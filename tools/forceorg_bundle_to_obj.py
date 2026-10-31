#!/usr/bin/env python3
"""Convert a static ForceOrg Unity prefab bundle into validated OBJ parts.

UnityPy is an optional local dependency. The game invokes a packaged copy of
this helper only after downloading a bundle selected from the user's catalog.
No Lua scripts or other bundle code are executed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any

MAX_INPUT_BYTES = 64 * 1024 * 1024
MAX_TOTAL_INPUT_BYTES = 128 * 1024 * 1024
MAX_OUTPUT_BYTES = 256 * 1024 * 1024
MAX_OUTPUT_FILES = 2048
MAX_PARTS = 256
MAX_DEPENDENCIES = 16
TEXTURE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp"}


def _component_pointer(component: Any) -> Any:
    if isinstance(component, tuple):
        return component[1]
    return getattr(component, "component", None)


def _transform(game_object: Any, env: Any) -> Any | None:
    for component in getattr(game_object, "m_Component", []):
        pointer = _component_pointer(component)
        if pointer is None:
            continue
        try:
            reader = pointer.deref()
            if reader and reader.type.name == "Transform":
                return pointer.deref_parse_as_object()
        except Exception:
            continue
    return None


def _vector(value: Any, dimensions: int) -> list[float]:
    keys = ("x", "y", "z", "w")[:dimensions]
    result = [float(getattr(value, key)) for key in keys]
    if not all(map(lambda part: abs(part) < 1_000_000, result)):
        raise ValueError("Unity transform contains an invalid numeric value")
    return result


def _transform_chain(transform: Any, root_ids: set[int]) -> list[dict[str, list[float]]]:
    chain: list[dict[str, list[float]]] = []
    visited: set[int] = set()
    current = transform
    reached_root = not root_ids
    while current is not None:
        reader = current.object_reader
        path_id = int(reader.path_id)
        if path_id in visited or len(chain) > 32:
            raise ValueError("Unity prefab transform hierarchy is cyclic or too deep")
        visited.add(path_id)
        chain.append(
            {
                "position": _vector(current.m_LocalPosition, 3),
                "rotation_quaternion": _vector(current.m_LocalRotation, 4),
                "scale": _vector(current.m_LocalScale, 3),
            }
        )
        parent = getattr(current, "m_Father", None)
        if not parent:
            current = None
            continue
        parent_id = int(parent.path_id)
        if parent_id in root_ids:
            reached_root = True
        try:
            current = parent.deref_parse_as_object()
        except Exception as error:
            raise ValueError("Unity prefab has a missing parent transform") from error
    if not reached_root:
        raise ValueError("Renderer is outside the prefab root")
    chain.reverse()
    return chain


def _property_map(items: Any) -> dict[str, Any]:
    if isinstance(items, dict):
        return dict(items)
    output: dict[str, Any] = {}
    for key, value in items or []:
        output[key if isinstance(key, str) else getattr(key, "name", str(key))] = value
    return output


def _bundle_name(value: Any) -> str:
    return str(value or "").replace("\\", "/").rsplit("/", 1)[-1].strip().casefold()


def _color(value: Any, default: tuple[float, float, float, float]) -> tuple[float, float, float, float]:
    if value is None:
        return default
    if isinstance(value, (tuple, list)):
        values = tuple(float(channel) for channel in value)
        return (values + (1.0, 1.0, 1.0, 1.0))[:4]
    return tuple(float(getattr(value, key, fallback)) for key, fallback in zip(("r", "g", "b", "a"), default))


def _texture_filename(name: str) -> str:
    safe_name = re.sub(r"[^A-Za-z0-9._-]+", "_", name).strip("._-") or "texture"
    return safe_name + ".png"


def _reconcile_material_textures(part_dir: Path) -> None:
    """Rename UnityPy's original texture filenames to the safe names in MTL."""
    for material_path in part_dir.glob("*.mtl"):
        for line in material_path.read_text(encoding="utf-8", errors="replace").splitlines():
            words = line.strip().split()
            if not words or words[0] not in {"map_Kd", "map_Bump", "map_Kn", "bump", "norm"} or len(words) < 2:
                continue
            reference = words[-1].replace("\\", "/")
            texture_name = Path(reference).name
            if not texture_name or texture_name != reference or ":" in reference:
                raise ValueError("Converted material contains an unsafe texture path")
            target = part_dir / texture_name
            if target.is_file():
                continue
            candidates = [
                path
                for path in part_dir.iterdir()
                if path.is_file()
                and path.suffix.lower() not in {".obj", ".mtl"}
                and _texture_filename(path.stem).casefold() == texture_name.casefold()
            ]
            if len(candidates) != 1:
                raise ValueError(f"Could not uniquely match exported material texture {texture_name!r}")
            candidates[0].replace(target)


def _normalize_obj_face_references(mesh_path: Path) -> list[str]:
    """Normalize UV indices and drop authored normals, which Godot recomputes."""
    temp_path = mesh_path.with_suffix(mesh_path.suffix + ".normalized")
    vertex_count = 0
    uv_count = 0
    invalid_uv_references = 0
    with mesh_path.open("r", encoding="utf-8", errors="replace") as source, temp_path.open(
        "w", encoding="utf-8", newline="\n"
    ) as target:
        for line in source:
            words = line.split("#", 1)[0].split()
            if words and words[0] == "v":
                vertex_count += 1
                target.write(line)
            elif words and words[0] == "vt":
                uv_count += 1
                target.write(line)
            elif words and words[0] == "f":
                normalized_tokens: list[str] = []
                for token in words[1:]:
                    indices = token.split("/")
                    if len(indices) > 3 or not indices[0]:
                        raise ValueError("Exported OBJ contains an invalid face reference")
                    try:
                        vertex_index = int(indices[0])
                    except ValueError as error:
                        raise ValueError("Exported OBJ contains a non-numeric vertex reference") from error
                    if vertex_index == 0 or (vertex_index > 0 and vertex_index > vertex_count) or (vertex_index < 0 and -vertex_index > vertex_count):
                        raise ValueError("Exported OBJ face references a missing vertex")
                    uv_index = indices[1] if len(indices) > 1 else ""
                    if uv_index:
                        try:
                            uv_value = int(uv_index)
                        except ValueError:
                            uv_value = 0
                        if uv_value == 0 or (uv_value > 0 and uv_value > uv_count) or (uv_value < 0 and -uv_value > uv_count):
                            uv_index = ""
                            invalid_uv_references += 1
                    normalized_tokens.append(indices[0] + ("/" + uv_index if uv_index else ""))
                target.write("f " + " ".join(normalized_tokens) + "\n")
            else:
                target.write(line)
    try:
        temp_path.replace(mesh_path)
    except PermissionError:
        # Windows scanners can briefly deny replacement even though the staged
        # file is writable. This directory is still private conversion output,
        # so copy into the existing file as a bounded-memory fallback.
        with temp_path.open("rb") as source, mesh_path.open("wb") as target:
            shutil.copyfileobj(source, target, length=1024 * 1024)
        temp_path.unlink(missing_ok=True)

    warnings: list[str] = []
    if invalid_uv_references:
        warnings.append(f"Dropped {invalid_uv_references} invalid UV references; normals are recomputed by the runtime.")
    if uv_count == 0:
        dropped_maps = 0
        for material_path in mesh_path.parent.glob("*.mtl"):
            kept_lines: list[str] = []
            for line in material_path.read_text(encoding="utf-8", errors="replace").splitlines():
                words = line.strip().split()
                if words and words[0] in {"map_Kd", "map_kd", "map_Bump", "map_bump", "map_Kn", "map_kn", "bump", "norm"}:
                    dropped_maps += 1
                    continue
                kept_lines.append(line)
            material_path.write_text("\n".join(kept_lines) + "\n", encoding="utf-8")
        if dropped_maps:
            warnings.append(f"Omitted {dropped_maps} material texture maps because this OBJ has no UV coordinates.")
    return warnings


def _export_material(material: Any) -> str:
    props = material.m_SavedProperties
    colors = _property_map(getattr(props, "m_Colors", []))
    floats = _property_map(getattr(props, "m_Floats", []))
    tex_envs = _property_map(getattr(props, "m_TexEnvs", []))
    diffuse = _color(colors.get("_Color"), (0.8, 0.8, 0.8, 1.0))
    ambient = _color(colors.get("_SColor"), (0.2, 0.2, 0.2, 1.0))
    specular = _color(colors.get("_SpecularColor"), (0.2, 0.2, 0.2, 1.0))
    shininess = float(floats.get("_Shininess", 20.0))
    transparency = float(floats.get("_Transparency", 0.0))
    lines = [
        f"newmtl {material.m_Name}",
        "Ka %.4f %.4f %.4f" % ambient[:3],
        "Kd %.4f %.4f %.4f" % diffuse[:3],
        "Ks %.4f %.4f %.4f" % specular[:3],
        f"Tr {transparency:.4f}",
        f"Ns {shininess:.4f}",
    ]
    for key, texture_env in tex_envs.items():
        texture_pointer = getattr(texture_env, "m_Texture", None)
        if not texture_pointer:
            continue
        texture = texture_pointer.deref_parse_as_object()
        texture_name = _texture_filename(str(texture.m_Name or key))
        normalized_key = key if isinstance(key, str) else getattr(key, "name", str(key))
        if normalized_key == "_MainTex":
            lines.append(f"map_Kd {texture_name}")
        elif normalized_key in {"_BumpMap", "_NormalMap", "_BaseNormalMap"}:
            lines.append(f"map_Bump {texture_name}")
    return "\n".join(lines)


def _export_mesh_renderer(renderer: Any, export_dir: str) -> None:
    """Export one renderer with Windows-safe mesh and texture filenames."""
    from UnityPy.export import MeshRendererExporter

    env = renderer.object_reader.assets_file.environment
    env.fs.makedirs(export_dir, exist_ok=True)
    mesh = MeshRendererExporter.get_mesh(renderer)
    if not mesh:
        return
    safe_mesh_name = re.sub(r"[^A-Za-z0-9._-]+", "_", str(mesh.m_Name or "mesh")).strip("._-") or "mesh"
    mesh.m_Name = safe_mesh_name

    first_submesh = 0
    if hasattr(renderer, "m_StaticBatchInfo") and renderer.m_StaticBatchInfo.subMeshCount > 0:
        first_submesh = renderer.m_StaticBatchInfo.firstSubMesh
    elif hasattr(renderer, "m_SubsetIndices") and renderer.m_SubsetIndices:
        first_submesh = min(renderer.m_SubsetIndices)

    materials: list[str] = []
    material_names: list[str | None] = []
    renderer_materials = getattr(renderer, "m_Materials", []) or []
    for index in range(len(mesh.m_SubMeshes)):
        material_index = index - first_submesh
        if material_index < 0 or material_index >= len(renderer_materials):
            continue
        material_pointer = renderer_materials[material_index]
        if not material_pointer:
            material_names.append(None)
            continue
        material = material_pointer.deref_parse_as_object()
        safe_material_name = re.sub(r"[^A-Za-z0-9._-]+", "_", str(material.m_Name or "material")).strip("._-") or "material"
        material.m_Name = safe_material_name
        materials.append(_export_material(material))
        material_names.append(safe_material_name)
        texture_envs = _property_map(getattr(material.m_SavedProperties, "m_TexEnvs", []))
        for key, texture_env in texture_envs.items():
            texture_pointer = getattr(texture_env, "m_Texture", None)
            if not texture_pointer:
                continue
            texture = texture_pointer.deref_parse_as_object()
            property_name = key if isinstance(key, str) else getattr(key, "name", str(key))
            filename = _texture_filename(str(texture.m_Name or property_name))
            with env.fs.open(env.fs.sep.join([export_dir, filename]), "wb") as texture_file:
                texture.image.save(texture_file)

    obj_path = env.fs.sep.join([export_dir, f"{safe_mesh_name}.obj"])
    mtl_path = env.fs.sep.join([export_dir, f"{safe_mesh_name}.mtl"])
    obj_text = MeshRendererExporter.export_mesh_obj(mesh, material_names)
    if not isinstance(obj_text, str) or not obj_text.strip():
        return
    with env.fs.open(obj_path, "wt", encoding="utf8", newline="") as obj_file:
        obj_file.write(obj_text)
    with env.fs.open(mtl_path, "wt", encoding="utf8", newline="") as mtl_file:
        mtl_file.write("\n".join(materials))


def _patch_export_compatibility(unitypy: Any) -> None:
    """Adapt UnityPy's renderer exporter to current generated type wrappers."""
    from UnityPy.export import MeshRendererExporter

    MeshRendererExporter.export_material = _export_material
    MeshRendererExporter.export_mesh_renderer = _export_mesh_renderer


def _deduplicate_textures(destination: Path) -> int:
    """Hard-link byte-identical renderer textures while preserving sidecar paths."""
    canonical_by_hash: dict[str, Path] = {}
    deduplicated = 0
    for path in sorted(destination.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in TEXTURE_SUFFIXES:
            continue
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        canonical = canonical_by_hash.get(digest)
        if canonical is None:
            canonical_by_hash[digest] = path
            continue
        path.unlink()
        try:
            os.link(canonical, path)
            deduplicated += 1
        except OSError:
            # Some filesystems disallow hard links. Keep a regular copy; the
            # physical-output bound below will still count its full byte size.
            shutil.copyfile(canonical, path)
    return deduplicated


def _unique_output_bytes(files: list[Path]) -> int:
    seen: set[tuple[int, int] | str] = set()
    total_bytes = 0
    for path in files:
        stat = path.stat()
        identity: tuple[int, int] | str = (stat.st_dev, stat.st_ino) if stat.st_ino else str(path.resolve()).casefold()
        if identity in seen:
            continue
        seen.add(identity)
        total_bytes += stat.st_size
    return total_bytes


def convert(source: Path, destination: Path, dependencies: list[Path] | None = None) -> dict[str, Any]:
    if not source.is_file():
        raise ValueError("AssetBundle input does not exist")
    size = source.stat().st_size
    if size <= 0 or size > MAX_INPUT_BYTES:
        raise ValueError("AssetBundle is empty or exceeds the 64 MiB input limit")
    dependencies = dependencies or []
    if len(dependencies) > MAX_DEPENDENCIES:
        raise ValueError(f"AssetBundle exceeds the {MAX_DEPENDENCIES} dependency limit")
    for dependency in dependencies:
        if not dependency.is_file() or dependency.stat().st_size <= 0 or dependency.stat().st_size > MAX_INPUT_BYTES:
            raise ValueError("AssetBundle dependency is missing, empty, or exceeds the 64 MiB input limit")
    if size + sum(path.stat().st_size for path in dependencies) > MAX_TOTAL_INPUT_BYTES:
        raise ValueError("AssetBundle and its dependencies exceed the 128 MiB combined input limit")
    if destination.exists() and any(destination.iterdir()):
        raise ValueError("Output directory must be empty")
    destination.mkdir(parents=True, exist_ok=True)

    try:
        import UnityPy
    except ImportError as error:
        raise RuntimeError("UnityPy is unavailable; install the optional ForceOrg converter") from error
    _patch_export_compatibility(UnityPy)
    env = UnityPy.load(str(source))
    objects = list(env.objects)
    if len(objects) > 100_000:
        raise ValueError("AssetBundle exceeds the 100,000 serialized object limit")
    primary_asset_files = {str(getattr(reader.assets_file, "name", "")) for reader in objects}
    required_dependencies: set[str] = set()
    for reader in objects:
        if reader.type.name != "AssetBundle":
            continue
        for dependency_name in getattr(reader.read(), "m_Dependencies", []) or []:
            normalized = _bundle_name(dependency_name)
            if normalized:
                required_dependencies.add(normalized)
    loaded_dependencies: list[Path] = []
    loaded_dependency_names: set[str] = set()
    for dependency_path in dependencies:
        candidate_env = UnityPy.load(str(dependency_path))
        candidate_objects = list(candidate_env.objects)
        if len(candidate_objects) > 100_000:
            raise ValueError("AssetBundle dependency exceeds the 100,000 serialized object limit")
        candidate_names = {
            _bundle_name(getattr(reader.read(), "m_Name", ""))
            for reader in candidate_objects
            if reader.type.name == "AssetBundle"
        }
        matching_names = candidate_names & required_dependencies
        if not matching_names:
            continue
        env.load_file(str(dependency_path))
        loaded_dependencies.append(dependency_path)
        loaded_dependency_names.update(matching_names)
        if len(list(env.objects)) > 100_000:
            raise ValueError("AssetBundle assembly exceeds the 100,000 serialized object limit")
    missing_bundle_dependencies = required_dependencies - loaded_dependency_names
    dependencies_complete = not missing_bundle_dependencies
    unresolved_external_reference = False

    def is_primary_reader(reader: Any) -> bool:
        asset_file = getattr(reader, "assets_file", None)
        if asset_file is None:
            try:
                asset_file = reader.deref().assets_file
            except Exception:
                return False
        return str(getattr(asset_file, "name", "")) in primary_asset_files

    root_objects = [
        reader.deref_parse_as_object()
        for reader in env.container.values()
        if reader.type.name == "GameObject" and is_primary_reader(reader)
    ]
    root_transforms = [_transform(game_object, env) for game_object in root_objects]
    root_ids = {int(value.object_reader.path_id) for value in root_transforms if value is not None}

    parts: list[dict[str, Any]] = []
    renderers = [obj for obj in env.objects if obj.type.name in {"MeshRenderer", "SkinnedMeshRenderer"} and is_primary_reader(obj)]
    for renderer_index, renderer_reader in enumerate(renderers):
        if len(parts) >= MAX_PARTS:
            raise ValueError("AssetBundle exceeds the 256 rendered-part limit")
        renderer = renderer_reader.parse_as_object()
        if not bool(getattr(renderer, "m_Enabled", True)):
            continue
        game_object_pointer = getattr(renderer, "m_GameObject", None)
        if not game_object_pointer:
            continue
        game_object = game_object_pointer.deref_parse_as_object()
        transform = _transform(game_object, env)
        if transform is None:
            continue
        try:
            transforms = _transform_chain(transform, root_ids)
        except ValueError as error:
            if str(error) == "Renderer is outside the prefab root":
                continue
            raise

        material_pointers = getattr(renderer, "m_Materials", None)
        if material_pointers is None:
            renderer.m_Materials = []
            material_pointers = renderer.m_Materials
        if not getattr(renderer, "m_SubsetIndices", None):
            renderer.m_SubsetIndices = [0]
        if not isinstance(material_pointers, list):
            renderer.m_Materials = list(material_pointers)
            material_pointers = renderer.m_Materials
        missing_dependency_warnings: list[str] = []
        for dependency_name in sorted(missing_bundle_dependencies):
            warning = f"Declared Unity AssetBundle dependency {dependency_name} is unavailable; external material data may be incomplete."
            if warning not in missing_dependency_warnings:
                missing_dependency_warnings.append(warning)
        for material_index, material_pointer in enumerate(material_pointers):
            if not material_pointer:
                continue
            try:
                material = material_pointer.deref_parse_as_object()
            except FileNotFoundError as error:
                unresolved_external_reference = True
                renderer.m_Materials[material_index] = None
                dependency = str(error).split(" not found in ", 1)[0].removeprefix("File ")
                warning = f"External CAB dependency {dependency} is unavailable; this renderer uses the default material."
                if warning not in missing_dependency_warnings:
                    missing_dependency_warnings.append(warning)
                continue
            tex_envs = getattr(material.m_SavedProperties, "m_TexEnvs", [])
            if isinstance(tex_envs, dict):
                material.m_SavedProperties.m_TexEnvs = list(tex_envs.items())
                tex_envs = material.m_SavedProperties.m_TexEnvs
            for texture_env in _property_map(tex_envs).values():
                texture_pointer = getattr(texture_env, "m_Texture", None)
                if not texture_pointer:
                    continue
                try:
                    texture_pointer.deref_parse_as_object()
                except FileNotFoundError as error:
                    unresolved_external_reference = True
                    texture_env.m_Texture = None
                    dependency = str(error).split(" not found in ", 1)[0].removeprefix("File ")
                    warning = f"External CAB texture {dependency} is unavailable; its material map was omitted."
                    if warning not in missing_dependency_warnings:
                        missing_dependency_warnings.append(warning)

        safe_name = re.sub(r"[^A-Za-z0-9._-]+", "_", str(game_object.m_Name or "part"))[:80]
        part_dir = destination / "parts" / f"{renderer_index:04d}_{safe_name}"
        part_dir.mkdir(parents=True, exist_ok=True)
        try:
            renderer.export(str(part_dir))
            _reconcile_material_textures(part_dir)
        except Exception as error:
            raise ValueError(f"Could not export rendered object {game_object.m_Name!r}: {error}") from error
        mesh_files = sorted(part_dir.rglob("*.obj"))
        if not mesh_files:
            for path in part_dir.iterdir():
                if path.is_file():
                    path.unlink()
            part_dir.rmdir()
            continue
        if len(mesh_files) != 1:
            raise ValueError(f"Rendered object {game_object.m_Name!r} did not produce one OBJ mesh")
        mesh_path = mesh_files[0]
        warnings = missing_dependency_warnings + _normalize_obj_face_references(mesh_path)
        relative = mesh_path.relative_to(destination).as_posix()
        parts.append({"name": str(game_object.m_Name or safe_name), "mesh": relative, "transforms": transforms, "warnings": warnings})

    if not parts:
        raise ValueError("AssetBundle contains no supported static mesh renderers")
    dependencies_complete = dependencies_complete and not unresolved_external_reference
    deduplicated_textures = _deduplicate_textures(destination)
    files = [path for path in destination.rglob("*") if path.is_file()]
    total_bytes = _unique_output_bytes(files)
    if len(files) > MAX_OUTPUT_FILES or total_bytes > MAX_OUTPUT_BYTES:
        raise ValueError(f"Converted AssetBundle output exceeds limits ({len(files)} files, {total_bytes} unique bytes; limits {MAX_OUTPUT_FILES} files and {MAX_OUTPUT_BYTES} bytes)")
    if not all((destination / part["mesh"]).is_file() for part in parts):
        raise ValueError("Converted mesh manifest contains a missing file")

    source_sha256 = hashlib.sha256(source.read_bytes()).hexdigest()
    dependency_sha256 = [hashlib.sha256(path.read_bytes()).hexdigest() for path in loaded_dependencies]
    conversion_sha256 = source_sha256
    if dependency_sha256:
        conversion_material = "\n".join([source_sha256, *dependency_sha256]).encode("ascii")
        conversion_sha256 = hashlib.sha256(conversion_material).hexdigest()
    manifest = {
        "version": 1,
        "source_sha256": source_sha256,
        "dependency_sha256": dependency_sha256,
        "conversion_sha256": conversion_sha256,
        "dependencies_complete": dependencies_complete,
        "unity_version": str(getattr(objects[0].assets_file, "unity_version", "unknown")) if objects else "unknown",
        "part_count": len(parts),
        "deduplicated_textures": deduplicated_textures,
        "parts": parts,
    }
    (destination / "manifest.json").write_text(json.dumps(manifest, separators=(",", ":")), encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--dependency", action="append", default=[], type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--result", type=Path, help=argparse.SUPPRESS)
    parser.add_argument("--unitypy-path", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.unitypy_path is not None:
        sys.path.insert(0, str(args.unitypy_path.resolve()))
    try:
        manifest = convert(args.input, args.output, args.dependency)
    except Exception as error:
        result = {"error": str(error)}
        if args.result is not None:
            args.result.parent.mkdir(parents=True, exist_ok=True)
            args.result.write_text(json.dumps(result), encoding="utf-8")
        print(json.dumps(result), file=sys.stderr)
        return 1
    result = {"error": "", "part_count": manifest["part_count"], "deduplicated_textures": manifest["deduplicated_textures"], "manifest": str(args.output / "manifest.json")}
    if args.result is not None:
        args.result.parent.mkdir(parents=True, exist_ok=True)
        args.result.write_text(json.dumps(result), encoding="utf-8")
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

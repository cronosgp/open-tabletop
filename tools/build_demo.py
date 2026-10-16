"""Export only the offline movement demo. Native binaries need Godot export templates."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import sys

from verify import ROOT, Runner, stage


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT", "godot"))
    parser.add_argument("--target", choices=("pack", "windows", "linux"), default="pack")
    parser.add_argument("--templates", type=Path, help="Directory containing Godot 4.7.2 native export templates")
    args = parser.parse_args()
    engine = shutil.which(args.godot)
    if not engine:
        parser.error("Godot not found; pass --godot /path/to/godot")
    directory = ROOT / ".tools/verification" / ("build-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ"))
    directory.mkdir(parents=True)
    project = stage(directory, "demo")
    runner = Runner(str(Path(engine).resolve()), project, directory, 120)
    preset = "Linux Demo" if args.target == "linux" else "Windows Demo"
    if args.target != "pack":
        # User profiles are isolated; resolve templates before redirecting APPDATA/XDG.
        native = "windows_release_x86_64.exe" if args.target == "windows" else "linux_release.x86_64"
        default = (Path(os.environ.get("APPDATA", str(Path.home() / "AppData/Roaming"))) / "Godot/export_templates/4.7.2.stable"
                   if os.name == "nt" else Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "godot/export_templates/4.7.2.stable")
        template = (args.templates or default).resolve() / native
        if not template.is_file():
            parser.error(f"Missing {template}; install matching export templates or pass --templates DIRECTORY")
        configuration = project / "export_presets.cfg"
        section = "[preset.0.options]" if args.target == "windows" else "[preset.1.options]"
        current = ""
        lines = []
        for line in configuration.read_text(encoding="utf-8").splitlines():
            if line.startswith("["):
                current = line
            if current == section and line.startswith("custom_template/release="):
                line = "custom_template/release=" + json.dumps(template.as_posix())
            lines.append(line)
        configuration.write_text("\n".join(lines) + "\n", encoding="utf-8")
    suffix = {"pack": ".pck", "windows": ".exe", "linux": ".x86_64"}[args.target]
    output = directory / ("open-tabletop-demo" + suffix)
    runner.run("import", [runner.engine, "--headless", "--path", str(project),
                          "--log-file", str(directory / "import.engine.log"), "--editor", "--import"])
    if runner.results[-1]["status"] == "passed":
        runner.run("export", [runner.engine, "--headless", "--path", str(project),
                              "--log-file", str(directory / "export.engine.log"),
                              "--export-pack" if args.target == "pack" else "--export-release", preset, str(output)])
    if runner.results[-1]["status"] == "passed" and output.is_file():
        if args.target == "pack":
            runner.run("exported-startup", [runner.engine, "--headless", "--path", str(project),
                                           "--main-pack", str(output), "--log-file", str(directory / "exported.engine.log"), "--quit-after", "5"])
    success = output.is_file() and all(result["status"] == "passed" for result in runner.results)
    (directory / "results.json").write_text(json.dumps(dict(target=args.target, artifact=str(output), results=runner.results), indent=2), encoding="utf-8")
    print("Exported:" if success else "Build failed:", output if success else directory)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

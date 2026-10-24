"""Export the offline demo and smoke-test the current tactical training profile.

Native binaries need Godot export templates. The export still excludes the
historical starter snapshot and third-party data; the tactical smoke test
proves that the project-owned current-reference profile can start from the
same clean staged tree used for the pack.
"""
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
    parser.add_argument("--timeout", type=float, default=300, help="Seconds per import/export/startup process")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    engine = shutil.which(args.godot)
    if not engine:
        parser.error("Godot not found; pass --godot /path/to/godot")
    directory = ROOT / ".tools/verification" / ("build-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ"))
    directory.mkdir(parents=True)
    project = stage(directory, "demo")
    runner = Runner(str(Path(engine).resolve()), project, directory, args.timeout)
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
        runner.run("tactical-smoke", runner.command("tactical-smoke", "test_tactical_training"))
    if runner.results[-1]["status"] == "passed":
        runner.run("export", [runner.engine, "--headless", "--path", str(project),
                              "--log-file", str(directory / "export.engine.log"),
                              "--export-pack" if args.target == "pack" else "--export-release", preset, str(output)])
    if runner.results[-1]["status"] == "passed" and output.is_file():
        if args.target == "pack":
            runner.run("exported-startup", [runner.engine, "--headless", "--path", str(project),
                                           "--main-pack", str(output), "--log-file", str(directory / "exported.engine.log"), "--quit-after", "5"])
            if runner.results[-1]["status"] == "passed":
                smoke_script = directory / "pck_tactical_smoke.gd"
                smoke_script.write_text("""extends SceneTree
func _initialize() -> void:
\tcall_deferred(\"run\")
func run() -> void:
\tvar game = load(\"res://scenes/main.tscn\").instantiate()
\troot.add_child(game)
\tgame._start_guided_first_session()
\tvar points: Dictionary = game.state.get(\"training_points\", {})
\tgame._refresh_first_session_guide()
\tgame._refresh_decision()
\tvar title_ok: bool = game.main_menu != null and game.main_menu.guided_button != null and game.main_menu.training_summary != null and game.main_menu.guided_button.text == \"Start tactical training\" and \"Practice:\" in game.main_menu.training_summary.text
\tvar guide_ok: bool = game.first_session_experiments != null and game.first_session_experiments.visible and \"CURRENT WINDOW: PREPARATION\" in game.first_session_experiments.text and game.tactical_opportunity_label != null and not game.tactical_opportunity_label.visible
\tvar ok: bool = game.saved_army_mode and game.guided_first_session and points == {1: 290, 2: 235} and title_ok and guide_ok
\tprint(\"PCK tactical smoke: %s\" % (\"PASS\" if ok else \"FAIL\"))
\tgame.free()
\tawait process_frame
\tquit(0 if ok else 1)
""", encoding="utf-8")
                runner.run("tactical-pack-smoke", [runner.engine, "--headless", "--main-pack", str(output),
                                                    "--script", str(smoke_script), "--log-file", str(directory / "tactical-pack-smoke.engine.log")])
    success = output.is_file() and all(result["status"] == "passed" for result in runner.results)
    (directory / "results.json").write_text(json.dumps(dict(target=args.target, artifact=str(output), results=runner.results), indent=2), encoding="utf-8")
    print("Exported:" if success else "Build failed:", output if success else directory)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

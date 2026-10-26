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
const AbilityReference = preload(\"res://scripts/ui/local_ability_reference.gd\")
func _initialize() -> void:
\tcall_deferred(\"run\")
func _find_unit(game: Node, owner: int, suffix: String) -> int:
\tfor id: int in game.state.units:
\t\tvar unit: Dictionary = game.state.units[id]
\t\tif int(unit.get(\"owner\", 0)) == owner and str(unit.get(\"definition_id\", \"\")).ends_with(\":\" + suffix):
\t\t\treturn id
\treturn -1
func _find_choice(game: Node, owner: int, action: String, model: int = -1, target: int = -1) -> Dictionary:
\tfor choice: Dictionary in game.Combat.unit_choices(game.state, owner):
\t\tif str(choice.get(\"action\", \"\")) != action: continue
\t\tif model >= 0 and int(choice.get(\"model\", -1)) != model: continue
\t\tif target >= 0 and int(choice.get(\"target\", -1)) != target: continue
\t\treturn choice
\treturn {}
func run() -> void:
\tvar game = load(\"res://scenes/main.tscn\").instantiate()
\troot.add_child(game)
\tgame._start_guided_first_session()
\tgame.match_save_path = \"user://matches/pck-smoke.save\"
\tgame.match_journal_directory = \"user://matches/journals/pck-smoke\"
\tvar points: Dictionary = game.state.get(\"training_points\", {})
\tgame._refresh_first_session_guide()
\tgame._refresh_decision()
\tvar title_ok: bool = game.main_menu != null and game.main_menu.guided_button != null and game.main_menu.training_summary != null and game.main_menu.guided_button.text == \"Start tactical training\" and \"Practice:\" in game.main_menu.training_summary.text
\tvar guide_ok: bool = game.first_session_experiments != null and game.first_session_experiments.visible and \"CURRENT WINDOW: PREPARATION\" in game.first_session_experiments.text and game.tactical_opportunity_label != null and not game.tactical_opportunity_label.visible
\tvar setup_ok := true
\tfor owner: int in [1, 2]:
\t\tvar leader := _find_unit(game, owner, \"captain\" if owner == 1 else \"chaplain\")
\t\tvar bodyguard := _find_unit(game, owner, \"intercessor-squad\" if owner == 1 else \"assault-intercessor-squad\")
\t\tif leader < 0 or bodyguard < 0:
\t\t\tsetup_ok = false
\t\t\tbreak
\t\tfor choice_data: Array in [[\"warlord\", leader, -1], [\"attach\", leader, int(game.state.units[bodyguard].squad)], [\"setup-done\", -1, -1]]:
\t\t\tvar choice := _find_choice(game, owner, str(choice_data[0]), int(choice_data[1]), int(choice_data[2]))
\t\t\tif choice.is_empty():
\t\t\t\tsetup_ok = false
\t\t\t\tbreak
\t\t\tvar command_choice: Dictionary = game._unit_choice_payload(choice)
\t\t\tvar result: Dictionary = game.MatchCommandService.execute(game.state, owner, {\"kind\": game.MatchCommandService.SELECT_UNIT_CHOICE, \"choice\": command_choice, \"revision\": int(game.state.revision)}, game._d6)
\t\t\tif not str(result.get(\"error\", \"\")).is_empty():
\t\t\t\tsetup_ok = false
\t\t\t\tbreak
\t\tif not setup_ok: break
\tvar inspect_id := -1
\tfor id: int in game.state.units:
\t\tvar identity: String = game.Combat.UnitAbilities.identity(game.state.units[id])
\t\tif not game.Combat.UnitAbilities.RULES.get(identity, []).is_empty():
\t\t\tinspect_id = id
\t\t\tbreak
\tgame.selected = inspect_id
\tgame._refresh()
\tvar inspect_state := var_to_bytes(game.state)
\tvar inspect_rng: int = game.rng.state
\tgame._open_selected_datasheet()
\tvar reference_issue: String = str(game.datasheet_view.last_model.get(\"ability_source_issue\", \"\"))
\tvar reference_result: Dictionary = AbilityReference.load_from_roots(AbilityReference.USER_ROOT, AbilityReference.PROJECT_ROOT)
\tvar reference_absent: bool = reference_result.get(\"sheets\", {}).is_empty() and \"not installed\" in reference_issue
\tvar implemented_scope_visible: bool = not game.datasheet_view.last_model.get(\"abilities\", []).is_empty()
\tvar inspection_read_only: bool = game.selected == inspect_id and game.rng.state == inspect_rng and var_to_bytes(game.state) == inspect_state
\tgame._close_tactical_screen()
\tgame._reset_history()
\tvar saved_state: Dictionary = game.state.duplicate(true)
\tvar saved_rng: int = game.rng.state
\tvar save_error: String = game._save_snapshot()
\tvar recovery_ok := false
\tif save_error.is_empty():
\t\tgame.state.revision = int(game.state.revision) + 1
\t\tgame._load_match()
\t\trecovery_ok = game.resume_succeeded and game.state == saved_state and game.rng.state == saved_rng
\tvar ok: bool = game.saved_army_mode and game.guided_first_session and points == {1: 290, 2: 235} and title_ok and guide_ok and setup_ok and inspect_id >= 0 and reference_absent and implemented_scope_visible and inspection_read_only and recovery_ok
\tprint(\"PCK tactical smoke: %s (title=%s guide=%s setup=%s reference_absent=%s implemented_scope=%s inspection_read_only=%s save_recovery=%s)\" % [\"PASS\" if ok else \"FAIL\", title_ok, guide_ok, setup_ok, reference_absent, implemented_scope_visible, inspection_read_only, recovery_ok])
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

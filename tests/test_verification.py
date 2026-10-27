"""Regression checks for silent Godot errors and hung test processes."""
import importlib.util
from contextlib import redirect_stdout
import io
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("verification", Path(__file__).parents[1] / "tools/verify.py")
verification = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verification)
playtest_spec = importlib.util.spec_from_file_location("validate_tactical_playtest", Path(__file__).parents[1] / "tools/validate_tactical_playtest.py")
playtest = importlib.util.module_from_spec(playtest_spec)
playtest_spec.loader.exec_module(playtest)


class VerificationTests(unittest.TestCase):
    @staticmethod
    def _playtest_record(outcomes=None):
        outcomes = outcomes or {}
        lines = [
            "Date: 2026-10-24 04:00:00 -03:00",
            "Code revision: test-revision",
            "Scenario: marine-tactical-training-v1",
            "Mode: shared computer, two participants alternating control",
            "",
            "| Gate | Outcome | Notes |",
            "|---|---|---|",
        ]
        for gate in playtest.REQUIRED_GATES:
            lines.append(f"| {gate} | {outcomes.get(gate, 'pass')} | observed in the actual session |")
        return "\n".join(lines) + "\n"

    def test_tactical_playtest_record_accepts_only_a_complete_pass_record(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            path.write_text(self._playtest_record(), encoding="utf-8")
            code, messages = playtest.validate(path)
        self.assertEqual(code, 0)
        self.assertIn("recorded session only", messages[0])

    def test_tactical_playtest_record_keeps_partial_outcomes_open(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            gate = "Experiment progress checklist understood"
            path.write_text(self._playtest_record({gate: "not observed"}), encoding="utf-8")
            code, messages = playtest.validate(path)
        self.assertEqual(code, 3)
        self.assertIn("not observed", messages[0])

    def test_tactical_playtest_cannot_pass_without_corrected_experience_observations(self):
        gate = "Optional roll kept without CP and paid reroll cost understood"
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            record = self._playtest_record()
            record = "\n".join(line for line in record.splitlines() if not line.startswith(f"| {gate} |"))
            path.write_text(record, encoding="utf-8")
            code, messages = playtest.validate(path)
            self.assertEqual(code, 2)
            self.assertTrue(any(gate in message for message in messages))
            path.write_text(self._playtest_record({gate: "not observed"}), encoding="utf-8")
            code, messages = playtest.validate(path)
            self.assertEqual(code, 3)
            self.assertTrue(any(gate in message for message in messages))

    def test_playtest_launcher_contains_all_required_blank_observations(self):
        launcher = (Path(__file__).parents[1] / "tools/run_tactical_playtest.ps1").read_text(encoding="utf-8")
        for gate in playtest.REQUIRED_GATES:
            self.assertIn(f"| {gate} | | |", launcher)

    def test_tactical_playtest_record_rejects_blank_gate_outcomes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            path.write_text(self._playtest_record({playtest.REQUIRED_GATES[0]: ""}), encoding="utf-8")
            code, messages = playtest.validate(path)
        self.assertEqual(code, 2)
        self.assertTrue(any("Outcome is missing" in message for message in messages))

    def test_tactical_playtest_record_rejects_missing_gate_notes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            record = self._playtest_record()
            record = record.replace("| Both forces, model counts and points understood | pass | observed in the actual session |", "| Both forces, model counts and points understood | pass | |")
            path.write_text(record, encoding="utf-8")
            code, messages = playtest.validate(path)
        self.assertEqual(code, 2)
        self.assertTrue(any("Notes are missing" in message for message in messages))

    def test_tactical_playtest_record_rejects_placeholder_gate_notes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "record.md"
            record = self._playtest_record()
            record = record.replace("| Both forces, model counts and points understood | pass | observed in the actual session |", "| Both forces, model counts and points understood | pass | observed |")
            path.write_text(record, encoding="utf-8")
            code, messages = playtest.validate(path)
        self.assertEqual(code, 2)
        self.assertTrue(any("describe the observed evidence" in message for message in messages))

    def test_focused_profile_runs_only_requested_local_suites(self):
        suites = ["test_actions", "test_phase_progression", "test_network"]
        self.assertEqual(
            verification.select_suites("focused", suites, ["test_phase_progression"], False),
            ["test_phase_progression"],
        )

    def test_focused_profile_requires_an_explicit_suite(self):
        with self.assertRaisesRegex(ValueError, "requires at least one --only"):
            verification.select_suites("focused", ["test_actions"], [], False)

    def test_targeted_profile_requires_an_explicit_suite(self):
        with self.assertRaisesRegex(ValueError, "requires at least one --only"):
            verification.select_suites("targeted", ["test_actions"], [], False)

    def test_targeted_profile_allows_data_backed_suites(self):
        suite = "test_marine_machine_spirits"
        self.assertTrue(verification.needs_legacy_starter(suite))
        self.assertEqual(verification.select_suites("targeted", [suite], [suite], False), [suite])
        self.assertTrue(verification.requires_legacy_starter("targeted", [suite]))

    def test_targeted_profile_skips_legacy_snapshot_for_independent_suites(self):
        self.assertFalse(verification.requires_legacy_starter("targeted", ["test_phase_progression"]))
        self.assertTrue(verification.requires_legacy_starter("full", ["test_phase_progression"]))

    def test_runtime_layout_exercises_declare_their_legacy_data_dependency(self):
        self.assertTrue(verification.needs_legacy_starter("test_gameplay_layout"))
        self.assertTrue(verification.needs_legacy_starter("test_unit_choice_help_ui"))
        self.assertTrue(verification.needs_legacy_starter("test_selection_card"))
        self.assertTrue(verification.requires_legacy_starter("targeted", ["test_gameplay_layout"]))

    def test_current_catalog_match_suites_do_not_stage_legacy_snapshot(self):
        suites = ["test_local_match_vertical_slice", "test_current_reference_match_network",
                  "test_tactical_training", "test_tactical_combat_flow", "test_roll_choice_ui", "test_doctrine_choice_ui", "test_save_outcome_ui", "test_selection_response"]
        for suite in suites:
            self.assertFalse(verification.needs_legacy_starter(suite))
        self.assertFalse(verification.requires_legacy_starter("targeted", suites))

    def test_synthetic_builder_regression_does_not_stage_legacy_snapshot(self):
        self.assertFalse(verification.needs_legacy_starter("test_army_builder"))
        self.assertFalse(verification.requires_legacy_starter("demo", ["test_army_builder"]))

    def test_demo_allowlist_is_data_free_for_the_complete_profile(self):
        self.assertFalse(verification.requires_legacy_starter("demo", sorted(verification.DEMO)))

    def test_focused_profile_runs_fast_architecture_and_runner_checks(self):
        command = verification.python_command("focused")
        self.assertEqual(command[-2:], ["tests.test_architecture", "tests.test_verification"])

    def test_targeted_profile_runs_the_same_fast_prechecks(self):
        command = verification.python_command("targeted")
        self.assertEqual(command[-2:], ["tests.test_architecture", "tests.test_verification"])

    def test_suite_listing_needs_no_godot_executable(self):
        with patch.object(sys, "argv", ["verify.py", "--list-suites"]), redirect_stdout(io.StringIO()) as output:
            self.assertEqual(verification.main(), 0)
        self.assertIn("test_match_command_service", output.getvalue())

    def test_report_metadata_records_effective_suite_selection(self):
        report = verification.report_metadata("focused", "godot", ["test_phase_progression"], False, 45, "2026-10-21T00:00:00+00:00")
        self.assertEqual(report["report_version"], 1)
        self.assertEqual(report["selected_suites"], ["test_phase_progression"])
        self.assertFalse(report["legacy_starter_staged"])
        self.assertFalse(report["network"])
        self.assertEqual(report["timeout_seconds"], 45)

    def test_full_and_demo_profiles_run_all_python_checks(self):
        for profile in ("demo", "full"):
            command = verification.python_command(profile)
            self.assertEqual(command[-5:], ["discover", "-s", "tests", "-p", "test_*.py"])

    def test_focused_profile_rejects_suites_that_need_the_legacy_snapshot(self):
        self.assertTrue(verification.needs_legacy_starter("test_marine_machine_spirits"))
        with self.assertRaisesRegex(ValueError, "use --profile targeted or full"):
            verification.select_suites("focused", ["test_marine_machine_spirits"], ["test_marine_machine_spirits"], False)
        self.assertFalse(verification.needs_legacy_starter("test_phase_progression"))

    def test_selected_network_suite_requires_network_flag(self):
        with self.assertRaisesRegex(ValueError, "requires --network"):
            verification.select_suites("focused", ["test_actions_network"], ["test_actions_network"], False)

    def test_demo_profile_remains_allowlisted(self):
        with self.assertRaisesRegex(ValueError, "requires --profile full, targeted or focused"):
            verification.select_suites("demo", ["test_phase_progression"], ["test_phase_progression"], False)

    def test_engine_error_cannot_pass_with_zero_exit(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 5)
            log = Path(directory) / "silent_error.log"
            log.write_text("SCRIPT ERROR: invalid state", encoding="utf-8")

            class ExitedProcess:
                returncode = 0

                @staticmethod
                def poll():
                    return 0

            with redirect_stdout(io.StringIO()), log.open("r", encoding="utf-8") as stream:
                runner.finish("silent_error", (ExitedProcess(), stream, log, verification.time.monotonic()))
            self.assertEqual(runner.results[0]["status"], "failed")
            self.assertEqual(runner.results[0]["exit_code"], 0)

    def test_headless_rid_shutdown_diagnostics_are_reported_but_not_runtime_failures(self):
        output = "ERROR: 2 RID allocations of type 'N16RendererViewport8ViewportE' were leaked at exit."
        self.assertTrue(verification.has_headless_rid_cleanup(output))
        self.assertFalse(verification.failed(0, output))
        self.assertTrue(verification.failed(0, output + "\nSCRIPT ERROR: invalid state"))
        self.assertTrue(verification.failed(1, output))

    def test_runtime_script_error_stops_a_hung_test_early(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 5)
            with redirect_stdout(io.StringIO()):
                runner.run("runtime_error", [sys.executable, "-u", "-c",
                                              "import time; print('SCRIPT ERROR: invalid state', flush=True); time.sleep(30)"])
            self.assertEqual(runner.results[0]["status"], "failed")
            self.assertTrue(runner.results[0]["stopped_on_error"])
            # The process must stop before the configured five-second timeout;
            # a fixed three-second wall-clock bound is flaky on a busy Windows
            # worker even when the early-error path works correctly.
            self.assertLess(runner.results[0]["seconds"], runner.timeout)

    def test_timeout_terminates_process_and_retains_log(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 0.4)
            with redirect_stdout(io.StringIO()):
                runner.run("hang", [sys.executable, "-u", "-c", "import time; print('started', flush=True); time.sleep(30)"])
            self.assertEqual(runner.results[0]["status"], "timeout")
            self.assertIn("started", Path(runner.results[0]["log"]).read_text())


if __name__ == "__main__":
    unittest.main()

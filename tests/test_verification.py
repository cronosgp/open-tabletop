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


class VerificationTests(unittest.TestCase):
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

    def test_demo_profile_never_stages_optional_legacy_snapshot(self):
        self.assertTrue(verification.needs_legacy_starter("test_army_builder"))
        self.assertFalse(verification.requires_legacy_starter("demo", ["test_army_builder"]))

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
            with redirect_stdout(io.StringIO()):
                runner.run("silent_error", [sys.executable, "-c", "print('SCRIPT ERROR: invalid state')"])
            self.assertEqual(runner.results[0]["status"], "failed")
            self.assertEqual(runner.results[0]["exit_code"], 0)

    def test_runtime_script_error_stops_a_hung_test_early(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 5)
            with redirect_stdout(io.StringIO()):
                runner.run("runtime_error", [sys.executable, "-u", "-c",
                                              "import time; print('SCRIPT ERROR: invalid state', flush=True); time.sleep(30)"])
            self.assertEqual(runner.results[0]["status"], "failed")
            self.assertTrue(runner.results[0]["stopped_on_error"])
            self.assertLess(runner.results[0]["seconds"], 3)

    def test_timeout_terminates_process_and_retains_log(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 0.4)
            with redirect_stdout(io.StringIO()):
                runner.run("hang", [sys.executable, "-u", "-c", "import time; print('started'); time.sleep(30)"])
            self.assertEqual(runner.results[0]["status"], "timeout")
            self.assertIn("started", Path(runner.results[0]["log"]).read_text())


if __name__ == "__main__":
    unittest.main()

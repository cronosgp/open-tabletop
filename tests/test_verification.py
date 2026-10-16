"""Regression checks for silent Godot errors and hung test processes."""
import importlib.util
from contextlib import redirect_stdout
import io
from pathlib import Path
import sys
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("verification", Path(__file__).parents[1] / "tools/verify.py")
verification = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verification)


class VerificationTests(unittest.TestCase):
    def test_engine_error_cannot_pass_with_zero_exit(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 5)
            with redirect_stdout(io.StringIO()):
                runner.run("silent_error", [sys.executable, "-c", "print('SCRIPT ERROR: invalid state')"])
            self.assertEqual(runner.results[0]["status"], "failed")
            self.assertEqual(runner.results[0]["exit_code"], 0)

    def test_timeout_terminates_process_and_retains_log(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = verification.Runner("unused", Path(directory), Path(directory), 0.4)
            with redirect_stdout(io.StringIO()):
                runner.run("hang", [sys.executable, "-u", "-c", "import time; print('started'); time.sleep(30)"])
            self.assertEqual(runner.results[0]["status"], "timeout")
            self.assertIn("started", Path(runner.results[0]["log"]).read_text())


if __name__ == "__main__":
    unittest.main()

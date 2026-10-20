"""Run offline checks in an isolated project; standard library, Python 3.10+."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import time
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
DEMO = {"test_rules", "test_data_pack", "test_model_cache",
        "test_forceorg_catalog", "test_forceorg_catalog_download", "test_model_download", "test_network", "test_army_catalog", "test_army_builder"}
VARIANTS = {"test_attack_plan_network": ["--ranged-test"],
            "test_saved_armies_network": ["--budget-mismatch-test", "--stratagem-test", "--movement-rerolls-test", "--attack-rerolls-test", "--save-rerolls-test", "--damage-rerolls-test", "--hazard-rerolls-test", "--count-rerolls-test", "--escape-rerolls-test"],
            "test_movement_rerolls_network": ["--advance-test"],
            "test_attack_rerolls_network": ["--wound-test", "--save-test", "--damage-test", "--hazard-test", "--count-test"],
            "test_damage_allocation_network": ["--melee-test"],
            "test_equipment_network": ["--melee-test", "--vehicle-test"],
            "test_weapon_selection_network": ["--allocation-test", "--random-test"]}
ERROR = re.compile(r"SCRIPT ERROR:|(?:^|\n)ERROR:|(?:^|\n)FAIL(?:\s|:)|\b[1-9]\d* failures\b")


def failed(code, output):
    output = re.sub(r"\x1b\[[0-9;]*m", "", output)
    return code != 0 or bool(ERROR.search(output))


def stage(destination, profile):
    project = destination / "project"
    project.mkdir()
    shutil.copy2(ROOT / "project.godot", project)
    if (ROOT / "export_presets.cfg").is_file():
        shutil.copy2(ROOT / "export_presets.cfg", project)
    for name in ("scripts", "scenes", "tests", "tools"):
        shutil.copytree(ROOT / name, project / name, ignore=shutil.ignore_patterns("__pycache__"))
    shutil.copytree(ROOT / "data/packs", project / "data/packs")
    if profile == "full":
        source = ROOT / "data/imported/starter-11e-v1"
        lock = json.loads((ROOT / "data/starter.lock.json").read_text(encoding="utf-8"))
        for faction in ("adeptus-astartes", "necrons"):
            if not (source / faction / "manifest.json").is_file():
                raise ValueError("Full checks require data/imported/starter-11e-v1; see docs/verification/verification.md")
            manifest = json.loads((source / faction / "manifest.json").read_text(encoding="utf-8"))
            digest = hashlib.sha256((source / faction / "units.json").read_bytes()).hexdigest()
            if digest != lock["units_sha256"][faction] or manifest["units_sha256"] != digest or manifest["source"]["revision"] != lock["revision"]:
                raise ValueError("Starter data differs from lock; run tools/prepare_starter.py --check")
        shutil.copytree(source, project / "data/imported/starter-11e-v1")
    (project / ".tools").mkdir()
    return project


class Runner:
    def __init__(self, engine, project, directory, timeout):
        self.engine, self.project, self.directory, self.timeout = engine, project, directory, timeout
        self.results = []

    def start(self, label, command):
        profile = self.directory / "profiles" / label
        profile.mkdir(parents=True)
        env = os.environ.copy()
        # Godot resolves user:// via APPDATA on Windows and XDG_DATA_HOME on Linux.
        env.update(APPDATA=str(profile), XDG_DATA_HOME=str(profile),
                   TMP=str(profile), TEMP=str(profile), TMPDIR=str(profile))
        log = self.directory / (label + ".log")
        stream = log.open("w", encoding="utf-8")
        try:
            process = subprocess.Popen(command, cwd=self.project, env=env,
                                       stdout=stream, stderr=subprocess.STDOUT)
        except BaseException:
            stream.close()
            raise
        return process, stream, log, time.monotonic()

    def finish(self, label, job):
        process, stream, log, started = job
        expired = False
        try:
            process.wait(timeout=max(0.01, self.timeout - (time.monotonic() - started)))
        except subprocess.TimeoutExpired:
            expired = True
            process.kill()
            process.wait()
        finally:
            stream.close()
        output = log.read_text(encoding="utf-8", errors="replace")
        status = "timeout" if expired else "failed" if failed(process.returncode, output) else "passed"
        result = dict(name=label, status=status, exit_code=process.returncode,
                      seconds=round(time.monotonic() - started, 2), log=str(log))
        self.results.append(result)
        print(f"{status.upper():7} {label}", flush=True)
        if status != "passed":
            print(output[-3500:], flush=True)

    def command(self, label, script=None, flags=()):
        command = [self.engine, "--headless", "--path", str(self.project),
                   "--log-file", str(self.directory / (label + ".engine.log"))]
        if script:
            command += ["--script", "tests/" + script + ".gd"]
        else:
            command += ["--quit-after", "5"]
        if flags:
            command += ["--", *flags]
        return command

    def run(self, label, command):
        self.finish(label, self.start(label, command))

    def network(self, script, extra=()):
        label = script + ("_" + extra[0].removeprefix("--") if extra else "")
        host = self.start(label + "_host", self.command(label + "_host", script, ("--host-test", *extra)))
        client = None
        try:
            time.sleep(0.7)
            client = self.start(label + "_client", self.command(label + "_client", script, ("--client-test", *extra)))
            self.finish(label + "_host", host)
            self.finish(label + "_client", client)
        finally:
            for job in (host, client):
                if job and job[0].poll() is None:
                    job[0].kill()
                    job[0].wait()
                if job:
                    job[1].close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT", "godot"))
    parser.add_argument("--profile", choices=("demo", "full"), default="demo")
    parser.add_argument("--network", action="store_true", help="Run sequential host/client loopback pairs")
    parser.add_argument("--only", action="append", help="Exact Godot test stem; repeat to select several")
    parser.add_argument("--timeout", type=float, default=45, help="Seconds per process")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    engine = shutil.which(args.godot)
    if not engine:
        parser.error("Godot not found; pass --godot /path/to/godot")
    suites = sorted(path.stem for path in (ROOT / "tests").glob("test_*.gd"))
    if args.only and set(args.only) - set(suites):
        parser.error("Unknown suite: " + ", ".join(sorted(set(args.only) - set(suites))))
    if args.only and args.profile == "demo" and set(args.only) - DEMO:
        parser.error("Selected suite requires --profile full")
    if args.only and not args.network and any(name == "test_network" or name.endswith("_network") for name in args.only):
        parser.error("Selected network suite requires --network")
    directory = ROOT / ".tools/verification" / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    directory.mkdir(parents=True)
    print("Report directory:", directory, flush=True)
    network_lock = None
    try:
        if args.network:
            network_lock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            if hasattr(socket, "SO_EXCLUSIVEADDRUSE"):
                network_lock.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)
            try:
                network_lock.bind(("127.0.0.1", 24561))
            except OSError as error:
                raise ValueError("Another network verification may be running (TCP guard port 24561 is busy). Run suites sequentially.") from error
        project = stage(directory, args.profile)
        runner = Runner(str(Path(engine).resolve()), project, directory, args.timeout)
        # Import in isolation first so fresh checkouts resolve resources/UIDs.
        runner.timeout = max(120, args.timeout)
        runner.run("import", [runner.engine, "--headless", "--path", str(project),
                              "--log-file", str(directory / "import.engine.log"), "--editor", "--import"])
        runner.timeout = args.timeout
        if runner.results[-1]["status"] == "passed":
            runner.run("python", [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py"])
            runner.run("startup", runner.command("startup"))
            for suite in suites:
                if args.only and suite not in args.only:
                    continue
                if args.profile == "demo" and suite not in DEMO:
                    continue
                if suite == "test_network" or suite.endswith("_network"):
                    if args.network:
                        runner.network(suite)
                        for variant in VARIANTS.get(suite, []):
                            runner.network(suite, (variant,))
                else:
                    runner.run(suite, runner.command(suite, suite))
        report = dict(profile=args.profile, network=args.network, results=runner.results)
        (directory / "results.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
        passed = all(result["status"] == "passed" for result in runner.results)
        print(f"{len(runner.results)} processes; {'PASS' if passed else 'FAIL'}; {directory / 'results.json'}")
        return 0 if passed else 1
    except (OSError, ValueError) as error:
        print(f"Verification could not run: {error}", file=sys.stderr)
        return 2
    finally:
        if network_lock is not None:
            network_lock.close()


if __name__ == "__main__":
    sys.exit(main())

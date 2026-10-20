# Reproducible verification and demo builds

Requirements: Python 3.10+ and the standard Godot 4.7.2 editor/console executable. Python tools use only the standard library. The game itself does not need Python.

## Offline baseline

From the repository root:

```text
python tools/verify.py --godot /path/to/godot --profile demo --network
```

On Windows, pass the console executable, e.g. `--godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Alternatively set `GODOT` or put `godot` on PATH.

The demo profile needs no external data, assets, model library or network downloads. `--network` runs a local host/client pair; without it, loopback tests are omitted. The runner imports resources, runs Python tests, checks main-scene startup, and runs the selected Godot suites. The CI definition in `.github/workflows/verify.yml` runs this baseline on Windows and Linux. It must actually run remotely before being reported as passing there.

The army catalog/profile suites also belong to the demo profile. They use synthetic data and an offline fake transport; no public API is queried during these suites. Live API/catalog and graphical checks are separate evidence recorded in [results](verification-results.md).

Each run copies the required project files into a new `.tools/verification/<timestamp>/project` directory. Godot user data and Python temporary files are redirected to separate profiles inside that run. The player's normal model mappings/download folder are never used. Logs, engine logs and machine-readable `results.json` remain in the run directory. A test process times out after 45 seconds by default; override with `--timeout`. Initial resource import gets at least 120 seconds. Nonzero exits and Godot script/runtime errors fail the run even when Godot returns zero.

Network suites and their variants run sequentially because they use UDP 24560. The runner reserves TCP 24561 as a guard against concurrent runner invocations; it does not provide a game service. Do not launch manual network tests at the same time.

## Legacy optional combat snapshot (not the authoritative source)

The current full test profile still consumes the old 40kdc-data starter snapshot pinned by `data/starter.lock.json`. This is retained only for compatibility and historical exercise tests; it is **not** a Wahapedia export, must not be used to validate current datasheet facts, and is not a fallback for a missing local export. The Wahapedia ingestion migration remains pending.

```text
python tools/prepare_starter.py
python tools/prepare_starter.py --check
python tools/verify.py --godot /path/to/godot --profile full --network
```

The first command explicitly retrieves the legacy community snapshot pinned in `data/starter.lock.json`, validates both faction hashes and installs it under ignored `data/imported/starter-11e-v1`. Existing directories are verified rather than overwritten. `--check` is offline. A different/corrupt snapshot is rejected; preserve it separately before preparing another snapshot. Passing the hash check verifies only this historical test input, not authoritative provenance, current rules, or complete playable faction content.

The full runner verifies the pinned snapshot before copying it. It discovers local Godot suites and host/client pairs, including ranged/melee, vehicle, manual-allocation and random-attack variants. Narrow a reproduction with repeated exact stems:

```text
python tools/verify.py --godot /path/to/godot --profile full --network --only test_mixed_defenders_network --only test_tactical_guides
```

Logs and copied projects are retained for diagnosis, so repeated runs consume disk space. They are ignored by Git. No cleanup of previous runs happens automatically.

## Export the original demo

```text
python tools/build_demo.py --godot /path/to/godot
python tools/build_demo.py --godot /path/to/godot --target windows
python tools/build_demo.py --godot /path/to/godot --target linux
```

The default produces a `.pck` and starts it headlessly through the supplied engine. Native targets require matching Godot 4.7.2 export templates installed on the build machine. The helper resolves the standard template location before isolating the build profile; use `--templates /path/to/templates` for a local extracted template directory. Presets use GL compatibility and include the original demo JSON; external starter data, models, test fixtures, tools and documentation are excluded. The helper builds from an isolated demo project, so ignored local downloads cannot enter the artifact accidentally.

Artifacts and build reports remain under `.tools/verification/build-<timestamp>/`. The exported demo supports the original movement/LAN exercise; combat needs optional imported data and is not bundled in this artifact. A headless PCK launch is not validation of native Windows/Linux binaries, graphical interaction or a production release.

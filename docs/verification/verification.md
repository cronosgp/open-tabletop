# Reproducible verification and demo builds

Requirements: Python 3.10+ and the standard Godot 4.7.2 editor/console executable. Python tools use only the standard library. The game itself does not need Python.

## Offline baseline

From the repository root:

```text
python tools/verify.py --godot /path/to/godot --profile demo --network --timeout 300
```

On Windows, pass the console executable, e.g. `--godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Alternatively set `GODOT` or put `godot` on PATH.

The demo profile needs no external data, assets, model library or network downloads. `--network` runs a local host/client pair; without it, loopback tests are omitted. The runner imports resources, runs Python tests, checks main-scene startup, and runs the selected Godot suites. The CI definition in `.github/workflows/verify.yml` runs this baseline on Windows and Linux with a 300-second per-process budget to accommodate clean-run resource import and export latency. It must actually run remotely before being reported as passing there.

The builder suite is part of this data-free baseline: it injects a synthetic catalog and only checks the optional historical training roster through code paths that are not invoked by the regression. The verifier therefore does not stage `data/imported/starter-11e-v1` for `test_army_builder`; suites that actually consume that pinned legacy snapshot remain targeted/full-profile checks.

To see the exact Godot suite names without installing or locating Godot, run `python tools/verify.py --list-suites`. Each run's `results.json` records the profile, selected suites, resolved Godot executable, timeout, network setting and UTC start time alongside per-process results.

For fast iteration, use the focused profile with one or more exact suite names. It stages the same isolated, data-free project but skips the broad Python suite and main-scene startup check:

```text
python tools/verify.py --godot /path/to/godot --profile focused --only test_phase_progression
python tools/verify.py --godot /path/to/godot --profile focused --network --only test_prepared_match_network
```

The focused profile requires `--only` so it cannot accidentally look like a full project verification. It runs the static architecture dependency checks and verification-runner unit tests, but skips the broader Python suite and main-scene startup check. A selected network suite requires `--network` and runs with the same sequential host/client isolation as other profiles. The runner walks each selected test's preloaded GDScript dependencies and rejects suites that reference the legacy starter snapshot before launching Godot; use the targeted or full profile for those suites.

For a data-backed local rules regression, use the targeted profile. It verifies and stages the pinned legacy snapshot when a selected suite depends on it; independent suites run without that local snapshot. It runs only the requested Godot suites plus the fast architecture and runner tests:

```text
python tools/verify.py --godot /path/to/godot --profile targeted --only test_combat_doctrines
```

The targeted profile skips broad Python discovery and main-scene startup. Its `results.json` records whether the legacy starter snapshot was staged. The current-catalog Marine local and network match suites use the source-backed current-template path and run without staging that snapshot; other dependency-matched suites may still require it for historical training exercises. This profile is a faster regression check, not a replacement for the full profile or evidence of current rules accuracy. Network suites still require `--network`, and loopback remains distinct from separate-machine validation.

The army catalog/profile suites also belong to the demo profile. They use synthetic data and an offline fake transport; no public API is queried during these suites. Live API/catalog and graphical checks are separate evidence recorded in [results](verification-results.md).

The distinct tactical-training formations have their own current-catalog checks, independent of the historical starter:

```text
python tools/verify.py --godot /path/to/godot --profile focused --only test_tactical_combat_flow --only test_tactical_training --timeout 300
```

The combat suite reaches plasma and Charge/Fight through public setup, deployment and movement. Its standard/supercharged branches use controlled test-only dice at the same serialized shooting checkpoint. The UI/lifecycle suite covers the actual initial action, side swapping, paid Gladius use, pending save/recovery and five-round completion. See [scenario boundaries and evidence](../guides/tactical-training.md).

Each run copies the required project files into a new `.tools/verification/<timestamp>/project` directory. Godot user data and Python temporary files are redirected to separate profiles inside that run. The player's normal model mappings/download folder are never used. Logs, engine logs and machine-readable `results.json` remain in the run directory. A test process times out after 45 seconds by default; override with `--timeout`. Initial resource import gets at least 120 seconds. Nonzero exits and Godot script/runtime errors fail the run even when Godot returns zero. Godot 4.7.2's headless dummy renderer emits `RID allocations ... were leaked at exit` diagnostics on both normal project startup and UI-heavy test shutdown; the runner keeps those lines in the raw logs and sets `headless_rid_cleanup_diagnostics` in `results.json`, but does not treat those exact shutdown-only lines as runtime failures. Other engine errors remain fatal.

Network suites and their variants run sequentially because they use UDP 24560. The runner reserves TCP 24561 as a guard against concurrent runner invocations; it does not provide a game service. Do not launch manual network tests at the same time.

The focused current-reference loopback lifecycle includes recovery during the pending Fire Overwatch decision. The clean run at `.tools/verification/20261023T225711261053Z/results.json` passed import/Python and all four host/client processes; the 550-point mirror finished at revision 135 with score 5–0 and the tactical profile at revision 139 with score 0–0, with matching canonical hashes within each pair. The client wait now accepts the authoritative resolved attack when the Shooting snapshot and attack arrive in one frame. The runtime profile also reduced repeated movement-window UI work by about 57% on a 40-model checkpoint. Run it with a longer per-process timeout and retain both role logs:

```text
python tools/verify.py --godot /path/to/Godot_v4.7.2-stable_win64_console.exe --profile focused --network --only test_current_reference_match_network --timeout 300
```

### Deferred: cross-machine bounded-match exercise

Separate-machine LAN validation is a final-integration gate, distinct from loopback. `test_current_reference_match_network.gd` can run on two computers. Use the same working-tree revision and Godot 4.7.2 build on both machines. On the host, run:

```text
godot --headless --path . --script tests/test_current_reference_match_network.gd -- --host-test --cross-machine-test
```

On the guest, replace `<host-lan-ip>` with the host's LAN IPv4 address:

```text
godot --headless --path . --script tests/test_current_reference_match_network.gd -- --client-test --cross-machine-test --host-address=<host-lan-ip>
```

Add `--tactical-profile-test` to both role commands for Fire and Manoeuvre versus Close Assault; omitting it exercises the former mirror. The focused runner command above executes both variants sequentially. The test-only checkpoint node exchanges and compares complete snapshots before releasing deployment recovery, pending Fire Overwatch recovery and match completion; it does not change gameplay state. Both role logs also print `FINAL STATE SHA-256 (canonical)`, with dictionary keys ordered deterministically while preserving scalar types and array order. Retain both logs and any `.tools/checkpoint-*.state` diagnostics produced on mismatch. These checks do not establish unexercised rules or player comprehension. Neither these commands nor the tactical presets require shared storage, raw export transfer or content downloads. The cross-machine command flag remains accepted for compatibility; it is not itself evidence that the processes ran on different computers.

Allow UDP port 24560 between the two computers. The exercise admits the mirrored 550-point training lists, completes setup and deployment, saves, disconnects and reclaims the guest seat during deployment and during a pending Fire Overwatch decision, synchronizes a legal ranged attack, plays the bounded five-round match, and verifies the host's completed save and journal. Each process prints a role-specific `CURRENT-REFERENCE HOST: PASS` or `CURRENT-REFERENCE CLIENT: PASS` line. A successful loopback run is not evidence for this cross-machine gate; record both machines, Godot version, LAN path, role outputs and result before updating the support matrix.

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

## Export the project demo

```text
python tools/build_demo.py --godot /path/to/godot
python tools/build_demo.py --godot /path/to/godot --target windows
python tools/build_demo.py --godot /path/to/godot --target linux
```

The default produces a `.pck` and starts it headlessly through the supplied engine. Each process allows 300 seconds by default; use `--timeout` to change that when import/export latency differs. Native targets require matching Godot 4.7.2 export templates installed on the build machine. The helper resolves the standard template location before isolating the build profile; use `--templates /path/to/templates` for a local extracted template directory. Presets use GL compatibility and include the project-owned demo JSON plus the current-reference tactical runtime; external starter data, models, test fixtures, tools and documentation are excluded. The helper builds from an isolated demo project, so ignored local downloads cannot enter the artifact accidentally.

The latest local pack build on 24 October 2026 (UTC report timestamp 20261024T080456779917Z) passed `import`, `tactical-smoke`, `export`, `exported-startup` and `tactical-pack-smoke`, producing `.tools/verification/build-20261024T080456779917Z/open-tabletop-demo.pck` with `--timeout 300`. The tactical smoke starts the current-reference Fire and Manoeuvre versus Close Assault scenario from the clean staged tree and from the exported pack, verifies the title/guide surface and confirms no false opportunity cue during preparation, without the historical starter snapshot. Two earlier 120-second attempts reached the Godot export save-pack stage but timed out; they did not report script or export errors. The Windows and Linux native attempts were stopped before export because `windows_release_x86_64.exe` and `linux_release.x86_64` were absent from the Godot 4.7.2 template directory; neither native target is reported as passed until matching templates are installed or supplied with `--templates`.

Artifacts and build reports remain under `.tools/verification/build-<timestamp>/`. The exported demo supports the original movement/LAN exercise and the project-owned tactical training profile; it excludes the historical starter snapshot, third-party data, tests, tools and documentation. A headless PCK launch is not validation of native Windows/Linux binaries, graphical interaction, human comprehension or a production release.

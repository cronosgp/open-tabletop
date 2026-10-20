# Open Tabletop

[![CI](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml/badge.svg)](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Godot 4.7.2](https://img.shields.io/badge/Godot-4.7.2-478cbf)](https://godotengine.org)

An open-source Godot prototype for playing Warhammer 40,000 with user-supplied visuals. The rules target is the **official 11th edition**. The project is still a prototype: a checked match profile and several restricted exercises are implemented, not every faction, army list, rule, or mission.

**Start here:** [current support and limitations](docs/project/support-matrix.md) · [roadmap](docs/project/roadmap.md) · [contributing](CONTRIBUTING.md) · [documentation index](docs/README.md)

## Run from a clean checkout

1. Install **Godot 4.7.2 stable, standard edition (no .NET)**.
2. Import `project.godot` in Godot and press **F5**.

The original movement demonstration starts without Python, external data, model downloads, or network access. In the local demo, select a miniature's base with the left mouse button and request a move with the right button. Scroll to zoom, middle-drag to orbit, and use WASD to pan. **Host LAN** and **Join** support direct LAN/loopback connections; this is not internet matchmaking.

Combat exercises are separate from the clean-checkout demo. Their exact data requirements and rule boundaries are listed in the [support matrix](docs/project/support-matrix.md) and the [documentation index](docs/README.md). An exercise or selectable profile does not by itself certify a legal army or a complete official match.

## Rules and datasheet sources

The project targets official **11th-edition** rules. The required local reference for datasheet data is an export obtained from [Wahapedia's 11th-edition data export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/). Keep raw exports local and ignored by Git under the proposed structure:

```text
.tools/wahapedia/11e/<faction>/<snapshot-id>/
```

Record the export URL, edition, retrieval date, snapshot identity, filenames, and SHA-256 hashes alongside each local snapshot. Do not commit or redistribute extracted third-party content. For rule effects, Codex updates, errata, and version boundaries, also cross-check current official Games Workshop publications and record any discrepancy. See [agent instructions](AGENTS.md) and the [source policy](docs/data/source-assessment.md).

**Pipeline status:** this checkout does not yet contain a Wahapedia-export ingestion tool or local snapshot. Existing OpenHammer/40kdc adapters and starter packs are legacy/experimental inputs, not authoritative sources for current datasheet facts or evidence of rules support. Do not fall back to those providers when the required local export is absent; the ingestion migration is separate work.

## Verify changes

Requirements for project checks: Python 3.10+ and Godot 4.7.2. Python is not needed to launch the clean-checkout movement demo.

```text
python tools/verify.py --godot /path/to/godot --profile demo --network
python tools/verify.py --godot /path/to/godot --profile full --network
python tools/build_demo.py --godot /path/to/godot
```

The demo profile uses synthetic/offline fixtures and local loopback only. The current full profile still depends on the legacy pinned starter snapshot; it is not a Wahapedia data-source check or a rules-certification result. See [verification instructions](docs/verification/verification.md) for Windows executable paths, test isolation, timeouts, and limitations; see [latest recorded results](docs/verification/verification-results.md) for evidence and platform boundaries.

## Project map

- `scripts/edition_11/` — rules and match logic, separated from rendering where implemented.
- `scripts/main.gd` — current main scene, UI, board presentation, and network integration; gradual separation is on the [roadmap](docs/project/roadmap.md).
- `tests/` — Godot headless suites and Python tool tests.
- `tools/` — verification/build helpers and legacy data importers.
- `data/` — project-owned demo data and schema/lock files; imported third-party content is not committed.
- `docs/` — categorized guides, rule boundaries, data policy, architecture, project status, and verification. Start at [docs/README.md](docs/README.md).

## Contributing and content

Read [CONTRIBUTING.md](CONTRIBUTING.md) before changing code or rules. In particular, keep current e11 behavior separate from historical training profiles, use the local Wahapedia export as the only datasheet-data source, and do not describe partial tests as full rules or army legality certification.

The [MIT License](LICENSE) applies to the project's code and original demo content only. Warhammer 40,000 names and marks, extracted community data, and user-supplied visuals remain under their respective owners' terms; downloads do not grant redistribution rights. Third-party content is not bundled or sent to the other player.

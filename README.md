# Open Tabletop

[![CI](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml/badge.svg)](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Godot 4.7.2](https://img.shields.io/badge/Godot-4.7.2-478cbf)](https://godotengine.org)

An open-source Godot prototype for playing Warhammer 40,000 with user-supplied visuals. The rules target is the **official 11th edition**. The project is still a prototype: a checked match profile and several restricted exercises are implemented, not every faction, army list, rule, or mission.

**Start here:** [current support and limitations](docs/project/support-matrix.md) · [roadmap](docs/project/roadmap.md) · [contributing](CONTRIBUTING.md) · [documentation index](docs/README.md)

## Run from a clean checkout

1. Install **Godot 4.7.2 stable, standard edition (no .NET)**.
2. Import `project.godot` in Godot and press **F5**.

On first launch, an optional setup asks for a local `ForceOrg.json` model catalog. Choosing **Continue without models** keeps automatic model downloads off; add the catalog later from Army & Models or enable downloads in New match settings. Compatible miniature files download after a local match's armies are selected, or after you explicitly choose **Prepare all 161 models** in **Training Tools** to open the visual catalog table. The original movement demonstration needs no Python, external data or model downloads. In the local demo, select a miniature's base with the left mouse button and request a move with the right button. Scroll to zoom, middle-drag to orbit, and use W/A/S/D by default to pan; remap camera pan, Focus and Datasheet keys in Settings. **Host LAN** and **Join** support direct LAN/loopback connections; this is not internet matchmaking.

The project-owned tactical training profile also starts offline from the current-reference Marine catalog embedded in the runtime; it does not require the historical starter snapshot or a download. Other combat exercises remain separate, and their exact data requirements and rule boundaries are listed in the [support matrix](docs/project/support-matrix.md) and the [documentation index](docs/README.md). An exercise or selectable profile does not by itself certify a legal army or a complete official match.

**Start tactical training** offers two distinct local Marine forces with current abilities, Gladius/Core stratagems and optional tips. Review its [configuration and validation limits](docs/guides/tactical-training.md); the original mirror remains selectable.

## Rules and datasheet sources

The project targets **Warhammer 40,000 11th edition**. Wahapedia's `/wh40k11ed/` Core Rules and faction pages are the project's definitive rules reference. Datasheet facts come from the corresponding local export snapshot:

```text
.tools/wahapedia/11e/<faction>/<snapshot-id>/
```

Record the export URL, edition, retrieval date, snapshot identity, filenames, and SHA-256 hashes alongside each local snapshot. Do not commit or redistribute extracted third-party content. Official Games Workshop material may be used as context, but is not an admission prerequisite and does not override the selected Wahapedia rules. See [agent instructions](AGENTS.md) and the [source policy](docs/data/source-assessment.md).

**Catalog status:** the local construction catalog contains 161 standard Space Marine profiles (159 complete local scopes; two partial: Crusader Squad and Wolf Guard Headtakers) and 24 separately labelled Warhammer Legends profiles (185 Marine profiles total), plus 28 admitted Necron App v1.2 profiles — 213 admitted profiles across both factions, with 120 reviewed saved-equipment schemas and 93 fixed-equipment profiles. Key boundaries: Wahapedia/MFM points differ on Decimus (10-model/210 vs 190) and Crusader Squad (160/305 vs 150/290); Headtakers' two MFM-priced mixed formations are admitted while other mixes and exact wolf-base geometry remain unresolved; vehicle/bunker 60 mm and 120 mm footprints are interaction proxies; Legends units need event approval; and catalog admission does not certify full army legality. See [Space Marines coverage](docs/space-marines-coverage.md), [Space Marine extended & Legends inventory](docs/data/space-marine-extended-inventory.md), [Necrons coverage](docs/data/necrons-coverage.md), [Army Builder coverage](docs/project/army-builder-coverage.md), and the [documentation index](docs/README.md).

## Verify changes

Requirements for project checks: Python 3.10+ and Godot 4.7.2. Python is not needed to launch the clean-checkout movement demo.

```text
python tools/verify.py --godot /path/to/godot --profile demo --network --timeout 300
python tools/verify.py --godot /path/to/godot --profile full --network --timeout 300
python tools/build_demo.py --godot /path/to/godot --timeout 300
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

Dataslate title-menu icons are by Lorc from [game-icons.net](https://game-icons.net/) under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/). See [icon attribution](assets/ui/icons/dataslate/ATTRIBUTION.md).

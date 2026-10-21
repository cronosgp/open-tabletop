# Contributing to Open Tabletop

Thanks for helping improve the project. Read this guide and the repository [agent instructions](AGENTS.md) before changing code, rules, or data.

## Requirements and clean start

- **Godot 4.7.2 stable**, standard edition, no .NET.
- **Python 3.10+** for repository verification/build tools; the game itself does not need Python.

Import `project.godot` in Godot and press **F5**. A clean checkout opens the original movement demo without external data or downloads.

## Rules and data changes

- The target is **Warhammer 40,000 11th edition** as represented by the selected Wahapedia `/wh40k11ed/` Core Rules, faction pages, and Data Export. Record the edition, source book/chapter, game mode, and current revision for each implementation scope.
- Datasheet facts use only a verified **local Wahapedia 11e data export** as the project's source of record. See [source policy](docs/data/source-assessment.md) for the local snapshot layout and current pipeline status. Do not replace a missing extract with OpenHammer, 40kdc, another provider, or an older rules profile.
- Games Workshop publications may be recorded as context, but they are not an admission prerequisite and do not override the selected Wahapedia reference. Record ambiguities and keep unsupported scope blocked.
- Keep third-party source exports local and out of commits/builds. Existing starter importers are legacy/experimental, not the current authoritative data pipeline.
- Keep unsupported rules visible and gated. A catalog entry, passing test, or selectable unit is not proof of complete rules support or legal army construction.
- Rules changes should have focused headless tests. Keep the support matrix, capability metadata, roadmap, and feature documentation consistent with the actual scope.

## Verify and build

```text
python tools/verify.py --godot /path/to/godot --profile demo --network
python tools/verify.py --godot /path/to/godot --profile full --network
python tools/build_demo.py --godot /path/to/godot
```

Use the Godot console executable on Windows when needed. The demo profile is the offline baseline apart from loopback networking. The full profile currently requires a legacy pinned starter snapshot and does not validate the Wahapedia ingestion policy. Use the full [verification guide](docs/verification/verification.md) for exact requirements, test selection, isolation, and known limitations; report only commands actually run and results actually observed.

## Project layout and conventions

- `scripts/edition_11/` — rules/match modules.
- `scripts/main.gd` — main-scene UI, board presentation, and network integration.
- `tests/` — Godot headless tests and Python tests.
- `tools/` — verification/build helpers and existing legacy importers.
- `data/` — project-owned demo data and pack schemas; imported third-party content is ignored.
- `docs/` — topic docs organized by category; add new docs to the [index](docs/README.md).

Follow the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) (tabs, `snake_case`) and [PEP 8](https://peps.python.org/pep-0008/) for Python. Use the existing test framework and helpers. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (for example `feat:`, `fix:`, `docs:`, `test:`).

## Content and licensing

- Do not commit or distribute Wahapedia exports, community catalogs, downloaded miniature meshes/textures, or rulebook PDFs. Downloads and local availability do not grant redistribution rights.
- Warhammer 40,000 names and marks belong to Games Workshop. The MIT license covers this project's code and original demo content only; it does not relicense imported or user-provided content.
- User-supplied visuals remain local and are not transferred to peers.

## Reporting issues

Use the [bug report](https://github.com/cronosgp/open-tabletop/issues/new?template=bug_report.yml) or [feature request](https://github.com/cronosgp/open-tabletop/issues/new?template=feature_request.yml) templates. For security issues, see [SECURITY.md](SECURITY.md).

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).

# Contributing to Open Tabletop

Thanks for your interest in contributing. Open Tabletop is a two-player Warhammer 40,000 (10th edition) tabletop prototype built in Godot. Contributions are welcome — please read this guide before opening a pull request.

## Getting started

- Godot **4.7.2 stable**, standard edition, no .NET. Older or newer versions may not open the project cleanly.
- Python **3.10+** (standard library only) for the preparation and verification tools.

### Run the project

Import `project.godot` in the Godot editor and press **F5**. A clean checkout opens the original movement demo without external data or downloads.

### Optional starter data (combat exercises)

```text
python tools/prepare_starter.py
```

This downloads the community snapshot pinned by revision and hashes in `data/starter.lock.json`. Optional data stays in the git-ignored `data/imported/` directory and is never committed.

## Running the tests

```text
python tools/verify.py --profile demo --network
python tools/verify.py --profile full --network
python tools/build_demo.py
```

- `--profile demo` is offline except for local loopback; `full` requires the pinned starter snapshot.
- Individual suites can be run directly, e.g. `godot --headless --path . --script tests/test_individual_movement.gd`.
- CI runs the same commands on both Windows and Ubuntu via [`.github/workflows/verify.yml`](.github/workflows/verify.yml).

Full instructions: [`docs/verification.md`](docs/verification.md).

## Project layout

- `scripts/edition_11/` — rules modules that validate commands independently of rendering.
- `scripts/main.gd` — board presentation, UI and ENet session handling (gradual separation is on the [roadmap](docs/roadmap.md)).
- `tests/` — headless Godot suites and Python tests.
- `tools/` — preparation, verification and export scripts.
- `docs/` — support matrix, roadmap and per-feature notes.

## Code style

- Follow the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) (tabs for indentation, `snake_case` for functions and variables).
- Python follows [PEP 8](https://peps.python.org/pep-0008/) and uses only the standard library.
- Rules logic must stay independent of rendering and be covered by a headless test.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g. `feat:`, `fix:`, `docs:`, `test:`).

## Content boundary (important)

- Do **not** commit third-party assets: no community catalogs, no downloaded model meshes/textures, no rulebook PDFs. These stay in git-ignored locations (`data/imported/`, `.tools/`) or the user's local folders.
- Warhammer 40,000 and related names/marks are property of Games Workshop. This project does not redistribute their content.
- The MIT license applies to the project's own code and original demo content only, not to imported or user-supplied material.

## Reporting issues

Use the [bug report](https://github.com/cronosgp/open-tabletop/issues/new?template=bug_report.yml) or [feature request](https://github.com/cronosgp/open-tabletop/issues/new?template=feature_request.yml) templates. For security issues, see [SECURITY.md](SECURITY.md).

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

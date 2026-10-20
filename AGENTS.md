# Instructions for coding agents

## Start with the project state

- Read [README.md](README.md), [the documentation index](docs/README.md), and the relevant topic documents before changing behavior.
- Check the [support matrix](docs/project/support-matrix.md), [roadmap](docs/project/roadmap.md), and capability registry before claiming a feature is complete. Keep those sources consistent with actual runtime gates and tests.
- Follow existing Godot, GDScript, Python, and test patterns. Keep rules logic independent of rendering where the architecture supports it; add targeted headless coverage for behavior changes.
- Run the smallest relevant checks and report exact commands and outcomes. A passing test suite does not establish rules accuracy, army legality, or platform coverage.

## Rules and data-source policy

- The target is official **Warhammer 40,000 11th edition**. Confirm the edition, current faction/Codex content, errata, and effective version before implementing or marking a rule supported.
- Datasheet facts must come from the local export obtained through [Wahapedia's 11e data-export page](https://wahapedia.ru/wh40k11ed/the-rules/data-export/). The proposed local-only location is `.tools/wahapedia/11e/<faction>/<snapshot-id>/`; identify the snapshot and verify its recorded SHA-256 hashes. If the export is absent or the record cannot be verified, stop datasheet certification rather than substituting OpenHammer, 40kdc, memory, or an older pack.
- The local Wahapedia export is the project's authoritative datasheet-data reference; it is not an official Games Workshop publication. Cross-check rules effects, FAQs/errata, and current publication boundaries against official Games Workshop sources. Record disagreements, source dates/versions, and unresolved questions.
- Keep raw exports and derived third-party data out of Git and distribution. Do not treat `data/imported/`, existing 40kdc locks, or legacy OpenHammer adapters as current authoritative inputs. The ingestion migration is not yet implemented in this checkout.
- Never silently combine 10th-edition, superseded Codex, historical training, or provisional mechanics with current e11 rules. Isolate historical profiles and state their limits.
- Preserve unsupported rules as explicit blockers/errors; do not silently drop an ability or make a selectable profile imply complete support.

## Documentation and project organization

- Keep the root README as a short project entry point, not a changelog or full feature catalogue. Add or update topic documentation in the relevant `docs/` category and add it to [the docs index](docs/README.md).
- Keep machine-readable capability metadata, support claims, roadmap, and verification reports aligned. Distinguish implemented, tested, source-checked, and certified scope.
- The project-owned demo is the clean-checkout baseline. Data preparation and optional exercises must clearly state dependencies and never silently download third-party content.

## Interface work

- For game UI, menus, HUD, onboarding, and player feedback, use `docs/skills/design-first-ui-prompting/SKILL.md` together with the existing `online-game-design` skill. Adapt web-oriented examples to Godot; do not add browser, Three.js, or unrelated web dependencies.
- For visible UI changes, use `docs/skills/workflow-progress-screenshots/SKILL.md` where an actual Godot capture can be made. Label captures and limitations accurately; do not present mockups as in-game results.
- Use `docs/skills/workflow-score-to-target/SKILL.md` when asked for a numeric quality target. Scores require visible evidence and an explicit rubric.
- Keep game state legible and preserve rules boundaries. A clear interface does not mean an action is legal or rules-certified.

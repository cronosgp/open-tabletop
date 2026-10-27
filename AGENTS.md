# Instructions for coding agents

## Current project decisions

- The target is Warhammer 40,000 11th edition. By user decision, Wahapedia's `/wh40k11ed/` rules and faction pages are the definitive rules reference for this project. Use the corresponding local Data Export snapshot for datasheet facts. Games Workshop material may provide context but is not an admission prerequisite and does not override the selected Wahapedia version. See [source assessment](docs/data/source-assessment.md).
- Check the edition, source book/chapter, game mode and current Wahapedia revision before implementing or marking a rule supported. Do not substitute an earlier-edition or superseded Codex mechanic for current e11 behavior or silently combine incompatible versions. Isolate historical training profiles and label their limits.
- Army construction must use only the consolidated local runtime catalog. Do not restore broad API catalog fetching or cached API choices. Keep pending-validation and historical/unreconciled profiles out of new construction choices. Preserve existing lists as labeled legacy drafts. See [construction catalog policy](docs/construction-catalog-policy.md).
- Continue Space Marines with local rules, combat and admission checks. Defer network validation to final integration, and never report deferred checks as passed.
- Keep the roadmap, capability metadata, support matrix and verification claims aligned with runtime gates. A passing test suite does not establish rules accuracy, full army legality or platform coverage.

## Start with the project state

- Read [README.md](README.md), [the documentation index](docs/README.md) and relevant topic documents before changing behavior.
- Check the [support matrix](docs/project/support-matrix.md), [roadmap](docs/project/roadmap.md) and capability registry before claiming a feature is complete.
- Follow existing Godot, GDScript, Python and test patterns. Keep rules logic independent of rendering where the architecture supports it.
- Run the smallest relevant checks and report exact commands and outcomes. Do not add or run tests unless the user asks for verification or the implementation requires a check under the active project workflow.
- The project-owned demo is the clean-checkout baseline. Data preparation and optional exercises must clearly state dependencies and must not silently download third-party content.

## Rules and data-source policy

- Datasheet facts must come from a verified local export obtained through [Wahapedia's 11e Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/). Record the snapshot identity, retrieval date, filenames and SHA-256 hashes. If the export or its provenance cannot be verified, stop datasheet certification instead of substituting OpenHammer, 40kdc, memory or an older pack.
- Keep raw exports and derived third-party data out of Git and distribution. Do not treat legacy imported data or provider adapters as authoritative current inputs.
- Preserve unsupported rules as explicit blockers/errors; do not silently drop abilities or imply that a selectable profile is complete.
- Keep capability metadata, support claims, roadmap and validation reports aligned. Distinguish catalogued, implemented, locally validated, source-checked and certified scope.

## Documentation and project organization

- Keep the root README as a short entry point. Put topic detail in the relevant `docs/` category and add or update its link in [the docs index](docs/README.md).
- Update the support matrix and roadmap when actual runtime scope changes. Do not use documentation alone to claim behavior is implemented.

## Interface work

- For game UI, menus, HUD, onboarding and player feedback, use `docs/skills/design-first-ui-prompting/SKILL.md` together with the `online-game-design` skill. Adapt web-oriented examples to Godot; do not add browser, Three.js or unrelated web dependencies.
- For visible UI changes, use `docs/skills/workflow-progress-screenshots/SKILL.md` where an actual Godot capture can be made. Label captures and limitations accurately; do not present mockups as in-game results.
- Use `docs/skills/workflow-score-to-target/SKILL.md` when asked for a numeric quality target. Scores require visible evidence and an explicit rubric.
- Keep game state legible and preserve rules boundaries. A clear interface does not mean an action is legal or rules-certified.

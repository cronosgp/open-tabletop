# Rules target

- The user requires **Warhammer 40,000 11th-edition rules as published by Wahapedia**. By explicit user decision on 18 October 2026, Wahapedia `/wh40k11ed/` is the definitive rules authority for this project. See `docs/rules-source-policy.md`.
- Always use https://wahapedia.ru/wh40k11ed/the-rules/core-rules/, the corresponding `/wh40k11ed/` faction pages and https://wahapedia.ru/wh40k11ed/the-rules/data-export/. Check edition, book/chapter, game mode and current revision before implementing or marking supported. GW Codex/app/errata cross-checks are optional context, not an admission prerequisite and cannot override the selected Wahapedia rules. Older documentation requiring official locators is superseded by this decision.
- Do not implement an earlier-edition or superseded Codex mechanic as a substitute for current e11 rules, or silently combine incompatible versions. Existing historical training profiles are not current-rule certification; migrate or explicitly isolate them.
- Keep roadmap, capability metadata and validation claims consistent with implemented e11 scope. A passing test suite alone does not establish rules accuracy or full army legality.
- Army construction must use only the consolidated local runtime catalog, per user decision on 18 October 2026; do not restore broad API catalog fetching or cached API choices. Pending-validation and historical/unreconciled profiles stay outside new construction choices. Preserve existing lists as explicitly labeled legacy drafts. See `docs/construction-catalog-policy.md`.

# Validation order

- Validation order requested by the user on 18 October 2026: continue implementing Space Marines with local rules/combat/admission checks; defer network validation to the final integration stage. Deferred network checks must not be reported as passed.

# Visual design workflow

- For game UI, menus, HUD, onboarding, and player feedback, use `docs/skills/design-first-ui-prompting/SKILL.md` together with the existing `online-game-design` skill. Adapt web-oriented examples to Godot and this tabletop game's needs; do not add browser, Three.js, or unrelated web dependencies.
- For visible UI changes, use `docs/skills/workflow-progress-screenshots/SKILL.md` where an actual Godot capture can be made. Label captures and limitations accurately; do not present mockups as in-game results.
- Use `docs/skills/workflow-score-to-target/SKILL.md` when the user asks for a numeric quality target or score. Scores require visible evidence and an explicit rubric; do not invent one on the user's behalf.
- Visual improvements must preserve clear game state and current-edition rules boundaries. Do not imply an action is legal or a result is rules-certified just because the interface presents it clearly.

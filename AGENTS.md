# Rules target

- The user requires **official Warhammer 40,000 11th-edition rules**. Always check edition and current faction/Codex/errata applicability before implementing or marking a rule supported.
- Use https://wahapedia.ru/wh40k11ed/the-rules/core-rules/ and the corresponding `/wh40k11ed/` faction pages as the user's requested reference. Cross-check rule effects and updates against official Games Workshop sources; record discrepancies and source/version boundaries.
- Do not implement an earlier-edition or superseded Codex mechanic as a substitute for current e11 rules, or silently combine incompatible versions. Existing historical training profiles are not current-rule certification; migrate or explicitly isolate them.
- Keep roadmap, capability metadata and validation claims consistent with implemented e11 scope. A passing test suite alone does not establish rules accuracy or full army legality.

# Visual design workflow

- For game UI, menus, HUD, onboarding, and player feedback, use `docs/skills/design-first-ui-prompting/SKILL.md` together with the existing `online-game-design` skill. Adapt web-oriented examples to Godot and this tabletop game's needs; do not add browser, Three.js, or unrelated web dependencies.
- For visible UI changes, use `docs/skills/workflow-progress-screenshots/SKILL.md` where an actual Godot capture can be made. Label captures and limitations accurately; do not present mockups as in-game results.
- Use `docs/skills/workflow-score-to-target/SKILL.md` when the user asks for a numeric quality target or score. Scores require visible evidence and an explicit rubric; do not invent one on the user's behalf.
- Visual improvements must preserve clear game state and current-edition rules boundaries. Do not imply an action is legal or a result is rules-certified just because the interface presents it clearly.

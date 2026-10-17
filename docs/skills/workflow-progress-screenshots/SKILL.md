---
name: workflow-progress-screenshots
description: Use when changing visible game UI, art, animation, or board feedback. Show and inspect real Godot captures of the starting state and meaningful results when capture is available; label previews and limitations honestly.
---

# Workflow: Progress Screenshots

Adapted from Meng To's `workflow-progress-screenshots` skill for a Godot project. See `../mengto-skills/README.md` for provenance and license.

## Capture workflow

1. Before a visual change, capture the existing game state if the project can open in Godot.
2. Capture after each meaningful pass, rather than after every save.
3. For interaction changes, capture the relevant state (for example, a tooltip open, a disabled action, or a damage preview). For motion, use a short frame sequence or recording when available; a still image cannot prove animation behavior.
4. Inspect every capture for the correct scene, loaded assets, current values, clipping, and stray editor or debug UI.
5. Use the same viewport, game state, and framing for before/after comparisons.
6. Caption what the image actually shows and identify whether it came from a live Godot run, editor viewport, or a staged fixture.
7. Keep review captures in a gitignored output location; do not commit generated captures unless the user asks for project evidence/assets.

## Godot-specific limits

- Use the project's available Godot editor or runtime capture path. Do not assume browser capture scripts or Three.js workflows apply.
- If the game cannot be launched or a state cannot be reproduced, say which capture is missing and why. A mockup may help discuss a proposal but is not evidence that the game displays it.
- Check captures at the actual intended viewport sizes. A desktop capture does not prove small-window readability.

## Source material

This project copy is adapted from Meng To, `agent-skills/workflow/workflow-progress-screenshots/SKILL.md`, in [MengTo/Skills](https://github.com/mengto/skills), MIT licensed. Browser-specific capture details were replaced with Godot-appropriate guidance.

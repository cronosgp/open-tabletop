---
name: design-first-ui-prompting
description: Use when planning or implementing a game screen, menu, HUD, tooltip, or visual feedback in this Godot project. Turn fuzzy visual requests into a concrete layout, hierarchy, type, color, imagery, and interaction spec before iterating.
---

# Design-First UI Prompting

Adapted from Meng To's `design-first-ui-prompting` skill for this Godot game project. See `../mengto-skills/README.md` for provenance and license.

## Core principle

Write a screen specification, not a wish. Resolve layout and information hierarchy before adding decoration or motion.

## Screen brief

```text
GOAL
- What should the player understand or do on this screen?
- What is the player trying to accomplish?
- What would make the screen clear and successful?

FORMAT
- Godot viewport and supported aspect ratios:
- Safe margins and minimum readable sizes:

LAYOUT
- Main content regions:
- Information order:
- Primary action and secondary actions:
- What stays hidden until needed:

TYPE
- Heading, body, label, and numeric hierarchy:
- Legibility at the smallest supported viewport:

COLOR + MATERIAL
- Background and text colors:
- Semantic colors for friendly, enemy, warning, unavailable, and confirmed states:
- Accent color and restrained texture:

IMAGERY / GAME UI STYLE
- What visual communicates the game's tabletop setting:
- Which images or illustrations are functional, and which are decorative:
- What must remain readable over the board or miniature art:

COPY
- Exact title, helper text, labels, and action names:

INTERACTION + FEEDBACK
- Hover, focus, pressed, disabled, loading, and result states:
- Tooltip trigger and dismissal behavior:
- Motion purpose, duration, and reduced-motion behavior:

CONSTRAINTS
- Preserve existing gameplay, rules scope, and data:
- Limit this iteration to one or two visual variables:
```

## Iteration

1. First settle the screen's goal, hierarchy, copy, and main action.
2. Keep a coherent visual system, then change only one or two variables per pass.
3. Check the actual Godot screen at the relevant window sizes, not just a design description.
4. Treat typography and numeric combat information as fragile: check truncation, contrast, alignment, and scaling.
5. Use illustrations to explain state or action. Avoid decorative detail that competes with the board, dice, damage, or health information.
6. Keep an explicit distinction between previews, tutorial samples, host claims, and validated game outcomes.

## Review checklist

- Can a player identify the current screen and its primary action quickly?
- Is it clear which actions are available, unavailable, or conditional?
- Are health, dice, damage, and combat outcomes distinguishable at a glance?
- Does hover help without being the only way to access important information?
- Does motion communicate a state change and remain optional or restrained?
- Are rules and validation claims supported by the current 11th-edition scope documented in `AGENTS.md`?

## Questions when needed

- What is the one thing this screen should help the player do?
- Which information must remain visible while playing?
- What is the smallest game window or supported display where this must still work?
- Is a proposed illustration explanatory, or merely decorative?

## Source material

This project copy is adapted from Meng To, `agent-skills/ui/design-first-ui-prompting/SKILL.md`, in [MengTo/Skills](https://github.com/mengto/skills), MIT licensed. Project-specific Godot and Warhammer constraints above supplement the source workflow.

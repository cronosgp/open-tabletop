# Game development and design skills

This project uses selected Godot and cross-engine Agent Skills as practical references for implementation and player experience. Apply them according to the system being changed; the project does not need to load unrelated skills for every task. The project-wide design expectations are recorded in [AGENTS.md](../../AGENTS.md).

## Working principles

- Start from the player's goal and the match state they need to understand. Clarify the next action, its owner, its legal options, its cost or consequence, and how a blocked or interrupted action is recovered.
- Keep authoritative rules state deterministic and separate from presentation where the architecture allows it. UI clarity never upgrades an unsupported or unvalidated rules interaction into supported play.
- Prefer readable Godot scene composition, typed GDScript, explicit signals, accessible focus, responsive containers and state-driven feedback. Preserve the project's Godot 4.7.2 baseline and existing patterns.
- Use the engine editor and a real project capture when visual evidence matters. State the resolutions, controls and scenarios actually observed; do not substitute a mockup for an in-game result.
- Treat a skill as a checklist of useful questions, not as authority over project decisions. `AGENTS.md`, edition/source policy, current user direction and the verification guide take precedence.

## Installed skill set

The selected upstream folders are installed in the project worktree under `.agents/skills/` so Codex and compatible agents can load them by task. `.gitignore` keeps unrelated local agent configuration ignored and permits this selected set to be included in project changes:

| Skill | Apply to |
|---|---|
| `router` | Route game-development tasks to the smallest relevant engine, design-discipline and workflow skill set before work begins. |
| `online-game-design` | Existing project guidance for multiplayer game systems, interaction and player experience. |
| `godot-gdscript` | Typed GDScript, lifecycle, async work and script errors. |
| `godot-nodes-scenes` | Scene tree, node composition, reusable scenes and instancing. |
| `godot-signals-groups` | Event boundaries, signals, decoupling and node groups. |
| `godot-ui-control` | Godot Control nodes, containers, anchors, focus and themes. |
| `godot-multiplayer` | Host authority, RPCs, synchronization, peer lifecycle and recovery. |
| `godot-gdscript-headless-testing` | Godot headless test execution and failure interpretation, subject to the project verification policy. |
| `godot-resources` | Data-driven Godot Resources and resource-backed configuration. |
| `godot-3d-essentials` | Board, camera, lighting and other Godot 3D work. |
| `godot-physics` | Collision layers, overlap detection and ray queries for 3D board interaction. |
| `godot-animation` | AnimationPlayer, AnimationTree and Tween for character, board and interface feedback. |
| `godot-audio` | Godot audio playback, buses and effects for clear, configurable game feedback. |
| `godot-export` | Export presets, templates and reproducible platform builds when delivery work is in scope. |
| `game-ui-ux` | Cross-engine HUD, menus, navigation, scaling and screen flow. |
| `game-feel` | Timing and feedback for meaningful actions, decisions and results. |
| `input-systems` | Action mapping, accessible controls, device handling and rebinding when control work is in scope. |
| `level-design` | Battlefield layout, terrain, sightlines and spatial readability. |
| `save-systems` | Save identity, versioning, recovery and deterministic persistence. |
| `camera-systems` | Camera movement, framing, bounds and decision focus. |
| `create-game-assets` | Visual direction, cohesive asset families, import checks and asset provenance. |
| `performance-optimization` | Profile-first performance investigation and measured optimization. |
| `prototype-fast` | Scope playable mechanic prototypes and vertical slices around one explicit learning question and observable keep/kill criteria. |

For game interface work, continue to combine `game-ui-ux` and `godot-ui-control` with the existing `online-game-design` skill and the project workflows under `docs/skills/`.

## Source and attribution

The initial selected skill set was copied from [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) at commit `38a4c2500eeb5ff9ac084336b8f66108069d2f8d` on 2026-10-22. `godot-animation`, `godot-audio` and `godot-export` were added from the same commit on 2026-10-23 after checking their fit for this project. Export is relevant to the existing platform presets and H1 delivery milestone. The upstream repository describes the Godot skill baseline as Godot 4.7. Its Apache License 2.0 and NOTICE are preserved in [third-party/gamedev-skills](third-party/gamedev-skills/). The set is intentionally scoped to this Godot tabletop tactics project; it does not vendor unrelated engines, genres or publishing workflows. The current upstream HEAD matches this pinned commit.

The imported skills are third-party guidance. Project rules, source provenance, user instructions and verification boundaries remain governed by this repository.

# Tactical training UX audit

Status: issues observed in the guided opening and combat presentation. This document records the correction scope; it does not claim that these issues are fixed.

The [experience correction plan](tactical-training-experience-plan.md) turns the latest human feedback into implementation steps, distinguishes code findings from reproduction hypotheses, and specifies the next human acceptance gates.

The feedback identifies three separate layers of failure:

1. **Layout containment:** the opening guided panel can extend beyond the viewport.
2. **Decision clarity:** the player cannot always tell who acts, what is optional, which legal model can receive damage, or why an action is rejected.
3. **Combat presentation:** the attack result is technically recorded but resolves too quickly and exposes implementation details instead of a readable moment of action.

## Prioritized issue list

| Priority | Issue | Player impact | Required correction |
|---|---|---|---|
| P0 | Guided opening overflows the screen | The first session begins with clipped content, so the player loses context before learning the controls. | Put the guide inside a bounded scroll or collapsed card, set a minimum/maximum height for every supported viewport, and keep the first instruction visible without pushing the board or action controls off-screen. |
| P0 | Too many competing text surfaces | Guide, combat log, attack details, dice source, technical identifiers and action controls compete for attention. The player cannot identify the next decision. | Establish one primary decision card: **phase → active player → decision owner → legal action → consequence**. Move explanation and history into expandable secondary panels. |
| P0 | Defender allocation is missing or opaque | The defending player cannot choose a legal wound allocation or understand which model will be removed. This undermines agency and can make the result look wrong. | Expose the legal allocation decision after saves/damage. Show eligible models, wounded/Character/attached-unit priority and the resulting casualty preview. Do not permit choices that violate the current 11e allocation rules. |
| P0 | Command Re-roll appears mandatory | A reaction that should be optional feels forced, and the player cannot tell whether passing is legal. | Every re-roll window must show two explicit choices: **Use Command Re-roll** and **Continue without re-roll**. The pass option must be visible, owned by the correct player and never consume CP. |
| P0 | Dice are difficult to read | The screenshot repeats low-level attack text, shows `entry #156` and a chain identifier, and presents rows such as `A 1 → 1 attacks` without a clear hit/wound/save/damage structure. | Replace the default view with a staged, player-facing dice summary: weapon and target, roll group, result, damage, casualties. Keep source/chain/revision data behind an expandable technical view. |
| P1 | Dice/detail controls are ambiguous | `Dice and attack details` and `Animate recorded dice` look like switches, but their state and effect are not immediately clear. A player may not know whether the control changes the result, opens history or starts a replay. | Use explicit labels such as `Show attack details` and `Replay recorded dice`, show on/off or action states clearly, and explain that replay reveals the saved result without rolling again. |
| P1 | Dice resolution is too fast and has no tension | The result appears before anticipation can build, so a hit, failed save or casualty feels like a status update instead of a combat moment. | Use a deliberate beat structure: announce the attack, build the dice pool, roll, reveal grouped results, pause at the meaningful threshold, then show impact and casualty. Allow skip/fast-forward, but keep the final result visible. Timing must scale by event importance rather than making every individual die slow. |
| P1 | Invalid movement has no local explanation | A player tries to place a model and receives no immediate reason near the model, forcing guesswork. | Return a structured validation reason from the authoritative movement check and display it above the selected model and in the action card, for example `Blocked: exceeds Move`, `Blocked: out of coherency` or `Blocked: destination overlaps terrain`. |
| P1 | Combat history is written as a wall of prose | Long repeated unit/model names obscure the event that matters and make comparison difficult. | Render combat history as compact event cards with actor, weapon, target, result and casualties. Collapse repeated identifiers and provide a detail expansion for the full firing-model list. |
| P1 | Ownership and timing are not prominent during resolution | The player may not know whether the current screen is a result, a required choice or an optional reaction. | Pin `P1/P2`, phase, round, active player and decision owner at the top of every pending window. Label optional reactions separately from required allocations. |
| P2 | Technical and player-facing information are mixed | Local dice source, entry numbers and hash-like chains look like game rules or player obligations. | Keep diagnostics available for debugging, but hide them from the normal player surface and expose them only through an explicit `Details` control. |
| P2 | Feedback lacks impact and recovery emphasis | A casualty or hazardous result does not receive enough visual/audio weight, while a failed placement does not show a clear recovery path. | Add restrained hit-stop, camera emphasis, model highlight, casualty state and a clear next-step prompt. Do not delay mandatory choices or alter authoritative dice. |

## Correction order

### 1. Contain the first session

- Rebuild the opening guide with a bounded responsive container.
- Keep one short instruction and one current-window label visible.
- Put the four optional experiments in a collapsed or scrollable secondary section.
- Verify 1280×800 and 1024×768 with both preparation and the first combat decision visible.

### 2. Make legal decisions explicit

- Audit every damage allocation path used by the tactical scenario.
- Add defender-owned model selection where the rules require a choice.
- Audit all Command Re-roll windows for an explicit pass path and CP invariance.
- Add structured movement rejection reasons without duplicating rule validation in the UI.

### 3. Replace the result wall with a readable combat sequence

- Build a player-facing attack result model separate from the raw journal.
- Show animated dice in rule order with deliberate anticipation and impact beats, a skip control and a stable final summary.
- Start with tunable timing targets: roughly 250–400 ms to announce, 600–900 ms to roll a group, 300–500 ms to reveal the decisive result and 500–800 ms to hold a meaningful hit/casualty before the next action. Group dice where the rules permit instead of delaying every die equally.
- Group repeated firing models and show casualties as a clear before/after change.
- Keep raw D6/source metadata expandable for debugging and replay inspection.

### 4. Add game feel without hiding rules

- Give hits, failed saves, Hazardous failures and casualties distinct feedback.
- Use camera/model emphasis and short timing pauses only around meaningful transitions.
- Keep the current decision owner and legal buttons visible throughout.
- Preserve deterministic replay, save/resume and host-authoritative resolution.

## Acceptance gates

The correction is ready for another human session only when:

- no maintained panel or guide text leaves the viewport at 1280×800 or 1024×768;
- a new player can identify the current phase, active player, decision owner and next legal action from the primary card;
- the defender can make every allocation choice that the tactical rules require, while illegal allocations remain rejected;
- every Command Re-roll prompt has a visible legal pass option and passing does not spend CP;
- an invalid movement attempt displays a reason anchored to the selected model without waiting for a distant log entry;
- a player can feel the attack build, identify the decisive result and see the casualty land before the next action; the animation can be skipped without changing the result;
- raw identifiers and diagnostic chains are absent from the default player view;
- a second human session records these observations separately from automated Godot and loopback evidence.

The rules boundary remains authoritative: presentation may summarize or animate a decision, but it cannot invent a target, casualty, re-roll, CP payment or legal movement result.

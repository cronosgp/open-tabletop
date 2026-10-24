# Tactical training experience correction plan

Date: 24 October 2026. Status: implementation candidate prepared and locally checked following the user's approval; human acceptance remains pending. See the [progress report](tactical-training-experience-progress.md) for actual changes, evidence and open gates; this plan itself is not a completion claim.

Companion documents: [UX audit](tactical-training-ux-audit.md), [support matrix](support-matrix.md), [roadmap](roadmap.md), [decision flow](../architecture/phase-action-decision-flow.md), [defender allocation](../rules/defender-allocation.md), and [playtest procedure](../verification/tactical-training-playtest.md).

## Evidence and design objective

The player reported an overflowing opening guide, a confusing information-heavy flow, unclear dice, missing defender model choices, apparently compulsory Command Re-rolls, distant movement errors, and combat that resolves too quickly and out of sight. The player suggested symbols/images to reduce text. This is qualitative human feedback; build identity, viewport and exact failing action sequences were not supplied. Do not treat it as a completed structured playtest or invent reproduction details.

Code inspection provides two useful leads in `scripts/main.gd`:

- `_start_guided_first_session()` explicitly sets `defender_choice` to false. The guided entry disables the choice the player expected. Follow the setting into match creation and admission before changing the default; the domain allocation implementation already exists.
- The reaction panel includes `Keep result · 0 CP` and `Command Re-roll · 1 CP`. This proves a UI path exists, not that passing works visibly in every reported state. Reproduce the affected windows and inspect availability, focus, clipping, ownership and continuation before attributing the problem to rules logic.

The objective is for either player to understand **what is happening, who decides, which choices are legal, and what changed on the battlefield**, with enough anticipation to enjoy the result. The board remains the primary surface. Rules accuracy and player agency take precedence over cinematic effects.

Guidance applied: project router, online-game-design, design-first UI prompting, game-ui-ux, godot-ui-control, game-feel and create-game-assets. This is a planning task; animation/audio implementation guidance and screenshot workflow must be loaded when those systems are actually changed or captured.

## Target screen and visual language

Use a restrained tabletop instrument style: dark opaque panels, clear numerical hierarchy, simple original vector symbols, minimal texture. Avoid decorative faction illustrations around the decision area. Preserve the existing asset direction where it remains readable.

| Region | Always visible | Appears only when relevant |
|---|---|---|
| Compact top strip | Round, phase, active player, both players' CP | Prominent decision-owner badge when control changes |
| Battlefield | Selected miniature/unit, readable bases and targets | Legal recipients, movement preview, local rejection reason, damage/casualty feedback |
| Decision card | Current task, owner, primary action and legal alternatives | Eligibility explanation, cost, consequences and confirmation |
| Combat tray | Current roll stage during combat; latest final summary until dismissed or replaced | Dice pool, target number, modifiers, results and optional reaction |
| Help/history drawer | Small named access controls | One contextual guide instruction, optional experiments, event history and technical details |

At narrow widths, the decision card docks above the combat tray; help/history replaces secondary content rather than stacking over required controls. Only the current decision receives primary emphasis. Required buttons never depend on scrolling through tutorial text. Guide and reference content may scroll independently.

Initial layout targets: 1280×800 and 1024×768, with a larger desktop viewport as a comparison. Start with 16 logical-pixel safe margins, body text around 16–18, larger dice numerals and actions at least 40 logical pixels high; tune against actual Godot captures rather than shrinking everything to fit. Use anchors, containers and a shared Theme. Treat increased text size as an additional layout case, not evidence of platform coverage.

Use color plus shape/label: player badges identify ownership, an outline identifies selection, a check identifies success, a cross identifies failure, and a lock identifies ineligibility. Do not encode player, success and availability using the same color alone. Important help is available by click and focus, not hover alone.

## Delivery order and acceptance

### 0. Establish the failing paths

Record candidate build, window size, UI scale, entry point and match settings. Reproduce opening, first ranged attack, a legal defender allocation, passing a reroll, and invalid placement using the actual guided scenario. Keep the user's observations separate from developer reproduction and existing automated evidence.

Deliverable: a small issue-to-state map with screenshots when practical. If a symptom cannot be reproduced, retain it as unresolved and record the exercised path; do not close it because a test passes.

### 1. P0 — Restore agency and contain the opening

1. Make defender selection the guided-session default through the existing supported domain path. Keep automatic allocation as an explicit assist for exercises that need it, visibly labeled. Check both guided and resumed matches; do not silently rewrite saved match settings.
2. Bring the active decision, its owner and all legal alternatives into one bounded card. During shared-computer play, show `Player 2 decides` and an explicit handoff; during connected play, the other player sees a waiting state. Neither player can submit the other's choice.
3. Present optional rerolls with equally readable actions: `Keep result · 0 CP` and `Command Re-roll · 1 CP`. Retain current dice visibly. Explain unavailable rerolls beside the disabled action. Audit Hit, Wound, Save, Damage, attack count, Advance, Charge and the scenario's other enabled windows separately. Distinguish free ability rerolls from CP rerolls.
4. Reduce the guide to one current instruction with `Show help` / `Hide help`. Put optional experiments and full explanations behind a drawer. Hiding help never hides a mandatory decision or blocks progression. Fix container sizing and focus as part of this change.

Acceptance: no clipped instruction or decision controls at target sizes; the defender can select a non-default eligible recipient when a legal choice exists; every optional reaction can be declined without spending CP or stalling the action. If no legal recipient choice exists, show why rather than implying freedom to choose any casualty.

### 2. P1 — Explain actions where they happen

Show a movement destination ghost, relevant distance/path and a concise reason immediately above the affected miniature or destination: `Exceeds Move`, `Breaks unit coherency`, or `Destination occupied`. Wording must reflect the actual domain rejection code. Do not invent a reason from visual proximity or create separate UI legality logic.

Preview feedback is advisory; confirmation still uses authoritative validation. Keep the attempted destination visible and offer an obvious retry/reset. Mirror the same reason in the decision card for accessibility. Clamp the label inside the viewport, prevent it covering the selected base, and use an edge cue/card fallback when the miniature is off-screen. Multiple failures show the primary blocker first with further details expandable. Clear stale reasons when the preview becomes valid.

Acceptance: a rejected move yields a local explanation in the same interaction, retains the original legal state and lets the player correct the destination without consulting history.

### 3. P1 — Make combat readable before adding spectacle

Create a presentation model derived from authoritative attack events and pending decisions. Keep the current actionable roll separate from completed history. Show weapon, attacker, defender, stage, threshold, dice results, applicable modifier explanation and resulting count. Fixed values should appear as fixed values, not fake rolls.

Group dice only when the current rules implementation permits identical resolution. Keep pooled hits/wounds distinct from per-model saves/damage and heterogeneous defense. Do not let a compact summary skip a required allocation, reaction or ability. When the rules require recipient selection before a save, present that selection before revealing that save; when the supported homogeneous exercise batches saves, label that bounded behavior correctly.

Use `Hits`, `Wounds`, `Saves`, `Damage` as stage labels; keep remaining wounds on a miniature distinct from successful wound rolls. Successful/failed dice have outlines or symbols as well as color. Large pools use readable pages/groups and totals, with each individual result inspectable. The final summary states damage applied and models destroyed; repeated names and technical entry/chain identifiers move into details.

Allocation view: highlight eligible miniatures on the board and offer equivalent model cards with distinguishing equipment/position and remaining wounds. Preview `2 → 0 wounds · model destroyed` only when determinable from already revealed information. Otherwise label uncertainty. Explain mandatory recipient restrictions and source-specific exceptions using the authoritative eligible set. Confirm the selected recipient before removal; do not offer a separate arbitrary casualty choice after damage has already determined destruction.

Acceptance: a player can reconstruct the roll stage, successful results, any decision, chosen recipient and casualties from the normal view. Full history remains available without occupying the battlefield by default.

### 4. P2 — Add anticipation, reveal and impact

Implement one combat sequence driven by events, interruptible at every real decision:

1. **Declare:** emphasize attacker, weapon and target.
2. **Anticipate:** assemble and animate the recorded/current authorized dice pool.
3. **Reveal:** settle readable results and highlight the decisive threshold.
4. **Decide:** stop at the actual reaction/allocation window, with owner and alternatives visible.
5. **Apply:** show confirmed damage on the affected miniature, then casualty feedback when destruction occurs.
6. **Hold:** leave a compact final result visible before returning attention to the next action.

Initial tuning hypotheses: 250–400 ms declaration, 600–900 ms group roll, 300–500 ms reveal emphasis, 500–800 ms casualty hold. These are adjustable design starting points, not measured quality targets. Avoid adding the full sequence to every single die. Use a modest sound cue, brief model highlight and casualty fade/removal; reserve stronger emphasis for destruction or unusually consequential outcomes. Camera motion should be optional and never disorient the tactical view.

Provide `Normal`, `Fast`, reduced motion and `Skip animation`. Skip completes presentation only; it never declines a reaction, allocates damage, spends CP, advances a phase or generates new RNG. `Replay recorded dice` is separate from reroll and never changes state. Presentation must not reveal future random results or commit damage before a still-open decision. Save/resume or reconnect rebuilds the current decision and a stable summary without replaying old impacts or submitting twice. Local animation speed does not control the other player's legal access to decisions.

Acceptance: combat is readable with animation, fast mode and reduced motion; skip/replay preserve authoritative results and all player choices. Final networking verification remains deferred to integration and must be reported separately.

### 5. P2 — Replace repeated prose with a small symbol system

Yes: symbols can remove repeated scaffolding and help scanning. They cannot replace the explanation of an unfamiliar rule, a blocked action or the owner/cost of a choice.

| Meaning | Proposed symbol | Retained text/data |
|---|---|---|
| Hit stage | Crosshair | `Hits`, threshold and success count |
| Wound stage | Impact burst | `Wounds`, threshold and success count |
| Save stage | Shield | `Saves`, threshold and outcome |
| Damage | Cracked armor | `Damage`, applied amount |
| Remaining model wounds | Segmented health mark | Current/max value |
| Destruction | Crossed miniature | `Destroyed` and count |
| Reroll | Circular arrow around die | Action name, eligible dice and CP cost |
| Invalid placement | Blocked footprint | Specific reason and recovery action |

Start with original monochrome SVGs sharing stroke, silhouette and size. Review one representative strip at actual Godot scale before producing the family. Preserve English labels, keyboard focus and accessible descriptions. Record asset origin/license. Avoid decorative imagery in this pass; investigate recognition in the next playtest before hiding more text.

The user permits considering Wahapedia 11e images. Use them selectively for unit or faction recognition when they improve identification; they are optional, not a replacement for action symbols, eligibility, numerical results or rule explanations. Inspect the actual source and record provenance and applicable usage terms before adoption. Keep third-party images local and outside Git and distributed packages under the existing content policy; retain an original symbol/text fallback. No Wahapedia image has been selected or imported by this planning update.

## Implementation boundaries

Start from `scripts/main.gd` guided launch, reaction controls and dice refresh functions; reuse `scripts/ui/combat_hud.gd` where appropriate. Keep decision ownership/eligibility in the normalized pending-decision and command services. Extract presentation components incrementally for the decision card, dice tray and board feedback rather than expanding the main script or attempting a whole-engine rewrite.

Before changing allocation order, reaction timing or eligibility, check the applicable current Wahapedia 11e chapter, game mode and revision. Datasheet facts require the verified corresponding local export. This plan does not establish a new rules interpretation or certify existing rules. Preserve unsupported interactions as explicit blockers. Update capability metadata and support claims only when runtime scope actually changes.

Dependencies: reproduction → P0 agency/layout → local movement feedback and readable combat → pacing/feedback → icon refinement → human playtest. Visual polish cannot close an unresolved choice or continuation defect.

## Next playtest and evidence gates

Do not run new tests solely for this planning document. During implementation, run only checks required by the active project workflow or requested by the user. Likely existing check areas are guided/layout UI, choice ownership, core reactions, allocation, combat results and tactical combat flow; select exact commands after the patch scope is known and record actual commands/outcomes.

For visible implementation, use the project's progress-screenshot workflow and capture actual Godot states at the target viewports: opening, both-player handoff, reroll keep/use, allocation, invalid move, dice reveal and final casualty. Images alone do not prove input behavior or comprehension.

The next human session should ask the player to:

- Start training and identify the current task without opening the manual.
- Keep a result without using Command Re-roll, then deliberately use one when legal and explain the CP difference.
- Act as the defender, identify eligible recipients and choose a different legal model where possible.
- Attempt an invalid move, explain its rejection and correct it from the local feedback.
- Watch an attack and explain hits, wounds, saves, damage and removed models.
- Repeat with fast/skip and reduced motion, retaining access to all decisions.

Record success without help, hesitation, incorrect assumptions and concrete failure paths. Treat “can explain why a model died” and “can decline an optional reroll” as release gates for this correction. Do not manufacture a numeric quality score or call the experience fixed from automated checks. The user's current report establishes unresolved experience issues despite previous technical passes.

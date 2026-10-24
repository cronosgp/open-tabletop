# Documentation

Use the root [README](../README.md) for a project overview and clean-checkout start. This index groups maintained guidance by purpose. Update it whenever a document is added or moved.

## Guides and gameplay

- [Tactical training](guides/tactical-training.md) — distinct Marine forces, optional abilities and stratagems, and configuration boundaries.

- [3D combat exercise](guides/3d-combat.md)
- [Army builder](guides/army-builder.md)
- [Gameplay UI and player flows](guides/gameplay-ui.md)
- [Initial test scenario](guides/initial-test-scenario.md)
- [Prepared match](guides/prepared-match.md)
- [Reference armies](guides/reference-armies.md)
- [Saved army matches](guides/saved-army-matches.md)
- [Tactical controls](guides/tactical-controls.md)

## Rules, mechanics, and boundaries

- [Actions](rules/actions.md) · [Advanced defense](rules/advanced-defense.md) · [Attack plans](rules/attack-plans.md)
- [Awakened Dynasty](rules/awakened-dynasty.md) · [Chapter Approved mission](rules/chapter-approved-mission.md) · [Close combat](rules/close-combat.md)
- [Combat Doctrines](rules/combat-doctrines.md) · [Contact reachability](rules/contact-reachability.md) · [Core stratagems](rules/core-stratagems.md)
- [Current unit abilities](rules/current-unit-abilities.md) · [Defender allocation](rules/defender-allocation.md) · [Detachment stratagems](rules/detachment-stratagems.md)
- [Devastating Wounds](rules/devastating-wounds.md) · [Equipment](rules/equipment.md) · [Escape re-rolls](rules/escape-rerolls.md)
- [Hail of Bolts (historical)](rules/hail-of-bolts.md) · [Hazardous](rules/hazardous.md) · [Implacable Eradication](rules/implacable-eradication.md)
- [Movement types](rules/movement-types.md) · [Multiple units](rules/multiple-units.md) · [Oath of Moment (historical)](rules/oath-of-moment.md)
- [Objective Secured](rules/objective-secured.md) · [Objectives](rules/objectives.md) · [Reanimation Protocols](rules/reanimation-protocols.md)
- [Roster validation](rules/roster-validation.md) · [Terrain](rules/terrain.md) · [Weapon mechanics](rules/weapon-mechanics.md) · [Weapon selection](rules/weapon-selection.md)

## Data and sources

- [Rules source decision](rules-source-policy.md) — Wahapedia 11e is the definitive project reference.
- [Source policy and assessment](data/source-assessment.md) — authoritative local datasheet source, verification boundary, and pipeline status.
- [Construction catalog policy](construction-catalog-policy.md) — local runtime choices, blocked profiles and legacy list handling.
- [Data-pack format](data/data-packs.md) — existing format and legacy adapter status.
- [11e starter lab](data/11e-starter.md) — isolated exercise and its legacy sample inputs.
- [Faction catalog](data/faction-catalog.md) · [ForceOrg import](data/forceorg-import.md) · [Model import validation](data/model-import-validation.md)
- [Wahapedia importer](wahapedia-import.md) · [Space Marines catalog and source reconciliation](space-marines-catalog.md) · [Consolidated Space Marines profile records](space-marines-profile-records.md) · [Datasheet implementation architecture](datasheet-implementation-architecture.md)
- [Design-first UI prompting skill](skills/design-first-ui-prompting/SKILL.md) · [progress screenshots](skills/workflow-progress-screenshots/SKILL.md) · [score-to-target workflow](skills/workflow-score-to-target/SKILL.md)
- [Game development and design skills](skills/game-development-design.md) — selected Godot and cross-engine skills, use guidance and source attribution.

## Architecture

- [Architecture direction](architecture.md) — target ownership boundaries and migration plan.
- [Phase, action and decision flow](architecture/phase-action-decision-flow.md) — progression stages, pending decisions, suspension/resume and phase-close gate.
- [Match history](architecture/match-history.md)
- [Match persistence](architecture/match-persistence.md)

## Project status and direction

- [Current assessment and tactical consolidation plan](project/current-assessment.md) — roadmap position, strengths, weaknesses and evidence gates.
- [Tactical training UX audit](project/tactical-training-ux-audit.md) — prioritized feedback on guided layout, decisions, dice readability, movement feedback and combat feel.
- [Tactical training experience correction plan](project/tactical-training-experience-plan.md) — implementation order, screen hierarchy, player agency, combat pacing, symbols and next-playtest gates based on human feedback.
- [Tactical training experience correction progress](project/tactical-training-experience-progress.md) — implementation findings, local evidence and remaining human/integration gates.
- [Current support matrix](project/support-matrix.md) — what is supported and what is not.
- [Roadmap](project/roadmap.md) — forward plan and completion criteria.
- [Backlog](project/backlog.md)
- [Track A checked-match scope](project/track-a.md) · [Track A5](project/track-a-a5.md)
- [Rules status history](project/rules-status.md) · [Functional roadmap history](project/roadmap-funcional.md)

## Verification

- [Tactical training playtest procedure and record](verification/tactical-training-playtest.md) — human comprehension gate; no session claimed.

- [Verification guide](verification/verification.md)
- [Latest recorded verification results](verification/verification-results.md)
- [A2 pending-workflow audit](verification/a2-pending-workflow-audit.md) — normalized decision-source inventory and its remaining workflow-level boundary.

## Documentation conventions

- The root README is the concise entry point; this page is the documentation map.
- Keep topic detail beside its owning category and prefer links over duplicating long explanations.
- Mark historical or superseded work as such. Do not promote a historical experiment into current support without source review, implementation, tests, and updated status metadata.
- Keep paths and links relative so they work in a clean clone.

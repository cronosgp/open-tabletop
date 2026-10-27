# Track A — Current rules and match scope

Track A is the rules/content workstream. The end goal remains a complete, source-versioned match for the supported factions and mission configuration. The former 930-point Gladius vs 880-point Awakened lists are retained as experimental reference rosters; they are not currently certified as a complete legal match.

## Rules baseline

Wahapedia's 11th-edition Core Rules, faction pages and verified local Data Export are the project's definitive reference. Preserve source book/chapter, mode, revision and snapshot identity. Official Games Workshop material may be noted as context but is not an admission prerequisite and cannot override the selected Wahapedia revision. See [source assessment](../data/source-assessment.md).

## Current state

- The construction catalog publishes all 85 shared-book Space Marine identities. A source-linked Land Speeder Vengeance profile and Storm of Vengeance runtime path from the Dark Angels App are implemented with local checks pending, so this app-only profile remains out of new construction choices.
- Marine scope continues through local source, rules, combat, construction and materialization checks. The Wardens of Ultramar profile and Strategium Command have focused local checks; some detachment effects still await local validation. Blade of Ultramar now exposes Armour of Antoninus through per-model defense/prevention, Oath of Macragge through per-model melee weapon modification and Veteran of Behemoth through ranged attack profiles; focused local checks remain pending. All four enhancements and all six stratagems now have local paths; Tactical Foresight applies -1 to Wound when the triggering enemy's Strength exceeds the target's Toughness during its current attack sequence. Focused checks and current official rule locators remain pending. The current metadata/runtime gate mismatch is tracked in the [roadmap](roadmap.md).
- Construction uses the local runtime catalog only. Historical, pending-validation and unreconciled profiles stay outside new choices; old lists remain labeled drafts. See [construction catalog policy](../construction-catalog-policy.md).
- The current implementation includes bounded Space Marine profiles/effects, selected core decisions and a selected CA 2026-27 mission. The exact roster, rule and mission boundaries are in the [support matrix](support-matrix.md) and [A5 reference-roster notes](track-a-a5.md).
- Current-reference Space Marine roster admission rejects mixed represented Chapter faction keywords and applies the Spearpoint/Wrath of the Rock Chapter restrictions during prepared-match creation. Non-Faction `DEATHWING`/`RAVENWING` keywords do not establish Chapter identity; conditional chapter grants remain outside this gate. Focused local checks remain pending. See [Chapter admission](../rules/current-space-marine-admission.md).
- The capability registry is implemented and gates supported/blocked scope. A shared generic action/reaction engine remains future work as specified in [phase/action/decision flow](../architecture/phase-action-decision-flow.md).
- Network validation of current Marine increments is deferred to final integration. Full faction coverage, general army legality and full-match certification remain incomplete.

## Completion sequence

1. Close remaining local source/effect/interaction gaps in the declared Space Marine catalog scope; keep incomplete choices blocked.
2. Implement the shared phase, action, pending-decision, suspension/resumption and phase-close contracts. Migrate existing local flows incrementally without changing rule outcomes.
3. Expand admitted Marine compositions, options, attachments and dependencies through local validated slices.
4. Keep the capability registry, local construction catalog, support matrix and evidence reports synchronized.
5. After Marine implementation is ready, perform the deferred host/guest, persistence, stale-command and RNG-continuation integration checks.
6. Broaden mission and faction coverage only after each slice has a source identity, runtime behavior and bounded validation evidence.

The work does not promote an identity to full support solely because it appears in the catalog. Rules, admission, local validation, network validation and certification remain separate claims.

# Open Tabletop roadmap

This is the plan for remaining work. Current runtime scope and limits live in the [support matrix](support-matrix.md); historical increments and verification evidence live in their topic reports.

## Product goal

Open Tabletop is an open-source desktop game for two players to play Warhammer 40,000 11th edition matches. The project aims to provide authoritative match state, rules-aware choices and reactions, dice resolution, mission scoring, saved matches, and LAN or direct host connections. Players provide their own miniature visuals. A flexible shared battlefield comes before the final-milestone battlefield editor.

The project has no project-operated server or account service. The local player host is authoritative. Project code and original demo assets are MIT-licensed; third-party rules data and player visuals retain their own source and use terms.

## Decisions that govern the roadmap

- **Rules reference:** Wahapedia's `/wh40k11ed/` rules, faction pages and Data Export are definitive for this project. Preserve the relevant edition, book/chapter, game mode, snapshot and revision. Games Workshop publications may provide context, but are not a prerequisite and do not override this selected reference. See [source assessment](../data/source-assessment.md).
- **Army construction:** expose only profiles in the consolidated local runtime catalog. Do not restore broad API catalog fetching or cached API choices. Pending-validation and historical/unreconciled profiles stay out of new choices; existing affected lists remain labeled legacy drafts. See [construction catalog policy](../construction-catalog-policy.md).
- **Validation order:** continue the Space Marines scope with local rules, combat and admission checks. Defer network validation to final integration; deferred work is never reported as passed.
- **Match flow:** define progression, phase steps, pending decisions, interruption and resumption before broadening timing support. The [phase/action/decision contract](../architecture/phase-action-decision-flow.md) defines this target; it does not claim a generic reaction engine is already implemented.
- **Support claims:** distinguish catalogued, implemented, locally validated, source-checked, network-validated and certified scope. A selectable profile or passing suite alone is not full rules support or army legality.
- **Content distribution:** keep raw Wahapedia exports and derived third-party data local and out of Git/distribution. The clean-checkout demo uses project-owned content and does not silently fetch third-party game data.

## Current baseline

- The consolidated local Wahapedia catalog offers all 85 shared-book Space Marine identities, including Wardens of Ultramar. Selection/admission does not mean every identity, option or interaction has complete rules coverage. Four Necron profiles remain outside this Space Marines construction catalog.
- Focused local profile, rules, combat, construction and materialization checks are the active validation path. Wardens of Ultramar and its Strategium Command coverage have focused local checks. Vanguard Ambushers and three Ironstorm stratagems remain pending local validation and are explicitly blocked by the capability registry and runtime gates.
- Current Marine work has local validation only. Network validation remains deferred to final integration. Full faction legality and general army legality are not certified.
- The 930-point Gladius and 880-point Awakened lists remain experimental reference rosters; earlier fixed-roster certification claims were withdrawn pending completion of the applicable current-rule scope.
- The project has a host-authoritative LAN/loopback path, versioned snapshots and an event/dice journal. Cross-machine networking, broader match negotiation and recovery coverage remain separate evidence gates.
- The local Wahapedia ingestion and catalog tooling exists. The verified-source and local-only construction policies supersede legacy OpenHammer/40kdc catalog workflows; those adapters remain isolated historical tooling.
- Deterministic phase ordering and turn rollover live in `scripts/edition_11/phase_progression.gd`; boundary-effect ordering lives in `phase_resolution.gd`; command priority lives in `scripts/edition_11/match_actor.gd`; common command admission and existing close blockers, including transport placement, live in `scripts/edition_11/phase_close_gate.gd`. `scripts/edition_11/match_command_service.gd` owns gameplay command execution for deployment, model placement, reactions, damage/coherency allocation, preparation choices, phase advancement, doctrine and unit choices, movement and contact workflows, charge, shooting, attack plans, fights and mission-action starts. `main.gd` retains RPC admission, broadcasts and player feedback; the combat facade and domain modules retain validation and state transitions. Combat Doctrine, supported stratagem roll/Battle-shock windows, Reanimation, pending attack allocation, phase-start/end reaction choices and other active UnitActions ability/preparation windows have normalized read-only projections in `scripts/edition_11/pending_decision.gd`, shared by command priority and phase-close admission while specialized handlers revalidate submitted choices. Reanimation projects model-placement intent; the rules module validates its free-form coordinate. Damage allocation projects the attacker/defender owner and current model choices. The projections have no domain event ID or persisted resume frame yet. Combat Doctrine, stratagem, Reanimation, damage allocation and UnitActions selection commands now carry and validate the current decision ID and legal option ID; other workflows retain specialized validation. Faction effects remain in their domain modules, sequenced at phase boundaries by `phase_resolution.gd`. Other pending workflows are still specialized; a shared action lifecycle, full decision migration, complete close-blocker coverage, trigger dispatcher and resolution-frame stack remain future work. Legacy non-combat exercise movement stays separate.

See the [support matrix](support-matrix.md) and [verification results](../verification/verification-results.md) for detailed scope and evidence.

## Rules, phase flow and content

| Milestone | Work | Completion condition |
|---|---|---|
| A1 — Marine scope closure | Finish local source reconciliation, executable effects, options, attachment combinations and interactions for declared Marine profiles. Keep unsupported scope blocked. | Each published Marine capability matches its bounded local source profile, has focused local evidence and is accurately represented in the catalog and support matrix. |
| A2 — Phase and decision foundation | Implement the shared progression, action, pending-decision and resume contracts in [the phase/action/decision flow](../architecture/phase-action-decision-flow.md). Migrate existing local workflows incrementally, keeping rule-specific timing in versioned profiles. | Phase close cannot pass pending work; eligible choices can suspend and resume actions deterministically; no-choice paths advance automatically. |
| A3 — Marine completeness | Add remaining Marine compositions, options, shared rules and selected detachments in verified local slices. Keep construction local and fail closed for incomplete profiles. | Every newly exposed choice has the required rule dependencies and bounded local validation; no general legality claim is implied. |
| A4 — Capability and source status | Keep one inspectable registry for source provenance, implementation, local/network validation and certified limits. | Setup, rules gates, UI and documentation derive consistent supported/blocked claims. |
| A5 — Mission and faction breadth | Add mission profiles, factions and their interactions after the shared rules/decision foundation supports them. | Each selectable configuration has compatible mission, battlefield, content and source identities with validated bounded behavior. |
| A6 — Rules completeness | Expand shared rules, vertical geometry, vehicles, transports, aircraft, reserves and cross-faction interactions. | The support matrix accurately covers the declared release scope and clearly blocks everything outside it. |

## Multiplayer and persistence

| Milestone | Work | Completion condition |
|---|---|---|
| B1 — Match agreement | Negotiate the rules/content/mission manifest and readiness before gameplay. | Both players accept identical versioned match inputs. |
| B2 — Direct internet transport | Improve host-address sharing, security, NAT guidance and optional user/community-operated relay support. | Two players complete a match through the documented direct-host flow. No project-operated service is required. |
| B3 — Recovery and diagnostics | Improve seat recovery, loss/latency feedback, reconnection and diagnostics. | A dropped peer can rejoin the correct authorized seat at a persisted state with pending decisions restored. |
| C1 — Journal lifecycle | Add multiple save slots and bounded journal maintenance. | Long-running matches remain resumable and history storage remains manageable. |
| C2 — Replay and exchange | Render deterministic replays and allow players to exchange result/replay files directly. | A saved journal can be replayed and shared without an account service. |
| C3 — Version migration | Define safe save/replay compatibility and migration. | Content updates cannot silently rewrite or invalidate an existing match. |

Per the validation-order decision above, network validation for the current Marine implementation is deferred until the final integration stage. When that stage begins, cover manifest agreement, authoritative choices, stale/duplicate commands, save/rejoin, pending decisions and RNG continuation. Do not count earlier local or loopback checks as cross-machine results.

## Player experience and release quality

| Milestone | Work | Completion condition |
|---|---|---|
| D1 — First session | Guide a new player through a bounded sample, setup declarations, deployment and initial actions. | A new player understands the next legal task without needing technical documentation. |
| D2 — Inline rules help | Explain supported keywords, decisions, phase steps and blocked-action reasons. | Players can understand why an action is offered or blocked within the declared scope. |
| D3 — Dice presentation | Make outcomes, costs, provenance and recorded history readable without overstating RNG guarantees. | Players can inspect what was rolled and what the authoritative match recorded. |
| D4 — HUD and feedback | Keep round, phase, active player, current decision owner, pending choice and recent result visible. | The board answers “what phase, whose turn, who acts now, and what just happened?” |
| D5 — Inactive-player engagement | Allow safe inspection and planning while waiting, without submitting out-of-turn commands. | Waiting players stay oriented and can recover context after reconnecting. |
| D6 — Match end | Provide recorded result, local rematch, summary and result export. | Completing a match leads to a useful next step; network rematch remains gated on integration. |
| E1 — Accessibility | Add non-color-only cues, text scaling, keyboard navigation and reduced motion. | Core play does not rely on color, small text or mouse-only input. |
| E2 — Localization | Consolidate interface strings and support additional languages. | UI text can be translated without changing rules code. |
| H1 — Delivery | Verify CI, native builds and Windows/Linux compatibility. | Published builds are reproducible and the declared platform matrix is supported by evidence. |
| H2 — Playtesting | Measure turn duration, blocked actions, comprehension, recovery and match completion in voluntary local playtests. | Product decisions use recorded player evidence; no telemetry service is required. |

These tracks progress alongside rules work where possible and are release requirements, not a final polish-only phase.

## Open-source content and maintenance

- Keep the MIT code license and original project-owned demo content clearly separated from third-party sources and player-supplied visuals.
- Preserve data provenance, source revision, content identity and local snapshot hashes.
- Keep external catalog/import adapters isolated from construction and match resolution.
- Record implementation scope and evidence with each rules/content increment.

## Sequencing

| Order | Focus | Exit condition |
|---|---|---|
| 0 | Resolve current documentation baseline and keep source/catalog/support policy consistent | No merge markers or contradictory source, catalog or validation claims in maintained project guidance. |
| 1 | Continue Marine local scope closure and define shared phase/action/decision contracts | Local rules/combat/admission checks and consistent capability/support metadata for each increment. |
| 2 | Migrate existing pending workflows to shared decision/resumption contracts; continue Marine completeness | Phase/turn progression is gated by unresolved work and supported decisions resume deterministically. |
| 3 | Run final integration and deferred network validation | Host/guest agreement, command authority, recovery, pending windows and RNG continuation pass the explicitly selected checks. |
| 4 | Broaden mission/faction coverage and release quality in verified slices | Every newly declared playable configuration has source, implementation and validation evidence. |
| 5 | Deliver replay, native builds and platform support | Supported platforms can complete, save, resume and inspect documented matches. |
| 6 | Implement the battlefield editor — final product milestone | Players can author, validate, save and share maps whose versioned geometry is used by rules and presentation. |

## Next actions

1. Resolve capability entries marked `supported` while their validation status is pending: complete the local checks or block the effect in runtime and setup until they pass.
2. Extend the normalized decision record and phase-close blockers to more local workflows; migrate action suspension/resumption and persisted resolution frames incrementally beyond Movement and Charge.
3. Keep the capability registry, construction catalog, support matrix and rule reports aligned with those actual gates.
4. Complete Marine scope and shared dependencies using the local Wahapedia source; keep incomplete profiles unavailable for new construction choices.
5. Perform the deferred network integration checks only after the Marine implementation stage is ready.

The battlefield editor remains the final implementation milestone. Until then, keep mission geometry and terrain data-driven on the maintained shared battlefield.

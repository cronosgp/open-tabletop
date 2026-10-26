# A2 pending-workflow audit

Updated 23 October 2026. This checkpoint inventories the normalized decision sources registered by `scripts/edition_11/pending_decision_registry.gd` and their public command paths. It is an audit of decision-source families, not a certification of every selectable option or every individual rules interaction.

**Follow-up on 26 October 2026:** Emergency Disembark has an optional `aggressive-choice` stage for Gauntlet Task Force Aggressive Disembarkation before Hazard is rolled. The same choice now appears before every mandatory Drop Pod Assault Rapid Disembark after arrival in either player's Movement phase, including after Rapid Ingress in the opponent's Movement phase. Each passenger returns to the existing multi-passenger continuation, and the Drop Pod's more-than-8-inch enemy restriction remains. The 23 October verification artifacts do not cover either new choice stage; focused checks and playtesting remain pending.

## Decision-source inventory

| Decision source | Public command path | Focused regression |
|---|---|---|
| Awakened attachment | `SELECT_AWAKENED_ATTACHMENT` | `test_awakened_dynasty` |
| Mission preparation | `SELECT_UNIT_CHOICE` | `test_chapter_approved` |
| Combat Doctrines | `SELECT_DOCTRINE`; phase-start UnitActions use `SELECT_UNIT_CHOICE` | `test_combat_doctrines`, `test_match_command_service` |
| Damage allocation | `ALLOCATE_DAMAGE` | `test_damage_allocation` |
| Oath of Moment | `SELECT_OATH_TARGET` | `test_oath_of_moment` |
| Reanimation | `RESOLVE_REANIMATION` | `test_reanimation_protocols`, `test_current_unit_abilities` |
| Stratagem reactions | `COMMAND_REACTION`; My Will Be Done is projected in the same reaction window | `test_stratagems`, `test_core_reactions`, `test_escape_rerolls`, `test_current_unit_abilities` |
| Unit abilities and setup | `SELECT_UNIT_CHOICE` | `test_current_unit_abilities`, `test_hammer_of_wrath`, `test_jump_pack_captain`, and feature suites |
| End-turn coherency | `REMOVE_COHERENCY` | `test_morale_coherency` |
| Desperate Escape allocation | `ALLOCATE_ESCAPE_WOUND` | `test_escape_rerolls` |

The focused cross-check for these sources passed **19/19 processes** (import, Python checks, the ten source/feature regressions above, command service, pending-decision registry, phase-close gate and resolution frames) at `.tools/verification/20261023T140953672503Z/results.json` (`network: false`, Godot 4.7.2). This run includes the My Will Be Done public-command fix.

Follow-up admission coverage now also rejects My Will Be Done submissions with an obsolete option ID, alongside wrong-owner and stale-revision submissions; all leave the state unchanged. The focused follow-up passed **6/6 processes** at `.tools/verification/20261023T141510253642Z/results.json` (`network: false`, Godot 4.7.2).

Repulsor Combat Embarkation now exercises its defender choice through the normalized unit-choice command, preserves the suspended Charge frame across serialization and either pass/embark response, and resumes target selection/placement through public `CHARGE_TARGET` and `BEGIN_CONTACT`. The targeted follow-up passed **7/7 processes** at `.tools/verification/20261023T141835733242Z/results.json` (`network: false`, Godot 4.7.2).

The legacy `mounted-shooting-reaction` window discriminator now has a focused compatibility regression: a pending legacy-shaped reaction survives save/restore, retains its defender decision ID and can pass through `SELECT_UNIT_CHOICE` to complete the bound attack. Its focused cross-check passed **7/7 processes** at `.tools/verification/20261023T142259750291Z/results.json` (`network: false`, Godot 4.7.2).

The broader workflow sweep found one concrete admission gap: during alternating Deployment, an immediate UnitActions choice such as Vulkan's Seeker of the Unfound had no `priority_player_id` because the registry only derived UnitActions actors from preparation windows or battle reactions. The command service therefore could not accept that choice through its normalized envelope. `UnitActions.actor()` now uses the current deployment squad's owner when a legal UnitActions choice exists, and `pending_decision()` identifies that timing as `deployment:unit-choice`. Vulkan's regression now checks the owner, stable decision/option identity across save/restore, wrong-owner rejection and stale-option rejection before resolving through the public service. This closes the discovered implementation gap.

The same sweep migrated the remaining player-choice tests that called `UnitActions.apply()` directly to the public command service. The remaining direct unit-choice calls are in full UI/demo integration tests (`game._apply_unit_action`), not domain test bypasses. The combined cross-check of these migrations, the deployment decision, Headhunter and Emergency Disembark, and the command/pending/frame gates passed **19/19 processes** at `.tools/verification/20261023T143422584566Z/results.json` (`network: false`, Godot 4.7.2).

## Count and boundary

- **10/10 registered decision-source families** have a public command route and a focused regression in the audited set.
- **0 missing command dispatchers** were identified at the source-family level.
- `UnitActions.supported_window_kind` admits **53 window-kind discriminators**. They include setup windows, phase boundaries and action continuations; this is the finite internal window inventory, not a count of missing bugs. The workflow map below links stateful choices to their owning frame family; setup-only choices use their own persisted preparation stage.
- A static regression-name sweep now finds **0/53 window discriminators without a matching test reference**, including Headhunter and Emergency Disembark after their explicit kind assertions were added. This is only a coverage index; it does not prove that all paths, options or transitions for those windows are behaviorally covered.
- **0 direct `UnitActions.apply`, `Combat.unit_action` or `C.unit_action` calls** remain in non-network rule tests; the remaining unit-choice calls use full UI/demo integration helpers.
- A continuation audit found that the Repulsor Combat Embarkation regression also entered and resumed charge placement through direct combat methods. It now uses public `BEGIN_CONTACT` and `CHARGE_TARGET` commands and checks the same suspended charge frame across save/restore, the defender's response and resumed placement.
- **Open A2 implementation/workflow gaps in this bounded local scope: 0 currently known.** The deployment-actor defect found during the sweep is fixed and covered. All 10 decision-source families have routes and focused regression, all 53 window discriminators map to contextual test references, and the 8 persisted frame families have continuation evidence in the mapped suites. The A2 scope does not certify every profile/option interaction, full rules coverage or network/LAN behavior. Preparation-only decisions advance their persisted setup stage and do not require a combat resolution frame.
- Network/LAN evidence remains deferred; this audit is local only.

## Continuation workflow map

The runtime currently uses **8 resolution-frame kinds**. The frame kind is the continuation category; individual `resume_point` values are internal substages, not separate user workflows. This map groups the currently supported interruption paths and points to the focused local suites. It is a traceability map, not a claim that every rules option in each family is certified.

| Frame family | Supported interrupted paths represented in the current suite set | Lifecycle evidence in the regressions | Representative regressions |
|---|---|---|
| `phase-start` | Command doctrine/Oath selection; start-window UnitActions; sequential Fearsome Assault and Adamantine Terror tests | Decision/frame identity, save/restore, premature-close blocking, ordered resumption/completion | `test_combat_doctrines`, `test_oath_of_moment`, `test_reiver_squad`, `test_ironclad_champions`, `test_chaplain` |
| `phase-close` | Command healing/Reanimation; end-of-phase choices; coherency casualties and turn rollover; phase-end Overwatch/Heroic Intervention | Decision/frame identity, save/restore, close blocked until choices settle, resumption/turn rollover | `test_apothecary`, `test_attached_reanimation`, `test_core_reactions`, `test_morale_coherency`, `test_suboden_khan` |
| `unit-action` | Movement rolls/placement, Desperate Escape allocation, post-move reactions, Charge target/contact and Repulsor Combat Embarkation; Rapid Ingress placement | Matching action/frame, save/restore, rejected invalid owner/placement, close blocked, same action resumes | `test_movement_rerolls`, `test_escape_rerolls`, `test_cato_sicarius`, `test_techmarine`, `test_marine_repulsor_combat_embarkation`, `test_unit_reserves` |
| `fight` | Counteroffensive; unengaged Fight and Bladeguard stance before the activation sequence advances | Choice/frame identity, save/restore, Fight close blocked, next activation resumes after choice | `test_core_reactions`, `test_bladeguard` |
| `attack` | Pre-dice declarations/reactions; hit/wound/Hazardous/damage allocation; destruction effects; selected post-attack movement/mark choices | Attacker/defender ownership, frame identity through nested allocation and save/restore, Shooting/Fight close blocked, same attack completes | `test_ironstorm_stratagems`, `test_librarian_phobos`, `test_damage_allocation`, `test_hazardous`, `test_marine_transport_destruction`, `test_land_speeder`, `test_victrix_honour_guard` |
| `shooting-reaction` | Vengeful Stars attacker reaction and the bound retaliatory shot | Bound actor, attack-frame identity, save/restore, close blocked until the reactive attack/pass settles | `test_combat_doctrines`, `test_devastator_brethren` |
| `transport-disembark` | Normal and Emergency Disembark hazard, allocation, placement and confirmation | Passenger/active-player ownership handoff, same frame through serialization, close blocked, transport destruction resumes after confirmation | `test_marine_transport_rules`, `test_marine_transport_destruction` |
| `transport-drop-pod-assault` | Multi-passenger Drop Pod Assault placement and shared parent continuation | Parent/child frame identity through each passenger and save/restore, close blocked until final confirmation, both frames complete | `test_marine_drop_pod` |

As a static cross-check, **49 non-network test files** mention frame state and **40** also reference a public command helper. A contextual token/value scan maps all **53/53** admitted UnitActions window discriminators to test references. These are search indexes; the lifecycle claims in the table come from the representative regression assertions, not from the scan alone. The map covers all eight persisted frame families and the registered decision-source set.

The A2 local workflow audit is complete for the currently supported decision sources and frame families. A mapped regression exercises its named path and does not certify every profile, target combination or official rules interaction. No missing command route, unreferenced window discriminator, direct rule-test bypass or failing regression is currently known in this scope. Network/LAN, full army legality and unimplemented rules remain separate project gates.

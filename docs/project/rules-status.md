# 11e implementation status

Current summary: [support matrix](support-matrix.md), updated 26 October 2026. The default `terrain-11e-v1` central ruin and the Dense ruins in Event Companion layouts A/B/C now have bounded 3-inch first-floor proxies for movement, contact placement, 3D cylindrical-proxy visibility and Plunging Fire. Desperate Escape applies the Core Hazard rule's three-mortal-wound result when every model in a unit is MONSTER or VEHICLE, before and after an optional Command Re-roll. Engaged MONSTER/VEHICLE shooting now respects the own-Shooting-phase target exception, Close-quarters targeting and the BLAST restriction. Event Companion floor dimensions are project-authored approximations; focused local checks and playtesting are pending. Sections below are historical increment reports; their “next” and “pending” statements may have been superseded by later entries. Use [verification](../verification/verification.md) for the current test commands.

## Blade of Ultramar: current enhancements and stratagems (26 October 2026)

Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, defines Armour of Antoninus at 15 points: the bearer has a 2+ Save and Feel No Pain 5+. The local export snapshot `20261021T130623Z` identifies enhancement row `000010633003`, with 37 related datasheets; 23 resolve to current-catalog Marine profiles. The runtime restricts assignment to a non-Epic-Hero Adeptus Astartes Character under Blade of Ultramar and routes Save/FNP through the existing per-model systems. Focused local checks and player-facing review remain pending; no tests or Godot session were run for this expansion.

Oath of Macragge (`000010633004`, 20 points) links to the same 37 export datasheets, of which 23 resolve to current-catalog Character profiles outside the Epic Hero exclusion. Its bearer gains +1 Strength and AP on melee attacks, or +2 while Assault Doctrine is active. The runtime applies this through the existing per-model melee weapon path; focused local checks remain pending.

Veteran of Behemoth (`000010633005`, 20 points) shares the same 37 export datasheets; 23 resolve to current-catalog Character profiles outside the Epic Hero exclusion. The bearer unit gains Sustained Hits 1 on ranged attacks through the shared attack-profile path. All four enhancements now have bounded local runtime paths. Armour of Contempt (1 CP, source row `000010634002`) uses the shared attack-declaration response and binds -1 AP to the triggering enemy’s attacks. Courage and Honour! (1 CP, source row `000010634005`) uses the shared Lance profile path when a friendly Astartes unit is selected to fight. Exemplary Vigilance (1 CP, source row `000010634003`) grants ranged attacks Ignores Cover when a friendly Astartes unit is selected to shoot. Ultramarian Adaptivity (1 CP, source row `000010634004`) assigns one Combat Doctrine to a friendly unit until its owner’s next Command phase. Practical Tactics (1 CP, source row `000010634006`) offers a D3+3-inch Normal Move to an eligible unengaged unit after an enemy ends a move within 8 inches. Tactical Foresight (1 CP, source row `000010634007`) opens a defender response when an enemy targets a friendly Astartes unit; if used, that enemy's attacks against the target have -1 to Wound when Strength exceeds Toughness through its current attack sequence. All six require Blade of Ultramar with Ultramarines Chapter context. Focused local checks remain pending; current official full-rule locators also need confirmation.

**Armour of Contempt**, **Courage and Honour!**, **Exemplary Vigilance**, **Ultramarian Adaptivity**, **Practical Tactics** and **Tactical Foresight** use existing attack-declaration, melee-profile, ranged-profile, per-unit doctrine, post-move reaction and wound-modifier systems. They require current unit abilities and Ultramarines Chapter context; focused local checks, network validation and full army legality remain pending.

Updated 26 October 2026. The Marine detachment references are Wahapedia 11e Space Marines App 2.8.1 and local Data Export snapshot `20261021T130623Z`; the shared modifier uses the [11e Core Rules and FAQs](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/). Exact current full-rule locators, network validation and focused checks remain pending. This status record does not certify a complete supported edition pack or full army legality.

## Transport Hazard update (26 October 2026)

Combat and Emergency Disembark now use the current Core Rules Hazard multiplier: each failed roll causes three mortal wounds when every living passenger model is MONSTER or VEHICLE. Only those two modes roll one Hazard per model; Rapid, Tactical, Assault and Shock do not. When configured and eligible, the passenger owner may use Command Re-roll on one die before allocation. Emergency placement returns to the active player after Hazard allocation is complete. Focused local checks are pending.

## Crushing Impact / Tank Shock update (26 October 2026)

Current Wahapedia 11e Core Rules §15.06 allows a friendly MONSTER or VEHICLE unit to use Crushing Impact immediately after it ends a Charge move. The selected model contributes D6 equal to its Toughness; each 1 causes one mortal wound to the charging unit, then each 5+ causes one mortal wound to the selected enemy unit, to a maximum of six against that enemy. The local path resolves the charging unit's packet first, then the target's packet, through shared allocation, prevention and Deadly Demise continuations. Brutalis Charge retains its additional per-unit use and cost reduction. Focused checks and human playtesting for this expansion are pending; older Tank Shock verification entries below cover the prior Vehicle-only, target-packet behavior.

## Shooting at engaged Monsters and Vehicles update (26 October 2026)

Current Wahapedia 11e Core Rules §17.03 permits ranged attacks against an engaged enemy MONSTER/VEHICLE during the attacking player's own Shooting phase, except with BLAST; attacks suffer -1 to Hit unless they use a CLOSE-QUARTERS weapon and the attacking unit is engaged with the target. An attacking unit already engaged still has to use its eligible Close-quarters shooting and target only units it is engaged with. The shared attack planner now enforces these target boundaries and phase restriction. Focused local checks and playtesting remain pending; broader out-of-phase shooting exceptions are not covered.

## Completed in this increment

- Normal moves permit transit through engagement range, with enemy-base collisions still enforced. Each staged segment is provisional; confirmation requires the whole squad to be unengaged and coherent. A draft ending engaged stays editable or can be cancelled.
- Coherency checks connectivity in addition to neighbour distance and maximum separation. Flat-board geometry remains a limitation.
- End-of-turn coherency casualties are chosen by their owner, one model per authoritative request. The UI exposes the removal button and acting player; the turn cannot advance until both squads are coherent. A rules implementation version bump rejects older clients.
- Command battle-shock uses host-rolled 2D6 against Leadership, with inclusive half-strength checks and single-model wound thresholds. Already battle-shocked units test even above half strength. Successful Command tests clear status; changing turns alone does not.
- Effective OC and morale-only action/stratagem eligibility queries respect battle-shock. The latter are foundations for future systems, not complete action or stratagem implementations. Morale does not by itself block ordinary movement, shooting, or charges.
- Missing/invalid dice and invalid commands leave match state unchanged. Dice results and morale status replicate in host snapshots.

Tests: `test_individual_movement.gd`, `test_morale_coherency.gd`, `test_morale_network.gd`, and existing attack/combat/melee and tactical-guide checks.

Validation on Windows: movement, morale/coherency, attack sequence, attack lab, combat scenario, melee, tactical guides, demo rules and data-pack tests passed. Two-process loopback checks passed for morale/coherency, movement, shooting and melee. The new casualty-selection and battle-shock panels were rendered and visually checked. Linux and separate-machine LAN remain unverified.

## Next movement increment completed

Advance, Assault shooting eligibility, Ordered Retreat, Desperate Escape, and stationary selections are now available through the UI and host/client commands. Infantry hazard wounds use owner allocation with wounded-model priority; failed placement can be reset while retaining rolls and casualties. Successful moves apply turn-long shooting, charge and action restrictions. A steady squad completing Desperate Escape tests battle-shock. See [movement choices](../rules/movement-types.md) for controls and limitations.

`test_movement_types.gd` covers dice validation, retained rolls, movement budgets, mode eligibility, enemy-base traversal, mortal-wound allocation, post-move morale, failed moves and turn restrictions. `test_movement_types_network.gd` covers guest controls, synchronized rolls/budgets, casualties, post-escape morale and stale requests.

Windows validation passed for both new tests and the existing rules/combat/UI checks. Five host/client loopback suites passed: movement types, ordinary movement, shooting, melee and morale/coherency. The movement selector, rolled Advance budget, and escape damage controls were rendered and visually checked. Linux and separate-machine LAN remain unverified.

## Contact movement increment completed

The normal UI now uses charge-target selection and editable per-model paths rather than automatic destinations. Multi-target charge validation is available in the rules API, while the exercise still fields one opposing squad. Charge confirmation, optional pile-in, additional overrun pile-in, and enemy-directed consolidation share accumulated budgets, connected coherency and collision checks. Base-contact locks, retained engagements, and immediate fights after consolidation are enforced. Cancel restores placement and retains charge dice.

Approach exceptions now use the bounded certification described below. Some complex placements remain conservatively restricted. Objective consolidation and general multi-squad fight queues remain unimplemented. The old sampled assist is used only by legacy fixtures and also passes final validation.

`test_contact_actions.gd` covers manual paths, retained rolls, multi-target charges, overrun, base contact, approach checks and consolidation reactions. `test_contact_network.gd` covers guest target/placement controls, cancellation, pile-in, combat, consolidation, and invalid/stale requests.

Windows validation: seven local rules/UI suites passed, along with six host/client loopback suites (contact, melee, ordinary movement, movement types, shooting, and morale/coherency). Charge target selection, manual placement and base-contact pile-in controls were rendered and visually checked. Linux and separate-machine LAN remain unverified.

## Approach exception certificates

The host now accepts terrain detours and global coherency exceptions when a relaxed reachability/placement analysis proves the requested approach impossible. The analysis allows teammates to rearrange, respects base-contact locks and retained engagements, checks every live target model, and never treats search exhaustion as proof. Charges independently check 1-inch and engagement duties. Certificate details and human-readable reasons synchronize with match snapshots/events. See [contact reachability](../rules/contact-reachability.md) for the mathematical relaxations and remaining limits.

New tests: `test_contact_reachability.gd` and `test_contact_exceptions_network.gd`. Four local suites passed (certificates, contact actions, melee, tactical guides), as did three host/client loopback suites (exceptions, manual contact, melee). Accepted exception details were rendered and visually checked in the event log on Windows. This does not claim exhaustive certification: enemy-base obstructions and complex unresolved arrangements can still be conservatively rejected. Linux and separate-machine LAN remain unverified.

## Remaining implementation order

1. Expand contact certificates for remaining obstructions/arrangements, add objective consolidation with the objective system, and generalize fight/reaction queues beyond the two-squad exercise.
2. Extend the bounded central first-floor Movement slice to Event Companion floors, vertical Charge/contact movement, plunging fire and exact imported-model visibility.
3. Add objectives, control and secured objectives, mission setup, actions, battle-round triggers, scoring and victory. Use effective OC, morale and move/shoot restrictions in these systems.
4. Add stratagem timing, costs, eligibility and reactions, then faction/unit abilities for the two starter squads with verified profiles.
5. Expand attack allocation to defender choices, mixed profiles and attached characters; generalize the infantry escape mortal-wound implementation to other sources, remaining weapon mechanics and damage prevention.
6. Add reserves, transports, flying, vehicles/monsters, aircraft, legal army construction and deployment, and edition/update configuration.

Each increment needs deterministic rules tests and applicable UI/network checks before it is presented as supported. The original movement demo in `scripts/rules.gd` intentionally remains a separate prototype.

## Ground terrain increment completed

The default combat map now includes exposed, light and dense terrain with feature heights and per-model traversal permissions. Cover worsens BS by 1 and splits shooting pools per attacker. Hidden, firing history, detection, Obscuring and Gone to Ground synchronize through host snapshots. The renderer and tactical guides use the same layout. [Terrain documentation](../rules/terrain.md) explains the cylindrical visibility proxies and geometric limits.

Eleven local rules/UI suites and eight host/client loopback suites passed on Windows, including new terrain and terrain-network tests. Old solid-map fixtures retain their assertions by explicitly selecting the legacy map. A bounded central first-floor movement slice is now implemented for Infantry, Beasts, Swarm, FLY and equipped Reivers; its focused checks remain pending. Event-layout floors, vertical Charge/contact transitions, plunging fire and exact imported-mesh visibility remain open. Objectives, control and scoring are the next major gameplay increment. Linux and separate-machine LAN remain unverified.

## Objective control and training increment completed

Core terrain-objective control now resolves at phase boundaries, with effective OC, battle-shock, ties and secured-objective retention/loss. A separate custom training mission awards 1 VP per controlled objective at round end and finishes after five rounds with a win or draw. Its configuration, control, scores and result synchronize through the host. Securing remains an internal effect for future verified abilities, not a free player action. See [objectives](../rules/objectives.md).

Eleven local rules/UI suites and four host/client suites (objectives, terrain, shooting and melee) passed on Windows. The training panel and objective outlines were visually inspected. The runtime now includes a bounded Chapter Approved 2026-27 mission profile; random mission/deck selection, other deployment configurations, actions outside this profile and full objective/mission coverage remain pending. The newest fixed-secondary expansion awaits local focused checks. Linux and separate-machine LAN remain unverified.

## Objective consolidation increment completed

Unengaged eligible squads now consolidate toward a selected objective when no enemy is within 3 inches. Enemy modes retain priority. The host checks the 3-inch per-model path budget, terrain, collisions, coherency, objective approach and an unengaged finish with at least one model in objective range. The UI provides an objective selector and the guides name the chosen target. Cancellation restores origins; final confirmation does not capture an objective until the phase boundary.

Six local rules/UI suites and four host/client suites passed on Windows. The objective-consolidation panel and guides were rendered and inspected. The objective mode currently requires a moved model to reach objective range whenever the direct geometric lower bound permits it within 3 inches: obstacle/coherency exceptions for this mode are not certified, so some legal arrangements remain conservatively rejected. Enemy-contact certificates continue unchanged.

The player battlefield builder is deferred at low priority in the [future backlog](backlog.md). Next rules work: actions and their phase timing, then multi-unit fight/reaction queues and verified mission/unit abilities.

## Action lifecycle increment completed

Core action eligibility and same-turn lifecycle are integrated with host commands, phases, movement, morale and casualties. Action starts retain shooting/charge restrictions through failure or completion until turn end, including the Titanic shooting exemption. Pile-in and consolidation do not interrupt actions; accepted other moves, battle-shock, destruction or leaving the battlefield do. Cancelled placement drafts do not count as committed moves.

Custom training now offers Secure Ground: start in your Shooting phase with an eligible unit controlling an objective from within range, once per army per turn; complete at End of Turn if still controlling it from within range, securing the objective. It grants no direct VP. See [actions and limits](../rules/actions.md). Official mission actions, cross-turn schedules and eligibility overrides remain future work.

Ten local suites and five host/client loopback suites passed on Windows. Action progress/completion panels were rendered and inspected. Next priority: multi-unit fight/reaction queues. The battlefield editor remains deferred at low priority. Linux and separate-machine LAN remain unverified.

## Multiple-unit training and Fight queues completed

The optional two-unit-per-player training mode fields four real units and 30 models. Unit IDs are independent of player IDs. Initial pile-in and consolidation decisions are tracked once per unit, active army first; fight selection alternates owners and enforces the current Fights First pool. Overrun commits the activation to the moved unit. All unfought enemies contacted by ongoing/engaging consolidation enter a mandatory reaction queue; the opponent chooses their order before consolidation resumes. Elimination checks the entire army, not a single destroyed unit.

The UI lists eligible units and mandatory reactions, accepts selected-unit declines and provides an enemy contact-target dropdown. Roster size and queue state synchronize through the host. See [multiple units and limits](../rules/multiple-units.md).

Thirteen local rules/UI suites and five host/client loopback suites passed on Windows. The 30-model battlefield and multiple-reaction panel were visually inspected. Split attacks across targets, mixed profiles, innate abilities, stratagems, army construction and deployment remain pending. The next combat increment is explicit attack allocation across multiple targets. Linux and separate-machine LAN remain unverified; the battlefield builder remains low priority.

## Per-model attack plans completed

The host now accepts complete per-model plans across several target units. Ranged weapons retain a single target per weapon; a melee weapon can split its fixed A between eligible engaged units, requiring all attacks from every eligible melee model. Plans validate before dice; targets, range, visibility, Rapid Fire and cover freeze before casualties. All pools against one target resolve before the next declared target. Excess attacks never redirect. Damage and activation commit once for the entire plan, with rollback of match state on any pool failure.

The UI supports per-model target/count assignment, replacement, clearing, local cancellation and confirmation. Right-click single-target shortcuts use the same validator. Snapshot results and the event log record target-specific pools and declared assignments. See [attack plans](../rules/attack-plans.md).

Fifteen local rules/UI suites and six host/client loopback scenarios passed on Windows, including ranged/melee plan editing and confirmation, repeat rejection and combat/terrain/queue regressions. The editor and result log were visually inspected. Mixed weapon/profile selection, random A, Extra Attacks, defender choices and attached characters remain pending. Next combat work: defender allocation and mixed profiles. Linux and separate-machine LAN remain unverified.

## Defender-selected damage increment completed

New matches can enable defender-selected damage within the current homogeneous, non-character group. Saves resolve lowest first; successful saves are automatic and damaging results pause for a defender model choice, prioritizing wounded models. Other commands and queue advancement remain blocked until the whole attack plan completes. Damage applies per accepted choice, excess is discarded, current/future pool state retains frozen targeting, and invalid commands or later dice failures do not lose previous accepted choices. The automatic allocation assist remains available and explicitly labeled.

The next-match setting participates in compatibility checks. Pending rolls, model choices and completion synchronize through host snapshots, including a guest disconnect/rejoin during allocation. See [defender allocation controls and limits](../rules/defender-allocation.md).

Seventeen local rules/UI/lab suites and eight loopback scenarios passed on Windows. Allocation and wounded-priority panels were rendered and inspected. Mixed allocation groups, attached characters, damage prevention and allocation-triggered abilities remain unsupported. Next combat work: mixed weapon/profile selection. Linux and separate-machine LAN remain unverified; the battlefield builder remains low priority.

## Equipped weapons and profile selection completed

An optional varied training roster now gives models server-owned weapon instances and supported profiles. The planner selects per-model weapons/profiles, permits multiple ranged weapon instances, enforces one target/profile per ranged instance and one ordinary melee weapon per model, and uses the selected melee A. Bolt Rifle profiles, Krak launcher, chainsword and alternating Gauss Flayer/Reaper equipment come from the starter import. The roster remains curated practice data, not validation of legal army equipment options.

Range, Assault eligibility, Heavy and Rapid Fire apply to each selected profile. Supported mechanics expand before pooling identical attack properties; unsupported raw mechanics reject before dice. Both automatic and defender-choice allocation preserve the selected weapon identities. Equipment mode enters the compatibility hash and inventory replicates in snapshots. See [equipment controls and limits](../rules/equipment.md).

Eighteen local suites and seven loopback scenarios passed on Windows. Ranged/melee selectors and review panels were visually inspected, including switching between models with different equipment. Next weapon work: Blast, random A/D, Hazardous and other currently unavailable mechanics. Close-quarters, Hunter restrictions, Extra Attacks, Devastating Wounds, mixed defending groups and attached characters remain unsupported. Linux and separate-machine LAN remain unverified; the battlefield builder remains low priority.

## Blast and random characteristics increment

Frag is available on the curated launcher. Blast uses declared target size; bounded ranged random A is generated per weapon, and random D is rolled after allocation per damaging attack. Results retain raw dice and generated characteristics. Random melee A, Hazardous and Close-quarters profiles remain blocked. See [weapon mechanics](../rules/weapon-mechanics.md) for controls, validation and remaining scope. Protocol bumped to v16.

## Hazardous and infantry Close-quarters completed

Plasma Standard/Supercharge is available on the first Intercessor in each curated squad. Infantry sidearm selection and engaged Close-quarters targets are checked per model. After all attack pools, Hazardous rolls once per selected weapon, with owner-selected mortal wounds before activation, fight queues or elimination complete. Snapshots preserve hazard rolls and choices across reconnection. Protocol is v17.

Twenty-two local suites and seven loopback scenarios passed on Windows, including Hazardous owner allocation/rejoin and ranged/melee equipment, defender allocation and attack-plan regressions. Plasma and Hazardous controls were visually inspected. See [controls, validation and scope](../rules/hazardous.md). Next weapon work: Hunter restrictions and Extra Attacks, then Devastating Wounds. Full MONSTER/VEHICLE shooting exceptions, damage prevention, attached units and mixed defending groups remain unsupported; battlefield editing stays low priority.

## Hunter and Extra Attacks completed

Hunter profiles now restrict targets using imported keyword alternatives, with client filtering and host validation before dice. Extra Attacks now supports all eligible additional melee weapon instances alongside one ordinary weapon, full A per selected profile, independent target splits, extra-only inventories and physical-weapon Hazardous counting. Editing an ordinary weapon preserves extra assignments, and identical instances have numbered choices. Malformed/conflicting restrictions and unimplemented conditional parameters are rejected.

Twenty-three local suites and nine host/client loopback scenarios passed on Windows, including new multi-weapon UI/host checks in automatic and defender-choice modes. Hunter and Extra Attacks planning controls were visually inspected. Protocol is v18. The existing practice roster is unchanged; actual imported Chainfist and servo-arm profiles are exercised in synthetic test fixtures, and Hunter is inspectable in the attack lab. See [controls and scope](../rules/weapon-selection.md).

Next combat work: Devastating Wounds. Random melee A, full MONSTER/VEHICLE shooting exceptions, damage prevention, mixed defending groups and attached units remain pending. Battlefield editing stays low priority.

## Devastating Wounds completed

Critical wound rolls now create no-save mortal packets, resolved after the same identical-attack pool's normal damage. Each critical damages at most one defending model; excess is discarded. Both automatic assist and defender-choice allocation follow this order, with random D rolled after recipient selection and pending steps preserved through reconnection. Hazardous follows all attack damage before activation or fight queues complete. Lethal automatic wounds do not trigger critical-wound effects.

The first Intercessor's curated melee inventory now includes the imported Thunder Hammer as an ordinary weapon alternative. The planner, defender panel, result log and isolated lab expose its behavior. Protocol is v19. Twenty-four local suites and ten loopback scenarios passed on Windows, including a new normal-to-mortal allocation/rejoin scenario. Hammer and mortal-allocation controls were visually inspected. See [controls, rules and limits](../rules/devastating-wounds.md).

Next combat work: Feel No Pain and wound prevention. Mixed defending groups, attached characters, Precision, random melee A and full MONSTER/VEHICLE shooting exceptions remain pending. Battlefield editing stays low priority.

## Advanced defense and allocation completed

Implemented assigned Feel No Pain profiles for normal damage, Devastating Wounds, Hazardous and escape mortals; Monster/Vehicle shooting and sidearm exceptions; random melee A against a single target; mixed W/Sv/InSv defensive groups; attached-unit combat profiles; and Precision. The host now obtains group order before rolling saves, checks each group's actual save after casualties, and preserves attacker Precision choices, defender decisions and prevention rolls in reconnectable snapshots. Attached characters remain one unit after bodyguard destruction, and per-model Leadership/OC are retained.

Added **Start rules lab: mixed defense / Precision**, an explicitly synthetic teaching scenario for these mechanics. It is usable locally and with both peers selecting the same lab before connecting. Scenario-construction helpers can form practice attachments while preserving individual profiles and combined starting strength; official army/MFM attachment permissions and general leader/aura abilities remain disabled.

Protocol is v21. Thirty local suites and fifteen loopback scenarios passed on Windows. New checks include group-order and prevention rejoin, actual UI flow for Precision/decline, Monster/Vehicle modifiers, random melee editing, per-component attached profiles, and the new practice scenario. The allocation panels were rendered and visually inspected. See [current controls, state and limits](../rules/advanced-defense.md).

The user authorized continuation of the roadmap without per-increment approval. Remaining work includes random-A melee splitting, remaining weapon keywords/damage modifiers, conditional and propagated unit abilities, reserves/transports, official missions/stratagems and more complete geometry. Battlefield editing remains low priority. This is still a partial 11e implementation, not a certification of all official rules or army construction.

## UI clarity roadmap and first context summary

The user requested UI and game-information clarity as a roadmap priority. Added a near-term UI workstream in backlog.md: separate setup from gameplay, keep turn/decision context visible, contextual controls with blocked-action explanations, compact model cards, guided attack/defense choices and readable results.

First increment adds a top-of-sidebar summary with readable phase, round and actual decision owner, including opponent-owned decisions during the active player's turn. It explains required Precision, defense order, damage, Hazardous, contact placement and coherency steps, waiting for a peer and finished exercises. This summary currently scrolls with the sidebar; a persistent HUD and full panel reorganization remain scheduled. No combat or protocol change.

Validation: headless main-scene startup, allocation-practice UI, mixed defenders/Precision and weapon-selection suites passed. A targeted UI-context smoke check passed for preview, shooting, Precision, defender group order, host waiting and completion. Full visual layout review and separate-machine LAN were not performed for this increment.

## Setup/gameplay separation and persistent context completed

Split the main sidebar into Match setup and Play tabs with independent scrolling. The round, phase, actual decision owner, connection identity and custom-training VP/objective ownership remain outside the scroll containers. Starting combat automatically opens Play; returning to preview opens Match setup. Ordinary refreshes preserve manually selected tabs. Existing controls, host authority and protocol v21 remain unchanged.

Validation: headless startup and four local suites passed (new gameplay layout, allocation practice, attack plans and tactical guides). Layout checks exercise tab transitions, deliberate setup access during combat, long-content scrolling with fixed decision/score positions and scoreboard visibility for objective versus elimination exercises. Setup, objective play and scrolled rules-lab screens were rendered and visually inspected at 1280x800 on Windows. No new network or Linux validation in this UI increment.

Next UI item: group controls by the current action and explain unavailable actions. Compact model cards, guided attack/defense flows and result/log cleanup follow. Core-rule implementation remains part of the roadmap; battlefield editing stays deferred.

## Local ForceOrg / TTS visual import baseline completed

Added Models / Import as a third sidebar tab. Players can scan their own ForceOrg.json or TTS saved army/object, inspect nested objects and alternate states without executing Lua, load a local text OBJ and optional diffuse image, preview scale/rotation/height, and save/remove the visual for the selected unit definition. Local mappings persist in user://local-models.cfg with source identity and source/mesh/texture fingerprints. No third-party models or source scripts are included in the runtime; the game performs no remote acquisition. Missing, changed or unsupported files fall back to placeholders. Imported meshes do not replace authoritative bases, geometry, rules, snapshots or protocol v21.

Inspected upstream downloader source: it installs ForceOrg.json and ForceOrg.png into the selected TTS Saves directory, not a complete offline mesh collection. The current adapter requires the player to choose the local OBJ/image explicitly. Automatic cache matching, Lua-generated catalog expansion, per-model visual variants, GLB, MTL/normal-map handling and AssetBundle conversion remain outside this baseline.

Validation: five local suites passed (local model import, gameplay layout, allocation practice, attack plans and tactical guides). New coverage includes OBJ/UV/texture parsing, malformed and missing files, duplicate names and alternate states, persisted settings/replacement, invalid transforms, changed-file fallback, unit-type rendering and unchanged match state. The scanner also processed the previously obtained 43 MB backup: 3,245 objects and 60 mesh/bundle entries. Preview and board rendering were inspected at 1280x800 with an original synthetic OBJ; corrected long dropdown names expanding the sidebar. Actual third-party miniature appearance, Linux and a separate-machine client remain unverified. See forceorg-import.md for usage and current limits.

## Local cache lookup increment completed

Models / Import can now index a player-selected local Mods/cache directory and find OBJ/diffuse candidates by complete URL-derived filenames, including extensionless files and the verify-cache prefix. Unique complete matches load the preview; duplicates, missing declared textures and unsupported bundles require manual resolution. Lookup does not download files or save/apply a unit mapping. The folder setting persists alongside existing version-1 mappings. Switching objects or starting a failed lookup clears stale files/previews. Scan limits and ambiguous candidates are reported next to the lookup controls; directory links/hidden entries are skipped and partial scans are never used after a limit/error.

Six local suites passed: cache lookup, local models, gameplay layout, allocation practice, attack plans and tactical guides. The synthetic cache lookup UI was rendered and inspected at 1280x800. Real ForceOrg/TTS cache naming variants, Lua-generated collections, Linux and separate-machine peers remain unverified. Protocol and gameplay state are unchanged. See forceorg-import.md for instructions and precise naming/scope restrictions.

## Contextual action groups and blocking guidance completed

Play now groups movement/coherency, charge/contact, attacks, attack/damage resolution, objectives and phase progression. Empty groups hide; pending movement/contact/allocation/coherency decisions and attack editing focus their own group while preserving explicit cancel/decline actions. Adjacent explanations and tooltips reuse movement/attack/allocation/objective validators and existing charge/contact eligibility checks. Opponent decisions and host waiting identify who must act. Plan/selection changes clear stale blocking explanations.

Corrected a presentation ambiguity: with no selected model, Direct Precision no longer accepts the -1 decline command. The separate Do not use Precision control retains that behavior. Combat validation, network snapshots and protocol v21 are unchanged.

Ten local suites passed: action guidance, gameplay layout, allocation practice, attack plans, local models, cache lookup, individual movement, contact actions, multiple units and mixed defenders. The new suite checks exclusive views, cancel/decline availability, live blocking errors and unchanged gameplay state. Shooting and Precision panels were visually inspected at 1280x800. Separate-machine LAN and Linux were not newly verified. Next UI item: compact unit/model selection cards with expandable technical detail. See gameplay-ui.md.

## Compact selection card completed

Play now shows a compact selected-unit/model card with owner, surviving model count, model wounds, individual defenses, morale/OC and assigned FNP. Movement remaining and active objective actions appear when relevant. Equipment and the existing technical summary are collapsed behind Show equipment and technical details; expansion survives refreshes/selection changes. Mandatory allocation/group profiles and fight/contact/movement decisions remain in an independent visible area. Existing match state and protocol are unchanged; raw combat-event/dice log cleanup remains scheduled separately.

Six local suites passed: selection card, action guidance, gameplay layout, allocation practice, local models and cache lookup. New checks include per-model mixed defenses/FNP, expansion, stale/destroyed selection, mandatory choices and group profiles with details collapsed, and no state mutation. Selected-model and Precision screens were visually inspected at 1280x800. New network/Linux validation was not performed. Next: guided attack/defense flows and result/log cleanup.

## Guided attack and defense baseline completed

The attack planner now explains selection, weapon/target assignment, repetition and review/confirmation as numbered steps. It names the selected unit/model, summarizes assignment and target counts, and lists target resolution order. Confirmation explicitly rolls/resolves; cancellation retains its existing local-draft behavior. Long weapon/target names no longer force dropdown/sidebar expansion.

Precision, defense group ordering, damage and Hazardous choices now show stage-specific instructions and the responsible player. A named eligible-model picker includes unit identity and wounds, synchronizes with board selection, and never commits a decision by itself. The prompt resets selection without invoking Precision decline. Host authority, save revelation order and protocol v21 remain unchanged.

Six local suites passed: guided attacks, action guidance, selection card, allocation practice, attack plans and mixed defenders. Planner/Precision screens were visually inspected at 1280x800. Separate-machine LAN and Linux remain unverified. Next UI work: readable results, notices and expandable combat/dice logs; broader accessibility/window-size validation remains scheduled.

## Readable results and expandable history completed

Latest notices now appear before selection/actions. A last-completed-attack summary aggregates each defending target across weapon pools and separates applied damage, models destroyed, FNP prevention and discarded excess. Hazardous self-damage/prevention/discarded wounds appear separately. If another attack is pending, the earlier completed result is explicitly labeled; pending hidden rolls are not used to fabricate a finished outcome.

Combat history and raw dice are collapsed behind Show combat history and dice. Expansion persists across refreshes, and unchanged content no longer resets the reader's log scroll. Existing logs and host-owned outcomes remain available; match state and protocol v21 are unchanged.

Six local suites passed: combat results UI, guided attacks, selection card, action guidance, gameplay layout and allocation practice. New tests include a complete synthetic attack, actual prevention/excess totals, separate Hazardous reporting, pending-result labeling, hidden/expanded dice, scroll preservation and stale-result clearing. Summary and expanded-history screens were visually inspected at 1280x800. No new Linux or separate-machine network validation. Remaining UI work includes accessibility/window-size/host-client-rejoin checks, keyword explanations and terminology review.

## Initial Incursion testing baseline

Applied the user's requested initial scenario: Incursion with a 1,000-point target per army on a 43x43-inch board. Main-scene combat/objective/rules exercises use state-driven board dimensions, whole-base movement/contact boundaries and matching rendered grid/borders. Preset identity enters the pack compatibility hash and is consistent across offline/host/rejoin factories. Legacy movement-only fixtures keep their original default board.

The 1,000-point value is scenario metadata, not army-construction validation. Current practice armies and terrain remain training content; no official mission, deployment zone or roster legality is implied. The UI displays the size/points and unvalidated-roster status. See initial-test-scenario.md for remaining scenario work.

Six local suites passed, plus one host/client loopback allocation scenario with rejoin and synchronized battlefield/points checks. The 43x43 board and scenario label were visually inspected at 1280x800. Separate-machine LAN/Linux remain unverified.

## Real ForceOrg models validated

At the user's request, downloaded the official manual ForceOrg save and three sample mesh references for local testing. No downloader EXE or TTS installation was required. Real testing exposed and fixed missing static objectJSONs catalogs, missing ChildObjects components, an inadequate object-count bound, lack of search for the expanded collection and extension-based image decoding that failed on a JPEG cached as .png. Static JSON is read as data without executing Lua; names/credits and entry identities survive filtering. Scanner now reports 35,936 objects, 32,256 mesh/bundle entries and 10,605 static embedded objects for the tested save.

Two Intercessors and one Necron component passed real OBJ/texture preview, board application and persistence. Installed their local visual mappings in this game's default user profile and verified a fresh launch. All downloaded third-party files remain in ignored .tools/forceorg-real; none is bundled into source/distribution. Six local suites and one host/client loopback/rejoin scenario passed. Real previews and board renderings were visually inspected. Full evidence and precise unsupported paths are in model-import-validation.md. This does not certify every model or composite/AssetBundle; actual TTS-generated cache variants, Linux and separate-machine LAN remain unverified.

## Explicit selected-model downloads implemented

At the user's request, added Baixar arquivos deste modelo with a local destination, progress and cancellation. It fetches only the selected OBJ and optional diffuse HTTPS references; TTS/cache is no longer required. Scanning/searching stays offline. Downloads have size, timeout and redirect limits, validate content before promotion, keep content-versioned files and load only the preview. Unit mappings still require explicit confirmation. The destination persists in local settings; the optional cache lookup recognizes this library naming scheme.

Seven local suites passed, plus actual Marine/Necron HTTP downloads through the in-game button and cancellation of a real transfer. Real testing found a Windows open-handle rename failure; the request/file handles are now released before promoting/cleaning partial downloads. The UI was rendered and inspected at 1280x800. Unsupported AssetBundles, full composite assembly, Linux and separate-machine peers remain outside this validation. No background bulk acquisition or inter-player asset transfer was introduced.

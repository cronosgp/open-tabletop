# Architecture direction

Status: target architecture for the incremental refactor started on `refactor/architecture-foundation`. This document does not claim that the current code already has these boundaries.

## Product constraints

- The target is the complete, current Warhammer 40,000 11th-edition rules and content scope, including every faction, unit, ability, mission and player-created battlefield.
- One player's desktop process is the authoritative host. LAN and direct internet connections are supported without a project-operated game server or account service.
- The project remains free and open source. Rules references, points, catalogs and visual assets retain their source and distribution boundaries.
- One shared, flexible battlefield is used while rule and mission coverage grows. The player-facing battlefield editor is the last implementation milestone.

## Target ownership boundaries

| Boundary | Owns | Must not own |
|---|---|---|
| Rules kernel | Deterministic validation and state transitions for edition-specific commands; dice requests; timing windows; rule effects | Godot controls, network transport, provider API records |
| Content catalog | Versioned datasheets, weapons, abilities, points, detachments and source provenance; capability and validation metadata | Executable downloaded prose, UI nodes, authoritative live state |
| Match orchestration | Match setup, immutable manifest, command routing, actor/revision checks, effect sequencing and host authority | Rendering and direct access to peer-supplied state mutations |
| Transport | Host/guest connection, reliable command/snapshot delivery, identity of the connected seat and reconnect lifecycle | Rules decisions, dice outcomes, profiles or legality decisions |
| Persistence and journal | Versioned snapshots, event history, integrity checks and migrations | Reconstructing unsupported rules by guessing from a newer catalog |
| Presentation | Setup, army workshop, battlefield display, decisions, accessibility and contextual explanations | Being the source of rules truth or declaring legality independently |
| Battlefield and mission data | Dimensions, terrain geometry, deployment, objectives and scoring parameters | Implicit assumptions hidden in renderer-only coordinates |

These are dependency boundaries, not a requirement to split the Godot project into plugins or services. The first implementation can remain a single desktop application.

## Current structural seams

- `scripts/edition_11/phase_progression.gd` exposes the five player-facing phases separately from internal `start_turn`/`end_turn` progression steps, and owns turn rollover/reset. `scripts/edition_11/phase_resolution.gd` sequences start/end effects after common admission; `combat_scenario.gd` remains the compatibility facade and owns fight-specific action advancement.
- `scripts/edition_11/phase_close_gate.gd` centralizes common command admission and existing blockers for close requests, including in-progress movement, charge, contact, transport placement and reactive shooting. It also refuses close requests with an unresolved frame unless that frame is the matching phase-close continuation re-entering the gate. `phase_resolution.gd` sequences phase-boundary work and persists a LIFO continuation frame when an end-of-phase decision suspends the close request. Movement drafts and pre-placement roll/stratagem windows persist action frames through confirmation, editable normal-move cancellation, or failed Fall Back; resetting locked movement placement keeps the frame open. Charge frames span optional pre-roll decisions, roll reactions, target selection, contact placement and immediate post-charge effects. These are initial workflow migrations, not a universal action lifecycle.
- `scripts/edition_11/match_actor.gd` resolves command priority from mission, setup, reaction and allocation windows separately from active turn ownership. Domain modules provide those windows; the actor resolver owns their precedence.
- `combat_doctrines.gd`, `stratagems.gd`, `reanimation_protocols.gd` and `damage_allocation.gd` expose their active choices through normalized pending-decision projections; their existing validators remain authoritative. Reanimation projects model placement intent while leaving the coordinate to the domain validator. Damage allocation projects attacker-owned Precision choices and defender-owned allocation choices. `UnitActions` projects phase-start/end and other active unit-ability or preparation windows with legal options. `match_actor.gd` consumes projected owners for command priority, and `phase_close_gate.gd` uses those projections to block progression.
- `scripts/edition_11/match_command_service.gd` executes gameplay commands for deployment, model placement, reactions, damage/coherency allocation, preparation choices, movement and contact workflows, charge, shooting, attack plans, fights and mission-action starts against the rules facade. It centralizes the shared projected-decision owner, identity and option-envelope checks while domain modules retain authoritative rule validation. It returns plain outcomes; `main.gd` keeps RPC admission, broadcast and player feedback. Legacy non-combat exercise movement remains on its existing path.
- `unit_actions.gd` now surfaces eligible core and detachment reactions in an open end-of-phase choice window. `core_reactions.gd` can preflight timing eligibility before that window is created.
- `scripts/edition_11/match_manifest.gd` builds match identity without preloading the combat orchestrator. The rules implementation identity has its own small module.
- `scripts/edition_11/leader_catalog.gd` owns read-only leader identity facts shared by abilities, actions and attachment setup. It stays below those modules in the preload graph, avoiding the previous rules-to-setup cycle.
- The prior rules preload cycle was removed: doctrine queries now depend on the low-level `unit_ability_catalog.gd`, and objective control calculations are passed into objective queries by their caller. `tests/test_architecture.py` checks that the edition rules preload graph stays acyclic. The large scene/controller in `scripts/main.gd` remains a separate migration task.
- The root RPC adapters now ask `scripts/network/match_session.gd` whether a sender owns the admitted guest seat; `main.gd` no longer repeats direct sender-ID comparisons. Focused verification also runs the static architecture and verification-runner tests so boundary regressions are caught during a narrow iteration.

## Authoritative command flow

1. A client submits an intent with its seat, expected match revision and selected identifiers.
2. The host checks the seat, phase/window, revision, eligibility and content manifest.
3. The rules kernel resolves the command and requests host-owned dice where required.
4. The host records accepted choices, dice and state changes in the journal, then sends the new revision/snapshot.
5. Both clients render the resulting state. Clients never submit profiles, damage results, random results or replacement match state.

The current game already follows much of this pattern. `scripts/network/session_transport.gd` owns ENet peer creation, offline reset and connection-signal forwarding. `scripts/network/seat_handshake.gd` owns challenge/proof protocol decisions. `scripts/network/match_session.gd` owns host/guest seat state, admission, disconnect lifecycle and transactional reservation around the snapshot callback. `scripts/main.gd` retains the RPC endpoints and supplies the persistence callback; preserve those root RPC paths until both peers can negotiate a versioned endpoint manifest.

## Match identity and versioning

Before gameplay, the host builds an immutable manifest containing at least:

- edition and core-rule implementation revision;
- each content pack's identity, source revision, content hash and capability set;
- faction/datasheet/weapon/equipment definition identities;
- the source snapshot identity for datasheet and point facts used by roster construction;
- mission and battlefield identities and content hashes;
- match options, deployment and randomization configuration;
- save schema and implementation versions needed to resume.

The guest accepts the match only after verifying the same manifest. Saves and rejoin flows restore that exact combination. An updated catalog does not silently rewrite an existing match. A source update creates a new content revision and requires explicit migration or a new match.

## Rule capability model

Support should be recorded at the smallest useful scope: a named rule or datasheet option, the 11th-edition source and update revision, implementation identity, affected rule windows, supported interactions, validation evidence and known restrictions. Keep these claims separate:

1. **Catalogued** — identity and source metadata are present.
2. **Implemented** — the host resolver enforces the behavior.
3. **Locally validated** — rule cases have deterministic checks.
4. **Network validated** — host, guest, stale commands and reconnect preserve behavior.
5. **Source reviewed** — effect and timing were checked against the selected Wahapedia 11e page/export and its recorded revision. Games Workshop publications may be noted as context, but do not gate admission or override that reference.
6. **Certified scope** — named rosters, mission, battlefield, options and version boundary were reviewed together.

A capability is matchable only if every required rule in its dependency set is implemented and enabled. A broad provider flag or a successful test suite cannot promote a rule to certified scope.

Common reusable rule concepts should represent timing windows, mandatory/optional triggers, legal targets, player choices, resource costs, effect duration, stacking/precedence and event provenance. Faction abilities can then use these concepts while retaining explicit custom code for effects that cannot be expressed safely as data.

The shared progression, action lifecycle, decision contract and phase-close gate are specified in [Phase, action and decision flow](architecture/phase-action-decision-flow.md). That document is an implementation contract, not a claim that the runtime already has a generic reaction engine.

## Shared battlefield before the editor

The interim battlefield is match content, not renderer code. Store its dimensions, terrain footprint and elevation, traversability/visibility properties, deployment zones and objective anchors in a versioned definition. Missions reference compatible battlefield capabilities and may provide setup parameters. The host and guest compare the battlefield hash before deployment.

Maintain one high-quality shared battlefield during rules expansion. Add mission compatibility and terrain geometry to that data model now; expose editing controls only in final milestone I. This avoids building an editor for geometry the rules engine cannot yet resolve.

## Incremental migration plan

1. Keep current match behavior stable; write characterization checks before moving high-risk code.
2. Extract immutable manifest construction and validation into a match/content boundary. The initial manifest builder is now separate from prepared match construction.
3. **Extracted:** peer creation, offline reset and connection-signal forwarding live in `scripts/network/session_transport.gd`.
4. **Extracted:** seat challenge/proof decisions live in `scripts/network/seat_handshake.gd`; seat lifecycle/admission and guest command authorization live in `scripts/network/match_session.gd`. Root RPC endpoints remain as adapters.
5. **In progress:** supported combat gameplay dispatch now goes through `scripts/edition_11/match_command_service.gd`, while `main.gd` retains RPC, presentation and legacy exercise handling. Preserve endpoint paths during migration. A shared command envelope, idempotency policy and negotiated endpoint manifest remain future work; revision and actor validation still lives in domain workflows and the common admission gate.
6. **In progress:** the capability registry exists and feeds rules gates, but provenance/evidence consumption across setup, support UI and test discovery still needs consolidation.
7. Move current fixed profiles to the versioned content format without changing their admitted rules or prices.
8. Add a generic timing/choice/effect API and migrate one existing faction feature at a time.
9. Continue with core rules, faction slices, missions and the shared battlefield. Build the map editor only after these are complete.

Each step keeps historical training behavior isolated from current-edition certification. No bulk migration of every faction is planned in one change.

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
- points/MFM snapshot identity when roster construction uses points;
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
5. **Source reviewed** — effect and timing were checked against the requested 11e reference and current official updates.
6. **Certified scope** — named rosters, mission, battlefield, options and version boundary were reviewed together.

A capability is matchable only if every required rule in its dependency set is implemented and enabled. A broad provider flag or a successful test suite cannot promote a rule to certified scope.

Common reusable rule concepts should represent timing windows, mandatory/optional triggers, legal targets, player choices, resource costs, effect duration, stacking/precedence and event provenance. Faction abilities can then use these concepts while retaining explicit custom code for effects that cannot be expressed safely as data.

## Shared battlefield before the editor

The interim battlefield is match content, not renderer code. Store its dimensions, terrain footprint and elevation, traversability/visibility properties, deployment zones and objective anchors in a versioned definition. Missions reference compatible battlefield capabilities and may provide setup parameters. The host and guest compare the battlefield hash before deployment.

Maintain one high-quality shared battlefield during rules expansion. Add mission compatibility and terrain geometry to that data model now; expose editing controls only in final milestone I. This avoids building an editor for geometry the rules engine cannot yet resolve.

## Incremental migration plan

1. Keep current match behavior stable; write characterization checks before moving high-risk code.
2. Extract immutable manifest construction and validation into a match/content boundary. The initial manifest builder is now separate from prepared match construction.
3. Extract peer creation, offline reset and connection-signal forwarding into `scripts/network/session_transport.gd`.
4. Extract seat challenge/proof protocol decisions into `scripts/network/seat_handshake.gd` and seat lifecycle/admission into `scripts/network/match_session.gd`; retain root RPC endpoints as adapters.
5. Move command dispatch and revision/actor checks out of `scripts/main.gd`; keep RPC callbacks thin and preserve endpoint paths during migration.
6. Consolidate capability, provenance and evidence metadata into a versioned registry consumed by setup, validation, support UI and test discovery.
7. Move current fixed profiles to the versioned content format without changing their admitted rules or prices.
8. Add a generic timing/choice/effect API and migrate one existing faction feature at a time.
9. Continue with core rules, faction slices, missions and the shared battlefield. Build the map editor only after these are complete.

Each step keeps historical training behavior isolated from current-edition certification. No bulk migration of every faction is planned in one change.

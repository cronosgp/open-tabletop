# Prepared custom match

Implemented 16 October 2026, combat protocol **v22**. This is a new preparation flow for the existing custom objective mission, not official mission deployment or legal army construction. Existing exercises still start directly at the first turn.

Update: protocol **v23** adds a separate [saved-list training flow](saved-army-matches.md) with validated canonical points, independent LAN selections and one/two units per side, including asymmetric or matching-faction armies. The original fixed-roster mode described below remains available.

## Start

1. Prepare the pinned optional starter data as described in [verification](../verification/verification.md).
2. In **Match setup**, choose next-match damage allocation/equipment options, then **Prepare custom match: deploy, then play 5 rounds**.
3. For LAN, select this same mode/options on both peers before the host starts and the guest joins. Hosting starts a fresh setup. No lobby negotiation is implemented yet.
4. Player 1 deploys Intercessor Squad I; player 2 deploys Necron Warriors I; then each deploys its second unit. Local mode controls the current decision owner automatically.
5. Select a model in the current unit and right-click a position inside its outlined zone. Alternatively, **Accept this unit's preview positions** marks the current positions of every model in that unit as placed. It does not restore original positions or commit the unit.
6. **Confirm unit deployment** locks the coherent unit and passes placement to the other player. After all four units, player 1 begins round 1. Normal phases, five-round custom scoring and win/draw handling follow.

The custom zones are 11-inch-wide left/right strips within the existing 43 × 43 battlefield. Player 1 uses the blue left zone; player 2 uses the orange right zone, also identified in text. Previews of all models remain visible; unplaced previews are not committed pieces for deployment collision purposes. Once a model is placed, other placements cannot overlap it. The complete base must fit within its zone and avoid blocking terrain endpoints. Final confirmation revalidates every position and unit coherency.

Deployment is placement, not movement: no movement budget, path crossing, dice, CP gain, damage or scoring applies during setup. Ordinary rules commands cannot skip setup. Invalid/stale/opponent requests leave the state unchanged. A unit remains editable until its own confirmation; after confirmation, it cannot be repositioned through deployment commands.

## Fixed scope and identity

The factory fields two current training units per side: ten Marine models and twenty Necron models in total. These are fixed training rosters, not armies validated at 1,000 points. Their faction/unit abilities and official legality remain outside this implementation. The UI retains the explicit “Rosters not points-validated” notice.

`prepared_training.gd` accepts only boolean `manual_allocation` and `varied_equipment` options. Unknown settings and malformed types fail before state creation. A versioned match manifest records the scenario, rules implementation, underlying content/configuration hash, battlefield, mission, first player, roster identities/counts and selected options. Its hash forms the compatibility identity; ordinary play does not change the manifest or adopt next-match settings. Clients with another exercise or configuration are rejected.

`deployment.gd` owns placement validation, sequencing and authoritative revisions. It does not depend on rendering. Host and guest use the same command path. Reconnecting while the original host stays open restores confirmed units, the active unit and its individually placed models. Persistent saves, restart recovery and authenticated player recovery remain separate work.

## Validation

`test_prepared_match.gd` covers configuration, identity, ownership, non-finite/out-of-zone/overlapping/terrain placement, coherency, stale requests, inability to bypass setup, explicit confirmation, unchanged turn/CP state, five-round completion and contextual UI. `test_prepared_match_network.gd` checks both players, rejected requests, disconnect/rejoin during individual placement and synchronized transition to Command.

The interface was rendered and inspected at 1280 × 800 on Windows for player 1 deployment, player 2 deployment and the first turn. Controls are above selection/history in Play; zones disappear after setup. A preview whose cursor is entirely outside the battlefield does not create an empty rendering surface. Screenshots and QA logs remain under ignored `.tools/prepared-*` paths.

See [latest verification results](../verification/verification-results.md). Linux, separate-machine LAN and internet play are not established by Windows loopback tests.

# Selected Chapter Approved 2026-27 mission (A2)

Enable **Advanced match options -> Next prepared match: CA 2026-27 / Battlefield Dominance**, then prepare a match or select both saved lists. This enables the current unit-ability/faction/core-stratagem options. For saved lists, this profile admits Space Marines as P1 and Necrons as P2 with an Incursion category and a 1,000-point limit. Their pinned costs and full army construction remain unverified (A3).

## Selected scenario

Both armies select **Take and Hold**, available to Gladius Task Force and Awakened Dynasty. The matching primary is **Battlefield Dominance**. The selected deployment is **Hammer and Anvil**. Both players use the two fixed secondaries **Engage on All Fronts** and **Assassination**. No Twist is selected. This is one selected scenario, not a random mission/deck generator or the official Event Companion recommended terrain layout.

The board is **60 x 44 inches**, with the long dimension along engine X. Attacker deploys wholly in X -30 to -12; Defender in X 12 to 30. The five objective points, expressed as engine (X,Z), are Attacker home (-16,-12), Defender home (16,12), expansions (-6,14) and (6,-14), and central (0,0). A D6 of six replaces the central point with (0,-6) and (0,6). The custom agreed terrain uses a 6 x 4-inch light terrain area covering each point with a low barricade proxy. These **terrain areas** are the objectives, using existing e11 terrain-objective control; they are not old-edition circular objective markers. Geometry remains ground-level with proxy visibility.

The preset map and custom terrain are the agreed scenario configuration. Interactive random deployment-card selection, alternating terrain authoring, other Force Dispositions/primaries, recommended event layouts and Tactical secondary decks are outside this profile. Selecting this mission is not a claim that every possible Chapter Approved configuration is implemented.

## Preparation and recovery

Resolve central-objective configuration, then a role roll-off. Each roll-off rolls once for each player; ties require another explicit roll. The winner chooses Attacker or Defender. Declare each army's Battle Ready status; no painting VP is granted yet. Resolve the current Leader/Support/Warlord preparations and reserve declarations, then alternate deployment starting with the Defender. Both players explicitly accept or place coherent previews and confirm each unit. Previews account for different base sizes and attached components, avoiding terrain walls and earlier suggested units.

Reserve declarations are concealed in the guest's state, model flags, deployment omissions/order and event log until both sides commit formations. Remote history is withheld during that interval to prevent a history-based leak. The authoritative host retains the full state for saving. This assumes the existing trusted host model and does not protect against a modified host inspecting its local save.

After deployment, roll off for first turn; the winner goes first. Existing pre-battle Homer declarations follow in first-player order. A fresh host can resume any pending mission choice; options and implementation ID enter the public setup/manifest, save/config checks and peer compatibility. The ID is `ca-2026-27-dominance-hammer-fixed-v1`. Both LAN peers must choose it. Historical saves default to disabled and keep their training identities.

## Scoring

Battlefield Dominance grants the current card's objective-control and home-objective cumulative bonuses. Rounds 1-2 also check the end-turn control advantage. Rounds 2-4 score control at own end of Command; **both** players defer that control scoring to own end of turn in round 5. Control resolves at phase/turn end before scoring, including coherency casualties at turn end. Scoring checkpoints cannot be applied twice.

Fixed Engage evaluates whole units in distinct quarters, more than six inches from the centre, excluding Aircraft, Battle-shocked and off-field models. An attached unit counts as one unit. Fixed Assassination scores newly destroyed enemy Character **models** at either player's turn end, including the wounds-characteristic bonus; surviving bodyguards do not prevent that score. Destroyed Characters cannot currently be revived, so the persisted destroyed-model ledger is scoped to that restriction.

Primary and secondary totals each have their current 45VP match and 15VP round caps; each fixed card also has its 20VP cap. At the end of five complete rounds, apply declared Battle Ready bonuses and compare final VP. Wiping an army does not end the game early. Randomized first-player order is preserved when advancing turns and rounds and granting battle-round-start Captain CP.

## Sources checked 17 October 2026

- User-required [e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), especially 14.01 terrain objectives and 14.02 control at phase and turn end.
- [Mission Deck 2026-27](https://wahapedia.ru/wh40k11ed/the-rules/mission-deck-2026-27/): scenario sequence, Hammer and Anvil map, Take and Hold matching primary, the selected primary/secondary cards, first-turn and scoring timing.
- [Space Marines](https://wahapedia.ru/wh40k11ed/factions/space-marines/) and [Necrons](https://wahapedia.ru/wh40k11ed/factions/necrons/): current Gladius/Awakened Take and Hold availability. Base faction/Codex effects follow the boundaries already recorded in the unit-ability and faction documents.
- Official [Warhammer Event Companion v1.3, 14 October 2026](https://assets.warhammer-community.com/eng_14-10_wh40k_event_companion-rdwnqprl4c-nj8oqogadv.pdf), pp. 1-4: board dimensions, roles/deployment, first turn, five-round duration despite wipeout, scoring limits and FAQ boundaries. It contains no amendments to these selected cards and does not reproduce the full base mission deck. Its recommended terrain layout system is not the custom terrain configuration implemented here. Cached PDF SHA256: `187253a9b6ea377f5e44d1148454bd042b165b03bb5c45c51a5880762bf56dc2`.

This source distinction matters: the `/wh40k11ed/` site also contains historical **2025-26 / edition 10** mission material. That material is not used as a substitute for the current mission.

See [verification results](verification-results.md) for automated and graphical evidence. A2's selected scenario is playable within these boundaries; A3 points/DP/wargear/complete army legality and the remaining required detachment content must still be certified before calling Track A a complete legal match.

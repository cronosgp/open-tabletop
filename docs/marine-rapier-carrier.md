# Rapier Carrier datasheet audit

## Current source identity

The current [Wahapedia 11th edition Rapier Carrier page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Rapier-Carrier) identifies this as a Space Marines Warhammer Legends datasheet: book `000000356`, datasheet `000000110`. Facts below use the local, hash-verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Legends source-slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`.

## Datasheet facts represented

- One Rapier Carrier model for 90 points; Movement 3", Toughness 6, Save 2+, 6 Wounds, Leadership 6+, Objective Control 2.
- Keywords: ADEPTUS ASTARTES, IMPERIUM, ARTILLERY, FRAME, VEHICLE. The source lists Combat Doctrines.
- Fixed weapons: Boltgun (24", A1, BS3+, S5, AP−1, D1, Rapid Fire 1) and Armoured Hull (A2, WS3+, S4, AP0, D1).
- Starting replaceable weapon: Quad Heavy Bolter (36", A6, BS3+, S5, AP−1, D2, Sustained Hits 1, Rapid Fire 2, Twin-linked, Heavy).
- The Quad Heavy Bolter may be replaced with one Graviton Cannon, Laser Destroyer or Quad Launcher. The Quad Launcher remains one selectable weapon with Shatter Shells and Thunderfire Shells profiles. Every profile and rule keyword from the local export is represented.
- Powerful Volley grants Lethal Hits to this unit's ranged Heavy attacks in a turn in which it remained stationary. AttackPlan checks unit movement and setup state, including Movement-phase moves, charges, pile-ins and consolidations. Existing model movement flags reset at the start of each turn, and dead models that moved still disqualify the unit for that turn.

## Game use and remaining boundaries

Games Workshop's current [Space Marines Legends guidance](https://www.warhammer-community.com/en-gb/articles/bbnskauh/big-space-marines-news/) allows Legends in home, store, club and campaign games; competitive Warhammer events require organiser permission. The Army Builder marks the entry `Warhammer Legends` and displays that event condition. Incursion and Strike Force construction apply the local two-copy and three-copy ceilings, respectively.

The source gives the base/footprint as `Use model` without a dimension. The simulation uses a 60 mm circle proxy so the unit can be placed and resolved on the current board. Exact model footprint, terrain clearance and physical-measurement equivalence are not certified. Full list legality, network validation and human playtesting remain separate gates under the project support policy.

## Verification

The focused Rapier test checks export provenance, all characteristics and weapon profiles, both Quad Launcher modes, selectable wargear replacement, Legends construction labels, points and copy caps, Powerful Volley on stationary Heavy attacks, and its exclusions after movement, advance, fall back, set-up and melee. The current results are recorded in [verification results](verification/verification-results.md).

# Vindicator datasheet audit

## Current source identity

The current [Wahapedia 11th edition Vindicator page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Vindicator) identifies the unit as a Space Marines Warhammer Legends datasheet in book `000000356`, datasheet `000001188`. It was checked on 30 October 2026 against the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Space Marines Legends slice manifest SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The machine-readable audit records the source-table hashes and the scoped source checker result. The Legends slice has zero scoped structural findings; the parent export retains 68 unrelated findings.

## Datasheet facts represented

- One Vindicator model: M9, T11, Sv2+, W11, Ld6+, OC3. Its exact source keywords are ADEPTUS ASTARTES, VEHICLE, FRAME, IMPERIUM and SMOKE.
- The first two units cost 185 points each; each third-plus unit costs 200. Construction applies the two-copy Incursion and three-copy Strike Force limits.
- Default equipment is Armoured Tracks and Demolisher Cannon. The source profiles are Armoured Tracks (A3, WS4+, S6, AP0, D1), Demolisher Cannon (24", D3+3, BS3+, S14, AP−3, D4, Blast 1), Hunter-killer Missile (48", A1, BS2+, S14, AP−3, D3+3, One Shot) and Storm Bolter (24", A2, BS3+, S5, AP−1, D1, Rapid Fire 2).
- During preparation, Hunter-killer Missile and Storm Bolter can each be added independently. One Shot usage is enforced by the shared attack path.
- Combat Doctrines, Deadly Demise D3 and Damaged 4 are registered. Damaged 4 applies −1 to Hit while the Vindicator has 1–4 wounds remaining. A destroyed Vindicator's Deadly Demise roll and D3 mortal-wound packet use the shared resolver and defender allocation path.
- Siege Shield is implemented for the owner's Shooting phase while the Vindicator uses close-quarters shooting. Attacks against a unit engaged with the Vindicator ignore modifiers to BS and Hit rolls. The Vindicator can choose a Blast weapon without BLAST; that profile may target any visible, in-range enemy that is not engaged with another friendly unit. This includes enemies engaged only with the Vindicator and unengaged enemies. It rejects enemies engaged with any other friendly unit. The selected no-BLAST profile removes only BLAST; it does not add an unsupported CLOSE-QUARTERS weapon keyword. When Siege Shield is active, the runtime takes the permitted choice to ignore all applicable BS and Hit modifiers.

## Game use and remaining boundaries

The sheet is labelled Warhammer Legends. Games Workshop guidance permits Legends in home, store, club and campaign games; competitive-event use requires the event organiser's permission. The Army Builder displays that condition. This verifies the sheet's current game-mode status, but the organiser decides acceptance at a specific event.

The source says `Use model` and gives no base diameter. The game uses a labelled 60 mm circular footprint proxy so the model can be placed and resolved; exact model clearance, terrain interactions and physical-measurement equivalence are not certified. The local scope covers the fixed profile, both optional weapons, all listed weapon data, points, composition, copy limits, Siege Shield target/phase behavior, Damaged 4, Deadly Demise D3 and construction admission. It does not certify a complete Space Marines army, every cross-unit interaction, network play, a complete match or human playtesting. Network validation remains deferred to final integration under project policy.

## Verification

Focused local checks cover export provenance, all characteristics/keywords/weapons, both equipment choices, point tiers, copy limits, the exact Siege Shield firing profile, engaged and unengaged targets, the other-friendly-unit restriction, the owner's Shooting-phase restriction, BS/Hit modifier handling, the Damaged 4 threshold and Deadly Demise D3 through mortal-wound allocation. See the [machine-readable audit](marine-vindicator-audit.json) and [verification history](verification/verification-results.md).

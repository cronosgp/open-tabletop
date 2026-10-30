# Centurion Devastator Squad datasheet audit

## Current source identity

The current [Wahapedia 11th edition Centurion Devastator Squad page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Centurion-Devastator-Squad) identifies a Space Marines Warhammer Legends datasheet in book `000000356`, datasheet `000001193`. The page was checked on 30 October 2026 against the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Space Marines Legends slice manifest SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The retrieval time, source-table filenames and hashes are recorded in the [machine-readable audit](marine-centurion-devastator-squad-audit.json). The source slice validates with zero scoped findings; the parent export's 68 unrelated findings remain open.

## Datasheet facts represented

- Composition is one Devastator Centurion Sergeant and two to five Devastator Centurions. Both roles use the exported M4, T7, Sv2+, W4, Ld6+, OC2 profile and exact 50 mm base.
- The only source-priced sizes are three models for 175 points and six models for 350 points. Other sizes are unavailable in construction. The local category and repeat limits apply the normal two-copy Incursion and three-copy Strike Force ceilings.
- Every model starts with Centurion Bolters, Centurion Fists and a Grav-cannon. During preparation, each model can independently replace its Centurion Bolters with a Centurion Missile Launcher and/or its Grav-cannon with a Twin Heavy Bolter or Twin Lascannon.
- All six per-model ranged combinations are supported. The three weapons in each legal loadout retain their individual ranges, attacks, skill, Strength, AP, Damage and weapon traits. Centurion Fists are represented as the melee profile. The datasheet's ADEPTUS ASTARTES faction keyword, INFANTRY, CENTURION and IMPERIUM keywords, and Combat Doctrines army rule are retained.
- Decimator Protocols allows ranged Hit rolls of 1 to be re-rolled. When the target unit is within range of an objective, the unit can instead re-roll Hit rolls. Attack planning resolves this separately for each target and retains the Core Rules bans on re-rolls for Fire Overwatch and Indirect Shooting. It does not affect melee attacks.

## Game use and remaining boundaries

Games Workshop identifies Centurion Devastator Squad among the Space Marines Legends units. Its guidance permits Legends use in home, store, club and campaign games; competitive event use requires the event organiser's permission. The Army Builder labels the profile `Warhammer Legends` and shows the event condition. This confirms the current source and game-mode status; it does not guarantee acceptance by a specific event organiser.

The supported local profile covers the source-priced unit sizes, role minimums, all listed equipment combinations and the declared Decimator Protocols effect. It does not certify complete Space Marines list legality, every cross-unit interaction, network play, a complete match or human playtesting. Network validation remains deferred to final integration under the project policy.

## Verification

Focused checks cover the source identity and snapshot provenance, exported characteristics and weapon profiles, base size and keywords, one-Sergeant composition, source-priced roster admission and copy limits, all equipment choices, each model's preparation selections, objective-range rerolls, and the Fire Overwatch, Indirect Shooting and melee exclusions. The source-slice structural audit and final local verification command/result are recorded in the [machine-readable audit](marine-centurion-devastator-squad-audit.json) and [verification results](verification/verification-results.md).

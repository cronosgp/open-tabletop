# Redemptor Dreadnought — 19 October 2026

Source: local Wahapedia 11th-edition extraction, Space Marines book `000000139`, datasheet `000002717`, exported `2026-10-16T21:03:46+03:00`. [Redemptor Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Redemptor-Dreadnought).

## Implemented profile and rules

One model: M8, T10, Sv2+, W12, Ld6+, OC4 and a 90 mm base. The extracted cost is 170 points for each of the first two copies and 190 for the third-plus copy. Macro Plasma Incinerator costs an additional 10 points. The default ranged weapons are Fragstorm Grenade Launchers, Heavy Flamer and Heavy Onslaught Gatling Cannon; the default melee weapon is Redemptor Fist.

The local construction workflow supports the extracted options: Fragstorm Grenade Launchers to Storm Bolters; Heavy Flamer to Onslaught Gatling Cannon; Heavy Onslaught Gatling Cannon to Macro Plasma Incinerator; and add an Icarus Rocket Pod. The Macro Plasma Incinerator carries standard and supercharge profiles, with Hazardous on supercharge. The Icarus Rocket Pod has Anti-Fly 2+. Heavy Onslaught Gatling Cannon's Devastating Wounds and Sustained Hits 2 are restricted to targets without MONSTER or VEHICLE. Optional macro-plasma pricing updates the prepared roster and checks the points cap.

- **Damaged 4:** while the model has 1–4 wounds remaining, its attacks have -1 to Hit.
- **Deadly Demise D3:** on a 6 after destruction, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet. Allocation and chained explosions use the shared local mortal-wound resolution queue.
- **Duty Eternal:** attacks targeting the Redemptor with Strength greater than its Toughness subtract 1 from the Wound roll.

The profile is selectable in the consolidated local construction catalog. This scope implements its fixed profile, listed weapon replacements, checked optional cost, abilities and targeted interactions. It does not certify every roster interaction, full army legality or a full match.

## Local validation

Focused offline validation passed **15/15 processes** in `.tools/verification/20261019T052426603673Z/results.json`. The selected checks include Redemptor, Ballistus, Attack Sequence, unit abilities, army builder, roster admission, combat scenario, Firestrike and Ancient regression coverage. The initial run found missing `damaged_threshold` metadata on the existing Ballistus profile; the metadata was corrected and the focused run passed. After marking Duty Eternal as locally validated in the capability registry, a follow-up run passed **7/7 processes** in `.tools/verification/20261019T052644446467Z/results.json`, including `test_capabilities`.

The bounded fixed-data comparison `.tools/wahapedia-fixed-data-review-v29.json` covers 22 profiles and 79 weapon trait profiles, with zero numeric or identity differences; 21/22 pass all fixed-data checks. Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation is deferred to final integration. Full faction and army legality are not certified.

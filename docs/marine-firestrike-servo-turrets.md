# Firestrike Servo-turrets — 19 October 2026

Source: local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000086`, exported `2026-10-16T21:03:46+03:00`. The local Wahapedia extraction is the sole rules authority for this project. [Firestrike Servo-turrets on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Firestrike-Servo-turrets).

## Admitted profile

- 1 turret for 80 points or 2 turrets for 160. Each has M5, T6, Sv2+, W6, Ld6+, OC2, and an 80 mm base.
- Default ranged weapon: Twin Firestrike Las-talon (36 inches, A2, BS2+, S10, AP-3, D3+3; Twin-linked).
- Each model may replace its Las-talon with a Twin Firestrike Autocannon (48 inches, A4, BS2+, S9, AP-1, D3; Twin-linked, Rapid Fire 2). The choice is individual to each turret.
- Hovering Bulk is the melee weapon (A3, WS3+, S5, AP0, D1).
- Sentinel Protocols lets this unit be targeted by Fire Overwatch regardless of other uses of that Stratagem in the phase. Once per phase per unit, the unit's snap shooting hits on unmodified 4+ until that Stratagem use is resolved. The usual CP cost and target eligibility remain. Snap shooting still cannot generate Critical Hits or use Hit re-rolls.

## Local validation

Focused offline validation passed **9/9 processes** in `.tools/verification/20261019T044616562986Z/results.json`: import, Python checks, startup, `test_combat_scenario`, `test_core_reactions`, `test_current_unit_abilities`, `test_firestrike_servo_turrets`, `test_implemented_catalog`, and `test_reiver_squad`.

The bounded fixed-data comparison `.tools/wahapedia-fixed-data-review-v20.json` covers **20 profiles / 65 weapon profiles**. Firestrike passes numeric characteristics, weapon traits, shared keywords, default loadout, composition and cost checks. Nineteen of twenty profiles are consistent; Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation and full local regression remain pending. Full faction and army legality are not certified.

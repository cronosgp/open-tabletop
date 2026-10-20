# Ballistus Dreadnought — 19 October 2026

Source: local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000091`, exported `2026-10-16T21:03:46+03:00`. [Ballistus Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ballistus-Dreadnought).

## Implemented profile and abilities

One model for 150 points: M8, T10, Sv2+, W12, Ld6+, OC4 and a 90 mm base. Its default equipment is Ballistus Lascannon, one Ballistus Missile Launcher with Frag and Krak profiles, Storm Bolters and Armoured Feet. The extracted third-plus price is 170 points; local list admission charges 150 each for the first two copies and 170 for the third. The fixed-data comparison matches the local extraction.

- **Ballistus Strike:** ranged attacks targeting an enemy unit within 24 inches gain Sustained Hits 1.
- **Damaged 4:** while the model has 1–4 wounds remaining, its attacks have -1 to Hit. The modifier enters the actual attack plan for both shooting and melee.
- **Deadly Demise D3:** when destroyed, a D6 roll of 6 triggers an explosion. Every unit within 6 inches receives a separately rolled D3 mortal-wound packet. The affected unit's owner allocates those wounds through normal mortal-wound prevention. If a packet destroys another Ballistus, its explosion is queued and resolved in sequence before the suspended attack resumes.

The profile is selectable in the local construction catalog. Admission checks cover the one-model profile and the extracted one-, two- and third-copy prices; they do not certify full army legality.

## Local validation

Focused offline validation passed **11/11 processes** in `.tools/verification/20261019T050853510494Z/results.json`: import, Python checks, startup, `test_army_builder`, `test_attack_sequence`, `test_ballistus_dreadnought`, `test_combat_scenario`, `test_core_reactions`, `test_current_unit_abilities`, `test_implemented_catalog` and `test_roster_validation`. The Ballistus test exercises the 24-inch effect, the Damaged 4 threshold, the Deadly Demise roll, per-unit D3 packets, allocation, chain explosions, attack resumption and local admission including third-plus pricing.

The fixed-data comparator `.tools/wahapedia-fixed-data-review-v25.json` reports zero numeric or identity differences; this Ballistus profile is consistent. Across 21 profiles / 70 weapon profiles, 20 pass all bounded fixed-data checks; Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` context. Full local regression and final network validation remain pending. Full faction and army legality are not certified.

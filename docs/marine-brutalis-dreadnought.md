# Brutalis Dreadnought — 19 October 2026

Source of truth: the local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000136`, exported `2026-10-16T21:03:46+03:00`. [Brutalis Dreadnought source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Brutalis-Dreadnought-UL).

## Implemented profile

One VEHICLE model: M10, T10, Sv2+, W12, Ld6+, OC4, 90 mm base. Construction charges 160 points for each of the first two copies and 180 for the third-plus copy; the supported copy limit is three.

The default weapons are Bolt Rifles (Twin-linked), Twin Heavy Bolter (Twin-linked, Sustained Hits 1, Rapid Fire 2), Twin Icarus Ironhail Heavy Stubber (Anti-Fly 3+, Rapid Fire 3, Twin-linked), and Brutalis Fists (Twin-linked). The local loadout choices implement the paired Bolt Rifles and Brutalis Fists replacement with Brutalis Talons (Sustained Hits 1 against targets without MONSTER or VEHICLE, Twin-linked, Cleave 2), and Twin Heavy Bolter replacement with Twin Multi-melta (Twin-linked, Melta 3).

- **Damaged 4:** while this model has 1–4 wounds remaining, subtract 1 from its Hit rolls.
- **Deadly Demise D3:** when destroyed, roll one D6; on a 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet, allocated through the shared mortal-wound flow.
- **Brutalis Charge:** this unit can use Tank Shock even if another unit has already used it this phase; its use does not prevent other units using Tank Shock. Once per phase per Brutalis unit, Tank Shock costs 1 fewer CP.
- **Tank Shock (Crushing Impact):** immediately after a VEHICLE finishes a Charge move, choose an enemy unit engaged by a VEHICLE model in the charging unit. Roll a number of D6 equal to that model's Toughness; each 5+ inflicts 1 mortal wound, to a maximum of 6. The defending player allocates those mortal wounds through the ordinary allocation window.

The post-charge Tank Shock window opens only when the charging Vehicle is engaged with an eligible enemy and the stratagem can be used. Tank Shock uses record separately so the Brutalis exception preserves one ordinary use by another unit in the same phase.

## Local validation

The focused run passed **14/14 processes**, including `test_brutalis_dreadnought`, the capability registry, combat scenario, Tank Shock/core reactions, both existing Dreadnought regressions, the implemented catalog and roster checks. Results: `.tools/verification/20261019T053830682027Z/results.json`.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v32.json` contains 23 runtime profiles and 85 weapon trait profiles; 22/23 pass all fixed-data checks with no numeric or identity differences. Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` keyword context. This comparison does not certify optional wargear legality, full faction coverage or full army legality. Network validation remains deferred to final integration.

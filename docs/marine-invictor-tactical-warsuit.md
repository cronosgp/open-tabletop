# Invictor Tactical Warsuit — 19 October 2026

Source of truth: the local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000001156`, exported `2026-10-16T21:03:46+03:00`. [Invictor Tactical Warsuit source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Invictor-Tactical-Warsuit).

## Implemented profile

One VEHICLE model: M10, T9, Sv3+, W12, Ld6+, OC4, 90 mm base. Construction charges 135 points for each of the first two copies and 150 for the third-plus copy; the supported copy limit is three.

The default weapons are Fragstorm Grenade Launcher (Blast 1), Heavy Bolter (Sustained Hits 1, Rapid Fire 2), Incendium Cannon (Torrent, Blast 2), Ironhail Heavy Stubbers (Rapid Fire 6), and Invictor Fist. The Incendium Cannon may be replaced by a Twin Ironhail Autocannon (Twin-linked).

- **Damaged 4:** while this model has 1–4 wounds remaining, subtract 1 from its Hit rolls.
- **Deadly Demise D3:** when destroyed, roll one D6; on a 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet, allocated through the shared mortal-wound flow.
- **Scouts 8:** before the first turn, the unit may make a normal move up to 8 inches or be set up from Strategic Reserves wholly within its deployment zone; the shared Scout flow checks base placement, coherency and more than 8 inches from enemies.
- **Forward Assault Warsuit:** at the start of the first battle round, mark one enemy unit. The Invictor re-rolls Wound rolls of 1 against its mark. Each time the mark is destroyed, select a new living enemy mark. Replacement selection waits for attack and mortal-wound resolution to finish.

## Local validation

The focused run passed **6/6 processes**, including the Invictor mark lifecycle through a resolved attack, Strategic Reserves eligibility from Scouts 8, capability registry, implemented catalog and startup/import checks. Results: `.tools/verification/20261019T055549579499Z/results.json`.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v35.json` covers 24 runtime profiles and 91 weapon trait profiles; 23/24 pass all fixed-data checks with zero numeric or identity differences. Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` keyword context. This comparison does not certify optional wargear legality, full faction coverage or full army legality. Network validation remains deferred to final integration.

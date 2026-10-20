# Scout Squad — local Wahapedia implementation

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000001160`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The direct sheet is [Scout Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Scout-Squad).

## Runtime scope

- 5 Scouts for 65 points or 10 for 120; one Scout Sergeant plus four/nine Scouts. Characteristics: M6, T4, Sv4+, W2, Ld6+, OC1.
- Fixed equipment: Bolt Pistol, Boltgun and Combat Knife per model.
- Sergeant may replace Boltgun with Shotgun and Combat Knife with Chainsword. Any Scout may replace Boltgun with Shotgun. Per five models, one Sniper Rifle and one additional special weapon; Heavy Bolter and Missile Launcher share the special-weapon slot. Missile Launcher has Frag and Krak profiles.
- Scouts 6 is available only when every living model qualifies. After deployment and first-turn determination, eligible units alternate; the squad may make a normal move up to 6 inches or set up from Strategic Reserves wholly within its owner's deployment zone. It must finish more than 8 inches horizontally from enemy models.
- Infiltrators applies the current deployment restriction. The linked Phobos Librarian Leader relationship is admitted and tested.
- Flexible Asset allows an otherwise eligible Action to start after the unit is selected to Advance or Fall Back; all other Action restrictions still apply.

## Validation boundary

Focused offline verification passed 13/13 processes in `.tools/verification/20261019T041415760366Z/results.json`: isolated import, Python checks, startup, ten related Godot suites (capabilities, current abilities, roster and reserves, Phobos leaders, Infiltrators, Eliminators, catalog and Scout Squad). The suite covers costs/admission, 5/10 composition, Scout movement, linked Librarian eligibility, action eligibility and wargear caps.

The bounded fixed-data comparator passed Scout Squad across all nine weapon profiles and its default equipment, composition and cost. The full comparison covers 17 profiles, 56 weapon profiles, with 16/17 complete data passes; Ancient in Terminator Armour has unresolved `DEATHWING` context. No network validation or complete local regression was run. Full faction/army legality is not certified.

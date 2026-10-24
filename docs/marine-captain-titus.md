# Captain Titus — Space Marines e11 increment

Source of truth: the local Wahapedia 11th-edition data export. Datasheet ID `000004187`, shared-book ID `000000139`, export timestamp `2026-10-16T21:03:46+03:00`; source page: https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-Titus. Network validation remains deferred to final integration.

## Admitted profile

Captain Titus is one Ultramarines Epic Hero model at 115 points on a 40mm base: M6, T5, Sv3+, invulnerable 4+, W6, Ld6+, OC1. His keywords include Infantry, Character, Epic Hero, Captain, Tacticus, Imperium, Explosives, Adeptus Astartes and Ultramarines.

- **Bolt Pistol:** 12”, A1, BS2+, S5, AP-1, D1; Close-Quarters.
- **Master-crafted Bolter:** 24”, A2, BS2+, S5, AP-1, D2; Assault, Rapid Fire 1, Heavy.
- **Master-crafted Chainsword:** melee A8, WS2+, S5, AP-1, D2; Anti-non-Monster/Vehicle 2+.

The local Leader target table lists Bladeguard Veterans, Hellblasters, Intercessors, Sternguard Veterans, Assault Intercessors and Infernus Squads. The runtime exposes these exact targets and rejects unlisted bodyguards.

## Implemented rules

- **Feel No Pain 5+, Leader, Combat Doctrines and Transhuman Strategist:** linked to the extracted core/faction records and existing shared implementations.
- **Press the Attack:** melee attacks gain Sustained Hits 1 against targets without Monster or Vehicle. If Assault Doctrine is active for his unit, they gain Sustained Hits 1 against any target.
- **Righteous Fury:** optional once per battle per army when Titus is selected to fight. It grants +1 Strength to melee attacks, then heals D3 after the unit fights, or 2D3 if Titus destroyed an enemy model this Fight phase. Healing is capped at his maximum Wounds.
- **Honour of Ultramar:** if Titus is destroyed in the Fight phase before his unit has been selected to fight, roll a D6; on 2+, he remains at 1 Wound until his unit fights or the Fight phase ends. Other units fighting do not prematurely remove him.
- **Anti-non-Monster/Vehicle 2+:** unmodified Wound rolls of 2+ are critical wounds only against targets with neither Monster nor Vehicle; excluded targets use the normal wound threshold.

## Local verification

Focused offline verification passed 15/15 processes, including profile, ability, Fight-phase effects, anti-keyword resolution, attack windows, catalog publication, roster and saved-army regressions. Results: `.tools/verification/20261019T181223215266Z/results.json`. The local runtime export is `.tools/marine-runtime-v107.json`. Network checks were not run, and this does not certify full faction or army legality.

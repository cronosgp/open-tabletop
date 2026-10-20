# Kor’sarro Khan — Space Marines e11 increment

Source of truth: the local Wahapedia 11th-edition data export. Datasheet ID `000002709`, shared-book ID `000000139`, export timestamp `2026-10-16T21:03:46+03:00`; source page: https://wahapedia.ru/wh40k11ed/factions/space-marines/Kor-sarro-Khan. Network validation remains deferred to final integration.

## Admitted profile

Kor’sarro Khan is one Epic Hero model at 80 points on a 40mm base: M6, T5, Sv3+, invulnerable 4+, W5, Ld6+, OC1. His keywords include Infantry, Character, Epic Hero, Captain, Tacticus, Imperium, Explosives, Adeptus Astartes and White Scars.

- **Anzuq:** 18”, A2, BS3+, S4, AP-1, D2; Close-Quarters, Devastating Wounds, Anti-Infantry 4+.
- **Bolt Pistol:** 12”, A1, BS2+, S5, AP-1, D1; Close-Quarters.
- **Moonfang:** melee A6, WS2+, S6, AP-3, D2; Anti-Character 5+, Precision, Devastating Wounds.

## Implemented rules

- **Leader:** exact local source targets are Bladeguard Veteran Squad (`000000071`), Sternguard Veteran Squad (`000002255`), Intercessor Squad (`000001157`), Assault Intercessor Squad (`000001606`), Company Heroes (`000002772`) and Vanguard Veteran Squad (`000001154`). The jump-pack Vanguard Veterans are not a target. Target availability is bounded by admitted compatible profiles.
- **Combat Doctrines** and **Transhuman Strategist:** existing shared e11 implementations apply.
- **Trophy Taker:** while Kor’sarro is in the unit, attacks that target a CHARACTER unit re-roll Hit and Wound rolls of 1.
- **For the Khan!:** the unit’s ranged attacks have Assault and its melee attacks have Lance.
- **Weapon Anti traits:** Anti-Infantry 4+ and Anti-Character 5+ create critical wounds at the threshold; the critical-wound path correctly interacts with Devastating Wounds and interactive attack resolution.

## Local verification

Focused offline verification passed 15/15 processes, including profile, Leader, ability, catalog, attack sequence, interactive attack window, weapon selection, roster validation and saved-army regressions. Results: `.tools/verification/20261019T175834766365Z/results.json`. The local runtime export is `.tools/marine-runtime-v106.json`. Network checks were not run, and this does not certify full faction or army legality.

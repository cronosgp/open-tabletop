# Incursor Squad — local Wahapedia implementation

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000001159`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The direct sheet is [Incursor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Incursor-Squad).

## Runtime scope

- 5 models for 90 points or 10 models for 170 points for the first and second units; the third-plus reference is 100/180 points. The consolidated construction catalog admits at most two copies, so it never applies third-plus pricing to an admitted third unit.
- Characteristics: M8, T4, Sv3+, W2, Ld6+, OC1; 32 mm bases. Fixed equipment per model: Bolt Pistol, Occulus Bolt Carbine and Paired Combat Blades.
- The implemented default weapons are Bolt Pistol A1 BS3 S5 AP-1 D1 (Close Quarters); Occulus Bolt Carbine 24 inches A2 BS3 S5 AP-1 D1 (Assault, Ignores Cover); Paired Combat Blades A3 WS3 S5 AP-1 D1 (Sustained Hits 1).
- Scouts 6 is available only when all living models qualify; the shared pre-battle movement and reserve set-up constraints are reused.
- Divinator-class Auspexes can be offered once per phase per Incursor unit when a friendly ADEPTUS ASTARTES unit is selected to shoot. It scans one visible enemy unit within 18 inches; friendly ranged attacks against it re-roll Hit rolls of 1 until the end of the Shooting phase. The effect is integrated with hit-roll rerolls.
- Haywire Mine is optional once per battle in the Incursor unit's Shooting phase: choose a visible enemy within 6 inches, roll D6; on 2+ it suffers D3 mortal wounds, or 2D3 if it has VEHICLE. Wounds use the shared mortal-wound allocation/prevention flow.
- Phobos Librarian and Phobos Lieutenant are linked as Leaders. The external Phobos Captain identity remains inadmitted.

## Validation boundary

Focused offline verification passed 15/15 processes in `.tools/verification/20261019T042405255660Z/results.json`: import, Python checks, startup, and twelve relevant Godot suites covering combat, attack plans, roster/reserves, ability registry, current catalog, Scout and Incursor behavior, and the Phobos leaders. The direct Incursor suite passed with zero failures.

The bounded fixed-data comparison in `.tools/wahapedia-fixed-data-review-v17.json` covers 18 profiles and 59 weapon profiles. Incursor's numeric characteristics, weapon traits, default equipment, composition and price data match the local extraction. Seventeen profiles pass the full bounded comparison; Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation and the full local regression remain pending. Full faction/army legality is not certified.

# Apothecary Biologis datasheet audit

## Source and scope

This audit covers the 11th-edition shared Space Marines datasheet in source book `000000139`, datasheet `000000060`, from the [Wahapedia Apothecary Biologis page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary-Biologis). The runtime profile keeps its `2026-10-16T21:03:46+03:00` source stamp. The scope uses the separately pinned, verified local export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, updated `2026-10-21 16:06:23 GMT+3`, specification revision `20260817b`. Its 23-file manifest and relevant SHA-256 values are recorded in [the machine-readable audit](marine-apothecary-biologis-audit.json).

The export defines one model at 60 points, with a 40 mm base, M5/T6/Sv3+/W5/Ld6+/OC1, and fixed Absolvor Bolt Pistol and Servo-armature. The sheet has no equipment-option rows. The export's Deathwatch Indomitor Kill Team relation is outside this shared-book scope and is not admitted by this increment.

## Implemented scope checked

- **Profile and construction:** source identity, composition, cost, base, characteristics, keywords, fixed loadout and absence of equipment options; the current consolidated Marine catalog materializes for both players. A 550-point roster passes local admission.
- **Vivispectral Analysis Targeting:** while the Biologis is living and attached as Support, the attached unit's attacks gain Lethal Hits against non-Vehicle targets. Monsters are eligible. A Vehicle keyword on any living model in the target unit excludes it; a destroyed model stops contributing its keywords. Destroying the Biologis removes the ability from future declarations.
- **Support:** all four shared-book bodyguards are available and materialized: Aggressors, Heavy Intercessors, Eradicators with Heavy Bolters and Eradicators with Melta Rifles. The suite checks preparation projections, positive attachment, a non-Gravis rejection and the need to assign duplicate Supports to separate bodyguards.
- **Weapons and combat path:** the fixed pistol and Servo-armature are available through Equipment. The pistol and attached bodyguard attacks reach AttackPlan with the ability effects; a critical pistol hit resolves Lethal Hits without a wound roll.

The rules reading follows the current [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) for Attached Units, keywords contributed by living models and Lethal Hits. The dedicated suite does not add a manual decline window for critical hits.

## Verification and limits

The targeted offline command below passed **6/6 processes**: project import, Python checks, the Biologis scope, profile parity, the 153-link Leader/Support map and the Eradicator Heavy Bolter bodyguard regression. It records `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics at `.tools/verification/20261027T093653231740Z/results.json`.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_biologis --only test_apothecary_biologis_profile_parity --only test_space_marine_leader_links --only test_eradicator_heavy_bolters --timeout 300
```

This closes only the declared 11th-edition shared-book local scope. It does not certify whole-army legality, the separate Deathwatch attachment, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.

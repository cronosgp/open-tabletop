# Aggressor Squad — Space Marines datasheet scope

This audit closes the Aggressor Squad's source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Aggressor Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Aggressor-Squad), book `000000139`, datasheet `000002099`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

## Verified local data source

The Space Marines local Wahapedia Data Export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; export specification revision `20260817b`; the manifest has 23 files and SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant source files and SHA-256 values:

| Export file | SHA-256 |
|---|---|
| `Last_update.csv` | `e39235a323535cd23fbcbc3813bf939df34511b9a10203ca93377700e2ec7485` |
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Abilities.csv` | `4922f4c86c5b3ad31d5651feb4b395255a14912ec361e2296f80364a9a731410` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

The raw export remains ignored under `.tools`; these hashes identify the recorded snapshot and are not a substitute for checking a newer source revision when one is adopted.

## Implemented and locally checked scope

- One Aggressor Sergeant and two to five Aggressors; supported sizes are three or six models. Every model has M5, T6, Sv3+, W3, Ld6+, OC1 and a 40 mm base. Points are 90/180 for three/six models.
- Default wargear is one Flamestorm Gauntlets and Twin Power Fists on every model. The only datasheet option replaces each model's Flamestorm Gauntlets with both Auto Boltstorm Gauntlets and a Fragstorm Grenade Launcher. Projected public preparation choices apply the whole-unit package, reject wrong-owner and stale choices, can restore Flamestorm and persist through state serialization.
- **Flamestorm Gauntlets — Ranged:** 12", A3, Torrent, Twin-linked, Blast 2, S4, AP-1, D1. **Close Quarters:** 12", A3, Close-quarters, Torrent, Twin-linked, S4, AP-1, D1; it has no Blast. The AttackPlan adds Blast attacks against a ten-model target and retains the separate Close-quarters engagement path.
- **Auto Boltstorm Gauntlets:** 18", A3, BS3, Twin-linked, S5, AP-1, D1. **Fragstorm Grenade Launcher:** 18", A3, BS3, Blast 1, S4, AP-1, D1. **Twin Power Fists:** melee A3, WS3, Twin-linked, S8, AP-2, D2. The dedicated suite routes each profile through AttackPlan, including the three-model melee pool.
- **Close-quarters Firestorm:** attacks by the unit that target an enemy unit within 9" of the Aggressor unit gain +1 Strength. The local check covers ranged and melee, the exact 9" boundary, a distant firing model supported by a living nearby Aggressor, a destroyed nearby model, and no bonus beyond range. The bonus is unit-wide and is not applied once per attacker.
- The Gravis profile has no ordinary Captain Leader link; the focused check rejects that pairing. Apothecary Biologis Support is a separate source-listed attachment path and is covered by the Biologis suite and shared Leader/Support relation audit.
- Construction uses the consolidated local catalog. The focused fixture materializes three- and six-model formations and the fixed 1000-point Incursion roster validator enforces its two-copy per-datasheet limit; this roster mode is not presented as full faction legality.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_aggressors`), with `network: false` and `legacy_starter_staged: false`, at `.tools/verification/20261027T054124713809Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aggressors --timeout 300
```

This closes only the Aggressor Squad's declared source-bounded shared-book local scope (**5/85 datasheets complete**, alongside Scout Squad, Lieutenant, Redemptor Dreadnought and Vanguard Veteran Squad With Jump Packs). The shared faction ability, Biologis effects, other datasheets and detachment rules retain their separate bounded evidence. Whole-army legality, chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Brutalis Dreadnought — Space Marines datasheet scope

This audit closes the Brutalis Dreadnought source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Brutalis Dreadnought datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Brutalis-Dreadnought), book `000000139`, datasheet `000000136`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

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

- One model; the first and second copies cost 160 points, and the third-plus tier costs 180. The supported catalog ceiling is three. Characteristics are M10, T10, Sv2+, W12, Ld6+, OC4, with a 90 mm round base and **Damaged 4**.
- The default loadout is Bolt Rifles, Twin Heavy Bolter, Twin Icarus Ironhail Heavy Stubber and Brutalis Fists. The test checks source weapon values and traits, then sends every equipped ranged and melee profile through `Equipment` and `AttackPlan`.
- The two source options are independently represented: replace Bolt Rifles and Brutalis Fists with Brutalis Talons; replace Twin Heavy Bolter with Twin Multi-melta. The suite exercises each selected package and all alternate weapon attack plans.
- Brutalis Talons retain Cleave 2 and Twin-linked; Sustained Hits 1 is restricted against MONSTER and VEHICLE. Twin Multi-melta retains Twin-linked and Melta 3. The test checks these exported traits in the equipment profile.
- **Brutalis Charge:** after a successful Charge, the immediate Tank Shock choice is free and counts as an additional use for the phase. The suite resolves that choice at 0 CP, verifies that a previous ordinary Tank Shock does not consume the Brutalis exception, and confirms that a later ordinary Vehicle use still costs 1 CP.
- The Tank Shock flow uses the common command and defender allocation window: the test checks the Toughness-based dice pool, six-mortal-wound cap, defender-owned allocation, suspended Charge continuation, save/restore of the pending decision and frame, wrong-owner rejection and completion before another reaction.
- Both Brutalis and Redemptor materialize from the current Space Marines catalog on both sides of the fixture. Admission, source characteristics, Damaged 4, options and copy limit are checked locally.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_brutalis_dreadnought`), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T061109103709Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_brutalis_dreadnought --timeout 300
```

This closes only the Brutalis Dreadnought declared source-bounded shared-book local scope (**8/85 datasheets complete**, alongside Scout Squad, Aggressor Squad, Lieutenant, Redemptor Dreadnought, Vanguard Veteran Squad With Jump Packs, Firestrike Servo-turrets and Company Heroes). Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Company Heroes — Space Marines datasheet scope

This audit closes the Company Heroes source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Company Heroes datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Company-Heroes), book `000000139`, datasheet `000002772`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

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

- The unit is exactly one Ancient, one Company Champion, one Company Veteran with Bolt Rifle and one Company Veteran with Heavy Bolter. Each model has M6, T5, Sv3+, W4, Ld6+, OC2 and a 40 mm base. The first and second units cost 125 points; third and later copies cost 145.
- All models share INFANTRY, EXPLOSIVES, IMPERIUM, TACTICUS and ADEPTUS ASTARTES. Only the Ancient has ANCIENT and CHARACTER; only the Company Champion has CHAMPION.
- Model-specific equipment is preserved: the Ancient and Bolt Rifle Veteran have a Master-crafted Bolt Pistol, Master-crafted Bolt Rifle and Combat Knife; the Company Champion has a Master-crafted Bolt Pistol and Master-crafted Power Weapon; the Heavy Bolter Veteran has a Master-crafted Bolt Pistol, Master-crafted Heavy Bolter and Combat Knife. The dedicated check compares every weapon profile and trait with the pinned export and sends every model-weapon pair through AttackPlan.
- **Command Squad:** attacks that target this unit have -1 to Wound rolls without a Strength threshold. The suite verifies this in an actual incoming Intercessor AttackPlan at S5 against T5, and confirms the effect is not applied to another unit.
- **Raise the Banner:** at the end of its owner's Movement phase, if this unit controls an objective, that objective is secured. The movement-end check secures the nearby controlled objective and leaves a distant objective unsecured.
- The source lists thirteen Leader identities that can attach to Company Heroes: Captain, Sanguinary Priest, Azrael, Lieutenant, Adrax Agatone, Lazarus, Kor'sarro Khan, Vulkan He'stan, Apothecary, Castellan, High Marshal Helbrecht, Blood Angels Captain and Marneus Calgar. The current-catalog fixture verifies the Captain attachment predicate; the shared Leader relation suite checks all 153 source links across 37 datasheets, including each Company Heroes link.
- The consolidated local catalog exposes the four-model choice at 125 points with the third-plus tier at 145. A three-copy construction charges 125 + 125 + 145 points. No datasheet wargear option rows are listed.

## Validation and limits

The dedicated offline command passed **4/4 processes** (project import, Python checks, `test_company_heroes_current` and `test_space_marine_leader_links`), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T060134565606Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_company_heroes_current --only test_space_marine_leader_links --timeout 300
```

This closes only the Company Heroes declared source-bounded shared-book local scope (**7/85 datasheets complete**, alongside Scout Squad, Aggressor Squad, Lieutenant, Redemptor Dreadnought, Vanguard Veteran Squad With Jump Packs and Firestrike Servo-turrets). Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

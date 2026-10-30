# Incursor Squad — Space Marines datasheet scope

This audit closes the Incursor Squad source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Incursor Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Incursor-Squad), book `000000139`, datasheet `000001159`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

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

- The unit contains one Incursor Sergeant and four to nine Incursors. Five models cost 90 points and ten cost 170 for either of the first two units; the third-plus reference is 100/180. The construction catalog admits at most two copies. Models use 32 mm bases with M8, T4, Sv3+, W2, Ld6+, OC1.
- All models have INFANTRY, EXPLOSIVES, SMOKE, PHOBOS, IMPERIUM and ADEPTUS ASTARTES. Each has a Bolt Pistol, Occulus Bolt Carbine and Paired Combat Blades. The source has no equipment-option rows.
- The suite checks every source weapon profile and trait with `Equipment.select`, then routes the Bolt Pistol, Occulus Bolt Carbine and Paired Combat Blades through `AttackPlan`. It also verifies source identity, 5/10-model construction prices, the third-plus price reference and copy ceiling.
- **Scouts 6:** the profile registers the source distance and can use the shared Strategic Reserves set-up flow.
- **Divinator-class Auspexes (once per phase per unit):** when a friendly ADEPTUS ASTARTES unit is selected to shoot, one visible enemy within 18 inches can be scanned. Friendly ranged attacks then re-roll Hit rolls of 1 against that target for the Shooting phase. The test scans through the public command during a live Intercessor shooting declaration, checks the ranged AttackPlan reroll and once-per-phase limit, rejects the opponent's submission and rejects an out-of-range trigger.
- **Haywire Mine (once per battle per unit):** select a visible enemy within 6 inches and roll a D6. On 2+, the target suffers D3 mortal wounds, or 2D3 if it has VEHICLE. The suite covers non-Vehicle and Vehicle packets, a failed roll that still expends the mine, an out-of-range target, defender-owned mortal allocation, save/restore, wrong-owner rejection and completion through the shared prevention flow.
- The source-linked Leader targets are Captain in Phobos Armour, Librarian in Phobos Armour and Lieutenant in Phobos Armour. Each attachment predicate is checked against the current local catalog.
- Both sides of the match fixture use current Space Marines catalog entries; the test does not stage the optional legacy starter pack.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_incursor_squad`), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T061905870311Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_incursor_squad --timeout 300
```

This closed the ninth sheet in that audit sequence. The matrix later advanced to 10/85 with Inceptor Squad and now records 11/85 after Infiltrator Squad was source-audited. Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

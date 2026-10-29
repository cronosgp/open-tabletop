# Inceptor Squad — Space Marines datasheet scope

This audit closes the Inceptor Squad source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Inceptor Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Inceptor-Squad), book `000000139`, datasheet `000000125`. Datasheet facts below come from a verified local export snapshot; this audit did not perform network validation.

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

- The unit contains one Inceptor Sergeant and two to five Inceptors. Three models cost 130 points and six cost 260 for either of the first two units; the third-plus reference is 150/280. Models use 40 mm bases and M10, T6, Sv3+, W3, Ld6+, OC1.
- All models carry INFANTRY, GRAVIS, JUMP PACK, IMPERIUM, FLY and ADEPTUS ASTARTES. The default weapons are Assault Bolters and Ceramite Fists. During setup, each model can individually replace its Assault Bolters with Plasma Exterminators. The suite checks the public choice for every model in isolated states and confirms other models keep their own weapons.
- The suite checks the full Assault Bolters, Plasma Exterminator standard and supercharge, and Ceramite Fists profiles through `Equipment` and `AttackPlan`. This includes the Hazardous tag on supercharge and the retained attack source.
- **Deep Strike:** the source ability is present on every model. After Jetleap reserves the unit, the suite verifies that the shared Ingress choice is exposed; it does not resolve the complete placement path for this unit.
- **Meteoric Descent:** after an Ingress move, ranged attacks gain +1 to Hit for the rest of the turn. Checks cover AttackPlan propagation, the ranged-only boundary, the out-of-phase Fight timing, and expiry after a different move.
- **Parabolic Jetleap:** at the end of the opponent's Fight phase, an unengaged unit can enter Strategic Reserves. The suite checks the engaged restriction, public choice, opponent pass, save/restore of phase close, and all models leaving the battlefield together.
- The current consolidated catalog admits the profile and source model sizes/cost tiers; unsupported five-model construction is rejected.
- The runtime retains the profile's original `2026-10-16T21:03:46+03:00` export stamp. This scope audit is tied separately to the verified 21 October snapshot above.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_inceptor_squad`), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T063205977865Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_inceptor_squad --timeout 300
```

At the point this report was recorded, Inceptor Squad brought the matrix to **10/85 datasheets complete**. The current matrix is **11/85** after the Infiltrator Squad audit. This closes only Inceptor's declared source-bounded shared-book local scope. Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Redemptor Dreadnought — Space Marines datasheet scope

This audit closes the Redemptor Dreadnought's source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Redemptor Dreadnought datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Redemptor-Dreadnought), book `000000139`, datasheet `000002717`. Datasheet facts below are taken from the verified local export snapshot; this turn did not perform network validation.

## Verified local data source

The Space Marines local Wahapedia Data Export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; export specification revision `20260817b`; manifest has 23 files and SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. All 23 file hashes were verified in the snapshot manifest. Relevant source files and SHA-256 values:

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

- One model: M8, T10, Sv2+, W12, Ld6+, OC4, 90 mm base; 170 points for each of the first two copies, then 190 for the third-plus copy. The construction limit rejects a fourth Redemptor.
- Every source equipment option is represented: add an Icarus Rocket Pod; replace Fragstorm Grenade Launchers with Storm Bolters; replace Heavy Flamer with Onslaught Gatling Cannon; or replace Heavy Onslaught Gatling Cannon with Macro Plasma Incinerator. The Macro Plasma option adds 10 points.
- All 16 legal combinations of the four binary option rows are checked. The 64 resulting ranged weapon profiles route their Strength, skill, AP and damage to AttackPlan. The fixed Redemptor Fist is also routed through a Fight AttackPlan.
- The weapon checks cover the source traits and modes, including Blast and Torrent on the Heavy Flamer, Anti-Fly 2+ on the Icarus Rocket Pod, Hazardous only on Macro Plasma supercharge, and rejection of selecting standard and supercharge together. Heavy Onslaught Gatling Cannon's Devastating Wounds and Sustained Hits 2 are present only against targets without MONSTER or VEHICLE.
- **Damaged 4** is exercised through an actual attack plan at the 1–4 wound threshold. **Duty Eternal** is covered through the shared attack resolution. Combat Doctrines are selected for the Redemptor and checked in its attack path.
- **Deadly Demise D3** is exercised by destroying a Redemptor in a prepared match. A synthetic attacker creates the deterministic destruction event; the actual Redemptor destruction reaction opens the nearby-unit mortal-wound flow, rejects the wrong player without mutation, allocates the chosen packet and closes the attack continuation.
- The source-projected `DEATHWING` keyword is absent outside Dark Angels Chapter context and granted to the Dreadnought in the tested Dark Angels context.
- The profile is admitted through the consolidated local construction catalog.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_redemptor_dreadnought`), with `network: false` and `legacy_starter_staged: false`, at `.tools/verification/20261027T051901469684Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_redemptor_dreadnought --timeout 300
```

This closes only the Redemptor's declared source-bounded shared-book local scope (**3/85 datasheets complete**, alongside Scout Squad and Lieutenant). Network validation is deferred to final integration. Whole-army legality, other datasheets, Chapter-book variants beyond the tested conditional Chapter context, Forge World, Legends, full match certification and human playtesting are not certified by this result.

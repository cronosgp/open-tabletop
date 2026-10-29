# Lieutenant — Space Marines datasheet scope

This audit covers the Lieutenant's source-defined scope in the shared Space Marines App book only. The [Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant) was checked on 27 October 2026. It identifies App book `000000139`, datasheet `000001346`, and the current 11th-edition Lieutenant entry. The original runtime source stamp is 16 October 2026; the later verified local export below was used to re-check the sheet facts without rewriting the older shared identity audit.

## Verified local data source

The local Wahapedia Data Export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; the export specification revision is `20260817b`. All 23 files listed in the snapshot manifest passed SHA-256 verification. The manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`.

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

The raw export remains in the ignored `.tools` directory. These recorded hashes identify the local source rows; they are not a substitute for rechecking Wahapedia when the source changes.

## Implemented and locally checked scope

- One model for 50 points, on a 40 mm base; M6, T5, Sv3+, W4, Ld6+, OC1, with the source-listed keywords and default Bolt Pistol, Master-crafted Bolter and Ceramite Fists.
- Every one of the five source option rows is represented. The test exercises all nine ranged packages, all three Ceramite Fists choices, and the optional Storm Shield only with the Neo-volkite package. The shield changes only the Lieutenant model's invulnerable save and reverts when that package is removed. Roster cost stays fixed.
- All six distinct ranged profiles and three melee profiles reach AttackPlan with their source stats. Tests include both Plasma modes, Hazardous on supercharge, rejection of simultaneously selecting both modes on one pistol, and the applicable Lethal Hits behavior.
- Support/attachment behavior is exercised with an allowed Intercessor bodyguard and a rejected Heavy Intercessor bodyguard. Tactical Precision excludes MONSTER and VEHICLE targets. Demi-company Commander is exercised after a Captain's Strategic Acumen choice, including its once-per-turn boundary.
- The profile is selectable from the consolidated local construction catalog.

## Validation and limits

The dedicated current-catalog run passed **3/3 processes** (import, Python checks and Lieutenant suite), with `network: false` and `legacy_starter_staged: false`: `.tools/verification/20261027T050300064874Z/results.json`.

A related run covering the Lieutenant and adjacent ability, doctrine, combat, catalog and Leader checks passed **8/8 processes**: `.tools/verification/20261027T050337525997Z/results.json`. That multi-suite verification copy staged the optional legacy starter (`legacy_starter_staged: true`); it is dependency evidence, not the dedicated Lieutenant gate.

This closes the Lieutenant's declared source-bounded local scope in shared-book datasheet coverage (**2/85 sheets complete**, alongside Scout Squad). It does not certify all Space Marine rosters, general faction legality, Chapter-book, Forge World or Legends variants, a complete match, network play, or the pending network validation reserved for final integration.

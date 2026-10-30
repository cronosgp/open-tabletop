# Firestrike Servo-turrets — Space Marines datasheet scope

This audit closes the Firestrike Servo-turrets' source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Firestrike Servo-turrets datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Firestrike-Servo-turrets), book `000000139`, datasheet `000000086`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

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

- One or two Firestrike Servo-turrets; 80/160 points. Each has M5, T6, Sv2+, W6, Ld6+, OC2, an 80 mm base, and the ARTILLERY, VEHICLE and ADEPTUS ASTARTES keywords.
- Each turret defaults to a Twin Firestrike Las-talon: 36", A2, BS2+, S10, AP-3, D3+3, Twin-linked. The source option lets any number of models replace its Las-talon with a Twin Firestrike Autocannon: 48", A4, BS2+, S9, AP-1, D3, Twin-linked, Rapid Fire 2. Preparation exposes a reversible choice for each turret independently.
- **Hovering Bulk:** melee A3, WS3+, S5, AP0, D1. Both ranged profiles and Hovering Bulk are checked against source characteristics, and attack plans route both ranged profiles during Overwatch and Hovering Bulk during the Fight phase.
- **Sentinel Protocols (once per phase per unit):** Firestrike's wording explicitly says it can be targeted by Fire Overwatch regardless of any other uses that phase, and that its use does not prevent use on other units. The shared rules therefore let Firestrike bypass the core once-per-player-per-phase restriction, while preserving ordinary use for other units; it still pays normal CP. Its snap shooting hits on unmodified 4+ for that use. The public-choice checks cover the target/CP path, wrong-owner rejection, no repeated use by the same turret unit, no hit re-rolls or Critical Hits for snap shooting, and preservation of another unit's normal use. This extra-use permission belongs to Firestrike's exact wording and is not inferred for Tarantula Sentry Battery.
- The shared Overwatch resolver now treats a Firestrike Sentinel use as an additional use in both directions: it can follow an ordinary Overwatch use, and its use does not consume another unit's normal use. This was fixed in the shared reaction path and rechecked with the current-catalog core-reaction suite.
- Firestrike is admitted through the consolidated local catalog at both source model counts. The datasheet does not list a Leader attachment.

## Validation and limits

The dedicated offline command passed **4/4 processes** (project import, Python checks, `test_firestrike_servo_turrets` and `test_core_reactions`), with `network: false` and `legacy_starter_staged: false`, at `.tools/verification/20261027T055048396594Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_firestrike_servo_turrets --only test_core_reactions --timeout 300
```

This closes only the Firestrike Servo-turrets' declared source-bounded shared-book local scope (**6/85 datasheets complete**, alongside Scout Squad, Aggressor Squad, Lieutenant, Redemptor Dreadnought and Vanguard Veteran Squad With Jump Packs). Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

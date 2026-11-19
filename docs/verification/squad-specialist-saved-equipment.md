# Saved squad specialist equipment - 14 November 2026

Firestrike Servo-turrets, Infiltrator Squad and Bladeguard Veteran Squad now save source-bounded equipment per stable miniature and copy in the Army Workshop. Match admission validates the entire squad's limits and roles, materialization installs exact equipment before Deployment, and readiness suppresses repeated choices. Existing selections without saved records retain their preparation path.

## Source and reviewed scope

The authority is the verified local Wahapedia 11e snapshot `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot ID `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Its final retrieval bracket is `2026-10-30T01:33:48.347556+00:00`; individual timestamps remain in the manifest. All 22 CSV hashes were rechecked with the existing local reader. This is the shared Space Marines App `000000139`, common 40K datasheet/points context; other game modes and full army legality are outside this review. No online resolution was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

| Datasheet | Source sheet | Saved scope |
|---|---|---|
| Firestrike Servo-turrets | `000000086` | Every model independently selects Twin Firestrike Las-talon or Twin Firestrike Autocannon. Source sizes 1/2 at 80/160 points; no replacement surcharge. |
| Infiltrator Squad | `000000128` | Zero or one Helix Gauntlet bearer in each 5/10-model squad, at 85/150 points. Every miniature may be the bearer; no surcharge. Fixed weapon inventory remains unchanged. |
| Bladeguard Veteran Squad | `000000071` | Sergeant may replace Heavy Bolt Pistol with Neo-volkite or Plasma. All other models retain Heavy Bolt Pistols. Source sizes 3/6 at 90/180 for copies 1-2, then 110/200 for copy 3 onward; no pistol surcharge. |

Existing source factories and audits remain authoritative for weapon characteristics and abilities: [Firestrike](../marine-firestrike-servo-turrets.md), [Infiltrator](../marine-infiltrator-squad.md), [Bladeguard](../marine-bladeguard-veteran-squad.md). The shared App verification slice binding remains `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535`, and the Marine runtime digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`; source profiles/factories and original extraction metadata were not rewritten by this increment. Three new explicit equipment-source reviews bind the exact saved fields to these source identities. Runtime verification is a separate gate.

The 204-profile ledger now has 82 detected schemas, 23 explicit equipment completeness reviews, 87 fixed-equipment profiles and 35 option-bearing migrations pending. The other 59 schemas still need source-option completeness review. These counts do not certify full rules or army legality.

## Data flow and player experience

The shared adapter now supports these three model-scoped schemas. Whole-squad validation enforces model counts, the single Helix limit and Sergeant-only replacements. The stable first Bladeguard model is the Sergeant, matching actual materialization. Wrong types, unknown fields, excess bearers and ordinary-model pistol replacements fail closed. Saved-model setup locks reject even direct forced changes without mutating the match. The Helix ability source lookup sees only the selected saved bearer; healing rules and the Bladeguard combat ability remain unchanged.

Player goal: finish reusable equipment configuration in the Workshop, identify the specialist and save once. Existing model rows, full-width native selectors, gold/black theme, typography, copy picker and Save footer are reused. Firestrike models have independent weapon choices. Each Infiltrator row labels the one-per-squad Helix limit; remove it from the current bearer before choosing another. Bladeguard's first row is explicitly labelled Sergeant; ordinary models show a disabled fixed-pistol selector. A rejected choice preserves the draft, restores the actual control and displays the existing source-limit feedback. The roster validation error now refers to source limits/model roles rather than incorrectly naming a per-three-model rule for every schema. Optional visual assets do not block saving; no browser dependencies or generated art were added. Scripted signals do not establish keyboard/gamepad accessibility.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_squad_specialist_saved_loadouts --only test_firestrike_servo_turrets --only test_infiltrator_squad --only test_bladeguard_veteran_squad --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_squad_specialist_saved_loadouts --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Result | results.json SHA-256 |
|---|---|---|
| `20261114T060706152906Z` | Failed 5/6: new fixture needed an explicit Dictionary type on a local variable; all three existing source suites passed. No cleanup diagnostics. | `e45795b682d4a7d072910afa1daf60dc8b63766ff982e9660b55985322784a6f` |
| `20261114T060841774860Z` | Passed 5/5 after correcting the fixture; only the catalog process reported RID/ObjectDB shutdown diagnostics. | `1fa170e41e51ab0ed7324c87559473b01aa94419be2279c2cb234b0e79e83c31` |

The Python ledger suite passed six tests.

The new fixture exhaustively checks 1,818 complete distributions over every source-supported model count, yielding 29 legal distributions. This includes both turret choices at sizes 1/2, zero or each single bearer at sizes 5/10, and three Sergeant pistols with fixed ordinary models at sizes 3/6. It checks wrong types/fields, transactional rejection of invalid edits, actual Workshop selectors and reversion, the Sergeant/fixed controls, independent copies, a separate Godot process reopening the bank, stable IDs and exact source weapons for both players, source Helix bearer lookup, duplicate setup suppression, forced-edit non-mutation and match isolation after source edits.

The mixed test army has two 2-model Firestrike units, two 10-model Infiltrator units and three 6-model Bladeguard units. Builder, admission and both players' materialized squad costs all total exactly 1,180, retaining the third-copy tier. No equipment price was invented. All Godot batches disable network and stage the historical starter. No deferred network check is reported as passed.

## Actual Godot captures

Actual Godot 4.7.2 Compatibility rendering at 1280x800 compares `.tools/verification/20261114T055542565213Z/project` with `.tools/verification/20261114T060841774860Z/project`. Both use the same 335/2000-point army: two Firestrikes, five Infiltrators and three Bladeguard. Isolated APPDATA/XDG_DATA_HOME folders are under `.tools/squad-specialist-equipment-20261114/`; the final after pass uses `after/profile-refined`. The actual selectors choose Autocannon on turret 1, Helix on Infiltrator 3 and Plasma on the Sergeant, then explicitly Save. The total remains 335. The initial after framing exposed only the first row; the final capture pass scrolls to the complete group so the selected bearer and fixed ordinary models are visible. All six final images were inspected. Both capture processes exited 0, with texture/RID/ObjectDB shutdown diagnostics retained in their logs. No clean render shutdown is claimed.

The ignored fixture `capture_equipment.gd` was run in each staged project with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_specialist_equipment.gd -- <output folder> <before|after>`. No model downloads occurred. Capture evidence SHA-256: `943e35c8a5465443cc852873a6ac9f4092c1457d2b072b03b4fe25007d4498d2`.

| Profile | Before | After |
|---|---|---|
| Firestrike | [Before](../../.tools/squad-specialist-equipment-20261114/before/firestrike-servo-turrets-before-1280x800.png) | [Independent turret weapons](../../.tools/squad-specialist-equipment-20261114/after/firestrike-servo-turrets-after-1280x800.png) |
| Infiltrators | [Before](../../.tools/squad-specialist-equipment-20261114/before/infiltrator-squad-before-1280x800.png) | [One selected Helix bearer](../../.tools/squad-specialist-equipment-20261114/after/infiltrator-squad-after-1280x800.png) |
| Bladeguard | [Before](../../.tools/squad-specialist-equipment-20261114/before/bladeguard-veteran-squad-before-1280x800.png) | [Sergeant Plasma Pistol and fixed ordinary models](../../.tools/squad-specialist-equipment-20261114/after/bladeguard-veteran-squad-after-1280x800.png) |

The images are scripted runtime observations, not mockups, human playtests, physical-sculpt reviews, input-device coverage or separate-machine LAN evidence. Original plan recovery, legacy and integration gates remain open in [the plan status](../project/army-configuration-plan-status.md).

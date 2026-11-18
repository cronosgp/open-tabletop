# Heavy and Space Wolves saved equipment — 14 November 2026

Redemptor Dreadnought, Centurion Assault Squad, Centurion Devastator Squad and Wolf Guard Battle Leader now save equipment per stable model/copy in the Army Builder. Canonical admission validates the choices and prices; preparation materializes the exact existing local weapon factories and suppresses repeated equipment setup. Legacy selections without saved records retain their existing preparation path.

## Source and equipment scope

The verified local source is `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Final retrieval bracket: `2026-10-30T01:33:48.347556+00:00`; individual retrieval times remain in the manifest. All 22 CSV hashes were rechecked with the existing local audit reader. No online resolution was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |

| Profile | Book / datasheet | Reviewed saved scope |
|---|---|---|
| Redemptor Dreadnought | Space Marines App `000000139` / `000002717` | Four independent groups, 16 packages: Fragstorm/Storm Bolters, Heavy Flamer/Onslaught, Heavy Onslaught/Macro Plasma and optional Icarus. Macro Plasma adds 10 points. Base copies 1–2 cost 170 each; copy 3 costs 190 before equipment. |
| Centurion Assault Squad | Legends `000000356` / `000002703` | Four packages independently per model, squads of 3/6 at 150/300. Bolters/Assault Launcher and Twin Flamer/Twin Meltagun. Launcher grants EXPLOSIVES to its bearer, without inventing an attack profile. |
| Centurion Devastator Squad | Legends `000000356` / `000001193` | Six packages independently per model, squads of 3/6 at 175/350. Bolters/Missile Launcher and Grav-cannon/Twin Heavy Bolter/Twin Lascannon; fists retained. |
| Wolf Guard Battle Leader | Space Wolves App `000000036` / `000004130` | Four packages: Plasma Pistol/Storm Shield and Master-crafted Power Weapon/Thunder Hammer. Base 80; shield adds exactly one Wound, 5 → 6, without changing its existing 4+ invulnerable save or adding points. |

Runtime verification slice hashes are `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535` (shared App), `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c` (Legends) and `427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327` (Space Wolves). Original extraction identities remain distinct. The registry binds each source-option review to the exact saved fields and verified-against provenance.

Existing ability, Chapter, event and geometry boundaries remain in the [Redemptor](../marine-redemptor-dreadnought.md), [Assault Centurion](../marine-centurion-assault-squad.md), [Devastator Centurion](../marine-centurion-devastator-squad.md) and [Battle Leader](../marine-wolf-guard-battle-leader.md) audits. This is equipment-option completeness, not full datasheet or army-legality certification. The current ledger has 204 profiles: 67 detected schemas, eight explicit equipment-source schema reviews, 87 fixed-equipment profiles and 50 migrations pending. The other 59 schemas still need source-option completeness review.

## Pricing and persistence

The shared adapter reads the Redemptor replacement price from its local runtime source profile. The roster summary and admission use the same value. Admission retains internal per-configuration pricing; prepared squads preserve each canonical copy cost instead of resetting it to the base profile during loadout initialization. This fixes loss of equipment surcharges and third-copy tiers. The existing ATV surcharge remains supported, and legacy paths without canonical pricing retain their prior calculation.

The fixture independently enumerates all 30 packages, checks strict types and model counts, source weapon equality, bearer-only EXPLOSIVES, idempotent shield Wounds, independent model IDs/copies, budget rejection, a second Godot process reopening the army bank, match save/reload and source-army edits after the snapshot. A 1,920-point mixed army includes three Redemptors, mixed 3- and 6-model Centurion copies, two Battle Leaders and three existing ATVs. For both players, the sum of materialized squad costs equals the admitted total. Forced setup changes must return an error and leave the entire state unchanged. Real Workshop option signals verify per-model independence and live price feedback.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_saved_loadouts --only test_redemptor_dreadnought --only test_centurion_assault_squad --only test_centurion_devastator_squad --only test_wolf_guard_battle_leader --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_saved_loadouts --only test_unit_reserves --only test_space_marine_copy_cost_parity --only test_invader_atvs --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_saved_loadouts --only test_character_artillery_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Outcome | results.json SHA-256 |
|---|---|---|
| `20261114T051809123809Z` | Failed, 6/7 processes; new fixture assumed flattened multi-model controls. All four source regressions passed. | `d3986d3d2a09abdc7ba2f0dc8665a0673a43e300b69ba5de6e87eb6954ea003f` |
| `20261114T052112897287Z` | Passed 6/6 after correcting the fixture to inspect each model row. | `09251e763f5cd877d86c11480d53c7c4c730a62647687194d82298bfcdbc139b` |
| `20261114T052554738295Z` | Passed 5/5, including forced-change rejection, prior migrations and catalog regression. | `35d85648f56db05fb472d2086fb85e54c17b855cc64999ce64c772a21e2e90d3` |

All three batches disabled network and staged the historical starter fixture. Only the final catalog process reported RID/ObjectDB shutdown diagnostics. The Python ledger suite passed six tests. No deferred network check is reported as passed.

## Player experience and actual Godot captures

Player goal: configure reusable equipment, see point consequences and save before starting a match. Existing shared labels, selectors, model rows and explicit Save footer are reused. Centurion changes affect only the selected miniature; the live total exposes the Macro Plasma surcharge. Invalid records are rejected by the source-specific validator. Optional visuals do not block saving; placeholders remain visible. No new assets or browser dependencies were introduced.

Actual Godot 4.7.2 Compatibility rendering, 1280×800, used isolated APPDATA/XDG_DATA_HOME under `.tools/heavy-equipment-20261114/<before|after>/profile`. The before project was `.tools/verification/20261114T044537078478Z/project`; after was `.tools/verification/20261114T052112897287Z/project`. The same four-unit/eight-model army starts at 575 points. After real selector signals and explicit Save, Macro Plasma raises it to 585. The first model of each Centurion squad changes independently; the Battle Leader selects the shield.

| Profile | Before | After |
|---|---|---|
| Redemptor | [Before](../../.tools/heavy-equipment-20261114/before/redemptor-dreadnought-before-1280x800.png) | [Macro Plasma +10](../../.tools/heavy-equipment-20261114/after/redemptor-dreadnought-after-1280x800.png) |
| Assault Centurions | [Before](../../.tools/heavy-equipment-20261114/before/centurion-assault-squad-before-1280x800.png) | [Independent model controls](../../.tools/heavy-equipment-20261114/after/centurion-assault-squad-after-1280x800.png) |
| Devastator Centurions | [Before](../../.tools/heavy-equipment-20261114/before/centurion-devastator-squad-before-1280x800.png) | [Independent model controls](../../.tools/heavy-equipment-20261114/after/centurion-devastator-squad-after-1280x800.png) |
| Battle Leader | [Before](../../.tools/heavy-equipment-20261114/before/wolf-guard-battle-leader-before-1280x800.png) | [Shield +1 Wound](../../.tools/heavy-equipment-20261114/after/wolf-guard-battle-leader-after-1280x800.png) |

All eight images were inspected. The baseline shows the unit inspector without these saved selectors; the after fixture scrolls to them. Redemptor's first selector is above the shown viewport; the signal regression checks all four. Capture logs retain texture/RID/ObjectDB shutdown diagnostics. The ignored fixture is `capture_equipment.gd`, invoked in each staged project with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_equipment.gd -- <output folder> <before|after>`. No model downloads occurred. Capture evidence SHA-256: `697189080c006f12eba1691d90abb50ca8ddde6c7a19e680992d6acb3a12c351`.

These are scripted observations, not a human playtest, keyboard/gamepad review, sculpt review or separate-machine LAN session. Remaining migrations, completeness reviews and [original plan gates](../project/army-configuration-plan-status.md) remain open.

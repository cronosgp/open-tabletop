# Saved Sergeant and Pack Leader squad equipment — 14 November 2026

Assault Intercessors with Jump Packs, Blood Claws and Grey Hunters now persist equipment per stable model and copy. Leader and ordinary-model roles constrain Workshop selectors, canonical admission validates each complete saved record, and materialization applies exact inventories before Deployment. Readiness omits these saved choices and forced equipment edits preserve the captured state. Old Greymanes remains a live formation decision.

## Verified source and scope

Authority: `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot of the same name, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. All 22 CSV hashes were rechecked. These are the common 40K datasheet context; alternate modes and full army legality are not certified. No online lookup was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

Runtime Marine digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`. Verified-against slice hashes are `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535` for book `000000139` and `427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327` for `000000036`. Original extraction provenance and earlier source stamps remain separate and unchanged.

| Profile | Book / datasheet | Saved equipment scope |
|---|---|---|
| Assault Intercessors with Jump Packs | `000000139` / `000002776` | 5/10 models, 95/190 points within existing two-copy admission. Model zero is Sergeant: Heavy Bolt Pistol, Hand Flamer or Plasma Pistol, independently Chainsword, Power Fist or Power Weapon. Ordinary models keep Chainswords; one per five may take Plasma Pistol. Sergeant Plasma does not consume the ordinary-model allowance. |
| Blood Claws | `000000036` / `000000303` | 10/20 models, 150/290 points. Pack Leader may independently replace Bolt Pistol with Plasma Pistol and Chainsword with Power Weapon. Other models retain Bolt Pistol and Chainsword. |
| Grey Hunters | `000000036` / `000000305` | 10 models, 180 points. Pack Leader may independently replace Bolt Pistol with Plasma Pistol and Chainsword with Power Fist or Power Weapon. Every model retains its Bolt Carbine. Other models retain Bolt Pistol and Chainsword. |

All options above are free. Source weapon factories retain Standard/Supercharge and exact weapon characteristics. Admission sizes and copy limits are unchanged, including the existing two-copy Jump Intercessor limit despite recorded third-plus source prices. This migration does not widen those construction gates or rewrite combat effects. See the [Jump Intercessor](../marine-assault-intercessors-with-jump-packs.md), [Blood Claws](../marine-blood-claws.md) and [Grey Hunters](../marine-grey-hunters.md) audits.

The shared adapter uses exact per-profile pistol/melee fields. Source role zero is explicit in controls, validation, preparation and appearance similarity; equipment-identical ordinary models cannot inherit the leader's visual override through the shared appearance action. Prepared records retain their original saved-model index before any formation replay. Existing selections without saved records retain legacy preparation behavior. Old Greymanes may still select and split five identities into a second pack, preserving each inventory.

Three exact-field source-option audits bring the consolidated ledger to 95 detected schemas, 36 explicit completeness reviews, 87 fixed profiles and 22 migrations pending. The other 59 detected schemas still need completeness review. These are migration counts, not a rules-certification score.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sergeant_squad_saved_loadouts --only test_assault_intercessors_with_jump_packs --only test_blood_claws --only test_grey_hunters --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sergeant_squad_saved_loadouts --only test_mixed_space_wolves_saved_loadouts --only test_model_equipment_visuals --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

Initial report `.tools/verification/20261114T154303767117Z/results.json` failed 1/6 processes: the new test had a GDScript inferred-type error on its expected legality expression. Import, Python and all three existing source suites passed. SHA-256: `46832b9273cffe1841d337cfa80a3ca25d0503b27cfe0e0eba169aa4a7ba52f0`. The test now declares that expression as `bool`; a direct rerun of the corrected test in the same stage exited 0 with no failures. Runtime logic was not changed for this correction.

Final report `.tools/verification/20261114T154547437952Z/results.json` passed 6/6 processes (import, Python, new squad test, previous mixed Space Wolves test, model-equipment visuals and consolidated catalog). SHA-256: `b0aec5dddf196385e28184fa07c6cc5f632240d26b60276a574799e933a6c0ae`. Only the catalog emitted headless renderer/ObjectDB cleanup diagnostics. Network checks were disabled and the verifier staged the historical starter; this is not a network or current-source-certification result.

The exhaustive Jump matrix checks all 4,752 distributions: nine Sergeant packages times every ordinary-model binary pistol distribution at five/ten models. It finds exactly 45/414 legal outcomes. Another 315 role/package cases cover every source pistol/melee pair on every model at each admitted size across the three profiles. Valid packages are compared with the existing exact source weapon factories; wrong fields/types, incomplete records and non-leader replacements fail closed.

The integration fixture has five entries/seven units: 5/10-model Jump squads, two ten-model and one twenty-model Blood Claws, and two ten-model Grey Hunters. Builder, canonical admission and each player's materialized squad sum are exactly 1,235 points. The check covers independent copies, separate-process bank reopening, stable identity mapping, exact inventories, saved setup locks with whole-state non-mutation, Old Greymanes split preservation, match save/reload and isolation from later source-army edits. Native selector signals check the ordinary Plasma cap rejection/reversion and a free Sergeant Hand Flamer change. Appearance filtering and fixed-role native selectors are inspected. The Python ledger suite passed six tests.

## Screen brief and actual Godot captures

Player goal: choose the leader's reusable weapons, allocate legal ordinary Plasma Pistols and save once before a match. Existing native two-selector model rows, copy identity, gold/black theme, font hierarchy and Save footer are preserved. Labels identify Sergeant/Pack Leader; ordinary Jump rows state `Pistol (1 Plasma / 5)`; Grey rows state `Pistol (+ Bolt Carbine)` to make the retained weapon legible. Fixed selectors are disabled, and invalid edits restore the draft/control. Rules remain independent of visual assets.

Real Godot 4.7.2 Compatibility captures at 1280×800 use isolated user-data paths with no model downloads. Before stage is `20261114T153240545996Z`; after stage is `20261114T154303767117Z` (same runtime UI as the corrected stage). Both processes exited 0; both reported renderer/ObjectDB shutdown cleanup diagnostics. These are bounded Workshop render observations, not clean-shutdown or full input/platform certification.

Ignored folder `.tools/sergeant-squad-equipment-20261114/` retains capture scripts, logs, process results and observations. Three before captures show the former unit inspector without the new per-model controls. Three after captures show the Jump Sergeant's Hand Flamer/Power Fist and an ordinary Plasma bearer; Blood Claw Pack Leader Plasma/Power Weapon; and Grey Hunter Pack Leader Plasma/Power Fist with the retained carbine label. Scrolling crops later model rows; tests cover the full arrays, while visual review of the twenty-model layout, keyboard/gamepad and other viewport sizes remains open.

![Jump Sergeant and ordinary Plasma bearer](../../.tools/sergeant-squad-equipment-20261114/after/assault-intercessors-with-jump-packs-after-1280x800.png)

![Grey Hunter Pack Leader and retained carbines](../../.tools/sergeant-squad-equipment-20261114/after/grey-hunters-after-1280x800.png)

Remaining original gates include the 22 migrations, 59 schema completeness reviews, broader legacy/asset/restart recovery and gallery cases, human review and unequal-cache separate-machine LAN. Deferred network checks are not reported as passed.

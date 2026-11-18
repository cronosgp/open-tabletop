# Saved Space Wolves squad equipment - 14 November 2026

Thunderwolf Cavalry, Wulfen and Wulfen with Storm Shields now save source-listed equipment per stable miniature and copy in the Workshop. Canonical admission enforces unit sizes, Plasma Pistol limits and per-bearer shield prices; materialization applies exact weapons and flags before Deployment. Readiness omits these persistent decisions and direct forced changes leave the captured match unchanged.

## Verified local source and equipment scope

The authority is `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Final retrieval bracket: `2026-10-30T01:33:48.347556+00:00`; individual timestamps remain in its manifest. All 22 CSV hashes were rechecked. The three sheets are Space Wolves App book `000000036`, common 40K datasheet/points context. Alternate modes and full army legality are not certified. No online resolution was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

| Sheet | ID | Reviewed saved scope |
|---|---|---|
| Thunderwolf Cavalry | `000000322` | 3/6 models at 115/230 for copies 1-2, 145/260 for copy 3 onward. Per model: Bolt Pistol; Plasma Pistol (one per three models); or Boltgun plus Storm Shield. Each shield adds 5 points and grants only its bearer 4+ invulnerable; Wounds remain 4. Both melee weapons and both Plasma profiles retained. |
| Wulfen | `000000311` | 5/10 models at 90/180, then 105/195 for copy 3 onward. Every model defaults to Death Totem and may independently replace it with Stormfrag Auto-launcher. No equipment surcharge. Wulfen Weapons retained; no shield save is introduced. |
| Wulfen with Storm Shields | `000004132` | 5/10 models at 125/250, then 155/280 for copy 3 onward. Every model defaults to Stormfrag Auto-launcher and may independently replace it with Death Totem. Thunder Hammer, fixed 4+ invulnerable and 2 Wounds retained; no additional shield price. |

The existing local factories remain authoritative for weapon profiles: [Thunderwolves](../marine-thunderwolf-cavalry.md), [Wulfen](../marine-wulfen.md) and [shield Wulfen](../marine-wulfen-with-storm-shields.md). The saved field captures the physical pistol choice, while Standard/Supercharge remain firing-profile choices during play. Totem flags and actual squad ability lookup are preserved; this migration does not rewrite their combat effects.

Runtime source profiles and digest `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68` are unchanged. The verified-against Space Wolves slice hash is `427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327`; original extraction metadata is preserved. Three exact-field equipment reviews bring the ledger to 90 detected schemas, 31 explicit completeness audits, 87 fixed profiles and 27 migrations pending. The other 59 schemas still need completeness review.

## Pricing and regression findings

Whole-squad saved validation accepts only the source model counts and caps Plasma Pistols before admission. Thunderwolf shield pricing reads the existing source `storm-shield` cost per equipped model. Wulfen choices add no price. Stable copies keep independent model records; prepared models carry the exact weapon packages, bearer-only defense and persistent-setup lock. Existing selections without saved records retain their legacy preparation route.

The first batch exposed three outdated source-test expectations: each fixture contains three units but asserted first-two prices on all three. The existing canonical admission groups configurations deterministically and the earlier pricing fix now preserves its later-copy tiers in materialized squads. Reviewing the source table and canonical selection confirmed the third-unit premiums. Only test expectations were changed here: Thunderwolf canonical 3/3/6 formations total 490, Wulfen canonical 5/5/10 total 375, and shield Wulfen 5/5/10 total 530. The tests now check the actual copy tier and unit sums against the army total. Runtime pricing/profile rules were not changed to satisfy these tests.

The new mixed-army fixture has three six-model Thunderwolf units with one shield per unit, two five-model Wulfen units and two five-model shield-Wulfen units. Builder, admission and each player's prepared squad sum are exactly 1,165. A two-unit 230-point budget accepts default three-model Thunderwolves and rejects the 235-point result after adding one shield.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_squad_saved_loadouts --only test_thunderwolf_cavalry --only test_wulfen --only test_wulfen_storm_shields --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_squad_saved_loadouts --only test_squad_specialist_saved_loadouts --only test_implemented_catalog --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_thunderwolf_cavalry --only test_wulfen --only test_wulfen_storm_shields --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Result | results.json SHA-256 |
|---|---|---|
| `20261114T150202525695Z` | Failed 3/6: new saved-equipment matrix passed; three old tests incorrectly expected first-two prices on the third unit. No cleanup diagnostics. | `7f8438b52f63f47d9584fcbbddb7b0bf016008b76a8b26bc9459f5ff2655e4db` |
| `20261114T150607965939Z` | Passed 5/5: new saved-lock checks, previous specialist and catalog regression. Catalog shutdown diagnostics. | `48657e78bf75e51b41f0a8d49c71271af834462923c8df8a7c1dd8005ed7e03c` |
| `20261114T150852426899Z` | Passed 5/5 after correcting source-tier expectations; no cleanup diagnostics. | `751c24e9ec784feebac8a48342e29847f8fd61c85967820d9cfe0c76c0202e7a` |

The Python equipment-ledger suite passed six tests.

The exhaustive matrix checks 2,868 complete model distributions and 2,628 legal outcomes: every 5/10-model binary Wulfen distribution, plus 20 legal three-model and 496 legal six-model Thunderwolf distributions. It checks exact shield costs, wrong fields/types/model counts and Plasma caps. Integration checks cover atomic invalid-edit rejection, second-process bank reopen, stable IDs, source weapons and Wounds, actual bearer defense/totem lookup, no repeated setup choices, exact saved-lock rejection messages with full non-mutation, match save/reload and source-army isolation. Native Workshop signals check Plasma rejection/reversion, the five-point shield increment and free Wulfen replacements. Every Godot batch disables network and stages the historical starter; deferred network checks are not reported as passed.

## Screen brief and actual Godot captures

Player goal: configure each miniature's reusable package, understand the Plasma limit and shield price, then save once before starting a match. Existing per-model rows, native selectors, copy picker, gold/black theme, typography and Save footer are retained. Thunderwolf labels state the per-three Plasma limit and five-point shield price. Each Wulfen row exposes Totem/launcher, preserving the different default on the shield datasheet. Invalid choices retain the draft and restore the actual selector with existing source-limit feedback. Optional assets do not block saving; no browser dependencies, generated artwork or animation were introduced. Scripted signals do not prove keyboard/gamepad accessibility.

Actual Godot 4.7.2 Compatibility captures at 1280x800 compare `.tools/verification/20261114T144856361862Z/project` with `.tools/verification/20261114T150202525695Z/project`. Isolated APPDATA/XDG_DATA_HOME folders are under `.tools/space-wolves-squad-equipment-20261114/<before|after>/profile`. The same 13-model, three-unit army starts at 330/2000 points. Real selectors plus explicit Save produce Plasma/Shield/default on the three Thunderwolves, a launcher on normal Wulfen model 1 and a Totem on shield Wulfen model 1. The total becomes 335 only from the cavalry shield. All six captures were inspected. Both processes exited 0 with texture/RID/ObjectDB shutdown diagnostics; clean render shutdown is not claimed.

| Profile | Before | After |
|---|---|---|
| Thunderwolf Cavalry | [Before](../../.tools/space-wolves-squad-equipment-20261114/before/thunderwolf-cavalry-before-1280x800.png) | [Independent pistol/shield packages](../../.tools/space-wolves-squad-equipment-20261114/after/thunderwolf-cavalry-after-1280x800.png) |
| Wulfen | [Before](../../.tools/space-wolves-squad-equipment-20261114/before/wulfen-before-1280x800.png) | [Launcher on one model](../../.tools/space-wolves-squad-equipment-20261114/after/wulfen-after-1280x800.png) |
| Shield Wulfen | [Before](../../.tools/space-wolves-squad-equipment-20261114/before/wulfen-with-storm-shields-before-1280x800.png) | [Totem on one model](../../.tools/space-wolves-squad-equipment-20261114/after/wulfen-with-storm-shields-after-1280x800.png) |

The ignored fixture `capture_equipment.gd` was run with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_space_wolves_squads.gd -- <output folder> <before|after>`. No model downloads occurred. Capture evidence SHA-256: `d62a3735c5339c6bdd5c53f5d435f512f08c8d54c716a9ee5f31ab086e2e731a`.

These are scripted runtime observations, not mockups, human playtests, sculpt reviews, full deployment, complete army legality or separate-machine LAN evidence. The [original plan gates](../project/army-configuration-plan-status.md) remain open.

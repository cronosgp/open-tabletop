# Saved Black Templars Gladiator equipment - 14 November 2026

Black Templars Gladiator Lancer, Reaper and Valiant now save their additional Multi-melta per independent vehicle copy in the Army Workshop. Source pricing counts every equipped Multi-melta, including the Valiant's two fixed weapons. The Add form now includes priced default equipment consistently with saved totals and admission.

## Verified local source

The local Wahapedia 11e source is `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Final retrieval bracket: `2026-10-30T01:33:48.347556+00:00`; individual timestamps remain in the manifest. All 22 CSV hashes were rechecked. The three sheets belong to Black Templars App book `000000162`, common 40K datasheet/points context; alternate modes and whole-army legality are outside this review. No online resolution was needed.

| Source file | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

| Black Templars sheet | ID | Base cost copies 1-2 / 3+ | Saved default / additional weapon, copies 1-2 | Saved default / additional weapon, copy 3+ |
|---|---|---|---|---|
| Gladiator Lancer | `000002787` | 165 / 185 | 165 / 175 | 185 / 195 |
| Gladiator Reaper | `000002789` | 165 / 185 | 165 / 175 | 185 / 195 |
| Gladiator Valiant | `000002788` | 145 / 165 | 165 / 175 | 185 / 195 |

Each sheet permits one additional Multi-melta and lists a ten-point price per Multi-melta. Valiant's default loadout explicitly includes two, so its saved default pays 20 in addition to the base; the optional third adds another 10. Lancer/Reaper have no fixed Multi-melta. These are Chapter-specific choices and cost tables, not options inferred from the generic shared-book sheets.

All three source Multi-melta rows match the already verified Land Raider weapon: name Multi-melta, range 18, attacks 2, BS 3, Strength 10, AP -3, damage D3+2, Melta 3. The adapter reuses that exact record, giving the optional weapon a distinct `gladiator-additional-multi-melta` attack-selection ID. The Valiant's fixed left/right weapons remain untouched. Existing default characteristics, weapons, abilities, Chapter boundaries and footprints remain in [the vehicle audit](../marine-black-templars-vehicles.md).

The runtime source profiles and digest `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68` were not rewritten. The existing BT verified-against slice hash is `49b1df5633b88744e6b4f9ee60d0b1e3841178e2ed9bcb76c3eab021efba3f97`; extraction and verification provenance remain separate. Three exact-field source equipment reviews bring the ledger to 85 detected schemas, 26 explicit completeness audits, 87 fixed-equipment profiles and 32 migrations pending. The other 59 schemas still need completeness review. No full rules or army-legality certification follows.

## Pricing, persistence and player experience

The single-model adapter validates an exact typed boolean, materializes the optional weapon before Deployment and binds the saved record to the frozen copy. These options were previously absent from the Workshop and have no legacy Gladiator preparation endpoint to remove. The generic transport setup route rejects these non-transport units. Existing matches without these records keep their frozen selection; editing the source army does not modify a saved match.

`Roster.default_equipment_points` supplies default equipment pricing to both the Add summary and model-size/copy-tier labels. `addition_cost` uses this value along with source tiers and composition costs. This also corrects the existing common Executioner Add preview to include its default Laser surcharge. Saved totals/admission retain their existing canonical pricing path. The fixture covers the precise 330-point default pair of Valiants, rejection at 340 after adding one optional weapon, and a valid next-two-copy addition of 350 after the first 165-point Valiant, for a 515-point final army.

Player goal: choose an additional weapon on the intended vehicle, see its ten-point effect, and save before starting a match. Existing Unit inspector Label/OptionButton controls, copy selection, gold/black theme, native focus behavior, typography and Save footer are reused. Exact copy prices appear in the Add form; fixed Valiant weapons are retained automatically. Invalid records fail closed. Optional visuals do not block saving, and built-in fallback miniatures remain visible. No new art, browser dependencies or animation were added. Scripted signals do not prove keyboard/gamepad accessibility.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_templar_gladiator_saved_loadouts --only test_black_templars_vehicles --only test_space_marine_copy_cost_parity --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_templar_gladiator_saved_loadouts --only test_army_builder --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Result | results.json SHA-256 |
|---|---|---|
| `20261114T143112569076Z` | Passed 5/5 before the Add-preview correction; no cleanup diagnostics. | `bd236a941b08c500e457b918dc6ebb789e37909522eebfb05a487258826a2793` |
| `20261114T143332223037Z` | Passed 6/6 including the corrected Add widgets, existing Army Builder, transports and catalog. Army Builder/catalog shutdown diagnostics remain recorded. | `ae8d4f7a6189cf95e2d9b7f7d2a09248caac7dd090de7276aecdff1df9bac472` |

The Python equipment ledger suite passed six tests.

The dedicated fixture covers both choices on all three identities, exact source weapon fields and distinct weapon IDs, preservation of both Valiant fixed weapons, per-weapon and third-copy prices, strict types/model counts, budget enforcement, independent stable copies, bank reopen in a second Godot process, both-player materialization, the actual weapon selector, rejection by the transport setup route, match save/reload and source-army isolation. A nine-copy mixed army totals exactly 1,605 across builder, admission and each player's materialized squads. Real Workshop signals check the ten-point increments; actual Add widgets check the default and third-copy labels and valid two-copy price.

All Godot runs disable network and stage the historical starter fixture. Cleanup diagnostics are reported separately from process success. No deferred network check is reported as passed.

## Actual Godot captures

Actual Godot 4.7.2 Compatibility at 1280x800 compares `.tools/verification/20261114T060841774860Z/project` with `.tools/verification/20261114T143332223037Z/project`. Isolated APPDATA/XDG_DATA_HOME folders are under `.tools/templar-gladiator-equipment-20261114/<before|after>/profile`. Both final capture processes exited 0, with texture/RID/ObjectDB shutdown diagnostics. The first capture fixture attempt needed an explicit Node type and failed before producing evidence; it was corrected for both final runs.

The same three-vehicle army totals 475 in the old baseline, which omitted the fixed-pair price. Its corrected saved default is 495, and real selector signals plus Save increase it to 505, 515 and 525. The Add-form comparison uses one default Valiant and two proposed additions: the old preview incorrectly shows 145, 310 added and 455 total; the current preview shows 165, 350 added and 515 total, with the 185-point third-copy default label.

| State | Before | After |
|---|---|---|
| BT Gladiator Lancer | [Before](../../.tools/templar-gladiator-equipment-20261114/before/black-templars-gladiator-lancer-before-1280x800.png) | [Additional weapon](../../.tools/templar-gladiator-equipment-20261114/after/black-templars-gladiator-lancer-after-1280x800.png) |
| BT Gladiator Reaper | [Before](../../.tools/templar-gladiator-equipment-20261114/before/black-templars-gladiator-reaper-before-1280x800.png) | [Additional weapon](../../.tools/templar-gladiator-equipment-20261114/after/black-templars-gladiator-reaper-after-1280x800.png) |
| BT Gladiator Valiant | [Before](../../.tools/templar-gladiator-equipment-20261114/before/black-templars-gladiator-valiant-before-1280x800.png) | [Optional third weapon](../../.tools/templar-gladiator-equipment-20261114/after/black-templars-gladiator-valiant-after-1280x800.png) |
| Valiant Add preview | [Before](../../.tools/templar-gladiator-equipment-20261114/before/valiant-addition-preview-before-1280x800.png) | [Default gear and copy tiers included](../../.tools/templar-gladiator-equipment-20261114/after/valiant-addition-preview-after-1280x800.png) |

All eight final captures were inspected. The ignored fixture `capture_equipment.gd` was run with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_gladiator_equipment.gd -- <output folder> <before|after>`. No model downloads occurred. Capture evidence SHA-256: `0bfe7f063c8ecedbc7567b659d545c554fc61c5709828c4db2a3a2b73cb8a4ba`.

These are scripted runtime observations, not human playtests, sculpt reviews, full deployment, input-device coverage or separate-machine LAN evidence. The [original plan gates](../project/army-configuration-plan-status.md) remain open.

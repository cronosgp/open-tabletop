# Character and artillery saved equipment — 14 November 2026

## Delivered scope

The Army Workshop now saves the complete source-listed equipment options for Execrator, Lieutenant in Phobos Armour, Chaplain in Terminator Armour and Rapier Carrier against each stable model/copy identity. Canonical admission validates the saved values, match materialization applies exact existing local weapon profiles after source defaults, and preparation suppresses and rejects repeated changes. Existing costs, copy limits, Chapter restrictions, geometry and Legends labels are preserved.

| Profile | Source book / datasheet | Saved option scope |
|---|---|---|
| Execrator | Black Templars App `000000162` / `000004135` | Absolvor Bolt Pistol or Hand Flamer; extra Master-crafted Power Weapon only with the Absolvor. Three legal packages; the conflicting fourth combination is rejected. |
| Lieutenant in Phobos Armour | Space Marines App `000000139` / `000002530` | Special-issue Bolt Pistol or Master-crafted Bolt Carbine; combat blades retained. |
| Chaplain in Terminator Armour | Space Marines App `000000139` / `000000115` | Storm Bolter or Relic Shield; Crozius retained, shield bearer has exactly one extra Wound (5 → 6). Reapplying preparation does not accumulate Wounds. |
| Rapier Carrier | Warhammer Legends `000000356` / `000000110` | Quad Heavy Bolter, Graviton Cannon, Laser Destroyer or Quad Launcher; fixed Boltgun/Armoured Hull and both Quad Launcher modes retained. |

These are saved-equipment migrations, not new datasheet-rule implementations or full army-legality certification. Rapier retains its existing Legends/event and circular footprint-proxy boundaries. Earlier audits remain authoritative for abilities and geometry: [Execrator](../marine-execrator.md), [Phobos Lieutenant](../marine-lieutenant-phobos-armour.md), [Terminator Chaplain](../marine-terminator-chaplain.md) and [Rapier](../marine-rapier-carrier.md).

## Source and schema review

The local source is `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. The final retrieval bracket is `2026-10-30T01:33:48.347556+00:00`; individual retrieval timestamps remain in its manifest. Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. All 22 CSV hashes were rechecked using the existing local audit reader. No online source resolution was needed.

The five relevant `Datasheets_options.csv` rows (two Execrator groups, one for each other profile) were read locally. Its SHA-256 is `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`; `Datasheets.csv` is `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`, and `Source.csv` is `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`. Book identities and edition 11 were already validated by the equipment classification batch. Existing runtime verification slice bindings are `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535` (shared App), `49b1df5633b88744e6b4f9ee60d0b1e3841178e2ed9bcb76c3eab021efba3f97` (Black Templars) and `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c` (Legends).

The source-review registry records these four as `saved_equipment_options_reviewed` using `saved_equipment_source_audit`, bound to runtime provenance and the exact saved-field set. The ledger reports `saved_schema_source_reviewed` only when that explicit record still matches; changed/missing fields, missing evidence or stale provenance invalidate it. This reviews equipment-option completeness only. Runtime verification gates remain distinct; the exporter does not infer them from schema presence or turn tests into whole-datasheet certification.

At this checkpoint the 204-profile ledger has **63 detected schemas**, **4 explicit equipment-source schema reviews**, **87 fixed-equipment profiles** and **54 option-bearing migrations**. The other 59 detected schemas still require source-option completeness review. Raw export tables and generated captures stay local and ignored.

## Verification

The first command used an incorrect suite name, `test_lieutenant_phobos_armour`; the verifier rejected it before running. The actual suite is `test_phobos_lieutenant`.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_character_artillery_saved_loadouts --only test_execrator --only test_phobos_lieutenant --only test_terminator_chaplain --only test_rapier_carrier --timeout 300
```

The initial executable batch passed 5/7 processes, but remains **failed** at `.tools/verification/20261114T044047316763Z/results.json`, SHA-256 `616baaea207bc5a04fbb0098e505c0418c7dca97844788389bada911383efe45`. The new fixture omitted the point/roller arguments to `UnitActions.apply`; the pre-existing Phobos test also assumed no reserve choice could exist for its mixed unit. Execrator, Terminator Chaplain and Rapier source regressions passed. Network was disabled, the historical starter fixture was staged, and this report recorded no cleanup diagnostics.

After correcting the fixture call, saved-equipment and consolidated catalog checks passed **4/4 processes**:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_character_artillery_saved_loadouts --only test_implemented_catalog --timeout 300
```

Report `.tools/verification/20261114T044207834746Z/results.json`, SHA-256 `4afef4c72a42448a7b11f8bfd84f54519ef64560513d9a68ca35ae2ecfee7f20`; network disabled, historical starter staged. The catalog process reported RID/ObjectDB shutdown diagnostics; the other processes did not.

The Phobos expectation now checks the actual distinction: the mixed attached unit may enter ordinary Strategic Reserves, and its stored ingress record must have `deep_strike: false`. The test submits the choice through the public normalized command path; no reserve rules were changed by this increment. The new saved-equipment fixture also exercises every Workshop selector and rejection/reversion of the conflicting Execrator pair.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_character_artillery_saved_loadouts --only test_phobos_lieutenant --only test_unit_reserves --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The corrected final Godot batch passed **5/5 processes** at `.tools/verification/20261114T044537078478Z/results.json`, SHA-256 `e829619848a5f4889ee54e094b6e95afbeca9c52d2bfd18f1b915855b82d2849`; network disabled, historical starter staged, no cleanup diagnostics. The Python source-review suite passed **6 tests**, including exact-field binding, stale/missing-evidence rejection and end-to-end ledger rendering after schema fields change or disappear.

The equipment fixture checks all eleven source-listed packages via typed schema validation and exact existing local weapon factories, conditional conflicts, unknown values/types, one-model scope, independent default/configured copies for both players, current-catalog admission, separate-process army-bank reopen, match save/reload, later source-army edits, duplicate-choice suppression and non-mutating forced-edit rejection. It also exercises actual Workshop option signals for all four profiles. It does not certify full army legality, sculpt parity, all combat interactions or separate-machine LAN.

## Design and actual Godot captures

Player goal: select each model's reusable equipment before starting a match, see the weapon names and conditional restriction, save locally and recover from an invalid combination without losing the draft. The shared Unit inspector retains its Label/OptionButton controls, existing fonts/colors, per-copy selection and explicit Save footer. No browser dependencies, artwork, animation or new layout system were added. Invalid combinations preserve the draft, restore the control's actual value and display the existing source-limit feedback; optional assets do not block saving.

The before project is `.tools/verification/20261114T042644029990Z/project`; the after project is `.tools/verification/20261114T044537078478Z/project`. Both used actual Godot 4.7.2 Compatibility rendering at 1280×800, isolated APPDATA/XDG_DATA_HOME beneath `.tools/character-artillery-20261114/<before|after>/profile`, the same four-profile 270/2000-point army and built-in fallback miniatures. The after fixture edits through each real OptionButton signal and explicitly saves; it scrolls the existing inspector to the new equipment controls.

| Profile | Before | Saved selector after |
|---|---|---|
| Execrator | [Before](../../.tools/character-artillery-20261114/before/execrator-before-1280x800.png) | [Hand Flamer; extra weapon not equipped](../../.tools/character-artillery-20261114/after/execrator-after-1280x800.png) |
| Phobos Lieutenant | [Before](../../.tools/character-artillery-20261114/before/lieutenant-in-phobos-armour-before-1280x800.png) | [Master-crafted Bolt Carbine](../../.tools/character-artillery-20261114/after/lieutenant-in-phobos-armour-after-1280x800.png) |
| Terminator Chaplain | [Before](../../.tools/character-artillery-20261114/before/chaplain-in-terminator-armour-before-1280x800.png) | [Relic Shield (+1 Wound)](../../.tools/character-artillery-20261114/after/chaplain-in-terminator-armour-after-1280x800.png) |
| Rapier | [Before](../../.tools/character-artillery-20261114/before/rapier-carrier-before-1280x800.png) | [Quad Launcher](../../.tools/character-artillery-20261114/after/rapier-carrier-after-1280x800.png) |

All eight captures were inspected; both processes exited 0. Their logs retain render texture/RID/ObjectDB shutdown diagnostics, so clean shutdown is not claimed. The ignored fixture is `.tools/character-artillery-20261114/capture_equipment.gd`. It was copied into each staged project's `.tools` and run with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_equipment.gd -- <output folder> <before|after>`. No model download was performed. The ignored `capture-evidence.json` records all hashes, SHA-256 `ff30da7fd33e2850a6d8e7d7c82ee41ef2a22a40e684900a65a28f9c6f917485`.

The baseline has no persistent selectors for these four profiles, while the after captures show actual saved equipment controls. This is scripted runtime observation, not a human playtest, keyboard/gamepad coverage, physical-sculpt review or complete match integration. The remaining 54 migrations, 59 other schema completeness reviews and the [original plan acceptance gates](../project/army-configuration-plan-status.md) stay open.

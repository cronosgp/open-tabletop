# Battle Readiness declaration feedback — 14 November 2026

## Screen brief

The player should finish a configured army without repeating persistent choices. At 1280×800, readiness status and the primary finish action must precede a long saved-equipment summary. Keep the existing Godot containers, typography, gold controls, green ready indicator and warning colors; change information order and copy only. Use text as well as color to distinguish ready, required, optional and waiting states. Preserve source-sensitive rules and current host/guest restrictions.

The title is **Player … · Battle Readiness**. When the existing rules probe permits finish, show **Required declarations are complete. Other changes are optional.**, expose **Finish Player …'s army** before saved equipment, and label remaining alternatives **Optional declaration changes / Apply optional change**. When the probe rejects finish, retain its actionable error, the required-declaration label and the disabled finish action. The currently assigned Warlord has no redundant picker entry; alternative eligible Warlords remain an explicit optional change. Rules choices remain validated on submission. No new animation, assets or dependencies are introduced.

## Implementation and checks

`scripts/main.gd` orders the finish control in the actual command-panel group, not just its original parent. It derives optional/required copy from the existing finish validation on a copied state and omits the already-applied Warlord from presentation choices. It does not remove authoritative rule choices, complete preparation automatically or change saved declarations.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --only test_saved_armies --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 300
```

The first report `.tools/verification/20261114T042246195529Z/results.json` passed import, Python and saved armies, but failed the new UI fixture because its direct Warlord submission omitted the normalized decision envelope. SHA-256: `eea708ff8202101e1f203d31e8005a2dffc765bd28b03b2329909750e947f68f`. That run remains failed evidence.

The fixture now submits through `_unit_choice_payload`, the same decision envelope as the UI. The corrected report `.tools/verification/20261114T042644029990Z/results.json` passed **3/3 processes**, SHA-256 `f5e0ac6fa86c33234d574ace20322937c21c61e85f26e080c1e1d2166e629e32`. It verifies missing-Warlord blocking, a valid declaration, optional alternatives after validation, omission of the already-assigned model, unchanged authoritative state after refresh, finish before the equipment summary, and Player 2's independent required declaration. Both reports used no network; UI and saved-army processes recorded RID/ObjectDB shutdown diagnostics. They do not establish clean shutdown or LAN behavior.

## Actual Godot evidence

The [earlier preparation capture](../../.tools/army-builder-review-20261114/captures/review-preparation-1280x800.png) is the before state. All four new captures were made in actual Godot 4.7.2 Compatibility mode at 1280×800 and inspected:

- [Workshop](../../.tools/army-builder-readiness-20261114/captures/review-workshop-1280x800.png): saved per-model equipment and unavailable manual appearance retained with fallback.
- [Readiness](../../.tools/army-builder-readiness-20261114/captures/review-readiness-1280x800.png): both 365-point armies locally ready despite the missing appearance.
- [Preparation](../../.tools/army-builder-readiness-20261114/captures/review-preparation-1280x800.png): finish is visible above saved equipment; remaining Strategic Reserves declaration is explicitly optional; saved Warlord is not requested again.
- [Deployment](../../.tools/army-builder-readiness-20261114/captures/review-deployment-1280x800.png): both player-finish actions reach placement with visible built-in miniatures and no equipment or Warlord reselection.

The script ran against `.tools/verification/20261114T042644029990Z/project` with isolated APPDATA/XDG_DATA_HOME `.tools/army-builder-readiness-20261114/profile`. Godot arguments were `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_builder_flow.gd`. The retained fixture is `.tools/army-builder-readiness-20261114/capture_builder_flow.gd`; it explicitly disables optional model downloads. The process exited 0, with render texture/RID/ObjectDB shutdown diagnostics retained in `capture.log`. The ignored `capture-evidence.json` records artifact hashes and has SHA-256 `abd8f1cc86f631e37fb087e8ad40d5a73f54faa85b623503f7524fc62c4d183e`.

This is a scripted runtime observation, not a manual playtest or keyboard/gamepad coverage. Equipment inspector content still scrolls below the captured viewport. Other sizes, complete deployment, interruption/recovery and separate-machine validation remain open. See the [full plan completion gates](army-configuration-plan-status.md).

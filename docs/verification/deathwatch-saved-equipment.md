# Deathwatch saved equipment — 15 November 2026

## Source identity and scope

This migration uses the project's selected local Wahapedia 11th-edition Data Export. The verified snapshot is `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 2026-10-30 at 01:33:48 UTC, with export revision `2026-10-28T23:48:19+03:00` and manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. The Deathwatch source is App book `000000035`, edition 11, errata date 3 October 2026. The source rows are Deathwatch Veterans datasheet `000002783` and Deathwatch Terminator Squad datasheet `000003873`.

The raw snapshot files remain local and out of Git. Relevant hashes:

| File | SHA-256 |
|---|---|
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The relevant exported tables contain nine Veterans equipment-option rows and two Terminator equipment-option rows. Their supported 5/10-model sizes and existing source runtime factories are preserved; this is not a new composition or faction rules implementation.

## Saved options

For Deathwatch Veterans, the Watch Sergeant may replace the Boltgun with a Combi-weapon and the Power Weapon with a Xenophase Blade. Each group of five ordinary Veterans permits one Stalker-pattern Boltgun, one Infernus Heavy Bolter, one Frag Cannon, up to two Deathwatch Shotguns, up to two Heavy Thunder Hammers, and up to two combined Boltgun/Storm Shield or Power Weapon/Storm Shield packages. One Veteran in the unit may instead take Black Shield Blades. These options have no equipment surcharge; base unit prices remain 115 points for five and 220 for ten.

For Deathwatch Terminators, each model's Power Fist/Storm Bolter package can be replaced by Storm Bolter/Chainfist, Storm Bolter/Power Weapon, Thunder Hammer/Storm Shield, or Twin Lightning Claws. Up to three ordinary Deathwatch Terminators can replace their Storm Bolter with an Assault Cannon, Cyclone Missile Launcher plus retained Storm Bolter, Heavy Flamer, or Plasma Cannon. The Sergeant's ranged-special selector is fixed to the Storm Bolter by the existing local role contract. Base prices remain 190/380 for the first two copies and 230/420 for third-and-later five/ten-model copies. Each Storm Shield adds five points and one Wound to its bearer; each Cyclone Missile Launcher adds ten points.

## Implementation

`deathwatch_saved_equipment.gd` validates exact per-model records, source roles, whole-squad caps, shield/special interactions and source-based prices. Saved records use the existing stable model/copy roster storage and local Deathwatch weapon factories. Admission and match materialization apply the saved weapons and bearer defense/Wound changes before Deployment. Saved-equipment locks suppress repeated setup choices and reject direct forced changes without mutating the match. Existing live abilities and activation decisions remain outside this saved equipment record.

The Army Workshop presents these two dense profiles as model cards: role name above, with up to two labeled equipment selectors below. This avoids the Terminator Sergeant/regular-model names collapsing to one character per line in a flat horizontal row. Other profile layouts are unchanged.

## Verification

The final targeted run passed 11/11 processes:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_deathwatch_saved_loadouts --only test_deathwatch_terminator_squad --only test_deathwatch_veterans --only test_terminator_saved_loadouts --only test_deathwing_saved_loadouts --only test_specialist_squad_saved_loadouts --only test_model_equipment_visuals --only test_army_builder --only test_implemented_catalog --timeout 300
```

Report: `.tools/verification/20261115T053213457489Z/results.json`, SHA-256 `e131b4e8074b58d3ced58c74dddb10fe6152c39672e241431b818a5072f89fe7`. Networking was disabled; the verifier staged its legacy starter. `test_army_builder` and `test_implemented_catalog` exited successfully with headless RID/ObjectDB shutdown cleanup diagnostics; the other nine processes reported no cleanup diagnostics. See the exact counts in the report logs and [verification history](verification-results.md).

Actual Godot 4.7.2 Compatibility captures use a 1280×800 viewport. Same-fixture saved-equipment captures before and after the layout correction are in the ignored `.tools/deathwatch-equipment-20261115/before-layout/` and `.tools/deathwatch-equipment-20261115/after/` folders. Both Veterans and Terminator screens were inspected; the pre-correction Terminator row wraps its model name vertically, while the corrected view shows the Sergeant and ordinary model controls in readable cards. The visible list continues below the viewport and uses its scrollbar. The earlier baseline screen from `.tools/deathwatch-equipment-20261115/before/` predates the saved Deathwatch controls entirely, so it is not the layout comparison.

The coverage exporter records these two fields as source-option reviewed and equipment migrated. This evidence does not establish every Deathwatch rule, full army legality, sculpt parity, other viewport/device usability, a separate-machine LAN session or broader failure-recovery coverage.

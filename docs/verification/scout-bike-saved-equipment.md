# Scout Bike Squad saved equipment — 15 November 2026

## Rules and source boundary

This slice moves the two already-audited equipment choices for Scout Bike Squad into the Army Workshop. The profile remains Warhammer 40,000 11th edition, Space Marines, book `000000356` (Space Marines, Warhammer Legends), datasheet `000000137`. This is an equipment-option migration for the existing Legends profile. It does not expand construction composition, certify event eligibility or certify full army legality. The project’s Legends use label and event boundary remain in force.

The verified local source bundle is `.tools/marine-full-space-readiness-20261030/space-marines-legends-faction-28`. Its `manifest.json` SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`; the manifest identifies parent export manifest `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, retrieved `2026-10-30T01:33:48.347556Z`, with export update `2026-10-28T23:48:19+03:00`. The exact local command revalidated the 28-subject 11e Legends slice with zero in-scope validation findings:

```powershell
python tools/audit_space_marine_extended_slice.py --slice-root .tools/marine-full-space-readiness-20261030/space-marines-legends-faction-28 --expected-book-id 000000356 --expected-count 28 --output .tools/scout-bike-slice-audit-20261115.json
```

The resulting source-only audit SHA-256 is `e84cccba5299461a0a5504232ad554895c4c31dc13f9aec1f5530325bdf5da04`. The audit tool reports `runtime-admitted=0` and `playable-certified=0` because it validates the source slice only; those fields do not change the separate runtime catalog admission.

The slice manifest binds the filtered raw files to these SHA-256 values:

| Source file | Filtered slice SHA-256 | Parent export SHA-256 |
|---|---|---|
| `Datasheets_options.csv` | `6d0606fffae83d2928333a04664dee6c3b59a7d14b9f46480e8efae9ed7d9d08` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_models_cost.csv` | `133787b7d71432e4cfbf585f366d703825451eb60e174a913616516007562eb1` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `8da7df62e8e3b1c7eabd64b8073872ab12b7d662282b8827c00f9fc9a7c0897f` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The existing machine-readable Scout Bike audit contains per-file hashes (`44a652…` for options and `023637…` for model costs) that do not match these filtered raw files. The migration therefore binds its review to the exact slice manifest and its verified filtered hashes above, with the parent hashes separately recorded; the older audit record was not silently rewritten. No online source was needed.

The two source option rows say that any number of models may replace Twin Boltgun with Grenade Launcher, and that the Scout Biker Sergeant may replace Bolt Pistol with one of eleven listed choices: Boltgun, Chainsword, Combi-weapon, Grav-pistol, Hand Flamer, Inferno Pistol, Plasma Pistol, Power Fist, Power Weapon, Storm Bolter or Thunder Hammer. Both are free. The local cost rows price 3 models at 75 points and 6 at 150; first, second and third-plus costs remain identical. Existing copy limits remain two at Incursion and three at Strike Force.

## Saved behavior

The shared saved-equipment registry now includes a Scout Bike adapter with one stable model record per biker. Each record stores the optional Grenade Launcher, while only model zero (the Sergeant) may change the Bolt Pistol field. All twelve Sergeant states are resolved by the existing local Legends weapon factory. Invalid roles, sizes, fields and options are rejected. No equipment points are added.

Saved loadouts flow through local catalog admission and materialization for both players. Saved equipment is fixed in the match: the old setup choices are suppressed, and a forced choice is rejected without state mutation. Unit roles, existing 3/6-model composition, costs, copy caps, Scouts, Combat Doctrines, Outflank and weapon profiles were not changed. The older source-bounded live setup test still passes.

The restart regression saves two distinct three-model copies and one six-model copy, opens the saved bank in a separate Godot process, verifies all independent Sergeant/launcher choices and source totals, and compares every prepared model's saved record and weapons with the exact local factory. It also exercises the real Workshop selector signals, rejects a Sergeant-only edit on a regular Biker, and checks that all six named cards are available in the scrollable inspector.

## Actual Godot evidence

These are captures from the staged Godot 4.7.2 Compatibility renderer at 1280×800, inspected from the generated PNG files:

- [Three-model copy with Sergeant Thunder Hammer and two Grenade Launchers](../../.tools/scout-bike-equipment-20261115/after/scout-bike-squad-3-saved-1280x800.png)
- [Six-model copy, upper cards](../../.tools/scout-bike-equipment-20261115/after/scout-bike-squad-6-saved-1280x800.png)
- [Six-model copy, lower cards](../../.tools/scout-bike-equipment-20261115/after/scout-bike-squad-6-saved-lower-1280x800.png)
- [Capture state and stable model labels](../../.tools/scout-bike-equipment-20261115/after/observations.json)

The capture process exited 0 and displayed the saved controls and role labels. It also logged texture RID and 55 ObjectDB shutdown cleanup warnings. These captures show state and layout; they are not a human usability review, exact sculpt review, smaller-window check or event-acceptance result.

## Verification

The final focused offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_scout_bike_saved_equipment --only test_scout_bike_squad_legends --only test_ravenwing_saved_equipment --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --timeout 300
```

It passed **8/8 verifier processes** (import, Python and six selected suites) at `.tools/verification/20261115T072732806232Z/results.json`, SHA-256 `8ca24610a4a3a83ac308396a9261f291a2798ea1cb7d600c282aa9f1f9ee9823`. Network was disabled and the historical starter was staged. Army Builder and catalog suites exited successfully with existing headless RID/ObjectDB cleanup diagnostics; the other selected suites reported none. The Python coverage ledger suite also passed after the source-review update.

This verifies the local saved-equipment contract, save/reopen, admission, per-model materialization, setup lock and visible Workshop controls against the bounded Legends source data. It does not certify all Scout Bike rules, competitive event use, exact visual sculpt/loadout parity, full Space Marines/army legality, human usability, separate-machine LAN or completion of the Army Builder/ForceOrg plan.

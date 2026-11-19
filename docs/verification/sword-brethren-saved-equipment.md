# Sword Brethren saved equipment — 15 November 2026

## Source and boundaries

This migration is for the admitted Black Templars 11th-edition Sword Brethren Squad profile, App book `000000162`, datasheet `000002798`. The selected local source is snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556Z`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. The raw local CSV hashes were rechecked before migration:

| Export file | SHA-256 |
|---|---|
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The five equipment rows allow up to two Heavy Bolt Pistols to become Hand Flamers per four models, any number of Chainswords to become Master-crafted Power Weapons, and one replacement per four for a Thunder Hammer, Plasma Pistol or Twin Lightning Claws. The saved selector exposes the ten complete packages supported by the existing local Sword Brethren factory. Whole-copy validation independently enforces the four source caps using `floor(models / 4)`; the Power Weapon replacement has no additional cap.

Only the locally priced sizes 4, 5, 9 and 10 are offered. First/second copy prices remain 115, 140, 250 and 275 points; third-plus prices remain 135, 160, 270 and 295. The equipment rows add no points. Sizes 6–8 remain blocked because the verified export has no price rows; prices are not interpolated. Existing copy limits, Chapter/game-mode gates and the source profile are unchanged. This is not full Black Templars/Space Marines rules or army-legality certification.

The older [datasheet audit](../marine-sword-brethren-squad.md) records the 21 October source extraction and the local rules/combat scope. This migration additionally binds its equipment review to the verified 30 October runtime snapshot above; it does not silently rewrite the historical audit's extraction identity.

## Saved behavior

`sword_brethren_loadout` is saved per stable model and unit copy through the shared Army Builder equipment registry. Defaults are optional for existing lists and represent the source Heavy Bolt Pistol + Chainsword package. Admission rejects unknown fields, values, sizes and short model arrays. The adapter uses `sword_brethren_model_loadout` for exact local weapon profiles and validates all model IDs together against the independent per-four limits.

Before Deployment, each saved model receives its exact ranged/melee weapons and saved record. The existing `sword-brethren-loadout` preparation choice is hidden for saved models, and a forced edit returns an error without changing match state. No new surcharge or composition rule was added. Standalone Army Preparation choices for unsaved/legacy training fixtures continue to use the existing behavior.

## Verification

The focused test checks every package at all four supported sizes, defaults and rejection cases, exact per-model weapon factories, four-/nine-/ten-model cap boundaries, unchanged first/second and third-plus prices, independent equipment across three copies, save/reopen in a separate Godot process, both-player current-catalog materialization, immutable match setup, and live Workshop selectors/signals for a ten-model roster. It passed alongside the existing Sword Brethren rules regression, Scout Bike regressions, catalog and model-visual checks.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sword_brethren_saved_equipment --only test_sword_brethren_squad --only test_space_marine_leader_links --only test_scout_bike_saved_equipment --only test_scout_bike_squad_legends --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --timeout 360
```

The overall selected batch was **8/10 verifier processes**, not a full pass. Report `.tools/verification/20261115T161551369141Z/results.json` has SHA-256 `0fed4a7bed241ca093b2a93ba0cda20dce31f55f019b9321271f9109239df506`; network was disabled and the legacy starter was staged. The two failing adjacent suites reported: `test_space_marine_leader_links` — an Orikan Necron Support relation target was missing; `test_army_builder` — the automatic appearance fixture did not select different sculpts for separate copies. The Army Builder test and implemented-catalog test also emitted shutdown RID/ObjectDB cleanup diagnostics. The Sword Brethren saved-equipment test and its original source/rules test both passed with no cleanup diagnostics. These failures remain open and are not presented as passing or as part of this profile's equipment evidence.

The actual Godot 4.7.2 Compatibility renderer was inspected at 1280×800. The four-model lower-scroll capture shows model cards 3–4; the ten-model top and lower captures show early and final cards. The complete control count, including models 1–2 in the four-model case, is asserted by the live Workshop test. Captures are review-only files in the gitignored `.tools/sword-brethren-equipment-20261115/after/` directory:

- `sword-brethren-4-lower-saved-1280x800.png` — SHA-256 `748587c8cd98ffd05994fb1153958cbfc7ee20ea242f04cc78452f08650ab321`
- `sword-brethren-10-saved-1280x800.png` — SHA-256 `0f45c4fe20b1853578f67e5876e67861c031cd42ebe2c3768a09787a206f9cc0`
- `sword-brethren-10-lower-saved-1280x800.png` — SHA-256 `19aa6c4712418de3899e1d3094b9b2b76a1ddda7c3ea21d64c864f6a7201f2a9`

The screenshot process exited successfully with texture/font/CanvasItem RID and ObjectDB cleanup diagnostics. Network validation, separate-machine LAN, final integration, human usability, exact sculpt parity and complete army legality remain open.

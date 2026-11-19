# Saved Terminator equipment — 14 November 2026

Terminator Squad, Terminator Assault Squad and Wolf Guard Terminators now save source equipment per stable miniature and copy. Full-unit validation enforces source roles and special-weapon caps; pricing includes Cyclones and shields. Prepared models receive exact inventories and bearer-only shield Wounds before Deployment. Saved equipment is locked against repeated setup; existing unsaved selections retain their preparation route.

## Verified local source and scope

Authority: `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot of the same name, revision `2026-10-28T23:48:19+03:00`, specification `20260817b`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. All 22 CSV hashes were rechecked. Standard/Assault use common Space Marines App book `000000139`; Wolf Guard uses Space Wolves App book `000000036`. This is common 40K scope, not alternate-mode or full-army certification. No online lookup was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| Datasheets_abilities.csv | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |

Runtime Marine digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`. Verified-against slice hashes remain `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535` (book 139) and `427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327` (book 36). Earlier extraction metadata and runtime export stamps remain separate and unchanged.

| Profile / datasheet | Source-bounded saved scope |
|---|---|
| Terminator Squad / `000001183` | 5/10 models for 190/380 points; third-plus 230/420. All start with Storm Bolter and Power Fist. Sergeant may take Chainfist or Power Weapon; ordinary Terminators may take Chainfist. One ordinary model per five may take Assault Cannon, Heavy Flamer, or Cyclone Missile Launcher with retained Storm Bolter. These share one allowance. Each Cyclone adds 10 points; Frag/Krak and Chainfist Standard/Hunter modes are retained. |
| Terminator Assault Squad / `000000118` | 5/10 models for 170/340 points; third-plus 210/380. Any model, including Sergeant, may replace Twin Lightning Claws with Thunder Hammer plus Storm Shield. Each shield adds 5 points and +1 Wound to its bearer. No replacement cap. No ranged weapons are introduced. |
| Wolf Guard Terminators / `000000318` | 5/10 models for 180/365 points; third-plus 220/405. All start with Storm Bolter and Master-crafted Power Weapon. Pack Leader may replace both with Relic Greataxe or Twin Lightning Claws. Any model may replace only the Storm Bolter with Storm Shield for 5 points/+1 Wound. One ordinary model per five may instead replace both weapons with Assault Cannon and Power Fist. Packages cannot stack incompatible replacements. |

All three profiles retain their baseline 4+ invulnerable save; the shields above add Wounds, not another defense bonus. Wounds are assigned from source base plus the saved shield flag, so repeated preparation cannot accumulate bonuses. Source weapon factories/additional profiles are reused. Common-book and Wolf Guard rules/composition/copy gates remain unchanged. See the [standard](../marine-terminator-squad.md), [Assault](../marine-terminator-assault-squad.md) and [Wolf Guard](../marine-wolf-guard-terminators.md) audits.

The new adapter exposes exact fields `terminator_melee_choice`/`terminator_special_weapon`, `terminator_assault_storm_shield`, and `wolf_guard_terminator_loadout`. Controls distinguish Sergeant/Pack Leader from ordinary models. Whole-copy validation prevents role-ineligible replacements or excess special weapons before admission. Prices are summed once during canonical admission; initial materialization preserves those totals, and forced gear commands cannot mutate inventories, Wounds or points. Locks cover only the four persistent equipment commands, leaving existing combat/declaration handlers unchanged. Deathwing and Deathwatch equipment schemas remain separate migration work.

Three exact-field source-option reviews bring the ledger to 101 detected schemas, 42 explicit completeness reviews, 87 fixed profiles and 16 migrations pending. Another 59 schemas still need completeness review. These counts are not full rules or army-legality certification.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_saved_loadouts --only test_terminator_squad_current --only test_terminator_assault_squad --only test_wolf_guard_terminators --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_deathwing_terminator_squad --only test_deathwatch_terminator_squad --only test_model_equipment_visuals --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

Main report `.tools/verification/20261114T160934262857Z/results.json` passed 6/6 processes (import, Python and all four selected Godot suites), with no headless cleanup diagnostics. SHA-256: `8b574d9b96b2f540ca8d840fa92a92459cd5bc8ba3039bc04ceeb07bcab746a9`. Network checks were disabled and the verifier staged the historical starter. Source accuracy and broader networking are not established by these tests alone.

Shared-command regression `.tools/verification/20261114T161217173205Z/results.json` passed 6/6 processes (import, Python, Deathwing Terminators, Deathwatch Terminators, model-equipment visuals and consolidated catalog). SHA-256: `89479cda2b55f94dfd527665ff3bdedb8b20c25c6bc15f992310a3d41ec9e8df`. Cleanup diagnostics are recorded only for the catalog; source/runtime gates remain bounded. The later Wolf Guard wording refinement changes display text only and was verified in the actual capture.

The exhaustive Assault/Wolf Guard matrix covers 80,112 unit distributions: every 5/10-model binary Assault distribution (1,056 legal) and all allowed-role Wolf Guard assignments (79,056 total; 192/29,696 legal at five/ten models). Standard Terminators separately cover every 1,584 legal melee distribution with a varying ordinary primary slot, and all 13/352 legal primary distributions with exact Cyclone costs. This is not an exhaustive cross-product of all standard melee/primary distributions. Additional role/package checks compare exact source weapons, retained Cyclone bolters, shield Wounds and fixed invulnerable saves, and call preparation twice to prove idempotence. Explicit role/cap failures and incomplete/unknown records fail closed.

The mixed fixture contains three five-model copies of each profile: nine units, 45 miniatures per player. Builder, canonical admission and both players' prepared squad sums are exactly 1,820 points, including third-copy premiums, three Cyclones, six Assault shields and four Wolf Guard shields. Each paid option also fails admission when added to an otherwise exact custom budget. Checks cover independent copies, separate-process bank reopening, stable model mapping, frozen inventories/Wounds, absence of repeated setup, saved-lock errors with complete state preservation, match save/reload and source-army isolation. Native signals check special-cap rejection/reversion and reversible five-point shield pricing; appearance sharing keeps the leader role separate. The ledger Python suite passed six tests.

## Screen brief and actual Godot captures

Player goal: configure reusable Terminator weapons by eligible role, understand paid launchers/shields and save once before starting a match. Existing native per-model rows, copy identities, gold/black theme, typography and Save footer are retained. Controls show the shared special limit, Cyclone's retained bolter and price, and shield price/+1 Wound. Fixed Sergeant Storm Bolter is disabled; invalid cap edits restore the draft/control. Wolf Guard labels retain the Master-crafted weapon name. Visual choices do not alter rules.

Real Godot 4.7.2 Compatibility captures at 1280×800 use isolated user-data paths with no model downloads. Before stage: `20261114T155932553033Z`; after stage: `20261114T160934262857Z`, with a later text-only refinement naming the shielded Master-crafted weapon. Both capture processes exited 0 and emitted renderer/ObjectDB cleanup diagnostics. All six before/after captures were inspected; the final Wolf Guard label was recaptured after its refinement. Ignored scripts, process results, observations and logs remain under `.tools/terminator-equipment-20261114/`.

Before shows the previous unit inspector without these model equipment rows. After shows Sergeant Power Weapon, ordinary Cyclone and Chainfist; Assault Sergeant hammer/shield; Wolf Guard Pack Leader Greataxe, ordinary cannon/fist and shield. The sample total progresses 540→550→555→560 as paid gear is selected. These are actual Workshop renders, not mockups, exact-sculpt evidence or full input/platform coverage. Scrolling and ten-model visual review remain broader acceptance work.

![Saved standard Terminator weapons and Cyclone cost](../../.tools/terminator-equipment-20261114/after/terminator-squad-after-1280x800.png)

![Wolf Guard role-specific saved packages](../../.tools/terminator-equipment-20261114/after/wolf-guard-terminators-after-1280x800.png)

Original plan gates remain open: 16 migrations, 59 completeness reviews, broader legacy/asset/restart/gallery recovery, human review and unequal-cache separate-machine LAN. Deferred checks are not reported as passed.

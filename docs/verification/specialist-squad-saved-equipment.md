# Saved specialist squad equipment — 14 November 2026

Eradicator Squad with Melta Rifles, Desolation Squad and Sternguard Veteran Squad now save equipment per stable miniature and copy. Whole-unit validation enforces role eligibility and weapon caps; pricing includes the Vengor surcharge. Preparation applies saved inventories before Deployment, and readiness rejects repeated gear setup. Existing construction sizes and copy gates are preserved.

## Verified local source

Authority: `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot of the same name, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. All 22 CSV hashes were rechecked. All three sheets belong to common Space Marines App book `000000139`; alternate modes and full army legality are not certified.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

Runtime Marine digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`; verified-against common-book slice hash remains `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535`. Extraction metadata and earlier runtime source stamps are preserved separately. Source profiles were not rewritten by this migration.

| Profile | Datasheet | Reviewed saved scope |
|---|---|---|
| Eradicator Squad with Melta Rifles | `000004249` | 3/6 models at 100/200 points, then 120/220 from the third copy. One ordinary Eradicator per three total unit models may replace Melta Rifle with Multi-melta. Sergeant retains Melta Rifle. Every model keeps Bolt Pistol and Ceramite Fists; Standard/Hunter modes retained. Free equipment. |
| Desolation Squad | `000002270` | Existing five-model/two-copy admission, 140 points per copy; recorded third-plus 150 remains outside that gate. Superfrag/Superkrak saved per model as in the existing source-bounded preparation route. Sergeant alone may take Vengor for 5 points. Every model retains Bolt Pistol, Castellan Launcher and Ceramite Fists. |
| Sternguard Veteran Squad | `000002255` | 5/10 models at 105/210 points, then 120/225 from the third copy. Sergeant keeps Artificer Firearm and may replace Chainsword with Power Fist or Power Weapon. One ordinary Veteran per five models may replace Artificer Firearm with Heavy Bolter or Pyrecannon, counted collectively. All retain Bolt Pistols; ordinary melee remains Ceramite Fists. Artificer modes remain firing choices. Free equipment. |

The adapter uses the existing exact source weapon factories and preserves combat abilities. Schema fields are `eradicator_multi_melta`, `desolation_rocket`, and `sternguard_gun`/`sternguard_melee`. Sternguard `default` melee resolves by source role: Chainsword for Sergeant, Ceramite Fists for an ordinary Veteran. Invalid role packages fail before admission; only complete legal loadouts contribute equipment points. The Vengor costs exactly five points per equipped Sergeant, and saved locks prevent a second runtime price mutation. Source selections without saved equipment keep their legacy preparation route, with the Eradicator eligibility correction below.

Three exact-field reviews bring the ledger to 98 detected schemas, 39 explicit source-option completeness reviews, 87 fixed profiles and 19 migrations pending. The other 59 schemas require completeness review. These figures do not certify all rules or full army legality.

## Eradicator source inconsistency resolved

The prior preparation code and test allowed the Sergeant to carry Multi-melta. The selected local option row names the ordinary Eradicator role, while its composition separately names the Sergeant. To resolve the implementation/source disagreement, the matching [current Wahapedia 11e Eradicator sheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eradicator-Squad-with-Melta-Rifles) was checked on 14 November 2026: its composition, option, sizes, prices and App Space Marines 11e marker match these selected local facts. The rendered page did not expose a separate export revision; no provenance substitution is claimed. The eligibility resolution follows those distinct role names, consistently with the Sternguard and Jump Intercessor role restrictions. This is an interpretation of the matching source roles, not a new FAQ claim.

Both saved validation and the legacy public setup route now restrict Multi-melta to ordinary Eradicators. The Sergeant has no setup choice, and a forced direct command fails without mutation. The old test now checks two/five eligible carriers at 3/6 models, explicit Sergeant rejection, ordinary restoration, cap rejection and both weapon modes. No historical match file is rewritten. The earlier captured Sergeant option is historical evidence of the corrected behavior, not current legality evidence.

The matching Desolation page and Core Rules 02.06/02.07 were also consulted while checking role/option wording. Desolation's page initially loaded its profile but later focused requests timed out; those requests did not establish additional rules. Its existing per-model rocket interpretation is retained from the selected local source/audit; no new general all-model wargear interpretation is asserted. Runtime network validation remains deferred.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_specialist_squad_saved_loadouts --only test_eradicator_melta_rifles --only test_desolation_squad --only test_sternguard_veteran_squad --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sergeant_squad_saved_loadouts --only test_model_equipment_visuals --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

Main report `.tools/verification/20261114T155637759613Z/results.json` passed 6/6 processes (import, Python and all four selected Godot suites). SHA-256: `320b2dc0ac0ac05118f8b095cbb4a310f34835227555050bd0653f5472e366c2`. The Desolation source suite emitted renderer/ObjectDB cleanup diagnostics; the new suite and other source suites did not. Network checks were disabled and the verifier staged the historical starter; this does not certify networking or current-source accuracy by itself.

Shared regression `.tools/verification/20261114T155932553033Z/results.json` passed 5/5 processes (import, Python, previous Sergeant-squad migration, model-equipment visuals and consolidated catalog). SHA-256: `202199447f92a0a1dc5ddf8d667126ac7208ea129c8cff558c1994642a205b3a`. The catalog emitted renderer/ObjectDB cleanup diagnostics. No runtime changes were needed after the main pass.

The exhaustive matrix tests 59,607 distributions with 583 legal outcomes: all 72 binary 3/6-model Eradicator distributions (3/16 legal), all 243 five-model Desolation distributions (48 legal), and 59,292 Sternguard distributions combining every ordinary primary-weapon assignment with each Sergeant melee choice at 5/10 models (27/489 legal). Additional role/package preparation checks compare full source inventories, secondary weapons and role melee. Atomic draft edits reject Sergeant Multi-melta, a third six-model Multi-melta, ordinary Vengor, Sergeant special guns, over-cap special guns and ordinary Sergeant melee.

The mixed fixture has three six-model Eradicator units, two Desolation units (one Vengor), and three ten-model Sternguard units. Builder, canonical admission and both players' materialized squad sums are exactly 1,550 points, including third-copy premiums. A 140-point custom budget accepts default Desolation and rejects the 145-point Vengor result. Checks cover separate-process bank reopening, independent copies and stable identities, exact frozen inventories, absence of repeated setup, saved-lock errors with whole-state non-mutation, match save/reload and isolation from later source-gear/price edits. Native selector signals verify Multi-melta cap rejection/reversion and reversible five-point Vengor pricing; role-aware appearance filtering is retained. The Python ledger suite passed six tests.

## Screen brief and actual Godot captures

Player goal: assign reusable specialist weapons to eligible miniatures, see caps and paid equipment, then save once before a match. Existing native rows, per-copy identity, gold/black theme, typography and Save footer remain. Labels state `Primary (1 Multi / 3)`, `Primary (1 special / 5)` and `Vengor (+5 pts)`. The fixed Eradicator Sergeant rifle, Sternguard Sergeant primary and ordinary Sternguard melee selectors are disabled. Invalid changes restore the control/draft. Visual assets remain presentation-only.

Real Godot 4.7.2 Compatibility captures at 1280×800 use isolated user-data paths and no model downloads. Before stage: `20261114T154547437952Z`; after stage: `20261114T155637759613Z`. Both processes exited 0 and emitted renderer/ObjectDB cleanup diagnostics. The ignored evidence folder `.tools/specialist-squad-equipment-20261114/` retains capture scripts, process results, observations and logs. All six captures were inspected. Before shows the former inspector without these per-model selectors; after shows an ordinary Multi-melta with fixed Sergeant rifle, Sergeant Vengor with the total increasing 345→350, and a Sternguard Sergeant Power Fist alongside an ordinary Pyrecannon. These are actual Workshop renders, not mockups, exact sculpt review or full keyboard/gamepad/viewport coverage. Later scrolling rows and larger sizes still need broader visual review.

![Ordinary Eradicator Multi-melta and fixed Sergeant rifle](../../.tools/specialist-squad-equipment-20261114/after/eradicator-squad-with-melta-rifles-after-1280x800.png)

![Vengor surcharge in the saved army](../../.tools/specialist-squad-equipment-20261114/after/desolation-squad-after-1280x800.png)

Original plan gates remain open: 19 migrations, 59 completeness reviews, broader legacy/asset/restart/gallery recovery, human review and unequal-cache separate-machine LAN. No deferred check is reported as passed.

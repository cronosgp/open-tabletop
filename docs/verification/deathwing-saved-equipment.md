# Saved Deathwing unit and model equipment — 14 November 2026

Deathwing Terminators and Deathwing Knights now save source weapons per miniature and the optional Watcher in the Dark once per stable unit copy. Watcher is separate from model inventory and appearance: it has no fictional bearer, adds no miniature to composition and costs no points. Saved records apply before Deployment; persistent setup is locked while activation remains a live once-per-battle reaction.

## Verified local source

Authority: `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot of the same name, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. All 22 CSV hashes were rechecked. Both sheets belong to Dark Angels App book `000000023`, common 40K context. No online resolution was needed; alternate modes and full army legality are not certified.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| Datasheets_abilities.csv | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |

Runtime Marine digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`; verified-against Dark Angels slice hash remains `63babe1ca34885808f13f7250bd2f1f490fbeb0ba386e9bae1280a93802397f8`. Earlier extraction metadata and runtime source stamps remain separate. Source profiles, construction sizes/copy gates and combat effects were not rewritten.

| Sheet | Datasheet | Reviewed saved scope |
|---|---|---|
| Deathwing Terminator Squad | `000000230` | 5/10 models at 190/380 points, third-plus 230/420. Sergeant may replace Power Fist with Chainfist or Power Weapon; ordinary models may take Chainfist. One ordinary model per five may take Assault Cannon, Heavy Flamer, Plasma Cannon or Cyclone with retained Storm Bolter. These share a cap; each Cyclone adds 10 points. Plasma Standard/Supercharge, Cyclone Frag/Krak and Chainfist Standard/Hunter are preserved. One optional free Watcher per unit. |
| Deathwing Knights | `000000231` | Five models at 255 points, third-plus 275. Knight Master defaults to Great Weapon of the Unforgiven and may take Relic Weapon; ordinary Knights default to Mace of Absolution and may take Power Weapon. One optional free Watcher per unit. No new ranged weapons, shield charge or Wound bonus is introduced. |

See the existing [Deathwing Terminator](../marine-deathwing-terminator-squad.md) and [Deathwing Knights](../marine-deathwing-knights.md) source audits. Model fields are `terminator_melee_choice`/`terminator_special_weapon` and `deathwing_knight_melee`. Knight `default` resolves by source role, not a generic weapon. Watcher uses the separate exact unit field `watcher_in_the_dark: bool`.

The ledger now has 103 detected schemas, 44 explicit source-option completeness reviews, 87 fixed profiles and 14 migrations pending. The other 59 schemas still need completeness review. Counts are migration evidence, not full rules/army-legality certification.

## Separate unit and miniature records

The existing `unit_equipment_by_copy_id` storage path now supports explicitly registered squad equipment alongside the existing Reiver route. It is keyed by stable copy ID; `model_equipment_by_id` remains keyed by miniature ID. New Deathwing entries seed an explicit false Watcher record. Invalid unit fields, types, copy counts and unsupported profile bindings fail closed.

Canonical selection adds optional `saved_unit_loadouts`, one exact dictionary per selected copy, beside `saved_model_loadouts`. Its normalized content participates in `configuration_key`, so identical model weapons with different Watchers cannot merge into the wrong match configuration. Canonical admission validates unit records before materialization. Prepared squads retain the captured dictionary and its definition identity; source defaults finish first, then the saved unit flags apply once before ability initialization and formation replay. Watcher flags remain squad-level. Explicit unit records lock the equip/remove command; absence retains the older optional preparation route.

The Workshop exposes one native checkbox above the model rows, labelled `Watcher in the Dark (whole unit; free)`. It changes only the selected copy and does not change model equipment/appearance keys or points. The existing source activation command remains available when a saved watched unit receives mortal wounds and remains once per battle.

Catalog repricing previously copied model records and stable copy IDs but omitted `unit_equipment_by_copy_id`. It now preserves and normalizes that map, preventing a refresh from dropping Watchers or existing Reiver Grav-chutes/Grapnel Launchers. Copy splitting preserves the map too. The new fixture checks both Deathwing and Reiver unit records through repricing, split, disk reopening and match materialization.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_deathwing_saved_loadouts --only test_deathwing_terminator_squad --only test_deathwing_knights --only test_reiver_squad --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_deathwing_saved_loadouts --only test_terminator_saved_loadouts --only test_army_builder --only test_model_equipment_visuals --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

Initial report `.tools/verification/20261114T162644356823Z/results.json` failed 1/6 processes: the new test called a nonexistent admission method. Import, Python, both existing Deathwing source suites and Reiver passed, with no headless cleanup diagnostics. SHA-256: `348dae4b8e48995cf5be65009c87d4e12e87bb58797818168e9601e29293499d`. Correcting the test to call `Capabilities.admit` produced a direct staged pass. Runtime behavior was not changed for that correction. Additional direct model-lock checks were included in the final regression.

Final report `.tools/verification/20261114T163040946949Z/results.json` passed 7/7 processes (import, Python, new Deathwing unit/model test, previous Terminator migration, Army Builder, model-equipment visuals and consolidated catalog). SHA-256: `58f079d4a8ebf6f046c34bca4b11e9df8ba7634ca29d05113b3645ed9cc53b6e`. Headless cleanup diagnostics: test_army_builder, test_implemented_catalog. Network disabled; historical starter staged by the verifier.

The weapon matrix covers all 243 Knight role assignments (32 legal), all 1,584 permitted Deathwing melee distributions with an ordinary Plasma Cannon, and all 17/613 legal primary distributions at five/ten models, including exact Cyclone cost. This is not the full cross-product of Deathwing melee and primary assignments. Separate exact-type unit tests accept only the two Watcher booleans and reject a fictional bearer, wrong shape, extra fields or numeric boolean. Prepared package checks compare complete source inventories and role weapons.

The mixed fixture has three five-model units of each Deathwing profile plus one Reiver Squad: seven units and 35 models per player. Identical model equipment deliberately accompanies different unit Watchers (copies 1/3 equipped, copy 2 unequipped). Canonical mapping, both players' ability lookup and frozen unit records preserve those distinctions. Army Builder, canonical admission and materialized squad sums are exactly 1,510 points, including third-copy tiers, three Cyclones and free Watchers. Reiver's existing unit equipment remains separate.

Checks cover stable copy splitting, catalog repricing, separate-process bank reopen, exact unit/model materialization, malformed/foreign canonical unit-record rejection, absence of repeated setup, full state preservation on forced unit/model equipment edits, live Watcher activation and once-per-battle consumption, match save/reload and source-army isolation. Native checkbox signals verify copy isolation and unchanged points. Role-aware appearance filtering remains independent of the unit Watcher. The Python ledger suite passed six tests. Runtime networking remains deferred; no network result is inferred from this local evidence.

## Screen brief and actual Godot captures

Player goal: choose reusable model weapons and the unit's optional Watcher, save each copy independently, and use the Watcher only when its match trigger occurs. Existing per-model rows, copy selection, gold/black theme, typography and Save footer remain. The whole-unit free checkbox appears before miniature rows; Sergeant/Knight Master controls retain source role limits. Invalid edits restore the draft, and Watcher does not create a model appearance slot.

Real Godot 4.7.2 Compatibility captures at 1280×800 use isolated user-data paths with no model downloads. Before stage: `20261114T161217173205Z`; after stage: `20261114T162644356823Z` (same runtime implementation as the corrected test stage). Both capture processes exited 0 and emitted renderer/ObjectDB cleanup diagnostics. The ignored folder `.tools/deathwing-equipment-20261114/` retains scripts, observations, process results and logs. All four captures were inspected.

Before shows the former inspector without these controls. After shows a single checked whole-unit Watcher above Deathwing Sergeant Power Weapon/ordinary Plasma Cannon, and above Knight Master Relic Weapon/ordinary Power Weapon. The two-unit list remains 445 points. These are actual Workshop renders, not mockups, exact-sculpt evidence or complete input/platform coverage; later scrolling rows and ten-model visual review remain broader acceptance work.

![Unit Watcher and model-specific Deathwing weapons](../../.tools/deathwing-equipment-20261114/after/deathwing-terminator-squad-after-1280x800.png)

![Knight Master and whole-unit Watcher](../../.tools/deathwing-equipment-20261114/after/deathwing-knights-after-1280x800.png)

Original plan gates remain open: 14 migrations, 59 completeness reviews, broader legacy/recovery/gallery cases, human review and unequal-cache separate-machine LAN. Deferred checks are not reported as passed.

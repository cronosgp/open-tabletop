### Necron Overlords, Lychguard, Destroyer Lords and Cryptek Support expansion — 18 November 2026

Ten additional Necrons App v1.2 datasheets—Overlord (`000000523`), Overlord with translocation shroud (`000003693`), Lychguard (`000000536`), Skorpekh Lord (`000002109`), Lokhust Lord (`000002351`), Plasmancer (`000002108`), Technomancer (`000002352`), Psychomancer (`000002353`), Chronomancer (`000002354`), and Orikan the Diviner (`000000530`)—now clear their source-bounded local behavior gates, equipment selections, tiered points, and Leader/Support links, admitting 38/51 Necron datasheets into the current construction catalog. `tests/test_necron_overlords_lychguard.gd`, `tests/test_necron_destroyer_lords.gd`, and `tests/test_necron_crypteks.gd` are registered in `tools/verify.py` under `CURRENT_CATALOG_MATCH_SUITES`. The current construction catalog expands to 223 total selectable profiles, 123/123 reviewed equipment schemas, and 100 fixed-equipment profiles.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_necron_overlords_lychguard --only test_necron_destroyer_lords --only test_necron_crypteks --only test_necron_saved_equipment --only test_implemented_catalog --only test_space_marine_leader_links --timeout 600
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_warriors_current --only test_capabilities --only test_current_unit_abilities --only test_reanimation_protocols --timeout 600
python -B -m unittest discover -s tests -p "test_*.py"
```

The focused data-free run passed **8/8 processes** at `.tools/verification/20261119T013615669211Z/results.json` (SHA-256 `27c78237e4eb53d4e428bc70dcfccca6e23345a887d598f2af7378afdcac3381`; `legacy_starter_staged: false`, `network: false`; `test_implemented_catalog` reported headless RID cleanup diagnostics at shutdown). The targeted run passed **6/6 processes** at `.tools/verification/20261119T013616515332Z/results.json` (SHA-256 `52f7efee2fd6849e5f4a28b89fe0553784e6fe5f5abd974909d5b7dd370f6ce9`; `legacy_starter_staged: true`, `network: false`; `test_current_unit_abilities` and `test_reanimation_protocols` reported headless RID cleanup diagnostics at shutdown). These runs were recorded after the reviewer follow-up fixes and supersede the earlier pre-fix runs `20261118T235811693120Z` (8/8) and `20261119T000042010900Z` (6/6). The Python test suite passed **124 tests**. The remaining 13 Necron datasheets, full faction roster legality, and separate-machine LAN remain open.

### Necron prepared-match template and Triarch scope reconciliation — 18 November 2026

`Prepared.initial_state` now uses embedded current-reference templates whenever both players supply `schema_version: 2` Space Marines or Necrons selections without `legacy_necron_reference`, so current-catalog Necron prepared matches (`test_necron_saved_equipment`) no longer read `res://data/imported/starter-11e-v1` before `_materialize_mixed` replaces the placeholder squads and units. `test_necron_saved_equipment` is restored to `CURRENT_CATALOG_MATCH_SUITES`, while `test_necron_warriors_current` is classified under `targeted`/`full` because its C’tan Warlord and historical Warrior checks intentionally exercise the legacy starter pack. Triarch Praetorians (`000000539`) and Triarch Stalker (`000000540`) capability notes, coverage rows and the `test_necron_warriors_current` Praetorian option assertion are reconciled with the verified local Necrons App v1.2 export (`.tools/wahapedia/11e/necrons/20261031T053336Z`, `Datasheets_options.csv`) and the implemented saved-equipment schemas. In addition, `tests/test_prepared_match.gd` now explicitly sets `unit_abilities_choice.button_pressed = false` before starting its baseline historical prepared-match UI check (matching `tests/test_decision_ui.gd`), and `tests/test_space_marine_leader_links.gd` now validates the five Necron Cryptek Support identities in `Supports.BODYGUARDS` (11 Necron pairs alongside the 96 static Space Marine pairs) against their `current_reference_necron_profiles.gd` `source_bodyguard_datasheet_ids`.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_leader_catalog --only test_kor_sarro_khan --only test_implemented_catalog --only test_necron_saved_equipment --only test_saved_match_interruption --only test_necron_triarch_praetorians --only test_necron_triarch_stalker --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_warriors_current --only test_capabilities --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_space_marine_leader_links --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_prepared_match --only test_space_marine_leader_links --timeout 300
```

The focused data-free run passed **9/9 processes** at `.tools/verification/20261118T132355989993Z/results.json` (SHA-256 `D207867DE02C5E988626D14D8C9509A22C239111ED51FDF19F207C52051235B2`; `legacy_starter_staged: false`, `network: false`; `test_implemented_catalog` and `test_saved_match_interruption` reported headless RID cleanup diagnostics at shutdown). The targeted run passed **4/4 processes** at `.tools/verification/20261118T132750030808Z/results.json` (SHA-256 `3EBFB37DE6C2C0F4504F4B8A404C263B7778301558F84F261876993220ADDE92`; `legacy_starter_staged: true`, `network: false`, no cleanup diagnostics). The coverage export (`213` admitted profiles, `120/120` reviewed schemas, `93` fixed profiles) and `python -B -m unittest discover -s tests -p "test_*.py"` (`124` tests) passed. The focused Leader/Support link run passed **3/3 processes** at `.tools/verification/20261118T140015762834Z/results.json` (SHA-256 `EC83FC928BC2AE445E79AEED38B172625340EF7E4F3724EF4F4128D0FAC5A663`; `legacy_starter_staged: false`, `network: false`, no cleanup diagnostics), and the targeted prepared-match and Leader/Support batch passed **4/4 processes** at `.tools/verification/20261118T140051063197Z/results.json` (SHA-256 `785B9270580D9125F7FF6167E2B136B693CC834D6154F11ADF0F557E9BE6A9E5`; `legacy_starter_staged: true`, `network: false`; `test_prepared_match` reported headless RID cleanup diagnostics at shutdown). Exact Triarch Stalker FRAME geometry, separate-machine LAN and full Necron army legality remain uncertified.

### Saved mission-pair resume — 17 November 2026

`tests/test_saved_mission_pair_resume.gd` now starts a saved-army Chapter Approved match from the real UI with a non-default fixed pair, `engage-tempting-target`. The match freezes `secondary_pair_id`, both cards and the `terrain` stage in its checkpoint. A separate Godot process resumes the save and confirms the official mission, selected pair, cards, Event Companion terrain layout and pending stage are restored from the file. Back in the original process, resolving terrain enters `tempting-target-p1` for Player 2; both opponents' declarations then resolve in order to `roles-roll`. The fixture also covers the mission option path change: `_saved_match_options`, `_initial_state`, `_try_saved_armies` and `_start_prepared_match` now route official missions through `_match_terrain_layout()`, so the selected Event Companion layout reaches saved, prepared and LAN option builders instead of the unrelated training terrain default.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_mission_pair_resume --timeout 600
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_match_interruption --only test_saved_armies --only test_saved_mission_pair_resume --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T150234739814Z/results.json` (SHA-256 `FCD93B398F708262E689948F7A95972620FC9A89BC4AB91B10E261B85E43BA86`; `network: false`, legacy starter not staged). The adjacent saved-match batch passed **5/5 processes** at `.tools/verification/20261117T150602157919Z/results.json` (SHA-256 `267018C909163ECF1047AE92A18BE9EE15C4FFC1FE0F1DD90C04A08F514D8EEF`; `network: false`, legacy starter not staged). `tests/test_saved_mission_pair_resume.gd` hashed `85C3124E5C902E44AC53E56F7B20A6F83B2173DF9FA508F5AE43CE4887837F09`. This covers one non-default pair and its first two declaration stages; it does not complete the declaration matrix or establish separate-machine behavior.

### Chapter Approved mission fixture repair — 17 November 2026

The all-units Chapter Approved suite now passes again. Diagnosis showed `tests/all_units_fixture.gd` includes the `overlord`, whose current capability status is `implemented_local_checks_pending`, so current-catalog admission rejected it; the mission test now opts into `legacy_necron_reference`, matching how the fixture's own `fresh()` path already treats that data. The suite also needed an explicit Event Companion layout for official missions, per-player `primary_ids` when synthetic scoring blocks replace a primary, and the current generic Secure Asset home-objective error plus its per-player action list. These are test-fixture corrections, not new rules support or current-catalog certification of the Overlord.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chapter_approved --timeout 600
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chapter_approved --only test_saved_mission_pair_resume --only test_saved_match_interruption --only test_saved_armies --only test_army_builder --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T151930706939Z/results.json` (SHA-256 `497A3B18D403A52F712B0324EEFF2383B0FA84D0DF8C89D773FB2D0EB152A227`; `network: false`, legacy starter not staged) with `Chapter Approved checks: 0 failures`. The combined batch passed **7/7 processes** at `.tools/verification/20261117T152023523046Z/results.json` (SHA-256 `D76312563C774BFB75B2FFADC063FC65259FE02A04C76AB3609305C9C766AAF7`; `network: false`, legacy starter not staged). `tests/test_chapter_approved.gd` hashed `EA6FEE9F551C0B6382C69E4105AD4ED26DEC87D7F96F0E096C387929CA085A62`. This restores the bounded mission test; it does not admit the Overlord to new current-catalog construction or add new mission rules.

### Army-profile bank incompatibility boundary — 17 November 2026

The Army Builder profile regression now writes a valid profile bank with `schema_version: 2` and a second bank with no `schema_version`, then opens each through `ArmyProfiles`. Both are refused with the explicit `Incompatible profile format; file preserved.` error. The newer-schema bank is not partially read, `save_list` refuses to write, no temporary file remains and the original bytes are unchanged. The unversioned bank also refuses a profile-creation commit, so an older or newer external format cannot be silently extended in place. A `BuilderPanel` opened on the newer bank disables saving and shows `Cannot save · Incompatible profile format; file preserved.` instead of offering a write path. This establishes an explicit refusal boundary for the profile bank; it does not add migration or numeric-schema support.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T143257508948Z/results.json` (SHA-256 `83EF2BC146D5C57CF5A7B2FC3DCAE8CE6D44D5C46CFA54066C0DBFD5BBC7E793`; `network: false`, legacy starter not staged). `tests/test_army_builder.gd` hashed `65CEB49BA8DAD72851B8B32DB69F9C65F6736C7A5CEEA4F2B6C5274110F4C967` at this run. Godot emitted shutdown RID diagnostics after the suite reported zero failures. This covers two unsupported bank headers and the Builder's blocked-save state, not every historical army-profile shape or a human recovery workflow. The same suite re-passed **3/3 processes** at `.tools/verification/20261117T151115384217Z/results.json` (SHA-256 `E44B691053D430390DC57C4085CEAEB23BBB5BDE74901DBC82217D3E610F4B8A`) after the mission-pair option change.

### Saved Leader attachment readiness — 17 November 2026

The Chapter Approved readiness fixture now saves a Leader attachment in each army profile: the Space Marine Captain joins the Intercessor Squad and the Royal Warden joins the Necron Warriors. Opening the match applies both attachments from the saved profile without a reselection step, sets the leader role on each attached model, marks both bodyguard squads as attached and raises their starting strength to 6 and 11. The same match still opens the mission preparation decision for Player 1, and the saved Warlord mapping remains intact. This pairs with the existing Warlord coverage: persistent Warlord and Leader choices come from the saved army, while the mission declaration stays in readiness.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T034448231863Z/results.json` (SHA-256 `63A897186E811EF70F36F795B35B53ACE2443369C0939E2ED26A0835B19ED49B`; `network: false`). `tests/test_battle_readiness_ui.gd` hashed `2FF793BDCE28462BFDE9D98DDC5D737F4AAA4149F11859042BAD6CF21D53E976` at this run. This covers two saved Leader attachments in one mission pair; it does not verify every Leader/Support link or replace human usability review.

### Bring It Down readiness gate — 17 November 2026

The Chapter Approved readiness fixture now gives each mission roster a qualifying 10+ Wound model: a Space Marine Impulsor (11 Wounds) and a Necron Canoptek Doomstalker (12 Wounds). With `secondary_pair = "engage-bring-it-down"`, `Prepared.initial_state` builds both armies without an error, both rosters report a Bring It Down target, and the mission preparation decision opens for Player 1 with legal options. The fixture then resolves terrain, the role roll-off, the Attacker/Defender choice and both Battle Ready declarations to Formations, confirms both Bring It Down cards are registered, rechecks both target predicates and verifies the saved Warlords did not change. A control copy that reduces the opposing models' `max_wounds` to 9 removes the target, so the assertion fails if the predicate stops discriminating. An earlier fixture used an Annihilation Barge, which the local snapshot gives 9 Wounds; `Prepared.initial_state` rejected that pair with "Bring It Down requires each opposing roster to include at least one model with 10 or more Wounds.", confirming the readiness gate is enforced rather than bypassed.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T033518133247Z/results.json` (SHA-256 `A584C221C40BBAE177D594DF7BA9BAC56E5F9990F8AD269071C48694DF3B2B2D`; `network: false`). `tests/test_battle_readiness_ui.gd` hashed `31C549EF0DF90D9E7EC563363DEEE927D59B2AC7518C1ECC12F7322D14DE88FB` at this run. This covers one additional mission-specific pair; it does not complete the declaration matrix, verify every secondary pair, or replace human readiness/usability review.

### Broader legacy profile restart fixture — 17 November 2026

The separate-process legacy restart fixture now includes a third saved profile, an Aggressor Squad with a flat appearance array and no stable identity or mode keys. Reopening assigns a copy identity, preserves the unit appearance and the per-model sculpt, and keeps the untouched model in Auto mode. Saving and reopening a second time retains the same copy identity and appearance values.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_saved_loadout_restart --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T032028566417Z/results.json` (SHA-256 `B09C930B77BA69C077C23878BA13F4B8637AC87DAA3E4FAECFD41B616B2D5077`; `network: false`). This adds one profile to the legacy fixture; it does not certify every historical profile or match format.

### Legacy whole-unit equipment migration — 17 November 2026

The legacy restart fixture now includes a fourth saved profile that uses the former whole-unit Aggressor equipment record, `unit_equipment_by_copy_id`, keyed to an existing legacy copy identity. Before the change the fixture covered only flat appearance arrays. On reopen the reader converts the whole-unit `aggressor_boltstorm` value into per-model `model_equipment_by_id` records for all three models, removes the obsolete whole-unit key, and preserves the copy identity. Saving and reopening a second time retains all three per-model values and still has no whole-unit equipment key. Boltstorm is `true` on every model, which distinguishes real migration from the `false` default a dropped record would produce.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_saved_loadout_restart --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T033936088014Z/results.json` (SHA-256 `D8C44E16AFB3D5C15A4866F2AB7655E9A2C553CCF04971EF165E55C82AD1FB6D`; `network: false`). `tests/test_saved_loadout_restart.gd` hashed `BFE8D9E20076175B74EB16EA848D4A64BEE518F668DF3E4E28AD3C840E4BC723` at this run. This exercises one supported historical equipment record; it does not cover every legacy schema, match format or human review.

### Appearance gallery ready-only filter — 17 November 2026

The Appearance gallery now lists ready local looks before candidates that still need local preparation and adds a `Ready only` checkbox. The checkbox reports the ready/total count and hides unready candidates, while Automatic stays visible and a saved unready choice remains visible even when other unready looks are hidden. The preference survives copy/model re-renders for the session. Filtering is presentation-only: it does not change equipment, points, saved assignments or unsaved draft state. The regression injects synthetic ready and pending variants, checks Automatic-first/ready-first ordering, hides the pending card only while the filter is active, re-renders the appearance pane and confirms the filter and hidden card survive, keeps a saved pending choice visible while hiding a different pending look, clears that choice and confirms it hides again, and compares the draft string around every filter action.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_workshop_ui --timeout 600
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_workshop_ui --only test_army_builder --only test_model_equipment_visuals --only test_saved_armies --only test_match_save --only test_saved_loadout_restart --only test_local_models --only test_local_armies_models --timeout 600
```

The focused run passed **3/3 processes** at `.tools/verification/20261117T024709935017Z/results.json` (SHA-256 `56C6D21BC9CC77CDD03E482158E3CD2DF63ECB4595F0BDF109A17B480B65111E`; `network: false`, no legacy starter). The regression batch passed **10/10 processes** at `.tools/verification/20261117T024852603517Z/results.json` (SHA-256 `08A8BB6385126E877ED98CDB4251E0855CBFCE3627A62BE192090E593ADA3408`; `network: false`, legacy starter staged). Godot emitted shutdown RID/ObjectDB cleanup diagnostics after several suites still reported passing. These are synthetic metadata checks; they do not replace real-asset captures, small-window layout review or human usability review.

### Unequal-cache saved-army LAN loopback — 17 November 2026

The saved-army network fixture now gives only the host renderable local sculpts for both its saved unit appearance and a saved per-model override. The client keeps the same saved reference values but has no matching local files. Both processes still admit the same 20 units at the same points, reach Deployment, and retain their own local appearance references. The host resolves the unit and model sculpts; the client reports fallback warnings and stays playable. This covers local visual availability remaining outside synchronized gameplay state, not a separate-machine session.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --network --only test_saved_armies_network --timeout 600
```

The final run passed **22/22 processes** at `.tools/verification/20261117T030633389741Z/results.json` (SHA-256 `BA690BEEE0D18CC0CE2D2EEA247F49A92143D3D79AD0302ECBDA542D6368062A`). An earlier run with the same change stopped on the `save-rerolls` host/client pair at a Deployment coordination timeout (`.tools/verification/20261117T025438598227Z/results.json`, SHA-256 `7AFB549CBB2C93D3312DDA28C390DD084A1048C7FEE74DFC2AE32FF25AA6CD64`); it passed on the isolated verifier rerun above, so the timeout is recorded as an observed flake rather than a confirmed pass. It remains loopback evidence with synthetic local assets; real separate-machine LAN, asset transfer and human visual review remain open.

The Appearance control regression was updated to select the unit-copy picker before checking the `Unit 2` preview caption. The focused run passed **3/3 processes** at `.tools/verification/20261117T021219235207Z/results.json` (SHA-256 `908069BA75D9B156BB93C1C019C3A9927521023DDC562C3DC666EEB1A5A21F34`).

### Ravenwing saved equipment — 15 November 2026

Ravenwing Black Knights and Ravenwing Command Squad now persist their source-listed, free Plasma Talon replacement against each stable model and copy. Validation preserves one Grenade Launcher per three models, including two distinct bearers for a six-model Black Knight unit. Local role factories, the 3/6-model prices, third-plus copy tiers and saved match locks are retained. The actual Workshop uses stacked model cards; top and lower scroll captures were inspected at 1280×800.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_ravenwing_saved_equipment --only test_ravenwing_black_knights --only test_ravenwing_command_squad --only test_sammael --only test_captain_on_bike --only test_outrider_squad_current --only test_deathwatch_saved_loadouts --only test_vanguard_saved_equipment --only test_model_equipment_visuals --only test_army_builder --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final Godot batch passed **13/13 processes** at `.tools/verification/20261115T070347136336Z/results.json` (SHA-256 `338DF731C8DDC0E3BFAEE4DA46EE0A81BA6CB99305791CEFBD373F0CBAB2B82A`; `network: false`, historical starter staged). Army Builder and implemented-catalog checks exited successfully with their existing headless cleanup diagnostics; all other selected processes were clean. The Python coverage suite passed 6/6. The refreshed 213-profile ledger has 109 detected schemas (50 explicit source-option reviews), 75 fixed-equipment reviews, 8 option-bearing migrations pending, 12 stale reviews, 9 unclassified profiles and 59 schemas still awaiting completeness review. Actual staged captures exited 0; their Texture RID and 55-ObjectDB shutdown diagnostics are recorded in the [source/visual audit](ravenwing-saved-equipment.md). This does not certify full Ravenwing/Chapter army legality, separate-machine LAN, human usability or completion of the wider plan.

### Vanguard Veteran saved equipment — 15 November 2026

Both the Warhammer Legends Vanguard Veteran Squad and the Jump Pack variant now persist source-listed choices per model. The saved path validates Sergeant-only melee replacements, the ordinary two-per-five Plasma allowance, all local factory combinations, zero equipment surcharges and existing copy tiers. Match preparation applies the selected weapons and shield-bearer saves before Deployment, then suppresses and rejects reconfiguration. The Jump Pack Workshop shows stacked model cards so the model names remain visible above both fields; the Legends variant retains one control row per model.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vanguard_saved_equipment --only test_vanguard_veterans --only test_vanguard_veteran_squad_legends --only test_deathwatch_saved_loadouts --only test_deathwatch_terminator_squad --only test_deathwatch_veterans --only test_terminator_saved_loadouts --only test_deathwing_saved_loadouts --only test_specialist_squad_saved_loadouts --only test_model_equipment_visuals --only test_army_builder --only test_implemented_catalog --timeout 300
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json
python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final verifier batch passed 14/14 at `.tools/verification/20261115T062111845814Z/results.json`, SHA-256 `9f2416bb7390f1c4260e18aaeebab5317a17710373f04c9e0e8a00d3b3c9ad33`; network was disabled and the historical starter was staged. The Army Builder and catalog checks exited successfully with the cleanup diagnostics listed in the [migration record](vanguard-veteran-saved-equipment.md). The Python ledger suite passed 6/6. Two actual 1280×800 Godot Compatibility captures were inspected; both capture processes exited 0 and reported Texture RID/ObjectDB cleanup warnings at shutdown. Focused regressions include separate-process list reopen and prepared-match model comparisons for every admitted copy and model.

The refreshed 213-profile ledger reports 107 detected schemas, 48 explicit option-completeness reviews, 75 fixed-equipment reviews, 10 option-bearing migrations pending, 12 stale reviews, 9 unclassified profiles and 59 incomplete-schema reviews. Those stale/unclassified records and the plan-wide integration gates remain open. This does not certify full rules coverage, official army legality, sculpt parity, human usability or network play.

### Saved Space Wolves squad equipment - 14 November 2026

Thunderwolf Cavalry and both Wulfen profiles now persist per-model source packages with Plasma caps, shield prices, exact weapons and actual bearer/totem effects. The exhaustive matrix checks 2,868 complete distributions and 2,628 legal outcomes. A mixed army retains 1,165 points through the builder, admission, separate-process reopen and both players' materialized squad sums. Saved setup choices are suppressed, forced edits return the saved-lock error without mutation, and later source-army edits do not change the match.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_squad_saved_loadouts --only test_squad_specialist_saved_loadouts --only test_implemented_catalog --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_thunderwolf_cavalry --only test_wulfen --only test_wulfen_storm_shields --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The new/specialist/catalog batch passed 5/5 at `.tools/verification/20261114T150607965939Z/results.json`, SHA-256 `48657e78bf75e51b41f0a8d49c71271af834462923c8df8a7c1dd8005ed7e03c`; only catalog cleanup diagnostics. Corrected source tests passed 5/5 at `.tools/verification/20261114T150852426899Z/results.json`, SHA-256 `751c24e9ec784feebac8a48342e29847f8fd61c85967820d9cfe0c76c0202e7a`, without cleanup diagnostics. Both disabled network and staged the historical starter. Python ledger checks passed six tests. The initial 3/6 batch remains failed evidence for three old tests that expected first-two prices on all three units; source tables and canonical admission prove the corrected tier expectations. Runtime source profiles/pricing rules were not changed to satisfy those tests. Six actual Godot captures were inspected. The ledger has 90 detected schemas, 31 explicit equipment completeness audits, 87 fixed profiles and 27 migrations without stale/unclassified records; 59 other schemas still need review. See [all source hashes, commands, failure records, capture context and limits](space-wolves-squad-saved-equipment.md). Full army legality, human usability and separate-machine LAN remain open.

### Saved aircraft/heavy transport equipment - 14 November 2026

Corvus Blackstar and Mastodon now save all 24 reviewed equipment packages, including whole launcher/weapon pairs, fixed weapons, Corvus Auspex effects and unchanged source prices. Shared code now distinguishes a boolean pair from a named-choice group; the existing legacy Corvus paired-launcher defect was reproduced and corrected. Stable configured/default copies reopen in another Godot process, materialize for both players at 1,440 points and remain independent of later source-army edits.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_large_transport_saved_loadouts --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final batch passed 5/5 at `.tools/verification/20261114T144856361862Z/results.json`, SHA-256 `e50d8966472d0808d9c0dd1577e8bf475b73e51a121a117668ec708a9ea3fc9b`; network disabled, historical starter staged, catalog shutdown diagnostics. Python ledger checks passed six tests. The original 3/4 batch remains failed evidence for the legacy Corvus defect. The next 6/7 batch remains failed evidence for an array-type error in the new fixture; both existing source suites, previous transports and catalog passed there. Four actual Godot before/after captures were inspected; both capture processes exited 0 with render shutdown diagnostics. The ledger now has 87 detected schemas, 28 explicit equipment completeness audits, 87 fixed profiles and 30 migrations, without stale/unclassified records. The other 59 schemas still need review. Source profiles/digest were unchanged. See [all source hashes, commands, failed/successful reports, capture context and limits](large-transport-saved-equipment.md). Full army legality, geometry, human usability and separate-machine LAN remain open.

### Saved Black Templars Gladiator equipment - 14 November 2026

BT Lancer, Reaper and Valiant save their additional Multi-melta per independent copy and retain exact fixed weapons. Pricing counts every equipped source-listed weapon, including Valiant's fixed pair. The Workshop Add form now includes default equipment in the unit/copy-tier labels and addition arithmetic; this also fixes the existing common Executioner default Laser preview. The nine-copy fixture totals exactly 1,605 through save/reopen, admission and both players' materialized squads.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_templar_gladiator_saved_loadouts --only test_army_builder --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final batch passed 6/6 at `.tools/verification/20261114T143332223037Z/results.json`, SHA-256 `ae8d4f7a6189cf95e2d9b7f7d2a09248caac7dd090de7276aecdff1df9bac472`; network disabled, historical starter staged. Army Builder/catalog shutdown diagnostics remain recorded. The preceding source/copy-price batch passed 5/5 without cleanup diagnostics; Python ledger checks passed six tests. The ledger now has 85 detected schemas, 26 exact-field source reviews, 87 fixed profiles and 32 migrations, without stale/unclassified records. The other 59 schemas still need review. Eight actual Godot captures show saved selectors and the corrected Add preview (165 default, 350 added, 515 total). Source profiles/digest were unchanged. See [all source hashes, commands, both reports, capture context and limits](templar-gladiator-saved-equipment.md). Full army legality, human usability and separate-machine LAN remain open.

### Saved squad specialist equipment - 14 November 2026

Firestrike Servo-turrets, Infiltrators and Bladeguard now save per-model equipment with exact source sizes, the single Helix bearer and Sergeant-only pistol replacements. The new matrix checks 1,818 distributions and 29 legal outcomes, separate-process reopen, exact source weapons, real Workshop signals, frozen setup locks and immutable matches. Both players retain the mixed army's 1,180-point total, including the third Bladeguard copy tier.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_squad_specialist_saved_loadouts --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The corrected final Godot batch passed 5/5 at `.tools/verification/20261114T060841774860Z/results.json`, SHA-256 `1fa170e41e51ab0ed7324c87559473b01aa94419be2279c2cb234b0e79e83c31`; network disabled, historical starter staged. Only the catalog process reported cleanup diagnostics. Python ledger checks passed six tests. The initial batch remains failed 5/6 evidence for an untyped local variable in the new fixture; all three existing source suites passed. The source profiles and Marine digest were unchanged. The ledger now has 82 detected schemas, 23 explicit completeness reviews, 87 fixed profiles and 35 migrations, with no stale/unclassified records. The other 59 schemas still need completeness review. See [source hashes, both report commands, exact scope and visual evidence](squad-specialist-saved-equipment.md). Full army legality, human usability and separate-machine LAN remain open.

### Saved transport equipment - 14 November 2026

Twelve Land Raider, Razorback, Repulsor and Impulsor identities now save per-copy equipment through canonical validation, materialization and frozen setup locks. All 126 independently enumerated source packages are covered. The local export resolved missing BT Multi-melta choices, the Impulsor pintle is exclusive, common/BT Executioner prices remain distinct, and legacy paid edits keep squad and army costs aligned. A 4,290-point mixed army survives separate-process reopen and match snapshots; actual Workshop signals and 24 inspected Godot captures cover the visible controls.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_black_templars_vehicles --only test_marine_impulsor_options --only test_marine_repulsor_loadouts --only test_transport_saved_loadouts --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final Godot batch passed 6/6 at `.tools/verification/20261114T055542565213Z/results.json`, SHA-256 `73538a316b34e09056949a3c7883067c2d7ecee83062173b53936f8bb380b9a4`; network disabled, historical starter staged, no cleanup diagnostics. The preceding catalog/heavy/transport regression passed 6/6 at `.tools/verification/20261114T054839722669Z/results.json`, SHA-256 `89cd9cedb4b340d09420ae6f59a8f93211b0578c013c001bde26da83ea757e61`, with catalog shutdown diagnostics. Python ledger checks passed six tests after checked digest continuity: 182/185 Marine profiles are exactly unchanged, three BT transport metadata records were re-audited, and 133 registry bindings were updated only after proving that scope. The ledger now has 79 detected schemas, 20 explicit source-option reviews, 87 fixed profiles, 38 migrations and no stale/unclassified records. The other 59 schemas still need completeness review. A direct root whitelist check also passed twelve valid and 24 malformed identities.

The initial 5/6 batch remains failed evidence for a new fixture's wrong catalog preload/type inference. All exact commands, five reports, source hashes, digest continuity, capture context and limits are in [the transport migration record](transport-saved-equipment.md). Full army legality, human usability, broader recovery and separate-machine LAN remain open.

### Heavy and Space Wolves saved equipment - 14 November 2026

Redemptor, both Centurion squads and Wolf Guard Battle Leader now persist all source-listed equipment groups. Preparation retains canonical per-copy equipment prices and copy tiers, including the existing ATV surcharge. The ledger has 67 detected schemas, eight explicit source-option reviews, 87 fixed profiles and 50 migrations pending; 59 other schemas still need completeness review.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_saved_loadouts --only test_unit_reserves --only test_space_marine_copy_cost_parity --only test_invader_atvs --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_saved_loadouts --only test_character_artillery_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The pricing/reserve/ATV run passed 6/6 at `.tools/verification/20261114T052112897287Z/results.json`, SHA-256 `09251e763f5cd877d86c11480d53c7c4c730a62647687194d82298bfcdbc139b`. The final run passed 5/5 at `.tools/verification/20261114T052554738295Z/results.json`, SHA-256 `35d85648f56db05fb472d2086fb85e54c17b855cc64999ce64c772a21e2e90d3`. Both disabled network and staged the historical starter; only the final catalog process reported cleanup diagnostics. Python ledger checks passed six tests. The initial 6/7 run remains failed evidence for a new fixture's incorrect assumption about model-row topology; all four source regressions passed. Thirty equipment packages, separate-process reopen, immutable matches, forced-edit rejection and real Workshop signals are covered. See [all commands, source hashes, failed/successful reports and eight inspected actual Godot captures](heavy-saved-equipment.md). Human review, broader recovery and separate-machine LAN remain open.

### Character and artillery saved equipment — 14 November 2026

Execrator, Phobos Lieutenant, Terminator Chaplain and Rapier Carrier now persist all source-listed equipment groups per stable copy, apply exact weapons and the Chaplain shield Wound before Deployment, and reject repeated setup changes. The catalog ledger has 63 detected schemas, four exact-field-bound source-option reviews, 87 fixed-equipment profiles and 54 migrations pending. Existing costs, copy limits, Chapter scope and Legends/geometry boundaries remain unchanged.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_character_artillery_saved_loadouts --only test_phobos_lieutenant --only test_unit_reserves --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The final Godot run passed **5/5 processes** at `.tools/verification/20261114T044537078478Z/results.json`, SHA-256 `e829619848a5f4889ee54e094b6e95afbeca9c52d2bfd18f1b915855b82d2849`; network disabled, historical starter staged, no cleanup diagnostics. The Python suite passed **6 tests**. The preceding catalog batch passed 4/4 with catalog shutdown diagnostics; the initial batch remains failed evidence for a fixture parse error and an outdated Phobos reserve expectation. The corrected Phobos test submits ordinary reserves through the public command path and checks the mixed unit does not gain Deep Strike. All exact commands, source hashes, failed/successful reports, limits and eight inspected Godot before/after captures are in [the migration record](character-artillery-saved-equipment.md). No full army legality, human playtest, sculpt parity or separate-machine LAN claim follows.

### Army Builder source classification and Battle Readiness UI — 14 November 2026

The 105-profile local export classification returned 47 additional fixed-equipment profiles and 58 option-bearing migrations. The ledger now separates 59 detected schemas, 87 fixed-equipment records and 58 migrations; no profile without a saved schema remains unclassified. Four focused Python source-review tests passed. See [exact commands, source manifests and scope](army-builder-equipment-classification.md).

Battle Readiness now places finish before the equipment summary, omits the applied Warlord from presentation choices and labels remaining alternatives optional only when the existing rules probe permits finish. The first new UI test run failed because the fixture omitted the normalized submission envelope; its saved-army regression passed. After correcting the fixture to use the actual UI payload, focused verification passed 3/3 processes at `.tools/verification/20261114T042644029990Z/results.json`, SHA-256 `f5e0ac6fa86c33234d574ace20322937c21c61e85f26e080c1e1d2166e629e32`. Network was disabled; UI and saved-army runs retain RID/ObjectDB shutdown diagnostics. Actual Godot Compatibility captures at 1280×800 show the saved mixed army reaching initial Deployment with missing-visual fallback and no weapon/Warlord reselection. This is scripted runtime evidence, not a human playtest, complete deployment or LAN certification. Exact commands, the failed report and capture context are in [readiness evidence](../project/battle-readiness-ui.md).

### Army Builder equipment provenance and workflow review — 14 November 2026

The local equipment-continuity audit reconciled 29 fixed-equipment reviews to existing runtime verification provenance. Both raw snapshots' manifest files were hash-checked (23 earlier files and 22 current CSVs); all reviewed default loadouts and source identities agree and neither options table contains rows for these datasheets. The ledger now has 204 admitted profiles: 59 detected schemas, 40 fixed-equipment reviews, zero stale equipment reviews and 105 unclassified profiles. The additional schema is the existing Rhino Primaris path in the working tree, not an equipment implementation from this increment. Exact source identities, file hashes, audit command and limits are in the [provenance record](army-builder-equipment-provenance.md).

```powershell
python -m unittest discover -s tests -p test_army_builder_coverage.py
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_loadout_restart --only test_saved_armies --only test_match_save --only test_model_equipment_visuals --timeout 300
```

The three focused Python tests passed. The combined verifier reported **5/6 processes passed**, not an overall pass: import, Python, saved armies, match save and model-equipment visuals passed, while the restart fixture failed because it assumed differently equipped Rhino copies remain grouped in one canonical entry. Report: `.tools/verification/20261114T030417445529Z/results.json`, SHA-256 `6e0c09c527a68f61d6adb0ef0ce42ff14d254b109796fa638de16e16c7681dd3`; network disabled, historical starter staged. Saved-army and match-save processes reported RID/ObjectDB cleanup diagnostics at exit; other selected processes did not.

The fixture now counts every canonical copy and verifies exactly one equipped and one default loadout for each Rhino datasheet, independently of canonical grouping/order. A failure exits nonzero. It retains separate-process army reopening, mixed infantry/vehicle equipment, exact frozen setup comparison after source-list edits, match save/reload and shared editor-signal checks.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_loadout_restart --timeout 300
```

The corrected restart run passed **3/3 processes** at `.tools/verification/20261114T030652693724Z/results.json`, SHA-256 `07a3c82bb593c6e2709b3c4671cf8146f4e22b00caad500749fbce5377bd8e7d`; network disabled, historical starter not staged, no cleanup diagnostics. The earlier run's other successful suites were not rerun because the correction only changes the restart fixture. This establishes bounded local workflow evidence, not full army legality, broad legacy migration, human usability or separate-machine LAN.


Actual Godot Compatibility captures at 1280×800 also cover a scripted mixed saved army through Workshop, readiness, the two player-finish actions and initial Deployment using built-in fallbacks with one unavailable manual visual. The fixture exited 0; render shutdown diagnostics remain in the capture log. No equipment or Warlord was reselected. The preparation panel still labels the saved Warlord as a required declaration despite allowing finish; this presentation follow-up remains open. See the [captures, exact fixture context and limits](army-builder-equipment-provenance.md#observed-godot-workflow).

### Local appearance availability and retry recovery — 13 November 2026

The focused local-army and model verifier passed **3/3 processes** at
`.tools/verification/20261113T163900992280Z/results.json` (SHA-256
`84674E954D96D408BA8A7AE165CF3E89157F621351B6BAD01C08FE1F676AAFCC`):

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_armies_models --timeout 300
```

The offline regression verifies that the resolver records per-candidate
`download_pending`, `downloading`, `missing` and `conversion_failed` states and
their reasons while retaining deterministic fallback order. It checks that the
datasheet's saved default miniature is the final traced local fallback, and
that a repaired saved appearance replaces the currently rendered fallback
without changing the stable appearance ID or gameplay state. The targeted
profile staged its legacy starter fixture and used no network. Godot still
reports RID/ObjectDB cleanup diagnostics when this suite exits; the suite itself
reports zero assertion failures. No live match visual-parity or separate-machine
asset-availability check was performed.

### Strategic Reserves round-three ingress timing — 13 November 2026

The focused reserve verifier passed **3/3 processes** at
`.tools/verification/20261113T161600334384Z/results.json` (SHA-256
`F499FB864D38F31474065E955F11F6A341349D292962802746BC5F329BAD8149`):

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_unit_reserves --timeout 300
```

The targeted run staged the legacy starter fixture and reported `network: false`.
The reserve regression now verifies both timing sides: ordinary Strategic
Reserves are rejected inside the opponent’s deployment zone before round three,
then can arrive there during round three when every model remains within 6 inches
of a battlefield edge and more than 8 inches from enemy units. Deep Strike’s
round-two enemy-zone formation remains separately checked. This does not certify
Necron-specific ingress, transport/passenger interactions, full army legality or
separate-machine networking.

### Strategic Reserves declaration and ingress distinction — 13 November 2026

The focused reserve, capability and Aircraft verifier passed **5/5 processes**
at `.tools/verification/20261113T160446212620Z/results.json` (SHA-256
`59B5E20FA76F01295F3FC7A53C3A7AD255D58E76001AC9DA2268E6030206D87D`):

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_unit_reserves --only test_capabilities --only test_nephilim_jetfighter --timeout 300
```

The targeted run staged the legacy starter fixture and reported `network: false`.
It confirms that a non-Deep-Strike Intercessor can be declared into Strategic
Reserves, a synthetic FORTIFICATION-tagged unit is withheld, combined local
reserve costs stay under the 50% cap, and AIRCRAFT continue through their
mandatory reserve path. The Terminator placement checks allow a complete Deep
Strike unit into the opponent’s deployment zone when each model is more than 8
inches from enemies, while ordinary Strategic Reserves remain excluded from
that zone before round three even at a legal battlefield edge. The 11e Core
Rules page (June 2026 revision) was checked for §§20.01, 20.04 and 24.09. The
checks do not certify Necron-specific ingress, all transport/passenger
interactions, official price recency, full army legality or separate-machine
network behavior.

### Aggressor Army Builder equipment integration — 13 November 2026

The focused saved-list, combat, visual-metadata and Army Builder regressions passed **6/6 processes** at
`.tools/verification/20261113T130119170273Z/results.json`:

```text
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aggressor_saved_loadout --only test_aggressors --only test_model_equipment_visuals --only test_army_builder --timeout 300
```

The verifier reported `network: false`; the targeted profile staged its optional
legacy starter fixture. The saved-list regression covers per-miniature save/reopen,
stable model and unit-copy IDs, migration of the former whole-squad preview record,
Army Workshop controls, mixed-model canonical admission, pre-Deployment weapon
materialization, Battle Readiness counts, setup suppression and standalone per-model
choices. The combat regression covers the current source weapon profiles, Close-quarters
Firestorm and attack resolution. The visual regression checks metadata-based package
matching and rejects conflicting equipment hints; the Army Builder suite checks the
existing builder flow. These are local path checks, not full army legality, actual
Aggressor sculpt parity or separate-machine LAN validation.

## Local model database and equipment selection — 6 November 2026

## Configuration workspaces — 6 November 2026

The current-catalog editor/workspace check passed **5/5 processes** at
`.tools/verification/20261106T210755697276Z/results.json` (network disabled, no legacy
starter staged). A broader run including the existing gameplay-layout suite passed
**6/6** at `.tools/verification/20261106T211402634912Z/results.json` (network disabled;
its optional historical starter fixture was staged). A focus-warning follow-up
passed **4/4** at `.tools/verification/20261106T211637224083Z/results.json`
(configuration and gameplay-layout suites plus import/Python; no focus warnings).
It covers save/copy/reload,
current composition edits, imported fixture previews, settings Apply/Revert and
configuration navigation; it does not certify rules, full army legality or LAN.

The staged native Godot captures cover 1366×768, 1920×1080 and 2560×1440 with
100/110/120% interface scales. Synthetic keyboard/controller events are checked;
physical-controller coverage is not claimed. The continuation passed 12/12
processes for local launch, tactical/result, draft recovery, configuration, model
transfer and layout checks at `.tools/verification/20261106T223900607426Z/results.json`.
The old immediate-start training/result failures are superseded by async public-flow
checks. A worker/race/local-model follow-up passed 5/5 at
`.tools/verification/20261106T224332353778Z/results.json`. Four real local models
and a 32,256-entry source were profiled; initial synchronous GLB conversion
took 4–18 seconds. The subsequent worker conversion run verified three packages
in 5.6–6.2 seconds each while frames continued (approximately 49 ms maximum
interval). Explicit source scanning of 32,256 entries also yielded across frames.
Whole-library transfer, physical devices and separate-machine LAN remain unverified.
The final async conversion/source/first-run race suite passed 3/3 at
`.tools/verification/20261106T225133842344Z/results.json` (network disabled). See the
[full redesign audit, phase record and commands](../project/ui-redesign.md).

The local batch follow-up passed 6/6 processes at
`.tools/verification/20261106T230038658297Z/results.json`; extended heavy-item and
appearance cancellation/directory-source checks passed 3/3 at
`.tools/verification/20261106T230218184539Z/results.json`. All selected checks had
network disabled. Six defaults and 60 local appearances previously blocked the
native preparation callback for 11.1 seconds; background planning dispatched in
1.63 ms and completed across frames with the same ready counts and zero external
request attempts. Actual heavy cached completion-handler imports and 48-entry,
long-name/notes layouts are recorded in the redesign audit. This closes the active
continuation's local acceptance scope; the full release gate remains partial.

### Missing standard-profile mapping recovery — 6 November 2026

The local Godot 4.7.2 config audit reproduced the 144 mapped / 17 missing
standard-profile discrepancy. All 17 missing profiles had complete candidates
in the configured local cache. The new recovery tool uses the production matcher,
cache/component resolver and current base/completeness checks. It preserves
existing records, makes a local backup, rejects concurrent config changes and
reads back the temporary and installed settings. An initial full-config save
rounded one existing Redemptor transform; that attempt was replaced from its
hash-verified backup. The final tool inserts only new dictionary entries into
the original text. The final preservation comparison found no differences.

Exact successful commands (run from the project root):

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/reconcile_local_model_mappings.gd -- --output .tools/forceorg-model-table/catalog_v2/mapping-recovery-dry-run-20261106.json
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/reconcile_local_model_mappings.gd -- --apply --output .tools/forceorg-model-table/catalog_v2/mapping-recovery-applied-20261106.json
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/verify_recovered_mapping_reload.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/audit_forceorg_source_pose_mappings.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/reconcile_local_model_mappings.gd -- --apply --output .tools/forceorg-model-table/catalog_v2/mapping-recovery-idempotence-20261106.json
```

All final commands exited **0**. Dry run found 17 recoverable links; apply restored
17/17. The fresh-process reload created **17/17 Node3D visuals** through
`ModelImportPanel.visual_for`, which checks saved fingerprints and current base
gates. All 145 original mapping records, 64 saved variants and other settings
matched the backup. The standard-profile audit reported **161 profiles, 17
source-pose pilot, 144 retained legacy, zero missing, zero invalid pilot**. The
idempotence run found zero missing links and made no save. The 145 original
records include one profile outside the standard Marine set.

Applied-report SHA-256:
`b1f383861dc6719ea7de34b9bbca8fbbc858b533a76b2833c21af71cd231e6d2`;
reload-report SHA-256:
`cf8308b81c181927d931c2a9293aad3604a387ae23bedf146125adc60239f008`.
Reports and the local probe scripts remain under ignored `.tools/`. The applied
report records the exact backup path, original/recovered config hashes and
ForceOrg source hash. No model files or generated third-party data were added
to Git. No test suite, network requests or downloads were used. These are
direct recovery and reload checks, not rendered evidence, TTS parity, full
161-profile import certification, equipment completeness or multiplayer coverage.

### Schema 8 hierarchy index and association-first search — 6 November 2026

The schema-8 rebuild adds `source_object_parent(parent_path,source_sha256)` to
the 74,766-row object hierarchy table. Before the index, `EXPLAIN QUERY PLAN`
reported a full `SCAN source_objects` for a parent-only lookup. The rebuilt
database now uses `source_object_parent` for both parent-only and exact
source-plus-parent lookups. The source/category indexes and all data counts are
preserved. SQLite integrity is `ok`, with zero foreign-key errors; totals remain
35,884 source variants, 147,384 candidate/identity links, 38,495 visual catalog
occurrences and 74,766 static objects.

The same schema-8 query audit found that alphabetical ordering put 104
candidate-only Intercessor/Grenade Launcher rows ahead of ten label/user
associations. Datasheet-filtered searches now rank confirmed label/user
associations first, reviewed visual fallbacks second and candidate-only links
third. Candidates remain visible and keep their status. The focused search now
returns the ten Intercessor Grenadier label/user associations before the
Sergeant-labelled candidate rows; it does not certify those candidate loadouts.

The exact rebuild and focused query commands were:

```text
python tools/forceorg_model_database.py build --catalog .tools/forceorg-model-table/catalog_v2/forceorg_model_weapon_catalog.csv --datasheets .tools/forceorg-model-table/live_20261106_4/forceorg_datasheet_profiles_11e.csv --runtime-profiles .tools/forceorg-model-table/runtime_visual_datasheet_identities.json --relations .tools/forceorg-model-table/live_20261106_4/forceorg_visual_variant_datasheet_candidates.csv --relations .tools/forceorg-model-table/forceorg_source/forceorg_visual_variant_datasheet_candidates.csv --visual-inventory .tools/forceorg-model-table/ForceOrg_catalog_visual_candidates.csv --visual-inventory .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_visual_candidates.csv --object-inventory .tools/forceorg-model-table/catalog_v2/workshop-objects.json --object-inventory .tools/forceorg-model-table/catalog_v2/autosave-objects.json --corrections .tools/forceorg-model-table/catalog_v2/visual-corrections-20261106.json --database .tools/forceorg-model-table/catalog_v2/models.sqlite
python tools/forceorg_model_database.py search --database .tools/forceorg-model-table/catalog_v2/models.sqlite --datasheet 000001157 --weapon grenade-launcher --name Intercessor --limit 12
python tools/forceorg_model_database.py search --database .tools/forceorg-model-table/catalog_v2/models.sqlite --weapon grenade-launcher --name Intercessor --limit 6
python tools/forceorg_model_database.py search --database .tools/forceorg-model-table/catalog_v2/models.sqlite --datasheet-role Fortifications --limit 20
python tools/forceorg_model_database.py objects --database .tools/forceorg-model-table/catalog_v2/models.sqlite --source ea1550037e8ae36aff8225cfc06c24eb9cd0f23a0a150e9688611aa78f70af63 --parent ObjectStates/139 --limit 3
```

The build exited 0 and stored the schema-8 input fingerprints in SQLite. The
weapon and Fortifications searches exited 0. The Fortifications query returns
source role separately from visual category and surfaces associated Gauss Pylon,
Big'ed Bossbunka, Feculent Gnarlmaw, Mekboy Workshop and Noctilith Crown variants.
A read-only SQLite audit checked `PRAGMA
integrity_check`, `PRAGMA foreign_key_check`, index definitions and both parent
query plans. An inventory of 11 local Workshop JSON saves identified `ForceOrg`
as the only Warhammer 40,000 catalog source by title; the report is stored under
`.tools/forceorg-model-table/catalog_v2/`. No test suite, network access or
download was used.

### Full current-datasheet association coverage — 6 November 2026

The new read-only `datasheet-coverage` command summarizes association evidence
for every current datasheet, including Character status and whether that sheet
has label associations, candidate-only rows, reviewed fallbacks or no source
candidate. Its full report is saved in ignored `.tools/`.

The schema-8 catalog has **1,469 datasheets** and **236 runtime identities**.
Across all datasheets, **1,057** have source-label associations, **321** are
candidate-only, **16** have reviewed fallbacks without confirmed label
associations, and **75** have no miniature candidate. Fifteen of those 16 fallback
records also have unreviewed candidates. The runtime subset matches the
established **214 / 16 / 4 / 2** split by status category. Counts describe
candidate evidence and do not certify a correct sculpt, equipment combination,
or successful asset import.

The audit also found **704** candidate variant/datasheet links whose normalized
source label exactly equals the datasheet name, across **89** sheets; all 704
have a recorded source-faction scope conflict and remain candidates. Of the 321
candidate-only sheets, **45** have **356** such exact-name links. Search results
now expose this as `exact_datasheet_name_with_faction_scope_conflict`, separate
from the candidate's association status. `--review-queue` writes one row per
exact-name/faction-conflict link with source hashes, fingerprint, occurrence
GUIDs and paths, weapons, model-role evidence and other confirmed datasheets for
the same variant. The 704 rows cover 89 datasheets and 504 distinct variants;
673 rows point to variants already confirmed against another datasheet. The
queue keeps every target link pending identity and scope review.

```text
python tools/forceorg_model_database.py datasheet-coverage --database .tools/forceorg-model-table/catalog_v2/models.sqlite --output .tools/forceorg-model-table/catalog_v2/all-datasheet-coverage-schema8-20261106.json --review-queue .tools/forceorg-model-table/catalog_v2/exact-name-scope-review-20261106.csv
```

The command exited 0. A direct comparison of all 236 runtime rows against
`runtime-coverage-current.json` matched the status counts after grouping fallback
rows without confirmed label associations. JSON report SHA-256 is
`aa198aed4b113e01bb64f2126717619b8bdfeb599808a6c8a5d30436872d9c98`; CSV review
queue SHA-256 is
`07042b4664401011e13c2d1cc52919e776d0516fe78f2456eeaa2fd1e34d9429`. Both
artifacts stay in ignored `.tools/`. No tests or network access were used.

### Datasheet weapon-profile label coverage — 6 November 2026

The new read-only `weapon-coverage` audit compares current datasheet physical
weapon names with weapon terms found in associated and candidate model labels.
Fire-mode suffixes are grouped under their shared physical weapon. It does not
certify that the weapon is visible on a mesh, legal for a specific member or
present when a label term is missing.

Across all **1,469** datasheets in the selected snapshot, **1,458** have weapon
profiles. The report contains **538** confirmed datasheet/weapon label pairs,
**548** candidate-only pairs and **5,682** pairs with no recognized source-label
term. In the 236 current runtime datasheets, **132** pairs have confirmed label
evidence, **101** are candidate-only and **744** have no recognized term across
235 datasheets with weapon profiles; 62 runtime datasheets have at least one
confirmed weapon term. These counts expose work for review, not actual-sculpt
coverage.

Intercessor Squad `000001157` has 13 weapon profile rows but ten physical weapon
names after grouping fire modes. Bolt Rifle has 68 confirmed source variants;
Grenade Launcher has ten, plus 104 candidate variants. Bolt Pistol has no
confirmed weapon-label term and four candidate variants. This does not indicate
that Intercessors lack pistols: the local 11e source equips every model with both
a Bolt Pistol and Bolt Rifle, while one non-Sergeant model per five may also take
the Grenade Launcher. The pistol is default equipment and should not be treated as
an alternative to the rifle for visual selection.

The exact report commands were:

```text
python tools/forceorg_model_database.py weapon-coverage --database .tools/forceorg-model-table/catalog_v2/models.sqlite --output .tools/forceorg-model-table/catalog_v2/weapon-coverage-schema8-20261106.json
python tools/forceorg_model_database.py weapon-coverage --database .tools/forceorg-model-table/catalog_v2/models.sqlite --runtime-only --output .tools/forceorg-model-table/catalog_v2/runtime-weapon-coverage-schema8-20261106.json
python tools/forceorg_model_database.py weapon-coverage --database .tools/forceorg-model-table/catalog_v2/models.sqlite --datasheet 000001157
```

All three completed with exit code 0. The all-datasheet report SHA-256 is
`45fdd38f559b8bd556d14fe5b8b2c646e8734f331d83b8ef499f2938327e4b85`; the
runtime-only report SHA-256 is
`5fe9985ee2e020d81e0144b1035de38153f47468ad5709b95c26478fb01f6b18`. Both
generated reports remain in ignored `.tools/`.

### Search by datasheet and weapon label

The local runtime visual index now exposes datasheet names for every admitted
label/user association, including datasheets outside the 236 runtime-profile
catalog. The Models importer searches by source model label, role, linked
datasheet/runtime name and source weapon term/alias. The selected detail separates
datasheet matches from weapon terms, labels both as source-derived evidence and
keeps the result count visible after selection.

A staged Godot 4.7.2 capture used two real Necron Warrior objects in a minimal
fixture and their copied associations from the schema-7 local index. Searching
`Gauss Reaper` returned the `necron warrior reaper` object and displayed the
`Necron Warriors` datasheet and `Gauss Reaper` term; the pre-change name-only UI
returned zero matches for the same query. Captures are in the ignored local report
`.tools/verification/model-search-ui-20261106/`. The complete-save screenshot
attempt timed out, so this confirms search presentation only on the two-object
fixture. The console-only full-save scan and search profile is recorded below; it
does not verify the full rendered UI. No network was used and no tests were run
for this UI change.

### Full Workshop catalog profile and association corrections — 6 November 2026

The local Godot 4.7.2 console scanned `ForceOrg.json` (SHA-256
`ed0b66dc0518f03ea746a485d2739deb57ea2094117d552c02925983c3bcba44`) in **5.379 s**:
35,936 TTS objects produced 32,256 visual entries and zero parser warnings. Reading
the 41.3 MiB save and 12.3 MiB visual index took 64.6 ms; parsing, traversal and
index joining account for the remaining scan time. A cold `Gauss Reaper` search
returned seven results in **279 ms**; a subsequent `Necron Warriors` query
returned nine in **43 ms**. The results include an unassociated component and
candidate-only model labels, which remain distinct from admitted datasheet links.
The headless profile log and script are under
`.tools/verification/model-catalog-performance-20261106/`; this is a debug-console
measurement from before the scan cache and search debounce, not a release-build
or frame-rate benchmark.

Four local fingerprint corrections now link both `Master Lazarus` visual variants
to datasheet `000002296` and both misspelled `Overlord with Translcation Shroud`
variants to `000003693`. A full-source Godot scan found the corrected Overlord
record by its proper datasheet name while preserving the TTS label. It also
confirmed the Lazarus link on the whole miniature; the similarly named child
component remains separate. The correction file SHA-256
`e6d570512d5c17607faa4a35d2035910feac320461ada5601e6e50042f362563` is recorded in
SQLite input metadata. At this pre-vehicle-fallback checkpoint, coverage was 214
label-associated profiles, 14 reviewed-fallback-only, six candidate-only and two
without a source candidate.
SQLite integrity is `ok` with zero foreign-key errors. Network was disabled; no
automated tests were run for these data corrections.

### Repeat source-scan cache and search profile — 6 November 2026

The production scanner now keeps a versioned binary cache of parsed static
entries in the local `user://` folder. Cache reuse requires the exact source path
and SHA-256; the source-gated visual index is reapplied on every read. Source-object
inventory exports bypass the smaller runtime cache. Malformed, stale or
incompatible cache data falls back to a full scan.

The existing headless profile
`.tools/verification/model-catalog-performance-20261106/profile_full_catalog.gd`
ran against `res://ForceOrg.json` in Godot 4.7.2. A cache miss scanned 35,936
objects into 32,256 visual entries with zero warnings in **6.685 s**, including a
**1.317 s** binary cache write (53,821,208 bytes). In a new process, a cache hit
returned the same counts and warnings in **1.353 s**; cache load took 1.138 s and
the source/index reads took 73 ms. The prior uncached baseline was 5.379 s. The
cache improves repeat scans by about 75%, at the cost of a 1.306 s first-use write.

On the cache-hit run, direct calls to the inventory filter returned the same
seven `Gauss Reaper` and nine `Necron Warriors` entries in **256 ms** and **42 ms**.
The profile calls the filter directly, so those figures exclude the 150 ms UI
debounce and do not measure rendered-frame behavior. The post-change parser check
`Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit`
exited 0. A subsequent cached real-source/index audit using
`Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/audit_forceorg_visual_catalog.gd -- --source res://ForceOrg.json --output res://.tools/verification/model-catalog-performance-20261106/cache-warm-audit.json --index-only`
passed **18,485/18,485** indexed Workshop occurrences with zero parser warnings.
No automated test suite was run and no network was used.

### Vehicle visual fallbacks and local-cache ordering — 6 November 2026

Two explicit visual-only aliases now unblock display for local profiles without
an exact source sculpt: Land Raider Excelsior (`000000067`) uses `Ultramarine Land
Raider`, and Relic Razorback (`000002720`) uses `Razorback Lascannon`. They remain
fallback-only in runtime coverage; the alias does not become a label identity,
weapon association or certification of the depicted sculpt. The Relic asset's
Lascannon source label stays separate from its datasheet equipment.

Preflight now ranks locally resolvable assets first only among variants with the
same visual-choice group. It keeps distinct role/weapon groups and manual choices
intact. The focused real-source audit selected and parsed the cached Excelsior
fallback (1/1 option) and a cached Relic Razorback fallback (4/12 equivalent
options available). This avoids trying an uncached duplicate when a visually
equivalent candidate is already in the local TTS cache; the remaining Relic
variants stay available as download candidates.

The renderer previously mistook a flat vehicle underside for a scenic base and
fitted it to the 60/120 mm gameplay proxy. For non-source-pose profiles marked
`Use model`, it now preserves the TTS root scale, reports no physical base size,
and keeps the interaction proxy independent. The UI labels this as source model
scale, not base measurement. This improves source proportions but does not
certify exact real-world dimensions or board clearance. The prepared-GLB cache
key now includes this hull-fit version and its source/user scales, so prior hull
packages cannot silently keep the old proxy-fitted result.

Four complete local vehicle candidates were rendered through the production OBJ
parser, composite assembler, fit settings and `Assets.visual`, using the source
TTS scale (`1.1` for each captured root). The Godot capture is
`.tools/verification/model-vehicle-render-20261106/candidates.png` (SHA-256
`2234E5966FA1F596D4D82BE6029B580B17FAA846D3B37EDD92DD24783AA1462C`); its report
is `render-report.json`. This is a staged source-asset render, not a live match,
identity review or library certification. Eleven of eleven selected cached
assemblies parsed, but only the four shown were visually rendered.

The focused runtime and rendering commands were:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/forceorg-model-table/catalog_v2/audit_reviewed_vehicle_fallbacks.gd -- res://ForceOrg.json "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods"
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script .tools/forceorg-model-table/catalog_v2/capture_cached_vehicle_candidates.gd -- res://ForceOrg.json "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods" res://.tools/forceorg-model-table/catalog_v2/local-cache-candidate-review-20261106.json
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit
```

The runtime audit exited 0 and selected a locally parsed fallback for each
datasheet; the actual-renderer capture exited 0; the Godot source check exited 0.
These runs used local assets, with no downloads or network access. No test suite
was run. Latest schema-7 coverage is 214 label-associated, 16
reviewed-fallback-only, four candidate-only and two with no source candidate.

### Additional local ForceOrg source audit — 6 November 2026

The local TTS Workshop cache contains item `3753014527` (`ForceOrg`), SHA-256
`6293a22c39da3d932d7f062d280ea0c1154709219158286026182cf1dad09f67`. It was
exported with the production static scanner:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_forceorg_visual_table.gd -- "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods\Workshop\3753014527.json" res://.tools/forceorg-model-table/catalog_v2/forceorg_workshop_cache_20261106.csv
```

The export completed with 37,351 parsed objects, 19,154 visual rows, 17,871
distinct variants, 10,979 embedded static objects and zero parser warnings.
Comparing its variant export with the current schema-7 catalog found all
**17,523/17,523** asset fingerprints and all **17,871/17,871** fingerprint/label
pairs already present. No new visual variants or labels were added.

The three other TTS AutoSave files in the user Saves directory were also compared
with the indexed AutoSave snapshot. Each had the same **1,543** path/label/GUID/
asset/tint visual signatures and **47** `objectJSONs` script path/hash pairs.
Their save hashes differ, but none adds model inventory. The exact filenames and
hashes plus the local comparison report are recorded in the [database source
audit](../data/model-variant-database.md). No network or model download was used;
this comparison does not certify geometry or prove global ForceOrg completeness.
A separate inventory of cached TTS Workshop JSON saves found ForceOrg and ten
unrelated tabletop games; it found no additional local Warhammer 40,000 scenery
source to add to the catalog.

### Intercessor weapon-to-model source audit

The selected local 11e snapshot (`20261021T130623Z`, manifest SHA-256
`169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`) defines
Intercessor Squad `000001157` with a Bolt Pistol and Bolt Rifle on every model;
for every five models, one non-Sergeant Intercessor may also be equipped with a
Grenade Launcher. The pistol is default equipment, not an either/or sculpt choice.

The latest two-save database rebuild adds five fingerprint-scoped corrections for
Grenadier-labelled Intercessors. All five are returned with datasheet
`000001157`, role `Intercessor`, weapon `grenade-launcher` and status
`user_association`; the correction file SHA-256 is
`be83119e4d1717725bf421fb8234b407bfa95eadbf4118907dedd99ee5f265d1`. The
corrections preserve each original TTS label. Sergeant-labelled `Auto-Bolt Rifle
+ GL` candidates remain uncorrected because the local 11e sheet gives the
Grenade Launcher option to a non-Sergeant Intercessor.

A focused scan of the Workshop save found four runtime Grenadier candidates; two
of four had complete files in the 5,981-file local TTS cache and parsed through
the composite importer. The `Intercessor Grenadier` assembly in the Ultramarines
family was selected by the production `visual_role_variant_for` function and
loaded through `visual_variant_for` at a 32 mm visual fit. The staged Godot
capture is
`.tools/forceorg-model-table/catalog_v2/intercessor-weapon-selection-20261106.png`
(SHA-256
`9F7106C4234C0B1BD74C1DC29AFB0029597B871C938FF76F4630CEB7A8B3A1AA`); the
local report is `intercessor-weapon-selection-20261106.json`. This confirms the
source assembly and weapon-specific selection path, not sculpt identity or a live
match.

The selected Iron Hands appearance has no same-family Grenadier. Two complete
Grenadier candidates in the local Workshop cache parse through the importer, one
from the Ultramarines family and one with a derived material family; the Raptors
candidate has no mesh and the AssetBundle candidate is unsupported. Runtime now
considers already available weapon-compatible variants from other families after
same-family matches. This fallback uses only files already in local mappings;
selected-group role preflight does not queue or download cross-family candidates.

The saved user model settings also contain complete generic Intercessor variants;
the top-level `Primaris Intercessor` mapping is only a detached component and is
rejected for being too short to represent a full infantry miniature. In the
selected material family (`materials-v1:11623a8891a8f101b792bd68c75472920a2752279008d2b5fe260ca2dfadf1ce`),
variant `02ca311d03641cebb41e42c5738771a3f36565496bac5e3c4e20183c04a62aea`
(`Intercessors`) is a complete shared fallback. The next saved generic candidate
`6d32cae646e46913abef0381bcdb51b5ecb7dd426a01fc22bbf279774805165d`
(`Primaris Intercessor`) also renders, but has a different derived material
family.

A staged Godot capture used the production local variant loader and family-aware
selectors. It simulated a missing file for the first same-family generic candidate
in memory only; the saved settings were restored immediately, and the next
cross-family generic candidate rendered. This confirms recovery through the
importer when a preferred candidate fails, but does not reproduce an actual file
failure in a live match or certify matching paint. The capture is
`.tools/forceorg-model-table/catalog_v2/saved-intercessor-fallback-20261106.png`
(SHA-256
`93F4EBA0A5CC695BF9B328259239E47A50B4CB99C303A0C5C9EE9EA9138D513C`); its local
report is `saved-intercessor-fallback-20261106.json`. Runtime now orders
same-family generic candidates before any-family generic candidates. Equipment-
compatible candidates from other families now come before generic recovery.
Confirm the complete sequence in a live match; automatic cross-family recovery
can change the visible palette.

### Cross-family weapon-specific fallback — 6 November 2026

The runtime candidate ordering now lives in
`ModelImportPanel.ordered_equipment_visual_variants_for`; `main.gd` calls this
same method for local model rendering. This keeps the family and weapon
priorities in one implementation. The staged Godot capture used that production
resolver for an Intercessor with Bolt Rifle + Astartes Grenade Launcher. The
selected appearance family was Iron Hands, it had no same-family Grenadier, and
the resolver returned the file-ready Ultramarines `Intercessor Grenadier`
(`1df3f9943d95898acb2955d3ac2c2df33734ff3535348e44a9e53b9784f88899`) as its
first candidate. The composite importer rendered it with a reported 32 mm base
fit. The local scan fingerprint is
`ed0b66dc0518f03ea746a485d2739deb57ea2094117d552c02925983c3bcba44`; the local
cache index contained 5,981 files. The capture image is
`.tools/forceorg-model-table/catalog_v2/intercessor-cross-family-weapon-selection-20261106.png`
(SHA-256
`9F7106C4234C0B1BD74C1DC29AFB0029597B871C938FF76F4630CEB7A8B3A1AA`), and
`intercessor-cross-family-weapon-selection-20261106.json` records the candidate
order and import metadata.

The selected-family generic `Primaris Intercessor` failed to load because its
mesh was unavailable in that local cache, so the capture demonstrates candidate
selection and Grenadier loading, not a side-by-side comparison with a usable
generic model. It is a staged local render, not a live match or a paint-identity
check. No network or download was used. Cross-family variants are only eligible
when their files are already available; this fallback does not preflight or fetch
them.

After the correction rebuild, schema 7 contains **35,884 variants**,
**147,384 candidate/identity links** and **38,495 visual catalog occurrences**.
The source-gated runtime index contains **9,107 runtime-associated occurrences**.
Index-only audits passed for **18,485/18,485** Workshop and **20,010/20,010**
AutoSave occurrences, with zero identity mismatches. Runtime coverage remains
214 label-associated, 16 reviewed-fallback-only, four candidate-only and two
without a source candidate.

The focused commands were:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/forceorg-model-table/catalog_v2/audit_intercessor_variants.gd -- res://ForceOrg.json "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods"
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script .tools/forceorg-model-table/catalog_v2/capture_intercessor_weapon_selection.gd -- res://ForceOrg.json "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods"
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/audit_forceorg_visual_catalog.gd -- --source res://ForceOrg.json --output res://.tools/forceorg-model-table/catalog_v2/intercessor-workshop-index-audit-20261106.json --index-only
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/audit_forceorg_visual_catalog.gd -- --source .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json --output res://.tools/forceorg-model-table/catalog_v2/intercessor-autosave-index-audit-20261106.json --index-only
```

All commands used local files only; no network or downloads were used. No test
suite was run for this data correction or capture.

### Complete bounded static-object inventory

`python -m unittest tests.test_forceorg_model_database` passed **18/18**. New
cases verify source type precedence (a character-named card remains ignored),
dimension-only bases, non-mesh terrain versus unknown objects, complete source
coverage, unique object paths, valid parents and default accessory exclusion in
object search. The isolated `test_local_models` suite passed with current scanner
and test files copied into `.tools/verification/20261106T054254959062Z/project`:

```text
<godot-4.7.2> --headless --path <imported-project> --log-file <report>/test_local_models.engine.log --script tests/test_local_models.gd
```

Here `<report>` is `.tools/verification/model-source-objects-20261106`.
`results.json` records exit 0 and no cleanup diagnostics. The new scanner cases
check opt-in inventory allocation, container/visual/state coverage and actual
parent paths. Existing loading, transforms, measured-base and source-family
regressions remain covered by that suite.

Both real saves were exported with
`<godot> --headless --path <workspace> --script tools/export_forceorg_object_inventory.gd -- <source> res://.tools/forceorg-model-table/catalog_v2/<name>-objects.json`.
Workshop (`ForceOrg.json`) yielded **35,936 objects**, including **32,256 visual
entries**; AutoSave (`.tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json`)
yielded **38,830 objects**, including **34,751 visual entries**. This includes
child parts; those visual-entry counts are not the earlier root-candidate counts.
Both exports exited 0 with no parser warnings (`export-results.json`). No Lua was
executed and no content downloaded. Exports check that the source did not change.

The database guide's build command with both `--object-inventory` inputs passed
at schema 7, preserving **35,884 variants**, **147,426 candidate/identity links**
and **38,495 visual catalog occurrences** at that checkpoint. The later schema-7
correction rebuild records **147,384** candidate/identity links; its updated
runtime occurrence count and current source-index audits are documented in the
Intercessor audit above. Every catalog occurrence matched an
object's exact source hash/path/label/GUID. All **74,766** object records have
valid parent hierarchy. Source-object classification is **38,380 miniature
occurrences, 28,508 components, 1,760 containers, 5,808 ignored objects, 95 bases,
two terrain-labelled occurrences and 213 unclassified objects**. The two terrain
occurrences share the label `Shield Wall`; this does not establish a broad scenery
collection or certify that label against rendered geometry. Fifty-nine visual
variants with dimension-only names were corrected from miniature to base; none
had an admitted current-runtime identity association.

SQLite integrity returned `ok`; foreign-key check returned no rows.
`database-audit.json` records the checkpoint counts. `export-index` and `coverage`
passed; that checkpoint's 236 runtime profiles comprised 212 label-associated,
14 fallback-only, eight candidate-only and two without source candidates. The
current 214/236 coverage split is in the latest schema-7 report above. The source/index audits
were rerun with `tools/audit_forceorg_visual_catalog.gd --source <source> --output <report>/index-<name>.json --index-only`:
**18,485/18,485** Workshop and **20,010/20,010** AutoSave catalog occurrences
matched with zero warnings (`index-results.json`).

The actual commands `python tools/forceorg_model_database.py objects --database
.tools/forceorg-model-table/catalog_v2/models.sqlite --category terrain --limit 2`
and the same command with `--category component --name 'necron warrior flayer'
--limit 1` returned exact source/parent paths, category evidence and supported
reference status. Object search does not infer a component's own datasheet from
its parent, admit new army profiles, or claim that a reference can be rendered.
Coverage is bounded to static literal objects in these two selected saves;
dynamic Lua-produced objects and external scenery collections are not covered.

### Terrain and Fortifications coverage audit — 6 November 2026

The schema-8 local index has one explicit terrain label, `Shield Wall`, repeated
once in each selected save. Both variant rows have candidate-only links and no
confirmed datasheet association. Ten candidate links point to five sheets,
including Shield-Captain, Wulfen with Storm Shields and Tomb Citadel Walls; these
name overlaps remain candidates. The separate `Fortifications` datasheet-role
facet covers 28 current-source sheets: 44 confirmed variant-to-datasheet links
and 437 candidate links across 319 unique variants. These are searchable via
`search --datasheet-role Fortifications`; they remain visually categorized as
miniatures or terrain according to their source-object evidence.

The two Shield Wall occurrences were checked against the local Tabletop Simulator
cache with the existing offline cache/OBJ audit:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://.tools/forceorg-model-table/catalog_v2/audit_exact_name_candidate_cache.gd -- 'res://ForceOrg.json' 'res://.tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json' 'C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods' 'res://.tools/forceorg-model-table/catalog_v2/shield-wall-occurrences-20261106.json' 'res://.tools/forceorg-model-table/catalog_v2/shield-wall-cache-audit-20261106.json'
```

The command exited 0 and matched both exact source hash/path/GUID occurrences in
the 5,981-file cache, but neither had its OBJ cached; zero meshes were parsed and
no association changed. The ignored input SHA-256 is
`109931599daa5558e2719e48f04d5715a36a76fd7cd09128a5dc02b684be117d`; the report
`.tools/forceorg-model-table/catalog_v2/shield-wall-cache-audit-20261106.json`
has SHA-256 `f4bc6f24000179ab0e6cbbebe147d979756947596ea355e0ccb047d6bedab633`.
No network or download was used and no tests were run. This confirms that the
sole explicitly terrain-labelled candidate in the selected sources is not
locally renderable; a separate user-supplied scenery source is still needed to
expand that category.

### Object-only source ingestion smoke check — 6 November 2026

The database builder now accepts `--object-only-inventory` for an additional
local static-object source that has no model catalog or datasheet crosswalk. A
scratch-only smoke check used the locally installed TTS table `The Mind`; it was
not added to the project’s Warhammer catalog. The production object scanner
returned 132 objects and zero warnings:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_forceorg_object_inventory.gd -- "C:\Users\Warmachine\Documents\My Games\Tabletop Simulator\Mods\Workshop\1365287616.json" res://.tools/forceorg-model-table/catalog_v2/object-only-smoke-mind-objects.json
```

The scan output SHA-256 is
`b911e16acf4edbea8e7710847ee3881361292009654c573b84b2f62b5474f3b3`; its source
save SHA-256 is
`9b023bdd82aa166baf6bbff53516bc3236eb3b3a7e2fc08dacc2ec3d9764d741`. Rebuilding
the usual schema-8 catalog into a separate scratch database with the additional
object-only input succeeded:

```powershell
python tools/forceorg_model_database.py build `
  --catalog .tools/forceorg-model-table/catalog_v2/forceorg_model_weapon_catalog.csv `
  --datasheets .tools/forceorg-model-table/live_20261106_4/forceorg_datasheet_profiles_11e.csv `
  --runtime-profiles .tools/forceorg-model-table/runtime_visual_datasheet_identities.json `
  --relations .tools/forceorg-model-table/live_20261106_4/forceorg_visual_variant_datasheet_candidates.csv `
  --relations .tools/forceorg-model-table/forceorg_source/forceorg_visual_variant_datasheet_candidates.csv `
  --visual-inventory .tools/forceorg-model-table/ForceOrg_catalog_visual_candidates.csv `
  --visual-inventory .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_visual_candidates.csv `
  --object-inventory .tools/forceorg-model-table/catalog_v2/workshop-objects.json `
  --object-inventory .tools/forceorg-model-table/catalog_v2/autosave-objects.json `
  --object-only-inventory .tools/forceorg-model-table/catalog_v2/object-only-smoke-mind-objects.json `
  --corrections .tools/forceorg-model-table/catalog_v2/visual-corrections-20261106.json `
  --database .tools/forceorg-model-table/catalog_v2/models-object-only-smoke.sqlite
```

The scratch database retained **35,884 variants** and **147,384 links**, added
132 source-object rows, and recorded the extra source hash with zero variant or
datasheet-link rows for it. `objects --category ignored --source
9b023bdd82aa166baf6bbff53516bc3236eb3b3a7e2fc08dacc2ec3d9764d741 --limit 1`
returned a TTS Card as `ignored` with no catalog variant IDs. SQLite integrity
was `ok` with no foreign-key errors. This verifies independent inventory and
accessory exclusion; it does not validate Warhammer terrain, mesh rendering or
datasheet matching. The smoke database remains ignored under `.tools/`; no
network, downloads or test suite were used.

### Source-object category refinement — 6 November 2026

The Godot scanner records `asset_kinds` from the object's explicit TTS asset
fields. The catalog now marks `Custom_Tile` records with only `CustomImage`
references as ignored for 3D model selection, after preserving explicit terrain
labels and existing visual-catalog matches. ForceOrg dropdown, search and
CleanerBlock controls are also marked ignored from their labels. All records
remain in `source_objects` with category evidence. The unclassified inventory is
now four `BlockSquare` records: the generic `BlockSquare` and `Yellow Storage`,
repeated across two saves. The local ForceOrg Workshop save `3753014527`
(`6293a22c39da3d932d7f062d280ea0c1154709219158286026182cf1dad09f67`) contains
`Yellow Machine` at `ObjectStates/115`, GUID `46ccee`, with the same label and
TTS type. Static inspection of its bundled `Yellow Machine.46ccee.lua` module
found button and object-spawn functions, supporting its utility classification.
An exact source-hash/path join found no image-only tile occurrence in the visual
variant catalog.

The canonical schema-8 rebuild retained **35,884 variants**, **147,384 links**
and **74,766 source objects**. Object categories are 38,380 miniatures, 28,508
components, 1,760 containers, 6,017 ignored, 95 bases, two terrain-labelled
objects and four unclassified. A separate scratch rebuild produced the same
counts; SQLite integrity was `ok`. Source-object rows and datasheet/model
associations are unchanged; only object category/evidence changed. No rules
data, downloads, network checks or test suite were involved.

### Actual weapon models and measured-base priority

The saved local diagnostic at
`.tools/verification/model-warrior-render-20261106/capture_variants.gd` scans the
exact Workshop source, builds both actual assemblies from their component plans,
and registers their real local file paths/fingerprints with the production
import panel. `equipment_variant_for` selects each equipped weapon's identity;
`visual_variant_for` loads the selected complete assembly. A staged Godot scene
captures front and reverse views at 1200×800. This is actual engine rendering,
not a mockup or a live match screenshot. No player mappings were changed.

The Reaper mesh, base mesh and shared texture were reused from local caches.
Only the missing Flayer OBJ was downloaded from its existing Workshop object
reference: 1,192,900 bytes, SHA-256
`29dbcb40c1a29b8eb347285383d5e97875b74694816fdecf47c58e6caf934e8f`.
`assets.json` in that report directory records every asset URL, local path and
hash; all third-party data and images remain ignored local artifacts.

The initial render exposed the Flayer body's estimated footprint overriding the
separate complete base ring: visual scale **0.8686355**, versus **1.0083712** for
the Reaper. After measured rims took priority over heuristic estimates, both use
**1.0083712**, with reported footprint **1.259843 inches** on each axis (the
32 mm visual-fit target). Source geometry, rules bases and equipment are unchanged.
`before-front.png`, `before-reverse.png`, `before-report.json`, `front.png`,
`reverse.png`, and `render-report.json` preserve the same-framing comparison.
Both final images were inspected: complete models, distinct weapons and shared
source texture are visible. Source tints are not applied by this OBJ path, so
the bases render white; this is not exact TTS material/paint parity.

The render command was:

```text
<godot-4.7.2> --path <workspace> --rendering-method gl_compatibility --resolution 1200x800 --script <report>/capture_variants.gd
```

`results.json`, `metrics-results.json` and `after-results.json` record successful
exit-0 renders with isolated user/temp directories and no network during rendering.
The final diagnostic additionally checked identical uniform scales and `ring`
detection for both models. The current isolated `test_local_models` and
`test_model_equipment_visuals` suites also passed via
`<godot> --headless --path <imported-project> --log-file <report>/<suite>.engine.log --script tests/<suite>.gd`.
The imported project is `.tools/verification/20261106T054254959062Z/project`;
current scanner and local-model tests were copied before the run. New regressions
check that a measured rim retains its footprint and center against a larger
estimated body outline in either component order. Results are in
`test-results.json`. This evidence is bounded to local import/rendering and
selection; it does not certify all weapons, appearance families or network play.
The separate `test_local_armies_models` run also passed with current code;
`fallback-test-results.json` records its exit-0 result. It retains the synthetic
board swap, corrupt-file alternative and explicit-assignment regressions; it is
not an actual-asset live match input capture.

### Material families for entries without declared groups

Four isolated Godot suites passed: `test_model_equipment_visuals`,
`test_local_models`, `test_local_armies_models`, and `test_forceorg_catalog`.
The command for each was:

```text
<godot-4.7.2> --headless --path <imported-project> --log-file <report>/<suite>.engine.log --script tests/<suite>.gd
```

`<imported-project>` is `.tools/verification/20261106T054254959062Z/project`, with
the current scanner, importer and changed suites copied before execution.
`<report>` is `.tools/verification/model-material-families-20261106`.
`results.json` records all four exit-0 results, isolated user/temp profiles,
`network: false` and no cleanup diagnostics. New cases cover shared static
materials across different meshes, distinct tints/textures, exact geometry for
untextured parts, unknown bundles/built-in children, preservation of original
source groups, declared-group priority, cached selection and preparation/runtime
family agreement. Existing explicit overrides and fallback checks also passed.

The saved diagnostic command
`<godot-4.7.2> --headless --path <workspace> --script <report>/audit_actual_families.gd`
passed after correcting an initial diagnostic-only parse error (`Panel` shadowed
a native class). Both attempts are retained in `actual-results.json` and
`actual-corrected-results.json`. The final actual-save report
`actual-families.json` records exact source hashes and zero parser warnings. It
finds derived material families on **1,665 Workshop** and **2,208 AutoSave**
runtime-associated occurrences lacking source groups. All five exact
Flayer/Reaper occurrences per save share one derived family; the production
role-preparation filter returns five variants and includes both `gauss-flayer`
and `gauss-reaper`. No files were downloaded or geometry imported. These are
material-reference, filtering and synthetic-cache checks, not rendered weapon,
paint, live-input or multiplayer certification.

### Abbreviated weapons after a complete model name

`python -m unittest tests.test_forceorg_model_database` passed **15/15**. New
cases cover complete model prefixes, unique/ambiguous source suffixes, firing
modes, unknown modifiers, historical prefixes, extended identities and per-link
search evidence. The initial real-data build exposed a false interpretation of
`Burning Chariot of Tzeentch`; it was removed by preserving/rejecting identity
connectors and adding a regression. A new search-fixture run initially failed
Windows temporary-directory cleanup because its SQLite connection remained open;
the fixture now explicitly closes it before cleanup, and the final run passed.

The documented local build command in
[the database guide](../data/model-variant-database.md#build-and-search), followed
by its `export-index` command, succeeded with schema 6. There are **91** added
weapon terms across 91 previously unrecognized variants, with **100** per-link
resolution records. Integrity check returned `ok`; foreign-key check returned no
rows. Comparison with the pre-change database found zero removed weapon terms
and zero changes to variants, occurrences, identity links, runtime identities,
model roles or visual substitutes. Evidence:
`.tools/verification/model-label-suffix-20261106/database-diff.json`.

The isolated offline runner executed these commands through Godot 4.7.2:

```text
<godot> --headless --path <workspace> --script tools/audit_forceorg_visual_catalog.gd -- --source ForceOrg.json --output <report>/workshop-isolated.json --index-only
<godot> --headless --path <workspace> --script tools/audit_forceorg_visual_catalog.gd -- --source .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json --output <report>/autosave-isolated.json --index-only
<godot> --headless --path <workspace> --script <report>/check_warrior_labels.gd
```

Here `<report>` is `.tools/verification/model-label-suffix-20261106`.
All three exited 0. The two index audits matched **18,485/18,485** Workshop and
**20,010/20,010** AutoSave occurrences with no parser warnings. The saved local
diagnostic script scanned both real saves and checked all ten exact
`necron warrior flayer` / `necron warrior reaper` occurrences: matching equipped
weapon score 10, opposite weapon score -1. Commands/results and individual rows
are in `results.json` and `warrior-labels.json` there. No downloads or geometry
imports occurred. These checks establish scanner-to-equipment-score behavior;
they do not establish appearance-family selection, visual fidelity or networking.

### Unique source-weapon terms and physical-weapon ranking

`python -m unittest tests.test_forceorg_model_database` passed **13/13** after adding
same-datasheet unique weapon expansions. Tests reject short terms shared by Twin
and Quad weapons, prefer an existing exact source name, combine firing modes into
one physical weapon, and keep Auto Bolt Rifle separate from Bolt Rifle.

Schema 5 stores **47** source-bounded alias pairs. The real Hammerfall source rows
map `heavy-bolter` / `heavy-flamer` to the corresponding full Hammerfall array
names. The generated index carries those mappings under the relevant definition,
not as global synonyms. The current identity exporter ran successfully before
the database rebuild because the matcher hash changed.

An initial equipment-suite attempt at
`.tools/verification/model-weapon-aliases-20261106/initial-results.json` used an older
staged import panel and failed because it lacked `equipment_variants_for`. This is
not a passing run. After copying the current scripts/tests and edition-11 project
data into the previously imported isolated project, the existing
`tools.verify.Runner` commands passed **4/4** suites at
`.tools/verification/model-weapon-aliases-current-20261106/results.json`:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-weapon-aliases-current-20261106/test_model_equipment_visuals.engine.log --script tests/test_model_equipment_visuals.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-weapon-aliases-current-20261106/test_forceorg_catalog.engine.log --script tests/test_forceorg_catalog.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-weapon-aliases-current-20261106/test_local_armies_models.engine.log --script tests/test_local_armies_models.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-weapon-aliases-current-20261106/test_local_models.engine.log --script tests/test_local_models.gd
```

The report's hashes match the current runtime scripts. The later index-bridge
assertion reran the equipment suite with the same command form and log directory
`.tools/verification/model-weapon-alias-bridge-20261106/`, passing **1/1**; that report
also verifies current source/test hashes. All runs use separate APPDATA/XDG/TMP
profiles, network disabled and no cleanup diagnostics. Checks establish that the
short Hammerfall term matches the equipped Bolter array, is rejected for a Flamer,
survives the index bridge, and contributes one physical weapon even if both short
and full labels are present. Existing catalog, board fallback and local-model
regressions also pass. No actual-asset visual fidelity or network claim is added.

### Literal names, existing proxies and exact occurrence labels

`python -m unittest tests.test_forceorg_model_database` passed **12/12**. The added
checks keep reviewed substitutes separate from model identity, account for every
coverage state, restrict literal-name suffixes to the selected sheet's source
weapons/models/composition, and retain case-sensitive occurrence labels while
rejecting other-save and duplicate-path inventories.

The updated identity exporter passed in an isolated Godot process at
`.tools/verification/model-fallback-registry-20261106/results.json`. Its exact
command is stored in that report; it uses `--script tools/export_runtime_visual_datasheet_identities.gd`
and `-- --output <absolute local runtime_visual_datasheet_identities.json>`, against
the previously imported clean-current-catalog project. The output has 236 runtime
identities and the current matcher SHA-256. Existing substitute labels now have
their own `fallback_links` table; a changed matcher hash requires re-exporting.

The following is the earlier schema-4 build/export checkpoint, superseded by the
schema-7 profile and fingerprint corrections recorded at the start of this file.
At this checkpoint the [database guide](../data/model-variant-database.md)
reported **35,884 variants**, **147,426 identity/candidate relations** (including
109 additional literal-name relations), and **326 separate fallback links**.
Coverage was **212 label-associated**, **14 fallback-only**, **8 candidate-only**
and **2 with no source candidate**, totalling 236. The index contained 38,495
occurrences and 9,098 runtime-associated occurrences. These counts describe the
pre-correction baseline; current schema-7 counts and hashes are in the latest
profile above and `.tools/forceorg-model-table/catalog_v2/audit.json`.

The offline real-save matcher commands were:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T060704875991Z/project --log-file .tools/verification/model-real-source-choices-20261106/workshop.engine.log --script tools/audit_forceorg_visual_catalog.gd -- --source ForceOrg.json --output .tools/verification/model-real-source-choices-20261106/workshop-choices.json
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T060704875991Z/project --log-file .tools/verification/model-real-source-choices-20261106/autosave.engine.log --script tools/audit_forceorg_visual_catalog.gd -- --source .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json --output .tools/verification/model-real-source-choices-20261106/autosave-choices.json
```

The runner expands those paths to absolute paths and isolates APPDATA/XDG/TMP per
process; full argv arrays are stored in
`.tools/verification/model-real-source-choices-20261106/results.json`. **2/2 passed**,
with zero parser warnings and source choices for **226/236 Workshop** and
**227/236 AutoSave** identities. Those counts include existing aliases and runtime
name normalization; they are distinct from database label-association counts.
No model downloads, mesh imports, graphical inspection or network checks ran.

That scan exposed one case-variant occurrence per source which the old canonical
label substitution failed to attach: `Aspiring Champion bolt/chain` versus
`Aspiring Champion Bolt/Chain`. Detailed inventories now preserve each original
label, with source hash/GUID/path/fingerprint checks. The index comparison at
`.tools/verification/model-occurrence-index-20261106/label-differences.json`
shows only those two label corrections; all definition/weapon/role associations
are unchanged. The future visual-table exporter also records occurrence labels.

The first index-only helper run failed to parse because an `ok` variable inferred
its type from a Variant; that failed report remains at
`.tools/verification/model-occurrence-index-20261106/results.json`. With explicit
boolean typing, both commands passed using the same script/path/source arguments,
`--index-only`, and log/report paths under
`.tools/verification/model-occurrence-index-fixed-20261106/`. Its `results.json`
stores full argv arrays and the index hash. Godot confirmed **18,485/18,485 Workshop**
and **20,010/20,010 AutoSave** occurrences, zero parser warnings, **2/2 processes**.
An independent detailed-CSV comparison also matched all 38,495 labels and GUIDs.
Index-only mode does not rerun profile choices; the two corrected aliases are
outside the Marine/Necron runtime identities used by the earlier choice audit.

The changed visual-table exporter was then run through Godot with a synthetic
two-object save sharing one asset/family but differing in label case. It passed
**1/1** and its single grouped variant retained both exact occurrence labels.
Report: `.tools/verification/model-occurrence-export-20261106/results.json`;
the full argv uses `--script tools/export_forceorg_visual_table.gd -- <synthetic-save.json> <synthetic-visuals.csv>`
in the same imported isolated project. The report records the successful Python
CSV/JSON round-trip assertion; no third-party models or network access were used.

These results establish source inventory, identity/proxy distinctions and local
matcher behavior. They do not certify complete miniatures, weapon fidelity,
paint, local-file readiness, rules accuracy or separate-machine behavior.

### Model roles, current names and corrupt-asset alternatives

The subsequent `python -m unittest tests.test_forceorg_model_database` passed
**8/8**. Added checks cover mixed-model role specificity/ties and the source CSV's
`True`/`true` faction flags. The latter bug previously withheld valid exact-label
associations. At this schema-6 checkpoint the database had 35,884 variants and
147,317 candidate relations; the current schema-7 audit is recorded above.
At this checkpoint, **18,943** relations qualified as label associations,
covering **203** runtime identities. Its index carried 38,495 total occurrences
and **8,790** with
runtime associations. Per-datasheet model-role links remain unresolved when the
source label cannot distinguish the member; no tied role is selected arbitrarily.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_model_catalog_names --timeout 300
```

This clean-current-catalog run passed **3/3 processes** at
`.tools/verification/20261106T060704875991Z/results.json`, without staging the
historical starter pack or enabling network access. The Godot suite checked all
**236 current identities**, reported zero failures, and resolved a Doomsday Ark
from its current name. The suite is explicitly exempted from legacy staging
because it asserts that the historical pack is absent; its negative fixture path
is not an actual runtime dependency. The initial focused attempt, before adding
that fixture classification, was rejected before execution.

The current scanner/matcher/import-panel/main scripts and updated tests were copied
to the previously imported isolated project at
`.tools/verification/20261106T054254959062Z/project`. Using `tools.verify.Runner`
with separate APPDATA/XDG/TMP profiles, the commands below passed **4/4**:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-role-fallback-20261106/test_model_equipment_visuals.engine.log --script tests/test_model_equipment_visuals.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-role-fallback-20261106/test_forceorg_catalog.engine.log --script tests/test_forceorg_catalog.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-role-fallback-20261106/test_local_armies_models.engine.log --script tests/test_local_armies_models.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-role-fallback-20261106/test_local_models.engine.log --script tests/test_local_models.gd
```

Report: `.tools/verification/model-role-fallback-20261106/results.json`, with
matching current source SHA-256 hashes, exit codes 0, no cleanup diagnostics and
network disabled. These checks include Chaplain/Cenobyte separation, an unarmed
companion, indexed Company Heroes roles, ambiguous-role fallback, ranked alternate
assets and a corrupt leading OBJ falling through to the next compatible miniature
through the actual board-node rendering path. `local_visual_resolved` scene
metadata verifies which miniature rendered, rather than only the attempted ID list.
The authoritative match state is unchanged by rendering. This is headless node
behavior evidence, not a new visual-inspection or whole-library fidelity claim.

`search --datasheet 000002772 --model-role Ancient --limit 1` returned a source
Ancient with its Company Heroes role and separate Ancient datasheet association.
Results now expose weapon terms, all datasheet scores/statuses and role evidence.

### Initial database increment and earlier evidence

`python -m unittest tests.test_forceorg_model_database` passed **6/6** checks:
raw inventories require an explicit relation join; source mismatches and missing
rules provenance fail; leading-zero source IDs, existing links and real candidate
ties survive consolidation; accessories, child paths and mount notes classify
without the Shrike-without-wall false positive. The sixth check confirms that the
full export vocabulary recognizes Gauss Reaper while preserving historical Auto
Bolt Rifle labels separately from current Bolt Rifle equipment.

The local rebuild commands in [the database guide](../data/model-variant-database.md)
completed with **35,884 variants**, **147,317 candidate relations**, **32,971 rows
with a best candidate**, and **3,632 exported runtime-associated occurrences**.
SQLite integrity and foreign-key checks passed within the builder. Searches using
`search --datasheet 000001157 --weapon grenade-launcher` and
`search --character --name Captain` returned the expected respective label-based
entries. Inputs and their SHA-256 hashes are in the database `metadata` table.

The initial command was:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_equipment_visuals --only test_forceorg_catalog --only test_local_models --only test_local_armies_models --timeout 300
```

Its report `.tools/verification/20261106T054254959062Z/results.json` records import,
Python, catalog, local-model and army-preparation passes, and a failed new test
script caused by shadowing Godot's native `Panel` class. That run is **not** an
overall pass. A preceding `focused` invocation was rejected before execution
because these dependencies require the staged historical starter fixtures.

After renaming the test constant and adding cached-metadata refresh, the current
test/import-panel files were copied into that already imported isolated project.
The existing `tools.verify.Runner` then ran these commands, with a separate
APPDATA/XDG/TMP profile and engine log for each label:

```text
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-equipment-final-20261106/test_model_equipment_visuals.engine.log --script tests/test_model_equipment_visuals.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-equipment-final-20261106/test_forceorg_catalog.engine.log --script tests/test_forceorg_catalog.gd
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path .tools/verification/20261106T054254959062Z/project --log-file .tools/verification/model-equipment-final-20261106/test_local_armies_models.engine.log --script tests/test_local_armies_models.gd
```

Final result: **3/3 processes passed**, exit code 0, no cleanup diagnostics,
network disabled. The final report is
`.tools/verification/model-equipment-final-20261106/results.json`; its source
hashes match the current scanner, matcher, import panel, main script and new test.
Checks cover indexed source gating, a generic Bolt Rifle + GL label, equipped
weapon instances across profile modes, Sergeant and datasheet boundaries,
same-group selection, unavailable files, cached metadata refresh and unchanged
authoritative equipment. Existing catalog and army-preparation regression checks
also pass. This does not establish complete sculpt identity, mixed-role coverage,
live visual behavior, matching paint, whole-library coverage or network readiness.

After adding the full weapon vocabulary and carrying accessory categories through
the generated index, the current-source rerun passed **3/3** at
`.tools/verification/model-equipment-final-v2-20261106/results.json`. It used the
same isolated imported project and command forms above, with logs under the new
report directory. The later board-integration extension reran
`test_local_armies_models` with the same engine/path/script arguments and
`--log-file .tools/verification/model-equipment-board-20261106/test_local_armies_models.engine.log`;
it passed **1/1**, with zero failures and no cleanup diagnostics. Its report at
`.tools/verification/model-equipment-board-20261106/results.json` records hashes
matching the current runtime files and the extended test. A generated label
association changes the actual `LocalModelVisual` through `main.gd`, independently
of the handwritten Grenadier alias flag; removing the equipped weapon restores
the shared appearance, and rendering preserves authoritative state.

The final local index carries **38,495 source occurrences**, of which **3,632**
have runtime associations. Default database searches and the runtime miniature
picker exclude accessories; automatic unit matching also excludes indexed scenery,
bases and parts. The raw catalog and all candidate relations are preserved.

An actual Godot run was also inspected using Computer Use. In **Models / Import**,
the local Workshop save was scanned and the exact search
`Primaris Intercessor - Bolt Rifle + GL` returned ten source occurrences. The first
displayed occurrence, GUID `90162d`, downloaded and converted successfully and the
preview reported **8 OBJ parts** and a **32 × 32 mm** visual base. The observed
yellow-armoured miniature is visible in the capture
`.tools/verification/model-equipment-final-20261106/live-gl-import-preview.png`.
The model is small in that preview, so this is evidence of a loaded assembly and
searchable label, not a detailed weapon/paint confirmation or live match weapon
switch. No unit mapping or saved match was overwritten, and the debug session was
stopped after inspection. Whole-library visual review and network validation
remain open.

## Necron C’tan shared rules — 31 October 2026

The four C’tan source profiles now map Necrodermis to the shared allocated-attack Damage resolver, reducing Damage by 1 to a minimum of 1. The Deceiver also maps its source-listed Stealth ability to the existing shared Stealth rule. The four ENSLAVED STAR GOD source rows prevent Warlord selection through direct choice submission and checked-roster sealing. The local App v1.2 export remains authoritative for datasheet facts. Wahapedia’s current Core Rules were checked only to resolve the allocation order around Devastating Wounds; those mortal wounds do not pass through the allocated attack Damage reduction. These shared abilities do not complete any C’tan datasheet; their unique abilities and roster checks remain pending.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_warriors_current --only test_capabilities --only test_current_unit_abilities --only test_attack_plan` passed **6/6 processes** at `.tools/verification/20261031T162828411100Z/results.json` (SHA-256 `204335C0D4FEFAF414BFBA0418D403CF5799142CFB0970F0C729B1D09203B6A6`; `network: false`, legacy starter staged, no cleanup diagnostics). The initial combined attempt also included `test_damage_allocation`; that run first exposed a case-sensitive capability-metadata assertion, corrected before the passing retry, and two allocation-selection assertions (“Wounded model becomes mandatory” and “Choose freely again after wounded model destroyed”) remained failing. Its report is `.tools/verification/20261031T162652951162Z/results.json` (SHA-256 `927899EBA8549DE0EDA0B968AE41A0E4D6B95F7D3220C01991F96810240D8CCC`). Those allocation-selection expectations are outside the scoped Necron rule checks and remain an observed failure.

The follow-up validation covering the Warlord restriction also passed **6/6 processes** with the same four focused suites at `.tools/verification/20261031T163810084862Z/results.json` (SHA-256 `9798D061D9BBFDFE9E4FEB071E7744DA1A50941A1B538D0F5178BF7532CDBAAE`; offline, legacy starter staged, no cleanup diagnostics). A separate broader selection including `test_roster_validation` is not green: that suite's setup expects a current Necron roster containing Immortals, which the local-validity policy correctly leaves construction-gated until implementation is complete. Report: `.tools/verification/20261031T163348637156Z/results.json` (SHA-256 `B091D187512B5699C069E87C01A1C84FBEBE88E09BF7C14D9587AD601EE81419`).

## Necron Canoptek Reanimator — 31 October 2026

Canoptek Reanimator (`000002112`) now has the complete source-bounded local datasheet scope: its one-model/75-point/6-wound profile, two Atomiser beams, Reanimator’s claws, Feel No Pain 4+, Reanimation Protocols and Nanoscarab Reanimation Beam. Reanimation checks include the 3-inch range, the Reanimator's own Aura, and two nearby sources applying the Aura only once. The local App v1.2 export is the source for the datasheet facts; the current Wahapedia 11e Core Rules section 22.01 was consulted only to resolve Aura repetition. At that point in the admission timeline, current Necron profiles remained outside construction pending shared admission checks.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_reanimation_protocols --only test_necron_warriors_current --only test_current_unit_abilities --only test_attached_reanimation --only test_capabilities` passed **7/7 processes** at `.tools/verification/20261031T162154272602Z/results.json` (SHA-256 `A229D99E8B2D6B2737A2DFFA340116BC372329F09E2F35192A7F37A3EC17E529`; `network: false`, legacy starter staged, no cleanup diagnostics). This completes the Reanimator's local datasheet rules scope only; it does not certify Necron construction, full army legality, network behavior or playtesting. See the [Necrons coverage ledger](../data/necrons-coverage.md).

## Razorback and Relic Razorback Warhammer Legends — 30 October 2026

Razorback (`000000129`) and Relic Razorback (`000002720`) now have source-bounded local profiles at 95 and 105 points per copy. Both include all source weapons and options, six-space Astartes Infantry transport restrictions, Deadly Demise D3, Combat Doctrines and Fire Support. Fire Support is tied to the enemy unit actually hit, the specific Razorback passengers disembarked from and the current turn. The copy-cap audit confirmed four copies per sheet in Incursion and six in Strike Force; the supported-copy metadata now matches that source-standard ceiling. A dedicated test passed with zero failures.

The connected offline verification passed **9/9 processes** at `.tools/verification/20261030T132109018867Z/results.json` (SHA-256 `47FF08129742A58BF9078F7736811681473FD6756C677BA41E488265F6086764`; `network: false`, legacy starter staged). It covers the dedicated sheets, the 184-profile consolidated catalog, copy-limit admission in both standard sizes and the connected transport weapon, rules and destruction regressions. Both models use labelled 120 mm circular hull proxies because the source says `Use model` without physical dimensions. The per-sheet [source/hash audit](../marine-razorback-legends-audit.json) records source CSV hashes, snapshot identity and limits. Live-page/event-pack checks, event approval, exact hull clearance, whole-army legality and human playtesting remain open.

## Mastodon Warhammer Legends — 30 October 2026

Mastodon (`000001189`, Space Marines Legends book `000000356`) now has a source-bounded local profile at 540 points with all seven source weapon profiles, both independent three-choice replacement groups, Combat Doctrines, Damaged 10, Deadly Demise 2D6, Inviolable Transport and its 45-space transport capacity. The focused test covers the threshold through a live AttackPlan, damage reduction, the common Deadly Demise resolver, Dreadnought identity capacity, the two-model limit and mixed 45-space capacity. The source says `Use model` without hull dimensions; exact physical placement is not certified. The current local game-mode policy labels Legends playable in casual settings and requires organiser approval for competitive events. See the [sheet audit](../marine-mastodon.md) and [machine-readable source/hash audit](../marine-mastodon-audit.json).

The focused verifier passed **17/17 processes** at `.tools/verification/20261030T124919082721Z/results.json` (SHA-256 `4D112555B3373FC911BEE04C7B47A795A07D5A4A7CDC3C3EF5A05BD7756720A1`; `network: false`, legacy starter staged, no cleanup diagnostics). The post-admission runtime export contains **182 profiles**, including Mastodon and zero missing source IDs, at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v16.json` (SHA-256 `E44796241979C35F6C9072039DCC46F026763D4AB60A2F2A745589FB5508505E`). Exact hull placement, live-page/event-pack validation, full army legality, network play and human playtesting remain outside this sheet-specific result.

## Scout Bike Squad Warhammer Legends — 30 October 2026

Scout Bike Squad (`000000137`, book `000000356`) now has a source-bounded local profile for 3/6 models at 75/150 points, all six price tiers, all 20 weapon profiles, the Sergeant pistol replacements, per-model Grenade Launcher, Scouts 9, Combat Doctrines and reserve-persistent Outflank. Its source base is a 75 × 25 mm oval; the runtime uses a labelled 75 mm bounding-circle proxy. Casual Legends construction is enabled locally; competitive events still require organiser permission. Exact physical clearance, event-specific restrictions, full army legality and live rules/event-page validation remain open.

The focused command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_scout_bike_squad_legends --only test_implemented_catalog --only test_space_marine_profile_source_fields --only test_space_marine_copy_cost_parity --only test_marine_category_copy_limits --only test_capabilities --only test_current_unit_abilities --only test_scout_squad --only test_attack_plan --only test_weapon_selection` passed **12/12 processes** at `.tools/verification/20261030T121229591371Z/results.json` (SHA-256 `5B886A29D83350B24362822FFDFDE952765EB6F63109D96C92DE73F61C8AD1ED`; `network: false`, legacy starter staged for declared fixture dependencies, no cleanup diagnostics). The dedicated direct Scout Bike suite also passed. The post-admission runtime identity export contains **181 profiles**, including 20 Space Marines Legends and zero missing source IDs, at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v15.json` (SHA-256 `59174C0FF9DE47FFF9B26D04CE3A4EA3A2D7E13802D8B2F9B51781AA9F42F9D9`). The exact 28-identity source slice has zero scoped structural findings; the machine-readable audit records the eight source CSV hashes and the focused report. See the [sheet audit](../marine-scout-bike-squad-legends.md) and [machine-readable source/hash audit](../marine-scout-bike-squad-legends-audit.json).

## Rhino Primaris Warhammer Legends — 30 October 2026

The local profile is reconciled to the verified Wahapedia 11e Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z` (updated `2026-10-28T23:48:19+03:00`). The exact Legends slice has zero scoped structural findings; parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and the Legends slice SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The machine-readable [sheet audit](../marine-rhino-primaris-audit.json) records the source row hashes and exact IDs.

The profile includes all source weapon modes and the optional One Shot Hunter-killer missile, 95-point first/second/third-copy tiers, the six-model Astartes Infantry transport limit and exclusions, Combat Doctrines, Deadly Demise D3, Self-repair and Orbital Comms Array. It deliberately does not inherit Firing Deck or Veiling Smoke from the ordinary Rhino. Construction allows two copies in Incursion and three in Strike Force under the current standard repetition gate. A labelled 120 mm circular footprint is a proxy because the source says `Use model` without a physical diameter.

The dedicated offline command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_rhino_primaris_legends` passed **3/3 processes** at `.tools/verification/20261030T112755484959Z/results.json` (SHA-256 `2A2B28E33FA38780770D8AD4FC257EE0EB7DEA631BD62ED245E8FBADB47FAD5`). The connected regression command, including the dedicated sheet, construction catalog, source fields, copy-cost parity, capability metadata, transport rules, weapon planning and One Shot flow, passed **18/18 processes** at `.tools/verification/20261030T113344527125Z/results.json` (SHA-256 `23BA149367E973E4E44016B9AD95F9D710F067E850F820C1F492F44BA50E95CA`; `network: false`, legacy starter staged, no cleanup diagnostics). The post-admission runtime export contains 180 identities and zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v14.json` (SHA-256 `6A9E24641B4951E6D348F3761CF2E4D6DC24128AB5F7E2A57E0483D9BD98B823`).

This is local source-bounded readiness for the supported rules flow. It does not certify the whole army, exact hull clearance, live network rules, event-pack restrictions or human playtesting. Legends units may be used in casual settings; competitive event use requires organiser permission. See the [support matrix](../project/support-matrix.md) and [datasheet audit](../marine-rhino-primaris.md).

## Three requested Space Marine datasheets — 30 October 2026

The latest local connected regression for the three linked sheets passed **15/15 processes** at `.tools/verification/20261030T102146906553Z/results.json` (SHA-256 `daa3134c46d55086618e0a01ec438cbd5e431470fef33759c66a01e2cbdd5cde`; `network: false`, legacy starter staged, no cleanup diagnostics). It includes the Decimus Kill Team, Wolf Guard Headtakers and Crusader Squad suites; Contact reachability, Fist of the God-Emperor, Vow-sworn enhancements/stratagems; catalog, source metadata, copy limits, capabilities, AttackPlan and current abilities.

This verifies the locally admitted choices and rules paths covered by those suites. It does not remove the known boundaries: Decimus's impossible five-model row and 210/190-point Wahapedia/MFM difference; Headtakers' unpriced role mixes and oval-base proxy; or Crusader Squad's bounded terrain-route and whole-formation coherency search. Full army legality, final network/event-pack checks and human playtesting remain open. See the [Decimus audit](../marine-decimus-kill-team.md), [Headtakers audit](../marine-wolf-guard-headtakers.md) and [Crusader Squad audit](../marine-crusader-squad.md).

## Venerable Dreadnought Warhammer Legends — 30 October 2026

The separate Legends Venerable Dreadnought (`000000120`, book `000000356`) is now source-bounded at 165 points, with its exact 60 mm base, 15 weapon rows/profiles, all 32 combinations across two independent equipment groups, Combat Doctrines, Deadly Demise 1, Wisdom of the Ancients and SMOKE. It remains separate from the Space Wolves Venerable Dreadnought (`000002801`). See the [sheet audit](../marine-venerable-dreadnought-legends.md) and [machine-readable source/hash audit](../marine-venerable-dreadnought-legends-audit.json).

The focused suite passed **3/3 processes** at `.tools/verification/20261030T101356327760Z/results.json` (SHA-256 `BD2ADEFD27FD649FBC82BCC3D0361D382AF4A0409EBC897FD120CB1DAC8725AE`; `network: false`, no legacy starter staged, no cleanup diagnostics). The connected catalog/ability/combat regression passed **14/14 processes** at `.tools/verification/20261030T101420116731Z/results.json` (SHA-256 `1BCB63A5924CE923B803656B0990D2869C0483524EB6C56C7308F60D9487FAF2`; `network: false`, legacy starter staged, no cleanup diagnostics). The runtime identity export contains **177 profiles**, includes the Legends identity and has zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v11.json` (SHA-256 `968283C5C46710C91172886BC5EF0CC19E53E83FB5A669CE4C9421C033EB8588`). Full army legality, final live-page/event-pack integration and human playtesting remain outside this sheet-specific result.

## Typhon Warhammer Legends — 30 October 2026

Typhon (`000000093`, Space Marines Legends book `000000356`) now has its source-bounded 320-point profile, all seven weapon profiles, 15 legal optional-loadout combinations, Damaged 6, Deadly Demise D6 and Sunderer of Fortresses. Its `Use model` footprint is represented by a labelled 60 mm circle proxy. See the [sheet audit](../marine-typhon.md) and [machine-readable source/hash audit](../marine-typhon-audit.json).

The focused rerun after removing debug output passed **3/3 processes** at `.tools/verification/20261030T095847866454Z/results.json` (SHA-256 `0267EE2BC11E027B91690F2EBC7B26B5AF0434709097AFAA23A4BAC2C76EFDFE`; `network: false`, no legacy starter staged, no cleanup diagnostics). The connected catalog/ability/combat regression passed **12/12 processes** at `.tools/verification/20261030T100032341278Z/results.json` (SHA-256 `FEA6375D208F9D5C0673405413F3548525CF06436A4189A3B3DE2F6E2375E51F`; `network: false`, legacy starter staged, no cleanup diagnostics). The current runtime identity export has 176 profiles, includes Typhon and has zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v10.json` (SHA-256 `F5C3C91F9170A0D33B1C5D868E3A057EBF47A8FCF2E37A87D8D670C440B86AFF`). Full army legality, live-page and event-pack validation, exact physical clearance, organiser acceptance and human playtesting remain outside this focused result.

### Dreadnought Legends — 30 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_dreadnought_legends --only test_cerberus --only test_attack_plan --only test_implemented_catalog --only test_space_marine_profile_source_fields --only test_marine_category_copy_limits --only test_capabilities --only test_combat_doctrines --only test_current_unit_abilities --only test_ballistus_dreadnought --only test_redemptor_dreadnought --only test_brutalis_dreadnought --only test_space_wolves_walkers --only test_ironclad_champions --only test_vindicator --only test_stormhawk_interceptor --only test_stormtalon_gunship --only test_rapier_carrier` passed **20/20 processes** at `.tools/verification/20261030T093959828822Z/results.json` (SHA-256 `2CF0774EE62B33D9B5209AE00F5C2A213FCB4A5E2C482F683682700B2EFBE2F5`; `network: false`, legacy starter staged, no cleanup diagnostics). After adding the source keyword SMOKE, the expanded standalone `test_dreadnought_legends` passed 3/3 processes at `.tools/verification/20261030T094342691431Z/results.json` (SHA-256 `41FD7232A9ABF0E9DE1B4017F4AF6F0FB7E78E0F070F8574817131B36B378E3`). The updated identity export contains 175 runtime profiles, includes the Dreadnought SMOKE keyword and has no missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v9.json` (SHA-256 `CE84F29A7AADD431D140BFEAF7F8048027298F43232E4AB8B9A7BDC1EED18DAA`). This closes only the source-bounded Dreadnought Legends sheet scope; it does not establish full army legality, live-page/event-price validation, organiser acceptance or human playtesting.

### Cerberus Warhammer Legends local sheet scope — 30 October 2026

Cerberus (`000001153`, Space Marines Legends book `000000356`) now has its one-model 270-point profile, all source-listed ranged weapon profiles and both independent optional equipment groups. Atomantic Arc-reactor grants Lethal Hits only to the Neutron Pulse Array when the unit remained stationary this turn; the regression checks movement/setup suppression and confirms optional weapons do not inherit it. Combat Doctrines and Deadly Demise D6 enter the shared local ability flow. The source footprint is `Use model`; match geometry displays a labelled 60 mm circular proxy. The profile is labelled Warhammer Legends for casual use, with organiser permission required for competitive events. See the [sheet audit](../marine-cerberus.md) and [machine-readable source/hash audit](../marine-cerberus-audit.json).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_cerberus --only test_attack_plan --only test_implemented_catalog --only test_space_marine_profile_source_fields --only test_marine_category_copy_limits --only test_capabilities --only test_combat_doctrines --only test_current_unit_abilities --only test_stormhawk_interceptor --only test_stormtalon_gunship --only test_rapier_carrier --only test_vindicator` passed **14/14 processes** at `.tools/verification/20261030T091339075999Z/results.json` (SHA-256 `d2755e880b3bd32d37ee4ea8b1e7ab62410327df27ccedf83b75b192463f382c`; `network: false`, legacy starter staged by the verifier, no cleanup diagnostics). At this earlier checkpoint, the identity export recorded 174 profiles and no missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v7.json` (SHA-256 `761b2c1be8b5275eb16d9fdaaa2c57c729b8660f83b0d0da56d2236fef1c4c741`). The parent export still has unrelated structural findings. This local sheet result does not certify full army legality, exact physical clearance, live-page or current event-pack price equality, competitive organiser acceptance, network behavior or human playtesting.

### Stormtalon Gunship Legends sheet admission — 30 October 2026

Stormtalon Gunship (`000001190`, Space Marines Legends book `000000356`) now has its 165-point Aircraft profile, all source-listed weapons and all three Skyhammer replacements. Its focused test checks source metadata, stats, exact weapon rules, construction pricing, replacement/restoration actions, mandatory reserves placement and Strafing Run against FLY, non-FLY and melee targets. The 120 × 92 mm oval is represented by a labelled 60 mm bounding-circle proxy. The profile is tagged as Warhammer Legends; competitive events require organiser approval. See the [sheet audit](../marine-stormtalon-gunship.md) and [machine-readable source/hash audit](../marine-stormtalon-gunship-audit.json).

The focused regression and catalog integration command passed **10/10 processes** at `.tools/verification/20261030T084944412603Z/results.json` (SHA-256 `2db87ad663a3133d03523ab7e9e53b7d3a1a7289f5d0358793ff7536a53a140f`; `network: false`, legacy starter staged by the verifier, no cleanup diagnostics). Selected checks were Stormtalon, Stormhawk, Nephilim, implemented catalog, source metadata, copy limits, capabilities and current-unit abilities, plus import and Python checks. The runtime identity export at that earlier checkpoint recorded 173 profiles with no missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v6.json` (SHA-256 `fc9049e66855fbb33e0f44bbb0b67fb6e1007c64f8acb2c638b7c8e42fe9021d`). This does not certify full army legality, current live-page or event-pack points, exact physical base clearance, profile-specific Deadly Demise trigger/chain cases, tournament permission or human playtesting.

After the Stormtalon test added direct `AttackPlan` modifier assertions, rejection of off-sheet weapon replacements and the organiser-approval readiness label, its clean focused rerun passed **3/3 processes** at `.tools/verification/20261030T085923444727Z/results.json` (SHA-256 `560c810fa3aee065e6670c31f352dc4ef509228d87af51bc79f71ef761bd25f4`; `network: false`, no legacy starter staged, no cleanup diagnostics).

The additional shared regression command `python tools/verify.py --profile targeted --only test_stormtalon_gunship --only test_stormhawk_interceptor --only test_nephilim_jetfighter --only test_attack_plan --only test_attack_sequence --only test_core_reactions --only test_vindicator --only test_damage_allocation --only test_current_unit_abilities --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe'` passed **10/11 processes** at `.tools/verification/20261030T085606152964Z/results.json` (SHA-256 `2dd3ab61e85a1fa52f181588eb28a875a5c0d7de07506ab1c4045ab56060d347`; `network: false`, legacy starter staged, no cleanup diagnostics). Eight selected suites plus import/Python checks passed; `test_damage_allocation` failed its two wounded-model-priority assertions (`Wounded model becomes mandatory` and `Choose freely again after wounded model destroyed`). That suite covers a separate damage-allocation path and its allocation implementation was not changed for Stormtalon; the failure is retained as an open regression rather than counted as Stormtalon evidence.

### Stormhawk Interceptor Legends sheet admission — 30 October 2026

Stormhawk Interceptor (`000000084`, Space Marines Legends book `000000356`) now has its 155-point Aircraft profile, all source-listed weapons and replacements, mandatory Aircraft reserves handling, Deadly Demise D3 and the Interceptor +1-to-hit rule against FLY targets. Its 120 × 92 mm oval is recorded as a labelled 60 mm bounding-circle proxy; exact physical clearance is outside the result. See the [sheet audit](../marine-stormhawk-interceptor.md) and [machine-readable source/hash audit](../marine-stormhawk-interceptor-audit.json).

The focused command `python tools/verify.py --profile targeted --only test_stormhawk_interceptor --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe'` passed **3/3 processes** at `.tools/verification/20261030T083724270725Z/results.json` (SHA-256 `80f71a55103e1740ae185a6348b06f9ef2f32d55314bc228a289f3c0af9d6fec`; `network: false`). The refreshed runtime identity export contains 172 profiles with no missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v5.json` (SHA-256 `4da4709e80fbe7c6c60f775dcf7527b5a13dbdc5e8c61fd30bb49e3a5edc34f3`). This sheet result does not certify full army legality, current live-page or event-pack equality, competitive organiser acceptance, exact base clearance or human playtesting.

### Whirlwind Legends sheet admission — 30 October 2026

Whirlwind (`000002727`, Space Marines Legends book `000000356`) now has a source-bounded local profile with 175 first-copy/195 later-copy pricing, both optional weapons, Indirect Fire, Blast 2, and Punishing Bombardment's Vengeance Launcher hit gate and Battle-shock flow. The 60 mm footprint remains an explicit proxy because the export says “Use model.” Legends is available for home, store, club and campaign play; competitive events require organiser permission. See the [sheet audit](../marine-whirlwind.md) and [machine-readable source/hash audit](../marine-whirlwind-audit.json).

The first integration run exposed a target-selection defect shared by engaged vehicle shooting: a VEHICLE shooter could attack an engaged Infantry unit that was engaged with a different friendly unit. AttackPlan now rejects that target while retaining the current-Shooting-phase §17.03 exception for engaged enemy MONSTER/VEHICLE units. The final focused rerun `python tools/verify.py --profile targeted --only test_whirlwind_legends --only test_predator_destructor_legends --only test_predator_annihilator_legends --only test_vindicator --only test_vehicle_shooting --only test_attack_plan --only test_implemented_catalog --only test_marine_category_copy_limits --only test_space_marine_profile_source_fields --only test_capabilities --only test_current_unit_abilities --only test_core_reactions --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 900` passed **14/14 processes** at `.tools/verification/20261030T081744025098Z/results.json` (SHA-256 `86be5e11bd7d9fa6e306c4a363352a044b63511ba04008ed6fdb7b912409ad71`; `network: false`, legacy starter staged, no cleanup diagnostics). The refreshed identity export records 171 profiles with no missing source metadata at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v4.json` (SHA-256 `150a2d21627f34b9d76a2376ff46d54c81bf2dbef9bb970dc5fa8f177c577f74`). The slice has zero scoped findings; 68 unrelated parent-export findings remain. This local sheet and regression evidence do not certify every roster combination, full army legality, live-page equality, event-pack points, tournament permission, exact base clearance or human playtesting.

An optional broader smoke attempt at `.tools/verification/20261030T081436429430Z/results.json` failed three suites outside this sheet: `test_morale_coherency` reached an aircraft-turn handler without a `reserves` field, `test_combat_scenario` reached Stasis Bomb phase-close without `unit_abilities`, and `test_unit_choice_help_ui` reached a UI fixture without `units`. `test_whirlwind_legends`, `test_current_unit_abilities` and `test_core_reactions` passed in that run; the three unrelated failures are not counted as Whirlwind validation and remain open.

After updating the capability registry to mark §17.03's tested local boundary accurately, a final focused check of Whirlwind, vehicle shooting and capability metadata passed **5/5 processes** at `.tools/verification/20261030T082117851521Z/results.json` (SHA-256 `0a5ff036fab578008413ef66bc583b3c1469320bdcfd5e68785deb7a3b58f70d`; `network: false`).

### Centurion Devastator Squad source-bounded Legends admission — 30 October 2026

Centurion Devastator Squad (`000001193`, Space Marines Legends book `000000356`, 11e) is admitted at its source-priced 3-model/175-point and 6-model/350-point sizes. The local sheet includes the source's one-Sergeant minimum, exact 50 mm base, all per-model ranged replacements and Decimator Protocols, with event-use labeling. The local Legends-slice checker validated the hash-verified Data Export slice with zero scoped findings; its 56-subject count includes linked source dependencies. The parent export's 68 unrelated structural findings remain open.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_centurion_devastator_squad --only test_implemented_catalog --only test_attack_plan --only test_core_reactions --only test_combat_doctrines --only test_space_marine_profile_source_fields --only test_capabilities --only test_marine_category_copy_limits` passed **10/10 processes** (eight Godot suites plus import and Python checks) at `.tools/verification/20261030T060308657963Z/results.json` (SHA-256 `1f6798207eddc66265bc5b24b3c07fd5602da05ddc3cfd053252c6d2a94606cc`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The selected suites verify every admitted Marine source binding, all 165 current construction-profile copy limits, all Centurion weapon choices and the Decimator objective/Overwatch/Indirect/melee boundaries. This is local source-bounded scope evidence; full army legality, network validation and human playtesting remain open. See the [Centurion datasheet audit](../marine-centurion-devastator-squad.md) and its [machine-readable source/hash audit](../marine-centurion-devastator-squad-audit.json).

### Space Marine all-profile provenance and 138-suite local check — 30 October 2026

The latest verified Wahapedia 11e export is snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, updated `2026-10-28T23:48:19+03:00`. Its parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`; all 22 CSV hashes matched. Six current source-book slices cover all 161 runtime identities and each slice has zero structural findings. Every runtime profile now records the current verification snapshot, parent hash, source-book slice hash and export update time without rewriting historical import metadata. The parent export remains structurally invalid with 68 global findings; this is not reported as a successful global validation.

`tools/compare_wahapedia_marines.py` compared all 161 profiles against that export: zero numeric/identity differences, all 161 source identity bindings consistent, all 763 ability relation IDs resolved, and all 161 selectable cost schedules exact. The latest role-aware strict fixed-data gate is 161/161: Headtakers' duplicate six-model costs now map to the official MFM role rows, while only its compatible 3+3 and 6+6 mixes are selectable; other source-permitted mixes remain unpriced and blocked. `tools/validate_space_marine_roster_costs.py` independently matched 161/161 runtime profiles and catalog choices across 576 cost rows. `tools/validate_space_marine_chapter_links.ps1` matched 363/363 Leader relations, 14/14 static Support identities, the conditional Support profile and all 161 runtime identities.

The offline rerun replayed the 138 suite names saved in the preceding verification report through `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 300` with one `--only` argument per saved suite; the exact selection is embedded in the new results file. It passed **140/140 processes** (138 Godot suites plus import and Python checks) at `.tools/verification/20261030T040229977346Z/results.json` (SHA-256 `5a2e39f1702cb4a4d9641fd6e6d0a03aa755bb8ff85905122c4846ff06feac69`; `network: false`, `legacy_starter_staged: true`). The batch covers the three newly corrected partial sheets, profiles, current catalog admission, copy limits by Incursion/Strike Force, Leader/Support links, weapons and transport interactions. Passing local checks does not establish that every rule is implemented or that a complete army is legal.

The current e11 pages for [Decimus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team), [Wolf Guard Headtakers](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Headtakers) and [Crusader Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Crusader-Squad) were inspected on 30 October. Decimus lists a 5-model price, but its composition requires the Xenophase Veteran, Sergeant and at least one model from each of four other roles (six models minimum), so the 5-model choice is withheld. Headtakers' duplicate six-model rows are mapped to official MFM role prices; only Wahapedia-compatible, explicitly priced 3+3 and 6+6 mixes are selectable, while other permitted but unpriced mixes stay blocked. Crusader Squad remains partial because Surge route candidates and whole-squad coherency search are bounded. No source conflict has been papered over to mark an option legal.

The all-profile export comparison was repeated on 30 October using the current runtime exporter and the same verified snapshot. At that checkpoint it found **0/161** numeric/model/weapon/source-identity differences, **0/161** ability-resolution issue profiles and **0** weapon-trait mismatches; strict fixed-data scope was **159/161** before the legal Decimus and role-aware Headtakers cost reconciliations below. The ignored comparison artifact is `.tools/marine-comparison-readiness-20261030.json` (SHA-256 `8e1f0a6d2931d43ebeb8d60bf44cfc12e3e018a01e724b1965f40e5f4f3fe2c`). The parent export's 68 structural findings remain, so this is not a global source certification.

After aligning capability metadata so all three known exceptions are explicitly marked `source_bounded_local_scope_partial_2026_10_30`, the focused regression command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_implemented_catalog --only test_decimus_kill_team --only test_wolf_guard_headtakers --only test_crusader_squad --only test_fist_god_emperor --only test_contact_reachability --only test_capabilities --timeout 300` passed **9/9 processes** at `.tools/verification/20261030T032726422374Z/results.json` (SHA-256 `fd9698228b2c8d05055ab285115903fc5ac2f1dec385390083acf13f1513e58d`; `network: false`, legacy starter staged, no cleanup diagnostics). The tests preserve selectable legal/priced configurations while asserting that the bounded or conflicting parts remain disclosed.

### Decimus legal-configuration completion — 30 October 2026

Decimus now stores only the legal ten-model role composition as a runtime choice and defaults to its source-compatible 210-point configuration. The raw 5/10 model cost rows remain available as provenance, but army construction explicitly blocks the five-model row because the six mandatory roles require at least six models. The capability registry now marks this legal scope complete; Crusader Squad and Headtakers remain the two partial scopes.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --only test_implemented_catalog --only test_capabilities --only test_marine_category_copy_limits --timeout 300` passed **6/6 processes** at `.tools/verification/20261030T035057105186Z/results.json` (SHA-256 `6d218a73e93b176125f5e110e07467f6026f6a428e8dc6d40dab3001e93c813f`; `network: false`). A fresh export of all 161 runtime profiles and a comparison against the same hash-verified snapshot reported zero numeric or source-identity differences. At this checkpoint, before the later role-aware Headtakers comparison below, the strict fixed-data gate was **160/161**; Decimus composition and price checks were consistent, and the duplicate Headtakers six-model rows were the sole remaining comparison issue. The runtime export hash is `5e90cb22444b419f166c8328a7cfc5ae16f2bd2da2ce3e161e64119926b9ba96`; comparison hash is `526b71fbb60e0f3400655e731770b15bdd8b4aca1a1003e4589a1bcbd5e747ab`. The export parent retains 68 unrelated global validation findings. This confirms the bounded local Decimus profile, not complete army legality or event-specific approval.

### Headtakers role-aware price reconciliation — 30 October 2026

The Wahapedia export expresses four Headtakers price rows by total model count, with two conflicting rows at six models. The runtime preserves the official MFM role mapping and marks only the 3+3 and 6+6 rows compatible with Wahapedia's minimum composition. The comparator now checks the multiset of all source prices against that mapping and compares construction prices only for compatible, explicitly priced compositions. This preserves the 3/6-model Headtakers-only MFM rows as blocked evidence and leaves other permitted but unpriced role mixes unavailable.

`python -m unittest tests.test_wahapedia_fixed_checks` passed **29/29 tests**. The focused command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_wolf_guard_headtakers --only test_crusader_squad --only test_fist_god_emperor --only test_contact_reachability --only test_implemented_catalog --only test_capabilities --only test_decimus_kill_team --timeout 300` passed **9/9 processes** at `.tools/verification/20261030T035752327644Z/results.json` (SHA-256 `467535c10b9f27f1fcfa99407abdf9a4f2470923e41ebb1820ba5a7c967f9768`; `network: false`, legacy starter staged, no cleanup diagnostics). The specific role-price regression passed as part of the 29-test suite. The fresh 161-profile export/comparison reports zero numeric or source-identity differences and **161/161 role-aware strict fixed-data profiles consistent**. Headtakers' selectable cost schedule is 6/115 and 12/230 points for the first two copies, then 6/125 and 12/240 for the third copy. The ignored runtime export is `.tools/marine-runtime-rolemapped-headtakers-20261030.json`; comparison artifact `.tools/marine-comparison-rolemapped-headtakers-20261030.json` has SHA-256 `f76429c0f3e39fdbdfa52f2ea2ac4d83d6a509a344ea67c1545dba68f9449aea`. The parent Data Export still has 68 global structural findings, Headtakers' unpriced role mixes and oval-base proxy remain disclosed, and Crusader Squad's Surge movement search remains bounded. This audit does not certify full army legality or event approval.

### Space Marine source and roster readiness — 29 October 2026

The current offline exporter produced **161/161** standard Space Marine profiles from the runtime. Against the timestamp-bracketed Wahapedia 11e export updated `2026-10-28T23:48:19+03:00`, source identities and numeric profile data match **161/161**; the strict fixed-data gate passes **159/161**. Decimus Kill Team and Wolf Guard Headtakers remain the two explicit composition/cost blockers, and the construction catalog withholds the affected choices. The separate price audit matched **161/161** runtime schedules and construction choices. The export's 22 files passed manifest SHA-256 checks, but its parent data remains structurally invalid with **68 global findings**.

`tools/validate_space_marine_chapter_links.ps1` matched all **363/363** source Leader relations, **14/14** static Support identities, and **161/161** runtime/source identities against the same hash-verified snapshot. The targeted offline verification command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --only test_wolf_guard_headtakers --only test_decimus_kill_team --timeout 300` passed **5/5 processes** at `.tools/verification/20261030T000144180807Z/results.json` (SHA-256 `089B121F02CD0E0EA962224950117D09EC86363216435F9EF780EA8109E418CE`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks repeat limits for all 161 profiles in Incursion and Strike Force, Chapter tags for all 76 Chapter-book profiles, and the selected legal/blocked compositions for both partial sheets. These are bounded local data and admission results; general army legality, complete rules implementation, final network/page validation and playtesting remain open.
### Wolf Guard Headtakers full MFM composition-cost rows in runtime metadata — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_wolf_guard_headtakers --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T214027644989Z/results.json` (SHA-256 `12FF611601AE39A51319B5EF4BB3C02250A5B2DC8CD56D52017C8AC00F6CE838`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The runtime profile now preserves all four exact MFM role compositions and both copy tiers in `mfm_composition_cost_rows`; the regression verifies the 3+3 and 6+6 rows remain the only selectable configurations while the priced Headtakers-only rows stay blocked by the selected Wahapedia minimum composition.

### Exact origin-to-goal access-zone contacts for Crusader Surge — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T213327544692Z/results.json` (SHA-256 `A2EC21F234767A56A9CD13D43851664D39D45B25E18B9B81482983BB5AB0E88D`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The regression confirms that both direct and composed cross-surface access queries include exact entry/exit points from the mover-to-destination segment, without relying on portal-edge subdivisions or endpoint projections. Route segments remain validated by the shared movement geometry; arbitrary multisegment routes and whole-formation coherency remain bounded.

### Wolf Guard Headtakers source-bounded partial integration — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_wolf_guard_headtakers --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T205351478176Z/results.json` (SHA-256 `B6E0015006EB21E0B0A56AEE96413B444F971FD8F10EDE582E90CEBA6DBBF476`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the MFM-mapped compatible 6/12-model mixed compositions, blocks the incompatible Headtakers-only rows, exercises all six public Leader attachments, verifies the pre-battle split and independent quarry choices, tests quarry-specific attack traits and replacement selection, and covers role-specific stats/weapons, Storm Shield and Hunting Hounds.

The connected regression passed **7/7 processes** at `.tools/verification/20261029T205134675733Z/results.json` (SHA-256 `991D3C5A5DFB6A60F00350D5E527F33CF1FF48D3B25AC4369CD40E00A76A22BA`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It also covers Wolf Scouts, Fenrisian Wolves, Watch Master and the Space Marine Leader-link map. Both runs are offline evidence; they do not establish final network/page validation, exact oval-base geometry, full army legality or human playtesting.

### Full Space Marine runtime-profile source comparison before Headtakers integration — 29 October 2026

`python -m unittest discover -s tests -p test_wahapedia_import.py` passed **16/16 tests**, including new checks for expanded runtime model-role matching and Torrent auto-hit comparison. The offline Godot exporter command `& .\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_reference_marines.gd -- --output .tools/marine-runtime-final-all2-20261029.json` exported **160 runtime profiles**, 93 with manually enriched option profiles. `python tools/compare_wahapedia_marines.py --snapshot .tools/wahapedia-e11-final-marine-catalog-20261029 --runtime-profiles .tools/marine-runtime-final-all2-20261029.json --output .tools/marine-compare-final-all2-20261029.json` reported **zero numeric or runtime-source-identity differences across 160 profiles**; **122/160** passed that checkpoint's bounded fixed-data checks. The source export was hash-verified across 22 files but structurally invalid with 68 global findings. This historical checkpoint did not certify every role-specific default loadout, weapon trait, composition, optional wargear price, army legality or ability interaction. Runtime export SHA-256: `989328F14A19FD45EC3CC1BEFFE734BBA211DFFF5EA3296883BAD4753D93A886`; comparison report SHA-256: `D005E61533271B4E7B24DB2214E89E61131939407741B7E1E0DC1B47681E7A3F`.

### Marine profile audit reconciliation before Headtakers integration — 29 October 2026

`& .\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_reference_marines.gd -- --output .tools/marine-runtime-marine-closeout-20261029.json` exported **160 profiles** (93 with manually enriched option profiles). `python tools/compare_wahapedia_marines.py --snapshot .tools/wahapedia-e11-final-marine-catalog-20261029 --runtime-profiles .tools/marine-runtime-marine-closeout-20261029.json --output .tools/marine-compare-marine-closeout-20261029.json` reported **zero numeric or runtime-source-identity differences** and **159/160** passes for the bounded fixed-data gate. Weapon traits, default equipment, keyword context, unit costs and optional wargear costs each pass for all 160 profiles. The only open comparison is Decimus Kill Team: source role minima total six, against a five-model runtime interpretation. The source manifest confirms 68 global structural findings, so this is not all-catalogue certification. Runtime export SHA-256: `c42eb732b4018cc0594574ca8caba9b7af59ee805c2e438a3dbc8e469194c336`; comparison SHA-256: `3287ac36b147f52ed44a865f4290332176575eeb8232313ba63b44d99dabe9dc`.

`python -m unittest discover -s tests -p test_wahapedia_fixed_checks.py` passed **28/28 tests** and `python -m unittest discover -s tests -p test_wahapedia_import.py` passed **17/17 tests**. The focused Godot command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_deathwatch_veterans --only test_wolf_guard_terminators --only test_thunderwolf_cavalry --only test_sammael --only test_wolf_scouts --only test_roster_validation --timeout 300` passed **8/8 processes** at `.tools/verification/20261029T120901761505Z/results.json` (SHA-256 `fcc54ace0cce7e38a21f2ebc7ae0553aa65af4eb057811bd7356143d60c04a56`; `network: false`, legacy starter staged, no cleanup diagnostics). It verifies the corrected Damnatus/Purgatus trait split, both Storm Shield costs, Sammael's runtime-only `MOBILE` tag, Wolf Scouts' restricted Instigator profile, roster validation and the audit helpers.

### Marine Chapter mixed-roster coverage — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T121947338596Z/results.json` (SHA-256 `4EC416ABE301E2FA6BDCFB17EBEEA46B9264994B254E1EC3A8068E69C1C98CA6`; `network: false`, legacy starter staged, no cleanup diagnostics). The actual-admission matrix pairs each of the 75 Chapter profiles with a same-keyword profile, checks a cross-Chapter rejection involving each profile, and covers all 42 directed pairings among the seven Chapter keywords represented in the catalog. The test uses 156 mixed-pair admissions, down from 375 in its first passing draft; this keeps per-profile and per-keyword-pair coverage while reducing the focused test process from 51.32 to 17.51 seconds. Multi-unit copy-limit combinations, Support assignment combinations, and full army legality remain open.


The next copy-limit increment passed **3/3 processes** at `.tools/verification/20261029T122751101952Z/results.json` (SHA-256 `133A3AD872B947E0BB646610CB6D6D451C25067DEF5862224992EA7B17935116`; `network: false`, legacy starter staged, no cleanup diagnostics). The suite now admits all 160 profiles at both their Incursion and Strike Force repeat limits, rejects one extra copy in each category, and checks split Strike Force configurations for at least 30 eligible profiles. It retains the full 75-profile/42-pair Chapter matrix. The focused test process took 26.07 seconds. Broader combined-roster interactions and full army legality remain open.

### Combined Space Marine copy-cap roster — 29 October 2026

Command: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300. It passed **3/3 processes** at .tools/verification/20261029T125540251757Z/results.json (SHA-256 C472B91FB6342BBB03CA38F0CA7D9515BD4991B17E6DACBD6DDBB0598A7DD03F; network: false, legacy starter staged, no cleanup diagnostics; test process 26.56 seconds).

The test admits one 2,000-point Strike Force with six Intercessors, six Rhinos, three Sternguard units and Roboute Guilliman at each datasheet's individual cap. Raising each profile above its cap in turn is rejected by that profile's repeat/Epic Hero gate while the other entries remain in the list. The same run also admits an Incursion roster with a Crusader Squad and three shared-book profiles. These cases check two combined shapes, not general army legality or every multi-unit interaction.

### Space Marine Support roster matching — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_marine_leader_links --only test_roster_validation --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T122351421740Z/results.json` (SHA-256 `25D22448793C422E0640528C27156158E04738A040DE1B3DA1A64CE98367C5A9`; `network: false`, legacy starter staged, no cleanup diagnostics). The matcher now covers all 97 static Support/bodyguard pairs and each pairwise overlap on a single bodyguard; actual checked Incursion admission covers all 14 static Support identities and representative valid reassignment, Apothecary/Lieutenant sharing, collision, third-Support and conditional Cato/Calgar/Victrix cases. This does not exhaust every multi-unit roster or certify full army legality.

### Space Marine route, roster and source-identity follow-up — 29 October 2026

The focused local command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_marine_detachment_roster_admission --only test_marine_category_copy_limits --only test_space_marine_copy_cost_parity --only test_space_marine_leader_links --timeout 300` passed **9/9 processes** at `.tools/verification/20261029T103849012064Z/results.json` (SHA-256 `A5337D82395E789788BFD9E200B1D6DB1B92BBD45FDAB81E8211524CD160A932`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Crusader/Fist route and objective regressions, Chapter/detachment admission, local copy limits and costs, and every mapped runtime Leader/Support relation. These are bounded offline checks; they do not prove exhaustive roster legality, network behavior or playtesting.

At this earlier checkpoint, the verified Chapter export audit found **76 source sheets, 75 runtime profiles and one missing profile**; the source/relation validator separately passed **22/22 manifest hashes, 363/363 attachment relations across 161 identities and 14/14 static Support profiles**. At that checkpoint, Wolf Guard Headtakers was the missing identity and its duplicate six-model rows lacked a model mapping; the later MFM mapping and partial runtime integration are recorded above. Crusader Squad remains partial while route/coherency edge cases are unresolved.

### Full Space Marine Leader/Support relation audit — 29 October 2026

`pwsh -NoProfile -ExecutionPolicy Bypass -File tools/validate_space_marine_chapter_links.ps1` passed against `wahapedia-e11-live-refresh-20261029T072022Z-final-integration`: **22/22 manifest hashes**, **363/363 standard Leader/Support edges across 161 source identities**, and **14/14 source-marked static Support identities**. The validator exports identities from the current runtime catalog, joins them to the hash-verified local Data Export, and preserved Wolf Guard Headtakers as the sole source-only identity at that audit checkpoint; the later 29 October follow-up added its partial mixed-profile runtime integration. Cato Sicarius remains conditional on Marneus Calgar. Legends targets stay outside the standard relation map.

The focused runtime command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_marine_leader_links --only test_ancients --only test_castellan --only test_apothecary --only test_marine_lieutenant --only test_judiciar --only test_phobos_lieutenant --timeout 300` passed **9/9 processes** at `.tools/verification/20261029T102751146530Z/results.json` (SHA-256 `30C57E528C50AA8074873415F3C4AAAF9B7CD734319D6782EC1AAAAD1EA36CCA`; `network: false`, no legacy starter staged, no cleanup diagnostics). It checks every mapped relation and declared attachment role, all fourteen current-catalog Apothecary bodyguards, the corrected Castellan Support classification, and the Ancient, Lieutenant, Judiciar and Phobos attachment scopes. These checks do not certify every roster combination, full army legality, network behavior or playtesting.

### Common Space Marines Leader-link source audit — 29 October 2026

`pwsh -NoProfile -ExecutionPolicy Bypass -File tools/validate_space_marine_leader_links.ps1` passed against snapshot `20261021T130623Z`: **23/23 manifest hashes**, **85/85 common-book identities** matched source ID, name, faction and book, and **153/153 in-scope Leader links** matched across 37 datasheets. The identity map is pinned to 19 October; the selected export is dated 21 October, so the script explicitly rechecks every mapped identity against that newer export before comparing relations. The run is local and offline. It does not certify cross-book BODYGUARD/Support mappings or exhaustive attachment legality.

### Vow-sworn enhancement and stratagem effect checks — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vow_sworn_stratagems --only test_vow_sworn_enhancements --only test_templar_vows --only test_fist_force_dispositions --only test_marine_detachment_roster_admission --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **11/11 processes** at `.tools/verification/20261029T095653298940Z/results.json` (SHA-256 `FB377EA169B1CF8F2BBF5FA8C9317AF7DF7BE648D11C9C01B0528E502F98D51C`; `network: false`, legacy starter staged, no cleanup diagnostics).

The two new focused suites check the four enhancement costs and sampled source eligibility/effects, all six Vow-sworn stratagem effects in selected local contexts, and Heresy Begets Retribution's triggered D6 move to a legal endpoint. The batch also passes Templar Vows, Force Disposition setup, Chapter admission, Crusader/Fist route and squad cases, and capability metadata. It does not exercise full public saved attack continuations for Pious Enmity, For the Emperor's Honour! and Spoor of the Unholy, the saved Charge continuation/Leadership reroll branch for Dread Crusaders, Zealous Vanguard's Strategic Reserves set-up, all eligible enhancement bearers, network rules validation, complete army legality or human playtesting.

### Vow-sworn enhancement checks — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vow_sworn_enhancements --only test_templar_vows --only test_fist_force_dispositions --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T094844825000Z/results.json` (SHA-256 `525433BA06BC2416EE9CBA4A291E04E1DD0ABF00849A943BD5EDA0D99B0FA4A5`; `network: false`, legacy starter staged, no cleanup diagnostics).

The new `test_vow_sworn_enhancements` suite checks local admission costs and an ineligible bearer, Consecrating Aura's granted 5+ and preserved better melee save, Incendiary Animus's +1 melee Strength through AttackPlan, Zealous Vanguard's entry into the shared pre-battle Scout flow, and Augury Servo-host's visible target selection, cover denial through AttackPlan, one-use limit and Shooting-phase expiry through a public unit command. The run also passes the core Vow, direct Force Disposition and capability suites. Zealous Vanguard's Strategic Reserves setup path, the six Vow-sworn stratagems, network rules validation, complete army legality and human playtesting remain open.

### Crusader Squad direct-route shortcut and A* visibility search — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_fist_force_dispositions --only test_capabilities --timeout 300` passed **7/7 processes** at `.tools/verification/20261029T094236500773Z/results.json` (SHA-256 `55C21D1C3523C4E036204AAD2293245264577F06507A1CFB9D98EF7A5CE64AAE`; `network: false`, legacy starter staged, no cleanup diagnostics).

The relaxed-route proof returns the exact straight-line lower bound without constructing the graph when the nearest goal-box point is visible. For obstructed routes, A* uses distance to the goal region as a consistent heuristic over the same obstacle visibility graph; an exact rectangular-detour regression preserves its shortest-path result. This does not make finite waypoints or formation placement exhaustive. The run recorded 4.33 seconds for `test_contact_reachability` and 6.44 seconds for `test_fist_god_emperor`, compared with 4.63 and 6.44 seconds in the prior run. These are single-run test timings, not a benchmark or confirmed performance gain. The 1,024-box cap and partial coherent-placement scope remain.

After the route capability wording was updated, `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T094421828206Z/results.json` (SHA-256 `AB6837EA9882CE481762DC6EC3BADAFF9132BED5191F2CE0DFF268F5314E59B4`; `network: false`, no cleanup diagnostics).

### Crusader Squad visible-route lower-bound shortcut — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_fist_force_dispositions --only test_capabilities --timeout 300` passed **7/7 processes** at `.tools/verification/20261029T093941179319Z/results.json` (SHA-256 `BEBD38B3B45B5B1D8DFF91024448CAED6CFF027196C31EB8D2E1511C4A392D29`; `network: false`, legacy starter staged, no cleanup diagnostics).

When the nearest point in the goal box is visible in the relaxed obstacle geometry, the reachability proof now returns that exact Euclidean lower bound before building the obstacle visibility graph. This is safe because no route can be shorter than the straight segment. The run recorded 4.63 seconds for `test_contact_reachability` and 6.44 seconds for `test_fist_god_emperor`, versus 5.94 and 6.75 seconds in the previous comparable run. This is a single-run comparison, not a benchmark. The 1,024-box cap, finite waypoints and partial coherent-placement scope remain.

### Vow-sworn Crusaders Purge the Foe direct-mode integration — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_force_dispositions --only test_marine_detachment_roster_admission --only test_capabilities --timeout 300` passed **5/5 processes** (import, Python checks and three Godot suites) at `.tools/verification/20261029T093740730871Z/results.json` (SHA-256 `37AAF5CACB9108F5FF70E2145AD32A31147824317293D50B846F9A9EF61E004A`; `network: false`, legacy starter staged, no cleanup diagnostics).

The regression covers the checked Vow-sworn roster record (2 DP, Purge the Foe only), direct Force Disposition availability and rejection of unavailable choices, direct CA setup with explicit primary cards, persistence into mission state, and fail-closed rejection of sealed defaults while that matchup is unsupported. It does not validate the current network rules page, the Purge the Foe primary-card mapping, full army legality or the rest of the partial Vow-sworn implementation.

### Crusader Surge stepped blocker bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T092546260230Z/results.json` (SHA-256 `591B42FD7419B205F85B684A530DBE1E378C182D1C993270123D17F96D394212`; `network: false`, legacy starter staged, no cleanup diagnostics). The coherent Surge route relaxation replaces each fixed same-height blocker square with an eight-slice union of inscribed rectangles and precomputes obstacle-edge intersections once per model proof. Regressions check rectangle containment, intersection vertices, a stronger lower bound than the previous square and a result below the analytic circle route. The focused run recorded 5.86 seconds for `test_contact_reachability` and 6.93 seconds for `test_fist_god_emperor`, compared with 5.23 and 5.64 seconds in the 09:00 run. This is a single-run comparison, not a benchmark; the stronger bound has not yet reduced total runtime in the observed run. The 1,024-box limit and bounded route/coherency scope remain unchanged.

### Crusader Surge formation route pruning and cache — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T090010987727Z/results.json` (SHA-256 `5A25CD291A0584AE38F5C0B2F3B77C92BFE866F986E44CAF991F837848DC5AD2`; `network: false`, legacy starter staged, no cleanup diagnostics). The coherent Surge route relaxation now adds inscribed squares inside fixed same-height blocker disks, giving a stronger safe route lower bound, and caches that bound for identical per-model endpoint boxes during branch-and-bound. A regression proves the blocker bound is tighter than Euclidean distance and remains below the analytic path around the actual circle. In this run `test_contact_reachability` took 5.23 seconds and `test_fist_god_emperor` 5.64 seconds, compared with 11.16 and 16.10 seconds in the adjacent 08:56 run; this is a single-run comparison, not a benchmark. The objective search cap and bounded route/coherency scope remain unchanged.

### Crusader Squad common tangents between blocker bases — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T085600539743Z/results.json` (SHA-256 `C45373C0282D63C1F8DD1599D1C783B9AC686E2E1522DC98A6427EB32E77437B`; `network: false`, legacy starter staged, no cleanup diagnostics). The waypoint graph now adds external and internal common tangents between reachable clearance-expanded blocker circles, plus tangents from existing terrain-corner nodes to those circles. Regressions validate tangent geometry, a two-base diagonal detour near its analytic shortest path and terrain-corner tangent-node admission. Arc transitions still use finite waypoints, and coherent-placement search remains bounded; Crusader Squad stays partial.

### Crusader Squad query-specific blocker tangents — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T084841185717Z/results.json` (SHA-256 `FED746C0F010932A420335748CC44C2F26FEDE3A2D0166281F96E83AA8ABFA32`; `network: false`, legacy starter staged, no cleanup diagnostics). The movement pathfinder now adds analytic tangent waypoints from the move origin and query destination to clearance-expanded circles around blocking bases, while retaining its shared waypoint graph for intermediate routes. The diagonal regression checks a route near the single-circle shortest-path lower bound. Multi-obstacle arc coverage and coherent-placement search remain bounded; this increment does not close Crusader Squad's partial scope.

### Space Marine Chapter source-to-runtime inventory audit — 29 October 2026

The earlier `pwsh -NoProfile -ExecutionPolicy Bypass -File tools/audit_space_marine_chapters.ps1 -SnapshotPath .tools/wahapedia-e11-live-refresh-20261029T072022Z-final-integration -OutputPath .tools/space-marine-chapter-gap-audit-20261029-current.md` checkpoint verified **22/22** export file hashes and found 76 Chapter-book sheets, 75 runtime profiles and one then-missing profile: Wolf Guard Headtakers (`000004131`). The report is derived from the timestamp-bracketed local 11e export and remains under ignored `.tools/`. It confirms source identity coverage only; it does not validate rules or complete local scope. At that checkpoint, MFM price mapping and composition reconciliation were still open, as was Crusader Squad route/coherency scope. The 29 October MFM follow-up mapped all four compositions and both cost tiers; runtime now admits only the Wahapedia-compatible 3+3 and 6+6 mixed formations, while the Headtakers-only rows remain blocked. Crusader Squad remains partial.

### Crusader Squad objective-target coherency follow-up — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T083807186639Z/results.json` (SHA-256 `143FFD9E0F845DC3DAA17D177686AE4F7302E34EAC96C5F647573BC7541A3917`; `network: false`, legacy starter staged, no cleanup diagnostics). Added marker and terrain objective-region regressions cover a wall-limited coherent endpoint, a closer coherent alternative, reachable objective range and a stationary endpoint already optimal under coherency. Preview defers objective-distance validation to full-formation confirmation. The objective certificate is bounded at 1,024 boxes; solo-survivor route search and general finite waypoint coverage remain partial.

### Crusader Squad exact enemy-engagement endpoint intervals — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --only test_fist_force_dispositions --only test_death_company_dreadnought --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T075602211222Z/results.json` (SHA-256 `F9C1C877FB69F2C6FB9F39DCB0BE681263CA467A9919AD3C56B95EFD289C3414`; `network: false`, legacy starter staged, no cleanup diagnostics). A regression places two forbidden circles so the legal gap between them falls between the previous 32-step samples; the exact interval union selects the furthest safe point and the public Purge and Sanctify path accepts it. Finite obstacle waypoint search, coherent group-placement search, network validation, playtesting and complete army legality remain open.

### Crusader endpoint capability metadata follow-up — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --only test_fist_god_emperor --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T075914919991Z/results.json` (SHA-256 `8841618C9E1944E14B88E2B9066DF913CB52FE8D5105BF13A51A089A5AB2B34A`; `network: false`, legacy starter staged, no cleanup diagnostics). The run checks that capability descriptions preserve the exact enemy-engagement endpoint behavior and the still-bounded waypoint/coherency scope.

### Crusader Squad safe partial-leg route regression — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --only test_fist_force_dispositions --only test_death_company_dreadnought --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T074840359064Z/results.json` (SHA-256 `4F761F2A7FB787A4EB1EE7D1E12D3F4E323DFA308C563B35A7AACBFD11D8D05D`; `network: false`, legacy starter staged, no cleanup diagnostics). The regression verifies that an otherwise allowed shorter endpoint remains reachable when the furthest endpoint on the same segment is rejected by the other-enemy Engagement Range filter. Finite route and endpoint samples, coherent-placement search, network validation, playtesting and complete army legality remain open.

### Talonstrike Kill Team source-bounded local scope — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_talonstrike_kill_team --only test_implemented_catalog --only test_capabilities --only test_current_unit_abilities --only test_space_marine_leader_links --timeout 300` passed **7/7 processes** at `.tools/verification/20261029T074509411414Z/results.json` (SHA-256 `94E5F7933CFE3878BDAACF2A8DCEEC891E23EF906B8C9F0E91D6BFC256ECC6DD`; `network: false`, legacy starter staged, no cleanup diagnostics). The run checks the source-reconciled Deathwatch App profile and export hashes, all mixed model characteristics/bases and weapon profiles, public preparation choices and limits, three-copy pricing, both-player materialization, both source-listed Jump Pack Leaders, Talonstrike Doctrines AP/Lance timing, current catalog admission and capability/ability/Leader registries.

This closes only Talonstrike's source-bounded local datasheet scope. The parent export has 68 unrelated structural findings while the Talonstrike subject slice has zero. At this Talonstrike checkpoint, Wolf Guard Headtakers price/composition mapping was still open. The MFM now maps all four rows, and the compatible mixed rows have partial local runtime integration; the Headtakers-only rows remain blocked by the selected Wahapedia composition. Crusader Squad route/coherency review, broader roster legality, catalog-wide network validation, human playtesting and full-match certification remain open. See the [Talonstrike sheet audit](../marine-talonstrike-kill-team.md) and [machine-readable source/hash audit](../marine-talonstrike-kill-team-audit.json).

### Grey Hunters source-bounded local scope — 29 October 2026

python tools/verify.py --profile targeted --only test_grey_hunters --only test_implemented_catalog --only test_capabilities --only test_blood_claws --only test_combat_doctrines --only test_roster_validation --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300 passed **8/8 processes** at .tools/verification/20261029T021529028806Z/results.json (SHA-256 E53F5448997D72DBE37AC38D76B31678D9E53B5F69E8188E5C119DA97CD008C; network: false, legacy starter staged, no cleanup diagnostics). The regression covers source-priced catalog admission, Pack Leader weapon options, exact five-model membership and cost conservation in Old Greymanes, and the Fight-phase objective gate and melee modifiers for Cunning Hunters. This closes only the named source-bounded local scope; the five source-listed Leader endpoints, network validation, human playtesting and full army legality remain open. See the [Grey Hunters audit](../marine-grey-hunters.md) and [machine-readable source/hash audit](../marine-grey-hunters-audit.json).

### Watch Master source-bounded local scope — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_watch_master --timeout 120` passed **3/3 processes** at `.tools/verification/20261029T005637251297Z/results.json` (SHA-256 `7bc0f4e042816ba40993ccdac0340c972ae9d28c0bb2f22204668cc8fc274f0c`; `network: false`, no legacy starter staged, no cleanup diagnostics). The source-bounded suite covers the refreshed Deathwatch App profile and hashes, construction admission and Veteran attachment, optional initial and replacement quarry selection/pass paths, Assault eligibility after Advance, model-only CHARACTER re-rolls, quarry-target Wound re-rolls and the Fall Back/Charge permissions.

The connected offline regression `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_watch_master --only test_invictor_tactical_warsuit --only test_deathwatch_veterans --only test_space_marine_leader_links --only test_combat_doctrines --only test_capabilities --only test_implemented_catalog --timeout 180` passed **9/9 processes** at `.tools/verification/20261029T005519320110Z/results.json` (SHA-256 `822ed338b843e5294a900a5fd6d8e29b0ea26ae52b7a284de0f8507af60928f6`; `network: false`, legacy starter staged, no cleanup diagnostics). The Invictor repeat-limit scenario uses the 2,000-point Strike Force category for its three-copy assertion; Incursion uses the correct two-copy non-Battleline ceiling. These checks establish only the named local scope. Network validation, human playtesting, full Chapter/army legality and platform coverage remain open. See the [Watch Master audit](../marine-watch-master.md) and [machine-readable source/hash audit](../marine-watch-master-audit.json).

### Decimus Kill Team source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --only test_fortis_kill_team --only test_deathwatch_veterans --timeout 300` passed **8/8 processes** at `.tools/verification/20261028T232332498607Z/results.json` (SHA-256 `930cd92ae10ca11e3854ee1e4abfcb369370def06ad59337ae6bc85b28a198cc`; `network: false`, legacy starter staged, no cleanup diagnostics). The dedicated suite and regressions cover the verified Deathwatch App source identity, source-priced five/ten-model sizes, role composition, weapons, per-five-model equipment limits, Death to the Alien, Combat Doctrines and source-listed Leader/Support relations. That 28 October check had accepted the five-model interpretation. The 29 October source recheck found the current page and export still require six minimum models, so the five-model size is now blocked from construction; see the follow-up below. Network validation, human playtesting and full Space Marine army legality remain open. See the [Decimus audit](../marine-decimus-kill-team.md) and [machine-readable source/hash audit](../marine-decimus-kill-team-audit.json).

### Decimus source conflict and supported-size gate — 29 October 2026

The current [Decimus Kill Team page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team) and refreshed, hash-verified export both list a 5-model price while requiring at least one model in each of four specialist roles in addition to the fixed Xenophase Veteran and Sergeant. Construction now offers only the coherent 10-model/210-point option; the 5-model/110-point size is recorded as excluded pending source correction. The focused profile/catalog/copy-limit/Apothecary run passed **6/6 processes** at `.tools/verification/20261029T130559976998Z/results.json` (SHA-256 `9E7233099702A49D6B01D5E020A0CDC796D32B802F8142F086E4DE9A57B98AD1`; `network: false`, no cleanup diagnostics). Checked-roster and Leader/Support link regressions passed **4/4 processes** at `.tools/verification/20261029T130749133650Z/results.json` (SHA-256 `4F823B79517A9372B934A070CA5807A99CA631DFC58A9E15CAC8ED566DFB1C82`; `network: false`). This does not resolve the five-model row or certify complete army legality.

### Fortis Kill Team source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fortis_kill_team --only test_implemented_catalog --only test_capabilities --only test_current_unit_abilities --only test_space_marine_leader_links --only test_contact_actions --timeout 300` passed **8/8 processes** at `.tools/verification/20261028T230231390978Z/results.json` (SHA-256 `876e1b8ec45263712179e9cb46a36fca342833c7bccae2bb2fcb436a5f8e2995`; `network: false`, legacy starter staged, no cleanup diagnostics). The run checks the local Fortis source identity, mixed composition, prices, model-specific loadouts, construction admission, Fortis Doctrines target-strength thresholds, ability registration, attachment links and contact actions. This closes only the declared source-bounded local Fortis scope; network validation, human playtesting and full Space Marine army legality remain open. See the [Fortis audit](../marine-fortis-kill-team.md) and [machine-readable source/hash audit](../marine-fortis-kill-team-audit.json).

### Sanguinary Guard source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sanguinary_guard --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --timeout 300` passed **6/6 processes** at `.tools/verification/20261028T204624103776Z/results.json` (SHA-256 `695056331297C00C2DAB81073C69C76971FED6035A9B1A4A5DA2615F160DA691`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The dedicated suite checks the verified profile identity, snapshot and slice hashes, priced 3/6-model costs and copy gate, weapons through Equipment/AttackPlan, reversible Inferno Pistol choices with an attached Captain, both-player catalog admission, Captain With Jump Pack attachment, Deep Strike, Combat Doctrines, and the melee Hit / Strength-gated Wound modifiers. This closes only the declared local Sanguinary Guard scope; Commander Dante attachment, full army legality, network behavior and human playtesting remain open. See the [Sanguinary Guard audit](../marine-sanguinary-guard.md) and [machine-readable audit](../marine-sanguinary-guard-audit.json).

### Baal Predator source-bounded local scope — 28 October 2026

Direct Godot 4.7.2 headless invocations with `--headless --path . --script` passed with zero failures for `test_baal_predator`, `test_capabilities`, `test_blood_angels_captain`, `test_sanguinary_priest` and `test_implemented_catalog`. The catalog reported 119 selectable profiles and four excluded. Baal checks cover the verified Blood Angels source snapshot/slice identity, exact datasheet and weapon profiles, 135/150-point tiers and three-copy cap, public optional equipment choices, Damaged 4, the registered Deadly Demise D3 value and Overcharged Engines re-rolling an Advance without CP. Captain's regression confirms its profile now records the Blood Angels slice manifest (`74de1b...`) rather than the Black Templars slice. `tools/audit_space_marine_chapters.ps1 -SnapshotPath .tools/wahapedia/11e/space-marines/20261021T130623Z` verified 23 snapshot files and reports 76 Chapter sheets, 34 runtime profiles and 42 missing. These were focused direct checks; `tools/verify.py`, network integration, full roster legality and final host/client behavior were not run or established. See the [Baal Predator audit](../marine-baal-predator.md).

### Blood Angels Captain source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_blood_angels_captain --only test_captain_current` passed **4/4 processes** at `.tools/verification/20261028T184631888100Z/results.json` (SHA-256 `B8C64725509F0A2CD39C6A5F983CC02033AF45D9743F9A99F9DC8046B41BCC8A`; `network: false`, no legacy starter staged, no cleanup diagnostics). Checks cover the verified source identity and hashes, 90-point profile, all weapon profiles and six source-legal combinations, both-player chapter-context materialization, current-catalog admission, exact Leader endpoints, Strategic Acumen, Warlord CP and Finest Hour. The shared-book Captain regression confirms ability-driven Finest Hour still works.

The wider catalog/capability/Leader regression also passed 7/7 processes at `.tools/verification/20261028T184845097646Z/results.json` (SHA-256 `2AC7C23273085737DE304D5A3518C28CEEDA69F08B217FE7F15C40ED72FE09E4`; `network: false`). That targeted run staged the existing legacy starter for supplemental historical fixtures; it verified 117 selectable current-reference Marine profiles and four excluded historical/non-Marine entries. No cleanup diagnostics were reported. This closes only this local datasheet scope; full army legality, network integration and human playtesting remain open. See the [Blood Angels Captain audit](../marine-blood-angels-captain.md).

### Execrator source-bounded local scope — 28 October 2026

python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_execrator --only test_crusade_ancient --only test_sword_brethren_squad passed **5/5 processes** at .tools/verification/20261028T182325483410Z/results.json (SHA-256 D8242A2984F4658D055814E9F0CC0C9784D1225728A757EC6E4D9E8213AE4BFE; network: false, no legacy starter staged, no cleanup diagnostics). The focused checks cover the Execrator’s verified source facts and manifest hashes, current catalog and Leader admission, legal equipment choices, Advance-and-charge scope, multiple engaged enemy units, mandatory -1 Battle-shock tests, existing Battle-shock persistence and the optional Tempered in Battle re-roll. The same run also rechecks Crusade Ancient’s pending Martial Honour window and Sword Brethren’s source-priced profiles and effects. This closes only the named local datasheet scopes; network validation, full army legality and human playtesting remain open. See the [Execrator audit](../marine-execrator.md).

### Crusade Ancient source-bounded local scope — 28 October 2026

`python tools/verify.py --profile focused --only test_crusade_ancient --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **3/3 processes** at `.tools/verification/20261028T171941190553Z/results.json` (SHA-256 `0F098095E0309CA214AFC19E4F5D2B7FD66C581837C761ECBDD55F22DC37509E`; `network: false`, no legacy starter staged, no cleanup diagnostics). The suite checks the verified profile facts and manifests, current construction admission, source Support relations, the Fight attack-declaration Vengeful Exhortation reaction and its 4+ success/failure/cleanup boundaries, and Martial Honour's post-attack choice, once-per-battle use and model-only +5 OC. This closes only the named local datasheet scope; overall roster legality, network validation and human playtesting remain open. Sword Brethren is now admitted at its source-priced sizes.

### Sword Brethren Squad source-bounded local scope — 28 October 2026

`python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_sword_brethren_squad --only test_space_marine_leader_links` passed **4/4 processes** at `.tools/verification/20261028T180348989697Z/results.json` (SHA-256 `DD1D23D5E1B1D4F9F527AF51FB5E61D04E7CF190742AA60E9D60372E71D42C16`; `network: false`, no legacy starter staged, no cleanup diagnostics). The tests check source-priced 4/5/9/10 sizes and both point tiers, all weapons and equipment options, four- and nine-model replacement caps, current catalog admission, a Chaplain Grimaldus Leader link, the pre-Fall Back engagement snapshot, the still-engaged restriction and the persisted Exploit their Cowardice 6-inch Normal Move, including rejection beyond six inches. This closes only the named local datasheet scope; 6–8-model sizes remain unavailable because the export has no prices, while roster-wide legality, network validation and human playtesting remain open.

### Surge target-endpoint route regression — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --only test_death_company_dreadnought --timeout 300` passed **5/5 processes** at `.tools/verification/20261029T071459381738Z/results.json` (SHA-256 `55509BA41B74190D8FCEA49350E5CB49A46C0264279C8F692735BF8418ECD2DF`; `network: false`, legacy starter staged, no cleanup diagnostics). The run checks Heresy Begets Retribution's reachable Engagement Range and closest endpoint through a wall detour, Purge and Sanctify's closest reachable objective endpoint, Crusader Squad catalog behavior and the shared Death Company Dreadnought route. Finite waypoint samples and coherent-placement alternatives remain bounded; this does not certify all legal routes or full army legality.

### Surge route detour regression — 28 October 2026

`python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_fist_god_emperor --timeout 60` passed **4/4 processes** at `.tools/verification/20261028T170155041675Z/results.json` (SHA-256 `36503C1F96740D4D97C46B7E41F2A4F325E027F10387990077EAC85CFB3AF73F`; `network: false`, `legacy_starter_staged: true` for supplemental historical fixtures, no cleanup diagnostics). The suite checks routes around a wall and enemy base, permitted friendly-base passage, the rolled-distance limit, closest-target reachability through a detour, and Righteous Zeal/Heresy Begets Retribution destination validation around a wall. A companion capability-metadata rerun passed **4/4 processes** at `.tools/verification/20261028T165948627380Z/results.json` (SHA-256 `2FF3792E86E5B286C824376A710F4FC4F5D9AB50327052719F7C4F6E624D0B81`; `network: false`, historical fixtures staged, no cleanup diagnostics). These runs verify only the focused offline route slice; finite route/coherency search, network validation, playtesting and full army legality remain open.

### Marine profile cache and Chapter regression — 28 October 2026

`python tools/verify.py --profile targeted --only test_implemented_catalog --timeout 180 --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **3/3 processes** at `.tools/verification/20261028T164316833550Z/results.json` (SHA-256 `5AD154B79D5B0EC8C6ED56DA608F366ED54127BCC5E6EB4C913F6005B68E9E51`; `network: false`, no legacy starter staged, no cleanup diagnostics). The catalog test process took 15.09 seconds, compared with 161.33 seconds in `.tools/verification/20261028T163621865660Z/results.json` before memoization—about 10.7× faster. The same assertions still cover all 112 entries and verify that callers cannot mutate cached profiles or catalogs.

The combined regression then passed **8/8 processes** under the verifier’s default 45-second per-process limit at `.tools/verification/20261028T164358830697Z/results.json` (SHA-256 `F3102CC8EB65D2BB61A55042F5411570F7DDD5CB2C83C8AB01A308CEBF86E913`; `network: false`, `legacy_starter_staged: true` for supplemental historical fixtures, no cleanup diagnostics). It covers Helbrecht, Marshal, core reactions, all 153 common-book Leader/Support links, capability metadata and the full construction catalog. The catalog publishes 112 entries across 111 complete local scopes and the partial Crusader Squad scope, while explicitly excluding four unsupported or non-Marine profiles. These offline checks do not imply full army legality or network validation.

28 October 2026 Black Templars vehicle source-bounded local scopes: `python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_black_templars_vehicles --only test_marine_repulsor_combat_embarkation` passed **4/4 processes** at `.tools/verification/20261028T141659297789Z/results.json` (SHA-256 `6d547667746d34c4731eedc946511ef911a71281b676a4334caab4a856111c52`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The vehicle suite covers the six Black Templars identities, source price tiers and catalog caps, every default weapon mode through the attack plan, the Impulsor's excluded Ironhail Skytalon Array, and Combat Embarkation eligibility for the Black Templars Repulsor. The companion suite exercises the full public Repulsor reaction after its fixture was moved to current-catalog preparation. The scoped seven-profile fixed-data comparison, including Emperor’s Champion, reported zero numeric/identity differences; its subject slice is valid, while 68 unrelated parent-export errors remain open. Black Templars now has eight runtime profiles; seven are missing, and Crusader Squad remains partial. Full army legality, network validation and human playtesting remain open. See the [vehicle audit](../marine-black-templars-vehicles.md).

28 October 2026 Nephilim Jetfighter and Ravenwing Dark Talon source-bounded local scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_nephilim_jetfighter --only test_ravenwing_dark_talon --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T130615559370Z/results.json` (SHA-256 `08537FEBF4151D7AB8F7E91638DEEB1DB8E7E05928375BB5F6819A2E761771B2`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The pair checks both current-catalog profiles, source weapon data, prices/copy caps, Nephilim loadout replacement and restoration, Damaged 3, Lightning-fast Manoeuvres, Aircraft reserve/ingress/return and movement/combat limits, plus Dark Talon's Stasis Bomb targeting, both rolls, shared low-roll allocation and saved-movement continuation. The 120 × 92 mm source ovals use provisional 60 mm bounding-circle proxies. Aircraft-specific Deadly Demise, doctrine effects, Plunging Fire targeting, full army legality, network behavior and human playtesting remain outside this result. See the [Nephilim audit](../marine-nephilim-jetfighter.md) and [Dark Talon audit](../marine-ravenwing-dark-talon.md).

28 October 2026 aircraft capability metadata consistency: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T131114410346Z/results.json` (SHA-256 `B53289C06BFEF6A1712929CEBE1F7BC1D27E5B79E72BCC4225201BC0241CEB64`; `network: false`, legacy starter staged, no cleanup diagnostics). The registry admits the two sheet-specific checks and keeps broader Aircraft Plunging Fire and Aircraft-triggered Deadly Demise validation pending.
28 October 2026 Ezekiel source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_ezekiel --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T120027007826Z/results.json` (SHA-256 `174180AE06115085E8BB3E216D2581E8FEF4A068A0409E5D67D2C2504697504A`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks profile and all weapon modes, Book of Salvation, Psychic Hood, Engulfing Fear, Whispers of the Shadow Forest, current-catalog admission and all seven source Leader links. The related Phobos Librarian/capability/Leader-link regressions passed 6/6 processes at `.tools/verification/20261028T120048353698Z/results.json`; the optional legacy starter was staged for those existing regression suites. The slice passed with no structural errors; the parent export has 68 errors outside this scope. Full Dark Angels/Space Marines army legality, network behavior and human playtesting remain open. See the [Ezekiel audit](../marine-ezekiel.md).

28 October 2026 Deathwing Terminator Squad source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_deathwing_terminator_squad --only test_terminator_squad_current --only test_deathwing_knights --only test_belial --only test_space_marine_leader_links --timeout 300` passed **7/7 processes** at `.tools/verification/20261028T113916146828Z/results.json` (SHA-256 `7eef7b59a1c6e093ffb3b59954ba06d5e78779a7919105100d6155f59a3d137b`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks both unit sizes, current-catalog prices, weapon profiles and options, the Deathwing Hit/BS/WS rule including attached-model attacks, Belial's separate Wound bonus, optional Watcher response, and all five Leader/Support links. It includes the shared Terminator Squad, Deathwing Knights, Belial and Leader/Support regressions. The parent export has 68 errors outside the structurally valid sheet slice. Full Dark Angels/Space Marines army legality and network validation remain open. See the [Deathwing Terminator Squad audit](../marine-deathwing-terminator-squad.md).

28 October 2026 Deathwing Terminator Squad capability/Azrael regression: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --only test_azrael --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T113948965947Z/results.json` (SHA-256 `c5549d6994d478f9ef45cf3c12b1eba6bdd8d0062e78deaba01390337514d153`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). This confirms the capability registry remains aligned and preserves Azrael's optional Watcher behavior.

28 October 2026 Deathwing Knights source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_deathwing_knights --only test_terminator_squad_current --only test_terminator_assault_squad --only test_belial --only test_space_marine_leader_links --timeout 300` passed **7/7 processes** at `.tools/verification/20261028T112030065233Z/results.json` (SHA-256 `a3bd8faed0eae837b2c80e48d6b89cff5388cf2d6f7970bf59e7140784511145`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the five-model source profile, price tiers, all four melee profiles, role-specific public loadout choices, optional Watcher, Inner Circle attack Damage reduction and Fortitude exclusion, Teleport Homer declaration and zero-CP Rapid Ingress, all four Leader targets, Ancient Support attachment, and the shared Terminator/Belial relation regressions. The parent export reports 68 errors outside this structurally valid source slice. Full Dark Angels/Space Marines army legality and network validation remain open. See the [Deathwing Knights audit](../marine-deathwing-knights.md).

28 October 2026 Deathwing Knights capability/Azrael regression: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --only test_azrael --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T112103950189Z/results.json` (SHA-256 `a2c6159cdd58b31948ba66384688bd019d879a22f0ca479849a3bf68884ef3b9`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). This confirms local capability status alignment and preserves Azrael's optional Watcher behavior.

28 October 2026 Azrael source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_azrael --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T103650933865Z/results.json` (SHA-256 `dd8a31b882ca1f79ddb2d135bfdeac0594157f0b3677764369884c845da0d47`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the App profile and weapons, all eight Leader targets, current-catalog admission, Deathwing context, unit-scoped Masterful Tactician timing, Sustained Hits 1, and Watcher in the Dark's once-per-battle mortal-wound prevention. It does not certify Dark Angels army legality or network behavior. See the [Azrael audit](../marine-azrael.md).

28 October 2026 Azrael metadata consistency: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T103807866500Z/results.json` (SHA-256 `fe97346493c612a4ccaf0e9ae51deceb47b88c8196d8eb729b4eb45f828e97d0`; `network: false`, no cleanup diagnostics). This checks capability metadata and all source-linked shared Leader relations after adding Azrael's eight targets.
28 October 2026 Ravenwing Darkshroud source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_ravenwing_darkshroud --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T102401179066Z/results.json` (SHA-256 `0d4d71661e6877363c66824094b99693b681374687aadd15e2485ceffe266614`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks the verified Dark Angels App profile and source IDs, every fixed weapon profile and the Heavy Bolter-to-Assault-Cannon choice, both weapon target paths, registration of Deep Strike, Deadly Demise D3 and Combat Doctrines, Lone Operative's 15-inch boundary, Icon of Old Caliban's 6-inch Dark Angels Stealth aura, and catalog cost/copy admission. It does not exercise the profile-specific Deep Strike ingress, Deadly Demise trigger or Combat Doctrine effects. The 60 mm collision proxy remains provisional because the source export provides only “Large Flying Base.” Full Dark Angels/army legality, network validation, detachment interactions and playtesting remain outside this scope. See [the datasheet audit](../marine-ravenwing-darkshroud.md).

28 October 2026 Darkshroud capability metadata consistency: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --timeout 300` passed 3/3 processes at `.tools/verification/20261028T102651045909Z/results.json` (SHA-256 `ae871974127299b234a0bc63c7700c078875beb17039963ebbececea54d313e`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The registry recognizes Icon of Old Caliban as locally tested while keeping full army coverage separate.

28 October 2026 Space Marine Chapter restriction mapping: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_combat_doctrines --only test_fist_god_emperor --only test_marine_detachment_roster_admission --timeout 300` passed 5/5 processes at `.tools/verification/20261028T081455519213Z/results.json` (SHA-256 `a39ce531865d06407f452682e8a476156485adcfbb1315166475f2811fad5531`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The focused checks cover the six source-restricted detachment mappings, reject conflicting selected Chapter context, retain Fist of the God-Emperor setup, and keep Chapter grouping alone from adding restrictions to Medusa's Wrath or Blade of Ultramar. This verifies local mapping behavior only; multi-Chapter army legality remains outside the gate.

28 October 2026 Fist Force Disposition profile and selector checks: `python tools/verify.py --profile targeted --only test_fist_force_dispositions --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe'` passed 3/3 processes at `.tools/verification/20261028T153543222779Z/results.json` (SHA-256 `33783d38fda0e0ef1df8b22558146e374ec024ce409c1ec00efb7f4d6ea605e88`; `network: false`, `legacy_starter_staged: true`, no headless RID cleanup diagnostics). The checks verify Fist's 1 DP / Take and Hold profile, preserve Gladius and Awakened Dynasty defaults, allow only roster-available direct choices, reject Priority Assets for Fist during sealed selection, and retain both Awakened Dynasty choices for P2. The run tests focused rule helpers and mission choice transitions; it does not validate a complete saved-roster launch, visual setup, network play or full army legality.

28 October 2026 capability registry consistency: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_capabilities --timeout 300 passed 3/3 processes at .tools/verification/20261028T080210980270Z/results.json (SHA-256 acaa8c2b56f3033708f78d548bdbe85f3d5f61cac22add94041516995e5b858a; network: false, legacy_starter_staged: true, no cleanup diagnostics). This aligns metadata assertions with validated and pending local states, and confirms Vanguard Ambushers remains inadmissible until its unit-level Hidden, Movement-end trigger and attack integration are checked.

28 October 2026 closure of the six remaining shared-book Space Marines transport datasheets: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_transport_profiles --only test_marine_transport_admission --only test_marine_transport_weapon_options --only test_marine_transport_rules --only test_marine_transport_destruction --only test_marine_machine_spirits --only test_marine_rhino_admission --only test_marine_impulsor_options --only test_marine_firing_deck --only test_marine_conditional_weapon_traits --only test_roster_validation --only test_army_builder --only test_marine_repulsor_combat_embarkation --only test_marine_executioner --only test_marine_repulsor_loadouts --only test_marine_rhino_veiling_smoke --only test_space_marine_leader_links --timeout 300` passed **19/19 processes** at `.tools/verification/20261028T072634954983Z/results.json` (SHA-256 `96c77d6ec353164a6d3fb07e637c6f99a97ad66602854f9e2fd8cff01909b1ff`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). This closes Land Raider, Land Raider Crusader, Land Raider Redeemer, Repulsor, Repulsor Executioner and Rhino for the shared Space Marines App source `000000139`, revision 2.8.1 / October 2026. The focused regression covers source profiles and cost tiers, weapon/system options, supported transport admission/restrictions, Machine Spirit and transport ability effects, Firing Deck/destruction continuations, both-player current-catalog construction and the Army Builder copy-price preview. The optional legacy starter fixture was staged for this broad regression run. This is source-bounded local sheet evidence only; full army legality and network validation remain open. See the six per-sheet audits in `docs/marine-{land-raider,land-raider-crusader,land-raider-redeemer,repulsor,repulsor-executioner,rhino}.md` and matching `-audit.json` files.

28 October 2026 Impulsor source-bounded scope: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_impulsor_options --only test_marine_transport_profiles --only test_marine_transport_admission --only test_marine_transport_rules --only test_marine_transport_weapon_options --only test_marine_transport_destruction --only test_marine_firing_deck --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300 passed **11/11 processes** at .tools/verification/20261028T065001931427Z/results.json (SHA-256 8536f6797ede5752f52de62ce73d432a33c868f6f7ea49188fab17677acb2782; network: false, legacy_starter_staged: false, no cleanup diagnostics). The scope checks the exact profile and 100 mm circular base, every weapon profile and source option, the Orbital Comms and Shield Dome effects, transport restrictions and Rapid Disembarkation after Advance, Core Firing Deck 7/Deadly Demise D3 bindings, and both-player current-catalog admission. Shared Firing Deck planning and transport-destruction continuation are exercised through transport regression fixtures. This closes the 79th of 85 common-book local scopes; six option-bearing transport sheets remain. Full army legality and network validation remain open. See the Impulsor audit at ../marine-impulsor.md.

28 October 2026 Outrider Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_outrider_squad_current --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T063311613901Z/results.json` (SHA-256 `7447b146a385ff53aba5310c5b5af6c46a33ea2a77564085bbb41cf2f533e12a`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks 3/6-model profiles and costs, every fixed/replacement weapon profile through Equipment/AttackPlan, owner-checked reversible choices and Plasma Pistol caps, both Full-throttle Assault branches in prepared attacks, contextual Dark Angels Ravenwing, all three shared-book Leaders, public Captain on Bike attachment and both-player current-catalog admission. The 90 × 52 mm oval is represented by a labelled 45 mm bounding-circle proxy. This closes the 78th of 85 common-book local scopes; seven option-bearing sheets remain. Full army legality and network validation remain open. See [the Outrider audit](../marine-outrider-squad.md).

28 October 2026 Terminator Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_squad_current --only test_space_marine_leader_links --only test_unit_reserves --only test_terminator_assault_squad --only test_detachment_stratagems --timeout 300` passed **7/7 processes** at `.tools/verification/20261028T055847733207Z/results.json` (SHA-256 `2d63936c3e478b86194ef0782f4417b31ae27660429d6bb2822d4be4f1fce829`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The new suite covers both unit sizes and copy-cost tiers, default and optional weapon profiles through Equipment/AttackPlan, Sergeant/regular replacement rules, the one-per-five special-gun cap, reversible Cyclone surcharge, Fury of the First across ranged/melee/attached attacks and its 9-inch edge boundary, Deep Strike and Teleport Homer declaration/removal/zero-CP ingress, both-player current catalogs, source-listed Leader/Support identities and the local Incursion copy gate. This closes the 75th shared-book scope; ten option-bearing sheets remain. The suite found and fixed an initializer that erased Terminators' default Power Fists when current abilities were enabled. Network validation and full army legality remain open. See the [Terminator Squad audit](../marine-terminator-squad.md).

28 October 2026 Terminator Assault Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_assault_squad --only test_space_marine_leader_links --only test_unit_reserves --only test_detachment_stratagems --only test_inceptor_squad --only test_kayvaan_shrike --only test_marine_drop_pod --only test_marine_wardens_profile --only test_reiver_squad --timeout 300` passed **11/11 processes** at `.tools/verification/20261028T054135729338Z/results.json` (SHA-256 `a4a5bf6d4e274a3bee448ad4b70180bd898f0d333eb0a7ab22cdbc8318dec223`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers both unit sizes and source cost tiers, all characteristics and weapon traits, reversible Storm Shield choices and per-model costs, Terminatus Assault target gates, Deep Strike/Teleport Homer placement and removal, both-player materialization, all seven common-book Leader/Support identities, and local Incursion admission. This closes the 74th common-book local scope; 11 option-bearing scopes remain. Shared ingress now applies the Deep Strike placement exception to Strategic Reserves edge/deployment-zone restrictions while retaining enemy-distance and geometry checks. The local two-copy limit is not full army legality. Network validation remains deferred to final integration. See the [Terminator Assault audit](../marine-terminator-assault-squad.md).

28 October 2026 Sternguard Veteran Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sternguard_veteran_squad --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T052655350303Z/results.json` (SHA-256 `1484ae1ece4357ca226379e80a3d08212f2cbed774b55198aa21d55e6fd80716`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers both sizes and source cost tiers, every default and optional weapon through Equipment/AttackPlan, public reversible Sergeant and per-five-model Veteran choices, Veteran Marksmen ranged and attached-Leader effects plus melee/Snap Shooting boundaries, all 14 common-book Leader/Support identities, current catalogs for both players and the local Incursion two-copy gate. This closes the 73rd source-bounded common-book local scope; 12 option-bearing scopes remain. The local Incursion cap is not full current-edition army legality. Network validation and full army legality remain open. See the [Sternguard audit](../marine-sternguard-veteran-squad.md).

28 October 2026 Intercessor Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_intercessor_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T051426845028Z/results.json` (SHA-256 `3539e140d8a8761f330ef0ad244626f492895d90de8ed833ecb822b8a3ed4dea`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers both compositions, exact source profile and points, all Sergeant replacements, Grenade Launcher eligibility/caps, every weapon profile through Equipment/AttackPlan, Bolter Discipline and Tactical Mainstay boundaries, all common-book Leader/Support relations and both-player current-catalog admission. This closes the 72nd source-bounded common-book local scope; 13 option-bearing scopes remain. The MFM 1.6 Incursion four-copy Battleline gate is recorded as a local construction limit, not complete current-edition army legality. Network validation and full army legality remain open. See [the Intercessor audit](../marine-intercessor-squad.md).

28 October 2026 Lieutenant in Phobos Armour source-bounded scope: `python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_phobos_lieutenant --only test_infiltrator_squad --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T013420957771Z/results.json` (SHA-256 `33addbe8eacfaa93ae05c2aaec2d23fa8596365c84a04c9df40c3849e5e5b9ec`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the exact 40-point source profile, both gun options and retained blades through Equipment/AttackPlan, both-player current-catalog materialization and copy limit, four common-book Support links, mixed-unit ability boundaries, reserves and the Demi-company Commander response. This closes only the shared-book local scope; network and full army legality remain open. See [the sheet audit](../marine-lieutenant-phobos-armour.md).

28 October Captain in Gravis Armour source-bounded scope: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gravis_captain --only test_gravis_captain_profile_parity --only test_space_marine_leader_links --timeout 300 passed 5/5 processes (import, Python checks, Gravis scope, profile parity and all 153 common-book Leader/Support links) at .tools/verification/20261028T004022679152Z/results.json (SHA-256 d3e8554dcc01eefa0836ff41506c2b4aa56b0413e597602451f506f9aa2b4e3d; network: false, legacy_starter_staged: false, no cleanup diagnostics). The current-catalog suite checks both players, the 90-point/40 mm source profile, the default and all three paired weapon packages through Equipment/AttackPlan, the three-copy cap, four common-book Leader targets, Strategic Acumen duration, bearer-only Refuse to Yield damage reduction and once-per-round Warlord CP. Deathwatch Indomitor Kill Team is outside the shared 85. This closes only the common-book local datasheet scope; full army legality and network validation remain open. See the Captain in Gravis Armour audit (../marine-captain-gravis.md).

27 October 2026 Wardens of Ultramar source-bounded scope closure: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_wardens_profile --timeout 300 passed 3/3 processes (import, Python checks and Wardens scope) at .tools/verification/20261028T003202038856Z/results.json (SHA-256 a6452e5031358ce0799067ac80ec8ccf91412fed6cf7ad1cfd11eddc953fd932; network: false, legacy_starter_staged: false, no cleanup diagnostics). It checks the six-model/115-point fixed profile, individual bases and defense, Dainal's PSYKER keyword, all fixed weapon plans, four common-book Support targets, Raise the Banner timing, and Strategium Command ownership/redeployment/reserve exception/three-unit limit. A separate 7-process current regression covering Leader/Support links, Ancients, Company Heroes and the catalog also passed; it staged the optional legacy starter, so it is not the clean-catalog evidence. See [the Wardens sheet audit](../marine-wardens-ultramar.md) and [source/evidence record](../marine-wardens-ultramar-audit.json).

27 October 2026 Vulkan He’stan source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vulkan_hestan --only test_vulkan_hestan_profile_parity --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T001549947966Z/results.json` (SHA-256 `179643ff60b9bc543fe662b4420df814cb7e085fd5d49c5101da898570e14564`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the fixed profile and all three weapon plans, current Marine catalogs for both players, the five common-book Leader targets, Warlord CP, base Feel No Pain 6+, Seeker’s objective choice and conditional OC/Leadership/FNP 4+, plus Forgefather’s visible/range/opaque-terrain gates and Melta/Torrent AttackPlans. The current Wahapedia page and pinned export agree; the per-profile fixed-data comparison reports no differences, though its parent artifact is not globally certified. This closes only Vulkan’s common-book local scope; Salamanders Chapter rules, the Legends Vanguard Veteran pairing, full army legality and network validation remain outside scope. See [the Vulkan audit](../marine-vulkan-hestan.md).

27 October 2026 Suboden Khan source-bounded scope closure: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_suboden_khan --only test_space_marine_leader_links --only test_marine_conditional_weapon_traits --only test_attack_sequence --only test_weapon_selection --timeout 300 passed 7/7 processes at .tools/verification/20261028T000207773070Z/results.json (SHA-256 b5008fb2acfe074714768f06796b830813c6ea6080f9836d0bc38ad0c9cd65d9; network: false, legacy_starter_staged: true, no cleanup diagnostics). The scope covers Suboden's exact profile and all four weapons through Equipment/AttackPlan, both current Marine catalogs, unique-copy admission, the Outrider Leader link and shared relation regression, Combat Doctrines and Transhuman Strategist, Spear of Chogoris, Skilled Riders, target-restricted Power Sword Sustained Hits, and Stormtooth Anti-MONSTER/VEHICLE plus Lance. The pinned fixed-data comparison reports no Suboden profile differences. This closes only the common-book local sheet scope; the run staged the optional legacy starter pack, and does not prove clean-checkout demo behavior, White Scars roster legality, full army legality or network validation. See the [Suboden Khan sheet audit](../marine-suboden-khan.md) and [snapshot audit](../marine-suboden-khan-audit.json).

27 October 2026 Tor Garadon source-bounded scope closure: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tor_garadon --only test_space_marine_leader_links --timeout 300 passed 4/4 processes (import, Python checks, Tor Garadon and all 153 common-book Leader/Support links) at .tools/verification/20261027T235102047086Z/results.json (SHA-256 1638836fda91a6020e9ba5c6bf4c66b73cfbbc4526f88e2a688209f819124848; network: false, legacy_starter_staged: false, no cleanup diagnostics). The suite checks the exact 90-point profile and both weapons through Equipment/AttackPlan, current local Space Marines catalogs for both players, unique-copy admission, Warlord CP, Siege Captain target conditions, Signum Array ownership/cover/use/phase behavior, and all source Leader links. This closes only Tor's shared-book local sheet scope; Chapter rules, full army legality and network validation remain open. See the Tor Garadon audit (../marine-tor-garadon.md).

27 October 2026 Roboute Guilliman source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_guilliman --only test_roster_validation --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, Guilliman, checked-roster validation and all 153 common-book Leader/Support links) at `.tools/verification/20261027T233923329274Z/results.json` (SHA-256 `b4e5b25c0f995d59ddacb7257727a6ac7d76e80b3da0643be5bc539ffc88eea5`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The suite checks the exact one-model 415-point fixed profile, all weapon modes through Equipment/AttackPlan, both-player current catalogs, eight source-listed ability records, aura rerolls through an allied attack plan, Feel No Pain 5+, public Warlord selection, Author of the Codex ownership/timing/expiry, Lone Operative range and source limits, and Warlord CP. It exposed and fixed a runtime 6+ Feel No Pain mismatch and updated the roster fixture to select a supported Event Companion terrain layout. The current Wahapedia page and verified pinned export agree, and the fixed-data comparison reports no Guilliman differences. This closes only his shared-book local datasheet scope; Ultramarines/Gladius roster legality, complete army legality and network validation remain open. See [the Guilliman audit](../marine-guilliman.md).

27 October 2026 Librarian source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_librarian_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, Librarian and all 153 common-book Leader/Support links) at `.tools/verification/20261027T232136941877Z/results.json` (SHA-256 `2df8150f38cd565e9c825d8420d34a94fe77379f352a4dbe00ce29ac7250a971`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the exact 75-point fixed profile and no-option loadout, all four weapon profiles through Equipment/AttackPlan, current Marine catalogs for both players, six common-book Leader links, Combat Doctrines and Warlord eligibility, Psychic Hood, Force Dome, Veil of Time and the level-1 round limit. The current Wahapedia page and pinned export agree; the fixed-data comparison reports no Librarian differences. This closes only the shared-book local sheet scope; Chapter/Legends targets, full army legality, network behavior, complete matches and human playtesting remain outside it. See [the Librarian datasheet audit](../marine-librarian.md).

27 October 2026 Judiciar source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_judiciar --only test_judiciar_profile_parity --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, Judiciar, profile parity and all 153 common-book Leader/Support links) at `.tools/verification/20261027T231150548787Z/results.json` (SHA-256 `1e67c8aa3925cf6e129c9aae80e2559c7a2a2e1f81675da1fc5f8a3c94e6a8fe`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks the exact profile, both weapon plans, both-player catalog materialization, all five in-scope Support targets, melee-only invulnerable-save behavior and Tempormortis Fights First timing/source lifetime. This closes only the shared-book local sheet scope; Chapter/Legends targets, full army legality and network behavior remain outside it. See [the Judiciar datasheet audit](../marine-judiciar.md).

27 October 2026 Iron Father Feirros source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_iron_father_feirros --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T230433907954Z/results.json` (SHA-256 `c9a59d264d04518c00a01d07a66b40b7df83514c24314d1f89b43f5aba4528a6`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the exact one-model profile and no-option loadout, all four fixed weapon plans, both-player current Marine catalogs, the four Leader targets, owner-checked Warlord/CP, Rites of Tempering's strict Strength comparison, Iron Father's 3-inch standalone/Attached boundary, and Master of the Forge's deferred end-of-move repair, modifier protection and expiry. The current Wahapedia page and pinned export agree, and the fixed-data comparison reports no Feirros differences. This closes only his shared-book local scope; Iron Hands Chapter rules and complete army legality remain outside it. See [the Feirros datasheet audit](../marine-iron-father-feirros.md).

27 October 2026 Chief Librarian Tigurius source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chief_librarian_tigurius --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T225949381745Z/results.json` (SHA-256 `e1def037ecd1863c961da8eca1f8c7b2a55d4ba343ae53c6efd4f8926c7682df`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the exact fixed profile and no-option loadout, all three weapons through Equipment/AttackPlan, both-player current Marine catalogs, six common-book Leader links, Hood of Hellfire, Prescience duration, Telepathic Assault's visible 24-inch target and defender-owned mortal allocation/save-restore/phase-close path, both powers in one turn and Warlord CP. The current Wahapedia page and pinned local export agree, and the 85-profile fixed-data comparison reports no Tigurius differences. This closes only his shared-book local scope; the Legends Vanguard Veteran pairing, Ultramarines Chapter rules and full army legality remain outside it. See [the Tigurius datasheet audit](../marine-chief-librarian-tigurius.md).

27 October 2026 Kaius Konorius source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_kaius_konorius --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T225347438197Z/results.json` (SHA-256 `4114937293a141fc6bc0d9de706583120434a7247237c01b7ef73f504f8b46ca`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite materializes Kaius from the current catalog for both players; checks all fixed weapons through Equipment/AttackPlan, the Support role and four source targets, Combat Doctrines, the Captain-Leader/Kaius-Support attachment, Veteran Bodyguard's other-Character FNP 4+ and Calgar's Champion target gate. The current Wahapedia page matches the pinned export, and the 85-profile fixed-data comparison reports no Kaius differences. This closes only his common-book local scope. See [the Kaius datasheet audit](../marine-kaius-konorius.md).

27 October 2026 Kaius Support-role regression batch: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_marine_leader_links --only test_roster_validation --only test_current_unit_abilities --only test_implemented_catalog --timeout 300` passed the relation-map, current-abilities and implemented-catalog suites, but `test_roster_validation` failed at its pre-existing Roboute roster setup because the fixture lacks a supported 11th-edition Event Companion terrain layout. Report `.tools/verification/20261027T225107906098Z/results.json` (SHA-256 `d5fb946674cdafab8437d076e62209a6b0e12bd86ef5579cf6b5315d9bcfe9b0`); the fixture failure occurs before its roster cases and is unrelated to Kaius.

27 October 2026 Caanok Var source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_caanok_var --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T224248107984Z/results.json` (SHA-256 `30ec9c4ebadb466d031ce4410624af57310b518123a9c02be8a658eec84b6f23`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite materializes Caanok for both players, checks the fixed profile and weapons through Equipment/AttackPlan, both Leader targets, Core/Army ability registration, Cerebrex's owner-checked Scouts 6 setup, Cold and Calculating's real Vehicle/Infantry target conditions with Tactical Doctrine, and Warlord CP timing. The current Wahapedia datasheet and pinned local export agree; the 85-profile fixed-data comparison reports no differences for Caanok. This closes only his common-book local scope; Iron Hands Chapter rules and complete army legality remain open. See [the Caanok sheet audit](../marine-caanok-var.md).

27 October 2026 Darnath Lysander source-bounded scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_darnath_lysander --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T223627402745Z/results.json` (SHA-256 `d34865fc6d9280c34ce515a74cc6e1e756ea9fb3075859277cbc5edb90440a9b`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks the source profile and one-copy cap, Fist of Dorn through Equipment/AttackPlan, current Marine catalogs for both players, exact Terminator Leader targets, all listed abilities, Warlord CP timing, Rampart at a non-Shooting phase start and through phase expiry, and Icon of Obstinacy in incoming ranged/melee contexts. The current Wahapedia page matches the pinned local export and the 85-profile fixed-data comparison reports no Darnath differences. This closes only the common-book local sheet scope; Chapter rules and full army legality remain open. See [the datasheet audit](../marine-darnath-lysander.md).

27 October 2026 Lieutenant with Combi-weapon scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_lieutenant_combi_weapon --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T220101252638Z/results.json` (SHA-256 `bcd89f1dfdeb59a6c2bd4ac424ef88eb50e8224c0bda03e9cf99bf29516e2b47`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite now uses current Marine catalogs for both players and checks the exact source profile/keywords, every fixed weapon mode through Equipment/AttackPlan, FNP, Infiltrators/Stealth predicates, Lone Operative, Combat Doctrines registration, Priority Target Identified and Evade and Survive's saved public decision flow. It exposed and fixed a missing Combat Doctrines ability registration; the verifier also now classifies this test as current-catalog rather than legacy-fixture dependent. The current Wahapedia page matches the pinned local export. See [the sheet audit](../marine-combi-lieutenant.md).

27 October 2026 Cato Sicarius and Marneus Calgar linked scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_cato_sicarius --only test_cato_profile_parity --only test_marneus_calgar --only test_victrix_honour_guard --only test_space_marine_leader_links --timeout 300` passed **7/7 processes** at `.tools/verification/20261027T184013951006Z/results.json` (SHA-256 `fda6d470dc83ef6df9faa13f30c37ae748879ca91526b0b5faba66a546bfde01`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The run closes the declared Cato and Calgar local scopes and checks the 153-link relation suite. Victrix is included only as a linked regression and remains open for role composition and optional Banner cost. See [Cato](../marine-cato-sicarius.md) and [Calgar](../marine-marneus-calgar.md).

27 October 2026 fixed-weapon-plan helper regression: focused verification passed **9/9 processes** at `.tools/verification/20261027T184300165783Z/results.json` (SHA-256 `7206c29544a351023b91787fa309ea9b027c5c36d65130b790e568c641db4279`; `network: false`, `legacy_starter_staged: false`). The seven consumer suites cover Adrax Agatone, Aethon Shaan, Captain Titus, Kor'sarro Khan, and the Ancient, Captain and Chaplain in Terminator Armour after Extra Attacks-aware fixed weapon routing changed. This is a shared-helper regression result, not additional datasheet scope.

27 October 2026 Captain in Phobos Armour scope closure: the dedicated sheet, profile-parity and shared Leader-link suites passed **5/5 processes** at `.tools/verification/20261027T111545655265Z/results.json` (import, Python checks and three Godot suites; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The checks cover the current-catalog profile for both players, all three fixed weapons through Equipment and AttackPlan, the tested Phobos abilities and Tactical Fluidity's saved phase-close continuation; the paired relation suite checks all 153 common-book links. This closes only the shared-book Captain scope; Chapter-specific links and full army legality remain outside it. See the [Captain in Phobos audit](../marine-captain-phobos.md).

27 October 2026 Kayvaan Shrike scope closure: the dedicated sheet and shared Leader-link suites passed **4/4 processes** at `.tools/verification/20261027T112204266063Z/results.json` (import, Python checks and both Godot suites; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The checks cover source admission and copy limit, both weapons through Equipment and AttackPlan, both Jump Pack Leader targets, Warlord CP, Trifold Path and Echo of the Ravenspire's saved phase-close continuation. This closes only the common-book Shrike scope; Raven Guard Chapter-book behavior and full army legality remain outside it. See the [Kayvaan Shrike audit](../marine-kayvaan-shrike.md).

27 October 2026 Librarian in Phobos Armour scope closure: the dedicated sheet and shared Leader-link suites passed **4/4 processes** at `.tools/verification/20261027T113940680686Z/results.json` (import, Python checks and both Godot suites; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The checks cover exact source profile data, all four weapon profiles through Equipment and AttackPlan, Psychic Hood prevention, Soul Sight/Shrouding, both Scout 6 paths with both-player alternation, current-catalog materialization for both players, and the five common-book Leader targets. This closes only the declared shared-book local scope; Chapter-specific targets and full army legality remain outside it. See the [Librarian in Phobos Armour audit](../marine-librarian-phobos.md).

27 October 2026 Incursor Squad scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_incursor_squad --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T061905870311Z/results.json` (import, Python checks and the dedicated suite; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite uses current Marine catalogs on both sides and checks the source composition/costs/keywords/base, all three weapon profiles through Equipment and AttackPlan, Scouts 6, all three Leader targets, Divinator-class Auspexes range/trigger/reroll/phase behavior, and Haywire Mine range, one-use limit, Vehicle/non-Vehicle damage and defender allocation. This closes only the declared Incursor shared-book local scope; network validation and full army legality remain open. See the [Incursor sheet audit](../marine-incursor-squad.md).

27 October 2026 Brutalis Dreadnought scope closure and Tank Shock eligibility correction: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_brutalis_dreadnought --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T061109103709Z/results.json` (import, Python checks and the dedicated suite; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The scope suite checks source composition/costs/characteristics, Damaged 4, every ranged/melee weapon and both replacements through Equipment and AttackPlan, Brutalis Charge's additional free Tank Shock in both directions relative to an ordinary use, defender-owned mortal allocation/continuation, save/restore, wrong-owner rejection and current-catalog admission. It exposed that source `VEHICLE` keywords were compared against lowercase text, preventing Crushing Impact eligibility; keyword comparison now normalizes case. This closes only the declared Brutalis shared-book local scope; network validation and full army legality remain open. See the [Brutalis sheet audit](../marine-brutalis-dreadnought.md).

27 October 2026 Company Heroes scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_company_heroes_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T060134565606Z/results.json` (import, Python checks and both Godot suites; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The tests cover the four source-defined roles and model-specific weapons/keywords, all weapon profiles through Equipment and AttackPlan, Command Squad in a real incoming attack plan, Raise the Banner's objective/timing boundary, the Captain attachment predicate and all 153 shared Leader relations. The scope suite caught and fixed the missing source-listed `CHARACTER` keyword on the Ancient model. This closes only the Company Heroes source-bounded shared-book local scope; network validation and full army legality remain open. See the [Company Heroes sheet audit](../marine-company-heroes.md).

27 October 2026 Firestrike Servo-turrets scope closure and Overwatch correction: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_firestrike_servo_turrets --only test_core_reactions --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T055306196988Z/results.json` (import, Python checks and both Godot suites; `network: false`, `legacy_starter_staged: false`, no headless cleanup diagnostics). Sentinel Protocols now allows its extra Fire Overwatch after a normal use while leaving another unit's normal Overwatch available after Firestrike uses its ability. The Firestrike suite covers both weapon modes and Hovering Bulk through AttackPlan, individual turret choices, snap-hit behavior, no repeat use and local admission. This closes only the declared Firestrike source-bounded shared-book scope; network validation and full army legality remain open. See the [Firestrike sheet audit](../marine-firestrike-servo-turrets.md).

27 October 2026 Aggressor Squad scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aggressors --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T054124713809Z/results.json` (import, Python checks and the dedicated Godot suite; `network: false`, `legacy_starter_staged: false`). The suite checks both priced sizes, the whole-unit weapon package and restore path, exact Flamestorm ranged/Close-quarters and alternative weapon profiles through AttackPlan, Blast expansion against the ten-model target, three-model Twin Power Fist attacks, Firestorm's exact 9-inch range and living range sources, engaged shooting eligibility, actual Torrent/Twin-linked resolution and local roster admission. This closes only the Aggressor Squad's declared source-bounded shared-book local scope; whole-army legality, network validation and human playtesting remain open. See the [Aggressor sheet audit](../marine-aggressor-squad.md) for the pinned snapshot, source hashes and limits.

27 October 2026 Vanguard Veteran Squad With Jump Packs scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vanguard_veterans --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T053433336440Z/results.json` (import, Python checks and the dedicated Godot suite; `network: false`, `legacy_starter_staged: false`). The suite checks five/ten-model prices, including the third-plus cost tier and three-copy catalog limit; all source-listed equipment choices and bearer limits; weapon profiles through AttackPlan; Vanguard Assault; Deep Strike reserve assignment for the attached unit; Leader eligibility; and conditional Dark Angels `DEATHWING`. This closes only the sheet's declared source-bounded shared-book local scope; network validation, every reserve ingress path and full army legality remain open. See the [Vanguard Veteran sheet audit](../marine-vanguard-veterans-jump-packs.md) for the pinned export snapshot, file hashes, full scope and limits.

27 October 2026 Redemptor Dreadnought scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_redemptor_dreadnought --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T051901469684Z/results.json` (import, Python checks and the dedicated Godot suite; `network: false`, `legacy_starter_staged: false`). The suite checks every source equipment combination and ranged AttackPlan package, melee, conditional weapon traits, Damaged 4, Duty Eternal, Combat Doctrines, the actual Deadly Demise allocation flow, source-conditional Dark Angels `DEATHWING`, and local catalog admission. This closes only the Redemptor's source-bounded shared-book local scope; whole-army legality, network validation and match certification remain open. See the [Redemptor sheet audit](../marine-redemptor-dreadnought.md) for the pinned snapshot and source-file hashes.

27 October 2026 Lieutenant scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_lieutenant --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T050300064874Z/results.json` (import, Python checks and the dedicated Godot suite; `network: false`, `legacy_starter_staged: false`). The suite uses current Space Marines catalogs and covers every source option combination, conditional Storm Shield, all weapon profiles through AttackPlan, Tactical Precision exclusions, attachment eligibility and Demi-company Commander. A related cross-check command covering Lieutenant dependencies and adjacent combat/catalog/Leader rules passed **8/8 processes** at `.tools/verification/20261027T050337525997Z/results.json`; that aggregate staged the optional legacy starter for companion suites (`legacy_starter_staged: true`), so the dedicated no-stage result above is the Lieutenant scope evidence. This closes only the shared-book Lieutenant local scope; network validation, complete army legality and match certification remain open.

27 October 2026 Space Marines conditional-weapon reconciliation: regenerated an 85-profile runtime audit and compared it to the verified local Wahapedia slice. `python tools/compare_wahapedia_marines.py --snapshot .tools/wahapedia-marines-slice-20261021-v4 --runtime-profiles .tools/marine-runtime-audit-20261027-v8.json --identity-map docs/space-marines-source-identity-map.json --output .tools/marine-comparison-20261027-v12.json --chapter shared` reports 85/85 fixed-data profiles consistent, zero numeric/identity differences and zero weapon-trait differences. `python -m unittest tests.test_wahapedia_import tests.test_wahapedia_fixed_checks` passed 35/35; `test_marine_conditional_weapon_traits.gd`, `test_marine_transport_profiles.gd` and `test_terminator_squad_current.gd` passed. This is bounded profile/condition evidence, not complete-sheet implementation. `test_eradicator_melta_rifles.gd` remains blocked by a fixture without a supported Event Companion terrain layout; `test_redemptor_dreadnought.gd` currently fails before its Damaged 4 assertion because the attack fixture cannot legally target its selected unit. Network validation remains deferred.

27 October 2026 Scout Squad scope closure: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_scout_squad --timeout 300` passed **3/3 processes** at `.tools/verification/20261027T044508003953Z/results.json` (import, Python checks and `test_scout_squad`; `network: false`). The suite covers both priced compositions, all listed wargear and caps, weapon profiles through AttackPlan, Infiltrators, Scouts 6 normal movement and Strategic Reserves set-up, Flexible Asset's Advance/Fall Back boundaries, both source-linked Phobos Leaders and local admission. This establishes Scout Squad's source-bounded local sheet scope only; full faction/army legality and network validation remain open.

27 October 2026 Fist of the God-Emperor and Vow-sworn Crusaders increment: focused local checks for the Crusader Squad profile, Righteous Zeal/Purge and Sanctify, Righteous Fervour and the three Fist stratagems passed alongside the core three Templar Vows. The related regressions for Stormlance enhancements, detachment stratagems and Combat Doctrines also passed. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_templar_vows --only test_stormlance_enhancements --only test_detachment_stratagems --only test_combat_doctrines --timeout 300` passed **7/7 processes** at `.tools/verification/20261027T025046843904Z/results.json` (import, Python and five Godot suites; no headless RID cleanup diagnostics, `network: false`). This is focused local evidence only: Oathbound Exemplar and the Vow-sworn enhancements/stratagems still need checks; no usable visual capture, playtesting, network validation, Force Disposition coverage or full army legality is claimed.

26 October 2026 fixed secondary expansion: the CA profile now has optional Bring It Down and A Grievous Blow pairs, but no local verification was run for these additions because testing is deferred. Existing reports below cover earlier mission behavior only; both additions remain pending focused checks, host/client validation and human playtesting.

24 October selection/datasheet and combat-feedback candidate: the broad local selection, camera, ownership, layout, tactical, doctrine, save and presentation audit passed **12/12** at `.tools/verification/20261024T213835681697Z/results.json` (39 Python checks). Final inspector/card checks passed **4/4** at `.tools/verification/20261024T214203268368Z/results.json`; bounded mirror/tactical loopback passed **6/6** at `.tools/verification/20261024T214203268551Z/results.json`; the final PCK passed **5/5** at `.tools/verification/build-20261024T214203269305Z/results.json`. These reports contain no headless cleanup diagnostics. Actual Godot captures were inspected at 1280x800 and 1024x768. Selection-refresh CPU time in the same eight-sample debug-runtime checkpoint fell from 166.1-173.9 ms to 7.2-9.6 ms; this is not release FPS or input-to-photon evidence. See the [selection review](../project/selection-datasheet-review.md) and [progress report](../project/tactical-training-experience-progress.md) for commands, captures, stable attack identity, save feedback and remaining human gates.

24 October Command doctrine UI follow-up: action/unit/doctrine selectors separate free Strategic Acumen from Adaptive Strategy, show cost/effect/duration and warn of an already-active primary doctrine. The tactical/doctrine/Help run passed **5/5** at `.tools/verification/20261024T170427180122Z/results.json`; the final doctrine/Help recheck passed **4/4** at `.tools/verification/20261024T170633135548Z/results.json`, including 39 Python checks. Actual Godot/OpenGL captures were inspected at 1280x800 and 1024x768. The final PCK passed **5/5** stages at `.tools/verification/build-20261024T170716525024Z/results.json`. These are local UI/build checks, not new rules, network or human acceptance evidence. See the [progress report](../project/tactical-training-experience-progress.md) for exact commands and the initial fixture failures.

24 October tactical reaction UI audit: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_roll_choice_ui --timeout 300` passed **3/3 processes** at `.tools/verification/20261024T161811460493Z/results.json` (import, 37 Python checks and the Godot UI suite; no legacy snapshot, network or cleanup diagnostics). Actual Keep/Command Re-roll buttons were exercised separately for Advance, Charge, Desperate Escape, attack count, Hit, Wound, Save, Damage and Hazardous, checking owner CP, continuation and retained/replaced dice. The synthetic weapon fixture tests UI wiring, not datasheet accuracy; headless visibility is not rendered fit or human acceptance. See the [experience progress report](../project/tactical-training-experience-progress.md).

24 October tactical UX candidate: defender choice is now enabled for new guided training, and Keep submits no replacement die. The new presentation, local feedback and compact history passed **9/9 local processes** at `.tools/verification/20261024T154842358045Z/results.json`; the final tactical/tray recheck passed **4/4** at `.tools/verification/20261024T155634746804Z/results.json`. The final bounded mirror/tactical loopback passed **6/6** at `.tools/verification/20261024T160441117483Z/results.json`, including guest deployment rejection/recovery feedback at the miniature and Command card without invalid-command state/RNG mutation. The final PCK passed all five build/smoke stages at `.tools/verification/build-20261024T155634742518Z/results.json`. Actual Godot captures cover opening/Help at 1024×768, 1280×800 and 1600×900, plus scripted combat at the two smaller sizes. Exact commands, intermediate failures, artifact identity, capture conditions and remaining boundaries are in the [experience correction report](../project/tactical-training-experience-progress.md). These technical checks do not close the new human acceptance gate or establish general Marine networking, separate-machine LAN or native builds.

24 October native-template probe: `python tools/build_demo.py --target windows --timeout 300` and `--target linux --timeout 300` both stopped before export with exit code 2 because the matching Godot 4.7.2 templates are absent at the configured template directory. The packaged PCK baseline remains the supported local artifact; no native target is reported as passed.

24 October tactical loopback re-audit: the same host/client lifecycle was rerun after the local tactical consolidation. It passed **6/6 processes** at `.tools/verification/20261024T075949863687Z/results.json` (mirror and tactical host/client pairs, `network: true`, `legacy_starter_staged: false`), including the tactical experiment-tracker checkpoints. This confirms the bounded loopback preservation gate remains stable; it does not establish separate-machine LAN reachability or human comprehension.

24 October tactical loopback tracker audit: the host/client lifecycle now explicitly checks that the tactical `training_experiments` metadata survives admission, the guest's authenticated deployment rejoin, the host's saved checkpoint and the completed-match checkpoint. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --network --only test_current_reference_match_network --timeout 300` passed **6/6 processes** at `.tools/verification/20261024T074056953079Z/results.json` (mirror and tactical host/client pairs, `network: true`). This is loopback evidence for snapshot preservation; it does not establish separate-machine LAN reachability or human comprehension.

24 October focused tactical recheck: the current-catalog tactical lifecycle and integrated combat gate passed **4/4 processes** at `.tools/verification/20261024T075744731933Z/results.json` (`network: false`, `legacy_starter_staged: false`). This rechecks the 0/4 checklist, legend, Captain ability, paid stratagem, plasma/Hazardous branches, save/resume marker and Bladeguard stance after the network checkpoint audit.

24 October tactical experiment progress: the guided Help panel now shows `PROGRESS: n / 4 observed` with `DONE = observed • OPEN = available` for the leader ability, CP stratagem, plasma/Hazardous and Bladeguard stance experiments. The checklist derives completion from authoritative ability/use records and committed attacks, persists its plasma metadata with the tactical match, starts at 0/4, and the focused regression now records a real Captain ability, paid stratagem, standard/supercharged/Hazardous combat branches and accepted Bladeguard stance, while verifying that the observed stratagem marker survives save/resume. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tactical_training --only test_tactical_combat_flow --timeout 300` passed **4/4 processes** at `.tools/verification/20261024T075744731933Z/results.json`. This is local presentation and combat-workflow evidence; it does not establish human comprehension, separate-machine LAN, remote CI or native platform support.

24 October human-gate refinement: the shared-computer playtest record and validator now require participants to understand the `PROGRESS: n / 4 observed` checklist as a separate gate, and every gate row must include a non-placeholder concrete observation note. The focused Python validator suite passed **25/25**; the launcher dry run created the new fields, and an unfilled, note-less or placeholder-note record correctly exits with code 2. No human result is claimed.

24 October tactical checklist legend: the Help panel now explains `DONE = observed • OPEN = available`, and the current tactical/combat gate passed **4/4 processes** at `.tools/verification/20261024T075744731933Z/results.json`. The full local demo with loopback passed **13/13** at `.tools/verification/20261024T080319927934Z/results.json`; the refreshed PCK passed all five export/startup/smoke stages at `.tools/verification/build-20261024T080456779917Z/results.json`. These remain local evidence and do not establish human comprehension, separate-machine LAN, remote CI or native platform support.

24 October Python compatibility sweep: `python -m unittest discover -s tests -p 'test_*.py'` passed **69/69 tests** after strengthening the tactical playtest-record validator to reject placeholder notes and require a concrete observation for every human gate. The focused verifier suite passed **25/25**. This covers the verifier, architecture checks and the record classification helper; it is Python tooling evidence only and does not replace Godot, human, network or native-platform gates.

24 October remote CI audit: [GitHub Actions run 17](https://github.com/cronosgp/open-tabletop/actions/runs/39658206740) failed in both Ubuntu and Windows jobs before import or any test. The merge revision used the older demo preflight, which required the ignored `data/imported/starter-11e-v1` snapshot and exited before producing reports. The current working-tree workflow and verifier now keep the demo allowlist data-free, run the current-catalog tactical gate and use the 300-second budget; those corrections still need a remote run on the actual revision before CI is reported green.

24 October command-panel opportunity cue: the tactical current-catalog workflow now repeats live Leader/CP/Bladeguard opportunities at the top of the open Command panel, while keeping the Help cue and legal-choice projection unchanged. The focused tactical test passed **3/3 processes** at `.tools/verification/20261024T060132409617Z/results.json`; the current targeted tactical/UI/layout run passed **5/5** at `.tools/verification/20261024T060650663369Z/results.json`. Actual OpenGL captures at 1280×800 and 1024×768 include `.tools/tactical-command-cue-1280.png`, `.tools/tactical-command-cue-1024.png`, `.tools/tactical-bladeguard-1280.png` and `.tools/tactical-bladeguard-1024.png`; preparation remains cue-free, and no action or CP is granted by the presentation label. Human comprehension is still untested.

24 October Bladeguard opportunity recheck: after adding the stance category to the live cue, the clean current-catalog tactical and combat workflow passed **4/4 processes** at `.tools/verification/20261024T060418114518Z/results.json` (`network: false`, `legacy_starter_staged: false`). The actual Bladeguard captures show the legal stance cue and the underlying effect/confirmation at both supported sizes.

24 October integrated tactical recheck: after the Command-panel cue, the clean current-catalog command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 300` passed **4/4 processes** at `.tools/verification/20261024T054411598872Z/results.json`, with `network: false` and `legacy_starter_staged: false`. This rechecks both the tactical lifecycle and integrated combat flow after the presentation change.

24 October full-demo recheck: after the data-free demo allowlist regression was added, `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile demo --network --timeout 300` passed **13/13 processes** at `.tools/verification/20261024T080319927934Z/results.json` (`network: true`, `legacy_starter_staged: false`). Startup, data-free catalog/model/rules suites and both loopback roles passed without cleanup diagnostics. This is still local loopback evidence; it does not establish separate-machine LAN or a native release.

24 October tactical distribution recheck: after the same current-tree validation, `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --target pack --timeout 300` passed `import`, `tactical-smoke`, `export`, `exported-startup` and `tactical-pack-smoke` at `.tools/verification/build-20261024T080456779917Z/results.json`. The exported PCK smoke test started `marine-tactical-training-v1` from the pack with the 290/235 current-reference forces, verified the title/guide surface and confirmed no false opportunity cue during preparation, without the historical starter snapshot. Native templates remain unavailable, so this is packaged local evidence rather than native platform validation.

24 October historical UI cleanup recheck: the targeted command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_stratagems --only test_combat_doctrines --only test_current_unit_abilities --timeout 300` passed **5/5 processes** at `.tools/verification/20261024T052827480848Z/results.json`. Import, Python checks and all three historical suites reported no RID/ObjectDB cleanup diagnostics. This supersedes the older diagnostic observations for these exact suites; other historical UI-heavy roles still require individual audits, and the profile stages the legacy snapshot by design.

24 October current-unit-abilities isolation: `test_current_unit_abilities` passed **3/3 processes** at `.tools/verification/20261024T052509406028Z/results.json`, also without cleanup diagnostics. The targeted profile stages the historical snapshot for this suite; it is separate from the clean current-catalog tactical gate.

24 October current-catalog focused recheck: after adding independent opportunity-category assertions, `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 300` passed **4/4 processes** at `.tools/verification/20261024T051708906412Z/results.json`. `network: false`, `legacy_starter_staged: false`; this is the clean current-catalog evidence for the tactical lifecycle and integrated combat flow.

24 October opportunity-category coverage: the tactical regression now checks the cue independently for a Leader ability, a CP stratagem and their combined presence, in addition to the live preparation/no-false-positive and Command-window assertions. The targeted UI/tactical/layout run passed **5/5 processes** at `.tools/verification/20261024T051108287971Z/results.json`; that mixed UI profile stages the pinned legacy snapshot for its historical guided-screen suite, while the clean current-catalog lifecycle is reported separately in the focused 4/4 result above.

24 October CI timeout hardening: `.github/workflows/verify.yml` now passes `--timeout 300` to the demo, focused tactical and PCK commands. The local verifier and export helper already passed with that budget; `python -m unittest tests.test_verification` passed **25/25**, including the data-free demo allowlist and the strengthened tactical playtest-record validator. This makes clean-run import/export latency less likely to mask a script result, but the corrected revision still needs a remote workflow run before CI is reported green.

24 October no-false-positive opportunity assertion: the tactical lifecycle now explicitly checks that `READY NOW` is absent during preparation, then appears once the current Command actor exposes a real leader/CP choice. The targeted UI/tactical/layout rerun passed **5/5 processes** at `.tools/verification/20261024T045833650964Z/results.json`; the earlier targeted report at `.tools/verification/20261024T043049887500Z/results.json` remains the first visual-cue gate. No action or CP is manufactured when the legal choice list is empty.

24 October legal-opportunity cue: the tactical Help panel now appends `READY NOW` only when the current actor's real `Combat.unit_choices` exposes a leader ability or CP stratagem. When neither is legal, the cue stays absent; no action or CP is manufactured. The targeted UI/tactical/layout run passed **5/5 processes** at `.tools/verification/20261024T043049887500Z/results.json`, the focused tactical/combat gate passed **4/4** at `.tools/verification/20261024T043527264205Z/results.json`, the complete local demo with loopback passed **13/13** at `.tools/verification/20261024T044536267699Z/results.json`, and the refreshed PCK passed import/export/startup at `.tools/verification/build-20261024T044821038334Z/results.json`. The first same-turn full-demo attempt at `.tools/verification/20261024T043832292929Z/results.json` failed only its concurrent host/client pair; the isolated network replay passed **4/4** at `.tools/verification/20261024T044319660501Z/results.json`, followed by the complete passing rerun. Actual Godot/OpenGL Help captures at 1280×800 and 1024×768 show `READY NOW — a CP stratagem is a legal choice` in `.tools/tactical-opportunity-1280.png` and `.tools/tactical-opportunity-1024.png`; the screenshots are rendered checkpoint evidence, not human comprehension or separate-machine LAN evidence.

24 October tactical focus after navigation increment: the exact current-catalog workflow `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 300` passed **4/4 processes** at `.tools/verification/20261024T042531813975Z/results.json`. This rechecks the paid Gladius choice, Captain ability, plasma/Hazardous branches, charge/contact, Bladeguard stance and five-round lifecycle after the title focus change. `network: false`, `legacy_starter_staged: false`; no separate-machine LAN or human playtest is implied.

24 October focus increment baseline: after adding the visible primary-action focus state, the complete local demo with loopback passed **13/13 processes** at `.tools/verification/20261024T040926105967Z/results.json` (`network: true`, `legacy_starter_staged: false`). The refreshed demo PCK passed import/export/startup with the extended build timeout at `.tools/verification/build-20261024T042305431456Z/results.json`. The selected logs contain no cleanup diagnostics. Human comprehension, remote CI, native platform and separate-machine LAN gates remain open.

24 October title-screen focus gate: the title now gives keyboard/gamepad focus to the first valid primary action—`Continue saved match` when a compatible save exists, otherwise `Start tactical training`; the in-match menu focuses `Return to current match`. The targeted layout/tactical rerun passed **5/5 processes** at `.tools/verification/20261024T040520503674Z/results.json`. Fresh Godot/OpenGL captures at 1280×800 and 1024×768 show the visible focus outline on the tactical-training fallback. This improves navigation access only; it does not alter match state or action admission.

24 October title-screen save fallback: when the local save belongs to another rules/data pack, the title now presents an actionable English summary ("Start a new match or tactical training") while preserving the exact compatibility cause in the control tooltip. The layout was inspected in actual Godot/OpenGL captures at 1280×800 and 1024×768; the targeted UI/tactical check passed **5/5 processes** at `.tools/verification/20261024T034645615678Z/results.json`. This improves recovery messaging only; it does not migrate or reinterpret the incompatible save.

24 October post-fallback local baseline: after the title-screen copy change, the complete local demo with loopback passed **13/13 processes** at `.tools/verification/20261024T035723040680Z/results.json` (`network: true`, `legacy_starter_staged: false`). The refreshed demo PCK passed import/export/startup at `.tools/verification/build-20261024T040053635428Z/results.json`. An earlier same-turn baseline at `.tools/verification/20261024T035047118938Z/results.json` failed only the concurrent loopback pair; the immediate isolated network replay passed **4/4** at `.tools/verification/20261024T035528936571Z/results.json`, and the complete rerun above passed. Human comprehension, remote CI, native platform and separate-machine LAN gates remain open.

24 October title-screen invitation: the tactical training summary now advertises the four exploration goals before launch (`abilities`, `CP stratagems`, `plasma/Hazardous` and `Bladeguard stances`) while retaining force totals and the asymmetric boundary. The targeted UI/tactical rerun passed **4/4** at `.tools/verification/20261024T033721330415Z/results.json`; actual title and preparation captures were regenerated and inspected at 1280×800 and 1024×768. The copy remains a prompt, not a tutorial grant or a rules bypass.

24 October final local baseline after the title copy: the complete local demo with loopback passed **13/13 processes** at `.tools/verification/20261024T033858358107Z/results.json` (`network: true`, `legacy_starter_staged: false`), and the refreshed PCK passed import/export/startup at `.tools/verification/build-20261024T034142681303Z/results.json`. The selected logs contain no cleanup diagnostics. Human comprehension, remote CI, native platform and separate-machine LAN gates remain open.

24 October historical local baseline after state-aware window guidance: the complete local demo with loopback passed **13/13 processes** at `.tools/verification/20261024T033100384150Z/results.json` (`network: true`, `legacy_starter_staged: false`), and the refreshed PCK passed import/export/startup at `.tools/verification/build-20261024T033325830841Z/results.json`. The selected logs contain no cleanup diagnostics. Later baselines are recorded above; human comprehension, remote CI, native platform and separate-machine LAN gates remain open.

24 October state-aware current-window cue: the Help panel now detects pending setup declarations through `unit_abilities.setup_players`, showing `PREPARATION` while Warlord/Leader choices remain and combat windows after setup. The targeted UI/tactical run passed **4/4** at `.tools/verification/20261024T032542677679Z/results.json`; fresh 1280×800 and 1024×768 captures show the complete list and the preparation cue. The cue is presentation-only and does not grant or force an action.

24 October current-window assertion correction (superseded by the state-aware cue below): the live tactical start enters `DEPLOYMENT` while setup declarations are still pending, so the interim focused regression asserted the actual `CURRENT WINDOW: DEPLOYMENT` text. It passed **4/4 processes** at `.tools/verification/20261024T032228096638Z/results.json`; the later state-aware implementation reports `PREPARATION` for that pending setup state.

24 October current-window guidance: the tactical Help panel now marks the phase-relevant experiment window (`PREPARATION`, `DEPLOYMENT`, `COMMAND`, `SHOOTING` or `CHARGE / FIGHT`) while keeping all four optional experiments visible. The copy was tightened after actual captures showed the fourth entry clipping at the supported sizes. The current targeted run passed **4/4 processes** at `.tools/verification/20261024T030347776122Z/results.json`; fresh Godot/OpenGL captures at 1280×800 and 1024×768 show the complete compact list in `.tools/tactical-experiments-1280.png` and `.tools/tactical-experiments-1024.png`. This improves discoverability only; it does not manufacture legal opportunities or bypass required choices.

24 October post-UI full baseline: after the current-window guidance and compact copy change, the complete local demo with loopback passed **13/13 processes** at `.tools/verification/20261024T031255406705Z/results.json` (`network: true`, `legacy_starter_staged: false`). The refreshed PCK passed import, export and exported startup at `.tools/verification/build-20261024T031702837608Z/results.json`. The selected logs contain no cleanup diagnostics; this remains local loopback/PCK evidence, not human, remote-CI, native-platform or separate-machine LAN evidence.

24 October cleanup ownership fix: the tactical settings panel is now owned by the tactical overlay for its full lifetime and hidden when unused; the guided experiment cards are rebuilt synchronously so queued controls cannot accumulate. A standalone verbose `test_tactical_training` run exited 0 with no `RID allocations`, `ObjectDB instances`, or post-tree `get_path` diagnostics. The targeted UI/layout/tactical gate passed **5/5** at `.tools/verification/20261024T024023701612Z/results.json`; the focused tactical/combat gate passed **4/4** at `.tools/verification/20261024T024356192993Z/results.json`; and the complete local demo with loopback passed **13/13** at `.tools/verification/20261024T024752131260Z/results.json`. The refreshed PCK import/export/startup check passed at `.tools/verification/build-20261024T025123740421Z/results.json`. This closes the previously observed cleanup diagnostics for the exercised current paths; historical UI-heavy roles still require their own audit.

24 October baseline recovery: the full local Windows demo rerun `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile demo --network --timeout 180` passed **13/13 processes** at `.tools/verification/20261024T021628518377Z/results.json` (`network: true`, `legacy_starter_staged: false`). It covers import, all 63 Python checks, startup, the builder/catalog/data/model/rules suites and both loopback network roles. The isolated network replay also passed **5/5** at `.tools/verification/20261024T021402438599Z/results.json`. The verifier's early-script-error regression now compares against its configured timeout instead of a fixed three-second wall-clock bound, removing a load-sensitive Windows false negative; this changes only the verifier assertion, not game admission.

24 October baseline diagnosis retained: the earlier full rerun at `.tools/verification/20261024T020552110151Z/results.json` exposed a loopback host/client failure, while `.tools/verification/20261024T021058991333Z/results.json` stopped in the Python precheck because that fixed three-second timing assertion fired under load. Both findings were investigated before the passing reruns above; no network delay or gameplay bypass was added.

24 October cleanup diagnostic: a standalone verbose run of `test_tactical_training` passed its gameplay assertions with exit code 0, but confirmed that the remaining shutdown diagnostics are UI/resource lifecycle issues. The log lists leaked `Label`, `Button`, `OptionButton`, `StyleBox`, texture/font and `ObjectDB` instances, plus `get_path` calls after controls leave the scene tree. Replacing the existing immediate test-scene cleanup with a longer deferred `queue_free` wait did not reduce the leak and was reverted. This remains a release-quality investigation item; it is not classified as a gameplay or network failure.

24 October current-tree confirmation: after reverting the cleanup experiment, the exact tactical workflow `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 180` passed **4/4 processes** at `.tools/verification/20261024T022729153285Z/results.json` (`network: false`, `legacy_starter_staged: false`). The report confirms that the tactical lifecycle and integrated combat behavior remain green; the tactical UI role retains the previously documented shutdown-only cleanup diagnostics.

24 October phase-labelled experiments: the four optional Help entries now identify their search phase (`COMMAND`, `COMMAND / REACTION`, `SHOOTING`, and `CHARGE / FIGHT`) so players can recognize when an ability, stratagem, plasma profile or Bladeguard stance can appear. The current-tree workflow passed **4/4** at `.tools/verification/20261024T023357461057Z/results.json` after a first import-only timeout at `.tools/verification/20261024T023029130313Z/results.json`; the retry used a 300-second import window and reached both Godot suites. Actual OpenGL captures at 1280×800 and 1024×768 were regenerated in `.tools/tactical-experiments-1280.png` and `.tools/tactical-experiments-1024.png`; both show the phase labels without clipping. The first timeout was import latency, not a gameplay or parser failure.

24 October tactical onboarding/coherency increment: the guided End-of-Turn text now names the required casualty removal when a unit is incoherent, and the tactical lifecycle resolves that decision through `MatchCommandService.REMOVE_COHERENCY` instead of treating the legitimate phase-close blocker as a test failure. The exact workflow step `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 180` passed **4/4 processes twice consecutively**, at `.tools/verification/20261024T015932087138Z/results.json` and `.tools/verification/20261024T020109940917Z/results.json` (`network: false`, `legacy_starter_staged: false`). The targeted guided-UI plus tactical rerun also passed **4/4** at `.tools/verification/20261024T015715766564Z/results.json`. Actual Godot/OpenGL captures at 1280×800 and 1024×768 were inspected in `.tools/tactical-experiments-1280.png` and `.tools/tactical-experiments-1024.png`; these demonstrate rendered Help layout and text only, not human comprehension or manual-input coverage. The capture harness reports shutdown renderer/ObjectDB cleanup diagnostics. Remote CI, native platform builds, LAN and human playtest remain pending.

24 October delivery recheck: `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --target pack` passed import, PCK export and exported startup at `.tools/verification/build-20261024T020338427290Z/results.json`. The generated artifact is the project-owned demo PCK baseline and does not certify a native Windows/Linux binary or the separate tactical-training network gates; the export-startup role retains shutdown-only renderer cleanup diagnostics.

23 October data-free baseline correction: `tools/verify.py` now classifies `test_army_builder` as data-free because the regression injects a synthetic catalog and does not invoke the optional historical training roster, despite that roster being preloaded by the builder UI. The local Windows baseline `--profile demo --network` passed **13/13 processes** at `.tools/verification/20261024T012307114690Z/results.json` (`legacy_starter_staged: false`), including import, Python checks, startup, builder/catalog/data/model/rules suites and the loopback host/client pair. Startup and UI/network roles retain known headless RID cleanup diagnostics only. The latest remote run for the older proposed revision, GitHub Actions run [39658206740](https://github.com/cronosgp/open-tabletop/actions/runs/39658206740), failed before tests because that revision still required the ignored legacy snapshot; a rerun on the corrected revision is required before remote CI can be reported as passing.

23 October workflow tactical step: the exact CI command `python tools/verify.py --profile focused --only test_tactical_training --only test_tactical_combat_flow --timeout 180` passed **4/4 processes** locally at `.tools/verification/20261024T013142498028Z/results.json` (`network: false`, `legacy_starter_staged: false`). This covers import, Python verification, the current-catalog training lifecycle and the integrated tactical combat regression; it is local evidence until the revised workflow runs remotely.

23 October loopback recovery rerun: `.tools/verification/20261023T225711261053Z/results.json` passed **6/6 processes** (isolated import, Python checks, current-reference host/client and tactical-profile host/client; `network: true`, `legacy_starter_staged: false`). The 550-point mirror completed deployment recovery, pending Fire Overwatch disconnect/rejoin, synchronized ranged combat and five-round scoring at revision 135 with matching canonical final-state hash `aa9107e190eb1a0417217e0be6f541018a80c7c8339d35c4ae280136a0d46d4f`. The asymmetric Fire and Manoeuvre versus Close Assault profile completed the same bounded lifecycle at revision 139 with points `{1: 290, 2: 235}`, score `{1: 0, 2: 0}` and matching canonical hash `e0688daa3a9ec54c00caa1a8993c4459bae67b27bfc5444d555493e779589f85`. The client wait now treats a received resolved attack as a valid checkpoint when Shooting and the attack arrive in one frame; this fixes a test phase-observation race without changing authoritative command admission. Headless renderer cleanup diagnostics remain in the raw role logs and are classified separately by the verifier. Separate-machine LAN, human playtest, remote CI and native platform validation remain pending.

The post-change local regression cross-check at `.tools/verification/20261023T225955186022Z/results.json` passed **7/7 processes** (`network: false`, `legacy_starter_staged: true`): import, Python checks, `test_match_actor`, `test_pending_decision`, `test_network_checkpoint`, `test_tactical_combat_flow` and `test_tactical_training`. This confirms the network wait correction and performance helpers did not regress the exercised local command, checkpoint, combat or tactical lifecycle paths.

23 October tactical-training checkpoint: the local lifecycle and integrated combat suites passed **4/4 processes** at `.tools/verification/20261023T154340821727Z/results.json` (`network: false`, `legacy_starter_staged: false`). They cover public setup/deployment/movement, paid Adaptive Strategy, Captain doctrine effect, standard/supercharged plasma and Hazardous allocation, charge/contact, Bladeguard stance ownership and actual attack modifier, melee completion, pending serialization and five-round progression. Controlled dice are confined to the combat regression. The lifecycle suite records headless shutdown diagnostics; the combat suite does not. Actual Godot title/preparation captures were inspected at 1280×800 and 1024×768; these are not human-played combat evidence.

The mirror and asymmetric tactical network variants passed **6/6 processes** at `.tools/verification/20261023T154216323174Z/results.json`, covering deployment recovery, pending Fire Overwatch recovery, synchronized ranged combat and five-round completion. The tactical guest also rejects stale revision, obsolete option and resolved-decision replay commands. The stricter final-state hash follow-up at `.tools/verification/20261023T155004428012Z/results.json` passed both tactical roles at revision 139 with matching final hashes, but failed mirror reconnection during Fire Overwatch: **4/6 passed, overall FAIL**. Mirror recovery repeatability is an open integration defect. This is bounded loopback evidence; it does not cover every locally checked combat interaction over the network. Separate-machine LAN was explicitly deferred by the user after SSH banner timeouts on 23 October. Human comprehension, remote CI and native platform builds remain pending. The project-owned demo PCK import/export/startup passed at `.tools/verification/build-20261023T152628350106Z/results.json`; this does not establish a tactical distribution or native binary. See the [training guide](../guides/tactical-training.md) for commands and scope.

Further 23 October diagnostics: `.tools/verification/20261023T155737133721Z/results.json` passed 6/6 with transport-event tracing, but `.tools/verification/20261023T160307400059Z/results.json` passed only 5/6 after a tactical raw final-hash mismatch. The raw mismatch has not established which values, if any, diverged. The test was strengthened with explicit snapshot acknowledgements, a delayed guest checkpoint, complete-state comparisons and canonical diagnostic hashes. The next run under `.tools/verification/20261023T160933388937Z/` confirmed the mirror recovery snapshots, then disconnected later and timed out; the tactical diagnostic was still running at this checkpoint and had also logged a disconnect. These are unresolved integration failures, not network passes. Local comparator and tactical lifecycle checks passed **4/4** at `.tools/verification/20261023T161020147309Z/results.json` (`network: false`, `legacy_starter_staged: false`), with tactical cleanup diagnostics. Actual Godot combat-checkpoint captures at 1280×800 and 1024×768 verified the selected Fire Overwatch label/CP cost wrapping and visible Bladeguard explanation/confirmation; these use reproduced controlled-dice states and do not establish human comprehension or manual input coverage.

Wardens of Ultramar passed **10/10 focused local processes** in `.tools/verification/20261019T211419295401Z/results.json`, covering per-model characteristics and weapons, construction admission and one-copy cap, Support links, Strategium Command reserve bypass, Raise the Banner, catalog publication, roster validation and Scouts regression. The final public-action integration and saved-army/catalog checks passed **8/8 processes** in `.tools/verification/20261019T212547325101Z/results.json`; adjacent leader, ability, capability and roster regressions passed **7/7 processes** in `.tools/verification/20261019T212717951667Z/results.json`. The catalog now publishes all 85 shared-book Marine identities. Network validation remains deferred to final integration; complete faction and army legality remain uncertified.

Gladius enhancements passed focused local checks in `tests/test_gladius_enhancements.gd`: source eligibility and local points, catalog and roster admission, additive Tactical Doctrine after Captain attachment, bearer-only 2+ Save/FNP and melee bonuses, and Standard bearer OC/Leadership/FNP plus the once-per-army attached-unit melee Attack effect. The companion `test_detachment_stratagems.gd` covers Armour of Contempt's actual attack trigger, 1 CP use, attacker binding and AP reduction. Network validation remains deferred; complete faction and army legality remain uncertified.

Ironclad Champions passed focused local checks in `tests/test_ironclad_champions.gd`: Dreadnought eligibility, 40/30-point enhancement admission, Enduring Vengeance and Venerable Champion hit rerolls in attack plans, Artificer Sarcophagus damage reduction, both Mercy is Weakness modes, Adamantine Terror's -1 Battle-shock modifier and Unstoppable Advance's Mobile movement declaration. Network validation remains deferred; complete faction and army legality remain uncertified.

All eight Space Marine transport sheets passed their focused profile, rule and admission checks in **23/23 local processes** in `.tools/verification/20261019T205749184284Z/results.json`. This covers transport admission/materialization, catalog, points, loadout options, attack sequence, passenger destruction, roster validation and saved armies. After adding explicit three-copy caps and fourth-copy rejections for all transports, the catalog, transport admission, roster and capability regressions passed **7/7 processes** in `.tools/verification/20261019T210109473257Z/results.json`. A separate `test_prepared_match` run still asserts `start_turn` immediately after deployment, while the current flow enters `pre_battle` and then resolves Scout Moves; it was outside these focused runs. Network validation was not run; complete faction and army legality remain uncertified.

Rhino passed **12/12 focused local processes** in `.tools/verification/20261019T204954010696Z/results.json`: isolated project import, offline Python checks, Godot startup, Rhino admission, catalog, Veiling Smoke, transport profiles, embark/disembark rules, passenger destruction and optional weapon regressions, capability metadata and current abilities. It is the 77th selectable shared-book Marine profile. Admission checks cover local prices through the third-copy tier, the three-copy limit, list admission and current-ability training materialization; the optional Hunter-killer remains a preparation choice. Network validation remains deferred; full faction and army legality remain uncertified.

Transport optional weapon handling and One Shot passed **19/19 focused local processes** in `.tools/verification/20261019T204041881249Z/results.json`: isolated import, offline Python checks, startup, One Shot, Land Raider/Rhino options, Impulsor options, Repulsor/Executioner replacements and cost, Machine Spirit, Repulsor Combat Embarkation, Drop Pod, Rhino Smoke, transport profiles/rules/destruction, attack sequence, capabilities, current abilities and catalog regressions. All source-listed transport additions and replacements in the current local profiles now enter the attack inventory. The eight transport identities remain excluded from construction pending cross-system reconciliation and admission checks. Network validation remains deferred.

Shared One Shot weapon handling passed **17/17 focused local processes** in `.tools/verification/20261019T203047596198Z/results.json`: isolated import, offline Python checks, Godot startup, attack sequence, capabilities, current unit abilities, runtime catalog, Drop Pod, Repulsor Executioner, Impulsor options, Machine Spirit, One Shot, Repulsor Combat Embarkation, Rhino Smoke, transport destruction, transport profiles and transport rules. The Hunter-killer Missile is consumed when declared; the same model's separate One Shot weapon remains usable, and a paused attack declaration cannot be duplicated. Network validation remains deferred and vehicle construction/admission remains incomplete.

Impulsor option handling and selector integration passed **16/16 focused local processes** in `.tools/verification/20261019T202103819622Z/results.json`: isolated import, offline Python checks, Godot startup, attack sequence, capability registry, current-unit abilities, local catalog, Drop Pod, Repulsor Executioner, Impulsor options, Machine Spirit rules, Repulsor Combat Embarkation, Rhino Veiling Smoke and shared transport checks. The Impulsor's three Bellicatus profiles are exposed as selectable attack choices and checked against their local weapon characteristics and a legal target. Network validation remains deferred; all eight transport profiles remain outside army construction pending cross-system and admission checks.

Land Raider Machine Spirit rules passed **15/15 local processes** in `.tools/verification/20261019T200949585102Z/results.json`: isolated import, offline Python checks, Godot startup, Machine Spirit effects and the transport, attack, capability, ability and catalog regressions. The new test covers optional one-hit/one-wound re-roll windows across an attack activation, target-distance and keyword limits for Crusader/Redeemer effects, and use limits across multiple target batches. Network validation remains deferred; all eight transport profiles remain outside construction pending outstanding options, interactions and admission checks.

Repulsor Combat Embarkation passed **14/14 local processes** in `.tools/verification/20261019T200146176150Z/results.json`: isolated import, offline Python checks, Godot startup, defender reaction and retargeting including the set-up-this-turn eligibility boundary, Repulsor Executioner, Drop Pod, shared transport rules/profiles/destruction, Rhino Veiling Smoke, capability metadata, attack sequence, current abilities and local catalog admission regressions. Network validation remains deferred; transport construction admission and full faction/army legality remain incomplete.

Lieutenant source reconciliation passed **7/7 local processes** in `.tools/verification/20261019T183235481116Z/results.json`: isolated import, offline Python checks, Godot startup, `test_combat_doctrines`, `test_current_unit_abilities`, `test_marine_lieutenant` and `test_roster_validation`. The profile and source-listed equipment choices are admitted from the consolidated local catalog; `.tools/marine-runtime-v108.json` exports the current audit set. Network validation remains deferred; full faction and army legality are uncertified.

Captain Titus passed **15/15 focused local processes** in `.tools/verification/20261019T181223215266Z/results.json`: isolated project import, offline Python checks, Godot startup, attack roll window, attack sequence, capability registry, Titus profile/effects, current unit abilities, implemented catalog, Kor’sarro regression, Leaders, roster validation, saved armies, Suboden Khan and weapon selection. The local catalog now publishes **74 selectable Marine identities**; five historical profiles remain excluded and 11 shared-book identities remain incomplete or unreconciled. Network validation remains deferred; full faction and army legality are uncertified.

Victrix Honour Guard passed **11/11 local processes** in `.tools/verification/20261019T172535463675Z/results.json`: isolated project import, offline Python checks, Godot startup, `test_victrix_honour_guard`, `test_cato_sicarius`, `test_implemented_catalog`, `test_current_unit_abilities`, `test_capabilities`, `test_core_reactions`, `test_roster_validation` and `test_saved_armies`. The consolidated local catalog now publishes **71 selectable Marine identities**, with five historical profiles excluded; `.tools/marine-runtime-v104.json` exports 56 profiles for audit. Network validation remains deferred; full faction and army legality are uncertified. At the time of this 19 October report, the admitted Victrix profile covered fixed Ancient+Champion compositions at 3 and 6 models; the role-composition follow-up is recorded in the 27 October closure below.

Cato Sicarius passed **11/11 local processes** in `.tools/verification/20261019T170840191227Z/results.json`: isolated project import, offline Python checks, Godot startup, `test_cato_sicarius`, `test_capabilities`, `test_core_reactions`, `test_current_unit_abilities`, `test_implemented_catalog`, `test_lieutenant_combi_weapon`, `test_roster_validation` and `test_saved_armies`. The catalog published 70 selectable Marine identities at that point, with five historical profiles excluded; runtime audit export `.tools/marine-runtime-v103.json` contained 55 profiles. Network validation remains deferred and full faction/army legality is uncertified. That run preceded Victrix and Calgar admission; both exact attachment and conditional Support checks are recorded in later results.

Chief Librarian Tigurius passed **10/10 local processes** in `.tools/verification/20261019T163756511821Z/results.json`: isolated project import, offline Python checks, Godot startup, `test_chief_librarian_tigurius`, `test_implemented_catalog`, `test_capabilities`, `test_current_unit_abilities`, `test_librarian_current`, `test_roster_validation` and `test_saved_armies`. The catalog publishes **68 selectable Marine identities**, with five historical profiles excluded; runtime audit export `.tools/marine-runtime-v101.json` contains 53 profiles. Fixed-data comparison remains deferred because the current comparison snapshot fails structural validation; network validation remains deferred and full faction/army legality is uncertified.

The Caanok Var increment passed **10/10 local processes** in `.tools/verification/20261019T162006558312Z/results.json`: isolated project import, offline Python checks, Godot startup, `test_caanok_var`, `test_implemented_catalog`, `test_capabilities`, `test_current_unit_abilities`, `test_terminator_squad_current`, `test_roster_validation` and `test_saved_armies`. The catalog publishes **67 selectable Marine identities**, with five historical profiles excluded; runtime audit export `.tools/marine-runtime-v100.json` contains 52 profiles. Fixed-data comparison is deferred because the current comparison snapshot fails structural validation; network validation remains deferred and full faction/army legality is uncertified.

The Iron Father Feirros increment passed **8/8 local processes** in `.tools/verification/20261019T154826639115Z/results.json`: isolated project import, offline Python checks, Godot startup, and `test_capabilities`, `test_current_unit_abilities`, `test_implemented_catalog`, `test_iron_father_feirros` and the shared `test_techmarine` regression. The catalog publishes **66 selectable Marine identities**, with five historical profiles excluded. Runtime audit export `.tools/marine-runtime-v99.json` contains 51 profiles. The last structurally validated fixed-data comparison `.tools/wahapedia-fixed-data-review-v97.json` predates Feirros and the later source profiles; the current comparison snapshot remains structurally invalid. Network validation remains deferred; full faction and army legality remain uncertified.

The Suboden Khan increment passed **4 targeted Godot suites**: `test_suboden_khan`, `test_implemented_catalog`, `test_capabilities` and `test_current_unit_abilities` (verification run `.tools/verification/20261019T140335885159Z/results.json`). The catalog publishes **65 selectable Marine identities**, with five historical profiles excluded. Runtime audit export `.tools/marine-runtime-v98.json` contains 50 runtime profiles. The last structurally validated fixed-data comparison, `.tools/wahapedia-fixed-data-review-v97.json`, covers 47 profiles / 208 weapon-trait profiles and predates Tor Garadon, Darnath Lysander and Suboden Khan. The currently available incomplete local snapshot was not accepted as validation. Network validation remains deferred; full faction and army legality remain uncertified.

After adding direct checks for Warlord eligibility, Transhuman Strategist CP and shooting after Advance, the updated `test_suboden_khan.gd` passed in a direct Godot 4.7.2 invocation. The subsequent aggregate retry did not start its suites because project import timed out. A separate attempt to include the broad `test_combat_doctrines` suite hit an existing script error at line 118 (`selection` missing) and timed out; that suite is not counted as passed.

The previous Captain increment passed its focused local check and regressions: `test_captain_current`, `test_current_unit_combat`, `test_marine_ability_boundaries`, `test_terminator_captain`, `test_captain_phobos`, `test_gravis_captain`, `test_current_unit_abilities`, `test_implemented_catalog`, `test_capabilities`, `test_roster_validation` and `test_saved_armies`. Captain's test covers the source profile and default loadout, alternate ranged profiles including both Plasma Pistol modes, independent Power Fist replacement, Relic Shield's extra wound and reset, supported Leader pairing, Warlord eligibility, Strategic Acumen and Transhuman Strategist. Existing Finest Hour attack and ability-boundary checks also passed. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v95.json` checked 46 profiles / 203 weapon-trait profiles, with zero numeric or identity differences and 45/46 bounded profiles consistent; Ancient in Terminator Armour's `DEATHWING` keyword context remains unresolved. Network validation remains deferred; full faction and army legality remain uncertified.

The previous Aethon Shaan increment passed **8/8 targeted processes** in `.tools/verification/20261019T123223000000Z/results.json`, covering Aethon's full listed ability set, core Heroic Intervention regressions, Terminator Captain regression, current unit abilities, catalog admission, capability metadata, UI turn choices and fixed-data comparison. The catalog then published 60 Marine identities. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v93.json` checked 46 profiles / 198 weapon-trait profiles; 45/46 bounded checks passed with zero numeric or identity differences. The sole unresolved bounded profile was Ancient in Terminator Armour's `DEATHWING` keyword context. Network validation remains deferred; full faction and army legality remain uncertified.

The Librarian increment passed **9/9 processes** in `.tools/verification/20261019T121509900605Z/results.json`: isolated import, Python checks, startup, capability metadata, broad current abilities, catalog admission, and focused tests for the base Librarian plus Phobos and Terminator Librarian regressions. The suite checks Veil of Time's Battle-shock and Advance replacement after the ordinary reroll window, Force Dome's unit-wide 4+ save and expiry, Psychic Hood, Librarius level-1 use, Leader and Warlord eligibility. The catalog then published 59 Marine identities. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v91.json` checked 45 profiles / 196 weapon-trait profiles; 44/45 bounded checks passed with zero numeric or identity differences. Network validation remains deferred; full faction and army legality remain uncertified.

The Kaius Konorius increment and catalog publication passed **5/5 processes** in `.tools/verification/20261019T115532567686Z/results.json`, covering isolated import, Python checks, startup and both the targeted profile/rules suite and consolidated-catalog admission suite. The catalog now publishes 58 Marine identities. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v89.json` checks 44 profiles / 192 weapon-trait profiles; 43/44 bounded checks pass with zero numeric or identity differences. Kaius passes all of his bounded source checks; the single unresolved profile is Ancient in Terminator Armour's `DEATHWING` keyword context. Network validation remains deferred; full faction and army legality remain uncertified.

The Adrax Agatone increment passed **10/10 processes** in `.tools/verification/20261019T114211481946Z/results.json`, covering import, Python, startup and seven focused/regression suites for Adrax, catalog publication, combat, unit abilities, roster validation, attack sequence and Terminator Captain. The Adrax test also verifies Transhuman Strategist grants one Warlord CP per battle round. Offline fixed-check tests passed 9/9 and Wahapedia slice tests passed 6/6. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v87.json` checks 43 profiles / 189 weapon-trait profiles; 42/43 bounded checks pass with zero numeric or identity differences. Network validation remains deferred; full faction and army legality remain uncertified.

The Captain on Bike increment passed **8/8 processes** in `.tools/verification/20261019T112505737398Z/results.json`, covering import, Python, startup and focused Captain, catalog, Chaplain on Bike, Outrider and Terminator regression checks. The Captain test covers its source weapons and options, Warlord eligibility, Outrider attachment, Into the Fray Cleave 1, and local 110-point admission. Offline fixed-check tests passed 9/9 and Wahapedia slice tests passed 6/6. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v85.json` checks 42 profiles / 187 weapon-trait profiles; 41/42 bounded checks pass with zero numeric or identity differences. Network validation remains deferred; full faction and army legality remain uncertified.

The Terminator Assault Squad increment passed **6/6 processes** in `.tools/verification/20261019T111723260184Z/results.json`, covering import, Python, startup and focused Assault Terminator, catalog and ordinary Terminator regression checks. The test covers 5/10 compositions and copy tiers, the Teleport Homer battle-start hook, the Storm Shield +1 Wound/+5-point replacement, and Terminatus Assault against infantry and Vehicle targets. Offline fixed-check tests passed 9/9 and Wahapedia slice tests passed 6/6. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v83.json` checks 41 profiles / 181 weapon-trait profiles; 40/41 bounded checks pass with zero numeric or identity differences. Network validation remains deferred; full faction and army legality remain uncertified.

The Chaplain on Bike increment passed **7/7 processes** in `.tools/verification/20261019T110640219017Z/results.json`, covering import, Python, startup and the focused profile/admission/Leader/Catechism test plus Chaplain, Land Speeder and catalog regressions. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v80.json` covers 40 profiles and 179 weapon-trait profiles; 39/40 bounded checks pass with zero numeric or identity differences. Offline Wahapedia fixed-check tests passed 9/9 and slice tests passed 6/6. Network validation remains deferred; full faction and army legality remain uncertified.

The Land Speeder increment passed **9/9 processes** in `.tools/verification/20261019T104954638154Z/results.json`, covering import, Python, startup, Land Speeder fixed data, Pyrecannon replacement, Purgation Run's after-shot D6 move/charge restriction, 53 selectable identities, reserve-flow regression, current ability regression, Lancer regression and roster admission. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v78.json` covers 39 profiles and 176 weapon-trait profiles; 38/39 bounded profile checks pass with zero numeric or identity differences. The sole unresolved bounded profile remains Ancient in Terminator Armour's shared-versus-chapter `DEATHWING` keyword context. Network validation remains deferred. A separate wider selection including `test_combat_doctrines` did not pass: its reference-army `.selection` lookup fails; that test is not counted in the 9/9 result.

The preceding Gladiator Valiant increment passed **8/8 processes** in `.tools/verification/20261019T101548046740Z/results.json`, covering its fixed profile and weapon instances, local admission, Priority Target Acquisition at in-range/out-of-range targets, melee exclusion, current ability regression, damage allocation and Marine fire-support regression. Its comparison was `.tools/wahapedia-fixed-data-review-v73.json`. Network validation remains deferred.

The Storm Speeder Thunderstrike increment passed **8/8 processes** in `.tools/verification/20261019T100916115351Z/results.json`, covering import, Python, startup, its profile and construction admission, ranged Wound modifier and melee exclusion, Shattered Defences target selection and AP effect, current ability regression, damage allocation and Marine fire-support regression. Its fixed-data comparison is `.tools/wahapedia-fixed-data-review-v72.json` (36 profiles, 163 weapon-trait profiles; 35/36 bounded checks consistent, zero numeric or identity differences). Network validation remains deferred.

# Local validation results

The Storm Speeder Hailstrike increment passed **8/8 processes** in `.tools/verification/20261019T095857106371Z/results.json`, covering import, Python, startup, Hailstrike profile/materialization, post-hit mark selection, cover behavior, the construction catalog, current ability regression, prior Driven from Cover behavior and damage allocation. The preceding Storm Speeder Hammerstrike increment passed 7/7 in `.tools/verification/20261019T095156133458Z/results.json`. The preceding Gladiator Reaper increment passed 13/13 in `.tools/verification/20261019T094130522668Z/results.json`, covering its profile/materialization, target filters, construction, army builder, saved lists, roster validation, abilities, attacks, capability metadata, actions and damage allocation. The Outrider Squad increment passed 12/12 in `.tools/verification/20261019T093253362330Z/results.json`, covering both formation sizes, equipment caps and both Full-throttle Assault branches. The prior Company Heroes increment passed 20/20; its 7/7 follow-up after Command Squad's unconditional -1 Wound modifier remains recorded in `.tools/verification/20261019T091716845473Z/results.json`.

Fixed-data comparison `.tools/wahapedia-fixed-data-review-v73.json` covers 37 runtime profiles and 168 weapon trait instances; it found zero numeric/identity differences and 36/37 bounded profile passes. Gladiator Valiant matches its four distinct weapon profiles, five physical weapon instances, uniform loadout, source keywords and tiered prices. Thunderstrike, Hailstrike, Hammerstrike and Gladiator Reaper retain their bounded profile passes. Ancient in Terminator Armour `DEATHWING` chapter context remains unresolved. The pinned export snapshot passes structural validation. Network validation remains deferred to final integration; full faction and army legality remain uncertified.

The prior Terminator pricing captures remain actual Godot runs inspected at 1280×800 and a 1024×640 rendered viewport; the latter preserves the project 16:10 aspect.

The Inceptor Squad increment passed **11/11 processes** in `.tools/verification/20261019T082438502854Z/results.json`, including 35 Python tests. Its historical fixed-data report is `.tools/wahapedia-fixed-data-review-v53.json` (30 profiles, 119 weapon trait profiles). Network validation was not run; full faction and army legality remain uncertified.
The earlier Space Marine transport rules increment passed **11/11 local processes** in `.tools/verification/20261019T194515038203Z/results.json`: isolated import, offline Python checks, Godot startup, Drop Pod Assault, transport profiles, embark/disembark, transport destruction, Rhino Veiling Smoke, implemented-catalog admission, action guidance and Smokescreen. Drop Pod reserve placement, first-round ingress, compulsory chained passenger disembark, the 8-inch enemy distance and Deployment Complete are checked from local Wahapedia source data. At that point the eight transport profiles were still excluded from the construction catalog; the later transport admission followup below supersedes that catalog status. Network validation remains deferred; full faction and army legality are uncertified.

The Firing Deck increment passed **8/8 local processes** in `.tools/verification/20261019T214320939718Z/results.json`: isolated import, offline Python checks, Godot startup, `test_marine_firing_deck`, `test_marine_one_shot`, `test_marine_transport_profiles`, `test_marine_transport_rules` and `test_marine_transport_weapon_options`. The focused test covers extracted Impulsor 7/Rhino 2 parameters, eligible passenger weapon options, already-shot model and One Shot exclusions, the one-profile-per-model limit, the Rhino model cap, transport attack resolution and end-of-turn passenger shooting locks. JSON metadata parsing also passed. Network validation was not run; full faction and army legality remain uncertified.

The local revalidation of four previously stale Marine capability records passed **7/7 processes** in `.tools/verification/20261019T214537649086Z/results.json`: isolated import, offline Python checks, startup, `test_ancients`, `test_gravis_captain`, `test_infiltrator_squad` and `test_terminator_ancient`. Source descriptions for Omni-scramblers, Helix Gauntlet, Refuse to Yield and Never Shall the Standard Fall were read from the local export; the capability registry now records the bounded e11 source and targeted-test status. Network validation was not run; this does not certify complete interactions or army legality.

Gladius source/behavior revalidation passed **5/5 processes** in `.tools/verification/20261019T214816526779Z/results.json`: isolated import, offline Python checks, startup, `test_combat_doctrines` and `test_detachment_stratagems`. All six stratagem rows linked to local detachment `000000750` and Codex Discipline row `000008355` were inspected in the Wahapedia export; capability records now describe the e11 effects and local validation. This corrected the Might of Angels registry summary: the stratagem grants Lance, whose core rule supplies the charge-dependent Wound bonus. The Gladius force-disposition/page-context discrepancy remains unresolved. Network validation was not run; full faction and army legality remain uncertified.

After consolidating those source/status updates, the combined Marine regression run passed **15/15 local processes** in `.tools/verification/20261019T215152941353Z/results.json`: isolated import, offline Python checks, Godot startup, capabilities, doctrines, detachment stratagems, Firing Deck, One Shot, transport profiles/rules/weapon options, Infiltrators, Gravis Captain and Ancient checks. This is bounded local evidence; network validation and full army legality remain uncertified.

Stormlance selection and Lightning-fast Strike passed **5/5 local processes** in `.tools/verification/20261019T220424916822Z/results.json`: isolated import, offline Python checks, Godot startup, capability metadata and Combat Doctrines tests. The local export identifies detachment `000000796` and ability `000008485`; +2 inches is applied only to Adeptus Astartes Mounted/Speeder units across their movement allowance. Setup blocks the unreconciled CA mission and checked-roster combination. The three Stormlance stratagems now have runtime implementation paths; their bounded status is below.

Direct Godot checks passed for `test_combat_doctrines.gd`, `test_detachment_stratagems.gd`, `test_attack_sequence.gd`, `test_movement_rerolls.gd` and `test_capabilities.gd`. Combat Doctrines checks cover Sudden Onslaught's fixed 6 without a D6 roll, Wind-Swift's post-fight eligibility, Movement characteristic plus Stormlance allowance, coherent Normal Move and Fall Back confirmations with end-window resume, and Hurtling Targets' pre-dice defender reaction and ranged -1 to Hit. Obstacle and crowded-base movement edge cases remain to cover. A missing `tyrant` state map found by the detachment suite was initialized, after which the suite passed. Network validation remains deferred; enhancements, mission compatibility, and full army legality remain uncertified.

19 October follow-up: Supercharged Engines and Auspex Triangulation Shrines now have local catalog, roster admission, points and match-effect paths. `test_stormlance_enhancements.gd` passed, covering exported eligibility and points, free Advance reroll, a single Auspex target per bearer per Shooting phase, target range, and persistent spotted detection. Network validation remains deferred to final integration; full army legality remains uncertified.

19 October follow-up: Assault Mastery passed the extended `test_combat_doctrines.gd` local suite. The checks confirm one additional Assault Doctrine selection is fixed to Assault, does not grant extra Tactical/Devastator uses, and cannot be used a third time. Network validation remains deferred; full army legality remains uncertified.

19 October follow-up: Death Blow and Codex Fire-patterns passed local checks in `test_combat_doctrines.gd`. Checks cover the Terminator-only charge bonus (including enemy/non-Terminator exclusions) and Tacticus Rapid Fire through maximum weapon range, including the range boundary. Network validation remains deferred; neither result certifies full army legality.

19 October follow-up: Wrath of the Chapter, Walking Fortress and Dutiful Tenacity passed targeted local checks in `test_combat_doctrines.gd`. Coverage includes Wrath's free post-roll Tacticus Advance reroll, Walking Fortress's Gravis Normal Move attack effect (Heavy removed and +1 to Hit), and Dutiful Tenacity's strict Strength-greater-than-Toughness threshold and friendly Infantry target. Network validation and complete Dark Angels army legality remain pending.

19 October follow-up: all six Spearpoint stratagems passed focused checks in `test_spearpoint_stratagems.gd`; `test_suboden_khan.gd` now also checks Storm-swift Onslaught's post-Advance/Fall Back charges and Wrath of the First Khan's destroyed-enemy trigger and 6-inch move window. Network validation, full White Scars detachment legality and remaining Mobile/terrain interactions remain pending.

19 October follow-up: all four Spearpoint enhancements passed focused checks in `test_spearpoint_enhancements.gd`. Coverage confirms local export eligibility and points, free Stormseer's Wisdom Advance reroll, Chogorian Huntmaster's round 1 ingress permission, Hunter's Eye ranged traits, and Spearpoint Paragon's bearer-only Strength/AP bonuses before and after a Charge move. Network validation and full White Scars/faction legality remain deferred.

19 October follow-up: Ironstorm Auto-targeters now enters prepared-match selection and grants an eligible friendly Adeptus Astartes Vehicle unit, excluding Walkers, one optional Hit and one optional Wound re-roll per ranged attack activation. `test_marine_machine_spirits.gd`, `test_combat_doctrines.gd` and `test_capabilities.gd` passed locally; the Godot editor import/parse check passed. Checks cover Storm Speeder eligibility, Redemptor/Intercessor exclusions, both source-labelled choices, once-each use and the existing Land Raider re-roll flow. `test_prepared_match.gd` still reports its deployment-scoring assertion failure; it is not included as a pass. Network validation and full army legality remain deferred.

19 October continuation: Ironstorm enhancements Redoubtable Machine Spirit and Gunnery Honours now use the local points and enhancement-to-datasheet rows, intersected with the local datasheet role and keywords. `test_ironstorm_enhancements.gd` passes: it checks 25/15-point admission, Transport/Walker exclusion, the 5+ invulnerable save, one wound restored at actual Command-phase transition, ranged Heavy, and melee exclusion. Regression checks passed for `test_spearpoint_enhancements.gd`, `test_combat_doctrines.gd`, `test_capabilities.gd`, `test_marine_machine_spirits.gd` and Godot editor import. Network validation, the three Ironstorm stratagems, and full army legality remain pending. A headless screenshot could not be captured because this Godot runtime uses the dummy renderer, which exposes no viewport texture.

19 October continuation: implemented local runtime paths for the three Ironstorm stratagems from Wahapedia export rows `000008479002`–`000008479004`. Headhunter opens at the declared shooting attack before its profiles are rebuilt; Might records the owner's next Command phase expiry and suppresses the runtime's Move/Hit/Wound modifiers; Layered Ceramite adds a pre-allocation choice for the currently implemented mortal-wound sources. The source text also names BS modifiers, which the current combat engine does not model directly. The local ledger JSON parses and `git diff --check` reports no whitespace errors. No gameplay tests were added or run, per the current task instructions. Godot import/parse could not be run because no Godot executable is available on PATH or in the checked application directories. Focused local validation remains pending; network validation and full army legality are deferred.

19 October continuation: added a runtime path for Phobos Shock Force's Vanguard Ambushers from local Wahapedia row `000011195`. At the end of the owner's Movement phase, a friendly unit with the PHOBOS keyword whose living models are hidden model-by-model in current terrain receives Wound rerolls of 1 for Shooting and Fight attacks through that turn. The detachment is selectable; its other enhancements and stratagems remain pending. No gameplay tests were added or run. Local validation, network validation and full army legality remain pending.

20 October follow-up: the local Wahapedia 11e export (`faction_id=SM`, source book `000000139`) maps all 85 runtime identities to unique datasheet IDs. The 65 existing runtime IDs were checked against source IDs/names; the other 20 were mapped by unique names. The identity audit records the stable `2026-10-19 03:47:32` update marker and hashes for all 23 snapshot files. This is identity-only reconciliation: no runtime stats, options, abilities or legality were compared or inferred; six fixed profiles retain their earlier direct data comparison, and zero full datasheet scopes are validated.

Vanguard Ambushers remains unsupported and is not admitted into a match. Its previous per-model Hidden eligibility path was removed because the source says a PHOBOS unit is Hidden and that condition is not reconciled with the local model-level terrain helper. The fixture-free rule-context test checks the blocked capability gate, the current-turn mark's Shooting/Fight resolver scope, expiry, detachment/phase boundaries, and the wound-reroll-1 predicate without a hit reroll. It does not exercise the Movement trigger, unit Hidden eligibility or a complete attack integration. `& .\.tools\godot-4.7\Godot_v4.7-stable_win64_console.exe --headless --path . --script .\tests\test_vanguard_ambushers.gd` passed with 0 failures. The capability-registry suite `& .\.tools\godot-4.7\Godot_v4.7-stable_win64_console.exe --headless --path . --script .\tests\test_capabilities.gd` reached two failures because the starter-pack manifest is missing in this worktree; it is not a passing regression run. Network validation remains deferred; full army legality is uncertified.

Repulsor Executioner's rules and transport profile attack normalization passed **13/13 local processes** in `.tools/verification/20261019T195112042550Z/results.json`: isolated import, offline Python checks, Godot startup, Executioner threshold, Drop Pod Assault, transport profiles/rules/destruction, Rhino Veiling Smoke, capability metadata, attack sequence, current abilities and implemented-catalog admission. The focused Executioner check also passed again after adding an exact half-strength boundary case. Network validation remains deferred; transport construction admission and full faction/army legality remain incomplete.


22 October A1 continuation: `test_tempered_in_battle.gd` and `test_movement_types.gd` passed for post-move Desperate Escape: the result waits for the optional full 2D6 reroll, the decision and suspended movement frame survive serialization, phase close is blocked while pending, and movement resumes afterward. Later entries below record the remaining contexts and final admission change. This is local evidence, not full rules certification or Dark Angels legality.


22 October A1 Tempered in Battle Fearsome Assault continuation: `test_reiver_squad.gd` passed with 0 failures. At the time, the test injected the then-blocked enhancement into an isolated opposing Astartes test unit. It verified that the Fight-start Leadership result stayed unapplied while pending, routed the keep/reroll choice to the target controller, round-tripped the decision/frame through serialization, rejected phase close, rerolled both dice with the Fearsome Assault -1 modifier, and resumed with the result recorded. Source: [Wahapedia Reiver Squad 11e](https://wahapedia.ru/wh40k11ed/factions/space-marines/Reiver-Squad).

22 October A1 Tempered in Battle Adamantine Terror continuation: `test_ironclad_champions.gd` passed with 0 failures. The earlier synthetic opposing-detachment case confirms sequential target processing, one CP spend, controller-owned rerolls, serialized pending results, and phase-close blocking. `test_tempered_in_battle.gd` and `test_per_player_detachments.gd` now pass with the enhancement selected in an admitted roster and separate Wrath/Ironclad assignments in a normal prepared match. The no-Core-Stratagem Command fallback also suspends, survives serialization, and resumes after the reroll. Focused local checks passed for `test_tempered_in_battle.gd`, `test_per_player_detachments.gd`, `test_combat_doctrines.gd`, `test_detachment_stratagems.gd`, `test_capabilities.gd`, `test_reiver_squad.gd`, `test_ironclad_champions.gd` and `test_wrath_of_the_rock.gd`. A headless run of `test_prepared_match_network.gd` could not connect its RPC peers and was stopped; network validation remains deferred. Full Dark Angels army legality remains uncertified. Sources: [Wahapedia Space Marines 11e](https://wahapedia.ru/wh40k11ed/factions/space-marines/), [Wahapedia Core Rules 11e](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/).

22 October bounded-match integration follow-up: `test_local_match_vertical_slice.gd` completed with **0 failures**. It starts the two 550-point current-catalog Space Marines training lists, completes setup and deployment, legally deploys P1 Terminators in the Rubble objective, commits a Normal Move, saves and resumes the exact state/RNG/journal, then completes five rounds at **5–0** on `objective-training-v1` / `saved-army-training-43x43-v1`. This is a custom, restricted training match; it does not certify army legality, other objective interactions, or official mission support. `test_current_reference_match_network.gd` passed on both host and client in loopback at revision 96: the host saved and checked a checkpoint, the guest disconnected and reclaimed its authenticated seat, both players completed deployment, P1 held Rubble, both sides synchronized the 5–0 result, and the host saved and re-read the completed state, RNG state and journal. The combined clean targeted run passed **5/5 processes** in `.tools/verification/20261022T194122434093Z/results.json` (import, Python checks, local match, network host and network client). UI-heavy Godot process logs retain `headless_rid_cleanup_diagnostics: true`; the report records these baseline shutdown diagnostics, while script/runtime errors and nonzero exits remain fatal. The runner stages the legacy starter for this targeted match suite (`legacy_starter_staged: true`), a remaining dependency to investigate. Loopback is not separate-machine LAN evidence; no cross-machine run has been completed. Broader objective interactions and cross-machine recovery remain open.

22 October local match follow-up: the bounded local slice now also commits and records a legal ranged attack through the live match command service before its save checkpoint. After resuming, it verifies the exact saved state, RNG continuation and journal, then completes all five rounds and the 5–0 result. The combined targeted verification passed **5/5 processes** in `.tools/verification/20261022T195145989199Z/results.json`. The paired loopback run remains the prior movement-only network profile; it does not yet prove shot synchronization or a two-computer match. `legacy_starter_staged` remains `true`, so this targeted run still stages the historical snapshot and needs dependency cleanup before it is fully independent of that input.

22 October clean-input probe: the two current-reference match suites were run from an isolated project without staging the legacy starter and failed during setup with `Import starter data first: Cannot open manifest.` The failure comes from `PreparedTraining.initial_state()` creating temporary templates with `Combat.initial_state()` before the current saved lists replace them. The list admission uses current Space Marine profiles, but this bootstrap still makes the current match flow depend on the historical starter. No source or verification claim treats the clean-input attempt as a pass; remove this dependency before calling the local slice self-contained.

22 October clean-input follow-up supersedes the failed probe above: current-catalog Space Marine saved lists now bypass the historical starter for admission, and prepared matches use current sourced Marine templates for their temporary state. The legacy template and Necron training route remain available for historical exercises. `test_local_match_vertical_slice` and both loopback host/client roles passed from an isolated project with `legacy_starter_staged: false` in `.tools/verification/20261022T200655514943Z/results.json` (**5/5 processes**). The local case includes a legal ranged attack before save/resume; at that point the loopback case was movement-only. `test_saved_armies` and `test_capabilities` passed in `.tools/verification/20261022T200546005520Z/results.json` (**4/4 processes**, with the legacy starter staged for the legacy Necron assertions), confirming that the historical training price path remains intact.

22 October loopback network follow-up: `test_current_reference_match_network` passed **4/4 processes** in `.tools/verification/20261022T201651801575Z/results.json` using the clean focused profile with `legacy_starter_staged: false`. The five-round host/client match now includes a legal host ranged attack whose resulting revision and attack pools are observed by the guest, in addition to the existing deployment checkpoint, guest disconnect/rejoin, continued play, final scoring, and host save/journal checks. The attack occurs after the existing reconnect checkpoint; recovery from a pending decision and separate-machine LAN reachability remain unverified. A same-host attempt using the host's LAN IPv4 did not authenticate the client and is not evidence for or against cross-machine reachability. The cross-machine exercise is documented in [verification instructions](verification.md).

22 October pending-decision network follow-up supersedes the recovery limit above: `test_current_reference_match_network` passed **4/4 processes** in `.tools/verification/20261022T203002775730Z/results.json` using the focused clean-input profile (`legacy_starter_staged: false`). The host saves an open Fire Overwatch decision and suspended phase-close frame; the guest disconnects, reclaims its authenticated seat, and confirms that the exact decision identity, legal options, owner and continuation return before declining. The match then synchronizes a legal ranged attack, completes five rounds at 5–0, and verifies the host's final save and journal. Both role logs report revision 135. Each process took about 92 seconds, so this targeted runner invocation used `--timeout 120`. This is loopback evidence for the bounded training profile only; the same recovery and match remain unverified between separate computers.

22 October implementation follow-through: the broad local targeted batch passed **46/46 processes** across 44 selected Godot suites in `.tools/verification/20261023T012414902042Z/results.json` (`network: false`, `legacy_starter_staged: true`). It includes mission and unit-choice help, guided-turn and action-guidance UI, phase/decision and combat regressions, the bounded five-round local match, and the focused current Space Marines slices. The run caught two UI issues which were fixed: an attack-plan draft could leave its cancel button inside a closed command panel, and mission-preparation guidance was hidden behind army-preparation controls. The verification runner now stages the legacy starter for the allocation-practice UI suite that starts its state through `main.tscn`; the mission-choice help test uses current Marine templates and the selected CA mission setup.

After those fixes, the two-process current-reference loopback passed **4/4 processes** in `.tools/verification/20261023T013146474077Z/results.json` (`legacy_starter_staged: false`). Host and client both report revision 135, eight committed deployments, 550 points per side and the same 5–0 result. This rerun covers pending Fire Overwatch save/recovery, guest seat reclaim, attack synchronization, completed save and journal checks. It is local loopback evidence only; separate-machine LAN remains deferred to final integration.

22 October local integration consolidation: the first focused run caught a save/resume rejection for a current CA mission match. The save configuration was comparing only active Marine owners against the full per-player detachment declaration recorded in the immutable match manifest; it now preserves and validates that declared map. `test_chapter_approved`, `test_per_player_detachments`, `test_saved_armies` and `test_capabilities` then passed. The broader focused local run passed **21/21 processes** in `.tools/verification/20261023T005034774757Z/results.json`, including pending-decision/resolution frames, phase close, the local five-round match, guided-turn UI, current Marine increments and saved-list regressions. The targeted aggregate stages the legacy starter for historical saved-army assertions; the current-catalog match suite itself does not depend on it. The two-local-process host/client loopback lifecycle passed **4/4 processes** in `.tools/verification/20261023T010428064008Z/results.json` with `legacy_starter_staged: false`; both roles report revision 135 and the same 5–0 result after pending Fire Overwatch recovery, ranged attack synchronization, final save and journal checks. The local test waits for the guest's final assertions before closing the host. No separate-machine LAN validation was run; it remains deferred to final integration.

23 October A2 continuation: phase and command admission now explicitly reject a non-empty pending Deadly Demise destruction chain, even when its UnitActions choice window is absent. The pending queue remains covered after state serialization. `test_phase_close_gate` and `test_marine_transport_destruction` passed with the targeted verification profile: 4/4 processes including isolated import and Python checks, recorded at `.tools/verification/20261023T013633981926Z/results.json`. This hardens a local close/command invariant; it does not change rules eligibility or add network evidence.

23 October A2 continuation: normal Transport disembarkation now opens a persisted `transport-disembark` resolution frame spanning Hazard allocation, save/resume and passenger placement; confirmation closes the frame. Drop Pod compulsory disembarkation continues under its existing phase-start path, and transport destruction remains nested in its attack continuation. The focused local verification passed **6/6 processes** (import, Python, `test_marine_transport_rules`, `test_marine_drop_pod`, `test_marine_transport_destruction`, `test_phase_close_gate`) at `.tools/verification/20261023T014052103017Z/results.json`. The run also exposed a Drop Pod fixture with a missing optional `battle_shocked` field; detachment eligibility now reads that state with the same false default used by sibling paths. This is local evidence only; no LAN validation was run.

23 October A2 follow-up: the normal Transport disembark frame now also completes automatically when Hazard removes every passenger, so no-choice resolution does not leave a suspended action behind. A repeat targeted run passed **5/5 processes** (`import`, Python checks, `test_marine_transport_rules`, `test_marine_drop_pod`, `test_marine_transport_destruction`) at `.tools/verification/20261023T014248671624Z/results.json`; the immediately preceding 6/6 run also passed `test_phase_close_gate` after adding this no-choice assertion. The full focused set is local only and does not establish separate-machine LAN behavior.

23 October A2 continuation: Drop Pod Assault now creates one persisted `transport-drop-pod-assault` frame after ingress and carries it across each compulsory passenger placement. The exact frame identity survives serialization; intermediate passengers keep the same frame, and the final passenger or automatic no-survivor path completes it. Emergency disembark remains under its attack continuation. Final targeted verification passed **6/6 processes** (import, Python checks and four transport/phase-close suites) at `.tools/verification/20261023T014653904036Z/results.json`. This is local workflow evidence only; separate-machine LAN validation remains deferred.

23 October A2 continuation: all reserve/Rapid Ingress previews now suspend a `unit-action` frame. Save/resume preserves its identity; cancel closes the frame and restores the previous window; confirmation completes it. For opponent Rapid Ingress, the frame nests under phase close and returns to that parent when ingress ends. When ingress brings in a Drop Pod, Drop Pod Assault nests another frame beneath ingress and keeps both until every passenger finishes or the no-choice path resolves. The targeted local run passed **7/7 processes** (import, Python checks, `test_unit_reserves`, `test_marine_drop_pod`, `test_marine_transport_rules`, `test_marine_transport_destruction`, `test_phase_close_gate`) at `.tools/verification/20261023T015054933771Z/results.json`. This is local workflow evidence; no LAN test was run.

23 October A2 follow-up: the Drop Pod Assault local checks now explicitly force a Hazard failure that kills the first passenger, then verify automatic progression to the next passenger under the same saved frame and clean frame completion after the remaining passenger. The focused verification passed **7/7 processes** in `.tools/verification/20261023T015334296436Z/results.json`, including import, Python checks, reserves/Ingress, Drop Pod, normal transport, transport destruction and phase-close suites. `git diff --check` passed. LAN testing between separate machines remains deferred; this run used the local Godot verification profile.

23 October A2 close-gate follow-up: common command admission now blocks on raw transport resolution state even if its mirrored UnitActions window is missing, and a non-empty UnitActions window with a missing/invalid owner projection fails closed for commands and phase close. The focused verification passed **7/7 processes** at `.tools/verification/20261023T015628054802Z/results.json` (import, Python checks, phase-close gate, reserves/Ingress, Drop Pod, normal transport and transport destruction). No network checks were run.

23 October A2 gate hardening: after the broader 7/7 transport/Ingress regression, the UnitActions ownership check was tightened to require a numeric player ID of 1 or 2; an empty owner list and an invalid owner now both fail closed. The final focused phase-close verification passed **3/3 processes** (import, Python checks and `test_phase_close_gate`) at `.tools/verification/20261023T015804373638Z/results.json`. The immediately preceding 7/7 run at `.tools/verification/20261023T015628054802Z/results.json` covered the same gate change with the transport/Ingress suites before this final owner-validation refinement. No network checks were run.

23 October A2 verification addendum: the final `test_phase_close_gate` case also covers a pending UnitActions window with a valid player but no decision kind. The gate suite passed again **3/3 processes** (import, Python checks and `test_phase_close_gate`) at `.tools/verification/20261023T015857948974Z/results.json`.

23 October A2 action-admission follow-up: ordinary commands now fail closed when any persisted resolution frame remains, including an orphaned frame with no specialized pending record. The phase-close route retains its matching continuation entry, and the player who owns a supported Core reaction can still perform the validated reaction action under the suspended phase-close frame. The first regression run exposed Fire Overwatch shooting being blocked; after adding the narrowly scoped Core-reaction continuation, all focused suites passed **9/9 processes** in `.tools/verification/20261023T020155781968Z/results.json`: import, Python checks, `test_phase_close_gate`, `test_core_reactions`, `test_attached_reanimation`, `test_unit_reserves`, `test_marine_transport_rules`, `test_marine_drop_pod` and `test_marine_transport_destruction`. This is local workflow evidence; no network tests were run.

23 October A2 nested-frame follow-up: `ResolutionFrames.begin` now refuses a child while its parent is resolving; the caller must suspend the parent first. Opponent Rapid Ingress now suspends the real phase-close parent before opening its unit-action frame. Common command admission permits continuation through a suspended frame only when the command carries the matching Movement/Charge action ID; other commands remain blocked, while phase-close and authorized Core reaction continuations retain their dedicated paths. The first integration run exposed movement/charge continuation commands and synthetic fixtures with stale or missing feature state; those callers and fixtures were corrected. The focused combined verification passed **19/19 processes** at `.tools/verification/20261023T021448812440Z/results.json`: import, Python checks, resolution-frame and phase-close gates, core reactions, Reanimation, reserves/Ingress, Drop Pod and transport workflows, Movement/Charge rerolls, Hammer of Wrath, Chaplain, Apothecary, Combat Doctrines, Reiver, Tempered in Battle and detachment stratagems. This is local evidence; network checks were not run.

23 October A2 admission hardening: Core reaction ownership no longer bypasses an active resolution-frame gate. Only the current actor's validated Overwatch shot or Heroic Intervention charge declaration can enter through the matching suspended phase-close frame identity; unrelated commands remain blocked. The focused verification passed **4/4 processes** (import, Python checks, `test_phase_close_gate` and `test_core_reactions`) at `.tools/verification/20261023T022252765101Z/results.json` (`network: false`). This is local admission evidence; no two-client or separate-machine network check was run.

23 October A2 pending-owner validation: command admission now rejects UnitActions windows unless the entire owner list contains distinct player IDs 1 and 2. Mixed valid/invalid and duplicate owners block ordinary commands and phase close without mutating match state. The focused verification passed **3/3 processes** (import, Python checks and `test_phase_close_gate`) at `.tools/verification/20261023T022456299445Z/results.json`; network checks were not run.

23 October A2 Fight-contact continuation: pile-in, overrun and consolidation placement now suspend a persisted contact frame through each staged segment and complete it on confirmation or cancellation. The frame and pending action identity survive save/resume; an older contact draft without a frame reconstructs its continuation when a matching placement command resumes it. Common admission also blocks unrelated commands against raw pending Movement, Charge or contact records when the frame is absent, while allowing only the matching continuation identity. The combined focused verification passed **6/6 processes** (import, Python checks, `test_phase_close_gate`, `test_contact_actions`, `test_core_reactions` and `test_movement_rerolls`) at `.tools/verification/20261023T023146815394Z/results.json` (`network: false`). `test_movement_rerolls` passed with Godot shutdown RID cleanup diagnostics recorded in its log; no gameplay assertion or process failure occurred. This is local workflow evidence only.

23 October A2 malformed-draft follow-up: Movement, Charge and contact continuation handlers now read pending action identity through type-checked helpers before calling admission, so malformed persisted values reach the fail-closed gate without being dereferenced. Phase close validates those same pending values before checking whether they are empty. Regression cases exercise the public finish/decline handlers and phase-close route. The combined focused verification passed **6/6 processes** (import, Python checks, `test_phase_close_gate`, `test_contact_actions`, `test_core_reactions` and `test_movement_rerolls`) at `.tools/verification/20261023T023539534531Z/results.json` (`network: false`). This is local workflow evidence only.

23 October A2 persisted-decision type audit: common admission now validates pending Deadly Demise, Hazardous and damage-allocation records before pending-decision projection or actor resolution. Both command entry and phase close fail closed for a malformed record. The combined focused verification passed **6/6 processes** (import, Python checks, `test_phase_close_gate`, `test_contact_actions`, `test_core_reactions` and `test_movement_rerolls`) at `.tools/verification/20261023T023737561834Z/results.json` (`network: false`). This is local workflow evidence only.

23 October A2 phase-close input audit: the close route now validates the outer UnitActions container and nested transport window before querying detection selection or transport work. Regression cases cover malformed outer and nested state. The combined focused verification passed **6/6 processes** (import, Python checks, `test_phase_close_gate`, `test_contact_actions`, `test_core_reactions` and `test_movement_rerolls`) at `.tools/verification/20261023T023855958810Z/results.json` (`network: false`). This is local workflow evidence only.

23 October A2 allocation-dispatch audit: the specialized attack-allocation command now validates pending-state types and refuses to continue while Deadly Demise, transport placement or a UnitActions decision is pending, before building the defender allocation projection. This closes a dispatcher bypass where an absent destruction choice projection could allow damage allocation to resume prematurely. The focused verification passed **7/7 processes** (import, Python checks, `test_phase_close_gate`, `test_damage_allocation`, `test_core_reactions`, `test_attached_reanimation` and `test_marine_transport_destruction`) at `.tools/verification/20261023T024112375075Z/results.json` (`network: false`). This is local workflow evidence only.

23 October A2 destruction-choice dispatch audit: unit-choice dispatch now refuses unrelated legacy choices while a Deadly Demise chain is active and its normalized destruction/emergency-disembark option is absent. Attack allocation and unit-choice paths both remain usable for their matching projected options. The combined focused verification passed **7/7 processes** (import, Python checks, `test_phase_close_gate`, `test_damage_allocation`, `test_core_reactions`, `test_attached_reanimation` and `test_marine_transport_destruction`) at `.tools/verification/20261023T024322154952Z/results.json` (`network: false`). This is local workflow evidence only.

23 October A2 unprojected unit-choice audit: when no normalized decision exists, unit-choice dispatch now calls common command admission before applying a legacy immediate choice. A regression reproduces an attacker attempting Ancient Exhortation while the defender owns suspended damage allocation; the command is rejected without changing state, while the current Fight actor can still use the choice when no pending work exists. The combined focused verification passed **8/8 processes** (import, Python checks, `test_gladius_enhancements`, `test_damage_allocation`, `test_phase_close_gate`, `test_combat_doctrines`, `test_oath_of_moment` and `test_marine_transport_destruction`) at `.tools/verification/20261023T024753488877Z/results.json` (`network: false`). The strengthened Ancient Exhortation regression was rerun standalone and passed after the combined run.

22 October A2 unit-choice projection guard: the command service now validates the persisted UnitActions container, transport window and decision-owner list before building a unit-choice projection. This prevents malformed saved windows or owner lists from crashing decision projection and returns a fail-closed command error without mutating match state. The shared validation is reused by command admission. The targeted verification passed **3/3 processes** (import, Python checks and `test_phase_close_gate`) at `.tools/verification/20261023T025259368540Z/results.json` (`network: false`). This is local admission evidence only.

22 October A2 persisted reaction-state guard: common command admission and the specialized reaction/Reanimation dispatchers now validate the `stratagems` and `reanimation` containers and their pending-window types before projection or dispatch. Malformed state is rejected without mutation. The combined targeted verification passed **6/6 processes** (import, Python checks, `test_phase_close_gate`, `test_core_reactions`, `test_stratagems` and `test_attached_reanimation`) at `.tools/verification/20261023T025459924525Z/results.json` (`network: false`). This is local admission evidence only.

22 October A2 pending-container audit: command admission and specialized dispatch now validate decision-state container types for Mission, Combat Doctrines, Oath of Moment, Awakened Dynasty, Stratagems and Reanimation before reading their projected choices or pending windows. Regressions exercise malformed top-level state through public command routes. The targeted verification passed **10/10 processes** (import, Python checks and the phase-close, mission, doctrine, Oath, Awakened Dynasty, stratagem, Reanimation and core-reaction suites) at `.tools/verification/20261023T025640106194Z/results.json` (`network: false`). This is local admission evidence only.

23 October A2 continuation: centralized pending-state validation now also protects actor/HUD projection and save, resume and host-snapshot boundaries. It checks deployment, core and detachment reactions, Command Battle-shock, Fearsome Assault, Adamantine Terror and normalized decision windows before actor projection. Malformed state is rejected before projection or assignment, and an invalid snapshot cannot replace the client's last accepted state. A no-choice phase-close regression confirms that progression advances and completes the temporary frame. Targeted verification passed **4/4 processes** (import, Python checks, `test_phase_close_gate` and `test_actions`) at `.tools/verification/20261023T030718337251Z/results.json` (`network: false`). This is local evidence only; no LAN clients were used.

23 October A2 Rapid Ingress audit: the opponent's Movement-end choice window previously opened whenever any reserve entry existed, including reserves owned only by the active player. The resolver now derives eligible Rapid Ingress squads per owner and reuses that set for both ownership and option projection; it requires the Core Stratagems container and a legal CP or Teleport Homer entry. No eligible owner means phase close advances without a pass-only prompt or leaked frame. UnitActions also validates its `used`, `reserves`, `homers`, setup-player and battle-player containers before actor projection. Targeted local verification passed **4/4 processes** (import, Python checks, `test_unit_reserves` and `test_phase_close_gate`) at `.tools/verification/20261023T031258673678Z/results.json` (`network: false`). The reserve suite covers ineligible reserve ownership, omitted Core Stratagems, legal 1 CP Rapid Ingress and Teleport Homer ingress through the opponent's phase-close continuation.

23 October A2 phase-start continuation audit: focused local coverage passed for standalone Command Doctrine, Oath of Moment, the Doctrine plus UnitActions start window, Fight-entry Fearsome Assault, and Command Battle-shock with Tempered in Battle. These checks verify normalized choices, serialized continuation identity, close blocking, and frame completion. Targeted verification passed **7/7 processes** (import, Python checks and the five selected suites) at `.tools/verification/20261023T031436915263Z/results.json` (`network: false`). This evidence covers these phase-start paths only; other pending workflows remain under audit.

23 October A2 coherency-decision migration: mandatory End-of-Turn casualties now have a deterministic shared decision projection and model option IDs; the command service validates the current decision and selected option before applying the existing domain removal rule. The same focused run exposed three defects in the no-Core-Stratagem Command Battle-shock fallback: partial batch mutation on invalid dice, completion erasing its final result, and a passed repeat test failing to clear Battle-shock. These were fixed with staged resolution, single completion and current-result state assignment. Targeted verification passed **5/5 processes** (import, Python checks, `test_morale_coherency`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T032320402976Z/results.json` (`network: false`, Godot 4.7.2). No LAN clients were used. This validates only these local workflows; broader rules scope and LAN behavior remain unverified.

23 October A2 Desperate Escape allocation migration: the Movement action now exposes its required mortal-wound choice through the pending-decision registry and accepts only the current decision/option IDs. The eligibility projection and domain command share the existing Mortal Wounds hierarchy, including non-Character and Character priority; the UI disables a selected model outside the current legal set, and both phase close and unrelated commands remain blocked until allocation completes. Rules were checked against Wahapedia's 11e Core Rules page, listing a June 2026 update: §§06.02–06.03 and 09.07. Targeted verification passed **7/7 processes** (import, Python checks, `test_movement_types`, `test_phase_close_gate`, `test_damage_allocation`, `test_hazardous` and `test_escape_rerolls`) at `.tools/verification/20261023T033858501140Z/results.json` (`network: false`, Godot 4.7.2). A staged, synthetic Movement state was captured in the live Godot runtime at 1280×800; the ignored `.tools/review_captures/` images show one eligible and one priority-blocked selection. No network clients were used, and the capture does not claim a full-match or LAN result.

23 October A2 Desperate Escape continuation follow-up: the persisted Movement frame now suspends at `escape-wound-allocation`, remains the same frame through multiple mortal wounds and resumes at `movement-placement` after the final wound. This also applies after the hazard pool is accepted or re-rolled, and serialized pending decisions restore the suspended frame identity. Targeted verification passed **5/5 processes** (import, Python checks, `test_movement_types`, `test_escape_rerolls` and `test_phase_close_gate`) at `.tools/verification/20261023T034349434562Z/results.json` (`network: false`, Godot 4.7.2). No network clients were used.

23 October A2 End-of-Turn coherency continuation: entering `end_turn` with incoherent units now suspends one persisted `phase-close` frame. The normalized casualty decision links to that frame, survives serialization, transfers priority between affected players and resumes the same frame after the final required casualty. Focused verification passed **7/7 processes** (import, Python checks, `test_morale_coherency`, `test_phase_close_gate`, `test_pending_decision`, `test_movement_types` and `test_escape_rerolls`) at `.tools/verification/20261023T034906589044Z/results.json` (`network: false`, Godot 4.7.2). No network clients were used.

23 October A2 UnitActions projection audit: the UnitActions dispatcher now validates persisted window kinds against its supported discriminator set before projection. Unknown kinds can no longer be cleared through a generic decline action, and higher-priority decisions remain unaffected. Expanded targeted verification passed **16/16 processes** (import, Python checks and 14 suites covering phase-close admission, pending decisions, Core reactions, reserves, Ironstorm, Chaplain, Machine Spirits, Bladeguard, Cato Sicarius, Victrix, Combi-weapon Lieutenant, detachment stratagems, transport destruction and Hammer of Wrath) at `.tools/verification/20261023T040013494489Z/results.json` (`network: false`, Godot 4.7.2). This was local verification only; no LAN clients were used.

23 October A2 attack declaration and Fight continuations: pre-dice reactions now retain the same persisted attack frame through save/resume, the selected Shrouding result and subsequent damage allocation; the unengaged Bladeguard stance choice now owns a `fight` frame, is selected through the normalized command option, and blocks phase close without mutating state. Focused local verification passed `test_librarian_phobos` (3/3 processes) at `.tools/verification/20261023T041147483381Z/results.json` and `test_bladeguard` (3/3 processes) at `.tools/verification/20261023T041449885900Z/results.json` (`network: false`). No LAN or two-client checks were run.

23 October A2 Movement reaction continuation: completed Movement now keeps its persisted frame while post-move Cato Sicarius, Combi-weapon Lieutenant Evade and Survive, or deferred Techmarine Blessings choices resolve. Normalized decisions retain the movement frame identity through reaction placement/queue steps; completion closes the same frame. The targeted local run passed **5/5 processes** (import, Python checks, `test_techmarine`, `test_cato_sicarius` and `test_lieutenant_combi_weapon`) at `.tools/verification/20261023T042424104904Z/results.json` (`network: false`, Godot 4.7.2). Cato and Techmarine checks cover serialization/phase-close blocking; the Combi Lieutenant check covers the actual movement, decision and decline path. No LAN clients were used. This is bounded workflow evidence, not broad rules or army-legality certification.

23 October A2 detachment Movement/Charge continuation: Responsive Tactics, Masterful Tactics and Hunter’s Instincts now open a player-owned reaction after an enemy move ends within range. The decision survives save/resume, offers pass or an eligible stratagem, and retains the Movement frame through placement cancellation. Pre-move Mobile stratagem selections and Flawless Riders Charge declarations now resume their suspended action frames through the actual unit-choice command path. Targeted offline verification passed **5/5 processes** (isolated import, Python checks, `test_detachment_stratagems.gd`, `test_tactical_brethren.gd` and `test_spearpoint_stratagems.gd`) at `.tools/verification/20261023T044617403758Z/results.json` (`network: false`, Godot 4.7.2). The response integration uses two players in one local state; no LAN clients were used. Network validation and full army legality remain uncertified.

23 October A2 post-attack continuation audit: finalized attacks suspend their existing attack frame while selected Tactical Fluidity, Purgation Run, Glory of Ultramar or Invictor mark-replacement decisions remain pending. Normalized choices retain the attack action/frame identity through reaction and placement. The tests cover real Captain Phobos and Land Speeder shooting, Purgation save/resume and phase-close blocking, Glory frame suspension/placement, and the Invictor replacement inside its attack-allocation continuation. Focused local verification passed **11/11 processes** (import, Python checks and nine suites: `test_captain_phobos`, `test_land_speeder`, `test_victrix_honour_guard`, `test_invictor_tactical_warsuit`, `test_lieutenant_combi_weapon`, `test_techmarine`, `test_cato_sicarius`, `test_librarian_phobos` and `test_bladeguard`) at `.tools/verification/20261023T043109202254Z/results.json` (`network: false`, Godot 4.7.2). No LAN clients were used. This covers selected local post-attack workflows only.

23 October A2 phase/frame regression audit: after the post-attack frame migration, local checks passed **7/7 processes** (import, Python checks and `test_phase_close_gate`, `test_resolution_frame`, `test_damage_allocation`, `test_core_reactions` and `test_stratagems`) at `.tools/verification/20261023T043235732992Z/results.json` (`network: false`, Godot 4.7.2). The verifier marked all suites passed; it also recorded Godot renderer/ObjectDB cleanup diagnostics for `test_stratagems`, so that cleanup remains a separate maintenance item. No LAN clients were used.

23 October A2 end-of-Fight continuation characterization: `test_suboden_khan` now drives Wrath of the First Khan through the normalized public UnitActions command path, checks that the opponent owns the phase-end decision, rejects phase close without mutation while placement is pending, serializes/restores the suspended phase-close frame, confirms the move and passes the remaining optional window. Fight close then hands off to the distinct mandatory End-of-Turn coherency frame. Targeted verification passed **3/3 processes** (import, Python checks and `test_suboden_khan`) at `.tools/verification/20261023T045649488105Z/results.json` (`network: false`, Godot 4.7.2). This uses one local match state; no LAN or host/client test was run.

23 October A2 Wind-Swift continuation characterization: `test_combat_doctrines` now drives the Stormlance Wind-Swift Evasion choice through the normalized public UnitActions command, saves/restores during the Movement placement, verifies a premature phase close is rejected, confirms movement back into the existing end window and passes to complete Fight close. Targeted verification passed **3/3 processes** (import, Python checks and `test_combat_doctrines`) at `.tools/verification/20261023T045907287324Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Withdraw and Regroup continuation characterization: `test_spearpoint_stratagems` now advances the ordered Fight-end window through the normalized command path, lets Player 2 decline first, then lets the Spearpoint player spend 1 CP and place an eligible Mounted unit in reserves. The suspended phase-close frame survives save/restore and resumes after the remaining pass. Targeted verification passed **3/3 processes** (import, Python checks and `test_spearpoint_stratagems`) at `.tools/verification/20261023T050207509245Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 reserve-choice continuation audit: `test_inceptor_squad` and `test_kayvaan_shrike` now select Parabolic Jetleap and Echo of the Ravenspire through normalized Fight-end command decisions. Both suites verify eligible reserve placement, retained phase-close state, save/restore and explicit pass to resume Fight close. Each targeted run passed **3/3 processes** at `.tools/verification/20261023T050343478190Z/results.json` and `.tools/verification/20261023T050423385801Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Tactical Fluidity end-of-Fight continuation: `test_captain_phobos` now advances the opponent's Fight close into the Captain's normalized response, Fall Back subchoice and serialized placement. It verifies premature phase close is rejected without mutation, the same continuation survives confirmation, and the remaining pass resumes Fight close. Targeted local verification passed **3/3 processes** (import, Python checks and `test_captain_phobos`) at `.tools/verification/20261023T050536284712Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Resurrection Orb continuation: Orb activation now runs through its normalized end-of-phase choice; the Reanimation projection reports the actual phase timing (and Undying Legions is labeled post-destruction) instead of incorrectly labeling every window as Command. The focused test covers returnable-model placement, close rejection while pending, save/restore, confirmation and explicit pass to resume the original phase close. Targeted verification passed **3/3 processes** (import, Python checks and `test_current_unit_abilities`) at `.tools/verification/20261023T050835335660Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Fight-end decision audit regression: after integrating Suboden Khan, Wind-Swift Evasion, Withdraw and Regroup, Parabolic Jetleap, Echo of the Ravenspire, Tactical Fluidity and Resurrection Orb, the combined targeted run passed **10/10 processes** (import, Python checks and `test_suboden_khan`, `test_combat_doctrines`, `test_spearpoint_stratagems`, `test_inceptor_squad`, `test_kayvaan_shrike`, `test_captain_phobos`, `test_current_unit_abilities` and `test_detachment_stratagems`) at `.tools/verification/20261023T051207097150Z/results.json` (`network: false`, Godot 4.7.2). Undying Legions timing is also checked as `post-destruction:shooting:reanimation`. The verifier recorded renderer RID and ObjectDB cleanup diagnostics for `test_combat_doctrines` and `test_current_unit_abilities`; their checks themselves reported zero failures. No LAN or host/client test was run.

23 October A2 Heroic Intervention phase-close continuation: `test_core_reactions` now advances the Charge close into the normalized Heroic Intervention choice, spends 1 CP through `MatchCommandService`, opens the reacting unit's pending charge and verifies that phase close remains blocked under the same continuation. The focused run passed **3/3 processes** at `.tools/verification/20261023T051447017492Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Into the Fray continuation: `test_core_reactions` now also resolves the 2 CP mode through the normalized Charge-end choice, verifies the capped charge stays under the phase-close continuation and blocks phase close until the charge resolves. The focused rerun passed **3/3 processes** at `.tools/verification/20261023T051544522739Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 Eternal Revenant end-window continuation: the stratagem placement now stores and restores the original end-of-phase choice window after confirming the returned model, so remaining eligible choices are preserved. `test_detachment_stratagems` exercises the normalized choice, suspended phase-close frame, blocked premature close, serialized placement, resumed pass and phase progression. Targeted verification passed **3/3 processes** at `.tools/verification/20261023T051804417829Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/client test was run.

23 October A2 continuation cross-check after Eternal Revenant: `test_core_reactions`, `test_detachment_stratagems`, `test_current_unit_abilities` and `test_phase_close_gate` passed together **6/6 processes** (including isolated import and Python checks) at `.tools/verification/20261023T051844232413Z/results.json` (`network: false`, Godot 4.7.2). This confirms the preserved end-window continuation alongside Overwatch/Heroic charge, Orb Reanimation and phase-close admission. No LAN or host/client test was run.

23 October A2 Undying Legions post-attack continuation: the defender now receives a normalized reaction after an eligible Shooting or Fight attack destroys models in a supported Necron unit. The suspended attack frame persists through the Reanimation reroll and return placement; completing Reanimation resumes/completes that frame without advancing the phase. A second case covers a Character reroll that completes Reanimation without returned models and verifies that the phase does not advance. Targeted verification passed **6/6 processes** (isolated import, Python checks, `test_detachment_stratagems`, `test_current_unit_abilities`, `test_reanimation_protocols` and `test_phase_close_gate`) at `.tools/verification/20261023T053155133310Z/results.json` (`network: false`, Godot 4.7.2). The runner recorded RID/ObjectDB cleanup diagnostics in `test_current_unit_abilities` and `test_reanimation_protocols`, although both suites passed. A follow-up regression of `test_core_reactions`, `test_stratagems` and `test_match_command_service` passed **5/5 processes** at `.tools/verification/20261023T053406381478Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Vengeful Stars/Hail of Vengeance continuation audit: both choices now exercise the normalized MatchCommandService path, persist the `shooting-reaction` frame across state serialization, block phase close while pending, and accept the bound reactive shooter's attack window. This uncovered and fixed an admission bug where Hail's valid attack was rejected as an unresolved UnitActions choice; the exception is limited to the decision owner, selected reactive shooter and matching continuation frame. Hail's explicit decline after restore completes the frame. Targeted verification passed **6/6 processes** (import, Python checks, `test_devastator_brethren`, `test_detachment_stratagems`, `test_phase_close_gate` and `test_match_command_service`) at `.tools/verification/20261023T053857177750Z/results.json` (`network: false`, Godot 4.7.2). This checks attack admission, not full reactive weapon resolution. No LAN or host/guest test was run.

23 October A2 Hail of Vengeance attack completion: `test_devastator_brethren` now resolves a real retaliatory shot through `MatchCommandService.SHOOT`, verifies the bound attack is accepted, consumes the damaged unit's Shooting activation and completes the persisted reaction frame; the separate restored-state pass case remains covered. The focused cross-check passed **6/6 processes** (import, Python checks, `test_devastator_brethren`, `test_detachment_stratagems`, `test_phase_close_gate` and `test_match_command_service`) at `.tools/verification/20261023T054123441036Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Vengeful Stars nested attack completion: `test_detachment_stratagems` now resolves the Necron Character's reactive attack through `MatchCommandService.SHOOT`. Its defender-owned save-roll decision remains under the attack child frame and Vengeful reaction parent across serialization; accepting the normalized save choice completes the attack and closes both frames. The focused cross-check passed **6/6 processes** (import, Python checks, `test_devastator_brethren`, `test_detachment_stratagems`, `test_phase_close_gate` and `test_match_command_service`) at `.tools/verification/20261023T055221843557Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Vengeful Stars trigger-to-shot coverage: `test_detachment_stratagems` now starts from a public Captain attack-plan using the equipped Master-crafted Bolter, resolves the defender's normalized damage allocation to destroy the last Immortal, then resolves the Overlord's normalized Vengeful choice and retaliatory `SHOOT` against the destroying Marine unit. The nested defender save-roll decision and both attack/reaction frames survive serialization and close after acceptance. Focused local verification passed **6/6 processes** (import, Python checks, `test_devastator_brethren`, `test_detachment_stratagems`, `test_phase_close_gate` and `test_match_command_service`) at `.tools/verification/20261023T060829051482Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Command-healing continuation: `test_apothecary` now starts Narthecium and confirms healing through normalized UnitActions commands, rejects a premature close without mutation, saves/restores between the choices with the phase-close frame retained, then resumes Command close and resolves the opponent's remaining end-phase choice before Movement. The focused local regression passed **5/5 processes** (`test_apothecary`, `test_phase_close_gate`, `test_current_unit_abilities`, import and Python checks) at `.tools/verification/20261023T061227324113Z/results.json` (`network: false`, Godot 4.7.2). The verifier recorded RID/ObjectDB cleanup diagnostics in `test_current_unit_abilities` despite its passing assertions. No LAN or host/guest test was run.

23 October A2 no-Core-Stratagem Battle-shock continuation: `test_tempered_in_battle` now resolves the serialized fallback Tempered in Battle choice through normalized `MatchCommandService.SELECT_UNIT_CHOICE`, rejects premature phase close without mutation and confirms the suspended Command frame completes after the full Leadership re-roll. The cross-check passed **6/6 processes** (`test_tempered_in_battle`, `test_morale_coherency`, `test_phase_close_gate`, `test_stratagems`, import and Python checks) at `.tools/verification/20261023T061412977941Z/results.json` (`network: false`, Godot 4.7.2). The verifier recorded renderer/ObjectDB cleanup diagnostics for `test_stratagems` despite its passing assertions. No LAN or host/guest test was run.

23 October A2 mixed phase-start decision continuation: `test_chaplain` now resolves Spiritual Leader, the newly enabled Smokescreen choice and the final `Pass` through normalized UnitActions commands. The restored decision and `phase-start` frame persist across the first effect and complete after the remaining choice; the cross-check passed **7/7 processes** (`test_chaplain`, `test_smokescreen`, `test_pending_decision`, `test_combat_doctrines`, `test_phase_close_gate`, import and Python checks) at `.tools/verification/20261023T061551324475Z/results.json` (`network: false`, Godot 4.7.2). The verifier recorded renderer/ObjectDB cleanup diagnostics for `test_combat_doctrines` despite its passing assertions. No LAN or host/guest test was run.

23 October A2 Fearsome Assault normalized decision flow: `test_reiver_squad` now submits Fight-entry Battle-shock rolls, already-shocked target handling and the target controller's serialized Tempered in Battle re-roll through normalized UnitActions command envelopes. The `phase-start` frame completes after the final result. Cross-check passed **6/6 processes** (`test_reiver_squad`, `test_ironclad_champions`, `test_tempered_in_battle`, `test_phase_close_gate`, import and Python checks) at `.tools/verification/20261023T061732516323Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Adamantine Terror sequential decision flow: `test_ironclad_champions` now submits the trigger and both target-controller Tempered in Battle re-rolls through normalized UnitActions command envelopes. The first target's result resumes the same Fight-start sequence for the second; phase close remains blocked until both results finish. Cross-check passed **8/8 processes** (`test_ironclad_champions`, `test_tempered_in_battle`, `test_reiver_squad`, `test_per_player_detachments`, `test_phase_close_gate`, `test_detachment_stratagems`, import and Python checks) at `.tools/verification/20261023T061841111383Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Hail trigger-to-response integration: `test_devastator_brethren` now starts with a public enemy `SHOOT`, handles the target's normalized Armour of Contempt decline and defender-owned damage allocation, verifies the actual model destruction opens Hail for the surviving unit and binds the triggering shooter, then selects Hail and resolves the reactive shot. The combined focused cross-check passed **6/6 processes** (import, Python checks, `test_devastator_brethren`, `test_detachment_stratagems`, `test_phase_close_gate` and `test_match_command_service`) at `.tools/verification/20261023T055724302920Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 Unstoppable Advance declaration choice: `test_ironclad_champions` now submits the pre-move Mobile stratagem through the normalized UnitActions command and checks that the decision ID survives save/restore before the owner spends 1 CP and resumes the movement declaration. The targeted offline run passed **3/3 processes** (import, Python checks and `test_ironclad_champions`) at `.tools/verification/20261023T062123023091Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Hunter's Instincts response: `test_spearpoint_stratagems` now opens the response through the recorded enemy-movement trigger, verifies its owner and decision identity through save/restore, then submits the D3 result through the normalized UnitActions command before checking CP and the follow-up Normal Move. The targeted offline run passed **3/3 processes** (import, Python checks and `test_spearpoint_stratagems`) at `.tools/verification/20261023T062321299555Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Mobile declaration choices: `test_spearpoint_stratagems` now submits Flawless Riders Movement and Charge choices plus Mobile Lethality through `MatchCommandService.SELECT_UNIT_CHOICE`; the Movement decision survives save/restore, then the checks confirm the selected movement or charge retains Mobile and its existing terrain/spacing constraints. Targeted local verification passed **3/3 processes** at `.tools/verification/20261023T062615105283Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. A detachment-stratagem regression run also passed **3/3 processes** at `.tools/verification/20261023T062644476201Z/results.json` (`network: false`, no cleanup diagnostics). No LAN or host/guest test was run.

23 October A2 A Worthy Death and Duty in Death attack continuations: the Gladius and Assault Brethren cases now resolve through normalized UnitActions choices during real Fight attack declarations. The tests pass Armour of Contempt, verify the defender owns the follow-up, reject premature Fight close, save/restore the decision and suspended attack frame, and resume the declaration after CP is spent. Duty in Death retains its Assault Doctrine casualty-roll check. The cross-check passed **6/6 processes** (import, Python checks, `test_detachment_stratagems`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T063030945908Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Counteroffensive command validation: the `test_core_reactions` take path now uses the normalized UnitActions command after save/restore, and its pass path also uses the normalized command. A wrong-owner command is rejected without mutation; the valid choice spends CP or passes, then completes the same persisted Fight continuation. Targeted local verification passed **5/5 processes** (import, Python checks, `test_core_reactions`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T063204381712Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Hurtling Targets attack continuation: `test_combat_doctrines` now saves/restores the real ranged attack's defender decision and suspended frame, rejects Shooting close without mutation, then submits Hurtling through the normalized UnitActions command. The resumed attack completes, spends CP and uses the ranged -1 hit modifier. Cross-check passed **6/6 processes** (import, Python checks, `test_combat_doctrines`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T063447127075Z/results.json` (`network: false`, Godot 4.7.2). The verifier recorded renderer/ObjectDB cleanup diagnostics for `test_combat_doctrines`, although its checks passed. No LAN or host/guest test was run.

23 October A2 Spearpoint Evasive Manoeuvres attack response: `test_spearpoint_stratagems` now opens the defender decision from a public ranged attack, checks save/restore and phase-close blocking, then submits Evasive through the normalized command. The shot completes with the wound modifier applied and CP spent. Cross-check passed **7/7 processes** (import, Python checks, `test_spearpoint_stratagems`, `test_combat_doctrines`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T064646098854Z/results.json` (`network: false`, Godot 4.7.2). Renderer/ObjectDB cleanup diagnostics remain in `test_combat_doctrines`; the other selected suites reported none. No LAN or host/guest test was run.

23 October A2 Emergency Disembark response: a destroyed transport's passenger-owned Hazard allocations and active-player placement now use normalized UnitActions commands through the complete destruction/attack continuation. The test rejects the wrong player without mutation, preserves decision and suspended attack identity through save/restore, checks close blocking, then confirms placement and resumes the suspended attack. Cross-check passed **7/7 processes** (import, Python checks, `test_marine_transport_destruction`, `test_marine_transport_rules`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T070238640966Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Normal Transport disembark continuation: the no-Hazard Rapid Disembark placement window now assigns its owner and is accepted by the normalized UnitActions dispatcher. The test preserves decision and frame identity through save/restore, rejects phase close while placement remains, and submits model placement and confirmation through the normalized command. Cross-check passed **7/7 processes** (import, Python checks, `test_marine_transport_destruction`, `test_marine_transport_rules`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T071621989620Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Drop Pod Assault passenger sequence: the compulsory multi-passenger disembark now uses normalized UnitActions choices through placement and confirmation. The test checks owner rejection, phase-close blocking, save/restore identity, frame reuse for the next passenger and completion of both child and ingress frames. Cross-check passed **8/8 processes** (import, Python checks, `test_marine_transport_destruction`, `test_marine_transport_rules`, `test_marine_drop_pod`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T072059468383Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Headhunter Doctrine continuation: the real attack declaration now opens a normalized attacker-owned choice, blocks premature Shooting close, rejects the opponent without mutation, and preserves decision/frame identity through save/restore. Both use and pass resume the same public attack; follow-up Ironstorm reroll decisions also resolve through normalized commands. Focused local verification passed **7/7 processes** (`import`, Python checks, `test_ironstorm_stratagems`, `test_detachment_stratagems`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T073231968655Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Cato Sicarius movement reaction: Knight Champion use, placement and confirmation now pass through normalized UnitActions commands while retaining the completed Movement frame. The test rejects an opponent command without mutation and confirms the same frame closes after the Normal Move. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_cato_sicarius`, `test_phase_close_gate`, `test_resolution_frame` and `test_current_unit_abilities`) at `.tools/verification/20261023T073805721013Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless RID/ObjectDB cleanup diagnostics despite passing; other selected checks reported none. No LAN or host/guest test was run.

23 October A2 mortal allocation responses: Hammer of Wrath's attacker reaction and defender allocation now use normalized UnitActions commands; its suspended Charge frame survives save/restore and completes after allocation. Tigurius's Telepathic Assault allocation preserves the defender decision ID, rejects the attacker without mutation and keeps Shooting close blocked until all three mortal wounds resolve. Focused local verification passed **8/8 processes** (`import`, Python checks, `test_hammer_of_wrath`, `test_chief_librarian_tigurius`, `test_explosives`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T074723665544Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 mortal-source follow-up: normalized defender allocation now also covers Explosives, Haywire Mine, Tank Shock and Ballistus Deadly Demise. The Ballistus flow preserves the decision and suspended attack-frame identities through save/restore before resuming the attack; Tank Shock retains its Charge continuation through the mortal packet. The combined source regression passed **12/12 processes** (import, Python checks, Hammer of Wrath, Tigurius, Explosives, Incursor Squad, Ballistus Dreadnought, Core Reactions, Transport Destruction, phase close, resolution frame and damage allocation) at `.tools/verification/20261023T080024689255Z/results.json` (`network: false`). No cleanup diagnostics were recorded. A follow-up Brutalis check passed **7/7 processes** (import, Python checks, Brutalis Dreadnought, Core Reactions, phase close, resolution frame and damage allocation) at `.tools/verification/20261023T080417067747Z/results.json` (`network: false`), also without cleanup diagnostics. Godot 4.7.2. No LAN or host/guest test was run.

23 October A2 post-movement response choices: Cato Knight Champion, Combi-weapon Lieutenant Evade and Survive, and Techmarine Blessings now submit their response, deferral, placement and confirmation choices through the normalized command. The combined focused verification passed **8/8 processes** (import, Python checks, the three unit suites, phase close, resolution frame and current UnitActions) at `.tools/verification/20261023T080631559265Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless RID/ObjectDB cleanup diagnostics despite passing; all other selected processes reported none. No LAN or host/guest test was run.

23 October A2 post-Fight Tactical Fluidity: Wind-Swift's Normal Move confirmation and Fall Back placement and confirmation now use the normalized UnitActions command. Focused verification passed **7/7 processes** (import, Python checks, Combat Doctrines, Detachment Stratagems, phase close, resolution frame and damage allocation) at `.tools/verification/20261023T080809481437Z/results.json` (`network: false`, Godot 4.7.2). `test_combat_doctrines` reported headless renderer/ObjectDB cleanup diagnostics despite passing; remaining selected processes reported none. No LAN or host/guest test was run.

23 October A2 post-attack continuation choices: Invictor Forward Assault's initial and replacement marks and Victrix Glory of Ultramar's use, Surge placement and confirmation now use normalized UnitActions commands. The real Invictor replacement rejects the defender without mutation, preserves decision and attack-frame identities through save/restore, blocks Shooting close and resumes the same attack. Cross-check passed **9/9 processes** (import, Python checks, Invictor Tactical Warsuit, Victrix Honour Guard, Combat Doctrines, Detachment Stratagems, phase close, resolution frame and damage allocation) at `.tools/verification/20261023T081125225745Z/results.json` (`network: false`, Godot 4.7.2). `test_combat_doctrines` reported cleanup diagnostics despite passing; all other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Purgation Run continuation: a public Land Speeder attack-plan now opens the post-attack response; normalized use, Normal Move placement and confirmation retain the decision and attack-frame identities through save/restore, reject the opponent without mutation and block phase close until the move is confirmed. Focused cross-check passed **7/7 processes** (import, Python checks, Land Speeder, Detachment Stratagems, phase close, resolution frame and damage allocation) at `.tools/verification/20261023T081327331690Z/results.json` (`network: false`, Godot 4.7.2); no cleanup diagnostics were recorded. No LAN or host/guest test was run.

23 October A2 Tactical Fluidity continuation: Captain Phobos's post-shot D6 choice and Normal Move placement/confirmation now use normalized commands. The test rejects opponent submission without mutation, blocks phase close, and retains the attack-frame continuation through save/restore until confirmation. Targeted local verification passed **3/3 processes** (import, Python checks and `test_captain_phobos`) at `.tools/verification/20261023T081514304493Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 attack reroll continuation: Power of the Machine Spirit and Ironstorm Auto-targeters Hit/Wound reroll and decline choices now use normalized UnitActions commands. Machine Spirit decision identity survives save/restore, the opponent is rejected without mutation, and phase close remains blocked while the attack choice is pending. Both flows resume their attacks after the selected reroll or decline. Targeted verification passed **6/6 processes** (`import`, Python checks, `test_marine_machine_spirits`, `test_damage_allocation`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T081751113540Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Command Re-roll continuation: `test_attack_rerolls` now submits attack Hit/Wound accept and reroll choices through the normalized stratagem-decision envelope used by the UI. It retains the save/restore decision check and rejects invalid owner, stale revision, die and RNG attempts without consuming rolls or mutating the attack. Focused verification passed **6/6 processes** (`import`, Python checks, `test_attack_rerolls`, `test_stratagems`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T082130288509Z/results.json` (`network: false`, Godot 4.7.2). The runner recorded headless RID/ObjectDB cleanup diagnostics for `test_attack_rerolls` and `test_stratagems`, although both passed; other selected processes reported none. No LAN or host/guest test was run.

23 October A2 mortal-source interaction continuation: the Ironstorm integration regression now routes Tank Shock, Hammer of Wrath, Telepathic Assault and Haywire Mine through the normalized command service, then resolves Layered Ceramite and a mortal allocation through normalized choices. Focused local verification passed **7/7 processes** (`import`, Python checks, `test_ironstorm_stratagems`, `test_detachment_stratagems`, `test_phase_close_gate`, `test_resolution_frame` and `test_damage_allocation`) at `.tools/verification/20261023T082512717894Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Drop Pod ingress continuation: the integration test now submits Rapid Ingress declaration, preview and confirmation through `MatchCommandService`, then resolves nested mandatory Drop Pod passenger choices through normalized commands. Save/restore identity, phase-close blocking and same-frame completion remain covered. Targeted verification passed **7/7 processes** (`import`, Python checks, `test_marine_drop_pod`, `test_marine_transport_rules`, `test_marine_transport_destruction`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T082911550104Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Fight activation choice continuation: Captain Titus's Righteous Fury now enters through `MatchCommandService`. The opponent's choice is rejected without mutation and the valid choice activates the ability once. Targeted verification passed **6/6 processes** (`import`, Python checks, `test_captain_titus`, `test_current_unit_abilities`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083111304762Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Command ability continuation: Captain Phobos's start-of-Command Combat Doctrine, Strategic Acumen and remaining-window pass now use `MatchCommandService`. The focused check proceeds into Fight and the post-shot Tactical Fluidity choice. Verification passed **7/7 processes** (`import`, Python checks, `test_captain_phobos`, `test_combat_doctrines`, `test_match_command_service`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083321124536Z/results.json` (`network: false`, Godot 4.7.2). `test_combat_doctrines` reported renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Charge/transport reaction continuation: Repulsor Combat Embarkation now submits the defender's Charge-time pass/embark decision through `MatchCommandService`. The test verifies opponent rejection without mutation, Charge-close blocking and target-selection resumption. Targeted verification passed **7/7 processes** (`import`, Python checks, `test_marine_repulsor_combat_embarkation`, `test_contact_actions`, `test_marine_transport_rules`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083444781150Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Fight stance continuation: `test_bladeguard` now submits both sides' attack/defend stances and decline through normalized UnitActions commands before dice. The attack resumes with the selected modifiers, and declined stances remain available on later legal triggers. Targeted verification passed **6/6 processes** (`import`, Python checks, `test_bladeguard`, `test_contact_actions`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083552174660Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Apothecary healing continuation: Narthecium, healing allocation, revived-model placement, reset and confirmation now use `MatchCommandService`, including the suspended Command-close frame and save/restore path. Targeted verification passed **6/6 processes** (`import`, Python checks, `test_apothecary`, `test_current_unit_abilities`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083742270514Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported renderer/ObjectDB cleanup diagnostics despite passing; all other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Implacable Eradication continuation: Hit/Wound rerolls and keep-results now use the normalized UnitActions envelope in the pending attack. The test checks stable defender decision identity, attacker rejection without mutation, duplicate reroll refusal and attack resumption. Targeted verification passed **6/6 processes** (`import`, Python checks, `test_current_unit_combat`, `test_damage_allocation`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T083907385650Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Responsive Tactics continuation: activation, placement cancel and decline after an enemy move now use normalized commands. Cancel restores the same reaction window, and the last pass completes the pending Movement frame. Targeted verification passed **7/7 processes** (`import`, Python checks, `test_detachment_stratagems`, `test_core_reactions`, `test_phase_close_gate`, `test_resolution_frame` and `test_current_unit_abilities`) at `.tools/verification/20261023T084015689080Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 pre-battle Scout continuation: Scout declaration, individual previews and confirmation now submit through normalized UnitActions commands. The last queued Scout move advances automatically into `start_turn`. Focused verification passed **7/7 processes** (`import`, Python checks, `test_scout_squad`, `test_librarian_phobos`, `test_phase_close_gate`, `test_resolution_frame` and `test_match_command_service`) at `.tools/verification/20261023T084152125789Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Phobos Scout follow-up: the Librarian's ordinary Scout move and Strategic Reserves set-up now also use normalized UnitActions commands for declaration, per-model preview and confirmation. The local test retains the six-inch move check, deployment-zone check, final queued advancement and reserves removal. Focused verification passed **7/7 processes** (`import`, Python checks, `test_librarian_phobos`, `test_scout_squad`, `test_phase_close_gate`, `test_resolution_frame` and `test_match_command_service`) at `.tools/verification/20261023T084455255610Z/results.json` (`network: false`, Godot 4.7.2), with no cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 shared UnitActions regression: `test_current_unit_abilities` now uses normalized envelopes for the choices present in the pending-decision projection. My Will Be Done's Core Stratagem discount response remains on its specialized handler. Focused verification passed **7/7 processes** (`import`, Python checks, `test_current_unit_abilities`, `test_current_unit_combat`, `test_phase_close_gate`, `test_resolution_frame` and `test_match_command_service`) at `.tools/verification/20261023T084648381963Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 selected ability windows: Darnath Lysander's Rampart, Hailstrike and Thunderstrike marks now submit through normalized UnitActions envelopes. A ranged-attack finalization omission was fixed so Shooting hits can open the existing Hailstrike/Shattered Defences target decision. The tests reject the opposing player without mutation and preserve target filters. Focused verification passed **10/10 processes** at `.tools/verification/20261023T085322152423Z/results.json` (`network: false`, Godot 4.7.2): import, Python checks, the three ability/profile suites, Combat Doctrines, phase-close gate, resolution frame, match command service and damage allocation. `test_combat_doctrines` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Captain Strategic Acumen: the current-reference Captain's immediate Command-phase choice now enters through `MatchCommandService`; the opponent is rejected without mutation. The exercised action is not held as a pending decision. Focused verification passed **8/8 processes** (`import`, Python checks, Captain, Captain in Phobos Armour, Combat Doctrines, phase-close gate, resolution frame and match command service) at `.tools/verification/20261023T085006013897Z/results.json` (`network: false`, Godot 4.7.2). `test_combat_doctrines` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Banner of Macragge activation: Victrix's Fight-time choice now submits through the projected UnitActions envelope. The opponent is rejected without mutation and the once-per-army activation remains checked. Focused verification passed **7/7 processes** (`import`, Python checks, Victrix Honour Guard, Captain Titus, phase-close gate, resolution frame and current UnitActions) at `.tools/verification/20261023T085711201128Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 remaining controller choices: Driven from Cover now submits its mandatory post-shot hit mark through the normalized UnitActions envelope, rejects the opponent and remains phase-close blocked until a legal mark is selected. Adamantine Terror's sequential Battle-shock re-rolls use controller-owned normalized decisions; the second result retains a fresh identity after save/restore. The combined fire-support cross-check passed **9/9 processes** at `.tools/verification/20261023T085932175991Z/results.json`; the sequential detachment cross-check passed **8/8 processes** at `.tools/verification/20261023T090114763647Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` in the fire-support run reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other processes in both reports reported none. No LAN or host/guest test was run.

23 October A2 Command Reanimation hand-off: the remaining end-phase pass now submits through the projected UnitActions envelope. The other player is rejected without mutation; the authorized pass completes the same phase-close frame and advances to Movement. Focused verification passed **7/7 processes** (`import`, Python checks, `test_attached_reanimation`, phase-close gate, resolution frame, current UnitActions and Reanimation Protocols) at `.tools/verification/20261023T090251194810Z/results.json` (`network: false`, Godot 4.7.2). The verifier recorded headless renderer/ObjectDB cleanup diagnostics for `test_current_unit_abilities` and `test_reanimation_protocols` despite passing. No LAN or host/guest test was run.

23 October A2 Phobos Shrouding continuation: the defender's pre-dice reaction now submits through the normalized UnitActions envelope. The attacker is rejected without mutation, Shooting close remains blocked and the same attack declaration resumes after the psychic choice. Focused verification passed **8/8 processes** (`import`, Python checks, `test_librarian_phobos`, `test_scout_squad`, phase-close gate, resolution frame, command service and current UnitActions) at `.tools/verification/20261023T090412811748Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Feirros repair continuation: Master of the Forge's pre-move defer and post-move repair use the projected UnitActions envelope. Opponent submissions at each point are rejected without mutation. Focused verification passed **7/7 processes** (`import`, Python checks, `test_iron_father_feirros`, `test_techmarine`, phase-close gate, resolution frame and current UnitActions) at `.tools/verification/20261023T090538546603Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other selected processes reported none. No LAN or host/guest test was run.

23 October A2 Chaplain phase-start choice: Spiritual Leader now submits through the projected UnitActions envelope, with wrong-player rejection and no CP cost. Focused verification passed **3/3 processes** (`import`, Python checks and `test_chaplain`) at `.tools/verification/20261023T090840417282Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 additional public-command coverage: standalone Smokescreen activation/pass and stale-revision rejection, Firestrike's extra Fire Overwatch and foreign-owner rejection, Eliminator Optics selection/cancellation, and Teleport Homer start-of-battle choices now exercise the public command service. Focused reports passed **7/7**, **10/10**, **6/6** and **7/7** at `.tools/verification/20261023T091120076405Z/results.json`, `.tools/verification/20261023T091217485330Z/results.json`, `.tools/verification/20261023T091346344595Z/results.json` and `.tools/verification/20261023T091432971438Z/results.json` (`network: false`, Godot 4.7.2). The Eliminators suite reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other reports did not. No LAN or host/guest test was run.

23 October A2 mission progression and deployment cursor: Chapter Approved setup, mission roles, first-turn roll, battle declarations and doctrine/pass choices now route through normalized decisions or public match commands. The shared actor gate accepts the completed deployment cursor at `order.size()` only with `complete=true`, restoring first-turn actor admission and Captain CP timing while rejecting incomplete exhausted orders. Focused verification passed **7/7 processes** (`import`, Python checks, Chapter Approved, phase-close gate, unit reserves, pending decision and match command service) at `.tools/verification/20261023T092458783358Z/results.json` (`network: false`, Godot 4.7.2). `test_chapter_approved` reported headless renderer/ObjectDB cleanup diagnostics despite passing; the other processes did not. No LAN or host/guest test was run.

23 October A2 public match-loop coverage: Chapter Approved setup, deployment preset/confirmation, first-turn selection and full phase advancement now use `MatchCommandService`; the five-round local progression and first-turn CP check pass. Gladiator Lancer Aquilon hit/wound rerolls submit with projected UnitActions decision IDs, and a non-priority player is rejected without mutation. Focused reports passed **6/6 processes** at `.tools/verification/20261023T092639129236Z/results.json` and **8/8** at `.tools/verification/20261023T092800754727Z/results.json` (`network: false`, Godot 4.7.2). The Chapter Approved report recorded headless cleanup diagnostics for that suite; the Lancer report did not. No LAN or host/guest test was run.

23 October A2 Infiltrator decision coverage: Omni-Scramblers target selection now uses the common command service, with foreign-owner and stale-revision submissions rejected without mutation. Focused verification passed **7/7 processes** (`import`, Python checks, Infiltrator Squad, Eliminators, pending decision, phase-close gate and match command service) at `.tools/verification/20261023T093002147245Z/results.json` (`network: false`, Godot 4.7.2). `test_eliminators` reported headless cleanup diagnostics despite passing; the other processes did not. No LAN or host/guest test was run.

23 October A2 public-command follow-up: the Chaplain suite now submits Spiritual Leader's stale-revision case through `MatchCommandService`; Chaplain on Bike submits Catechism target selection and the no-doctrine preparation choice through that service, rejecting a non-priority Catechism command without mutation. Core Epic Challenge's immediate Fight choice also uses the public command path. Focused reports passed **7/7 processes** for `test_core_reactions` and its command/phase regression set at `.tools/verification/20261023T093127776654Z/results.json`, **7/7** for Chaplain on Bike plus current-ability and decision gates at `.tools/verification/20261023T093224818112Z/results.json`, and **8/8** for the updated Chaplain, Chaplain on Bike and shared decision gates at `.tools/verification/20261023T093820102646Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics in the latter two reports despite passing; the other selected processes did not. No LAN or host/guest test was run.

23 October A2 decision rejection follow-up: Apothecary Narthecium confirmation and Bladeguard attacker stance now send foreign-owner and stale-revision cases through normalized public commands. Focused verification passed **7/7 processes** (`import`, Python checks, Apothecary, Bladeguard, phase-close gate, current UnitActions and command service) at `.tools/verification/20261023T094344299426Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; the other selected processes did not. No LAN or host/guest test was run.

23 October A2 phase and doctrine command follow-up: Tempered in Battle's integrated Command-close flow now advances the phase and selects the no-doctrine option through `MatchCommandService` before exercising the normalized Leadership decision. Focused verification passed **11/11 processes** (import, Python checks, Tempered in Battle, Marine ability boundaries, Apothecary, Bladeguard, Chaplain, Chaplain on Bike, phase-close gate, current UnitActions and command service) at `.tools/verification/20261023T094522797880Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; the other selected processes did not. No LAN or host/guest test was run.

23 October A2 preparation-choice follow-up: the Marine ability-boundary regression now resolves its initial no-doctrine choice through `MatchCommandService`. Focused verification passed **6/6 processes** (`import`, Python checks, Marine ability boundaries, phase-close gate, pending decision and command service) at `.tools/verification/20261023T094638406970Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 shared UnitActions audit guard: the broad current-ability helper now refuses to fall through to the domain handler when a pending UnitActions choice does not project the requested option or belongs to the other player. Focused verification passed **6/6 processes** (`import`, Python checks, current UnitActions, phase-close gate, pending decision and command service) at `.tools/verification/20261023T095052399002Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; the other selected processes did not. No LAN or host/guest test was run.

23 October A2 actor-rejection verification: the Chaplain's wrong-player Spiritual Leader command now reaches `MatchCommandService` using the pending decision's projected option; the service rejects it without state mutation. Focused verification passed **6/6 processes** (`import`, Python checks, Chaplain, pending decision, phase-close gate and command service) at `.tools/verification/20261023T095148144852Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 roster-command coverage: the Biologis setup regression now submits its Warlord selection, Support attachment and confirmation through `MatchCommandService`, using the decision envelope whenever the pending projection contains the option. Focused verification passed **6/6 processes** (`import`, Python checks, Biologis, phase-close gate, pending decision and command service) at `.tools/verification/20261023T095248150144Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. This is a local roster workflow check, not general army legality certification. No LAN or host/guest test was run.

23 October A2 Explosives rejection coverage: stale-revision submission now uses the same public UnitActions command path as valid activation and wrong-owner rejection; no state changes on the stale request. Focused verification passed **7/7 processes** (`import`, Python checks, Explosives, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T095438403791Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 stale-decision replay coverage: Implacable Eradication now resubmits its original wound-reroll decision/option IDs after resolution through `MatchCommandService`; the replay is rejected and leaves the state unchanged. Focused verification passed **7/7 processes** (`import`, Python checks, current-unit combat, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T095542613173Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Incursor post-shot decision: Divinator-class Auspexes now submits its normalized scan through `MatchCommandService`; opponent ownership is rejected without mutation and the authorized choice resumes the same shooting declaration. Focused verification passed **7/7 processes** (`import`, Python checks, Incursor Squad, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T095717310720Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Phobos Librarius command coverage: Soul Sight's immediate Shooting-phase choice now uses `MatchCommandService` without presenting it as a persisted pending decision; a non-active player is rejected without mutation. Shrouding continues through its normalized envelope. Focused verification passed **8/8 processes** (`import`, Python checks, Phobos Librarian, Scout Squad, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T095940096922Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Wardens Strategium decision: post-deployment Strategium selection and Strategic Reserves declaration now use projected public commands. The opponent is rejected without mutation and the authorized flow proceeds to reserve placement before Scouts. Focused verification passed **7/7 processes** (`import`, Python checks, Wardens of Ultramar, Scout Squad, phase-close gate, pending decision and command service) at `.tools/verification/20261023T100043132455Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Brutalis Tank Shock follow-up: ordinary Vehicle Tank Shock after the Brutalis bonus use now uses `MatchCommandService`; the opponent is rejected without mutation and the owner pays the standard CP cost. Focused verification passed **8/8 processes** (`import`, Python checks, Brutalis Dreadnought, detachment stratagems, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T100132930824Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Tigurius psychic-choice follow-up: immediate Prescience and same-turn Telepathic Assault now submit through `MatchCommandService`; an opponent Prescience request is rejected without mutation. Focused verification passed **7/7 processes** (`import`, Python checks, Tigurius, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T100340515980Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Terminator Librarian command coverage: Might of Heroes, its failed psychic test and Thunderous Force now submit through `MatchCommandService`; the opponent cannot submit Might of Heroes and leaves state unchanged. Focused verification passed **7/7 processes** (`import`, Python checks, Terminator Librarian, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T100431937018Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Librarian psychic command coverage: Force Dome and Veil of Time, including failed psychic rolls, now submit through `MatchCommandService`; the opponent cannot submit Force Dome and leaves state unchanged. Focused verification passed **9/9 processes** (`import`, Python checks, Librarian, Terminator Librarian, Tigurius, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T100514183078Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Master of Shadows choices: Aethon Shaan's immediate Command selection now uses raw public `SELECT_UNIT_CHOICE` because it has no persisted projection, and the Charge re-roll uses the normalized stratagem envelope through `COMMAND_REACTION`; the opponent is rejected without mutation and the authorized free re-roll costs 0 CP. Focused verification passed **9/9 processes** (`import`, Python checks, Aethon Shaan, Wrath of the Rock, core reactions, phase-close gate, resolution frame, command service and stratagems) at `.tools/verification/20261023T103431553347Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Calgar preparation and doctrine choices: Cato's conditional Support attachment and Calgar's Thunderhawk Insertion now submit through projected `MatchCommandService` choices; the opponent's attachment submission is rejected without mutation. Movement-phase Master Tactician also uses the public command. Focused verification passed **7/7 processes** (`import`, Python checks, Marneus Calgar, Victrix Honour Guard, phase-close gate, pending decision and command service) at `.tools/verification/20261023T100825496803Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Caanok preparation decision: Cerebrex Logic Engine's Scout target now submits through its projected preparation choice; the opposing player is rejected without mutation. Focused verification passed **7/7 processes** (`import`, Python checks, Caanok Var, Marneus Calgar, phase-close gate, pending decision and command service) at `.tools/verification/20261023T100920933646Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Lord of the Ravenwing continuation: the saved Charge re-roll now submits through the normalized `COMMAND_REACTION` envelope; the opponent is rejected without mutation, the original Charge frame resumes after the re-roll, and replaying the resolved decision is rejected. Focused verification passed **8/8 processes** (`import`, Python checks, Wrath of the Rock, detachment stratagems, stratagems, phase-close gate, resolution frame and command service) at `.tools/verification/20261023T101019961079Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Flawless Riders Charge continuation: its post-mobility Charge-roll acceptance now uses the normalized `COMMAND_REACTION` envelope; the opposing player is rejected without mutation before the same Charge proceeds. Focused verification passed **7/7 processes** (`import`, Python checks, Spearpoint Stratagems, stratagems, phase-close gate, resolution frame and command service) at `.tools/verification/20261023T101138097708Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Honour of Vigilance Advance reaction: the Devastator Doctrine re-roll now uses the normalized `COMMAND_REACTION` envelope; the opponent is rejected unchanged and the owner replaces the Advance die at no CP cost. Focused verification passed **8/8 processes** (`import`, Python checks, Devastator Brethren, Tempered in Battle, stratagems, phase-close gate, resolution frame and command service) at `.tools/verification/20261023T101253457950Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Wrath of the Chapter Advance reaction: the Tacticus re-roll now uses `COMMAND_REACTION`; the opponent is rejected without mutation and the free reroll resumes the movement workflow. Focused verification passed **7/7 processes** (`import`, Python checks, Combat Doctrines, detachment stratagems, phase-close gate, resolution frame and command service) at `.tools/verification/20261023T101405405162Z/results.json` (`network: false`, Godot 4.7.2). `test_combat_doctrines` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Reanimation command hand-off: the Necron Command Battle-shock accept decision now goes through normalized `COMMAND_REACTION`; the opponent is rejected unchanged, and the accepted roll opens the same Reanimation sequence. Focused verification passed **8/8 processes** (`import`, Python checks, Reanimation Protocols, attached Reanimation, Tempered in Battle, phase-close gate, pending decision and command service) at `.tools/verification/20261023T101518417391Z/results.json` (`network: false`, Godot 4.7.2). `test_reanimation_protocols` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Insane Bravery decision: after the specialized My Will Be Done discount declaration, the resulting Command Battle-shock option now submits through normalized `COMMAND_REACTION`; the opponent is rejected without mutation and the accepted free stratagem consumes the discount without CP. Focused verification passed **7/7 processes** (`import`, Python checks, current UnitActions, stratagems, phase-close gate, resolution frame and command service) at `.tools/verification/20261023T101636576285Z/results.json` (`network: false`, Godot 4.7.2). Current UnitActions and stratagems reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Heroic Intervention charge continuation: Leap to Defend and Into the Fray now accept their Charge results through normalized `COMMAND_REACTION`; the active player is rejected from the responder's pending roll, and the accepted commands continue the same charge workflows. Focused verification passed **7/7 processes** (`import`, Python checks, core reactions, phase-close gate, resolution frame, stratagems and command service) at `.tools/verification/20261023T101805916857Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Tempered in Battle reaction completion: Command Battle-shock accept/re-roll and Desperate Escape Battle-shock re-roll now submit through normalized `COMMAND_REACTION`; the opposing player is rejected without mutation, saved decisions block phase close, and authorized choices resume the original Command or Movement continuation. The no-Core-Stratagem fallback remains normalized through UnitActions. Focused verification passed **9/9 processes** (`import`, Python checks, Tempered in Battle, morale/coherency, movement rerolls, phase-close gate, resolution frame, command service and stratagems) at `.tools/verification/20261023T101918353882Z/results.json` (`network: false`, Godot 4.7.2). Movement rerolls and stratagems reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Led Sudden Storm Advance continuation: its Advance re-roll now submits through normalized `COMMAND_REACTION` while Movement is pending; the other player is rejected without mutation and the authorized result resumes movement without spending CP. Focused verification passed **8/8 processes** (`import`, Python checks, detachment stratagems, Spearpoint stratagems, phase-close gate, resolution frame, damage allocation and command service) at `.tools/verification/20261023T102219951210Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Stormlance and Spearpoint Advance reactions: Stormseer's Wisdom and Supercharged Engines now submit through normalized `COMMAND_REACTION`; the opponent is rejected without mutation and each free re-roll resumes the pending Advance. Focused verification passed **8/8 processes** (`import`, Python checks, Spearpoint Enhancements, Stormlance Enhancements, phase-close gate, resolution frame, stratagems and command service) at `.tools/verification/20261023T102337314305Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Terminator Captain choices: immediate Strategic Acumen now uses public `SELECT_UNIT_CHOICE`, and Unstoppable Valour plus eligible paid Command Re-roll submit through normalized `COMMAND_REACTION`; wrong-owner/stale Valour commands leave Charge unchanged, the free choice replaces both dice, and the paid alternative spends one CP. Focused verification passed **7/7 processes** (`import`, Python checks, Terminator Captain, Marine ability boundaries, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104223575878Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Tor Garadon Signum Array: its immediate target choice now uses raw public `SELECT_UNIT_CHOICE`; the opposing player is rejected without mutation, and the authorized action removes cover from the selected enemy for the Shooting phase. Focused verification passed **6/6 processes** (`import`, Python checks, Tor Garadon, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104333896028Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Phobos Lieutenant doctrine reaction: the immediate Captain Strategic Acumen choice and the resulting persisted Demi-company Commander response now use `MatchCommandService`; an opponent submission to Strategic Acumen is rejected without mutation. Focused verification passed **8/8 processes** (`import`, Python checks, Phobos Lieutenant, Marine ability boundaries, current UnitActions, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104423316744Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; the other selected checks did not. No LAN or host/guest test was run.

23 October A2 Kayvaan Shrike Warlord declaration: the projected UnitActions choice now submits through its normalized envelope; the opponent is rejected without mutation and the authorized owner records Shrike as Warlord. Focused verification passed **8/8 processes** (`import`, Python checks, Kayvaan Shrike, Tigurius, Marine ability boundaries, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104620727317Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Chaplain attachment: the deployment choice now submits through the projected UnitActions envelope; the opponent is rejected without mutation and the authorized owner attaches the Chaplain to a source-listed Intercessor bodyguard. Focused verification passed **8/8 processes** (`import`, Python checks, Chaplain, Marneus Calgar, Chaplain on Bike, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104749849167Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Judiciar Support attachment: the conditional Support choice now submits through its projected UnitActions envelope; the opponent is rejected without mutation before the owner attaches to the allowed bodyguard. Focused verification passed **8/8 processes** (`import`, Python checks, Judiciar, Chaplain, Marneus Calgar, phase-close gate, pending decision and command service) at `.tools/verification/20261023T104857594140Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Ancient Support declarations: Ancient and Bladeguard Ancient attachments now use projected UnitActions commands; the opponent is rejected without mutation and each attachment retains its Support role without consuming the separate Leader slot. Focused verification passed **9/9 processes** (`import`, Python checks, Ancients, Judiciar, Chaplain, Marneus Calgar, phase-close gate, pending decision and command service) at `.tools/verification/20261023T105002426437Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Command Re-roll persistence coverage: the serialized Movement and Charge reroll decisions now resolve through normalized `COMMAND_REACTION`; Advance placement and Charge target selection resume on their original frames, including accept, successful and worse-result choices. Focused verification passed **7/7 processes** (`import`, Python checks, movement rerolls, phase-close gate, resolution frame, stratagems and command service) at `.tools/verification/20261023T102836370415Z/results.json` (`network: false`, Godot 4.7.2). Movement rerolls and stratagems reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Detachment stratagem choices: eligible pending UnitActions projections in the detachment-stratagem regression now submit through normalized `SELECT_UNIT_CHOICE`; immediate choices without a projection retain the domain path. Focused verification passed **9/9 processes** (`import`, Python checks, detachment stratagems, Devastator Brethren, Tempered in Battle, phase-close gate, resolution frame, command service and stratagems) at `.tools/verification/20261023T102947275673Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Melta damage decision: the optional reroll and keep results now submit through normalized `SELECT_UNIT_CHOICE`, retaining the full Melta-adjusted damage expression and excess-damage handling. Focused verification passed **8/8 processes** (`import`, Python checks, Eradicator Melta Rifles, damage allocation, phase-close gate, resolution frame, command service and stratagems) at `.tools/verification/20261023T103118882786Z/results.json` (`network: false`, Godot 4.7.2). `test_stratagems` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Tigurius Warlord declaration: the eligible setup choice now uses `MatchCommandService`; an opponent submission is rejected without mutation before the owner records Tigurius as Warlord. Focused verification passed **9/9 processes** (import, Python checks, Tigurius, both Librarian suites, phase-close gate, pending decision, damage allocation and command service) at `.tools/verification/20261023T103223886193Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Caanok immediate ability choices: Cold and Calculating's Shooting Lethal Hits and Fight Sustained Hits options now use public `SELECT_UNIT_CHOICE`; the opponent is rejected without mutation on the Shooting-phase selection. Focused verification passed **6/6 processes** (import, Python checks, Caanok Var, current UnitActions, phase-close gate and command service) at `.tools/verification/20261023T103336979121Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 current UnitActions public-command coverage: the current-unit-abilities regression now submits projected decisions through their envelopes and supported immediate choices through raw `SELECT_UNIT_CHOICE`. My Will Be Done's specialized discount declaration remains on its domain path because it is not a generic UnitActions choice. Focused verification passed **8/8 processes** (`import`, Python checks, current UnitActions, Tempered in Battle, Reanimation Protocols, phase-close gate, pending decision and command service) at `.tools/verification/20261023T103705027896Z/results.json` (`network: false`, Godot 4.7.2). Current UnitActions and Reanimation Protocols reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Marine ability-boundary command coverage: projected trigger choices now use their normalized envelopes, and immediate Strategic Acumen, Demi-company Commander and Finest Hour selections use raw `SELECT_UNIT_CHOICE`. Focused verification passed **7/7 processes** (`import`, Python checks, Marine ability boundaries, current UnitActions, phase-close gate, pending decision and command service) at `.tools/verification/20261023T103829548576Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 mission-preparation command audit: the roster-validation role roll-off now submits its projected mission choice through `SELECT_UNIT_CHOICE` with its deterministic roll provider. Focused local verification passed **4/4 processes** (`import`, Python checks, `test_roster_validation` and `test_chapter_approved`) at `.tools/verification/20261023T105147561701Z/results.json` (`network: false`, Godot 4.7.2). Both Godot suites reported shutdown-only RID cleanup diagnostics; all assertions passed. No LAN or host/guest test was run.

23 October A2 out-of-turn Hungry Void command: `test_detachment_stratagems` now routes immediate choices through public `SELECT_UNIT_CHOICE`. The service admits the eligible owner during the other player's Fight actor window, while wrong-owner and stale-revision commands leave state unchanged. Responsive Tactics now tests its D6 and placement limit after a real confirmed move through the normalized reaction. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_detachment_stratagems`, `test_phase_close_gate`, `test_pending_decision` and `test_match_command_service`) at `.tools/verification/20261023T110327474412Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 mission-choice routing follow-up: the roster-validation integration now submits terrain, role roll-off, attacker/defender and Battle Ready steps through exact projected mission options. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_roster_validation`, `test_chapter_approved`, `test_match_command_service` and `test_pending_decision`) at `.tools/verification/20261023T105930222973Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 roster UnitActions command follow-up: Warlord, Support attachment and setup completion now use public `SELECT_UNIT_CHOICE`; the current UnitActions decision and option IDs are attached when a projection exists. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_roster_validation`, `test_chapter_approved`, `test_match_command_service` and `test_pending_decision`) at `.tools/verification/20261023T110045217617Z/results.json` (`network: false`, Godot 4.7.2). Both roster and Chapter Approved suites emitted shutdown-only RID cleanup diagnostics while passing. No LAN or host/guest test was run.

23 October A2 mission and Hungry Void admission cross-check: focused local verification passed **8/8 processes** (`import`, Python checks, `test_detachment_stratagems`, `test_roster_validation`, `test_chapter_approved`, `test_phase_close_gate`, `test_pending_decision` and `test_match_command_service`) at `.tools/verification/20261023T110528323411Z/results.json` (`network: false`, Godot 4.7.2). The two UI-heavy mission suites emitted shutdown-only RID cleanup diagnostics; all assertions passed. The cross-check covers the bounded non-actor Hungry Void exception and public mission/roster command flows. No LAN or host/guest test was run.

23 October A2 Desperate Escape allocation command: successful mortal-wound allocations now submit the current normalized `escape-wounds` decision through `ALLOCATE_ESCAPE_WOUND`; wrong-owner and stale-option submissions are rejected without mutation. The test confirms the same Movement frame stays suspended across multiple allocations and resumes when the final wound is allocated, including a prevented-wound case. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_escape_rerolls`, `test_phase_close_gate`, `test_pending_decision` and `test_match_command_service`) at `.tools/verification/20261023T130047839656Z/results.json` (`network: false`, Godot 4.7.2). `test_escape_rerolls` reported headless RID cleanup diagnostics despite passing; the other selected checks did not. No LAN or host/guest test was run.

23 October A2 Desperate Escape reaction command: accept and Command Re-roll now submit the current `stratagems` decision through `COMMAND_REACTION`, including its decision and option IDs. Wrong-owner and stale-option submissions are rejected unchanged, and replaying the resolved reroll decision is refused. The previous public allocation path remains covered in the same regression. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_escape_rerolls`, `test_phase_close_gate`, `test_pending_decision` and `test_match_command_service`) at `.tools/verification/20261023T130227071301Z/results.json` (`network: false`, Godot 4.7.2). `test_escape_rerolls` reported headless RID cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Terminator Chaplain reserve declaration: standalone Deep Strike reserve selection and the attached Chaplain-plus-Terminator squad's reserve-cost check now submit the projected preparation option through `SELECT_UNIT_CHOICE`. The public command rejects wrong-owner and stale-option attempts, enforces the 500-point half-army limit without mutation, and accepts the eligible 1,000-point declaration with the combined 265-point cost. Focused local verification passed **7/7 processes** (`import`, Python checks, `test_terminator_chaplain`, `test_chapter_approved`, `test_match_command_service`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T130659939382Z/results.json` (`network: false`, Godot 4.7.2). `test_chapter_approved` reported headless cleanup diagnostics despite passing; other selected checks did not. No LAN or host/guest test was run.

23 October A2 Terminator Chaplain preparation follow-up: the Chaplain's Relic Shield/bolter swap now uses the same projected `SELECT_UNIT_CHOICE` path as reserve declarations. The focused cross-check again passed **7/7 processes** at `.tools/verification/20261023T130805465751Z/results.json` (`network: false`, Godot 4.7.2); `test_chapter_approved` was the only selected suite with shutdown-only cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Aggressor preparation choice: the whole-unit alternate loadout and restoration now submit their projected preparation options through `SELECT_UNIT_CHOICE`. Wrong-owner and stale-option commands are rejected without mutation; serialized weapon configuration and subsequent attack-plan behavior remain covered. Focused local verification passed **7/7 processes** (`import`, Python checks, `test_aggressors`, `test_terminator_chaplain`, `test_match_command_service`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T130941057494Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Ancient loadout command: the Ancient's pistol/rifle and power-weapon/rifle combinations now submit through the projected `SELECT_UNIT_CHOICE` preparation decision. Wrong-owner and stale-option submissions leave the equipment state unchanged; authorized swaps preserve the existing weapon-boundary checks. Focused local verification passed **8/8 processes** (`import`, Python checks, `test_ancients`, Judiciar, Chaplain, command service, pending decision and phase-close gate) at `.tools/verification/20261023T131035255904Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 current Captain loadouts: ranged upgrades, Power Fist selection and restoration now use the projected `SELECT_UNIT_CHOICE` command. The helper sends a wrong-owner attempt through the service rather than filtering it locally; the regression also rejects a stale option without mutation and preserves source-profile assertions. Focused local verification passed **7/7 processes** (`import`, Python checks, `test_captain_current`, Marine ability boundaries, command service, pending decision and phase-close gate) at `.tools/verification/20261023T131148104897Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Bladeguard Sergeant pistol preparation: the three supported pistol selections now use projected `SELECT_UNIT_CHOICE` envelopes, with wrong-owner and stale-option attempts rejected without mutation. The focused cross-check passed **7/7 processes** (`import`, Python checks, `test_bladeguard`, `test_current_unit_abilities`, `test_match_command_service`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T131918617776Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` emitted shutdown-only RID cleanup diagnostics despite passing; other selected checks did not. This is local command-path coverage, not network validation or rules certification.

23 October A2 Scout Squad preparation: Sniper Rifle, Heavy Bolter, Shotgun and Sergeant wargear choices now use projected `SELECT_UNIT_CHOICE` envelopes. The existing model-count and special-weapon limits remain covered; wrong-owner and stale-option commands are rejected unchanged. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_scout_squad`, command service, pending decision and phase-close gate) at `.tools/verification/20261023T132101933582Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Vanguard Veteran preparation: Combat Shield, ordinary and Sergeant Plasma Pistols, and the Sergeant Thunder Hammer now submit projected public unit choices. Wrong-owner and stale-option requests are rejected unchanged; bearer-specific invulnerable saves, weapon profiles and the ordinary-model pistol cap remain covered. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_vanguard_veterans`, command service, pending decision and phase-close gate) at `.tools/verification/20261023T132239228518Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Invader ATV preparation: each Multi-melta swap and cannon restoration now uses a projected public unit-choice command. Wrong-owner and stale-option requests are rejected unchanged, and the existing per-model point-cost checks remain covered. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_invader_atvs`, command service, pending decision and phase-close gate) at `.tools/verification/20261023T132323582244Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 Reiver preparation: Grav-chutes and Grapnel Launchers now submit projected public unit-choice commands. The regression rejects wrong-owner and stale-option commands unchanged, while retaining the Deep Strike and grapnel-eligibility checks. Focused local verification passed **6/6 processes** (`import`, Python checks, `test_reiver_squad`, command service, pending decision and phase-close gate) at `.tools/verification/20261023T132411019985Z/results.json` (`network: false`, Godot 4.7.2), without cleanup diagnostics. No LAN or host/guest test was run.

23 October A2 My Will Be Done and final direct-choice migration: the Core Stratagem reaction projection now includes the eligible My Will Be Done discount and applies it through normalized `COMMAND_REACTION`. Wrong-owner and stale-revision attempts are rejected unchanged; Insane Bravery then spends the discount without CP. Three remaining direct preparation calls in Hammer of Wrath and Jump Pack Captain tests now use the public command service. Focused verification passed **8/8 processes** (`import`, Python checks, `test_current_unit_abilities`, `test_hammer_of_wrath`, `test_jump_pack_captain`, `test_match_command_service`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T140326481247Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` emitted shutdown-only renderer cleanup diagnostics despite passing; all assertions passed. The non-network test tree now has zero direct `Combat.unit_action`/`C.unit_action` calls. This is local command-path evidence, not network validation, rules certification or completion of the broader A2 pending-workflow audit.

23 October A2 decision-source audit: the ten registered pending-decision sources map to public command routes and focused source regressions. The combined source/gate check passed **19/19 processes** at `.tools/verification/20261023T140953672503Z/results.json` (`network: false`, Godot 4.7.2). The current inventory and its scope limits are recorded in [A2 pending-workflow audit](a2-pending-workflow-audit.md); this does not establish per-workflow save/restore and continuation coverage or network behavior.

23 October A2 reaction-option admission follow-up: My Will Be Done's normalized `COMMAND_REACTION` rejects a stale option ID as well as a wrong owner and stale revision, leaving match state unchanged. The focused cross-check passed **6/6 processes** (`import`, Python checks, `test_current_unit_abilities`, `test_match_command_service`, `test_pending_decision` and `test_phase_close_gate`) at `.tools/verification/20261023T141510253642Z/results.json` (`network: false`, Godot 4.7.2). `test_current_unit_abilities` emitted shutdown-only renderer cleanup diagnostics; all assertions passed.

23 October A2 Repulsor Combat Embarkation continuation: the regression now submits Charge contact start, target revision and resumed placement through `MatchCommandService`. The defender's projected response survives save/restore with the same decision ID/options and suspended Charge frame; pass or embark retains that frame, phase close remains blocked, and stale-option/wrong-owner submissions leave state unchanged. Focused verification passed **7/7 processes** (`import`, Python checks, `test_marine_repulsor_combat_embarkation`, `test_match_command_service`, `test_pending_decision`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T141835733242Z/results.json` (`network: false`, Godot 4.7.2). This is local command-path evidence only.

23 October A2 legacy mounted-reaction continuation: the legacy `mounted-shooting-reaction` discriminator is now exercised as a saved pending defender choice. The public normalized pass resumes and completes its bound attack after restore. Focused verification passed **7/7 processes** (`import`, Python checks, `test_combat_doctrines`, `test_match_command_service`, `test_pending_decision`, `test_phase_close_gate` and `test_resolution_frame`) at `.tools/verification/20261023T142259750291Z/results.json` (`network: false`, Godot 4.7.2). A2 has one tracked open workflow-audit item; the number of underlying defects is not yet known. No LAN or host/guest test was run.

23 October A2 deployment actor and remaining UnitActions public-path sweep: alternating Deployment now projects immediate UnitActions choices for the owner of the current deploying squad. Vulkan's Seeker of the Unfound checks deployment decision ownership, save/restore identity, wrong-owner rejection and stale-option rejection, then resolves through `SELECT_UNIT_CHOICE`. Remaining rule tests that called `UnitActions.apply()` directly were migrated to the public command helper; Stormlance's isolated Shooting state now clears its previous test-only Movement frame. Headhunter and Emergency Disembark assert their registered window kinds explicitly. The combined targeted cross-check passed **19/19 processes** (`import`, Python checks, ten feature regressions, transport destruction, Ironstorm, Combat Doctrines, command service, pending registry, phase-close gate and resolution frames) at `.tools/verification/20261023T143422584566Z/results.json` (`network: false`, Godot 4.7.2). No LAN or host/guest test was run.

23 October A2 continuation-family cross-check: Deployment, phase-start/end, Movement, Escape allocation, Charge/Repulsor contact, Fight selection, attack/reactions, Reanimation, coherency, ingress and transport continuations passed **24/24 processes** at `.tools/verification/20261023T143815711796Z/results.json` (`network: false`, Godot 4.7.2). Follow-up assertions for the legacy mounted-reaction and reserve-ingress discriminator names passed **8/8 processes** at `.tools/verification/20261023T144214641197Z/results.json`. The bounded A2 map now covers 10/10 pending-decision source families, contextual test references for all 53 admitted window kinds and lifecycle evidence for all eight persisted frame families. This closes known A2 command-path/continuation gaps in the local supported scope; it is not full rules certification or network validation.

23 October tactical consolidation and performance follow-up: `MatchActor.player()` now uses a cheap validated phase-decision owner query before projecting the full UnitActions option list, and the HUD reuses one authoritative command precondition while rendering the five movement-type rows. On the same 40-model host checkpoint and 20-command sequence, the debug profile dropped `_refresh TOTAL` from about 2.32 million to 1.00 million microseconds; movement-reference work dropped to about 217 thousand microseconds. Direct Godot checks passed `test_match_actor.gd` (0 failures), `test_pending_decision.gd` (0 failures), `test_tactical_combat_flow.gd` (0 failures) and `test_tactical_training.gd` (0 failures; shutdown-only RID/ObjectDB diagnostics). The local change preserves per-command option, revision, ownership and cost validation. The earlier full loopback run at `.tools/verification/20261023T220533843705Z/results.json` remains retained as failure history; it was superseded by the clean `6/6` network rerun at `.tools/verification/20261023T225711261053Z/results.json`. Separate-machine LAN remains explicitly deferred by the user.
23 October demo distribution check (UTC report timestamp 20261024T011854705902Z): `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --target pack` passed `import`, `export` and `exported-startup` at `.tools/verification/build-20261024T011854705902Z/results.json`, producing a 1.4 MB offline `open-tabletop-demo.pck`. Native Windows and Linux export attempts were rejected before export because the matching Godot 4.7.2 release templates were not installed (`windows_release_x86_64.exe` and `linux_release.x86_64` missing). This confirms the pack path only; native artifacts and cross-platform interaction remain unverified.
24 October focused tactical recheck: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tactical_training --only test_tactical_combat_flow --only test_guided_turn_ui --timeout 300` passed **5/5 processes** at `.tools/verification/20261024T064117338648Z/results.json`. This recheck covers the current asymmetric formations, legal combat opportunities, guided phase cues and integrated tactical combat flow. It remains local evidence; it does not establish human comprehension, separate-machine LAN, remote CI or native release artifacts.

24 October final tactical-UX targeted regressions: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_ability_reference --only test_selection_response --only test_selection_card --only test_decision_camera --only test_choice_ownership_ui --only test_gameplay_layout --only test_roll_choice_ui --only test_save_outcome_ui --only test_combat_tray --only test_attack_feedback --only test_match_result_ui --only test_pending_decision --only test_resolution_frame --only test_guided_turn_ui --only test_tactical_training --only test_tactical_combat_flow --only test_attack_rerolls --only test_save_rerolls --only test_damage_rerolls --only test_damage_allocation --timeout 300` passed **22/22 processes** at `.tools/verification/20261024T230814521351Z/results.json` (`network: false`, no cleanup diagnostics). The damage-reroll check saves and reloads an actual pending allocation, comparing state, RNG, legal options, defender ownership and attack continuation. The row-selection regression verifies in-place row styling and rebuild on displayed wound changes. The reader suite covers local fixtures and explicit source failures; the real project snapshot audit separately resolves 192 identities and 882 ability records from the 23-file `20261021T130623Z` export.

24 October final local integration: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile demo --network --timeout 300` passed **13/13 processes** at `.tools/verification/20261024T230025979983Z/results.json` (`network: true`, `legacy_starter_staged: false`, no cleanup diagnostics). Host and client were run sequentially. This is loopback coverage for the bounded demo and tactical profile; it is not separate-machine LAN evidence.

24 October final PCK: `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --target pack --timeout 300` passed **5/5 stages** at `.tools/verification/build-20261024T224938400914Z/results.json`. The exported-pack smoke verifies startup, training setup, absent optional source text with implemented scope still visible, read-only datasheet inspection, and exact save/load state and RNG recovery. The PCK is `.tools/verification/build-20261024T224938400914Z/open-tabletop-demo.pck`, 1,486,836 bytes, SHA-256 `a95a65c6d639dc780d8225add1fb880b1b5fd3fd8a11da7acc1ab1a79adfdabe`; no source CSV filename or export workbook is present in the artifact. Native Windows/Linux builds remain blocked by missing matching Godot 4.7.2 templates. Human acceptance, separate-machine LAN and remote CI remain open.

27 October Space Marines fixture follow-up: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_company_heroes_current --only test_aggressors --only test_redemptor_dreadnought --timeout 300` passed **5/5 processes** (import, Python checks and all three selected suites) at `.tools/verification/20261027T045432731737Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). These fixtures use current Space Marines catalogs for both players and pass in the isolated verification copy without the optional legacy starter pack. This clears the fixture blocker only; the suites assert bounded materialization, loadout, attack-plan and combat behavior, and do not add any complete source-bounded datasheet scope.

27 October Inceptor Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_inceptor_squad --timeout 300` passed **3/3 processes** (project import, Python checks and Inceptor suite) at `.tools/verification/20261027T063205977865Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). Coverage includes source composition and cost tiers, each model’s Plasma choice, Assault Bolters/Plasma/Ceramite Fists through Equipment and AttackPlan, Meteoric Descent boundaries, Deep Strike Ingress-choice exposure and Parabolic Jetleap reserve/phase-close continuation. This closes only the declared shared-book local Inceptor scope; whole-army legality, complete Ingress placement, network validation and human playtesting remain open.

27 October Assault Intercessor Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_assault_intercessor_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T072248470555Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers both prices/compositions, all five Sergeant replacements and restoration through public setup commands, model/owner/stale-choice boundaries, all eight weapon profiles through Equipment and AttackPlan, Targeted Intercession on the Thunder Hammer, and the paired 153-link relation map. This closes only the source-bounded local shared-book scope; army legality and network validation remain open.

27 October Heavy Intercessor Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_intercessor_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261027T073729361442Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks both source-priced sizes, all characteristics and keywords, all four weapon profiles through Equipment and AttackPlan, the public Heavy Bolter replace/restore path and 1-per-5 cap, the five source Leader/Support links, and Unyielding through objective control and the damage save resolver. This closes only the source-bounded local shared-book scope; army legality and network validation remain open.


27 October Invictor Tactical Warsuit source-bounded scope: the current-catalog datasheet suite now checks six weapon profiles, the public autocannon replacement/restoration and rejection boundaries, Damaged 4 through AttackPlan, Deadly Demise D3's allocation decision, Scouts 8 reserve eligibility and movement boundary, and Forward Assault marking/replacement through a saved attack continuation. Focused offline verification passed **4/4 processes** (`import`, Python checks, Invictor and the 153-link Leader/Support map) at `.tools/verification/20261027T074848766922Z/results.json` (`network: false`, `legacy_starter_staged: false`), without cleanup diagnostics. This closes only the Invictor's source-bounded local scope; full army legality and network validation remain open.

27 October Ancient and Bladeguard Ancient source-bounded scopes: the existing combined suite now materializes both players from the current Marine catalog and covers both source profiles, admission, all seven weapon profiles through Equipment and AttackPlan, Ancient's reversible public Power Weapon choice and rejection boundaries, Honour of the Company, both Raise the Banner sources, Deeds of Legend, Support matching and Dark Angels Deathwing context. Focused offline verification passed **4/4 processes** (`import`, Python checks, Ancient suite and the 153-link relation suite) at `.tools/verification/20261027T080140069584Z/results.json` (`network: false`, `legacy_starter_staged: false`), without cleanup diagnostics. This closes only the two source-bounded local scopes; full army legality and network validation remain open.

27 October Eradicator Squad with Heavy Bolters source-bounded scope: the suite now uses the current Marine catalog for both players and verifies the 3/6-model profiles, first-two and third-plus prices, fixed 40 mm loadout, three weapon profiles through Equipment and AttackPlan, all five Leader links and Biologis Support, current-catalog admission, and Overlapping Destruction ownership/effect boundaries. Focused offline verification passed **4/4 processes** (import, Python checks, datasheet suite and the 153-link relation suite) at `.tools/verification/20261027T081515345154Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). This closes only this shared-book local scope; full army legality and network validation remain open.
27 October Infernus Squad source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_infernus_squad_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, Infernus suite and the 153-link relation suite) at `.tools/verification/20261027T081932784642Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers both current Marine catalogs, 5/10-model composition and costs, all three weapon profiles through Equipment and AttackPlan, Leader links, Driven from Cover's target/owner/phase boundaries and real cover effect, save/resume, expiry, and rejection of a third copy in the checked Incursion roster. This closes only the declared source-bounded local Infernus scope; full army legality and network validation remain open.
27 October Gladiator Lancer source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gladiator_lancer --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, the Lancer suite and the 153-link relation suite) at `.tools/verification/20261027T082732292887Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite covers both players, the one-model/100 mm profile, source costs and three-copy cap, the fixed loadout and every weapon through Equipment and AttackPlan, Aquilon Optics' target and public-choice boundaries, Damaged 4 and Deadly Demise D3. This closes only the declared shared-book local scope; full army legality and network validation remain open.
27 October Gladiator Valiant source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gladiator_valiant --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, the Valiant suite and the 153-link relation suite) at `.tools/verification/20261027T083654769142Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks both players, the 100 mm/one-model profile, every weapon instance and trait, the tiered costs and three-copy cap, Priority Target Acquisition at its range boundary and immediately beyond, Damaged 4 and Deadly Demise D3. This closes only the declared shared-book local scope; full army legality and network validation remain open.
27 October Ballistus Dreadnought source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_ballistus_dreadnought --only test_ballistus_dreadnought_profile_parity --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, Ballistus scope, profile parity and the 153-link Leader/Support suite) at `.tools/verification/20261027T084333440820Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite covers both players, all five fixed weapon modes through Equipment and AttackPlan, Ballistus Strike at/around 24 inches, Damaged 4, nested Deadly Demise allocation/resumption and one-to-four-copy construction. This closes only the declared shared-book local scope; full army legality and network validation remain open.

27 October Techmarine source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_techmarine --only test_techmarine_profile_parity --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, Techmarine scope, profile parity and the 153-link Leader/Support suite) at `.tools/verification/20261027T085333172418Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite covers both players, the fixed profile and three weapon plans, Lone Operative targeting boundaries, Blessings of the Omnissiah timing/healing/modifier duration, and save/restore. This closes only the declared shared-book local scope; full army legality and network validation remain open.


27 October Apothecary source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_apothecary --only test_apothecary_profile_parity --only test_infiltrator_squad --only test_space_marine_leader_links --timeout 300` passed **6/6 processes** (import, Python checks and all four selected suites) at `.tools/verification/20261027T092025938936Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The run closes only the shared-book Apothecary and Infiltrator scopes described in their audits; network validation and full faction/army legality remain open.

27 October Apothecary Biologis source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_biologis --only test_apothecary_biologis_profile_parity --only test_space_marine_leader_links --only test_eradicator_heavy_bolters --timeout 300` passed **6/6 processes** (import, Python checks, Biologis scope, profile parity, the 153-link Leader/Support map and Eradicator Heavy Bolter bodyguard regression) at `.tools/verification/20261027T093653231740Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks Vivispectral Analysis Targeting against living target keywords, source loss, all four shared-book Support links, fixed weapons through Equipment/AttackPlan and roster admission. This closes only the shared-book Biologis scope; full army legality and network validation remain open.

27 October Chaplain source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chaplain_current --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, current-catalog Chaplain suite and the 153-link Leader/Support relation suite) at `.tools/verification/20261027T100107251997Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the one-model/60-point fixed profile, both weapons through Equipment/AttackPlan, all six shared-book Leader choices, current-catalog admission, Litany of Hate and Spiritual Leader timing, range, source-life and per-round limits. This closes only the declared common-book Chaplain local scope; full army legality and network validation remain open.

27 October Chaplain on Bike and Chaplain With Jump Pack source-bounded scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chaplain_on_bike --only test_chaplain_with_jump_pack --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, both datasheet suites and the 153-link Leader/Support relation suite) at `.tools/verification/20261027T103130253761Z/results.json` (`network: false`, no cleanup diagnostics). The bike suite covers fixed equipment/admission, Outrider attachment, Catechism target choice and attack effects, Litany and attack planning; the Jump Pack suite covers both common-book Leader links, Deep Strike, complete Crozius attacks and Exhortation at above/at/below half-strength. These results close only the two common-book local sheet scopes; the bike's oval-base proxy, network validation and full army legality remain outside the result.

27 October Storm Speeder and Gladiator Reaper source-bounded scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_storm_speeder_hammerstrike --only test_storm_speeder_hailstrike --only test_storm_speeder_thunderstrike --only test_gladiator_reaper_current --only test_space_marine_leader_links --timeout 300` passed **7/7 processes** (import, Python checks, four current-catalog datasheet suites and the 153-link Leader/Support suite) at `.tools/verification/20261027T104505989012Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suites compare all weapon fields and traits through Equipment/AttackPlan, test the current catalog for both players, source prices and copy limits, and cover each sheet's unique weapon/ability boundaries. The four common-book local scopes are closed; full army legality and network validation remain open.

27 October Drop Pod source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_drop_pod --only test_marine_transport_admission --timeout 300` passed **4/4 processes** (import, Python checks, Drop Pod scope and transport-admission regression) at `.tools/verification/20261027T110036757480Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the one-model source profile, custom-geometry proxy, all transport keywords/restrictions, Deep Strike, Deadly Demise 1, 60/60/70 point tiers, four-copy local ceiling, both-player catalog materialization, required reserves and half-army cap, first-turn ingress, sequential compulsory Rapid Disembark at more than 8 inches from enemies, save/restore, no Hazard on Rapid Disembark, Deployment Complete and later embark rejection. The local copy cap remains four; Strike Force copy slots five and six, category-aware limits, the Gauntlet Task Force Aggressive Disembarkation cross-interaction, full army legality and network validation remain outside this evidence. See [the Drop Pod audit](../marine-drop-pod.md).


27 October Librarian in Terminator Armour source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_librarian_terminator --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** (import, Python checks, dedicated suite and all 153 common-book Leader/Support links) at `.tools/verification/20261027T114625824325Z/results.json` (SHA-256 `c2d1abc551223301349a1fa7ed9c6195de3c0ca0d7e48d787e03d8bb29904169`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks the exact fixed profile, all four weapon routes through Equipment/AttackPlan, both-player admission/materialization, Deep Strike and Combat Doctrines metadata, Psychic Hood boundaries, both level-1 Librarius powers, Battle-shock on a psychic roll of 1, and the per-round use limit. This closes only the shared-book local sheet scope; `DEATHWING` remains chapter-conditional, network validation remains deferred and full army legality is not certified. See [the datasheet audit](../marine-librarian-terminator-armour.md).

27 October Terminator leader source-bounded scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_ancient --only test_terminator_captain --only test_terminator_chaplain --only test_space_marine_leader_links --timeout 300` passed **6/6 processes** (import, Python checks, all three current-catalog datasheet suites and the shared 153-link Leader/Support suite) at `.tools/verification/20261027T115826825089Z/results.json` (SHA-256 `08f2d566467befc6aaff28ffe5fc8345460c97b7556611bebbf922f458cf3881`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suites cover the declared Ancient, Captain in Terminator Armour and Chaplain in Terminator Armour scopes, including both-player admission/materialization and every listed weapon through Equipment/AttackPlan. This closes only those three shared-book local scopes; full army legality, Chapter-book links, network validation, complete matches and playtesting remain open.

27 October Adrax Agatone and Kor'sarro Khan source-bounded scopes: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_adrax_agatone --only test_kor_sarro_khan --only test_space_marine_leader_links --timeout 300` passed **5/5 processes** (import, Python checks, both current-catalog datasheet suites and all 153 common-book Leader/Support relations) at `.tools/verification/20261027T121145243348Z/results.json` (SHA-256 `74608c5dded5965ecba9f88ca029e89521da757a26b95356944ba03b125d1e0a`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suites cover the declared shared-book scopes, including exact profiles, all fixed weapons through Equipment/AttackPlan, Adrax's Combat Doctrines and named effects, Kor'sarro's target-gated rerolls and Anti attack paths, and both-player current Marine rosters. The source-linked Vanguard Veteran Squad target comes from Warhammer Legends and remains outside the shared 85-sheet scope. Chapter/army legality and network validation remain open.

27 October Aethon Shaan source-bounded scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aethon_shaan --only test_aethon_shaan_profile_parity --only test_marine_conditional_weapon_traits --timeout 300` passed **5/5 processes** at `.tools/verification/20261027T122224029113Z/results.json` (SHA-256 `4edc1737cb7f6019dffec4358478db90ad2ffb3d7c7ce170a1a81eda00c97357`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks Aethon's source profile, both fixed weapons through Equipment/AttackPlan, conditional Claws of Severax traits, both-player current Marine rosters, Core/Army abilities, Master of Shadows and Blackwing Mantle. This closes only Aethon's local shared-book scope; Raven Guard/Chapter and army legality and network validation remain open.


### Victrix Honour Guard role-composition closure — 27 October 2026

The Victrix scope now covers all eight source-listed Ancient/Champion/Guard compositions at 3 or 6 models, optional Banner pricing and current-catalog admission. The focused rules run passed 3/3 offline processes (test_victrix_honour_guard, Python checks and Godot import) in .tools/verification/20261027T221923236402Z/results.json (SHA-256 9bc2f3c4b354e2a09c87b84af25ec4de5bdbE61012f753168edd83f4d4ec9837), with network false and no legacy starter staging. The Army Workshop selector and saved Bannerless cost passed in .tools/verification/20261027T221801613709Z/results.json (SHA-256 26e3eb486ec74a69357186b3e73aedf8b4be61154b8176b41e29c6b47f0d8335). This closes one shared-book local datasheet scope; it does not certify full army legality, network behavior or human playtesting. See [the Victrix sheet audit](../marine-victrix-honour-guard.md).

### Judiciar shared-book scope closure — 27 October 2026

Focused verification passed 5/5 processes at `.tools/verification/20261027T231150548787Z/results.json` (SHA-256 `1e67c8aa3925cf6e129c9aae80e2559c7a2a2e1f81675da1fc5f8a3c94e6a8fe`): import, Python checks, the current-catalog Judiciar suite, its source-profile parity suite and all 153 common-book Leader/Support relations. The run used `network: false`, did not stage the optional legacy starter and reported no cleanup diagnostics. The suite covers the no-option 50-point source profile and two fixed weapon plans, current Marine materialization for both players, the five common-book Support targets, the melee-only invulnerable save across grouped/automatic/manual allocation, and Tempormortis Fights First priority and source lifetime. This closes only the Judiciar shared-book local sheet scope; Chapter/Legends links, full army legality, network behavior, complete matches and human playtesting remain open. See [the Judiciar audit](../marine-judiciar.md).


### Ordinary Captain shared-book scope closure — 28 October 2026

Focused verification passed **4/4 processes**: import, Python checks, `test_captain_current` and all 153 common-book Leader/Support relations. Command: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_current --only test_space_marine_leader_links --timeout 300`. Report: `.tools/verification/20261028T005647625078Z/results.json` (SHA-256 `CCF5DC0FEEC7BA9FF257E982EDBDC551EB3DEB4F4442B0124FCB2BB6B267AA04`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers seven legal equipment packages through Equipment/AttackPlan, the Relic Shield/Power Fist exclusion, wound restoration, both-player current-catalog materialization, Leader links, Strategic Acumen, Finest Hour, Warlord CP and once-per-round limits. This closes only the ordinary Captain's shared-book local sheet scope; Chapter/Legends targets, full army legality, network validation and playtesting remain open. See [the audit](../marine-captain.md).

### Captain on Bike shared-book scope closure — 28 October 2026

Focused verification passed **4/4 processes**: import, Python checks, `test_captain_on_bike` and all 153 common-book Leader/Support relations. Command: `python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_on_bike --only test_space_marine_leader_links`. Report: `.tools/verification/20261028T010904565443Z/results.json` (SHA-256 `c38ff10e4395bb75d08409d6225f904f26102f895b96ea10dff51cb37c9ec758`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The source-bounded suite checks both-player current-catalog construction, the three-copy local cap, every weapon in all four legal packages through Equipment/AttackPlan, the Outrider attachment, Combat Doctrines metadata, Warlord CP, owner-checked Strategic Acumen and the charged/uncharged Into the Fray boundary. The live Wahapedia page identifies Space Marines App 2.8.1 / October 2026, and the per-profile fixed-data comparison reports no differences. The 90 x 52 mm oval is represented by a bounding-circle proxy; Ravenwing Black Knights remain a Dark Angels Chapter-book target. This closes only the Captain on Bike shared-book local scope; full army legality, network validation, complete matches and playtesting remain open. See [the audit](../marine-captain-on-bike.md) and [source/data hashes](../marine-captain-on-bike-audit.json).

28 October Assault Intercessors With Jump Packs source-bounded scope: `python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_assault_intercessors_with_jump_packs --only test_space_marine_leader_links --only test_captain_with_jump_pack --only test_kayvaan_shrike --timeout 300` passed **6/6 processes** at `.tools/verification/20261028T014923681819Z/results.json` (SHA-256 `9c1f697cbea55dbc578df376dee60fdecad7481977fb9304368b929e2d4f0faa`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It covers source compositions, prices, choices, weapon plans, caps and Leader links. The broader copy-cost/Chaplain regression passed **8/8** at `.tools/verification/20261028T014453977946Z/results.json` (SHA-256 `0a2e3b132b02ee9d6033f0bacd401b795a6b4a4532fb900e0422f6193e949edb`; `legacy_starter_staged: true` for its supplemental local historical-starter dependency; `network: false`). The separate Hammer of Wrath run passed **3/3** at `.tools/verification/20261028T014532504875Z/results.json` (SHA-256 `20bcec476b1f747895e86c94288ef52f5f6ece19411418b02c296ba2943efcb3`; legacy training fixture; no network access).

### Bladeguard Veteran Squad source-bounded scope — 28 October 2026

`python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_bladeguard_veteran_squad --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T020001295731Z/results.json` (SHA-256 `34a97220e505def41b8e8d842ec3364a1565d8728286c5be58d49234fd4a24ca`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks both model counts and cost tiers, Incursion admission, model geometry and characteristics, all Sergeant pistol states, every weapon profile through `Equipment` and the shared `AttackPlan` helper, and materialization for both players. The relation suite checks all 153 common-book Leader/Support links, including Bladeguard's eight Leaders and six Supports.

The existing stance-behavior regression separately passed **3/3 processes** at `.tools/verification/20261028T015803358451Z/results.json` (SHA-256 `5a82ac14447337ad1953f599e7a3c8bcf3ce405efc91652c84251e45cfbb1272`; `network: false`, `legacy_starter_staged: true`). That legacy staging is required by the checked Marine-versus-Necron fixture; it does not affect the clean current-catalog scope result. The full limits and pinned export hashes are recorded in [the datasheet audit](../marine-bladeguard-veteran-squad.md) and [machine audit](../marine-bladeguard-veteran-squad-audit.json).

### Desolation Squad source-bounded scope — 28 October 2026

`python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_desolation_squad --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T020613524680Z/results.json` (SHA-256 `ffa756433f25b8790053a823768e8f80b696bfbabe5a4e4ad79c7909212a8b50`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The current-catalog suite checks the five-model profile and 32 mm bases, exact loadout and all rocket choices/reversals, every weapon route through Equipment/AttackPlan, both-player catalog materialization, Targeter Optics, Vengor Indirect Fire interactions and Incursion's two-copy limit. The source third-plus price remains recorded; Strike Force admission is not implemented. The relation suite checks all 153 common-book Leader/Support links. See [the datasheet audit](../marine-desolation-squad.md) and [machine audit](../marine-desolation-squad-audit.json).


### Eliminator Squad source-bounded scope — 28 October 2026

`python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_eliminators --only test_space_marine_leader_links --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T023439939543Z/results.json` (SHA-256 `2ad3e8176dbbed68e248b5851328b891812be766db2a56191eed6689aa54f2bd`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The source suite checks each ordinary model’s independent Las Fusil replacement and restoration, mixed loadout, Sergeant options, every weapon route through Equipment/AttackPlan, current-catalog admission and materialization, weapon traits, detection/Optics behavior and current UI labels, including stable Eliminator 1/2 equipment names and actionable replacement text. The relation suite checks all 153 common-book Leader/Support links. A broader 7/7 behavior regression passed at `.tools/verification/20261028T023543257357Z/results.json` (SHA-256 `c2877b1cd2cca1396b835d9227c6b27964b18641835daa5a564c65cf151cc006`; `network: false`); that broader run staged the optional historical starter for one or more supplemental shared-rule fixtures. See the [sheet audit](../marine-eliminator-squad.md) and [machine audit](../marine-eliminator-squad-audit.json).

### Invader ATVs shared-book scope closure — 28 October 2026

Focused offline verification passed **5/5 processes**: import, Python checks, `test_invader_atvs`, conditional weapon-trait checks and all 153 common-book Leader/Support relations. Command: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_invader_atvs --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300`. Report: `.tools/verification/20261028T061032408179Z/results.json` (SHA-256 `2789e8f3c1ec39549d7be5ea344a93f7b653ae6edcef43417e4adefb49e7871b`; `network: false`, no legacy starter staged, no cleanup diagnostics). The test checks source profiles and costs, one/two-model construction for both players, reversible per-model Multi-melta choices, AttackPlan weapon and ability contexts, the edge-to-edge 6-inch boundary, Chapter-contextual RAVENWING and empty Leader/Support target relations. “Use model” remains a documented geometry proxy limitation. Full army legality and network behavior remain outside this closure. See [the sheet audit](../marine-invader-atvs.md) and [source/data hashes](../marine-invader-atvs-audit.json).

### Land Speeder shared-book scope closure — 28 October 2026

Focused offline verification passed **5/5 processes** at `.tools/verification/20261028T062111243132Z/results.json` (SHA-256 `11f7fb3cad930bfb1047eb2719ff7c75228d269a13a6ee6e39562dc1467bc3e8`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The current Marine suite checks both-player catalog materialization, all fixed weapon plans, the reversible no-cost Pyrecannon choice, conditional Onslaught Cannon traits, Deep Strike reserve declaration and the Purgation Run use/pass, saved attack continuation, D6 Normal Move placement, owner rejection, phase-close block and Charge restriction. The Necron opponent in the CA fixture uses the optional legacy starter and is not certified by this test. The 77th common-book scope is closed; 8 option-bearing sheets remain, beginning with Outrider Squad. Full army legality and network validation remain open. See [the sheet audit](../marine-land-speeder.md) and [machine audit](../marine-land-speeder-audit.json).
28 October 2026 Space Marine roster copy-limit and Darkflight Pursuit context integration: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_detachment_roster_admission --only test_marine_category_copy_limits --only test_combat_doctrines --only test_prepared_match --only test_per_player_detachments --timeout 300` passed **7/7 processes** at `.tools/verification/20261028T075538220026Z/results.json` (SHA-256 `e4f31f9708b692f632679a8bba0a8059eb0734eafd2d0f5384af31b4ad7d968a`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). Checks standard category limits for all 85 shared-book profiles, Victrix composition-specific EPIC HERO counts, Darkflight Pursuit's Outrider BATTLELINE copy-limit grant, and the same per-player keyword in the prepared match. This closes one detachment keyword interaction; remaining attachment combinations, other detachment interactions, broader Chapter restrictions, full army legality and network validation remain open.

28 October 2026 Land Speeder Vengeance source-bounded local scope: `python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_land_speeder_vengeance --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T085143396826Z/results.json` (SHA-256 `cafc7aec5a07dd9bc4f02143ffd31e58b71dea6fa91b8861a9cb4ac65d2abe2d`; network: false, legacy_starter_staged: false, no cleanup diagnostics). It checks the pinned Dark Angels App profile, catalog admission/copy prices, Deep Strike eligibility, Storm of Vengeance trigger/target/owner/sequential-response rules, Deadly Demise D3 and Nightforged Battery's Attack and Hazard rerolls. The regression fixes preserve Dark Angels keywords after unit destruction and route the Nightforged Attack reroll through serialized attack allocation. See the [sheet audit](../marine-land-speeder-vengeance.md). This does not certify full army legality or network behavior.

28 October 2026 Ravenwing Black Knights source-bounded local scope: `python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile focused --only test_ravenwing_black_knights --only test_captain_on_bike --only test_outrider_squad_current --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T091330361383Z/results.json` (SHA-256 `8b74375d8f95fae875f78bda94b58bd0d6a92ff6da49e5cb3ed9ce5625d8f242`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the pinned Dark Angels App profile, size and copy-price tiers, weapon profiles and replacement quotas, current-catalog construction, public attachment of the Captain on Bike and Chaplain on Bike, Knights of Caliban in melee AttackPlan after a Charge move, and regression coverage for the Captain/Outrider shared-book profiles. At the time of this earlier Ravenwing Black Knights check, Sammael and Ravenwing Command Squad were still pending Leader endpoints; their datasheets and attachment behavior were subsequently integrated in the 9/9 run listed in the current Chapter coverage audit. Full Chapter roster legality and network behavior remain open. See the [sheet audit](../marine-ravenwing-black-knights.md) and [machine-readable audit](../marine-ravenwing-black-knights-audit.json).

28 October 2026 Inner Circle Companions source-bounded local scope: `python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile focused --only test_inner_circle_companions --only test_ravenwing_black_knights --only test_captain_current --only test_ancients --only test_space_marine_leader_links --only test_leader_catalog --timeout 300` passed **8/8 processes** at `.tools/verification/20261028T092644132650Z/results.json` (SHA-256 `c3b1dfb9451e5c6f6d8809889f1e8dc6bda05d11295a61b3908ea022f0c680bf`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The run checks the pinned profile, both sizes and copy-price tiers, fixed weapon plans, ability and Chapter effects, catalog limits, source relation maps and public Captain/Apothecary attachment, while rerunning Ancient and Ravenwing regressions. Four Chapter Leader endpoints remain unavailable until their sheets are integrated. Full Chapter roster legality and network behavior remain open. See [the sheet audit](../marine-inner-circle-companions.md) and [machine-readable audit](../marine-inner-circle-companions-audit.json).

28 October 2026 Asmodai source-bounded local scope: `python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile focused --only test_asmodai --only test_attack_sequence --only test_inner_circle_companions --only test_ravenwing_black_knights --only test_reiver_squad --only test_captain_current --only test_ancients --only test_space_marine_leader_links --only test_leader_catalog --only test_captain_on_bike --only test_outrider_squad_current --timeout 300` passed **13/13 processes** at `.tools/verification/20261028T094914926379Z/results.json` (SHA-256 `32295d1ddc045f220cb1e0abf8dc13120c599f4fa55960ba92e2f9100e15ce9b`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite covers Asmodai's current profile, weapons, Warlord CP, all melee Hit rerolls including successful rolls, Fight-start Battle-shock and controller-owned Tempered in Battle reroll after save/restore, including persistence of a pre-existing Battle-shock condition, plus regressions for Chapter and shared-book Leader links. Network validation and full army legality remain pending. See [the sheet audit](../marine-asmodai.md) and [machine-readable audit](../marine-asmodai-audit.json).

28 October 2026 Lazarus source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_lazarus --only test_attack_sequence --only test_captain_titus --only test_inner_circle_companions --only test_asmodai --only test_chief_librarian_tigurius --timeout 300` passed **8/8 processes** at `.tools/verification/20261028T100238026258Z/results.json` (SHA-256 `4246119a7dc0ad9c103c287e9b45d3df62612aec42c17af5156c7f3034de448a`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks Lazarus's pinned profile, catalog and Warlord CP, Anti-Psyker 2+, The Spiritshield Helm, Intractable Will retention/removal, Deathwing context and public Inner Circle Companions attachment, plus attack, Titus, Asmodai, Inner Circle and Tigurius regressions. A separate `test_weapon_selection` run passed **3/3 processes** at `.tools/verification/20261028T100308716157Z/results.json` (SHA-256 `4ad6240b98299a0c853c210f30f7db5f44d1f6fa4a36456ea8c2924c44587213`; `legacy_starter_staged: true` because that suite explicitly exercises its historical selection path). Network validation and full army legality remain pending. See [the Lazarus audit](../marine-lazarus.md) and [machine-readable audit](../marine-lazarus-audit.json).

28 October 2026 Belial source-bounded local scope: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_belial --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T105835508974Z/results.json` (SHA-256 `2910072ab483505a489bf99495c4ccd7b3b0a604666d43900854a91263b6cc89`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks Belial's pinned profile, current-catalog admission and copy limit, all four source Leader relations with two blocked endpoints, Terminator Squad attachment, Warlord CP, ranged and melee CHARACTER modifiers, exact 2+ Fight-phase retention and removal timing. Capability and shared Leader-link checks passed **4/4 processes** at `.tools/verification/20261028T105501993243Z/results.json` (SHA-256 `39ea0d7b5fba60591219d94a6a7d1d3681e3e78e74b44eeae31e2460e2688c4f`). The Wahapedia source-row slicing improvement passed its focused regression (`python -m unittest discover -s tests -p test_wahapedia_slice.py -k direct_local_export_layout`). Network validation and full Dark Angels/army legality remain open. See [the Belial audit](../marine-belial.md) and [machine-readable audit](../marine-belial-audit.json).

### Chaplain Grimaldus source-bounded local scope — 28 October 2026

`python tools/verify.py --profile focused --only test_chaplain_grimaldus --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **3/3 processes** at `.tools/verification/20261028T174823201312Z/results.json` (SHA-256 `63CF74C6ED6A126FA39E6BBF42470415B12EF78A943CBB33343DA0F520AEFEDC`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the verified source data and hashes, current-catalog admission, mixed-model profile, all five Leader links, attachment with Cenobytes, unit abilities, relic choices and duration, zero transport capacity, actual damage-allocation death cascade with four casualties, and melee AttackPlan re-rolls.

The expanded regression batch `python tools/verify.py --profile focused --only test_chaplain_grimaldus --only test_space_marine_leader_links --only test_marine_transport_rules --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **5/5 processes** at `.tools/verification/20261028T174844999345Z/results.json` (SHA-256 `22461A04A142ED38FBBF12059A3A73BFDC646F3C2F06E77DB97F857A320A112E`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The result covers the local profile and regressions for the Leader/Support relation map and Marine transport rules. This closes only the named local scope; full roster legality, network validation and human playtesting remain open. See [the datasheet audit](../marine-chaplain-grimaldus.md) and [machine-readable audit](../marine-chaplain-grimaldus-audit.json).

### Death Company Dreadnought source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_dreadnought --only test_implemented_catalog --only test_capabilities --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T194021499437Z/results.json` (SHA-256 `3B263606A2821852AA4FE90C4C547996C7B563958A60C58BBD8C5A724A3A5A9A`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The focused scope checks the pinned local profile, source costs and copy cap, loadout replacements and conditional weapon traits, Black Rage AttackPlan/support/Fall Back/OC behavior, Driven by Fury eligibility and public resolved-shot Surge placement, phase-close blocking and attack continuation, the consolidated catalog and capability registry. The targeted verifier staged the ignored legacy starter fixture required by these suites; the run did not request network access. The shared Deadly Demise chain-resolution scope, full army legality and network validation remain open. See the [sheet audit](../marine-death-company-dreadnought.md) and [machine-readable audit](../marine-death-company-dreadnought-audit.json).

### Death Company Marines source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_marines --only test_implemented_catalog --only test_capabilities --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T195743838575Z/results.json` (SHA-256 `2679C2D11638DD385AB4C5F1B444FA0F1C345D378A11A96C470BF459DF9EABD9`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The shared suite checks both source-pinned profiles, points and copy limits, each per-model equipment limit, public Army Preparation choices, Black Rage support and movement restrictions, the foot squad's Sustained Hits strength bands, Jump Pack Deep Strike and Savage Fury, the selectable catalog and capability registry. This closes only the two declared local scopes. Full roster legality, network validation, human playtesting and the remaining Chapter datasheets stay open. See the [foot squad audit](../marine-death-company-marines.md), [Jump Pack audit](../marine-death-company-marines-with-jump-packs.md) and their [machine-readable records](../marine-death-company-marines-audit.json), [Jump Pack record](../marine-death-company-marines-with-jump-packs-audit.json).

### Commander Dante source-bounded local scope — 28 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_commander_dante --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --only test_combat_doctrines --timeout 300` passed **7/7 processes** at `.tools/verification/20261028T205826091643Z/results.json` (SHA-256 `FA3713E153EC7D1FC90814D71E78CEED7066850B94068977B299D5F7E13C0C61`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The checks cover source-pinned characteristics, keywords and both fixed weapons through Equipment/AttackPlan; current-catalog pricing and single-copy admission; all three Leader links; Warlord CP; Warden's attached-unit doctrine effects; Death Mask's exact 6-inch boundary, inclusion of non-Character units and -1 Battle-shock modifier; and save/restore of the Fight-phase decision. The declared local datasheet scope passes; full Chapter army legality, cross-sheet interactions, network validation and human playtesting remain open. See [Dante's sheet audit](../marine-commander-dante.md) and [machine-readable audit](../marine-commander-dante-audit.json).

### The Sanguinor source-bounded local scope — 28 October 2026

Focused offline verification passed **6/6 processes**: import, Python checks, The Sanguinor, Castellan reroll integration, current construction catalog and capability metadata. Command: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sanguinor --only test_castellan --only test_implemented_catalog --only test_capabilities --timeout 300. Report: .tools/verification/20261028T212105985788Z/results.json (SHA-256 7762A31B374D7399FC9FD9B69E64635D33BAC2E3B3D69D81F9CA593B443F7A47; network: false, legacy starter staged, no cleanup diagnostics). The reroll regression checks Aura of Fervour through the persisted Vehement Aggression keep-or-reroll choice. This closes only the declared source-bounded local datasheet scope; network validation, full army legality and human playtesting remain open. See [the sheet audit](../marine-the-sanguinor.md) and [machine audit](../marine-the-sanguinor-audit.json).


### Indomitor Kill Team source-bounded local scope - 28 October 2026

The focused command python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_indomitor_kill_team --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --only test_biologis --only test_space_marine_copy_cost_parity --only test_fortis_kill_team --only test_decimus_kill_team --timeout 300 passed **10/10 processes** (import, Python checks and eight targeted Godot suites) at .tools/verification/20261028T234416623535Z/results.json (SHA-256 9DC322EAA1081639415AF6205FB89F3040A9945FAAB56F8808A2B462EEFBE2A0; network: false, legacy_starter_staged: true, no cleanup diagnostics). The run checks the pinned source identity/hashes, fixed composition, weapon choices and limits, copy-price tiers, Captain in Gravis Armour / Apothecary Biologis links, Hunter-aware target selection for Indomitor Doctrines, the consolidated catalog and capability registry. Network validation, human playtesting, full army legality and complete-match certification remain open. See the sheet audit (../marine-indomitor-kill-team.md) and machine-readable audit (../marine-indomitor-kill-team-audit.json).
### Spectrus Kill Team source-bounded local scope — 29 October 2026

`python tools/verify.py --profile focused --only test_spectrus_kill_team --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **3/3 processes** at `.tools/verification/20261029T002556320011Z/results.json` (SHA-256 `c73f90bd8be5bdc40c29c5ae645afe54098c6fae38e23d9200fa41a7d4ca2dcf`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics).

The connected regression `python tools/verify.py --profile targeted --only test_spectrus_kill_team --only test_space_marine_leader_links --only test_infiltrator_squad --only test_fortis_kill_team --only test_indomitor_kill_team --only test_unit_reserves --only test_capabilities --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` passed **9/9 processes** at `.tools/verification/20261029T002716405961Z/results.json` (SHA-256 `bae33ae7070ddf73e30f5cacbc46d458792e816780bc4b6efd7999d4eea20cfe`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The run includes the updated locally validated status allowlist in capability metadata checks. Local source-bounded scope is recorded; network validation, full army legality and human playtesting remain open. See the [Spectrus sheet audit](../marine-spectrus-kill-team.md) and [machine-readable source/hash audit](../marine-spectrus-kill-team-audit.json).


### Watch Captain Artemis source-bounded local scope — 29 October 2026

`python tools/verify.py --profile focused --only test_watch_captain_artemis --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe` passed 3/3 processes at `.tools/verification/20261029T011058690940Z/results.json` (SHA-256 `a155e992d4ae7e8723742c47dad793e2c039fe30640c1246b826e66c5c6895fe`; `network: false`, no legacy starter staged, no headless cleanup diagnostics).

The connected regression `python tools/verify.py --profile targeted --only test_watch_captain_artemis --only test_deathwatch_veterans --only test_fortis_kill_team --only test_decimus_kill_team --only test_space_marine_leader_links --only test_combat_doctrines --only test_capabilities --only test_implemented_catalog --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300` passed 10/10 processes at `.tools/verification/20261029T011706897051Z/results.json` (SHA-256 `de3809fe4cbf7d6e3019042e0ecd87556912cd0d431c3e9540476455a0d3c6ac`; `network: false`, legacy starter staged, no headless cleanup diagnostics). The run checks the source-pinned Artemis profile and rules, all three Deathwatch Leader endpoints, shared Combat Doctrines, capability metadata and the 138-profile construction catalog. On-battlefield destruction paths are covered; off-board or transport destruction, network behavior, human playtesting and full army legality remain open. See the [sheet audit](../marine-watch-captain-artemis.md) and [machine-readable source/hash audit](../marine-watch-captain-artemis-audit.json).


### Thunderwolf Cavalry local scope — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_thunderwolf_cavalry --timeout 300` passed **3/3 processes** (import, Python checks and the focused Godot suite) at `.tools/verification/20261029T030029700768Z/results.json` (SHA-256 `8df5a19890dbb23b79db0a3a7795859246b5ed7a14ecd695b84b4002ec8fa7ba`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics).

The suite checks source identity, statistics, both formation sizes and copy-price fields, default and alternate weapon profiles, per-three Plasma Pistol replacements, priced Storm Shields and bearer-only 4+ invulnerable saves, reversible public preparation commands and Thunderous Charge's melee-only +1 Strength/+1 Damage after a Charge move. The scoped export slice has zero findings; its parent export retains 68 validation findings. Network validation, human playtesting and full Chapter/army legality remain open. See the [Thunderwolf Cavalry audit](../marine-thunderwolf-cavalry.md) and [machine-readable source/hash audit](../marine-thunderwolf-cavalry-audit.json).

### Space Wolves sheet batch: Fenrisian Wolves and Wolf Guard Terminators — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_wolf_guard_terminators --only test_fenrisian_wolves --only test_blood_claws --only test_grey_hunters --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --only test_deathwatch_terminator_squad --only test_roster_validation --only test_combat_doctrines --timeout 300` passed **12/12 processes** (import, Python checks and ten Godot suites) at `.tools/verification/20261029T024440783950Z/results.json` (SHA-256 `B302F9565738BA82CF5C926BB636A02C7E120E6FDD863FFE74AEDDF6DC0E3468`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics).

The run checks the two source-bounded profiles, Wolf Guard Terminator loadout roles and per-five-model cap, Storm Shield cost and bearer wound change, Rugged Resilience strength boundary, Fenrisian reaction timing and OC rule, the prior Space Wolves sheets, construction/capability publication, source-listed attachments, roster validation and shared Combat Doctrines. The export slice has zero subject errors; the parent export retains 68 unrelated findings. Network validation, human playtesting and full Chapter/army legality remain open. See the [Fenrisian Wolves audit](../marine-fenrisian-wolves.md) and [Wolf Guard Terminators audit](../marine-wolf-guard-terminators.md).

### Wulfen source-bounded local scope — 29 October 2026

Focused offline verification passed **3/3 processes** at `.tools/verification/20261029T031423847780Z/results.json` (SHA-256 `bc5c6ea36466cf39bafccf4cd1df4f83f572b8c81ec716d5b875956f7a24a61`; `network: false`, legacy starter staged, no cleanup diagnostics). The connected offline regression passed **13/13 processes** at `.tools/verification/20261029T031521462605Z/results.json` (SHA-256 `e686b080096aeeca55981dfd5b6ec2adb295a6104d59a8620275e35f87660bf93`; `network: false`, no cleanup diagnostics).

The focused suite checks Wulfen's source identity, model counts and both copy-price tiers, the per-model Stormfrag choice, Death Totem Hit rerolls, Savage Frenzy Fall Back restrictions and Hazard modifier, Curse of the Wulfen's Character/Wolf Priest range and Battle-shock conditions, and Bestial Forms transport capacity. The subject-scoped source slice has zero findings; the parent export retains 68 unrelated validation findings. Network validation, human playtesting and full Chapter/army legality remain open. See the [Wulfen sheet audit](../marine-wulfen.md) and [machine-readable source/hash audit](../marine-wulfen-audit.json).

### Wolf Scouts source-bounded local scope — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_wolf_scouts --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T035511571132Z/results.json` (SHA-256 `0ECA81594411F45A4B2D7DC6E27BBD5A4B74874CE1AF9D72D6282A8CA577936D`; `network: false`, no legacy starter staged, no cleanup diagnostics).

The connected offline regression `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_wolf_scouts --only test_implemented_catalog --only test_space_marine_leader_links --only test_capabilities --only test_incursor_squad --only test_ironstorm_stratagems --only test_fenrisian_wolves --only test_scout_squad --only test_roster_validation --timeout 300` passed **11/11 processes** at `.tools/verification/20261029T035536744980Z/results.json` (SHA-256 `091F32E4B73F259EB7D8A82089197965A801DF6E936F6AC7B22C2F0ECFA14415`; `network: false`, legacy starter staged for historical fixture dependencies, no cleanup diagnostics).

The focused suite covers source identity, model roles and both priced sizes, Scout weapon packages and per-unit caps, Phobos Leader links, Scouts 8, Infiltrators, Hunting Hounds, Deadly Stalkers, and Haywire Mine allocation. The connected run covers the consolidated catalog, Leader links, capabilities, Incursor/Haywire behavior, Fenrisian Wolves, Scout Squad and roster validation. The 60 x 35.5 mm Hunting Wolf base is represented by a 30 mm circular proxy; the positive Hunting Hounds Character case uses a synthetic test fixture because no Space Wolves Character profile is integrated yet. The subject slice has zero findings; the parent export retains 68 unrelated validation findings. Network/page validation, human playtesting and full Chapter/army legality remain open. See the [Wolf Scouts sheet audit](../marine-wolf-scouts.md) and [machine-readable source/hash audit](../marine-wolf-scouts-audit.json).


### Wulfen with Storm Shields source-bounded local scope — 29 October 2026

Focused offline verification passed **3/3 processes** at `.tools/verification/20261029T033331055146Z/results.json` (SHA-256 `F203254F1C6E0BA62D7489C8DA9A61A3170FDE78A18115C78B953A211BD4E124`; `network: false`, no legacy starter staged, no cleanup diagnostics). The connected current-catalog Space Wolves regression passed **11/11 processes** at `.tools/verification/20261029T033559838252Z/results.json` (SHA-256 `63916B3D07296BFAE5D0A6E617B4465D8F9D8E1ABC0B2F30BD4BE3CB916C6565`; `network: false`, no legacy starter staged, no cleanup diagnostics). A separate historical-data-dependent regression passed **7/7 processes** at `.tools/verification/20261029T033713524054Z/results.json` (SHA-256 `53C4B2A7F4425ED55EE18B3D17A6CB716165254DA8620753F382BADD85B378E8`; `network: false`, the legacy starter was staged for suites declaring that dependency, no cleanup diagnostics). The first two runs cover both Wulfen sheets, current catalog admission, the shared Space Wolves transport/Leader rules and the actual Hammer Blow AttackPlan modifier. The supplemental regression covers Tactical Brethren suppression, detachment stratagems, capability metadata, Combat Doctrines and roster validation. Network validation, page reconciliation, human playtesting and full Chapter/army legality remain open. See the [sheet audit](../marine-wulfen-with-storm-shields.md) and [machine-readable source/hash audit](../marine-wulfen-with-storm-shields-audit.json).
### Arjac Rockfist source-bounded local scope — 29 October 2026

The focused offline suite passed **3/3 processes** at `.tools/verification/20261029T040343855197Z/results.json` (SHA-256 `6DC425F0C50B7935FAB4CA040D5449D19152BB154641FD8B73DC1D202BB11234`; `network: false`). The connected offline regression passed **15/15 processes** at `.tools/verification/20261029T040913593435Z/results.json` (SHA-256 `E249F5A9B9F5AC18BC4087FE32283E48D3BE185A46FC23853772E8F53870D827`; `network: false`, legacy starter staged for historical fixture dependencies).

The focused suite checks Arjac's source identity, profile, fixed weapons, one-copy admission, capability records, all three source-listed Terminator Leader targets, CHARACTER-only Hit/Wound re-rolls for his model, no re-roll leakage to attached Wolf Guard Terminators, and Anvil of Endurance on failed/successful rolls, after the unit is selected, outside the Fight phase, at unit fight and phase end. The connected run covers current-catalog admission, Leader links, Wolf Guard/Terminator attachment, the shared retention paths for Lazarus, Belial and Captain Titus, all 13 Ancient Support targets, capabilities, roster validation and Combat Doctrines. The source slice has zero structural findings; the parent export retains 68 unrelated findings. Network/page validation, human playtesting, Chapter restrictions and full army legality remain open. See the [Arjac sheet audit](../marine-arjac-rockfist.md) and [machine-readable source/hash audit](../marine-arjac-rockfist-audit.json).

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_arjac_rockfist --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_arjac_rockfist --only test_implemented_catalog --only test_space_marine_leader_links --only test_capabilities --only test_wolf_guard_terminators --only test_terminator_squad_current --only test_terminator_assault_squad --only test_lazarus --only test_belial --only test_ancients --only test_captain_titus --only test_roster_validation --only test_combat_doctrines --timeout 300
```

### Crusader isolated-circle route bound — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_death_company_dreadnought --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T105514505486Z/results.json` (SHA-256 `C48B60AB3AF1F32B649887A32778797B8BCEB47C6DAA924A1B1EE723E891C507`; `network: false`, legacy starter staged, no cleanup diagnostics).

The isolated ground-level single-blocker regression bounds the route within 0.008 inches of its analytic tangent-and-arc distance. A board-edge fixture rejects the shorter arc when the mover's base would leave the battlefield, then confirms a bounded in-bounds detour. Shared route checks passed for Contact Reachability, Fist of the God-Emperor, Crusader Squad and Death Company Dreadnought. This leaves Crusader Squad partial: multi-blocker/terrain/elevated routing and coherent-placement search remain bounded; full Chapter legality, network validation and human playtesting remain open.

### Space Marine catalog price and relation audit — 29 October 2026

`python tools/validate_space_marine_roster_costs.py --snapshot .tools/wahapedia-e11-live-refresh-20261029T072022Z-final-integration --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --output .tools/current-space-marine-roster-cost-audit.json` was the pre-Headtakers-integration copy-cost checkpoint: it matched 576 rows against 160 profiles and their construction choices. The 29 October recheck below supersedes that profile count and also models the two known composition conflicts explicitly.

At this earlier roster-audit checkpoint, Wolf Guard Headtakers (`000004131`) was still the only source-only record; its six-model first/second and third-plus rows lacked a model-composition mapping, so no runtime cost was guessed. The later MFM mapping and partial mixed-profile integration are recorded above.

`& .\tools\validate_space_marine_chapter_links.ps1 -SnapshotPath .tools/wahapedia-e11-live-refresh-20261029T072022Z-final-integration` passed: **363/363** source Leader/Support relations across **161/161** identities, **14/14** static Support identities, and **22/22** manifest hashes. Its name comparison normalizes U+2018/U+2019 apostrophes by code point, covering source/runtime punctuation differences without weakening identity matching.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_marine_leader_links --only test_space_marine_copy_cost_parity --only test_roster_validation --only test_implemented_catalog --only test_capabilities --timeout 300` passed **7/7 processes** at `.tools/verification/20261029T110508804139Z/results.json` (SHA-256 `9D168E732F8EDA774B95BE52715FB62DA37BBEADCBF62632F39CF29B80740348`; `network: false`, legacy starter staged, no cleanup diagnostics). These audits verify source prices and relation maps, but do not exhaust every combined roster or establish full army legality; Crusader Squad remains partial, and final network validation and human playtesting remain open.

### Space Marine copy limits and Chapter roster combinations — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T111858888101Z/results.json` (SHA-256 `A3826068BB31BB82650090750E62203A2980DDE66B3FAF22C01EC5333A3AD68C`; `network: false`, legacy starter staged, no cleanup diagnostics).

At this earlier copy-limit checkpoint, the calculation checked both standard battle sizes against the exported keywords for all **160 runtime profiles** (85 shared-book and 75 Chapter-book profiles). Actual Incursion admission accepts four Blood Claws units, rejects a fifth, and rejects a mixed Black Templars/Space Wolves roster. This targeted coverage does not exercise every combination of Support assignments, Chapter restrictions, multiple configurations of one datasheet, or complete army legality; Crusader Squad remains partial; Headtakers has since gained an admitted partial profile with the MFM-mapped compatible mixed compositions.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_marine_leader_links --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T112107324578Z/results.json` (SHA-256 `0BF13C09845BE1C010EB57B74D75EEC15A330B1102FDDBCE296A08ED98AAB0CD`; `network: false`, no legacy starter staged, no cleanup diagnostics). In addition to all mapped Leader/Support relations, the suite now covers a forced matching reassignment, two Supports competing for one bodyguard, the Apothecary/Lieutenant sharing exception, rejection of a third Support on that bodyguard, a separate Support assigned to a second bodyguard, and Cato’s conditional Victrix assignment when Calgar is present. These helper-level roster combinations do not verify every full army or saved-match formation.

The copy-limit suite was expanded to verify the Chapter keyword count across all 160 current profiles and test actual same-Chapter and cross-Chapter roster admissions for every Chapter value represented by the catalog. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T112731235948Z/results.json` (SHA-256 `8D6BC5F59CB11420FAE2C9218A6FA348D7FCAC4B27A9565E34311C4BEDD8203B`; `network: false`, legacy starter staged, no cleanup diagnostics; the Godot test process took 3.63 seconds). This covers the Chapter gate at representative profile-pair boundaries; complete army legality remains unverified.

### Crusader two-blocker route phase check — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T113039637580Z/results.json` (SHA-256 `AED357C35C5E33DD1582C88AC340D955D44035B30751F3E2C9A67FAFED3B7BDF`; `network: false`, legacy starter staged, no cleanup diagnostics; the Fist process took 7.47 seconds).

The exact-clearance two-blocker detour was checked at four angular phases and stayed within 0.008 inches of its analytic path bound in each case. This does not establish arbitrary obstacle-field correctness; multi-blocker paths with terrain/elevation and whole-formation coherent placement remain bounded, so Crusader Squad remains partial.

### Crusader combined terrain and base route — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T114020217132Z/results.json` (SHA-256 `649D9369262CEBEF447CDB6178D9D5B3B9A64F386CB17FDBFB9D3033287E7B24`; `network: false`, legacy starter staged, no cleanup diagnostics; the Fist process took 6.84 seconds).

The new controlled fixture combines a terrain wall with two clearance-expanded enemy-base blockers touching its ends. The route graph found a detour longer than the direct path and within the movement allowance. This covers one mixed-obstacle arrangement; arbitrary terrain/elevation and full-formation coherent placement remain bounded, so Crusader Squad stays partial.

### Crusader two-blocker route phase expansion — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T123037828804Z/results.json` (SHA-256 `DBF99872D3B88B72218E36935F3A34882CF49B8C57A8FC6C942ADA6C138B352B`; `network: false`, legacy starter staged, no cleanup diagnostics).

The follow-up checks each integer angle from 1° through 14° in the 15° waypoint interval for the controlled two-blocker route; every result stayed within 0.008 inches of its analytic exact-clearance bound. This expands angular coverage for that fixture only. Arbitrary obstacle fields, terrain/elevation and whole-formation coherent placement remain bounded, so Crusader Squad remains partial.

### Crusader ground-level blocker visibility graph — 29 October 2026

Command: python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --timeout 300. It passed **5/5 processes** at .tools/verification/20261029T125334767841Z/results.json (SHA-256 7E070565CC77FEBF97F93AB4D8B6B0BA1AF3C7CC097D8AE378A2D1DFEDFCE3BE; network: false, no cleanup diagnostics; test processes 4.23, 6.44 and 3.52 seconds).

Ground-level routes now combine model-circle tangents/intersections and clear circular arcs with corners of clearance-expanded terrain rectangles. Straight edges are validated by movement geometry and circular arcs are rejected if they enter an expanded terrain blocker. The graph has a 256-node cap and falls back to the validated waypoint graph on overflow. Regressions cover 14 two-blocker angular orientations, a three-blocker route within 0.008 inches of its analytic bound and a terrain-wall route within 0.03 inches of its expanded-rectangle bound. Elevated routing and whole-formation coherent placement remain bounded.

### Terrain-corner tangents in the ground visibility graph — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T131851514801Z/results.json` (SHA-256 `40632F6C1B0105502263544ED6AC1A7E1CD94E262B8DB1CE83C65523148CCE76`; `network: false`, legacy starter staged, no cleanup diagnostics). The connected route command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --timeout 300` also passed **5/5 processes** at `.tools/verification/20261029T132120448551Z/results.json` (SHA-256 `16CDF878D2A9AF30BAA229D0EF89BB8FFB0DCB2056DC3D4151D39F20E8BD2ABF`; `network: false`, legacy starter staged, no cleanup diagnostics).

The mixed terrain-and-base fixture inspects the actual ground visibility graph and confirms it contains tangent nodes from clearance-expanded terrain corners to circular blockers. A mutation check removing those links made the Fist suite fail, confirming the regression exercises the new graph connection. It also checks a route through the mixed-obstacle geometry against a constructed tangent-path bound. Elevated routing and whole-formation coherent placement remain bounded, so Crusader Squad stays partial.

### All-profile Strike Force repeat-cap admission — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T113719634642Z/results.json` (SHA-256 `476179BA5FA8C61703A21064CDD880C85D42703C11BA79A4C01E3D7991EA8237`; `network: false`, legacy starter staged, no cleanup diagnostics).

For each of the **160 runtime profiles**, the test selects its lowest-cost valid model size and non-Epic composition where applicable, admits the profile at its Strike Force copy cap, and checks that one further copy is rejected by the source-standard repetition gate (or the Epic Hero gate). Incursion copy-limit calculations remain checked across all 160 profiles, with direct admission boundaries covered by representative cases. This does not establish complete multi-profile roster legality.

### Sixteen-slice Surge blocker lower bound — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T132856983539Z/results.json` (SHA-256 `BA6796F1786B42A1BDCD1D74211914600C43BD0CB4714822CED435B0FFB7CBE0`; `network: false`, legacy starter staged, no cleanup diagnostics). The connected contact/Fist/Crusader command passed **5/5 processes** at `.tools/verification/20261029T133001702446Z/results.json` (SHA-256 `451171979F70972233481DD5EE75E0FCC6CEEEC2E1698DDD7FC0A0F174A6F5E0`; `network: false`, legacy starter staged, no cleanup diagnostics).

Each fixed same-height Surge blocker now contributes 16 stacked rectangles wholly inside its true blocked circle. The fixture compares the resulting relaxed route bound against the previous 8-slice version and the exact analytic circle route: the new bound is strictly stronger than the 8-slice bound and remains lower than the exact route, preserving certificate safety. This improves the bound used to prune impossible placements; the 1,024-box default, elevated-route relaxation and coherent-placement search limits remain. The focused process took 5.13 seconds in the isolated run; this single measurement is not evidence of a general runtime speed-up. Crusader Squad remains partial.

### Same-surface elevated contact routes — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T134337222770Z/results.json` (SHA-256 `31C19BF75F291ED7D8B4447FBC0CFC598D52224FC80C780CD7D0213C054F3CC9`; `network: false`, legacy starter staged, no cleanup diagnostics).

The current [Wahapedia 11e Core Rules, §§03 and 13.06](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) permit movement as successive straight segments and require vertical movement to stay within 1/2 inch of its terrain feature. The multi-obstacle visibility graph now routes same-height movement on one supported upper surface; every arc must keep the entire base inside that surface's fit rectangle, and graph nodes must stay on the mover's source surface. The regression accepts a mixed wall/base detour on an elevated floor within the configured 7-inch movement allowance and rejects a route to a disconnected same-height floor or through a too-narrow floor with no listed vertical access. This covers those fixtures only. The 256-node limit and waypoint fallback remain; a single transition to a selected destination surface is supported, while multiple intermediate surface transitions and whole-formation coherent placement remain bounded, so Crusader Squad remains partial.

### Exact rounded-rectangle coherency lower bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T135208491974Z/results.json` (SHA-256 `D0CEE2EB971CA555EFC9CF594C2873E63D43727C5C8445F4DED5D4BD15A4E64B`; `network: false`, legacy starter staged, no cleanup diagnostics).

The coherency certificate now measures disk-to-rounded-rectangle and rounded-rectangle-to-rounded-rectangle distances directly for objective goal constraints. This replaces the previous single circumscribing-circle envelope and remains a lower bound because each modeled constraint is the actual relaxed goal/domain set. The regression compares the old 1.53-inch bound with the exact 3.6-inch bound and checks symmetry plus fail-closed handling of malformed geometry. The connected Fist/Crusader objective-placement regressions still pass. This tightens one pairwise pruning bound; it does not prove exhaustive placement. The general certificate still caps at 1,024 boxes, the objective-specific override at 16,384, and unresolved proofs retain the required rule.

### Per-target coherency bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T135835656997Z/results.json` (SHA-256 `CA0C66F5C44A3099F9A31698AB71422F01604FBFC3109F0F8E0C6A93779F930C`; `network: false`, legacy starter staged, no cleanup diagnostics).

When a target has multiple candidate models, each root search box now carries pairwise coherency lower bounds for its own goal region. Previously those static bounds used the full goal set and therefore inherited the nearest alternative target's weaker distance, even though the roots were already separate. A regression checks that an overlapping alternative weakens the combined set to zero while the individual rounded-rectangle goal retains its exact 3.6-inch separation. This strengthens pruning for each root without merging candidates or changing the rule that search limits and unresolved boundaries cannot prove impossibility. Full coherent-placement search remains bounded; Crusader Squad remains partial.

### Route-ellipse blocker pruning — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T141935210020Z/results.json` (SHA-256 `BF0A96AA7BE50919DD67EF09FD26468DE3CAFF91C3F38CE934FDD06E58396CDD`; `network: false`, legacy starter staged, no cleanup diagnostics).

Before generating tangent nodes, the same-surface route graph now omits expanded circles or terrain rectangles whose route lower bound from origin through the obstacle to destination exceeds the full movement allowance. The regression has 12 blocker circles and 11 remote terrain rectangles: only the central circle can affect a 12-inch route, so circle-pair tangent checks fall from 66 to 0 and all 44 remote terrain-corner nodes are omitted. The retained path stays within 0.15 inches of the analytic central-circle detour and does not overflow the visibility graph. Malformed circle or rectangle geometry is retained. These deterministic operation counts are not a measured general runtime improvement. Existing connected route, Surge and Crusader checks pass; elevated cross-surface movement and whole-formation placement remain bounded.

### Black Templars mixed-cap roster admission — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T142541568844Z/results.json` (SHA-256 `049CCE645596850C20C06D067575CEA5296D716D6C1D8EC7F448EA825A4850EE`; `network: false`, legacy starter staged, no cleanup diagnostics; the Godot test process took 25.34 seconds).

The combined Strike Force fixture admits six Black Templars Impulsors, three Lieutenants, one Emperor's Champion and six Crusader Squads together, each at its datasheet copy limit and within the 2,000-point cap. It then adds one copy to each datasheet in turn and confirms the repeat gate rejects the roster. This exercises Battleline, Dedicated Transport, non-Battleline, EPIC HERO, Chapter-tagged and shared-book profiles in one selected combination; it does not establish full army legality.

### Crusader movement-ellipse candidate pruning — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T143324591170Z/results.json` (SHA-256 `12F13FB74741378BC583DAF1A120F3007824EE609842137D9E2952F4B4AF442F`; `network: false`, legacy starter staged, no cleanup diagnostics).

The same-surface visibility graph now skips tangent, terrain-corner and circle-intersection candidates when the straight-line lower bound through that point exceeds the movement allowance. The regression used two relevant blocker circles and remote terrain clutter: four over-budget nodes plus 30 straight edges and one circular arc were pruned before geometry validation, 14 graph nodes remained, and the validated 10.2083-inch route stayed within 0.15 inches of the analytic single-circle bound. This is a deterministic operation count for that fixture, not a measured general runtime improvement. Elevated cross-surface routes, graph overflow and whole-formation coherent placement remain bounded.

### Crusader route edge pruning — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T143756791700Z/results.json` (SHA-256 `D7BC4BFAE3CC8118FB8DDAB7D38EAC02D9B64CA54AB0D52A881D9D5A898E1DFC`; `network: false`, legacy starter staged, no cleanup diagnostics).

With two relevant blocker circles and remote terrain clutter, the visibility graph prunes four over-budget nodes, 30 straight-edge candidates and one circular-arc candidate before the corresponding geometry validations. Fourteen graph nodes remain, and the validated route is 10.2083 inches, within 0.15 inches of the analytic single-circle bound. These are deterministic operation counts for this fixture, not a general wall-clock measurement. Cross-surface routing, graph overflow and whole-formation coherent placement remain bounded.

### Coherency route-budget cutoff — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T144915861536Z/results.json` (SHA-256 `1E3C64C3823B9BED0C1FCA9E7EC4F6FFB4B4B09BB35BB72D2D399BF2F0FDCF6A`; `network: false`, legacy starter staged, no cleanup diagnostics).

The terrain-route lower-bound helper returns the direct Euclidean bound before graph construction when it already exceeds the movement budget. For detours, it filters rectangles that cannot be touched within the budget, rebuilds vertices from the retained obstacle union, and stops A* when its smallest open estimate exceeds the certificate cutoff. The direct wall fixture returned 5 inches for a 4-inch allowance instead of the 6.53-inch route. The detour fixture filtered eleven remote rectangles and 44 vertices, returning 10.5146 inches above the 10.02-inch certificate threshold; the complete relaxed route bound was 10.5342 inches for a 10-inch allowance. The contact log reports zero certificate failures. These operation counts apply to controlled fixtures, not general runtime performance; route coverage and coherent-placement search remain bounded.

### Target-directed A* on waypoint overflow — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T150507264169Z/results.json` (SHA-256 `C023B9F8860E2543A3EBE59A64BD80157E00CA20C9AAD071F0C46F7A5E685BC1`; `network: false`, legacy starter staged, no cleanup diagnostics). The contact-reachability process took 19.94 seconds and reported zero certificate failures.

When the exact same-surface graph exceeds its 256-node cap, endpoint and closest-region queries now use target-directed A* over the validated waypoint candidates, checking straight edges on demand. The 15-blocker fixture overflowed to 423 fallback nodes. Endpoint routing expanded 157 nodes, validated 26,416 edges and retained the 23.8052-inch route within a 24-inch allowance. Closest-region search reached zero gap in 21.8052 inches, expanded 220 nodes and validated 23,044 new edges; a second target query found zero gap in 21.2326 inches and required only 193 new geometry validations because the pathfinder reused cached edge results. These counts apply to one fixture, not a general performance or route-completeness claim; arbitrary waypoint coverage, multiple intermediate surface transitions and whole-formation coherency remain open.

### Surge endpoint on an eligible upper surface — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 90` passed **3/3 processes** at `.tools/verification/20261029T153523078275Z/results.json` (SHA-256 `2621A9C6DC0115971B5D82EE4EC5107E44118E7E70B689C24F9F4A488676543B`; `network: false`, legacy starter staged, no cleanup diagnostics).

The focused public-command regression previews a Righteous Zeal model on an eligible upper floor through one listed ruin access feature, confirms the model's live elevation remains unchanged during preview, and then verifies the confirmed position/elevation commit. It rejects a 6-inch movement budget for a 6.8-inch route (3.8 inches horizontal plus 3 inches vertical), accepts that route with a 7-inch roll, and retains the existing no-access/disconnected-surface blockers. This establishes the tested single-transition endpoint behavior; it does not cover multiple intermediate floors, arbitrary waypoint completeness or all coherency outcomes.

### Adaptive cross-surface access-zone refinement — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 90` passed **3/3 processes** at `.tools/verification/20261029T155302702260Z/results.json` (SHA-256 `7BB1745462175C028FD8EBD8452F5C8A5107C66A851E85A57307A3FBE4404547`; `network: false`, legacy starter staged, no cleanup diagnostics).

The new three-blocker regression returned no route before the change, although a valid path existed through a narrow cross-surface access gap. When the original center/corner/midpoint endpoints find no route, the fallback now adds 32 subdivisions along each access-zone edge and retries. Both direct distance and closest-reachable-endpoint search recover the gap; the validated direct path falls between 10 and 12 inches for the 12-inch fixture allowance. This is a bounded recovery for that fixture; it does not establish exhaustive access endpoints, arbitrary multilevel routing, or whole-formation coherency.

### Closest cross-surface endpoint refinement — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 120` passed **3/3 processes** at `.tools/verification/20261029T155818635362Z/results.json` (SHA-256 `ECB0661663029DF233E01E9A828F7CCB4C20374EAADD66E6BB52D7FEB3252612`; `network: false`, legacy starter staged, no cleanup diagnostics).

The cross-surface closest-endpoint query previously skipped edge refinement when its initial finite result did not reach the goal region. It now subdivides access-zone edges when that gap is positive and keeps the better of the initial and refined results. In the controlled three-blocker fixture, the best point improves from 5.244 inches to 1.686 inches from the target within a 12-inch movement allowance. This improves a tested single-transition case; the finite access samples, arbitrary multilevel routes and whole-formation coherency remain bounded.

### Destination-surface route candidate filter — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 120` passed **3/3 processes** at `.tools/verification/20261029T160441745100Z/results.json` (SHA-256 `EBE09A5838BA11012BF411108229F3131232FCB93491D748D2EFF75A44B39A9B`; `network: false`, legacy starter staged, no cleanup diagnostics).

Cross-surface route and closest-endpoint queries now add waypoints only for access surfaces at the requested destination elevation whose base-fit bounds overlap the target point or goal region. A regression with disconnected floors at the same height confirms the unrelated surface contributes no access candidates while the selected-floor narrow route, direct movement query and closest-endpoint refinement still pass. This prunes unrelated access points from the route graph; it does not cover transitions through multiple intermediate surfaces.

### Two consecutive vertical movement transitions — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 120` passed **3/3 processes** at `.tools/verification/20261029T163322053721Z/results.json` (SHA-256 `D3885EF9CBA2A1C6B20F729062175B53467B4224803EA294A5145768B6434747`; `network: false`, legacy starter staged, no cleanup diagnostics).

The individual-model route and closest-region queries compose successive legal movement segments through intermediate supported floors. The public Purge and Sanctify regression moves two Crusaders to an upper-floor objective through two transitions each, confirms their direct ground-to-second-floor paths are blocked, leaves both live models unchanged during preview, then commits their coherent destinations within objective range. A solo-survivor case validates the closest partial endpoint when the objective is out of reach; separate cases verify three transitions and a ground-level intermediate for exact and closest-region queries. The known two-transition route costs 5.924 inches within a 6-inch allowance. These are bounded fixtures; arbitrary multilevel routes and whole-formation completeness remain open.

### Ground as an intermediate movement surface — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 180` passed **3/3 processes** at `.tools/verification/20261029T164039752368Z/results.json` (SHA-256 `6AB365A7654D61D1B31C590B854EDD400B928C4B934FFE0D92FD76EA8FDAB4AC`; `network: false`, legacy starter staged, no cleanup diagnostics).

The individual-model pathfinder can now route from an upper floor down to ground, traverse the ground, then ascend through a different listed access feature to the destination floor. In the fixture, the direct upper-to-upper segment is blocked, both movement segments pass shared geometry, and the 6.700-inch composed route fits a 7-inch budget. Both exact-destination and closest-region queries find the route and end on the requested floor. This is one bounded fixture; arbitrary terrain networks and whole-formation placement remain open.

### Same-height platform transition through ground — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 180` passed **3/3 processes** at `.tools/verification/20261029T164647787068Z/results.json` (SHA-256 `9A050582C3555BC09BBB2D0E7C00CDE06CE51A49511F9EE4FC986A6A9AD1150A`; `network: false`, legacy starter staged, no cleanup diagnostics).

The pathfinder now detects when a same-height destination lies on a different supported surface. A controlled fixture blocks the direct segment, then validates exact-destination and closest-region routes that descend to ground and ascend through the destination floor's separate listed access feature within 7 inches. This is pathfinder evidence for one terrain layout; public-command completion for this layout, arbitrary terrain networks and whole-formation placement remain open.

### Public Surge on same-height separated platforms — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 180` passed **3/3 processes** at `.tools/verification/20261029T165808037478Z/results.json` (SHA-256 `90D67671AB8B1EC40ACFF91150825189153B6BE6FED17367F10E66EBE5687468`; `network: false`, legacy starter staged, no cleanup diagnostics).

The test drives Purge and Sanctify through the public command on the separated same-height floor fixture. The direct route remains blocked; exact-destination, point-target and finite objective-region queries descend to ground and ascend through the other floor's listed access. The region query finds a zero-gap endpoint on the destination surface. Preview preserves both live positions, and confirmation commits both positions and elevations on that surface while verifying coherency. This two-model fixture does not establish arbitrary terrain-network or whole-formation placement completeness.

### Exact projected vertical-access candidates — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 180` passed **3/3 processes** at `.tools/verification/20261029T170454005349Z/results.json` (SHA-256 `A2E39154B9276C97CCC51F92D5E4A3B8A57CA8B0D65438718448803731CE65A2`; `network: false`, legacy starter staged, no cleanup diagnostics).

Vertical-access candidate generation now adds the access point obtained by projecting the mover and requested endpoint onto each access zone. Finite goal-region queries also project the nearest point on the goal region back onto the zone. Regressions check the exact mover and finite-objective projections; all movement segments still use shared geometry validation. These candidates supplement finite edge samples and do not establish arbitrary surface-route or whole-formation placement completeness.

### Reused terrain surface ids remain distinct — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 180` passed **3/3 processes** at `.tools/verification/20261029T171128176738Z/results.json` (SHA-256 `34B1BCB3C02FE716607A91F53F72094646FAA19F829C216F4F3727BD8BA2285A`; `network: false`, legacy starter staged, no cleanup diagnostics).

Terrain surface enumeration now records each platform's index within its area. Same-elevation path validation, direct-route classification and elevated route-node membership compare the declared id, area index and surface index. The regression assigns the same id to three disconnected platforms, including two in one area and one in another, and confirms direct routes are rejected, both goals are classified as surface transitions, and no route is invented when the platforms have no listed access features. This prevents identity collisions; bounded route search and whole-formation placement remain open.

The connected `test_contact_reachability`, `test_fist_god_emperor`, `test_crusader_squad` and `test_capabilities` run passed **6/6 processes** at `.tools/verification/20261029T171238786822Z/results.json` (SHA-256 `46812E8447A7C0904D6326CF909BFAA924E01B2B8CF1D7E8893C69A499B4260C`; `network: false`, legacy starter staged, no cleanup diagnostics).

### Same-class datasheet caps in mixed Strike Force rosters — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_category_copy_limits --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T171550127223Z/results.json` (SHA-256 `F2ED0DCCE04187C4A41EE64E59B83EEB2B3F6D2BC7F35A0F086AB9C7A19800C3`; `network: false`, legacy starter staged, no cleanup diagnostics).

Two distinct Battleline datasheets now sit at their six-copy Strike Force caps in one roster, and two distinct Dedicated Transport sheets do the same in another. Raising each identity to seven is rejected by that datasheet's own repeat gate. This catches accidental global caps across sheets sharing a keyword class; it complements the existing all-profile single-sheet limits and mixed-category cap roster. It does not prove every multi-unit combination or full army legality.

### Vertical movement lower bound for enemy approach — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T172553100410Z/results.json` (SHA-256 `5089D765337C9B75BD881CE117E82E6B2665D3870E90C606331110F89AEFA431`; `network: false`, legacy starter staged, no cleanup diagnostics).

Enemy-target certificates now add the minimum vertical movement required to enter the five-inch engagement-height band to the relaxed horizontal route lower bound. A target eight inches above the origin requires at least a three-inch climb: a 2.9-inch move is certified impossible, while 3 inches remains unresolved within the numerical margin. FLY using Take to the Skies ignores the vertical term. This proves a narrow height-cost bound only; it does not certify an elevated route or close Crusader Squad's bounded whole-formation search.

### Whole-formation vertical coherency bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T173431696686Z/results.json` (SHA-256 `FF1279E56CD8E8C5F55856B3828D7F7FBBD929480E5F728980DCE4204187AE3F`; `network: false`, legacy starter staged, no cleanup diagnostics).

Coherency impossibility search now tracks a conservative reachable-height interval for each model. It restricts each enemy-target root to the focused model's 5-inch engagement-height band and rejects a pair only when no heights within both movement domains could satisfy the 5-inch vertical coherency limit. The regression begins with two models coherent at exactly 5 inches of vertical separation; a target requiring the focus to rise above a locked ground anchor is proved impossible as a coherent formation. A target on the legal boundary remains unresolved, and the proof still makes no claim that a matching surface or access route exists.

### Retained-engagement height bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T173956466496Z/results.json` (SHA-256 `3FFAC60CD038C547BA3F9BD39B60B2F400962CD486F61A46E7ADD7EFF05649F2`; `network: false`, legacy starter staged, no cleanup diagnostics).

The formation-height certificate now intersects each movable supporting model's reachable elevation with a conservative envelope of the retained enemies' 5-inch engagement-height bands. A two-model regression starts coherent; the focus can approach a target at elevation 20, while the supporting model must retain engagement with a ground-level enemy. No height pair can preserve both engagements and 5-inch coherency, so the check proves `coherent_placement`. The envelope can contain unreachable intermediate heights and does not claim a valid surface, route or complete formation search.

### Supported endpoint-height domains in contact certificates — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T181008235662Z/results.json` (SHA-256 `34890CFAC841614D52F66F5B9A5CCAA94E0F4EDD89562DC2F14A3991E3D83FA3`; `network: false`, legacy starter staged, no cleanup diagnostics).

The formation certificate now uses per-model vertical interval unions. It includes ground and eligible upper surfaces whose base-fit bounds intersect the model's relaxed XY box and whose height fits its movement allowance, then applies target, retained-engagement and coherency constraints. Walls and access routes remain ignored, preserving a conservative impossibility proof. If source terrain or the starting position is malformed, the previous continuous interval remains as a fail-open fallback. A regression confirms that a reachable vertical movement band alone cannot imply an endpoint when no legal floor of that height overlaps the goal domain. Eligible surface descriptors are prepared once per certificate instead of being reconstructed for every search box; no general runtime speedup is claimed. This does not close arbitrary surface routing or whole-formation placement.

### Marker-objective height bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T174454213337Z/results.json` (SHA-256 `572D9984397604F1366BD45055F67E04D8C56281F8233AD1DA391F373A90AB27`; `network: false`, legacy starter staged, no cleanup diagnostics).

Purge and Sanctify's formation proof now carries a marker's elevation only into the goal for reaching objective range. A regression proves that a 10-inch Surge cannot place a model within range of a marker 20 inches above its starting elevation. The separate closest-distance goal omits the height constraint because that comparison is horizontal. Terrain-objective regions also remain height-independent here. This strengthens an impossibility proof; it does not certify a supported route or a full formation arrangement.

### Combined Chapter, Support and tiered-price admission — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_roster_validation --only test_marine_category_copy_limits --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T174853619117Z/results.json` (SHA-256 `58A291BDD135D11B185D4EAC3393579B84C43935364D4954C1513ADDDEB87D4C`; `network: false`, legacy starter staged, no cleanup diagnostics).

The combined fixed-price Incursion uses a Black Templars Crusader Squad, shared-book units, an Apothecary/Lieutenant pair sharing one eligible bodyguard and two Land Raiders. Admission applies the per-datasheet Incursion cap and the Land Raider's second-plus cost while keeping the list within 1,000 points. This joins several existing gates in one roster; Warlord/Support sealing and full army legality remain separate checks.

### Combined roster through public setup sealing — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_roster_validation --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T175233824289Z/results.json` (SHA-256 `B1AFBF95090B1CAB6B1474332611601FBBCED198DEE283E7CAC188C14A82997B`; `network: false`, legacy starter staged, no cleanup diagnostics).

The checked Incursion now continues through the public preparation path: it materializes the Chapter/shared roster, declares its Captain Warlord, attaches the Apothecary and Lieutenant as shared Supports on the Crusader Squad bodyguard, and seals both players' formations. This validates one setup combination; it does not certify complete army legality, the match, or network play.

### Exact projections in the direct cross-surface route graph — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T181432224545Z/results.json` (SHA-256 `596FC8ABAE0BEE2B6C99D1DD7B029CECDD52124CFAE16EF99BBD3D52455E52A5`; `network: false`, legacy starter staged, no cleanup diagnostics).

Direct cross-surface route graphs now add the exact mover projection onto each eligible access zone and the access point nearest the exact destination or finite goal. The regression confirms that the mover projection appears in the direct graph for a narrow access zone. Existing geometry checks still validate route segments; this does not establish complete access search or whole-formation placement. Crusader Squad remains partial.

The expanded regression also checks the exact requested-destination projection and the closest access point for a finite goal region in the direct graph. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T182036241561Z/results.json` (SHA-256 `A6FB191D6AA5E12E03D45117918908A26B834403B248B32F4E6328C2BF01D6F9`; `network: false`, legacy starter staged, no cleanup diagnostics).

### Copy-on-write intermediate route states — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --only test_crusader_squad --only test_capabilities --timeout 300` passed **6/6 processes** at `.tools/verification/20261029T182320403947Z/results.json` (SHA-256 `6F72D151197103BBFFEF1AD64E4AED81281A9100339B7BE11CA806AE826172AD`; `network: false`, legacy starter staged, no cleanup diagnostics).

Recursive intermediate-surface queries now shallow-copy the outer battle state and unit map, then clone only the moving model record before changing position and elevation. This removes deep copies of unrelated battle data for each candidate while leaving the parent state and its movement scratch state isolated. The run covered reachability certificates, Surge routing, Crusader movement and the capability registry. It does not claim a measured frame-time improvement or broader route completeness.

### Reusing ordered terrain descriptors during access checks — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T182628541103Z/results.json` (SHA-256 `19E0B102A557C7EFDAE1BED5F352058FA23998E75A0ECE2DB417800AD74D15CB`; `network: false`, legacy starter staged, no cleanup diagnostics).

Access candidate validation now reuses one ordered surface list per query instead of calling `Terrain.surface_at` and rebuilding that list for every candidate. The helper preserves the same elevation tolerance, model keyword eligibility, base-fit containment and first matching surface identity. These focused suites cover narrow access gaps, finite and exact goals, duplicate surface IDs, intermediate floors and Crusader movement. This does not claim a measured wall-clock improvement or broader route completeness.

### Exact tangents from vertical-access projections — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T183016122373Z/results.json` (SHA-256 `BAEB69B82D6CFC4600DF224A382725403CDA78BCBC905BCBF71BD1624D317A23`; `network: false`, legacy starter staged, no cleanup diagnostics).

When a cross-surface query adds exact mover or goal projections to an access zone, it now also inserts validated circle tangents from those projection anchors to the current-elevation blocker circles. The regression verifies the finite-goal anchor's exact tangent appears in the route graph. Tangents are not generated from every subdivided edge point; broader terrain routing and whole-formation placement remain partial.

The follow-up regression also verifies tangents from the mover projection; `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T183133269838Z/results.json` (SHA-256 `88B1E07E1CB83CE34DCDA25E5B98989EFB11478BCA4D29DDB14617B9553670DD`; `network: false`, legacy starter staged, no cleanup diagnostics).

### Access-aware formation-height bounds — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_contact_reachability --only test_fist_god_emperor --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T185905120494Z/results.json` (SHA-256 `A228E8DB2C976D095680F22BD9D781464D1B3A974ECC8F58A0575D8BE091639F`; `network: false`, legacy starter staged, no cleanup diagnostics).

The height certificate now bounds travel from the origin through the destination floor's access zone and onward to the relaxed endpoint box, then adds unavoidable vertical travel. For ground endpoints from an elevated start, it considers access zones on all eligible elevated floors, keeping legal routes that descend through a lower intermediate floor even if the starting floor's access is too far away. It pre-collects that zone union once per model and stops at the first sufficient zone; no general timing improvement is claimed. The regressions reject out-of-budget and off-route access, retain a reachable lower-floor endpoint at 2.5 inches, preserve a ground route through the lower floor at 5.5 inches, and keep the continuous fallback when access data is malformed. These are access and height lower-bound cases; general route completeness and whole-formation search remain bounded.

### Corner tangents in direct cross-surface graphs — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T190459575166Z/results.json` (SHA-256 `2123CC030D6D3F791F8485F75EC05435CAE790F060B21956A7F5B151A913391F`; `network: false`, legacy starter staged, no cleanup diagnostics).

Direct cross-surface route graphs now add analytic blocker-circle tangents from each access-zone corner in addition to the mover and goal projections. The regression confirms a corner tangent is admitted to the graph. This expands the finite candidate set for tested narrow access zones; it does not establish arbitrary route completeness or whole-formation placement, and Crusader Squad remains partial.

### Safe access-node pruning for exact cross-surface routes — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T191057173085Z/results.json` (SHA-256 `903051A5CFE75EA15710D0FC32C80A0DA4BE0289F6FCAA8C8070A6F0F7BB5D3E`; `network: false`, legacy starter staged, no cleanup diagnostics).

Exact-destination cross-surface graph construction now skips an access node when origin-to-node movement, the relaxed node-to-goal distance and unavoidable vertical cost already exceed the allowance. The same prune is disabled for closest-region searches: even when the requested region is out of reach, an access candidate may still produce the closest valid partial endpoint. Regressions check both over-budget exact-route pruning and retention of the existing improved partial endpoint. This is a necessary lower bound, not exhaustive route or formation search; Crusader Squad remains partial.


### Crusader Squad route-waypoint projections into access zones — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T193908386704Z/results.json` (SHA-256 `dd7783a8e82c1e3f58ec9007595fda7dbfc6084154668c5a0cec029dcba0eb40`; `network: false`, legacy starter staged, no cleanup diagnostics).

Direct and intermediate cross-surface access candidate generation projects current source-surface waypoints onto eligible access zones. The focused fixture routes through a three-blocker narrow gap without edge subdivisions, and the integrated Surge and Crusader checks pass. This demonstrates the bounded fixture no longer depends on the 32 edge samples; it does not establish arbitrary access-route or whole-formation completeness.


### Decimus preparation gate for the blocked size — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --only test_implemented_catalog --only test_capabilities --timeout 300` passed **5/5 processes** at `.tools/verification/20261029T194643249902Z/results.json` (SHA-256 `000E989B5C1CB9C233B2E34BD36B15913A4B7EE7BBE19A5B24B4057A229698D2`; `network: false`, legacy starter staged, no cleanup diagnostics). The Decimus regression confirms that a five-model legacy state receives no preparation loadout choices and that a forged public command is rejected without mutation. The 10-model/210-point construction remains the only admitted size; this does not resolve the source's five-model composition conflict or certify full army legality.

### Crusader projected-waypoint blocker tangents — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T195431625189Z/results.json` (SHA-256 `10EAE03F02015A05D04A9ACDB4DCB4EB30DF91981AAFA09C4DBE54B387FD2322`; `network: false`, legacy starter staged, no cleanup diagnostics). Direct and recursively composed access-zone candidate generation adds blocker tangents from source-route waypoint projections. The regression checks both query paths, retains the three-blocker narrow route with edge subdivision disabled, and verifies that target-scoped access omits a disconnected floor outside the goal region. Geometry validation remains active; general multilevel route and whole-formation coherency completeness remain open.

### Exact direct source-segment contacts on access zones — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --only test_crusader_squad --timeout 300` passed **4/4 processes** at `.tools/verification/20261029T201720787063Z/results.json` (SHA-256 `4F4924E93ABDFD9DBB8BD0C8A2ACC1370A9D2F32984F6C131158BB632551DCF9`; `network: false`, legacy starter staged, no cleanup diagnostics). Cross-surface access queries now add exact entry and exit points from origin-to-baseline-waypoint segments where they intersect an access zone. The candidate set remains incomplete for multi-segment transitions and whole-formation coherency; Crusader Squad remains partial.

### Crusader Squad focused local recheck — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_crusader_squad --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T203408337767Z/results.json` (SHA-256 `FFD6F90218317B611315E585B1D0B6311939E078CFD8A19D4B7BDA02F5773DA6`; `network: false`, no legacy starter staged, no cleanup diagnostics). This rechecks the local Crusader Squad scope only; it does not close the bounded movement/formation boundary or validate the separate Headtakers source audit.

### Space Marine identity and roster-cost recheck — 29 October 2026

The local `audit_space_marine_chapters.ps1` audit against `.tools/wahapedia-e11-live-refresh-20261029T072022Z-final-integration` verified all 22 manifest file hashes and found **76/76 Chapter-book sheets represented by runtime profiles**, with zero missing profiles. The ignored report is `.tools/space-marine-chapter-gap-audit-20261029-recheck.md` (SHA-256 `B9A371BDD1BC5AABFEFB72014EA86A4B4D28826105C37A945B2B308BC6700360`). The parent export still records 68 structural findings, so this identity count is not individual datasheet certification.

`python tools/validate_space_marine_roster_costs.py --snapshot .tools/wahapedia-e11-live-refresh-20261029T072022Z-final-integration --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --output .tools/space-marine-roster-cost-audit-20261029-recheck.json` matched **576 source-priced size/tier rows against all 161 runtime profiles** and verified construction costs for **161/161 catalog choices**, with zero mismatches and all 22/22 export hashes verified. It also parsed the two known source compositions and confirmed each minimum is six models. The ignored result is `.tools/space-marine-roster-cost-audit-20261029-recheck.json` (SHA-256 `A12345D38A4DA9E95409ADD9AAB8B688247247C5769F24CEB6F94DAEB0AFEBBE`). The audit explicitly withholds Decimus's five-model/110-point row and Wolf Guard Headtakers' three-model/85- or 95-point rows; for the ambiguous six-model Headtakers cost it admits only the composition-compatible 3+3 schedule (115/125), while the six-Headtaker-only row (170/180) remains blocked. The 6+6 schedule remains 230/240. It is an offline identity and points-parity check (`network: false`), not source-page validation, ability certification, or full army legality.
### Crusader access-zone circle intersections — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T212347755944Z/results.json` (SHA-256 `2396A20621F7249ACA66A1F9E6566F35920405118343185A84430CB0E003FB06`; `network: false`, legacy starter staged, no cleanup diagnostics). The regression covers exact circle/portal intersections in the helper and their presence in direct and recursively composed access queries. This remains a finite route candidate improvement; Crusader Squad is still partial.


29 October remote route-end portal contacts: exact contact generation now allows the far endpoint of a route-waypoint segment to be outside the movement allowance, provided a reachable anchor can reach a portal contact within budget. A regression keeps the 5-inch entry and drops the 7-inch exit under a 6-inch allowance. Fist/Surge verification passed 3/3 at `.tools/verification/20261029T214610411886Z/results.json` (SHA-256 `d6bbd9d26761d12e85cc8b9d043102de4900255ffae496347f12846587d913b4`; network disabled, legacy starter staged, no cleanup diagnostics). Crusader Squad verification passed 3/3 at `.tools/verification/20261029T214913900304Z/results.json` (SHA-256 `3908c593d6118a8c0f0325a0f3322072fe1600f934402d1215bde3c787b87546`; network disabled, no legacy starter staged, no cleanup diagnostics). This closes one candidate-pruning gap; arbitrary access routes and whole-formation coherency remain open.


29 October Surge certificate geometry reuse: repeated model proofs within one formation validation now share prepared surface domains and terrain/blocker obstacle geometry; preparation is lazy until a proof is needed. Contact-reachability passed 3/3 processes at `.tools/verification/20261029T215641625962Z/results.json` (SHA-256 `15c78849b45a6293d739f51c54fee4078679ab96a4df0b18bbf91f7b7282c0d7`; network disabled, no cleanup diagnostics). Integrated Fist/Surge and Crusader Squad passed 4/4 at `.tools/verification/20261029T215723406081Z/results.json` (SHA-256 `eee3a0e799edca24b42fc5b42a7c927971cba0c38f3b7fa82ccd90cb0d2f5806`; network disabled, no cleanup diagnostics). Reused and standalone terrain-route proofs agree. This reduces repeated preparation by construction but does not prove a general runtime improvement.


### Decimus source-provenance recheck — 29 October 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T220221019374Z/results.json` (SHA-256 `d975ec817706afccb3831fcf2c3f3c129bec76f3c79bc713cb63dc67368d7210`; `network: false`, legacy starter staged, no cleanup diagnostics). The audit was refreshed to the 29 October export and its parent and subject-slice manifest hashes and all 22 files in each were checked. The six required role rows still imply a minimum of six models against the source-listed five-model/110-point row; that contradiction remains blocked from construction.

### Same-floor route detour through ground — 29 October 2026

An exact-destination route on an elevated surface now compares the same-surface path with a composed route that descends through a listed access wall, routes around a full-height blocker on the ground and ascends through another listed access wall back to the same surface. The closest-region search checks the same alternative for elevated starts. The regression validates each movement segment independently and checks both exact and closest-region results. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_crusader_squad --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T221025950931Z/results.json` (SHA-256 `5fd49f8eb3bb63ef1c60ea634d7928182448d98df633afce828d392f5bcca2e4`; `network: false`, no legacy starter staged, no cleanup diagnostics; Crusader Squad process 26.13 seconds). This closes one missing same-floor transition case; arbitrary surface-network search and whole-formation coherency remain bounded, so Crusader Squad remains partial.


The same case also passes through the public Purge and Sanctify flow: a D6 roll of 6 grants 7 inches, preview leaves live position unchanged, and confirmation commits the model on the same upper floor. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fist_god_emperor --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T221352151675Z/results.json` (SHA-256 `492f32a285c6f27fa80b0eb8e4d1b82fa5f3087549562c4550f173679a4881ae`; `network: false`, legacy starter staged, no cleanup diagnostics; Godot process 159.04 seconds).

### Three current Space Marine datasheets and roster-readiness recheck — 29 October 2026 (UTC 30 October)

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_crusader_squad --only test_decimus_kill_team --only test_wolf_guard_headtakers --only test_marine_category_copy_limits --only test_implemented_catalog --only test_space_marine_profile_source_fields --only test_space_marine_copy_cost_parity --only test_marine_ability_boundaries --only test_space_marine_leader_links --only test_marine_detachment_roster_admission --only test_marine_conditional_weapon_traits --only test_marine_transport_admission` passed **14/14 processes** at `.tools/verification/20261030T015331833516Z/results.json` (SHA-256 `5B927A356524B9E0613EED2B39E33F4C5D17B851B1305D376944689D4A2B1338`; `network: false`, legacy starter staged, no cleanup diagnostics). This covers the three sheets, construction scopes and size choices, profile provenance, copy-tier costs, abilities, leader links, detachment admission, conditional weapon traits and transport admission.

The refreshed Godot UI was inspected after relaunch: Decimus exposes only the source-compatible 10-model/210-point option and displays why 5/110 is blocked; Crusader Squad displays its bounded movement-search note; changing the filter clears the prior unit's warning and preview. The visual check validates those screens, not game-wide legality. Source-page checks are documented in the three sheet audits and [Data Export audit](../wahapedia-import.md); the batch remains offline and does not certify full army legality or human playability.

### Current live checks for the three linked datasheets — 30 October 2026

The current Wahapedia 11e pages for [Decimus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team), [Wolf Guard Headtakers](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Headtakers) and [Crusader Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Crusader-Squad) were reopened and checked for composition, prices and sheet options. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --only test_wolf_guard_headtakers --only test_crusader_squad --timeout 600` passed **5/5 processes** at `.tools/verification/20261030T030111786006Z/results.json` (SHA-256 `6bee64a7cbcc7387b986e4cb9504a2e7798e1b6275474caa63f3899deacccd2d`; `network: false`, legacy starter staged, no cleanup diagnostics). This confirms the admitted local configurations and their explicit blockers. It does not resolve Decimus' 5-model composition conflict, add MFM costs for other Headtaker role mixes, certify the Wolf oval proxy, or close Crusader's bounded Surge routing and whole-formation coherency search.

### Full 161-sheet Space Marines inventory and local readiness rerun — 30 October 2026

The current local export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z` was hash-checked against all 22 manifest files. The six book-scoped slices cover 85 shared-book, 15 Black Templars, 14 Blood Angels, 16 Dark Angels, 10 Deathwatch and 21 Space Wolves datasheets; each slice has zero structural findings and references the same parent manifest. All 161 runtime identities match their verified source-book slice provenance. The source comparison found zero identity/numeric/model/weapon differences across 161 profiles and zero mismatches in 810 weapon-trait checks. The roster-cost audit matched all 576 source-priced size/tier rows across all 161 profiles and construction entries. Strict fixed-data scope is 159/161 because Decimus' five-model price row conflicts with its six-role minimum and the Headtakers' duplicate six-model costs conflict; those configurations remain blocked. The source export parent still has 68 unrelated structural findings.

The broad offline rerun used the same 138 Marine-focused suite stems recorded in `selected_suites` by the previous 30 October batch. It passed **140/140 processes** at `.tools/verification/20261030T030837835442Z/results.json` (SHA-256 `a3303d17cbc32cbf420f79d3e39e4854edbe7b7261c046e392c56bba292e611f`; `network: false`, legacy starter staged, no cleanup diagnostics). This covers the current profiles and the tested construction, abilities, equipment, relations, transports and Chapter admission paths. It does not close the three partial datasheet scopes, certify every rules interaction, full army legality, catalog-wide network behavior or human playtesting.

### Tarantula Air Defence Battery Legends profile — 30 October 2026

The first source-bounded Space Marines Legends runtime profile is Tarantula Air Defence Battery (book `000000356`, sheet `000000099`). The profile matches the hash-verified 11e export, adds Deadly Demise 1 and Sentry Programming to the unit ability catalog, makes its Fire Overwatch use free and independent of other units' uses, and labels the entry as Warhammer Legends in the builder and roster. The 60 mm circular footprint is an explicit simulation proxy because the source says `Use model` without a measurement; exact physical footprint clearance is not certified. Games Workshop's current guidance permits Legends at home, stores, clubs and campaigns; competitive event use requires organiser permission. See the [Tarantula audit](../marine-tarantula-air-defence-battery.md).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tarantula_air_defence_battery --only test_implemented_catalog --only test_firestrike_servo_turrets --only test_core_reactions --timeout 300` passed **6/6 processes** at `.tools/verification/20261030T043853086740Z/results.json` (SHA-256 `98e0f3301e7e5db4b17c78fca7b8d1540ceeeeb481e9b5eb4ec7596872d4d074b`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks the fixed datasheet, source hashes, roster admission, Incursion and Strike Force copy limits, UI/source labels, AttackPlan and Blast 2, Deadly Demise 1 allocation, Sentry Programming, and Firestrike/Core reaction regressions. It does not certify full army legality or physical measurement geometry.

### Legends roster singular count copy correction — 30 October 2026

The Army Builder now displays `1 model` for a single-model datasheet while retaining `models` for larger configurations. The focused Tarantula/catalog/Firestrike/Core batch passed **6/6 processes** at `.tools/verification/20261030T044853649302Z/results.json` (SHA-256 `5761064DF2A9E631D8C22D416D7427A0EF70BF0DB0C6B7E32767051CCC014207`, `network: false`, legacy starter staged, no cleanup diagnostics). A live Godot 4.7.2 capture at 1280×800 was inspected: `.tools/tarantula-builder-added.png` shows `Warhammer Legends`, `1 model` and `70 pts` in the draft row. The rendered cylinder is only the generic placeholder preview; no miniature-art or full application visual certification is claimed.

### Rapier Carrier Legends datasheet admission — 30 October 2026

The Rapier Carrier (book `000000356`, datasheet `000000110`) is admitted as a source-bounded local profile from the hash-verified 11e export. It includes all source weapons and both Quad Launcher firing modes, its Graviton Cannon/Laser Destroyer/Quad Launcher replacements, the 90-point cost, and Powerful Volley. The builder marks the model as Warhammer Legends and discloses that competitive-event use requires the organiser's permission. The source specifies `Use model` without a footprint dimension, so the game uses a 60 mm circle proxy; physical clearance is not certified. See the [Rapier audit](../marine-rapier-carrier.md).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 600 --only test_rapier_carrier --only test_implemented_catalog --only test_attack_plan --only test_core_reactions` passed **6/6 processes** at `.tools/verification/20261030T051201291008Z/results.json` (SHA-256 `428F20F2735DE83633B925B37F4830A263F063F4C9E951016DAC13E035AEC26E`; `network: false`, legacy starter staged, no cleanup diagnostics). After that batch, the focused Rapier test was expanded to cover both Quad Launcher modes, replacement selection, and additional Powerful Volley exclusions; the updated direct command `& '.tools/godot/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script tests/test_rapier_carrier.gd` also passed. This verifies the local sheet and tested interactions, not complete army legality, exact physical footprint, event acceptance or human playtesting.

### Tarantula Sentry Battery Legends datasheet admission — 30 October 2026

The Tarantula Sentry Battery (book `000000356`, datasheet `000000098`) is locally admitted with all 1–3 model sizes, 30 points per model, source-listed characteristics and weapons, the per-model Twin Lascannon replacement, Combat Doctrines and Sentinel Protocols. Sentinel Protocols retains normal Fire Overwatch CP cost and its once-per-phase, per-unit boundary; it does not bypass the core once-per-player-per-phase use limit, and it does not inherit the separate Air Defence Battery's free-use rule or Deadly Demise. Its `Use model` source footprint remains a 60 mm circle proxy. The builder labels it as Warhammer Legends and displays the event-approval condition. See the [sheet audit](../marine-tarantula-sentry-battery.md).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_tarantula_sentry_battery --only test_tarantula_air_defence_battery --only test_rapier_carrier --only test_implemented_catalog --only test_firestrike_servo_turrets --only test_attack_plan --only test_core_reactions` passed **9/9 processes** at `.tools/verification/20261030T052859052876Z/results.json` (SHA-256 `564f9634e89e95d661af592c24d62a8dd674d3b9c1e8f206895317b93906ef2b`; `network: false`, legacy starter staged, no cleanup diagnostics). The batch covered the three admitted Legends profiles, local roster/build UI, copy limits, Fire Overwatch and AttackPlan. It verifies these local scopes, not exact physical base clearance, competitive-event acceptance, full army legality or human playtesting.

### Sentinel Protocols wording reconciliation — 30 October 2026

The current Firestrike Servo-turrets datasheet explicitly says Sentinel Protocols permits Fire Overwatch regardless of any other uses that phase, and that its use does not prevent uses on other units. The Tarantula Sentry Battery datasheet only changes its snap-hit threshold to 4+. Core Rules 15.01 limits each player to one use of the same Stratagem per phase. The shared runtime now keeps Firestrike's explicit extra-use exception separate from Tarantula Sentry Battery's 4+ hit modifier; Tarantula Sentry Battery is blocked when another unit has already used Fire Overwatch. Tarantula Air Defence Battery keeps its separately worded free-use Sentry Programming rule. Current sources: [Firestrike Servo-turrets](https://wahapedia.ru/wh40k11ed/factions/space-marines/Firestrike-Servo-turrets), [Tarantula Sentry Battery](https://wahapedia.ru/wh40k11ed/factions/space-marines/Tarantula-Sentry-Battery), and [Core Rules 15.01](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_tarantula_sentry_battery --only test_tarantula_air_defence_battery --only test_rapier_carrier --only test_firestrike_servo_turrets --only test_attack_plan --only test_core_reactions --only test_implemented_catalog` passed **9/9 processes** at `.tools/verification/20261030T053830779547Z/results.json` (SHA-256 `3CE90AEC23AEB819918FEC071F6281DC63389C883DB0F39D21C700DED546EB9B`; `network: false`, legacy starter staged, no cleanup diagnostics). It confirms the source-specific Fire Overwatch limits, all three admitted Legends profiles, Firestrike's additional use, Tarantula Air Defence's free use, 4+ snap shooting, shared reactions, attack planning and catalog admission.

### Centurion Assault Squad source-bounded scope — 30 October 2026

The current [Wahapedia Centurion Assault Squad page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Centurion-Assault-Squad) and matching hash-verified Legends export slice agree on the source identity, profiles, prices, 50 mm bases, per-model replacements, Combat Doctrines, Annihilator Protocols and the launcher-granted EXPLOSIVES keyword. The official [Warhammer Legends guidance](https://www.warhammer-community.com/en-gb/articles/bbnskauh/big-space-marines-news/) allows Legends units in home, store, club and campaign games; competitive use is subject to the event organiser. Focused offline verification passed **10/10 processes** at `.tools/verification/20261030T061652252047Z/results.json` (SHA-256 `B768A70481D0279EE01719B452A55CE9704EE4F468B16E883F0DF6C442EE6E22`; `network: false`, legacy starter staged, no cleanup diagnostics). The run covered the sheet, catalog, attack planning, Core reactions, Combat Doctrines, source fields, capabilities and copy limits. The source-slice checker passed with zero scoped findings; its parent export retains 68 unrelated findings. This closes the declared local sheet scope only; full Space Marines army legality, network validation and human playtesting remain open. See the [sheet audit](../marine-centurion-assault-squad.md) and [machine-readable source/hash audit](../marine-centurion-assault-squad-audit.json).
### Vindicator source-bounded Legends admission — 30 October 2026

Vindicator (`000001188`, Space Marines Legends book `000000356`, 11e) is admitted at 185 points per unit for the first two copies and 200 points for the third, with independent optional Hunter-killer Missile and Storm Bolter choices. The sheet includes Demolisher Cannon, Armoured Tracks, Combat Doctrines, Deadly Demise D3, Damaged 4 and Siege Shield. The current Wahapedia page and matching verified Legends export slice agree; the scoped slice checker found zero structural issues among 56 subjects including linked dependencies. The parent export still has 68 unrelated findings.

The Siege Shield tests verify close-quarters modifier handling, BLAST selection without BLAST, target engagement restrictions, phase/eligibility checks, One Shot consumption, Damaged 4 and Deadly Demise D3. They also guard the shared Vehicle/Monster close-quarters behavior against 11 other Marine vehicle sheets. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_vindicator --only test_ballistus_dreadnought --only test_redemptor_dreadnought --only test_brutalis_dreadnought --only test_death_company_dreadnought --only test_gladiator_lancer --only test_gladiator_reaper_current --only test_gladiator_valiant --only test_storm_speeder_hammerstrike --only test_storm_speeder_hailstrike --only test_storm_speeder_thunderstrike --only test_baal_predator` passed **14/14 processes** at `.tools/verification/20261030T063731391958Z/results.json` (SHA-256 `82dd67dea1d954eb01ad3d3a4929c0cb31118eb5054543402e051a44e9258dfa`; offline, no legacy starter staged, no cleanup diagnostics). The source gives no physical footprint size, so the 60 mm circle remains a simulation proxy. This closes only the declared local sheet scope; full army legality, network behavior and human playtesting remain open. Competitive event use requires organiser permission. See the [Vindicator audit](../marine-vindicator.md) and [machine-readable source/hash audit](../marine-vindicator-audit.json).

### Integrated requested-sheet readiness and MFM points cross-check — 30 October 2026

The current Wahapedia 11e pages for [Decimus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team), [Wolf Guard Headtakers](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Headtakers) and [Crusader Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Crusader-Squad) were checked against their verified local source slices. The official [Deathwatch MFM v1.0](https://mfm.warhammer-community.com/en/deathwatch), [Black Templars MFM v1.0](https://mfm.warhammer-community.com/en/black-templars) and [Space Wolves MFM v1.0](https://mfm.warhammer-community.com/en/space-wolves), under the download index updated 14 October, list Decimus at 100/190 points and Crusader Squad at 150/290; the selected Wahapedia source/runtime lists 110/210 and 160/305. The two Headtakers compositions admitted by Wahapedia match MFM at 115/230 points for first/second copies and 125/240 for third-plus. Project source policy retains Wahapedia costs; Decimus and Crusader roster totals are therefore not certified for events requiring current MFM points.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_decimus_kill_team --only test_wolf_guard_headtakers --only test_crusader_squad --only test_fist_god_emperor --only test_contact_reachability --only test_implemented_catalog --only test_capabilities --only test_space_marine_profile_source_fields --only test_marine_category_copy_limits` passed **11/11 processes** at `.tools/verification/20261030T070201355409Z/results.json` (SHA-256 `eb3e935cc2ba1cbd6494ce3f5342b0af3a9a9f9b260affec4435a68b26b09913`; `network: false`, legacy starter staged, no cleanup diagnostics). The batch covers the three profiles, their associated local rules, catalog/capability status, source fields and copy limits. It does not certify full army legality, every interaction, network validation or human playtesting.

**Vanguard Veteran Squad (Warhammer Legends) local scope — 30 October 2026:** the verified local 11e sheet adds source-priced 5/10-model profiles, exact 32 mm bases and characteristics, every per-model Bolt Pistol replacement, Scouts 6, Combat Doctrines, charge-triggered melee Lethal Hits and bearer-only Storm Shield protection. The focused regression passed 9/9 processes at `.tools/verification/20261030T072146163985Z/results.json` (SHA-256 `32f7e60d8db33ce33af4da12e648d22158675514e10323880542ae8c27ac70ca`; `network: false`, no cleanup diagnostics). The slice audit confirms 28 source subjects and zero scoped structural findings; its report is audit-only. Legends use outside competitive events still requires organiser permission. Page/network integration, full army legality and human playtesting remain open. See the [sheet audit](../marine-vanguard-veteran-squad.md) and [machine-readable source/hash audit](../marine-vanguard-veteran-squad-audit.json).

**Predator Annihilator (Warhammer Legends) local scope — 30 October 2026:** the verified 11e export adds the one-model 135/145-point copy tiers, Lascannon/Heavy Bolter sponsons, separately selectable Hunter-killer Missile and Storm Bolter, Damage rerolls against MONSTER/VEHICLE targets on ranged attacks, Damaged 4, Deadly Demise D3 and Combat Doctrines. Its source does not define a footprint diameter; the simulation labels its 60 mm circle as a proxy. Focused regression passed **10/10 offline processes** at `.tools/verification/20261030T074016277314Z/results.json` (SHA-256 `26f6bbc5bfe8a7ee3dc6e314cb7aa83351dc61182a07f422b0f0a53d5e782375`; network disabled, legacy starter staged by the verifier, no cleanup diagnostics). The runtime identity export records 169 profiles with no missing source metadata at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v2.json` (SHA-256 `c23fc667a874001bdeca44d80b25e8cb75ef6ab969e3f3f8e62f50132678cc14`). Legends use outside competitive events still requires organiser permission. The live page and current event-pack points, exact physical footprint, full army legality, network behavior and human playtesting remain outside this local sheet scope. See the [sheet audit](../marine-predator-annihilator.md) and [machine-readable source/hash audit](../marine-predator-annihilator-audit.json).

**Predator Destructor (Warhammer Legends) local scope — 30 October 2026:** the verified 11e export adds the one-model 140/150-point copy tiers, Predator Autocannon and the Lascannon/Heavy Bolter sponson choice, plus independently selectable Hunter-killer Missile and Storm Bolter. Destructor improves ranged AP against INFANTRY only. Focused regression passed **11/11 offline processes** at `.tools/verification/20261030T074914940625Z/results.json` (SHA-256 `1e62efde0861e0ec4e5ebc3d652fa7b716078f627c7a94e5321df4d9a81333bc`; network disabled, legacy starter staged by the verifier, no cleanup diagnostics). The runtime identity export records 170 profiles with no missing source metadata at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v3.json` (SHA-256 `aa09955221f4858f10bc3be74395e9b00a970d4ffd0fc838af1ce1a8167ea249`). The source does not define a footprint diameter; the simulation labels its 60 mm circle as a proxy. Legends use outside competitive events still requires organiser permission. The live page and current event-pack points, exact physical footprint, full army legality, network behavior and human playtesting remain outside this local sheet scope. See the [sheet audit](../marine-predator-destructor.md) and [machine-readable source/hash audit](../marine-predator-destructor-audit.json).

**Land Raider Excelsior (Warhammer Legends) local scope — 30 October 2026:** the verified 11e export and source slice admit datasheet `000000067` at 250 points per copy, with all nine weapon rows, four optional additions, 12-space transport capacity and Centurion triple occupancy. Combat Doctrines, Damaged 5, Deadly Demise D6 and Rites of Battle are registered; the exact source/hash and proxy limits are in the [sheet audit](../marine-land-raider-excelsior.md) and [machine-readable audit](../marine-land-raider-excelsior-audit.json). The dedicated check passed **3/3 processes** at `.tools/verification/20261030T105104891887Z/results.json` (SHA-256 `769a354db815f489a64c72683738fc5eddeee69e742097ae77b31f9c49b2ec94`). The connected transport/catalog/ability regression passed **15/15 processes** at `.tools/verification/20261030T104449773869Z/results.json` (SHA-256 `17febc9758170782a92a4e09586e7b8e370ffa50047e15d2f6e54c0080a02e19`; `network: false`). The refreshed runtime identity export records 178 profiles with zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v12.json` (SHA-256 `b7388894176ed072f1a91186e926bf215a617a0014b57ede4e2ced7456ffcd1a`). A separate source-only check passed for all 56 datasheets assigned to Legends book `000000356`, including 28 Space Marines identities; runtime admission is checked separately. Local completeness does not establish full army legality, exact physical clearance, current online page/event-pack status or competitive-event organiser permission. Network validation remains deferred to final integration.

**Falchion (Warhammer Legends) local scope — 30 October 2026:** the verified 11e export admits datasheet `000001666` at 420 points per copy, up to three copies. All ten weapon rows, the three independent loadout choices (20 legal combinations), Combat Doctrines, Damaged 8, Deadly Demise D6+2 and Titan-killer are represented. The source says `Use model`; the runtime labels its 60 mm circle as a proxy. The dedicated test passed **3/3 processes** at `.tools/verification/20261030T110317013906Z/results.json` (SHA-256 `401935e223376558498686cc3a60c59d5cb8a2f17687308e3670a108cbde7738`; network disabled, no cleanup diagnostics). The connected catalog/source/copy-cost/capability/ability/weapon and vehicle regression passed **14/14 processes** at `.tools/verification/20261030T110346483572Z/results.json` (SHA-256 `63b9eec14a424902d0c18ecfa4927eee2bdad270a1ebcfafd576b7e2a950ca04`; network disabled, no cleanup diagnostics). Runtime export v13 records 179 profiles with zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v13.json` (SHA-256 `22d65f1464791f7ebecb55d3cd206943119c84d0c6effff2b795530e0b009a28`). The all-56-subject Legends slice recheck has zero scoped structural findings; it is an audit-only source completeness result. Local sheet readiness does not certify full army legality, physical clearance, live-page/event-pack validation, event approval, network behavior or human playability. See the [sheet audit](../marine-falchion.md) and [machine-readable source/hash audit](../marine-falchion-audit.json).

### Hammerfall Bunker (Warhammer Legends) source-bounded local scope — 30 October 2026

The verified Wahapedia 11e export admits datasheet `000000097` at 175 points with its Heavy Bolter Array, Heavy Flamer replacement, both Missile Launcher profiles, copy limits, Damaged 5, Deadly Demise D6, Ceramite Cover, Defensive Array and Fortification effects. The connected targeted run passed **17/17 processes** at `.tools/verification/20261030T135350883038Z/results.json` (SHA-256 `67e1e3d2a78742021ef5c2493b844cfee81449cafec739db804a204134fa26d3`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the sheet, local catalog and source fields, all runtime profile copy-limit admission, capabilities, AttackPlan, Core reactions, Smokescreen, Firestrike, Tarantula Sentry Battery, transport regressions and Combat Doctrines. After adding a Hammerfall-specific Army Builder assertion, the updated catalog/UI check passed **3/3 processes** at `.tools/verification/20261030T135718985528Z/results.json` (SHA-256 `c4f968f771153d20707473e9565854261db98a5974e46b647d1cdbd38aa678fd`; `network: false`, no legacy starter staged, no cleanup diagnostics). The final dedicated regression forces Deadly Demise D6 to 6, checks the trigger and verifies the six-mortal-wound packet; `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_hammerfall_bunker` passed **3/3 processes** at `.tools/verification/20261030T140049678605Z/results.json` (SHA-256 `026c9dd6bf4aedcaa0980116a4d24b8ef6f0ddfdd1e0eb8b085006295c85c981`; `network: false`, no legacy starter staged, no cleanup diagnostics).

The refreshed 28-subject Legends slice audit has zero scoped structural findings; the parent export retains 68 unrelated findings. The runtime identity export records **185 profiles** and zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v18-hammerfall.json` (SHA-256 `e7307ec9a36350ccd64abfe2d078f2a8caca895831abe5cffe2b7113db05d9e4`). Exact physical placement is not certified because the source says `Use model` without dimensions; the app uses a labelled 120 mm circular interaction proxy. Legends event approval, live-page validation, full army legality and human playtesting remain open. See the [Hammerfall sheet audit](../marine-hammerfall-bunker.md) and [machine-readable source/hash audit](../marine-hammerfall-bunker-audit.json).

### Transcendent C’tan movement and roster restrictions — 31 October 2026

The local Necrons App v1.2 export supplies the Transcendent C’tan source ability and C’TAN SHARD roster restriction. The movement choice retains the Advance D6, removes the distance cap, permits transit across all model bases, and validates the more-than-8-inch horizontal endpoint against every enemy unit. Terrain, board edge, destination overlap and coherency checks remain active. A FLYING Transcendent C’tan may also declare Take to the Skies to pass through terrain while retaining unlimited distance. Core Rules §§09.06 and 21.03 were checked on Wahapedia only to resolve the Advance and Take to the Skies interactions; datasheet facts remain from the local extraction.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_transdimensional_displacement --only test_necron_warriors_current --only test_capabilities` passed **5/5 processes** at `.tools/verification/20261031T164906041827Z/results.json` (SHA-256 `7c1189ee61fd38f4de6c441a403d48a2af832537abfa9d0577dff0bb606ff448`; `network: false`, no cleanup diagnostics). This checks the ability profile binding, source-local Enhancement restriction, forged roster assignment rejection, movement selection, unbounded path, pass-through, endpoint requirement and existing related capability regressions. It does not complete the Transcendent datasheet or Necron roster admission.

A broader batch including `test_movement_types` stopped at an end-turn aircraft return case (`aircraft_rules.gd:75`, missing `reserves` key) before reaching the newly isolated movement checks. See `.tools/verification/20261031T164743345902Z/results.json`; the dedicated Transdimensional suite passed in the successful run above.

After adding the move to the player’s Movement choices, the integrated UI/regression run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_transdimensional_displacement --only test_turn_choices_ui --only test_necron_warriors_current --only test_capabilities` passed **6/6 processes** at `.tools/verification/20261031T165132611766Z/results.json` (SHA-256 `1b3a2cd265bcce7257ae01c14f18d79e5f514d984a0402852dcd17bf1d9d9ade`; `network: false`, no cleanup diagnostics).

The focused suite now also checks the FLYING C’tan’s optional Take to the Skies terrain transit without reintroducing a range cap. The integrated run with that interaction passed **6/6 processes** at `.tools/verification/20261031T165556974356Z/results.json` (SHA-256 `0efd454fc78157985314013a5db626f4be581b163847ac91acd9e4c366bc8975`; `network: false`, no cleanup diagnostics). It does not complete the Transcendent datasheet or Necron roster admission.

### Royal Warden local datasheet scope — 31 October 2026

The verified local App v1.2 profile for datasheet `000002350` now has a bounded runtime scope: its one-model/50-point construction, characteristics, fixed weapons, Leader targets, Reanimation Protocols, Adaptive Strategy and once-per-battle Engrammatic Logic. Engrammatic Logic is available at the start of either player's turn, targets a friendly Battle-shocked Necrons unit within 12 inches, and clears Battle-shock when resolved. Adaptive Strategy uses the shared Combat Doctrines shoot/charge gates and does not expose the Gladius Stratagem as a Warden ability. The Royal Warden was the first current Necron construction choice at that point; this did not open the remaining 50 profile gates or establish full faction roster legality.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_royal_warden --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **8/8 processes** at `.tools/verification/20261031T171745711032Z/results.json` (SHA-256 `168544b07e03ae40fe6e1864cd708c0c70cb1803cfcfe53ff481594e9ce990f9`; `network: false`, legacy starter staged, no cleanup diagnostics). The CUA desktop capture could not initialize in this session, so no in-game screenshot was produced for the Army Workshop's preserved Space Marines default. Network validation, full Necron army legality and the other 50 datasheet scopes remain open.


### Necron Warriors local datasheet scope — 31 October 2026

Necron Warriors (`000000534`) now have a source-bounded local scope for both App v1.2 configurations (10 models/85 points and 20/190), Gauss flayer and Gauss Reaper profiles, independent per-model flayer-to-Reaper replacement, restoration to the default, Reanimation Protocols and Their Number is Legion's re-roll each time Reanimation activates. The choice is scoped to current sourced matches; legacy starter-backed training profiles do not receive it. Current construction has three locally checked Necron sheets—Canoptek Reanimator, Royal Warden and Necron Warriors—while the other 48 remain gated. Full faction roster legality remains open.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_warrior_gauss_reaper --only test_necron_warriors_current --only test_necron_royal_warden --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **9/9 offline processes** at `.tools/verification/20261031T173143934713Z/results.json` (SHA-256 `0424deaa3e80943d507199e9145e1a0a60db0f53995587a517e475cf774aff65`; `network: false`, legacy starter staged, no cleanup diagnostics). Network validation, full Necron army legality, human playtesting and the other 48 datasheet scopes remain open.

### Immortals local datasheet scope — 31 October 2026

Immortals (`000000535`) now have a source-bounded local scope for both App v1.2 configurations (5 models/65 points and 10/130), Gauss blaster and Tesla carbine profiles, independent per-model replacement and restoration, Reanimation Protocols, and Implacable Eradication. Each attack re-rolls Wound rolls of 1; against a target in objective-marker range, the attack opens an optional free choice to re-roll any Wound die, including successful results. The local wording omits “failed” in that clause. Wahapedia's current sheet page repeats the export, and its general Core Rules reroll section has no failed-roll restriction; the interpretation is recorded in the [Necrons coverage ledger](../data/necrons-coverage.md). Legacy starter-backed training profiles do not gain the current sourced equipment choice. Current construction has four checked Necron sheets; 47 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_immortals --only test_necron_warrior_gauss_reaper --only test_necron_warriors_current --only test_necron_royal_warden --only test_current_unit_abilities --only test_current_unit_combat --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **11/11 processes** at `.tools/verification/20261031T174432309140Z/results.json` (SHA-256 `7411d320f2042d45359a39d619bd1ad51d04e8572fe52dab42bf019db0e650ec`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Immortals profile, public attack declaration and optional successful-Wound reroll, plus connected Necron, catalog and shared combat regressions. Network validation, full Necron army legality, human playtesting and the other 47 datasheet scopes remain open.

### Deathmarks local datasheet scope — 31 October 2026

Deathmarks (`000000537`) now have a source-bounded local scope for both App v1.2 configurations (5 models/60 points and 10/120; third-plus copies 70 and 130), the fixed synaptic disintegrator and close combat weapon, Deep Strike, Reanimation Protocols, and Hyperspace Hunters. The local datasheet sentence offers one shot when the opponent sets an enemy unit up from Reserves during that opponent’s Movement-phase Reinforcements step, within 18 inches and visible, and only against that unit when it is an eligible ranged target. Declining the offer does not spend the shot; completing it does. A Drop Pod arrival that opens the choice delays passenger disembarkation until the choice ends. Current construction has five checked Necron sheets; 46 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_deathmarks --only test_necron_immortals --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **9/9 processes** at `.tools/verification/20261031T193811705794Z/results.json` (SHA-256 `9b4f99a811f13131eb1710b18480965045adaccd23f39733e908d128f8bd2de0`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Deathmarks profile, Hyperspace Hunters timing and targeting, plus connected Necron, catalog and Reanimation regressions. Network validation, full Necron army legality, human playtesting and the other 46 datasheet scopes remain open.

### Flayed Ones local datasheet scope — 31 October 2026

Flayed Ones (`000000538`) now have a source-bounded local scope for both App v1.2 configurations (5 models/55 points and 10/100), the fixed flayer claws, Infiltrators, Stealth, Reanimation Protocols and Flesh Hunger. The local ability rows also include Stealth, which an earlier transcription had omitted. Flesh Hunger makes each successful melee Hit a Critical Hit when the target is Below Half-strength. Exactly half-strength does not qualify. Current construction has six checked Necron sheets; 45 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_flayed_ones --only test_necron_deathmarks --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **9/9 processes** at `.tools/verification/20261031T195020897663Z/results.json` (SHA-256 `db4557baaa8bc30b422ef89118f13aaaeb4743e23ee79561bb26630d93e7e0cf`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Flayed Ones profile, deployment, cover, and Flesh Hunger strength thresholds, plus connected Necron, catalog and Reanimation regressions. Network validation, full Necron army legality, human playtesting and the other 45 datasheet scopes remain open.

### Canoptek Scarab Swarms local datasheet scope — 31 October 2026

Canoptek Scarab Swarms (`000002114`) now have a source-bounded local scope for both App v1.2 configurations (3 models/40 points and 6/80), the fixed Feeder mandibles, Reanimation Protocols, Self-destruction and Chittering Swarm. Self-destruction is optional at the start of the Fight phase: destroying one engaged model inflicts D3 mortal wounds on a modified 2–5, or 3 mortal wounds on a 6+, with +1 to the roll against a VEHICLE. A modified 1 inflicts none. Chittering Swarm reduces engaged enemy Objective Control by 1 per engaged Scarab unit, to a minimum of 1, and sets Scarab Objective Control to 1 while a model is within 6 inches of a friendly CRYPTEK. Engagement uses this project’s 2-inch base-edge check. The local export was unambiguous, so no extra online page was required. Current construction has seven checked Necron sheets; 44 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_scarab_swarms --only test_necron_flayed_ones --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols` passed **9/9 processes** at `.tools/verification/20261031T200056963803Z/results.json` (SHA-256 `9ab16d121c3cbc9426c86d25d476ee8415e6c4d6a139c2cce6c7be104e0c14d4`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Scarab profile, Self-destruction and Chittering Swarm, plus connected Necron, catalog and Reanimation regressions. Network validation, full Necron army legality, human playtesting and the other 44 datasheet scopes remain open.

### Hexmark Destroyer local datasheet scope — 31 October 2026

Hexmark Destroyer (`000002355`) now has a source-bounded local scope for its one-model/75-point configuration, Enmitic disintegrator pistols, Deep Strike, Lone Operative, Reanimation Protocols, Inescapable Death and Multi-threat Eliminator. The local Pistol label uses the existing close-quarters shooting keyword. Inescapable Death lets one unit with the ability use Fire Overwatch for 0CP once per turn, including after another unit has used that Stratagem this phase, and its Overwatch hits on unmodified 2+. Multi-threat Eliminator is an optional shot after an enemy unit shoots a friendly Necrons unit within 3 inches; declining does not spend it. The local export was unambiguous, so no extra online page was required. Current construction has eight checked Necron sheets; 43 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_hexmark_destroyer --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols --only test_core_reactions` passed **9/9 processes** at `.tools/verification/20261031T201625878945Z/results.json` (SHA-256 `af417d99df8ed2725ea52a3ef86b70a999677bdc39e204dd6f79ed1ffe0a433a`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Hexmark profile, Lone Operative, Multi-threat Eliminator and Inescapable Death, plus connected Necron, catalog, Reanimation and core Overwatch regressions. Network validation, full Necron army legality, human playtesting and the other 43 datasheet scopes remain open.

### Canoptek Doomstalker local datasheet scope — 31 October 2026

Canoptek Doomstalker (`000002115`) now has a source-bounded local scope for its one-model/130-point configuration, Doomsday blaster, Twin gauss flayer, Doomstalker limbs, 4+ invulnerable save, Deadly Demise D3, Reanimation Protocols, Sentinel Construct and Damaged 4. Sentinel Construct scores Fire Overwatch hits on unmodified 5+. The Stratagem still costs 1CP and keeps the normal once-per-phase limit. The Damaged 1–4 wound penalty subtracts 1 from normal Hit rolls and does not change the unmodified Overwatch threshold. Deadly Demise uses the shared 6-inch resolver. The local export was unambiguous, so no extra online page was required. Current construction has nine checked Necron sheets; 42 remain gated. Full faction roster legality remains open.

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_doomstalker --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols --only test_core_reactions` passed **9/9 processes** at `.tools/verification/20261031T202516905119Z/results.json` (SHA-256 `a2c95f1a2fd9f2a3c3123dadbcd1084e729405245e9f81078177b14d38e76130`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the current Doomstalker profile, Damaged threshold, Sentinel Construct and Deadly Demise, plus connected Necron, catalog, Reanimation and core Overwatch regressions. Network validation, full Necron army legality, human playtesting and the other 42 datasheet scopes remain open.

### Canoptek Macrocytes integration verification — 12 November 2026

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_macrocytes --only test_necron_warriors_current --only test_capabilities --only test_implemented_catalog --only test_current_unit_abilities --only test_reanimation_protocols --only test_necron_void_dragon` passed **9/9 processes** at `.tools/verification/20261112T060950914459Z/results.json` (SHA-256 `1C97AB6E7A872DFF8CD26AC1501A0E4C90FF9E5E7BFA8E25AA710DBF433F85E6`; `network: false`, legacy starter staged). The Macrocytes suite and import completed without cleanup diagnostics. The catalog, current-unit-abilities and Reanimation suites reported Godot shutdown RID/ObjectDB cleanup diagnostics, but exited successfully and did not stop on error. This covers the Macrocytes source profile, current admission, loadouts, Harassment Swarm, Accelerator Mandible and Nanoscarab Projector with connected shared regressions. It does not certify full Necrons roster legality, network play or event legality.

### Canoptek Spyders local scope — 12 November 2026

Canoptek Spyders (000000551) now have a source-bounded local scope for both priced unit sizes, all three per-model equipment choices, Deadly Demise 1, Fabricator Claw Array, Gloom Prism, Reanimation Protocols and optional Command-phase Canoptek Swarm placement. The datasheet facts use the verified local Necrons App v1.2 export. The local Swarm sentence does not specify whether destroyed Spyder models count; the runtime uses surviving Spyders as a scoped reading. Wahapedia Core Rules §01.02.03 was checked only for returned-model setup constraints; this research and the interpretation are recorded in the [Necrons coverage ledger](../data/necrons-coverage.md).

The integrated offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_spyders --only test_necron_scarab_swarms --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols --only test_necron_macrocytes` passed **10/10 processes** at `.tools/verification/20261112T224920767547Z/results.json` (SHA-256 `dd201d247ac474ea4e27943bf9addee01da6f647d09557d931eb33b01ad2c45f`; `network: false`, legacy starter staged). Import, Python checks, the Spyders suite and connected Scarab, current Necron, ability, capability, catalog, Reanimation and Macrocytes suites passed. The current-unit-abilities, implemented-catalog and Reanimation processes reported shutdown RID/ObjectDB cleanup diagnostics; they exited successfully without stopping on error. The focused Spyders suite had no cleanup diagnostics. This does not certify full Necron roster legality, network play, human playtesting or event legality.

### Canoptek Tomb Crawlers integration verification — 12 November 2026

The integrated offline run was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_tomb_crawlers --only test_necron_warriors_current --only test_capabilities --only test_implemented_catalog --only test_current_unit_abilities --only test_reanimation_protocols --only test_attached_reanimation --only test_necron_spyders --only test_necron_macrocytes
```

It passed **11/11 processes** at `.tools/verification/20261112T233108511621Z/results.json` (SHA-256 `5DEF9672948F54800C2F938CFC660A46D2482DAEC3EA9732D82855BB426C53CC`; `network: false`, legacy starter staged). The Tomb Crawlers suite covers the source profile and 2/60 admission, the isolator's one-model-per-unit cap, optional Retinue through the public setup choice, Cryptothralls and duplicate-unit restrictions, per-model ranged modifier ignoring through the 12-inch boundary, and Reanimation on the supported attached composition. Catalog, capability, current Necron profile, Reanimation and existing Canoptek regressions passed. `test_implemented_catalog`, `test_current_unit_abilities` and `test_reanimation_protocols` reported Godot shutdown RID/ObjectDB cleanup diagnostics; they exited successfully and did not stop on error. Import, Python checks, the focused Tomb Crawlers test and other selected suites had no cleanup diagnostics. The run remains local scope validation; it does not certify full roster legality, network play, human playtesting or event legality.


### Doom Scythe integration verification — 12 November 2026

The integrated offline check was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_doom_scythe --only test_necron_warriors_current --only test_capabilities --only test_implemented_catalog --only test_current_unit_abilities --only test_reanimation_protocols --only test_attached_reanimation --only test_necron_doomstalker --only test_necron_doomsday_ark --only test_attack_plan --only test_necron_tomb_crawlers
```

It passed **13/13 processes** at `.tools/verification/20261113T000938285746Z/results.json` (SHA-256 `d68dc663ca6f38ae782173bad4b2ce696c796844f985be3fd519a61732ca0f65`; `network: false`, legacy starter staged). The focused Doom Scythe suite covers its source profile and 1/200 admission, both fixed weapons, Aircraft identity, Reanimation, Damaged 4, Deadly Demise D3, the mandatory target-controller choice, both stances and duration, Stand firm critical Hits, and weapon-specific triggering. The expanded ledger suite confirms its mapped source abilities and admitted catalog status. `test_implemented_catalog`, `test_current_unit_abilities` and `test_reanimation_protocols` reported Godot shutdown RID/ObjectDB cleanup diagnostics; all exited successfully without stopping on error. This validates only the local scope. It does not certify full Necron roster legality, all Aircraft movement interactions, network play, human playtesting or event legality.

### Saved Intercessor Sergeant match loadouts — 12 November 2026

The focused offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_intercessor_current --only test_army_builder --only test_match_command_service --timeout 300` passed **5/5 processes** at `.tools/verification/20261113T014118425608Z/results.json` (SHA-256 `849960AFDD8EF1E750E152E35676F109C1FE84C32A1202D19EA7A097B499D27F`; `network: false`, legacy starter staged). Intercessor checks cover per-copy saved weapon materialization, omitted saved-list rifle/melee preparation choices, rejection of stale direct and public commands without mutation, retained Grenade Launcher preparation and the legacy setup-choice path. Army Builder and match-command regressions passed. `test_army_builder` reported Godot shutdown RID/ObjectDB cleanup diagnostics after its successful exit; import, Python checks, Intercessor and match-command processes had none. This verifies the local UX/data path only; full army legality, visual parity for each loadout and network validation remain open.

### Army Builder local identity foundation — 12 November 2026

Saved unit copies now receive stable local IDs, with stable model-slot IDs derived from each copy ID. Repricing and splitting a saved copy preserve its identity, equipment and appearance assignments; new copies receive fresh identities. Legacy lists gain IDs in memory and persist them on their next save. These IDs remain local and are removed from gameplay roster projections.

The focused offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_saved_armies --only test_local_armies_models --timeout 300` passed **5/5 processes** at `.tools/verification/20261113T022600140619Z/results.json` (SHA-256 `7F50EE402FBCF93EB46087E12636F8C323A3902337D8814749C231CEDDC84918`; `network: false`, legacy starter staged). Import, Python checks and all three focused suites exited successfully without stopping on error. The three Godot test processes emitted shutdown RID/ObjectDB cleanup diagnostics. This verifies identity persistence and compatibility paths; broader model equipment editing, visual resolution, snapshots, Quick Match and full-plan acceptance coverage remain open.

### Stable model appearance references and visual resolver — 12 November 2026

Manual per-model sculpt references now use stable model IDs derived from saved unit-copy IDs. Legacy model-slot arrays migrate in memory and remain available as a compatibility view; resize, save/reload, repricing and splitting a copied entry preserve assigned sculpt references. The local board resolver records the chosen variant/source, rationale and fallback warning, and preserves an unavailable manual selection while it tries a compatible local appearance or the built-in miniature. Rules equipment and gameplay state are unchanged.

The focused offline run `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_saved_armies --only test_local_armies_models --timeout 300` passed **5/5 processes** at `.tools/verification/20261113T023957755172Z/results.json` (SHA-256 `F6EF7AB567288CBEDB81D2A4FC237502A69A5418D3E3F0E50E50EFF65A81D53D`; `network: false`, legacy starter staged). Import, Python checks and all focused suites exited successfully without stopping on error. The three Godot test processes reported shutdown RID/ObjectDB cleanup diagnostics. The tests cover legacy override migration, stable IDs through resize/split/reload, local-only projection, resolver priority/fallback and rendering. General per-model rules loadouts, visible gallery rationale, Warlord/Leader list assignments, readiness/Quick Match and broad asset-failure coverage remain open.

### Per-model Eliminator equipment in saved armies — 13 November 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_eliminators --only test_saved_armies --timeout 300` passed **5/5 processes** at `.tools/verification/20261113T031636910470Z/results.json` (SHA-256 `8F46B3A6A9900EE9E37B9F26DEF0739FE2DC159F0DEBE901DAC9E1E56FD51D3D`; `network: false`, legacy starter staged). The Army Builder, Eliminator and saved-army suites passed; all three emitted shutdown-only RID/ObjectDB cleanup diagnostics. Coverage checks independent saved identities and UI controls for the Sergeant and ordinary Eliminators, per-copy configuration grouping/admission, saved weapon materialization, suppressed/rejected repeat setup choices, and separation of the frozen match selection from later source-list edits. Import and Python checks passed without cleanup diagnostics. This covers the supported Eliminator profile and existing Intercessor Sergeant path, not all loadout-bearing datasheets, Warlord/Leader editing, immutable visual references, full readiness/Quick Match migration, complete army legality or LAN validation.

### Saved Warlord and Leader/Support formation candidates — 13 November 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_saved_armies --timeout 300` passed **4/4 processes** at `.tools/verification/20261113T042914812877Z/results.json` (SHA-256 `F5973CA413E144E2A163A1DE10B6058E18F37733A7E2990FF906995A48B9E64C`; `network: false`, legacy starter staged). Army Builder checks cover the Warlord and attachment candidate controls and stable IDs. Saved-army integration maps those IDs to canonical units/models, replays Warlord and attachment choices through the current public rules choices for both players, rejects an illegal pairing, and reconstructs the declarations from the saved match setup. Both Godot test processes emitted shutdown-only RID/ObjectDB cleanup diagnostics; import and Python processes passed without them. This is local setup evidence only; LAN still uses in-match declarations, and it does not establish full army legality or broader rules coverage.

### Quick Match saved-army route — 13 November 2026

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_saved_armies --timeout 300` passed **4/4 processes** at `.tools/verification/20261113T044555628143Z/results.json` (SHA-256 `fa21c59b4d396bffac549dd7309c7840eb9066135537d4751e6d2ebe1d755d2e`; `network: false`, legacy starter staged). The saved-army integration starts the explicit standard Quick Match preset from two current-catalog lists, confirms current unit abilities are enabled while official mission/core stratagem options are disabled, and confirms automatic damage allocation before deployment. The Army Builder and saved-army suites passed; both Godot processes emitted shutdown-only RID/ObjectDB cleanup diagnostics. This result predates the 13 November follow-up that compacts the visible precheck and adds appearance candidate explanations. The compact readiness and appearance inspector were viewed in Godot at 1280×800; the latest saved-equipment-to-visual-hint comparison is only parser checked and still needs a refreshed in-game review. Neither the test report nor the UI review certifies complete army legality, every rules interaction, cross-machine LAN or visual parity.

### Eliminator appearance batch action — 13 November 2026

The Appearance tab now offers an explicit batch action when the selected model is an Eliminator Squad member with another model in the same unit copy that has the same Sergeant/trooper role and saved ranged weapon. It copies or clears only the local visual override for those matching model IDs; gameplay equipment, other unit copies and match state are unchanged. This initial version received only a Godot 4.7.2 headless editor parse/import and `git diff --check`; no test suite or refreshed in-game capture was run for the action.

### Per-model Necron equipment and shared appearance batching — 13 November 2026

The Army Builder stores Gauss flayer/Gauss reaper choices for each Necron Warrior, Gauss blaster/Tesla carbine choices for each Immortal, and one of four source-listed packages per Canoptek Macrocyte against stable model IDs. Current-catalog admission validates the model counts and choices, including the one-per-unit Atomiser and Accelerator Mandible caps; canonical grouping keeps differently equipped copies distinct. Local saved-army construction resolves these choices through the verified Necrons App v1.2 profiles, locks the corresponding Army Preparation choices, and reports saved equipment in the readiness summary. Ranged and melee records are passed to the local ForceOrg matcher; if there is no exact ready visual, the normal miniature fallback remains.

Appearance batching now uses a saved role/equipment key and applies only within the selected unit copy. The supported model schemas are Eliminators, Necron Warriors, Immortals and Canoptek Macrocytes. It copies or clears visual overrides only; loadouts, other copies, match state and network state are unchanged. Rules facts use local snapshot `20261031T053336Z`, Necrons App book `000000029`, version 1.2; see the [Necrons coverage ledger](../data/necrons-coverage.md).

Static verification: `& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit` exited 0 after the final script changes, and `git diff --check` exited 0. No test suite was run or added for this increment, and no refreshed in-game capture was made. This confirms editor parse/import only; it does not verify UI behavior, save/reload integration, visual matching, broad rules coverage, full army legality or LAN behavior.

### Canoptek Spyder equipment in saved armies — 13 November 2026

The Army Builder now stores the three independent source-listed Canoptek Spyders options for each stable model ID. Current-catalog admission checks the unit-copy/model array shape and option fields; the canonical roster includes each model's chosen combination. Local saved-army construction applies the saved equipment before Deployment, locks it against duplicate Army Preparation changes, and includes it in the readiness summary. The appearance preview checks the resulting ranged/melee equipment against local ForceOrg hints; identical model roles and equipment can share an appearance override within the same unit copy. The scope is based on local Wahapedia Necrons App v1.2 sheet `000000551`; the scoped surviving-Spyder interpretation for Canoptek Swarm remains unchanged.

Static verification: the Godot 4.7.2 headless editor parse/import and `git diff --check` exited 0. No test suite was run or added, and no in-game UI capture was made for this increment. The checks establish parser/import success only; runtime save/reload, equipment application, visual matching, full army legality and LAN behavior remain unverified here.

The gameplay roster projection now materializes both Spyder and Tomb Crawler saved choices into their canonical fields before removing local model IDs. This closes a serialization omission found during code review; it is not evidence of a successful network session.

### Canoptek Tomb Crawler equipment in saved armies — 13 November 2026

The Army Builder stores the Twin gauss reaper or transdimensional isolator per model against stable IDs, and current-catalog admission rejects more than one isolator per unit. Local match materialization applies and locks these choices before Deployment. The local visual matcher receives the selected ranged profile plus fixed melee profile; a missing exact sculpt keeps the standard appearance. The code review also found and fixed the LAN roster projection so it emits canonical Spyder and Tomb Crawler equipment arrays before stripping local model IDs. Cross-machine LAN behavior remains unvalidated.

Static verification after the projection change: `& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit` exited 0 and `git diff --check` exited 0. No test suite was run or added, and no in-game capture was made for this increment. This confirms parser/import and whitespace checks only; it does not establish runtime save/reload, network behavior, full army legality or visual parity.

### Annihilation Barge and Monolith saved weapons — 13 November 2026

The Army Builder now persists the Barge's Gauss cannon or source-listed Tesla cannon and the Monolith's four Gauss Flux Arcs or four Death Rays by stable model identity. Admission validates those choices against the local Necrons App v1.2 profiles; canonical selections carry them into local match materialization and gameplay roster projection. Saved-list matches apply and lock the choice before Deployment. The preview matcher receives the selected ranged records and retains the normal fallback when no exact visual is ready. The legacy Army Preparation replacement handlers now use canonical datasheet IDs when calling the shared profile adapter.

Rules facts use local snapshot `20261031T053336Z`, Necrons App book `000000029`, version 1.2; the source identity, retrieval metadata and hashes are recorded in the [Necrons coverage ledger](../data/necrons-coverage.md). Static verification with `& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit` exited 0, and `git diff --check` exited 0. No test suite was run or added. A live Army Workshop capture showed its existing Space Marines list and preview, not these vehicle controls; the control behavior remains visually unverified. These checks establish parser/import success only, not runtime save/reload, network behavior, complete army legality or visual parity.

### Appearance availability feedback — 13 November 2026

The Army Builder gallery now labels local assets as ready, queued/download-pending, downloading, missing or conversion/validation-failed. Candidate tooltips explain the state and fallback. A failed preparation is tracked for the current local session and is cleared when that candidate is retried or successfully prepared; saved visual assignments remain intact.

Static verification with `& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit` exited 0 and `git diff --check` exited 0. No test suite was run or added. No refreshed in-game capture was made for the new status labels. The implementation is scoped to gallery candidates and the local preparation session; comprehensive cache-corruption, import-failure persistence and end-to-end recovery remain unverified.

### Immutable saved-match visual-copy binding — 13 November 2026

Local match creation now maps every saved copy ID to its canonical match unit index and preserves the source-list appearance ordinal. Version 2 local appearance snapshots retain those references and validate that every frozen unit is represented exactly once by the matching datasheet and model count. The board resolves manual and shared visual choices by the mapped copy; version 1 snapshots retain their previous count-based compatibility path. Mapping metadata remains inside the match's local `presentation` section and is not projected into gameplay or LAN roster data.

The focused regression command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_saved_armies --timeout 300
```

It passed **3/3 processes** (import, Python and `test_saved_armies`) at `.tools/verification/20261113T072801330803Z/results.json` (SHA-256 `6BEB4DB85A2F3D177702FDC87F4E84BF5E09993C38A61A602CD55DB90CE1ADAD`; `network: false`, legacy starter staged). The added regression reverses default and alternate Intercessor copy order, saves and selects that profile through the local New Match flow, checks canonical index bindings and per-copy visual resolution, restores version 2 snapshot data, rejects duplicate match-unit indices, and confirms later source-list equipment/appearance edits do not affect the frozen match. The Godot process reported shutdown RID/ObjectDB cleanup diagnostics and exited successfully. `git diff --check` exited 0 with only Git line-ending normalization warnings. No in-game capture was made; actual rendered visual review, separate-machine LAN validation and full plan acceptance remain open.

### Explicit per-model appearance mode and schema v3 — 13 November 2026

Army Builder profiles now persist Auto/Manual for every miniature using its stable model ID. A saved manual sculpt remains selected when its local files are missing; the normal visual resolver fallback stays visible. Legacy overrides infer Manual and all other legacy models infer Auto on profile normalization. Frozen local appearance snapshots now use schema v3 for model modes and copy bindings; v1 unbound and v2 copy-bound snapshots remain supported.

Static verification with `& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit` exited 0. The production Army Workshop panel was captured in a staged Godot runtime at 1280×800 under `.tools/visual-review/army_builder_visual_mode_capture.png`; it shows a saved Intercessor Grenadier manual appearance, the unavailable-asset explanation and fallback. The fixture uses the local runtime catalog and does not read/write a user profile or model cache. `git diff --check` exited 0 with only the repository's LF/CRLF normalization warnings. No targeted suite was run after this mode/snapshot increment; earlier Intercessor/saved-army results predate this change. Separate-machine LAN and broader plan acceptance remain open.

### Outrider persistent loadouts — 13 November 2026

The Army Builder now saves the Outrider Sergeant's melee replacement and each model's Plasma Pistol choice by stable ID. Current-catalog admission validates the source-listed options and one-per-three cap, groups distinct unit-copy configurations, and preserves stable model references. Local match creation applies the selected weapons before Deployment and blocks duplicate setup changes for saved lists. The preview sends the saved weapon profiles to the local visual matcher; unavailable exact variants retain the normal fallback. Rules facts remain bounded to the verified local Wahapedia e11 Outrider profile documented in [the datasheet audit](../marine-outrider-squad.md).

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_outrider_squad_current --timeout 300
```

It passed **3/3 processes** (import, Python and `test_outrider_squad_current`) at `.tools/verification/20261113T084632291390Z/results.json` (SHA-256 `0530DDEB38EE70C199633C820547AC0C832631F1D029CDE505E39F7F3EDCB012`; `network: false`, legacy starter not staged, no shutdown cleanup diagnostics). The regression covers saved-list admission, per-model canonical choices, stable model mapping, the per-three-model cap, match materialization and blocked setup changes. The actual Army Workshop was captured at 1280×800 in `.tools/visual-review/army_builder_outrider_equipment_capture.png`; the staged list shows the saved Sergeant weapon and model-specific Plasma Pistol, including the disabled state when the unit cap is reached. The capture used the local runtime catalog without reading or writing a user profile or model cache. This does not verify exact sculpt parity, cross-machine LAN, complete army legality or the remaining plan acceptance criteria.

### Ravenwing Darkshroud saved weapon — 13 November 2026

The Army Builder now persists each Darkshroud's Heavy Bolter or Assault Cannon choice against the stable model ID. Canonical admission and stable miniature mapping include the per-copy selection; local saved-list materialization applies the source-listed weapon before Deployment, reports it in readiness and blocks the duplicate Army Preparation change. Missing local equipment-matched assets continue to use the visual fallback.

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_ravenwing_darkshroud --timeout 300
```

It passed **3/3 processes** (import, Python and `test_ravenwing_darkshroud`) at `.tools/verification/20261113T090810306673Z/results.json` (SHA-256 `8A279EFF690B7C10F926D806F3A6957275B528745577D6BF45B8A8A1E15E1773`; `network: false`, legacy starter not staged, no shutdown cleanup diagnostics). In addition to the earlier datasheet checks, the regression covers saved builder admission, canonical equipment projection, stable model mapping, Assault Cannon materialization, the saved-list lock, suppression of duplicate setup choices and gallery explanations for matching/conflicting cannon hints. The actual 1280×800 Godot Army Workshop capture is `.tools/visual-review/army_builder_darkshroud_equipment_capture.png`; it shows the production Unit Inspector with Assault Cannon selected. The capture fixture used the local runtime catalog and did not read or write a user profile or model cache. This does not verify exact sculpt parity, Darkshroud deep strike/Deadly Demise end-to-end behavior, cross-machine LAN, full army legality or the remaining plan acceptance criteria.

### Inceptor per-model saved weapons — 13 November 2026

The Army Builder now stores each Inceptor's Assault Bolters or Plasma Exterminators choice against its stable model ID. Current-catalog admission validates a complete per-model choice array and canonical grouping preserves it. Local saved-list materialization installs each exact source profile before Deployment and suppresses the duplicate Army Preparation choice; standalone exercises retain the setup choice. The preview passes the selected weapon to the local visual matcher, and gallery hints explain matching or conflicting equipment metadata without claiming sculpt certification.

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_inceptor_squad --timeout 300
```

It passed **3/3 processes** (import, Python and `test_inceptor_squad`) at `.tools/verification/20261113T093531737235Z/results.json` (SHA-256 `0D0D7F70231303CE0A214C0659553EC416AF929A8EAEFD4350EC32653825E59E`; `network: false`, legacy starter not staged, no shutdown cleanup diagnostics). The regression checks stable model mapping, invalid loadout rejection, saved model materialization and locking, separate weapon state for models with the same loadout, standalone setup fallback, builder summaries and appearance-hint rationale. The production Army Workshop capture is `.tools/visual-review/army_builder_inceptor_equipment_capture.png` at 1280×800; it shows per-model selections of Plasma Exterminators, Assault Bolters and Plasma Exterminators. Its fixture uses the local runtime catalog and does not read or write a user profile or model cache. This does not establish exact sculpt parity, cross-machine LAN, full army legality or completion of the remaining plan scope.

### Land Speeder saved cannon — 13 November 2026

The Army Builder saves the Land Speeder's Onslaught Gatling Cannon or Pyrecannon against each copy's stable model ID. Local catalog admission preserves differently configured copies, and saved-list matches install the selected weapon before Deployment and suppress the duplicate preparation action. Gallery hints compare the selection with local weapon labels while leaving sculpt suitability unresolved.

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_land_speeder_saved_loadout --timeout 300
```

It passed **3/3 processes** (import, Python and `test_land_speeder_saved_loadout`) at `.tools/verification/20261113T095441032750Z/results.json` (SHA-256 `B9DC202769A761E414A670E7B7A560CE1C0B845E74DF70788CA231BFD18CF365`; `network: false`, legacy starter staged, no shutdown cleanup diagnostics). The regression covers admission and copy separation, stable miniature mapping, appearance-hint rationale, exact weapon materialization, setup suppression and rejection of a forced mid-match change. The production Army Workshop was captured at 1280×800 in `.tools/visual-review/army_builder_land_speeder_equipment_capture.png`; Unit 2 shows Pyrecannon selected. The preview uses the current local fallback and does not certify a matching sculpt. A separate run of `test_land_speeder` reaches its older Purgation fixture and exits because the local Overlord profile is pending validation. This result does not establish full army legality or cross-machine LAN behavior.

### Land Speeder Vengeance saved cannon — 13 November 2026

The Army Builder saves each one-model Vengeance copy's Heavy Bolter or Assault Cannon selection by stable model ID. Admission and canonical grouping preserve unlike copies; saved-list matches install the exact replacement profile before Deployment and suppress the second preparation prompt. The appearance matcher compares local weapon labels without treating them as sculpt certification.

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_land_speeder_vengeance_saved_loadout --timeout 300
```

It passed **3/3 processes** (import, Python and `test_land_speeder_vengeance_saved_loadout`) at `.tools/verification/20261113T100156220705Z/results.json` (SHA-256 `03114F8007A62B87B2016D30B17BEF44B05071769645402E55D0F35342790FE4`; `network: false`, legacy starter staged, no shutdown cleanup diagnostics). The regression checks stable mapping, distinct copy choices, appearance-hint rationale, exact profile materialization, setup suppression and rejection of a forced change. The production 1280×800 Workshop capture is `.tools/visual-review/army_builder_land_speeder_vengeance_capture.png`; Unit 2 shows Assault Cannon selected while the local fallback remains visible. This does not establish exact sculpt parity, full army legality or cross-machine LAN behavior.

### Hellblaster saved Sergeant pistol — 13 November 2026

The Army Builder now saves each Hellblaster Squad copy's Sergeant Bolt Pistol or free Plasma Pistol choice against the stable Sergeant model ID. Local catalog admission preserves differently configured copies, and saved-list matches install the selected profile before Deployment, lock it for the match and suppress the duplicate preparation choice. The match readiness summary reports the saved pistol counts. Equipment hints use local weapon labels and do not certify sculpt parity.

The focused offline command was:

```powershell
python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile targeted --only test_hellblaster_saved_loadout --only test_hellblaster_squad --timeout 300
```

It passed **4/4 processes** (import, Python, `test_hellblaster_saved_loadout` and `test_hellblaster_squad`) at `.tools/verification/20261113T102156369274Z/results.json` (SHA-256 `77DD877A20629487AE4085991BA5CA5D2E3FC2D4CE67824DF39E4BBE9109A71B`; `network: false`, legacy starter staged, no shutdown cleanup diagnostics). The saved-loadout regression covers admission, distinct copy choices, stable model references, readiness reporting, weapon installation, setup suppression and forced-change rejection. The production Army Workshop capture at 1280×800 is `.tools/visual-review/army_builder_hellblaster_equipment_capture.png`; it shows the Unit Inspector's Plasma Pistol choice. The local fallback preview is visible only in part at this scroll position, so the capture verifies the control and selection but not sculpt parity or gallery coverage. Full army legality, cross-machine LAN and the remaining plan scope stay open.

### Assault Intercessor saved Sergeant weapons — 13 November 2026

The Army Builder now stores the Sergeant's source-listed pistol and melee replacement against the stable model ID. Saved-list admission retains distinct combinations across copies, and match construction installs both selected profiles before Deployment while suppressing the duplicate setup choices. The production Army Workshop capture at 1280×800 is `.tools/visual-review/army_builder_assault_intercessor_equipment_capture.png`; Unit 2 shows Hand Flamer and Thunder Hammer selected. This capture verifies the controls and displayed choices, not saved-list admission, match materialization or sculpt parity.

Static Godot project import completed successfully with:

```powershell
& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
```

At the time of this Workshop capture, the saved-list runtime path had not yet had a focused regression run. The later combined local regression is recorded below; this capture itself does not establish match behavior, full army legality, cross-machine LAN or the remaining plan scope.

### Heavy Intercessor saved Heavy Bolters — 13 November 2026

The Army Builder now records Heavy Bolter replacements by eligible non-Sergeant model ID and applies the verified one-per-five limit to each squad copy. Admission carries the per-model choices into saved-list match construction, which installs the local Heavy Bolter profile before Deployment and locks the saved loadout. The production Army Workshop capture at 1280×800 is `.tools/visual-review/army_builder_heavy_intercessor_equipment_capture.png`; it shows the second eligible model's Heavy Bolter selected and the remaining choices disabled at the squad cap. The capture verifies the controls and limit feedback, not saved-list admission or match materialization.

Static Godot project import completed successfully with:

```powershell
& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
```

At the time of this Workshop capture, the saved-list runtime path had not yet had a focused regression run. The later combined local regression is recorded below; this capture itself does not establish match behavior, full army legality, cross-machine LAN or the remaining plan scope.

### Invader ATV saved Multi-meltas — 13 November 2026

The Army Builder now stores each model's Onslaught Gatling Cannon or Multi-melta choice by stable model ID. Each Multi-melta adds the verified 5-point local source cost to the saved-list summary and current-catalog admission; canonical configuration grouping retains distinct model choices. Saved-list match construction applies the chosen profile before Deployment, accounts for its surcharge in match points and locks the duplicate Army Preparation choice. The production Army Workshop capture at 1280×800 is `.tools/visual-review/army_builder_invader_atv_equipment_capture.png`; it shows the two-model control state, the second ATV's checked Multi-melta and a 135/1000-point total. The preview is only the partial local fallback in this capture, so it verifies neither an exact sculpt nor weapon visibility.

Static Godot project import completed with exit code 0 and no script parse errors using:

```powershell
& 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
```

At the time of this Workshop capture, the focused saved-list runtime regression had not yet been run. The later combined local regression is recorded below; this import and capture themselves do not establish admission/materialization behavior, full army legality, cross-machine LAN or the remaining plan scope.

### Saved-list runtime coverage for Scout, Reiver, Invader ATV, Assault and Heavy Intercessors — 13 November 2026

The Army Workshop now has focused local runtime coverage across five saved-list loadout paths. The regression starts from the current consolidated local Space Marines catalog, configures a Scout Sergeant and trooper, two Reiver copies with different squad gear, a mixed two-model Invader ATV unit, two Assault Intercessor Sergeant packages and two Heavy Intercessors with Heavy Bolters. It saves and reopens the army profile, checks the actual Workshop controls reflect the stored choices, validates the list against current local capabilities, and materializes the selections into a match before Deployment. It verifies the Invader ATV 5-point surcharge, per-five-model Heavy Bolter cap, exact weapon IDs and saved-loadout locks.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_saved_loadouts --timeout 300
```

It passed **3/3 processes** (import, Python and `test_marine_saved_loadouts`) at `.tools/verification/20261113T131439856174Z/results.json` (SHA-256 `4BF2B46D391623310539EBAE3237016A5262E73BC4D30003F1D8081A7A114200`; `network: false`, legacy starter staged, no shutdown cleanup diagnostics). This validates only the listed local profiles and match path. It does not establish complete army legality, exact sculpt parity, every option-bearing datasheet or separate-machine LAN behavior.

### Local visual resolution, mesh reuse and saved-loadout regressions — 13 November 2026

The combined local run includes synthetic prepared-GLB coverage and the Army Workshop/import suites. Two separate miniature scene instances share the same cached Mesh resource while retaining distinct scene roots and MeshInstance nodes. The saved-list suite covers the five Marine profiles described above. Local fallback/recovery checks include unavailable manual appearances, corrupt equipment-candidate fallback, failed downloads and invalid OBJ import; separate-machine assets and visual parity are not established.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_models --only test_local_armies_models --only test_marine_saved_loadouts --timeout 300
```

It passed **5/5 processes** (import, Python and the three selected suites) at `.tools/verification/20261113T132357529928Z/results.json` (SHA-256 `0E8B6C9A6732A2874F1935C9FEE74216534048C70515A0E0636EB0200141B0DA`; `network: false`, legacy starter staged). The two local model suites reported headless RID cleanup diagnostics and exited successfully; the saved-loadout suite had no cleanup diagnostics. The targeted corrupt-variant retry regression was added and run separately afterward.

### Corrupt saved-variant retry preserves its assignment — 13 November 2026

The local asset regression now injects an invalid cached OBJ for a manually selectable variant, confirms parsing rejects it, then invokes the explicit retry path. The retry clears the failed in-memory cache and forces a source refresh even though the old file and mapping still exist. A deliberately invalid non-HTTPS source makes the retry fail offline; the saved mapping remains unchanged and the actionable URL error is retained. This verifies retry selection and failure preservation, not successful repair from a replacement source.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_armies_models --timeout 300
```

It passed **3/3 processes** (import, Python and `test_local_armies_models`) at `.tools/verification/20261113T133005563752Z/results.json` (SHA-256 `75159E1D45DBFE6E738A8D19EA1D2AEBBFB5BF4AAF144BD6C8D8428FD727C231`; `network: false`, legacy starter staged). The suite reported headless RID/ObjectDB cleanup diagnostics and exited successfully. The regression does not verify a successful repaired asset, default-mapping recovery, separate-machine asset behavior, visual parity or full army legality.

### Manual sculpt mismatch feedback after equipment changes — 13 November 2026

The Army Builder regression saves a Hellblaster Sergeant's manual Bolt Pistol sculpt, changes its saved equipment to Plasma Pistol, and checks the gallery rationale flags the known equipment conflict without clearing the manual appearance. Restoring Bolt Pistol updates the rationale to a match while retaining the same saved variant identity. The comparison is bounded by local variant metadata and does not certify sculpt parity.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --timeout 300
```

It passed **3/3 processes** (import, Python and `test_army_builder`) at `.tools/verification/20261113T133524846439Z/results.json` (SHA-256 `E2EC8CD459CE2343543DA21CD93BE999136428B02F71030DFD54F544610AC358`; `network: false`, legacy starter not staged). The Godot test process reported headless RID/ObjectDB cleanup diagnostics and exited successfully. Broader model-role combinations, actual sculpt parity, full army legality and separate-machine LAN remain outside this result.

### Responsive appearance workspace — 13 November 2026

At 1280×800, opening a selected entry's Appearance view activates the compact Unit Inspector region. The Appearance tab keeps the live miniature preview and model selector beside the local gallery; candidate looks are placed before optional preparation and palette controls. The screenshot shows the built-in placeholder and a preserved unavailable manual appearance because this isolated fixture links no local asset.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --timeout 300
```

It passed **3/3 processes** (import, Python and `test_army_builder`) at `.tools/verification/20261113T140309689520Z/results.json` (SHA-256 `7C91A908A20828409EE0B126B466E9F04AE35F23FBB8E7A143CD3D9A58CC8968`; `network: false`, legacy starter not staged). The Godot test process reported headless RID/ObjectDB cleanup diagnostics and exited successfully. The actual 1280×800 Godot capture is `.tools/visual-review/army_builder_live_appearance_capture.png`; the staged screenshot uses an isolated list/catalog path and does not read or write the user profile or model cache. Other viewport widths, local sculpt parity, complete army legality and separate-machine LAN remain unverified.

### Take to the Skies movement — 13 November 2026

The focused match-command regression covers the ordinary model/dense-wall blockers and the Take to the Skies bypass, a FLY squad's two-inch movement and Charge limits, Advance declaration before its D6, HOVER's waived reduction, vertical-distance bypass while reaching the default 3-inch floor, and carrying the Charge declaration through target selection into contact placement. It also rejects the declaration for a non-FLY unit without mutating state. The current matching [Wahapedia 11e Core Rules page](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) was checked on 13 November 2026; it identifies the June 2026 rulebook revision and retains the §21.03/§24.17 behavior used here.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_take_to_skies --timeout 300
```

It passed **3/3 processes** (import, Python and `test_take_to_skies`) at `.tools/verification/20261113T141902601227Z/results.json` (SHA-256 `7C809333F4A2922F1B60521250742687DD266391048190B5CD50EB4500D1F3F3`; `network: false`, legacy starter staged, no headless cleanup diagnostics). This is bounded local movement evidence. Upper-floor Charge contact, bounded 3D visibility, Plunging Fire, human playtesting, separate-machine LAN and full army legality remain open.

### MONSTER/VEHICLE model passage — 13 November 2026

The focused offline regression exercises the shared Movement command validator and the supported Purgation Run Normal Move. It verifies friendly and enemy ordinary-model passage during Normal Moves and Advances, blocks other MONSTER/VEHICLE bases, confirms that ordinary models do not gain the enemy-passage exception, and checks Charge boundaries and endpoint overlap. The §17.01 FAQ's friendly-model permission for other move types is also covered. The matching current [Wahapedia 11e Core Rules page](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) was checked on 13 November 2026; it identifies the June 2026 Core Rules revision and states the relevant rules in §§03.01 and 17.01.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_monster_vehicle_passage --timeout 300
```

It passed **3/3 processes** (import, Python and `test_monster_vehicle_passage`) at `.tools/verification/20261113T143554568989Z/results.json` (SHA-256 `15E0E519661AC71FDFB1244A83C62B48FB2350F3322F1DD9294FEC4C928BAF40`; `network: false`, legacy starter staged, no headless cleanup diagnostics). Human playtesting, separate-machine LAN, full army legality, terrain and other move-type edge cases remain outside this focused regression.

### Appearance evidence confidence — 13 November 2026

The local matcher now reports **Strong**, **Partial**, **Role only**, **Unverified** or **Conflict** from applicable saved weapon and reviewed model-role metadata. Weapon coverage is the share of the distinct physical weapon labels in the saved model record that the catalog hints cover. The existing deterministic score remains unchanged for resolver ranking. The Army Builder shows evidence confidence independently from asset availability and preserves saved manual choices when a conflict is reported. These labels describe metadata coverage only; they do not estimate probability or certify sculpt parity.

The exact offline command was:

```powershell
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_equipment_visuals --only test_army_builder --timeout 300
```

It passed **4/4 processes** (import, Python, `test_model_equipment_visuals` and `test_army_builder`) at `.tools/verification/20261113T145252293197Z/results.json` (SHA-256 `ECCF7237C46B999D7AD463B2FE6DAFBB5A1B8FC0E5A5F210091FA16A6E6D2D6A`; `network: false`, legacy starter not staged). The Army Builder test process reported headless RID/ObjectDB cleanup diagnostics and exited successfully. The actual 1280×800 Godot capture is `.tools/visual-review/army_builder_confidence_capture.png`; it uses the consolidated local catalog with a staged missing-asset Intercessor variant whose role metadata conflicts with the saved Grenade Launcher model, so it shows the built-in placeholder alongside the separate readiness and confidence labels. The fixture does not verify a real ForceOrg asset or sculpt parity. Thumbnail cards, broad asset-failure coverage, full army legality and separate-machine LAN remain open.

## Saved army formation transfer for LAN selection — 13 November 2026

Saved Warlord and Leader/Support candidates are now mapped from persistent Army Builder model/copy IDs to bounded canonical match coordinates before a LAN roster submission. The versioned packet contains the admitted gameplay roster and the optional formation declaration; it carries no local profile identifiers, visual variants or local paths. The host still performs current-catalog admission and applies declarations through the same current UnitActions checks used by local saved-army matches. The guest reconstructs the received frozen setup and checks its own roster and formation against the host's accepted snapshot. A legacy raw-roster request remains accepted with no saved formation declaration.

The focused verifier passed **3/3 processes** (`import`, Python and `test_saved_armies`) at `.tools/verification/20261113T152823301057Z/results.json` (SHA-256 `E0252EE78C7B793CA2F75B4809AC29A8BEBC5D5C88D373EE24959E4DDB2AD025`; `network: false`, legacy starter staged). `test_saved_armies` reported headless RID/ObjectDB cleanup diagnostics and exited successfully. The checks cover persistent-ID to canonical-coordinate mapping, packet shape rejection, current rules validation and frozen setup reconstruction. They do not exercise an RPC host/guest session or establish separate-machine LAN behavior; Space Marine network validation remains deferred.

## Baal Predator saved loadout — 13 November 2026

The Army Builder stores all four local source-listed choices per stable Baal Predator model: primary cannon, paired sponson package, Storm Bolter and Hunter-killer Missile. Admission validates values against the current local profile, separates unlike copies, and returns canonical choices. Match setup installs the exact weapon profiles before Deployment and locks the setup command for saved selections. The Workshop regression checks that the controls reopen with saved values. Appearance metadata compares the selected physical weapons to local hints and keeps different loadouts in separate model roles; this is metadata coverage only and does not establish sculpt parity.

The exact offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_baal_predator_saved_loadout --only test_baal_predator --only test_army_builder --timeout 300
```

It passed **5/5 processes** (`import`, Python, `test_baal_predator_saved_loadout`, `test_baal_predator` and `test_army_builder`) at `.tools/verification/20261113T170206645894Z/results.json` (SHA-256 `02DE7F83D861C54C228103A72093836EA35AE6AB26C086F6671353563DC44F0A`; `network: false`, legacy starter staged). `test_army_builder` reported Godot headless RID/ObjectDB cleanup diagnostics and exited successfully; the other four processes had no such diagnostics. Full army legality, separate-machine LAN and exact sculpt parity remain unverified.

## Predator Destructor saved loadout — 13 November 2026

The Army Workshop stores the source-listed paired sponson replacement and both optional weapons per stable Predator Destructor copy. The local current-catalog path keeps unlike copies separate, materializes the complete selected profiles before Deployment and locks the duplicate setup choices. The UI regression checks reopened values and compares equipment hints against local appearance metadata; this does not establish sculpt parity. The sheet remains Warhammer Legends and competitive event use requires organiser permission.

The exact offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_predator_destructor_saved_loadout --timeout 300
```

It passed **3/3 processes** (`import`, Python and `test_predator_destructor_saved_loadout`) at `.tools/verification/20261113T172822142075Z/results.json` (SHA-256 `F46D06EB8129BA00FF9CB685DE8DCCB89ACFAE479FFEE9433C19AA1135C4CE59`; `network: false`, legacy starter staged, no cleanup diagnostics). Full army legality, separate-machine LAN and exact sculpt parity remain unverified. No live Godot capture was produced for this slice.

## Predator Annihilator saved loadout — 13 November 2026

The Workshop stores each stable copy's paired Heavy Bolter replacement, Storm Bolter and Hunter-killer Missile. Current-catalog admission preserves unlike copies; materialization installs exact weapon records and locks duplicate preparation commands. The regression renders controls from an in-memory list, checks local metadata guidance and tests default/fully equipped copies plus forced-change rejection. It does not exercise a disk-save/restart round trip or every option combination. The profile retains its Warhammer Legends scope.

The exact offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_predator_annihilator_saved_loadout --only test_predator_annihilator_legends --timeout 300
```

It passed **4/4 processes** (import, Python and both selected suites) at `.tools/verification/20261113T174036761309Z/results.json` (SHA-256 `82B57E5C31C73044020B1C64E60D507DA100086B0567077A0C7A98EE7019E63D`; network disabled, legacy starter staged, no cleanup diagnostics). This report was re-read and its hash recomputed during the implementation review; tests were not rerun. No new live Godot capture was produced. Full army legality, exact sculpt parity and separate-machine LAN remain unverified.

## Army Builder implementation review — 13 November 2026

The [review](../project/army-builder-implementation-review.md) compares the supplied plan with current ownership, migrated profiles and acceptance gates. It identifies incomplete coverage accounting, repeated profile branches, draft feedback that implies a disk save, and gaps in persistence/integration evidence. Existing focused report hashes were recomputed; no new runtime, rules-source, network or live visual check is claimed by this documentation review.

## Shared equipment adapters, disk restart and Workshop review — 13 November 2026

Predator Destructor and Annihilator now share their control rendering and draft-update callback. Their feedback explicitly says **updated in this draft**. Invictor Tactical Warsuit and Ancient use an explicit shared adapter for defaults, enum validation, editor controls, canonical copy grouping and exact source-listed materialization. Saved choices are locked against duplicate setup changes. The Invictor regression caught and resolved a later initialization step resetting its saved cannon to the default.

The exact focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_invictor_saved_loadout --only test_ancient_saved_loadout --only test_saved_loadout_restart --only test_predator_annihilator_saved_loadout --only test_predator_destructor_saved_loadout --only test_army_builder --timeout 300
```

It passed **8/8 processes** at `.tools/verification/20261113T180012760988Z/results.json` (SHA-256 `A8725368FF5B4DC43E628062FF74FAE45956D861EFAF52CF44A03D300B13CE04`; network disabled, legacy starter staged). `test_army_builder` exited successfully with headless RID/ObjectDB cleanup diagnostics; the other processes did not report those diagnostics.

The new restart test writes an army bank to disk, starts a separate Godot process to reopen it, preserves differently configured copies and a missing appearance reference, saves/reloads a gameplay match and confirms later source-list edits leave the frozen setup unchanged. It exercises actual shared Predator checkbox signals. The new Invictor/Ancient regressions check distinct copy configurations, exact weapon materialization, unsupported-choice rejection, duplicate-prompt suppression, forced-change rejection without mutation and generic editor signals. This remains a bounded local path, not a complete manual readiness/deployment walkthrough or a separate-machine LAN session.

The production Workshop was rendered in a non-headless Godot 4.7.2 run using OpenGL compatibility at 1280x800. The inspected staged capture is `.tools/visual-review/army_builder_invictor_equipment_capture.png`: the Unit inspector shows **Twin Ironhail Autocannon** selected for Unit 1, and **Unsaved changes** beside Save list. The preview is partly outside the scrolled view and uses the local fallback; this capture does not establish a matching Invictor sculpt. An initial capture showed the catalog region and was rejected as equipment evidence; the corrected fixture selected the compact inspector region before capture.

The runtime coverage exporter and renderer produced the [204-profile discovery ledger](../project/army-builder-coverage.md), with 26 profiles containing detected saved equipment schemas. The other 178 require fixed-equipment/option review. Discovery metadata and passing tests do not certify complete loadouts, full army legality, all factions or live-page equality. Existing source audits remain authoritative for the two new migration profiles; no source facts or provenance were replaced.

Standalone preparation and existing source-bounded behavior were also checked with:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_invictor_tactical_warsuit --only test_ancients --timeout 300
```

This passed **4/4 processes** at `.tools/verification/20261113T180520453111Z/results.json` (SHA-256 `5546F1CA58C528AFFC1A60DA409093FCAE10C33F3C8E08511C0B25FBD66714E1`; network disabled, legacy starter staged). Cleanup diagnostic flags: import=false, python=false, test_invictor_tactical_warsuit=false, test_ancients=false. Documentation local-file links, 204 unique ledger identities with runtime book/datasheet IDs and `git diff --check` also passed.

## Optional vehicle saved equipment — 13 November 2026

The shared adapter now saves source-listed vehicle choices per stable one-model copy for Vindicator, Whirlwind, Hammerfall Bunker, Nephilim Jetfighter, Cerberus, Typhon and Falchion. Hammerfall Bunker, Cerberus, Typhon and Falchion remain visibly bounded to their local Legends profiles where applicable. Local canonical admission validates the records, and match preparation applies them after its profile defaults so those defaults cannot reset the saved choices. The focused regression checks two independently configured copies per profile, exact local ranged weapon packages, admission, duplicate setup-choice suppression, editor control signals and rejection of wrong-type values.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_optional_vehicle_saved_loadouts --only test_saved_loadout_restart --timeout 300
```

It passed **4/4 processes** (import, Python, `test_optional_vehicle_saved_loadouts` and `test_saved_loadout_restart`) at `.tools/verification/20261113T194708205511Z/results.json` (SHA-256 `AA3E23D672A45D62116D29B7DDEC64168460ED41D3E8A6A3ABB292C572F36C87`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). The restart regression preserves the previously covered army-bank reopen and frozen-match source-edit isolation. No live Workshop screenshot was produced for these seven profiles; the control-signal exercise is runtime interaction evidence, not viewport evidence. Exact visual parity, every per-option combination, full army legality and separate-machine LAN remain unverified.

## Dreadnought saved equipment — 13 November 2026

The Army Workshop now saves Dreadnought's primary weapon, linked melee/ranged package and Storm Bolter replacement per stable unit copy. It accepts the 12 legal combinations recorded in the local Legends audit and rejects the Heavy Flamer with the Missile Launcher + Crushing Feet package. Venerable Dreadnought (Legends) stores its primary weapon and replacement package, matching all 32 combinations in its source audit. Both local weapon factories supply the exact saved ranged and melee records. Match setup applies them after source defaults and prevents duplicate preparation choices. The restart fixture reopens a configured Dreadnought in a separate Godot process, then saves/reloads the match and verifies that later list edits do not alter frozen setup.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_dreadnought_saved_loadouts --only test_saved_loadout_restart --only test_dreadnought_legends --only test_venerable_dreadnought_legends --timeout 300
```

It passed **6/6 processes** at `.tools/verification/20261113T200236356425Z/results.json` (SHA-256 `C2523931EB2044FE4F49764DF5A47E9DDE84A01CE38F447434F2BF4F20713FFC`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). These checks verify local construction and persistence behavior against the previously recorded source audits; they do not verify competitive event eligibility, sculpt parity, full army legality, separate-machine LAN or human usability. No live Workshop capture was produced for these two controls.

## Aircraft saved equipment — 13 November 2026

Stormhawk Interceptor and Stormtalon Gunship now save their source-listed Legends loadouts per copy through the shared Army Workshop adapter. The check enumerates all six Stormhawk combinations and all four Stormtalon missile selections, then covers current-catalog admission, two differently equipped copies, exact ranged weapon materialization, Workshop controls/signals, duplicate-choice suppression and forced match-preparation edit rejection. The existing source regressions also run in the same focused command.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aircraft_saved_loadouts --only test_stormhawk_interceptor --only test_stormtalon_gunship --timeout 300
```

It passed **5/5 processes** at `.tools/verification/20261113T201409698292Z/results.json` (SHA-256 `FCCC66B747740413B17BC9091FE88BC53A1160A074D037E08A972F0E4EBFE0F9`; network disabled, legacy starter staged, no headless cleanup diagnostics). The rules facts remain bounded by the [Stormhawk](../marine-stormhawk-interceptor.md) and [Stormtalon](../marine-stormtalon-gunship.md) source audits. No visible Workshop capture was produced; sculpt parity, event eligibility, full army legality, separate-machine LAN and human usability remain unverified.

## Space Wolves walker saved equipment — 13 November 2026

Bjorn, the Space Wolves Venerable Dreadnought and Wulfen Dreadnought now save their source-listed choices per stable unit copy. The adapter uses the existing local Space Wolves weapon factory. The regression checks all three Bjorn choices, all eight legal Venerable combinations and all four Wulfen combinations, including the Venerable Great Axe + Blizzard Shield restriction. It also checks current-catalog admission, configured/default copies where repeat limits allow, exact ranged and melee profiles, shield state, Workshop control signals and rejection of duplicate Army Preparation edits. Murderfang remains fixed-equipment and outside this migration. The source authority and hash evidence remain in the [Space Wolves walkers audit](../marine-space-wolves-walkers.md).

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_walker_saved_loadouts --only test_space_wolves_walkers --only test_capabilities --only test_implemented_catalog --timeout 300
```

It passed **6/6 processes** at `.tools/verification/20261113T202939499046Z/results.json` (SHA-256 `C731DD693403671079B4A8354CDAB80CC50151403754E0EFFB0AD134DD8C9305`; network disabled, legacy starter staged). `test_implemented_catalog` reported headless RID/ObjectDB cleanup diagnostics and exited successfully; the other processes did not report them. This is local saved-equipment verification against the existing source audit; full Space Wolves legality, sculpt parity, event eligibility, separate-machine LAN and human usability remain unverified.

## Death Company Dreadnought saved equipment — 13 November 2026

The Army Workshop saves the Twin Heavy Bolter/Twin Multi-melta choice and linked Blood Fists + Bolt Rifles/Blood Talons package per stable copy. The current local catalog admits the selections, and match creation installs their exact ranged/melee weapon records after profile defaults. Saved choices suppress repeat match-preparation prompts. The focused integration regression exercises all four combinations, one configured and one default copy, editor controls/signals, and forced-change rejection; the existing source suite runs beside it.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_dreadnought_saved_loadout --only test_death_company_dreadnought --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T204234432951Z/results.json` (SHA-256 `B99922B14AB239654D53EEC38230420E1B91EB3E01E927F35EAC288DF4E84877`; network disabled, legacy starter staged, no headless cleanup diagnostics). Rules facts remain bounded by the [existing local source audit](../marine-death-company-dreadnought.md). No live Workshop capture was produced; full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Death Company Captain saved equipment — 13 November 2026

Both Death Company Captain profiles now save equipment through the shared Army Workshop adapter. The foot Captain validates its independent pistol and melee selections against all six local factory combinations. The Jump Pack Captain validates its nine complete package choices, installs exact ranged and melee profiles, and carries the Relic Shield wound adjustment into the match. The regression also exercises current-catalog admission, separate configured/default copies, Workshop signals, setup-choice suppression and forced-edit rejection; the existing Blood Angels character scope suite ran alongside it.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_captain_saved_loadouts --only test_blood_angels_characters --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T205339544317Z/results.json` (SHA-256 `9C75B203D7FDF0FC5FBC56EE7F28DE3B42D29FC0287B7C96C9208733322652AB`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Rules facts remain tied to the current profile records from local snapshot `20261021T130623Z`, App book `000000021`, datasheets `000003832` and `000003833`; those facts were not rechecked online in this implementation step. No live Workshop capture was produced; full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Blood Angels Captain saved equipment — 13 November 2026

The shared adapter now saves the Blood Angels Captain's pistol and melee options independently. The check enumerates all six local factory combinations, admits a changed saved profile through the current catalog, materializes the exact weapons before Deployment, blocks duplicate/forged setup edits and exercises the Workshop control. It also reruns the existing source-bounded Blood Angels Captain suite. Construction repeat limits are unchanged; the new integration fixture uses one copy because the runtime capability record does not declare a limit.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_captain_saved_loadouts --only test_blood_angels_captain --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T210522212816Z/results.json` (SHA-256 `4582FAB0CDFEEAF3FA0C34ABBD6672FF8AE636EF16F9BB64F4F361CF6948A634`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Rules evidence remains in the [existing Captain audit](../marine-blood-angels-captain.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Shared Captain saved equipment — 13 November 2026

The shared-book Captain saves its ranged package and melee weapon per stable model copy. The adapter checks all eight selector pairs against the local source factory, permits the seven legal combinations and rejects Relic Shield + Power Fist. The regression carries three differently equipped copies through catalog admission and match preparation, checks exact ranged/melee profiles, the Relic Shield wound adjustment, setup-choice suppression, forged-edit rejection and Workshop control signals. The existing Captain scope suite runs alongside it.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_saved_loadout --only test_captain_current --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T211416516160Z/results.json` (SHA-256 `FD2A703678BEBE0B348B8A42BB3D2741F82494884CB5B98DC7D47736602B5B25`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Source evidence remains in the [Captain audit](../marine-captain.md); it was not refreshed in this implementation step. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Jump Pack Captain saved equipment — 13 November 2026

The shared-book Captain With Jump Pack saves its complete pistol/melee/Relic Shield package per stable copy. The focused regression checks all seven factory options, rejects an unknown package, retains three differently configured copies through admission and match preparation, materializes exact weapon profiles, applies the shield's extra Wound, suppresses duplicate setup choices, rejects forced edits and exercises the Workshop selector. The existing source-bounded Jump Pack Captain suite runs alongside it.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_jump_pack_captain_saved_loadouts --only test_captain_with_jump_pack --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T212035509775Z/results.json` (SHA-256 `FA79BDFBBD4167FB917E69F00BED7EB57D77E3E5539B549A700E424E82809C27`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Source evidence remains in the [existing audit](../marine-captain-with-jump-pack.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Castellan saved equipment — 13 November 2026

The Army Workshop stores the Castellan's ranged and melee replacements independently. The focused regression checks all four choices against the existing local factory, validates catalog admission and exact pre-Deployment materialization, exercises the Workshop controls, confirms setup-choice suppression and rejects a forced setup edit. The existing source-bounded Castellan suite ran alongside it. No repeat-limit change or source refresh was made.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_castellan_saved_loadout --only test_castellan --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T213111485240Z/results.json` (SHA-256 `850D7B25A02A735D81C3A87443D7FCE6B3910CE17D1B19655B523D58D190EE13`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Rules evidence remains in the [Castellan audit](../marine-castellan.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Marshal saved equipment — 13 November 2026

The Army Workshop stores the Marshal's Plasma Pistol/Combi-weapon replacement. The focused regression checks both selections against the current local factory, validates catalog admission and exact pre-Deployment weapon materialization, exercises the Workshop selector, verifies setup-choice suppression and rejects a forced setup edit. It also checks that the Marshal's fixed melee weapon, Wounds and invulnerable save remain intact. The existing source-bounded Marshal suite ran alongside it. Repeat limits and source research were not changed.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marshal_saved_loadout --only test_marshal --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T213858828446Z/results.json` (SHA-256 `D58C3162BCDF6238F2B9DB9BDC0367C72F5E4C4668CFBC4A18D9DE7BD7BBAC26`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Rules evidence remains in the [Marshal audit](../marine-marshal.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Lieutenant saved equipment — 13 November 2026

The Army Workshop persists the shared-book Lieutenant's ranged package, fists replacement and optional Storm Shield. The focused regression matches all 54 selector states against the existing local factory, confirming the 30 allowed combinations and shield restriction. It carries Neo-volkite + Power Fist + Storm Shield through current-catalog admission and match materialization, checks the model-only 4+ save and setup lock, rejects forced edits, and exercises the Workshop's dependent-choice recovery when switching away from Neo-volkite. The existing source-bounded Lieutenant suite ran alongside it.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_lieutenant_saved_loadout --only test_marine_lieutenant --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T215139606770Z/results.json` (SHA-256 `B05CCFF38AAB8E0D3C36789C250CE8EDFB72EE97DB87F1E1331A7555A48AB4A3`; network disabled, legacy starter staged, no headless RID/ObjectDB cleanup diagnostics). Rules evidence remains in the [Lieutenant audit](../marine-lieutenant.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Gravis Captain saved equipment — 13 November 2026

The Army Workshop stores the default rifle/power-weapon package or one of three Boltstorm Gauntlet + relic packages per Captain copy. The focused regression matches all four choices against the existing local weapon factory, validates current-catalog admission, checks distinct saved copies and exact pre-Deployment profiles, exercises the Workshop selector, verifies duplicate setup-choice suppression and rejects a forced match-time edit. The existing Captain source suite ran alongside it. The runtime copy cap and source research were unchanged.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gravis_captain_saved_loadout --only test_gravis_captain --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T220635931429Z/results.json` (SHA-256 `c77e23f2eb76d906197899e3da2a3ecada3cf8ee3e18bf39eb51711c884b1f11`; network disabled, legacy starter staged, no cleanup diagnostics). Rules evidence remains in the [Gravis Captain audit](../marine-captain-gravis.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Terminator Captain saved equipment — 13 November 2026

The Army Workshop stores Storm Bolter/Combi-weapon and Relic Weapon/Relic Fist independently. The regression matches all four combinations against the source-bounded local factory, carries Combi-weapon + Relic Fist through current-catalog admission and exact pre-Deployment materialization, exercises both Workshop selectors, suppresses duplicate setup choices and rejects a forced edit. The existing Terminator Captain source suite and Gravis Captain regressions ran alongside it. Copy limits and source research were unchanged.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_captain_saved_loadout --only test_terminator_captain --only test_gravis_captain_saved_loadout --only test_gravis_captain --timeout 300
```

It passed **6/6 processes** at `.tools/verification/20261113T220958671134Z/results.json` (SHA-256 `f06118a29efc7de9635a0993f36598b41dfffd5e49d5ce56f60c696aa8d0ea87`; network disabled, legacy starter staged, no cleanup diagnostics). Rules evidence remains in the [Terminator Captain audit](../marine-terminator-captain.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Captain on Bike saved equipment — 13 November 2026

The Army Workshop stores the Heavy Bolt Pistol/Plasma Pistol and Master-crafted Power Weapon/Thunder Hammer replacements independently. The focused regression matches all four combinations against the existing local factory, validates three distinct copies through current-catalog admission and pre-Deployment materialization, exercises the Workshop controls, suppresses duplicate setup choices and rejects a forced edit. The existing Captain on Bike source suite ran alongside it. Source-audited copy limits and the placement proxy were unchanged.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_on_bike_saved_loadout --only test_captain_on_bike --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T222107234427Z/results.json` (SHA-256 `9e2edec24d46dad244b28c3491d9b5435eaea3d4a664ba97b57ac7f64636bb83`; network disabled, legacy starter staged, no cleanup diagnostics). Rules evidence remains in the [Captain on Bike audit](../marine-captain-on-bike.md); this implementation did not refresh source research. Full army legality, exact oval placement, sculpt parity, separate-machine LAN and human usability remain unverified.

## Brutalis saved equipment — 13 November 2026

The Army Workshop stores the Brutalis Talons linked replacement and Twin Multi-melta option independently. The focused regression matches all four combinations against the local profile factory, validates three separate copies in current-catalog admission, checks exact pre-Deployment weapon arrays and Workshop signals, suppresses duplicate setup choices and rejects a forced edit. The existing Brutalis Dreadnought scope suite ran alongside it. The three-copy cap and local source audit were unchanged.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_brutalis_saved_loadout --only test_brutalis_dreadnought --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T222746142741Z/results.json` (SHA-256 `e28b123efcc6b1c105d6694cf86a8e63bb017b2d2634ff71bc9507c637d22dd7`; network disabled, legacy starter staged, no cleanup diagnostics). Rules evidence remains in the [Brutalis audit](../marine-brutalis-dreadnought.md); this implementation did not refresh source research. Full army legality, sculpt parity, separate-machine LAN and human usability remain unverified.

## Sanguinary Guard saved equipment — 13 November 2026

The saved roster now stores the Angelus Boltgun/Inferno Pistol choice per stable model identity. Local admission limits Inferno Pistols to one per three models and rejects malformed or over-limit saved arrays. Two differently configured 3-model copies remain distinct through canonical admission and match preparation; exact local weapons are materialized before Deployment and the duplicate Army Preparation choice is suppressed/guarded. The separate-process restart fixture reopens both per-model configurations from disk and includes them in a frozen match snapshot. This uses the existing verified local Guard audit and did not refresh source research.

The focused verifier command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sanguinary_guard_saved_loadouts --only test_saved_loadout_restart --only test_sanguinary_guard --only test_implemented_catalog --timeout 420
```

It passed **6/6 processes** at `.tools/verification/20261113T230628813613Z/results.json` (SHA-256 `A5F371EC6DFEB2AD368102E251200BEA970DBFE35EC491F7CC27E1D7C11A7F2B`; `network: false`, legacy starter staged). `test_implemented_catalog` reported headless RID/ObjectDB cleanup diagnostics but exited successfully; the other processes had none. This verifies the bounded saved-equipment/disk-restart/admission/materialization and control path. It does not certify full army legality, all Leader interactions, exact sculpt parity, event eligibility, separate-machine LAN or human usability. A live Workshop capture was not obtained in this pass: the launched Godot debug windows remained on the splash screen.

## Death Company Marines saved equipment — 13 November 2026

The Army Workshop now saves each Death Company Marine's melee and pistol package by stable model identity. The foot squad also saves the optional Grenade Launcher for a Bolt Rifle carrier; Jump Pack records omit that foot-only field. Both schemas call the already source-bounded local 11e validators, which enforce the distinct 5/10-model quotas and exact weapon packages. Current-catalog admission rejects malformed/over-limit records. Match setup installs each model's exact ranged and melee profile, suppresses the repeated Army Preparation choices and rejects forced edits. Separate foot and Jump Pack copies retain independent loadouts.

The verifier command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_saved_loadouts --only test_saved_loadout_restart --only test_death_company_marines --only test_implemented_catalog --only test_capabilities --timeout 420
```

It passed **7/7 processes** at `.tools/verification/20261113T232937800828Z/results.json` (SHA-256 `E9F26CC0BAE900B43F7B97F02F88284FBACF5745243CEDAF867D5FC48176D974`; `network: false`, legacy starter staged). The catalog process reported headless RID/ObjectDB cleanup diagnostics and exited successfully; the other processes had none. The restart fixture reopened five mixed army entries in a separate Godot process, checked per-model Guard and both Death Company schemas, then verified that the match snapshot stayed frozen after a later source-list edit. This confirms the bounded local equipment/admission/materialization path against the previously recorded source audit; no source refresh was performed. Full army legality, exact sculpt parity, separate-machine LAN and human usability remain open.

## Tarantula Sentry Battery saved equipment — 13 November 2026

The saved Army Workshop stores the Twin Heavy Bolter/Twin Lascannon choice for each stable model ID in 1/2/3-model Tarantula copies. Admission and preparation validate against the existing verified local Legends weapon factory. Saved matches materialize each model's exact ranged profile and suppress/guard the duplicate match-time selection. Per-model choices remain independent inside and across copies; prices, copy caps, Sentinel Protocols and the Legends boundary are unchanged.

The focused verifier command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tarantula_sentry_saved_loadouts --only test_saved_loadout_restart --only test_tarantula_sentry_battery --only test_implemented_catalog --only test_capabilities --timeout 420
```

It passed **7/7 processes** at `.tools/verification/20261113T234712498861Z/results.json` (SHA-256 `D827792456ADF81ABD3BD64649146C94DC1E61C7A2BF31B2C81F83826561FB3C`; `network: false`, legacy starter staged). The catalog process reported headless RID/ObjectDB cleanup diagnostics and exited successfully; the other processes had none. The restart fixture reopened six mixed entries in a separate Godot process—including Sanguinary Guard, both Death Company datasheets and three Tarantula copies—and checked that the match snapshot remained frozen after a later army-list edit. This verifies the bounded local equipment, admission and materialization path against the existing source audit; no research refresh was performed. The local footprint proxy, event eligibility, full army legality, separate-machine LAN and human usability remain unverified.

## Rhino saved Hunter-killer Missile — 13 November 2026

The standard Rhino's already-audited no-cost Hunter-killer Missile now persists per vehicle copy in the saved army. Admission validates the typed field, the shared adapter materializes the existing local weapon profile (including One Shot), and saved matches suppress and reject duplicate match-preparation edits. The focused regression checks the Workshop control signal and unsaved-draft notice, independent equipped/unequipped copies for both players, exact weapon inventory, and the setup lock. The shared restart fixture reopens a mixed seven-entry army in a separate Godot process and verifies that later Rhino list edits do not alter the frozen match snapshot.

The exact command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_rhino_saved_loadout --only test_saved_loadout_restart --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261114T014351768636Z/results.json` (SHA-256 `E1C2DA74014092C7B262C3B12D09DB1EE880E625348F6D6980A84E3E5F45A207`; network disabled, no legacy starter staged, no cleanup diagnostics). The implementation reused the existing Rhino source audit and local profile; no rules-source refresh or network check was run. A live Workshop capture was not obtained. This verifies the bounded saved-option path only; full Rhino rules, full army legality, exact sculpt parity, separate-machine LAN and human usability remain open.

## 14 November — mixed Space Wolves saved equipment

Wolf Scouts and Wolf Guard Headtakers saved role equipment, caps, stable restart, frozen locks, native controls and role-aware appearance filtering passed with source/specialist/visual/catalog regressions: 8/8 processes at `.tools/verification/20261114T153240545996Z/results.json` (SHA-256 `6bf1dbecc4a0e808eb38cfa603a8dffcc6d51c5101c6cef707f827138b6684f4`). Catalog shutdown cleanup diagnostics remain recorded. Initial 2/5 failures, corrections, six Python ledger checks and actual Godot captures are documented in the [bounded audit](mixed-space-wolves-saved-equipment.md). Network disabled; no expanded army-legality/platform claim.

## 14 November — saved Sergeant/Pack Leader squad equipment

Assault Intercessors with Jump Packs, Blood Claws and Grey Hunters now persist source-listed role equipment and omit repeat setup. The initial batch passed all three existing source suites but failed the new test due to its inferred-type declaration; correcting the test produced a direct pass. Final related regression passed 6/6 at `.tools/verification/20261114T154547437952Z/results.json` (SHA-256 `b0aec5dddf196385e28184fa07c6cc5f632240d26b60276a574799e933a6c0ae`), with catalog cleanup diagnostics. Six Python ledger tests passed. See [exact commands, initial report, exhaustive matrix and real Godot captures](sergeant-squad-saved-equipment.md). Network disabled; existing construction gates preserved.

## 14 November — saved specialist squad equipment

Eradicators with Melta Rifles, Desolation Squad and Sternguard Veterans now save role equipment, caps and Vengor prices before Deployment. Main/source checks passed 6/6 at `.tools/verification/20261114T155637759613Z/results.json` (SHA-256 `320b2dc0ac0ac05118f8b095cbb4a310f34835227555050bd0653f5472e366c2`); shared regression passed 5/5 at `.tools/verification/20261114T155932553033Z/results.json` (SHA-256 `202199447f92a0a1dc5ddf8d667126ac7208ea129c8cff558c1994642a205b3a`). Desolation/catalog cleanup diagnostics are recorded. Six Python ledger checks passed. The 59,607-distribution matrix, Eradicator Sergeant eligibility correction and six actual Godot captures are documented in the [bounded audit](specialist-squad-saved-equipment.md). Network disabled; existing construction gates retained.

## 14 November — saved Terminator equipment

Standard, Assault and Wolf Guard Terminators now persist role equipment, shared special caps, Cyclone prices/retained bolters and shield bearer Wounds before Deployment. Main/source regression passed 6/6 at `.tools/verification/20261114T160934262857Z/results.json` (SHA-256 `8b574d9b96b2f540ca8d840fa92a92459cd5bc8ba3039bc04ceeb07bcab746a9`, no headless cleanup diagnostics). Shared-command/visual/catalog regression passed 6/6 at `.tools/verification/20261114T161217173205Z/results.json` (SHA-256 `89479cda2b55f94dfd527665ff3bdedb8b20c25c6bc15f992310a3d41ec9e8df`); diagnostics are detailed in the [bounded audit](terminator-saved-equipment.md), alongside matrix scope, six Python checks and actual Godot captures. Network disabled; no expanded army-legality/platform claim.

## 14 November — separate Deathwing unit/model equipment

Deathwing Terminators and Knights now save model weapons alongside one free Watcher per stable unit copy. Canonical keys preserve different Watchers on otherwise identical models; triggered Watcher activation remains live. Catalog repricing now retains unit maps, including Reiver gear. Initial source checks passed but the new test used an incorrect method name (1/6 processes failed). After correcting it, the final shared regression passed 7/7 at `.tools/verification/20261114T163040946949Z/results.json` (SHA-256 `58f079d4a8ebf6f046c34bca4b11e9df8ba7634ca29d05113b3645ed9cc53b6e`; cleanup diagnostics: test_army_builder, test_implemented_catalog). Six Python ledger tests passed. See [exact commands, initial report, unit/copy evidence and four actual Godot captures](deathwing-saved-equipment.md). Network disabled; broader legacy/integration/platform claims remain open.

## 15 November — Deathwatch saved equipment and Workshop layout

Deathwatch Veterans and Terminators now save source-listed per-model equipment with role restrictions, whole-squad caps, Storm Shield/Cyclone pricing and frozen match setup. The dense Terminator controls now render in model cards after the 1280×800 capture exposed vertical name wrapping in the prior flat rows; both Deathwatch profiles were inspected in actual Godot Compatibility captures at the same viewport.

The final targeted regression passed 11/11 verifier processes at `.tools/verification/20261115T053213457489Z/results.json` (SHA-256 `e131b4e8074b58d3ced58c74dddb10fe6152c39672e241431b818a5072f89fe7`). The `test_army_builder` process reported 15 dummy Texture, 4 ShapedTextDataAdvanced, 2 FontAdvanced and 5 CanvasItem RID allocations plus 82 ObjectDB instances at shutdown; `test_implemented_catalog` reported 12 dummy Texture, 2 FontAdvanced and 2 CanvasItem RIDs plus 58 ObjectDB instances. Both exited successfully; the other nine processes reported no cleanup diagnostics. Network was disabled and the verifier staged its legacy starter. See [source facts, command, capture locations and scope limits](deathwatch-saved-equipment.md). The refreshed ledger contains 213 admitted profiles, 105 detected schemas (46 reviewed), 75 accepted fixed reviews, 12 migration-required profiles, 12 stale reviews, 9 unclassified profiles and 59 detected schemas still needing source-option completeness review.


## 15 November — Scout Bike saved equipment

The Army Workshop now saves each Scout Biker’s free Twin Boltgun/Grenade Launcher replacement and the Sergeant’s free Bolt Pistol replacement by stable model/copy. The local Warhammer Legends source permits the launcher on any number of models and lists eleven Sergeant alternatives. Sizes, 75/150-point prices, first/second/third-plus tiers and existing Incursion/Strike Force copy caps remain unchanged. Saved loadouts pass current local catalog admission, materialize exact factory weapons for both players and suppress/reject the duplicate setup actions. A separate process reopens all records; Workshop signals and six saved model cards were inspected in actual 1280×800 Godot captures.

The offline command passed 8/8 verifier processes at `.tools/verification/20261115T072732806232Z/results.json` (SHA-256 `8ca24610a4a3a83ac308396a9261f291a2798ea1cb7d600c282aa9f1f9ee9823`; network disabled, legacy starter staged). Army Builder and implemented-catalog suites exited successfully with shutdown RID/ObjectDB cleanup diagnostics; four other selected suites reported none. The source-only 28-subject Legends audit passed its structural check but reports no runtime/playable certification. The screenshot process exited 0 with texture/ObjectDB cleanup messages. Existing audit JSON per-file hashes differ from the filtered raw hashes in the current slice; the migration review is bound to the slice manifest and parent manifest separately. At that Scout Bike checkpoint the ledger contained 110 schemas (51 reviewed) and 7 option migrations pending. See [source provenance, command, captures and certification limits](scout-bike-saved-equipment.md). Full army legality, event approval, sculpt parity, separate-machine LAN and remaining plan acceptance gates remain open.

## 15 November — Sword Brethren saved equipment

The Army Workshop now saves one of the ten source-backed complete weapon packages per Sword Brethren model and unit copy. Whole-copy validation applies the Hand Flamer, Plasma Pistol, Thunder Hammer and Twin Lightning Claws limits independently per four models. Local catalog admission materializes exact existing factory weapons for both players, persists distinct configurations across three copies and rejects duplicate match-preparation edits. The 4/5/9/10-model source prices and copy tiers remain unchanged, with no equipment surcharge; unpriced 6–8-model sizes stay blocked. The saved-equipment test also reopens the list in a separate process and exercises real Workshop controls/signals. Actual Godot Compatibility captures cover four- and ten-model cards at 1280×800.

The selected offline batch passed **8/10 verifier processes** at `.tools/verification/20261115T161551369141Z/results.json` (SHA-256 `0fed4a7bed241ca093b2a93ba0cda20dce31f55f019b9321271f9109239df506`; network disabled, legacy starter staged). The Sword Brethren saved-equipment and existing rules suites, Scout Bike suites, catalog and model-visual suites passed. Two adjacent checks failed: the Leader-link suite found a missing Orikan Necron Support target; the Army Builder suite found that its automatic-appearance fixture selected the same sculpt for separate unit copies. The latter and the catalog process emitted shutdown RID/ObjectDB diagnostics. See [source hashes, exact command, capture paths and limitations](sword-brethren-saved-equipment.md). These results do not close plan-wide integration, usability, network or army-legality gates.

## 15 November — Indomitor Kill Team saved equipment

Indomitor now saves the Aggressor Auto Boltstorm replacement, one Eradicator Multi-melta and up to two Heavy Intercessor Heavy Bolters by stable model and copy. Role-shaped defaults preserve the source's 3/3/4 composition; local validation enforces role eligibility and whole-unit caps. The unchanged copy prices are 280 points for copies one/two and 300 from the third; equipment adds no points. Prepared matches materialize exact local factory weapons and suppress/reject duplicate setup edits. Actual 1280×800 Compatibility captures show the three role-specific controls.

The final offline command passed **7/7 verifier processes** at `.tools/verification/20261115T174004175092Z/results.json` (SHA-256 `c225cbd28d4ceec6dcdfdaaa2309beb7cde2a81acf9211d0210541323f0a05b6`; network disabled; legacy starter staged). It included the new saved-equipment regression, existing Indomitor rules suite, Army Builder, implemented catalog and model visuals. The Army Builder process reported 15 dummy textures, 4 shaped-text RIDs, 2 advanced-font RIDs, 5 CanvasItem RIDs and 82 ObjectDB instances at shutdown; implemented catalog reported 12 dummy textures, 2 advanced-font RIDs, 2 CanvasItem RIDs and 58 ObjectDB instances. Both passed. Capture runs exited 0 and reported 19 GLES texture RIDs, 2 advanced-font RIDs, 2 CanvasItems and 47 ObjectDB instances at shutdown. Network was disabled. See [source tables, reproducible command, capture hashes and scope limits](indomitor-saved-equipment.md). This closes only the saved-equipment migration for this profile; full Deathwatch/army rules, smaller-window usability, network and plan-wide acceptance remain open.

## 15 November — Crusader Squad saved equipment

The Army Workshop persists the local source-listed choices by stable model and copy: Sword Brother Hand Flamer, Neophyte Shotgun plus Combat Knife, Initiate Heavy Bolt Pistol plus Chainsword, and the combined Initiate Power Fist/Pyreblaster replacements. Validation allows at most two combined special Initiates per ten models. Equipment adds no points; runtime catalog values remain Wahapedia's 160/305, while MFM v1.0 lists 150/290. Match materialization uses the existing local factory and rejects duplicate preparation edits. Separate-process reopen, both-player materialization, match locks and actual 1280×800 Compatibility captures were reviewed.

The offline targeted command passed **8/8 verifier processes** at `.tools/verification/20261115T175549767382Z/results.json` (SHA-256 `582693809ea0c36345c022ba570c9eec603e78f5bc1ea246bcab10e7a947fe2d`; network disabled; legacy starter staged). Army Builder and catalog shutdown cleanup diagnostics were recorded; they exited successfully. See [local source hashes, exact command, capture hashes and limits](crusader-saved-equipment.md). This completes only Crusader's saved-equipment migration; its bounded movement/formation support, event-cost certification and plan-wide acceptance remain open.

## 15 November — Decimus Kill Team saved equipment

The final focused offline run passed **8/8 verifier processes** at `.tools/verification/20261115T185617124231Z/results.json` (SHA-256 `56e8ddd0004575e9d3b2b65f93012dfa1169ed1e31287a68e6cfc7df0a2046aa`; network disabled; legacy starter staged). Army Builder and implemented-catalog shutdown cleanup diagnostics were recorded; both suites exited successfully. Actual 1280×800 Compatibility captures and the complete bounded implementation are documented in [the Decimus evidence](decimus-saved-equipment.md). A separate wider adjacent attempt and its unrelated `test_marine_category_copy_limits` failure remain noted in that evidence and are not represented as part of this passing final batch. Decimus' five-model composition and Wahapedia/MFM cost discrepancy, full army legality, and plan-wide gates remain open.

## 15 November — Fortis Kill Team saved equipment

The offline targeted batch passed **10/10 verifier processes** at `.tools/verification/20261115T192549640335Z/results.json` (SHA-256 `03605ca4a13a852dafbd30e7bbe95171f04057f866b86a7b1d9c77c19beb6140`; network disabled; legacy starter staged). It included Fortis saved equipment and rules, Apothecary attachment, Army Builder, catalog, model visuals, saved armies and match save. Army Builder, catalog, saved-army and match-save processes emitted headless RID/ObjectDB cleanup diagnostics but exited successfully; six processes reported none. See [source hashes, exact command, actual capture hashes and limits](fortis-saved-equipment.md). This closes only Fortis' saved-equipment migration. At that checkpoint, Spectrus and Talonstrike were still queued; later sections record both completions. Rules certification, full army legality and plan-wide integration/user-review gates remain open.

## 15 November — Spectrus Kill Team saved equipment

The final offline batch passed **10/10 verifier processes** at `.tools/verification/20261115T195957153558Z/results.json` (SHA-256 `8eb0ccd2f6a71c6fa56b8ac74ebff4fc3b5c271683d6cd8a4bc3e7288089c539`; network disabled; legacy starter staged). It included saved-equipment and existing Spectrus rules suites, Apothecary attachment, Army Builder, catalog, model-visual, saved-army and match-save checks. Army Builder, catalog, saved-army and match-save processes emitted headless cleanup diagnostics at shutdown but exited successfully; the other six reported none. See [source hashes, persistence/materialization scope, actual capture hashes and limits](spectrus-saved-equipment.md). This closes only Spectrus saved equipment; full rules/army certification, 59 saved-schema option-completeness reviews and plan-wide integration remain open. At the Spectrus checkpoint, Talonstrike was the sole no-schema option migration; the following Talonstrike entry records its completion.

A separate 15 November leader-link inventory batch passed import/Python but failed the `test_space_marine_leader_links` suite at `.tools/verification/20261115T195846562216Z/results.json` (SHA-256 `abdc6fec673e93c90823994fb03848bc0826372c93b88605797bbac269260b6c`; network disabled; legacy starter not staged). It reports five Necron Support-target cross-map assertions for Orikan, Plasmancer, Technomancer, Psychomancer and Chronomancer. Spectrus's target-specific Phobos Lieutenant Leader assertion passed after the test reflected its dual Support/Leader relationships; the broader Necron findings are not counted as passed and remain outside this migration.

## 15 November — Talonstrike Kill Team saved equipment

The final offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_talonstrike_saved_equipment --only test_talonstrike_kill_team --timeout 900
```

It passed **4/4 verifier processes** at `.tools/verification/20261115T205105179047Z/results.json` (SHA-256 `26ed5a8ac4c81ae7c1a13154532c1a17224a1792759d6d2b6974b6ff07b80c36`; network disabled; legacy starter staged; no headless RID/ObjectDB cleanup diagnostics). The new saved-equipment regression verifies role-scoped records, the one-per-five Plasma Pistol allowance, uncapped Heavy Intercessor replacements, separate-process reopen, both-player materialization, match-lock enforcement, Workshop controls and frozen-snapshot isolation from later saved-army edits. The existing Talonstrike rules regression passed. Actual windowed Godot Compatibility captures are recorded with hashes in the [Talonstrike evidence](talonstrike-saved-equipment.md).

## 15 November — Aggressor Squad source-option completeness review

The selected local export has one equipment-option row: every model may replace Flamestorm Gauntlets with the paired Auto Boltstorm Gauntlets and Fragstorm Grenade Launcher. The existing stable per-model field covers that entire option; Twin Power Fists remain fixed. Source composition and 90/180-point 3/6-model rows remain unchanged. All five relevant raw CSV hashes match the verified-against export manifest. No runtime behavior changed and no test run was needed for this source-classification update. The current ledger advances to 59 of 117 detected schemas explicitly reviewed, with 58 remaining; zero option-bearing profiles lack a saved schema. This is equipment-option completeness only. See the [source hashes and field mapping](aggressor-saved-equipment-source-review.md).

## 15 November — Ancient source-option completeness review

The verified local export's only option replaces the Ancient's Bolt Rifle with a Power Weapon. The existing saved-model field covers the choice; fixed Bolt Pistol and Ceramite Fists, one-model composition and 40-point cost are unchanged. Relevant raw CSV hashes match the export manifest. No runtime behavior changed and this source-classification update did not rerun the existing saved-equipment regression. The current ledger advances to 60 of 117 detected schemas explicitly reviewed, with 57 remaining; zero option-bearing profiles lack a saved schema. This is equipment-option completeness only. See the [source hashes and field mapping](ancient-saved-equipment-source-review.md).

## Local saved-match interruption — 15 November 2026

After list admission and any optional visual preflight, local saved matches now write a recovery checkpoint immediately upon match creation. The focused regression exercises the actual saved Aggressor lists for both players, distinct per-model loadouts and local appearance overrides, checkpoint creation before the first Deployment command, source-list edits after creation, both players' match-specific setup completion, one committed Deployment unit, and restart through `_load_match()` in a separate Godot process. The resumed state and local appearance snapshot must match the checkpoint byte-for-structure while retaining both frozen model loadouts.

The final offline targeted command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_match_interruption --only test_saved_armies --only test_match_save --timeout 900
```

It passed **5/5 verifier processes** at `.tools/verification/20261115T212618627007Z/results.json` (SHA-256 `609571d570fb3a3620eadbfd7c0c8cb364888cd9632a0c43cd712353dadef09a`; network disabled; legacy starter staged). The interruption, saved-army and match-save Godot processes each reported headless RID/ObjectDB cleanup diagnostics at shutdown and exited successfully. This closes only the bounded local saved-match interruption path. Mission-dependent restart, asset-job interruption, broader failure recovery, separate-machine LAN with unequal asset caches, and human review remain open.

## Captain on Bike saved-schema source review — 15 November 2026

The verified local Wahapedia 11e export lists exactly two equipment-option rows for Space Marines App datasheet `000002702`: Heavy Bolt Pistol to Plasma Pistol and Master-crafted Power Weapon to Thunder Hammer. The existing stable-model schema covers them with independent fields; this source-only review does not alter runtime behavior or claim complete datasheet/rules coverage. See the [source audit](captain-on-bike-saved-equipment-source-review.md) for the selected snapshot identity, manifest hash and relevant raw-table hashes.

After adding the review to the registry and rendering the coverage ledger, the Python verification command `python -m unittest discover -s tests -p test_army_builder_coverage.py` passed **6/6 checks**. The current ledger reports 61 of 117 saved schemas source-option reviewed, with 56 remaining; 12 records are stale and 9 profiles remain unclassified.

## Saved-schema option completeness batch — 15 November 2026

The selected verified local Wahapedia 11e export was checked for every equipment-option row on Assault Intercessor Squad, Baal Predator, Blood Angels Captain, Captain in Terminator Armour and Invader ATVs. Each existing stable-model schema covers all listed groups, including the per-model Invader ATV replacement. The source hashes, exact options and field mappings are recorded in the [review batch](saved-schema-source-review-2026-11-15.md). This audit changed only the project source-review registry and generated coverage ledger; no gameplay behavior changed.

The registry was rendered from `.tools/army-builder-coverage.json`. `python -m unittest discover -s tests -p test_army_builder_coverage.py` passed **6/6 checks**. The updated ledger reports 66 of 117 saved schemas source-option reviewed; 51 remain. No schema-less option migration is pending. This source review does not certify runtime behavior or full army legality.

## Saved-profile source review regressions — 15 November 2026

After the five-profile source-option audit, the matching local profile suites passed for Assault Intercessor Squad, Baal Predator, Blood Angels Captain, Captain in Terminator Armour and Invader ATVs. The offline targeted command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_assault_intercessor_current --only test_baal_predator_saved_loadout --only test_blood_angels_captain --only test_terminator_captain_saved_loadout --only test_invader_atvs --timeout 900
```

It passed **7/7 verifier processes** at `.tools/verification/20261115T214243711099Z/results.json` (SHA-256 `c1eb52962fe2bd6b2491305419700031d6a7ec6c023173588d7d6a0c45a77b79`; network disabled; legacy starter staged; no headless cleanup diagnostics). The source audit remains limited to equipment-option completeness and does not establish full army legality.
## Saved-schema review regression follow-up — 15 November 2026

Five additional profile suites passed after the second source-review group: Captain in Gravis Armour, Heavy Intercessor Squad, Hellblaster Squad, Inceptor Squad and Invictor Tactical Warsuit.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gravis_captain_saved_loadout --only test_heavy_intercessor_current --only test_hellblaster_saved_loadout --only test_inceptor_squad --only test_invictor_saved_loadout --timeout 900
```

The final batch passed **7/7 verifier processes** at `.tools/verification/20261115T215159540861Z/results.json` (SHA-256 `f6ff13273f3c104b9767ba24546f65ab5c04caa98d47e93b1e55fa47816f8bfc`; network disabled; legacy starter staged; no cleanup diagnostics). An earlier run at `.tools/verification/20261115T214836148493Z/results.json` failed the Inceptor suite on an outdated assertion expecting generic “miniature” phrasing; it was updated to match the current model-specific rationale and the final batch passed. No Inceptor equipment matching logic changed.

This source-review increment advances the ledger to 71 of 117 saved schemas reviewed for option completeness, leaving 46. Twelve reviews remain stale and nine profiles unclassified. No schema-less equipment-option migration is pending.

## <a id="vehicle-saved-schema-review-regression-follow-up-2026-11-15"></a>Vehicle saved-schema review regression follow-up: 15 November 2026

The local saved-equipment regressions passed for Hammerfall Bunker, Land Speeder, Land Speeder Vengeance, Rhino and Rhino Primaris. These tests check the existing option fields and saved-loadout paths; the separate source audit is limited to option-row completeness.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_optional_vehicle_saved_loadouts --only test_land_speeder_saved_loadout --only test_land_speeder_vengeance_saved_loadout --only test_rhino_saved_loadout --timeout 900
```

The run passed **6/6 verifier processes** at `.tools/verification/20261115T215907499156Z/results.json` (SHA-256 `4431e2611c8f7bcac753280b9e4a41535734cbe6a6e5140d26b1aa405e6f90d0`; network disabled; legacy starter staged; no cleanup diagnostics). The current ledger now reports 76 of 117 schemas reviewed for option completeness, with 41 remaining; 12 reviews are stale and 9 profiles unclassified. The no-schema option migration queue remains empty. This review does not certify full datasheet rules, event approval for Legends profiles, or whole-army legality.

## <a id="matched-source-schema-review-regression-2026-11-15"></a>Matched-source schema review regression: 15 November 2026

The offline batch exercised the Annihilation Barge, Canoptek Tomb Crawlers, Immortals, Marshal and Nephilim Jetfighter. The shared saved-vehicle test also covered the existing Marshal and Nephilim equipment fields. Only Marshal and Nephilim were added to the source-review registry: their verified-against snapshot matches this review. The three Necron records bind to a different local snapshot whose manifest is unavailable; the earlier export was not substituted.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_annihilation_barge --only test_necron_tomb_crawlers --only test_necron_immortals --only test_marshal_saved_loadout --only test_optional_vehicle_saved_loadouts --only test_nephilim_jetfighter --timeout 900
```

The run passed **8/8 verifier processes** at `.tools/verification/20261115T220904984618Z/results.json` (SHA-256 `49ed3b5498bbd01753e43ffd823c1c2138f67e53e484e5c7c7dcf44a4676a290`; network disabled; legacy starter staged; no cleanup diagnostics). The matched-provenance source reviews advance the ledger to 78/117, with 39 option-completeness reviews still pending. Twelve reviews remain stale and nine profiles unclassified. This batch does not certify the three deferred Necron option schemas, complete datasheet rules, or whole-army legality.

## <a id="aircraft-squad-saved-schema-review-regression-2026-11-15"></a>Aircraft and squad saved-schema review regression: 15 November 2026

The saved-schema regressions passed for Ravenwing Darkshroud, Sanguinary Guard, Stormhawk Interceptor, Stormtalon Gunship and Tarantula Sentry Battery.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_ravenwing_darkshroud --only test_sanguinary_guard_saved_loadouts --only test_aircraft_saved_loadouts --only test_tarantula_sentry_saved_loadouts --timeout 900
```

The run passed **6/6 verifier processes** at `.tools/verification/20261115T222430600096Z/results.json` (SHA-256 `decac9c9291b6d41737838ad1469b0bb1dc39f2270f4a6371aa2f5d6c3803424`; network disabled; legacy starter staged; no cleanup diagnostics). The source ledger now reports 83/117 schemas reviewed for option completeness, leaving 34; 12 reviews remain stale and 9 profiles unclassified. Three Necron schemas remain source-review pending until their recorded local export provenance is restored or reconciled. This batch does not certify full datasheet rules, Legends event approval or whole-army legality.

## <a id="dreadnought-saved-schema-review-regression-2026-11-15"></a>Dreadnought saved-schema review regression: 15 November 2026

The saved-loadout regressions passed for Bjorn the Fell-Handed, Brutalis Dreadnought, Venerable Dreadnought and Wulfen Dreadnought.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_brutalis_saved_loadout --only test_space_wolves_walker_saved_loadouts --timeout 900
```

The run passed **4/4 verifier processes** at `.tools/verification/20261115T223256342013Z/results.json` (SHA-256 `b57097733d9d482eac236bc7590a4edb2713edfbc3b5567b168328a243275b5a`; network disabled; legacy starter staged; no cleanup diagnostics). Eight source-option rows now map to existing fields, advancing the ledger to 87/117 reviewed with 30 remaining. Twelve reviews remain stale and nine profiles unclassified. The test confirms the Venerable Dreadnought's linked replacement conflict; full datasheet rules and whole-army legality remain out of scope.

## <a id="squad-and-predator-saved-schema-review-regression-2026-11-15"></a>Squad and Predator saved-schema review regression: 15 November 2026

The focused suites passed for Eliminator Squad, Outrider Squad, Reiver Squad, Predator Annihilator and Predator Destructor.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_eliminators --only test_outrider_squad_current --only test_reiver_squad --only test_predator_annihilator_saved_loadout --only test_predator_destructor_saved_loadout --timeout 900
```

The run passed **7/7 verifier processes** at `.tools/verification/20261115T224419581070Z/results.json` (SHA-256 `12fca5ac35b900cdc989b63b82187e3a3d2e58e7313dfa1263be05eb727fda9d`; network disabled; legacy starter staged; no cleanup diagnostics). Twelve local option rows now map to existing saved fields, advancing the ledger to 92/117 reviewed with 25 remaining. Twelve reviews remain stale and nine profiles unclassified. The two Predator profiles remain source-bounded Legends entries; competitive-event approval and full army legality are not certified here.

## <a id="captain-and-castellan-saved-schema-source-review-15-november-2026"></a>Captain and Castellan saved-schema source review: 15 November 2026

The focused saved-loadout suites passed for Captain, Captain with Jump Pack, Black Templars Castellan, Death Company Captain and Death Company Captain with Jump Pack.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_saved_loadout --only test_jump_pack_captain_saved_loadouts --only test_castellan_saved_loadout --only test_death_company_captain_saved_loadouts --timeout 900
```

The run passed **6/6 verifier processes** at `.tools/verification/20261115T225226501937Z/results.json` (SHA-256 `ba917e0276def7e94027c61896652b95d58513d254dfd0290319c1e5d194a92a`; network disabled; legacy starter staged; no cleanup diagnostics). Fourteen local option rows now map to existing fields, advancing the source-review ledger to 97/117 schemas reviewed, with 20 remaining. Twelve reviews remain stale and nine profiles unclassified. Three Necron profiles remain pending until their runtime-bound source provenance is available locally. This is source-option completeness evidence only; it does not certify complete datasheet rules or whole-army legality. See the [source audit](saved-schema-source-review-captains-2026-11-15.md).

## <a id="dreadnought-and-death-company-saved-schema-source-review-15-november-2026"></a>Dreadnought and Death Company saved-schema source review: 15 November 2026

The focused offline suites passed for Cerberus, Death Company Dreadnought, Death Company Marines, Death Company Marines with Jump Packs and Dreadnought.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_cerberus --only test_death_company_dreadnought_saved_loadout --only test_death_company_saved_loadouts --only test_dreadnought_saved_loadouts --only test_dreadnought_legends --timeout 1200
```

The run passed **7/7 verifier processes** at `.tools/verification/20261115T230358615591Z/results.json` (SHA-256 `32e0d59885f02251f5ae64862f3605e76b512190306a1594435c17d491e8c4fc`; network disabled; legacy starter staged; no cleanup diagnostics). Eighteen verified local option rows map to existing fields, advancing the ledger to 102/117 schemas reviewed, with 15 remaining. Twelve reviews remain stale and nine profiles unclassified. Three Necron profiles remain pending until their runtime-bound local source provenance is restored or reconciled. This review does not certify complete datasheets or whole-army legality. See the [source audit](saved-schema-source-review-dreadnoughts-and-death-company-2026-11-15.md).

## <a id="heavy-vehicles-and-lieutenant-saved-schema-source-review-15-november-2026"></a>Heavy vehicles and Lieutenant saved-schema source review: 15 November 2026

The focused offline suites passed for Falchion, Lieutenant, Typhon, Vindicator and Whirlwind.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_falchion_legends --only test_lieutenant_saved_loadout --only test_typhon_legends --only test_vindicator --only test_whirlwind_legends --timeout 1200
```

The run passed **7/7 verifier processes** at `.tools/verification/20261115T231234692976Z/results.json` (SHA-256 `8ee42192e2780d5c6ebc0b2dae7cdf8d68eb9a595e49a04b1892f1eb51a24fe4`; network disabled; legacy starter staged; no cleanup diagnostics). Sixteen local option rows map to existing fields, advancing the ledger to 107/117 schemas reviewed, with 10 remaining. Twelve reviews remain stale and nine profiles unclassified. This is source-option completeness evidence only; it does not certify complete datasheets, Legends event approval or whole-army legality. See the [source audit](saved-schema-source-review-heavy-vehicles-and-lieutenant-2026-11-15.md).

## <a id="necron-saved-schema-source-option-review-15-november-2026"></a>Necron saved-schema source-option review: 15 November 2026

Seven Necron profiles map eleven source option rows to their existing saved fields. The runtime-bound snapshot `20261031T053336Z` is locally present; its manifest SHA-256 is `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`, and the relevant raw-file hashes match. The export manifest has 68 validation findings, none scoped to these seven datasheets or their option rows; this audit does not certify the wider export.

The first targeted run failed only in `test_necron_warriors_current`: a legacy unit-only fixture lacks the optional `squads` key. `prepared_training.gd` now treats absent squads as an empty collection. The corrected full rerun passed:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_annihilation_barge --only test_necron_macrocytes --only test_necron_spyders --only test_necron_tomb_crawlers --only test_necron_immortals --only test_necron_monolith --only test_necron_warriors_current --timeout 1200
```

The rerun passed **9/9 verifier processes** at `.tools/verification/20261115T232348103302Z/results.json` (SHA-256 `478aaf5ba9cf5bb4a5c396549b0fd1fcafbc22ea7f779e9e9c1a566637f9cee7`; network disabled; legacy starter staged; no cleanup diagnostics). The ledger advances to 114/117 schemas reviewed, with three remaining. Twelve reviews remain stale and nine profiles unclassified. See the [source audit](saved-schema-source-review-necrons-2026-11-15.md).

## Necron saved-equipment extension and review refresh — 15 November 2026

Lokhust Heavy Destroyers, Triarch Praetorians and Triarch Stalker now save their local weapon choices in the Army Builder and materialize them before Deployment. The focused fixture checks per-model and linked weapon packages, both-player preparation, copy-tier points, Workshop edits and JSON persistence. Editing the source army after match creation leaves its frozen selection and materialized weapons unchanged. The same verified Necrons App v1.2 snapshot was checked against its manifest; all ten saved-equipment schemas now map fourteen option rows. The source registry also refreshes eighteen no-schema Necron classifications against that snapshot, distinguishing the two implemented Plasmacyte composition rows from equipment choices.

The targeted run passed **3/3 verifier stages** at `.tools/verification/20261116T020509349526Z/results.json` (SHA-256 `f07391231206274c4cd1df3cfab1a83a27f47651116ec60e4a0811198b712829`; network disabled; legacy starter staged; no cleanup diagnostics). Its fixture launches a separate Godot process to reopen the saved list, then verifies the frozen loadout after a source-list edit. A fresh 213-profile coverage export reports 120/120 detected schemas reviewed, 93 fixed-equipment classifications, zero equipment migrations pending, zero stale/unbound reviews and zero unclassified profiles. The bounded Necron reviews do not resolve the export's 68 unrelated structural findings or certify full army legality. This regression inspects Workshop controls and match materialization; it is not a visible capture or human usability review. See the [Necron source audit](saved-schema-source-review-necrons-2026-11-15.md).

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_saved_equipment --timeout 300
```

## <a id="final-marine-saved-schema-source-option-review-15-november-2026"></a>Final Marine saved-schema source-option review: 15 November 2026

The focused offline suites passed for Intercessor Squad, Scout Squad and Venerable Dreadnought. Intercessor Sergeant choices persist per unit copy through the existing roster fields; its per-model Grenade Launcher and the Scout/Dreadnought saved fields are checked by the focused regressions.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_intercessor_current --only test_scout_squad --only test_venerable_dreadnought_legends --timeout 1200
```

The run passed **5/5 verifier processes** at `.tools/verification/20261115T233210179362Z/results.json` (SHA-256 `27f17f81ccf7b70ee1c0f0d8d78b40363267057e7f80d987a71eb1796b30da76`; network disabled; legacy starter staged; no cleanup diagnostics). Ten source option rows map to existing saved configuration paths, advancing the ledger to 117/117 schemas reviewed. Twelve reviews remain stale and nine profiles unclassified. This closes the source-option audit queue only; it does not certify full rules, event approval or whole-army legality. See the [source audit](saved-schema-source-review-final-marine-profiles-2026-11-15.md).

## Legacy army restart and match-save recovery boundary — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_loadout_restart --only test_match_save --timeout 300
```

The focused run passed **4/4 verifier processes** at `.tools/verification/20261116T021607123059Z/results.json` (SHA-256 `C72017130609DE709396E9E1EA595943F133DD5C8D8C3B22D9F661CE288C8D6E`; network disabled; legacy starter staged). The restart suite verifies that a legacy army with flat model appearance arrays and no stable copy ID can be read by a separate Godot process, migrated, saved and reopened with its appearance and inferred Auto/Manual modes retained. The match-save suite verifies both valid-backup recovery from a corrupt primary and refusal to fall back when the primary has a valid checksum but a newer unsupported save version. `test_match_save` reports shutdown RID/ObjectDB cleanup diagnostics; the restart test reports none. This is a bounded compatibility/recovery check, not complete historical match migration or interruption coverage.

## Appearance gallery empty-state capture — 16 November 2026

The Army Builder Appearance workspace was captured from a live Godot 4.7.2 Compatibility runtime at 1280×800. The staged `Test Line` catalog has no ready local variants and includes a saved appearance unavailable in the current catalog. The screenshot shows the built-in 3D placeholder, camera controls, per-copy/model selector, gallery search, an Automatic choice, and the preserved unavailable choice with fallback status. It supports only empty/unavailable layout review; it does not demonstrate an actual ForceOrg sculpt, successful selection, exact equipment sculpt parity or human usability. The PNG is retained in ignored local output as `.tools/appearance-gallery-review.png`.

## Real local ForceOrg appearance preview — 16 November 2026

Command:

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script .tools/capture_real_appearance_gallery.gd --rendering-method gl_compatibility --resolution 1600x1400
```

The live Godot 4.7.2 Compatibility capture read the existing local ForceOrg catalog and model cache without starting downloads. The scan yielded 32,256 catalog entries, 395 Intercessor variants, 24 locally ready variants and 109 saved variant mappings. The preview imported the selected local mesh, and the gallery showed ready availability alongside `Match: Unverified`. Captures are `.tools/appearance-gallery-real-variants-review.png` (preview and rationale) and `.tools/appearance-gallery-real-variants-browse-review.png` (scrolled gallery cards). The process saved both images and exited, but Godot emitted RID, CanvasItem and ObjectDB shutdown cleanup diagnostics. This is local asset/availability evidence only; exact sculpt matching, wider resolver failures, screen/input coverage and human usability remain unverified.

## Interrupted model-download shutdown cleanup — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_download --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T025834028600Z/results.json` (SHA-256 `8C7A31CC41AF75D09EEB319181BF681A96D6E6E13253285C64DE2308514FE938`; network disabled; legacy starter not staged; no cleanup diagnostics). The added fixture frees the downloader while its tracked partial mesh and conversion outputs exist, then verifies they are deleted and the interrupted URL does not match the cache. This verifies graceful shutdown cleanup; forced termination, power loss and separate-machine asset availability remain open.

## Saved-match readiness interruption follow-up — 16 November 2026

The saved-match interruption fixture now reopens the creation checkpoint in a separate Godot process before either player completes Battle Readiness. It checks that the frozen loadouts and both presentation snapshots survive source-army edits, the current player retains the finish action after restart, the opposing player waits until the first setup declaration completes, and the second player's action then becomes available. The same fixture still resumes a second time after one unit has committed during Deployment.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T023350409991Z/results.json` (SHA-256 `01B051487CE24C98815A8E4E81C023B07120769341DBF0071AF26C0B130A7DB0`; network disabled; legacy starter not staged). The Godot suite reports shutdown RID/ObjectDB cleanup diagnostics despite zero fixture failures. This closes the local interruption/restart slice for readiness and one Deployment checkpoint; mission-specific declaration breadth, cross-machine LAN and user-driven readiness review remain open.

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_match_interruption --timeout 300
```

## Unsupported legacy match-version boundary — 16 November 2026

The match-save regression now creates both a v0 primary and a future v2 primary, each with a valid checksum and a valid v1 backup beside it. In both cases the reader returns `Incompatible save version.` and refuses to roll back to the older checkpoint. The test does not add conversion for old match formats; it verifies their preserved, explicit unsupported boundary. Existing coverage still checks backup recovery when the primary is corrupted.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T023648741145Z/results.json` (SHA-256 `92B12844957C11A0726296D944055B6447292CFB75457F6E56BF355D41B92C6B`; network disabled; legacy starter staged). `test_match_save` reports Godot shutdown RID/ObjectDB cleanup diagnostics after `MATCH SAVE: PASS`.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_match_save --timeout 300
```

## Saved formations with mission preparation — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T032412288733Z/results.json` (SHA-256 `59882ACDFA1027E9E5F20473BC968EB8AF4EC5B0F77A9F62417697F43E21990D`; network disabled; legacy starter staged). The fixture saves a current Space Marine army and Necron army with a Warlord each, builds an official Chapter Approved match from the admitted saved-army selections, and verifies both saved Warlords are applied to the match state while mission preparation and the match-specific readiness step remain active. This is one supported path only; broader mission-dependent declarations and player review remain open.

## Failed bundle conversion cleanup — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_download --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T032936493852Z/results.json` (SHA-256 `36D4727695F02316421FBE7444EB2D8E4D914ADBBB0DDAC607A2656AA6F578F0`; network disabled; legacy starter not staged; no cleanup diagnostics). The added failure fixture checks that the conversion cause remains visible, staged bundle and converter outputs are removed, and the failed source has no cache hit. It exercises graceful failure handling only; forced process termination, power loss and full converter integration remain open.

## Appearance-only match isolation — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_armies --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T033135002812Z/results.json` (SHA-256 `3428A0B4D43D33EE499ED9807E2B10851032A04169D222B4CFE0679AFAA7FF9F`; network disabled; legacy starter staged). The added fixture changes only unit and per-model appearance references, then confirms canonical current-catalog admission and the complete prepared gameplay state are unchanged. The Godot process reported shutdown cleanup diagnostics after the suite passed. This proves the saved-reference path for the tested profile; direct imported-mesh recovery and separate-machine asset behavior remain open.

## Saved-army host/client privacy and reconnect — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --network --only test_saved_armies_network --timeout 300
```

The run passed **22/22 verifier processes** at `.tools/verification/20261116T130522600906Z/results.json` (SHA-256 `F2CAAA43322E7BFC0A2F5B9762F45926F6BFF23C78B1268AAD37E85B55B70FFD`; loopback network enabled; the targeted profile staged the legacy starter, while the fixture constructed its lists through the current local catalog). It covers baseline admission, mismatched-budget rejection, stratagems, movement/attack/save/damage/Hazardous/count/Desperate Escape re-roll settings, private list metadata, rejected guest mutations, distinct host/client appearance references kept out of synchronized gameplay state, three-unit alternating Deployment and authenticated reconnect to the command phase. Every network process reported Godot RID/ObjectDB shutdown cleanup diagnostics despite the verifier marking all cases passed. This is a same-machine loopback result; unequal-cache LAN across separate computers, abrupt process interruption and human visual/usability review remain open.

## Second-faction legacy appearance migration — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_loadout_restart --timeout 120
```

The run passed **3/3 verifier processes** at `.tools/verification/20261116T132548224316Z/results.json` (SHA-256 `76D44C02981C1C634D04D7C30542BEC87A1F60CDC4CB145590581FDDAC4DE390`; network disabled; legacy starter not staged; no shutdown cleanup diagnostics). The separate Godot reopen now reads a legacy bank containing Space Marine Intercessors and Necron Warriors, migrates their flat per-model appearance arrays and stable copy/model IDs, preserves automatic/manual selection modes, saves both lists and reopens them again. This broadens the migration sample by faction; it does not cover every historical save schema or certify unsupported match-format conversion.

## Forced model-download process interruption recovery — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_download --timeout 120
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T133827850261Z/results.json` (SHA-256 `E637B4EB647C784EBA2272C8750756ED347A535C0F5248485CD15904677B40FC`; network disabled; legacy starter not staged; no cleanup diagnostics). The fixture starts a separate Godot process, records a partial download plus converter directory/result, terminates it before normal shutdown, then creates a new downloader and verifies recovery removes only those journaled paths, leaves an already-imported mesh intact and creates no cache hit. The checker exercises local forced termination only; power-loss behavior, broader converter/cache integration and unequal-cache LAN remain open.

## Corrupt local catalog-cache recovery — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_models --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T134118461631Z/results.json` (SHA-256 `D8555EF39BC70B34BF0E458E91342A7B89F61F6A65DBFF1BD0D6DCAC93ED25D2`; network disabled; legacy starter staged). With a matching source path and fingerprint, the fixture replaces the cached entries with a malformed serialized value and checks the scanner rebuilds the catalog from the unchanged source, writes a valid cache record and reuses it on the next scan. The same suite verifies applying a local imported mesh leaves match state unchanged and removing/changing the source mesh resumes the saved match with a placeholder. Godot reported shutdown RID/ObjectDB cleanup diagnostics after passing. This checks the app's local catalog scan cache; corrupted asset files, converted-bundle markers and wider cache repair remain separate coverage.

## Legacy multi-copy appearance migration — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_saved_loadout_restart --timeout 120
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T134924337892Z/results.json` (SHA-256 `0C0C101553813B322BE962EF8F00DA6C88C94F1B560983E7E77959164B97B874`; network disabled; legacy starter not staged; no shutdown cleanup diagnostics). The legacy Space Marine list now contains two Intercessor copies encoded in the old flat arrays with different unit appearances and separate model overrides. A separate Godot process migrates each copy to a distinct stable identity, infers Auto/Manual modes, saves the list and reopens it again with both appearances intact. The existing Necron single-copy fixture runs in the same process. This improves identity/appearance migration breadth without adding support for historical match conversion.

## Saved-army Chapter Approved declaration sequence — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T135234822460Z/results.json` (SHA-256 `3496162697FF1D4C8F86EAE3E8CD5645EEBA91A30945FFC82B525065BE67404A`; network disabled; legacy starter staged). Starting from saved Marine and Necron Warlords, the fixture resolves the selected mission's terrain roll, roles roll-off, side choice and each player's Battle Ready declaration in order. It verifies the required actor changes at each step and that the saved Warlord assignments remain unchanged. This is one selected mission/roster profile; other supported primary/secondary combinations and manual usability review remain open. Godot reported shutdown RID/ObjectDB cleanup diagnostics after the passing test.

## Converted-bundle cache marker validation — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_model_cache --timeout 180
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T135748673508Z/results.json` (SHA-256 `38B742B8F00CF93764186A961D9DCBE74B6C5879E833202506E3211A844E33CC`; network disabled; legacy starter not staged; no shutdown cleanup diagnostics). Synthetic cache entries exercise the same local resolver used by imported assets: a valid converted manifest resolves its mesh, while an unsafe cache directory, malformed manifest, incomplete declared material dependency and mismatched dependency URL all remain invalid with no resolved part. A complete, correctly identified dependency is accepted. This validates cache admission and path/dependency checks; it does not run or certify an external Unity bundle converter.

## Saved-army A Tempting Target preparation — 16 November 2026

Command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_battle_readiness_ui --timeout 300
```

The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T140024155394Z/results.json` (SHA-256 `2389D79A2225680406AAB34F41D42A5F8957662639DFDFA0DE1D50D20AC81796`; network disabled; legacy starter staged). In addition to the saved-army terrain/roles/side/readiness path, the fixture creates the supported Engage + A Tempting Target pair, confirms P2 chooses a target for P1 and P1 then chooses one for P2, and proceeds through role selection and both Battle Ready choices. It verifies both player target assignments exist and saved Warlord records remain unchanged. This covers one additional declaration order; other supported combinations and manual interaction review remain open. The passing Godot test reported shutdown RID/ObjectDB cleanup diagnostics.

## Cleanup verification — 17/18 November 2026

Repository cleanup (dead-code/doc removal, verify.py suite classification) was checked with the focused and full profiles on the current working tree (`feat/local-necron-and-import-progress`, uncommitted).

Commands and outcomes:

- `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_leader_catalog --only test_kor_sarro_khan --only test_necron_warriors_current --only test_implemented_catalog --only test_necron_saved_equipment --only test_saved_match_interruption --timeout 300` — run `20261118T001846438849Z`: import, python, test_leader_catalog, test_kor_sarro_khan, test_implemented_catalog and test_saved_match_interruption PASSED; test_necron_warriors_current FAILED (Praetorian rod-gating assertion stale versus the implemented saved-equipment scope) and test_necron_saved_equipment FAILED data-free (prepared-match construction needs the legacy snapshot at runtime).
- `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile full --only test_necron_warriors_current --only test_necron_saved_equipment --timeout 300` — run `20261118T002228384320Z`: import, python and startup PASSED; test_necron_saved_equipment PASSED with the legacy snapshot staged, confirming its runtime data dependency and its removal from the current-catalog match set; test_necron_warriors_current FAILED identically, confirming its failure is a pre-existing working-tree issue independent of data staging.
- `python -B -m unittest discover -s tests -p "test_*.py"` — 124 tests, OK (run twice during the cleanup).
- `python -m unittest tests.test_architecture tests.test_verification` — 39 tests, OK.

The two failing Godot suites at that checkpoint were pre-existing issues in the uncommitted Necron work-in-progress, not cleanup regressions; both were resolved in the 18 November follow-up below.

### Necron prepared-match template and Triarch scope reconciliation — 18 November 2026

`Prepared.initial_state` now uses embedded current-reference templates whenever both players supply `schema_version: 2` Space Marines or Necrons selections without `legacy_necron_reference`, so current-catalog Necron prepared matches (`test_necron_saved_equipment`) no longer read `res://data/imported/starter-11e-v1` before `_materialize_mixed` replaces the placeholder squads and units. `test_necron_saved_equipment` is restored to `CURRENT_CATALOG_MATCH_SUITES`, while `test_necron_warriors_current` is classified under `targeted`/`full` because its C’tan Warlord and historical Warrior checks intentionally exercise the legacy starter pack. Triarch Praetorians (`000000539`) and Triarch Stalker (`000000540`) capability notes, coverage rows and the `test_necron_warriors_current` Praetorian option assertion are reconciled with the verified local Necrons App v1.2 export (`.tools/wahapedia/11e/necrons/20261031T053336Z`, `Datasheets_options.csv`) and the implemented saved-equipment schemas. In addition, `tests/test_prepared_match.gd` now explicitly sets `unit_abilities_choice.button_pressed = false` before starting its baseline historical prepared-match UI check (matching `tests/test_decision_ui.gd`), and `tests/test_space_marine_leader_links.gd` now validates the five Necron Cryptek Support identities in `Supports.BODYGUARDS` (11 Necron pairs alongside the 96 static Space Marine pairs) against their `current_reference_necron_profiles.gd` `source_bodyguard_datasheet_ids`.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_leader_catalog --only test_kor_sarro_khan --only test_implemented_catalog --only test_necron_saved_equipment --only test_saved_match_interruption --only test_necron_triarch_praetorians --only test_necron_triarch_stalker --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_necron_warriors_current --only test_capabilities --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_space_marine_leader_links --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_prepared_match --only test_space_marine_leader_links --timeout 300
```

The focused data-free run passed **9/9 processes** at `.tools/verification/20261118T132355989993Z/results.json` (SHA-256 `D207867DE02C5E988626D14D8C9509A22C239111ED51FDF19F207C52051235B2`; `legacy_starter_staged: false`, `network: false`; `test_implemented_catalog` and `test_saved_match_interruption` reported headless RID cleanup diagnostics at shutdown). The targeted run passed **4/4 processes** at `.tools/verification/20261118T132750030808Z/results.json` (SHA-256 `3EBFB37DE6C2C0F4504F4B8A404C263B7778301558F84F261876993220ADDE92`; `legacy_starter_staged: true`, `network: false`, no cleanup diagnostics). The coverage export (`213` admitted profiles, `120/120` reviewed schemas, `93` fixed profiles) and `python -B -m unittest discover -s tests -p "test_*.py"` (`124` tests) passed. The focused Leader/Support link run passed **3/3 processes** at `.tools/verification/20261118T140015762834Z/results.json` (SHA-256 `EC83FC928BC2AE445E79AEED38B172625340EF7E4F3724EF4F4128D0FAC5A663`; `legacy_starter_staged: false`, `network: false`, no cleanup diagnostics), and the targeted prepared-match and Leader/Support batch passed **4/4 processes** at `.tools/verification/20261118T140051063197Z/results.json` (SHA-256 `785B9270580D9125F7FF6167E2B136B693CC834D6154F11ADF0F557E9BE6A9E5`; `legacy_starter_staged: true`, `network: false`; `test_prepared_match` reported headless RID cleanup diagnostics at shutdown). Exact Triarch Stalker FRAME geometry, separate-machine LAN and full Necron army legality remain uncertified.

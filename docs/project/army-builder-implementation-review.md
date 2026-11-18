# Army Builder implementation review — 15 November 2026

## Assessment

The architecture follows the original Army Configuration and ForceOrg Visual Variants plan: persistent equipment belongs to the saved army, current local rules validate it, and local assets remain presentation data. The implementation is a working partial migration, not coverage of every unit or faction. The earlier conversational description “all units in the game” described an ambition, not delivered scope. Applying this workflow across the game does not mean implementing every faction's rules as part of this migration.

The approach should now move from repeated individual profile additions to a coverage inventory and consolidation of the repeated plumbing. Per-datasheet source checks and validation remain necessary; generic controls must not invent legality.

This review inspects the current working tree, the plan supplied in Downloads, the architecture and status documents, the saved-loadout path and the latest local verification reports. The tree also contains adjacent rules, combat and UI changes. This is not an exhaustive re-certification of every dirty file, every datasheet or the entire rules engine. No runtime code was changed by this review.

## Where the plan stands

| Area | Current implementation | Remaining exit gate |
|---|---|---|
| Ownership and data flow | Documented catalog, profile, admission, materialization, appearance and snapshot boundaries | Keep ownership aligned during consolidation |
| Persistent army/model identity | Stable copy/model IDs, saved overrides and Auto/Manual modes; compatibility readers | Broader older-profile and older-match fixture review |
| Equipment | 120 detected saved schemas have explicit source-option reviews; 93 other profiles have current fixed-equipment source classifications; canonical admission, materialization and setup locks cover the migrated paths | Broader legacy fixtures and behavior/usability review; these counts do not establish complete rules or every-faction coverage |
| Warlord and attachments | Saved candidates replayed through current rules checks; canonical formation references in LAN packets | Separate-machine host/guest review and complete rules coverage |
| Appearance | Local resolver, metadata rationale, preview/gallery, explicit similar-model action, local fallback and asset-status feedback | Thumbnail gallery, exact sculpt review, broader conversion/recovery coverage |
| Match flow | Quick Match, compact readiness, editor route for blockers, frozen gameplay and local appearance snapshots; local saved-match checkpoint is written at creation before the first Deployment command | Broader end-to-end review with mixed equipment, mission-dependent restart and deployment interruption |
| Verification | Focused offline integration regressions and selected actual Godot captures recorded; separate-process recovery after one Deployment unit commits passes for a saved local match | Full integration, separate-machine LAN with unequal asset caches and human usability review |

Phase 0 is documented. Phases 1–4 remain partial; the integration and failure-recovery acceptance gates remain open. The latest 15 November coverage export enumerates 213 admitted construction profiles: 120 have detected saved fields and all 120 have explicit source-option reviews; 93 profiles have current fixed-equipment classifications; no option-bearing profile remains without a schema; and no stale or unclassified records remain. All ten Necron equipment schemas are now bound to the current runtime digest and the verified local snapshot. The manifest records 68 structural findings outside the ten audited datasheets and their equipment options, so this bounded review does not certify the full export. The [source-continuity record](../verification/army-builder-equipment-provenance.md) remains separate from equipment completeness. The exporter does not certify complete rules coverage.

## Delivered workflow scope

The saved-equipment path also includes Deathwatch Veterans/Terminators, both Vanguard Veteran profiles, Ravenwing Black Knights/Command Squad, the Scout Bike Squad Legends profile, Sword Brethren, Indomitor, Crusader Squad, Decimus, Fortis, Spectrus and Talonstrike Kill Teams. Spectrus preserves its fixed 2/2/2/4 sniper, Occulus, special-issue and Marksman roles; both sniper replacements, the paired Deathwatch Bolt Carbine/Ceramite Fists swap, and one Helix Gauntlet per unit save by model and copy. Existing 185/185/195 copy tiers and zero surcharge remain. Its exact weapon packages materialize through the local factory and preparation choices lock on saved lists. Fortis retains its fixed ten-model role sequence, Sergeant's separate melee/ranged choices, Deathwatch Bolt Rifle Grenade Launcher cap, one Plasma Pistol replacement and Castellan launcher choice; equipment remains free and the 210/225 copy tiers are unchanged. Talonstrike's one Sergeant, four Heavy Intercessors and five Intercessors now save their listed replacements independently; the one-per-five Intercessor Plasma Pistol rule admits two in a ten-model unit, and any number of the four Heavy Intercessors may take Plasma Exterminators. Its 280/280/300 copy prices and zero surcharge are unchanged. Each adapter materializes through its existing local factory and locks duplicate preparation edits. Decimus retains only the source-compatible ten-model construction; model roles expose the three source-listed per-five replacements, including the bearer-only Storm Shield benefit, while the five-model/minimum-composition blocker and 210/190 Wahapedia/MFM price difference stay disclosed. Crusader keeps its 10/20-model source roles, four replacement rows, two combined Initiate Power Fist/Pyreblaster limit per ten and unchanged zero-surcharge Wahapedia totals; current MFM price conflicts remain visible. Indomitor retains its three source-defined model roles, eligible replacements, two-Heavy-Bolter/one-Multi-melta caps and existing 280/300-point copy tiers. Sword Brethren retains all ten factory-backed weapon packages, independent per-four caps, unchanged copy prices, and unpriced-size blockers. The Vanguard adapters preserve the Jump Pack Sergeant choices, ordinary Plasma cap, exact local factories, copy prices, shield-bearer saves, pre-Deployment materialization and match locks. Both Ravenwing profiles preserve their one-per-three Grenade Launcher limit, role factories, saved copy/model choices and source price tiers. Existing migrations include Intercessors, Assault Intercessor Sergeant weapons, Heavy Intercessor Heavy Bolters, Eliminators, Outriders, Inceptors, Hellblaster Sergeant pistols, Invader ATVs, Reiver squad gear, Aggressors, Scouts, Sanguinary Guard, Death Company Marines and Death Company Marines With Jump Packs, standard Rhino, Tarantula Sentry Battery, Ravenwing Darkshroud, Land Speeder, Land Speeder Vengeance, Baal Predator, Predator Destructor, Predator Annihilator, Brutalis Dreadnought, Stormhawk Interceptor, Stormtalon Gunship, Bjorn, the Space Wolves Venerable Dreadnought, Wulfen Dreadnought, Death Company Dreadnought, the shared-book Captain and its Jump Pack, Gravis, Terminator and Bike variants, the Blood Angels Captain, both Death Company Captain profiles, the Black Templars Castellan and Marshal, and the shared-book Lieutenant. Necron paths include Warriors, Immortals, Canoptek Macrocytes, Spyders, Tomb Crawlers, Annihilation Barge, Monolith, Lokhust Heavy Destroyers, Triarch Praetorians and Triarch Stalker. This list describes migrated equipment paths, not complete faction or datasheet certification. See the [architecture record](../architecture/army-builder-forceorg-flow.md) and [player guide](../guides/army-builder.md).

The vehicle, Dreadnought, aircraft, Space Wolves walker and Captain increments preserve independent copies where the datasheet permits, validate saved selections, install their exact weapon packages before Deployment and reject duplicate setup changes. Predator Destructor, Annihilator, aircraft and several other adapters retain their Legends boundaries. Local metadata can guide appearances without certifying that the sculpt visibly matches.

Adjacent work in the current tree includes Strategic Reserves declarations/ingress, FLY and MONSTER/VEHICLE movement checks, Necron profile/combat paths and in-match UI changes. Those have their own source and verification records; they do not close the Army Builder plan's acceptance gates. See the [support matrix](support-matrix.md) and [verification history](../verification/verification-results.md).

## Review findings

1. **Resolved — source provenance and classification ledger.** The refreshed 213-profile export has 120 detected equipment schemas with 120 exact-field source reviews, 93 source-reviewed fixed-equipment profiles, and zero pending migrations, stale reviews or unclassified profiles. All ten Necron saved schemas are bound to the verified local snapshot and current runtime digest; 68 unrelated export-manifest findings remain outside those datasheets. `saved_fields` still detects schema presence only; it does not by itself prove behavior or full rules coverage.
2. **Addressed — shared option plumbing.** The shared `SavedEquipment` descriptor/adapter path now binds the Workshop control, typed roster field, local validator/weapon factory and prepared-match lock. Rhino uses this path without a new one-off editor handler. Keep source-specific restrictions in their existing factories; further refactoring should follow demonstrated repetition, not replace the current schema wholesale.
3. **Addressed — saved-versus-draft feedback for the shared control.** The shared callback says equipment was updated in the draft and tells the player to save the list. The Rhino Workshop signal regression checks that message and dirty state. Other older specialized controls should keep the same distinction when they are next touched.
4. **Partly addressed — persistence evidence.** The restart fixture now reopens Rhino in a separate Godot process and checks that changing the source army later does not change the frozen match setup. The focused Rhino regression checks typed invalid values and duplicate preparation rejection. The Annihilator's own disk round trip and its complete boolean matrix remain unverified; this evidence should stay profile-specific.
5. **Open — integration and visible review.** Offline tests establish useful local behavior, but this Rhino increment has no live Godot capture. LAN packet checks do not establish an RPC host/guest session. Schedule a representative end-to-end saved-army review before claiming the plan's integration gates.

## Recommended next implementation order

1. **Complete —** the 213-profile source ledger has 120/120 exact schema reviews, no equipment migrations, no stale provenance and no unclassified profiles; refresh it when the runtime catalog changes.
2. Expand legacy army and match reopen fixtures, keeping historical profiles labeled and outside new construction.
3. Review a representative saved army through save/reopen, readiness, deployment, match save/reload and later source-list edits. Include mixed model equipment, missing visuals and interrupted asset preparation; capture the actual Godot UI where available.
4. Finish the visual gallery, exact sculpt review and cached/conversion failure recovery, then conduct human usability review.
5. Perform final host/guest integration on separate machines with different local asset availability. Keep these checks visibly open until observed.

## Evidence reviewed

Existing local verifier reports were read and their SHA-256 hashes recomputed for Baal Predator (`20261113T170206645894Z`, 5/5 processes), Predator Destructor (`20261113T172822142075Z`, 3/3) and Predator Annihilator (`20261113T174036761309Z`, 4/4). Exact commands, hashes and limitations are in the [verification record](../verification/verification-results.md#predator-annihilator-saved-loadout--13-november-2026). These are existing results, not new runs from this review. No new rules-source, network, live UI or full-suite verification is claimed.

## Implementation follow-up — 13 November 2026

The requested four workstreams are now tracked explicitly:

| Workstream | Delivered follow-up | Remaining work |
|---|---|---|
| Coverage inventory | A reproducible runtime exporter and [ledger](army-builder-coverage.md) enumerate 204 admitted construction profiles; 63 have detected equipment fields (four source-option reviewed), 87 are source-reviewed fixed, 54 require equipment migration and none have stale/unclassified equipment reviews | Review remaining profiles to distinguish fixed equipment, partial schemas and options that need migration; resolve stale provenance before accepting source classifications |
| Shared code | Destructor and Annihilator share callbacks; explicit registered adapters share defaults/schema validation, canonical copy projection, controls and materialization for 29 one-model Marine profiles plus four per-model unit schemas | Extend only where source-specific factories and complete validators exist; retain existing save schemas and source boundaries |
| End-to-end review | A dedicated test writes an army bank, launches a separate Godot process to reopen it, saves/reloads a match, checks later source-list edits leave that match unchanged and exercises actual control signals | Broader mixed infantry/vehicle flow, readiness/deployment interruption, full manual interaction and separate-machine integration remain open |
| Remaining unit migration | Invictor, Ancient, seven optional vehicles, Tarantula Sentry Battery, eight Captain profiles, Sanguinary Guard, both Death Company squads, Brutalis plus three other Dreadnought profiles, two aircraft and three Space Wolves walkers use the shared adapter; focused saved-choice, per-model limits, copies, materialization and editor checks passed for the new profiles | The rest of the catalog has not been source-classified or migrated; do not treat these profiles or ledger counts as broad completion |

These changes address the draft feedback finding, introduce the shared adapter path and add seven optional-vehicle profiles. The original review above records the state and findings before this follow-up. Current commands, results and limitations are maintained in the verification record.

## Dreadnought saved-equipment follow-up — 13 November 2026

The adapter now includes Dreadnought and Venerable Dreadnought (Legends). Both use existing local weapon factories as cross-field validators, so the Army Builder rejects the Dreadnought's Storm Bolter/Heavy Flamer conflict with its Crushing Feet + Missile Launcher package and accepts all 12 documented Dreadnought and 32 Venerable Legends combinations. Saved packages apply after source-default setup, materialize exact ranged and melee weapons, preserve per-copy differences and suppress/guard repeated match-preparation changes. The restart fixture now reopens a mixed Predator/Dreadnought list in a separate Godot process and verifies that later list edits do not mutate the frozen match.

The combined focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_dreadnought_saved_loadouts --only test_saved_loadout_restart --only test_dreadnought_legends --only test_venerable_dreadnought_legends --timeout 300
```

It passed **6/6 processes** at `.tools/verification/20261113T200236356425Z/results.json` (SHA-256 `C2523931EB2044FE4F49764DF5A47E9DDE84A01CE38F447434F2BF4F20713FFC`; network disabled, legacy starter staged, no headless cleanup diagnostics). The Dreadnought source audits remain the rules evidence; this test result establishes local Army Workshop and match-persistence behavior only. Sculpt parity, live UI capture, event-use decisions, full army legality and separate-machine LAN remain open.

## Aircraft saved-equipment follow-up — 13 November 2026

Stormhawk Interceptor and Stormtalon Gunship now use the shared adapter. Their local Legends factories supply the selectable profile records; the Workshop saves the Las-talon replacement and Skyhammer choices per model copy, admits them through the current local catalog, applies them after profile defaults and locks duplicate match-preparation edits. The focused adapter regression checks all six Stormhawk and four Stormtalon choices, independent configured/default copies, exact ranged profiles, editor signals and forced-edit rejection. The existing source tests continue to cover each audited datasheet. No UI capture was made for this increment.

The exact offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aircraft_saved_loadouts --only test_stormhawk_interceptor --only test_stormtalon_gunship --timeout 300
```

It passed **5/5 processes** at `.tools/verification/20261113T201409698292Z/results.json` (SHA-256 `FCCC66B747740413B17BC9091FE88BC53A1160A074D037E08A972F0E4EBFE0F9`; network disabled, legacy starter staged, no headless cleanup diagnostics). This verifies the local saved-equipment path against the existing source audits; it does not certify event eligibility, sculpt parity, full army legality, separate-machine LAN or human usability.

## Space Wolves walker saved-equipment follow-up — 13 November 2026

Bjorn, the Space Wolves Venerable Dreadnought and Wulfen Dreadnought now use the shared adapter with the local Space Wolves weapon factory. Their schemas accept 3 Bjorn choices, 8 legal Venerable combinations and all 4 Wulfen combinations. The Venerable factory's restriction on pairing the Great Axe + Blizzard Shield with a non-Assault Cannon is retained. Saved copies materialize exact ranged/melee profiles and shield state, preserve separate defaults where multiple copies are allowed and reject duplicate match-preparation edits. Murderfang remains unchanged because its audited loadout is fixed. This Venerable profile is the Space Wolves datasheet, separate from Venerable Dreadnought (Legends).

The exact focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_walker_saved_loadouts --only test_space_wolves_walkers --only test_capabilities --only test_implemented_catalog --timeout 300
```

It passed **6/6 processes** at `.tools/verification/20261113T202939499046Z/results.json` (SHA-256 `C731DD693403671079B4A8354CDAB80CC50151403754E0EFFB0AD134DD8C9305`; network disabled, legacy starter staged). The `test_implemented_catalog` process reported headless RID/ObjectDB cleanup diagnostics and exited successfully; the other processes had none. This checks local Army Workshop behavior against the existing source audit; it does not certify full Space Wolves legality, sculpt parity, event eligibility, separate-machine LAN or human usability.

## Death Company Dreadnought saved-equipment follow-up — 13 November 2026

The Death Company Dreadnought now uses the shared adapter for its Twin Heavy Bolter/Twin Multi-melta choice and linked Blood Fists + Bolt Rifles/Blood Talons package. The existing local weapon factory validates the four combinations; saved selections materialize after source defaults and lock the existing preparation actions. The focused regression covers separate configured/default copies, exact weapon arrays, admission, Workshop signals, choice suppression and forced-change rejection. Its source audit continues to define the 11e Blood Angels profile and existing limitations.

The exact offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_dreadnought_saved_loadout --only test_death_company_dreadnought --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T204234432951Z/results.json` (SHA-256 `B99922B14AB239654D53EEC38230420E1B91EB3E01E927F35EAC288DF4E84877`; network disabled, legacy starter staged, no cleanup diagnostics). This is a saved-equipment path check against the previously recorded source audit; it does not certify full army legality, sculpt parity, separate-machine LAN or human usability.

## Death Company Captain saved-equipment follow-up — 13 November 2026

Both Blood Angels Captain profiles now use the shared saved-equipment adapter. The foot Captain stores its pistol and melee replacements separately, with the local factory admitting all six combinations. The Jump Pack Captain stores one of its nine complete packages, preserving the source constraints between pistol, melee weapon and Relic Shield. Admission and match materialization use the existing current reference profiles from the verified local snapshot `20261021T130623Z` (App book `000000021`, datasheets `000003832` and `000003833`). Saved choices install exact ranged/melee profiles, suppress match-preparation duplicates and retain the Relic Shield's one extra Wound. The source revision and weapon facts were not re-audited online in this implementation step.

The focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_captain_saved_loadouts --only test_blood_angels_characters --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T205339544317Z/results.json` (SHA-256 `9C75B203D7FDF0FC5FBC56EE7F28DE3B42D29FC0287B7C96C9208733322652AB`; network disabled, legacy starter staged, no headless cleanup diagnostics). The new regression checks all 15 source combinations, current-catalog admission, per-copy save/materialization, Workshop signals, duplicate-choice suppression, forced-edit rejection and shield wound adjustment. Full Blood Angels/army legality, sculpt parity, separate-machine LAN and live Workshop capture remain open.

## Blood Angels Captain saved-equipment follow-up — 13 November 2026

The Blood Angels Captain now saves its independent pistol and melee replacements through the same registered one-model adapter. Its local source factory accepts the six combinations: two pistol choices crossed with three melee choices. Current catalog admission, pre-Deployment weapon materialization and setup locking are covered in the shared adapter regression. The source book, snapshot, datasheet ID, option rows and file hashes remain documented in the [existing Captain audit](../marine-blood-angels-captain.md); no rules-source refresh was performed during this implementation.

The focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_captain_saved_loadouts --only test_blood_angels_captain --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T210522212816Z/results.json` (SHA-256 `4582FAB0CDFEEAF3FA0C34ABBD6672FF8AE636EF16F9BB64F4F361CF6948A634`; network disabled, legacy starter staged, no headless cleanup diagnostics). The new saved-equipment regression exercises one Captain copy because the runtime capability record does not declare a repeat limit; this change leaves construction limits unchanged. Full army legality, sculpt parity, separate-machine LAN and live Workshop capture remain open.

## Shared-book Captain saved-equipment follow-up — 13 November 2026

The shared Space Marines Captain now stores its ranged package and melee weapon separately on each stable model copy. The adapter uses the existing local Captain factory, admitting all seven source-permitted combinations and rejecting the explicit Relic Shield + Power Fist conflict. Saved match creation applies exact weapon profiles after source defaults, sets the shield's additional Wound and locks duplicate Army Preparation edits. Three differently configured copies are retained independently; the profile's audited one-to-three copy limit remains unchanged.

The focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_saved_loadout --only test_captain_current --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T211416516160Z/results.json` (SHA-256 `FD2A703678BEBE0B348B8A42BB3D2741F82494884CB5B98DC7D47736602B5B25`; network disabled, legacy starter staged, no headless cleanup diagnostics). The source book, snapshot, datasheet ID, option rows and file hashes remain documented in the [existing Captain audit](../marine-captain.md); no rules-source refresh was performed. Full army legality, sculpt parity, separate-machine LAN and live Workshop capture remain open.

## Captain With Jump Pack saved-equipment follow-up — 13 November 2026

The shared one-model adapter now stores the Captain With Jump Pack's seven complete source-listed weapon packages as one validated choice. The package factory keeps the pistol, melee weapon and Relic Shield combinations together; saved matches materialize exact profiles and shield wounds before Deployment and reject duplicate setup edits. The existing three-copy cap is unchanged. The source audit's App book, datasheet, local snapshot and hashes remain authoritative; no rules-source refresh was performed in this implementation.

The focused command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_jump_pack_captain_saved_loadouts --only test_captain_with_jump_pack --timeout 300
```

It passed **4/4 processes** at `.tools/verification/20261113T212035509775Z/results.json` (SHA-256 `FA79BDFBBD4167FB917E69F00BED7EB57D77E3E5539B549A700E424E82809C27`; network disabled, legacy starter staged, no headless cleanup diagnostics). The adapter regression checks every package, three distinct copies, local admission, exact materialization, shield wounds, Workshop signals and forced-edit rejection. Full army legality, sculpt parity, separate-machine LAN and live Workshop capture remain open.

## Sanguinary Guard saved-equipment follow-up — 13 November 2026

The shared adapter now also supports a multi-model schema: stable model IDs store each Guard's Angelus Boltgun/Inferno Pistol choice, and roster admission enforces the audited one-per-three-model limit. Distinct copies retain separate per-model selections. The prepared match receives exact local weapon profiles before Deployment and saved lists suppress the repeated Army Preparation choice. At that checkpoint the ledger detected schemas in 54/204 admitted profiles; 150 rows needed source review and were not presumed migrations.

Focused verification passed 6/6 processes, including separate-process disk reopen and a frozen match snapshot; full details, exact command and result hash are in the [verification record](../verification/verification-results.md#sanguinary-guard-saved-equipment--13-november-2026). The local source audit was not refreshed. A live Workshop capture was not obtained because the launched Godot debug windows remained on the splash screen. Full army legality, exact sculpt parity, separate-machine LAN and human usability remain open.

## Death Company Marines saved-equipment follow-up — 13 November 2026

Both audited Blood Angels squad profiles now save source-listed melee and pistol choices per stable model; only the foot squad exposes the Grenade Launcher field. Their existing local validators enforce copy-wide quotas for each 5/10-model roster, and prepared saved matches apply exact weapons and reject duplicate setup changes. A separate-process fixture verifies disk reopen for the foot squad and differently configured Jump Pack copies and keeps those records in the frozen match after later army edits. The focused batch passed 7/7 processes. At that checkpoint, the ledger detected schemas in 56/204 profiles and flagged 148 for fixed-equipment/option review; this was not a count of required migrations. See the [verification record](../verification/verification-results.md#death-company-marines-saved-equipment--13-november-2026). Source research was not refreshed, and full army legality, exact sculpt parity, separate-machine LAN and human usability remain open.

## Tarantula Sentry Battery saved-equipment follow-up — 13 November 2026

The shared adapter now treats Tarantula Sentry Battery's 1/2/3-model units as per-model loadout sets: stable identities retain each model's Twin Heavy Bolter/Twin Lascannon choice, independently across copies. It reuses the verified local Legends weapon factory and leaves existing prices, copy caps, rules and event labels unchanged. Focused controls, admission, saved materialization and disk-restart checks passed in a 7/7-process batch. At that implementation checkpoint, the ledger detected schemas in 57/204 profiles and had 147 profiles without source classifications. See the [verification record](../verification/verification-results.md#tarantula-sentry-battery-saved-equipment--13-november-2026) and [existing local audit](../marine-tarantula-sentry-battery.md). No source research was refreshed; exact physical footprint, full army legality, separate-machine LAN and human usability remain open.

## Fixed-equipment source review — 13 November 2026 (historical checkpoint)

At this checkpoint, the source-review registry contained 40 records. Eleven fixed-equipment classifications were accepted and bound to their book, datasheet, source snapshot, manifest hash and runtime source digest. Ten use the verified `20261021T130623Z` export and its `Datasheets_options.csv` hash `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`; Tarantula Air Defence Battery uses its separate `20261030T013229Z` snapshot. The other 29 records point to verified Space Marines audits and an options-file hash with no rows for those datasheets, but the runtime profiles do not record the matching snapshot and manifest; the exporter correctly labels these records stale instead of accepting them. The [coverage ledger](army-builder-coverage.md) distinguishes 58 saved schemas, 11 accepted fixed profiles, 29 stale/unbound reviews and 106 profiles with no source classification. This classifies equipment options only and does not certify rules coverage or army legality.

## Equipment provenance follow-up — 14 November 2026

The coverage exporter now includes existing runtime verification metadata alongside original extraction metadata. Reviews explicitly choose their provenance basis and reject mismatched pairs or missing bindings. Local source continuity resolved all 29 previously stale fixed-equipment records, yielding 40 accepted fixed profiles. The current tree also exposes the Rhino Primaris schema, so discovery now counts 59 schemas and 105 unclassified profiles; that schema was not introduced by the provenance change. The three focused Python tests passed. See the [source-continuity evidence and reproduction commands](../verification/army-builder-equipment-provenance.md). Historical follow-up counts above retain their checkpoint meaning. Broader option classification, integration, visual review and separate-machine LAN remain open.

## Representative workflow observation — 14 November 2026

The corrected disk/restart fixture passes 3/3 verifier processes. The existing saved-army, match-save and equipment-visual suites passed in the preceding run; their report retains the original restart-fixture failure and shutdown diagnostics. Actual 1280×800 Godot Compatibility captures show a mixed saved army reaching initial Deployment with its saved equipment and missing-visual fallback after two player-finish actions. This staged fixture is not manual interaction, deployment-interruption recovery or LAN evidence. The preparation screen still calls the already-saved Warlord a required declaration even though finish succeeds without reselection; clarify optional versus required declarations in the next UI pass. See the [full source/workflow evidence](../verification/army-builder-equipment-provenance.md) and [exact verifier commands/results](../verification/verification-results.md#army-builder-equipment-provenance-and-workflow-review--14-november-2026).

## Source classification and readiness follow-up — 14 November 2026

The [105-profile source classification batch](../verification/army-builder-equipment-classification.md) completes discovery for profiles without saved schemas: 47 additional fixed-equipment records and 58 option-bearing migrations remain. No new rules or construction choices were admitted. The [Battle Readiness UI change](battle-readiness-ui.md) resolves the misleading required-Warlord label and exposes finish before long equipment summaries; missing required Warlords still block finishing. Corrected focused UI verification passed 3/3 processes and actual Godot captures reach initial Deployment. Earlier checkpoint findings/counts remain historical. Continue the 58 migrations and schema completeness work under the [full original plan gates](army-configuration-plan-status.md); do not equate classification with implementation or final integration.

## Character/artillery migration follow-up — 14 November 2026

Execrator, Phobos Lieutenant, Terminator Chaplain and Rapier Carrier now use the shared persistent equipment adapter. All exported option groups for these four profiles have an explicit source review bound to runtime provenance and the exact saved fields. Typed schemas admit 3/2/2/4 legal packages, preserve independent copies, materialize exact local weapons and the Chaplain shield Wound, and lock duplicate preparation edits. Separate-process disk reopen, frozen snapshots, real Workshop signals and conflict recovery pass in the final 5/5-process batch. The Phobos test now distinguishes ordinary Strategic Reserves from Deep Strike without changing reserve rules. Before/after Godot captures cover all four selectors at 1280×800. The current ledger has 63 schemas, four source-option reviews, 87 fixed profiles and 54 migrations pending; 59 other schemas still need completeness review. See the [full evidence](../verification/character-artillery-saved-equipment.md). Historical checkpoint counts above are retained as history, not current scope.

## Heavy-equipment checkpoint - 14 November 2026

Redemptor, both Centurion squads and Wolf Guard Battle Leader now use the shared saved-equipment path. Canonical per-copy pricing survives preparation, including replacement surcharges and copy tiers. Source review, persistence, forced-edit rejection, actual Workshop captures and regression reports are recorded in [the heavy-equipment evidence](../verification/heavy-saved-equipment.md). This raises detected schemas to 67, with eight explicit source-option reviews; 50 migrations and 59 other schema reviews remain. Original integration gates remain open.

## Transport checkpoint - 14 November 2026

Twelve transport identities now use persistent equipment and frozen setup locks. Source review resolved missing Black Templars Multi-melta options and preserves its exclusive Impulsor pintle. Common Executioner saved prices include the source-listed Heavy Laser Destroyer surcharge; the BT sheet has its own different cost table. Shared pure inventories keep saved and legacy preparation consistent. The ledger has 79 detected schemas, 20 exact-field source reviews, 87 fixed profiles and 38 migrations pending. The other 59 schemas and original integration gates remain open. See [source review, regression reports and actual Godot captures](../verification/transport-saved-equipment.md).

## Squad-specialist checkpoint - 14 November 2026

Firestrike Servo-turrets, Infiltrators and Bladeguard now use per-model saved records, exact source caps and Sergeant-only roles. Ordinary Bladeguard show fixed pistol controls. The new exhaustive regression checks 1,818 distributions with 29 legal outcomes, separate-process persistence, actual Workshop signals and immutable matches. The ledger has 82 detected schemas, 23 explicit completeness reviews, 87 fixed profiles and 35 migrations pending; 59 other schemas and original integration gates remain open. See [source, reports and Godot evidence](../verification/squad-specialist-saved-equipment.md).

## Templar Gladiator checkpoint - 14 November 2026

The three BT Gladiators save their optional Multi-melta independently per copy. Source prices count every equipped weapon, including the Valiant fixed pair. The Add summary and copy-tier labels now include priced default equipment, also fixing the common Executioner preview. The final builder/transport/catalog batch passed 6/6; eight actual Godot captures show selectors and corrected addition arithmetic. The ledger has 85 detected schemas, 26 explicit completeness audits, 87 fixed profiles and 32 migrations pending; 59 other schemas and original integration gates remain open. See [source, exact reports and captures](../verification/templar-gladiator-saved-equipment.md).

## Aircraft/heavy transport checkpoint - 14 November 2026

Corvus Blackstar and Mastodon now save all reviewed weapon groups. The shared path distinguishes a boolean whole-pair swap from named group alternatives, fixing the legacy Corvus regression while preserving Mastodon alternatives and all fixed weapons. The new 24-package fixture checks independent copies, persistence, points and immutable snapshots. The ledger has 87 detected schemas, 28 explicit completeness reviews, 87 fixed profiles and 30 migrations pending; 59 other schemas and the original integration gates remain open. See [source, exact reports and actual Godot captures](../verification/large-transport-saved-equipment.md).

## Space Wolves squad checkpoint - 14 November 2026

Thunderwolf Cavalry and both Wulfen profiles now persist per-model equipment, source Plasma caps, shield prices and bearer/totem effects. The exhaustive matrix checks 2,868 distributions and 2,628 legal outcomes; persistence, immutable snapshots, Workshop rejection/reversion and source-price parity pass. Older source tests were corrected to assert actual canonical third-copy prices rather than first-two prices for every unit. Both final batches passed 5/5. The ledger has 90 detected schemas, 31 explicit completeness audits, 87 fixed profiles and 27 migrations pending; 59 other schemas and original integration gates remain open. See [source, exact reports and six Godot captures](../verification/space-wolves-squad-saved-equipment.md).

**14 November mixed Space Wolves equipment:** Wolf Scouts and Wolf Guard Headtakers now save equipment per miniature and copy, validate role restrictions and whole-unit caps, and apply source weapons before Deployment. Hunting Wolves retain fixed Teeth and Claws. Saved equipment is locked during readiness; live mine use and Headtaker splitting remain available. This preserves the existing partial Headtaker composition/pricing scope. The ledger now has 92 detected schemas, 33 explicit source-option reviews, 87 fixed profiles and 25 migrations pending; 59 other schemas still need completeness review. See [bounded verification and Godot captures](../verification/mixed-space-wolves-saved-equipment.md).

**14 November leader-led squad equipment:** Assault Intercessors with Jump Packs, Blood Claws and Grey Hunters now persist role-specific weapons per stable model/copy. Whole-record validation enforces ordinary Plasma limits and leader-only replacements; Grey Hunters retain Bolt Carbines. Match preparation applies saved weapons and locks repeated equipment choices, while Old Greymanes remains live. Existing construction gates are preserved. The ledger has 95 detected schemas, 36 explicit completeness audits, 87 fixed profiles and 22 migrations pending; 59 other schemas still need completeness review. See the [source/verification audit and actual Godot captures](../verification/sergeant-squad-saved-equipment.md).

**14 November specialist squad equipment:** Eradicators with Melta Rifles, Desolation Squad and Sternguard Veteran Squad now persist source-listed role equipment, whole-unit caps and Vengor surcharge. Exact secondary weapons and role melee survive preparation; repeated match setup is locked. Prior Eradicator Sergeant Multi-melta permission was corrected against the selected source and matching 11e page. Construction gates remain unchanged. The ledger has 98 detected schemas, 39 explicit completeness reviews, 87 fixed profiles and 19 migrations pending; 59 other schemas and original integration gates remain open. See [source resolution, bounded checks and real Godot captures](../verification/specialist-squad-saved-equipment.md).

**14 November saved Terminator equipment:** standard Terminators, Assault Terminators and Wolf Guard Terminators now save role-specific gear per stable model/copy. Whole-unit caps, Cyclone retained bolters and 10-point cost, shield five-point/+1-Wound effects and canonical totals are preserved before Deployment. Repeated equipment setup is locked; existing source/copy/composition gates and combat/declaration handlers are unchanged. The ledger has 101 detected schemas, 42 explicit completeness reviews, 87 fixed profiles and 16 migrations pending; 59 other schemas and original integration gates remain open. See [bounded checks and actual Godot captures](../verification/terminator-saved-equipment.md).

**14 November saved Deathwing unit/model equipment:** Deathwing Terminators and Knights now save model weapons and a separate free Watcher record per stable unit copy. Canonical keys keep identical models with different unit choices distinct; prepared squads apply saved Watchers before ability/formation initialization. Persistent gear setup is locked, while triggered Watcher activation remains live. Catalog repricing now preserves unit maps, including Reiver gear. The ledger has 103 detected schemas, 44 explicit completeness reviews, 87 fixed profiles and 14 migrations pending; 59 other schemas and original integration gates remain open. See [source, bounded verification and actual Godot captures](../verification/deathwing-saved-equipment.md).

## Deathwatch saved equipment and Workshop layout — 15 November 2026

Deathwatch Veterans and Deathwatch Terminators now persist the selected local 11e equipment per stable model. Admission validates Sergeant restrictions and whole-squad option caps, calculates the existing Storm Shield/Cyclone surcharges, and materializes the saved weapon/defense records before Deployment. Saved equipment is locked for the match while live abilities remain separate. The Workshop displays these dense model profiles as readable cards. Final targeted regression passed 11/11 verifier processes and actual 1280×800 Godot captures were inspected; Army Builder/catalog shutdown diagnostics remain documented. The refreshed 213-profile ledger now shows 105 schemas (46 reviewed), 75 fixed reviews, 12 migrations pending, 12 stale reviews, 9 unclassified profiles and 59 incomplete schema reviews. See [source and evidence](../verification/deathwatch-saved-equipment.md). Integration, full army legality and the original cross-machine gates remain open.

**15 November Vanguard Veteran saved equipment:** the Warhammer Legends and Jump Pack profiles now persist all reviewed pistol, shield and Sergeant melee choices per model. Tests cover whole-unit Plasma limits, exact local weapon packages, shield-bearer saves, source copy-price tiers, a separate-process army reopen and frozen match locks. Actual Compatibility captures confirmed the Legends row and Jump Pack card layouts; the latter makes both selectors readable under the model name. The combined offline regression passed 14/14 processes, with only the existing Army Builder and catalog cleanup diagnostics. The current ledger now reports 107 schemas (48 reviewed), 75 fixed reviews, 10 option migrations pending, 12 stale, 9 unclassified and 59 incomplete schemas. See [source, exact commands, captures and limits](../verification/vanguard-veteran-saved-equipment.md). The plan remains partial.

## Scout Bike saved equipment — 15 November 2026

The Scout Bike Legends schema is now registered in the shared model-scoped saved-equipment path. It preserves the all-model Grenade Launcher choice and restricts the eleven local Sergeant sidearm replacements to model zero, without altering 3/6-model composition, 75/150-point copy tiers, or the existing Incursion/Strike Force limits. Source completeness is bound to the current 28-sheet Legends slice manifest; the older machine-readable audit’s filtered-file hashes were not treated as matching provenance. The targeted six-suite batch passed 8/8 processes, separate-process reopen and actual Workshop captures; Army Builder/catalog cleanup diagnostics remain reported. At that checkpoint, ledger counts were 110 schemas (51 completeness reviews), 75 fixed reviews, 7 migrations, 12 stale, 9 unclassified and 59 incomplete schemas. See [bounded verification](../verification/scout-bike-saved-equipment.md).

The Indomitor Kill Team schema is registered in the shared model-scoped path with role-shaped defaults for three Aggressors, three Eradicators and four Heavy Intercessors. Saved choices enforce the two Heavy Bolter and one Multi-melta caps, preserve free Auto Boltstorm replacements and unchanged 280/300-point copy tiers, and lock repeated setup edits in prepared matches. The five-suite offline regression passed 7/7 verifier processes; both-player materialization, separate-process reopen and actual 1280×800 Workshop captures were inspected. At that checkpoint, coverage reported 112 schemas (53 source-option reviews), 75 fixed reviews, 5 migrations pending, 12 stale, 9 unclassified and 59 incomplete schemas. See [source and evidence](../verification/indomitor-saved-equipment.md); wider integration and complete army legality remain open.

The Crusader Squad schema now saves the four local 11e equipment options by stable model and copy across the source-priced 10/20-model role sequences. Validation enforces the combined Power Fist/Pyreblaster allowance of two per ten; the Hand Flamer and Neophyte Shotgun remain independently available to their eligible roles. Equipment adds no points; the Wahapedia 160/305 totals remain distinct from the official MFM v1.0 150/290 values. The six-suite offline regression passed 8/8 verifier processes; disk reopen, both-player materialization and actual 1280×800 Workshop captures were checked. Current coverage reports 113 schemas (54 source-option reviews), 75 fixed reviews, 4 migrations pending, 12 stale, 9 unclassified and 59 incomplete schemas. See [source and evidence](../verification/crusader-saved-equipment.md); bounded Crusader movement rules and complete army legality remain open.

## Necron saved equipment and source-ledger refresh — 15 November 2026

Lokhust Heavy Destroyers, Triarch Praetorians and Triarch Stalker now persist the three remaining source-listed weapon choices through the shared saved-equipment path. The Lokhust fixture mixes two Enmitic Exterminators into one model-by-model squad; Praetorians retain the linked Particle Caster/Voidblade package; Stalker stores its one-model replacement per copy. All ten Necron saved schemas now map fourteen local source-option rows. The same snapshot refresh classified eighteen no-schema profiles as fixed equipment; the two Plasmacyte option rows are model-composition counts already represented by their profiles, not equipment migrations. The current 213-profile ledger reports 120/120 schemas source-reviewed, 93 fixed-equipment classifications, and zero pending, stale or unclassified source records. The targeted regression passes separate-process list reopen, source-list edit isolation, Workshop controls and both-player materialization. It is not a visible capture or usability review. See the [source audit](../verification/saved-schema-source-review-necrons-2026-11-15.md) and [verification record](../verification/verification-results.md#necron-saved-equipment-extension-and-review-refresh--15-november-2026).

## Legacy restart and match-version recovery follow-up — 16 November 2026

The mixed saved-loadout restart fixture now also creates an older army record with flat appearance arrays and no stable copy ID. A separate Godot process opens it, migrates its model identity and inferred Auto/Manual modes, saves it, then reopens the migrated record. The match-save regression writes a valid older backup next to a checksummed primary save marked with a newer version and verifies that the reader reports the version boundary instead of silently restoring the older backup. The existing corrupted-primary fixture still verifies recovery from a valid backup.

The focused run passed **4/4 verifier processes** at `.tools/verification/20261116T021607123059Z/results.json` (SHA-256 `C72017130609DE709396E9E1EA595943F133DD5C8D8C3B22D9F661CE288C8D6E`; network disabled; legacy starter staged). `test_match_save` reports Godot shutdown RID/ObjectDB cleanup diagnostics; the restart fixture has none. This adds a bounded legacy army and match recovery case, not a complete historical schema matrix. Cross-version match migrations, interrupted asset jobs, gallery/visible usability review and separate-machine LAN remain open.

## Appearance gallery capture — 16 November 2026

A live Godot 4.7.2 Compatibility runtime capture at 1280×800 shows the Army Builder Appearance workspace with the live 3D placeholder, rotation/zoom controls, copy/model selector, search and gallery. The staged catalog deliberately has no ready local variants and includes an unavailable saved appearance; the screen keeps the fallback visible and labels preparation as optional. This confirms the empty/unavailable layout only. It does not show real ForceOrg sculpts, reliable loadout matches, a successful local selection, small-window behavior or human usability. The capture is stored in the ignored local review output at `.tools/appearance-gallery-review.png`.

## Real local appearance gallery review — 16 November 2026

The local ForceOrg catalog scan returned 32,256 entries and 395 variants for the current Intercessor profile. Of those variants, 24 had ready local files and 109 saved variant mappings were present. A live Godot 4.7.2 Compatibility capture at 1600×1400 shows one ready local Intercessor in the preview and the appearance gallery with the Automatic choice, a selected ready card and the resolver's metadata rationale. The card explicitly reports `Match: Unverified`; the preview proves that a real local asset loads, not that its sculpt matches a particular weapon or role. The screenshot is retained in ignored local review output as `.tools/appearance-gallery-real-variants-review.png` and `.tools/appearance-gallery-real-variants-browse-review.png`. The current gallery has many candidates and requires scrolling; low-resolution behavior, keyboard/controller navigation, search usability and human sculpt review remain open. No asset download was started.

## Graceful asset-preparation shutdown — 16 November 2026

The model-download regression now frees a downloader while owned partial mesh and conversion outputs exist. Its scene-exit cancellation removes those temporary files and leaves the interrupted URL unmatched by the local cache index, so no incomplete asset can be linked after reopening. This covers graceful node shutdown, not forced process termination, power loss or a real second-machine cache difference.

## Saved-match readiness restart review — 16 November 2026

A saved-army match now has separate-process recovery evidence at two points: immediately after snapshot creation while sequential readiness actions remain, and during Deployment after one unit commits. The readiness restart retains both players' frozen equipment and appearance snapshots despite later source-army edits, restores the current player's finish action, and exposes the opposing player's action only after the first player finishes. This is scripted local evidence; no mission-specific declaration matrix or live two-player usability session is claimed.

The focused offline run passed **3/3 verifier processes** at `.tools/verification/20261116T023350409991Z/results.json` (SHA-256 `01B051487CE24C98815A8E4E81C023B07120769341DBF0071AF26C0B130A7DB0`; legacy starter not staged; network disabled). Godot emitted shutdown RID/ObjectDB cleanup diagnostics after the suite reported zero failures. See the [verification record](../verification/verification-results.md#saved-match-readiness-interruption-follow-up--16-november-2026).

## Unsupported legacy match-version boundary — 16 November 2026

The match-save fixture now verifies that an older v0 primary and a future v2 primary both produce the explicit `Incompatible save version.` error without silently loading an adjacent valid v1 backup. Corrupt primary recovery remains covered. This establishes safe refusal and data preservation for unsupported versions; it does not migrate old match data. The focused run passed **3/3 verifier processes** at `.tools/verification/20261116T023648741145Z/results.json` (SHA-256 `92B12844957C11A0726296D944055B6447292CFB75457F6E56BF355D41B92C6B`). Godot reported shutdown RID/ObjectDB cleanup diagnostics after the suite passed. See the [verification record](../verification/verification-results.md#unsupported-legacy-match-version-boundary--16-november-2026).

## Unequal local visual caches — 17 November 2026

The saved-army LAN loopback now gives the host renderable local sculpts for both its saved unit appearance and a saved per-model override, while the client process has no matching local assets. The host resolves the unit and model sculpts through the local visual cascade; the client keeps the saved references but reports fallback warnings and remains playable. Both peers retain their own local appearance references, admit the same 20 units at the same points, and reach the same Deployment state. This exercises the plan's rule that local visual availability is separate from synchronized gameplay state. It remains a loopback test with synthetic local files; it does not establish a real two-machine session, network transfer of assets, or human visual review.

The final network run passed **22/22 verifier processes** at `.tools/verification/20261117T030633389741Z/results.json` (SHA-256 `BA690BEEE0D18CC0CE2D2EEA247F49A92143D3D79AD0302ECBDA542D6368062A`; network loopback enabled). An earlier run of the same extension stopped on the `save-rerolls` pair at a Deployment coordination timeout (`.tools/verification/20261117T025438598227Z/results.json`, SHA-256 `7AFB549CBB2C93D3312DDA28C390DD084A1048C7FEE74DFC2AE32FF25AA6CD64`); the verifier rerun passed, so that timeout is recorded as an observed flake rather than a confirmed pass. The Appearance/Workshop control regression was also corrected for the copy picker and passed at `.tools/verification/20261117T021219235207Z/results.json` (SHA-256 `908069BA75D9B156BB93C1C019C3A9927521023DDC562C3DC666EEB1A5A21F34`).

## Broader legacy profile fixture — 17 November 2026

The separate-process legacy restart fixture now covers a third profile, an Aggressor Squad saved with only flat appearance arrays. Reopening assigns stable copy identities, preserves the unit appearance and one per-model sculpt, and leaves the other model in Auto mode; saving and reopening again retains the same identity and values. This extends the Space Marine and Necron cases by one profile, not to every historical schema or match format.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T032028566417Z/results.json` (SHA-256 `B09C930B77BA69C077C23878BA13F4B8637AC87DAA3E4FAECFD41B616B2D5077`; network disabled).

## Legacy whole-unit equipment migration — 17 November 2026

A fourth legacy list exercises the former whole-unit Aggressor equipment record rather than only flat appearance arrays. The saved entry keeps a legacy copy identity and stores `aggressor_boltstorm` in `unit_equipment_by_copy_id`; reopening converts that value into per-model equipment for all three models, removes the obsolete whole-unit key and preserves the copy identity. Saving and reopening again keeps all three values and the absent whole-unit key. Because the migrated value is `true` rather than the `false` default, the fixture distinguishes real conversion from a dropped record. This covers one supported historical equipment format and its restart behavior, not every legacy schema or match format.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T033936088014Z/results.json` (SHA-256 `D8C44E16AFB3D5C15A4866F2AB7655E9A2C553CCF04971EF165E55C82AD1FB6D`; network disabled). `tests/test_saved_loadout_restart.gd` hashed `BFE8D9E20076175B74EB16EA848D4A64BEE518F668DF3E4E28AD3C840E4BC723`. See the [verification record](../verification/verification-results.md#legacy-whole-unit-equipment-migration--17-november-2026).

## Appearance gallery ready-only filter — 17 November 2026

The real Intercessor gallery exposed 395 candidates with only 24 ready local variants, so the gallery now orders ready looks first and provides a `Ready only` checkbox that reports the ready/total count. The filter hides unready candidates but keeps Automatic and saved choices visible; selecting or clearing it never changes equipment, points, saved appearance assignments or the draft's unsaved state. The preference now survives copy/model re-renders for the session. The card layout and search remain unchanged.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T024709935017Z/results.json` (SHA-256 `56C6D21BC9CC77CDD03E482158E3CD2DF63ECB4595F0BDF109A17B480B65111E`). The plan-related regression batch passed **10/10 processes** at `.tools/verification/20261117T024852603517Z/results.json` (SHA-256 `08A8BB6385126E877ED98CDB4251E0855CBFCE3627A62BE192090E593ADA3408`; network disabled, legacy starter staged). The new assertions use synthetic ready/pending variants and do not add real sculpt thumbnails or human usability evidence.

## Bring It Down readiness gate — 17 November 2026

The Chapter Approved readiness fixture now includes a qualifying 10+ Wound model in each mission roster: a Space Marine Impulsor (11 Wounds) and a Necron Canoptek Doomstalker (12 Wounds). Selecting `engage-bring-it-down` builds both armies and opens mission preparation for Player 1 only because both rosters contain a Bring It Down target; the fixture then resolves terrain, the role roll-off, the Attacker/Defender choice and both Battle Ready declarations to Formations, confirms both cards are registered, rechecks the target predicates and preserves the saved Warlords. A copied state whose opposing models are reduced to 9 `max_wounds` loses the target, so the predicate is checked in both directions. The first fixture attempt used an Annihilation Barge, which this snapshot gives 9 Wounds, and `Prepared.initial_state` rejected the pair with its explicit 10+ Wound requirement. This adds one mission-specific readiness combination and its full setup sequence; it does not complete the declaration matrix or verify every secondary pair.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T033518133247Z/results.json` (SHA-256 `A584C221C40BBAE177D594DF7BA9BAC56E5F9990F8AD269071C48694DF3B2B2D`; network disabled). `tests/test_battle_readiness_ui.gd` hashed `31C549EF0DF90D9E7EC563363DEEE927D59B2AC7518C1ECC12F7322D14DE88FB`. See the [verification record](../verification/verification-results.md#bring-it-down-readiness-gate--17-november-2026).

## Saved Leader attachment readiness — 17 November 2026

Each mission roster in the readiness fixture now saves one Leader attachment alongside its Warlord: the Captain joins the Intercessor Squad and the Royal Warden joins the Necron Warriors. `Prepared.initial_state` applies both saved attachments before the mission declaration, without a readiness reselection prompt. The attached models carry the leader role, both bodyguard squads report as attached, and their starting strengths become 6 and 11. The mission preparation decision and the saved Warlord mapping remain unchanged, so persistent Warlord/Leader configuration stays in the saved army while only the scenario declarations remain in readiness. This covers two named Leader links; it does not certify every Leader/Support link or a human readiness session.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T034448231863Z/results.json` (SHA-256 `63A897186E811EF70F36F795B35B53ACE2443369C0939E2ED26A0835B19ED49B`; network disabled). `tests/test_battle_readiness_ui.gd` hashed `2FF793BDCE28462BFDE9D98DDC5D737F4AAA4149F11859042BAD6CF21D53E976`. See the [verification record](../verification/verification-results.md#saved-leader-attachment-readiness--17-november-2026).

## Unsupported army-profile bank boundary — 17 November 2026

The Army Builder profile regression now covers the profile bank's version refusal path rather than only malformed JSON. It writes a structurally valid bank with a future `schema_version: 2` and a second bank with no `schema_version`, then opens each with `ArmyProfiles`. Both report `Incompatible profile format; file preserved.` The newer schema is not partially loaded, `save_list` refuses the write, `create_profile` also refuses on the unversioned bank, no `.tmp` file remains and the original bytes are unchanged. A `BuilderPanel` opened on the newer bank disables its save button and shows the same reason, so the visible path also refuses the write. This matches the match-save version boundary already recorded, but applies to the saved-army library: an unknown format is left untouched instead of being reinterpreted or upgraded in place. It does not add a migration path, numeric-schema support or a human recovery workflow for blocked libraries.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T143257508948Z/results.json` (SHA-256 `83EF2BC146D5C57CF5A7B2FC3DCAE8CE6D44D5C46CFA54066C0DBFD5BBC7E793`; network disabled). `tests/test_army_builder.gd` hashed `65CEB49BA8DAD72851B8B32DB69F9C65F6736C7A5CEEA4F2B6C5274110F4C967`. See the [verification record](../verification/verification-results.md#army-profile-bank-incompatibility-boundary--17-november-2026).

## Saved non-default mission-pair resume — 17 November 2026

The saved-army path now has a focused separate-process regression for a non-default fixed secondary pair. `tests/test_saved_mission_pair_resume.gd` starts a Chapter Approved match from the real UI with `engage-tempting-target`, checks that the initial checkpoint freezes the pair, both cards and the `terrain` stage, and resumes that save in a second Godot process. The resumed process restores the official mission, selected pair, cards, Event Companion terrain layout and pending stage. The original process then resolves terrain to `tempting-target-p1` for Player 2, resolves both opponent-ordered declarations and reaches `roles-roll`.

The option path had a related integration gap: prepared, saved and LAN mission builders passed the generic training `terrain_layout` even when a Chapter Approved mission required an Event Companion layout. They now use `_match_terrain_layout()`, which returns the selected official layout for an active official mission and the training layout otherwise. The adjacent saved-match and saved-armies suites still pass.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T150234739814Z/results.json` (SHA-256 `FCD93B398F708262E689948F7A95972620FC9A89BC4AB91B10E261B85E43BA86`; network disabled). The saved-match batch passed **5/5 verifier processes** at `.tools/verification/20261117T150602157919Z/results.json` (SHA-256 `267018C909163ECF1047AE92A18BE9EE15C4FFC1FE0F1DD90C04A08F514D8EEF`). `tests/test_saved_mission_pair_resume.gd` hashed `85C3124E5C902E44AC53E56F7B20A6F83B2173DF9FA508F5AE43CE4887837F09`. This covers one pair and two declaration stages; it does not complete the declaration matrix, verify every pair, or establish separate-machine behavior.

## Chapter Approved mission fixture repair — 17 November 2026

The all-units Chapter Approved suite had stopped at `Selected 11e layout stays in mission and peer identity`. The fixture includes the `overlord`, whose current capability status is `implemented_local_checks_pending`; current-catalog admission therefore rejected the mission roster. The test now opts into `legacy_necron_reference`, matching the fixture's existing `fresh()` data path, and supplies an explicit Event Companion layout for official missions. Synthetic scoring blocks now update per-player `primary_ids` alongside the legacy `primary_id`, and the Secure Asset block carries its per-player action list and the current generic home-objective rejection text. These are test-fixture corrections: the Overlord remains outside new current-catalog construction, and no new mission rules or current datasheet certification were added.

The focused run passed **3/3 verifier processes** at `.tools/verification/20261117T151930706939Z/results.json` (SHA-256 `497A3B18D403A52F712B0324EEFF2383B0FA84D0DF8C89D773FB2D0EB152A227`; network disabled) with `Chapter Approved checks: 0 failures`. The combined Chapter Approved, saved mission-pair, interruption, saved-armies and Army Builder batch passed **7/7 verifier processes** at `.tools/verification/20261117T152023523046Z/results.json` (SHA-256 `D76312563C774BFB75B2FFADC063FC65259FE02A04C76AB3609305C9C766AAF7`). `tests/test_chapter_approved.gd` hashed `EA6FEE9F551C0B6382C69E4105AD4ED26DEC87D7F96F0E096C387929CA085A62`. See the [verification record](../verification/verification-results.md#chapter-approved-mission-fixture-repair--17-november-2026).


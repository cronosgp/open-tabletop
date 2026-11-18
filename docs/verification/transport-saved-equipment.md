# Saved transport equipment - 14 November 2026

Twelve admitted transport identities now configure and save equipment per stable copy/model in the Army Workshop. Source-specific choices, prices and effects pass through canonical admission into the frozen match; readiness suppresses repeated equipment choices. Source-army edits do not change the saved match. Older matches without saved equipment retain the explicit preparation path.

## Source review

The verified local source is `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Final retrieval bracket: `2026-10-30T01:33:48.347556+00:00`; individual retrieval times remain in its manifest. All 22 CSV file hashes were rechecked. The selected context is the source book's common 40K datasheet and points view; Boarding Actions and other mode-specific legality are not certified. No online resolution was needed.

| Source file | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |

| Identity | Source book / datasheet | Independently enumerated packages |
|---|---|---:|
| `land-raider` | `000000139` / `000000065` | 8 |
| `land-raider-crusader` | `000000139` / `000000066` | 8 |
| `land-raider-redeemer` | `000000139` / `000002173` | 8 |
| `land-raider-excelsior` | `000000356` / `000000067` | 16 |
| `razorback` | `000000356` / `000000129` | 8 |
| `relic-razorback` | `000000356` / `000002720` | 16 |
| `repulsor` | `000000139` / `000002721` | 4 |
| `repulsor-executioner` | `000000139` / `000002722` | 2 |
| `black-templars-repulsor` | `000000162` / `000002791` | 8 |
| `black-templars-repulsor-executioner` | `000000162` / `000002790` | 4 |
| `impulsor` | `000000139` / `000002568` | 20 |
| `black-templars-impulsor` | `000000162` / `000002786` | 24 |

Book `000000139` is the shared Space Marines App; `000000162` is Black Templars App; `000000356` is Warhammer Legends. Their runtime verification slice hashes remain `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535`, `49b1df5633b88744e6b4f9ee60d0b1e3841178e2ed9bcb76c3eab021efba3f97` and `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. Extraction provenance remains distinct from verified-against provenance. Twelve exact-field-bound source-option audits were added to the registry, bringing the ledger to 79 detected schemas, 20 explicit completeness reviews, 87 fixed-equipment profiles and 38 migrations pending. The other 59 detected schemas still need completeness review.

Land Raider, Crusader and Redeemer retain their three independent optional additions. Excelsior additionally supports the Combi-weapon - Damnatus. Razorback retains the Twin Lascannon replacement and optional missile/bolter; Relic Razorback also permits Multi-melta or Twin Assault Cannon in the same exclusive primary slot. Repulsor retains two independent replacements; Executioner retains its Laser/Plasma replacement. Common Impulsor permits none or one of four systems, Storm Bolters/Fragstorm and optional Heavy Stubber. Black Templars has three systems, excludes Skytalon, and permits none or exactly one pintle: Heavy Stubber or Multi-melta.

The final local export explicitly lists a Multi-melta on all three Black Templars transport sheets, but their inherited runtime metadata previously omitted the optional weapon. The three source weapon rows match every field on the shared Land Raider's Multi-melta: range 18, attacks 2, BS 3, Strength 10, AP -3, damage D3+2, Melta 3. The runtime now reuses that exact verified weapon record and exposes each sheet's own choice and price. This resolves a missing-option inconsistency; it does not import options from the shared book into Chapter legality.

## Runtime digest continuity

Adding the three source-listed BT optional weapon records changed the shared Marine runtime digest from `9e929ea66dc5a9e0f688e727996b7b1887ec96299dad1bc555cb2058ae213fe9` to `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`. The stale-review detector initially rejected 133 old bindings, as intended. Before rebinding them, complete runtime profile exports were compared between the before stage and current root: all 185 identities match; 182 profiles are exactly unchanged, and only `additional_weapon_profiles`/`transport` differ on the three BT sheets reviewed above. Removing the new Chapter-vehicle metadata block from the current source text yields the exact baseline source text, so unrelated weapon factory code is unchanged. Book, datasheet, source snapshot and manifest identities remain unchanged. The registry rebinds those 133 reviews only after this check; it does not promote the 59 unaudited schemas or alter rules provenance.

Ignored evidence: `.tools/transport-equipment-20261114/source-continuity.json`, SHA-256 `ce5b29cc88dbe7ec692ef71333d4600f3e440325dc9746ffeaf3fc71fc35afa7`. It records both digests, exact changed identities, registry identities and input file hashes. The ignored `export_continuity.gd` emits `Marines.digest()` and the full runtime profiles; it was run against `.tools/verification/20261114T052554738295Z/project` and the root using `--headless --path <project> --script <fixture> -- <output JSON>`. Raw/derived source data remains ignored and is not distributed.

## Costs, effects and compatibility

Orbital Comms Array adds 10 points. Each of the three Black Templars Multi-meltas adds 10 points. The common-book Executioner base cost is 260/280 by copy tier, plus 10 when the Heavy Laser Destroyer is equipped: saved defaults therefore total 270/290; selecting Macro Plasma removes that additional 10. The Black Templars Executioner is 265/285 and its source lists only a Multi-melta surcharge; it must not inherit the shared-book Laser surcharge. Other reviewed equipment adds no source-listed points. Existing copy tiers, Chapter checks, Legends/event restrictions, transport capacity and geometry proxies remain unchanged.

Canonical pricing flows through roster summary, admission and prepared squad prices. A mixed 23-model army (two copies per identity except one Excelsior) totals exactly 4,290 points in the fixture, including configured/default copies. Both players' materialized squad costs sum to that total. Saved Shield Dome uses the actual 5+ invulnerable defense path; saved Orbital Comms Array uses Scouts 6. The old preparation path retains its equipment controls; paid additions/replacements check the budget before mutation and update both the army total and squad cost. Source-locked saved choices reject direct forced edits without changing state.

The new `transport_equipment.gd` helper owns pure inventory assembly, reviewed descriptors/defaults, strict record validation, source pricing and materialization for an explicit twelve-identity whitelist. It shares inventories with legacy transport setup; metadata does not enable unreviewed construction identities. Unknown fields, wrong types, extra models and excluded Chapter options fail closed. Rules and presentation remain separate.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_transport_saved_loadouts --only test_marine_impulsor_options --only test_marine_repulsor_loadouts --only test_black_templars_vehicles --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_transport_saved_loadouts --only test_marine_executioner --only test_razorback_legends --only test_land_raider_excelsior --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_transport_saved_loadouts --only test_heavy_saved_loadouts --only test_marine_transport_weapon_options --only test_implemented_catalog --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_black_templars_vehicles --only test_marine_impulsor_options --only test_transport_saved_loadouts --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_black_templars_vehicles --only test_marine_impulsor_options --only test_marine_repulsor_loadouts --only test_transport_saved_loadouts --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Result | results.json SHA-256 |
|---|---|---|
| `20261114T054510773590Z` | Failed 5/6: new fixture had a wrong catalog preload and an inferred model type; the three existing suites passed. | `b7344b60eb6c3237d290faf8d8aa07e5673cac1fbf9da35348bd57b92e8c20cf` |
| `20261114T054620566856Z` | Passed 6/6 after fixing the fixture; all source packages and source suites passed. | `1f5e0ca6d63a607428025b17e1eabce689ce7b6e2af0014056b30e96eee78f4b` |
| `20261114T054839722669Z` | Passed 6/6 with source-price/effect checks and catalog regression; catalog shutdown diagnostics. | `89cd9cedb4b340d09420ae6f59a8f93211b0578c013c001bde26da83ea757e61` |
| `20261114T055222715654Z` | Passed 5/5 with legacy paid-addition and exclusive-pintle coverage. | `154aca817212e383e9599cdcde3388ab6b815d4f8182067f0898babccd6be49d` |
| `20261114T055542565213Z` | Passed 6/6 after aligning legacy army and squad costs. | `73538a316b34e09056949a3c7883067c2d7ecee83062173b53936f8bb380b9a4` |

The Python ledger suite passed six tests after the checked digest rebindings. A direct current-root strict-identity check passed all twelve valid and 24 malformed identities using `& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/check_transport_identity.gd`; this final whitelist tightening preserves every reviewed identity.

All Godot batches disable network and stage the historical starter fixture. Catalog cleanup diagnostics are recorded separately from process success. The fixture covers all 126 independently enumerated packages and exact source weapons, strict types, illegal Chapter options, separate-process bank reopen, stable copy identities, actual Workshop signals, cost parity and budget rejection, source effects, setup suppression, non-mutating forced edits, match persistence and snapshot isolation. Existing Black Templars tests additionally exercise legacy paid additions, exclusive pintle switching and over-budget non-mutation. No deferred network check is reported as passed.

## Screen brief and actual Godot evidence

Player goal: choose each vehicle's reusable weapons and systems, understand price consequences, and save before starting a match. Existing Workshop Unit inspector, full-width Label/OptionButton pairs, gold/black theme, fonts and explicit Save footer are retained. The live total and priced option labels expose costs; one selector enforces each exclusive group. Invalid choices preserve the draft through the existing feedback path. Visual downloads remain optional and fallback miniatures visible. There are no new browser dependencies, artwork or animation. Standard focusable controls remain in use; input-device accessibility is not claimed from a scripted signal test.

Actual Godot 4.7.2 Compatibility captures at 1280x800 compare `.tools/verification/20261114T052554738295Z/project` with `.tools/verification/20261114T054839722669Z/project`. Isolated APPDATA/XDG_DATA_HOME folders are under `.tools/transport-equipment-20261114/<before|after>/profile`. Both processes exited 0; logs retain texture/RID/ObjectDB shutdown diagnostics. The same 12-unit, 12-model custom-limit army starts at 2,215 in the old baseline and 2,225 after the saved default Laser surcharge is included. Successive real selector signals and explicit saves produce a final 2,255-point configured army. The common Impulsor selects Orbital Comms Array, the Black Templars one selects Shield Dome plus Multi-melta; the remaining selectors use their final options.

| Identity | Before | After |
|---|---|---|
| `land-raider` | [Before](../../.tools/transport-equipment-20261114/before/land-raider-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/land-raider-after-1280x800.png) |
| `land-raider-crusader` | [Before](../../.tools/transport-equipment-20261114/before/land-raider-crusader-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/land-raider-crusader-after-1280x800.png) |
| `land-raider-redeemer` | [Before](../../.tools/transport-equipment-20261114/before/land-raider-redeemer-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/land-raider-redeemer-after-1280x800.png) |
| `land-raider-excelsior` | [Before](../../.tools/transport-equipment-20261114/before/land-raider-excelsior-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/land-raider-excelsior-after-1280x800.png) |
| `razorback` | [Before](../../.tools/transport-equipment-20261114/before/razorback-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/razorback-after-1280x800.png) |
| `relic-razorback` | [Before](../../.tools/transport-equipment-20261114/before/relic-razorback-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/relic-razorback-after-1280x800.png) |
| `repulsor` | [Before](../../.tools/transport-equipment-20261114/before/repulsor-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/repulsor-after-1280x800.png) |
| `repulsor-executioner` | [Before](../../.tools/transport-equipment-20261114/before/repulsor-executioner-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/repulsor-executioner-after-1280x800.png) |
| `black-templars-repulsor` | [Before](../../.tools/transport-equipment-20261114/before/black-templars-repulsor-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/black-templars-repulsor-after-1280x800.png) |
| `black-templars-repulsor-executioner` | [Before](../../.tools/transport-equipment-20261114/before/black-templars-repulsor-executioner-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/black-templars-repulsor-executioner-after-1280x800.png) |
| `impulsor` | [Before](../../.tools/transport-equipment-20261114/before/impulsor-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/impulsor-after-1280x800.png) |
| `black-templars-impulsor` | [Before](../../.tools/transport-equipment-20261114/before/black-templars-impulsor-before-1280x800.png) | [Saved controls](../../.tools/transport-equipment-20261114/after/black-templars-impulsor-after-1280x800.png) |

All 24 captures were inspected. The baseline inspector has no saved selectors for these profiles; the after captures scroll to the controls. Excelsior's first control is above the displayed viewport, while all four are covered by real signal checks. The ignored fixture `capture_equipment.gd` was run in each staged project with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_transport_equipment.gd -- <output folder> <before|after>`. No model downloads were performed. Capture evidence SHA-256: `2567f892d0c1c39880d8e18ad40b6b8ea66d5bc4ba6d6c18fec09d320b561df8`.

These are scripted runtime observations, not a human playtest, sculpt-parity review, complete deployment or separate-machine LAN session. Full army legality and unrelated source abilities remain outside this equipment migration; the [original plan gates](../project/army-configuration-plan-status.md) remain open.

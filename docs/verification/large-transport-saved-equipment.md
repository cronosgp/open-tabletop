# Saved aircraft and heavy transport equipment - 14 November 2026

Corvus Blackstar and Mastodon now save complete source-listed equipment per independent vehicle copy in the Workshop. Their grouped weapons are applied before Deployment and remain frozen for the match. This increment also fixes an existing legacy Corvus paired-launcher failure in the shared transport path.

## Source and equipment review

The authority is the verified local Wahapedia 11e export `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, specification `20260817b`. Final retrieval bracket: `2026-10-30T01:33:48.347556+00:00`; individual timestamps remain in the manifest. All 22 CSV hashes were rechecked. The context is each source book's common 40K datasheet and points view; alternate modes and full army legality are not certified. No online resolution was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

| Profile | Source book / sheet | Reviewed scope |
|---|---|---|
| Corvus Blackstar | Deathwatch App `000000035` / `000000358` | Eight packages: optional Hurricane Bolter; Twin Assault Cannon/Twin Lascannon; both Blackstar Rocket Launchers or both Stormstrike Missile Launchers. One model at 180 points; no surcharge. Auspex Array remains fixed and its Ignores Cover effect remains on every source ranged profile. |
| Mastodon | Legends `000000356` / `000001189` | Sixteen packages. The default Heavy Flamer pair can become two Heavy Bolters, Lascannons or Volkite Culverins; independently the default Lascannon pair can become two Heavy Bolters, Heavy Flamers or Volkite Culverins. One model at 540 points in every source copy tier; no equipment surcharge. Siege Melta Array, Skyreaper Battery and melee retained. |

The source explicitly replaces each pair as a whole; it does not authorize choosing an arbitrary weapon independently on each side. Every installed weapon retains a distinct source ID, including same-name pairs from different Mastodon groups. Source equipment, Chapter/event, ability and footprint boundaries remain in the [Corvus audit](../marine-corvus-blackstar.md) and [Mastodon audit](../marine-mastodon.md). Mastodon retains its Legends/event restrictions, circular footprint proxy and open passenger/source-integration limits. This equipment migration does not close those gates.

The current verified-against slice hashes are `ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109` (Deathwatch) and `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c` (Legends). Original extraction provenance is preserved. Runtime source profiles and Marine digest `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68` were not rewritten. Two exact-field equipment reviews bring the ledger to 87 detected schemas, 28 explicit completeness audits, 87 fixed profiles and 30 migrations pending. The other 59 schemas still need completeness review.

## Group distinction, persistence and legacy correction

The reviewed transport whitelist now includes these two identities. An optional boolean pair is distinct from a named multi-choice pair. The shared code previously used `group.get("choices", {}) is Dictionary`; its empty-dictionary fallback made a group with no choices list enter the enum branch. The existing Corvus regression reproduced that failure before the change. The corrected code tests for the actual choices dictionary, exposes a typed boolean pair selector when absent, and stores/materializes the boolean without converting it to a legacy command string. Enum groups remain source-listed strings.

Both saved and legacy inventory assembly share that distinction. The existing Corvus suite now passes paired replacement and restoration, along with its other source checks; Mastodon's named groups remain reversible. Saved units carry the existing transport lock, disappear from repeated setup choices and reject direct forced reconfiguration without state mutation. Existing selections without saved records retain their legacy equipment route. Later source-army edits cannot alter the saved match.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_corvus_blackstar --only test_mastodon_legends --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_large_transport_saved_loadouts --only test_corvus_blackstar --only test_mastodon_legends --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_large_transport_saved_loadouts --only test_transport_saved_loadouts --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

| Report under `.tools/verification/` | Result | results.json SHA-256 |
|---|---|---|
| `20261114T144224574024Z` | Failed 3/4 before the fix: existing Corvus paired-launcher regression reproduced the defect; Mastodon passed. No cleanup diagnostics. | `c037a553b18187c5a32963b89d5096cbf4aa0a7d9a6aa2d96a7a18c8b81c6ac2` |
| `20261114T144611572207Z` | Failed 6/7: both existing source suites, prior transports and catalog passed; the new fixture assigned an untyped conditional array to Array[String] and its comparison was invalid. Catalog cleanup diagnostics. | `303742d865a3e424ade9d014b44608822d758c3f008eb93f04eba095b1091c27` |
| `20261114T144856361862Z` | Passed 5/5 after correcting the new fixture's array type; final new/prior transport and catalog checks passed. Catalog cleanup diagnostics. | `e50d8966472d0808d9c0dd1577e8bf475b73e51a121a117668ec708a9ea3fc9b` |

The Python equipment-ledger suite passed six tests. Failed batches remain failed evidence; their passing components do not turn them into passing batches.

The new fixture independently enumerates all 24 packages, compares exact pair IDs and every source weapon field, verifies fixed weapons/melee and Corvus Auspex keywords, rejects wrong types/extra fields/models, reopens the saved bank in a second Godot process, checks stable configured/default copies, materializes both players, suppresses repeated equipment and rejects forced group changes. Its four-copy mixed army totals 1,440 in the builder, admission and each player's materialized squad sum. Match save/reload remains identical after changing the source army. Real Workshop signals verify every group and preserve the other copy and zero surcharge.

All Godot batches disable network and stage the historical starter fixture. Cleanup diagnostics are separate from process success; no deferred network check is reported as passed. These checks do not establish all combat, transport, geometry or full army-legality behavior.

## Screen brief and actual Godot captures

Player goal: choose the intended weapon pair on a reusable vehicle, see the fixed-versus-replaced group and save it before starting a match. The existing Unit inspector, full-width native Label/OptionButton controls, gold/black theme, copy picker and Save footer are retained. Corvus has a keep/use pair control alongside its two other groups; Mastodon has two independent four-choice group selectors. Point totals remain unchanged because the source lists no surcharge. Invalid saved types fail closed and the existing source-limit feedback preserves the draft. Optional model downloads do not block saving, and fallback miniatures remain available. No new browser dependencies, artwork or animation were added. Scripted signals do not prove keyboard/gamepad coverage.

Actual Godot 4.7.2 Compatibility at 1280x800 compares `.tools/verification/20261114T143332223037Z/project` with `.tools/verification/20261114T144611572207Z/project`. Isolated APPDATA/XDG_DATA_HOME folders are under `.tools/large-transport-equipment-20261114/<before|after>/profile`. The same one-Corvus/one-Mastodon army remains at 720/2000 points. The after fixture uses real selectors and explicit Save to choose Hurricane Bolter, Twin Lascannon and Stormstrike pair on Corvus, plus both Volkite pairs on Mastodon. All four captures were inspected. Both processes exited 0 with texture/RID/ObjectDB shutdown diagnostics retained; clean render shutdown is not claimed.

| Profile | Before | After |
|---|---|---|
| Corvus | [Before](../../.tools/large-transport-equipment-20261114/before/corvus-blackstar-before-1280x800.png) | [Saved three-group configuration](../../.tools/large-transport-equipment-20261114/after/corvus-blackstar-after-1280x800.png) |
| Mastodon | [Before](../../.tools/large-transport-equipment-20261114/before/mastodon-before-1280x800.png) | [Independent saved pairs](../../.tools/large-transport-equipment-20261114/after/mastodon-after-1280x800.png) |

The ignored fixture `capture_equipment.gd` was run with `--rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_large_transport.gd -- <output folder> <before|after>`. No model downloads occurred. Capture evidence SHA-256: `1b13dcd46739eb7cfb74f937437c516e6a00e938f7531b5e70c9f6309eaac6ab`.

The captures are scripted runtime observations, not mockups, human playtests, sculpt review, full deployment or separate-machine LAN evidence. The [original plan gates](../project/army-configuration-plan-status.md) remain open.

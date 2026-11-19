# Army Builder equipment provenance — 14 November 2026

## Result and boundary

The 29 previously stale fixed-equipment reviews now bind explicitly to the runtime profiles' existing `source_verified_against_*` metadata. Original extraction metadata remains unchanged. This resolves an equipment-review provenance gap; it does not add controls, change rules, admit construction choices or certify entire datasheets.

At this provenance checkpoint, the refreshed ledger contained 204 admitted profiles: 59 have detected saved-equipment fields, 40 have accepted fixed-equipment reviews, none have stale equipment reviews, and 105 remain unclassified. The additional detected schema is the existing Rhino Primaris path in the working tree; this provenance change did not implement it. Detected fields do not establish complete option coverage.

All 29 reconciled records belong to Space Marines App book `000000139`, edition `11`. Neither snapshot's options table contains a row for these identities. Their default loadout, book, faction and descriptive text are unchanged. Existing per-sheet audits remain the evidence for the fixed loadouts; this comparison does not re-audit every weapon or ability. The `Datasheets.csv` column `legend` is descriptive text, not the Warhammer Legends classification; source-book identity retains that boundary.

## Verified local sources

| Property | Earlier audited extraction | Runtime verification reference |
|---|---|---|
| Directory | `.tools/wahapedia/11e/space-marines/20261021T130623Z/` | `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/` |
| Snapshot | `20261021T130623Z` | `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z` |
| Retrieval | `2026-10-21T19:46:58Z` | Final timestamp bracket `2026-10-30T01:33:48.347556+00:00`; individual retrievals remain in the manifest |
| Export revision | `2026-10-21 16:06:23 GMT+3` | `2026-10-28T23:48:19+03:00` |
| Manifest SHA-256 | `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Verified files | 23: 22 CSVs and the specification workbook | 22 CSVs |
| `Datasheets_options.csv` SHA-256 | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` | Same |

The current shared-book runtime slice-manifest binding is `735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535`. This increment verifies raw export manifests and equipment continuity; it does not regenerate or certify the entire slice. No online page resolution was needed. Raw exports and the generated comparison report remain ignored and are not distribution inputs.

## Acceptance and reproduction

The exporter retains extraction and subsequent verification provenance. The registry's `source_review_basis` selects one pair. A review must match book, datasheet, runtime digest, snapshot and manifest; verification-based reviews also require the existing runtime slice binding. Snapshot/manifest pairs cannot be mixed. Unknown bases or missing bindings remain stale.

Run from the repository root:

```powershell
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json
python tools/audit_army_builder_equipment_reviews.py --runtime-audit .tools/army-builder-coverage.json --previous .tools/wahapedia/11e/space-marines/20261021T130623Z --current .tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z --output .tools/army-builder-equipment-provenance-20261114.json
python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The exporter returned 204 profiles. The source audit returned 29 verified fixed-equipment continuity records. The three Python tests passed, including negative cases for mismatched provenance, missing verification bindings, changed loadouts, new options, wrong book edition and corrupt bytes. The ignored report `.tools/army-builder-equipment-provenance-20261114.json` has SHA-256 `97c9713e0b3e71357f1c47cee784715c61dfc289034711e808ba18c4f13cf7bc` and records each verified source filename and SHA-256; the registry links individual identities to this record and earlier audits.

## Observed Godot workflow

A scripted fixture was rendered in actual Godot 4.7.2 Compatibility mode at 1280×800, using the verifier's isolated project and a separate APPDATA profile. Both sides selected the same 365/1000-point saved army: a Captain Warlord, three Sanguinary Guard with one saved Inferno Pistol and two Rhinos with different saved missile selections. One Guard retained an unavailable manual visual. Optional model downloads were disabled through the match setting; built-in fallback miniatures were used.

| Actual capture | Observed result |
|---|---|
| [Workshop](../../.tools/army-builder-review-20261114/captures/review-workshop-1280x800.png) | Saved list loaded; selected Guard shows its Inferno Pistol and unavailable assigned visual with fallback. Inspector content continues below the scroll viewport. |
| [Readiness](../../.tools/army-builder-review-20261114/captures/review-readiness-1280x800.png) | Both lists are locally ready at 365/1000 points; one saved look is missing on each side and fallback availability is explicit. |
| [Preparation](../../.tools/army-builder-review-20261114/captures/review-preparation-1280x800.png) | Saved loadouts show one equipped and one default Rhino and two Angelus Boltguns/one Inferno Pistol. Required checks are clear. |
| [Deployment](../../.tools/army-builder-review-20261114/captures/review-deployment-1280x800.png) | After the two player-finish actions, both armies are prepared; the first unit awaits placement and built-in miniatures remain visible. No weapons or Warlord were reselected. |

All four captures were inspected. The fixture exited 0. The render process reported texture/RID/ObjectDB shutdown diagnostics, retained in `.tools/army-builder-review-20261114/capture-complete.log`; this is not a clean-shutdown claim. Capture identities and hashes are in `.tools/army-builder-review-20261114/capture-evidence.json`, SHA-256 `100453bd598ad2b6fe8d9cef52a3f4f17c9f3d9c5c46beb21ee86754b7332f71`. The ignored fixture is `.tools/army-builder-review-20261114/capture_builder_flow.gd`.

The capture invocation used the isolated staged project `.tools/verification/20261114T030652693724Z/project`, APPDATA/XDG_DATA_HOME `.tools/army-builder-review-20261114/profile-complete`, and these Godot arguments:

```text
--path <isolated staged project> --rendering-method gl_compatibility --resolution 1280x800 --script res://.tools/capture_builder_flow.gd
```

This is a staged runtime review, not manual input coverage or a human playtest. It covers reaching initial Deployment, not placing every unit or interrupting/restarting deployment. Other sizes, gallery interaction, conversion recovery and separate-machine caches remain unobserved here. An earlier capture attempt checked launch before handling the preparation path; its log is retained separately and is not counted as acceptance evidence.

At this capture checkpoint, one visible follow-up remained: preparation says **Required checks clear** while still presenting **Choose a required declaration / Warlord** for the already-saved Captain. Both player-finish actions succeeded without reselecting it, so the remaining issue is misleading presentation. The subsequent [Battle Readiness UI increment](../project/battle-readiness-ui.md) resolved this presentation issue and includes new actual captures.

## Remaining work

The subsequent [source classification batch](army-builder-equipment-classification.md) reviewed those 105 profiles: 47 are fixed and 58 have options awaiting migration. Review the 59 detected schemas for option completeness. Continue interruption/recovery and human interaction review; broader legacy fixtures, physical sculpt parity and separate-machine LAN remain open gates. See the [implementation review](../project/army-builder-implementation-review.md) and [verification history](verification-results.md).

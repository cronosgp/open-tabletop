# Wahapedia e11 snapshot importer

The [definitive source policy](rules-source-policy.md) is now backed by `tools/import_wahapedia.py`, a standard-library Python importer for all 22 CSV files linked by the export specification. It is an offline content/audit tool, not a runtime network dependency or an executable rule interpreter.

## Capture and inspect

From the repository root, with Python 3.10+:

```text
python tools/import_wahapedia.py --output .tools/wahapedia-e11-NEW
```

Choose a new directory each time. The tool refuses overwrite, captures the update timestamp before/after download, requires HTTPS e11 redirects, caps response size and records per-file URLs, retrieval times, byte counts and SHA-256. Raw CSVs and the resulting Marine identity index stay in ignored local directories. No downloaded rules dataset is added to the distributed game.

`manifest.json` records completion, row counts, structural errors and parser notes. `capture-status.json` distinguishes a complete capture from an interrupted one. A partial capture retains raw files and progress but does not get a completed manifest. Exit 1 means a failed capture or structural validation errors; a completed capture with errors remains available for diagnosis and must not be promoted to a playable pack.

Offline reprocessing:

```text
python tools/import_wahapedia.py --input-dir .tools/wahapedia-e11-OLD/raw --output .tools/wahapedia-e11-REVIEWED
```

Offline processing does not claim a new live freshness check. If a parent snapshot manifest is present, input file hashes are verified and its manifest digest is recorded. The export timestamp uses its documented GMT+3 timezone. String IDs retain leading zeroes; HTML is kept as inert source data.

The importer accepts either the `raw/` directory from one of its own captures or the root of a downloaded snapshot containing the 22 CSVs and `manifest.json`. For a direct source snapshot, it verifies each CSV against the manifest's per-file hash and records the source manifest digest. Export timestamps are compared as timezone-aware instants, so equivalent GMT+3 and UTC offsets do not fail solely because their strings differ.

## Export-specific details

Some live descriptions contain unquoted physical newlines. The parser joins continuation fragments only while the record lacks its required field count, preserves newlines and reports each continuation. Missing columns, overlong rows, unexpected trailing columns and incomplete terminal records fail parsing.

Some ability IDs are reused across factions with the same definition. They are tracked by ID/faction, with identical shared definitions checked; conflicting definitions remain errors. Identical repeated relational rows are retained and noted. Some historical weapon rows lack their ordinal: those are indexed using datasheet/name/type/dice/profile-line instead and the missing order is reported, without inventing it. Remaining ambiguous duplicates and missing references fail structural validation.

Marine discovery uses the faction-page identity and source-book records, preserving chapters, Legends and Forge World as separate books. An e11 URL alone does not establish the source edition. `edition_11_candidate` is a source boundary check, not matched-play or implementation certification; every indexed entry remains `playable: false`.

## Compare the runtime Marine catalogue

Export actual Godot runtime data without launching a match:

```text
godot --headless --path . --script tools/export_reference_marines.gd -- --output .tools/marine-runtime-NEW.json
python tools/compare_wahapedia_marines.py --snapshot .tools/wahapedia-e11-REVIEWED --runtime-profiles .tools/marine-runtime-NEW.json --output .tools/marine-comparison-NEW.json
```

The exporter includes every identity in the current runtime catalog and retains the manually enriched option profiles for the original 93 identities. The comparator verifies raw-file hashes, compares source model characteristics and runtime weapon-mode values, and reports keyword, ability, default-equipment, composition and cost evidence. It matches source model types against role-specific runtime characteristics, so repeated model instances and source/runtime display-name differences do not require a one-to-one row count. Torrent's printed Ballistic Skill is treated as unused because Torrent automatically hits. Runtime datasheet ID, source-book ID, name and e11 edition are checked against the selected row.

For a Chapter context, use `--chapter black-templars`, `--chapter blood-angels`, `--chapter dark-angels`, `--chapter deathwatch` or `--chapter space-wolves`; this only selects keyword-audit context and does not grant runtime Chapter rules. A Chapter slice can compare only declared subject datasheets, not identity-only Leader endpoints. Missing or ambiguous definitions remain explicit. The comparator's exit 0 means an audit report was produced, not that its contents certify rules.

**Full-catalog audit, refreshed 29 October 2026:** the exporter produced 160 runtime profiles (93 with manually enriched option profiles). The timestamp-bracketed 22-file export yielded zero numeric or runtime-source-identity differences across all 160. The latest comparison passes **159/160** bounded fixed-data gates; default loadouts, weapon traits, keyword context and fixed/optional wargear costs pass for all 160. Decimus Kill Team is the sole remaining mismatch: its source composition rows require at least six models, while its runtime profile interprets a five-model composition. That five-model size is blocked from construction; only the composition-consistent ten-model/210-point option is selectable. During reconciliation, the comparator learned to project Wargear-granted weapon traits and Pistol handling from source labels, option profiles now retain the Wolf Scouts Instigator Carbine target restriction, and the Deathwatch Veterans Damnatus profile no longer receives the Purgatus-only Melta 2 trait. The 22-file source snapshot is hash-verified but structurally invalid with 68 global findings, so this run is not certification. Subject slices can isolate marine records while retaining the parent findings; never describe those findings as repaired or passed. Evidence: `.tools/marine-runtime-marine-closeout-20261029.json` (SHA-256 `c42eb732b4018cc0594574ca8caba9b7af59ee805c2e438a3dbc8e469194c336`) and `.tools/marine-compare-marine-closeout-20261029.json` (SHA-256 `3287ac36b147f52ed44a865f4290332176575eeb8232313ba63b44d99dabe9dc`), against export revision timestamp `2026-10-28T23:48:19+03:00`.

## First actual capture: 18 October 2026

The export timestamp was **16 October 2026, 21:03:46 GMT+3**, unchanged across the live download. All 22 files were captured, including 1,512 datasheet rows. The Space Marines faction index contains **193 records**: 85 from the shared Space Marines book, plus chapter, Legends, Forge World and unresolved-source records. 190 pass the e11 source boundary; this count includes optional books and is not a playable-unit total.

After accounting for the observed shared IDs, repeated identical relations and missing historical weapon ordinals, validation still reports **68 errors**: 60 dangling datasheet references, six dangling detachment references and two datasheets missing source/faction identity. The captured global dataset is therefore **structurally invalid** and remains audit-only. No broken reference was guessed or silently repaired.

The six runtime profiles have **zero numeric/identity differences** in the implemented comparison and no unresolved ability-ID lookups. Five profiles have matching ordinary keyword sets. Terminators export DEATHWING while runtime contains a TERMINATOR SQUAD identity tag; chapter applicability must be resolved against page context before changing either. Weapon-trait and executable-rule completeness are not established by this comparison.

Reproducible local evidence: `.tools/wahapedia-e11-snapshot-v2/manifest.json` for the original live capture, `.tools/wahapedia-e11-20261018-reviewed/manifest.json` for reprocessing, and `.tools/wahapedia-marines-comparison-final.json` for comparison. Committed [audit metadata](wahapedia-import-audit.json) preserves hashes, counts and concise findings without bundling the source prose. The runtime profile exporter completed successfully; all **19 Python tests passed**, including ten new importer/comparison tests. No new graphical or multiplayer validation was needed for these offline tools.

Follow-up delivered: the [shared Marine source slice](wahapedia-marines-slice.md) isolates all 85 shared-book subjects with zero structural errors, generates a joined catalog and resolves the Terminator keyword audit through revision-scoped page context. The 68 global errors remain preserved. Next: weapon-trait/loadout/composition/cost checks and executable effect/interaction validation. Full-match and general army-legality flags remain false.

## Newer export reviewed locally: 21 October 2026

The locally downloaded export reports **21 October 2026, 16:06:23 GMT+3**. Offline processing recognized 1,513 datasheets and 193 Space Marines faction-page candidates. Structural validation again found 68 errors: 60 dangling datasheet references, six dangling detachment references and two datasheets missing faction/source identity. The importer's audit manifest records the raw snapshot manifest digest and all per-file hashes.

A source-bounded slice for the shared Space Marines book (`Source.csv` ID `000000139`) was extracted from this capture. It contains **85 subject sheets** and 41 identity-only Leader endpoints, has zero slice validation errors, and remains `playable: false` and `full_match_certified: false`. The parent export's 68 global errors remain recorded; slicing does not repair or hide them. Raw capture, review output and slice stay local in ignored `.tools/` paths.

Chapter source slices use `tools/slice_wahapedia.py` to accelerate per-sheet review without copying the full export into a capture-specific `raw/` directory. The tool accepts the verified export root directly, pins all parent CSV hashes, includes the selected datasheet's linked source rows and records external Leader targets as identity-only dependencies. Example for Belial: `python tools/slice_wahapedia.py --snapshot .tools/wahapedia/11e/space-marines/20261021T130623Z --source-id 000000023 --datasheet-id 000000219 --output .tools/wahapedia/11e/space-marine-chapter-slices/belial-20261028`. Its audit slice is structurally valid with no slice errors; the parent's 68 unrelated global validation errors are retained and are not reported as passed. The direct-export layout regression passed in `test_direct_local_export_layout_can_feed_a_verified_audit_slice`.

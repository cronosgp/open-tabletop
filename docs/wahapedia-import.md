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

The importer accepts either the `raw/` directory from one of its own captures or the root of a downloaded snapshot containing the 22 CSVs and `manifest.json`. For a direct source snapshot, it verifies each CSV against the manifest's per-file hash and records the source manifest digest.

## Export-specific details

Some live descriptions contain unquoted physical newlines. The parser joins continuation fragments only while the record lacks its required field count, preserves newlines and reports each continuation. Missing columns, overlong rows, unexpected trailing columns and incomplete terminal records fail parsing.

Some ability IDs are reused across factions with the same definition. They are tracked by ID/faction, with identical shared definitions checked; conflicting definitions remain errors. Identical repeated relational rows are retained and noted. Some historical weapon rows lack their ordinal: those are indexed using datasheet/name/type/dice/profile-line instead and the missing order is reported, without inventing it. Remaining ambiguous duplicates and missing references fail structural validation.

Marine discovery uses the faction-page identity and source-book records, preserving chapters, Legends and Forge World as separate books. An e11 URL alone does not establish the source edition. `edition_11_candidate` is a source boundary check, not matched-play or implementation certification; every indexed entry remains `playable: false`.

## Compare the six experimental profiles

Export actual Godot runtime data without launching a match:

```text
godot --headless --path . --script tools/export_reference_marines.gd -- --output .tools/marine-runtime-NEW.json
python tools/compare_wahapedia_marines.py --snapshot .tools/wahapedia-e11-REVIEWED --runtime-profiles .tools/marine-runtime-NEW.json --output .tools/marine-comparison-NEW.json
```

The comparison verifies all raw-file hashes, matches exactly one e11 datasheet by its canonical page URL, compares every exported model's characteristics and each runtime weapon mode's numeric values, and lists keyword/ability/cost evidence. Missing or ambiguous definitions remain explicit. The comparator's exit 0 means an audit report was produced, not that its contents certify rules. Keyword conditions, weapon traits, optional equipment, points applicability and executable abilities still need scope validation.

## First actual capture: 18 October 2026

The export timestamp was **16 October 2026, 21:03:46 GMT+3**, unchanged across the live download. All 22 files were captured, including 1,512 datasheet rows. The Space Marines faction index contains **193 records**: 85 from the shared Space Marines book, plus chapter, Legends, Forge World and unresolved-source records. 190 pass the e11 source boundary; this count includes optional books and is not a playable-unit total.

After accounting for the observed shared IDs, repeated identical relations and missing historical weapon ordinals, validation still reports **68 errors**: 60 dangling datasheet references, six dangling detachment references and two datasheets missing source/faction identity. The captured global dataset is therefore **structurally invalid** and remains audit-only. No broken reference was guessed or silently repaired.

The six runtime profiles have **zero numeric/identity differences** in the implemented comparison and no unresolved ability-ID lookups. Five profiles have matching ordinary keyword sets. Terminators export DEATHWING while runtime contains a TERMINATOR SQUAD identity tag; chapter applicability must be resolved against page context before changing either. Weapon-trait and executable-rule completeness are not established by this comparison.

Reproducible local evidence: `.tools/wahapedia-e11-snapshot-v2/manifest.json` for the original live capture, `.tools/wahapedia-e11-20261018-reviewed/manifest.json` for reprocessing, and `.tools/wahapedia-marines-comparison-final.json` for comparison. Committed [audit metadata](wahapedia-import-audit.json) preserves hashes, counts and concise findings without bundling the source prose. The runtime profile exporter completed successfully; all **19 Python tests passed**, including ten new importer/comparison tests. No new graphical or multiplayer validation was needed for these offline tools.

Follow-up delivered: the [shared Marine source slice](wahapedia-marines-slice.md) isolates all 85 shared-book subjects with zero structural errors, generates a joined catalog and resolves the Terminator keyword audit through revision-scoped page context. The 68 global errors remain preserved. Next: weapon-trait/loadout/composition/cost checks and executable effect/interaction validation. Full-match and general army-legality flags remain false.

## Newer export reviewed locally: 21 October 2026

The locally downloaded export reports **21 October 2026, 16:06:23 GMT+3**. Offline processing recognized 1,513 datasheets and 193 Space Marines faction-page candidates. Structural validation again found 68 errors: 60 dangling datasheet references, six dangling detachment references and two datasheets missing faction/source identity. The importer's audit manifest records the raw snapshot manifest digest and all per-file hashes.

A source-bounded slice for the shared Space Marines book (`Source.csv` ID `000000139`) was extracted from this capture. It contains **85 subject sheets** and 41 identity-only Leader endpoints, has zero slice validation errors, and remains `playable: false` and `full_match_certified: false`. The parent export's 68 global errors remain recorded; slicing does not repair or hide them. Raw capture, review output and slice stay local in ignored `.tools/` paths.

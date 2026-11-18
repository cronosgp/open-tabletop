# Army Builder source equipment classification — 14 November 2026

The no-schema option migration queue is now empty. Talonstrike Kill Team completed the final saved-equipment migration; see its [source and verification record](talonstrike-saved-equipment.md), alongside the [Fortis](fortis-saved-equipment.md) and [Spectrus](spectrus-saved-equipment.md) reports. The historical counts and source-classification procedure below describe the 14 November checkpoint.

## Result

The 105 previously unclassified admitted profiles were checked against their selected local runtime source references. There are 47 additional profiles with a nonempty default loadout and no exported equipment-option rows (35 Marines and 12 Necrons), and 58 Marine profiles with source-listed options requiring saved-equipment migration.

At the classification checkpoint, the 204-profile ledger contained 59 detected saved schemas, 87 source-reviewed fixed-equipment profiles and 58 option-bearing profiles awaiting migration. The subsequent [character/artillery migration](character-artillery-saved-equipment.md) adds four schemas and explicit completeness reviews; use the current ledger for live totals. No profile without a detected saved schema remains unclassified. At that checkpoint, 59 schemas still required per-profile source-option completeness review; later profile audits reduce the current queue. This inventory does not certify complete equipment implementation, abilities, full datasheets or army legality. Existing admission gates and legacy drafts are unchanged.

## Source identity and review method

Marine reviews bind to the runtime's existing verified-against snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. It is local at `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`. The final retrieval bracket is `2026-10-30T01:33:48.347556+00:00`; per-file retrievals remain in the manifest.

Necron reviews bind to the runtime extraction snapshot `20261031T053336Z`, local at `.tools/wahapedia/11e/necrons/20261031T053336Z/`, export revision `2026-10-30T22:19:16+03:00`, parent manifest SHA-256 `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`. Its final retrieval bracket is `2026-10-31T05:34:28.395103+00:00`; individual file retrievals remain in the manifest. The Necrons source book is App `000000029`, version `1.2`.

All 22 CSV hashes in each manifest were checked. Every reviewed datasheet must exist in the selected export, have a nonempty loadout and match the runtime's book ID; the source book must be edition 11. Book type/version and source scope remain separate, including Chapter books and Warhammer Legends. The registry preserves the specific book and datasheet IDs. The common `Datasheets_options.csv` hash is `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` in both exports. Every filename/hash and the reviewed identities are recorded in the ignored report.

The registry's `export_equipment_classification` method distinguishes this direct table review from earlier per-datasheet audits and the 29-profile continuity review. Source option descriptions are not converted into controls or legality constraints. A missing snapshot, hash mismatch, absent default, mismatched book/edition or incomplete runtime binding stops the batch before updating the registry. Existing manually audited reviews are preserved. Re-running refreshes this generated classification batch; it does not duplicate identities.

## Reproduce

The raw snapshots must already exist locally; no tool downloads them.

```powershell
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json
python tools/review_army_builder_equipment_catalog.py --runtime-audit .tools/army-builder-coverage.json --snapshot .tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z --snapshot .tools/wahapedia/11e/necrons/20261031T053336Z --reviewed-on 2026-11-14 --output .tools/army-builder-equipment-classification-current.json --update-registry
python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The original checkpoint batch returned **105 profiles: 47 fixed, 58 with options**. Reproduction against a later runtime refreshes only still-generated classification records; explicit source-audited migrated schemas are preserved and the count may decrease. The report `.tools/army-builder-equipment-classification-20261114.json` has SHA-256 `9f192f16ddb39c14e75bc4b1c4c16abe24e9800c2ca12fa1e0c3742ccd0762b3`. All four focused Python tests passed, including unknown source, absent defaults, changed options, corrupt bytes, wrong edition and stale/mixed runtime provenance. No raw tables or third-party option descriptions were committed or packaged.

## Next implementation work

The original batch found 58 option-bearing profiles. At the earlier 14 November checkpoint, 46 schema completeness audits and stale/unclassified source records remained. The 15 November refresh below closes that source-review work for the current catalog. The original plan's broader persistence, interruption, asset-recovery, visible interaction, usability and separate-machine LAN acceptance checks remain open.

## Necron source-ledger refresh — 15 November 2026

The expanded Necrons runtime catalog changed its faction-level digest while retaining the same verified source snapshot. The seven existing equipment-schema reviews were rebound to that digest, and three new schemas were audited against the same raw export. Twelve stale no-schema classifications and six previously unclassified Necron profiles were checked against the local App v1.2 tables.

The inventory has two option rows for Skorpekh and Ophydian Destroyers that describe one size-scaled Plasmacyte composition count per three models. Their runtime profiles already implement those counts; they are not weapon or equipment loadout choices. The coverage exporter now carries typed source-option kinds, and the classifier treats these rows as composition-only only when the typed metadata count exactly matches the exported source rows. If any row lacks a recognized kind, classification remains conservative and the options stay in the migration queue. A focused Python regression covers both the composition-only and mixed equipment/composition cases.

After this refresh the 213-profile ledger reports 120 detected equipment schemas with 120 exact-field source reviews, 93 fixed-equipment classifications, zero equipment migrations pending, zero stale reviews and zero unclassified profiles. This closes the source-review queue for the current catalog; the plan's remaining work is integration, recovery, visual review, usability and unequal-cache LAN verification.

# Army Builder coverage inventory

Generated from the consolidated local construction catalog. This is schema discovery and source-review tracking, not rules certification or a count of fully migrated units.

Admitted profiles: **223**. Profiles with detected saved equipment fields: **123**. Of those, schemas with an explicit source-option completeness review: **123**. Profiles source-reviewed as fixed equipment with no options: **100**. Profiles with source-reviewed equipment options awaiting migration: **0**. Profiles with a stale or unbound source review: **0**. Profiles with no fixed/option source classification yet: **0**.

| Faction | Admitted profiles |
|---|---:|
| Necrons | 38 |
| Space Marines | 185 |

The [TSV ledger](army-builder-coverage.tsv) records every admitted identity, source book/datasheet identifiers where present, runtime source digest, detected fields, equipment review classification and separate verification gates. The [source review registry](army-builder-source-review.tsv) classifies a profile only when its book, datasheet, snapshot, manifest and runtime profile digest still match. Each review explicitly uses its extraction provenance or the separately exported `source_verified_against_*` provenance; snapshot/manifest pairs are never mixed. Verified-against reviews require a runtime slice-manifest binding and a separate local equipment-source audit; they do not rewrite original extraction metadata. `equipment_migration_required` means the selected local source lists equipment options but no saved schema was detected; these options remain implementation work. `source_classification_required` means no source classification is recorded; it does not mean a migration is required. `source_review_stale` means a review record exists but its provenance does not match the current runtime profile. `saved_schema_source_reviewed` means an explicit equipment-source audit matches the runtime provenance and exact saved-field set; runtime verification gates remain separate. `saved_schema_review_stale` means that audit no longer matches. `saved_schema_source_review_required` means fields were detected but does not prove that they cover all source choices. `not_audited` means the exporter did not check that verification gate.

Excluded catalog entries/reasons: **14** (including blocked compositions; not necessarily distinct datasheets). Exclusions remain in the ignored JSON audit and are never added as construction choices.

## Reproduce

```powershell
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json
python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project
```

The ignored JSON contains runtime audit metadata only. This tool does not fetch online catalogs or alter source provenance. See the [implementation review](army-builder-implementation-review.md) for the remaining integration gates.

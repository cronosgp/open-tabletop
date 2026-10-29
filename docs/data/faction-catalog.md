# Faction catalog admission

Army construction exposes only profiles published by the consolidated local runtime catalog. The base Space Marines Codex (`000000139`) is closed locally at 85/85 source-bounded datasheets; Chapter-book supplements are tracked separately. Its current Space Marine inventory has 161 runtime profiles across 85 shared-book identities and all 76 Chapter-book identities. The 161-identity inventory has 158 complete local datasheet scopes and no missing Chapter profile. Wolf Guard Headtakers is selectable in the two Wahapedia-compatible mixed formations; the MFM Headtakers-only configurations fail the selected source composition, and other source-permitted role mixes without explicit MFM prices remain blocked. Crusader Squad remains partial, and Decimus Kill Team's five-model/110-point row is blocked while its ten-model profile remains available. Sword Brethren construction allows only the source-priced 4-, 5-, 9- and 10-model sizes. These catalog and profile counts do not imply complete rules coverage, full faction legality, or match certification. See [Chapter coverage](../space-marines-coverage.md#chapter-book-expansion-status), [current support](../project/support-matrix.md) and the [Space Marine roadmap](../project/roadmap.md#chapter-book-supplement-status).

## Admission controls

- [`implemented_army_catalog.gd`](../../scripts/implemented_army_catalog.gd) derives choices from the runtime admission inventory and applies its publication gate.
- [`capabilities.gd`](../../scripts/edition_11/capabilities.gd), local profile definitions, and roster validation provide the corresponding behavior and scope gates.
- Pending-validation and historical/unreconciled profiles stay out of new choices. Existing affected lists remain labeled legacy drafts.
- A blocked unit must retain an explicit reason. Do not infer support from a catalog row or match a unit by name alone.

## Source and data pipeline

The project's source decision is Wahapedia's `/wh40k11ed/` rules and faction pages, with the local Data Export as the sole accepted source for extracted datasheet facts. The repository has importer, slicing, comparison, and fixed-data audit tools; they consume local snapshots for offline preparation. Record snapshot identity, retrieval time, exported filenames, and SHA-256 hashes. Keep raw and derived third-party data local and out of Git and releases. See [source assessment](source-assessment.md) and [importer guide](../wahapedia-import.md).

OpenHammer and 40kdc adapters remain isolated legacy/experimental workflows. They do not feed current construction choices and are not fallback sources for missing Wahapedia data. Official Games Workshop publications may provide context but do not gate admission or override the selected Wahapedia revision.

## Admission sequence

1. Identify the profile in a verified local Wahapedia 11e snapshot and record its faction, source identity, snapshot, and file/hash provenance.
2. Preserve the extracted record and normalize it without inventing values or silently dropping unsupported fields.
3. Record the source edition, book/chapter, mode, and revision for the claimed scope.
4. Enumerate the compositions, options, keywords, effects, triggers, timings, limits, durations, and interactions included in that scope.
5. Implement the declared behavior and explicit unsupported gates, with focused checks for supported and rejected cases.
6. Align capability metadata, roster admission, topic documentation, support matrix, and verification claims.

Catalog browsing, prices, and passing tests alone do not establish complete rules support or legal army construction.

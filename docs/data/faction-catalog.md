# Faction catalog admission

> **Current source boundary:** The game's catalog UI still has legacy OpenHammer lookup behavior. It is not an accepted source of current datasheet facts. A new profile must be grounded in a verified local [Wahapedia e11 Data Export snapshot](source-assessment.md); if the extract is unavailable, defer admission.

## Current app behavior

- **Listas** can display catalog records for browsing and local planning. Provider presence, points, composition, or variant selection does not establish current rules accuracy or official list legality.
- Match admission is controlled by [`capabilities.gd`](../../scripts/edition_11/capabilities.gd), the local fixed-profile definitions, and the applicable roster validator.
- A blocked unit must remain visibly blocked with its reason; never infer support from a catalog flag or match a unit by name alone.
- The online OpenHammer integration and imported starter packs are legacy/experimental. The local-export ingestion migration has not been implemented in this checkout.

## Admission sequence for a datasheet

1. Locate the record in the verified local Wahapedia 11e export and record its faction, source identity, snapshot ID, and file/hash provenance.
2. Preserve the original extracted record. Normalize into the project format without silently inventing values or discarding unsupported fields.
3. Check current rules effects, official points, and errata against applicable Games Workshop publications; record version boundaries and conflicts. Do not merge incompatible editions or sources silently.
4. Enumerate every required model composition, weapon/equipment option, keyword, ability trigger, target, timing, use limit, duration, and interaction for the claimed scope.
5. Implement the complete admitted scope and explicit unsupported gates. Add tests for both the rule and illegal/unsupported cases.
6. Update capability metadata, roster validation, documentation, and the support matrix together. Being selectable is not equivalent to being fully implemented or certified.

## Local data contract

Until a migration tool is available, the intended raw snapshot location is:

```text
.tools/wahapedia/11e/<faction>/<snapshot-id>/
```

Each snapshot needs a manifest with the exact export URL, edition, retrieval time, identity, filenames, SHA-256 hashes, and parsing notes. Keep raw and derived third-party data ignored by Git and out of releases. See the [source policy](source-assessment.md) for conflict handling and migration requirements.

## Scope and non-goals

- Do not use OpenHammer, 40kdc-data, a provider API, or previous-edition profiles as authoritative inputs for current e11 datasheets.
- Do not admit every catalog entry in one batch or enable a profile before its declared behavior is implemented and tested.
- Shared faction and chapter-specific content remain separate scopes; chapter substitutions, supplements, and other publications need their own source review and capability boundaries.
- Catalog browsing, budget presets, and passing tests are not a complete army-construction validator.

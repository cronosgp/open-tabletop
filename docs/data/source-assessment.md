# Rules and datasheet source policy

## Required rules baseline

The target is official **Warhammer 40,000 11th edition**. Use [Wahapedia's e11 Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and corresponding `/wh40k11ed/` faction pages as the project's reference, and cross-check current rule effects and updates against official Games Workshop publications. Record source dates, publication/version boundaries, discrepancies, and unresolved interpretations.

Do not substitute 10th-edition or superseded Codex rules, combine incompatible versions, or treat historical training profiles as current-rule certification. Historical profiles must be migrated or explicitly isolated. See [AGENTS.md](../../AGENTS.md) for the rules that apply to every agent contribution.

## Authoritative datasheet input

The project's sole accepted source for local datasheet extraction is the Wahapedia 11th-edition [Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/) page. For purposes of the local data pipeline, a **verified local export snapshot** is the source of record for extracted datasheet fields. OpenHammer, 40kdc-data, memory, search results, and previous-edition packs are not substitutes.

This is a project source policy, not a claim that Wahapedia is an official Games Workshop publication or that an extracted record is automatically rules-correct, complete, licensed for redistribution, implemented, or validated. Cross-check rules effects, Codex/faction changes, FAQs, errata, and update boundaries with official Games Workshop sources. If those sources and the local export appear to disagree, preserve the source/version details, mark the issue unresolved, and do not silently reconcile or certify the affected behavior.

## Local snapshot layout

Keep raw exports unchanged and local-only in the ignored `.tools/` directory:

```text
.tools/
└── wahapedia/
    └── 11e/
        └── <faction>/
            └── <snapshot-id>/
                ├── manifest.json
                └── <files returned by the export>
```

The manifest should identify the schema version, edition, faction, exact Data Export URL, snapshot identity, retrieval date/time, each exported filename and its SHA-256 hash, and any scope or parsing notes. Hash the original bytes. Never rewrite, merge, or overwrite a source snapshot in place; create a new snapshot identity when source content changes. Derived normalized/runtime data must retain the originating snapshot identity and hashes so a reviewer can trace each field back to its source.

Raw extracts and derived third-party content must not be committed, bundled, or sent to peers. `data/` is for project-owned data and schemas; any future local derived packs remain ignored and are not independent sources of truth. A hash establishes file identity, not correctness, trust, or permission to redistribute.

## Current checkout and migration boundary

The current checkout has **no Wahapedia export snapshot or Wahapedia ingestion tool**. The tracked `data/starter.lock.json` and existing 40kdc/OpenHammer import tools describe legacy experimental workflows. They may support isolated historical exercises, but they are not authoritative for current e11 datasheet facts and cannot establish rules support. Do not run them as a fallback when the required local export is absent.

The ingestion migration is separate work. It must:

1. Read only a verified local snapshot and fail clearly for a missing export, mismatched hash, unknown schema, or unsupported field.
2. Preserve raw files, provenance, snapshot identity, and unsupported source fields instead of silently dropping them.
3. Generate local derived data without querying remote services during a match.
4. Include targeted normalization and traceability tests without checking third-party source data into Git.
5. Keep `data/`, runtime allowlists, capabilities, support documentation, and verification claims aligned with the newly migrated source and implemented scope.

## Current e11 evidence

The [checked Combat Doctrines/Gladius scope](../rules/combat-doctrines.md), [Awakened Dynasty scope](../rules/awakened-dynasty.md), [unit abilities](../rules/current-unit-abilities.md), and [selected mission](../rules/chapter-approved-mission.md) document the reference and official update boundaries used for those increments. They certify only the expressly documented profiles and interactions; they do not establish complete faction coverage or general army legality.

The [11e attack lab](11e-starter.md) and [data-pack format](data-packs.md) still describe legacy input tooling. Their continued presence does not change the source policy above.

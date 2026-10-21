# Rules and datasheet source policy

## Required rules baseline

The target is **Warhammer 40,000 11th edition**. By user decision, [Wahapedia's e11 Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), corresponding `/wh40k11ed/` faction pages and Data Export are the definitive project references. Check the edition, book/chapter, game mode and current revision, and record the selected source/version with each implementation scope.

Official Games Workshop publications may provide context but are not an admission prerequisite and do not override the selected Wahapedia source. Do not mix editions or superseded profiles. Preserve unresolved ambiguities as explicit blockers rather than silently merging incompatible versions.

Do not substitute 10th-edition or superseded Codex rules, combine incompatible versions, or treat historical training profiles as current-rule certification. Historical profiles must be migrated or explicitly isolated. See [AGENTS.md](../../AGENTS.md) for the rules that apply to every agent contribution.

## Authoritative datasheet input

The project's sole accepted source for local datasheet extraction is the Wahapedia 11th-edition [Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/) page. For purposes of the local data pipeline, a **verified local export snapshot** is the source of record for extracted datasheet fields. OpenHammer, 40kdc-data, memory, search results, and previous-edition packs are not substitutes.

This is a project source policy, not a claim that Wahapedia is an official Games Workshop publication or that an extracted record is automatically complete, licensed for redistribution, implemented, or validated. Use the chosen Wahapedia edition/page/export and its recorded revision as the rules/data baseline. Do not replace it with another source's interpretation. Record ambiguities within that selected source and keep unsupported scope blocked.

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

The repository contains Wahapedia import, slice, comparison and fixed-data tooling; its outputs and source audits are local preparation inputs. The consolidated runtime construction catalog currently exposes all 85 shared-book Space Marine identities from the selected local e11 source. This publication scope does not certify every identity's complete rules interactions, full faction coverage or general army legality. The tracked starter lock and OpenHammer/40kdc adapters are legacy workflows, not authoritative e11 data and not fallback sources.

Future changes to the ingestion pipeline must:

1. Read only a verified local snapshot and fail clearly for a missing export, mismatched hash, unknown schema, or unsupported field.
2. Preserve raw files, provenance, snapshot identity, and unsupported source fields instead of silently dropping them.
3. Generate local derived data without querying remote services during a match.
4. Include targeted normalization and traceability tests without checking third-party source data into Git.
5. Keep `data/`, runtime allowlists, capabilities, support documentation, and verification claims aligned with the newly migrated source and implemented scope.

## Current e11 evidence

The [checked Combat Doctrines/Gladius scope](../rules/combat-doctrines.md), [Awakened Dynasty scope](../rules/awakened-dynasty.md), [unit abilities](../rules/current-unit-abilities.md), and [selected mission](../rules/chapter-approved-mission.md) document the selected Wahapedia source revisions and the expressly bounded profiles/interactions for those increments. They do not establish complete faction coverage or general army legality.

The [11e attack lab](11e-starter.md) and [data-pack format](data-packs.md) still describe legacy input tooling. Their continued presence does not change the source policy above.

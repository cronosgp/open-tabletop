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

The repository contains Wahapedia import, slice, comparison and fixed-data tooling; its outputs and source audits are local preparation inputs. The consolidated runtime construction catalog contains all 161 standard Space Marine profiles and eighteen separately labelled Legends profiles (179 total). The standard inventory has 159 complete local scopes and two partial scopes. Wolf Guard Headtakers is admitted for the two Wahapedia-compatible mixed formations priced by MFM; other source-permitted role mixes without explicit MFM costs remain blocked, and exact oval-base geometry remains unresolved. Decimus Kill Team is locally complete for the Wahapedia 10-model/210-point configuration; current MFM v1.0 lists 190, and the impossible 5-model/110-point row cannot satisfy its six-model minimum. Crusader Squad remains partial for route/coherency and uses Wahapedia 160/305 versus MFM 150/290; its roster points are not MFM-event certified. Whirlwind is admitted as Warhammer Legends for casual play with source-priced 175/195 copy tiers; competitive-event use needs organiser permission, its 60 mm footprint is a proxy, and live-page/event-pack rechecks are deferred. Stormhawk Interceptor and Stormtalon Gunship are locally admitted with their 155- and 165-point source profiles, complete weapon options, respective Interceptor and Strafing Run abilities, and labelled 60 mm proxies for their 120 x 92 mm ovals. Cerberus is also admitted at 270 points with both independent optional weapon groups, Atomantic Arc-reactor, Deadly Demise D6 and a labelled 60 mm proxy for the source footprint `Use model`. See the [Cerberus sheet audit](../marine-cerberus.md). The Dreadnought is admitted at 135 points with its exact 60 mm base, every weapon profile, the linked Missile Launcher/Crushing Feet replacement and Wisdom of the Ancients; see the [Dreadnought sheet audit](../marine-dreadnought.md). Falchion Legends is also admitted at 420 points per copy with all source-listed weapon choices and its four rules; the source says `Use model`, so its 60 mm footprint is a labelled proxy. See the [Falchion sheet audit](../marine-falchion.md). This is a local catalog status, not a claim of final network/page validation, every Chapter interaction, complete faction rules or general army legality. Forge World, Legends and alternate modes remain separate inventories; the 30 October full page-index counts and separate admission boundary are recorded in the [extended Marine inventory](space-marine-extended-inventory.md). The tracked starter lock and OpenHammer/40kdc adapters are legacy workflows, not authoritative e11 data and not fallback sources.

Future changes to the ingestion pipeline must:

1. Read only a verified local snapshot and fail clearly for a missing export, mismatched hash, unknown schema, or unsupported field.
2. Preserve raw files, provenance, snapshot identity, and unsupported source fields instead of silently dropping them.
3. Generate local derived data without querying remote services during a match.
4. Include targeted normalization and traceability tests without checking third-party source data into Git.
5. Keep `data/`, runtime allowlists, capabilities, support documentation, and verification claims aligned with the newly migrated source and implemented scope.

## Current e11 evidence

The [checked Combat Doctrines/Gladius scope](../rules/combat-doctrines.md), [Awakened Dynasty scope](../rules/awakened-dynasty.md), [unit abilities](../rules/current-unit-abilities.md), and [selected mission](../rules/chapter-approved-mission.md) document the selected Wahapedia source revisions and the expressly bounded profiles/interactions for those increments. They do not establish complete faction coverage or general army legality.

The [11e attack lab](11e-starter.md) and [data-pack format](data-packs.md) still describe legacy input tooling. Their continued presence does not change the source policy above.

## Optional in-game ability reference

The match-profile inspector may show read-only ability descriptions from a verified local Wahapedia 11e export. These descriptions are source text for review; the adjacent **Implemented scope** remains project-authored metadata. Displaying source text does not add an ability to the rules engine, establish that its effect is implemented, or certify a datasheet.

The packaged game looks first in `user://rules/wahapedia/11e/space-marines/<snapshot-id>/`. A local development checkout may use `.tools/wahapedia/11e/space-marines/<snapshot-id>/` when there is no user installation. A user installation takes precedence. When several snapshots are present, timestamp identities sort in UTC order; other folder names use the manifest's `retrieved_at_utc` value. Every timestamp-shaped folder name is calendar-validated even when timestamp and non-timestamp names are mixed. If the user path is not a folder, its newest snapshot is invalid, or the reader cannot determine the newest snapshot, the inspector reports the error and does not hide it by falling back to the project copy.

The installed snapshot keeps the export's unmodified filenames beside `manifest.json`. The manifest records schema 1, provider, edition, Space Marines context, source page, matching snapshot ID, retrieval time, export-specification revision, and each exported filename and SHA-256. The reader verifies every listed file before parsing the three ability tables; errors identify the filename when a listed file is missing or its hash differs. Space Marines datasheet links must use the HTTPS Wahapedia 11e faction path and contain one valid slug; off-source, nested or malformed links fail the source instead of being reduced to a plausible-looking identity. Ability relations are checked against all datasheet identities in the same export, including other factions. Multiline cells retain their physical line breaks, including empty lines within the cell. If a relation refers to an unknown datasheet ID, the reader skips that row only after recording it in a visible incomplete-export warning; resolved per-datasheet entries remain available, and the warning says they may omit abilities. Missing or changed files, malformed tables or relation identities, unsupported metadata and required ability entries without a resolvable name or description fail the whole source and expose no partial list.

For an exported pack, copy a snapshot that has already been verified against the official Data Export into the `user://` path above, preserving its snapshot folder name, manifest and exact files. Place the whole `<snapshot-id>` folder beneath the parent; copying the files directly into the parent is reported as an invalid installation. A verified file manifest does not guarantee that every cross-file relation resolves; unresolved datasheet relations are shown with the incomplete-export warning described above. The inspector's **Open local reference folder** action opens the parent directory for this manual copy. If the operating system cannot open it, **Copy local reference folder path** provides the path for manual navigation. After installation, select **Reload local reference** in the inspector; the game makes no network request. Do not edit the CSVs or manifest, rename the snapshot, put the export in a match save, or share it through a synced match folder. With no valid installation, the inspector states that reference text is unavailable and continues to show project-authored implemented scope. When collapsed, the foldout label retains the source status as incomplete, unavailable or error. Raw exports and derived copies remain local-only and are excluded from Git, the PCK and session synchronization.

The current project-local snapshot `20261021T130623Z` has no missing or hash-mismatched manifest files, but record 5947 in `Datasheets_abilities.csv` references datasheet ID `000004150`, which is absent from `Datasheets.csv`. The reader now displays entries for identities that resolve and shows an incomplete-export warning naming the orphan row; the unresolved row is omitted and no ability completeness is implied. No raw file was edited or refreshed. This records the export’s cross-file inconsistency, not a claim that Wahapedia has corrected or rechecked it.

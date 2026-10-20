# Definitive rules source

User decision, 18 October 2026: **Wahapedia's `/wh40k11ed/` content is the definitive rules source for this project.** This replaces the previous requirement for separate Games Workshop Codex/app/errata confirmation. Wahapedia is the project's canonical source; this designation does not describe it as a Games Workshop publication.

## Source precedence

1. [Wahapedia e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), current faction/datasheet pages and their linked e11 exports define the selected rules.
2. [Wahapedia data export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/) is the preferred structured ingestion source. Pages supply context and any content absent from the exported tables.
3. OpenHammer and older snapshots are discovery/migration inputs only. They cannot override Wahapedia. GW material may be retained as historical context; obtaining a separate official locator is no longer a support gate.

Keep edition, source book, chapter, Legends status and game mode separate even within an e11 URL. Where a page and CSV disagree, record both retrievals and hold only the affected record for reconciliation. Do not fill gaps from earlier editions or silently merge incompatible profiles.

## Export inspection

The export page advertises linked CSV tables rather than an on-demand API. Its linked [specification workbook](https://wahapedia.ru/wh40k11ed/Export%20Data%20Specs.xlsx?v=20260817b) was downloaded and inspected on 18 October 2026. It specifies UTF-8, pipe-delimited CSV, string IDs unique within a table, HTML in descriptive fields, and textual boolean values. Preserve IDs as strings and treat HTML as data, never executable content.

The specification links 22 distinct CSV files under `/wh40k11ed/`, including factions/source books, datasheets, models, weapons, options, composition, costs, abilities, stratagems, enhancements, detachments, chapter DP, Leader pairings and relational tables. `Last_update.csv` supplies an export update timestamp documented as GMT+3. A file link in the specification is not proof that its live contents are complete or current; this increment inspected the schema, not the full CSV dataset.

Ingestion should capture requested/final URL, retrieval time, export update timestamp, raw-file SHA-256 and edition path. Check update timestamps before and after a multi-file download to detect a changing export. Validate headers, unique keys and relationships, then filter Space Marines through faction and source identities, not display names alone. Keep raw downloaded data in an ignored local snapshot. Use a repeatable parser and compare the six experimental profiles against the selected snapshot before promotion.

## What remains required for playable support

Removing the official-source gate does not implement a rule. A profile still needs complete characteristics, weapons/options, points/composition, keyword and attachment data; executable effects with correct timing/targets/duration; and meaningful interaction validation for the declared scope. Core and detachment dependencies must work together. Do not switch full-match or army-legality flags merely because the source policy changed.

Historical documents and metadata describing `official_locator_pending` record the earlier policy. They are superseded as admission requirements by this document. Existing runtime certification booleans remain false until implementation and scope checks are complete; they must not be relabeled as GW certification when eventually enabled.

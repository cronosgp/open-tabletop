# Rules sources and admission policy

## Current policy

User decision, 18 October 2026, reaffirmed 20 October 2026: **the Wahapedia `/wh40k11ed/` export and pages are the definitive project source for current-edition datasheet data and rules**, including profile values, composition, options, keywords, points, applicability and effects. This is a project source designation; it does not describe Wahapedia as a Games Workshop publication.

**An official Games Workshop cross-check is not required and is not an admission gate.** GW publications may be noted as optional context, but they cannot replace or override the selected Wahapedia e11 source or delay support solely because a GW locator is unavailable.

Preserve edition, book/chapter, game mode and revision boundaries. If the selected Wahapedia sources conflict with each other, record both, isolate the affected rule/data and leave it pending reconciliation; do not synthesize missing text or combine incompatible revisions.

## Source workflow

1. Use the [Wahapedia e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), the corresponding `/wh40k11ed/` faction and datasheet pages, and the [e11 data export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/). Verify edition, source book, chapter, game mode and current revision before claiming a profile or rule is in scope.
2. Prefer the structured Wahapedia export for datasheet data. The [export specification workbook](https://wahapedia.ru/wh40k11ed/Export%20Data%20Specs.xlsx?v=20260817b) specifies UTF-8, pipe-delimited CSV, string IDs, HTML descriptions and textual booleans. Preserve IDs as strings and treat HTML as data, never executable content.
3. GW cross-checks are optional context only. Do not report them as required or use their absence as the reason to block an otherwise locally reconciled Wahapedia e11 rule.
4. OpenHammer and older snapshots are discovery/migration inputs only. They cannot fill gaps or override Wahapedia. Do not implement an earlier-edition or superseded mechanic as a substitute.
5. Where a Wahapedia page and export disagree, preserve both retrievals and hold the affected record for reconciliation. Do not synthesize unavailable rule text.

The export specification advertises 22 distinct CSV tables, including faction/source books, datasheets, models, weapons, options, composition, costs, abilities, stratagems, enhancements, detachments, chapter DP and Leader pairings. `Last_update.csv` supplies the export timestamp documented as GMT+3. A linked file is not proof that its contents are complete or current. For multi-file ingestion, capture requested/final URLs, retrieval time, update marker, raw-file SHA-256 and edition path; compare update timestamps before and after download; validate headers, unique keys and relationships; then select by faction and source identity, not display name alone. Keep raw exports in ignored local snapshots and use a repeatable parser.

## Requirements for playable support

A source match alone does not implement a rule. Support requires complete in-scope profile data, all legal options, executable effects with correct timing/targets/duration, and local interaction validation. Keep affected capabilities unsupported when a Wahapedia source, implementation or local validation gate is pending. Do not infer full datasheet coverage, army legality or full-match certification from passing tests or identity mapping.

## Superseded policy history

An intermediate policy revision that required official GW cross-checks before supporting rules is **superseded** by the user's reaffirmation on 20 October 2026. The Wahapedia e11 authority decision remains in force for both datasheet data and rules. Earlier notes that say GW confirmation was optional or not required are historical policy metadata; the current decision is that GW is not a gate.

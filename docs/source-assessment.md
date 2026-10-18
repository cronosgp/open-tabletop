Current A3 increment (17 October 2026): [checked Incursion rosters](roster-validation.md) use official live MFM 1.6 points for ten fixed profiles, 2/4 repetition limits, the sole-3DP detachment exception and mandatory Warlord/Support declarations. Two 290-point starters are available under the 1,000-point ceiling. Complete official-match certification, broader equipment/model counts and remaining required detachment/core content are still pending.

Mission reconciliation, 17 October 2026: [the selected CA 2026-27 profile](chapter-approved-mission.md) records current e11 primary/fixed-secondary/map references and official Event Companion v1.3 cross-checks, including PDF checksum and the distinction between custom terrain and official recommended layouts. Historical 2025-26 material under the same e11 site path is not used as a current mission substitute.

Current source reconciliation (17 October 2026): [ten-unit abilities](current-unit-abilities.md#sources-checked-on-17-october-2026) uses the current e11 datasheets and Appendix, with official 14 October Marine errata and September Necron updates checked. Current regular Captain, Intercessor and Lieutenant abilities replace historical roadmap names in the new option. Printed base Codex coverage and reference-point limitations remain explicit.

Space Marines expansion, 17 October 2026: the [Space Marines catalog](space-marines-catalog.md) records six OpenHammer-to-current-reference comparisons, 67 partial datasheet identity candidates, and the source-surface census. Its machine-readable ledger lists 15 shared Codex detachment candidates and 20 chapter candidates from the current e11 reference. All 35 candidates now have first-pass rule, restriction, enhancement and stratagem summaries. The chapter slice contains 61 enhancements and 94 stratagems; shared Codex records contain 32 enhancements and 48 stratagems. GW's 15 September Codex-era preview says Angelic Inheritors is 2 DP, while the October reference says 3 DP. GW's 20 June launch pack/indexed MFM also say 3 DP, but those are pre-Codex evidence. The GW downloads hub identifies its live MFM as updated 14 October; automated retrieval of the live MFM page returns 403, and the search-indexed page is an older snapshot, so the current official value remains unverified. The public downloads search in this check found no post-Codex Space Marines faction-pack PDF or full Codex errata locator. This is an unresolved source boundary, not a resolved choice of either DP value. GW preview articles corroborate selected rule direction and mechanics but not every rule or card. Deathwatch Support's preview confirms army legality conditions, including the 500-point cap and Warlord restriction. Official full-text locators, chapter and shared DP/disposition reconciliation, and detailed effect/source checks remain incomplete. GW announced 85 shared Codex datasheets; the e11 consolidated Wahapedia index reports 191 ADEPTUS ASTARTES sheets across its broader filters; OpenHammer returns 132 records in its shared Space Marines bucket. These counts have different boundaries and are not proof of playable coverage. The OpenHammer sample includes stale or invalid fields, so its imports are provisional candidates and never direct runtime data. The current workflow uses it for fast bulk discovery, then checks only the slice selected for implementation against the current e11 reference and applicable GW updates. The catalog does not certify additional profiles or complete Marine army legality; only the separately checked fixed-roster path uses current MFM 1.6 prices.

First structured Space Marines rule pass, 17 October 2026: [space-marines-rule-definitions.json](space-marines-rule-definitions.json) defines Combat Doctrines and the unit/attachment rules used by six current fixed Marine profiles, plus definition-only abilities from Bladeguard, Hellblaster, Infernus, Company Heroes, Redemptor Dreadnought, Apothecary Biologis, Desolation, Eliminator, Eradicator and Incursor, with Hazard Rolls/HAZARDOUS, Lethal Hits, secured-objective and Hidden/Detection Range core dependencies. These fifteen additional sheets are not runtime-admitted. The definitions record Wahapedia e11 page references, timing, eligibility, limits, duration and unresolved interactions; they are design/audit inputs, not official certification. Exact current GW Codex/core/errata locators remain pending. This pass also caught a Tactical Squad page whose 11e marker conflicts with its T4/S4/Oath content, and a Sternguard result that is a Black Templars variant. Neither was promoted into shared current rules. This pass also found an older Eradicator page marked Faction Pack v1.2; its Oath of Moment and profile fields are excluded in favor of the current Eradicator Squad with Melta Rifles page. The Incursor Haywire Mine remains on its current datasheet but is explicitly removed by the Pilum Strike Team Boarding Actions adaptation. The current GW downloads hub reports the MFM updated 14 October but its linked page returned 403; official preview material does not reproduce these individual ability effects.

40k.app follow-up, 17 October 2026: its [Angelic Inheritors page](https://www.40k.app/factions/blood-angels/detachments/angelic-inheritors) also shows 3 DP, but lists Priority Assets without Purge the Foe, which the current Wahapedia reference lists. This third-party corroboration is useful for detecting the disposition mismatch; it does not supersede the newer GW preview or establish the live MFM value. The ledger now records the three-way cost evidence and the disposition discrepancy without resolving either for gameplay.

# External source assessment

## Required rules baseline

The user requires official **Warhammer 40,000 11th edition**, using [Wahapedia e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and corresponding `/wh40k11ed/` faction pages as the consultation reference. Cross-check current effects and publication/version boundaries against official Games Workshop material. Never replace a missing current rule with an earlier-edition mechanic or silently combine superseded and current Codex rules. This requirement is also recorded in [AGENTS.md](../AGENTS.md).

### Source workflow checked 17 October 2026

Use OpenHammer `/v1/11e` for fast bulk discovery and provisional unit/profile/weapon imports. Use its provider IDs, edition, query URL, retrieval time and content digest to make each snapshot reproducible. Its current README describes monthly BSData synchronization and 1,368 records across 35 factions, while the live service returned 1,348 in the 17 October check; the provider summary and endpoint did not agree. Its records also lack reliable per-record publication provenance, so an `11e` tag is a candidate label, not current-rule certification.

Use Wahapedia `/wh40k11ed/` pages as the fast human-readable e11 rules reference when a catalog item is selected for implementation. Check the applicable current GW Codex, faction pack, FAQ/errata and points source for that implementation slice. This is a just-in-time gate: do not block broad catalog ingestion or unrelated engine work while the entire faction is being reviewed. A source disagreement stays recorded and the affected mechanic remains provisional or unsupported until resolved. The official [Warhammer 40,000 app listing](https://apps.apple.com/us/app/warhammer-40-000-the-app/id6443503982?platform=ipad) describes current points/rules and Codex-unlocked datasheets; GW's [new-edition app announcement](https://www.warhammer-community.com/en-gb/articles/8wi6x7nq/new40k-points-apps-and-updates-incoming/) describes live points and rules integration. No public OpenHammer-equivalent data API for the official app has been identified, so use it as a manual official check rather than an assumed import interface.

Do not use 10e data to fill gaps in the e11 catalog. The four sampled 40k.app Marine datasheets still carry older values/mechanics; retain those concrete differences as discovery evidence, not catalog input. Keep publisher, book, chapter, edition, game mode and revision distinct when providers disagree.

The current [Combat Doctrines/Gladius implementation](combat-doctrines.md) follows that baseline. Historical Oath and earlier reference datasheets/abilities are not certification of the latest Codex; auditing and migrating those profiles is required before the Track A target can be considered legal. Existing historical save compatibility does not make those profiles part of current rules.

On 17 October 2026, [Awakened Dynasty Command Protocols and current Overlord pairings](awakened-dynasty.md) were checked against the e11 Necron pages and September official faction updates. The hit effect and pre-deployment declaration are implemented; attached Reanimation is now supported for the admitted pairings. Core e11 19/19.04 retains one unit and its combined strength, including a surviving leader's ability; Appendix 02.02.04 supplies living-wound priority before non-Character revival. Earlier separation assumptions are superseded.

Inspected 2026-10-15. This is an integration assessment, not confirmation of complete or official rules compliance. No upstream code or game dataset has been incorporated into the runtime. An independent local pack format and optional OpenHammer import tool have since been implemented; see [data-packs.md](data-packs.md). Imported snapshots are reference-only and excluded from version control by default.

Update 2026-10-16: the [army planner](army-builder.md) now uses OpenHammer directly for explicit catalog refreshes and a local offline cache. No upstream software or downloaded catalog is bundled, and remote data is not used during match resolution. The previous paragraph describes the earlier import-only integration.

## Recommended use

### 40kdc-data: data model and ability representation

[Repository](https://github.com/wn-mitch/40kdc-data)

Useful candidate for the long-term interchange model, especially the structured split between triggers, conditions, effects, scope, and links to phases/interactions. It is a community data/schema project, not an official rules source or a complete rules engine for our Godot game. Its README still describes `main` as migrating to 11e, with 10e preserved on an archive branch. The migration plan explicitly discusses porting 10e records into `11th/pre-launch-provisional` based on previewed continuity. That is useful as an omission-finding queue, but it cannot certify a current Marine rule under this project's rules policy; every admitted profile and ability must independently match current e11 sources and updates. I have not confirmed complete current Space Marine coverage in its public 11e data.

Concrete schema features inspected:

- [Unit schema](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/core/unit.schema.json): linked weapon/ability IDs, game version, base size, model count, multiple profiles, and provisional-points flag. Base size can be absent/null and representative rather than sufficient for every model.
- [Ability schema](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/enrichment/ability-dsl/ability.schema.json): source digest, version, supersession, trigger, scope, and effect. A digest identifies content; it does not establish release ordering or correctness.
- [Terrain layout](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/core/terrain-layout.schema.json): footprints, heights, parent areas, rotation, board dimensions, and objective metadata. Map its 2D coordinates explicitly to Godot X/Z and convert inches consistently.
- [11e migration plan](https://github.com/wn-mitch/40kdc-data/blob/main/11e-migration.md): useful for tracking schema changes and source boundaries, but its provisional 10e-seeding strategy is not an acceptable path to current-rule certification here.

License boundaries are separate: [schemas CC0](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-SCHEMAS), [enrichment CC BY 4.0](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-DATA), and [tools MIT plus public-deployment attribution](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-TOOLS). If we reuse enrichment records, preserve CC BY attribution. If we ship their data package in a publicly accessible application, follow its visible-credit requirement. For this Godot project, the lowest-coupling path is to borrow the schema ideas and implement a small project-owned data contract; avoid taking the multi-language runtime package wholesale. Do not label the entire repository simply MIT.

### Warhammer Oracle: reference tooling and calculation examples

[Repository](https://github.com/gregario/warhammer-oracle)

Provides edition-aware lookups, phase guidance, and curated rules. The README identifies BSData as a data source and distinguishes its MIT server code from game content.

Inspected [wound-calc.ts](https://github.com/gregario/warhammer-oracle/blob/main/src/lib/wound-calc.ts): returns expected hits, wounds, damage, and probabilities. This is useful for a future attack preview or selected mathematical test cases, not a replacement for resolving individual attacks and casualties.

Inspected [game-flow.ts](https://github.com/gregario/warhammer-oracle/blob/main/src/tools/game-flow.ts): formats phase guidance for the caller. It does not enforce a match state machine. Any adapted calculation must be checked against the selected edition and preserve its license notice.

### OpenHammer REST API: bulk discovery and provisional import

[API](https://openhammer-api-production.up.railway.app/) · [OpenAPI specification](https://openhammer-api-production.up.railway.app/openapi.json)

The root lists `10e` and `11e`; the 17 October live `11e` stats response reported 1,348 entries and 35 factions, while the README now claims 1,368. This count mismatch is itself provenance that a snapshot should retain. Neither count establishes completeness.

The API exposes paginated unit lookup (`limit`/`offset`), lookup by ID, faction filters and bulk queries. The Unit schema includes stats, weapons, points, composition, keywords and ability descriptions; it lacks reliable per-record publication provenance, rules-update revision and base geometry. Its monthly-sync claim does not remove the need for a selected-slice source check. Earlier live Intercessor, Assault Intercessor, Terminator and Character candidates contained superseded profiles/abilities or invalid composition bounds; see the [Space Marines catalog](space-marines-catalog.md). Use OpenHammer now to seed the candidate inventory and speed up profile/options work. Imported values remain provisional, reference-only and unplayable until checked for the scope being implemented.

Treat edition labels as provider claims until the selected record's source boundary is checked. Preserve provider IDs in a namespace and map them to internal IDs explicitly. Bulk-fetch a faction into a dated local snapshot, normalize stat/dice strings, and report unsupported values. Do not infer base dimensions or execute ability descriptions. Preserve source digests and keep downloaded game data out of distributed builds; data licensing and upstream provenance remain unverified.

### 40k.app: discrepancy discovery only for sampled Marine rules

[40k.app](https://www.40k.app/) announced an 11th-edition list builder in beta on 21 June 2026 and added core rules and stratagem pages in July. Its public pages expose faction indexes, datasheets, army rules, detachments, update histories, and list export. However, a 17 October sample of four current Space Marines datasheets found substantial mismatches against their current Wahapedia e11 pages:

| Datasheet | 40k.app sample | Current e11 reference | Finding |
|---|---|---|---|
| Intercessor Squad | T4; 80/150 points for 5/10; Objective Secured and Hail of Bolts | T5; 85/170; Bolter Discipline and Tactical Mainstay | Characteristics, prices and abilities differ. |
| Assault Intercessor Squad | T4, chainsword S4; 75/150; Targeted Intercession rerolls Wounds | T5, chainsword S5; 85/170; after a charge, melee attacks gain +1 S and AP | Same ability name, different effect; profile and prices differ too. |
| Heavy Intercessor Squad | 100/200; Unyielding affects Damage 1 attacks while on an objective | 115/230; while controlling an objective, +1 to save rolls | Price and ability trigger/effect differ. |
| Terminator Squad | T5; 160/320; Storm Bolter S4/AP0; Fury of the First keys off Oath of Moment | T6; 190/380; Storm Bolter S5/AP-1; Fury of the First grants +1 AP against units within 9 inches | Multiple stale profile and rule fields. |

The detailed snapshot and URLs are in the [Space Marines rules ledger](space-marines-rules-ledger.json). These samples show that 40k.app's announcement of an e11 list builder does not mean every Marine datasheet has been updated to the current Codex-era rules. Keep this sample only as audit evidence. Do not use it to source current identities, rules, values, or coverage, and do not use its sampled values in gameplay data.

It is not an official Games Workshop source, and its public pages do not provide a documented downloadable data/API contract or a clear license for reusing the rules dataset. Keep it out of the runtime/import pipeline. Do not bulk-copy its rules text or treat a list builder's acceptance as proof of legality. Its [Space Marines update history](https://www.40k.app/factions/space-marines/updates) currently reports no changes between the versions it displays; sampled profiles still differ from the current reference, so an unchanged provider page is not evidence of currentness.

**Assessment checked 17 October 2026:** four sampled Marine profiles show stale current-rule data. Retain the comparison as historical audit evidence only. It is not a rules authority, verified redistribution source, or documented machine interface. No claim is made that its faction data is complete or current.

### Wahapedia: human-readable cross-check

[11e core-rules page](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/)

The page is accessible and organizes numbered rules, phases, movement, attacks, terrain, and FAQs. Useful for finding interactions and drafting test scenarios. It is a third-party reference, not an executable rules engine; validate implemented behavior against the relevant official publication and updates. Link to relevant sections rather than bundling the page.

### Space Marines e11 interaction pass — 17 October 2026

The current [Space Marines e11 faction page](https://wahapedia.ru/wh40k11ed/factions/space-marines/) identifies Combat Doctrines as once per battle per doctrine, says a later doctrine replaces the prior doctrine on a unit, and lists Transhuman Strategist. The current Captain and Lieutenant datasheets define Strategic Acumen and Demi-company Commander. Applying the shared selection limit to Strategic Acumen, while treating Demi-company Commander as activation of the same selection, is now captured in the [structured rule definitions](space-marines-rule-definitions.json) and in the runtime. The Gladius Codex Discipline reference permits one doctrine an additional selection.

The current core transcription has a 1 CP gain for each player during each Command phase, a battle-round start rule that withholds Warlord-generated CP while the Warlord is destroyed, and a floor of 0 CP for modified stratagem costs. No general one-CP-per-battle-round gain cap appears in the consulted current core rules. This supports Transhuman Strategist and the 0 CP Teleport Homer Rapid Ingress interaction in the current reference model.

The source pages identify e11 and current faction content, but the exact applicable official Codex/core publication and errata locators for this definition slice have not been matched. Keep these effects marked `current_reference_transcribed`, not official-rule-certified. Games Workshop's [30 September Astartes balance summary](https://www.warhammer-community.com/en-gb/articles/rylbvfnv/warhammer-40000-balance-update-emboldened-astartes/) confirms broad datasheet changes around the Codex release; it does not independently reproduce these ability texts.

## Proposed integration sequence

1. Define an internal pack manifest: edition, schema version, rules implementation version, source URL/revision, retrieval date, notices, content hash, and supported mechanics.
2. Implement a small OpenHammer REST import adapter with strict normalization and explicit missing-data errors.
3. Map imported records into a 40kdc-compatible subset where practical. Preserve per-provider IDs and provenance; never merge by name alone.
4. Implement a small phase state machine and actual dice-driven attack resolution in the rendering-independent rules core. Structured abilities require implemented effect handlers.
5. Add fixed-roll interaction tests. Unsupported mechanics must prevent a unit from entering an enforced match rather than disappear silently.
6. Load pinned packs locally. Both players must agree on the pack hash and host overrides before starting; do not query remote services during action resolution.

This recommends adapters and verified subsets, not adopting an entire upstream engine. Existing prototype rules remain demonstration-only.

Source workflow update, 17 October 2026: OpenHammer is the fast bulk discovery/provisional import input for e11 candidates; Wahapedia supplies readable current e11 rule references; applicable GW publications/app updates are checked when a slice is implemented or marked supported. This just-in-time review keeps catalog and engine work moving without certifying unreviewed data. The fifth Space Marines definition slice adds the current Eradicator Squad with Heavy Bolters, Inceptor Squad, Assault Intercessors With Jump Packs and Scout Squad abilities, plus core Blast, Infiltrators and Scouts/Scout Move. These definitions remain reference-only until their mechanics are selected for implementation.
Sixth Space Marines definition slice, 17 October 2026: the current Wahapedia e11 Aggressor Squad and Infiltrator Squad pages were transcribed for Close-quarters Firestorm, Omni-scramblers and Helix Gauntlet. The core healing procedure is recorded as Helix Gauntlet's dependency. Both datasheets remain outside the runtime and army legality scope.

Seventh Space Marines definition slice, 17 October 2026: current Wahapedia e11 pages add Vanguard Assault and Combat Shield for Vanguard Veteran Squad With Jump Packs, and Ballistus Strike for Ballistus Dreadnought. Deep Strike, Sustained Hits, Damaged and Deadly Demise are represented as core dependencies/links. These sheets remain outside runtime scope.

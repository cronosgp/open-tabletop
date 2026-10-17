Current A3 increment (17 October 2026): [checked Incursion rosters](roster-validation.md) use official live MFM 1.6 points for ten fixed profiles, 2/4 repetition limits, the sole-3DP detachment exception and mandatory Warlord/Support declarations. Two 290-point starters are available under the 1,000-point ceiling. Complete official-match certification, broader equipment/model counts and remaining required detachment/core content are still pending.

Mission reconciliation, 17 October 2026: [the selected CA 2026-27 profile](chapter-approved-mission.md) records current e11 primary/fixed-secondary/map references and official Event Companion v1.3 cross-checks, including PDF checksum and the distinction between custom terrain and official recommended layouts. Historical 2025-26 material under the same e11 site path is not used as a current mission substitute.

Current source reconciliation (17 October 2026): [ten-unit abilities](current-unit-abilities.md#sources-checked-on-17-october-2026) uses the current e11 datasheets and Appendix, with official 14 October Marine errata and September Necron updates checked. Current regular Captain, Intercessor and Lieutenant abilities replace historical roadmap names in the new option. Printed base Codex coverage and reference-point limitations remain explicit.

# External source assessment

## Required rules baseline

The user requires official **Warhammer 40,000 11th edition**, using [Wahapedia e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and corresponding `/wh40k11ed/` faction pages as the consultation reference. Cross-check current effects and publication/version boundaries against official Games Workshop material. Never replace a missing current rule with an earlier-edition mechanic or silently combine superseded and current Codex rules. This requirement is also recorded in [AGENTS.md](../AGENTS.md).

The current [Combat Doctrines/Gladius implementation](combat-doctrines.md) follows that baseline. Historical Oath and earlier reference datasheets/abilities are not certification of the latest Codex; auditing and migrating those profiles is required before the Track A target can be considered legal. Existing historical save compatibility does not make those profiles part of current rules.

On 17 October 2026, [Awakened Dynasty Command Protocols and current Overlord pairings](awakened-dynasty.md) were checked against the e11 Necron pages and September official faction updates. The hit effect and pre-deployment declaration are implemented; attached Reanimation is now supported for the admitted pairings. Core e11 19/19.04 retains one unit and its combined strength, including a surviving leader's ability; Appendix 02.02.04 supplies living-wound priority before non-Character revival. Earlier separation assumptions are superseded.

Inspected 2026-10-15. This is an integration assessment, not confirmation of complete or official rules compliance. No upstream code or game dataset has been incorporated into the runtime. An independent local pack format and optional OpenHammer import tool have since been implemented; see [data-packs.md](data-packs.md). Imported snapshots are reference-only and excluded from version control by default.

Update 2026-10-16: the [army planner](army-builder.md) now uses OpenHammer directly for explicit catalog refreshes and a local offline cache. No upstream software or downloaded catalog is bundled, and remote data is not used during match resolution. The previous paragraph describes the earlier import-only integration.

## Recommended use

### 40kdc-data: data model and ability representation

[Repository](https://github.com/wn-mitch/40kdc-data)

Best candidate for the long-term interchange model. Its documented ability design separates triggers, conditions, effects, and scope. This fits automatic validation better than interpreting descriptions during play. Its 11e migration is ongoing; pin a commit and check coverage for each supported unit.

Concrete schema features inspected:

- [Unit schema](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/core/unit.schema.json): linked weapon/ability IDs, game version, base size, model count, multiple profiles, and provisional-points flag. Base size can be absent/null and representative rather than sufficient for every model.
- [Ability schema](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/enrichment/ability-dsl/ability.schema.json): source digest, version, supersession, trigger, scope, and effect. A digest identifies content; it does not establish release ordering or correctness.
- [Terrain layout](https://github.com/wn-mitch/40kdc-data/blob/main/schemas/core/terrain-layout.schema.json): footprints, heights, parent areas, rotation, board dimensions, and objective metadata. Map its 2D coordinates explicitly to Godot X/Z and convert inches consistently.

License boundaries are separate: [schemas CC0](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-SCHEMAS), [enrichment CC BY 4.0](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-DATA), and [tools MIT plus public-deployment attribution](https://github.com/wn-mitch/40kdc-data/blob/main/LICENSE-TOOLS). Preserve the applicable notices; do not label the whole repository simply MIT.

### Warhammer Oracle: reference tooling and calculation examples

[Repository](https://github.com/gregario/warhammer-oracle)

Provides edition-aware lookups, phase guidance, and curated rules. The README identifies BSData as a data source and distinguishes its MIT server code from game content.

Inspected [wound-calc.ts](https://github.com/gregario/warhammer-oracle/blob/main/src/lib/wound-calc.ts): returns expected hits, wounds, damage, and probabilities. This is useful for a future attack preview or selected mathematical test cases, not a replacement for resolving individual attacks and casualties.

Inspected [game-flow.ts](https://github.com/gregario/warhammer-oracle/blob/main/src/tools/game-flow.ts): formats phase guidance for the caller. It does not enforce a match state machine. Any adapted calculation must be checked against the selected edition and preserve its license notice.

### OpenHammer REST API: first import adapter

[API](https://openhammer-api-production.up.railway.app/) · [OpenAPI specification](https://openhammer-api-production.up.railway.app/openapi.json)

Live root and stats requests succeeded. The root lists `10e` and `11e`; the `11e` stats response reported 1,348 entries and 35 factions. Those counts do not establish completeness.

The specification exposes paginated unit lookup (`limit`/`offset`), lookup by ID, faction filters, and bulk queries. It is a simpler direct Godot import interface than MCP. The Unit schema includes stats, weapons, points, composition, keywords, and text abilities; it lacks explicit publication provenance, rules-update version, base geometry, and executable ability effects.

Treat edition labels as provider claims until validated. Preserve provider IDs in a namespace and map them to internal IDs explicitly. Request a selected small subset, normalize stat/dice strings, and report unsupported values. Do not infer base dimensions or execute ability descriptions. Data licensing and upstream provenance remain unverified.

### Wahapedia: human-readable cross-check

[11e core-rules page](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/)

The page is accessible and organizes numbered rules, phases, movement, attacks, terrain, and FAQs. Useful for finding interactions and drafting test scenarios. It is a third-party reference, not an executable rules engine; validate implemented behavior against the relevant official publication and updates. Link to relevant sections rather than bundling the page.

## Proposed integration sequence

1. Define an internal pack manifest: edition, schema version, rules implementation version, source URL/revision, retrieval date, notices, content hash, and supported mechanics.
2. Implement a small OpenHammer REST import adapter with strict normalization and explicit missing-data errors.
3. Map imported records into a 40kdc-compatible subset where practical. Preserve per-provider IDs and provenance; never merge by name alone.
4. Implement a small phase state machine and actual dice-driven attack resolution in the rendering-independent rules core. Structured abilities require implemented effect handlers.
5. Add fixed-roll interaction tests. Unsupported mechanics must prevent a unit from entering an enforced match rather than disappear silently.
6. Load pinned packs locally. Both players must agree on the pack hash and host overrides before starting; do not query remote services during action resolution.

This recommends adapters and verified subsets, not adopting an entire upstream engine. Existing prototype rules remain demonstration-only.

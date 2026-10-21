# Current support matrix

Updated 21 October 2026. This matrix describes implemented and admitted scope; it is not a claim that the whole edition or every selectable profile is fully supported. See the [roadmap](roadmap.md) for next work and [verification results](../verification/verification-results.md) for evidence.

**Rules/data source:** Wahapedia `/wh40k11ed/` is the definitive project reference. New army construction choices come only from the consolidated local runtime catalog. Network validation for current Marine increments is deferred to final integration. See [source assessment](../data/source-assessment.md) and [construction catalog policy](../construction-catalog-policy.md).

| Area | Available | Remaining / limit |
|---|---|---|
| Offline startup | Project-owned movement demo; local two-list setup; offline preparation and exercises | Bundled broad current-edition army content |
| Combat | Movement, morale, shooting, charge, alternating fights, attack planning, defender allocation and selected weapon/unit abilities | Arbitrary armies and every core/faction interaction |
| Phase progression | Command, Movement, Shooting, Charge and Fight are represented, with specialized pending decisions and action drafts | Generic event-trigger registry, shared suspended-action frames and universal phase-close gate; see [phase/action/decision flow](../architecture/phase-action-decision-flow.md) |
| Unit catalog | All 85 shared-book Space Marine identities, including Wardens of Ultramar, are represented in the local Wahapedia e11 catalog and pass the local construction publication gate | Catalog selection does not imply complete rules, options, interactions or faction legality; four Necron profiles remain outside this Marine catalog |
| Marine rules | Local profile, rules, combat, construction and materialization checks for bounded admitted increments; current faction/detachment effects are limited to documented scopes | Vanguard Ambushers and three Ironstorm stratagems remain pending local validation and are blocked from admission and use. Remaining options, combinations and shared interactions are also incomplete. |
| Other factions | Four retained Necron training/reference profiles and their bounded mechanics | Consolidation/admission into the current construction catalog and broader faction completeness |
| Army construction | Local catalog choices, declared sizes/prices, saved drafts and bounded admission checks | General-purpose legal-list validation, all duplicate/attachment/equipment/detachment rules and all factions |
| Mission | Selected CA 2026-27 Battlefield Dominance / Hammer and Anvil profile with fixed secondaries, preparation, scoring and five-round result; separate custom training scenario | Other mission/deck/layout configurations and full match certification with current faction scope |
| Stratagems and reactions | Documented Command Re-roll windows, Fire Overwatch, Heroic Intervention, Counteroffensive, Epic Challenge, Insane Bravery and selected faction cards within their profile gates | Other cards and timings; exact options remain capability- and profile-gated |
| Battlefield | Shared ground-level board, selected deployment/terrain geometry and objective layout | Upper floors, complete vertical movement, exact imported-mesh visibility and player battlefield editor |
| Multiplayer | Authoritative host, LAN/direct address, snapshots, seat credentials and existing host-restart recovery paths | Current Marine network validation is deferred; broader negotiation, separate-machine coverage, practical NAT diagnostics and recovery polish remain |
| Persistence | Versioned snapshots, atomic replace/checksum, autosave, local/LAN resume, RNG continuation and hash-chained event/dice journal with verified reconstruction | Visual replay, multiple slots, journal compaction and cross-version migration |
| Models | Local mapping/preview and explicit ForceOrg/TTS visual import/download workflows | Broader formats, composite assembly and per-model variants; visuals never determine rules geometry |
| Delivery | Offline verification runner, CI definition and demo export presets | CI execution, native builds and supported cross-platform match validation |

## Evidence levels

Keep these distinct when describing a feature:

1. **Catalogued:** identity and source metadata exist.
2. **Implemented:** the host/runtime enforces the bounded behavior.
3. **Locally validated:** focused local cases passed for the stated scope.
4. **Network validated:** host/guest, stale/duplicate commands and recovery passed for that scope.
5. **Certified:** named lists, mission, battlefield, options and version boundary were reviewed together.

Headless checks, loopback host/client, graphical review, separate-machine LAN, Windows/Linux interoperability and native export are separate forms of evidence. A pass at one level does not imply another.

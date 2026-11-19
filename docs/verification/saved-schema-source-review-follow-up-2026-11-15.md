# Saved-schema source-option review follow-up — 15 November 2026

## Scope and provenance

This audit checks whether existing saved equipment fields cover every equipment-option row on five admitted profiles. It does not add choices or certify complete datasheets, current event legality, or full army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each option-bearing source row below was checked against the exact saved field and runtime provenance. The registry binds either the profile's extraction snapshot or its separate `source_verified_against_*` snapshot; those provenance pairs are not mixed.

## Profile findings

### Hammerfall Bunker — `000000097` (Space Marines Warhammer Legends)

The source allows the Hammerfall Heavy Bolter Array to be replaced with a Hammerfall Heavy Flamer Array. The existing `hammerfall_heavy_flamer_array` field represents that single-model choice. The saved-equipment regression checks the selectable package and its materialized weapons. The Legends source label remains part of the profile boundary; this option review does not establish event approval.

### Land Speeder — `000002711` (Space Marines)

The source allows the Onslaught Gatling Cannon to be replaced with a Pyrecannon. The existing `land_speeder_cannon` field stores the choice by stable copy. Its regression checks distinct saved copies, materialization before Deployment, suppression of duplicate preparation edits, and equipment-based appearance rationale.

### Land Speeder Vengeance — `000000242` (Dark Angels)

The source allows the Heavy Bolter to be replaced with an Assault Cannon. The existing `land_speeder_vengeance_cannon` field represents the single replacement group. The saved-loadout regression exercises the Workshop, admission, and materialized weapon choice.

### Rhino — `000002723` (Space Marines)

The source permits this model to take a Hunter-killer Missile. The existing boolean `rhino_hunter_killer_missile` field saves that optional weapon per copy. The shared Rhino regression checks independent copies, Workshop selection, admission and both-player materialization.

### Rhino Primaris — `000000085` (Space Marines Warhammer Legends)

The Legends source permits this model to take a Hunter-killer Missile. Its existing `rhino_hunter_killer_missile` field saves the option per copy, and the shared Rhino regression verifies the separate profile and its saved choice. This remains a source-bounded Legends profile; the option review does not certify current event approval or broader rules scope.

## Conclusion

All five source option rows map to existing saved fields, so no schema change was required. The matching saved-loadout suites passed as recorded in the [verification results](verification-results.md#vehicle-saved-schema-review-regression-follow-up-2026-11-15). The registry and generated coverage ledger classify these profiles as source-option reviewed only; their other support and rules gates remain separate.

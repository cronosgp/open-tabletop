# Saved-schema source-option review — aircraft and squads — 15 November 2026

## Scope and provenance

This audit maps every local equipment-option row for five admitted profiles to the existing saved fields. It does not add choices or certify complete datasheets, event legality, or full army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each profile's runtime verified-against snapshot, manifest, source digest and slice-manifest binding match this source audit.

## Profile findings

### Ravenwing Darkshroud — `000000238` (Dark Angels)

The source permits the Heavy Bolter to be replaced with an Assault Cannon. The existing `ravenwing_darkshroud_cannon` field covers the single replacement. The saved profile regression checks independent copy persistence, admission, match materialization and setup locking.

### Sanguinary Guard — `000000165` (Blood Angels)

For every three models, one model may replace its Angelus Boltgun with an Inferno Pistol. The per-model `sanguinary_guard_inferno_pistol` field preserves the bearer identity; existing validation retains the one-per-three cap.

### Stormhawk Interceptor — `000000084` (Space Marines Warhammer Legends)

The source lists two groups: replace the Las-talon with an Icarus Stormcannon, and replace the Skyhammer Missile Launcher with a Twin Heavy Bolter or Typhoon Missile Launcher. The existing `stormhawk_icarus_stormcannon` and `stormhawk_missile_launcher` fields represent both groups. The test checks all six legal combinations. The Legends boundary remains; event approval is not part of this review.

### Stormtalon Gunship — `000001190` (Space Marines Warhammer Legends)

The Skyhammer Missile Launcher may become a Twin Heavy Bolter, Twin Lascannon or Typhoon Missile Launcher. The `stormtalon_missile_launcher` field stores the source default and all three alternatives; the saved-schema test checks all four packages. The Legends boundary remains; event approval is not part of this review.

### Tarantula Sentry Battery — `000000098` (Space Marines Warhammer Legends)

Any number of models may independently replace a Twin Heavy Bolter with a Twin Lascannon. The existing `tarantula_sentry_primary` field is stored per model, and its saved-loadout regression exercises the selectable profiles across the battery's supported sizes. The Legends boundary remains; event approval is not part of this review.

## Conclusion

The six exported option rows map to six existing saved fields. No schema change was required. The matching profile regressions are recorded in the [verification results](verification-results.md#aircraft-squad-saved-schema-review-regression-2026-11-15). This source-option audit does not close any other runtime or rules gate.

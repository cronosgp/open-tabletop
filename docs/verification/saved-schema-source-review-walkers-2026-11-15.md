# Saved-schema source-option review — Dreadnoughts — 15 November 2026

## Scope and provenance

This audit checks whether existing saved equipment schemas cover all exported option rows for four admitted Dreadnought profiles. It does not add choices or certify complete datasheets, event legality, or full army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each profile's runtime verified-against snapshot, manifest, source digest and slice-manifest binding match this review basis.

## Profile findings

### Bjorn the Fell-Handed — `000000302` (Space Wolves)

The source allows the Assault Cannon to be replaced with a Helfrost Cannon or Multi-melta. The existing `space_wolves_walker_primary` field also retains the source default and covers all three weapon choices. The focused walker regression checks the factory and saved-copy path.

### Brutalis Dreadnought — `000000136` (Space Marines)

The source lists two groups: replace the Bolt Rifles and Brutalis Fists together with Brutalis Talons, and replace the Twin Heavy Bolter with a Twin Multi-melta. The existing `brutalis_talons` and `brutalis_multi_melta` fields represent these independent groups. Its regression checks saved admission, exact materialization and setup locking.

### Venerable Dreadnought — `000002801` (Space Wolves)

The three source rows cover the Assault Cannon replacement, Storm Bolter to Heavy Flamer, and the linked Assault Cannon plus Dreadnought Combat Weapon replacement with a Fenrisian Great Axe and Blizzard Shield. The fields `space_wolves_walker_primary`, `space_wolves_walker_secondary` and `space_wolves_walker_melee_package` cover these groups. The existing factory and schema validator admit exactly eight legal combinations and reject the conflicting primary replacement with the linked axe/shield package.

### Wulfen Dreadnought — `000004133` (Space Wolves)

The source allows Storm Bolter to Heavy Flamer and Fenrisian Great Axe to Blizzard Shield. The existing `space_wolves_walker_secondary` and `space_wolves_walker_melee_package` fields cover the two groups. Its regression checks the combinations, saved copy materialization and lock.

## Conclusion

The eight local option rows map to eight existing saved fields. No schema change was needed. The matching regressions are recorded in the [verification results](verification-results.md#dreadnought-saved-schema-review-regression-2026-11-15). This source-option audit does not close other runtime or rules gates; the three profiles sourced from the Space Wolves book remain subject to their existing catalog boundaries.

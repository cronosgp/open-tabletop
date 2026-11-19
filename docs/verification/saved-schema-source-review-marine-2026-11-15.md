# Saved-schema source-option review — matched profiles — 15 November 2026

## Scope and provenance

This audit checks whether existing saved fields represent every equipment-option row for two admitted profiles. It does not add choices or certify complete datasheets, event legality, or full army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each profile's runtime verified-against snapshot, manifest, source digest and slice-manifest binding match this review basis.

## Profile findings

### Marshal — `000002796` (Black Templars)

The source allows the Plasma Pistol to be replaced with a Combi-weapon. The existing `marshal_ranged_package` field records this replacement; the fixed Master-crafted Power Weapon is unaffected. The saved-loadout regression checks the field, admission, materialized weapons, preparation lock and Workshop signal.

### Nephilim Jetfighter — `000000239` (Dark Angels)

The source allows the Twin Heavy Bolter to be replaced with Nephilim Lascannons. The existing `nephilim_lascannon_package` field represents that replacement. The local saved-vehicle regression checks the saved package and expected weapons, while the profile suite covers the source-listed preparation choice.

## Deferred profiles

Annihilation Barge (`000000553`), Canoptek Tomb Crawlers (`000004177`) and Immortals (`000000535`) remain pending. Their runtime records bind to snapshot `20261031T053336Z` and parent manifest SHA-256 `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`, but that manifest and its raw export are not present in the local source tree. The available 30 October export has an earlier revision, so it was not substituted for the profiles' recorded provenance. Their existing rules/profile suites passed in the same test batch, but that does not establish source-option completeness. Review can resume when the bound export is restored or a separate verified-against source binding is recorded.

## Conclusion

Both matched source rows map to existing fields, so no schema change was needed. The source registry and generated coverage ledger mark only these two profiles as option-reviewed. The matching verification batch is recorded in the [verification results](verification-results.md#matched-source-schema-review-regression-2026-11-15).

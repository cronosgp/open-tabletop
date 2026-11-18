# Saved-schema source-option review — Dreadnoughts and Death Company — 15 November 2026

## Scope and provenance

This review maps all local equipment-option rows for five admitted profiles to their detected saved fields. It covers source-option completeness only; it does not certify complete datasheets, event approval or whole-army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

The raw CSV copies used for this comparison match these hashes. Each runtime profile's verified-against snapshot, manifest, source digest and slice-manifest binding match the same review basis.

## Profile findings

### Cerberus — `000001153` (Space Marines, Warhammer Legends)

Two source option rows cover the independent optional hull weapon and paired sponson package. The existing `cerberus_optional_weapon` and `cerberus_optional_pair` fields represent those groups.

### Death Company Dreadnought — `000000166` (Blood Angels)

Two source option rows replace the Twin Heavy Bolter and the linked Blood Fist Bolt Rifles/Blood Fists. The existing `death_company_twin_multi_melta` and `death_company_blood_talons` fields cover the two replacements.

### Death Company Marines — `000001997` (Blood Angels)

Five source option rows cover the Chainsword-to-Bolt Rifle Fire/Combat Blade package, Eviscerator and other melee replacements, pistol alternatives, and the conditional Grenade Launcher. The existing `death_company_melee_package`, `death_company_pistol_package` and `death_company_grenade_launcher` fields cover these choices.

### Death Company Marines with Jump Packs — `000002737` (Blood Angels)

Six source option rows cover the per-five-model melee replacements and pistol replacements, including their separate caps. The existing `death_company_melee_package` and `death_company_pistol_package` fields cover the groups.

### Dreadnought — `000000117` (Space Marines, Warhammer Legends)

Three source option rows cover the Assault Cannon replacement, the linked Dreadnought Fist/Storm Bolter replacement, and the remaining Storm Bolter replacement. The existing `dreadnought_primary`, `dreadnought_melee_package` and `dreadnought_secondary` fields cover these options.

## Conclusion

All eighteen source option rows map to existing saved fields, so no schema change was required. The focused offline regressions are recorded in the [verification results](verification-results.md#dreadnought-and-death-company-saved-schema-source-review-15-november-2026). This review establishes option-completeness mapping only.

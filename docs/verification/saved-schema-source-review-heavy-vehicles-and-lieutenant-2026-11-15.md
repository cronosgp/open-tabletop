# Saved-schema source-option review — heavy vehicles and Lieutenant — 15 November 2026

## Scope and provenance

This audit maps all local equipment-option rows for five admitted profiles to their detected saved fields. It checks equipment-option completeness only; it does not certify complete datasheet rules, Legends event approval or whole-army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

The raw CSV copies used for this comparison match those hashes. Each runtime profile's verified-against snapshot, manifest, source digest and slice-manifest binding match the same review basis.

## Profile findings

### Falchion — `000001666` (Space Marines, Warhammer Legends)

Three source option rows cover the optional hull weapon, the four-weapon main-armament replacement and the Twin Heavy Bolter replacement. The existing `falchion_optional_weapon`, `falchion_main_armament` and `falchion_twin_replacement` fields cover these groups.

### Lieutenant — `000001346` (Space Marines)

Five source option rows cover the linked Neo-volkite pistol/Power Weapon package, its conditional Storm Shield, the Bolt Pistol replacement, Master-crafted Bolter replacements and Ceramite Fists replacements. The existing `lieutenant_weapon_package`, `lieutenant_storm_shield` and `lieutenant_fists_replacement` fields cover those choices.

### Typhon — `000000093` (Space Marines, Warhammer Legends)

Two source option rows cover the paired sponson package and optional hull weapon. The existing `typhon_sponson_package` and `typhon_hull_weapon` fields represent both groups.

### Vindicator — `000001188` (Space Marines, Warhammer Legends)

The export contains four rows for the Hunter-killer Missile and Storm Bolter additions, including capitalization/punctuation variants for the same two optional items. The existing `vindicator_hunter_killer_missile` and `vindicator_storm_bolter` fields cover both distinct choices; the duplicate wording adds no separate selectable option.

### Whirlwind — `000002727` (Space Marines, Warhammer Legends)

Two source option rows cover the Storm Bolter and Hunter-killer Missile additions. The existing `whirlwind_storm_bolter` and `whirlwind_hunter_killer_missile` fields cover both.

## Conclusion

All sixteen source option rows map to existing saved fields, accounting for the Vindicator's two duplicate wording variants without treating them as extra choices. No schema change was required. The focused offline suites are recorded in the [verification results](verification-results.md#heavy-vehicles-and-lieutenant-saved-schema-source-review-15-november-2026). This review does not certify complete datasheets or whole-army legality.

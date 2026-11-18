# Captain on Bike saved-equipment source review

## Scope and provenance

This is an equipment-option completeness review for the existing saved-model schema. It does not certify the full datasheet, army legality or all Captain on Bike rules.

- Edition and source: Warhammer 40,000 11th edition, local Wahapedia Space Marines App book `000000139`, datasheet `000002702`.
- Verified-against snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent export manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Runtime source digest: `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`.
- Relevant raw file SHA-256 values, each matching the selected export manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

## Exported equipment and saved-field coverage

The local default loadout lists a Heavy Bolt Pistol, Master-crafted Power Weapon and Twin Bolt Rifle. Its two equipment-option rows permit independent replacements: Heavy Bolt Pistol with a Plasma Pistol, and Master-crafted Power Weapon with a Thunder Hammer. No other equipment-option row is present for this datasheet in the selected export.

The existing stable-model fields `captain_bike_plasma_pistol` and `captain_bike_thunder_hammer` encode those two independent choices. The saved-equipment adapter offers the same alternatives and validates the combined packages through the local Captain on Bike weapon factory. The Twin Bolt Rifle remains fixed. The existing saved-loadout regression was not rerun as part of this source-only classification update.

## Conclusion

The existing saved schema covers both equipment-option rows in the selected local source. No additional field or runtime change is required for this profile. The registry records this as equipment-option completeness only; broader rules, army-legality and plan acceptance gates remain open.

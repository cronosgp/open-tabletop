# Aggressor Squad saved-equipment source review

## Scope and provenance

This is an equipment-option completeness review for the existing saved-model field. It is not a full datasheet, army-legality or rules certification.

- Edition and source: Warhammer 40,000 11th edition, local Wahapedia App datasheet 000002099 in source book 000000139.
- Verified-against snapshot: wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z, export revision 2026-10-28T23:48:19+03:00, retrieved 2026-10-30T01:33:48.347556+00:00.
- Parent export manifest SHA-256: 12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e.
- Runtime source digest: 2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68.
- Raw file SHA-256 values, each matching the selected export manifest:
  - Datasheets.csv: 39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c
  - Datasheets_options.csv: 642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853
  - Datasheets_unit_composition.csv: f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245
  - Datasheets_models_cost.csv: 2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e
  - Datasheets_wargear.csv: 565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d

## Exported equipment and saved-field coverage

The local options row says every model may replace its Flamestorm Gauntlets with one Auto Boltstorm Gauntlets and one Fragstorm Grenade Launcher. The default profile lists Flamestorm Gauntlets and Twin Power Fists on every model. The Twin Power Fists remain fixed; the export lists no further optional groups or bearer-specific caps.

The existing stable-model field, aggressor_boltstorm, represents exactly this package choice: false retains Flamestorm Gauntlets and true selects both replacement weapons. The Army Workshop exposes an independent control for each model. Existing saved-loadout regression coverage exercises mixed choices across model and copy identities, save/reopen, compatibility migration, current-catalog admission and the Workshop control. This audit does not claim that those checks were rerun here.

The local composition rows specify one Aggressor Sergeant plus two to five Aggressors. The export lists 90 points for three models and 180 points for six; the equipment option has no listed surcharge. This source review does not change composition or point admission.

## Conclusion

The existing saved schema covers the complete equipment-option row for the selected local source. No additional equipment field or runtime change is required for this profile. The source-option completeness review is recorded in the Army Builder ledger; broader rules, army-legality and plan acceptance gates remain open.

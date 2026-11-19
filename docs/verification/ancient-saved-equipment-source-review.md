# Ancient saved-equipment source review

## Scope and provenance

This is an equipment-option completeness review for the existing saved-model field. It does not certify the Ancient datasheet or full army legality.

- Edition and source: Warhammer 40,000 11th edition, local Wahapedia App datasheet 000002775 in Space Marines book 000000139.
- Verified-against snapshot: wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z, export revision 2026-10-28T23:48:19+03:00, retrieved 2026-10-30T01:33:48.347556+00:00.
- Parent export manifest SHA-256: 12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e.
- Runtime source digest: 2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68.
- Relevant raw file hashes match the selected export manifest:
  - Datasheets.csv: 39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c
  - Datasheets_options.csv: 642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853
  - Datasheets_unit_composition.csv: f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245
  - Datasheets_models_cost.csv: 2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e

## Exported equipment and saved-field coverage

The local equipment-options row permits this model's Bolt Rifle to be replaced with one Power Weapon. The default datasheet equipment also includes a Bolt Pistol and Ceramite Fists; the export lists no further optional group or additional bearer.

The existing saved field, ancient_weapon, records the Bolt Rifle or Power Weapon choice for the stable model. The saved-equipment adapter presents the same two choices, and the existing regression checks admission, both copies with different choices, exact local factory materialization, frozen setup behavior and the Workshop picker. The existing regression was not rerun as part of this source-classification update.

The export lists one Ancient model at 40 points. No equipment surcharge is listed, and this review does not change composition or points.

## Conclusion

The saved schema covers the complete option row for this profile in the selected local source. No additional field or runtime change is required. This closes only the equipment-option completeness review.

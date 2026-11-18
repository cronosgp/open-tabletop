# Saved-schema source-option review — Captains and Castellan — 15 November 2026

## Scope and provenance

This review maps every local equipment-option row for five admitted character profiles to their detected saved fields. It checks source-option completeness only; it does not certify each datasheet's complete rules, event approval or whole-army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each runtime profile's verified-against snapshot, manifest, source digest and slice-manifest binding match this review basis.

## Profile findings

### Captain — `000000073` (Space Marines)

Three source option rows cover the ranged package, the melee weapon/shield replacement and the power-weapon replacement. The existing `captain_ranged_loadout` and `captain_melee_weapon` fields cover these groups.

### Captain with Jump Pack — `000000083` (Space Marines)

Three source option rows cover the pistol, melee weapon and linked pistol/melee package alternatives. The existing `jump_captain_loadout` field represents each choice, including the linked package.

### Castellan — `000002793` (Black Templars)

Two source option rows replace the Combi-weapon and Master-crafted Power Weapon. The existing `castellan_ranged_package` and `castellan_melee_package` fields cover both rows.

### Death Company Captain — `000003832` (Blood Angels)

Two source option rows cover the Master-crafted Chainsword replacement and Heavy Bolt Pistol replacement. The existing `death_company_captain_melee` and `death_company_captain_pistol` fields cover both groups.

### Death Company Captain with Jump Pack — `000003833` (Blood Angels)

Four source option rows cover the linked Thunder Hammer/Relic Shield package, standalone melee replacements, the linked Chainsword/Relic Shield package, and pistol replacements. The existing `death_company_jump_captain_loadout` field represents these alternatives.

## Conclusion

All fourteen source option rows map to existing saved fields; no schema change was required. The focused offline suites passed, as recorded in the [verification results](verification-results.md#captain-and-castellan-saved-schema-source-review-15-november-2026). This review is limited to equipment-option completeness.

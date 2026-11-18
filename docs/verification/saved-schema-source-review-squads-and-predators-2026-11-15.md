# Saved-schema source-option review — squads and Predators — 15 November 2026

## Scope and provenance

This audit maps each local equipment-option row for five admitted profiles to existing saved fields. It does not add choices or certify complete datasheets, event legality, or full army legality.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each profile's runtime verified-against snapshot, manifest, source digest and slice-manifest binding match this review basis.

## Profile findings

### Eliminator Squad — `000001668` (Space Marines)

The source permits the Sergeant to replace the Bolt Sniper Rifle with an Instigator Bolt Carbine or Las Fusil, and permits every model to replace that rifle with a Las Fusil. The existing `eliminator_sergeant_ranged` and `eliminator_trooper_ranged` fields cover the distinct Sergeant and ordinary-model roles, including their source defaults.

### Outrider Squad — `000002712` (Space Marines)

The Sergeant may replace the Chainsword with a Power Weapon or Thunder Hammer. For every three models, one model may replace a Heavy Bolt Pistol with a Plasma Pistol. The saved `outrider_sergeant_melee` and per-model `outrider_plasma_pistol` fields cover both groups; the existing validator retains the cap.

### Reiver Squad — `000002718` (Space Marines)

The unit can take Grav-chutes and Grapnel Launchers as separate optional groups. The existing `reiver_grav_chutes` and `reiver_grapnel_launchers` fields preserve those independent selections.

### Predator Annihilator — `000002714` (Space Marines Warhammer Legends)

The source permits replacing the pair of Lascannons with two Heavy Bolters, and separately permits a Hunter-killer Missile and Storm Bolter. The existing `predator_annihilator_heavy_bolters`, `predator_annihilator_hunter_killer_missile` and `predator_annihilator_storm_bolter` fields cover all three rows. The saved regression checks independent copies and exact package materialization. Event approval remains outside this audit.

### Predator Destructor — `000002715` (Space Marines Warhammer Legends)

The source separately permits a Storm Bolter, Hunter-killer Missile and replacement of the two Lascannons with two Heavy Bolters. The existing `predator_destructor_heavy_bolters`, `predator_destructor_hunter_killer_missile` and `predator_destructor_storm_bolter` fields cover all three rows. Its saved regression checks independent copies and exact package materialization. Event approval remains outside this audit.

## Conclusion

All twelve source option rows map to existing saved fields, so no schema change was needed. The focused suites are recorded in the [verification results](verification-results.md#squad-and-predator-saved-schema-review-regression-2026-11-15). The two Predator records remain source-bounded Warhammer Legends profiles; this audit does not certify competitive-event approval.

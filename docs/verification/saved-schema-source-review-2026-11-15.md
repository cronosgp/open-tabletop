# Saved-schema source-option review — 15 November 2026

## Scope and provenance

This batch checks equipment-option completeness for existing saved schemas. It does not add equipment choices or certify full datasheets, army legality or faction rules.

- Edition and source: Warhammer 40,000 11th edition, verified local Wahapedia Data Export, Space Marines App book `000000139` and Blood Angels App book `000000021`.
- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

## Profile findings

### Assault Intercessor Squad — `000001606` (Space Marines App)

The export's two option rows apply to the Sergeant: Heavy Bolt Pistol may become a Hand Flamer or Plasma Pistol; Chainsword may become a Power Fist, Power Weapon or Thunder Hammer. The saved fields `assault_intercessor_sergeant_pistol` and `assault_intercessor_sergeant_melee` represent these two separate groups on the stable Sergeant model. Other models retain their fixed Chainsword and Heavy Bolt Pistol.

### Baal Predator — `000000168` (Blood Angels App)

The export lists four groups: choose two Heavy Bolters or two Heavy Flamers for the sponsons; replace the Twin Assault Cannon with a Baal Flamestorm Cannon; add a Storm Bolter; and add a Hunter-killer Missile. The four saved fields—`baal_predator_sponson_package`, `baal_predator_primary_cannon`, `baal_predator_storm_bolter` and `baal_predator_hunter_killer_missile`—cover those groups independently.

### Blood Angels Captain — `000003831` (Blood Angels App)

The export lists two independent replacements: Master-crafted Chainsword to Power Fist or Relic Weapon, and Heavy Bolt Pistol to Inferno Pistol. The saved fields `blood_angels_captain_melee` and `blood_angels_captain_pistol` expose those choices; the default package remains available.

### Captain in Terminator Armour — `000000135` (Space Marines App)

The export lists two independent replacements: Relic Weapon to Relic Fist, and Storm Bolter to Combi-weapon. The saved fields `terminator_captain_relic_fist` and `terminator_captain_combi_weapon` represent both rows.

### Invader ATVs — `000004247` (Space Marines App)

The export permits every model to replace its Onslaught Gatling Cannon with a Multi-melta. The saved field `invader_atv_multi_melta` is stored by stable model, so each ATV's choice is independent. Fixed Armoured Impact, Bolt Pistol and Twin Bolt Rifle remain unchanged.

### Captain in Gravis Armour — `000001172` (Space Marines App)

The export has one equipment group replacing the Master-crafted Heavy Bolt Rifle and Master-crafted Power Weapon together with one of three packages: Boltstorm Gauntlet plus Relic Blade, Relic Chainsword or Relic Power Fist. The saved field `gravis_loadout` represents the complete package choice.

### Heavy Intercessor Squad — `000001177` (Space Marines App)

The export allows one non-Sergeant Heavy Intercessor per five starting models to replace a Heavy Bolt Rifle with a Heavy Bolter. The `heavy_intercessor_bolter` field is stored per eligible stable model; the Sergeant has no such field. The source's one-per-five cap remains enforced by the existing setup validator.

### Hellblaster Squad — `000002098` (Space Marines App)

The export's only option permits the Hellblaster Sergeant to replace their Bolt Pistol with a Plasma Pistol. The stable-model field `hellblaster_sergeant_pistol` records that replacement; other models remain fixed.

### Inceptor Squad — `000000125` (Space Marines App)

The export permits every model to replace Assault Bolters with Plasma Exterminators. The `inceptor_weapon` field is stored by stable model, preserving independent equipment for each Inceptor.

### Invictor Tactical Warsuit — `000001156` (Space Marines App)

The export permits this model's Incendium Cannon to be replaced with a Twin Ironhail Autocannon. The saved field `invictor_cannon` covers this single option group.

## Conclusion

For all ten profiles in this batch, the current saved fields cover every equipment-option row in the selected local export. No new schema or runtime change was needed. The two five-profile regression batches are recorded in [the first group](verification-results.md#saved-profile-source-review-regressions--15-november-2026) and [the follow-up](verification-results.md#saved-schema-review-regression-follow-up--15-november-2026). The registry and generated coverage ledger record these as equipment-option completeness reviews only.

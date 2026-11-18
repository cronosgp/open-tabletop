# Saved-schema source-option review — Necrons — 15 November 2026

## Scope and provenance

This review maps all local equipment-option rows for ten admitted Necron profiles to their detected saved fields. It establishes option completeness for these records only; it does not certify all datasheets in the export, complete rules coverage or whole-army legality.

- Edition and source: Warhammer 40,000 11th edition, local Wahapedia Data Export, Necrons App (`Source.csv` edition `11`).
- Runtime-bound snapshot: `20261031T053336Z`, export revision `2026-10-30T22:19:16+03:00`, retrieved `2026-10-31T05:34:28.395103+00:00`.
- Parent manifest SHA-256: `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`.
- Current Necrons runtime-catalog digest: `4c0a1cd8edba1fef54a92c613db5ee6e421681dc11b144c43461053fb5184982`. The source snapshot and raw tables did not change; this rebind follows the expanded runtime catalog.
- Relevant raw-file hashes, matched to that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

The manifest contains 68 structural validation findings in the wider export. None names these ten datasheet IDs or their option rows; all ten datasheets and their source-book references were checked directly against the hashed tables. This bounded audit does not clear the export's other findings or claim broader data certification.

## Profile findings

### Annihilation Barge — `000000553`

The source's one option replaces the Gauss Cannon with a Tesla Cannon. The existing `necron_annihilation_barge_loadout` field covers that choice.

### Canoptek Macrocytes — `000004176`

Three source option rows cover the Gauss Scalpel/Tesla Caster swap and two single-model special weapon alternatives. The existing `canoptek_macrocytes_loadout` field represents those choices.

### Canoptek Spyders — `000000551`

The three independent source options add Particle Beamers, a Fabricator Claw Array and a Gloom Prism. The existing `canoptek_spyders_particle_beamers`, `canoptek_spyders_fabricator_claw_array` and `canoptek_spyders_gloom_prism` fields preserve them independently.

### Canoptek Tomb Crawlers — `000004177`

The source's one option replaces the Twin Gauss Reaper with a Transdimensional Isolator. The existing `canoptek_tomb_crawlers_loadout` field covers that choice.

### Immortals — `000000535`

The source's one option replaces each model's Gauss Blaster with a Tesla Carbine. The existing `necron_ranged_weapon` field covers that per-model choice.

### Monolith — `000000552`

The source's one option replaces the four Gauss Flux Arcs with four Death Rays. The existing `necron_monolith_loadout` field covers the paired package.

### Necron Warriors — `000000534`

The source's one option allows each model to replace its Gauss Flayer with a Gauss Reaper. The existing `necron_ranged_weapon` field covers the per-model choice.

### Lokhust Heavy Destroyers — `000002116`

The source allows any number of models to replace each Gauss Destructor with an Enmitic Exterminator. The `lokhust_heavy_weapon` field stores that choice independently for every model.

### Triarch Praetorians — `000000539`

The source replaces each Rod of Covenant with the linked Particle Caster and Voidblade package. The `triarch_praetorian_weapon_package` field preserves both weapons as one per-model choice.

### Triarch Stalker — `000000540`

The source replaces the Heat Ray with either a Particle Shredder or Heavy Gauss Cannon Array. The `triarch_stalker_weapon` field stores the copy-level selection.

## Conclusion

All fourteen source option rows map to the ten exact saved-field sets. The seven existing schemas were rebound to the expanded runtime catalog digest; all ten retain the same source snapshot and manifest. No alternate export was substituted. The new saved-equipment path passed its focused offline regression, recorded in the [verification results](verification-results.md#necron-saved-equipment-extension-and-review-refresh--15-november-2026). The wider export's 68 structural findings remain outside this audit.

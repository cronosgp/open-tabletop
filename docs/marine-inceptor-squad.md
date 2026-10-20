# Inceptor Squad — current e11 local profile

**Source of truth:** the pinned [Wahapedia 11th-edition Inceptor datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Inceptor-Squad) and its local export. Shared-book source `000000139`, datasheet `000000125`, export timestamp `2026-10-16T21:03:46+03:00`. This is not a network check.

## Admitted scope

- Unit composition: 1 Inceptor Sergeant and 2–5 Inceptors. The local construction catalog admits 3- or 6-model units. Points are 130/260 for the first two units and 150/280 for each later unit.
- Profile: Move 10", Toughness 6, Save 3+, 3 Wounds, Leadership 6+, Objective Control 1; 40 mm bases. Keywords: Infantry, Gravis, Jump Pack, Imperium, Fly, Adeptus Astartes.
- Default equipment: each model has Assault Bolters and Ceramite Fists. At army setup, each model may independently replace Assault Bolters with Plasma Exterminators. Standard and Supercharge profiles are available; Supercharge is Hazardous.
- Deep Strike uses the existing all-model ingress flow.
- Meteoric Descent adds +1 to Hit for ranged attacks after this unit made an Ingress move this turn. The shared hit modifier cap still applies; the effect also remains available to out-of-phase ranged attacks in that same turn.
- Parabolic Jetleap is offered at the end of the opponent's Fight phase when this unit is unengaged. Choosing it removes the whole unit into Strategic Reserves; it can return through the shared Deep Strike Ingress flow.

## Local checks

Focused validation is recorded in `.tools/verification/20261019T082438502854Z/results.json` (11/11 processes; 35 Python tests). `test_inceptor_squad` checks source identity, profile data, 3/6 sizes, first-two and third-plus prices, all weapon profiles/traits, per-model plasma replacement, Deep Strike, Meteoric Descent (including out-of-phase attacks), the unengaged end-of-Fight trigger, removal to reserves and the return choice. Adjacent checks cover roster validation, catalog publication, attack planning, doctrines, leaders and current abilities.

The bounded offline comparison `.tools/wahapedia-fixed-data-review-v53.json` includes this as profile 30. It found no numeric or identity differences; the Inceptor profile passes its bounded fixed-data checks, including all four weapon profiles and the Adeptus Astartes keyword context. The full comparison is 29/30 because Ancient in Terminator Armour retains unresolved chapter-specific `DEATHWING` context. The raw source snapshot has structural warnings.

Construction and combat coverage is local and partial. Final network validation remains deferred; this does not certify full Space Marines rules coverage, general reserve legality or full army legality.

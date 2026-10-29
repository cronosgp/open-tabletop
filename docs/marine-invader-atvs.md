# Invader ATVs — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Invader ATVs](https://wahapedia.ru/wh40k11ed/factions/space-marines/Invader-ATVs), source book `000000139`, datasheet `000004247`. Datasheet facts were checked against the verified local Wahapedia Data Export snapshot and the live 11e page on 28 October 2026. This does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The machine-readable [audit](marine-invader-atvs-audit.json) records the relevant export-file and implementation hashes. The runtime profile retains its `2026-10-16T21:03:46+03:00` datasheet export stamp.

## Implemented and checked

- Unit composition is one or two Invader ATVs. Each model has M10, T6, Sv3+, W8, Ld6+, OC2 and no invulnerable save. Costs are 65/130 points for the first two copies and 75/140 for later copies.
- Every model starts with Armoured Impact, Bolt Pistol, Onslaught Gatling Cannon and Twin Bolt Rifle. The test resolves all default profiles through Equipment and AttackPlan. It checks the optional Multi-melta profile through Equipment.
- Each model can replace its own Onslaught Gatling Cannon with one Multi-melta for 5 points. The public preparation choice is checked for each model, rejected for a wrong owner or stale option, and can be reversed with the surcharge refunded.
- The weapon profile test preserves Bolt Pistol Close-quarters, Twin Bolt Rifle Twin-linked/Assault/Rapid Fire 2, Multi-melta Melta 3 and the Onslaught Cannon's Devastating Wounds restriction against MONSTER and VEHICLE targets.
- Aggressive Reconnaissance grants +1 to wound to the unit's ranged attacks in its controlling player's Shooting phase against an enemy unit with no other enemy unit within 6 inches. The test checks the edge-to-edge 6.00/6.01-inch boundary and the modifier in AttackPlan, plus the opponent's phase and Overwatch exclusions.
- The exported RAVENWING keyword stays Chapter-contextual in prepared matches. The test confirms it is absent outside Dark Angels context and granted in Dark Angels context, in line with [The Ravenwing rule](https://wahapedia.ru/wh40k11ed/factions/space-marines/#The-Ravenwing) and the project's keyword-context audit.
- Both players' current catalogs materialize one- and two-model units. The test checks first/tiered copy pricing in construction and saved-list summaries, including split rows. The export and runtime Leader/Support maps contain no attachment links for this datasheet.

The source labels the base size “Use model.” For flat-board contact calculations, the runtime uses a labelled 90 × 52 mm oval footprint proxy. That proxy is not a verified physical base size.

Focused offline verification passed **5/5 processes** with `network: false`, no legacy starter staged and no cleanup diagnostics. The run includes the Invader suite, conditional weapon-trait checks and the shared Leader/Support relation regression. See `.tools/verification/20261028T061032408179Z/results.json` (SHA-256 `2789e8f3c1ec39549d7be5ea344a93f7b653ae6edcef43417e4adefb49e7871b`).

## Limits

This closes only the Invader ATVs shared-book local scope. The “Use model” footprint proxy is an explicit geometry limit. Chapter-book variants and restrictions, complete faction/army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

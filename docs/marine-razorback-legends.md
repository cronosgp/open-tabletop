# Razorback and Relic Razorback (Warhammer Legends) local datasheet audit

**Status (30 October 2026): both sheets are source-bounded for casual army preparation and supported local play.** Their profiles include source characteristics, all weapons and weapon choices, copy prices, transport restrictions and the listed abilities. The local list-admission path accepts the correct Dedicated Transport repetition limits: up to four copies in Incursion and six in Strike Force, subject to points and the rest of the roster rules.

## Source and game-use boundary

The sheets are datasheets `000000129` (Razorback) and `000002720` (Relic Razorback), from Space Marines (Warhammer Legends), source book `000000356`, edition 11. The profiles use the verified local Wahapedia 11e Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved at `2026-10-30T01:33:48.347556+00:00`, revision `2026-10-28T23:48:19+03:00`. The [machine-readable audit](marine-razorback-legends-audit.json) records parent and Legends-slice manifest hashes, the eight raw export CSV hashes and the eight subject-slice table hashes, along with the local verification result.

These are Warhammer Legends sheets. The project enables them for home, store, club and campaign games; competitive-event use requires the organiser's permission. Event-specific points or restrictions need confirmation. The export says `Use model` without hull dimensions, so the simulation uses a labelled 120 mm circular interaction proxy. Exact model footprint, placement and clearance are not certified. The local export and targeted checks have been verified; live-page and event-pack network comparison remains deferred to final integration.

## Represented sheets

| Sheet | Cost per copy | Characteristics | Weapons and abilities |
|---|---:|---|---|
| Razorback | 95 points at each of its listed first, second and third copy tiers | One model; M12, T9, Sv3+, W10, Ld6+, OC2; no invulnerable save | Twin Heavy Bolter, Armoured Tracks, optional Hunter-killer Missile and Storm Bolter, or replace the Twin Heavy Bolter with a Twin Lascannon; Deadly Demise D3, Combat Doctrines, Fire Support |
| Relic Razorback | 105 points at each of its listed first, second and third copy tiers | One model; M12, T9, Sv3+, W10, Ld6+, OC2; no invulnerable save | Same default and optional weapons; replace the Twin Heavy Bolter with a Twin Lascannon, Multi-melta or Twin Assault Cannon; Deadly Demise D3, Combat Doctrines, Fire Support |

Both sheets have the keywords ADEPTUS ASTARTES, SMOKE, FRAME, VEHICLE, DEDICATED TRANSPORT, TRANSPORT and IMPERIUM. They carry up to six ADEPTUS ASTARTES INFANTRY models. They cannot carry models with JUMP PACK, TERMINATOR, CENTURION or GRAVIS, using the exact forbidden class order on each source sheet. Every ranged and melee profile, keyword, option and priced copy tier in the verified export is represented.

## Local rules and list checks

Fire Support opens after the transport shoots. The owner chooses an enemy unit that was actually hit. Friendly ADEPTUS ASTARTES units that disembarked from that specific transport this turn can choose wound dice to re-roll against that marked target; the choice is optional and expires at turn end. The check connects the passenger to its source transport through the actual disembark flow, rejects unhit targets and unrelated units, and keeps the mark scoped to its transport and turn.

Both sheets register Deadly Demise D3 and Combat Doctrines. The Razorback-specific test verifies each D3 value, while the broader transport Deadly Demise timing and resolution remain marked pending in the shared capability registry. The standard category admission regression checks all current profiles at their Incursion and Strike Force copy caps and rejects the next copy; its scope is per-datasheet repetition, not complete army-list certification.

The Relic Razorback export spells the ability name `Fire Supprt`. The runtime normalizes this to `Fire Support` for rules lookup and preserves the exact source spelling in provenance.

## Verification and limits

The dedicated offline test checks both source identities and all eight CSV hashes, all source weapon profiles and choices, preparation loadouts, points, list admission, four/six copy caps, transport capacity and exclusions, actual embark/disembark origin, eligible Fire Support targets and optional wound re-roll selection. The connected batch also runs the catalog and transport regressions. Exact commands, process counts and artifact hashes are recorded in the machine audit and the [verification history](verification/verification-results.md).

This closes the two sheets' declared local source and rules scope. It does not certify a complete army, every cross-datasheet interaction, the exact hull footprint, live network or event-pack equality, tournament acceptance, remote play or human playtesting. Legends status and the footprint proxy remain visible to the player.

# Whirlwind (Warhammer Legends)

## Source and local status

Whirlwind is Space Marines Legends datasheet `000002727` from 11e source book `000000356`. Its source-bounded profile uses the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`; the machine-readable audit records the manifest, source slice and selected CSV hashes.

The profile is available for home, store, club and campaign play under the project's Legends policy. Competitive event use requires organiser permission. Live-page and event-pack point rechecks are deferred to final network integration. The source says “Use model” and gives no base diameter, so the simulation labels its 60 mm circular footprint as a proxy; exact physical clearance is not certified.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 10" | 10 | 3+ | 11 | 6+ | 3 | 175 first copy; 195 second and later copies |

Maximum supported copies: three in Strike Force, subject to the standard Incursion repeat limit. Keywords: ADEPTUS ASTARTES, VEHICLE, FRAME, IMPERIUM and SMOKE. Damaged applies at 4 wounds. The unit has Combat Doctrines and Deadly Demise D3.

Default equipment is one Whirlwind Vengeance Launcher and Armoured Tracks. The two optional additions can be selected independently or together: one Storm Bolter and one Hunter-killer Missile.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Whirlwind Vengeance Launcher | 72" | 6 | 3+ | 8 | -2 | 2 | Indirect Fire, Blast 2 |
| Storm Bolter | 24" | 2 | 3+ | 5 | -1 | 1 | Rapid Fire 2 |
| Hunter-killer Missile | 48" | 1 | 2+ | 14 | -3 | D3+3 | One Shot |
| Armoured Tracks | Melee | 3 | 4+ | 6 | 0 | 1 | — |

**Punishing Bombardment:** after this unit shoots, select one enemy INFANTRY unit hit by its Vengeance Launcher attacks. That target makes a Battle-shock test. The local flow opens the target choice after attack resolution, then lets the target's controller choose any eligible Leadership re-roll before applying the final result.

## Evidence and limits

The dedicated regression checks source identity and hashes, all characteristics, costs and copy limits, default and optional weapons, both optional upgrades together, public preparation choices, Blast attack-count handling and the exact weapon/target gate for Punishing Bombardment. It also checks target ownership, Battle-shock results, Leadership re-rolls and restoration of an already-open reaction window. The focused integration batch covers the catalog, source bindings, copy limits, AttackPlan and related Legends vehicle profiles.

This is a locally validated datasheet and rules scope, ready for casual Legends play in the project. It does not certify every combined army roster, a complete match, the exact physical footprint, current event-pack points, event organiser acceptance, live network-page equality or human playtesting. See the [extended Space Marine inventory](data/space-marine-extended-inventory.md) for overall readiness.

# Cerberus (Warhammer Legends)

## Source and local status

Cerberus is Space Marines Legends datasheet `000001153` from 11e source book `000000356`. Its facts are bound to the verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z` (retrieved 30 October 2026 at `01:32:29 UTC`), revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Space Marines Legends slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The eight relevant parent-export CSV hashes and local verification evidence are recorded in the [machine-readable audit](marine-cerberus-audit.json).

The local catalog marks Cerberus as Warhammer Legends. It is available for casual play under the project's Legends scope; competitive-event use requires organiser approval. The source footprint is `Use model` without a diameter. The simulation shows a labelled 60 mm circular proxy, so exact physical clearance is not certified. Live-page and current event-pack price checks remain deferred to final network integration.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 10" | 12 | 2+ | 18 | 6+ | 6 | 270 |

Maximum supported copies: three in Strike Force, subject to the standard Incursion repeat limit. Keywords: ADEPTUS ASTARTES, FRAME, IMPERIUM, VEHICLE and SMOKE. Core abilities are Combat Doctrines and Deadly Demise D6.

Default equipment is Armoured Tracks and one Cerberus Neutron Pulse Array. The two optional equipment groups are independent: equip one Heavy Bolter, Heavy Flamer, Multi-melta or Storm Bolter; and separately equip two Heavy Bolters or two Lascannons.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Cerberus Neutron Pulse Array | 48" | 3 | 3+ | 16 | -3 | D3+6 | Twin-linked |
| Heavy Bolter | 36" | 3 | 3+ | 5 | -1 | 2 | Rapid Fire 2, Sustained Hits 1 |
| Heavy Flamer | 12" | 3 | — | 5 | -1 | 1 | Blast 2, Torrent |
| Multi-melta | 18" | 2 | 3+ | 10 | -3 | D3+2 | Melta 3 |
| Storm Bolter | 24" | 2 | 3+ | 5 | -1 | 1 | Rapid Fire 2 |
| Two Heavy Bolters | 36" each | 3 each | 3+ | 5 | -1 | 2 | Rapid Fire 2, Sustained Hits 1 |
| Two Lascannons | 48" each | 1 each | 3+ | 12 | -3 | D3+3 | — |
| Armoured Tracks | Melee | 6 | 4+ | 8 | 0 | 1 | — |

**Atomantic Arc-reactor:** if the unit remained stationary this turn, only its Cerberus Neutron Pulse Array ranged attacks gain Lethal Hits. Moving, advancing, falling back, arriving from setup or moving the model suppresses the effect. The option weapons do not gain Lethal Hits from this ability.

## Evidence and limits

The focused local regression checks source identity and snapshot provenance, all characteristics and keywords, the fixed and optional weapon profiles, both independent option groups, default-loadout restoration, the 270-point construction price, three-copy admission and rejection of a fourth copy. It also checks the stationary trigger on the Neutron Pulse Array, suppression after movement/setup, no effect on an optional Heavy Bolter, Combat Doctrines registration and the shared Deadly Demise D6 sequence. The connected offline batch passed 14/14 processes, including catalog, source-field, copy-limit, capability and neighbouring vehicle regressions. At this Cerberus checkpoint, the runtime identity export contained 174 profiles with no missing source IDs.

This closes the declared local Cerberus sheet scope. It does not certify full army legality, every combined ability interaction, exact physical clearance, current live-page/event-pack equality, competitive organiser acceptance, network behavior or human playtesting.

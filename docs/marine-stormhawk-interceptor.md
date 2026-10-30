# Stormhawk Interceptor (Warhammer Legends)

## Source and local status

Stormhawk Interceptor is Space Marines Legends datasheet `000000084` from 11e source book `000000356`. The profile uses the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, whose parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. The source slice manifest SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. Selected export-file hashes and the focused runtime result are recorded in the [machine-readable audit](marine-stormhawk-interceptor-audit.json).

The local profile is available under the project's Warhammer Legends policy. Competitive event use requires organiser approval. The source specifies a 120 × 92 mm oval base; the simulation uses a labelled 60 mm bounding-circle proxy, so exact physical base clearance is not certified. Live-page and event-pack price rechecks remain deferred to final network integration.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | — | 9 | 3+ | 10 | 6+ | 0 | 155 |

Maximum supported copies: three in Strike Force, subject to the standard Incursion repeat limit. Keywords: ADEPTUS ASTARTES, VEHICLE, SMOKE, RAVENWING, IMPERIUM, FLY and AIRCRAFT. The unit has Combat Doctrines and Deadly Demise D3.

Default equipment is one Las-talon, one Skyhammer Missile Launcher, one Twin Assault Cannon and one Armoured Hull. The Las-talon can be replaced with one Icarus Stormcannon. The Skyhammer Missile Launcher can be replaced with one Twin Heavy Bolter or one Typhoon Missile Launcher.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Las-talon | 36" | 2 | 3+ | 10 | -3 | D3+3 | — |
| Icarus Stormcannon | 48" | 6 | 3+ | 7 | -1 | 2 | Anti-Fly 2+ |
| Skyhammer Missile Launcher | 48" | 3 | 3+ | 8 | -1 | 2 | Anti-Fly 2+ |
| Twin Heavy Bolter | 36" | 3 | 3+ | 5 | -1 | 2 | Twin-linked, Rapid Fire 2, Sustained Hits 1 |
| Typhoon Missile Launcher — Krak | 48" | 2 | 3+ | 10 | -2 | D3+3 | — |
| Typhoon Missile Launcher — Frag | 48" | 6 | 3+ | 4 | -1 | 1 | Blast 2 |
| Twin Assault Cannon | 24" | 6 | 3+ | 6 | -2 | 1 | Twin-linked, Sustained Hits 1 |
| Armoured Hull | Melee | 3 | 4+ | 6 | 0 | 1 | — |

**Interceptor:** the Stormhawk's ranged attacks gain +1 to hit against targets with FLY. The shared attack resolver applies the core modifier cap and ignores Hit modifiers for Overwatch.

## Evidence and limits

The focused regression checks source identity and snapshot metadata, all characteristics and weapon profiles, the 155-point construction choice, copy admission, both replacement options and restoring their defaults, mandatory Aircraft Strategic Reserves placement, Deadly Demise D3 and Interceptor against FLY, non-FLY and melee targets. The runtime identity export now contains 172 source-bound profiles with no missing source IDs.

This is a source-bounded local datasheet scope for casual Legends play. It does not certify full army legality, every combined rules interaction, exact physical base clearance, current live-page or event-pack equality, competitive organiser acceptance or human playtesting.

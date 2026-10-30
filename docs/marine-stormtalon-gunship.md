# Stormtalon Gunship (Warhammer Legends)

## Source and local status

Stormtalon Gunship is Space Marines Legends datasheet `000001190` from 11e source book `000000356`. Its facts come from the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, with export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Legends-slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The selected CSV hashes and verification evidence are in the [machine-readable audit](marine-stormtalon-gunship-audit.json).

The local catalog marks this as a Warhammer Legends profile. The project allows Legends in home, store, club and campaign games; competitive events require organiser approval. The source specifies a 120 × 92 mm oval base. The simulation uses a labelled 60 mm bounding-circle proxy, so exact physical base clearance is not certified. Live-page and event-pack price rechecks remain deferred to final network integration.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | — | 8 | 3+ | 10 | 6+ | 0 | 165 |

Maximum supported copies: three in Strike Force, subject to the standard Incursion repeat limit. Keywords: ADEPTUS ASTARTES, RAVENWING, FLY, VEHICLE, AIRCRAFT and IMPERIUM. The unit has Combat Doctrines and Deadly Demise D3.

Default equipment is one Skyhammer Missile Launcher, one Twin Assault Cannon and one Armoured Hull. The Skyhammer Missile Launcher can be replaced by one Twin Heavy Bolter, Twin Lascannon or Typhoon Missile Launcher.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Skyhammer Missile Launcher | 48" | 3 | 3+ | 8 | -1 | 2 | Twin-linked, Anti-Fly 2+ |
| Twin Assault Cannon | 24" | 6 | 3+ | 6 | -2 | 1 | Twin-linked, Sustained Hits 1 |
| Twin Heavy Bolter | 36" | 3 | 3+ | 5 | -1 | 2 | Twin-linked, Rapid Fire 2, Sustained Hits 1 |
| Twin Lascannon | 48" | 1 | 3+ | 12 | -3 | D3+3 | Twin-linked |
| Typhoon Missile Launcher — Krak | 48" | 2 | 3+ | 10 | -2 | D3+3 | — |
| Typhoon Missile Launcher — Frag | 48" | 6 | 3+ | 4 | -1 | 1 | Blast 2 |
| Armoured Hull | Melee | 3 | 4+ | 6 | 0 | 1 | — |

**Strafing Run:** the Stormtalon's ranged attacks gain +1 to Hit against targets without FLY. This is handled by the shared Hit modifier resolver, so normal modifier caps and Aircraft Overwatch restrictions still apply; the bonus does not affect melee attacks.

The shared Aircraft rules place the model in Strategic Reserves during preparation. This sheet's focused regression checks that placement. Wider Aircraft timing, movement and targeting rules are covered by their shared tests and remain a separate rules scope.

## Evidence and limits

The focused suite checks source identity and snapshot metadata, the full characteristic and weapon set, all three Skyhammer replacement choices, restoration of the default weapon, the 165-point construction choice, copy admission, Deadly Demise D3 registration and Strafing Run against FLY, non-FLY and melee targets. At the time of the Stormtalon verification, the runtime identity export recorded 173 source-bound Space Marine profiles with no missing source IDs; the later Cerberus batch raised the current total to 174, recorded in its [machine-readable audit](marine-cerberus-audit.json).

This closes the Stormtalon source-bounded local sheet scope. It does not certify full army legality, every combined ability interaction, profile-specific Deadly Demise trigger/chain cases, exact physical base clearance, current live-page or event-pack equality, competitive organiser acceptance or human playtesting.

# Dreadnought (Warhammer Legends)

## Source and local status

Dreadnought is Space Marines Legends datasheet `000000117` from 11th-edition source book `000000356`. Its facts are bound to the verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 30 October 2026 at `01:32:29 UTC`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Legends slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The eight relevant parent-export CSV hashes and local test evidence are in the [machine-readable audit](marine-dreadnought-audit.json).

The construction catalog marks this as Warhammer Legends. It is available for casual play under the project's Legends scope; competitive-event use requires organiser approval. The exact source-listed 60 mm base is represented. Live-page and current event-pack price checks remain deferred to final network integration.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 6" | 9 | 2+ | 8 | 6+ | 3 | 135 |

Maximum supported copies follow the local Strike Force/Incursion repetition limits. Keywords: ADEPTUS ASTARTES, DEATHWING, WALKER, VEHICLE, SMOKE and IMPERIUM. Core abilities are Combat Doctrines and Deadly Demise 1.

Default equipment is one Assault Cannon, Dreadnought Fist and Storm Bolter. Its three replacement groups are implemented with the source dependency: the Assault Cannon can be replaced by one Heavy Plasma Cannon, Multi-melta or Twin Lascannon; Dreadnought Fist and Storm Bolter can be replaced together by one Missile Launcher and Crushing Feet; or the Storm Bolter can be replaced by one Heavy Flamer. The Heavy Flamer replacement cannot be combined with the Missile Launcher + Crushing Feet package because that package already replaces the Storm Bolter.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Assault Cannon | 24" | 6 | 3+ | 6 | -2 | 1 | Sustained Hits 1 |
| Heavy Plasma Cannon — Standard | 36" | 3 | 3+ | 9 | -2 | 2 | Blast 1, Heavy |
| Heavy Plasma Cannon — Supercharge | 36" | 3 | 3+ | 10 | -3 | 3 | Blast 1, Hazardous, Heavy |
| Multi-melta | 18" | 2 | 3+ | 10 | -3 | D3+2 | Melta 3 |
| Twin Lascannon | 48" | 1 | 3+ | 12 | -3 | D3+3 | Twin-linked |
| Storm Bolter | 24" | 2 | 3+ | 5 | -1 | 1 | Rapid Fire 2 |
| Heavy Flamer | 12" | 3 | — | 5 | -1 | 1 | Blast 2, Torrent |
| Missile Launcher — Frag | 48" | 4 | 3+ | 4 | -1 | 1 | Blast 1 |
| Missile Launcher — Krak | 48" | 1 | 3+ | 10 | -2 | D3+3 | — |
| Dreadnought Fist | Melee | 5 | 3+ | 12 | -2 | 3 | — |
| Crushing Feet | Melee | 5 | 3+ | 6 | 0 | 1 | — |

**Wisdom of the Ancients:** while a friendly Adeptus Astartes Infantry unit is within 6" of this model, that unit's attacks re-roll Hit rolls of 1. The simulation measures base-edge distance, requires the source to be alive and on the battlefield, and checks the target's Astartes and Infantry keywords. Snap Shooting and Indirect Fire retain the core hit re-roll prohibitions.

## Evidence and limits

After the source keyword SMOKE was added, the expanded focused test passed 3/3 processes at `.tools/verification/20261030T094342691431Z/results.json` (SHA-256 `41FD7232A9ABF0E9DE1B4017F4AF6F0FB7E78E0F070F8574817131B36B378E3E`). It checks the source identity and snapshot, characteristics and keywords, every weapon profile, all 12 legal loadout combinations, the Storm Bolter replacement dependency, 135-point admission and copy limits, all three abilities, the Wisdom aura range and eligibility, ranged and melee attack plans, Overwatch and Indirect Fire restrictions, and Deadly Demise 1. The connected catalog/ability/walker/vehicle regression passed 20/20 processes at `.tools/verification/20261030T093959828822Z/results.json` (SHA-256 `2CF0774EE62B33D9B5209AE00F5C2A213FCB4A5E2C482F683682700B2EFBE2F5`). The updated runtime identity export records 175 profiles, includes SMOKE on Dreadnought and has no missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v9.json` (SHA-256 `CE84F29A7AADD431D140BFEAF7F8048027298F43232E4AB8B9A7BDC1EED18DAA`).

This closes the Dreadnought's source-bounded local sheet scope. It does not certify full army legality, all combined rules interactions, current live-page or event-pack equality, competitive organiser acceptance, network behavior or human playtesting.

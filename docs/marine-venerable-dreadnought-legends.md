# Venerable Dreadnought (Warhammer Legends)

## Source and local status

This is a separate Space Marines Warhammer Legends datasheet, not the similarly named Space Wolves datasheet. Its 11th-edition identity is datasheet `000000120` in book `000000356`; the Space Wolves profile remains datasheet `000002801` in book `000000036`.

Facts are bound to the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 30 October 2026 at `01:33:48 UTC`, revision `2026-10-28T23:48:19+03:00`. The parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`; the Space Marines Legends source-slice SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The [machine-readable audit](marine-venerable-dreadnought-legends-audit.json) records the selected source filenames and raw export hashes.

The local catalog labels this one-model, 165-point profile as Warhammer Legends and admits up to three copies under the current Strike Force copy limit. Its exact source footprint is 60 mm. The complete sheet scope is available for casual home, store, club and campaign games. Competitive events require organiser approval. This local sheet result does not certify full army legality, event-pack pricing, every combined rules interaction, network behavior or human playtesting.

## Datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 6" | 9 | 2+ | 8 | 6+ | 3 | 165 |

Keywords: ADEPTUS ASTARTES, IMPERIUM, DEATHWING, VEHICLE, WALKER, DREADNOUGHT and SMOKE. Default equipment is Armoured Feet, Assault Cannon, Dreadnought Fist and Storm Bolter.

### Ranged weapons

| Weapon | Range | A | BS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Assault Cannon | 24" | 6 | 3+ | 6 | -2 | 1 | Sustained Hits 1 |
| Dreadnought Inferno Cannon | 12" | 7 | — | 6 | -1 | 1 | Blast 2, Torrent |
| Heavy Flamer | 12" | 3 | — | 5 | -1 | 1 | Torrent, Blast 2 |
| Heavy Plasma Cannon — Standard | 36" | 3 | 3+ | 9 | -2 | 2 | Blast 1, Heavy |
| Heavy Plasma Cannon — Supercharge | 36" | 3 | 3+ | 10 | -3 | 3 | Hazardous, Blast 1, Heavy |
| Missile Launcher — Frag | 48" | 4 | 3+ | 4 | -1 | 1 | Blast 1, Heavy |
| Missile Launcher — Krak | 48" | 1 | 3+ | 10 | -2 | D3+3 | — |
| Multi-melta | 18" | 2 | 3+ | 10 | -3 | D3+2 | Melta 3 |
| Storm Bolter | 24" | 2 | 3+ | 5 | -1 | 1 | Rapid Fire 2 |
| Twin Autocannon | 48" | 2 | 3+ | 9 | -1 | 3 | Twin-linked |
| Twin Heavy Bolter | 36" | 3 | 3+ | 5 | -1 | 2 | Sustained Hits 1, Rapid Fire 2, Twin-linked |
| Twin Heavy Flamer | 12" | 3 | — | 5 | -1 | 1 | Blast 2, Twin-linked, Torrent |
| Twin Lascannon | 48" | 1 | 3+ | 12 | -3 | D3+3 | Twin-linked |

### Melee weapons

| Weapon | A | WS | S | AP | D |
|---|---:|---:|---:|---:|---:|
| Armoured Feet | 5 | 3+ | 6 | 0 | 1 |
| Dreadnought Fist | 5 | 3+ | 12 | -2 | 3 |

## Wargear choices and abilities

The two source-listed options are independent and reversible:

- Assault Cannon stays, or is replaced by one Dreadnought Inferno Cannon, Heavy Plasma Cannon, Multi-melta, Twin Autocannon, Twin Heavy Bolter, Twin Heavy Flamer or Twin Lascannon: 8 choices including the default.
- Dreadnought Fist and Storm Bolter stay, or are replaced together by one Heavy Flamer and Dreadnought Fist, one Missile Launcher, or one Twin Autocannon: 4 choices including the default.

The runtime exposes all `8 × 4 = 32` legal combinations. Preparation rejects unsupported values and can restore either group independently.

**Abilities:** Combat Doctrines; Deadly Demise 1; Wisdom of the Ancients. Wisdom of the Ancients grants re-rolls of Hit rolls of 1 to attacks by friendly ADEPTUS ASTARTES INFANTRY units within 6" of this unit. Deadly Demise 1 uses the shared destruction trigger, mortal-wound allocation and prevention flow. The source-listed SMOKE keyword is retained for the Smoke core stratagem.

## Verification and limits

The focused command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 900 --only test_venerable_dreadnought_legends` passed **3/3 processes** (import, Python checks and the sheet suite) at `.tools/verification/20261030T101356327760Z/results.json` (SHA-256 `BD2ADEFD27FD649FBC82BCC3D0361D382AF4A0409EBC897FD120CB1DAC8725AE`; `network: false`, no legacy starter staged, no cleanup diagnostics). It checks source identity and stats, every weapon profile and keyword, all 32 combinations, rejection/restoration behavior, the copy ceiling, distinction from the Space Wolves profile, Smoke, Wisdom of the Ancients in AttackPlan and an actual Deadly Demise 1 trigger.

The connected profile/catalog/ability/combat regression passed **14/14 processes** at `.tools/verification/20261030T101420116731Z/results.json` (SHA-256 `1BCB63A5924CE923B803656B0990D2869C0483524EB6C56C7308F60D9487FAF2`; `network: false`, legacy starter staged, no cleanup diagnostics). The runtime identity export contains **177 profiles**, includes source ID `000000120`, and has zero missing source IDs at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v11.json` (SHA-256 `968283C5C46710C91172886BC5EF0CC19E53E83FB5A669CE4C9421C033EB8588`).

This closes the local source-bounded Venerable Legends datasheet scope. Final network integration and event-pack checks remain pending; full army legality and human playtesting are separate gates.

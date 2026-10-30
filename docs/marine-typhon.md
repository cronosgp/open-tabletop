# Typhon (Warhammer Legends)

## Source and local status

Typhon is Space Marines Legends datasheet `000000093` from 11th-edition source book `000000356`. Its facts are bound to the verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 30 October 2026 at `01:32:29 UTC`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Legends slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The eight relevant parent-export CSV hashes and verification evidence are in the [machine-readable audit](marine-typhon-audit.json).

The construction catalog labels Typhon as Warhammer Legends. The implemented one-model datasheet costs 320 points, supports all 15 combinations allowed by its two independent optional weapon groups, and follows the local three-copy Strike Force ceiling. It is ready for casual home, store, club and campaign games within this implemented sheet scope. Competitive events require organiser approval. The source says `Use model` without defining a footprint; the simulation uses a clearly disclosed 60 mm circular proxy, so exact physical clearance is not certified. Live-page and current event-pack checks remain deferred to final network integration.

## Implemented datasheet

| Models | M | T | Sv | W | Ld | OC | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 10" | 12 | 2+ | 18 | 6+ | 6 | 320 |

Keywords: ADEPTUS ASTARTES, FRAME, VEHICLE, IMPERIUM and SMOKE. Default equipment is one Dreadhammer Siege Cannon and Armoured Tracks.

| Weapon | Range | A | BS/WS | S | AP | D | Rules |
|---|---:|---:|---:|---:|---:|---:|---|
| Dreadhammer Siege Cannon | 24" | D6+6 | 3+ | 14 | -3 | D3+3 | Blast 1 |
| Heavy Bolter | 36" | 3 | 3+ | 5 | -1 | 2 | Rapid Fire 2, Sustained Hits 1 |
| Heavy Flamer | 12" | 3 | — | 5 | -1 | 1 | Blast 2, Torrent |
| Lascannon | 48" | 1 | 3+ | 12 | -3 | D3+3 | — |
| Multi-melta | 18" | 2 | 3+ | 10 | -3 | D3+2 | Melta 3 |
| Storm Bolter | 24" | 2 | 3+ | 5 | -1 | 1 | Rapid Fire 2 |
| Armoured Tracks | Melee | 6 | 4+ | 8 | 0 | 1 | — |

The equipment groups are independent:

- Sponsons: replace both with two Heavy Bolters, replace both with two Lascannons, or keep no sponsons.
- Hull weapon: add one Heavy Bolter, Heavy Flamer, Multi-melta or Storm Bolter, or keep no hull weapon.

All 3 × 5 = 15 source-legal combinations are available as reversible preparation choices. The engine rebuilds and restores the selected loadout through its ordinary unit-choice flow.

**Abilities:** Combat Doctrines; Damaged 6; Deadly Demise D6; Sunderer of Fortresses. Damaged 6 imposes -1 to Hit while the model has 1–6 wounds remaining. Deadly Demise D6 uses the shared destruction, mortal-wound allocation and prevention sequence. Sunderer of Fortresses adds +1 Strength and Damage to ranged attacks against VEHICLE targets, or +2 Strength and Damage against FORTIFICATION targets; its melee attacks do not receive the bonus.

## Evidence and limits

The focused Typhon suite passed 3/3 processes (isolated import, Python checks and `test_typhon_legends`) at `.tools/verification/20261030T095847866454Z/results.json` (SHA-256 `0267EE2BC11E027B91690F2EBC7B26B5AF0434709097AFAA23A4BAC2C76EFDFE`; `network: false`, no legacy starter staged, no cleanup diagnostics). The suite checks the source snapshot and identity, all characteristics and keywords, all seven weapon profiles, all 15 combinations, invalid choices, cost and copy admission, setup/restore actions, Smoke, ability registration, VEHICLE/FORTIFICATION AttackPlan bonuses, unchanged melee, the Damaged 6 threshold and live hit modifier, and an actual Deadly Demise D6 trigger.

The connected catalog/ability/combat regression passed 12/12 processes at `.tools/verification/20261030T100032341278Z/results.json` (SHA-256 `FEA6375D208F9D5C0673405413F3548525CF06436A4189A3B3DE2F6E2375E51F`; `network: false`, legacy starter staged, no cleanup diagnostics). The selected suites covered Typhon, Dreadnought, Cerberus, catalog identity, source metadata, copy limits, capabilities, attack planning, current abilities and Combat Doctrines. The refreshed identity export contains 176 runtime profiles and zero missing source IDs, including Typhon's source identity, at `.tools/space-marine-runtime-identities-full-audit-next-20261030-v10.json` (SHA-256 `F5C3C91F9170A0D33B1C5D868E3A057EBF47A8FCF2E37A87D8D670C440B86AFF`).

This closes the source-bounded local Typhon sheet scope. It does not certify full army legality, every combined rules interaction, current live-page or event-pack equality, competitive organiser acceptance, exact physical model clearance, network behavior or human playtesting.

# Land Raider Excelsior datasheet audit

## Current source identity

The verified Wahapedia 11th-edition Data Export identifies Land Raider Excelsior as Space Marines Warhammer Legends datasheet `000000067`, source book `000000356`, with the current faction-page identity [Land Raider Excelsior](https://wahapedia.ru/wh40k11ed/factions/space-marines/Land-Raider-Excelsior). The local source record is bound to snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556Z`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and the Marine Legends source-slice SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The machine-readable [source and runtime audit](marine-land-raider-excelsior-audit.json) records relevant source-file hashes, the source-slice recheck and local verification evidence.

## Datasheet facts represented

- One model: M10, T12, Sv2+, W16, Ld6+, OC5 and invulnerable save 5+. Keywords: ADEPTUS ASTARTES, SMOKE, IMPERIUM, TRANSPORT, FRAME and VEHICLE.
- Wahapedia export price: 250 points for each of the first, second and third copies. Construction admits up to three copies.
- Default equipment: Armoured Tracks, two Godhammer Lascannons and one Grav-cannon. The profile contains all nine source weapon rows, including all three Combi-weapon profiles: Damnatus, Infernus and Purgatus.
- The sheet permits adding one Multi-melta, one Hunter-killer Missile, one Storm Bolter and one Combi-weapon – Damnatus. The shared preparation flow exposes all four choices; One Shot is handled by the attack rules.
- Transport capacity is 12 ADEPTUS ASTARTES INFANTRY spaces. Jump Pack, Gravis and Terminator models each occupy two spaces; Centurion models occupy three. The loadout choices remain those on the source sheet.
- Combat Doctrines, Damaged 5, Deadly Demise D6 and Rites of Battle are present in the profile and connected to the shared rules systems. Damaged 5 applies −1 to Hit when the model has five or fewer wounds remaining. Rites of Battle can reduce one Stratagem targeting a unit with the ability by 1 CP once per battle round per army.

## Game use and remaining boundaries

This is a Warhammer Legends profile, separately labelled in construction. The project records Legends as usable in home, store, club and campaign games; competitive events require organiser approval, following the [Games Workshop Legends guidance](https://www.warhammer-community.com/en-gb/articles/bbnskauh/big-space-marines-news/). Event-specific acceptance and a live network check remain deferred to final integration. The 250-point value above is the verified Wahapedia export value; this increment does not independently reconcile the profile with a live event pack.

The source gives the footprint as `Use model` without a diameter. The local simulation uses a labelled 60 mm circular proxy. The profile is admitted for local construction and rules use, but exact physical clearance, event acceptance, complete-army legality, every cross-unit interaction and network play are not certified. The parent export still has 68 unrelated structural findings; the exact source slice used here has zero scoped findings.

## Verification

The dedicated suite and connected local regression cover provenance, points and copy tiers, characteristics and keywords, the complete weapon inventory, all four preparation choices, the Combi-weapon profiles, transport admission and Centurion/Gravis occupancy, Rites of Battle's army-wide once-per-round limit, the Deadly Demise parameter, and the Damaged 5 threshold. The focused regression passed 15/15 processes with network access disabled. See the [machine-readable audit](marine-land-raider-excelsior-audit.json) and [verification history](verification/verification-results.md).

# Land Speeder — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Land Speeder](https://wahapedia.ru/wh40k11ed/factions/space-marines/Land-Speeder), source book `000000139`, datasheet `000002711`. Datasheet facts were checked against the verified local Wahapedia Data Export snapshot and the live 11e page on 28 October 2026. This does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96e01817ce52cb5ce4deccf`. The machine-readable [audit](marine-land-speeder-audit.json) records source-file and implementation hashes. The runtime profile retains its `2026-10-16T21:03:46+03:00` datasheet export stamp.

## Implemented and checked

- One model costs 105 points at every supported copy tier. Its profile records M14, T8, Sv3+, W9, Ld6+, OC3, and no invulnerable save. The source's 105 × 70 mm base is represented by a labelled bounding-circle collision proxy; this geometry is an approximation.
- The fixed loadout includes Multi-melta, Onslaught Gatling Cannon, Stormfury Missile Launcher and Armoured Impact. Their profiles resolve through Equipment and AttackPlan. Onslaught's Devastating Wounds is suppressed against MONSTER and VEHICLE targets and retained against other targets.
- The sole equipment option replaces Onslaught Gatling Cannon with Pyrecannon at no extra cost. The public setup choice can be reversed, rejects the wrong owner, installs the correct Blast 2/Torrent profile, and leaves unit cost unchanged.
- Deep Strike is attached to the current-reference profile and the public Strategic Reserves declaration records Deep Strike as the arrival method. Shared ingress placement is covered by other reserve workflow checks; this audit does not claim a separate Land Speeder ingress placement test.
- Purgation Run opens after the Land Speeder shoots in its own Shooting phase. The dedicated suite checks the use/pass decision, wrong-owner rejection without mutation, saved decision and attack-frame identity, a D6 roll, the Normal Move placement limit, rejection beyond the rolled distance, phase-close blocking, and the Charge restriction through the end of the turn.
- The source-projected RAVENWING keyword is contextual: it is absent from the prepared shared profile outside Dark Angels context and is granted to this VEHICLE with FLY in Dark Angels context.
- Both players' current Space Marine catalogs materialize the profile. The construction selector, 105-point price, three-copy local custom list and absence of Leader/Support links are checked.

Focused offline verification passed **5/5 processes** at `.tools/verification/20261028T062111243132Z/results.json` (SHA-256 `11f7fb3cad930bfb1047eb2719ff7c75228d269a13a6ee6e39562dc1467bc3e8`; `network: false`; no cleanup diagnostics). The run stages the optional legacy starter data because the official CA fixture uses Necrons as the opposing army. The test only uses that opponent fixture to exercise the Marine-side match flow; it does not verify or certify Necron rules. The Marine sheet is taken from the consolidated current catalog and the pinned Wahapedia export.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_land_speeder --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300
```

Network validation remains deferred to final integration.

## Limits

This closes only the shared-book Land Speeder local scope. The bounding-circle footprint is a geometry approximation. Deep Strike ingress uses the shared reserve implementation and was not separately replayed for this sheet. The optional legacy opponent fixture is not evidence for Necron profiles or army legality. Chapter-book variants and restrictions, full faction/army legality, network behavior, complete-match certification and human playtesting remain outside this result.

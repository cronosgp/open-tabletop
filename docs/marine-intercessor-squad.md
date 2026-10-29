# Intercessor Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Intercessor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Intercessor-Squad), book `000000139`, datasheet `000001157`. Facts were checked against the verified local Wahapedia Data Export snapshot. This scope does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant file hashes are recorded in the [machine-readable audit](marine-intercessor-squad-audit.json). The runtime profile retains its original `2026-10-16T21:03:46+03:00` export stamp; this scope records the separately verified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One Sergeant and four to nine Intercessors; five- and ten-model units cost 85/170 points. Models use 32 mm bases and M6, T5, Sv3+, W2, Ld6+, OC2, with no invulnerable save. The keywords are `ADEPTUS ASTARTES`, `BATTLELINE`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`.
- Every model starts with a Bolt Rifle, Bolt Pistol and Knives and Fists. Both Bolt Rifle profiles, Bolt Pistol and Knives and Fists pass the shared Equipment and AttackPlan checks.
- The Sergeant may replace Knives and Fists with a Chainsword, Power Fist, Power Weapon or Thunder Hammer, and separately replace the Bolt Rifle with a Chainsword, Hand Flamer, Plasma Pistol or Power Weapon. The Bolt Pistol remains equipped. Choices use the public preparation command; the Sergeant-only and player-ownership boundaries, forged values and restore paths are checked.
- One non-Sergeant Intercessor per five models may add a Grenade Launcher. The five-model and ten-model caps, removal/reopened choices, Frag/Krak profiles and eligible model set are checked.
- Bolter Discipline is checked in the owning Shooting phase for attacker/target objective proximity, and excluded in the opponent's phase, melee and when neither unit is within objective range. Tactical Mainstay is checked for Battle-shock and Engagement action eligibility, retained Advance/Fall Back restrictions, shooting after an action and the Charge restriction.
- The current common-book relation map contains fourteen Leader/Supported by links, including five `Supported by` identities. The paired relation suite checks all 153 common-book links; this Intercessor scope also exercises Captain attachment.
- Both players materialize from the current consolidated Space Marines catalog with exact five/ten-model sizes and prices.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the shared Leader/Support relation suite) at `.tools/verification/20261028T051426845028Z/results.json` (SHA-256 `3539e140d8a8761f330ef0ad244626f492895d90de8ed833ecb822b8a3ed4dea`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_intercessor_current --only test_space_marine_leader_links --timeout 300
```

The scope suite uses current Marine catalogs for both players and the local 1,000-point Incursion roster path. The test records that this project's MFM 1.6 fixed-roster validator permits four Battleline copies. That local gate is not an assertion of full current-edition army legality.

## Limits

This closes only the shared-book Intercessor Squad local datasheet scope. Chapter-specific Leader links, Forge World and Legends entries, full faction/army legality, Strike Force validation, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

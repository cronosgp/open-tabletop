# Chaplain — source-bounded local scope

This audit closes the common-book 11th-edition local datasheet scope for the [Chaplain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain), book `000000139`, datasheet `000001174`. The current page was checked on 27 October 2026 in App 2.8.1, Space Marines (11th edition), standard battle context. Fixed datasheet facts were checked against the verified local Data Export snapshot. Chapter, Deathwatch and Boarding Actions variants remain outside this scope.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant export-file hashes and implementation hashes are preserved in the [machine-readable audit](marine-chaplain-audit.json). The runtime profile retains the earlier `2026-10-16T21:03:46+03:00` source stamp; this scope uses the separately identified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One model, 60 points, a 40 mm base and M6, T5, Sv3+, W4, Ld5+, OC1, with a 4+ invulnerable save. The source keywords are `INFANTRY`, `CHARACTER`, `EXPLOSIVES`, `IMPERIUM`, `TACTICUS` and `ADEPTUS ASTARTES`. The fixed loadout has no equipment-option rows: one Absolvor Bolt Pistol and one Crozius Arcanum.
- Equipment matches the exported profiles: Absolvor Bolt Pistol 18 inches, A1, BS3+, S5, AP-2, D2, Close-quarters; Crozius Arcanum melee A5, WS2+, S6, AP-1, D2, Cleave 1. Both weapon routes are checked through Equipment and AttackPlan.
- Both players materialize from the consolidated current Marine catalog. The suite checks current-catalog roster admission, Warlord selection and public attachment preparation. All six shared-book Leader links are tested: Assault Intercessors, Bladeguard Veterans, Hellblasters, Infernus, Intercessors and Sternguard Veterans.
- `Litany of Hate` gives the attached unit Lance on melee attacks while the Chaplain source is alive. The shared planner applies Lance's +1 to Wound only after the unit has charged. Ranged attacks receive no benefit, destroying the Chaplain removes the future effect, and the source weapon data remains unchanged.
- `Spiritual Leader` is offered at the start of Command, Movement, Shooting, Charge and Fight, including the opponent's Fight phase. Once per battle round, it clears Battle-shock from one friendly Adeptus Astartes unit within 6 inches of the Chaplain model; it has no visibility requirement or CP cost. Checks cover the exact 6-inch limit, an out-of-range target, use across both turns, refresh next round, a battle-shocked Chaplain using it on its attached unit, a blocked line of sight, and destroyed/off-board sources.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this current-catalog Chaplain suite and the 153-link Leader/Support relation suite) at `.tools/verification/20261027T100107251997Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chaplain_current --only test_space_marine_leader_links --timeout 300
```

## Limits

This closes only the common-book Chaplain local scope. Chapter-book bodyguards and variants, the separate Deathwatch and Legends links, Boarding Actions, full faction/army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

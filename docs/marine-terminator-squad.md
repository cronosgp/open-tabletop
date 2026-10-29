# Terminator Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Terminator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Squad), book `000000139`, datasheet `000001183`. Datasheet facts were checked against the verified local Wahapedia Data Export snapshot and the live 11e page on 28 October 2026. This does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The machine-readable [audit](marine-terminator-squad-audit.json) records hashes for the relevant export files and implementation. The runtime profile retains its `2026-10-16T21:03:46+03:00` datasheet export stamp.

## Implemented and checked

- One Terminator Sergeant and four to nine Terminators; five- and ten-model units cost 190/380 points for the first two copies and 230/420 points for later copies. Each model uses a 40 mm base and M5, T6, Sv2+, W3, Ld6+, OC1 and a 4+ invulnerable save.
- The shared profile retains the source `ADEPTUS ASTARTES`, `IMPERIUM`, `INFANTRY` and `TERMINATOR` keywords. `DEATHWING` remains Chapter-contextual and is not treated as an unconditional common-book keyword. `TERMINATOR SQUAD` is an internal runtime grouping tag.
- Every model starts with a Storm Bolter and Power Fist. The Sergeant can replace its fist with a Chainfist or Power Weapon; any number of regular Terminators can replace their fists with Chainfists. For every five models, one regular Terminator can replace its Storm Bolter with an Assault Cannon or Heavy Flamer, or take a Cyclone Missile Launcher while retaining its Storm Bolter. The Cyclone's Storm Bolter cannot be replaced. A ten-model unit can take two special guns. Each Cyclone costs 10 points and removing it refunds that surcharge.
- All seven exported weapon families and modes match the source and resolve through Equipment/AttackPlan: Storm Bolter, Power Fist, Assault Cannon, Heavy Flamer, Cyclone frag and krak, Chainfist standard and Hunter, and Power Weapon. The default Power Fist remains equipped when current unit abilities are initialized.
- Fury of the First grants +1 AP to ranged and melee attacks against a target within 9 inches of the Terminator unit. The suite checks the range boundary, AttackPlan output and an attached Terminator Captain.
- Deep Strike and the once-per-battle, per-unit Teleport Homer are checked through battle-start declarations and Rapid Ingress. The token is removed when an enemy move ends within 1 inch; using it reduces Rapid Ingress to 0 CP, requires set-up within 3 inches of the token and more than 8 inches from enemies, and consumes the token.
- The common-book relation map contains six Leader targets (Caanok Var, Captain, Chaplain, Darnath Lysander, Librarian and Marneus Calgar in Terminator Armour) and one `Supported by` target (Ancient in Terminator Armour). The paired relation suite checks all 153 represented common-book Leader/Support links.
- Both players' current catalogs materialize both unit sizes. The local 1,000-point Incursion path admits two copies and rejects a third. This is a local validator limit, not a current-edition army legality claim; source third-plus prices remain available in custom local construction.

## Local validation

Focused offline verification passed **7/7 processes** at `.tools/verification/20261028T055847733207Z/results.json` (SHA-256 `2d63936c3e478b86194ef0782f4417b31ae27660429d6bb2822d4be4f1fce829`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_squad_current --only test_space_marine_leader_links --only test_unit_reserves --only test_terminator_assault_squad --only test_detachment_stratagems --timeout 300
```

Network validation remains deferred to final integration.

## Limits

This closes only the shared-book Terminator Squad local datasheet scope. Chapter-specific variants and links, Forge World, Legends, full faction/army legality, Strike Force admission, network behavior, complete-match certification and human playtesting remain outside this result.

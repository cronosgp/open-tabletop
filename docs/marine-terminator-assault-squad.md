# Terminator Assault Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Terminator Assault Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Assault-Squad), book `000000139`, datasheet `000000118`. Datasheet facts were checked against the verified local Wahapedia Data Export snapshot and the live 11e page on 28 October 2026. This does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The machine-readable [audit](marine-terminator-assault-squad-audit.json) records hashes for the relevant export files and implementation. The runtime profile retains its `2026-10-16T21:03:46+03:00` export stamp.

## Implemented and checked

- One Terminator Sergeant and four to nine Terminators; five- and ten-model units cost 170/340 points for the first two copies and 210/380 for third-plus. Each model uses a 40 mm base and M5, T6, Sv2+, W3, Ld6+, OC1 and a 4+ invulnerable save.
- The shared profile retains the exported `ADEPTUS ASTARTES`, `IMPERIUM`, `INFANTRY` and `TERMINATOR` keywords. `DEATHWING` remains Chapter-contextual and is not treated as an unconditional common-book keyword.
- Every model starts with Twin Lightning Claws (A6, WS3+, S5, AP-2, D1, Twin-linked). Each model may replace them with a Storm Shield and Thunder Hammer (A3, WS3+, S8, AP-2, D3, Devastating Wounds). The shield adds one Wound and costs 5 points per model. All supported models can make this reversible preparation choice; Equipment and AttackPlan accept both weapon profiles.
- Terminatus Assault grants Sustained Hits 1 to Lightning Claws after the unit charges against targets without MONSTER or VEHICLE; Thunder Hammers gain it against MONSTER or VEHICLE. The suite checks both sides of those target gates and confirms neither bonus applies without a charge.
- Deep Strike and the once-per-battle, per-unit Teleport Homer are checked through declaration and Rapid Ingress. The token can be placed at the start of battle, is removed when an enemy ends a move within 1 inch, and enables the unit's zero-CP Rapid Ingress within 3 inches of the token and more than 8 inches from enemies. The setup obeys Deep Strike placement rules, which permit the exception to normal Strategic Reserves edge and deployment-zone limits while preserving enemy distance, terrain, base and coherency checks. See [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) §24.09.
- The shared-book relation map contains six Leader targets (Caanok Var, Captain, Chaplain, Darnath Lysander, Librarian and Marneus Calgar in Terminator Armour) and one `Supported by` target (Ancient in Terminator Armour). The paired relation suite checks all 153 represented common-book Leader/Support links; this sheet suite checks both-player catalog materialization.
- The local 1,000-point Incursion path admits two copies and rejects a third. This is a local validator limit, not a current-edition army legality claim.

## Local validation

Focused offline verification passed **11/11 processes** at `.tools/verification/20261028T054135729338Z/results.json` (SHA-256 `a4a5bf6d4e274a3bee448ad4b70180bd898f0d333eb0a7ab22cdbc8318dec223`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_assault_squad --only test_space_marine_leader_links --only test_unit_reserves --only test_detachment_stratagems --only test_inceptor_squad --only test_kayvaan_shrike --only test_marine_drop_pod --only test_marine_wardens_profile --only test_reiver_squad --timeout 300
```

The regression set also checks Deep Strike reserve metadata and ingress consumers used by other units. Network validation remains deferred to final integration.

## Limits

This closes only the shared-book Terminator Assault Squad local datasheet scope. Chapter-specific variants and links, Forge World, Legends, full faction/army legality, Strike Force admission, network behavior, complete-match certification and human playtesting remain outside this result.

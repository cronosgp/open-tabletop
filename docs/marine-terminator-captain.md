# Captain in Terminator Armour datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in source book `000000139`, datasheet `000000135`, from pinned local Wahapedia export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; Space Marines slice manifest SHA-256: `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Terminator-Armour) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

One model costs 90 points and uses a 40 mm base: M5, T6, Sv2+, W6, Ld6+, OC1, with a 4+ invulnerable save. Shared unconditional keywords include Infantry, Character, Imperium, Terminator, Captain and Adeptus Astartes; conditional `DEATHWING` is excluded. The default weapons are Storm Bolter and Relic Weapon. The two independent preparation replacements are Storm Bolter to Combi-weapon (Infernus, Purgatus or Damnatus profile) and Relic Weapon to Relic Fist. Source abilities include Deep Strike, Leader, Combat Doctrines, Strategic Acumen, Unstoppable Valour and Transhuman Strategist. Common-book Leader targets are Terminator Assault Squad and Terminator Squad.

## Integrated local scope

The current-catalog suite checks both-player admission/materialization, the exact profile, stats, base, points and keywords; default and alternate weapon routes through Equipment and AttackPlan; both independent swaps and all three Combi modes; and Leader, Deep Strike and Combat Doctrines metadata. It exercises Strategic Acumen's public choice, Unstoppable Valour's free Charge re-roll, and Transhuman Strategist's Warlord, CP, once-per-round and source-life boundaries. The shared relation suite verifies both common-book Leader links.

## Verification

Focused offline verification passed **6/6 processes**, including the three current-catalog Terminator leader suites and the shared 153-link Leader/Support suite.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_terminator_ancient --only test_terminator_captain --only test_terminator_chaplain --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T115826825089Z/results.json`; SHA-256 `08f2d566467befc6aaff28ffe5fc8345460c97b7556611bebbf922f458cf3881`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were recorded. Provenance and scope are recorded in [master profile evidence](space-marines-profile-evidence.json) and the [machine-readable audit](marine-terminator-captain-audit.json).

## Open boundaries

This closes only the shared-book Captain sheet scope. Dark Angels `DEATHWING` context and Dark Angels, Deathwatch and Space Wolves Chapter-book targets remain outside the shared 85-sheet scope. Full army legality, other Chapter contexts, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

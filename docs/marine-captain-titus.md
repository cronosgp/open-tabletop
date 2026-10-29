# Captain Titus datasheet audit

## Source and snapshot

This audit covers Captain Titus in shared Space Marines book `000000139`, datasheet `000004187`, from the pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved on 2026-10-21; its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-Titus) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

One Ultramarines Epic Hero model costs 115 points on a 40 mm base: M6, T5, Sv3+, W6, Ld6+, OC1 and a 4+ invulnerable save. Fixed weapons are Bolt Pistol, Master-crafted Bolter and Master-crafted Chainsword. The sheet has no equipment-option rows.

Core abilities are Feel No Pain 5+ and Leader; Army Rules are Transhuman Strategist and Combat Doctrines. The datasheet abilities are Press the Attack, Righteous Fury and Honour of Ultramar.

Six Leader targets belong to the shared book: Bladeguard Veteran Squad, Hellblaster Squad, Intercessor Squad, Sternguard Veteran Squad, Assault Intercessor Squad and Infernus Squad. The page also links Vanguard Veteran Squad from Warhammer Legends book `000000356`; that target is excluded from the common 85-sheet construction scope.

## Integrated local scope

The current-catalog tests check the exact source identity, cost, base, characteristics, keywords, all three weapon profiles through Equipment and AttackPlan, both players' current Marine rosters, the six shared-book Leader links and attachment eligibility. Feel No Pain 5+ is assigned to Titus's model and resolves against normal wounds. Transhuman Strategist is checked through Warlord selection and battle-round CP; Combat Doctrines is exercised through Press the Attack.

Press the Attack grants Sustained Hits 1 against targets without MONSTER or VEHICLE, and against any target while Assault Doctrine is active. Righteous Fury is submitted through the current public choice flow, rejects the opponent, grants +1 melee Strength, heals D3 or conditional 2D3, and remains once per battle per army. Honour of Ultramar checks its 2+ retention roll, removal after Titus's unit fights or at Fight end, and failure on an unmodified 1. The Chainsword's Anti-non-Monster/Vehicle 2+ is checked against Infantry and Vehicle targets.

## Verification

Focused offline verification passed **5/5 processes**: import, Python checks, the Titus datasheet suite, the 153-link Leader/Support relation suite and the conditional weapon-trait regression.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_titus --only test_space_marine_leader_links --only test_marine_conditional_weapon_traits --timeout 300
```

Report: `.tools/verification/20261027T122555251642Z/results.json`; SHA-256 `b8e812cb005c69ef1704c4dd926b30d431793289157f057914d66fb0d9801c75`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were reported. Provenance and boundaries are recorded in the [machine-readable audit](marine-captain-titus-audit.json) and [master profile evidence](space-marines-profile-evidence.json).

## Open boundaries

This closes only Titus's shared-book local datasheet scope. The separately listed Legends Leader target remains unavailable to new construction. Ultramarines/Chapter restrictions, full faction/army legality, network behavior, complete matches and human playtesting remain outside this result. Network validation is deferred to final integration.

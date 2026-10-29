# Captain in Phobos Armour datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in source book `000000139`, datasheet `000002701`, using the pinned local Wahapedia export snapshot `20261021T130623Z` (revision `20260817b`). The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Phobos-Armour) was checked on 2026-10-27. The export snapshot was retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The profile retains its runtime source-export stamp `2026-10-16T21:03:46+03:00`; snapshot file hashes are recorded in [master profile evidence](space-marines-profile-evidence.json).

The sheet is one model on a 40 mm base for 75 points, with M8, T4, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. Its fixed weapons are the Instigator Bolt Carbine, Bolt Pistol and Combat Knife; the local export has no equipment-option rows. Source abilities include Deep Strike, Infiltrators, Leader, Scouts 6, Stealth, Combat Doctrines, Transhuman Strategist, Strategic Acumen and Tactical Fluidity.

## Integrated local scope

- The dedicated suite checks the source profile, characteristics, keywords, fixed equipment and 75-point current-catalog resolution for both players.
- All three fixed weapons pass through Equipment and AttackPlan. The suite checks the listed ability mapping and the tested local effects, including Scouts 6, Strategic Acumen, Transhuman Strategist's Warlord CP and Tactical Fluidity's post-shot and Fight-end choices.
- Tactical Fluidity's normalized public choices preserve the suspended phase-close continuation through save/restore.
- The linked 153-relation suite validates the five common-book Leader targets: Eliminator, Incursor, Infiltrator, Reiver and Scout Squads. The dedicated sheet test materializes and checks the Infiltrator pairing.

## Verification

Focused offline verification passed 5/5 processes: import, Python checks, the dedicated sheet suite, profile parity and the shared Leader-link suite. Network validation was disabled; the optional legacy starter was not staged; no headless cleanup diagnostics were recorded.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_phobos --only test_captain_phobos_profile_parity --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T111545655265Z/results.json`; SHA-256 `98758d7d9fe92b6f05cf6c934a69f875f0457786c1fc1f94a18ee35fd4c13ca2`. Machine-readable scope and provenance: [Captain in Phobos audit record](marine-captain-phobos-audit.json).

## Open boundaries

The Chapter-specific Spectrus Kill Team and Wolf Scouts links are outside the 85 common-book inventory. Whole-army legality, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

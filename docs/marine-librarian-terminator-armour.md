# Librarian in Terminator Armour datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in source book `000000139`, datasheet `000000079`. Datasheet facts come from the pinned local Wahapedia export snapshot `20261021T130623Z` (specification revision `20260817b`), retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Librarian-In-Terminator-Armour) was checked on 2026-10-27; the local export remains authoritative for profile facts.

The sheet is one model on a 40 mm base for 80 points: M5, T6, Sv2+, W5, Ld6+, OC1 and a 4+ invulnerable save. The unconditional shared keywords are Infantry, Character, Imperium, Psyker, Terminator and Adeptus Astartes. The export and current page also show `DEATHWING`; the shared runtime excludes that Chapter-conditional context. The fixed loadout is Force Weapon, Smite (Focused Witchfire and Witchfire), and Storm Bolter. The local export has no equipment-option rows. Source abilities are Deep Strike, Leader, Combat Doctrines, Librarius (psyker level 1), Psychic Hood, Might of Heroes and Thunderous Force.

The two common-book Leader targets are Terminator Assault Squad and Terminator Squad. The sheet also links to Dark Angels, Deathwatch and Space Wolves Chapter-book units, which are outside the shared 85-datasheet admission scope.

## Integrated local scope

- The dedicated suite compares the fixed profile, source identity, base, points, characteristics, unconditional keyword set, conditional `DEATHWING` exclusion and no-option status. It resolves and admits the profile through the consolidated current catalog, with both players materializing the current profile.
- Smite (both profiles), Storm Bolter and Force Weapon pass through Equipment and AttackPlan. The profile metadata includes the source-listed Combat Doctrines ability.
- Deep Strike and Librarius are present on the runtime unit. Psychic Hood provides a unit-wide Feel No Pain 4+ against Psychic attacks, including mortal damage caused by those attacks; the suite checks normal/mortal Psychic damage and the non-Psychic boundary.
- Might of Heroes adds 2 Strength to attached melee weapons after its Fight-phase psychic roll. Thunderous Force adds 6 inches to attached ranged weapon range after its Shooting-phase psychic roll. A roll of 1 Battle-shocks the unit, and psyker level 1 limits the unit to one level-1 Librarius power per battle round. The tests use the public match-choice command and check opponent rejection.
- The shared Leader/Support suite verifies the source relation map, including both common-book targets. The dedicated scenario attaches the Librarian to Terminators and checks Deep Strike and Librarius propagation.

## Verification

Focused offline verification passed **4/4 processes**: import, Python checks, the dedicated datasheet suite and the shared 153-link Leader/Support suite. Network validation was disabled, the optional legacy starter was not staged, and no headless cleanup diagnostics were recorded.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_librarian_terminator --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T114625824325Z/results.json`; SHA-256 `c2d1abc551223301349a1fa7ed9c6195de3c0ca0d7e48d787e03d8bb29904169`. Provenance and the exact bounded scope are recorded in [master profile evidence](space-marines-profile-evidence.json) and the [machine-readable audit](marine-librarian-terminator-armour-audit.json).

## Open boundaries

This closes only the declared common-book local sheet scope. The profile does not establish Dark Angels keyword admission or Chapter-book Leader targets. Whole-army legality, other Chapter contexts, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Librarian in Phobos Armour datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in source book `000000139`, datasheet `000000119`. Datasheet facts are checked against the pinned local Wahapedia export snapshot `20261021T130623Z` (specification revision `20260817b`), retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Librarian-In-Phobos-Armour) was checked on 2026-10-27; the local export remains the authority for profile facts.

The fixed sheet is one model on a 40 mm base for 75 points: M8, T4, Sv3+, W4, Ld6+, OC1, with no invulnerable save. Its keywords are Infantry, Character, Explosives, Imperium, Phobos, Psyker and Adeptus Astartes. Its fixed loadout is Bolt Pistol, Force Weapon and Smite, with Focused Witchfire and Witchfire profiles; the local export contains no equipment-option rows. The five common-book Leader targets are Eliminator Squad, Infiltrator Squad, Incursor Squad, Reiver Squad and Scout Squad.

## Integrated local scope

- The dedicated suite compares the fixed profile, full keyword set, source identity and cost, then resolves and admits the sheet through the consolidated current catalog. Both players materialize the profile from current Marine catalog entries.
- Bolt Pistol, Force Weapon and both Smite profiles pass through Equipment and AttackPlan. The source-listed Combat Doctrines faction ability is now included in this profile's ability metadata.
- The Leader relationship suite checks all 153 common-book Leader/Support links, including the Phobos Librarian's five shared-book targets. The suite also attaches the Librarian to Infiltrators and checks which abilities are shared by every model and which stay with the standalone Leader.
- Psychic Hood's 4+ Feel No Pain applies to normal and mortal damage from Psychic attacks, but not to non-Psychic damage. Soul Sight and Shrouding use the level-1 Librarius limit and their source timing; the tests cover successful effects, the Psychic roll-of-1 Battle-shock result, ownership rejection, pending-decision save/restore, and phase-close continuation.
- Scouts 6 is exercised as a pre-battle move and as a separate Strategic Reserves set-up path, through the public match-choice command and its distance/deployment bounds.

## Verification

Focused offline verification passed **4/4 processes**: import, Python checks, the dedicated datasheet suite and shared Leader-link suite. Network validation was disabled and the optional legacy starter was not staged.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_librarian_phobos --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T113940680686Z/results.json`; SHA-256 `62eaab9a59a5744aac68bb581911e4b3f4bd6f02a5cac1ef8e53096d19991f46`. Source snapshot file hashes and the result are also recorded in [master profile evidence](space-marines-profile-evidence.json) and the [machine-readable scope audit](marine-librarian-phobos-audit.json).

## Open boundaries

This closes only the declared common-book local scope. Spectrus Kill Team and Wolf Scouts are Chapter-book Leader targets outside the 85-sheet shared-book inventory. Whole-army legality, other Chapter contexts, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Kayvaan Shrike datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in source book `000000139`, datasheet `000002708`, using the pinned local Wahapedia export snapshot `20261021T130623Z` (revision `20260817b`). The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Kayvaan-Shrike) was checked on 2026-10-27. The export snapshot was retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The profile retains its runtime source-export stamp `2026-10-16T21:03:46+03:00`; snapshot file hashes are recorded in [master profile evidence](space-marines-profile-evidence.json).

The sheet is one model on a 40 mm base for 95 points, with M12, T4, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. Its fixed weapons are Blackout and Raven's Talons; the local export has no equipment-option rows. The exact common-book Leader targets are Assault Intercessors with Jump Packs and Vanguard Veteran Squad with Jump Packs.

## Integrated local scope

- The dedicated suite checks the source profile and keywords, weapon traits, 95-point local catalog admission, duplicate Epic Hero rejection and current-catalog materialization for both players.
- Blackout and Raven's Talons pass through Equipment and AttackPlan. The suite checks Deep Strike, Lone Operative, Leader, Combat Doctrines, Transhuman Strategist, Trifold Path of Shadow and Echo of the Ravenspire, including Warlord CP, unit-wide Stealth and the 9-inch detection boundary.
- Both exact Jump Pack Leader targets are accepted and an unlisted Intercessor Squad is rejected. The attached Shrike keeps his source defense profile while the bodyguard unit uses its own shared characteristics.
- Echo of the Ravenspire is checked at the end of the opponent's Fight phase for an unengaged unit through the public choice command; the phase-close continuation survives save/restore, and the ability is unavailable while engaged.

## Verification

Focused offline verification passed 4/4 processes: import, Python checks, the dedicated sheet suite and the shared Leader-link suite. Network validation was disabled; the optional legacy starter was not staged; no headless cleanup diagnostics were recorded.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_kayvaan_shrike --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T112204266063Z/results.json`; SHA-256 `b01728c9092c883d6f45f15ab4908c4c09b9a430e9cf379d9c622e54e5f9abbf`. Machine-readable scope and provenance: [Kayvaan Shrike audit record](marine-kayvaan-shrike-audit.json).

## Open boundaries

This is Kayvaan Shrike's common-book scope. Raven Guard Chapter-book interactions, whole-army legality, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

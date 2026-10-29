# Aethon Shaan datasheet audit

## Source and snapshot

This audit covers Aethon Shaan in shared Space Marines book `000000139`, datasheet `000004148`, from the pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved on 2026-10-21; its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Aethon-Shaan) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

One model costs 105 points and uses a 50 mm base: M14, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The fixed weapons are Heavy Bolt Pistol (18 inches, one attack, BS2+, S5, AP-1, D1, Close-quarters) and Claws of Severax (seven attacks, WS2+, S5, AP-2, D2, Twin-linked, Sustained Hits 2 against targets without MONSTER or VEHICLE). The export has no equipment-option rows and no Leader links.

Source keywords include Chapter Master, Character, Epic Hero, Explosives, Infantry, Fly, Imperium, Jump Pack, Smoke, Tacticus, Adeptus Astartes and Raven Guard. Core abilities are Deep Strike, Lone Operative and Stealth; Army Rules are Combat Doctrines and Transhuman Strategist. The datasheet abilities are Master of Shadows and Blackwing Mantle.

## Integrated local scope

The current-catalog tests check the exact profile, base, cost, characteristics, keywords and weapon profiles. Both players' rosters resolve from the consolidated current Marine catalog. The Heavy Bolt Pistol and Claws of Severax pass Equipment and AttackPlan; Claws retain Sustained Hits 2 against Infantry and lose it against a Vehicle.

The dedicated ability suite checks Deep Strike reserve eligibility, Lone Operative while standalone and its removal while attached, Stealth, Combat Doctrines, Warlord selection and Transhuman Strategist's once-per-round CP. It exercises Master of Shadows through the public choice command, rejects the opponent's command, re-rolls both Charge dice, enforces the mandatory result and checks duration through the next Command phase. Blackwing Mantle is checked before and after an ordinary Heroic Intervention, including its CP discount, once-per-phase limit and separation from other uses.

## Verification

Focused offline verification passed **5/5 processes**: import, Python checks, the Aethon ability suite, Aethon profile parity and the shared conditional weapon-trait regression.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_aethon_shaan --only test_aethon_shaan_profile_parity --only test_marine_conditional_weapon_traits --timeout 300
```

Report: `.tools/verification/20261027T122224029113Z/results.json`; SHA-256 `4edc1737cb7f6019dffec4358478db90ad2ffb3d7c7ce170a1a81eda00c97357`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were reported. Provenance and boundaries are recorded in the [machine-readable audit](marine-aethon-shaan-audit.json) and [master profile evidence](space-marines-profile-evidence.json).

## Open boundaries

This closes only Aethon's shared-book local datasheet scope. Raven Guard roster restrictions and Chapter-book interactions, full faction/army legality, network behavior, complete matches and human playtesting remain outside this result. Network validation is deferred to final integration.

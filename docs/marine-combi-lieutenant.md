# Lieutenant with Combi-weapon datasheet audit

## Source and snapshot

This audit covers Lieutenant with Combi-weapon in shared Space Marines book `000000139`, datasheet `000000076`, from the pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved on 2026-10-21; its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-with-Combi-weapon) was checked on 2026-10-27 and matches the bounded local profile. Relevant export-file hashes are in the machine audit.

## Source profile

One Lieutenant with Combi-weapon model costs 85 points on a 40 mm base: M8, T4, Sv3+, W4, Ld6+, OC1, with no invulnerable save. It is equipped with one Combi-weapon (Bolter or Flamer mode) and Paired Combat Blades. The source has no equipment-option rows and no Leader targets.

Core abilities: Feel No Pain 5+, Infiltrators, Lone Operative, Stealth. Army rule: Combat Doctrines. Datasheet abilities: Priority Target Identified (Once per battle, per unit), Evade and Survive (Once per phase, per unit).

## Integrated local scope

Lieutenant with Combi-weapon: one-model 40 mm 85-point profile, all characteristics and seven source keywords; no equipment-option or Leader rows; the Combi-weapon Bolter and Flamer modes and Paired Combat Blades through Equipment and AttackPlan; both players' current Marine catalogs; Feel No Pain 5+ through wound prevention; Infiltrators and Stealth effect predicates; Lone Operative's 12-inch ranged-target boundary; Combat Doctrines registration; Priority Target Identified visible-terrain choice, +3 detection range and end-of-turn expiry; and Evade and Survive's opponent-Movement trigger, 8-inch range, D3+3 distance, unengaged/coherent placement, public use/pass, owner rejection and saved continuation.

## Verification

Focused offline verification passed **3/3 processes**: project import, Python checks and the Lieutenant suite.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_lieutenant_combi_weapon --timeout 300
```

Report: `.tools/verification/20261027T220101252638Z/results.json`; SHA-256 `bcd89f1dfdeb59a6c2bd4ac424ef88eb50e8224c0bda03e9cf99bf29516e2b47`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were reported. The verifier now recognizes this suite as a current-catalog match test; it materializes both sides from the consolidated Marine catalog. See the [machine-readable audit](marine-combi-lieutenant-audit.json) and [master profile evidence](space-marines-profile-evidence.json).

## Open boundaries

Closes only the Lieutenant with Combi-weapon shared-book local sheet scope. The test verifies Infiltrators and Stealth eligibility through the shared effect predicates; it does not expand their generic deployment/detection semantics beyond the other shared-system tests. Chapter restrictions, full faction/army legality, network behavior, complete matches and human playtesting remain outside this result; network validation is deferred to final integration.

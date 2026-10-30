# Captain — 11th edition datasheet scope

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in source book `000000139`, datasheet `000000073`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain) was checked on 27 October 2026 (Space Marines App 2.8.1 / October 2026; stable `Last_update` 2026-10-19 03:47:32). Datasheet facts use the verified local export snapshot `20261021T130623Z`, specification revision `20260817b`, retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the relevant CSV hashes are preserved in [the machine audit](marine-captain-audit.json).

## Profile and equipment

The Captain is one model for 90 points on a 40 mm base: M6, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The default weapons are a Heavy Bolt Pistol, Master-crafted Bolter and Master-crafted Power Weapon. The local construction limit admits one to three copies.

The public preparation selector supports the source replacements and restoration. The Bolter and Heavy Bolt Pistol can be replaced together by a Neo-volkite Pistol or Plasma Pistol; the Bolter can instead be replaced by a Relic Shield; and the Master-crafted Power Weapon can be replaced by a Power Fist. The Relic Shield option explicitly prevents replacing the Master-crafted Power Weapon, so Shield plus Power Fist is rejected in the selector and command handler. The Plasma Pistol exposes Standard and Supercharge profiles. All seven legal packages route their weapons through Equipment and AttackPlan.

## Rules and Leader links

The common-book Leader targets are Company Heroes, Intercessor Squad, Assault Intercessor Squad, Infernus Squad, Hellblaster Squad, Desolation Squad, Bladeguard Veteran Squad, Victrix Honour Guard and Sternguard Veteran Squad. The shared relation suite checks all 153 common-book Leader/Support relations; only targets available in the consolidated runtime catalog can currently materialize as roster pairings.

Strategic Acumen lets the Captain's unit select an active Combat Doctrine in its owner's Command phase. It is owner-checked, usable once in that phase, remains active through the opponent's Command phase, and expires at the start of the next own Command phase. Finest Hour is a public Fight-phase choice, usable once per battle, that adds three attacks and Devastating Wounds to the Captain's melee attacks for that phase. Transhuman Strategist grants one CP once per battle round while the Captain is the Warlord. The Relic Shield adds one wound and the runtime restores the corresponding maximum/current wound values when the loadout changes.

## Verification

Focused offline verification passed **4/4 processes**: Godot import, Python checks, the Captain scope suite and the 153-link Leader/Support suite. The run used `network: false`, `legacy_starter_staged: false` and reported no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_captain_current --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261028T005647625078Z/results.json`; SHA-256 `CCF5DC0FEEC7BA9FF257E982EDBDC551EB3DEB4F4442B0124FCB2BB6B267AA04`. Fixed-profile comparison reports no differences; it does not certify complete behavior. See [the coverage matrix](space-marines-coverage.md), [profile evidence](space-marines-profile-evidence.json) and [verification record](verification/verification-results.md).

This closes only the Captain shared-book local datasheet scope. Chapter-book and Legends targets, full faction/army legality, network behavior, complete-match certification and human playtesting remain outside this closure. Network validation remains deferred to final integration.

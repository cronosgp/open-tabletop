# Caanok Var datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in App. Space Marines book `000000139`, datasheet `000004166`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Caanok-Var) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the export manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The fixed-data comparator found no differences in Caanok's profile, keywords, default equipment, composition, cost or weapon traits. Provenance and file hashes are recorded in the [machine audit](marine-caanok-var-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and a stable `Last_update` marker of `2026-10-19 03:47:32`. This is the shared-book Iron Hands profile, exercised in a standard 11th-edition 1000-point Incursion training match; Chapter detachment rules and Boarding Actions are outside this scope.

## Source profile and equipment

Caanok is one 100-point model on a 50 mm base: M5, T6, Sv2+, W6, Ld6+, OC1 and a 4+ invulnerable save. His fixed weapons are Storm Bolter (Rapid Fire 2) and Axiom (five melee attacks, WS2+, Strength 8, AP-3, Damage 2, Cleave 1). The source has no equipment-option rows. His keywords are Infantry, Terminator, Imperium, Epic Hero, Character and Captain, with Adeptus Astartes and Iron Hands faction keywords.

## Integrated local scope

The dedicated suite checks the exact source profile and current construction catalog, then materializes actual Caanok models from the consolidated Marine catalog for both players. Both fixed weapons pass the shared Equipment and AttackPlan checks. It verifies Deep Strike, Feel No Pain 5+, Leader, Combat Doctrines and Transhuman Strategist alongside Caanok's named abilities.

Caanok can lead Terminator Squad and Terminator Assault Squad, and the test rejects Intercessors. Cerebrex Logic Engine offers a friendly Infantry target through the public preparation command, rejects the opponent without mutation and grants Scouts 6 only to the selected unit. Cold and Calculating exposes the Shooting and Fight choices, applies Lethal Hits to a real Vehicle target and Sustained Hits 1 to a real Infantry target, and grants both target-conditioned traits with Tactical Doctrine. The suite also checks Warlord eligibility and once-per-round CP.

## Verification

The focused offline run passed **3/3 processes**: import, Python checks and `test_caanok_var`. It used `network: false` and `legacy_starter_staged: false`, with no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_caanok_var --timeout 300
```

Report: `.tools/verification/20261027T224248107984Z/results.json` (SHA-256 `30ec9c4ebadb466d031ce4410624af57310b518123a9c02be8a658eec84b6f23`).

## Boundaries

This closes only Caanok's shared-book local datasheet scope. Iron Hands Chapter rules, complete army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Darnath Lysander datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in App. Space Marines book `000000139`, datasheet `000002105`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Darnath-Lysander) was checked on 27 October 2026. Source facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the export manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The reproducible fixed-data comparator reports no differences for Darnath's numeric data, keywords, loadout, composition, cost or weapon traits. File hashes and reports are recorded in the [machine audit](marine-darnath-lysander-audit.json).

## Source profile and equipment

Darnath is one 160-point model on a 50 mm base: M5, T6, Sv2+, W7, Ld6+, OC1 and a 4+ invulnerable save. His only weapon is Fist of Dorn: five melee attacks at WS2+, Strength 10, AP-3 and Damage 3, with Devastating Wounds and Cleave 1. He has the Infantry, Terminator, Epic Hero, Character, Captain and Imperium keywords, plus Adeptus Astartes and Imperial Fists faction keywords. The source lists no equipment-option rows; local admission limits him to one copy.

## Integrated local scope

The dedicated suite checks the source identity, profile, base, cost, copy cap, keywords and fixed loadout; resolves Darnath through the consolidated construction catalog; and materializes current-catalog Space Marines for both players without staging the optional legacy starter. Fist of Dorn passes the shared Equipment and AttackPlan checks.

The test checks the two source-listed Leader targets—Terminator Squad and Terminator Assault Squad—and rejects Intercessors. It confirms Deep Strike, Leader, Combat Doctrines and Transhuman Strategist are registered, allows Darnath to be selected as Warlord, and verifies the Warlord CP is granted only once per round. Rampart is offered at the start of a Movement phase, grants a 2+ invulnerable save until that phase ends, and cannot be reused after activation. Icon of Obstinacy subtracts 1 from ranged and melee Hit rolls against Darnath's unit; its modifier is present in the incoming ranged attack plan.

## Verification

The focused offline run passed **3/3 processes**: import, Python checks and `test_darnath_lysander`. It used `network: false` and `legacy_starter_staged: false`, with no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_darnath_lysander --timeout 300
```

Report: `.tools/verification/20261027T223627402745Z/results.json` (SHA-256 `d34865fc6d9280c34ce515a74cc6e1e756ea9fb3075859277cbc5edb90440a9b`).

## Boundaries

This closes only Darnath's shared-book local datasheet scope. Imperial Fists Chapter rules, complete army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.

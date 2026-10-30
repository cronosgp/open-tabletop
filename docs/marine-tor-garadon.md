# Tor Garadon datasheet audit

## Source and snapshot

This audit covers Tor Garadon in the shared Space Marines 11th-edition App book `000000139`, datasheet `000002473`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Tor-Garadon) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The source lists no equipment-option rows. The identity audit records Space Marines App 2.8.1 / October 2026 and stable `Last_update` `2026-10-19 03:47:32`. The fixed-data comparison reports no Tor profile differences. File hashes and the scope record are in the [machine audit](marine-tor-garadon-audit.json).

## Source profile and weapons

Tor is one 90-point model on a 40 mm base: M5, T6, Sv3+, invulnerable save 4+, W6, Ld6+ and OC1. His keywords include Infantry, Captain, Character, Epic Hero, Gravis, Imperium and Adeptus Astartes; his Chapter keyword is Imperial Fists. His fixed weapons are the Artificer Grav-gun (18 inches, A3, BS2+, S5, AP-1, D2, Anti-Vehicle 2+) and Hand of Defiance (Melee, A5, WS2+, S12, AP-2, D2).

## Integrated local scope

The dedicated suite checks the exact profile and both fixed weapons through Equipment and AttackPlan, the 90-point catalog entry and unique-copy cap, and prepared materialization from the current local Space Marines catalog on both sides. The paired 153-link suite exercises all four source-listed Leader targets. Tor's army and datasheet abilities are checked as follows:

- Transhuman Strategist allows Tor to be selected as Warlord and grants its CP once per battle round.
- Siege Captain adds +2 Strength, AP and Damage against Vehicle, Monster and Fortification targets, leaves ordinary targets unchanged, and carries through ranged and melee AttackPlans against a Vehicle.
- Signum Array selects one visible enemy within 18 inches during the Shooting phase through the public command. The opposing owner is rejected; only the selected unit loses cover for that phase; the use limit and phase expiry are checked.

## Verification

The focused offline run passed **4/4 processes**: import, Python checks, Tor Garadon and the common-book Leader/Support relation suite. It used `network: false`, `legacy_starter_staged: false`, and reported no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tor_garadon --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T235102047086Z/results.json` (SHA-256 `1638836fda91a6020e9ba5c6bf4c66b73cfbbc4526f88e2a688209f819124848`). The fixed-data comparator is `.tools/marine-comparison-20261027-v12.json` (SHA-256 `30e1b54329013cda755058d3990d397036454346c6c54f2388411f3403021420`; Tor differences: none).

## Boundaries

This closes only Tor's shared-book local datasheet scope. Imperial Fists Chapter and detachment roster restrictions, other Chapter interactions, full faction or army legality, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

# Roboute Guilliman datasheet audit

## Source and snapshot

This audit covers Roboute Guilliman in the shared Space Marines 11th-edition App book `000000139`, datasheet `000000138`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Roboute-Guilliman) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; its 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The source lists no equipment-option rows. The source identity audit records Space Marines App 2.8.1 / October 2026 and stable `Last_update` `2026-10-19 03:47:32`. The 27 October fixed-data comparison reports no Guilliman differences. Full provenance and relevant file hashes are in the [machine audit](marine-guilliman-audit.json).

## Source profile and weapons

Guilliman is one 415-point model on a 60 mm base: M8, T10, Sv2+, invulnerable save 4+, W16, Ld5+ and OC4. His keywords are Adeptus Astartes, Ultramarines, Primarch, Monster, Character, Epic Hero, Imperium and Mobile. The fixed equipment is the Hand of Dominion and Emperor’s Sword. The Hand of Dominion has ranged and melee profiles but remains one physical weapon in the runtime.

The Hand of Dominion ranged profile is 36 inches, A4, BS2+, S6, AP-2 and D2, with Rapid Fire 2 and Sustained Hits 1. The Emperor’s Sword is A10, WS2+, S10, AP-3 and D2, with Devastating Wounds and CLEAVE 2. The Hand of Dominion melee profile is A7, WS2+, S14, AP-4 and D4, with Lethal Hits.

## Integrated local scope

The dedicated suite checks the fixed source profile, current catalog admission and materialization for both players, and all three weapon profiles through Equipment and AttackPlan. The source lists eight ability records. The suite checks the seven unit abilities and separately verifies Combat Doctrines:

- Combat Doctrines are active for all three doctrine selections; Codex Adept keeps all three active for Guilliman’s unit.
- Primarch of the XIII grants nearby friendly Adeptus Astartes units Hit and Wound re-rolls of 1 within 6 inches. The suite checks the friendly-only boundary and the actual allied AttackPlan.
- Author of the Codex selects a visible friendly Astartes unit within 12 inches during Movement, adds a doctrine through the owner’s next Command phase, and respects ownership and the one-use limit.
- Feel No Pain is 5+ against each wound. The suite rejects 6+, confirms a roll of 4 fails and a 5 prevents the wound.
- Leader of Astartes grants Lone Operative while Guilliman is within 3 inches of friendly Astartes Infantry; the suite checks distance and source ownership.
- Supreme Commander makes Guilliman the only offered Warlord choice while present; public submission and opposing-player rejection are checked.
- Transhuman Strategist grants the Warlord CP once per battle round.

The source/export review found one runtime mismatch: Guilliman had been receiving Feel No Pain 6+. The runtime now uses the source-listed 5+ value.

## Verification

The focused offline run passed **5/5 processes**: import, Python checks, the Guilliman suite, checked-roster validation and the 153-link common-book Leader/Support suite. It used `network: false`, recorded `legacy_starter_staged: true`, and reported no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_guilliman --only test_roster_validation --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T233923329274Z/results.json` (SHA-256 `b4e5b25c0f995d59ddacb7257727a6ac7d76e80b3da0643be5bc539ffc88eea5`). The fixed-data comparator is `.tools/marine-comparison-20261027-v12.json` (SHA-256 `30e1b54329013cda755058d3990d397036454346c6c54f2388411f3403021420`; Guilliman differences: none).

## Boundaries

This closes only Guilliman’s shared-book local datasheet scope. It does not certify Ultramarines/Gladius roster restrictions, full faction or army legality, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, complete-match certification or human playtesting. Network validation remains deferred to final integration.

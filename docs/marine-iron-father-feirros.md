# Iron Father Feirros datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in App. Space Marines book `000000139`, datasheet `000000127`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Iron-Father-Feirros) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the export manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The fixed-data comparison found no differences in Feirros's profile, keywords, default equipment, composition, cost or mapped weapon traits. The verified local options table contains no Feirros equipment-option rows. Provenance and per-file hashes are recorded in the [machine audit](marine-iron-father-feirros-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and a stable `Last_update` marker of `2026-10-19 03:47:32`. This is the shared-book Iron Hands profile, exercised in a standard 11th-edition 1000-point Incursion training match; Chapter detachment rules and Boarding Actions are outside this scope.

## Source profile and equipment

Feirros is one 85-point model on a 40 mm base: M5, T6, Sv2+, W6, Ld6+, OC1 and no invulnerable save. His fixed weapons are Bolt Pistol, Gorgon's Wrath, Harrowhand and Medusan Manipuli. The source lists no equipment replacements.

His four common-book Leader targets are Aggressor Squad, Eradicator Squad with Heavy Bolters, Eradicator Squad with Melta Rifles and Heavy Intercessor Squad.

## Integrated local scope

The dedicated suite checks the exact source profile and construction catalog, then materializes current Marine rosters for both players. All four fixed weapons pass the shared Equipment and AttackPlan checks. All four source-listed Leader targets are allowed; the suite rejects an unlisted Vehicle, while the relation regression checks all 153 common-book Leader/Support links.

Feel No Pain 5+ applies to Feirros. Rites of Tempering gives his unit -1 to wound when an attack's Strength exceeds the unit's Toughness; equal Strength is not enough. Iron Father grants Lone Operative while Feirros is within 3 inches of a friendly Adeptus Astartes Vehicle, and the effect does not protect him while he is part of an Attached unit.

Master of the Forge can trigger at the start or end of Feirros's move. The test defers the start-of-move choice, then heals a nearby Astartes Vehicle by 3 wounds and grants its attacks immunity to modifiers to Ballistic Skill, Hit rolls and Wound rolls until the start of Feirros's next Movement phase. Feirros can be declared Warlord through the public command; the suite checks ownership rejection and the Transhuman Strategist CP.

## Verification

The focused offline run passed **4/4 processes**: import, Python checks, `test_iron_father_feirros` and `test_space_marine_leader_links`. It used `network: false` and `legacy_starter_staged: false`, with no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_iron_father_feirros --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T230433907954Z/results.json` (SHA-256 `c9a59d264d04518c00a01d07a66b40b7df83514c24314d1f89b43f5aba4528a6`).

## Boundaries

This closes only Feirros's shared-book local datasheet scope. Iron Hands Chapter rules, complete army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.

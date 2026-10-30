# Sword Brethren Squad datasheet audit

## Source and snapshot

This audit covers Sword Brethren Squad in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002798`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sword-Brethren-Squad) was checked on 28 October 2026. Fixed datasheet facts come from verified export snapshot `20261021T130623Z`, retrieved 21 October 2026, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. Parent manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Space Marines slice manifest SHA-256: `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`.

The checked datasheet says 4–10 Sword Brother models, but the local points export has rows only for 4, 5, 9 and 10 models. Those four sizes are admitted with the exported first/second and third-plus prices. Sizes 6–8 stay unavailable in construction; the project does not interpolate their costs.

## Source profile and weapons

The unit has M6, T5, Sv3+, W3, Ld6+, OC1 and 40 mm bases. Its keywords are Infantry, Explosives, Tacticus, Imperium, Adeptus Astartes and Black Templars. The points are:

| Models | First / second copy | Third-plus copy |
|---:|---:|---:|
| 4 | 115 | 135 |
| 5 | 140 | 160 |
| 9 | 250 | 270 |
| 10 | 275 | 295 |

Source weapon profiles:

- Heavy Bolt Pistol — 18", A1, BS3+, S5, AP-1, D1; Close-quarters.
- Hand Flamer — 9", A3, Torrent, S4, AP0, D1; Close-quarters.
- Plasma Pistol — 12", A1, BS3+, S7, AP-2, D1, or S8, AP-3, D2 with Hazardous when supercharged; Close-quarters.
- Chainsword — A6, WS2+, S5, AP-1, D1; Sustained Hits 1.
- Master-crafted Power Weapon — A3, WS2+, S5, AP-2, D2; Lethal Hits.
- Thunder Hammer — A3, WS3+, S8, AP-2, D3; Devastating Wounds.
- Twin Lightning Claws — A5, WS2+, S5, AP-2, D1; Twin-linked.

The five equipment options are represented per model: for every four models, up to two Heavy Bolt Pistols can become Hand Flamers; any number of Chainswords can become Master-crafted Power Weapons; for every four models, one Chainsword can become a Thunder Hammer, one Heavy Bolt Pistol can become a Plasma Pistol, and one Heavy Bolt Pistol plus Chainsword can become Twin Lightning Claws. The loadout selector enforces each independent per-four-model cap and retains all source-legal pistol/melee combinations.

## Integrated local scope

The consolidated local catalog admits the exact priced sizes above, all weapon profiles, Combat Doctrines, and all five wargear options. The model choice has explicit loadout packages, including default restoration. Existing Black Templars Leader links now resolve to this admitted endpoint; the focused regression checks Chaplain Grimaldus attaching to the unit and the broader Leader-link matrix.

Exploit their Cowardice is checked at the start of an enemy Fall Back move. The movement draft records which Sword Brethren units were engaged with that specific enemy. When the Fall Back move is confirmed, the reaction is offered only if the recorded Sword Brethren unit is now unengaged. The optional Normal Move uses the persisted reaction decision, caps each model at 6 inches and checks terrain, path, base overlap, coherency and ending outside Engagement Range before confirmation.

## Verification

Focused offline verification passed **4/4 processes**: Godot import, Python architecture/verification checks, `test_sword_brethren_squad`, and `test_space_marine_leader_links`.

```text
python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_sword_brethren_squad --only test_space_marine_leader_links
```

Report: `.tools/verification/20261028T180348989697Z/results.json` (SHA-256 `DD1D23D5E1B1D4F9F527AF51FB5E61D04E7CF190742AA60E9D60372E71D42C16`; `network: false`, legacy starter not staged, no cleanup diagnostics). The tests check the two cost tiers, every weapon family, four- and nine-model replacement limits, current-catalog materialization, the Leader endpoint, the captured Fall Back trigger, the still-engaged restriction, rejection beyond six inches, and a confirmed legal reaction move.

## Boundaries

This closes Sword Brethren Squad's source-bounded local datasheet scope. Six-, seven- and eight-model choices remain blocked because the verified local export has no costs for them. This does not certify complete Black Templars or Space Marine army legality, cross-sheet list restrictions, network behavior, final integration or human playtesting. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are separate inventories.

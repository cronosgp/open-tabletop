# Baal Predator datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000000168` in source book `000000021` for Warhammer 40,000 11th edition. The [current Wahapedia datasheet](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Baal-Predator) was checked on 28 October 2026. It identifies the Blood Angels App and lists “Use model” for footprint measurement; no separate datasheet page revision is published. The current page's profile, options, abilities and points were checked against the pinned local export.

Fixed datasheet facts come from verified Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, updated `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The derived 14-sheet Blood Angels App slice was built offline from that snapshot; its manifest SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`. The slice validator reported zero structural errors. The parent-wide validator reported 68 unrelated errors elsewhere in the export.

Relevant source-file SHA-256 values:

| File | SHA-256 |
|---|---|
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Integrated scope

The one-model vehicle costs 135 points for its first two copies and 150 points for each third-or-later copy, with a three-copy cap. Its characteristics are M12, T10, Sv3+, W11, Ld6+, OC3 and no invulnerable save. It carries the source keywords Vehicle, Frame, Imperium, Smoke, Blood Angels and Adeptus Astartes.

The default equipment is one Twin Assault Cannon and Armoured Tracks. Army Preparation can replace the cannon with a Baal Flamestorm Cannon; select a paired package of two Heavy Bolters, two Heavy Flamers or no sponson weapons; and add/remove a Storm Bolter and Hunter-killer Missile. Replacing the sponson package replaces both weapons, so mixed pairs cannot be selected. These equipment choices do not change the source cost.

The registered abilities are Damaged 4, Deadly Demise D3, Combat Doctrines and Overcharged Engines. Damaged 4 applies the shared -1 Hit modifier at four or fewer remaining wounds. Deadly Demise uses the shared D3 value. Overcharged Engines offers the player a free Advance re-roll in the shared pending-roll decision, uses the host's die source and does not consume CP or record a stratagem use.

The source requires the model itself for footprint measurement. Runtime placement currently uses a **provisional 90 mm circular collision proxy**. That value is a gameplay approximation, not an exported base dimension or a tabletop-measurement claim.

## Local checks and limits

Direct Godot 4.7.2 headless runs passed with zero failures:

- `tests/test_baal_predator.gd` — source identity and snapshot, profile/weapons, cost tiers and copy cap, paired equipment choices, invalid loadout rejection, Damaged threshold, Deadly Demise value, public Advance re-roll and zero CP use.
- `tests/test_capabilities.gd` — registry source/validation metadata and the enabled Overcharged Engines capability.
- `tests/test_blood_angels_captain.gd` — regression for the corrected Blood Angels slice manifest.
- `tests/test_sanguinary_priest.gd` — regression for the sibling Blood Angels App profile.
- `tests/test_implemented_catalog.gd` — 119 selectable profiles, four excluded, zero failures.

The local Chapter auditor verifies all 23 snapshot files, identifies 76 Chapter sheets, and reports 34 runtime profiles / 42 missing profiles, including three of 14 Blood Angels sheets. These checks establish the declared local sheet scope only. Full army legality, other Chapter books, network validation and final host/client integration remain open. The shared Deadly Demise capability still has broader trigger/chain-resolution checks pending.

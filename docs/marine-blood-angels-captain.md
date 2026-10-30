# Blood Angels Captain datasheet audit

## Source and snapshot

This audit covers Blood Angels Captain datasheet `000003831` in the Blood Angels App book `000000021`, for Warhammer 40,000 11th edition. The [Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Blood-Angels-Captain) was checked on 28 October 2026. Its page did not state a separate revision identifier; the local source row records errata date `03.10.2026`.

Fixed datasheet facts come from verified Wahapedia Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`. The export update timestamp is `2026-10-21T16:06:23+03:00`; specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Blood Angels slice manifest SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`.

Relevant verified export file hashes:

| File | SHA-256 |
|---|---|
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Datasheets_models.csv | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_unit_composition.csv | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| Datasheets_abilities.csv | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| Datasheets_keywords.csv | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| Datasheets_leader.csv | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Source profile and equipment

The one-model unit costs 90 points and uses a 40 mm base: M6, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. Keywords are Blood Angels, Adeptus Astartes, Tacticus, Imperium, Character, Captain, Infantry and Explosives.

| Weapon | Profile | Keywords |
|---|---|---|
| Heavy Bolt Pistol | 18", A1, BS2+, S5, AP-1, D1 | Close-quarters |
| Inferno Pistol | 9", A1, BS2+, S8, AP-3, D3+2 | Melta 1, Close-quarters |
| Master-crafted Chainsword | A7, WS2+, S5, AP-1, D2 | — |
| Power Fist | A5, WS2+, S8, AP-2, D2 | — |
| Relic Weapon | A6, WS2+, S6, AP-2, D2 | — |

The default equipment is a Heavy Bolt Pistol and Master-crafted Chainsword. The pistol can be replaced with an Inferno Pistol, and the chainsword can independently be replaced with a Power Fist or Relic Weapon. The public preparation flow exposes all six legal combinations and rejects unsupported values.

## Abilities and Leader relation

The profile maps Core Leader, Combat Doctrines, Transhuman Strategist, Finest Hour and Strategic Acumen to existing local rules. Finest Hour adds three melee attacks and Devastating Wounds to this model for its Fight activation, once per battle per unit. Strategic Acumen selects a Combat Doctrine for the unit until the start of the controlling player's next Command phase. Equipment now applies Finest Hour by the admitted ability mapping, preserving the shared-book Captain behavior while supporting this datasheet.

The exact Leader targets are Sternguard Veteran Squad, Company Heroes, Intercessor Squad, Assault Intercessor Squad and Infernus Squad. The profile has its own chapter-book identity, weapon options and Leader endpoints; it is not an alias for the shared-book Captain.

## Verification and boundaries

Focused offline verification passed 4/4 processes: Godot import, Python checks, `test_blood_angels_captain` and `test_captain_current`. The result is `.tools/verification/20261028T184631888100Z/results.json`, SHA-256 `B8C64725509F0A2CD39C6A5F983CC02033AF45D9743F9A99F9DC8046B41BCC8A`; network was disabled, no legacy starter was staged and no cleanup diagnostics were reported. Checks cover source identity and hashes, fixed facts, all weapon profiles, catalog admission, both-player chapter-context materialization, exact Leader endpoints, public equipment choices, all six packages through Equipment and AttackPlan, Warlord CP, Strategic Acumen and Finest Hour. The regression also preserves the shared-book Captain's Finest Hour behavior.

The wider catalog/capability/Leader regression also passed 7/7 processes at `.tools/verification/20261028T184845097646Z/results.json` (SHA-256 `2AC7C23273085737DE304D5A3518C28CEEDA69F08B217FE7F15C40ED72FE09E4`; `network: false`). That targeted run staged the existing legacy starter for supplemental historical fixtures; it verified 117 selectable current-reference Marine profiles and four excluded historical/non-Marine entries. No cleanup diagnostics were reported.

This closes only the Blood Angels Captain's source-bounded local datasheet scope. It does not certify complete Space Marine army legality, network behavior, final host/client integration, or human playtesting. With the subsequent Sanguinary Priest and Baal Predator integrations, eleven Blood Angels profiles remain without runtime records; Forge World, Legends and alternate modes are separate inventories.

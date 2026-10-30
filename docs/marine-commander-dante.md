# Commander Dante datasheet audit

## Source and snapshot

This audit covers Commander Dante, Blood Angels App datasheet `000000151` in source book `000000021`, for Warhammer 40,000 11th edition. The [Wahapedia 11e datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Commander-Dante) was checked on 28 October 2026; it identifies the Blood Angels App and does not publish a separate revision identifier.

Fixed datasheet facts use verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the 14-sheet Blood Angels App slice SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`. The slice validator reported zero slice errors. The parent-wide validator reported 68 unrelated relational-export errors.

| Export file | SHA-256 |
|---|---|
| `Last_update.csv` | `e39235a323535cd23fbcbc3813bf939df34511b9a10203ca93377700e2ec7485` |
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168e446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Integrated local scope

Dante is one model on a 40 mm base, with M12, T5, Sv2+, W6, Ld6+, OC1 and a 4+ invulnerable save. He costs 140 points and is limited to one copy. His keywords are Blood Angels, Adeptus Astartes, Epic Hero, Jump Pack, Character, Explosives, Fly, Infantry, Imperium, Tacticus and Chapter Master.

| Weapon | Profile | Keywords |
|---|---|---|
| Perdition Pistol | 9", A1, BS2+, S10, AP-3, D3+2 | Sustained Hits 1, Melta 2, Close-quarters |
| The Axe Mortalis | Melee, A8, WS2+, S8, AP-3, D2 | Lethal Hits |

Deep Strike, Leader, Combat Doctrines and Transhuman Strategist use existing shared rules. Dante can lead Assault Intercessors With Jump Packs, Vanguard Veteran Squad With Jump Packs and Sanguinary Guard. His Warlord designation participates in Transhuman Strategist's once-per-round Command Point effect.

Death Mask of Sanguinius opens at the start of the Fight phase and tests every enemy unit within 6 inches of Dante at -1 to the Battle-shock roll; it includes units without a Character and records the result before the Fight sequence resumes. Warden of the Imperium Nihilus keeps Assault and Tactical Doctrines active for Dante's unit alongside any other active doctrine, including after attachment.

## Local checks and limits

The focused offline verification checks the pinned identity and fixed profile, both weapons through Equipment and AttackPlan, current-catalog price and one-copy admission, all three Leader targets, Warlord CP, attached-unit doctrine behavior, Fight-phase Battle-shock targeting/range and continuation through a serialized public decision. See the machine-readable [Dante audit](marine-commander-dante-audit.json) for the verification artifact. This closes only the declared source-bounded local sheet scope. Full Space Marine army legality, network behavior and human playtesting remain open.

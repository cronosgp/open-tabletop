# Sanguinary Priest datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000000158` in source book `000000021`, for Warhammer 40,000 11th edition. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sanguinary-Priest) was checked on 28 October 2026. The page identifies the Blood Angels App (11th edition) and does not publish a separate page revision; `Source.csv` records the App errata date as 3 October 2026.

Fixed datasheet facts were taken from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The derived 14-sheet Blood Angels App slice was built offline from that snapshot; its manifest SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`. Its structural validation reported zero slice errors. The parent-wide validator reported 68 unrelated errors elsewhere in the relational export.

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

The slice can be regenerated without network access with:

```powershell
python tools/slice_wahapedia.py --snapshot .tools/wahapedia/11e/space-marines/20261021T130623Z --source-id 000000021 --output .tools/wahapedia/11e/space-marine-chapter-slices/blood-angels-20261028
```

## Integrated scope

The one-model unit costs 60 points and uses a 40 mm base: M6, T5, Sv3+, W4, Ld6+, OC1, with no invulnerable save. Its keywords are Blood Angels, Adeptus Astartes, Imperium, Tacticus, Infantry, Character and Explosives.

| Weapon | Profile | Keywords |
|---|---|---|
| Absolvor Bolt Pistol | 18", A1, BS3+, S5, AP-2, D2 | Close-quarters |
| Chainsword | Melee, A5, WS3+, S5, AP-1, D1 | — |

The fixed loadout has no equipment choices. Blood Chalice adds +1 Toughness to every living model in the Priest’s unit, including an attached bodyguard unit. The shared defensive profile removes the bonus when the Priest is destroyed. Narthecium can be used once per turn per unit in the owner’s Command phase to heal D3+1 wounds; it reuses the existing shared healing allocation and confirmation flow.

The exact eight Support targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Company Heroes, Desolation Squad, Hellblaster Squad, Infernus Squad, Intercessor Squad and Sternguard Veteran Squad. Heavy Intercessor Squad is not an eligible target.

## Local checks and limits

Direct Godot 4.7.2 headless runs passed with zero failures:

- `tests/test_sanguinary_priest.gd` checks the source identity and hashes, points, model characteristics, both weapons, exact Support links, catalog admission, source-restricted attachment, attached-unit Toughness, source loss after destruction and the shared D3+1 healing flow.
- `tests/test_implemented_catalog.gd` reports 118 selectable profiles and four excluded profiles.

The isolated `tools/verify.py --profile focused --only test_sanguinary_priest` run timed out during Godot’s project-wide class import at 85%, before any test suite launched; it produced no verification result JSON. That timeout is not counted as a passing check. These local checks do not certify full Space Marine army legality, network integration or human playtesting.

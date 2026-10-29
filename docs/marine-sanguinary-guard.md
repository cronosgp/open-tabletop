# Sanguinary Guard datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000000165` in source book `000000021` for Warhammer 40,000 11th edition. The [Wahapedia 11e datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sanguinary-Guard) was checked on 28 October 2026; the page identifies the Blood Angels App (11th edition) and does not publish a separate revision identifier.

Fixed datasheet facts use verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the 14-sheet Blood Angels App slice SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`. The slice validator reported zero slice errors. The parent-wide validator reported 68 unrelated relational-export errors.

| Export file | SHA-256 |
|---|---|
| `Last_update.csv` | `e39235a323535cd23fbcbc3813bf939df34511b9a10203ca93377700e2ec7485` |
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

## Integrated local scope

The unit contains 3 or 6 models, each on a 40 mm base, with M12, T5, Sv2+, W3, Ld6+, OC2 and a 4+ invulnerable save. First and second copies cost 135/275 points; third and later copies cost 150/290 points. The construction profile admits only the export-priced 3- and 6-model sizes and locally supports up to three copies. The datasheet keywords are Blood Angels, Adeptus Astartes, Jump Pack, Infantry, Explosives, Fly, Imperium and Tacticus.

| Weapon | Profile | Keywords |
|---|---|---|
| Angelus Boltgun | 18", A3, BS2+, S5, AP-1, D1 | Assault, Close-quarters |
| Inferno Pistol | 9", A1, BS2+, S8, AP-3, D3+2 | Melta 1, Close-quarters |
| Encarmine Weapon | Melee, A4, WS2+, S6, AP-2, D2 | Lance |

For every three models, one Angelus Boltgun can be replaced by an Inferno Pistol. Army Preparation exposes reversible per-model choices, enforces that limit after a Captain With Jump Pack joins the unit, and installs the selected profile through the shared Equipment path. Captain With Jump Pack and Commander Dante are implemented Leader targets; Dante's datasheet audit covers his own attached-unit doctrine effect.

Deep Strike and Combat Doctrines use the existing shared rules paths. Heirs of Azkaellon applies -1 to Wound when an attack targeting the unit has Strength greater than its Toughness. Angelic Visage applies -1 to Hit to melee attacks targeting the unit. Both defensive effects enter the shared AttackPlan and modifier cap.

## Local checks and limits

The focused offline verification passed **6/6 processes** at `.tools/verification/20261028T204624103776Z/results.json` (SHA-256 `695056331297C00C2DAB81073C69C76971FED6035A9B1A4A5DA2615F160DA691`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sanguinary_guard --only test_implemented_catalog --only test_capabilities --only test_space_marine_leader_links --timeout 300
```

The checks cover source identity, hashes, characteristics, priced compositions, costs and copy limit; all three weapons through Equipment and AttackPlan; reversible Inferno Pistol choices and per-three-model limits; both-player catalog materialization; the Captain With Jump Pack Leader link; Deep Strike and Combat Doctrines; and the melee Hit and Strength-gated Wound modifiers. This closes only the declared local Guard scope. Full Blood Angels and Space Marine army legality, all Leader combinations, network behavior and human playtesting remain open; Dante's own attachment and doctrine path are covered in his separate audit.

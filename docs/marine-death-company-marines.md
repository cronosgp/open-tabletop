# Death Company Marines datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000001997` in source book `000000021` for Warhammer 40,000 11th edition. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Death-Company-Marines) was checked on 28 October 2026; the page does not publish a separate revision identifier.

Fixed facts use the verified Wahapedia Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Blood Angels App slice SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`.

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

The raw export remains ignored under `.tools`. These hashes identify the pinned snapshot; recheck a later adopted export before updating this profile.

## Integrated local scope

The unit has 5 or 10 models. The first and second copies cost 90/170 points; each third-or-later copy costs 105/185 points, with a three-copy construction limit. Each model uses a 32 mm base and has M6, T5, Sv3+, W2, Ld6+, OC1. The fixed profile records the Blood Angels, Adeptus Astartes, Death Company, Infantry, Tacticus, Explosives and Imperium keywords. Each model starts with a Heavy Bolt Pistol and Chainsword.

During Army Preparation, any model can replace its Chainsword with Bolt Rifle Fire and a Combat Blade. For every five models, one model may replace its Chainsword with an Eviscerator; one Bolt Rifle carrier may add a Grenade Launcher. One model in the unit may replace its Heavy Bolt Pistol with a Hand Flamer, Inferno Pistol or Plasma Pistol. One model may replace its Chainsword with a Power Fist, Power Weapon or Thunder Hammer. The implementation enforces those unit-level limits, restricts the Grenade Launcher to a Bolt Rifle carrier and does not change points for these source-listed options.

The local ability scope includes Combat Doctrines, Feel No Pain 6+, Black Rage and An Honourable Death in Combat. Black Rage grants melee Hit rerolls of 1. If the unit is outside either supporting range—6 inches from a friendly Blood Angels Character or 12 inches from a friendly Chaplain—it cannot Fall Back and has OC 0. An Honourable Death in Combat adds Sustained Hits 1 while below Starting Strength and Sustained Hits 2 while below half-strength; the half-strength boundary itself remains at Sustained Hits 1.

## Local checks and limits

The targeted offline verification passed **5/5 processes** at `.tools/verification/20261028T195743838575Z/results.json` (SHA-256 `2679C2D11638DD385AB4C5F1B444FA0F1C345D378A11A96C470BF459DF9EABD9`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_marines --only test_implemented_catalog --only test_capabilities --timeout 300
```

The suite checks the pinned source identity and facts, weapon profiles, option counts, both point tiers, public preparation choices and limits, FNP, Black Rage melee/support/Fall Back/OC effects, Honourable Death attack bands, catalog count and capability records. This closes only the declared local scope. It does not certify full Blood Angels or Space Marine army legality, network behavior, all roster interactions or human playtesting. See the [machine-readable audit](marine-death-company-marines-audit.json).

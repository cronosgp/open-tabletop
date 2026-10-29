# Marshal datasheet audit

## Source and snapshot

This audit covers the Marshal in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002796`. The [Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Marshal) was checked on 28 October 2026. Its page identifies the Black Templars App but exposes no separate per-sheet revision marker. Fixed facts come from verified local export snapshot `20261021T130623Z`, retrieved 21 October 2026 at 19:46:58 UTC, specification revision `20260817b` and export timestamp `2026-10-21 16:06:23 GMT+3`.

The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice manifest SHA-256 is `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`. The relevant verified source tables and file SHA-256 values are:

| Export file | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Source profile and weapons

Marshal is one model for 80 points on a 40 mm base: M6, T5, Sv3+, invulnerable save 4+, W5, Ld6+ and OC1. Its keywords are Infantry, Captain, Character, Explosives, Imperium, Tacticus, Adeptus Astartes and Black Templars.

- Plasma Pistol — Standard: 12", A1, BS2+, S7, AP-2, D1; Close-quarters.
- Plasma Pistol — Supercharge: 12", A1, BS2+, S8, AP-3, D2; Hazardous, Close-quarters.
- Combi-weapon — Damnatus: 12", A1, BS2+, S9, AP-3, D3+2; Melta 2.
- Combi-weapon — Infernus: 12", A3, Torrent, S4, AP0, D1; Blast 1.
- Combi-weapon — Purgatus: 24", A2, BS2+, S7, AP-2, D2.
- Master-crafted Power Weapon — A7, WS2+, S6, AP-2, D2; Lethal Hits.

At no additional points, the Plasma Pistol can be replaced by a Combi-weapon. Army preparation exposes that choice and can restore the default pistol.

## Integrated local scope

The current catalog admits one Marshal for 80 points. The source-listed Leader targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Infernus Squad, Intercessor Squad, Sternguard Veteran Squad, Crusader Squad and Sword Brethren Squad. Sword Brethren is now an admitted target for its source-priced 4/5/9/10-model sizes; the unpriced 6–8-model sizes remain unavailable.

Inspirational Exemplar grants +1 to Hit to the unit's melee attacks. Pious Fervour is an optional choice when the unit is selected to fight. It counts enemy units within 6 inches of the Marshal, caps the bonus at +3 Attacks, applies those attacks only to the Marshal's melee weapons and expires when that Fight activation ends. The focused checks cover the count cap, a fourth enemy outside range, attached bodyguards receiving no bonus, the shared melee Hit modifier and cleanup after normal or empty fights.

The profile registers Leader, Combat Doctrines and Transhuman Strategist through the shared rules path. The focused Marshal suite checks its Warlord eligibility and ability registration; it does not independently re-audit the shared Transhuman Strategist CP-resolution path.

## Verification

Focused offline verification passed **3/3 processes**: Godot import, Python checks and `test_marshal`.

```text
python tools/verify.py --profile focused --only test_marshal --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

Report: `.tools/verification/20261028T145731924167Z/results.json` (SHA-256 `B71D338D901E50E286C663C980AAA2532548C2D76F6C077A32D67CA2D78CCC44`; `network: false`, no legacy starter staged, no cleanup diagnostics). These checks validate only the declared local scope.

## Boundaries

This closes only the Marshal's source-bounded local datasheet scope. It does not certify the full Black Templars or Space Marine roster, every Leader endpoint, detachment Force Disposition rules, network behavior or human playtesting. Crusader Squad remains partial; Sword Brethren Squad is admitted for its priced sizes, while 6–8-model choices remain blocked. Forge World, Legends and alternate modes are outside the current Chapter-book inventory. Network validation remains deferred to final integration.

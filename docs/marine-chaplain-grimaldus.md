# Chaplain Grimaldus datasheet audit

## Source and snapshot

This audit covers Chaplain Grimaldus in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002792`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain-Grimaldus) was checked on 28 October 2026. Fixed datasheet facts come from the verified local export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice manifest SHA-256 is `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`.

The slice files and SHA-256 values used for reconciliation are recorded in the [machine-readable audit](marine-chaplain-grimaldus-audit.json): `Datasheets.csv`, `Datasheets_abilities.csv`, `Datasheets_keywords.csv`, `Datasheets_models.csv`, `Datasheets_wargear.csv`, `Datasheets_unit_composition.csv`, `Datasheets_models_cost.csv` and `Datasheets_leader.csv`.

## Source profile

The 120-point unit contains one Chaplain Grimaldus and three Cenobyte Servitors. Grimaldus has M6, T5, Sv3+, W5, Ld5+, OC1, a 4+ invulnerable save and a 40 mm base. Each Servitor has M6, T4, Sv3+, W1, Ld8+, OC1, a 4+ invulnerable save and a 28.5 mm base. Their characteristics, keywords, bases and weapons are stored per model; Grimaldus alone has the Character and Epic Hero keywords.

- Plasma Pistol — Standard: 12\", A1, BS2+, S7, AP-2, D1, Close-quarters.
- Plasma Pistol — Supercharge: 12\", A1, BS2+, S8, AP-3, D2, Close-quarters, Hazardous.
- Artificer crozius: A6, WS2+, S6, AP-2, D2.
- Servitor Close combat weapon: A1, WS4+, S3, AP0, D1.

The source lists five Leader targets: Assault Intercessor Squad, Infernus Squad, Intercessor Squad, Crusader Squad and Sword Brethren Squad.

## Integrated local scope

The consolidated current-reference catalog admits the four-model, 120-point choice. The profile is gated by its source-bounded local validation status. The Leader attachment path moves Grimaldus and all three Cenobytes into the selected Bodyguard unit. Cenobytes add zero transport capacity; Grimaldus adds one.

- **Feel No Pain 5+:** applied to the unit while Grimaldus is alive.
- **Litanies of the Devout:** grants the unit full melee Hit re-rolls through AttackPlan.
- **Temple Relics:** the owner may select one available relic in the Command phase after resolving Combat Doctrines: +1 to Advance and Charge, +1 Toughness, or +1 melee AP. It lasts until the start of the owner's next Command phase.
- **Faithful Cenobytes:** when Grimaldus is destroyed, all remaining Cenobytes are destroyed. The cascade is wired into normal damage allocation, hazard/mortal damage, transport destruction and lingering-model cleanup; the focused suite directly checks normal damage allocation and casualty accounting.

The focused suite also checks source identity and hashes, characteristics and weapons, current-catalog admission, all five Leader targets, attachment, transport capacity, unit abilities, relic effects and expiry, and melee AttackPlan re-rolls.

## Verification

Focused offline verification passed **3/3 processes**: Godot import, Python checks and `test_chaplain_grimaldus`.

```text
python tools/verify.py --profile focused --only test_chaplain_grimaldus --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

Report: `.tools/verification/20261028T174823201312Z/results.json` (SHA-256 `63CF74C6ED6A126FA39E6BBF42470415B12EF78A943CBB33343DA0F520AEFEDC`; `network: false`, no legacy starter staged, no cleanup diagnostics). It validates this named local scope, including all weapon profile values.

An expanded regression batch passed **5/5 processes**, including the Leader/Support relation map and Marine transport rules. Report: `.tools/verification/20261028T174844999345Z/results.json` (SHA-256 `22461A04A142ED38FBBF12059A3A73BFDC646F3C2F06E77DB97F857A320A112E`; `network: false`, no legacy starter staged, no cleanup diagnostics).

## Boundaries

This closes Chaplain Grimaldus's source-bounded local datasheet scope. It does not certify full Black Templars or Space Marine army legality, every attached-unit interaction, network behavior or human playtesting. Crusader Squad remains partial; Sword Brethren Squad is admitted for its source-priced sizes, and all Black Templars identities now have runtime profiles. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are outside this inventory.

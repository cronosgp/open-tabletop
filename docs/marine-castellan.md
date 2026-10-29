# Castellan datasheet audit

## Source and snapshot

This audit covers the Castellan in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002793`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Castellan) was checked on 28 October 2026. Fixed facts come from the verified local export `20261021T130623Z`, retrieved 21 October 2026, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice manifest SHA-256 is `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`.

## Source profile and weapons

The Castellan is one model for 75 points on a 40 mm base: M6, T5, Sv3+, W4, Ld6+ and OC1. Its keywords are Infantry, Character, Lieutenant, Explosives, Imperium, Tacticus, Adeptus Astartes and Black Templars.

- Combi-weapon — Purgatus: 24", A2, BS2+, S7, AP-2, D2.
- Combi-weapon — Damnatus: 12", A1, BS2+, S9, AP-3, D3+2; Melta 2.
- Combi-weapon — Infernus: 12", A3, BS2+, S4, AP0, D1; Torrent, Blast 1.
- Master-crafted Power Weapon — A6, WS2+, S6, AP-2, D2; Lethal Hits.
- Optional replacements, at no additional points: Combi-weapon to Heavy Bolt Pistol (18", A1, BS2+, S4, AP-1, D1; Close-quarters) and Master-crafted Power Weapon to Chainsword (A7, WS2+, S5, AP-1, D1; Sustained Hits 1).

## Integrated local scope

The current local catalog admits one Castellan at 75 points. Army preparation exposes both source-listed equipment replacements and can restore the default weapon package. The Support map records eight source targets: Assault Intercessors, Bladeguard Veterans, Company Heroes, Infernus Squad, Intercessors, Sternguard Veterans, Crusader Squad and Sword Brethren Squad. Each target remains subject to its own runtime admission and integration status.

Vehement Aggression is offered when the unit is selected to fight. The owner may make a Leadership roll for that unit. Its melee attacks re-roll Hit rolls of 1; on a successful roll, they also re-roll Wound rolls of 1. The implementation uses the shared current-Leadership calculation, saves the result for the Fight activation, and does not change the unit's Battle-shock state. AttackPlan applies the result to melee attacks only. Combat Doctrines continue through the shared doctrine path.

The dedicated suite checks the exported profile facts, catalog admission, both public equipment replacements and restoration, Support mapping and an Intercessor attachment, failed and successful Leadership rolls, the unchanged Battle-shock state, melee-only rerolls, repeated-use rejection, selected-activation persistence and cleanup after a completed or empty Fight activation.

## Verification

Focused offline verification passed **3/3 processes**: Godot import, Python checks and `test_castellan`.

```text
python tools/verify.py --profile focused --only test_castellan --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

Report: `.tools/verification/20261028T144300855471Z/results.json` (SHA-256 `AE94BD3CCED30AEA78F08D6B9D67F01385C1E31FCEFFF21F34D75C0949DA2D33`, `network: false`, no legacy starter staged, no cleanup diagnostics). The checks validate only the named local scope.

## Boundaries

This closes only the Castellan's source-bounded local datasheet scope. It does not certify the full Black Templars or Space Marine roster, all Support endpoints, detachment force-disposition rules, network behavior or human playtesting. Crusader Squad remains partial; Sword Brethren Squad is now admitted for its source-priced sizes, with 6–8-model choices blocked. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are outside this inventory.

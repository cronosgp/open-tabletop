# Black Templars vehicle datasheet audit

## Source and snapshot

This audit covers the six Black Templars App vehicle sheets in the 11th-edition Chapter book: Gladiator Lancer (`000002787`), Gladiator Reaper (`000002789`), Gladiator Valiant (`000002788`), Impulsor (`000002786`), Repulsor (`000002791`) and Repulsor Executioner (`000002790`). Their live Wahapedia 11e pages were checked on 28 October 2026. Fixed facts come from the verified local export `20261021T130623Z`, retrieved 21 October 2026 under specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice is structurally valid with manifest SHA-256 `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe` and catalog SHA-256 `a3f5ca78fb12c38e6a5ca80e446befca7370b36dd5a017dd97e54ea6c00483c9`. The parent export has 68 unrelated validation errors outside this subject slice; they are not treated as passed. See the [machine-readable audit](marine-black-templars-vehicles-audit.json) for source-file hashes and verification evidence.

## Runtime profiles

The six identities reuse the shared Space Marine vehicle combat profiles after source comparison showed the same fixed characteristics, default weapons and weapon traits. Each keeps the Black Templars book and datasheet IDs, faction keywords, source point tiers and catalog identity:

| Datasheet | First / third-plus points | Chapter-specific handling |
|---|---:|---|
| [Gladiator Lancer](https://wahapedia.ru/wh40k11ed/factions/space-marines/Gladiator-Lancer) | 165 / 185 | Multi-melta option costs 10 points |
| [Gladiator Reaper](https://wahapedia.ru/wh40k11ed/factions/space-marines/Gladiator-Reaper) | 165 / 185 | Multi-melta option costs 10 points |
| [Gladiator Valiant](https://wahapedia.ru/wh40k11ed/factions/space-marines/Gladiator-Valiant) | 145 / 165 | Multi-melta option costs 10 points |
| [Impulsor](https://wahapedia.ru/wh40k11ed/factions/space-marines/Impulsor-1) | 70 / 70; fourth-plus 80 | Multi-melta and Orbital Comms Array cost 10 points; Ironhail Skytalon Array is not offered |
| [Repulsor](https://wahapedia.ru/wh40k11ed/factions/space-marines/Repulsor-1) | 190 / 210 | Multi-melta option costs 10 points; Combat Embarkation is registered |
| [Repulsor Executioner](https://wahapedia.ru/wh40k11ed/factions/space-marines/Repulsor-Executioner) | 265 / 285 | Multi-melta option costs 10 points; Executioner remains registered |

The Impulsor's option list is datasheet-specific: preparation choices and direct configuration both reject the Ironhail Skytalon Array. The Black Templars Repulsor identity follows the shared Combat Embarkation candidate and transport paths. These profiles do not duplicate vehicle rules; they preserve chapter-specific source identity and catalog costs while reusing the reconciled shared combat data.

## Verification

The seven-profile fixed-data comparison (these six vehicles plus the already integrated Emperor’s Champion) reported **zero numeric or identity differences**, **7/7 source-consistent profiles**, and a structurally valid subject slice. The focused offline run passed **4/4 processes**: project import, Python checks, the vehicle suite and the full Repulsor Combat Embarkation regression.

```text
python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_black_templars_vehicles --only test_marine_repulsor_combat_embarkation
```

The vehicle suite checks the six source identities, point tiers, copy caps, catalog admission, shared fixed combat data, every default weapon mode through the attack plan, the Impulsor's excluded array, and Black Templars Repulsor Combat Embarkation eligibility. The companion suite exercises the full public Repulsor reaction flow. Report: `.tools/verification/20261028T141659297789Z/results.json` (SHA-256 `6d547667746d34c4731eedc946511ef911a71281b676a4334caab4a856111c52`, `network: false`, no legacy starter staged, no cleanup diagnostics). Comparator: `.tools/marine-comparison-black-templars-vehicles-20261028-scoped.json` (SHA-256 `3f6267a70569f8bbd11f9eba182352f241aa478f3b0d9d4e871aec7ef9da43a7`). The chapter gap audit reports 24 runtime records across the five books and 52 missing records at `.tools/space-marine-chapter-gap-audit-20261028T1410Z.md`.

## Boundaries and next work

This closes the local source-bounded scope for these six vehicle identities; it does not certify full Black Templars or Space Marine army legality, network behavior, a complete match, or human playtesting. Later increments have raised Black Templars to fifteen runtime profiles, including the source-bounded Sword Brethren Squad, Crusade Ancient, Castellan, Emperor’s Champion, High Marshal Helbrecht, Marshal, Chaplain Grimaldus and Execrator. Crusader Squad remains partial; Sword Brethren is now available as a Leader or Support target at its source-priced 4/5/9/10-model sizes, with 6–8 blocked because the export has no cost rows. Blood Angels (14) is complete; Deathwatch has one profile complete and nine remaining, followed by Space Wolves (21). Forge World, Legends and alternate modes still need separate inventories.

# Execrator datasheet audit

## Source and snapshot

This audit covers the Execrator in the Black Templars 11th-edition App, source book 000000162, datasheet 000004135. The [Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Execrator) was checked on 28 October 2026; the page did not state a separate revision identifier.

Fixed facts come from verified export snapshot 20261021T130623Z, retrieved 2026-10-21T19:46:58Z. Export update timestamp: 2026-10-21T16:06:23+03:00. Specification revision: 20260817b. Parent manifest SHA-256: 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. Black Templars slice manifest SHA-256: 8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe.

Relevant verified export filenames and SHA-256 hashes:

| File | SHA-256 |
|---|---|
| Source.csv | 1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9 |
| Datasheets.csv | 39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c |
| Datasheets_models.csv | 9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03 |
| Datasheets_models_cost.csv | 2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e |
| Datasheets_unit_composition.csv | f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245 |
| Datasheets_abilities.csv | 49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6 |
| Datasheets_keywords.csv | bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341 |
| Datasheets_wargear.csv | 565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d |
| Datasheets_options.csv | 642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853 |
| Datasheets_leader.csv | af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4 |

## Source profile and weapons

One model costs 65 points on a 40 mm base: M6, T5, Sv3+, W4, Ld5+, OC1 and a 4+ invulnerable save. Keywords: Infantry, Character, Chaplain, Imperium, Tacticus, Explosives, Adeptus Astartes and Black Templars.

| Weapon | Profile | Keywords |
|---|---|---|
| Absolvor Bolt Pistol | 18", A1, BS3+, S5, AP-2, D2 | Close-quarters |
| Hand Flamer | 9", A3, Torrent, S4, AP0, D1 | Close-quarters |
| Crozius Arcanum | A5, WS2+, S6, AP-1, D2 | Cleave 1 |
| Master-crafted Power Weapon | A3, WS2+, S6, AP-2, D2 | Extra Attacks, Lethal Hits |

The default is Absolvor Bolt Pistol plus Crozius Arcanum. The pistol may be replaced by a Hand Flamer. While the Absolvor is equipped, the Execrator may add the Extra Attacks Master-crafted Power Weapon; that option prevents replacing the pistol.

## Integrated local scope

The current-reference catalog admits the 65-point profile. Its Leader targets are Crusader Squad and Sword Brethren Squad.

Remorseless Persecution keeps the unit eligible to declare a Charge after it Advances in its Movement phase.

Condemnatory Annihilation resolves after the Execrator's unit fights and destroys an enemy model in the Fight phase. Every living enemy unit still engaged with it takes a Battle-shock test at -1. Failed tests apply Battle-shock; a pass does not clear an existing Battle-shock condition. A target with Tempered in Battle may optionally re-roll both dice for free at -1 under its controller's decision. The saved Fight decision resumes after pending re-roll choices resolve.

## Verification

Focused offline verification passed 5/5 processes: Godot import, Python checks, test_execrator, test_crusade_ancient and test_sword_brethren_squad.

    python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_execrator --only test_crusade_ancient --only test_sword_brethren_squad

Report: .tools/verification/20261028T182325483410Z/results.json (SHA-256 D8242A2984F4658D055814E9F0CC0C9784D1225728A757EC6E4D9E8213AE4BFE; network: false, no legacy starter staged, no cleanup diagnostics). Checks cover source data and manifests, catalog/Leader admission, legal weapon packages, charge-after-Advance scope, multiple engaged enemies, mandatory tests, Battle-shock persistence and Tempered in Battle re-rolls.

## Boundaries

This closes the Execrator's source-bounded local datasheet scope. It does not certify complete army legality, network behavior, final host/client integration or human playtesting. Crusader Squad remains partial because its bounded Surge search does not cover every legal route and coherent placement. Sword Brethren sizes 6–8 remain unavailable because the export has no point rows. Forge World, Legends and alternate game modes are separate inventories.

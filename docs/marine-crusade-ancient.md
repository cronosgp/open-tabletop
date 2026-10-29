# Crusade Ancient datasheet audit

## Source and snapshot

This audit covers the Crusade Ancient in the Black Templars 11th-edition App, source book `000000162`, datasheet `000004136`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Crusade-Ancient) was checked on 28 October 2026. Fixed facts come from the verified local export snapshot `20261021T130623Z`, retrieved 21 October 2026. Its parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice manifest SHA-256 is `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`.

## Source profile and weapons

The Crusade Ancient is one model for 45 points on a 40 mm base: M6, T5, Sv3+, W4, Ld6+ and OC1. It has no invulnerable save. Its keywords are Infantry, Character, Tacticus, Imperium, Explosives, Adeptus Astartes and Black Templars.

- Bolt Pistol — 12", A1, BS3+, S5, AP-1, D1; Close-quarters.
- Master-crafted Power Weapon — A5, WS2+, S5, AP-2, D2; Lethal Hits.

## Integrated local scope

The consolidated current-reference catalog admits the 45-point profile. Its verified Support targets are Crusader Squad and Sword Brethren Squad. Sword Brethren is selectable at the source-priced 4/5/9/10-model sizes; the 6–8-model sizes remain unavailable because no cost rows were exported.

Martial Honour opens after the attached unit's melee attacks destroy an enemy unit in the Fight phase. The owner may pass or use the ability once per battle for that unit. If used, only the Crusade Ancient model gains +5 Objective Control for the rest of the battle.

Vengeful Exhortation can be activated before this unit has fought in the Fight phase when an enemy Fight attack is declared against it. The owner may arm the unit or pass before attack dice are rolled. While armed, each destroyed model in the unit rolls a D6; a 4+ keeps it at one wound until the unit fights or the Fight phase ends. A failed roll removes it. The unit cannot activate the ability again that phase.

The focused suite checks source facts and hashes, current catalog admission, both Support endpoints, the real attack-declaration reaction, owner validation, successful and failed retention rolls, cleanup when the unit fights, the real post-attack Martial Honour window, model-only OC, and the once-per-battle limit.

## Verification

Focused offline verification passed **3/3 processes**: Godot import, Python checks and `test_crusade_ancient`.

```text
python tools/verify.py --profile focused --only test_crusade_ancient --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

Report: `.tools/verification/20261028T171941190553Z/results.json` (SHA-256 `0F098095E0309CA214AFC19E4F5D2B7FD66C581837C761ECBDD55F22DC37509E`; `network: false`, no legacy starter staged, no cleanup diagnostics). These checks validate only the named local scope.

## Boundaries

This closes only the Crusade Ancient's source-bounded local datasheet scope. It does not certify the full Black Templars or Space Marine roster, all Support/Leader combinations, network behavior or human playtesting. Crusader Squad remains partial; all Black Templars identities now have runtime profiles. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are outside this inventory.

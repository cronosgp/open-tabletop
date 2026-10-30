# High Marshal Helbrecht datasheet audit

## Source and snapshot

This audit covers High Marshal Helbrecht in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002794`. The [Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/High-Marshal-Helbrecht) was checked on 28 October 2026. Fixed datasheet facts come from the verified local export snapshot `20261021T130623Z`, retrieved 21 October 2026, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice manifest SHA-256 is `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`.

## Source profile and weapons

Helbrecht is one Epic Hero model for 125 points on a 60 mm base: M6, T5, Sv2+, W6, Ld6+, OC3 and a 4+ invulnerable save. The profile records Infantry, Epic Hero, Chapter Master, Character, Explosives, Imperium, Tacticus, Adeptus Astartes and Black Templars.

- Ferocity: 24", A2, BS2+, S5, AP-1, D2; Anti-infantry 4+, Devastating Wounds.
- Sword of the High Marshals — Strike: A6, WS2+, S9, AP-3, D3.
- Sword of the High Marshals — Sweep: A12, WS2+, S6, AP-3, D1.

The source lists six Leader targets: Assault Intercessor Squad, Bladeguard Veteran Squad, Company Heroes, Intercessor Squad, Crusader Squad and Sword Brethren Squad. Sword Brethren is now an admitted target for its source-priced 4/5/9/10-model sizes; the unpriced 6–8-model sizes remain unavailable.

## Integrated local scope

The consolidated local catalog admits Helbrecht as a one-copy, 125-point profile. Transhuman Strategist grants 1 CP at the start of a battle round when Helbrecht is the selected Warlord; he is selectable as Warlord.

Crusade of Wrath adds +1 Attack and +1 Strength to the melee attacks of Helbrecht’s current unit, including attached bodyguards, through the shared melee profile and attack-count paths. High Marshal is offered in the start-of-Fight window only when a living Helbrecht unit is engaged with an enemy. The owner selects one such enemy; a persisted D6 result resolves 0, D3, 3 or D3+3 mortal wounds on rolls of 1, 2–3, 4–5 or 6. Mortal wounds use the shared prevention, allocation and mortal-reaction paths, then restore the original phase-start window. The use is limited to once per Fight phase for the bearer.

Combat Doctrines and the Leader rule use their shared implementations. Other source-listed army rules continue through the shared current-reference Space Marine paths.

## Verification

Focused offline verification passed **3/3 processes**: Godot import, Python checks and `test_high_marshal_helbrecht`.

```text
python tools/verify.py --profile targeted --only test_high_marshal_helbrecht --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

Report: `.tools/verification/20261028T162645916738Z/results.json` (SHA-256 `AB0087D8890C8C76F745CA6619F910C6F37E678916CF1E4FF987EF9E837DB274`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks local export facts and provenance, current-catalog admission, Leader links, Warlord CP, the melee modifiers, all High Marshal roll bands, public mortal-wound allocation and phase-window resumption. These checks validate only the named local scope.

The expanded regression batch passed **8/8 processes** with the same dedicated suite plus Marshal, core reactions, shared Space Marine Leader links, capabilities and implemented-catalog checks. The latest report is `.tools/verification/20261028T164358830697Z/results.json` (SHA-256 `F3102CC8EB65D2BB61A55042F5411570F7DDD5CB2C83C8AB01A308CEBF86E913`; `network: false`, `legacy_starter_staged: true` for supplemental historical fixtures, no cleanup diagnostics). The catalog assertion confirms 112 selectable records and four excluded profiles. After memoizing the canonical profile data behind deep-copy getters, the catalog test passed under the verifier’s default 45-second process limit.

## Boundaries

This closes Helbrecht’s source-bounded local datasheet scope only. It does not certify full Black Templars or Space Marine army legality, every Leader endpoint, network behavior, complete-match play or human playtesting. Crusader Squad remains partial because its bounded Surge waypoint search does not cover every legal route or coherent placement around blockers. Sword Brethren Squad is admitted for its priced sizes; Crusader Squad remains partial. Network validation remains deferred to final integration; Forge World, Legends and alternate modes are outside this inventory.

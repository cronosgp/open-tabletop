# Belial (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes Belial's fixed datasheet, available Leader links and declared local ability scope. It does not certify full Dark Angels roster legality, Space Marines army legality or network behavior.

## Source identity

- [Wahapedia 11th-edition Belial](https://wahapedia.ru/wh40k11ed/factions/space-marines/Belial), Dark Angels App datasheet `000000219`, book `000000023`.
- The live Space Marines page was checked on 28 October 2026 and lists Dark Angels App revision 2.8.1 (October 2026). Fixed data comes from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records snapshot identity and the SHA-256 hashes of the source files used. Raw export data remains outside Git.

## Profile and loadout

- One model, 100 points, one copy. M5, T6, Sv2+, W6, Ld6+, OC1, 4+ invulnerable save, 50 mm base.
- Master-crafted Storm Bolter: 24", A2, BS2+, S5, AP-1, D2, Precision.
- The Sword of Silence: A6, WS2+, S6, AP-3, D2.
- All source keywords are represented, including TERMINATOR, DEATHWING and the Dark Angels faction keyword.
- Leader targets are Terminator Assault Squad, Terminator Squad, Deathwing Knights and Deathwing Terminator Squad; all four are available in the current local catalog.

## Rules in the checked scope

- Leader, Deep Strike, Combat Doctrines and Transhuman Strategist use the shared local paths. Belial can be selected as Warlord; Transhuman Strategist grants the existing once-per-round Command point.
- **Grand Master of the Deathwing:** Belial's unit adds +1 to Wound rolls against enemy CHARACTER units. The shared AttackPlan path applies this to ranged and melee attacks, including attached bodyguards, and does not apply it against other targets.
- **Strikes of Retribution:** in the Fight phase, when Belial is destroyed before his unit has fought, a D6 roll of 2+ leaves him on the battlefield until his unit fights or the phase ends, whichever comes first. A failed roll of 1 records the destruction; bodyguard casualties do not trigger the ability.
- The source DEATHWING keyword is retained in Dark Angels Chapter context.

## Local verification and limits

The combined focused check passed 7/7 processes at `.tools/verification/20261028T113916146828Z/results.json`, including Belial's attachment targets, the Deathwing Terminator Squad profile and the merged Leader/Support links. Capability and Azrael regressions passed 4/4 processes at `.tools/verification/20261028T113948965947Z/results.json`.

The Belial extraction is a structurally valid, closed audit slice with no slice validation errors. The whole parent export reports 68 validation errors outside the Belial slice; this was not treated as a global export pass. The local checks do not certify complete Dark Angels/Space Marines army legality, other Chapter interactions, network paths or human playtesting.

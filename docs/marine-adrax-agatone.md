# Adrax Agatone

Current Space Marines 11th-edition datasheet from the pinned local Wahapedia extraction. Source book `000000139`, datasheet `000002100`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Adrax-Agatone).

## Profile

- One model, 90 points; M6, T5, Sv2+, 4++, W5, Ld6+, OC1; 40 mm base.
- Exported keywords include the Salamanders and Adeptus Astartes faction keywords, plus Captain, Character, Epic Hero, Explosives, Infantry, Imperium and Tacticus.
- Drakkis: 12", D6+3, Torrent, Close-quarters, S5, AP-1, D1.
- Malleus Noctum: 5A, WS2+, S10, AP-2, D3, Devastating Wounds.

## Rules implemented

- Leader attachment to the source-listed bodyguard identities admitted in the consolidated local catalog.
- Transhuman Strategist, using the existing Warlord CP effect.
- Lord of the Pyroclasts: enemy units engaged with Adrax's attached unit have -1 OC, minimum 0.
- Unto the Anvil: the attached unit's melee attacks re-roll wound rolls of 1; while Assault Doctrine is active for that unit, it re-rolls wound rolls instead.

The implementation is scoped to this local extraction and the listed bodyguard choices. It does not certify full Salamanders restrictions, faction legality or network integration.

Validation: `.tools/verification/20261019T114211481946Z/results.json` (10/10 local processes). Fixed-data comparison: `.tools/wahapedia-fixed-data-review-v87.json` (42/43 bounded profiles pass; the remaining keyword-context issue is Ancient in Terminator Armour). Network checks remain deferred.

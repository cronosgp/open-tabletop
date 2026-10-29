# Space Marine roster copy limits

This document records the current source-bounded copy-limit rules used by mixed roster admission for the 85 shared Space Marines datasheets.

## Source and scope

- Edition: Warhammer 40,000 11th edition.
- Source: Wahapedia 11e Core Rules, §§01.02.07 and 25.03; live page checked 28 October 2026 (version 11, June 2026).
- Game sizes implemented from §25.03: Incursion (1,000 points; Unit Limit 2) and Strike Force (2,000 points; Unit Limit 3).
- Datasheet keywords come from the verified local 11e export. This is a roster-admission rule scope, not certification of every army rule.

## Per-datasheet limits

| Category | Ordinary datasheet | BATTLELINE or DEDICATED TRANSPORT | EPIC HERO |
| --- | ---: | ---: | ---: |
| Incursion | 2 | 4 | 1 |
| Strike Force | 3 | 6 | 1 |

The doubled limit applies when a unit has BATTLELINE or DEDICATED TRANSPORT. Core Rules §01.02.07 defines a unit as having a keyword when one or more models in that unit have it. The admission code therefore counts copies by datasheet across different loadout configurations and derives special keywords from the selected composition where model roles matter.

Detachment-granted keywords also affect the limit when the roster context is known. Darkflight Pursuit grants BATTLELINE to Outrider Squads, so their Incursion cap becomes four and their Strike Force cap becomes six. Prepared-match admission rechecks each player's list using that player's selected detachment. The same source-keyed grant function is used when materializing the unit for play.

Victrix Honour Guard is a composition-sensitive case: a guards-only unit does not inherit EPIC HERO from the optional Chapter Ancient or Chapter Champion. Selecting either named role does give that unit EPIC HERO, so that configuration counts against the one-copy limit. The guards-only and Epic Hero configurations still share the same datasheet copy count.

`training`, `onslaught`, and `custom` categories do not use the two standard limits above. They retain the project's local supported-copy ceiling and are labeled as such in the admission result; they are not represented as source-checked Core Rules categories here.

## Verification and remaining boundary

The focused local check iterates all 85 shared-book Space Marines profiles, checks both standard category mappings, and exercises ordinary, BATTLELINE, Dedicated Transport, EPIC HERO and composition-sensitive Victrix cases. A second focused check covers Darkflight Pursuit's Outrider BATTLELINE grant at admission and in the prepared match, including different detachments for each player. The combined run passed 7/7 processes at `.tools/verification/20261028T075538220026Z/results.json` (`network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). Leader attachment combinations, other detachment interactions, every Chapter restriction, complete army legality and host/client networking remain separate cross-sheet and integration work.

Source: [Wahapedia 11e Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/).

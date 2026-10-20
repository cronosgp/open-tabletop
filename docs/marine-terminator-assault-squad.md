# Terminator Assault Squad

Current Space Marines 11th-edition profile from the project’s Wahapedia-only local extraction. Source book `000000139`, datasheet `000000118`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Assault-Squad).

## Admitted profile

- Five or ten Terminators; one Sergeant and four to nine Terminators.
- M5, T6, Sv2+, 4++, W3, Ld6+, OC1; 40 mm bases.
- Default weapon: Twin Lightning Claws (A6, WS3+, S5, AP-2, D1, Twin-linked).
- Five models cost 170 points and ten cost 340. Third and later units use 210/380; each Storm Shield adds 5 points.
- Each model may replace its Twin Lightning Claws with a Storm Shield and Thunder Hammer. The shield adds 1 Wound; the hammer is A3, WS3+, S8, AP-2, D3, Devastating Wounds.

## Implemented abilities

- Deep Strike and the existing Teleport Homer declaration/Rapid Ingress flow.
- Terminatus Assault: after a charge this turn, Lightning Claws gain Sustained Hits 1 against targets without MONSTER or VEHICLE; Thunder Hammers gain Sustained Hits 1 against targets with either keyword.
- Storm Shield equipment is selectable model by model during preparation, updates the model’s Wounds characteristic and adds the sourced equipment cost.

DEATHWING remains chapter-conditional and is not applied to this shared-book profile. No leader options are admitted for this squad in this increment. This is focused local profile and combat validation only; network validation is deferred to final integration, and full faction/army legality is not certified.

Validation: `.tools/verification/20261019T111723260184Z/results.json`; fixed-data comparison: `.tools/wahapedia-fixed-data-review-v83.json`.

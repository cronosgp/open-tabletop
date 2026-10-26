# Crushing Impact / Tank Shock

## Current 11e rule

The Core Stratagem is used immediately after a friendly MONSTER or VEHICLE unit ends a Charge move. Choose one enemy unit engaged with your unit, then select one of your models engaged with that enemy. Roll a number of D6 equal to the selected model's Toughness. Each result of 1 inflicts one mortal wound on the charging unit. Each result of 5+ inflicts one mortal wound on the selected enemy unit, to a maximum of six against that enemy.

The source checked for this scope is [Wahapedia 11e Core Rules, §15.06](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/). The Core Rules refer to the same stratagem as Crushing Impact and Tank Shock.

## Local implementation

The post-charge choice accepts eligible MONSTER and VEHICLE units and preserves the per-phase use rules, including Brutalis Charge's additional per-unit use and cost reduction. After the roll, the charging unit's mortal-wound packet resolves first under its owner's allocation and prevention choices. The selected enemy's packet follows under its owner's choices. Both packets use the shared mortal-wound flow, including Deadly Demise continuations. Allocation choices identify whether they apply to the charging unit or the target unit.

## Support status

This behavior is implemented and source-checked against current Wahapedia 11e. Focused local checks and human playtesting for MONSTER eligibility and the charging-unit packet remain pending. Network validation is deferred to final integration; full army legality is not certified. The previously recorded Vehicle-only checks cover the older target-only behavior and do not verify this expansion.

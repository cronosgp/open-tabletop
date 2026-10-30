# Shooting at engaged Monsters and Vehicles

The current Wahapedia 11th-edition Core Rules state in §10.06 that close-quarters shooting is available to an engaged MONSTER/VEHICLE unit that did not Advance; §17.03 allows ranged attacks against engaged enemy MONSTER/VEHICLE units during the attacking player's own Shooting phase. BLAST attacks cannot target an engaged unit. Attacks against an engaged MONSTER/VEHICLE subtract 1 from the Hit roll, except CLOSE-QUARTERS attacks made by a unit engaged with that target. [Current Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) were checked on 30 October 2026.

## Target and shooter boundaries

- An unengaged shooter may target an engaged enemy MONSTER/VEHICLE only during its controlling player's own Shooting phase.
- A shooter that is already engaged still needs an eligible close-quarters shooting type. During that shooting, MONSTER/VEHICLE models may target enemy units their own unit is engaged with and retain their normal ability to target unengaged enemies. During their own Shooting phase, they may also target another engaged enemy MONSTER/VEHICLE under §17.03; other engaged enemy units remain unavailable. Non-MONSTER/non-VEHICLE models remain limited to CLOSE-QUARTERS weapons and enemies engaged with their unit.
- BLAST cannot target an engaged unit, including when the target has MONSTER or VEHICLE.
- For an engaged MONSTER/VEHICLE shooter, each attack against an enemy engaged with its unit subtracts 1 from Hit unless it uses a CLOSE-QUARTERS weapon. A unit can separately ignore any or all BS/Hit modifiers when a datasheet ability permits it, such as the Vindicator's Siege Shield. Target-side §17.03's -1 Hit modifier is waived only for a CLOSE-QUARTERS attack made by a unit engaged with that target.
- This target exception does not apply to out-of-phase shooting. A separate rule may allow that shooting, but §17.03 does not grant access to an engaged MONSTER/VEHICLE target outside the attacking player's own Shooting phase.

The shared attack planner enforces these boundaries in target selection and attack preparation. Focused `test_vehicle_shooting` checks the engaged-shooter target limits, §17.03 target exception, BLAST exclusion and hit modifiers; Vindicator regressions cover close-quarters shooting against engaged and unengaged targets, Siege Shield's other-friendly engagement restriction and its modifier override. This remains a bounded core-rule slice: the full set of out-of-phase shooting effects and every MONSTER/VEHICLE datasheet interaction are not certified.

## Validation status

Implementation and source checks are recorded; focused local checks for the Vindicator and selected Marine vehicles passed on 30 October 2026. Human playtesting remains pending. Network validation and full army legality are not established by this entry.

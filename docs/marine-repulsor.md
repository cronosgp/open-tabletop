# Repulsor — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Repulsor](https://wahapedia.ru/wh40k11ed/factions/space-marines/Repulsor), source book 000000139, datasheet 000002721. The page is under the Space Marines App 2.8.1, updated October 2026; it was checked alongside the verified local Data Export snapshot on 28 October 2026. The checked context is the common 40K datasheet and points view, with no Chapter selected; this scope does not certify Boarding Actions or other mode-specific lists.

## Implemented and checked

- The source composition is one model. Roster prices are 190 points for each of the first two copies and 210 for the third and later copies; local admission caps this datasheet at three copies. Saved rosters, admission totals and builder previews preserve those categories.
- The source lists a 100 mm diameter circle; the runtime uses the matching circular footprint. The imported characteristics, keywords, default weapons and source weapon profiles are retained, including Heavy Onslaught Gatling Cannon's target-restricted Devastating Wounds and Sustained Hits 2.
- Army Preparation exposes both no-cost reversible replacements: Heavy Onslaught Gatling Cannon for Las-talon, and Twin Heavy Bolter for Twin Lascannon.
- The transport carries 14 ADEPTUS ASTARTES INFANTRY spaces, excludes JUMP PACK models and counts GRAVIS and TERMINATOR models twice. Combat Embarkation runs during the opponent's Charge phase after target selection and before movement; the defender can embark one eligible target and the charging player can then revise targets. Public-command checks cover pass, embark, owner/stale-option rejection, save/restore and continuation of the same Charge frame.
- Damaged 6 and Deadly Demise D6 parameters, current-catalog admission for both players, shared transport rules and point calculations passed in the focused offline verification recorded in the [machine-readable source and hash audit](marine-repulsor-audit.json).

## Limits

The source and runtime both specify a 100 mm circular base, so this profile uses the matching circle. The three-copy catalog ceiling is a local construction limit, not a full army-legality claim. Chapter-book content, full army legality, network behavior, complete-match certification and human playtesting remain outside this scope; network validation is deferred to final integration.

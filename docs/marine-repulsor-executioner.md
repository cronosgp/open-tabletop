# Repulsor Executioner — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Repulsor Executioner](https://wahapedia.ru/wh40k11ed/factions/space-marines/Repulsor-Executioner), source book 000000139, datasheet 000002722. The page is under the Space Marines App 2.8.1, updated October 2026; it was checked alongside the verified local Data Export snapshot on 28 October 2026. The checked context is the common 40K datasheet and points view, with no Chapter selected; this scope does not certify Boarding Actions or other mode-specific lists.

## Implemented and checked

- The source composition is one model. Roster prices are 260 points for each of the first two copies and 280 for the third and later copies; local admission caps this datasheet at three copies. Saved rosters, admission totals and builder previews preserve those categories.
- The source lists a 100 mm diameter circle; the runtime uses the matching circular footprint. The imported characteristics, keywords, default weapons and source weapon profiles are retained. Executioner gives +1 to ranged Hit rolls against targets not below half-strength; checks cover above, exactly at and below half-strength, including a single model measured by remaining wounds.
- Army Preparation allows the Heavy Laser Destroyer to be replaced with a Macro Plasma Incinerator. The +10-point Heavy Laser Destroyer surcharge is removed on replacement and restored when switching back; both Standard and Supercharge profiles enter attack selection.
- The transport carries seven ADEPTUS ASTARTES INFANTRY spaces, excludes JUMP PACK models and counts GRAVIS and TERMINATOR models twice. Damaged 6, Deadly Demise D6 and both-player current-catalog admission are checked.
- Profile, replacement and surcharge, Executioner effect, transport, and roster pricing passed in the focused offline verification recorded in the [machine-readable source and hash audit](marine-repulsor-executioner-audit.json).

## Limits

The source and runtime both specify a 100 mm circular base, so this profile uses the matching circle. The three-copy catalog ceiling is a local construction limit, not a full army-legality claim. Chapter-book content, full army legality, network behavior, complete-match certification and human playtesting remain outside this scope; network validation is deferred to final integration.

# Assault Intercessors With Jump Packs — targeted local validation passed

18 October 2026. This batch admits Assault Intercessors With Jump Packs to the local runtime and construction catalog using the Wahapedia 11th-edition export as its rules authority. It does not certify the complete Space Marines faction or full army legality.

## Source and fixed profile

Reviewed against the local source record for [Assault Intercessors With Jump Packs](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessors-With-Jump-Packs), datasheet `000002776`, shared Space Marines App book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The source has five or ten models, with 95/190 points for the first two units and 105/200 for the third-plus tier. The current roster catalog cannot assign a cost according to copy index, so construction permits at most two copies. It does not silently price a third at the first/second tier.

The fixed profile matches the source characteristics, base size, composition, default Heavy Bolt Pistol and Chainsword, and two source weapon profiles in the local fixed-data comparison. Hammer of Wrath and Deep Strike are represented for this identity. Only the listed setup choices are exposed: Sergeant pistol and melee replacements, and up to one ordinary model's Plasma Pistol per five-model group. Optional choices are not separately priced because the source lists no additional cost for them.

## Implemented behavior

After this unit completes a charge, Hammer of Wrath offers eligible enemy units it is engaged with as targets, with a skip option. For each living model in the charging unit engaged with that target, the attacker rolls one D6; each 4+ causes one mortal wound. The defender must allocate each mortal wound, with the existing prevention and allocation flow. Charge failure or an invalid target/dice count does not trigger or partially apply the effect.

Deep Strike is recorded as an ability on the profile and continues to use the existing reserve mechanism. This batch adds no leader attachment or chapter-specific rules.

## Preparation UI

The Sergeant and ordinary-model equipment choices use the existing unit-action selector and help area; no panel or layout was changed. I could not make a new Godot capture in this environment because the runtime could not create its `user://` log/cache directory under the workspace sandbox. The suite verifies the generated options and replacement limits, but no new screenshot is claimed.

## Validation

The 16-process local run `.tools/verification/20261019T024716658895Z/results.json` passed, including `test_hammer_of_wrath`, `test_implemented_catalog`, `test_roster_validation`, `test_unit_reserves`, `test_capabilities`, `test_explosives`, and the recent Gravis, Ancient, Phobos and Infiltrator suites. Import, startup and all 30 Python checks also passed in that run. The full local regression remains pending. Network validation was deferred and not run. These checks do not establish full faction rules coverage or full army legality.

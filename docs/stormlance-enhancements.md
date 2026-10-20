# Stormlance enhancements in local training

## Army Workshop screen brief

- **Goal:** assign one supported Stormlance enhancement to one unit entry and make its extra points visible.
- **Context:** the player selects an existing entry in the local army list.
- **Information order:** unit name and composition, current points, then the enhancement picker. The picker shows the enhancement name, 10-point cost, and Stormlance requirement.
- **Primary action:** select an eligible enhancement. A multi-copy row splits into an unenhanced row and one enhanced unit before assignment.
- **Feedback:** the selected list row names its enhancement and shows the additional 10 points. The list total includes the added cost. The helper text asks the player to select Stormlance for match setup.
- **Unavailable state:** the picker is disabled when the selected local datasheet has no supported enhancement. An enhancement already assigned elsewhere in the army is disabled.
- **Rules boundary:** the source is the local Wahapedia 11e export. Pending and historical profiles remain outside construction choices. This Army Workshop entry is a training roster choice, not a complete legality certification.
- **Capture status:** graphical before/after captures were unavailable in this environment because no Godot executable was found on PATH or in the workspace. The UI has not received graphical QA at supported viewport sizes.

## Implemented source rows

| Export ID | Enhancement | Eligible supported local profiles | Runtime effect |
|---|---|---|---|
| `000008486002` | Supercharged Engines | Chaplain on Bike, Captain on Bike, Outrider Squad, Invader ATVs | Free Advance reroll in the pending movement decision. |
| `000008486003` | Auspex Triangulation Shrines | Storm Speeder Hammerstrike, Hailstrike, Thunderstrike, Land Speeder | At Shooting start, mark one visible enemy within 12 inches spotted; +3 inches detection range while marked. |

The local export also maps Supercharged Engines to Scout Bike Squad, Ravenwing Black Knights, Thunderwolf Cavalry and Ravenwing Command Squad, and Auspex Triangulation Shrines to Ravenwing Darkshroud and Land Speeder Vengeance. Those datasheets do not yet have selectable runtime profiles, so they remain unavailable in construction until reconciled and admitted. Exported spotted text contains no expiry clause, so the selected mark lasts for the battle. `tests/test_stormlance_enhancements.gd` passed its local checks; networking and full army legality remain deferred.

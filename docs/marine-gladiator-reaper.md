# Gladiator Reaper — current e11 implementation

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000001667`, revision `2026-10-16T21:03:46+03:00`. The Gladiator Reaper is one 100 mm-base model with M10, T10, Sv3+, W12, Ld6+ and OC3. It costs 165 points for each of the first two copies and 185 for the third-plus price tier.

The model's fixed loadout is Armoured Hull, Defensive Array and Twin Heavy Onslaught Gatling Cannon. The weapon profiles preserve Rapid Fire 12 on the Defensive Array, and Twin-linked plus Sustained Hits 2 and Devastating Wounds against targets without MONSTER/VEHICLE on the cannon. The cannon loses those two conditional traits against a Monster or Vehicle; Twin-linked remains. No replacement options appear on this source sheet.

**Reaping Tally** improves the AP of the unit's ranged attacks by 1 when targeting a unit without the MONSTER or VEHICLE keyword. It does not modify melee attacks. The shared **Damaged 4** effect applies -1 to Hit while the model has 1–4 wounds remaining. **Deadly Demise D3** uses the shared destruction sequence: after destruction roll a D6; on 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet.

The base is a 100 mm circle, represented by its 50 mm radius. `tests/test_gladiator_reaper_current.gd` checks the source identity, stats, weapons, prices, catalog publication, materialization, Reaping Tally versus ordinary/Monster/Vehicle targets, conditional cannon traits and the Damaged 4 threshold. The fixed-data audit also checks source loadout, composition, prices and all three weapon profiles/traits. This increment does not certify full faction or army legality; network checks remain deferred to final integration.

# Chaplain on Bike

The Chaplain on Bike is admitted as a fixed-loadout Space Marines profile from the pinned local Wahapedia 11th-edition export. This increment adds its one-model, 75-point profile, Leader attachment to Outrider Squad, Litany of Hate and Catechism of Fire.

## Profile and loadout

The local row is M12, T6, Sv3+, 4+ invulnerable save, W5, Ld5+ and OC2. Its base is a 90 x 52 mm oval; the runtime represents it with the project’s documented 90 mm bounding-circle proxy. The fixed weapons are Absolvor Bolt Pistol, Twin Bolt Rifle and Crozius Arcanum. Weapon characteristics and traits match the pinned extraction.

## Implemented rules

- **Leader:** this admitted build allows attachment to Outrider Squad. The source export also links Ravenwing Black Knights, which is outside the consolidated shared-book construction choices.
- **Litany of Hate:** while the Chaplain source lives, attached unit melee attacks gain Lance.
- **Catechism of Fire:** when the unit is selected to shoot, the player may choose one visible enemy unit. The unit’s ranged attacks against that target gain Devastating Wounds for that Shooting phase. Other targets and melee attacks do not receive the effect.

## Validation boundary

The focused Godot run passed (7/7 selected processes) in [results.json](../.tools/verification/20261019T110640219017Z/results.json). The local fixed-data comparison [v80](../.tools/wahapedia-fixed-data-review-v80.json) covers 40 profiles and 179 weapon-trait profiles; 39/40 bounded checks pass with zero numeric or identity differences. The remaining bounded mismatch is Ancient in Terminator Armour’s `DEATHWING` chapter context. Network validation is deferred to final integration. This does not certify full faction support or full army legality.

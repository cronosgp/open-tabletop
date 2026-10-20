# Vanguard Veteran Squad With Jump Packs

Implemented from the project's local Wahapedia 11th-edition extraction. Source book `000000139`, datasheet `000000147`, export revision `2026-10-16T21:03:46+03:00`. Wahapedia is the rules authority under [project policy](rules-source-policy.md); no other rules source was used to resolve this datasheet.

## Admitted scope

- One Sergeant and four to nine Vanguard Veterans; supported sizes are five or ten models. Characteristics: Move 12", Toughness 5, Save 3+, Wounds 2, Leadership 6+, Objective Control 1; 32 mm base.
- Points: 110/220 for five/ten models among the first two copies; 130/240 for the third-plus tier. Construction allows up to two copies because its local catalog has one unit price per identity and cannot correctly price a different third-plus tier per copy.
- Default equipment is role-specific: the Sergeant has a Heavy Bolt Pistol and Relic Blade; other models have a Heavy Bolt Pistol and Master-crafted Power Weapon.
- Models may replace their Heavy Bolt Pistol with a Plasma Pistol or Combat Shield. Ordinary Veterans can take at most two Plasma Pistols for every five models. The Sergeant has an independent pistol choice. A Combat Shield replaces the pistol and gives only its bearer a 5+ invulnerable save.
- The Sergeant may replace the Relic Blade with a Power Fist or Thunder Hammer. Alternate profiles preserve their extracted traits, including Hazardous on Plasma Pistol Supercharge and Devastating Wounds on the Thunder Hammer.
- Deep Strike uses the shared reserves implementation. Vanguard Assault adds one Attack to melee weapons while the unit has made a Charge move this turn. The Fight-phase attack planner is covered by the targeted test.
- Captain With Jump Pack is an allowed Leader from the extracted attachment link. Conditional `DEATHWING` is retained as chapter-context metadata and is not injected into the shared unit keyword set.

## Validation

The fixed-data comparison checks characteristics, default equipment by role, weapon profiles and traits, shared keyword scope, composition, and both points tiers. Targeted local tests check five/ten-model admission, the two-copy boundary, Leader attachment, Deep Strike, Vanguard Assault in a prepared attack plan, individual Combat Shields, Plasma Pistol limits and modes, Sergeant weapon choices, Thunder Hammer Devastating Wounds, and Relic Blade's conditional Lethal Hits.

These checks cover the admitted local slice. The full local regression and final network integration remain pending; this sheet does not certify complete Space Marine faction rules or full army legality.

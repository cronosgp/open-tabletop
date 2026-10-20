# Captain With Jump Pack — targeted local validation passed

19 October 2026. This increment admits Captain With Jump Pack from the local Wahapedia 11th-edition extraction as the sole rules authority for this project. It does not certify the full Space Marines faction or full army legality.

## Source and fixed profile

Reviewed against the local source record for [Captain With Jump Pack](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-With-Jump-Pack), datasheet `000000083`, Space Marines App book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The fixed 90-point, one-model profile uses the extracted characteristics and default Heavy Bolt Pistol and Chainsword. The local fixed-data comparison matched characteristics, default equipment, weapon traits, size and price.

The setup selector exposes seven supported source combinations: default pistol and Chainsword, Hand Flamer, Plasma Pistol, Power Fist, Relic Weapon, Thunder Hammer with Relic Shield, and Chainsword with Relic Shield. Replacements are represented as complete mutually exclusive sets. Relic Shield grants +1 Wound only to its bearer; changing back removes that wound and shield effect.

## Implemented rules

- **Leader:** may attach to the admitted Assault Intercessors With Jump Packs bodyguard. Other Jump Pack bodyguards remain unavailable until their own profiles and compatibility are reconciled.
- **Deep Strike:** uses the existing reserve implementation.
- **Strategic Acumen:** uses the existing Captain/doctrine use and limit mechanism.
- **Angel’s Wrath:** when its attached unit Advances, add 1 to the Advance result; when it Charges, add 1 to the Charge result. The Advance bonus is applied after any Command Re-roll resolves.
- **Relic Shield:** active only for a Captain equipped with that option, with bearer-only +1 Wound.

## Validation and limits

`tests/test_jump_pack_captain.gd` checks local profile admission, all seven equipment sets, the allowed attachment link, Leader behavior, Advance/Charge modifiers, re-roll ordering and Relic Shield source lifetime. The 13-process batch run `.tools/verification/20261019T025729062171Z/results.json` passed; after adding the explicit pre-attachment assertion, the five-process focused follow-up `.tools/verification/20261019T030130556533Z/results.json` also passed. The local source comparison is in `.tools/wahapedia-fixed-data-review-v7.json`: 11 of 12 exported profiles have consistent fixed-data scope; the remaining Ancient in Terminator Armour is still unresolved for `DEATHWING` chapter context. The Captain’s fixed profile is consistent.

The complete local regression remains pending. Network validation was deferred and not run. Optional enhancements, all possible leader bodyguards, general chapter interactions, and full faction/army legality are outside this increment.

# Ragnar Blackmane

## Source and scope

Ragnar Blackmane is a 100-point Space Wolves App Epic Hero from Wahapedia 11th edition datasheet `000000285` (book `000000036`). The local construction catalog supports one copy. His source profile is M7, T5, Sv3+, 4+ invulnerable save, W5, Ld6+, OC1 on a 40 mm base. He has a Bolt Pistol and Frostfang; Frostfang has eight WS2+, S6, AP-3, D2 attacks with Sustained Hits 1. The Bolt Pistol uses its source 12-inch close-quarters profile.

The runtime records Leader links to Wolf Guard Headtakers and Blood Claws. Blood Claws is admitted; Headtakers is a partial profile selectable at its compatible mixed 6/12-model sizes, with its incompatible Headtakers-only MFM rows blocked.

## Implemented local abilities

- **Battle-lust:** after Ragnar's unit makes a Charge move, add two attacks to Ragnar's melee weapon profiles. The bonus is model-specific.
- **War Howl:** while Ragnar leads Blood Claws, the attached unit's melee attacks gain +1 Strength and Sustained Hits 1. While he leads Headtakers, the unit remains eligible to declare a Charge after Advancing. These target conditions are resolved from the attached unit identity.
- **Core and faction abilities:** Leader, Combat Doctrines and Transhuman Strategist are registered. Ragnar is eligible to be the Warlord, allowing the existing once-per-round CP rule to evaluate his datasheet ability.

## Local evidence and limits

The focused offline run passed 3/3 processes. The connected offline regression passed 11/11 processes and included catalog, capability, Leader, Blood Claws, doctrine, roster and current combat checks. Network validation was disabled. The verified subject slice has zero structural errors; its parent export has 68 unrelated findings, which are not reported as passed.

This closes Ragnar's source-bounded local datasheet scope only. Headtakers remains partial with its incompatible standalone rows blocked; network/page comparison, human playtesting, full Space Wolves roster restrictions and full army legality are not certified. See the [machine-readable source/hash audit](marine-ragnar-blackmane-audit.json).

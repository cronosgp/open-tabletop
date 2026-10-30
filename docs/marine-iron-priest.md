# Iron Priest

## Source and scope

Iron Priest is a 60-point Space Wolves App character from Wahapedia 11th-edition datasheet `000000306` (book `000000036`). The local catalog admits one model per unit, with a three-copy roster ceiling. Its source profile is M7, T5, Sv2+, W4, Ld6+, OC1 on a 32 mm base, with no invulnerable save or equipment options. The weapons are a Helfrost Pistol with Dispersed and Focused profiles, plus the Tempest Hammer and Servo-arm. Snapshot identity, revision, batch scope and hashes are recorded in the [machine-readable source/hash audit](marine-iron-priest-audit.json).

The source lists five Leader targets: Intercessor Squad, Wolf Guard Headtakers, Blood Claws, Assault Intercessor Squad and Grey Hunters. Headtakers is selectable for its admitted mixed 6/12-model profiles; its Headtakers-only rows remain blocked by Wahapedia's selected minimum composition.

## Implemented local abilities

- **Gift of the Iron Wolf:** at the start or end of the Iron Priest unit’s move in its Movement phase, select up to one friendly Space Wolves Vehicle model within 3 inches. The model heals D3 wounds and its attacks can ignore Hit and Wound modifiers until the start of the owner’s next Movement phase. A Vehicle model cannot be selected again for this ability in the same phase.
- **Iron Priest:** this model has Lone Operative while within 3 inches of a friendly Space Wolves Vehicle unit. Range uses base-edge geometry. The model-only protection does not apply to a Leader-attached unit.
- **Judgement of the Omnissiah:** the Iron Priest’s own attacks can re-roll all Wound rolls against an enemy unit engaged with a friendly Space Wolves Vehicle. The general attack sequence now supports this all-roll Wound reroll without granting it to other models in the squad.
- **Core and faction abilities:** Leader, Combat Doctrines and Transhuman Strategist are registered; the Iron Priest can be selected as Warlord.

## Local evidence and limits

The isolated offline run passed 3/3 verifier processes for `test_iron_priest`. The connected targeted regression passed 8/8 processes: import, Python checks, Iron Priest, consolidated catalog, capability metadata, Leader links, Techmarine and attack sequence. The network was disabled. The source batch has zero structural findings; the parent export has 68 unrelated findings that remain open.

The rules tests add `SPACE WOLVES` to a common Ballistus Dreadnought only inside the fixture because the current catalog does not yet offer a Space Wolves Vehicle. This checks the keyword gates but does not certify a playable Space Wolves Vehicle roster. The profile’s existing source-linked enhancement relations were not retested in this increment. Wolf Guard Headtakers is now a selectable partial target at its admitted mixed sizes, and network/page comparison, human playtesting, full Space Wolves restrictions and full army legality remain uncertified.

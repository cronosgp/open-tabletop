# Ulrik the Slayer

## Source and scope

Ulrik the Slayer is a 90-point Space Wolves App Epic Hero from Wahapedia 11th-edition datasheet `000000297` (book `000000036`). The local construction catalog supports one copy. His source profile is M7, T5, Sv3+, 4+ invulnerable save, W4, Ld5+, OC1 on a 32 mm base. He carries a Plasma Pistol with standard and supercharge profiles and an Artificer Crozius Arcanum with Anti-Monster 4+ and Anti-Vehicle 4+. Snapshot provenance and file hashes are recorded in the [machine-readable source/hash audit](marine-ulrik-the-slayer-audit.json).

The source lists six Leader targets: Grey Hunters, Assault Intercessor Squad, Wolf Guard Headtakers, Blood Claws, Bladeguard Veteran Squad and Intercessor Squad. All six are represented in the current catalog. Headtakers is partial and selectable at its compatible mixed 6/12-model sizes; the incompatible Headtakers-only rows remain blocked.

## Implemented local abilities

- **Slayer’s Oath:** at the start of the first battle round, the player selects up to one enemy CHARACTER, MONSTER or VEHICLE unit, with an explicit skip option. Against that mark, the local AttackPlan removes net negative BS/WS and Hit modifiers.
- **Oathbound:** the unit’s melee attacks gain +1 to Hit; melee attacks against the selected mark also gain +1 to Wound.
- **Core and faction abilities:** Leader, Combat Doctrines and Transhuman Strategist are registered. Ulrik is eligible to be selected as Warlord.

## Local evidence and limits

Focused offline verification passed 3/3 processes. The connected targeted regression passed 6/6 processes for Ulrik, catalog admission, capability metadata and source Leader links. Network validation was disabled. The verified subject slice has zero structural findings; its parent export has 68 unrelated findings, which are not reported as passed.

This closes Ulrik’s source-bounded local datasheet scope only. The local AttackPlan interprets the Oath permission as removal of net negative modifiers and does not offer a separate per-modifier choice. Headtakers remains partial with its incompatible standalone rows blocked; network/page comparison, human playtesting, full Space Wolves roster restrictions and full army legality are not certified.

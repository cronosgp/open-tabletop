# Wolf Priest

## Source and profile

Wolf Priest is a 75-point Space Wolves App character from the verified Wahapedia 11th-edition export, datasheet `000004129` in book `000000036`. The unit is one model, has a three-copy roster ceiling and uses a 40 mm base. Its profile is M7, T5, Sv3+, 4+ invulnerable save, W4, Ld6+ and OC1. It carries an Absolvor Bolt Pistol and Crozius Arcanum, with no equipment replacements. The snapshot identity, revision, manifest hashes and source-file hashes are in the [machine-readable source/hash audit](marine-wolf-priest-audit.json).

The source lists six Leader targets in this order: Wolf Guard Headtakers, Assault Intercessor Squad, Grey Hunters, Blood Claws, Bladeguard Veteran Squad and Intercessor Squad. All six targets are selectable. Headtakers is a partial profile available at its compatible mixed 6/12-model sizes; its Headtakers-only MFM rows remain blocked by Wahapedia's selected minimum composition.

## Implemented abilities

- **Healing Balms:** during the owner's Command phase, the attached unit receives a D3+1 healing budget through the shared transactional healing flow. The player previews the allocation and confirms it; the ability is limited to once per turn.
- **Litany of Hate:** the unit's melee profile gains Lance. The shared attack plan applies Lance's +1 to Wound only when the unit charged that turn.
- **Core and faction abilities:** Leader and Combat Doctrines are registered. The Wolf Priest can be selected as Warlord under the shared Space Marines rules.

## Local verification and limits

The focused offline verifier passed `test_wolf_priest` in 3/3 processes. The connected Space Wolves/catalog regression passed 11 selected suites in 13/13 processes, including the catalog, capability metadata, Leader links, attacks, Grey Hunters, Blood Claws and the adjacent Space Wolves characters. Both reports ran with `network: false` and no legacy starter staged; exact commands and SHA-256 hashes are recorded in the [machine-readable audit](marine-wolf-priest-audit.json).

The datasheet's subject slice has zero structural findings; the parent export contains 68 unrelated findings. Network/page comparison, human playtesting, full Space Wolves restrictions and full army legality remain open. A broader exploratory selection also exposed separate mismatches between current Support maps and the expected sets in the Apothecary and Sternguard tests; those are recorded in the audit and need their own source reconciliation.

# Immortal Implacable Eradication — training reference

Implemented 16 October 2026. Enable **Match setup → Advanced match options → Next prepared match: Immortals Implacable Eradication (reference)**. Both LAN players must select the same option before creating the match. It applies to canonical Immortals in the mixed Necron reference army or a compatible saved list. Default exercises without Immortals gain no unit effect.

The automatic training policy repeats wound rolls of 1. If any living model in the enemy target squad is in range of a mission objective, it instead repeats failed wound rolls. Successful rolls are always kept; choosing to repeat successes to seek critical wounds is not implemented. This applies to ranged and melee attacks, without CP cost. Target ownership/control and target OC do not gate the bonus. Dead models do not establish range. The custom mission's terrain objectives use their existing area-range definition, while marker objectives use the existing marker-range helper.

Eligibility is captured for each target when attacks are declared, before casualties. Weapon batches with different policies cannot merge. Automatic replacements share one pool with Twin-linked; a replacement cannot be repeated again by either ability or Command Re-roll. Fast resolution and serializable hit/wound checkpoints use the same policy and dice order. Lethal Hits automatic wounds do not generate wound dice.

## Source limitations

The pinned community starter (`data/imported/starter-11e-v1/necrons/units.json`) describes the ones-only effect and marks its 11th-edition data provisional. The objective-dependent extension is a training reference based on the [official 2023 Necron Index](https://www.warhammer-community.com/wp-content/uploads/2023/06/H5pO90rzYSAY6dHG.pdf), an older-edition document. The [2026 Necron faction pack](https://assets.warhammer-community.com/eng_09-06_warhammer40000_faction_pack_necrons-qodfthk7tt-bzeqy07okc.pdf) does not supply this base datasheet for verification. This implementation therefore explicitly does **not** certify the current official 11th-edition Immortal datasheet. Reconfirm the complete current datasheet before upgrading this capability from a reference.

The imported ability DSL remains inert. Only pure squads with canonical definition `40kdc:11e:necrons:immortals` qualify. Renaming a unit does not enable it; mixed future attachments do not inherit the effect automatically. Other unsupported abilities stay disabled.

## Persistence and compatibility

Capability ID: `immortal-implacable-eradication-reference-v1`. The option is frozen in the manifest and public saved-list setup, and persisted in the save configuration. Old saves default to disabled. Conflicting save or LAN settings are rejected. Selected Immortal squads display the ability label. Changing the setup checkbox during play affects the next setup.

`test_implacable_eradication.gd` covers identity, objective range, dead models, dice-policy parity, Twin-linked overlap, Command Re-roll exclusion, real shooting/allocation, melee declaration, frozen eligibility and save/resume. `test_implacable_eradication_network.gd` exercises combined unit options, authoritative guest commands and authenticated LAN reconnect. Loopback tests do not establish separate-machine LAN support.

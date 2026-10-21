# Historical 11e attack lab

> **Data-source status:** This isolated lab's optional Space Marine and Necron profiles were imported from a pinned 40kdc-data snapshot. That input is now legacy and is not an accepted source for current datasheet facts. The lab's calculations do not certify those profiles. See the [current source policy](source-assessment.md); do not use the legacy importer as a fallback for a missing local Wahapedia export.

## Exercise scope

The local **11e attack sequence lab** uses `scripts/edition_11/attack_sequence.gd`. Open the 3D prototype and select **11e attack sequence lab (local)**, or run `scenes/attack_lab.tscn` directly with F6. Entering this local lab disconnects any current multiplayer session.

The lab accepts an attacker, defender, identical weapon count, weapon profile, and target model count, then resolves an attack pool. It does not select legal loadouts or assemble full squads. This is an isolated calculation, not a complete two-faction match. The 3D scene has a separate [persistent combat exercise](../guides/3d-combat.md); neither exercise certifies full army rules.

## Implemented attack calculation

The original implementation was checked against [the official 11e Core Rules PDF](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf), particularly §§04.03–05.04 and applicable §24 weapon abilities:

- Identical attacks resolve in stages, with natural-roll checks and the Strength/Toughness table.
- Saves are sorted ascending before allocating damage. Excess damage from one attack does not transfer to another model.
- Armour penetration and invulnerable saves are evaluated independently.
- Lethal Hits offers automatic wounds as a choice; Sustained Hits creates additional non-critical hits.
- Rapid Fire applies per weapon at half range; Torrent bypasses hit rolls; Twin-linked can re-roll failed wound rolls once.
- Heavy accepts an explicit eligibility flag from the test context. A full match must calculate current e11 eligibility rather than assume an earlier-edition condition.

The resolver accepts fixed integer attacks and damage, one homogeneous non-character defending group, and explicit final roll modifiers. It rejects unknown weapon effects, invalid dice, unresolved effects supplied by a caller, and unsupported random damage. It does not mutate caller models.

Army/unit abilities, cover, distance/visibility eligibility, legal equipment, complete phase flow, mixed allocation groups, characters, reanimation, objectives, and stratagems are outside this lab. Assault/Close-quarters are identified as selection rules outside the calculation. Wounds start at full health on every calculation; this is not a persistent battle simulator.

## Legacy profile reproduction

The historical `tools/import_starter_factions.py` command retrieves 40kdc-data and writes to ignored `data/imported/`. Its pinned profiles may help reproduce the old exercise, but they are **not canonical inputs**, cannot be used to validate current datasheet facts, and do not establish support. The lab currently has no migrated Wahapedia-export reader. Do not commit or distribute the imported profiles.

## Verification boundary

Use the current [verification guide](../verification/verification.md) and [recorded results](../verification/verification-results.md) for reproducible repository checks. A historical attack-lab check or a passing generic test does not certify data provenance, full e11 compliance, army legality, or platform support.

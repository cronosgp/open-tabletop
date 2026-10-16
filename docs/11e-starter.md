# 11th-edition starter: Space Marines and Necrons

## Current result

The first real-rule implementation is `scripts/edition_11/attack_sequence.gd`. Open the 3D prototype and select **11e attack sequence lab (local)**, or run `scenes/attack_lab.tscn` directly with F6. Entering this local lab disconnects any current multiplayer session.

The lab loads locally imported Space Marines and Necron profiles. Choose attacker, defender, identical weapon count, weapon profile, and target model count, then roll an attack pool. The initial selections are Intercessor Squad and Necron Warriors. An attacker with several weapons must have each identical-attack group resolved separately; this screen does not select legal loadouts or assemble full squads.

This is a real core-rule calculation available in the app, not a complete two-faction match. The 3D scene now offers a separate [persistent combat exercise](3d-combat.md) alongside its original movement demo, with host-authoritative shooting, phases, and model wounds. Full army/unit abilities remain outside both exercises.

## Implemented attack rules

Original implementation checked against [the official 11e Core Rules PDF](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf), particularly §§04.03–05.04 and the applicable §24 weapon abilities:

- Identical attacks resolve in stages, with natural-roll checks and the strength/toughness table.
- Saves are sorted ascending before allocating damage. This differs from a conventional per-attack simulator.
- A wounded model is selected first in a homogeneous allocation group. An attack's excess damage does not transfer to another model.
- Armour penetration and invulnerable saves are evaluated independently.
- Lethal Hits offers automatic wounds as a choice; Sustained Hits creates additional non-critical hits.
- Rapid Fire applies per weapon at half range; Torrent bypasses hit rolls; Twin-linked optionally re-rolls failed wound rolls once.
- Heavy accepts an explicit eligibility flag from the test context. A full match must compute its 11e conditions, not assume the older stationary-only condition.

The resolver accepts fixed integer attacks and damage, one homogeneous non-character defending group, and explicit final roll modifiers. It rejects unknown weapon effects, unresolved effects supplied by a caller, invalid dice, and unsupported random damage. It is a pure calculation: it does not mutate the caller's models. A full authoritative match must supply the dice and validate action eligibility.

The lab intentionally isolates that calculation. Army/unit abilities, cover, distance/visibility eligibility, legal equipment, full phase flow, mixed allocation groups, characters, reanimation, objectives, and stratagems are not executed. Assault/Close-quarters are identified as selection rules outside this lab; other unknown weapon mechanics cause a visible error. Wound counts start at full health on every lab calculation. It is not a persistent battle simulator.

## Local source snapshots

Optional Python command (standard library only):

```text
python tools/import_starter_factions.py --output data/imported/starter-11e-v1
```

The tool retrieves a fixed commit of 40kdc-data and converts both factions into our format, including bases, composition, profiles, points, and linked structured weapon/ability records. It imports data, not upstream runtime libraries. Reproduce the inspected snapshot with:

```text
python tools/import_starter_factions.py --revision 709ecd9f5bb6c06b7446eda6a6a0eae6b921a1c8 --output data/imported/starter-11e-v1
```

Use a new output directory for subsequent snapshots. The lab currently uses the documented `starter-11e-v1` location. A fresh checkout requires this optional import before the lab has profiles; the 3D demo works without it.

The inspected snapshot has 196 Space Marine entries and 57 Necron entries. Counts include provider variants and are not a claim that every record is a unique, legal, fully supported unit. Source-specific notices accompany each pack. These local snapshots are ignored by Git.

## Observed source conflicts

OpenHammer returned Intercessor composition with minimum 4 and maximum 2. For the same BSData-linked ID, 40kdc's inspected snapshot lists 5–10 and a different toughness value. Its linked weapon/ability records can also carry provisional versions despite a unit's launch version. We preserve the source revisions and do not silently reconcile these into a certified datasheet. The importer now warns about invalid OpenHammer composition.

Therefore the lab is useful for validating mechanics with source profiles, while full packs remain gated from enforced matches. Phase-aware movement/shooting and persistent casualties now run in the separate integration exercise. Required next work is to settle the first two datasheets against current publications, add their complete unit/army effects, and implement the remaining action types, terrain rules, and mission systems.

## Verification

```text
python -m unittest discover -s tests -p "test_*.py"
godot --headless --path . --script tests/test_attack_sequence.gd
godot --headless --path . --script tests/test_attack_lab.gd
```

The optional integration check requires the local starter snapshot. Windows checks passed for fixed-dice edge cases, import normalization, both lab attack directions, and scene startup. Linux and graphical interaction are still unverified.

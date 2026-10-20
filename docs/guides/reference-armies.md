# Mixed reference armies

> **Legacy training data:** These reference compositions use the pinned 40kdc-data snapshot and its local costs. They are historical exercise fixtures, not current authoritative datasheet data, official points, or certified legal armies. See the [source policy](../data/source-assessment.md).

Implemented on 16 October 2026. These are **core-profile training forces**, using the pinned starter snapshot. They are not complete official armies: characters/warlords, detachments and unlisted unit/faction abilities remain outside this mode. [Intercessor Objective Secured](../rules/objective-secured.md) is now available as an explicit option.

## Ready compositions

Both use the training category with a **500-point limit**, spend **480 points**, and leave 20 unused. Values are the local snapshot's reference costs, not a claim of current official points or competitive balance.

| Army | Composition | Models | Local pack points |
|---|---|---:|---:|
| Space Marines | 2 × 5 Intercessors; 2 × 5 Terminators | 20 | 2 × 80 + 2 × 160 = 480 |
| Necrons | 4 × 10 Warriors; 2 × 5 Immortals | 50 | 4 × 85 + 2 × 70 = 480 |

Choose **Mixed reference — Space Marines / Necrons** in the two setup selectors, then create the local match. The four smaller presets remain available and stay selected by default on a fresh launch. Save independent editable copies to the active profile with the existing copy buttons. **Armies → New mixed reference army** creates an unsaved editable reference for the selected supported faction; it works with the starter installed even without OpenHammer access.

## Admission and execution

`scripts/edition_11/army_capabilities.gd` declares four supported unit types, exact model counts, source identities/API aliases, canonical prices and fixed weapon profiles. It validates profiles against the existing attack engine before admitting them. Supported counts are five Intercessors, five Terminators, ten Warriors or five Immortals per squad. Arbitrary catalog units and larger per-squad compositions remain blocked.

Mixed lists admit one to six squads per player, with a training repetition cap of six Battleline squads or three other squads of one type. Duplicate rows and verified API aliases merge into a canonical, sorted public selection. These are implementation bounds, not a complete official legality validator. Client-supplied prices, stats, extra public fields, cross-faction entries, unsupported sizes and over-budget lists are rejected before changing the match. Each side must choose the same category/limit.

Fixed loadouts:

- Intercessors: existing Saturation bolt rifle and Knives and Fists.
- Terminators: Storm Bolter for all; Power Weapon for the first model (sergeant), Power Fist for the other four. Their own 40mm bases, three wounds, armour and invulnerable defense are used.
- Warriors: existing Gauss Flayer and Close combat weapon.
- Immortals: Gauss Blaster and Close combat weapon, with their own characteristics and imported supported weapon traits.

The factory creates actual model records from each profile, including per-model sergeant equipment; it no longer treats the extra squads as renamed Intercessors/Warriors. Preview formations use three rows for five-model squads and five rows for Warriors, leaving room for different base sizes across six deployment slots. All ten reference squads can confirm the suggested placements and complete the custom five-round mission.

## Explicit remaining rules

The setup summary lists unresolved abilities for each mixed unit type. They are not activated by admitting the numeric profile. Objective Secured is removed from the running squad's disabled list only when its explicit prepared-match option is enabled. This includes the Terminator abilities `deep-strike`, `fury-of-the-first`, `judgement-of-the-weak`, `teleport-homer`, Immortal `implacable-eradication`, and the existing Intercessor/Warrior unsupported abilities in the source snapshot. Faction abilities remain disabled. No undocumented implementation of those rules is implied.

The next reference-army milestone is to verify and implement these abilities and faction rules, add supported commanders/attachments, and then validate complete legal army construction. Transport/reserve/vertical rules should be admitted only when their implementation is complete.

## Compatibility and visuals

Existing single-type one/two-squad selections retain their schema-v1 identity and factory, preserving earlier setup hashes and saves. Mixed or larger selections use a strict schema-v2 public roster nested inside the existing saved-match setup. The match manifest records `mixed-core-profiles-v1`; profiles, notes and reference prices from the local library are not shared. Mixed and legacy selections can face one another when their budget agrees. Local/LAN save/reconstruction uses the same canonical factory.

Automatic ForceOrg matching now recognizes Terminator and Immortal visuals as well. It excludes named Terminator characters and obvious incompatible families, prefers Gauss-labelled Immortals, and preserves the existing manual links and placeholder behavior. Visual variants never configure weapons or rules. Real validation downloaded/linked four unit types, rendered 70 models and completed deployment; see [verification results](../verification/verification-results.md).

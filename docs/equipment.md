# Equipped weapons and profile selection

Enable **Next match: varied training equipment** before starting a combat or objective-training match. Both peers need the same setting. The default unchecked mode retains the fixed-equipment fixtures. This is a curated practice roster using imported profiles, not a legal army builder or validation of datasheet equipment options. Faction/unit abilities and unresolved imported data conflicts remain disabled.

## Curated inventory

| Models | Equipped options in varied training |
|---|---|
| Every Intercessor | Bolt Rifle: Saturation or Focused Fire; Knives and Fists |
| First Intercessor in each squad | Also has chainsword and Thunder Hammer melee alternatives, plus a plasma pistol with Standard/Supercharge profiles |
| Second Intercessor in each squad | Also has a grenade launcher with Krak and Frag profiles |
| Alternating Warriors | One Gauss Flayer or one Gauss Reaper, plus close combat weapon |

All shown characteristics come from the existing starter import. The launcher uses the launch `astartes-grenade-launcher-intercessor-squad` Krak record. Frag now applies Blast. Plasma Standard/Supercharge now implement Close-quarters and Hazardous. Thunder Hammer now implements Devastating Wounds; no keywords are silently dropped to make those profiles playable. Owning one weapon does not grant the model every weapon on its datasheet.

## Planning controls

Select a model and **Plan attacks across targets**. Choose its weapon/profile before choosing the target and assigning attacks. The dropdown lists only profiles for weapons equipped on that model. Selected profiles and weapon names appear in the review and result log.

Each physical ranged weapon chooses one profile and one target. A model with both rifle and launcher may fire both, potentially at different targets. Changing the profile or target of an already assigned ranged weapon replaces its previous assignment, while preserving its other weapons. Different models may use different profiles of the same weapon.

In melee, choose one ordinary melee weapon per model and allocate its full A between engaged targets. Choosing a different melee weapon in the UI replaces that model's previous weapon assignments. The host rejects attempts to combine two ordinary melee weapons, select two profiles of one instance, split one ranged weapon across targets, or use a weapon/profile the model does not own. The planner also supports Extra Attacks for inventories that equip those weapons; see [weapon selection](weapon-selection.md). The current curated inventory has no Extra Attacks weapons.

After Advance, eligibility follows the selected profile: Saturation has Assault; Focused Fire cannot be selected to shoot. Heavy eligibility is evaluated for each applicable profile. Weapon range, cover and Rapid Fire are frozen per model and weapon before casualties.

The ordinary right-click shortcut uses each model's first equipped profile, preserving a simple default attack. Use the planner to choose another profile or fire additional equipped weapons. Range guides describe that default equipped profile; the planner validates its selected profile separately.

## Rules and synchronization

The implementation follows [Core Rules §04.01 and the multiple-profile reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Select-Weapons). Client requests contain weapon/profile identifiers, never authoritative weapon characteristics. Inventory belongs to host state, is fixed for the match and replicates in snapshots. Equipment mode participates in the match compatibility hash.

Applicable attack-count and eligibility mechanics are expanded per selected weapon before pooling: Rapid Fire adds the correct attacks, Heavy supplies its eligible hit modifier, Assault gates selection, and Ignores Cover controls the cover penalty. Attacks sharing the remaining attack characteristics and applicable effects pool together even when their original weapon A differs. Pools with different damage, AP, strength, skill, applicable keywords or modifiers remain separate. Raw profiles are validated before this expansion, so unsupported mechanics reject before dice.

Both automatic allocation and defender-choice mode retain the declared weapon identities and different damage profiles. Defender groups are still homogeneous: mixed attacking equipment does not enable mixed defending profiles or attached characters.

## Validation and remaining work

`test_equipment.gd` covers inventory ownership, profiles, multiple ranged weapons, range/Rapid Fire, Heavy, Assault, one-profile/one-melee-weapon limits, full melee counts, identical pooling and mixed-profile defender allocation. `test_equipment_network.gd` covers guest UI selection for ranged and melee profiles, host rejection of forged choices and synchronized result identities. Its fixture swaps primary-unit ownership so the guest exercises the Marine profile controls.

Eighteen local suites and seven loopback scenarios passed on Windows, including attack-plan, allocation/rejoin, multi-unit and terrain regressions. Ranged and melee profile controls were rendered and visually inspected. Linux and separate-machine LAN remain unverified.

Feel No Pain, Monster/Vehicle shooting, mixed defenders and Precision are supported in [advanced defense](advanced-defense.md). Random melee A supports one target; random-A splits and remaining damage modifiers still need work. Hunter and Extra Attacks support is described in [weapon selection](weapon-selection.md). Army construction, editable equipment rosters, mixed defending groups and attached characters require separate implementation. The battlefield builder remains deferred at low priority.

Blast and bounded random A/D support are described in [weapon mechanics](weapon-mechanics.md).


For plasma eligibility and post-attack allocation, see [Hazardous and Close-quarters](hazardous.md).



See [Devastating Wounds](devastating-wounds.md) for the imported hammer, damage order and defender controls.



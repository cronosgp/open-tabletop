# Defender-selected damage

Enable **Next match: defender chooses damage recipients**, then start a combat or objective-training match. Both peers must select the same option before connecting. The setting is part of the compatibility hash and is preserved when hosting or resetting that mode. The existing unchecked setting remains an explicit **automatic allocation assist** for older test scenarios; the panel identifies which mode is active.

The original increment implemented model choice inside a homogeneous non-character group, following [11e §05.04](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Inflict-Damage). Mixed groups, attached combat profiles, Precision and assigned Feel No Pain are now supported in [advanced defense](advanced-defense.md). Allocation-triggered abilities remain unsupported.

## Resolution window

After the attacker declares the complete plan, the host rolls the current identical-attack pool. Saves are sorted from lowest to highest. With identical saves and no allocation-triggered effects in this exercise, successful saves resolve automatically; each damaging result requires a defender choice.

The panel shows the defending player, target unit, current failed save, damage, remaining damaging results and eligible model IDs. Green rings mark eligible models. Select a miniature and press **Allocate next damaging attack to selected model**. Any living model in the current defending unit can receive the attack, regardless of its visibility or distance from the attacker. If a model has already lost wounds, it must receive the next damaging attack until destroyed. Excess damage from one attack is discarded, rather than transferred to another miniature.

Other commands are blocked while allocation is pending. Shooting/Fight activation, the next fighter, mandatory reaction queues and phase progression resume only after the entire declared plan finishes. The next pool is rolled only after allocation of the current pool; target order and the frozen range/visibility/cover/Rapid Fire declarations are retained. Destroying a target discards attacks still assigned to it, without redirecting them.

Allocation changes miniature wounds as each choice is accepted. A choice and any following pool roll are processed together on a copy of match state; invalid choice, stale revision or dice failure leaves that command's state unchanged and retains earlier accepted allocations. This differs from the automatic assist, which resolves and commits the entire plan in one transaction. There is no cancellation or reroll option after an attack is declared.

The host owns all dice and validates the defender, target group and wounded-model priority. Snapshots carry the pending pool, rolls, cursor and choices. A disconnected guest can rejoin and continue allocation without rerolling. Match snapshots now persist pending choices and dice; the guest proves its locally stored seat credential when reconnecting, including after the host restores a save. See [match persistence](match-persistence.md). Final results record the chosen model, save result, applied damage and discarded excess for each damaging attack.

## Verification and limits

`test_damage_allocation.gd` covers defender identity, choosing a non-default casualty, wounded priority, sorted saves, automatic successful saves, excess damage, repeated/stale/wrong-target rejection, command locking, later-pool failure, multi-target continuation and resuming a mandatory melee reaction only after allocation.

`test_damage_allocation_network.gd` covers ranged and melee host/client scenarios, defender UI, invalid commands, a disconnect/rejoin during wounded-model allocation, and synchronized completion. Seventeen local suites and eight loopback scenarios passed on Windows. Allocation and wounded-priority panels were rendered and visually inspected. Linux and separate-machine LAN remain unverified.

[Mixed attacking equipment and profile selection](equipment.md) are now available in an optional training roster. Mixed defending profiles, group ordering, characters and assigned Feel No Pain now have their own validated allocation flow; see [advanced defense](advanced-defense.md). Unlisted allocation-triggered abilities remain disabled.

[Devastating Wounds](devastating-wounds.md) adds a distinct no-save mortal-packet choice after each pool's normal damage. The same defender, wounded-priority, revision and reconnection checks apply. Assigned Feel No Pain and character groups are now supported in [advanced defense](advanced-defense.md).


[Advanced defense](advanced-defense.md) now adds mixed-group order before save revelation, character groups, attacker-controlled Precision and per-model Feel No Pain. The synthetic rules lab exposes these choices in the UI and supports host/client rejoin. Protocol is v21.




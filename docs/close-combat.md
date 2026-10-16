# Charges and melee in the 3D exercise

The integration scenario supports editable charge, pile-in, overrun and enemy-directed consolidation moves, alongside melee attacks. The rules baseline is [11e Core Rules and FAQs](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), particularly §§03.01–03.04, 11.02–11.04 and 12.02–12.08, including the ongoing-consolidation erratum. This remains a restricted flat-board exercise.

## Charge controls

1. In Charge, select a living friendly miniature and press **Roll charge for selected squad (2D6)**.
2. The host rolls and retains the result. Right-click enemy miniatures to toggle their squads as charge targets, then press **Begin charge placement**. The target set is locked while placing models.
3. Left-click each friendly model and right-click destinations to build its path from straight segments. Each model has the rolled distance as an accumulated budget. Press **Confirm contact movement** when the whole squad is ready. A successful charge grants Fights First for the turn.
4. **Cancel contact placement** restores the starting positions and retains the roll and target choices. Targets can then be changed. **Finish pending charge without moving** restores positions and consumes the declaration. Neither option grants another roll. A roll with no target within the rolled distance immediately fails without movement.

A charge target must be within the full rolled distance and within 12 inches. Being able to reach engagement range with a shorter roll does not make a farther target eligible. Engaged squads cannot declare a charge. Pending rolls must be resolved or declined before advancing the phase. The interface and host reject extra declarations, stale requests, and other-player commands.

Manual paths are checked against terrain, enemy bases, destination overlaps and battlefield bounds. Final confirmation checks connected coherency, approach conditions, engagement with every declared target, and absence of engagement with undeclared enemies. Target selection accepts multiple squads; the optional two-unit-per-player training mode supplies multiple opposing units. A sampled straight-line assist remains for older fixtures and also passes final validation; it is not the player-facing placement mechanism.

The host can now [certify terrain and coherency exceptions](contact-reachability.md) to an approach requirement. Terrain uses a relaxed route lower bound; coherency considers all friendly models' reachable domains, base-contact locks and retained engagements. An accepted exception is recorded in the event log and replicated to clients. Analysis that reaches its work limit remains inconclusive and does not waive the requirement, so some legal complex placements can still be rejected. Charges check the 1-inch and engagement duties independently.

Normal movement uses [individual model placement](tactical-controls.md), with connected coherency checked at squad confirmation. At End of Turn, each controlling player selects and removes models from their incoherent squad until coherency is restored. Phase advancement is blocked while these choices remain; the interface switches the acting player when the opponent must choose.

## Fight controls and order

Both players act in Fight even though the overall turn owner stays unchanged. The sidebar shows **player acts**, the substep, and the current priority.

- The active player, then the opponent, may begin an optional pile-in, place models individually and confirm it, or decline movement. Confirmation advances to the other player's window automatically.
- Once the attack step starts, select a living model in the acting squad and right-click an enemy model. Every model engaged with that enemy unit contributes its fixed melee weapon's attacks. Models outside engagement do not contribute.
- Charging units resolve first. Once no eligible Fights First unit remains, remaining combats continue from the player who moves the sequence to that stage. This uses 11e ordering; it does not hard-code the 10e defender-first rule.
- An engaged, eligible squad must fight once before the step can finish. The defender's input window is enforced by the host, including when it is not that player's overall turn.
- A unit that remains eligible while unengaged, or became engaged after the Fight step began, may use **Begin overrun pile-in** for one additional pile-in before its attacks. The move does not consume its attacks. A newly engaged enemy becomes eligible to fight. Advancing an unengaged fight still allows declining this movement and making no attacks.
- After attacks, active player then opponent may consolidate or decline. The mode is selected automatically: ongoing while engaged, otherwise engaging if an enemy is within 3 inches. Enemy-directed consolidation is limited to 3 inches per model. Objective-directed consolidation is unavailable until objectives are implemented.
- Models in base contact cannot move during pile-in or ongoing consolidation. Models that move must approach the closest selected enemy and meet the supported engagement requirement. Each model retains the enemy units it started engaged with. Consolidation that contacts an enemy that has not fought opens a mandatory enemy fight window, then resumes consolidation order.

The imported fixed melee profiles are **Knives and Fists** for Intercessors and **Close combat weapon** for Warriors. Damage, dice, and casualties use the same authoritative kernel and persistent model wounds as shooting. No client submits dice, charge distance, placement, or damage. Charging priority expires when the overall turn ends.

Army abilities, unit abilities, innate Fights First abilities, arbitrary weapon selection, full terrain rules, and official mission systems remain outside this exercise. Objective consolidation and [multiple-unit fight/reaction queues](multiple-units.md) are available with the documented limits. [Advance and Fall Back](movement-types.md) block charge declarations for the turn when completed. The complete official edition pack is still disabled.

## Verification

```text
godot --headless --path . --script tests/test_close_combat.gd
godot --headless --path . --script tests/test_contact_actions.gd
```

For the optional two-process check (requires imported starter packs), start the host first, then the client within ten seconds:

```text
godot --headless --path . --script tests/test_melee_network.gd -- --host-test
godot --headless --path . --script tests/test_melee_network.gd -- --client-test
```

The network test positions units in a close-range fixture; the normal game still uses its original deployment. Windows checks cover charge failure/decline, post-roll target choice, individual placements and coherency, both factions charging, priority and actor switching, mandatory fights, casualties removing engagement, stale/duplicate commands, defender input, and replicated casualty meshes. Rendered charge-selection and defender-action screens were visually inspected. Linux and separate-machine LAN remain unverified.

`test_contact_network.gd` uses the same host/client arguments to exercise the player-facing charge target selection, multi-segment placement, cancellation without rerolls, pile-in, combat and consolidation windows over loopback. `test_contact_actions.gd` additionally covers overrun, multiple charge targets, base-contact locks, conservative approach validation, undeclared engagement and mandatory consolidation retaliation.

Objective consolidation is now available when no enemy is within 3 inches and an objective is within 3 inches. Choose the objective in the dropdown before beginning placement; finish unengaged and within range. See [objective consolidation controls and geometric limits](objectives.md#objective-consolidation).


[Attack plans](attack-plans.md) now split a model's fixed melee weapon attacks between engaged target units. Every eligible model must allocate its full attack count before confirmation; Fight/reaction queues advance once for the whole unit.

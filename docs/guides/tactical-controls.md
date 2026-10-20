# Individual miniature movement and tactical guides

Normal movement in the 3D combat exercise now repositions individual miniatures. The squad remains the activation unit: place its models, then confirm that squad's movement once.

## Movement controls

1. In Movement, left-click a living friendly miniature. Its body and base marker identify the selected model; squadmates retain their faction color.
2. Right-click a destination to stage a straight movement segment for that miniature. Its squadmates stay in place.
3. Select another model to reposition it, or add another segment to the selected model's path. Every model has its own cumulative movement budget; moving back toward its starting point still costs distance.
4. Press **Confirm squad movement** when finished. The host checks final coherency and closes the squad's movement activation. Models left in place cost no movement.
5. Use **Cancel pending movement** to restore the whole uncommitted squad to its original positions and movement budgets.

Coherency can temporarily break while arranging models. Confirmation stays disabled until the squad is coherent; other miniatures can be repositioned to repair it. The phase cannot advance while a movement draft exists. Confirmation or cancellation is shared with the other player, and stale or other-player requests are rejected by the host.

Terrain, board edges, remaining distance, and destination base overlap are checked for every segment. Friendly models and enemy engagement range can be crossed in transit, while enemy bases cannot. A normal move must finish with the whole squad unengaged and in one connected coherent group; drafts that fail these final checks remain editable or can be cancelled. Orange previews flag positions needing correction before confirmation. Confirmed squads cannot activate again that phase. Heavy eligibility uses the longest accumulated path among all squad models.

The [movement type controls](../rules/movement-types.md) add Advance bonuses to each model's displayed budget. Desperate Escape permits crossing enemy bases, with occupied destinations still rejected. Dice-backed and Fall Back selections retain their dice, damage and type when resetting placement; their control labels distinguish resetting from cancelling a Normal Move.

During [contact placement](../rules/close-combat.md), right-click adds a segment to the selected model's charge, pile-in, overrun or consolidation path. Orange guides show its remaining contact budget; base-contact locks appear in the guide caption. Confirm validates the completed squad arrangement, while Cancel restores all its contact origins. Charge cancellation retains the original host roll.

## Guides

**Show tactical ranges** toggles local visual overlays without changing the match.

| Visual | Meaning |
| --- | --- |
| Yellow body and pale base ring | Selected miniature |
| Green movement area | Remaining distance from that model's current position |
| Pale original-base marker | Starting point of the current uncommitted movement |
| Green/red squad links | Nearby coherency connections or missing neighbors; long red links also flag excessive separation |
| Green cursor footprint and path | A valid individual movement segment |
| Amber cursor footprint | The segment is valid, but the projected squad needs coherency repair before confirmation |
| Red cursor footprint | Segment rejected by distance, base, terrain, board, ownership, or phase checks |
| Blue area | Selected model's weapon reach measured from its base |
| Green/red enemy base rings | Visible and in range / blocked or beyond the selected model's range |
| Orange area | Charge target-distance guide, using the actual roll after declaration, or 2-inch engagement reach in Fight |

Hovering an enemy also shows its distance and a colored line. Shooting guides describe the selected model; shooting still resolves the squad's eligible models together. Charge target highlights use the squad's minimum distance, while the circle is centered on the selected model. A valid distance does not guarantee a legal charge placement.

All guide geometry is clipped to the fixed battlefield. Distance circles are not pathfinding maps and do not remove obstacles from their fill. Cursor checks use the same movement validator as the host, but the host remains authoritative if the match changes before a command arrives. The guides share the host terrain and cylindrical visibility proxies, including cover and Hidden detection captions. See [terrain limits](../rules/terrain.md).

The sidebar is scrollable to keep confirmation/cancellation controls and event history accessible. The original movement demo remains separate; the combat exercise provides squad confirmation and per-model cumulative budgets.

## Verification

```text
godot --headless --path . --script tests/test_individual_movement.gd
godot --headless --path . --script tests/test_tactical_guides.gd
```

Optional network check: start the host, then the client in another terminal within ten seconds.

```text
godot --headless --path . --script tests/test_movement_network.gd -- --host-test
godot --headless --path . --script tests/test_movement_network.gd -- --client-test
```

Windows verification covers independent budgets, accumulated paths, temporary coherency loss and repair, rollback, single squad activation, endpoint/path restrictions, guide distances and board clipping, blocked targeting, read-only previews, and two-process draft/confirm/cancel synchronization. Movement and shooting overlays were visually inspected. Linux and separate-machine LAN remain unverified.

Use **Plan attacks across targets** during Shooting or an eligible Fight window to assign individual models and split melee attack counts. Review [the planning controls](../rules/attack-plans.md) before confirmation. Each result pool now identifies its target in the event log.

Before starting a new match, **Next match: defender chooses damage recipients** enables [interactive damage allocation](../rules/defender-allocation.md). Both peers need the same setting. During allocation, select a green-ringed eligible defender and press the allocation button; other actions remain locked until the declared attacks finish.

The optional [varied equipment roster](../rules/equipment.md) adds a weapon/profile dropdown to the planner, per-model inventory limits and selected-profile eligibility. Enable it before starting a new match; both peers must use the same setting.

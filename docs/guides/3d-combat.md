# Persistent 3D combat exercise

> **Legacy data:** This exercise's imported unit profiles come from the pinned 40kdc-data snapshot. That snapshot is not an accepted source for current datasheet facts or certification. See the [current source policy](../data/source-assessment.md); this path remains only for reproducing the existing exercise until ingestion is migrated.

## Play locally

1. Open `project.godot` in Godot 4.7.2 and press F5.
2. Select **Start 3D combat exercise: Marines / Necrons**.
3. Use **Advance phase** to pass Start turn and Command and reach Movement.
4. Left-click a friendly miniature and right-click a destination to reposition that model only. Place the squad's models individually, then use **Confirm squad movement**. **Cancel pending movement** restores the uncommitted positions. See [movement and range guides](tactical-controls.md).
5. Advance to Shooting. With a friendly miniature selected, right-click a living enemy miniature to target its squad. The host determines eligible firing models and resolves their attacks.
6. In Charge, roll first, toggle enemy targets with right-click, begin placement, move models individually and confirm. In Fight, follow the acting-player/substep labels for optional pile-in, required attacks, optional overrun and consolidation. See [charge and melee controls](../rules/close-combat.md).
7. Finish the remaining steps to change players. Local mode controls both players. Wounds and casualties persist across turns; destroyed miniatures disappear and stop blocking movement.

Player 1 has five Intercessors with the imported **Bolt Rifle / Saturation** profile. Player 2 has ten Necron Warriors with **Gauss flayers**. Each model is a separate 3D piece with a base and remaining wounds. The selected squad is highlighted; selected-model wounds, model counts, phases, Core CP, events, and the most recent dice rolls appear in the sidebar.

The local data import is required for this exercise. If absent, the game reports the missing pack and keeps the movement demo available:

```text
python tools/import_starter_factions.py --revision 709ecd9f5bb6c06b7446eda6a6a0eae6b921a1c8 --output data/imported/starter-11e-v1
```

## Two-player LAN

Both players select the combat exercise before connecting. One selects **Host LAN** and the other enters the host's LAN IP and selects **Join**. Both installations need identical local starter data. The receiver rejects a different mode or unit-content hash.

Only the host rolls dice and changes authoritative wounds, positions, phases, and model counts. Client requests contain model IDs, expected state revision, and the player's Lethal Hits choice; they cannot submit damage or dice. Wrong-turn, stale, duplicate, dead-model, friendly-fire, wrong-phase, and already-used-unit requests are rejected. A rejected request does not consume the action.

A disconnected guest can rejoin the same in-memory host session. **Local preview / disconnect** starts a fresh local exercise. Leaving for the isolated attack lab also ends the network connection. No persistent disk save or authenticated player recovery is implemented.

## Scope of the exercise

This connects the implemented 11e attack kernel to the 3D/network layer. It remains an integration exercise, **not a complete official match**. The sidebar identifies the missing systems throughout play.

- The seven turn parts are ordered; both players gain one Core CP on entering Command. On leaving Command, the host resolves battle-shock for the active player's surviving units at or below half-strength or already battle-shocked. Status persists until a successful test in that unit's Command phase. Other start/end triggers, army abilities, and stratagem spending are not executed.
- Normal movement uses individual straight segments with a separate accumulated budget for each model. Models may pass through enemy engagement range, avoiding enemy bases; the completed squad move must end unengaged. Coherency requires a connected group as well as the 2-inch neighbour and 9-inch diameter checks. Pending movement blocks phase advancement. [Movement choices](../rules/movement-types.md) now include Advance, Ordered Retreat, Desperate Escape and explicit stationary selections, with retained host dice, owner-allocated escape mortal wounds and turn-long eligibility restrictions. Charge placement uses its separate individual planner.
- At End of Turn, each owner selects models from their incoherent squad and uses **Remove selected model for coherency** until it is coherent. The turn owner's choices come first, then their opponent's. Local mode follows the current actor; LAN grants the opponent an out-of-turn choice window. These removals do not generate destroyed-model ability triggers.
- The sidebar shows selected-model morale and effective OC. Battle-shocked models contribute no OC. Morale eligibility gates for friendly stratagem targets and starting actions are available to future systems; stratagems, actions, and objective scoring themselves remain unimplemented.
- Shooting supports the fixed identical loadouts, unengaged units, distance measured between bases, and per-model eligibility. Advancing permits Assault weapons only; a completed Fall Back prevents shooting. Range/visibility and Rapid Fire group membership are fixed before damage resolution. A squad can shoot once per Shooting phase.
- The default board uses dense ruins, exposed rubble and a light barricade. Ground traversal, cover, Hidden, detection, Obscuring and Gone to Ground use cylindrical visibility proxies. Cover worsens BS by 1 and splits attack pools per shooter. One central first floor supports a bounded movement slice; elevated ranged visibility and exact imported-mesh visibility remain unsupported. See [terrain and geometry limits](../rules/terrain.md).
- Save allocation automatically chooses a wounded model first, then model ID. Defender-selected casualties, mixed profiles, and attached characters are not supported.
- Charge declarations, host 2D6, post-roll target selection, manual paths, Fights First from charges, and normal melee attacks are available. Pile-in, overrun and enemy-directed consolidation use individual 3-inch movement budgets and confirmation. Base contact, retained engagement and consolidation retaliation are enforced. [Terrain/coherency approach exceptions](../rules/contact-reachability.md) are accepted when the host proves them; unresolved cases remain restricted. Objective consolidation and exhaustive certification remain unsupported.
- Army/unit abilities including Oath of Moment, reanimation, and objective effects are explicitly outside the exercise. These omissions must be implemented before enabling an official rules pack.
- Elimination finishes this test exercise; it does not implement official mission scoring or victory conditions.

Source profile conflicts described in [11e-starter.md](../data/11e-starter.md) remain unresolved. The source snapshots supply test profiles and do not certify datasheet correctness. No remote service is required while playing.

## Verification

```text
godot --headless --path . --script tests/test_combat_scenario.gd
godot --headless --path . --script tests/test_morale_coherency.gd
```

For network integration, run the host command first and the client in a second terminal within ten seconds:

```text
godot --headless --path . --script tests/test_combat_network.gd -- --host-test
godot --headless --path . --script tests/test_combat_network.gd -- --client-test
```

Use `tests/test_morale_network.gd` with the same host/client arguments to check player-selected coherency removals, out-of-turn permissions, synchronized battle-shock and OC, and stale-request rejection. See [implementation status](../project/rules-status.md) for the remaining work.

Windows checks cover phase restrictions, individual model movement, squad confirmation, blocked and out-of-range attacks, durable in-session casualties, Core CP, stale/repeated commands, synchronized host/client attacks, and hidden destroyed meshes. The rendered interface and tactical overlays were visually inspected on Windows. Linux and separate-machine LAN have not been verified.

A separate **Start custom objective training (5 rounds)** button enables [terrain objectives and a custom VP mission](../rules/objectives.md). End-of-phase control uses effective OC. This mode finishes by points after five rounds; the existing combat exercise still finishes by elimination.

Custom objective training now offers [Secure Ground](../rules/actions.md), with core action eligibility and host-synchronized progress/completion. Select a unit during Shooting to choose an objective. Starting it prevents shooting (except Titanic) and charges until turn end, even if the action fails.

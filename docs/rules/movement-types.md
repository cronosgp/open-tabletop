# Movement choices in the combat exercise

In Movement, select a living friendly model, choose a movement type from the dropdown, and press **Begin selected movement**. Right-clicking before choosing a type still starts a Normal Move. Place models individually and confirm the squad. Models left without a selection when advancing to Shooting are recorded as stationary.

Implemented against the [Warhammer 40,000 11th-edition Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) (Wahapedia page lists the Core Rules update as June 2026), §§03.01, 06.02–06.03, 09.04–09.07, 10.04–10.05, 11.02 and 24.04:

- **Advance:** host rolls one D6, adding that result to each model's movement allowance. The squad must start and finish unengaged. Only its Assault weapons may shoot afterwards; charging and starting actions are unavailable until the turn ends.
- **Fall Back — Ordered Retreat:** requires an engaged squad that is not battle-shocked. Models use their normal movement allowance and cannot cross enemy bases.
- **Fall Back — Desperate Escape:** available to engaged squads, including battle-shocked squads. The host rolls one hazard per living model before placement. For these infantry squads, each 1–2 inflicts one mortal wound. The owner allocates each wound under the Mortal Wounds sequence: a wounded non-Character first, otherwise any non-Character, then a wounded Character, then any Character. The shared decision and the rules validator use this same eligibility order. Surviving models can cross enemy bases but cannot finish overlapping them.
- Both Fall Back modes must finish coherent and unengaged. A completed Fall Back prevents shooting, charging and starting actions until the turn ends. A steady squad completing Desperate Escape also makes a battle-shock roll.

The sidebar shows the selected type, Advance bonus, remaining escape damage, and per-model budgets. The movement guide includes the rolled bonus. Hazard wounds must be allocated before placement or confirmation; destroyed models disappear immediately. Models destroyed by escape damage are retained as casualties if placement is reset.

For Advance and Fall Back, **Reset placement** restores starting positions and budgets while retaining the selected type, dice and damage. It cannot grant a reroll or change movement types. Normal Move drafts retain their existing cancel behavior.

If Fall Back cannot be completed, **Abandon Fall Back** restores positions and consumes the squad's movement selection, retaining escape damage. The unsuccessful move is recorded separately from a completed Fall Back. It cannot be selected again that phase. All hazard damage must be resolved first. Advance can be confirmed with no displacement while retaining its restrictions.

This implementation covers the two homogeneous infantry squads. Monster/vehicle hazard multipliers, Feel No Pain, hazard modifiers, exceptions from abilities and stratagems, transports, and flying remain unsupported. Action eligibility queries exist, but a complete action system is not yet available.

Verification:

```text
godot --headless --path . --script tests/test_movement_types.gd
godot --headless --path . --script tests/test_movement_types_network.gd -- --host-test
godot --headless --path . --script tests/test_movement_types_network.gd -- --client-test
```

Start the host and client in separate terminals for the network test. Windows deterministic tests and two-process loopback checks pass; Linux and separate-machine LAN remain unverified.

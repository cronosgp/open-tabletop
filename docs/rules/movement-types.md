# Movement choices in the combat exercise

In Movement, select a living friendly model, choose a movement type from the dropdown, and press **Begin selected movement**. Right-clicking before choosing a type still starts a Normal Move. Place models individually and confirm the squad. Models left without a selection when advancing to Shooting are recorded as stationary.

Implemented against the [Warhammer 40,000 11th-edition Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) (Wahapedia page lists the Core Rules update as June 2026). The matching page was checked on 13 November 2026 because Core Rules are not part of the local datasheet export; §§03.01 and 17.01 define friendly-model movement and the MONSTER/VEHICLE passage exception, while §§21.03 and 24.17 define the FLY declaration, its 2-inch maximum-distance reduction and the HOVER exception. Other cited sections are §§06.02–06.03, 09.04–09.07, 10.04–10.05, 11.02 and 24.04:

- **Advance:** host rolls one D6, adding that result to each model's movement allowance. The squad must start and finish unengaged. Only its Assault weapons may shoot afterwards; charging and starting actions are unavailable until the turn ends.
- **Fall Back — Ordered Retreat:** requires an engaged squad that is not battle-shocked. Models use their normal movement allowance and cannot cross enemy bases.
- **Fall Back — Desperate Escape:** available to engaged squads, including battle-shocked squads. The host rolls one Hazard per model before placement. Each failed 1–2 inflicts one mortal wound, or three mortal wounds if every model in the unit is a MONSTER or VEHICLE. The owner allocates each wound under the Mortal Wounds sequence: a wounded non-Character first, otherwise any non-Character, then a wounded Character, then any Character. The shared decision and the rules validator use this same eligibility order. Surviving models can cross enemy bases but cannot finish overlapping them.
- Both Fall Back modes must finish coherent and unengaged. A completed Fall Back prevents shooting, charging and starting actions until the turn ends. A steady squad completing Desperate Escape also makes a battle-shock roll.

**MONSTER/VEHICLE model passage:** during a Normal Move or Advance, those models can pass through friendly and enemy models except other MONSTER/VEHICLE models. The §17.01 FAQ also allows them to pass through friendly models during other move types; this does not allow passage through enemy models on a Charge. Focused offline checks cover the shared Movement-phase path and supported Purgation Run Normal Move, friendly/enemy ordinary passage, blocking MONSTER/VEHICLE bases, the non-MONSTER/VEHICLE control, Charge boundaries and endpoint overlap. Terrain, distance, coherency and end-of-move restrictions still apply. Human playtesting, network validation and full army legality remain uncertified.

**Take to the Skies:** when a FLYING unit is selected for a Normal Move, Advance, Fall Back or Charge, the player may declare this before the move; an Advance or Charge declaration happens before its roll. If declared, FLY models can move through all models and terrain while ignoring vertical distance, and the maximum distance for every model in the unit is reduced by 2 inches unless that unit has HOVER. Without the declaration, FLY models use the ordinary terrain and vertical-distance rules. The Movement choice persists through a pending movement-stratagem or Advance-roll decision; the Charge choice persists through its stratagem and Charge-roll decisions and applies to target range and placement. Focused offline checks now cover declaration, model and dense-wall passage, the movement/Charge reductions, Advance timing, HOVER and vertical-distance bypass on the default first floor. Upper-floor Charge contact, bounded 3D visibility, Plunging Fire and playtesting remain pending. Visible attacks from those floors can receive Plunging Fire against a target unit containing a ground-level model, subject to the supported-layout proxy limits in [terrain rules](terrain.md); the cited Core Rules are §§06.01, 13.07, 13.10–13.11, 15.09, 22.05 and 23.03.

The sidebar shows the selected type, Advance bonus, remaining escape damage, and per-model budgets. The movement guide includes the rolled bonus. Hazard wounds must be allocated before placement or confirmation; destroyed models disappear immediately. Models destroyed by escape damage are retained as casualties if placement is reset.

For Advance and Fall Back, **Reset placement** restores starting positions and budgets while retaining the selected type, dice and damage. It cannot grant a reroll or change movement types. Normal Move drafts retain their existing cancel behavior.

If Fall Back cannot be completed, **Abandon Fall Back** restores positions and consumes the squad's movement selection, retaining escape damage. The unsuccessful move is recorded separately from a completed Fall Back. It cannot be selected again that phase. All hazard damage must be resolved first. Advance can be confirmed with no displacement while retaining its restrictions.

Desperate Escape applies the 11e all-MONSTER/VEHICLE multiplier through the shared Hazard roll resolver, and allocated wounds use the shared prevention path. Combat and Emergency Disembark also use that multiplier; only those two transport modes roll Hazard per passenger model. Focused movement and transport checks remain pending. Hazard modifiers and exceptions from abilities and stratagems, broader transport mechanics, and general army-wide flying coverage remain unsupported. Action eligibility queries exist, but a complete action system is not yet available.

Verification:

```text
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_take_to_skies --timeout 300
python tools/verify.py --godot C:/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_monster_vehicle_passage --timeout 300
godot --headless --path . --script tests/test_movement_types.gd
godot --headless --path . --script tests/test_movement_types_network.gd -- --host-test
godot --headless --path . --script tests/test_movement_types_network.gd -- --client-test
```

The focused Take to the Skies and MONSTER/VEHICLE passage regressions pass locally with network access disabled; the two-process movement suite covers its older movement scope. These checks do not certify upper-floor Charge placement, bounded visibility or Plunging Fire. Start the host and client in separate terminals for the network test. Linux, separate-machine LAN and human playtesting remain unverified.

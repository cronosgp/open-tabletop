extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
var dice_index := 0
var successful_rolls := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func six() -> int: return 6

func damage_rolls() -> int:
	dice_index += 1
	return 6 if dice_index <= successful_rolls else 1

func to_phase(state: Dictionary, phase: String) -> void:
	for step in range(7):
		if state.phase == phase: return
		Combat.advance_phase(state, state.active, state.revision)

func _initialize() -> void:
	var state := Combat.initial_state("legacy-solid-v1")
	if state.has("error"):
		push_error(state.error)
		quit(1)
		return
	check(Combat.living(state, 1).size() == 5 and Combat.living(state, 2).size() == 10, "Wrong starting model counts")
	check(not Combat.move(state, 1, 100, Vector2(-9, -4), state.revision).is_empty(), "Movement outside phase accepted")
	check(not Combat.advance_phase(state, 2, state.revision).is_empty(), "Guest advanced host phase")
	to_phase(state, "movement")
	check(state.cp[1] == 1 and state.cp[2] == 1, "Both players should gain Core CP")
	check(not Combat.move(state, 1, 100, Vector2(NAN, 0), state.revision).is_empty(), "NaN accepted")
	check(not Combat.move(state, 1, 100, Vector2(-16, -4), state.revision).is_empty(), "Off-board formation accepted")
	var old: Vector2 = state.units[104].position
	var revision: int = state.revision
	check(Combat.move(state, 1, 100, Vector2(-13, -4), revision) == "", "Valid miniature move rejected")
	check(state.units[104].position == old, "Moving one miniature also moved a squadmate")
	check(not Combat.move(state, 1, 100, Vector2(-10, -4), revision).is_empty(), "Stale move accepted")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Coherent squad movement confirmation failed")
	check(not Combat.move(state, 1, 100, Vector2(-10, -4), state.revision).is_empty(), "Second squad move accepted")
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty(), "Shooting outside phase accepted")
	to_phase(state, "shooting")
	check(not Combat.shoot(state, 2, 200, 100, state.revision, true, six).error.is_empty(), "Wrong-turn attack accepted")
	check(not Combat.shoot(state, 1, 100, 101, state.revision, true, six).error.is_empty(), "Friendly target accepted")
	check(not Combat.shoot(state, 1, 100, 200, state.revision - 1, true, six).error.is_empty(), "Stale attack accepted")
	# Probe only the copy to determine the number of visible shooting models.
	var probe: Dictionary = state.duplicate(true)
	var result := Combat.shoot(probe, 1, 100, 200, probe.revision, true, six)
	check(result.error == "" and result.pools.size() == 1, "Identical Bolt Rifles must form one pool")
	successful_rolls = int(result.pools[0].attacks) * 2
	check(result.pools[0].attacks < 10, "Solid central terrain should block some shooters")
	result = Combat.shoot(state, 1, 100, 200, state.revision, true, damage_rolls)
	check(result.error == "" and state.last_attack.pools[0].damage_applied > 0, "Attack did not persist damage")
	check(Combat.living(state, 2).size() < 10 and state.units[200].wounds == 0, "Casualties not persisted")
	var count := Combat.living(state, 2).size()
	check(not Combat.shoot(state, 1, 100, 209, state.revision, true, six).error.is_empty(), "Second shooting activation accepted")
	to_phase(state, "end_turn")
	check(Combat.advance_phase(state, 1, state.revision) == "" and state.active == 2, "Turn did not change")
	check(Combat.living(state, 2).size() == count, "Casualties restored across turns")
	to_phase(state, "movement")
	check(not Combat.move(state, 2, 200, Vector2(7, -4), state.revision).is_empty(), "Dead model moved")
	check(Combat.move(state, 2, 209, state.units[209].position + Vector2(0.1, 0), state.revision) == "", "Dead bases still block movement")
	# Out-of-range and fully blocked targets reject without consuming the activation.
	state = Combat.initial_state("legacy-solid-v1")
	to_phase(state, "shooting")
	for id: int in Combat.living(state, 1): state.units[id].position = Vector2(-14, 0)
	for id: int in Combat.living(state, 2): state.units[id].position = Vector2(14, 0)
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty() and not state.squads[1].shot, "Out-of-range shot consumed activation")
	for id: int in Combat.living(state, 1): state.units[id].position = Vector2(-8, 0)
	for id: int in Combat.living(state, 2): state.units[id].position = Vector2(8, 0)
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty(), "Shot through solid terrain accepted")
	# A surviving wounded Marine retains its actual model identity.
	state = Combat.initial_state("legacy-solid-v1")
	state.active = 2
	to_phase(state, "shooting")
	var partial_rng := RandomNumberGenerator.new()
	partial_rng.seed = 42
	result = Combat.shoot(state, 2, 200, 100, state.revision, false, func(): return partial_rng.randi_range(1, 6))
	check(result.error == "", "Necron shooting rejected")
	var total := 0
	for id: int in Combat.living(state, 1): total += state.units[id].wounds
	check(total == 10 - int(state.last_attack.pools[0].damage_applied), "Marine wound totals disagree with pool")
	print("3D combat scenario checks complete: %d failures" % failures)
	quit(1 if failures else 0)

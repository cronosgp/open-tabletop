extends SceneTree
const Fixture = preload("res://tests/all_units_fixture.gd")
const Combat = Fixture.C
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func make_state() -> Dictionary:
	var selections := Fixture.current_marine_selections()
	selections[1].entries = [entry("captain"), entry("rhino"), entry("intercessor-squad", 5), entry("assault-intercessor-squad", 5)]
	selections[2].entries = [entry("intercessor-squad", 5)]
	var state := Fixture.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)
	if state.has("error"): return state
	state.mission.stage = "battle"
	state.phase = "shooting"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.revision = 0
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = Combat.UnitActions.key(state)
	state.awakened_dynasty.pending = []
	state.terrain.areas = []
	var transport := -1
	var transport_squad := -1
	var passengers: Array[int] = []
	var passenger_squads: Dictionary = {}
	var target := -1
	for squad: int in state.squads:
		if int(state.squads[squad].owner) == 2: target = squad
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		unit.on_battlefield = true
		unit.position = Vector2(-4, 0) if int(unit.owner) == 1 else Vector2(5, 0)
		var identity := Combat.UnitAbilities.identity(unit)
		if identity == "rhino":
			transport = model
			transport_squad = int(unit.squad)
		elif identity in ["intercessor-squad", "assault-intercessor-squad"] and int(unit.owner) == 1:
			passengers.append(model)
			passenger_squads[int(unit.squad)] = true
	if transport < 0 or target < 0 or passengers.size() != 10: return {"error": "Firing Deck fixture did not materialize its transport, passengers and target."}
	state.units[transport].position = Vector2(0, 0)
	state.squads[transport_squad].shot = false
	for passenger: int in passengers:
		state.units[passenger].on_battlefield = false
		state.units[passenger].embarked_transport = transport
	for squad: int in passenger_squads:
		state.squads[squad].embarked_in = transport
		state.squads[squad].shot = false
	# Add a synthetic One Shot option so the shared exclusion is exercised.
	var one_shot_model := passengers[0]
	var one_shot: Dictionary = state.units[one_shot_model].ranged_weapons[0].duplicate(true)
	one_shot.id = "test-one-shot"
	one_shot.name = "One Shot test weapon"
	for profile_name: String in one_shot.profiles:
		one_shot.profiles[profile_name].keywords["one-shot"] = true
	state.units[one_shot_model].ranged_weapons.append(one_shot)
	state.squads[int(state.units[passengers[5]].squad)].shot = true
	state.test_firing_deck_transport = transport
	state.test_firing_deck_target = target
	state.test_firing_deck_passengers = passengers
	return state

func options_for_model(state: Dictionary, transport: int, source_model: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option: Dictionary in Equipment.choices(state, transport, false):
		if int(option.get("firing_deck_source_model", -1)) == source_model: result.append(option)
	return result

func attack_row(transport: int, target: int, option: Dictionary) -> Dictionary:
	return {"model": transport, "target": target, "amount": 1, "weapon": str(option.weapon), "profile": str(option.profile)}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var impulsor := Profiles.profile("impulsor")
	var rhino := Profiles.profile("rhino")
	var impulsor_deck := FiringDeck.model_limit({"units": {100: {"transport_profile": impulsor.transport}}}, 100)
	var rhino_deck := FiringDeck.model_limit({"units": {100: {"transport_profile": rhino.transport}}}, 100)
	check(impulsor_deck == 7 and rhino_deck == 2, "Impulsor and Rhino retain their extracted Firing Deck 7/2 parameters")
	var state := make_state()
	check(not state.has("error"), "Prepared Marine transport and two passenger units form a live attack fixture: " + str(state.get("error", "")))
	if not state.has("error"):
		var transport := int(state.test_firing_deck_transport)
		var target := int(state.test_firing_deck_target)
		var passengers: Array = state.test_firing_deck_passengers
		var source_one := int(passengers[0])
		var source_two := int(passengers[1])
		var options_one := options_for_model(state, transport, source_one)
		var options_two := options_for_model(state, transport, source_two)
		check(not options_one.is_empty() and not options_two.is_empty(), "The shooting plan exposes embarked models' ranged profiles as transport weapon choices")
		check(options_one.size() == 1 and not str(options_one[0].weapon).contains("test-one-shot"), "Firing Deck excludes One Shot passenger weapons")
		check(options_for_model(state, transport, int(passengers[5])).is_empty(), "Firing Deck excludes models from a passenger unit already selected to shoot this phase")
		var one := options_one[0] if not options_one.is_empty() else {}
		var two := options_two[0] if not options_two.is_empty() else {}
		var valid := [attack_row(transport, target, one), attack_row(transport, target, two)] if not one.is_empty() and not two.is_empty() else []
		var prepared := Combat.AttackPlan.prepare(state, int(state.units[transport].squad), false, valid, true)
		check(valid.size() == 2 and prepared.error.is_empty(), "Rhino accepts two distinct embarked models within Firing Deck 2")
		var source_weapon: Dictionary = state.units[source_one].ranged_weapons[0]
		var profile_names: Array = source_weapon.profiles.keys()
		if not profile_names.is_empty(): source_weapon.profiles["test-alternate-profile"] = source_weapon.profiles[profile_names[0]].duplicate(true)
		var same_model := options_for_model(state, transport, source_one)
		if same_model.size() >= 2:
			var duplicate_source := [attack_row(transport, target, same_model[0]), attack_row(transport, target, same_model[1])]
			check(not Combat.AttackPlan.prepare(state, int(state.units[transport].squad), false, duplicate_source, true).error.is_empty(), "A passenger cannot contribute two weapon profiles to one Firing Deck selection")
		else:
			check(false, "Fixture exposes two profiles on one passenger weapon for the one-profile limit")
		var three_models: Array = []
		for source_model: int in passengers.slice(0, 3):
			var source_options := options_for_model(state, transport, source_model)
			if not source_options.is_empty(): three_models.append(attack_row(transport, target, source_options[0]))
		var over_limit := Combat.AttackPlan.prepare(state, int(state.units[transport].squad), false, three_models, true)
		check(three_models.size() == 3 and over_limit.error.contains("at most 2 passenger models"), "Rhino rejects more selected models than its Firing Deck parameter")
		# Restore the source profile so the live declared plan uses one profile per model.
		source_weapon.profiles.erase("test-alternate-profile")
		var live_options_one := options_for_model(state, transport, source_one)
		var live_options_two := options_for_model(state, transport, source_two)
		var live_entries := [attack_row(transport, target, live_options_one[0]), attack_row(transport, target, live_options_two[0])]
		var resolved := Combat.resolve_attack_plan(state, 1, transport, live_entries, state.revision, false, true, func() -> int: return 1)
		check(resolved.error.is_empty() and state.squads[int(state.units[transport].squad)].shot, "Transport resolves its hull and selected Firing Deck weapons in one attack activation")
		for squad: int in state.squads:
			if passenger_squads_match(state, squad, transport):
				check(Actions.shooting_blocked(state, squad), "Every unit embarked in the transport becomes unable to shoot for the turn")
		check(not state.units[transport].has("firing_deck_active_weapons"), "Temporary passenger weapons leave the transport after its declared attacks resolve")
	print("Marine Firing Deck checks: %d failures" % failures)
	quit(1 if failures else 0)

func passenger_squads_match(state: Dictionary, squad: int, transport: int) -> bool:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("embarked_transport", -1)) == transport: return true
	return false


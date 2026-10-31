extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Scarabs = preload("res://scripts/edition_11/canoptek_scarab_swarms.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const SCARAB_ID := "40kdc:11e:necrons:canoptek-scarab-swarms"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": SCARAB_ID, "models": 3, "copies": 1},
		{"definition_id": SCARAB_ID, "models": 6, "copies": 1}]
	return result

func models_for(state: Dictionary, owner: int, strength: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner: continue
		if C.UnitAbilities.identity(unit) != ("canoptek-scarab-swarms" if owner == 2 else "intercessor-squad"): continue
		if int(state.squads.get(int(unit.get("squad", -1)), {}).get("starting_strength", -1)) == strength: result.append(model)
	result.sort()
	return result

func place(state: Dictionary, models: Array, origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(float(index) * 2.2, 0.0)
		state.units[models[index]].on_battlefield = true
		state.units[models[index]].wounds = int(state.units[models[index]].max_wounds)

func option(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func open_fight(state: Dictionary) -> void:
	state.phase = "fight"
	state.active = 2
	state.turn = 2
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)

func fresh() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.unit_abilities.setup_players = [1, 2]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		C.select_combat_doctrine(state, int(state.active), "none", int(state.revision))
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	return state

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("canoptek-scarab-swarms")
	check(profile.get("source_datasheet_id", "") == "000002114" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Scarab Swarms use the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {3: 40, 6: 80} and not profile.has("third_plus_points_by_models") and profile.get("base_size_source_mm") == 40.0 and int(profile.stats.wounds) == 4 and int(profile.stats.objective_control) == 0, "Scarab Swarms keep both source prices, the 40 mm base, four wounds and OC 0")
	check(profile.supported_rule_ids == ["reanimation-protocols", "self-destruction", "chittering-swarm"] and profile.unsupported_abilities.is_empty(), "Reanimation Protocols, Self-destruction and Chittering Swarm are the local ability scope")
	for size: int in [3, 6]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SCARAB_ID, "models": size, "copies": 1}]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == int(profile.points_by_models[size]), "Scarab Swarm size %d admits at its source price" % size)
	var third := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SCARAB_ID, "models": 3, "copies": 3}]})
	check(str(third.get("error", "")).is_empty() and int(third.get("total", -1)) == 120, "Later Scarab Swarm copies keep the source size price: %s" % str(third))
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SCARAB_ID, "models": 4, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "Unpriced Scarab Swarm sizes stay out of construction")

	var state := fresh()
	if state.has("error"):
		check(false, "Scarab Swarm roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	var small := models_for(state, 2, 3)
	var large := models_for(state, 2, 6)
	var marines := models_for(state, 1, 5)
	check(small.size() == 3 and large.size() == 6 and marines.size() == 5, "Both Scarab Swarm sizes and the Marine squad materialize")
	if small.is_empty() or marines.is_empty():
		quit(1)
		return
	var small_squad := int(state.units[small[0]].squad)
	var large_squad := int(state.units[large[0]].squad)
	var marine_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, small_squad) and Reanimation.supported_unit(state, large_squad), "Both source-sized Scarab Swarm units can activate Reanimation Protocols")
	check(state.units[small[0]].ranged_weapons.is_empty() and str(state.units[small[0]].melee_weapons[0].profiles.standard.name) == "Feeder mandibles", "Scarab Swarms materialize only the local feeder mandibles")

	place(state, small, Vector2(0, 0))
	place(state, large, Vector2(0, 30))
	place(state, marines, Vector2(2, 0))
	state.units[small[1]].position = Vector2(0, 30)
	state.units[small[2]].position = Vector2(2.2, 30)
	open_fight(state)
	var offered := option(state, 2, Scarabs.ACTION, marine_squad, small[0])
	var distant := option(state, 2, Scarabs.ACTION, marine_squad, small[1])
	check(not offered.is_empty() and distant.is_empty(), "Only a Scarab model within Engagement Range can be destroyed")
	var declined := PublicUnitCommand.submit(state, 2, option(state, 2, "pass"))
	check(str(declined.get("error", "")).is_empty() and int(state.units[small[0]].wounds) == 4, "Declining Self-destruction does not destroy a model: %s" % str(declined.get("error", "")))

	open_fight(state)
	var rolls := {"values": [1]}
	var miss := Scarabs.apply(state, 2, option(state, 2, Scarabs.ACTION, marine_squad, small[0]), func() -> int: return int(rolls.values.pop_front()) if not rolls.values.is_empty() else 1)
	check(str(miss.get("error", "")).is_empty() and int(state.units[small[0]].wounds) == 0 and int(state.last_scarab_self_destruction.modified) == 1 and int(state.last_scarab_self_destruction.total) == 0, "An unmodified 1 destroys the Scarab and inflicts no mortal wounds: %s" % str(miss))
	check(option(state, 2, Scarabs.ACTION, marine_squad, small[1]).is_empty(), "The same Scarab unit cannot use Self-destruction again this Fight phase")

	var burst := fresh()
	var burst_scarab: int = models_for(burst, 2, 3)[0]
	var burst_marine_squad := int(burst.units[models_for(burst, 1, 5)[0]].squad)
	place(burst, models_for(burst, 2, 3), Vector2(0, 0))
	place(burst, models_for(burst, 1, 5), Vector2(2, 0))
	open_fight(burst)
	rolls = {"values": [6]}
	var heavy := Scarabs.apply(burst, 2, option(burst, 2, Scarabs.ACTION, burst_marine_squad, burst_scarab), func() -> int: return int(rolls.values.pop_front()) if not rolls.values.is_empty() else 1)
	check(str(heavy.get("error", "")).is_empty() and int(burst.last_scarab_self_destruction.total) == 3 and str(burst.unit_abilities.window.kind) == Scarabs.MORTAL_WINDOW, "A 6+ inflicts 3 mortal wounds through the defender allocation window: %s" % str(heavy))

	var vehicle := fresh()
	var vehicle_scarab: int = models_for(vehicle, 2, 3)[0]
	var vehicle_marines := models_for(vehicle, 1, 5)
	place(vehicle, models_for(vehicle, 2, 3), Vector2(0, 0))
	place(vehicle, vehicle_marines, Vector2(2, 0))
	for marine: int in vehicle_marines: vehicle.units[marine].keywords.append("VEHICLE")
	open_fight(vehicle)
	rolls = {"values": [1, 1]}
	var vehicle_result := Scarabs.apply(vehicle, 2, option(vehicle, 2, Scarabs.ACTION, int(vehicle.units[vehicle_marines[0]].squad), vehicle_scarab), func() -> int: return int(rolls.values.pop_front()) if not rolls.values.is_empty() else 1)
	check(str(vehicle_result.get("error", "")).is_empty() and bool(vehicle.last_scarab_self_destruction.vehicle) and int(vehicle.last_scarab_self_destruction.modified) == 2 and int(vehicle.last_scarab_self_destruction.total) == 1, "A VEHICLE target adds 1 to the D6, so a 1 becomes a D3 mortal wound: %s" % str(vehicle_result))

	var control := fresh()
	var control_small := models_for(control, 2, 3)
	var control_large := models_for(control, 2, 6)
	var control_marines := models_for(control, 1, 5)
	place(control, control_small, Vector2(0, 0))
	place(control, control_large, Vector2(0, 40))
	place(control, control_marines, Vector2(2, 0))
	var marine_model := control_marines[0]
	var printed := int(control.units[marine_model].get("objective_control", control.squads[int(control.units[marine_model].squad)].stats.objective_control))
	check(Morale.objective_control(control, marine_model) == maxi(1, printed - 1), "One engaged Scarab unit subtracts 1 Objective Control, to a minimum of 1")
	place(control, [control_large[0]], Vector2(2.2, 0))
	check(Morale.objective_control(control, marine_model) == 1, "A second engaged Scarab unit also subtracts 1 and still stops at 1")
	place(control, control_large, Vector2(0, 40))
	place(control, control_marines, Vector2(30, 0))
	check(Morale.objective_control(control, marine_model) == printed, "Chittering Swarm ends when the enemy leaves Engagement Range")
	check(Morale.objective_control(control, control_small[0]) == 0, "Scarab Swarms keep OC 0 without a friendly Cryptek")
	var cryptek: Dictionary = control.units[marine_model].duplicate(true)
	cryptek.owner = 2
	cryptek.squad = 90
	cryptek.wounds = 4
	cryptek.max_wounds = 4
	cryptek.on_battlefield = true
	cryptek.keywords = ["NECRONS", "INFANTRY", "CHARACTER", "CRYPTEK"]
	cryptek.position = Vector2(4, 0)
	control.units[9000] = cryptek
	control.squads[90] = control.squads[int(control.units[marine_model].squad)].duplicate(true)
	control.squads[90].owner = 2
	control.squads[90].starting_strength = 1
	check(Morale.objective_control(control, control_small[0]) == 1 and Actions.eligibility_error(control, int(control.units[control_small[0]].squad)).is_empty(), "A friendly Cryptek within 6 inches sets Scarab Objective Control to 1")
	cryptek.position = Vector2(20, 0)
	control.units[9000] = cryptek
	check(Morale.objective_control(control, control_small[0]) == 0, "A Cryptek more than 6 inches away does not change Scarab Objective Control")

	if failures == 0: print("Necron Scarab Swarms local checks: passed")
	else: print("Necron Scarab Swarms local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

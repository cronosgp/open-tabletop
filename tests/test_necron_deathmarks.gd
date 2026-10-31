extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Hyperspace = preload("res://scripts/edition_11/hyperspace_hunters.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const PhaseClose = preload("res://scripts/edition_11/phase_close_gate.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const DEATHMARK_ID := "40kdc:11e:necrons:deathmarks"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": MARINE_ID, "models": 5, "copies": 1},
		{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": DEATHMARK_ID, "models": 5, "copies": 1},
		{"definition_id": DEATHMARK_ID, "models": 10, "copies": 1}]
	return result

func models_for(state: Dictionary, owner: int, strength: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != ("deathmarks" if owner == 2 else "intercessor-squad"): continue
		if int(state.squads.get(int(unit.get("squad", -1)), {}).get("starting_strength", -1)) == strength: result.append(model)
	result.sort()
	return result

func place(state: Dictionary, models: Array, origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(index * 1.2, 0)
		state.units[models[index]].on_battlefield = true
		state.units[models[index]].wounds = int(state.units[models[index]].max_wounds)

func prepare(state: Dictionary) -> void:
	state.unit_abilities.setup_players = [1]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		check(C.select_combat_doctrine(state, int(state.active), "none", int(state.revision)).is_empty(), "Clear the unrelated doctrine choice")
	state.phase = "movement"
	state.active = 1
	state.turn = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("deathmarks")
	check(profile.get("source_datasheet_id", "") == "000000537" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Deathmarks use the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {5: 60, 10: 120} and profile.get("third_plus_points_by_models", {}) == {5: 70, 10: 130}, "Deathmarks keep both sizes and the third-plus prices")
	check(profile.supported_rule_ids == ["deep-strike", "reanimation-protocols", "hyperspace-hunters"] and profile.unsupported_abilities.is_empty(), "Deep Strike, Reanimation Protocols and Hyperspace Hunters are the local ability scope")
	for size: int in [5, 10]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DEATHMARK_ID, "models": size, "copies": 1}]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == int(profile.points_by_models[size]), "Deathmarks size %d admits at its first-copy price" % size)
	var third := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DEATHMARK_ID, "models": 5, "copies": 3}]})
	check(str(third.get("error", "")).is_empty() and int(third.get("total", -1)) == 190, "The third five-model Deathmarks unit uses the 70-point copy price: %s" % str(third))
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DEATHMARK_ID, "models": 4, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "Unpriced Deathmarks sizes stay out of construction")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Deathmarks roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	prepare(state)
	var small := models_for(state, 2, 5)
	var large := models_for(state, 2, 10)
	var marines := models_for(state, 1, 5)
	check(small.size() == 5 and large.size() == 10 and marines.size() == 10, "Both Deathmarks sizes and the two Marine squads materialize: %d/%d/%d" % [small.size(), large.size(), marines.size()])
	if small.is_empty() or marines.size() < 10:
		quit(1)
		return
	var small_squad := int(state.units[small[0]].squad)
	var other_marine_squad := int(state.units[marines[5]].squad)
	var arrived_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, small_squad) and Reanimation.supported_unit(state, int(state.units[large[0]].squad)), "Both source-sized Deathmarks units can activate Reanimation Protocols")
	check(str(state.units[small[0]].ranged_weapons[0].profiles.standard.name) == "Synaptic disintegrator", "Deathmarks materialize the local synaptic disintegrator")

	place(state, small, Vector2(-8, 0))
	place(state, large, Vector2(-8, 40))
	place(state, marines.slice(0, 5), Vector2(8, 0))
	place(state, marines.slice(5, 10), Vector2(40, 0))
	state.squads[arrived_squad].move_type = "ingress"
	state.squads[arrived_squad].set_up_this_turn = true
	check(Hyperspace.offer(state, arrived_squad), "An enemy Reserves arrival within 18 inches opens Hyperspace Hunters")
	check(str(state.unit_abilities.window.get("kind", "")) == Hyperspace.KIND and int(state.unit_abilities.window.owners[0]) == 2, "The Deathmarks player owns the arrival reaction")
	var shoot_choices: Array = Hyperspace.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "shoot")
	check(shoot_choices.size() == 1 and int(shoot_choices[0].target) == small_squad, "Only the Deathmarks unit within 18 inches and line of sight is offered")
	check(not PhaseClose.close_request_error(state, 1, int(state.revision)).is_empty(), "The Movement phase waits for the Hyperspace Hunters choice")
	var declined := PublicUnitCommand.submit(state, 2, Hyperspace.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "pass")[0])
	check(str(declined.get("error", "")).is_empty() and state.unit_abilities.window.is_empty() and not state.unit_abilities.get("used", {}).has("hyperspace-hunters:%d" % small_squad), "Declining this arrival does not spend the once-per-turn shot: %s" % str(declined.get("error", "")))
	check(Hyperspace.offer(state, arrived_squad), "A later arrival in the same turn can still trigger the unused ability")
	var selected := PublicUnitCommand.submit(state, 2, Hyperspace.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "shoot")[0])
	check(str(selected.get("error", "")).is_empty() and Hyperspace.active_shooter(state, small_squad), "Selecting the shot restricts the attack to the arrived unit: %s" % str(selected.get("error", "")))
	var weapon_id := str(state.units[small[0]].ranged_weapons[0].get("id", ""))
	check(arrived_squad in AttackPlan.legal_targets(state, small[0], false, weapon_id, "standard") and other_marine_squad not in AttackPlan.legal_targets(state, small[0], false, weapon_id, "standard"), "The shot can target only the unit that arrived from Reserves")
	scripted_dice = [6, 6, 1]
	var attack := C.resolve_attack_plan(state, 2, small[0], [{"model": small[0], "target": arrived_squad, "amount": 1, "weapon": weapon_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(attack.get("error", "")).is_empty(), "The out-of-phase shot resolves through the normal shooting attack path: %s" % str(attack.get("error", "")))
	check(bool(state.squads[small_squad].shot) and int(state.unit_abilities.get("used", {}).get("hyperspace-hunters:%d" % small_squad, -1)) == int(state.turn) and state.unit_abilities.get("window", {}).is_empty(), "A completed Hyperspace Hunters shot is spent for the turn and returns control: shot=%s used=%s window=%s attack=%s" % [str(state.squads[small_squad].shot), str(state.unit_abilities.get("used", {})), str(state.unit_abilities.get("window", {})), str(attack)])
	check(not Hyperspace.offer(state, arrived_squad), "The same Deathmarks unit cannot shoot with Hyperspace Hunters again this turn")

	state.unit_abilities.used.erase("hyperspace-hunters:%d" % small_squad)
	state.squads[small_squad].shot = false
	state.phase = "command"
	check(not Hyperspace.offer(state, arrived_squad), "Hyperspace Hunters waits for the opponent's Movement phase")
	state.phase = "movement"
	state.active = 2
	check(not Hyperspace.offer(state, arrived_squad), "Deathmarks do not react to an arrival during their own Movement phase")
	state.active = 1
	state.squads[arrived_squad].owner = 2
	check(not Hyperspace.offer(state, arrived_squad), "A friendly unit arriving during the opponent's Movement phase is not an enemy Reserves target")
	state.squads[arrived_squad].owner = 1
	for model: int in marines.slice(0, 5): state.units[model].position = Vector2(40, 0)
	check(not Hyperspace.offer(state, arrived_squad), "An arrival more than 18 inches away does not open the reaction")
	for model: int in marines.slice(0, 5): state.units[model].position = Vector2(8, 0)
	state.terrain = {"id": "legacy-solid-v1", "areas": [{"bounds": Rect2(0, -2, 2, 4), "category": "dense", "features": []}]}
	check(not Hyperspace.offer(state, arrived_squad), "An arrival that is not visible does not open the reaction")

	if failures == 0: print("Necron Deathmarks local checks: passed")
	else: print("Necron Deathmarks local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

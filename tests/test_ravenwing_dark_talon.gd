extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const StasisBomb = preload("res://scripts/edition_11/stasis_bomb.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "ravenwing-dark-talon"
const UNIT_ID := "40kdc:11e:adeptus-astartes:ravenwing-dark-talon"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0
var dice: Array[int] = []

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
	return result

func prepared() -> Dictionary:
	var options := {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS"}
	}
	var state: Dictionary = F.P.initial_state(options, selection())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squads(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in models(state, identity, owner):
		var squad := int(state.units[model].squad)
		if squad not in result: result.append(squad)
	return result

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000240", "The profile identifies Ravenwing Dark Talon in the Dark Angels App")
	check(profile.get("points_by_models", {}) == {1: 190} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The source composition, price and local copy cap are recorded")
	check(profile.get("base_size_source_mm", []) == [120, 92] and profile.get("base_geometry", "") == "oval" and str(profile.get("geometry_scope", "")).contains("60 mm bounding-circle proxy"), "The oval source base and labelled proxy footprint are preserved")
	check(profile.get("stats", {}) == {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 5}, "The fixed Aircraft characteristics match the local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "VEHICLE", "AIRCRAFT", "RAVENWING", "FLY", "IMPERIUM"], "All seven datasheet keywords are represented")
	var weapons: Array = profile.get("ranged", [])
	check(weapons.size() == 3 and weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "rift-cannon" and row.profiles.standard == {"name": "Rift Cannon", "range_inches": 18.0, "attacks": "D3+1", "skill": 3, "strength": 16, "ap": -4, "damage": 3, "keywords": {"devastating-wounds": true, "blast": 1}}), "Rift Cannon retains its random Attacks, Devastating Wounds and Blast profile")
	var hurricane_bolters: Array[Dictionary] = []
	for row: Dictionary in weapons:
		if str(row.get("id", "")).begins_with("hurricane-bolter-"): hurricane_bolters.append(row)
	check(hurricane_bolters.size() == 2 and hurricane_bolters[0].profiles.standard == hurricane_bolters[1].profiles.standard and int(hurricane_bolters[0].profiles.standard.attacks) == 6, "The two physical Hurricane Bolters each retain their own six-shot profile")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the export")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "Admission status matches the scoped local checks")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 190}], "The consolidated local catalog exposes the 190-point choice")

	var state := prepared()
	check(not state.has("error"), "The admitted Dark Talon materializes in a current-catalog match: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Ravenwing Dark Talon checks: %d failures" % (failures + 1))
		quit(1)
		return
	var aircraft_models := models(state, UNIT, 1)
	var enemy_squads := squads(state, "intercessor-squad", 2)
	check(aircraft_models.size() == 1 and not enemy_squads.is_empty(), "The match includes the Dark Talon and an enemy Intercessor unit")
	if aircraft_models.is_empty() or enemy_squads.is_empty():
		print("Ravenwing Dark Talon checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = aircraft_models[0]
	var squad := int(state.units[model].squad)
	var target_squad: int = enemy_squads[0]
	var target_models: Array[int] = C.living(state, target_squad)
	var target_model: int = target_models[0]
	check(A.has(state, squad, "damaged-3") and A.has(state, squad, "deadly-demise-d3") and A.deadly_demise_value(state, model) == "D3" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "stasis-bomb"), "Damaged 3, Deadly Demise D3, Combat Doctrines and Stasis Bomb are registered")
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 3 does not penalize the full-health Dark Talon")
	state.units[model].wounds = 3
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 3 penalizes attacks at three remaining wounds")
	state.units[model].wounds = 11

	state.board_size = Vector2(80.0, 24.0)
	for other: int in state.units:
		if int(state.units[other].owner) == 1: state.units[other].position = Vector2(-14.0, 8.0)
		else: state.units[other].position = Vector2(14.0, -8.0)
	state.units[model].position = Vector2(0.0, 8.0)
	for other: int in target_models: state.units[other].position = Vector2(10.0, 8.0)
	check(StasisBomb.can_target(state, model, target_squad), "Stasis Bomb can select a visible enemy within 24 inches")
	var original_keywords: Array = state.units[target_model].keywords.duplicate()
	state.units[target_model].keywords.append("LONE OPERATIVE")
	check(not StasisBomb.can_target(state, model, target_squad), "Stasis Bomb excludes Lone Operative units")
	state.units[target_model].keywords = original_keywords
	state.units[target_model].keywords.append("AIRCRAFT")
	check(not StasisBomb.can_target(state, model, target_squad), "Stasis Bomb excludes AIRCRAFT units")
	state.units[target_model].keywords = original_keywords
	for other: int in target_models: state.units[other].position = Vector2(30.0, 8.0)
	check(not StasisBomb.can_target(state, model, target_squad), "Stasis Bomb cannot select a unit beyond 24 inches")
	for other: int in target_models: state.units[other].position = Vector2(10.0, 8.0)

	state.phase = "fight"
	state.active = 2
	state.turn = 10
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	check(U.open_end(state) and StasisBomb.available(state, 1), "The opponent's Fight-phase end window offers Stasis Bomb to its owner")
	var unit_choices := U.choices(state, 1)
	var bomb_choice: Dictionary = {}
	for option: Dictionary in unit_choices:
		if option.get("action", "") == "stasis-bomb":
			bomb_choice = option
			break
	check(not bomb_choice.is_empty() and int(bomb_choice.get("model", -1)) == model, "UnitActions exposes the source-checked Stasis Bomb choice")
	if not bomb_choice.is_empty():
		target_squad = int(bomb_choice.get("target", -1))
		target_models = C.living(state, target_squad)
		if not target_models.is_empty(): target_model = target_models[0]
		for target_unit: int in target_models: state.units[target_unit].position = Vector2(10.0, 8.0)
	var bomb_result := PublicUnitCommand.submit(state, 1, bomb_choice)
	var bomb_error := str(bomb_result.get("error", ""))
	var marks: Dictionary = state.unit_abilities.get("stasis_bomb_marks", {})
	var mark: Dictionary = marks.get(target_squad, {})
	check(not bomb_choice.is_empty() and bomb_error.is_empty() and mark.get("owner", -1) == 2 and mark.get("expires_turn", -1) == 12, "The target is marked through the end of its next Movement phase: choice=%s error=%s window=%s" % [str(bomb_choice), bomb_error, str(state.unit_abilities.get("window", {}))])
	check(state.unit_abilities.used.has("stasis-bomb:10:%d" % squad), "The Dark Talon cannot use Stasis Bomb twice in the same turn")

	state.phase = "movement"
	state.active = 2
	state.turn = 12
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = U.key(state)
	state.unit_abilities.end_done = ""
	state.resolution_frames = []
	state.pending_move = {}
	state.squads[target_squad].moved = false
	state.units[target_model].moved = false
	dice = [3, 2]
	var movement_error := C.begin_movement(state, 2, target_model, "normal", state.revision, Callable(self, "roll_die"))
	check(movement_error.is_empty() and state.unit_abilities.window.get("kind", "") == StasisBomb.MORTAL_WINDOW, "Selecting the target to move suspends movement for Stasis mortal-wound allocation: error=%s window=%s marks=%s" % [movement_error, str(state.unit_abilities.get("window", {})), str(state.unit_abilities.get("stasis_bomb_marks", {}))])
	var stasis_record: Dictionary = state.get("last_stasis_bomb", {})
	check(stasis_record.get("rolls", []) == [3, 2] and stasis_record.get("remaining", -1) == 1 and stasis_record.get("penalty", -1) == 2, "A 1–4 result applies D3 mortals and -2 inches to M")
	check(C.movement_remaining(state, target_model) == 4.0, "The Stasis M penalty is included in the unit's movement allowance")
	var allocation_choice: Dictionary = {}
	for option: Dictionary in U.choices(state, 2):
		if option.get("action", "") == "mortal-allocate" and option.get("value", "") == StasisBomb.MORTAL_WINDOW:
			allocation_choice = option
			break
	var allocate_error := str(PublicUnitCommand.submit(state, 2, allocation_choice, Vector2.ZERO, Callable(self, "roll_die")).get("error", ""))
	check(not allocation_choice.is_empty() and allocate_error.is_empty() and state.unit_abilities.window.get("kind", "") == StasisBomb.RESUME_WINDOW, "Shared mortal allocation resolves before the saved move resumes")
	var resume_choice: Dictionary = {}
	for option: Dictionary in U.choices(state, 2):
		if option.get("action", "") == "stasis-movement-resume":
			resume_choice = option
			break
	var resume_error := C.unit_action(state, 2, resume_choice, Vector2.ZERO, state.revision, Callable(self, "roll_die"))
	check(not resume_choice.is_empty() and resume_error.is_empty() and not state.pending_move.is_empty(), "The saved Normal Move resumes after mortal allocation: choice=%s error=%s pending=%s" % [str(resume_choice), resume_error, str(state.pending_move)])
	check(C.movement_remaining(state, target_model) == 4.0, "The movement penalty remains active after the continuation resumes")

	var high_state: Dictionary = state.duplicate(true)
	high_state.pending_move = {}
	high_state.unit_abilities.window = {}
	high_state.unit_abilities.used.erase("stasis-bomb-movement:12:%d" % target_squad)
	dice = [6, 6, 2]
	var high_result := StasisBomb.resolve_movement(high_state, 2, target_squad, target_model, "normal", Callable(self, "roll_die"), {})
	check(high_result.get("record", {}).get("rolls", []) == [6, 6, 2] and high_result.record.get("remaining", -1) == 4 and high_result.record.get("penalty", -1) == 3, "A 5–6 result applies 2D3 mortals and -3 inches to M")
	var stationary := StasisBomb.resolve_movement(high_state, 2, target_squad, target_model, "stationary", Callable(self, "roll_die"), {})
	check(not stationary.get("pending", false), "Remaining stationary avoids the Stasis Bomb movement roll")
	state.pending_move = {}
	StasisBomb.end_movement_phase(state)
	check(not state.unit_abilities.stasis_bomb_marks.has(target_squad) and not state.unit_abilities.stasis_bomb_penalties.has(target_squad), "Stasis Bomb's mark and M penalty expire at the end of the affected Movement phase")

	if failures == 0:
		print("Ravenwing Dark Talon checks passed")
	else:
		print("Ravenwing Dark Talon checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

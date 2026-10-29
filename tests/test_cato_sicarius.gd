extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func action(state: Dictionary, player: int, action_id: String, target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (target < 0 or option.target == target): return option
	return {}

func submit_choice(state: Dictionary, player: int, action_id: String, target: int, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target:
			projected = option
			break
	if projected.is_empty(): return {"error": "The normalized decision does not offer %s for target %d." % [action_id, target]}
	var choice := action(state, player, action_id, target)
	if choice.is_empty(): return {"error": "UnitActions no longer offers the projected Cato choice."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}})

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func make_state() -> Dictionary:
	var lists := F.current_marine_selections()
	lists[1].entries.append(entry("cato-sicarius"))
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.mission.stage = "battle"
	return state

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("cato-sicarius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004184" and profile.points == 115 and profile.base_size_source_mm == 40, "Cato profile identifies the shared-book source, points and base")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "Cato has no equipment-option rows in the current source export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Cato characteristics match the local Wahapedia export")
	check(profile.ranged[0].profiles.standard.name == "Artisan Plasma Pistol" and profile.ranged[0].profiles.standard.strength == 8 and profile.melee.size() == 3, "Cato's plasma pistol and all three Tempest Blade profiles are represented")
	check(profile.melee[0].profiles.standard.keywords == {"devastating-wounds": true} and profile.melee[1].profiles.standard.keywords == {"precision": true} and profile.melee[2].profiles.standard.keywords == {"sustained-hits": 1}, "Tempest Blade profiles retain source attack traits")
	check(Catalog.SPECS.get("cato-sicarius", {}).get("current_reference", false) and Roster.POINTS.get("cato-sicarius", {}).get("sizes", {}) == {1: 115}, "Cato is admitted to the current catalog at the source cost")
	var state := make_state()
	check(not state.has("error"), "Cato and both current Marine rosters materialize from the consolidated catalog")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var cato_squad := find_squad(state, 1, "cato-sicarius")
	var cato := Geometry.alive(state, cato_squad)[0]
	var cato_start: Vector2 = state.units[cato].position
	var enemy := find_squad(state, 2, "intercessor-squad")
	var enemy_model := Geometry.alive(state, enemy)[0]
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, cato, enemy):
		check(false, "Cato fixed weapon plan: " + failure)
	check(Abilities.has(state, cato_squad, "leader") and Abilities.has(state, cato_squad, "knight-champion-of-macragge") and Abilities.has(state, cato_squad, "honour-or-death"), "Cato's Leader and datasheet abilities register")
	check(Abilities.has(state, cato_squad, "combat-doctrines") and Abilities.has(state, cato_squad, "transhuman-strategist"), "Cato receives both exported army rules")
	var warlord_state: Dictionary = state.duplicate(true)
	warlord_state.phase = "deployment"
	var cato_warlord: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(warlord_state, 1):
		if option.action == "warlord" and int(option.model) == cato: cato_warlord = option
	check(not cato_warlord.is_empty(), "Cato can be selected as the army's Warlord")
	if not cato_warlord.is_empty():
		var cp_before := int(warlord_state.cp[1])
		var warlord_result := C.UnitActions.apply(warlord_state, 1, cato_warlord, Vector2.ZERO, func() -> int: return 1)
		warlord_state.active = int(warlord_state.get("first_player", 1))
		warlord_state.round = 1
		C.UnitActions.start_round(warlord_state)
		C.UnitActions.start_round(warlord_state)
		check(warlord_result.get("error", "").is_empty() and warlord_state.cp[1] == cp_before + 1, "Transhuman Strategist grants Cato's Warlord CP once per battle round")
	check(not C.UnitActions.attachment_allowed(state, cato, cato_squad), "Cato cannot attach to his own unit")
	check(CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.HEROIC) == 0 and CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.FRAY) == 1 and CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.OVERWATCH) == 1, "Honour or Death discounts Heroic Intervention only and preserves the additional Into the Fray cost")
	var enemy_models := Geometry.alive(state, enemy)
	for index in range(enemy_models.size()):
		state.units[enemy_models[index]].position = cato_start + Vector2(8.5, -2.4 + float(index) * 1.2)
	state.phase = "movement"
	state.active = 2
	state.turn = 1
	state.squads[enemy].moved = false
	var moved_model := enemy_models[0]
	var movement_error := C.move(state, 2, moved_model, state.units[moved_model].position + Vector2(-1, 0), state.revision)
	var finish_error := movement_error if not movement_error.is_empty() else C.finish_movement(state, 2, state.revision, false)
	check(finish_error.is_empty() and state.unit_abilities.window.get("kind", "") == "knight-champion-of-macragge", "Enemy move ending within 8 inches opens Cato's reaction")
	var movement_frame := ResolutionFrames.current(state)
	var movement_decision := C.UnitActions.pending_decision(state)
	check(movement_frame.get("kind", "") == "unit-action" and movement_frame.get("status", "") == "suspended" and movement_frame.get("action_id", "") == "movement:%d:%d:movement" % [state.turn, enemy], "Post-move Cato reaction suspends the completed Movement frame")
	check(movement_decision.get("action_id", "") == movement_frame.get("action_id", "") and movement_decision.get("resume_frame_id", "") == movement_frame.get("frame_id", ""), "Cato decision identifies the movement continuation")
	state = bytes_to_var(var_to_bytes(state))
	movement_frame = ResolutionFrames.current(state)
	movement_decision = C.UnitActions.pending_decision(state)
	check(movement_decision.get("resume_frame_id", "") == movement_frame.get("frame_id", "") and movement_frame.get("status", "") == "suspended", "Post-move reaction and movement frame survive serialization")
	var before_close := var_to_bytes(state)
	check(not C.advance_phase(state, 2, state.revision).is_empty() and before_close == var_to_bytes(state), "Phase close cannot skip the pending post-move reaction")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner_choice := submit_choice(state, 2, "cato-knight-use", cato_squad)
	check(not str(wrong_owner_choice.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot submit or mutate Cato's movement reaction")
	var use := action(state, 1, "cato-knight-use", cato_squad)
	check(not use.is_empty(), "Cato receives an optional 6-inch Normal Move choice")
	if not use.is_empty():
		var result := submit_choice(state, 1, "cato-knight-use", cato_squad)
		check(str(result.get("error", "")).is_empty(), "Cato can choose the reaction move through the normalized command")
		movement_frame = ResolutionFrames.current(state)
		check(movement_frame.get("status", "") == "suspended" and movement_frame.get("action_id", "") == "movement:%d:%d:movement" % [state.turn, enemy], "Cato's placement step retains the same completed-move continuation")
		var place := action(state, 1, "cato-knight-place", cato_squad)
		check(not place.is_empty(), "The reaction offers model placement")
		if not place.is_empty():
			var destination := cato_start + Vector2(1, 0)
			var placement_result := submit_choice(state, 1, "cato-knight-place", cato_squad, destination)
			check(str(placement_result.get("error", "")).is_empty(), "Cato can preview a legal position within 6 inches")
			var confirm := action(state, 1, "cato-knight-confirm", cato_squad)
			var confirm_result := submit_choice(state, 1, "cato-knight-confirm", cato_squad)
			check(not confirm.is_empty() and str(confirm_result.get("error", "")).is_empty(), "The confirmed reaction is a Normal Move and consumes the per-army use")
			check(state.units[cato].position.distance_to(cato_start) <= 6.001 and state.squads[cato_squad].move_type == "normal" and state.unit_abilities.used.has("cato-knight-champion:1:1"), "Cato's movement state and once-per-phase record are persisted")
			check(state.unit_abilities.window.is_empty() and ResolutionFrames.current(state).is_empty(), "Knight Champion cannot reopen and the movement continuation completes after the reaction")
	check(CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.HEROIC) == (1 if state.units[cato].wounds <= 0 else 0), "Honour or Death remains sourced by the living Cato model")
	print("Cato Sicarius profile and rule checks: %d failures" % failures)
	quit(1 if failures else 0)

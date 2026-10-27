extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const F = preload("res://tests/all_units_fixture.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:invictor-tactical-warsuit", "models": 1, "copies": copies}]}

func first_model(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and state.units[model].wounds > 0 and Abilities.identity(state.units[model]) == identity: return model
	return -1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func submit_choice(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Invictor choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("invictor-tactical-warsuit")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001156" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Invictor identity matches the selected local Space Marines export")
	check(profile.points_by_models == {1: 135} and profile.third_plus_points_by_models == {1: 150} and profile.max_supported_copies == 3, "Invictor first/second and third-plus copy costs and limit match export")
	check(profile.stats == {"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.damaged_threshold == 4 and profile.base_radius_inches == 45.0 / 25.4, "Invictor characteristics, Damaged 4 and 90mm base match export")
	check(profile.ranged.size() == 4 and profile.ranged[0].id == "fragstorm-grenade-launcher" and profile.ranged[1].id == "heavy-bolter" and profile.ranged[2].id == "incendium-cannon" and profile.ranged[3].id == "ironhail-heavy-stubbers" and profile.melee[0].id == "invictor-fist", "Invictor default weapons match the local sheet")
	check(profile.ranged[0].profiles.standard.keywords == {"blast": 1} and profile.ranged[1].profiles.standard.keywords == {"sustained-hits": 1, "rapid-fire": 2} and profile.ranged[2].profiles.standard.skill == 0 and profile.ranged[2].profiles.standard.keywords == {"torrent": true, "blast": 2} and profile.ranged[3].profiles.standard.keywords == {"rapid-fire": 6}, "Invictor default weapon traits and automatic hit profile match export")
	var autocannon := Profiles.invictor_weapons(true)
	check(autocannon.size() == 4 and autocannon[2].id == "twin-ironhail-autocannon" and autocannon[2].profiles.standard.keywords == {"twin-linked": true}, "Optional Twin Ironhail Autocannon replaces the Incendium Cannon")
	check(Army.SPECS["invictor-tactical-warsuit"].current_reference and Army.SPECS["invictor-tactical-warsuit"].max_supported_copies == 3, "Invictor admission remains tied to this current profile and copy limit")
	var admitted := Army.admit(selection())
	var three := Army.admit(selection(3))
	var four := Army.admit(selection(4))
	check(admitted.error.is_empty() and admitted.total == 135 and three.error.is_empty() and three.total == 420 and not four.error.is_empty(), "Local construction uses source costs and rejects a fourth Invictor: %s / %d; %s / %d; %s" % [admitted.get("error", ""), admitted.get("total", -1), three.get("error", ""), three.get("total", -1), four.get("error", "")])

	var selections := F.selections()
	for index in range(selections[1].entries.size() - 1, -1, -1):
		var entry: Dictionary = selections[1].entries[index]
		if entry.definition_id.ends_with(":terminator-squad"):
			selections[1].entries.remove_at(index)
		elif entry.definition_id.ends_with(":assault-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:invictor-tactical-warsuit"
			entry.models = 1
		elif entry.definition_id.ends_with(":heavy-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
			entry.models = 1
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections)
	check(not state.has("error"), "Invictor and vehicle reference profiles materialize from the local catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var invictor := first_model(state, "invictor-tactical-warsuit", 1)
		var warriors := first_model(state, "necron-warriors", 2)
		var immortals := first_model(state, "immortals", 2)
		check(invictor >= 0 and warriors >= 0 and immortals >= 0, "Battle includes Invictor and two enemy units for mark transitions")
		if invictor >= 0 and warriors >= 0 and immortals >= 0:
			var inv_squad: int = state.units[invictor].squad
			var warrior_squad: int = state.units[warriors].squad
			var immortal_squad: int = state.units[immortals].squad
			state.awakened_dynasty.pending = []
			var reserve_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "reserve" and option.target == inv_squad: reserve_choice = option
			check(not reserve_choice.is_empty(), "The Invictor's Scouts 8 ability makes it eligible for Strategic Reserves set-up")
			var equipment: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-gun" and option.model == invictor and option.value == "autocannon": equipment = option
			check(not equipment.is_empty(), "Deployment exposes the Invictor autocannon replacement")
			if not equipment.is_empty():
				var equipment_error := PublicUnitCommand.error(state, 1, equipment)
				check(equipment_error.is_empty() and state.units[invictor].ranged_weapons[2].id == "twin-ironhail-autocannon", "Selecting the optional autocannon changes the equipped weapon")
			check(Abilities.scout_distance(state, inv_squad) == 8, "The exported Scouts 8-inch ability is registered for this Invictor")
			state.phase = "start_turn"
			state.turn = 1
			state.round = 1
			state.active = 1
			state.first_player = 1
			state.unit_abilities.battle_players = []
			check(UnitActions.battle_actor(state) == 1, "The Invictor owner receives the first-battle-round Forward Assault declaration")
			var mark_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-mark" and option.model == invictor and option.target == warrior_squad: mark_choice = option
			check(not mark_choice.is_empty(), "Start-of-round choices offer enemy units as the Invictor mark")
			if not mark_choice.is_empty():
				var mark_result := submit_choice(state, 1, mark_choice)
				check(str(mark_result.get("error", "")).is_empty() and Abilities.forward_assault_mark(state, inv_squad) == warrior_squad, "Forward Assault stores the selected enemy mark through the normalized command")
			state.units[invictor].position = Vector2(6, 0)
			state.units[warriors].position = Vector2(12, 0)
			state.units[immortals].position = Vector2(13, 0)
			var scout_probe := state.duplicate(true)
			scout_probe.terrain = {"id": "terrain-11e-v1", "areas": []}
			scout_probe.unit_abilities.window = {"kind": "scouts", "squad": inv_squad, "reserved": false, "setup": false,
				"origins": {invictor: Vector2(6, 0)}, "positions": {invictor: Vector2(6, 0)}}
			var scout_eight_error := ScoutMoves.position_error(scout_probe, invictor, Vector2(-2, 0))
			check(scout_eight_error.is_empty(), "Scout movement accepts the Invictor's full 8-inch move: %s" % scout_eight_error)
			check(ScoutMoves.position_error(scout_probe, invictor, Vector2(-2.01, 0)).contains("more than its Scouts distance"), "Scout movement rejects movement beyond the Invictor's 8-inch allowance")
			var marked_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			var unmarked_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": immortal_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			check(marked_plan.error.is_empty() and marked_plan.batches[0].context.get("wound_reroll", "") == "ones", "Invictor attacks against its current mark re-roll Wound rolls of 1")
			check(unmarked_plan.error.is_empty() and unmarked_plan.batches[0].context.get("wound_reroll", "none") == "none", "Forward Assault does not grant re-rolls against an unmarked unit")
			for target_model: int in state.units:
				if state.units[target_model].squad == warrior_squad and target_model != warriors: state.units[target_model].wounds = 0
			state.units[warriors].wounds = 1
			state.phase = "shooting"
			state.active = 1
			state.squads[inv_squad].shot = false
			dice = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 1, 1, 1, 1, 1]
			var attack := F.C.resolve_attack_plan(state, 1, invictor, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], state.revision, false, false, roll_die)
			var allocation_error := F.C.allocate_damage(state, 2, warriors, state.revision, roll_die)
			check(attack.get("error", "").is_empty() and allocation_error.is_empty() and state.units[warriors].wounds == 0 and state.unit_abilities.window.get("kind", "") == "forward-assault-mark", "Destroying the marked enemy through a resolved attack opens the replacement choice: attack=%s allocation=%s" % [attack.get("error", ""), allocation_error])
			var post_attack_frame := ResolutionFrames.current(state)
			var post_attack_decision := UnitActions.pending_decision(state)
			check(post_attack_frame.get("kind", "") == "attack" and post_attack_frame.get("status", "") == "suspended" and post_attack_frame.get("resume_point", "") == "attack-mark-replacement", "Invictor mark replacement suspends the in-progress attack frame")
			check(post_attack_decision.get("resume_frame_id", "") == post_attack_frame.get("frame_id", ""), "Invictor replacement decision retains the attack frame identity")
			check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "Shooting close remains blocked while Forward Assault needs a replacement mark")
			var replacement: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-mark" and option.model == invictor and option.target == immortal_squad: replacement = option
			check(not replacement.is_empty(), "Destroyed mark can be replaced by another living enemy: window=%s choices=%s" % [str(state.unit_abilities.window), str(UnitActions.choices(state, 1))])
			if not replacement.is_empty():
				var before_wrong_owner := var_to_bytes(state)
				var wrong_owner_result := submit_choice(state, 2, replacement)
				check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The defender cannot submit or mutate the Invictor replacement decision")
				var saved_frame_id: String = str(post_attack_frame.get("frame_id", ""))
				state = bytes_to_var(var_to_bytes(state))
				post_attack_decision = PendingDecisions.current(state, ["unit-actions"])
				check(post_attack_decision.get("resume_frame_id", "") == saved_frame_id, "Invictor replacement and attack frame survive save/restore")
				for option: Dictionary in UnitActions.choices(state, 1):
					if option.action == "invictor-mark" and option.model == invictor and option.target == immortal_squad: replacement = option
				var replacement_result := submit_choice(state, 1, replacement)
				check(str(replacement_result.get("error", "")).is_empty() and Abilities.forward_assault_mark(state, inv_squad) == immortal_squad and state.unit_abilities.window.is_empty(), "Replacement target becomes the current mark through the normalized command")
				check(ResolutionFrames.current(state).is_empty(), "Completing the Invictor mark replacement closes the attack continuation")
	if failures == 0: print("Invictor Tactical Warsuit checks: 0 failures")
	else: push_error("Invictor Tactical Warsuit checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

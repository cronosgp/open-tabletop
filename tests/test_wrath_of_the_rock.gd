extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const CurrentProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const C = Prepared.Combat

var dice_values: Array[int] = [1, 1, 6, 6]
var dice_index := 0
var failures := 0

func die() -> int:
	var value := dice_values[dice_index]
	dice_index += 1
	return value

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(source: String, models: int, enhancement_id: String = "") -> Dictionary:
	return {
		"schema_version": 2,
		"faction": "Space Marines",
		"category": "training",
		"points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": models, "copies": 1, "enhancement_id": enhancement_id}]
	}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var captain_bike_identity := "40kdc:11e:adeptus-astartes:captain-on-bike"
	var chaplain_bike_identity := "40kdc:11e:adeptus-astartes:chaplain-on-bike"
	var outrider_identity := "40kdc:11e:adeptus-astartes:outrider-squad"
	var captain_identity := "40kdc:11e:adeptus-astartes:captain"
	check(Enhancements.valid_for(captain_bike_identity, Enhancements.LORD_OF_THE_RAVENWING, Enhancements.WRATH_OF_THE_ROCK), "The local export's Captain on Bike eligibility row is admitted")
	check(Enhancements.valid_for(chaplain_bike_identity, Enhancements.LORD_OF_THE_RAVENWING, Enhancements.WRATH_OF_THE_ROCK), "The local export's Chaplain on Bike eligibility row is admitted")
	check(not Enhancements.valid_for(outrider_identity, Enhancements.LORD_OF_THE_RAVENWING, Enhancements.WRATH_OF_THE_ROCK), "Ravenwing keyword alone does not admit Outrider Squad without an enhancement mapping row")
	check(not Enhancements.valid_for(captain_identity, Enhancements.LORD_OF_THE_RAVENWING, Enhancements.WRATH_OF_THE_ROCK), "Captain datasheets outside the local enhancement rows are rejected")
	var admission := ArmyCapabilities.admit(army("captain-on-bike", 1, Enhancements.LORD_OF_THE_RAVENWING))
	var base_points: int = CurrentProfiles.profile("captain-on-bike").points_by_models[1]
	check(admission.error.is_empty() and admission.total == base_points + 15, "Lord of the Ravenwing adds its exported 15-point cost on an eligible datasheet")
	var chaplain_admission := ArmyCapabilities.admit(army("chaplain-on-bike", 1, Enhancements.LORD_OF_THE_RAVENWING))
	var chaplain_points: int = CurrentProfiles.profile("chaplain-on-bike").points_by_models[1]
	check(chaplain_admission.error.is_empty() and chaplain_admission.total == chaplain_points + 15, "Chaplain on Bike receives the export-mapped enhancement option and cost")
	var rejected_outrider := ArmyCapabilities.admit(army("outrider-squad", 3, Enhancements.LORD_OF_THE_RAVENWING))
	check(not rejected_outrider.error.is_empty(), "Army admission rejects Lord of the Ravenwing on Outrider Squad")
	var rejected := ArmyCapabilities.admit(army("captain", 1, Enhancements.LORD_OF_THE_RAVENWING))
	check(not rejected.error.is_empty(), "Army admission rejects Lord of the Ravenwing on an ineligible datasheet")

	var armies := {
		1: army("captain-on-bike", 1, Enhancements.LORD_OF_THE_RAVENWING),
		2: army("storm-speeder-hailstrike", 1)
	}
	var state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.WRATH_OF_THE_ROCK}, armies)
	check(not state.has("error"), "Eligible Wrath of the Rock match profile is admitted")
	if state.has("error"):
		print("Wrath of the Rock checks: %d failures" % (failures + 1))
		quit(1)
		return

	var bike_squad := -1
	var bike_model := -1
	var enemy_squad := -1
	for squad: int in state.squads:
		if state.squads[squad].get("enhancement_id", "") == Enhancements.LORD_OF_THE_RAVENWING:
			bike_squad = squad
			bike_model = C.living(state, squad)[0]
		elif state.squads[squad].owner == 2:
			enemy_squad = squad
	check(bike_squad > 0 and bike_model >= 0 and enemy_squad > 0, "The selected Lord is materialized on its bearer unit")
	if bike_squad < 0 or bike_model < 0 or enemy_squad < 0:
		print("Wrath of the Rock checks: %d failures" % failures)
		quit(1)
		return
	check(C.Capabilities.enabled(state, "lord-of-the-ravenwing"), "The current capability registry enables Lord of the Ravenwing only for the selected Wrath match")
	check(Enhancements.lord_of_the_ravenwing_active(state, bike_squad), "The assigned enhancement activates for its eligible unit in Wrath of the Rock")
	var wrong_detachment: Dictionary = state.duplicate(true)
	wrong_detachment.combat_doctrines.detachment = "stormlance-task-force"
	check(not Enhancements.lord_of_the_ravenwing_active(wrong_detachment, bike_squad), "Lord of the Ravenwing is inactive outside Wrath of the Rock")

	for model: int in C.living(state, bike_squad): state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, enemy_squad): state.units[model].position = Vector2(8, 0)
	state.phase = "charge"
	state.active = 1
	state.turn = 1
	state.revision = 0
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var declared := C.declare_charge(state, 1, bike_model, state.revision, die)
	check(declared.error.is_empty() and C.Stratagems.pending(state).get("lord_of_the_ravenwing", false), "A Charge roll opens Lord of the Ravenwing's optional re-roll window: " + str(declared.get("error", "")))
	if not declared.error.is_empty() or not C.Stratagems.pending(state).get("lord_of_the_ravenwing", false):
		print("Wrath of the Rock checks: %d failures" % failures)
		quit(1)
		return
	var original_frame := C.ResolutionFrames.current(state)
	var decision := C.Stratagems.pending_decision(state)
	var lord_option := false
	for option: Dictionary in decision.get("legal_options", []):
		if option.get("action", "") == "stratagem-reaction" and option.get("value", "") == "lord-of-the-ravenwing": lord_option = true
	check(lord_option and decision.get("source", "") == "stratagems", "The normalized decision offers the free Lord of the Ravenwing re-roll")
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_decision := C.Stratagems.pending_decision(restored)
	check(restored_decision.get("decision_id", "") == decision.get("decision_id", "") and restored_decision.get("legal_options", []) == decision.get("legal_options", []) and restored_decision.get("priority_player_id", -1) == decision.get("priority_player_id", -2) and C.ResolutionFrames.current(restored) == original_frame, "The Lord decision and Charge continuation survive serialization")
	var before_blocked_close := var_to_bytes(restored)
	check(not C.advance_phase(restored, 1, restored.revision).is_empty() and var_to_bytes(restored) == before_blocked_close, "The restored Charge re-roll blocks phase close without mutation")
	state = restored
	var projected_lord_option: Dictionary = {}
	for option: Dictionary in C.Stratagems.pending_decision(state).get("legal_options", []):
		if int(option.get("target", -1)) == bike_squad and str(option.get("value", "")) == "lord-of-the-ravenwing": projected_lord_option = option
	var lord_choice := {"action": "stratagem-reaction", "model": -1, "target": bike_squad, "value": "lord-of-the-ravenwing", "die": -1}
	var lord_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(restored_decision.get("decision_id", "")), "option_id": str(projected_lord_option.get("id", "")), "choice": lord_choice}
	var before_wrong_lord_owner := var_to_bytes(state)
	var wrong_lord_owner := MatchCommands.execute(state, 2, {"kind": MatchCommands.COMMAND_REACTION, "choice": lord_envelope, "revision": state.revision}, Callable(self, "die"))
	check(not str(wrong_lord_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_lord_owner, "The opponent cannot submit Lord of the Ravenwing or mutate its saved Charge decision")
	var cp_before: int = state.cp[1]
	var reroll_result := MatchCommands.execute(state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": lord_envelope, "revision": state.revision}, Callable(self, "die"))
	var resumed_frame := C.ResolutionFrames.current(state)
	check(str(reroll_result.get("error", "")).is_empty() and dice_index == 4 and state.cp[1] == cp_before, "The Lord re-rolls both Charge dice through the public command for 0 CP")
	check(state.pending_charge.get("rolls", []) == [6, 6] and state.pending_charge.get("maximum", -1) == 12 and state.stratagems.pending.is_empty(), "The re-rolled result becomes the mandatory Charge result")
	check(state.get("last_command_roll", {}).get("source", "") == "lord-of-the-ravenwing" and state.get("last_command_roll", {}).get("rerolled", false), "The roll journal records Lord of the Ravenwing as the source")
	check(resumed_frame.get("frame_id", "") == original_frame.get("frame_id", "") and resumed_frame.get("action_id", "") == original_frame.get("action_id", "") and resumed_frame.get("status", "") == "resolving", "The existing Charge continuation resumes with the same frame identity")
	var before_second_attempt := var_to_bytes(state)
	var replayed_lord_choice := MatchCommands.execute(state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": lord_envelope, "revision": state.revision}, Callable(self, "die"))
	check(not str(replayed_lord_choice.get("error", "")).is_empty() and var_to_bytes(state) == before_second_attempt, "The resolved Lord of the Ravenwing decision cannot be replayed")

	print("Wrath of the Rock checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const CurrentProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const C = Prepared.Combat
const D = C.DetachmentStratagems
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(source: String, enhancement_id: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": 1 if source != "outrider-squad" else 3, "copies": 1, "enhancement_id": enhancement_id}]}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var valid := Capabilities.admit(army("captain-on-bike", Enhancements.SUPERCHARGED))
	var base_cost: int = CurrentProfiles.profile("captain-on-bike").points_by_models[1]
	check(valid.error.is_empty() and valid.total == base_cost + 10 and valid.selection.entries[0].enhancement_id == Enhancements.SUPERCHARGED, "Supercharged Engines admission adds its exported 10 point cost")
	var wrong_sheet := Capabilities.admit(army("captain-on-bike", Enhancements.AUSPEX))
	check(not wrong_sheet.error.is_empty(), "Auspex is rejected on an ineligible datasheet")
	var wrong_keyword := Capabilities.admit(army("chaplain-on-bike", Enhancements.AUSPEX))
	check(not wrong_keyword.error.is_empty(), "An enhancement is rejected when its exact export mapping excludes that datasheet")
	check(Enhancements.valid_for("40kdc:11e:adeptus-astartes:outrider-squad", Enhancements.SUPERCHARGED, Enhancements.STORMLANCE) and not Enhancements.valid_for("40kdc:11e:adeptus-astartes:redemptor-dreadnought", Enhancements.SUPERCHARGED, Enhancements.STORMLANCE), "Supercharged Engines follows the local Mounted datasheet eligibility rows")
	check(Enhancements.valid_for("40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", Enhancements.AUSPEX, Enhancements.STORMLANCE) and Enhancements.valid_for("40kdc:11e:adeptus-astartes:land-speeder", Enhancements.AUSPEX, Enhancements.STORMLANCE), "Auspex Triangulation Shrines accepts the local Speeder eligibility rows")
	var armies := {1: army("captain-on-bike", Enhancements.SUPERCHARGED), 2: army("storm-speeder-hailstrike", Enhancements.AUSPEX)}
	var state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": "stormlance"}, armies)
	check(not state.has("error"), "Both exported Stormlance enhancements are admitted into a local training match")
	if not state.has("error"):
		var bike_squad := 1
		var speeder_squad := 2
		check(state.squads[bike_squad].enhancement_id == Enhancements.SUPERCHARGED and state.squads[speeder_squad].enhancement_id == Enhancements.AUSPEX, "Enhancement identity is materialized on its selected unit")
		state.phase = "movement"
		state.active = 1
		state.squads[bike_squad].moved = false
		var first := C.begin_movement(state, 1, 100, "advance", state.revision, func() -> int: return 2)
		check(first.is_empty() and C.Stratagems.pending(state).get("supercharged", false), "Advance opens the Supercharged Engines decision window")
		var cp_before: int = state.cp[1]
		var reroll := C.resolve_roll_reaction(state, 1, bike_squad, "supercharged-engines", state.revision, func() -> int: return 5)
		check(reroll.is_empty() and state.cp[1] == cp_before and state.pending_move.bonus >= 5, "Supercharged reroll is free and its new D6 result is mandatory")
		state.pending_move = {}
		state.phase = "shooting"
		state.active = 2
		state.unit_abilities.window = {}
		state.unit_abilities.setup_done = true
		state.terrain.areas = []
		for model: int in state.units:
			if state.units[model].squad == speeder_squad: state.units[model].position = Vector2(0, 0)
			elif state.units[model].squad == bike_squad: state.units[model].position = Vector2(5, 0)
		var choices := UnitActions.choices(state, 2)
		var spotted_choice: Dictionary = {}
		for candidate: Dictionary in choices:
			if candidate.get("action", "") == "auspex-spotted" and int(candidate.get("target", -1)) == bike_squad: spotted_choice = candidate
		check(not spotted_choice.is_empty(), "Auspex offers a visible enemy within 12 inches at Shooting start")
		if not spotted_choice.is_empty():
			var result: Dictionary = UnitActions.apply(state, 2, spotted_choice, Vector2.ZERO, Callable())
			check(result.get("error", "").is_empty() and is_equal_approx(Detection.detection_range(state, 100, false), 18.0), "Auspex marks the target spotted and adds 3 inches to detection")
			check(D.spotted_source_used(state, speeder_squad) and UnitActions.auspex_triangulation_choices(state, 2).is_empty(), "One Auspex bearer marks no more than one enemy unit in its Shooting phase")
			state.turn += 1
			check(D.spotted(state, bike_squad) and is_equal_approx(Detection.detection_range(state, 100, false), 18.0) and not D.spotted_source_used(state, speeder_squad), "The spotted bonus persists and the Auspex can be used again in a later Shooting phase")
			for model: int in state.units:
				if state.units[model].squad == speeder_squad: state.units[model].position = Vector2(30, 0)
			check(UnitActions.auspex_triangulation_choices(state, 2).is_empty(), "Auspex cannot select an enemy outside 12 inches")
			state.turn -= 1
	print("Stormlance enhancement checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

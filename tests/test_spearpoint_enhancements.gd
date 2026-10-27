extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const CurrentProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const C = Prepared.Combat
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(source: String, enhancement_id: String, models: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": models, "copies": 1, "enhancement_id": enhancement_id}]}

func first_squad(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func bearer(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and not str(state.units[model].get("enhancement_id", "")).is_empty(): return model
	return -1

func first_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	for spec: Dictionary in [
		{"source": "captain", "id": Enhancements.STORMSEERS_WISDOM, "cost": 15},
		{"source": "outrider-squad", "id": Enhancements.CHOGORIAN_HUNTMASTER, "cost": 20, "models": 3},
		{"source": "captain", "id": Enhancements.HUNTERS_EYE, "cost": 25},
		{"source": "captain", "id": Enhancements.SPEARPOINT_PARAGON, "cost": 25}
	]:
		var source := str(spec.source)
		var id := str(spec.id)
		var valid := Capabilities.admit(army(source, id, int(spec.get("models", 1))))
		var price := int(CurrentProfiles.profile(source).points_by_models[int(spec.get("models", 1))])
		check(valid.error.is_empty() and valid.total == price + int(spec.cost), "%s is admitted from the local export with its exact points" % id)
		check(Enhancements.valid_for("40kdc:11e:adeptus-astartes:" + source, id, Enhancements.SPEARPOINT), "%s uses the local datasheet-to-enhancement eligibility rows" % id)
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:redemptor-dreadnought", Enhancements.HUNTERS_EYE, Enhancements.SPEARPOINT), "Spearpoint bearer eligibility rejects a datasheet absent from the export relation")

	var wisdom := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.SPEARPOINT}, {1: army("captain", Enhancements.STORMSEERS_WISDOM), 2: army("intercessor-squad", "", 5)})
	check(not wisdom.has("error"), "Stormseer's Wisdom enters a local Spearpoint training match: " + str(wisdom.get("error", "")))
	if not wisdom.has("error"):
		var wisdom_squad := first_squad(wisdom, 1)
		wisdom.phase = "movement"
		wisdom.active = 1
		var advance_error := C.begin_movement(wisdom, 1, first_model(wisdom, wisdom_squad), "advance", wisdom.revision, func() -> int: return 2)
		check(advance_error.is_empty() and C.Stratagems.pending(wisdom).get("stormseers_wisdom", false), "Stormseer's Wisdom opens after the unit's Advance roll: " + advance_error)
		var cp_before: int = wisdom.cp[1]
		var decision := C.Stratagems.pending_decision(wisdom)
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if int(option.get("target", -1)) == wisdom_squad and str(option.get("value", "")) == "stormseers-wisdom": projected = option
		var choice := {"action": "stratagem-reaction", "model": -1, "target": wisdom_squad, "value": "stormseers-wisdom", "die": -1}
		var envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
		var before_wrong_owner := var_to_bytes(wisdom)
		var wrong_owner := MatchCommands.execute(wisdom, 2, {"kind": MatchCommands.COMMAND_REACTION, "choice": envelope, "revision": wisdom.revision}, func() -> int: return 5)
		check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(wisdom) == before_wrong_owner, "The opponent cannot submit or mutate Stormseer's Wisdom")
		var reroll_result := MatchCommands.execute(wisdom, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": envelope, "revision": wisdom.revision}, func() -> int: return 5)
		check(str(reroll_result.get("error", "")).is_empty() and wisdom.cp[1] == cp_before and wisdom.pending_move.get("raw_bonus", 0) == 5, "Stormseer's Wisdom rerolls the Advance D6 through the public command for free")

	var huntmaster := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.SPEARPOINT}, {1: army("outrider-squad", Enhancements.CHOGORIAN_HUNTMASTER, 3), 2: army("intercessor-squad", "", 5)})
	check(not huntmaster.has("error"), "Chogorian Huntmaster enters a local Spearpoint training match: " + str(huntmaster.get("error", "")))
	if not huntmaster.has("error"):
		var huntmaster_squad := first_squad(huntmaster, 1)
		huntmaster.round = 1
		check(Enhancements.ingress_round_allowed(huntmaster, huntmaster_squad), "Chogorian Huntmaster treats battle round 1 as round 2 for ingress")
		var no_huntmaster := huntmaster.duplicate(true)
		no_huntmaster.squads[huntmaster_squad].enhancement_id = ""
		for model: int in no_huntmaster.units: no_huntmaster.units[model].enhancement_id = ""
		check(not Enhancements.ingress_round_allowed(no_huntmaster, huntmaster_squad), "Round 1 ingress stays unavailable to a unit without Chogorian Huntmaster")

	var eye := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.SPEARPOINT}, {1: army("captain", Enhancements.HUNTERS_EYE), 2: army("intercessor-squad", "", 5)})
	if not eye.has("error"):
		var eye_squad := first_squad(eye, 1)
		var eye_bearer := bearer(eye, eye_squad)
		var ranged := {"strength": 4, "ap": 0, "keywords": {"sustained-hits": 0}}
		var enhanced_ranged: Dictionary = AttackPlan._enhancement_weapon(eye, eye_bearer, ranged, false)
		check(enhanced_ranged.keywords.get("ignores-cover", false) and enhanced_ranged.keywords.get("sustained-hits", 0) == 1, "Hunter's Eye adds Ignores Cover and Sustained Hits 1 to the bearer's unit ranged attacks")
		var already_sustained := {"strength": 4, "ap": 0, "keywords": {"sustained-hits": 2}}
		var no_stack: Dictionary = AttackPlan._enhancement_weapon(eye, eye_bearer, already_sustained, false)
		check(no_stack.keywords.get("sustained-hits", 0) == 2, "Hunter's Eye does not stack Sustained Hits beyond the existing higher value")
		check(Enhancements.hunters_eye_active(eye, eye_squad), "Hunter's Eye applies to the whole assigned unit")

	var paragon := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.SPEARPOINT}, {1: army("captain", Enhancements.SPEARPOINT_PARAGON), 2: army("intercessor-squad", "", 5)})
	if not paragon.has("error"):
		var paragon_squad := first_squad(paragon, 1)
		var paragon_bearer := bearer(paragon, paragon_squad)
		var melee := {"strength": 4, "ap": -1, "keywords": {}}
		var uncharged: Dictionary = AttackPlan._enhancement_weapon(paragon, paragon_bearer, melee, true)
		paragon.squads[paragon_squad].charged = true
		var charged: Dictionary = AttackPlan._enhancement_weapon(paragon, paragon_bearer, melee, true)
		check(uncharged.strength == 5 and uncharged.ap == -2, "Spearpoint Paragon grants +1 Strength and AP before a Charge")
		check(charged.strength == 6 and charged.ap == -3, "Spearpoint Paragon grants +2 Strength and AP after its unit charges")
		check(Enhancements.spearpoint_paragon_bearer(paragon, paragon_bearer), "Spearpoint Paragon modifies only the assigned bearer")

	print("Spearpoint enhancement checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

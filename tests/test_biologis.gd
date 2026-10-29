extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")

const BIOLOGIS_ID := "40kdc:11e:adeptus-astartes:apothecary-biologis"
const BIOLOGIS_BODYGUARDS := {
	"aggressor-squad": 3,
	"heavy-intercessor-squad": 5,
	"eradicator-squad-with-heavy-bolters": 3,
	"eradicator-squad-with-melta-rifles": 3
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		entry("apothecary-biologis"),
		entry("aggressor-squad", 3),
		entry("heavy-intercessor-squad", 5),
		entry("eradicator-squad-with-heavy-bolters", 3),
		entry("eradicator-squad-with-melta-rifles", 3),
		entry("intercessor-squad", 5)
	]
	return result

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true,
		"combat_doctrines": true,
		"reanimation_protocols": true,
		"awakened_dynasty": true,
		"core_stratagems": true,
		"manual_allocation": false
	}, lists())
	if state.has("error"):
		return state
	state.awakened_dynasty.pending = []
	state.mission.stage = "battle"
	state.terrain.areas = []
	return state

func find_squad(state: Dictionary, player: int, identity: String, model_count: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or C.UnitAbilities.identity(unit) != identity:
			continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad):
			continue
		if model_count >= 0 and C.living(state, squad).size() != model_count:
			continue
		return squad
	return -1

func find_model(state: Dictionary, player: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == player and C.UnitAbilities.identity(unit) == identity and int(unit.get("wounds", 0)) > 0:
			return model
	return -1

func option(state: Dictionary, action: String, model: int = -1, target: int = -1) -> Dictionary:
	for selected: Dictionary in C.unit_choices(state, 1):
		if str(selected.get("action", "")) != action:
			continue
		if model >= 0 and int(selected.get("model", -1)) != model:
			continue
		if target >= 0 and int(selected.get("target", -1)) != target:
			continue
		return selected
	return {}

func apply(state: Dictionary, selected: Dictionary) -> String:
	if selected.is_empty():
		return "The requested preparation choice is not currently available."
	var decision := PendingDecisions.current(state, ["mission-preparation", "unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for legal_option: Dictionary in decision.get("legal_options", []):
			if str(legal_option.get("action", "")) == str(selected.get("action", "")) \
			and int(legal_option.get("model", -1)) == int(selected.get("model", -1)) \
			and int(legal_option.get("target", -1)) == int(selected.get("target", -1)) \
			and str(legal_option.get("value", "")) == str(selected.get("value", "")):
				projected = legal_option
				break
		if projected.is_empty():
			return "The preparation choice is not present in the current projection."
		payload = {
			"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE,
			"decision_id": str(decision.get("decision_id", "")),
			"option_id": str(projected.get("id", "")),
			"choice": selected
		}
	var result := MatchCommands.execute(state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload})
	return str(result.get("error", ""))

func sorted_strings(values: Array) -> Array:
	var result := values.duplicate()
	result.sort()
	return result

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var state := fixture()
	check(not state.has("error"), "The current consolidated Marine catalog materializes on both players' rosters")
	if state.has("error"):
		print(state)
		quit(1)
		return

	var profile: Dictionary = Profiles.profile("apothecary-biologis")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000060" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Biologis maps to the shared-book source identity and keeps its runtime export stamp")
	check(state.training_points[1] == 550, "The six current-catalog Marine choices retain their source point costs")
	var roster_admission := C.RosterValidation.admit(lists()[1])
	check(roster_admission.get("error", "").is_empty() and roster_admission.get("total", -1) == 550, "The current-catalog roster passes construction admission at 550 points")
	check(profile.points_by_models == {1: 60} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "One-model composition, 60 points and 40 mm base match the export")
	check(profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "APOTHECARY", "CHARACTER", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "The local export has no selectable Biologis weapon options")
	var biologis_model := find_model(state, 1, "apothecary-biologis")
	check(biologis_model > 0 and int(state.units[biologis_model].get("max_wounds", -1)) == 5 and is_equal_approx(float(state.units[biologis_model].get("radius", 0.0)), 20.0 / 25.4), "The current-catalog Biologis materializes with five wounds and a 40 mm base")

	var expected_bodyguards: Array[String] = []
	for identity_variant: Variant in BIOLOGIS_BODYGUARDS:
		expected_bodyguards.append(str(identity_variant))
	expected_bodyguards.sort()
	var support_targets: Array = SupportAttachments.BODYGUARDS.get("apothecary-biologis", []).duplicate()
	var shared_support_targets: Array = support_targets.filter(func(identity: Variant) -> bool: return str(identity) != "indomitor-kill-team")
	check(sorted_strings(shared_support_targets) == expected_bodyguards and "indomitor-kill-team" in support_targets, "The Support map contains all four shared-book Gravis bodyguards and the source-listed Indomitor Chapter endpoint")
	var leader_targets: Array = LeaderLinks.TARGETS.get("apothecary-biologis", []).duplicate()
	check(sorted_strings(leader_targets) == expected_bodyguards and "indomitor-kill-team" in LeaderLinks.targets("apothecary-biologis"), "Common-book Leader relations and the separate Indomitor Chapter link are both retained")

	var bodyguard_squads: Dictionary = {}
	var aggressors := -1
	for identity_variant: Variant in BIOLOGIS_BODYGUARDS:
		var identity := str(identity_variant)
		var squad := find_squad(state, 1, identity, int(BIOLOGIS_BODYGUARDS[identity]))
		bodyguard_squads[identity] = squad
		if identity == "aggressor-squad":
			aggressors = squad
		check(squad > 0, "Current catalog materializes the source-linked %s bodyguard" % identity)
		if squad > 0:
			check(C.UnitActions.attachment_allowed(state, biologis_model, squad), "Biologis can attach to the source-linked %s bodyguard" % identity)
	var intercessor_squad := find_squad(state, 1, "intercessor-squad", 5)
	check(intercessor_squad > 0 and not C.UnitActions.attachment_allowed(state, biologis_model, intercessor_squad), "Biologis cannot attach to a non-Gravis Intercessor squad")
	check(not SupportAttachments.matching_error([entry("apothecary-biologis"), entry("apothecary-biologis"), entry("aggressor-squad", 3)]).is_empty(), "Two Biologis Supports require two separate eligible bodyguards")
	var target_before_attachment := find_squad(state, 2, "intercessor-squad", 10)
	var aggressor_model_before_attachment := C.living(state, aggressors)[0]
	var fists: Dictionary = Profiles.profile("aggressor-squad").melee[0].profiles.standard
	check(not C.UnitAbilities.weapon(state, aggressor_model_before_attachment, target_before_attachment, fists, true).keywords.get("lethal-hits", false), "Vivispectral Analysis Targeting is absent before Support attachment")

	check(apply(state, option(state, "warlord", biologis_model)).is_empty(), "A current-catalog Character Biologis can be selected as Warlord")
	var attachment_choices := 0
	for identity_variant: Variant in BIOLOGIS_BODYGUARDS:
		var identity := str(identity_variant)
		if not option(state, "attach", biologis_model, int(bodyguard_squads[identity])).is_empty():
			attachment_choices += 1
	check(attachment_choices == BIOLOGIS_BODYGUARDS.size(), "Preparation projects all four current-catalog Biologis Support targets")
	check(apply(state, option(state, "attach", biologis_model, aggressors)).is_empty(), "The normalized public preparation command attaches Biologis to Aggressors")
	check(state.units[biologis_model].squad == aggressors and state.units[biologis_model].attachment_role == "support" and state.squads[aggressors].starting_strength == 4, "Attached Support role and unit starting strength materialize correctly")
	var setup_done := option(state, "setup-done")
	if not setup_done.is_empty():
		check(apply(state, setup_done).is_empty(), "Preparation can continue after the mandatory Support has been attached")

	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.phase = "shooting"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	var attacker := find_model(state, 1, "aggressor-squad")
	var target := find_squad(state, 2, "intercessor-squad", 10)
	check(target > 0, "The opponent's current-catalog Intercessor target is materialized")
	for model: int in C.living(state, aggressors):
		state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, target):
		state.units[model].position = Vector2(8.0, 0.0)
	check(C.UnitAbilities.weapon(state, attacker, target, fists, true).keywords.get("lethal-hits", false), "The living attached Support grants Lethal Hits to bodyguard attacks")
	var pistol_selected := Equipment.select(state, biologis_model, false, "absolvor-bolt-pistol", "standard")
	var servo_selected := Equipment.select(state, biologis_model, true, "servo-armature", "standard")
	check(pistol_selected.get("error", "").is_empty() and pistol_selected.stats == profile.ranged[0].profiles.standard, "Fixed Absolvor Bolt Pistol reaches Equipment with its sourced profile")
	check(servo_selected.get("error", "").is_empty() and servo_selected.stats == profile.melee[0].profiles.standard, "Fixed Servo-armature reaches Equipment with its sourced profile")
	var pistol_plan := C.AttackPlan.prepare(state, aggressors, false, [{"model": biologis_model, "target": target, "amount": 1, "weapon": "absolvor-bolt-pistol", "profile": "standard"}], true)
	check(pistol_plan.error.is_empty() and pistol_plan.batches.size() == 1 and pistol_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Biologis pistol enters AttackPlan with Vivispectral Lethal Hits")
	check(pistol_plan.error.is_empty() and pistol_plan.batches[0].weapon.range_inches == 18.0 and pistol_plan.batches[0].weapon.attacks == 1 and pistol_plan.batches[0].weapon.skill == 3 and pistol_plan.batches[0].weapon.strength == 6 and pistol_plan.batches[0].weapon.ap == -2 and pistol_plan.batches[0].weapon.damage == 2, "AttackPlan combines the fixed pistol with Aggressor Firestorm's +1 Strength and Biologis Lethal Hits")
	if pistol_plan.error.is_empty() and pistol_plan.batches.size() == 1:
		var dice: Array[int] = [6, 1]
		var pool := C.AttackPlan.Attacks.roll_pool(pistol_plan.batches[0].weapon, C.AttackPlan.defender(state, target), pistol_plan.batches[0].context, func() -> int: return dice.pop_front())
		check(pool.error.is_empty() and pool.hits == 1 and pool.wounds == 1 and pool.wound_rolls.is_empty(), "A critical pistol hit uses Lethal Hits to wound automatically without a wound roll")
	var expected_fists := Equipment.select(state, attacker, true, "twin-power-fists", "standard")
	check(expected_fists.get("error", "").is_empty() and expected_fists.stats == fists, "Bodyguard melee remains selectable through Equipment")
	for model: int in C.living(state, target):
		state.units[model].keywords.append("MONSTER")
	check(C.UnitAbilities.weapon(state, attacker, target, fists, true).keywords.get("lethal-hits", false), "Monster targets remain eligible under the non-Vehicle restriction")
	var vehicle_model := C.living(state, target)[0]
	state.units[vehicle_model].keywords.append("VEHICLE")
	check(not C.UnitAbilities.weapon(state, attacker, target, fists, true).keywords.get("lethal-hits", false), "A Vehicle keyword on a living model excludes the attached target unit")
	state.units[vehicle_model].wounds = 0
	check(C.UnitAbilities.weapon(state, attacker, target, fists, true).keywords.get("lethal-hits", false), "A destroyed target model no longer contributes its Vehicle keyword")
	state.phase = "fight"
	state.units[biologis_model].position = Vector2.ZERO
	var target_models := C.living(state, target)
	for model_index in range(target_models.size()):
		state.units[target_models[model_index]].position = Vector2(1.6, 0.0) if model_index == 0 else Vector2(8.0, float(model_index) * 2.0)
	var living_target_models := C.living(state, target)
	if not living_target_models.is_empty():
		state.units[living_target_models[0]].position = Vector2(1.6, 0.0)
	var servo_plan := C.AttackPlan.prepare(state, aggressors, true, C.AttackPlan.single_target(state, aggressors, target, true), true)
	var servo_attacks := 0
	for batch: Dictionary in servo_plan.get("batches", []):
		if str(batch.get("weapon", {}).get("name", "")) == "Servo-armature" and batch.weapon.keywords.get("lethal-hits", false):
			servo_attacks += int(batch.get("count", 0))
	check(servo_plan.error.is_empty() and servo_attacks == 4, "All four Biologis Servo-armature attacks enter the attached-unit plan with Lethal Hits: " + str(servo_plan.get("error", "")))
	state.units[biologis_model].wounds = 0
	check(not C.UnitAbilities.weapon(state, attacker, target, fists, true).keywords.get("lethal-hits", false), "Destroying the Support source removes Vivispectral Analysis Targeting from future declarations")

	var invalid := lists()
	invalid[1].entries = [entry("apothecary-biologis"), entry("intercessor-squad", 5)]
	check(not C.RosterValidation.admit(invalid[1]).get("error", "").is_empty(), "Roster admission rejects a non-Gravis bodyguard for Biologis")
	invalid = lists()
	invalid[1].entries = [entry("apothecary-biologis"), entry("apothecary-biologis"), entry("aggressor-squad", 3)]
	check(not C.RosterValidation.admit(invalid[1]).get("error", "").is_empty(), "Roster admission rejects two Biologis Supports with only one eligible bodyguard")

	print("Biologis current-catalog checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:captain-with-jump-pack", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 1}]
	return result

func find_choice(state: Dictionary, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func submit_preparation_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No current Vanguard Veteran preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current Vanguard Veteran preparation decision does not offer this choice."}
	return Commands.execute(state, player, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}})

func _initialize() -> void:
	var profile := Profiles.profile("vanguard-veteran-squad-with-jump-packs")
	check(profile.source_datasheet_id == "000000147" and profile.source_book_id == "000000139" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Vanguard Veterans retain their Space Marines e11 source identity")
	check(profile.stats.movement_inches == 12 and profile.stats.toughness == 5 and profile.stats.save_target == 3 and profile.stats.wounds == 2 and profile.stats.objective_control == 1, "Vanguard Veteran characteristics match the local export")
	check(profile.points_by_models == {5: 110, 10: 220} and profile.third_plus_points_by_models == {5: 130, 10: 240} and profile.max_supported_copies == 2, "Both size prices and the supported-copy boundary are source-backed")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 10, "copies": 1}]})
	check(five.error.is_empty() and five.total == 110 and ten.error.is_empty() and ten.total == 220, "Five- and ten-model formations are admitted at their extracted prices")
	var too_many := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 3}]})
	check(not too_many.error.is_empty(), "The third-plus points tier is not mispriced at the first/second-unit value")
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Captain and Vanguard Veteran Jump Pack profiles materialize from the local catalog")
	if state.has("error"):
		print("Vanguard Veteran checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(UnitActions.attachment_allowed(state, 100, 3), "Captain With Jump Pack has its source-recorded Vanguard Veteran Leader link")
	UnitActions.attach(state, 100, 3)
	state.awakened_dynasty.pending = []
	check(Abilities.every_model_has(state, 3, "deep-strike") and Abilities.has(state, 3, "vanguard-assault"), "Deep Strike and Vanguard Assault are active on the assembled unit")
	var shield := find_choice(state, "vanguard-veteran-pistol", 301, "combat-shield")
	var prep_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_choice := var_to_bytes(state)
	var wrong_owner := submit_preparation_choice(state, 2, shield)
	var stale_option := submit_preparation_choice(state, 1, shield, str(prep_decision.get("decision_id", "")), "stale-option")
	check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and before_choice == var_to_bytes(state), "Wrong-owner and stale Vanguard Veteran choices are rejected unchanged")
	check(not shield.is_empty() and submit_preparation_choice(state, 1, shield).get("error", "").is_empty(), "A model can replace its Heavy Bolt Pistol with a Combat Shield through the public command")
	check(Groups.profile(state, 301).invulnerable_target == 5 and Groups.profile(state, 302).invulnerable_target == 0, "Combat Shield grants an individual 5+ invulnerable save only to its bearer")
	var plasma := find_choice(state, "vanguard-veteran-pistol", 301, "plasma-pistol")
	check(not plasma.is_empty() and submit_preparation_choice(state, 1, plasma).get("error", "").is_empty(), "An equipped Combat Shield can be replaced by a Plasma Pistol through the public command")
	check(state.units[301].ranged_weapons[0].profiles.supercharge.keywords.hazardous and state.units[301].ranged_weapons[0].profiles.standard.attacks == 1, "Both extracted Plasma Pistol modes are available")
	for model: int in [302, 303]:
		plasma = find_choice(state, "vanguard-veteran-pistol", model, "plasma-pistol")
		if not plasma.is_empty(): check(submit_preparation_choice(state, 1, plasma).get("error", "").is_empty(), "An ordinary-model Plasma Pistol selection uses the public command")
	check(find_choice(state, "vanguard-veteran-pistol", 304, "plasma-pistol").is_empty(), "Two ordinary Plasma Pistols is the five-model cap")
	var sergeant_plasma := find_choice(state, "vanguard-veteran-pistol", 300, "plasma-pistol")
	check(not sergeant_plasma.is_empty() and submit_preparation_choice(state, 1, sergeant_plasma).get("error", "").is_empty(), "The Sergeant's independent Plasma Pistol option does not consume the ordinary-model limit")
	var hammer := find_choice(state, "vanguard-veteran-melee", 300, "thunder-hammer")
	check(not hammer.is_empty() and submit_preparation_choice(state, 1, hammer).get("error", "").is_empty() and state.units[300].melee_weapons[0].profiles.standard.keywords.get("devastating-wounds", false), "Sergeant may replace the Relic Blade with a Devastating Wounds Thunder Hammer through the public command")
	state.squads[3].charged = false
	check(Abilities.melee_bonus(state, 3) == 0, "Vanguard Assault is inactive before the unit charges")
	state.squads[3].charged = true
	check(Abilities.melee_bonus(state, 3) == 1 and Abilities.weapon(state, 300, 2, state.units[300].melee_weapons[0].profiles.standard, true).attacks == 4, "Vanguard Assault adds one melee Attack after the assembled unit charges")
	state.phase = "fight"
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20 if state.units[model].owner == 1 else 20, model % 5)
	state.units[300].position = Vector2.ZERO
	state.units[200].position = Vector2(1.5, 0)
	var hammer_entries := C.AttackPlan.single_target(state, 3, 2, true)
	var hammer_plan := C.AttackPlan.prepare(state, 3, true, hammer_entries, true)
	check(hammer_plan.error.is_empty() and hammer_entries.size() == 1 and hammer_plan.batches.size() == 1 and hammer_plan.batches[0].count == 4 and hammer_plan.batches[0].context.attack_sources[0].expression == 4, "Vanguard Assault adds exactly one attack in the prepared Fight-phase hammer pool")
	var relic: Dictionary = Profiles.vanguard_veteran_weapons(true, "heavy-bolt-pistol", "relic-blade").melee[0].profiles.standard
	check(Abilities.weapon(state, 300, 2, relic, true).keywords.get("lethal-hits", false), "Relic Blade grants Lethal Hits against a target without excluded keywords")
	state.units[200].keywords = ["MONSTER"]
	check(not Abilities.weapon(state, 300, 2, relic, true).keywords.get("lethal-hits", false), "Relic Blade's conditional Lethal Hits excludes Monster targets")
	print("Vanguard Veteran Jump Pack checks: %d failures" % failures)
	quit(1 if failures else 0)

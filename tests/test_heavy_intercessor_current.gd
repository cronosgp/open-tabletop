extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const U = F.C.UnitActions
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const DamageAllocation = preload("res://scripts/edition_11/damage_allocation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const HI_ID := "40kdc:11e:adeptus-astartes:heavy-intercessor-squad"
const GRAVIS_CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain-in-gravis-armour"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := {
	"bolt-pistol": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"heavy-bolt-rifle": {"melee": false, "range_inches": 30.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 1}},
	"heavy-bolter": {"melee": false, "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"heavy": true, "sustained-hits": 1, "rapid-fire": 2}},
	"ceramite-fists": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(models: int = 5) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": HI_ID, "models": models, "copies": 1},
		{"definition_id": GRAVIS_CAPTAIN_ID, "models": 1, "copies": 1}]
	result[2].entries = [{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]
	return result

func make_state(models: int = 5) -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections(models))

func find_models(state: Dictionary, owner: int, identity: String) -> Dictionary:
	var result := {"squad": -1, "models": [], "sergeant": -1}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		result.squad = int(unit.squad)
		result.models.append(model)
		if unit.get("sergeant", false): result.sergeant = model
	return result

func option_for(options: Array, model: int, value: String = "on") -> Dictionary:
	for option: Dictionary in options:
		if option.action == "heavy-intercessor-bolter" and int(option.model) == model and str(option.value) == value: return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty(): return {"error": "No UnitActions preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current preparation decision does not offer this choice."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}})

func check_weapon_profile(state: Dictionary, squad: int, model: int, target_squad: int, weapon_id: String) -> void:
	var expected: Dictionary = WEAPONS[weapon_id]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon_id, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is available through Equipment" % weapon_id)
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the pinned export" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s preserves all source weapon traits" % weapon_id)
	var prior_phase: String = str(state.phase)
	var targets: Array[int] = C.living(state, target_squad)
	if targets.is_empty():
		check(false, "AttackPlan target squad has a living model")
		return
	var target_model := targets[0]
	var old_positions := {}
	for member: int in C.living(state, squad) + targets: old_positions[member] = state.units[member].position
	for index in range(C.living(state, squad).size()):
		var member: int = C.living(state, squad)[index]
		var other_attacker_x := -10.0 if expected.melee else 0.0
		state.units[member].position = Vector2.ZERO if member == model else Vector2(other_attacker_x, 4 + index * 3)
	for index in range(targets.size()):
		var member: int = targets[index]
		var target_distance := 1.0 if expected.melee else 4.0
		var other_target_x := 10.0 if expected.melee else target_distance
		state.units[member].position = Vector2(target_distance, 0) if member == target_model else Vector2(other_target_x, 4 + index * 3)
	state.phase = "fight" if expected.melee else "shooting"
	var amount := int(selected.stats.attacks) if expected.melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, bool(expected.melee), [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
	state.phase = prior_phase
	for member: int in old_positions: state.units[member].position = old_positions[member]
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan preserves %s as the attack source" % weapon_id)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("heavy-intercessor-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001177" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Heavy Intercessor identity retains its original local-export stamp and maps to the pinned shared-book source")
	check(profile.get("points_by_models", {}) == {5: 115, 10: 230} and profile.get("models") == 5 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Five/ten-model prices and 40 mm bases match the local export")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Characteristics match the source datasheet")
	var expected_keywords := ["ADEPTUS ASTARTES", "BATTLELINE", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "INFANTRY"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All six source keywords are retained")
	check(profile.get("ranged", []).size() == 2 and profile.ranged[0].id == "heavy-bolt-rifle" and profile.ranged[1].id == "bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "ceramite-fists", "Default loadout includes Heavy Bolt Rifle, Bolt Pistol and Ceramite Fists")
	check(profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1 and profile.additional_weapon_profiles.ranged[0].id == "heavy-bolter", "The source Heavy Bolter option has a runtime weapon profile")
	check(Catalog.SPECS["heavy-intercessor-squad"].get("current_reference", false), "Heavy Intercessors are admitted into local construction")
	var catalog_choice := Catalog.current_catalog_choice({"id": HI_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 5, "cost": 115}, {"models": 10, "cost": 230}], "Construction exposes only the sourced squad sizes and points")
	check(Roster.POINTS["heavy-intercessor-squad"].get("sizes", {}) == {5: 115, 10: 230}, "Roster pricing retains both source costs")
	var five := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": HI_ID, "models": 5, "copies": 1}]})
	var ten := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": HI_ID, "models": 10, "copies": 1}]})
	var unsupported := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": HI_ID, "models": 6, "copies": 1}]})
	check(five.error.is_empty() and five.total == 115 and ten.error.is_empty() and ten.total == 230 and not unsupported.error.is_empty(), "Roster admission accepts the source sizes and rejects an unsupported six-model unit")

	var expected_leaders := ["apothecary-biologis", "captain-in-gravis-armour", "iron-father-feirros", "marneus-calgar", "tor-garadon"]
	var actual_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if "heavy-intercessor-squad" in LeaderLinks.TARGETS[leader]: actual_leaders.append(leader)
	actual_leaders.sort()
	check(actual_leaders == expected_leaders, "All five source-listed Leader/Support links match the local relation map")

	var state := make_state()
	check(not state.has("error"), "Current-catalog Heavy Intercessors materialize")
	if state.has("error"):
		print("Current Heavy Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find_models(state, 1, "heavy-intercessor-squad")
	var enemy := find_models(state, 2, "intercessor-squad")
	var captain := find_models(state, 1, "captain-in-gravis-armour")
	check(found.models.size() == 5 and found.sergeant >= 0 and enemy.models.size() == 5 and captain.models.size() == 1, "One Sergeant and four Heavy Intercessors materialize with a source-linked Gravis Captain and target unit")
	if found.models.is_empty() or found.sergeant < 0 or enemy.models.is_empty() or captain.models.is_empty():
		print("Current Heavy Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := int(found.squad)
	var expected_loadout := ["bolt-pistol", "heavy-bolt-rifle"]
	expected_loadout.sort()
	for model: int in found.models:
		var record: Dictionary = state.units[model]
		check(int(record.get("movement", -1)) == 5 and int(record.get("max_wounds", -1)) == 3, "Each model has the source Movement and Wounds")
		for keyword: String in expected_keywords: check(Terrain.has_keyword(record, [keyword.to_lower()]), "Each model carries the %s source keyword" % keyword)
		var actual_ranged: Array[String] = []
		for weapon: Dictionary in record.get("ranged_weapons", []): actual_ranged.append(str(weapon.get("id", "")))
		actual_ranged.sort()
		check(actual_ranged == expected_loadout and record.get("melee_weapons", []).size() == 1 and record.melee_weapons[0].id == "ceramite-fists", "Each model starts with its exact source-listed weapons")
	check(state.squads[squad].stats.toughness == 6 and state.squads[squad].stats.save_target == 3 and state.squads[squad].stats.leadership_target == 6 and state.squads[squad].stats.objective_control == 2, "Materialized squad characteristics match the local source")
	check(C.UnitActions.attachment_allowed(state, int(captain.models[0]), squad), "A Captain in Gravis Armour can attach to the source-listed Heavy Intercessors")
	check(C.UnitAbilities.has(state, squad, "unyielding-in-the-face-of-the-foe"), "Unyielding in the Face of the Foe is registered on this unit")
	check_weapon_profile(state, squad, found.sergeant, enemy.squad, "bolt-pistol")
	check_weapon_profile(state, squad, found.sergeant, enemy.squad, "heavy-bolt-rifle")
	check_weapon_profile(state, squad, found.sergeant, enemy.squad, "ceramite-fists")

	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var initial_options: Array = U.choices(state, 1)
	var eligible: Array[int] = []
	for model: int in found.models:
		if model != found.sergeant and not option_for(initial_options, model).is_empty(): eligible.append(model)
	check(eligible.size() == 4 and option_for(initial_options, found.sergeant).is_empty(), "The five-model option is offered to its four non-Sergeants and excludes the Sergeant")
	if eligible.size() < 2:
		print("Current Heavy Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var selected_model := eligible[0]
	var heavy_bolter_choice := option_for(U.choices(state, 1), selected_model)
	var before_rejected_choice := var_to_bytes(state)
	var wrong_owner := submit_choice(state, 2, heavy_bolter_choice)
	var forged_sergeant := heavy_bolter_choice.duplicate(true)
	forged_sergeant.model = found.sergeant
	var wrong_model := submit_choice(state, 1, forged_sergeant)
	var stale_decision := C.UnitActions.pending_decision(state)
	var stale_choice := submit_choice(state, 1, heavy_bolter_choice, str(stale_decision.get("decision_id", "")), "stale-option-id")
	check(not wrong_owner.get("error", "").is_empty() and not wrong_model.get("error", "").is_empty() and not stale_choice.get("error", "").is_empty() and before_rejected_choice == var_to_bytes(state), "Wrong-owner, Sergeant-only and stale option commands are rejected without changing loadout")
	var replacement := submit_choice(state, 1, heavy_bolter_choice)
	check(str(replacement.get("error", "")).is_empty() and state.units[selected_model].get("heavy_intercessor_heavy_bolter", false), "Public setup equips one legal Heavy Bolter replacement")
	check_weapon_profile(state, squad, selected_model, enemy.squad, "heavy-bolter")
	check(state.units[selected_model].ranged_weapons.size() == 2 and state.units[selected_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "heavy-bolter") and state.units[selected_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "bolt-pistol"), "The Heavy Bolter replaces only the Heavy Bolt Rifle")
	for model: int in found.models:
		if model == selected_model: continue
		check(state.units[model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "heavy-bolt-rifle"), "The Heavy Bolter choice does not change other models")
	check(option_for(U.choices(state, 1), eligible[1]).is_empty(), "A five-model unit cannot exceed one Heavy Bolter")
	var forged_limit := heavy_bolter_choice.duplicate(true)
	forged_limit.model = eligible[1]
	var limit_state := var_to_bytes(state)
	var limit_rejection := U.apply(state, 1, forged_limit, Vector2.ZERO, func() -> int: return 1)
	check(not str(limit_rejection.get("error", "")).is_empty() and limit_state == var_to_bytes(state), "The setup validator rejects a forged second replacement at five models")
	var restore := option_for(U.choices(state, 1), selected_model, "off")
	check(not restore.is_empty() and str(submit_choice(state, 1, restore).get("error", "")).is_empty() and state.units[selected_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "heavy-bolt-rifle"), "The public setup restores the Heavy Bolt Rifle")

	var own_objective := {"kind": "marker", "position": state.units[selected_model].position, "controller": 1, "secured": 0}
	state.mission.objectives = [own_objective]
	Objectives.resolve_control(state, Callable(C.Morale, "objective_control"))
	check(squad in Objectives.controlling_squads(state, state.mission.objectives[0], Callable(C.Morale, "objective_control")) and C.UnitAbilities.save_bonus(state, squad, Callable(C.Morale, "objective_control")) == 1, "Unyielding grants +1 to saves while this squad contributes to a friendly-controlled objective")
	DamageAllocation.start(state, {"targets": [squad]}, enemy.squad, 2, [], false)
	var protected_save := DamageAllocation.save_roll_outcome(state, {"weapon": {"ap": 0}}, selected_model, 2)
	check(state.pending_attack.ability_saves[squad] == 1 and protected_save.success and protected_save.armour_target == 2, "The attack save resolver applies Unyielding to a 2+ armour save while the unit controls an objective")
	state.mission.objectives = [{"kind": "marker", "position": Vector2(100, 100), "controller": 0, "secured": 0}]
	Objectives.resolve_control(state, Callable(C.Morale, "objective_control"))
	DamageAllocation.start(state, {"targets": [squad]}, enemy.squad, 2, [], false)
	var unprotected_save := DamageAllocation.save_roll_outcome(state, {"weapon": {"ap": 0}}, selected_model, 2)
	check(state.pending_attack.ability_saves[squad] == 0 and not unprotected_save.success and unprotected_save.armour_target == 3, "Being away from a friendly-controlled objective does not grant the save bonus")

	var ten_state := make_state(10)
	check(not ten_state.has("error"), "Ten-model Heavy Intercessor construction materializes")
	if not ten_state.has("error"):
		ten_state.phase = "deployment"
		ten_state.unit_abilities.setup_players = []
		var ten_found := find_models(ten_state, 1, "heavy-intercessor-squad")
		var ten_eligible: Array[int] = []
		for model: int in ten_found.models:
			if model != ten_found.sergeant and not option_for(U.choices(ten_state, 1), model).is_empty(): ten_eligible.append(model)
		check(ten_found.models.size() == 10 and ten_eligible.size() == 9, "Ten-model composition has one Sergeant and nine eligible Heavy Bolter bearers")
		if ten_eligible.size() >= 3:
			var third_choice := option_for(U.choices(ten_state, 1), ten_eligible[2])
			for index in [0, 1]:
				var choice := option_for(U.choices(ten_state, 1), ten_eligible[index])
				check(not choice.is_empty() and str(submit_choice(ten_state, 1, choice).get("error", "")).is_empty(), "Ten-model unit accepts Heavy Bolter %d of 2" % (index + 1))
			check(option_for(U.choices(ten_state, 1), ten_eligible[2]).is_empty(), "Ten-model unit is capped at two Heavy Bolters")
			var forged_third := third_choice.duplicate(true)
			var ten_before_rejection := var_to_bytes(ten_state)
			var third_rejection := U.apply(ten_state, 1, forged_third, Vector2.ZERO, func() -> int: return 1)
			check(not str(third_rejection.get("error", "")).is_empty() and ten_before_rejection == var_to_bytes(ten_state), "The setup validator rejects a forged third Heavy Bolter at ten models")
	else:
		check(false, "Ten-model Heavy Intercessor squad materializes: " + str(ten_state.error))

	print("Current Heavy Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

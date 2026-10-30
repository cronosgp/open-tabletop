extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detection_rules.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")

const INFILTRATOR_ID := "40kdc:11e:adeptus-astartes:infiltrator-squad"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const PHOBOS_LIEUTENANT_ID := "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour"
const PHOBOS_LIBRARIAN_ID := "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour"
const PHOBOS_CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain-in-phobos-armour"
const CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain"
const EXPECTED_WEAPONS := {
	"marksman-bolt-carbine": {"range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 1, "precision": true}},
	"bolt-pistol": {"range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"ceramite-fists": {"range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(infiltrator_models: int = 5) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": INFILTRATOR_ID, "models": infiltrator_models, "copies": 1},
		{"definition_id": PHOBOS_LIEUTENANT_ID, "models": 1, "copies": 1},
		{"definition_id": PHOBOS_LIBRARIAN_ID, "models": 1, "copies": 1},
		{"definition_id": PHOBOS_CAPTAIN_ID, "models": 1, "copies": 1},
		{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1}]
	result[2].entries = [
		{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 10, "copies": 1}]
	return result

func make_state(infiltrator_models: int = 5) -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections(infiltrator_models))
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
	return state

func find_units(state: Dictionary) -> Dictionary:
	var found := {"infiltrator": -1, "infiltrator_models": [], "sergeant": -1, "enemy": -1, "enemy_model": -1, "enemy_ten": -1, "lieutenant": -1, "librarian": -1, "phobos_captain": -1, "captain": -1}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var identity := C.UnitAbilities.identity(unit)
		match identity:
			"infiltrator-squad":
				if unit.owner == 1:
					found.infiltrator = unit.squad
					found.infiltrator_models.append(model)
					if unit.get("sergeant", false): found.sergeant = model
			"intercessor-squad":
				if unit.owner == 2:
					if int(state.squads[unit.squad].starting_strength) == 5 and found.enemy < 0:
						found.enemy = unit.squad
						found.enemy_model = model
					if int(state.squads[unit.squad].starting_strength) == 10: found.enemy_ten = unit.squad
			"lieutenant-in-phobos-armour": found.lieutenant = model
			"librarian-in-phobos-armour": found.librarian = model
			"captain-in-phobos-armour": found.phobos_captain = model
			"captain": found.captain = model
	return found

func place_test_units(state: Dictionary, found: Dictionary, enemy_x: float = 8.0) -> void:
	var enemy_counts: Dictionary = {}
	var infiltrator_counts: Dictionary = {}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1 and unit.squad == found.infiltrator:
			var index := int(infiltrator_counts.get(unit.squad, 0))
			unit.position = Vector2(-5, (index - 2) * 1.4)
			infiltrator_counts[unit.squad] = index + 1
		elif unit.owner == 2:
			var index := int(enemy_counts.get(unit.squad, 0))
			var x := enemy_x if unit.squad == found.enemy else enemy_x + 7.0
			unit.position = Vector2(x, (index - 2) * 1.4)
			enemy_counts[unit.squad] = index + 1
		else:
			unit.position = Vector2(-15, 9 + float(model % 3) * 1.4)

func option(state: Dictionary, player: int, action: String, target: int = -999, model: int = -999, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action != action: continue
		if target != -999 and int(item.target) != target: continue
		if model != -999 and int(item.model) != model: continue
		if not value.is_empty() and str(item.value) != value: continue
		return item
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable(), revision: int = -2147483648, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		if int(decision.get("priority_player_id", -1)) != player: return {"error": "The current decision belongs to another player."}
		var projected: Dictionary = {}
		for candidate: Dictionary in decision.get("legal_options", []):
			if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
				projected = candidate
				break
		if projected.is_empty(): return {"error": "The selected choice is not in the current public decision."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	var command_revision := int(state.revision) if revision == -2147483648 else revision
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": command_revision, "choice": payload, "point": point}, roller)

func check_attack_profile(state: Dictionary, squad: int, model: int, target: int, melee: bool, weapon_id: String) -> void:
	var selected := Equipment.select(state, model, melee, weapon_id, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is available to the Infiltrator model" % weapon_id)
	if not str(selected.get("error", "")).is_empty(): return
	var expected: Dictionary = EXPECTED_WEAPONS[weapon_id]
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the verified export" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s retains its complete source keyword set" % weapon_id)
	var old_phase: String = state.phase
	var old_position: Vector2 = state.units[model].position
	var amount := int(selected.stats.attacks) if melee else 1
	if melee:
		state.phase = "fight"
		var targets: Array[int] = C.living(state, target)
		if not targets.is_empty(): state.units[model].position = state.units[targets[0]].position
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
	state.phase = old_phase
	state.units[model].position = old_position
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1, "%s routes through the shared AttackPlan: %s" % [weapon_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan retains the Infiltrator weapon identity")

func count_helix_bearers(state: Dictionary, models: Array) -> int:
	var count := 0
	for model: int in models:
		if state.units[model].get("helix_gauntlet", false): count += 1
	return count

func run() -> void:
	var profile := Profiles.profile("infiltrator-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000128" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Infiltrator Squad is linked to the local shared-book Wahapedia sheet")
	check(profile.models == 5 and profile.points_by_models == {5: 85, 10: 150} and is_equal_approx(profile.base_radius_inches, 16.0 / 25.4), "Five/ten-model prices and 32 mm bases match the export")
	check(profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Movement, Toughness, Save, Wounds, Leadership and OC match the export")
	check(profile.keywords.size() == 6 and "INFANTRY" in profile.keywords and "EXPLOSIVES" in profile.keywords and "IMPERIUM" in profile.keywords and "PHOBOS" in profile.keywords and "SMOKE" in profile.keywords and "ADEPTUS ASTARTES" in profile.keywords, "All six datasheet keywords match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].id == "marksman-bolt-carbine" and profile.ranged[1].id == "bolt-pistol" and profile.melee.size() == 1 and profile.melee[0].id == "ceramite-fists", "All three default weapons match the sheet loadout")
	var spec: Dictionary = Army.SPECS.get("infiltrator-squad", {})
	check(spec.get("current_reference", false), "Infiltrator Squad is an admitted current local profile")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": INFILTRATOR_ID, "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": INFILTRATOR_ID, "models": 10, "copies": 1}]})
	var invalid := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": INFILTRATOR_ID, "models": 6, "copies": 1}]})
	check(five.error.is_empty() and five.total == 85 and ten.error.is_empty() and ten.total == 150 and not invalid.error.is_empty(), "Construction admits only the source five/ten-model sizes at 85/150 points")
	var catalog := Catalog.new()
	root.add_child(catalog)
	catalog.select_edition("11e")
	check(catalog.contains(INFILTRATOR_ID), "The consolidated local catalog exposes Infiltrator Squad")
	catalog.queue_free()
	await process_frame
	var state := make_state()
	check(not state.has("error"), "Current Space Marines catalogs materialize the match on both sides")
	if state.has("error"):
		print("Infiltrator Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find_units(state)
	check(found.infiltrator >= 0 and found.infiltrator_models.size() == 5 and found.sergeant >= 0 and found.enemy >= 0 and found.enemy_ten >= 0 and found.lieutenant >= 0 and found.librarian >= 0 and found.phobos_captain >= 0 and found.captain >= 0, "Five-model squad, 5/10 Intercessor targets and linked Leader profiles materialize from the current catalog")
	for model: int in found.infiltrator_models:
		var unit: Dictionary = state.units[model]
		var squad_stats: Dictionary = state.squads[unit.squad].stats
		check(is_equal_approx(float(unit.radius), 16.0 / 25.4) and unit.movement == 8 and squad_stats.toughness == 4 and squad_stats.save_target == 3 and unit.max_wounds == 2 and squad_stats.leadership_target == 6 and C.Morale.objective_control(state, model) == 1, "Materialized Infiltrator model facts match the source profile")
		check(unit.keywords == profile.keywords and D.infiltrators(state, found.infiltrator), "Each living Infiltrator carries the source keywords and retains the placement ability")
		check(unit.ranged_weapons.size() == 2 and unit.ranged_weapons[0].id == "marksman-bolt-carbine" and unit.ranged_weapons[1].id == "bolt-pistol" and unit.melee_weapons.size() == 1 and unit.melee_weapons[0].id == "ceramite-fists", "Each model starts with the full default wargear set")
	check(C.UnitAbilities.has(state, found.infiltrator, "infiltrators") and C.UnitAbilities.has(state, found.infiltrator, "omni-scramblers") and not C.UnitAbilities.has(state, found.infiltrator, "helix-gauntlet"), "Infiltrators and Omni-Scramblers register while optional Helix remains unequipped")
	check(C.UnitActions.attachment_allowed(state, found.lieutenant, found.infiltrator) and C.UnitActions.attachment_allowed(state, found.librarian, found.infiltrator) and C.UnitActions.attachment_allowed(state, found.phobos_captain, found.infiltrator), "Lieutenant, Librarian and Captain in Phobos Armour match all three source Leader links")
	check(not C.UnitActions.attachment_allowed(state, found.captain, found.infiltrator), "A generic Captain is not admitted as an Infiltrator Leader")
	var ten_state := make_state(10)
	var ten_found := find_units(ten_state)
	check(not ten_state.has("error") and ten_found.infiltrator_models.size() == 10 and int(ten_state.squads[ten_found.infiltrator].starting_strength) == 10 and int(ten_state.squads[ten_found.infiltrator].training_cost) == 150, "The source ten-model composition materializes at its exact 150-point cost")
	place_test_units(state, found)
	state.phase = "shooting"
	state.active = 1
	for weapon: Dictionary in profile.ranged: check_attack_profile(state, found.infiltrator, found.infiltrator_models[0], found.enemy, false, str(weapon.id))
	for weapon: Dictionary in profile.melee: check_attack_profile(state, found.infiltrator, found.infiltrator_models[0], found.enemy, true, str(weapon.id))

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var helix_choices: Array[int] = []
	for candidate: Dictionary in C.unit_choices(state, 1):
		if candidate.action == "helix-bearer" and candidate.target == found.infiltrator and candidate.value == "on": helix_choices.append(int(candidate.model))
	helix_choices.sort()
	var expected_models: Array[int] = []
	for model: int in found.infiltrator_models: expected_models.append(model)
	expected_models.sort()
	check(helix_choices == expected_models, "Army preparation presents exactly one individual Helix Gauntlet option for each Infiltrator")
	var first_helix := option(state, 1, "helix-bearer", found.infiltrator, found.infiltrator_models[0], "on")
	var second_helix := option(state, 1, "helix-bearer", found.infiltrator, found.infiltrator_models[1], "on")
	check(not first_helix.is_empty() and not second_helix.is_empty(), "The player can choose which individual carries the optional Helix")
	if not first_helix.is_empty() and not second_helix.is_empty():
		check(submit_choice(state, 1, first_helix).get("error", "").is_empty() and count_helix_bearers(state, found.infiltrator_models) == 1 and state.units[first_helix.model].helix_gauntlet, "The public setup command equips exactly the selected bearer")
		check(C.UnitAbilities.has(state, found.infiltrator, "helix-gauntlet"), "The selected bearer activates the conditional Helix ability")
		second_helix = option(state, 1, "helix-bearer", found.infiltrator, found.infiltrator_models[1], "on")
		check(not second_helix.is_empty() and submit_choice(state, 1, second_helix).get("error", "").is_empty() and count_helix_bearers(state, found.infiltrator_models) == 1 and state.units[second_helix.model].helix_gauntlet and not state.units[first_helix.model].helix_gauntlet, "Moving the optional wargear transfers it to the newly selected model")
		var remove_helix := option(state, 1, "helix-bearer", found.infiltrator, found.infiltrator_models[1], "off")
		check(not remove_helix.is_empty() and submit_choice(state, 1, remove_helix).get("error", "").is_empty() and count_helix_bearers(state, found.infiltrator_models) == 0, "The optional Helix can be removed and no bearer remains")
		var restore_helix := option(state, 1, "helix-bearer", found.infiltrator, found.infiltrator_models[0], "on")
		if not restore_helix.is_empty(): submit_choice(state, 1, restore_helix)
	check(C.UnitActions.healing_choices(state, 1).is_empty(), "An unequipped unit has no Helix healing action")

	# Source Infiltrators placement must use whole bases and both enemy-distance checks.
	var deployment_state := make_state()
	var deployment_found := find_units(deployment_state)
	deployment_state.board_size = Vector2(44, 30)
	deployment_state.deployment = {"order": [deployment_found.infiltrator], "index": 0, "placed": {}, "committed": [], "zones": {1: Rect2(-22, -15, 8, 30), 2: Rect2(14, -15, 8, 30)}, "complete": false}
	deployment_state.units[deployment_found.enemy_model].position = Vector2(17, 0)
	deployment_state.deployment.placed[deployment_found.enemy_model] = true
	var placement_model: int = deployment_found.infiltrator_models[0]
	var legal_position := Deployment.position_error(deployment_state, placement_model, Vector2(0, -8))
	var enemy_zone_distance := Deployment.position_error(deployment_state, placement_model, Vector2(6.0 - float(deployment_state.units[placement_model].radius), -8))
	deployment_state.units[deployment_found.enemy_model].position = Vector2(8, -8)
	var enemy_model_distance := Deployment.position_error(deployment_state, placement_model, Vector2(0, -8))
	var board_edge := Deployment.position_error(deployment_state, placement_model, Vector2(-21.8, -8))
	check(legal_position.is_empty() and not enemy_zone_distance.is_empty() and not enemy_model_distance.is_empty() and not board_edge.is_empty(), "Infiltrators placement enforces more than 8 inches from enemy zone/models and fits the whole base on the board")
	deployment_state.deployment.order = [deployment_found.enemy]
	var ordinary_deployment := Deployment.position_error(deployment_state, deployment_found.enemy_model, Vector2(0, -8))
	check(not ordinary_deployment.is_empty(), "Intercessors without Infiltrators cannot be placed outside their deployment zone")
	var attached_state := make_state()
	var attached_found := find_units(attached_state)
	if C.UnitActions.attachment_allowed(attached_state, attached_found.lieutenant, attached_found.infiltrator): C.UnitActions.attach(attached_state, attached_found.lieutenant, attached_found.infiltrator)
	check(D.infiltrators(attached_state, attached_found.infiltrator), "A source-linked Phobos Lieutenant preserves the attached squad's all-model Infiltrators eligibility")

	# Helix uses the Core Rules unit-healing sequence for living wounds and model returns.
	check(C.UnitActions.attachment_allowed(state, found.lieutenant, found.infiltrator), "The source-linked Lieutenant can attach before the healing interaction")
	if C.UnitActions.attachment_allowed(state, found.lieutenant, found.infiltrator): C.UnitActions.attach(state, found.lieutenant, found.infiltrator)
	state.phase = "command"
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Doctrines.select_doctrine(state, 1, "none")
	var healing_character: int = found.lieutenant
	state.units[healing_character].wounds = 2
	state.units[healing_character].position = Vector2(-5, -4.2)
	var already_destroyed: int = found.infiltrator_models[1]
	state.units[already_destroyed].wounds = 0
	var heal_choice := option(state, 1, "helix-heal")
	check(not heal_choice.is_empty(), "A living Helix bearer can offer a Command-phase heal for the attached unit")
	if not heal_choice.is_empty():
		var heal_begin := submit_choice(state, 1, heal_choice, func() -> int: return 6)
		check(heal_begin.get("error", "").is_empty() and state.unit_abilities.window.total == 3 and state.unit_abilities.window.ability_name == "Helix Gauntlet" and state.units[healing_character].wounds == 2, "Helix rolls D3 through the public command and previews before changing wounds")
		var return_position: Vector2 = state.units[already_destroyed].position
		var return_choice := option(state, 1, "heal-revive", -999, already_destroyed)
		check(not return_choice.is_empty() and state.unit_abilities.window.remaining == 1, "Helix heals the living Character first and then offers one destroyed non-Character model")
		if not return_choice.is_empty():
			var return_result := submit_choice(state, 1, return_choice, Callable(), -2147483648, return_position)
			check(return_result.get("error", "").is_empty(), "Helix accepts a legal returned-model placement: " + str(return_result.get("error", "")))
		var confirmation := option(state, 1, "heal-confirm")
		check(not confirmation.is_empty() and submit_choice(state, 1, confirmation).get("error", "").is_empty() and state.units[healing_character].wounds == 4 and state.unit_abilities.last_healing.discarded == 0 and state.unit_abilities.last_healing.returned.has(already_destroyed) and state.units[already_destroyed].wounds == 1, "Helix heals the Character, returns one non-Character and accounts for the complete budget")
		check(C.UnitActions.healing_choices(state, 1).is_empty(), "Helix cannot be used twice in the same Command phase")

	var dead_bearer_state := make_state()
	var dead_bearer_found := find_units(dead_bearer_state)
	dead_bearer_state.units[dead_bearer_found.infiltrator_models[0]].helix_gauntlet = true
	dead_bearer_state.units[dead_bearer_found.infiltrator_models[0]].wounds = 0
	dead_bearer_state.units[dead_bearer_found.infiltrator_models[1]].wounds = 1
	dead_bearer_state.phase = "command"
	dead_bearer_state.active = 1
	dead_bearer_state.unit_abilities.setup_players = [1, 2]
	dead_bearer_state.unit_abilities.phase_key = C.UnitActions.key(dead_bearer_state)
	check(C.UnitActions.healing_choices(dead_bearer_state, 1).is_empty(), "A destroyed Helix bearer cannot activate the ability")

	var destroyed_only_state := make_state()
	var destroyed_only_found := find_units(destroyed_only_state)
	place_test_units(destroyed_only_state, destroyed_only_found)
	destroyed_only_state.units[destroyed_only_found.infiltrator_models[0]].wounds = 0
	destroyed_only_state.units[destroyed_only_found.infiltrator_models[1]].helix_gauntlet = true
	destroyed_only_state.phase = "command"
	destroyed_only_state.active = 1
	destroyed_only_state.unit_abilities.setup_players = [1, 2]
	destroyed_only_state.unit_abilities.phase_key = C.UnitActions.key(destroyed_only_state)
	C.Doctrines.select_doctrine(destroyed_only_state, 1, "none")
	var destroyed_only_heal := option(destroyed_only_state, 1, "helix-heal")
	check(not destroyed_only_heal.is_empty(), "A surviving Helix bearer can heal a unit with a destroyed model and no living wounds")
	if not destroyed_only_heal.is_empty():
		var destroyed_model: int = destroyed_only_found.infiltrator_models[0]
		var return_position: Vector2 = destroyed_only_state.units[destroyed_model].position
		check(submit_choice(destroyed_only_state, 1, destroyed_only_heal, func() -> int: return 6).get("error", "").is_empty() and destroyed_only_state.unit_abilities.window.total == 3, "Helix opens its D3 unit-healing budget when a non-Character can return")
		var return_choice := option(destroyed_only_state, 1, "heal-revive", -999, destroyed_model)
		check(not return_choice.is_empty() and submit_choice(destroyed_only_state, 1, return_choice, Callable(), -2147483648, return_position).get("error", "").is_empty(), "Helix returns a destroyed non-Character with legal placement")
		var confirmation := option(destroyed_only_state, 1, "heal-confirm")
		check(not confirmation.is_empty() and submit_choice(destroyed_only_state, 1, confirmation).get("error", "").is_empty() and destroyed_only_state.units[destroyed_model].wounds == 2 and destroyed_only_state.unit_abilities.last_healing.discarded == 1, "Helix heals the returned model to its 2-wound maximum and discards excess after no further model can return")

	# Omni-scramblers marks a visible enemy for this Shooting phase only.
	var omni_state := make_state()
	var omni_found := find_units(omni_state)
	place_test_units(omni_state, omni_found)
	omni_state.phase = "shooting"
	omni_state.active = 1
	omni_state.unit_abilities.phase_key = C.UnitActions.key(omni_state)
	var enemy_model: int = C.living(omni_state, omni_found.enemy)[0]
	var detection_before: float = D.detection_range(omni_state, enemy_model, false)
	var omni_choice := option(omni_state, 1, "omni-scramblers", omni_found.enemy)
	check(not omni_choice.is_empty(), "Omni-scramblers offers a visible enemy within 18 inches")
	if not omni_choice.is_empty():
		var omni_result := submit_choice(omni_state, 1, omni_choice)
		check(omni_result.get("error", "").is_empty() and is_equal_approx(D.detection_range(omni_state, enemy_model, false), detection_before + 3.0), "The public Omni choice increases the target's detection range by 3 inches")
		check(C.UnitActions.omni_choices(omni_state, 1).is_empty() and not omni_state.squads[omni_found.infiltrator].shot and omni_state.cp[1] == 0, "The unit cannot repeat the mark this phase and Omni consumes neither a shot nor CP")
		omni_state.unit_abilities.optics = {"mode": "detect", "target": omni_found.enemy, "squad": omni_found.infiltrator, "phase_key": C.UnitActions.key(omni_state)}
		check(is_equal_approx(D.detection_range(omni_state, enemy_model, false), detection_before + 9.0), "Omni's +3 inches combines with the separate Optics +6-inch effect")
	omni_state.phase = "charge"
	check(is_equal_approx(D.detection_range(omni_state, enemy_model, false), detection_before), "Detected status expires when the Shooting phase ends")

	var far_omni_state := make_state()
	var far_omni_found := find_units(far_omni_state)
	place_test_units(far_omni_state, far_omni_found, 16)
	far_omni_state.phase = "shooting"
	far_omni_state.active = 1
	far_omni_state.unit_abilities.phase_key = C.UnitActions.key(far_omni_state)
	check(C.UnitActions.omni_choices(far_omni_state, 1).is_empty(), "Omni offers no target when every enemy is beyond 18 inches")

	var hidden_state := make_state()
	var hidden_found := find_units(hidden_state)
	place_test_units(hidden_state, hidden_found)
	for model: int in C.living(hidden_state, hidden_found.enemy): hidden_state.units[model].position = Vector2(13, 0)
	hidden_state.terrain.id = "infiltrator-visibility-test"
	hidden_state.terrain.areas = [{"name": "Hidden target", "category": "light", "bounds": Rect2(10, -3, 6, 6), "features": [{"bounds": Rect2(12.9, -0.1, 0.2, 0.2), "height": 0.1, "blocks_end": false}]}]
	hidden_state.phase = "shooting"
	hidden_state.active = 1
	hidden_state.unit_abilities.phase_key = C.UnitActions.key(hidden_state)
	var hidden_target: int = C.living(hidden_state, hidden_found.enemy)[0]
	var hidden_sight: Dictionary = Terrain.pair(hidden_state, hidden_found.infiltrator_models[2], hidden_target)
	check(Terrain.hidden(hidden_state, hidden_target) and not hidden_sight.visible and C.UnitActions.omni_choices(hidden_state, 1).is_empty(), "Omni cannot create visibility for a target hidden beyond current detection")

	var decision_state := make_state()
	var decision_found := find_units(decision_state)
	place_test_units(decision_state, decision_found)
	decision_state.phase = "shooting"
	decision_state.active = 1
	decision_state.unit_abilities.phase_key = C.UnitActions.key(decision_state)
	var decision_choice := option(decision_state, 1, "omni-scramblers", decision_found.enemy)
	var before_rejections := var_to_bytes(decision_state)
	var wrong_owner := submit_choice(decision_state, 2, decision_choice)
	var stale_choice := submit_choice(decision_state, 1, decision_choice, Callable(), int(decision_state.revision) - 1)
	check(not decision_choice.is_empty() and not wrong_owner.get("error", "").is_empty() and not stale_choice.get("error", "").is_empty() and before_rejections == var_to_bytes(decision_state), "Wrong-owner and stale Omni commands are rejected without mutation")

	print("Infiltrator Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

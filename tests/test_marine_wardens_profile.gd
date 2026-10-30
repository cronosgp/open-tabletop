extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func submit_choice(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload := selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
		if projected.is_empty(): return {"error": "The selected choice is not in the current Strategium decision."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": payload})

func act(state: Dictionary, player: int, action: String, target: int = -999, point: Vector2 = Vector2.ZERO) -> String:
	var available: Array = F.C.unit_choices(state, player)
	for option: Dictionary in available:
		if option.action == action and (target == -999 or int(option.target) == target):
			return str(submit_choice(state, player, option, point).get("error", ""))
	return "Missing choice: " + action

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("wardens-of-ultramar")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000004188" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Wardens point to the pinned Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {6: 115} and profile.get("models") == 6 and profile.get("base_size_source_mm", []) == [28.5, 40, 28.5, 28.5, 28.5, 40], "The six-model unit costs 115 points and preserves per-model base sizes")
	var rows: Array[Dictionary] = []
	for index in range(6): rows.append(Profiles.wardens_model_loadout(index))
	var expected_stats := [
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}
	]
	var expected_bases := [28.5, 40.0, 28.5, 28.5, 28.5, 40.0]
	for index in range(6):
		check(rows[index].stats == expected_stats[index] and is_equal_approx(rows[index].base_size_source_mm, expected_bases[index]) and is_equal_approx(rows[index].base_radius_inches, expected_bases[index] / 50.8), "Model %d preserves source characteristics and base size" % index)
	check(rows[2].keywords == ["PSYKER"] and rows[0].keywords.is_empty() and rows[1].keywords.is_empty() and rows[3].keywords.is_empty() and rows[4].keywords.is_empty() and rows[5].keywords.is_empty(), "Only Dainal has the source-listed model-specific PSYKER keyword")
	check(not profile.keywords.has("CHARACTER") and "EPIC HERO" in profile.keywords, "Source keywords do not invent CHARACTER for this datasheet")

	var expected_weapons := {
		"archeotech-laspistol:standard": {"name": "Archeotech Laspistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
		"bolt-rifle:focused-fire": {"name": "Bolt Rifle - Focused Fire", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 1}},
		"bolt-rifle:saturation": {"name": "Bolt Rifle - Saturation", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "rapid-fire": 1}},
		"astropathic-blast:standard": {"name": "Astropathic Blast", "range_inches": 12.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"psychic": true, "blast": 1}},
		"heavy-bolt-pistol:standard": {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
		"ceramite-fists:standard": {"name": "Ceramite Fists", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}},
		"force-stave:standard": {"name": "Force Stave", "range_inches": 0.0, "attacks": 1, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"psychic": true}},
		"master-crafted-power-weapon:standard": {"name": "Master-crafted Power Weapon", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"precision": true}},
		"power-weapon:standard": {"name": "Power Weapon", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 4, "ap": -2, "damage": 1, "keywords": {}},
		"ultramarian-combat-weapons:standard": {"name": "Ultramarian Combat Weapons", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}
	}
	var source_weapon_ids: Dictionary = {}
	for row: Dictionary in rows:
		for melee: bool in [false, true]:
			var loadout_weapons: Array = row.melee if melee else row.ranged
			for weapon: Dictionary in loadout_weapons:
				for profile_id: String in weapon.profiles:
					var key := "%s:%s" % [str(weapon.id), profile_id]
					source_weapon_ids[key] = true
					check(expected_weapons.has(key) and weapon.profiles[profile_id] == expected_weapons.get(key, {}), "Source weapon %s matches its exact exported profile" % key)
	check(source_weapon_ids.size() == expected_weapons.size(), "Every source weapon and Bolt Rifle profile has an explicit expected record")

	var selections := F.current_marine_selections()
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 1})
	var state := Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Both players materialize from current Space Marines catalogs with Wardens in the friendly roster")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var squad := -1
	var warden_models: Array[int] = [-1, -1, -1, -1, -1, -1]
	var enemy_squad := -1
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.owner) == 1 and Abilities.identity(unit) == "wardens-of-ultramar":
			squad = int(unit.squad)
			warden_models[int(unit.get("wardens_model", -1))] = model
		if int(unit.owner) == 2 and Abilities.identity(unit) == "intercessor-squad" and enemy_squad < 0: enemy_squad = int(unit.squad)
	var all_wardens_found := true
	for model: int in warden_models: all_wardens_found = all_wardens_found and model >= 0
	check(squad >= 0 and enemy_squad >= 0 and all_wardens_found, "Both sides resolve through the current-catalog match path")
	if squad < 0 or enemy_squad < 0 or not all_wardens_found:
		quit(1)
		return
	check(Abilities.has(state, squad, "support") and Abilities.has(state, squad, "combat-doctrines") and Abilities.has(state, squad, "raise-the-banner") and Abilities.has(state, squad, "strategium-command"), "All four source-listed Wardens abilities register")
	for index in range(6):
		var unit: Dictionary = state.units[warden_models[index]]
		check(int(unit.get("wardens_model", -1)) == index and unit.max_wounds == expected_stats[index].wounds and unit.objective_control == expected_stats[index].objective_control and unit.defense.toughness == expected_stats[index].toughness and unit.defense.save_target == expected_stats[index].save_target and unit.defense.invulnerable_target == expected_stats[index].invulnerable_target, "Materialized model %d retains its source role and personal defense/OC" % index)
		check(is_equal_approx(float(unit.radius), expected_bases[index] / 50.8), "Materialized model %d uses its exact source base radius" % index)
		check(unit.keywords.has("PSYKER") == (index == 2), "Only source model %d receives PSYKER" % index)
		for keyword: String in ["INFANTRY", "EPIC HERO", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "ULTRAMARINES"]: check(unit.keywords.has(keyword), "Wardens model %d retains common keyword %s" % [index, keyword])
	var attached_support: Dictionary = state.duplicate(true)
	var intercessor_bodyguard := -1
	for model: int in attached_support.units:
		if int(attached_support.units[model].owner) == 1 and Abilities.identity(attached_support.units[model]) == "intercessor-squad":
			intercessor_bodyguard = int(attached_support.units[model].squad)
			break
	check(intercessor_bodyguard >= 0 and C.UnitActions.attachment_allowed(attached_support, warden_models[0], intercessor_bodyguard), "The six-model Support unit can join an eligible bodyguard")
	if intercessor_bodyguard >= 0 and C.UnitActions.attachment_allowed(attached_support, warden_models[0], intercessor_bodyguard):
		var original_wardens_squad := int(attached_support.units[warden_models[0]].squad)
		C.UnitActions.attach(attached_support, warden_models[0], intercessor_bodyguard)
		var all_wardens_attached := true
		for model: int in warden_models: all_wardens_attached = all_wardens_attached and int(attached_support.units[model].squad) == intercessor_bodyguard and str(attached_support.units[model].get("attachment_role", "")) == "support"
		check(all_wardens_attached and not attached_support.squads.has(original_wardens_squad) and attached_support.squads[intercessor_bodyguard].starting_strength == 11, "Attaching a multi-model Support transfers the entire source component")
	var defender := Groups.defender(state, squad)
	check(defender.get("error", "") == "" and defender.toughness == 5 and defender.mixed, "Mixed Wardens defense resolves with T5 and model-specific allocation groups")

	check(Catalog.SPECS.has("wardens-of-ultramar") and Catalog.SPECS["wardens-of-ultramar"].get("max_supported_copies", 0) == 1, "Wardens construction uses the one-copy Epic Hero cap")
	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 1}]})
	var two_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 2}]})
	check(one_copy.get("error", "").is_empty() and one_copy.get("total", -1) == 115 and not two_copies.get("error", "").is_empty(), "Wahapedia points and the one-copy construction cap are enforced")
	var expected_supports := ["assault-intercessor-squad", "bladeguard-veteran-squad", "intercessor-squad", "sternguard-veteran-squad"]
	var actual_supports: Array = Supports.BODYGUARDS["wardens-of-ultramar"].duplicate()
	actual_supports.sort()
	expected_supports.sort()
	check(actual_supports == expected_supports, "Wardens expose four common-book Support targets and omit the Legends target")
	check(Supports.matching_error([{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "copies": 1}, {"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "copies": 1}]).is_empty() and not Supports.matching_error([{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "copies": 1}, {"definition_id": "40kdc:11e:necrons:necron-warriors", "copies": 1}]).is_empty(), "Support assignments accept listed units and reject an unlisted faction")

	var weapon_failures: Array[String] = []
	for index in range(6):
		state.units[warden_models[index]].on_battlefield = true
		state.units[warden_models[index]].position = Vector2(-3, -6.0 + float(index) * 2.2)
	for model: int in C.living(state, enemy_squad):
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(16, 0)
	for index in range(6): weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(state, rows[index], warden_models[index], enemy_squad))
	check(weapon_failures.is_empty(), "Every model-specific Wardens weapon profile passes Equipment and AttackPlan: %s" % str(weapon_failures))

	var banner_state: Dictionary = state.duplicate(true)
	banner_state.phase = "movement"
	banner_state.turn = 3
	banner_state.round = 2
	banner_state.active = 1
	banner_state.mission.stage = "battle"
	banner_state.awakened_dynasty.pending = []
	banner_state.deployment.complete = true
	banner_state.unit_abilities.setup_players = [1, 2]
	banner_state.unit_abilities.battle_players = [1, 2]
	banner_state.unit_abilities.window = {}
	banner_state.unit_abilities.phase_key = C.UnitActions.key(banner_state)
	banner_state.mission.objectives = [{"name": "Wardens Banner", "kind": "marker", "position": Vector2.ZERO, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
	for model: int in banner_state.units:
		banner_state.units[model].on_battlefield = true
		banner_state.units[model].position = Vector2.ZERO if int(banner_state.units[model].owner) == 1 and int(banner_state.units[model].squad) == squad else Vector2(20, 20)
	var roll_six := func() -> int: return 6
	check(C.advance_phase(banner_state, 1, banner_state.revision, roll_six).is_empty() and banner_state.mission.objectives[0].controller == 1 and banner_state.mission.objectives[0].secured == 1, "Raise the Banner secures an objective controlled by Wardens at their Movement-phase end")
	var enemy_banner_state: Dictionary = banner_state.duplicate(true)
	enemy_banner_state.mission.objectives[0].secured = 0
	enemy_banner_state.phase = "movement"
	enemy_banner_state.active = 2
	enemy_banner_state.unit_abilities.phase_key = C.UnitActions.key(enemy_banner_state)
	check(C.advance_phase(enemy_banner_state, 2, enemy_banner_state.revision, roll_six).is_empty() and enemy_banner_state.mission.objectives[0].secured == 0, "Raise the Banner does not trigger at the end of the opposing Movement phase")

	var strategium_state: Dictionary = state.duplicate(true)
	strategium_state.phase = "pre_battle"
	strategium_state.deployment.complete = true
	strategium_state.deployment.zones = {1: Rect2(-21.5, -21.5, 18, 43), 2: Rect2(3.5, -21.5, 18, 43)}
	strategium_state.first_player = 1
	strategium_state.unit_abilities.setup_players = [1, 2]
	strategium_state.unit_abilities.battle_players = [1, 2]
	strategium_state.unit_abilities.window = {}
	var placed_squads := {1: 0, 2: 0}
	for current_squad: int in strategium_state.squads:
		var owner := int(strategium_state.squads[current_squad].owner)
		var squad_x := -20.0 + float(placed_squads[owner]) * 4.0 if owner == 1 else 5.0 + float(placed_squads[owner]) * 4.0
		placed_squads[owner] = int(placed_squads[owner]) + 1
		var model_row := 0
		for model: int in C.living(strategium_state, current_squad):
			strategium_state.units[model].on_battlefield = true
			strategium_state.units[model].position = Vector2(squad_x, -16 + float(model_row) * 2.2)
			model_row += 1
	ScoutMoves.begin(strategium_state)
	check(strategium_state.unit_abilities.window.get("kind", "") == "strategium-command" and ScoutMoves.actor(strategium_state) == 1, "Strategium Command starts after deployment and before Scouts")
	var captain_model := -1
	var captain_squad := -1
	for model: int in strategium_state.units:
		if int(strategium_state.units[model].owner) == 1 and Abilities.identity(strategium_state.units[model]) == "captain":
			captain_model = model
			captain_squad = int(strategium_state.units[model].squad)
			break
	var selected_choice: Dictionary = {}
	for option: Dictionary in F.C.unit_choices(strategium_state, 1):
		if option.action == "strategium-select" and int(option.target) == captain_squad: selected_choice = option; break
	var before_wrong_strategium_owner := var_to_bytes(strategium_state)
	var wrong_strategium_owner := submit_choice(strategium_state, 2, selected_choice)
	check(captain_model >= 0 and not selected_choice.is_empty() and not str(wrong_strategium_owner.get("error", "")).is_empty() and before_wrong_strategium_owner == var_to_bytes(strategium_state), "Strategium rejects the other player without state mutation")
	check(act(strategium_state, 1, "strategium-select", captain_squad).is_empty() and act(strategium_state, 1, "strategium-redeploy", captain_squad).is_empty(), "Strategium selects a deployed Astartes unit for normal redeployment")
	check(not act(strategium_state, 1, "strategium-place", captain_squad, Vector2.ZERO).is_empty(), "Normal redeployment enforces the deployment-zone restriction")
	var valid_place_error := act(strategium_state, 1, "strategium-place", captain_squad, Vector2(-18, 10))
	var confirm_error := act(strategium_state, 1, "strategium-confirm", captain_squad) if valid_place_error.is_empty() else "not attempted after rejected placement"
	check(valid_place_error.is_empty() and confirm_error.is_empty(), "Strategium confirms a legal on-field redeployment: %s / %s" % [valid_place_error, confirm_error])
	check(captain_model >= 0 and strategium_state.units[captain_model].position == Vector2(-18, 10) and strategium_state.units[captain_model].on_battlefield, "Normal redeployment commits the confirmed Captain position")
	check(act(strategium_state, 1, "strategium-select", squad).is_empty() and act(strategium_state, 1, "strategium-reserve", squad).is_empty(), "Strategium places the six-model Wardens unit in Strategic Reserves")
	var all_wardens_offboard := true
	for model: int in warden_models: all_wardens_offboard = all_wardens_offboard and not strategium_state.units[model].on_battlefield
	check(strategium_state.unit_abilities.reserves.get(squad, {}).get("source", "") == "strategium-command" and strategium_state.unit_abilities.reserves[squad].get("bypass_limit", false) and all_wardens_offboard, "Strategium records the reserve-limit exception and moves all Wardens off the battlefield")
	var additional_targets: Array[int] = []
	for candidate: int in strategium_state.squads:
		if candidate not in strategium_state.unit_abilities.strategium_used.get(1, []) and int(strategium_state.squads[candidate].owner) == 1 and ScoutMoves._redeploy_target(strategium_state, candidate, "strategium-command"): additional_targets.append(candidate)
	additional_targets.sort()
	check(not additional_targets.is_empty(), "Strategium allows a third distinct deployed Astartes unit")
	if not additional_targets.is_empty():
		var candidate := additional_targets[0]
		check(act(strategium_state, 1, "strategium-select", candidate).is_empty() and act(strategium_state, 1, "strategium-reserve", candidate).is_empty(), "Strategium resolves its third distinct Astartes selection")
	check(int(strategium_state.unit_abilities.strategium_count.get(1, 0)) == 3 and strategium_state.unit_abilities.window.get("kind", "") != "strategium-command", "Strategium stops after three units and proceeds to the next pre-battle step")
	print("Wardens local source and materialization profile: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ArmyCatalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const JUMP_ID := "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
const COMMON_LEADERS := ["captain-with-jump-pack", "chaplain-with-jump-pack", "kayvaan-shrike"]

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		var model_count := 5 if owner == 1 else 10
		var entries: Array = [entry("assault-intercessors-with-jump-packs", model_count), entry("intercessor-squad", 5)]
		for leader: String in COMMON_LEADERS:
			entries.append(entry(leader))
		result[owner].entries = entries
	return result

func fixture() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false,
		"official_mission": false,
		"unit_abilities": true,
		"combat_doctrines": true,
		"core_stratagems": true,
		"manual_allocation": false
	}, selections())

func find_models(state: Dictionary, owner: int, identity: String) -> Dictionary:
	var result := {"squad": -1, "models": [], "sergeant": -1}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity:
			continue
		result.squad = int(unit.squad)
		result.models.append(model)
		if unit.get("sergeant", false):
			result.sergeant = model
	return result

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	var found := find_models(state, owner, identity)
	return int(found.models[0]) if not found.models.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty():
		return {"error": "Choice is not part of the current preparation decision."}
	var payload := {
		"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE,
		"decision_id": str(decision.get("decision_id", "")),
		"option_id": str(projected.get("id", "")),
		"choice": selected
	}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": payload, "revision": int(state.revision)})

func check_weapon_plans(state: Dictionary, model: int, target_squad: int) -> void:
	var unit: Dictionary = state.units[model]
	var profile := {"ranged": unit.get("ranged_weapons", []).duplicate(true), "melee": unit.get("melee_weapons", []).duplicate(true)}
	var plan_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, profile, model, target_squad)
	check(plan_failures.is_empty(), "%s weapon profiles resolve through Equipment and AttackPlan: %s" % [C.UnitAbilities.identity(unit), str(plan_failures)])

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile: Dictionary = Profiles.profile("assault-intercessors-with-jump-packs")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002776", "Runtime profile identifies the shared-book Jump Pack datasheet")
	check(profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Runtime profile retains its original export stamp")
	check(profile.models == 5 and profile.points_by_models == {5: 95, 10: 190} and profile.get("third_plus_points_by_models", {}) == {5: 105, 10: 200}, "Both source compositions and first/second plus third-plus costs match the pinned export")
	check(is_equal_approx(float(profile.base_radius_inches), 16.0 / 25.4), "Every model uses the exported 32 mm base")
	check(profile.stats == {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Profile characteristics match the pinned export")
	var expected_keywords := ["ADEPTUS ASTARTES", "EXPLOSIVES", "FLY", "IMPERIUM", "INFANTRY", "JUMP PACK", "TACTICUS"]
	var actual_keywords: Array = profile.keywords.duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All seven source keywords are retained")
	check(profile.ranged.size() == 1 and profile.ranged[0].id == "heavy-bolt-pistol" and profile.melee.size() == 1 and profile.melee[0].id == "chainsword", "Every model starts with a Heavy Bolt Pistol and Chainsword")
	check(AbilityCatalog.RULES.get("assault-intercessors-with-jump-packs", []) == ["deep-strike", "hammer-of-wrath"], "Deep Strike and Hammer of Wrath are the registered sheet abilities")
	check(ArmyCatalog.resolve("Space Marines", JUMP_ID).get("error", "").is_empty(), "The sheet resolves through the consolidated Space Marines catalog")

	var catalog_choice := ArmyCatalog.current_catalog_choice({"id": JUMP_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [
		{"models": 5, "cost": 95, "third_plus_cost": 105},
		{"models": 10, "cost": 190, "third_plus_cost": 200}
	], "Construction records both source sizes and both copy-cost tiers")
	for item: Dictionary in [
		{"models": 5, "cost": 95},
		{"models": 10, "cost": 190}
	]:
		var admitted := ArmyCatalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("assault-intercessors-with-jump-packs", int(item.models))]})
		check(admitted.get("error", "").is_empty() and int(admitted.get("total", -1)) == int(item.cost), "%d-model source composition is admitted at %d points" % [int(item.models), int(item.cost)])
	var unsupported := ArmyCatalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("assault-intercessors-with-jump-packs", 6)]})
	check(not str(unsupported.get("error", "")).is_empty(), "Construction rejects a six-model size absent from the source")
	var capped := ArmyCatalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": JUMP_ID, "models": 5, "copies": 3}]})
	check(not str(capped.get("error", "")).is_empty(), "Construction holds out a third copy while copy-index-aware pricing is unsupported")

	var state := fixture()
	check(not state.has("error"), "The both-player current-catalog fixture materializes")
	if state.has("error"):
		print("Assault Intercessors With Jump Packs checks: %d failures" % (failures + 1))
		quit(1)
		return
	var player_one := find_models(state, 1, "assault-intercessors-with-jump-packs")
	var player_two := find_models(state, 2, "assault-intercessors-with-jump-packs")
	check(player_one.models.size() == 5 and player_one.sergeant > 0 and player_two.models.size() == 10 and player_two.sergeant > 0, "Both players materialize the exact five- and ten-model compositions with one Sergeant")
	for owner: int in [1, 2]:
		var jump := find_models(state, owner, "assault-intercessors-with-jump-packs")
		for model: int in jump.models:
			var record: Dictionary = state.units[model]
			check(int(record.get("movement", -1)) == 12 and int(record.get("max_wounds", -1)) == 2, "Player %d Jump Intercessors retain source movement and wounds" % owner)
			check(record.get("ranged_weapons", []).size() == 1 and record.ranged_weapons[0].id == "heavy-bolt-pistol" and record.get("melee_weapons", []).size() == 1 and record.melee_weapons[0].id == "chainsword", "Player %d model starts with the fixed source loadout" % owner)
		check(int(state.squads[jump.squad].get("stats", {}).get("objective_control", -1)) == 1, "Player %d squad retains source OC 1" % owner)
		var enemy_squad := int(find_models(state, 3 - owner, "intercessor-squad").squad)
		check(enemy_squad > 0, "Player %d has a current-catalog target for attack planning" % owner)
		for leader: String in COMMON_LEADERS:
			var leader_model := find_model(state, owner, leader)
			check(leader_model > 0 and C.UnitActions.attachment_allowed(state, leader_model, int(jump.squad)), "Player %d source-linked Leader %s can attach" % [owner, leader])
		check(C.UnitAbilities.has(state, int(jump.squad), "deep-strike") and C.UnitAbilities.has(state, int(jump.squad), "hammer-of-wrath"), "Player %d squad receives both source abilities" % owner)

	var common_targets: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if "assault-intercessors-with-jump-packs" in LeaderLinks.TARGETS[leader]: common_targets.append(leader)
	common_targets.sort()
	check(common_targets == ["captain-with-jump-pack", "chaplain-with-jump-pack", "kayvaan-shrike"], "The common-book Leader map contains exactly the three shared-book sources")
	check_weapon_plans(state, int(player_one.sergeant), int(find_models(state, 2, "intercessor-squad").squad))

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var sergeant := int(player_one.sergeant)
	for kind: String in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]:
		var option := choice_for(state, 1, "jump-pack-sergeant-pistol", sergeant, kind)
		check(not option.is_empty(), "Sergeant setup offers the source pistol choice %s" % kind)
		if option.is_empty(): continue
		var result := submit_choice(state, 1, option)
		check(str(result.get("error", "")).is_empty(), "Public preparation accepts Sergeant pistol %s" % kind)
		var expected_id := "heavy-bolt-pistol" if kind == "heavy-bolt-pistol" else kind
		check(state.units[sergeant].ranged_weapons.size() == 1 and state.units[sergeant].ranged_weapons[0].id == expected_id, "Sergeant equips only %s" % expected_id)
		check_weapon_plans(state, sergeant, int(find_models(state, 2, "intercessor-squad").squad))
	for kind: String in ["chainsword", "power-fist", "power-weapon"]:
		var option := choice_for(state, 1, "jump-pack-sergeant-melee", sergeant, kind)
		check(not option.is_empty(), "Sergeant setup offers the source melee choice %s" % kind)
		if option.is_empty(): continue
		var result := submit_choice(state, 1, option)
		check(str(result.get("error", "")).is_empty(), "Public preparation accepts Sergeant melee weapon %s" % kind)
		var expected_id := "chainsword" if kind == "chainsword" else kind
		check(state.units[sergeant].melee_weapons.size() == 1 and state.units[sergeant].melee_weapons[0].id == expected_id, "Sergeant equips only %s" % expected_id)
		check_weapon_plans(state, sergeant, int(find_models(state, 2, "intercessor-squad").squad))

	var five_troopers: Array[int] = []
	for model: int in player_one.models:
		if model != sergeant: five_troopers.append(model)
	var five_plasma_options := 0
	for model: int in five_troopers:
		if not choice_for(state, 1, "jump-pack-trooper-pistol", model, "plasma-pistol").is_empty(): five_plasma_options += 1
	check(five_plasma_options == 4, "A five-model unit can select one of its four ordinary models for the single Plasma Pistol")
	if not five_troopers.is_empty():
		var option := choice_for(state, 1, "jump-pack-trooper-pistol", five_troopers[0], "plasma-pistol")
		check(not option.is_empty() and str(submit_choice(state, 1, option).get("error", "")).is_empty(), "The ordinary-model Plasma Pistol uses the public preparation command")
		check(state.units[five_troopers[0]].ranged_weapons[0].id == "plasma-pistol", "The selected ordinary model receives the Plasma Pistol")
		var additional_options := 0
		for model: int in five_troopers:
			if not choice_for(state, 1, "jump-pack-trooper-pistol", model, "plasma-pistol").is_empty(): additional_options += 1
		check(additional_options == 0, "A five-model unit cannot exceed one ordinary Plasma Pistol")
		var restore := choice_for(state, 1, "jump-pack-trooper-pistol", five_troopers[0], "heavy-bolt-pistol")
		check(not restore.is_empty() and str(submit_choice(state, 1, restore).get("error", "")).is_empty(), "The ordinary model can restore its Heavy Bolt Pistol")
		check(state.units[five_troopers[0]].ranged_weapons[0].id == "heavy-bolt-pistol", "Restoring the fixed pistol clears the optional bearer state")

	state.active = 2
	state.unit_abilities.setup_players = [1]
	var ten_troopers: Array[int] = []
	for model: int in player_two.models:
		if model != player_two.sergeant: ten_troopers.append(model)
	var ten_plasma_options := 0
	for model: int in ten_troopers:
		if not choice_for(state, 2, "jump-pack-trooper-pistol", model, "plasma-pistol").is_empty(): ten_plasma_options += 1
	check(ten_plasma_options == 9, "A ten-model unit may choose any of its nine ordinary models for the first Plasma Pistol")
	if ten_troopers.size() >= 2:
		var first := choice_for(state, 2, "jump-pack-trooper-pistol", ten_troopers[0], "plasma-pistol")
		check(not first.is_empty() and str(submit_choice(state, 2, first).get("error", "")).is_empty(), "Player two equips the first ordinary Plasma Pistol through the public command")
		var second_options: Array[Dictionary] = []
		for model: int in ten_troopers:
			var option := choice_for(state, 2, "jump-pack-trooper-pistol", model, "plasma-pistol")
			if not option.is_empty(): second_options.append(option)
		check(second_options.size() == 8, "The ten-model unit permits exactly one more ordinary Plasma Pistol")
		if not second_options.is_empty():
			check(str(submit_choice(state, 2, second_options[0]).get("error", "")).is_empty(), "Player two equips the second ordinary Plasma Pistol")
			var third_options := 0
			for model: int in ten_troopers:
				if not choice_for(state, 2, "jump-pack-trooper-pistol", model, "plasma-pistol").is_empty(): third_options += 1
			check(third_options == 0, "A ten-model unit cannot exceed two ordinary Plasma Pistols")

	print("Assault Intercessors With Jump Packs checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

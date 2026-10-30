extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "talonstrike-kill-team"
const UNIT_ID := "40kdc:11e:adeptus-astartes:talonstrike-kill-team"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry(UNIT, 10), entry("captain-with-jump-pack"), entry("chaplain-with-jump-pack")]
	result[2].entries = [entry(UNIT, 10), entry("intercessor-squad", 5)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, lists())

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return int(state.units[model].get("squad", -1))
	return -1

func find_model(state: Dictionary, squad: int, identity: String, model_index: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or C.UnitAbilities.identity(unit) != identity: continue
		if model_index < 0 or int(unit.get("talonstrike_kill_team_model", -1)) == model_index: return model
	return -1

func models_for(state: Dictionary, squad: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	return {}

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func has_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> bool:
	return not find_choice(state, owner, action, squad, model, value).is_empty()

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, owner, find_choice(state, owner, action, squad, model, value))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Talonstrike Kill Team" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000003874", "The profile maps to the Deathwatch App Talonstrike datasheet")
	check(profile.get("source_snapshot_id") == "20261029T072022Z" and profile.get("source_manifest_sha256") == "772952e313b6772022c68226514eba7cdde00464468fd79c8291d20c24da4801" and profile.get("source_slice_manifest_sha256") == "14091c1c687942cffa668a3cab4deaf007562f9a4c40c94a7d15893394e85d26", "The current timestamp-bracketed export and clean subject-slice manifests are pinned")
	check(profile.get("points_by_models", {}) == {10: 280} and profile.get("third_plus_points_by_models", {}) == {10: 300} and profile.get("models", 0) == 10 and profile.get("max_supported_copies", 0) == 3, "The fixed ten-model composition, 280/300 point tiers and three-copy cap match the source")
	check(profile.get("base_size_source_mm", []) == [32, 40, 40, 40, 40, 32, 32, 32, 32, 32] and profile.get("base_geometry", "") == "per-model-circles", "The model-order base assignments retain the 32 mm and 40 mm source bases")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "The root characteristic row uses the source-listed Sergeant profile")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 10 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ["sergeant", "heavy-intercessor", "heavy-intercessor", "heavy-intercessor", "heavy-intercessor", "intercessor", "intercessor", "intercessor", "intercessor", "intercessor"], "The ten model roles retain source composition order")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "JUMP PACK", "FLY", "IMPERIUM", "GRAVIS", "TACTICUS"], "All source-listed unit keywords are preserved")
	check(profile_weapon("ranged", "assault-bolters").keywords == {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true} and profile_weapon("ranged", "assault-bolters").range_inches == 18.0, "Assault Bolters retain all four traits and their 18-inch range")
	check(profile_weapon("ranged", "heavy-bolt-pistol").range_inches == 18.0 and profile_weapon("ranged", "plasma-exterminators", "supercharge").get("damage", -1) == 3 and profile_weapon("ranged", "plasma-exterminators", "supercharge").keywords.get("hazardous", false), "The source Heavy Bolt Pistol range and both Plasma Exterminator modes are preserved")
	check(profile_weapon("ranged", "plasma-pistol", "standard").strength == 7 and profile_weapon("ranged", "plasma-pistol", "supercharge").strength == 8 and profile_weapon("ranged", "hand-flamer").keywords.get("torrent", false), "Both Plasma Pistol modes and the Sergeant Hand Flamer are present")
	check(profile_weapon("melee", "ceramite-fists").attacks == 3 and profile_weapon("melee", "chainsword").attacks == 4 and profile_weapon("melee", "power-fist").strength == 8 and profile_weapon("melee", "power-weapon").ap == -2, "All four source melee profiles are represented")
	check(Catalog.SPECS.has(UNIT) and Catalog.SPECS[UNIT].get("max_supported_copies", 0) == 3 and Abilities.RULES.get(UNIT, []) == ["deep-strike", "combat-doctrines", "talonstrike-doctrines"], "Construction admission and the three unit abilities are registered")
	check(CapabilityRegistry.known("talonstrike-doctrines") and CapabilityRegistry.supported("talonstrike-doctrines"), "Talonstrike Doctrines is present in the capability registry")
	check(LeaderLinks.targets("captain-with-jump-pack").has(UNIT) and LeaderLinks.targets("chaplain-with-jump-pack").has(UNIT), "Both source-listed Jump Pack Leaders can lead the team")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 10, "copies": 3}]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 860, "Three copies use the first-two and third-plus source prices")
	check(Profiles.talonstrike_kill_team_model_loadout(0, "thunder-hammer").is_empty() and Profiles.talonstrike_kill_team_model_loadout(1, "chainsword", "heavy-bolt-pistol", true, false).is_empty() and Profiles.talonstrike_kill_team_model_loadout(5, "chainsword", "heavy-bolt-pistol", false, true).is_empty(), "The model helper rejects options on ineligible model roles")

	var state := fresh_state()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Talonstrike materializes in both local Deathwatch rosters: " + state_error)
	if not state_error.is_empty():
		print("Talonstrike Kill Team source-bounded checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT)
	var opposing_squad := find_squad(state, 2, UNIT)
	var target := find_squad(state, 2, "intercessor-squad")
	var talonstrike_models := models_for(state, squad, UNIT)
	var opponent_models := models_for(state, opposing_squad, UNIT)
	check(squad > 0 and target > 0 and talonstrike_models.size() == 10 and opponent_models.size() == 10, "Both players' current catalogs materialize all ten models")
	check(int(state.squads[squad].get("training_cost", -1)) == 280 and int(state.squads[opposing_squad].get("training_cost", -1)) == 280, "The prepared roster applies the source cost for each ten-model unit")
	var expected_ranged := [["heavy-bolt-pistol"], ["assault-bolters"], ["assault-bolters"], ["assault-bolters"], ["assault-bolters"], ["heavy-bolt-pistol"], ["heavy-bolt-pistol"], ["heavy-bolt-pistol"], ["heavy-bolt-pistol"], ["heavy-bolt-pistol"]]
	var expected_melee := [["chainsword"], ["ceramite-fists"], ["ceramite-fists"], ["ceramite-fists"], ["ceramite-fists"], ["chainsword"], ["chainsword"], ["chainsword"], ["chainsword"], ["chainsword"]]
	for model: int in talonstrike_models:
		var index := int(state.units[model].get("talonstrike_kill_team_model", -1))
		var unit: Dictionary = state.units[model]
		var expected_stats: Dictionary = loadouts[index].stats
		check(unit.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))) == expected_ranged[index] and unit.get("melee_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))) == expected_melee[index], "Talonstrike model %d receives its source default wargear" % index)
		check(int(unit.get("movement", -1)) == int(expected_stats.movement_inches) and int(unit.get("max_wounds", -1)) == int(expected_stats.wounds) and int(unit.get("defense", {}).get("toughness", -1)) == int(expected_stats.toughness), "Talonstrike model %d receives its own movement, wounds and Toughness" % index)
		check(is_equal_approx(float(unit.get("radius", 0.0)), float(loadouts[index].base_radius_inches)) and unit.get("keywords", []) == profile.keywords, "Talonstrike model %d keeps its source base and unit keywords" % index)
	check(C.UnitAbilities.has(state, squad, "deep-strike") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "talonstrike-doctrines"), "All source-bound rules are active for the prepared team")
	var captain_squad := find_squad(state, 1, "captain-with-jump-pack")
	var chaplain_squad := find_squad(state, 1, "chaplain-with-jump-pack")
	check(C.UnitActions.attachment_allowed(state, find_model(state, captain_squad, "captain-with-jump-pack"), squad) and C.UnitActions.attachment_allowed(state, find_model(state, chaplain_squad, "chaplain-with-jump-pack"), squad), "Both source-listed Leaders pass the attachment gate")

	var sergeant := find_model(state, squad, UNIT, 0)
	var heavy_one := find_model(state, squad, UNIT, 1)
	var heavy_two := find_model(state, squad, UNIT, 2)
	var heavy_three := find_model(state, squad, UNIT, 3)
	var heavy_four := find_model(state, squad, UNIT, 4)
	var intercessor_one := find_model(state, squad, UNIT, 5)
	var intercessor_two := find_model(state, squad, UNIT, 6)
	var intercessor_three := find_model(state, squad, UNIT, 7)
	check(has_choice(state, 1, "talonstrike-sergeant-melee", squad, sergeant, "power-fist") and has_choice(state, 1, "talonstrike-sergeant-ranged", squad, sergeant, "hand-flamer"), "The Sergeant receives both source replacement groups")
	var changed := choose(state, 1, "talonstrike-sergeant-melee", squad, sergeant, "power-fist")
	check(changed.get("error", "").is_empty() and state.units[sergeant].melee_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["power-fist"], "The public preparation command applies the Sergeant melee replacement")
	changed = choose(state, 1, "talonstrike-sergeant-melee", squad, sergeant, "chainsword")
	check(changed.get("error", "").is_empty() and state.units[sergeant].melee_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["chainsword"], "The Sergeant melee replacement restores its default")
	changed = choose(state, 1, "talonstrike-sergeant-ranged", squad, sergeant, "plasma-pistol")
	check(changed.get("error", "").is_empty() and state.units[sergeant].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["plasma-pistol"], "The Sergeant can replace and restore its Heavy Bolt Pistol")
	changed = choose(state, 1, "talonstrike-sergeant-ranged", squad, sergeant, "heavy-bolt-pistol")
	check(changed.get("error", "").is_empty(), "The Sergeant pistol can be restored")
	var plasma_one := choose(state, 1, "talonstrike-intercessor-plasma-pistol", squad, intercessor_one, "on")
	var plasma_two := choose(state, 1, "talonstrike-intercessor-plasma-pistol", squad, intercessor_two, "on")
	check(plasma_one.get("error", "").is_empty() and plasma_two.get("error", "").is_empty() and not has_choice(state, 1, "talonstrike-intercessor-plasma-pistol", squad, intercessor_three, "on"), "Ten models allow two Intercessor Plasma Pistols and withhold a third")
	var forged_choice := {"action": "talonstrike-intercessor-plasma-pistol", "model": intercessor_three, "target": squad, "value": "on"}
	var before_forged := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forged_choice).is_empty() and before_forged == var_to_bytes(state), "A forged command cannot exceed the per-five-model Plasma Pistol limit")
	changed = choose(state, 1, "talonstrike-intercessor-plasma-pistol", squad, intercessor_one, "off")
	check(changed.get("error", "").is_empty() and has_choice(state, 1, "talonstrike-intercessor-plasma-pistol", squad, intercessor_three, "on"), "Restoring an Intercessor Heavy Bolt Pistol releases that model-count slot")
	for heavy_model: int in [heavy_one, heavy_two, heavy_three, heavy_four]:
		changed = choose(state, 1, "talonstrike-plasma-exterminator", squad, heavy_model, "on")
		check(changed.get("error", "").is_empty() and state.units[heavy_model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["plasma-exterminators"], "Every Heavy Intercessor can independently replace Assault Bolters with Plasma Exterminators")
	changed = choose(state, 1, "talonstrike-plasma-exterminator", squad, heavy_one, "off")
	check(changed.get("error", "").is_empty() and state.units[heavy_one].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["assault-bolters"], "A Heavy Intercessor can restore Assault Bolters")
	var wrong_owner_option := find_choice(state, 1, "talonstrike-plasma-exterminator", squad, heavy_one, "on")
	var before_wrong_owner := var_to_bytes(state)
	check(not wrong_owner_option.is_empty() and not PublicUnitCommand.error(state, 2, wrong_owner_option).is_empty() and before_wrong_owner == var_to_bytes(state), "The opposing player cannot alter Talonstrike preparation")

	var target_models := models_for(state, target, "intercessor-squad")
	for index: int in talonstrike_models.size(): state.units[talonstrike_models[index]].position = Vector2(0.0, float(index) * 2.0)
	for index: int in target_models.size(): state.units[target_models[index]].position = Vector2(6.0, float(index) * 2.0)
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var assignment := {"model": heavy_one, "target": target, "amount": 1, "weapon": "assault-bolters", "profile": "standard"}
	state.squads[squad].set_up_this_turn = false
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("ap", 99)) == -1, "Talonstrike gains no AP bonus outside its setup turn")
	state.squads[squad].set_up_this_turn = true
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("ap", 99)) == -2, "Talonstrike grants +1 AP to ranged attacks in the turn it was set up")
	state.phase = "fight"
	state.squads[squad].charged = false
	state.units[sergeant].position = Vector2(7.0, 0.0)
	var melee_assignment := {"model": sergeant, "target": target, "amount": 4, "weapon": "chainsword", "profile": "standard"}
	plan = C.AttackPlan.prepare(state, squad, true, [melee_assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("ap", 99)) == -2 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 0, "Setup-turn melee gains +1 AP but Lance does not improve Wound rolls before a Charge")
	state.squads[squad].charged = true
	plan = C.AttackPlan.prepare(state, squad, true, [melee_assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("ap", 99)) == -2 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 1, "After a Charge, setup-turn melee Lance supplies the shared +1-to-Wound effect")
	state.squads[squad].set_up_this_turn = false
	plan = C.AttackPlan.prepare(state, squad, true, [melee_assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("ap", 99)) == -1 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 0, "Talonstrike AP and Lance expire after the setup turn")

	print("Talonstrike Kill Team source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

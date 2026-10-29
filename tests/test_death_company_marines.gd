extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const FOOT := "death-company-marines"
const JUMP := "death-company-marines-with-jump-packs"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func profile_weapon(identity: String, category: String, weapon_id: String, profile_name: String = "standard") -> Dictionary:
	var profile := Profiles.profile(identity)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_name, {})
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_name, {})
	return {}

func models_for(state: Dictionary, squad: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	return result

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner and not models_for(state, squad, identity).is_empty(): return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	var squad := find_squad(state, owner, identity)
	var members := models_for(state, squad, identity) if squad >= 0 else []
	return members[0] if not members.is_empty() else -1

func choose(state: Dictionary, player: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return PublicUnitCommand.submit(state, player, option)
	return {"error": "Missing projected Death Company choice %s/%s for model %d." % [action, value, model]}

func has_choice(state: Dictionary, player: int, action: String, squad: int, model: int, value: String) -> bool:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return true
	return false

func fresh_state() -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry(FOOT, 10), entry(JUMP, 10), entry("blood-angels-captain"), entry("chaplain")]
	lists[2].entries = [entry("captain")]
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, lists)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var foot := Profiles.profile(FOOT)
	var jump := Profiles.profile(JUMP)
	var snapshot_hash := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
	var slice_hash := "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5"
	for item: Dictionary in [{"profile": foot, "id": "000001997", "name": "Death Company Marines"}, {"profile": jump, "id": "000002737", "name": "Death Company Marines With Jump Packs"}]:
		var profile: Dictionary = item.profile
		check(profile.get("name") == item.name and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == item.id, "%s maps to the exact Blood Angels datasheet identity" % item.name)
		check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == snapshot_hash and profile.get("source_slice_manifest_sha256") == slice_hash, "%s records the verified local export snapshot and hashes" % item.name)
		check(profile.get("points_by_models", {}) in [{5: 90, 10: 170}, {5: 130, 10: 260}] and profile.get("third_plus_points_by_models", {}) in [{5: 105, 10: 185}, {5: 160, 10: 290}], "%s admits only its source-priced 5/10 model sizes and both point tiers" % item.name)
		check(profile.get("models") == 5 and profile.get("max_supported_copies") == 3 and profile.get("base_size_source_mm") == 32, "%s records its composition, copy cap and 32 mm bases" % item.name)
		check(profile.get("stats", {}).get("toughness") == 5 and profile.get("stats", {}).get("save_target") == 3 and profile.get("stats", {}).get("wounds") == 2 and profile.get("stats", {}).get("leadership_target") == 6 and profile.get("stats", {}).get("objective_control") == 1, "%s preserves its exported model characteristics" % item.name)
		check("ADEPTUS ASTARTES" in profile.get("keywords", []) and "BLOOD ANGELS" in profile.get("keywords", []) and "DEATH COMPANY" in profile.get("keywords", []) and ("JUMP PACK" in profile.get("keywords", [])) == (item.id == "000002737") and ("FLY" in profile.get("keywords", [])) == (item.id == "000002737"), "%s preserves faction and sheet keywords" % item.name)
		var identity := FOOT if item.id == "000001997" else JUMP
		check(Profiles.death_company_model_weapons(identity).ranged[0].id == "heavy-bolt-pistol", "%s defaults to its Heavy Bolt Pistol" % item.name)
	check(foot.get("stats", {}).get("movement_inches") == 6 and jump.get("stats", {}).get("movement_inches") == 12, "The foot and Jump Pack movement values are distinct and exact")
	check(foot.get("keywords", []).has("INFANTRY") and foot.get("keywords", []).has("TACTICUS") and jump.get("keywords", []).has("JUMP PACK") and jump.get("keywords", []).has("FLY"), "Both profiles preserve their Infantry/Tacticus type and Jump Pack/Fly keywords")
	check(profile_weapon(FOOT, "ranged", "bolt-rifle-fire", "focused-fire") == {"name": "Bolt Rifle - Focused Fire", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 1}}, "Bolt Rifle Focused Fire matches the export")
	check(profile_weapon(FOOT, "ranged", "bolt-rifle-fire", "saturation").keywords == {"assault": true, "rapid-fire": 1} and profile_weapon(FOOT, "ranged", "bolt-rifle-fire", "saturation").strength == 5, "Bolt Rifle Saturation retains its separate Assault profile")
	check(profile_weapon(FOOT, "ranged", "grenade-launcher", "frag").keywords == {"blast": 1} and profile_weapon(FOOT, "ranged", "grenade-launcher", "krak").keywords == {"rapid-fire": 1}, "Grenade Launcher retains Frag and Krak profiles")
	check(profile_weapon(FOOT, "melee", "combat-blade").attacks == 3 and profile_weapon(FOOT, "melee", "eviscerator").keywords == {"cleave": 1} and profile_weapon(FOOT, "melee", "thunder-hammer").keywords == {"devastating-wounds": true}, "Foot-unit melee replacements match the source profiles")
	check(profile_weapon(JUMP, "melee", "eviscerator").strength == 7 and profile_weapon(JUMP, "melee", "power-fist").strength == 8 and profile_weapon(JUMP, "melee", "power-weapon").ap == -2, "Jump Pack melee replacements match the source profiles")
	check(profile_weapon(FOOT, "ranged", "hand-flamer").keywords == {"torrent": true, "close-quarters": true} and profile_weapon(JUMP, "ranged", "inferno-pistol").damage == "D3+2" and profile_weapon(JUMP, "ranged", "plasma-pistol", "supercharge").keywords.hazardous, "Optional pistols retain Torrent, Melta and Hazardous traits")
	check(AbilityCatalog.RULES.get(FOOT, []) == ["combat-doctrines", "feel-no-pain-6", "black-rage", "an-honourable-death-in-combat"] and AbilityCatalog.RULES.get(JUMP, []) == ["deep-strike", "combat-doctrines", "feel-no-pain-6", "black-rage", "savage-fury"], "Both datasheet ability sets are registered with only their source-listed rules")

	var foot_melee_5: Array[String] = ["eviscerator", "chainsword", "chainsword", "chainsword", "chainsword"]
	var foot_pistol_5: Array[String] = ["heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol"]
	var no_grenade_5: Array[bool] = [false, false, false, false, false]
	var double_eviscerator_5 := foot_melee_5.duplicate()
	double_eviscerator_5[1] = "eviscerator"
	check(Profiles.death_company_loadout_limits_valid(FOOT, 5, foot_melee_5, foot_pistol_5, no_grenade_5) and not Profiles.death_company_loadout_limits_valid(FOOT, 5, double_eviscerator_5, foot_pistol_5, no_grenade_5), "Foot-unit Eviscerators are limited to one per five models")
	var foot_melee_10: Array[String] = ["eviscerator", "eviscerator", "power-weapon", "bolt-rifle-fire", "bolt-rifle-fire", "chainsword", "chainsword", "chainsword", "chainsword", "chainsword"]
	var foot_pistol_10: Array[String] = ["hand-flamer", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol"]
	var foot_grenades_10: Array[bool] = [false, false, false, true, true, false, false, false, false, false]
	check(Profiles.death_company_loadout_limits_valid(FOOT, 10, foot_melee_10, foot_pistol_10, foot_grenades_10), "The 10-model foot unit supports two Eviscerators and Grenade Launchers on two Bolt Rifle carriers")
	var double_pistol_10 := foot_pistol_10.duplicate()
	double_pistol_10[1] = "plasma-pistol"
	check(not Profiles.death_company_loadout_limits_valid(FOOT, 10, foot_melee_10, double_pistol_10, foot_grenades_10), "The foot unit permits only one replacement Heavy Bolt Pistol")
	var jump_melee_10: Array[String] = ["eviscerator", "eviscerator", "power-fist", "power-fist", "power-weapon", "power-weapon", "power-weapon", "power-weapon", "chainsword", "chainsword"]
	var jump_pistol_10: Array[String] = ["hand-flamer", "hand-flamer", "inferno-pistol", "inferno-pistol", "plasma-pistol", "plasma-pistol", "plasma-pistol", "plasma-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol"]
	var no_jump_grenades: Array[bool] = [false, false, false, false, false, false, false, false, false, false]
	check(Profiles.death_company_loadout_limits_valid(JUMP, 10, jump_melee_10, jump_pistol_10, no_jump_grenades), "The 10-model Jump Pack unit scales its independent per-five melee and pistol limits")
	var five_jump_melee: Array[String] = ["power-weapon", "power-weapon", "power-weapon", "chainsword", "chainsword"]
	var five_jump_pistol: Array[String] = ["heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol", "heavy-bolt-pistol"]
	var five_jump_grenades: Array[bool] = [false, false, false, false, false]
	check(not Profiles.death_company_loadout_limits_valid(JUMP, 5, five_jump_melee, five_jump_pistol, five_jump_grenades), "A five-model Jump Pack unit cannot equip a third Power Weapon")
	var foot_package := Profiles.death_company_model_weapons(FOOT, "bolt-rifle-fire", "plasma-pistol", true)
	var jump_package := Profiles.death_company_model_weapons(JUMP, "power-fist", "inferno-pistol")
	check(foot_package.ranged.map(func(w: Dictionary) -> String: return str(w.id)) == ["plasma-pistol", "bolt-rifle-fire", "grenade-launcher"] and foot_package.melee[0].id == "combat-blade", "A foot model receives the exact Rifle/Blade/Launcher and pistol combination")
	check(jump_package.ranged[0].id == "inferno-pistol" and jump_package.melee[0].id == "power-fist" and Profiles.death_company_model_weapons(JUMP, "bolt-rifle-fire", "heavy-bolt-pistol").is_empty(), "Jump Pack loadouts support listed combinations and reject foot-only replacements")

	var foot_three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry(FOOT, 10, 3)]})
	var jump_three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry(JUMP, 5, 3)]})
	var foot_four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry(FOOT, 10, 4)]})
	check(foot_three.get("error", "").is_empty() and foot_three.get("total", -1) == 525 and jump_three.get("error", "").is_empty() and jump_three.get("total", -1) == 420 and not foot_four.get("error", "").is_empty(), "Catalog pricing applies source 1st/2nd and third-plus tiers and rejects a fourth copy")
	check(Roster.POINTS.get(FOOT, {}).get("sizes", {}) == {5: 90, 10: 170} and Roster.POINTS.get(JUMP, {}).get("sizes", {}) == {5: 130, 10: 260}, "Roster admission uses the same source-priced model choices")

	var state := fresh_state()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "The two Death Company datasheets materialize from the current local catalog: " + state_error)
	if not state_error.is_empty():
		print(state_error)
		quit(1)
		return
	var foot_squad := find_squad(state, 1, FOOT)
	var jump_squad := find_squad(state, 1, JUMP)
	var foot_models := models_for(state, foot_squad, FOOT)
	var jump_models := models_for(state, jump_squad, JUMP)
	var captain := find_model(state, 1, "blood-angels-captain")
	var chaplain := find_model(state, 1, "chaplain")
	var enemy := find_model(state, 2, "captain")
	var enemy_squad := find_squad(state, 2, "captain")
	check(foot_models.size() == 10 and jump_models.size() == 10 and captain >= 0 and chaplain >= 0 and enemy >= 0, "Both source-sized units and the supporting characters materialize")
	check(int(state.squads[foot_squad].get("training_cost", -1)) == 170 and int(state.squads[jump_squad].get("training_cost", -1)) == 260, "Prepared units use their source first-to-second unit costs")
	check(UnitPrevention.grants(state, foot_squad) == [{"target": 6, "against": "any"}] and UnitPrevention.grants(state, jump_squad) == [{"target": 6, "against": "any"}], "Both Death Company units receive Feel No Pain 6+ through shared prevention")
	check(C.UnitAbilities.has(state, jump_squad, "deep-strike") and C.UnitAbilities.charge_modifier(state, jump_squad) == 1 and C.UnitAbilities.charge_modifier(state, foot_squad) == 0, "Deep Strike and Savage Fury affect only the Jump Pack datasheet")
	if foot_models.size() != 10 or jump_models.size() != 10 or captain < 0 or chaplain < 0 or enemy < 0:
		quit(1)
		return

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var foot_model := foot_models[0]
	var bolt_result := choose(state, 1, "death-company-melee-loadout", foot_squad, foot_model, "bolt-rifle-fire")
	check(str(bolt_result.get("error", "")).is_empty() and state.units[foot_model].ranged_weapons.any(func(w: Dictionary) -> bool: return str(w.id) == "bolt-rifle-fire") and state.units[foot_model].melee_weapons[0].id == "combat-blade", "Public preparation command installs Bolt Rifle Fire and its paired Combat Blade")
	var grenade_result := choose(state, 1, "death-company-grenade-launcher", foot_squad, foot_model, "on")
	check(str(grenade_result.get("error", "")).is_empty() and state.units[foot_model].ranged_weapons.any(func(w: Dictionary) -> bool: return str(w.id) == "grenade-launcher"), "Public preparation command adds the two-profile Grenade Launcher only to the rifle carrier")
	var foot_special_pistol := choose(state, 1, "death-company-pistol-loadout", foot_squad, foot_models[1], "hand-flamer")
	check(str(foot_special_pistol.get("error", "")).is_empty() and not has_choice(state, 1, "death-company-pistol-loadout", foot_squad, foot_models[2], "plasma-pistol"), "The foot unit permits one replacement pistol total and withholds later replacements")
	for model_index in [2, 3]:
		var eviscerator_result := choose(state, 1, "death-company-melee-loadout", foot_squad, foot_models[model_index], "eviscerator")
		check(str(eviscerator_result.get("error", "")).is_empty(), "The foot unit can assign each of its two 10-model Eviscerators")
	check(not has_choice(state, 1, "death-company-melee-loadout", foot_squad, foot_models[4], "eviscerator"), "The foot unit withholds a third Eviscerator at ten models")
	var first_power := choose(state, 1, "death-company-melee-loadout", foot_squad, foot_models[4], "power-weapon")
	check(str(first_power.get("error", "")).is_empty() and not has_choice(state, 1, "death-company-melee-loadout", foot_squad, foot_models[5], "thunder-hammer"), "The foot unit allows one total Power Fist/Power Weapon/Thunder Hammer replacement")
	var jump_model := jump_models[0]
	var initial_training_points := int(state.training_points.get(1, 0))
	for model_index in range(4):
		var plasma_result := choose(state, 1, "death-company-pistol-loadout", jump_squad, jump_models[model_index], "plasma-pistol")
		check(str(plasma_result.get("error", "")).is_empty(), "Jump Pack plasma pistol limit allows four replacements at ten models")
	check(not has_choice(state, 1, "death-company-pistol-loadout", jump_squad, jump_models[4], "plasma-pistol"), "Jump Pack choices withhold a fifth Plasma Pistol at ten models")
	for model_index in [0, 1]:
		var jump_evis := choose(state, 1, "death-company-melee-loadout", jump_squad, jump_models[model_index], "eviscerator")
		check(str(jump_evis.get("error", "")).is_empty(), "Jump Pack unit can assign both Eviscerators at ten models")
	check(not has_choice(state, 1, "death-company-melee-loadout", jump_squad, jump_models[2], "eviscerator"), "Jump Pack choices withhold a third Eviscerator at ten models")
	check(int(state.training_points.get(1, 0)) == initial_training_points, "Datasheet equipment replacements do not change army points")

	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "movement"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.resolution_frames = []
	state.stratagems.pending = {}
	for model: int in state.units:
		state.units[model].on_battlefield = false
		state.units[model].position = Vector2(40, 40)
	for id: int in foot_models:
		state.units[id].on_battlefield = true
		state.units[id].position = Vector2(-10, 8)
	for id: int in jump_models:
		state.units[id].on_battlefield = true
		state.units[id].position = Vector2(-10, 8)
	state.units[captain].on_battlefield = true
	state.units[captain].position = Vector2(-6, 8)
	state.units[chaplain].on_battlefield = true
	state.units[chaplain].position = Vector2(-2, 8)
	state.units[enemy].on_battlefield = true
	state.units[enemy].position = Vector2(-8, 8)
	for squad: int in [foot_squad, jump_squad]:
		var model: int = models_for(state, squad, FOOT if squad == foot_squad else JUMP)[0]
		check(not C.UnitAbilities.black_rage_restricted(state, squad) and C.Morale.objective_control(state, model) == 1, "Black Rage is supported when both source auras cover this unit")
		var fall_back_ok := C.movement_choice_error_after_command(state, 1, model, "ordered_retreat", "")
		check(fall_back_ok.is_empty(), "Black Rage allows Fall Back while both support auras are present")
	state.units[chaplain].position = Vector2(10, 8)
	for squad: int in [foot_squad, jump_squad]:
		var model: int = models_for(state, squad, FOOT if squad == foot_squad else JUMP)[0]
		check(C.UnitAbilities.black_rage_restricted(state, squad) and C.Morale.objective_control(state, model) == 0, "Missing Chaplain support independently blocks Fall Back and sets OC to zero")
		var fall_back_blocked := C.movement_choice_error_after_command(state, 1, model, "ordered_retreat", "")
		check(fall_back_blocked.contains("Black Rage"), "The public Fall Back gate enforces Black Rage for this datasheet")
	state.units[chaplain].position = Vector2(-2, 8)
	state.units[captain].position = Vector2(10, 8)
	for squad: int in [foot_squad, jump_squad]: check(C.UnitAbilities.black_rage_restricted(state, squad), "Missing Blood Angels Character support independently triggers Black Rage")
	state.units[captain].position = Vector2(-6, 8)

	state.phase = "shooting"
	state.active = 1
	state.squads[foot_squad].starting_strength = 10
	var target_model := enemy
	for id: int in foot_models:
		if id != foot_model: state.units[id].on_battlefield = false
	var melee_attacks := int(profile_weapon(FOOT, "melee", "combat-blade").get("attacks", 3))
	var melee_plan := C.AttackPlan.prepare(state, foot_squad, true, [{"model": foot_model, "target": enemy_squad, "amount": melee_attacks, "weapon": "combat-blade", "profile": "standard"}], true)
	check(str(melee_plan.get("error", "")).is_empty() and melee_plan.batches.size() == 1 and melee_plan.batches[0].context.hit_reroll == "ones", "Foot-unit Black Rage adds melee Hit rerolls through AttackPlan")
	for id: int in foot_models: state.units[id].on_battlefield = true
	for model: int in foot_models: state.units[model].wounds = int(state.units[model].max_wounds)
	var full_plan := C.AttackPlan.prepare(state, foot_squad, false, [{"model": foot_models[0], "target": enemy_squad, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], true)
	check(str(full_plan.get("error", "")).is_empty() and int(full_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 0, "An Honourable Death grants no Sustained Hits at Starting Strength")
	for index in range(1, 5): state.units[foot_models[index]].wounds = 0
	var below_start_plan := C.AttackPlan.prepare(state, foot_squad, false, [{"model": foot_models[0], "target": enemy_squad, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], true)
	check(str(below_start_plan.get("error", "")).is_empty() and int(below_start_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1, "An Honourable Death grants Sustained Hits 1 below Starting Strength")
	state.units[foot_models[5]].wounds = 0
	var exact_half_plan := C.AttackPlan.prepare(state, foot_squad, false, [{"model": foot_models[0], "target": enemy_squad, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], true)
	check(str(exact_half_plan.get("error", "")).is_empty() and int(exact_half_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1, "An Honourable Death keeps Sustained Hits 1 at exact half-strength")
	state.units[foot_models[6]].wounds = 0
	var below_half_plan := C.AttackPlan.prepare(state, foot_squad, false, [{"model": foot_models[0], "target": enemy_squad, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], true)
	check(str(below_half_plan.get("error", "")).is_empty() and int(below_half_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 2, "An Honourable Death upgrades to Sustained Hits 2 below half-strength")
	var jump_attack_model := jump_models[4]
	for id: int in jump_models:
		if id != jump_attack_model: state.units[id].on_battlefield = false
	var jump_attacks := int(profile_weapon(JUMP, "melee", "chainsword").get("attacks", 1))
	var jump_melee_plan := C.AttackPlan.prepare(state, jump_squad, true, [{"model": jump_attack_model, "target": enemy_squad, "amount": jump_attacks, "weapon": "chainsword", "profile": "standard"}], true)
	var jump_base_sustained := int(profile_weapon(JUMP, "melee", "chainsword").get("keywords", {}).get("sustained-hits", 0))
	check(str(jump_melee_plan.get("error", "")).is_empty() and jump_melee_plan.batches[0].context.hit_reroll == "ones" and int(jump_melee_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == jump_base_sustained, "Jump Pack Black Rage applies its melee reroll without adding foot-only Sustained Hits")

	print("Death Company Marines source-bounded checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

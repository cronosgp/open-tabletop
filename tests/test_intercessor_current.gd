extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "intercessor-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("captain"), entry(UNIT, 5), entry(UNIT, 10)]
	result[2].entries = [entry(UNIT, 5), entry(UNIT, 10)]
	return result

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true,
		"awakened_dynasty": true, "core_stratagems": false, "manual_allocation": false
	}, lists())
	if state.has("error"):
		return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	return state

func find_squad(state: Dictionary, owner: int, strength: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != UNIT: continue
		var squad := int(unit.get("squad", -1))
		if int(state.squads[squad].get("starting_strength", -1)) == strength: return squad
	return -1

func model_for(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in C.living(state, squad):
		if bool(state.units[model].get("sergeant", false)) == sergeant: return model
	return -1

func model_for_identity(state: Dictionary, identity: String, owner: int = 1) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return model
	return -1

func choice_for(state: Dictionary, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, 1):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func apply_choice(state: Dictionary, action: String, model: int, value: String) -> String:
	var option := choice_for(state, action, model, value)
	if option.is_empty(): return "Missing projected %s=%s choice for model %d." % [action, value, model]
	return str(PublicUnitCommand.submit(state, 1, option).get("error", ""))

func weapon_ids(state: Dictionary, model: int) -> Array[String]:
	var ids: Array[String] = []
	for weapon: Dictionary in state.units[model].get("ranged_weapons", []): ids.append(str(weapon.get("id", "")))
	for weapon: Dictionary in state.units[model].get("melee_weapons", []): ids.append(str(weapon.get("id", "")))
	return ids

func check_model_weapons(state: Dictionary, model: int, target: int, description: String) -> void:
	var loadout := {"ranged": state.units[model].ranged_weapons.duplicate(true), "melee": state.units[model].melee_weapons.duplicate(true)}
	var issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, loadout, model, target)
	check(issues.is_empty(), "%s resolves every equipped weapon profile through Equipment and AttackPlan: %s" % [description, str(issues)])

func check_weapon_definitions(profile: Dictionary) -> void:
	var optional_ranged: Dictionary = {}
	for weapon: Dictionary in profile.additional_weapon_profiles.ranged: optional_ranged[str(weapon.id)] = weapon
	var optional_melee: Dictionary = {}
	for weapon: Dictionary in profile.additional_weapon_profiles.melee: optional_melee[str(weapon.id)] = weapon
	check(profile.ranged.map(func(w: Dictionary) -> String: return str(w.id)) == ["bolt-rifle", "bolt-pistol"] and profile.melee.map(func(w: Dictionary) -> String: return str(w.id)) == ["knives-and-fists"], "The exported default loadout is Bolt Rifle, Bolt Pistol and Knives and Fists")
	check(profile.ranged[0].profiles.focused_fire == {"name": "Bolt Rifle - Focused Fire", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 1}} and profile.ranged[0].profiles.saturation == {"name": "Bolt Rifle - Saturation", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "rapid-fire": 1}}, "Both Bolt Rifle profiles preserve their distinct 11e traits and characteristics")
	check(optional_ranged.get("grenade-launcher", {}).get("profiles", {}) == {"frag": {"name": "Grenade Launcher - Frag", "range_inches": 24.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 1}}, "krak": {"name": "Grenade Launcher - Krak", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -2, "damage": 3, "keywords": {"rapid-fire": 1}}}, "Grenade Launcher Frag and Krak profiles match the pinned source")
	check(optional_ranged.get("hand-flamer", {}).get("profiles", {}).get("standard", {}) == {"name": "Hand Flamer", "range_inches": 9.0, "attacks": 3, "skill": 0, "strength": 4, "ap": 0, "damage": 1, "keywords": {"torrent": true, "close-quarters": true}}, "Hand Flamer profile and Torrent are retained")
	check(optional_ranged.get("plasma-pistol", {}).get("profiles", {}) == {"standard": {"name": "Plasma Pistol - Standard", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}}, "supercharge": {"name": "Plasma Pistol - Supercharge", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}}}, "Both Plasma Pistol profiles and Supercharge Hazardous are retained")
	check(optional_melee.keys().size() == 4 and optional_melee.get("chainsword", {}).get("profiles", {}).get("standard", {}).get("attacks", 0) == 5 and optional_melee.get("power-fist", {}).get("profiles", {}).get("standard", {}).get("damage", 0) == 2 and optional_melee.get("power-weapon", {}).get("profiles", {}).get("standard", {}).get("ap", 0) == -2 and optional_melee.get("thunder-hammer", {}).get("profiles", {}).get("standard", {}).get("keywords", {}).get("devastating-wounds", false), "All four Sergeant melee replacements include their sourced profiles")
	check(profile.melee[0].profiles.standard == {"name": "Knives and Fists", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}, "Default Knives and Fists profile matches the export")
	check(profile.ranged[1].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol profile matches the export")

func check_abilities(state: Dictionary, squad: int, enemy: int) -> void:
	var source_models: Array[int] = C.living(state, squad)
	for model: int in source_models: state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, enemy): state.units[model].position = Vector2(20.0, 0.0)
	state.mission.objectives = [{"kind": "marker", "position": Vector2.ZERO, "name": "Intercessor objective", "controller": 1, "secured": 0}]
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, false) == 1, "Bolter Discipline grants +1 ranged Hit when the attacking Intercessors are within objective range")
	state.active = 2
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, false) == 0, "Bolter Discipline does not apply during the opponent's Shooting phase")
	state.active = 1
	state.phase = "fight"
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, true) == 0, "Bolter Discipline does not modify melee Hit rolls")
	state.phase = "shooting"
	for model: int in source_models: state.units[model].position = Vector2(-20.0, 0.0)
	for model: int in C.living(state, enemy): state.units[model].position = Vector2.ZERO
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, false) == 1, "Bolter Discipline also qualifies when the target unit is within objective range")
	for model: int in C.living(state, enemy): state.units[model].position = Vector2(20.0, 0.0)
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, false) == 0, "Bolter Discipline stops when neither unit is within objective range")
	for model: int in source_models: state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, enemy): state.units[model].position = Vector2(1.0, 0.0)
	state.squads[squad].battle_shocked = true
	check(C.Actions.eligibility_error(state, squad).is_empty(), "Tactical Mainstay permits otherwise-eligible action start while Battle-shocked")
	state.squads[squad].battle_shocked = false
	check(C.Actions.engaged(state, squad) and C.Actions.eligibility_error(state, squad).is_empty(), "Tactical Mainstay permits otherwise-eligible action start while Engaged")
	state.squads[squad].advanced = true
	check(not C.Actions.eligibility_error(state, squad).is_empty(), "Tactical Mainstay does not waive the Advance action restriction")
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = true
	check(not C.Actions.eligibility_error(state, squad).is_empty(), "Tactical Mainstay does not waive the Fall Back action restriction")
	state.squads[squad].fell_back = false
	C.Actions.start(state, squad, 0)
	check(not C.Actions.shooting_blocked(state, squad) and C.Actions.charge_blocked(state, squad), "Starting an action does not block Intercessors from shooting, but still blocks a Charge")
	for model: int in source_models: state.units[model].wounds = 0
	check(C.UnitAbilities.hit_bonus(state, squad, enemy, false) == 0 and C.Actions.shooting_blocked(state, squad), "Destroyed Intercessors no longer supply either datasheet ability")

func run() -> void:
	var profile: Dictionary = Profiles.profile(UNIT)
	check(profile.get("name", "") == "Intercessor Squad" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000001157" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile matches the pinned common-book e11 export")
	check(profile.get("models", -1) == 5 and profile.get("points_by_models", {}) == {5: 85, 10: 170} and profile.get("third_plus_points_by_models", {}) == {}, "Five/ten-model composition, points and absent third-copy tier match the export")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 16.0 / 25.4) and profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "The source 32 mm base and all seven model characteristics match")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "All six shared datasheet keywords are represented")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["bolter-discipline", "tactical-mainstay"], "Both source abilities are registered to Intercessor Squad")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0) == 4, "Catalog status and current four-copy local roster gate match the scope evidence")
	check_weapon_definitions(profile)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false), "Intercessors are admitted into the current consolidated construction catalog")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 5, "cost": 85}, {"models": 10, "cost": 170}], "Construction exposes only the two source-sized Intercessor options")
	check(Roster.POINTS.get(UNIT, {}).get("source", "") == "wahapedia-e11-2026-10-19" and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {5: 85, 10: 170}, "Roster pricing resolves to the pinned local source")
	var four_copy_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), entry(UNIT, 5, 4)]}
	var four_copy_admission := C.RosterValidation.admit(four_copy_roster)
	check(four_copy_admission.get("error", "").is_empty(), "The current fixed-roster Incursion gate admits four Battleline copies at the source five-model size: %s" % str(four_copy_admission.get("error", "")))
	four_copy_roster.entries[0].copies = 5
	check(not str(C.RosterValidation.admit(four_copy_roster).get("error", "")).is_empty(), "The current fixed-roster Incursion gate rejects a fifth Battleline copy")

	var state := fixture()
	check(not state.has("error"), "Current Space Marine catalogs materialize for the Intercessor scope: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Current Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, 5)
	var large := find_squad(state, 1, 10)
	var enemy_small := find_squad(state, 2, 5)
	var enemy_large := find_squad(state, 2, 10)
	var target := enemy_large
	check(small > 0 and large > 0 and enemy_small > 0 and enemy_large > 0, "Both sourced compositions materialize for both current Space Marine catalogs")
	if small < 0 or large < 0 or enemy_small < 0 or enemy_large < 0:
		print("Current Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(state.squads[small].training_cost == 85 and state.squads[large].training_cost == 170 and state.squads[enemy_small].training_cost == 85 and state.squads[enemy_large].training_cost == 170 and C.living(state, small).size() == 5 and C.living(state, large).size() == 10 and C.living(state, enemy_small).size() == 5 and C.living(state, enemy_large).size() == 10, "Both players retain the exact model sizes and first/second-copy prices")
	for squad: int in [small, large, enemy_small, enemy_large]:
		for model: int in C.living(state, squad):
			check(is_equal_approx(float(state.units[model].radius), 16.0 / 25.4) and state.units[model].keywords.has("BATTLELINE"), "Materialized model %d keeps the source base and Battleline role" % model)
	check(state.squads[small].stats == profile.stats, "Materialized squad receives the sourced profile characteristics")

	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader]: source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["adrax-agatone", "ancient", "apothecary", "captain", "captain-titus", "chaplain", "chief-librarian-tigurius", "judiciar", "kor-sarro-khan", "librarian", "lieutenant", "marneus-calgar", "techmarine", "wardens-of-ultramar"], "All fourteen common-book Leader/Supported by links match the local source map: %s" % str(source_leaders))
	var source_supports: Array[String] = []
	for candidate: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[candidate]: source_supports.append(candidate)
	source_supports.sort()
	check(source_supports == ["ancient", "apothecary", "judiciar", "lieutenant", "wardens-of-ultramar"], "All five common-book Supported by links match the local source map: %s" % str(source_supports))
	var captain_model := model_for_identity(state, "captain")
	check(captain_model >= 0 and C.UnitActions.attachment_allowed(state, captain_model, small), "A source-linked Captain can attach to Intercessor Squad")

	var sergeant := model_for(state, small, true)
	var trooper := model_for(state, small, false)
	check_model_weapons(state, sergeant, target, "Default Intercessor Sergeant")
	var melee_option := choice_for(state, "intercessor-melee", sergeant, "chainsword")
	var before_illegal_choice := var_to_bytes(state)
	var wrong_model_choice: Dictionary = melee_option.duplicate(true)
	wrong_model_choice.model = trooper
	check(not PublicUnitCommand.error(state, 1, wrong_model_choice).is_empty() and before_illegal_choice == var_to_bytes(state), "A non-Sergeant cannot receive the Sergeant melee replacement")
	check(not PublicUnitCommand.error(state, 2, melee_option).is_empty() and before_illegal_choice == var_to_bytes(state), "The opposing player cannot select a Sergeant replacement")
	var forged_melee: Dictionary = melee_option.duplicate(true)
	forged_melee.value = "unsupported-melee"
	check(not PublicUnitCommand.error(state, 1, forged_melee).is_empty() and before_illegal_choice == var_to_bytes(state), "A forged Sergeant melee value is rejected without changing the loadout")
	for kind: String in ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]:
		var error := apply_choice(state, "intercessor-melee", sergeant, kind)
		check(error.is_empty() and kind in weapon_ids(state, sergeant), "Public preparation command equips Sergeant melee replacement %s: %s" % [kind, error])
		check_model_weapons(state, sergeant, target, "Sergeant with %s" % kind)
	check(apply_choice(state, "intercessor-melee", sergeant, "knives-and-fists").is_empty() and "knives-and-fists" in weapon_ids(state, sergeant), "The Sergeant can publicly restore Knives and Fists")
	for kind: String in ["chainsword", "hand-flamer", "plasma-pistol", "power-weapon"]:
		var error := apply_choice(state, "intercessor-rifle", sergeant, kind)
		check(error.is_empty() and "bolt-pistol" in weapon_ids(state, sergeant) and kind in weapon_ids(state, sergeant) and "bolt-rifle" not in weapon_ids(state, sergeant), "Public preparation command replaces only the Sergeant Bolt Rifle with %s and retains the Bolt Pistol: %s" % [kind, error])
		check_model_weapons(state, sergeant, target, "Sergeant rifle replacement %s" % kind)
	check(apply_choice(state, "intercessor-rifle", sergeant, "bolt-rifle").is_empty() and "bolt-rifle" in weapon_ids(state, sergeant) and "bolt-pistol" in weapon_ids(state, sergeant), "The Sergeant can publicly restore the Bolt Rifle and retain the Bolt Pistol")
	check_model_weapons(state, sergeant, target, "Restored Intercessor Sergeant")
	var current_launcher_options: Array = C.unit_choices(state, 1).filter(func(option: Dictionary) -> bool: return option.get("action", "") == "intercessor-grenade-launcher" and int(option.get("target", -1)) == small and option.get("value", "") == "on")
	check(current_launcher_options.size() == 4 and current_launcher_options.all(func(option: Dictionary) -> bool: return int(option.get("model", -1)) != sergeant), "Five-model squad offers one Grenade Launcher to each of four eligible non-Sergeants")
	var wrong_owner: Dictionary = current_launcher_options[0] if not current_launcher_options.is_empty() else {}
	if not wrong_owner.is_empty():
		var before := var_to_bytes(state)
		check(not PublicUnitCommand.error(state, 2, wrong_owner).is_empty() and before == var_to_bytes(state), "The opposing player cannot change the Intercessor loadout")
		var forged: Dictionary = wrong_owner.duplicate(true)
		forged.value = "krak"
		before = var_to_bytes(state)
		check(not PublicUnitCommand.error(state, 1, forged).is_empty() and before == var_to_bytes(state), "A forged Grenade Launcher selection value cannot mutate the unit")
		check(PublicUnitCommand.error(state, 1, wrong_owner).is_empty(), "The public preparation command adds the five-model unit's Grenade Launcher")
		check_model_weapons(state, int(wrong_owner.model), target, "Five-model Grenade Launcher")
		var another := -1
		for option: Dictionary in C.unit_choices(state, 1):
			if option.get("action", "") == "intercessor-grenade-launcher" and int(option.get("target", -1)) == small and option.get("value", "") == "on": another = int(option.get("model", -1))
		check(another < 0, "Five-model squad cannot exceed one Grenade Launcher")
		check(apply_choice(state, "intercessor-grenade-launcher", int(wrong_owner.model), "off").is_empty(), "Equipped Grenade Launcher can be removed and its slot reopened")
		check(C.unit_choices(state, 1).any(func(option: Dictionary) -> bool: return option.get("action", "") == "intercessor-grenade-launcher" and option.get("value", "") == "on"), "Removing the launcher restores one eligible selection opportunity")

	var ten_candidates: Array[int] = []
	for option: Dictionary in C.unit_choices(state, 1):
		if option.get("action", "") == "intercessor-grenade-launcher" and int(option.get("target", -1)) == large and option.get("value", "") == "on": ten_candidates.append(int(option.get("model", -1)))
	check(ten_candidates.size() == 9, "Ten-model squad exposes nine eligible non-Sergeants before taking its two launchers")
	if ten_candidates.size() >= 3:
		check(apply_choice(state, "intercessor-grenade-launcher", ten_candidates[0], "on").is_empty() and apply_choice(state, "intercessor-grenade-launcher", ten_candidates[1], "on").is_empty(), "Public preparation equips both permitted ten-model Grenade Launchers")
		check_model_weapons(state, ten_candidates[0], target, "Ten-model Grenade Launcher Frag/Krak")
		var third_available := C.unit_choices(state, 1).any(func(option: Dictionary) -> bool: return option.get("action", "") == "intercessor-grenade-launcher" and int(option.get("target", -1)) == large and option.get("value", "") == "on")
		check(not third_available, "Ten-model squad cannot exceed two Grenade Launchers")
		check(apply_choice(state, "intercessor-grenade-launcher", ten_candidates[0], "off").is_empty(), "A ten-model Grenade Launcher can be removed")
		check(C.unit_choices(state, 1).any(func(option: Dictionary) -> bool: return option.get("action", "") == "intercessor-grenade-launcher" and int(option.get("target", -1)) == large and option.get("value", "") == "on"), "Removing one of two launchers reopens the ten-model option")
	else:
		check(false, "Ten-model launcher options are present for the source-permitted two selections")

	check_abilities(state, small, target)
	print("Current Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

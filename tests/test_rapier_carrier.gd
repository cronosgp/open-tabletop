extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const SOURCE_ID := "rapier-carrier"
const UNIT_ID := "40kdc:11e:adeptus-astartes:rapier-carrier"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry("intercessor-squad", 5)]
	result[1].entries = [entry(SOURCE_ID)]
	return result

func battle() -> Dictionary:
	var state := F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())
	if state.has("error"): return state
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].squad) if model >= 0 else -1

func choice_for(state: Dictionary, action: String, model: int, value: String = "") -> Dictionary:
	for choice: Dictionary in C.UnitActions.choices(state, 1):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and (value.is_empty() or str(choice.get("value", "")) == value): return choice
	return {}

func attack_plan(state: Dictionary, model: int, squad: int, target: int, weapon: String, profile: String = "standard") -> Dictionary:
	return C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile}], true)

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000000110", "Profile is tied to the current 11e Warhammer Legends Rapier Carrier sheet")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile retains the verified export and Legends source-slice provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Rapier-Carrier"), "The current source page and Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {1: 90} and profile.get("models", 0) == 1 and profile.get("stats", {}) == {"movement_inches": 3, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Composition, points and model characteristics match the verified export")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("not certified"), "Unspecified model footprint remains an explicit 60 mm simulation proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "IMPERIUM", "ARTILLERY", "FRAME", "VEHICLE"] and profile.get("default_loadout_by_role", {}).get("Rapier Carrier", {}) == {"Armoured Hull": 1, "Boltgun": 1, "Quad Heavy Bolter": 1}, "All source keywords and the fixed starting loadout are retained")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Powerful Volley"] and "powerful-volley" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "Both army and datasheet rules are registered for the sheet")
	var expected_guns := {
		"boltgun": {"name": "Boltgun", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 1}},
		"quad-heavy-bolter": {"name": "Quad Heavy Bolter", "range_inches": 36.0, "attacks": 6, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1, "rapid-fire": 2, "twin-linked": true, "heavy": true}},
		"graviton-cannon": {"name": "Graviton Cannon", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 6, "ap": -2, "damage": 2, "keywords": {"blast": 2, "anti-vehicle": 2, "heavy": true}},
		"laser-destroyer": {"name": "Laser Destroyer", "range_inches": 72.0, "attacks": 2, "skill": 3, "strength": 14, "ap": -3, "damage": "D6+3", "keywords": {"heavy": true}}
	}
	var all_ranged: Array = profile.ranged.duplicate(true)
	all_ranged.append_array(profile.get("additional_weapon_profiles", {}).get("ranged", []))
	for id: String in expected_guns:
		var source_weapons: Array = all_ranged.filter(func(candidate: Dictionary) -> bool: return str(candidate.id) == id)
		var weapon: Dictionary = source_weapons[0].profiles.standard if not source_weapons.is_empty() else {}
		check(weapon == expected_guns[id], "%s exactly matches its current source weapon profile" % weapon.name)
	var launcher: Array = profile.get("additional_weapon_profiles", {}).get("ranged", []).filter(func(candidate: Dictionary) -> bool: return str(candidate.id) == "quad-launcher")
	check(launcher.size() == 1 and launcher[0].profiles["shatter-shells"] == {"name": "Quad Launcher - Shatter Shells", "range_inches": 24.0, "attacks": 4, "skill": 3, "strength": 9, "ap": -2, "damage": 3, "keywords": {"heavy": true}} and launcher[0].profiles["thunderfire-shells"] == {"name": "Quad Launcher - Thunderfire Shells", "range_inches": 60.0, "attacks": "D3+6", "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {"indirect-fire": true, "heavy": true, "blast": 1}}, "Quad Launcher keeps both source fire modes and every characteristic")
	var hull: Dictionary = profile.melee[0].profiles.standard
	check(hull == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 2, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the current melee profile")
	check(Army.SPECS.get(SOURCE_ID, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "Army admission marks Legends scope and the three-copy datasheet ceiling")
	check(Capabilities.supported("powerful-volley"), "Powerful Volley has an enabled capability record")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Rapier Carrier is loaded from the consolidated local catalog")
	var unit := provider.lookup(UNIT_ID)
	check(unit.get("source_scope", "") == "Warhammer Legends" and unit.get("options", []) == [{"models": 1, "cost": 90}] and unit.get("scope", "").contains("competitive events require organiser approval"), "Construction lists the legal size/price and the Legends event condition")
	for copies: int in [1, 2]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": copies}]})
		check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == copies * 90, "Army admission prices %d Rapier Carrier copy/copies correctly" % copies)
	var strike_force_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var strike_force_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(strike_force_three.get("error", "").is_empty() and strike_force_three.get("total", -1) == 270 and not str(strike_force_four.get("error", "")).is_empty(), "Strike Force permits up to three copies and rejects a fourth")

	for option: String in ["quad-heavy-bolter", "graviton-cannon", "laser-destroyer", "quad-launcher"]:
		var loadout := P.rapier_carrier_weapons(option)
		check(not loadout.is_empty() and loadout.ranged.size() == 2 and loadout.melee.size() == 1 and str(loadout.ranged[1].id) == option, "The %s primary-weapon package replaces exactly the source option" % option)
	check(P.rapier_carrier_weapons("invalid").is_empty(), "An unlisted Rapier weapon option is rejected")
	var state := battle()
	if state.has("error"):
		check(false, "Admitted Rapier Carrier builds into the battle: " + str(state.error))
		provider.free()
		quit(1)
		return
	var model := model_for(state, 1, SOURCE_ID)
	var squad := squad_for(state, 1, SOURCE_ID)
	var target := squad_for(state, 2, "intercessor-squad")
	check(model >= 0 and squad >= 0 and target >= 0 and C.UnitAbilities.has(state, squad, "powerful-volley"), "The roster creates a Rapier Carrier with its datasheet ability")
	if model >= 0 and target >= 0:
		state.units[model].position = Vector2.ZERO
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(20, 0)
		for option: String in ["graviton-cannon", "laser-destroyer", "quad-launcher"]:
			var loadout_choice := choice_for(state, "rapier-carrier-loadout", model, option)
			var changed_loadout := C.UnitActions.apply(state, 1, loadout_choice, Vector2.ZERO, Callable()) if not loadout_choice.is_empty() else {"error": "No %s preparation choice was offered." % option}
			check(str(changed_loadout.get("error", "")).is_empty() and str(state.units[model].get("rapier_carrier_primary", "")) == option and str(state.units[model].ranged_weapons[1].id) == option, "The setup choice replaces the default weapon with source-listed %s: %s" % [option, str(changed_loadout)])
			if option == "quad-launcher":
				var shatter := Equipment.select(state, model, false, "quad-launcher", "shatter-shells")
				var thunderfire := Equipment.select(state, model, false, "quad-launcher", "thunderfire-shells")
				check(shatter.get("error", "").is_empty() and shatter.stats.damage == 3 and thunderfire.get("error", "").is_empty() and thunderfire.stats.keywords.get("indirect-fire", false), "The selectable Quad Launcher exposes both distinct source fire profiles")
				var launcher_shot_state := state.duplicate(true)
				launcher_shot_state.phase = "shooting"
				launcher_shot_state.active = 1
				launcher_shot_state.unit_abilities.window = {}
				var launcher_plan := C.AttackPlan.prepare(launcher_shot_state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "quad-launcher", "profile": "thunderfire-shells"}], true, -1, true)
				check(launcher_plan.get("error", "").is_empty() and launcher_plan.batches.size() == 1 and launcher_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Stationary Powerful Volley applies to the Thunderfire Shells Heavy Indirect Fire attack")
		var laser_choice := choice_for(state, "rapier-carrier-loadout", model, "laser-destroyer")
		var laser_selected := C.UnitActions.apply(state, 1, laser_choice, Vector2.ZERO, Callable()) if not laser_choice.is_empty() else {"error": "No Laser Destroyer preparation choice was offered."}
		check(str(laser_selected.get("error", "")).is_empty() and str(state.units[model].get("rapier_carrier_primary", "")) == "laser-destroyer", "The source-listed Laser Destroyer can be selected for the battle")
		state.phase = "shooting"
		state.active = 1
		state.unit_abilities.window = {}
		var selected := Equipment.select(state, model, false, "laser-destroyer", "standard")
		check(selected.get("error", "").is_empty() and selected.stats.keywords.get("heavy", false), "The chosen Laser Destroyer is selectable through the shared equipment flow: %s" % str(selected))
		var stationary := attack_plan(state, model, squad, target, "laser-destroyer")
		check(stationary.get("error", "").is_empty() and stationary.batches.size() == 1 and stationary.batches[0].weapon.keywords.get("lethal-hits", false), "Powerful Volley adds Lethal Hits to the stationary Heavy ranged attack: %s" % str(stationary))
		var boltgun := attack_plan(state, model, squad, target, "boltgun")
		check(boltgun.get("error", "").is_empty() and not boltgun.batches[0].weapon.keywords.get("lethal-hits", false), "Powerful Volley does not grant Lethal Hits to a non-Heavy ranged attack")
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(1.5, 0)
		state.phase = "fight"
		var melee := C.AttackPlan.prepare(state, squad, true, [{"model": model, "target": target, "amount": 2, "weapon": "armoured-hull", "profile": "standard"}], true)
		check(melee.get("error", "").is_empty() and melee.get("batches", []).size() == 1 and not melee.batches[0].weapon.keywords.get("lethal-hits", false), "Powerful Volley does not affect melee attacks: %s" % str(melee))
		state.phase = "shooting"
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(20, 0)
		for cause: String in ["model-moved", "movement-distance", "set-up"]:
			var moving := state.duplicate(true)
			match cause:
				"model-moved": moving.units[model].moved = true
				"movement-distance": moving.squads[squad].moved_distance = 0.1
				"set-up": moving.squads[squad].set_up_this_turn = true
			var blocked := attack_plan(moving, model, squad, target, "laser-destroyer")
			check(blocked.get("error", "").is_empty() and not blocked.batches[0].weapon.keywords.get("lethal-hits", false), "Powerful Volley is absent after %s this turn" % cause)
		var advanced := state.duplicate(true)
		advanced.squads[squad].advanced = true
		var fallback := state.duplicate(true)
		fallback.squads[squad].fell_back = true
		check(not C.AttackPlan._stationary(advanced, squad) and not C.AttackPlan._stationary(fallback, squad), "Powerful Volley stationarity excludes Advances and Fall Back moves")

	provider.free()
	if failures > 0: quit(1)
	else: quit(0)

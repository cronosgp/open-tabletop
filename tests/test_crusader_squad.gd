extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MovementGeometry = preload("res://scripts/edition_11/contact_movement.gd")
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = Prepared.Combat
const FIST := "fist-of-the-god-emperor"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(faction: String, identity: String, models: int) -> Dictionary:
	var prefix := "adeptus-astartes" if faction == "Space Marines" else "necrons"
	return {"schema_version": 2, "faction": faction, "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:%s:%s" % [prefix, identity], "models": models, "copies": 1}]}

func fresh_state(crusader_models: int) -> Dictionary:
	return Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "combat_doctrines": true,
		"unit_abilities": true, "marine_detachments": {1: FIST, 2: "gladius"}, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}},
		{1: army("Space Marines", "crusader-squad", crusader_models), 2: army("Space Marines", "crusader-squad", 10)})

func squad_for(state: Dictionary, owner: int) -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func model_for_index(state: Dictionary, squad: int, model_index: int) -> int:
	for model: int in C.living(state, squad):
		if int(state.units[model].get("crusader_squad_model", -1)) == model_index: return model
	return -1

func source_weapon(profile_record: Dictionary, category: String, weapon_id: String, profile_id: String = "standard") -> Dictionary:
	var options: Dictionary = profile_record.get("additional_weapon_profiles", {})
	for weapon: Dictionary in profile_record.get(category, []) + options.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_id, {})
	return {}

func loadout_choice(state: Dictionary, player: int, squad: int, model_index: int, loadout_id: String) -> Dictionary:
	var model := model_for_index(state, squad, model_index)
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) == "crusader-squad-loadout" and int(candidate.get("target", -1)) == squad and int(candidate.get("model", -1)) == model and str(candidate.get("value", "")) == loadout_id:
			return candidate
	return {}

func submit_loadout(state: Dictionary, player: int, squad: int, model_index: int, loadout_id: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, loadout_choice(state, player, squad, model_index, loadout_id))

func test_same_upper_surface_route_via_ground() -> void:
	var state := fresh_state(10)
	if state.has("error"):
		check(false, "Same-floor ground-detour fixture prepares a Crusader match")
		return
	var squad := squad_for(state, 1)
	var mover := model_for_index(state, squad, 0)
	if mover < 0:
		check(false, "Same-floor ground-detour fixture has a living Crusader")
		return
	for model_id: int in state.units: state.units[model_id].wounds = 0
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-1.0, 0.0)
	state.units[mover].elevation = 3.0
	var upper_floor := {"id": "detour-floor", "name": "Detour floor", "bounds": Rect2(-2.0, -3.0, 6.0, 6.0),
		"elevation": 3.0, "access_features": [0, 2], "requires_keywords": ["infantry"]}
	state["terrain"] = {"id": "same-floor-ground-detour", "areas": [{"name": "Sealed floor with two access walls", "category": "legacy",
		"bounds": Rect2(-2.0, -4.0, 6.0, 8.0), "features": [
			{"bounds": Rect2(-2.05, -0.5, 0.1, 1.0), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(0.4, -4.0, 0.2, 8.0), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(3.95, -0.5, 0.1, 1.0), "height": 4.0, "blocks_end": true}], "surfaces": [upper_floor]}]}
	var destination := Vector2(3.0, 0.0)
	var allowance := 22.0
	check(not MovementGeometry.clear_path(state, mover, destination, allowance, false, false, 3.0, "surge"),
		"A direct same-floor path stays blocked by the wall spanning the platform")
	var route := MovementPathfinder.new(state, mover, allowance, "surge").distance_to(destination, 3.0)
	var route_points: Array[Dictionary] = [
		{"position": Vector2(-1.25, 0.0), "elevation": 0.0},
		{"position": Vector2(-1.25, 4.6), "elevation": 0.0},
		{"position": Vector2(3.2, 4.6), "elevation": 0.0},
		{"position": Vector2(3.2, 0.0), "elevation": 0.0},
		{"position": destination, "elevation": 3.0}
	]
	var composed_route := 0.0
	var legal_composition := true
	var route_state: Dictionary = state.duplicate(true)
	for step: Dictionary in route_points:
		var start: Vector2 = route_state.units[mover].position
		var start_elevation := float(route_state.units[mover].get("elevation", 0.0))
		var point: Vector2 = step.position
		var elevation := float(step.elevation)
		composed_route += start.distance_to(point) + absf(start_elevation - elevation)
		if not MovementGeometry.clear_path(route_state, mover, point, allowance, false, false, elevation, "surge"):
			legal_composition = false
			break
		route_state.units[mover].position = point
		route_state.units[mover].elevation = elevation
	check(legal_composition and composed_route <= allowance and not is_inf(route) and route <= composed_route + 0.05,
		"The route search composes a legal descent, ground detour and ascent back to the same floor (route %.3f; composed %.3f; legal %s)" % [route, composed_route, str(legal_composition)])
	var closest := MovementPathfinder.new(state, mover, allowance, "surge").closest_reachable_to_region(
		Rect2(destination, Vector2.ZERO), 0.0, Callable(), [], 3.0)
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= composed_route + 0.05,
		"The closest-region query also reaches the same-floor endpoint through the ground detour (gap %.3f; route %.3f)" % [float(closest.get("distance", INF)), float(closest.get("route_distance", INF))])

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("crusader-squad")
	check(str(profile.get("source_snapshot_id", "")) == "20261021T130623Z" and str(profile.get("source_manifest_sha256", "")) == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and str(profile.get("source_slice_manifest_sha256", "")) == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Crusader Squad records the verified Space Marines snapshot and Black Templars slice identities")
	check(profile.get("points_by_models", {}) == {10: 160, 20: 305} and profile.get("keywords", []).has("BATTLELINE"), "Crusader Squad preserves both source sizes, prices and the Battleline keyword")
	var ranged_ids: Array[String] = []
	for weapon: Dictionary in profile.get("ranged", []) + profile.get("additional_weapon_profiles", {}).get("ranged", []): ranged_ids.append(str(weapon.get("id", "")))
	var melee_ids: Array[String] = []
	for weapon: Dictionary in profile.get("melee", []) + profile.get("additional_weapon_profiles", {}).get("melee", []): melee_ids.append(str(weapon.get("id", "")))
	check(ranged_ids == ["bolt-pistol", "bolt-rifle", "hand-flamer", "heavy-bolt-pistol", "pyreblaster", "shotgun"], "All six source ranged weapon families are recorded once")
	check(melee_ids == ["close-combat-weapon", "combat-knife", "initiate-chainsword", "master-crafted-power-weapon", "neophyte-chainsword", "power-fist"], "All six source melee weapon families are recorded once")
	check(source_weapon(profile, "ranged", "bolt-pistol") == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol facts match the verified local export")
	check(source_weapon(profile, "ranged", "bolt-rifle", "focused-fire") == {"name": "Bolt Rifle - Focused Fire", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 1, "heavy": true}} and source_weapon(profile, "ranged", "bolt-rifle", "saturation") == {"name": "Bolt Rifle - Saturation", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "rapid-fire": 1}}, "Both Bolt Rifle profiles match the verified local export")
	check(source_weapon(profile, "ranged", "hand-flamer") == {"name": "Hand Flamer", "range_inches": 9.0, "attacks": 3, "skill": 0, "strength": 4, "ap": 0, "damage": 1, "keywords": {"torrent": true, "close-quarters": true}} and source_weapon(profile, "ranged", "heavy-bolt-pistol") == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Hand Flamer and Heavy Bolt Pistol facts match the verified local export")
	check(source_weapon(profile, "ranged", "pyreblaster") == {"name": "Pyreblaster", "range_inches": 12.0, "attacks": 3, "skill": 0, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 1, "torrent": true}} and source_weapon(profile, "ranged", "shotgun") == {"name": "Shotgun", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"assault": true, "blast": 1}}, "Pyreblaster and Shotgun facts match the verified local export")
	check(source_weapon(profile, "melee", "close-combat-weapon") == {"name": "Close combat weapon", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}} and source_weapon(profile, "melee", "combat-knife") == {"name": "Combat Knife", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}, "Close combat weapon and Combat Knife facts match the verified local export")
	check(source_weapon(profile, "melee", "initiate-chainsword") == {"name": "Initiate Chainsword", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1}} and source_weapon(profile, "melee", "neophyte-chainsword") == {"name": "Neophyte Chainsword", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1}}, "The two Chainsword profiles match the verified local export")
	check(source_weapon(profile, "melee", "master-crafted-power-weapon") == {"name": "Master-crafted Power Weapon", "range_inches": 0.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"lethal-hits": true}} and source_weapon(profile, "melee", "power-fist") == {"name": "Power Fist", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}, "Master-crafted Power Weapon and Power Fist facts match the verified local export")
	var sword_default := Profiles.crusader_squad_model_loadout(0, 10)
	var sword_flame := Profiles.crusader_squad_model_loadout(0, 10, "hand-flamer")
	var neophyte_default := Profiles.crusader_squad_model_loadout(1, 10)
	var neophyte_shotgun := Profiles.crusader_squad_model_loadout(1, 10, "shotgun")
	var initiate_default := Profiles.crusader_squad_model_loadout(5, 10)
	var initiate_chain := Profiles.crusader_squad_model_loadout(5, 10, "pistol-chainsword")
	var initiate_fist := Profiles.crusader_squad_model_loadout(5, 10, "heavy-pistol-power-fist")
	var initiate_pyre := Profiles.crusader_squad_model_loadout(5, 10, "pyreblaster")
	check(sword_default.ranged[0].id == "heavy-bolt-pistol" and sword_flame.ranged[0].id == "hand-flamer" and sword_default.melee[0].id == "master-crafted-power-weapon", "Sword Brother can replace only its pistol and keeps its source melee weapon")
	check(neophyte_default.ranged[0].id == "bolt-pistol" and neophyte_default.melee[0].id == "neophyte-chainsword" and neophyte_shotgun.ranged[0].id == "shotgun" and neophyte_shotgun.melee[0].id == "combat-knife", "Neophyte's paired replacement changes both source-listed weapons")
	check(initiate_default.ranged.size() == 2 and initiate_default.ranged[1].profiles.size() == 2 and initiate_chain.melee.size() == 2 and initiate_fist.melee.size() == 2 and initiate_pyre.ranged[1].id == "pyreblaster", "Initiate loadouts preserve the Bolt Pistol and close combat weapon when replacing the Bolt Rifle")
	check(Profiles.crusader_squad_model_loadout(4, 10, "shotgun").role == "Neophyte" and Profiles.crusader_squad_model_loadout(5, 10, "shotgun").is_empty() and Profiles.crusader_squad_model_loadout(8, 20).role == "Neophyte" and Profiles.crusader_squad_model_loadout(9, 20).role == "Initiate", "Both source compositions assign model roles at the correct boundaries")

	var state := fresh_state(10)
	check(not state.has("error"), "Prepared Fist match admits a 10-model Crusader Squad: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var squad := squad_for(state, 1)
	var sword_model := model_for_index(state, squad, 0)
	var first_upgrade := loadout_choice(state, 1, squad, 5, "heavy-pistol-power-fist")
	var unchanged := var_to_bytes(state)
	var wrong_owner := PublicUnitCommand.submit(state, 2, first_upgrade)
	check(not str(wrong_owner.get("error", "")).is_empty() and unchanged == var_to_bytes(state), "The other player cannot select Crusader Squad preparation equipment")
	var sword_result := submit_loadout(state, 1, squad, 0, "hand-flamer")
	check(str(sword_result.get("error", "")).is_empty() and state.units[sword_model].ranged_weapons[0].id == "hand-flamer", "The owning player can select the Sword Brother's Hand Flamer replacement through the public command")
	var fist_result := submit_loadout(state, 1, squad, 5, "heavy-pistol-power-fist")
	var pyre_result := submit_loadout(state, 1, squad, 6, "pyreblaster")
	check(str(fist_result.get("error", "")).is_empty() and str(pyre_result.get("error", "")).is_empty(), "A 10-model squad can select two Initiate heavy-weapon replacements")
	check(loadout_choice(state, 1, squad, 7, "heavy-pistol-power-fist").is_empty() and loadout_choice(state, 1, squad, 7, "pyreblaster").is_empty(), "A 10-model squad cannot exceed two combined heavy-weapon replacements")
	var unlimited_choice := loadout_choice(state, 1, squad, 7, "pistol-chainsword")
	check(not unlimited_choice.is_empty() and str(PublicUnitCommand.submit(state, 1, unlimited_choice).get("error", "")).is_empty(), "The unlimited Initiate Heavy Bolt Pistol and Chainsword option remains available after reaching the heavy-weapon cap")

	var twenty_state := fresh_state(20)
	check(not twenty_state.has("error"), "Prepared Fist match admits a 20-model Crusader Squad: %s" % str(twenty_state.get("error", "")))
	if not twenty_state.has("error"):
		var twenty_squad := squad_for(twenty_state, 1)
		var accepted := true
		for model_index in [9, 10, 11, 12]:
			var option_id := "pyreblaster" if model_index % 2 == 0 else "heavy-pistol-power-fist"
			if not str(submit_loadout(twenty_state, 1, twenty_squad, model_index, option_id).get("error", "")).is_empty(): accepted = false
		check(accepted and loadout_choice(twenty_state, 1, twenty_squad, 13, "pyreblaster").is_empty(), "A 20-model squad allows four, and no more than four, combined heavy-weapon replacements")

	test_same_upper_surface_route_via_ground()

	if failures > 0:
		print("Crusader Squad checks: %d failures" % failures)
		quit(1)
	else:
		print("Crusader Squad checks passed")
		quit(0)

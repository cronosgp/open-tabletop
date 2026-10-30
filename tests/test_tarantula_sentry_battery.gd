extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const R = preload("res://scripts/edition_11/core_reactions.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const SOURCE_ID := "tarantula-sentry-battery"
const UNIT_ID := "40kdc:11e:adeptus-astartes:tarantula-sentry-battery"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	result[1].entries = [
		{"definition_id": UNIT_ID, "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": 1, "copies": 1}]
	return result

func battle() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	return result

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var models := models_for(state, owner, identity)
	return int(state.units[models[0]].squad) if not models.is_empty() else -1

func choice_for(state: Dictionary, action: String, model: int, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and (value.is_empty() or str(option.get("value", "")) == value): return option
	return {}

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000000098", "Profile maps to the current 11e Warhammer Legends source identity")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile records verified local export provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Tarantula-Sentry-Battery"), "The current source page and Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {1: 30, 2: 60, 3: 90} and profile.get("models", 0) == 1 and profile.get("stats", {}) == {"movement_inches": 0, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "All source model counts, points and characteristics are exact")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("not certified"), "The omitted source diameter is disclosed as a 60 mm simulation proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "ARTILLERY", "FRAME", "IMPERIUM"] and profile.get("default_loadout_by_role", {}).get("Tarantula Sentry Battery", {}) == {"Armoured Hull": 1, "Twin Heavy Bolter": 1}, "Source keywords and fixed starting equipment are retained")
	var heavy_bolter: Dictionary = profile.ranged[0].profiles.standard
	var lascannon: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.standard
	var hull: Dictionary = profile.melee[0].profiles.standard
	check(heavy_bolter == {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1, "rapid-fire": 2}}, "Twin Heavy Bolter matches the export")
	check(lascannon == {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}, "Twin Lascannon replacement matches the export")
	check(hull == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 1, "skill": 6, "strength": 3, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the export")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Sentinel Protocols"] and "sentinel-protocols" in C.UnitAbilities.RULES.get(SOURCE_ID, []) and "combat-doctrines" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "All datasheet and army rules are registered, without borrowing Tarantula Air Defence rules")
	check("deadly-demise-1" not in C.UnitAbilities.RULES.get(SOURCE_ID, []) and Capabilities.supported("sentinel-protocols"), "The profile does not inherit Deadly Demise or free Overwatch from the other Tarantula datasheet")
	check(P.tarantula_sentry_battery_weapons("twin-heavy-bolter").ranged[0].id == "twin-heavy-bolter" and P.tarantula_sentry_battery_weapons("twin-lascannon").ranged[0].id == "twin-lascannon" and P.tarantula_sentry_battery_weapons("invalid").is_empty(), "Only the two source-listed interchangeable weapons can be configured")
	check(Army.SPECS.get(SOURCE_ID, {}).get("validation_status", "") == "tests_passed_local_targeted" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "The locally verified Legends profile publishes the source copy limit")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Tarantula Sentry Battery is published from the local catalog")
	var catalog_unit := provider.lookup(UNIT_ID)
	check(catalog_unit.get("source_scope", "") == "Warhammer Legends" and catalog_unit.get("options", []) == [{"models": 1, "cost": 30}, {"models": 2, "cost": 60}, {"models": 3, "cost": 90}] and catalog_unit.get("scope", "").contains("competitive events require organiser approval") and catalog_unit.get("scope", "").contains("footprint"), "Construction exposes every priced size and both use/geometry conditions")
	var list := Roster.new_list("11e", "Space Marines", "incursion", 1000)
	list.entries.append(Roster.entry(catalog_unit, 1))
	check(Roster.validate(list).is_empty() and list.entries[0].get("source_scope", "") == "Warhammer Legends", "The local army roster accepts and preserves its Legends source label")
	var repriced := Roster.reprice(list, provider.catalog)
	check(repriced.get("error", "").is_empty() and repriced.get("list", {}).get("entries", [{}])[0].get("models", -1) == 2 and repriced.get("list", {}).get("entries", [{}])[0].get("cost", -1) == 60, "Saved lists retain the source-priced model count on reprice: %s" % str(repriced))
	for size: int in [1, 2, 3]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": size, "copies": 1}]})
		check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == size * 30, "Army admission prices the %d-model source size correctly" % size)
	var incursion_over_limit := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var strike_force_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 3, "copies": 3}]})
	var strike_force_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(incursion_over_limit.get("error", "")).is_empty() and strike_force_three.get("error", "").is_empty() and strike_force_three.get("total", -1) == 270 and not str(strike_force_four.get("error", "")).is_empty(), "Incursion and Strike Force use the existing two-/three-copy category limits: %s / %s / %s" % [str(incursion_over_limit), str(strike_force_three), str(strike_force_four)])

	var state := battle()
	if state.has("error"):
		check(false, "Source-priced 3-model Tarantula Sentry unit builds into a battle: " + str(state.error))
		provider.free()
		quit(1)
		return
	var models := models_for(state, 1, SOURCE_ID)
	var squad := squad_for(state, 1, SOURCE_ID)
	check(models.size() == 3 and squad >= 0 and C.UnitAbilities.has(state, squad, "sentinel-protocols") and not C.UnitAbilities.has(state, squad, "sentry-programming"), "The 3-model unit receives Sentinel Protocols, not the Air Defence datasheet's separate free-use rule")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	if models.size() == 3:
		for model: int in models:
			var setup_choice := choice_for(state, "tarantula-sentry-battery-loadout", model, "twin-lascannon")
			check(not setup_choice.is_empty(), "Each Tarantula in the unit has its own Twin Lascannon equipment choice")
		var second_choice := choice_for(state, "tarantula-sentry-battery-loadout", models[1], "twin-lascannon")
		var wrong_owner_before := var_to_bytes(state)
		var wrong_owner_result: Dictionary = PublicUnitCommand.submit(state, 2, second_choice) if not second_choice.is_empty() else {"error": "no choice"}
		check(not str(wrong_owner_result.get("error", "")).is_empty() and wrong_owner_before == var_to_bytes(state), "A non-owner cannot change a Tarantula loadout")
		var apply_result := C.UnitActions.apply(state, 1, second_choice, Vector2.ZERO, Callable()) if not second_choice.is_empty() else {"error": "no choice"}
		check(apply_result.get("error", "").is_empty() and str(state.units[models[1]].get("tarantula_sentry_primary", "")) == "twin-lascannon" and state.units[models[1]].ranged_weapons[0].id == "twin-lascannon", "One model's weapon swap leaves the other two independently equipped")
		var first_choice := choice_for(state, "tarantula-sentry-battery-loadout", models[0], "twin-lascannon")
		var invalid_choice := first_choice.duplicate(true)
		invalid_choice.value = "land-raider"
		var invalid_before := var_to_bytes(state)
		var invalid_result := C.UnitActions.apply(state, 1, invalid_choice, Vector2.ZERO, Callable()) if not invalid_choice.is_empty() else {"error": "no choice"}
		check(not str(invalid_result.get("error", "")).is_empty() and invalid_before == var_to_bytes(state), "A forged weapon option is rejected without changing the unit")
		var alternate_back := choice_for(state, "tarantula-sentry-battery-loadout", models[1], "twin-heavy-bolter")
		var revert_result := C.UnitActions.apply(state, 1, alternate_back, Vector2.ZERO, Callable()) if not alternate_back.is_empty() else {"error": "no choice"}
		var reverted_to_default: bool = str(revert_result.get("error", "")).is_empty() and str(state.units[models[1]].ranged_weapons[0].id) == "twin-heavy-bolter"
		check(reverted_to_default, "The setup selection can be returned to the source default")

	var second_unit := squad_for(state, 1, "intercessor-squad")
	var target := squad_for(state, 2, "intercessor-squad")
	state.phase = "movement"
	state.active = 2
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	state.core_reactions.overwatch = {}
	for model: int in models: state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, target): state.units[model].position = Vector2(8, 0)
	state.stratagems.uses.append({"player": 1, "squad": second_unit, "stratagem": R.OVERWATCH, "phase_key": R.phase_key(state), "turn": state.turn})
	check(R.cost_of(state, 1, squad, R.OVERWATCH) == 1 and not R.error(state, 1, squad, R.OVERWATCH).is_empty(), "Tarantula Sentry Battery remains subject to the normal once-per-player-per-phase Fire Overwatch limit")
	state.stratagems.uses.clear()
	check(R.cost_of(state, 1, squad, R.OVERWATCH) == 1 and R.error(state, 1, squad, R.OVERWATCH).is_empty(), "Sentinel Protocols can use a normal Fire Overwatch when no other unit has used it this phase")
	var overwatch_choice := R.choices(state, 1).filter(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == squad and str(option.get("value", "")) == R.OVERWATCH)
	var overwatch_result := R.apply(state, 1, {"value": R.OVERWATCH, "target": squad, "model": -1})
	check(not overwatch_choice.is_empty() and overwatch_result.get("error", "").is_empty() and int(state.cp[1]) == 2, "The builder exposes and pays one normal Fire Overwatch use for the Tarantula unit")
	check(not R.error(state, 1, squad, R.OVERWATCH).is_empty(), "The same unit cannot repeat Sentinel Protocols during the phase")
	var plan := C.AttackPlan.prepare(state, squad, false, C.AttackPlan.single_target(state, squad, target, false), true)
	check(plan.get("error", "").is_empty() and not plan.get("batches", []).is_empty() and int(plan.batches[0].context.get("snap_hit_threshold", 0)) == 4 and plan.batches[0].context.get("hit_reroll", "") == "none", "Every Tarantula Overwatch attack uses unmodified 4+ snap shooting without hit re-rolls")
	var criticals := C.Attacks.roll_pool({"skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "attacks": 1, "keywords": {"twin-linked": true}}, {"toughness": 4, "save_target": 4, "wounds_per_model": 2, "remaining_wounds": [2]}, {"weapon_count": 1, "snap_shooting": true, "snap_hit_threshold": 4, "hit_reroll": "none", "snap_shooting_criticals": false}, func() -> int: return 4)
	check(criticals.get("error", "").is_empty() and criticals.get("hit_rolls", []) == [4] and criticals.get("critical_hits", 0) == 0, "An unmodified 4 hit during the Overwatch threshold is not a critical hit")

	provider.free()
	if failures > 0: quit(1)
	else: quit(0)

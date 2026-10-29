extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "ravenwing-black-knights"
const UNIT_ID := "40kdc:11e:adeptus-astartes:ravenwing-black-knights"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections(model_count: int = 3) -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
		result[owner].entries = [entry(UNIT, model_count), entry("intercessor-squad", 5)]
		if owner == 1:
			result[owner].entries.append(entry("captain-on-bike", 1))
			result[owner].entries.append(entry("chaplain-on-bike", 1))
	return result

func fixture(model_count: int = 3) -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}
	}, selections(model_count))
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String, owner: int) -> int:
	var found := models(state, identity, owner)
	return int(state.units[found[0]].squad) if not found.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func equipped_profile(state: Dictionary, model: int) -> Dictionary:
	var result := Profiles.profile(UNIT)
	result.ranged = state.units[model].get("ranged_weapons", []).duplicate(true)
	result.melee = state.units[model].get("melee_weapons", []).duplicate(true)
	return result

func weapon_plan_failures(state: Dictionary, squad: int, model: int, target: int) -> Array[String]:
	var isolated: Dictionary = state.duplicate(true)
	for sibling: int in C.living(isolated, squad):
		if sibling != model: isolated.units[sibling].wounds = 0
	return WeaponChecks.fixed_weapon_plan_failures(isolated, equipped_profile(isolated, model), model, target)

func melee_plan(state: Dictionary, squad: int, model: int, target: int, charged: bool) -> Dictionary:
	var isolated: Dictionary = state.duplicate(true)
	for sibling: int in C.living(isolated, squad):
		if sibling != model: isolated.units[sibling].wounds = 0
	var target_models: Array[int] = C.living(isolated, target)
	if target_models.is_empty(): return {"error": "The target unit has no living models."}
	isolated.phase = "fight"
	isolated.active = int(isolated.units[model].owner)
	isolated.units[model].position = Vector2.ZERO
	isolated.units[target_models[0]].position = Vector2(1.75, 0.0)
	isolated.squads[squad].charged = charged
	return C.AttackPlan.prepare(isolated, squad, true, [{
		"model": model, "target": target, "amount": 4, "weapon": "corvus-hammers", "profile": "standard"
	}], true)

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000241" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Ravenwing Black Knights cites the pinned 11e Dark Angels App identity")
	check(profile.get("points_by_models", {}) == {3: 85, 6: 170} and profile.get("third_plus_points_by_models", {}) == {3: 95, 6: 180}, "The 3/6-model sizes and first/second versus third-plus prices match the export")
	check(profile.get("base_size_source_mm", []) == [75, 42] and profile.get("base_geometry") == "oval" and profile.get("geometry_scope") == "75 x 42 mm oval represented by a labelled 37.5 mm bounding-circle proxy" and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 37.5 / 25.4), "The oval base uses the explicitly labelled conservative collision proxy")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 5}, "M12/T6/Sv3+/W3/Ld6+/OC2 and 5+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["DARK ANGELS", "RAVENWING", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"], "Every source keyword, including Chapter and Ravenwing, is represented")
	check(profile.get("default_loadout_by_role", {}).get("Ravenwing Huntmaster", {}) == {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1} and profile.default_loadout_by_role.get("Ravenwing Black Knight", {}) == {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1}, "Both source model roles receive all three default weapons")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["bolt-pistol", "plasma-talon"] and profile.melee.map(func(w: Dictionary) -> String: return w.id) == ["corvus-hammers"], "The fixed ranged and melee weapons match the exported default loadout")
	check(profile.ranged[0].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol fields and Close-quarters match the export")
	check(profile.ranged[1].profiles.standard == {"name": "Plasma Talon - Standard", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"rapid-fire": 1}} and profile.ranged[1].profiles.supercharge == {"name": "Plasma Talon - Supercharge", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"rapid-fire": 1, "hazardous": true}}, "Both Plasma Talon profiles retain every stat and trait")
	check(profile.melee[0].profiles.standard == {"name": "Corvus Hammers", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {"devastating-wounds": true}}, "Corvus Hammers fields and Devastating Wounds match the export")
	var grenade: Dictionary = profile.additional_weapon_profiles.ranged[0]
	check(grenade.id == "grenade-launcher" and grenade.profiles.frag == {"name": "Grenade Launcher - Frag", "range_inches": 24.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 1}} and grenade.profiles.krak == {"name": "Grenade Launcher - Krak", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -2, "damage": 3, "keywords": {"rapid-fire": 1}}, "Grenade Launcher Frag and Krak profiles preserve all exported fields")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["combat-doctrines", "knights-of-caliban"], "Both exported datasheet abilities are assigned to the unit")
	var ability_capability: Dictionary = Registry.KNOWN.get("knights-of-caliban", {})
	check(ability_capability.get("category", "") == Registry.CATEGORY_UNIT and ability_capability.get("supported", false) and ability_capability.get("validation_status", "") == "tests_passed_local_targeted", "Knights of Caliban is registered with its focused local validation status")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {3: 85, 6: 170} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {3: 95, 6: 180}, "The locally checked current catalog and roster price map include both compositions")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	var options_by_models: Dictionary = {}
	for option: Dictionary in catalog_choice.get("options", []): options_by_models[int(option.models)] = option
	check(options_by_models == {3: {"models": 3, "cost": 85, "third_plus_cost": 95}, 6: {"models": 6, "cost": 170, "third_plus_cost": 180}}, "The construction catalog exposes both sizes with exact source prices")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 37.5 / 25.4}, "Runtime admission resolves the labelled oval proxy")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 3)]})
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 4)]})
	check(three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 265 and not str(four_copies.get("error", "")).is_empty(), "Custom-list admission applies the third-copy price and local three-copy limit")
	var bike_leader_targets: Array = LeaderLinks.targets("captain-on-bike")
	var bike_chaplain_targets: Array = LeaderLinks.targets("chaplain-on-bike")
	check(bike_leader_targets == ["outrider-squad", UNIT] and bike_chaplain_targets == ["outrider-squad", UNIT], "Bike Leaders retain their Outrider links and gain the source-listed Black Knights link")
	check(UNIT_ID in LeaderCatalog.ATTACHMENTS.get("40kdc:11e:adeptus-astartes:captain-on-bike", []) and UNIT_ID in LeaderCatalog.ATTACHMENTS.get("40kdc:11e:adeptus-astartes:chaplain-on-bike", []), "The runtime Leader catalog exposes both source-listed Black Knights attachments")

	var state := fixture()
	check(not state.has("error"), "Both Dark Angels players materialize the source-listed squad: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Ravenwing Black Knights checks: %d failures" % (failures + 1))
		quit(1)
		return
	var knights := models(state, UNIT, 1)
	var opposing_knights := models(state, UNIT, 2)
	var squad := squad_for(state, UNIT, 1)
	var target := squad_for(state, "intercessor-squad", 2)
	var captain_models := models(state, "captain-on-bike", 1)
	var chaplain_models := models(state, "chaplain-on-bike", 1)
	check(knights.size() == 3 and opposing_knights.size() == 3 and int(state.squads[squad].training_cost) == 85 and target > 0, "Both sides materialize three models at 85 points")
	var default_loadout_ok := true
	for model: int in knights:
		if state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) != ["bolt-pistol", "plasma-talon"] or state.units[model].melee_weapons.map(func(w: Dictionary) -> String: return w.id) != ["corvus-hammers"]: default_loadout_ok = false
	check(default_loadout_ok and not knights.is_empty() and state.units[knights[0]].get("keywords", []).has("RAVENWING"), "Each model gets the full default loadout and Dark Angels contextual RAVENWING keyword")
	check(A.has(state, squad, "knights-of-caliban") and A.has(state, squad, "combat-doctrines"), "The match admits both current datasheet abilities")
	if not captain_models.is_empty():
		check(U.attachment_allowed(state, captain_models[0], squad), "The source-listed Captain on Bike can attach to the Black Knights")
		var captain_choice := choice_for(state, 1, "attach", captain_models[0], squad)
		var captain_state: Dictionary = state.duplicate(true)
		var captain_attachment := PublicUnitCommand.submit(captain_state, 1, captain_choice)
		check(captain_attachment.get("error", "").is_empty() and int(captain_state.units[captain_models[0]].squad) == squad, "The Captain on Bike joins through the public preparation command")
	if not chaplain_models.is_empty():
		check(U.attachment_allowed(state, chaplain_models[0], squad), "The source-listed Chaplain on Bike can attach to the Black Knights")
		var chaplain_choice := choice_for(state, 1, "attach", chaplain_models[0], squad)
		var chaplain_state: Dictionary = state.duplicate(true)
		var chaplain_attachment := PublicUnitCommand.submit(chaplain_state, 1, chaplain_choice)
		check(chaplain_attachment.get("error", "").is_empty() and int(chaplain_state.units[chaplain_models[0]].squad) == squad, "The Chaplain on Bike joins through the public preparation command")
	var default_failures := weapon_plan_failures(state, squad, knights[1], target)
	check(default_failures.is_empty(), "All default weapon profiles resolve through Equipment and AttackPlan: %s" % str(default_failures))

	var initial_choice := choice_for(state, 1, "black-knight-grenade-launcher", knights[0], squad, "on")
	var changed_state: Dictionary = state.duplicate(true)
	var wrong_owner_before := var_to_bytes(changed_state)
	var wrong_owner := PublicUnitCommand.submit(changed_state, 2, initial_choice)
	check(not initial_choice.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and wrong_owner_before == var_to_bytes(changed_state), "A different player cannot change Black Knight equipment")
	var initial_cost := int(changed_state.squads[squad].training_cost)
	var replacement := PublicUnitCommand.submit(changed_state, 1, initial_choice)
	check(replacement.get("error", "").is_empty() and changed_state.units[knights[0]].ranged_weapons[1].id == "grenade-launcher" and int(changed_state.squads[squad].training_cost) == initial_cost, "One model can take the free Grenade Launcher while replacing its Plasma Talon")
	check(choice_for(changed_state, 1, "black-knight-grenade-launcher", knights[1], squad, "on").is_empty(), "A three-model squad cannot take a second Grenade Launcher")
	var alternate_failures := weapon_plan_failures(changed_state, squad, knights[0], target)
	check(alternate_failures.is_empty(), "Both Grenade Launcher profiles resolve through Equipment and AttackPlan: %s" % str(alternate_failures))
	var restore_choice := choice_for(changed_state, 1, "black-knight-grenade-launcher", knights[0], squad, "off")
	var restored := PublicUnitCommand.submit(changed_state, 1, restore_choice)
	check(restored.get("error", "").is_empty() and changed_state.units[knights[0]].ranged_weapons[1].id == "plasma-talon" and int(changed_state.squads[squad].training_cost) == initial_cost, "The public command restores the Plasma Talon without changing points")

	var uncharged_plan := melee_plan(state, squad, knights[1], target, false)
	var charged_plan := melee_plan(state, squad, knights[1], target, true)
	check(uncharged_plan.get("error", "").is_empty() and not uncharged_plan.batches[0].weapon.keywords.has("anti-monster") and not uncharged_plan.batches[0].weapon.keywords.has("anti-vehicle"), "Knights of Caliban does not grant Anti traits without a Charge move")
	check(charged_plan.get("error", "").is_empty() and charged_plan.batches[0].weapon.keywords.get("anti-monster", 0) == 4 and charged_plan.batches[0].weapon.keywords.get("anti-vehicle", 0) == 4, "After a Charge move the actual Corvus Hammer AttackPlan gains Anti-MONSTER 4+ and Anti-VEHICLE 4+")

	var six_state := fixture(6)
	var six_knights := models(six_state, UNIT, 1)
	var six_squad := squad_for(six_state, UNIT, 1)
	check(not six_state.has("error") and six_knights.size() == 6 and int(six_state.squads[six_squad].training_cost) == 170, "Six-model Ravenwing Black Knights materialize at 170 points")
	if six_knights.size() == 6:
		var first_choice := choice_for(six_state, 1, "black-knight-grenade-launcher", six_knights[0], six_squad, "on")
		var first_result := PublicUnitCommand.submit(six_state, 1, first_choice)
		var second_choice := choice_for(six_state, 1, "black-knight-grenade-launcher", six_knights[1], six_squad, "on")
		var second_result := PublicUnitCommand.submit(six_state, 1, second_choice)
		var third_choice := choice_for(six_state, 1, "black-knight-grenade-launcher", six_knights[2], six_squad, "on")
		var third_result := PublicUnitCommand.submit(six_state, 1, third_choice)
		check(first_result.get("error", "").is_empty() and second_result.get("error", "").is_empty() and third_choice.is_empty() and not str(third_result.get("error", "")).is_empty(), "A six-model unit allows two Grenade Launchers and rejects a third")
	if failures == 0: print("Ravenwing Black Knights checks: passed")
	else: print("Ravenwing Black Knights checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")

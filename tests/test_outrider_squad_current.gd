extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const UNIT := "outrider-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:outrider-squad"
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
	return result

func fixture(model_count: int = 3, chapters: Dictionary = {}) -> Dictionary:
	var options := {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}
	if not chapters.is_empty(): options.marine_chapters = chapters.duplicate(true)
	var state: Dictionary = F.P.initial_state(options, selections(model_count))
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity:
			result.append(model)
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

func weapon_plan_failures_for_model(state: Dictionary, squad: int, model: int, target: int) -> Array[String]:
	var isolated: Dictionary = state.duplicate(true)
	for sibling: int in C.living(isolated, squad):
		if sibling != model: isolated.units[sibling].wounds = 0
	return WeaponChecks.fixed_weapon_plan_failures(isolated, equipped_profile(isolated, model), model, target)

func melee_batch(state: Dictionary, squad: int, model: int, target: int, weapon_id: String, charged: bool) -> Dictionary:
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
	var selected := Equipment.select(isolated, model, true, weapon_id, "standard")
	if not str(selected.get("error", "")).is_empty(): return selected
	var plan: Dictionary = C.AttackPlan.prepare(isolated, squad, true, [{
		"model": model, "target": target, "amount": int(selected.stats.get("attacks", 1)),
		"weapon": weapon_id, "profile": "standard"
	}], true)
	if not str(plan.get("error", "")).is_empty(): return plan
	if plan.get("batches", []).is_empty(): return {"error": "AttackPlan returned no melee batch."}
	return plan.batches[0]

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002712" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Outrider Squad cites the pinned shared-book Wahapedia 11e identity")
	check(profile.get("points_by_models", {}) == {3: 80, 6: 160} and profile.get("third_plus_points_by_models", {}) == {3: 80, 6: 160}, "The source's 3/6-model compositions and all copy-cost tiers match")
	check(profile.get("base_size_source_mm", []) == [90, 52] and profile.get("base_geometry") == "oval" and profile.get("geometry_scope") == "90 x 52 mm bounding-circle proxy" and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 45.0 / 25.4), "The 90 x 52 mm oval base retains its explicitly labelled circular collision proxy")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "M12/T6/Sv3+/W4/Ld6+/OC2 and no invulnerable save match the local export")
	check(profile.get("keywords", []) == ["RAVENWING", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"], "All source keywords are recorded, with Ravenwing treated as Chapter-contextual")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["heavy-bolt-pistol", "twin-bolt-rifle"] and profile.melee.map(func(w: Dictionary) -> String: return w.id) == ["chainsword"], "The fixed default loadout matches the per-model source entry")
	check(profile.ranged[0].profiles.standard == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}} and profile.ranged[1].profiles.standard == {"name": "Twin Bolt Rifle", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"twin-linked": true, "assault": true, "rapid-fire": 2}}, "Heavy Bolt Pistol and Twin Bolt Rifle retain every exported profile field and trait")
	check(profile.melee[0].profiles.standard == {"name": "Chainsword", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {}}, "Chainsword retains every exported profile field")
	check(profile.additional_weapon_profiles.ranged.size() == 1 and profile.additional_weapon_profiles.ranged[0].id == "plasma-pistol" and profile.additional_weapon_profiles.ranged[0].profiles.standard == {"name": "Plasma Pistol - Standard", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}} and profile.additional_weapon_profiles.ranged[0].profiles.supercharge.keywords == {"close-quarters": true, "hazardous": true}, "Both Plasma Pistol profiles and Hazardous are present")
	check(profile.additional_weapon_profiles.ranged[0].profiles.supercharge == {"name": "Plasma Pistol - Supercharge", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}}, "Plasma Pistol Supercharge retains every exported profile field and Hazardous")
	check(profile.additional_weapon_profiles.melee.map(func(w: Dictionary) -> String: return w.id) == ["power-weapon", "thunder-hammer"] and profile.additional_weapon_profiles.melee[0].profiles.standard == {"name": "Power Weapon", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {}} and profile.additional_weapon_profiles.melee[1].profiles.standard == {"name": "Thunder Hammer", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 8, "ap": -2, "damage": 3, "keywords": {"devastating-wounds": true}}, "Both Sergeant melee replacements retain every exported field and trait")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {3: 80, 6: 160} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {3: 80, 6: 160}, "The current catalog and roster price map admit both source unit sizes and prices")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	var options_by_models: Dictionary = {}
	for option: Dictionary in catalog_choice.get("options", []): options_by_models[int(option.models)] = option
	check(options_by_models == {3: {"models": 3, "cost": 80, "third_plus_cost": 80}, 6: {"models": 6, "cost": 160, "third_plus_cost": 160}}, "The construction catalog exposes both model counts at exact source prices")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 45.0 / 25.4}, "Runtime admission uses the documented conservative circle proxy for the oval")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 3)]})
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 4)]})
	check(three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 240 and not str(four_copies.get("error", "")).is_empty(), "Custom-list admission prices the third copy correctly and enforces the local three-copy cap")

	var leader_targets: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader]: leader_targets.append(leader)
	leader_targets.sort()
	var supported_by: Array[String] = []
	for source: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[source]: supported_by.append(source)
	check(leader_targets == ["captain-on-bike", "chaplain-on-bike", "suboden-khan"] and supported_by == ["ravenwing-command-squad"], "The shared-book Leader links and Ravenwing Command Squad Chapter Support link are present")

	var state := fixture()
	check(not state.has("error"), "Both players build Outriders from the consolidated current Marine catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Current Outrider Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var riders := models(state, UNIT, 1)
	var opposing_riders := models(state, UNIT, 2)
	var rider_squad := squad_for(state, UNIT, 1)
	var target_squad := squad_for(state, "intercessor-squad", 2)
	var captains := models(state, "captain-on-bike", 1)
	check(captains.size() == 1, "The current Marine catalog materializes one Captain on Bike for the Leader regression")
	if captains.is_empty():
		for model: int in state.get("units", {}): print("Outrider fixture unit %d: %s owner=%d" % [model, A.identity(state.units[model]), int(state.units[model].get("owner", -1))])
	var captain := captains[0] if not captains.is_empty() else -1
	check(riders.size() == 3 and opposing_riders.size() == 3 and int(state.squads[rider_squad].training_cost) == 80 and target_squad > 0, "Both players materialize three-model squads at 80 points")
	check(state.units[riders[0]].get("sergeant", false) and not state.units[riders[1]].get("sergeant", false), "Exactly one model receives the Sergeant role")
	var default_loadouts_match := true
	for model: int in riders:
		if state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) != ["heavy-bolt-pistol", "twin-bolt-rifle"] or state.units[model].melee_weapons.map(func(w: Dictionary) -> String: return w.id) != ["chainsword"]:
			default_loadouts_match = false
	check(default_loadouts_match, "Every Outrider model, including the Sergeant, materializes all three default weapons")
	check(A.has(state, rider_squad, "full-throttle-assault"), "Full-throttle Assault is attached to the current Outrider unit")
	check(not state.units[riders[0]].get("keywords", []).has("RAVENWING"), "RAVENWING does not leak into a shared profile outside Dark Angels context")
	var dark_state := fixture(3, {1: "DARK ANGELS", 2: "DARK ANGELS"})
	var dark_riders := models(dark_state, UNIT, 1)
	check(not dark_state.has("error") and not dark_riders.is_empty() and dark_state.units[dark_riders[0]].get("keywords", []).has("RAVENWING"), "Dark Angels context grants the source-listed RAVENWING keyword")
	var default_failures := weapon_plan_failures_for_model(state, rider_squad, riders[1], target_squad)
	check(default_failures.is_empty(), "Every default weapon profile resolves through Equipment and AttackPlan: %s" % str(default_failures))

	var initial_plasma_on_sergeant := choice_for(state, 1, "outrider-plasma-pistol", riders[0], rider_squad, "on")
	var plasma_state: Dictionary = state.duplicate(true)
	var trooper_plasma_choice := choice_for(plasma_state, 1, "outrider-plasma-pistol", riders[1], rider_squad, "on")
	var before_wrong_owner := var_to_bytes(plasma_state)
	var wrong_owner := PublicUnitCommand.submit(plasma_state, 2, trooper_plasma_choice)
	check(not trooper_plasma_choice.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(plasma_state), "A different player cannot change Outrider equipment")
	var base_cost := int(plasma_state.squads[rider_squad].training_cost)
	var plasma_result := PublicUnitCommand.submit(plasma_state, 1, trooper_plasma_choice)
	check(plasma_result.get("error", "").is_empty() and plasma_state.units[riders[1]].ranged_weapons[0].id == "plasma-pistol" and int(plasma_state.squads[rider_squad].training_cost) == base_cost, "A model may replace its Heavy Bolt Pistol with a free Plasma Pistol through the public command")
	var second_plasma_result := PublicUnitCommand.submit(plasma_state, 1, initial_plasma_on_sergeant)
	check(not str(second_plasma_result.get("error", "")).is_empty() and choice_for(plasma_state, 1, "outrider-plasma-pistol", riders[0], rider_squad, "on").is_empty(), "The three-model unit rejects a second Plasma Pistol at the command projection")
	var plasma_failures := weapon_plan_failures_for_model(plasma_state, rider_squad, riders[1], target_squad)
	check(plasma_failures.is_empty(), "Plasma Pistol Standard and Supercharge both resolve through Equipment and AttackPlan: %s" % str(plasma_failures))
	var restore_plasma_choice := choice_for(plasma_state, 1, "outrider-plasma-pistol", riders[1], rider_squad, "off")
	var restore_plasma := PublicUnitCommand.submit(plasma_state, 1, restore_plasma_choice)
	check(restore_plasma.get("error", "").is_empty() and plasma_state.units[riders[1]].ranged_weapons[0].id == "heavy-bolt-pistol" and int(plasma_state.squads[rider_squad].training_cost) == base_cost, "The public choice restores the Heavy Bolt Pistol without changing points")

	for melee_kind: String in ["power-weapon", "thunder-hammer"]:
		var melee_state: Dictionary = state.duplicate(true)
		var selected_melee := choice_for(melee_state, 1, "outrider-melee", riders[0], rider_squad, melee_kind)
		var melee_cost := int(melee_state.squads[rider_squad].training_cost)
		var melee_result := PublicUnitCommand.submit(melee_state, 1, selected_melee)
		check(not selected_melee.is_empty() and melee_result.get("error", "").is_empty() and melee_state.units[riders[0]].melee_weapons[0].id == melee_kind and int(melee_state.squads[rider_squad].training_cost) == melee_cost, "The Sergeant can select the free %s through the public command" % melee_kind)
		var option_failures := weapon_plan_failures_for_model(melee_state, rider_squad, riders[0], target_squad)
		check(option_failures.is_empty(), "%s resolves through Equipment and AttackPlan: %s" % [melee_kind, str(option_failures)])
		var restore_melee_choice := choice_for(melee_state, 1, "outrider-melee", riders[0], rider_squad, "chainsword")
		var restore_melee := PublicUnitCommand.submit(melee_state, 1, restore_melee_choice)
		check(restore_melee.get("error", "").is_empty() and melee_state.units[riders[0]].melee_weapons[0].id == "chainsword", "The Sergeant can restore its Chainsword")
	check(choice_for(state, 1, "outrider-melee", riders[1], rider_squad, "power-weapon").is_empty(), "Regular Outriders cannot take Sergeant-only melee replacements")

	var six_state := fixture(6)
	var six_riders := models(six_state, UNIT, 1)
	var six_squad := squad_for(six_state, UNIT, 1)
	check(not six_state.has("error") and six_riders.size() == 6 and int(six_state.squads[six_squad].training_cost) == 160, "Six-model Outrider Squad materializes at 160 points")
	if six_riders.size() == 6:
		var six_sergeant := -1
		for model: int in six_riders:
			if six_state.units[model].get("sergeant", false): six_sergeant = model
		var six_plasma_candidates: Array[Dictionary] = []
		for model: int in six_riders:
			var candidate := choice_for(six_state, 1, "outrider-plasma-pistol", model, six_squad, "on")
			if not candidate.is_empty(): six_plasma_candidates.append(candidate)
		check(six_plasma_candidates.size() == 6, "Every model in the six-model unit can be selected for a Plasma Pistol")
		var six_cost := int(six_state.squads[six_squad].training_cost)
		var sergeant_plasma := choice_for(six_state, 1, "outrider-plasma-pistol", six_sergeant, six_squad, "on")
		var first_plasma := PublicUnitCommand.submit(six_state, 1, sergeant_plasma)
		var second_plasma_model: int = six_riders[1] if six_riders[1] != six_sergeant else six_riders[2]
		var second_plasma := choice_for(six_state, 1, "outrider-plasma-pistol", second_plasma_model, six_squad, "on")
		var second_result := PublicUnitCommand.submit(six_state, 1, second_plasma)
		check(first_plasma.get("error", "").is_empty() and second_result.get("error", "").is_empty() and int(six_state.squads[six_squad].training_cost) == six_cost, "Two models, including the Sergeant, may take Plasma Pistols for no extra points")
		var third_model: int = six_riders[3]
		var capped_choice := choice_for(six_state, 1, "outrider-plasma-pistol", third_model, six_squad, "on")
		var third_result := PublicUnitCommand.submit(six_state, 1, capped_choice)
		check(capped_choice.is_empty() and not str(third_result.get("error", "")).is_empty(), "The six-model unit caps at two Plasma Pistols")
		var restore_six_choice := choice_for(six_state, 1, "outrider-plasma-pistol", six_sergeant, six_squad, "off")
		var restored_six := PublicUnitCommand.submit(six_state, 1, restore_six_choice)
		var freed_slot := choice_for(six_state, 1, "outrider-plasma-pistol", third_model, six_squad, "on")
		var freed_result := PublicUnitCommand.submit(six_state, 1, freed_slot)
		check(restored_six.get("error", "").is_empty() and freed_result.get("error", "").is_empty(), "Restoring a Heavy Bolt Pistol frees a Plasma Pistol slot")

	var uncharged_chain := melee_batch(state, rider_squad, riders[1], target_squad, "chainsword", false)
	var charged_chain := melee_batch(state, rider_squad, riders[1], target_squad, "chainsword", true)
	var power_state: Dictionary = state.duplicate(true)
	var power_choice := choice_for(power_state, 1, "outrider-melee", riders[0], rider_squad, "power-weapon")
	var power_result := PublicUnitCommand.submit(power_state, 1, power_choice)
	var charged_power := melee_batch(power_state, rider_squad, riders[0], target_squad, "power-weapon", true)
	var hammer_state: Dictionary = state.duplicate(true)
	var hammer_choice := choice_for(hammer_state, 1, "outrider-melee", riders[0], rider_squad, "thunder-hammer")
	PublicUnitCommand.submit(hammer_state, 1, hammer_choice)
	var uncharged_hammer := melee_batch(hammer_state, rider_squad, riders[0], target_squad, "thunder-hammer", false)
	var charged_hammer := melee_batch(hammer_state, rider_squad, riders[0], target_squad, "thunder-hammer", true)
	check(uncharged_chain.get("weapon", {}).get("damage") == 1 and uncharged_chain.get("weapon", {}).get("keywords", {}).get("sustained-hits", 0) == 0 and int(uncharged_chain.get("context", {}).get("hit_modifier", 0)) == 0, "Full-throttle Assault is inactive without a Charge move")
	check(charged_chain.get("weapon", {}).get("damage") == 2 and charged_chain.get("weapon", {}).get("keywords", {}).get("sustained-hits", 0) == 1 and int(charged_chain.get("context", {}).get("hit_modifier", 0)) == 0, "A charged Chainsword gains +1 Damage and Sustained Hits 1 through AttackPlan")
	check(power_result.get("error", "").is_empty() and charged_power.get("weapon", {}).get("damage") == 2 and charged_power.get("weapon", {}).get("keywords", {}).get("sustained-hits", 0) == 1, "A charged Power Weapon gains +1 Damage and Sustained Hits 1 through AttackPlan")
	check(uncharged_hammer.get("weapon", {}).get("damage") == 3 and uncharged_hammer.get("context", {}).get("hit_modifier", 0) == 0 and uncharged_hammer.get("weapon", {}).get("keywords", {}).get("sustained-hits", 0) == 0, "Thunder Hammer receives no Full-throttle bonus without a Charge move")
	check(charged_hammer.get("weapon", {}).get("damage") == 3 and charged_hammer.get("context", {}).get("hit_modifier", 0) == 1 and charged_hammer.get("weapon", {}).get("keywords", {}).get("sustained-hits", 0) == 1, "A charged Thunder Hammer gains +1 to hit and Sustained Hits 1, with no Damage bonus")

	var captain_choice := choice_for(state, 1, "attach", captain, rider_squad)
	var before_wrong_leader := var_to_bytes(state)
	var wrong_leader := PublicUnitCommand.submit(state, 2, captain_choice)
	check(not captain_choice.is_empty() and not str(wrong_leader.get("error", "")).is_empty() and before_wrong_leader == var_to_bytes(state), "The opposing player cannot attach the Captain on Bike")
	var attach_result := PublicUnitCommand.submit(state, 1, captain_choice)
	check(attach_result.get("error", "").is_empty() and int(state.units[captain].squad) == rider_squad and state.units[captain].get("attachment_role", "") == "leader", "The Captain on Bike joins Outriders through the public preparation command")

	print("Current Outrider Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

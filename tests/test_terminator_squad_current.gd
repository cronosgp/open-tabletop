extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const ListRoster = preload("res://scripts/army_roster.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "terminator-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:terminator-squad"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("captain-in-terminator-armour"), entry(UNIT, 5), entry(UNIT, 10)]
	result[2].entries = [entry("intercessor-squad", 10), entry(UNIT, 5), entry(UNIT, 10)]
	return result

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true,
		"awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}, lists())
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.phase_key = U.key(state)
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	return state

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or A.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func models_for(state: Dictionary, squad: int, identity: String = UNIT) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and A.identity(state.units[model]) == identity and int(state.units[model].get("wounds", 0)) > 0:
			result.append(model)
	result.sort()
	return result

func model_for(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and A.identity(unit) == UNIT and bool(unit.get("sergeant", false)) == sergeant: return model
	return -1

func find_choice(state: Dictionary, owner: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in U.choices(state, owner):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit(state: Dictionary, owner: int, action: String, model: int = -1, target: int = -1, value: String = "", point: Vector2 = Vector2.ZERO) -> String:
	var selected := find_choice(state, owner, action, model, target, value)
	if selected.is_empty(): return "Missing %s choice (model=%d target=%d value=%s)." % [action, model, target, value]
	return str(PublicUnitCommand.submit(state, owner, selected, point).get("error", ""))

func profile_weapon(profile: Dictionary, category: String, identity: String, profile_id: String = "standard", additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for weapon: Dictionary in rows:
		if str(weapon.get("id", "")) == identity:
			return weapon.get("profiles", {}).get(profile_id, {})
	return {}

func check_profile(profile: Dictionary) -> void:
	check(profile.get("name", "") == "Terminator Squad" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000001183" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile identifies the shared-book datasheet and verified local export revision")
	check(profile.get("points_by_models", {}) == {5: 190, 10: 380} and profile.get("third_plus_points_by_models", {}) == {5: 230, 10: 420} and profile.get("wargear_costs", {}) == {"cyclone-missile-launcher": 10}, "Both source unit sizes, third-plus prices and the Cyclone surcharge match the export")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "M5/T6/Sv2+/W3/Ld6+/OC1/4++ and 40 mm bases match the source")
	var keywords: Array = profile.get("keywords", []).duplicate()
	check(keywords.has("ADEPTUS ASTARTES") and keywords.has("IMPERIUM") and keywords.has("INFANTRY") and keywords.has("TERMINATOR") and not keywords.has("DEATHWING"), "Shared-book keywords remain distinct from the Chapter-contextual Deathwing keyword")
	check(profile.get("ranged", []).size() == 1 and profile.get("melee", []).size() == 1 and profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 3 and profile.get("additional_weapon_profiles", {}).get("melee", []).size() == 2, "Default profiles and every source-listed optional weapon family are present")
	check(profile_weapon(profile, "ranged", "storm-bolter") == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "Storm Bolter profile matches the source")
	check(profile_weapon(profile, "melee", "power-fist") == {"name": "Power Fist", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}, "Power Fist profile matches the source")
	check(profile_weapon(profile, "ranged", "assault-cannon", "standard", true) == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}}, "Assault Cannon profile matches the source")
	check(profile_weapon(profile, "ranged", "heavy-flamer", "standard", true) == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": 0, "strength": 5, "ap": -1, "damage": 1, "keywords": {"torrent": true, "blast": 2}}, "Heavy Flamer Torrent and Blast profile matches the source")
	check(profile_weapon(profile, "ranged", "cyclone-missile-launcher", "frag", true) == {"name": "Cyclone Missile Launcher - Frag", "range_inches": 36.0, "attacks": 8, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 2}} and profile_weapon(profile, "ranged", "cyclone-missile-launcher", "krak", true) == {"name": "Cyclone Missile Launcher - Krak", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}}, "Both Cyclone launcher profiles match the source")
	check(profile_weapon(profile, "melee", "chainfist", "standard", true) == {"name": "Chainfist - Standard", "range_inches": 0.0, "attacks": 2, "skill": 4, "strength": 8, "ap": -2, "damage": 2, "keywords": {}} and profile_weapon(profile, "melee", "chainfist", "hunter", true) == {"name": "Chainfist - Hunter", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 12, "ap": -2, "damage": 3, "keywords": {"hunter": ["Monster", "Vehicle"]}}, "Standard and Hunter Chainfist profiles preserve their source target condition")
	check(profile_weapon(profile, "melee", "power-weapon", "standard", true) == {"name": "Power Weapon", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {}}, "Power Weapon profile matches the source")

func check_catalog_and_relations() -> void:
	var choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 5, "cost": 190, "third_plus_cost": 230}, {"models": 10, "cost": 380, "third_plus_cost": 420}], "The consolidated catalog offers source sizes and first-two/third-plus costs")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {5: 190, 10: 380} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {5: 230, 10: 420} and Roster.POINTS.get(UNIT, {}).get("wargear_costs", {}) == {"cyclone-missile-launcher": 10}, "Roster price authority matches the local export")
	var three_report := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [entry(UNIT, 5, 3)]})
	check(str(three_report.get("error", "")).is_empty() and int(three_report.get("total", -1)) == 610, "Custom lists preserve third-plus price tiers: 190 + 190 + 230 points")
	var saved_list := ListRoster.new_list("11e", "Space Marines", "custom", 1000)
	saved_list.entries.append({"unit_id": UNIT_ID, "name": "Terminator Squad", "edition": "11e", "faction": "Space Marines", "role": "Other units", "models": 5, "cost": 190, "third_plus_cost": 230, "copies": 3, "source_digest": Profiles.digest()})
	check(ListRoster.summary(saved_list).points == 610 and ListRoster.entry_cost(saved_list.entries, 0) == 610, "Saved roster summary applies the third-plus tier to grouped copies")
	saved_list.entries[0].copies = 2
	var third_row: Dictionary = saved_list.entries[0].duplicate(true)
	third_row.copies = 1
	saved_list.entries.append(third_row)
	check(ListRoster.summary(saved_list).points == 610 and ListRoster.entry_cost(saved_list.entries, 1) == 230, "Saved roster summary also applies the tier when copies use split rows")
	var incursion := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-in-terminator-armour"), entry(UNIT, 5), entry(UNIT, 10)]}
	check(C.RosterValidation.admit(incursion).get("error", "").is_empty(), "Local 1,000-point Incursion validator admits two copies")
	incursion.entries.append(entry(UNIT, 5))
	check(not str(C.RosterValidation.admit(incursion).get("error", "")).is_empty(), "Local Incursion validator rejects a third non-Battleline copy without removing its source price")
	var leaders: Array[String] = []
	for identity: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[identity] and not SupportAttachments.BODYGUARDS.has(identity): leaders.append(identity)
	leaders.sort()
	check(leaders == ["caanok-var", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "darnath-lysander", "librarian-in-terminator-armour", "marneus-calgar"], "All six common-book Leader links are represented")
	var supports: Array[String] = []
	for identity: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[identity]: supports.append(identity)
	supports.sort()
	check(supports == ["ancient-in-terminator-armour"], "The common-book Ancient in Terminator Armour Support link is represented")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "Catalog exposes this source-bounded local validation scope")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["deep-strike", "teleport-homer", "fury-of-the-first"], "Core Deep Strike and both current datasheet abilities are assigned to this profile")
	check(CapabilityRegistry.KNOWN.get("fury-of-the-first", {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "Capability registry records the verified Fury of the First scope")

func check_weapon_plans(state: Dictionary, model: int, enemy: int, label: String) -> void:
	var loadout := {"ranged": state.units[model].get("ranged_weapons", []).duplicate(true), "melee": state.units[model].get("melee_weapons", []).duplicate(true)}
	var issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, loadout, model, enemy)
	check(issues.is_empty(), "%s reaches Equipment and AttackPlan: %s" % [label, str(issues)])

func check_loadouts(state: Dictionary, five: int, ten: int, enemy: int) -> void:
	var five_models := models_for(state, five)
	var ten_models := models_for(state, ten)
	check(five_models.size() == 5 and ten_models.size() == 10, "Both players materialize the source five- and ten-model unit sizes")
	if five_models.size() != 5 or ten_models.size() != 10: return
	var enemy_five := find_squad(state, 2, UNIT, 5)
	var enemy_ten := find_squad(state, 2, UNIT, 10)
	check(state.squads[five].training_cost == 190 and state.squads[ten].training_cost == 380 and state.squads[enemy_five].training_cost == 190 and state.squads[enemy_ten].training_cost == 380, "Both current Marine catalogs materialize both sizes at first-two costs")
	check(five_models.all(func(model: int) -> bool: return state.units[model].wounds == 3 and is_equal_approx(float(state.units[model].radius), 20.0 / 25.4) and state.units[model].get("ranged_weapons", []).any(func(w: Dictionary) -> bool: return w.get("id", "") == "storm-bolter") and state.units[model].get("melee_weapons", []).any(func(w: Dictionary) -> bool: return w.get("id", "") == "power-fist")), "Every model starts with source wounds/base and Storm Bolter + Power Fist")
	check(A.has(state, five, "deep-strike") and A.has(state, five, "teleport-homer") and A.has(state, five, "fury-of-the-first"), "The current Terminator Squad receives all three supported abilities")
	var sergeant := model_for(state, five, true)
	var regulars: Array[int] = models_for(state, five).filter(func(model: int) -> bool: return model != sergeant)
	var special := regulars[0]
	var selection := find_choice(state, 1, "terminator-melee", sergeant, five, "power-weapon")
	check(not selection.is_empty() and submit(state, 1, "terminator-melee", sergeant, five, "power-weapon").is_empty() and state.units[sergeant].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "power-weapon"), "Sergeant can replace its Power Fist with a Power Weapon")
	check(find_choice(state, 1, "terminator-melee", special, five, "power-weapon").is_empty(), "A regular Terminator cannot select the Sergeant-only Power Weapon")
	check(submit(state, 1, "terminator-melee", sergeant, five, "chainfist").is_empty() and state.units[sergeant].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "chainfist"), "Sergeant can instead replace its Power Fist with a Chainfist")
	check(submit(state, 1, "terminator-melee", sergeant, five, "power-fist").is_empty(), "Sergeant can restore its default Power Fist")
	var before := var_to_bytes(state)
	var forged := {"action": "terminator-melee", "model": sergeant, "target": five, "value": "power-weapon"}
	check(not str(PublicUnitCommand.submit(state, 2, forged).get("error", "")).is_empty() and var_to_bytes(state) == before, "Opponent cannot alter this unit's selected equipment")
	for model: int in regulars:
		check(submit(state, 1, "terminator-melee", model, five, "chainfist").is_empty(), "Any number of regular Terminators may select Chainfists")
	check(regulars.all(func(model: int) -> bool: return state.units[model].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "chainfist")), "All four regular Terminators can retain the independent melee replacement")
	check(submit(state, 1, "terminator-special-weapon", special, five, "assault-cannon").is_empty() and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "assault-cannon") and not state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter"), "Assault Cannon replaces the regular model's Storm Bolter")
	check(find_choice(state, 1, "terminator-special-weapon", sergeant, five, "assault-cannon").is_empty(), "Sergeant is excluded from regular-model special-gun choices")
	check(find_choice(state, 1, "terminator-special-weapon", regulars[1], five, "heavy-flamer").is_empty(), "A five-model unit is capped at one special gun")
	check(submit(state, 1, "terminator-special-weapon", special, five, "heavy-flamer").is_empty() and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "heavy-flamer"), "The special-gun choice is reversible among source-listed alternatives")
	check(submit(state, 1, "terminator-special-weapon", special, five, "cyclone-missile-launcher").is_empty() and int(state.squads[five].training_cost) == 200 and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "cyclone-missile-launcher" and w.profiles.frag.attacks == 8 and w.profiles.krak.damage == "D3+3") and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter"), "Cyclone adds both launcher profiles, retains its Storm Bolter and costs 10 points")
	var ten_regulars: Array[int] = models_for(state, ten).filter(func(model: int) -> bool: return not state.units[model].get("sergeant", false))
	check(submit(state, 1, "terminator-special-weapon", ten_regulars[0], ten, "cyclone-missile-launcher").is_empty() and int(state.squads[ten].training_cost) == 390, "First Cyclone on a ten-model unit adds 10 points")
	check(submit(state, 1, "terminator-special-weapon", ten_regulars[1], ten, "assault-cannon").is_empty() and find_choice(state, 1, "terminator-special-weapon", ten_regulars[2], ten, "heavy-flamer").is_empty(), "Ten models allow two special guns, with no third choice")
	check(submit(state, 1, "terminator-special-weapon", ten_regulars[1], ten, "none").is_empty() and int(state.squads[ten].training_cost) == 390 and not find_choice(state, 1, "terminator-special-weapon", ten_regulars[2], ten, "heavy-flamer").is_empty(), "Restoring Storm Bolter frees the second special-gun slot without changing points")
	check(submit(state, 1, "terminator-special-weapon", ten_regulars[1], ten, "cyclone-missile-launcher").is_empty() and int(state.squads[ten].training_cost) == 400, "Replacing a gun with Cyclone charges one 10-point surcharge")
	check(submit(state, 1, "terminator-special-weapon", ten_regulars[1], ten, "none").is_empty() and int(state.squads[ten].training_cost) == 390, "Removing a Cyclone refunds its surcharge exactly once")
	check(submit(state, 1, "terminator-special-weapon", special, five, "none").is_empty() and int(state.squads[five].training_cost) == 190, "Restoring Storm Bolter refunds the five-model Cyclone surcharge")
	for model: int in state.units:
		if int(state.units[model].owner) == 2: state.units[model].keywords = ["VEHICLE"]
	check_weapon_plans(state, sergeant, enemy, "Power Fist and Storm Bolter")
	check_weapon_plans(state, special, enemy, "Cyclone Missile Launcher frag/krak and retained Storm Bolter")
	check_weapon_plans(state, ten_regulars[1], enemy, "Assault Cannon and Power Fist")
	check_weapon_plans(state, ten_regulars[2], enemy, "Storm Bolter and Power Fist")
	for model: int in regulars:
		check_weapon_plans(state, model, enemy, "Regular Chainfist standard/Hunter profiles")

func check_fury_of_the_first() -> void:
	var state := fixture()
	check(not state.has("error"), "Fury test current-catalog fixture materializes")
	if state.has("error"): return
	var squad := find_squad(state, 1, UNIT, 5)
	var enemy := find_squad(state, 2, "intercessor-squad", 10)
	var captain := -1
	for model: int in state.units:
		if int(state.units[model].owner) == 1 and A.identity(state.units[model]) == "captain-in-terminator-armour": captain = model
	check(squad > 0 and enemy > 0 and captain >= 0, "Fury test has a Terminator unit, target and source-listed attached Leader")
	if squad <= 0 or enemy <= 0 or captain < 0: return
	for model: int in models_for(state, enemy, "intercessor-squad"): state.units[model].position = Vector2(0, 0)
	var models := models_for(state, squad)
	var attacker := models[0]
	var nearby := models[1]
	state.units[attacker].position = Vector2(-20, 0)
	state.units[nearby].position = Vector2(10.0, 0)
	var storm_bolter: Dictionary = state.units[attacker].ranged_weapons[0].profiles.standard
	var ranged := A.weapon(state, attacker, enemy, storm_bolter, false)
	check(int(ranged.get("ap", 0)) == -2, "Fury grants +1 AP to a ranged attack when another model in its unit is within 9 inches")
	state.phase = "shooting"
	state.unit_abilities.phase_key = U.key(state)
	var ranged_plan := C.AttackPlan.prepare(state, squad, false, [{"model": attacker, "target": enemy, "amount": 1, "weapon": "storm-bolter", "profile": "standard"}], true)
	check(str(ranged_plan.get("error", "")).is_empty() and ranged_plan.get("batches", []).size() == 1 and int(ranged_plan.batches[0].weapon.ap) == -2, "Fury's unit-range bonus reaches the resolved ranged AttackPlan")
	state.units[nearby].position = Vector2(11.0, 0)
	ranged = A.weapon(state, attacker, enemy, storm_bolter, false)
	check(int(ranged.get("ap", 0)) == -1, "Fury stops applying when the whole unit is outside 9 inches")
	ranged_plan = C.AttackPlan.prepare(state, squad, false, [{"model": attacker, "target": enemy, "amount": 1, "weapon": "storm-bolter", "profile": "standard"}], true)
	check(str(ranged_plan.get("error", "")).is_empty() and ranged_plan.get("batches", []).size() == 1 and int(ranged_plan.batches[0].weapon.ap) == -1, "Ranged AttackPlan omits Fury outside the 9-inch unit range")
	state.units[nearby].position = Vector2(10.0, 0)
	state.units[attacker].position = Vector2(1.5, 0)
	var fist: Dictionary = state.units[attacker].melee_weapons[0].profiles.standard
	var melee := A.weapon(state, attacker, enemy, fist, true)
	check(int(melee.get("ap", 0)) == -3, "Fury also grants +1 AP to melee attacks against a target within the unit range")
	state.phase = "fight"
	state.unit_abilities.phase_key = U.key(state)
	var melee_plan := C.AttackPlan.prepare(state, squad, true, [{"model": attacker, "target": enemy, "amount": 3, "weapon": "power-fist", "profile": "standard"}], true)
	check(str(melee_plan.get("error", "")).is_empty() and melee_plan.get("batches", []).size() == 1 and int(melee_plan.batches[0].weapon.ap) == -3, "Fury's AP bonus reaches the resolved melee AttackPlan")
	U.attach(state, captain, squad)
	state.units[captain].position = Vector2(1.5, 0)
	var captain_weapon: Dictionary = state.units[captain].melee_weapons[0].profiles.standard
	var attached_melee := A.weapon(state, captain, enemy, captain_weapon, true)
	check(int(attached_melee.get("ap", 0)) == int(captain_weapon.get("ap", 0)) - 1, "Fury applies to attacks from a Captain attached to the Terminator unit")

func check_homer_and_ingress() -> void:
	var state := fixture()
	check(not state.has("error"), "Teleport Homer fixture materializes")
	if state.has("error"): return
	var five := find_squad(state, 1, UNIT, 5)
	var ten := find_squad(state, 1, UNIT, 10)
	var enemy := find_squad(state, 2, "intercessor-squad", 10)
	if five <= 0 or ten <= 0 or enemy <= 0:
		check(false, "Teleport Homer fixture contains both Terminator units and an enemy unit")
		return
	var five_models := models_for(state, five)
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = []
	state.phase = "deployment"
	state.unit_abilities.reserves[five] = {"cost": int(state.squads[five].training_cost), "source": "strategic-reserves"}
	for model: int in five_models: state.units[model].on_battlefield = false
	state.phase = "start_turn"
	state.unit_abilities.phase_key = U.key(state)
	var zones: Dictionary = state.deployment.get("zones", {})
	var enemy_zone: Rect2 = zones.get(2, Rect2(Vector2(8, 0), Vector2(8, 8)))
	var homer_point := enemy_zone.get_center()
	var homer_error := submit(state, 1, "homer", -1, five, "", homer_point)
	check(U.battle_actor(state) == 1 and homer_error.is_empty(), "Owner can place a Teleport Homer at battle start for a reserve Terminator unit: actor=%d error=%s" % [U.battle_actor(state), homer_error])
	check(state.unit_abilities.homers.get(five, Vector2.INF) == homer_point and find_choice(state, 1, "homer", -1, five).is_empty(), "Each unit can place its token once per battle")
	check(submit(state, 1, "homer", -1, ten, "", Vector2(5, 5)).is_empty(), "A second Terminator unit independently places its own Homer")
	check(find_choice(state, 2, "homer", -1, ten).is_empty(), "Opponent cannot place the Terminator player's Homer")
	for model: int in state.units:
		if int(state.units[model].owner) == 2: state.units[model].position = Vector2(-18, -12)
	var moving_enemy := models_for(state, enemy, "intercessor-squad")[0]
	state.units[moving_enemy].position = Vector2(5, 5)
	U.end_move(state, enemy)
	check(not state.unit_abilities.homers.has(ten) and state.unit_abilities.homers.has(five), "Enemy move ending within one inch removes only that unit's Homer")
	for model: int in state.units:
		if int(state.units[model].owner) == 2: state.units[model].position = Vector2(-18, -12)
	check(submit(state, 1, "battle-done").is_empty() and submit(state, 2, "battle-done").is_empty(), "Both players finish the battle-start declaration window")
	state.phase = "movement"
	state.active = 2
	state.turn = 4
	state.round = 2
	state.cp[1] = 0
	state.unit_abilities.phase_key = U.key(state)
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	var advance_error := C.advance_phase(state, 2, state.revision)
	check(advance_error.is_empty() and U.pending(state).get("kind", "") == "end", "Opponent Movement end window opens for Rapid Ingress: " + advance_error)
	check(U.rapid_ingress_squads(state, 1) == [five] and not find_choice(state, 1, "homer-ingress", -1, five).is_empty(), "Teleport Homer enables its unit's zero-CP Rapid Ingress option")
	var ingress_error := submit(state, 1, "homer-ingress", -1, five)
	check(ingress_error.is_empty() and bool(state.unit_abilities.window.get("deep_strike", false)), "Ingress preserves the Terminator unit's Deep Strike arrival method: " + ingress_error)
	check(C.living(state, five).is_empty(), "The five-model unit stays in reserve until placement is confirmed")
	var reserve_models := models_for(state, five)
	var enemy_model := models_for(state, enemy, "intercessor-squad")[0]
	check(not submit(state, 1, "ingress-place", reserve_models[0], five, "", state.units[enemy_model].position).is_empty(), "Deep Strike ingress still enforces more than eight inches from every enemy")
	for index: int in reserve_models.size():
		var point := Vector2(8.0 + float(index % 3) * 1.68, 8.0 + float(index / 3) * 1.68)
		check(submit(state, 1, "ingress-place", reserve_models[index], five, "", point).is_empty(), "Unit stages coherent Deep Strike positions outside enemy distance")
	check(not submit(state, 1, "ingress-confirm").is_empty(), "Homer ingress cannot be confirmed when models are more than three inches from its token")
	for index: int in reserve_models.size():
		var point := homer_point + Vector2(float(index % 3) * 1.68, float(index / 3) * 1.68)
		check(submit(state, 1, "ingress-place", reserve_models[index], five, "", point).is_empty(), "Unit can restage coherent positions within three inches of the Homer")
	check(submit(state, 1, "ingress-confirm").is_empty() and int(state.cp[1]) == 0 and not state.unit_abilities.homers.has(five) and C.living(state, five).size() == 5, "Homer Rapid Ingress is free, consumes the token and sets up the whole unit")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check_profile(profile)
	check_catalog_and_relations()
	var state := fixture()
	check(not state.has("error"), "Both players materialize from the current Marine catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Current Terminator Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var five := find_squad(state, 1, UNIT, 5)
	var ten := find_squad(state, 1, UNIT, 10)
	var enemy := find_squad(state, 2, "intercessor-squad", 10)
	check(five > 0 and ten > 0 and enemy > 0 and find_squad(state, 2, UNIT, 5) > 0 and find_squad(state, 2, UNIT, 10) > 0, "Both current catalogs contain both supported Terminator sizes")
	if five > 0 and ten > 0 and enemy > 0:
		check_loadouts(state, five, ten, enemy)
	check_fury_of_the_first()
	check_homer_and_ingress()
	print("Current Terminator Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

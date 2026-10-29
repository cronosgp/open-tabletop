extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "deathwing-terminator-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:deathwing-terminator-squad"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, model_count: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": copies}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 5), entry("belial"), entry("ancient-in-terminator-armour")]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("inner-circle-companions", 3), entry("belial")]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections())

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func option(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for item: Dictionary in U.choices(state, player):
		if str(item.get("action", "")) != action: continue
		if model >= 0 and int(item.get("model", -1)) != model: continue
		if target >= 0 and int(item.get("target", -1)) != target: continue
		if not value.is_empty() and str(item.get("value", "")) != value: continue
		return item
	return {}

func submit(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "", point: Vector2 = Vector2.ZERO) -> String:
	var selected := option(state, player, action, model, target, value)
	if selected.is_empty(): return "Missing %s choice (model=%d target=%d value=%s)." % [action, model, target, value]
	return str(PublicUnitCommand.submit(state, player, selected, point).get("error", ""))

func profile_weapon(profile: Dictionary, category: String, identity: String, profile_id: String = "standard", additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for item: Dictionary in rows:
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get(profile_id, {})
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000230" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Deathwing Terminator Squad identifies its pinned Dark Angels App source row")
	check(profile.get("points_by_models", {}) == {5: 190, 10: 380} and profile.get("third_plus_points_by_models", {}) == {5: 230, 10: 420} and profile.get("wargear_costs", {}) == {"cyclone-missile-launcher": 10} and profile.get("max_supported_copies", 0) == 3, "Both source unit sizes, third-plus prices, Cyclone surcharge and copy cap match the export")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and profile.get("base_size_source_mm") == 40, "M5/T6/Sv2+/W3/Ld6+/OC1/4++ and 40 mm bases match the source")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TERMINATOR", "DEATHWING", "IMPERIUM"], "Datasheet and faction keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Deathwing Sergeant", {}) == {"Power Fist": 1, "Storm Bolter": 1} and profile.get("default_loadout_by_role", {}).get("Deathwing Terminators", {}) == {"Power Fist": 1, "Storm Bolter": 1}, "The Sergeant and regular models share the exported default loadout")
	check(profile_weapon(profile, "ranged", "storm-bolter") == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "Storm Bolter matches the source profile")
	check(profile_weapon(profile, "melee", "power-fist") == {"name": "Power Fist", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}, "Power Fist matches the source profile")
	check(profile_weapon(profile, "ranged", "assault-cannon", "standard", true) == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}} and profile_weapon(profile, "ranged", "heavy-flamer", "standard", true).get("keywords", {}).get("torrent", false), "Assault Cannon and Heavy Flamer profiles are source-linked")
	check(profile_weapon(profile, "ranged", "cyclone-missile-launcher", "frag", true).get("attacks") == 8 and profile_weapon(profile, "ranged", "cyclone-missile-launcher", "krak", true).get("damage") == "D3+3", "Both Cyclone Missile Launcher profiles match the source")
	check(profile_weapon(profile, "ranged", "plasma-cannon", "standard", true).get("strength") == 7 and profile_weapon(profile, "ranged", "plasma-cannon", "supercharge", true).get("keywords", {}).get("hazardous", false) and profile_weapon(profile, "ranged", "plasma-cannon", "supercharge", true).get("damage") == 3, "Plasma Cannon standard and Hazardous supercharge profiles match the source")
	check(profile_weapon(profile, "melee", "chainfist", "standard", true).get("skill") == 4 and profile_weapon(profile, "melee", "chainfist", "hunter", true).get("keywords", {}).has("hunter") and profile_weapon(profile, "melee", "power-weapon", "standard", true).get("attacks") == 5, "Chainfist target profiles and Sergeant Power Weapon are represented")

	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 5, "cost": 190, "third_plus_cost": 230}, {"models": 10, "cost": 380, "third_plus_cost": 420}], "The consolidated local catalog exposes both legal unit sizes and price tiers")
	check(Roster.POINTS.get(UNIT, {}).get("wargear_costs", {}) == {"cyclone-missile-launcher": 10} and Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "The validated profile is admitted with its exported option surcharge")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 5, 3)]})
	check(str(three_copies.get("error", "")).is_empty() and int(three_copies.get("total", -1)) == 610, "Three copies use the first-two and third-plus costs")
	var ten_selections := selections()
	ten_selections[1].entries = [entry(UNIT, 10)]
	ten_selections[2].entries = [entry("intercessor-squad", 5)]
	var ten_state := F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, ten_selections)
	var ten_models := models(ten_state, UNIT, 1) if not ten_state.has("error") else []
	check(not ten_state.has("error") and ten_models.size() == 10 and int(ten_state.squads[int(ten_state.units[ten_models[0]].squad)].training_cost) == 380, "A ten-model Deathwing unit materializes at its first-two source price")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["deep-strike", "combat-doctrines", "deathwing", "watcher-in-the-dark"], "Deep Strike, Combat Doctrines and both datasheet abilities are assigned without unrelated Terminator abilities")
	for ability: String in ["deathwing", "watcher-in-the-dark"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("supported", false) and capability.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "%s is recorded in the source-bounded capability registry" % ability)

	for link: Array in [["belial", "Belial"], ["captain-in-terminator-armour", "Terminator Captain"], ["chaplain-in-terminator-armour", "Terminator Chaplain"], ["librarian-in-terminator-armour", "Terminator Librarian"]]:
		check(UNIT in LeaderLinks.targets(str(link[0])), "%s retains its source-listed Leader link" % str(link[1]))
	check(UNIT in Supports.BODYGUARDS.get("ancient-in-terminator-armour", []), "Ancient in Terminator Armour retains its source Support relation")
	check(UNIT in LeaderLinks.targets("ancient-in-terminator-armour"), "Ancient in Terminator Armour source link map includes this Support target")

	var state := fixture()
	check(not state.has("error"), "The Deathwing, Leader, Support and opponent rosters materialize: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Deathwing Terminator Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var deathwing_models := models(state, UNIT, 1)
	var belial_models := models(state, "belial", 1)
	var ancient_models := models(state, "ancient-in-terminator-armour", 1)
	var enemy_companions := models(state, "inner-circle-companions", 2)
	var enemy_belial := models(state, "belial", 2)
	check(deathwing_models.size() == 5 and belial_models.size() == 1 and ancient_models.size() == 1 and enemy_companions.size() == 3 and enemy_belial.size() == 1, "The source unit sizes and required interaction targets materialize")
	if deathwing_models.size() != 5 or belial_models.is_empty() or ancient_models.is_empty() or enemy_companions.is_empty() or enemy_belial.is_empty():
		print("Deathwing Terminator Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := int(state.units[deathwing_models[0]].squad)
	var sergeant := -1
	var regulars: Array[int] = []
	for model: int in deathwing_models:
		if bool(state.units[model].get("sergeant", false)): sergeant = model
		else: regulars.append(model)
	var regular := regulars[0]
	var special := regulars[1]
	var enemy_squad := int(state.units[enemy_companions[0]].squad)
	var character_squad := int(state.units[enemy_belial[0]].squad)
	check(sergeant >= 0 and regulars.size() == 4 and deathwing_models.all(func(model: int) -> bool: return int(state.units[model].wounds) == 3 and state.units[model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter") and state.units[model].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "power-fist")), "Every model materializes with source wounds and Power Fist + Storm Bolter")
	check("DEATHWING" in state.units[sergeant].keywords and A.has(state, squad, "deep-strike") and A.has(state, squad, "deathwing") and A.has(state, squad, "combat-doctrines"), "Dark Angels context and the unit's shared abilities are available")
	check(not A.has(state, squad, "watcher-in-the-dark") and not A.has(state, squad, "teleport-homer") and not A.has(state, squad, "fury-of-the-first"), "Watcher is optional and absent until selected; unrelated unit abilities are not granted")
	check(option(state, 1, "terminator-melee", regular, squad, "power-weapon").is_empty(), "A regular Deathwing Terminator cannot select the Sergeant-only Power Weapon")
	check(submit(state, 1, "terminator-melee", sergeant, squad, "power-weapon").is_empty() and state.units[sergeant].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "power-weapon"), "The Sergeant can replace its Power Fist with a Power Weapon")
	check(submit(state, 1, "terminator-melee", regular, squad, "chainfist").is_empty() and state.units[regular].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "chainfist") and submit(state, 1, "terminator-melee", regular, squad, "power-fist").is_empty(), "A regular Deathwing Terminator can select and restore a Chainfist")
	check(submit(state, 1, "terminator-melee", sergeant, squad, "power-fist").is_empty(), "The Sergeant can restore its Power Fist")
	check(submit(state, 1, "terminator-special-weapon", special, squad, "plasma-cannon").is_empty() and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "plasma-cannon") and not state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter"), "Plasma Cannon replaces the selected model's Storm Bolter")
	check(option(state, 1, "terminator-special-weapon", regulars[2], squad, "assault-cannon").is_empty(), "A five-model squad is limited to one special weapon")
	check(submit(state, 1, "terminator-special-weapon", special, squad, "cyclone-missile-launcher").is_empty() and int(state.squads[squad].training_cost) == 200 and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "cyclone-missile-launcher" and w.profiles.frag.attacks == 8 and w.profiles.krak.damage == "D3+3") and state.units[special].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter"), "Cyclone keeps the Storm Bolter, exposes both profiles and adds 10 points")
	check(submit(state, 1, "terminator-special-weapon", special, squad, "none").is_empty() and int(state.squads[squad].training_cost) == 190, "Restoring the Storm Bolter refunds the Cyclone surcharge")
	check(submit(state, 1, "terminator-special-weapon", special, squad, "plasma-cannon").is_empty(), "Plasma Cannon can be selected again for the weapon profile check")
	var loadout := {"ranged": state.units[special].ranged_weapons.duplicate(true), "melee": state.units[special].melee_weapons.duplicate(true)}
	var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, loadout, special, character_squad)
	check(weapon_failures.is_empty(), "Selected weapon profiles reach Equipment and AttackPlan: %s" % str(weapon_failures))
	var watcher_choice := option(state, 1, "deathwing-knights-watcher", -1, squad, "on")
	check(not watcher_choice.is_empty() and submit(state, 1, "deathwing-knights-watcher", -1, squad, "on").is_empty() and A.has(state, squad, "watcher-in-the-dark"), "The Watcher can be equipped during army preparation and grants its ability")
	check(submit(state, 1, "deathwing-knights-watcher", -1, squad, "off").is_empty() and not A.has(state, squad, "watcher-in-the-dark"), "The optional Watcher can be removed again during preparation")
	check(submit(state, 1, "deathwing-knights-watcher", -1, squad, "on").is_empty(), "The Watcher can be equipped for its mortal-wound response")
	check(submit(state, 1, "attach", belial_models[0], squad).is_empty() and int(state.units[belial_models[0]].squad) == squad, "Belial attaches through the public preparation action")
	check(submit(state, 1, "attach", ancient_models[0], squad).is_empty() and int(state.units[ancient_models[0]].squad) == squad and state.units[ancient_models[0]].get("attachment_role", "") == "support", "Ancient in Terminator Armour attaches in its Support role")

	state.units[regular].position = Vector2.ZERO
	state.units[enemy_companions[0]].position = Vector2(1.75, 0.0)
	state.phase = "fight"
	state.active = 1
	state.unit_abilities.phase_key = U.key(state)
	var power_fist: Dictionary = state.units[regular].melee_weapons[0].profiles.standard
	check(A.hit_bonus(state, squad, enemy_squad, true, regular, power_fist) == -1, "The target's Braziers of Judgement applies a real -1 melee Hit modifier")
	var melee_plan := C.AttackPlan.prepare(state, squad, true, [{"model": regular, "target": enemy_squad, "amount": 3, "weapon": "power-fist", "profile": "standard"}], true)
	check(melee_plan.get("error", "").is_empty() and melee_plan.get("batches", []).size() == 1 and int(melee_plan.batches[0].context.get("hit_modifier", 99)) == 0, "Deathwing ignores the hit-roll modifier while resolving the melee attack")
	state.unit_abilities.weapon_skill_characteristic_modifiers = {"squads": {squad: {"WS": -1}}, "models": {}}
	melee_plan = C.AttackPlan.prepare(state, squad, true, [{"model": regular, "target": enemy_squad, "amount": 3, "weapon": "power-fist", "profile": "standard"}], true)
	check(melee_plan.get("error", "").is_empty() and melee_plan.get("batches", []).size() == 1 and int(melee_plan.batches[0].weapon.skill) == 3, "Deathwing ignores a direct WS characteristic modifier in AttackPlan")

	state.units[belial_models[0]].position = Vector2.ZERO
	state.units[enemy_belial[0]].position = Vector2(10.0, 0.0)
	for model: int in enemy_companions: state.units[model].position = Vector2(30.0, 30.0)
	state.phase = "shooting"
	state.unit_abilities.phase_key = U.key(state)
	state.unit_abilities.weapon_skill_characteristic_modifiers = {"squads": {squad: {"BS": -1}}, "models": {}}
	var belial_plan := C.AttackPlan.prepare(state, squad, false, [{"model": belial_models[0], "target": character_squad, "amount": 1, "weapon": "master-crafted-storm-bolter", "profile": "standard"}], true)
	check(belial_plan.get("error", "").is_empty() and belial_plan.get("batches", []).size() == 1 and int(belial_plan.batches[0].weapon.skill) == 2, "Deathwing also ignores a BS modifier for an attached Leader's attack: %s" % str(belial_plan))
	check(belial_plan.get("error", "").is_empty() and belial_plan.get("batches", []).size() == 1 and int(belial_plan.batches[0].context.get("wound_modifier", 0)) == 1, "Deathwing does not erase Belial's separate +1 to Wound against a CHARACTER: %s" % str(belial_plan))

	state.pending_attack = {"current": {"phase": "damage", "target": squad, "cursor": 0, "steps": [{"kind": "devastating"}]}}
	state.unit_abilities.window = {"kind": C.DetachmentStratagems.LAYERED_CERAMITE_WINDOW, "owners": [1], "squad": squad}
	var watcher := option(state, 1, "watcher-in-dark", -1, squad, "summon")
	check(not watcher.is_empty(), "The equipped Watcher is offered when the unit receives mortal wounds")
	if not watcher.is_empty():
		var watcher_result := PublicUnitCommand.submit(state, 1, watcher)
		check(str(watcher_result.get("error", "")).is_empty() and state.unit_abilities.watcher_active.get(squad, false), "The Watcher activates through the public reaction action")
		check({"target": 4, "against": "mortal"} in Prevention.rules(state, regular) and {"target": 4, "against": "mortal"} in Prevention.rules(state, belial_models[0]), "Watcher grants Feel No Pain 4+ against mortal wounds to Deathwing and attached Belial")

	if failures == 0: print("Deathwing Terminator Squad source-bounded local checks passed")
	else: print("Deathwing Terminator Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

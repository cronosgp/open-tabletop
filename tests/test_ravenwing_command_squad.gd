extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "ravenwing-command-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:ravenwing-command-squad"
const A = C.UnitAbilities
const U = C.UnitActions
const R = C.CoreReactions

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 2

func entry(identity: String, models_count: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": copies}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3), entry("ravenwing-black-knights", 3), entry("outrider-squad", 3)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}
	}, selections())
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

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in U.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000002748" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Ravenwing Command Squad cites the pinned Dark Angels App export")
	check(profile.get("points_by_models", {}) == {3: 115} and profile.get("third_plus_points_by_models", {}) == {3: 135} and profile.get("max_supported_copies", 0) == 3, "The fixed three-model group and first/second versus third-plus prices match the source")
	check(profile.get("base_size_source_mm", []) == [75, 42] and profile.get("geometry_scope", "").contains("37.5 mm bounding-circle proxy"), "The oval base is represented by the documented collision proxy")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 5}, "Each source-defined role uses the correct shared characteristics")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "CHARACTER", "DARK ANGELS", "EXPLOSIVES", "IMPERIUM", "MOUNTED", "RAVENWING"], "Every unconditional datasheet keyword is represented")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 3 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ["Ravenwing Ancient", "Ravenwing Apothecary", "Ravenwing Champion"], "Ancient, Apothecary and Champion are fixed source roles")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return w.id) == ["bolt-pistol", "plasma-talon"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return w.id) == ["corvus-hammers", "master-crafted-power-weapon"], "The aggregate weapon inventory includes the role-specific profiles")
	check(profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1 and profile.additional_weapon_profiles.ranged[0].profiles.size() == 2, "Frag and Krak Grenade Launcher profiles are catalogued")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["support", "combat-doctrines", "ravenwing-astartes-banner", "ravenwing-honour-or-death", "narthecium"], "Support, doctrines and all role abilities are assigned")
	check(Supports.BODYGUARDS.get(UNIT, []) == ["outrider-squad", "ravenwing-black-knights"], "The source Support targets are present")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {3: 115} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {3: 135}, "The construction and roster catalogs expose source prices")
	var third_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 3)]})
	var fourth_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, 4)]})
	check(third_copies.get("error", "").is_empty() and third_copies.get("total", -1) == 365 and not fourth_copy.get("error", "").is_empty(), "Roster admission prices the third copy at 135 and enforces the three-copy limit")
	for ability: String in ["ravenwing-astartes-banner", "ravenwing-honour-or-death", "narthecium"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("supported", false) and capability.get("category", "") == Registry.CATEGORY_UNIT, "%s is declared in the capability registry" % ability)

	var state := fixture()
	check(not state.has("error"), "Dark Angels rosters materialize Ravenwing Command Squad and support targets: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var command_models := models(state, UNIT, 1)
	var knights := models(state, "ravenwing-black-knights", 1)
	var outriders := squad_for(state, "outrider-squad", 1)
	var squad := squad_for(state, "ravenwing-black-knights", 1)
	var enemy := squad_for(state, "intercessor-squad", 2)
	check(command_models.size() == 3 and knights.size() == 3 and int(state.squads[squad].training_cost) == 85, "The Command Squad roles and three-model bodyguard materialize")
	var roles: Array[String] = []
	for model: int in command_models: roles.append(str(state.units[model].get("ravenwing_command_role", "")))
	check(roles == ["Ravenwing Ancient", "Ravenwing Apothecary", "Ravenwing Champion"], "Each model receives exactly one source role and its role-specific weapon")
	check(state.units[command_models[0]].melee_weapons[0].id == "corvus-hammers" and state.units[command_models[1]].melee_weapons[0].id == "corvus-hammers" and state.units[command_models[2]].melee_weapons[0].id == "master-crafted-power-weapon", "Ancient and Apothecary use Hammers; Champion uses the Power Weapon")
	var default_weapon_failures: Array[String] = []
	for model: int in command_models:
		var role_profile := Profiles.profile(UNIT)
		role_profile.ranged = state.units[model].ranged_weapons.duplicate(true)
		role_profile.melee = state.units[model].melee_weapons.duplicate(true)
		default_weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(state, role_profile, model, enemy))
	check(default_weapon_failures.is_empty(), "Every role's default weapons resolve through Equipment and AttackPlan: %s" % str(default_weapon_failures))
	check(U.attachment_allowed(state, command_models[0], squad) and U.attachment_allowed(state, command_models[0], outriders), "The Support role can join either source-listed unit")
	var attach_choice := option(state, 1, "attach", "", squad, command_models[0])
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[command_models[0]].squad) == squad and int(state.units[command_models[1]].squad) == squad and int(state.units[command_models[2]].squad) == squad, "Ravenwing Command Squad joins Black Knights as one complete Support unit: " + str(attach_result.get("error", "")))
	check(A.has(state, squad, "ravenwing-astartes-banner") and A.has(state, squad, "ravenwing-honour-or-death") and A.has(state, squad, "narthecium"), "All role abilities remain present on the combined unit")
	for model: int in knights: check(C.Morale.objective_control(state, model) == 3, "A living Ancient gives every combined unit model +1 OC")
	check(C.UnitAbilities.advance_modifier(state, squad) == 1 and C.UnitAbilities.charge_modifier(state, squad) == 1, "The living Champion grants +1 to Advance and Charge")
	check(R.cost_of(state, 1, squad, R.HEROIC) == 0 and R.cost_of(state, 1, squad, R.FRAY) == 1, "Honour or Death discounts Heroic Intervention and Into the Fray")

	state.phase = "deployment"
	var launcher_choice := option(state, 1, "ravenwing-command-grenade-launcher", "on", squad, command_models[0])
	var launcher_result := PublicUnitCommand.submit(state, 1, launcher_choice)
	check(not launcher_choice.is_empty() and launcher_result.get("error", "").is_empty() and state.units[command_models[0]].ranged_weapons[1].id == "grenade-launcher", "The Ancient can replace its Plasma Talon with a free Grenade Launcher")
	check(option(state, 1, "ravenwing-command-grenade-launcher", "on", squad, command_models[1]).is_empty(), "A three-model squad cannot select a second Grenade Launcher")
	var launcher_profile := Profiles.profile(UNIT)
	launcher_profile.ranged = state.units[command_models[0]].ranged_weapons.duplicate(true)
	launcher_profile.melee = state.units[command_models[0]].melee_weapons.duplicate(true)
	var grenade_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, launcher_profile, command_models[0], enemy)
	check(grenade_failures.is_empty(), "Both Grenade Launcher modes resolve through Equipment and AttackPlan: %s" % str(grenade_failures))
	var restore_choice := option(state, 1, "ravenwing-command-grenade-launcher", "off", squad, command_models[0])
	var restore_result := PublicUnitCommand.submit(state, 1, restore_choice)
	check(restore_result.get("error", "").is_empty() and state.units[command_models[0]].ranged_weapons[1].id == "plasma-talon" and int(state.squads[squad].training_cost) == 200, "Restoring the Plasma Talon is reversible and keeps combined points unchanged")
	var black_knight_launcher := option(state, 1, "black-knight-grenade-launcher", "on", squad, knights[0])
	var black_knight_launcher_result := PublicUnitCommand.submit(state, 1, black_knight_launcher)
	check(not black_knight_launcher.is_empty() and black_knight_launcher_result.get("error", "").is_empty() and option(state, 1, "black-knight-grenade-launcher", "on", squad, knights[1]).is_empty(), "An attached Command Squad does not raise the Black Knights' one-per-three Grenade Launcher cap")
	var black_knight_restore := option(state, 1, "black-knight-grenade-launcher", "off", squad, knights[0])
	check(PublicUnitCommand.submit(state, 1, black_knight_restore).get("error", "").is_empty(), "The attached Black Knight can restore its Plasma Talon")

	var ancient_dead := state.duplicate(true)
	ancient_dead.units[command_models[0]].wounds = 0
	check(not A.has(ancient_dead, squad, "ravenwing-astartes-banner") and C.Morale.objective_control(ancient_dead, knights[0]) == 2, "The banner bonus ends when the Ancient is destroyed")
	var champion_dead := state.duplicate(true)
	champion_dead.units[command_models[2]].wounds = 0
	check(C.UnitAbilities.advance_modifier(champion_dead, squad) == 0 and C.UnitAbilities.charge_modifier(champion_dead, squad) == 0, "Advance and Charge bonuses end when the Champion is destroyed")
	check(R.cost_of(champion_dead, 1, squad, R.HEROIC) == 1 and R.cost_of(champion_dead, 1, squad, R.FRAY) == 2, "The CP discount ends when the Champion is destroyed")
	var apothecary_dead := state.duplicate(true)
	apothecary_dead.units[command_models[1]].wounds = 0
	check(not A.has(apothecary_dead, squad, "narthecium"), "Narthecium becomes unavailable when the Apothecary is destroyed")

	state.phase = "command"
	state.active = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	state.units[knights[0]].wounds = 1
	dice_queue = [2]
	var heal_choice := option(state, 1, "narthecium", "", squad, command_models[1])
	var heal_result := PublicUnitCommand.submit(state, 1, heal_choice, Vector2.ZERO, Callable(self, "roll_die"))
	check(not heal_choice.is_empty() and heal_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == "healing", "The living Apothecary starts the shared D3+1 healing flow in Command")
	var confirm_choice := option(state, 1, "heal-confirm", "", squad)
	var confirm_result := PublicUnitCommand.submit(state, 1, confirm_choice)
	check(confirm_result.get("error", "").is_empty() and state.units[knights[0]].wounds == 3 and state.unit_abilities.last_healing.restored == 2, "Narthecium heals the attached Black Knight through the shared allocation path")
	check(option(state, 1, "narthecium", "", squad, command_models[1]).is_empty(), "Narthecium cannot be used twice in the same turn")

	if failures == 0: print("Ravenwing Command Squad checks: passed")
	else: print("Ravenwing Command Squad checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")

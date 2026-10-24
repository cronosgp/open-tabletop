extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func apply_choice(state: Dictionary, player: int, action: String, model: int, value: String) -> String:
	var option := find_choice(state, player, action, model, value)
	if option.is_empty(): return "Choice not offered: %s=%s" % [action, value]
	var result: Dictionary = PublicUnitCommand.submit(state, player, option, Vector2.ZERO, func() -> int: return 6)
	return str(result.get("error", ""))

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("lieutenant")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001346" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Lieutenant identity follows the local Wahapedia e11 export")
	check(profile.points_by_models == {1: 50} and profile.base_size_source_mm == 40, "Lieutenant cost and base match the source")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Lieutenant characteristics match the source")
	check(profile.keywords.has("ADEPTUS ASTARTES") and profile.keywords.has("TACTICUS") and profile.keywords.has("EXPLOSIVES"), "Lieutenant source keywords are present")
	check(Catalog.SPECS.get("lieutenant", {}).get("current_reference", false) and Roster.POINTS.get("lieutenant", {}).get("sizes", {}) == {1: 50}, "Lieutenant uses the current local price authority")
	var catalog_row := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:lieutenant", "edition": "11e", "faction": "Space Marines", "options": [{"models": 1, "cost": 50}]})
	check(catalog_row.get("id", "") == "40kdc:11e:adeptus-astartes:lieutenant" and catalog_row.get("options", []).size() == 1 and catalog_row.options[0].cost == 50, "Lieutenant enters the consolidated current construction catalog")
	var package_options: Array = profile.options.ranged_packages
	for package: String in package_options:
		for fists_choice: String in profile.options.fists_replacements:
			var weapons := Profiles.lieutenant_weapons(package, fists_choice, false)
			check(not weapons.is_empty(), "Source-listed Lieutenant package resolves: %s / %s" % [package, fists_choice])
			if package == "neo-volkite": check(not Profiles.lieutenant_weapons(package, fists_choice, true).is_empty(), "Neo-volkite Storm Shield combination resolves: " + fists_choice)
	check(Profiles.lieutenant_weapons("default", "ceramite-fists", true).is_empty(), "Storm Shield cannot be equipped outside the Neo-volkite package")
	var state: Dictionary = F.fresh()
	check(not state.has("error"), "Prepared Space Marines match initializes")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	state.awakened_dynasty.pending.clear()
	var model := find_model(state, 1, "lieutenant")
	var squad: int = state.units[model].squad if model >= 0 else -1
	check(model >= 0 and C.UnitAbilities.has(state, squad, "support") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "tactical-precision") and C.UnitAbilities.has(state, squad, "demi-company-commander"), "Lieutenant Support, Combat Doctrines and datasheet effects are registered")
	if model < 0:
		print("Lieutenant local checks: %d failures" % failures)
		quit(1)
		return
	check(apply_choice(state, 1, "lieutenant-ranged-loadout", model, "neo-volkite").is_empty(), "Neo-volkite package is selectable during army preparation")
	check(state.units[model].ranged_weapons.size() == 1 and state.units[model].ranged_weapons[0].id == "neo-volkite-pistol", "Neo-volkite package replaces the Bolt Pistol and Master-crafted Bolter")
	check(state.units[model].melee_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "master-crafted-power-weapon"), "Neo-volkite package adds the Master-crafted Power Weapon")
	check(apply_choice(state, 1, "lieutenant-storm-shield", model, "on").is_empty(), "Storm Shield is selectable with Neo-volkite")
	var defense := Groups.profile(state, model)
	check(defense.error.is_empty() and defense.invulnerable_target == 4 and C.UnitAbilities.has(state, squad, "storm-shield"), "Equipped Lieutenant alone gains the 4+ invulnerable save")
	check(apply_choice(state, 1, "lieutenant-melee-loadout", model, "power-fist").is_empty(), "Ceramite Fists replacement is selectable")
	check(state.units[model].melee_weapons.size() == 2 and state.units[model].melee_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "power-fist"), "Power Fist replacement is represented alongside the package weapon")
	check(apply_choice(state, 1, "lieutenant-ranged-loadout", model, "plasma-pistol").is_empty(), "Independent plasma pistol replacement is selectable")
	check(state.units[model].ranged_weapons.size() == 2 and state.units[model].ranged_weapons[0].id == "bolt-pistol" and state.units[model].ranged_weapons[1].id == "plasma-pistol", "Plasma pistol replaces the bolter while preserving the Bolt Pistol")
	check(not state.units[model].get("lieutenant_storm_shield", false) and Groups.profile(state, model).invulnerable_target == 0, "Leaving Neo-volkite automatically removes its conditional Storm Shield")
	var profiles := Profiles.lieutenant_weapons("heavy-pistol-plasma-pistol", "power-weapon", false)
	check(profiles.ranged[0].id == "heavy-bolt-pistol" and profiles.ranged[1].profiles.supercharge.keywords.hazardous, "Independent Heavy Bolt Pistol and Plasma Pistol options retain both plasma profiles")
	print("Lieutenant local checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const A = F.C.UnitAbilities
const U = F.C.UnitActions
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func model_for(state: Dictionary, identity: String, sergeant: bool = false, squad: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1 and A.identity(unit) == identity and unit.get("sergeant", false) == sergeant and (squad < 0 or unit.squad == squad): return model
	return -1

func option_for(options: Array, action: String, model: int, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and (value.is_empty() or option.value == value): return option
	return {}

func run() -> void:
	var profile := Profiles.profile("intercessor-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001157" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Intercessor profile cites the local Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {5: 85, 10: 170} and profile.get("models") == 5 and is_equal_approx(profile.get("base_radius_inches", 0.0), 16.0 / 25.4), "Intercessor sizes, prices and base match the local export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0} and "ADEPTUS ASTARTES" in profile.keywords and "BATTLELINE" in profile.keywords, "Intercessor characteristics and keywords match the local export")
	check(profile.ranged[0].profiles.focused_fire.strength == 6 and profile.ranged[0].profiles.focused_fire.damage == 2 and profile.ranged[0].profiles.saturation.strength == 5 and profile.ranged[0].profiles.saturation.attacks == 2, "Bolt Rifle modes match Wahapedia")
	check(profile.additional_weapon_profiles.ranged.size() == 3 and profile.additional_weapon_profiles.melee.size() == 4, "All source-listed optional weapon profiles are represented")
	check(Catalog.SPECS["intercessor-squad"].get("current_reference", false), "Intercessors are admitted into current construction")
	var choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:intercessor-squad", "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 5, "cost": 85}, {"models": 10, "cost": 170}], "Construction offers only locally sourced 5- and 10-model options")
	check(Roster.POINTS["intercessor-squad"].get("source", "") == "wahapedia-e11-2026-10-19" and Roster.POINTS["intercessor-squad"].sizes == {5: 85, 10: 170}, "Roster points resolve from the local Wahapedia profile")

	var state := F.fresh()
	check(not state.has("error"), "Current Intercessors materialize")
	if not state.has("error"):
		state.phase = "deployment"
		state.awakened_dynasty.pending = []
		var sergeant := model_for(state, "intercessor-squad", true)
		var trooper := model_for(state, "intercessor-squad", false)
		var squad := int(state.units[sergeant].squad) if sergeant >= 0 else -1
		check(sergeant >= 0 and trooper >= 0 and A.has(state, squad, "bolter-discipline") and A.has(state, squad, "tactical-mainstay"), "The admitted unit receives both datasheet abilities")
		if sergeant >= 0 and trooper >= 0:
			var setup := U.choices(state, 1)
			var rifle_option := option_for(setup, "intercessor-rifle", sergeant, "hand-flamer")
			var applied := U.apply(state, 1, rifle_option, Vector2.ZERO, func() -> int: return 1)
			check(not rifle_option.is_empty() and applied.get("error", "").is_empty() and state.units[sergeant].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "hand-flamer") and not state.units[sergeant].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "bolt-rifle"), "Sergeant may replace the Bolt Rifle with a Hand Flamer while retaining its Bolt Pistol")
			var melee_option := option_for(U.choices(state, 1), "intercessor-melee", sergeant, "thunder-hammer")
			applied = U.apply(state, 1, melee_option, Vector2.ZERO, func() -> int: return 1)
			check(not melee_option.is_empty() and applied.get("error", "").is_empty() and state.units[sergeant].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "thunder-hammer" and w.profiles.standard.keywords.get("devastating-wounds", false)), "Sergeant melee replacement carries the Thunder Hammer profile and Devastating Wounds")
			var grenade := option_for(U.choices(state, 1), "intercessor-grenade-launcher", trooper, "on")
			applied = U.apply(state, 1, grenade, Vector2.ZERO, func() -> int: return 1)
			check(not grenade.is_empty() and applied.get("error", "").is_empty() and state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "grenade-launcher"), "One model in a five-Intercessor unit may take the additional Grenade Launcher")
		check(option_for(U.choices(state, 1), "intercessor-grenade-launcher", sergeant, "on").is_empty(), "Sergeant is not an eligible model for the Intercessor Grenade Launcher option")

	var ten := F.selections()
	for entry: Dictionary in ten[1].entries:
		if entry.definition_id.ends_with(":intercessor-squad"): entry.models = 10
	var ten_state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true}, ten)
	if not ten_state.has("error"):
		ten_state.phase = "deployment"
		ten_state.awakened_dynasty.pending = []
		var eligible: Array[int] = []
		for model: int in ten_state.units:
			var unit: Dictionary = ten_state.units[model]
			if unit.owner != 1 or A.identity(unit) != "intercessor-squad" or unit.get("sergeant", false): continue
			if not option_for(U.choices(ten_state, 1), "intercessor-grenade-launcher", model, "on").is_empty(): eligible.append(model)
		check(eligible.size() == 9, "A 10-model squad exposes the first Grenade Launcher choice for its nine eligible Intercessor models")
		if eligible.size() >= 3:
			var first := option_for(U.choices(ten_state, 1), "intercessor-grenade-launcher", eligible[0], "on")
			var second := option_for(U.choices(ten_state, 1), "intercessor-grenade-launcher", eligible[1], "on")
			U.apply(ten_state, 1, first, Vector2.ZERO, func() -> int: return 1)
			U.apply(ten_state, 1, second, Vector2.ZERO, func() -> int: return 1)
			check(option_for(U.choices(ten_state, 1), "intercessor-grenade-launcher", eligible[2], "on").is_empty(), "Ten-model unit is capped at two Grenade Launchers")
	else:
		check(false, "Ten-model Intercessor squad materializes: " + str(ten_state.error))

	print("Current Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

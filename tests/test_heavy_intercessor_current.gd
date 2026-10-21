extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const A = F.C.UnitAbilities
const U = F.C.UnitActions
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func model_for(state: Dictionary, sergeant: bool = false) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1 and A.identity(unit) == "heavy-intercessor-squad" and unit.get("sergeant", false) == sergeant: return model
	return -1

func option_for(options: Array, model: int, value: String = "on") -> Dictionary:
	for option: Dictionary in options:
		if option.action == "heavy-intercessor-bolter" and option.model == model and option.value == value: return option
	return {}

func run() -> void:
	var profile := Profiles.profile("heavy-intercessor-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001177" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Heavy Intercessor profile cites the local Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {5: 115, 10: 230} and profile.get("models") == 5 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Heavy Intercessor sizes, prices and bases match the local export")
	check(profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0} and "ADEPTUS ASTARTES" in profile.keywords and "BATTLELINE" in profile.keywords, "Characteristics and keywords match the source export")
	check(profile.ranged[0].profiles.standard.keywords.get("heavy", false) and profile.ranged[0].profiles.standard.keywords.get("rapid-fire", 0) == 1 and profile.additional_weapon_profiles.ranged[0].id == "heavy-bolter" and profile.additional_weapon_profiles.ranged[0].profiles.standard.keywords.get("sustained-hits", 0) == 1 and profile.additional_weapon_profiles.ranged[0].profiles.standard.keywords.get("rapid-fire", 0) == 2, "Heavy Bolt Rifle and optional Heavy Bolter profiles preserve source traits")
	check(Catalog.SPECS["heavy-intercessor-squad"].get("current_reference", false), "Heavy Intercessors are admitted into local construction")
	var choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:heavy-intercessor-squad", "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 5, "cost": 115}, {"models": 10, "cost": 230}], "Construction exposes only the sourced squad sizes and points")
	check(Roster.POINTS["heavy-intercessor-squad"].get("source", "") == "wahapedia-e11-2026-10-19" and Roster.POINTS["heavy-intercessor-squad"].sizes == {5: 115, 10: 230}, "Roster validation prices use the local profile")

	var state := F.fresh()
	check(not state.has("error"), "Current Heavy Intercessors materialize")
	if not state.has("error"):
		state.phase = "deployment"
		state.awakened_dynasty.pending = []
		var sergeant := model_for(state, true)
		var trooper := model_for(state)
		var squad := int(state.units[sergeant].squad) if sergeant >= 0 else -1
		check(sergeant >= 0 and trooper >= 0 and A.has(state, squad, "unyielding-in-the-face-of-the-foe"), "The admitted unit materializes its datasheet ability")
		if sergeant >= 0 and trooper >= 0:
			var options := U.choices(state, 1)
			var heavy_bolter := option_for(options, trooper)
			var applied := U.apply(state, 1, heavy_bolter, Vector2.ZERO, func() -> int: return 1)
			check(not heavy_bolter.is_empty() and applied.get("error", "").is_empty() and state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "heavy-bolter" and w.profiles.standard.attacks == 3), "One non-Sergeant in a five-model unit can replace the Heavy Bolt Rifle with source Heavy Bolter")
			check(option_for(U.choices(state, 1), sergeant).is_empty(), "The Sergeant cannot take the Heavy Bolter option")
			var own_objective := {"kind": "marker", "position": state.units[trooper].position, "controller": 1, "secured": 0}
			state.mission.objectives = [own_objective]
			Objectives.resolve_control(state, Callable(F.C.Morale, "objective_control"))
			check(squad in Objectives.controlling_squads(state, state.mission.objectives[0], Callable(F.C.Morale, "objective_control")) and A.save_bonus(state, squad, Callable(F.C.Morale, "objective_control")) == 1, "Unyielding grants +1 to saves while this squad controls its objective")
			state.mission.objectives = [{"kind": "marker", "position": Vector2(100, 100), "controller": 1, "secured": 0}]
			check(A.save_bonus(state, squad, Callable(F.C.Morale, "objective_control")) == 0, "An objective controlled elsewhere does not grant the save bonus")

	var ten := F.selections()
	for entry: Dictionary in ten[1].entries:
		if entry.definition_id.ends_with(":heavy-intercessor-squad"): entry.models = 10
	var ten_state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true}, ten)
	if not ten_state.has("error"):
		ten_state.phase = "deployment"
		ten_state.awakened_dynasty.pending = []
		var eligible: Array[int] = []
		for model: int in ten_state.units:
			var unit: Dictionary = ten_state.units[model]
			if unit.owner != 1 or A.identity(unit) != "heavy-intercessor-squad" or unit.get("sergeant", false): continue
			if not option_for(U.choices(ten_state, 1), model).is_empty(): eligible.append(model)
		check(eligible.size() == 9, "A ten-model unit exposes choices for all nine eligible models")
		if eligible.size() >= 3:
			U.apply(ten_state, 1, option_for(U.choices(ten_state, 1), eligible[0]), Vector2.ZERO, func() -> int: return 1)
			U.apply(ten_state, 1, option_for(U.choices(ten_state, 1), eligible[1]), Vector2.ZERO, func() -> int: return 1)
			check(option_for(U.choices(ten_state, 1), eligible[2]).is_empty(), "Ten-model unit is capped at two Heavy Bolters")
	else:
		check(false, "Ten-model Heavy Intercessor squad materializes: " + str(ten_state.error))

	print("Current Heavy Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const ListRoster = preload("res://scripts/army_roster.gd")
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
		if unit.owner == 1 and A.identity(unit) == "terminator-squad" and unit.get("sergeant", false) == sergeant: return model
	return -1

func option_for(options: Array, action: String, model: int, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and (value.is_empty() or option.value == value): return option
	return {}

func run() -> void:
	var profile := Profiles.profile("terminator-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001183" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Terminator Squad profile cites the local Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {5: 190, 10: 380} and profile.get("third_plus_points_by_models", {}) == {5: 230, 10: 420} and profile.get("wargear_costs", {}).get("cyclone-missile-launcher") == 10 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Terminator compositions, copy tiers, Cyclone cost and 40 mm bases match the source export")
	check(profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and "TERMINATOR" in profile.keywords, "Terminator characteristics and shared datasheet keywords match the export")
	check(profile.additional_weapon_profiles.ranged.size() == 3 and profile.additional_weapon_profiles.melee.size() == 2 and profile.additional_weapon_profiles.melee[0].profiles.size() == 2, "All optional Terminator weapons and both exported Chainfist profiles are recorded")
	check(Catalog.SPECS["terminator-squad"].get("current_reference", false), "Terminator Squad is admitted as a current local profile")
	var choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:terminator-squad", "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 5, "cost": 190, "third_plus_cost": 230}, {"models": 10, "cost": 380, "third_plus_cost": 420}], "Catalog exposes the sourced first-two and third-plus copy prices for supported compositions")
	check(Roster.POINTS["terminator-squad"].sizes == {5: 190, 10: 380} and Roster.POINTS["terminator-squad"].third_plus_sizes == {5: 230, 10: 420} and Roster.POINTS["terminator-squad"].wargear_costs == {"cyclone-missile-launcher": 10}, "Roster price authority uses local copy tiers and optional Cyclone cost")
	var three_report := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:terminator-squad", "models": 5, "copies": 3}]})
	check(three_report.get("error", "").is_empty() and three_report.get("total", -1) == 610, "Local construction charges the first two 5-model squads at 190 and each later squad at 230")
	var priced_list := ListRoster.new_list("11e", "Space Marines", "custom", 1000)
	priced_list.entries.append({"unit_id": "40kdc:11e:adeptus-astartes:terminator-squad", "name": "Terminator Squad", "edition": "11e", "faction": "Space Marines", "role": "Other units", "models": 5, "cost": 190, "third_plus_cost": 230, "copies": 3, "source_digest": Profiles.digest()})
	check(ListRoster.summary(priced_list).points == 610 and ListRoster.entry_cost(priced_list.entries, 0) == 610, "Saved army summaries apply the third-plus tier to grouped copies")
	priced_list.entries[0].copies = 2
	var third_copy: Dictionary = priced_list.entries[0].duplicate(true)
	third_copy.copies = 1
	priced_list.entries.append(third_copy)
	check(ListRoster.summary(priced_list).points == 610 and ListRoster.entry_cost(priced_list.entries, 1) == 230, "Tiered prices remain correct when copies are split across roster rows")

	var state := F.fresh()
	check(not state.has("error"), "Current Terminators materialize")
	if not state.has("error"):
		state.phase = "deployment"
		state.awakened_dynasty.pending = []
		var sergeant := model_for(state, true)
		var trooper := model_for(state)
		var squad := int(state.units[sergeant].squad) if sergeant >= 0 else -1
		check(sergeant >= 0 and trooper >= 0 and A.has(state, squad, "fury-of-the-first") and A.has(state, squad, "teleport-homer") and A.has(state, squad, "deep-strike"), "Current Terminator rules remain assigned on the admitted sheet")
		if sergeant >= 0 and trooper >= 0:
			var options := U.choices(state, 1)
			var sgt_power := option_for(options, "terminator-melee", sergeant, "power-weapon")
			var applied := U.apply(state, 1, sgt_power, Vector2.ZERO, func() -> int: return 1)
			check(not sgt_power.is_empty() and applied.get("error", "").is_empty() and state.units[sergeant].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "power-weapon"), "Terminator Sergeant can replace its Power Fist with a Power Weapon")
			var chainfist := option_for(U.choices(state, 1), "terminator-melee", trooper, "chainfist")
			applied = U.apply(state, 1, chainfist, Vector2.ZERO, func() -> int: return 1)
			check(not chainfist.is_empty() and applied.get("error", "").is_empty() and state.units[trooper].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "chainfist" and w.profiles.hunter.attacks == 3), "A Terminator may replace its Power Fist with a Chainfist carrying both source profiles")
			var second_trooper := -1
			for candidate: int in state.units:
				if candidate != trooper and state.units[candidate].owner == 1 and A.identity(state.units[candidate]) == "terminator-squad" and not state.units[candidate].get("sergeant", false):
					second_trooper = candidate
					break
			var second_chainfist := option_for(U.choices(state, 1), "terminator-melee", second_trooper, "chainfist")
			applied = U.apply(state, 1, second_chainfist, Vector2.ZERO, func() -> int: return 1)
			check(second_trooper >= 0 and not second_chainfist.is_empty() and applied.get("error", "").is_empty() and state.units[second_trooper].melee_weapons.any(func(w: Dictionary) -> bool: return w.id == "chainfist"), "Any number of regular Terminators may replace their Power Fists with Chainfists")
			check(option_for(U.choices(state, 1), "terminator-melee", sergeant, "power-fist").is_empty() == false, "Sergeant can restore its default Power Fist")
			var special := option_for(U.choices(state, 1), "terminator-special-weapon", trooper, "assault-cannon")
			applied = U.apply(state, 1, special, Vector2.ZERO, func() -> int: return 1)
			check(not special.is_empty() and applied.get("error", "").is_empty() and state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "assault-cannon") and not state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter"), "One model per five may replace its Storm Bolter with an Assault Cannon")
			check(option_for(U.choices(state, 1), "terminator-special-weapon", sergeant, "assault-cannon").is_empty(), "Terminator Sergeant is not eligible for the regular Terminator special-gun option")
			var restore := option_for(U.choices(state, 1), "terminator-special-weapon", trooper, "none")
			U.apply(state, 1, restore, Vector2.ZERO, func() -> int: return 1)
			var base_cost := int(state.squads[squad].training_cost)
			var cyclone := option_for(U.choices(state, 1), "terminator-special-weapon", trooper, "cyclone-missile-launcher")
			applied = U.apply(state, 1, cyclone, Vector2.ZERO, func() -> int: return 1)
			check(not cyclone.is_empty() and applied.get("error", "").is_empty() and int(state.squads[squad].training_cost) == base_cost + 10 and state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "storm-bolter") and state.units[trooper].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "cyclone-missile-launcher" and w.profiles.frag.attacks == 8 and w.profiles.krak.damage == "D3+3"), "Cyclone adds both profiles, retains its Storm Bolter and adds the source 10 points")

	var ten := F.selections()
	for entry: Dictionary in ten[1].entries:
		if entry.definition_id.ends_with(":terminator-squad"): entry.models = 10
	var ten_state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true}, ten)
	if not ten_state.has("error"):
		ten_state.phase = "deployment"
		ten_state.awakened_dynasty.pending = []
		var eligible: Array[int] = []
		for model: int in ten_state.units:
			var unit: Dictionary = ten_state.units[model]
			if unit.owner != 1 or A.identity(unit) != "terminator-squad" or unit.get("sergeant", false): continue
			if not option_for(U.choices(ten_state, 1), "terminator-special-weapon", model, "assault-cannon").is_empty(): eligible.append(model)
		check(eligible.size() == 9, "A ten-model unit exposes special-weapon choices for all nine regular Terminators")
		if eligible.size() >= 3:
			U.apply(ten_state, 1, option_for(U.choices(ten_state, 1), "terminator-special-weapon", eligible[0], "assault-cannon"), Vector2.ZERO, func() -> int: return 1)
		U.apply(ten_state, 1, option_for(U.choices(ten_state, 1), "terminator-special-weapon", eligible[1], "heavy-flamer"), Vector2.ZERO, func() -> int: return 1)
		check(option_for(U.choices(ten_state, 1), "terminator-special-weapon", eligible[2], "assault-cannon").is_empty(), "Ten-model unit is capped at two special guns")
	else:
		check(false, "Ten-model Terminator Squad materializes: " + str(ten_state.error))

	print("Current Terminator Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

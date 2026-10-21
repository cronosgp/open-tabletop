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

func option_for(options: Array, action: String, model: int, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and (value.is_empty() or option.value == value): return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("outrider-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002712" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Outrider Squad cites the pinned local Wahapedia e11 extraction")
	check(profile.get("points_by_models", {}) == {3: 80, 6: 160} and profile.get("third_plus_points_by_models", {}) == {3: 80, 6: 160} and profile.get("base_size_source_mm", []) == [90, 52] and profile.get("base_geometry") == "oval", "Source compositions, copy tiers and 90 x 52 mm oval bases are recorded")
	check(profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0} and profile.keywords.has("RAVENWING") and profile.keywords.has("MOUNTED"), "Shared characteristics and local datasheet keywords match source rows")
	check(profile.ranged[0].id == "heavy-bolt-pistol" and profile.ranged[1].id == "twin-bolt-rifle" and profile.additional_weapon_profiles.ranged[0].profiles.supercharge.keywords.hazardous and profile.additional_weapon_profiles.melee[1].id == "thunder-hammer", "Default and replacement weapon profiles are present with source traits")
	check(Catalog.SPECS.has("outrider-squad") and Roster.POINTS["outrider-squad"].sizes == {3: 80, 6: 160} and Roster.POINTS["outrider-squad"].third_plus_sizes == {3: 80, 6: 160}, "The local construction catalog uses the source composition and prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 240, "Three copies use the verified 80-point third-plus price")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Outrider Squad passes local roster admission and materializes")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var squad := -1
	var models: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1 and A.identity(unit) == "outrider-squad":
			squad = int(unit.squad)
			models.append(model)
	models.sort()
	check(models.size() == 3 and state.squads[squad].training_cost == 80 and A.has(state, squad, "full-throttle-assault"), "Three models, source cost and Full-throttle Assault materialize")
	var sergeant := models[0]
	var trooper := models[1]
	state.phase = "deployment"
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.unit_abilities.setup_players = []
	state.unit_abilities.phase_key = U.key(state)
	check(state.units[sergeant].get("sergeant", false) and not state.units[trooper].get("sergeant", false), "Only the first model receives the Sergeant role")
	check(state.units[trooper].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) == ["heavy-bolt-pistol", "twin-bolt-rifle"] and state.units[trooper].melee_weapons[0].id == "chainsword", "Default Outrider loadout is materialized per model")
	var choices := U.choices(state, 1)
	var plasma := option_for(choices, "outrider-plasma-pistol", trooper, "on")
	var applied := U.apply(state, 1, plasma, Vector2.ZERO, func() -> int: return 1) if not plasma.is_empty() else {"error": "choice not offered"}
	check(not plasma.is_empty() and applied.get("error", "").is_empty() and state.units[trooper].ranged_weapons[0].id == "plasma-pistol", "Any Outrider model may replace its Heavy Bolt Pistol with a Plasma Pistol")
	choices = U.choices(state, 1)
	var second_plasma := option_for(choices, "outrider-plasma-pistol", sergeant, "on")
	check(second_plasma.is_empty(), "A three-model unit permits only one Plasma Pistol")
	var hammer := option_for(choices, "outrider-melee", sergeant, "thunder-hammer")
	applied = U.apply(state, 1, hammer, Vector2.ZERO, func() -> int: return 1) if not hammer.is_empty() else {"error": "choice not offered"}
	check(not hammer.is_empty() and applied.get("error", "").is_empty() and state.units[sergeant].melee_weapons[0].id == "thunder-hammer", "The Sergeant may replace its Chainsword with a Thunder Hammer")
	var hammer_profile: Dictionary = state.units[sergeant].melee_weapons[0].profiles.standard
	var target_squad := -1
	for model: int in state.units:
		if state.units[model].owner == 2:
			target_squad = int(state.units[model].squad)
			break
	state.squads[squad].charged = false
	var inactive := A.weapon(state, sergeant, -1, hammer_profile, true)
	check(inactive.damage == 3 and inactive.keywords.get("sustained-hits", 0) == 0 and A.hit_bonus(state, squad, target_squad, true, sergeant, hammer_profile) == 0, "Full-throttle Assault is inactive when the unit did not Charge this turn")
	state.squads[squad].charged = true
	var active_hammer := A.weapon(state, sergeant, -1, hammer_profile, true)
	check(active_hammer.damage == 3 and active_hammer.keywords.get("sustained-hits", 0) == 1 and A.hit_bonus(state, squad, target_squad, true, sergeant, hammer_profile) == 1, "A charging Thunder Hammer gains +1 to hit and Sustained Hits 1 without a Damage bonus")
	var chainsword_profile: Dictionary = {"name": "Chainsword", "damage": 1, "keywords": {}}
	var active_chain := A.weapon(state, trooper, -1, chainsword_profile, true)
	check(active_chain.damage == 2 and active_chain.keywords.get("sustained-hits", 0) == 1 and A.hit_bonus(state, squad, target_squad, true, trooper, chainsword_profile) == 0, "Other melee weapons gain +1 Damage and Sustained Hits 1 after a Charge")
	check(not A.weapon(state, trooper, -1, state.units[trooper].ranged_weapons[1].profiles.standard, false).keywords.get("sustained-hits", false), "Full-throttle Assault does not modify ranged weapons")

	var six_lists := F.selections()
	six_lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 6, "copies": 1})
	var six_state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, six_lists)
	if six_state.has("error"):
		check(false, "Six-model Outrider Squad materializes: " + str(six_state.error))
	else:
		var six_models: Array[int] = []
		for model: int in six_state.units:
			if six_state.units[model].owner == 1 and A.identity(six_state.units[model]) == "outrider-squad": six_models.append(model)
		six_models.sort()
		var six_squad: int = six_state.units[six_models[0]].squad if not six_models.is_empty() else -1
		six_state.phase = "deployment"
		six_state.awakened_dynasty.pending = []
		six_state.unit_abilities.setup_players = []
		var six_choices := U.choices(six_state, 1)
		var available_plasmas := six_choices.filter(func(option: Dictionary) -> bool: return option.action == "outrider-plasma-pistol" and option.value == "on")
		check(six_models.size() == 6 and six_state.squads[six_squad].training_cost == 160 and available_plasmas.size() == 6, "Six models cost 160 points and any two models may start as Plasma Pistol candidates")
		if six_models.size() == 6:
			for index in [1, 2]:
				var selected := option_for(U.choices(six_state, 1), "outrider-plasma-pistol", six_models[index], "on")
				U.apply(six_state, 1, selected, Vector2.ZERO, func() -> int: return 1)
			var third_choice := option_for(U.choices(six_state, 1), "outrider-plasma-pistol", six_models[3], "on")
			var restore := option_for(U.choices(six_state, 1), "outrider-plasma-pistol", six_models[1], "off")
			var restore_result := U.apply(six_state, 1, restore, Vector2.ZERO, func() -> int: return 1) if not restore.is_empty() else {"error": "restore choice not offered"}
			var freed_slot := option_for(U.choices(six_state, 1), "outrider-plasma-pistol", six_models[3], "on")
			check(third_choice.is_empty() and not restore.is_empty() and restore_result.get("error", "").is_empty() and not freed_slot.is_empty(), "Six-model unit caps at two Plasma Pistols and changing equipment frees a legal slot")
			check(option_for(U.choices(six_state, 1), "outrider-melee", six_models[1]).is_empty(), "A regular Outrider cannot take the Sergeant melee replacements")
	print("Current Outrider Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

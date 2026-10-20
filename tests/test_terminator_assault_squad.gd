extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const A = F.C.UnitAbilities
const U = F.C.UnitActions
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("terminator-assault-squad")
	check(profile.source_datasheet_id == "000000118" and profile.source_book_id == "000000139" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Assault Terminators cite the pinned local Wahapedia datasheet export")
	check(profile.points_by_models == {5: 170, 10: 340} and profile.third_plus_points_by_models == {5: 210, 10: 380} and profile.wargear_costs == {"storm-shield": 5}, "Unit compositions, copy tiers and per-model Storm Shield cost match the extracted source")
	check(profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "Datasheet characteristics and 40 mm base match the source")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard.name == "Twin Lightning Claws" and profile.additional_weapon_profiles.melee[0].profiles.standard.name == "Thunder Hammer", "Default claws and optional Storm Shield hammer profile are recorded")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:terminator-assault-squad", "edition": "11e", "faction": "Space Marines"})
	check(Catalog.SPECS.has("terminator-assault-squad") and catalog_choice.get("options", []) == [{"models": 5, "cost": 170, "third_plus_cost": 210}, {"models": 10, "cost": 340, "third_plus_cost": 380}], "The local construction catalog exposes both sourced compositions and copy tiers")
	var selections := F.selections()
	var entries: Array = []
	for row: Dictionary in selections[1].entries:
		if not str(row.definition_id).ends_with(":terminator-squad"): entries.append(row)
	entries.append({"definition_id": "40kdc:11e:adeptus-astartes:terminator-assault-squad", "models": 5, "copies": 1})
	selections[1].entries = entries
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Assault Terminators materialize from the local profile")
	if not state.has("error"):
		state.phase = "deployment"
		state.awakened_dynasty.pending = []
		var squad := -1
		var model := -1
		for id: int in state.units:
			if state.units[id].owner == 1 and A.identity(state.units[id]) == "terminator-assault-squad": squad = state.units[id].squad; model = id; break
		check(squad > 0 and A.has(state, squad, "deep-strike") and A.has(state, squad, "teleport-homer") and A.has(state, squad, "terminatus-assault"), "The sheet receives its source abilities")
		if model > 0:
			check(state.units[model].wounds == 3 and state.units[model].melee_weapons[0].profiles.standard.name == "Twin Lightning Claws", "Default model has three wounds and Lightning Claws")
			state.phase = "start_turn"
			check(U.battle_actor(state) == 1, "The Assault Squad may declare its Teleport Homer at battle start")
			state.phase = "deployment"
			var shield_choice: Dictionary
			for option: Dictionary in U.choices(state, 1):
				if option.action == "terminator-assault-loadout" and option.model == model: shield_choice = option; break
			var result := U.apply(state, 1, shield_choice, Vector2.ZERO, func() -> int: return 1)
			check(result.get("error", "").is_empty() and state.units[model].wounds == 4 and state.units[model].max_wounds == 4 and state.units[model].melee_weapons[0].profiles.standard.name == "Thunder Hammer", "Storm Shield adds one wound and replaces claws with the hammer")
			check(state.squads[squad].training_cost == 175, "The equipped model adds five points to the unit")
			state.squads[squad].charged = true
			var enemy_squad := -1
			for enemy: int in state.units:
				if state.units[enemy].owner == 2: enemy_squad = state.units[enemy].squad; break
			var claws: Dictionary = Profiles.profile("terminator-assault-squad").melee[0].profiles.standard
			var hammer: Dictionary = Profiles.profile("terminator-assault-squad").additional_weapon_profiles.melee[0].profiles.standard
			check(A.weapon(state, model, enemy_squad, claws, true).keywords.get("sustained-hits", 0) == 1 and A.weapon(state, model, enemy_squad, hammer, true).keywords.get("sustained-hits", 0) == 0, "After a charge, claws gain Sustained Hits against non-Monster/Vehicle targets")
			for enemy: int in state.units:
				if state.units[enemy].owner == 2: state.units[enemy].keywords = ["VEHICLE"]
			check(A.weapon(state, model, enemy_squad, hammer, true).keywords.get("sustained-hits", 0) == 1 and A.weapon(state, model, enemy_squad, claws, true).keywords.get("sustained-hits", 0) == 0, "Against a Vehicle, the Hammer receives the charge bonus instead")
	print("Terminator Assault Squad local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

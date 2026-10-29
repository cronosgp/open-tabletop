extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "wulfen"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry(5), entry(10), entry(5)] if owner == 1 else [entry(5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}
	}, selections())

func models_for(state: Dictionary, owner: int, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == UNIT: result.append(model)
	result.sort()
	return result

func squads_for(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == UNIT:
				result.append(squad)
				break
	result.sort()
	return result

func find_choice(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "wulfen-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_choice(state, player, model, squad, value))

func roll_three() -> int:
	return 3

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000000311" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "f3dedbf36bf9fa30d6db0b22f1a6cc4f95f2dceef136def80846496eaf2fe9d3", "The profile records the exact Space Wolves sheet and verified local slice")
	check(profile.points_by_models == {5: 90, 10: 180} and profile.third_plus_points_by_models == {5: 105, 10: 195}, "Both unit sizes and third-plus copy costs match the local export")
	check(profile.stats.movement_inches == 9 and profile.stats.toughness == 6 and profile.stats.save_target == 4 and profile.stats.wounds == 2 and profile.stats.leadership_target == 7 and profile.stats.objective_control == 0 and profile.base_size_source_mm == 40, "All fixed model characteristics and the 40 mm base are represented")
	var default_weapons := Profiles.wulfen_weapons()
	var launcher_weapons := Profiles.wulfen_weapons("stormfrag-auto-launcher")
	check(default_weapons.ranged.is_empty() and default_weapons.melee.size() == 1 and default_weapons.melee[0].id == "wulfen-weapons" and int(default_weapons.melee[0].profiles.standard.keywords.get("sustained-hits", 0)) == 1, "The default Death Totem and Wulfen Weapons loadout has no ranged weapon and retains Sustained Hits 1")
	check(launcher_weapons.ranged.size() == 1 and launcher_weapons.ranged[0].id == "stormfrag-auto-launcher" and launcher_weapons.ranged[0].profiles.standard.range_inches == 12.0 and launcher_weapons.ranged[0].profiles.standard.keywords.get("assault", false) and launcher_weapons.ranged[0].profiles.standard.keywords.get("blast", 0) == 1 and Profiles.wulfen_weapons("unknown").is_empty(), "The source-listed Stormfrag Auto-launcher and unsupported-loadout rejection are explicit")
	check(["combat-doctrines", "savage-frenzy", "death-totem", "curse-of-the-wulfen", "bestial-forms"].all(func(rule: String) -> bool: return rule in C.UnitAbilities.RULES.get(UNIT, [])), "Combat Doctrines and all three Wulfen abilities plus Bestial Forms are registered")
	check(Catalog.Current.profile(UNIT).source_datasheet_id == "000000311", "The consolidated current catalog resolves the Wulfen source identity")

	var state := fresh()
	if state.has("error"):
		check(false, "A Space Wolves current-catalog Wulfen training match builds: " + str(state.error))
		quit(1)
		return
	var owner_squads := squads_for(state, 1)
	var enemy_squads := squads_for(state, 2)
	check(owner_squads.size() == 3 and enemy_squads.size() == 1, "Three source-priced Wulfen units and an opposing unit enter the current catalog")
	if owner_squads.size() < 3 or enemy_squads.is_empty():
		quit(1)
		return
	var squad := owner_squads[0]
	var enemy_squad := enemy_squads[0]
	var size_counts := {5: 0, 10: 0}
	for item: int in owner_squads:
		size_counts[int(state.squads[item].starting_strength)] += 1
		check(int(state.squads[item].get("training_cost", -1)) == int(profile.points_by_models[int(state.squads[item].starting_strength)]), "Training materializes a listed formation at its first-two price")
	check(size_counts == {5: 2, 10: 1} and profile.third_plus_points_by_models == {5: 105, 10: 195}, "The roster includes both model sizes and retains third-plus copy prices")
	var models := models_for(state, 1, squad)
	var enemy_models := models_for(state, 2, enemy_squad)
	check(models.size() == 5 and enemy_models.size() == 5 and models.all(func(model: int) -> bool: return state.units[model].ranged_weapons.is_empty() and state.units[model].melee_weapons[0].id == "wulfen-weapons" and bool(state.units[model].get("wulfen_death_totem", false))), "Each model receives its default Death Totem and Wulfen Weapons loadout")
	check(C.UnitAbilities.wulfen_death_totem_active(state, squad) and Transport.capacity_cost(state, squad, {}) == 10, "The retained Death Totem and two-slot Bestial Forms capacity are active")

	var launcher_choice := find_choice(state, 1, models[0], squad, "stormfrag-auto-launcher")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner := PublicUnitCommand.submit(state, 2, launcher_choice)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot change a Wulfen loadout")
	var equipped := choose(state, 1, models[0], squad, "stormfrag-auto-launcher")
	check(str(equipped.get("error", "")).is_empty() and state.units[models[0]].ranged_weapons[0].id == "stormfrag-auto-launcher" and not bool(state.units[models[0]].get("wulfen_death_totem", true)) and C.UnitAbilities.wulfen_death_totem_active(state, squad), "The public preparation choice replaces only this model's Death Totem and installs its launcher")
	for model: int in models.slice(1):
		var change := choose(state, 1, model, squad, "stormfrag-auto-launcher")
		check(str(change.get("error", "")).is_empty(), "Any Wulfen model can independently take the free Stormfrag Auto-launcher")
	check(not C.UnitAbilities.wulfen_death_totem_active(state, squad) and C.UnitAbilities.sources(state, squad, "death-totem").is_empty(), "Replacing every Death Totem removes its melee re-roll ability and equipment source")
	var restored := choose(state, 1, models[0], squad, "death-totem")
	check(str(restored.get("error", "")).is_empty() and state.units[models[0]].ranged_weapons.is_empty() and C.UnitAbilities.wulfen_death_totem_active(state, squad) and C.UnitAbilities.sources(state, squad, "death-totem") == [models[0]], "The Death Totem can be restored and its bearer reactivates the melee ability")

	var totem_state: Dictionary = state.duplicate(true)
	totem_state.phase = "fight"
	totem_state.active = 1
	totem_state.unit_abilities.setup_players = []
	totem_state.units[models[0]].position = Vector2.ZERO
	totem_state.units[enemy_models[0]].position = Vector2(1.0, 0.0)
	var melee_plan := C.AttackPlan.prepare(totem_state, squad, true, [{"model": models[0], "target": enemy_squad, "amount": 3, "weapon": "wulfen-weapons", "profile": "standard"}], true)
	check(str(melee_plan.get("error", "")).is_empty() and melee_plan.batches.size() == 1 and melee_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Death Totem Hit re-rolls enter the real melee AttackPlan")
	var launcher_restore := choose(state, 1, models[0], squad, "stormfrag-auto-launcher")
	var no_totem_state: Dictionary = state.duplicate(true)
	no_totem_state.phase = "fight"
	no_totem_state.active = 1
	no_totem_state.unit_abilities.setup_players = []
	no_totem_state.units[models[0]].position = Vector2.ZERO
	no_totem_state.units[enemy_models[0]].position = Vector2(1.0, 0.0)
	var no_totem_plan := C.AttackPlan.prepare(no_totem_state, squad, true, [{"model": models[0], "target": enemy_squad, "amount": 3, "weapon": "wulfen-weapons", "profile": "standard"}], true)
	check(str(launcher_restore.get("error", "")).is_empty() and str(no_totem_plan.get("error", "")).is_empty() and no_totem_plan.batches[0].context.get("hit_reroll", "none") == "none", "The unit loses Death Totem rerolls after its last Totem is replaced")

	var test_model := models[0]
	var character_model := models[1]
	for model: int in models: state.units[model].position = Vector2.ZERO
	state.units[character_model].position = Vector2(6.5, 0.0)
	state.units[character_model].keywords = ["ADEPTUS ASTARTES", "SPACE WOLVES", "CHARACTER", "IMPERIUM"]
	check(Morale.objective_control(state, test_model) == 1, "Curse of the Wulfen gives the whole unit +1 OC within six inches of a non-Wulfen Space Wolves Character")
	state.units[character_model].position = Vector2(10.0, 0.0)
	state.units[character_model].keywords = ["WOLF PRIEST"]
	check(Morale.objective_control(state, test_model) == 1, "The alternate twelve-inch Wolf Priest condition grants +1 OC")
	state.squads[squad].battle_shocked = true
	check(Morale.objective_control(state, test_model) == 0, "A Battle-shocked Wulfen unit receives no Curse of the Wulfen OC")
	state.squads[squad].battle_shocked = false
	state.units[character_model].keywords = ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WULFEN"]

	for model: int in models: state.units[model].position = Vector2.ZERO
	for index in range(enemy_models.size()): state.units[enemy_models[index]].position = Vector2(-10.0, 0.0) if index > 0 else Vector2(1.0, 0.0)
	state.phase = "movement"
	state.active = 2
	var forced_error := C.movement_choice_error(state, 2, enemy_models[0], "ordered_retreat", int(state.revision))
	check(forced_error.contains("Savage Frenzy") and C.UnitAbilities.savage_frenzy_forces_desperate_escape(state, enemy_squad), "An engaged non-MONSTER/VEHICLE enemy cannot choose Ordered Retreat near Wulfen")
	state.squads[enemy_squad].battle_shocked = true
	check(C.UnitAbilities.forced_escape_hazard_modifiers(state, enemy_squad, enemy_models.size()) == [-1, -1, -1, -1, -1], "Battle-shocked forced Desperate Escape modifies every model's Hazard roll")
	var escape_state: Dictionary = state.duplicate(true)
	var escape_error := C.begin_movement(escape_state, 2, enemy_models[0], "desperate_escape", int(escape_state.revision), Callable(self, "roll_three"))
	check(escape_error.is_empty() and escape_state.pending_move.get("hazard_modifiers", []) == [-1, -1, -1, -1, -1] and int(escape_state.pending_move.get("hazard_remaining", 0)) == 5, "The shared Fall Back resolver applies and retains Wulfen's Hazard modifier")
	for model: int in enemy_models: state.units[model].keywords.append("VEHICLE")
	check(not C.UnitAbilities.savage_frenzy_forces_desperate_escape(state, enemy_squad), "Savage Frenzy exempts units with MONSTER or VEHICLE")

	if failures == 0:
		print("Wulfen checks passed")
		quit(0)
	else:
		print("Wulfen checks: %d failures" % failures)
		quit(1)

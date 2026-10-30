extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Defenders = preload("res://scripts/edition_11/defender_groups.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "thunderwolf-cavalry"

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
		result[owner].entries = [entry(3), entry(6), entry(3)] if owner == 1 else [entry(3)]
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
		if C.living(state, squad).any(func(model: int) -> bool: return C.UnitAbilities.identity(state.units[model]) == UNIT): result.append(squad)
	result.sort()
	return result

func find_choice(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "thunderwolf-cavalry-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_choice(state, player, model, squad, value))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000000322" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "238c7c2f9d776cab7fc5ebe7103157781cb2d72397fce3872a923c4f37f627ff", "The profile records the exact Space Wolves datasheet and verified local slice")
	check(profile.points_by_models == {3: 115, 6: 230} and profile.third_plus_points_by_models == {3: 145, 6: 260} and profile.wargear_costs == {"storm-shield": 5}, "Copy tiers and optional Storm Shield points match the local export")
	check(profile.stats.movement_inches == 12 and profile.stats.toughness == 6 and profile.stats.wounds == 4 and profile.stats.objective_control == 2 and profile.base_size_source_mm == 60, "The source characteristics and 60 mm base are represented")
	var default_weapons := Profiles.thunderwolf_cavalry_weapons()
	var plasma_weapons := Profiles.thunderwolf_cavalry_weapons("plasma-pistol")
	var shield_weapons := Profiles.thunderwolf_cavalry_weapons("boltgun-storm-shield")
	check(default_weapons.ranged[0].id == "bolt-pistol" and default_weapons.melee.size() == 2 and default_weapons.melee[0].profiles.standard.keywords.get("extra-attacks", false), "Default Bolt Pistol, Wolf Guard Weapon and Extra Attacks Teeth and Claws are built from the source profile")
	check(plasma_weapons.ranged[0].id == "plasma-pistol" and plasma_weapons.ranged[0].profiles.has("standard") and plasma_weapons.ranged[0].profiles.has("supercharge"), "The Plasma Pistol exposes its standard and hazardous supercharge profiles")
	check(shield_weapons.ranged[0].id == "boltgun" and Profiles.thunderwolf_cavalry_weapons("unknown").is_empty(), "The Boltgun replacement and unsupported-loadout rejection are explicit")
	check("combat-doctrines" in C.UnitAbilities.RULES.get(UNIT, []) and "thunderous-charge" in C.UnitAbilities.RULES[UNIT] and "storm-shield" in C.UnitAbilities.RULES[UNIT], "Combat Doctrines, Thunderous Charge and the source-listed Storm Shield are registered for this profile")
	check(Catalog.Current.profile(UNIT).source_datasheet_id == "000000322", "The admitted current catalog resolves the Thunderwolf datasheet identity")

	var state := fresh()
	var squads := squads_for(state, 1)
	check(squads.size() == 3, "The current-reference roster materializes three independently priced units")
	if squads.size() < 3:
		quit(1)
		return
	var three := squads_for(state, 1).filter(func(squad: int) -> bool: return int(state.squads[squad].starting_strength) == 3)
	var six := squads_for(state, 1).filter(func(squad: int) -> bool: return int(state.squads[squad].starting_strength) == 6)
	var price_summary: Array[String] = []
	for squad: int in squads: price_summary.append("%d:%d" % [int(state.squads[squad].starting_strength), int(state.squads[squad].get("training_cost", -1))])
	check(three.size() == 2 and six.size() == 1 and int(state.squads[three[0]].training_cost) == 115 and int(state.squads[six[0]].training_cost) == 230 and int(state.squads[three[1]].training_cost) == 115, "Three- and six-model formations materialize at their first-two training prices (" + str(price_summary) + "); third-plus prices remain in the source profile")
	var models := models_for(state, 1, three[0])
	var six_models := models_for(state, 1, six[0])
	var loadout_choices := C.UnitActions.thunderwolf_cavalry_loadout_choices(state, 1)
	var pack_leader_count := 0
	for model: int in models:
		if bool(state.units[model].get("sergeant", false)): pack_leader_count += 1
	check(models.size() == 3 and pack_leader_count == 1, "Three-model composition includes one Pack Leader and two Cavalry models")
	check(models.all(func(model: int) -> bool: return state.units[model].ranged_weapons[0].id == "bolt-pistol" and state.units[model].melee_weapons.size() == 2), "Prepared models receive the listed default weapons")
	check(Catalog.Current.profile(UNIT).max_supported_copies == 3 and six_models.size() == 6, "The six-model option and three-copy construction cap are published")
	var six_regular: Array[int] = []
	for model: int in six_models:
		if not bool(state.units[model].get("sergeant", false)): six_regular.append(model)
	var six_plasma_choices := loadout_choices.filter(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == six[0] and str(option.get("value", "")) == "plasma-pistol")
	check(six_regular.size() == 5 and six_plasma_choices.size() == 6, "Army preparations expose an eligible Plasma Pistol choice for each bearer in the six-model unit")

	var regular := int(models[1]) if bool(state.units[models[0]].get("sergeant", false)) else int(models[0])
	var first_six_regular := six_regular[0]
	var second_six_regular := six_regular[1]
	var opponent_squad := squads_for(state, 2)[0]
	var before_wrong_owner := var_to_bytes(state)
	var plasma_choice := find_choice(state, 1, first_six_regular, six[0], "plasma-pistol")
	check(not plasma_choice.is_empty(), "The six-model unit offers an eligible Plasma Pistol replacement (" + str(loadout_choices) + ")")
	var wrong_owner := PublicUnitCommand.submit(state, 2, plasma_choice)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot submit or mutate army-preparation loadouts")
	var first_plasma := choose(state, 1, first_six_regular, six[0], "plasma-pistol")
	check(str(first_plasma.get("error", "")).is_empty(), "A six-model unit can take its first Plasma Pistol (" + str(first_plasma) + ")")
	var second_plasma := choose(state, 1, second_six_regular, six[0], "plasma-pistol")
	check(str(second_plasma.get("error", "")).is_empty(), "The per-three-model option allows a second Plasma Pistol in a six-model unit (" + str(second_plasma) + ")")
	var third_choice := find_choice(state, 1, six_regular[2], six[0], "plasma-pistol")
	check(third_choice.is_empty(), "A six-model unit cannot exceed two Plasma Pistols")

	var shield_result := choose(state, 1, regular, three[0], "boltgun-storm-shield")
	var shield_defense := Defenders.profile(state, regular)
	check(str(shield_result.get("error", "")).is_empty() and int(state.squads[three[0]].training_cost) == 120 and int(shield_defense.get("invulnerable_target", 0)) == 4 and int(shield_defense.get("wounds_per_model", 0)) == 4, "Storm Shield costs five points and grants only its bearer a 4+ invulnerable save")
	check(C.UnitAbilities.sources(state, three[0], "storm-shield") == [regular] and state.units[regular].ranged_weapons[0].id == "boltgun" and state.units[regular].melee_weapons.size() == 2, "The shield bearer retains both melee weapons and only that model exposes the Storm Shield ability")
	var restore := choose(state, 1, regular, three[0], "default")
	var restored_defense := Defenders.profile(state, regular)
	check(str(restore.get("error", "")).is_empty() and int(state.squads[three[0]].training_cost) == 115 and int(restored_defense.get("invulnerable_target", 0)) == 0 and state.units[regular].ranged_weapons[0].id == "bolt-pistol", "Restoring the default package reverses price and bearer-only defense")

	var base_melee: Dictionary = profile.melee[0].profiles.standard
	var uncharged := C.UnitAbilities.weapon(state, regular, opponent_squad, base_melee, true)
	state.squads[three[0]].charged = true
	var charged := C.UnitAbilities.weapon(state, regular, opponent_squad, base_melee, true)
	var ranged: Dictionary = profile.ranged[0].profiles.standard
	var charged_ranged := C.UnitAbilities.weapon(state, regular, opponent_squad, ranged, false)
	check(int(uncharged.strength) == 5 and int(uncharged.damage) == 1 and int(charged.strength) == 6 and int(charged.damage) == 2, "Thunderous Charge adds Strength and Damage only after a Charge move for melee attacks")
	check(int(charged_ranged.strength) == 5 and int(charged_ranged.damage) == 1, "Thunderous Charge does not modify ranged attacks")

	if failures == 0:
		print("Thunderwolf Cavalry checks passed")
		quit(0)
	else:
		print("Thunderwolf Cavalry checks: %d failures" % failures)
		quit(1)

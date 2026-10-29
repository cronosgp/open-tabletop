extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "wolf-guard-terminators"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry(UNIT, 5), entry(UNIT, 10)] if owner == 1 else [entry(UNIT, 5)]
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

func squad_for(state: Dictionary, owner: int, strength: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner and int(state.squads[squad].get("starting_strength", -1)) == strength:
			for model: int in C.living(state, squad):
				if C.UnitAbilities.identity(state.units[model]) == UNIT: return squad
	return -1

func find_choice(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "wolf-guard-terminator-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_choice(state, player, model, squad, value))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000000318" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "BBF8E8372AA7A599BEEB7EC92CE309D2C8073C3A638F8A0CA4A52FB4AC78FB1E", "Wolf Guard Terminators is bound to the Space Wolves App sheet and verified source slice")
	check(profile.points_by_models == {5: 180, 10: 365} and profile.third_plus_points_by_models == {5: 220, 10: 405} and profile.wargear_costs == {"storm-shield": 5} and profile.models == 5 and profile.base_size_source_mm == 40, "Source-priced sizes, optional Storm Shield points, five-model composition and 40 mm bases are retained")
	check(profile.stats == {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Wolf Guard Terminator characteristics include the sheet's baseline 4+ invulnerable save")
	check(profile.keywords == ["ADEPTUS ASTARTES", "INFANTRY", "IMPERIUM", "SPACE WOLVES", "TERMINATOR"], "The profile carries every exported faction and unit keyword")
	check(profile.ranged[0].id == "storm-bolter" and profile.ranged[0].profiles.standard.attacks == 2 and profile.ranged[0].profiles.standard.keywords["rapid-fire"] == 2, "Storm Bolter profile matches the export")
	check(profile.melee[0].id == "master-crafted-power-weapon" and profile.melee[0].profiles.standard.attacks == 4 and profile.melee[0].profiles.standard.strength == 5 and profile.melee[0].profiles.standard.ap == -2 and profile.melee[0].profiles.standard.damage == 2, "Master-crafted Power Weapon profile matches the export")
	var assault := Profiles.wolf_guard_terminator_weapons("assault-cannon-power-fist")
	var axe := Profiles.wolf_guard_terminator_weapons("relic-greataxe")
	var claws_profile := Profiles.wolf_guard_terminator_weapons("twin-lightning-claws")
	check(assault.ranged[0].profiles.standard.attacks == 6 and assault.ranged[0].profiles.standard.keywords["sustained-hits"] == 1 and assault.melee[0].profiles.standard.strength == 8, "Assault Cannon and Power Fist replacement profiles match the source")
	check(axe.ranged.is_empty() and axe.melee[0].profiles.standard.damage == 3 and axe.melee[0].profiles.standard.keywords["devastating-wounds"] and claws_profile.ranged.is_empty() and claws_profile.melee[0].profiles.standard.attacks == 6 and claws_profile.melee[0].profiles.standard.keywords["twin-linked"], "Pack Leader alternatives replace both default weapons with their source-listed profiles")
	check(Profiles.wolf_guard_terminator_weapons("unsupported").is_empty(), "Unknown Wolf Guard Terminator loadouts are rejected")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Profiles.profile(UNIT).source_datasheet_id == "000000318", "The current construction catalog admits the source-bounded sheet")
	check(LeaderLinks.targets("captain-in-terminator-armour").has(UNIT) and LeaderLinks.targets("chaplain-in-terminator-armour").has(UNIT) and LeaderLinks.targets("librarian-in-terminator-armour").has(UNIT) and LeaderLinks.targets("arjac-rockfist").has(UNIT) and LeaderLinks.targets("logan-grimnar").has(UNIT), "All five source-listed Leader endpoints are registered, including future Space Wolves characters")
	check(SupportAttachments.BODYGUARDS["ancient-in-terminator-armour"].has(UNIT), "Ancient in Terminator Armour is recorded as a source-listed Support")

	var state := fresh()
	check(not state.has("error"), "Wolf Guard Terminators prepare from the consolidated local construction catalog")
	if state.has("error"):
		print(str(state.error))
		quit(1)
		return
	var five := squad_for(state, 1, 5)
	var ten := squad_for(state, 1, 10)
	var five_models := models_for(state, 1, five)
	var ten_models := models_for(state, 1, ten)
	check(five_models.size() == 5 and ten_models.size() == 10 and int(state.squads[five].training_cost) == 180 and int(state.squads[ten].training_cost) == 365, "Five- and ten-model formations prepare at their current first/second-copy prices")
	if five_models.size() != 5 or ten_models.size() != 10:
		print("Wolf Guard Terminators checks: %d failures" % failures)
		quit(1)
		return
	var leader := five_models[0]
	var regular := five_models[1]
	var other_regular := five_models[2]
	check(state.units[leader].get("sergeant", false) and not state.units[regular].get("sergeant", false), "The first model is the Pack Leader and remaining models are regular Wolf Guard Terminators")
	check(state.units[leader].ranged_weapons[0].id == "storm-bolter" and state.units[leader].melee_weapons[0].id == "master-crafted-power-weapon", "The Pack Leader starts with its exported default equipment")
	check(C.UnitAbilities.has(state, five, "deep-strike") and C.UnitAbilities.has(state, five, "combat-doctrines") and C.UnitAbilities.has(state, five, "rugged-resilience"), "Deep Strike, Combat Doctrines and Rugged Resilience are registered")
	check(C.UnitAbilities.defensive_wound_modifier(state, five, 6, 6) == 0 and C.UnitAbilities.defensive_wound_modifier(state, five, 7, 6) == -1 and C.UnitAbilities.defensive_wound_modifier(state, five, 7, 6, true) == -1, "Rugged Resilience applies only when Strength exceeds Toughness, to ranged and melee attacks")
	check(find_choice(state, 1, leader, five, "assault-cannon-power-fist").is_empty() and not find_choice(state, 1, regular, five, "assault-cannon-power-fist").is_empty() and find_choice(state, 1, regular, five, "relic-greataxe").is_empty(), "Only regular Terminators may take the capped Assault Cannon package, while Pack Leader replacements stay role-locked")

	var before_wrong_owner := var_to_bytes(state)
	var shield_choice := find_choice(state, 1, regular, five, "storm-shield")
	var wrong_owner := PublicUnitCommand.submit(state, 2, shield_choice)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot submit or mutate army-preparation equipment")
	var special := choose(state, 1, regular, five, "assault-cannon-power-fist")
	check(str(special.get("error", "")).is_empty() and state.units[regular].ranged_weapons[0].id == "assault-cannon" and state.units[regular].melee_weapons[0].id == "power-fist", "The first regular model can replace both default weapons with the per-five package")
	check(find_choice(state, 1, other_regular, five, "assault-cannon-power-fist").is_empty(), "A five-model unit cannot exceed one Assault Cannon package")
	var added_shield := choose(state, 1, other_regular, five, "storm-shield")
	check(str(added_shield.get("error", "")).is_empty() and int(state.squads[five].training_cost) == 185 and int(state.units[other_regular].max_wounds) == 4 and int(state.units[other_regular].wounds) == 4, "A Storm Shield costs five points and adds one wound to its bearer")
	check(C.UnitAbilities.sources(state, five, "storm-shield") == [other_regular] and int(state.squads[five].stats.invulnerable_target) == 4, "Storm Shield is recorded only for its bearer and does not change the unit's baseline 4+ invulnerable save")
	var restored_shield := choose(state, 1, other_regular, five, "default")
	check(str(restored_shield.get("error", "")).is_empty() and int(state.squads[five].training_cost) == 180 and int(state.units[other_regular].max_wounds) == 3 and state.units[other_regular].ranged_weapons[0].id == "storm-bolter", "Restoring the default loadout reverses the shield cost, wound and weapon changes")
	var greataxe := choose(state, 1, leader, five, "relic-greataxe")
	check(str(greataxe.get("error", "")).is_empty() and state.units[leader].ranged_weapons.is_empty() and state.units[leader].melee_weapons[0].id == "relic-greataxe", "The Pack Leader can replace the Storm Bolter and Master-crafted Power Weapon with the Relic Greataxe")
	var claws := choose(state, 1, leader, five, "twin-lightning-claws")
	check(str(claws.get("error", "")).is_empty() and state.units[leader].melee_weapons[0].id == "twin-lightning-claws", "The Pack Leader can switch to Twin Lightning Claws")

	var ten_regulars: Array[int] = []
	for model: int in ten_models:
		if not state.units[model].get("sergeant", false): ten_regulars.append(model)
	var ten_first := choose(state, 1, ten_regulars[0], ten, "assault-cannon-power-fist")
	var ten_second := choose(state, 1, ten_regulars[1], ten, "assault-cannon-power-fist")
	check(str(ten_first.get("error", "")).is_empty() and str(ten_second.get("error", "")).is_empty() and find_choice(state, 1, ten_regulars[2], ten, "assault-cannon-power-fist").is_empty(), "A ten-model unit allows exactly two Assault Cannon packages")

	if failures == 0:
		print("Wolf Guard Terminators checks passed")
		quit(0)
	else:
		print("Wolf Guard Terminators checks: %d failures" % failures)
		quit(1)

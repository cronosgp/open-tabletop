extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const DeathCompanyDreadnought = preload("res://scripts/edition_11/death_company_dreadnought.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const WALKERS := ["bjorn-the-fell-handed", "murderfang", "venerable-dreadnought", "wulfen-dreadnought"]
const SOURCE_MANIFEST := "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d"
const SLICE_MANIFEST := "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry("intercessor-squad", 5)]
	result[1].entries = [entry("bjorn-the-fell-handed"), entry("murderfang"), entry("venerable-dreadnought"), entry("wulfen-dreadnought"), entry("njal-stormcaller"), entry("wulfen", 5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}}, selections())

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var models := models_for(state, owner, identity)
	return int(state.units[models[0]].get("squad", -1)) if not models.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func roll_four() -> int:
	return 4

func roll_two() -> int:
	return 2

func roll_six() -> int:
	return 6

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var expected_stats := {
		"bjorn-the-fell-handed": {"movement_inches": 9, "toughness": 10, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
		"murderfang": {"movement_inches": 9, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
		"venerable-dreadnought": {"movement_inches": 8, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"wulfen-dreadnought": {"movement_inches": 9, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
	}
	var expected_keywords := {
		"bjorn-the-fell-handed": ["SPACE WOLVES", "ADEPTUS ASTARTES", "VEHICLE", "SMOKE", "IMPERIUM", "DREADNOUGHT", "EPIC HERO", "CHARACTER", "WALKER"],
		"murderfang": ["ADEPTUS ASTARTES", "SPACE WOLVES", "DREADNOUGHT", "CHARACTER", "EPIC HERO", "WULFEN", "VEHICLE", "IMPERIUM", "WALKER"],
		"venerable-dreadnought": ["SPACE WOLVES", "ADEPTUS ASTARTES", "SMOKE", "IMPERIUM", "DREADNOUGHT", "WALKER", "VEHICLE"],
		"wulfen-dreadnought": ["ADEPTUS ASTARTES", "SPACE WOLVES", "IMPERIUM", "VEHICLE", "DREADNOUGHT", "WULFEN", "WALKER"],
	}
	var expected_ids := {"bjorn-the-fell-handed": "000000302", "murderfang": "000000314", "venerable-dreadnought": "000002801", "wulfen-dreadnought": "000004133"}
	var expected_points := {"bjorn-the-fell-handed": 160, "murderfang": 150, "venerable-dreadnought": 130, "wulfen-dreadnought": 140}
	for identity: String in WALKERS:
		var profile := Profiles.profile(identity)
		check(profile.source_book_id == "000000036" and profile.source_datasheet_id == expected_ids[identity] and profile.source_snapshot_id == "20261029T003124Z", "%s records its Book, datasheet and snapshot identity" % identity)
		check(profile.source_manifest_sha256 == SOURCE_MANIFEST and profile.source_slice_manifest_sha256 == SLICE_MANIFEST, "%s records both verified manifest hashes" % identity)
		check(profile.stats == expected_stats[identity] and profile.keywords == expected_keywords[identity] and profile.points == expected_points[identity] and profile.models == 1 and profile.base_size_source_mm == 60, "%s has source-matched characteristics, keywords, cost, model count and base" % identity)
		check(Catalog.Current.profile(identity).source_datasheet_id == expected_ids[identity], "%s is admitted through the consolidated current catalog" % identity)
	check(Profiles.profile("venerable-dreadnought").third_plus_points_by_models == {1: 140} and Profiles.profile("wulfen-dreadnought").third_plus_points_by_models == {1: 150}, "The two copy-cost schedules distinguish third-plus units")
	check(Profiles.profile("bjorn-the-fell-handed").max_supported_copies == 1 and Profiles.profile("murderfang").max_supported_copies == 1 and Profiles.profile("venerable-dreadnought").max_supported_copies == 3 and Profiles.profile("wulfen-dreadnought").max_supported_copies == 3, "Unique and three-copy limits match the local source")

	var bjorn_default := Profiles.space_wolves_walker_weapons("bjorn-the-fell-handed")
	var bjorn_helfrost := Profiles.space_wolves_walker_weapons("bjorn-the-fell-handed", "helfrost-cannon")
	var bjorn_melta := Profiles.space_wolves_walker_weapons("bjorn-the-fell-handed", "multi-melta")
	check(bjorn_default.ranged.map(func(weapon: Dictionary) -> String: return weapon.id) == ["assault-cannon", "heavy-flamer"] and bjorn_default.melee[0].id == "trueclaw", "Bjorn's fixed default ranged and melee weapons are present")
	check(bjorn_helfrost.ranged[0].profiles.dispersed.attacks == 3 and bjorn_helfrost.ranged[0].profiles.focused.damage == 5 and bjorn_melta.ranged[0].profiles.standard.keywords.melta == 3, "Bjorn's two source-listed Assault Cannon replacements retain both Helfrost profiles and Melta")
	var murderfang := Profiles.space_wolves_walker_weapons("murderfang")
	check(murderfang.ranged.map(func(weapon: Dictionary) -> String: return weapon.id) == ["heavy-flamer", "storm-bolter"] and murderfang.melee[0].profiles.standard.keywords == {"twin-linked": true, "sustained-hits": 1}, "Murderfang's fixed weapons and Murderclaws traits match the export")
	var venerable_default := Profiles.space_wolves_walker_weapons("venerable-dreadnought")
	var venerable_shield := Profiles.space_wolves_walker_weapons("venerable-dreadnought", "assault-cannon", "storm-bolter", "fenrisian-great-axe-blizzard-shield")
	var venerable_invalid := Profiles.space_wolves_walker_weapons("venerable-dreadnought", "multi-melta", "storm-bolter", "fenrisian-great-axe-blizzard-shield")
	check(venerable_default.ranged.map(func(weapon: Dictionary) -> String: return weapon.id) == ["assault-cannon", "storm-bolter"] and venerable_default.melee[0].id == "dreadnought-combat-weapon", "Venerable Dreadnought's default three weapon selections are present")
	check(venerable_shield.blizzard_shield and venerable_shield.ranged.map(func(weapon: Dictionary) -> String: return weapon.id) == ["storm-bolter"] and venerable_shield.melee[0].profiles.sweep.attacks == 12 and venerable_invalid.is_empty(), "The Venerable Great Axe and Blizzard Shield route replaces the Assault Cannon and excludes its conflicting alternative")
	var wulfen_default := Profiles.space_wolves_walker_weapons("wulfen-dreadnought")
	var wulfen_shield := Profiles.space_wolves_walker_weapons("wulfen-dreadnought", "", "heavy-flamer", "blizzard-shield")
	check(wulfen_default.ranged[0].id == "storm-bolter" and wulfen_default.melee.map(func(weapon: Dictionary) -> String: return weapon.id) == ["fenrisian-great-axe", "great-wolf-claw"], "Wulfen Dreadnought starts with Storm Bolter, Great Axe and Great Wolf Claw")
	check(wulfen_shield.blizzard_shield and wulfen_shield.ranged[0].id == "heavy-flamer" and wulfen_shield.melee.map(func(weapon: Dictionary) -> String: return weapon.id) == ["great-wolf-claw"], "Wulfen Blizzard Shield replaces only the Great Axe")

	var abilities := C.UnitAbilities.RULES
	check(["deadly-demise-1", "feel-no-pain-5", "legendary-tenacity", "ancient-tactician"].all(func(rule: String) -> bool: return rule in abilities.get("bjorn-the-fell-handed", [])), "Bjorn's full ability list is admitted")
	check(["deadly-demise-1", "feel-no-pain-6", "curse-of-the-wulfen", "murder-maker", "bestial-fury", "force-of-untamed-destruction"].all(func(rule: String) -> bool: return rule in abilities.get("murderfang", [])), "Murderfang's full ability list is admitted")
	check(["deadly-demise-1", "fervour-of-the-ancients"].all(func(rule: String) -> bool: return rule in abilities.get("venerable-dreadnought", [])), "The Venerable Dreadnought's abilities are admitted")
	check(["deadly-demise-1", "feel-no-pain-6", "curse-of-the-wulfen", "violent-fury", "bestial-rage", "blizzard-shield", "bestial-forms"].all(func(rule: String) -> bool: return rule in abilities.get("wulfen-dreadnought", [])), "The Wulfen Dreadnought's full ability list is admitted")
	for rule: String in ["deadly-demise-1", "legendary-tenacity", "ancient-tactician", "murder-maker", "bestial-fury", "force-of-untamed-destruction", "fervour-of-the-ancients", "violent-fury", "bestial-rage", "blizzard-shield"]:
		check(Capabilities.KNOWN.has(rule) and bool(Capabilities.KNOWN[rule].get("supported", false)), "%s has a supported capability record" % rule)

	var state := fresh()
	if state.has("error"):
		check(false, "The four source-priced walkers build from the consolidated catalog: " + str(state.error))
		quit(1)
		return
	var bjorn_model := models_for(state, 1, "bjorn-the-fell-handed")[0]
	var murderfang_model := models_for(state, 1, "murderfang")[0]
	var venerable_model := models_for(state, 1, "venerable-dreadnought")[0]
	var dread_model := models_for(state, 1, "wulfen-dreadnought")[0]
	var wulfen_model := models_for(state, 1, "wulfen")[0]
	var bjorn_squad := int(state.units[bjorn_model].squad)
	var murderfang_squad := int(state.units[murderfang_model].squad)
	var venerable_squad := int(state.units[venerable_model].squad)
	var dread_squad := int(state.units[dread_model].squad)
	var wulfen_squad := int(state.units[wulfen_model].squad)
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(has_personal_fnp(state, bjorn_model), "Bjorn's personal 5+ Feel No Pain is installed")
	check(C.UnitAbilities.deadly_demise_value(state, bjorn_model) == "1" and C.UnitAbilities.deadly_demise_value(state, murderfang_model) == "1" and C.UnitAbilities.deadly_demise_value(state, venerable_model) == "1" and C.UnitAbilities.deadly_demise_value(state, dread_model) == "1", "All four walkers expose Deadly Demise 1 to the shared resolver")
	check(has_personal_fnp(state, bjorn_model) and has_personal_fnp(state, murderfang_model, 6) and has_personal_fnp(state, dread_model, 6), "Bjorn has Feel No Pain 5+ and Murderfang/Wulfen Dreadnought have 6+")
	check(C.UnitAbilities.defensive_wound_modifier(state, bjorn_squad, 11, 10) == -1 and C.UnitAbilities.defensive_wound_modifier(state, bjorn_squad, 10, 10) == 0, "Legendary Tenacity applies only when Strength exceeds Bjorn's Toughness")
	var murderfang_warlord := C.UnitActions.apply(state, 1, {"action": "warlord", "model": murderfang_model, "target": -1, "value": ""}, Vector2.ZERO, Callable())
	check(str(murderfang_warlord.get("error", "")).contains("cannot be selected as your Warlord") and choice_for(state, 1, "warlord", murderfang_model).is_empty(), "Force of Untamed Destruction blocks forged and projected Warlord choices")

	var demise_state := state.duplicate(true)
	for model: int in demise_state.units:
		if int(demise_state.units[model].get("owner", -1)) == 1: demise_state.units[model].position = Vector2(-12, -12)
	for model: int in models_for(demise_state, 2, "intercessor-squad"): demise_state.units[model].position = Vector2(5, 0)
	demise_state.units[venerable_model].position = Vector2.ZERO
	demise_state.units[venerable_model].wounds = 0
	var target_models := models_for(demise_state, 2, "intercessor-squad")
	var target_wounds := int(demise_state.units[target_models[0]].wounds)
	var demise_started := DeadlyDemise.begin(demise_state, [venerable_model], Callable(self, "roll_six"))
	var demise_choices := DeadlyDemise.choices(demise_state, 2)
	var demise_allocation := DeadlyDemise.allocate(demise_state, 2, demise_choices[0], Callable()) if not demise_choices.is_empty() else {"error": "No mortal wound allocation was offered."}
	check(str(demise_started.get("error", "")).is_empty() and demise_started.get("complete", true) == false and str(demise_allocation.get("error", "")).is_empty() and int(demise_state.units[target_models[0]].wounds) == target_wounds - 1, "A destroyed walker rolls Deadly Demise on a 6 and allocates exactly 1 mortal wound through the shared resolver: %s | choices=%s | allocation=%s | wounds=%d->%d" % [str(demise_started), str(demise_choices), str(demise_allocation), target_wounds, int(demise_state.units[target_models[0]].wounds)])

	state.units[venerable_model].position = Vector2(0, 0)
	state.units[dread_model].position = Vector2(5, 0)
	var njal_model := models_for(state, 1, "njal-stormcaller")[0]
	state.units[njal_model].position = Vector2(0, 0)
	check(C.UnitAbilities.advance_modifier(state, dread_squad) == 1 and C.UnitAbilities.charge_modifier(state, dread_squad) == 1, "Fervour of the Ancients grants +1 Advance and Charge within 6 inches")
	state.units[dread_model].position = Vector2(9, 0)
	check(C.UnitAbilities.advance_modifier(state, dread_squad) == 0 and C.UnitAbilities.charge_modifier(state, dread_squad) == 0, "Fervour of the Ancients stops applying beyond 6 inches")
	state.units[dread_model].position = Vector2(5, 0)
	check(C.UnitAbilities.curse_of_the_wulfen_oc_bonus(state, dread_model) == 3, "Curse of the Wulfen grants a Vehicle +3 OC within 6 inches of a friendly non-Wulfen Character")
	state.units[dread_model].position = Vector2(9, 0)
	check(C.UnitAbilities.curse_of_the_wulfen_oc_bonus(state, dread_model) == 0, "Curse of the Wulfen aura stops applying outside 6 inches")
	state.units[dread_model].position = Vector2(5, 0)

	var venerable_choice := choice_for(state, 1, "space-wolves-walker-loadout", venerable_model, 2, "fenrisian-great-axe-blizzard-shield")
	var venerable_change := PublicUnitCommand.submit(state, 1, venerable_choice)
	check(not venerable_choice.is_empty() and str(venerable_change.get("error", "")).is_empty() and state.units[venerable_model].get("space_wolves_blizzard_shield", false), "The Venerable Blizzard Shield is selectable through the public preparation boundary")
	check(DefenderGroups.profile(state, venerable_model).invulnerable_target == 4, "The Venerable Blizzard Shield grants a 4+ invulnerable save")
	var twin_claw := Equipment.select(state, dread_model, true, "great-wolf-claw", "standard")
	check(str(twin_claw.get("error", "")).is_empty() and C.UnitAbilities.weapon(state, dread_model, enemy_squad, twin_claw.stats, true).keywords.get("twin-linked", false), "Violent Fury gives melee Twin-linked while the Wulfen Dreadnought has two melee weapons")
	var dread_shield_choice := choice_for(state, 1, "space-wolves-walker-loadout", dread_model, 2, "blizzard-shield")
	var dread_shield_change := PublicUnitCommand.submit(state, 1, dread_shield_choice)
	check(not dread_shield_choice.is_empty() and str(dread_shield_change.get("error", "")).is_empty() and state.units[dread_model].get("space_wolves_blizzard_shield", false), "The Wulfen Blizzard Shield is selectable through the public preparation boundary")
	check(DefenderGroups.profile(state, dread_model).invulnerable_target == 4 and state.units[dread_model].melee_weapons.size() == 1, "The Wulfen Blizzard Shield grants 4+ invulnerable and removes the axe")
	twin_claw = Equipment.select(state, dread_model, true, "great-wolf-claw", "standard")
	check(not C.UnitAbilities.weapon(state, dread_model, enemy_squad, twin_claw.stats, true).keywords.get("twin-linked", false), "Violent Fury stops granting Twin-linked when only one melee weapon remains")

	state.turn = 1
	check(C.UnitAbilities.discount(state, 1, bjorn_squad) == 1, "Ancient Tactician makes the first targeted stratagem cost 1 CP less")
	C.UnitAbilities.consume_discount(state, 1, bjorn_squad)
	check(C.UnitAbilities.discount(state, 1, bjorn_squad) == 0, "Ancient Tactician is limited to once per turn per army")
	state.turn = 3
	check(C.UnitAbilities.discount(state, 1, bjorn_squad) == 1, "Ancient Tactician becomes available on the next friendly turn")
	state.turn = 1
	state.phase = "movement"
	state.active = 1
	check(Stratagems.open_roll(state, 1, murderfang_squad, "after_advance_roll", [2], {}), "Bestial Fury opens a decision after an Advance roll")
	var reroll_decision := Stratagems.pending_decision(state)
	check(reroll_decision.get("source", "") == "stratagems" and reroll_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "bestial-fury"), "Bestial Fury is offered as a free Advance re-roll: %s" % str(reroll_decision))
	state.stratagems.pending = {}
	state.phase = "charge"
	check(Stratagems.open_roll(state, 1, murderfang_squad, "after_charge_roll", [2, 3], {}), "Bestial Fury opens a decision after a Charge roll")
	var charge_decision := Stratagems.pending_decision(state)
	check(charge_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "bestial-fury"), "Bestial Fury is offered as a free Charge re-roll")
	state.stratagems.pending = {}

	state.units[murderfang_model].position = Vector2(0, 0)
	state.units[wulfen_model].position = Vector2(4, 0)
	state.units[wulfen_model].wounds = 0
	state.phase = "fight"
	state.active = 2
	var retained := DetachmentStratagems.hold_destroyed(state, wulfen_model, Callable(self, "roll_four"))
	check(retained.get("held", false) and retained.get("rule", "") == "murder-maker" and state.units[wulfen_model].wounds == 1, "Murder-maker retains a destroyed Wulfen on a 4+ before the unit fights")

	state.units[dread_model].position = Vector2(0, 0)
	var enemy_models := models_for(state, 2, "intercessor-squad")
	for index: int in enemy_models.size(): state.units[enemy_models[index]].position = Vector2(8.0 + (index % 2) * 2.0, float(index / 2) * 2.0)
	for identity: String in ["bjorn-the-fell-handed", "murderfang", "venerable-dreadnought", "njal-stormcaller", "wulfen"]:
		for model: int in models_for(state, 1, identity): state.units[model].position = Vector2(-12.0, -12.0)
	state.units[dread_model].wounds = 7
	state.squads[dread_squad].moved = false
	state.squads[dread_squad].battle_shocked = false
	state.phase = "shooting"
	state.active = 2
	DeathCompanyDreadnought.open_after_enemy_shot(state, enemy_squad, [{"target_squad": dread_squad, "hits": 0, "damage_applied": 1, "allocations": [{"model": dread_model, "damage": 1}]}])
	check(state.unit_abilities.window.get("kind", "") == DeathCompanyDreadnought.WINDOW, "Bestial Rage opens only from wound damage even when the attack pool had no hits field")
	var use_choice := DeathCompanyDreadnought.choices(state, 1)[0]
	var rolled := DeathCompanyDreadnought.apply(state, 1, use_choice, Vector2.ZERO, Callable(self, "roll_two"))
	check(str(rolled.get("error", "")).is_empty() and state.unit_abilities.window.get("distance", 0) == 3, "Bestial Rage rolls D6+1 for its Surge movement")
	var target_choice: Dictionary = {}
	for option: Dictionary in DeathCompanyDreadnought.choices(state, 1):
		if option.get("action", "") == "death-company-fury-target": target_choice = option; break
	check(not target_choice.is_empty(), "Bestial Rage offers the closest enemy Surge target")
	var target_result := DeathCompanyDreadnought.apply(state, 1, target_choice, Vector2.ZERO, Callable())
	var placement_choice := {"action": "death-company-fury-place", "model": dread_model, "target": dread_squad, "value": ""}
	var placement_result := DeathCompanyDreadnought.apply(state, 1, placement_choice, Vector2(3, 0), Callable())
	var confirm_choice := {"action": "death-company-fury-confirm", "model": -1, "target": dread_squad, "value": ""}
	var confirm_result := DeathCompanyDreadnought.apply(state, 1, confirm_choice, Vector2.ZERO, Callable())
	check(str(target_result.get("error", "")).is_empty() and str(placement_result.get("error", "")).is_empty() and str(confirm_result.get("error", "")).is_empty() and state.squads[dread_squad].move_type == "surge", "Bestial Rage validates and completes its shared Surge placement")

	if failures > 0:
		quit(1)
		return
	print("Space Wolves walker source profiles, admission, equipment and locally implemented abilities passed.")
	quit(0)

func has_personal_fnp(state: Dictionary, model: int, target: int = 5) -> bool:
	for rule: Dictionary in Prevention.rules(state, model):
		if int(rule.get("target", 0)) == target and str(rule.get("against", "")) == "any": return true
	return false

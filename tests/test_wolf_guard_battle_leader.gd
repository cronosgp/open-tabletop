extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "wolf-guard-battle-leader"

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
	result[1].entries = [entry(UNIT), entry("intercessor-squad", 5)]
	result[2].entries = [entry("intercessor-squad", 5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units.get(model, {}).get("squad", -1))

func find_choice(state: Dictionary, player: int, action: String, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, player: int, action: String, model: int, squad: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_choice(state, player, action, model, squad, value))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000004130" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764", "Wolf Guard Battle Leader is bound to its Space Wolves App sheet and verified local slice")
	check(profile.get("points_by_models", {}) == {1: 80} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 3 and profile.get("base_size_source_mm", -1) == 40, "Fixed 80-point profile, three-copy cap and 40 mm base match the local export")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Characteristics include the export's baseline 4+ invulnerable save")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"], "All six source keywords are retained")
	var pistol: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {})
	var power_weapon: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	var hammer: Dictionary = profile.get("additional_weapon_profiles", {}).get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(pistol.get("standard", {}).get("skill") == 3 and pistol.standard.strength == 7 and pistol.standard.ap == -2 and pistol.standard.damage == 1, "Standard Plasma Pistol profile matches the source")
	check(pistol.get("supercharge", {}).get("skill") == 3 and pistol.supercharge.strength == 8 and pistol.supercharge.ap == -3 and pistol.supercharge.damage == 2 and pistol.supercharge.keywords.get("hazardous", false), "Supercharge profile retains its source statistics and Hazardous")
	check(power_weapon.get("attacks") == 7 and power_weapon.get("skill") == 2 and power_weapon.get("strength") == 6 and power_weapon.get("ap") == -2 and power_weapon.get("damage") == 2, "Master-crafted Power Weapon matches its source profile")
	check(hammer.get("attacks") == 5 and hammer.get("skill") == 3 and hammer.get("strength") == 8 and hammer.get("ap") == -2 and hammer.get("damage") == 3 and hammer.get("keywords", {}).get("devastating-wounds", false), "Thunder Hammer matches its source profile")
	check(Profiles.wolf_guard_battle_leader_weapons("storm-shield", "thunder-hammer").ranged.is_empty() and Profiles.wolf_guard_battle_leader_weapons("invalid", "thunder-hammer").is_empty(), "Storm Shield replaces the pistol and unknown packages are rejected")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get("wolf-guard-headtakers", {}).get("current_reference", false), "The Battle Leader and reconciled, source-priced Headtakers profile are selectable")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "tempered-ferocity", "heroic-last-stand"], "Leader, doctrines, Warlord eligibility and both datasheet abilities register")
	check(Registry.supported("tempered-ferocity") and Registry.supported("heroic-last-stand"), "Both named abilities are recorded as supported capabilities")
	var targets := LeaderLinks.targets(UNIT)
	check(targets == ["wolf-guard-headtakers", "bladeguard-veteran-squad", "blood-claws", "intercessor-squad", "grey-hunters", "assault-intercessor-squad"], "All six source-listed Leader endpoints stay in export order")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT)]})
	var duplicate := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 80 and duplicate.get("error", "").is_empty(), "The non-Epic profile is admitted at source cost and accepts multiple copies")

	var state := fresh()
	check(not state.has("error"), "The source profile prepares through the consolidated local catalog: %s" % state.get("error", ""))
	if state.has("error"):
		quit(1)
		return
	var leader := model_for(state, 1, UNIT)
	var squad := int(state.units[leader].squad)
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(leader > 0 and state.units[leader].ranged_weapons[0].id == "plasma-pistol" and state.units[leader].melee_weapons[0].id == "master-crafted-power-weapon", "The model enters preparation with the exported default weapons")
	check(C.UnitAbilities.has(state, squad, "tempered-ferocity") and C.UnitAbilities.has(state, squad, "heroic-last-stand") and int(state.squads[squad].stats.invulnerable_target) == 4, "Datasheet abilities and baseline invulnerable save are present in the materialized unit")
	state.phase = "deployment"
	state.active = 1
	check(C.UnitActions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == leader), "Transhuman Strategist makes the Battle Leader a Warlord choice")

	var before_wrong_owner := var_to_bytes(state)
	var shield_choice := find_choice(state, 1, "wolf-guard-battle-leader-ranged", leader, squad, "storm-shield")
	var denied := PublicUnitCommand.submit(state, 2, shield_choice)
	check(not str(denied.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot equip the Battle Leader")
	var hammer_choice := choose(state, 1, "wolf-guard-battle-leader-melee", leader, squad, "thunder-hammer")
	var storm_shield := choose(state, 1, "wolf-guard-battle-leader-ranged", leader, squad, "storm-shield")
	check(hammer_choice.get("error", "").is_empty() and state.units[leader].melee_weapons[0].id == "thunder-hammer", "The Battle Leader can replace the Master-crafted Power Weapon with a Thunder Hammer")
	check(storm_shield.get("error", "").is_empty() and state.units[leader].ranged_weapons.is_empty() and state.units[leader].melee_weapons[0].id == "thunder-hammer" and int(state.units[leader].max_wounds) == 6 and int(state.units[leader].wounds) == 6 and int(state.squads[squad].training_cost) == 80, "Storm Shield replaces only the pistol, adds one Wound and preserves the independent melee choice at no extra cost")
	var restore_pistol := choose(state, 1, "wolf-guard-battle-leader-ranged", leader, squad, "plasma-pistol")
	var restore_weapon := choose(state, 1, "wolf-guard-battle-leader-melee", leader, squad, "master-crafted-power-weapon")
	check(restore_pistol.get("error", "").is_empty() and restore_weapon.get("error", "").is_empty() and state.units[leader].ranged_weapons[0].id == "plasma-pistol" and state.units[leader].melee_weapons[0].id == "master-crafted-power-weapon" and int(state.units[leader].max_wounds) == 5 and int(state.units[leader].wounds) == 5, "Both source-listed replacement choices can be restored independently")

	state.phase = "shooting"
	state.active = 1
	state.units[leader].position = Vector2.ZERO
	for index in range(C.living(state, enemy_squad).size()): state.units[C.living(state, enemy_squad)[index]].position = Vector2(5.5 + index * 0.1, index * 0.1)
	var pistol_weapon: Dictionary = state.units[leader].ranged_weapons[0]
	var near_plan := C.AttackPlan.prepare(state, squad, false, [{"model": leader, "target": enemy_squad, "amount": 1, "weapon": pistol_weapon.id, "profile": "standard"}], false)
	check(near_plan.get("error", "").is_empty() and near_plan.get("batches", []).size() == 1 and int(near_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1 and near_plan.batches[0].context.get("hit_reroll", "") == "ones", "Tempered Ferocity grants Sustained Hits 1 and re-rolls Hit rolls of 1 against a nearby target")
	for model: int in C.living(state, enemy_squad): state.units[model].position += Vector2(2.6, 0)
	var far_plan := C.AttackPlan.prepare(state, squad, false, [{"model": leader, "target": enemy_squad, "amount": 1, "weapon": pistol_weapon.id, "profile": "standard"}], false)
	check(far_plan.get("error", "").is_empty() and far_plan.get("batches", []).size() == 1 and far_plan.batches[0].context.get("hit_reroll", "none") == "none" and int(far_plan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1, "The Hit re-roll stops beyond 6 inches while Sustained Hits remains")

	state.phase = "fight"
	state.squads[squad].fought = false
	state.fight_selected = -1
	state.units[leader].wounds = 0
	var retained: Dictionary = C.DetachmentStratagems.hold_destroyed(state, leader, func() -> int: return 2)
	check(retained.get("held", false) and retained.get("rule", "") == "heroic-last-stand" and state.units[leader].wounds == 1 and state.units[leader].get("lingering", false), "Heroic Last Stand retains the model on a 2+")
	C.DetachmentStratagems.remove_lingering(state, squad)
	check(state.units[leader].wounds == 0 and not state.units[leader].get("lingering", false), "The retained model is removed after its unit fights or the Fight phase ends")
	state.units[leader].wounds = 0
	var failed: Dictionary = C.DetachmentStratagems.hold_destroyed(state, leader, func() -> int: return 1)
	check(not failed.get("held", false) and failed.get("roll", 0) == 1, "Heroic Last Stand fails on an unmodified 1")
	state.units[leader].wounds = 0
	state.fight_selected = squad
	var after_selected: Dictionary = C.DetachmentStratagems.hold_destroyed(state, leader, func() -> int: return 6)
	check(not after_selected.get("held", false), "Heroic Last Stand does not trigger after the unit has been selected to fight")
	state.fight_selected = -1
	state.squads[squad].fought = true
	var after_fought: Dictionary = C.DetachmentStratagems.hold_destroyed(state, leader, func() -> int: return 6)
	check(not after_fought.get("held", false), "Heroic Last Stand does not trigger after the unit has fought")
	state.phase = "shooting"
	state.squads[squad].fought = false
	var outside_fight: Dictionary = C.DetachmentStratagems.hold_destroyed(state, leader, func() -> int: return 6)
	check(not outside_fight.get("held", false), "Heroic Last Stand is limited to the Fight phase")

	print("Wolf Guard Battle Leader checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

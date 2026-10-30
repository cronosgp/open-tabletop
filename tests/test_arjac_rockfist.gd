extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const ID := "40kdc:11e:adeptus-astartes:arjac-rockfist"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
	result[1].entries = [entry("arjac-rockfist"), entry("wolf-guard-terminators", 5)]
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections())

func model_for(state: Dictionary, owner: int, identity: String, role: String = "") -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		if not role.is_empty() and str(unit.get("attachment_role", "")) != role: continue
		return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength < 0 or int(state.squads[squad].get("starting_strength", -1)) == strength: return squad
	return -1

func attach_choice(state: Dictionary, model: int, target: int) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "attach" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target: return option
	return {}

func attack_context(state: Dictionary, squad: int, model: int, target: int, melee: bool, weapon: String) -> Dictionary:
	var plan := AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": "standard"}], false)
	if not str(plan.get("error", "")).is_empty(): return {"error": str(plan.error)}
	return plan.get("batches", [{}])[0].get("context", {})

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("arjac-rockfist")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000317" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "D63245311AC15F3B13E1A0235E9A642FD374D2ECD0B1853F791EE4981633DC06", "Arjac identity is bound to the Space Wolves App and subject-scoped verified export")
	check(profile.get("points_by_models", {}) == {1: 105} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 50, "Arjac retains the one-model 105-point Epic Hero profile, unique-copy limit and 50 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Arjac characteristics match the current export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TERMINATOR"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All source-listed Arjac keywords are retained")
	var ranged: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.ranged[0].get("physical_weapon_id", "") == "foehammer" and profile.melee[0].get("physical_weapon_id", "") == "foehammer", "Foehammer's ranged and melee profiles remain one physical weapon")
	check(ranged.get("range_inches") == 9.0 and ranged.get("attacks") == 1 and ranged.get("skill") == 2 and ranged.get("strength") == 10 and ranged.get("ap") == -2 and ranged.get("damage") == 3 and ranged.get("keywords", {}) == {"assault": true, "anti-monster": 3, "anti-vehicle": 3}, "Foehammer ranged profile matches the export")
	check(melee.get("attacks") == 5 and melee.get("skill") == 2 and melee.get("strength") == 10 and melee.get("ap") == -2 and melee.get("damage") == 3 and melee.get("keywords", {}) == {"anti-monster": 3, "anti-vehicle": 3, "precision": true}, "Foehammer melee profile matches the export")
	check(Army.SPECS.has("arjac-rockfist") and Army.SPECS["arjac-rockfist"].get("current_reference", false), "Arjac is registered in current-reference construction admission")
	check(AbilityCatalog.RULES.get("arjac-rockfist", []) == ["leader", "deep-strike", "combat-doctrines", "champion-of-the-kingsguard", "anvil-of-endurance"], "Core, faction and datasheet abilities are all registered")
	check(Registry.supported("champion-of-the-kingsguard") and Registry.supported("anvil-of-endurance"), "Both Arjac datasheet abilities are exposed as supported capabilities")
	var targets := LeaderLinks.targets("arjac-rockfist")
	check(targets.size() == 3 and "terminator-squad" in targets and "terminator-assault-squad" in targets and "wolf-guard-terminators" in targets, "All three source-listed Leader targets are connected")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("arjac-rockfist")]})
	var duplicate := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("arjac-rockfist", 1, 2)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 105 and not str(duplicate.get("error", "")).is_empty(), "Construction admits the source cost and enforces the one-copy Epic Hero limit")

	var state := fresh_state()
	check(not state.has("error"), "Test armies materialize from the consolidated local catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var arjac := model_for(state, 1, "arjac-rockfist")
		var guard := model_for(state, 1, "wolf-guard-terminators")
		var guard_squad := squad_for(state, 1, "wolf-guard-terminators", 5)
		var character_squad := squad_for(state, 2, "captain")
		var noncharacter_squad := squad_for(state, 2, "intercessor-squad", 5)
		state.phase = "deployment"
		state.active = 1
		state.first_player = 1
		state.unit_abilities.setup_players = []
		var attach := PublicUnitCommand.submit(state, 1, attach_choice(state, arjac, guard_squad))
		guard = model_for(state, 1, "wolf-guard-terminators", "bodyguard")
		guard_squad = int(state.units.get(arjac, {}).get("squad", -1))
		check(arjac >= 0 and guard >= 0 and guard_squad >= 0 and str(attach.get("error", "")).is_empty(), "Arjac attaches to Wolf Guard Terminators through the public Leader command")
		for model: int in state.units:
			var squad := int(state.units[model].get("squad", -1))
			if squad == guard_squad: state.units[model].position = Vector2.ZERO
			elif squad == character_squad: state.units[model].position = Vector2(6, 0)
			elif squad == noncharacter_squad: state.units[model].position = Vector2(7, 2)
		state.phase = "shooting"
		state.active = 1
		var arjac_character := attack_context(state, guard_squad, arjac, character_squad, false, "foehammer-ranged")
		var arjac_noncharacter := attack_context(state, guard_squad, arjac, noncharacter_squad, false, "foehammer-ranged")
		var guard_character := attack_context(state, guard_squad, guard, character_squad, false, "storm-bolter")
		check(arjac_character.get("hit_reroll", "none") == "ones" and arjac_character.get("wound_reroll", "none") == "ones", "Arjac re-rolls Hit and Wound rolls of 1 against a CHARACTER target")
		check(arjac_noncharacter.get("hit_reroll", "none") == "none" and arjac_noncharacter.get("wound_reroll", "none") == "none", "Champion of the Kingsguard does not apply to non-CHARACTER targets")
		check(guard_character.get("hit_reroll", "none") == "none" and guard_character.get("wound_reroll", "none") == "none", "Arjac's model-only re-rolls do not extend to attached bodyguards")

		var failed_state: Dictionary = state.duplicate(true)
		failed_state.phase = "fight"
		failed_state.fight_selected = -1
		failed_state.squads[guard_squad].fought = false
		failed_state.units[guard].wounds = 0
		var failed: Dictionary = C.DetachmentStratagems.hold_destroyed(failed_state, guard, func() -> int: return 3)
		check(failed.get("error", "").is_empty() and not failed.get("held", false) and failed.get("roll", 0) == 3 and failed_state.units[guard].wounds == 0, "Anvil of Endurance fails on an unmodified 3")
		var held_state: Dictionary = state.duplicate(true)
		held_state.phase = "fight"
		held_state.fight_selected = -1
		held_state.squads[guard_squad].fought = false
		held_state.units[guard].wounds = 0
		var held: Dictionary = C.DetachmentStratagems.hold_destroyed(held_state, guard, func() -> int: return 4)
		check(held.get("error", "").is_empty() and held.get("held", false) and held.get("rule", "") == "anvil-of-endurance" and held_state.units[guard].wounds == 1, "Anvil retains a destroyed bodyguard model on 4+")
		C.DetachmentStratagems.remove_lingering(held_state, guard_squad)
		check(held_state.units[guard].wounds == 0 and not held_state.units[guard].get("arjac_anvil_lingering", false), "The retained model is removed as soon as Arjac's unit fights")
		var end_phase_state: Dictionary = state.duplicate(true)
		end_phase_state.phase = "fight"
		end_phase_state.fight_selected = -1
		end_phase_state.squads[guard_squad].fought = false
		end_phase_state.units[guard].wounds = 0
		var phase_hold: Dictionary = C.DetachmentStratagems.hold_destroyed(end_phase_state, guard, func() -> int: return 6)
		C.DetachmentStratagems.remove_lingering(end_phase_state)
		check(phase_hold.get("held", false) and end_phase_state.units[guard].wounds == 0, "The retained model is removed at Fight-phase end")
		var selected_state: Dictionary = state.duplicate(true)
		selected_state.phase = "fight"
		selected_state.fight_selected = guard_squad
		selected_state.squads[guard_squad].fought = false
		selected_state.units[guard].wounds = 0
		var after_selected: Dictionary = C.DetachmentStratagems.hold_destroyed(selected_state, guard, func() -> int: return 6)
		check(not after_selected.get("held", false), "Anvil does not trigger once the unit has been selected to fight")
		var outside_window: Dictionary = state.duplicate(true)
		outside_window.phase = "shooting"
		outside_window.units[guard].wounds = 0
		check(not C.DetachmentStratagems.hold_destroyed(outside_window, guard, func() -> int: return 6).get("held", false), "Anvil does not trigger outside the Fight phase")

	if failures == 0: print("Arjac Rockfist checks: passed")
	else: print("Arjac Rockfist checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "wolf-guard-headtakers"
const ENTRY := "40kdc:11e:adeptus-astartes:wolf-guard-headtakers"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, composition: String = "") -> Dictionary:
	var result := {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}
	if not composition.is_empty(): result.composition_choice_id = composition
	return result

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
		result[owner].entries = []
	result[1].entries = [entry(UNIT, 6, "six-mixed"), entry("ragnar-blackmane", 1)]
	result[2].entries = [entry(UNIT, 12, "twelve-mixed"), entry("intercessor-squad", 5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}
	}, selections())

func squads_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if Abilities.identity(state.units[model]) == identity:
				result.append(squad)
				break
	result.sort()
	return result

func models_for(state: Dictionary, squad: int, role: String = "") -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or Abilities.identity(unit) != UNIT: continue
		if not role.is_empty() and str(unit.get("wolf_guard_headtaker_role", "")) != role: continue
		result.append(model)
	result.sort()
	return result

func model_with_role(state: Dictionary, squad: int, role: String) -> int:
	var models := models_for(state, squad, role)
	return models[0] if not models.is_empty() else -1

func find_choice(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value: return option
	return {}

func submit(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_choice(state, player, action, model, target, value), Vector2.ZERO)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_datasheet_id == "000004131" and profile.source_snapshot_id == "20261029T072022Z-final-integration" and profile.source_slice_manifest_sha256 == "9779a6e90c1690c19179a7eda8a66498d4cce2c6e953e05d3bcd7a644763fe1e", "Headtakers records the verified Space Wolves App sheet and bounded slice")
	var expected_mfm_cost_rows: Array[Dictionary] = [
		{"models": 3, "headtakers": 3, "hunting_wolves": 0, "first_to_second_points": 85, "third_plus_points": 95, "wahapedia_composition_compatible": false},
		{"models": 6, "headtakers": 3, "hunting_wolves": 3, "first_to_second_points": 115, "third_plus_points": 125, "wahapedia_composition_compatible": true},
		{"models": 6, "headtakers": 6, "hunting_wolves": 0, "first_to_second_points": 170, "third_plus_points": 180, "wahapedia_composition_compatible": false},
		{"models": 12, "headtakers": 6, "hunting_wolves": 6, "first_to_second_points": 230, "third_plus_points": 240, "wahapedia_composition_compatible": true}
	]
	check(profile.get("mfm_composition_cost_rows", []) == expected_mfm_cost_rows,
		"All four exact MFM role compositions and both copy tiers remain recorded in the runtime profile")
	check(profile.points_by_models == {6: 115, 12: 230} and profile.third_plus_points_by_models == {6: 125, 12: 240} and Army.construction_model_sizes(UNIT, profile) == [6, 12], "Only the MFM-priced mixed compositions compatible with the Wahapedia minimum composition are exposed")
	check(profile.composition_options.size() == 2 and profile.composition_options[0].roles.count("wolf-guard-headtaker") == 3 and profile.composition_options[0].roles.count("hunting-wolf") == 3 and profile.composition_options[1].roles.count("wolf-guard-headtaker") == 6 and profile.composition_options[1].roles.count("hunting-wolf") == 6, "The two admitted choices preserve each source-listed Headtaker and Hunting Wolf count")
	check(Profiles.wolf_guard_headtaker_model_loadout("wolf-guard-headtaker").stats.wounds == 3 and Profiles.wolf_guard_headtaker_model_loadout("hunting-wolf").stats.objective_control == 0 and Profiles.wolf_guard_headtaker_model_loadout("hunting-wolf").base_radius_inches == 30.0 / 25.4, "Role-specific characteristics and the Hunting Wolf base proxy are recorded")
	var shield_profile := Profiles.wolf_guard_headtaker_model_loadout("wolf-guard-headtaker", true)
	check(shield_profile.stats.invulnerable_target == 4 and shield_profile.melee[0].profiles.standard.attacks == 4 and shield_profile.melee[0].id == "master-crafted-power-weapon", "Storm Shield replaces paired weapons and grants the source-listed 4+ invulnerable save")
	check(Army.SPECS.has(UNIT) and Army.SPECS[UNIT].get("current_reference", false) and "wolf-guard-headtakers" in Links.targets("ragnar-blackmane"), "The partial current profile and source-listed Leader endpoint are present")
	check("headhunter-quarry" in C.UnitAbilities.RULES.get(UNIT, []) and "let-loose-the-wolves" in C.UnitAbilities.RULES.get(UNIT, []) and "hunting-hounds" in C.UnitAbilities.RULES.get(UNIT, []) and "storm-shield" in C.UnitAbilities.RULES.get(UNIT, []), "All four datasheet abilities are registered")

	var invalid_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 3, "three-headtakers")]})
	var invalid_only := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 6, "six-headtakers-only")]})
	check(not str(invalid_three.get("error", "")).is_empty() and not str(invalid_only.get("error", "")).is_empty(), "Headtakers-only cost rows remain blocked against the selected Wahapedia composition")
	var leader_endpoints := ["wolf-priest", "wolf-guard-battle-leader", "ragnar-blackmane", "ulrik-the-slayer", "njal-stormcaller", "iron-priest"]
	for leader_identity: String in leader_endpoints:
		var leader_selections: Dictionary = selections()
		leader_selections[1].entries = [entry(UNIT, 6, "six-mixed"), entry(leader_identity, 1)]
		var leader_state := F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}}, leader_selections)
		if leader_state.has("error"):
			check(false, "%s roster materializes with the admitted Headtakers profile: %s" % [leader_identity, str(leader_state.error)])
			continue
		var leader_squads := squads_for(leader_state, 1, UNIT)
		var leader_model := -1
		for model: int in leader_state.get("units", {}):
			if int(leader_state.units[model].get("owner", -1)) == 1 and Abilities.identity(leader_state.units[model]) == leader_identity: leader_model = model
		var leader_choice := find_choice(leader_state, 1, "attach", leader_model, leader_squads[0], "") if not leader_squads.is_empty() and leader_model >= 0 else {}
		var leader_result := PublicUnitCommand.submit(leader_state, 1, leader_choice, Vector2.ZERO)
		var leader_attached: bool = not leader_squads.is_empty() and bool(leader_state.squads[leader_squads[0]].get("attached", false))
		check(not leader_choice.is_empty() and str(leader_result.get("error", "")).is_empty() and leader_attached, "%s can attach to the admitted mixed Headtakers profile" % leader_identity)

	var state := fresh()
	check(not state.has("error"), "The mixed 6- and 12-model rosters materialize with their MFM cost tiers")
	if state.has("error"):
		print(str(state.get("error", "")))
		quit(1)
		return
	var friendly := squads_for(state, 1, UNIT)
	var enemy := squads_for(state, 2, UNIT)
	check(friendly.size() == 1 and enemy.size() == 1 and models_for(state, friendly[0]).size() == 6 and models_for(state, enemy[0]).size() == 12, "Both source-priced mixed formations retain all models")
	if friendly.is_empty() or enemy.is_empty():
		quit(1)
		return
	var headtaker := model_with_role(state, friendly[0], "wolf-guard-headtaker")
	var hunting_wolf := model_with_role(state, friendly[0], "hunting-wolf")
	check(headtaker >= 0 and hunting_wolf >= 0 and state.units[headtaker].defense.toughness == 5 and state.units[headtaker].ranged_weapons[0].id == "heavy-bolt-pistol" and state.units[hunting_wolf].defense.toughness == 4 and state.units[hunting_wolf].melee_weapons[0].id == "teeth-and-claws", "Prepared model roles carry their own source weapons and characteristics")
	var shield_choice := find_choice(state, 1, "wolf-guard-headtaker-storm-shield", headtaker, friendly[0], "on")
	var shield_result := PublicUnitCommand.submit(state, 1, shield_choice, Vector2.ZERO)
	check(not shield_choice.is_empty() and str(shield_result.get("error", "")).is_empty() and state.units[headtaker].defense.invulnerable_target == 4 and state.units[headtaker].melee_weapons[0].id == "master-crafted-power-weapon" and Abilities.has(state, friendly[0], "storm-shield"), "The public setup choice equips a Storm Shield on one Headtaker only")
	var restore_result := submit(state, 1, "wolf-guard-headtaker-storm-shield", headtaker, friendly[0], "off")
	check(str(restore_result.get("error", "")).is_empty() and state.units[headtaker].defense.invulnerable_target == 0 and state.units[headtaker].melee_weapons[0].id == "paired-master-crafted-power-weapons", "The public setup choice restores the default paired power weapons")

	var ragnar := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and Abilities.identity(state.units[model]) == "ragnar-blackmane": ragnar = model
	var attach_choice := find_choice(state, 1, "attach", ragnar, friendly[0], "")
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice, Vector2.ZERO)
	check(ragnar >= 0 and not attach_choice.is_empty() and str(attach_result.get("error", "")).is_empty() and bool(state.squads[friendly[0]].get("attached", false)), "A source-listed Space Wolves Leader can attach before the split")
	var split_choice := find_choice(state, 1, "wolf-guard-headtakers-split", -1, friendly[0], "split")
	var split_result := PublicUnitCommand.submit(state, 1, split_choice, Vector2.ZERO)
	var wolf_squad := int(state.units[hunting_wolf].squad)
	check(not split_choice.is_empty() and str(split_result.get("error", "")).is_empty() and wolf_squad != friendly[0] and models_for(state, friendly[0], "wolf-guard-headtaker").size() == 3 and models_for(state, wolf_squad, "hunting-wolf").size() == 3, "Let Loose the Wolves separates all Hunting Wolves into a new unit")
	check(int(state.units[ragnar].squad) == friendly[0] and state.squads[friendly[0]].starting_strength == 4 and state.squads[wolf_squad].starting_strength == 3 and int(state.squads[friendly[0]].training_cost) + int(state.squads[wolf_squad].training_cost) == 215, "The split retains its attached Leader, updates starting strengths and preserves the combined roster cost")
	check(Abilities.has(state, friendly[0], "headhunter-quarry") and Abilities.has(state, wolf_squad, "headhunter-quarry") and Abilities.has(state, wolf_squad, "hunting-hounds"), "Both resulting units retain their datasheet abilities")
	var ragnar_unit: Dictionary = state.units[ragnar]
	state.units[hunting_wolf].position = Vector2.ZERO
	state.units[ragnar].position = Vector2(5, 0)
	state.units[ragnar].keywords.append("SPACE WOLVES")
	check(Morale.objective_control(state, hunting_wolf) == 1, "Hunting Hounds adds +1 OC only to the Hunting Wolf near its eligible Character")
	state.units[ragnar] = ragnar_unit

	state.phase = "start_turn"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.first_player = 1
	state.unit_abilities.battle_players = []
	check(C.UnitActions.battle_actor(state) == 1, "The owner receives the first-battle-round Headhunters choice")
	var quarry_target := enemy[0]
	var unmarked := squads_for(state, 2, "intercessor-squad")[0]
	var quarry_choice := find_choice(state, 1, "headhunter-quarry", headtaker, quarry_target, "initial")
	var quarry_result := PublicUnitCommand.submit(state, 1, quarry_choice, Vector2.ZERO)
	check(not quarry_choice.is_empty() and str(quarry_result.get("error", "")).is_empty() and Abilities.headhunter_quarry(state, friendly[0]) == quarry_target, "The public first-round choice stores the selected enemy quarry")
	var wolf_quarry_choice := find_choice(state, 1, "headhunter-quarry", hunting_wolf, unmarked, "initial")
	var wolf_quarry_result := PublicUnitCommand.submit(state, 1, wolf_quarry_choice, Vector2.ZERO)
	check(not wolf_quarry_choice.is_empty() and str(wolf_quarry_result.get("error", "")).is_empty() and Abilities.headhunter_quarry(state, wolf_squad) == unmarked and Abilities.headhunter_quarry(state, friendly[0]) == quarry_target, "After the pre-battle split, each resulting unit receives and stores its own Headhunters quarry")
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.squads[friendly[0]].advanced = false
	for model: int in state.units:
		state.units[model].position = Vector2(-30, float(model % 4) * 3) if int(state.units[model].get("owner", -1)) == 1 else Vector2(30, float(model % 4) * 3)
		if int(state.units[model].get("squad", -1)) == quarry_target: state.units[model].position = Vector2(4, 0)
		elif int(state.units[model].get("squad", -1)) == unmarked: state.units[model].position = Vector2(10, 0)
	state.units[headtaker].position = Vector2.ZERO
	state.phase = "shooting"
	state.active = 1
	var quarry_plan := C.AttackPlan.prepare(state, friendly[0], false, [{"model": headtaker, "target": quarry_target, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], false)
	var unmarked_plan := C.AttackPlan.prepare(state, friendly[0], false, [{"model": headtaker, "target": unmarked, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], false)
	var legal_targets := C.AttackPlan.legal_targets(state, headtaker, false, "heavy-bolt-pistol", "standard")
	check(quarry_target in legal_targets and unmarked in legal_targets and quarry_plan.get("error", "").is_empty() and quarry_plan.batches[0].weapon.keywords.get("devastating-wounds", false) and quarry_plan.batches[0].weapon.keywords.get("precision", false) and unmarked_plan.get("error", "").is_empty() and not unmarked_plan.batches[0].weapon.keywords.get("devastating-wounds", false) and not unmarked_plan.batches[0].weapon.keywords.get("precision", false), "Headhunters grants both weapon traits only against its selected quarry: quarry=%s unmarked=%s legal=%s" % [str(quarry_plan), str(unmarked_plan), str(legal_targets)])
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == quarry_target: state.units[model].wounds = 0
	check(Abilities.open_destroyed_mark_replacements(state) and state.unit_abilities.window.get("source_ability", "") == "headhunter-quarry", "Destroying the quarry opens the replacement selection")
	var replacement := find_choice(state, 1, "headhunter-quarry", headtaker, unmarked, "replacement")
	var no_replacement_pass := find_choice(state, 1, "headhunter-quarry", headtaker, friendly[0], "pass-replacement")
	var replacement_result := PublicUnitCommand.submit(state, 1, replacement, Vector2.ZERO)
	check(not replacement.is_empty() and no_replacement_pass.is_empty() and str(replacement_result.get("error", "")).is_empty() and Abilities.headhunter_quarry(state, friendly[0]) == unmarked, "The replacement is selected from living enemy units without a pass option")

	if failures == 0: print("Wolf Guard Headtakers checks: 0 failures")
	else: push_error("Wolf Guard Headtakers checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const ID := "40kdc:11e:adeptus-astartes:watch-master"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry("watch-master"), entry("deathwatch-veterans", 5)]
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5), entry("intercessor-squad", 10)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({
		"unit_abilities": true,
		"combat_doctrines": true,
		"core_stratagems": true,
		"marine_chapters": {1: "DEATHWATCH", 2: "ULTRAMARINES"}
	}, lists())

func model_for(state: Dictionary, owner: int, identity: String, role: String = "") -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or Abilities.identity(unit) != identity: continue
		if not role.is_empty() and str(unit.get("attachment_role", "")) != role: continue
		return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or Abilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength < 0 or int(state.squads[squad].get("starting_strength", -1)) == strength: return squad
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int, target: int, value: String = "") -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if int(option.get("model", -1)) != model or int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit_choice(state: Dictionary, player: int, action: String, model: int, target: int, value: String = "") -> Dictionary:
	var selected := find_choice(state, player, action, model, target, value)
	if selected.is_empty(): return {"error": "Missing projected Watch Master choice %s/%s." % [action, value]}
	return PublicUnitCommand.submit(state, player, selected)

func attack_context(state: Dictionary, squad: int, model: int, target: int, weapon: String) -> Dictionary:
	var plan := AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": "standard"}], false)
	if not str(plan.get("error", "")).is_empty(): return {"error": str(plan.error)}
	return plan.get("batches", [{}])[0].get("context", {})

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("watch-master")
	check(profile.get("source_book_id", "") == "000000035" and profile.get("source_datasheet_id", "") == "000003871" and profile.get("source_export_updated_at", "") == "2026-10-28T23:48:19+03:00", "Watch Master identity is pinned to the refreshed Deathwatch 11e export")
	check(profile.get("points_by_models", {}) == {1: 105} and profile.get("models", -1) == 1 and profile.get("base_size_source_mm", -1) == 32, "Watch Master retains its one-model 105-point composition and 32 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Watch Master characteristics match the current export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CAPTAIN", "CHARACTER", "DEATHWATCH", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "KILL TEAM"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All source-listed Watch Master keywords are retained")
	var ranged: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.ranged[0].get("physical_weapon_id", "") == "vigil-spear" and profile.melee[0].get("physical_weapon_id", "") == "vigil-spear", "The ranged and melee Vigil Spear profiles refer to one physical weapon")
	check(ranged.get("range_inches") == 24.0 and ranged.get("attacks") == 2 and ranged.get("skill") == 2 and ranged.get("strength") == 5 and ranged.get("ap") == -1 and ranged.get("damage") == 2, "Vigil Spear ranged profile matches the 11e export")
	check(melee.get("attacks") == 6 and melee.get("skill") == 2 and melee.get("strength") == 6 and melee.get("ap") == -2 and melee.get("damage") == 2 and melee.get("keywords", {}) == {"lance": true}, "Vigil Spear melee profile retains Lance and source characteristics")
	check(Army.SPECS.has("watch-master") and Army.SPECS["watch-master"].get("current_reference", false), "Watch Master is registered in current-reference admission")
	check(AbilityCatalog.RULES.get("watch-master", []) == ["leader", "combat-doctrines", "transhuman-strategist", "strategic-knowledge", "watch-master", "purgatus-quarry"], "All core, army and datasheet abilities are registered")
	check(CapabilityRegistry.supported("strategic-knowledge") and CapabilityRegistry.supported("watch-master") and CapabilityRegistry.supported("purgatus-quarry"), "All three Watch Master datasheet abilities are exposed as supported capabilities")
	check(LeaderLinks.targets("watch-master").size() == 3 and "deathwatch-veterans" in LeaderLinks.targets("watch-master") and "fortis-kill-team" in LeaderLinks.targets("watch-master") and "decimus-kill-team" in LeaderLinks.targets("watch-master"), "Watch Master retains all three source-listed Deathwatch Leader targets")
	var three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ID, "models": 1, "copies": 3}]})
	var four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ID, "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 315 and not str(four.get("error", "")).is_empty(), "Construction exposes the source price and applies the local three-copy ceiling")

	var state := fresh_state()
	check(not state.has("error"), "Both test armies materialize through the consolidated current catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var watch_master := model_for(state, 1, "watch-master")
		var bodyguard_model := model_for(state, 1, "deathwatch-veterans")
		var watch_squad := int(state.units.get(watch_master, {}).get("squad", -1))
		var bodyguard_squad := squad_for(state, 1, "deathwatch-veterans", 5)
		var captain_squad := squad_for(state, 2, "captain")
		var hunted_squad := squad_for(state, 2, "intercessor-squad", 5)
		var other_squad := squad_for(state, 2, "intercessor-squad", 10)
		check(watch_master >= 0 and bodyguard_model >= 0 and watch_squad != bodyguard_squad and captain_squad >= 0 and hunted_squad >= 0 and other_squad >= 0, "The fixture contains the Watch Master, a valid Deathwatch bodyguard, a Character and two non-Character targets")
		if watch_master >= 0 and bodyguard_squad >= 0:
			state.phase = "deployment"
			state.active = 1
			state.first_player = 1
			state.unit_abilities.setup_players = []
			var attached := submit_choice(state, 1, "attach", watch_master, bodyguard_squad)
			watch_squad = int(state.units[watch_master].squad)
			check(str(attached.get("error", "")).is_empty() and watch_squad == bodyguard_squad and state.squads[watch_squad].get("attached", false), "The Watch Master attaches through the public preparation choice to Deathwatch Veterans")
			bodyguard_model = model_for(state, 1, "deathwatch-veterans", "bodyguard")
			check(bodyguard_model >= 0 and str(state.units[watch_master].get("attachment_role", "")) == "leader", "The attached Character and bodyguard retain distinct model roles")

			state.phase = "start_turn"
			state.turn = 1
			state.round = 1
			state.active = 1
			state.first_player = 1
			state.unit_abilities.battle_players = []
			check(UnitActions.battle_actor(state) == 1, "Purgatus Quarry is offered to its owner at the start of battle round 1")
			var initial := find_choice(state, 1, "purgatus-quarry", watch_master, hunted_squad, "initial")
			var initial_pass := find_choice(state, 1, "purgatus-quarry", watch_master, watch_squad, "pass-initial")
			check(not initial.is_empty() and not initial_pass.is_empty(), "The initial menu offers living enemy units and an explicit optional pass")
			var pass_state: Dictionary = state.duplicate(true)
			var pass_result := submit_choice(pass_state, 1, "purgatus-quarry", watch_master, watch_squad, "pass-initial")
			check(str(pass_result.get("error", "")).is_empty() and Abilities.purgatus_initial_resolved(pass_state, watch_squad) and Abilities.purgatus_quarry(pass_state, watch_squad) == -1, "Passing resolves the optional first-battle-round quarry without creating a delayed mark")
			var selected := PublicUnitCommand.submit(state, 1, initial)
			check(str(selected.get("error", "")).is_empty() and Abilities.purgatus_quarry(state, watch_squad) == hunted_squad and Abilities.purgatus_initial_resolved(state, watch_squad), "The public first-battle-round choice stores one hunted enemy squad")

			for model: int in state.units:
				if int(state.units[model].get("squad", -1)) == watch_squad: state.units[model].position = Vector2.ZERO
				elif int(state.units[model].get("squad", -1)) == hunted_squad: state.units[model].position = Vector2(8, 0)
				elif int(state.units[model].get("squad", -1)) == other_squad: state.units[model].position = Vector2(10, 0)
				elif int(state.units[model].get("squad", -1)) == captain_squad: state.units[model].position = Vector2(12, 0)
			var gun := Equipment.select(state, watch_master, false, "vigil-spear", "standard")
			var bodyguard_gun := Equipment.select(state, bodyguard_model, false, "boltgun", "standard")
			state.phase = "shooting"
			state.active = 1
			var master_assault_weapon := Abilities.weapon(state, watch_master, captain_squad, gun.stats, false)
			var bodyguard_assault_weapon := Abilities.weapon(state, bodyguard_model, captain_squad, bodyguard_gun.stats, false)
			check(master_assault_weapon.get("keywords", {}).get("assault", false), "Strategic Knowledge adds Assault to the Watch Master's ranged attacks")
			check(bodyguard_assault_weapon.get("keywords", {}).get("assault", false), "Strategic Knowledge also adds Assault to the attached bodyguard's ranged attacks")
			state.squads[watch_squad].advanced = true
			check(captain_squad in AttackPlan.legal_targets(state, watch_master, false, "vigil-spear", "standard") and captain_squad in AttackPlan.legal_targets(state, bodyguard_model, false, "boltgun", "standard"), "Strategic Knowledge Assault weapons remain eligible targets after an Advance")
			state.squads[watch_squad].advanced = false
			var master_weapon_plan: Dictionary = AttackPlan.prepare(state, watch_squad, false, [{"model": watch_master, "target": captain_squad, "amount": 1, "weapon": "vigil-spear", "profile": "standard"}], false)
			var bodyguard_weapon_plan: Dictionary = AttackPlan.prepare(state, watch_squad, false, [{"model": bodyguard_model, "target": captain_squad, "amount": 1, "weapon": "boltgun", "profile": "standard"}], false)
			check(str(gun.get("error", "")).is_empty() and master_weapon_plan.get("error", "").is_empty() and bodyguard_gun.get("error", "").is_empty() and bodyguard_weapon_plan.get("error", "").is_empty(), "Strategic Knowledge weapons prepare valid ranged attack plans")
			var character_context := attack_context(state, watch_squad, watch_master, captain_squad, "vigil-spear")
			var bodyguard_character_context := attack_context(state, watch_squad, bodyguard_model, captain_squad, "boltgun")
			var quarry_context := attack_context(state, watch_squad, watch_master, hunted_squad, "vigil-spear")
			var unmarked_context := attack_context(state, watch_squad, watch_master, other_squad, "vigil-spear")
			check(character_context.get("hit_reroll", "none") == "ones" and character_context.get("wound_reroll", "none") == "ones", "Only Watch Master attacks re-roll Hit and Wound rolls of 1 against a CHARACTER target")
			check(bodyguard_character_context.get("wound_reroll", "none") == "none", "The model-specific Watch Master re-roll does not leak to its attached bodyguard")
			check(quarry_context.get("wound_reroll", "none") == "ones" and unmarked_context.get("wound_reroll", "none") == "none", "Purgatus Quarry grants Wound re-rolls only against the selected hunted unit")
			state.squads[watch_squad].advanced = true
			check(Doctrines.charge_error(state, watch_squad).is_empty(), "Strategic Knowledge preserves Charge eligibility after an Advance")
			state.squads[watch_squad].advanced = false
			state.squads[watch_squad].fell_back = true
			check(Doctrines.shoot_after_fallback(state, watch_squad) and Doctrines.charge_error(state, watch_squad).is_empty(), "Strategic Knowledge preserves shooting and Charge eligibility after Fall Back")

			for model: int in state.units:
				if int(state.units[model].get("squad", -1)) == hunted_squad: state.units[model].wounds = 0
			check(Abilities.open_destroyed_mark_replacements(state), "Destroying the hunted unit opens the Purgatus Quarry replacement window")
			check(state.unit_abilities.window.get("kind", "") == "forward-assault-mark" and state.unit_abilities.window.get("source_ability", "") == "purgatus-quarry", "The shared mark continuation identifies Purgatus Quarry as the source")
			var replacement := find_choice(state, 1, "purgatus-quarry", watch_master, captain_squad, "replacement")
			var replacement_pass := find_choice(state, 1, "purgatus-quarry", watch_master, watch_squad, "pass-replacement")
			check(not replacement.is_empty() and not replacement_pass.is_empty(), "The destroyed-quarry decision offers a living replacement and an explicit pass")
			var pass_replacement_state: Dictionary = state.duplicate(true)
			var passed_replacement := submit_choice(pass_replacement_state, 1, "purgatus-quarry", watch_master, watch_squad, "pass-replacement")
			check(str(passed_replacement.get("error", "")).is_empty() and Abilities.purgatus_quarry(pass_replacement_state, watch_squad) == -1 and pass_replacement_state.unit_abilities.window.is_empty(), "Passing on replacement clears the destroyed quarry and closes its decision")
			var replacement_result := PublicUnitCommand.submit(state, 1, replacement)
			check(str(replacement_result.get("error", "")).is_empty() and Abilities.purgatus_quarry(state, watch_squad) == captain_squad and state.unit_abilities.window.is_empty(), "The public replacement choice selects a new hunted unit")
	if failures == 0: print("Watch Master checks: 0 failures")
	else: push_error("Watch Master checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, action_id: String, value: String = "", target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == action_id and (value.is_empty() or option.value == value) and (target < 0 or option.target == target): return option
	return {}

func submit_choice(state: Dictionary, player: int, choice: Dictionary) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty(): return {"error": "Cerebrex preparation decision is not open."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(choice.get("action", "")) and int(option.get("model", -1)) == int(choice.get("model", -1)) and int(option.get("target", -1)) == int(choice.get("target", -1)) and str(option.get("value", "")) == str(choice.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Cerebrex target is not in the current preparation decision."}
	var envelope := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": envelope, "revision": int(state.revision)})

func submit_immediate_choice(state: Dictionary, player: int, choice: Dictionary) -> Dictionary:
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": choice, "revision": int(state.revision)})

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("caanok-var")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004166" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Caanok profile identifies the local shared-book e11 export")
	check(profile.points == 100 and profile.base_size_source_mm == 50 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Caanok characteristics, cost and 50 mm base match the extracted records")
	check(profile.ranged[0].profiles.standard.keywords == {"rapid-fire": 2} and profile.melee[0].profiles.standard.keywords == {"cleave": 1}, "Storm Bolter and Axiom retain their local weapon traits")
	var lists := F.selections()
	lists[1].entries = [entry("captain"), entry("terminator-squad", 5), entry("terminator-assault-squad", 5), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Caanok test materializes the local Marine fixture")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "captain")
	var squad: int = int(state.units[model].squad)
	state.units[model].definition_id = "40kdc:11e:adeptus-astartes:caanok-var"
	state.units[model].keywords = profile.keywords.duplicate()
	state.units[model].ranged_weapons = profile.ranged.duplicate(true)
	state.units[model].melee_weapons = profile.melee.duplicate(true)
	state.units[model].invulnerable_target = 4
	C.UnitAbilities.enable(state)
	state.awakened_dynasty.pending = []
	var term := find_squad(state, 1, "terminator-squad")
	var assault_term := find_squad(state, 1, "terminator-assault-squad")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	check(C.UnitAbilities.has(state, squad, "cold-and-calculating") and C.UnitAbilities.has(state, squad, "cerebrex-logic-engine") and C.UnitAbilities.has(state, squad, "feel-no-pain-5"), "Caanok's named abilities and core protections register")
	check(Prevention.rules(state, model).any(func(rule: Dictionary) -> bool: return rule.get("target", 0) == 5 and rule.get("against", "") == "any"), "Caanok has Feel No Pain 5+")
	check(C.UnitActions.attachment_allowed(state, model, term) and C.UnitActions.attachment_allowed(state, model, assault_term), "Caanok can lead both source-listed Terminator bodyguards")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var scout_choice := action(state, "cerebrex-scout", "", intercessors)
	check(not scout_choice.is_empty(), "Cerebrex offers an eligible friendly Adeptus Astartes Infantry target during army preparation")
	if not scout_choice.is_empty():
		var before_wrong_scout_owner := var_to_bytes(state)
		var wrong_scout_owner := submit_choice(state, 2, scout_choice)
		check(not str(wrong_scout_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_scout_owner, "The opponent cannot submit or mutate Caanok's Cerebrex preparation decision")
		var scout_result := submit_choice(state, 1, scout_choice)
		check(str(scout_result.get("error", "")).is_empty(), "Cerebrex records its Scout target through the public command")
	check(C.UnitAbilities.scout_distance(state, intercessors) == 6 and C.UnitAbilities.scout_distance(state, term) == 0, "Cerebrex grants Scouts 6 only to the selected unit")
	state.phase = "shooting"
	state.active = 1
	var enemy := find_squad(state, 2, "immortals")
	var enemy_model := Geometry.alive(state, enemy)[0]
	var cold := action(state, "cold-select", "lethal", squad)
	check(not cold.is_empty(), "Cold and Calculating offers a shooting attack choice")
	if not cold.is_empty():
		var before_wrong_cold_owner := var_to_bytes(state)
		var wrong_cold_owner := submit_immediate_choice(state, 2, cold)
		check(not str(wrong_cold_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_cold_owner, "The opponent cannot submit or mutate Caanok's immediate Cold and Calculating selection")
		var cold_result := submit_immediate_choice(state, 1, cold)
		check(str(cold_result.get("error", "")).is_empty(), "Cold and Calculating records Lethal Hits through the public command")
	state.units[enemy_model].keywords.append("VEHICLE")
	var monster_weapon := C.UnitAbilities.weapon(state, model, enemy, profile.ranged[0].profiles.standard, false)
	check(monster_weapon.keywords.get("lethal-hits", false), "Cold and Calculating gives Lethal Hits against Vehicle targets")
	state.units[enemy_model].keywords.erase("VEHICLE")
	var ordinary_weapon := C.UnitAbilities.weapon(state, model, enemy, profile.ranged[0].profiles.standard, false)
	check(not ordinary_weapon.keywords.get("lethal-hits", false), "The chosen Lethal Hits mode is restricted to Monster/Vehicle targets")
	state.phase = "fight"
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.squads[squad].fought = false
	state.units[model].position = Vector2.ZERO
	state.units[enemy_model].position = Vector2(0.8, 0)
	state.unit_abilities.used.erase("cold:%d:fight" % squad)
	var sustained := action(state, "cold-select", "sustained", squad)
	check(not sustained.is_empty(), "Cold and Calculating offers a separate Fight-phase choice")
	if not sustained.is_empty():
		var sustained_result := submit_immediate_choice(state, 1, sustained)
		check(str(sustained_result.get("error", "")).is_empty(), "Cold and Calculating records Sustained Hits through the public command")
	check(C.UnitAbilities.weapon(state, model, enemy, profile.melee[0].profiles.standard, true).keywords.get("sustained-hits", 0) == 1, "Cold and Calculating grants Sustained Hits 1 against non-Monsters/Vehicles")
	state.combat_doctrines.active[1] = "tactical"
	state.units[enemy_model].keywords.append("VEHICLE")
	var tac_vehicle := C.UnitAbilities.weapon(state, model, enemy, profile.melee[0].profiles.standard, true)
	check(tac_vehicle.keywords.get("lethal-hits", false), "Tactical Doctrine grants the conditional Lethal Hits trait")
	state.units[enemy_model].keywords.erase("VEHICLE")
	check(C.UnitAbilities.weapon(state, model, enemy, profile.melee[0].profiles.standard, true).keywords.get("sustained-hits", 0) == 1, "Tactical Doctrine grants the conditional Sustained Hits trait")
	state.phase = "deployment"
	state.unit_abilities.setup_players = [2]
	var warlord_available := false
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == "warlord" and option.model == model: warlord_available = true
	check(warlord_available, "Caanok is eligible to be selected as Warlord")
	state.round = 1
	state.unit_abilities.warlords = {1: model}
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP when Caanok is Warlord")
	print("Caanok Var local checks: %d failures" % failures)
	quit(1 if failures else 0)

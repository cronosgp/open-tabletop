extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
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
	check(profile.points == 100 and profile.points_by_models == {1: 100} and profile.max_supported_copies == 1 and profile.models == 1 and profile.base_size_source_mm == 50 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Caanok composition, copy cap, characteristics, cost and 50 mm base match the extracted records")
	check(profile.keywords == ["INFANTRY", "TERMINATOR", "IMPERIUM", "EPIC HERO", "CHARACTER", "CAPTAIN", "ADEPTUS ASTARTES", "IRON HANDS"] and profile.ranged.size() == 1 and profile.melee.size() == 1 and profile.get("additional_weapon_profiles", {}).is_empty(), "Caanok has all source keywords, fixed default weapons and no alternate profiles")
	check(profile.ranged[0].profiles.standard.keywords == {"rapid-fire": 2} and profile.melee[0].profiles.standard.keywords == {"cleave": 1}, "Storm Bolter and Axiom retain their local weapon traits")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:caanok-var", "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0].get("models", 0) == 1 and catalog_choice.options[0].get("cost", 0) == 100, "The consolidated construction catalog exposes Caanok's one-model source cost")
	check(Catalog.resolve("Space Marines", "40kdc:11e:adeptus-astartes:caanok-var").get("error", "").is_empty(), "Caanok resolves through the admitted current-reference catalog")
	var lists := F.current_marine_selections()
	lists[1].entries = [entry("caanok-var"), entry("terminator-squad", 5), entry("terminator-assault-squad", 5), entry("intercessor-squad", 5)]
	lists[2].entries = [entry("caanok-var"), entry("redemptor-dreadnought"), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Caanok and current-catalog Marine units materialize for both players")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "caanok-var")
	check(model > 0 and find_model(state, 2, "caanok-var") > 0, "Both players' Caanok models materialize from the current catalog")
	if model < 0:
		quit(1)
		return
	var squad: int = int(state.units[model].squad)
	C.UnitAbilities.enable(state)
	state.awakened_dynasty.pending = []
	var term := find_squad(state, 1, "terminator-squad")
	var assault_term := find_squad(state, 1, "terminator-assault-squad")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	check(C.UnitAbilities.has(state, squad, "cold-and-calculating") and C.UnitAbilities.has(state, squad, "cerebrex-logic-engine") and C.UnitAbilities.has(state, squad, "feel-no-pain-5") and C.UnitAbilities.has(state, squad, "deep-strike") and C.UnitAbilities.has(state, squad, "leader") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "transhuman-strategist"), "Caanok's Core, Army and datasheet abilities register")
	check(Prevention.rules(state, model).any(func(rule: Dictionary) -> bool: return rule.get("target", 0) == 5 and rule.get("against", "") == "any"), "Caanok has Feel No Pain 5+")
	check(C.UnitActions.attachment_allowed(state, model, term) and C.UnitActions.attachment_allowed(state, model, assault_term), "Caanok can lead both source-listed Terminator bodyguards")
	check(not C.UnitActions.attachment_allowed(state, model, intercessors), "Caanok cannot lead a non-listed Intercessor unit")
	var enemy_vehicle := find_squad(state, 2, "redemptor-dreadnought")
	var enemy_infantry := find_squad(state, 2, "intercessor-squad")
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, model, enemy_infantry):
		check(false, "Caanok source weapon plan: " + failure)
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
	var enemy_vehicle_model := Geometry.alive(state, enemy_vehicle)[0]
	var cold := action(state, "cold-select", "lethal", squad)
	check(not cold.is_empty(), "Cold and Calculating offers a shooting attack choice")
	if not cold.is_empty():
		var before_wrong_cold_owner := var_to_bytes(state)
		var wrong_cold_owner := submit_immediate_choice(state, 2, cold)
		check(not str(wrong_cold_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_cold_owner, "The opponent cannot submit or mutate Caanok's immediate Cold and Calculating selection")
		var cold_result := submit_immediate_choice(state, 1, cold)
		check(str(cold_result.get("error", "")).is_empty(), "Cold and Calculating records Lethal Hits through the public command")
	var monster_weapon := C.UnitAbilities.weapon(state, model, enemy_vehicle, profile.ranged[0].profiles.standard, false)
	check(monster_weapon.keywords.get("lethal-hits", false), "Cold and Calculating gives Lethal Hits against Vehicle targets")
	var ordinary_weapon := C.UnitAbilities.weapon(state, model, enemy_infantry, profile.ranged[0].profiles.standard, false)
	check(not ordinary_weapon.keywords.get("lethal-hits", false), "The chosen Lethal Hits mode is restricted to Monster/Vehicle targets")
	state.phase = "fight"
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.squads[squad].fought = false
	state.units[model].position = Vector2.ZERO
	var enemy_infantry_model := Geometry.alive(state, enemy_infantry)[0]
	state.units[enemy_infantry_model].position = Vector2(0.8, 0)
	state.units[enemy_vehicle_model].position = Vector2(1.0, 0)
	state.unit_abilities.used.erase("cold:%d:fight" % squad)
	var sustained := action(state, "cold-select", "sustained", squad)
	check(not sustained.is_empty(), "Cold and Calculating offers a separate Fight-phase choice")
	if not sustained.is_empty():
		var sustained_result := submit_immediate_choice(state, 1, sustained)
		check(str(sustained_result.get("error", "")).is_empty(), "Cold and Calculating records Sustained Hits through the public command")
	check(C.UnitAbilities.weapon(state, model, enemy_infantry, profile.melee[0].profiles.standard, true).keywords.get("sustained-hits", 0) == 1, "Cold and Calculating grants Sustained Hits 1 against non-Monsters/Vehicles")
	state.combat_doctrines.active[1] = "tactical"
	var tac_vehicle := C.UnitAbilities.weapon(state, model, enemy_vehicle, profile.melee[0].profiles.standard, true)
	check(tac_vehicle.keywords.get("lethal-hits", false), "Tactical Doctrine grants the conditional Lethal Hits trait")
	check(C.UnitAbilities.weapon(state, model, enemy_infantry, profile.melee[0].profiles.standard, true).keywords.get("sustained-hits", 0) == 1, "Tactical Doctrine grants the conditional Sustained Hits trait")
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

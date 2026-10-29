extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
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
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, action_id: String, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == action_id and (model < 0 or int(option.get("model", -1)) == model): return option
	return {}

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("iron-father-feirros")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000127" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Feirros profile uses the local shared-book Wahapedia export")
	check(profile.points == 85 and profile.points_by_models == {1: 85} and profile.max_supported_copies == 1 and profile.models == 1 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and profile.base_size_source_mm == 40, "Feirros points, copy cap, characteristics and base match the extracted model")
	check(profile.keywords == ["INFANTRY", "GRAVIS", "CHARACTER", "EPIC HERO", "IMPERIUM", "ADEPTUS ASTARTES", "IRON HANDS"], "Feirros retains the exact source-exported keywords")
	check(profile.ranged.size() == 2 and profile.melee.size() == 2 and profile.get("additional_weapon_profiles", {}).is_empty(), "Feirros has two fixed ranged weapons, two fixed melee weapons and no selectable equipment replacements")
	check(profile.ranged[0].profiles.standard.keywords == {"close-quarters": true} and profile.ranged[1].profiles.standard.keywords == {"rapid-fire": 2, "sustained-hits": 2} and profile.melee[1].profiles.standard.keywords == {"extra-attacks": true}, "Bolt Pistol, Gorgon's Wrath and Medusan Manipuli preserve source weapon traits")
	check(Catalog.SPECS.get("iron-father-feirros", {}).get("current_reference", false) and Roster.POINTS.get("iron-father-feirros", {}).get("sizes", {}) == {1: 85}, "Feirros is configured for one 85-point model")
	var identity := "40kdc:11e:adeptus-astartes:iron-father-feirros"
	var catalog_choice := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0].get("models", 0) == 1 and catalog_choice.options[0].get("cost", 0) == 85, "The consolidated catalog publishes Feirros's one-model source cost")
	check(Catalog.resolve("Space Marines", identity).get("error", "").is_empty(), "Feirros resolves through the admitted current-reference catalog")
	var lists := F.current_marine_selections()
	lists[1].entries = [entry("iron-father-feirros"), entry("aggressor-squad", 3), entry("heavy-intercessor-squad", 5), entry("eradicator-squad-with-heavy-bolters", 3), entry("eradicator-squad-with-melta-rifles", 3), entry("redemptor-dreadnought")]
	lists[2].entries = [entry("assault-intercessor-squad", 5), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Feirros and both players' current Marine rosters materialize from the consolidated catalog")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var feirros := find_model(state, 1, "iron-father-feirros")
	var feirros_squad: int = int(state.units[feirros].squad)
	C.UnitAbilities.enable(state)
	var aggressors := find_squad(state, 1, "aggressor-squad")
	var heavy_intercessors := find_squad(state, 1, "heavy-intercessor-squad")
	var heavy_bolter_eradicators := find_squad(state, 1, "eradicator-squad-with-heavy-bolters")
	var melta_eradicators := find_squad(state, 1, "eradicator-squad-with-melta-rifles")
	var vehicle := find_model(state, 1, "redemptor-dreadnought")
	var enemy_intercessors := find_squad(state, 2, "intercessor-squad")
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, feirros, enemy_intercessors):
		check(false, "Feirros source weapon plan: " + failure)
	check(C.UnitAbilities.has(state, feirros_squad, "feel-no-pain-5") and C.UnitAbilities.has(state, feirros_squad, "master-of-the-forge") and C.UnitAbilities.has(state, feirros_squad, "rites-of-tempering") and C.UnitAbilities.has(state, feirros_squad, "iron-father"), "Feirros abilities register on his unit")
	check(Prevention.rules(state, feirros).any(func(rule: Dictionary) -> bool: return rule.get("target", 0) == 5 and rule.get("against", "") == "any"), "Feirros receives his personal Feel No Pain 5+")
	check(C.UnitActions.attachment_allowed(state, feirros, aggressors) and C.UnitActions.attachment_allowed(state, feirros, heavy_intercessors) and C.UnitActions.attachment_allowed(state, feirros, heavy_bolter_eradicators) and C.UnitActions.attachment_allowed(state, feirros, melta_eradicators), "Feirros can lead each of the four source-listed bodyguards")
	check(not C.UnitActions.attachment_allowed(state, feirros, find_squad(state, 1, "redemptor-dreadnought")), "Feirros cannot lead an unlisted Vehicle")
	check(C.UnitAbilities.defensive_wound_modifier(state, feirros_squad, 7, 6) == -1 and C.UnitAbilities.defensive_wound_modifier(state, feirros_squad, 6, 6) == 0, "Rites of Tempering subtracts 1 only when attacking Strength exceeds Toughness")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	var warlord_choice := action(state, "warlord", feirros)
	check(not warlord_choice.is_empty(), "Feirros is eligible to be selected as Warlord")
	if not warlord_choice.is_empty():
		var before_wrong_warlord_owner := var_to_bytes(state)
		var wrong_warlord_owner := submit_projected_choice(state, 2, warlord_choice)
		check(not str(wrong_warlord_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_warlord_owner, "The opponent cannot submit or mutate Feirros's Warlord choice")
		var warlord_result := submit_projected_choice(state, 1, warlord_choice)
		check(str(warlord_result.get("error", "")).is_empty(), "Feirros can be recorded as Warlord through the public command")
	check(int(state.unit_abilities.warlords.get(1, -1)) == feirros, "Feirros remains the recorded Warlord after declaration")
	state.cp[1] = 0
	state.round = 1
	state.first_player = 1
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants Feirros's Warlord CP")
	state.units[feirros].position = Vector2.ZERO
	state.units[vehicle].position = Vector2(2.0, 0)
	check(C.UnitAbilities.lone_operative_active(state, feirros), "Iron Father grants Lone Operative within 3 inches of a friendly Astartes Vehicle")
	state.units[vehicle].position = Vector2(7, 0)
	check(not C.UnitAbilities.lone_operative_active(state, feirros), "Iron Father loses Lone Operative outside 3 inches")
	state.units[vehicle].position = Vector2(2.0, 0)
	C.UnitActions.attach(state, feirros, aggressors)
	check(not C.UnitAbilities.lone_operative_active(state, feirros), "Lone Operative does not protect Feirros while he is part of an Attached unit")
	check(C.UnitAbilities.defensive_wound_modifier(state, aggressors, 7, 6) == -1, "Rites of Tempering protects the attached bodyguard unit")
	state.phase = "movement"
	state.active = 1
	state.squads[aggressors].moved = false
	state.units[vehicle].wounds = 7
	var move_error := C.begin_movement(state, 1, feirros, "normal", state.revision)
	check(move_error.is_empty() and state.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Master of the Forge opens at the start of Feirros's move")
	var defer := action(state, "master-forge-defer")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_defer_owner := submit_projected_choice(state, 2, defer) if not defer.is_empty() else {"error": "choice missing"}
	check(not str(wrong_defer_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "Opponent cannot defer Feirros's Master of the Forge")
	var defer_result := submit_projected_choice(state, 1, defer) if not defer.is_empty() else {"error": "choice missing"}
	check(not defer.is_empty() and str(defer_result.get("error", "")).is_empty(), "Master of the Forge can be deferred through the normalized decision until the end of the move")
	state.pending_move = {}
	state.squads[aggressors].moved = true
	state.squads[aggressors].move_type = "normal"
	C.UnitActions.end_move(state, aggressors)
	var repair := action(state, "master-of-the-forge")
	check(not repair.is_empty() and repair.target == vehicle, "Master of the Forge offers the nearby Astartes Vehicle")
	if not repair.is_empty():
		var before_wrong_repair_owner := var_to_bytes(state)
		var wrong_repair_owner := submit_projected_choice(state, 2, repair)
		check(not str(wrong_repair_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_repair_owner, "Opponent cannot resolve Feirros's repair")
		var repair_result := submit_projected_choice(state, 1, repair)
		check(str(repair_result.get("error", "")).is_empty(), "Master of the Forge repair action uses the normalized decision: " + str(repair_result.get("error", "")))
	check(state.units[vehicle].wounds == 10 and Techmarine.modifier_ignore_active(state, vehicle), "Master of the Forge heals a fixed 3 wounds and grants temporary attack-modifier protection")
	check(Techmarine.characteristic_modifier_ignore_active(state, vehicle), "Master of the Forge also ignores direct BS/WS characteristic modifiers")
	state.turn += 2
	check(not Techmarine.modifier_ignore_active(state, vehicle), "Master of the Forge protection ends at the next own Movement phase")
	print("Iron Father Feirros local checks: %d failures" % failures)
	quit(1 if failures else 0)

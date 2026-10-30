extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Stormlance = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

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
	result[1].entries = [entry("logan-grimnar"), entry("wolf-scouts", 6), entry("wolf-guard-terminators", 5)]
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return int(unit.squad)
	return -1

func living_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: result.append(model)
	return result

func find_choice(state: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, owner):
		if str(option.get("action", "")) != action: continue
		if model != -2 and int(option.get("model", -1)) != model: continue
		if target != -2 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func submit(state: Dictionary, owner: int, action: String, model: int = -2, target: int = -2, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var option := find_choice(state, owner, action, model, target)
	if option.is_empty(): return {"error": "Unavailable: " + action}
	return PublicUnitCommand.submit(state, owner, option, point)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("logan-grimnar")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000282" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "6DB0CD7F582C0A87EC57AB91C02C8A5CF88A2E5B102224F26F9F1B3C5FD12E92", "Logan is bound to the Space Wolves App and the subject-scoped verified export")
	check(profile.get("points_by_models", {}) == {1: 150} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 80, "Logan retains the one-model, 150-point Epic Hero profile, one-copy limit and 80 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Logan's characteristics match the current export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CHAPTER MASTER", "CHARACTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TERMINATOR"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All source-listed Logan keywords are retained (actual=%s expected=%s)" % [str(actual_keywords), str(expected_keywords)])
	var ranged: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {})
	var tyrnak: Dictionary = profile.get("melee", [{}, {}])[1].get("profiles", {}).get("standard", {})
	check(ranged.get("range_inches") == 24.0 and ranged.get("attacks") == 2 and ranged.get("skill") == 2 and ranged.get("strength") == 5 and ranged.get("ap") == -1 and ranged.get("damage") == 1 and ranged.get("keywords", {}) == {"rapid-fire": 2}, "Storm Bolter profile matches the export")
	check(melee.get("strike", {}).get("attacks") == 6 and melee.get("strike", {}).get("strength") == 10 and melee.get("strike", {}).get("ap") == -2 and melee.get("strike", {}).get("damage") == 3, "Axe Morkai Strike profile matches the export")
	check(melee.get("sweep", {}).get("attacks") == 10 and melee.get("sweep", {}).get("strength") == 6 and melee.get("sweep", {}).get("ap") == -2 and melee.get("sweep", {}).get("damage") == 1 and melee.get("sweep", {}).get("keywords", {}) == {"cleave": 1}, "Axe Morkai Sweep and Cleave match the export")
	check(tyrnak.get("attacks") == 6 and tyrnak.get("skill") == 2 and tyrnak.get("strength") == 5 and tyrnak.get("ap") == -1 and tyrnak.get("damage") == 1 and tyrnak.get("keywords", {}) == {"extra-attacks": true}, "Tyrnak and Fenrir retain their Extra Attacks profile")
	check(Army.SPECS.has("logan-grimnar") and Army.SPECS["logan-grimnar"].get("current_reference", false), "Logan is registered in current-reference construction admission")
	check(AbilityCatalog.RULES.get("logan-grimnar", []) == ["leader", "deep-strike", "combat-doctrines", "high-king-of-fenris", "guile-of-the-wolf"], "Core, faction and datasheet abilities are registered")
	check(Registry.supported("high-king-of-fenris") and Registry.supported("guile-of-the-wolf"), "Both Logan datasheet abilities are exposed as supported capabilities")
	var targets := LeaderLinks.targets("logan-grimnar")
	check(targets.size() == 3 and "terminator-squad" in targets and "terminator-assault-squad" in targets and "wolf-guard-terminators" in targets, "All source-listed Leader targets are connected")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("logan-grimnar")]})
	var duplicate := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("logan-grimnar", 1, 2)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 150 and not str(duplicate.get("error", "")).is_empty(), "Construction admits Logan at source cost and enforces the one-copy Epic Hero limit")

	var state := fresh_state()
	check(not state.has("error"), "Test armies materialize from the consolidated local catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var logan := model_for(state, 1, "logan-grimnar")
		var logan_squad := int(state.units.get(logan, {}).get("squad", -1))
		var scouts := squad_for(state, 1, "wolf-scouts")
		var wolf_guard := squad_for(state, 1, "wolf-guard-terminators")
		var doctrines := Doctrines.active_doctrines_for(state, logan_squad)
		check(doctrines.size() == 3 and "assault" in doctrines and "devastator" in doctrines and "tactical" in doctrines, "Guile of the Wolf activates all three doctrines for Logan's unit")
		check(AbilityCatalog.additional_doctrines(state, wolf_guard).is_empty(), "Guile of the Wolf does not grant doctrines to another Space Wolves unit")

		state.phase = "movement"
		state.active = 1
		state.round = 1
		state.turn = 1
		state.board_size = Vector2(60, 44)
		state.deployment.zones = {1: Rect2(-30, -10, 20, 20), 2: Rect2(23, -10, 7, 20)}
		state.unit_abilities.phase_key = UnitActions.key(state)
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == scouts:
				state.units[model].on_battlefield = false
			elif int(state.units[model].get("owner", -1)) == 1:
				state.units[model].position = Vector2(-15, 10)
			else:
				state.units[model].position = Vector2(20, 15)
		state.unit_abilities.reserves[scouts] = {"cost": 85, "source": "strategic-reserves", "deep_strike": false}
		state.unit_abilities.reserves[wolf_guard] = {"cost": 185, "source": "strategic-reserves", "deep_strike": true}
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == wolf_guard: state.units[model].on_battlefield = false

		var selection := find_choice(state, 1, "high-king-fenris", logan, scouts)
		check(not selection.is_empty(), "The Movement phase offers a friendly Space Wolves reserve selection (logan=%s identity=%s enabled=%s sources=%s reserve=%s keywords=%s choices=%s)" % [str(logan), C.UnitAbilities.identity(state.units.get(logan, {})), str(C.UnitAbilities.enabled(state)), str(C.UnitAbilities.sources(state, logan_squad, "high-king-of-fenris")), str(state.unit_abilities.reserves), str(C.UnitAbilities.has_target_keyword(state, scouts, "SPACE WOLVES")), str(UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "high-king-fenris"))])
		var selected := PublicUnitCommand.submit(state, 1, selection)
		check(str(selected.get("error", "")).is_empty() and C.UnitAbilities.high_king_fenris_selected(state, scouts), "High King selection is recorded through the public unit-choice command (%s)" % str(selected))
		check(find_choice(state, 1, "high-king-fenris", logan, wolf_guard).is_empty(), "Logan can select only one reserve unit per battle round")
		check(UnitActions.ingress_round_allowed(state, scouts), "High King permits a non-Deep Strike unit to ingress in battle round 1")
		var opponent_phase: Dictionary = state.duplicate(true)
		opponent_phase.active = 2
		opponent_phase.cp[1] = 1
		check(UnitActions.rapid_ingress_squads(opponent_phase, 1).has(scouts), "A selected unit remains eligible for Rapid Ingress in the opponent's Movement phase")

		var zone_state: Dictionary = state.duplicate(true)
		zone_state.round = 2
		zone_state.unit_abilities.window = {"kind": "ingress", "squad": scouts, "deep_strike": false, "positions": {}}
		var scout_model := living_models(zone_state, scouts)[0]
		var opposing_deployment_point := Vector2(25, 0)
		var selected_zone_error := UnitActions.ingress_position_error(zone_state, scout_model, opposing_deployment_point)
		var unselected_zone_state: Dictionary = zone_state.duplicate(true)
		unselected_zone_state.unit_abilities.high_king_fenris.erase(scouts)
		var unselected_zone_error := UnitActions.ingress_position_error(unselected_zone_state, scout_model, opposing_deployment_point)
		check(not selected_zone_error.contains("before battle round 3") and unselected_zone_error.contains("before battle round 3"), "A selected non-Deep Strike unit uses the treated round for the opponent deployment-zone restriction (selected=%s unselected=%s)" % [selected_zone_error, unselected_zone_error])

		for model: int in living_models(state, scouts): state.units[model].on_battlefield = false
		var arrival := submit(state, 1, "ingress", -1, scouts)
		check(str(arrival.get("error", "")).is_empty() and UnitActions.pending(state).get("kind", "") == "ingress", "High King opens a first-round ingress for its selected reserve")
		var scout_models := living_models(state, scouts)
		for index: int in range(scout_models.size()):
			var x := -26.0 if index % 2 == 0 else -24.0
			var y := -2.2 + float(floori(float(index) / 2.0)) * 2.2
			var placed := submit(state, 1, "ingress-place", scout_models[index], scouts, Vector2(x, y))
			check(str(placed.get("error", "")).is_empty(), "A selected Space Wolves reserve model can be staged within 6 inches of the battlefield edge: %s" % placed.get("error", ""))
		var confirmed := submit(state, 1, "ingress-confirm")
		check(str(confirmed.get("error", "")).is_empty() and not C.UnitAbilities.high_king_fenris_selected(state, scouts) and not state.unit_abilities.high_king_fenris.has(scouts) and not state.unit_abilities.reserves.has(scouts), "Ingress consumes the High King selection after the full unit is set up (result=%s selected=%s map=%s reserves=%s window=%s)" % [str(confirmed), str(C.UnitAbilities.high_king_fenris_selected(state, scouts)), str(state.unit_abilities.high_king_fenris), str(state.unit_abilities.reserves), str(UnitActions.pending(state))])

	print("Logan Grimnar checks: %d failures" % failures)
	quit(1 if failures else 0)

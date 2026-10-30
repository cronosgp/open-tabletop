extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const V = F.C.RosterValidation
const P = F.P
const M = F.C.Mission
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var fist := V.detachment_for("Space Marines", "fist-of-the-god-emperor")
	check(fist.get("dp", 0) == 1 and fist.get("force_dispositions", []) == ["take-and-hold"] and V.dp_error([fist]).is_empty(), "Fist's checked profile costs 1 DP and offers Take and Hold only")
	var gladius := V.detachment_for("Space Marines")
	var necrons := V.detachment_for("Necrons")
	check(gladius.get("id", "") == "gladius-task-force" and gladius.get("force_dispositions", []).size() == 2 and necrons.get("id", "") == "awakened-dynasty", "Default checked profiles preserve Gladius and Awakened Dynasty")
	var fist_report := {"construction": {"detachments": [fist]}}
	var necron_report := {"construction": {"detachments": [necrons]}}
	var reports := {1: fist_report, 2: necron_report}
	check(P.force_disposition_error(reports, {1: "take-and-hold", 2: "priority-assets"}).is_empty(), "Direct setup accepts dispositions available from both selected rosters")
	check(P.force_disposition_error(reports, {1: "priority-assets", 2: "take-and-hold"}).contains("not available"), "Direct setup rejects Priority Assets for the Fist roster")
	var state := {"phase": "deployment", "test_winner": 0, "mission": {"id": M.ID, "stage": "force-disposition-p1", "sealed_force_disposition_reveal": true, "sealed_force_disposition_choices": {}, "primary_selection_mode": "sealed-force-disposition-default-pending", "force_dispositions": {}}, "roster_validation": {"armies": {1: fist_report.construction, 2: necron_report.construction}}}
	var p1_choices: Array = M.choices(state, 1)
	var invalid_choice_error := M.apply(state, 1, {"action": "mission-force-disposition", "value": "priority-assets"}, Callable())
	check(p1_choices.size() == 1 and p1_choices[0].value == "take-and-hold", "Sealed Fist setup exposes Take and Hold only")
	check(not invalid_choice_error.is_empty() and state.mission.stage == "force-disposition-p1", "Sealed choice rejects a disposition excluded by Fist")
	check(M.apply(state, 1, {"action": "mission-force-disposition", "value": "take-and-hold"}, Callable()).is_empty() and state.mission.stage == "force-disposition-p2", "Valid Fist choice advances to Player 2")
	check(M.choices(state, 2).size() == 2, "Awakened Dynasty retains its two roster-available choices")
	var vow := V.detachment_for("Space Marines", "vow-sworn-crusaders")
	check(vow.get("dp", 0) == 2 and vow.get("force_dispositions", []) == ["purge-the-foe"] and V.dp_error([vow]).is_empty(), "Vow-sworn's checked profile records its 2 DP and sole Purge the Foe disposition")
	var vow_report := {"construction": {"detachments": [vow]}}
	check(P.force_disposition_error({1: vow_report, 2: necron_report}, {1: "purge-the-foe", 2: "priority-assets"}).is_empty(), "Direct setup accepts Purge the Foe from Vow-sworn")
	check(P.force_disposition_error({1: vow_report, 2: necron_report}, {1: "take-and-hold", 2: "priority-assets"}).contains("not available"), "Direct setup rejects dispositions absent from Vow-sworn")
	var vow_state := {"roster_validation": {"armies": {1: vow_report, 2: necron_report}}}
	check(M.available_force_dispositions(vow_state, 1) == ["purge-the-foe"] and M.default_primary_mission("purge-the-foe", "priority-assets").is_empty(), "Vow-sworn exposes Purge directly and does not invent an unsupported matchup default")
	var direct_setup := P.initial_state({"official_mission": true, "checked_rosters": true, "unit_abilities": true, "combat_doctrines": true,
		"reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "terrain_layout": M.DEFAULT_TERRAIN_LAYOUT,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: "gladius"}, "marine_chapters": {1: "BLACK TEMPLARS"},
		"primary_missions": {1: "secure-asset", 2: "battlefield-dominance"}, "primary_overrides": {1: true, 2: true},
		"force_dispositions": {1: "purge-the-foe", 2: "priority-assets"}}, V.defaults())
	check(not direct_setup.has("error"), "Checked CA setup accepts Vow-sworn with its direct Force Disposition and direct primary selections: %s" % str(direct_setup.get("error", "")))
	if not direct_setup.has("error"):
		check(direct_setup.mission.force_dispositions == {1: "purge-the-foe", 2: "priority-assets"} and direct_setup.mission.primary_ids == {1: "secure-asset", 2: "battlefield-dominance"}, "Vow-sworn disposition and direct primary selections reach the mission state")
	var sealed_setup_options := {"official_mission": true, "checked_rosters": true, "unit_abilities": true, "combat_doctrines": true,
		"reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: "gladius"}, "marine_chapters": {1: "BLACK TEMPLARS"},
		"primary_overrides": {1: false, 2: false}, "sealed_force_disposition_reveal": true}
	var sealed_vow_setup := P.initial_state(sealed_setup_options, V.defaults())
	check(str(sealed_vow_setup.get("error", "")).contains("no supported primary-card defaults"), "Sealed defaults reject Vow-sworn until Purge the Foe matchup mappings are supported")
	print("Force Disposition checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

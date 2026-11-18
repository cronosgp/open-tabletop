extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MainScene = preload("res://scenes/main.tscn")
var failures := 0
var mission_rolls: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func next_mission_roll() -> int:
	return mission_rolls.pop_front() if not mission_rolls.is_empty() else 6

func resolve_mission_action(state: Dictionary, player: int, action: String, target: int = -2) -> String:
	var selected: Dictionary = {}
	for option: Dictionary in Combat.Mission.choices(state, player):
		if str(option.get("action", "")) == action and (target == -2 or int(option.get("target", -1)) == target):
			selected = option
			break
	if selected.is_empty(): return "Unavailable mission action: " + action
	return Combat.unit_action(state, player, selected, Vector2.ZERO, int(state.get("revision", -1)), Callable(self, "next_mission_roll"))

func run() -> void:
	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.army_builder.store.path = "res://.tools/readiness-ui-profiles.json"
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Current local catalog opens")
	var army := Roster.new_list("11e", "Space Marines", "incursion", 1000)
	army.entries.append(Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:captain"), 0, 1))
	army.entries.append(Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:chaplain"), 0, 1))
	var saved: Dictionary = game.army_builder.store.save_list(army)
	check(str(saved.get("error", "")).is_empty(), "Army without saved Warlord remains editable")
	if failures > 0:
		game.free()
		catalog.free()
		quit(1)
		return
	game._refresh_army_choices()
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if str(picker.get_item_metadata(index).get("id", "")) == str(saved.list.id): picker.select(index)
	game._start_quick_match()
	check(game.saved_army_mode, "Quick Match opens the current saved army")
	check(game.setup_finish_button.disabled and game.setup_decisions_heading.text == "Choose a required declaration",
		"Missing Warlord remains required and cannot be bypassed by finish")
	var warlord: Dictionary = {}
	for option: Dictionary in game.setup_decision_choices:
		if str(option.get("action", "")) == "warlord":
			warlord = option
			break
	check(not warlord.is_empty(), "A required Warlord choice remains available")
	if not warlord.is_empty():
		game._apply_unit_action(1, game._unit_choice_payload(warlord), Vector2.ZERO, int(game.state.revision))
	var before: Dictionary = game.state.duplicate(true)
	game._refresh_unit_actions()
	check(game.state == before, "Refreshing readiness never mutates authoritative state")
	check(not game.setup_finish_button.disabled and game.setup_decisions_heading.text == "Optional declaration changes",
		"After Warlord validation the remaining alternatives are explicitly optional")
	check(game.unit_action_button.text == "Apply optional change", "The secondary action is labelled optional")
	for option: Dictionary in game.setup_decision_choices:
		check(str(option.get("action", "")) != "warlord" or int(option.get("model", -1)) != int(warlord.get("model", -2)),
			"The applied Warlord is not offered again as a declaration")
	check(game.setup_finish_button.get_parent() == game.setup_saved_loadouts_status.get_parent()
		and game.setup_finish_button.get_index() < game.setup_saved_loadouts_status.get_index(),
		"Finish precedes the potentially long saved-equipment summary")
	var mission_marines := Roster.new_list("11e", "Space Marines", "incursion", 1000)
	mission_marines.entries.append(Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:captain"), 0, 1))
	mission_marines.entries.append(Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:intercessor-squad"), 0, 1))
	mission_marines.entries.append(Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:impulsor"), 0, 1))
	mission_marines.leader_assignments = [{"leader_model_id": Roster.model_instance_id(mission_marines.entries[0], 0, 0), "target_copy_id": str(mission_marines.entries[1].copy_instance_ids[0])}]
	var mission_necrons := Roster.new_list("11e", "Necrons", "incursion", 1000)
	mission_necrons.entries.append(Roster.entry(catalog.lookup("40kdc:11e:necrons:royal-warden"), 0, 1))
	mission_necrons.entries.append(Roster.entry(catalog.lookup("40kdc:11e:necrons:necron-warriors"), 0, 1))
	mission_necrons.entries.append(Roster.entry(catalog.lookup("40kdc:11e:necrons:canoptek-doomstalker"), 0, 1))
	mission_necrons.leader_assignments = [{"leader_model_id": Roster.model_instance_id(mission_necrons.entries[0], 0, 0), "target_copy_id": str(mission_necrons.entries[1].copy_instance_ids[0])}]
	var mission_game = MainScene.instantiate()
	root.add_child(mission_game)
	mission_game.auto_models.button_pressed = false
	mission_game.army_builder.store.path = "res://.tools/readiness-mission-profiles.json"
	mission_marines.warlord_model_id = Roster.model_instance_id(mission_marines.entries[0], 0, 0)
	mission_necrons.warlord_model_id = Roster.model_instance_id(mission_necrons.entries[0], 0, 0)
	var saved_mission_marines: Dictionary = mission_game.army_builder.store.save_list(mission_marines)
	var saved_mission_necrons: Dictionary = mission_game.army_builder.store.save_list(mission_necrons)
	mission_game._refresh_army_choices()
	for owner in [1, 2]:
		var picker: OptionButton = mission_game.saved_army_pickers[owner]
		var wanted_id := str(saved_mission_marines.get("list", {}).get("id", "")) if owner == 1 else str(saved_mission_necrons.get("list", {}).get("id", ""))
		for index in range(picker.item_count):
			if str(picker.get_item_metadata(index).get("id", "")) == wanted_id: picker.select(index)
	var mission_report_p1: Dictionary = mission_game._saved_army_report(1)
	var mission_report_p2: Dictionary = mission_game._saved_army_report(2)
	var formation: Dictionary = mission_game._selected_army_declarations()
	var ca_options := Prepared.quick_match_options()
	ca_options.official_mission = true
	ca_options.terrain_layout = Combat.Mission.DEFAULT_TERRAIN_LAYOUT
	ca_options.unit_abilities = true
	ca_options.combat_doctrines = true
	ca_options.marine_detachment = "gladius"
	ca_options.marine_detachments = {1: "gladius", 2: "gladius"}
	ca_options.awakened_dynasty = true
	ca_options.reanimation_protocols = true
	ca_options.core_stratagems = true
	ca_options.army_declarations = formation.get("declarations", {})
	var mission_state: Dictionary = Prepared.initial_state(ca_options, {1: mission_report_p1.get("selection", {}), 2: mission_report_p2.get("selection", {})})
	var mission_decision: Dictionary = Combat.Mission.pending_decision(mission_state) if not mission_state.has("error") else {}
	if not str(mission_state.get("error", "")).is_empty(): print("CA readiness setup error: " + str(mission_state.error))
	var saved_warlords_match := true
	var saved_attachments_match := true
	for owner in [1, 2]:
		var declaration: Dictionary = formation.get("declarations", {}).get(owner, {})
		var reference: Dictionary = declaration.get("warlord", {})
		var expected_squad: int = owner + int(reference.get("unit_index", -1)) * 2
		var expected_model: int = expected_squad * 100 + int(reference.get("model_index", -1))
		saved_warlords_match = saved_warlords_match and not reference.is_empty() and int(mission_state.get("unit_abilities", {}).get("warlords", {}).get(owner, -1)) == expected_model
		var attachments: Array = declaration.get("attachments", [])
		if attachments.size() != 1: saved_attachments_match = false; continue
		var attachment: Dictionary = attachments[0]
		var leader_ref: Dictionary = attachment.get("leader", {})
		var leader_squad: int = owner + int(leader_ref.get("unit_index", -1)) * 2
		var leader_model: int = leader_squad * 100 + int(leader_ref.get("model_index", -1))
		var target_squad: int = owner + int(attachment.get("target_unit_index", -1)) * 2
		var leader_unit: Dictionary = mission_state.get("units", {}).get(leader_model, {})
		var target_unit: Dictionary = mission_state.get("squads", {}).get(target_squad, {})
		var expected_strength := 6 if owner == 1 else 11
		saved_attachments_match = saved_attachments_match and not leader_unit.is_empty() and not target_unit.is_empty() \
			and int(leader_unit.get("squad", -1)) == target_squad and str(leader_unit.get("attachment_role", "")) == "leader" \
			and bool(target_unit.get("attached", false)) and int(target_unit.get("starting_strength", 0)) == expected_strength
	check(str(saved_mission_marines.get("error", "")).is_empty() and str(saved_mission_necrons.get("error", "")).is_empty()
		and str(mission_report_p1.get("error", "")).is_empty() and str(mission_report_p2.get("error", "")).is_empty()
		and str(formation.get("error", "")).is_empty() and not mission_state.has("error") and saved_warlords_match and saved_attachments_match
		and Combat.UnitActions.setup_actor(mission_state) == 1
		and Combat.Mission.actor(mission_state) == 1 and mission_decision.get("source", "") == "mission-preparation"
		and not mission_decision.get("legal_options", []).is_empty(),
		"Saved Warlords and Leader attachments load without reselection while match-specific readiness and Chapter Approved preparation remain")
	var frozen_warlords: Dictionary = mission_state.get("unit_abilities", {}).get("warlords", {}).duplicate(true)
	mission_rolls = [6, 4, 2]
	var mission_setup_ok := resolve_mission_action(mission_state, 1, "mission-terrain").is_empty()
	mission_setup_ok = mission_setup_ok and mission_state.mission.stage == "roles-roll" and Combat.Mission.actor(mission_state) == 1
	mission_setup_ok = mission_setup_ok and resolve_mission_action(mission_state, 1, "mission-roles").is_empty()
	mission_setup_ok = mission_setup_ok and mission_state.mission.stage == "roles-choice" and Combat.Mission.actor(mission_state) == 1
	mission_setup_ok = mission_setup_ok and resolve_mission_action(mission_state, 1, "mission-side", 1).is_empty()
	mission_setup_ok = mission_setup_ok and mission_state.mission.stage == "battle-ready" and Combat.Mission.actor(mission_state) == 1
	mission_setup_ok = mission_setup_ok and resolve_mission_action(mission_state, 1, "mission-ready", 1).is_empty()
	mission_setup_ok = mission_setup_ok and Combat.Mission.actor(mission_state) == 2 and mission_state.mission.battle_ready == {1: true}
	mission_setup_ok = mission_setup_ok and resolve_mission_action(mission_state, 2, "mission-ready", 0).is_empty()
	mission_setup_ok = mission_setup_ok and mission_state.mission.stage == "formations" and Combat.Mission.actor(mission_state) == -1
	mission_setup_ok = mission_setup_ok and mission_state.get("unit_abilities", {}).get("warlords", {}) == frozen_warlords
	check(mission_setup_ok, "Chapter Approved terrain, roles and both Battle Ready declarations resolve in order without changing saved Warlords")
	var tempting_options: Dictionary = ca_options.duplicate(true)
	tempting_options.secondary_pair = "engage-tempting-target"
	var tempting_state: Dictionary = Prepared.initial_state(tempting_options, {1: mission_report_p1.get("selection", {}), 2: mission_report_p2.get("selection", {})})
	var tempting_setup_ok := not tempting_state.has("error") and Combat.Mission.actor(tempting_state) == 1
	mission_rolls = [6, 2, 5]
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 1, "mission-terrain").is_empty()
	tempting_setup_ok = tempting_setup_ok and tempting_state.mission.stage == "tempting-target-p1" and Combat.Mission.actor(tempting_state) == 2
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 2, "mission-tempting-target").is_empty()
	tempting_setup_ok = tempting_setup_ok and tempting_state.mission.stage == "tempting-target-p2" and Combat.Mission.actor(tempting_state) == 1
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 1, "mission-tempting-target").is_empty()
	tempting_setup_ok = tempting_setup_ok and tempting_state.mission.stage == "roles-roll" and Combat.Mission.actor(tempting_state) == 1
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 1, "mission-roles").is_empty()
	tempting_setup_ok = tempting_setup_ok and tempting_state.mission.stage == "roles-choice" and Combat.Mission.actor(tempting_state) == 2
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 2, "mission-side", 1).is_empty()
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 1, "mission-ready", 1).is_empty()
	tempting_setup_ok = tempting_setup_ok and resolve_mission_action(tempting_state, 2, "mission-ready", 0).is_empty()
	var target_owners: Array[String] = []
	for owner in [1, 2]:
		var target_name := str(tempting_state.mission.get("tempting_targets", {}).get(owner, ""))
		if not target_name.is_empty(): target_owners.append_array(Combat.Mission.tempting_target_owners(tempting_state, target_name))
	tempting_setup_ok = tempting_setup_ok and target_owners.has("P1") and target_owners.has("P2")
	tempting_setup_ok = tempting_setup_ok and tempting_state.mission.stage == "formations"
	tempting_setup_ok = tempting_setup_ok and tempting_state.get("unit_abilities", {}).get("warlords", {}) == frozen_warlords
	check(tempting_setup_ok, "A Tempting Target declarations resolve in opponent order before roles and Battle Ready without changing saved Warlords")
	var bid_options: Dictionary = ca_options.duplicate(true)
	bid_options.secondary_pair = "engage-bring-it-down"
	var bid_state: Dictionary = Prepared.initial_state(bid_options, {1: mission_report_p1.get("selection", {}), 2: mission_report_p2.get("selection", {})})
	var bid_decision: Dictionary = Combat.Mission.pending_decision(bid_state) if not bid_state.has("error") else {}
	if not str(bid_state.get("error", "")).is_empty(): print("Bring It Down readiness setup error: " + str(bid_state.error))
	var bid_targets_ok := not bid_state.has("error") \
		and Combat.Mission.has_bring_it_down_roster_target(bid_state, 1) \
		and Combat.Mission.has_bring_it_down_roster_target(bid_state, 2)
	var without_targets: Dictionary = bid_state.duplicate(true)
	for model: int in without_targets.get("units", {}):
		if int(without_targets.units[model].get("owner", 0)) == 2: without_targets.units[model].max_wounds = 9
	var stripped_targets_ok := not Combat.Mission.has_bring_it_down_roster_target(without_targets, 1) \
		and Combat.Mission.has_bring_it_down_roster_target(without_targets, 2)
	check(bid_targets_ok and stripped_targets_ok and Combat.UnitActions.setup_actor(bid_state) == 1
		and Combat.Mission.actor(bid_state) == 1 and bid_decision.get("source", "") == "mission-preparation"
		and not bid_decision.get("legal_options", []).is_empty(),
		"Bring It Down requires an opposing 10+ Wound model in each roster and opens Chapter Approved preparation when both armies have one")
	var bid_cards_ok: bool = bid_state.get("mission", {}).get("secondary_cards", []) == ["engage-on-all-fronts", "bring-it-down"]
	mission_rolls = [6, 4, 2]
	var bid_setup_ok := resolve_mission_action(bid_state, 1, "mission-terrain").is_empty()
	bid_setup_ok = bid_setup_ok and bid_state.mission.stage == "roles-roll" and Combat.Mission.actor(bid_state) == 1
	bid_setup_ok = bid_setup_ok and resolve_mission_action(bid_state, 1, "mission-roles").is_empty()
	bid_setup_ok = bid_setup_ok and bid_state.mission.stage == "roles-choice" and Combat.Mission.actor(bid_state) == 1
	bid_setup_ok = bid_setup_ok and resolve_mission_action(bid_state, 1, "mission-side", 1).is_empty()
	bid_setup_ok = bid_setup_ok and bid_state.mission.stage == "battle-ready" and Combat.Mission.actor(bid_state) == 1
	bid_setup_ok = bid_setup_ok and resolve_mission_action(bid_state, 1, "mission-ready", 1).is_empty()
	bid_setup_ok = bid_setup_ok and Combat.Mission.actor(bid_state) == 2
	bid_setup_ok = bid_setup_ok and resolve_mission_action(bid_state, 2, "mission-ready", 0).is_empty()
	bid_setup_ok = bid_setup_ok and bid_state.mission.stage == "formations" and Combat.Mission.actor(bid_state) == -1
	bid_setup_ok = bid_setup_ok and bid_state.get("unit_abilities", {}).get("warlords", {}) == frozen_warlords
	bid_setup_ok = bid_setup_ok and Combat.Mission.has_bring_it_down_roster_target(bid_state, 1) and Combat.Mission.has_bring_it_down_roster_target(bid_state, 2)
	check(bid_cards_ok and bid_setup_ok,
		"Bring It Down registers both cards and resolves terrain, roles and both Battle Ready declarations to Formations")
	mission_game.free()
	game.setup_finish_button.pressed.emit()
	check(game.Combat.UnitActions.setup_actor(game.state) == 2 and game.setup_finish_button.disabled,
		"Finishing Player 1 does not bypass Player 2's required Warlord")
	game.free()
	catalog.free()
	await process_frame
	print("Battle readiness UI checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

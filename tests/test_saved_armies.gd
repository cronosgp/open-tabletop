extends SceneTree
const T = preload("res://scripts/edition_11/training_roster.gd")
const P = preload("res://scripts/edition_11/prepared_training.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var marines := T.template("Space Marines", "training", 500)
	var necrons := T.template("Necrons", "training", 500)
	if not marines.error.is_empty() or not necrons.error.is_empty():
		push_error("Pinned starter data is required")
		quit(1)
		return
	check(T.inspect(marines.list).total == 160 and T.inspect(necrons.list).total == 170, "Runtime points resolve from local pack")
	var captain_profile: Dictionary = T.Capabilities.current_reference_profile("Space Marines", "captain")
	var captain_id := "40kdc:11e:adeptus-astartes:captain"
	var captain_list := ArmyRoster.new_list("11e", "Space Marines", "training", 500)
	captain_list.entries.append({"unit_id": captain_id, "name": str(captain_profile.get("name", "Captain")), "edition": "11e", "faction": "Space Marines", "role": "Character", "models": 1, "cost": int(captain_profile.get("points", 75)), "copies": 1, "source_digest": T.Capabilities.current_reference_digest("Space Marines")})
	ArmyRoster.normalize_copy_instance_ids(captain_list.entries[0])
	captain_list.warlord_model_id = ArmyRoster.model_instance_id(captain_list.entries[0], 0, 0)
	var captain_admission := T.admit_current_catalog(captain_list)
	var captain_refs := T.stable_model_refs(captain_list, captain_admission.selection) if captain_admission.error.is_empty() else {"error": captain_admission.error}
	check(captain_admission.error.is_empty() and captain_refs.error.is_empty() and captain_refs.models[captain_list.warlord_model_id] == {"unit_index": 0, "model_index": 0}, "Stable army model IDs map to sorted canonical match coordinates")
	if captain_admission.error.is_empty() and captain_refs.error.is_empty():
		var mapped_warlord := T.stable_formation_declaration(captain_list, captain_refs)
		var warlord_ref: Dictionary = mapped_warlord.declaration.warlord
		check(mapped_warlord.error.is_empty() and T.valid_match_formation_declaration(mapped_warlord.declaration) and captain_list.warlord_model_id not in var_to_str(mapped_warlord.declaration), "Saved Warlord candidates map to bounded network-safe match references without exposing local IDs")
		var formation_options := {"unit_abilities": true, "army_declarations": {1: mapped_warlord.declaration, 2: mapped_warlord.declaration}}
		var warlord_state := P.initial_state(formation_options, {1: captain_admission.selection, 2: captain_admission.selection})
		var restored_warlord_state := P.from_setup(warlord_state.get("saved_army_setup", {})) if not warlord_state.has("error") else {"error": warlord_state.error}
		check(not warlord_state.has("error") and warlord_state.unit_abilities.warlords == {1: 100, 2: 200} and warlord_state.unit_abilities.get("setup_players", []).is_empty(), "Saved Warlords use the current public rule choices without completing Battle Readiness")
		check(not restored_warlord_state.has("error") and restored_warlord_state.unit_abilities.warlords == {1: 100, 2: 200}, "Saved match setup restores its immutable Warlord declarations")
	var formation_list := ArmyRoster.new_list("11e", "Space Marines", "training", 500)
	var current_digest := T.Capabilities.current_reference_digest("Space Marines")
	var intercessor_profile := T.Capabilities.current_reference_profile("Space Marines", "intercessor-squad")
	var formation_intercessors := {"unit_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "name": "Intercessor Squad", "edition": "11e", "faction": "Space Marines", "role": "Battleline", "models": 5, "cost": int(intercessor_profile.get("points", 0)), "copies": 1, "source_digest": current_digest}
	var formation_captain := {"unit_id": captain_id, "name": str(captain_profile.get("name", "Captain")), "edition": "11e", "faction": "Space Marines", "role": "Character", "models": 1, "cost": int(captain_profile.get("points", 75)), "copies": 1, "source_digest": current_digest}
	formation_list.entries = [formation_intercessors, formation_captain]
	for entry: Dictionary in formation_list.entries: ArmyRoster.normalize_copy_instance_ids(entry)
	var captain_model_id := ArmyRoster.model_instance_id(formation_captain, 0, 0)
	var intercessor_copy_id := str(formation_intercessors.copy_instance_ids[0])
	formation_list.warlord_model_id = captain_model_id
	formation_list.leader_assignments = [{"leader_model_id": captain_model_id, "target_copy_id": intercessor_copy_id}]
	var formation_admission := T.admit_current_catalog(formation_list)
	var formation_refs := T.stable_model_refs(formation_list, formation_admission.selection) if formation_admission.error.is_empty() else {"error": formation_admission.error}
	if formation_admission.error.is_empty() and formation_refs.error.is_empty():
		var mapped_formation := T.stable_formation_declaration(formation_list, formation_refs)
		var captain_ref: Dictionary = formation_refs.models[captain_model_id]
		var target_ref: Dictionary = formation_refs.copies[intercessor_copy_id]
		var source_squad := 1 + int(captain_ref.unit_index) * 2
		var target_squad := 1 + int(target_ref.unit_index) * 2
		var captain_model := source_squad * 100 + int(captain_ref.model_index)
		var captain_model_p2 := (source_squad + 1) * 100 + int(captain_ref.model_index)
		var attachment_declaration: Dictionary = mapped_formation.declaration
		check(mapped_formation.error.is_empty() and T.valid_match_formation_declaration(attachment_declaration) and captain_model_id not in var_to_str(attachment_declaration), "Saved Leader and Support assignments map to a small declaration packet without local profile identifiers")
		var attachment_state := P.initial_state({"unit_abilities": true, "army_declarations": {1: attachment_declaration, 2: attachment_declaration}}, {1: formation_admission.selection, 2: formation_admission.selection})
		var restored_attachment_state := P.from_setup(attachment_state.get("saved_army_setup", {})) if not attachment_state.has("error") else {"error": attachment_state.error}
		var attached_correctly := not attachment_state.has("error") and int(attachment_state.units[captain_model].get("squad", -1)) == target_squad and str(attachment_state.units[captain_model].get("attachment_role", "")) == "leader"
		var restored_attachment := not restored_attachment_state.has("error") and int(restored_attachment_state.units[captain_model].get("squad", -1)) == target_squad and str(restored_attachment_state.units[captain_model].get("attachment_role", "")) == "leader"
		check(attached_correctly and int(attachment_state.units[captain_model_p2].get("squad", -1)) == target_squad + 1 and attachment_state.unit_abilities.warlords.get(1, -1) == captain_model and attachment_state.unit_abilities.warlords.get(2, -1) == captain_model_p2 and attachment_state.unit_abilities.get("setup_players", []).is_empty(), "Saved Leader attachments and Warlords apply through legal public setup choices for both players")
		check(restored_attachment and restored_attachment_state.unit_abilities.warlords.get(1, -1) == captain_model, "Saved match setup reconstructs its frozen Leader and Warlord declarations")
		check(not T.valid_match_formation_declaration({"warlord": {"unit_index": 0, "model_index": 0}, "unexpected": true}) and not T.valid_match_formation_declaration({"attachments": [{"leader": {"unit_index": 0, "model_index": 0}, "target_unit_index": "0"}]}), "Network formation packets reject unknown fields and non-integer references")
		var illegal_attachment := P.initial_state({"unit_abilities": true, "army_declarations": {1: {"attachments": [{"leader": captain_ref, "target_unit_index": int(captain_ref.unit_index)}]}}}, {1: formation_admission.selection, 2: formation_admission.selection})
		check(illegal_attachment.has("error"), "Saved attachment choices that violate current bodyguard rules are rejected before launch")
	else:
		check(false, "Current mixed Leader/bodyguard army maps stable miniature and unit references (admission: %s; mapping: %s)" % [str(formation_admission.get("error", "")), str(formation_refs.get("error", ""))])
	var intercessor_selection: Dictionary = T.inspect(marines.list).selection
	var illegal_warlord := P.initial_state({"unit_abilities": true, "army_declarations": {1: {"warlord": {"unit_index": 0, "model_index": 0}}}}, {1: intercessor_selection, 2: intercessor_selection})
	check(illegal_warlord.has("error"), "An ineligible saved Warlord is rejected by current match rules")
	var bad: Dictionary = marines.list.duplicate(true)
	bad.entries[0].cost = 99999
	check(T.inspect(bad).total == 160, "Saved/API prices cannot override runtime points")
	bad.entries[0].models = 6
	check(not T.inspect(bad).error.is_empty(), "Unsupported API composition is rejected instead of silently corrected")
	bad = marines.list.duplicate(true)
	bad.entries[0].unit_id = "unimplemented:captain"
	bad.entries[0].name = "Intercessor Squad"
	check(not T.inspect(bad).error.is_empty(), "Display-name spoof cannot admit unknown units")
	bad = marines.list.duplicate(true)
	bad.entries[0].copies = 6
	check(not T.inspect(bad).error.is_empty(), "More than six units is outside the core-profile limit")
	bad = marines.list.duplicate(true)
	bad.category = "custom"
	bad.points_limit = 100
	check(not T.inspect(bad).error.is_empty(), "Canonical runtime costs enforce the budget")
	var report := T.inspect(marines.list)
	var selection: Dictionary = report.selection.duplicate(true)
	selection.price = 0
	check(not T.admit(selection).error.is_empty(), "Public selection cannot supply prices or extra fields")
	necrons.list.entries.resize(1)
	necrons.list.name = "PRIVATE PROFILE LIST"
	necrons.list.notes = "PRIVATE NOTES"
	var a := T.inspect(necrons.list)
	var b := T.inspect(marines.list)
	var state := P.initial_state({}, {1: a.selection, 2: b.selection})
	check(not state.has("error") and state.units.size() == 20 and state.squads.size() == 3 and state.deployment.order == [1, 2, 4], "Saved lists create asymmetric army sizes and deployment order")
	check(state.squads[1].faction == "Necrons" and state.squads[2].faction == "Space Marines" and state.training_points == {1: 85, 2: 160}, "Either player may choose either implemented faction")
	check(state.points_limit == 500 and not state.roster_points_validated and state.pack_hash == P.from_setup(state.saved_army_setup).pack_hash, "Setup reconstructs deterministically without claiming official legality")
	check("PRIVATE" not in var_to_str(state), "Profile/list names and notes never enter match state")
	var mirror := P.initial_state({"manual_allocation": false}, {1: a.selection, 2: a.selection})
	for id: int in mirror.units:
		if id not in [100, 200]: mirror.units[id].wounds = 0
	mirror.phase = "shooting"
	var shot: Dictionary = P.Combat.shoot(mirror, 1, 100, 200, mirror.revision, true, func(): return 6)
	check(shot.error.is_empty() and mirror.squads[1].shot and mirror.has("last_attack"), "Inverted/same-faction rosters execute real combat with their own profiles")
	var changed: Dictionary = b.selection.duplicate(true)
	changed.category = "incursion"
	changed.points_limit = 1000
	check(P.initial_state({}, {1: a.selection, 2: changed}).has("error"), "Mismatched point categories/limits cannot start")
	check(P.initial_state({"varied_equipment": true}, {1: a.selection, 2: b.selection}).has("error"), "Saved-list mode cannot silently substitute curated varied equipment")
	var identity: String = state.pack_hash
	for squad in [1, 2, 4]:
		var owner: int = state.squads[squad].owner
		check(P.Deployment.preset(state, owner, state.revision).is_empty() and P.Deployment.confirm(state, owner, state.revision).is_empty(), "Each admitted unit can deploy coherently")
	for step in range(100):
		if state.test_winner != 0: break
		check(P.Combat.advance_phase(state, P.Combat.actor(state), state.revision).is_empty(), "Asymmetric saved armies can complete the mission")
	check(state.test_winner != 0 and state.pack_hash == identity, "Five rounds finish without changing frozen roster identity")
	var editor = load("res://scripts/army_builder_panel.gd").new()
	editor.storage_path = "res://.tools/offline-training-list.json"
	editor.cache_directory = "res://.tools/no-online-catalog"
	root.add_child(editor)
	check(not editor.source.catalog.is_empty() and editor.source.catalog.provider == "Consolidated local runtime", "Consolidated construction choices load offline without the API")
	editor._new_training()
	check(editor._save() and T.inspect(editor.draft).error.is_empty() and editor.catalog_boundary.visible, "Historical training fixture remains storable but is explicitly outside the consolidated construction catalog")
	editor.queue_free()
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.army_builder.store.path = "res://.tools/saved-army-profiles.json"
	var saved_a: Dictionary = game.army_builder.store.save_list(necrons.list)
	var current_marines: Dictionary = T.Capabilities.reference_army("Space Marines")
	var saved_b: Dictionary = game.army_builder.store.save_list(current_marines.list)
	game._refresh_army_choices()
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == (saved_a.list.id if owner == 1 else saved_b.list.id): picker.select(index)
	var before := var_to_str(game.state)
	game._start_saved_match(false)
	check(var_to_str(game.state) == before, "LAN training requires explicit acceptance")
	game.saved_training_consent.button_pressed = true
	game._start_saved_match()
	check(not game.saved_army_mode and var_to_str(game.state) == before, "Historical Necron drafts remain saved but cannot enter new match construction")
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == saved_b.list.id: picker.select(index)
	game.unit_abilities_choice.button_pressed = true
	game._start_quick_match()
	var quick_options: Dictionary = game.state.get("saved_army_setup", {}).get("options", {})
	check(game.saved_army_mode and game.state.units.size() == 40 and game.state.phase == "deployment" and quick_options.get("unit_abilities", false) and not quick_options.get("official_mission", false) and not quick_options.get("core_stratagems", false) and not game.manual_allocation, "Quick Match validates current-catalog lists and enters deployment with its explicit standard setup")
	var visual_source: Dictionary = saved_b.list.duplicate(true)
	if not visual_source.entries.is_empty():
		ArmyRoster.set_unit_visual_variant(visual_source.entries[0], 0, "snapshot-unit-variant")
		ArmyRoster.set_model_visual_override(visual_source.entries[0], 0, 0, "snapshot-model-override")
		game.local_visual_armies[1] = visual_source.duplicate(true)
		var frozen_presentation: Dictionary = game._local_visual_presentation()
		var frozen_entry: Dictionary = frozen_presentation.get("snapshot", {}).get("visual_armies", {}).get(1, {}).get("entries", [{}])[0]
		visual_source.entries[0].visual_variants[0] = "edited-source-variant"
		check(frozen_presentation.error.is_empty() and frozen_entry.get("visual_variants", [""])[0] == "snapshot-unit-variant", "A match takes an independent local appearance snapshot from its source list")
		game.local_visual_armies.clear()
		var restored_presentation := {"state": game.state.duplicate(true), "presentation": frozen_presentation.snapshot}
		var restore_error: String = game._restore_local_visual_presentation(restored_presentation)
		var restored_override_values: Array = game.local_visual_armies.get(1, {}).get("entries", [{}])[0].get("visual_model_overrides_by_id", {}).values()
		check(restore_error.is_empty() and "snapshot-model-override" in restored_override_values, "Saved match appearance references restore independently of later army edits")
	var mixed_visual_list := ArmyRoster.new_list("11e", "Space Marines", "training", 500)
	var mixed_default_entry := formation_intercessors.duplicate(true)
	mixed_default_entry.copies = 1
	mixed_default_entry.erase("copy_instance_ids")
	mixed_default_entry.erase("intercessor_sergeant_loadouts")
	mixed_default_entry.erase("intercessor_rifle_choice")
	mixed_default_entry.erase("intercessor_melee_choice")
	ArmyRoster.normalize_copy_instance_ids(mixed_default_entry)
	ArmyRoster.set_unit_visual_variant(mixed_default_entry, 0, "default-copy-variant")
	ArmyRoster.set_model_visual_override(mixed_default_entry, 0, 0, "default-copy-model")
	var mixed_alternate_entry := formation_intercessors.duplicate(true)
	mixed_alternate_entry.copies = 1
	mixed_alternate_entry.erase("copy_instance_ids")
	ArmyRoster.normalize_copy_instance_ids(mixed_alternate_entry)
	ArmyRoster.set_intercessor_sergeant_loadout(mixed_alternate_entry, 0, "plasma-pistol", "thunder-hammer")
	ArmyRoster.set_unit_visual_variant(mixed_alternate_entry, 0, "alternate-copy-variant")
	ArmyRoster.set_model_visual_override(mixed_alternate_entry, 0, 0, "alternate-copy-model")
	# Put the non-default configuration first so canonical grouping reverses the source order.
	mixed_visual_list.entries = [mixed_alternate_entry, mixed_default_entry]
	var mixed_visual_admission := T.admit_current_catalog(mixed_visual_list)
	var mixed_visual_refs := T.stable_model_refs(mixed_visual_list, mixed_visual_admission.selection) if mixed_visual_admission.error.is_empty() else {"error": mixed_visual_admission.error}
	var appearance_only_list: Dictionary = mixed_visual_list.duplicate(true)
	for appearance_index in range(appearance_only_list.entries.size()):
		var appearance_entry: Dictionary = appearance_only_list.entries[appearance_index]
		ArmyRoster.set_unit_visual_variant(appearance_entry, 0, "appearance-only-unit-%d" % appearance_index)
		ArmyRoster.set_model_visual_override(appearance_entry, 0, 0, "appearance-only-model-%d" % appearance_index)
	var appearance_only_admission := T.admit_current_catalog(appearance_only_list)
	var original_appearance_match: Dictionary = {}
	var changed_appearance_match: Dictionary = {}
	if mixed_visual_admission.error.is_empty() and appearance_only_admission.error.is_empty():
		original_appearance_match = P.initial_state(P.quick_match_options(), {1: mixed_visual_admission.selection, 2: mixed_visual_admission.selection})
		changed_appearance_match = P.initial_state(P.quick_match_options(), {1: appearance_only_admission.selection, 2: appearance_only_admission.selection})
	check(mixed_visual_admission.error.is_empty() and appearance_only_admission.error.is_empty()
		and mixed_visual_admission.selection == appearance_only_admission.selection
		and not original_appearance_match.has("error") and original_appearance_match == changed_appearance_match,
		"Changing saved appearance references alone cannot alter admitted equipment, points, or the frozen gameplay state")
	var mixed_alternate_copy_id := str(mixed_alternate_entry.copy_instance_ids[0])
	var mixed_default_copy_id := str(mixed_default_entry.copy_instance_ids[0])
	if mixed_visual_admission.error.is_empty() and mixed_visual_refs.error.is_empty():
		var alternate_match_index := int(mixed_visual_refs.copies[mixed_alternate_copy_id].unit_index)
		var default_match_index := int(mixed_visual_refs.copies[mixed_default_copy_id].unit_index)
		var saved_mixed_visual_list: Dictionary = game.army_builder.store.save_list(mixed_visual_list)
		if saved_mixed_visual_list.get("error", "").is_empty():
			mixed_visual_list.id = str(saved_mixed_visual_list.list.id)
			game._refresh_army_choices()
			for owner in [1, 2]:
				var picker: OptionButton = game.saved_army_pickers[owner]
				for index in range(picker.item_count):
					if str(picker.get_item_metadata(index).get("id", "")) == mixed_visual_list.id: picker.select(index)
			game._start_quick_match()
		else:
			check(false, "Mixed visual army can be saved to the local profile: %s" % str(saved_mixed_visual_list.error))
		var mixed_state: Dictionary = game.state
		var bound_visual_army: Dictionary = game.local_visual_armies.get(1, {})
		check(alternate_match_index == 1 and default_match_index == 0, "Stable copy references account for canonical reordering of different equipment configurations")
		check(game.saved_army_mode and mixed_state.get("saved_army_setup", {}).get("armies", {}).get(1, {}) == mixed_visual_admission.selection and not bound_visual_army.is_empty(), "Starting a saved match binds profile copies to its frozen canonical roster")
		if game.saved_army_mode and not bound_visual_army.is_empty():
			var alternate_model_id := (1 + alternate_match_index * 2) * 100
			var default_model_id := (1 + default_match_index * 2) * 100
			check(game._local_unit_visual_variant(alternate_model_id) == "alternate-copy-variant" and game._local_model_visual_override(alternate_model_id) == "alternate-copy-model", "Alternate copy visuals resolve through the canonical match-unit binding")
			check(game._local_unit_visual_variant(default_model_id) == "default-copy-variant" and game._local_model_visual_override(default_model_id) == "default-copy-model", "Default copy visuals resolve through the canonical match-unit binding")
			var version_two_snapshot := ArmyRoster.visual_snapshot(bound_visual_army)
			var saved_visuals := {"schema_version": 1, "visual_armies": {1: version_two_snapshot}}
			var snapshot_matches: bool = game._visual_snapshot_matches_selection(version_two_snapshot, mixed_state.saved_army_setup.armies[1])
			var restore_visual_error: String = game._restore_local_visual_presentation({"state": mixed_state, "presentation": saved_visuals})
			check(version_two_snapshot.get("schema_version", 0) == 3 and snapshot_matches and restore_visual_error.is_empty(), "Version 3 appearance snapshots retain explicit model modes and copy bindings against the frozen selection")
			var legacy_bound_snapshot := version_two_snapshot.duplicate(true)
			legacy_bound_snapshot.schema_version = 2
			for legacy_entry: Dictionary in legacy_bound_snapshot.entries: legacy_entry.erase("model_visual_selection_modes_by_id")
			check(ArmyRoster.valid_visual_snapshot(legacy_bound_snapshot) and game._visual_snapshot_matches_selection(legacy_bound_snapshot, mixed_state.saved_army_setup.armies[1]), "Version 2 bound appearance snapshots remain compatible after the version 3 mode migration")
			var frozen_setup: Dictionary = mixed_state.saved_army_setup.armies[1].duplicate(true)
			var frozen_visual_variant := ArmyRoster.unit_visual_variant(game.local_visual_armies[1].entries[0], 0)
			ArmyRoster.set_intercessor_sergeant_loadout(mixed_visual_list.entries[0], 0, "bolt-rifle", "power-weapon")
			ArmyRoster.set_unit_visual_variant(mixed_visual_list.entries[0], 0, "edited-after-match")
			check(game.state.saved_army_setup.armies[1] == frozen_setup and game._local_unit_visual_variant(alternate_model_id) == "alternate-copy-variant" and frozen_visual_variant == "alternate-copy-variant", "Editing the source list after match creation does not change frozen equipment or miniature appearance")
			version_two_snapshot.entries[0].match_unit_indices[0] = version_two_snapshot.entries[1].match_unit_indices[0]
			check(not ArmyRoster.valid_visual_snapshot(version_two_snapshot), "Duplicate canonical match-unit bindings are rejected during snapshot validation")
	else:
		check(false, "Mixed-configuration appearance fixture admits and maps (admission: %s; mapping: %s)" % [str(mixed_visual_admission.get("error", "")), str(mixed_visual_refs.get("error", ""))])
	var other = load("res://scenes/main.tscn").instantiate()
	root.add_child(other)
	other._start_prepared_match()
	other.saved_army_mode = true
	other.submitted_army = b.selection
	other.mode = "client"
	# The snapshot below uses the historical option defaults. Match the client to
	# that snapshot so this check reaches the submitted-list comparison.
	other.unit_abilities = false
	other.awakened_dynasty = false
	other.combat_doctrines = false
	other.reanimation_protocols = false
	other.core_stratagems = false
	var wrong := P.initial_state({}, {1: a.selection, 2: a.selection})
	other.receive_state(wrong)
	check(other.mode == "local" and "changed its army selection" in other.status.text, "Client rejects a host changing its submitted army")
	game._start_objectives()
	check(not game.saved_army_mode and not game.state.has("saved_army_setup"), "Existing exercises stay separate")
	print("Saved army admission checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

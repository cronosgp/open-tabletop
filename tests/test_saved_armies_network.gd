extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Assets = preload("res://scripts/local_models.gd")
var host_visual_fixture_path := ""

func install_host_visual(game: Node, definition: String, identity: String) -> String:
	host_visual_fixture_path = "res://.tools/network-host-visual-%d.obj" % OS.get_process_id()
	var file := FileAccess.open(host_visual_fixture_path, FileAccess.WRITE)
	if file == null: return "Could not create the host-only visual fixture."
	file.store_string("v -1 0 -1\nv 1 0 -1\nv 0 3 0\nv 0 0 1\nf 1 2 3\nf 2 4 3\nf 4 1 3\nf 1 4 2\n")
	file.close()
	var asset := Assets.obj_mesh(host_visual_fixture_path)
	if not str(asset.get("error", "")).is_empty(): return str(asset.error)
	game.model_imports.variant_mappings[identity] = {"definition": definition, "path": host_visual_fixture_path, "fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint, "scale": 1.0}
	game.model_imports.variant_cache[identity] = asset
	return ""

func current_list(catalog: Node, faction: String, source: String, model_count: int, copies: int = 1) -> Dictionary:
	var folder := "adeptus-astartes" if faction == "Space Marines" else "necrons"
	var unit: Dictionary = catalog.lookup("40kdc:11e:%s:%s" % [folder, source])
	if unit.is_empty(): return {"error": "Current local catalog is missing %s." % source}
	var option_index := -1
	for index in range(unit.get("options", []).size()):
		if int(unit.options[index].get("models", -1)) == model_count:
			option_index = index
			break
	if option_index < 0: return {"error": "Current local catalog has no %d-model option for %s." % [model_count, source]}
	var army := Roster.new_list("11e", faction, "training", 500)
	army.entries.append(Roster.entry(unit, option_index, copies))
	return {"error": "", "list": army}

func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.has("error"):
			push_error("Saved-army state failed before revision %d: %s" % [wanted, str(game.state.error)])
			return false
		if game.state.revision >= wanted: return true
		await create_timer(0.1).timeout
	push_error("Saved-army revision timeout %d/%d: %s" % [game.state.revision, wanted, game.status.text])
	return false
func deployment(game: Node) -> bool:
	for attempt in range(100):
		if game.state.has("error"):
			push_error("Saved-army state failed before Deployment: " + str(game.state.error))
			return false
		if game.state.phase == "deployment": return true
		await create_timer(0.1).timeout
	push_error("Saved-army setup timeout: " + game.status.text)
	return false

func readiness_actor(game: Node, expected: int) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		var armies: Dictionary = game.state.get("saved_army_setup", {}).get("armies", {})
		if armies.size() == 2 and Combat.UnitActions.setup_actor(game.state) == expected: return true
		await create_timer(0.1).timeout
	push_error("Saved-army readiness did not reach Player %d: revision=%d phase=%s actor=%d armies=%s status=%s" % [expected, game.state.get("revision", -1), str(game.state.get("phase", "")), Combat.UnitActions.setup_actor(game.state), str(game.state.get("saved_army_setup", {}).get("armies", {}).keys()), game.status.text])
	return false

func readiness_complete(game: Node) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		var armies: Dictionary = game.state.get("saved_army_setup", {}).get("armies", {})
		if armies.size() == 2 and Combat.UnitActions.setup_actor(game.state) < 0: return true
		await create_timer(0.1).timeout
	push_error("Saved-army readiness did not finish: revision=%d phase=%s actor=%d armies=%s status=%s" % [game.state.get("revision", -1), str(game.state.get("phase", "")), Combat.UnitActions.setup_actor(game.state), str(game.state.get("saved_army_setup", {}).get("armies", {}).keys()), game.status.text])
	return false

func deployment_actor(game: Node, expected: int, committed_count: int) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		var committed: Array = game.state.get("deployment", {}).get("committed", [])
		if game.state.phase == "deployment" and committed.size() == committed_count and Deployment.actor(game.state) == expected: return true
		await create_timer(0.1).timeout
	push_error("Saved-army deployment did not reach Player %d after %d units: revision=%d phase=%s actor=%d current=%d order=%s committed=%s status=%s" % [expected, committed_count, game.state.revision, str(game.state.phase), Deployment.actor(game.state), Deployment.current(game.state), str(game.state.get("deployment", {}).get("order", [])), str(game.state.get("deployment", {}).get("committed", [])), game.status.text])
	return false

func deployment_count(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		if game.state.get("deployment", {}).get("committed", []).size() >= wanted: return true
		await create_timer(0.1).timeout
	push_error("Saved-army deployment did not commit %d units: %s" % [wanted, game.status.text])
	return false

func deploy_current_unit(game: Node) -> bool:
	var before := int(game.state.revision)
	var committed_before: int = game.state.get("deployment", {}).get("committed", []).size()
	game._request_deployment_preset()
	if not await revision(game, before + 1): return false
	game._request_end()
	return await deployment_count(game, committed_before + 1)

func guest_connection(game: Node, connected: bool) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		if (game.guest_id != 0) == connected: return true
		await create_timer(0.1).timeout
	push_error("Saved-army guest connection did not become %s: %s" % ["connected" if connected else "disconnected", game.status.text])
	return false

func synchronized_deployed_command(game: Node) -> bool:
	for attempt in range(100):
		if game.state.has("error"): return false
		if game.status.text == "State synchronized with host." and game.state.phase == "command" and game.state.get("deployment", {}).get("committed", []).size() == 3: return true
		await create_timer(0.1).timeout
	push_error("Saved-army client did not restore the deployed match: revision=%d phase=%s committed=%s status=%s" % [game.state.revision, str(game.state.phase), str(game.state.get("deployment", {}).get("committed", [])), game.status.text])
	return false

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var mismatch: bool = "--budget-mismatch-test" in OS.get_cmdline_user_args()
	var count_rerolls: bool = "--count-rerolls-test" in OS.get_cmdline_user_args()
	var hazard_rerolls: bool = "--hazard-rerolls-test" in OS.get_cmdline_user_args()
	var escape_rerolls: bool = "--escape-rerolls-test" in OS.get_cmdline_user_args()
	var damage_rerolls: bool = "--damage-rerolls-test" in OS.get_cmdline_user_args()
	var save_rerolls: bool = "--save-rerolls-test" in OS.get_cmdline_user_args()
	var attack_rerolls: bool = "--attack-rerolls-test" in OS.get_cmdline_user_args()
	var rerolls: bool = "--movement-rerolls-test" in OS.get_cmdline_user_args()
	var stratagems: bool = "--stratagem-test" in OS.get_cmdline_user_args() or rerolls or attack_rerolls or save_rerolls or damage_rerolls or hazard_rerolls or count_rerolls or escape_rerolls
	game.stratagem_choice.button_pressed = stratagems
	game.reroll_choice.button_pressed = rerolls
	game.attack_reroll_choice.button_pressed = attack_rerolls
	game.save_reroll_choice.button_pressed = save_rerolls
	game.damage_reroll_choice.button_pressed = damage_rerolls
	game.hazard_reroll_choice.button_pressed = hazard_rerolls
	game.escape_reroll_choice.button_pressed = escape_rerolls
	game.count_reroll_choice.button_pressed = count_rerolls
	var catalog := Catalog.new()
	var catalog_error: String = catalog.select_edition("11e")
	if not catalog_error.is_empty():
		push_error(catalog_error)
		quit(1)
		return
	var current_army := current_list(catalog, "Necrons", "necron-warriors", 10) if host else current_list(catalog, "Space Marines", "intercessor-squad", 5, 2)
	if not str(current_army.get("error", "")).is_empty():
		push_error(str(current_army.error))
		catalog.free()
		quit(1)
		return
	var own: Dictionary = current_army.list
	var local_appearance_reference := "host-local-appearance-reference" if host else "client-local-appearance-reference"
	Roster.set_unit_visual_variant(own.entries[0], 0, local_appearance_reference)
	Roster.set_model_visual_override(own.entries[0], 0, 0, local_appearance_reference + "-model")
	# The host has a renderable local sculpt for this reference; the client does not.
	# Local visual availability must never enter synchronized gameplay state.
	if host:
		var host_visual_error := install_host_visual(game, str(own.entries[0].unit_id), local_appearance_reference)
		if host_visual_error.is_empty():
			host_visual_error = install_host_visual(game, str(own.entries[0].unit_id), local_appearance_reference + "-model")
		if not host_visual_error.is_empty():
			push_error(host_visual_error)
			catalog.free()
			quit(1)
			return
	if mismatch and not host:
		own.category = "incursion"
		own.points_limit = 1000
	own.name = "PRIVATE NAME"
	own.notes = "PRIVATE NOTES"
	game.army_builder.store.path = "res://.tools/saved-network-%s.json" % ("host" if host else "client")
	var saved: Dictionary = game.army_builder.store.save_list(own)
	if not saved.error.is_empty():
		push_error(saved.error)
		catalog.free()
		quit(1)
		return
	game._refresh_army_choices()
	var picker: OptionButton = game.saved_army_pickers[1 if host else 2]
	for index in range(picker.item_count):
		if picker.get_item_metadata(index).get("id", "") == saved.list.id: picker.select(index)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
	catalog.free()
	if game.state.has("error") or str(game.state.get("phase", "")) != "army_selection":
		push_error("Saved-army lobby failed to start: " + game.status.text)
		game.free()
		quit(1)
		return
	if host:
		game._host()
		var host_army_index := -1
		for index in range(game.saved_army_pickers[1].item_count):
			if str(game.saved_army_pickers[1].get_item_metadata(index).get("id", "")) == str(saved.list.id):
				host_army_index = index
				break
		if host_army_index < 0:
			push_error("Host cannot find its saved current-catalog profile after starting LAN.")
			quit(1)
			return
		game._network_army_selected(host_army_index)
		game.network_army_submit.pressed.emit()
		var passed: bool = await readiness_actor(game, 1)
		if passed:
			var setup_revision: int = game.state.revision
			game._request_setup_finish()
			passed = await revision(game, setup_revision + 1) and passed
		passed = await readiness_complete(game) and passed
		passed = await deployment(game) and passed
		var host_visuals: Dictionary = game.local_visual_armies.get(1, {})
		var host_visual_reference_kept := local_appearance_reference in var_to_str(host_visuals)
		var host_visuals_isolated := not var_to_str(game.state).contains(local_appearance_reference) and not var_to_str(game.state).contains("client-local-appearance-reference")
		var host_admission_matches: bool = game.state.units.size() == 20 and game.state.training_points == {1: 85, 2: 170} and "PRIVATE" not in var_to_str(game.state)
		var host_ready_local_visual := false
		var host_ready_model_visual := false
		var host_foreign_visual_absent := true
		for piece: Variant in game.pieces.values():
			var resolved := str(piece.get_meta("local_visual_resolved", ""))
			if resolved == local_appearance_reference: host_ready_local_visual = true
			if resolved == local_appearance_reference + "-model": host_ready_model_visual = true
			if resolved == "client-local-appearance-reference": host_foreign_visual_absent = false
		passed = passed and host_visual_reference_kept and host_visuals_isolated and host_admission_matches
		passed = passed and host_ready_local_visual and host_ready_model_visual and host_foreign_visual_absent
		var deployment_start_revision: int = game.state.revision
		passed = await deployment_actor(game, 1, 0) and passed
		passed = await deploy_current_unit(game) and passed
		passed = await deployment_count(game, 3) and passed
		passed = await guest_connection(game, false) and passed
		passed = await guest_connection(game, true) and passed
		passed = await revision(game, deployment_start_revision + 6) and passed
		passed = passed and game.state.phase == "start_turn" and game.state.deployment.committed == [1, 2, 4]
		game._request_end()
		passed = await revision(game, deployment_start_revision + 7) and passed
		passed = passed and game.state.phase == "command" and game.state.cp == {1: 1, 2: 1}
		passed = passed and game.state.has("stratagems") == stratagems
		passed = passed and game.state.get("stratagems", {}).get("escape_rerolls", false) == escape_rerolls
		passed = passed and game.state.get("stratagems", {}).get("count_rerolls", false) == count_rerolls and game.state.get("stratagems", {}).get("hazard_rerolls", false) == hazard_rerolls and game.state.get("stratagems", {}).get("damage_rerolls", false) == damage_rerolls and game.state.get("stratagems", {}).get("save_rerolls", false) == save_rerolls and game.state.get("stratagems", {}).get("attack_rerolls", false) == attack_rerolls and game.state.get("stratagems", {}).get("movement_rerolls", false) == rerolls
		if not host_visual_fixture_path.is_empty() and FileAccess.file_exists(host_visual_fixture_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(host_visual_fixture_path))
		print("SAVED ARMIES HOST: ", "PASS" if passed else "FAIL")
		await create_timer(5.0).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var army_submit_ready := false
	for attempt in range(100):
		if game.status.text == "State synchronized with host." and game.network_army_picker.visible and not game.network_army_submit.disabled:
			army_submit_ready = true
			break
		await create_timer(0.05).timeout
	if not army_submit_ready:
		push_error("Guest did not reach saved-army selection: " + game.network_army_status.text)
		quit(1)
		return
	var client_army_index := -1
	for index in range(game.saved_army_pickers[2].item_count):
		if str(game.saved_army_pickers[2].get_item_metadata(index).get("id", "")) == str(saved.list.id):
			client_army_index = index
			break
	if client_army_index < 0:
		push_error("Client cannot find its saved current-catalog profile after joining.")
		quit(1)
		return
	game._network_army_selected(client_army_index)
	game.network_army_submit.pressed.emit()
	var passed := true
	if mismatch:
		for attempt in range(100):
			if game.state.get("ready_armies", []).size() == 2: break
			await create_timer(0.1).timeout
		passed = game.state.phase == "army_selection" and game.state.cp == {1: 0, 2: 0} and game.state.revision == 0
		game.request_end.rpc_id(1, 0)
		await create_timer(0.15).timeout
		passed = passed and game.state.phase == "army_selection"
		own.id = saved.list.id
		own.category = "training"
		own.points_limit = 500
		game.army_builder.store.save_list(own)
		game._refresh_army_choices()
		game._submit_saved_army()
	passed = await readiness_actor(game, 2) and passed
	if passed:
		var setup_revision: int = game.state.revision
		game._request_setup_finish()
		passed = await revision(game, setup_revision + 1) and passed
	passed = await readiness_complete(game) and passed
	passed = await deployment_actor(game, 2, 1) and passed
	var client_visuals: Dictionary = game.local_visual_armies.get(2, {})
	var client_visual_reference_kept := local_appearance_reference in var_to_str(client_visuals)
	var client_visuals_isolated := not var_to_str(game.state).contains(local_appearance_reference) and not var_to_str(game.state).contains("host-local-appearance-reference")
	var client_admission_matches: bool = game.state.units.size() == 20 and game.state.training_points == {1: 85, 2: 170} and game.pieces.size() == 20 and game.state.squads[2].faction == "Space Marines"
	var client_foreign_visual_not_resolved := true
	var client_fallback_warning := false
	for piece: Variant in game.pieces.values():
		var resolved := str(piece.get_meta("local_visual_resolved", ""))
		if resolved == local_appearance_reference or resolved == local_appearance_reference + "-model" or resolved == "host-local-appearance-reference" or resolved == "host-local-appearance-reference-model": client_foreign_visual_not_resolved = false
		var warnings_value: Variant = piece.get_meta("local_visual_warnings", [])
		if resolved.is_empty() and warnings_value is Array and not warnings_value.is_empty(): client_fallback_warning = true
	passed = passed and client_visual_reference_kept and client_visuals_isolated and client_admission_matches
	passed = passed and client_foreign_visual_not_resolved and client_fallback_warning
	var identity: String = game.state.pack_hash
	var changed: Dictionary = game.submitted_army.duplicate(true)
	changed.copies = 1
	var before_invalid_commands: Dictionary = game.state.duplicate(true)
	game.request_saved_army.rpc_id(1, changed)
	game.request_move.rpc_id(1, 100, Vector2(-18, 0), int(game.state.revision))
	await create_timer(0.2).timeout
	passed = passed and game.state == before_invalid_commands and game.state.pack_hash == identity and game.state.units.size() == 20
	passed = await deploy_current_unit(game) and passed
	passed = await deployment_actor(game, 2, 2) and passed
	passed = await deploy_current_unit(game) and passed
	passed = await deployment_count(game, 3) and passed
	game._offline("Rejoin selected saved army")
	await create_timer(0.6).timeout
	game._join()
	passed = await synchronized_deployed_command(game) and passed
	passed = passed and game.state.pack_hash == identity and game.pieces.size() == 20 and game.state.deployment.committed == [1, 2, 4]
	passed = passed and game.state.training_points == {1: 85, 2: 170} and game.state.cp == {1: 1, 2: 1} and "PRIVATE" not in var_to_str(game.state)
	passed = passed and game.state.has("stratagems") == stratagems
	passed = passed and game.state.get("stratagems", {}).get("escape_rerolls", false) == escape_rerolls
	passed = passed and game.state.get("stratagems", {}).get("count_rerolls", false) == count_rerolls and game.state.get("stratagems", {}).get("hazard_rerolls", false) == hazard_rerolls and game.state.get("stratagems", {}).get("damage_rerolls", false) == damage_rerolls and game.state.get("stratagems", {}).get("save_rerolls", false) == save_rerolls and game.state.get("stratagems", {}).get("attack_rerolls", false) == attack_rerolls and game.state.get("stratagems", {}).get("movement_rerolls", false) == rerolls
	print("SAVED ARMIES CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.2).timeout
	quit(0 if passed else 1)

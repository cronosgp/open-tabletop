extends SceneTree
const R = preload("res://scripts/army_roster.gd")
const F = preload("res://tests/fixtures/army_catalog_fixture.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
var ROOT := "res://.tools/army-builder-test-%d" % OS.get_process_id()
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var tiered_unit := {"id": "rhino", "name": "Rhino", "edition": "11e", "faction": "Space Marines", "role": "Transporte dedicado", "source_digest": "source",
		"options": [{"models": 1, "cost": 70, "third_plus_cost": 70, "fourth_plus_cost": 80}]}
	var tiered_list := R.new_list("11e", "Space Marines", "custom", 1000)
	tiered_list.entries.append(R.entry(tiered_unit, 0, 4))
	check(R.summary(tiered_list).points == 290 and R.tiered_cost(70, 70, 1, 3, 80) == 80, "Fourth-plus pricing begins on the fourth copy, including copies split across entries")
	var catalog := F.catalog()
	var list := R.new_list("11e", "Space Marines")
	list.entries.append(R.entry(catalog.units[0], 1, 2))
	check(R.validate(list).is_empty() and R.summary(list).points == 300, "Variant cost is multiplied by unit copies, not models")
	var original := var_to_str(list)
	var updated := catalog.duplicate(true)
	updated.units[0].options[1].cost = 160
	updated.digest = R.catalog_digest(updated.units)
	var repriced := R.reprice(list, updated)
	check(var_to_str(list) == original and R.summary(repriced.list).points == 320, "Catalog updates do not change saved list costs without explicit repricing")
	var unknown := list.duplicate(true)
	unknown.entries[0].cost = null
	check(R.summary(unknown).unknown == 2 and not R.summary(unknown).within_budget, "Missing costs never count as complete zero-cost armies")
	list.entries.append(R.entry(catalog.units[2], 0))
	check(not R.validate(list).is_empty(), "Other factions require an explicit custom allies setting")
	list.allow_allies = true
	check(R.validate(list).is_empty(), "Custom mixed-faction planning is available")
	list.entries[-1].edition = "10e"
	check(not R.validate(list).is_empty(), "Mixed editions are rejected even with custom allies")
	check(R.faction_allowed("Blood Angels", "Space Marines", false) and not R.faction_allowed("Space Marines", "Blood Angels", false), "Chapter catalog includes common Marines without including every other chapter")
	var standard := R.standard(catalog, "Space Marines", "incursion", 1000)
	check(R.summary(standard).units == 3 and R.summary(standard).points == 250, "Editable standard base uses a character and two battleline units within budget")
	R.write_json(ROOT.path_join("catalogs/11e.json"), catalog)
	var panel := BuilderPanel.new()
	panel.storage_path = ROOT.path_join("profiles.json")
	panel.cache_directory = ROOT.path_join("catalogs")
	root.add_child(panel)
	# Synthetic persistence fixtures are injected explicitly; production ignores API caches.
	panel.source.catalog = catalog
	panel._fill_factions()
	for index in range(panel.faction_picker.item_count):
		if panel.faction_picker.get_item_text(index) == "Space Marines":
			panel.faction_picker.select(index)
			panel._faction_selected(index)
	check(panel.unit_picker.item_count == 2, "Builder filters units by selected army")
	panel._select_unit(0)
	panel.choice_picker.select(1)
	panel.copies.value = 2
	check("20 models" in panel.addition_summary.text and "300 pts added" in panel.addition_summary.text, "Addition preview multiplies both composition and points by copies")
	panel._add()
	check(panel.draft.entries[0].visual_variants.size() == panel.draft.entries[0].models * panel.draft.entries[0].copies, "Local appearance data retains one compatibility slot per model")
	R.set_unit_visual_variant(panel.draft.entries[0], 0, "variant-one")
	R.set_unit_visual_variant(panel.draft.entries[0], 1, "variant-two")
	check(panel.draft.entries[0].visual_variants[0] == "variant-one" and panel.draft.entries[0].visual_variants[9] == "variant-one" and panel.draft.entries[0].visual_variants[10] == "variant-two" and panel.draft.entries[0].visual_variants[19] == "variant-two", "Every model in a unit copy shares the same local appearance")
	panel._select_entry(0)
	panel._resume_draft()
	panel._open_entry_appearance()
	check(panel.visual_copy_picker.item_count == 2 and panel.visual_slot_controls.size() == 2, "Appearance editor shows the shared unit choice and the selected model's optional sculpt override")
	panel._set_model_visual_override(0, "reviewed-role-sculpt")
	check(R.model_visual_override(panel.draft.entries[0], 0, 0) == "reviewed-role-sculpt" and R.model_visual_override(panel.draft.entries[0], 0, 1).is_empty() and R.unit_visual_variant(panel.draft.entries[0], 0) == "variant-one", "A sculpt override changes one model while preserving the shared unit appearance for its squadmates")
	var legacy_visuals := R.entry(catalog.units[0], 1, 1)
	legacy_visuals.visual_variants = ["legacy-first", "legacy-second", "", "", "", "", "", "", "", ""]
	R.normalize_visual_variants(legacy_visuals)
	check(legacy_visuals.visual_variants.all(func(visual_id: String): return visual_id == "legacy-first"), "Legacy per-model appearances migrate to the first saved choice for that unit")
	panel.name_input.text = "My saved force"
	panel._changed()
	check(R.summary(panel.draft).points == 300 and panel.entries.item_count == 1, "Builder adds selected composition and unit copies")
	panel.category_picker.select(4)
	panel._category_selected(4)
	panel.points_limit.value = 100
	check("Over the limit" in panel.summary_label.text and panel._save(), "Over-budget planning can be saved as a clearly marked draft")
	var first_id: String = panel.draft.id
	var fresh := Profiles.new(panel.storage_path)
	check(fresh.error.is_empty() and fresh.active().lists.size() == 1 and R.summary(fresh.active().lists[0]).points == 300 and fresh.active().lists[0].points_limit == 100 and fresh.active().lists[0].entries[0].visual_variants[0] == "variant-one" and fresh.active().lists[0].entries[0].visual_variants[10] == "variant-two" and R.model_visual_override(fresh.active().lists[0].entries[0], 0, 0) == "reviewed-role-sculpt", "A fresh profile restores unit appearances and the explicit model override")
	check(panel.saved_lists_view.item_count == 1 and "My saved force" in panel.saved_list_detail.text, "The active profile library shows saved army details")
	var role_panel := BuilderPanel.new()
	role_panel.storage_path = ROOT.path_join("sergeant-profiles.json")
	role_panel.cache_directory = ROOT.path_join("catalogs")
	root.add_child(role_panel)
	role_panel.draft = R.new_list("11e", "Space Marines", "incursion", 1000)
	role_panel.draft.entries.append({"unit_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "name": "Intercessor Squad", "edition": "11e", "faction": "Space Marines", "role": "Linha de batalha", "models": 5, "cost": 85, "copies": 2, "source_digest": "current-profile"})
	role_panel._render_draft()
	check(role_panel.sergeant_loadout_heading.visible and role_panel.sergeant_loadout_copy_picker.item_count == 2 and role_panel.sergeant_rifle_picker.item_count == 5 and role_panel.sergeant_melee_picker.item_count == 5,
		"Army builder exposes source-listed Sergeant equipment independently for each Intercessor unit copy")
	role_panel._sergeant_loadout_copy_selected(1)
	for option_index in range(role_panel.sergeant_rifle_picker.item_count):
		if str(role_panel.sergeant_rifle_picker.get_item_metadata(option_index)) == "plasma-pistol": role_panel.sergeant_rifle_picker.select(option_index)
	for option_index in range(role_panel.sergeant_melee_picker.item_count):
		if str(role_panel.sergeant_melee_picker.get_item_metadata(option_index)) == "thunder-hammer": role_panel.sergeant_melee_picker.select(option_index)
	role_panel._set_sergeant_loadout_from_controls()
	var saved_sergeant_loadout := R.intercessor_sergeant_loadout(role_panel.draft.entries[0], 1)
	check(saved_sergeant_loadout == {"rifle_choice": "plasma-pistol", "melee_choice": "thunder-hammer"} and R.validate(role_panel.draft).is_empty() and "Plasma Pistol + Thunder Hammer" in role_panel.miniature_preview.caption.text,
		"The chosen Sergeant loadout persists by copy, validates as roster equipment and appears in the preview")
	var previous_file := FileAccess.get_file_as_string(panel.storage_path)
	check(not R.write_json(panel.storage_path, {"oversized": "x".repeat(200)}, 100).is_empty() and FileAccess.get_file_as_string(panel.storage_path) == previous_file, "Storage-size rejection preserves the previous readable library")
	panel._save_copy()
	check(panel.store.active().lists.size() == 2 and panel.draft.id != first_id and panel.draft.entries[0].visual_variants[0] == "variant-one" and panel.draft.entries[0].visual_variants[10] == "variant-two" and R.model_visual_override(panel.draft.entries[0], 0, 0) == "reviewed-role-sculpt", "Save copy retains composition, unit appearances and model overrides")
	check(panel.store.active().lists[0].name == "My saved force", "Editing a copied draft cannot mutate the original saved object")
	panel.profile_name.text = "Second player"
	panel._create_profile()
	check(panel.store.active().lists.is_empty(), "Each local profile has its own saved lists")
	panel.profile_picker.select(0)
	panel._select_profile(0)
	check(panel.store.active().lists.size() == 2, "Switching profiles restores the original library")
	panel.saved_picker.select(0)
	panel._load_list()
	check(panel.unsaved_dialog.visible, "Loading a saved list protects the retained profile draft")
	panel.unsaved_dialog.get_ok_button().pressed.emit()
	check(panel.draft.id == first_id and panel.name_input.text == "My saved force", "Saved list can be opened for editing")
	panel._select_entry(0)
	panel.entry_models_input.value = 9
	panel._apply_entry_size()
	check(panel.draft.entries[0].models == 10 and panel.draft.entries[0].cost == 150 and panel.draft.entries[0].visual_variants.size() == 20 and "outside the consolidated" in panel.notice.text, "Unsupported composition edit preserves cost and appearance assignments")
	panel.entry_models_input.value = 10
	panel._apply_entry_size()
	panel._reprice()
	check(panel.draft.entries[0].cost == 150 and panel.draft.entries[0].visual_variants[0] == "variant-one", "Repricing restores the catalog cost while preserving miniature choices")
	panel.source.catalog.units.append({"id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "source_id": "victrix-honour-guard", "name": "Victrix Honour Guard", "edition": "11e", "faction": "Space Marines", "role": "Other units", "keywords": ["ADEPTUS ASTARTES", "ULTRAMARINES"], "options": [{"models": 3, "cost": 120}], "source_digest": "source"})
	panel._filter_units()
	var victrix_index := -1
	for index in panel.unit_picker.item_count:
		var listed: Dictionary = panel.unit_picker.get_item_metadata(index)
		if listed.get("id", "") == "40kdc:11e:adeptus-astartes:victrix-honour-guard": victrix_index = index
	if victrix_index >= 0:
		panel._select_unit(victrix_index)
		panel.choice_picker.select(0)
		panel._refresh_composition_options()
		for index in panel.composition_picker.item_count:
			var choice: Dictionary = panel.composition_picker.get_item_metadata(index)
			if choice.get("id", "") == "guards-only": panel.composition_picker.select(index)
	panel.copies.value = 1
	panel._refresh_addition_summary()
	var composition_available := panel.composition_picker.visible
	var roles_preview := panel.addition_summary.text
	panel._add()
	var saved_victrix: Dictionary = panel.draft.entries.back()
	check(victrix_index >= 0 and composition_available and "120 pts added" in roles_preview and saved_victrix.get("composition_choice_id", "") == "guards-only" and int(saved_victrix.get("wargear_cost", -1)) == 0, "Army Workshop offers source-defined Victrix roles and saves the Bannerless role choice at the correct cost: index=%d visible=%s preview=%s saved=%s" % [victrix_index, str(composition_available), roles_preview, str(saved_victrix)])
	var corrupt_path := ROOT.path_join("corrupt.json")
	var file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var corrupt := Profiles.new(corrupt_path)
	check(not corrupt.error.is_empty() and not corrupt.save_list(standard).error.is_empty() and FileAccess.get_file_as_string(corrupt_path) == "{broken", "Malformed profiles cannot be overwritten with an empty library")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	check(game.match_tabs.get_tab_title(3) == "Army & Models" and game.army_builder != null and not game.combat_enabled and game.workshop_tabs.is_ancestor_of(game.model_imports), "Unified builder and imports are accessible without requiring a combat exercise")
	var local_panel = game.army_builder
	var api := {"id": "openhammer:11e:Space%20Marines:b007-fc7b-8e4a-b017", "name": "Infernus Squad", "edition": "11e", "faction": "Space Marines", "role": "Infantry", "source_digest": "stale-api", "options": [{"models": 1, "cost": 85}, {"models": 6, "cost": 180}]}
	panel.unit_picker.add_item("Infernus Squad")
	panel.unit_picker.set_item_metadata(panel.unit_picker.item_count - 1, api)
	panel._select_unit(panel.unit_picker.item_count - 1)
	check(panel.choice_picker.item_count == 2 and "10 models (Wahapedia e11)" in panel.choice_picker.get_item_text(1) and panel.selected_unit.options[1].cost == 190, "Actual builder offers approved 5/10 Infernus choices instead of stale API sizes/costs")
	panel.draft = R.new_list("11e", "Space Marines", "incursion", 1000)
	panel.source.catalog.units.append(api)
	panel.choice_picker.select(1)
	panel.copies.value = 1
	panel._add()
	check(panel.draft.entries.is_empty() and "outside the consolidated local catalog" in panel.notice.text, "An API-only identity cannot enter the local construction catalog")
	var local_infernus: Dictionary = local_panel.source.lookup("40kdc:11e:adeptus-astartes:infernus-squad")
	local_panel.unit_picker.clear()
	local_panel.unit_picker.add_item(local_infernus.name)
	local_panel.unit_picker.set_item_metadata(0, local_infernus)
	local_panel._select_unit(0)
	local_panel.draft = R.new_list("11e", "Space Marines", "incursion", 1000)
	local_panel.choice_picker.select(1)
	local_panel._add()
	check(local_panel.draft.entries.size() == 1 and local_panel.draft.entries[0].unit_id == "40kdc:11e:adeptus-astartes:infernus-squad" and local_panel.draft.entries[0].models == 10 and local_panel.draft.entries[0].cost == 190, "Builder stores the local canonical identity, size and current source cost")
	local_panel._reprice()
	check(local_panel.draft.entries[0].cost == 190, "Explicit repricing preserves the approved profile price")
	var local_land_raider: Dictionary = local_panel.source.lookup("40kdc:11e:adeptus-astartes:land-raider")
	local_panel.unit_picker.clear()
	local_panel.unit_picker.add_item(local_land_raider.name)
	local_panel.unit_picker.set_item_metadata(0, local_land_raider)
	local_panel._select_unit(0)
	local_panel.draft = R.new_list("11e", "Space Marines", "custom", 2000)
	local_panel.choice_picker.select(0)
	local_panel.copies.value = 2
	check("2nd+ 265 pts" in local_panel.choice_picker.get_item_text(0) and "510 pts added" in local_panel.addition_summary.text, "Builder displays the Land Raider's distinct second-copy price and calculates the preview")
	var local_terminators: Dictionary = local_panel.source.lookup("40kdc:11e:adeptus-astartes:terminator-squad")
	local_panel.unit_picker.clear()
	local_panel.unit_picker.add_item(local_terminators.name)
	local_panel.unit_picker.set_item_metadata(0, local_terminators)
	local_panel._select_unit(0)
	local_panel.draft = R.new_list("11e", "Space Marines", "custom", 2000)
	local_panel.choice_picker.select(0)
	local_panel.copies.value = 3
	check("3rd+ 230 pts" in local_panel.choice_picker.get_item_text(0) and "610 pts added" in local_panel.addition_summary.text, "Builder preview exposes the sourced later-copy tier and charges the third Terminator squad at its correct cost")
	local_panel._add()
	check(local_panel.draft.entries[0].get("third_plus_cost", -1) == 230 and R.summary(local_panel.draft).points == 610 and "610 pts" in local_panel.entries.get_item_text(0), "Builder saves and displays tiered Terminator prices accurately")
	local_panel._reprice()
	check(R.summary(local_panel.draft).points == 610, "Explicit repricing retains the tiered current-source price")
	var local_drop_pod: Dictionary = local_panel.source.lookup("40kdc:11e:adeptus-astartes:drop-pod")
	local_panel.unit_picker.clear()
	local_panel.unit_picker.add_item(local_drop_pod.name)
	local_panel.unit_picker.set_item_metadata(0, local_drop_pod)
	local_panel._select_unit(0)
	local_panel.draft = R.new_list("11e", "Space Marines", "custom", 2000)
	local_panel.copies.value = 4
	check("4th+ 70 pts" in local_panel.choice_picker.get_item_text(0) and "250 pts added" in local_panel.addition_summary.text, "Builder explains the Drop Pod fourth-copy price and calculates the preview")
	local_panel._add()
	check(local_panel.draft.entries.size() == 1 and local_panel.draft.entries[0].get("fourth_plus_cost", -1) == 70 and R.summary(local_panel.draft).points == 250, "Builder stores and totals the distinct fourth-plus price tier")
	local_panel._reprice()
	check(R.summary(local_panel.draft).points == 250, "Explicit repricing retains the sourced fourth-plus tier")
	var training := preload("res://scripts/edition_11/training_roster.gd")
	var current_intercessors: Dictionary = local_panel.source.lookup("40kdc:11e:adeptus-astartes:intercessor-squad")
	current_intercessors = training.Capabilities.current_catalog_choice(current_intercessors)
	check(local_panel._visual_model_role_label({"unit_id": current_intercessors.id}, 0) == "Intercessor Sergeant" and local_panel._visual_model_role_label({"unit_id": current_intercessors.id}, 1) == "Model 2", "Intercessor preview identifies its first model as the Sergeant without guessing other roles")
	var small_army := R.new_list("11e", "Space Marines", "custom", 1000)
	small_army.name = "Current Intercessor appearance pilot"
	small_army.entries.append(R.entry(current_intercessors, 0, 1))
	check(training.admit_current_catalog(small_army).error.is_empty(), "A freshly constructed single current Intercessor unit can start a test match")
	small_army.entries[0].source_digest = "historical-fixture"
	check(not training.admit_current_catalog(small_army).error.is_empty(), "An unreconciled single-profile draft stays outside current match construction")
	var palette_entry: Dictionary = local_panel.draft.entries[0]
	var palette_definition := str(palette_entry.unit_id)
	local_panel._select_entry(0)
	local_panel._set_visual_slot(0, "fixture-blue-a")
	local_panel._toggle_palette_choice()
	local_panel._set_visual_slot(1, "fixture-blue-b")
	local_panel._toggle_palette_choice()
	check(R.palette_variant(local_panel.draft, palette_definition, 0) == "fixture-blue-a" and R.palette_variant(local_panel.draft, palette_definition, 3) == "fixture-blue-b", "Army palette cycles reviewed appearances for the unit type")
	local_panel._set_visual_slot(1, "fixture-manual-override")
	R.set_model_visual_override(local_panel.draft.entries[0], 1, 0, "fixture-sergeant-sculpt")
	var palette_store := Profiles.new(ROOT.path_join("palette.json"))
	var saved_palette := palette_store.save_list(local_panel.draft)
	check(saved_palette.error.is_empty(), "Army palette saves with the roster")
	if saved_palette.error.is_empty():
		var reopened_palette := Profiles.new(ROOT.path_join("palette.json"))
		var reopened_list: Dictionary = reopened_palette.active().lists[0]
		check(R.palette_variant(reopened_list, palette_definition, 1) == "fixture-blue-b", "Army palette survives reload")
		check(reopened_list.entries[0].visual_variants[1] == "fixture-manual-override", "Manual unit-copy choice remains separate from the army palette")
		check(R.model_visual_override(reopened_list.entries[0], 1, 0) == "fixture-sergeant-sculpt", "Reviewed per-model sculpt overrides survive profile reload")
		var projected: Dictionary = game._gameplay_roster(reopened_list)
		check(not projected.has("visual_palette") and not projected.entries[0].has("visual_variants") and not projected.entries[0].has("visual_model_overrides"), "Gameplay roster excludes palette, shared appearance and model overrides")
		game.local_visual_armies[91] = reopened_list
		var prior_units := {}
		var prior_squads: Variant = game.state.get("squads", null)
		if prior_squads is Dictionary: prior_squads = prior_squads.duplicate(true)
		if not game.state.has("squads") or not game.state["squads"] is Dictionary: game.state["squads"] = {}
		for squad_index in range(2):
			var squad_id := 990001 + squad_index
			game.state["squads"][squad_id] = {"owner": 91}
			for model_index in range(2):
				var model_id := 990101 + squad_index * 10 + model_index
				prior_units[model_id] = game.state.units.get(model_id, null)
				game.state.units[model_id] = {"owner": 91, "definition_id": palette_definition, "squad": squad_id}
		check(game._local_palette_variant(990111) == "fixture-blue-b" and game._local_unit_visual_variant(990111) == "fixture-manual-override", "Battlefield resolves a unit copy's shared appearance independent of its model IDs")
		check(game._local_visual_variant(990111) == "fixture-sergeant-sculpt" and game._local_visual_variant(990112) == "fixture-manual-override", "A model override applies only to its assigned miniature and squadmates inherit the shared sculpt")
		for model_id: int in prior_units:
			if prior_units[model_id] == null: game.state.units.erase(model_id)
			else: game.state.units[model_id] = prior_units[model_id]
		if prior_squads == null: game.state.erase("squads")
		else: game.state["squads"] = prior_squads
		game.local_visual_armies.erase(91)
	var assets := preload("res://scripts/local_models.gd")
	var cached_models := ROOT.path_join("appearance-fixture")
	DirAccess.make_dir_recursive_absolute(cached_models)
	var sources: Array[Dictionary] = []
	for name: String in ["one", "two"]:
		var url := "https://example.invalid/" + name
		var obj := FileAccess.open(cached_models.path_join(assets.cache_key(url) + ".obj"), FileAccess.WRITE)
		obj.store_string("v -0.5 0 -0.5\nv 0.5 0 -0.5\nv 0 1 0\nv 0 0 0.5\nf 1 2 3\nf 1 3 4\nf 2 4 3\n")
		obj.close()
		sources.append({"Nickname": "Intercessor", "CustomMesh": {"MeshURL": url}})
	var source_file := FileAccess.open(cached_models.path_join("ForceOrg.json"), FileAccess.WRITE)
	source_file.store_string(JSON.stringify({"ObjectStates": sources}))
	source_file.close()
	game.model_imports.settings_path = cached_models.path_join("local.cfg")
	game.model_imports.download_path.text = cached_models
	game.model_imports.source_path.text = cached_models.path_join("ForceOrg.json")
	game.model_imports.mappings.clear()
	game.model_imports.variant_mappings.clear()
	local_panel.draft = R.new_list("11e", "Space Marines", "custom", 1000)
	local_panel.unit_picker.clear()
	local_panel.unit_picker.add_item(current_intercessors.name)
	local_panel.unit_picker.set_item_metadata(0, current_intercessors)
	local_panel._select_unit(0)
	local_panel.choice_picker.select(0)
	local_panel.copies.value = 2
	local_panel.automatic_appearance_toggle.button_pressed = true
	local_panel._add()
	for frame in 30:
		await process_frame
		if not game.model_imports.automatic_running and local_panel.pending_appearance_units.is_empty(): break
	var automatic_one: String = game.model_imports.automatic_variant_for(current_intercessors.id, 0)
	var automatic_two: String = game.model_imports.automatic_variant_for(current_intercessors.id, 1)
	check(not automatic_one.is_empty() and not automatic_two.is_empty() and automatic_one != automatic_two, "Opt-in army assembly can prepare different sculpts for separate unit copies")
	print("Army builder/profile checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

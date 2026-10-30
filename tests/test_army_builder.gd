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
	check(panel.draft.entries[0].visual_variants.size() == panel.draft.entries[0].models * panel.draft.entries[0].copies, "Every miniature receives a local appearance slot in the army draft")
	panel.draft.entries[0].visual_variants[0] = "variant-one"
	panel.draft.entries[0].visual_variants[1] = "variant-two"
	panel.name_input.text = "My saved force"
	panel._changed()
	check(R.summary(panel.draft).points == 300 and panel.entries.item_count == 1, "Builder adds selected composition and unit copies")
	panel.category_picker.select(4)
	panel._category_selected(4)
	panel.points_limit.value = 100
	check("Over the limit" in panel.summary_label.text and panel._save(), "Over-budget planning can be saved as a clearly marked draft")
	var first_id: String = panel.draft.id
	var fresh := Profiles.new(panel.storage_path)
	check(fresh.error.is_empty() and fresh.active().lists.size() == 1 and R.summary(fresh.active().lists[0]).points == 300 and fresh.active().lists[0].points_limit == 100 and fresh.active().lists[0].entries[0].visual_variants[0] == "variant-one", "A fresh profile restores army details and per-miniature appearances")
	check(panel.saved_lists_view.item_count == 1 and "My saved force" in panel.saved_list_detail.text, "The active profile library shows saved army details")
	var previous_file := FileAccess.get_file_as_string(panel.storage_path)
	check(not R.write_json(panel.storage_path, {"oversized": "x".repeat(200)}, 100).is_empty() and FileAccess.get_file_as_string(panel.storage_path) == previous_file, "Storage-size rejection preserves the previous readable library")
	panel._save_copy()
	check(panel.store.active().lists.size() == 2 and panel.draft.id != first_id and panel.draft.entries[0].visual_variants[1] == "variant-two", "Save copy retains composition and miniature appearances")
	check(panel.store.active().lists[0].name == "My saved force", "Editing a copied draft cannot mutate the original saved object")
	panel.profile_name.text = "Second player"
	panel._create_profile()
	check(panel.store.active().lists.is_empty(), "Each local profile has its own saved lists")
	panel.profile_picker.select(0)
	panel._select_profile(0)
	check(panel.store.active().lists.size() == 2, "Switching profiles restores the original library")
	panel.saved_picker.select(0)
	panel._load_list()
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
	print("Army builder/profile checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

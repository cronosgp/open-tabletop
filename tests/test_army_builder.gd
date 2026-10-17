extends SceneTree
const R = preload("res://scripts/army_roster.gd")
const F = preload("res://tests/fixtures/army_catalog_fixture.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const ROOT := "res://.tools/army-builder-test"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
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
	for index in range(panel.faction_picker.item_count):
		if panel.faction_picker.get_item_text(index) == "Space Marines":
			panel.faction_picker.select(index)
			panel._faction_selected(index)
	check(panel.unit_picker.item_count == 2, "Builder filters units by selected army")
	panel._select_unit(0)
	panel.choice_picker.select(1)
	panel.copies.value = 2
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
	check(panel.draft.entries[0].models == 9 and panel.draft.entries[0].cost == null and panel.draft.entries[0].visual_variants.size() == 18, "Editing model count marks price unconfirmed and resizes appearance slots")
	panel.entry_models_input.value = 10
	panel._apply_entry_size()
	panel._reprice()
	check(panel.draft.entries[0].cost == 150 and panel.draft.entries[0].visual_variants[0] == "variant-one", "Repricing restores the catalog cost while preserving miniature choices")
	var corrupt_path := ROOT.path_join("corrupt.json")
	var file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var corrupt := Profiles.new(corrupt_path)
	check(not corrupt.error.is_empty() and not corrupt.save_list(standard).error.is_empty() and FileAccess.get_file_as_string(corrupt_path) == "{broken", "Malformed profiles cannot be overwritten with an empty library")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	check(game.match_tabs.get_tab_title(3) == "Armies" and game.army_builder != null and not game.combat_enabled, "Builder is accessible without requiring a combat exercise")
	print("Army builder/profile checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

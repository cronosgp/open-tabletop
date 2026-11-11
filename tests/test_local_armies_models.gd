extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const Matcher = preload("res://scripts/forceorg_matcher.gd")
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
var failures := 0
var DIR := "res://.tools/local-armies-models-%d" % OS.get_process_id()
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var presets := Training.presets()
	check(presets.size() == 3 and presets[0].id == "reference:core-v2:Space Marines", "The original reference remains first beside two tactical training forces")
	for list: Dictionary in presets:
		check(list.faction == "Space Marines" and Training.admit_current_catalog(list).error.is_empty(), "Every fresh preset passes current local catalog admission")
		check(Training.inspect(list).error.is_empty() and list.points_limit == 1000, "Current local reference passes canonical admission at its declared limit")
	presets[0].entries.clear()
	check(not Training.presets()[0].entries.is_empty(), "Preset edits cannot mutate future defaults")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.army_builder.store = Profiles.new(DIR.path_join("army-lists.json"))
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.button_pressed = true
	check(game._picked_army(1).faction == "Space Marines" and game._picked_army(2).faction == "Space Marines", "Fresh launch preselects the current local reference for both seats")
	check(game.army_builder.store.active().lists.is_empty(), "Showing defaults does not silently populate the profile")
	game._start_saved_match()
	check(game.state.phase == "deployment" and game.state.units.size() == 40, "One local action starts both current local reference armies without LAN consent")
	game._save_selected_army(1)
	var saved: Dictionary = game.army_builder.store.active().lists[0]
	check(not saved.id.begins_with("preset:") and Training.inspect(saved).error.is_empty(), "Save copy generates an editable independent profile entry")
	var previous := var_to_str(game.state)
	game.saved_army_pickers[2].select(0)
	game._start_saved_match()
	check(var_to_str(game.state) == previous, "An incomplete setup preserves the current match")
	game.saved_army_pickers[2].select(2)
	game._start_saved_match()
	check(game.state.squads[1].faction == game.state.squads[2].faction, "Local setup supports mirror matches")
	var visual_fixture: Dictionary = Training.presets()[0].duplicate(true)
	for owner: int in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		picker.clear()
		picker.add_item("Role preflight fixture")
		picker.set_item_metadata(0, visual_fixture.duplicate(true))
		picker.select(0)
	var preparation_plan: Dictionary = game._visual_preparation_for_selections({1: {"faction": "Space Marines"}, 2: {"faction": "Space Marines"}})
	var every_definition_has_scoped_role_preflight: bool = not preparation_plan.get("requests", {}).is_empty()
	for request: Dictionary in preparation_plan.get("requests", {}).values():
		if not bool(request.get("all_role_variants", false)) or not request.get("role_families", []) is Array: every_definition_has_scoped_role_preflight = false
	check(every_definition_has_scoped_role_preflight, "Selected armies carry a source-group scope for equipment-role preflight on each datasheet")
	var definition: String = Training.definition("Space Marines").unit.id
	var mesh_url := "https://example.invalid/intercessor.obj"
	var entry := {"name": "Primaris Intercessor", "path": "ObjectStates/0", "kind": "CustomMesh", "references": {"MeshURL": mesh_url}}
	var bad: Dictionary = entry.duplicate(true)
	bad.name = "Assault Intercessor"
	check(not Matcher.choose(definition, [bad]).error.is_empty(), "Assault models cannot be selected for regular Intercessors")
	check(Matcher.variants("40kdc:11e:adeptus-astartes:assault-intercessor-squad", [bad]).size() == 1, "Assault Intercessor models are selectable for the matching unit")
	bad = entry.duplicate(true)
	bad.child_components = 2
	check(not Matcher.choose(definition, [bad]).error.is_empty(), "Composite base objects never auto-link as a complete miniature")
	bad = entry.duplicate(true)
	bad.references.MeshURL = "https://example.invalid/other.obj"
	check(Matcher.choose(definition, [entry, bad]).entry == Matcher.choose(definition, [bad, entry]).entry, "Visual variant selection is independent of catalog order")
	check(Matcher.variants(definition, [entry, bad]).size() == 2 and Matcher.variants(definition, [entry, bad])[0].variant_id != Matcher.variants(definition, [entry, bad])[1].variant_id, "Distinct compatible miniature variants can be assigned separately")
	var sergeant_definition := "40kdc:11e:adeptus-astartes:intercessor-squad"
	var sergeant_variant := {"name": "Intercessors Sgt w/ Plasma Pistol and Power Sword", "path": "ObjectStates/0/States/4", "guid": "sergeant-fixture", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/sergeant-body.obj"}, "components": [
		{"name": "Sergeant body", "kind": "CustomMesh", "path": "ObjectStates/0/States/4", "references": {"MeshURL": "https://example.invalid/sergeant-body.obj"}, "transforms": [], "base_candidate": false},
		{"name": "Power sword arm", "kind": "CustomMesh", "path": "ObjectStates/0/States/4/ChildObjects/0", "references": {"MeshURL": "https://example.invalid/power-sword.obj"}, "transforms": [{"position": [0.0, 0.0, 0.0], "rotation": [0.0, 0.0, 0.0], "scale": [1.0, 1.0, 1.0]}], "base_candidate": false}
	]}
	var role_options := Matcher.intercessor_sergeant_variants(sergeant_definition, [sergeant_variant])
	var sergeant_role_unit := {"definition_id": sergeant_definition, "sergeant": true, "intercessor_rifle_choice": "plasma-pistol", "intercessor_melee_choice": "power-weapon"}
	check(role_options.size() == 1 and role_options[0].visual_role == "intercessor-sergeant:plasma-pistol|power-weapon", "A complete saved Sergeant assembly receives a stable exact-loadout presentation role")
	var second_family_sergeant: Dictionary = sergeant_variant.duplicate(true)
	second_family_sergeant.path = "ObjectStates/1/States/5"
	second_family_sergeant.guid = "sergeant-raven-fixture"
	second_family_sergeant.source_group_hint = "Raven Guard"
	var family_role_options := Matcher.intercessor_sergeant_variants(sergeant_definition, [sergeant_variant, second_family_sergeant])
	check(family_role_options.size() == 2 and family_role_options[0].visual_role == family_role_options[1].visual_role and family_role_options[1].source_group_hint == "Raven Guard", "The same Sergeant weapon role retains one candidate per TTS source group")
	check(Matcher.intercessor_sergeant_visual_role(sergeant_role_unit) == role_options[0].visual_role, "Sergeant presentation role follows the selected ranged and melee equipment")
	sergeant_role_unit.intercessor_rifle_choice = "hand-flamer"
	check(Matcher.intercessor_sergeant_visual_role(sergeant_role_unit) == Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE, "A loadout without an exact source sculpt safely uses the dedicated Sergeant default role")
	var grenadier_source := {"name": "Intercessor w/ Grenade Launcher", "path": "ObjectStates/1", "guid": "grenadier-fixture", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/intercessor-grenadier.obj"}, "child_components": 0}
	var grenadier_options := Matcher.intercessor_grenadier_variants(sergeant_definition, [grenadier_source])
	var grenadier_unit := {"definition_id": sergeant_definition, "sergeant": false, "intercessor_grenade_launcher": true}
	check(grenadier_options.size() == 1 and grenadier_options[0].visual_role == Matcher.INTERCESSOR_GRENADIER_ROLE and Matcher.intercessor_model_visual_role(grenadier_unit) == Matcher.INTERCESSOR_GRENADIER_ROLE, "A non-Sergeant with a Grenade Launcher resolves to a complete weapon-role sculpt")
	grenadier_unit.intercessor_grenade_launcher = false
	check(Matcher.intercessor_model_visual_role(grenadier_unit).is_empty(), "An ordinary Intercessor remains on the shared unit appearance")
	var child_only_grenadier := grenadier_source.duplicate(true)
	child_only_grenadier.path += "/ChildObjects/0"
	check(Matcher.intercessor_grenadier_variants(sergeant_definition, [child_only_grenadier]).is_empty(), "A Grenade Launcher component alone is never selected as a complete miniature")
	var child_only_sergeant := sergeant_variant.duplicate(true)
	child_only_sergeant.path += "/ChildObjects/0"
	check(Matcher.intercessor_sergeant_variants(sergeant_definition, [child_only_sergeant]).is_empty(), "A weapon component alone is never imported as the complete Sergeant miniature")
	var infantry_base := {"base_radius_inches": 20.0 / 25.4}
	var normal_infantry := {"bounds": AABB(Vector3(-0.3, 0.0, -0.3), Vector3(0.6, 2.0, 0.6)), "base_footprint": Vector2.ZERO}
	var malformed_infantry := {"bounds": AABB(Vector3(-0.787, 0.0, -0.787), Vector3(13.895, 2.427, 1.575)), "base_footprint": Vector2.ZERO}
	check(Assets.visual_error_for_base(normal_infantry, infantry_base).is_empty(), "Proportionate infantry geometry without a detected OBJ base remains renderable")
	check(not Assets.visual_error_for_base(malformed_infantry, infantry_base).is_empty(), "An extreme infantry hull cannot render away from its gameplay base")
	write(DIR.path_join(Assets.cache_key(mesh_url) + ".obj"), "v 0 0 0\nv 1 0 0\nv 0 2 0\nf 1 2 3\n")
	var source := DIR.path_join("ForceOrg.json")
	write(source, JSON.stringify({"ObjectStates": [{"Nickname": "Primaris Intercessor", "CustomMesh": {"MeshURL": mesh_url}}]}))
	var panel := ImportPanel.new()
	panel.settings_path = DIR.path_join("models.cfg")
	root.add_child(panel)
	panel.source_path.text = source
	panel.download_path.text = DIR
	panel.catalog = Assets.scan(source)
	check(panel.variants_for(definition).size() == 1, "Army editor can browse compatible imported miniature variants")
	panel.download_variants_for(definition)
	check(panel.variant_mappings.size() == 1 and panel.variants_for(definition)[0].ready, "One action links compatible model variants from the local cache")
	var variant_visual: Node3D = panel.visual_variant_for(panel.variants_for(definition)[0].variant_id)
	check(variant_visual != null, "Downloaded variant renders from its local files")
	if variant_visual != null: variant_visual.free()
	var family_variant_id := str(panel.variants_for(definition)[0].variant_id)
	var old_family_catalog: Dictionary = panel.catalog.duplicate(true)
	var old_family_variant_mappings: Dictionary = panel.variant_mappings.duplicate(true)
	var old_family_mappings: Dictionary = panel.mappings.duplicate(true)
	panel.catalog = panel.catalog.duplicate(true)
	panel.catalog.entries[0].source_group_hint = "Salamanders"
	panel.variant_mappings.clear()
	panel.mappings.erase(definition)
	check(panel.visual_family_for("", definition) == "salamanders", "First-time role preflight derives the TTS group from the catalog's automatic base-sculpt candidate")
	panel.catalog = old_family_catalog
	panel.variant_mappings = old_family_variant_mappings
	panel.mappings = old_family_mappings
	var family_base: Dictionary = panel.variant_mappings[family_variant_id].duplicate(true)
	family_base.entry.source_group_hint = "Ultramarines"
	family_base.source_group_hint = "Ultramarines"
	panel.variant_mappings["test-unit-appearance"] = family_base
	var raven_role: Dictionary = family_base.duplicate(true)
	raven_role.visual_role = "intercessor-sergeant:plasma-pistol|power-weapon"
	raven_role.entry.source_group_hint = "Raven Guard"
	raven_role.source_group_hint = "Raven Guard"
	panel.variant_mappings["test-raven-sergeant"] = raven_role
	var ultramarines_role: Dictionary = family_base.duplicate(true)
	ultramarines_role.visual_role = "intercessor-sergeant:plasma-pistol|power-weapon"
	panel.variant_mappings["test-ultramarines-sergeant"] = ultramarines_role
	check(panel.visual_family_for("test-unit-appearance") == "ultramarines", "A chosen unit sculpt exposes its TTS source-group hint")
	check(panel.visual_role_variant_for("intercessor-sergeant:plasma-pistol|power-weapon", "ultramarines") == "test-ultramarines-sergeant", "A weapon role selects its matching paint family")
	check(panel.visual_role_variant_for("intercessor-sergeant:plasma-pistol|power-weapon", "raven guard") == "test-raven-sergeant" and panel.visual_role_variant_for("intercessor-sergeant:plasma-pistol|power-weapon", "dark angels").is_empty(), "Weapon-role selection refuses a different or missing paint family")
	var role_candidates: Array[Dictionary] = [
		{"variant_id": "test-raven-sergeant", "visual_role": "intercessor-sergeant:plasma-pistol|power-weapon", "source_group_hint": "Raven Guard"},
		{"variant_id": "test-ultramarines-sergeant", "visual_role": "intercessor-sergeant:plasma-pistol|power-weapon", "source_group_hint": "Ultramarines"}
	]
	check(panel._role_variant_ids_for_families(role_candidates, ["ULTRAMARINES"]) == ["test-ultramarines-sergeant"] and panel._role_variant_ids_for_families(role_candidates, []).is_empty(), "Role preflight queues only candidates in the selected source group and fails closed without one")
	game.model_imports.variant_mappings["test-unit-appearance"] = family_base.duplicate(true)
	var selected_visual_entry := {"unit_id": sergeant_definition, "models": 5, "copies": 1, "visual_variants": [], "visual_model_overrides": []}
	for _slot in range(5): selected_visual_entry.visual_variants.append("")
	selected_visual_entry.visual_variants[1] = "test-unit-appearance"
	for _slot in range(5): selected_visual_entry.visual_model_overrides.append("")
	var selected_visual_army := {"faction": "Space Marines", "entries": [selected_visual_entry], "visual_palette": {}}
	for owner: int in [1, 2]:
		game.saved_army_pickers[owner].set_item_metadata(0, selected_visual_army.duplicate(true))
	var family_preflight: Dictionary = game._visual_preparation_for_selections({1: {"faction": "Space Marines"}, 2: {"faction": "Space Marines"}})
	var family_request: Dictionary = family_preflight.get("requests", {}).get(sergeant_definition, {})
	check(family_request.get("role_families", []) == ["ultramarines"], "Match preflight derives the role family from the selected shared unit sculpt")
	for owner: int in [1, 2]: game.saved_army_pickers[owner].set_item_metadata(0, visual_fixture.duplicate(true))
	var before := var_to_str(game.state)
	await process_frame
	panel.prepare_armies([definition, "unsupported:captain"])
	for frame in range(8): await process_frame
	check(panel.mappings.has(definition) and not panel.downloader.busy and not panel.automatic_running, "Cached OBJ auto-links without HTTP or pawn selection")
	check("No visual alias" in panel.download_status.text, "Unsupported profiles have a recoverable per-model status")
	check(var_to_str(game.state) == before, "Visual preparation does not alter gameplay")
	var model_ids: Array = game.state.units.keys()
	model_ids.sort()
	var chosen_model := -1
	for model_id: int in model_ids:
		if game.state.units[model_id].owner == 1 and str(game.state.units[model_id].get("definition_id", "")).ends_with(":intercessor-squad"):
			chosen_model = model_id
			break
	if chosen_model >= 0:
		var chosen_unit: Dictionary = game.state.units[chosen_model]
		var appearance_index := maxi(0, game._local_unit_appearance_index(chosen_model))
		var owner_army := {"faction": "Space Marines", "entries": [{"unit_id": chosen_unit.definition_id, "models": 1, "copies": appearance_index + 1, "visual_variants": [], "visual_model_overrides": []}]}
		# Use the selected model's live squad size to form a valid presentation-only roster row.
		var squad_models: Array[int] = []
		for candidate_id: int in game.state.units:
			if game.state.units[candidate_id].squad == chosen_unit.squad and game.state.units[candidate_id].definition_id == chosen_unit.definition_id: squad_models.append(candidate_id)
		squad_models.sort()
		owner_army.entries[0].models = squad_models.size()
		for _slot in range(int(owner_army.entries[0].models) * int(owner_army.entries[0].copies)): owner_army.entries[0].visual_variants.append("")
		for _slot in range(int(owner_army.entries[0].models) * int(owner_army.entries[0].copies)): owner_army.entries[0].visual_model_overrides.append("")
		for model_index in range(squad_models.size()): owner_army.entries[0].visual_variants[appearance_index * squad_models.size() + model_index] = "test-unit-appearance"
		ArmyRoster.set_model_visual_override(owner_army.entries[0], appearance_index, 0, "test-sergeant-sculpt")
		game.local_visual_armies[1] = owner_army
		check(bool(game.state.units[squad_models[0]].get("sergeant", false)) and game._local_visual_variant(squad_models[0]) == "test-sergeant-sculpt" and game._local_visual_variant(squad_models[1]) == "test-unit-appearance", "Intercessor Sergeant can use its explicit sculpt while other models inherit the unit appearance")
		var role_visual_id: String = family_variant_id
		var fallback_mapping: Dictionary = family_base.duplicate(true)
		fallback_mapping.visual_role = Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE
		game.model_imports.variant_mappings[role_visual_id] = raven_role.duplicate(true)
		game.model_imports.variant_mappings["test-default-sergeant"] = fallback_mapping
		game.model_imports.variant_mappings["test-ultramarines-sergeant"] = ultramarines_role.duplicate(true)
		game.model_imports.variant_mappings["test-unit-appearance"] = family_base.duplicate(true)
		var sergeant_id := squad_models[0]
		game.state.units[sergeant_id].intercessor_rifle_choice = "plasma-pistol"
		game.state.units[sergeant_id].intercessor_melee_choice = "power-weapon"
		ArmyRoster.set_model_visual_override(owner_army.entries[0], appearance_index, 0, "")
		check(game._local_visual_variant(sergeant_id) == "test-ultramarines-sergeant", "The local Sergeant sculpt follows its loadout and selected unit paint family")
		game._sync_local_model_visual(sergeant_id, appearance_index)
		var first_role_visual_identity := str(game.pieces[sergeant_id].get_meta("local_visual_identity", ""))
		game.state.units[sergeant_id].intercessor_rifle_choice = "hand-flamer"
		check(game._local_visual_variant(sergeant_id) == "test-default-sergeant", "Unsupported Sergeant combinations use the same-family default sculpt")
		game._sync_local_model_visual(sergeant_id, appearance_index)
		check(first_role_visual_identity != str(game.pieces[sergeant_id].get_meta("local_visual_identity", "")) and game.pieces[sergeant_id].get_node_or_null("LocalModelVisual") != null, "A local equipment choice swaps the board visual without recreating the unit or sending asset data")
		var grenadier_id := squad_models[1]
		var grenadier_mapping: Dictionary = family_base.duplicate(true)
		grenadier_mapping.visual_role = Matcher.INTERCESSOR_GRENADIER_ROLE
		game.model_imports.variant_mappings["test-intercessor-grenadier"] = grenadier_mapping
		check(game._local_visual_variant(grenadier_id) == "test-unit-appearance", "A standard Intercessor inherits the unit sculpt before equipping the Grenade Launcher")
		game.state.units[grenadier_id].intercessor_grenade_launcher = true
		check(game._local_visual_variant(grenadier_id) == "test-intercessor-grenadier", "The equipped non-Sergeant selects its weapon-role sculpt")
		game._sync_local_model_visual(grenadier_id, appearance_index)
		var grenade_visual_identity := str(game.pieces[grenadier_id].get_meta("local_visual_identity", ""))
		game.state.units[grenadier_id].intercessor_grenade_launcher = false
		check(game._local_visual_variant(grenadier_id) == "test-unit-appearance", "Removing the Grenade Launcher restores the single unit appearance")
		game._sync_local_model_visual(grenadier_id, appearance_index)
		check(grenade_visual_identity != str(game.pieces[grenadier_id].get_meta("local_visual_identity", "")), "Changing an ordinary model's equipment swaps its local visual in place")
		# Exercise the generic path through main and the actual board renderer,
		# independently of the old Intercessor role flags and alias spellings.
		var generic_mapping: Dictionary = family_base.duplicate(true)
		generic_mapping.visual_role = "equipment:" + sergeant_definition
		generic_mapping.entry = {"name": "Primaris Intercessor - Bolt Rifle + GL", "visual_definitions": [sergeant_definition], "visual_weapons": ["grenade-launcher"], "visual_model_role": ""}
		game.model_imports.variant_mappings["test-generic-launcher"] = generic_mapping
		var original_weapons: Array = game.state.units[grenadier_id].get("ranged_weapons", []).duplicate(true)
		game.state.units[grenadier_id].ranged_weapons = original_weapons.duplicate(true)
		game.state.units[grenadier_id].ranged_weapons.append({"id": "synthetic-launcher", "name": "Astartes Grenade Launcher", "profiles": {"frag": {"name": "Astartes Grenade Launcher – Frag"}}})
		check(game._local_visual_variant(grenadier_id) == "test-generic-launcher", "Generated label metadata selects a weapon sculpt through main without a handwritten alias")
		var before_generic_render := var_to_str(game.state)
		game._sync_local_model_visual(grenadier_id, appearance_index)
		check(game.pieces[grenadier_id].get_meta("local_visual_resolved", "") == "test-generic-launcher" and game.pieces[grenadier_id].get_node_or_null("LocalModelVisual") != null, "The generic equipment choice replaces the rendered board miniature")
		check(var_to_str(game.state) == before_generic_render, "Generic board visual changes leave authoritative state untouched")
		var invalid_generic: Dictionary = generic_mapping.duplicate(true)
		write(DIR.path_join("broken-equipment.obj"), "<html>not a model</html>")
		invalid_generic.erase("parts")
		invalid_generic.path = DIR.path_join("broken-equipment.obj")
		game.model_imports.variant_mappings["0-broken-generic-launcher"] = invalid_generic
		game._sync_local_model_visual(grenadier_id, appearance_index)
		check(not game.model_imports.variant_cache.get("0-broken-generic-launcher", {}).get("error", "").is_empty() and game.pieces[grenadier_id].get_meta("local_visual_resolved", "") == "test-generic-launcher", "A corrupt highest-ranked equipment file falls through to the next compatible rendered miniature")
		game.model_imports.variant_mappings.erase("0-broken-generic-launcher")
		game.state.units[grenadier_id].ranged_weapons = original_weapons
		check(game._local_visual_variant(grenadier_id) == "test-unit-appearance", "A missing equipped weapon restores the available shared model")
	var presentation_list: Dictionary = game._picked_army(1)
	for army_entry: Dictionary in presentation_list.entries:
		army_entry.visual_variants = []
		for _slot in range(int(army_entry.models) * int(army_entry.copies)): army_entry.visual_variants.append("test-variant")
		army_entry.visual_model_overrides = []
		for _slot in range(int(army_entry.models) * int(army_entry.copies)): army_entry.visual_model_overrides.append("test-sergeant-sculpt")
	var canonical_selection: Dictionary = Training.inspect(presentation_list).selection
	check(not JSON.stringify(canonical_selection).contains("visual_variants") and not JSON.stringify(canonical_selection).contains("visual_model_overrides"), "Training admission strips both shared and per-model local appearance assignments from canonical match selections")
	var restored := ImportPanel.new()
	restored.settings_path = panel.settings_path
	root.add_child(restored)
	check(restored.source_path.text == source and restored.mappings.has(definition), "Catalog and links survive restart")
	var visual := restored.visual_for(definition)
	check(visual != null, "Restored automatic link renders a real mesh")
	if visual != null: visual.free()
	if not panel.mappings.has(definition):
		quit(1)
		return
	var mapping: Dictionary = panel.mappings[definition].duplicate(true)
	panel.prepare_armies([definition])
	check(panel.mappings[definition] == mapping and "Reused saved model" in panel.download_status.text, "Existing visual choices are preserved and reused")
	panel.automatic_running = true
	panel.automatic_queue = [{"definition": "old"}]
	var old_generation: int = panel.automatic_generation
	panel.cancel_automatic()
	panel._next_automatic(old_generation)
	check(panel.automatic_queue.is_empty() and panel.mappings[definition] == mapping, "Cancellation and stale queue callbacks preserve links")
	panel.automatic_running = true
	panel.automatic_current = {"definition": "failed:unit", "entry": entry}
	panel._finish_automatic_item({"error": "HTTP 404"})
	for frame in range(3): await process_frame
	check(not panel.mappings.has("failed:unit") and panel.mappings[definition] == mapping and "HTTP 404" in panel.download_status.text, "A failed download reports its reason without damaging earlier links")
	write(DIR.path_join("invalid.obj"), "<html>unavailable</html>")
	panel.automatic_running = true
	panel.automatic_current = {"definition": "invalid:unit", "entry": entry}
	panel._finish_automatic_item({"error": "", "mesh": DIR.path_join("invalid.obj"), "texture": ""})
	for frame in range(3): await process_frame
	check(not panel.mappings.has("invalid:unit") and panel.mappings[definition] == mapping, "HTTP success with invalid OBJ cannot create a visual link")
	var verified := {"name": "necron warrior reaper / component 1", "kind": "CustomMesh", "path": "ObjectStates/0/ChildObjects/0", "references": {"MeshURL": Matcher.VERIFIED_NECRON_BODY}}
	check(Matcher.choose(Training.definition("Necrons").unit.id, [verified]).error.is_empty(), "The previously verified Necron body can render over the board base")
	print("Local armies and automatic models: %d failures" % failures)
	panel.free()
	restored.free()
	for frame in range(3): await process_frame
	quit(0 if failures == 0 else 1)

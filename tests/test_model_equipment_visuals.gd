extends SceneTree

const Matcher = preload("res://scripts/forceorg_matcher.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const Assets = preload("res://scripts/local_models.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var definition := "40kdc:11e:adeptus-astartes:intercessor-squad"
	var rifle := {"name": "Bolt Rifle", "profiles": {"standard": {"name": "Bolt Rifle – Focused Fire"}}}
	var launcher := {"name": "Astartes Grenade Launcher", "profiles": {"frag": {"name": "Astartes Grenade Launcher – Frag"}}}
	var unit := {"definition_id": definition, "ranged_weapons": [rifle, launcher], "melee_weapons": [], "sergeant": false}
	var entry := {"name": "Primaris Intercessor - Bolt Rifle + GL", "guid": "aaaaaa", "path": "ObjectStates/1", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/mini"}, "source_group_hint": "Ultramarines", "visual_definitions": [definition], "visual_weapons": ["bolt-rifle", "grenade-launcher"], "visual_model_role": ""}
	var before := var_to_str(unit)
	var index_file := FileAccess.open("user://forceorg_visual_index.json", FileAccess.WRITE)
	index_file.store_string(JSON.stringify({"schema_version": 1, "sources": {"synthetic-save": {entry.path: {"label": entry.name, "guid": entry.guid, "definitions": [definition], "weapons": ["bolt-rifle", "grenade-launcher"], "source_group": "Ultramarines", "weapon_aliases": {definition: {"grenade-launcher": "astartes-grenade-launcher"}}}}}}))
	index_file.close()
	var unindexed := entry.duplicate(true)
	unindexed.erase("visual_definitions")
	unindexed.erase("visual_weapons")
	var indexed_entries: Array[Dictionary] = [unindexed]
	var warnings: Array[String] = []
	Assets._apply_visual_index(indexed_entries, "another-save", warnings)
	check(not unindexed.has("visual_definitions"), "Index from another save cannot inject datasheet associations")
	Assets._apply_visual_index(indexed_entries, "synthetic-save", warnings)
	check(definition in unindexed.get("visual_definitions", []), "Exact source hash, path, GUID and label restore local model associations")
	check(unindexed.get("visual_weapon_aliases", {}).get(definition, {}).get("grenade-launcher", "") == "astartes-grenade-launcher", "Source-scoped weapon aliases survive the index-to-runtime bridge")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://forceorg_visual_index.json"))
	var options := Matcher.variants(definition, [entry])
	check(options.size() == 1 and str(options[0].get("visual_role", "")).begins_with("equipment:"), "Indexed GL labels become equipment variants without a unit-specific alias")
	var accessory := entry.duplicate(true)
	accessory.visual_category = "ignored"
	check(Matcher.variants(definition, [accessory]).is_empty(), "Ignored accessories never become automatic miniature choices")
	check(Matcher.equipment_visual_score(entry, definition, unit) == 20, "Physical weapons match across fire modes and the bounded Astartes launcher visual alias")
	var exact_assessment := Matcher.equipment_visual_assessment(entry, definition, unit)
	check(exact_assessment.confidence == "strong" and is_equal_approx(float(exact_assessment.coverage), 1.0)
		and exact_assessment.matched_weapons.size() == 2 and exact_assessment.configured_weapons.size() == 2,
		"Strong appearance evidence means local weapon metadata covers every saved physical weapon")
	var partial_entry := entry.duplicate(true)
	partial_entry.visual_weapons = ["bolt-rifle"]
	var partial_assessment := Matcher.equipment_visual_assessment(partial_entry, definition, unit)
	check(partial_assessment.confidence == "partial" and is_equal_approx(float(partial_assessment.coverage), 0.5)
		and Matcher.equipment_visual_score(partial_entry, definition, unit) == 10,
		"Partial evidence reports saved weapon coverage while preserving the existing resolver ranking score")
	unit.ranged_weapons = [rifle]
	var conflict_assessment := Matcher.equipment_visual_assessment(entry, definition, unit)
	check(conflict_assessment.confidence == "conflict" and Matcher.equipment_visual_score(entry, definition, unit) == -1, "A launcher sculpt is not selected for a rifle-only loadout")
	unit.ranged_weapons = [rifle, launcher]
	var sgt := entry.duplicate(true)
	sgt.visual_model_role = "sergeant"
	check(Matcher.equipment_visual_score(sgt, definition, unit) == -1, "Sergeant sculpts do not replace ordinary models")
	check(Matcher.equipment_visual_score(entry, "another-datasheet", unit) == -1, "Datasheet identity bounds equipment selection")
	var child := entry.duplicate(true)
	child.path = "ObjectStates/1/ChildObjects/0"
	check(Matcher.equipment_variants(definition, [child]).is_empty(), "Child-only parts are not whole miniature choices")
	check(var_to_str(unit) == before, "Visual matching preserves authoritative equipment state")
	var bunker_definition := "40kdc:11e:adeptus-astartes:hammerfall-bunker"
	var bunker := {"definition_id": bunker_definition, "ranged_weapons": [{"name": "Hammerfall Heavy Bolter Array", "profiles": {"standard": {"name": "Hammerfall Heavy Bolter Array"}}}]}
	var bolter_sculpt := {"visual_definitions": [bunker_definition], "visual_weapons": ["heavy-bolter"], "visual_weapon_aliases": {bunker_definition: {"heavy-bolter": "hammerfall-heavy-bolter-array"}}}
	check(Matcher.equipment_visual_score(bolter_sculpt, bunker_definition, bunker) == 10, "A source-bounded short label resolves the equipped Hammerfall array")
	bolter_sculpt.visual_weapons.append("hammerfall-heavy-bolter-array")
	check(Matcher.equipment_visual_score(bolter_sculpt, bunker_definition, bunker) == 10, "A physical weapon is counted once even when both short and full labels are present")
	bunker.ranged_weapons = [{"name": "Hammerfall Heavy Flamer Array", "profiles": {}}]
	check(Matcher.equipment_visual_score(bolter_sculpt, bunker_definition, bunker) == -1, "A weapon alias cannot select the bolter sculpt for a flamer loadout")
	var grimaldus := "40kdc:11e:adeptus-astartes:chaplain-grimaldus"
	var companion := {"visual_definitions": [grimaldus], "visual_weapons": [], "visual_role_constraints": {grimaldus: {"status": "label_model_role", "roles": ["Cenobyte Servitor"]}}}
	var companion_assessment := Matcher.equipment_visual_assessment(companion, grimaldus, {"definition_id": grimaldus, "chaplain_grimaldus_role": "cenobyte"})
	check(companion_assessment.confidence == "role_only" and companion_assessment.role_match
		and Matcher.equipment_visual_score(companion, grimaldus, {"definition_id": grimaldus, "chaplain_grimaldus_role": "cenobyte"}) > 0,
		"An unarmed companion reports a role-only match and can select its own source-model sculpt")
	var no_hints := {"visual_definitions": [grimaldus]}
	var unverified_assessment := Matcher.equipment_visual_assessment(no_hints, grimaldus, {"definition_id": grimaldus})
	check(unverified_assessment.confidence == "unverified" and unverified_assessment.score == 0,
		"Candidates without weapon or model-role metadata remain unverified and keep the legacy neutral score")
	check(Matcher.equipment_visual_score(companion, grimaldus, {"definition_id": grimaldus, "chaplain_grimaldus_role": "chaplain"}) == -1, "A companion never replaces the character in a mixed datasheet")
	var unresolved := companion.duplicate(true)
	unresolved.visual_role_constraints[grimaldus] = {"status": "ambiguous_model_role", "roles": ["Chaplain Grimaldus", "Cenobyte Servitor"]}
	check(Matcher.equipment_visual_score(unresolved, grimaldus, {"definition_id": grimaldus, "chaplain_grimaldus_role": "cenobyte"}) == -1, "Ambiguous mixed-model labels use the existing appearance fallback")
	var company := "40kdc:11e:adeptus-astartes:company-heroes"
	check("Ancient" in Matcher.model_roles({"definition_id": company, "company_heroes_model": 0}), "Indexed runtime members resolve through the current profile's model loadouts")
	check(Matcher.supported_definition("40kdc:11e:necrons:doomsday-ark"), "Current visual definitions do not depend on the historical starter pack")
	var aggressor_definition := "40kdc:11e:adeptus-astartes:aggressor-squad"
	var aggressor_base := {"name": "Flamestorm Gauntlets", "profiles": {"ranged": {"name": "Flamestorm Gauntlets – Ranged"}, "close_quarters": {"name": "Flamestorm Gauntlets – Close Quarters"}}}
	var aggressor_flame := {"definition_id": aggressor_definition, "ranged_weapons": [aggressor_base], "melee_weapons": [], "sergeant": false}
	var aggressor_visual := entry.duplicate(true)
	aggressor_visual.visual_definitions = [aggressor_definition]
	aggressor_visual.visual_weapons = ["flamestorm-gauntlets"]
	aggressor_visual.visual_weapon_aliases = {}
	var aggressor_boltstorm := {"definition_id": aggressor_definition, "ranged_weapons": [
		{"name": "Auto Boltstorm Gauntlets", "profiles": {"standard": {"name": "Auto Boltstorm Gauntlets"}}},
		{"name": "Fragstorm Grenade Launcher", "profiles": {"standard": {"name": "Fragstorm Grenade Launcher"}}}], "melee_weapons": [], "sergeant": false}
	var aggressor_bolt_visual := aggressor_visual.duplicate(true)
	aggressor_bolt_visual.visual_weapons = ["auto-boltstorm-gauntlets", "fragstorm-grenade-launcher"]
	check(Matcher.supported_definition(aggressor_definition)
		and Matcher.variants(aggressor_definition, [aggressor_visual]).size() == 1
		and Matcher.equipment_visual_score(aggressor_visual, aggressor_definition, aggressor_flame) == 10
		and Matcher.equipment_visual_score(aggressor_bolt_visual, aggressor_definition, aggressor_boltstorm) == 20
		and Matcher.equipment_visual_score(aggressor_visual, aggressor_definition, aggressor_boltstorm) == -1,
		"Aggressor miniature variants use reliable per-model weapon metadata and reject a conflicting physical package")
	var panel := ImportPanel.new()
	# Existing project-owned file stands in for an available cache file; no download.
	panel.variant_mappings = {"gl": {"definition": definition, "source_group_hint": "Ultramarines", "entry": entry, "path": "res://project.godot"}}
	var refreshed := entry.duplicate(true)
	refreshed.variant_id = "gl"
	panel.variant_mappings.gl.entry = {}
	panel._refresh_variant_catalog_metadata([refreshed])
	check(panel.variant_mappings.gl.entry.get("visual_weapons", []).size() == 2, "Previously cached files receive rebuilt catalog metadata without another download")
	check(panel.equipment_variant_for(unit, "ultramarines") == "gl", "Prepared same-family equipment sculpt is selected")
	panel.variant_mappings["alternate"] = panel.variant_mappings.gl.duplicate(true)
	panel.variant_mappings.alternate.entry.visual_weapons = ["bolt-rifle"]
	check(panel.equipment_variants_for(unit, "ultramarines") == ["gl", "alternate"], "Every compatible available sculpt is ranked for fallback, with the most specific equipment first")
	panel.variant_mappings.erase("alternate")
	check(panel.equipment_variant_for(unit, "blood angels").is_empty(), "Automatic selection never crosses the selected appearance family")
	panel.variant_mappings.gl.source_group_hint = ""
	panel.variant_mappings.gl.entry.source_group_hint = ""
	panel.variant_mappings.gl.entry.material_family_hint = "materials-v1:synthetic"
	panel.variant_mappings.gl.entry.visual_role = options[0].visual_role
	check(panel.visual_family_for("gl", definition) == "materials-v1:synthetic", "Selected cached sculpt exposes its derived material family")
	check(panel.equipment_variant_for(unit, "materials-v1:synthetic") == "gl", "Prepared weapon variants can use the selected material family when no source group exists")
	check(panel.equipment_variant_for(unit, "materials-v1:other").is_empty(), "Derived families do not cross other material groups")
	check(panel._role_variant_ids_for_families([panel.variant_mappings.gl.entry], ["materials-v1:synthetic"]) == ["gl"], "Preparation and runtime selection use the same material-family filter")
	panel.variant_mappings.gl.path = "res://missing-model.obj"
	check(panel.equipment_variant_for(unit, "ultramarines").is_empty(), "Unavailable sculpt returns control to the existing unit fallback")
	panel.free()
	print("MODEL EQUIPMENT VISUALS: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)

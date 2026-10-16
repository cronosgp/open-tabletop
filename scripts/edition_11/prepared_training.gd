extends RefCounted
## Versioned custom setup; does not claim legal official army construction.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const ID := "prepared-objective-training-v1"

static func initial_state(options: Dictionary = {}, selections: Dictionary = {}) -> Dictionary:
	for key: Variant in options:
		if key not in ["manual_allocation", "varied_equipment", "core_stratagems", "movement_rerolls", "attack_rerolls", "save_rerolls", "damage_rerolls", "hazard_rerolls", "count_rerolls", "objective_secured", "implacable_eradication", "escape_rerolls", "hail_of_bolts"]: return {"error": "Unsupported match option: " + str(key)}
		if not options[key] is bool: return {"error": "Match options must be boolean: " + str(key)}
	var manual: bool = options.get("manual_allocation", true)
	var varied: bool = options.get("varied_equipment", false)
	if (options.get("movement_rerolls", false) or options.get("attack_rerolls", false) or options.get("save_rerolls", false) or options.get("damage_rerolls", false) or options.get("hazard_rerolls", false) or options.get("count_rerolls", false) or options.get("escape_rerolls", false)) and not options.get("core_stratagems", false): return {"error": "Command Re-roll requires the core stratagems option."}
	var reports: Dictionary = {}
	if not selections.is_empty():
		if selections.size() != 2 or not selections.has(1) or not selections.has(2): return {"error": "Select both armies."}
		if varied: return {"error": "Saved lists use this training mode's fixed default weapons."}
		for owner in [1, 2]:
			var report := Training.admit(selections[owner])
			if not report.error.is_empty(): return report
			reports[owner] = report
		if reports[1].selection.category != reports[2].selection.category or reports[1].selection.points_limit != reports[2].selection.points_limit:
			return {"error": "Players must choose the same category and points limit."}
	var state := Battlefield.apply(Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING, 2, manual, varied))
	if state.has("error"): return state
	if options.get("core_stratagems", false): Combat.Stratagems.enable(state, options.get("movement_rerolls", false), options.get("attack_rerolls", false), options.get("save_rerolls", false), options.get("damage_rerolls", false), options.get("hazard_rerolls", false), options.get("count_rerolls", false), options.get("escape_rerolls", false))
	if not reports.is_empty():
		var original := state.duplicate(true)
		state.units = {}
		state.squads = {}
		for owner in [1, 2]:
			var report: Dictionary = reports[owner]
			var selection: Dictionary = report.selection
			if selection.schema_version == 2:
				_materialize_mixed(state, original, report, owner)
				continue
			for index in range(selection.copies):
				var squad: int = owner + index * 2
				state.squads[squad] = original.squads[report.template].duplicate(true)
				state.squads[squad].owner = owner
				state.squads[squad].name += " %d" % (index + 1)
				for model in range(selection.models):
					var unit: Dictionary = original.units[report.template * 100 + model].duplicate(true)
					unit.owner = owner
					unit.squad = squad
					unit.position = Vector2((-12.0 - floori(model / 5.0) * 1.5) if owner == 1 else (12.0 + floori(model / 5.0) * 1.5), (model % 5 - 2) * 1.3 + (-4.0 + index * 8.0 if selection.copies == 2 else 0.0))
					state.units[squad * 100 + model] = unit
		state.points_limit = reports[1].selection.points_limit
		state.battle_size = "Custom training"
		state.test_battlefield = "saved-army-training-43x43-v1"
		state.training_points = {1: reports[1].total, 2: reports[2].total}
		state.saved_army_setup = {"schema_version": 1, "options": {"manual_allocation": manual, "varied_equipment": false},
			"armies": {1: reports[1].selection, 2: reports[2].selection}}
		if options.get("core_stratagems", false): state.saved_army_setup.options.core_stratagems = true
		if options.get("movement_rerolls", false): state.saved_army_setup.options.movement_rerolls = true
		if options.get("attack_rerolls", false): state.saved_army_setup.options.attack_rerolls = true
		if options.get("save_rerolls", false): state.saved_army_setup.options.save_rerolls = true
		if options.get("damage_rerolls", false): state.saved_army_setup.options.damage_rerolls = true
		if options.get("hazard_rerolls", false): state.saved_army_setup.options.hazard_rerolls = true
		if options.get("escape_rerolls", false): state.saved_army_setup.options.escape_rerolls = true
		if options.get("count_rerolls", false): state.saved_army_setup.options.count_rerolls = true
	if options.get("objective_secured", false):
		Combat.ObjectiveSecured.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.objective_secured = true
	if options.get("implacable_eradication", false):
		Combat.ImplacableEradication.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.implacable_eradication = true
	if options.get("hail_of_bolts", false):
		Combat.HailOfBolts.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.hail_of_bolts = true
	var rosters: Array[Dictionary] = []
	for owner in [1, 2]:
		var units: Array[Dictionary] = []
		for squad: int in state.squads:
			if state.squads[squad].owner == owner:
				units.append({"squad": squad, "name": state.squads[squad].name, "models": Combat.living(state, squad).size()})
		rosters.append({"owner": owner, "units": units, "official_legality_validated": false})
	state.match_manifest = {"schema_version": 1, "scenario": ID, "rules_implementation": Combat.PACK_ID,
		"content_hash": state.pack_hash, "battlefield": Battlefield.ID, "mission": Combat.Objectives.TRAINING,
		"manual_allocation": manual, "varied_equipment": varied, "first_player": 1, "rosters": rosters}
	if options.get("core_stratagems", false): state.match_manifest.core_stratagems = Combat.Stratagems.ID
	if options.get("movement_rerolls", false): state.match_manifest.movement_rerolls = Combat.Stratagems.REROLL_ID
	if options.get("attack_rerolls", false): state.match_manifest.attack_rerolls = Combat.Stratagems.ATTACK_REROLL_ID
	if options.get("save_rerolls", false): state.match_manifest.save_rerolls = Combat.Stratagems.SAVE_REROLL_ID
	if options.get("damage_rerolls", false): state.match_manifest.damage_rerolls = Combat.Stratagems.DAMAGE_REROLL_ID
	if options.get("hazard_rerolls", false): state.match_manifest.hazard_rerolls = Combat.Stratagems.HAZARD_REROLL_ID
	if options.get("escape_rerolls", false): state.match_manifest.escape_rerolls = Combat.Stratagems.ESCAPE_REROLL_ID
	if options.get("count_rerolls", false): state.match_manifest.count_rerolls = Combat.Stratagems.COUNT_REROLL_ID
	if options.get("objective_secured", false): state.match_manifest.objective_secured = Combat.ObjectiveSecured.ID
	if options.get("implacable_eradication", false): state.match_manifest.implacable_eradication = Combat.ImplacableEradication.ID
	if options.get("hail_of_bolts", false): state.match_manifest.hail_of_bolts = Combat.HailOfBolts.ID
	if not reports.is_empty():
		if reports[1].selection.schema_version == 2 or reports[2].selection.schema_version == 2:
			state.match_manifest.capabilities = Training.Capabilities.ID
		state.match_manifest.scenario = "saved-army-training-v1"
		state.match_manifest.saved_armies = state.saved_army_setup.duplicate(true)
		state.match_manifest.training_points = state.training_points.duplicate()
		state.match_manifest.official_legality_validated = false
	state.pack_hash = var_to_str(state.match_manifest).sha256_text()
	Deployment.begin(state)
	return state

static func waiting(options: Dictionary) -> Dictionary:
	var state := initial_state(options)
	if state.has("error"): return state
	state.phase = "army_selection"
	state.pack_hash = (str(state.pack_hash) + ":saved-army-lobby-v1").sha256_text()
	state.ready_armies = []
	return state

static func from_setup(setup: Variant) -> Dictionary:
	if not setup is Dictionary or setup.size() != 3 or setup.get("schema_version") != 1 or not setup.get("options") is Dictionary or not setup.get("armies") is Dictionary: return {"error": "Invalid public training setup."}
	return initial_state(setup.options, setup.armies)

static func _materialize_mixed(state: Dictionary, original: Dictionary, report: Dictionary, owner: int) -> void:
	var index := 0
	for entry: Dictionary in report.selection.entries:
		var resolved: Dictionary = report.definitions[entry.definition_id]
		var spec: Dictionary = resolved.spec
		for copy in range(entry.copies):
			var squad := owner + index * 2
			var group: Dictionary = original.squads[spec.template].duplicate(true)
			group.name = resolved.unit.name + " %d" % (copy + 1)
			group.owner = owner
			group.faction = report.selection.faction
			group.starting_strength = int(entry.models)
			group.stats = resolved.unit.stats.duplicate(true)
			group.weapon = resolved.weapons.gun.duplicate(true)
			group.melee_weapon = resolved.weapons.blade.duplicate(true)
			group.disabled_abilities = resolved.unsupported_abilities.duplicate()
			state.squads[squad] = group
			var spacing: float = maxf(1.3, float(resolved.unit.base.radius_inches) * 2.0 + 0.1)
			var rows := 3 if int(entry.models) == 5 else 5
			for model in range(entry.models):
				var unit: Dictionary = original.units[int(spec.template) * 100].duplicate(true)
				unit.owner = owner
				unit.squad = squad
				unit.definition_id = entry.definition_id
				unit.keywords = resolved.unit.keywords.duplicate()
				unit.movement = group.stats.movement_inches
				unit.wounds = int(group.stats.wounds)
				unit.max_wounds = int(group.stats.wounds)
				unit.radius = float(resolved.unit.base.radius_inches)
				unit.position = Vector2((-12.0 - floori(float(model) / rows) * spacing) if owner == 1 else (12.0 + floori(float(model) / rows) * spacing), (model % rows - (rows - 1) / 2.0) * spacing + (index - (report.unit_count - 1) / 2.0) * 7.0)
				if model == 0 and resolved.weapons.has("sergeant"):
					unit.melee_weapons = [{"id": "sergeant-power-weapon", "profiles": {"standard": resolved.weapons.sergeant.duplicate(true)}}]
				state.units[squad * 100 + model] = unit
			index += 1

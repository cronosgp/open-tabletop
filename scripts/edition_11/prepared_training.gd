extends RefCounted
## Versioned custom setup; does not claim legal official army construction.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const MatchManifest = preload("res://scripts/edition_11/match_manifest.gd")
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ID := "prepared-objective-training-v2"

static func initial_state(options: Dictionary = {}, selections: Dictionary = {}) -> Dictionary:
	if options.get("combat_doctrines", false) and options.get("oath_of_moment", false): return {"error": "11e Combat Doctrines replaces the historical Oath of Moment profile; these options cannot be combined."}
	for key: Variant in options:
		if key not in ["manual_allocation", "varied_equipment", "core_stratagems", "movement_rerolls", "attack_rerolls", "save_rerolls", "damage_rerolls", "hazard_rerolls", "count_rerolls", "objective_secured", "implacable_eradication", "escape_rerolls", "hail_of_bolts", "oath_of_moment", "reanimation_protocols", "combat_doctrines", "awakened_dynasty", "unit_abilities", "official_mission", "checked_rosters"]: return {"error": "Unsupported match option: " + str(key)}
		if not options[key] is bool: return {"error": "Match options must be boolean: " + str(key)}
	if options.get("unit_abilities", false) and (options.get("hail_of_bolts", false) or options.get("objective_secured", false) or options.get("oath_of_moment", false)): return {"error": "Current datasheets cannot combine with historical Hail of Bolts, Objective Secured or Oath profiles."}
	if options.get("official_mission", false):
		for required in ["unit_abilities", "combat_doctrines", "reanimation_protocols", "awakened_dynasty", "core_stratagems"]:
			if not options.get(required, false) and not (required == "core_stratagems" and options.get("checked_rosters", false)):
				return {"error": "The CA mission requires current unit, faction and core stratagem options."}
	if options.get("checked_rosters", false) and not options.get("official_mission", false): return {"error": "Checked rosters require the selected current CA mission."}
	if options.get("checked_rosters", false) and selections.is_empty(): selections = Combat.RosterValidation.defaults()
	var manual: bool = options.get("manual_allocation", true)
	var varied: bool = options.get("varied_equipment", false)
	if varied and options.get("unit_abilities", false): return {"error": "Current unit abilities use the documented fixed loadouts."}
	var core: bool = options.get("core_stratagems", false)
	var movement_rerolls: bool = options.get("movement_rerolls", false)
	var attack_rerolls: bool = options.get("attack_rerolls", false)
	var save_rerolls: bool = options.get("save_rerolls", false)
	var damage_rerolls: bool = options.get("damage_rerolls", false)
	var hazard_rerolls: bool = options.get("hazard_rerolls", false)
	var count_rerolls: bool = options.get("count_rerolls", false)
	var escape_rerolls: bool = options.get("escape_rerolls", false)
	if options.get("checked_rosters", false):
		core = true
		movement_rerolls = true
		attack_rerolls = true
		save_rerolls = true
		damage_rerolls = true
		hazard_rerolls = true
		count_rerolls = true
		escape_rerolls = true
	if (movement_rerolls or attack_rerolls or save_rerolls or damage_rerolls or hazard_rerolls or count_rerolls or escape_rerolls) and not core: return {"error": "Command Re-roll requires the core stratagems option."}
	var reports: Dictionary = {}
	if not selections.is_empty():
		if selections.size() != 2 or not selections.has(1) or not selections.has(2): return {"error": "Select both armies."}
		if varied: return {"error": "Saved lists use this training mode's fixed default weapons."}
		for owner in [1, 2]:
			var report := Combat.RosterValidation.admit(selections[owner]) if options.get("checked_rosters", false) else Training.admit(selections[owner])
			if not report.error.is_empty(): return report
			reports[owner] = report
		if reports[1].selection.category != reports[2].selection.category or reports[1].selection.points_limit != reports[2].selection.points_limit:
			return {"error": "Players must choose the same category and points limit."}
	if options.get("official_mission", false) and not reports.is_empty():
		if reports[1].selection.faction != "Space Marines" or reports[2].selection.faction != "Necrons" or reports[1].selection.points_limit != 1000 or reports[1].selection.category != "incursion": return {"error": "This selected CA mission admits Space Marines P1 vs Necrons P2 with a 1000-point Incursion limit; prices and army legality remain reference data."}
	var state := Battlefield.apply(Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING, 2, manual, varied))
	if state.has("error"): return state
	if core: Combat.Stratagems.enable(state, movement_rerolls, attack_rerolls, save_rerolls, damage_rerolls, hazard_rerolls, count_rerolls, escape_rerolls)
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
		if core: state.saved_army_setup.options.core_stratagems = true
		if movement_rerolls: state.saved_army_setup.options.movement_rerolls = true
		if attack_rerolls: state.saved_army_setup.options.attack_rerolls = true
		if save_rerolls: state.saved_army_setup.options.save_rerolls = true
		if damage_rerolls: state.saved_army_setup.options.damage_rerolls = true
		if hazard_rerolls: state.saved_army_setup.options.hazard_rerolls = true
		if escape_rerolls: state.saved_army_setup.options.escape_rerolls = true
		if count_rerolls: state.saved_army_setup.options.count_rerolls = true
	if options.get("objective_secured", false):
		Combat.ObjectiveSecured.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.objective_secured = true
	if options.get("implacable_eradication", false):
		Combat.ImplacableEradication.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.implacable_eradication = true
	if options.get("hail_of_bolts", false):
		Combat.HailOfBolts.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.hail_of_bolts = true
	if options.get("oath_of_moment", false):
		Combat.OathOfMoment.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.oath_of_moment = true
	if options.get("reanimation_protocols", false):
		Combat.Reanimation.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.reanimation_protocols = true
	if options.get("combat_doctrines", false):
		Combat.Doctrines.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.combat_doctrines = true
	if options.get("awakened_dynasty", false):
		Combat.Awakened.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.awakened_dynasty = true
	if options.get("unit_abilities", false):
		var loadout_error := _current_loadouts(state)
		if not loadout_error.is_empty(): return {"error": loadout_error}
		Combat.UnitAbilities.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.unit_abilities = true
	if options.get("official_mission", false):
		Combat.Mission.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.official_mission = true
	if options.get("checked_rosters", false):
		Combat.RosterValidation.enable(state, reports)
		state.saved_army_setup.options.checked_rosters = true
	var manifest_options := {
		"manual_allocation": manual, "varied_equipment": varied, "core_stratagems": core,
		"movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls,
		"save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls,
		"hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls,
		"count_rerolls": count_rerolls
	}
	MatchManifest.seal(state, options, reports, manifest_options, ID)
	Deployment.begin(state)
	Combat.Awakened.begin_setup(state)
	return state

static func waiting(options: Dictionary) -> Dictionary:
	var state := initial_state(options)
	if state.has("error"): return state
	if options.get("checked_rosters", false): state.erase("saved_army_setup")
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
			group.training_cost = resolved.cost
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

static func _current_loadouts(state: Dictionary) -> String:
	var cache: Dictionary = {}
	var marine_profiles_used := false
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var source := Combat.UnitAbilities.identity(unit)
		if source not in Combat.UnitAbilities.RULES: return "Unsupported current unit profile: " + source
		if str(unit.get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"):
			var marine_profile := CurrentMarineProfiles.profile(source)
			if marine_profile.is_empty(): return "No current-reference fixed loadout is recorded for " + source
			var squad: int = unit.squad
			state.squads[squad].stats = marine_profile.stats.duplicate(true)
			var ranged_profiles: Dictionary = marine_profile.ranged[0].profiles
			var melee_profiles: Dictionary = marine_profile.melee[0].profiles
			state.squads[squad].weapon = ranged_profiles.values()[0].duplicate(true)
			state.squads[squad].melee_weapon = melee_profiles.values()[0].duplicate(true)
			unit.keywords = marine_profile.keywords.duplicate()
			unit.movement = int(marine_profile.stats.movement_inches)
			unit.wounds = int(marine_profile.stats.wounds)
			unit.max_wounds = int(marine_profile.stats.wounds)
			unit.ranged_weapons = marine_profile.ranged.duplicate(true)
			unit.melee_weapons = marine_profile.melee.duplicate(true)
			marine_profiles_used = true
			continue
		if not cache.has(source):
			var faction := "Necrons" if str(unit.definition_id).contains(":necrons:") else "Space Marines"
			cache[source] = Training.Capabilities.resolve(faction, unit.definition_id)
			if not cache[source].error.is_empty(): return cache[source].error
		var resolved: Dictionary = cache[source]
		var profiles := {"standard": resolved.weapons.gun.duplicate(true)}
		if source == "intercessor-squad":
			for weapon: Dictionary in resolved.unit.source_weapon_definitions:
				if weapon.id != resolved.spec.gun[0]: continue
				profiles = {}
				for profile: Dictionary in weapon.profiles:
					profiles[profile.name.to_snake_case()] = Training.Capabilities.weapon(resolved.unit, [weapon.id, profile.name])
		unit.ranged_weapons = [{"id": "primary", "profiles": profiles}]
		var secondary: Array = []
		match source:
			"captain": secondary = ["heavy-bolt-pistol-captain", "Heavy Bolt Pistol"]
			"lieutenant": secondary = ["bolt-pistol-lieutenant", "Bolt Pistol"]
			"heavy-intercessor-squad": secondary = ["bolt-pistol-heavy-intercessor-squad", "Bolt Pistol"]
			"intercessor-squad": secondary = ["bolt-pistol-intercessor-squad", "Bolt Pistol"]
		if not secondary.is_empty():
			var pistol := Training.Capabilities.weapon(resolved.unit, secondary)
			if pistol.is_empty(): return "Missing default pistol for " + source
			if source == "lieutenant": pistol.strength = 5
			unit.ranged_weapons.append({"id": "pistol", "profiles": {"standard": pistol}})
		unit.melee_weapons = [{"id": "melee", "profiles": {"standard": resolved.weapons.blade.duplicate(true)}}]
	if marine_profiles_used:
		state.pack_hash = str(state.get("pack_hash", "")) + ":" + CurrentMarineProfiles.ID + ":" + CurrentMarineProfiles.digest()
	return ""

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "vanguard-veteran-squad"
const ENTRY := "40kdc:11e:adeptus-astartes:" + UNIT

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
		result[owner].entries = []
	result[1].entries = [entry(UNIT, 10)]
	result[2].entries = [entry("intercessor-squad", 5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "", 2: ""}
	}, selections())

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func models_for(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and Abilities.identity(state.units[model]) == UNIT: result.append(model)
	result.sort()
	return result

func find_choice(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value: return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_datasheet_id", "") == "000001154" and profile.get("source_book_id", "") == "000000356" and profile.get("source_snapshot_id", "") == "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z" and profile.get("source_manifest_sha256", "") == "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e" and profile.get("source_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "The Legends profile records its exact Wahapedia 11e source and verified export provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("base_size_source_mm", -1) == 32 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 16.0 / 25.4), "The profile identifies Legends status and exact source-listed 32 mm bases")
	check(profile.get("points_by_models", {}) == {5: 120, 10: 240} and Army.construction_model_sizes(UNIT, profile) == [5, 10] and profile.get("max_supported_copies", 0) == 3, "Only the 5- and 10-model source-priced units are admitted, with the three-copy cap")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Movement, defensive characteristics and Objective Control match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "EXPLOSIVES"] and profile.get("scouts_inches", 0) == 6, "Exact datasheet keywords and Scouts 6 are recorded")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 5)]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 10)]})
	var four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 4)]})
	var eleven := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 11)]})
	check(five.get("error", "").is_empty() and five.get("total", -1) == 120 and ten.get("error", "").is_empty() and ten.get("total", -1) == 240 and not four.get("error", "").is_empty() and not eleven.get("error", "").is_empty(), "Army admission accepts both priced unit sizes and rejects sizes outside the sheet: five=%s ten=%s four=%s eleven=%s" % [str(five), str(ten), str(four), str(eleven)])
	var three_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT, 5), entry(UNIT, 5), entry(UNIT, 5)]})
	var four_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT, 5), entry(UNIT, 5), entry(UNIT, 5), entry(UNIT, 5)]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 360 and not four_copies.get("error", "").is_empty(), "Strike Force admission enforces the standard three-copy limit")
	check(Army.SPECS.get(UNIT, {}).get("source_scope", "") == "Warhammer Legends" and Army.construction_readiness_note(UNIT).contains("competitive events require organiser approval"), "Construction clearly labels the casual-use legality and competitive-event permission condition")
	check(Abilities.RULES.get(UNIT, []) == ["scouts-6", "combat-doctrines", "vanguard-assault-lethal-hits", "storm-shield"], "Scouts, Combat Doctrines, Legends Vanguard Assault and optional Storm Shield are registered separately from the Jump Pack variant")
	var choices_by_loadout := {
		"storm-shield": "storm-shield",
		"grav-pistol": "grav-pistol",
		"hand-flamer": "hand-flamer",
		"inferno-pistol": "inferno-pistol",
		"plasma-pistol": "plasma-pistol"
	}
	var state := fresh()
	check(not state.has("error"), "The current construction catalog materializes Vanguard Veteran Squad against an Intercessor target: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Vanguard Veteran Legends checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT)
	var target := find_squad(state, 2, "intercessor-squad")
	var models := models_for(state, squad)
	check(squad >= 0 and target >= 0 and models.size() == 10, "Both sides materialize and retain the selected 10-model formation")
	if squad < 0 or target < 0 or models.size() != 10:
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	for index: int in choices_by_loadout.size():
		var kind: String = choices_by_loadout.keys()[index]
		var model: int = models[index]
		var selected := find_choice(state, 1, "vanguard-veteran-squad-loadout", model, squad, kind)
		var result := PublicUnitCommand.submit(state, 1, selected, Vector2.ZERO)
		check(not selected.is_empty() and str(result.get("error", "")).is_empty() and state.units[model].get("vanguard_veteran_squad_loadout", "") == kind, "%s is a selectable per-model replacement through the public preparation command" % kind)
	check(state.units[models[0]].ranged_weapons.is_empty() and Groups.profile(state, models[0]).invulnerable_target == 4 and Abilities.sources(state, squad, "storm-shield") == [models[0]], "The selected Storm Shield removes its Bolt Pistol and grants only its bearer a 4+ invulnerable save")
	var restore := find_choice(state, 1, "vanguard-veteran-squad-loadout", models[0], squad, "bolt-pistol")
	var restore_result := PublicUnitCommand.submit(state, 1, restore, Vector2.ZERO)
	check(not restore.is_empty() and str(restore_result.get("error", "")).is_empty() and state.units[models[0]].ranged_weapons[0].id == "bolt-pistol" and Groups.profile(state, models[0]).invulnerable_target == 0 and Abilities.sources(state, squad, "storm-shield").is_empty(), "Restoring the Bolt Pistol removes the shield and its bearer-only save")
	var default_weapons := Profiles.vanguard_veteran_squad_weapons()
	var grav_weapons := Profiles.vanguard_veteran_squad_weapons("grav-pistol")
	var flamer_weapons := Profiles.vanguard_veteran_squad_weapons("hand-flamer")
	var inferno_weapons := Profiles.vanguard_veteran_squad_weapons("inferno-pistol")
	var plasma_weapons := Profiles.vanguard_veteran_squad_weapons("plasma-pistol")
	check(default_weapons.ranged[0].profiles.standard.attacks == 1 and default_weapons.ranged[0].profiles.standard.range_inches == 12 and default_weapons.melee[0].profiles.standard.attacks == 4 and default_weapons.melee[0].profiles.standard.strength == 5 and default_weapons.melee[0].profiles.standard.ap == -2 and default_weapons.melee[0].profiles.standard.damage == 1, "Default Bolt Pistol and Heirloom Weapon match all extracted profiles")
	check(grav_weapons.ranged[0].profiles.standard.attacks == 2 and grav_weapons.ranged[0].profiles.standard.keywords.get("anti-vehicle", 0) == 2 and flamer_weapons.ranged[0].profiles.standard.keywords.get("torrent", false) and flamer_weapons.ranged[0].profiles.standard.range_inches == 9, "Grav-pistol and Hand Flamer retain their special rules and characteristics")
	check(inferno_weapons.ranged[0].profiles.standard.damage == "D3+2" and inferno_weapons.ranged[0].profiles.standard.keywords.get("melta", 0) == 2 and plasma_weapons.ranged[0].profiles.supercharge.keywords.get("hazardous", false) and plasma_weapons.ranged[0].profiles.standard.strength == 7 and plasma_weapons.ranged[0].profiles.supercharge.strength == 8, "Inferno and Plasma Pistol modes match their exported damage, Melta and Hazardous rules")
	state.squads[squad].charged = false
	var melee: Dictionary = state.units[models[5]].melee_weapons[0].profiles.standard
	var before_charge := Abilities.weapon(state, models[5], target, melee, true)
	state.squads[squad].charged = true
	var after_charge := Abilities.weapon(state, models[5], target, melee, true)
	var ranged_after_charge := Abilities.weapon(state, models[5], target, state.units[models[5]].ranged_weapons[0].profiles.standard, false)
	check(not before_charge.keywords.get("lethal-hits", false) and after_charge.keywords.get("lethal-hits", false) and not ranged_after_charge.keywords.get("lethal-hits", false), "The Legends Vanguard Assault grants Lethal Hits only to melee attacks after a Charge move")
	check(Abilities.scout_distance(state, squad) == 6, "The source-listed Scouts 6 ability reaches the shared Scout-move distance resolver")
	print("Vanguard Veteran Legends checks: %d failures" % failures)
	quit(1 if failures else 0)

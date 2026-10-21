extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, action_id: String, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == action_id and (model < 0 or int(option.get("model", -1)) == model): return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("iron-father-feirros")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000127" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Feirros profile uses the local shared-book Wahapedia export")
	check(profile.points == 85 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and profile.base_size_source_mm == 40, "Feirros points, characteristics and base match the extracted model")
	check(profile.ranged[1].profiles.standard.keywords == {"rapid-fire": 2, "sustained-hits": 2} and profile.melee[1].profiles.standard.keywords["extra-attacks"], "Gorgon's Wrath and Medusan Manipuli preserve their source traits")
	check(Catalog.SPECS.get("iron-father-feirros", {}).get("current_reference", false) and Roster.POINTS.get("iron-father-feirros", {}).get("sizes", {}) == {1: 85}, "Feirros is configured for one 85-point model")
	var lists := F.selections()
	lists[1].entries = [entry("captain"), entry("aggressor-squad", 3), entry("heavy-intercessor-squad", 5), entry("eradicator-squad-with-heavy-bolters", 3), entry("eradicator-squad-with-melta-rifles", 3), entry("redemptor-dreadnought")]
	lists[2].entries = [{"definition_id": "40kdc:11e:necrons:immortals", "models": 5, "copies": 1}, {"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Feirros and his source-listed bodyguards materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var feirros := find_model(state, 1, "captain")
	var feirros_squad: int = int(state.units[feirros].squad)
	state.units[feirros].definition_id = "40kdc:11e:adeptus-astartes:iron-father-feirros"
	state.units[feirros].movement = profile.stats.movement_inches
	state.units[feirros].toughness = profile.stats.toughness
	state.units[feirros].save_target = profile.stats.save_target
	state.units[feirros].max_wounds = profile.stats.wounds
	state.units[feirros].wounds = profile.stats.wounds
	state.units[feirros].objective_control = profile.stats.objective_control
	state.units[feirros].invulnerable_target = profile.stats.invulnerable_target
	state.units[feirros].keywords = profile.keywords.duplicate()
	state.units[feirros].ranged_weapons = profile.ranged.duplicate(true)
	state.units[feirros].melee_weapons = profile.melee.duplicate(true)
	state.units[feirros].radius = profile.base_radius_inches
	state.squads[feirros_squad].stats.movement_inches = profile.stats.movement_inches
	state.squads[feirros_squad].stats.toughness = profile.stats.toughness
	state.squads[feirros_squad].stats.save_target = profile.stats.save_target
	state.squads[feirros_squad].stats.wounds_per_model = profile.stats.wounds
	state.squads[feirros_squad].stats.leadership_target = profile.stats.leadership_target
	state.squads[feirros_squad].stats.objective_control = profile.stats.objective_control
	state.squads[feirros_squad].stats.invulnerable_target = profile.stats.invulnerable_target
	C.UnitAbilities.enable(state)
	var aggressors := find_squad(state, 1, "aggressor-squad")
	var heavy_intercessors := find_squad(state, 1, "heavy-intercessor-squad")
	var heavy_bolter_eradicators := find_squad(state, 1, "eradicator-squad-with-heavy-bolters")
	var melta_eradicators := find_squad(state, 1, "eradicator-squad-with-melta-rifles")
	var vehicle := find_model(state, 1, "redemptor-dreadnought")
	check(C.UnitAbilities.has(state, feirros_squad, "feel-no-pain-5") and C.UnitAbilities.has(state, feirros_squad, "master-of-the-forge") and C.UnitAbilities.has(state, feirros_squad, "rites-of-tempering") and C.UnitAbilities.has(state, feirros_squad, "iron-father"), "Feirros abilities register on his unit")
	check(Prevention.rules(state, feirros).any(func(rule: Dictionary) -> bool: return rule.get("target", 0) == 5 and rule.get("against", "") == "any"), "Feirros receives his personal Feel No Pain 5+")
	check(C.UnitActions.attachment_allowed(state, feirros, aggressors) and C.UnitActions.attachment_allowed(state, feirros, heavy_intercessors) and C.UnitActions.attachment_allowed(state, feirros, heavy_bolter_eradicators) and C.UnitActions.attachment_allowed(state, feirros, melta_eradicators), "Feirros can lead each of the four source-listed bodyguards")
	check(not C.UnitActions.attachment_allowed(state, feirros, find_squad(state, 1, "redemptor-dreadnought")), "Feirros cannot lead an unlisted Vehicle")
	check(C.UnitAbilities.defensive_wound_modifier(state, feirros_squad, 7, 6) == -1 and C.UnitAbilities.defensive_wound_modifier(state, feirros_squad, 6, 6) == 0, "Rites of Tempering subtracts 1 only when attacking Strength exceeds Toughness")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	check(not action(state, "warlord", feirros).is_empty(), "Feirros is eligible to be selected as Warlord")
	state.unit_abilities.warlords = {1: feirros}
	state.cp[1] = 0
	state.round = 1
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants Feirros's Warlord CP")
	state.units[feirros].position = Vector2.ZERO
	state.units[vehicle].position = Vector2(2.0, 0)
	check(C.UnitAbilities.lone_operative_active(state, feirros), "Iron Father grants Lone Operative within 3 inches of a friendly Astartes Vehicle")
	state.units[vehicle].position = Vector2(7, 0)
	check(not C.UnitAbilities.lone_operative_active(state, feirros), "Iron Father loses Lone Operative outside 3 inches")
	state.units[vehicle].position = Vector2(2.0, 0)
	C.UnitActions.attach(state, feirros, aggressors)
	check(not C.UnitAbilities.lone_operative_active(state, feirros), "Lone Operative does not protect Feirros while he is part of an Attached unit")
	check(C.UnitAbilities.defensive_wound_modifier(state, aggressors, 7, 6) == -1, "Rites of Tempering protects the attached bodyguard unit")
	state.phase = "movement"
	state.active = 1
	state.squads[aggressors].moved = false
	state.units[vehicle].wounds = 7
	var move_error := C.begin_movement(state, 1, feirros, "normal", state.revision)
	check(move_error.is_empty() and state.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Master of the Forge opens at the start of Feirros's move")
	var defer := action(state, "master-forge-defer")
	check(not defer.is_empty() and C.unit_action(state, 1, defer, Vector2.ZERO, state.revision).is_empty(), "Master of the Forge can be deferred until the end of the move")
	state.pending_move = {}
	state.squads[aggressors].moved = true
	state.squads[aggressors].move_type = "normal"
	C.UnitActions.end_move(state, aggressors)
	var repair := action(state, "master-of-the-forge")
	check(not repair.is_empty() and repair.target == vehicle, "Master of the Forge offers the nearby Astartes Vehicle")
	if not repair.is_empty(): check(C.unit_action(state, 1, repair, Vector2.ZERO, state.revision).is_empty(), "Master of the Forge repair action resolves")
	check(state.units[vehicle].wounds == 10 and Techmarine.modifier_ignore_active(state, vehicle), "Master of the Forge heals a fixed 3 wounds and grants temporary attack-modifier protection")
	state.turn += 2
	check(not Techmarine.modifier_ignore_active(state, vehicle), "Master of the Forge protection ends at the next own Movement phase")
	print("Iron Father Feirros local checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(faction: String, identity: String, count: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:%s:%s" % [faction, identity], "models": count, "copies": 1}

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

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("suboden-khan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004167" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Suboden uses the local shared-book Wahapedia export")
	check(profile.points == 105 and profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4} and profile.base_size_source_mm == [90, 52], "Suboden cost, characteristics and oval base match the source")
	check(profile.ranged[1].profiles.standard.attacks == 8 and profile.ranged[1].profiles.standard.keywords == {"devastating-wounds": true}, "Onslaught Gatling Cannon retains its source profile")
	check(profile.melee[0].profiles.standard.keywords == {"anti-monster": 4, "anti-vehicle": 4, "lance": true} and profile.melee[1].profiles.standard.keywords["extra-attacks"] and profile.melee[1].profiles.standard.target_restricted_traits["sustained-hits"] == ["MONSTER", "VEHICLE"], "Stormtooth and Power Sword source traits are retained")
	check(Catalog.SPECS.get("suboden-khan", {}).get("current_reference", false) and Roster.POINTS.get("suboden-khan", {}).get("sizes", {}) == {1: 105}, "Suboden is admitted at 105 points")
	var lists := F.selections()
	lists[1].entries = [entry("adeptus-astartes", "suboden-khan", 1), entry("adeptus-astartes", "outrider-squad", 3), entry("adeptus-astartes", "intercessor-squad", 5)]
	lists[2].entries = [entry("necrons", "immortals", 5), entry("necrons", "necron-warriors", 10)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Suboden and source-listed units materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "suboden-khan")
	var squad := find_squad(state, 1, "suboden-khan")
	var outriders := find_squad(state, 1, "outrider-squad")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	check(C.UnitAbilities.has(state, squad, "spear-of-chogoris") and C.UnitAbilities.has(state, squad, "skilled-riders") and C.UnitAbilities.has(state, squad, "transhuman-strategist"), "Suboden's named rules register")
	check(C.UnitActions.attachment_allowed(state, model, outriders) and not C.UnitActions.attachment_allowed(state, model, find_squad(state, 1, "intercessor-squad")), "Suboden's Leader link is restricted to Outriders")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var warlord_available := false
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == "warlord" and option.model == model: warlord_available = true
	check(warlord_available, "Suboden is eligible to be selected as Warlord")
	state.unit_abilities.warlords = {1: model}
	state.cp[1] = 0
	state.round = 1
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants Suboden's Warlord CP")
	check(C.UnitAbilities.weapon(state, model, -1, profile.ranged[0].profiles.standard, false).keywords.assault, "Spear of Chogoris grants Assault to Suboden's ranged weapons")
	C.UnitActions.attach(state, model, outriders)
	check(state.units[model].squad == outriders and state.squads[outriders].attached, "Suboden can attach to the Outrider Squad")
	state.units[model].ranged_weapons = profile.ranged.duplicate(true)
	state.units[model].melee_weapons = profile.melee.duplicate(true)
	var outrider := Geometry.alive(state, outriders)[0]
	check(Terrain.mobile_unit(state, outrider), "Skilled Riders grants Mobile to the attached Outrider unit")
	var dense_blockers := 0
	for area: Dictionary in Terrain.areas(state):
		if area.category == "dense": dense_blockers += Terrain.movement_obstacles(state, outrider).filter(func(rect: Rect2) -> bool: return area.features.any(func(feature: Dictionary) -> bool: return feature.bounds == rect)).size()
	check(dense_blockers == 0, "Mobile ignores dense terrain movement obstacles for the attached unit")
	state.phase = "movement"
	state.active = 1
	state.units[model].position = Vector2(0, 0)
	state.combat_doctrines.active.erase(1)
	var advance_error := C.begin_movement(state, 1, model, "advance", state.revision, func() -> int: return 3)
	check(advance_error.is_empty() and state.pending_move.bonus == 3, "Spear gives no Advance modifier outside Assault Doctrine")
	state.squads[outriders].advanced = true
	check(C.Doctrines.charge_error(state, outriders).is_empty(), "Spear of Chogoris permits a charge after Advancing without Assault Doctrine")
	var enemy := find_squad(state, 2, "immortals")
	var enemy_model := Geometry.alive(state, enemy)[0]
	state.units[enemy_model].position = Vector2(8, 0)
	state.phase = "shooting"
	var pistol_id := str(state.units[model].ranged_weapons[0].id)
	var after_advance_targets := AttackPlan.legal_targets(state, model, false, pistol_id, "standard")
	check(enemy in after_advance_targets, "Assault lets Suboden shoot after Advancing")
	state.combat_doctrines.active[1] = "assault"
	check(C.Doctrines.advance_bonus(state, outriders) == 1 and C.Doctrines.charge_bonus(state, outriders) == 1, "Assault Doctrine adds one to Suboden's Advance and Charge rolls")
	var doctrine_state := state.duplicate(true)
	doctrine_state.phase = "movement"
	doctrine_state.units[model].position = Vector2(0, 0)
	doctrine_state.squads[outriders].moved = false
	doctrine_state.squads[outriders].advanced = false
	doctrine_state.pending_move = {}
	var doctrine_advance_error := C.begin_movement(doctrine_state, 1, model, "advance", doctrine_state.revision, func() -> int: return 3)
	check(doctrine_advance_error.is_empty() and doctrine_state.pending_move.bonus == 4, "Assault Doctrine modifier is applied to the actual Advance roll")
	doctrine_state.phase = "charge"
	doctrine_state.pending_move = {}
	doctrine_state.squads[outriders].advanced = true
	var charge_result := C.declare_charge(doctrine_state, 1, model, doctrine_state.revision, func() -> int: return 3)
	check(charge_result.error.is_empty() and doctrine_state.pending_charge.maximum == 7, "Assault Doctrine modifier is applied to the actual Charge roll after Advance")
	var spearpoint_state := state.duplicate(true)
	C.Doctrines.enable(spearpoint_state, "spearpoint-task-force")
	C.DetachmentStratagems.enable_spearpoint(spearpoint_state)
	spearpoint_state.squads[intercessors].advanced = true
	check(C.Doctrines.charge_error(spearpoint_state, intercessors).is_empty(), "Storm-swift Onslaught lets an Adeptus Astartes unit charge after Advancing")
	spearpoint_state.squads[intercessors].advanced = false
	spearpoint_state.squads[intercessors].fell_back = true
	check(C.Doctrines.charge_error(spearpoint_state, intercessors).is_empty(), "Storm-swift Onslaught also lets an Adeptus Astartes unit charge after Falling Back")
	for destroyed_enemy_model: int in Geometry.alive(spearpoint_state, enemy): spearpoint_state.units[destroyed_enemy_model].wounds = 0
	for other_enemy_model: int in spearpoint_state.units:
		if spearpoint_state.units[other_enemy_model].owner == 2 and spearpoint_state.units[other_enemy_model].wounds > 0: spearpoint_state.units[other_enemy_model].position = Vector2(40, 35)
	spearpoint_state.phase = "fight"
	spearpoint_state.active = 2
	C.Doctrines.record_spearpoint_destroyed_unit(spearpoint_state, outriders, enemy)
	var storm_swift_error := TacticalFluidity.start_end_fight(spearpoint_state, 1, outriders)
	check(Geometry.alive(spearpoint_state, enemy).is_empty() and storm_swift_error.is_empty() and spearpoint_state.unit_abilities.window.get("source", "") == "storm-swift-onslaught" and spearpoint_state.unit_abilities.window.get("distance", 0.0) == 6.0, "Wrath of the First Khan opens Suboden's 6-inch Normal Move after his unit destroys an enemy in the Fight phase")
	check(not TacticalFluidity.suboden_squads(spearpoint_state, 1).has(outriders), "Wrath of the First Khan cannot be used twice in the same Fight phase")
	print("Suboden Khan local checks: %d failures" % failures)
	quit(1 if failures else 0)

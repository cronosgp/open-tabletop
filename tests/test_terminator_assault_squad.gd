extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "terminator-assault-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:terminator-assault-squad"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("captain-in-terminator-armour"), entry(UNIT, 5), entry(UNIT, 10)]
	result[2].entries = [entry("intercessor-squad", 10), entry(UNIT, 5), entry(UNIT, 10)]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or A.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func squad_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0:
			result.append(model)
	result.sort()
	return result

func find_choice(state: Dictionary, owner: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.unit_choices(state, owner):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit(state: Dictionary, owner: int, action: String, model: int = -1, target: int = -1, value: String = "", point: Vector2 = Vector2.ZERO) -> String:
	var selected := find_choice(state, owner, action, model, target, value)
	if selected.is_empty(): return "Missing %s choice (model=%d target=%d value=%s)." % [action, model, target, value]
	return str(PublicUnitCommand.submit(state, owner, selected, point).get("error", ""))

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true,
		"combat_doctrines": true,
		"reanimation_protocols": true,
		"awakened_dynasty": true,
		"core_stratagems": true,
		"attack_rerolls": true,
		"manual_allocation": false
	}, lists())
	if state.has("error"):
		return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.phase_key = U.key(state)
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	return state

func check_profile(profile: Dictionary) -> void:
	check(profile.get("name", "") == "Terminator Assault Squad" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000000118" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile identifies the shared-book datasheet and pinned export revision")
	check(profile.get("points_by_models", {}) == {5: 170, 10: 340} and profile.get("third_plus_points_by_models", {}) == {5: 210, 10: 380} and profile.get("wargear_costs", {}) == {"storm-shield": 5}, "Five/ten-model and third-plus prices plus the per-model Storm Shield cost match the source")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "All model characteristics and the 40 mm base match the export")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "DEATHWING", "IMPERIUM", "INFANTRY", "TERMINATOR"], "All exported shared-profile keywords are retained; Deathwing remains chapter-contextual at match setup")
	var claws: Dictionary = profile.get("melee", [])[0].get("profiles", {}).get("standard", {}) if not profile.get("melee", []).is_empty() else {}
	var hammer_rows: Array = profile.get("additional_weapon_profiles", {}).get("melee", [])
	var hammer: Dictionary = hammer_rows[0].get("profiles", {}).get("standard", {}) if not hammer_rows.is_empty() else {}
	check(profile.get("ranged", []).is_empty() and claws == {"name": "Twin Lightning Claws", "range_inches": 0.0, "attacks": 6, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {"twin-linked": true}} and hammer == {"name": "Thunder Hammer", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 3, "keywords": {"devastating-wounds": true}}, "Default Lightning Claws and optional Thunder Hammer stats and traits match the export")

func check_catalog_and_relations() -> void:
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 5, "cost": 170, "third_plus_cost": 210}, {"models": 10, "cost": 340, "third_plus_cost": 380}], "The consolidated runtime catalog offers both compositions and source cost tiers")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {5: 170, 10: 340} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {5: 210, 10: 380}, "Roster pricing uses the same first/second and third-plus source costs")
	var two_copy_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-in-terminator-armour"), entry(UNIT, 5), entry(UNIT, 10)]}
	check(C.RosterValidation.admit(two_copy_roster).get("error", "").is_empty(), "The local Incursion validator admits two source-sized copies")
	two_copy_roster.entries.append(entry(UNIT, 5))
	check(not str(C.RosterValidation.admit(two_copy_roster).get("error", "")).is_empty(), "The local Incursion validator rejects a third non-Battleline copy")
	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader] and not SupportAttachments.BODYGUARDS.has(leader): source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["caanok-var", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "darnath-lysander", "librarian-in-terminator-armour", "marneus-calgar"], "All six common-book Leader links are represented")
	var source_supports: Array[String] = []
	for support: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[support]: source_supports.append(support)
	source_supports.sort()
	check(source_supports == ["ancient-in-terminator-armour"], "The common-book Terminator Ancient Support link is represented")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0) == 2, "Catalog exposes the checked sheet scope and local Incursion copy ceiling")

func check_loadouts_and_weapons(state: Dictionary, five: int, ten: int, enemy: int) -> void:
	var five_models := squad_models(state, five)
	var ten_models := squad_models(state, ten)
	check(five_models.size() == 5 and ten_models.size() == 10, "Both supported unit sizes materialize with exact starting strength")
	if five_models.size() != 5 or ten_models.size() != 10: return
	check(state.squads[five].training_cost == 170 and state.squads[ten].training_cost == 340 and state.squads[find_squad(state, 2, UNIT, 5)].training_cost == 170 and state.squads[find_squad(state, 2, UNIT, 10)].training_cost == 340, "Both current Marine catalogs materialize five/ten models at first-two source prices")
	check(is_equal_approx(float(state.units[five_models[0]].radius), 20.0 / 25.4) and state.units[five_models[0]].wounds == 3 and state.units[five_models[0]].melee_weapons[0].profiles.standard.name == "Twin Lightning Claws", "Default model materializes its source base, wounds and Lightning Claws")
	var invalid := {"action": "terminator-assault-loadout", "model": five_models[0], "target": five, "value": "on"}
	var before := var_to_bytes(state)
	check(not str(PublicUnitCommand.submit(state, 2, invalid).get("error", "")).is_empty() and var_to_bytes(state) == before, "The opposing player cannot change this unit's loadout or cost")
	var captain := -1
	for model: int in state.units:
		if int(state.units[model].owner) == 1 and A.identity(state.units[model]) == "captain-in-terminator-armour": captain = model
	var wrong_model := {"action": "terminator-assault-loadout", "model": captain, "target": five, "value": "on"}
	before = var_to_bytes(state)
	check(not str(PublicUnitCommand.submit(state, 1, wrong_model).get("error", "")).is_empty() and var_to_bytes(state) == before, "A non-Assault Terminator model cannot receive the per-model replacement")
	for model: int in five_models:
		check(submit(state, 1, "terminator-assault-loadout", model, five, "on").is_empty(), "Each five-model Terminator may take a Storm Shield")
	check(state.squads[five].training_cost == 195 and five_models.all(func(model: int) -> bool: return state.units[model].wounds == 4 and state.units[model].max_wounds == 4 and state.units[model].melee_weapons[0].profiles.standard.name == "Thunder Hammer"), "No per-unit replacement cap applies; five Storm Shields add 25 points and one wound per model")
	check(submit(state, 1, "terminator-assault-loadout", five_models[0], five, "off").is_empty() and state.squads[five].training_cost == 190 and state.units[five_models[0]].wounds == 3 and state.units[five_models[0]].melee_weapons[0].profiles.standard.name == "Twin Lightning Claws", "The model's original loadout and five points can be restored")
	for model: int in ten_models:
		check(submit(state, 1, "terminator-assault-loadout", model, ten, "on").is_empty(), "Each ten-model Terminator may take a Storm Shield")
	check(state.squads[ten].training_cost == 390 and ten_models.all(func(model: int) -> bool: return state.units[model].wounds == 4 and state.units[model].melee_weapons[0].profiles.standard.name == "Thunder Hammer"), "The ten-model unit can replace every model and pays all ten per-model costs")
	var claws: Dictionary = Profiles.profile(UNIT).melee[0].profiles.standard
	var hammer: Dictionary = Profiles.profile(UNIT).additional_weapon_profiles.melee[0].profiles.standard
	var issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, {"ranged": [], "melee": [claws]}, five_models[0], enemy)
	check(issues.is_empty(), "Twin Lightning Claws resolve through Equipment and AttackPlan: %s" % str(issues))
	issues = WeaponChecks.fixed_weapon_plan_failures(state, {"ranged": [], "melee": [hammer]}, ten_models[0], enemy)
	check(issues.is_empty(), "Thunder Hammer resolves through Equipment and AttackPlan: %s" % str(issues))

func check_terminatus_assault(state: Dictionary, squad: int, model: int, enemy: int) -> void:
	var claws: Dictionary = Profiles.profile(UNIT).melee[0].profiles.standard
	var hammer: Dictionary = Profiles.profile(UNIT).additional_weapon_profiles.melee[0].profiles.standard
	state.squads[squad].charged = false
	check(A.weapon(state, model, enemy, claws, true).keywords.get("sustained-hits", 0) == 0 and A.weapon(state, model, enemy, hammer, true).keywords.get("sustained-hits", 0) == 0, "Terminatus Assault grants no bonus when the unit did not charge")
	state.squads[squad].charged = true
	for target: int in squad_models(state, enemy): state.units[target].keywords = ["INFANTRY"]
	check(A.weapon(state, model, enemy, claws, true).keywords.get("sustained-hits", 0) == 1, "After a charge, Lightning Claws gain Sustained Hits 1 against non-Monster/Vehicle targets")
	check(A.weapon(state, model, enemy, hammer, true).keywords.get("sustained-hits", 0) == 0, "The charged Thunder Hammer bonus stays off against non-Monster/Vehicle targets")
	for target: int in squad_models(state, enemy): state.units[target].keywords = ["VEHICLE"]
	check(A.weapon(state, model, enemy, hammer, true).keywords.get("sustained-hits", 0) == 1 and A.weapon(state, model, enemy, claws, true).keywords.get("sustained-hits", 0) == 0, "Against a Vehicle, only the charged Thunder Hammer gains Sustained Hits 1")
	for target: int in squad_models(state, enemy): state.units[target].keywords = ["MONSTER"]
	check(A.weapon(state, model, enemy, hammer, true).keywords.get("sustained-hits", 0) == 1 and A.weapon(state, model, enemy, claws, true).keywords.get("sustained-hits", 0) == 0, "The Thunder Hammer condition also covers Monster targets")
	state.squads[squad].charged = false

func check_homer_and_ingress(state: Dictionary, five: int, ten: int, enemy: int) -> void:
	check(A.has(state, five, "deep-strike") and A.has(state, five, "teleport-homer") and A.has(state, five, "terminatus-assault"), "The materialized unit receives all source-listed core and datasheet abilities")
	var five_models := squad_models(state, five)
	var ten_models := squad_models(state, ten)
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = []
	state.phase = "deployment"
	state.unit_abilities.reserves[five] = {"cost": int(state.squads[five].training_cost), "source": "strategic-reserves"}
	for model: int in five_models: state.units[model].on_battlefield = false
	state.phase = "start_turn"
	state.unit_abilities.phase_key = U.key(state)
	var deployment_zones: Dictionary = state.deployment.get("zones", {})
	var enemy_zone: Rect2 = deployment_zones.get(2, Rect2(Vector2(8, 0), Vector2(8, 8)))
	var homer_point := enemy_zone.get_center()
	var homer_error := submit(state, 1, "homer", -1, five, "", homer_point)
	check(U.battle_actor(state) == 1 and homer_error.is_empty(), "At the start of battle, the owner can place a Teleport Homer in the opponent's deployment zone for a reserve Assault Squad: actor=%d error=%s" % [U.battle_actor(state), homer_error])
	check(state.unit_abilities.homers.has(five) and state.unit_abilities.homers[five] == homer_point and find_choice(state, 1, "homer", -1, five).is_empty(), "The token is recorded and cannot be placed a second time for the same unit")
	check(submit(state, 1, "homer", -1, ten, "", Vector2(5.0, 5.0)).is_empty(), "A second unit can independently place its once-per-battle Teleport Homer")
	check(find_choice(state, 2, "homer", -1, ten).is_empty(), "The opponent is not offered another player's Teleport Homer declaration")
	for model: int in state.units:
		if int(state.units[model].owner) == 2: state.units[model].position = Vector2(-18, -12)
	var moving_enemy := squad_models(state, enemy)[0]
	state.units[moving_enemy].position = Vector2(5.0, 5.0)
	check(state.unit_abilities.homers.has(ten), "Entering token range alone does not remove the marker before the move ends")
	U.end_move(state, enemy)
	check(not state.unit_abilities.homers.has(ten) and state.unit_abilities.homers.has(five), "An enemy unit ending its move within one inch removes only that unit's Teleport Homer")
	for model: int in state.units:
		if int(state.units[model].owner) == 2: state.units[model].position = Vector2(-18, -12)
	check(submit(state, 1, "battle-done").is_empty() and submit(state, 2, "battle-done").is_empty(), "Both players finish optional start-of-battle declarations")
	state.phase = "movement"
	state.active = 2
	state.turn = 4
	state.round = 2
	state.cp[1] = 0
	state.unit_abilities.phase_key = U.key(state)
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	var close_error := C.advance_phase(state, 2, state.revision)
	check(close_error.is_empty() and U.pending(state).get("kind", "") == "end", "The opponent's Movement phase opens the normal end-of-phase response window: " + close_error)
	check(U.rapid_ingress_squads(state, 1) == [five] and not find_choice(state, 1, "homer-ingress", -1, five).is_empty(), "The saved Teleport Homer enables the unit's zero-CP Rapid Ingress choice")
	var ingress_error := submit(state, 1, "homer-ingress", -1, five)
	check(ingress_error.is_empty() and state.unit_abilities.window.get("deep_strike", false), "Rapid Ingress recognizes this reserve unit's Deep Strike ability: " + ingress_error)
	var models_in_reserve := squad_models(state, five)
	check(models_in_reserve.size() == 5 and C.living(state, five).is_empty(), "The arriving five-model squad remains in reserve until its placement is confirmed")
	var too_close_error := submit(state, 1, "ingress-place", models_in_reserve[0], five, "", state.units[squad_models(state, enemy)[0]].position)
	check(not too_close_error.is_empty(), "Deep Strike still enforces the more-than-eight-inch enemy clearance")
	for index: int in models_in_reserve.size():
		var model := models_in_reserve[index]
		var point := Vector2(8.0 + float(index % 3) * 1.68, 8.0 + float(index / 3) * 1.68)
		var far_place_error := submit(state, 1, "ingress-place", model, five, "", point)
		check(far_place_error.is_empty(), "A staged model can be placed away from the Teleport Homer: " + far_place_error)
	check(not submit(state, 1, "ingress-confirm").is_empty(), "The unit cannot ingress more than three inches from its Teleport Homer")
	for index: int in models_in_reserve.size():
		var model := models_in_reserve[index]
		var point := homer_point + Vector2(float(index % 3) * 1.68, float(index / 3) * 1.68)
		var close_place_error := submit(state, 1, "ingress-place", model, five, "", point)
		check(close_place_error.is_empty(), "The unit can stage coherent positions within three inches of the token: " + close_place_error)
	check(submit(state, 1, "ingress-confirm").is_empty() and state.cp[1] == 0 and not state.unit_abilities.homers.has(five) and C.living(state, five).size() == 5, "Rapid Ingress via Homer is free, consumes the token and sets up the whole unit")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check_profile(profile)
	check_catalog_and_relations()
	var state := fixture()
	check(not state.has("error"), "Both players materialize from the current Marine catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Terminator Assault Squad local checks: %d failures" % (failures + 1))
		quit(1)
		return
	var five := find_squad(state, 1, UNIT, 5)
	var ten := find_squad(state, 1, UNIT, 10)
	var enemy := find_squad(state, 2, "intercessor-squad", 10)
	check(five > 0 and ten > 0 and enemy > 0, "The five/ten-model profiles and enemy target are present")
	if five <= 0 or ten <= 0 or enemy <= 0:
		print("Terminator Assault Squad local checks: %d failures" % (failures + 1))
		quit(1)
		return
	check_loadouts_and_weapons(state, five, ten, enemy)
	check_terminatus_assault(state, five, squad_models(state, five)[0], enemy)
	check_homer_and_ingress(state, five, ten, enemy)
	print("Terminator Assault Squad local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

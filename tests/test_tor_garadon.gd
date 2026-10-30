extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
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
	var profile := Profiles.profile("tor-garadon")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002473" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Tor Garadon profile cites the local Wahapedia shared-book export")
	check(profile.points == 90 and profile.models == 1 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Tor Garadon profile and points match the extracted datasheet")
	check(profile.ranged[0].id == "artificer-grav-gun" and profile.ranged[0].profiles.standard == {"name": "Artificer Grav-gun", "range_inches": 18.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -1, "damage": 2, "keywords": {"anti-vehicle": 2}} and profile.melee[0].id == "hand-of-defiance" and profile.melee[0].profiles.standard == {"name": "Hand of Defiance", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 12, "ap": -2, "damage": 2, "keywords": {}}, "Default ranged and melee weapons preserve every source value")
	check(Catalog.SPECS.get("tor-garadon", {}).get("current_reference", false) and int(Catalog.SPECS["tor-garadon"].get("max_supported_copies", 0)) == 1, "Tor Garadon is locally selectable and limited to one copy")
	check(Roster.POINTS.get("tor-garadon", {}).get("sizes", {}) == {1: 90}, "Army admission uses the local 90-point cost for one Tor Garadon")
	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("adeptus-astartes", "tor-garadon", 1)]})
	var two_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:tor-garadon", "models": 1, "copies": 2}]})
	check(one_copy.get("error", "").is_empty() and one_copy.get("total", -1) == 90 and not two_copies.get("error", "").is_empty(), "The current construction catalog admits Tor at 90 points and enforces his one-copy limit")

	var lists := F.current_marine_selections()
	lists[1].entries = [entry("adeptus-astartes", "tor-garadon", 1), entry("adeptus-astartes", "heavy-intercessor-squad", 5), entry("adeptus-astartes", "intercessor-squad", 5)]
	lists[2].entries = [entry("adeptus-astartes", "assault-intercessor-squad", 5), entry("adeptus-astartes", "intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Tor Garadon and both current-catalog Marine rosters materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var tor := find_model(state, 1, "tor-garadon")
	var tor_squad := find_squad(state, 1, "tor-garadon")
	var heavy_squad := find_squad(state, 1, "heavy-intercessor-squad")
	var target := find_squad(state, 2, "assault-intercessor-squad")
	var other := find_squad(state, 2, "intercessor-squad")
	check(find_squad(state, 2, "assault-intercessor-squad") >= 0 and find_squad(state, 2, "intercessor-squad") >= 0, "The opposing roster also materializes from the current local Space Marines catalog")
	check(tor >= 0 and C.UnitAbilities.has(state, tor_squad, "leader") and C.UnitAbilities.has(state, tor_squad, "combat-doctrines") and C.UnitAbilities.has(state, tor_squad, "transhuman-strategist") and C.UnitAbilities.has(state, tor_squad, "siege-captain") and C.UnitAbilities.has(state, tor_squad, "signum-array"), "Tor's Leader, army and datasheet abilities register")
	check(C.UnitActions.attachment_allowed(state, tor, heavy_squad), "Tor Garadon can lead Heavy Intercessors")
	var intercessors := C.UnitActions.attachment_allowed(state, tor, find_squad(state, 1, "intercessor-squad"))
	check(not intercessors, "Tor Garadon cannot lead a datasheet outside the extracted Leader list")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var setup_choices := C.UnitActions.choices(state, 1)
	var warlord_choice := false
	for option: Dictionary in setup_choices:
		if option.action == "warlord" and option.model == tor: warlord_choice = true
	check(warlord_choice, "Tor Garadon is eligible to be selected as Warlord")
	state.unit_abilities.warlords = {1: tor}
	state.round = 1
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP when Tor is Warlord")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist awards that Warlord CP only once per battle round")

	state.units[tor].position = Vector2(0, 0)
	for index: int in Geometry.alive(state, target): state.units[index].position = Vector2(8, 0)
	for index: int in Geometry.alive(state, other): state.units[index].position = Vector2(40, 0)
	state.terrain.id = "terrain-11e-v1"
	state.terrain.areas = [{"name": "Test cover", "category": "light", "bounds": Rect2(6, -2, 4, 4), "features": []}]
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.combat_doctrines.selected_turn[1] = 1
	var gun: Dictionary = profile.ranged[0].profiles.standard
	var hand: Dictionary = profile.melee[0].profiles.standard
	for target_model: int in Geometry.alive(state, target): state.units[target_model].keywords.append("VEHICLE")
	var against_vehicle := C.UnitAbilities.weapon(state, tor, target, gun, false)
	var hand_vehicle := C.UnitAbilities.weapon(state, tor, target, hand, true)
	check(against_vehicle.strength == 7 and against_vehicle.ap == -3 and against_vehicle.damage == 4, "Siege Captain gives Tor's ranged attacks +2 Strength, AP and Damage versus VEHICLE")
	check(hand_vehicle.strength == 14 and hand_vehicle.ap == -4 and hand_vehicle.damage == 4, "Siege Captain applies to Tor's melee attacks versus VEHICLE")
	var grav_selection := Equipment.select(state, tor, false, profile.ranged[0].id, "standard")
	var hand_selection := Equipment.select(state, tor, true, profile.melee[0].id, "standard")
	check(grav_selection.get("error", "").is_empty() and grav_selection.stats == gun and hand_selection.get("error", "").is_empty() and hand_selection.stats == hand, "Equipment exposes both fixed source weapons unchanged")
	var tor_attack := AttackPlan.prepare(state, tor_squad, false, [{"model": tor, "target": target, "weapon": profile.ranged[0].id, "profile": "standard", "amount": 1}], false)
	check(tor_attack.error.is_empty() and tor_attack.batches.size() == 1 and tor_attack.batches[0].weapon.strength == 7 and tor_attack.batches[0].weapon.ap == -3 and tor_attack.batches[0].weapon.damage == 4 and tor_attack.batches[0].weapon.keywords.get("anti-vehicle", 0) == 2, "The actual Artificer Grav-gun AttackPlan carries Siege Captain and Anti-Vehicle through resolution")
	var melee_positions := {}
	for member: int in Geometry.alive(state, target): melee_positions[member] = state.units[member].position
	for index in range(Geometry.alive(state, target).size()): state.units[Geometry.alive(state, target)[index]].position = Vector2(1.5, index * 3.0)
	var old_phase: String = str(state.phase)
	state.phase = "fight"
	var hand_attack := AttackPlan.prepare(state, tor_squad, true, [{"model": tor, "target": target, "weapon": profile.melee[0].id, "profile": "standard", "amount": 5}], false)
	check(hand_attack.error.is_empty() and hand_attack.batches.size() == 1 and hand_attack.batches[0].weapon.strength == 14 and hand_attack.batches[0].weapon.ap == -4 and hand_attack.batches[0].weapon.damage == 4, "The actual Hand of Defiance AttackPlan carries Siege Captain into melee")
	state.phase = old_phase
	for member: int in melee_positions: state.units[member].position = melee_positions[member]
	for target_model: int in Geometry.alive(state, target): state.units[target_model].keywords.erase("VEHICLE")
	var normal_target := C.UnitAbilities.weapon(state, tor, target, gun, false)
	check(normal_target.strength == 5 and normal_target.ap == -1 and normal_target.damage == 2, "Siege Captain does not modify attacks against a target without a qualifying keyword")
	state.units[Geometry.alive(state, target)[0]].keywords.append("MONSTER")
	var monster := C.UnitAbilities.weapon(state, tor, target, gun, false)
	check(monster.strength == 7 and monster.ap == -3 and monster.damage == 4, "Siege Captain also applies against MONSTER")
	state.units[Geometry.alive(state, target)[0]].keywords.erase("MONSTER")
	state.units[Geometry.alive(state, target)[0]].keywords.append("FORTIFICATION")
	var fortification := C.UnitAbilities.weapon(state, tor, target, gun, false)
	check(fortification.strength == 7 and fortification.ap == -3 and fortification.damage == 4, "Siege Captain also applies against FORTIFICATION")
	state.units[Geometry.alive(state, target)[0]].keywords.erase("FORTIFICATION")
	var heavy_model := Geometry.alive(state, heavy_squad)[0]
	var heavy_weapon: String = state.units[heavy_model].ranged_weapons[0].id
	var attack := AttackPlan.prepare(state, heavy_squad, false, [{"model": heavy_model, "target": target, "weapon": heavy_weapon, "profile": "standard", "amount": 1}], false)
	check(attack.error.is_empty() and bool(attack.batches[0].context.benefit_of_cover), "The target's terrain normally grants cover against Tor's visible attack")

	var choices := C.UnitActions.signum_array_choices(state, 1)
	var selected: Dictionary = {}
	for option: Dictionary in choices:
		if option.action == "signum-array" and option.model == tor and option.target == target: selected = option
	check(not selected.is_empty(), "Signum Array offers a visible enemy within 18 inches")
	check(C.UnitActions.pending_decision(state).is_empty(), "Signum Array is an immediate Shooting choice in this setup")
	var before_wrong_signum_owner := var_to_bytes(state)
	var wrong_signum_owner := MatchCommands.execute(state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": selected, "revision": state.revision})
	check(not str(wrong_signum_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_signum_owner, "The opponent cannot submit or mutate the immediate Signum Array target choice")
	var signum_result := MatchCommands.execute(state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": selected, "revision": state.revision})
	check(str(signum_result.get("error", "")).is_empty(), "Signum Array applies through the public command to the selected enemy")
	check(C.UnitAbilities.signum_array_active(state, 1, target) and not C.UnitAbilities.signum_array_active(state, 1, other), "The chosen target alone loses cover for this Shooting phase")
	attack = AttackPlan.prepare(state, heavy_squad, false, [{"model": heavy_model, "target": target, "weapon": heavy_weapon, "profile": "standard", "amount": 1}], false)
	check(attack.error.is_empty() and not bool(attack.batches[0].context.benefit_of_cover), "Signum Array removes cover from the attack context")
	choices = C.UnitActions.signum_array_choices(state, 1)
	check(choices.is_empty(), "Signum Array is limited to one use in that Shooting phase")
	state.phase = "fight"
	check(not C.UnitAbilities.signum_array_active(state, 1, target), "Signum Array's cover denial ends with the Shooting phase")

	print("Tor Garadon local checks: %d failures" % failures)
	quit(1 if failures else 0)

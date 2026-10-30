extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0

const EXPECTED_WEAPONS := {
	"bolt-pistol": {"range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"occulus-bolt-carbine": {"range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "ignores-cover": true}},
	"paired-combat-blades": {"range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1}}
}

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:incursor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:captain-in-phobos-armour", "models": 1, "copies": 1}]
	result[2].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 10, "copies": 1}]
	return result

func make_state() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
	return state

func option(state: Dictionary, player: int, action: String, target: int = -999) -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and (target == -999 or item.target == target): return item
	return {}

func submit_action(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Incursor choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, roller)

func check_attack_profile(state: Dictionary, squad: int, model: int, target: int, melee: bool, weapon_id: String) -> void:
	var selected: Dictionary = Equipment.select(state, model, melee, weapon_id, "standard")
	check(selected.get("error", "").is_empty(), "The Incursor model exposes %s to Equipment" % weapon_id)
	if not selected.get("error", "").is_empty(): return
	var expected: Dictionary = EXPECTED_WEAPONS[weapon_id]
	for field in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s matches source %s" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s matches its complete source keyword profile" % weapon_id)
	var previous_phase: String = str(state.phase)
	var previous_position: Vector2 = state.units[model].position
	if melee:
		state.phase = "fight"
		var target_models: Array[int] = C.living(state, target)
		if not target_models.is_empty(): state.units[model].position = state.units[target_models[0]].position
	var amount := int(selected.stats.attacks) if melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
	state.phase = previous_phase
	state.units[model].position = previous_position
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan retains the correct source for %s" % weapon_id)

func find_units(state: Dictionary) -> Dictionary:
	var found := {"incursor": -1, "intercessor": -1, "librarian": -1, "lieutenant": -1, "captain": -1, "enemy": -1, "incursor_model": -1, "attacker": -1}
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		match identity:
			"incursor-squad":
				found.incursor = state.units[model].squad
				if found.incursor_model < 0: found.incursor_model = model
			"intercessor-squad":
				if state.units[model].owner == 1 and found.intercessor < 0:
					found.intercessor = state.units[model].squad
					found.attacker = model
			"librarian-in-phobos-armour": found.librarian = model
			"lieutenant-in-phobos-armour": found.lieutenant = model
			"captain-in-phobos-armour": found.captain = model
		if state.units[model].owner == 2 and found.enemy < 0: found.enemy = state.units[model].squad
	return found

func place_test_units(state: Dictionary, found: Dictionary, enemy_x: float) -> void:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 2:
			unit.position = Vector2(enemy_x, (model % 5 - 2) * 1.4)
		elif unit.squad == found.incursor:
			unit.position = Vector2(-4, (model % 5 - 2) * 1.4)
		elif unit.squad == found.intercessor:
			unit.position = Vector2(-7, (model % 5 - 2) * 1.4)
		else:
			unit.position = Vector2(-12, 6 + float(model % 3) * 1.4)

func _initialize() -> void:
	var profile := Profiles.profile("incursor-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001159" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Incursor Squad is linked to its local Wahapedia source sheet")
	check(profile.models == 5 and profile.base_radius_inches == 16.0 / 25.4 and profile.scouts_inches == 6, "The source 5-model minimum, 32 mm base and Scouts 6 match the profile")
	check(profile.points_by_models == {5: 90, 10: 170} and profile.third_plus_points_by_models == {5: 100, 10: 180} and profile.max_supported_copies == 2, "5/10-model first-two and third-plus costs and the bounded catalog copy limit match the extracted sheet")
	check(profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Incursor characteristics match the local export")
	check(profile.keywords.size() == 6 and "INFANTRY" in profile.keywords and "EXPLOSIVES" in profile.keywords and "SMOKE" in profile.keywords and "PHOBOS" in profile.keywords and "IMPERIUM" in profile.keywords and "ADEPTUS ASTARTES" in profile.keywords, "Incursor fixed and faction keywords match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].id == "bolt-pistol" and profile.ranged[1].id == "occulus-bolt-carbine" and profile.melee.size() == 1 and profile.melee[0].id == "paired-combat-blades", "The fixed three-weapon loadout matches the local export")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:incursor-squad", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:incursor-squad", "models": 10, "copies": 1}]})
	var three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:incursor-squad", "models": 5, "copies": 3}]})
	check(five.error.is_empty() and five.total == 90 and ten.error.is_empty() and ten.total == 170 and not three.error.is_empty(), "5/10 squads use first-two points, with higher third-unit pricing kept outside construction")
	var state := make_state()
	check(not state.has("error"), "Incursor Squad and its test support units materialize")
	if state.has("error"):
		print("Incursor Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find_units(state)
	check(found.incursor >= 0 and found.intercessor >= 0 and found.enemy >= 0 and found.librarian >= 0 and found.lieutenant >= 0 and found.captain >= 0, "Incursor, allied Astartes, linked Leaders and enemy units materialize from the current Marine catalog")
	check(C.UnitAbilities.every_model_has(state, found.incursor, "scouts-6") and C.UnitAbilities.scout_distance(state, found.incursor) == 6, "Every Incursor model grants the six-inch Scout move")
	check(C.UnitAbilities.has(state, found.incursor, "divinator-class-auspexes") and C.UnitAbilities.has(state, found.incursor, "haywire-mine"), "The two datasheet abilities are registered on Incursor Squad")
	check(C.UnitActions.attachment_allowed(state, found.librarian, found.incursor) and C.UnitActions.attachment_allowed(state, found.lieutenant, found.incursor) and C.UnitActions.attachment_allowed(state, found.captain, found.incursor), "All three source-linked Phobos Leader profiles resolve to Incursors")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var reserves := option(state, 1, "reserve", found.incursor)
	check(not reserves.is_empty(), "Scouts permits Incursor Squad to be placed in Strategic Reserves")
	var weapon_state := make_state()
	var weapon_found := find_units(weapon_state)
	place_test_units(weapon_state, weapon_found, 8)
	weapon_state.phase = "shooting"
	weapon_state.active = 1
	for weapon: Dictionary in Profiles.profile("incursor-squad").ranged: check_attack_profile(weapon_state, weapon_found.incursor, weapon_found.incursor_model, weapon_found.enemy, false, str(weapon.id))
	for weapon: Dictionary in Profiles.profile("incursor-squad").melee: check_attack_profile(weapon_state, weapon_found.incursor, weapon_found.incursor_model, weapon_found.enemy, true, str(weapon.id))

	var scan_state := make_state()
	var scan_found := find_units(scan_state)
	place_test_units(scan_state, scan_found, 10)
	scan_state.phase = "shooting"
	scan_state.active = 1
	var entries: Array = C.AttackPlan.single_target(scan_state, scan_found.intercessor, scan_found.enemy, false)
	var declaration := {"kind": "attack", "player": 1, "squad": scan_found.intercessor, "attacker": scan_found.attacker, "entries": entries, "melee": false, "use_lethal": true, "hail_target": -1}
	check(not entries.is_empty(), "The current-catalog Intercessor exposes a ranged attack plan for the Incursor trigger")
	var scan_sources := Incursors._eligible_scanners(scan_state, 1)
	check(not scan_sources.is_empty(), "A living Incursor has a visible enemy within 18 inches: %s" % str(scan_sources))
	var scan_offered := Incursors.offer(scan_state, declaration)
	check(scan_offered, "Selecting a friendly Astartes unit to shoot opens the Incursor response")
	var scan_choice: Dictionary = {}
	for item: Dictionary in C.unit_choices(scan_state, 1):
		if item.action == Incursors.DIVINATOR_WINDOW and item.value == "scan" and item.target == scan_found.enemy: scan_choice = item
	check(not scan_choice.is_empty(), "Divinator offers visible enemy units within 18 inches")
	if not scan_choice.is_empty():
		var scan_before_wrong_owner := var_to_bytes(scan_state)
		var wrong_owner_scan := submit_action(scan_state, 2, scan_choice, func() -> int: return 6)
		check(not str(wrong_owner_scan.get("error", "")).is_empty() and scan_before_wrong_owner == var_to_bytes(scan_state), "The opponent cannot submit or mutate the attacking Incursor's decision")
		var scan_result := submit_action(scan_state, 1, scan_choice, func() -> int: return 6)
		check(str(scan_result.get("error", "")).is_empty() and not scan_state.get("last_attack", {}).is_empty() and Incursors.scanned(scan_state, 1, scan_found.enemy), "Scanning marks the enemy and resumes the selected shooting declaration through the match command")
		var prepared := C.AttackPlan.prepare(scan_state, scan_found.intercessor, false, entries, true)
		check(prepared.error.is_empty() and prepared.batches[0].context.get("hit_reroll", "none") == "ones", "Friendly ranged attacks gain hit rerolls of 1 against a scanned unit")
		check(Incursors._eligible_scanners(scan_state, 1).is_empty(), "The same Incursor unit cannot use Divinator twice in one phase")
	check(not Incursors.offer(scan_state, {"kind": "attack", "player": 1, "squad": scan_found.enemy, "melee": false}), "A non-friendly or non-Astartes shooting selection cannot trigger the scanner")
	var far_scan_state := make_state()
	var far_scan_found := find_units(far_scan_state)
	place_test_units(far_scan_state, far_scan_found, 18)
	far_scan_state.phase = "shooting"
	far_scan_state.active = 1
	check(not Incursors.offer(far_scan_state, {"kind": "attack", "player": 1, "squad": far_scan_found.intercessor, "melee": false}), "Divinator offers no scan when every visible enemy is beyond 18 inches")

	var mine_state := make_state()
	var mine_found := find_units(mine_state)
	place_test_units(mine_state, mine_found, 3)
	mine_state.phase = "shooting"
	mine_state.active = 1
	var mine: Dictionary = option(mine_state, 1, "haywire-mine", mine_found.enemy)
	check(not mine.is_empty(), "Haywire Mine targets a visible enemy within six inches")
	if not mine.is_empty():
		var mine_result := submit_action(mine_state, 1, mine, func() -> int: return 6)
		check(str(mine_result.get("error", "")).is_empty() and mine_state.last_incursor_haywire_mine.damage.expression == "D3" and mine_state.last_incursor_haywire_mine.mortal_wounds == 3, "A successful mine roll deals D3 mortal wounds to a non-Vehicle through the match command")
		var allocation_decision := PendingDecisions.current(mine_state, ["unit-actions"])
		check(allocation_decision.get("priority_player_id", -1) == 2 and allocation_decision.get("legal_options", []).size() == C.unit_choices(mine_state, 2).size() and not allocation_decision.get("legal_options", []).is_empty(), "Haywire Mine exposes mortal allocation as the defender's normalized decision")
		var restored_mine_state: Dictionary = bytes_to_var(var_to_bytes(mine_state))
		check(PendingDecisions.current(restored_mine_state, ["unit-actions"]).get("decision_id", "") == allocation_decision.get("decision_id", ""), "Haywire allocation decision identity survives save/restore")
		mine_state = restored_mine_state
		var before_wrong_owner := var_to_bytes(mine_state)
		var wrong_owner_result := submit_action(mine_state, 1, option(mine_state, 2, "mortal-allocate", mine_found.enemy))
		check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(mine_state) == before_wrong_owner, "The attacker cannot submit or mutate Haywire's defender allocation")
		for index in range(3):
			var allocate: Dictionary = option(mine_state, 2, "mortal-allocate", mine_found.enemy)
			check(not allocate.is_empty(), "The defender can allocate each Haywire mortal wound")
			if not allocate.is_empty(): check(str(submit_action(mine_state, 2, allocate).get("error", "")).is_empty(), "Mortal-wound allocation resolves through the normalized standard prevention flow")
		check(mine_state.last_incursor_haywire_mine.remaining == 0 and mine_state.unit_abilities.window.is_empty(), "Haywire mortal allocation closes when all wounds are resolved")
		check(option(mine_state, 1, "haywire-mine", mine_found.enemy).is_empty(), "Haywire Mine cannot be used twice per battle by the same squad")

	var vehicle_state := make_state()
	var vehicle_found := find_units(vehicle_state)
	place_test_units(vehicle_state, vehicle_found, 3)
	vehicle_state.phase = "shooting"
	vehicle_state.active = 1
	for model: int in C.living(vehicle_state, vehicle_found.enemy):
		if "VEHICLE" not in vehicle_state.units[model].keywords: vehicle_state.units[model].keywords.append("VEHICLE")
	var vehicle_mine: Dictionary = option(vehicle_state, 1, "haywire-mine", vehicle_found.enemy)
	if not vehicle_mine.is_empty(): submit_action(vehicle_state, 1, vehicle_mine, func() -> int: return 6)
	check(not vehicle_mine.is_empty() and vehicle_state.last_incursor_haywire_mine.damage.expression == "2D3" and vehicle_state.last_incursor_haywire_mine.mortal_wounds == 6, "A Vehicle target receives 2D3 mortal wounds on a successful mine roll")
	var failure_state := make_state()
	var failure_found := find_units(failure_state)
	place_test_units(failure_state, failure_found, 3)
	failure_state.phase = "shooting"
	failure_state.active = 1
	var failure_mine: Dictionary = option(failure_state, 1, "haywire-mine", failure_found.enemy)
	if not failure_mine.is_empty(): submit_action(failure_state, 1, failure_mine, func() -> int: return 1)
	check(not failure_mine.is_empty() and failure_state.last_incursor_haywire_mine.activation.value == 1 and failure_state.last_incursor_haywire_mine.mortal_wounds == 0 and option(failure_state, 1, "haywire-mine", failure_found.enemy).is_empty(), "A roll of 1 has no effect and still expends the once-per-battle mine")
	var far_mine_state := make_state()
	var far_mine_found := find_units(far_mine_state)
	place_test_units(far_mine_state, far_mine_found, 4)
	far_mine_state.phase = "shooting"
	far_mine_state.active = 1
	check(option(far_mine_state, 1, "haywire-mine", far_mine_found.enemy).is_empty(), "Haywire Mine is unavailable when the visible target is outside six inches")
	print("Incursor Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:incursor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour", "models": 1, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
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

func find_units(state: Dictionary) -> Dictionary:
	var found := {"incursor": -1, "intercessor": -1, "librarian": -1, "lieutenant": -1, "enemy": -1, "incursor_model": -1, "attacker": -1}
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		match identity:
			"incursor-squad":
				found.incursor = state.units[model].squad
				if found.incursor_model < 0: found.incursor_model = model
			"intercessor-squad":
				found.intercessor = state.units[model].squad
				if found.attacker < 0: found.attacker = model
			"librarian-in-phobos-armour": found.librarian = model
			"lieutenant-in-phobos-armour": found.lieutenant = model
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
	check(profile.points_by_models == {5: 90, 10: 170} and profile.third_plus_points_by_models == {5: 100, 10: 180} and profile.max_supported_copies == 2, "First and second unit costs and the bounded third-plus catalog limit match the extracted sheet")
	check(profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Incursor characteristics match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard.name == "Bolt Pistol" and profile.ranged[1].profiles.standard.name == "Occulus Bolt Carbine" and profile.ranged[1].profiles.standard.keywords == {"assault": true, "ignores-cover": true} and profile.melee[0].profiles.standard.name == "Paired Combat Blades" and profile.melee[0].profiles.standard.keywords == {"sustained-hits": 1}, "Fixed weapons and traits match the local export")
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
	check(found.incursor >= 0 and found.intercessor >= 0 and found.enemy >= 0 and found.librarian >= 0 and found.lieutenant >= 0, "Incursor, allied Astartes, linked leaders and target units materialize")
	check(C.UnitAbilities.every_model_has(state, found.incursor, "scouts-6") and C.UnitAbilities.scout_distance(state, found.incursor) == 6, "Every Incursor model grants the six-inch Scout move")
	check(C.UnitAbilities.has(state, found.incursor, "divinator-class-auspexes") and C.UnitAbilities.has(state, found.incursor, "haywire-mine"), "The two datasheet abilities are registered on Incursor Squad")
	check(C.UnitActions.attachment_allowed(state, found.librarian, found.incursor) and C.UnitActions.attachment_allowed(state, found.lieutenant, found.incursor), "The admitted Phobos Librarian and Lieutenant Leader links resolve to Incursors")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var reserves := option(state, 1, "reserve", found.incursor)
	check(not reserves.is_empty(), "Scouts permits Incursor Squad to be placed in Strategic Reserves")

	var scan_state := make_state()
	var scan_found := find_units(scan_state)
	place_test_units(scan_state, scan_found, 10)
	scan_state.phase = "shooting"
	scan_state.active = 1
	var entries: Array = C.AttackPlan.single_target(scan_state, scan_found.intercessor, scan_found.enemy, false)
	var declaration := {"kind": "attack", "player": 1, "squad": scan_found.intercessor, "attacker": scan_found.attacker, "entries": entries, "melee": false, "use_lethal": true, "hail_target": -1}
	check(not entries.is_empty() and Incursors.offer(scan_state, declaration), "Selecting a friendly Astartes unit to shoot opens the Incursor response")
	var scan_choice: Dictionary = {}
	for item: Dictionary in C.unit_choices(scan_state, 1):
		if item.action == Incursors.DIVINATOR_WINDOW and item.value == "scan" and item.target == scan_found.enemy: scan_choice = item
	check(not scan_choice.is_empty(), "Divinator offers visible enemy units within 18 inches")
	if not scan_choice.is_empty():
		var scan_error := C.unit_action(scan_state, 1, scan_choice, Vector2.ZERO, scan_state.revision, func() -> int: return 6)
		check(scan_error.is_empty() and not scan_state.get("last_attack", {}).is_empty() and Incursors.scanned(scan_state, 1, scan_found.enemy), "Scanning marks the enemy and resumes the selected shooting declaration")
		var prepared := C.AttackPlan.prepare(scan_state, scan_found.intercessor, false, entries, true)
		check(prepared.error.is_empty() and prepared.batches[0].context.get("hit_reroll", "none") == "ones", "Friendly ranged attacks gain hit rerolls of 1 against a scanned unit")
		check(Incursors._eligible_scanners(scan_state, 1).is_empty(), "The same Incursor unit cannot use Divinator twice in one phase")
	check(not Incursors.offer(scan_state, {"kind": "attack", "player": 1, "squad": scan_found.enemy, "melee": false}), "A non-friendly or non-Astartes shooting selection cannot trigger the scanner")

	var mine_state := make_state()
	var mine_found := find_units(mine_state)
	place_test_units(mine_state, mine_found, 3)
	mine_state.phase = "shooting"
	mine_state.active = 1
	var mine: Dictionary = option(mine_state, 1, "haywire-mine", mine_found.enemy)
	check(not mine.is_empty(), "Haywire Mine targets a visible enemy within six inches")
	if not mine.is_empty():
		var mine_error := C.unit_action(mine_state, 1, mine, Vector2.ZERO, mine_state.revision, func() -> int: return 6)
		check(mine_error.is_empty() and mine_state.last_incursor_haywire_mine.damage.expression == "D3" and mine_state.last_incursor_haywire_mine.mortal_wounds == 3, "A successful mine roll deals D3 mortal wounds to a non-Vehicle")
		for index in range(3):
			var allocate: Dictionary = option(mine_state, 2, "mortal-allocate", mine_found.enemy)
			check(not allocate.is_empty(), "The defender can allocate each Haywire mortal wound")
			if not allocate.is_empty(): check(C.unit_action(mine_state, 2, allocate, Vector2.ZERO, mine_state.revision).is_empty(), "Mortal-wound allocation resolves through the standard prevention flow")
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
	if not vehicle_mine.is_empty(): C.unit_action(vehicle_state, 1, vehicle_mine, Vector2.ZERO, vehicle_state.revision, func() -> int: return 6)
	check(not vehicle_mine.is_empty() and vehicle_state.last_incursor_haywire_mine.damage.expression == "2D3" and vehicle_state.last_incursor_haywire_mine.mortal_wounds == 6, "A Vehicle target receives 2D3 mortal wounds on a successful mine roll")
	var failure_state := make_state()
	var failure_found := find_units(failure_state)
	place_test_units(failure_state, failure_found, 3)
	failure_state.phase = "shooting"
	failure_state.active = 1
	var failure_mine: Dictionary = option(failure_state, 1, "haywire-mine", failure_found.enemy)
	if not failure_mine.is_empty(): C.unit_action(failure_state, 1, failure_mine, Vector2.ZERO, failure_state.revision, func() -> int: return 1)
	check(not failure_mine.is_empty() and failure_state.last_incursor_haywire_mine.activation.value == 1 and failure_state.last_incursor_haywire_mine.mortal_wounds == 0 and option(failure_state, 1, "haywire-mine", failure_found.enemy).is_empty(), "A roll of 1 has no effect and still expends the once-per-battle mine")
	print("Incursor Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

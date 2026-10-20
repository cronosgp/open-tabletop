extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(models: int) -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": models, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func make_state(models: int = 5) -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections(models))
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
	return state

func option(state: Dictionary, player: int, action: String, model: int, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and item.model == model and item.value == value: return item
	return {}

func _initialize() -> void:
	var profile := Profiles.profile("scout-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001160" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Scout Squad is linked to its current local Wahapedia sheet")
	check(profile.points_by_models == {5: 65, 10: 120} and profile.stats == {"movement_inches": 6, "toughness": 4, "save_target": 4, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Scout Squad sizes, costs and characteristics match the extracted sheet")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard.name == "Bolt Pistol" and profile.ranged[1].profiles.standard.name == "Boltgun" and profile.melee[0].profiles.standard.name == "Combat Knife", "Every Scout has the extracted fixed loadout")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": 10, "copies": 1}]})
	check(five.error.is_empty() and five.total == 65 and ten.error.is_empty() and ten.total == 120, "Both source model-count options enter the local catalog at Wahapedia points")
	var state := make_state()
	check(not state.has("error"), "Scout Squad and supporting Marines materialize from admitted local profiles")
	if state.has("error"):
		print("Scout Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := -1
	var sergeant := -1
	var scouts: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) != "scout-squad": continue
		squad = state.units[model].squad
		if state.units[model].get("sergeant", false): sergeant = model
		else: scouts.append(model)
	check(squad >= 0 and sergeant >= 0 and scouts.size() == 4, "Five-model formation has one Scout Sergeant and four Scouts")
	check(C.UnitAbilities.every_model_has(state, squad, "scouts-6") and C.UnitAbilities.scout_distance(state, squad) == 6 and C.UnitAbilities.Detection.infiltrators(state, squad), "All Scouts provide Scouts 6 and Infiltrators")
	check(C.UnitAbilities.has(state, squad, "flexible-asset"), "Scout Squad has Flexible Asset")
	state.squads[squad].advanced = true
	check(Actions.eligibility_error(state, squad).is_empty(), "Flexible Asset permits an Advanced Scout unit to start an otherwise eligible action")
	state.squads[squad].advanced = false
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var sniper := option(state, 1, "scout-gun", scouts[0], "sniper-rifle")
	check(not sniper.is_empty() and C.unit_action(state, 1, sniper, Vector2.ZERO, state.revision).is_empty(), "One Scout may replace its Boltgun with a Sniper Rifle")
	check(option(state, 1, "scout-gun", scouts[1], "sniper-rifle").is_empty(), "A five-model squad cannot exceed one Sniper Rifle")
	var heavy := option(state, 1, "scout-gun", scouts[1], "heavy-bolter")
	check(not heavy.is_empty() and C.unit_action(state, 1, heavy, Vector2.ZERO, state.revision).is_empty(), "One Scout may take the Heavy Bolter option")
	check(option(state, 1, "scout-gun", scouts[2], "missile-launcher").is_empty(), "Heavy Bolter and Missile Launcher share one special-weapon slot per five models")
	var shotgun := option(state, 1, "scout-gun", scouts[2], "shotgun")
	check(not shotgun.is_empty() and C.unit_action(state, 1, shotgun, Vector2.ZERO, state.revision).is_empty(), "Any Scout may replace its Boltgun with a Shotgun")
	var sergeant_shotgun := option(state, 1, "scout-gun", sergeant, "shotgun")
	var chainsword := option(state, 1, "scout-blade", sergeant, "chainsword")
	check(not sergeant_shotgun.is_empty() and not chainsword.is_empty(), "Scout Sergeant receives both source-listed individual wargear options")
	if not sergeant_shotgun.is_empty(): check(C.unit_action(state, 1, sergeant_shotgun, Vector2.ZERO, state.revision).is_empty() and state.units[sergeant].ranged_weapons[1].id == "shotgun", "Sergeant Shotgun replaces the Boltgun while retaining its Bolt Pistol")
	chainsword = option(state, 1, "scout-blade", sergeant, "chainsword")
	if not chainsword.is_empty(): check(C.unit_action(state, 1, chainsword, Vector2.ZERO, state.revision).is_empty() and state.units[sergeant].melee_weapons[0].id == "chainsword", "Sergeant Chainsword replaces the Combat Knife")
	var ten_state := make_state(10)
	var ten_squad := -1
	var ten_scouts: Array[int] = []
	for model: int in ten_state.units:
		if C.UnitAbilities.identity(ten_state.units[model]) != "scout-squad": continue
		ten_squad = ten_state.units[model].squad
		if not ten_state.units[model].get("sergeant", false): ten_scouts.append(model)
	ten_state.phase = "deployment"
	ten_state.unit_abilities.setup_players = []
	check(ten_scouts.size() == 9 and ten_squad >= 0, "Ten-model source composition includes one Sergeant and nine Scouts")
	for slot in [0, 1]:
		var sniper_choice := option(ten_state, 1, "scout-gun", ten_scouts[slot], "sniper-rifle")
		if not sniper_choice.is_empty(): C.unit_action(ten_state, 1, sniper_choice, Vector2.ZERO, ten_state.revision)
	check(option(ten_state, 1, "scout-gun", ten_scouts[2], "sniper-rifle").is_empty(), "Ten-model squad may take two Sniper Rifles")

	var attached_state := make_state()
	var librarian := -1
	var attached_scouts := -1
	for model: int in attached_state.units:
		match C.UnitAbilities.identity(attached_state.units[model]):
			"librarian-in-phobos-armour": librarian = model
			"scout-squad": attached_scouts = attached_state.units[model].squad
	check(librarian >= 0 and attached_scouts >= 0 and C.UnitActions.attachment_allowed(attached_state, librarian, attached_scouts), "Phobos Librarian may lead the Scout Squad as linked by its datasheet")
	if librarian >= 0 and attached_scouts >= 0:
		C.UnitActions.attach(attached_state, librarian, attached_scouts)
		check(C.UnitAbilities.every_model_has(attached_state, attached_scouts, "scouts-6") and C.UnitAbilities.scout_distance(attached_state, attached_scouts) == 6 and C.UnitAbilities.Detection.infiltrators(attached_state, attached_scouts), "The attached Scout unit retains all-model Scouts and Infiltrators eligibility")

	var scout_state := make_state()
	var scout := -1
	var positions: Array[int] = []
	for model: int in scout_state.units:
		if C.UnitAbilities.identity(scout_state.units[model]) == "scout-squad":
			scout = scout_state.units[model].squad
			positions.append(model)
		elif scout_state.units[model].owner == 1:
			scout_state.units[model].position = Vector2(7, 0)
		else:
			scout_state.units[model].position = Vector2(20, 0)
	scout_state.board_size = Vector2(43, 44)
	scout_state.deployment = {"zones": {1: Rect2(-21.5, -22, 11, 44), 2: Rect2(10.5, -22, 11, 44)}, "complete": true}
	for index: int in positions: scout_state.units[index].position = Vector2(-16, (positions.find(index) - 2) * 1.3)
	scout_state.phase = "pre_battle"
	scout_state.first_player = 1
	ScoutMoves.begin(scout_state)
	var scout_move: Dictionary = {}
	for item: Dictionary in C.unit_choices(scout_state, 1):
		if item.action == "scout-move": scout_move = item
	check(not scout_move.is_empty(), "Scout Squad enters the pre-battle Scouts sequence")
	if not scout_move.is_empty():
		C.unit_action(scout_state, 1, scout_move, Vector2.ZERO, scout_state.revision)
		var move_ok := true
		for index: int in positions:
			var place: Dictionary = option(scout_state, 1, "scout-place", index)
			if place.is_empty() or not C.unit_action(scout_state, 1, place, Vector2(-10, scout_state.units[index].position.y), scout_state.revision).is_empty(): move_ok = false
		var confirm: Dictionary = {}
		for item: Dictionary in C.unit_choices(scout_state, 1):
			if item.action == "scout-confirm": confirm = item
		check(move_ok and not confirm.is_empty() and C.unit_action(scout_state, 1, confirm, Vector2.ZERO, scout_state.revision).is_empty() and scout_state.phase == "start_turn", "Scout Squad moves up to 6 inches coherently and resolves before turn one")
	print("Scout Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

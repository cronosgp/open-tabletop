extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Scenario = preload("res://scripts/edition_11/combat_scenario.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func queued_die() -> int: return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:librarian", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func make_state() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
		state.unit_abilities.setup_players = []
		state.phase = "deployment"
		var librarian := -1
		var bodyguard := -1
		for model: int in state.units:
			if C.UnitAbilities.identity(state.units[model]) == "librarian": librarian = model
			if C.UnitAbilities.identity(state.units[model]) == "intercessor-squad": bodyguard = state.units[model].squad
		if librarian >= 0 and bodyguard >= 0: C.UnitActions.attach(state, librarian, bodyguard)
	return state

func find_librarian(state: Dictionary) -> int:
	for model: int in state.units:
		if state.units[model].owner == 1 and C.UnitAbilities.identity(state.units[model]) == "librarian": return model
	return -1

func find_bodyguard_squad(state: Dictionary) -> int:
	for model: int in state.units:
		if state.units[model].owner == 1 and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad": return state.units[model].squad
	return -1

func power_choice(state: Dictionary, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, 1):
		if option.action == "librarius-power" and option.value == value: return option
	return {}

func _initialize() -> void:
	var profile := Profiles.profile("librarian")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002266", "Librarian carries the exact local Wahapedia datasheet identity")
	check(profile.points_by_models == {1: 75} and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Librarian points and characteristics match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[1].profiles.focused.attacks == "D3+3" and profile.ranged[1].profiles.witchfire.attacks == "D6", "Both Smite profiles are represented from the local export")
	check(profile.melee[0].profiles.standard.attacks == 4 and profile.melee[0].profiles.standard.strength == 6 and profile.melee[0].profiles.standard.keywords == {"psychic": true}, "Force Weapon profile and Psychic trait match the local export")
	var resolved := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:librarian")
	check(resolved.error.is_empty() and resolved.cost == 75, "Librarian enters the local construction catalog at 75 points after targeted implementation")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:librarian", "models": 1, "copies": 1}]})
	check(admitted.error.is_empty() and admitted.total == 75, "Librarian is selectable at its source cost")
	var state := make_state()
	check(not state.has("error"), "Librarian and Intercessors materialize from current local profiles")
	if state.has("error"):
		print("Current Librarian profile checks: %d failures" % (failures + 1))
		quit(1)
		return
	var librarian := find_librarian(state)
	var squad := find_bodyguard_squad(state)
	check(librarian >= 0 and squad >= 0 and state.squads[squad].get("attached", false), "Librarian leads the selected bodyguard unit")
	var can_be_warlord := false
	for option: Dictionary in C.unit_choices(state, 1):
		if option.action == "warlord" and option.model == librarian: can_be_warlord = true
	check(can_be_warlord, "Librarian Character is eligible to be declared Warlord")
	if librarian < 0 or squad < 0:
		print("Current Librarian profile checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(C.UnitAbilities.has(state, squad, "librarius") and C.UnitAbilities.has(state, squad, "psychic-hood"), "Attached unit receives Librarius and Psychic Hood")
	check(Prevention.rules(state, C.living(state, squad)[0]) == [{"target": 4, "against": "psychic"}], "Psychic Hood applies its 4+ Feel No Pain to the whole unit")
	state.phase = "movement"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.units[C.living(state, squad)[0]].defense = {"invulnerable_target": 3}
	var dome := power_choice(state, "force-dome")
	check(not dome.is_empty(), "Force Dome is offered in the Librarian's Movement phase")
	if not dome.is_empty(): check(C.unit_action(state, 1, dome, Vector2.ZERO, state.revision, queued_die).is_empty(), "Force Dome resolves its psychic roll")
	var librarian_defense := Groups.profile(state, librarian)
	var bodyguard_model := C.living(state, squad)[0]
	var bodyguard_defense := Groups.profile(state, bodyguard_model)
	check(librarian_defense.invulnerable_target == 4 and bodyguard_defense.invulnerable_target == 3, "Force Dome grants 4+ across the unit while preserving a better save")
	check(C.unit_choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "librarius-power").is_empty(), "Librarius level 1 allows only one psychic ability per battle round")
	state.turn = 2
	check(Groups.profile(state, librarian).invulnerable_target == 4 and Groups.profile(state, bodyguard_model).invulnerable_target == 3, "Force Dome lasts through the opponent's turn without worsening a better save")
	state.turn = 3
	check(Groups.profile(state, librarian).invulnerable_target == 0 and Groups.profile(state, bodyguard_model).invulnerable_target == 3, "Force Dome expires at the start of its owner's next turn")
	var dome_one_state := make_state()
	dome_one_state.phase = "movement"
	dome_one_state.active = 1
	var dome_one := power_choice(dome_one_state, "force-dome")
	dice_queue = [1]
	if not dome_one.is_empty(): check(C.unit_action(dome_one_state, 1, dome_one, Vector2.ZERO, dome_one_state.revision, queued_die).is_empty(), "Force Dome resolves when its psychic roll is 1")
	var dome_one_squad := find_bodyguard_squad(dome_one_state)
	check(dome_one_state.squads[dome_one_squad].battle_shocked and Groups.profile(dome_one_state, find_librarian(dome_one_state)).invulnerable_target == 4, "A psychic roll of 1 causes Battle-shock and Force Dome still grants its save")
	var veil_state := make_state()
	veil_state.phase = "movement"
	veil_state.active = 1
	veil_state.turn = 1
	veil_state.round = 1
	var veil_model := find_librarian(veil_state)
	var veil_squad := find_bodyguard_squad(veil_state)
	veil_state.stratagems.movement_rerolls = true
	veil_state.cp[1] = 2
	var veil := power_choice(veil_state, "veil-of-time")
	check(not veil.is_empty(), "Veil of Time is offered before an eligible Advance")
	dice_queue = [6]
	if not veil.is_empty(): check(C.unit_action(veil_state, 1, veil, Vector2.ZERO, veil_state.revision, queued_die).is_empty(), "Veil of Time resolves its psychic roll")
	check(not veil_state.squads[veil_squad].battle_shocked and veil_state.unit_abilities.veil_of_time_pending.has(veil_squad), "Veil arms the Advance replacement on a successful psychic roll")
	dice_queue = [2]
	var movement_error := Scenario.begin_movement(veil_state, 1, veil_model, "advance", veil_state.revision, queued_die)
	if not movement_error.is_empty(): check(false, "Veil of Time Advance starts: " + movement_error)
	check(veil_state.get("stratagems", {}).get("pending", {}).get("kind", "") == "after_advance_roll", "The ordinary Advance reroll window resolves before Veil replaces the result")
	if veil_state.get("stratagems", {}).get("pending", {}).get("kind", "") == "after_advance_roll":
		var accepted := Scenario.resolve_roll_reaction(veil_state, 1, veil_squad, "", veil_state.revision)
		check(accepted.is_empty() and veil_state.pending_move.bonus == 6, "Veil changes the final Advance to 6 after its roll window")
	else:
		check(veil_state.pending_move.bonus == 6, "Veil replaces a rolled 2 with an Advance of 6")
	check(not veil_state.squads[veil_squad].battle_shocked, "A psychic roll above 1 does not Battle-shock the Veil unit")
	var veil_one_state := make_state()
	veil_one_state.phase = "movement"
	veil_one_state.active = 1
	var veil_one_squad := find_bodyguard_squad(veil_one_state)
	var veil_one := power_choice(veil_one_state, "veil-of-time")
	dice_queue = [1]
	if not veil_one.is_empty(): check(C.unit_action(veil_one_state, 1, veil_one, Vector2.ZERO, veil_one_state.revision, queued_die).is_empty(), "Veil of Time resolves its psychic roll of 1")
	check(veil_one_state.squads[veil_one_squad].battle_shocked and veil_one_state.unit_abilities.veil_of_time_pending.has(veil_one_squad), "A psychic roll of 1 Battle-shocks the unit and still arms the Advance replacement")
	print("Current Librarian profile checks: %d failures" % failures)
	quit(1 if failures else 0)

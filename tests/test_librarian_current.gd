extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Scenario = preload("res://scripts/edition_11/combat_scenario.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func queued_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner: continue
		var members: Array[int] = Geometry.alive(state, squad)
		for model: int in members:
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, action_id: String, value: String = "", target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == action_id and (value.is_empty() or option.value == value) \
			and (target < 0 or int(option.get("target", -1)) == target):
			return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": selected, "revision": int(state.revision)}, Callable(self, "queued_die"))

func selections(bodyguards: Array = ["assault-intercessor-squad", "desolation-squad", "hellblaster-squad", "infernus-squad", "intercessor-squad"]) -> Dictionary:
	var lists := F.current_marine_selections()
	lists[1].entries = [entry("librarian")]
	for identity: String in bodyguards: lists[1].entries.append(entry(identity, 5))
	lists[2].entries = [entry("captain"), entry("assault-intercessor-squad", 5), entry("intercessor-squad", 5)]
	return lists

func make_state(bodyguards: Array = ["assault-intercessor-squad", "desolation-squad", "hellblaster-squad", "infernus-squad", "intercessor-squad"]) -> Dictionary:
	var lists := selections(bodyguards)
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false,
		"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true,
		"manual_allocation": false}, lists)
	if state.has("error"): return state
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var librarian := find_model(state, 1, "librarian")
	var bodyguard_identity := str(bodyguards[0]) if not bodyguards.is_empty() else ""
	var bodyguard := find_squad(state, 1, bodyguard_identity)
	if librarian < 0 or bodyguard < 0: return {"error": "Current-catalog Librarian/bodyguard materialization failed."}
	C.UnitActions.attach(state, librarian, bodyguard)
	return state

func psychic_choice(state: Dictionary, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == "librarius-power" and option.value == value: return option
	return {}

func run() -> void:
	var profile := Profiles.profile("librarian")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002266"
		and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Librarian profile identifies the local shared-book Wahapedia datasheet")
	check(profile.points == 75 and profile.points_by_models == {1: 75} and profile.models == 1
		and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4)
		and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"Librarian source cost, base and characteristics match the export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "TACTICUS", "PSYKER", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES"]
		and profile.get("additional_weapon_profiles", {}).is_empty(), "Librarian source keywords and no-option fixed loadout are represented")
	check(profile.ranged.size() == 2 and profile.ranged[0].id == "bolt-pistol" and profile.ranged[1].id == "smite"
		and profile.melee.size() == 1 and profile.melee[0].id == "force-weapon", "Librarian source loadout has Bolt Pistol, Smite and Force Weapon")
	check(profile.ranged[1].profiles.focused.attacks == "D3+3" and profile.ranged[1].profiles.focused.skill == 3
		and profile.ranged[1].profiles.focused.strength == 6 and profile.ranged[1].profiles.focused.ap == -2
		and profile.ranged[1].profiles.focused.damage == 2
		and profile.ranged[1].profiles.focused.keywords == {"devastating-wounds": true, "psychic": true, "hazardous": true},
		"Focused Witchfire preserves the exported Smite profile")
	check(profile.ranged[1].profiles.witchfire.attacks == "D6" and profile.ranged[1].profiles.witchfire.skill == 3
		and profile.ranged[1].profiles.witchfire.strength == 6 and profile.ranged[1].profiles.witchfire.ap == -1
		and profile.ranged[1].profiles.witchfire.damage == 2 and profile.ranged[1].profiles.witchfire.keywords == {"psychic": true},
		"Witchfire preserves the exported Smite profile")
	check(profile.melee[0].profiles.standard.attacks == 4 and profile.melee[0].profiles.standard.skill == 3
		and profile.melee[0].profiles.standard.strength == 6 and profile.melee[0].profiles.standard.ap == -2
		and profile.melee[0].profiles.standard.damage == 2 and profile.melee[0].profiles.standard.keywords == {"psychic": true},
		"Force Weapon matches the exported profile")
	var identity := "40kdc:11e:adeptus-astartes:librarian"
	var catalog_choice := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(Catalog.SPECS.get("librarian", {}).get("current_reference", false)
		and catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0].get("models", 0) == 1
		and catalog_choice.options[0].get("cost", 0) == 75, "Consolidated catalog publishes the Librarian's fixed cost")
	check(Catalog.resolve("Space Marines", identity).get("error", "").is_empty(), "Librarian resolves through the current-reference catalog")
	var lone_list := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [entry("librarian")]}
	var admitted := Catalog.admit(lone_list)
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", 0)) == 75,
		"A legal Librarian-only selection is admitted at source cost")

	var state := make_state()
	check(not state.has("error"), "Librarian and both current Marine rosters materialize from the consolidated catalog")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var librarian := find_model(state, 1, "librarian")
	var squad: int = int(state.units[librarian].squad)
	var enemy := find_squad(state, 2, "intercessor-squad")
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, librarian, enemy):
		check(false, "Librarian source weapon plan: " + failure)
	var linked_identities := ["assault-intercessor-squad", "desolation-squad", "hellblaster-squad",
		"infernus-squad", "intercessor-squad"]
	for linked_identity: String in linked_identities:
		var target := find_squad(state, 1, linked_identity)
		var linked := target >= 0 and (target == squad and bool(state.squads[target].get("attached", false))
			or C.UnitActions.attachment_allowed(state, librarian, target))
		check(linked,
			"Librarian cannot lead source-listed bodyguard: " + linked_identity)
	var final_link_state := make_state(["sternguard-veteran-squad", "heavy-intercessor-squad"])
	check(not final_link_state.has("error"), "Sternguard and the unlisted comparison bodyguard materialize")
	if final_link_state.has("error"):
		print(final_link_state)
		quit(1)
		return
	var final_librarian := find_model(final_link_state, 1, "librarian")
	var sternguard := find_squad(final_link_state, 1, "sternguard-veteran-squad")
	var unlisted := find_squad(final_link_state, 1, "heavy-intercessor-squad")
	check(bool(final_link_state.squads[sternguard].get("attached", false)), "Librarian accepts its source-listed Sternguard target")
	check(not C.UnitActions.attachment_allowed(final_link_state, final_librarian, unlisted), "Librarian rejects the unlisted Heavy Intercessor bodyguard")
	check(C.UnitAbilities.has(state, squad, "leader") and C.UnitAbilities.has(state, squad, "combat-doctrines")
		and C.UnitAbilities.has(state, squad, "librarius") and C.UnitAbilities.has(state, squad, "psychic-hood"),
		"Attached unit receives Leader, Combat Doctrines, Librarius and Psychic Hood")
	var attached_models: Array[int] = Geometry.alive(state, squad)
	check(not attached_models.is_empty(), "Librarian's attached unit has living models")
	for model: int in attached_models:
		check(Prevention.rules(state, model).has({"target": 4, "against": "psychic"}),
			"Psychic Hood's Feel No Pain does not protect attached model %d" % model)
	dice_queue = [4, 4]
	var psychic_prevention := C.Attacks.Prevention.resolve(1, 5, Prevention.rules(state, librarian), "normal", Callable(self, "queued_die"), "psychic")
	var ordinary_prevention := C.Attacks.Prevention.resolve(1, 5, Prevention.rules(state, librarian), "normal", Callable(self, "queued_die"))
	check(psychic_prevention.lost == 0 and ordinary_prevention.lost == 1,
		"Psychic Hood prevents psychic damage but does not protect against ordinary damage")

	var warlord_state := make_state()
	var warlord_model := find_model(warlord_state, 1, "librarian")
	warlord_state.unit_abilities.setup_players = [2]
	var eligible_warlord := false
	for option: Dictionary in C.UnitActions.choices(warlord_state, 1):
		if option.action == "warlord" and int(option.model) == warlord_model: eligible_warlord = true
	check(eligible_warlord, "Librarian Character is eligible to be declared Warlord")

	state.phase = "movement"
	state.active = 1
	state.turn = 1
	state.round = 1
	var better_save_model := -1
	var protected_bodyguard := -1
	for model: int in attached_models:
		if model == librarian: continue
		if better_save_model < 0: better_save_model = model
		elif protected_bodyguard < 0: protected_bodyguard = model
	state.units[better_save_model].defense = {"invulnerable_target": 3}
	var dome := psychic_choice(state, "force-dome")
	check(not dome.is_empty(), "Force Dome is offered in the Movement phase")
	if not dome.is_empty():
		var before_wrong_dome_owner := var_to_bytes(state)
		var wrong_dome_owner := submit_choice(state, 2, dome)
		check(not str(wrong_dome_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_dome_owner,
			"The opponent cannot submit or mutate Force Dome")
		dice_queue = [6]
		var dome_result := submit_choice(state, 1, dome)
		check(str(dome_result.get("error", "")).is_empty(), "Force Dome resolves through the common match command")
	var librarian_defense := Groups.profile(state, librarian)
	var better_bodyguard_defense := Groups.profile(state, better_save_model)
	var protected_bodyguard_defense := Groups.profile(state, protected_bodyguard)
	check(librarian_defense.invulnerable_target == 4 and protected_bodyguard_defense.invulnerable_target == 4,
		"Force Dome grants a 4+ invulnerable save to the entire unit")
	check(better_bodyguard_defense.invulnerable_target == 3, "Force Dome preserves a better existing invulnerable save")
	check(C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "librarius-power").is_empty(),
		"Librarius level 1 allows only one psychic ability per battle round")
	state.turn = 2
	check(Groups.profile(state, librarian).invulnerable_target == 4 and Groups.profile(state, attached_models[0]).invulnerable_target == 3,
		"Force Dome lasts through the opponent's turn")
	state.turn = 3
	check(Groups.profile(state, librarian).invulnerable_target == 0 and Groups.profile(state, attached_models[0]).invulnerable_target == 3,
		"Force Dome expires at the start of its owner's next turn")

	var dome_one_state := make_state()
	dome_one_state.phase = "movement"
	dome_one_state.active = 1
	dome_one_state.turn = 1
	var dome_one := psychic_choice(dome_one_state, "force-dome")
	dice_queue = [1]
	if not dome_one.is_empty():
		check(str(submit_choice(dome_one_state, 1, dome_one).get("error", "")).is_empty(), "Force Dome resolves on psychic roll 1")
	var dome_one_squad: int = int(dome_one_state.units[find_model(dome_one_state, 1, "librarian")].squad)
	check(dome_one_state.squads[dome_one_squad].battle_shocked
		and Groups.profile(dome_one_state, find_model(dome_one_state, 1, "librarian")).invulnerable_target == 4,
		"A psychic roll of 1 Battle-shocks the unit and Force Dome still grants its save")

	var veil_state := make_state()
	veil_state.phase = "movement"
	veil_state.active = 1
	veil_state.turn = 1
	veil_state.round = 1
	var veil_model := find_model(veil_state, 1, "librarian")
	var veil_squad: int = int(veil_state.units[veil_model].squad)
	veil_state.stratagems.movement_rerolls = true
	veil_state.cp[1] = 2
	var veil := psychic_choice(veil_state, "veil-of-time")
	check(not veil.is_empty(), "Veil of Time is offered before an eligible Advance")
	dice_queue = [6]
	if not veil.is_empty():
		check(str(submit_choice(veil_state, 1, veil).get("error", "")).is_empty(), "Veil of Time resolves through the common match command")
	check(not veil_state.squads[veil_squad].battle_shocked and veil_state.unit_abilities.veil_of_time_pending.has(veil_squad),
		"Successful Veil psychic test arms the Advance replacement")
	dice_queue = [2]
	var movement_error := Scenario.begin_movement(veil_state, 1, veil_model, "advance", veil_state.revision, Callable(self, "queued_die"))
	check(movement_error.is_empty(), "Veil of Time Advance starts: " + movement_error)
	check(veil_state.get("stratagems", {}).get("pending", {}).get("kind", "") == "after_advance_roll",
		"Ordinary Advance re-roll window resolves before Veil changes the final result")
	if veil_state.get("stratagems", {}).get("pending", {}).get("kind", "") == "after_advance_roll":
		var accepted := Scenario.resolve_roll_reaction(veil_state, 1, veil_squad, "", veil_state.revision)
		check(accepted.is_empty() and veil_state.pending_move.bonus == 6, "Veil changes the Advance to 6 after the re-roll decision")
	else:
		check(veil_state.pending_move.bonus == 6, "Veil replaces the rolled Advance result with 6")
	check(not veil_state.squads[veil_squad].battle_shocked, "A successful psychic test does not Battle-shock the Veil unit")
	var veil_one_state := make_state()
	veil_one_state.phase = "movement"
	veil_one_state.active = 1
	var veil_one_squad: int = int(veil_one_state.units[find_model(veil_one_state, 1, "librarian")].squad)
	var veil_one := psychic_choice(veil_one_state, "veil-of-time")
	dice_queue = [1]
	if not veil_one.is_empty():
		check(str(submit_choice(veil_one_state, 1, veil_one).get("error", "")).is_empty(), "Veil of Time resolves on psychic roll 1")
	check(veil_one_state.squads[veil_one_squad].battle_shocked and veil_one_state.unit_abilities.veil_of_time_pending.has(veil_one_squad),
		"A psychic roll of 1 Battle-shocks the unit and still arms Veil's Advance replacement")

	print("Current Librarian source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

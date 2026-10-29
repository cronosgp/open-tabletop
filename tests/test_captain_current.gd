extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(name: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": copies}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.owner) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		var alive: Array[int] = Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func by_action(options: Array, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty():
		return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": selected}, func() -> int: return 6)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": payload}, func() -> int: return 6)

func choose(state: Dictionary, player: int, action: String, target: int, model: int, value: String) -> Dictionary:
	var option := by_action(C.UnitActions.choices(state, player), action, target, model, value)
	if option.is_empty(): return {"error": "Missing choice: %s/%s" % [action, value]}
	return submit_projected_choice(state, player, option)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("captain")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000073" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Current Captain is keyed to the Wahapedia shared-book datasheet")
	check(profile.name == "Captain" and profile.points_by_models == {1: 90} and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Captain characteristics, base-profile cost and saves match the extraction")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"] and is_equal_approx(float(profile.base_radius_inches), 20.0 / 25.4), "Captain source keywords and 40 mm base are represented")
	var default_package := Profiles.captain_weapons()
	check(profile.ranged == default_package.ranged and profile.melee == default_package.melee and profile.ranged[1].profiles.standard.keywords == {"assault": true, "rapid-fire": 1} and profile.melee[0].profiles.standard.attacks == 6, "Default weapons preserve the Master-crafted Bolter and Power Weapon profiles")
	check(Catalog.SPECS["captain"].get("current_reference", false) and Roster.POINTS.get("captain", {}).get("sizes", {}) == {1: 90}, "Captain is selectable through the current local catalog at the source cost")
	var two_incursion_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain", 1, 2)]})
	var three_incursion_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain", 1, 3)]})
	var three_strike_force_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain", 1, 3)]})
	var four_strike_force_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain", 1, 4)]})
	check(two_incursion_copies.get("error", "").is_empty() and int(two_incursion_copies.get("total", -1)) == 180 and not str(three_incursion_copies.get("error", "")).is_empty(), "Incursion applies the two-copy non-Battleline limit")
	check(three_strike_force_copies.get("error", "").is_empty() and int(three_strike_force_copies.get("total", -1)) == 270 and not str(four_strike_force_copies.get("error", "")).is_empty(), "Strike Force applies Captain's three-copy ceiling")

	var expected_targets := ["company-heroes", "intercessor-squad", "assault-intercessor-squad", "infernus-squad", "hellblaster-squad", "desolation-squad", "bladeguard-veteran-squad", "victrix-honour-guard", "sternguard-veteran-squad"]
	var source_targets: Array = MarineLinks.TARGETS.get("captain", []).duplicate()
	source_targets.sort()
	expected_targets.sort()
	check(source_targets == expected_targets, "Captain Leader map matches the nine common-book source targets")

	var lists := F.current_marine_selections()
	lists[1].category = "custom"
	lists[2].category = "custom"
	lists[1].points_limit = 3000
	lists[2].points_limit = 3000
	lists[1].entries = [
		entry("captain"), entry("company-heroes", 4), entry("intercessor-squad", 5),
		entry("assault-intercessor-squad", 5), entry("infernus-squad", 5),
		entry("heavy-intercessor-squad", 5)
	]
	lists[2].entries = [entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Both players materialize from current local Space Marines catalogs: " + materialization_error)
	if not materialization_error.is_empty():
		print(materialization_error)
		quit(1)
		return
	var captain := find_model(state, 1, "captain")
	var captain_squad: int = state.units[captain].squad if captain >= 0 else -1
	var enemy_squad := find_squad(state, 2, "intercessor-squad")
	check(captain >= 0 and captain_squad >= 0 and enemy_squad >= 0, "Captain and both current-catalog rosters materialize")
	if captain < 0 or captain_squad < 0 or enemy_squad < 0:
		quit(1)
		return
	for identity: String in ["company-heroes", "intercessor-squad", "assault-intercessor-squad", "infernus-squad"]:
		var target_squad := find_squad(state, 1, identity)
		check(target_squad >= 0 and C.UnitActions.attachment_allowed(state, captain, target_squad), "Captain can lead source-listed %s" % identity)
	check(not C.UnitActions.attachment_allowed(state, captain, find_squad(state, 1, "heavy-intercessor-squad")), "Captain cannot lead the unlisted Heavy Intercessor Squad")
	for ability: String in ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist"]:
		check(C.UnitAbilities.has(state, captain_squad, ability), "Captain has source-listed %s" % ability)
	check(state.units[captain].ranged_weapons.size() == 2 and state.units[captain].max_wounds == 5, "Default Captain loadout has both ranged weapons and five wounds")

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var options := C.UnitActions.choices(state, 1)
	check(not by_action(options, "warlord", -1, captain).is_empty(), "Captain is offered for Warlord designation")
	var loadout_decision := PendingDecisions.current(state, ["unit-actions"])
	var neo_choice := by_action(options, "captain-ranged-loadout", captain_squad, captain, "neo-volkite")
	var before_rejections := var_to_bytes(state)
	var wrong_owner := submit_projected_choice(state, 2, neo_choice)
	var stale_choice := submit_projected_choice(state, 1, neo_choice, str(loadout_decision.get("decision_id", "")), "stale-option")
	check(not str(wrong_owner.get("error", "")).is_empty() and not str(stale_choice.get("error", "")).is_empty() and before_rejections == var_to_bytes(state), "Wrong-owner and stale Captain choices are rejected without mutation")

	var combinations: Array[Dictionary] = [
		{"ranged": "default", "fist": false}, {"ranged": "default", "fist": true},
		{"ranged": "neo-volkite", "fist": false}, {"ranged": "neo-volkite", "fist": true},
		{"ranged": "plasma-pistol", "fist": false}, {"ranged": "plasma-pistol", "fist": true},
		{"ranged": "relic-shield", "fist": false}
	]
	var weapon_failures: Array[String] = []
	for combination: Dictionary in combinations:
		var ranged: String = str(combination.ranged)
		var fist: bool = bool(combination.fist)
		var local_state: Dictionary = state.duplicate(true)
		if ranged != "default":
			var ranged_result := choose(local_state, 1, "captain-ranged-loadout", captain_squad, captain, ranged)
			check(str(ranged_result.get("error", "")).is_empty(), "Captain ranged choice %s is selectable" % ranged)
		if fist:
			var fist_result := choose(local_state, 1, "captain-melee-loadout", captain_squad, captain, "power-fist")
			check(str(fist_result.get("error", "")).is_empty(), "Captain Power Fist replacement is selectable with %s" % ranged)
		var package := Profiles.captain_weapons(ranged, fist)
		check(not package.is_empty() and local_state.units[captain].ranged_weapons == package.ranged and local_state.units[captain].melee_weapons == package.melee, "Public choices equip the exact %s / %s package" % [ranged, "Power Fist" if fist else "Power Weapon"])
		var current_choices := C.UnitActions.choices(local_state, 1)
		if ranged == "relic-shield":
			check(by_action(current_choices, "captain-melee-loadout", captain_squad, captain, "power-fist").is_empty(), "Relic Shield prevents the Power Fist replacement choice")
		if fist:
			check(by_action(current_choices, "captain-ranged-loadout", captain_squad, captain, "relic-shield").is_empty(), "Power Fist prevents the Relic Shield choice")
			var invalid_shield := {"action": "captain-ranged-loadout", "model": captain, "target": captain_squad, "value": "relic-shield"}
			var before_invalid := var_to_bytes(local_state)
			var rejected_shield := submit_projected_choice(local_state, 1, invalid_shield)
			check(not str(rejected_shield.get("error", "")).is_empty() and before_invalid == var_to_bytes(local_state), "Forged Shield plus Power Fist choice is rejected unchanged")
		if ranged == "relic-shield":
			var invalid_fist := {"action": "captain-melee-loadout", "model": captain, "target": captain_squad, "value": "power-fist"}
			var before_invalid_fist := var_to_bytes(local_state)
			var rejected_fist := submit_projected_choice(local_state, 1, invalid_fist)
			check(not str(rejected_fist.get("error", "")).is_empty() and before_invalid_fist == var_to_bytes(local_state), "Forged Power Fist with Relic Shield choice is rejected unchanged")
		for model: int in local_state.units:
			local_state.units[model].on_battlefield = true
			local_state.units[model].position = Vector2(-14, 14) if int(local_state.units[model].owner) == 1 else Vector2(14, 14)
		weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(local_state, package, captain, enemy_squad))
	check(Profiles.captain_weapons("relic-shield", true).is_empty(), "Profile builder rejects the unsupported Shield plus Fist combination")
	check(weapon_failures.is_empty(), "Every legal Captain weapon profile passes Equipment and AttackPlan: %s" % str(weapon_failures))
	var shield_state: Dictionary = state.duplicate(true)
	var shield_result := choose(shield_state, 1, "captain-ranged-loadout", captain_squad, captain, "relic-shield")
	check(str(shield_result.get("error", "")).is_empty() and shield_state.units[captain].max_wounds == 6 and shield_state.units[captain].wounds == 6 and C.UnitAbilities.has(shield_state, captain_squad, "relic-shield"), "Relic Shield grants the bearer its source-listed extra wound")
	var restore_result := choose(shield_state, 1, "captain-ranged-loadout", captain_squad, captain, "default")
	check(str(restore_result.get("error", "")).is_empty() and shield_state.units[captain].max_wounds == 5 and not C.UnitAbilities.has(shield_state, captain_squad, "relic-shield"), "Restoring ranged weapons removes Relic Shield and its extra wound")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	options = C.UnitActions.choices(state, 1)
	var acumen := by_action(options, "acumen", captain_squad, captain, "assault")
	var before_wrong_doctrine_owner := var_to_bytes(state)
	var wrong_doctrine_owner := submit_projected_choice(state, 2, acumen) if not acumen.is_empty() else {"error": "missing Strategic Acumen option"}
	check(not str(wrong_doctrine_owner.get("error", "")).is_empty() and before_wrong_doctrine_owner == var_to_bytes(state), "Opponent cannot choose the Captain's Strategic Acumen doctrine")
	var doctrine_result := submit_projected_choice(state, 1, acumen) if not acumen.is_empty() else {"error": "missing Strategic Acumen option"}
	check(not acumen.is_empty() and str(doctrine_result.get("error", "")).is_empty() and C.Doctrines.active_for(state, captain_squad) == "assault", "Strategic Acumen selects an active Combat Doctrine")
	check(by_action(C.UnitActions.choices(state, 1), "acumen", captain_squad, captain, "tactical").is_empty(), "Strategic Acumen cannot be used twice in the same Command phase")
	state.active = 2
	C.Doctrines.start_command(state)
	C.UnitAbilities.start_command(state)
	check(C.Doctrines.active_for(state, captain_squad) == "assault", "Strategic Acumen persists through the opponent's Command phase")
	state.active = 1
	C.Doctrines.start_command(state)
	C.UnitAbilities.start_command(state)
	check(C.Doctrines.active_for(state, captain_squad).is_empty(), "Strategic Acumen expires at the start of the next own Command phase")

	state.unit_abilities.warlords = {1: captain}
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP when the Captain is Warlord")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist cannot grant Warlord CP twice in one round")

	state.phase = "fight"
	state.active = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = []
	state.awakened_dynasty.pending = []
	state.squads[captain_squad].charged = true
	state.squads[captain_squad].fought = false
	state.squads[captain_squad].fight_eligible = true
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var finest := by_action(C.UnitActions.choices(state, 1), "finest", captain_squad, captain)
	var finest_result := submit_projected_choice(state, 1, finest) if not finest.is_empty() else {"error": "missing Finest Hour option"}
	var finest_profile: Dictionary = Equipment.select(state, captain, true).get("stats", {})
	check(not finest.is_empty() and str(finest_result.get("error", "")).is_empty() and finest_profile.get("attacks", -1) == 9 and finest_profile.get("keywords", {}).get("devastating-wounds", false), "Finest Hour adds three attacks and Devastating Wounds to the Captain's Fight activation (models=%s, fight-choices=%s, squad=%s, choice=%s, result=%s, profile=%s)" % [str(C.UnitActions.models(state, 1, "finest-hour")), str(FightQueue.choices(state, 1)), str(state.squads[captain_squad]), str(finest), str(finest_result), str(finest_profile)])
	check(by_action(C.UnitActions.choices(state, 1), "finest", captain_squad, captain).is_empty(), "Finest Hour is once per battle")

	print("Current Captain source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

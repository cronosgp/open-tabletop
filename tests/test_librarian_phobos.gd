extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int: return 6
func four() -> int: return 4
func one() -> int: return 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries = [
			{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour", "models": 1, "copies": 1},
			{"definition_id": "40kdc:11e:adeptus-astartes:infiltrator-squad", "models": 5, "copies": 1},
			{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func make_state() -> Dictionary:
	var result := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if not result.has("error"):
		result.mission.stage = "battle"
		result.awakened_dynasty.pending = []
	return result

func find(state: Dictionary) -> Array[int]:
	var librarian := -1
	var bodyguard := -1
	var enemy_model := -1
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1:
			match C.UnitAbilities.identity(unit):
				"librarian-in-phobos-armour": librarian = model
				"infiltrator-squad": bodyguard = unit.squad
		if unit.owner == 2 and C.UnitAbilities.identity(unit) == "intercessor-squad" and enemy_model == -1: enemy_model = model
	return [librarian, bodyguard, enemy_model]

func check_weapon_plan(state: Dictionary, model: int, target_squad: int, weapon: Dictionary, profile_id: String, melee: bool) -> void:
	var targets: Array[int] = C.living(state, target_squad)
	if targets.is_empty():
		check(false, "%s has a living target for its AttackPlan" % str(weapon.get("id", "weapon")))
		return
	var target_model: int = targets[0]
	var old_phase := str(state.phase)
	var old_active := int(state.active)
	var old_attacker_position: Vector2 = state.units[model].position
	var old_target_position: Vector2 = state.units[target_model].position
	state.units[model].position = Vector2.ZERO
	state.units[target_model].position = Vector2(1.75, 0.0) if melee else Vector2(10.0, 0.0)
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.units[model].owner)
	var weapon_id := str(weapon.get("id", ""))
	var expected: Dictionary = weapon.get("profiles", {}).get(profile_id, {})
	var selected := Equipment.select(state, model, melee, weapon_id, profile_id)
	check(str(selected.get("error", "")).is_empty() and selected.get("stats", {}) == expected, "%s/%s passes Equipment with its exact source profile: %s" % [weapon_id, profile_id, str(selected.get("error", ""))])
	if str(selected.get("error", "")).is_empty():
		var amount := int(expected.get("attacks", 1)) if melee and expected.get("attacks", 1) is int else 1
		var plan: Dictionary = C.AttackPlan.prepare(state, int(state.units[model].squad), melee, [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": profile_id}], true)
		check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s/%s routes through AttackPlan: %s" % [weapon_id, profile_id, str(plan.get("error", ""))])
	state.phase = old_phase
	state.active = old_active
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.units[model].position = old_attacker_position
	state.units[target_model].position = old_target_position

func option(state: Dictionary, player: int, action: String, value: String, target: int = -999) -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and item.value == value and (target == -999 or item.target == target): return item
	return {}

func submit_scout_choice(state: Dictionary, player: int, action: String, model: int, target: int, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No Scout decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for choice: Dictionary in decision.get("legal_options", []):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and int(choice.get("target", -1)) == target:
			projected = choice
			break
	var selected: Dictionary = {}
	for choice: Dictionary in C.unit_choices(state, player):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and int(choice.get("target", -1)) == target:
			selected = choice
			break
	if projected.is_empty() or selected.is_empty(): return {"error": "The current Scout decision does not offer %s." % action}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = six) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty():
		return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": selected}, roller)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, roller)

func finish_scout_move(state: Dictionary, player: int, model: int, squad: int, point: Vector2) -> Dictionary:
	var start := option(state, player, "scout-move", "", squad)
	if start.is_empty(): return {"error": "missing Player %d Scout move choice" % player}
	var start_result := submit_scout_choice(state, player, "scout-move", -1, squad)
	if not str(start_result.get("error", "")).is_empty(): return start_result
	var placement: Dictionary = {}
	for choice: Dictionary in C.unit_choices(state, player):
		if choice.action == "scout-place" and int(choice.get("model", -1)) == model: placement = choice
	if placement.is_empty(): return {"error": "missing Player %d Scout placement choice" % player}
	var placement_result := submit_scout_choice(state, player, "scout-place", model, squad, point)
	if not str(placement_result.get("error", "")).is_empty(): return placement_result
	var confirmation: Dictionary = {}
	for choice: Dictionary in C.unit_choices(state, player):
		if choice.action == "scout-confirm" and int(choice.get("target", -1)) == squad: confirmation = choice
	if confirmation.is_empty(): return {"error": "missing Player %d Scout confirmation choice" % player}
	return submit_scout_choice(state, player, "scout-confirm", -1, squad)

func _initialize() -> void:
	var profile := Profiles.profile("librarian-in-phobos-armour")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000119" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Phobos Librarian retains local Wahapedia source identity")
	check(profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4) and profile.points_by_models == {1: 75} and profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Phobos Librarian model count, base, characteristics and price match the extraction")
	var expected_keywords := ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "PSYKER", "ADEPTUS ASTARTES"]
	var keywords_match: bool = profile.keywords.size() == expected_keywords.size()
	for keyword: String in expected_keywords:
		if keyword not in profile.keywords: keywords_match = false
	check(keywords_match, "Phobos Librarian retains the complete source keyword set")
	check("EXPLOSIVES" in profile.keywords and "PSYKER" in profile.keywords and profile.ranged.size() == 2 and profile.ranged[1].profiles.focused.attacks == "D3+3" and profile.ranged[1].profiles.focused.keywords == {"devastating-wounds": true, "psychic": true, "hazardous": true} and profile.melee[0].profiles.standard.keywords.psychic, "Phobos weapons, Smite modes and Psychic traits match the extraction")
	var resolution := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour")
	check(resolution.get("error", "").is_empty() and int(resolution.get("cost", -1)) == 75 and resolution.get("unsupported_abilities", []).is_empty(), "Phobos Librarian resolves from the current local catalog without blocked abilities")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-phobos-armour", "models": 1, "copies": 1}]})
	check(admitted.error.is_empty() and admitted.total == 75, "Phobos Librarian is admitted at 75 local points")
	var state := make_state()
	check(not state.has("error"), "Phobos Librarian and Infiltrators materialize from local profiles")
	if state.has("error"):
		print("Phobos Librarian checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find(state)
	var librarian: int = found[0]
	var bodyguard: int = found[1]
	var enemy_model: int = found[2]
	check(librarian >= 0 and bodyguard >= 0 and enemy_model >= 0, "Expected Librarian, Infiltrators and enemy models exist")
	if librarian < 0 or bodyguard < 0 or enemy_model < 0:
		print("Phobos Librarian checks: %d failures" % (failures + 1))
		quit(1)
		return
	for owner in [1, 2]:
		var owner_librarian := -1
		for model: int in state.units:
			if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == "librarian-in-phobos-armour": owner_librarian = model
		check(owner_librarian >= 0, "Player %d materializes the Phobos Librarian from the current local catalog" % owner)
	var librarian_squad: int = int(state.units[librarian].squad)
	check(C.UnitAbilities.has(state, librarian_squad, "deep-strike") and C.UnitAbilities.has(state, librarian_squad, "infiltrators") and C.UnitAbilities.has(state, librarian_squad, "stealth") and C.UnitAbilities.scout_distance(state, librarian_squad) == 6, "The Phobos Librarian retains its Core Deep Strike, Infiltrators, Stealth and Scouts 6 abilities")
	check(C.UnitAbilities.has(state, librarian_squad, "combat-doctrines") and C.UnitAbilities.has(state, librarian_squad, "librarius"), "The exported Combat Doctrines and Librarius faction abilities are catalogued for this datasheet")
	var materialization_enemy_squad: int = state.units[enemy_model].squad
	for weapon: Dictionary in profile.ranged:
		for weapon_profile: String in weapon.profiles:
			check_weapon_plan(state, librarian, materialization_enemy_squad, weapon, weapon_profile, false)
	for weapon: Dictionary in profile.melee:
		for weapon_profile: String in weapon.profiles:
			check_weapon_plan(state, librarian, materialization_enemy_squad, weapon, weapon_profile, true)
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(state, librarian, bodyguard), "Phobos Librarian can lead the admitted Infiltrator Squad")
	C.UnitActions.attach(state, librarian, bodyguard)
	check(C.UnitAbilities.has(state, bodyguard, "librarius") and C.UnitAbilities.has(state, bodyguard, "shrouding") and C.UnitAbilities.every_model_has(state, bodyguard, "infiltrators"), "Attached unit receives Librarius, Shrouding and all-model Infiltrators")
	check(not C.UnitAbilities.every_model_has(state, bodyguard, "deep-strike") and C.UnitAbilities.scout_distance(state, bodyguard) == 0 and not C.UnitAbilities.Detection.stealth(state, bodyguard), "Attached Infiltrators do not gain non-shared Deep Strike, Scout or Stealth")
	var rules: Array = Prevention.rules(state, librarian)
	check(rules == [{"target": 4, "against": "psychic"}] and Prevention.rules(state, C.living(state, bodyguard)[0]) == rules, "Phobos Psychic Hood gives the attached unit 4+ against Psychic damage")
	var prevented := C.Attacks.Prevention.resolve(1, 3, rules, "normal", four, "psychic")
	check(prevented.error.is_empty() and prevented.prevented == 1 and prevented.lost == 0, "Psychic Hood prevents normal damage from Psychic attacks")
	prevented = C.Attacks.Prevention.resolve(1, 3, rules, "mortal", four, "psychic")
	check(prevented.error.is_empty() and prevented.prevented == 1 and prevented.lost == 0, "Psychic Hood also prevents mortal damage from Psychic attacks")
	prevented = C.Attacks.Prevention.resolve(1, 3, rules, "normal", four)
	check(prevented.error.is_empty() and prevented.lost == 1 and prevented.rolls.is_empty(), "Psychic Hood does not prevent non-Psychic damage")
	check(C.UnitActions.attachment_allowed(state, librarian, bodyguard) == false, "A Leader cannot be attached twice")

	var soul_state := make_state()
	found = find(soul_state)
	C.UnitActions.attach(soul_state, found[0], found[1])
	soul_state.phase = "shooting"
	soul_state.active = 1
	soul_state.unit_abilities.setup_players = [1, 2]
	soul_state.terrain.areas = []
	for model: int in soul_state.units: soul_state.units[model].position = Vector2(-4, 0) if soul_state.units[model].owner == 1 else Vector2(4, 0)
	var enemy: int = find(soul_state)[2]
	var enemy_squad: int = soul_state.units[enemy].squad
	var soul := option(soul_state, 1, "librarius-power", "soul-sight", enemy_squad)
	check(not soul.is_empty(), "Soul Sight is offered for a visible enemy in the Phobos Librarian's Shooting phase")
	if not soul.is_empty():
		var before_wrong_soul_owner := var_to_bytes(soul_state)
		var wrong_soul_owner := submit_projected_choice(soul_state, 2, soul)
		check(not str(wrong_soul_owner.get("error", "")).is_empty() and before_wrong_soul_owner == var_to_bytes(soul_state), "The opponent cannot submit or mutate Soul Sight's decision")
		var soul_result := submit_projected_choice(soul_state, 1, soul)
		check(str(soul_result.get("error", "")).is_empty(), "Soul Sight psychic roll resolves through the match command: " + str(soul_result))
	var source_squad: int = soul_state.units[found[0]].squad
	var target_squad: int = soul_state.units[enemy].squad
	var pistol: Dictionary = Profiles.profile("librarian-in-phobos-armour").ranged[0].profiles.standard
	check(C.UnitAbilities.weapon(soul_state, found[0], target_squad, pistol, false).keywords.get("ignores-cover", false), "Soul Sight grants ranged Ignores Cover against the marked enemy")
	var allied: int = C.living(soul_state, found[1])[0]
	var allied_weapon: Dictionary = Profiles.profile("infiltrator-squad").ranged[0].profiles.standard
	check(C.UnitAbilities.weapon(soul_state, allied, target_squad, allied_weapon, false).keywords.get("ignores-cover", false), "Soul Sight applies to the whole Librarian attached unit")
	var unrelated := -1
	for model: int in soul_state.units:
		if soul_state.units[model].owner == 1 and C.UnitAbilities.identity(soul_state.units[model]) == "intercessor-squad": unrelated = model
	check(unrelated >= 0 and C.UnitAbilities.weapon(soul_state, unrelated, target_squad, Profiles.profile("intercessor-squad").ranged[0].profiles.values()[0], false).keywords.get("ignores-cover", false), "Soul Sight applies to other friendly ranged attacks against the marked enemy")
	check(C.UnitActions.librarius_choices(soul_state, 1).is_empty(), "Soul Sight consumes the Phobos Librarian's one level-1 power for this battle round")

	var incoming := make_state()
	found = find(incoming)
	C.UnitActions.attach(incoming, found[0], found[1])
	incoming.phase = "shooting"
	incoming.active = 2
	incoming.unit_abilities.setup_players = [1, 2]
	incoming.manual_allocation = true
	incoming.terrain.areas = []
	for model: int in incoming.units: incoming.units[model].position = Vector2(-4, 0) if incoming.units[model].owner == 1 else Vector2(4, 0)
	var attacker: int = find(incoming)[2]
	var defender_squad: int = found[1]
	var target_model: int = C.living(incoming, defender_squad)[0]
	var attack_weapon: Dictionary = incoming.units[attacker].ranged_weapons[0]
	var profile_name: String = attack_weapon.profiles.keys()[0]
	var declaration := [{"model": attacker, "target": defender_squad, "amount": 1, "weapon": attack_weapon.id, "profile": profile_name}]
	var declared := C.resolve_attack_plan(incoming, 2, attacker, declaration, incoming.revision, false, false, six)
	check(declared.error.is_empty() and incoming.unit_abilities.window.get("kind", "") == "phobos-shrouding", "Shrouding opens after the enemy selects the unit and before attack dice")
	var attack_frame := ResolutionFrames.current(incoming)
	var attack_decision := PendingDecisions.current(incoming, ["unit-actions"])
	check(attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_frame.get("resume_point", "") == "attack-phobos-shrouding", "Pre-dice Shrouding reaction suspends a persisted attack frame")
	check(attack_decision.get("action_id", "") == attack_frame.get("action_id", "") and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Normalized Shrouding decision identifies its attack continuation")
	var declaration_action_id := str(attack_frame.get("action_id", ""))
	incoming = bytes_to_var(var_to_bytes(incoming))
	attack_frame = ResolutionFrames.current(incoming)
	attack_decision = PendingDecisions.current(incoming, ["unit-actions"])
	check(attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", "") and attack_frame.get("status", "") == "suspended", "Serialized match preserves the pending attack frame and decision identity")
	var shrouding := option(incoming, 1, "phobos-shrouding", "use", defender_squad)
	check(not shrouding.is_empty(), "Defender receives an explicit Shrouding choice")
	if not shrouding.is_empty():
		var before_wrong_shrouding_owner := var_to_bytes(incoming)
		var wrong_shrouding_owner := submit_projected_choice(incoming, 2, shrouding)
		check(not str(wrong_shrouding_owner.get("error", "")).is_empty() and var_to_bytes(incoming) == before_wrong_shrouding_owner, "Attacker cannot resolve the defender's Shrouding reaction")
		check(not C.advance_phase(incoming, 2, incoming.revision).is_empty(), "Shooting close remains blocked while Shrouding is pending")
		var shrouding_result := submit_projected_choice(incoming, 1, shrouding)
		check(str(shrouding_result.get("error", "")).is_empty(), "Shrouding roll resumes the frozen attack declaration: " + str(shrouding_result.get("error", "")))
	attack_frame = ResolutionFrames.current(incoming)
	var damage_decision := PendingDecisions.current(incoming, ["damage-allocation"])
	check(not incoming.pending_attack.is_empty() and attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_frame.get("action_id", "") == declaration_action_id and incoming.pending_attack.get("resolution_action_id", "") == declaration_action_id, "Attack allocation suspends the same pre-dice action frame")
	check(damage_decision.get("action_id", "") == declaration_action_id and damage_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Damage-allocation projection keeps the declaration's frame identity")
	var allocation_steps := 0
	while not incoming.pending_attack.is_empty() and allocation_steps < 20:
		damage_decision = PendingDecisions.current(incoming, ["damage-allocation"])
		if damage_decision.get("legal_options", []).is_empty(): break
		var allocation_model := int(damage_decision.legal_options[0].get("model", -1))
		var allocation_error := C.allocate_damage(incoming, int(damage_decision.priority_player_id), allocation_model, incoming.revision, six)
		check(allocation_error.is_empty(), "Defender resolves allocation under the resumed attack frame")
		if not allocation_error.is_empty(): break
		allocation_steps += 1
	check(allocation_steps > 0, "Resumed attack exposes a legal damage-allocation choice")
	check(ResolutionFrames.current(incoming).is_empty() and incoming.pending_attack.is_empty(), "Attack frame completes only after damage allocation finishes")
	check(incoming.unit_abilities.used.get("librarius:%d:%d" % [defender_squad, incoming.round], "") == "shrouding" and C.UnitAbilities.hit_bonus(incoming, incoming.units[attacker].squad, defender_squad, false) == -1, "Shrouding spends level-1 capacity and applies -1 to hit through the phase")
	check(not incoming.squads[defender_squad].battle_shocked, "A successful Shrouding psychic roll leaves the unit unshocked")
	incoming.phase = "fight"
	check(C.UnitAbilities.hit_bonus(incoming, incoming.units[attacker].squad, defender_squad, true) == 0, "Shrouding modifier expires at phase end")

	var failed_cast := make_state()
	found = find(failed_cast)
	C.UnitActions.attach(failed_cast, found[0], found[1])
	failed_cast.phase = "shooting"
	failed_cast.active = 1
	failed_cast.unit_abilities.setup_players = [1, 2]
	failed_cast.terrain.areas = []
	for model: int in failed_cast.units: failed_cast.units[model].position = Vector2(-4, 0) if failed_cast.units[model].owner == 1 else Vector2(4, 0)
	enemy = find(failed_cast)[2]
	soul = option(failed_cast, 1, "librarius-power", "soul-sight", failed_cast.units[enemy].squad)
	if not soul.is_empty():
		var failed_soul_result := submit_projected_choice(failed_cast, 1, soul, one)
		check(str(failed_soul_result.get("error", "")).is_empty() and failed_cast.squads[found[1]].battle_shocked, "A Psychic roll of 1 Battle-shocks the Phobos unit through the match command")
	check(C.UnitActions.librarius_choices(failed_cast, 1).is_empty(), "Failed cast still consumes Librarius level-1 capacity")

	var scout := make_state()
	found = find(scout)
	var scout_model: int = found[0]
	var scout_squad: int = scout.units[scout_model].squad
	scout.deployment = {"zones": {1: Rect2(-30, -22, 11, 44), 2: Rect2(19, -22, 11, 44)}, "complete": true}
	scout.unit_abilities.reserves = {}
	scout.phase = "pre_battle"
	for id: int in scout.units:
		scout.units[id].position = Vector2(-25, 0) if id == scout_model else Vector2(-5, 0) if scout.units[id].owner == 1 else Vector2(20, 0)
	ScoutMoves.begin(scout)
	var scout_rows := C.unit_choices(scout, 1)
	var scout_start: Dictionary = {}
	for item: Dictionary in scout_rows:
		if item.action == "scout-move": scout_start = item
	check(not scout_start.is_empty() and C.actor(scout) == 1 and scout.phase == "pre_battle", "Standalone Phobos Librarian receives its alternating pre-battle Scout choice (distance %d; queue %s; window %s; phase %s)" % [C.UnitAbilities.scout_distance(scout, scout_squad), str(scout.unit_abilities.get("scout_queue", [])), str(scout.unit_abilities.get("window", {})), scout.phase])
	if not scout_start.is_empty():
		var start_result := submit_scout_choice(scout, 1, "scout-move", -1, scout_squad)
		check(str(start_result.get("error", "")).is_empty(), "Scout move opens per-model position previews")
		var place: Dictionary = {}
		for item: Dictionary in C.unit_choices(scout, 1):
			if item.action == "scout-place" and item.model == scout_model: place = item
		check(not place.is_empty(), "Scout move exposes model placement input")
		if not place.is_empty():
			var too_far := submit_scout_choice(scout, 1, "scout-place", scout_model, scout_squad, Vector2(-18.9, 0))
			check(not str(too_far.get("error", "")).is_empty(), "Scout rejects movement beyond six inches")
			var within_range := submit_scout_choice(scout, 1, "scout-place", scout_model, scout_squad, Vector2(-19, 0))
			check(str(within_range.get("error", "")).is_empty(), "Scout accepts a six-inch move within coherency and enemy-distance constraints")
		var confirm: Dictionary = {}
		for item: Dictionary in C.unit_choices(scout, 1):
			if item.action == "scout-confirm": confirm = item
		var confirmation := submit_scout_choice(scout, 1, "scout-confirm", -1, scout_squad)
		check(not confirm.is_empty() and str(confirmation.get("error", "")).is_empty(), "Scout positions confirm before the first turn")
		check(scout.phase == "pre_battle" and C.actor(scout) == 2 and scout.units[scout_model].position == Vector2(-19, 0), "Player 1 Scout move hands the pre-battle sequence to Player 2")
		var opponent_scout_model := -1
		for model: int in scout.units:
			if scout.units[model].owner == 2 and C.UnitAbilities.identity(scout.units[model]) == "librarian-in-phobos-armour": opponent_scout_model = model
		var opponent_scout_squad := int(scout.units[opponent_scout_model].squad) if opponent_scout_model >= 0 else -1
		var opponent_scout_result := finish_scout_move(scout, 2, opponent_scout_model, opponent_scout_squad, Vector2(14, 0)) if opponent_scout_model >= 0 else {"error": "missing Player 2 Phobos Librarian"}
		check(str(opponent_scout_result.get("error", "")).is_empty() and scout.phase == "start_turn" and scout.units[opponent_scout_model].position == Vector2(14, 0), "Player 2 Scout move completes before round one: " + str(opponent_scout_result.get("error", "")))

	var reserve_scout := make_state()
	found = find(reserve_scout)
	scout_model = found[0]
	scout_squad = reserve_scout.units[scout_model].squad
	reserve_scout.board_size = Vector2(60, 44)
	reserve_scout.deployment = {"zones": {1: Rect2(-30, -22, 11, 44), 2: Rect2(19, -22, 11, 44)}, "complete": true}
	reserve_scout.unit_abilities.reserves[scout_squad] = {"cost": 75}
	reserve_scout.phase = "pre_battle"
	for id: int in reserve_scout.units:
		reserve_scout.units[id].position = Vector2(-35, 0) if id == scout_model else Vector2(-5, 0) if reserve_scout.units[id].owner == 1 else Vector2(20, 0)
		if id == scout_model: reserve_scout.units[id].on_battlefield = false
	ScoutMoves.begin(reserve_scout)
	var scout_setup: Dictionary = {}
	for item: Dictionary in C.unit_choices(reserve_scout, 1):
		if item.action == "scout-setup": scout_setup = item
	check(not scout_setup.is_empty(), "Scout choice allows a reserved unit to set up in its deployment zone")
	if not scout_setup.is_empty():
		var setup_result := submit_scout_choice(reserve_scout, 1, "scout-setup", -1, scout_squad)
		check(str(setup_result.get("error", "")).is_empty(), "Reserved Scout unit opens set-up placement")
		var reserve_place: Dictionary = {}
		for item: Dictionary in C.unit_choices(reserve_scout, 1):
			if item.action == "scout-place" and item.model == scout_model: reserve_place = item
		var reserve_place_result: Dictionary = {"error": "missing placement choice"}
		if not reserve_place.is_empty(): reserve_place_result = submit_scout_choice(reserve_scout, 1, "scout-place", scout_model, scout_squad, Vector2(-25, 0))
		var reserve_confirm: Dictionary = {}
		for item: Dictionary in C.unit_choices(reserve_scout, 1):
			if item.action == "scout-confirm": reserve_confirm = item
		var reserve_confirm_result: Dictionary = {"error": "missing confirmation choice"}
		if not reserve_confirm.is_empty(): reserve_confirm_result = submit_scout_choice(reserve_scout, 1, "scout-confirm", -1, scout_squad)
		var reserve_place_error := str(reserve_place_result.get("error", ""))
		var reserve_confirm_error := str(reserve_confirm_result.get("error", ""))
		var opponent_reserve_scout_model := -1
		for model: int in reserve_scout.units:
			if reserve_scout.units[model].owner == 2 and C.UnitAbilities.identity(reserve_scout.units[model]) == "librarian-in-phobos-armour": opponent_reserve_scout_model = model
		var opponent_reserve_scout_squad := int(reserve_scout.units[opponent_reserve_scout_model].squad) if opponent_reserve_scout_model >= 0 else -1
		var opponent_reserve_scout_result := finish_scout_move(reserve_scout, 2, opponent_reserve_scout_model, opponent_reserve_scout_squad, Vector2(14, 0)) if opponent_reserve_scout_model >= 0 else {"error": "missing Player 2 Phobos Librarian"}
		check(reserve_place_error.is_empty() and reserve_confirm_error.is_empty() and str(opponent_reserve_scout_result.get("error", "")).is_empty() and reserve_scout.phase == "start_turn", "Reserved Player 1 unit sets up, then Player 2 takes its Scout move (place: %s; confirm: %s; opponent: %s)" % [reserve_place_error, reserve_confirm_error, str(opponent_reserve_scout_result.get("error", ""))])
		check(reserve_scout.units[scout_model].get("on_battlefield", false) and not reserve_scout.unit_abilities.reserves.has(scout_squad), "Scout set-up removes the unit from Strategic Reserves")

	print("Phobos Librarian checks: %d failures" % failures)
	quit(1 if failures else 0)

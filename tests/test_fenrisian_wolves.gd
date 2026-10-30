extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const FenrisianWolves = preload("res://scripts/edition_11/fenrisian_wolves.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:fenrisian-wolves", "models": 5, "copies": 1})
	return result

func fresh() -> Dictionary:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.mission.stage = "battle"
	return state

func find_squad(state: Dictionary, owner: int, identity: String, starting_strength: int = -1) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if starting_strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != starting_strength: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func choice(state: Dictionary, player: int, action_id: String, target: int) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target: return option
	return {}

func submit_choice(state: Dictionary, player: int, action_id: String, target: int, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target:
			projected = option
			break
	if projected.is_empty(): return {"error": "The normalized decision does not offer %s for target %d." % [action_id, target]}
	var selected := choice(state, player, action_id, target)
	if selected.is_empty(): return {"error": "UnitActions no longer offers the projected Fenrisian Wolves choice."}
	var command := {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}
	return MatchCommands.execute(state, player, command, roller)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("fenrisian-wolves")
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000000323" and profile.source_slice_manifest_sha256 == "DD01804235496759470C95A4B73CAFE3E04F924E10B5C62A68E2407B8E720EA1", "Fenrisian Wolves profile is tied to the source App datasheet and verified local slice")
	check(profile.points_by_models == {5: 45, 10: 75} and profile.third_plus_points_by_models == {5: 50, 10: 80} and profile.base_size_source_mm == 40, "Both source copy-cost tiers, model sizes and 40 mm bases are retained")
	check(profile.stats == {"movement_inches": 10, "toughness": 4, "save_target": 6, "wounds": 1, "leadership_target": 8, "objective_control": 0, "invulnerable_target": 0}, "Fenrisian Wolf characteristics match the verified local export")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard.attacks == 3 and profile.melee[0].profiles.standard.skill == 4 and profile.melee[0].profiles.standard.strength == 4, "Teeth and Claws matches its exported melee profile")
	check(Roster.POINTS.get("fenrisian-wolves", {}).get("sizes", {}) == {5: 45, 10: 75} and Catalog.SPECS.get("fenrisian-wolves", {}).get("current_reference", false), "The current catalog publishes the source-priced five/ten-model sizes")
	var state := fresh()
	check(not state.has("error"), "Fenrisian Wolves prepare from the current local Marine catalog")
	if state.has("error"):
		print(str(state.error))
		quit(1)
		return
	var wolves := find_squad(state, 1, "fenrisian-wolves", 5)
	var enemy_small := find_squad(state, 2, "intercessor-squad", 5)
	var captain := find_squad(state, 1, "captain")
	check(wolves >= 0 and enemy_small >= 0 and captain >= 0, "The test roster contains Fenrisian Wolves, an enemy movement target and a friendly Character")
	if wolves < 0 or enemy_small < 0 or captain < 0:
		print("Fenrisian Wolves checks: %d failures" % failures)
		quit(1)
		return
	var models := Geometry.alive(state, wolves)
	check(models.size() == 5 and Abilities.has(state, wolves, "predatory-instinct") and Abilities.has(state, wolves, "hunting-hounds"), "Five Fenrisian Wolves have both source abilities")
	var enemy_small_models := Geometry.alive(state, enemy_small)
	for model: int in state.units:
		state.units[model].position = Vector2(-18.0, -18.0 + float(model % 12) * 2.0) if int(state.units[model].get("owner", -1)) == 1 else Vector2(18.0, -18.0 + float(model % 12) * 2.0)
	for index in range(models.size()): state.units[models[index]].position = Vector2(-12.0, -5.2 + float(index) * 1.6)
	for index in range(enemy_small_models.size()): state.units[enemy_small_models[index]].position = Vector2(-6.0, -5.2 + float(index) * 1.6)
	state.phase = "movement"
	state.active = 2
	state.round = 1
	state.turn = 1
	state.squads[enemy_small].moved = false
	var mover := enemy_small_models[0]
	var moved := C.move(state, 2, mover, Vector2(-4.0, -5.2), int(state.revision))
	var finished := moved if not moved.is_empty() else C.finish_movement(state, 2, int(state.revision), false)
	check(finished.is_empty() and state.unit_abilities.window.get("kind", "") == FenrisianWolves.WINDOW, "An enemy move ending within 8 inches opens Predatory Instinct")
	check(C.UnitActions.movement_reaction_squad(state) == enemy_small, "Predatory Instinct suspends the completed enemy Movement action")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner := submit_choice(state, 2, "predatory-instinct-use", wolves)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot submit or mutate the Fenrisian reaction")
	var invalid_die := submit_choice(state, 1, "predatory-instinct-use", wolves, Vector2.ZERO, func() -> int: return 7)
	check(not str(invalid_die.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "An invalid D6 result is rejected without spending the once-per-round ability")
	var used := submit_choice(state, 1, "predatory-instinct-use", wolves, Vector2.ZERO, func() -> int: return 2)
	check(str(used.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == FenrisianWolves.PLACEMENT and int(state.unit_abilities.window.distance) == 2, "Using Predatory Instinct rolls a host D6 and opens a two-inch Normal Move")
	var first_wolf := models[0]
	var original: Vector2 = state.units[first_wolf].position
	var too_far := submit_choice(state, 1, "predatory-instinct-place", wolves, original + Vector2(2.5, 0.0))
	check(not str(too_far.get("error", "")).is_empty(), "A model cannot exceed its rolled D6 movement distance")
	var placed := submit_choice(state, 1, "predatory-instinct-place", wolves, original + Vector2(1.5, 0.0))
	check(str(placed.get("error", "")).is_empty(), "A Fenrisian Wolf can preview a legal reaction-move destination")
	var confirmed := submit_choice(state, 1, "predatory-instinct-confirm", wolves)
	check(str(confirmed.get("error", "")).is_empty() and state.squads[wolves].move_type == "normal" and state.units[first_wolf].position.distance_to(original) <= 2.001, "The reaction resolves as a Normal Move within the rolled distance")
	check(state.unit_abilities.used.has("fenrisian-predatory-instinct:%d:1" % wolves) and state.unit_abilities.window.is_empty(), "Predatory Instinct records the unit's once-per-battle-round use and resumes movement")
	FenrisianWolves.open_after_enemy_move(state, enemy_small)
	check(state.unit_abilities.window.is_empty(), "A second qualifying enemy move does not reopen Predatory Instinct within the same battle round")
	var character := Geometry.alive(state, captain)[0]
	state.units[character].keywords.append("SPACE WOLVES")
	var wolf := models[1]
	state.units[character].position = state.units[wolf].position + Vector2(5.0, 0.0)
	check(Morale.objective_control(state, wolf) == 1, "Hunting Hounds adds +1 OC near a friendly Space Wolves Character")
	state.units[character].keywords.append("WULFEN")
	check(Morale.objective_control(state, wolf) == 0, "A Wulfen Character is excluded from Hunting Hounds")
	state.units[character].keywords.erase("WULFEN")
	state.units[character].position = Vector2(-12.0, 10.0)
	check(Morale.objective_control(state, wolf) == 0, "Hunting Hounds ends outside its 6-inch range")
	state.units[character].position = state.units[wolf].position + Vector2(5.0, 0.0)
	state.squads[wolves].battle_shocked = true
	check(Morale.objective_control(state, wolf) == 0, "Battle-shock suppresses Hunting Hounds OC")
	print("Fenrisian Wolves checks: %d failures" % failures)
	quit(1 if failures else 0)

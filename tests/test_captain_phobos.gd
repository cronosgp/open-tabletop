extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const A = C.UnitAbilities
const Fluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:captain-in-phobos-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:infiltrator-squad", "models": 5, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true}, selections())
	if state.has("error"): return state
	state.phase = "shooting"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.mission.stage = "battle"
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	state.awakened_dynasty.pending = []
	state.terrain.areas = []
	for model: int in state.units: state.units[model].position = Vector2(-18, -12) if state.units[model].owner == 1 else Vector2(18, 12)
	return state
func model_for(state: Dictionary, identity: String, owner: int = 1) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and A.identity(state.units[model]) == identity: return model
	return -1
func choose(state: Dictionary, owner: int, action: String, target: int = -1) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and (target < 0 or row.target == target): return row
	return {}
func choose_model(state: Dictionary, owner: int, action: String, model: int) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and row.model == model: return row
	return {}
func choose_value(state: Dictionary, owner: int, action: String, model: int, value: String) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and row.model == model and row.value == value: return row
	return {}
func act(state: Dictionary, owner: int, action: String, target: int, point: Vector2 = Vector2.ZERO) -> String:
	var row := choose(state, owner, action, target)
	if row.is_empty(): return "missing choice: " + action
	var error := C.unit_action(state, owner, row, point, state.revision, six)
	if not error.is_empty(): print(action, " failed: ", error)
	return error
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	if s.has("error"):
		print(s)
		check(false, "Phobos Captain admitted into local roster")
		quit(1)
		return
	var captain := model_for(s, "captain-in-phobos-armour")
	var squad := int(s.units[captain].squad)
	var profile := P.profile("captain-in-phobos-armour")
	check(profile.points == 75 and profile.source_datasheet_id == "000002701" and profile.stats.wounds == 5 and profile.stats.objective_control == 1 and profile.stats.invulnerable_target == 4 and "CAPTAIN" in profile.keywords, "Captain profile, local source identity, cost, stats, save or keywords mismatch")
	check(profile.ranged[0].profiles.standard.keywords.precision and profile.melee[0].profiles.standard.keywords.get("sustained-hits", 0) == 1, "Instigator Carbine or Combat Knife traits missing")
	check(A.has(s, squad, "leader") and A.has(s, squad, "tactical-fluidity") and A.has(s, squad, "strategic-acumen") and A.scout_distance(s, squad) == 6, "Captain abilities not admitted")
	check(Detection.infiltrators(s, squad) and Detection.stealth(s, squad), "Captain Infiltrators or Stealth keyword effect missing")
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(s, captain, int(s.units[model_for(s, "infiltrator-squad")].squad)), "Captain Leader pairing missing")
	check(not choose_model(s, 1, "warlord", captain).is_empty(), "Captain Warlord choice missing")
	s.phase = "command"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	check(C.select_combat_doctrine(s, 1, "none", s.revision).is_empty(), "Start-of-Command doctrine choice failed")
	var acumen := choose_value(s, 1, "acumen", captain, "assault")
	check(not acumen.is_empty() and C.unit_action(s, 1, acumen, Vector2.ZERO, s.revision, six).is_empty() and C.Doctrines.active_for(s, squad) == "assault", "Captain Strategic Acumen failed to activate a doctrine")
	var demi_pass := choose(s, 1, "pass")
	if not demi_pass.is_empty(): C.unit_action(s, 1, demi_pass, Vector2.ZERO, s.revision, six)
	s.phase = "start_turn"
	s.unit_abilities.warlords = {1: captain}
	var cp_before: int = s.cp[1]
	C.UnitActions.start_round(s)
	check(s.cp[1] == cp_before + 1, "Captain Warlord did not gain its once-per-round CP")
	# After the unit shoots, use its once-per-round D6 Normal Move.
	s.phase = "shooting"
	s.unit_abilities.setup_players = [1, 2]
	s.squads[squad].shot = true
	Fluidity.open_after_shot(s, squad)
	check(C.UnitActions.actor(s) == 1 and not choose(s, 1, "fluidity-use", squad).is_empty(), "Post-shot Tactical Fluidity window missing")
	check(C.unit_action(s, 1, choose(s, 1, "fluidity-use", squad), Vector2.ZERO, s.revision, six).is_empty(), "Tactical Fluidity D6 choice failed")
	check(s.unit_abilities.window.distance == 6 and act(s, 1, "fluidity-place", squad, Vector2(-16, -12)).is_empty(), "Tactical Fluidity preview rejected valid move")
	check(act(s, 1, "fluidity-confirm", squad).is_empty() and s.units[captain].position == Vector2(-16, -12), "Tactical Fluidity Normal Move confirmation failed")
	Fluidity.open_after_shot(s, squad)
	check(s.unit_abilities.window.is_empty(), "Tactical Fluidity reused in the same battle round")
	# A separate trigger at the end of the opposing Fight phase permits Fall Back.
	s = fixture()
	captain = model_for(s, "captain-in-phobos-armour")
	squad = int(s.units[captain].squad)
	var enemy := model_for(s, "necron-warriors", 2)
	s.units[captain].position = Vector2.ZERO
	s.units[enemy].position = Vector2(1.8, 0)
	s.phase = "fight"
	s.active = 2
	check(squad in Fluidity.end_fight_squads(s, 1), "Engaged Captain's unit was not eligible for end-of-Fight Tactical Fluidity")
	var end_opened := C.UnitActions.open_end(s)
	if end_opened and C.UnitActions.actor(s) == 2:
		var opponent_pass := choose(s, 2, "pass")
		check(not opponent_pass.is_empty() and C.unit_action(s, 2, opponent_pass, Vector2.ZERO, s.revision, six).is_empty(), "Opponent could not pass its earlier end-of-Fight choices")
	check(end_opened and C.UnitActions.actor(s) == 1 and not choose(s, 1, "fluidity-end", squad).is_empty(), "Opponent Fight end did not offer the Captain's Fall Back reaction")
	check(C.unit_action(s, 1, choose(s, 1, "fluidity-end", squad), Vector2.ZERO, s.revision, six).is_empty(), "Tactical Fluidity end-of-Fight activation failed")
	check(C.unit_action(s, 1, choose(s, 1, "fluidity-use", squad), Vector2.ZERO, s.revision, six).is_empty(), "Tactical Fluidity Fall Back selection failed")
	if s.unit_abilities.window.get("kind", "") == Fluidity.PLACEMENT:
		check(s.unit_abilities.window.distance == 6 and act(s, 1, "fluidity-place", squad, Vector2(-2, 0)).is_empty(), "Tactical Fluidity Fall Back preview rejected valid move")
		check(act(s, 1, "fluidity-confirm", squad).is_empty() and s.squads[squad].fell_back and not C._engaged(s, squad), "Fall Back did not end unengaged")
	print("Captain in Phobos Armour checks: %d failures" % failures)
	quit(1 if failures else 0)

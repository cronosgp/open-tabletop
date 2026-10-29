extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Victrix = preload("res://scripts/edition_11/victrix_honour_guard.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
var failures := 0

func six() -> int: return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": count, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner: continue
		for model: int in Geometry.alive(state, squad):
			if A.identity(state.units[model]) == identity: return squad
	return -1

func find_role(state: Dictionary, squad: int, role: String) -> int:
	for model: int in Geometry.alive(state, squad):
		if state.units[model].get("victrix_honour_guard_role", "") == role: return model
	return -1

func fixture(count: int = 3, composition_choice_id: String = "") -> Dictionary:
	var lists := F.current_marine_selections()
	var guard_entry := entry("victrix-honour-guard", count)
	if not composition_choice_id.is_empty(): guard_entry.composition_choice_id = composition_choice_id
	lists[1].entries = [entry("cato-sicarius"), guard_entry, entry("assault-intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.mission.stage = "battle"
	state.unit_abilities.window = {}
	for model: int in state.units:
		state.units[model].on_battlefield = true
		var offset := Vector2(float(model % 5) * 2.0, floorf(float(model % 100) / 5.0) * 2.0)
		state.units[model].position = Vector2(12, 12) + offset if state.units[model].owner == 2 else Vector2(-18, -18) + offset
	var squad := find_squad(state, 1, "victrix-honour-guard")
	var members := Geometry.alive(state, squad)
	for index in range(members.size()): state.units[members[index]].position = Vector2(-10, (float(index) - float(members.size() - 1) / 2.0) * 1.7)
	return state

func action(state: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (target < 0 or int(option.target) == target) and (model < 0 or int(option.model) == model): return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Glory of Ultramar choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("victrix-honour-guard")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004185" and profile.points_by_models == {3: 135, 6: 265} and profile.third_plus_points_by_models == {3: 165, 6: 295}, "Victrix identity and banner-inclusive points match the local source export")
	check(profile.composition_options.size() == 8 and profile.source_roster_points.points_by_models == {3: 120, 6: 250} and profile.wargear_costs == {"banner-of-macragge": 15}, "The sheet exposes all legal 3/6-model role combinations with the source's separate Banner cost")
	for option: Dictionary in profile.composition_options:
		var admission := ArmyCapabilities.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "models": option.models, "copies": 1, "composition_choice_id": option.id}]})
		var expected_cost := int(profile.source_roster_points.points_by_models[option.models]) + int(option.wargear_cost)
		var configuration_key := "40kdc:11e:adeptus-astartes:victrix-honour-guard:%02d::%s" % [int(option.models), str(option.id)]
		var resolved: Dictionary = admission.get("configurations", {}).get(configuration_key, {})
		check(admission.get("error", "").is_empty() and admission.get("total", -1) == expected_cost and resolved.get("victrix_roles", []) == option.roles, "%s/%d resolves its exact roles and %d-point Banner cost" % [str(option.id), int(option.models), int(option.wargear_cost)])
	var invalid_roles := ArmyCapabilities.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "models": 3, "copies": 1, "composition_choice_id": "ancient-without-a-guard"}]})
	check(not invalid_roles.get("error", "").is_empty(), "Roster admission rejects a model-role configuration absent from the source composition")
	var builder_unit := ArmyCapabilities.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "name": "Victrix Honour Guard", "edition": "11e", "faction": "Space Marines", "role": "Other units", "options": [], "source_digest": "local"})
	var three_option_index := -1
	for option_index in builder_unit.options.size():
		if int(builder_unit.options[option_index].models) == 3: three_option_index = option_index
	var guards_choice: Dictionary = {}
	var ancient_choice: Dictionary = {}
	for option: Dictionary in builder_unit.composition_options:
		if int(option.models) != 3: continue
		if option.id == "guards-only": guards_choice = option
		if option.id == "ancient-champion": ancient_choice = option
	var no_banner_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 1000)
	no_banner_list.entries.append(ArmyRoster.entry(builder_unit, three_option_index, 1, guards_choice))
	var banner_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 1000)
	banner_list.entries.append(ArmyRoster.entry(builder_unit, three_option_index, 1, ancient_choice))
	check(ArmyRoster.validate(no_banner_list).is_empty() and ArmyRoster.summary(no_banner_list).points == 120 and ArmyRoster.entry_cost(no_banner_list.entries, 0) == 120 and ArmyRoster.summary(banner_list).points == 135, "Army-builder pricing adds the Banner only to compositions that include the Ancient")
	var checked_without_banner := C.RosterValidation.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), {"definition_id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "models": 3, "copies": 1, "composition_choice_id": "guards-only"}]})
	var checked_with_banner := C.RosterValidation.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), {"definition_id": "40kdc:11e:adeptus-astartes:victrix-honour-guard", "models": 3, "copies": 1, "composition_choice_id": "ancient-champion"}]})
	check(checked_without_banner.get("error", "").is_empty() and checked_with_banner.get("error", "").is_empty() and checked_with_banner.total - checked_without_banner.total == 15 and checked_without_banner.construction.breakdown[1].wargear_cost == 0 and checked_with_banner.construction.breakdown[1].wargear_cost == 15, "Checked-roster prices separately apply the 15-point Banner option")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "All three Victrix roles share the extracted characteristics")
	check(profile.model_loadouts.size() == 3 and profile.model_loadouts[0].keywords.has("EPIC HERO") and profile.model_loadouts[0].keywords.has("ANCIENT") and profile.model_loadouts[1].keywords.has("CHAMPION") and not profile.model_loadouts[2].keywords.has("EPIC HERO"), "Ancient, Champion and ordinary Guard keywords remain role-specific")
	var ancient: Dictionary = profile.model_loadouts[0]
	var champion: Dictionary = profile.model_loadouts[1]
	var guard: Dictionary = profile.model_loadouts[2]
	check(ancient.ranged[0].profiles.standard.attacks == 2 and ancient.ranged[0].profiles.standard.skill == 2 and ancient.melee[0].profiles.standard.strength == 5, "Ancient receives the source carbine and Master-crafted Power Weapon")
	check(champion.ranged.is_empty() and champion.melee[0].profiles.standard.keywords == {"twin-linked": true, "precision": true}, "Champion receives Blades of Honour and its source traits")
	check(guard.ranged[0].profiles.standard.keywords == {"rapid-fire": 1, "assault": true} and guard.melee[0].profiles.standard.damage == 2, "Guard carbine and melee profiles retain source traits")
	var six_models := fixture(6)
	var six_squad := find_squad(six_models, 1, "victrix-honour-guard")
	check(not six_models.has("error") and six_models.training_points[1] == 465 and six_squad >= 0 and find_role(six_models, six_squad, "chapter-ancient") >= 0 and find_role(six_models, six_squad, "chapter-champion") >= 0 and Geometry.alive(six_models, six_squad).size() == 6, "The six-model configuration materializes its required role composition")
	var guard_only := fixture(3, "guards-only")
	var guard_only_squad := find_squad(guard_only, 1, "victrix-honour-guard")
	var guard_only_roles: Array[String] = []
	for member: int in Geometry.alive(guard_only, guard_only_squad): guard_only_roles.append(str(guard_only.units[member].get("victrix_honour_guard_role", "")))
	check(not guard_only.has("error") and guard_only.training_points[1] == 320 and guard_only_roles == ["victrix-honour-guard", "victrix-honour-guard", "victrix-honour-guard"], "The bannerless Guard-only 3-model composition materializes at 120 points")
	var champion_only := fixture(3, "champion")
	var champion_only_squad := find_squad(champion_only, 1, "victrix-honour-guard")
	check(not champion_only.has("error") and find_role(champion_only, champion_only_squad, "chapter-ancient") < 0 and find_role(champion_only, champion_only_squad, "chapter-champion") >= 0 and champion_only.training_points[1] == 320, "The Champion-only composition preserves its Blades of Honour without charging for the Banner")
	var state := fixture()
	check(not state.has("error"), "Three-model Victrix fixture materializes")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var guard_squad := find_squad(state, 1, "victrix-honour-guard")
	var ancient_model := find_role(state, guard_squad, "chapter-ancient")
	var champion_model := find_role(state, guard_squad, "chapter-champion")
	var guard_model := -1
	for member: int in Geometry.alive(state, guard_squad):
		if state.units[member].get("victrix_honour_guard_role", "") == "victrix-honour-guard": guard_model = member
	check(state.training_points[1] == 335 and state.units[ancient_model].ranged_weapons[0].id == "master-crafted-bolt-carbine" and state.units[champion_model].melee_weapons[0].id == "blades-of-honour" and state.units[guard_model].melee_weapons[0].id == "master-crafted-power-weapon", "Fixed training loadouts map to each source model role")
	check(A.has(state, guard_squad, "glory-of-ultramar") and A.has(state, guard_squad, "honour-guard-of-macragge") and A.has(state, guard_squad, "banner-of-macragge") and A.has(state, guard_squad, "combat-doctrines"), "All Victrix datasheet abilities register")
	check(A.defensive_wound_modifier(state, guard_squad, 1, 5) == -1 and A.defensive_wound_modifier(state, guard_squad, 10, 5) == -1, "Honour Guard of Macragge reduces wound rolls at every Strength comparison")
	var cato_squad := find_squad(state, 1, "cato-sicarius")
	var assault_squad := find_squad(state, 1, "assault-intercessor-squad")
	var cato_model := Geometry.alive(state, cato_squad)[0]
	check(C.UnitActions.attachment_allowed(state, cato_model, guard_squad) and not C.UnitActions.attachment_allowed(state, cato_model, assault_squad), "Cato can join the exact source-listed Victrix target and not another bodyguard")
	C.UnitActions.attach(state, cato_model, guard_squad)
	check(state.units[cato_model].squad == guard_squad, "Cato's exact Victrix Leader attachment succeeds")
	state.units[cato_model].position = state.units[champion_model].position + Vector2(-1.7, 0)
	state.phase = "fight"
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.squads[guard_squad].charged = true
	var banner_use := action(state, 1, "victrix-banner", guard_squad)
	check(not banner_use.is_empty(), "Banner of Macragge can be chosen when Victrix is selected to fight")
	if not banner_use.is_empty():
		var before_banner := var_to_bytes(state)
		var wrong_owner := submit_choice(state, 2, banner_use, Vector2.ZERO, six)
		check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_banner, "Opponent cannot activate the Banner of Macragge")
		var banner_result := submit_choice(state, 1, banner_use, Vector2.ZERO, six)
		check(str(banner_result.get("error", "")).is_empty(), "Banner activation uses the current public UnitActions decision: " + str(banner_result.get("error", "")))
	check(state.unit_abilities.used.get("banner-macragge-used:1", false) and state.unit_abilities.banner_active.has(guard_squad) and action(state, 1, "victrix-banner", guard_squad).is_empty(), "Banner use is once per battle for the whole army")
	state.unit_abilities.banner_active = {guard_squad: {"owner": 1, "turn": 1}}
	var blade: Dictionary = state.units[champion_model].melee_weapons[0].profiles.standard
	var buffed := A.weapon(state, champion_model, 2, blade, true)
	check(buffed.strength == 7 and A.melee_attack_count(state, champion_model, blade) == 7 and blade.strength == 6 and blade.attacks == 6, "Banner fight effect adds +1 Strength and Attack without mutating source weapons")
	var cato_blade: Dictionary = Profiles.profile("cato-sicarius").melee[0].profiles.standard
	check(A.weapon(state, cato_model, 2, cato_blade, true).strength == cato_blade.strength + 1 and A.melee_attack_count(state, cato_model, cato_blade) == int(cato_blade.attacks) + 1, "Banner fight bonus also applies to Cato while attached")
	check(A.weapon(state, champion_model, 2, blade, false).strength == blade.strength, "Banner effect does not change ranged attacks")
	state.unit_abilities.banner_active = {}
	state.phase = "shooting"
	state.active = 2
	var shooter := find_squad(state, 2, "intercessor-squad")
	Victrix.open_after_enemy_shot(state, shooter, [])
	check(state.unit_abilities.window.is_empty(), "Glory does not trigger without a casualty from the completed attack")
	Victrix.open_after_enemy_shot(state, shooter, [{"target_squad": guard_squad, "models_destroyed": 1, "allocations": [{"model": champion_model}]}])
	check(state.unit_abilities.window.is_empty(), "Glory does not trigger when the pool does not identify a destroyed Victrix model")
	state.units[guard_model].wounds = 0
	var attack_action_id := "attack:%d:%d:shooting:test" % [state.turn, shooter]
	check(not C.ResolutionFrames.begin(state, "attack", attack_action_id, "attack-finalization").is_empty(), "A completed enemy attack opens a persisted resolution frame")
	Victrix.open_after_enemy_shot(state, shooter, [{"target_squad": guard_squad, "models_destroyed": 1, "allocations": [{"model": guard_model}]}])
	check(state.unit_abilities.window.get("kind", "") == Victrix.WINDOW and state.unit_abilities.window.squad == guard_squad, "A casualty from the resolved enemy attacks opens Glory of Ultramar")
	var post_attack_frame_error := C._complete_attack_resolution_frame(state, attack_action_id)
	var glory_frame := C.ResolutionFrames.current(state)
	check(post_attack_frame_error.is_empty() and glory_frame.get("status", "") == "suspended" and glory_frame.get("resume_point", "") == "attack-post-resolution-choice", "Glory of Ultramar suspends the attack continuation")
	var glory_decision := PendingDecisions.current(state, ["unit-actions"])
	var glory_decision_id: String = str(glory_decision.get("decision_id", ""))
	check(glory_decision.get("resume_frame_id", "") == glory_frame.get("frame_id", "") and glory_decision.get("priority_player_id", -1) == 1, "Glory decision identifies the suspended attack frame and defender owner")
	check(not PhaseCloseGate.close_request_error(state, 2, state.revision).is_empty(), "Shooting close remains blocked while Glory is pending")
	var use := action(state, 1, "glory-use", guard_squad)
	check(not use.is_empty(), "The defending player receives the optional Surge move")
	if not use.is_empty():
		var before_wrong_owner := var_to_bytes(state)
		var wrong_owner_result := submit_choice(state, 2, use, Vector2.ZERO, six)
		check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The shooting attacker cannot submit or mutate the defender's Glory choice")
		state = bytes_to_var(var_to_bytes(state))
		glory_decision = PendingDecisions.current(state, ["unit-actions"])
		check(glory_decision.get("decision_id", "") == glory_decision_id and glory_decision.get("resume_frame_id", "") == glory_frame.get("frame_id", ""), "Glory decision and attack frame survive save/restore")
		use = action(state, 1, "glory-use", guard_squad)
		check(str(submit_choice(state, 1, use, Vector2.ZERO, six).get("error", "")).is_empty(), "Glory of Ultramar rolls its D6 distance through the normalized command")
		check(C.ResolutionFrames.current(state).get("frame_id", "") == glory_frame.get("frame_id", ""), "Glory placement retains the same attack continuation")
		var place := action(state, 1, "glory-place", guard_squad, ancient_model)
		check(not place.is_empty(), "Surge move offers placement for surviving models")
		if not place.is_empty():
			var destination: Vector2 = state.units[ancient_model].position + Vector2(0.5, 0)
			var move_result := submit_choice(state, 1, place, destination, six)
			check(str(move_result.get("error", "")).is_empty(), "A surviving model can preview a legal Surge move through the normalized command")
			var confirm := action(state, 1, "glory-confirm", guard_squad)
			var confirm_error := "Missing confirm choice" if confirm.is_empty() else str(submit_choice(state, 1, confirm, Vector2.ZERO, six).get("error", ""))
			check(confirm_error.is_empty() and state.squads[guard_squad].move_type == "surge", "The confirmed move is recorded as a Surge move: " + confirm_error)
			check(C.ResolutionFrames.current(state).is_empty(), "Completing Glory closes the attack continuation")
	state.phase = "movement"
	state.active = 1
	state.unit_abilities.window = {}
	state.unit_abilities.control_done = ""
	state.mission.objectives = [{"name": "Macragge", "kind": "marker", "position": state.units[ancient_model].position, "controller": 1, "secured": 0, "levels": {1: 0, 2: 0}}]
	C._resolve_current_end_control(state)
	check(state.mission.objectives[0].secured == 1, "The Ancient's banner secures an objective controlled at end of Movement")
	state.mission.objectives[0].secured = 0
	state.unit_abilities.control_done = ""
	state.units[ancient_model].wounds = 0
	C._resolve_current_end_control(state)
	check(state.mission.objectives[0].secured == 0, "A destroyed Ancient cannot secure an objective with its banner")
	print("Victrix Honour Guard profile and rule checks: %d failures" % failures)
	quit(1 if failures else 0)

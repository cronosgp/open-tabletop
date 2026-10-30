extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const F = preload("res://tests/all_units_fixture.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const C = F.C
const INVICTOR_ID := "40kdc:11e:adeptus-astartes:invictor-tactical-warsuit"
const WEAPONS := {
	"fragstorm-grenade-launcher": {"melee": false, "profile": "standard", "range_inches": 18.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 1}},
	"heavy-bolter": {"melee": false, "profile": "standard", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1, "rapid-fire": 2}},
	"incendium-cannon": {"melee": false, "profile": "standard", "range_inches": 12.0, "attacks": 4, "skill": 0, "strength": 6, "ap": -1, "damage": 2, "keywords": {"torrent": true, "blast": 2}},
	"ironhail-heavy-stubbers": {"melee": false, "profile": "standard", "range_inches": 36.0, "attacks": 6, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 6}},
	"twin-ironhail-autocannon": {"melee": false, "profile": "standard", "range_inches": 48.0, "attacks": 4, "skill": 3, "strength": 9, "ap": -1, "damage": 3, "keywords": {"twin-linked": true}},
	"invictor-fist": {"melee": true, "profile": "standard", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 12, "ap": -2, "damage": 3, "keywords": {}}
}
var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000,
		"entries": [{"definition_id": INVICTOR_ID, "models": 1, "copies": copies}]}

func scenario_selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": INVICTOR_ID, "models": 1, "copies": 1}]
	return result

func first_model(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and state.units[model].wounds > 0 and Abilities.identity(state.units[model]) == identity: return model
	return -1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func check_weapon_profile(state: Dictionary, squad: int, model: int, target_squad: int, weapon_id: String) -> Dictionary:
	var expected: Dictionary = WEAPONS[weapon_id]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon_id, str(expected.profile))
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon_id)
	if not str(selected.get("error", "")).is_empty(): return {}
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the pinned source profile" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s keeps every source weapon trait" % weapon_id)
	var prior_phase: String = str(state.phase)
	var prior_active: int = int(state.active)
	var target_models: Array[int] = C.living(state, target_squad)
	if target_models.is_empty():
		check(false, "The weapon plan has a living target model")
		return {}
	var target_model: int = target_models[0]
	var old_positions := {}
	for member: int in C.living(state, squad) + target_models: old_positions[member] = state.units[member].position
	state.units[model].position = Vector2.ZERO
	var target_distance := 1.0 if expected.melee else 5.0
	for index in range(target_models.size()):
		var member: int = target_models[index]
		state.units[member].position = Vector2(target_distance, 0) if member == target_model else Vector2(target_distance, 4 + index * 3)
	state.phase = "fight" if expected.melee else "shooting"
	state.active = int(state.squads[squad].owner)
	var plan: Dictionary = AttackPlan.prepare(state, squad, bool(expected.melee), [{"model": model, "target": target_squad, "amount": int(selected.stats.attacks) if expected.melee else 1, "weapon": weapon_id, "profile": str(expected.profile)}], false)
	state.phase = prior_phase
	state.active = prior_active
	for member: int in old_positions: state.units[member].position = old_positions[member]
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan preserves %s as the attack source" % weapon_id)
	return plan

func submit_choice(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Invictor choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("invictor-tactical-warsuit")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001156" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Invictor identity matches the selected local Space Marines export")
	check(profile.points_by_models == {1: 135} and profile.third_plus_points_by_models == {1: 150} and profile.max_supported_copies == 3, "Invictor first/second and third-plus copy costs and limit match export")
	check(profile.stats == {"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.damaged_threshold == 4 and profile.base_radius_inches == 45.0 / 25.4, "Invictor characteristics, Damaged 4 and 90mm circular base match export")
	var expected_keywords := ["ADEPTUS ASTARTES", "IMPERIUM", "PHOBOS", "VEHICLE", "WALKER"]
	var actual_keywords: Array = profile.keywords.duplicate()
	actual_keywords.sort()
	expected_keywords.sort()
	check(actual_keywords == expected_keywords, "All five source datasheet keywords are retained")
	check(profile.ranged.size() == 4 and profile.ranged[0].id == "fragstorm-grenade-launcher" and profile.ranged[1].id == "heavy-bolter" and profile.ranged[2].id == "incendium-cannon" and profile.ranged[3].id == "ironhail-heavy-stubbers" and profile.melee[0].id == "invictor-fist", "Invictor default weapons match the local sheet")
	check(profile.ranged[0].profiles.standard.keywords == {"blast": 1} and profile.ranged[1].profiles.standard.keywords == {"sustained-hits": 1, "rapid-fire": 2} and profile.ranged[2].profiles.standard.skill == 0 and profile.ranged[2].profiles.standard.keywords == {"torrent": true, "blast": 2} and profile.ranged[3].profiles.standard.keywords == {"rapid-fire": 6}, "Invictor default weapon traits and automatic hit profile match export")
	var autocannon := Profiles.invictor_weapons(true)
	check(autocannon.size() == 4 and autocannon[2].id == "twin-ironhail-autocannon" and autocannon[2].profiles.standard.keywords == {"twin-linked": true}, "Optional Twin Ironhail Autocannon replaces the Incendium Cannon")
	check(Army.SPECS["invictor-tactical-warsuit"].current_reference and Army.SPECS["invictor-tactical-warsuit"].max_supported_copies == 3, "Invictor admission remains tied to this current profile and copy limit")
	var catalog_choice := Army.current_catalog_choice({"id": INVICTOR_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 135, "third_plus_cost": 150}], "Current construction exposes the source model count and both copy tiers")
	var admitted := Army.admit(selection())
	var three := Army.admit(selection(3))
	var four := Army.admit(selection(4))
	check(admitted.error.is_empty() and admitted.total == 135 and three.error.is_empty() and three.total == 420 and not four.error.is_empty(), "Local construction uses source costs and rejects a fourth Invictor: %s / %d; %s / %d; %s" % [admitted.get("error", ""), admitted.get("total", -1), three.get("error", ""), three.get("total", -1), four.get("error", "")])
	var demise_state := {"units": {100: {"definition_id": INVICTOR_ID, "owner": 1, "squad": 1, "wounds": 0, "max_wounds": 12, "position": Vector2.ZERO, "radius": 45.0 / 25.4}, 200: {"definition_id": "intercessor-squad", "owner": 2, "squad": 2, "wounds": 5, "max_wounds": 5, "position": Vector2(5, 0), "radius": 0.0}}, "squads": {1: {"owner": 1, "name": "Invictor"}, 2: {"owner": 2, "name": "Intercessors"}}, "unit_abilities": {"implementation": Abilities.ID, "window": {}}, "pending_attack": {}, "awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice = [5]
	var quiet_demise := DeadlyDemise.begin(demise_state, [100], roll_die)
	var triggered_state: Dictionary = demise_state.duplicate(true)
	dice = [6, 1]
	var triggered_demise := DeadlyDemise.begin(triggered_state, [100], roll_die)
	var demise_packet: Dictionary = triggered_state.get("pending_deadly_demise", {}).get("packets", [{}])[0]
	check(quiet_demise.get("error", "").is_empty() and quiet_demise.complete and demise_state.last_deadly_demise.events[0].expression == "D3" and not demise_state.last_deadly_demise.events[0].triggered and demise_state.last_deadly_demise.events[0].targets.is_empty(), "Invictor resolves the exported Deadly Demise D3 check without triggering on 5")
	check(triggered_demise.get("error", "").is_empty() and not triggered_demise.complete and triggered_state.pending_deadly_demise.events[0].triggered and demise_packet.get("owner", -1) == 2 and demise_packet.get("target", -1) == 2 and demise_packet.get("remaining", -1) == 1, "Invictor Deadly Demise D3 triggers on a 6 and opens the target player's mortal-wound allocation")

	var selections := scenario_selections()
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections)
	check(not state.has("error"), "Invictor materializes from the consolidated current Space Marines catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var invictor := first_model(state, "invictor-tactical-warsuit", 1)
		var enemy_models: Array[int] = []
		var enemy_squads: Array[int] = []
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner != 2 or Abilities.identity(unit) != "intercessor-squad": continue
			if int(unit.squad) not in enemy_squads:
				enemy_squads.append(int(unit.squad))
				enemy_models.append(model)
		enemy_squads.sort()
		var marked_model := first_model(state, "intercessor-squad", 2)
		var marked_squad := int(state.units[marked_model].squad) if marked_model >= 0 else -1
		var replacement_model := -1
		for model: int in enemy_models:
			if state.units[model].squad != marked_squad: replacement_model = model; break
		var replacement_squad := int(state.units[replacement_model].squad) if replacement_model >= 0 else -1
		check(invictor >= 0 and marked_model >= 0 and replacement_model >= 0 and enemy_squads.size() == 2, "Current-catalog match includes the Invictor and two enemy target units")
		if invictor >= 0 and marked_model >= 0 and replacement_model >= 0:
			var inv_squad: int = state.units[invictor].squad
			var warrior_squad: int = marked_squad
			var immortal_squad: int = replacement_squad
			check(state.units[invictor].ranged_weapons.size() == 4 and state.units[invictor].melee_weapons.size() == 1 and state.squads[inv_squad].training_cost == 135, "The materialized Invictor has its five source-listed default weapons and 135-point cost")
			for keyword: String in expected_keywords: check(Terrain.has_keyword(state.units[invictor], [keyword.to_lower()]), "The model carries the %s source keyword" % keyword)
			check(int(state.units[invictor].max_wounds) == 12 and int(state.squads[inv_squad].stats.toughness) == 9 and int(state.squads[inv_squad].stats.save_target) == 3, "Materialized model and squad characteristics retain T9, Sv3+ and 12 wounds")
			for weapon_id: String in ["fragstorm-grenade-launcher", "heavy-bolter", "incendium-cannon", "ironhail-heavy-stubbers", "invictor-fist"]:
				check_weapon_profile(state, inv_squad, invictor, warrior_squad, weapon_id)
			state.awakened_dynasty.pending = []
			var reserve_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "reserve" and option.target == inv_squad: reserve_choice = option
			check(not reserve_choice.is_empty(), "The Invictor's Scouts 8 ability makes it eligible for Strategic Reserves set-up")
			var equipment: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-gun" and option.model == invictor and option.value == "autocannon": equipment = option
			check(not equipment.is_empty(), "Deployment exposes the Invictor autocannon replacement")
			if not equipment.is_empty():
				var before_rejected_equipment := var_to_bytes(state)
				var wrong_owner_equipment := PublicUnitCommand.submit(state, 2, equipment)
				var decision := PendingDecisions.current(state, ["unit-actions"])
				var stale_equipment := PublicUnitCommand.submit(state, 1, equipment, Vector2.ZERO, Callable(), str(decision.get("decision_id", "stale-decision")), "stale-option-id")
				check(not str(wrong_owner_equipment.get("error", "")).is_empty() and not str(stale_equipment.get("error", "")).is_empty() and before_rejected_equipment == var_to_bytes(state), "Wrong-owner and stale autocannon choices are rejected without changing the loadout")
				var equipment_result := PublicUnitCommand.submit(state, 1, equipment)
				check(str(equipment_result.get("error", "")).is_empty() and state.units[invictor].ranged_weapons[2].id == "twin-ironhail-autocannon", "The public deployment command equips the optional autocannon")
				check_weapon_profile(state, inv_squad, invictor, warrior_squad, "twin-ironhail-autocannon")
				var restore_equipment: Dictionary = {}
				for option: Dictionary in UnitActions.choices(state, 1):
					if option.action == "invictor-gun" and option.model == invictor and option.value == "incendium": restore_equipment = option
				var restore_result := PublicUnitCommand.submit(state, 1, restore_equipment)
				check(not restore_equipment.is_empty() and str(restore_result.get("error", "")).is_empty() and state.units[invictor].ranged_weapons[2].id == "incendium-cannon", "The public choice restores the Incendium Cannon")
				check_weapon_profile(state, inv_squad, invictor, warrior_squad, "incendium-cannon")
			var healthy_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			var starting_wounds: int = int(state.units[invictor].wounds)
			state.units[invictor].wounds = 4
			var damaged_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			state.units[invictor].wounds = starting_wounds
			check(healthy_plan.get("error", "").is_empty() and healthy_plan.batches[0].context.hit_modifier == 0 and damaged_plan.get("error", "").is_empty() and damaged_plan.batches[0].context.hit_modifier == -1, "Damaged 4 applies a -1 Hit modifier in the Invictor's actual attack plan at four remaining wounds")
			check(Abilities.scout_distance(state, inv_squad) == 8, "The exported Scouts 8-inch ability is registered for this Invictor")
			state.phase = "start_turn"
			state.turn = 1
			state.round = 1
			state.active = 1
			state.first_player = 1
			state.unit_abilities.battle_players = []
			check(UnitActions.battle_actor(state) == 1, "The Invictor owner receives the first-battle-round Forward Assault declaration")
			var mark_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-mark" and option.model == invictor and option.target == warrior_squad: mark_choice = option
			check(not mark_choice.is_empty(), "Start-of-round choices offer enemy units as the Invictor mark")
			if not mark_choice.is_empty():
				var mark_result := submit_choice(state, 1, mark_choice)
				check(str(mark_result.get("error", "")).is_empty() and Abilities.forward_assault_mark(state, inv_squad) == warrior_squad, "Forward Assault stores the selected enemy mark through the normalized command")
			state.units[invictor].position = Vector2(6, 0)
			state.units[marked_model].position = Vector2(12, 0)
			state.units[replacement_model].position = Vector2(13, 0)
			var scout_probe := state.duplicate(true)
			scout_probe.terrain = {"id": "terrain-11e-v1", "areas": []}
			scout_probe.unit_abilities.window = {"kind": "scouts", "squad": inv_squad, "reserved": false, "setup": false,
				"origins": {invictor: Vector2(6, 0)}, "positions": {invictor: Vector2(6, 0)}}
			var scout_eight_error := ScoutMoves.position_error(scout_probe, invictor, Vector2(-2, 0))
			check(scout_eight_error.is_empty(), "Scout movement accepts the Invictor's full 8-inch move: %s" % scout_eight_error)
			check(ScoutMoves.position_error(scout_probe, invictor, Vector2(-2.01, 0)).contains("more than its Scouts distance"), "Scout movement rejects movement beyond the Invictor's 8-inch allowance")
			var marked_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			var unmarked_plan := AttackPlan.prepare(state, inv_squad, false, [{"model": invictor, "target": immortal_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
			check(marked_plan.error.is_empty() and marked_plan.batches[0].context.get("wound_reroll", "") == "ones", "Invictor attacks against its current mark re-roll Wound rolls of 1")
			check(unmarked_plan.error.is_empty() and unmarked_plan.batches[0].context.get("wound_reroll", "none") == "none", "Forward Assault does not grant re-rolls against an unmarked unit")
			for target_model: int in state.units:
				if state.units[target_model].squad == warrior_squad and target_model != marked_model: state.units[target_model].wounds = 0
			state.units[marked_model].wounds = 1
			state.phase = "shooting"
			state.active = 1
			state.squads[inv_squad].shot = false
			dice = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 1, 1, 1, 1, 1]
			var attack := F.C.resolve_attack_plan(state, 1, invictor, [{"model": invictor, "target": warrior_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], state.revision, false, false, roll_die)
			var allocation_error := F.C.allocate_damage(state, 2, marked_model, state.revision, roll_die)
			check(attack.get("error", "").is_empty() and allocation_error.is_empty() and state.units[marked_model].wounds == 0 and state.unit_abilities.window.get("kind", "") == "forward-assault-mark", "Destroying the marked enemy through a resolved attack opens the replacement choice: attack=%s allocation=%s" % [attack.get("error", ""), allocation_error])
			var post_attack_frame := ResolutionFrames.current(state)
			var post_attack_decision := UnitActions.pending_decision(state)
			check(post_attack_frame.get("kind", "") == "attack" and post_attack_frame.get("status", "") == "suspended" and post_attack_frame.get("resume_point", "") == "attack-mark-replacement", "Invictor mark replacement suspends the in-progress attack frame")
			check(post_attack_decision.get("resume_frame_id", "") == post_attack_frame.get("frame_id", ""), "Invictor replacement decision retains the attack frame identity")
			check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "Shooting close remains blocked while Forward Assault needs a replacement mark")
			var replacement: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "invictor-mark" and option.model == invictor and option.target == immortal_squad: replacement = option
			check(not replacement.is_empty(), "Destroyed mark can be replaced by another living enemy: window=%s choices=%s" % [str(state.unit_abilities.window), str(UnitActions.choices(state, 1))])
			if not replacement.is_empty():
				var before_wrong_owner := var_to_bytes(state)
				var wrong_owner_result := submit_choice(state, 2, replacement)
				check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The defender cannot submit or mutate the Invictor replacement decision")
				var saved_frame_id: String = str(post_attack_frame.get("frame_id", ""))
				state = bytes_to_var(var_to_bytes(state))
				post_attack_decision = PendingDecisions.current(state, ["unit-actions"])
				check(post_attack_decision.get("resume_frame_id", "") == saved_frame_id, "Invictor replacement and attack frame survive save/restore")
				for option: Dictionary in UnitActions.choices(state, 1):
					if option.action == "invictor-mark" and option.model == invictor and option.target == immortal_squad: replacement = option
				var replacement_result := submit_choice(state, 1, replacement)
				check(str(replacement_result.get("error", "")).is_empty() and Abilities.forward_assault_mark(state, inv_squad) == immortal_squad and state.unit_abilities.window.is_empty(), "Replacement target becomes the current mark through the normalized command")
				check(ResolutionFrames.current(state).is_empty(), "Completing the Invictor mark replacement closes the attack continuation")
	if failures == 0: print("Invictor Tactical Warsuit checks: 0 failures")
	else: push_error("Invictor Tactical Warsuit checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

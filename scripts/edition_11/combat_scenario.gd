extends RefCounted
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Reivers = preload("res://scripts/edition_11/reivers.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AncientFury = preload("res://scripts/edition_11/medusa_ancient_fury.gd")
const AdeptOfTheOmnissiah = preload("res://scripts/edition_11/adept_of_the_omnissiah.gd")
## Restricted integration exercise, not a complete official 11e match.
## Individual movement, optional varied training equipment and defender allocation.

const Pack = preload("res://scripts/data_pack.gd")
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Movement = preload("res://scripts/rules.gd") # Legacy fixture geometry/API.
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const ContactActions = preload("res://scripts/edition_11/contact_actions.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ImplacableEradication = preload("res://scripts/edition_11/implacable_eradication.gd")
const ObjectiveSecured = preload("res://scripts/edition_11/objective_secured.gd")
const HailOfBolts = preload("res://scripts/edition_11/hail_of_bolts.gd")
const Awakened = preload("res://scripts/edition_11/awakened_dynasty.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const OathOfMoment = preload("res://scripts/edition_11/oath_of_moment.gd")
const VowedTarget = preload("res://scripts/edition_11/vowed_target.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Hazard = preload("res://scripts/edition_11/hazardous.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const PhaseProgression = preload("res://scripts/edition_11/phase_progression.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const PhaseResolution = preload("res://scripts/edition_11/phase_resolution.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const RulesetIdentity = preload("res://scripts/edition_11/ruleset_identity.gd")
const MatchActor = preload("res://scripts/edition_11/match_actor.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const PurgationRun = preload("res://scripts/edition_11/purgation_run.gd")
const PhobosShadowMasters = preload("res://scripts/edition_11/phobos_shadow_masters.gd")
const PhobosExecuteRedeploy = preload("res://scripts/edition_11/phobos_execute_redeploy.gd")
const VictrixHonourGuard = preload("res://scripts/edition_11/victrix_honour_guard.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const PACK_ID := RulesetIdentity.PACK_ID
const DIRECTORY := "res://data/imported/starter-11e-v1"
const PHASES := PhaseProgression.PHASES
const DISABLED := "Unlisted unit/faction abilities, official missions, stratagems, official mission actions, terrain beyond the bounded training surfaces and exact imported-mesh visibility are not implemented. Unproved approach exceptions remain restricted."

static func initial_state(terrain_id: String = Terrain.DEFAULT_LAYOUT, mission_id: String = "elimination", squads_per_side: int = 1, manual_allocation: bool = false, varied_equipment: bool = false, current_marine_templates: bool = false) -> Dictionary:
	if squads_per_side not in [1, 2]: return {"error": "Supported exercise size is one or two squads per player."}
	if current_marine_templates and varied_equipment: return {"error": "Current-catalog match templates use fixed sourced loadouts."}
	var terrain := Terrain.layout(terrain_id)
	if terrain.has("error"): return terrain
	var mission := Objectives.setup(terrain, mission_id)
	if mission.has("error"): return mission
	var squads: Dictionary = {}
	var units: Dictionary = {}
	var hashes := PACK_ID + var_to_str(terrain) + var_to_str(mission) + str(squads_per_side) + str(manual_allocation) + str(varied_equipment)
	var current_template := CurrentMarineProfiles.profile("intercessor-squad") if current_marine_templates else {}
	if current_marine_templates and (current_template.is_empty() or current_template.get("ranged", []).is_empty() or current_template.get("melee", []).is_empty()): return {"error": "Current Marine base template is unavailable."}
	for side in [1, 2]:
		var definition: Dictionary = {}
		var gun: Dictionary = {}
		var blade: Dictionary = {}
		var gun_name := "bolt-rifle-intercessor-squad" if side == 1 else "gauss-flayer"
		if current_marine_templates:
			definition = {"id": "40kdc:11e:adeptus-astartes:intercessor-squad", "name": current_template.name, "faction": "Space Marines",
				"stats": current_template.stats, "keywords": current_template.keywords, "base": {"radius_inches": current_template.base_radius_inches}, "unsupported_rules": []}
			gun = current_template.ranged[0].profiles.values()[0].duplicate(true)
			blade = current_template.melee[0].profiles.values()[0].duplicate(true)
			hashes += CurrentMarineProfiles.digest()
		else:
			var faction := "adeptus-astartes" if side == 1 else "necrons"
			var pack: Dictionary = Pack.load_pack(DIRECTORY.path_join(faction))
			if not pack.error.is_empty(): return {"error": "Import starter data first: " + pack.error}
			hashes += pack.manifest.units_sha256
			var wanted := "intercessor-squad" if side == 1 else "necron-warriors"
			for record: Dictionary in pack.units:
				if record.source_id == wanted: definition = record
			if definition.is_empty() or not definition.get("base") is Dictionary:
				return {"error": "Missing selected datasheet or base geometry: " + wanted}
			gun = _weapon(definition, gun_name, "Saturation" if side == 1 else "Gauss flayer")
			if gun.is_empty(): return {"error": "Missing fixed loadout: " + gun_name}
			blade = _weapon(definition, "close-combat-weapon-intercessor-squad" if side == 1 else "close-combat-weapon", "Knives and Fists" if side == 1 else "Close combat weapon")
			if blade.is_empty(): return {"error": "Missing fixed melee loadout."}
		var stats: Dictionary = definition.stats
		for key in ["movement_inches", "toughness", "save_target", "wounds", "leadership_target", "objective_control"]:
			if not Attacks._positive_integer(stats.get(key)): return {"error": "Unresolved stat: " + key}
		var count := int(current_template.models) if current_marine_templates else (5 if side == 1 else 10)
		squads[side] = {"owner": side, "name": definition.name, "faction": definition.faction,
			"starting_strength": count, "battle_shocked": false,
			"move_type": "unselected", "advanced": false, "fell_back": false, "normal_moved_this_turn": false, "normal_move_phase_key": "",
			"overrun_used": false,
			"last_ranged_turn": -1, "started_action_turn": -1, "action": {}, "last_action": {},
			"weapon": gun, "melee_weapon": blade, "stats": stats.duplicate(true), "moved": false, "shot": false,
			"charge_declared": false, "charged": false, "fought": false, "was_engaged": false, "fight_eligible": false,
			"moved_distance": 0.0, "set_up_this_turn": false, "disabled_abilities": definition.get("unsupported_rules", [])}
		for index in range(count):
			var id: int = side * 100 + index
			# Two files for Warriors; all models are real pieces, not squad proxies.
			var column := floori(index / 5.0)
			var row := index % 5
			units[id] = {"owner": side, "squad": side, "position": Vector2(-12 if side == 1 else 12 + column * 1.5, (row - 2) * 2.0),
				"keywords": definition.get("keywords", []).duplicate(), "sight_height": 1.3, "elevation": 0.0,
				"moved": false, "movement": stats.movement_inches, "radius": definition.base.radius_inches,
				"wounds": int(stats.wounds), "max_wounds": int(stats.wounds), "definition_id": definition.id}
		if varied_equipment:
			for index in range(count):
				var model: Dictionary = units[side * 100 + index]
				if side == 1:
					model.ranged_weapons = [{"id": "rifle", "profiles": {"saturation": gun.duplicate(true), "focused": _weapon(definition, gun_name, "Focused Fire")}}]
					model.melee_weapons = [{"id": "knives", "profiles": {"standard": blade.duplicate(true)}}]
					if index == 0:
						model.melee_weapons.append({"id": "chainsword", "profiles": {"standard": _weapon(definition, "astartes-chainsword-intercessor-squad", "Chainsword")}})
						model.melee_weapons.append({"id": "hammer", "profiles": {"standard": _weapon(definition, "thunder-hammer-intercessor-squad", "Thunder Hammer")}})
						model.ranged_weapons.append({"id": "plasma", "profiles": {"standard": _weapon(definition, "plasma-pistol-intercessor-squad", "Standard"), "supercharge": _weapon(definition, "plasma-pistol-intercessor-squad", "Supercharge")}})
					if index == 1: model.ranged_weapons.append({"id": "launcher", "profiles": {"krak": _weapon(definition, "astartes-grenade-launcher-intercessor-squad", "Krak"), "frag": _weapon(definition, "astartes-grenade-launcher-intercessor-squad", "Frag")}})
				else:
					var reaper := index % 2 == 1
					model.ranged_weapons = [{"id": "reaper" if reaper else "flayer", "profiles": {"standard": _weapon(definition, "gauss-reaper", "Gauss reaper") if reaper else gun.duplicate(true)}}]
					model.melee_weapons = [{"id": "knives", "profiles": {"standard": blade.duplicate(true)}}]
				for melee in [false, true]:
					for option: Dictionary in AttackPlan.Equipment.choices({"units": units, "squads": squads}, side * 100 + index, melee):
						var validation := Attacks._validate(option.stats, {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}, {"distance_inches": 0.0, "heavy_eligible": false, "target_model_count": 1, "target_engaged": false})
						if not validation.is_empty(): return {"error": "Unsupported training equipment: " + validation}
	if squads_per_side == 2:
		for side in [1, 2]:
			var extra: int = side + 2
			squads[extra] = squads[side].duplicate(true)
			squads[side].name += " I"
			squads[extra].name += " II"
			for index in range(int(squads[side].starting_strength)):
				var original: int = side * 100 + index
				units[original].position.y = -4.0 + (index % 5 - 2) * 1.3
				units[extra * 100 + index] = units[original].duplicate(true)
				units[extra * 100 + index].squad = extra
				units[extra * 100 + index].position.y += 8.0
	return {"pack": PACK_ID, "pack_hash": hashes.sha256_text(), "terrain": terrain, "mission": mission, "revision": 0, "phase": "start_turn",
		"varied_equipment": varied_equipment, "manual_allocation": manual_allocation, "pending_attack": {}, "pending_hazard": {}, "squads_per_side": squads_per_side, "pile_done": [], "consolidate_done": [], "reaction_queue": [], "fight_selected": -1, "turn": 1, "round": 1, "active": 1, "units": units, "squads": squads,
		"cp": {1: 0, 2: 0}, "events": [], "test_winner": 0, "scope": DISABLED, "capabilities": {},
		"pending_move": {}, "pending_charge": {}, "pending_contact": {}, "pending_deadly_demise": {}, "consolidation_return": 0,
		"fight_step": "complete", "fight_actor": 1, "fight_priority": "first"}

static func _weapon(definition: Dictionary, weapon_id: String, profile_name: String) -> Dictionary:
	for weapon: Dictionary in definition.get("source_weapon_definitions", []):
		if weapon.get("id") != weapon_id: continue
		for profile: Dictionary in weapon.get("profiles", []):
			if profile.get("name") != profile_name: continue
			var stats: Dictionary = profile.stats
			var keywords := Attacks.Traits.import_profile(profile)
			return {"name": "%s / %s" % [weapon.name, profile.name], "attacks": stats.get("A"), "skill": stats.get("BS", stats.get("WS")), "strength": stats.get("S"),
				"ap": stats.get("AP"), "damage": stats.get("D"), "range_inches": profile.get("range"), "keywords": keywords}
	return {}

static func living(state: Dictionary, squad: int) -> Array[int]:
	var ids: Array[int] = []
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true): ids.append(id)
	return ids

static func actor(state: Dictionary) -> int:
	return MatchActor.player(state)

static func living_owner(state: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	for id: int in state.units:
		if state.units[id].owner == player and state.units[id].wounds > 0: result.append(id)
	return result

static func incoherent_squad(state: Dictionary) -> int:
	return MatchActor.incoherent_squad(state)

static func remove_for_coherency(state: Dictionary, player: int, model: int, revision: int) -> String:
	var continuation_action_id := ""
	var expected_close_action_id := "phase-close:%d:end_turn" % int(state.get("turn", 0))
	var frame := ResolutionFrames.current(state)
	if str(frame.get("kind", "")) == "phase-close" and str(frame.get("action_id", "")) == expected_close_action_id:
		continuation_action_id = expected_close_action_id
	var error := _command_error(state, player, revision, continuation_action_id, "coherency")
	if not error.is_empty(): return error
	if state.phase != "end_turn": return "Coherency removals happen at End of Turn."
	var squad := incoherent_squad(state)
	if squad == -1: return "All squads are coherent."
	if not state.units.has(model) or state.units[model].wounds <= 0 or state.units[model].squad != squad:
		return "Select a living model in your incoherent squad."
	# No destroyed-model ability triggers are generated by this removal.
	state.units[model].wounds = 0
	if incoherent_squad(state) == -1 and not continuation_action_id.is_empty():
		var resumed := ResolutionFrames.begin(state, "phase-close", continuation_action_id, "end-turn-close")
		if resumed.is_empty(): return "Could not resume the End-of-Turn coherency frame."
	_event(state, "Player %d removed model %d to restore coherency." % [player, model])
	return ""

static func _command_error(state: Dictionary, player: int, expected_revision: int, continuation_action_id: String = "", resolved_decision_source: String = "") -> String:
	return PhaseCloseGate.command_error(state, player, expected_revision, continuation_action_id, resolved_decision_source)

static func _core_reaction_phase_close_action_id(state: Dictionary, player: int) -> String:
	if CoreReactions.actor(state) != player: return ""
	var frame := ResolutionFrames.current(state)
	var action_id := "phase-close:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]
	if str(frame.get("kind", "")) != "phase-close" or str(frame.get("action_id", "")) != action_id or str(frame.get("status", "")) != "suspended": return ""
	return action_id

static func _event(state: Dictionary, message: String) -> void:
	Actions.reconcile(state)
	UnitActions.reconcile(state)
	_settle_phase_start_frame(state)
	_settle_counteroffensive_frame(state)
	_settle_vengeful_frame(state)
	state.revision += 1
	state.events.append({"revision": state.revision, "message": message})
	if state.events.size() > 30: state.events.pop_front()

static func _record_training_attack(state: Dictionary, entries: Array, prepared: Dictionary) -> void:
	var tracker_value: Variant = state.get("training_experiments", {})
	if typeof(tracker_value) != TYPE_DICTIONARY or tracker_value.is_empty(): return
	var tracker: Dictionary = tracker_value
	for raw_entry: Variant in entries:
		if not raw_entry is Dictionary: continue
		var weapon := str(raw_entry.get("weapon", "")).to_lower()
		if not weapon.contains("plasma"): continue
		match str(raw_entry.get("profile", "")).to_lower():
			"standard": tracker.standard_plasma = true
			"supercharge": tracker.supercharged_plasma = true
	if int(prepared.get("hazardous_count", 0)) > 0: tracker.hazardous = true
	state.training_experiments = tracker

static func advance_phase(state: Dictionary, player: int, revision: int, roller: Callable = Callable(), selected_squad: int = -1) -> String:
	var error := PhaseCloseGate.close_request_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase == "fight" and state.fight_step != "complete": return _advance_fight(state, player, false, selected_squad)
	var hooks := {
		"event": func(current: Dictionary, message: String) -> void: _event(current, message),
		"begin_fights": func(current: Dictionary) -> void: _begin_fight(current)
	}
	return PhaseResolution.advance_after_admission(state, roller, hooks)

static func _phase_start_action_id(state: Dictionary) -> String:
	return "phase-start:%d:%s:%d" % [int(state.get("turn", 0)), str(state.get("phase", "")), int(state.get("active", -1))]

static func _counteroffensive_action_id(state: Dictionary) -> String:
	var window := UnitActions.pending(state)
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") != "counter" or owners.is_empty() or UnitActions.pending_decision(state).is_empty(): return ""
	return "fight-counter:%d:%d:%d" % [int(state.get("turn", 0)), int(window.get("fighter", -1)), int(owners[0])]

static func _settle_counteroffensive_frame(state: Dictionary) -> void:
	var action_id := _counteroffensive_action_id(state)
	var frame := ResolutionFrames.current(state)
	if not action_id.is_empty():
		if not frame.is_empty() and str(frame.get("kind", "")) == "attack": return
		if frame.is_empty():
			frame = ResolutionFrames.begin(state, "fight", action_id, "counteroffensive-choice")
			if frame.is_empty(): return
			ResolutionFrames.suspend(state, str(frame.frame_id), "counteroffensive-choice")
		elif str(frame.get("kind", "")) == "fight" and str(frame.get("action_id", "")) == action_id:
			if str(frame.get("status", "")) == "resolving": ResolutionFrames.suspend(state, str(frame.frame_id), "counteroffensive-choice")
		return
	if not frame.is_empty() and str(frame.get("kind", "")) == "fight" and str(frame.get("action_id", "")).begins_with("fight-counter:"):
		ResolutionFrames.complete(state, str(frame.frame_id))

static func _vengeful_action_id(state: Dictionary) -> String:
	if DetachmentStratagems.shooting_reaction_actor(state) <= 0: return ""
	var data: Dictionary = state.get("detachment_stratagems", {}).get("vengeful", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("hail_of_vengeance", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("hail_of_vengeance_pending", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("storm_of_vengeance_pending", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("medusa_power_pending", {})
	if data.is_empty(): data = state.get("detachment_stratagems", {}).get("after", {})
	if data.is_empty(): return ""
	var owner := int(data.get("player", 3 - int(state.get("active", -1))))
	if owner <= 0: return ""
	return "shooting-reaction:%d:%d:%d" % [int(state.get("turn", 0)), owner, int(data.get("attacker", -1))]

static func _settle_vengeful_frame(state: Dictionary) -> void:
	var action_id := _vengeful_action_id(state)
	var frame := ResolutionFrames.current(state)
	if not action_id.is_empty():
		if not frame.is_empty() and str(frame.get("kind", "")) == "attack": return
		if frame.is_empty():
			frame = ResolutionFrames.begin(state, "shooting-reaction", action_id, "vengeful-choice")
			if frame.is_empty(): return
			ResolutionFrames.suspend(state, str(frame.frame_id), "vengeful-choice")
		elif str(frame.get("kind", "")) == "shooting-reaction" and str(frame.get("action_id", "")) == action_id:
			if str(frame.get("status", "")) == "resolving": ResolutionFrames.suspend(state, str(frame.frame_id), "vengeful-choice")
		return
	if not frame.is_empty() and str(frame.get("kind", "")) == "shooting-reaction" and str(frame.get("action_id", "")).begins_with("shooting-reaction:"):
		ResolutionFrames.complete(state, str(frame.frame_id))

static func _settle_phase_start_frame(state: Dictionary) -> void:
	var pending_choice: bool = Doctrines.needs_choice(state) or OathOfMoment.needs_choice(state) or VowedTarget.needs_choice(state) or not UnitActions.phase_decision(state).is_empty() or not state.get("fearsome_assault", {}).is_empty() or not DetachmentStratagems.adamantine_pending(state).is_empty()
	var action_id := _phase_start_action_id(state)
	var frame := ResolutionFrames.current(state)
	if not frame.is_empty() and (str(frame.get("kind", "")) != "phase-start" or str(frame.get("action_id", "")) != action_id): return
	if frame.is_empty():
		if not pending_choice: return
		frame = ResolutionFrames.begin(state, "phase-start", action_id, "phase-start-choice")
		if frame.is_empty(): return
		ResolutionFrames.suspend(state, str(frame.frame_id), "phase-start-choice")
		return
	if pending_choice:
		if str(frame.get("status", "")) == "resolving": ResolutionFrames.suspend(state, str(frame.frame_id), "phase-start-choice")
	else:
		ResolutionFrames.complete(state, str(frame.frame_id))

static func _resolve_vanguard_ambushers(state: Dictionary) -> void:
	PhaseResolution._resolve_vanguard_ambushers(state)

static func select_oath_target(state: Dictionary, player: int, target: int, revision: int) -> String:
	var error := OathOfMoment.choice_error(state, player, target, revision)
	if not error.is_empty(): return error
	OathOfMoment.select_target(state, player, target)
	_event(state, "Player %d: Oath of Moment targets %s (June 2026 rules profile)." % [player, state.squads[target].name])
	return ""

static func select_vowed_objective(state: Dictionary, player: int, objective_index: int, revision: int) -> String:
	var error := VowedTarget.choice_error(state, player, objective_index, revision)
	if not error.is_empty(): return error
	VowedTarget.select_objective(state, player, objective_index)
	if objective_index < 0:
		_event(state, "Player %d skipped Vowed Target for this Command phase." % player)
	else:
		var objective: Dictionary = state.mission.objectives[objective_index]
		_event(state, "Player %d selected %s as the Vowed objective until their next Command phase." % [player, str(objective.get("name", "Objective %d" % (objective_index + 1)))])
	return ""

static func resolve_command_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	var pending_kind := str(Stratagems.pending(state).get("kind", ""))
	if pending_kind not in ["before_battle_shock", "after_battle_shock_roll"]: return "There is no pending Battle-shock decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if pending_kind == "after_battle_shock_roll":
		var current_result: Dictionary = Stratagems.pending(state).get("current_result", {}).duplicate(true)
		if stratagem == "tempered-in-battle":
			if not MarineEnhancements.tempered_in_battle_active(state, squad): return "Tempered in Battle does not apply to this Leadership roll."
			var rerolled := Morale.roll_battle_shock(state, squad, roller, int(current_result.get("modifier", 0)))
			if not rerolled.error.is_empty(): return rerolled.error
			rerolled["rerolled_from"] = current_result.rolls.duplicate()
			rerolled["reroll_source"] = "tempered-in-battle"
			current_result = rerolled
		elif not stratagem.is_empty():
			return "Choose an available Leadership reroll or accept the current result."
		else:
			current_result["reroll_declined"] = true
		return _finish_command_battle_shock_roll(state, player, squad, current_result, revision, roller)
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
	var profile := Morale.leadership(state, squad)
	if not profile.error.is_empty(): return profile.error
	var result: Dictionary
	if stratagem.is_empty():
		result = Morale.roll_battle_shock(state, squad, roller)
		if not result.error.is_empty(): return result.error
		if MarineEnhancements.tempered_in_battle_active(state, squad):
			var staged := state.duplicate(true)
			staged.stratagems.pending.kind = "after_battle_shock_roll"
			staged.stratagems.pending.squad = squad
			staged.stratagems.pending.current_result = result.duplicate(true)
			_event(staged, "%s rolled Leadership %s vs %d. Choose whether to re-roll with Tempered in Battle or keep the result." % [staged.squads[squad].name, str(result.rolls), int(result.target)])
			state.clear()
			state.merge(staged, true)
			return ""
	else:
		result = {"error": "", "squad": squad, "rolls": [], "target": profile.target, "passed": true, "automatic": true, "stratagem": stratagem}
	var working := state.duplicate(true)
	if not stratagem.is_empty(): Stratagems.consume(working, player, squad, stratagem)
	error = _finish_command_battle_shock_roll(working, player, squad, result, revision, roller)
	if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func resolve_escape_morale_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	if Stratagems.pending(state).get("kind", "") != "after_escape_battle_shock_roll": return "There is no pending Desperate Escape Leadership decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	var current_result: Dictionary = Stratagems.pending(state).get("current_result", {}).duplicate(true)
	if stratagem == "tempered-in-battle":
		if not MarineEnhancements.tempered_in_battle_active(state, squad): return "Tempered in Battle does not apply to this Leadership roll."
		var rerolled := Morale.roll_battle_shock(state, squad, roller, int(current_result.get("modifier", 0)))
		if not rerolled.error.is_empty(): return rerolled.error
		rerolled["rerolled_from"] = current_result.rolls.duplicate()
		rerolled["reroll_source"] = "tempered-in-battle"
		current_result = rerolled
	elif not stratagem.is_empty():
		return "Choose Tempered in Battle or accept the current Leadership result."
	else:
		current_result["reroll_declined"] = true
	var working := state.duplicate(true)
	working.pending_move.morale_result = current_result.duplicate(true)
	working.stratagems.pending = {}
	error = finish_movement(working, player, working.revision, false, roller)
	if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func _finish_command_battle_shock_roll(state: Dictionary, player: int, squad: int, result: Dictionary, revision: int, roller: Callable) -> String:
	var working := state.duplicate(true)
	working.squads[squad].battle_shocked = not bool(result.get("passed", false))
	var window: Dictionary = working.stratagems.pending
	window.remaining.erase(squad)
	window.results.append(result.duplicate(true))
	working.last_morale = window.results.duplicate(true)
	if result.get("stratagem", "") == "insane-bravery":
		_event(working, "%s: Insane Bravery • 1 CP • Battle-shock passed automatically." % working.squads[squad].name)
	else:
		var result_source := " after Tempered in Battle's Leadership re-roll" if result.get("reroll_source", "") == "tempered-in-battle" else ""
		_event(working, "%s battle-shock%s: %s vs %d — %s." % [working.squads[squad].name, result_source, str(result.get("rolls", [])), int(result.get("target", 0)), "passed" if result.get("passed", false) else "battle-shocked"])
	window.erase("squad")
	window.erase("current_result")
	if window.remaining.is_empty():
		working.stratagems.pending = {}
		working.stratagems.command_done_turn = working.turn
		var error := advance_phase(working, player, working.revision, roller)
		if not error.is_empty(): return error
	else:
		window.kind = "before_battle_shock"
		window.phase_key = Stratagems.phase_key(working)
	state.clear()
	state.merge(working, true)
	return ""

static func _edge_distance(first: Dictionary, second: Dictionary) -> float:
	return maxf(0.0, first.position.distance_to(second.position) - float(first.radius) - float(second.radius))

static func _engaged(state: Dictionary, squad: int) -> bool:
	for id: int in living(state, squad):
		for enemy: int in state.units:
			if state.units[enemy].owner == state.units[id].owner or state.units[enemy].wounds <= 0 or not state.units[enemy].get("on_battlefield", true): continue
			if Contact.within_engagement(state.units[id], state.units[enemy]): return true
	return false

static func movement_remaining(state: Dictionary, id: int) -> float:
	if not state.units.has(id): return 0.0
	var unit: Dictionary = state.units[id]
	if unit.wounds <= 0 or state.squads[unit.squad].moved: return 0.0
	var spent := 0.0
	var bonus := 0.0
	var take_to_skies_penalty := 0.0
	if not state.pending_move.is_empty() and state.pending_move.squad == unit.squad:
		spent = float(state.pending_move.spent.get(id, 0.0))
		bonus = float(state.pending_move.get("bonus", 0))
		take_to_skies_penalty = float(state.pending_move.get("take_to_skies_penalty", 0.0))
	var characteristic_bonus := 0.0 if DetachmentStratagems.might_ignore_active(state, int(unit.squad)) else Doctrines.movement_bonus(state, int(unit.squad)) + AncientFury.movement_bonus(state, int(unit.squad))
	return maxf(0.0, float(unit.movement) + bonus + characteristic_bonus - take_to_skies_penalty - spent)

static func movement_choice_error(state: Dictionary, player: int, model: int, move_type: String, revision: int) -> String:
	var error := _command_error(state, player, revision)
	return movement_choice_error_after_command(state, player, model, move_type, error)

## Reuse the shared command precondition when a presentation layer checks every
## movement type for the same selected unit. The authoritative command path
## still calls movement_choice_error and recomputes the precondition itself.
static func movement_choice_error_after_command(state: Dictionary, player: int, model: int, move_type: String, command_error: String) -> String:
	if not command_error.is_empty(): return command_error
	if state.phase != "movement": return "Select movement types only in the Movement phase."
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player:
		return "Select a living model in your squad."
	if not state.pending_move.is_empty(): return "Finish the selected move before choosing another type."
	var squad: int = state.units[model].squad
	if state.squads[squad].moved: return "This squad has already resolved its move."
	if move_type not in ["normal", "advance", "ordered_retreat", "desperate_escape", "stationary"]:
		return "Unsupported movement type."
	var engaged := _engaged(state, squad)
	if move_type in ["normal", "advance"] and engaged: return "Engaged squads must Fall Back or remain stationary."
	if move_type in ["ordered_retreat", "desperate_escape"] and not engaged: return "Only engaged squads can Fall Back."
	if move_type == "ordered_retreat" and state.squads[squad].battle_shocked: return "Battle-shocked squads must use Desperate Escape to Fall Back."
	return ""

static func _movement_draft(state: Dictionary, squad: int, move_type: String, take_to_skies: bool = false) -> Dictionary:
	var origins: Dictionary = {}
	var origin_elevations: Dictionary = {}
	var prior_flags: Dictionary = {}
	for member: int in living(state, squad):
		origins[member] = state.units[member].position
		origin_elevations[member] = float(state.units[member].get("elevation", 0.0))
		prior_flags[member] = state.units[member].moved
	var take_to_skies_penalty := Terrain.take_to_skies_penalty(state, squad, take_to_skies)
	return {"squad": squad, "move_type": move_type, "origins": origins, "origin_elevations": origin_elevations, "prior_flags": prior_flags, "spent": {}, "bonus": 0, "hazard_remaining": 0, "hazard_rolls": [], "locked": move_type != "normal", "take_to_skies": take_to_skies, "take_to_skies_penalty": take_to_skies_penalty}

static func _movement_action_id(state: Dictionary, squad: int) -> String:
	return "movement:%d:%d:%s" % [int(state.get("turn", 0)), squad, str(state.get("phase", ""))]

static func _pending_movement_action_id(state: Dictionary) -> String:
	var pending_value: Variant = state.get("pending_move", {})
	if typeof(pending_value) != TYPE_DICTIONARY: return ""
	var pending: Dictionary = pending_value
	if pending.is_empty(): return ""
	var squad: Variant = pending.get("squad", -1)
	return _movement_action_id(state, int(squad)) if squad is int else ""

static func _begin_movement_frame(state: Dictionary, squad: int, resume_point: String) -> Dictionary:
	return ResolutionFrames.begin(state, "unit-action", _movement_action_id(state, squad), resume_point)

static func _suspend_movement_frame(state: Dictionary, squad: int, resume_point: String) -> String:
	var frame := ResolutionFrames.current(state)
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != _movement_action_id(state, squad): return "The movement resolution frame is missing."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _complete_movement_frame(state: Dictionary, squad: int) -> String:
	var frame := ResolutionFrames.current(state)
	# Older snapshots can contain a pending move without having persisted action frames.
	# Complete a compatibility frame so those drafts remain resolvable after upgrade.
	if frame.is_empty(): frame = _begin_movement_frame(state, squad, "legacy-movement-completion")
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != _movement_action_id(state, squad): return "The active movement resolution frame is missing."
	return ResolutionFrames.complete(state, str(frame.frame_id))

static func _charge_action_id(state: Dictionary, squad: int) -> String:
	return "charge:%d:%d:%s" % [int(state.get("turn", 0)), squad, str(state.get("phase", ""))]

static func _pending_charge_action_id(state: Dictionary) -> String:
	var pending_value: Variant = state.get("pending_charge", {})
	if typeof(pending_value) != TYPE_DICTIONARY: return ""
	var pending: Dictionary = pending_value
	if pending.is_empty(): return ""
	var squad: Variant = pending.get("squad", -1)
	return _charge_action_id(state, int(squad)) if squad is int else ""

static func _begin_charge_frame(state: Dictionary, squad: int, resume_point: String) -> Dictionary:
	return ResolutionFrames.begin(state, "unit-action", _charge_action_id(state, squad), resume_point)

static func _suspend_charge_frame(state: Dictionary, squad: int, resume_point: String) -> String:
	var frame := ResolutionFrames.current(state)
	if frame.is_empty(): frame = _begin_charge_frame(state, squad, resume_point)
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != _charge_action_id(state, squad): return "The charge resolution frame is missing."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _complete_charge_frame(state: Dictionary, squad: int) -> String:
	var frame := ResolutionFrames.current(state)
	if frame.is_empty(): frame = _begin_charge_frame(state, squad, "legacy-charge-completion")
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != _charge_action_id(state, squad): return "The active charge resolution frame is missing."
	return ResolutionFrames.complete(state, str(frame.frame_id))

static func _contact_action_id(state: Dictionary, squad: int, kind: String) -> String:
	return "contact:%d:%s:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", "")), squad, kind]

static func _pending_contact_action_id(state: Dictionary) -> String:
	var pending_value: Variant = state.get("pending_contact", {})
	if typeof(pending_value) != TYPE_DICTIONARY: return ""
	var pending: Dictionary = pending_value
	if pending.is_empty(): return ""
	return _contact_resolution_action_id(state, pending)

static func _contact_resolution_action_id(state: Dictionary, move: Dictionary) -> String:
	var action_id := str(move.get("resolution_action_id", ""))
	if not action_id.is_empty(): return action_id
	var squad := int(move.get("squad", -1))
	return _charge_action_id(state, squad) if str(move.get("kind", "")) == "charge" else _contact_action_id(state, squad, str(move.get("kind", "")))

static func _resume_contact_frame(state: Dictionary, move: Dictionary) -> String:
	var action_id := _contact_resolution_action_id(state, move)
	if action_id.is_empty(): return "The contact movement continuation has no action identity."
	var frame := ResolutionFrames.begin(state, "unit-action", action_id, "contact-placement")
	if frame.is_empty(): return "Could not resume the contact movement resolution frame."
	if str(move.get("resolution_action_id", "")).is_empty():
		move.resolution_action_id = action_id
	return ""

static func _suspend_contact_frame(state: Dictionary, move: Dictionary, resume_point: String = "contact-placement") -> String:
	var action_id := _contact_resolution_action_id(state, move)
	var frame := ResolutionFrames.current(state)
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != action_id: return "The active contact movement resolution frame is missing."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _complete_contact_frame(state: Dictionary, move: Dictionary) -> String:
	var action_id := _contact_resolution_action_id(state, move)
	var frame := ResolutionFrames.current(state)
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != action_id: return "The active contact movement resolution frame is missing."
	return ResolutionFrames.complete(state, str(frame.frame_id))

static func _settle_charge_frame_after_reaction(state: Dictionary) -> String:
	var frame := ResolutionFrames.current(state)
	if frame.is_empty() or str(frame.get("kind", "")) != "unit-action" or not str(frame.get("action_id", "")).begins_with("charge:") or str(frame.get("resume_point", "")) not in ["charge-post-move-reaction", "charge-failed-reaction"]: return ""
	if not UnitActions.pending(state).is_empty() or not state.get("pending_charge", {}).is_empty() or not state.get("pending_contact", {}).is_empty() or not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): return ""
	return ResolutionFrames.complete(state, str(frame.frame_id))

static func _new_attack_resolution_action_id(state: Dictionary, squad: int) -> String:
	return "attack:%d:%d:%s:%d" % [int(state.get("turn", 0)), squad, str(state.get("phase", "")), int(state.get("revision", -1))]

static func _attack_declaration_action_id(state: Dictionary, declaration: Dictionary) -> String:
	var action_id := str(declaration.get("resolution_action_id", ""))
	if action_id.is_empty():
		action_id = _new_attack_resolution_action_id(state, int(declaration.get("squad", -1)))
		declaration.resolution_action_id = action_id
	return action_id

static func _suspend_attack_declaration(state: Dictionary, declaration: Dictionary, resume_point: String) -> String:
	var action_id := _attack_declaration_action_id(state, declaration)
	var frame := ResolutionFrames.begin(state, "attack", action_id, resume_point)
	if frame.is_empty(): return "Could not open the attack declaration frame."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _attack_resolution_action_id(state: Dictionary) -> String:
	var pending_attack: Dictionary = state.get("pending_attack", {})
	if not pending_attack.is_empty():
		var action_id := str(pending_attack.get("resolution_action_id", ""))
		if action_id.is_empty():
			action_id = "legacy-attack:%d:%d:%s:%d" % [int(state.get("turn", 0)), int(pending_attack.get("squad", -1)), str(state.get("phase", "")), int(state.get("revision", -1))]
			pending_attack.resolution_action_id = action_id
		return action_id
	var pending_hazard: Dictionary = state.get("pending_hazard", {})
	if not pending_hazard.is_empty():
		var action_id := str(pending_hazard.get("resolution_action_id", ""))
		if action_id.is_empty():
			action_id = "legacy-attack:%d:%d:%s:%d" % [int(state.get("turn", 0)), int(pending_hazard.get("squad", -1)), str(state.get("phase", "")), int(state.get("revision", -1))]
			pending_hazard.resolution_action_id = action_id
		return action_id
	return ""

static func _resume_attack_resolution_frame(state: Dictionary, resume_point: String) -> String:
	var action_id := _attack_resolution_action_id(state)
	if action_id.is_empty(): return "There is no pending attack action to resume."
	var frame := ResolutionFrames.begin(state, "attack", action_id, resume_point)
	if frame.is_empty(): return "Could not resume the attack resolution frame."
	return ""

static func _suspend_attack_resolution_frame(state: Dictionary, action_id: String, resume_point: String) -> String:
	if action_id.is_empty(): return "The attack action has no resolution identity."
	var frame := ResolutionFrames.begin(state, "attack", action_id, resume_point)
	if frame.is_empty(): return "Could not suspend the attack resolution frame."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _complete_attack_resolution_frame(state: Dictionary, action_id: String) -> String:
	var frame := ResolutionFrames.current(state)
	if frame.is_empty(): return ""
	if str(frame.get("kind", "")) != "attack" or str(frame.get("action_id", "")) != action_id:
		return "The active attack resolution frame is missing."
	if _post_attack_reaction_pending(state):
		return ResolutionFrames.suspend(state, str(frame.frame_id), "attack-post-resolution-choice")
	var error := ResolutionFrames.complete(state, str(frame.frame_id))
	if not error.is_empty(): return error
	_settle_counteroffensive_frame(state)
	_settle_vengeful_frame(state)
	return ""

static func _complete_undying_attack_frame(state: Dictionary) -> String:
	var pending := Reanimation.pending(state)
	if not pending.is_empty() or str(pending.get("kind", "")) == "undying": return ""
	var frame := ResolutionFrames.current(state)
	if str(frame.get("kind", "")) != "attack" or str(frame.get("status", "")) != "suspended" or str(frame.get("resume_point", "")) != "attack-post-resolution-choice":
		return "The Undying Legions continuation is missing its suspended attack frame."
	var action_id := str(frame.get("action_id", ""))
	if ResolutionFrames.begin(state, "attack", action_id, "resume-undying-legions").is_empty(): return "Could not resume the Undying Legions attack continuation."
	return _complete_attack_resolution_frame(state, action_id)

static func _post_attack_reaction_pending(state: Dictionary) -> bool:
	var reanimation := Reanimation.pending(state)
	if str(reanimation.get("kind", "")) == "undying": return true
	return DetachmentStratagems.undying_actor(state) > 0 or DetachmentStratagems.sacrifice_actor(state) > 0 or DetachmentStratagems.darkflight_vengeance_actor(state) > 0 or DetachmentStratagems.darkflight_skyborne_actor(state) > 0 or _post_attack_reaction_window(UnitActions.pending(state), 0)

static func _post_attack_reaction_window(window: Dictionary, depth: int) -> bool:
	if window.is_empty() or depth >= 8: return false
	var kind := str(window.get("kind", ""))
	if kind == "tactics" and str(window.get("source", "")) == DetachmentStratagems.WE_ARE_VENGEANCE: return true
	if kind in [TacticalFluidity.WINDOW, TacticalFluidity.PLACEMENT,
		PurgationRun.WINDOW, PurgationRun.PLACEMENT,
		PhobosShadowMasters.WINDOW, PhobosExecuteRedeploy.WINDOW,
		VictrixHonourGuard.WINDOW, VictrixHonourGuard.PLACEMENT, "forward-assault-mark"]: return true
	var resume_window: Variant = window.get("resume_window", {})
	return _post_attack_reaction_window(resume_window, depth + 1) if typeof(resume_window) == TYPE_DICTIONARY else false

static func begin_movement(state: Dictionary, player: int, model: int, move_type: String, revision: int, roller: Callable = Callable(), use_sudden_onslaught: bool = false, unstoppable_resolved: bool = false, take_to_skies: bool = false) -> String:
	var error := movement_choice_error(state, player, model, move_type, revision)
	if not error.is_empty(): return error
	var squad: int = state.units[model].squad
	if take_to_skies and move_type not in ["normal", "advance", "ordered_retreat", "desperate_escape"]: return "Take to the Skies is available only for a Normal Move, Advance or Fall Back."
	if take_to_skies and not Terrain.squad_can_fly(state, squad): return "Take to the Skies requires a FLYING unit."
	var mobile_choice_available := not unstoppable_resolved and move_type != "stationary" and not use_sudden_onslaught and (DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.UNSTOPPABLE_ADVANCE) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.KNIGHTS_OF_IRON) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.FLAWLESS_RIDERS) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.MOBILE_LETHALITY, move_type))
	if mobile_choice_available:
		if _begin_movement_frame(state, squad, "movement-stratagem-decision").is_empty(): return "Could not open the movement resolution frame."
		state.unit_abilities.window = {"kind": DetachmentStratagems.UNSTOPPABLE_WINDOW, "owners": [player], "squad": squad, "trigger": "movement", "action": "movement", "model": model, "move_type": move_type, "use_sudden_onslaught": false, "take_to_skies": take_to_skies, "take_to_skies_penalty": 2.0 if take_to_skies and not Terrain.squad_has_hover(state, squad) else 0.0}
		var suspend_error := _suspend_movement_frame(state, squad, "movement-stratagem-decision")
		if not suspend_error.is_empty(): return suspend_error
		_event(state, "%s is selected to move. Choose an available movement stratagem or decline it before moving." % state.squads[squad].name)
		return ""
	if use_sudden_onslaught:
		if move_type != "advance": return "Sudden Onslaught can only replace an Advance roll."
		error = DetachmentStratagems.error(state, player, squad, DetachmentStratagems.SUDDEN_ONSLAUGHT)
		if not error.is_empty(): return error
	if move_type == "stationary":
		state.squads[squad].moved = true
		state.squads[squad].move_type = move_type
		_event(state, "%s remained stationary." % state.squads[squad].name)
		return ""
	var draft := _movement_draft(state, squad, move_type, take_to_skies)
	if move_type == "advance" and state.get("unit_abilities", {}).get("veil_of_time_pending", {}).has(squad):
		if use_sudden_onslaught: return "Sudden Onslaught cannot be used after Veil of Time fixed this Advance to 6."
		draft.veil_of_time_to_six = true
		state.unit_abilities.veil_of_time_pending.erase(squad)
	elif move_type != "advance" and state.get("unit_abilities", {}).get("veil_of_time_pending", {}).has(squad):
		state.unit_abilities.veil_of_time_pending.erase(squad)
	if move_type in ["advance", "desperate_escape"] and not use_sudden_onslaught:
		if not roller.is_valid(): return "This move requires host dice."
		var dice := Attacks.Dice.new(roller)
		if move_type == "advance": draft.bonus = dice.d6()
		else:
			for member: int in living(state, squad):
				draft.hazard_rolls.append(dice.d6())
		if not dice.error.is_empty(): return dice.error
		if move_type == "desperate_escape":
			var initial_hazard := Hazard.from_rolls(state, squad, draft.hazard_rolls)
			if not str(initial_hazard.get("error", "")).is_empty(): return str(initial_hazard.error)
			draft.hazard_remaining = int(initial_hazard.total)
	if _begin_movement_frame(state, squad, "movement-roll").is_empty(): return "Could not open the movement resolution frame."
	if move_type == "advance" and use_sudden_onslaught:
		error = DetachmentStratagems.spend_sudden_onslaught(state, player, squad)
		if not error.is_empty(): return error
		draft.bonus = 6
		draft.raw_bonus = 6
		draft.sudden_onslaught = true
		var sudden_modifier := UnitAbilities.advance_modifier(state, squad) + Doctrines.advance_bonus(state, squad)
		draft.bonus += sudden_modifier
		state.last_command_roll = {"kind": "after_advance_roll", "squad": squad, "original_rolls": [], "rolls": [6], "rerolled": false, "source": DetachmentStratagems.SUDDEN_ONSLAUGHT}
	elif move_type == "advance":
		var opened := Stratagems.open_roll(state, player, squad, "after_advance_roll", [draft.bonus], draft, Doctrines.wrath_of_the_chapter(state, squad))
		if DetachmentStratagems.sudden_led_advance(state, squad):
			if opened: state.stratagems.pending.sudden = true
			elif DetachmentStratagems.open_advance(state, player, squad, [draft.bonus], draft): opened = true
		if opened:
			var suspend_error := _suspend_movement_frame(state, squad, "advance-roll-decision")
			if not suspend_error.is_empty(): return suspend_error
			_event(state, "%s: Advance D6 = %d. Accept%s before moving." % [state.squads[squad].name, draft.bonus, ", re-roll with Sudden Storm" if state.stratagems.pending.get("sudden", false) else " or use Command Re-roll"])
			return ""
		draft.raw_bonus = draft.bonus
		var advance_modifier := UnitAbilities.advance_modifier(state, squad) + Doctrines.advance_bonus(state, squad)
		draft.bonus = (6 if draft.get("veil_of_time_to_six", false) else draft.raw_bonus) + advance_modifier
	state.pending_move = draft
	var frame := _begin_movement_frame(state, squad, "movement-placement")
	if frame.is_empty(): return "Could not resume the movement resolution frame."
	if UnitAbilities.enabled(state): UnitActions.Techmarine.open_for_move(state, squad, "start")
	UnitActions.TargetAuguryWeb.open_for_move(state, squad, "start")
	if move_type == "desperate_escape" and state.get("stratagems", {}).get("escape_rerolls", false):
		# Recalculate from the final pool after an optional Command Re-roll.
		var rerolled_hazard := Hazard.from_rolls(state, squad, draft.hazard_rolls)
		if not str(rerolled_hazard.get("error", "")).is_empty(): return str(rerolled_hazard.error)
		state.pending_move.hazard_remaining = int(rerolled_hazard.total)
		if Stratagems.eligibility_error(state, player, squad, "command-re-roll").is_empty():
			var indices: Array[int] = []
			for index in range(draft.hazard_rolls.size()): indices.append(index)
			state.stratagems.pending = {"kind": "after_escape_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": draft.hazard_rolls.duplicate(), "eligible": indices}
			var suspend_error := _suspend_movement_frame(state, squad, "escape-roll-decision")
			if not suspend_error.is_empty(): return suspend_error
			_event(state, "%s: Desperate Escape hazards %s. Accept or replace one D6 before allocation and movement." % [state.squads[squad].name, str(draft.hazard_rolls)])
			return ""
	if move_type == "desperate_escape" and int(state.pending_move.get("hazard_remaining", 0)) > 0:
		var suspend_error := _suspend_movement_frame(state, squad, "escape-wound-allocation")
		if not suspend_error.is_empty(): return suspend_error
	var message := "%s selected %s." % [state.squads[squad].name, move_type.replace("_", " ")]
	if move_type == "advance": message += " Advance %s: %d inches." % ["roll: 6 (Sudden Onslaught, 1 CP)" if use_sudden_onslaught else "roll", draft.bonus]
	if move_type == "desperate_escape": message += " Hazard rolls: %s; allocate %d mortal wounds before moving." % [str(draft.hazard_rolls), state.pending_move.hazard_remaining]
	if take_to_skies: message += " Take to the Skies declared%s; FLY models can move through all models and terrain." % (" with no movement reduction (HOVER)" if float(draft.take_to_skies_penalty) == 0.0 else "; maximum move reduced by 2 inches")
	_event(state, message)
	return ""

static func resolve_escape_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable = Callable()) -> String:
	var window := Stratagems.pending(state)
	if window.get("kind", "") != "after_escape_roll": return "No Desperate Escape roll is waiting for a decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in ["", "command-re-roll"]: return "Stratagem unavailable for this roll."
	var rolls: Array = window.rolls.duplicate()
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
		if die not in window.eligible: return "Choose an eligible escape hazard die."
		if not roller.is_valid(): return "Command Re-roll requires the host's dice."
		var dice := Attacks.Dice.new(roller)
		rolls[die] = dice.d6()
		if not dice.error.is_empty(): return dice.error
	var working := state.duplicate(true)
	var hazard := Hazard.from_rolls(working, squad, rolls)
	if not hazard.error.is_empty(): return hazard.error
	if not stratagem.is_empty(): Stratagems.consume(working, player, squad, stratagem)
	working.stratagems.pending = {}
	working.pending_move.hazard_rolls = rolls
	working.pending_move.hazard_remaining = hazard.total
	var frame := _begin_movement_frame(working, squad, "movement-placement")
	if frame.is_empty(): return "Could not resume the movement resolution frame."
	if hazard.total > 0:
		var suspend_error := _suspend_movement_frame(working, squad, "escape-wound-allocation")
		if not suspend_error.is_empty(): return suspend_error
	working.last_command_roll = {"kind": window.kind, "squad": squad, "original_rolls": window.rolls.duplicate(), "rolls": rolls.duplicate(), "rerolled": not stratagem.is_empty(), "die": die, "mortal_wounds": hazard.total}
	_event(working, "%s: final Desperate Escape hazards %s; %d mortal wounds before movement.%s" % [working.squads[squad].name, str(rolls), hazard.total, " Command Re-roll: 1 CP." if not stratagem.is_empty() else " Result accepted."])
	state.clear()
	state.merge(working, true)
	return ""

static func abandon_fall_back(state: Dictionary, player: int, revision: int) -> String:
	var continuation_action_id := _pending_movement_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return error
	if state.phase != "movement" or state.pending_move.get("move_type", "") not in ["ordered_retreat", "desperate_escape"]:
		return "No Fall Back placement to abandon."
	if state.pending_move.hazard_remaining > 0: return "Resolve all escape mortal wounds first."
	var squad: int = state.pending_move.squad
	var origin_elevations: Dictionary = state.pending_move.get("origin_elevations", {})
	for id: int in state.pending_move.origins:
		state.units[id].position = state.pending_move.origins[id]
		if origin_elevations.has(id): state.units[id].elevation = float(origin_elevations[id])
		state.units[id].moved = state.pending_move.prior_flags[id]
	# A move that fails its final conditions is not made (§03.01). The unit
	# has still been selected this phase; it cannot choose another move.
	state.squads[squad].moved = true
	state.squads[squad].move_type = "failed_fall_back"
	state.pending_move = {}
	var frame_error := _complete_movement_frame(state, squad)
	if not frame_error.is_empty(): return frame_error
	_event(state, "Fall Back not completed; original positions restored and escape casualties retained. This squad cannot move again this phase.")
	return ""

static func allocate_escape_wound(state: Dictionary, player: int, model: int, revision: int, roller: Callable = Callable()) -> String:
	var continuation_action_id := _pending_movement_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id, "escape-wounds")
	if not error.is_empty(): return error
	if state.phase != "movement" or state.pending_move.is_empty() or state.pending_move.get("hazard_remaining", 0) <= 0:
		return "No pending escape mortal wounds."
	var squad: int = state.pending_move.squad
	if model not in DefenderGroups.current_models(state, {"target": squad}, true):
		return "Choose a model eligible under Mortal Wounds allocation priority."
	var prevention := Attacks.Prevention.resolve(1, state.units[model].wounds, UnitPrevention.rules(state, model), "mortal", roller)
	if not prevention.error.is_empty(): return prevention.error
	state.units[model].wounds -= prevention.lost
	state.last_escape_prevention = prevention
	state.pending_move.hazard_remaining -= 1
	if living(state, squad).is_empty():
		state.pending_move = {}
		var frame_error := _complete_movement_frame(state, squad)
		if not frame_error.is_empty(): return frame_error
		if not Objectives.training(state) and not Mission.enabled(state) and living_owner(state, player).is_empty(): state.test_winner = 3 - player
	elif int(state.pending_move.get("hazard_remaining", 0)) <= 0:
		if _begin_movement_frame(state, squad, "movement-placement").is_empty(): return "Could not resume the movement placement frame."
	else:
		var suspend_error := _suspend_movement_frame(state, squad, "escape-wound-allocation")
		if not suspend_error.is_empty(): return suspend_error
	_event(state, "Escape mortal wound allocated to model %d." % model)
	return ""

static func can_start_action(state: Dictionary, squad: int) -> bool:
	return Actions.eligibility_error(state, squad).is_empty()

static func start_action(state: Dictionary, player: int, model: int, objective: int, revision: int) -> String:
	if not UnitAbilities.Detection.selection(state).is_empty(): return "Finish the selected Eliminator shooting or cancel its selection first."
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player: return "Select a living model in your unit."
	var squad: int = state.units[model].squad
	error = Actions.start_error(state, squad, objective)
	if not error.is_empty(): return error
	Actions.start(state, squad, objective)
	_event(state, "%s started Secure Ground on %s; completes at end of turn if still controlling it from within range." % [state.squads[squad].name, state.mission.objectives[objective].name])
	return ""

static func _movement_validation_result(code: String, reason: String = "", recovery: String = "", details: Array = [], primary_model: int = -1) -> Dictionary:
	return {"valid": reason.is_empty(), "code": "valid" if reason.is_empty() else code, "reason": reason, "recovery": recovery, "details": details.duplicate(true), "primary_model": primary_model}

static func validate_move_result(state: Dictionary, player: int, id: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> Dictionary:
	var continuation_action_id := _pending_movement_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return _movement_validation_result("command_blocked", error, "Resolve the current decision before moving.")
	if state.phase != "movement": return _movement_validation_result("wrong_phase", "Moves are allowed only in the Movement phase.", "Wait until the Movement phase.")
	if not state.units.has(id) or state.units[id].wounds <= 0: return _movement_validation_result("model_unavailable", "Select a living miniature.", "Select a living model on the battlefield.")
	var unit: Dictionary = state.units[id]
	if not unit.get("on_battlefield", true): return _movement_validation_result("model_in_reserves", "Reserved models must arrive with an ingress move.", "Use the unit's ingress action to enter the battlefield.")
	if unit.owner != player: return _movement_validation_result("wrong_owner", "You cannot move an opponent's miniature.", "Select a model you control.")
	if state.squads[unit.squad].moved: return _movement_validation_result("squad_already_moved", "This squad has already resolved its move.", "Choose a squad that has not moved yet.")
	if not state.pending_move.is_empty() and state.pending_move.squad != unit.squad: return _movement_validation_result("other_squad_moving", "Finish the active squad's movement first.", "Confirm or cancel the active squad's movement.")
	if not destination.is_finite(): return _movement_validation_result("invalid_destination", "Invalid destination.", "Choose a point on the battlefield.")
	if state.pending_move.get("hazard_remaining", 0) > 0: return _movement_validation_result("pending_escape_wounds", "Allocate escape mortal wounds before moving.", "Finish the pending mortal-wound allocation.")
	if state.pending_move.is_empty() and _engaged(state, unit.squad): return _movement_validation_result("engaged_normal_move", "An engaged squad cannot make a normal move.", "Choose Fall Back or remain stationary.")
	var target_elevation := float(unit.get("elevation", 0.0)) if destination_elevation < 0.0 else destination_elevation
	if not is_finite(target_elevation) or target_elevation < 0.0: return _movement_validation_result("unsupported_elevation", "Choose a supported battlefield elevation.", "Select one of the listed battlefield heights.")
	var current_elevation := float(unit.get("elevation", 0.0))
	var distance := Terrain.movement_distance(unit.position, current_elevation, destination, target_elevation, Terrain.ignores_vertical_movement(state, id))
	if unit.position.is_equal_approx(destination) and absf(target_elevation - current_elevation) <= 0.001: return _movement_validation_result("unchanged_destination", "Choose a different destination.", "Choose a new position or height.")
	var remaining := movement_remaining(state, id)
	if distance > remaining + 0.001: return _movement_validation_result("exceeds_movement", "Exceeds movement: %.2f inches requested, %.2f remaining." % [distance, remaining], "Choose a destination within the remaining movement allowance.")
	var move_type := str(state.pending_move.get("move_type", "normal"))
	var through_enemies: bool = move_type == "desperate_escape"
	if not Contact.clear_path(state, id, destination, remaining, through_enemies, false, target_elevation, move_type):
		var terrain_error := Terrain.path_error(state, id, destination, target_elevation)
		if not terrain_error.is_empty(): return _movement_validation_result("terrain_blocked", terrain_error, "Choose a route around the terrain feature.")
		return _movement_validation_result("path_blocked", "The base cannot cross terrain, a blocking model base, or the board edge.", "Choose a clear route that stays on the battlefield.")
	for other: int in state.units:
		if other == id or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		if absf(target_elevation - float(state.units[other].get("elevation", 0.0))) > 0.001: continue
		if destination.distance_to(state.units[other].position) < float(unit.radius) + float(state.units[other].radius) - 0.001:
			return _movement_validation_result("destination_overlap", "Bases cannot overlap at the destination.", "Choose a free destination that leaves space between bases.")
	# Engagement is checked after the entire unit move, not along its path.
	return _movement_validation_result("valid")

static func validate_move(state: Dictionary, player: int, id: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> String:
	return str(validate_move_result(state, player, id, destination, revision, destination_elevation).get("reason", "Movement validation failed."))

static func move_result(state: Dictionary, player: int, id: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> Dictionary:
	var validation := validate_move_result(state, player, id, destination, revision, destination_elevation)
	if not bool(validation.get("valid", false)): return validation
	var squad: int = state.units[id].squad
	if state.pending_move.is_empty():
		if _begin_movement_frame(state, squad, "movement-placement").is_empty(): return _movement_validation_result("movement_frame_unavailable", "Could not open the movement resolution frame.", "Cancel the placement and reopen the move.")
		state.pending_move = _movement_draft(state, squad, "normal")
	var current_elevation := float(state.units[id].get("elevation", 0.0))
	var target_elevation := current_elevation if destination_elevation < 0.0 else destination_elevation
	var distance := Terrain.movement_distance(state.units[id].position, current_elevation, destination, target_elevation, Terrain.ignores_vertical_movement(state, id))
	state.pending_move.spent[id] = float(state.pending_move.spent.get(id, 0.0)) + distance
	state.units[id].position = destination
	state.units[id].elevation = target_elevation
	state.units[id].moved = true
	var elevation_note := " to elevation %.2f inches" % target_elevation if absf(target_elevation - current_elevation) > 0.001 else ""
	_event(state, "Model %d: staged %.2f inches of movement%s; %.2f remaining. Confirm squad when ready." % [id, distance, elevation_note, movement_remaining(state, id)])
	return _movement_validation_result("valid")

static func move(state: Dictionary, player: int, id: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> String:
	return str(move_result(state, player, id, destination, revision, destination_elevation).get("reason", "Movement could not be completed."))

static func finish_movement(state: Dictionary, player: int, revision: int, cancel: bool = false, roller: Callable = Callable()) -> String:
	return str(finish_movement_result(state, player, revision, cancel, roller).get("reason", "Movement confirmation failed."))

static func finish_movement_result(state: Dictionary, player: int, revision: int, cancel: bool = false, roller: Callable = Callable()) -> Dictionary:
	var continuation_action_id := _pending_movement_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return _movement_validation_result("command_blocked", error, "Resolve the current decision before confirming movement.")
	if state.phase != "movement" or state.pending_move.is_empty(): return _movement_validation_result("movement_unavailable", "No pending squad movement.", "Begin or resume a move before confirming placement.")
	var squad: int = state.pending_move.squad
	if cancel:
		var origin_elevations: Dictionary = state.pending_move.get("origin_elevations", {})
		for id: int in state.pending_move.origins:
			state.units[id].position = state.pending_move.origins[id]
			if origin_elevations.has(id): state.units[id].elevation = float(origin_elevations[id])
			state.units[id].moved = state.pending_move.prior_flags[id]
		if state.pending_move.get("locked", false):
			state.pending_move.spent = {}
			_event(state, "Placement reset; selected move, dice and casualties are retained.")
		else:
			state.pending_move = {}
			var frame_error := _complete_movement_frame(state, squad)
			if not frame_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", frame_error, "Reopen the movement decision before continuing.")
			_event(state, "Pending squad movement cancelled; original positions restored.")
		return _movement_validation_result("valid")
	if UnitActions.TargetAuguryWeb.start_decision_pending(state, squad): return _movement_validation_result("pending_unit_ability", "Resolve Target Augury Web before confirming this unit's move.", "Resolve the Vehicle ability choice, then confirm movement.")
	if state.pending_move.get("hazard_remaining", 0) > 0: return _movement_validation_result("pending_escape_wounds", "Allocate escape mortal wounds before confirming.", "Finish allocating the pending escape wounds, then confirm movement.")
	if not Contact.coherent(state, squad): return _movement_validation_result("squad_not_coherent", "Squad is not in coherency. Reposition its models or cancel movement.", "Reposition the squad until it meets coherency, then confirm or reset placement.")
	if _engaged(state, squad): return _movement_validation_result("engaged_after_move", "The move must end unengaged. Reposition its models or reset placement.", "Reposition the squad to finish unengaged, or reset placement.")
	var move_type: String = state.pending_move.get("move_type", "normal")
	if move_type == "desperate_escape" and not state.squads[squad].battle_shocked:
		var result: Dictionary = state.pending_move.get("morale_result", {}).duplicate(true)
		if result.is_empty():
			var tempered_applies := MarineEnhancements.tempered_in_battle_active(state, squad)
			if tempered_applies and (not state.has("stratagems") or str(state.stratagems.get("implementation", "")).is_empty() or not Stratagems.pending(state).is_empty()):
				return _movement_validation_result("pending_unit_ability", "Tempered in Battle's Leadership decision is unavailable in this match profile.", "Use a match profile that supports this decision before resolving Desperate Escape.")
			result = Morale.roll_battle_shock(state, squad, roller)
			if not result.error.is_empty(): return _movement_validation_result("movement_resolution_failed", str(result.error), "Review the Battle-shock result and reopen the move if needed.")
			if tempered_applies:
				var staged := state.duplicate(true)
				if ResolutionFrames.current(staged).is_empty() and _begin_movement_frame(staged, squad, "desperate-escape-leadership-decision").is_empty():
					return _movement_validation_result("movement_continuation_unavailable", "Could not open the Desperate Escape Leadership continuation frame.", "Reopen the movement decision before continuing.")
				staged.stratagems.pending = {"kind": "after_escape_battle_shock_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(staged), "current_result": result.duplicate(true)}
				var suspend_error := _suspend_movement_frame(staged, squad, "desperate-escape-leadership-decision")
				if not suspend_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", suspend_error, "Reopen the movement decision before continuing.")
				_event(staged, "%s rolled Leadership %s vs %d after Desperate Escape. Choose Tempered in Battle or keep the result." % [staged.squads[squad].name, str(result.rolls), int(result.target)])
				state.clear()
				state.merge(staged, true)
				return _movement_validation_result("valid")
		else:
			var resume_frame := _begin_movement_frame(state, squad, "resume-desperate-escape-leadership-result")
			if resume_frame.is_empty(): return _movement_validation_result("movement_continuation_unavailable", "Could not resume the Desperate Escape Leadership continuation frame.", "Reopen the movement decision before continuing.")
			state.pending_move.erase("morale_result")
		state.squads[squad].battle_shocked = not result.passed
		state.last_morale = [result]
		state.events.append({"revision": state.revision + 1, "message": "Escape battle-shock: %s vs %d — %s." % [str(result.rolls), result.target, "passed" if result.passed else "battle-shocked"]})
	var longest := 0.0
	for id: int in state.pending_move.spent: longest = maxf(longest, state.pending_move.spent[id])
	state.squads[squad].moved = true
	state.squads[squad].moved_distance = longest
	Actions.interrupt(state, squad, "unit made a move")
	state.squads[squad].move_type = move_type
	state.squads[squad].advanced = move_type == "advance"
	state.squads[squad].fell_back = move_type in ["ordered_retreat", "desperate_escape"]
	if move_type == "normal":
		state.squads[squad].normal_moved_this_turn = true
		TacticalFluidity.mark_normal_move_used_this_phase(state, squad)
	state.pending_move = {}
	UnitActions.end_move(state, squad)
	UnitActions.open_mortis_snares_after_move(state, squad, move_type)
	var frame_error := ""
	if UnitActions.movement_reaction_squad(state) == squad:
		var current_frame := ResolutionFrames.current(state)
		if current_frame.is_empty():
			current_frame = _begin_movement_frame(state, squad, "legacy-post-move-reaction")
		if current_frame.is_empty() or str(current_frame.get("kind", "")) != "unit-action" or str(current_frame.get("action_id", "")) != _movement_action_id(state, squad):
			return _movement_validation_result("movement_continuation_unavailable", "The completed Movement reaction has no matching continuation frame.", "Reopen the movement decision before continuing.")
		frame_error = _suspend_movement_frame(state, squad, "movement-post-move-reaction")
	else:
		frame_error = _complete_movement_frame(state, squad)
	if not frame_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", frame_error, "Reopen the movement decision before continuing.")
	_event(state, "%s movement confirmed; longest model path %.2f inches." % [state.squads[squad].name, longest])
	return _movement_validation_result("valid")

static func charge_declaration_error(state: Dictionary, player: int, model: int, revision: int, continuation_action_id: String = "") -> String:
	if continuation_action_id.is_empty(): continuation_action_id = _core_reaction_phase_close_action_id(state, player)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return error
	if state.phase != "charge": return "Declare charges only in the Charge phase."
	if not state.pending_charge.is_empty(): return "Resolve the pending charge first."
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player:
		return "Select a living model in your squad."
	var squad: int = state.units[model].squad
	error = Doctrines.charge_error(state, squad)
	if not error.is_empty(): return error
	if Actions.charge_blocked(state, squad): return "Starting an action prevents charges until the turn ends."
	if state.squads[squad].charge_declared: return "This squad already declared a charge this phase."
	if _engaged(state, squad): return "Engaged squads cannot declare a charge."
	var nearest := INF
	for enemy: int in ContactActions.enemies(state, squad):
		for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	error = CoreReactions.charge_error(state, player, squad)
	if not error.is_empty(): return error
	if nearest > 12.0: return "No enemy unit within 12 inches."
	return ""

static func declare_charge(state: Dictionary, player: int, model: int, revision: int, roller: Callable, unstoppable_resolved: bool = false, take_to_skies: bool = false, take_to_skies_penalty: float = -1.0) -> Dictionary:
	var continuation_action_id := _charge_action_id(state, int(state.units[model].squad)) if unstoppable_resolved and state.units.has(model) else ""
	var error := charge_declaration_error(state, player, model, revision, continuation_action_id)
	if not error.is_empty(): return {"error": error}
	var squad: int = state.units[model].squad
	if take_to_skies and not Terrain.squad_can_fly(state, squad): return {"error": "Take to the Skies requires a FLYING unit."}
	if take_to_skies_penalty < 0.0: take_to_skies_penalty = Terrain.take_to_skies_penalty(state, squad, take_to_skies)
	var mobile_choice_available := not unstoppable_resolved and (DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.UNSTOPPABLE_ADVANCE) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.KNIGHTS_OF_IRON) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.FLAWLESS_RIDERS))
	if mobile_choice_available:
		if _begin_charge_frame(state, squad, "charge-stratagem-decision").is_empty(): return {"error": "Could not open the charge resolution frame."}
		state.unit_abilities.window = {"kind": DetachmentStratagems.UNSTOPPABLE_WINDOW, "owners": [player], "squad": squad, "trigger": "charge", "action": "charge", "model": model, "take_to_skies": take_to_skies, "take_to_skies_penalty": take_to_skies_penalty}
		var suspend_error := _suspend_charge_frame(state, squad, "charge-stratagem-decision")
		if not suspend_error.is_empty(): return {"error": suspend_error}
		_event(state, "%s declares a charge. Choose an available charge stratagem or decline it before rolling." % state.squads[squad].name)
		return {"error": "", "message": "Choose an available charge stratagem or decline before rolling the charge."}
	if not roller.is_valid(): return {"error": "Missing host dice provider."}
	var dice := Attacks.Dice.new(roller)
	var rolls := [dice.d6(), dice.d6()]
	if not dice.error.is_empty(): return {"error": dice.error}
	if _begin_charge_frame(state, squad, "charge-roll").is_empty(): return {"error": "Could not open the charge resolution frame."}
	var maximum: int = rolls[0] + rolls[1]
	state.squads[squad].charge_declared = true
	if player == state.active: CoreReactions.record_charger(state, squad)
	var charge_draft := {"take_to_skies": take_to_skies, "take_to_skies_penalty": take_to_skies_penalty}
	var opened := Stratagems.open_roll(state, player, squad, "after_charge_roll", rolls, charge_draft)
	if state.has("stratagems") and UnitAbilities.has(state, squad, "unstoppable-valour"):
		if not opened: state.stratagems.pending = {"kind": "after_charge_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": rolls.duplicate(), "draft": charge_draft.duplicate(true)}
		state.stratagems.pending.valour = true
		opened = true
	if state.has("stratagems") and UnitAbilities.master_shadows_active(state, squad):
		if not opened: state.stratagems.pending = {"kind": "after_charge_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": rolls.duplicate(), "draft": charge_draft.duplicate(true)}
		state.stratagems.pending.master_shadows = true
		opened = true
	if opened:
		var suspend_error := _suspend_charge_frame(state, squad, "charge-roll-decision")
		if not suspend_error.is_empty(): return {"error": suspend_error}
		var reroll_source := " with Unstoppable Valour, 0 CP" if state.stratagems.pending.get("valour", false) else (" with Master of Shadows, 0 CP" if state.stratagems.pending.get("master_shadows", false) else (" with Lord of the Ravenwing, 0 CP" if state.stratagems.pending.get("lord_of_the_ravenwing", false) else (" with Linebreaker Onslaught, 0 CP" if state.stratagems.pending.get("linebreaker_onslaught", false) else " with Command Re-roll")))
		var notice := "%s: Charge %s = %d." % [state.squads[squad].name, str(rolls), maximum]
		if take_to_skies: notice += " Take to the Skies declared%s." % (" with no movement reduction (HOVER)" if take_to_skies_penalty == 0.0 else "; maximum distance reduced by 2 inches")
		notice += " Accept or re-roll both dice%s." % reroll_source
		_event(state, notice)
		return {"error": "", "message": notice}
	return _accept_charge_roll(state, squad, rolls, take_to_skies, take_to_skies_penalty)

static func _accept_charge_roll(state: Dictionary, squad: int, rolls: Array, take_to_skies: bool = false, take_to_skies_penalty: float = -1.0) -> Dictionary:
	if take_to_skies_penalty < 0.0: take_to_skies_penalty = Terrain.take_to_skies_penalty(state, squad, take_to_skies)
	var raw_total: int = rolls[0] + rolls[1]
	var modifier := UnitAbilities.charge_modifier(state, squad) + Doctrines.charge_bonus(state, squad)
	var maximum: int = CoreReactions.cap_charge(state, squad, raw_total + modifier)
	maximum = maxi(0, maximum - int(take_to_skies_penalty))
	var nearest := INF
	for enemy: int in ContactActions.enemies(state, squad):
		for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	var message := "%s charge roll: %s = %d%s inches. Choose a target now." % [state.squads[squad].name, str(rolls), raw_total, " + %d" % modifier if modifier > 0 else ""]
	if take_to_skies: message += " Take to the Skies: maximum distance %d inches%s." % [maximum, " (HOVER; no reduction)" if take_to_skies_penalty == 0.0 else " after the 2-inch reduction"]
	if maximum < nearest:
		message = "%s charge failed: %s = %d, no target within the rolled distance.%s" % [state.squads[squad].name, str(rolls), maximum, " Take to the Skies reduced the maximum by 2 inches." if take_to_skies and take_to_skies_penalty > 0.0 else (" HOVER prevented the Take to the Skies reduction." if take_to_skies else "")]
		var failed_heroic := CoreReactions.heroic_charger(state, state.squads[squad].owner, squad)
		if failed_heroic:
			CoreReactions.clear_heroic(state)
			CoreReactions.reopen_heroic_choices(state)
		if not UnitActions.pending(state).is_empty():
			var suspend_error := _suspend_charge_frame(state, squad, "charge-failed-reaction")
			if not suspend_error.is_empty(): return {"error": suspend_error}
		else:
			var frame_error := _complete_charge_frame(state, squad)
			if not frame_error.is_empty(): return {"error": frame_error}
	else:
		state.pending_charge = {"squad": squad, "maximum": maximum, "rolls": rolls, "targets": [], "take_to_skies": take_to_skies, "take_to_skies_penalty": take_to_skies_penalty}
		if _begin_charge_frame(state, squad, "charge-target-selection").is_empty(): return {"error": "Could not resume the charge resolution frame."}
	_event(state, message)
	return {"error": "", "message": message}

static func resolve_roll_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	var window := Stratagems.pending(state)
	if window.get("kind") not in ["after_advance_roll", "after_charge_roll"]: return "No Advance or Charge roll is waiting for a decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in ["", "command-re-roll", "sudden-storm", "unstoppable-valour", "master-shadows", "lord-of-the-ravenwing", "linebreaker-onslaught", "supercharged-engines", "honour-of-vigilance", "wrath-of-the-chapter", "stormseers-wisdom"]: return "Stratagem unavailable for this roll."
	if stratagem == "unstoppable-valour" and (window.kind != "after_charge_roll" or not window.get("valour", false) or not UnitAbilities.has(state, squad, "unstoppable-valour")): return "Unstoppable Valour is not available for this charge."
	if stratagem == "master-shadows" and (window.kind != "after_charge_roll" or not window.get("master_shadows", false)): return "Master of Shadows is not available for this charge."
	if stratagem == "lord-of-the-ravenwing" and (window.kind != "after_charge_roll" or not window.get("lord_of_the_ravenwing", false) or not MarineEnhancements.lord_of_the_ravenwing_active(state, squad)): return "Lord of the Ravenwing is not available for this charge."
	if stratagem == "linebreaker-onslaught" and (window.kind != "after_charge_roll" or not window.get("linebreaker_onslaught", false) or not MarineEnhancements.linebreaker_onslaught_active(state, squad)): return "Linebreaker Onslaught is not available for this charge."
	if stratagem == "sudden-storm" and (window.kind != "after_advance_roll" or not window.get("sudden", false)): return "Sudden Storm Advance re-roll is not available."
	if stratagem == "supercharged-engines" and (window.kind != "after_advance_roll" or not window.get("supercharged", false)): return "Supercharged Engines Advance re-roll is not available."
	if stratagem == "honour-of-vigilance" and (window.kind != "after_advance_roll" or not window.get("honour_vigilance", false)): return "Honour of Vigilance Advance re-roll is not available."
	if stratagem == "wrath-of-the-chapter" and (window.kind != "after_advance_roll" or not window.get("wrath_chapter", false)): return "Wrath of the Chapter Advance re-roll is not available."
	if stratagem == "stormseers-wisdom" and (window.kind != "after_advance_roll" or not window.get("stormseers_wisdom", false)): return "Stormseer's Wisdom Advance re-roll is not available."
	var rolls: Array = window.rolls.duplicate()
	if not stratagem.is_empty():
		if stratagem == "command-re-roll":
			error = Stratagems.use_error(state, player, squad, stratagem, revision)
			if not error.is_empty(): return error
		if not roller.is_valid(): return "This re-roll requires the host's dice."
		var dice := Attacks.Dice.new(roller)
		rolls = [dice.d6()] if window.kind == "after_advance_roll" else [dice.d6(), dice.d6()]
		if not dice.error.is_empty(): return dice.error
	var working := state.duplicate(true)
	if stratagem == "command-re-roll": Stratagems.consume(working, player, squad, stratagem)
	working.stratagems.pending = {}
	working.last_command_roll = {"kind": window.kind, "squad": squad, "original_rolls": window.rolls.duplicate(), "rolls": rolls.duplicate(), "rerolled": not stratagem.is_empty(), "source": stratagem}
	if window.kind == "after_advance_roll":
		working.pending_move = window.draft.duplicate(true)
		var frame := _begin_movement_frame(working, squad, "movement-placement")
		if frame.is_empty(): return "Could not resume the movement resolution frame."
		working.pending_move.raw_bonus = rolls[0]
		var advance_modifier := UnitAbilities.advance_modifier(working, squad) + Doctrines.advance_bonus(working, squad)
		working.pending_move.bonus = (6 if working.pending_move.get("veil_of_time_to_six", false) else rolls[0]) + advance_modifier
		if UnitAbilities.enabled(working): UnitActions.Techmarine.open_for_move(working, squad, "start")
		var source_label := "Supercharged Engines re-roll, 0 CP" if stratagem == "supercharged-engines" else ("Stormseer's Wisdom re-roll, 0 CP" if stratagem == "stormseers-wisdom" else ("Honour of Vigilance re-roll, 0 CP" if stratagem == "honour-of-vigilance" else ("Wrath of the Chapter re-roll, 0 CP" if stratagem == "wrath-of-the-chapter" else ("Sudden Storm re-roll" if stratagem == "sudden-storm" else ("Command Re-roll, 1 CP" if stratagem == "command-re-roll" else "result accepted")))))
		_event(working, "%s: final Advance %s = %d%s inches%s. Movement can begin." % [working.squads[squad].name, str(rolls), working.pending_move.bonus, " (+%d modifier)" % advance_modifier if advance_modifier > 0 else "", " • " + source_label])
	else:
		if _begin_charge_frame(working, squad, "charge-roll").is_empty(): return "Could not resume the charge resolution frame."
		var charge_draft: Dictionary = window.get("draft", {})
		var take_to_skies := bool(charge_draft.get("take_to_skies", false))
		var take_to_skies_penalty := float(charge_draft.get("take_to_skies_penalty", -1.0))
		if take_to_skies_penalty < 0.0: take_to_skies_penalty = Terrain.take_to_skies_penalty(working, squad, take_to_skies)
		var result := _accept_charge_roll(working, squad, rolls, take_to_skies, take_to_skies_penalty)
		if not result.error.is_empty(): return result.error
		if not stratagem.is_empty(): working.events[-1].message += " %s: %s → %s." % ["Unstoppable Valour, 0 CP" if stratagem == "unstoppable-valour" else ("Master of Shadows, 0 CP" if stratagem == "master-shadows" else ("Lord of the Ravenwing, 0 CP" if stratagem == "lord-of-the-ravenwing" else ("Linebreaker Onslaught, 0 CP" if stratagem == "linebreaker-onslaught" else "Command Re-roll, 1 CP"))), str(window.rolls), str(rolls)]
	state.clear()
	state.merge(working, true)
	return ""

static func decline_charge(state: Dictionary, player: int, revision: int) -> String:
	var continuation_action_id := _pending_charge_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return error
	if state.phase != "charge" or state.pending_charge.is_empty(): return "No pending charge."
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == TransportRules.COMBAT_EMBARKATION_WINDOW: return "Resolve Repulsor Combat Embarkation before declining this charge."
	if not state.pending_contact.is_empty():
		ContactActions.restore(state)
		state.pending_contact = {}
	var heroic_squad: int = int(state.pending_charge.get("squad", -1))
	state.pending_charge = {}
	var declined_heroic := CoreReactions.heroic_charger(state, player, heroic_squad)
	if declined_heroic:
		CoreReactions.clear_heroic(state)
		CoreReactions.reopen_heroic_choices(state)
	if not UnitActions.pending(state).is_empty():
		var suspend_error := _suspend_charge_frame(state, heroic_squad, "charge-failed-reaction")
		if not suspend_error.is_empty(): return suspend_error
	else:
		var frame_error := _complete_charge_frame(state, heroic_squad)
		if not frame_error.is_empty(): return frame_error
	_event(state, "Charge resolved without moving; it cannot be rolled again this phase.")
	return ""

static func charge_target_error(state: Dictionary, player: int, target: int, revision: int) -> String:
	var continuation_action_id := _pending_charge_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return error
	if state.phase != "charge" or state.pending_charge.is_empty(): return "Roll the charge before choosing its target."
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == TransportRules.COMBAT_EMBARKATION_WINDOW: return "Resolve Repulsor Combat Embarkation before changing charge targets."
	if not state.pending_contact.is_empty(): return "Cancel charge placement before changing targets."
	if not UnitActions.pending(state).is_empty(): return "Resolve the pending reaction before changing charge targets."
	if not state.units.has(target) or state.units[target].wounds <= 0 or not state.units[target].get("on_battlefield", true) or state.units[target].owner == player:
		return "Choose a living enemy target after the charge roll."
	var squad: int = state.pending_charge.squad
	var enemy: int = state.units[target].squad
	var nearest := INF
	for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	if nearest > minf(12.0, state.pending_charge.maximum): return "Target must be within 12 inches and the full rolled distance."
	error = CoreReactions.leap_target_error(state, squad, enemy)
	return error

static func select_charge_target(state: Dictionary, player: int, target: int, revision: int) -> Dictionary:
	var error := charge_target_error(state, player, target, revision)
	if not error.is_empty(): return {"error": error}
	var working: Dictionary = state.duplicate(true)
	var enemy: int = working.units[target].squad
	var charging_squad := int(working.pending_charge.squad)
	if _begin_charge_frame(working, charging_squad, "charge-target-selection").is_empty(): return {"error": "Could not resume the charge resolution frame."}
	if not working.pending_charge.has("targets"): working.pending_charge.targets = []
	var was_selected := enemy in working.pending_charge.targets
	if was_selected: working.pending_charge.targets.erase(enemy)
	else: working.pending_charge.targets.append(enemy)
	var names: Array[String] = []
	for target_squad: int in working.pending_charge.targets: names.append(working.squads[target_squad].name)
	var message := "Charge targets: %s. Begin placement when ready." % (", ".join(names) if not names.is_empty() else "none")
	if not was_selected:
		var charge_frame := ResolutionFrames.current(working)
		if charge_frame.is_empty() or str(charge_frame.get("kind", "")) != "unit-action" or str(charge_frame.get("status", "")) != "resolving" or str(charge_frame.get("action_id", "")) != _charge_action_id(working, charging_squad): return {"error": "Dread Crusaders could not locate its pending Charge continuation."}
		if DetachmentStratagems.open_dread_crusaders_reaction(working, charging_squad, enemy, str(charge_frame.frame_id)):
			var suspend_error := ResolutionFrames.suspend(working, str(charge_frame.frame_id), "charge-target-selection")
			if not suspend_error.is_empty(): return {"error": suspend_error}
			message += " The defending player has a Dread Crusaders reaction."
	_event(working, message)
	state.clear()
	state.merge(working, true)
	return {"error": "", "message": message}

static func begin_contact_move(state: Dictionary, player: int, model: int, kind: String, revision: int, chosen_targets: Array[int] = [], objective_index: int = -1, roller: Callable = Callable(), use_tactical_focus: bool = false) -> String:
	if use_tactical_focus and kind != "consolidate": return "Tactical Focus can only be used with a consolidation move."
	var continuation_action_id := _pending_charge_action_id(state) if kind == "charge" else ""
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return error
	if not state.pending_contact.is_empty(): return "Finish the pending contact move first."
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player: return "Select a living model in your squad."
	var squad: int = state.units[model].squad
	if kind == "consolidate" and not use_tactical_focus and not DetachmentStratagems.tactical_focus_roll(state, player, squad).is_empty(): return "Tactical Focus has already been spent for this consolidation; resume its saved roll."
	var targets: Array[int] = []
	var maximum := 3.0
	var uses_singular_will := false
	var uses_tactical_focus := false
	if kind == "charge":
		if state.phase != "charge" or state.pending_charge.is_empty() or state.pending_charge.squad != squad: return "Roll this squad's charge first."
		if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == TransportRules.COMBAT_EMBARKATION_WINDOW: return "Resolve Repulsor Combat Embarkation before beginning charge placement."
		if _begin_charge_frame(state, squad, "charge-placement").is_empty(): return "Could not resume the charge resolution frame."
		for target: int in state.pending_charge.get("targets", []): targets.append(target)
		maximum = float(state.pending_charge.maximum)
		if TransportRules.begin_combat_embarkation_reaction(state, squad):
			var suspend_error := _suspend_charge_frame(state, squad, "charge-target-reaction")
			if not suspend_error.is_empty(): return suspend_error
			_event(state, "Repulsor Combat Embarkation: the defending player can embark one eligible charge target before the charge move.")
			return ""
	else:
		if state.phase != "fight": return "Pile-in and consolidation moves happen in Fight."
		match kind:
			"pile_in":
				if state.fight_step != "pile_in" or squad not in FightQueue.choices(state, player): return "This squad has no pile-in window."
			"overrun":
				if state.fight_step not in ["attacks", "consolidation_reaction"] or squad not in FightQueue.choices(state, player) or state.squads[squad].overrun_used: return "This squad has no additional overrun pile-in."
				if _engaged(state, squad) and state.squads[squad].was_engaged: return "This squad is eligible for a normal fight, not an overrun."
			"consolidate":
				if state.fight_step != "consolidate" or squad not in FightQueue.choices(state, player): return "This squad has no consolidation window."
				uses_singular_will = MarineEnhancements.singular_will_active(state, squad)
				uses_tactical_focus = use_tactical_focus
				kind = "consolidate_ongoing" if _engaged(state, squad) else "consolidate_engaging"
			_: return "Unsupported contact movement type."
		var engagement_targets := ContactActions.enemies(state, squad, 2.0)
		if not engagement_targets.is_empty(): targets = engagement_targets
		else:
			var possible := ContactActions.enemies(state, squad, 3.0 if kind == "consolidate_engaging" else 5.0)
			if chosen_targets.is_empty() and not possible.is_empty(): targets.append(possible[0])
			else:
				for target: int in chosen_targets:
					if target not in possible or target in targets: return "Invalid or duplicate contact target."
					targets.append(target)
	if targets.is_empty() and kind == "consolidate_engaging":
		var candidates := Objectives.consolidation_candidates(state, squad)
		if not candidates.is_empty():
			if objective_index == -1: objective_index = candidates[0]
			if objective_index not in candidates: return "Select an objective within 3 inches of the squad."
			kind = "consolidate_objective"
	if kind != "consolidate_objective" and objective_index != -1: return "Enemy consolidation takes priority over objective consolidation."
	if targets.is_empty() and kind != "consolidate_objective": return "No eligible enemy or objective consolidation target."
	var tactical_focus_key := ""
	var tactical_focus_roll: Dictionary = {}
	var tactical_focus_roll_reused := false
	if uses_tactical_focus:
		tactical_focus_key = DetachmentStratagems.tactical_focus_roll_key(state, player, squad)
		tactical_focus_roll = DetachmentStratagems.tactical_focus_roll(state, player, squad)
		tactical_focus_roll_reused = not tactical_focus_roll.is_empty()
		if tactical_focus_roll.is_empty():
			var focus_error := DetachmentStratagems.error(state, player, squad, DetachmentStratagems.TACTICAL_FOCUS)
			if not focus_error.is_empty(): return focus_error
			var focus_result := RandomStat.roll("D3+3", roller)
			if not str(focus_result.get("error", "")).is_empty(): return str(focus_result.error)
			tactical_focus_roll = focus_result.duplicate(true)
			tactical_focus_roll["squad"] = squad
			tactical_focus_roll["player"] = player
			tactical_focus_roll["round"] = int(state.get("round", 0))
			tactical_focus_roll["turn"] = int(state.get("turn", 0))
			tactical_focus_roll["phase_key"] = DetachmentStratagems.phase_key(state)
		maximum = maxf(maximum, float(tactical_focus_roll.get("value", 3)))
	var singular_will_key := ""
	var singular_will_roll: Dictionary = {}
	if uses_singular_will:
		singular_will_key = "%d:%d:%d:%d" % [int(state.get("round", 0)), int(state.get("turn", 0)), player, squad]
		var cached_rolls_value: Variant = state.get("singular_will_rolls", {})
		if not cached_rolls_value is Dictionary: return "Saved Singular Will roll history is invalid; synchronize before consolidating."
		var singular_will_rolls: Dictionary = cached_rolls_value
		var cached_roll_value: Variant = singular_will_rolls.get(singular_will_key, {})
		if not cached_roll_value is Dictionary: return "Saved Singular Will roll is invalid; synchronize before consolidating."
		singular_will_roll = cached_roll_value.duplicate(true)
		if singular_will_roll.is_empty():
			var roll_result := RandomStat.roll("D3+3", roller)
			if not str(roll_result.get("error", "")).is_empty(): return str(roll_result.error)
			singular_will_roll = roll_result.duplicate(true)
			singular_will_roll["squad"] = squad
			singular_will_roll["player"] = player
			singular_will_roll["round"] = int(state.get("round", 0))
			singular_will_roll["turn"] = int(state.get("turn", 0))
		else:
			var rolls: Array = singular_will_roll.get("rolls", [])
			if str(singular_will_roll.get("expression", "")) != "D3+3" or int(singular_will_roll.get("squad", -1)) != squad or int(singular_will_roll.get("player", -1)) != player or int(singular_will_roll.get("round", -1)) != int(state.get("round", 0)) or int(singular_will_roll.get("turn", -1)) != int(state.get("turn", 0)) or rolls.size() != 1 or not rolls[0] is int or int(rolls[0]) < 1 or int(rolls[0]) > 6 or int(singular_will_roll.get("value", -1)) != ceili(float(int(rolls[0])) / 2.0) + 3:
				return "The saved Singular Will roll is invalid; synchronize before consolidating."
		maximum = float(singular_will_roll.get("value", 3))
		if not singular_will_rolls.has(singular_will_key):
			singular_will_rolls[singular_will_key] = singular_will_roll.duplicate(true)
			state.singular_will_rolls = singular_will_rolls.duplicate(true)
	var move := ContactActions.draft(state, squad, kind, targets, maximum)
	if kind == "charge":
		move.take_to_skies = bool(state.pending_charge.get("take_to_skies", false))
		move.take_to_skies_penalty = float(state.pending_charge.get("take_to_skies_penalty", 0.0))
	if uses_singular_will:
		move.singular_will_roll_key = singular_will_key
		move.singular_will_roll = singular_will_roll.duplicate(true)
	if uses_tactical_focus:
		move.tactical_focus_roll_key = tactical_focus_key
		move.tactical_focus_roll = tactical_focus_roll.duplicate(true)
		move.tactical_focus_roll_reused = tactical_focus_roll_reused
	if kind == "charge":
		move.resolution_action_id = _charge_action_id(state, squad)
		var suspend_error := _suspend_charge_frame(state, squad, "charge-placement")
		if not suspend_error.is_empty(): return suspend_error
	else:
		var action_id := _contact_action_id(state, squad, kind)
		var frame := ResolutionFrames.begin(state, "unit-action", action_id, "contact-placement")
		if frame.is_empty(): return "Could not open the contact movement resolution frame."
		var contact_suspend_error := ResolutionFrames.suspend(state, str(frame.frame_id), "contact-placement")
		if not contact_suspend_error.is_empty():
			ResolutionFrames.complete(state, str(frame.frame_id))
			return contact_suspend_error
		if uses_tactical_focus and not tactical_focus_roll_reused:
			var focus_rolls_value: Variant = state.get("tactical_focus_rolls", {})
			if not focus_rolls_value is Dictionary:
				ResolutionFrames.complete(state, str(frame.frame_id))
				return "Saved Tactical Focus roll history is invalid; synchronize before consolidating."
			var focus_use := DetachmentStratagems.apply(state, player, {"stratagem": DetachmentStratagems.TACTICAL_FOCUS, "target": squad, "model": -1, "value": DetachmentStratagems.TACTICAL_FOCUS})
			if not str(focus_use.get("error", "")).is_empty():
				ResolutionFrames.complete(state, str(frame.frame_id))
				return str(focus_use.error)
			var focus_rolls: Dictionary = focus_rolls_value
			focus_rolls[tactical_focus_key] = tactical_focus_roll.duplicate(true)
			state.tactical_focus_rolls = focus_rolls.duplicate(true)
		move.resolution_action_id = action_id
	if kind == "consolidate_objective": move.objective = objective_index
	state.pending_contact = move
	if uses_singular_will:
		state.last_command_roll = {"kind": "singular-will", "source": "Singular Will", "squad": squad, "expression": "D3+3", "original_rolls": singular_will_roll.rolls.duplicate(), "rolls": singular_will_roll.rolls.duplicate(), "value": int(maximum), "rerolled": false}
		_event(state, "%s: Singular Will D3 roll %d + 3 = %d inches per model for consolidation." % [state.squads[squad].name, int(singular_will_roll.rolls[0]), int(maximum)])
	elif uses_tactical_focus:
		state.last_command_roll = {"kind": "tactical-focus", "source": "Tactical Focus", "squad": squad, "expression": "D3+3", "original_rolls": tactical_focus_roll.rolls.duplicate(), "rolls": tactical_focus_roll.rolls.duplicate(), "value": int(maximum), "rerolled": false}
		_event(state, "%s: Tactical Focus D3 roll %d + 3 = %d inches per model for consolidation." % [state.squads[squad].name, int(tactical_focus_roll.rolls[0]), int(maximum)])
	else:
		_event(state, "%s: begin %s; %.0f inches per model." % [state.squads[squad].name, kind.replace("_", " "), maximum])
	return ""

static func stage_contact_move_result(state: Dictionary, player: int, model: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> Dictionary:
	var pending_value: Variant = state.get("pending_contact", {})
	var move: Dictionary = pending_value if typeof(pending_value) == TYPE_DICTIONARY else {}
	var continuation_action_id := _pending_contact_action_id(state)
	if continuation_action_id.is_empty(): continuation_action_id = _pending_charge_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return _movement_validation_result("command_blocked", error, "Resolve the current decision before placing a model.")
	var validation := ContactActions.validate_segment_result(state, model, destination, destination_elevation)
	if not bool(validation.get("valid", false)): return validation
	var resume_error := _resume_contact_frame(state, move)
	if not resume_error.is_empty(): return _movement_validation_result("contact_frame_unavailable", resume_error, "Cancel and reopen the contact move.")
	var origin_elevation := float(state.units[model].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	var segment_distance := Terrain.movement_distance(state.units[model].position, origin_elevation, destination, target_elevation, Terrain.ignores_vertical_movement(state, model))
	state.pending_contact.spent[model] = float(state.pending_contact.spent.get(model, 0.0)) + segment_distance
	state.units[model].position = destination
	state.units[model].elevation = target_elevation
	var suspend_error := _suspend_contact_frame(state, state.pending_contact)
	if not suspend_error.is_empty(): return _movement_validation_result("contact_frame_unavailable", suspend_error, "Cancel and reopen the contact move.")
	_event(state, "Model %d contact placement: %.2f inches remaining." % [model, ContactActions.remaining(state, model)])
	return _movement_validation_result("valid")

static func stage_contact_move(state: Dictionary, player: int, model: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> String:
	return str(stage_contact_move_result(state, player, model, destination, revision, destination_elevation).get("reason", "Contact movement could not be completed."))

static func finish_contact_move(state: Dictionary, player: int, revision: int, cancel: bool = false) -> String:
	return str(finish_contact_move_result(state, player, revision, cancel).get("reason", "Contact movement could not be completed."))

static func finish_contact_move_result(state: Dictionary, player: int, revision: int, cancel: bool = false) -> Dictionary:
	var continuation_action_id := _pending_contact_action_id(state)
	if continuation_action_id.is_empty(): continuation_action_id = _pending_charge_action_id(state)
	var error := _command_error(state, player, revision, continuation_action_id)
	if not error.is_empty(): return _movement_validation_result("command_blocked", error, "Resolve the current decision before confirming contact movement.")
	if state.pending_contact.is_empty(): return _movement_validation_result("movement_unavailable", "No pending contact movement.", "Begin or resume a contact move before confirming placement.")
	if cancel:
		var resume_error := _resume_contact_frame(state, state.pending_contact)
		if not resume_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", resume_error, "Reopen the contact move before continuing.")
		ContactActions.restore(state)
		var cancelled_move: Dictionary = state.pending_contact
		state.pending_contact = {}
		if str(cancelled_move.get("kind", "")) == "charge":
			var suspend_error := _suspend_charge_frame(state, int(cancelled_move.get("squad", -1)), "charge-target-selection")
			if not suspend_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", suspend_error, "Reopen the Charge decision before continuing.")
		else:
			var complete_error := _complete_contact_frame(state, cancelled_move)
			if not complete_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", complete_error, "Reopen the contact move before continuing.")
		var tactical_focus_retained := not cancelled_move.get("tactical_focus_roll", {}).is_empty()
		var cancellation_message := "Contact placement cancelled; positions restored."
		if tactical_focus_retained: cancellation_message += " Tactical Focus remains paid and its roll is retained."
		elif str(cancelled_move.get("kind", "")) == "charge": cancellation_message += " Charge dice are retained."
		_event(state, cancellation_message)
		return _movement_validation_result("valid")
	var validation := ContactActions.final_validation(state)
	error = validation.error
	if not error.is_empty(): return _movement_validation_result(str(validation.get("code", "contact_blocked")), error, str(validation.get("recovery", "Reposition the models or cancel the contact move.")), validation.get("details", []), int(validation.get("primary_model", -1)))
	var resume_error := _resume_contact_frame(state, state.pending_contact)
	if not resume_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", resume_error, "Reopen the contact move before continuing.")
	state.last_contact_proofs = validation.proofs
	for proof: Dictionary in validation.proofs:
		var reason := "terrain detour exceeds movement" if proof.reason == "terrain_route" else "no coherent arrangement within movement and retained engagements"
		state.events.append({"revision": state.revision + 1, "message": "Model %d: %.0f-inch approach exception proved — %s." % [proof.model, proof.gap, reason]})
	var move: Dictionary = state.pending_contact
	var squad: int = move.squad
	state.pending_contact = {}
	UnitActions.end_move(state, squad)
	for id: int in move.spent: state.units[id].moved = true
	if move.kind == "charge":
		Actions.interrupt(state, squad, "unit made a charge move")
		for id: int in move.spent:
			state.squads[squad].moved_distance = maxf(state.squads[squad].moved_distance, float(move.spent[id]))
		state.squads[squad].charged = true
		state.pending_charge = {}
		var was_heroic_intervention := CoreReactions.heroic_charger(state, player, squad)
		if was_heroic_intervention: CoreReactions.clear_heroic(state)
		if not Hammer.charge_completed(state, player, squad): CoreReactions.charge_completed(state, player, squad)
		if was_heroic_intervention and state.get("unit_abilities", {}).get("window", {}).is_empty(): CoreReactions.reopen_heroic_choices(state)
		UnitActions.open_mortis_snares_after_move(state, squad, move.kind)
		if not UnitActions.pending(state).is_empty():
			var suspend_error := _suspend_charge_frame(state, squad, "charge-post-move-reaction")
			if not suspend_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", suspend_error, "Reopen the Charge decision before continuing.")
		else:
			var frame_error := _complete_charge_frame(state, squad)
			if not frame_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", frame_error, "Reopen the Charge decision before continuing.")
		_event(state, "%s charge confirmed; Fights First until this turn ends." % state.squads[squad].name)
	elif move.kind == "overrun":
		state.squads[squad].overrun_used = true
		state.fight_selected = squad
		for enemy: int in ContactActions.enemies(state, squad, 2.0): state.squads[enemy].fight_eligible = true
		_event(state, "Overrun pile-in confirmed. Resolve this squad's attacks.")
	elif move.kind.begins_with("consolidate"):
		var reactions: Array[int] = []
		for enemy: int in ContactActions.enemies(state, squad, 2.0):
			if not state.squads[enemy].fought: reactions.append(enemy)
		if not reactions.is_empty():
			state.consolidation_return = player
			state.reaction_queue = reactions
			state.fight_selected = -1
			if not state.has("consolidate_done"): state.consolidate_done = []
			state.consolidate_done.append(squad)
			state.fight_step = "consolidation_reaction"
			state.fight_actor = int(state.squads[reactions[0]].owner)
			for reaction: int in reactions: state.squads[reaction].fight_eligible = true
			_event(state, "Consolidation confirmed; newly contacted enemy must fight now.")
		else: _advance_fight(state, player, true, squad)
	else: _advance_fight(state, player, true, squad)
	if move.kind != "charge":
		UnitActions.open_mortis_snares_after_move(state, squad, move.kind)
		var contact_frame_error := _complete_contact_frame(state, move)
		if not contact_frame_error.is_empty(): return _movement_validation_result("movement_continuation_unavailable", contact_frame_error, "Reopen the contact move before continuing.")
	if move.has("singular_will_roll_key"):
		var cached_rolls: Dictionary = state.get("singular_will_rolls", {})
		cached_rolls.erase(str(move.singular_will_roll_key))
	if move.has("tactical_focus_roll_key"):
		var cached_focus_rolls: Dictionary = state.get("tactical_focus_rolls", {})
		cached_focus_rolls.erase(str(move.tactical_focus_roll_key))
	return _movement_validation_result("valid")

static func charge(state: Dictionary, player: int, target: int, revision: int) -> Dictionary:
	# Optional straight-line assist retained for existing fixtures. All proposals
	# pass the same final validator; normal UI/network commands use manual paths.
	var working: Dictionary = state.duplicate(true)
	var result := select_charge_target(working, player, target, revision)
	if not result.error.is_empty(): return result
	var squad: int = working.pending_charge.squad
	var plan := Contact.charge_plan(working, squad, working.units[target].squad, working.pending_charge.maximum)
	if not plan.error.is_empty(): return plan
	var error := begin_contact_move(working, player, living(working, squad)[0], "charge", working.revision)
	if not error.is_empty(): return {"error": error}
	for id: int in plan.positions:
		error = stage_contact_move(working, player, id, plan.positions[id], working.revision)
		if not error.is_empty(): return {"error": error}
	error = finish_contact_move(working, player, working.revision)
	if not error.is_empty(): return {"error": error}
	state.units = working.units
	state.squads = working.squads
	state.last_contact_proofs = working.get("last_contact_proofs", [])
	state.pending_charge = {}
	state.resolution_frames = working.get("resolution_frames", []).duplicate(true)
	if working.has("unit_abilities"): state.unit_abilities = working.unit_abilities.duplicate(true)
	var message := "Straight-line charge confirmed through contact validation."
	_event(state, message)
	return {"error": "", "message": message}

static func _pile_eligible(state: Dictionary, squad: int) -> bool:
	return not living(state, squad).is_empty() and (_engaged(state, squad) or state.squads[squad].charged)

static func _begin_fight(state: Dictionary) -> void:
	state.fight_actor = state.active
	state.fight_priority = "first"
	state.fight_step = "pile_in"
	state.pile_done = []
	state.consolidate_done = []
	state.reaction_queue = []
	state.fight_selected = -1
	for squad: int in state.squads:
		state.squads[squad].fought = false
		state.squads[squad].fight_eligible = false
		state.squads[squad].overrun_used = false
	if not FightQueue.choose_actor(state, state.active):
		state.fight_step = "complete"

static func _eligible_fighter(state: Dictionary, squad: int) -> bool:
	return FightQueue.eligible(state, squad)

static func _select_consolidation(state: Dictionary) -> void:
	state.fight_step = "consolidate"
	state.fight_selected = -1
	if not FightQueue.choose_actor(state, state.active):
		state.fight_step = "complete"
		state.fight_actor = state.active

static func _select_fighter(state: Dictionary, cursor: int) -> void:
	state.fight_step = "attacks"
	state.fight_selected = -1
	for squad: int in state.squads:
		if _eligible_fighter(state, squad): state.squads[squad].fight_eligible = true
	var pool := FightQueue.pool(state)
	state.fight_priority = "first" if not pool.is_empty() and FightQueue.first(state, pool[0]) else "remaining"
	if not FightQueue.choose_actor(state, cursor): _select_consolidation(state)

static func _start_fights(state: Dictionary) -> void:
	state.fight_step = "attacks"
	for squad: int in state.squads:
		state.squads[squad].was_engaged = _engaged(state, squad)
		state.squads[squad].fight_eligible = _eligible_fighter(state, squad)
	_select_fighter(state, state.active)

static func _advance_fight(state: Dictionary, player: int, moved: bool = false, selected_squad: int = -1) -> String:
	var choices := FightQueue.choices(state, player)
	# With multiple choices, explicit selection is required for an empty fight.
	var squad: int = selected_squad if selected_squad in choices else choices[0] if not choices.is_empty() else -1
	match state.fight_step:
		"pile_in":
			if squad != -1:
				if not state.has("pile_done"): state.pile_done = []
				state.pile_done.append(squad)
			if not FightQueue.choose_actor(state, state.active): _start_fights(state)
			_event(state, "Player %d, unit %d %s pile-in movement." % [player, squad, "confirmed" if moved else "declined optional"])
		"attacks", "consolidation_reaction":
			if squad == -1: return "No eligible unit in this action window."
			if choices.size() > 1 and selected_squad not in choices: return "Select an eligible unit before resolving an unengaged fight."
			if _engaged(state, squad): return "This unit must fight before the phase can advance."
			var waiting := state.duplicate(true)
			var action_id := "fight-empty:%d:%d:%d" % [int(waiting.get("turn", 0)), squad, player]
			var declaration := {"kind": "empty-fight", "squad": squad, "melee": true, "player": player, "resolution_action_id": action_id}
			if UnitActions.Bladeguard.offer(waiting, declaration, []):
				var frame := ResolutionFrames.begin(waiting, "fight", action_id, "empty-fight-bladeguard-choice")
				if frame.is_empty(): return "Could not open the unengaged Fight continuation frame."
				var suspend_error := ResolutionFrames.suspend(waiting, str(frame.frame_id), "empty-fight-bladeguard-choice")
				if not suspend_error.is_empty(): return suspend_error
				_event(waiting, "Choose Bladeguard stance before completing the unengaged fight.")
				state.clear()
				state.merge(waiting, true)
				return ""
			_finish_empty_fight(state, player, squad)
		"consolidate":
			if squad != -1:
				if not state.has("consolidate_done"): state.consolidate_done = []
				state.consolidate_done.append(squad)
			_select_consolidation(state)
			_event(state, "Player %d, unit %d %s consolidation movement." % [player, squad, "confirmed" if moved else "declined optional"])
	return ""

static func _finish_empty_fight(state: Dictionary, player: int, squad: int) -> void:
	if state.get("unit_abilities", {}).get("banner_active", {}).has(squad): state.unit_abilities.banner_active.erase(squad)
	state.squads[squad].fought = true
	DetachmentStratagems.remove_lingering(state, squad)
	if state.fight_step == "consolidation_reaction": _resume_consolidation(state)
	else: _select_fighter(state, 3 - player)
	var message := "Player %d, unit %d resolved an unengaged fight without moving or attacking." % [player, squad]
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == "counter": message += " Player %d may use an eligible Fight reaction or decline." % int(state.unit_abilities.window.owners[0])
	_event(state, message)

static func _resume_consolidation(state: Dictionary) -> void:
	state.fight_selected = -1
	var pending: Array[int] = []
	for squad: int in state.get("reaction_queue", []):
		if not state.squads[squad].fought and not living(state, squad).is_empty(): pending.append(squad)
	state.reaction_queue = pending
	if not pending.is_empty():
		state.fight_step = "consolidation_reaction"
		state.fight_actor = state.squads[pending[0]].owner
	else:
		state.consolidation_return = 0
		_select_consolidation(state)

static func attack_window_error(state: Dictionary, player: int, attacker: int, revision: int, melee: bool) -> String:
	var continuation_action_id := _core_reaction_phase_close_action_id(state, player)
	var resolved_decision_source := ""
	if not melee and state.get("phase", "") == "shooting" and DetachmentStratagems.shooting_reaction_actor(state) == player and state.units.has(attacker) and DetachmentStratagems.reactive_shooting_shooter(state, int(state.units[attacker].get("squad", -1))):
		continuation_action_id = _vengeful_action_id(state)
		resolved_decision_source = "unit-actions"
	var error := _command_error(state, player, revision, continuation_action_id, resolved_decision_source)
	if not error.is_empty(): return error
	if not state.pending_contact.is_empty() or not state.pending_move.is_empty(): return "Confirm or cancel placement before attacking."
	if not state.units.has(attacker) or state.units[attacker].wounds <= 0 or not state.units[attacker].get("on_battlefield", true) or state.units[attacker].owner != player: return "Select your living attacker."
	var squad: int = state.units[attacker].squad
	var optics := UnitAbilities.Detection.selection(state)
	if not optics.is_empty() and optics.squad != squad: return "Finish the selected Eliminator shooting or cancel its selection first."
	if state.get("unit_abilities", {}).get("window", {}).get("declaration", {}).get("kind", "") == "attack": return "Resolve the pending attack declaration choice before starting another attack."
	if melee:
		if state.phase != "fight" or state.fight_step not in ["attacks", "consolidation_reaction"]: return "Resolve pile-in decisions before fighting."
		if squad not in FightQueue.choices(state, player): return "Select an eligible unit in the current priority or reaction queue."
	else:
		if not CoreReactions.overwatch_shooter(state, squad) and state.phase != "shooting": return "Attacks are allowed only in the Shooting phase."
		if Actions.shooting_blocked(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "Starting an action prevents shooting until the turn ends."
		if state.squads[squad].shot and not DetachmentStratagems.reactive_shooting_shooter(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "This squad already shot this phase."
		if state.squads[squad].fell_back and not Doctrines.shoot_after_fallback(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "A squad that Fell Back needs an effect that allows it to shoot this turn."
	return ""

static func attack_plan_error(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool = true, hail_target: int = -1, indirect_shooting: bool = false) -> String:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return error
	var plan_state := state
	var squad: int = state.units[attacker].squad
	if not melee and DetachmentStratagems.point_blank_brutality_available(state, player, squad):
		plan_state = state.duplicate(true)
		plan_state._point_blank_legality_preview = true
	return AttackPlan.prepare(plan_state, squad, melee, entries, use_lethal, hail_target, indirect_shooting).error

static func resolve_attack_plan(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool, roller: Callable, hail_target: int = -1, indirect_shooting: bool = false) -> Dictionary:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return {"error": error}
	var squad: int = state.units[attacker].squad
	var declaration := {"kind": "attack", "player": player, "attacker": attacker, "squad": squad, "entries": entries.duplicate(true), "melee": melee, "use_lethal": use_lethal, "hail_target": hail_target, "indirect_shooting": indirect_shooting, "reaction_index": 0, "resolution_action_id": _new_attack_resolution_action_id(state, squad)}
	var plan_state := state
	var point_blank_available := not melee and DetachmentStratagems.point_blank_brutality_available(state, player, squad)
	if point_blank_available:
		plan_state = state.duplicate(true)
		plan_state._point_blank_legality_preview = true
	var prepared := AttackPlan.prepare(plan_state, squad, melee, entries, use_lethal, hail_target, indirect_shooting)
	if not prepared.error.is_empty(): return prepared
	var firing_deck_error := FiringDeck.declare_transport_shooting(state, attacker, entries)
	if not firing_deck_error.is_empty(): return {"error": firing_deck_error}
	if point_blank_available:
		var waiting := state.duplicate(true)
		waiting.unit_abilities.window = {"kind": DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW, "owners": [player], "squad": squad, "declaration": declaration.duplicate(true)}
		var can_use_point_blank := DetachmentStratagems.error(waiting, player, squad, DetachmentStratagems.FIRESTORM_POINT_BLANK_BRUTALITY).is_empty()
		if can_use_point_blank:
			var frame_error := _suspend_attack_declaration(waiting, declaration, "attack-point-blank-brutality-reaction")
			if not frame_error.is_empty(): return {"error": frame_error}
			waiting.unit_abilities.window = {"kind": DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW, "owners": [player], "squad": squad, "declaration": declaration.duplicate(true)}
			var message := "Selected Tacticus unit may use Point-Blank Brutality before its ranged attacks are resolved."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
	return _continue_attack_declaration(state, declaration, roller)

static func _continue_attack_declaration(state: Dictionary, declaration: Dictionary, roller: Callable) -> Dictionary:
	var prepared := AttackPlan.prepare(state, int(declaration.squad), bool(declaration.melee), declaration.entries, bool(declaration.use_lethal), int(declaration.hail_target), bool(declaration.get("indirect_shooting", false)))
	if not prepared.error.is_empty(): return prepared
	var waiting := state.duplicate(true)
	var index := int(declaration.get("reaction_index", 0))
	if index <= 0:
		declaration.reaction_index = 1
		if UnitActions.Incursors.offer(waiting, declaration):
			var frame_error := _suspend_attack_declaration(waiting, declaration, "attack-incursor-reaction")
			if not frame_error.is_empty(): return {"error": frame_error}
			var message := "Attack declared; eligible Incursor units may use Divinator-class Auspexes before the shot."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
		index = 1
	if index <= 1:
		declaration.reaction_index = 2
		if UnitActions.PhobosLibrarian.offer(waiting, declaration, prepared.targets):
			var frame_error := _suspend_attack_declaration(waiting, declaration, "attack-phobos-shrouding")
			if not frame_error.is_empty(): return {"error": frame_error}
			var message := "Attack declared; the targeted Phobos Librarian may use Shrouding before dice are rolled."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
		index = 2
	if index <= 2:
		declaration.reaction_index = 3
		if UnitActions.Bladeguard.offer(waiting, declaration, prepared.targets):
			var frame_error := _suspend_attack_declaration(waiting, declaration, "attack-bladeguard-stance")
			if not frame_error.is_empty(): return {"error": frame_error}
			var message := "Attack declared; choose Bladeguard stance before rolling any dice."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
		index = 3
	if index <= 3:
		var targets: Array = prepared.targets
		var cursor := int(declaration.get("armour_target_cursor", 0))
		while cursor < targets.size():
			var target := int(targets[cursor])
			declaration.armour_target_cursor = cursor + 1
			cursor += 1
			var defender := int(state.squads[target].owner)
			var previous_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.ARMOUR_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
			var can_armour := DetachmentStratagems.armour_error(state, defender, target, int(declaration.squad)).is_empty()
			var can_foresight := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.ULTRAMARINES_TACTICAL_FORESIGHT).is_empty()
			state.unit_abilities.window = previous_window
			if not can_armour and not can_foresight: continue
			declaration.reaction_index = 3
			var frame_error := _suspend_attack_declaration(state, declaration, "attack-armour-of-contempt")
			if not frame_error.is_empty(): return {"error": frame_error}
			state.unit_abilities.window = {"kind": DetachmentStratagems.ARMOUR_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
			var message := "Attack declared; the targeted Adeptus Astartes unit may use an available defensive stratagem before attack dice are rolled."
			_event(state, message)
			return {"error": "", "message": message, "pools": []}
		if UnitAbilities.enabled(state) and DetachmentStratagems.enabled(state):
			var fortitude_cursor := int(declaration.get("fortitude_target_cursor", 0))
			while fortitude_cursor < targets.size():
				var target := int(targets[fortitude_cursor])
				declaration.fortitude_target_cursor = fortitude_cursor + 1
				fortitude_cursor += 1
				var defender := int(state.squads[target].owner)
				var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
				state.unit_abilities.window = {"kind": DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
				var can_fortitude := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE).is_empty()
				state.unit_abilities.window = prior_window
				if not can_fortitude: continue
				declaration.reaction_index = 3
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-terminator-fortitude-reaction")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
				var message := "Attack declared; %s may use Tactical Dreadnought Fortitude before attack dice are rolled." % state.squads[target].name
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		if state.phase == "shooting" and UnitAbilities.enabled(state) and DetachmentStratagems.enabled(state):
			var shadow_cursor := int(declaration.get("wings_shadow_target_cursor", 0))
			while shadow_cursor < targets.size():
				var target := int(targets[shadow_cursor])
				declaration.wings_shadow_target_cursor = shadow_cursor + 1
				shadow_cursor += 1
				var defender := int(state.squads[target].owner)
				var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
				state.unit_abilities.window = {"kind": DetachmentStratagems.DARKFLIGHT_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
				var can_wings_of_shadow := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.WINGS_OF_SHADOW).is_empty()
				state.unit_abilities.window = prior_window
				if not can_wings_of_shadow: continue
				declaration.reaction_index = 3
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-darkflight-wings-of-shadow")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.DARKFLIGHT_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
				var message := "Attack declared; %s may use Wings of Shadow before attack dice are rolled." % state.squads[target].name
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		if state.phase == "fight":
			var duty_cursor := int(declaration.get("worthy_target_cursor", 0))
			while duty_cursor < targets.size():
				var target := int(targets[duty_cursor])
				declaration.worthy_target_cursor = duty_cursor + 1
				duty_cursor += 1
				var defender := int(state.squads[target].owner)
				var worthy_rule := DetachmentStratagems.worthy_stratagem(state, defender)
				if worthy_rule.is_empty(): continue
				var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
				state.unit_abilities.window = {"kind": DetachmentStratagems.WORTHY_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "stratagem": worthy_rule, "declaration": declaration.duplicate(true)}
				var can_use_worthy := DetachmentStratagems.error(state, defender, target, worthy_rule).is_empty()
				state.unit_abilities.window = prior_window
				if not can_use_worthy: continue
				declaration.reaction_index = 3
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-worthy-death-reaction")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.WORTHY_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "stratagem": worthy_rule, "declaration": declaration.duplicate(true)}
				var worthy_name := "Duty Unto Death" if worthy_rule == DetachmentStratagems.INNER_CIRCLE_DUTY_UNTO_DEATH else "Duty in Death" if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH else "A Worthy Death"
				var message := "Attack declared; %s may use %s before attack dice are rolled." % [str(state.squads[target].get("name", "the targeted unit")), worthy_name]
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		if UnitAbilities.enabled(state) and not declaration.get("adept_of_the_omnissiah_checked", false):
			declaration.adept_of_the_omnissiah_checked = true
			var adept_candidates := AdeptOfTheOmnissiah.eligible_targets(state, int(declaration.squad), targets)
			if not adept_candidates.is_empty():
				var defender := int(adept_candidates[0].get("owner", -1))
				declaration.reaction_index = 3
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-adept-of-the-omnissiah")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": AdeptOfTheOmnissiah.WINDOW, "owners": [defender], "candidates": adept_candidates.duplicate(true), "declaration": declaration.duplicate(true)}
				var message := "Attack declared; choose whether Adept of the Omnissiah protects an eligible Vehicle before its attack is resolved."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		declaration.reaction_index = 4
		index = 4
	if index <= 4 and UnitAbilities.enabled(state) and not declaration.get("defensive_reaction_checked", declaration.get("mounted_reaction_checked", false)) and not bool(declaration.melee):
		var umbral_targets: Array[int] = []
		for phobos_target: int in prepared.targets:
			var target_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.SHOOTING_REACTION_WINDOW, "owners": [int(state.squads[phobos_target].owner)], "squad": phobos_target, "declaration": declaration.duplicate(true)}
			if DetachmentStratagems.error(state, int(state.squads[phobos_target].owner), phobos_target, DetachmentStratagems.PHOBOS_UMBRAL_EVASION).is_empty(): umbral_targets.append(phobos_target)
			state.unit_abilities.window = target_window
		for target: int in prepared.targets:
			var defender := int(state.squads[target].owner)
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.SHOOTING_REACTION_WINDOW, "owners": [defender], "squad": target, "declaration": declaration.duplicate(true)}
			var can_hurtling := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.HURTLING_TARGETS).is_empty()
			var can_evasive := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.EVASIVE_MANOEUVRES).is_empty()
			var can_umbral := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.PHOBOS_UMBRAL_EVASION).is_empty()
			state.unit_abilities.window = prior_window
			if can_hurtling or can_evasive or can_umbral:
				declaration.defensive_reaction_checked = true
				declaration.reaction_index = 5
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-mounted-defence")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.SHOOTING_REACTION_WINDOW, "owners": [defender], "squad": target, "declaration": declaration.duplicate(true), "can_hurtling": can_hurtling, "can_evasive": can_evasive, "can_umbral": can_umbral, "umbral_targets": umbral_targets.duplicate()}
				var message := "Attack declared; the targeted unit may use a defensive stratagem before dice are rolled."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 5
	if index <= 5 and UnitAbilities.enabled(state) and not declaration.get("head_hunter_checked", false) and not bool(declaration.melee) and DetachmentStratagems.enabled(state):
		var shooter := int(declaration.squad)
		var owner := int(declaration.player)
		var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
		state.unit_abilities.window = {"kind": DetachmentStratagems.HEADHUNTER_WINDOW, "owners": [owner], "squad": shooter, "declaration": declaration.duplicate(true)}
		var can_headhunt := DetachmentStratagems.error(state, owner, shooter, DetachmentStratagems.IRONSTORM_HEADHUNTER).is_empty()
		state.unit_abilities.window = prior_window
		declaration.head_hunter_checked = true
		if can_headhunt:
			declaration.reaction_index = 6
			var frame_error := _suspend_attack_declaration(state, declaration, "attack-headhunter-reaction")
			if not frame_error.is_empty(): return {"error": frame_error}
			state.unit_abilities.window = {"kind": DetachmentStratagems.HEADHUNTER_WINDOW, "owners": [owner], "squad": shooter, "declaration": declaration.duplicate(true)}
			var message := "Selected Vehicle may use Headhunter Doctrine before its ranged attack is prepared."
			_event(state, message)
			return {"error": "", "message": message, "pools": []}
		index = 6
	if index <= 6 and UnitAbilities.enabled(state) and not declaration.get("gravis_annihilating_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var gravis_rule := DetachmentStratagems.gravis_annihilating_rule(state, owner)
		declaration.gravis_annihilating_checked = true
		if not gravis_rule.is_empty():
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
			var can_annihilate := DetachmentStratagems.error(state, owner, attacker_squad, gravis_rule).is_empty()
			state.unit_abilities.window = prior_window
			if can_annihilate:
				declaration.reaction_index = 7
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-gravis-annihilating-reaction")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected GRAVIS unit may use Annihilating Force before its attack is prepared."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 7
	if index <= 7 and UnitAbilities.enabled(state) and not bool(declaration.get("melee", false)) and not declaration.get("terminator_merciless_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var merciless_rule := DetachmentStratagems.terminator_merciless_rule(state, owner)
		declaration.terminator_merciless_checked = true
		if not merciless_rule.is_empty():
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
			var can_use_merciless := DetachmentStratagems.error(state, owner, attacker_squad, merciless_rule).is_empty()
			state.unit_abilities.window = prior_window
			if can_use_merciless:
				declaration.reaction_index = 8
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-terminator-merciless-reaction")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected Terminator unit may use Merciless Veterans before its ranged attack is prepared."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 8
	if index <= 8 and UnitAbilities.enabled(state) and not declaration.get("medusa_methodical_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var methodical_rule := DetachmentStratagems.MEDUSA_METHODICAL_BRUTALITY if DetachmentStratagems.medusa_wrath_enabled(state, owner) else ""
		declaration.medusa_methodical_checked = true
		if not methodical_rule.is_empty():
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
			var can_use_methodical := DetachmentStratagems.error(state, owner, attacker_squad, methodical_rule).is_empty()
			state.unit_abilities.window = prior_window
			if can_use_methodical:
				declaration.reaction_index = 9
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-medusa-methodical-brutality-reaction")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected Adeptus Astartes unit may use Methodical Brutality before its attack is prepared."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 9
	if index <= 9 and UnitAbilities.enabled(state) and not declaration.get("relentless_assault_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var relentless_rule := DetachmentStratagems.relentless_assault_rule(state, owner)
		declaration.relentless_assault_checked = true
		var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
		state.unit_abilities.window = {"kind": DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW, "owners": [owner], "squad": attacker_squad, "stratagem": relentless_rule, "declaration": declaration.duplicate(true)}
		var can_use_relentless := DetachmentStratagems.error(state, owner, attacker_squad, relentless_rule).is_empty()
		state.unit_abilities.window = prior_window
		if can_use_relentless:
			declaration.reaction_index = 10
			var frame_error := _suspend_attack_declaration(state, declaration, "attack-relentless-assault-reaction")
			if not frame_error.is_empty(): return {"error": frame_error}
			state.unit_abilities.window = {"kind": DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW, "owners": [owner], "squad": attacker_squad, "stratagem": relentless_rule, "declaration": declaration.duplicate(true)}
			var message := "Selected Tacticus unit may use Relentless Assault before its attacks are resolved."
			_event(state, message)
			return {"error": "", "message": message, "pools": []}
		index = 10
	if index <= 10 and UnitAbilities.enabled(state) and not declaration.get("phobos_strike_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var phobos_rule := DetachmentStratagems.phobos_strike_rule(state, owner)
		declaration.phobos_strike_checked = true
		if not phobos_rule.is_empty():
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.PHOBOS_STRIKE_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
			var can_use_phobos_strike := DetachmentStratagems.error(state, owner, attacker_squad, phobos_rule).is_empty()
			state.unit_abilities.window = prior_window
			if can_use_phobos_strike:
				declaration.reaction_index = 11
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-phobos-strike-from-the-shadows")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.PHOBOS_STRIKE_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected hidden PHOBOS unit may use Strike from the Shadows before its attack is prepared."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 11
	if index <= 11 and UnitAbilities.enabled(state) and bool(declaration.get("melee", false)) and not declaration.get("pious_enmity_checked", false) and DetachmentStratagems.enabled(state):
		var attacker_squad := int(declaration.squad)
		var owner := int(declaration.player)
		var pious_rule := DetachmentStratagems.VOW_PIOUS_ENMITY if DetachmentStratagems.vow_sworn_enabled(state, owner) else ""
		declaration.pious_enmity_checked = true
		if not pious_rule.is_empty():
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.PIOUS_ENMITY_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
			var can_use_pious := DetachmentStratagems.error(state, owner, attacker_squad, pious_rule).is_empty()
			state.unit_abilities.window = prior_window
			if can_use_pious:
				declaration.reaction_index = 12
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-vow-sworn-pious-enmity")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.PIOUS_ENMITY_WINDOW, "owners": [owner], "squad": attacker_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected Chaplain/Judiciar unit may use Pious Enmity before its melee attack."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 12
	if index <= 12 and UnitAbilities.enabled(state) and bool(declaration.get("melee", false)) and not declaration.get("for_emperors_honour_checked", false) and DetachmentStratagems.enabled(state):
		var honour_squad := int(declaration.squad)
		var honour_owner := int(declaration.player)
		var honour_rule := DetachmentStratagems.VOW_FOR_THE_EMPERORS_HONOUR if DetachmentStratagems.vow_sworn_enabled(state, honour_owner) else ""
		declaration.for_emperors_honour_checked = true
		if not honour_rule.is_empty():
			var honour_prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW, "owners": [honour_owner], "squad": honour_squad, "declaration": declaration.duplicate(true)}
			var can_use_honour := DetachmentStratagems.error(state, honour_owner, honour_squad, honour_rule).is_empty()
			state.unit_abilities.window = honour_prior_window
			if can_use_honour:
				declaration.reaction_index = 13
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-vow-sworn-for-emperors-honour")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW, "owners": [honour_owner], "squad": honour_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected Adeptus Astartes Infantry unit may use For the Emperor's Honour! before its melee attack."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 13
	if index <= 13 and UnitAbilities.enabled(state) and not declaration.get("spoor_of_the_unholy_checked", false) and DetachmentStratagems.enabled(state):
		var spoor_squad := int(declaration.squad)
		var spoor_owner := int(declaration.player)
		var spoor_rule := DetachmentStratagems.VOW_SPOOR_OF_THE_UNHOLY if DetachmentStratagems.vow_sworn_enabled(state, spoor_owner) else ""
		declaration.spoor_of_the_unholy_checked = true
		if not spoor_rule.is_empty():
			var spoor_prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW, "owners": [spoor_owner], "squad": spoor_squad, "declaration": declaration.duplicate(true)}
			var can_use_spoor := DetachmentStratagems.error(state, spoor_owner, spoor_squad, spoor_rule).is_empty()
			state.unit_abilities.window = spoor_prior_window
			if can_use_spoor:
				declaration.reaction_index = 14
				var frame_error := _suspend_attack_declaration(state, declaration, "attack-vow-sworn-spoor-of-the-unholy")
				if not frame_error.is_empty(): return {"error": frame_error}
				state.unit_abilities.window = {"kind": DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW, "owners": [spoor_owner], "squad": spoor_squad, "declaration": declaration.duplicate(true)}
				var message := "Selected Adeptus Astartes unit may use Spoor of the Unholy before its attack."
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		index = 14
	var final_prepared := AttackPlan.prepare(state, int(declaration.squad), bool(declaration.melee), declaration.entries, bool(declaration.use_lethal), int(declaration.hail_target), bool(declaration.get("indirect_shooting", false)))
	if not final_prepared.error.is_empty(): return final_prepared
	if not bool(declaration.melee) and DetachmentStratagems.medusa_power_snap_shooting(state, int(declaration.squad)):
		var snap_batches: Array = final_prepared.get("batches", [])
		for index in range(snap_batches.size()):
			if not snap_batches[index] is Dictionary: continue
			var batch: Dictionary = snap_batches[index]
			var context: Dictionary = batch.get("context", {}).duplicate(true)
			context.snap_shooting = true
			context.snap_hit_threshold = 6
			context.hit_reroll = "none"
			batch["context"] = context
			snap_batches[index] = batch
		final_prepared.batches = snap_batches
	var fortitude_targets: Variant = declaration.get("terminator_fortitude_targets", [])
	final_prepared.terminator_fortitude_targets = fortitude_targets.duplicate(true) if fortitude_targets is Array else []
	return _execute_attack_plan(state, int(declaration.player), int(declaration.attacker), declaration.entries, bool(declaration.melee), roller, final_prepared)

static func _execute_attack_plan(state: Dictionary, player: int, attacker: int, entries: Array, melee: bool, roller: Callable, prepared: Dictionary) -> Dictionary:
	var squad: int = state.units[attacker].squad
	if not melee:
		for row: Variant in entries:
			if not row is Dictionary or not state.units.has(int(row.get("model", -1))): continue
			var model: int = int(row.model)
			var selected := AttackPlan.Equipment.select(state, model, false, str(row.get("weapon", "")), str(row.get("profile", "")))
			if selected.has("error") or not selected.stats.get("keywords", {}).get("one-shot", false): continue
			if not state.units[model].has("one_shot_weapons_used") or not state.units[model].one_shot_weapons_used is Dictionary: state.units[model].one_shot_weapons_used = {}
			state.units[model].one_shot_weapons_used[selected.weapon] = true
	FiringDeck.finish_transport_shooting(state, attacker)
	var precision := false
	var ability_window := false
	for batch: Dictionary in prepared.batches:
		if batch.weapon.keywords.get("precision", false): precision = true
		if batch.context.get("martial_paragon", false) or batch.context.get("free_wound_reroll", false) or batch.context.get("free_damage_reroll", false) or batch.context.get("machine_spirit_power", false) or batch.context.get("armoured_wrath", false): ability_window = true
		var target_squad := int(batch.get("target", -1))
		if AdeptOfTheOmnissiah.active_for_attack(state, squad, target_squad): ability_window = true
		if batch.weapon.keywords.get("devastating-wounds", false) and state.squads.has(target_squad):
			var defender_owner := int(state.squads[target_squad].get("owner", -1))
			if DetachmentStratagems.ironstorm_enabled(state, defender_owner) and DetachmentStratagems.ironstorm_vehicle_unit(state, target_squad, true): ability_window = true
	if state.get("manual_allocation", false) or precision or ability_window or state.get("stratagems", {}).get("attack_rerolls", false) or state.get("stratagems", {}).get("save_rerolls", false) or state.get("stratagems", {}).get("damage_rerolls", false) or state.get("stratagems", {}).get("count_rerolls", false):
		var working := state.duplicate(true)
		Allocation.start(working, prepared, squad, player, entries, melee, not state.get("manual_allocation", false))
		var current_frame := ResolutionFrames.current(working)
		var attack_action_id := str(current_frame.get("action_id", "")) if str(current_frame.get("kind", "")) == "attack" else _new_attack_resolution_action_id(working, squad)
		working.pending_attack.resolution_action_id = attack_action_id
		if ResolutionFrames.begin(working, "attack", attack_action_id, "attack-damage-resolution").is_empty(): return {"error": "Could not open the attack resolution frame."}
		var rolled := Allocation.pump(working, roller)
		if not rolled.error.is_empty(): return rolled
		var result: Dictionary
		if rolled.complete: result = _finish_pending_attack(working, roller)
		else:
			var pending_choice_window := UnitActions.pending(working)
			var message := "Attack declared; player %d must allocate damage to %s." % [actor(working), working.squads[working.pending_attack.current.target].name]
			if pending_choice_window.get("kind", "") == "wound": message = "%s: choose wound rerolls before saves." % working.pending_attack.current.checkpoint.context.get("free_wound_reroll_source", "Implacable Eradication")
			if pending_choice_window.get("kind", "") == "aquilon-hit": message = "Aquilon Optics: choose one hit die to re-roll, or continue."
			if pending_choice_window.get("kind", "") == "martial-paragon-hit": message = "Martial Paragon: choose one Hit die to re-roll for this unit's attack, or continue."
			if pending_choice_window.get("kind", "") == "martial-paragon-wound": message = "Martial Paragon: choose one Wound die to re-roll for this unit's attack, or continue."
			if pending_choice_window.get("kind", "") in ["machine-spirit-hit", "machine-spirit-wound"]: message = "%s: choose one %s die to re-roll, or continue." % [pending_choice_window.get("source", "Power of the Machine Spirit"), "hit" if pending_choice_window.kind == "machine-spirit-hit" else "wound"]
			if pending_choice_window.get("kind", "") in ["armoured-wrath-hit", "armoured-wrath-wound"]: message = "Armoured Wrath: choose one %s die to re-roll, or continue." % ("hit" if pending_choice_window.kind == "armoured-wrath-hit" else "wound")
			if pending_choice_window.get("kind", "") == "damage-reroll": message = "Choose whether to re-roll this Damage roll with %s." % ", ".join(pending_choice_window.get("sources", [pending_choice_window.get("source", "Total Obliteration")]))
			if not Stratagems.pending(working).is_empty(): message = "Attack paused: accept the roll or choose a D6 for Command Re-roll before the next step."
			var suspend_error := _suspend_attack_resolution_frame(working, attack_action_id, "attack-damage-decision")
			if not suspend_error.is_empty(): return {"error": suspend_error}
			_event(working, message)
			result = {"error": "", "message": message, "pools": working.pending_attack.pools}
		if not result.error.is_empty(): return result
		state.clear()
		state.merge(working, true)
		return result
	var resolved := AttackPlan.resolve(state, prepared, roller, melee)
	if not resolved.error.is_empty(): return resolved
	var working := state.duplicate(true)
	working.units = resolved.units
	var result := _finish_attack(working, squad, player, entries, melee, prepared, resolved, roller)
	if not result.error.is_empty(): return result
	state.clear()
	state.merge(working, true)
	return result

static func _finish_attack(state: Dictionary, squad: int, player: int, entries: Array, melee: bool, prepared: Dictionary, resolved: Dictionary, roller: Callable, manage_resolution_frame: bool = true) -> Dictionary:
	AdeptOfTheOmnissiah.clear_after_attack(state, squad)
	var frame := ResolutionFrames.current(state)
	var attack_action_id := str(frame.get("action_id", "")) if frame.get("kind", "") == "attack" else ""
	var owns_attack_frame := not attack_action_id.is_empty()
	if attack_action_id.is_empty() and int(prepared.get("hazardous_count", 0)) > 0:
		attack_action_id = _new_attack_resolution_action_id(state, squad)
		if ResolutionFrames.begin(state, "attack", attack_action_id, "attack-hazard-resolution").is_empty(): return {"error": "Could not open the attack resolution frame."}
		owns_attack_frame = true
	var hazard := Hazard.roll(state, squad, int(prepared.get("hazardous_count", 0)), roller, prepared.get("hazard_modifiers", []))
	if not hazard.error.is_empty(): return hazard
	resolved.hazardous = hazard
	if UnitAbilities.enabled(state) and MarineEnhancements.active(state, squad, MarineEnhancements.NIGHTFORGED_BATTERY) and not hazard.rolls.is_empty() and not living(state, squad).is_empty():
		state.pending_hazard = {"squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee, "prepared": prepared, "resolved": resolved, "remaining": hazard.total}
		if not attack_action_id.is_empty(): state.pending_hazard.resolution_action_id = attack_action_id
		var eligible: Array[int] = []
		for index in range(hazard.rolls.size()): eligible.append(index)
		state.unit_abilities.window = {"kind": "nightforged-hazard", "owners": [player], "eligible": eligible}
		var message := "Nightforged Battery: re-roll any Hazard dice before accepting the results."
		if owns_attack_frame and manage_resolution_frame:
			var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-reroll")
			if not suspend_error.is_empty(): return {"error": suspend_error}
		_event(state, message)
		return {"error": "", "message": message, "pools": resolved.pools}
	if state.get("stratagems", {}).get("hazard_rerolls", false) and not hazard.rolls.is_empty() and not living(state, squad).is_empty() and Stratagems.eligibility_error(state, player, squad, "command-re-roll").is_empty():
		state.pending_hazard = {"squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee, "prepared": prepared, "resolved": resolved, "remaining": hazard.total}
		var indices: Array[int] = []
		for index in range(hazard.rolls.size()): indices.append(index)
		state.stratagems.pending = {"kind": "after_hazardous_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": hazard.rolls.duplicate(), "eligible": indices}
		if not attack_action_id.is_empty(): state.pending_hazard.resolution_action_id = attack_action_id
		var message := "Hazardous: accept the results or replace one D6 before allocation."
		if owns_attack_frame and manage_resolution_frame:
			var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-reroll")
			if not suspend_error.is_empty(): return {"error": suspend_error}
		_event(state, message)
		return {"error": "", "message": message, "pools": resolved.pools}
	if hazard.total > 0 and not living(state, squad).is_empty():
		state.pending_hazard = {"squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee, "prepared": prepared, "resolved": resolved, "remaining": hazard.total}
		if not attack_action_id.is_empty(): state.pending_hazard.resolution_action_id = attack_action_id
		var message := "Player %d: allocate %d Hazardous mortal wounds to %s." % [player, hazard.total, state.squads[squad].name]
		if owns_attack_frame and manage_resolution_frame:
			var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-allocation")
			if not suspend_error.is_empty(): return {"error": suspend_error}
		_event(state, message)
		return {"error": "", "message": message, "pools": resolved.pools}
	var committed := _commit_finished_attack(state, squad, player, entries, melee, prepared, resolved, roller)
	if not committed.get("error", "").is_empty(): return committed
	if owns_attack_frame and manage_resolution_frame:
		var frame_error := _complete_attack_resolution_frame(state, attack_action_id)
		if not frame_error.is_empty(): return {"error": frame_error}
		var charge_frame_error := _settle_charge_frame_after_reaction(state)
		if not charge_frame_error.is_empty(): return {"error": charge_frame_error}
	return committed

static func _commit_finished_attack(state: Dictionary, squad: int, player: int, entries: Array, melee: bool, prepared: Dictionary, resolved: Dictionary, roller: Callable) -> Dictionary:
	if melee:
		var unit_abilities: Dictionary = state.get("unit_abilities", {})
		if unit_abilities.get("banner_active", {}).has(squad): unit_abilities.banner_active.erase(squad)
		state.squads[squad].fought = true
		state.squads[squad].fight_eligible = true
		DetachmentStratagems.remove_lingering(state, squad)
		if UnitAbilities.enabled(state) and unit_abilities.get("used", {}).get("righteous-active:%d" % squad, false):
			var heal_roll := RandomStat.roll("2D3" if int(resolved.get("killed", 0)) > 0 else "D3", roller)
			if not heal_roll.error.is_empty(): return heal_roll
			for model: int in Contact.alive(state, squad):
				if UnitAbilities.identity(state.units[model]) != "captain-titus": continue
				var wounds_before: int = int(state.units[model].wounds)
				state.units[model].wounds = mini(int(state.units[model].max_wounds), int(state.units[model].wounds) + int(heal_roll.value))
				unit_abilities.last_titus_heal = {"model": model, "roll": heal_roll.duplicate(true), "wounds_restored": int(state.units[model].wounds) - wounds_before}
				_event(state, "Righteous Fury: Captain Titus heals %d wound(s)." % int(heal_roll.value))
				break
			unit_abilities.used.erase("righteous-active:%d" % squad)
		state.squads[squad].fights_first = false
		if not CoreReactions.offer_fight_reaction(state, squad):
			if state.fight_step == "consolidation_reaction": _resume_consolidation(state)
			else: _select_fighter(state, 3 - player)
	else:
		if CoreReactions.overwatch_shooter(state, squad):
			CoreReactions.clear_overwatch(state)
		else:
			state.squads[squad].shot = true
			state.squads[squad].last_ranged_turn = state.turn
			if prepared.get("indirect_shooting", false): state.squads[squad].indirect_shooting_block = "%d:%s" % [state.turn, state.phase]
		if DetachmentStratagems.reactive_shooting_shooter(state, squad): DetachmentStratagems.clear_reactive_shooting(state, squad)
	if not melee and UnitAbilities.enabled(state) and state.unit_abilities.get("optics", {}).get("squad", -1) == squad: state.unit_abilities.erase("optics")
	DetachmentStratagems.after_attacks(state, squad, prepared.targets, int(resolved.killed), prepared, resolved, melee)
	UnitAbilities.offer_cover_target(state, squad, prepared, resolved, melee)
	UnitAbilities.open_destroyed_mark_replacements(state)
	if not melee and state.phase == "shooting" and state.active == player and UnitAbilities.enabled(state):
		TacticalFluidity.open_after_shot(state, squad)
		PurgationRun.open_after_shot(state, squad)
		PhobosShadowMasters.open_after_shot(state, squad)
	if not melee and state.phase == "shooting" and state.active == player and UnitAbilities.enabled(state):
		VictrixHonourGuard.open_after_enemy_shot(state, squad, resolved.pools)
	var names: Array[String] = []
	for target: int in prepared.targets: names.append(state.squads[target].name)
	var message := "%s%s → %s: %d damage, %d models destroyed." % [state.squads[squad].name, " melee" if melee else "", ", ".join(names), resolved.damage, resolved.killed]
	if melee and not state.get("unit_abilities", {}).get("window", {}).is_empty() and state.unit_abilities.window.get("kind", "") == "counter":
		var reaction_owner := int(state.unit_abilities.window.get("owners", [3 - player])[0])
		if not DetachmentStratagems.transhuman_swiftness_choices(state, reaction_owner).is_empty(): message += " Player %d may use an eligible Fight reaction or decline." % reaction_owner
		else: message += " Opponent may use Counteroffensive or decline."
	_record_training_attack(state, entries, prepared)
	if not Objectives.training(state) and not Mission.enabled(state) and (living_owner(state, 1).is_empty() or living_owner(state, 2).is_empty()):
		state.test_winner = -1 if living_owner(state, 1).is_empty() and living_owner(state, 2).is_empty() else (2 if living_owner(state, 1).is_empty() else 1)
		message += " Elimination exercise finished."
	state.last_attack = {"completion_revision": int(state.revision) + 1, "message": message, "pools": resolved.pools, "assignments": entries.duplicate(true), "targets": prepared.targets.duplicate()}
	state.last_attack.hazardous = resolved.get("hazardous", {})
	if prepared.has("hail_of_bolts"):
		state.last_attack.hail_of_bolts = prepared.hail_of_bolts.duplicate(true)
		message += " Hail of Bolts: " + state.squads[prepared.hail_of_bolts.target].name + "."
		state.last_attack.message = message
	_event(state, message)
	return {"error": "", "message": message, "pools": resolved.pools}

static func _unrerolled_hazard_indices(hazard: Dictionary) -> Array[int]:
	var used: Array[int] = []
	for reroll: Dictionary in hazard.get("rerolls", []): used.append(int(reroll.get("index", -1)))
	var result: Array[int] = []
	for index in range(hazard.get("rolls", []).size()):
		if index not in used: result.append(index)
	return result

static func _continue_nightforged_hazard(state: Dictionary, player: int, roller: Callable) -> String:
	var pending: Dictionary = state.get("pending_hazard", {})
	if pending.is_empty(): return "The Nightforged Battery Hazard continuation is missing."
	var squad := int(pending.get("squad", -1))
	var attack_action_id := _attack_resolution_action_id(state)
	var frame_error := _resume_attack_resolution_frame(state, "attack-hazard-reroll")
	if not frame_error.is_empty(): return frame_error
	var hazard: Dictionary = pending.resolved.hazardous
	var eligible := _unrerolled_hazard_indices(hazard)
	if state.get("stratagems", {}).get("hazard_rerolls", false) and not eligible.is_empty() and not living(state, squad).is_empty() and Stratagems.eligibility_error(state, player, squad, "command-re-roll").is_empty():
		state.stratagems.pending = {"kind": "after_hazardous_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": hazard.rolls.duplicate(), "eligible": eligible}
		frame_error = _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-reroll")
		if not frame_error.is_empty(): return frame_error
		_event(state, "Nightforged Battery re-rolls resolved; accept the Hazard results or use Command Re-roll on an eligible die.")
		return ""
	pending.remaining = hazard.total
	if pending.remaining > 0 and not living(state, squad).is_empty():
		frame_error = _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-allocation")
		if not frame_error.is_empty(): return frame_error
		_event(state, "Hazardous confirmed; allocate %d mortal wound(s)." % int(pending.remaining))
		return ""
	hazard.discarded = int(pending.remaining)
	state.pending_hazard = {}
	var committed := _commit_finished_attack(state, squad, player, pending.entries, bool(pending.melee), pending.prepared, pending.resolved, roller)
	if not committed.get("error", "").is_empty(): return str(committed.error)
	frame_error = _complete_attack_resolution_frame(state, attack_action_id)
	if not frame_error.is_empty(): return frame_error
	return _settle_charge_frame_after_reaction(state)

static func _single_target_attack(state: Dictionary, player: int, attacker: int, target: int, revision: int, melee: bool, use_lethal: bool, roller: Callable) -> Dictionary:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return {"error": error}
	if not state.units.has(target) or state.units[target].wounds <= 0 or state.units[target].owner == player: return {"error": "Select a living enemy target."}
	var point_blank_preview := not melee and DetachmentStratagems.point_blank_brutality_available(state, player, state.units[attacker].squad)
	var entries := AttackPlan.single_target(state, state.units[attacker].squad, state.units[target].squad, melee, point_blank_preview)
	return resolve_attack_plan(state, player, attacker, entries, revision, melee, use_lethal, roller)

static func _finish_pending_attack(state: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = state.pending_attack
	var attack_action_id := _attack_resolution_action_id(state)
	var resume_error := _resume_attack_resolution_frame(state, "attack-finalization")
	if not resume_error.is_empty(): return {"error": resume_error}
	if not pending.get("deadly_demise_checked", false):
		var destroyed: Array[int] = []
		for pool: Dictionary in pending.get("pools", []):
			for allocation: Dictionary in pool.get("allocations", []):
				var model: int = int(allocation.get("model", -1))
				if model >= 0 and state.units.has(model) and state.units[model].wounds <= 0 and model not in destroyed: destroyed.append(model)
		pending.deadly_demise_checked = true
		var demise := DeadlyDemise.begin(state, destroyed, roller)
		if not demise.error.is_empty(): return demise
		if not demise.get("complete", true):
			var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, "attack-destroyed-model-reactions")
			if not suspend_error.is_empty(): return {"error": suspend_error}
			_event(state, str(demise.get("message", "Resolve Deadly Demise.")))
			return demise
		pending = state.pending_attack
	if not pending.get("forward_assault_checked", false):
		pending.forward_assault_checked = true
		if UnitAbilities.open_destroyed_mark_replacements(state):
			var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, "attack-mark-replacement")
			if not suspend_error.is_empty(): return {"error": suspend_error}
			return {"error": "", "complete": false}
	state.pending_attack = {}
	var finished := _finish_attack(state, pending.squad, pending.player, pending.entries, pending.melee, pending.prepared, {"pools": pending.pools, "damage": pending.damage, "killed": pending.killed}, roller, false)
	if not finished.get("error", "").is_empty(): return finished
	if not state.get("pending_hazard", {}).is_empty():
		state.pending_hazard.resolution_action_id = attack_action_id
		var resume_point := "attack-hazard-reroll" if not UnitActions.pending(state).is_empty() or not Stratagems.pending(state).is_empty() else "attack-hazard-allocation"
		var suspend_error := _suspend_attack_resolution_frame(state, attack_action_id, resume_point)
		if not suspend_error.is_empty(): return {"error": suspend_error}
		return finished
	var frame_error := _complete_attack_resolution_frame(state, attack_action_id)
	if not frame_error.is_empty(): return {"error": frame_error}
	var charge_frame_error := _settle_charge_frame_after_reaction(state)
	if not charge_frame_error.is_empty(): return {"error": charge_frame_error}
	return finished

static func resolve_attack_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable) -> String:
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if Stratagems.pending(state).kind not in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_attack_count_roll"]: return "There is no pending attack decision."
	if stratagem not in ["", "command-re-roll"]: return "Invalid stratagem for this roll."
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
	var working := state.duplicate(true)
	var attack_action_id := _attack_resolution_action_id(working)
	var frame_error := _resume_attack_resolution_frame(working, "attack-roll-reaction")
	if not frame_error.is_empty(): return frame_error
	var current: Dictionary = working.pending_attack.current
	var original: Array = Stratagems.pending(state).rolls.duplicate()
	var saving: bool = Stratagems.pending(state).kind == "after_save_roll"
	var damaging: bool = Stratagems.pending(state).kind == "after_damage_roll"
	if not stratagem.is_empty():
		if damaging:
			var replacement := Attacks.RandomStat.replace_die(current.pending_damage.rolled, die, roller)
			if not replacement.error.is_empty(): return replacement.error
			current.pending_damage.rolled = replacement
			current.result.dice_history.append(replacement.rolls[die])
		elif saving:
			if die not in Stratagems.pending(state).eligible: return "Select a D6 from this save roll."
			if not roller.is_valid(): return "Missing dice provider."
			var dice := Attacks.Dice.new(roller)
			var value := dice.d6()
			if not dice.error.is_empty(): return dice.error
			current.result.save_rerolls = [{"index": die, "original": current.result.save_rolls[die], "replacement": value}]
			current.result.save_rolls[die] = value
			current.result.dice_history.append(value)
		else:
			var replacement := Allocation.RollWindows.reroll(current.checkpoint, die, current.checkpoint.revision, roller)
			if not replacement.error.is_empty(): return replacement.error
			current.checkpoint = replacement
		Stratagems.consume(working, player, squad, stratagem)
	var generating: bool = Stratagems.pending(state).kind == "after_attack_count_roll"
	var final_rolls: Array = current.checkpoint.generated.rolls.duplicate() if generating else (current.pending_damage.rolled.rolls.duplicate() if damaging else (current.result.save_rolls.duplicate() if saving else (current.checkpoint.hit_rolls.duplicate() if current.checkpoint.phase == "hit" else current.checkpoint.effective_wounds.duplicate())))
	working.last_command_roll = {"kind": Stratagems.pending(state).kind, "squad": squad, "original_rolls": original, "rolls": final_rolls, "rerolled": not stratagem.is_empty(), "die": die}
	if generating: working.last_command_roll.total = current.checkpoint.generated.count
	working.stratagems.pending = {}
	if damaging:
		working.last_command_roll.expression = current.pending_damage.rolled.expression
		working.last_command_roll.value = current.pending_damage.rolled.value
		current.phase = "damage_finalize"
	elif saving: current.phase = "save_finalize"
	else: current.accepted = true
	var resumed := Allocation.pump(working, roller)
	if not resumed.error.is_empty(): return resumed.error
	if resumed.complete:
		var finished := _finish_pending_attack(working, roller)
		if not finished.error.is_empty(): return finished.error
	else:
		frame_error = _suspend_attack_resolution_frame(working, attack_action_id, "attack-roll-reaction")
		if not frame_error.is_empty(): return frame_error
		_event(working, "Attack roll decision accepted; player %d continues." % actor(working))
	state.clear()
	state.merge(working, true)
	return ""

static func allocate_damage(state: Dictionary, player: int, model: int, revision: int, roller: Callable) -> String:
	if state.test_winner != 0: return "Exercise finished."
	if revision != state.revision: return "State changed; synchronize before allocating."
	var error := Allocation.choice_error(state, player, model)
	if not error.is_empty(): return error
	var working := state.duplicate(true)
	var attack_action_id := _attack_resolution_action_id(working)
	var frame_error := _resume_attack_resolution_frame(working, "attack-defender-allocation")
	if not frame_error.is_empty(): return frame_error
	var applied := Allocation.apply(working, model, roller)
	if not applied.error.is_empty(): return applied.error
	var result := Allocation.pump(working, roller)
	if not result.error.is_empty(): return result.error
	if result.complete:
		var finished := _finish_pending_attack(working, roller)
		if not finished.error.is_empty(): return finished.error
	else:
		frame_error = _suspend_attack_resolution_frame(working, attack_action_id, "attack-defender-allocation")
		if not frame_error.is_empty(): return frame_error
		_event(working, "Allocation choice accepted for model %d; player %d continues the attack sequence." % [model, actor(working)])
	state.clear()
	state.merge(working, true)
	return ""

static func resolve_hazard_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable) -> String:
	if Stratagems.pending(state).get("kind", "") == "after_transport_hazard_roll":
		return TransportRules.resolve_hazard_reaction(state, player, squad, stratagem, revision, die, roller)
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if Stratagems.pending(state).kind != "after_hazardous_roll": return "There is no pending Hazardous decision."
	if stratagem not in ["", "command-re-roll"]: return "Invalid stratagem for this decision."
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
		if die not in Stratagems.pending(state).eligible: return "Select a D6 from this Hazardous pool."
	var working := state.duplicate(true)
	var attack_action_id := _attack_resolution_action_id(working)
	var frame_error := _resume_attack_resolution_frame(working, "attack-hazard-reroll")
	if not frame_error.is_empty(): return frame_error
	var pending: Dictionary = working.pending_hazard
	var original: Array = pending.resolved.hazardous.rolls.duplicate()
	if not stratagem.is_empty():
		if not roller.is_valid(): return "Missing hazard dice provider."
		var value: Variant = roller.call()
		if not value is int or value < 1 or value > 6: return "Hazard dice must be integers from 1 to 6."
		var final_rolls: Array = original.duplicate()
		final_rolls[die] = value
		var replaced := Hazard.from_rolls(working, squad, final_rolls, pending.prepared.get("hazard_modifiers", []))
		if not replaced.error.is_empty(): return replaced.error
		var prior_rerolls: Array = pending.resolved.hazardous.get("rerolls", []).duplicate(true)
		prior_rerolls.append({"index": die, "original": original[die], "replacement": value, "source": "Command Re-roll"})
		replaced.rerolls = prior_rerolls
		pending.resolved.hazardous = replaced
		Stratagems.consume(working, player, squad, stratagem)
	working.last_command_roll = {"kind": "after_hazardous_roll", "squad": squad, "original_rolls": original, "rolls": pending.resolved.hazardous.rolls.duplicate(), "rerolled": not stratagem.is_empty(), "die": die}
	working.stratagems.pending = {}
	pending.remaining = pending.resolved.hazardous.total
	if pending.remaining > 0 and not living(working, squad).is_empty():
		frame_error = _suspend_attack_resolution_frame(working, attack_action_id, "attack-hazard-allocation")
		if not frame_error.is_empty(): return frame_error
		_event(working, "Hazardous confirmado; aloque %d ferida(s) mortal(is)." % pending.remaining)
	else:
		working.pending_hazard = {}
		var committed := _commit_finished_attack(working, squad, player, pending.entries, pending.melee, pending.prepared, pending.resolved, roller)
		if not committed.error.is_empty(): return committed.error
		frame_error = _complete_attack_resolution_frame(working, attack_action_id)
		if not frame_error.is_empty(): return frame_error
		var charge_frame_error := _settle_charge_frame_after_reaction(working)
		if not charge_frame_error.is_empty(): return charge_frame_error
	state.clear()
	state.merge(working, true)
	return ""

static func allocate_hazard(state: Dictionary, player: int, model: int, revision: int, roller: Callable = Callable()) -> String:
	if revision != state.revision: return "State changed; synchronize before allocating."
	var error := Hazard.choice_error(state, player, model)
	if not error.is_empty(): return error
	var attack_action_id := _attack_resolution_action_id(state)
	var frame_error := _resume_attack_resolution_frame(state, "attack-hazard-allocation")
	if not frame_error.is_empty(): return frame_error
	var pending: Dictionary = state.pending_hazard
	var prevention := Attacks.Prevention.resolve(1, state.units[model].wounds, UnitPrevention.rules(state, model), "mortal", roller)
	if not prevention.error.is_empty(): return prevention.error
	state.units[model].wounds -= prevention.lost
	pending.remaining -= 1
	pending.resolved.hazardous.allocations.append(model)
	if not pending.resolved.hazardous.has("prevention"): pending.resolved.hazardous.prevention = []
	pending.resolved.hazardous.prevention.append(prevention)
	if pending.remaining == 0 or living(state, pending.squad).is_empty():
		pending.resolved.hazardous.discarded = pending.remaining
		state.pending_hazard = {}
		var committed := _commit_finished_attack(state, pending.squad, pending.player, pending.entries, pending.melee, pending.prepared, pending.resolved, roller)
		if not committed.error.is_empty(): return committed.error
		frame_error = _complete_attack_resolution_frame(state, attack_action_id)
		if not frame_error.is_empty(): return frame_error
		var charge_frame_error := _settle_charge_frame_after_reaction(state)
		if not charge_frame_error.is_empty(): return charge_frame_error
	else: _event(state, "Hazardous mortal wound allocated to model %d." % model)
	if not state.get("pending_hazard", {}).is_empty():
		frame_error = _suspend_attack_resolution_frame(state, attack_action_id, "attack-hazard-allocation")
		if not frame_error.is_empty(): return frame_error
	return ""

static func fight(state: Dictionary, player: int, attacker: int, target: int, revision: int, roller: Callable) -> Dictionary:
	return _single_target_attack(state, player, attacker, target, revision, true, true, roller)

static func shoot(state: Dictionary, player: int, attacker: int, target: int, revision: int, use_lethal: bool, roller: Callable) -> Dictionary:
	return _single_target_attack(state, player, attacker, target, revision, false, use_lethal, roller)

static func resolve_reanimation(state: Dictionary, player: int, action: String, squad: int, model: int, position: Vector2, revision: int, roller: Callable = Callable()) -> String:
	var error := Reanimation.choice_error(state, player, revision)
	if not error.is_empty(): return error
	var reanimation_kind := str(Reanimation.pending(state).get("kind", ""))
	if action not in ["roll", "place", "suggest", "unplaceable", "reset", "confirm"]: return "Unknown Reanimation action."
	if Reanimation.pending(state).current.get("reroll_pending", false): return "Accept or re-roll Their Number is Legion before assigning healing."
	var working := state.duplicate(true)
	var result: Dictionary
	match action:
		"roll": result = Reanimation.roll_unit(working, squad, roller)
		"place": result = Reanimation.place_model(working, model, position)
		"suggest": result = Reanimation.suggest(working)
		"unplaceable": result = Reanimation.declare_unplaceable(working, model)
		"reset": result = Reanimation.reset_preview(working)
		"confirm": result = Reanimation.confirm_unit(working)
	if not result.error.is_empty(): return result.error
	_event(working, result.message)
	if reanimation_kind == "undying" and Reanimation.pending(working).is_empty():
		error = _complete_undying_attack_frame(working)
		if not error.is_empty(): return error
	if reanimation_kind != "undying" and Reanimation.pending(working).is_empty() and UnitActions.pending(working).is_empty():
		error = advance_phase(working, player, working.revision, roller)
		if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func select_combat_doctrine(state: Dictionary, player: int, doctrine: String, revision: int) -> String:
	var error := Doctrines.choice_error(state, player, doctrine, revision)
	if not error.is_empty(): return error
	var doctrine_frame_id := ""
	if state.combat_doctrines.cp_pending_turn == state.turn:
		var doctrine_action_id := _phase_start_action_id(state)
		var current_frame := ResolutionFrames.current(state)
		if not current_frame.is_empty() and (str(current_frame.get("kind", "")) != "phase-start" or str(current_frame.get("action_id", "")) != doctrine_action_id):
			return "The Command-start doctrine frame is not the active resolution."
		var doctrine_frame := ResolutionFrames.begin(state, "phase-start", doctrine_action_id, "resume-command-doctrine-selection")
		if doctrine_frame.is_empty(): return "Could not resume the Command-start doctrine frame."
		doctrine_frame_id = str(doctrine_frame.frame_id)
	Doctrines.select_doctrine(state, player, doctrine)
	if state.combat_doctrines.cp_pending_turn == state.turn:
		state.cp[1] += 1
		state.cp[2] += 1
		state.combat_doctrines.cp_pending_turn = -1
		if OathOfMoment.needs_choice(state) or VowedTarget.needs_choice(state) or not UnitActions.phase_decision(state).is_empty():
			var suspend_error := ResolutionFrames.suspend(state, doctrine_frame_id, "phase-start-unit-abilities")
			if not suspend_error.is_empty(): return suspend_error
		else:
			var complete_error := ResolutionFrames.complete(state, doctrine_frame_id)
			if not complete_error.is_empty(): return complete_error
	_event(state, "Player %d: %s (11e Combat Doctrines; Gladius extra use %s)." % [player, Doctrines.NAMES[doctrine], "spent" if state.combat_doctrines.extra_used.get(player, false) else "available"] if Doctrines.detachment_for(state, player) == "gladius" else "Player %d: %s (11e Combat Doctrines; %s detachment)." % [player, Doctrines.NAMES[doctrine], Doctrines.detachment_for(state, player).capitalize()])
	return ""

static func select_awakened_attachment(state: Dictionary, player: int, bodyguard: int, revision: int) -> String:
	if Mission.actor(state) > 0: return "Resolve mission preparation before attachment declarations."
	var leader: int = state.get("awakened_dynasty", {}).get("pending", [-1])[0] if Awakened.needs_setup(state) else -1
	var error := Awakened.choose(state, player, bodyguard, revision)
	if not error.is_empty(): return error
	_event(state, "Player %d declared Overlord %d %s. Review and confirm deployment for every model." % [player, leader, "standalone" if bodyguard == -1 else "leading " + state.squads[bodyguard].name])
	return ""

static func unit_choices(state: Dictionary, player: int) -> Array:
	if Mission.actor(state) > 0: return Mission.choices(state, player)
	return UnitActions.choices(state, player)

static func unit_action(state: Dictionary, player: int, selected: Dictionary, point: Vector2, revision: int, roller: Callable = Callable()) -> String:
	if revision != state.get("revision", -1): return "State changed; synchronize before choosing an ability."
	if selected not in unit_choices(state, player): return "This unit ability choice is no longer legal."
	var working := state.duplicate(true)
	if Mission.actor(working) > 0:
		var mission_error := Mission.apply(working, player, selected, roller)
		if not mission_error.is_empty(): return mission_error
		if selected.action == "mission-side": Deployment.begin(working)
		_event(working, selected.label)
		state.clear()
		state.merge(working, true)
		return ""
	var reanimation_kind_before_choice := str(Reanimation.pending(working).get("kind", ""))
	var was_reanimation := not reanimation_kind_before_choice.is_empty()
	var phase_start_frame_id := ""
	if not UnitActions.phase_decision(working).is_empty() or not working.get("fearsome_assault", {}).is_empty() or not DetachmentStratagems.adamantine_pending(working).is_empty():
		var action_id := _phase_start_action_id(working)
		var current_frame := ResolutionFrames.current(working)
		if current_frame.is_empty() or (str(current_frame.get("kind", "")) == "phase-start" and str(current_frame.get("action_id", "")) == action_id):
			var phase_start_frame := ResolutionFrames.begin(working, "phase-start", action_id, "resume-phase-start-unit-abilities")
			if phase_start_frame.is_empty(): return "Could not resume the phase-start ability frame."
			phase_start_frame_id = str(phase_start_frame.frame_id)
	var fight_counter_frame_id := ""
	if UnitActions.pending(working).get("kind", "") == "counter":
		var action_id := _counteroffensive_action_id(working)
		var current_frame := ResolutionFrames.current(working)
		if not current_frame.is_empty() and (str(current_frame.get("kind", "")) != "fight" or str(current_frame.get("action_id", "")) != action_id):
			return "The Counteroffensive continuation frame is not the active resolution."
		var fight_frame := ResolutionFrames.begin(working, "fight", action_id, "resume-counteroffensive-choice")
		if fight_frame.is_empty(): return "Could not resume the Counteroffensive continuation frame."
		fight_counter_frame_id = str(fight_frame.frame_id)
	if DetachmentStratagems.shooting_reaction_actor(working) == player:
		var vengeful_action_id := _vengeful_action_id(working)
		var current_frame := ResolutionFrames.current(working)
		if not current_frame.is_empty() and (str(current_frame.get("kind", "")) != "shooting-reaction" or str(current_frame.get("action_id", "")) != vengeful_action_id):
			return "The Vengeful Stars continuation frame is not the active resolution."
		var vengeful_frame := ResolutionFrames.begin(working, "shooting-reaction", vengeful_action_id, "resume-vengeful-choice")
		if vengeful_frame.is_empty(): return "Could not resume the Vengeful Stars continuation frame."
	var pending_unit_action := UnitActions.pending(working)
	var declaration_value: Variant = pending_unit_action.get("declaration", {})
	var movement_reaction_squad := UnitActions.movement_reaction_squad(working)
	var movement_reaction_frame_id := ""
	if movement_reaction_squad >= 0:
		var movement_frame := _begin_movement_frame(working, movement_reaction_squad, "resume-movement-post-move-reaction")
		if movement_frame.is_empty(): return "Could not resume the completed Movement reaction frame."
		movement_reaction_frame_id = str(movement_frame.frame_id)
	var post_attack_action_id := ""
	var post_attack_frame_id := ""
	var active_frame := ResolutionFrames.current(working)
	if _post_attack_reaction_pending(working) and str(active_frame.get("kind", "")) == "attack" and str(active_frame.get("status", "")) == "suspended" and str(active_frame.get("resume_point", "")) == "attack-post-resolution-choice":
		post_attack_action_id = str(active_frame.action_id)
		var resumed_attack_frame := ResolutionFrames.begin(working, "attack", post_attack_action_id, "resume-attack-post-resolution-choice")
		if resumed_attack_frame.is_empty(): return "Could not resume the post-attack reaction frame."
		post_attack_frame_id = str(resumed_attack_frame.frame_id)
	var attack_declaration_frame_id := ""
	var empty_fight_frame_id := ""
	if typeof(declaration_value) == TYPE_DICTIONARY and str(declaration_value.get("kind", "")) == "attack":
		var declaration: Dictionary = declaration_value
		var declaration_action_id := _attack_declaration_action_id(working, declaration)
		var attack_frame := ResolutionFrames.begin(working, "attack", declaration_action_id, "resume-attack-declaration-choice")
		if attack_frame.is_empty(): return "Could not resume the pending attack declaration frame."
		attack_declaration_frame_id = str(attack_frame.frame_id)
		pending_unit_action.declaration = declaration
		working.unit_abilities.window = pending_unit_action
	elif typeof(declaration_value) == TYPE_DICTIONARY and str(declaration_value.get("kind", "")) == "empty-fight":
		var declaration: Dictionary = declaration_value
		var action_id := str(declaration.get("resolution_action_id", ""))
		if action_id.is_empty(): return "The unengaged Fight declaration has no continuation identity."
		var frame := ResolutionFrames.begin(working, "fight", action_id, "resume-empty-fight-choice")
		if frame.is_empty(): return "Could not resume the unengaged Fight continuation frame."
		empty_fight_frame_id = str(frame.frame_id)
	var result := UnitActions.apply(working, player, selected, point, roller)
	if not result.get("error", "").is_empty(): return result.error
	if result.get("resolve_nightforged_hazard", false):
		var hazard_message := str(result.get("message", ""))
		if not hazard_message.is_empty(): _event(working, hazard_message)
		if result.get("hazard_choice_complete", false):
			var hazard_error := _continue_nightforged_hazard(working, player, roller)
			if not hazard_error.is_empty(): return hazard_error
		state.clear()
		state.merge(working, true)
		return ""
	var remaining_unit_action := UnitActions.pending(working)
	var remaining_declaration: Variant = remaining_unit_action.get("declaration", {})
	if not attack_declaration_frame_id.is_empty() and not result.has("resume_declaration") and typeof(remaining_declaration) == TYPE_DICTIONARY and str(remaining_declaration.get("kind", "")) == "attack":
		var frame_error := ResolutionFrames.suspend(working, attack_declaration_frame_id, "attack-declaration-next-choice")
		if not frame_error.is_empty(): return frame_error
	if not empty_fight_frame_id.is_empty() and not result.has("resume_declaration") and typeof(remaining_declaration) == TYPE_DICTIONARY and str(remaining_declaration.get("kind", "")) == "empty-fight":
		var frame_error := ResolutionFrames.suspend(working, empty_fight_frame_id, "empty-fight-next-choice")
		if not frame_error.is_empty(): return frame_error
	if not movement_reaction_frame_id.is_empty():
		var movement_frame_error := ""
		if UnitActions.movement_reaction_squad(working) == movement_reaction_squad:
			movement_frame_error = _suspend_movement_frame(working, movement_reaction_squad, "movement-post-move-reaction")
		else:
			movement_frame_error = _complete_movement_frame(working, movement_reaction_squad)
		if not movement_frame_error.is_empty(): return movement_frame_error
	if Mission.enabled(working) and selected.action == "setup-done" and working.unit_abilities.get("setup_players", []).size() == 2:
		Mission.preview(working)
	if result.get("resume_fight", false):
		if str(result.get("resume_fight_step", "attacks")) == "consolidation_reaction": _resume_consolidation(working)
		else: _select_fighter(working, int(result.get("resume_cursor", working.active)))
	if result.has("resume_declaration"):
		var declaration: Dictionary = result.resume_declaration
		var reaction_message := str(result.get("message", ""))
		if not reaction_message.is_empty(): _event(working, reaction_message)
		if declaration.kind == "empty-fight":
			_finish_empty_fight(working, declaration.player, declaration.squad)
			if not empty_fight_frame_id.is_empty():
				var frame_error := ResolutionFrames.complete(working, empty_fight_frame_id)
				if not frame_error.is_empty(): return frame_error
		else:
			var resumed := _continue_attack_declaration(working, declaration, roller)
			if not resumed.error.is_empty():
				if not bool(declaration.get("point_blank_declined", false)): return resumed.error
				if not attack_declaration_frame_id.is_empty():
					var cancel_frame_error := ResolutionFrames.complete(working, attack_declaration_frame_id)
					if not cancel_frame_error.is_empty(): return cancel_frame_error
				_event(working, "Point-Blank Brutality declined; the selected attack was canceled because its profiles are not legal without the stratagem.")
		state.clear()
		state.merge(working, true)
		return ""
	if result.has("resume_mobile_declaration"):
		var mobile_declaration: Dictionary = result.resume_mobile_declaration
		if mobile_declaration.get("action", "") == "movement":
			var move_error := begin_movement(working, player, int(mobile_declaration.model), str(mobile_declaration.move_type), revision, roller, bool(mobile_declaration.get("use_sudden_onslaught", false)), true, bool(mobile_declaration.get("take_to_skies", false)))
			if not move_error.is_empty(): return move_error
			if selected.action == "detachment-stratagem":
				var mobile_source := "Knights of Iron" if selected.get("value", "") == DetachmentStratagems.KNIGHTS_OF_IRON else ("Flawless Riders" if selected.get("value", "") == DetachmentStratagems.FLAWLESS_RIDERS else ("Mobile Lethality" if selected.get("value", "") == DetachmentStratagems.MOBILE_LETHALITY else "Unstoppable Advance"))
				_event(working, "%s: %s resolved; continue the selected move." % [working.squads[int(mobile_declaration.squad)].name, mobile_source])
			else: _event(working, str(result.get("message", "The Mobile stratagem was declined.")))
		elif mobile_declaration.get("action", "") == "charge":
			var charge_result := declare_charge(working, player, int(mobile_declaration.model), revision, roller, true, bool(mobile_declaration.get("take_to_skies", false)), float(mobile_declaration.get("take_to_skies_penalty", -1.0)))
			if not charge_result.get("error", "").is_empty(): return charge_result.error
			if selected.action == "detachment-stratagem":
				var mobile_source := "Knights of Iron" if selected.get("value", "") == DetachmentStratagems.KNIGHTS_OF_IRON else ("Flawless Riders" if selected.get("value", "") == DetachmentStratagems.FLAWLESS_RIDERS else ("Mobile Lethality" if selected.get("value", "") == DetachmentStratagems.MOBILE_LETHALITY else "Unstoppable Advance"))
				_event(working, "%s: %s resolved; %s" % [working.squads[int(mobile_declaration.squad)].name, mobile_source, str(charge_result.get("message", "charge roll resolved."))])
			else: _event(working, str(charge_result.get("message", result.get("message", "The Mobile stratagem was declined."))))
		else: return "The Mobile stratagem prompt has no valid movement or charge declaration to resume."
		state.clear()
		state.merge(working, true)
		return ""
	if result.get("resume_charge", false):
		var pending_charge: Dictionary = working.get("pending_charge", {})
		var charge_squad := int(pending_charge.get("squad", -1))
		var charge_frame_id := str(result.get("charge_frame_id", ""))
		var charge_frame := ResolutionFrames.current(working)
		if charge_squad < 0 or charge_frame_id.is_empty() or str(charge_frame.get("frame_id", "")) != charge_frame_id or str(charge_frame.get("kind", "")) != "unit-action" or str(charge_frame.get("status", "")) != "suspended" or str(charge_frame.get("action_id", "")) != _charge_action_id(working, charge_squad):
			return "The saved Charge continuation for this reaction is missing."
		if _begin_charge_frame(working, charge_squad, "charge-target-selection").is_empty(): return "Could not resume the saved Charge target selection."
	if result.get("resume_attack", false):
		var attack_action_id := _attack_resolution_action_id(working)
		var attack_frame_error := _resume_attack_resolution_frame(working, "attack-unit-ability")
		if not attack_frame_error.is_empty(): return attack_frame_error
		var resumed := Allocation.pump(working, roller)
		if not resumed.error.is_empty(): return resumed.error
		if resumed.complete:
			var finished := _finish_pending_attack(working, roller)
			if not finished.error.is_empty(): return finished.error
		else:
			attack_frame_error = _suspend_attack_resolution_frame(working, attack_action_id, "attack-unit-ability")
			if not attack_frame_error.is_empty(): return attack_frame_error
			_event(working, selected.label)
	else: _event(working, str(result.get("message", selected.label)))
	if not post_attack_frame_id.is_empty():
		var post_attack_frame_error := _complete_attack_resolution_frame(working, post_attack_action_id)
		if not post_attack_frame_error.is_empty(): return post_attack_frame_error
	var charge_frame_error := _settle_charge_frame_after_reaction(working)
	if not charge_frame_error.is_empty(): return charge_frame_error
	if result.get("advance", false) or (was_reanimation and reanimation_kind_before_choice != "undying" and Reanimation.pending(working).is_empty() and UnitActions.pending(working).is_empty()):
		var error := advance_phase(working, working.active, working.revision, roller)
		if not error.is_empty(): return error
	if not phase_start_frame_id.is_empty(): _settle_phase_start_frame(working)
	if not fight_counter_frame_id.is_empty(): _settle_counteroffensive_frame(working)
	state.clear()
	state.merge(working, true)
	return ""

static func _resolve_current_end_control(state: Dictionary) -> void:
	PhaseResolution._resolve_current_end_control(state)

extends RefCounted
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Reivers = preload("res://scripts/edition_11/reivers.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Restricted integration exercise, not a complete official 11e match.
## Individual movement, optional varied training equipment and defender allocation.

const Pack = preload("res://scripts/data_pack.gd")
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
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Hazard = preload("res://scripts/edition_11/hazardous.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const PurgationRun = preload("res://scripts/edition_11/purgation_run.gd")
const VictrixHonourGuard = preload("res://scripts/edition_11/victrix_honour_guard.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const PACK_ID := "11e-3d-integration-v28-kor-sarro-khan"
const DIRECTORY := "res://data/imported/starter-11e-v1"
const PHASES := ["start_turn", "command", "movement", "shooting", "charge", "fight", "end_turn"]
const DISABLED := "Unlisted unit/faction abilities, official missions, stratagems, official mission actions, upper floors and exact imported-mesh visibility are not implemented. Unproved approach exceptions remain restricted."

static func initial_state(terrain_id: String = Terrain.DEFAULT_LAYOUT, mission_id: String = "elimination", squads_per_side: int = 1, manual_allocation: bool = false, varied_equipment: bool = false) -> Dictionary:
	if squads_per_side not in [1, 2]: return {"error": "Supported exercise size is one or two squads per player."}
	var terrain := Terrain.layout(terrain_id)
	if terrain.has("error"): return terrain
	var mission := Objectives.setup(terrain, mission_id)
	if mission.has("error"): return mission
	var squads: Dictionary = {}
	var units: Dictionary = {}
	var hashes := PACK_ID + var_to_str(terrain) + var_to_str(mission) + str(squads_per_side) + str(manual_allocation) + str(varied_equipment)
	for side in [1, 2]:
		var faction := "adeptus-astartes" if side == 1 else "necrons"
		var pack: Dictionary = Pack.load_pack(DIRECTORY.path_join(faction))
		if not pack.error.is_empty(): return {"error": "Import starter data first: " + pack.error}
		hashes += pack.manifest.units_sha256
		var definition: Dictionary = {}
		var wanted := "intercessor-squad" if side == 1 else "necron-warriors"
		for record: Dictionary in pack.units:
			if record.source_id == wanted: definition = record
		if definition.is_empty() or not definition.get("base") is Dictionary:
			return {"error": "Missing selected datasheet or base geometry: " + wanted}
		var gun_name := "bolt-rifle-intercessor-squad" if side == 1 else "gauss-flayer"
		var gun := _weapon(definition, gun_name, "Saturation" if side == 1 else "Gauss flayer")
		if gun.is_empty(): return {"error": "Missing fixed loadout: " + gun_name}
		var blade := _weapon(definition, "close-combat-weapon-intercessor-squad" if side == 1 else "close-combat-weapon", "Knives and Fists" if side == 1 else "Close combat weapon")
		if blade.is_empty(): return {"error": "Missing fixed melee loadout."}
		var stats: Dictionary = definition.stats
		for key in ["movement_inches", "toughness", "save_target", "wounds", "leadership_target", "objective_control"]:
			if not Attacks._positive_integer(stats.get(key)): return {"error": "Unresolved stat: " + key}
		var count := 5 if side == 1 else 10
		squads[side] = {"owner": side, "name": definition.name, "faction": definition.faction,
			"starting_strength": count, "battle_shocked": false,
			"move_type": "unselected", "advanced": false, "fell_back": false, "normal_moved_this_turn": false,
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
	if Mission.actor(state) > 0: return Mission.actor(state)
	if Awakened.needs_setup(state): return Awakened.setup_actor(state)
	if not Reanimation.pending(state).is_empty(): return int(Reanimation.pending(state).player)
	if Doctrines.needs_choice(state): return int(state.active)
	if UnitActions.actor(state) > 0: return UnitActions.actor(state)
	if state.get("phase", "") == "deployment": return Deployment.actor(state)
	if DetachmentStratagems.vengeful_actor(state) > 0: return DetachmentStratagems.vengeful_actor(state)
	if not Stratagems.pending(state).is_empty(): return int(Stratagems.pending(state).player)
	if CoreReactions.actor(state) > 0: return CoreReactions.actor(state)
	if not state.get("pending_hazard", {}).is_empty(): return int(state.pending_hazard.player)
	if not state.get("pending_attack", {}).is_empty():
		if state.pending_attack.current.get("phase", "") == "precision": return int(state.pending_attack.player)
		return int(state.squads[state.pending_attack.current.target].owner)
	if state.phase == "end_turn":
		var squad := incoherent_squad(state)
		if squad != -1: return int(state.squads[squad].owner)
	return int(state.fight_actor) if state.phase == "fight" else int(state.active)

static func living_owner(state: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	for id: int in state.units:
		if state.units[id].owner == player and state.units[id].wounds > 0: result.append(id)
	return result

static func incoherent_squad(state: Dictionary) -> int:
	# Resolve the turn owner's choices first, then the opponent's.
	for owner in [state.active, 3 - int(state.active)]:
		for squad: int in state.squads:
			if state.squads[squad].owner == owner and not Contact.coherent(state, squad): return squad
	return -1

static func remove_for_coherency(state: Dictionary, player: int, model: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "end_turn": return "Coherency removals happen at End of Turn."
	var squad := incoherent_squad(state)
	if squad == -1: return "All squads are coherent."
	if not state.units.has(model) or state.units[model].wounds <= 0 or state.units[model].squad != squad:
		return "Select a living model in your incoherent squad."
	# No destroyed-model ability triggers are generated by this removal.
	state.units[model].wounds = 0
	_event(state, "Player %d removed model %d to restore coherency." % [player, model])
	return ""

static func _command_error(state: Dictionary, player: int, expected_revision: int) -> String:
	if Awakened.needs_setup(state): return "Finish Overlord attachment declarations before deployment."
	if UnitActions.actor(state) > 0: return "Resolve or decline the pending unit ability choices first."
	if Mission.actor(state) > 0: return "Resolve the mission preparation choice first."
	if Doctrines.needs_choice(state): return "Choose a Combat Doctrine or no doctrine before continuing Command."
	if not Reanimation.pending(state).is_empty(): return "Finish Reanimation Protocols before continuing."
	if OathOfMoment.needs_choice(state): return "Select the Oath of Moment target before continuing the Command phase."
	if state.get("phase", "") in ["deployment", "army_selection"]: return "Finish army selection and deployment before playing the first turn."
	if not Stratagems.pending(state).is_empty(): return "Resolve the pending decision before continuing."
	if not state.get("pending_hazard", {}).is_empty(): return "Finish Hazardous mortal-wound allocation first."
	if not state.get("pending_attack", {}).is_empty(): return "The defender must finish damage allocation first."
	if state.test_winner != 0: return "Exercise finished. Start a new local exercise to reset."
	if player != actor(state): return "Wait for your action window."
	if expected_revision != state.revision: return "State changed; try again after synchronization."
	return ""

static func _event(state: Dictionary, message: String) -> void:
	Actions.reconcile(state)
	UnitActions.reconcile(state)
	state.revision += 1
	state.events.append({"revision": state.revision, "message": message})
	if state.events.size() > 30: state.events.pop_front()

static func advance_phase(state: Dictionary, player: int, revision: int, roller: Callable = Callable(), selected_squad: int = -1) -> String:
	if not UnitAbilities.Detection.selection(state).is_empty(): return "Finish the selected Eliminator shooting or cancel its selection first."
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if not state.pending_contact.is_empty(): return "Confirm or cancel the pending contact movement first."
	if not state.pending_move.is_empty(): return "Confirm or cancel the squad's movement before advancing."
	if state.phase == "charge" and not state.pending_charge.is_empty(): return "Resolve or decline the rolled charge before advancing."
	if CoreReactions.actor(state) > 0: return "Resolve Fire Overwatch shooting or the Heroic Intervention charge first."
	if state.phase == "fight" and state.fight_step != "complete": return _advance_fight(state, player, false, selected_squad)
	if state.phase == "end_turn" and incoherent_squad(state) != -1:
		return "The controlling player must select coherency casualties before ending the turn."
	if state.phase == "start_turn": UnitActions.start_round(state)
	if state.phase == "command":
		if UnitActions.offer_command_healing(state):
			_event(state, "Resolve unit healing before finishing Command.")
			return ""
		error = Reanimation.phase_error(state)
		if not error.is_empty(): return error
		if not Reanimation.morale_done(state):
			if Stratagems.open_command(state):
				_event(state, "Battle-shock: choose a unit to roll the test or use Insane Bravery before rolling.")
				return ""
			if not state.has("stratagems"):
				var morale: Dictionary = Morale.resolve_command(state, roller)
				if not morale.error.is_empty(): return morale.error
				state.last_morale = morale.results
				for result: Dictionary in morale.results:
					state.squads[result.squad].battle_shocked = not result.passed
					state.events.append({"revision": state.revision + 1, "message": "%s battle-shock: %s vs %d — %s." % [state.squads[result.squad].name, str(result.rolls), result.target, "passed" if result.passed else "battle-shocked"]})
		_resolve_current_end_control(state)
		if Reanimation.open_end_command(state):
			_event(state, "End of Command: resolve each Necron unit's Reanimation Protocols.")
			return ""
	_resolve_current_end_control(state)
	if UnitActions.open_end(state):
		_event(state, "End of phase: resolve or decline optional unit abilities.")
		return ""
	# Command morale resolves before end-of-phase control. Draft placements never capture.
	if not UnitAbilities.enabled(state) and state.phase in ["command", "movement", "shooting", "charge", "fight"]:
		Objectives.resolve_control(state)
	var ability_note := ObjectiveSecured.end_command(state)
	if state.phase == "command":
		for healed: Dictionary in MarineEnhancements.ironstorm_command_healing(state, state.active):
			_event(state, "Redoubtable Machine Spirit restores 1 wound to %s." % str(state.squads[healed.squad].get("name", "Vehicle")))
	if Mission.enabled(state):
		if Mission.score(state):
			_event(state, Mission.summary(state))
			return ""
	if state.phase == "end_turn" and state.active != state.get("first_player", 1):
		var scoring := Objectives.score_round(state)
		if not scoring.is_empty():
			if state.test_winner != 0:
				_event(state, scoring)
				return ""
			state.events.append({"revision": state.revision + 1, "message": scoring})
	var next: int = PHASES.find(state.phase) + 1
	if next == PHASES.size():
		state.active = 3 - state.active
		state.turn += 1
		if state.active == state.get("first_player", 1): state.round += 1
		state.phase = PHASES[0]
		for squad: int in state.squads:
			state.squads[squad].set_up_this_turn = false
			state.squads[squad].moved = false
			state.squads[squad].shot = false
			state.squads[squad].moved_distance = 0.0
			state.squads[squad].charge_declared = false
			state.squads[squad].charged = false
			state.squads[squad].move_type = "unselected"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = false
			state.squads[squad].normal_moved_this_turn = false
		for id: int in state.units: state.units[id].moved = false
	else:
		if state.phase == "fight": DetachmentStratagems.remove_lingering(state)
		if state.phase == "movement":
			_resolve_vanguard_ambushers(state)
			for squad: int in state.squads:
				if state.squads[squad].owner == state.active and not state.squads[squad].moved:
					state.squads[squad].move_type = "stationary"
					state.squads[squad].moved = true
		state.phase = PHASES[next]
	if state.phase == "charge" and state.has("core_reactions"):
		state.core_reactions.chargers = []
		state.core_reactions.charge_closed = false
		state.core_reactions.heroic = {}
	if state.phase == "command":
		UnitAbilities.start_command(state)
		Doctrines.start_command(state)
		OathOfMoment.start_command(state)
		Reanimation.start_command(state)
		if Doctrines.needs_choice(state):
			state.combat_doctrines.cp_pending_turn = state.turn
		else:
			state.cp[1] += 1
			state.cp[2] += 1
	if state.phase == "fight": _begin_fight(state)
	if state.phase == "end_turn": Actions.complete_end_turn(state)
	_event(state, "Player %d: %s" % [state.active, state.phase] + (" • " + ability_note if not ability_note.is_empty() else ""))
	if state.phase == "fight" and Reivers.begin_fight(state): _event(state, "Fearsome Assault: resolve the required Battle-shock tests before the Fight sequence.")
	return ""

static func _resolve_vanguard_ambushers(state: Dictionary) -> void:
	if str(state.get("combat_doctrines", {}).get("detachment", "")) != "phobos-shock-force": return
	if not state.combat_doctrines.has("vanguard_ambushers"): state.combat_doctrines.vanguard_ambushers = {}
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != int(state.active): continue
		if not UnitAbilities.has_target_keyword(state, squad, "PHOBOS"): continue
		var alive := Contact.alive(state, squad)
		if alive.is_empty(): continue
		var is_hidden := true
		for model: int in alive:
			if not Terrain.hidden(state, model): is_hidden = false
		if is_hidden: state.combat_doctrines.vanguard_ambushers[squad] = int(state.turn)

static func select_oath_target(state: Dictionary, player: int, target: int, revision: int) -> String:
	var error := OathOfMoment.choice_error(state, player, target, revision)
	if not error.is_empty(): return error
	OathOfMoment.select_target(state, player, target)
	_event(state, "Player %d: Oath of Moment targets %s (June 2026 rules profile)." % [player, state.squads[target].name])
	return ""

static func resolve_command_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	if Stratagems.pending(state).get("kind") != "before_battle_shock": return "There is no pending Battle-shock decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
	var profile := Morale.leadership(state, squad)
	if not profile.error.is_empty(): return profile.error
	var result: Dictionary
	if stratagem.is_empty():
		result = Morale.roll_battle_shock(state, squad, roller)
		if not result.error.is_empty(): return result.error
	else:
		result = {"error": "", "squad": squad, "rolls": [], "target": profile.target, "passed": true, "automatic": true, "stratagem": stratagem}
	var working := state.duplicate(true)
	if not stratagem.is_empty(): Stratagems.consume(working, player, squad, stratagem)
	working.squads[squad].battle_shocked = not result.passed
	var window: Dictionary = working.stratagems.pending
	window.remaining.erase(squad)
	window.results.append(result)
	working.last_morale = window.results.duplicate(true)
	_event(working, "%s: Insane Bravery • 1 CP • Battle-shock aprovado automaticamente." % working.squads[squad].name if not stratagem.is_empty() else "%s battle-shock: %s vs %d — %s." % [working.squads[squad].name, str(result.rolls), result.target, "passed" if result.passed else "battle-shocked"])
	if window.remaining.is_empty():
		working.stratagems.pending = {}
		working.stratagems.command_done_turn = working.turn
		error = advance_phase(working, player, working.revision, roller)
		if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func _edge_distance(first: Dictionary, second: Dictionary) -> float:
	return maxf(0.0, first.position.distance_to(second.position) - float(first.radius) - float(second.radius))

static func _engaged(state: Dictionary, squad: int) -> bool:
	for id: int in living(state, squad):
		for enemy: int in state.units:
			if state.units[enemy].owner == state.units[id].owner or state.units[enemy].wounds <= 0: continue
			if _edge_distance(state.units[id], state.units[enemy]) <= 2.0: return true
	return false

static func movement_remaining(state: Dictionary, id: int) -> float:
	if not state.units.has(id): return 0.0
	var unit: Dictionary = state.units[id]
	if unit.wounds <= 0 or state.squads[unit.squad].moved: return 0.0
	var spent := 0.0
	var bonus := 0.0
	if not state.pending_move.is_empty() and state.pending_move.squad == unit.squad:
		spent = float(state.pending_move.spent.get(id, 0.0))
		bonus = float(state.pending_move.get("bonus", 0))
	var characteristic_bonus := 0.0 if DetachmentStratagems.might_ignore_active(state, int(unit.squad)) else Doctrines.movement_bonus(state, int(unit.squad))
	return maxf(0.0, float(unit.movement) + bonus + characteristic_bonus - spent)

static func movement_choice_error(state: Dictionary, player: int, model: int, move_type: String, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
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

static func _movement_draft(state: Dictionary, squad: int, move_type: String) -> Dictionary:
	var origins: Dictionary = {}
	var prior_flags: Dictionary = {}
	for member: int in living(state, squad):
		origins[member] = state.units[member].position
		prior_flags[member] = state.units[member].moved
	return {"squad": squad, "move_type": move_type, "origins": origins, "prior_flags": prior_flags, "spent": {}, "bonus": 0, "hazard_remaining": 0, "hazard_rolls": [], "locked": move_type != "normal"}

static func begin_movement(state: Dictionary, player: int, model: int, move_type: String, revision: int, roller: Callable = Callable(), use_sudden_onslaught: bool = false, unstoppable_resolved: bool = false) -> String:
	var error := movement_choice_error(state, player, model, move_type, revision)
	if not error.is_empty(): return error
	var squad: int = state.units[model].squad
	var mobile_choice_available := not unstoppable_resolved and move_type != "stationary" and not use_sudden_onslaught and (DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.UNSTOPPABLE_ADVANCE) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.FLAWLESS_RIDERS) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.MOBILE_LETHALITY, move_type))
	if mobile_choice_available:
		state.unit_abilities.window = {"kind": DetachmentStratagems.UNSTOPPABLE_WINDOW, "owners": [player], "squad": squad, "trigger": "movement", "action": "movement", "model": model, "move_type": move_type, "use_sudden_onslaught": false}
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
	var draft := _movement_draft(state, squad, move_type)
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
				var roll := dice.d6()
				draft.hazard_rolls.append(roll)
				if roll <= 2: draft.hazard_remaining += 1
		if not dice.error.is_empty(): return dice.error
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
			_event(state, "%s: Advance D6 = %d. Accept%s before moving." % [state.squads[squad].name, draft.bonus, ", re-roll with Sudden Storm" if state.stratagems.pending.get("sudden", false) else " or use Command Re-roll"])
			return ""
		draft.raw_bonus = draft.bonus
		var advance_modifier := UnitAbilities.advance_modifier(state, squad) + Doctrines.advance_bonus(state, squad)
		draft.bonus = (6 if draft.get("veil_of_time_to_six", false) else draft.raw_bonus) + advance_modifier
	state.pending_move = draft
	if UnitAbilities.enabled(state): UnitActions.Techmarine.open_for_move(state, squad, "start")
	if move_type == "desperate_escape" and state.get("stratagems", {}).get("escape_rerolls", false):
		# New capability uses the shared hazard rule, including all-heavy units.
		# Keep the disabled historical exercise and its hashes unchanged.
		state.pending_move.hazard_remaining = Hazard.from_rolls(state, squad, draft.hazard_rolls).total
		if Stratagems.eligibility_error(state, player, squad, "command-re-roll").is_empty():
			var indices: Array[int] = []
			for index in range(draft.hazard_rolls.size()): indices.append(index)
			state.stratagems.pending = {"kind": "after_escape_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": draft.hazard_rolls.duplicate(), "eligible": indices}
			_event(state, "%s: Desperate Escape hazards %s. Accept or replace one D6 before allocation and movement." % [state.squads[squad].name, str(draft.hazard_rolls)])
			return ""
	var message := "%s selected %s." % [state.squads[squad].name, move_type.replace("_", " ")]
	if move_type == "advance": message += " Advance %s: %d inches." % ["roll: 6 (Sudden Onslaught, 1 CP)" if use_sudden_onslaught else "roll", draft.bonus]
	if move_type == "desperate_escape": message += " Hazard rolls: %s; allocate %d mortal wounds before moving." % [str(draft.hazard_rolls), state.pending_move.hazard_remaining]
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
	working.last_command_roll = {"kind": window.kind, "squad": squad, "original_rolls": window.rolls.duplicate(), "rolls": rolls.duplicate(), "rerolled": not stratagem.is_empty(), "die": die, "mortal_wounds": hazard.total}
	_event(working, "%s: final Desperate Escape hazards %s; %d mortal wounds before movement.%s" % [working.squads[squad].name, str(rolls), hazard.total, " Command Re-roll: 1 CP." if not stratagem.is_empty() else " Result accepted."])
	state.clear()
	state.merge(working, true)
	return ""

static func abandon_fall_back(state: Dictionary, player: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "movement" or state.pending_move.get("move_type", "") not in ["ordered_retreat", "desperate_escape"]:
		return "No Fall Back placement to abandon."
	if state.pending_move.hazard_remaining > 0: return "Resolve all escape mortal wounds first."
	var squad: int = state.pending_move.squad
	for id: int in state.pending_move.origins:
		state.units[id].position = state.pending_move.origins[id]
		state.units[id].moved = state.pending_move.prior_flags[id]
	# A move that fails its final conditions is not made (§03.01). The unit
	# has still been selected this phase; it cannot choose another move.
	state.squads[squad].moved = true
	state.squads[squad].move_type = "failed_fall_back"
	state.pending_move = {}
	_event(state, "Fall Back not completed; original positions restored and escape casualties retained. This squad cannot move again this phase.")
	return ""

static func allocate_escape_wound(state: Dictionary, player: int, model: int, revision: int, roller: Callable = Callable()) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "movement" or state.pending_move.is_empty() or state.pending_move.get("hazard_remaining", 0) <= 0:
		return "No pending escape mortal wounds."
	var squad: int = state.pending_move.squad
	if not state.units.has(model) or state.units[model].squad != squad or state.units[model].wounds <= 0:
		return "Choose a living model in the escaping squad."
	for member: int in living(state, squad):
		if state.units[member].wounds < state.units[member].max_wounds and member != model:
			return "Allocate to the already wounded model first."
	var prevention := Attacks.Prevention.resolve(1, state.units[model].wounds, UnitPrevention.rules(state, model), "mortal", roller)
	if not prevention.error.is_empty(): return prevention.error
	state.units[model].wounds -= prevention.lost
	state.last_escape_prevention = prevention
	state.pending_move.hazard_remaining -= 1
	if living(state, squad).is_empty():
		state.pending_move = {}
		if not Objectives.training(state) and not Mission.enabled(state) and living_owner(state, player).is_empty(): state.test_winner = 3 - player
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

static func validate_move(state: Dictionary, player: int, id: int, destination: Vector2, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "movement": return "Moves are allowed only in the Movement phase."
	if not state.units.has(id) or state.units[id].wounds <= 0: return "Select a living miniature."
	var unit: Dictionary = state.units[id]
	if not unit.get("on_battlefield", true): return "Reserved models must arrive with an ingress move."
	if unit.owner != player: return "You cannot move an opponent's miniature."
	if state.squads[unit.squad].moved: return "This squad has already resolved its move."
	if not state.pending_move.is_empty() and state.pending_move.squad != unit.squad: return "Finish the active squad's movement first."
	if not destination.is_finite(): return "Invalid destination."
	if state.pending_move.get("hazard_remaining", 0) > 0: return "Allocate escape mortal wounds before moving."
	if state.pending_move.is_empty() and _engaged(state, unit.squad): return "An engaged squad cannot make a normal move."
	var distance: float = unit.position.distance_to(destination)
	if distance <= 0.001: return "Choose a different destination."
	var remaining := movement_remaining(state, id)
	if distance > remaining + 0.001: return "This model has %.2f inches of movement remaining." % remaining
	var through_enemies: bool = state.pending_move.get("move_type", "normal") == "desperate_escape"
	if not Contact.clear_path(state, id, destination, remaining, through_enemies): return "The base cannot cross terrain, a blocking enemy base, or the board edge."
	for other: int in state.units:
		if other == id or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		if destination.distance_to(state.units[other].position) < float(unit.radius) + float(state.units[other].radius) - 0.001:
			return "Bases cannot overlap at the destination."
	# Engagement is checked after the entire unit move, not along its path.
	return ""

static func move(state: Dictionary, player: int, id: int, destination: Vector2, revision: int) -> String:
	var error := validate_move(state, player, id, destination, revision)
	if not error.is_empty(): return error
	var squad: int = state.units[id].squad
	if state.pending_move.is_empty():
		state.pending_move = _movement_draft(state, squad, "normal")
	var distance: float = state.units[id].position.distance_to(destination)
	state.pending_move.spent[id] = float(state.pending_move.spent.get(id, 0.0)) + distance
	state.units[id].position = destination
	state.units[id].moved = true
	_event(state, "Model %d: staged %.2f inches; %.2f remaining. Confirm squad when ready." % [id, distance, movement_remaining(state, id)])
	return ""

static func finish_movement(state: Dictionary, player: int, revision: int, cancel: bool = false, roller: Callable = Callable()) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "movement" or state.pending_move.is_empty(): return "No pending squad movement."
	var squad: int = state.pending_move.squad
	if cancel:
		for id: int in state.pending_move.origins:
			state.units[id].position = state.pending_move.origins[id]
			state.units[id].moved = state.pending_move.prior_flags[id]
		if state.pending_move.get("locked", false):
			state.pending_move.spent = {}
			_event(state, "Placement reset; selected move, dice and casualties are retained.")
		else:
			state.pending_move = {}
			_event(state, "Pending squad movement cancelled; original positions restored.")
		return ""
	if state.pending_move.get("hazard_remaining", 0) > 0: return "Allocate escape mortal wounds before confirming."
	if not Contact.coherent(state, squad): return "Squad is not in coherency. Reposition its models or cancel movement."
	if _engaged(state, squad): return "The move must end unengaged. Reposition its models or reset placement."
	var move_type: String = state.pending_move.get("move_type", "normal")
	if move_type == "desperate_escape" and not state.squads[squad].battle_shocked:
		var result := Morale.roll_battle_shock(state, squad, roller)
		if not result.error.is_empty(): return result.error
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
	if move_type == "normal": state.squads[squad].normal_moved_this_turn = true
	state.pending_move = {}
	UnitActions.end_move(state, squad)
	_event(state, "%s movement confirmed; longest model path %.2f inches." % [state.squads[squad].name, longest])
	return ""

static func charge_declaration_error(state: Dictionary, player: int, model: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
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

static func declare_charge(state: Dictionary, player: int, model: int, revision: int, roller: Callable, unstoppable_resolved: bool = false) -> Dictionary:
	var error := charge_declaration_error(state, player, model, revision)
	if not error.is_empty(): return {"error": error}
	var squad: int = state.units[model].squad
	var mobile_choice_available := not unstoppable_resolved and (DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.UNSTOPPABLE_ADVANCE) or DetachmentStratagems.mobile_declaration_available(state, player, squad, DetachmentStratagems.FLAWLESS_RIDERS))
	if mobile_choice_available:
		state.unit_abilities.window = {"kind": DetachmentStratagems.UNSTOPPABLE_WINDOW, "owners": [player], "squad": squad, "trigger": "charge", "action": "charge", "model": model}
		_event(state, "%s declares a charge. Choose an available charge stratagem or decline it before rolling." % state.squads[squad].name)
		return {"error": "", "message": "Choose an available charge stratagem or decline before rolling the charge."}
	if not roller.is_valid(): return {"error": "Missing host dice provider."}
	var dice := Attacks.Dice.new(roller)
	var rolls := [dice.d6(), dice.d6()]
	if not dice.error.is_empty(): return {"error": dice.error}
	var maximum: int = rolls[0] + rolls[1]
	state.squads[squad].charge_declared = true
	if player == state.active: CoreReactions.record_charger(state, squad)
	var opened := Stratagems.open_roll(state, player, squad, "after_charge_roll", rolls)
	if state.has("stratagems") and UnitAbilities.has(state, squad, "unstoppable-valour"):
		if not opened: state.stratagems.pending = {"kind": "after_charge_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": rolls.duplicate(), "draft": {}}
		state.stratagems.pending.valour = true
		opened = true
	if state.has("stratagems") and UnitAbilities.master_shadows_active(state, squad):
		if not opened: state.stratagems.pending = {"kind": "after_charge_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": rolls.duplicate(), "draft": {}}
		state.stratagems.pending.master_shadows = true
		opened = true
	if opened:
		var reroll_source := " with Unstoppable Valour, 0 CP" if state.stratagems.pending.get("valour", false) else (" with Master of Shadows, 0 CP" if state.stratagems.pending.get("master_shadows", false) else " with Command Re-roll")
		var notice := "%s: Charge %s = %d. Accept or re-roll both dice%s." % [state.squads[squad].name, str(rolls), maximum, reroll_source]
		_event(state, notice)
		return {"error": "", "message": notice}
	return _accept_charge_roll(state, squad, rolls)

static func _accept_charge_roll(state: Dictionary, squad: int, rolls: Array) -> Dictionary:
	var raw_total: int = rolls[0] + rolls[1]
	var modifier := UnitAbilities.charge_modifier(state, squad) + Doctrines.charge_bonus(state, squad)
	var maximum: int = CoreReactions.cap_charge(state, squad, raw_total + modifier)
	var nearest := INF
	for enemy: int in ContactActions.enemies(state, squad):
		for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	var message := "%s charge roll: %s = %d%s inches. Choose a target now." % [state.squads[squad].name, str(rolls), raw_total, " + %d" % modifier if modifier > 0 else ""]
	if maximum < nearest:
		message = "%s charge failed: %s = %d, no target within the rolled distance." % [state.squads[squad].name, str(rolls), maximum]
		var failed_heroic := CoreReactions.heroic_charger(state, state.squads[squad].owner, squad)
		if failed_heroic:
			CoreReactions.clear_heroic(state)
			CoreReactions.reopen_heroic_choices(state)
	else:
		state.pending_charge = {"squad": squad, "maximum": maximum, "rolls": rolls, "targets": []}
	_event(state, message)
	return {"error": "", "message": message}

static func resolve_roll_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	var window := Stratagems.pending(state)
	if window.get("kind") not in ["after_advance_roll", "after_charge_roll"]: return "No Advance or Charge roll is waiting for a decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in ["", "command-re-roll", "sudden-storm", "unstoppable-valour", "master-shadows", "supercharged-engines", "honour-of-vigilance", "wrath-of-the-chapter", "stormseers-wisdom"]: return "Stratagem unavailable for this roll."
	if stratagem == "unstoppable-valour" and (window.kind != "after_charge_roll" or not window.get("valour", false) or not UnitAbilities.has(state, squad, "unstoppable-valour")): return "Unstoppable Valour is not available for this charge."
	if stratagem == "master-shadows" and (window.kind != "after_charge_roll" or not window.get("master_shadows", false)): return "Master of Shadows is not available for this charge."
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
		working.pending_move.raw_bonus = rolls[0]
		var advance_modifier := UnitAbilities.advance_modifier(working, squad) + Doctrines.advance_bonus(working, squad)
		working.pending_move.bonus = (6 if working.pending_move.get("veil_of_time_to_six", false) else rolls[0]) + advance_modifier
		if UnitAbilities.enabled(working): UnitActions.Techmarine.open_for_move(working, squad, "start")
		var source_label := "Supercharged Engines re-roll, 0 CP" if stratagem == "supercharged-engines" else ("Stormseer's Wisdom re-roll, 0 CP" if stratagem == "stormseers-wisdom" else ("Honour of Vigilance re-roll, 0 CP" if stratagem == "honour-of-vigilance" else ("Wrath of the Chapter re-roll, 0 CP" if stratagem == "wrath-of-the-chapter" else ("Sudden Storm re-roll" if stratagem == "sudden-storm" else ("Command Re-roll, 1 CP" if stratagem == "command-re-roll" else "result accepted")))))
		_event(working, "%s: final Advance %s = %d%s inches%s. Movement can begin." % [working.squads[squad].name, str(rolls), working.pending_move.bonus, " (+%d modifier)" % advance_modifier if advance_modifier > 0 else "", " • " + source_label])
	else:
		var result := _accept_charge_roll(working, squad, rolls)
		if not result.error.is_empty(): return result.error
		if not stratagem.is_empty(): working.events[-1].message += " %s: %s → %s." % ["Unstoppable Valour, 0 CP" if stratagem == "unstoppable-valour" else ("Master of Shadows, 0 CP" if stratagem == "master-shadows" else "Command Re-roll, 1 CP"), str(window.rolls), str(rolls)]
	state.clear()
	state.merge(working, true)
	return ""

static func decline_charge(state: Dictionary, player: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
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
	_event(state, "Charge resolved without moving; it cannot be rolled again this phase.")
	return ""

static func charge_target_error(state: Dictionary, player: int, target: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "charge" or state.pending_charge.is_empty(): return "Roll the charge before choosing its target."
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == TransportRules.COMBAT_EMBARKATION_WINDOW: return "Resolve Repulsor Combat Embarkation before changing charge targets."
	if not state.pending_contact.is_empty(): return "Cancel charge placement before changing targets."
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
	var enemy: int = state.units[target].squad
	if not state.pending_charge.has("targets"): state.pending_charge.targets = []
	if enemy in state.pending_charge.targets: state.pending_charge.targets.erase(enemy)
	else: state.pending_charge.targets.append(enemy)
	var names: Array[String] = []
	for target_squad: int in state.pending_charge.targets: names.append(state.squads[target_squad].name)
	var message := "Charge targets: %s. Begin placement when ready." % (", ".join(names) if not names.is_empty() else "none")
	_event(state, message)
	return {"error": "", "message": message}

static func begin_contact_move(state: Dictionary, player: int, model: int, kind: String, revision: int, chosen_targets: Array[int] = [], objective_index: int = -1) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if not state.pending_contact.is_empty(): return "Finish the pending contact move first."
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player: return "Select a living model in your squad."
	var squad: int = state.units[model].squad
	var targets: Array[int] = []
	var maximum := 3.0
	if kind == "charge":
		if state.phase != "charge" or state.pending_charge.is_empty() or state.pending_charge.squad != squad: return "Roll this squad's charge first."
		if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == TransportRules.COMBAT_EMBARKATION_WINDOW: return "Resolve Repulsor Combat Embarkation before beginning charge placement."
		for target: int in state.pending_charge.get("targets", []): targets.append(target)
		maximum = float(state.pending_charge.maximum)
		if TransportRules.begin_combat_embarkation_reaction(state, squad):
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
	state.pending_contact = ContactActions.draft(state, squad, kind, targets, maximum)
	if kind == "consolidate_objective": state.pending_contact.objective = objective_index
	_event(state, "%s: begin %s; %.0f inches per model." % [state.squads[squad].name, kind.replace("_", " "), maximum])
	return ""

static func stage_contact_move(state: Dictionary, player: int, model: int, destination: Vector2, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	error = ContactActions.validate_segment(state, model, destination)
	if not error.is_empty(): return error
	state.pending_contact.spent[model] = float(state.pending_contact.spent.get(model, 0.0)) + state.units[model].position.distance_to(destination)
	state.units[model].position = destination
	_event(state, "Model %d contact placement: %.2f inches remaining." % [model, ContactActions.remaining(state, model)])
	return ""

static func finish_contact_move(state: Dictionary, player: int, revision: int, cancel: bool = false) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.pending_contact.is_empty(): return "No pending contact movement."
	if cancel:
		ContactActions.restore(state)
		state.pending_contact = {}
		_event(state, "Contact placement cancelled; positions restored and charge dice retained.")
		return ""
	var validation := ContactActions.final_validation(state)
	error = validation.error
	if not error.is_empty(): return error
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
	return ""

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
	if working.has("unit_abilities"): state.unit_abilities = working.unit_abilities.duplicate(true)
	var message := "Straight-line charge confirmed through contact validation."
	_event(state, message)
	return {"error": "", "message": message}

static func _pile_eligible(state: Dictionary, squad: int) -> bool:
	return not living(state, squad).is_empty() and (_engaged(state, squad) or state.squads[squad].charged)

static func _begin_fight(state: Dictionary) -> void:
	if Doctrines.enabled(state): state.combat_doctrines["spearpoint_destroyed_units"] = {}
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
			if UnitActions.Bladeguard.offer(state, {"kind": "empty-fight", "squad": squad, "melee": true, "player": player}, []):
				_event(state, "Choose Bladeguard stance before completing the unengaged fight.")
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
	_event(state, "Player %d, unit %d resolved an unengaged fight without moving or attacking." % [player, squad])

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
	var error := _command_error(state, player, revision)
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
		if state.squads[squad].shot and not DetachmentStratagems.vengeful_shooter(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "This squad already shot this phase."
		if state.squads[squad].fell_back and not Doctrines.shoot_after_fallback(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "A squad that Fell Back needs an effect that allows it to shoot this turn."
	return ""

static func attack_plan_error(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool = true, hail_target: int = -1, indirect_shooting: bool = false) -> String:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return error
	return AttackPlan.prepare(state, state.units[attacker].squad, melee, entries, use_lethal, hail_target, indirect_shooting).error

static func resolve_attack_plan(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool, roller: Callable, hail_target: int = -1, indirect_shooting: bool = false) -> Dictionary:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return {"error": error}
	var squad: int = state.units[attacker].squad
	var prepared := AttackPlan.prepare(state, squad, melee, entries, use_lethal, hail_target, indirect_shooting)
	if not prepared.error.is_empty(): return prepared
	var firing_deck_error := FiringDeck.declare_transport_shooting(state, attacker, entries)
	if not firing_deck_error.is_empty(): return {"error": firing_deck_error}
	var declaration := {"kind": "attack", "player": player, "attacker": attacker, "squad": squad, "entries": entries.duplicate(true), "melee": melee, "use_lethal": use_lethal, "hail_target": hail_target, "indirect_shooting": indirect_shooting, "reaction_index": 0}
	return _continue_attack_declaration(state, declaration, roller)

static func _continue_attack_declaration(state: Dictionary, declaration: Dictionary, roller: Callable) -> Dictionary:
	var prepared := AttackPlan.prepare(state, int(declaration.squad), bool(declaration.melee), declaration.entries, bool(declaration.use_lethal), int(declaration.hail_target), bool(declaration.get("indirect_shooting", false)))
	if not prepared.error.is_empty(): return prepared
	var waiting := state.duplicate(true)
	var index := int(declaration.get("reaction_index", 0))
	if index <= 0:
		declaration.reaction_index = 1
		if UnitActions.Incursors.offer(waiting, declaration):
			var message := "Attack declared; eligible Incursor units may use Divinator-class Auspexes before the shot."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
		index = 1
	if index <= 1:
		declaration.reaction_index = 2
		if UnitActions.PhobosLibrarian.offer(waiting, declaration, prepared.targets):
			var message := "Attack declared; the targeted Phobos Librarian may use Shrouding before dice are rolled."
			_event(waiting, message)
			state.clear()
			state.merge(waiting, true)
			return {"error": "", "message": message, "pools": []}
		index = 2
	if index <= 2:
		declaration.reaction_index = 3
		if UnitActions.Bladeguard.offer(waiting, declaration, prepared.targets):
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
			if not DetachmentStratagems.armour_error(state, defender, target, int(declaration.squad)).is_empty(): continue
			declaration.reaction_index = 3
			state.unit_abilities.window = {"kind": DetachmentStratagems.ARMOUR_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "declaration": declaration.duplicate(true)}
			var message := "Attack declared; the targeted Adeptus Astartes unit may use Armour of Contempt before attack dice are rolled."
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
				state.unit_abilities.window = {"kind": DetachmentStratagems.WORTHY_WINDOW, "owners": [defender], "squad": target, "attacker_squad": int(declaration.squad), "stratagem": worthy_rule, "declaration": declaration.duplicate(true)}
				var message := "Attack declared; the targeted Adeptus Astartes unit may use %s before attack dice are rolled." % ("Duty in Death" if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH else "A Worthy Death")
				_event(state, message)
				return {"error": "", "message": message, "pools": []}
		declaration.reaction_index = 4
		index = 4
	if index <= 4 and UnitAbilities.enabled(state) and not declaration.get("mounted_reaction_checked", false) and not bool(declaration.melee):
		for target: int in prepared.targets:
			var defender := int(state.squads[target].owner)
			var prior_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
			state.unit_abilities.window = {"kind": "stormlance-hurtling", "owners": [defender], "squad": target, "declaration": declaration.duplicate(true)}
			var can_hurtling := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.HURTLING_TARGETS).is_empty()
			var can_evasive := DetachmentStratagems.error(state, defender, target, DetachmentStratagems.EVASIVE_MANOEUVRES).is_empty()
			state.unit_abilities.window = prior_window
			if can_hurtling or can_evasive:
				declaration.mounted_reaction_checked = true
				declaration.reaction_index = 5
				state.unit_abilities.window = {"kind": "stormlance-hurtling", "owners": [defender], "squad": target, "declaration": declaration.duplicate(true), "can_hurtling": can_hurtling, "can_evasive": can_evasive}
				var message := "Attack declared; the targeted mounted unit may use a defensive stratagem before dice are rolled."
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
			state.unit_abilities.window = {"kind": DetachmentStratagems.HEADHUNTER_WINDOW, "owners": [owner], "squad": shooter, "declaration": declaration.duplicate(true)}
			var message := "Selected Vehicle may use Headhunter Doctrine before its ranged attack is prepared."
			_event(state, message)
			return {"error": "", "message": message, "pools": []}
		index = 6
	var final_prepared := AttackPlan.prepare(state, int(declaration.squad), bool(declaration.melee), declaration.entries, bool(declaration.use_lethal), int(declaration.hail_target), bool(declaration.get("indirect_shooting", false)))
	if not final_prepared.error.is_empty(): return final_prepared
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
		if batch.context.get("free_wound_reroll", false) or batch.context.get("free_damage_reroll", false) or batch.context.get("machine_spirit_power", false): ability_window = true
	if state.get("manual_allocation", false) or precision or ability_window or state.get("stratagems", {}).get("attack_rerolls", false) or state.get("stratagems", {}).get("save_rerolls", false) or state.get("stratagems", {}).get("damage_rerolls", false) or state.get("stratagems", {}).get("count_rerolls", false):
		var working := state.duplicate(true)
		Allocation.start(working, prepared, squad, player, entries, melee, not state.get("manual_allocation", false))
		var rolled := Allocation.pump(working, roller)
		if not rolled.error.is_empty(): return rolled
		var result: Dictionary
		if rolled.complete: result = _finish_pending_attack(working, roller)
		else:
			var pending_choice_window := UnitActions.pending(working)
			var message := "Attack declared; player %d must allocate damage to %s." % [actor(working), working.squads[working.pending_attack.current.target].name]
			if pending_choice_window.get("kind", "") == "wound": message = "%s: choose wound rerolls before saves." % working.pending_attack.current.checkpoint.context.get("free_wound_reroll_source", "Implacable Eradication")
			if pending_choice_window.get("kind", "") == "aquilon-hit": message = "Aquilon Optics: choose one hit die to re-roll, or continue."
			if pending_choice_window.get("kind", "") in ["machine-spirit-hit", "machine-spirit-wound"]: message = "%s: choose one %s die to re-roll, or continue." % [pending_choice_window.get("source", "Power of the Machine Spirit"), "hit" if pending_choice_window.kind == "machine-spirit-hit" else "wound"]
			if pending_choice_window.get("kind", "") == "damage-reroll": message = "%s: keep or re-roll this Damage roll." % pending_choice_window.get("source", "Total Obliteration")
			if not Stratagems.pending(working).is_empty(): message = "Attack paused: accept the roll or choose a D6 for Command Re-roll before the next step."
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

static func _finish_attack(state: Dictionary, squad: int, player: int, entries: Array, melee: bool, prepared: Dictionary, resolved: Dictionary, roller: Callable) -> Dictionary:
	var hazard := Hazard.roll(state, squad, int(prepared.get("hazardous_count", 0)), roller, prepared.get("hazard_modifiers", []))
	if not hazard.error.is_empty(): return hazard
	resolved.hazardous = hazard
	if state.get("stratagems", {}).get("hazard_rerolls", false) and not hazard.rolls.is_empty() and not living(state, squad).is_empty() and Stratagems.eligibility_error(state, player, squad, "command-re-roll").is_empty():
		state.pending_hazard = {"squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee, "prepared": prepared, "resolved": resolved, "remaining": hazard.total}
		var indices: Array[int] = []
		for index in range(hazard.rolls.size()): indices.append(index)
		state.stratagems.pending = {"kind": "after_hazardous_roll", "player": player, "squad": squad, "phase_key": Stratagems.phase_key(state), "rolls": hazard.rolls.duplicate(), "eligible": indices}
		var message := "Hazardous: accept the results or replace one D6 before allocation."
		_event(state, message)
		return {"error": "", "message": message, "pools": resolved.pools}
	if hazard.total > 0 and not living(state, squad).is_empty():
		state.pending_hazard = {"squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee, "prepared": prepared, "resolved": resolved, "remaining": hazard.total}
		var message := "Player %d: allocate %d Hazardous mortal wounds to %s." % [player, hazard.total, state.squads[squad].name]
		_event(state, message)
		return {"error": "", "message": message, "pools": resolved.pools}
	return _commit_finished_attack(state, squad, player, entries, melee, prepared, resolved, roller)

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
		if state.fight_step == "consolidation_reaction": _resume_consolidation(state)
		elif not CoreReactions.offer_counter(state, squad): _select_fighter(state, 3 - player)
	else:
		if CoreReactions.overwatch_shooter(state, squad):
			CoreReactions.clear_overwatch(state)
		else:
			state.squads[squad].shot = true
			state.squads[squad].last_ranged_turn = state.turn
			if prepared.get("indirect_shooting", false): state.squads[squad].indirect_shooting_block = "%d:%s" % [state.turn, state.phase]
		if DetachmentStratagems.vengeful_shooter(state, squad): DetachmentStratagems.clear_vengeful(state)
	if not melee and UnitAbilities.enabled(state) and state.unit_abilities.get("optics", {}).get("squad", -1) == squad: state.unit_abilities.erase("optics")
	DetachmentStratagems.after_attacks(state, squad, prepared.targets, int(resolved.killed), prepared, resolved)
	if melee and state.phase == "fight":
		for target: int in prepared.targets: Doctrines.record_spearpoint_destroyed_unit(state, squad, target)
	UnitAbilities.offer_cover_target(state, squad, prepared, resolved, melee)
	UnitAbilities.open_destroyed_mark_replacements(state)
	if not melee and state.phase == "shooting" and state.active == player and UnitAbilities.enabled(state):
		TacticalFluidity.open_after_shot(state, squad)
		PurgationRun.open_after_shot(state, squad)
	if not melee and state.phase == "shooting" and state.active == player and UnitAbilities.enabled(state):
		VictrixHonourGuard.open_after_enemy_shot(state, squad, resolved.pools)
	var names: Array[String] = []
	for target: int in prepared.targets: names.append(state.squads[target].name)
	var message := "%s%s → %s: %d damage, %d models destroyed." % [state.squads[squad].name, " melee" if melee else "", ", ".join(names), resolved.damage, resolved.killed]
	if melee and not state.get("unit_abilities", {}).get("window", {}).is_empty() and state.unit_abilities.window.get("kind", "") == "counter":
		message += " Opponent may use Counteroffensive or decline."
	if not Objectives.training(state) and not Mission.enabled(state) and (living_owner(state, 1).is_empty() or living_owner(state, 2).is_empty()):
		state.test_winner = -1 if living_owner(state, 1).is_empty() and living_owner(state, 2).is_empty() else (2 if living_owner(state, 1).is_empty() else 1)
		message += " Elimination exercise finished."
	state.last_attack = {"message": message, "pools": resolved.pools, "assignments": entries.duplicate(true), "targets": prepared.targets.duplicate()}
	state.last_attack.hazardous = resolved.get("hazardous", {})
	if prepared.has("hail_of_bolts"):
		state.last_attack.hail_of_bolts = prepared.hail_of_bolts.duplicate(true)
		message += " Hail of Bolts: " + state.squads[prepared.hail_of_bolts.target].name + "."
		state.last_attack.message = message
	_event(state, message)
	return {"error": "", "message": message, "pools": resolved.pools}

static func _single_target_attack(state: Dictionary, player: int, attacker: int, target: int, revision: int, melee: bool, use_lethal: bool, roller: Callable) -> Dictionary:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return {"error": error}
	if not state.units.has(target) or state.units[target].wounds <= 0 or state.units[target].owner == player: return {"error": "Select a living enemy target."}
	var entries := AttackPlan.single_target(state, state.units[attacker].squad, state.units[target].squad, melee)
	return resolve_attack_plan(state, player, attacker, entries, revision, melee, use_lethal, roller)

static func _finish_pending_attack(state: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = state.pending_attack
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
			_event(state, str(demise.get("message", "Resolve Deadly Demise.")))
			return demise
		pending = state.pending_attack
	if not pending.get("forward_assault_checked", false):
		pending.forward_assault_checked = true
		if UnitAbilities.open_destroyed_mark_replacements(state): return {"error": "", "complete": false}
	state.pending_attack = {}
	return _finish_attack(state, pending.squad, pending.player, pending.entries, pending.melee, pending.prepared, {"pools": pending.pools, "damage": pending.damage, "killed": pending.killed}, roller)

static func resolve_attack_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable) -> String:
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if Stratagems.pending(state).kind not in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_attack_count_roll"]: return "There is no pending attack decision."
	if stratagem not in ["", "command-re-roll"]: return "Invalid stratagem for this roll."
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
	var working := state.duplicate(true)
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
	else: _event(working, "Attack roll decision accepted; player %d continues." % actor(working))
	state.clear()
	state.merge(working, true)
	return ""

static func allocate_damage(state: Dictionary, player: int, model: int, revision: int, roller: Callable) -> String:
	if state.test_winner != 0: return "Exercise finished."
	if revision != state.revision: return "State changed; synchronize before allocating."
	var error := Allocation.choice_error(state, player, model)
	if not error.is_empty(): return error
	var working := state.duplicate(true)
	var applied := Allocation.apply(working, model, roller)
	if not applied.error.is_empty(): return applied.error
	var result := Allocation.pump(working, roller)
	if not result.error.is_empty(): return result.error
	if result.complete:
		var finished := _finish_pending_attack(working, roller)
		if not finished.error.is_empty(): return finished.error
	else: _event(working, "Allocation choice accepted for model %d; player %d continues the attack sequence." % [model, actor(working)])
	state.clear()
	state.merge(working, true)
	return ""

static func resolve_hazard_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable) -> String:
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if Stratagems.pending(state).kind != "after_hazardous_roll": return "There is no pending Hazardous decision."
	if stratagem not in ["", "command-re-roll"]: return "Invalid stratagem for this decision."
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
		if die not in Stratagems.pending(state).eligible: return "Select a D6 from this Hazardous pool."
	var working := state.duplicate(true)
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
		replaced.rerolls = [{"index": die, "original": original[die], "replacement": value}]
		pending.resolved.hazardous = replaced
		Stratagems.consume(working, player, squad, stratagem)
	working.last_command_roll = {"kind": "after_hazardous_roll", "squad": squad, "original_rolls": original, "rolls": pending.resolved.hazardous.rolls.duplicate(), "rerolled": not stratagem.is_empty(), "die": die}
	working.stratagems.pending = {}
	pending.remaining = pending.resolved.hazardous.total
	if pending.remaining > 0 and not living(working, squad).is_empty(): _event(working, "Hazardous confirmado; aloque %d ferida(s) mortal(is)." % pending.remaining)
	else:
		working.pending_hazard = {}
		var committed := _commit_finished_attack(working, squad, player, pending.entries, pending.melee, pending.prepared, pending.resolved, roller)
		if not committed.error.is_empty(): return committed.error
	state.clear()
	state.merge(working, true)
	return ""

static func allocate_hazard(state: Dictionary, player: int, model: int, revision: int, roller: Callable = Callable()) -> String:
	if revision != state.revision: return "State changed; synchronize before allocating."
	var error := Hazard.choice_error(state, player, model)
	if not error.is_empty(): return error
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
	else: _event(state, "Hazardous mortal wound allocated to model %d." % model)
	return ""

static func fight(state: Dictionary, player: int, attacker: int, target: int, revision: int, roller: Callable) -> Dictionary:
	return _single_target_attack(state, player, attacker, target, revision, true, true, roller)

static func shoot(state: Dictionary, player: int, attacker: int, target: int, revision: int, use_lethal: bool, roller: Callable) -> Dictionary:
	return _single_target_attack(state, player, attacker, target, revision, false, use_lethal, roller)

static func resolve_reanimation(state: Dictionary, player: int, action: String, squad: int, model: int, position: Vector2, revision: int, roller: Callable = Callable()) -> String:
	var error := Reanimation.choice_error(state, player, revision)
	if not error.is_empty(): return error
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
	if Reanimation.pending(working).is_empty() and UnitActions.pending(working).is_empty():
		error = advance_phase(working, player, working.revision, roller)
		if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func select_combat_doctrine(state: Dictionary, player: int, doctrine: String, revision: int) -> String:
	var error := Doctrines.choice_error(state, player, doctrine, revision)
	if not error.is_empty(): return error
	Doctrines.select_doctrine(state, player, doctrine)
	if state.combat_doctrines.cp_pending_turn == state.turn:
		state.cp[1] += 1
		state.cp[2] += 1
		state.combat_doctrines.cp_pending_turn = -1
	_event(state, "Player %d: %s (11e Combat Doctrines; Gladius extra use %s)." % [player, Doctrines.NAMES[doctrine], "spent" if state.combat_doctrines.extra_used.get(player, false) else "available"] if state.combat_doctrines.gladius else "Player %d: %s (11e Combat Doctrines; %s detachment)." % [player, Doctrines.NAMES[doctrine], str(state.combat_doctrines.get("detachment", "none")).capitalize()])
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
	var was_reanimation := not Reanimation.pending(working).is_empty()
	var result := UnitActions.apply(working, player, selected, point, roller)
	if not result.get("error", "").is_empty(): return result.error
	if Mission.enabled(working) and selected.action == "setup-done" and working.unit_abilities.get("setup_players", []).size() == 2:
		Mission.preview(working)
	if result.get("resume_fight", false):
		_select_fighter(working, int(result.get("resume_cursor", working.active)))
	if result.has("resume_declaration"):
		var declaration: Dictionary = result.resume_declaration
		if declaration.kind == "empty-fight":
			_finish_empty_fight(working, declaration.player, declaration.squad)
		else:
			var resumed := _continue_attack_declaration(working, declaration, roller)
			if not resumed.error.is_empty(): return resumed.error
		state.clear()
		state.merge(working, true)
		return ""
	if result.has("resume_mobile_declaration"):
		var mobile_declaration: Dictionary = result.resume_mobile_declaration
		if mobile_declaration.get("action", "") == "movement":
			var move_error := begin_movement(working, player, int(mobile_declaration.model), str(mobile_declaration.move_type), revision, roller, bool(mobile_declaration.get("use_sudden_onslaught", false)), true)
			if not move_error.is_empty(): return move_error
			if selected.action == "detachment-stratagem":
				var mobile_source := "Flawless Riders" if selected.get("value", "") == DetachmentStratagems.FLAWLESS_RIDERS else ("Mobile Lethality" if selected.get("value", "") == DetachmentStratagems.MOBILE_LETHALITY else "Unstoppable Advance")
				_event(working, "%s: %s resolved; continue the selected move." % [working.squads[int(mobile_declaration.squad)].name, mobile_source])
			else: _event(working, str(result.get("message", "The Mobile stratagem was declined.")))
		elif mobile_declaration.get("action", "") == "charge":
			var charge_result := declare_charge(working, player, int(mobile_declaration.model), revision, roller, true)
			if not charge_result.get("error", "").is_empty(): return charge_result.error
			if selected.action == "detachment-stratagem":
				var mobile_source := "Flawless Riders" if selected.get("value", "") == DetachmentStratagems.FLAWLESS_RIDERS else ("Mobile Lethality" if selected.get("value", "") == DetachmentStratagems.MOBILE_LETHALITY else "Unstoppable Advance")
				_event(working, "%s: %s resolved; %s" % [working.squads[int(mobile_declaration.squad)].name, mobile_source, str(charge_result.get("message", "charge roll resolved."))])
			else: _event(working, str(charge_result.get("message", result.get("message", "The Mobile stratagem was declined."))))
		else: return "The Mobile stratagem prompt has no valid movement or charge declaration to resume."
		state.clear()
		state.merge(working, true)
		return ""
	if result.get("resume_attack", false):
		var resumed := Allocation.pump(working, roller)
		if not resumed.error.is_empty(): return resumed.error
		if resumed.complete:
			var finished := _finish_pending_attack(working, roller)
			if not finished.error.is_empty(): return finished.error
		else: _event(working, selected.label)
	else: _event(working, str(result.get("message", selected.label)))
	if result.get("advance", false) or (was_reanimation and Reanimation.pending(working).is_empty() and UnitActions.pending(working).is_empty()):
		var error := advance_phase(working, working.active, working.revision, roller)
		if not error.is_empty(): return error
	state.clear()
	state.merge(working, true)
	return ""

static func _resolve_current_end_control(state: Dictionary) -> void:
	if not UnitAbilities.enabled(state) or (state.phase not in ["command", "movement", "shooting", "charge", "fight"] and not (Mission.enabled(state) and state.phase == "end_turn")): return
	var phase_key := UnitActions.key(state)
	if state.unit_abilities.get("control_done", "") == phase_key: return
	Objectives.resolve_control(state)
	if state.phase == "movement":
		for index in range(state.get("mission", {}).get("objectives", []).size()):
			var objective: Dictionary = state.mission.objectives[index]
			if objective.controller != state.active: continue
			for squad: int in Objectives.controlling_squads(state, objective):
				if UnitAbilities.has(state, squad, "raise-the-banner"): Objectives.secure(state, index, state.active)
				if UnitAbilities.has(state, squad, "banner-of-macragge"):
					for model: int in Contact.alive(state, squad):
						if UnitAbilities.identity(state.units[model]) == "victrix-honour-guard" and state.units[model].get("victrix_honour_guard_role", "") == "chapter-ancient":
							Objectives.secure(state, index, state.active)
							break
	state.unit_abilities.control_done = phase_key

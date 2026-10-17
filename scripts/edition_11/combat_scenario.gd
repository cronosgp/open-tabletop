extends RefCounted
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
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
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const OathOfMoment = preload("res://scripts/edition_11/oath_of_moment.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const Hazard = preload("res://scripts/edition_11/hazardous.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const PACK_ID := "11e-3d-integration-v23"
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
			"move_type": "unselected", "advanced": false, "fell_back": false,
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
		"pending_move": {}, "pending_charge": {}, "pending_contact": {}, "consolidation_return": 0,
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
		for id: int in state.units: state.units[id].moved = false
	else:
		if state.phase == "fight": DetachmentStratagems.remove_lingering(state)
		if state.phase == "movement":
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
	return ""

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
	return maxf(0.0, float(unit.movement) + bonus - spent)

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

static func begin_movement(state: Dictionary, player: int, model: int, move_type: String, revision: int, roller: Callable = Callable()) -> String:
	var error := movement_choice_error(state, player, model, move_type, revision)
	if not error.is_empty(): return error
	var squad: int = state.units[model].squad
	if move_type == "stationary":
		state.squads[squad].moved = true
		state.squads[squad].move_type = move_type
		_event(state, "%s remained stationary." % state.squads[squad].name)
		return ""
	var draft := _movement_draft(state, squad, move_type)
	if move_type in ["advance", "desperate_escape"]:
		if not roller.is_valid(): return "This move requires host dice."
		var dice := Attacks.Dice.new(roller)
		if move_type == "advance": draft.bonus = dice.d6()
		else:
			for member: int in living(state, squad):
				var roll := dice.d6()
				draft.hazard_rolls.append(roll)
				if roll <= 2: draft.hazard_remaining += 1
		if not dice.error.is_empty(): return dice.error
	if move_type == "advance":
		var opened := Stratagems.open_roll(state, player, squad, "after_advance_roll", [draft.bonus], draft)
		if DetachmentStratagems.sudden_led_advance(state, squad):
			if opened: state.stratagems.pending.sudden = true
			elif DetachmentStratagems.open_advance(state, player, squad, [draft.bonus], draft): opened = true
		if opened:
			_event(state, "%s: Advance D6 = %d. Accept%s before moving." % [state.squads[squad].name, draft.bonus, ", re-roll with Sudden Storm" if state.stratagems.pending.get("sudden", false) else " or use Command Re-roll"])
			return ""
	state.pending_move = draft
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
	if move_type == "advance": message += " Advance roll: %d inches." % draft.bonus
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
	var prevention := Attacks.Prevention.resolve(1, state.units[model].wounds, state.units[model].get("feel_no_pain", []), "mortal", roller)
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
	state.pending_move = {}
	UnitActions.end_move(state, squad)
	_event(state, "%s movement confirmed; longest model path %.2f inches." % [state.squads[squad].name, longest])
	return ""

static func declare_charge(state: Dictionary, player: int, model: int, revision: int, roller: Callable) -> Dictionary:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return {"error": error}
	if state.phase != "charge": return {"error": "Declare charges only in the Charge phase."}
	if not state.pending_charge.is_empty(): return {"error": "Resolve the pending charge first."}
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true) or state.units[model].owner != player:
		return {"error": "Select a living model in your squad."}
	var squad: int = state.units[model].squad
	error = Doctrines.charge_error(state, squad)
	if not error.is_empty(): return {"error": error}
	if Actions.charge_blocked(state, squad): return {"error": "Starting an action prevents charges until the turn ends."}
	if state.squads[squad].charge_declared: return {"error": "This squad already declared a charge this phase."}
	if _engaged(state, squad): return {"error": "Engaged squads cannot declare a charge."}
	var nearest := INF
	for enemy: int in ContactActions.enemies(state, squad):
		for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	error = CoreReactions.charge_error(state, player, squad)
	if not error.is_empty(): return {"error": error}
	if nearest > 12.0: return {"error": "No enemy unit within 12 inches."}
	if not roller.is_valid(): return {"error": "Missing host dice provider."}
	var dice := Attacks.Dice.new(roller)
	var rolls := [dice.d6(), dice.d6()]
	if not dice.error.is_empty(): return {"error": dice.error}
	var maximum: int = rolls[0] + rolls[1]
	state.squads[squad].charge_declared = true
	if player == state.active: CoreReactions.record_charger(state, squad)
	if Stratagems.open_roll(state, player, squad, "after_charge_roll", rolls):
		var notice := "%s: Charge %s = %d. Accept or use Command Re-roll on both dice." % [state.squads[squad].name, str(rolls), maximum]
		_event(state, notice)
		return {"error": "", "message": notice}
	return _accept_charge_roll(state, squad, rolls)

static func _accept_charge_roll(state: Dictionary, squad: int, rolls: Array) -> Dictionary:
	var maximum: int = CoreReactions.cap_charge(state, squad, rolls[0] + rolls[1])
	var nearest := INF
	for enemy: int in ContactActions.enemies(state, squad):
		for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	var message := "%s charge roll: %s = %d inches. Choose a target now." % [state.squads[squad].name, str(rolls), maximum]
	if maximum < nearest:
		message = "%s charge failed: %s = %d, no target within the rolled distance." % [state.squads[squad].name, str(rolls), maximum]
		if CoreReactions.heroic_charger(state, state.squads[squad].owner, squad): CoreReactions.clear_heroic(state)
	else:
		state.pending_charge = {"squad": squad, "maximum": maximum, "rolls": rolls, "targets": []}
	_event(state, message)
	return {"error": "", "message": message}

static func resolve_roll_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, roller: Callable = Callable()) -> String:
	var window := Stratagems.pending(state)
	if window.get("kind") not in ["after_advance_roll", "after_charge_roll"]: return "No Advance or Charge roll is waiting for a decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in ["", "command-re-roll", "sudden-storm"]: return "Stratagem unavailable for this roll."
	if stratagem == "sudden-storm" and (window.kind != "after_advance_roll" or not window.get("sudden", false)): return "Sudden Storm Advance re-roll is not available."
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
	working.last_command_roll = {"kind": window.kind, "squad": squad, "original_rolls": window.rolls.duplicate(), "rolls": rolls.duplicate(), "rerolled": not stratagem.is_empty()}
	if window.kind == "after_advance_roll":
		working.pending_move = window.draft.duplicate(true)
		working.pending_move.bonus = rolls[0]
		_event(working, "%s: final Advance %s = %d%s. Movement can begin." % [working.squads[squad].name, str(rolls), rolls[0], " • Sudden Storm re-roll" if stratagem == "sudden-storm" else (" • Command Re-roll, 1 CP" if stratagem == "command-re-roll" else " • result accepted")])
	else:
		var result := _accept_charge_roll(working, squad, rolls)
		if not result.error.is_empty(): return result.error
		if not stratagem.is_empty(): working.events[-1].message += " Command Re-roll: %s → %s, 1 CP." % [str(window.rolls), str(rolls)]
	state.clear()
	state.merge(working, true)
	return ""

static func decline_charge(state: Dictionary, player: int, revision: int) -> String:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return error
	if state.phase != "charge" or state.pending_charge.is_empty(): return "No pending charge."
	if not state.pending_contact.is_empty():
		ContactActions.restore(state)
		state.pending_contact = {}
	var heroic_squad: int = int(state.pending_charge.get("squad", -1))
	state.pending_charge = {}
	if CoreReactions.heroic_charger(state, player, heroic_squad): CoreReactions.clear_heroic(state)
	_event(state, "Charge resolved without moving; it cannot be rolled again this phase.")
	return ""

static func select_charge_target(state: Dictionary, player: int, target: int, revision: int) -> Dictionary:
	var error := _command_error(state, player, revision)
	if not error.is_empty(): return {"error": error}
	if state.phase != "charge" or state.pending_charge.is_empty(): return {"error": "Roll the charge before choosing its target."}
	if not state.pending_contact.is_empty(): return {"error": "Cancel charge placement before changing targets."}
	if not state.units.has(target) or state.units[target].wounds <= 0 or state.units[target].owner == player:
		return {"error": "Choose a living enemy target after the charge roll."}
	var squad: int = state.pending_charge.squad
	var enemy: int = state.units[target].squad
	var nearest := INF
	for id: int in living(state, squad): nearest = minf(nearest, Contact.distance_to_target(state, state.units[id], enemy))
	if nearest > minf(12.0, state.pending_charge.maximum): return {"error": "Target must be within 12 inches and the full rolled distance."}
	error = CoreReactions.leap_target_error(state, squad, enemy)
	if not error.is_empty(): return {"error": error}
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
		for target: int in state.pending_charge.get("targets", []): targets.append(target)
		maximum = float(state.pending_charge.maximum)
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
		if CoreReactions.heroic_charger(state, player, squad): CoreReactions.clear_heroic(state)
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
	state.fight_priority = "first" if not pool.is_empty() and (state.squads[pool[0]].charged or state.squads[pool[0]].get("fights_first", false)) else "remaining"
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
			state.squads[squad].fought = true
			if state.fight_step == "consolidation_reaction": _resume_consolidation(state)
			else: _select_fighter(state, 3 - player)
			_event(state, "Player %d, unit %d resolved an unengaged fight without moving or attacking." % [player, squad])
		"consolidate":
			if squad != -1:
				if not state.has("consolidate_done"): state.consolidate_done = []
				state.consolidate_done.append(squad)
			_select_consolidation(state)
			_event(state, "Player %d, unit %d %s consolidation movement." % [player, squad, "confirmed" if moved else "declined optional"])
	return ""

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
	if melee:
		if state.phase != "fight" or state.fight_step not in ["attacks", "consolidation_reaction"]: return "Resolve pile-in decisions before fighting."
		if squad not in FightQueue.choices(state, player): return "Select an eligible unit in the current priority or reaction queue."
	else:
		if not CoreReactions.overwatch_shooter(state, squad) and state.phase != "shooting": return "Attacks are allowed only in the Shooting phase."
		if Actions.shooting_blocked(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "Starting an action prevents shooting until the turn ends."
		if state.squads[squad].shot and not DetachmentStratagems.vengeful_shooter(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "This squad already shot this phase."
		if state.squads[squad].fell_back and not Doctrines.shoot_after_fallback(state, squad) and not CoreReactions.overwatch_shooter(state, squad): return "A squad that Fell Back needs Tactical Doctrine to shoot this turn."
	return ""

static func attack_plan_error(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool = true, hail_target: int = -1) -> String:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return error
	return AttackPlan.prepare(state, state.units[attacker].squad, melee, entries, use_lethal, hail_target).error

static func resolve_attack_plan(state: Dictionary, player: int, attacker: int, entries: Array, revision: int, melee: bool, use_lethal: bool, roller: Callable, hail_target: int = -1) -> Dictionary:
	var error := attack_window_error(state, player, attacker, revision, melee)
	if not error.is_empty(): return {"error": error}
	var squad: int = state.units[attacker].squad
	var prepared := AttackPlan.prepare(state, squad, melee, entries, use_lethal, hail_target)
	if not prepared.error.is_empty(): return prepared
	var precision := false
	var ability_window := false
	for batch: Dictionary in prepared.batches:
		if batch.weapon.keywords.get("precision", false): precision = true
		if batch.context.get("free_wound_reroll", false): ability_window = true
	if state.get("manual_allocation", false) or precision or ability_window or state.get("stratagems", {}).get("attack_rerolls", false) or state.get("stratagems", {}).get("save_rerolls", false) or state.get("stratagems", {}).get("damage_rerolls", false) or state.get("stratagems", {}).get("count_rerolls", false):
		var working := state.duplicate(true)
		Allocation.start(working, prepared, squad, player, entries, melee, not state.get("manual_allocation", false))
		var rolled := Allocation.pump(working, roller)
		if not rolled.error.is_empty(): return rolled
		var result: Dictionary
		if rolled.complete: result = _finish_pending_attack(working, roller)
		else:
			var message := "Implacable Eradication: choose wound rerolls before saves." if UnitActions.pending(working).get("kind", "") == "wound" else "Attack declared; player %d must allocate damage to %s." % [actor(working), working.squads[working.pending_attack.current.target].name]
			if not Stratagems.pending(working).is_empty(): message = "Attack paused: accept the roll or choose a D6 for Command Re-roll before the next step."
			_event(working, message)
			result = {"error": "", "message": message, "pools": working.pending_attack.pools}
		if not result.error.is_empty(): return result
		state.clear()
		state.merge(working, true)
		return result
	var resolved := AttackPlan.resolve(state, prepared, roller)
	if not resolved.error.is_empty(): return resolved
	var working := state.duplicate(true)
	working.units = resolved.units
	var result := _finish_attack(working, squad, player, entries, melee, prepared, resolved, roller)
	if not result.error.is_empty(): return result
	state.clear()
	state.merge(working, true)
	return result

static func _finish_attack(state: Dictionary, squad: int, player: int, entries: Array, melee: bool, prepared: Dictionary, resolved: Dictionary, roller: Callable) -> Dictionary:
	var hazard := Hazard.roll(state, squad, int(prepared.get("hazardous_count", 0)), roller)
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
	return _commit_finished_attack(state, squad, player, entries, melee, prepared, resolved)

static func _commit_finished_attack(state: Dictionary, squad: int, player: int, entries: Array, melee: bool, prepared: Dictionary, resolved: Dictionary) -> Dictionary:
	if melee:
		state.squads[squad].fought = true
		state.squads[squad].fight_eligible = true
		DetachmentStratagems.remove_lingering(state, squad)
		state.squads[squad].fights_first = false
		if state.fight_step == "consolidation_reaction": _resume_consolidation(state)
		elif not CoreReactions.offer_counter(state, squad): _select_fighter(state, 3 - player)
	else:
		if CoreReactions.overwatch_shooter(state, squad):
			CoreReactions.clear_overwatch(state)
		else:
			state.squads[squad].shot = true
			state.squads[squad].last_ranged_turn = state.turn
		if DetachmentStratagems.vengeful_shooter(state, squad): DetachmentStratagems.clear_vengeful(state)
	DetachmentStratagems.after_attacks(state, squad, prepared.targets, int(resolved.killed))
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
		var replaced := Hazard.from_rolls(working, squad, final_rolls)
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
		_commit_finished_attack(working, squad, player, pending.entries, pending.melee, pending.prepared, pending.resolved)
	state.clear()
	state.merge(working, true)
	return ""

static func allocate_hazard(state: Dictionary, player: int, model: int, revision: int, roller: Callable = Callable()) -> String:
	if revision != state.revision: return "State changed; synchronize before allocating."
	var error := Hazard.choice_error(state, player, model)
	if not error.is_empty(): return error
	var pending: Dictionary = state.pending_hazard
	var prevention := Attacks.Prevention.resolve(1, state.units[model].wounds, state.units[model].get("feel_no_pain", []), "mortal", roller)
	if not prevention.error.is_empty(): return prevention.error
	state.units[model].wounds -= prevention.lost
	pending.remaining -= 1
	pending.resolved.hazardous.allocations.append(model)
	if not pending.resolved.hazardous.has("prevention"): pending.resolved.hazardous.prevention = []
	pending.resolved.hazardous.prevention.append(prevention)
	if pending.remaining == 0 or living(state, pending.squad).is_empty():
		pending.resolved.hazardous.discarded = pending.remaining
		state.pending_hazard = {}
		_commit_finished_attack(state, pending.squad, pending.player, pending.entries, pending.melee, pending.prepared, pending.resolved)
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
	_event(state, "Player %d: %s (11e Combat Doctrines; Gladius extra use %s)." % [player, Doctrines.NAMES[doctrine], "spent" if state.combat_doctrines.extra_used.get(player, false) else "available"])
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
	if result.get("resume_attack", false):
		var resumed := Allocation.pump(working, roller)
		if not resumed.error.is_empty(): return resumed.error
		if resumed.complete:
			var finished := _finish_pending_attack(working, roller)
			if not finished.error.is_empty(): return finished.error
		else: _event(working, selected.label)
	else: _event(working, selected.label)
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
	state.unit_abilities.control_done = phase_key

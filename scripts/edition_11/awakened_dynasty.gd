extends RefCounted
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const ID := "awakened-dynasty-command-protocols-11e-v2"
const REFERENCE := "https://wahapedia.ru/wh40k11ed/factions/necrons/#Command-Protocols"
const OVERLORD := "40kdc:11e:necrons:overlord"
const BODYGUARDS := ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:immortals"]

static func enable(state: Dictionary) -> void:
	var owners: Array[int] = []
	for owner in [1, 2]:
		if Reanimation.necron_army(state, owner): owners.append(owner)
	state.awakened_dynasty = {"implementation": ID, "owners": owners, "pending": [], "attachments": []}
	Capabilities.admit(state, "awakened-dynasty", ID)
	for squad: int in state.squads:
		if state.squads[squad].owner in owners: Capabilities.admit_squad(state, squad, "awakened-dynasty")

static func enabled(state: Dictionary) -> bool:
	return state.get("awakened_dynasty", {}).get("implementation", "") == ID

static func pure(state: Dictionary, squad: int, definitions: Array) -> bool:
	if not state.squads.has(squad) or state.squads[squad].get("attached", false): return false
	var identity := ""
	for unit: Dictionary in state.units.values():
		if unit.squad != squad: continue
		if identity.is_empty(): identity = str(unit.get("definition_id", ""))
		if identity not in definitions or unit.get("definition_id", "") != identity: return false
	return not identity.is_empty()

static func begin_setup(state: Dictionary) -> void:
	if not enabled(state): return
	var leaders: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner in state.awakened_dynasty.owners and pure(state, squad, [OVERLORD]) and Geometry.alive(state, squad).size() == 1: leaders.append(squad)
	leaders.sort()
	state.awakened_dynasty.pending = leaders

static func needs_setup(state: Dictionary) -> bool:
	return enabled(state) and not state.awakened_dynasty.pending.is_empty()

static func setup_actor(state: Dictionary) -> int:
	return int(state.squads[state.awakened_dynasty.pending[0]].owner) if needs_setup(state) else -1

static func candidates(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if not needs_setup(state): return result
	var owner := setup_actor(state)
	for squad: int in state.squads:
		if state.squads[squad].owner == owner and pure(state, squad, BODYGUARDS) and Geometry.alive(state, squad).size() == state.squads[squad].starting_strength: result.append(squad)
	result.sort()
	return result

static func choice_error(state: Dictionary, player: int, bodyguard: int, revision: int) -> String:
	if not needs_setup(state): return "No Overlord attachment decision is pending."
	if state.phase != "deployment" or state.turn != 1 or state.get("test_winner", 0) != 0 or state.deployment.index != 0 or not state.deployment.placed.is_empty(): return "Declare attachments before deploying any model."
	if revision != state.revision: return "State changed; synchronize before declaring an attachment."
	if player != setup_actor(state): return "This Overlord belongs to the other player."
	if bodyguard != -1 and bodyguard not in candidates(state): return "Choose an intact friendly, unled Warriors/Immortals unit or leave the Overlord standalone."
	return ""

static func choose(state: Dictionary, player: int, bodyguard: int, revision: int) -> String:
	var error := choice_error(state, player, bodyguard, revision)
	if not error.is_empty(): return error
	var working := state.duplicate(true)
	var leader: int = working.awakened_dynasty.pending[0]
	if bodyguard != -1:
		# Permission is verified above against the current Overlord datasheet.
		# Placement is still mandatory and validated by normal deployment.
		working.phase = "start_turn"
		working.revision = 0
		error = Attachments.form_practice_unit(working, bodyguard, leader, -1, true)
		if not error.is_empty(): return error
		working.pack_hash = state.pack_hash
		working.revision = revision
		Deployment.begin(working)
		_suggest_leader(working, bodyguard, leader)
	working.awakened_dynasty.attachments.append({"owner": player, "leader": leader, "bodyguard": bodyguard})
	working.awakened_dynasty.pending.erase(leader)
	state.clear()
	state.merge(working, true)
	return ""

static func _suggest_leader(state: Dictionary, bodyguard: int, component: int) -> void:
	var probe := state.duplicate(true)
	probe.deployment.index = probe.deployment.order.find(bodyguard)
	var model := -1
	# Avoid other units' previews too, so later deployment does not invalidate it.
	for id: int in probe.units:
		if probe.units[id].wounds > 0: probe.deployment.placed[id] = true
	for id: int in Geometry.alive(probe, bodyguard):
		if probe.units[id].component_squad == component: model = id
	if model == -1: return
	for anchor: int in Geometry.alive(probe, bodyguard):
		if anchor == model: continue
		for gap in [0.1, 0.7, 1.3, 1.9]:
			for direction in range(24):
				var distance: float = probe.units[anchor].radius + probe.units[model].radius + float(gap)
				var point: Vector2 = probe.units[anchor].position + Vector2.RIGHT.rotated(direction * TAU / 24.0) * distance
				if Deployment.position_error(probe, model, point).is_empty():
					probe.units[model].position = point
					if Geometry.coherent(probe, bodyguard):
						state.units[model].position = point
						return
	# Suggestions are not exhaustive. The player can still place all models manually.

static func hit_bonus(state: Dictionary, squad: int) -> int:
	if not enabled(state) or not state.squads.has(squad) or not state.squads[squad].get("attached", false): return 0
	var owner: int = state.squads[squad].owner
	if owner not in state.awakened_dynasty.owners or not Reanimation.necron_army(state, owner): return 0
	var leader := false
	for model: int in Geometry.alive(state, squad):
		var unit: Dictionary = state.units[model]
		if unit.owner != owner: return 0
		if unit.get("attachment_role", "") == "leader" and Groups.character(unit) and str(unit.get("definition_id", "")).begins_with("40kdc:11e:necrons:"): leader = true
	return 1 if leader else 0

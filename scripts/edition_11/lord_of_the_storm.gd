extends RefCounted
## Imotekh the Stormlord's once-per-battle Lord of the Storm ability at the end of the Command phase.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")

const ACTION := "imotekh-lord-of-the-storm"
const ALLOCATE := "imotekh-lord-of-the-storm-allocate"
const DECLINE := "imotekh-lord-of-the-storm-decline"
const MORTAL_WINDOW := "imotekh-lord-of-the-storm-mortal"
const SOURCE := "imotekh-the-stormlord"
const RANGE := 12.0
const EPSILON := 0.001

static func _targets(state: Dictionary, source_model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source_model): return result
	var source: Dictionary = state.units[source_model]
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) == int(source.get("owner", -2)): continue
		if Geometry.alive(state, squad).is_empty() or TransportRules.squad_embarked(state, squad): continue
		if Geometry.distance_to_target(state, source, squad) <= RANGE + EPSILON:
			result.append(squad)
	result.sort()
	return result

static func _sources(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != owner or not AbilityCatalog.enabled(state): return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)): continue
		if int(unit.get("embarked_transport", -1)) >= 0: continue
		var squad := int(unit.get("squad", -1))
		if state.get("unit_abilities", {}).get("reserves", {}).has(squad): continue
		if AbilityCatalog.identity(unit) != SOURCE and not AbilityCatalog.has(state, squad, "lord-of-the-storm"): continue
		if bool(used.get("lord-of-the-storm:%d" % model, false)): continue
		if bool(used.get("lord-of-the-storm-declined:%d:%d" % [model, int(state.get("turn", 0))], false)): continue
		if not _targets(state, model).is_empty(): result.append(model)
	result.sort()
	return result

static func available(state: Dictionary, owner: int) -> bool:
	return not _sources(state, owner).is_empty()

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "end": return result
	var owners: Array = window.get("owners", [])
	if owners.is_empty() or int(owners[0]) != player: return result
	for model: int in _sources(state, player):
		result.append({
			"label": "Imotekh the Stormlord: unleash Lord of the Storm",
			"action": ACTION,
			"model": model,
			"target": -1,
			"value": ""
		})
		result.append({
			"label": "Decline Lord of the Storm",
			"action": DECLINE,
			"model": model,
			"target": -1,
			"value": "pass"
		})
	return result

static func decline(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var model := int(selected.get("model", -1))
	state.unit_abilities.used["lord-of-the-storm-declined:%d:%d" % [model, int(state.get("turn", 0))]] = true
	if state.get("events", []) is Array:
		state.events.append({"revision": int(state.get("revision", 0)) + 1, "message": "Player %d declined Lord of the Storm." % player})
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") == "end" and not window.get("owners", []).is_empty() and int(window.owners[0]) == player:
		if not available(state, player):
			window.owners.pop_front()
			if window.owners.is_empty():
				state.unit_abilities.window = {}
				return {"error": "", "advance": true, "message": "Lord of the Storm declined; advancing phase."}
	return {"error": "", "message": "Lord of the Storm declined for this Command phase."}

static func _set_packet_window(state: Dictionary) -> bool:
	var pending: Dictionary = state.get("pending_lord_of_the_storm", {})
	if pending.is_empty(): return false
	while int(pending.get("packet_cursor", 0)) < pending.get("packets", []).size():
		var packet: Dictionary = pending.packets[pending.packet_cursor]
		if int(packet.get("remaining", 0)) > 0 and not Geometry.alive(state, int(packet.get("target", -1))).is_empty():
			state.unit_abilities.window = {
				"kind": MORTAL_WINDOW,
				"owners": [int(packet.owner)],
				"target": int(packet.target)
			}
			return true
		packet.discarded = int(packet.get("discarded", 0)) + int(packet.get("remaining", 0))
		packet.remaining = 0
		pending.packet_cursor = int(pending.packet_cursor) + 1
	var finished: Dictionary = pending.duplicate(true)
	state.last_lord_of_the_storm = finished
	state.pending_lord_of_the_storm = {}
	state.unit_abilities.window = finished.get("resume_window", {}).duplicate(true)
	return false

static func resolve(state: Dictionary, owner: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "end" or window.get("owners", []).is_empty() or int(window.owners[0]) != owner:
		return {"error": "Lord of the Storm is available only at the end of your Command phase."}
	var model := int(selected.get("model", -1))
	if model not in _sources(state, owner):
		return {"error": "Lord of the Storm is not available for this model."}
	if not state.get("pending_lord_of_the_storm", {}).is_empty():
		return {"error": "A Lord of the Storm sequence is already pending."}
	if not roller.is_valid():
		return {"error": "Lord of the Storm requires the host's dice provider."}

	state.unit_abilities.used["lord-of-the-storm:%d" % model] = true

	var targets := _targets(state, model)
	var events: Array[Dictionary] = []
	var packets: Array[Dictionary] = []

	for target_squad: int in targets:
		var d6_roll: Variant = roller.call()
		if not d6_roll is int or d6_roll < 1 or d6_roll > 6:
			return {"error": "Lord of the Storm D6 results must be integers from 1 to 6."}
		var d6 := int(d6_roll)
		var mortal_wounds := 0
		var d3_roll: Dictionary = {}
		if d6 >= 2 and d6 <= 5:
			var rolled_d3 := RandomStat.roll("D3", roller)
			if not str(rolled_d3.get("error", "")).is_empty(): return rolled_d3
			d3_roll = rolled_d3.duplicate(true)
			mortal_wounds = int(rolled_d3.value)
		elif d6 == 6:
			var rolled_d3 := RandomStat.roll("D3", roller)
			if not str(rolled_d3.get("error", "")).is_empty(): return rolled_d3
			d3_roll = rolled_d3.duplicate(true)
			mortal_wounds = int(rolled_d3.value) + 3

		events.append({
			"source_model": model,
			"target": target_squad,
			"d6": d6,
			"mortal_wounds": mortal_wounds,
			"d3": d3_roll
		})

		if mortal_wounds > 0:
			packets.append({
				"source_model": model,
				"target": target_squad,
				"owner": int(state.squads[target_squad].owner),
				"d6": d6,
				"mortal_wounds": mortal_wounds,
				"remaining": mortal_wounds,
				"allocations": [],
				"discarded": 0
			})

	var pending_record := {
		"model": model,
		"owner": owner,
		"events": events,
		"packets": packets,
		"packet_cursor": 0,
		"allocations": [],
		"resume_window": window.duplicate(true)
	}

	if packets.is_empty():
		state.last_lord_of_the_storm = pending_record.duplicate(true)
		state.pending_lord_of_the_storm = {}
		if state.get("events", []) is Array:
			state.events.append({"revision": int(state.get("revision", 0)) + 1, "message": "Lord of the Storm resolved; no mortal wounds were caused."})
		return {"error": "", "complete": true, "message": "Lord of the Storm resolved; no mortal wounds were caused."}

	state.pending_lord_of_the_storm = pending_record
	_set_packet_window(state)
	var first_packet: Dictionary = packets[0]
	var target_name := str(state.squads[int(first_packet.target)].name)
	var msg := "Player %d: allocate %d Lord of the Storm mortal wound(s) to %s." % [int(first_packet.owner), int(first_packet.remaining), target_name]
	if state.get("events", []) is Array:
		state.events.append({"revision": int(state.get("revision", 0)) + 1, "message": msg})
	return {"error": "", "complete": false, "message": msg}

static func allocation_choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get("pending_lord_of_the_storm", {})
	if pending.is_empty() or state.get("unit_abilities", {}).get("window", {}).get("kind", "") != MORTAL_WINDOW: return []
	if int(pending.get("packet_cursor", -1)) >= pending.get("packets", []).size(): return []
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	if int(packet.get("owner", -1)) != player: return []
	var current := {"target": int(packet.target), "precision": -1, "groups": [], "order": []}
	var result: Array = []
	for model: int in Groups.current_models(state, current, true):
		result.append({
			"label": "Lord of the Storm: allocate mortal wound to model %d (%d remaining)" % [model, int(packet.remaining)],
			"action": ALLOCATE,
			"model": model,
			"target": int(packet.target),
			"value": MORTAL_WINDOW
		})
	return result

static func allocate(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in allocation_choices(state, player):
		return {"error": "Choose a living model in the affected unit to allocate the Lord of the Storm mortal wound."}
	var pending: Dictionary = state.pending_lord_of_the_storm
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	var model := int(selected.model)
	var prevention: Dictionary = WoundPrevention.resolve(1, int(state.units[model].wounds), UnitPrevention.rules(state, model), "mortal", roller)
	if not str(prevention.get("error", "")).is_empty(): return prevention
	state.units[model].wounds = int(state.units[model].wounds) - int(prevention.lost)
	packet.allocations.append({"model": model, "prevention": prevention.duplicate(true)})
	packet.remaining = maxi(0, int(packet.remaining) - 1)
	pending.allocations.append({"source_model": int(packet.source_model), "target": int(packet.target), "model": model, "prevention": prevention.duplicate(true)})
	var destroyed := int(state.units[model].wounds) <= 0
	if destroyed:
		DetachmentStratagems.record_destroyed(state, model)
		for cenobyte: int in ChaplainGrimaldus.destroy_cenobytes(state, model):
			DetachmentStratagems.record_destroyed(state, cenobyte)
	if packet.remaining <= 0 or Geometry.alive(state, int(packet.target)).is_empty():
		if Geometry.alive(state, int(packet.target)).is_empty():
			packet.discarded = int(packet.remaining)
			packet.remaining = 0
		pending.packet_cursor = int(pending.packet_cursor) + 1
	_set_packet_window(state)
	if destroyed:
		var demise: Dictionary = DeadlyDemise.begin(state, [model], roller)
		if not str(demise.get("error", "")).is_empty(): return demise
		if not state.get("pending_deadly_demise", {}).is_empty():
			return {"error": "", "message": demise.get("message", "Resolve the destruction effects.")}
		_set_packet_window(state)
	return {"error": "", "message": "Lord of the Storm mortal wound allocated."}

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	match str(selected.get("action", "")):
		ACTION: return resolve(state, player, selected, roller)
		ALLOCATE: return allocate(state, player, selected, roller)
		DECLINE: return decline(state, player, selected)
	return {"error": "Unsupported Lord of the Storm action."}

static func resume_after_nested_destruction(state: Dictionary) -> void:
	if not state.get("pending_lord_of_the_storm", {}).is_empty() and state.get("pending_deadly_demise", {}).is_empty() and state.get("unit_abilities", {}).get("window", {}).get("kind", "") == MORTAL_WINDOW:
		_set_packet_window(state)

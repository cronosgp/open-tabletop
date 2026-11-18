extends RefCounted
## Nightbringer's mandatory end-of-Fight-phase Drain Life sequence.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")

const ACTION := "nightbringer-drain-life"
const ALLOCATE := "nightbringer-drain-life-allocate"
const MORTAL_WINDOW := "nightbringer-drain-life-mortal"
const SOURCE := "ctan-shard-of-the-nightbringer"

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _targets(state: Dictionary, source_model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source_model): return result
	var source: Dictionary = state.units[source_model]
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) == int(source.get("owner", -2)): continue
		if Geometry.alive(state, squad).is_empty(): continue
		if Geometry.distance_to_target(state, source, squad) <= 6.001: result.append(squad)
	result.sort()
	return result

static func _sources(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if str(state.get("phase", "")) != "fight" or not AbilityCatalog.enabled(state): return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var phase_key := _phase_key(state)
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
		if AbilityCatalog.identity(unit) != SOURCE: continue
		var squad := int(unit.get("squad", -1))
		if not AbilityCatalog.has(state, squad, "drain-life"): continue
		if str(used.get("drain-life:%d" % model, "")) == phase_key: continue
		if not _targets(state, model).is_empty(): result.append(model)
	result.sort()
	return result

static func available(state: Dictionary, owner: int) -> bool:
	return not _sources(state, owner).is_empty()

static func choices(state: Dictionary, owner: int) -> Array:
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") != "end": return []
	var window: Dictionary = state.unit_abilities.window
	if window.get("owners", []).is_empty() or int(window.owners[0]) != owner: return []
	var sources := _sources(state, owner)
	if sources.is_empty(): return []
	return [{"label": "Nightbringer: resolve Drain Life", "action": ACTION, "model": sources[0], "target": -1, "value": ""}]

static func _set_packet_window(state: Dictionary) -> bool:
	var pending: Dictionary = state.get("pending_drain_life", {})
	if pending.is_empty(): return false
	while int(pending.get("packet_cursor", 0)) < pending.get("packets", []).size():
		var packet: Dictionary = pending.packets[pending.packet_cursor]
		if int(packet.get("remaining", 0)) > 0 and not Geometry.alive(state, int(packet.get("target", -1))).is_empty():
			state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(packet.owner)], "target": int(packet.target)}
			return true
		packet.discarded = int(packet.get("discarded", 0)) + int(packet.get("remaining", 0))
		packet.remaining = 0
		pending.packet_cursor = int(pending.packet_cursor) + 1
	var finished: Dictionary = pending.duplicate(true)
	state.last_drain_life = finished
	state.pending_drain_life = {}
	state.unit_abilities.window = finished.get("resume_window", {}).duplicate(true)
	return false

static func resolve(state: Dictionary, owner: int, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "end" or window.get("owners", []).is_empty() or int(window.owners[0]) != owner or not available(state, owner):
		return {"error": "Drain Life is not available for this owner at the end of the Fight phase."}
	if not state.get("pending_drain_life", {}).is_empty(): return {"error": "A Drain Life sequence is already pending."}
	if not roller.is_valid(): return {"error": "Drain Life requires the host's dice provider."}
	var events: Array[Dictionary] = []
	var packets: Array[Dictionary] = []
	var sources := _sources(state, owner)
	for source_model: int in sources:
		for target_squad: int in _targets(state, source_model):
			var die: Variant = roller.call()
			if not die is int or die < 1 or die > 6: return {"error": "Drain Life D6 results must be integers from 1 to 6."}
			var event := {"source_model": source_model, "target": target_squad, "d6": die, "triggered": int(die) >= 4, "d3": {}, "mortal_wounds": 0}
			if int(die) >= 4:
				var damage: Dictionary = RandomStat.roll("D3", roller)
				if not str(damage.get("error", "")).is_empty(): return damage
				event.d3 = damage.duplicate(true)
				event.mortal_wounds = int(damage.value)
				packets.append({"source_model": source_model, "target": target_squad, "owner": int(state.squads[target_squad].owner),
					"d6": die, "roll": damage.duplicate(true), "remaining": int(damage.value), "allocations": [], "discarded": 0})
			events.append(event)
	var used: Dictionary = state.unit_abilities.get("used", {}).duplicate(true)
	for source_model: int in sources: used["drain-life:%d" % source_model] = _phase_key(state)
	state.unit_abilities.used = used
	state.pending_drain_life = {"phase_key": _phase_key(state), "owner": owner, "events": events, "packets": packets,
		"packet_cursor": 0, "allocations": [], "resume_window": window.duplicate(true)}
	if packets.is_empty():
		state.last_drain_life = state.pending_drain_life.duplicate(true)
		state.pending_drain_life = {}
		return {"error": "", "complete": true, "message": "Drain Life resolved; no mortal wounds were caused."}
	_set_packet_window(state)
	var first: Dictionary = state.pending_drain_life.packets[0]
	return {"error": "", "complete": false, "message": "Player %d: allocate %d Drain Life mortal wounds to %s." % [first.owner, first.remaining, state.squads[first.target].name]}

static func allocation_choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get("pending_drain_life", {})
	if pending.is_empty() or state.get("unit_abilities", {}).get("window", {}).get("kind", "") != MORTAL_WINDOW: return []
	if int(pending.get("packet_cursor", -1)) >= pending.get("packets", []).size(): return []
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	if int(packet.get("owner", -1)) != player: return []
	var current := {"target": int(packet.target), "precision": -1, "groups": [], "order": []}
	var result: Array = []
	for model: int in Groups.current_models(state, current, true):
		result.append({"label": "Drain Life: allocate mortal wound to model %d (%d remaining)" % [model, packet.remaining],
			"action": ALLOCATE, "model": model, "target": int(packet.target), "value": MORTAL_WINDOW})
	return result

static func allocate(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in allocation_choices(state, player): return {"error": "Choose a living model in the affected unit to allocate the Drain Life mortal wound."}
	var pending: Dictionary = state.pending_drain_life
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
		for cenobyte: int in ChaplainGrimaldus.destroy_cenobytes(state, model): DetachmentStratagems.record_destroyed(state, cenobyte)
	if packet.remaining <= 0 or Geometry.alive(state, int(packet.target)).is_empty():
		if Geometry.alive(state, int(packet.target)).is_empty():
			packet.discarded = int(packet.remaining)
			packet.remaining = 0
		pending.packet_cursor = int(pending.packet_cursor) + 1
	_set_packet_window(state)
	if destroyed:
		var demise: Dictionary = DeadlyDemise.begin(state, [model], roller)
		if not str(demise.get("error", "")).is_empty(): return demise
		if not state.get("pending_deadly_demise", {}).is_empty(): return {"error": "", "message": demise.get("message", "Resolve the destruction effects.")}
		_set_packet_window(state)
	return {"error": "", "message": "Drain Life mortal wound allocated."}

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	match str(selected.get("action", "")):
		ACTION: return resolve(state, player, roller)
		ALLOCATE: return allocate(state, player, selected, roller)
	return {"error": "Unsupported Drain Life action."}

static func resume_after_nested_destruction(state: Dictionary) -> void:
	if not state.get("pending_drain_life", {}).is_empty() and state.get("pending_deadly_demise", {}).is_empty() and state.get("unit_abilities", {}).get("window", {}).get("kind", "") == MORTAL_WINDOW:
		_set_packet_window(state)

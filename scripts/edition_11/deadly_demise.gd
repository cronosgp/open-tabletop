extends RefCounted
## Deadly Demise chain resolution for destroyed models and per-unit mortal packets.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Prevention = preload("res://scripts/edition_11/wound_prevention.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const WINDOW := "deadly-demise-mortal"

static func begin(state: Dictionary, destroyed_models: Array[int], roller: Callable) -> Dictionary:
	var queue: Array[int] = []
	var transport_queue := TransportRules.passengers_of_destroyed(state, destroyed_models)
	for model: int in destroyed_models:
		if not state.units.has(model) or state.units[model].wounds > 0: continue
		if UnitAbilities.deadly_demise_value(state, model) == null: continue
		if model not in queue: queue.append(model)
	if queue.is_empty() and transport_queue.is_empty(): return {"error": "", "complete": true}
	state.pending_deadly_demise = {"queue": queue, "queue_cursor": 0, "packets": [], "packet_cursor": 0,
		"events": [], "allocations": [], "transport_queue": transport_queue, "transport_cursor": 0,
		"vengeful_animus_squads": {}, "vengeful_animus_declined": {},
		"resume_window": state.get("unit_abilities", {}).get("window", {}).duplicate(true)}
	return pump(state, roller)

static func _set_window(state: Dictionary) -> void:
	var pending: Dictionary = state.get("pending_deadly_demise", {})
	if pending.is_empty() or pending.packet_cursor >= pending.packets.size():
		state.unit_abilities.window = {}
		return
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(packet.owner)], "target": int(packet.target)}

static func pump(state: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = state.get("pending_deadly_demise", {})
	if pending.is_empty(): return {"error": "", "complete": true}
	while int(pending.get("transport_cursor", 0)) < pending.get("transport_queue", []).size():
		if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty(): return {"error": "", "complete": false, "message": "Resolve Emergency Disembark for the transport's passengers."}
		var passenger: Dictionary = pending.transport_queue[pending.transport_cursor]
		pending.transport_cursor = int(pending.transport_cursor) + 1
		if TransportRules.models(state, int(passenger.passenger_squad)).is_empty(): continue
		var error := TransportRules.begin_emergency(state, int(passenger.transport), int(passenger.passenger_squad), roller)
		if not error.is_empty(): return {"error": error}
		if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty():
			return {"error": "", "complete": false, "message": "Resolve Emergency Disembark for %s." % state.squads[int(passenger.passenger_squad)].name}
		pending = state.pending_deadly_demise
	for passenger: Dictionary in pending.get("transport_queue", []):
		var transport_model := int(passenger.transport)
		if state.units.has(transport_model) and int(state.units[transport_model].get("wounds", 1)) <= 0:
			state.units[transport_model].on_battlefield = false
	while true:
		while pending.packet_cursor < pending.packets.size():
			var packet: Dictionary = pending.packets[pending.packet_cursor]
			if int(packet.remaining) > 0 and not Geometry.alive(state, int(packet.target)).is_empty():
				_set_window(state)
				return {"error": "", "complete": false, "message": "Player %d: allocate %d Deadly Demise mortal wounds to %s." % [packet.owner, packet.remaining, state.squads[packet.target].name]}
			packet.discarded = int(packet.remaining)
			packet.remaining = 0
			pending.packet_cursor += 1
		pending = state.pending_deadly_demise
		pending.packets = []
		pending.packet_cursor = 0
		while pending.queue_cursor < pending.queue.size():
			var source: int = int(pending.queue[pending.queue_cursor])
			if not state.units.has(source) or state.units[source].wounds > 0:
				pending.queue_cursor += 1
				continue
			var source_squad := int(state.units[source].get("squad", -1))
			var squad_key := str(source_squad)
			if not pending.get("vengeful_animus_squads", {}).has(squad_key) and not pending.get("vengeful_animus_declined", {}).has(squad_key):
				var source_owner := int(state.units[source].get("owner", -1))
				state.unit_abilities.window = {"kind": DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW, "owners": [source_owner], "squad": source_squad, "source_model": source}
				if DetachmentStratagems.error(state, source_owner, source_squad, DetachmentStratagems.MEDUSA_VENGEFUL_ANIMUS).is_empty():
					return {"error": "", "complete": false, "message": "Player %d: Vengeful Animus may be used before rolling Deadly Demise for %s." % [source_owner, str(state.squads[source_squad].get("name", "the destroyed Vehicle"))]}
				state.unit_abilities.window = pending.get("resume_window", {}).duplicate(true)
			var forced := bool(pending.get("vengeful_animus_squads", {}).get(squad_key, false))
			pending.queue_cursor += 1
			var die: Variant = 6 if forced else (roller.call() if roller.is_valid() else null)
			if not die is int or die < 1 or die > 6: return {"error": "Deadly Demise requires a D6 result from 1 to 6."}
			var deadly_demise_value: Variant = UnitAbilities.deadly_demise_value(state, source)
			if deadly_demise_value == null: return {"error": "The destroyed model has no admitted Deadly Demise profile."}
			var event := {"source_model": source, "die": die, "expression": deadly_demise_value, "triggered": die == 6, "forced_by_vengeful_animus": forced, "targets": []}
			pending.events.append(event)
			if die != 6: continue
			for squad: int in state.squads:
				if Geometry.alive(state, squad).is_empty() or Geometry.distance_to_target(state, state.units[source], squad) > 6.001: continue
				var rolled := RandomStat.roll(deadly_demise_value, roller)
				if not rolled.error.is_empty(): return rolled
				var packet := {"source_model": source, "target": squad, "owner": state.squads[squad].owner,
					"roll": rolled, "remaining": int(rolled.value), "allocations": [], "discarded": 0}
				pending.packets.append(packet)
				event.targets.append({"squad": squad, "roll": rolled.duplicate(true), "mortal_wounds": int(rolled.value)})
			pending.events[pending.events.size() - 1] = event
			if not pending.packets.is_empty():
				pending.packet_cursor = 0
				_set_window(state)
				var first: Dictionary = pending.packets[0]
				return {"error": "", "complete": false, "message": "Player %d: allocate %d Deadly Demise mortal wounds to %s." % [first.owner, first.remaining, state.squads[first.target].name]}
		if pending.queue_cursor >= pending.queue.size():
			var finished := pending.duplicate(true)
			state.last_deadly_demise = finished
			state.pending_deadly_demise = {}
			state.unit_abilities.window = finished.resume_window
			if state.get("pending_attack", {}).is_empty(): UnitAbilities.open_destroyed_mark_replacements(state)
			return {"error": "", "complete": true, "message": "Deadly Demise resolved."}
	return {"error": "", "complete": true}

static func choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get("pending_deadly_demise", {})
	if pending.is_empty() or pending.packet_cursor >= pending.packets.size(): return []
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	if int(packet.owner) != player: return []
	var result: Array = []
	var current := {"target": int(packet.target), "precision": -1, "groups": [], "order": []}
	for model: int in Groups.current_models(state, current, true):
		result.append({"label": "Deadly Demise: allocate mortal wound to model %d (%d remaining)" % [model, packet.remaining],
			"action": "deadly-demise-allocate", "model": model, "target": packet.target, "value": WINDOW})
	return result

static func allocate(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose an eligible model in the affected unit to allocate the mortal wound."}
	var pending: Dictionary = state.pending_deadly_demise
	var packet: Dictionary = pending.packets[pending.packet_cursor]
	var model: int = int(selected.model)
	var prevention := Prevention.resolve(1, int(state.units[model].wounds), UnitPrevention.rules(state, model), "mortal", roller)
	if not prevention.error.is_empty(): return prevention
	state.units[model].wounds -= prevention.lost
	packet.allocations.append({"model": model, "prevention": prevention})
	packet.remaining -= 1
	if state.units[model].wounds <= 0:
		DetachmentStratagems.record_destroyed(state, model)
		if UnitAbilities.deadly_demise_value(state, model) != null and model not in pending.queue:
			pending.queue.append(model)
	pending.packets[pending.packet_cursor] = packet
	pending.allocations.append({"source_model": packet.source_model, "target_squad": packet.target, "model": model, "prevention": prevention})
	var pumped := pump(state, roller)
	if not pumped.error.is_empty(): return pumped
	if pumped.get("complete", false) and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true, "message": "Deadly Demise resolved; resume the attack sequence."}
	return {"error": "", "message": pumped.get("message", "Deadly Demise mortal wound allocated.")}

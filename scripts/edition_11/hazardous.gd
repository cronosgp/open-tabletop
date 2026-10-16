extends RefCounted
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

static func has_keyword(model: Dictionary, keyword: String) -> bool:
	for item: Variant in model.get("keywords", []):
		if str(item).to_upper() == keyword: return true
	return false

static func roll(state: Dictionary, squad: int, count: int, roller: Callable) -> Dictionary:
	var rolls: Array[int] = []
	for index in range(count):
		if not roller.is_valid(): return {"error": "Missing hazard dice provider."}
		var value: Variant = roller.call()
		if not value is int or value < 1 or value > 6: return {"error": "Hazard dice must be integers from 1 to 6."}
		rolls.append(value)
	return from_rolls(state, squad, rolls)

static func from_rolls(state: Dictionary, squad: int, rolls: Array) -> Dictionary:
	var alive := Geometry.alive(state, squad)
	var heavy := not alive.is_empty()
	for id: int in alive:
		if not has_keyword(state.units[id], "MONSTER") and not has_keyword(state.units[id], "VEHICLE"): heavy = false
	var failures := 0
	for value: Variant in rolls:
		if not value is int or value < 1 or value > 6: return {"error": "Hazard dice must be integers from 1 to 6."}
		if value <= 2: failures += 1
	return {"error": "", "rolls": rolls.duplicate(), "failures": failures, "total": failures * (3 if heavy else 1), "allocations": [], "discarded": 0}

static func eligible(state: Dictionary) -> Array[int]:
	if not state.get("stratagems", {}).get("pending", {}).is_empty(): return []
	var pending: Dictionary = state.get("pending_hazard", {})
	if pending.is_empty(): return []
	var groups: Array = [[], [], [], []]
	for id: int in Geometry.alive(state, pending.squad):
		var model: Dictionary = state.units[id]
		var priority := 2 if has_keyword(model, "CHARACTER") else 0
		if model.wounds == model.max_wounds: priority += 1
		groups[priority].append(id)
	var result: Array[int] = []
	for group: Array in groups:
		if not group.is_empty():
			result.assign(group)
			break
	return result

static func choice_error(state: Dictionary, player: int, model: int) -> String:
	if not state.get("stratagems", {}).get("pending", {}).is_empty(): return "Resolve the re-roll decision before allocating Hazardous."
	var pending: Dictionary = state.get("pending_hazard", {})
	if pending.is_empty(): return "No pending Hazardous wounds."
	if player != pending.player: return "The unit owner allocates Hazardous mortal wounds."
	if model not in eligible(state): return "Choose an eligible model in your unit; wounded non-characters have priority."
	return ""

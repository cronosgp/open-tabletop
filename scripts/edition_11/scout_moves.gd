extends RefCounted
## Pre-battle redeployment and Scout moves for admitted local e11 profiles.
const G = preload("res://scripts/edition_11/contact_movement.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const EPS := 0.001

static func begin(s: Dictionary) -> void:
	if not A.enabled(s):
		s.phase = "start_turn"
		return
	var redeploy_sources: Array[Dictionary] = []
	for owner in [int(s.get("first_player", 1)), 3 - int(s.get("first_player", 1))]:
		for squad: int in s.squads:
			if int(s.squads[squad].owner) == owner and A.has(s, squad, "strategium-command") and not G.alive(s, squad).is_empty():
				redeploy_sources.append({"owner": owner, "source": "strategium-command"})
				break
		for squad: int in s.squads:
			if int(s.squads[squad].owner) == owner and MarineEnhancements.active(s, squad, MarineEnhancements.CYBER_FAMILIAR):
				redeploy_sources.append({"owner": owner, "source": "cyber-familiar"})
				break
	if not redeploy_sources.is_empty():
		s.unit_abilities.strategium_used = {}
		s.unit_abilities.strategium_count = {}
		s.unit_abilities.cyber_familiar_used = {}
		s.unit_abilities.cyber_familiar_count = {}
		var current: Dictionary = redeploy_sources.pop_front()
		var queue: Array[int] = []
		var queue_sources: Array[String] = []
		for queued: Dictionary in redeploy_sources:
			queue.append(int(queued.owner))
			queue_sources.append(str(queued.source))
		s.unit_abilities.window = {"kind": "strategium-command", "owners": [int(current.owner)], "source": str(current.source), "queue": queue, "queue_sources": queue_sources}
		return
	_begin_scouts(s)

static func _begin_scouts(s: Dictionary) -> void:
	if not A.enabled(s): return
	var sides := {1: [], 2: []}
	for squad: int in s.squads:
		if A.scout_distance(s, squad) <= 0: continue
		if s.unit_abilities.reserves.has(squad):
			sides[s.squads[squad].owner].append(squad)
		elif _wholly_in_zone(s, squad):
			sides[s.squads[squad].owner].append(squad)
	for owner in [1, 2]: sides[owner].sort()
	var first := int(s.get("first_player", 1))
	var queue: Array[int] = []
	for index in range(maxi(sides[1].size(), sides[2].size())):
		for owner in [first, 3 - first]:
			if index < sides[owner].size(): queue.append(sides[owner][index])
	s.unit_abilities.scout_queue = queue
	_next(s)

static func actor(s: Dictionary) -> int:
	var w: Dictionary = s.get("unit_abilities", {}).get("window", {})
	return int(w.get("owners", [0])[0]) if w.get("kind", "") in ["scouts", "strategium-command"] else -1

static func choices(s: Dictionary, player: int) -> Array:
	var w: Dictionary = s.unit_abilities.get("window", {})
	if w.get("kind", "") == "strategium-command": return _strategium_choices(s, player, w)
	if w.get("kind", "") != "scouts" or int(w.owners[0]) != player: return []
	var squad: int = w.squad
	var rows: Array = []
	if w.reserved:
		rows.append({"label": "Set up %s in its deployment zone" % s.squads[squad].name, "action": "scout-setup", "model": -1, "target": squad, "value": ""})
	else:
		rows.append({"label": "Make a Scout move with %s" % s.squads[squad].name, "action": "scout-move", "model": -1, "target": squad, "value": ""})
	rows.append({"label": "Pass: do not use Scouts for %s" % s.squads[squad].name, "action": "scout-pass", "model": -1, "target": squad, "value": ""})
	if w.get("selected", false):
		rows = []
		for model: int in _living_models(s, squad): rows.append({"label": "Scout model %d: preview at X/Z" % model, "action": "scout-place", "model": model, "target": squad, "value": ""})
		rows.append({"label": "Confirm Scout positions", "action": "scout-confirm", "model": -1, "target": squad, "value": ""})
		rows.append({"label": "Cancel Scout preview", "action": "scout-cancel", "model": -1, "target": squad, "value": ""})
	return rows

static func apply(s: Dictionary, action: String, model: int, squad: int, point: Vector2) -> String:
	var w: Dictionary = s.unit_abilities.window
	if w.get("kind", "") == "strategium-command": return _apply_strategium(s, action, model, squad, point, w)
	if w.get("kind", "") != "scouts" or int(w.squad) != squad: return "No matching Scout move is pending."
	match action:
		"scout-pass": _next(s)
		"scout-move", "scout-setup":
			if action == "scout-setup" and not w.reserved: return "This unit is not in Strategic Reserves."
			if action == "scout-move" and w.reserved: return "A unit in Strategic Reserves must use Scout set-up."
			w.selected = true
			w.setup = action == "scout-setup"
			w.origins = {}
			w.positions = {}
			for id: int in _living_models(s, squad):
				w.origins[id] = s.units[id].position
				w.positions[id] = s.units[id].position
		"scout-place":
			var err := position_error(s, model, point)
			if not err.is_empty(): return err
			w.positions[model] = point
		"scout-cancel":
			w.selected = false
			w.positions = {}
		"scout-confirm":
			var projected := s.duplicate(true)
			for id: int in w.positions:
				projected.units[id].position = w.positions[id]
				projected.units[id].on_battlefield = true
			if not G.coherent(projected, squad): return "Scout move must leave the unit in coherency."
			for id: int in w.positions:
				var err := position_error(s, id, w.positions[id])
				if not err.is_empty(): return err
			for id: int in w.positions:
				s.units[id].position = w.positions[id]
				s.units[id].on_battlefield = true
			s.unit_abilities.reserves.erase(squad)
			s.squads[squad].moved = not w.setup
			s.squads[squad].move_type = "scout" if not w.setup else "scout-setup"
			_next(s)
		_:
			return "Unknown Scout action."
	return ""

static func position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var w: Dictionary = s.unit_abilities.window
	if not point.is_finite() or not w.positions.has(model): return "Select a living model in the pending Scout unit."
	var u: Dictionary = s.units[model]
	var radius := float(u.radius)
	var half: Vector2 = s.board_size / 2.0
	if absf(point.x) + radius > half.x + EPS or absf(point.y) + radius > half.y + EPS: return "The whole base must remain on the battlefield."
	if w.setup:
		var zone: Rect2 = s.deployment.zones[u.owner]
		if point.x - radius < zone.position.x - EPS or point.x + radius > zone.end.x + EPS or point.y - radius < zone.position.y - EPS or point.y + radius > zone.end.y + EPS: return "Scout set-up must be wholly within your deployment zone."
	else:
		if Vector2(w.origins[model]).distance_to(point) > float(A.scout_distance(s, u.squad)) + EPS: return "This model cannot move more than its Scouts distance."
	var projected := s.duplicate(true)
	projected.units[model].position = point
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0: continue
		var o: Dictionary = s.units[other]
		var other_point: Vector2 = w.positions.get(other, o.position)
		if o.owner != u.owner and not o.get("on_battlefield", true): continue
		if other_point.distance_to(point) < radius + float(o.radius) - EPS: return "Scout positions cannot overlap another model."
		if o.owner != u.owner and other_point.distance_to(point) - radius - float(o.radius) <= 8.0 + EPS: return "Scout moves and set-ups must finish more than 8 inches from every enemy unit."
	if not w.setup:
		var err := Terrain.path_error(projected, model, point)
		if not err.is_empty(): return err
	return ""

static func _wholly_in_zone(s: Dictionary, squad: int) -> bool:
	if not s.get("deployment", {}).get("zones", {}).has(s.squads[squad].owner): return false
	var zone: Rect2 = s.deployment.zones[s.squads[squad].owner]
	var ids := G.alive(s, squad)
	if ids.is_empty(): return false
	for id: int in ids:
		var u: Dictionary = s.units[id]
		if not u.get("on_battlefield", true): return false
		var r := float(u.radius)
		if u.position.x - r < zone.position.x - EPS or u.position.x + r > zone.end.x + EPS or u.position.y - r < zone.position.y - EPS or u.position.y + r > zone.end.y + EPS: return false
	return true

static func _next(s: Dictionary) -> void:
	var queue: Array = s.unit_abilities.get("scout_queue", [])
	if not queue.is_empty():
		var squad: int = queue.pop_front()
		s.unit_abilities.scout_queue = queue
		s.unit_abilities.window = {"kind": "scouts", "owners": [s.squads[squad].owner], "squad": squad, "reserved": s.unit_abilities.reserves.has(squad), "selected": false}
		return
	s.unit_abilities.window = {}
	s.phase = "start_turn"

static func _strategium_choices(s: Dictionary, player: int, w: Dictionary) -> Array:
	if w.get("owners", []) != [player]: return []
	var source := str(w.get("source", "strategium-command"))
	var source_label := _redeploy_label(source)
	var used := _redeploy_used(s, source, player)
	var count := _redeploy_count(s, source, player)
	if w.get("selected", false):
		var selected_squad := int(w.get("squad", -1))
		if w.get("mode", "") == "place":
			var result: Array = []
			for model: int in _living_models(s, selected_squad): result.append({"label": "%s: preview model %d" % [source_label, model], "action": "strategium-place", "model": model, "target": selected_squad, "value": ""})
			result.append({"label": "Confirm redeployment of %s" % s.squads[selected_squad].name, "action": "strategium-confirm", "model": -1, "target": selected_squad, "value": ""})
			result.append({"label": "Cancel this redeployment" , "action": "strategium-cancel", "model": -1, "target": selected_squad, "value": ""})
			return result
		var selected_choices: Array = [
			{"label": "%s: redeploy %s using normal set-up rules" % [source_label, s.squads[selected_squad].name], "action": "strategium-redeploy", "model": -1, "target": selected_squad, "value": ""}
		]
		if int(s.squads[selected_squad].get("training_cost", 0)) > 0:
			selected_choices.append({"label": "%s: place %s in Strategic Reserves (ignore the normal limit)" % [source_label, s.squads[selected_squad].name], "action": "strategium-reserve", "model": -1, "target": selected_squad, "value": ""})
		selected_choices.append({"label": "Cancel unit selection", "action": "strategium-cancel", "model": -1, "target": selected_squad, "value": ""})
		return selected_choices
	var choices: Array = []
	if count < 3:
		for target: int in s.squads:
			if target in used or int(s.squads[target].owner) != player or not _redeploy_target(s, target, source): continue
			choices.append({"label": "%s: select %s" % [source_label, s.squads[target].name], "action": "strategium-select", "model": -1, "target": target, "value": ""})
	choices.append({"label": "Finish %s" % source_label, "action": "strategium-finish", "model": -1, "target": -1, "value": ""})
	return choices

static func _apply_strategium(s: Dictionary, action: String, model: int, squad: int, point: Vector2, w: Dictionary) -> String:
	if w.get("owners", []).is_empty(): return "%s has no active player." % _redeploy_label(str(w.get("source", "strategium-command")))
	var owner := int(w.owners[0])
	var source := str(w.get("source", "strategium-command"))
	var source_label := _redeploy_label(source)
	if action == "strategium-finish":
		var queue: Array = w.get("queue", []).duplicate(true)
		var queue_sources: Array = w.get("queue_sources", []).duplicate(true)
		if queue.is_empty():
			s.unit_abilities.window = {}
			_begin_scouts(s)
		else:
			var next_owner := int(queue.pop_front())
			var next_source := str(queue_sources.pop_front()) if not queue_sources.is_empty() else "strategium-command"
			w.queue = queue
			w.queue_sources = queue_sources
			w.owners = [next_owner]
			w.source = next_source
			w.erase("selected")
			w.erase("squad")
			w.erase("mode")
		return ""
	if action == "strategium-select":
		if w.get("selected", false) or not _redeploy_target(s, squad, source) or int(s.squads[squad].owner) != owner: return "Select an eligible deployed friendly unit for %s." % source_label
		var used := _redeploy_used(s, source, owner)
		if squad in used or _redeploy_count(s, source, owner) >= 3: return "%s can select up to three different units." % source_label
		w.selected = true
		w.squad = squad
		w.mode = "choice"
		w.before = _strategium_snapshot(s, squad)
		return ""
	if not w.get("selected", false) or int(w.get("squad", -1)) != squad: return "No matching %s unit is selected." % source_label
	if action == "strategium-cancel":
		if w.get("mode", "") == "place":
			_restore_strategium_snapshot(s, squad, w.get("before", {}))
			w.erase("positions")
			w.erase("origins")
			w.mode = "choice"
		else:
			w.erase("selected")
			w.erase("squad")
			w.erase("mode")
		return ""
	if action == "strategium-reserve":
		if not _redeploy_target(s, squad, source) or int(s.squads[squad].owner) != owner: return "This unit is no longer eligible for %s." % source_label
		var cost := int(s.squads[squad].get("training_cost", 0))
		if cost <= 0: return "The selected unit has no local reserve points cost."
		var deep_strike := A.every_model_has(s, squad, "deep-strike")
		_detach_strategium_unit(s, squad)
		s.unit_abilities.reserves[squad] = {"cost": cost, "source": source, "bypass_limit": true, "deep_strike": deep_strike}
		for id: int in _living_models(s, squad): s.units[id].on_battlefield = false
		_finish_strategium_unit(s, owner, squad, source)
		return ""
	if action == "strategium-redeploy":
		if not _redeploy_target(s, squad, source) or int(s.squads[squad].owner) != owner: return "This unit is no longer eligible for %s." % source_label
		s.unit_abilities.reserves.erase(squad)
		_detach_strategium_unit(s, squad)
		for id: int in _living_models(s, squad): s.units[id].on_battlefield = true
		w.mode = "place"
		w.origins = {}
		w.positions = {}
		for id: int in _living_models(s, squad): w.origins[id] = s.units[id].position; w.positions[id] = s.units[id].position
		return ""
	if action == "strategium-place":
		var err := strategium_position_error(s, model, point)
		if not err.is_empty(): return err
		w.positions[model] = point
		return ""
	if action == "strategium-confirm":
		var projected := s.duplicate(true)
		for id: int in w.positions: projected.units[id].position = w.positions[id]
		if not G.coherent(projected, squad): return "Redeployed unit must be in coherency."
		for id: int in w.positions:
			var err := strategium_position_error(s, id, w.positions[id])
			if not err.is_empty(): return err
		for id: int in w.positions: s.units[id].position = w.positions[id]
		_finish_strategium_unit(s, owner, squad, source)
		return ""
	return "Unknown %s action." % source_label

static func _finish_strategium_unit(s: Dictionary, owner: int, squad: int, source: String = "strategium-command") -> void:
	var used_key := _redeploy_used_key(source)
	var count_key := _redeploy_count_key(source)
	var used: Dictionary = s.unit_abilities.get(used_key, {}).duplicate(true)
	var list: Array = used.get(owner, [])
	list.append(squad)
	used[owner] = list
	s.unit_abilities[used_key] = used
	var count: Dictionary = s.unit_abilities.get(count_key, {}).duplicate(true)
	count[owner] = int(count.get(owner, 0)) + 1
	s.unit_abilities[count_key] = count
	var w: Dictionary = s.unit_abilities.window
	w.erase("selected")
	w.erase("squad")
	w.erase("mode")
	w.erase("positions")
	w.erase("origins")
	if int(count[owner]) >= 3:
		var queue: Array = w.get("queue", []).duplicate(true)
		var queue_sources: Array = w.get("queue_sources", []).duplicate(true)
		if queue.is_empty(): s.unit_abilities.window = {}; _begin_scouts(s)
		else:
			var next_owner := int(queue.pop_front())
			var next_source := str(queue_sources.pop_front()) if not queue_sources.is_empty() else "strategium-command"
			w.owners = [next_owner]
			w.source = next_source
			w.queue = queue
			w.queue_sources = queue_sources

static func _redeploy_target(s: Dictionary, squad: int, source: String) -> bool:
	if not s.squads.has(squad) or G.alive(s, squad).is_empty() or s.get("unit_abilities", {}).get("reserves", {}).has(squad) or TransportRules.squad_embarked(s, squad): return false
	var has_astartes := false
	var has_infantry := false
	for model: int in G.alive(s, squad):
		var unit: Dictionary = s.units[model]
		if not unit.get("on_battlefield", true): return false
		var keywords: Array = unit.get("keywords", [])
		if "ADEPTUS ASTARTES" in keywords: has_astartes = true
		if "INFANTRY" in keywords: has_infantry = true
	return has_astartes and (source != "cyber-familiar" or has_infantry)

static func _redeploy_label(source: String) -> String:
	return "Cyber-familiar" if source == "cyber-familiar" else "Strategium Command"

static func _redeploy_used_key(source: String) -> String:
	return "cyber_familiar_used" if source == "cyber-familiar" else "strategium_used"

static func _redeploy_count_key(source: String) -> String:
	return "cyber_familiar_count" if source == "cyber-familiar" else "strategium_count"

static func _redeploy_used(s: Dictionary, source: String, player: int) -> Array:
	return s.get("unit_abilities", {}).get(_redeploy_used_key(source), {}).get(player, [])

static func _redeploy_count(s: Dictionary, source: String, player: int) -> int:
	return int(s.get("unit_abilities", {}).get(_redeploy_count_key(source), {}).get(player, 0))

static func _strategium_snapshot(s: Dictionary, squad: int) -> Dictionary:
	var models := {}
	for id: int in _living_models(s, squad):
		models[id] = {"position": s.units[id].position, "on_battlefield": s.units[id].get("on_battlefield", true), "embarked_transport": s.units[id].get("embarked_transport", -1)}
	return {"models": models, "reserve": s.unit_abilities.reserves.get(squad, {}).duplicate(true), "had_reserve": s.unit_abilities.reserves.has(squad), "embarked_in": s.squads[squad].get("embarked_in", -1), "had_embarked_in": s.squads[squad].has("embarked_in")}

static func _restore_strategium_snapshot(s: Dictionary, squad: int, snapshot: Dictionary) -> void:
	if snapshot.is_empty(): return
	for raw_id: Variant in snapshot.get("models", {}):
		var id := int(raw_id)
		if not s.units.has(id): continue
		var before: Dictionary = snapshot.models[raw_id]
		s.units[id].position = before.position
		s.units[id].on_battlefield = before.on_battlefield
		if int(before.embarked_transport) >= 0: s.units[id].embarked_transport = int(before.embarked_transport)
		else: s.units[id].erase("embarked_transport")
	if snapshot.get("had_reserve", false): s.unit_abilities.reserves[squad] = snapshot.reserve.duplicate(true)
	else: s.unit_abilities.reserves.erase(squad)
	if snapshot.get("had_embarked_in", false): s.squads[squad].embarked_in = snapshot.embarked_in
	else: s.squads[squad].erase("embarked_in")

static func _detach_strategium_unit(s: Dictionary, squad: int) -> void:
	for id: int in _living_models(s, squad): s.units[id].erase("embarked_transport")
	s.squads[squad].erase("embarked_in")
	s.squads[squad].erase("embarked_this_turn")

static func strategium_position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var w: Dictionary = s.unit_abilities.window
	if not point.is_finite() or not w.get("positions", {}).has(model): return "Select a living model in the selected unit."
	var unit: Dictionary = s.units[model]
	var radius := float(unit.radius)
	var half: Vector2 = s.board_size / 2.0
	if absf(point.x) + radius > half.x + EPS or absf(point.y) + radius > half.y + EPS: return "The whole base must remain on the battlefield."
	var zone: Rect2 = s.deployment.zones[unit.owner]
	var infiltrator := Terrain.Detection.infiltrators(s, int(unit.squad))
	if not infiltrator and (point.x - radius < zone.position.x - EPS or point.x + radius > zone.end.x + EPS or point.y - radius < zone.position.y - EPS or point.y + radius > zone.end.y + EPS): return "Redeployment must follow the normal deployment-zone restrictions."
	var projected := s.duplicate(true)
	projected.units[model].position = point
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0: continue
		var other_model: Dictionary = s.units[other]
		var other_point: Vector2 = w.get("positions", {}).get(other, other_model.position)
		if other_model.squad == unit.squad: continue
		if other_model.owner != unit.owner and not other_model.get("on_battlefield", true): continue
		if point.distance_to(other_point) < radius + float(other_model.radius) - EPS: return "Redeployed models cannot overlap another model."
		if other_model.owner != unit.owner and point.distance_to(other_point) - radius - float(other_model.radius) <= 2.0 + EPS: return "Redeployed units must be set up unengaged."
		if infiltrator and other_model.owner != unit.owner and point.distance_to(other_point) - radius - float(other_model.radius) <= 8.0 + EPS: return "Infiltrators must remain more than 8 inches from every enemy unit."
	if infiltrator:
		var enemy_zone: Rect2 = s.deployment.zones[3 - int(unit.owner)]
		if point.distance_to(point.clamp(enemy_zone.position, enemy_zone.end)) - radius <= 8.0 + EPS: return "Infiltrators must remain more than 8 inches from the enemy deployment zone."
	return Terrain.path_error(projected, model, point)

static func _living_models(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in s.units:
		if s.units[model].squad == squad and s.units[model].wounds > 0: result.append(model)
	return result


extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## September 2026 faction rule, scoped to admitted core profiles and Overlord attachments.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Board = preload("res://scripts/rules.gd")
const ID := "reanimation-core-profiles-september-2026-v2"
const SOURCE := "https://assets.warhammer-community.com/eng_30-09_wh40k_faction_pack_necrons-1urphgbmpy-wbhocjbaba.pdf"
const TROOPS := ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:immortals"]
const OVERLORD := "40kdc:11e:necrons:overlord"
const WARDEN := "40kdc:11e:necrons:royal-warden"
const EPSILON := 0.001

static func necron_army(state: Dictionary, owner: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.owner != owner: continue
		if not str(model.get("definition_id", "")).begins_with("40kdc:11e:necrons:"): return false
		found = true
	return found

static func supported_unit(state: Dictionary, squad: int) -> bool:
	if state.squads[squad].get("attached", false): return _supported_attachment(state, squad)
	var identity := ""
	var models := 0
	for unit: Dictionary in state.units.values():
		if unit.squad != squad: continue
		if identity.is_empty(): identity = str(unit.get("definition_id", ""))
		if identity != unit.get("definition_id", "") or identity not in TROOPS + [OVERLORD, WARDEN]: return false
		if unit.get("elevation", 0.0) != 0.0: return false
		if identity in TROOPS and unit.max_wounds != 1: return false
		models += 1
	return models > 0 and (identity not in [OVERLORD, WARDEN] or models == 1)

# One Character and one 1W troop component: healing order has no ambiguous
# wounded-model choice. Retain the original unit and its combined strength (19).
static func _supported_attachment(state: Dictionary, squad: int) -> bool:
	var components: Array = state.squads[squad].get("components", [])
	if components.size() != 2: return false
	var troop_identity := ""
	var leader_count := 0
	var troop_count := 0
	for unit: Dictionary in state.units.values():
		if unit.squad != squad: continue
		if unit.owner != state.squads[squad].owner or unit.get("elevation", 0.0) != 0.0: return false
		var identity: String = unit.get("definition_id", "")
		if unit.get("attachment_role", "") == "leader":
			if identity not in [OVERLORD, WARDEN] or unit.max_wounds != (6 if identity == OVERLORD else 4): return false
			leader_count += 1
		elif unit.get("attachment_role", "") == "bodyguard":
			if identity not in TROOPS or unit.max_wounds != 1: return false
			if troop_identity.is_empty(): troop_identity = identity
			if identity != troop_identity: return false
			troop_count += 1
		else: return false
	return leader_count == 1 and troop_count > 0 and state.squads[squad].starting_strength == troop_count + leader_count

static func enable(state: Dictionary) -> void:
	state.reanimation = {"implementation": ID, "done_turn": {}, "morale_turn": -1, "command_turn": -1, "anchors": {}, "pending": {}, "last_results": []}
	Capabilities.admit(state, "reanimation-protocols", ID)
	for squad: int in state.squads:
		if necron_army(state, state.squads[squad].owner) and supported_unit(state, squad): Capabilities.admit_squad(state, squad, "reanimation-protocols")

static func enabled(state: Dictionary) -> bool:
	return state.get("reanimation", {}).get("implementation", "") == ID

static func pending(state: Dictionary) -> Dictionary:
	return state.get("reanimation", {}).get("pending", {})

static func start_command(state: Dictionary) -> void:
	if not enabled(state): return
	state.reanimation.command_turn = state.turn
	state.reanimation.anchors = {}
	for squad: int in state.squads:
		if state.squads[squad].owner == state.active: state.reanimation.anchors[squad] = Geometry.alive(state, squad)

static func phase_error(state: Dictionary) -> String:
	if not enabled(state) or not necron_army(state, state.active) or state.reanimation.done_turn.get(state.active, -1) == state.turn: return ""
	if state.reanimation.command_turn != state.turn: return "Missing Command-entry snapshot for Reanimation Protocols."
	for squad: int in state.squads:
		if state.squads[squad].owner != state.active or Geometry.alive(state, squad).is_empty(): continue
		if not supported_unit(state, squad): return "Reanimation currently supports Warriors, Immortals, single-model Overlords and their admitted attachments; other wound profiles are blocked."
	return ""

static func morale_done(state: Dictionary) -> bool:
	return enabled(state) and state.reanimation.morale_turn == state.turn

static func open_end_command(state: Dictionary) -> bool:
	if not enabled(state) or not necron_army(state, state.active) or state.reanimation.done_turn.get(state.active, -1) == state.turn: return false
	var squads: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == state.active and not Geometry.alive(state, squad).is_empty(): squads.append(squad)
	squads.sort()
	state.reanimation.morale_turn = state.turn
	if squads.is_empty():
		state.reanimation.done_turn[state.active] = state.turn
		return false
	state.reanimation.pending = {"player": state.active, "turn": state.turn, "remaining": squads, "current": {}, "results": []}
	return true

static func choice_error(state: Dictionary, player: int, revision: int) -> String:
	var window := pending(state)
	if window.is_empty(): return "No Reanimation Protocols decision is pending."
	if revision != state.revision: return "State changed; synchronize before resolving Reanimation."
	if window.turn != state.turn or player != window.player or (window.get("kind", "") not in ["orb", "undying"] and (state.phase != "command" or player != state.active)): return "This Reanimation decision belongs to the active Necron player."
	if state.get("test_winner", 0) != 0: return "The match has ended."
	return ""

static func returnable(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty() or current.get("reroll_pending", false): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.squad == current.squad and unit.wounds == 0 and unit.definition_id in TROOPS: result.append(model)
	result.sort()
	return result

static func roll_unit(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	var window := pending(state)
	if not window.current.is_empty() or squad not in window.remaining: return {"error": "Select an unresolved unit before rolling its Reanimation."}
	if not supported_unit(state, squad) or Geometry.alive(state, squad).is_empty(): return {"error": "That unit is no longer eligible for Reanimation."}
	if not roller.is_valid(): return {"error": "Reanimation requires the host's D6 provider."}
	var raw: Variant = roller.call()
	if not raw is int or raw < 1 or raw > 6: return {"error": "Reanimation dice must be integers from 1 to 6."}
	if UnitAbilities.has(state, squad, "their-number-is-legion"):
		window.current = {"squad": squad, "raw_roll": raw, "reroll_pending": true, "placements": {}, "unplaced": []}
		return {"error": "", "message": "Their Number is Legion: accept this roll or re-roll once before assigning healing."}
	return _prepare_healing(state, squad, raw)

static func accept_roll(state: Dictionary, reroll: bool, roller: Callable) -> Dictionary:
	var current: Dictionary = pending(state).get("current", {})
	if not current.get("reroll_pending", false): return {"error": "No Legion roll decision is pending."}
	var raw: int = current.raw_roll
	if reroll:
		if not roller.is_valid(): return {"error": "Host dice provider required."}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "Invalid host D6."}
		raw = rolled
	return _prepare_healing(state, current.squad, raw)

static func _prepare_healing(state: Dictionary, squad: int, raw: int) -> Dictionary:
	var window := pending(state)
	var budget := raw if window.get("kind", "") == "orb" else ceili(float(raw) / 2.0)
	if window.get("kind", "") == "undying" and window.get("led", false): budget += 1
	var healed: Dictionary = {}
	var remaining := budget
	for model: int in Geometry.alive(state, squad):
		var lost: int = state.units[model].max_wounds - state.units[model].wounds
		if lost > 0:
			var amount := mini(remaining, lost)
			if amount > 0: healed[model] = amount
			remaining -= amount
	var engaged: Array[int] = []
	for target: int in state.squads:
		if state.squads[target].owner == window.player: continue
		for model: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target(state, state.units[model], target) <= 2.0 + EPSILON:
				engaged.append(target)
				break
	window.current = {"squad": squad, "raw_roll": raw, "budget": budget, "healing_die": "D6" if window.get("kind", "") == "orb" else "D3", "healed": healed, "placements": {}, "unplaced": [], "engaged": engaged, "anchors": state.reanimation.anchors.get(squad, []).duplicate()}
	window.current.slots = mini(remaining, returnable(state).size())
	if window.current.slots == 0: return confirm_unit(state)
	return {"error": "", "message": "%s: Reanimation D6 %d becomes %s %d. Preview %d returned models, then confirm." % [state.squads[squad].name, raw, window.current.healing_die, budget, window.current.slots]}

static func projected(state: Dictionary) -> Dictionary:
	var copy := state.duplicate(true)
	var current: Dictionary = pending(state).get("current", {})
	for model: int in current.get("placements", {}):
		copy.units[model].wounds = 1
		copy.units[model].position = current.placements[model]
	return copy

static func position_error(state: Dictionary, model: int, destination: Vector2) -> String:
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty() or model not in returnable(state): return "Choose a destroyed troop model from the active Reanimation unit."
	if model in current.unplaced: return "Reset this preview before placing a model already declared unplaceable."
	if not current.placements.has(model) and current.placements.size() + current.unplaced.size() >= current.slots: return "The D3 healing budget is already assigned."
	if not destination.is_finite(): return "Choose a finite base-centre position."
	var unit: Dictionary = state.units[model]
	var radius: float = unit.radius
	var half := Board.half_board(state)
	if absf(destination.x) + radius > half.x + EPSILON or absf(destination.y) + radius > half.y + EPSILON: return "The returned model's whole base must fit on the battlefield."
	var copy := projected(state)
	copy.units[model].wounds = 1
	copy.units[model].position = destination
	var anchor_near := false
	for anchor: int in current.anchors:
		if state.units[anchor].wounds > 0 and Geometry.edge(copy.units[model], state.units[anchor]) <= 2.0 + EPSILON: anchor_near = true
	if not anchor_near: return "Return within 2 inches of a surviving model that was on the battlefield at Command entry; returned models cannot extend this anchor chain."
	for other: int in copy.units:
		if other == model or copy.units[other].wounds <= 0 or not copy.units[other].get("on_battlefield", true): continue
		var distance := Geometry.edge(copy.units[model], copy.units[other])
		if destination.distance_to(copy.units[other].position) < radius + float(copy.units[other].radius) - EPSILON: return "Returned bases cannot overlap another living or previewed model."
		if copy.units[other].squad == current.squad and distance > 9.0 + EPSILON: return "Keep the returned model within 9 inches of every model in its unit."
		if copy.units[other].owner != unit.owner and distance <= 2.0 + EPSILON and copy.units[other].squad not in current.engaged: return "A return cannot create engagement with a new enemy unit."
	# A return is a setup, not a movement path: only test the endpoint.
	return Terrain.path_error(copy, model, destination)

static func place_model(state: Dictionary, model: int, destination: Vector2) -> Dictionary:
	var error := position_error(state, model, destination)
	if not error.is_empty(): return {"error": error}
	pending(state).current.placements[model] = destination
	return {"error": "", "message": "Reanimation model %d previewed; confirm the unit to restore its wound." % model}

static func declare_unplaceable(state: Dictionary, model: int) -> Dictionary:
	var current: Dictionary = pending(state).current
	if current.is_empty() or model not in returnable(state) or model in current.unplaced: return {"error": "Choose a destroyed troop model that has not already been declared unplaceable."}
	if not current.placements.has(model) and current.placements.size() + current.unplaced.size() >= current.slots: return {"error": "All return attempts are already assigned."}
	current.placements.erase(model)
	current.unplaced.append(model)
	return {"error": "", "message": "Controller declares model %d cannot be placed. It remains destroyed; this failed return will be recorded." % model}

static func reset_preview(state: Dictionary) -> Dictionary:
	var current: Dictionary = pending(state).current
	if current.is_empty() or current.get("reroll_pending", false): return {"error": "Resolve the roll decision before resetting a placement preview."}
	current.placements = {}
	current.unplaced = []
	return {"error": "", "message": "Reanimation preview reset; original D3 and healing budget retained."}

static func suggest(state: Dictionary) -> Dictionary:
	if pending(state).current.is_empty() or pending(state).current.get("reroll_pending", false): return {"error": "Resolve the roll decision before suggesting return positions."}
	var working := state.duplicate(true)
	var current: Dictionary = pending(working).current
	for model: int in returnable(working):
		if current.placements.size() + current.unplaced.size() >= current.slots: break
		if current.placements.has(model) or model in current.unplaced: continue
		var points: Array[Vector2] = [working.units[model].position]
		for anchor: int in current.anchors:
			if working.units[anchor].wounds <= 0: continue
			for gap in [0.1, 0.7, 1.3, 1.9]:
				for direction in range(24):
					var offset: Vector2 = Vector2.RIGHT.rotated(direction * TAU / 24.0) * (float(working.units[anchor].radius) + float(working.units[model].radius) + float(gap))
					points.append(working.units[anchor].position + offset)
		var found := false
		for point: Vector2 in points:
			if position_error(working, model, point).is_empty():
				current.placements[model] = point
				found = true
				break
		if not found: return {"error": "No complete suggestion found. Place models manually or record a controller-declared inability to place; the search is not exhaustive."}
	state.reanimation.pending.current.placements = current.placements.duplicate()
	return {"error": "", "message": "Suggested return positions are previews; review and confirm the unit."}

static func confirm_error(state: Dictionary) -> String:
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty(): return "Roll a unit's Reanimation first."
	if current.get("reroll_pending", false): return "Accept or re-roll Their Number is Legion first."
	if current.placements.size() + current.unplaced.size() != current.slots: return "Place each available returned model or explicitly record an inability to place it."
	for model: int in current.placements:
		var error := position_error(state, model, current.placements[model])
		if not error.is_empty(): return error
	if not current.placements.is_empty() and not Geometry.coherent(projected(state), current.squad): return "Returned models must leave the unit in coherency."
	return ""

static func confirm_unit(state: Dictionary) -> Dictionary:
	var error := confirm_error(state)
	if not error.is_empty(): return {"error": error}
	var window := pending(state)
	var current: Dictionary = window.current
	var restored := 0
	for model: int in current.healed:
		state.units[model].wounds += int(current.healed[model])
		restored += int(current.healed[model])
	for model: int in current.placements:
		state.units[model].wounds = 1
		state.units[model].position = current.placements[model]
		restored += 1
	var report := {"squad": current.squad, "raw_roll": current.raw_roll, "budget": current.budget, "healed": current.healed.duplicate(), "returned": current.placements.duplicate(), "unplaced": current.unplaced.duplicate(), "discarded": current.budget - restored}
	window.results.append(report)
	window.remaining.erase(current.squad)
	window.current = {}
	if window.remaining.is_empty():
		state.reanimation.last_results = window.results.duplicate(true)
		if window.get("kind", "") != "undying": state.reanimation.done_turn[window.player] = state.turn
		state.reanimation.pending = {}
	return {"error": "", "message": "%s: Reanimation restored %d wounds, returned %d models; %d healing unused, %d controller-declared placement failures." % [state.squads[current.squad].name, restored, current.placements.size(), report.discarded, current.unplaced.size()]}

extends RefCounted
## A2 selected mission, CA 2026-27. No army/points certification.
const T = preload("res://scripts/edition_11/terrain.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const ID := "ca-2026-27-dominance-hammer-fixed-v1"
const DEFAULT_TERRAIN_LAYOUT := "ca-2026-27-take-and-hold-mirror-a-v1"
const SIZE := Vector2(60, 44)
const PRIMARY_MISSIONS := {
	"battlefield-dominance": {"name": "Battlefield Dominance", "force_disposition": "Take and Hold"},
	"meatgrinder": {"name": "Meatgrinder", "force_disposition": "Purge the Foe"},
	"reconnaissance-sweep": {"name": "Reconnaissance Sweep", "force_disposition": "Reconnaissance"},
	"secure-asset": {"name": "Secure Asset", "force_disposition": "Priority Assets"}
}

static func enabled(s: Dictionary) -> bool:
	return s.get("mission", {}).get("id", "") == ID

static func enable(s: Dictionary, terrain_layout: String = DEFAULT_TERRAIN_LAYOUT, primary_id: String = "battlefield-dominance") -> void:
	if not T.is_event_layout(terrain_layout): terrain_layout = DEFAULT_TERRAIN_LAYOUT
	if not PRIMARY_MISSIONS.has(primary_id): primary_id = "battlefield-dominance"
	var primary: Dictionary = PRIMARY_MISSIONS[primary_id]
	s.board_size = SIZE
	s.test_battlefield = ID
	s.battle_size = "Incursion - CA 2026-27 (reference lists)"
	s.first_player = 1
	s.mission = {"id": ID, "primary_id": primary_id, "name": primary.name, "deployment": "Hammer and Anvil", "force_disposition": primary.force_disposition, "terrain_layout": terrain_layout, "secondary_mode": "fixed", "secondary_cards": ["engage-on-all-fronts", "assassination"], "rounds": 5, "stage": "terrain", "roll_winner": 0, "attacker": 0, "defender": 0, "battle_ready": {}, "objectives": [], "actions": ["secure-asset"] if primary_id == "secure-asset" else [], "scores": {1: 0, 2: 0}, "primary": {1: 0, 2: 0}, "secondary": {1: 0, 2: 0}, "cards": {1: {"engage-on-all-fronts": 0, "assassination": 0}, 2: {"engage-on-all-fronts": 0, "assassination": 0}}, "round_points": {}, "scored": [], "dead_characters": [], "log": [], "turn_start_alive": {1: [], 2: []}, "turn_start_central": {1: [], 2: []}, "last_turn_losses": {1: 0, 2: 0}, "asset_secured_turn": {1: -1, 2: -1}}
	terrain(s, false, terrain_layout)
	Registry.admit(s, "ca-dominance-hammer-fixed", ID)

static func terrain(s: Dictionary, two: bool, terrain_layout: String = DEFAULT_TERRAIN_LAYOUT) -> void:
	var areas: Array = []
	var objectives: Array = []
	var points := [{"name": "Attacker home", "point": Vector2(-16, -12), "role": "attacker"}, {"name": "Defender home", "point": Vector2(16, 12), "role": "defender"}, {"name": "North expansion", "point": Vector2(-6, 14), "role": "expansion"}, {"name": "South expansion", "point": Vector2(6, -14), "role": "expansion"}]
	for y in [-6, 6] if two else [0]: points.append({"name": "Central %d" % (y + 6), "point": Vector2(0, y), "role": "central"})
	for point: Dictionary in points:
		var bounds := Rect2(point.point - Vector2(3, 2), Vector2(6, 4))
		# Agreed custom ground-level terrain covering each official objective point.
		areas.append({"name": point.name, "category": "light", "bounds": bounds, "features": [{"bounds": Rect2(bounds.position + Vector2(0, 0.8), Vector2(6, 0.2)), "height": 1.0, "blocks_end": true}]})
		objectives.append({"name": point.name, "kind": "terrain", "bounds": bounds, "role": point.role, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}})
	var selected_layout := T.layout(terrain_layout)
	if not selected_layout.has("error"):
		for area: Dictionary in selected_layout.areas: areas.append(area)
	s.terrain = {"id": terrain_layout, "source": "wahapedia-11e-event-companion-2026-27-take-and-hold-mirror", "areas": areas}
	s.mission.objectives = objectives

static func actor(s: Dictionary) -> int:
	if not enabled(s) or s.phase == "army_selection": return -1
	match s.mission.stage:
		"terrain", "roles-roll": return 1
		"roles-choice": return int(s.mission.roll_winner)
		"battle-ready":
			for player in [1, 2]:
				if not s.mission.battle_ready.has(player): return player
	if s.phase == "mission_first_turn": return 1
	return -1

static func choice(label: String, action: String, target: int = -1) -> Dictionary:
	return {"label": label, "action": action, "model": -1, "target": target, "value": ""}

static func choices(s: Dictionary, player: int) -> Array:
	if player != actor(s) or s.get("test_winner", 0) != 0: return []
	if s.phase == "mission_first_turn": return [choice("Roll off for first turn (ties roll again)", "mission-first")]
	match s.mission.stage:
		"terrain": return [choice("Roll central objective configuration (D6)", "mission-terrain")]
		"roles-roll": return [choice("Roll off for Attacker/Defender choice", "mission-roles")]
		"roles-choice": return [choice("Choose Attacker (left zone)", "mission-side", player), choice("Choose Defender (right zone)", "mission-side", 3 - player)]
		"battle-ready": return [choice("Battle Ready: no painting bonus", "mission-ready", 0), choice("Declare army Battle Ready (+10 VP at battle end)", "mission-ready", 1)]
	return []

static func pending_decision(s: Dictionary) -> Dictionary:
	var owner := actor(s)
	if owner <= 0: return {}
	var options := choices(s, owner)
	if options.is_empty(): return {}
	return PendingDecision.create(s, "mission-preparation", "mission-preparation:%s" % str(s.get("mission", {}).get("stage", "")), owner, options, false)

static func roll(roller: Callable) -> int:
	return int(roller.call()) if roller.is_valid() else randi_range(1, 6)

static func primary_id(s: Dictionary) -> String:
	return str(s.get("mission", {}).get("primary_id", "battlefield-dominance"))

static func _ensure_tracking(m: Dictionary) -> void:
	# Older saves for this mission predate the optional-primary trackers.
	if not m.get("turn_start_alive", null) is Dictionary: m.turn_start_alive = {1: [], 2: []}
	if not m.get("turn_start_central", null) is Dictionary: m.turn_start_central = {1: [], 2: []}
	if not m.get("last_turn_losses", null) is Dictionary: m.last_turn_losses = {1: 0, 2: 0}
	if not m.get("asset_secured_turn", null) is Dictionary: m.asset_secured_turn = {1: -1, 2: -1}
	for player in [1, 2]:
		if not m.turn_start_alive.has(player): m.turn_start_alive[player] = []
		if not m.turn_start_central.has(player): m.turn_start_central[player] = []
		if not m.last_turn_losses.has(player): m.last_turn_losses[player] = 0
		if not m.asset_secured_turn.has(player): m.asset_secured_turn[player] = -1

static func start_turn(s: Dictionary) -> void:
	if not enabled(s): return
	var m: Dictionary = s.mission
	_ensure_tracking(m)
	for player in [1, 2]:
		m.turn_start_alive[player] = []
		m.turn_start_central[player] = []
		for squad: int in s.squads:
			if int(s.squads[squad].owner) != player or G.alive(s, squad).is_empty(): continue
			m.turn_start_alive[player].append(squad)
			if _within_central(s, squad): m.turn_start_central[player].append(squad)

static func _within_central(s: Dictionary, squad: int) -> bool:
	for objective: Dictionary in s.mission.objectives:
		if objective.get("role", "") != "central": continue
		for model: int in G.alive(s, squad):
			if Objectives.in_range(s.units[model], objective): return true
	return false

static func _turn_losses(s: Dictionary) -> Dictionary:
	var result := {1: 0, 2: 0}
	var lost_central := {1: [], 2: []}
	for player in [1, 2]:
		for squad: int in s.mission.turn_start_alive.get(player, []):
			if G.alive(s, squad).is_empty():
				result[player] += 1
				if squad in s.mission.turn_start_central.get(player, []): lost_central[player].append(squad)
	return {"units": result, "central": lost_central}

static func apply(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> String:
	var m: Dictionary = s.mission
	match selected.action:
		"mission-terrain":
			var die := roll(roller)
			if die < 1 or die > 6: return "Invalid mission die."
			terrain(s, die == 6, str(m.get("terrain_layout", DEFAULT_TERRAIN_LAYOUT)))
			m.terrain_die = die
			m.stage = "roles-roll"
		"mission-roles", "mission-first":
			var one := roll(roller)
			var two := roll(roller)
			if one < 1 or one > 6 or two < 1 or two > 6: return "Invalid mission dice."
			m.log.append("%s roll-off: P1 %d / P2 %d%s" % ["First turn" if selected.action == "mission-first" else "Roles", one, two, " (tie; roll again)" if one == two else ""])
			if one == two: return ""
			var winner := 1 if one > two else 2
			if selected.action == "mission-roles":
				m.roll_winner = winner
				m.stage = "roles-choice"
			else:
				s.first_player = winner
				s.active = winner
				s.phase = "pre_battle"
				m.stage = "battle"
				ScoutMoves.begin(s)
		"mission-side":
			m.attacker = selected.target
			m.defender = 3 - selected.target
			m.stage = "battle-ready"
			preview(s)
		"mission-ready":
			m.battle_ready[player] = selected.target == 1
			if m.battle_ready.size() == 2: m.stage = "formations"
		_: return "Unknown mission choice."
	return ""

static func preview(s: Dictionary) -> void:
	var placed: Array[int] = []
	for player in [1, 2]:
		var squads: Array[int] = []
		for squad: int in s.squads:
			if s.squads[squad].owner == player: squads.append(squad)
		squads.sort()
		for index in range(squads.size()):
			var ids: Array[int] = G.alive(s, squads[index])
			ids.sort()
			var side := -1 if player == s.mission.attacker else 1
			var base := Vector2(side * (15 + (index % 2) * 9), -17 + floori(index / 2.0) * 13)
			var found := false
			for dy in [0, 1, -1, 2, -2, 3, -3]:
				if found: break
				for dx in [0, 1, -1, 2, -2]:
					var projected := s.duplicate(true)
					var positions := {}
					var valid := true
					for j in range(ids.size()):
						var id: int = ids[j]
						var u: Dictionary = projected.units[id]
						var point := base + Vector2(side * ((j % 3) * 2.2 + dx), floori(j / 3.0) * 2.2 + dy)
						var r: float = u.radius
						if absf(point.x) + r > 30 or absf(point.y) + r > 22 or absf(point.x) - r < 12: valid = false; break
						u.position = point
						if not T.path_error(projected, id, point).is_empty(): valid = false; break
						for previous: int in placed:
							if point.distance_to(s.units[previous].position) < r + float(s.units[previous].radius): valid = false; break
						if not valid: break
						positions[id] = point
					if valid and G.coherent(projected, squads[index]):
						for id: int in positions: s.units[id].position = positions[id]
						placed.append_array(ids)
						found = true
						break

static func award(s: Dictionary, player: int, source: String, requested: int, timing: String, card: String = "") -> void:
	var m: Dictionary = s.mission
	var key := "%d:%d:%s" % [s.round, player, source]
	var amount := mini(requested, 45 - int(m[source][player]))
	# Event Companion FAQ: end-of-battle VP is outside the per-round scoring cap.
	if timing != "end battle": amount = mini(amount, 15 - int(m.round_points.get(key, 0)))
	if not card.is_empty(): amount = mini(amount, 20 - int(m.cards[player][card]))
	amount = maxi(0, amount)
	m[source][player] += amount
	m.round_points[key] = int(m.round_points.get(key, 0)) + amount
	if not card.is_empty(): m.cards[player][card] += amount
	m.scores[player] += amount
	if amount > 0: m.log.append("Round %d P%d %s: +%d %s VP%s" % [s.round, player, timing, amount, source, " (" + card + ")" if not card.is_empty() else ""])

static func controlled(s: Dictionary, player: int) -> int:
	var result := 0
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == player: result += 1
	return result

static func primary_control(s: Dictionary) -> int:
	var result := 0
	var home := false
	var role := "attacker" if s.active == s.mission.attacker else "defender"
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == s.active and objective.role == role: home = true
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == s.active: result += 3 + (2 if home and objective.role != role else 0)
	return result

static func controlled_non_home(s: Dictionary, player: int) -> int:
	var result := 0
	var home_role := "attacker" if player == s.mission.attacker else "defender"
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == player and objective.role != home_role: result += 1
	return result

static func _primary_checkpoint(s: Dictionary) -> bool:
	return s.round >= 2 and ((s.phase == "command" and s.round < 5) or (s.phase == "end_turn" and s.round == 5))

static func _score_primary(s: Dictionary, losses: Dictionary) -> void:
	var m: Dictionary = s.mission
	var p := primary_id(s)
	var player: int = s.active
	var opponent := 3 - player
	var non_home := controlled_non_home(s, player)
	match p:
		"battlefield-dominance":
			if _primary_checkpoint(s): award(s, player, "primary", primary_control(s), s.phase)
			if s.phase == "end_turn" and s.round <= 2 and controlled(s, player) > controlled(s, opponent): award(s, player, "primary", 2, "end turn")
		"meatgrinder":
			if _primary_checkpoint(s) and non_home > 0: award(s, player, "primary", 4, s.phase)
			if s.phase == "end_turn":
				if int(losses.units[opponent]) > 0: award(s, player, "primary", 3, "end turn")
				if s.round >= 2 and int(losses.units[opponent]) > int(m.last_turn_losses.get(player, 0)): award(s, player, "primary", 5, "end turn")
				if s.round >= 2 and _controls_home(s, player, opponent): award(s, player, "primary", 5, "end turn")
		"reconnaissance-sweep":
			if _primary_checkpoint(s) and non_home > 0: award(s, player, "primary", 3, s.phase)
			if s.phase == "end_turn":
				var quarters_present := quarters(s, player, false)
				award(s, player, "primary", 6 if quarters_present >= 4 else 3 if quarters_present >= 3 else 0, "end turn")
				award(s, player, "primary", int(losses.units[opponent]), "end turn")
		"secure-asset":
			if _primary_checkpoint(s):
				if non_home > 0: award(s, player, "primary", 4, s.phase)
				if controlled(s, player) >= 3: award(s, player, "primary", 4, s.phase)
			if s.phase == "end_turn":
				if int(m.asset_secured_turn.get(player, -1)) == int(s.turn): award(s, player, "primary", 4, "end turn")
			var central_losses: Array = losses.central.get(opponent, [])
			if s.phase == "end_turn" and not central_losses.is_empty(): award(s, player, "primary", 2, "end turn")

static func _controls_home(s: Dictionary, player: int, owner: int) -> bool:
	var role := "attacker" if owner == s.mission.attacker else "defender"
	for objective: Dictionary in s.mission.objectives:
		if objective.role == role and objective.controller == player: return true
	return false

static func _unit_wholly_in_territory(s: Dictionary, squad: int, owner: int) -> bool:
	var alive := G.alive(s, squad)
	if alive.is_empty(): return false
	var zone: Rect2 = s.get("deployment", {}).get("zones", {}).get(owner, Rect2())
	var center := zone.get_center()
	var horizontal_split := absf(center.x) >= absf(center.y)
	var owner_on_negative_side := center.x < 0.0 if horizontal_split else center.y < 0.0
	if is_zero_approx(center.x) and is_zero_approx(center.y): return false
	for model: int in alive:
		var unit: Dictionary = s.units[model]
		if not unit.get("on_battlefield", true): return false
		var coordinate: float = unit.position.x if horizontal_split else unit.position.y
		var radius: float = float(unit.get("radius", 0.0))
		if owner_on_negative_side and coordinate + radius > 0.001: return false
		if not owner_on_negative_side and coordinate - radius < -0.001: return false
	return true

static func no_enemy_wholly_in_territory(s: Dictionary, player: int) -> bool:
	var zones: Dictionary = s.get("deployment", {}).get("zones", {})
	if not zones.has(player) or not zones[player] is Rect2 or zones[player].size == Vector2.ZERO: return false
	for squad: int in s.squads:
		if int(s.squads[squad].owner) != player and _unit_wholly_in_territory(s, squad, player): return false
	return true

static func quarters(s: Dictionary, player: int, exclude_aircraft_and_shocked: bool = true) -> int:
	var found: Array[int] = []
	for squad: int in s.squads:
		if s.squads[squad].owner != player or (exclude_aircraft_and_shocked and s.squads[squad].battle_shocked): continue
		var ids := G.alive(s, squad)
		if ids.is_empty(): continue
		var quarter := -1
		var valid := true
		for model: int in ids:
			var u: Dictionary = s.units[model]
			if not u.get("on_battlefield", true): valid = false; break
			if exclude_aircraft_and_shocked and "AIRCRAFT" in u.get("keywords", []): valid = false; break
			if u.position.length() - float(u.radius) <= 6.001: valid = false; break
			var q: int = (0 if u.position.x < 0 else 1) + (0 if u.position.y < 0 else 2)
			if absf(u.position.x) < float(u.radius) - 0.001 or absf(u.position.y) < float(u.radius) - 0.001 or (quarter >= 0 and q != quarter): valid = false; break
			quarter = q
		if valid and quarter not in found: found.append(quarter)
	return found.size()

static func score(s: Dictionary) -> bool:
	if not enabled(s) or s.phase not in ["command", "end_turn"]: return false
	var m: Dictionary = s.mission
	_ensure_tracking(m)
	var key := "%d:%s" % [s.turn, s.phase]
	if key in m.scored: return false
	m.scored.append(key)
	var losses := _turn_losses(s) if s.phase == "end_turn" else {"units": {1: 0, 2: 0}, "central": {1: [], 2: []}}
	_score_primary(s, losses)
	if s.phase != "end_turn": return false
	var count := quarters(s, s.active)
	award(s, s.active, "secondary", 4 if count == 4 else 2 if count == 3 else 0, "end turn", "engage-on-all-fronts")
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if unit.wounds > 0 or not Groups.character(unit) or model in m.dead_characters: continue
		m.dead_characters.append(model)
		award(s, 3 - unit.owner, "secondary", 3 + (1 if unit.max_wounds >= 4 else 0), "end turn", "assassination")
	m.last_turn_losses = losses.units.duplicate(true)
	if s.round == 5 and s.active != s.first_player:
		for player in [1, 2]:
			if m.battle_ready[player]: m.scores[player] += 10
			if primary_id(s) == "reconnaissance-sweep" and no_enemy_wholly_in_territory(s, player):
				award(s, player, "primary", 10, "end battle")
		s.test_winner = 1 if m.scores[1] > m.scores[2] else 2 if m.scores[2] > m.scores[1] else -1
		m.stage = "complete"
		return true
	return false

static func summary(s: Dictionary) -> String:
	var m: Dictionary = s.mission
	return "CA 2026-27 - %s / Hammer and Anvil\nVP %d / %d | Primary %d/%d | Fixed secondaries %d/%d\nEngage on All Fronts + Assassination | Round %d/5\n%s" % [str(m.get("name", "Battlefield Dominance")), m.scores[1], m.scores[2], m.primary[1], m.primary[2], m.secondary[1], m.secondary[2], s.round, m.log[-1] if not m.log.is_empty() else "Resolve mission preparation choices."]

static func secret_formations(s: Dictionary) -> bool:
	return enabled(s) and s.phase == "deployment" and s.mission.stage == "formations" and s.unit_abilities.get("setup_players", []).size() < 2

static func public_state(s: Dictionary, player: int) -> Dictionary:
	if not secret_formations(s): return s
	var visible := s.duplicate(true)
	for squad: int in visible.unit_abilities.reserves.keys():
		if visible.squads[squad].owner == player: continue
		visible.unit_abilities.reserves.erase(squad)
		for unit: Dictionary in visible.units.values():
			if unit.squad == squad: unit.on_battlefield = true
	# The omission/order and log would otherwise reveal a private reserve choice.
	var sides := {1: [], 2: []}
	for squad: int in visible.squads:
		if not visible.unit_abilities.reserves.has(squad): sides[visible.squads[squad].owner].append(squad)
	sides[1].sort()
	sides[2].sort()
	visible.deployment.order = []
	for index in range(maxi(sides[1].size(), sides[2].size())):
		for owner in [visible.mission.defender, visible.mission.attacker]:
			if index < sides[owner].size(): visible.deployment.order.append(sides[owner][index])
	visible.events = []
	return visible

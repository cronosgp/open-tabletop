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
const DEFAULT_SECONDARY_PAIR := "engage-assassination"
const FORCE_DISPOSITIONS := {"take-and-hold": "Take and Hold", "priority-assets": "Priority Assets"}
const SECONDARY_PAIRS := {
	"engage-assassination": {"label": "Engage on All Fronts + Assassination", "cards": ["engage-on-all-fronts", "assassination"]},
	"engage-bring-it-down": {"label": "Engage on All Fronts + Bring It Down", "cards": ["engage-on-all-fronts", "bring-it-down"]},
	"engage-grievous-blow": {"label": "Engage on All Fronts + A Grievous Blow", "cards": ["engage-on-all-fronts", "a-grievous-blow"]},
	"engage-secure-no-mans-land": {"label": "Engage on All Fronts + Secure No Man's Land", "cards": ["engage-on-all-fronts", "secure-no-mans-land"]},
	"engage-no-prisoners": {"label": "Engage on All Fronts + No Prisoners", "cards": ["engage-on-all-fronts", "no-prisoners"]},
	"engage-behind-enemy-lines": {"label": "Engage on All Fronts + Behind Enemy Lines", "cards": ["engage-on-all-fronts", "behind-enemy-lines"]},
	"engage-centre-ground": {"label": "Engage on All Fronts + Centre Ground", "cards": ["engage-on-all-fronts", "centre-ground"]},
	"engage-display-of-might": {"label": "Engage on All Fronts + Display of Might", "cards": ["engage-on-all-fronts", "display-of-might"]},
	"engage-overwhelming-force": {"label": "Engage on All Fronts + Overwhelming Force", "cards": ["engage-on-all-fronts", "overwhelming-force"]},
	"engage-outflank": {"label": "Engage on All Fronts + Outflank", "cards": ["engage-on-all-fronts", "outflank"]},
	"engage-forward-position": {"label": "Engage on All Fronts + Forward Position", "cards": ["engage-on-all-fronts", "forward-position"]},
	"engage-defend-stronghold": {"label": "Engage on All Fronts + Defend Stronghold", "cards": ["engage-on-all-fronts", "defend-stronghold"]},
	"engage-tempting-target": {"label": "Engage on All Fronts + A Tempting Target", "cards": ["engage-on-all-fronts", "a-tempting-target"]}
}
const SECONDARY_CARD_NAMES := {
	"engage-on-all-fronts": "Engage on All Fronts",
	"assassination": "Assassination",
	"bring-it-down": "Bring It Down",
	"a-grievous-blow": "A Grievous Blow",
	"secure-no-mans-land": "Secure No Man's Land",
	"no-prisoners": "No Prisoners",
	"behind-enemy-lines": "Behind Enemy Lines",
	"centre-ground": "Centre Ground",
	"display-of-might": "Display of Might",
	"overwhelming-force": "Overwhelming Force",
	"outflank": "Outflank",
	"forward-position": "Forward Position",
	"defend-stronghold": "Defend Stronghold",
	"a-tempting-target": "A Tempting Target"
}
const SIZE := Vector2(60, 44)
const PRIMARY_MISSIONS := {
	"battlefield-dominance": {"name": "Battlefield Dominance"},
	"meatgrinder": {"name": "Meatgrinder"},
	"reconnaissance-sweep": {"name": "Reconnaissance Sweep"},
	"secure-asset": {"name": "Secure Asset"},
	"destroyers-wrath": {"name": "Destroyer's Wrath"},
	"outmanoeuvre": {"name": "Outmanoeuvre"},
	"immovable-object": {"name": "Immovable Object"},
	"delaying-action": {"name": "Delaying Action"}
}

static func enabled(s: Dictionary) -> bool:
	return s.get("mission", {}).get("id", "") == ID

static func enable(s: Dictionary, terrain_layout: String = DEFAULT_TERRAIN_LAYOUT, primary_id: String = "battlefield-dominance", secondary_pair_id: String = DEFAULT_SECONDARY_PAIR, primary_ids: Dictionary = {}, force_disposition_ids: Dictionary = {}) -> void:
	if not T.is_event_layout(terrain_layout): terrain_layout = DEFAULT_TERRAIN_LAYOUT
	if not PRIMARY_MISSIONS.has(primary_id): primary_id = "battlefield-dominance"
	if not SECONDARY_PAIRS.has(secondary_pair_id): secondary_pair_id = DEFAULT_SECONDARY_PAIR
	var selected_primaries := {1: primary_id, 2: primary_id}
	for raw_owner: Variant in primary_ids:
		var owner := int(raw_owner)
		var selected_id := str(primary_ids[raw_owner])
		if owner in [1, 2] and PRIMARY_MISSIONS.has(selected_id): selected_primaries[owner] = selected_id
	primary_id = str(selected_primaries[1])
	var selected_force_dispositions: Dictionary = {}
	var selected_force_disposition_names: Dictionary = {}
	for owner in [1, 2]:
		var force_disposition_id := str(force_disposition_ids.get(owner, force_disposition_ids.get(str(owner), "")))
		if FORCE_DISPOSITIONS.has(force_disposition_id):
			selected_force_dispositions[owner] = force_disposition_id
			selected_force_disposition_names[owner] = str(FORCE_DISPOSITIONS[force_disposition_id])
	var p1: Dictionary = PRIMARY_MISSIONS[selected_primaries[1]]
	var p2: Dictionary = PRIMARY_MISSIONS[selected_primaries[2]]
	var secondary_cards: Array = SECONDARY_PAIRS[secondary_pair_id].cards.duplicate()
	var player_actions := {1: ["secure-asset"] if selected_primaries[1] == "secure-asset" else [], 2: ["secure-asset"] if selected_primaries[2] == "secure-asset" else []}
	var actions: Array[String] = []
	if not player_actions[1].is_empty() or not player_actions[2].is_empty(): actions.append("secure-asset")
	s.board_size = SIZE
	s.test_battlefield = ID
	s.battle_size = "Incursion - CA 2026-27 (reference lists)"
	s.first_player = 1
	s.mission = {"id": ID, "primary_id": primary_id, "primary_ids": selected_primaries, "primary_names": {1: p1.name, 2: p2.name}, "secondary_pair_id": secondary_pair_id, "name": "P1: %s / P2: %s" % [p1.name, p2.name] if selected_primaries[1] != selected_primaries[2] else str(p1.name), "deployment": "Hammer and Anvil", "force_dispositions": selected_force_dispositions, "force_disposition_names": selected_force_disposition_names, "primary_selection_mode": "direct-selection-override" if not selected_force_dispositions.is_empty() else "direct-selection", "terrain_layout": terrain_layout, "secondary_mode": "fixed", "secondary_cards": secondary_cards, "rounds": 5, "stage": "terrain", "roll_winner": 0, "attacker": 0, "defender": 0, "battle_ready": {}, "objectives": [], "tempting_targets": {}, "actions": actions, "actions_by_player": player_actions, "scores": {1: 0, 2: 0}, "primary": {1: 0, 2: 0}, "secondary": {1: 0, 2: 0}, "cards": {1: {secondary_cards[0]: 0, secondary_cards[1]: 0}, 2: {secondary_cards[0]: 0, secondary_cards[1]: 0}}, "round_points": {}, "scored": [], "dead_characters": [], "log": [], "turn_start_alive": {1: [], 2: []}, "turn_start_objective_units": {1: [], 2: []}, "turn_start_central": {1: [], 2: []}, "turn_start_models": {1: [], 2: []}, "last_turn_losses": {1: 0, 2: 0}, "asset_secured_turn": {1: -1, 2: -1}}
	s.mission.battle_start_strength = {}
	s.mission.battle_strength_recorded = false
	terrain(s, false, terrain_layout)
	Registry.admit(s, "ca-dominance-hammer-fixed", ID)

static func secondary_pair_id(s: Dictionary) -> String:
	var selected := str(s.get("mission", {}).get("secondary_pair_id", DEFAULT_SECONDARY_PAIR))
	return selected if SECONDARY_PAIRS.has(selected) else DEFAULT_SECONDARY_PAIR

static func tempting_target_owners(s: Dictionary, objective_name: String) -> Array[String]:
	var owners: Array[String] = []
	if secondary_pair_id(s) != "engage-tempting-target": return owners
	var targets: Dictionary = s.get("mission", {}).get("tempting_targets", {})
	for player in [1, 2]:
		if str(targets.get(player, targets.get(str(player), ""))) == objective_name: owners.append("P%d" % player)
	return owners

static func has_bring_it_down_roster_target(s: Dictionary, player: int) -> bool:
	var enemy := 3 - player
	for model: int in s.get("units", {}):
		var unit: Dictionary = s.units[model]
		if int(unit.get("owner", 0)) == enemy and int(unit.get("wounds", 0)) > 0 and int(unit.get("max_wounds", 0)) >= 10: return true
	return false

static func has_grievous_blow_roster_target(s: Dictionary, player: int) -> bool:
	var enemy := 3 - player
	for squad: int in s.get("squads", {}):
		var unit: Dictionary = s.squads[squad]
		if int(unit.get("owner", 0)) == enemy and int(unit.get("starting_strength", 0)) >= 13 and not G.alive(s, squad).is_empty(): return true
	return false

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
		"tempting-target-p1": return 2
		"tempting-target-p2": return 1
		"roles-choice": return int(s.mission.roll_winner)
		"battle-ready":
			for player in [1, 2]:
				if not s.mission.battle_ready.has(player): return player
	if s.phase == "mission_first_turn": return 1
	return -1

static func choice(label: String, action: String, target: int = -1, value: String = "") -> Dictionary:
	return {"label": label, "action": action, "model": -1, "target": target, "value": value}

static func choices(s: Dictionary, player: int) -> Array:
	if player != actor(s) or s.get("test_winner", 0) != 0: return []
	if s.phase == "mission_first_turn": return [choice("Roll off for first turn (ties roll again)", "mission-first")]
	match s.mission.stage:
		"terrain": return [choice("Roll central objective configuration (D6)", "mission-terrain")]
		"tempting-target-p1", "tempting-target-p2":
			var target_owner := 1 if s.mission.stage == "tempting-target-p1" else 2
			var options: Array = []
			for objective: Dictionary in s.mission.objectives:
				if str(objective.get("role", "")) not in ["central", "expansion"]: continue
				var objective_name := str(objective.get("name", "Objective"))
				options.append(choice("Choose %s for Player %d" % [objective_name, target_owner], "mission-tempting-target", -1, objective_name))
			return options
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

static func primary_id(s: Dictionary, player: int = 1) -> String:
	var mission: Dictionary = s.get("mission", {})
	var assignments: Variant = mission.get("primary_ids", {})
	if assignments is Dictionary and player in [1, 2]:
		var value: Variant = assignments.get(player, assignments.get(str(player), ""))
		if PRIMARY_MISSIONS.has(str(value)): return str(value)
	return str(mission.get("primary_id", "battlefield-dominance"))

static func primary_assignments(s: Dictionary) -> Dictionary:
	return {1: primary_id(s, 1), 2: primary_id(s, 2)}

static func force_disposition_assignments(s: Dictionary) -> Dictionary:
	var mission: Dictionary = s.get("mission", {})
	# Older saves used this field for the disposition associated with a primary
	# card, not the disposition selected from the player's roster.
	if not mission.has("primary_selection_mode"):
		return {}
	var force_dispositions: Dictionary = mission.get("force_dispositions", {})
	return force_dispositions.duplicate(true)

static func _ensure_tracking(m: Dictionary) -> void:
	# Older saves for this mission predate the optional-primary trackers.
	if not m.get("turn_start_alive", null) is Dictionary: m.turn_start_alive = {1: [], 2: []}
	if not m.get("turn_start_objective_units", null) is Dictionary: m.turn_start_objective_units = {1: [], 2: []}
	if not m.get("turn_start_central", null) is Dictionary: m.turn_start_central = {1: [], 2: []}
	if not m.get("turn_start_models", null) is Dictionary: m.turn_start_models = {1: [], 2: []}
	if not m.get("last_turn_losses", null) is Dictionary: m.last_turn_losses = {1: 0, 2: 0}
	if not m.get("asset_secured_turn", null) is Dictionary: m.asset_secured_turn = {1: -1, 2: -1}
	for player in [1, 2]:
		if not m.turn_start_alive.has(player): m.turn_start_alive[player] = []
		if not m.turn_start_objective_units.has(player): m.turn_start_objective_units[player] = []
		if not m.turn_start_central.has(player): m.turn_start_central[player] = []
		if not m.turn_start_models.has(player): m.turn_start_models[player] = []
		if not m.last_turn_losses.has(player): m.last_turn_losses[player] = 0
		if not m.asset_secured_turn.has(player): m.asset_secured_turn[player] = -1

static func start_turn(s: Dictionary) -> void:
	if not enabled(s): return
	var m: Dictionary = s.mission
	_ensure_tracking(m)
	if not bool(m.get("battle_strength_recorded", false)):
		m.battle_start_strength = {}
		for squad: int in s.squads:
			m.battle_start_strength[squad] = int(s.squads[squad].get("starting_strength", 0))
		m.battle_strength_recorded = true
	for player in [1, 2]:
		m.turn_start_alive[player] = []
		m.turn_start_objective_units[player] = []
		m.turn_start_central[player] = []
		m.turn_start_models[player] = []
		for squad: int in s.squads:
			if int(s.squads[squad].owner) != player or G.alive(s, squad).is_empty(): continue
			m.turn_start_alive[player].append(squad)
			if _within_any_objective(s, squad): m.turn_start_objective_units[player].append(squad)
			if _within_central(s, squad): m.turn_start_central[player].append(squad)
		for model: int in s.units:
			var unit: Dictionary = s.units[model]
			if int(unit.owner) == player and int(unit.wounds) > 0:
				m.turn_start_models[player].append({"model": model, "max_wounds": int(unit.max_wounds)})

static func _within_central(s: Dictionary, squad: int) -> bool:
	for objective: Dictionary in s.mission.objectives:
		if objective.get("role", "") != "central": continue
		for model: int in G.alive(s, squad):
			if Objectives.in_range(s.units[model], objective): return true
	return false

static func _within_any_objective(s: Dictionary, squad: int) -> bool:
	for objective: Dictionary in s.mission.objectives:
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
			m.stage = "tempting-target-p1" if secondary_pair_id(s) == "engage-tempting-target" else "roles-roll"
		"mission-tempting-target":
			var target_owner := 1 if m.stage == "tempting-target-p1" else 2 if m.stage == "tempting-target-p2" else 0
			if target_owner not in [1, 2]: return "Tempting Target selection is not active."
			var target_name := str(selected.get("value", ""))
			var target_is_eligible := false
			for objective: Dictionary in m.objectives:
				if str(objective.get("name", "")) == target_name and str(objective.get("role", "")) in ["central", "expansion"]:
					target_is_eligible = true
					break
			if not target_is_eligible: return "Choose a central or expansion objective for A Tempting Target."
			if not m.get("tempting_targets", null) is Dictionary: m.tempting_targets = {}
			m.tempting_targets[target_owner] = target_name
			m.log.append("Player %d selected %s as Player %d's Tempting Target." % [player, target_name, target_owner])
			m.stage = "tempting-target-p2" if m.stage == "tempting-target-p1" else "roles-roll"
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

static func controlled_central(s: Dictionary, player: int) -> int:
	return controlled_role(s, player, "central")

static func controlled_expansion(s: Dictionary, player: int) -> int:
	return controlled_role(s, player, "expansion")

static func controlled_role(s: Dictionary, player: int, role: String) -> int:
	var result := 0
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == player and str(objective.get("role", "")) == role: result += 1
	return result

static func controlled_excluding_home_objectives(s: Dictionary, player: int) -> int:
	var result := 0
	for objective: Dictionary in s.mission.objectives:
		if objective.controller == player and str(objective.get("role", "")) not in ["attacker", "defender"]: result += 1
	return result

static func _primary_checkpoint(s: Dictionary) -> bool:
	return s.round >= 2 and ((s.phase == "command" and s.round < 5) or (s.phase == "end_turn" and s.round == 5))

static func _score_primary(s: Dictionary, losses: Dictionary) -> void:
	var m: Dictionary = s.mission
	var player: int = s.active
	var p := primary_id(s, player)
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
		"destroyers-wrath":
			if _primary_checkpoint(s):
				if non_home > 0: award(s, player, "primary", 4, s.phase)
				if controlled(s, player) > controlled(s, opponent): award(s, player, "primary", 6, s.phase)
			if s.phase == "end_turn":
				if int(losses.units[opponent]) > 0: award(s, player, "primary", 3, "end turn")
				if s.round >= 2 and int(losses.units[opponent]) > int(m.last_turn_losses.get(player, 0)): award(s, player, "primary", 4, "end turn")
		"outmanoeuvre":
			if s.phase == "command" and s.round in [2, 3] and non_home > 0: award(s, player, "primary", non_home * 5, s.phase)
			if s.phase == "end_turn":
				if _controls_home(s, player, opponent): award(s, player, "primary", 10, "end turn")
				if s.round == 1 and non_home > 0: award(s, player, "primary", non_home * 4, "end turn")
				if s.round >= 4 and non_home > 0: award(s, player, "primary", non_home * 6, "end turn")
		"immovable-object":
			if s.phase == "end_turn" and controlled_central(s, player) > 0: award(s, player, "primary", 3, "end turn")
			if _primary_checkpoint(s) and non_home > 0: award(s, player, "primary", non_home * 5, s.phase)
		"delaying-action":
			if s.phase == "end_turn":
				award(s, player, "primary", int(losses.units[opponent]) * 2, "end turn")
				if s.round >= 2 and controlled_central(s, player) > 0 and controlled_expansion(s, player) > 0: award(s, player, "primary", 3, "end turn")
			if _primary_checkpoint(s) and controlled_excluding_home_objectives(s, player) > 0: award(s, player, "primary", 4, s.phase)
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

static func _unit_wholly_in_deployment_zone(s: Dictionary, squad: int, zone_owner: int) -> bool:
	var zones: Dictionary = s.get("deployment", {}).get("zones", {})
	if not zones.has(zone_owner) or not zones[zone_owner] is Rect2 or zones[zone_owner].size == Vector2.ZERO: return false
	if not s.squads.has(squad) or bool(s.squads[squad].get("battle_shocked", false)): return false
	var zone: Rect2 = zones[zone_owner]
	var alive := G.alive(s, squad)
	if alive.is_empty(): return false
	for model: int in alive:
		var unit: Dictionary = s.units[model]
		if not unit.get("on_battlefield", true) or "AIRCRAFT" in unit.get("keywords", []): return false
		var radius := float(unit.get("radius", 0.0))
		if unit.position.x - radius < zone.position.x - 0.001 or unit.position.x + radius > zone.end.x + 0.001: return false
		if unit.position.y - radius < zone.position.y - 0.001 or unit.position.y + radius > zone.end.y + 0.001: return false
	return true

static func _enemy_unit_in_deployment_zone(s: Dictionary, zone_owner: int) -> bool:
	var zones: Dictionary = s.get("deployment", {}).get("zones", {})
	if not zones.has(zone_owner) or not zones[zone_owner] is Rect2 or zones[zone_owner].size == Vector2.ZERO: return false
	var zone: Rect2 = zones[zone_owner]
	var enemy_player := 3 - zone_owner
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", 0)) != enemy_player: continue
		for model: int in G.alive(s, squad):
			var unit: Dictionary = s.units[model]
			if not unit.get("on_battlefield", true): continue
			var radius := float(unit.get("radius", 0.0))
			if zone.get_closest_point(unit.position).distance_to(unit.position) <= radius + 0.001: return true
	return false

static func _outflank_unit_profile(s: Dictionary, squad: int, player: int) -> Dictionary:
	var zones: Dictionary = s.get("deployment", {}).get("zones", {})
	if not zones.has(player) or not zones[player] is Rect2 or zones[player].size == Vector2.ZERO: return {}
	if not s.squads.has(squad) or bool(s.squads[squad].get("battle_shocked", false)): return {}
	var zone: Rect2 = zones[player]
	var center := zone.get_center()
	var horizontal_split := absf(center.x) >= absf(center.y)
	var owner_on_negative_side := center.x < 0.0 if horizontal_split else center.y < 0.0
	if is_zero_approx(center.x) and is_zero_approx(center.y): return {}
	var half_board: Vector2 = s.get("board_size", SIZE) / 2.0
	var edges: Array[int] = []
	var outside_own_territory := true
	var alive := G.alive(s, squad)
	if alive.is_empty(): return {}
	for model: int in alive:
		var unit: Dictionary = s.units[model]
		if not unit.get("on_battlefield", true) or "AIRCRAFT" in unit.get("keywords", []): return {}
		var radius := float(unit.get("radius", 0.0))
		var territory_axis: float = unit.position.x if horizontal_split else unit.position.y
		if owner_on_negative_side and territory_axis - radius <= 0.001: outside_own_territory = false
		if not owner_on_negative_side and territory_axis + radius >= -0.001: outside_own_territory = false
		if unit.position.x - radius + half_board.x <= 6.001 and 0 not in edges: edges.append(0)
		if half_board.x - (unit.position.x + radius) <= 6.001 and 1 not in edges: edges.append(1)
		if unit.position.y - radius + half_board.y <= 6.001 and 2 not in edges: edges.append(2)
		if half_board.y - (unit.position.y + radius) <= 6.001 and 3 not in edges: edges.append(3)
	if edges.is_empty(): return {}
	return {"edges": edges, "outside_own_territory": outside_own_territory}

static func _outflank_score(s: Dictionary, player: int) -> int:
	var profiles: Array[Dictionary] = []
	var one_outside_near_edge := false
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", 0)) != player: continue
		var profile := _outflank_unit_profile(s, squad, player)
		if profile.is_empty(): continue
		profiles.append(profile)
		if bool(profile.get("outside_own_territory", false)): one_outside_near_edge = true
	for first_index in range(profiles.size()):
		var first_edges: Array = profiles[first_index].edges
		for second_index in range(first_index + 1, profiles.size()):
			var second_edges: Array = profiles[second_index].edges
			var opposite_edges := (0 in first_edges and 1 in second_edges) or (1 in first_edges and 0 in second_edges) or (2 in first_edges and 3 in second_edges) or (3 in first_edges and 2 in second_edges)
			if opposite_edges and (bool(profiles[first_index].outside_own_territory) or bool(profiles[second_index].outside_own_territory)): return 5
	return 3 if one_outside_near_edge else 0

static func _any_unit_within_centre(s: Dictionary, player: int, inches: float, exclude_aircraft_and_shocked: bool) -> bool:
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", 0)) != player: continue
		if exclude_aircraft_and_shocked and bool(s.squads[squad].get("battle_shocked", false)): continue
		for model: int in G.alive(s, squad):
			var unit: Dictionary = s.units[model]
			if not unit.get("on_battlefield", true): continue
			if exclude_aircraft_and_shocked and "AIRCRAFT" in unit.get("keywords", []): continue
			var horizontal_edge_distance := maxf(0.0, unit.position.length() - float(unit.get("radius", 0.0)))
			var distance_to_centre := Vector2(horizontal_edge_distance, float(unit.get("elevation", 0.0))).length()
			if distance_to_centre <= inches + 0.001: return true
	return false

static func _no_mans_land_unit_counts(s: Dictionary) -> Dictionary:
	var counts := {1: 0, 2: 0}
	var zones: Dictionary = s.get("deployment", {}).get("zones", {})
	if not zones.has(1) or not zones.has(2) or not zones[1] is Rect2 or not zones[2] is Rect2: return counts
	var left_zone: Rect2 = zones[1]
	var right_zone: Rect2 = zones[2]
	if right_zone.position.x < left_zone.position.x:
		var swap_zone := left_zone
		left_zone = right_zone
		right_zone = swap_zone
	var nml_left := left_zone.end.x
	var nml_right := right_zone.position.x
	if nml_left > nml_right: return counts
	var half_board: Vector2 = s.get("board_size", SIZE) / 2.0
	for squad: int in s.squads:
		var owner := int(s.squads[squad].get("owner", 0))
		if owner not in [1, 2] or bool(s.squads[squad].get("battle_shocked", false)): continue
		var alive := G.alive(s, squad)
		if alive.is_empty(): continue
		var wholly_in_no_mans_land := true
		for model: int in alive:
			var unit: Dictionary = s.units[model]
			if not unit.get("on_battlefield", true) or "AIRCRAFT" in unit.get("keywords", []): wholly_in_no_mans_land = false; break
			var radius := float(unit.get("radius", 0.0))
			if unit.position.x - radius < nml_left - 0.001 or unit.position.x + radius > nml_right + 0.001: wholly_in_no_mans_land = false; break
			if unit.position.y - radius < -half_board.y - 0.001 or unit.position.y + radius > half_board.y + 0.001: wholly_in_no_mans_land = false; break
		if wholly_in_no_mans_land: counts[owner] += 1
	return counts

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
	match secondary_pair_id(s):
		"engage-assassination":
			for model: int in s.units:
				var unit: Dictionary = s.units[model]
				if unit.wounds > 0 or not Groups.character(unit) or model in m.dead_characters: continue
				m.dead_characters.append(model)
				award(s, 3 - unit.owner, "secondary", 3 + (1 if unit.max_wounds >= 4 else 0), "end turn", "assassination")
		"engage-bring-it-down":
			for bring_scoring_player in [1, 2]:
				var bring_enemy := 3 - bring_scoring_player
				var destroyed_large_models := 0
				for start_record: Dictionary in m.turn_start_models.get(bring_enemy, []):
					var model := int(start_record.get("model", -1))
					if int(start_record.get("max_wounds", 0)) < 10 or not s.units.has(model): continue
					if int(s.units[model].get("wounds", 0)) <= 0: destroyed_large_models += 1
				award(s, bring_scoring_player, "secondary", destroyed_large_models * 4, "end turn", "bring-it-down")
		"engage-grievous-blow":
			for grievous_scoring_player in [1, 2]:
				var grievous_enemy := 3 - grievous_scoring_player
				var destroyed_large_units := 0
				for squad: int in m.turn_start_alive.get(grievous_enemy, []):
					if int(m.battle_start_strength.get(squad, 0)) < 13 or not s.squads.has(squad): continue
					if G.alive(s, squad).is_empty(): destroyed_large_units += 1
				award(s, grievous_scoring_player, "secondary", mini(destroyed_large_units * 4, 5), "end turn", "a-grievous-blow")
		"engage-secure-no-mans-land":
			if controlled_excluding_home_objectives(s, s.active) >= 2:
				award(s, s.active, "secondary", 5, "end turn", "secure-no-mans-land")
		"engage-no-prisoners":
			for no_prisoners_scoring_player in [1, 2]:
				var destroyed_enemy_units := int(losses.units[3 - no_prisoners_scoring_player])
				award(s, no_prisoners_scoring_player, "secondary", mini(destroyed_enemy_units * 2, 5), "end turn", "no-prisoners")
		"engage-behind-enemy-lines":
			var enemy_zone_owner := 3 - s.active
			var forward_units := 0
			for squad: int in s.squads:
				if int(s.squads[squad].get("owner", 0)) != s.active: continue
				if _unit_wholly_in_deployment_zone(s, squad, enemy_zone_owner): forward_units += 1
			award(s, s.active, "secondary", mini(forward_units * 3, 5), "end turn", "behind-enemy-lines")
		"engage-centre-ground":
			if _any_unit_within_centre(s, s.active, 3.0, true):
				var enemy_within_six := _any_unit_within_centre(s, 3 - s.active, 6.0, false)
				var enemy_within_three := _any_unit_within_centre(s, 3 - s.active, 3.0, false)
				if not enemy_within_six:
					award(s, s.active, "secondary", 5, "end turn", "centre-ground")
				elif not enemy_within_three:
					award(s, s.active, "secondary", 3, "end turn", "centre-ground")
		"engage-display-of-might":
			var no_mans_land_counts := _no_mans_land_unit_counts(s)
			for scorer in [1, 2]:
				var opposing_count := int(no_mans_land_counts[3 - scorer])
				if int(no_mans_land_counts[scorer]) <= opposing_count: continue
				var requested := 2 if scorer == s.active else 5
				award(s, scorer, "secondary", requested, "end turn", "display-of-might")
		"engage-overwhelming-force":
			for scoring_player in [1, 2]:
				var enemy_player := 3 - scoring_player
				var destroyed_near_objective := 0
				for squad: int in m.turn_start_objective_units.get(enemy_player, []):
					if s.squads.has(squad) and G.alive(s, squad).is_empty(): destroyed_near_objective += 1
				award(s, scoring_player, "secondary", mini(destroyed_near_objective * 3, 5), "end turn", "overwhelming-force")
		"engage-outflank":
			var outflank_vp := _outflank_score(s, s.active)
			if outflank_vp > 0: award(s, s.active, "secondary", outflank_vp, "end turn", "outflank")
		"engage-forward-position":
			var forward_position_vp := (5 if _controls_home(s, s.active, 3 - s.active) else 0) + controlled_expansion(s, s.active) * 5
			if forward_position_vp > 0: award(s, s.active, "secondary", forward_position_vp, "end turn", "forward-position")
		"engage-defend-stronghold":
			if s.round >= 2:
				var stronghold_player := 3 - s.active
				if _controls_home(s, stronghold_player, stronghold_player):
					var stronghold_vp := 3 if _enemy_unit_in_deployment_zone(s, stronghold_player) else 5
					award(s, stronghold_player, "secondary", stronghold_vp, "end opponent turn", "defend-stronghold")
		"engage-tempting-target":
			var target_name := str(m.get("tempting_targets", {}).get(s.active, ""))
			for objective: Dictionary in m.objectives:
				if str(objective.get("name", "")) == target_name and int(objective.get("controller", 0)) == s.active:
					award(s, s.active, "secondary", 5, "end turn", "a-tempting-target")
					break
	m.last_turn_losses = losses.units.duplicate(true)
	if s.round == 5 and s.active != s.first_player:
		for player in [1, 2]:
			if m.battle_ready[player]:
				m.scores[player] += 10
				m.log.append("End battle P%d: +10 Battle Ready VP." % player)
			if primary_id(s, player) == "reconnaissance-sweep" and no_enemy_wholly_in_territory(s, player):
				award(s, player, "primary", 10, "end battle")
		s.test_winner = 1 if m.scores[1] > m.scores[2] else 2 if m.scores[2] > m.scores[1] else -1
		m.stage = "complete"
		return true
	return false

static func summary(s: Dictionary) -> String:
	var m: Dictionary = s.mission
	var pair_id := secondary_pair_id(s)
	var pair_label := str(SECONDARY_PAIRS[pair_id].label)
	var names: Dictionary = m.get("primary_names", {1: str(m.get("name", "Battlefield Dominance")), 2: str(m.get("name", "Battlefield Dominance"))})
	var target_summary := ""
	if pair_id == "engage-tempting-target":
		var targets: Dictionary = m.get("tempting_targets", {})
		var p1_target := str(targets.get(1, targets.get("1", "")))
		var p2_target := str(targets.get(2, targets.get("2", "")))
		target_summary = "\nTempting Targets — P1: %s · P2: %s" % [p1_target if not p1_target.is_empty() else "awaiting opponent", p2_target if not p2_target.is_empty() else "awaiting opponent"]
	return "CA 2026-27 - %s / Hammer and Anvil\nPrimary: P1 %s (%d VP) · P2 %s (%d VP)\nTotal: %d / %d VP | Fixed secondaries %d / %d VP\n%s%s | Round %d/5\n%s" % [str(m.get("name", "Battlefield Dominance")), str(names.get(1, names.get("1", "Primary"))), m.primary[1], str(names.get(2, names.get("2", "Primary"))), m.primary[2], m.scores[1], m.scores[2], m.secondary[1], m.secondary[2], pair_label, target_summary, s.round, m.log[-1] if not m.log.is_empty() else "Resolve mission preparation choices."]

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

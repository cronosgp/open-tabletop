extends RefCounted
## Core e11 reaction stratagems required by the checked Gladius vs Awakened infantry match.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const ID := "core-reaction-stratagems-v1"
const OVERWATCH := "fire-overwatch"
const HEROIC := "heroic-intervention"
const FRAY := "heroic-fray"
const COUNTER := "counteroffensive"
const EPIC := "epic-challenge"

static func enable(s: Dictionary) -> void:
	if s.has("core_reactions"): return
	s.core_reactions = {"implementation": ID, "overwatch": {}, "heroic": {}, "chargers": [], "charge_closed": false, "epic": {}}
	s.pack_hash = (str(s.pack_hash) + ID).sha256_text()
	s.scope = "Core infantry reactions: Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge. " + str(s.get("scope", ""))
	for ability in [OVERWATCH, HEROIC, COUNTER, EPIC]: Registry.admit(s, ability, ID)

static func enabled(s: Dictionary) -> bool:
	return s.get("core_reactions", {}).get("implementation", "") == ID and s.has("stratagems") and A.enabled(s)

static func phase_key(s: Dictionary) -> String:
	return "%d:%s" % [s.turn, s.phase]

static func living(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in s.units:
		if s.units[model].squad == squad and s.units[model].wounds > 0 and s.units[model].get("on_battlefield", true): result.append(model)
	return result

static func keyword(s: Dictionary, squad: int, word: String) -> bool:
	for model: int in living(s, squad):
		for item: Variant in s.units[model].get("keywords", []):
			if str(item).strip_edges().to_upper() == word: return true
	return false

static func actor(s: Dictionary) -> int:
	if not enabled(s): return -1
	var shot: Dictionary = s.core_reactions.get("overwatch", {})
	if shot.get("phase_key", "") == phase_key(s): return int(shot.get("player", -1))
	var heroic: Dictionary = s.core_reactions.get("heroic", {})
	if heroic.get("phase_key", "") == phase_key(s): return int(heroic.get("player", -1))
	return -1

static func overwatch_shooter(s: Dictionary, squad: int) -> bool:
	if not enabled(s): return false
	var shot: Dictionary = s.core_reactions.get("overwatch", {})
	return shot.get("phase_key", "") == phase_key(s) and int(shot.get("squad", -1)) == squad

static func heroic_charger(s: Dictionary, player: int, squad: int) -> bool:
	if not enabled(s): return false
	var heroic: Dictionary = s.core_reactions.get("heroic", {})
	return heroic.get("phase_key", "") == phase_key(s) and int(heroic.get("player", -1)) == player and int(heroic.get("squad", -1)) == squad

static func fray_charger(s: Dictionary, squad: int) -> bool:
	if not enabled(s): return false
	var heroic: Dictionary = s.core_reactions.get("heroic", {})
	return heroic.get("phase_key", "") == phase_key(s) and int(heroic.get("squad", -1)) == squad and str(heroic.get("mode", "")) == "fray"

static func charge_closed(s: Dictionary) -> bool:
	return enabled(s) and bool(s.core_reactions.get("charge_closed", false)) and s.phase == "charge"

static func record_charger(s: Dictionary, squad: int) -> void:
	if not enabled(s): return
	var chargers: Array = s.core_reactions.chargers
	if squad not in chargers: chargers.append(squad)
	s.core_reactions.chargers = chargers

static func clear_overwatch(s: Dictionary) -> void:
	if enabled(s): s.core_reactions.overwatch = {}

static func clear_heroic(s: Dictionary) -> void:
	if enabled(s): s.core_reactions.heroic = {}

static func end_available(s: Dictionary, player: int) -> bool:
	if not enabled(s) or not A.enabled(s): return false
	if s.phase == "movement" and player != s.active:
		for squad: int in s.squads:
			if error(s, player, squad, OVERWATCH).is_empty(): return true
	if s.phase == "charge" and player != s.active:
		for squad: int in s.squads:
			if error(s, player, squad, HEROIC).is_empty() or error(s, player, squad, FRAY).is_empty(): return true
	return false

static func visible_within(s: Dictionary, squad: int, target: int, inches: float) -> bool:
	for model: int in living(s, squad):
		var sight := Terrain.targeting(s, model, target)
		if sight.visible and sight.distance <= inches + 0.001: return true
	return false

static func overwatch_targets(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for target: int in s.squads:
		if s.squads[target].owner == s.squads[squad].owner or living(s, target).is_empty(): continue
		if visible_within(s, squad, target, 24.0): result.append(target)
	return result

static func cost_of(s: Dictionary, player: int, squad: int, rule: String) -> int:
	var extra := 1 if rule == FRAY else 0
	var base := 2 if rule == COUNTER else 1
	return maxi(0, base - A.discount(s, player, squad)) + extra

static func error(s: Dictionary, player: int, squad: int, rule: String, model: int = -1) -> String:
	if not enabled(s): return "Core reaction stratagems are disabled."
	if not s.squads.has(squad) or s.squads[squad].owner != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
	if s.squads[squad].battle_shocked: return "Battle-shocked units cannot receive friendly stratagems."
	if s.cp.get(player, 0) < cost_of(s, player, squad, rule): return "This stratagem costs %d CP." % cost_of(s, player, squad, rule)
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if rule == OVERWATCH:
		if s.phase != "movement" or s.active == player: return "Fire Overwatch is used at the end of your opponent's Movement phase."
		if window.get("kind", "") != "end": return "Fire Overwatch is used at the end of the Movement phase."
		if Queue.engaged(s, squad): return "An engaged unit cannot fire Overwatch."
		if keyword(s, squad, "TITANIC"): return "Titanic units cannot fire Overwatch."
		if overwatch_targets(s, squad).is_empty(): return "Overwatch requires a visible enemy within 24 inches."
	elif rule in [HEROIC, FRAY]:
		if s.phase != "charge" or s.active == player: return "Heroic Intervention is used at the end of your opponent's Charge phase."
		if window.get("kind", "") != "end": return "Heroic Intervention is used at the end of the Charge phase."
		if Queue.engaged(s, squad): return "An engaged unit cannot make a Heroic Intervention."
		if s.squads[squad].charge_declared: return "This unit already declared a charge this phase."
		if rule == HEROIC:
			var near := false
			for charger: int in s.core_reactions.get("chargers", []):
				if s.squads.has(charger) and s.squads[charger].owner != player and G.distance_to_target(s, s.units[living(s, squad)[0]], charger) <= 12.001: near = true
			if not near: return "Leap to Defend requires an enemy that declared a charge within 12 inches."
	elif rule == COUNTER:
		if s.phase != "fight" or s.active == player: return "Counteroffensive is used in your opponent's Fight phase."
		if window.get("kind", "") != "counter": return "Counteroffensive is used just after an enemy unit has fought."
		if s.squads[squad].fought: return "Counteroffensive requires a unit that has not yet been selected to fight."
		if not Queue.eligible(s, squad): return "Counteroffensive requires a unit eligible to fight."
	elif rule == EPIC:
		if s.phase != "fight" or s.fight_step != "attacks": return "Epic Challenge is used after a Character unit is selected to fight."
		if s.get("fight_actor", -1) != player: return "Epic Challenge requires your unit selected to fight."
		if squad not in Queue.choices(s, player) and s.get("fight_selected", -1) != squad: return "Epic Challenge requires a Character unit selected to fight."
		if s.squads[squad].fought: return "This unit has already fought."
		var character := false
		for id: int in living(s, squad):
			if Groups.character(s.units[id]) and (model == -1 or id == model): character = true
		if not character: return "Epic Challenge requires a Character model."
	else: return "Unknown core reaction."
	for use: Dictionary in s.stratagems.uses:
		if use.player != player: continue
		if use.phase_key != phase_key(s): continue
		var used: String = str(use.stratagem)
		if used == rule or (rule in [HEROIC, FRAY] and used in [HEROIC, FRAY]): return "This stratagem has already been used this phase."
		if int(use.squad) == squad: return "This unit has already been targeted by another stratagem this phase."
	return ""

static func choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not enabled(s): return result
	var shot: Dictionary = s.core_reactions.get("overwatch", {})
	if shot.get("phase_key", "") == phase_key(s) and int(shot.get("player", -1)) == player:
		result.append({"label": "Decline remaining Fire Overwatch shooting", "action": "overwatch-pass", "model": -1, "target": int(shot.squad), "value": ""})
	for squad: int in s.squads:
		if error(s, player, squad, OVERWATCH).is_empty():
			result.append({"label": "Fire Overwatch: %s (snap shooting; %d CP)" % [s.squads[squad].name, cost_of(s, player, squad, OVERWATCH)], "action": "core-stratagem", "model": -1, "target": squad, "value": OVERWATCH})
		if error(s, player, squad, HEROIC).is_empty():
			result.append({"label": "Heroic Intervention — Leap to Defend: %s (%d CP)" % [s.squads[squad].name, cost_of(s, player, squad, HEROIC)], "action": "core-stratagem", "model": -1, "target": squad, "value": HEROIC})
		if error(s, player, squad, FRAY).is_empty():
			result.append({"label": "Heroic Intervention — Into the Fray: %s (charge cap 6; %d CP)" % [s.squads[squad].name, cost_of(s, player, squad, FRAY)], "action": "core-stratagem", "model": -1, "target": squad, "value": FRAY})
		if error(s, player, squad, COUNTER).is_empty():
			result.append({"label": "Counteroffensive: %s (Fights First; %d CP)" % [s.squads[squad].name, cost_of(s, player, squad, COUNTER)], "action": "core-stratagem", "model": -1, "target": squad, "value": COUNTER})
		for id: int in living(s, squad):
			if error(s, player, squad, EPIC, id).is_empty():
				result.append({"label": "Epic Challenge: %s model %d (melee Precision; %d CP)" % [s.squads[squad].name, id, cost_of(s, player, squad, EPIC)], "action": "core-stratagem", "model": id, "target": squad, "value": EPIC})
				break
	return result

static func apply(s: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var rule := str(selected.value)
	var failure := error(s, player, selected.target, rule, selected.model)
	if not failure.is_empty(): return {"error": failure}
	s.cp[player] -= cost_of(s, player, selected.target, rule)
	A.consume_discount(s, player, selected.target)
	var recorded := HEROIC if rule == FRAY else rule
	s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": recorded, "phase_key": phase_key(s), "turn": s.turn})
	if rule == OVERWATCH:
		s.core_reactions.overwatch = {"player": player, "squad": selected.target, "phase_key": phase_key(s)}
		s.squads[selected.target].overwatch_block = phase_key(s)
		s.unit_abilities.window = {}
	elif rule in [HEROIC, FRAY]:
		s.core_reactions.heroic = {"player": player, "squad": selected.target, "phase_key": phase_key(s), "mode": "fray" if rule == FRAY else "leap"}
		s.core_reactions.charge_closed = true
		s.unit_abilities.window = {}
	elif rule == COUNTER:
		s.squads[selected.target].fights_first = true
		s.fight_selected = selected.target
		s.fight_actor = player
		s.unit_abilities.window = {}
	elif rule == EPIC:
		s.core_reactions.epic = {"player": player, "squad": selected.target, "model": selected.model, "phase_key": phase_key(s)}
		s.fight_selected = selected.target
		s.fight_actor = player
	return {"error": ""}

static func offer_counter(s: Dictionary, fighter: int) -> bool:
	if not enabled(s) or s.phase != "fight" or s.fight_step != "attacks": return false
	if not s.squads.has(fighter) or s.squads[fighter].owner != s.active: return false
	var player: int = 3 - int(s.active)
	var any := false
	s.unit_abilities.window = {"kind": "counter", "owners": [player], "resume_cursor": player, "fighter": fighter}
	for squad: int in s.squads:
		if error(s, player, squad, COUNTER).is_empty(): any = true
	if not any:
		s.unit_abilities.window = {}
		return false
	return true

static func charge_error(s: Dictionary, player: int, squad: int) -> String:
	if not enabled(s): return ""
	if heroic_charger(s, player, squad): return ""
	if charge_closed(s): return "The Charge phase is finished except for the pending Heroic Intervention."
	return ""

static func leap_target_error(s: Dictionary, squad: int, enemy: int) -> String:
	if not enabled(s): return ""
	var heroic: Dictionary = s.core_reactions.get("heroic", {})
	if heroic.get("phase_key", "") != phase_key(s) or int(heroic.get("squad", -1)) != squad: return ""
	if str(heroic.get("mode", "")) != "leap": return ""
	if enemy not in s.core_reactions.get("chargers", []): return "Leap to Defend can only target a unit that declared a charge this phase."
	return ""

static func cap_charge(s: Dictionary, squad: int, maximum: int) -> int:
	return mini(6, maximum) if fray_charger(s, squad) else maximum

static func weapon(s: Dictionary, model: int, profile: Dictionary, melee: bool) -> Dictionary:
	if not melee or not enabled(s) or not s.units.has(model): return profile
	var epic: Dictionary = s.core_reactions.get("epic", {})
	if epic.get("phase_key", "") != phase_key(s) or int(epic.get("model", -1)) != model: return profile
	var result: Dictionary = profile.duplicate(true)
	if not result.has("keywords") or not result.keywords is Dictionary: result.keywords = {}
	else: result.keywords = result.keywords.duplicate(true)
	result.keywords.precision = true
	return result

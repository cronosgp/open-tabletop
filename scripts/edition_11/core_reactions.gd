extends RefCounted
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
## Core e11 reaction stratagems required by the checked Gladius vs Awakened infantry match.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Prevention = preload("res://scripts/edition_11/wound_prevention.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Detachments = preload("res://scripts/edition_11/detachment_stratagems.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const ID := "core-reaction-stratagems-2026-10-tank-shock-v1"
const SMOKE := "smokescreen"
const EXPLOSIVES := "explosives"
const OVERWATCH := "fire-overwatch"
const HEROIC := "heroic-intervention"
const FRAY := "heroic-fray"
const COUNTER := "counteroffensive"
const EPIC := "epic-challenge"
const CRUSHING := "crushing-impact"
const CRUSHING_MORTAL := "crushing-impact-mortal"
const TIGURIUS_MORTAL := "tigurius-telepathic-assault-mortal"
const BRUTALIS_CHARGE := "brutalis-charge"

static func enable(s: Dictionary) -> void:
	if s.has("core_reactions"): return
	s.core_reactions = {"implementation": ID, "overwatch": {}, "heroic": {}, "chargers": [], "charge_closed": false, "epic": {}}
	s.pack_hash = (str(s.pack_hash) + ID).sha256_text()
	s.scope = "Core infantry stratagems: Smokescreen, Explosives, Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge. " + str(s.get("scope", ""))
	for ability in [OVERWATCH, HEROIC, COUNTER, EPIC, EXPLOSIVES, SMOKE, CRUSHING]: Registry.admit(s, ability, ID)

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

static func reopen_heroic_choices(s: Dictionary) -> bool:
	if not enabled(s) or s.phase != "charge" or not charge_closed(s) or not s.get("unit_abilities", {}).get("window", {}).is_empty(): return false
	s.unit_abilities.window = {"kind": "end", "owners": [1, 2], "heroic_continuation": true}
	var owners: Array[int] = []
	for player in [1, 2]:
		if end_available(s, player): owners.append(player)
	if owners.is_empty():
		s.unit_abilities.window = {}
		return false
	s.unit_abilities.window.owners = owners
	return true

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
	if rule == CRUSHING and A.has(s, squad, BRUTALIS_CHARGE): return 0
	if rule == SMOKE and A.has(s, squad, "veiling-smoke"): return 0
	var extra := 1 if rule == FRAY else 0
	var base := 2 if rule == COUNTER else 1
	var discount := maxi(A.discount(s, player, squad), MarineEnhancements.laurels_vigilance_discount(s, player, squad, "heroic-intervention" if rule == FRAY else rule))
	if rule in [HEROIC, FRAY] and A.has(s, squad, "honour-or-death"): discount = maxi(discount, 1)
	var price := maxi(0, base - discount) + extra
	if rule in [HEROIC, FRAY] and A.has(s, squad, "blackwing-mantle") and s.get("unit_abilities", {}).get("used", {}).get("blackwing:%d" % player, "") != phase_key(s): price = maxi(0, price - 1)
	return price

static func error(s: Dictionary, player: int, squad: int, rule: String, model: int = -1, preview_start: bool = false, target: int = -1) -> String:
	if not enabled(s): return "Core reaction stratagems are disabled."
	if not s.squads.has(squad) or s.squads[squad].owner != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
	if s.squads[squad].battle_shocked: return "Battle-shocked units cannot receive friendly stratagems."
	if s.cp.get(player, 0) < cost_of(s, player, squad, rule): return "This stratagem costs %d CP." % cost_of(s, player, squad, rule)
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var blackwing := rule in [HEROIC, FRAY] and A.has(s, squad, "blackwing-mantle")
	if blackwing and s.get("unit_abilities", {}).get("used", {}).get("blackwing:%d" % player, "") == phase_key(s): return "Blackwing Mantle has already been used this phase."
	if rule == SMOKE:
		if s.phase != "shooting" or s.active == player: return "Smokescreen is used at the start of opponent Shooting."
		if not preview_start and (window.get("kind", "") != "start" or window.get("owners", [0])[0] != player): return "Smokescreen requires the start-of-phase decision window."
		if not keyword(s, squad, "SMOKE"): return "Smokescreen requires a SMOKE unit."
	elif rule == EXPLOSIVES:
		if s.phase != "shooting" or s.active != player or not window.is_empty(): return "Explosives requires your open Shooting phase."
		if Queue.engaged(s, squad) or s.squads[squad].shot or s.squads[squad].advanced: return "Explosives requires an unengaged unit that has not advanced or shot."
		if Actions.shooting_blocked(s, squad): return "This unit is not eligible to shoot after starting an action."
		if s.squads[squad].fell_back and not Doctrines.shoot_after_fallback(s, squad): return "This unit is not eligible to shoot after falling back."
		if model not in living(s, squad) or not Terrain.has_keyword(s.units[model], ["explosives", "grenades"]): return "Choose a living EXPLOSIVES/GRENADES model."
	elif rule == OVERWATCH:
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
	elif rule == CRUSHING:
		var charge_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if s.phase != "charge" or s.active != player: return "Tank Shock is used just after your Vehicle ends a Charge move."
		if charge_window.get("kind", "") != CRUSHING or int(charge_window.get("squad", -1)) != squad or charge_window.get("owners", []).is_empty() or int(charge_window.owners[0]) != player: return "Tank Shock requires the immediate post-charge window."
		if model not in living(s, squad) or not Terrain.has_keyword(s.units[model], ["vehicle"]): return "Choose a living VEHICLE model in the charging unit."
		if target != -1 and not crushing_target(s, model, target): return "Tank Shock targets an enemy unit engaged by the selected VEHICLE model."
	else: return "Unknown core reaction."
	for use: Dictionary in s.stratagems.uses:
		if use.player != player: continue
		if use.phase_key != phase_key(s): continue
		var used: String = str(use.stratagem)
		var current_veiling_smoke: bool = rule == SMOKE and A.has(s, squad, "veiling-smoke")
		var previous_veiling_smoke: bool = used == SMOKE and s.squads.has(int(use.squad)) and A.has(s, int(use.squad), "veiling-smoke")
		var smoke_cross_use_exception: bool = rule == SMOKE and used == SMOKE and int(use.squad) != squad and (current_veiling_smoke or previous_veiling_smoke)
		var sentinel_extra_overwatch := rule == OVERWATCH and A.has(s, squad, "sentinel-protocols") and int(use.squad) != squad
		var blackwing_heroic_exception := blackwing and rule in [HEROIC, FRAY] and used in [HEROIC, FRAY]
		if rule == CRUSHING and used == CRUSHING:
			var new_use_is_brutalis: bool = A.has(s, squad, BRUTALIS_CHARGE)
			var prior_use_is_brutalis: bool = s.squads.has(int(use.squad)) and A.has(s, int(use.squad), BRUTALIS_CHARGE)
			if not new_use_is_brutalis and not prior_use_is_brutalis: return "Tank Shock has already been used this phase."
			if new_use_is_brutalis and int(use.squad) == squad: return "This Brutalis unit has already used Tank Shock this phase."
		elif ((used == rule and not sentinel_extra_overwatch and not smoke_cross_use_exception) or (rule == EXPLOSIVES and used == "grenades") or (rule in [HEROIC, FRAY] and used in [HEROIC, FRAY])) and not blackwing_heroic_exception: return "This stratagem has already been used this phase."
		if int(use.squad) == squad and not (blackwing and used in [HEROIC, FRAY]): return "This unit has already been targeted by another stratagem this phase."
	return ""

static func charge_completed(s: Dictionary, player: int, squad: int) -> bool:
	if not enabled(s) or s.phase != "charge" or not s.squads.has(squad) or s.squads[squad].owner != player: return false
	if not bool(s.squads[squad].get("charged", false)) or not s.get("unit_abilities", {}).get("window", {}).is_empty(): return false
	# Validate candidates inside the immediate post-charge window. error() checks
	# that same window as part of normal stratagem validation.
	s.unit_abilities.window = {"kind": CRUSHING, "owners": [player], "squad": squad}
	var eligible := false
	for model: int in living(s, squad):
		if not Terrain.has_keyword(s.units[model], ["vehicle"]): continue
		for enemy: int in s.squads:
			if crushing_target(s, model, enemy) and error(s, player, squad, CRUSHING, model, false, enemy).is_empty(): eligible = true
	if not eligible:
		s.unit_abilities.window = {}
		return false
	return true

static func crushing_target(s: Dictionary, model: int, target: int) -> bool:
	if not s.units.has(model) or not s.squads.has(target) or living(s, target).is_empty(): return false
	if s.units[model].owner == s.squads[target].owner or not Terrain.has_keyword(s.units[model], ["vehicle"]): return false
	for enemy: int in living(s, target):
		if G.edge(s.units[model], s.units[enemy]) <= 2.001: return true
	return false

static func crushing_choices(s: Dictionary, player: int) -> Array:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != CRUSHING or window.get("owners", []).is_empty() or int(window.owners[0]) != player: return []
	var squad := int(window.squad)
	var result: Array = [{"label": "Skip Tank Shock", "action": "crushing-impact-pass", "model": -1, "target": squad, "value": "pass"}]
	for model: int in living(s, squad):
		if not Terrain.has_keyword(s.units[model], ["vehicle"]): continue
		for target: int in s.squads:
			if not crushing_target(s, model, target) or not error(s, player, squad, CRUSHING, model, false, target).is_empty(): continue
			var price := cost_of(s, player, squad, CRUSHING)
			result.append({"label": "Tank Shock: %s → %s with model %d (%d CP)" % [s.squads[squad].name, s.squads[target].name, model, price], "action": "core-stratagem", "model": model, "target": target, "source_squad": squad, "value": CRUSHING})
	return result

static func skip_crushing(s: Dictionary, player: int, selected: Dictionary) -> String:
	if selected not in crushing_choices(s, player) or selected.action != "crushing-impact-pass": return "Choose a Tank Shock target or decline the stratagem."
	s.unit_abilities.window = {}
	return ""

static func choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not enabled(s): return result
	var shot: Dictionary = s.core_reactions.get("overwatch", {})
	if shot.get("phase_key", "") == phase_key(s) and int(shot.get("player", -1)) == player:
		result.append({"label": "Decline remaining Fire Overwatch shooting", "action": "overwatch-pass", "model": -1, "target": int(shot.squad), "value": ""})
	for squad: int in s.squads:
		for model: int in living(s, squad):
			if not error(s, player, squad, EXPLOSIVES, model).is_empty(): continue
			for target: int in s.squads:
				if explosives_target(s, model, target):
					result.append({"label": "Explosives: %s model %d → %s (%d CP)" % [s.squads[squad].name, model, s.squads[target].name, cost_of(s, player, squad, EXPLOSIVES)], "action": "explosives", "model": model, "target": target, "value": EXPLOSIVES})
		if error(s, player, squad, SMOKE).is_empty():
			result.append({"label": "Smokescreen: %s (%d CP)" % [str(s.squads[squad].name).replace(" Squad", ""), cost_of(s, player, squad, SMOKE)], "action": "core-stratagem", "model": -1, "target": squad, "value": SMOKE})
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

static func explosives_target(s: Dictionary, model: int, target: int) -> bool:
	if not s.units.has(model) or not s.squads.has(target) or living(s, target).is_empty(): return false
	if s.units[model].owner == s.squads[target].owner or Queue.engaged(s, target): return false
	var sight := Terrain.targeting(s, model, target)
	return sight.visible and sight.distance <= 8.001

static func throw_explosives(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if not s.units.has(selected.model): return {"error": "Unknown Explosives model."}
	var squad: int = s.units[selected.model].squad
	var failure := error(s, player, squad, EXPLOSIVES, selected.model)
	if not failure.is_empty(): return {"error": failure}
	if not explosives_target(s, selected.model, selected.target): return {"error": "Explosives requires an unengaged visible enemy within 8 inches of this model."}
	if not roller.is_valid(): return {"error": "Explosives requires the host's D6 provider."}
	var rolls: Array[int] = []
	var wounds := 0
	for index in range(6):
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Explosives dice must be integers from 1 to 6."}
		rolls.append(die)
		if die >= 4: wounds += 1
	s.cp[player] -= cost_of(s, player, squad, EXPLOSIVES)
	A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": EXPLOSIVES, "phase_key": phase_key(s), "turn": s.turn})
	s.last_explosives = {"model": selected.model, "squad": squad, "target": selected.target, "rolls": rolls, "mortal_wounds": wounds, "remaining": wounds, "allocations": [], "discarded": 0}
	if wounds > 0: s.unit_abilities.window = {"kind": EXPLOSIVES, "owners": [s.squads[selected.target].owner], "target": selected.target}
	return {"error": ""}

static func explosives_allocations(s: Dictionary, player: int) -> Array:
	return mortal_allocations(s, player, EXPLOSIVES)

static func mortal_allocations(s: Dictionary, player: int, kind: String) -> Array:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != kind or window.get("owners", []).is_empty() or window.owners[0] != player: return []
	var record := _mortal_record(s, kind)
	if record.is_empty() or int(record.get("remaining", 0)) <= 0: return []
	var result: Array = []
	for model: int in Groups.current_models(s, {"target": window.target}, true):
		result.append({"label": "%s: allocate mortal wound to model %d (%d remaining)" % [_mortal_name(kind), model, record.remaining], "action": "mortal-allocate", "model": model, "target": window.target, "value": kind})
	return result

static func allocate_explosives(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	return allocate_mortal(s, player, selected, roller, EXPLOSIVES)

static func allocate_mortal(s: Dictionary, player: int, selected: Dictionary, roller: Callable, kind: String) -> Dictionary:
	if selected not in mortal_allocations(s, player, kind): return {"error": "Choose an eligible mortal-wound recipient."}
	var unit: Dictionary = s.units[selected.model]
	var had_wounds := int(unit.wounds)
	var prevention := Prevention.resolve(1, unit.wounds, UnitPrevention.rules(s, selected.model), "mortal", roller)
	if not prevention.error.is_empty(): return prevention
	unit.wounds -= prevention.lost
	if unit.wounds == 0: Detachments.record_destroyed(s, selected.model)
	var record := _mortal_record(s, kind)
	record.allocations.append({"model": selected.model, "prevention": prevention})
	record.remaining -= 1
	if record.remaining == 0 or living(s, selected.target).is_empty():
		record.discarded = record.remaining
		record.remaining = 0
		s.unit_abilities.window = {}
	if kind == EXPLOSIVES: s.last_explosives = record
	elif kind == "incursor-haywire-mortal": s.last_incursor_haywire_mine = record
	elif kind == CRUSHING_MORTAL: s.last_crushing_impact = record
	elif kind == TIGURIUS_MORTAL: s.last_tigurius_telepathic_assault = record
	else: s.last_hammer_of_wrath = record
	if had_wounds > 0 and unit.wounds <= 0:
		var demise := DeadlyDemise.begin(s, [int(selected.model)], roller)
		if not demise.error.is_empty(): return demise
		if not demise.get("complete", true): return demise
	if s.get("pending_attack", {}).is_empty() and s.get("unit_abilities", {}).get("window", {}).is_empty(): A.open_destroyed_mark_replacements(s)
	if kind == CRUSHING_MORTAL and s.get("unit_abilities", {}).get("window", {}).is_empty(): reopen_heroic_choices(s)
	return {"error": ""}

static func _mortal_record(s: Dictionary, kind: String) -> Dictionary:
	match kind:
		EXPLOSIVES: return s.get("last_explosives", {})
		"incursor-haywire-mortal": return s.get("last_incursor_haywire_mine", {})
		"hammer-of-wrath-mortal": return s.get("last_hammer_of_wrath", {})
		CRUSHING_MORTAL: return s.get("last_crushing_impact", {})
		TIGURIUS_MORTAL: return s.get("last_tigurius_telepathic_assault", {})
	return {}

static func _mortal_name(kind: String) -> String:
	if kind == EXPLOSIVES: return "Explosives"
	if kind == "incursor-haywire-mortal": return "Haywire Mine"
	if kind == CRUSHING_MORTAL: return "Tank Shock"
	if kind == TIGURIUS_MORTAL: return "Telepathic Assault"
	return "Hammer of Wrath"

static func apply(s: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var rule := str(selected.value)
	if rule == CRUSHING: return apply_crushing(s, player, selected, roller)
	var failure := error(s, player, selected.target, rule, selected.model)
	if not failure.is_empty(): return {"error": failure}
	var blackwing := rule in [HEROIC, FRAY] and A.has(s, selected.target, "blackwing-mantle")
	s.cp[player] -= cost_of(s, player, selected.target, rule)
	var laurels_discount := MarineEnhancements.laurels_vigilance_discount(s, player, selected.target, "heroic-intervention" if rule in [HEROIC, FRAY] else rule)
	A.consume_discount(s, player, selected.target)
	if laurels_discount > 0: MarineEnhancements.consume_laurels_vigilance(s, player)
	var recorded := HEROIC if rule == FRAY else rule
	if blackwing: s.unit_abilities.used["blackwing:%d" % player] = phase_key(s)
	else: s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": recorded, "phase_key": phase_key(s), "turn": s.turn})
	if rule == SMOKE:
		var smoke_records: Variant = s.core_reactions.get("smoke", {})
		if not smoke_records is Array:
			smoke_records = [] if smoke_records.is_empty() else [smoke_records.duplicate(true)]
		smoke_records.append({"squad": selected.target, "phase_key": phase_key(s)})
		s.core_reactions["smoke"] = smoke_records
	elif rule == OVERWATCH:
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

static func apply_crushing(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var model := int(selected.get("model", -1))
	var squad := int(selected.get("source_squad", s.units.get(model, {}).get("squad", -1)))
	if selected not in crushing_choices(s, player): return {"error": "Choose a current Tank Shock target for the charging Vehicle."}
	var failure := error(s, player, squad, CRUSHING, model, false, int(selected.target))
	if not failure.is_empty(): return {"error": failure}
	if not roller.is_valid(): return {"error": "Tank Shock requires the host's D6 provider."}
	var profile := DefenderGroups.profile(s, model)
	if not profile.get("error", "").is_empty(): return {"error": "The selected Vehicle model has no valid Toughness profile."}
	var toughness := int(profile.toughness)
	var rolls: Array[int] = []
	var mortal_wounds := 0
	for _die in range(toughness):
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Tank Shock dice must be integers from 1 to 6."}
		rolls.append(die)
		if die >= 5: mortal_wounds = mini(6, mortal_wounds + 1)
	var cost := cost_of(s, player, squad, CRUSHING)
	s.cp[player] -= cost
	if cost > 0: A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": CRUSHING, "phase_key": phase_key(s), "turn": s.turn, "brutalis_charge": A.has(s, squad, BRUTALIS_CHARGE)})
	s.last_crushing_impact = {"model": model, "squad": squad, "target": int(selected.target), "toughness": toughness, "rolls": rolls, "mortal_wounds": mortal_wounds, "remaining": mortal_wounds, "allocations": [], "discarded": 0, "cp_cost": cost}
	if mortal_wounds > 0: s.unit_abilities.window = {"kind": CRUSHING_MORTAL, "owners": [s.squads[int(selected.target)].owner], "target": int(selected.target)}
	else:
		s.unit_abilities.window = {}
		reopen_heroic_choices(s)
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

static func start_available(s: Dictionary, player: int) -> bool:
	if not enabled(s) or s.phase != "shooting" or s.active == player: return false
	for squad: int in s.squads:
		if error(s, player, squad, SMOKE, -1, true).is_empty(): return true
	return false

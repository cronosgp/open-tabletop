extends RefCounted
## Current e11 Gladius/Awakened stratagems, enabled only in the versioned checked-roster profile.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ID := "gladius-awakened-stratagems-11e-v5"
const ADAPTIVE := "gladius-adaptive-strategy"
const STORM := "gladius-storm-of-devastation"
const ARMOUR := "gladius-armour-of-contempt"
const MIGHT := "gladius-might-of-angels"
const WORTHY := "gladius-a-worthy-death"
const TACTICS := "gladius-responsive-tactics"
const HUNGRY := "protocol-of-the-hungry-void"
const SUDDEN := "protocol-of-the-sudden-storm"
const TYRANT := "protocol-of-the-conquering-tyrant"
const UNDYING := "protocol-of-the-undying-legions"
const ETERNAL := "protocol-of-the-eternal-revenant"
const VENGEFUL := "protocol-of-the-vengeful-stars"
const Queue = preload("res://scripts/edition_11/fight_queue.gd")

static func enable(s: Dictionary) -> void:
	s.detachment_stratagems = {"implementation": ID, "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	for ability in [ADAPTIVE, STORM, ARMOUR, MIGHT, WORTHY, TACTICS, HUNGRY, SUDDEN, TYRANT, UNDYING, ETERNAL, VENGEFUL]: Registry.admit(s, ability, ID)

static func enabled(s: Dictionary) -> bool:
	return s.get("detachment_stratagems", {}).get("implementation", "") == ID

static func living(s: Dictionary, squad: int) -> Array[int]:
	# A unit in reserves can still be selected by rules that target an army unit.
	var result: Array[int] = []
	for model: int in s.units:
		if s.units[model].squad == squad and s.units[model].wounds > 0: result.append(model)
	return result

static func led(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		if s.units[model].get("attachment_role", "") == "leader" and "CHARACTER" in str(s.units[model].keywords).to_upper(): return true
	return false

static func phase_key(s: Dictionary) -> String:
	return "%d:%s" % [s.turn, s.phase]

static func error(s: Dictionary, player: int, squad: int, rule: String, model: int = -1) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	if rule != ETERNAL:
		if not s.squads.has(squad) or s.squads[squad].owner != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
		if s.squads[squad].battle_shocked: return "Battle-shocked units cannot receive friendly stratagems."
	if rule == ADAPTIVE:
		if s.phase != "command" or s.active != player or not s.get("combat_doctrines", {}).get("gladius", false) or player not in s.combat_doctrines.owners: return "Adaptive Strategy requires your Gladius Command phase."
	elif rule == STORM:
		if s.phase != "shooting" or s.active != player or not Marines.marine_army(s, player) or s.squads[squad].shot: return "Storm of Devastation requires your Gladius Shooting phase and a unit that has not shot."
	elif rule == ARMOUR:
		if not Marines.marine_army(s, player): return "Armour of Contempt requires a Gladius Adeptus Astartes unit."
		if s.phase == "shooting":
			if s.active == player: return "Armour of Contempt is used in your opponent's Shooting phase."
		elif s.phase != "fight": return "Armour of Contempt requires your opponent's Shooting phase or the Fight phase."
	elif rule == MIGHT:
		if s.phase != "fight" or not Marines.marine_army(s, player) or s.squads[squad].fought: return "Might of Angels requires a Gladius unit selected to fight."
		if s.fight_selected != squad and s.fight_actor != player: return "Might of Angels requires a Gladius unit selected to fight."
	elif rule == HUNGRY:
		if s.phase != "fight" or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].fought or s.get("fight_selected", -1) == squad: return "Hungry Void requires an Awakened unit not yet selected to fight."
	elif rule == SUDDEN:
		if s.phase != "movement" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []): return "Sudden Storm requires your Awakened Movement phase."
	elif rule == TYRANT:
		if s.phase != "shooting" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].shot: return "Conquering Tyrant requires your Awakened Shooting phase and a unit that has not shot."
	elif rule == WORTHY:
		if s.phase != "fight" or not Marines.marine_army(s, player) or s.squads[squad].fought: return "A Worthy Death requires a Gladius unit that has not been selected to fight."
	elif rule == TACTICS:
		if s.phase != "movement" or s.active == player or not Marines.marine_army(s, player): return "Responsive Tactics is used in your opponent's Movement phase."
		if Queue.engaged(s, squad) or not _infantry_or_mounted(s, squad): return "Responsive Tactics requires an unengaged Adeptus Astartes Infantry or Mounted unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		if moved.get("phase_key", "") != phase_key(s) or int(moved.get("owner", player)) == player: return "An enemy unit must have just ended a move."
		if not _within(s, squad, int(moved.squad), 8.0): return "Responsive Tactics requires the enemy move to end within 8 inches."
	elif rule == UNDYING:
		var after: Dictionary = s.detachment_stratagems.get("after", {})
		if player not in s.get("awakened_dynasty", {}).get("owners", []): return "Undying Legions requires an Awakened unit."
		if after.get("phase_key", "") != phase_key(s) or squad not in after.get("victims", []): return "Undying Legions is used just after an enemy unit destroys models in your unit."
	elif rule == ETERNAL:
		if player not in s.get("awakened_dynasty", {}).get("owners", []): return "Eternal Revenant requires an Awakened Infantry Character."
		if s.get("unit_abilities", {}).get("window", {}).get("kind", "") != "end": return "Eternal Revenant is used at the end of the phase."
		var destroyed := _destroyed_record(s, player, squad, model)
		if destroyed.is_empty(): return "Eternal Revenant requires a Necron Infantry Character destroyed this phase."
		if s.detachment_stratagems.revived.has(destroyed.model): return "Each model can return with Eternal Revenant only once per battle."
	elif rule == VENGEFUL:
		if s.phase != "shooting" or s.active == player or player not in s.get("awakened_dynasty", {}).get("owners", []): return "Vengeful Stars is used in your opponent's Shooting phase."
		if not s.detachment_stratagems.get("vengeful", {}).is_empty() and s.detachment_stratagems.vengeful.get("phase_key", "") == phase_key(s): return "A Vengeful Stars shooting is already waiting."
		if not _character_unit(s, squad): return "Vengeful Stars requires a living Necron Character unit."
		var after: Dictionary = s.detachment_stratagems.get("after", {})
		if after.get("phase_key", "") != phase_key(s) or after.get("wiped", []).is_empty(): return "Vengeful Stars is used just after an enemy unit destroys a nearby Necron unit."
		if living(s, int(after.get("attacker", -1))).is_empty(): return "The destroying unit must still be on the battlefield."
		if not _near_wiped(s, squad, after.wiped, 6.0): return "Vengeful Stars requires a Character within 6 inches of the destroyed unit."
	else: return "Unknown detachment stratagem."
	if s.cp.get(player, 0) < maxi(0, 1 - A.discount(s, player, squad)): return "This stratagem costs 1 CP; arm an eligible discount first."
	for use: Dictionary in s.stratagems.uses:
		if use.player == player and use.phase_key == phase_key(s):
			if use.stratagem == rule: return "This stratagem has already been used this phase."
			if use.squad == squad: return "This unit already received a stratagem this phase."
	return ""

static func choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not enabled(s): return result
	for squad: int in s.squads:
		if error(s, player, squad, ADAPTIVE).is_empty():
			for doctrine in ["devastator", "tactical", "assault"]:
				result.append({"label": "Gladius Adaptive Strategy: %s / %s (%d CP, replaces doctrine)" % [s.squads[squad].name, doctrine, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": doctrine})
		if error(s, player, squad, STORM).is_empty(): result.append({"label": "Gladius Storm of Devastation: %s (ranged Ignores Cover; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM})
		if error(s, player, squad, ARMOUR).is_empty(): result.append({"label": "Gladius Armour of Contempt: %s (worsen incoming AP by 1; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": ARMOUR})
		if error(s, player, squad, MIGHT).is_empty(): result.append({"label": "Gladius Might of Angels: %s (melee Lance; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MIGHT})
		if error(s, player, squad, HUNGRY).is_empty(): result.append({"label": "Hungry Void: %s (+1 melee S; led: +1 AP; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": HUNGRY})
		if error(s, player, squad, SUDDEN).is_empty(): result.append({"label": "Sudden Storm: %s (ranged Assault this turn%s; %d CP)" % [s.squads[squad].name, "; led: re-roll Advance" if led(s, squad) else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SUDDEN})
		if error(s, player, squad, TYRANT).is_empty(): result.append({"label": "Conquering Tyrant: %s (half range hit re-roll; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TYRANT})
		if error(s, player, squad, WORTHY).is_empty(): result.append({"label": "Gladius A Worthy Death: %s (4+ stay to fight; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": WORTHY})
		if error(s, player, squad, TACTICS).is_empty(): result.append({"label": "Gladius Responsive Tactics: %s (D6 inch reaction move; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TACTICS})
		if error(s, player, squad, UNDYING).is_empty(): result.append({"label": "Undying Legions: %s (Reanimation D3%s; %d CP)" % [s.squads[squad].name, "+1 if led" if led(s, squad) else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": UNDYING})
		if error(s, player, squad, VENGEFUL).is_empty(): result.append({"label": "Vengeful Stars: %s shoots the destroying unit (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": VENGEFUL})
		for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
			if int(record.get("owner", -1)) != player or record.get("phase_key", "") != phase_key(s): continue
			if error(s, player, int(record.squad), ETERNAL, int(record.model)).is_empty():
				result.append({"label": "Eternal Revenant: return model %d (%d CP, half wounds, unattached)" % [int(record.model), maxi(0, 1 - A.discount(s, player, int(record.squad)))], "action": "detachment-stratagem", "model": int(record.model), "target": int(record.squad), "value": ETERNAL})
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("player", -1)) == player:
		result.append({"label": "Decline Vengeful Stars shooting", "action": "vengeful-pass", "model": -1, "target": int(vengeful.squad), "value": ""})
	return result

static func rule_of(value: String) -> String:
	if value in ["devastator", "tactical", "assault"]: return ADAPTIVE
	return value

static func apply(s: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var rule := rule_of(str(selected.value))
	var failure := error(s, player, selected.target, rule, selected.model)
	if not failure.is_empty(): return {"error": failure}
	if rule == ADAPTIVE and selected.value not in ["devastator", "tactical", "assault"]: return {"error": "Invalid doctrine."}
	var inches := 0
	if rule == TACTICS:
		if not roller.is_valid(): return {"error": "Responsive Tactics requires the host's D6."}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "Responsive Tactics dice must be 1–6."}
		inches = int(rolled)
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, selected.target))
	A.consume_discount(s, player, selected.target)
	s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": rule, "phase_key": phase_key(s), "turn": s.turn})
	if rule == ADAPTIVE: s.unit_abilities.doctrines[selected.target] = {"doctrine": selected.value}
	elif rule == STORM: s.detachment_stratagems.storm[selected.target] = {"phase_key": phase_key(s)}
	elif rule == ARMOUR: s.detachment_stratagems.armour[selected.target] = {"phase_key": phase_key(s), "attacker": -1}
	elif rule == MIGHT: s.detachment_stratagems.might[selected.target] = {"phase_key": phase_key(s)}
	elif rule == WORTHY: s.detachment_stratagems.worthy[selected.target] = {"phase_key": phase_key(s)}
	elif rule == HUNGRY: s.detachment_stratagems.hungry[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == SUDDEN: s.detachment_stratagems.sudden[selected.target] = {"turn": s.turn, "phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == TYRANT: s.detachment_stratagems.tyrant[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == TACTICS:
		var origins := {}
		for model: int in living(s, selected.target): origins[model] = s.units[model].position
		s.detachment_stratagems.tactics[selected.target] = {"inches": inches, "origins": origins, "phase_key": phase_key(s)}
		s.unit_abilities.window = {"kind": "tactics", "owners": [player], "squad": selected.target, "positions": {}}
	elif rule == UNDYING:
		var victims: Array = s.detachment_stratagems.after.get("victims", [])
		victims.erase(selected.target)
		s.detachment_stratagems.after.victims = victims
		return {"error": "", "undying": selected.target, "led": led(s, selected.target)}
	elif rule == VENGEFUL:
		s.detachment_stratagems.vengeful = {"player": player, "squad": selected.target, "attacker": int(s.detachment_stratagems.after.attacker), "phase_key": phase_key(s)}
	elif rule == ETERNAL:
		var destroyed := _destroyed_record(s, player, selected.target, selected.model)
		s.detachment_stratagems.revived[destroyed.model] = true
		s.unit_abilities.window = {"kind": "eternal", "owners": [player], "model": destroyed.model, "squad": destroyed.squad, "origin": destroyed.position, "max_wounds": destroyed.max_wounds, "positions": {}}
	else: return {"error": "Unknown detachment stratagem."}
	return {"error": ""}

static func hungry_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.hungry.get(squad, {}).get("phase_key", "") == phase_key(s)

static func storm_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.storm.get(squad, {}).get("phase_key", "") == phase_key(s)

static func might_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.might.get(squad, {}).get("phase_key", "") == phase_key(s)

static func sudden_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and int(s.detachment_stratagems.sudden.get(squad, {}).get("turn", -1)) == int(s.turn)

static func sudden_led_advance(s: Dictionary, squad: int) -> bool:
	return sudden_active(s, squad) and s.detachment_stratagems.sudden.get(squad, {}).get("led", false) == true and s.phase == "movement"

static func open_advance(s: Dictionary, player: int, squad: int, rolls: Array, draft: Dictionary) -> bool:
	if not enabled(s) or not s.has("stratagems"): return false
	s.stratagems.pending = {"kind": "after_advance_roll", "player": player, "squad": squad, "phase_key": phase_key(s), "rolls": rolls.duplicate(), "draft": draft.duplicate(true), "sudden": true}
	return true

static func tyrant_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.tyrant.get(squad, {}).get("phase_key", "") == phase_key(s)

static func weapon(s: Dictionary, squad: int, original: Dictionary, profile: Dictionary, melee: bool) -> Dictionary:
	var copy := profile
	if not melee and storm_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["ignores-cover"] = true
	if not melee and sudden_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["assault"] = true
	if melee and might_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["lance"] = true
	if melee and hungry_active(s, squad):
		copy = copy.duplicate(true)
		copy.strength += 1
		if s.detachment_stratagems.hungry[squad].led and int(copy.ap) >= int(original.ap): copy.ap -= 1
	return copy

static func defend(s: Dictionary, attacker: int, target: int, profile: Dictionary) -> Dictionary:
	if not enabled(s): return profile
	var record: Dictionary = s.detachment_stratagems.armour.get(target, {})
	if record.get("phase_key", "") != phase_key(s): return profile
	if int(record.get("attacker", -1)) not in [-1, attacker]: return profile
	if int(record.attacker) == -1: record.attacker = attacker
	var copy := profile.duplicate(true)
	copy.ap = mini(0, int(copy.ap) + 1)
	return copy

static func hit_policy(s: Dictionary, squad: int, distance: float, range_inches: float) -> String:
	if not tyrant_active(s, squad) or not is_finite(distance) or not is_finite(range_inches) or range_inches <= 0.0: return ""
	if distance > range_inches / 2.0: return ""
	return "failed" if s.detachment_stratagems.tyrant[squad].led else "ones"

static func lance_wound(s: Dictionary, squad: int, profile: Dictionary) -> bool:
	return profile.get("keywords", {}).get("lance", false) == true and s.squads[squad].get("charged", false)

static func worthy_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.worthy.get(squad, {}).get("phase_key", "") == phase_key(s) and not s.squads[squad].fought

static func hold_destroyed(s: Dictionary, model: int, roller: Callable) -> Dictionary:
	if not enabled(s) or not s.units.has(model): return {"error": "", "held": false}
	var unit: Dictionary = s.units[model]
	if unit.wounds > 0 or unit.get("lingering", false): return {"error": "", "held": false}
	if worthy_active(s, unit.squad):
		if not roller.is_valid(): return {"error": "A Worthy Death requires the host's D6."}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "A Worthy Death dice must be 1–6."}
		if rolled >= 4:
			unit.wounds = 1
			unit.lingering = true
			return {"error": "", "held": true}
	record_destroyed(s, model)
	return {"error": "", "held": false}

static func remove_lingering(s: Dictionary, squad: int = -1) -> void:
	if not enabled(s): return
	for model: int in s.units:
		if s.units[model].get("lingering", false) and (squad == -1 or s.units[model].squad == squad):
			s.units[model].wounds = 0
			s.units[model].erase("lingering")
			record_destroyed(s, model)

static func record_move(s: Dictionary, squad: int) -> void:
	if enabled(s) and s.squads.has(squad): s.detachment_stratagems.last_move = {"squad": squad, "owner": s.squads[squad].owner, "phase_key": phase_key(s)}

static func after_attacks(s: Dictionary, attacker: int, targets: Array, killed: int) -> void:
	if not enabled(s) or killed <= 0: return
	var victims: Array = []
	var wiped: Array = []
	for target: Variant in targets:
		if not target is int or not s.squads.has(target): continue
		var lost := false
		var origin := Vector2.ZERO
		var count := 0
		for model: int in s.units:
			if s.units[model].squad != target: continue
			origin += s.units[model].position
			count += 1
			if s.units[model].wounds <= 0: lost = true
		if count > 0: origin /= float(count)
		if not lost: continue
		if living(s, target).is_empty(): wiped.append({"squad": target, "origin": origin, "attacker": attacker})
		else: victims.append(target)
	if not victims.is_empty() or not wiped.is_empty(): s.detachment_stratagems.after = {"phase_key": phase_key(s), "attacker": attacker, "victims": victims, "wiped": wiped}

static func record_destroyed(s: Dictionary, model: int) -> void:
	if not enabled(s) or not s.units.has(model): return
	var unit: Dictionary = s.units[model]
	if unit.wounds > 0 or unit.get("lingering", false): return
	if not _has_keyword(unit, "CHARACTER") or not _has_keyword(unit, "INFANTRY"): return
	if unit.owner not in s.get("awakened_dynasty", {}).get("owners", []): return
	if s.detachment_stratagems.revived.has(model): return
	for record: Dictionary in s.detachment_stratagems.destroyed:
		if int(record.model) == model and record.phase_key == phase_key(s): return
	s.detachment_stratagems.destroyed.append({"model": model, "squad": unit.squad, "owner": unit.owner, "position": unit.position, "max_wounds": int(unit.get("max_wounds", 1)), "phase_key": phase_key(s)})

static func eternal_pending(s: Dictionary, owner: int) -> bool:
	if not enabled(s): return false
	for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
		if int(record.get("owner", -1)) == owner and record.get("phase_key", "") == phase_key(s) and not s.detachment_stratagems.revived.has(record.model): return true
	return false

static func vengeful_actor(s: Dictionary) -> int:
	if not enabled(s): return -1
	var shot: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if shot.get("phase_key", "") != phase_key(s): return -1
	return int(shot.get("player", -1))

static func vengeful_shooter(s: Dictionary, squad: int) -> bool:
	return vengeful_actor(s) > 0 and int(s.detachment_stratagems.vengeful.get("squad", -1)) == squad

static func clear_vengeful(s: Dictionary) -> void:
	if enabled(s): s.detachment_stratagems.vengeful = {}

static func _infantry_or_mounted(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		for keyword: Variant in s.units[model].get("keywords", []):
			if str(keyword).strip_edges().to_upper() in ["INFANTRY", "MOUNTED"]: return true
	return false

static func _within(s: Dictionary, squad: int, other: int, inches: float) -> bool:
	for model: int in living(s, squad):
		if G.distance_to_target(s, s.units[model], other) <= inches + 0.001: return true
	return false

static func tactics_position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "tactics" or not s.units.has(model) or s.units[model].squad != window.squad: return "This is not a Responsive Tactics placement."
	var record: Dictionary = s.detachment_stratagems.tactics.get(window.squad, {})
	if not record.has("origins") or not record.origins.has(model): return "This model cannot make the reaction move."
	if not point.is_finite(): return "Choose a finite reaction destination."
	if record.origins[model].distance_to(point) > float(record.inches) + 0.001: return "Responsive Tactics is a normal move of up to D6 inches."
	var half: Vector2 = s.board_size / 2.0
	var radius: float = float(s.units[model].radius)
	if absf(point.x) + radius > half.x or absf(point.y) + radius > half.y: return "The whole base must fit on the battlefield."
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0 or not s.units[other].get("on_battlefield", true): continue
		var position: Vector2 = window.positions.get(other, s.units[other].position)
		if point.distance_to(position) < radius + float(s.units[other].radius) - 0.001: return "Reaction move bases cannot overlap."
		if s.units[other].owner != s.units[model].owner and G.edge({"position": point, "radius": radius}, {"position": position, "radius": s.units[other].radius}) <= 2.001: return "The reaction move must end unengaged."
	return ""

static func confirm_tactics(s: Dictionary) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "tactics": return {"error": "No Responsive Tactics move is pending."}
	var projected := s.duplicate(true)
	for model: int in living(s, window.squad):
		var point: Vector2 = window.positions.get(model, s.units[model].position)
		var error := tactics_position_error(s, model, point)
		if not error.is_empty(): return {"error": error}
		projected.units[model].position = point
	if Queue.engaged(projected, window.squad): return {"error": "The reaction move must end unengaged."}
	for model: int in living(s, window.squad): s.units[model].position = window.positions.get(model, s.units[model].position)
	s.unit_abilities.window = {}
	return {"error": ""}

static func eternal_position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "eternal" or int(window.get("model", -1)) != model: return "This is not an Eternal Revenant placement."
	if not s.units.has(model): return "Choose the destroyed Infantry Character."
	if not point.is_finite(): return "Choose a finite set-up position."
	var radius: float = float(s.units[model].radius)
	var half: Vector2 = s.board_size / 2.0
	if absf(point.x) + radius > half.x or absf(point.y) + radius > half.y: return "The whole base must fit on the battlefield."
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0 or not s.units[other].get("on_battlefield", true): continue
		var position: Vector2 = window.positions.get(other, s.units[other].position)
		if point.distance_to(position) < radius + float(s.units[other].radius) - 0.001: return "Returned bases cannot overlap."
		if s.units[other].owner != s.units[model].owner and G.edge({"position": point, "radius": radius}, {"position": position, "radius": s.units[other].radius}) <= 2.001: return "Eternal Revenant must set up unengaged."
	return ""

static func confirm_eternal(s: Dictionary) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "eternal": return {"error": "No Eternal Revenant set-up is pending."}
	var model: int = int(window.model)
	if not window.positions.has(model): return {"error": "Preview the returned model's position before confirming."}
	var point: Vector2 = window.positions[model]
	var error := eternal_position_error(s, model, point)
	if not error.is_empty(): return {"error": error}
	_detach_revived(s, model)
	s.units[model].position = point
	s.units[model].on_battlefield = true
	s.units[model].wounds = maxi(1, ceili(float(window.max_wounds) / 2.0))
	s.units[model].erase("lingering")
	s.squads[s.units[model].squad].starting_strength = 1
	s.squads[s.units[model].squad].set_up_this_turn = true
	s.squads[s.units[model].squad].moved = true
	s.squads[s.units[model].squad].shot = true
	s.squads[s.units[model].squad].fought = true
	s.unit_abilities.window = {}
	return {"error": ""}

static func _has_keyword(unit: Dictionary, word: String) -> bool:
	for keyword: Variant in unit.get("keywords", []):
		if str(keyword).strip_edges().to_upper() == word: return true
	return false

static func _character_unit(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		if _has_keyword(s.units[model], "CHARACTER"): return true
	return false

static func _near_wiped(s: Dictionary, squad: int, wiped: Array, inches: float) -> bool:
	for record: Variant in wiped:
		if not record is Dictionary: continue
		var origin: Vector2 = record.origin
		for model: int in living(s, squad):
			if s.units[model].position.distance_to(origin) - float(s.units[model].radius) <= inches + 0.001: return true
	return false

static func _destroyed_record(s: Dictionary, player: int, squad: int, model: int) -> Dictionary:
	for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
		if record.get("phase_key", "") != phase_key(s) or int(record.owner) != player: continue
		if int(record.squad) != squad: continue
		if model != -1 and int(record.model) != model: continue
		return record
	return {}

static func _free_squad(s: Dictionary) -> int:
	var highest := 0
	for squad: int in s.squads: highest = maxi(highest, squad)
	return highest + 1

static func _detach_revived(s: Dictionary, model: int) -> void:
	var unit: Dictionary = s.units[model]
	if not unit.has("attachment_role") or unit.attachment_role == "bodyguard": return
	var body: int = unit.squad
	var origin: int = int(unit.get("component_squad", -1))
	if origin <= 0 or s.squads.has(origin): origin = _free_squad(s)
	var template: Dictionary = s.squads[body].duplicate(true)
	template.attached = false
	template.erase("components")
	template.starting_strength = 1
	s.squads[origin] = template
	if s.squads.has(body):
		s.squads[body].starting_strength = maxi(1, int(s.squads[body].starting_strength) - 1)
		var kept: Array = []
		for component: Dictionary in s.squads[body].get("components", []):
			if int(component.get("squad", -1)) != int(unit.get("component_squad", origin)): kept.append(component)
		s.squads[body].components = kept
		if kept.size() <= 1: s.squads[body].attached = false
	unit.squad = origin
	unit.erase("attachment_role")
	unit.erase("component_squad")

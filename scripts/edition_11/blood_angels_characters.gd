extends RefCounted
## Local Blood Angels character triggers that need casualty or post-fight timing.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

const DEATH_VISIONS_WINDOW := "blood-angels-death-visions"
const DEATH_VISIONS_MORTAL := "blood-angels-death-visions-mortal"
const DEATH_VISIONS_USE := "death-visions-use"
const DEATH_VISIONS_PASS := "death-visions-pass"

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _is_death_captain(identity: String) -> bool:
	return identity in ["death-company-captain", "death-company-captain-with-jump-pack"]

static func record_death_visions(state: Dictionary, model: int) -> void:
	if not UnitAbilities.enabled(state) or str(state.get("phase", "")) != "fight" or not state.get("units", {}).has(model): return
	var pending_attack: Dictionary = state.get("pending_attack", {})
	if pending_attack.is_empty() or not bool(pending_attack.get("melee", false)): return
	var victim: Dictionary = state.units[model]
	if not _is_death_captain(UnitAbilities.identity(victim)): return
	var attacker := int(pending_attack.get("squad", -1))
	var victim_squad := int(victim.get("squad", -1))
	if not state.get("squads", {}).has(attacker) or not state.get("squads", {}).has(victim_squad): return
	if int(state.squads[attacker].get("owner", -1)) == int(state.squads[victim_squad].get("owner", -2)): return
	var warlord_in_unit := false
	var engaged_with_attacker := false
	for enemy_model: int in Geometry.alive(state, attacker):
		var enemy: Dictionary = state.units[enemy_model]
		if "WARLORD" in enemy.get("keywords", []): warlord_in_unit = true
		if Geometry.within_engagement(victim, enemy): engaged_with_attacker = true
	if not state.get("unit_abilities", {}).has("death_visions_triggers"):
		state.unit_abilities.death_visions_triggers = []
	var triggers: Array = state.unit_abilities.death_visions_triggers.duplicate(true)
	triggers.append({"model": model, "owner": int(victim.get("owner", -1)), "attacker": attacker,
		"warlord_engaged": warlord_in_unit and engaged_with_attacker, "phase_key": phase_key(state)})
	state.unit_abilities.death_visions_triggers = triggers

static func after_fight(state: Dictionary, attacker: int) -> bool:
	if not UnitAbilities.enabled(state) or str(state.get("phase", "")) != "fight" or not state.get("squads", {}).has(attacker): return false
	var pending: Array = state.get("unit_abilities", {}).get("death_visions_triggers", []).duplicate(true)
	var queue: Array = []
	var remaining: Array = []
	for record: Variant in pending:
		if not record is Dictionary: continue
		if int(record.get("attacker", -1)) == attacker and str(record.get("phase_key", "")) == phase_key(state): queue.append(record)
		else: remaining.append(record)
	if queue.is_empty(): return false
	state.unit_abilities.death_visions_triggers = remaining
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": DEATH_VISIONS_WINDOW, "owners": [int(queue[0].get("owner", -1))],
		"queue": queue, "resume_window": previous, "phase_key": phase_key(state)}
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != DEATH_VISIONS_WINDOW or window.get("owners", []) != [player] or str(window.get("phase_key", "")) != phase_key(state): return result
	var queue: Array = window.get("queue", [])
	if queue.is_empty(): return result
	var trigger: Dictionary = queue[0]
	var target := int(trigger.get("attacker", -1))
	var model := int(trigger.get("model", -1))
	if state.get("squads", {}).has(target) and not Geometry.alive(state, target).is_empty():
		result.append({"label": "Death Visions of Sanguinius: use Captain %d against %s" % [model, str(state.squads[target].get("name", "the enemy unit"))], "action": DEATH_VISIONS_USE, "model": model, "target": target, "value": ""})
	result.append({"label": "Pass Death Visions of Sanguinius for Captain %d" % model, "action": DEATH_VISIONS_PASS, "model": model, "target": target, "value": ""})
	return result

static func _advance_window(state: Dictionary, window: Dictionary) -> Dictionary:
	var queue: Array = window.get("queue", []).duplicate(true)
	if not queue.is_empty(): queue.pop_front()
	if queue.is_empty(): return window.get("resume_window", {})
	window.queue = queue
	window.owners = [int(queue[0].get("owner", -1))]
	return window

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Death Visions of Sanguinius is available only after the enemy unit that destroyed this Captain has fought."}
	var window: Dictionary = state.unit_abilities.window.duplicate(true)
	var trigger: Dictionary = window.queue[0]
	var model := int(trigger.get("model", -1))
	var target := int(trigger.get("attacker", -1))
	if selected.action == DEATH_VISIONS_PASS:
		state.unit_abilities.window = _advance_window(state, window)
		return {"error": "", "message": "Death Visions of Sanguinius was passed."}
	if not roller.is_valid(): return {"error": "Death Visions of Sanguinius requires the host's dice."}
	var roll := RandomStat.roll("D6", roller)
	if not str(roll.get("error", "")).is_empty(): return roll
	var modifier := 2 if bool(trigger.get("warlord_engaged", false)) else 0
	var total := int(roll.get("value", 0)) + modifier
	var damage := 0
	var damage_roll: Dictionary = {}
	if total in [2, 3]:
		damage_roll = RandomStat.roll("D3", roller)
		if not str(damage_roll.get("error", "")).is_empty(): return damage_roll
		damage = int(damage_roll.value)
	elif total in [4, 5]: damage = 3
	elif total >= 6:
		damage_roll = RandomStat.roll("D3+3", roller)
		if not str(damage_roll.get("error", "")).is_empty(): return damage_roll
		damage = int(damage_roll.value)
	var follow_window := _advance_window(state, window)
	var record := {"source": model, "source_name": "Death Visions of Sanguinius", "owner": int(state.squads[target].get("owner", -1)),
		"target": target, "phase_key": phase_key(state), "roll": roll, "modifier": modifier, "total": total,
		"damage_roll": damage_roll, "total_wounds": damage, "remaining": damage, "allocations": [], "discarded": 0, "stage": "complete" if damage <= 0 else "allocating"}
	state.last_death_visions = record
	state.unit_abilities.window = follow_window
	if damage > 0 and not Geometry.alive(state, target).is_empty():
		state.unit_abilities.window = {"kind": DEATH_VISIONS_MORTAL, "owners": [int(state.squads[target].get("owner", -1))],
			"target": target, "resume_window": follow_window}
	elif damage > 0:
		record.discarded = damage
		record.remaining = 0
	return {"error": "", "message": "Death Visions of Sanguinius: D6 %d + %d = %d; %d mortal wound(s) against %s." % [int(roll.value), modifier, total, damage, str(state.squads[target].get("name", "the enemy unit"))]}

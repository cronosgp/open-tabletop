extends RefCounted
## Chaplain Grimaldus's command-phase Temple Relics and Cenobyte rules.

const ID := "chaplain-grimaldus-2026-10-28-v1"
const RELICS := ["advance-and-charge", "toughness", "melee-ap"]

static func _identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func _chaplains(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0: continue
		if not unit.get("on_battlefield", true) or _identity(unit) != "chaplain-grimaldus": continue
		if str(unit.get("chaplain_grimaldus_role", "")) == "chaplain": result.append(model)
	return result

static func _has_living_cenobyte(state: Dictionary, squad: int) -> bool:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and str(unit.get("chaplain_grimaldus_role", "")) == "cenobyte": return true
	return false

static func start_available(state: Dictionary, owner: int) -> bool:
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != owner: return false
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	for model: int in _chaplains(state, owner):
		var squad := int(state.units[model].get("squad", -1))
		if not state.get("squads", {}).has(squad) or not _has_living_cenobyte(state, squad): continue
		if int(used.get("grimaldus-temple-relic:%d" % model, -1)) != int(state.get("turn", -2)): return true
	return false

static func choices(state: Dictionary, owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") != "start" or owners.is_empty() or int(owners[0]) != owner: return result
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != owner: return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	for model: int in _chaplains(state, owner):
		var squad := int(state.units[model].get("squad", -1))
		if not state.get("squads", {}).has(squad) or not _has_living_cenobyte(state, squad): continue
		if int(used.get("grimaldus-temple-relic:%d" % model, -1)) == int(state.get("turn", -2)): continue
		for relic: String in RELICS:
			result.append({"label": "Grimaldus: select Temple Relic (%s)" % relic.replace("-", " "), "action": "grimaldus-temple-relic", "model": model, "target": squad, "value": relic})
	return result

static func apply(state: Dictionary, owner: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, owner): return {"error": "Temple Relics can be selected only for Grimaldus at the start of your Command phase while a Cenobyte Servitor remains."}
	var model := int(selected.get("model", -1))
	var turn := int(state.get("turn", -1))
	if not state.unit_abilities.has("grimaldus_temple_relics"): state.unit_abilities.grimaldus_temple_relics = {}
	state.unit_abilities.grimaldus_temple_relics[model] = {"owner": owner, "turn": turn, "relic": str(selected.get("value", "")), "implementation": ID}
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	state.unit_abilities.used["grimaldus-temple-relic:%d" % model] = turn
	return {"error": "", "message": "Grimaldus selected Temple Relic: %s." % str(selected.get("value", "")).replace("-", " ")}

static func active_relic(state: Dictionary, squad: int, relic: String) -> bool:
	if not state.get("squads", {}).has(squad) or relic not in RELICS: return false
	var records: Dictionary = state.get("unit_abilities", {}).get("grimaldus_temple_relics", {})
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		if _identity(unit) != "chaplain-grimaldus" or str(unit.get("chaplain_grimaldus_role", "")) != "chaplain": continue
		var record: Dictionary = records.get(model, {})
		if str(record.get("relic", "")) != relic or int(record.get("owner", -1)) != int(unit.get("owner", -2)): continue
		# Turns increment after each player's turn: the next friendly Command phase is two turns later.
		if int(state.get("turn", -1)) < int(record.get("turn", -2)) + 2: return true
	return false

static func destroy_cenobytes(state: Dictionary, model: int) -> Array[int]:
	var destroyed: Array[int] = []
	if not state.get("units", {}).has(model): return destroyed
	var chaplain: Dictionary = state.units[model]
	if int(chaplain.get("wounds", 0)) > 0 or _identity(chaplain) != "chaplain-grimaldus": return destroyed
	if str(chaplain.get("chaplain_grimaldus_role", "")) != "chaplain": return destroyed
	var squad := int(chaplain.get("squad", -1))
	for other: int in state.units:
		var unit: Dictionary = state.units[other]
		if int(unit.get("squad", -1)) != squad or str(unit.get("chaplain_grimaldus_role", "")) != "cenobyte": continue
		if int(unit.get("wounds", 0)) <= 0: continue
		unit.wounds = 0
		destroyed.append(other)
	return destroyed

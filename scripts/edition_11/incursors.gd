extends RefCounted
## Incursor Squad: Divinator-class Auspexes and once-per-battle Haywire Mine.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const ID := "incursor-squad"
const DIVINATOR_WINDOW := "incursor-divinator"
const MINE_WINDOW := "incursor-haywire-mortal"

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func _source(unit: Dictionary) -> bool:
	return str(unit.get("definition_id", "")).get_slice(":", 3) == ID

static func _models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in Geometry.alive(state, squad):
		if _source(state.units[model]) and state.units[model].get("on_battlefield", true): result.append(model)
	return result

static func _targets(state: Dictionary, model: int, max_range: float) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == state.units[model].owner or Geometry.alive(state, squad).is_empty(): continue
		var sight := Terrain.targeting(state, model, squad)
		if sight.visible and sight.distance <= max_range + 0.001: result.append(squad)
	result.sort()
	return result

static func _mine_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not AbilityCatalog.has(state, squad, "haywire-mine"): return result
	for model: int in Geometry.alive(state, squad):
		var unit: Dictionary = state.units[model]
		if not unit.get("on_battlefield", true): continue
		var identity := AbilityCatalog.identity(unit)
		if identity == ID:
			result.append(model)
		elif identity == "wolf-scouts" and bool(unit.get("wolf_scouts_haywire_mine", false)):
			for weapon: Dictionary in unit.get("ranged_weapons", []):
				if str(weapon.get("id", "")) == "plasma-pistol":
					result.append(model)
					break
	return result

static func _mine_targets(state: Dictionary, squad: int, max_range: float) -> Array[int]:
	var result: Array[int] = []
	for target: int in state.squads:
		if int(state.squads[target].get("owner", -1)) == int(state.squads[squad].get("owner", -2)) or Geometry.alive(state, target).is_empty(): continue
		for model: int in Geometry.alive(state, squad):
			if not state.units[model].get("on_battlefield", true): continue
			var sight := Terrain.targeting(state, model, target)
			if sight.visible and sight.distance <= max_range + 0.001:
				result.append(target)
				break
	result.sort()
	return result

static func _eligible_scanners(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	var abilities: Dictionary = state.get("unit_abilities", {})
	var used: Dictionary = abilities.get("used", {})
	for squad: int in state.squads:
		if state.squads[squad].owner != owner or _models(state, squad).is_empty(): continue
		if used.get("divinator:%d:%s" % [squad, phase_key(state)], false): continue
		var source: int = _models(state, squad)[0]
		if _targets(state, source, 18.0).is_empty(): continue
		result.append(squad)
	result.sort()
	return result

static func offer(state: Dictionary, declaration: Dictionary) -> bool:
	if state.phase != "shooting" or declaration.get("melee", true) or declaration.get("player", -1) != state.active: return false
	var squad: int = int(declaration.get("squad", -1))
	if not state.squads.has(squad) or state.squads[squad].owner != state.active: return false
	var astarte := false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): astarte = true
	if not astarte: return false
	var queue := _eligible_scanners(state, state.active)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": DIVINATOR_WINDOW, "owners": [state.active], "remaining": queue, "declaration": declaration.duplicate(true)}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != DIVINATOR_WINDOW or window.get("owners", [-1])[0] != player or window.get("remaining", []).is_empty(): return []
	var squad: int = int(window.remaining[0])
	var models := _models(state, squad)
	if models.is_empty(): return [{"label": "Skip Divinator-class Auspexes", "action": DIVINATOR_WINDOW, "model": -1, "target": -1, "value": "pass"}]
	var source: int = models[0]
	var result: Array = [{"label": "Decline Divinator-class Auspexes for %s" % state.squads[squad].name, "action": DIVINATOR_WINDOW, "model": -1, "target": -1, "value": "pass"}]
	for target: int in _targets(state, source, 18.0):
		result.append({"label": "Divinator-class Auspexes %d: scan %s (ranged hit re-rolls of 1)" % [source, state.squads[target].name], "action": DIVINATOR_WINDOW, "model": source, "target": target, "value": "scan"})
	return result

static func scanned(state: Dictionary, owner: int, target: int) -> bool:
	if state.phase != "shooting": return false
	var record: Dictionary = state.get("unit_abilities", {}).get("scanned_targets", {}).get("%d:%d" % [owner, target], {})
	return record.get("phase_key", "") == phase_key(state)

static func choose(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose a current Divinator target or decline."}
	var window: Dictionary = state.unit_abilities.window
	var squad: int = int(window.remaining[0])
	if selected.value == "scan":
		var source: int = int(selected.model)
		if source not in _models(state, squad) or selected.target not in _targets(state, source, 18.0): return {"error": "Divinator-class Auspexes requires a visible enemy within 18 inches."}
		if not state.unit_abilities.has("scanned_targets"): state.unit_abilities.scanned_targets = {}
		state.unit_abilities.scanned_targets["%d:%d" % [player, selected.target]] = {"phase_key": phase_key(state), "source": source}
		state.unit_abilities.used["divinator:%d:%s" % [squad, phase_key(state)]] = true
	window.remaining.pop_front()
	if not window.remaining.is_empty(): return {"error": ""}
	var declaration: Dictionary = window.declaration
	state.unit_abilities.window = {}
	return {"error": "", "resume_declaration": declaration}

static func haywire_available(state: Dictionary, squad: int) -> bool:
	return state.get("phase", "") == "shooting" and state.get("squads", {}).has(squad) and state.get("active", -1) == state.squads[squad].owner and not _mine_models(state, squad).is_empty() and not state.get("unit_abilities", {}).get("used", {}).get("haywire:%d" % squad, false)

static func haywire_choices(state: Dictionary, player: int) -> Array:
	if state.phase != "shooting" or state.active != player: return []
	var result: Array = []
	for squad: int in state.squads:
		if state.squads[squad].owner != player: continue
		var models := _mine_models(state, squad)
		if models.is_empty() or not haywire_available(state, squad): continue
		var source: int = models[0]
		for target: int in _mine_targets(state, squad, 6.0):
			result.append({"label": "Haywire Mine %d: target %s (once per battle)" % [source, state.squads[target].name], "action": "haywire-mine", "model": source, "target": target, "value": "use"})
	return result

static func haywire(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in haywire_choices(state, player): return {"error": "Haywire Mine requires a visible enemy unit within 6 inches."}
	if not roller.is_valid(): return {"error": "Haywire Mine requires the host's dice provider."}
	var source: int = int(selected.model)
	var squad: int = int(state.units[source].squad)
	var target: int = int(selected.target)
	var activation := RandomStat.roll("D6", roller)
	if not activation.error.is_empty(): return activation
	var record := {"squad": squad, "model": source, "datasheet": AbilityCatalog.identity(state.units[source]), "target": target, "activation": activation, "vehicle": false, "damage": {}, "mortal_wounds": 0, "remaining": 0, "allocations": [], "discarded": 0}
	state.unit_abilities.used["haywire:%d" % squad] = true
	if activation.value >= 2:
		var vehicle := false
		for model: int in Geometry.alive(state, target):
			if "VEHICLE" in state.units[model].get("keywords", []): vehicle = true
		var damage := RandomStat.roll("2D3" if vehicle else "D3", roller)
		if not damage.error.is_empty(): return damage
		record.vehicle = vehicle
		record.damage = damage
		record.mortal_wounds = damage.value
		record.remaining = damage.value
	state.last_incursor_haywire_mine = record
	if record.remaining > 0: state.unit_abilities.window = {"kind": MINE_WINDOW, "owners": [state.squads[target].owner], "target": target}
	return {"error": ""}

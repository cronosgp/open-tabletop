extends RefCounted
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")

static func character(model: Dictionary) -> bool:
	for keyword: Variant in model.get("keywords", []):
		if str(keyword).strip_edges().to_upper() == "CHARACTER": return true
	return false

static func profile(state: Dictionary, model: int, melee: bool = false) -> Dictionary:
	var unit: Dictionary = state.units[model]
	if unit.has("attachment_role") and unit.attachment_role not in ["bodyguard", "leader", "support"]: return {"error": "Unresolved attachment role."}
	var stats: Dictionary = state.squads[unit.squad].stats
	var overrides: Variant = unit.get("defense", {})
	if not overrides is Dictionary: return {"error": "Invalid model defense profile."}
	for key: Variant in overrides:
		if key not in ["toughness", "save_target", "invulnerable_target", "melee_invulnerable_target"]: return {"error": "Unsupported model defense characteristic."}
	var result := {"error": "", "wounds_per_model": unit.max_wounds, "toughness": overrides.get("toughness", stats.toughness), "save_target": overrides.get("save_target", stats.save_target), "invulnerable_target": overrides.get("invulnerable_target", stats.get("invulnerable_target", 0)), "melee_invulnerable_target": overrides.get("melee_invulnerable_target", stats.get("melee_invulnerable_target", 0))}
	if MarineEnhancements.artificer_armour_bearer(state, model): result.save_target = mini(2, int(result.save_target))
	if MarineEnhancements.redoubtable_machine_spirit_active(state, int(unit.squad)):
		result.invulnerable_target = 5 if int(result.invulnerable_target) == 0 else mini(5, int(result.invulnerable_target))
	if UnitAbilities.enabled(state) and UnitAbilities.identity(unit) == "vanguard-veteran-squad-with-jump-packs" and unit.get("combat_shield", false): result.invulnerable_target = 5
	if UnitAbilities.enabled(state) and UnitAbilities.identity(unit) == "impulsor" and unit.get("impulsor_system", "none") == "shield-dome": result.invulnerable_target = 5 if int(result.invulnerable_target) == 0 else mini(5, int(result.invulnerable_target))
	var force_dome: Dictionary = state.get("unit_abilities", {}).get("force_dome", {}).get(int(unit.squad), {})
	if UnitAbilities.enabled(state) and int(force_dome.get("expires_turn", -1)) > int(state.turn):
		result.invulnerable_target = 4 if int(result.invulnerable_target) == 0 else mini(4, int(result.invulnerable_target))
	if UnitAbilities.rampart_active(state, model):
		result.invulnerable_target = mini(2, int(result.invulnerable_target)) if int(result.invulnerable_target) > 0 else 2
	if result.invulnerable_target == null: result.invulnerable_target = 0
	for key in ["wounds_per_model", "toughness", "save_target", "invulnerable_target", "melee_invulnerable_target"]:
		var value: Variant = result[key]
		if not (value is int or value is float) or not is_finite(value) or value != floor(value) or value < (0 if key in ["invulnerable_target", "melee_invulnerable_target"] else 1) or value > 10000: return {"error": "Invalid model defense characteristic: " + key}
	if result.melee_invulnerable_target not in [0, 2, 3, 4, 5, 6]: return {"error": "Invalid conditional model saving throw."}
	if result.save_target < 2 or result.save_target > 7 or result.invulnerable_target not in [0, 2, 3, 4, 5, 6]: return {"error": "Invalid model saving throw."}
	if not unit.wounds is int or unit.wounds < 0 or unit.wounds > result.wounds_per_model: return {"error": "Invalid model remaining wounds."}
	if melee and result.melee_invulnerable_target > 0:
		result.invulnerable_target = mini(result.invulnerable_target, result.melee_invulnerable_target) if result.invulnerable_target > 0 else result.melee_invulnerable_target
	return result

static func groups(state: Dictionary, squad: int, melee: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var ids: Dictionary = {}
	for model: int in Geometry.alive(state, squad):
		var stats := profile(state, model, melee)
		if not stats.error.is_empty(): continue
		var is_character := character(state.units[model])
		var key := "character:%d" % model if is_character else str([stats.wounds_per_model, stats.save_target, stats.invulnerable_target])
		if not ids.has(key):
			ids[key] = result.size()
			result.append({"models": [], "character": is_character, "profile": stats})
		result[ids[key]].models.append(model)
	return result

static func defender(state: Dictionary, squad: int, melee: bool = false) -> Dictionary:
	var alive := Geometry.alive(state, squad)
	alive.sort_custom(func(a: int, b: int): return state.units[a].wounds < state.units[b].wounds if state.units[a].wounds != state.units[b].wounds else a < b)
	var wounds: Array[int] = []
	var prevention: Array = []
	var maximum := 1
	var toughness := 1
	var bodyguard_toughness := 0
	for model: int in alive:
		var stats := profile(state, model, melee)
		if not stats.error.is_empty(): return stats
		wounds.append(state.units[model].wounds)
		prevention.append(UnitPrevention.rules(state, model))
		maximum = maxi(maximum, stats.wounds_per_model)
		toughness = maxi(toughness, stats.toughness)
		var role: String = state.units[model].get("attachment_role", "leader" if character(state.units[model]) else "bodyguard")
		if role == "bodyguard": bodyguard_toughness = maxi(bodyguard_toughness, stats.toughness)
	if state.squads[squad].get("attached", false) and bodyguard_toughness > 0: toughness = bodyguard_toughness
	var allocation := groups(state, squad, melee)
	var first: Dictionary = allocation[0].profile if not allocation.is_empty() else {"save_target": 7, "invulnerable_target": 0}
	return {"error": "", "models": alive, "remaining_wounds": wounds, "prevention": prevention, "wounds_per_model": maximum, "toughness": toughness, "save_target": first.save_target, "invulnerable_target": first.invulnerable_target, "mixed": allocation.size() > 1}

static func living_group(state: Dictionary, group: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for model: int in group.models:
		if state.units[model].wounds > 0: result.append(model)
	return result

static func wounded_first(state: Dictionary, models: Array) -> Array[int]:
	var wounded: Array[int] = []
	var alive: Array[int] = []
	for model: int in models:
		if state.units[model].wounds <= 0: continue
		alive.append(model)
		if state.units[model].wounds < state.units[model].max_wounds: wounded.append(model)
	return wounded if not wounded.is_empty() else alive

static func order_choices(state: Dictionary, current: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var priority := 10
	for index in range(current.groups.size()):
		if index in current.order: continue
		var group: Dictionary = current.groups[index]
		var alive := living_group(state, group)
		if alive.is_empty(): continue
		var rank := 2 if group.character else 0
		var wounded := false
		for model: int in alive:
			if state.units[model].wounds < state.units[model].max_wounds: wounded = true
		if not wounded: rank += 1
		if rank < priority:
			priority = rank
			result.clear()
		if rank == priority: result.append_array(alive)
	return result

static func choose_order(current: Dictionary, model: int) -> void:
	for index in range(current.groups.size()):
		if model in current.groups[index].models:
			current.order.append(index)
			return

static func current_models(state: Dictionary, current: Dictionary, mortal: bool = false) -> Array[int]:
	var precision: int = current.get("precision", -1)
	if precision >= 0 and state.units[precision].wounds > 0: return [precision]
	if mortal:
		var ordinary: Array[int] = []
		var characters: Array[int] = []
		for model: int in Geometry.alive(state, current.target):
			if character(state.units[model]): characters.append(model)
			else: ordinary.append(model)
		return wounded_first(state, ordinary if not ordinary.is_empty() else characters)
	for index: int in current.order:
		var models := living_group(state, current.groups[index])
		if not models.is_empty(): return wounded_first(state, models)
	return []

static func precision_candidates(state: Dictionary, batch: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if not batch.weapon.keywords.get("precision", false): return result
	for model: int in Geometry.alive(state, batch.target):
		if not character(state.units[model]): continue
		for source: Dictionary in batch.context.get("attack_sources", []):
			if state.units.has(source.model) and Terrain.pair(state, source.model, model).visible:
				result.append(model)
				break
	return result

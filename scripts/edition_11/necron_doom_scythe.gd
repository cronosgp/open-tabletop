extends RefCounted
## Necrons App v1.2: Doom Scythe's mandatory target stance for the Heavy death ray.
const ID := "necron-doom-scythe-atavistic-instigation-2026-11-12-v1"
const WINDOW := "doom-scythe-atavistic-instigation"
const ACTION := "doom-scythe-atavistic-instigation"
const STAND_FIRM := "stand-firm"
const DUCK_FOR_COVER := "duck-for-cover"
const DOOM_SCYTHE_ID := "40kdc:11e:necrons:doom-scythe"
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

static func target_choices(state: Dictionary, declaration: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if bool(declaration.get("melee", false)) or not state.get("units", {}).has(int(declaration.get("attacker", -1))): return result
	var attacker: Dictionary = state.units[int(declaration.attacker)]
	if str(attacker.get("definition_id", "")) != DOOM_SCYTHE_ID or int(attacker.get("wounds", 0)) <= 0: return result
	for entry: Variant in declaration.get("entries", []):
		if not entry is Dictionary or int(entry.get("model", -1)) != int(declaration.attacker): continue
		var selected_heavy_ray := false
		for weapon: Variant in attacker.get("ranged_weapons", []):
			if not weapon is Dictionary or str(weapon.get("id", "")) != str(entry.get("weapon", "")): continue
			var profile: Dictionary = weapon.get("profiles", {}).get(str(entry.get("profile", "")), {})
			if str(profile.get("name", "")) == "Heavy death ray": selected_heavy_ray = true
		if not selected_heavy_ray: continue
		var target := int(entry.get("target", -1))
		if target not in result: result.append(target)
	return result

static func stand_firm_active(state: Dictionary, target: int) -> bool:
	var record: Dictionary = state.get("unit_abilities", {}).get("atavistic_instigation", {}).get(target, {})
	return str(record.get("stance", "")) == STAND_FIRM and str(record.get("phase_key", "")) == _phase_key(state)

static func duck_for_cover_hit_penalty(state: Dictionary, attacking_squad: int) -> int:
	if not state.get("squads", {}).has(attacking_squad): return 0
	var record: Dictionary = state.get("unit_abilities", {}).get("atavistic_instigation", {}).get(attacking_squad, {})
	if str(record.get("stance", "")) != DUCK_FOR_COVER: return 0
	var owner := int(record.get("owner", -1))
	var expiry_turn := int(record.get("expires_turn", -1))
	var turn := int(state.get("turn", -1))
	if turn < expiry_turn: return -1
	if turn > expiry_turn or int(state.get("active", -1)) != owner: return 0
	# The effect expires as the target player's next Shooting phase begins.
	return -1 if str(state.get("phase", "")) in ["start_turn", "command", "movement"] else 0

static func apply_response(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW or window.get("owners", []) != [player]: return {"error": "No Doom Scythe stance decision is pending for this player."}
	var stance := str(selected.get("value", ""))
	if stance not in [STAND_FIRM, DUCK_FOR_COVER]: return {"error": "Choose Stand firm or Duck for cover."}
	var target := int(window.get("target", -1))
	if int(selected.get("target", -1)) != target: return {"error": "Choose a stance for the unit currently targeted by the Heavy death ray."}
	if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) != player or Geometry.alive(state, target).is_empty():
		return {"error": "The selected Doom Scythe target is no longer available."}
	var declaration: Dictionary = window.get("declaration", {}).duplicate(true)
	if declaration.is_empty() or target not in target_choices(state, declaration): return {"error": "The saved Heavy death ray target is no longer valid."}
	if not state.unit_abilities.has("atavistic_instigation"): state.unit_abilities.atavistic_instigation = {}
	state.unit_abilities.atavistic_instigation[target] = {
		"stance": stance,
		"owner": player,
		"phase_key": _phase_key(state),
		"expires_turn": int(state.get("turn", 0)) + 1
	}
	state.unit_abilities.window = {}
	var message := "The controller of %s chose %s." % [str(state.squads[target].get("name", "the target")), "Stand firm" if stance == STAND_FIRM else "Duck for cover"]
	return {"error": "", "resume_declaration": declaration, "message": message}

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", -1)), str(state.get("phase", ""))]


extends RefCounted
## Gauntlet Task Force Damocles-class Uplink enhancement.

const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")

static func _use_key(player: int, turn: int) -> String:
	return "%d:%d" % [player, turn]

static func _transport_for_bearer(state: Dictionary, source_squad: int) -> int:
	if not state.get("squads", {}).has(source_squad) or not TransportRules.squad_embarked(state, source_squad): return -1
	var transport_model := int(state.squads[source_squad].get("embarked_in", -1))
	if not TransportRules.is_transport(state, transport_model): return -1
	var transport: Dictionary = state.units[transport_model]
	if int(transport.get("wounds", 0)) <= 0 or not transport.get("on_battlefield", true): return -1
	return transport_model

static func _target_eligible(state: Dictionary, player: int, transport_model: int, target: int) -> bool:
	if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) != player: return false
	var living := Geometry.alive(state, target)
	if living.is_empty(): return false
	var has_combat_doctrines := false
	for model: int in living:
		var unit: Dictionary = state.units[model]
		if not unit.get("on_battlefield", true): return false
		var keywords: Array = unit.get("keywords", [])
		if "ADEPTUS ASTARTES" not in keywords or "INFANTRY" not in keywords: return false
		if "combat-doctrines" in AbilityCatalog.RULES.get(AbilityCatalog.identity(unit), []): has_combat_doctrines = true
	return has_combat_doctrines and Geometry.distance_to_target(state, state.units[transport_model], target) <= 6.001

static func choices(state: Dictionary, player: int, available_doctrines: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "movement" or int(state.get("active", -1)) != player or available_doctrines.is_empty(): return result
	var used: Dictionary = state.get("marine_enhancements", {}).get("damocles_uplink_used", {})
	var use_key := _use_key(player, int(state.get("turn", 0)))
	if used.get(use_key, false): return result
	for source: int in state.get("units", {}):
		var bearer: Dictionary = state.units[source]
		if int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or not MarineEnhancements.damocles_class_uplink_bearer(state, source): continue
		var transport_model := _transport_for_bearer(state, int(bearer.get("squad", -1)))
		if transport_model < 0: continue
		for target: int in state.get("squads", {}):
			if not _target_eligible(state, player, transport_model, target): continue
			for doctrine: String in available_doctrines:
				if doctrine not in Doctrines.ORDER: continue
				var doctrine_name := "%s Doctrine" % doctrine.capitalize()
				result.append({"label": "Damocles-class Uplink: %s for %s" % [doctrine_name, str(state.squads[target].get("name", "Infantry unit"))],
					"action": "damocles-class-uplink", "model": source, "target": target, "value": doctrine})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, available_doctrines: Array[String]) -> Dictionary:
	var source := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var doctrine := str(selected.get("value", ""))
	if str(state.get("phase", "")) != "movement" or int(state.get("active", -1)) != player:
		return {"error": "Damocles-class Uplink is used in your Movement phase."}
	if not state.get("units", {}).has(source): return {"error": "Select the living Damocles-class Uplink bearer."}
	var bearer: Dictionary = state.units[source]
	if int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or not MarineEnhancements.damocles_class_uplink_bearer(state, source):
		return {"error": "Damocles-class Uplink requires its living Captain bearer."}
	var transport_model := _transport_for_bearer(state, int(bearer.get("squad", -1)))
	if transport_model < 0: return {"error": "The bearer’s unit must be embarked within a living Transport."}
	var used: Dictionary = state.get("marine_enhancements", {}).get("damocles_uplink_used", {})
	var use_key := _use_key(player, int(state.get("turn", 0)))
	if used.get(use_key, false): return {"error": "Damocles-class Uplink has already been used this Movement phase."}
	if doctrine not in Doctrines.ORDER or doctrine not in available_doctrines: return {"error": "Choose one available Combat Doctrine."}
	if not _target_eligible(state, player, transport_model, target): return {"error": "Choose a friendly Adeptus Astartes Infantry unit with Combat Doctrines within 6 inches of the Transport."}
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("damocles_doctrine_targets"): state.marine_enhancements.damocles_doctrine_targets = {}
	if not state.marine_enhancements.has("damocles_uplink_used"): state.marine_enhancements.damocles_uplink_used = {}
	state.marine_enhancements.damocles_doctrine_targets[target] = {"owner": player, "source": source, "doctrine": doctrine, "activated_turn": int(state.get("turn", 0)), "expires_turn": int(state.get("turn", 0)) + 2}
	state.marine_enhancements.damocles_uplink_used[use_key] = true
	return {"error": "", "message": "%s is active for %s until the start of your next Command phase." % [Doctrines.NAMES[doctrine], str(state.squads[target].get("name", "Infantry unit"))]}

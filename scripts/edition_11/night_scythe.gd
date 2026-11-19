extends RefCounted
## Source-bounded Night Scythe (000000544): Invasion Beams and Quantum Invader.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")

const IDENTITY := "night-scythe"

static func _has_embarked_models(state: Dictionary, transport_model: int) -> bool:
	for m: int in state.get("units", {}):
		var u: Dictionary = state.units[m]
		if int(u.get("embarked_transport", -1)) == transport_model and int(u.get("wounds", 0)) > 0:
			return true
	return false

static func _wholly_within_six_inches(state: Dictionary, transport_model: int, squad: int) -> bool:
	var transport: Dictionary = state.units[transport_model]
	var t_pos := Vector2(transport.get("position", Vector2.ZERO))
	var t_radius := float(transport.get("radius", 0.0))
	var living := TransportRules.models(state, squad)
	if living.is_empty(): return false
	for m: int in living:
		var u: Dictionary = state.units[m]
		if not bool(u.get("on_battlefield", true)): return false
		var m_pos := Vector2(u.get("position", Vector2.ZERO))
		var m_radius := float(u.get("radius", 0.0))
		if m_pos.distance_to(t_pos) + m_radius - t_radius > 6.001:
			return false
	return true

## Invasion Beams:
## At the end of the Fight phase, if there are no models currently embarked within this TRANSPORT,
## you can select one friendly NECRONS INFANTRY unit wholly within 6" of this TRANSPORT.
## Unless that unit is within Engagement Range of one or more enemy units, it can embark within this TRANSPORT.
static func invasion_beams_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not AbilityCatalog.enabled(state) or str(state.get("phase", "")) != "fight": return result
	var turn := int(state.get("turn", 0))
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var reserves: Dictionary = state.get("unit_abilities", {}).get("reserves", {})
	var transport_models: Array[int] = []
	for m: int in state.get("units", {}):
		var u: Dictionary = state.units[m]
		if int(u.get("owner", -1)) != player or int(u.get("wounds", 0)) <= 0 or not bool(u.get("on_battlefield", true)): continue
		if AbilityCatalog.identity(u) == IDENTITY: transport_models.append(m)
	transport_models.sort()
	var squad_ids: Array[int] = []
	for sq: int in state.get("squads", {}): squad_ids.append(sq)
	squad_ids.sort()
	for model: int in transport_models:
		if bool(used.get("invasion-beams:%d:%d" % [model, turn], false)): continue
		if _has_embarked_models(state, model): continue
		for sq: int in squad_ids:
			if int(state.squads[sq].get("owner", -1)) != player: continue
			if reserves.has(sq) or TransportRules.squad_embarked(state, sq): continue
			if FightQueue.engaged(state, sq): continue
			if not TransportRules.eligibility_error(state, model, sq, false).is_empty(): continue
			if not _wholly_within_six_inches(state, model, sq): continue
			result.append({
				"label": "Invasion Beams %d: embark %s" % [model, str(state.squads[sq].get("name", "Necrons Infantry"))],
				"action": "night-scythe-invasion-beams",
				"model": model,
				"target": sq,
				"value": "embark"
			})
	return result

static func apply_invasion_beams(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in invasion_beams_choices(state, player):
		return {"error": "No matching Invasion Beams embarkation is available."}
	var model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var turn := int(state.get("turn", 0))
	state.unit_abilities.used["invasion-beams:%d:%d" % [model, turn]] = true
	TransportRules._set_embarked(state, target, model)
	return {"error": "", "message": "Invasion Beams: %s embarked within Night Scythe %d." % [str(state.squads[target].get("name", "unit")), model]}

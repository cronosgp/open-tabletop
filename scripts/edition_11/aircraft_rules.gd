extends RefCounted
## Shared 11th-edition Aircraft handling for admitted profiles.
const ID := "core-aircraft-11e-v1"

static func has_keyword(record: Dictionary, keyword: String) -> bool:
	for value: Variant in record.get("keywords", []):
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func squad_has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and has_keyword(unit, keyword): return true
	return false

static func is_aircraft(state: Dictionary, squad: int) -> bool:
	return squad_has_keyword(state, squad, "AIRCRAFT")

static func is_flying(state: Dictionary, squad: int) -> bool:
	return squad_has_keyword(state, squad, "FLY")

static func may_fight_in_melee(state: Dictionary, attacker: int, target: int) -> bool:
	if not state.get("squads", {}).has(attacker) or not state.get("squads", {}).has(target): return false
	var attacker_aircraft := is_aircraft(state, attacker)
	var target_aircraft := is_aircraft(state, target)
	if attacker_aircraft and not is_flying(state, target): return false
	if target_aircraft and not is_flying(state, attacker): return false
	return true

static func may_charge_target(state: Dictionary, charger: int, target: int) -> bool:
	if is_aircraft(state, charger): return false
	return not is_aircraft(state, target) or is_flying(state, charger)

static func engagement_allowed(state: Dictionary, first_squad: int, second_squad: int) -> bool:
	if is_aircraft(state, first_squad) or is_aircraft(state, second_squad):
		return may_fight_in_melee(state, first_squad, second_squad)
	return true

static func movement_type_error(state: Dictionary, squad: int, move_type: String) -> String:
	if not is_aircraft(state, squad): return ""
	if move_type == "ingress": return ""
	return "AIRCRAFT units can only make an ingress move."

static func force_reserves(state: Dictionary, player: int) -> String:
	var abilities_value: Variant = state.get("unit_abilities", {})
	if not abilities_value is Dictionary or not abilities_value.get("reserves", {}) is Dictionary:
		return "Aircraft deployment requires the active Strategic Reserves state."
	var abilities: Dictionary = abilities_value
	var reserves: Dictionary = abilities.reserves
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player or not is_aircraft(state, squad) or reserves.has(squad): continue
		var cost := int(state.squads[squad].get("training_cost", 0))
		if cost <= 0: return "AIRCRAFT requires a valid local reserve cost."
		var spent := 0
		for reserved: int in reserves:
			if int(state.squads.get(reserved, {}).get("owner", -1)) == player: spent += int(reserves[reserved].get("cost", 0))
		if spent + cost > int(state.get("points_limit", 500)) / 2:
			return "Mandatory AIRCRAFT placement would exceed the half-army Strategic Reserves limit."
		reserves[squad] = {"cost": cost, "source": "aircraft", "deep_strike": false, "has_ingressed": false}
		for model: int in state.get("units", {}):
			if int(state.units[model].get("squad", -1)) == squad: state.units[model].on_battlefield = false
		var deployment_value: Variant = state.get("deployment", {})
		if deployment_value is Dictionary:
			var order_value: Variant = deployment_value.get("order", [])
			if order_value is Array: order_value.erase(squad)
	return ""

static func return_at_end_of_opponent_turn(state: Dictionary) -> Array[int]:
	var returned: Array[int] = []
	if str(state.get("phase", "")) != "end_turn": return returned
	var owner := 3 - int(state.get("active", -1))
	var abilities_value: Variant = state.get("unit_abilities", {})
	if not abilities_value is Dictionary or not abilities_value.get("reserves", {}) is Dictionary: return returned
	var reserves: Dictionary = abilities_value.reserves
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner or not is_aircraft(state, squad): continue
		var living_on_board := false
		for model: int in state.get("units", {}):
			var unit: Dictionary = state.units[model]
			if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)): living_on_board = true
		if not living_on_board: continue
		var record: Dictionary = reserves.get(squad, {}).duplicate(true)
		if record.is_empty():
			var cost := int(state.squads[squad].get("training_cost", 0))
			if cost <= 0: continue
			record = {"cost": cost, "source": "aircraft", "deep_strike": false}
		record.source = "aircraft"
		record.has_ingressed = bool(state.get("unit_abilities", {}).get("ingress_history", {}).get(squad, false)) or bool(record.get("has_ingressed", false))
		reserves[squad] = record
		for model: int in state.get("units", {}):
			if int(state.units[model].get("squad", -1)) == squad:
				state.units[model].on_battlefield = false
				state.units[model].set_up_this_turn = false
		state.squads[squad].set_up_this_turn = false
		returned.append(squad)
	returned.sort()
	return returned

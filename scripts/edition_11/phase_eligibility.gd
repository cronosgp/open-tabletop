extends RefCounted
## Pure rules-layer eligibility check for auto-skipping strictly empty phases.
## Never skips when any legal unit action, reaction, or Fight-start trigger exists.

const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

static func can_auto_skip(state: Dictionary, hooks: Dictionary = {}) -> Dictionary:
	if not bool(state.get("auto_advance_empty_phases", false)):
		return {"skip": false}
	if int(state.get("test_winner", 0)) != 0:
		return {"skip": false}
	var phase := str(state.get("phase", ""))
	if phase not in ["charge", "fight"]:
		return {"skip": false}
	var active_player := int(state.get("active", 0))
	if active_player not in [1, 2]:
		return {"skip": false}
	if not PhaseCloseGate.close_request_error(state, active_player, int(state.get("revision", -1))).is_empty():
		return {"skip": false}
	if phase == "charge":
		return _charge_skip(state, active_player, hooks)
	return _fight_skip(state, active_player)

static func _charge_skip(state: Dictionary, active_player: int, hooks: Dictionary) -> Dictionary:
	var can_declare_charge: Callable = hooks.get("can_declare_charge", Callable())
	if not can_declare_charge.is_valid():
		return {"skip": false}
	if not UnitActions.choices(state, active_player).is_empty():
		return {"skip": false}
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if int(unit.get("owner", 0)) != active_player or int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)):
			continue
		if can_declare_charge.call(state, active_player, id):
			return {"skip": false}
	return {"skip": true, "reason": "Charge skipped (no eligible units)."}

static func _fight_skip(state: Dictionary, active_player: int) -> Dictionary:
	if str(state.get("fight_step", "")) != "complete":
		return {"skip": false}
	if not state.get("fearsome_assault", {}).is_empty():
		return {"skip": false}
	if not state.get("feared-interrogator", {}).is_empty():
		return {"skip": false}
	if not state.get("death-mask-of-sanguinius", {}).is_empty():
		return {"skip": false}
	if not UnitActions.choices(state, active_player).is_empty():
		return {"skip": false}
	return {"skip": true, "reason": "Fight skipped (no eligible fighters)."}

extends SceneTree
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Core = preload("res://scripts/edition_11/core_reactions.gd")
const Smoke = preload("res://scripts/edition_11/smokescreen.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var state := {
		"phase": "shooting", "active": 2, "turn": 1, "round": 1, "cp": {1: 1, 2: 1},
		"unit_abilities": {"implementation": A.ID, "window": {"kind": "start", "owners": [1]}, "used": {}, "discounts": {}, "discount_armed": {}},
		"stratagems": {"uses": [], "pending": {}},
		"core_reactions": {"implementation": Core.ID, "smoke": [], "overwatch": {}, "heroic": {}, "chargers": [], "charge_closed": false, "epic": {}},
		"squads": {}, "units": {}
	}
	for record: Dictionary in [
		{"id": 1, "name": "Rhino Alpha", "identity": "rhino", "model": 101},
		{"id": 2, "name": "Intercessors", "identity": "intercessor-squad", "model": 201},
		{"id": 3, "name": "Rhino Beta", "identity": "rhino", "model": 301},
		{"id": 4, "name": "Infiltrators", "identity": "infiltrator-squad", "model": 401}]:
		state.squads[record.id] = {"owner": 1, "name": record.name, "battle_shocked": false}
		state.units[record.model] = {"owner": 1, "squad": record.id, "definition_id": "40kdc:11e:adeptus-astartes:%s" % record.identity, "position": Vector2.ZERO, "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "VEHICLE", "SMOKE"], "wounds": 5, "on_battlefield": true}
	return state

func use_smoke(state: Dictionary, squad: int) -> String:
	var choice := {"value": Core.SMOKE, "model": -1, "target": squad}
	var result := Core.apply(state, 1, choice)
	return str(result.get("error", ""))

func run() -> void:
	var state := make_state()
	check(Core.enabled(state), "Core reaction fixture did not activate")
	check(Core.cost_of(state, 1, 1, Core.SMOKE) == 0 and Core.error(state, 1, 1, Core.SMOKE).is_empty(), "Veiling Smoke reduces this Rhino's Smokescreen to 0 CP")
	check(use_smoke(state, 1).is_empty() and state.cp[1] == 1, "Rhino uses Smokescreen without spending CP")
	check(not Core.error(state, 1, 1, Core.SMOKE).is_empty(), "Veiling Smoke remains once per phase for that Rhino")
	check(Core.cost_of(state, 1, 2, Core.SMOKE) == 1 and Core.error(state, 1, 2, Core.SMOKE).is_empty(), "Rhino's use does not prevent Smokescreen on another eligible unit")
	check(use_smoke(state, 2).is_empty() and state.cp[1] == 0, "Another unit pays the normal Smokescreen cost")
	check(Core.cost_of(state, 1, 3, Core.SMOKE) == 0 and Core.error(state, 1, 3, Core.SMOKE).is_empty(), "A second Rhino can use its own Veiling Smoke despite earlier phase uses")
	check(use_smoke(state, 3).is_empty() and state.cp[1] == 0, "Second Rhino use is free")
	state.cp[1] = 1
	check(Core.error(state, 1, 4, Core.SMOKE).contains("already been used"), "An ordinary Smokescreen use still observes the normal phase limit")
	check(state.core_reactions.smoke.size() == 3 and Smoke.cover(state, 201, 1) and Smoke.cover(state, 101, 2) and Smoke.cover(state, 201, 3), "Multiple Smokescreen uses persist together for their full phase effects")
	print("Rhino Veiling Smoke: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")

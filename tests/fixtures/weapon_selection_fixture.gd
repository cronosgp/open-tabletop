extends RefCounted
## Imported weapons on a synthetic test unit, not a playable army loadout.
const C = preload("res://scripts/edition_11/combat_scenario.gd")
static var imported: Dictionary = {}
static func weapons() -> Dictionary:
	if not imported.is_empty(): return imported.duplicate(true)
	var pack := C.Pack.load_pack(C.DIRECTORY.path_join("adeptus-astartes"))
	for unit: Dictionary in pack.units:
		if unit.source_id == "terminator-squad":
			imported.chain = {"id": "chain", "profiles": {"standard": C._weapon(unit, "chainfist-terminator-squad", "Chainfist - Standard"), "hunter": C._weapon(unit, "chainfist-terminator-squad", "Chainfist - Hunter")}}
		if unit.source_id == "techmarine":
			imported.servo = {"id": "servo", "profiles": {"standard": C._weapon(unit, "servo-arm", "Servo-arm")}}
	return imported.duplicate(true)
static func configure(state: Dictionary) -> void:
	for id: int in state.units:
		if id not in [100, 200, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(0, -8)
	state.units[200].position = Vector2(1.5, -8)
	state.units[400].position = Vector2(-1.5, -8)
	state.units[200].keywords = ["Infantry"]
	state.units[400].keywords = ["Vehicle"]
	for squad in [2, 4]: state.squads[squad].stats.wounds = 20
	for id in [200, 400]:
		state.units[id].max_wounds = 20
		state.units[id].wounds = 20
	state.phase = "fight"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.squads[1].charged = true
	var equipment := weapons()
	var second: Dictionary = equipment.servo.duplicate(true)
	second.id = "servo-two"
	state.units[100].melee_weapons.append_array([equipment.chain, equipment.servo, second])
static func state(manual: bool = false) -> Dictionary:
	var result := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, manual, true)
	configure(result)
	return result
static func row(weapon: String, profile: String, amount: int, target: int = 2) -> Dictionary:
	return {"model": 100, "target": target, "weapon": weapon, "profile": profile, "amount": amount}
static func plan() -> Array:
	return [row("chain", "hunter", 3, 4), row("servo", "standard", 1, 2), row("servo-two", "standard", 1, 2)]
static func instance(s: Dictionary, id: String) -> Dictionary:
	for weapon: Dictionary in s.units[100].melee_weapons:
		if weapon.id == id: return weapon
	return {}

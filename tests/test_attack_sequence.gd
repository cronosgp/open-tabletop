extends SceneTree

const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0

class FixedDice:
	extends RefCounted
	var values: Array
	var offset := 0
	func _init(rolls: Array) -> void: values = rolls
	func roll() -> int:
		if offset >= values.size(): return 0
		var value: int = values[offset]
		offset += 1
		return value

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func weapon() -> Dictionary:
	return {"attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}

func defender() -> Dictionary:
	return {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 2, "remaining_wounds": [2, 2]}

func resolve(w: Dictionary, d: Dictionary, context: Dictionary, rolls: Array) -> Dictionary:
	var dice := FixedDice.new(rolls)
	return Attacks.resolve(w, d, context, dice.roll)

func _initialize() -> void:
	check(Attacks.wound_target(8, 4) == 2, "Double strength threshold")
	check(Attacks.wound_target(5, 4) == 3, "Greater strength threshold")
	check(Attacks.wound_target(4, 4) == 4, "Equal strength threshold")
	check(Attacks.wound_target(3, 4) == 5, "Lower strength threshold")
	check(Attacks.wound_target(2, 4) == 6, "Half strength threshold")
	check(not Attacks.successful_roll(1, 2, 1), "Natural one must fail")
	check(Attacks.successful_roll(6, 6, -1), "Natural six must succeed")
	var anti_vehicle_weapon := weapon()
	anti_vehicle_weapon.attacks = 1
	anti_vehicle_weapon.strength = 2
	anti_vehicle_weapon.keywords = {"anti-vehicle": 2}
	var vehicle_defender := defender()
	vehicle_defender.toughness = 10
	var anti_result := resolve(anti_vehicle_weapon, vehicle_defender, {"target_keywords": ["VEHICLE"], "defer_saves": true}, [6, 2])
	check(anti_result.error.is_empty() and anti_result.wounds == 1 and anti_result.critical_wounds == 1, "Anti-Vehicle 2+ did not make an unmodified 2 a Critical Wound against a Vehicle")
	anti_result = resolve(anti_vehicle_weapon, vehicle_defender, {"target_keywords": ["INFANTRY"], "defer_saves": true}, [6, 2])
	check(anti_result.error.is_empty() and anti_result.wounds == 0 and anti_result.critical_wounds == 0, "Anti-Vehicle applied without a Vehicle target")
	var d := defender()
	var result := resolve(weapon(), d, {}, [3, 6, 4, 6, 3, 4])
	check(result.error == "" and result.hits == 2 and result.wounds == 2, "Hit and wound pool")
	check(result.unsaved == 1 and result.remaining_wounds == [1, 2], "AP and damage allocation")
	check(d.remaining_wounds == [2, 2], "Resolver mutated input")
	var w := weapon()
	w.damage = 3
	result = resolve(w, defender(), {}, [6, 6, 6, 6, 1, 1])
	check(result.models_destroyed == 2 and result.excess_damage_discarded == 2, "Damage must not spill between models")
	d = defender()
	d.remaining_wounds = [2, 1]
	w.attacks = 1
	result = resolve(w, d, {}, [6, 6, 1])
	check(result.remaining_wounds == [2], "Wounded model must take damage first")
	w = weapon()
	w.ap = -4
	d = defender()
	d.invulnerable_target = 4
	result = resolve(w, d, {}, [6, 6, 6, 6, 4, 1])
	check(result.unsaved == 1 and result.save_rolls == [1, 4], "Invulnerable save and ascending save order")
	w = weapon()
	w.skill = 2
	w.keywords = {"lethal-hits": true, "sustained-hits": 1}
	w.attacks = 1
	result = resolve(w, defender(), {}, [6, 1, 1])
	check(result.hits == 2 and result.wounds == 1 and result.wound_rolls == [1], "Sustained hit must not inherit Lethal Hits")
	w.keywords = {"lethal-hits": true}
	result = resolve(w, defender(), {"use_lethal_hits": false}, [6, 1])
	check(result.wounds == 0, "Lethal Hits choice ignored")
	w = weapon()
	w.attacks = 1
	w.range_inches = 24
	w.keywords = {"rapid-fire": 1}
	result = resolve(w, defender(), {"weapon_count": 2, "distance_inches": 12}, [1, 1, 1, 1])
	check(result.attacks == 4, "Rapid Fire must apply once per weapon at half range")
	result = resolve(w, defender(), {"distance_inches": 12.01}, [1])
	check(result.attacks == 1, "Rapid Fire outside half range")
	w = weapon()
	w.attacks = 1
	w.keywords = {"torrent": true, "twin-linked": true}
	result = resolve(w, defender(), {}, [1, 6, 1])
	check(result.hit_rolls.is_empty() and result.wound_rolls == [1, 6] and result.unsaved == 1, "Torrent and Twin-linked")
	w.keywords = {"heavy": true}
	result = resolve(w, defender(), {"heavy_eligible": true}, [2, 6, 1])
	check(result.hits == 1, "11e Heavy eligible modifier")
	check(not resolve(w, defender(), {}, []).error.is_empty(), "Heavy without explicit eligibility accepted")
	w.keywords = {"unknown-effect": true}
	check(not resolve(w, defender(), {}, []).error.is_empty(), "Unknown keyword ignored")
	check(not resolve(weapon(), defender(), {"unresolved_effects": ["Oath of Moment"]}, []).error.is_empty(), "Unresolved unit effects ignored")
	check(not resolve(weapon(), defender(), {}, [7]).error.is_empty(), "Invalid dice accepted")
	w = weapon()
	w.damage = "D6"
	check(not resolve(w, defender(), {}, []).error.is_empty(), "Unsupported random damage accepted")
	print("11e attack sequence checks complete: %d failures" % failures)
	quit(1 if failures else 0)

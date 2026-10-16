extends SceneTree
const Windows = preload("res://scripts/edition_11/attack_roll_window.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0

class Dice:
	extends RefCounted
	var values: Array
	var offset := 0
	func _init(input: Array) -> void: values = input
	func roll() -> int:
		if offset >= values.size(): return 0
		var value: int = values[offset]
		offset += 1
		return value

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1

func weapon() -> Dictionary:
	return {"attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}

func defender() -> Dictionary:
	return {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 2, "remaining_wounds": [2, 2]}

func parity(w: Dictionary, context: Dictionary, seed_value: int) -> void:
	var first := RandomNumberGenerator.new()
	var second := RandomNumberGenerator.new()
	first.seed = seed_value
	second.seed = seed_value
	var original := Attacks.roll_pool(w, defender(), context.duplicate(true), func() -> int: return first.randi_range(1, 6))
	var staged := Windows.begin(w, defender(), context, func() -> int: return second.randi_range(1, 6))
	check(staged.error.is_empty(), "Start valid staged pool")
	if not staged.error.is_empty(): return
	staged = Windows.advance(staged, staged.revision, func() -> int: return second.randi_range(1, 6))
	check(staged.error.is_empty(), "Resume valid hit pool")
	if not staged.error.is_empty(): return
	staged = Windows.advance(staged, staged.revision, func() -> int: return second.randi_range(1, 6))
	check(staged.error.is_empty(), "Resume valid wound pool")
	if not staged.error.is_empty(): return
	check(staged.result == original, "Staged/batch result differs at seed %d, traits %s" % [seed_value, w.keywords])
	check(first.state == second.state, "Staging changed RNG consumption")
	second.seed = seed_value
	staged = Windows.begin(w, defender(), context, func() -> int: return second.randi_range(1, 6), true)
	while staged.error.is_empty() and staged.phase != "complete":
		staged = Windows.advance(staged, staged.revision, func() -> int: return second.randi_range(1, 6))
	check(staged.error.is_empty(), "Deferred generation failed")
	if not staged.error.is_empty(): return
	check(staged.result == original and first.state == second.state, "Generation checkpoint changed results or RNG")

func _initialize() -> void:
	var dice := Dice.new([6, 6, 1, 4, 4, 1, 1])
	var checkpoint := Windows.begin(weapon(), defender(), {}, dice.roll)
	check(checkpoint.phase == "hit" and dice.offset == 2, "Hit checkpoint consumed later dice")
	check(checkpoint.wound_rolls.is_empty(), "Hit window reveals wounds")
	var before := checkpoint.duplicate(true)
	var revised := Windows.reroll(checkpoint, 0, 0, dice.roll)
	check(checkpoint == before and revised.hit_rolls == [1, 6], "Worse replacement must apply without mutating input")
	check(revised.dice_history == [6, 6, 1] and revised.changes[0].previous == 6, "Original/replacement audit lost")
	var consumed := dice.offset
	check(not Windows.reroll(revised, 0, revised.revision, dice.roll).error.is_empty(), "Re-rolled die accepted again")
	check(not Windows.reroll(revised, 1, 0, dice.roll).error.is_empty(), "Stale checkpoint accepted")
	check(not Windows.reroll(revised, 50, revised.revision, dice.roll).error.is_empty(), "Invalid die index accepted")
	check(dice.offset == consumed, "Rejected choice consumed dice")
	# Native binary round trip preserves exact checkpoint types and resumes once.
	revised = bytes_to_var(var_to_bytes(revised))
	var wounded := Windows.advance(revised, revised.revision, dice.roll)
	check(wounded.phase == "wound" and wounded.effective_wounds == [4] and dice.offset == 4, "Wound checkpoint consumed saves")
	var done := Windows.advance(wounded, wounded.revision, dice.roll)
	check(done.phase == "complete" and done.result.save_rolls == [4] and dice.offset == 5, "Resume did not preserve remaining dice")
	check(not Windows.advance(done, done.revision, dice.roll).error.is_empty(), "Completed pool advanced twice")
	check(not Windows.reroll(done, 0, done.revision, dice.roll).error.is_empty(), "Late hit re-roll accepted after saves")
	var invalid := Dice.new([7])
	check(not Windows.reroll(checkpoint, 0, checkpoint.revision, invalid.roll).error.is_empty() and checkpoint == before, "Invalid replacement changed checkpoint")
	var twin := weapon()
	twin.keywords = {"torrent": true, "twin-linked": true, "devastating-wounds": true}
	dice = Dice.new([1, 6, 6, 1])
	checkpoint = Windows.begin(twin, defender(), {}, dice.roll)
	check(Windows.eligible(checkpoint).is_empty() and dice.offset == 0, "Torrent generated hit dice")
	checkpoint = Windows.advance(checkpoint, checkpoint.revision, dice.roll)
	check(checkpoint.effective_wounds == [6, 6] and Windows.eligible(checkpoint) == [1], "Twin-linked re-roll must not be eligible a second time")
	checkpoint = Windows.reroll(checkpoint, 1, checkpoint.revision, dice.roll)
	done = Windows.advance(checkpoint, checkpoint.revision, dice.roll)
	check(done.result.wounds == 1 and done.result.devastating_wounds == 1 and done.result.save_rolls.is_empty(), "Worse wound replacement/Devastating Wounds incorrect")
	check(done.result.wound_rolls == [1, 6, 6, 1] and done.result.dice_history == [1, 6, 6, 1], "Wound audit must retain every original and replacement")
	var w := weapon()
	w.attacks = 1
	w.keywords = {"lethal-hits": true, "sustained-hits": 2}
	dice = Dice.new([1, 6, 4, 4, 1, 1, 1])
	checkpoint = Windows.begin(w, defender(), {}, dice.roll)
	checkpoint = Windows.reroll(checkpoint, 0, checkpoint.revision, dice.roll)
	checkpoint = Windows.advance(checkpoint, checkpoint.revision, dice.roll)
	done = Windows.advance(checkpoint, checkpoint.revision, dice.roll)
	check(done.result.hits == 3 and done.result.wounds == 3, "Replacement critical must recompute Lethal/Sustained effects")
	for traits: Dictionary in [{}, {"torrent": true}, {"twin-linked": true}, {"devastating-wounds": true}, {"lethal-hits": true, "sustained-hits": 2}, {"torrent": true, "twin-linked": true, "devastating-wounds": true}, {"heavy": true}, {"rapid-fire": 1}, {"blast": true}]:
		for seed_value in range(1, 41):
			w = weapon()
			w.attacks = "D3"
			w.range_inches = 24
			w.keywords = traits
			parity(w, {"weapon_count": 2, "heavy_eligible": true, "distance_inches": 10.0, "target_model_count": 10, "target_keywords": [], "benefit_of_cover": seed_value % 2 == 0, "defer_saves": seed_value % 3 == 0}, seed_value)
	print("Attack roll checkpoints: %d failures" % failures)
	quit(1 if failures else 0)

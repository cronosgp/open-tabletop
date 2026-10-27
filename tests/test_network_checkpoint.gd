extends SceneTree
const Barrier = preload("res://tests/network_checkpoint_barrier.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var state := {"revision": 7, "units": {2: {"position": Vector2(1.25, -2.5), "wounds": 3}}, "ordered": [1, "one", 1.0]}
	var reordered := {"ordered": [1, "one", 1.0], "units": {2: {"wounds": 3, "position": Vector2(1.25, -2.5)}}, "revision": 7}
	check(state == reordered, "The comparison fixture has equal dictionary values")
	check(var_to_bytes(state) != var_to_bytes(reordered), "Insertion order can change serialized bytes without changing values")
	check(Barrier.digest(state) == Barrier.digest(reordered), "The diagnostic digest ignores dictionary insertion order")
	var changed := state.duplicate(true)
	changed.units[2].position.x += 0.125
	check(Barrier.digest(state) != Barrier.digest(changed), "The diagnostic digest preserves position components")
	changed = state.duplicate(true)
	changed.ordered.reverse()
	check(Barrier.digest(state) != Barrier.digest(changed), "The diagnostic digest preserves array order and scalar types")
	check(Barrier.digest({1: "unit"}) != Barrier.digest({"1": "unit"}), "Integer and string keys stay distinct")
	check(Barrier.digest({"value": 1}) != Barrier.digest({"value": 1.0}), "Integer and float values stay distinct")
	print("Network checkpoint comparisons: %d failures" % failures)
	quit(0 if failures == 0 else 1)

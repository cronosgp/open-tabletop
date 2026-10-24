extends SceneTree
const Tray = preload("res://scripts/ui/combat_tray.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func run() -> void:
	var tray := Tray.new()
	root.add_child(tray)
	tray.size.x = 540
	tray.sync({}, {}, true, true)
	var attack := {"message": "Fixture attack", "pools": [{"weapon_name": "Fixture weapon", "target_squad": 2, "final_hit_rolls": [6, 1, 4], "effective_skill": 3, "final_wound_rolls": [6, 4], "wound_target": 4, "wounds": 2, "save_rolls": [1, 3], "damage_rolls": [{"expression": "2", "value": 2, "rolls": []}], "damage_applied": 4, "models_destroyed": 2}]}
	var state := {"last_attack": attack, "squads": {2: {"name": "Defender"}}, "events": [{"message": "Fixture attack"}], "cp": {1: 2, 2: 2}}
	var before := var_to_bytes(state)
	tray.sync(state, {}, true, true)
	check(tray.visible and tray.sequence.is_running() and tray.skip.visible, "A new recorded attack starts its presentation")
	tray.finish()
	check(tray.summary.text == "4 damage applied · 2 models destroyed" and not tray.skip.visible, "Skipping reveals the stable confirmed result")
	check(not tray.expanded and tray.expand_button.text == "Show dice", "Completed combat folds to a stable summary and releases battlefield space")
	check(tray.stages.item_count == 4 and tray.groups[3].rolls.is_empty(), "Hits, wounds, saves and fixed damage remain inspectable without invented dice")
	tray.play()
	tray.finish()
	check(var_to_bytes(state) == before, "Replay and skip preserve all state, CP, events and recorded dice")
	state.events.append({"message": "Unrelated movement"})
	tray.sync(state, {}, true, true)
	check(not tray.sequence.is_running(), "Unrelated events do not replay an old impact")
	for revision in range(40):
		state.events.append({"message": "Phase changed", "revision": revision})
		if state.events.size() > 30: state.events.pop_front()
		tray.sync(state, {}, true, true)
		check(not tray.sequence.is_running(), "Phase changes and history eviction do not replay legacy attacks without completion metadata")
	var restored := Tray.new()
	root.add_child(restored)
	restored.sync(state, {}, true, true)
	check(restored.sequence == null and restored.summary.text == tray.summary.text, "Restored results appear settled without replaying an old impact")
	for face: Control in restored.dice.get_children(): check(face.scale == Vector2.ONE, "Restored dice have no automatic pop animation")
	var saved_attack: Dictionary = attack.duplicate(true)
	saved_attack.completion_revision = 10
	saved_attack.pools[0].saves_passed = 2
	saved_attack.pools[0].unsaved = 0
	saved_attack.pools[0].damage_applied = 0
	saved_attack.pools[0].models_destroyed = 0
	state.last_attack = saved_attack
	tray.sync(state, {}, true, true)
	tray.finish()
	check("Saved · no damage applied" in tray.summary.text and "Saves: 2 passed" in tray.summary.text, "All successful saves explicitly announce no damage")
	var damaged_attack: Dictionary = attack.duplicate(true)
	damaged_attack.completion_revision = 11
	damaged_attack.pools[0].saves_passed = 1
	damaged_attack.pools[0].unsaved = 1
	state.last_attack = damaged_attack
	tray.sync(state, {}, true, true)
	tray.finish()
	check("Saves: 1 passed · 1 failed" in tray.summary.text and "4 damage applied" in tray.summary.text, "Confirmed damage retains its save outcome")
	var window := {"kind": "after_hit_roll", "player": 1, "squad": 1, "rolls": [6, 1], "eligible": [0, 1]}
	before = var_to_bytes(state)
	tray.sync(state, window, true, true)
	check(tray.groups.size() == 1 and tray.groups[0].rolls == [6, 1], "A live decision shows only its current recorded roll")
	tray.speed.select(2)
	tray.play()
	check(not tray.skip.visible and "optional" in tray.summary.text and var_to_bytes(state) == before, "Reduced motion preserves the optional decision and match state")
	tray.sync(state, window, true, false)
	check(not tray.visible, "Read-only overlays can hide the tray without changing its decision")
	tray.free()
	restored.free()
	await process_frame
	print("Combat tray checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

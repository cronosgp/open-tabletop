extends SceneTree
const Journal = preload("res://scripts/match_journal.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var state := Prepared.initial_state()
	var journal = Journal.new()
	journal.reset(state)
	assert(journal.capture(state).is_empty())
	assert(journal.entries.size() == 1)
	assert(journal.capture(state).is_empty() and journal.entries.size() == 1)
	var first: Dictionary = journal.checkpoint()
	var initial: Dictionary = state.duplicate(true)
	for step in range(45):
		state.revision += 1
		state.units[100].position.x += 0.01
		state.events.append({"revision": state.revision, "message": "Test event %d" % step})
		if state.events.size() > 30: state.events.pop_front()
		journal.roll(state, step % 6 + 1)
		assert(journal.capture(state).is_empty())
	assert(journal.entries.size() == 46 and journal.page(0).items.size() == 20)
	assert(journal.page(0).items[1].messages == ["Test event 0"])
	assert(not journal.page(0).items[0].has("patch"))
	# Synthetic presentation fixture: public summaries must not expose raw patches
	# or modify the hashed journal entries that saves depend on.
	state.revision += 1
	state.last_attack = {"pools": [{"weapon_name": "Summary fixture", "target_squad": 2, "hits": 2, "wounds": 2, "damage_applied": 4, "models_destroyed": 2}]}
	assert(journal.capture(state).is_empty())
	var entries_before := Journal.digest(journal.entries)
	var public_entry: Dictionary = journal.page().items[-1]
	assert(public_entry.attack_summary.pools[0].damage_applied == 4 and public_entry.attack_summary.pools[0].models_destroyed == 2)
	assert(not public_entry.attack_summary.pools[0].target_name.is_empty() and not public_entry.has("patch"))
	assert(Journal.digest(journal.entries) == entries_before)
	var checkpoint: Dictionary = journal.checkpoint()
	var restored = Journal.new()
	assert(restored.restore(checkpoint, state).is_empty())
	assert(restored.entries == journal.entries and restored.observed == state)
	var wrong := state.duplicate(true)
	wrong.revision += 1
	assert(not Journal.new().restore(checkpoint, wrong).is_empty())
	# A save that committed only the initial prefix must ignore later actions,
	# preserve their file and continue in another file without duplicating dice.
	var branch = Journal.new()
	assert(branch.restore(first, initial).is_empty())
	assert(branch.id != journal.id and branch.entries.size() == 1)
	assert(branch.capture(initial).is_empty() and branch.entries.size() == 1)
	initial.revision += 1
	assert(branch.capture(initial).is_empty())
	assert(Journal.new().restore(checkpoint, state).is_empty())
	# A torn tail after the committed checkpoint is harmless to that save.
	var file := FileAccess.open(journal.path(), FileAccess.READ_WRITE)
	file.seek_end()
	file.store_buffer(PackedByteArray([255, 1, 2]))
	file.close()
	assert(Journal.new().restore(checkpoint, state).is_empty())
	# Corruption inside a committed record is rejected.
	file = FileAccess.open(journal.path(), FileAccess.READ_WRITE)
	file.seek(70)
	file.store_8(255)
	file.close()
	assert(not Journal.new().restore(checkpoint, state).is_empty())
	assert(not Journal.new().restore({"version": 1, "id": "../bad"}, state).is_empty())
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_allocation_practice()
	game.rng.seed = 12345
	game._begin_attack_plan()
	game._assign_attack()
	game._confirm_attack_plan()
	assert(game.journal.entries.size() == 2 and not game.journal.entries[-1].dice.is_empty())
	var dice: Array = game.journal.entries[-1].dice.duplicate(true)
	var rng_state: int = game.rng.state
	var count: int = game.journal.entries.size()
	game._history_page(0)
	assert(game.rng.state == rng_state and game.journal.entries.size() == count)
	game._load_match()
	assert(game.rng.state == rng_state and game.journal.entries.size() == count and game.journal.entries[-1].dice == dice)
	game._broadcast()
	assert(game.journal.entries.size() == count)
	# Stale commands cannot append records or roll dice.
	game._apply_end(1, -99)
	assert(game.journal.entries.size() == count and game.rng.state == rng_state)
	var before_corruption: Dictionary = game.state.duplicate(true)
	file = FileAccess.open(game.journal.path(), FileAccess.READ_WRITE)
	file.seek(70)
	file.store_8(255)
	file.close()
	game._load_match()
	assert(game.state == before_corruption and game.rng.state == rng_state)
	assert("corrupted" in game.status.text)
	print("MATCH JOURNAL: PASS")
	game.free()
	quit()

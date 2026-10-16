extends SceneTree

const Save = preload("res://scripts/match_save.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_prepared_match()
	game._request_deployment_preset()
	var original: Dictionary = game.state.duplicate(true)
	game.rng.seed = 123456789
	var random_state: int = game.rng.state
	game.attack_draft = {}
	var error: String = game._save_snapshot()
	if not error.is_empty():
		print("SAVE FAILURE: ", error)
		find_unsafe({"state": game.state, "config": game._save_config(), "draft": game.attack_draft})
		quit(1)
		return
	var read := Save.read()
	assert(read.state == original)
	assert(read.rng_state == random_state)
	assert(read.attack_draft == game.attack_draft)
	# Replacement must work when a previous autosave already exists.
	assert(game._save_snapshot().is_empty())
	game.state = game.Rules.initial_state()
	game.attack_draft = {}
	game.rng.randomize()
	game._load_match()
	assert(game.state == original)
	assert(game.rng.state == random_state)
	assert(game.attack_draft == read.attack_draft)
	var reference := RandomNumberGenerator.new()
	reference.state = random_state
	assert(game._d6() == reference.randi_range(1, 6))
	# Pending choices, movement vectors, integer keys and rolled results survive
	# serialization without JSON coercion or a second dice roll.
	var interrupted := original.duplicate(true)
	interrupted["persistence_fixture"] = {"movement": {101: Vector2(2.25, -3.5)}, "pending": [{"dice": [6, 1, 4], "choice": "defender"}], "bounds": Rect2(-1, -2, 3, 4)}
	assert(Save.write(interrupted, game._save_config(), random_state, {}).is_empty())
	assert(Save.read().state == interrupted)
	var config: Dictionary = game._save_config()
	var incompatible: Dictionary = original.duplicate(true)
	incompatible.pack_hash = "different"
	assert(Save.write(incompatible, config, random_state, {}).is_empty())
	game._load_match()
	assert(game.state == original)
	assert(Save.write(original, config, random_state, {}).is_empty())
	if "--resume-host" in OS.get_cmdline_user_args():
		game._load_match(true)
		assert(game.mode == "host" and game.state == original)
	game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	game.mode = "local"
	game._start_allocation_practice()
	game._begin_attack_plan()
	game._assign_attack()
	var draft: Dictionary = game.attack_draft.duplicate(true)
	assert(not draft.is_empty())
	assert(game._save_snapshot().is_empty())
	game.attack_draft = {}
	game._load_match()
	assert(game.attack_draft == draft and game.allocation_practice)
	game.selected = int(draft.attacker)
	game._confirm_attack_plan()
	var resolved: Dictionary = game.state.duplicate(true)
	var next_random: int = game.rng.state
	assert(resolved.revision > 0)
	assert(game._save_snapshot().is_empty())
	game._start_prepared_match()
	game._load_match()
	assert(game.state == resolved and game.rng.state == next_random)
	var object := Node.new()
	assert(not Save.safe({"object": object}))
	object.free()
	var file := FileAccess.open(Save.PATH, FileAccess.WRITE)
	file.store_string("corrupted")
	file.close()
	assert(Save.read().has("error"))
	print("MATCH SAVE: PASS")
	game.free()
	quit()

func find_unsafe(value: Variant) -> void:
	if Save.safe(value): return
	if value is Dictionary:
		for key in value:
			if typeof(key) not in [TYPE_STRING, TYPE_INT]: print("UNSAFE KEY: ", key, " type ", typeof(key))
			find_unsafe(value[key])
	elif value is Array:
		for item in value: find_unsafe(item)
	else: print("UNSAFE VALUE: ", value, " type ", typeof(value))

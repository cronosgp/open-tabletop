extends Node
## Test-only acknowledgement: snapshot comparison must finish before play resumes.
## Both peers add this node at the same path. It never changes gameplay state.
var game: Node
var expected: Dictionary = {}
var arrived := false
var released := ""
var awaiting: Dictionary = {}
var retry_after := 0.0
var previous_tick := 0

static func digest(state: Dictionary) -> String:
	return var_to_bytes(canonical(state)).hex_encode().sha256_text()

static func canonical(value: Variant) -> Variant:
	# Dictionary insertion order is not gameplay state. Preserve every typed key,
	# scalar and array element while ordering dictionary entries deterministically.
	if value is Dictionary:
		var keys: Array = value.keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return var_to_str(a) < var_to_str(b))
		var entries: Array = []
		for key: Variant in keys: entries.append([typeof(key), key, canonical(value[key])])
		return [TYPE_DICTIONARY, entries]
	if value is Array:
		var entries: Array = []
		for element: Variant in value: entries.append(canonical(element))
		return [TYPE_ARRAY, entries]
	return [typeof(value), value]

func expect(checkpoint: String, state: Dictionary) -> void:
	expected = {"checkpoint": checkpoint, "state": state.duplicate(true)}
	arrived = false

func arrive(checkpoint: String, state: Dictionary) -> void:
	released = ""
	awaiting = {"checkpoint": checkpoint, "state": state.duplicate(true)}
	_send_arrival()

func _process(delta: float) -> void:
	if not is_instance_valid(game):
		set_process(false)
		return
	var now := Time.get_ticks_msec()
	if previous_tick > 0 and now - previous_tick > 2000:
		print("NETWORK FRAME GAP: mode=%s elapsed_ms=%d revision=%d" % [game.mode, now - previous_tick, int(game.state.get("revision", -1))])
	previous_tick = now
	if awaiting.is_empty() or game.mode != "client": return
	retry_after -= delta
	if retry_after <= 0.0: _send_arrival()

func _send_arrival() -> void:
	# A guest may finish before the host's polling continuation reaches expect().
	# Retrying the immutable checkpoint is safe and cannot advance gameplay.
	acknowledge.rpc_id(1, str(awaiting.checkpoint), awaiting.state)
	retry_after = 1.0

@rpc("any_peer", "call_remote", "reliable")
func acknowledge(checkpoint: String, state: Dictionary) -> void:
	if game.mode != "host" or not game.match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): return
	if str(expected.get("checkpoint", "")) != checkpoint: return
	if expected.state != state:
		# Keep both public states for diagnosis; private seat credentials are absent.
		for item: Array in [["host", expected.state], ["guest", state]]:
			var diagnostic := FileAccess.open("res://.tools/checkpoint-%s-%s.state" % [checkpoint, item[0]], FileAccess.WRITE)
			if diagnostic != null: diagnostic.store_var(item[1])
		push_error("Network checkpoint %s has different host/guest values (revisions %d/%d)." % [checkpoint, int(expected.state.get("revision", -1)), int(state.get("revision", -1))])
		return
	if var_to_bytes(expected.state) != var_to_bytes(state): print("NETWORK CHECKPOINT: %s states compare equal with different serialized ordering." % checkpoint)
	arrived = true

func release_guest() -> void:
	release.rpc_id(game.guest_id, str(expected.checkpoint))

@rpc("authority", "call_remote", "reliable")
func release(checkpoint: String) -> void:
	if game.mode == "client" and str(awaiting.get("checkpoint", "")) == checkpoint:
		released = checkpoint
		awaiting.clear()

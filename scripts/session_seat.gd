extends RefCounted
## Private session credentials never belong in the public game snapshot.
const Save = preload("res://scripts/match_save.gd")
const PATH := "user://matches/guest-seats.save"

static func secret() -> String:
	return Crypto.new().generate_random_bytes(32).hex_encode()

static func valid(value: Variant) -> bool:
	if not value is String or value.length() != 64: return false
	for character in value:
		if character not in "0123456789abcdef": return false
	return true

static func create() -> Dictionary:
	return {"id": secret(), "token": ""}

static func valid_session(value: Variant) -> bool:
	return value is Dictionary and value.size() == 2 and valid(value.get("id")) and (value.get("token") == "" or valid(value.get("token")))

static func proof(token: String, nonce: String, session_id: String) -> String:
	if not valid(token) or not valid(nonce) or not valid(session_id): return ""
	return Crypto.new().hmac_digest(HashingContext.HASH_SHA256, token.to_utf8_buffer(), (session_id + nonce).to_utf8_buffer()).hex_encode()

static func accepts(session: Dictionary, nonce: String, response: String) -> bool:
	if not valid_session(session) or not valid(session.token) or not valid(response): return false
	return Crypto.new().constant_time_compare(proof(session.token, nonce, session.id).to_ascii_buffer(), response.to_ascii_buffer())

static func credentials(path: String = PATH) -> Dictionary:
	if not FileAccess.file_exists(path): return {"seats": {}}
	var saved := Save.read(path)
	if saved.has("error"): return saved
	for id in saved.state:
		if not valid(id) or not valid(saved.state[id]): return {"error": "Invalid local credentials."}
	return {"seats": saved.state}

static func remember(session_id: String, token: String, path: String = PATH) -> String:
	if not valid(session_id) or not valid(token): return "Invalid session credential."
	var saved := credentials(path)
	if saved.has("error"): return saved.error
	if saved.seats.size() >= 1024 and not saved.seats.has(session_id): return "Local session limit reached."
	saved.seats[session_id] = token
	return Save.write(saved.seats, {}, 0, {}, path)

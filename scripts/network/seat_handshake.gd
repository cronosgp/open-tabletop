extends RefCounted
## Challenge/proof protocol for authenticating the single guest seat on a hosted match.
## Persistence and match admission remain owned by the session coordinator.
const SessionSeat = preload("res://scripts/session_seat.gd")

static func begin_challenge(host_session: Dictionary, pending_seats: Dictionary, peer_id: int) -> Dictionary:
	var session := host_session
	if not SessionSeat.valid_session(session): session = SessionSeat.create()
	var nonce := SessionSeat.secret()
	pending_seats[peer_id] = {"nonce": nonce, "issued": ""}
	return {"session": session, "nonce": nonce, "claimed": not session.token.is_empty()}

static func guest_proof(session_id: String, nonce: String, claimed: bool) -> Dictionary:
	if not SessionSeat.valid(session_id) or not SessionSeat.valid(nonce): return {"error": "Invalid host seat challenge."}
	var saved := SessionSeat.credentials()
	if saved.has("error"): return {"error": saved.error}
	var token: String = saved.seats.get(session_id, "")
	if claimed and token.is_empty(): return {"error": "This seat belongs to another guest. Use the local credentials from the computer that joined as player 2."}
	return {"error": "", "response": SessionSeat.proof(token, nonce, session_id)}

static func decide_request(host_session: Dictionary, pending_seats: Dictionary, guest_id: int, peer_id: int, response: String) -> Dictionary:
	if not SessionSeat.valid_session(host_session) or not pending_seats.has(peer_id) or guest_id != 0:
		return {"status": "ignore"}
	var pending: Dictionary = pending_seats[peer_id]
	var nonce: String = pending.nonce
	if host_session.token.is_empty() and pending.issued.is_empty():
		var token := SessionSeat.secret()
		pending.issued = token
		pending_seats[peer_id] = pending
		return {"status": "issue_token", "session_id": host_session.id, "nonce": nonce, "token": token}
	var candidate := host_session.duplicate(true)
	if candidate.token.is_empty(): candidate.token = pending.issued
	if not SessionSeat.accepts(candidate, nonce, response): return {"status": "reject"}
	return {"status": "authenticated", "session": candidate}

static func guest_token_proof(challenge: Dictionary, session_id: String, nonce: String, token: String) -> Dictionary:
	if challenge.get("id") != session_id or challenge.get("nonce") != nonce: return {"error": "Host seat challenge expired."}
	var error := SessionSeat.remember(session_id, token)
	if not error.is_empty(): return {"error": error}
	return {"error": "", "response": SessionSeat.proof(token, nonce, session_id)}

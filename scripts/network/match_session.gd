extends RefCounted
## Owns the host and guest seat lifecycle for one hosted match.
## The root node remains the RPC endpoint and supplies durable snapshot storage.
const SessionSeat = preload("res://scripts/session_seat.gd")
const SeatHandshake = preload("res://scripts/network/seat_handshake.gd")

var host_session: Dictionary = {}
var pending_seats: Dictionary = {}
var guest_challenge: Dictionary = {}
var guest_id := 0

static func valid_host_session(value: Variant) -> bool:
	return SessionSeat.valid_session(value)

func start_host(restored: Dictionary = {}) -> void:
	host_session = restored.duplicate(true) if not restored.is_empty() else SessionSeat.create()
	pending_seats.clear()
	guest_challenge.clear()
	guest_id = 0

func reset() -> void:
	host_session = {}
	pending_seats.clear()
	guest_challenge.clear()
	guest_id = 0

func begin_challenge(peer_id: int) -> Dictionary:
	var challenge: Dictionary = SeatHandshake.begin_challenge(host_session, pending_seats, peer_id)
	host_session = challenge.session
	return challenge

func accept_challenge(session_id: String, nonce: String, claimed: bool) -> Dictionary:
	guest_challenge = {"id": session_id, "nonce": nonce}
	return SeatHandshake.guest_proof(session_id, nonce, claimed)

func decide_seat(peer_id: int, response: String) -> Dictionary:
	return SeatHandshake.decide_request(host_session, pending_seats, guest_id, peer_id, response)

## Persists the reservation before admitting the peer; restores memory on save failure.
func reserve(candidate: Dictionary, persist: Callable, phase: String) -> String:
	if not SessionSeat.valid_session(candidate): return "Invalid host seat reservation."
	var previous := host_session.duplicate(true)
	host_session = candidate.duplicate(true)
	if phase != "army_selection":
		var error := str(persist.call())
		if not error.is_empty():
			host_session = previous
			return error
	return ""

func admit(peer_id: int) -> void:
	pending_seats.erase(peer_id)
	guest_id = peer_id

## Authorizes match commands only from the currently admitted guest seat.
func accepts_guest_command(peer_id: int) -> bool:
	return guest_id > 0 and peer_id == guest_id

func reject(peer_id: int) -> void:
	pending_seats.erase(peer_id)

func receive_token(session_id: String, nonce: String, token: String) -> Dictionary:
	return SeatHandshake.guest_token_proof(guest_challenge, session_id, nonce, token)

func guest_ready() -> void:
	guest_challenge.clear()

## Returns the disconnect context before clearing it for the caller's UI and match updates.
func peer_disconnected(peer_id: int) -> Dictionary:
	var was_pending := pending_seats.has(peer_id)
	pending_seats.erase(peer_id)
	var was_guest := peer_id == guest_id and guest_id != 0
	if was_guest: guest_id = 0
	return {"pending": was_pending, "guest": was_guest}

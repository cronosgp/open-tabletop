extends Node
## ENet adapter for the one-player-hosted match transport.
## Match rules and seat authorization remain in the match/session layer.
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connected_to_server
signal connection_failed
signal server_disconnected

var api: MultiplayerAPI

func bind(multiplayer_api: MultiplayerAPI) -> void:
	if api == multiplayer_api: return
	_unbind()
	api = multiplayer_api
	api.peer_connected.connect(_on_peer_connected)
	api.peer_disconnected.connect(_on_peer_disconnected)
	api.connected_to_server.connect(_on_connected_to_server)
	api.connection_failed.connect(_on_connection_failed)
	api.server_disconnected.connect(_on_server_disconnected)

func start_host(port: int, max_clients: int) -> String:
	if api == null: return "Multiplayer transport is not bound."
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_clients)
	if error != OK: return "Cannot host: " + error_string(error)
	api.multiplayer_peer = peer
	return ""

func start_client(address: String, port: int) -> String:
	if api == null: return "Multiplayer transport is not bound."
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK: return "Cannot join: " + error_string(error)
	api.multiplayer_peer = peer
	return ""

func reset() -> void:
	if api != null: api.multiplayer_peer = OfflineMultiplayerPeer.new()

func disconnect_peer(peer_id: int) -> void:
	if api != null: api.multiplayer_peer.disconnect_peer(peer_id)

func current_peer() -> MultiplayerPeer:
	return api.multiplayer_peer if api != null else null

func has_peer(peer_id: int) -> bool:
	return api != null and peer_id in api.get_peers()

func connected() -> bool:
	return api != null and api.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func _unbind() -> void:
	if api == null: return
	if api.peer_connected.is_connected(_on_peer_connected): api.peer_connected.disconnect(_on_peer_connected)
	if api.peer_disconnected.is_connected(_on_peer_disconnected): api.peer_disconnected.disconnect(_on_peer_disconnected)
	if api.connected_to_server.is_connected(_on_connected_to_server): api.connected_to_server.disconnect(_on_connected_to_server)
	if api.connection_failed.is_connected(_on_connection_failed): api.connection_failed.disconnect(_on_connection_failed)
	if api.server_disconnected.is_connected(_on_server_disconnected): api.server_disconnected.disconnect(_on_server_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)

func _on_connected_to_server() -> void:
	connected_to_server.emit()

func _on_connection_failed() -> void:
	connection_failed.emit()

func _on_server_disconnected() -> void:
	server_disconnected.emit()

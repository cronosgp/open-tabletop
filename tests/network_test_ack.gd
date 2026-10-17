extends Node
## Test-only acknowledgement; no production scene loads this node.
var acknowledged := false
@rpc("any_peer", "call_remote", "reliable")
func finish() -> void:
	if multiplayer.get_remote_sender_id() != 0: acknowledged = true

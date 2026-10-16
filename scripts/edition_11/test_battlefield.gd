extends RefCounted
## User-selected initial testing assumptions, not an official mission/roster validator.
const ID := "incursion-test-1000-43x43-v1"
const SIZE := Vector2(43, 43)
const POINTS := 1000

static func apply(state: Dictionary) -> Dictionary:
	if state.has("error") or state.get("test_battlefield", "") == ID: return state
	state.board_size = SIZE
	state.battle_size = "Incursion"
	state.points_limit = POINTS
	state.roster_points_validated = false
	state.test_battlefield = ID
	state.pack_hash = (str(state.pack_hash) + ":" + ID).sha256_text()
	return state

extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const D = preload("res://scripts/edition_11/deployment.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var s := Combat.initial_state()
	s.board_size = Vector2(44, 30)
	for id: int in s.units:
		if id not in [100, 200]: s.units[id].wounds = 0
	# Synthetic dependency fixture: production Eliminator admission stays blocked.
	s.units[100].definition_id = "40kdc:11e:adeptus-astartes:eliminator-squad"
	A.enable(s)
	D.begin(s)
	s.unit_abilities.setup_players = [1, 2]
	s.deployment.zones = {1: Rect2(-22, -15, 8, 30), 2: Rect2(14, -15, 8, 30)}
	s.units[200].position = Vector2(0, -8)
	return s

func _initialize() -> void:
	var s := fixture()
	var point := Vector2(0, -8)
	check(D.position_error(s, 100, point).is_empty(), "Undeployed enemy preview blocked infiltration")
	var r: float = s.units[100].radius
	check(not D.position_error(s, 100, Vector2(6 - r, -8)).is_empty(), "Exactly 8 inches from enemy zone accepted")
	check(D.position_error(s, 100, Vector2(6 - r - 0.02, -8)).is_empty(), "More than 8 inches from enemy zone rejected")
	check(not D.position_error(s, 100, Vector2(-s.board_size.x / 2.0, -8)).is_empty(), "Infiltration allowed base over board edge")
	check(not D.position_error(s, 100, Vector2(-2.9, 0)).is_empty(), "Infiltration allowed base inside solid terrain")
	s.deployment.committed = [2]
	check(not D.position_error(s, 100, point).is_empty(), "Deployed enemy separation omitted")
	var radii: float = r + s.units[200].radius
	check(not D.position_error(s, 100, Vector2(-8 - radii, -8)).is_empty(), "Exactly 8 inches from enemy base accepted")
	check(D.position_error(s, 100, Vector2(-8 - radii - 0.02, -8)).is_empty(), "Valid base-to-base enemy separation rejected")
	s.deployment.committed = []
	s.deployment.placed[200] = true
	check(not D.position_error(s, 100, point).is_empty(), "Placed enemy model ignored")
	s.units[200].on_battlefield = false
	check(D.position_error(s, 100, point).is_empty(), "Off-board enemy blocked infiltration")
	s.units[200].on_battlefield = true
	s.units[200].wounds = 0
	check(D.position_error(s, 100, point).is_empty(), "Dead enemy blocked infiltration")
	s = fixture()
	s.units[101].wounds = 1
	check(not D.position_error(s, 100, point).is_empty(), "Mixed unit retained Infiltrators")
	s.units[101].definition_id = s.units[100].definition_id
	check(D.position_error(s, 100, point).is_empty(), "All-model unit lost Infiltrators")
	s.units[101].wounds = 0
	s.unit_abilities.implementation = "historical"
	check(not D.position_error(s, 100, point).is_empty(), "Disabled implementation gained Infiltrators")
	check(D.position_error(s, 100, Vector2(-18, -8)).is_empty(), "Ordinary own-zone deployment lost")
	s = fixture()
	var before := var_to_str(s)
	check(not D.place(s, 2, 100, point, s.revision).is_empty() and var_to_str(s) == before, "Wrong actor mutated infiltration")
	check(D.place(s, 1, 100, point, s.revision).is_empty(), "Legal infiltration command rejected")
	before = var_to_str(s)
	check(not D.place(s, 1, 100, Vector2(-1, -8), s.revision - 1).is_empty() and var_to_str(s) == before, "Stale placement mutated state")
	check(D.confirm(s, 1, s.revision).is_empty() and 1 in s.deployment.committed and D.actor(s) == 2, "Infiltrator confirmation broke alternating deployment")
	# Confirmation revalidates positions and coherency, rather than trusting placement.
	s = fixture()
	check(D.place(s, 1, 100, point, s.revision).is_empty(), "Initial infiltration rejected")
	s.units[101].wounds = 1
	s.units[101].definition_id = s.units[100].definition_id
	s.units[101].position = Vector2(-10, -8)
	s.deployment.placed[101] = true
	check(not D.confirm(s, 1, s.revision).is_empty(), "Infiltrator unit bypassed coherency")
	s.units[101].wounds = 0
	s.deployment.committed = [2]
	check(not D.confirm(s, 1, s.revision).is_empty(), "Confirmation trusted an invalid enemy-distance placement")
	print("Infiltrators checks complete: %d failures" % failures)
	quit(1 if failures else 0)

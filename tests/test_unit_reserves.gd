extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const U = C.UnitActions
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func act(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2, point: Vector2 = Vector2.ZERO) -> String:
	for selected: Dictionary in C.unit_choices(s, owner):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return C.unit_action(s, owner, selected, point, s.revision)
	return "Unavailable: " + action
func fresh() -> Dictionary:
	var s := F.fresh()
	check(not s.has("error"), "Ten-unit reserve fixture admitted")
	C.select_awakened_attachment(s, 2, -1, 0)
	check(act(s, 1, "attach", 900, 1).is_empty(), "Support assigned")
	check(act(s, 1, "warlord", 300).is_empty(), "Marine Warlord assigned")
	var before := var_to_bytes(s)
	check(not act(s, 1, "reserve", -1, 1).is_empty() and before == var_to_bytes(s), "Only eligible Deep Strike units can use this reserve workflow")
	check(act(s, 1, "reserve", -1, 11).is_empty(), "Terminator unit enters reserves within half-limit")
	check(C.living(s, 11).is_empty() and s.units[1100].wounds == 3 and not s.units[1100].on_battlefield and 11 not in s.deployment.order, "Reserves preserve wounds but leave board and deployment order")
	check(act(s, 1, "setup-done").is_empty() and act(s, 2, "warlord", 600).is_empty() and act(s, 2, "setup-done").is_empty(), "Both preparations complete")
	s.phase = "start_turn"
	s.deployment.complete = true
	check(U.battle_actor(s) == 1 and act(s, 1, "homer", -1, 11, Vector2(-8, -6)).is_empty(), "Homer is declared at battle start after deployment, including a reserve unit")
	check(act(s, 1, "battle-done").is_empty() and U.battle_actor(s) == -1, "Optional start-of-battle window closes")
	for model: int in s.units:
		if not s.units[model].get("on_battlefield", true): continue
		s.units[model].position = Vector2(-15 if s.units[model].owner == 1 else 15, 10 + (model % 5) * 1.7 if s.units[model].owner == 1 else -10 + (model % 5) * 1.7)
	return s
func _initialize() -> void:
	var s := fresh()
	s.phase = "movement"
	s.unit_abilities.phase_key = U.key(s)
	check(not act(s, 1, "ingress", -1, 11).is_empty(), "No first-round ingress")
	check(not C.begin_movement(s, 1, 1100, "normal", s.revision).is_empty() and not C.attack_window_error(s, 1, 1100, s.revision, false).is_empty(), "Reserved models cannot move or attack on the board")
	s.round = 2
	s.turn = 3
	s.unit_abilities.phase_key = U.key(s)
	check(act(s, 1, "ingress", -1, 11).is_empty(), "Own Movement permits second-round Deep Strike")
	var window: Dictionary = U.pending(s).duplicate(true)
	check(not act(s, 1, "ingress-place", 1100, 11, Vector2(30, 0)).is_empty() and U.pending(s) == window, "Off-board ingress rejected transactionally")
	check(not act(s, 1, "ingress-place", 1100, 11, s.units[200].position).is_empty(), "Enemy overlap/within eight inches rejected")
	check(not act(s, 1, "ingress-confirm").is_empty(), "Cannot confirm missing model positions")
	for index in range(5):
		check(act(s, 1, "ingress-place", 1100 + index, 11, Vector2(-8 + (index % 3) * 1.7, -6 + (index / 3) * 1.7)).is_empty(), "Each reserved model can stage legal arrival")
	check(C.living(s, 11).is_empty() and U.pending(s).positions.size() == 5, "Ingress positions remain previews until confirmation")
	var restored: Dictionary = bytes_to_var(var_to_bytes(s))
	check(act(restored, 1, "ingress-confirm").is_empty() and C.living(restored, 11).size() == 5 and restored.squads[11].set_up_this_turn, "Serialized ingress preview commits coherently and marks setup")
	check(not C.begin_movement(restored, 1, 1100, "normal", restored.revision).is_empty(), "Arriving units cannot make another Movement move")
	s = fresh()
	s.phase = "movement"
	s.active = 2
	s.round = 2
	s.turn = 4
	s.unit_abilities.phase_key = U.key(s)
	s.cp[1] = 0
	check(U.open_end(s), "End of opponent Movement opens ingress reaction")
	# Necron Orb optional window precedes non-active player's reaction.
	check(act(s, 2, "pass").is_empty(), "Active player's end-phase abilities resolve first")
	check(act(s, 1, "homer-ingress", -1, 11).is_empty(), "Homer grants zero-CP Rapid Ingress")
	for index in range(5): act(s, 1, "ingress-place", 1100 + index, 11, Vector2((index % 3) * 1.7, (index / 3) * 1.7))
	check(not act(s, 1, "ingress-confirm").is_empty(), "Homer arrival unit must be within three inches")
	for index in range(5): check(act(s, 1, "ingress-place", 1100 + index, 11, Vector2(-8 + (index % 3) * 1.7, -6 + (index / 3) * 1.7)).is_empty(), "Homer positions stage")
	check(act(s, 1, "ingress-confirm").is_empty() and s.cp[1] == 0 and not s.unit_abilities.homers.has(11), "Homer consumed once, no CP spent")
	check(s.stratagems.uses[-1].stratagem == "rapid-ingress", "Rapid Ingress enters the shared stratagem use journal")
	s = fresh()
	s.units[200].position = Vector2(-8, -6)
	U.reconcile(s)
	check(s.unit_abilities.homers.has(11), "Proximity alone does not remove Homer before an enemy move ends")
	U.end_move(s, 2)
	check(not s.unit_abilities.homers.has(11), "Enemy ending a move within one inch removes Homer")
	s.round = 4
	U.reconcile(s)
	check(s.units[1100].wounds == 0 and s.unit_abilities.reserves.is_empty(), "Unarrived reserves are destroyed after round three")
	print("Unit reserves checks: %d failures" % failures)
	quit(1 if failures else 0)

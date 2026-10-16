extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Capabilities = Training.Capabilities
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Leaders = preload("res://scripts/edition_11/leaders.gd")
const CAPTAIN := "40kdc:11e:adeptus-astartes:captain"
const OVERLORD := "40kdc:11e:necrons:overlord"
const INTERCESSOR := "40kdc:11e:adeptus-astartes:intercessor-squad"
const TERMINATOR := "40kdc:11e:adeptus-astartes:terminator-squad"
const WARRIORS := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS := "40kdc:11e:necrons:immortals"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func sm_selection() -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [
		{"definition_id": CAPTAIN, "models": 1, "copies": 1},
		{"definition_id": INTERCESSOR, "models": 5, "copies": 2},
		{"definition_id": TERMINATOR, "models": 5, "copies": 2}]}
func necron_selection() -> Dictionary:
	return {"schema_version": 2, "faction": "Necrons", "category": "incursion", "points_limit": 1000, "entries": [
		{"definition_id": OVERLORD, "models": 1, "copies": 1},
		{"definition_id": WARRIORS, "models": 10, "copies": 2},
		{"definition_id": IMMORTALS, "models": 5, "copies": 2}]}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var captain := Capabilities.resolve("Space Marines", CAPTAIN)
	var overlord := Capabilities.resolve("Necrons", OVERLORD)
	check(captain.error.is_empty() and captain.cost == 80 and captain.models == 1, "Captain resolves at canonical 80 points")
	check(overlord.error.is_empty() and overlord.cost == 90 and overlord.models == 1, "Overlord resolves at canonical 90 points")
	check(captain.weapons.gun.attacks > 0 and captain.weapons.blade.attacks > 0, "Captain fixed loadout has ranged and melee attacks")
	check(overlord.weapons.gun.range_inches > 0 and overlord.weapons.blade.attacks > 0, "Overlord staff of light resolves ranged and melee profiles")
	var sm := Capabilities.admit(sm_selection())
	var nec := Capabilities.admit(necron_selection())
	check(sm.error.is_empty() and sm.total == 560, "Captain-led Space Marine list admits at 560 points")
	check(nec.error.is_empty() and nec.total == 400, "Overlord-led Necron list admits at 400 points")
	check(var_to_str(sm.warnings).contains("Captain:") and var_to_str(sm.warnings).contains("leader"), "Captain declares its unimplemented Leader ability")
	check(var_to_str(nec.warnings).contains("Overlord:") and var_to_str(nec.warnings).contains("resurrection-orb"), "Overlord declares its unimplemented abilities")
	var state := Prepared.initial_state({}, {1: sm.selection, 2: nec.selection})
	check(not state.has("error"), "Commanders build a real match")
	var captain_squad := -1
	var overlord_squad := -1
	for squad: int in state.squads:
		if not Leaders.is_leader(state, squad): continue
		if state.squads[squad].owner == 1: captain_squad = squad
		else: overlord_squad = squad
	check(captain_squad >= 0 and state.squads[captain_squad].starting_strength == 1 and state.squads[captain_squad].stats.toughness == 5 and state.units[captain_squad * 100].max_wounds == 5, "Captain is one model with T5 and 5 wounds")
	check(is_equal_approx(state.units[captain_squad * 100].radius, 40.0 / 50.8), "Captain uses a 40mm base")
	check(Leaders.can_attach(state, captain_squad, 3), "Captain squad can join an Intercessor squad")
	check(overlord_squad >= 0 and state.squads[overlord_squad].stats.toughness == 5 and state.units[overlord_squad * 100].max_wounds == 6, "Overlord squad is a Leader with its own profile")
	print("Commander checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

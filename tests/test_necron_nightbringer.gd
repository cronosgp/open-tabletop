extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const NightbringerDrainLife = preload("res://scripts/edition_11/nightbringer_drain_life.gd")
const NIGHTBRINGER_ID := "40kdc:11e:necrons:ctan-shard-of-the-nightbringer"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func units_for(state: Dictionary, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func find_action(state: Dictionary, player: int, action: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action: return option
	return {}

func act(state: Dictionary, player: int, option: Dictionary) -> Dictionary:
	return UnitActions.apply(state, player, option, Vector2.ZERO, Callable(self, "next_die"))

func run() -> void:
	var profile := Profiles.profile("ctan-shard-of-the-nightbringer")
	var gaze: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var strike: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("strike", {})
	check(profile.get("source_datasheet_id", "") == "000000541" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Nightbringer facts retain their local Necrons App v1.2 snapshot identity")
	check(profile.get("points_by_models", {}) == {1: 360} and profile.get("base_size_source_mm", 0) == 90 and profile.get("stats", {}).get("wounds", 0) == 16 and profile.get("stats", {}).get("invulnerable_target", 0) == 4, "Nightbringer keeps its one-model 360 point, 90 mm, 16-wound source profile")
	check(gaze.get("attacks") == "D3" and gaze.get("strength") == 12 and gaze.get("damage") == "D6+3" and strike.get("attacks") == 6 and strike.get("keywords", {}) == {"devastating-wounds": true}, "Nightbringer Gaze and Scythe weapon profiles preserve the local attack values and trait")
	check(profile.get("supported_rule_ids", []).has("drain-life") and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_options", []).is_empty(), "Drain Life closes the Nightbringer's remaining local ability and configuration checks")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": NIGHTBRINGER_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 360, "The one-model Nightbringer enters the consolidated construction catalog at 360 points")

	var selections := F.current_marine_selections()
	selections[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	selections[1].category = "custom"
	selections[1].points_limit = 500
	selections[2].faction = "Necrons"
	selections[2].category = "custom"
	selections[2].points_limit = 500
	selections[2].entries = [{"definition_id": NIGHTBRINGER_ID, "models": 1, "copies": 1}]
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": true}, selections)
	if state.has("error"):
		check(false, "Nightbringer and Marine fixture admits from the checked local profiles: " + str(state.get("error", "")))
		quit(1)
		return
	var nightbringer_models := units_for(state, "ctan-shard-of-the-nightbringer")
	var nightbringer_squad := squad_for(state, "ctan-shard-of-the-nightbringer")
	var marine_squad := squad_for(state, "intercessor-squad")
	check(nightbringer_models.size() == 1 and nightbringer_squad >= 0 and marine_squad >= 0, "The local battle fixture materializes the Nightbringer and opposing Marines")
	if nightbringer_models.is_empty() or nightbringer_squad < 0 or marine_squad < 0:
		quit(1)
		return
	var source := nightbringer_models[0]
	var marines := Geometry.alive(state, marine_squad)
	check(Abilities.has(state, nightbringer_squad, "drain-life") and Abilities.deadly_demise_value(state, source) == "D6" and Abilities.cannot_be_warlord(state, source), "Nightbringer binds Drain Life alongside its existing C'tan rules")
	for model: int in state.units:
		state.units[model].on_battlefield = false
		state.units[model].position = Vector2.ZERO
	state.units[source].on_battlefield = true
	state.units[source].position = Vector2.ZERO
	for model: int in marines:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(7.5, 0.0)
	state.squads[900001] = {"owner": 1, "name": "Synthetic enemy unit"}
	state.units[9000011] = {"owner": 1, "squad": 900001, "wounds": 2, "max_wounds": 2, "on_battlefield": true, "position": Vector2(10.0, 0.0), "radius": 0.5, "keywords": []}
	state.phase = "fight"
	check(NightbringerDrainLife.available(state, 2), "Drain Life becomes available when an enemy unit is within 6 inches")
	for model: int in marines: state.units[model].position = Vector2(10.0, 0.0)
	state.units[9000011].position = Vector2(10.0, 0.0)
	check(not NightbringerDrainLife.available(state, 2), "Drain Life ignores an enemy unit outside its 6-inch range")
	for model: int in marines: state.units[model].position = Vector2(7.5, 0.0)
	state.units[9000011].position = Vector2(7.8, 0.0)
	state.phase = "shooting"
	check(not NightbringerDrainLife.available(state, 2), "Drain Life does not trigger outside the Fight phase")
	state.phase = "fight"
	state.active = 1
	state.unit_abilities.end_done = ""
	check(UnitActions.open_end(state) and state.unit_abilities.window.get("kind", "") == "end" and state.unit_abilities.window.get("owners", []).has(2), "The shared Fight phase end window opens for the Nightbringer owner")
	var explicit_choice := find_action(state, 2, NightbringerDrainLife.ACTION)
	var end_pass_choice := find_action(state, 2, "pass")
	check(not explicit_choice.is_empty() and not end_pass_choice.is_empty(), "The Fight phase end window offers Drain Life and its standard pass choice to the owner")
	scripted_dice = [4, 6, 3]
	var forced_error := C.unit_action(state, 2, end_pass_choice, Vector2.ZERO, int(state.get("revision", -1)), Callable(self, "next_die"))
	check(forced_error.is_empty() and not state.get("pending_drain_life", {}).is_empty(), "The public unit-action command resolves mandatory Drain Life before accepting its owner's pass")
	if state.get("pending_drain_life", {}).is_empty():
		quit(1)
		return
	var packet: Dictionary = state.pending_drain_life.get("packets", [{}])[0]
	check(state.pending_drain_life.events.size() == 2 and state.pending_drain_life.events[0].get("d6", 0) == 4 and state.pending_drain_life.events[1].get("d6", 0) == 3 and state.pending_drain_life.packets.size() == 1 and packet.get("d6", 0) == 4 and packet.get("roll", {}).get("value", 0) == 3 and packet.get("remaining", 0) == 3, "Drain Life rolls once per nearby enemy unit and creates a separate D3 packet only on a 4+")
	var original_wounds := 0
	for model: int in marines: original_wounds += int(state.units[model].wounds)
	for index in range(3):
		var allocation := find_action(state, 1, NightbringerDrainLife.ALLOCATE)
		check(not allocation.is_empty(), "The affected defender receives the mortal wound allocation choice %d" % (index + 1))
		if allocation.is_empty(): break
		var result := act(state, 1, allocation)
		check(str(result.get("error", "")).is_empty(), "Drain Life mortal wound %d resolves through the defender's selected model" % (index + 1))
	var remaining_wounds := 0
	for model: int in marines: remaining_wounds += maxi(0, int(state.units[model].wounds))
	check(state.get("pending_drain_life", {}).is_empty() and remaining_wounds == original_wounds - 3 and state.get("last_drain_life", {}).get("allocations", []).size() == 3, "Three mortal wounds are allocated one at a time and the Fight end window resumes")
	check(not NightbringerDrainLife.available(state, 2) and state.unit_abilities.window.get("kind", "") == "end", "Drain Life cannot be repeated in the same Fight phase after resolving")
	var pass_end := act(state, 2, {"action": "pass", "model": -1, "target": -1, "value": ""})
	check(str(pass_end.get("error", "")).is_empty() and state.unit_abilities.window.is_empty(), "The Nightbringer owner can pass once Drain Life is complete")
	state.turn = int(state.get("turn", 0)) + 1
	state.phase = "fight"
	state.active = 1
	state.unit_abilities.end_done = ""
	check(UnitActions.open_end(state), "The next Fight phase end window opens for a fresh Drain Life use")
	scripted_dice = [3, 2]
	var no_trigger := act(state, 2, {"action": "pass", "model": -1, "target": -1, "value": ""})
	var no_trigger_events: Array = state.get("last_drain_life", {}).get("events", [])
	check(str(no_trigger.get("error", "")).is_empty() and state.get("pending_drain_life", {}).is_empty() and no_trigger_events.size() == 2 and no_trigger_events.all(func(event: Dictionary) -> bool: return not event.get("triggered", true)), "Each nearby enemy unit still receives its D6 roll when Drain Life causes no mortal wounds")

	if failures == 0: print("Necron C’tan Shard of the Nightbringer local checks: passed")
	else: print("Necron C’tan Shard of the Nightbringer local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Demise = preload("res://scripts/edition_11/deadly_demise.gd")
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
var failures := 0
var dice_values: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1

func _initialize() -> void: call_deferred("run")

func roll_die() -> int:
	return dice_values.pop_front() if not dice_values.is_empty() else 1

func submit_unit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The current decision does not project the submitted Deadly Demise choice."}
	var payload := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, roller)

func selections() -> Dictionary:
	var result := F.selections()
	for entry: Dictionary in result[1].entries:
		if entry.definition_id.ends_with(":assault-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:ballistus-dreadnought"
			entry.models = 1
	result[2].faction = "Space Marines"
	result[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "models": 1, "copies": 1}]
	return result

func run() -> void:
	var p := P.profile("ballistus-dreadnought")
	check(p.source_book_id == "000000139" and p.source_datasheet_id == "000000091" and p.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Profile cites the local Space Marines 11e export")
	check(p.points == 150 and p.points_by_models == {1: 150} and p.third_plus_points_by_models == {1: 170} and p.models == 1 and p.stats == {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0}, "Ballistus characteristics, two first unit costs and third-plus cost match the extracted sheet")
	check(p.ranged.size() == 3 and p.ranged[1].profiles.has("frag") and p.ranged[1].profiles.has("krak") and p.ranged[1].profiles.frag.attacks == "D6+6" and p.ranged[1].profiles.frag.keywords.blast == 2 and p.ranged[1].profiles.krak.damage == "D3+3" and p.melee[0].profiles.standard.name == "Armoured Feet", "All default ranged modes and melee weapon match the extraction")
	check(Army.SPECS["ballistus-dreadnought"].validation_status == "tests_passed_local_targeted", "The complete local profile and all source abilities pass targeted validation")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "models": 1, "copies": 1}]})
	check(admitted.error.is_empty() and admitted.total == 150, "Ballistus enters local construction at its extracted cost")
	var two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "models": 1, "copies": 2}]})
	check(two.error.is_empty() and two.total == 300, "First two Ballistus copies use the extracted 150-point cost")
	var three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "models": 1, "copies": 3}]})
	check(three.error.is_empty() and three.total == 470, "Third Ballistus uses the extracted third-plus price")
	var wounded := {"unit_abilities": {"implementation": Abilities.ID}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "wounds": 5},
		101: {"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "wounds": 4},
		102: {"definition_id": "40kdc:11e:adeptus-astartes:captain", "wounds": 4}}}
	check(Abilities.damaged_attack_penalty(wounded, 100) == 0 and Abilities.damaged_attack_penalty(wounded, 101) == -1 and Abilities.damaged_attack_penalty(wounded, 102) == 0, "Damaged 4 applies -1 to Hit at the threshold, to Ballistus attacks only")
	var state := {"units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:ballistus-dreadnought", "squad": 1, "owner": 1, "wounds": 0, "max_wounds": 12, "position": Vector2.ZERO, "radius": 0.1, "on_battlefield": true, "keywords": ["VEHICLE"]},
		200: {"definition_id": "fixture:enemy", "squad": 2, "owner": 2, "wounds": 6, "max_wounds": 6, "position": Vector2(5, 0), "radius": 0.1, "on_battlefield": true, "keywords": []},
		300: {"definition_id": "fixture:friendly", "squad": 3, "owner": 1, "wounds": 6, "max_wounds": 6, "position": Vector2(5.5, 0), "radius": 0.1, "on_battlefield": true, "keywords": []},
		400: {"definition_id": "fixture:outside", "squad": 4, "owner": 2, "wounds": 6, "max_wounds": 6, "position": Vector2(7, 0), "radius": 0.1, "on_battlefield": true, "keywords": []}},
		"squads": {1: {"owner": 1, "name": "Ballistus"}, 2: {"owner": 2, "name": "Enemy"}, 3: {"owner": 1, "name": "Friendly"}, 4: {"owner": 2, "name": "Outside"}},
		"unit_abilities": {"implementation": Abilities.ID, "window": {}}, "pending_attack": {}, "awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice_values = [6, 1, 6]
	var started := Demise.begin(state, [100], roll_die)
	check(started.error.is_empty() and not started.complete and state.pending_deadly_demise.packets.size() == 2, "A Deadly Demise 6 creates a separately rolled mortal packet for every unit within 6 inches")
	if not state.get("pending_deadly_demise", {}).is_empty():
		var packet_totals := [int(state.pending_deadly_demise.packets[0].remaining), int(state.pending_deadly_demise.packets[1].remaining)]
		check(packet_totals == [1, 3], "Each affected unit receives its own D3 result")
		var guard := 10
		while not state.pending_deadly_demise.is_empty() and guard > 0:
			guard -= 1
			var pending_packet: Dictionary = state.pending_deadly_demise.packets[state.pending_deadly_demise.packet_cursor]
			var options := Demise.choices(state, int(pending_packet.owner))
			check(not options.is_empty(), "The affected unit owner receives legal mortal-wound allocation choices")
			if options.is_empty(): break
			var allocation := Demise.allocate(state, int(pending_packet.owner), options[0], roll_die)
			check(allocation.error.is_empty(), "Deadly Demise mortal wounds resolve through the allocation path")
		check(guard > 0, "Deadly Demise queue completes without an allocation loop")
		check(state.units[200].wounds == 5 and state.units[300].wounds == 3 and state.units[400].wounds == 6, "Only units in range lose their separately rolled mortal wounds")
	var chain_state: Dictionary = state.duplicate(true)
	chain_state.units[200].definition_id = "40kdc:11e:adeptus-astartes:ballistus-dreadnought"
	chain_state.units[200].wounds = 1
	chain_state.units[200].max_wounds = 12
	chain_state.pending_attack = {"deadly_demise_checked": true}
	dice_values = [6, 1, 6, 6, 1]
	started = Demise.begin(chain_state, [100], roll_die)
	var chain_resume := false
	var chain_guard := 10
	while not chain_state.pending_deadly_demise.is_empty() and chain_guard > 0:
		chain_guard -= 1
		var chain_packet: Dictionary = chain_state.pending_deadly_demise.packets[chain_state.pending_deadly_demise.packet_cursor]
		var chain_options := Demise.choices(chain_state, int(chain_packet.owner))
		if chain_options.is_empty(): break
		var chain_allocation := Demise.allocate(chain_state, int(chain_packet.owner), chain_options[0], roll_die)
		if chain_allocation.get("resume_attack", false): chain_resume = true
		check(chain_allocation.error.is_empty(), "Chain explosion packets continue to allocate without losing the pending attack")
	check(chain_guard > 0 and chain_resume and chain_state.units[300].wounds == 0 and chain_state.units[400].wounds == 5 and chain_state.last_deadly_demise.events.size() == 2, "A Ballistus destroyed by mortal wounds explodes in sequence, then returns control to the pending attack")
	var no_trigger := {"units": state.units.duplicate(true), "squads": state.squads.duplicate(true), "unit_abilities": {"implementation": Abilities.ID, "window": {}}, "pending_attack": {}, "awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice_values = [5]
	var quiet := Demise.begin(no_trigger, [100], roll_die)
	check(quiet.error.is_empty() and quiet.complete and no_trigger.last_deadly_demise.events.size() == 1 and not no_trigger.last_deadly_demise.events[0].triggered, "A Deadly Demise roll below 6 causes no mortal packets")
	var battle := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections())
	check(not battle.has("error"), "The admitted Ballistus materializes with current rules in a battle")
	if not battle.has("error"):
		battle.mission.stage = "battle"
		battle.awakened_dynasty.pending = []
		battle.phase = "shooting"
		battle.active = 1
		battle.unit_abilities.setup_players = [1, 2]
		var shooter := -1
		var target_model := -1
		for model: int in battle.units:
			if C.UnitAbilities.identity(battle.units[model]) == "ballistus-dreadnought" and battle.units[model].owner == 1: shooter = model
			elif battle.units[model].owner == 2 and target_model < 0: target_model = model
		if shooter >= 0 and target_model >= 0:
			var squad: int = battle.units[shooter].squad
			var target_squad: int = battle.units[target_model].squad
			battle.units[shooter].position = Vector2.ZERO
			for model: int in C.living(battle, target_squad): battle.units[model].position = Vector2(20, 0)
			var declaration := [{"model": shooter, "target": target_squad, "amount": 1, "weapon": "ballistus-lascannon", "profile": "standard"}]
			var attack := C.AttackPlan.prepare(battle, squad, false, declaration, true)
			check(attack.get("error", "").is_empty() and attack.batches[0].weapon.keywords.get("sustained-hits", 0) == 1, "Ballistus Strike adds Sustained Hits 1 in a legal ranged attack inside 24 inches")
			battle.units[shooter].wounds = 4
			attack = C.AttackPlan.prepare(battle, squad, false, declaration, true)
			check(attack.get("error", "").is_empty() and attack.batches[0].context.hit_modifier == -1, "Damaged 4 changes the actual attack plan's Hit modifier")
			var edge_of_24: float = 24.0 + float(battle.units[shooter].radius) + float(battle.units[target_model].radius)
			for model: int in C.living(battle, target_squad): battle.units[model].position = Vector2(edge_of_24, 0)
			battle.units[shooter].wounds = 5
			attack = C.AttackPlan.prepare(battle, squad, false, declaration, true)
			check(attack.get("error", "").is_empty() and attack.batches[0].weapon.keywords.get("sustained-hits", 0) == 1 and attack.batches[0].context.hit_modifier == 0, "Ballistus Strike includes the exact 24-inch boundary, while Damaged 4 stops at 5 wounds")
			for model: int in C.living(battle, target_squad): battle.units[model].position = Vector2(edge_of_24 + 0.01, 0)
			attack = C.AttackPlan.prepare(battle, squad, false, declaration, true)
			check(attack.get("error", "").is_empty() and not attack.batches[0].weapon.keywords.has("sustained-hits"), "Ballistus Strike ends beyond exactly 24 inches")
			battle.units[shooter].wounds = 5
			battle.units[shooter].position = Vector2.ZERO
			for model: int in C.living(battle, target_squad):
				battle.units[model].position = Vector2(5, 0)
				battle.units[model].wounds = 1
			var lethal_shot := [{"model": shooter, "target": target_squad, "amount": 1, "weapon": "ballistus-lascannon", "profile": "standard"}]
			dice_values = [4, 1, 3, 1, 1, 6, 1]
			var attack_result := C.resolve_attack_plan(battle, 1, shooter, lethal_shot, battle.revision, false, true, roll_die)
			if attack_result.get("error", "").is_empty() and not battle.pending_attack.is_empty():
				var allocation_error := C.allocate_damage(battle, 2, target_model, battle.revision, roll_die)
				check(allocation_error.is_empty(), "The defender resolves the Ballistus's lethal damage packet")
			check(attack_result.get("error", "").is_empty() and not battle.pending_deadly_demise.is_empty() and not battle.pending_attack.is_empty(), "Destroying the Ballistus opens Deadly Demise before finishing the pending attack")
			if not battle.pending_deadly_demise.is_empty():
				var mortal_choices := C.unit_choices(battle, 1)
				check(mortal_choices.size() == 1 and mortal_choices[0].action == "deadly-demise-allocate", "The nearby unit owner receives the Deadly Demise allocation decision")
				var demise_decision := PendingDecisions.current(battle, ["unit-actions"])
				var attack_frame := C.ResolutionFrames.current(battle)
				check(demise_decision.get("priority_player_id", -1) == 1 and demise_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", "") and attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended", "Deadly Demise decision is owned by the affected player and linked to the suspended attack")
				check(not PhaseCloseGate.close_request_error(battle, 1, battle.revision).is_empty(), "The pending Deadly Demise packet blocks Shooting close")
				var restored_battle: Dictionary = bytes_to_var(var_to_bytes(battle))
				var restored_demise_decision := PendingDecisions.current(restored_battle, ["unit-actions"])
				check(restored_demise_decision.get("decision_id", "") == demise_decision.get("decision_id", "") and restored_demise_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Deadly Demise decision and attack frame identities survive save/restore")
				battle = restored_battle
				if not mortal_choices.is_empty():
					var before_wrong_owner := var_to_bytes(battle)
					var wrong_owner_result := submit_unit_choice(battle, 2, mortal_choices[0], roll_die)
					check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(battle) == before_wrong_owner, "The opponent cannot submit or mutate the Deadly Demise allocation")
					var resolved := submit_unit_choice(battle, 1, mortal_choices[0], roll_die)
					check(str(resolved.get("error", "")).is_empty() and battle.pending_deadly_demise.is_empty() and battle.pending_attack.is_empty() and battle.units[shooter].wounds == 4, "Resolving the normalized mortal packet resumes and completes the attack transaction")
	print("Ballistus Dreadnought checks: %d failures" % failures)
	quit(1 if failures else 0)

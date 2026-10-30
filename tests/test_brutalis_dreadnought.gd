extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Reactions = preload("res://scripts/edition_11/core_reactions.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
var failures := 0
var dice: Array[int] = []

const EXPECTED_WEAPONS := {
	"bolt-rifles": {"range_inches": 24.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"twin-linked": true}},
	"twin-heavy-bolter": {"range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2}},
	"twin-icarus-ironhail-heavy-stubber": {"range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"anti-fly": 3, "rapid-fire": 3, "twin-linked": true}},
	"twin-multi-melta": {"range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"twin-linked": true, "melta": 3}},
	"brutalis-fists": {"range_inches": 0.0, "attacks": 6, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}},
	"brutalis-talons": {"range_inches": 0.0, "attacks": 8, "skill": 3, "strength": 10, "ap": -2, "damage": 2, "keywords": {"sustained-hits": 1, "twin-linked": true, "cleave": 2}}
}

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func submit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	var payload: Dictionary = selected
	if not decision.is_empty():
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Crushing Impact choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, roller)

func selection(copies: int = 1, category: String = "incursion") -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": category, "points_limit": 2000 if category == "strike_force" else 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "models": 1, "copies": copies}]}

func first_model(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and state.units[model].wounds > 0 and Abilities.identity(state.units[model]) == identity: return model
	return -1

func check_attack_profile(state: Dictionary, squad: int, model: int, target: int, melee: bool, weapon_id: String) -> void:
	var selected: Dictionary = Equipment.select(state, model, melee, weapon_id, "standard")
	check(selected.get("error", "").is_empty(), "The selected Brutalis model exposes %s to Equipment" % weapon_id)
	if not selected.get("error", "").is_empty(): return
	var expected: Dictionary = EXPECTED_WEAPONS[weapon_id]
	for field in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s matches source %s" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s matches its complete source keyword profile" % weapon_id)
	var previous_phase: String = str(state.phase)
	var previous_position: Vector2 = state.units[model].position
	if melee:
		state.phase = "fight"
		var target_models: Array[int] = C.living(state, target)
		if not target_models.is_empty(): state.units[model].position = state.units[target_models[0]].position
	var amount := int(selected.stats.attacks) if melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
	state.phase = previous_phase
	state.units[model].position = previous_position
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan retains the correct source for %s" % weapon_id)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("brutalis-dreadnought")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000136" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Brutalis cites the selected local Space Marines e11 export row")
	check(profile.points_by_models == {1: 160} and profile.third_plus_points_by_models == {1: 180} and profile.max_supported_copies == 3, "Brutalis first/second and third-plus prices and supported copy ceiling match source")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.damaged_threshold == 4 and profile.base_radius_inches == 45.0 / 25.4, "Brutalis characteristics, Damaged 4, and 90 mm base match extraction")
	check(profile.ranged.size() == 3 and profile.ranged[0].id == "bolt-rifles" and profile.ranged[1].id == "twin-heavy-bolter" and profile.ranged[2].id == "twin-icarus-ironhail-heavy-stubber" and profile.melee[0].id == "brutalis-fists", "Default ranged and melee loadout matches the exported sheet")
	check(profile.ranged[0].profiles.standard.keywords == {"twin-linked": true} and profile.ranged[1].profiles.standard.keywords == {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2} and profile.ranged[2].profiles.standard.keywords == {"anti-fly": 3, "rapid-fire": 3, "twin-linked": true}, "Default ranged traits match the extraction")
	check(profile.melee[0].profiles.standard.keywords == {"twin-linked": true}, "Brutalis Fists are Twin-linked")
	var talons := Profiles.brutalis_weapons(true, true)
	check(talons.ranged.size() == 2 and talons.ranged[0].id == "twin-multi-melta" and talons.ranged[1].id == "twin-icarus-ironhail-heavy-stubber" and talons.melee[0].id == "brutalis-talons", "Each paired replacement removes only its source weapons and installs exact alternatives")
	check(talons.melee[0].profiles.standard.keywords == {"sustained-hits": 1, "twin-linked": true, "cleave": 2} and talons.melee[0].profiles.standard.target_restricted_traits == {"sustained-hits": ["MONSTER", "VEHICLE"]}, "Brutalis Talons preserve Cleave and conditional Sustained Hits")
	check(Army.SPECS["brutalis-dreadnought"].current_reference and Army.SPECS["brutalis-dreadnought"].max_supported_copies == 3, "Brutalis admission is tied to the current-reference profile and explicit copy limit")
	var admitted := Army.admit(selection())
	var three := Army.admit(selection(3, "strike_force"))
	var four := Army.admit(selection(4, "strike_force"))
	var incursion_three := Army.admit(selection(3))
	check(admitted.error.is_empty() and admitted.total == 160 and three.error.is_empty() and three.total == 500 and not four.error.is_empty() and not incursion_three.error.is_empty(), "Local construction uses source copy tiers, Strike Force's third-copy price and each game's copy cap: %s / %d; %s / %d; %s; Incursion: %s" % [admitted.get("error", ""), admitted.get("total", -1), three.get("error", ""), three.get("total", -1), four.get("error", ""), incursion_three.get("error", "")])
	var wounded := {"unit_abilities": {"implementation": Abilities.ID}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "wounds": 5},
		101: {"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "wounds": 4},
		102: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 4}}}
	check(Abilities.damaged_attack_penalty(wounded, 100) == 0 and Abilities.damaged_attack_penalty(wounded, 101) == -1 and Abilities.damaged_attack_penalty(wounded, 102) == -1, "Damaged 4 applies at four remaining wounds to both admitted Dreadnought sheets")
	var selections := F.current_marine_selections()
	var selected_brutalis := false
	var selected_redemptor := false
	for entry: Dictionary in selections[1].entries:
		if entry.definition_id.ends_with(":intercessor-squad") and int(entry.models) == 5 and not selected_brutalis:
			entry.definition_id = "40kdc:11e:adeptus-astartes:brutalis-dreadnought"
			entry.models = 1
			selected_brutalis = true
		elif entry.definition_id.ends_with(":intercessor-squad") and int(entry.models) == 10 and not selected_redemptor:
			entry.definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
			entry.models = 1
			selected_redemptor = true
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections)
	check(not state.has("error"), "Brutalis and Redemptor both materialize from consolidated current Marine profiles: %s" % state.get("error", ""))
	if not state.has("error"):
		var brutalis := first_model(state, "brutalis-dreadnought", 1)
		var redemptor := first_model(state, "redemptor-dreadnought", 1)
		var target_model := first_model(state, "intercessor-squad", 2)
		check(brutalis >= 0 and redemptor >= 0 and target_model >= 0, "Materialized battle includes both Vehicle sheets and a target")
		if brutalis >= 0 and redemptor >= 0 and target_model >= 0:
			var squad: int = state.units[brutalis].squad
			var red_squad: int = state.units[redemptor].squad
			var enemy_squad: int = state.units[target_model].squad
			check(Reactions.crushing_unit(state, squad), "The source VEHICLE keyword makes the Brutalis eligible for Crushing Impact")
			var profile_state: Dictionary = state.duplicate(true)
			for model: int in profile_state.units:
				profile_state.units[model].position = Vector2(-25, -20) if profile_state.units[model].owner == 1 else Vector2(25, 20)
			profile_state.units[brutalis].position = Vector2.ZERO
			for enemy: int in C.living(profile_state, enemy_squad): profile_state.units[enemy].position = Vector2(8, 0)
			profile_state.phase = "shooting"
			profile_state.active = 1
			for weapon: Dictionary in profile_state.units[brutalis].ranged_weapons: check_attack_profile(profile_state, squad, brutalis, enemy_squad, false, str(weapon.id))
			for weapon: Dictionary in profile_state.units[brutalis].melee_weapons: check_attack_profile(profile_state, squad, brutalis, enemy_squad, true, str(weapon.id))
			state.awakened_dynasty.pending = []
			var loadout_options := UnitActions.choices(state, 1)
			var talon_choice: Dictionary = {}
			for option: Dictionary in loadout_options:
				if option.action == "brutalis-melee" and option.model == brutalis and option.value == "talons": talon_choice = option
			check(not talon_choice.is_empty(), "Deployment choices expose the Brutalis melee replacement")
			if not talon_choice.is_empty():
				var equipment_error := PublicUnitCommand.error(state, 1, talon_choice)
				check(equipment_error.is_empty() and state.units[brutalis].melee_weapons[0].id == "brutalis-talons" and state.units[brutalis].ranged_weapons.size() == 2, "Selecting Talons removes Bolt Rifles and Brutalis Fists while preserving other weapons")
			var melta_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "brutalis-ranged" and option.model == brutalis and option.value == "multi-melta": melta_choice = option
			if not melta_choice.is_empty():
				var melta_error := PublicUnitCommand.error(state, 1, melta_choice)
				check(melta_error.is_empty() and state.units[brutalis].ranged_weapons[0].id == "twin-multi-melta", "Selecting Twin Multi-melta replaces the Twin Heavy Bolter")
			for model: int in state.units:
				state.units[model].position = Vector2(-25, -20) if state.units[model].owner == 1 else Vector2(25, 20)
			state.units[brutalis].position = Vector2.ZERO
			for enemy: int in C.living(state, enemy_squad): state.units[enemy].position = Vector2(8, 0)
			state.phase = "shooting"
			state.active = 1
			for weapon: Dictionary in state.units[brutalis].ranged_weapons: check_attack_profile(state, squad, brutalis, enemy_squad, false, str(weapon.id))
			for weapon: Dictionary in state.units[brutalis].melee_weapons: check_attack_profile(state, squad, brutalis, enemy_squad, true, str(weapon.id))
			for model: int in state.units:
				if state.units[model].owner == 1: state.units[model].position = Vector2(-25, -20)
				else: state.units[model].position = Vector2(25, 20)
			state.units[brutalis].position = Vector2(6, 0)
			state.units[target_model].position = Vector2(12, 0)
			for enemy: int in C.living(state, enemy_squad): state.units[enemy].position = Vector2(12, 0)
			state.phase = "charge"
			state.active = 1
			state.turn = 1
			state.round = 1
			state.deployment.complete = true
			state.unit_abilities.setup_players = [1, 2]
			state.unit_abilities.battle_players = [1, 2]
			state.mission.stage = "battle"
			state.unit_abilities.window = {}
			state.cp[1] = 0
			dice = [6, 6]
			var charge := F.C.declare_charge(state, 1, brutalis, state.revision, roll_die)
			check(charge.error.is_empty() and not state.pending_charge.is_empty(), "Brutalis makes a legal charge roll from within 12 inches")
			if not state.pending_charge.is_empty():
				var target_error := F.C.select_charge_target(state, 1, target_model, state.revision)
				var move_error := F.C.begin_contact_move(state, 1, brutalis, "charge", state.revision)
				check(target_error.error.is_empty() and move_error.is_empty(), "Brutalis can select the enemy unit and begin post-charge placement")
				if move_error.is_empty():
					var stage_error := F.C.stage_contact_move(state, 1, brutalis, Vector2(9, 1), state.revision)
					var finish_error := F.C.finish_contact_move(state, 1, state.revision)
					check(stage_error.is_empty() and finish_error.is_empty() and state.squads[squad].charged and state.unit_abilities.window.get("kind", "") == Reactions.CRUSHING, "Successful Vehicle Charge opens the immediate Tank Shock window (stage=%s finish=%s charged=%s window=%s has=%s cost=%d target=%s err=%s)" % [stage_error, finish_error, str(state.squads[squad].charged), str(state.unit_abilities.window), str(Abilities.has(state, squad, Reactions.BRUTALIS_CHARGE)), Reactions.cost_of(state, 1, squad, Reactions.CRUSHING), str(Reactions.crushing_target(state, brutalis, enemy_squad)), Reactions.error(state, 1, squad, Reactions.CRUSHING, brutalis, false, enemy_squad)])
			if state.get("unit_abilities", {}).get("window", {}).get("kind", "") == Reactions.CRUSHING:
				var choices := F.C.unit_choices(state, 1)
				var tank_choice: Dictionary = {}
				for option: Dictionary in choices:
					if option.value == Reactions.CRUSHING and option.target == enemy_squad: tank_choice = option
				check(not tank_choice.is_empty() and Reactions.cost_of(state, 1, squad, Reactions.CRUSHING) == 0, "Brutalis Charge offers Tank Shock for 0 CP against an engaged enemy")
				var prior_normal_use_state: Dictionary = state.duplicate(true)
				prior_normal_use_state.stratagems.uses.append({"player": 1, "squad": red_squad, "stratagem": Reactions.CRUSHING, "phase_key": Reactions.phase_key(prior_normal_use_state), "turn": prior_normal_use_state.turn, "brutalis_charge": false})
				check(Reactions.error(prior_normal_use_state, 1, squad, Reactions.CRUSHING, brutalis, false, enemy_squad).is_empty() and Reactions.cost_of(prior_normal_use_state, 1, squad, Reactions.CRUSHING) == 0, "A prior ordinary Tank Shock use does not consume the Brutalis Charge exception")
				if not tank_choice.is_empty():
					dice = [6, 5, 5, 6, 6, 6, 6, 6, 6, 6]
					var tank_result := submit_choice(state, 1, tank_choice, roll_die)
					check(str(tank_result.get("error", "")).is_empty() and state.cp[1] == 0 and state.last_crushing_impact.rolls.size() == 10 and state.last_crushing_impact.mortal_wounds == 6, "Tank Shock rolls the selected model's Toughness in D6, caps mortal wounds at six and remains free at zero CP through the common command")
					var mortal_decision := PendingDecisions.current(state, ["unit-actions"])
					var charge_frame: Dictionary = F.C.ResolutionFrames.current(state)
					check(mortal_decision.get("priority_player_id", -1) == 2 and not mortal_decision.get("legal_options", []).is_empty() and mortal_decision.get("resume_frame_id", "") == charge_frame.get("frame_id", "") and charge_frame.get("status", "") == "suspended", "Tank Shock assigns its mortal allocation to the defender and retains the suspended Charge frame")
					check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "The charge owner's phase close remains blocked during Tank Shock allocation")
					var restored_state: Dictionary = bytes_to_var(var_to_bytes(state))
					var restored_mortal_decision := PendingDecisions.current(restored_state, ["unit-actions"])
					check(restored_mortal_decision.get("decision_id", "") == mortal_decision.get("decision_id", "") and restored_mortal_decision.get("resume_frame_id", "") == charge_frame.get("frame_id", ""), "Tank Shock allocation decision and Charge frame identities survive save/restore")
					state = restored_state
					var wrong_owner_allocations := F.C.unit_choices(state, 2)
					if not wrong_owner_allocations.is_empty():
						var before_wrong_owner := var_to_bytes(state)
						var wrong_owner_result := submit_choice(state, 1, wrong_owner_allocations[0], roll_die)
						check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The charge owner cannot submit or mutate the defender's Tank Shock allocation")
					var allocation_guard := 8
					var allocations_seen := 0
					while state.unit_abilities.window.get("kind", "") == Reactions.CRUSHING_MORTAL and allocation_guard > 0:
						allocation_guard -= 1
						var allocations := F.C.unit_choices(state, 2)
						if allocations.is_empty(): break
						allocations_seen += 1
						dice = [1]
						var allocation_result := submit_choice(state, 2, allocations[0], roll_die)
						check(str(allocation_result.get("error", "")).is_empty(), "Tank Shock mortal wounds resolve through the defender's normalized allocation window")
					check(allocations_seen == 6 and state.last_crushing_impact.remaining == 0 and allocation_guard > 0, "All Tank Shock mortal wounds finish allocation before another reaction")
				check(not Reactions.charge_completed(state, 1, squad), "Brutalis Charge cannot target its unit twice in the same phase")
				state.squads[red_squad].charged = true
				state.units[brutalis].position = Vector2(-10, 10)
				state.units[redemptor].position = Vector2(9, 1)
				for enemy: int in Reactions.living(state, enemy_squad): state.units[enemy].position = Vector2(12, 0)
				state.cp[1] = 1
				check(Reactions.charge_completed(state, 1, red_squad), "A prior free Brutalis use does not prevent a normal Vehicle Tank Shock use (window=%s cp=%d cost=%d target=%s has_brutalis=%s err=%s)" % [str(state.unit_abilities.window), state.cp[1], Reactions.cost_of(state, 1, red_squad, Reactions.CRUSHING), str(Reactions.crushing_target(state, redemptor, enemy_squad)), str(Abilities.has(state, red_squad, Reactions.BRUTALIS_CHARGE)), Reactions.error(state, 1, red_squad, Reactions.CRUSHING, redemptor, false, enemy_squad)])
				var normal_choices := Reactions.crushing_choices(state, 1)
				var normal_choice: Dictionary = {}
				for option: Dictionary in normal_choices:
					if option.value == Reactions.CRUSHING and option.source_squad == red_squad and option.target == enemy_squad: normal_choice = option
				check(not normal_choice.is_empty() and Reactions.cost_of(state, 1, red_squad, Reactions.CRUSHING) == 1, "Ordinary Tank Shock remains one CP after the Brutalis bonus use")
				if not normal_choice.is_empty():
					dice = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
					var before_wrong_normal_owner := var_to_bytes(state)
					var wrong_normal_owner := submit_choice(state, 2, normal_choice, roll_die)
					check(not str(wrong_normal_owner.get("error", "")).is_empty() and before_wrong_normal_owner == var_to_bytes(state), "The other player cannot submit ordinary Tank Shock")
					var normal_result := submit_choice(state, 1, normal_choice, roll_die)
					check(str(normal_result.get("error", "")).is_empty() and state.cp[1] == 0 and state.last_crushing_impact.cp_cost == 1 and not state.stratagems.uses.back().brutalis_charge, "Ordinary Tank Shock pays its base CP cost and records distinct use through the match command")
	if failures == 0: print("Brutalis Dreadnought checks: 0 failures")
	else: push_error("Brutalis Dreadnought checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

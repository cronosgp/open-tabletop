extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Reactions = preload("res://scripts/edition_11/core_reactions.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const F = preload("res://tests/all_units_fixture.gd")
var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func selection(copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "models": 1, "copies": copies}]}

func first_model(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and state.units[model].wounds > 0 and Abilities.identity(state.units[model]) == identity: return model
	return -1

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
	var three := Army.admit(selection(3))
	var four := Army.admit(selection(4))
	check(admitted.error.is_empty() and admitted.total == 160 and three.error.is_empty() and three.total == 500 and not four.error.is_empty(), "Local construction uses exact first/second and third-plus prices and rejects a fourth copy: %s / %d; %s / %d; %s" % [admitted.get("error", ""), admitted.get("total", -1), three.get("error", ""), three.get("total", -1), four.get("error", "")])
	var wounded := {"unit_abilities": {"implementation": Abilities.ID}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "wounds": 5},
		101: {"definition_id": "40kdc:11e:adeptus-astartes:brutalis-dreadnought", "wounds": 4},
		102: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 4}}}
	check(Abilities.damaged_attack_penalty(wounded, 100) == 0 and Abilities.damaged_attack_penalty(wounded, 101) == -1 and Abilities.damaged_attack_penalty(wounded, 102) == -1, "Damaged 4 applies at four remaining wounds to both admitted Dreadnought sheets")
	var selections := F.selections()
	for entry: Dictionary in selections[1].entries:
		if entry.definition_id.ends_with(":assault-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:brutalis-dreadnought"
			entry.models = 1
		elif entry.definition_id.ends_with(":heavy-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
			entry.models = 1
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections)
	check(not state.has("error"), "Brutalis and Redemptor both materialize from consolidated current Marine profiles: %s" % state.get("error", ""))
	if not state.has("error"):
		var brutalis := first_model(state, "brutalis-dreadnought", 1)
		var redemptor := first_model(state, "redemptor-dreadnought", 1)
		var target_model := first_model(state, "necron-warriors", 2)
		check(brutalis >= 0 and redemptor >= 0 and target_model >= 0, "Materialized battle includes both Vehicle sheets and a target")
		if brutalis >= 0 and redemptor >= 0 and target_model >= 0:
			var squad: int = state.units[brutalis].squad
			var red_squad: int = state.units[redemptor].squad
			var enemy_squad: int = state.units[target_model].squad
			state.awakened_dynasty.pending = []
			var loadout_options := UnitActions.choices(state, 1)
			var talon_choice: Dictionary = {}
			for option: Dictionary in loadout_options:
				if option.action == "brutalis-melee" and option.model == brutalis and option.value == "talons": talon_choice = option
			check(not talon_choice.is_empty(), "Deployment choices expose the Brutalis melee replacement")
			if not talon_choice.is_empty():
				var equipment_error := F.C.unit_action(state, 1, talon_choice, Vector2.ZERO, state.revision)
				check(equipment_error.is_empty() and state.units[brutalis].melee_weapons[0].id == "brutalis-talons" and state.units[brutalis].ranged_weapons.size() == 2, "Selecting Talons removes Bolt Rifles and Brutalis Fists while preserving other weapons")
			var melta_choice: Dictionary = {}
			for option: Dictionary in UnitActions.choices(state, 1):
				if option.action == "brutalis-ranged" and option.model == brutalis and option.value == "multi-melta": melta_choice = option
			if not melta_choice.is_empty():
				var melta_error := F.C.unit_action(state, 1, melta_choice, Vector2.ZERO, state.revision)
				check(melta_error.is_empty() and state.units[brutalis].ranged_weapons[0].id == "twin-multi-melta", "Selecting Twin Multi-melta replaces the Twin Heavy Bolter")
			for model: int in state.units:
				if state.units[model].owner == 1: state.units[model].position = Vector2(-25, -20)
				else: state.units[model].position = Vector2(25, 20)
			state.units[brutalis].position = Vector2(6, 0)
			state.units[target_model].position = Vector2(12, 0)
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
				if not tank_choice.is_empty():
					dice = [6, 5, 5, 6, 6, 6, 6, 6, 6, 6]
					var tank_error := F.C.unit_action(state, 1, tank_choice, Vector2.ZERO, state.revision, roll_die)
					check(tank_error.is_empty() and state.cp[1] == 0 and state.last_crushing_impact.rolls.size() == 10 and state.last_crushing_impact.mortal_wounds == 6, "Tank Shock rolls the selected model's Toughness in D6, caps mortal wounds at six and remains free at zero CP")
					var allocation_guard := 8
					var allocations_seen := 0
					while state.unit_abilities.window.get("kind", "") == Reactions.CRUSHING_MORTAL and allocation_guard > 0:
						allocation_guard -= 1
						var allocations := F.C.unit_choices(state, 2)
						if allocations.is_empty(): break
						allocations_seen += 1
						dice = [1]
						var allocation_error := F.C.unit_action(state, 2, allocations[0], Vector2.ZERO, state.revision, roll_die)
						check(allocation_error.is_empty(), "Tank Shock mortal wounds resolve through the defender's ordinary allocation window")
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
					var normal_error := F.C.unit_action(state, 1, normal_choice, Vector2.ZERO, state.revision, roll_die)
					check(normal_error.is_empty() and state.cp[1] == 0 and state.last_crushing_impact.cp_cost == 1 and not state.stratagems.uses.back().brutalis_charge, "Ordinary Tank Shock pays its base CP cost and records distinct use")
	if failures == 0: print("Brutalis Dreadnought checks: 0 failures")
	else: push_error("Brutalis Dreadnought checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

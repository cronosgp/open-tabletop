extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func act(state: Dictionary, player: int, action: String, target: int = -999, point: Vector2 = Vector2.ZERO) -> String:
	var available: Array = F.C.unit_choices(state, player)
	for option: Dictionary in available:
		if option.action == action and (target == -999 or int(option.target) == target):
			return F.C.unit_action(state, player, option, point, state.revision)
	return "Missing choice: " + action

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("wardens-of-ultramar")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000004188" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Wardens point to the pinned Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {6: 115} and profile.get("models") == 6 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Six fixed 40 mm models cost 115 points")
	var rows: Array[Dictionary] = []
	for index in range(6): rows.append(Profiles.wardens_model_loadout(index))
	var expected_stats := [
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
		{"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		{"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
	]
	for index in range(6): check(rows[index].stats == expected_stats[index], "Model %d preserves its source characteristics" % index)
	check(rows[1].ranged[0].profiles["focused-fire"].attacks == 1 and rows[1].ranged[0].profiles["focused-fire"].strength == 6 and rows[1].ranged[0].profiles.saturation.attacks == 2 and rows[1].ranged[0].profiles.saturation.strength == 5, "Gadriel's Bolt Rifle has both exported profiles")
	check(rows[2].ranged[0].id == "astropathic-blast" and rows[2].melee[0].id == "force-stave" and rows[2].ranged[0].profiles.standard.keywords.psychic, "Dainal has his source-listed psychic weapons")
	check(rows[3].stats.invulnerable_target == 5 and rows[0].melee[0].id == "power-weapon" and rows[4].melee[0].id == "ultramarian-combat-weapons" and rows[5].melee[0].profiles.standard.keywords.precision, "Model-specific defenses and melee weapons stay with their owners")
	check(not profile.keywords.has("CHARACTER") and "EPIC HERO" in profile.keywords, "Source keywords do not invent CHARACTER for this datasheet")

	var state := F.fresh()
	check(not state.has("error"), "Fixture prepares for a local materialization check")
	if state.has("error"):
		quit(1)
		return
	var squad := 99
	while state.squads.has(squad): squad += 2
	var source_group: Dictionary = state.squads[1].duplicate(true)
	source_group.name = "Wardens of Ultramar"
	source_group.owner = 1
	source_group.starting_strength = 6
	source_group.training_cost = 115
	source_group.stats = profile.stats.duplicate(true)
	state.squads[squad] = source_group
	for index in range(6):
		var unit: Dictionary = state.units[100].duplicate(true)
		unit.squad = squad
		unit.owner = 1
		unit.definition_id = "40kdc:11e:adeptus-astartes:wardens-of-ultramar"
		unit.wardens_model = index
		unit.sergeant = false
		unit.keywords = profile.keywords.duplicate()
		state.units[100000 + index] = unit
	check(Prepared._current_loadouts(state).is_empty(), "Wardens materialize through the shared Space Marine loadout pipeline")
	check(Abilities.has(state, squad, "support") and Abilities.has(state, squad, "combat-doctrines") and Abilities.has(state, squad, "raise-the-banner"), "Implemented Support, Combat Doctrines and Raise the Banner are active")
	for index in range(6):
		var unit: Dictionary = state.units[100000 + index]
		check(unit.max_wounds == expected_stats[index].wounds and unit.objective_control == expected_stats[index].objective_control and unit.defense.toughness == expected_stats[index].toughness and unit.defense.save_target == expected_stats[index].save_target and unit.defense.invulnerable_target == expected_stats[index].invulnerable_target, "Materialized model %d retains its personal defense and OC" % index)
	var target := Groups.defender(state, squad)
	check(target.get("error", "") == "" and target.toughness == 5 and target.mixed, "Mixed Wardens defense resolves with T5 and model-specific allocation groups")
	check(Catalog.SPECS.has("wardens-of-ultramar") and Catalog.SPECS["wardens-of-ultramar"].get("max_supported_copies", 0) == 1, "Locally supported Wardens enter construction with the one-copy Epic Hero cap")
	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 1}]})
	var two_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 2}]})
	check(one_copy.get("error", "").is_empty() and one_copy.get("total", -1) == 115 and not two_copies.get("error", "").is_empty(), "Wardens admission uses Wahapedia points and rejects a second copy")
	check("intercessor-squad" in Supports.BODYGUARDS["wardens-of-ultramar"] and Supports.matching_error([{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "copies": 1}, {"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "copies": 1}]).is_empty() and not Supports.matching_error([{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "copies": 1}, {"definition_id": "40kdc:11e:necrons:necron-warriors", "copies": 1}]).is_empty(), "Support assignments accept only source-listed bodyguards")
	var selected_lists := {1: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:wardens-of-ultramar", "models": 6, "copies": 1}]}, 2: F.selections()[2]}
	var admitted_state := Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selected_lists)
	check(not admitted_state.has("error"), "The actual prepared-training path admits and materializes six Wardens")
	if not admitted_state.has("error"):
		var admitted_squad := -1
		for candidate: int in admitted_state.squads:
			if int(admitted_state.squads[candidate].owner) == 1 and str(admitted_state.squads[candidate].get("name", "")).begins_with("Wardens of Ultramar"):
				admitted_squad = candidate
				break
		check(admitted_squad >= 0 and F.C.UnitAbilities.has(admitted_state, admitted_squad, "strategium-command"), "Admitted Wardens expose Strategium Command in runtime ability state")
	state.phase = "pre_battle"
	state.deployment.complete = true
	state.first_player = 1
	for index in range(6): state.units[100000 + index].on_battlefield = true
	ScoutMoves.begin(state)
	check(state.unit_abilities.window.get("kind", "") == "strategium-command" and ScoutMoves.actor(state) == 1, "Strategium Command resolves after both armies deploy and before Scouts")
	var selected := act(state, 1, "strategium-select", squad)
	check(selected.is_empty(), "Strategium Command can select an Adeptus Astartes unit")
	check(act(state, 1, "strategium-reserve", squad).is_empty(), "Strategium Command can place a selected unit into Strategic Reserves")
	check(state.unit_abilities.reserves.get(squad, {}).get("source", "") == "strategium-command" and state.unit_abilities.reserves[squad].get("bypass_limit", false) and not state.units[100000].on_battlefield, "Strategium reserve placement records its reserve-limit exception and removes the unit")
	var additional_targets: Array[int] = []
	for candidate: int in state.squads:
		if candidate != squad and int(state.squads[candidate].owner) == 1 and ScoutMoves._strategium_target(state, candidate): additional_targets.append(candidate)
	additional_targets.sort()
	for index in range(2):
		var candidate := additional_targets[index]
		check(act(state, 1, "strategium-select", candidate).is_empty() and act(state, 1, "strategium-reserve", candidate).is_empty(), "Strategium Command can resolve another distinct unit")
	check(int(state.unit_abilities.strategium_count.get(1, 0)) == 3 and state.unit_abilities.window.get("kind", "") != "strategium-command", "Strategium Command stops after three units and proceeds to the next pre-battle step")
	print("Wardens local source and materialization profile: %d failures" % failures)
	quit(1 if failures else 0)

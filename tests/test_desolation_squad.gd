extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Plan = preload("res://scripts/edition_11/attack_plan.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const F = preload("res://tests/all_units_fixture.gd")
var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 6

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("desolation-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002270" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Desolation identity follows the selected local export revision")
	check(profile.points_by_models == {5: 140} and profile.third_plus_points_by_models == {5: 150} and profile.max_supported_copies == 3 and profile.wargear_costs == {"vengor-launcher": 5}, "Desolation fixed size, copy price and Sergeant Vengor cost match the local export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and profile.base_radius_inches == 16.0 / 25.4, "Desolation characteristics and 32mm base match the local export")
	check(profile.ranged.size() == 3 and profile.ranged[0].id == "bolt-pistol" and profile.ranged[1].id == "castellan-launcher" and profile.ranged[2].profiles.standard.keywords == {"blast": 1, "heavy": true} and profile.melee[0].profiles.standard.attacks == 3, "Default equipment and Ceramite Fists are present")
	var vengor: Dictionary = Profiles.desolation_weapons("vengor")[2].profiles.standard
	var krak: Dictionary = Profiles.desolation_weapons("superkrak")[2].profiles.standard
	check(vengor.keywords == {"blast": 1, "indirect-fire": true, "heavy": true} and vengor.strength == 7 and vengor.damage == 2 and krak.strength == 10 and krak.damage == "D3+3", "Vengor and Superkrak retain their distinct extracted profiles")
	check(Army.SPECS["desolation-squad"].current_reference and Abilities.RULES["desolation-squad"] == ["targeter-optics"], "The sheet and Targeter Optics are registered for local admission")
	var selection := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:desolation-squad", "models": 5, "copies": 1}]}
	var admitted := Army.admit(selection)
	var three_selection := selection.duplicate(true)
	three_selection.entries[0].copies = 3
	var four_selection := selection.duplicate(true)
	four_selection.entries[0].copies = 4
	var three := Army.admit(three_selection)
	var four := Army.admit(four_selection)
	check(admitted.error.is_empty() and admitted.total == 140 and three.error.is_empty() and three.total == 430 and not four.error.is_empty(), "Local construction applies 140/150-point copy prices and rejects more than three squads")
	var selections := F.selections()
	for index in range(selections[1].entries.size()):
		if selections[1].entries[index].definition_id.ends_with(":assault-intercessor-squad"):
			selections[1].entries[index].definition_id = "40kdc:11e:adeptus-astartes:desolation-squad"
			break
	var state := F.P.initial_state({"unit_abilities": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Desolation materializes from the consolidated local catalog: %s" % state.get("error", ""))
	if state.has("error"):
		quit(1)
		return
	var squad := -1
	var sergeant := -1
	var members: Array[int] = []
	for model: int in state.units:
		if Abilities.identity(state.units[model]) != "desolation-squad": continue
		squad = state.units[model].squad
		members.append(model)
		if state.units[model].get("sergeant", false): sergeant = model
	check(members.size() == 5 and sergeant >= 0 and state.squads[squad].training_cost == 140, "The fixed five-model unit and Sergeant role materialize")
	var option: Dictionary = {}
	for choice: Dictionary in F.C.UnitActions.choices(state, 1):
		if choice.action == "desolation-rocket" and choice.model == sergeant and choice.value == "vengor": option = choice
	check(not option.is_empty(), "Only the Sergeant's preparation choices offer the Vengor Launcher")
	if not option.is_empty():
		var error := PublicUnitCommand.error(state, 1, option)
		check(error.is_empty() and state.squads[squad].training_cost == 145 and state.units[sergeant].ranged_weapons[2].profiles.standard.keywords.get("indirect-fire", false), "Selecting Vengor updates equipment and adds five points: " + error)
	for model: int in members:
		if model != sergeant: check(state.units[model].desolation_rocket == "superfrag", "Non-Sergeant retains the default Superfrag profile")
	var target := -1
	for model: int in state.units:
		if state.units[model].owner == 2 and Abilities.identity(state.units[model]) == "necron-warriors":
			target = model
			break
	var target_squad: int = state.units[target].squad
	for model: int in state.units:
		if state.units[model].owner == 1 and state.units[model].squad != squad: state.units[model].on_battlefield = false
	for model: int in members: state.units[model].position = Vector2(-5, 0)
	for model: int in F.C.living(state, target_squad): state.units[model].position = Vector2(5, 0)
	var wall := Rect2(-0.5, -4, 1, 8)
	state.terrain = {"id": "desolation-test-wall", "areas": [{"name": "Test wall", "category": "dense", "bounds": wall, "features": [{"bounds": wall, "height": 4.0, "blocks_end": true}]}]}
	state.phase = "shooting"
	state.active = 1
	var declaration := [{"model": sergeant, "target": target_squad, "amount": 1, "weapon": "rocket-launcher", "profile": "standard"}]
	check(Plan.legal_targets(state, sergeant, false, "rocket-launcher", "standard").is_empty(), "Indirect Fire cannot bypass visibility without selecting Indirect Shooting")
	check(target_squad in Plan.legal_targets(state, sergeant, false, "rocket-launcher", "standard", true), "Indirect Shooting permits the Vengor to target an unseen unit")
	var plan := Plan.prepare(state, squad, false, declaration, false, -1, true)
	check(plan.error.is_empty() and plan.batches[0].context.benefit_of_cover and plan.batches[0].context.hit_reroll == "none" and plan.batches[0].context.indirect_hit_cap == 5, "Indirect attack grants cover, forbids hit re-rolls and fails natural 1–5: " + plan.get("error", ""))
	var invalid_reroll := F.C.Attacks._validate(vengor, Plan.defender(state, target_squad), {"weapon_count": 1, "target_model_count": F.C.living(state, target_squad).size(), "target_engaged": false, "heavy_eligible": false, "benefit_of_cover": true, "indirect_fire": true, "indirect_hit_cap": 5, "hit_reroll": "ones"})
	check(invalid_reroll.contains("cannot re-roll hit"), "The attack validator rejects hit re-rolls even if another caller supplies them")
	state.squads[squad].shot = false
	dice = [4, 5, 1, 1, 6, 1, 6, 6, 6, 6]
	var attack := F.C.resolve_attack_plan(state, 1, sergeant, declaration, state.revision, false, false, roll_die, -1, true)
	check(attack.error.is_empty() and state.last_attack.pools[0].hits == 1 and state.squads[squad].indirect_shooting_block == "%d:shooting" % state.turn and Actions.eligibility_error(state, squad).contains("Indirect Shooting"), "Natural 1–5 fail for Vengor, and Indirect Shooting blocks actions that phase; hits=%d block=%s action=%s error=%s" % [int(state.last_attack.get("pools", [{}])[0].get("hits", -1)), str(state.squads[squad].get("indirect_shooting_block", "")), Actions.eligibility_error(state, squad), attack.get("error", "")])
	state.terrain = {"id": "desolation-open", "areas": []}
	state.squads[squad].shot = false
	state.squads[squad].indirect_shooting_block = ""
	state.units[target].position = Vector2(-9, 4.7)
	for model: int in members: state.units[model].position = Vector2(-5, 0)
	var sight := F.C.Terrain.targeting(state, sergeant, target_squad)
	var visible_plan := Plan.prepare(state, squad, false, declaration, false, -1, true)
	check(sight.visible and Abilities.has(state, squad, "targeter-optics") and visible_plan.error.is_empty() and not visible_plan.batches[0].context.benefit_of_cover and visible_plan.batches[0].context.indirect_hit_cap == 3, "Visible Targeter Optics ignores cover; stationary Indirect Shooting uses the 1–3 failure band")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._start_objectives()
	game._dismiss_home(1)
	game.state = state.duplicate(true)
	game.combat_enabled = true
	game._spawn_pieces()
	game.selected = sergeant
	game.attack_draft = {"squad": squad, "attacker": sergeant, "melee": false, "revision": game.state.revision, "pack_hash": game.state.pack_hash, "entries": declaration, "indirect_shooting": true}
	game._refresh()
	check(game.indirect_choice.visible and game.indirect_choice.button_pressed and "unmodified 1–5 fail" in game.plan_summary.text and "Targeter Optics" in game.plan_summary.text, "Attack-plan UI shows conditional Indirect Shooting and visible Targeter Optics effects without relying on the tooltip")
	game.queue_free()
	print("Desolation Squad checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

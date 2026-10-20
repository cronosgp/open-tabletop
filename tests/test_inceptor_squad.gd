extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(inceptor_models: int = 3) -> Dictionary:
	var result := F.selections()
	result[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": inceptor_models, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	return result

func find(state: Dictionary) -> Dictionary:
	var result := {"squad": -1, "models": [], "enemy": -1, "enemy_models": []}
	for id: int in state.units:
		var unit: Dictionary = state.units[id]
		match C.UnitAbilities.identity(unit):
			"inceptor-squad":
				result.squad = unit.squad
				result.models.append(id)
			"necron-warriors":
				result.enemy = unit.squad
				result.enemy_models.append(id)
	return result

func option(state: Dictionary, player: int, action: String, target: int = -999, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and (target == -999 or item.target == target) and (value.is_empty() or item.value == value): return item
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("inceptor-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000125" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Inceptor Squad links to the local shared-book Wahapedia datasheet")
	check(profile.points_by_models == {3: 130, 6: 260} and profile.third_plus_points_by_models == {3: 150, 6: 280} and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "Supported source sizes, first/second and third+ costs, and 40 mm base match the export")
	check(profile.stats == {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and "FLY" in profile.keywords and "JUMP PACK" in profile.keywords and "GRAVIS" in profile.keywords, "Inceptor characteristics and keywords match the export")
	var assault: Dictionary = profile.ranged[0].profiles.standard
	var plasma_standard: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.standard
	var plasma_supercharge: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.supercharge
	check(assault.name == "Assault Bolters" and assault.keywords == {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true}, "Default Assault Bolters preserve all extracted weapon traits")
	check(plasma_standard.strength == 7 and plasma_standard.ap == -2 and plasma_standard.damage == 2 and plasma_supercharge.strength == 8 and plasma_supercharge.ap == -3 and plasma_supercharge.damage == 3 and plasma_supercharge.keywords.hazardous, "Both Plasma Exterminator profiles match the local export")
	check(Army.SPECS["inceptor-squad"].get("current_reference", false), "Inceptor is admitted as a current local profile")
	var catalog := Catalog.new()
	root.add_child(catalog)
	catalog.select_edition("11e")
	check(catalog.contains("40kdc:11e:adeptus-astartes:inceptor-squad"), "Consolidated local construction catalog exposes the checked Inceptor profile")
	catalog.queue_free()
	await process_frame
	check(RosterValidation.POINTS["inceptor-squad"].sizes == {3: 130, 6: 260} and RosterValidation.POINTS["inceptor-squad"].third_plus_sizes == {3: 150, 6: 280}, "Roster checks resolve source Inceptor costs")
	var invalid := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 5, "copies": 1}]})
	check(not invalid.error.is_empty(), "Unsupported Inceptor squad size is rejected")
	var repeated := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 3, "copies": 3}]})
	check(repeated.error.is_empty() and repeated.total == 410, "Third Inceptor unit uses its source 150-point cost")
	var six := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 6, "copies": 1}]})
	check(six.error.is_empty() and six.total == 260, "The source six-model Inceptor composition is admitted at 260 points")
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Inceptor Squad and enemy materialize with current profiles")
	if state.has("error"):
		print("Inceptor Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find(state)
	check(found.models.size() == 3 and C.UnitAbilities.every_model_has(state, found.squad, "deep-strike") and C.UnitAbilities.has(state, found.squad, "meteoric-descent") and C.UnitAbilities.has(state, found.squad, "parabolic-jetleap"), "All Inceptors carry Deep Strike and both datasheet abilities")
	for model: int in found.models:
		check(state.units[model].ranged_weapons[0].id == "assault-bolters" and state.units[model].melee_weapons[0].id == "ceramite-fists", "Every model starts with the source default loadout")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var plasma_choice := option(state, 1, "inceptor-loadout", found.squad, "plasma")
	check(not plasma_choice.is_empty(), "Setup presents the source all-model Plasma replacement")
	if not plasma_choice.is_empty():
		check(C.unit_action(state, 1, plasma_choice, Vector2.ZERO, state.revision).is_empty(), "The source Plasma replacement is accepted")
		for model: int in found.models:
			if model == plasma_choice.model: check(state.units[model].ranged_weapons[0].id == "plasma-exterminators" and state.units[model].ranged_weapons[0].profiles.supercharge.keywords.hazardous, "Selected model uses Plasma Exterminators and preserves Hazardous")
			else: check(state.units[model].ranged_weapons[0].id == "assault-bolters", "Other models retain their Assault Bolters, allowing the source's individual replacement choice")
	state.phase = "shooting"
	state.active = 1
	state.squads[found.squad].move_type = "ingress"
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 1 and C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, true) == 0, "Meteoric Descent grants ranged +1 Hit only after an Ingress move this turn")
	state.phase = "fight"
	state.active = 2
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 1, "Meteoric Descent also applies to ranged attacks made out of phase during the Ingress turn")
	state.squads[found.squad].move_type = "normal"
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 0, "Meteoric Descent does not remain after a non-Ingress move")
	state.phase = "fight"
	state.active = 2
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	for model: int in found.models: state.units[model].position = Vector2(-12, float((model % 3) - 1))
	for model: int in found.enemy_models: state.units[model].position = Vector2(14, float((model % 5) - 2))
	state.units[found.enemy_models[0]].position = state.units[found.models[0]].position + Vector2(0.1, 0.0)
	check(C.UnitActions.parabolic_jetleap_squads(state, 1).is_empty(), "Engaged Inceptors cannot use Parabolic Jetleap")
	state.units[found.enemy_models[0]].position = Vector2(14, -2)
	state.unit_abilities.end_done = ""
	check(C.UnitActions.open_end(state) and state.unit_abilities.window.kind == "end" and 1 in state.unit_abilities.window.owners, "Opponent Fight end opens the Inceptor owner's Parabolic Jetleap choice")
	var jetleap := option(state, 1, "parabolic-jetleap", found.squad)
	check(not jetleap.is_empty(), "Unengaged Inceptors can choose Parabolic Jetleap")
	if not jetleap.is_empty():
		check(C.unit_action(state, 1, jetleap, Vector2.ZERO, state.revision).is_empty() and state.unit_abilities.reserves.has(found.squad), "Parabolic Jetleap places the squad in Strategic Reserves")
		for model: int in found.models: check(not state.units[model].on_battlefield, "Every Inceptor leaves the battlefield together")
		var pass_end := option(state, 1, "pass")
		if not pass_end.is_empty(): C.unit_action(state, 1, pass_end, Vector2.ZERO, state.revision)
		state.phase = "movement"
		state.active = 1
		state.round = 2
		state.unit_abilities.window = {}
		check(not option(state, 1, "ingress", found.squad).is_empty(), "Reserved Inceptors may use the shared Deep Strike Ingress flow on their turn")
	print("Inceptor Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

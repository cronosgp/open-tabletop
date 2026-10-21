extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, identity: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func models(state: Dictionary, squad_id: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in C.living(state, squad_id): result.append(model)
	return result

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("chaplain-on-bike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000094" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Chaplain on Bike cites the pinned local Wahapedia e11 datasheet")
	check(profile.points_by_models == {1: 75} and profile.get("third_plus_points_by_models", {}) == {1: 75} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 45.0 / 25.4), "Chaplain on Bike composition, points and oval base proxy are represented")
	check(profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 2, "invulnerable_target": 4}, "Chaplain on Bike characteristics match the local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["absolvor-bolt-pistol", "twin-bolt-rifle"] and profile.melee[0].id == "crozius-arcanum", "Chaplain on Bike fixed loadout matches the local rows")
	check(profile.ranged[1].profiles.standard.keywords == {"twin-linked": true, "rapid-fire": 2} and profile.melee[0].profiles.standard.keywords == {"cleave": 1}, "Twin-linked, Rapid Fire 2 and Cleave are represented")
	check(Catalog.SPECS.has("chaplain-on-bike") and Roster.POINTS["chaplain-on-bike"].sizes == {1: 75}, "Chaplain on Bike enters local roster admission at the extracted cost")
	var lists := F.selections()
	lists[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:chaplain-on-bike", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	lists[2].entries = [
		{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1},
		{"definition_id": "40kdc:11e:necrons:immortals", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:necrons:overlord", "models": 1, "copies": 1}]
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Chaplain on Bike and Outrider Squad materialize from the local catalog")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.phase = "command"
	if C.Doctrines.needs_choice(state): C.select_combat_doctrine(state, 1, "none", state.revision)
	state.phase = "deployment"
	var chaplain := squad(state, "chaplain-on-bike")
	var outriders := squad(state, "outrider-squad")
	check(chaplain > 0 and outriders > 0 and C.UnitActions.attachment_allowed(state, models(state, chaplain)[0], outriders), "Chaplain on Bike may lead Outrider Squad")
	var source_model: int = models(state, chaplain)[0]
	C.UnitActions.attach(state, source_model, outriders)
	check(state.units[source_model].squad == outriders and state.units[source_model].attachment_role == "leader" and state.squads[outriders].get("attached", false), "Chaplain on Bike attachment to Outriders applies")
	check(not C.UnitActions.attachment_allowed(state, source_model, squad(state, "intercessor-squad")), "Chaplain on Bike is not admitted to infantry bodyguards")
	var rider_models := models(state, outriders)
	var rider_model := rider_models[0]
	var target_a := squad(state, "necron-warriors")
	var target_b := squad(state, "immortals")
	var index := 0
	for model: int in C.living(state, outriders):
		state.units[model].position = Vector2(-5, -3 + index * 3)
		index += 1
	index = 0
	for model: int in C.living(state, target_a):
		state.units[model].position = Vector2(6, -15 + index * 3)
		index += 1
	index = 0
	for model: int in C.living(state, target_b):
		state.units[model].position = Vector2(6, 10 + index * 3)
		index += 1
	state.units[models(state, squad(state, "overlord"))[0]].position = Vector2(12, 25)
	state.phase = "shooting"
	state.turn = 1
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.used.erase("catechism-fire:%d" % outriders)
	state.units[source_model].on_battlefield = false
	check(C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire").is_empty(), "Off-board Chaplain cannot offer Catechism of Fire")
	state.units[source_model].on_battlefield = true
	var targets: Array = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire")
	check(targets.any(func(choice: Dictionary) -> bool: return choice.target == target_a) and targets.any(func(choice: Dictionary) -> bool: return choice.target == target_b), "Catechism offers each visible enemy unit before shooting")
	if not targets.any(func(choice: Dictionary) -> bool: return choice.target == target_a) or not targets.any(func(choice: Dictionary) -> bool: return choice.target == target_b):
		print("Catechism targets: ", targets, " Visible A/B: ", C.Terrain.targeting(state, rider_model, target_a), " / ", C.Terrain.targeting(state, rider_model, target_b))
		quit(1)
		return
	var selected: Dictionary = targets.filter(func(choice: Dictionary) -> bool: return choice.target == target_a)[0]
	check(C.unit_action(state, 1, selected, Vector2.ZERO, state.revision).is_empty(), "Catechism target selection applies")
	check(C.UnitAbilities.has(state, outriders, "catechism-of-fire") and C.UnitAbilities.has(state, outriders, "litany-of-hate"), "Attached unit receives Catechism and Litany while the Chaplain lives")
	var twin_bolt_rifle: Dictionary = Profiles.profile("outrider-squad").ranged[1].profiles.standard
	var target_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_a, twin_bolt_rifle, false)
	var other_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_b, twin_bolt_rifle, false)
	var melee_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_a, Profiles.profile("outrider-squad").melee[0].profiles.standard, true)
	check(target_effect.keywords.get("devastating-wounds", false), "Catechism grants Devastating Wounds against the selected target")
	check(not other_effect.keywords.get("devastating-wounds", false) and not melee_effect.keywords.get("devastating-wounds", false), "Catechism does not affect other targets or melee attacks")
	check(melee_effect.keywords.get("lance", false), "Litany of Hate grants Lance to attached Outrider melee attacks")
	check(C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire").is_empty(), "Catechism target cannot be changed after selection during that phase")
	print("Current Chaplain on Bike checks: %d failures" % failures)
	quit(1 if failures else 0)

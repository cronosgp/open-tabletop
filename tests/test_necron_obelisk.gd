extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Obelisk = preload("res://scripts/edition_11/necron_obelisk.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitAbilities = Abilities
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const OBELISK_ID := "40kdc:11e:necrons:obelisk"
const MARINE_ID := "40kdc:11e:adeptus-astartes:inceptor-squad"

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

func find_choice(state: Dictionary, player: int, action: String, target: int = -1) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func run() -> void:
	var profile := Profiles.profile("obelisk")
	var sphere: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000000557" and profile.get("points_by_models", {}) == {1: 280} and profile.get("second_plus_points_by_models", {}) == {1: 310} and profile.get("base_size_source_mm", 0) == 92, "Obelisk retains App v1.2 identity, first/second-plus prices and labelled 92 mm proxy")
	check(int(profile.get("ranged", [{}])[0].get("count", 0)) == 4 and sphere.get("attacks") == 6 and sphere.get("keywords", {}) == {"anti-fly": 4, "sustained-hits": 2}, "Four Tesla spheres preserve Anti-FLY 4+ and Sustained Hits 2")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "gravitic-pulse", "damaged-8"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty(), "Every Obelisk source rule is admitted")
	var first := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OBELISK_ID, "models": 1, "copies": 1}]})
	var two := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OBELISK_ID, "models": 1, "copies": 2}]})
	check(str(first.get("error", "")).is_empty() and int(first.get("total", -1)) == 280 and str(two.get("error", "")).is_empty() and int(two.get("total", -1)) == 590, "First Obelisk admits at 280 and the second copy adds 310")
	check(AbilityCatalog.RULES.get("obelisk", []) == ["deep-strike", "deadly-demise-d6", "reanimation-protocols", "gravitic-pulse", "damaged-8"], "Ability catalog binds all five Obelisk rules")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OBELISK_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": MARINE_ID, "models": 3, "copies": 1}]}
	})
	if state.has("error"):
		check(false, "Obelisk fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var obelisk_model := -1
	var enemy_squad := -1
	for model: int in state.get("units", {}):
		if Abilities.identity(state.units[model]) == "obelisk": obelisk_model = model
		elif Abilities.identity(state.units[model]) == "inceptor-squad" and enemy_squad < 0: enemy_squad = int(state.units[model].get("squad", -1))
	check(obelisk_model >= 0 and enemy_squad >= 0, "Obelisk and Inceptor fixture models materialize")
	if obelisk_model < 0 or enemy_squad < 0:
		quit(1)
		return
	state.units[obelisk_model].position = Vector2.ZERO
	for model: int in Geometry.alive(state, enemy_squad):
		state.units[model].position = Vector2(10.0, 0.0)
	UnitActions.reconcile(state)

	state.units[obelisk_model].wounds = 8
	check(C.Morale.objective_control(state, obelisk_model) == 4 and UnitAbilities.damaged_attack_penalty(state, obelisk_model) == -1, "Damaged 8 subtracts 4 OC and -1 Hit at eight wounds")
	state.units[obelisk_model].wounds = 9
	check(C.Morale.objective_control(state, obelisk_model) == 8 and UnitAbilities.damaged_attack_penalty(state, obelisk_model) == 0, "Damaged 8 ends above eight wounds")
	state.units[obelisk_model].wounds = 24

	state.phase = "movement"
	state.active = 2
	state.turn = 1
	UnitActions.reconcile(state)
	var pulse := find_choice(state, 1, Obelisk.ACTION, enemy_squad)
	var pulse_result := PublicUnitCommand.submit(state, 1, pulse)
	check(not pulse.is_empty() and str(pulse_result.get("error", "")).is_empty() and Obelisk.half_active(state, enemy_squad) and Obelisk.fly_active(state, enemy_squad), "Gravitic Pulse marks a visible FLY unit within 18 inches")
	check(is_equal_approx(Obelisk.movement_characteristic(state, enemy_squad, 10.0), 5.0) and Obelisk.halve_roll(state, enemy_squad, 7) == 4, "Gravitic Pulse halves Move and Advance/Charge rolls, rounding up")

	scripted_dice = [4, 5]
	var after := Obelisk.after_move(state, enemy_squad, Callable(self, "next_die"))
	check(bool(after.get("triggered", false)) and int(after.get("wounds", 0)) == 3 and str(state.unit_abilities.window.get("kind", "")) == Obelisk.MORTAL_WINDOW, "A FLY unit ending a move on a 4+ opens D3 mortal-wound allocation")

	if failures == 0:
		print("Obelisk scoped local checks: passed")
		quit(0)
	else:
		print("Obelisk checks: %d failures" % failures)
		quit(1)

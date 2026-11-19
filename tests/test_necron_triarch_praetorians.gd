extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")

const PRAETORIAN_ID := "40kdc:11e:necrons:triarch-praetorians"
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

func run() -> void:
	var profile := Profiles.profile("triarch-praetorians")
	var rod_ranged: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var rod_melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000000539" and profile.get("points_by_models", {}) == {5: 80, 10: 160} and profile.get("base_size_source_mm", 0) == 32, "Triarch Praetorians retain App v1.2 identity, priced sizes and 32 mm bases")
	check(rod_ranged.get("attacks") == 1 and rod_melee.get("attacks") == 3 and rod_melee.get("ap") == -2, "Rod of covenant ranged and melee profiles preserve source values")
	check(profile.get("supported_rule_ids", []) == ["deep-strike", "reanimation-protocols", "relentless-combatants"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty(), "Every Triarch Praetorians source rule is admitted within the local scope")
	var five := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": PRAETORIAN_ID, "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": PRAETORIAN_ID, "models": 10, "copies": 1}]})
	check(str(five.get("error", "")).is_empty() and int(five.get("total", -1)) == 80 and str(ten.get("error", "")).is_empty() and int(ten.get("total", -1)) == 160, "5/10-model Praetorians admit at 80/160")
	check(AbilityCatalog.RULES.get("triarch-praetorians", []) == ["deep-strike", "reanimation-protocols", "relentless-combatants"], "Ability catalog binds Deep Strike, Reanimation and Relentless Combatants")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": PRAETORIAN_ID, "models": 5, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}
	})
	if state.has("error"):
		check(false, "Triarch Praetorians fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var praetorian_model := -1
	var enemy_model := -1
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "triarch-praetorians" and praetorian_model < 0: praetorian_model = model
		elif identity == "intercessor-squad" and enemy_model < 0: enemy_model = model
	check(praetorian_model >= 0 and enemy_model >= 0, "Praetorians and Intercessors materialize")
	if praetorian_model < 0 or enemy_model < 0:
		quit(1)
		return
	var squad := int(state.units[praetorian_model].get("squad", -1))
	check(Reanimation.supported_unit(state, squad), "Five-model Triarch Praetorians can activate Reanimation Protocols")
	UnitActions.reconcile(state)

	state.squads[squad].fell_back = true
	state.squads[squad].advanced = false
	check(Doctrines.charge_error(state, squad).is_empty(), "Relentless Combatants keeps Praetorians eligible to charge after Falling Back")

	state.phase = "charge"
	state.active = 1
	state.turn = 1
	state.squads[squad].fell_back = false
	state.units[praetorian_model].position = Vector2.ZERO
	state.units[enemy_model].position = Vector2(8.0, 0.0)
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == int(state.units[enemy_model].get("squad", -1)):
			state.units[model].position = Vector2(8.0, float(model % 5))
	scripted_dice = [1, 1, 6, 6]
	var declared: Dictionary = C.declare_charge(state, 1, praetorian_model, int(state.revision), Callable(self, "next_die"))
	check(str(declared.get("error", "")).is_empty() and bool(state.get("stratagems", {}).get("pending", {}).get("relentless_combatants", false)), "Relentless Combatants opens a free Charge re-roll window")
	var reroll := C.resolve_roll_reaction(state, 1, squad, "relentless-combatants", int(state.revision), Callable(self, "next_die"))
	check(reroll.is_empty() and int(state.get("pending_charge", {}).get("maximum", -1)) == 12, "Relentless Combatants re-rolls both Charge dice at 0 CP")

	if failures == 0:
		print("Triarch Praetorians scoped local checks: passed")
		quit(0)
	else:
		print("Triarch Praetorians checks: %d failures" % failures)
		quit(1)

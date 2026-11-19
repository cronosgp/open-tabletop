extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

const HEAVY_ID := "40kdc:11e:necrons:lokhust-heavy-destroyers"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const RHINO_ID := "40kdc:11e:adeptus-astartes:rhino"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("lokhust-heavy-destroyers")
	check(profile.get("source_datasheet_id", "") == "000002116" and profile.get("points_by_models", {}) == {1: 50, 2: 100, 3: 165} and profile.get("third_plus_points_by_models", {}) == {1: 60, 2: 110, 3: 175}, "Lokhust Heavy Destroyers retain both source copy-price tiers")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "optimised-for-slaughter"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty(), "Optimised for Slaughter is admitted within the local scope")
	check(profile.get("source_options", [{}])[0].get("implemented", false) and profile.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("id", "") == "enmitic-exterminator", "Enmitic exterminator replacement is implemented from the local App export")
	var one := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEAVY_ID, "models": 1, "copies": 1}]})
	var three := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEAVY_ID, "models": 3, "copies": 1}]})
	var third_three := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": HEAVY_ID, "models": 3, "copies": 3}]})
	check(str(one.get("error", "")).is_empty() and int(one.get("total", -1)) == 50 and str(three.get("error", "")).is_empty() and int(three.get("total", -1)) == 165, "1- and 3-model Lokhust Heavy Destroyers admit at source first-copy prices")
	check(str(third_three.get("error", "")).is_empty() and int(third_three.get("total", -1)) == 505, "Three 3-model copies cost 165+165+175")
	check(AbilityCatalog.RULES.get("lokhust-heavy-destroyers", []) == ["reanimation-protocols", "optimised-for-slaughter"], "Ability catalog binds Reanimation and Optimised for Slaughter")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEAVY_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1},
			{"definition_id": RHINO_ID, "models": 1, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Lokhust Heavy fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	var heavy_model := -1
	var marine_squad := -1
	var rhino_squad := -1
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "lokhust-heavy-destroyers": heavy_model = model
		elif identity == "intercessor-squad" and marine_squad < 0: marine_squad = int(state.units[model].get("squad", -1))
		elif identity == "rhino" and rhino_squad < 0: rhino_squad = int(state.units[model].get("squad", -1))
	check(heavy_model >= 0 and marine_squad >= 0 and rhino_squad >= 0, "Lokhust Heavy, Intercessors and Rhino materialize")
	if heavy_model < 0 or marine_squad < 0 or rhino_squad < 0:
		quit(1)
		return
	var squad := int(state.units[heavy_model].get("squad", -1))
	check(Reanimation.supported_unit(state, squad), "Lokhust Heavy Destroyers can activate Reanimation Protocols")
	UnitActions.reconcile(state)
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	state.unit_abilities.window = {}
	state.active = 1
	var offered := UnitActions.choices(state, 1).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "necron-lokhust-heavy-enmitic")
	check(offered.size() == 1 and str(offered[0].get("value", "")) == "enmitic", "Preparation offers the Enmitic exterminator replacement")
	var swapped := UnitActions.apply(state, 1, offered[0], Vector2.ZERO, Callable()) if not offered.is_empty() else {"error": "No Enmitic choice"}
	check(str(swapped.get("error", "")).is_empty() and str(state.units[heavy_model].ranged_weapons[0].get("id", "")) == "enmitic-exterminator", "The model can replace its Gauss destructor with an Enmitic exterminator")
	var restore := UnitActions.choices(state, 1).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "necron-lokhust-heavy-enmitic" and str(candidate.get("value", "")) == "destructor")
	check(not restore.is_empty() and str(UnitActions.apply(state, 1, restore[0], Vector2.ZERO, Callable()).get("error", "")).is_empty() and str(state.units[heavy_model].ranged_weapons[0].get("id", "")) == "gauss-destructor", "The setup choice can restore the Gauss destructor")

	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.units[heavy_model].position = Vector2.ZERO
	for model: int in state.units:
		var unit_squad := int(state.units[model].get("squad", -1))
		if unit_squad == marine_squad: state.units[model].position = Vector2(18.0, 0.0)
		elif unit_squad == rhino_squad: state.units[model].position = Vector2(24.0, 0.0)

	var destructor_id := str(state.units[heavy_model].ranged_weapons[0].get("id", ""))
	var vs_rhino := AttackPlan.prepare(state, squad, false, [{"model": heavy_model, "target": rhino_squad, "amount": 1, "weapon": destructor_id, "profile": "standard"}], true)
	var vs_marines := AttackPlan.prepare(state, squad, false, [{"model": heavy_model, "target": marine_squad, "amount": 1, "weapon": destructor_id, "profile": "standard"}], true)
	check(str(vs_rhino.get("error", "")).is_empty() and str(vs_rhino.get("batches", [{}])[0].get("context", {}).get("wound_reroll", "")) == "ones", "Gauss destructor against a VEHICLE re-rolls Wound rolls of 1")
	check(str(vs_marines.get("error", "")).is_empty() and str(vs_marines.get("batches", [{}])[0].get("context", {}).get("wound_reroll", "none")) in ["none", ""], "Gauss destructor against Infantry does not receive Optimised Wound re-rolls")

	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var enmitic_choice := UnitActions.choices(state, 1).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "necron-lokhust-heavy-enmitic" and str(candidate.get("value", "")) == "enmitic")
	check(not enmitic_choice.is_empty() and str(UnitActions.apply(state, 1, enmitic_choice[0], Vector2.ZERO, Callable()).get("error", "")).is_empty(), "Enmitic can be reselected for Optimised wound checks")
	state.phase = "shooting"
	var enmitic_id := str(state.units[heavy_model].ranged_weapons[0].get("id", ""))
	var enmitic_vs_marines := AttackPlan.prepare(state, squad, false, [{"model": heavy_model, "target": marine_squad, "amount": 1, "weapon": enmitic_id, "profile": "standard"}], true)
	var enmitic_vs_rhino := AttackPlan.prepare(state, squad, false, [{"model": heavy_model, "target": rhino_squad, "amount": 1, "weapon": enmitic_id, "profile": "standard"}], true)
	check(str(enmitic_vs_marines.get("error", "")).is_empty() and str(enmitic_vs_marines.get("batches", [{}])[0].get("context", {}).get("wound_reroll", "")) == "ones", "Enmitic exterminator against non-MONSTER/VEHICLE re-rolls Wound rolls of 1")
	check(str(enmitic_vs_rhino.get("error", "")).is_empty() and str(enmitic_vs_rhino.get("batches", [{}])[0].get("context", {}).get("wound_reroll", "none")) in ["none", ""], "Enmitic exterminator against a VEHICLE does not receive Optimised Wound re-rolls")

	if failures == 0:
		print("Lokhust Heavy Destroyers scoped local checks: passed")
		quit(0)
	else:
		print("Lokhust Heavy Destroyers checks: %d failures" % failures)
		quit(1)

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and str(unit.get("definition_id", "")).ends_with(":" + identity): return model
	return -1

func move_squad_to(state: Dictionary, squad: int, position: Vector2) -> void:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad: state.units[model].position = position

func logic_state(phase: String, active: int, distance: float = 12.0, target_identity: String = "necron-warriors", target_owner: int = 2) -> Dictionary:
	var state := F.fresh()
	if state.has("error"): return state
	var warden := model_for(state, 2, "royal-warden")
	var target_model := model_for(state, target_owner if target_identity == "necron-warriors" else 1, target_identity)
	if warden < 0 or target_model < 0: return {"error": "Royal Warden or target fixture is missing."}
	var target_squad: int = int(state.units[target_model].squad)
	state.squads[target_squad].owner = target_owner
	state.squads[target_squad].battle_shocked = true
	state.units[warden].position = Vector2.ZERO
	var edge_distance := float(state.units[warden].radius) + float(state.units[target_model].radius) + distance
	move_squad_to(state, target_squad, Vector2(edge_distance, 0.0))
	state.phase = phase
	state.active = active
	state.awakened_dynasty.pending = []
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = "stale-phase-key"
	if state.has("command_battle_shock"): state.command_battle_shock.pending = {}
	UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		var doctrine_error := C.select_combat_doctrine(state, active, "none", int(state.revision))
		if not doctrine_error.is_empty(): return {"error": doctrine_error}
	return state

func logic_choices(state: Dictionary, owner: int, target: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option: Dictionary in UnitActions.choices(state, owner):
		if str(option.get("action", "")) == "logic" and int(option.get("target", -1)) == target: result.append(option)
	return result

func run() -> void:
	var profile := Profiles.profile("royal-warden")
	check(profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("source_book_id", "") == "000000029" and profile.get("source_book_version", "") == "1.2" and profile.get("source_datasheet_id", "") == "000002350", "Royal Warden traces to the local Necrons App v1.2 source record")
	check(profile.get("points_by_models", {}) == {1: 50} and profile.get("construction_model_sizes", []) == [1] and profile.get("base_size_source_mm", 0) == 32, "Royal Warden uses its fixed one-model, 50-point, 32 mm source configuration")
	check(profile.get("source_ability_names", []) == ["Leader", "Reanimation Protocols", "Adaptive Strategy", "Engrammatic Logic"] and profile.get("unsupported_abilities", []) == [], "All four source abilities are mapped with no remaining unsupported Warden ability")
	check(profile.get("supported_rule_ids", []) == ["leader", "reanimation-protocols", "adaptive-strategy", "engrammatic-logic"] and profile.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535"], "The profile maps its Leader, Reanimation and two Warden rules to the source bodyguards")
	var gun: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(gun == {"name": "Relic gauss blaster", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"lethal-hits": true, "rapid-fire": 2}} and melee == {"name": "Close combat weapon", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}, "Both fixed Warden weapon profiles retain their local characteristics and traits")
	check(Army.SPECS.get("royal-warden", {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_31", "Only this fully checked Necron sheet advances past its pending-validation gate")
	var resolved := Army.resolve("Necrons", "40kdc:11e:necrons:royal-warden")
	check(str(resolved.get("error", "")).is_empty() and int(resolved.get("cost", -1)) == 50 and resolved.get("pack_hash", "") == Profiles.digest(), "The current local Army resolver admits only the validated Warden profile at its source cost")
	var catalog := Catalog.new()
	root.add_child(catalog)
	check(catalog.select_edition("11e").is_empty(), "The consolidated local construction catalog rebuilds")
	var warden_catalog_entry := catalog.lookup("40kdc:11e:necrons:royal-warden")
	check(warden_catalog_entry.get("source_id", "") == "royal-warden" and warden_catalog_entry.get("options", []) == [{"models": 1, "cost": 50}], "The validated Warden enters the consolidated catalog with only its local size and price")
	check(catalog.lookup("40kdc:11e:necrons:necron-warriors").get("options", []) == [{"models": 10, "cost": 85}, {"models": 20, "cost": 190}], "The separate local Warriors scope offers only its verified sizes and prices")

	var state := logic_state("shooting", 2)
	if state.has("error"):
		check(false, "Engrammatic Logic fixture is ready: " + str(state.get("error", "")))
		quit(1)
		return
	var warden := model_for(state, 2, "royal-warden")
	var warriors := model_for(state, 2, "necron-warriors")
	var warden_squad: int = int(state.units[warden].squad)
	var warriors_squad: int = int(state.units[warriors].squad)
	check(C.UnitAbilities.sources(state, warden_squad, "engrammatic-logic") == [warden] and C.Reanimation.supported_unit(state, warden_squad), "The living Warden supplies Engrammatic Logic and the shared Reanimation rule")
	var exact_range_choices := logic_choices(state, 2, warriors_squad)
	check(C.UnitActions.logic_available(state, 2) and exact_range_choices.size() == 1, "A friendly Battle-shocked NECRONS unit exactly 12 inches away is selectable at phase start")
	if not exact_range_choices.is_empty():
		var logic_choice: Dictionary = exact_range_choices[0]
		check(C.unit_action(state, 2, logic_choice, Vector2.ZERO, int(state.revision), six).is_empty() and not state.squads[warriors_squad].battle_shocked and state.unit_abilities.used.has("logic:%d" % warden), "Engrammatic Logic clears the selected unit and records its once-per-battle use")
	state.squads[warriors_squad].battle_shocked = true
	state.phase = "fight"
	state.active = 1
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = "next-phase"
	if state.has("command_battle_shock"): state.command_battle_shock.pending = {}
	UnitActions.reconcile(state)
	check(not C.UnitActions.logic_available(state, 2) and logic_choices(state, 2, warriors_squad).is_empty(), "The used ability cannot trigger again in a later opponent phase")

	for phase: String in ["command", "movement", "shooting", "charge", "fight"]:
		for active: int in [1, 2]:
			var phase_state := logic_state(phase, active)
			if phase_state.has("error"):
				check(false, "%s phase fixture is ready for active player %d: %s" % [phase, active, str(phase_state.get("error", ""))])
				continue
			var phase_warden := model_for(phase_state, 2, "royal-warden")
			var phase_target := model_for(phase_state, 2, "necron-warriors")
			check(C.UnitActions.logic_available(phase_state, 2) and not logic_choices(phase_state, 2, int(phase_state.units[phase_target].squad)).is_empty(), "Engrammatic Logic is available at the start of %s when player %d is active" % [phase, active])
			if phase_warden >= 0: check("logic:%d" % phase_warden not in phase_state.unit_abilities.used, "A fresh battle can use the ability once in %s" % phase)

	var distant := logic_state("movement", 2, 12.1)
	if distant.has("error"):
		check(false, "Out-of-range fixture is ready: " + str(distant.get("error", "")))
	else:
		var distant_target := model_for(distant, 2, "necron-warriors")
		check(not C.UnitActions.logic_available(distant, 2) and logic_choices(distant, 2, int(distant.units[distant_target].squad)).is_empty(), "Engrammatic Logic rejects a target beyond 12 inches")

	var non_necron := logic_state("movement", 2, 6.0, "intercessor-squad", 2)
	if non_necron.has("error"):
		check(false, "Non-Necron target fixture is ready: " + str(non_necron.get("error", "")))
	else:
		check(not C.UnitActions.logic_available(non_necron, 2) and UnitActions.choices(non_necron, 2).all(func(option: Dictionary) -> bool: return str(option.get("action", "")) != "logic"), "Engrammatic Logic ignores a friendly Battle-shocked unit without the NECRONS keyword")

	var adaptive := F.fresh()
	var adaptive_warden := model_for(adaptive, 2, "royal-warden")
	var enemy := model_for(adaptive, 1, "intercessor-squad")
	var adaptive_squad: int = int(adaptive.units[adaptive_warden].squad)
	adaptive.units[adaptive_warden].position = Vector2.ZERO
	adaptive.units[enemy].position = Vector2(8.0, 0.0)
	adaptive.squads[adaptive_squad].fell_back = true
	check(C.Doctrines.shoot_after_fallback(adaptive, adaptive_squad) and C.Doctrines.charge_error(adaptive, adaptive_squad).is_empty(), "Adaptive Strategy passes the shared shooting and charge fallback gates")
	adaptive.units[adaptive_warden].definition_id = "40kdc:11e:necrons:canoptek-reanimator"
	check(not C.Doctrines.shoot_after_fallback(adaptive, adaptive_squad) and C.Doctrines.charge_error(adaptive, adaptive_squad).contains("Fell Back"), "A unit without Adaptive Strategy remains unable to shoot or charge after Fall Back")

	if failures == 0: print("Royal Warden local datasheet checks: passed")
	else: print("Royal Warden local datasheet checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")

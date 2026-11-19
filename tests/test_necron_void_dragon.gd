extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const MatterAbsorption = preload("res://scripts/edition_11/void_dragon_matter_absorption.gd")
const VOID_DRAGON_ID := "40kdc:11e:necrons:ctan-shard-of-the-void-dragon"
const DOOMSTALKER_ID := "40kdc:11e:necrons:canoptek-doomstalker"

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

func units_for(state: Dictionary, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func find_action(state: Dictionary, player: int, action: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action: return option
	return {}

func act(state: Dictionary, player: int, option: Dictionary) -> Dictionary:
	return {"error": C.unit_action(state, player, option, Vector2.ZERO, int(state.get("revision", -1)), Callable(self, "next_die"))}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DOOMSTALKER_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": VOID_DRAGON_ID, "models": 1, "copies": 1}]}}

func run() -> void:
	var profile := Profiles.profile("ctan-shard-of-the-void-dragon")
	var spear: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var storm: Dictionary = profile.get("ranged", [{}, {}])[1].get("profiles", {}).get("standard", {})
	var melee_spear: Dictionary = profile.get("melee", [{}])[0].get("profiles", {})
	var tail_blades: Dictionary = profile.get("melee", [{}, {}])[1].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000002357" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Void Dragon facts retain their local Necrons App v1.2 snapshot identity")
	check(profile.get("points_by_models", {}) == {1: 345} and profile.get("base_size_source_mm", 0) == 80 and profile.get("stats", {}).get("wounds", 0) == 16 and profile.get("stats", {}).get("invulnerable_target", 0) == 4, "Void Dragon keeps its one-model 345 point, 80 mm, 16-wound source profile")
	check(spear.get("attacks") == "D3" and spear.get("strength") == 8 and spear.get("damage") == "D6+2" and spear.get("keywords", {}) == {"anti-vehicle": 2}, "Spear of the Void Dragon ranged profile preserves its source Anti-Vehicle 2+ trait")
	check(storm.get("range_inches") == 18 and storm.get("attacks") == "D6+3" and storm.get("damage") == 2 and storm.get("keywords", {}) == {"blast": true, "sustained-hits": 2}, "Voltaic storm preserves its Blast and Sustained Hits 2 traits")
	check(melee_spear.get("strike", {}).get("attacks") == 5 and melee_spear.get("strike", {}).get("keywords", {}) == {"anti-vehicle": 2} and melee_spear.get("sweep", {}).get("attacks") == 10 and tail_blades.get("keywords", {}) == {"extra-attacks": true}, "Both spear modes and Canoptek tail blades preserve their source profiles")
	check(profile.get("supported_rule_ids", []).has("matter-absorption") and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_options", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "The Void Dragon ability and configuration gates close against the local source profile")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": VOID_DRAGON_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 345, "The one-model Void Dragon enters the consolidated construction catalog at 345 points")
	var duplicate := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": VOID_DRAGON_ID, "models": 1, "copies": 2}]})
	check(not str(duplicate.get("error", "")).is_empty(), "The Epic Hero duplicate cap remains enforced")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Void Dragon and Doomstalker local fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	var dragon_models := units_for(state, "ctan-shard-of-the-void-dragon")
	var dragon_squad := squad_for(state, "ctan-shard-of-the-void-dragon")
	var doomstalker_models := units_for(state, "canoptek-doomstalker")
	var doomstalker_squad := squad_for(state, "canoptek-doomstalker")
	check(dragon_models.size() == 1 and dragon_squad >= 0 and doomstalker_models.size() == 1 and doomstalker_squad >= 0, "The local battle fixture materializes the Void Dragon and opposing Vehicle")
	if dragon_models.is_empty() or dragon_squad < 0 or doomstalker_models.is_empty() or doomstalker_squad < 0:
		quit(1)
		return
	var dragon := dragon_models[0]
	var doomstalker := doomstalker_models[0]
	check(Abilities.has(state, dragon_squad, "matter-absorption") and Abilities.has(state, dragon_squad, "deep-strike") and Abilities.has(state, dragon_squad, "feel-no-pain-5") and Abilities.has(state, dragon_squad, "necrodermis") and Abilities.has(state, dragon_squad, "enslaved-star-god") and Abilities.deadly_demise_value(state, dragon) == "D6" and Abilities.cannot_be_warlord(state, dragon), "The Void Dragon binds Matter Absorption and all existing local C'tan rules")
	for model: int in state.units:
		state.units[model].on_battlefield = false
		state.units[model].position = Vector2.ZERO
	state.units[dragon].on_battlefield = true
	state.units[dragon].position = Vector2.ZERO
	state.units[dragon].wounds = 15
	state.units[doomstalker].on_battlefield = true
	state.units[doomstalker].position = Vector2(8.0, 0.0)
	state.units[doomstalker].wounds = 3
	state.phase = "shooting"
	state.active = 2
	state.unit_abilities.phase_key = ""
	check(MatterAbsorption.start_available(state, 2), "Matter Absorption is available for the Void Dragon's Shooting phase against a Vehicle within 12 inches")
	var original_target_keywords: Array = state.units[doomstalker].keywords.duplicate()
	state.units[doomstalker].keywords = []
	check(not MatterAbsorption.start_available(state, 2), "Matter Absorption excludes non-Vehicle targets")
	state.units[doomstalker].keywords = original_target_keywords
	var original_target_position: Vector2 = state.units[doomstalker].position
	state.units[doomstalker].position = Vector2(20.0, 0.0)
	check(not MatterAbsorption.start_available(state, 2), "Matter Absorption excludes enemy Vehicles beyond 12 inches")
	state.units[doomstalker].position = original_target_position
	state.phase = "fight"
	check(not MatterAbsorption.start_available(state, 2), "Matter Absorption does not trigger outside the owner's Shooting phase")
	state.phase = "shooting"
	state.units[doomstalker].max_wounds = 12
	state.units[doomstalker].wounds = 12
	var spear_id := str(state.units[dragon].ranged_weapons[0].get("id", ""))
	var attack_plan := C.AttackPlan.prepare(state, dragon_squad, false, [{"model": dragon, "target": doomstalker_squad, "amount": 1, "weapon": spear_id, "profile": "standard"}], true)
	var planned_weapon: Dictionary = attack_plan.get("batches", [{}])[0].get("weapon", {})
	check(str(attack_plan.get("error", "")).is_empty() and planned_weapon.get("keywords", {}) == {"anti-vehicle": 2}, "The source Spear of the Void Dragon enters the shared ranged AttackPlan with Anti-Vehicle 2+")
	state.units[doomstalker].wounds = 3
	state.unit_abilities.phase_key = ""
	UnitActions.reconcile(state)
	var source_choice := find_action(state, 2, MatterAbsorption.ACTION)
	var pass_choice := find_action(state, 2, "pass")
	check(state.unit_abilities.window.get("kind", "") == "start" and state.unit_abilities.window.get("owners", []).has(2) and not source_choice.is_empty() and not pass_choice.is_empty(), "The shared Shooting phase start window offers Matter Absorption and the standard pass control")
	var refused_pass := act(state, 2, pass_choice)
	check(not str(refused_pass.get("error", "")).is_empty() and not state.unit_abilities.used.has("matter-absorption:%d" % dragon), "Passing cannot skip the mandatory Matter Absorption target selection")
	scripted_dice = [2, 5, 6, 1, 2]
	var triggered := act(state, 2, source_choice)
	check(str(triggered.get("error", "")).is_empty() and state.get("pending_matter_absorption", {}).get("remaining", 0) == 3 and state.units[dragon].wounds == 15, "A 2+ opens a three-wound packet and defers healing until damage resolves")
	for index in range(2):
		var allocation := find_action(state, 1, MatterAbsorption.ALLOCATE)
		check(not allocation.is_empty(), "The affected Vehicle defender gets allocation choice %d" % (index + 1))
		if allocation.is_empty(): break
		var result := act(state, 1, allocation)
		check(str(result.get("error", "")).is_empty(), "Matter Absorption mortal wound %d is allocated through defender prevention" % (index + 1))
	var final_mortal := find_action(state, 1, MatterAbsorption.ALLOCATE)
	var last_damage := act(state, 1, final_mortal)
	check(str(last_damage.get("error", "")).is_empty() and state.units[doomstalker].wounds <= 0 and not state.get("pending_deadly_demise", {}).is_empty() and not state.get("pending_matter_absorption", {}).is_empty() and state.units[dragon].wounds == 15, "Destroying the target suspends healing while its Deadly Demise continuation resolves")
	var demise_allocation := find_action(state, 2, "deadly-demise-allocate")
	check(not demise_allocation.is_empty(), "The Void Dragon receives the Doomstalker's Deadly Demise allocation choice")
	if not demise_allocation.is_empty():
		var demise_result := act(state, 2, demise_allocation)
		check(str(demise_result.get("error", "")).is_empty(), "The nested Deadly Demise packet resolves before Matter Absorption healing")
	check(state.get("pending_matter_absorption", {}).is_empty() and state.get("pending_deadly_demise", {}).is_empty() and state.units[dragon].wounds == 16 and state.get("last_matter_absorption", {}).get("d6", {}).get("value", 0) == 2 and state.get("last_matter_absorption", {}).get("d3", {}).get("value", 0) == 3 and state.get("last_matter_absorption", {}).get("healed", 0) == 2 and state.get("last_matter_absorption", {}).get("allocations", []).size() == 3, "The Void Dragon heals by up to its D3 result after nested destruction, and the complete roll/allocation record is retained")
	var completed_pass := act(state, 2, find_action(state, 2, "pass"))
	check(str(completed_pass.get("error", "")).is_empty() and state.unit_abilities.window.is_empty(), "The owner can pass after the mandatory Matter Absorption sequence completes")

	state.turn = int(state.get("turn", 0)) + 1
	state.active = 2
	state.phase = "shooting"
	state.units[dragon].wounds = 14
	state.units[doomstalker].wounds = 3
	state.units[doomstalker].on_battlefield = true
	state.units[doomstalker].position = original_target_position
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = ""
	UnitActions.reconcile(state)
	scripted_dice = [1]
	var failed_roll := act(state, 2, find_action(state, 2, MatterAbsorption.ACTION))
	check(str(failed_roll.get("error", "")).is_empty() and state.get("last_matter_absorption", {}).get("d6", {}).get("value", 0) == 1 and not state.get("last_matter_absorption", {}).get("triggered", true) and state.units[dragon].wounds == 14 and state.get("pending_matter_absorption", {}).is_empty(), "A D6 result of 1 causes no mortal wounds or healing and consumes this phase's mandatory trigger")
	check(find_action(state, 2, MatterAbsorption.ACTION).is_empty(), "Matter Absorption cannot be repeated during the same Shooting phase")

	if failures == 0: print("Necron C’tan Shard of the Void Dragon local checks: passed")
	else: print("Necron C’tan Shard of the Void Dragon local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Corvus = preload("res://scripts/edition_11/corvus_blackstar.gd")
const CombatScenario = preload("res://scripts/edition_11/combat_scenario.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const C = F.C
var failures := 0
var rolls: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return rolls.pop_front() if not rolls.is_empty() else 1

func selections(passenger: String = "intercessor-squad") -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries = [
			{"definition_id": "40kdc:11e:adeptus-astartes:corvus-blackstar", "models": 1, "copies": 1},
			{"definition_id": "40kdc:11e:adeptus-astartes:%s" % passenger, "models": 5, "copies": 1}]
	return result

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func run() -> void:
	var profile := Profiles.profile("corvus-blackstar")
	check(profile.get("source_book_id", "") == "000000035" and profile.get("source_datasheet_id", "") == "000000358" and profile.get("points", 0) == 180, "Corvus profile carries the Deathwatch App identity and exported points")
	check(profile.stats.movement_inches == 14 and profile.stats.wounds == 14 and "AIRCRAFT" not in profile.keywords and "FLY" in profile.keywords and "Hover" in profile.core_abilities, "Corvus preserves the corrected movement and keyword/Hover interaction")
	check(profile.transport.capacity == 12 and profile.transport.required == ["DEATHWATCH", "INFANTRY"] and profile.transport.double_space == ["GRAVIS", "JUMP PACK", "TERMINATOR"], "Corvus transport profile preserves capacity, eligibility, and model-space costs")
	check(profile.get("default_loadout_by_role", {}).get("Corvus Blackstar", {}).get("Auspex Array", 0) == 1, "The default equipment record includes the source-listed Auspex Array")
	check(profile.ranged.size() == 3 and profile.additional_weapon_profiles.ranged.size() == 4 and profile.transport.options.replacement_groups.has("blackstar-rocket-launchers"), "Corvus retains unique weapon identities and the paired launcher replacement")

	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Corvus fixture prepares from the local construction catalog: %s" % str(state.error))
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.window = {}
	var corvus_model := find_model(state, 1, "corvus-blackstar")
	var corvus_squad := int(state.units[corvus_model].squad)
	check(C.UnitAbilities.deadly_demise_value(state, corvus_model) == "D6", "Corvus exposes source-listed Deadly Demise D6")
	check(C.UnitAbilities.has(state, corvus_squad, "stealth") and Terrain.take_to_skies_penalty(state, corvus_squad, true) == 0.0, "Corvus Stealth and Hover are active through the runtime ability and movement gates")
	state.units[corvus_model].wounds = 5
	check(C.UnitAbilities.damaged_attack_penalty(state, corvus_model) == -1, "Damaged 5 applies at five remaining wounds")
	state.units[corvus_model].wounds = 6
	check(C.UnitAbilities.damaged_attack_penalty(state, corvus_model) == 0, "Damaged 5 does not apply above its threshold")
	state.units[corvus_model].wounds = state.units[corvus_model].max_wounds
	var baseline: Array = state.units[corvus_model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id))
	check(baseline.has("blackstar-rocket-launcher-left") and baseline.has("blackstar-rocket-launcher-right"), "Default loadout includes both distinct Blackstar Rocket Launchers")
	check(Transport.configure_optional_transport_weapon(state, corvus_model, "group:blackstar-rocket-launchers:on").is_empty(), "Both launchers can be replaced as one grouped choice")
	var replaced: Array = state.units[corvus_model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id))
	check(not replaced.has("blackstar-rocket-launcher-left") and not replaced.has("blackstar-rocket-launcher-right") and replaced.has("stormstrike-missile-launcher-left") and replaced.has("stormstrike-missile-launcher-right"), "Grouped replacement equips both Stormstrike Missile Launchers and removes both originals")
	check(Transport.configure_optional_transport_weapon(state, corvus_model, "group:blackstar-rocket-launchers:off").is_empty(), "Grouped replacement is reversible during Army Preparation")
	check(Transport.configure_optional_transport_weapon(state, corvus_model, "replace:twin-assault-cannon:twin-lascannon").is_empty(), "Twin Assault Cannon replacement uses the existing one-for-one transport option")
	check(Transport.configure_optional_transport_weapon(state, corvus_model, "hurricane-bolter:on").is_empty(), "Optional Hurricane Bolter uses the existing add-weapon transport option")
	var chosen: Array = state.units[corvus_model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id))
	check(chosen.has("blackstar-rocket-launcher-left") and chosen.has("twin-lascannon") and chosen.has("hurricane-bolter"), "Individual replacement and optional weapon choices coexist with the paired replacement")
	var friendly_intercessors := find_model(state, 1, "intercessor-squad")
	var ineligible_passenger_error := Transport.eligibility_error(state, corvus_model, int(state.units[friendly_intercessors].squad))
	check(ineligible_passenger_error.contains("DEATHWATCH"), "Corvus rejects a non-Deathwatch passenger despite the INFANTRY keyword")
	var terminator_state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections("deathwatch-terminator-squad"))
	var terminator_corvus := find_model(terminator_state, 1, "corvus-blackstar")
	var terminator_model := find_model(terminator_state, 1, "deathwatch-terminator-squad")
	var terminator_squad := int(terminator_state.units[terminator_model].squad)
	check(Transport.eligibility_error(terminator_state, terminator_corvus, terminator_squad).is_empty() and Transport.capacity_cost(terminator_state, terminator_squad, Profiles.profile("corvus-blackstar").transport) == 10, "Corvus accepts Deathwatch Terminators and counts their five models as ten spaces")

	state.phase = "movement"
	state.unit_abilities.window = {}
	var enemy_model := find_model(state, 2, "intercessor-squad")
	var enemy_squad := int(state.units[enemy_model].squad)
	state.units[corvus_model].position = Vector2(5, 0)
	state.units[enemy_model].position = Vector2(0, 0)
	var detour := {corvus_model: [
		{"from": Vector2(-5, 0), "to": Vector2(-5, 5)},
		{"from": Vector2(-5, 5), "to": Vector2(5, 5)},
		{"from": Vector2(5, 5), "to": Vector2(5, 0)}]}
	check(not Corvus.open_after_normal_move(state, corvus_squad, "normal", detour), "Cluster Launcher uses the recorded route segments and does not infer an untraveled straight-line shortcut")
	var crossed := {corvus_model: [{"from": Vector2(-5, 0), "to": Vector2(5, 0)}]}
	check(not Corvus.open_after_normal_move(state, corvus_squad, "advance", crossed), "Cluster Launcher does not trigger after an Advance")
	C.UnitActions.end_move(state, corvus_squad, "normal", [], crossed)
	check(state.unit_abilities.window.get("kind", "") == Corvus.WINDOW, "A Corvus normal move crossing an enemy base opens the optional Cluster Launcher decision through end_move")
	check(C.UnitActions.movement_reaction_squad(state) == corvus_squad, "The Cluster Launcher window keeps the movement resolution frame active")
	var target_choice: Dictionary = C.UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "corvus-cluster-target" and int(choice.target) == enemy_squad)[0]
	rolls = [1, 2, 3, 4, 5, 6]
	var fired := C.UnitActions.apply(state, 1, target_choice, Vector2.ZERO, Callable(self, "roll_die"))
	check(fired.get("error", "").is_empty() and state.last_corvus_cluster_launcher.rolls == [1, 2, 3, 4, 5, 6] and state.last_corvus_cluster_launcher.mortal_wounds == 3, "Cluster Launcher rolls six D6 and causes one mortal wound for each 4+")
	check(state.unit_abilities.window.get("kind", "") == Corvus.MORTAL_WINDOW and C.UnitActions.movement_reaction_squad(state) == corvus_squad, "Mortal-wound allocation nests inside and retains the Movement continuation")
	var allocations := C.UnitActions.choices(state, 2)
	check(not allocations.is_empty() and allocations[0].action == "mortal-allocate", "The target player receives the normal mortal-wound allocation choices")
	for _wound in range(3):
		allocations = C.UnitActions.choices(state, 2).filter(func(choice: Dictionary) -> bool: return choice.action == "mortal-allocate")
		if allocations.is_empty(): break
		var allocated := C.UnitActions.apply(state, 2, allocations[0], Vector2.ZERO, Callable())
		check(allocated.get("error", "").is_empty(), "A Cluster Launcher mortal wound follows ordinary allocation and prevention")
	check(state.unit_abilities.window.get("kind", "") == Corvus.WINDOW and state.unit_abilities.window.get("stage", "") == "resume", "Completing the mortal packet resumes the Corvus movement reaction")
	var continuation: Dictionary = C.UnitActions.choices(state, 1)[0]
	check(continuation.action == "corvus-cluster-continue", "The moving player can close the Cluster Launcher continuation")
	C.UnitActions.apply(state, 1, continuation, Vector2.ZERO, Callable())
	check(state.unit_abilities.window.is_empty(), "Closing Cluster Launcher restores the prior ability window")

	var movement_state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	movement_state.phase = "movement"
	movement_state.active = 1
	movement_state.unit_abilities.window = {}
	movement_state.unit_abilities.phase_key = C.UnitActions.key(movement_state)
	var moving_corvus := find_model(movement_state, 1, "corvus-blackstar")
	var moving_squad := int(movement_state.units[moving_corvus].squad)
	var moving_enemy := find_model(movement_state, 2, "intercessor-squad")
	for model: int in movement_state.units:
		if model == moving_corvus or model == moving_enemy: continue
		movement_state.units[model].position = Vector2(15, 12) if int(movement_state.units[model].owner) == 2 else Vector2(-15, 12)
	movement_state.units[moving_corvus].position = Vector2(-6, 0)
	movement_state.units[moving_enemy].position = Vector2(0, 0)
	var begin_error := CombatScenario.begin_movement(movement_state, 1, moving_corvus, "normal", int(movement_state.revision), Callable(), false, false, true)
	check(begin_error.is_empty(), "The normal move can declare Take to the Skies with Hover")
	if begin_error.is_empty():
		var staged := CombatScenario.move_result(movement_state, 1, moving_corvus, Vector2(6, 0), int(movement_state.revision))
		check(bool(staged.get("valid", false)) and movement_state.pending_move.paths.get(moving_corvus, []).size() == 1, "CombatScenario records the actual staged route segment")
		var finished := CombatScenario.finish_movement_result(movement_state, 1, int(movement_state.revision))
		check(bool(finished.get("valid", false)) and movement_state.unit_abilities.window.get("kind", "") == Corvus.WINDOW and C.UnitActions.movement_reaction_squad(movement_state) == moving_squad, "Confirming the actual move opens and suspends for Cluster Launcher")
	print("Corvus Blackstar checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

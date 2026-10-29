extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const IDENTITIES := ["land-raider", "land-raider-crusader", "land-raider-redeemer", "drop-pod", "impulsor", "repulsor", "repulsor-executioner", "corvus-blackstar"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roster(entries: Array) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 2000, "entries": entries}

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func state_for(identities: Array) -> Dictionary:
	var entries: Array[Dictionary] = []
	for identity: String in identities: entries.append(entry(identity))
	var selections := {1: roster(entries), 2: roster([entry("rhino")])}
	return Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)

func run() -> void:
	var catalog := Catalog.new()
	root.add_child(catalog)
	check(catalog.select_edition("11e").is_empty(), "The consolidated local e11 catalog loads")
	for identity: String in IDENTITIES:
		var id := "40kdc:11e:adeptus-astartes:" + identity
		check(catalog.contains(id), "%s is published from its current local source profile" % identity)
		var resolved := Army.resolve("Space Marines", id)
		var expected_status := "source_bounded_local_scope_passed_2026_10_29" if identity == "corvus-blackstar" else "source_bounded_local_scope_passed_2026_10_28" if identity in ["land-raider", "land-raider-crusader", "land-raider-redeemer", "impulsor", "repulsor", "repulsor-executioner"] else "tests_passed_local_targeted"
		check(resolved.error.is_empty() and resolved.spec.get("validation_status", "") == expected_status, "%s resolves with only its recorded local validation status" % identity)
		var admitted := Army.admit(roster([entry(identity)]))
		check(admitted.error.is_empty() and admitted.total == int(Profiles.profile(identity).points), "%s passes local construction with extracted points" % identity)
		var profile: Dictionary = Profiles.profile(identity)
		var second_cost := int(profile.get("second_plus_points_by_models", {}).get(1, profile.points))
		var third_cost := int(profile.get("third_plus_points_by_models", {}).get(1, second_cost))
		var second_copy := Army.admit(roster([entry(identity, 1, 2)]))
		check(second_copy.error.is_empty() and second_copy.total == int(profile.points) + second_cost, "%s prices the second copy from its exact source tier" % identity)
		var third_copies := Army.admit(roster([entry(identity, 1, 3)]))
		check(third_copies.error.is_empty() and third_copies.total == int(profile.points) + second_cost + third_cost, "%s prices three copies using first, second-plus and third-plus tiers" % identity)
		var fourth := Army.admit(roster([entry(identity, 1, 4)]))
		if identity == "drop-pod":
			check(fourth.error.is_empty() and fourth.total == 250, "Drop Pod admits its fourth-plus tier at 70 points after three 60-point copies")
			check(not Army.admit(roster([entry(identity, 1, 5)])).error.is_empty(), "Drop Pod enforces its current four-copy local support ceiling")
		else:
			check(not fourth.error.is_empty(), "%s rejects a fourth copy under the local construction cap" % identity)
	check(Roster.tiered_cost(245, 265, 3, 0, null, 265) == 775, "Saved-list cost summaries preserve the 245 first copy and 265 second-plus copies")
	var state := state_for(IDENTITIES.slice(0, 6))
	check(not state.has("error"), "Six admitted transport entries pass army preparation together: " + str(state.get("error", "")))
	if not state.has("error"):
		for identity: String in IDENTITIES.slice(0, 6):
			var found := false
			for model: int in state.units:
				if Abilities.identity(state.units[model]) != identity: continue
				found = true
				check(state.units[model].get("transport_profile", {}).get("capacity", 0) == Profiles.profile(identity).transport.capacity, "%s materializes its extracted transport profile" % identity)
				check(Transport.is_transport(state, model), "%s enters the shared transport rules runtime" % identity)
				if identity == "drop-pod":
					check(state.units[model].ranged_weapons.is_empty() and state.units[model].melee_weapons.is_empty() and state.squads[state.units[model].squad].melee_weapon.is_empty(), "Drop Pod materializes without an invented ranged or melee weapon")
				break
			check(found, "%s materializes as a deployed current-reference unit" % identity)
	var final_state := state_for(["repulsor-executioner"])
	check(not final_state.has("error"), "Repulsor Executioner passes current-ability training materialization: " + str(final_state.get("error", "")))
	if not final_state.has("error"):
		check(Abilities.sources(final_state, 1, "executioner").size() == 1, "Repulsor Executioner's datasheet rule remains active after admission")
	var corvus_state := state_for(["corvus-blackstar"])
	check(not corvus_state.has("error"), "Corvus Blackstar materializes through the shared transport admission path: " + str(corvus_state.get("error", "")))
	if not corvus_state.has("error"):
		var corvus_found := false
		for model: int in corvus_state.units:
			if Abilities.identity(corvus_state.units[model]) != "corvus-blackstar": continue
			corvus_found = true
			check(Transport.is_transport(corvus_state, model) and corvus_state.units[model].get("transport_profile", {}).get("capacity", 0) == 12, "Corvus enters the shared 12-space transport rules runtime")
			check(corvus_state.units[model].get("core_abilities", []).has("Hover"), "Corvus Hover reaches the Take to the Skies movement gate")
			break
		check(corvus_found, "Corvus profile materializes as a deployed current-reference model")
	var both_impulsors := Prepared.initial_state(
		{"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false},
		{1: roster([entry("impulsor")]), 2: roster([entry("impulsor")])})
	check(not both_impulsors.has("error"), "Both players can prepare the Impulsor from the current local catalog: " + str(both_impulsors.get("error", "")))
	if not both_impulsors.has("error"):
		for player: int in [1, 2]:
			var found := false
			for model: int in both_impulsors.units:
				if int(both_impulsors.units[model].get("owner", -1)) != player or Abilities.identity(both_impulsors.units[model]) != "impulsor": continue
				found = true
				var transport_profile: Dictionary = both_impulsors.units[model].get("transport_profile", {})
				check(transport_profile.get("capacity", 0) == 7 and both_impulsors.units[model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["storm-bolters"], "Player %d materializes the source capacity and default Impulsor weapon" % player)
				break
			check(found, "Player %d receives one current-catalog Impulsor" % player)
	for identity: String in ["land-raider", "land-raider-crusader", "land-raider-redeemer", "repulsor", "repulsor-executioner"]:
		var mirrored := Prepared.initial_state(
			{"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false},
			{1: roster([entry(identity)]), 2: roster([entry(identity)])})
		check(not mirrored.has("error"), "Both players can prepare the source-bounded %s from the current local catalog: %s" % [identity, str(mirrored.get("error", ""))])
		if mirrored.has("error"): continue
		for player: int in [1, 2]:
			var found := false
			for model: int in mirrored.units:
				if int(mirrored.units[model].get("owner", -1)) != player or Abilities.identity(mirrored.units[model]) != identity: continue
				found = true
				check(mirrored.units[model].get("transport_profile", {}).get("capacity", 0) == Profiles.profile(identity).transport.capacity, "Player %d materializes the source transport rules for %s" % [player, identity])
				break
			check(found, "Player %d receives one current-catalog %s" % [player, identity])
	catalog.free()
	print("Marine transport admission: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const IDENTITIES := ["land-raider", "land-raider-crusader", "land-raider-redeemer", "drop-pod", "impulsor", "repulsor", "repulsor-executioner"]
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
		check(resolved.error.is_empty() and resolved.spec.get("validation_status", "") == "tests_passed_local_targeted", "%s resolves through the admitted current profile registry" % identity)
		var admitted := Army.admit(roster([entry(identity)]))
		check(admitted.error.is_empty() and admitted.total == int(Profiles.profile(identity).points), "%s passes local construction with extracted points" % identity)
		check(Army.admit(roster([entry(identity, 1, 3)])).error.is_empty(), "%s accepts three copies within the local construction cap" % identity)
		check(not Army.admit(roster([entry(identity, 1, 4)])).error.is_empty(), "%s rejects a fourth copy under the local construction cap" % identity)
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
	catalog.free()
	print("Marine transport admission: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roster(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}]}

func run() -> void:
	var catalog := Catalog.new()
	root.add_child(catalog)
	check(catalog.select_edition("11e").is_empty(), "The consolidated local e11 catalog loads")
	check(catalog.contains("40kdc:11e:adeptus-astartes:rhino"), "Rhino appears in the local construction catalog")
	check(catalog.lookup("40kdc:11e:adeptus-astartes:rhino").options == [{"models": 1, "cost": 70, "third_plus_cost": 70, "fourth_plus_cost": 80}], "Rhino preserves the 1st–3rd and 4th-plus Wahapedia price tiers")
	check(RosterValidation.POINTS.get("rhino", {}).get("fourth_plus_sizes", {}) == {1: 80}, "The bounded roster-price authority preserves Rhino's separate fourth-plus source tier")
	var resolved := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:rhino")
	check(resolved.error.is_empty() and resolved.spec.max_supported_copies == 3 and resolved.spec.validation_status == "source_bounded_local_scope_passed_2026_10_28", "Rhino resolves with its evidence-backed local status and three-copy construction limit")
	var admitted := Army.admit(roster("rhino", 1, 3))
	check(admitted.error.is_empty() and admitted.total == 210 and admitted.unit_count == 3, "Roster admission prices the first three Rhino copies at the source 1st–3rd tier")
	check(not Army.admit(roster("rhino", 1, 4)).error.is_empty(), "Roster admission rejects a fourth Rhino")
	var selections := {1: roster("rhino"), 2: roster("intercessor-squad", 5)}
	var state: Dictionary = Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Prepared training accepts the admitted Rhino with current abilities enabled")
	if not state.has("error"):
		var rhino_model := -1
		for model: int in state.units:
			if Abilities.identity(state.units[model]) == "rhino": rhino_model = model
		check(rhino_model >= 0 and state.units[rhino_model].transport_profile.capacity == 12, "Prepared training materializes the Rhino's imported transport rules")
		check(rhino_model >= 0 and state.units[rhino_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "storm-bolter"), "Prepared Rhino retains its default weapon inventory")
		check(rhino_model >= 0 and state.units[rhino_model].transport_profile.options.add.has("Hunter-killer Missile"), "Prepared Rhino exposes the optional Hunter-killer Missile from its source profile")
		check(Abilities.sources(state, state.units[rhino_model].squad, "veiling-smoke").has(rhino_model), "The admitted Rhino activates Veiling Smoke in the current-ability runtime")
	var mirrored: Dictionary = Prepared.initial_state(
		{"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false},
		{1: roster("rhino"), 2: roster("rhino")})
	check(not mirrored.has("error"), "Both players can prepare a Rhino from the current local catalog")
	if not mirrored.has("error"):
		for player: int in [1, 2]:
			var found := false
			for model: int in mirrored.units:
				if int(mirrored.units[model].get("owner", -1)) != player or Abilities.identity(mirrored.units[model]) != "rhino": continue
				found = true
				check(mirrored.units[model].transport_profile.capacity == 12 and Abilities.sources(mirrored, mirrored.units[model].squad, "veiling-smoke").has(model), "Player %d materializes Rhino capacity and Veiling Smoke" % player)
				break
			check(found, "Player %d receives a Rhino from the current local catalog" % player)
	print("Marine Rhino admission: %d failures" % failures)
	catalog.free()
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

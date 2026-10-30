extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const UNIT := "dreadnought"
const UNIT_ID := "40kdc:11e:adeptus-astartes:dreadnought"
const A = C.UnitAbilities
const U = C.UnitActions
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
	return result

func prepared() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}, selection())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func unit_models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_of(state: Dictionary, identity: String, owner: int) -> int:
	var found := unit_models(state, identity, owner)
	return int(state.units[found[0]].get("squad", -1)) if not found.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func weapon_entry(loadout: Dictionary, category: String, weapon_id: String) -> Dictionary:
	for row: Dictionary in loadout.get(category, []):
		if str(row.get("id", "")) == weapon_id: return row
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000117", "The profile identifies Dreadnought in the verified Space Marines Legends book")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records its verified export provenance")
	check(profile.get("points_by_models", {}) == {1: 135} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The one-model 135-point cost and supported copy ceiling match the source-bounded catalog")
	check(profile.get("base_size_source_mm") == 60 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 30.0 / 25.4), "The exact 60 mm base is represented as a 30 mm radius")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "All Dreadnought characteristics match the local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DEATHWING", "WALKER", "VEHICLE", "SMOKE", "IMPERIUM"], "All source keywords, including SMOKE, are represented")
	check(profile.get("default_loadout_by_role", {}).get("Dreadnought", {}) == {"Assault Cannon": 1, "Dreadnought Fist": 1, "Storm Bolter": 1}, "The fixed loadout matches the source")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise 1", "Wisdom of the Ancients"], "All datasheet and faction abilities are listed")
	var defaults := Profiles.dreadnought_weapons()
	check(defaults.get("ranged", []).size() == 2 and defaults.ranged.any(func(row: Dictionary) -> bool: return row.id == "assault-cannon") and defaults.ranged.any(func(row: Dictionary) -> bool: return row.id == "storm-bolter"), "The default Assault Cannon and Storm Bolter are represented")
	check(defaults.get("melee", []).size() == 1 and defaults.melee[0].get("id") == "dreadnought-fist", "The default Dreadnought Fist is represented")
	check(weapon_entry(defaults, "ranged", "assault-cannon").profiles.standard == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}}, "The Assault Cannon profile matches every source characteristic")
	check(weapon_entry(defaults, "ranged", "storm-bolter").profiles.standard == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "The default Storm Bolter profile matches every source characteristic")
	check(weapon_entry(defaults, "melee", "dreadnought-fist").profiles.standard == {"name": "Dreadnought Fist", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 12, "ap": -2, "damage": 3, "keywords": {}}, "The Dreadnought Fist profile matches every source characteristic")
	var plasma := Profiles.dreadnought_weapons("heavy-plasma-cannon")
	var plasma_profiles: Dictionary = plasma.ranged[0].profiles if not plasma.is_empty() else {}
	check(plasma_profiles.get("standard", {}) == {"name": "Heavy Plasma Cannon - Standard", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 9, "ap": -2, "damage": 2, "keywords": {"blast": 1, "heavy": true}} and plasma_profiles.get("supercharge", {}) == {"name": "Heavy Plasma Cannon - Supercharge", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 10, "ap": -3, "damage": 3, "keywords": {"blast": 1, "hazardous": true, "heavy": true}}, "Both Heavy Plasma Cannon profiles preserve Heavy, Blast and Hazardous")
	var launcher := Profiles.dreadnought_weapons("assault-cannon", "crushing-feet")
	check(weapon_entry(launcher, "ranged", "missile-launcher").profiles == {
		"frag": {"name": "Missile Launcher - Frag", "range_inches": 48.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 1}},
		"krak": {"name": "Missile Launcher - Krak", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}}}, "The Missile Launcher Frag and Krak profiles match every source characteristic")
	check(launcher.get("melee", []).size() == 1 and launcher.melee[0].get("id") == "crushing-feet" and launcher.ranged.all(func(row: Dictionary) -> bool: return row.id != "storm-bolter") and weapon_entry(launcher, "melee", "crushing-feet").profiles.standard == {"name": "Crushing Feet", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "The replacement package removes both the Fist and Storm Bolter and includes the full Crushing Feet profile")
	var flamer := Profiles.dreadnought_weapons("multi-melta", "dreadnought-fist", "heavy-flamer")
	check(weapon_entry(flamer, "ranged", "heavy-flamer").profiles.standard == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}, "The Heavy Flamer profile includes its automatic hits, Blast 2 and Torrent")
	check(Profiles.dreadnought_weapons("crushing-feet", "dreadnought-fist").is_empty() and Profiles.dreadnought_weapons("assault-cannon", "crushing-feet", "heavy-flamer").is_empty() and Profiles.dreadnought_weapons("invented", "dreadnought-fist").is_empty(), "The helper rejects unsupported choices and the mutually exclusive Storm Bolter replacement")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 6, "All six optional ranged weapon identities are source-bounded alongside the fixed Assault Cannon")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "multi-melta" and row.profiles.standard == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}) and additions.any(func(row: Dictionary) -> bool: return row.id == "twin-lascannon" and row.profiles.standard == {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}), "Multi-melta and Twin Lascannon profiles match every source characteristic")
	var legal_loadout_combinations := 0
	for primary: String in ["assault-cannon", "heavy-plasma-cannon", "multi-melta", "twin-lascannon"]:
		for melee_package: String in ["dreadnought-fist", "crushing-feet"]:
			for secondary: String in ["none", "heavy-flamer"]:
				var combination := Profiles.dreadnought_weapons(primary, melee_package, secondary)
				var should_be_invalid := melee_package == "crushing-feet" and secondary == "heavy-flamer"
				check(combination.is_empty() == should_be_invalid, "The equipment dependency admits or rejects %s/%s/%s correctly" % [primary, melee_package, secondary])
				if not combination.is_empty(): legal_loadout_combinations += 1
	check(legal_loadout_combinations == 12, "All 12 combinations of the independent primary option and linked package groups are legal")
	check(Catalog.construction_readiness_note(UNIT).contains("competitive events require organiser approval") and Catalog.construction_readiness_note(UNIT).contains("exact 60 mm base"), "The Legends event-use boundary and exact base are published")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 135}], "The consolidated catalog exposes the source-priced one-model unit")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 135}, "Roster validation applies the source cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(admitted.get("error", "").is_empty(), "Three Dreadnought copies are admitted under the configured Strike Force limit")
	var over_limit := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(over_limit.get("error", "")).is_empty(), "A fourth Dreadnought is rejected by the repetition limit")

	var state := prepared()
	check(not state.has("error"), "Dreadnought materializes from the current local catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var dreadnought_models := unit_models(state, UNIT, 1)
	check(dreadnought_models.size() == 1, "A single Dreadnought model enters the match")
	if dreadnought_models.is_empty():
		quit(1)
		return
	var model := dreadnought_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "deadly-demise-1") and A.deadly_demise_value(state, model) == "1" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "wisdom-of-the-ancients"), "Deadly Demise 1, Combat Doctrines and Wisdom of the Ancients are registered")
	check(C.CoreReactions.keyword(state, squad, "SMOKE"), "The source SMOKE keyword enables the shared Smokescreen gate")
	check(state.units[model].ranged_weapons.size() == 2 and state.units[model].melee_weapons.size() == 1 and state.units[model].get("dreadnought_primary") == "assault-cannon", "The battle starts with the full source default loadout")
	var secondary_squad := int(state.units[model].squad)
	var flamer_choice := choice_for(state, 1, "dreadnought-secondary", model, secondary_squad, "heavy-flamer")
	check(not flamer_choice.is_empty() and C.unit_action(state, 1, flamer_choice, Vector2.ZERO, state.revision).is_empty(), "Preparation accepts the Storm Bolter-to-Heavy-Flamer replacement")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "heavy-flamer"), "The Heavy Flamer replaces rather than adds to the Storm Bolter")
	var invalid_package := {"action": "dreadnought-melee-package", "model": model, "target": squad, "value": "crushing-feet"}
	check(not C.unit_action(state, 1, invalid_package, Vector2.ZERO, state.revision).is_empty(), "The public action rejects Crushing Feet while the Storm Bolter has already been replaced")
	var restore_secondary := choice_for(state, 1, "dreadnought-secondary", model, squad, "none")
	check(not restore_secondary.is_empty() and C.unit_action(state, 1, restore_secondary, Vector2.ZERO, state.revision).is_empty(), "Preparation restores the default Storm Bolter")
	var feet_choice := choice_for(state, 1, "dreadnought-melee-package", model, squad, "crushing-feet")
	check(not feet_choice.is_empty() and C.unit_action(state, 1, feet_choice, Vector2.ZERO, state.revision).is_empty(), "Preparation accepts the linked Missile Launcher + Crushing Feet replacement")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "missile-launcher") and state.units[model].melee_weapons.any(func(row: Dictionary) -> bool: return row.id == "crushing-feet") and state.units[model].ranged_weapons.all(func(row: Dictionary) -> bool: return row.id != "storm-bolter"), "The linked replacement is materialized without the replaced weapons")
	var invalid_secondary := {"action": "dreadnought-secondary", "model": model, "target": squad, "value": "heavy-flamer"}
	check(not C.unit_action(state, 1, invalid_secondary, Vector2.ZERO, state.revision).is_empty(), "The public action rejects a Heavy Flamer after the Storm Bolter is removed")
	var primary_choice := choice_for(state, 1, "dreadnought-primary", model, squad, "twin-lascannon")
	check(not primary_choice.is_empty() and C.unit_action(state, 1, primary_choice, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "twin-lascannon"), "The primary Assault Cannon replacement is independent of the melee package")
	var restore_package := choice_for(state, 1, "dreadnought-melee-package", model, squad, "dreadnought-fist")
	check(not restore_package.is_empty() and C.unit_action(state, 1, restore_package, Vector2.ZERO, state.revision).is_empty(), "The linked replacement can be reversed during preparation")
	var plasma_choice := choice_for(state, 1, "dreadnought-primary", model, squad, "heavy-plasma-cannon")
	check(not plasma_choice.is_empty() and C.unit_action(state, 1, plasma_choice, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "heavy-plasma-cannon"), "The Heavy Plasma Cannon replacement is selectable")
	var restore_primary := choice_for(state, 1, "dreadnought-primary", model, squad, "assault-cannon")
	check(not restore_primary.is_empty() and C.unit_action(state, 1, restore_primary, Vector2.ZERO, state.revision).is_empty(), "The Assault Cannon default can be restored")

	var infantry_squad := squad_of(state, "intercessor-squad", 1)
	var infantry_models := Geometry.alive(state, infantry_squad)
	var enemy_squad := squad_of(state, "intercessor-squad", 2)
	var enemy_models := Geometry.alive(state, enemy_squad)
	check(infantry_squad >= 0 and not infantry_models.is_empty() and enemy_squad >= 0 and not enemy_models.is_empty(), "The prepared match contains friendly and enemy Intercessor units")
	if infantry_squad >= 0 and not infantry_models.is_empty() and enemy_squad >= 0 and not enemy_models.is_empty():
		var infantry_model := infantry_models[0]
		for other: int in infantry_models:
			if other != infantry_model: state.units[other].wounds = 0
		state.units[model].position = Vector2.ZERO
		state.units[infantry_model].position = Vector2(6.0 + float(state.units[model].radius) + float(state.units[infantry_model].radius), 0.0)
		check(A.wisdom_of_the_ancients_active(state, infantry_squad), "Wisdom uses base-edge distance and reaches a friendly Astartes Infantry model at 6 inches")
		state.units[infantry_model].position.x += 0.02
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "Wisdom ends immediately beyond 6 inches")
		state.units[infantry_model].position.x -= 0.02
		var saved_keywords: Array = state.units[infantry_model].keywords.duplicate()
		state.units[infantry_model].keywords.erase("INFANTRY")
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "Wisdom does not affect a target lacking INFANTRY")
		state.units[infantry_model].keywords = saved_keywords.duplicate()
		state.units[infantry_model].keywords.erase("ADEPTUS ASTARTES")
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "Wisdom does not affect a target lacking ADEPTUS ASTARTES")
		state.units[infantry_model].keywords = saved_keywords.duplicate()
		var source_on_battlefield := bool(state.units[model].get("on_battlefield", true))
		state.units[model].on_battlefield = false
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "A Dreadnought off the battlefield does not supply Wisdom")
		state.units[model].on_battlefield = source_on_battlefield
		check(not A.wisdom_of_the_ancients_active(state, squad), "The Dreadnought cannot benefit from its own Infantry-only aura")
		var saved_owner := int(state.squads[infantry_squad].owner)
		state.squads[infantry_squad].owner = 2
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "Wisdom does not affect an enemy unit")
		state.squads[infantry_squad].owner = saved_owner

		var shooter: Dictionary = state.units[infantry_model]
		var ranged_weapon: Dictionary = shooter.ranged_weapons[0]
		for enemy: int in enemy_models: state.units[enemy].position = Vector2(20.0, 0.0)
		state.units[infantry_model].position = Vector2(3.0, 0.0)
		state.phase = "shooting"
		state.active = 1
		var ranged_plan := C.AttackPlan.prepare(state, infantry_squad, false, [{"model": infantry_model, "target": enemy_squad, "amount": 1, "weapon": str(ranged_weapon.id), "profile": str(ranged_weapon.profiles.keys()[0])}], false)
		check(ranged_plan.get("error", "").is_empty() and ranged_plan.get("batches", []).size() == 1 and ranged_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Wisdom enters a friendly Infantry ranged attack plan")

		var overwatch := state.duplicate(true)
		overwatch.phase = "movement"
		overwatch.active = 2
		overwatch.unit_abilities.phase_key = U.key(overwatch)
		overwatch.core_reactions.overwatch = {"phase_key": C.CoreReactions.phase_key(overwatch), "squad": infantry_squad, "player": 1}
		var snap_plan := C.AttackPlan.prepare(overwatch, infantry_squad, false, [{"model": infantry_model, "target": enemy_squad, "amount": 1, "weapon": str(ranged_weapon.id), "profile": str(ranged_weapon.profiles.keys()[0])}], false)
		check(snap_plan.get("error", "").is_empty() and snap_plan.batches[0].context.get("snap_shooting", false) and snap_plan.batches[0].context.get("hit_reroll", "none") == "none", "Wisdom preserves the Snap Shooting hit-reroll prohibition")

		var indirect := state.duplicate(true)
		var indirect_model: Dictionary = indirect.units[infantry_model]
		indirect_model.ranged_weapons[0].profiles[indirect_model.ranged_weapons[0].profiles.keys()[0]].keywords["indirect-fire"] = true
		var indirect_profile := str(indirect_model.ranged_weapons[0].profiles.keys()[0])
		var indirect_plan := C.AttackPlan.prepare(indirect, infantry_squad, false, [{"model": infantry_model, "target": enemy_squad, "amount": 1, "weapon": str(indirect_model.ranged_weapons[0].id), "profile": indirect_profile}], false, -1, true)
		check(indirect_plan.get("error", "").is_empty() and indirect_plan.batches.size() == 1 and indirect_plan.batches[0].context.get("indirect_fire", false) and indirect_plan.batches[0].context.get("hit_reroll", "none") == "none", "Wisdom preserves the Indirect Fire hit-reroll prohibition")

		for enemy: int in enemy_models: state.units[enemy].position = Vector2(4.5, 0.0)
		state.units[infantry_model].position = Vector2(3.0, 0.0)
		var melee_weapon: Dictionary = state.units[infantry_model].melee_weapons[0]
		var melee_attacks := int(melee_weapon.profiles[melee_weapon.profiles.keys()[0]].attacks)
		state.phase = "fight"
		var melee_plan := C.AttackPlan.prepare(state, infantry_squad, true, [{"model": infantry_model, "target": enemy_squad, "amount": melee_attacks, "weapon": str(melee_weapon.id), "profile": str(melee_weapon.profiles.keys()[0])}], false)
		check(melee_plan.get("error", "").is_empty() and melee_plan.get("batches", []).size() == 1 and melee_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Wisdom enters a friendly Infantry melee attack plan")

		state.units[model].wounds = 0
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "A destroyed Dreadnought no longer supplies Wisdom")
		state.units[model].wounds = int(profile.stats.wounds)

	state.units[model].wounds = 0
	var demise := DeadlyDemise.begin(state, [model], func() -> int: return 6)
	check(demise.get("error", "").is_empty() and not state.get("pending_deadly_demise", {}).is_empty(), "Destroyed Dreadnought enters the shared Deadly Demise sequence")
	if not state.get("pending_deadly_demise", {}).is_empty():
		var pending: Dictionary = state.pending_deadly_demise
		check(pending.get("events", []).size() == 1 and pending.events[0].get("expression", "") == "1" and not pending.get("packets", []).is_empty() and pending.packets.all(func(packet: Dictionary) -> bool: return packet.get("remaining", 0) == 1 and packet.get("roll", {}).get("expression", "") == "1"), "Deadly Demise 1 uses an unmodified trigger 6 and rolls one mortal wound separately for each affected unit")

	if failures == 0:
		print("Dreadnought Legends checks passed")
	else:
		print("Dreadnought Legends checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

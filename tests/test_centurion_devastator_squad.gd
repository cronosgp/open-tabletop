extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const SOURCE_ID := "centurion-devastator-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:centurion-devastator-squad"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry("intercessor-squad", 5)]
	result[1].entries = [entry(SOURCE_ID, 3)]
	return result

func battle() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].squad) if model >= 0 else -1

func choices_for(state: Dictionary, action: String, model: int, value: String = "") -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, 1):
		if str(candidate.get("action", "")) == action and int(candidate.get("model", -1)) == model and (value.is_empty() or str(candidate.get("value", "")) == value): return candidate
	return {}

func attack_plan(state: Dictionary, model: int, squad: int, target: int, weapon: String, profile: String = "standard", indirect: bool = false) -> Dictionary:
	return C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile}], true, -1, indirect)

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000001193", "Profile is tied to the current 11e Warhammer Legends Centurion Devastator sheet")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile retains the verified export and Legends source-slice provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Centurion-Devastator-Squad"), "Current 11e source URL and Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {3: 175, 6: 350} and profile.get("models", 0) == 3 and profile.get("stats", {}) == {"movement_inches": 4, "toughness": 7, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Only source-priced 3- and 6-model sizes and the exact characteristics are admitted")
	check(profile.get("base_size_source_mm", 0) == 50 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 25.0 / 25.4), "The exact 50 mm base is represented without a proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "INFANTRY", "CENTURION", "IMPERIUM"], "All exported unit and faction keywords are retained")
	check(profile.get("default_loadout_by_role", {}).get("Devastator Centurion", {}) == {"Centurion Bolters": 1, "Centurion Fists": 1, "Grav-cannon": 1} and profile.default_loadout_by_role.get("Devastator Centurion Sergeant", {}) == {"Centurion Bolters": 1, "Centurion Fists": 1, "Grav-cannon": 1}, "Both source roles have the exported default loadout")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Decimator Protocols"] and "decimator-protocols" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "Army and datasheet abilities are registered for this identity")
	check(Capabilities.supported("decimator-protocols"), "Decimator Protocols has an enabled capability record")

	var expected_weapons := {
		"centurion-bolters": {"name": "Centurion Bolters", "range_inches": 24.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 3, "twin-linked": true}},
		"centurion-missile-launcher": {"name": "Centurion Missile Launcher", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 9, "ap": -2, "damage": 3, "keywords": {"blast": 1}},
		"grav-cannon": {"name": "Grav-cannon", "range_inches": 24.0, "attacks": 3, "skill": 3, "strength": 6, "ap": -1, "damage": 3, "keywords": {"anti-vehicle": 2}},
		"twin-heavy-bolter": {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2}},
		"twin-lascannon": {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}
	}
	for weapon_id: String in expected_weapons:
		var weapon := P.additional_weapon(SOURCE_ID, "ranged", weapon_id)
		if weapon_id in ["centurion-bolters", "grav-cannon"]:
			weapon = profile.ranged.filter(func(candidate: Dictionary) -> bool: return str(candidate.get("id", "")) == weapon_id)[0] if not profile.ranged.filter(func(candidate: Dictionary) -> bool: return str(candidate.get("id", "")) == weapon_id).is_empty() else {}
		var actual: Dictionary = weapon.get("profiles", {}).get("standard", {})
		check(actual == expected_weapons[weapon_id], "%s matches every source characteristic and weapon trait" % weapon_id)
	check(profile.melee.size() == 1 and profile.melee[0].id == "centurion-fists" and profile.melee[0].profiles.standard == {"name": "Centurion Fists", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 5, "ap": -1, "damage": 2, "keywords": {}}, "Centurion Fists match the current melee profile")
	check(Army.SPECS.get(SOURCE_ID, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "Army admission labels Legends scope and the source datasheet repeat ceiling")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Centurion Devastators are loaded from the consolidated local catalog")
	var unit := provider.lookup(UNIT_ID)
	check(unit.get("source_scope", "") == "Warhammer Legends" and unit.get("options", []) == [{"models": 3, "cost": 175}, {"models": 6, "cost": 350}] and unit.get("scope", "").contains("competitive events require organiser approval"), "Construction exposes both legal sizes, exact costs and the event-use condition")
	var invalid_size := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 4)]})
	check(not str(invalid_size.get("error", "")).is_empty(), "An unpriced 4-model configuration is rejected")
	var incursion_two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 3, 2)]})
	var incursion_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 3, 3)]})
	var strike_force_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(SOURCE_ID, 6, 3)]})
	var strike_force_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(SOURCE_ID, 6, 4)]})
	check(incursion_two.get("error", "").is_empty() and incursion_two.get("total", -1) == 350 and not incursion_three.get("error", "").is_empty(), "Incursion prices the 3-model unit and enforces its two-copy cap")
	check(strike_force_three.get("error", "").is_empty() and strike_force_three.get("total", -1) == 1050 and not strike_force_four.get("error", "").is_empty(), "Strike Force prices the 6-model unit and enforces its three-copy cap")

	for bolter: String in ["centurion-bolters", "centurion-missile-launcher"]:
		for support: String in ["grav-cannon", "twin-heavy-bolter", "twin-lascannon"]:
			var loadout := P.centurion_devastator_weapons(bolter, support)
			check(not loadout.is_empty() and loadout.ranged.size() == 2 and loadout.melee.size() == 1 and loadout.ranged[0].id == bolter and loadout.ranged[1].id == support, "Every source-legal per-model weapon replacement combines independently")
	check(P.centurion_devastator_weapons("invalid", "grav-cannon").is_empty() and P.centurion_devastator_weapons("centurion-bolters", "invalid").is_empty(), "Unlisted replacement combinations are rejected")

	var state := battle()
	if state.has("error"):
		check(false, "The source-priced Centurion configuration builds into the battle: " + str(state.error))
		provider.free()
		quit(1)
		return
	var squad := squad_for(state, 1, SOURCE_ID)
	var target := squad_for(state, 2, "intercessor-squad")
	var centurions: Array[int] = C.living(state, squad)
	centurions.sort()
	var source_sergeant_count := 0
	for model_id: int in centurions:
		if bool(state.units[model_id].get("sergeant", false)): source_sergeant_count += 1
	check(centurions.size() == 3 and source_sergeant_count == 1 and squad >= 0 and target >= 0 and C.UnitAbilities.has(state, squad, "decimator-protocols"), "The 3-model army roster contains one source-listed Sergeant and Decimator Protocols")
	var offered := C.UnitActions.choices(state, 1).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "centurion-devastator-loadout")
	check(offered.size() == centurions.size() * 3, "Preparation offers one bolter replacement and two support-weapon replacements for each model")
	if centurions.size() == 3:
		var first := centurions[0]
		var second := centurions[1]
		var bolter_choice := choices_for(state, "centurion-devastator-loadout", first, "centurion-missile-launcher")
		var bolter_selected := C.UnitActions.apply(state, 1, bolter_choice, Vector2.ZERO, Callable()) if not bolter_choice.is_empty() else {"error": "No Missile Launcher preparation choice was offered."}
		var lascannon_choice := choices_for(state, "centurion-devastator-loadout", first, "twin-lascannon")
		var lascannon_selected := C.UnitActions.apply(state, 1, lascannon_choice, Vector2.ZERO, Callable()) if not lascannon_choice.is_empty() else {"error": "No Twin Lascannon preparation choice was offered."}
		var heavy_bolter_choice := choices_for(state, "centurion-devastator-loadout", second, "twin-heavy-bolter")
		var heavy_bolter_selected := C.UnitActions.apply(state, 1, heavy_bolter_choice, Vector2.ZERO, Callable()) if not heavy_bolter_choice.is_empty() else {"error": "No Twin Heavy Bolter preparation choice was offered."}
		check(bolter_selected.get("error", "").is_empty() and lascannon_selected.get("error", "").is_empty() and heavy_bolter_selected.get("error", "").is_empty(), "Each model can independently choose either source-listed replacement slot")
		check(state.units[first].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["centurion-missile-launcher", "twin-lascannon"] and state.units[second].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["centurion-bolters", "twin-heavy-bolter"] and state.units[centurions[2]].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["centurion-bolters", "grav-cannon"], "Mixed legal equipment is stored per model without changing adjacent models")
		var invalid_loadout := C.UnitActions.apply(state, 1, {"action": "centurion-devastator-loadout", "model": first, "target": 1, "value": "invalid"}, Vector2.ZERO, Callable())
		check(not str(invalid_loadout.get("error", "")).is_empty(), "An unsupported equipment action is rejected")

	if squad >= 0 and target >= 0 and not centurions.is_empty():
		var model := centurions[2]
		state.phase = "shooting"
		state.active = 1
		state.unit_abilities.window = {}
		state.terrain.areas = []
		state.mission.objectives = [{"name": "Decimator test marker", "kind": "marker", "position": Vector2.ZERO, "controller": 0}]
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2.ZERO
		state.units[model].position = Vector2(10.0, 0.0)
		var objective_plan := attack_plan(state, model, squad, target, "centurion-bolters")
		check(objective_plan.get("error", "").is_empty() and objective_plan.get("batches", []).size() == 1 and objective_plan.batches[0].context.get("hit_reroll", "none") == "all", "Ranged attacks can re-roll all hits against a target unit within objective range: " + str(objective_plan))
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(20.0, 0.0)
		state.units[model].position = Vector2(10.0, 0.0)
		var distant_plan := attack_plan(state, model, squad, target, "centurion-bolters")
		check(distant_plan.get("error", "").is_empty() and distant_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Ranged attacks against targets outside objective range can re-roll hit rolls of 1: " + str(distant_plan))
		var overwatch_state := state.duplicate(true)
		overwatch_state.core_reactions.overwatch = {"phase_key": C.CoreReactions.phase_key(overwatch_state), "squad": squad}
		var overwatch_plan := attack_plan(overwatch_state, model, squad, target, "centurion-bolters")
		check(overwatch_plan.get("error", "").is_empty() and overwatch_plan.batches[0].context.get("snap_shooting", false) and overwatch_plan.batches[0].context.get("hit_reroll", "none") == "none", "Decimator Protocols does not override the Fire Overwatch re-roll prohibition")
		var indirect_state := state.duplicate(true)
		indirect_state.units[model].ranged_weapons[0].profiles.standard.keywords["indirect-fire"] = true
		var indirect_plan := attack_plan(indirect_state, model, squad, target, "centurion-bolters", "standard", true)
		check(indirect_plan.get("error", "").is_empty() and indirect_plan.batches.size() == 1 and indirect_plan.batches[0].context.get("indirect_fire", false) and indirect_plan.batches[0].context.get("hit_reroll", "none") == "none", "Decimator Protocols does not override the Indirect Shooting re-roll prohibition")
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(1.0, 0.0)
		state.units[model].position = Vector2.ZERO
		state.phase = "fight"
		var melee := C.AttackPlan.prepare(state, squad, true, [{"model": model, "target": target, "amount": 3, "weapon": "centurion-fists", "profile": "standard"}], true)
		check(melee.get("error", "").is_empty() and melee.batches.size() == 1 and melee.batches[0].context.get("hit_reroll", "none") == "none", "Decimator Protocols only modifies ranged attacks: " + str(melee))

	provider.free()
	if failures > 0:
		quit(1)
	else:
		print("Centurion Devastator Squad source-profile and readiness checks passed.")
		quit(0)

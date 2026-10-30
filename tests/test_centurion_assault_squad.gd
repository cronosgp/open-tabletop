extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const SOURCE_ID := "centurion-assault-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:centurion-assault-squad"
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

func choice_for(state: Dictionary, action: String, model: int, category: int = -1, value: String = "") -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, 1):
		if str(candidate.get("action", "")) != action or int(candidate.get("model", -1)) != model: continue
		if category >= 0 and int(candidate.get("target", -1)) != category: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		return candidate
	return {}

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000002703", "Profile is tied to the current 11e Warhammer Legends Centurion Assault sheet")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile retains verified local export and Legends-slice provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Centurion-Assault-Squad"), "Current 11e URL and Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {3: 150, 6: 300} and profile.get("models", 0) == 3 and profile.get("stats", {}) == {"movement_inches": 4, "toughness": 7, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Only source-priced 3- and 6-model sizes and the exact characteristics are admitted")
	check(profile.get("base_size_source_mm", 0) == 50 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 25.0 / 25.4), "Both roles use the exact 50 mm source base")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "INFANTRY", "CENTURION", "IMPERIUM"], "All exported unit and faction keywords are retained")
	check(profile.get("default_loadout_by_role", {}).get("Assault Centurion Sergeant", {}) == {"Centurion Bolters": 1, "Siege Drills": 1, "Twin Flamer": 1} and profile.default_loadout_by_role.get("Assault Centurion", {}) == {"Centurion Bolters": 1, "Siege Drills": 1, "Twin Flamer": 1}, "Both source roles retain the full default equipment")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Annihilator Protocols"] and "annihilator-protocols" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "Army and datasheet abilities are registered")
	check(Capabilities.supported("annihilator-protocols") and Capabilities.supported("centurion-assault-launcher"), "Annihilator Protocols and the Launcher bearer keyword are recorded as supported")
	check(Army.SPECS.get(SOURCE_ID, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "Army admission labels Legends and the normal datasheet copy ceiling")

	var expected_weapons := {
		"centurion-bolters": {"name": "Centurion Bolters", "range_inches": 24.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 3, "twin-linked": true}},
		"twin-flamer": {"name": "Twin Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 4, "ap": 0, "damage": 1, "keywords": {"blast": 1, "twin-linked": true, "torrent": true}},
		"twin-meltagun": {"name": "Twin Meltagun", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 9, "ap": -3, "damage": "D3+2", "keywords": {"melta": 2, "twin-linked": true}}
	}
	for weapon_id: String in ["centurion-bolters", "twin-flamer"]:
		var base_weapon: Array = profile.ranged.filter(func(candidate: Dictionary) -> bool: return str(candidate.get("id", "")) == weapon_id)
		check(base_weapon.size() == 1 and base_weapon[0].profiles.standard == expected_weapons[weapon_id], "%s matches all source characteristics and traits" % weapon_id)
	var meltagun := P.additional_weapon(SOURCE_ID, "ranged", "twin-meltagun")
	check(meltagun.get("profiles", {}).get("standard", {}) == expected_weapons["twin-meltagun"], "Twin Meltagun matches its full source profile")
	check(profile.melee.size() == 1 and profile.melee[0].id == "siege-drills" and profile.melee[0].profiles.standard == {"name": "Siege Drills", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 10, "ap": -2, "damage": 3, "keywords": {"twin-linked": true}}, "Siege Drills match all melee characteristics and Twin-linked")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Centurion Assault is available from the consolidated local catalog")
	var unit := provider.lookup(UNIT_ID)
	check(unit.get("source_scope", "") == "Warhammer Legends" and unit.get("options", []) == [{"models": 3, "cost": 150}, {"models": 6, "cost": 300}] and unit.get("scope", "").contains("competitive events require organiser approval"), "Construction exposes legal size/points and the event permission condition")
	var invalid_size := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 4)]})
	var incursion_two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 3, 2)]})
	var incursion_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 3, 3)]})
	check(not str(invalid_size.get("error", "")).is_empty(), "Unpriced model sizes are rejected")
	check(incursion_two.get("error", "").is_empty() and incursion_two.get("total", -1) == 300 and not incursion_three.get("error", "").is_empty(), "Incursion uses the source 3-model price and enforces its two-copy cap")

	for launcher: bool in [false, true]:
		for meltagun_choice: bool in [false, true]:
			var loadout := P.centurion_assault_weapons(launcher, meltagun_choice)
			var ids: Array[String] = []
			for weapon: Dictionary in loadout.get("ranged", []): ids.append(str(weapon.get("id", "")))
			check(not loadout.is_empty() and ids.has("twin-meltagun") == meltagun_choice and ids.has("twin-flamer") != meltagun_choice and ids.has("centurion-bolters") != launcher and loadout.get("assault_launcher", false) == launcher, "All per-model launcher/flamer replacement combinations are represented without an invented launcher attack")
	check(P.centurion_assault_weapons(true, false).ranged.size() == 1 and P.centurion_assault_weapons(true, true).ranged.size() == 1, "Replacing Centurion Bolters with the Launcher removes that ranged attack profile")

	var state := battle()
	if state.has("error"):
		check(false, "The 3-model Centurion Assault roster builds: " + str(state.error))
		provider.free()
		quit(1)
		return
	var squad := squad_for(state, 1, SOURCE_ID)
	var target := squad_for(state, 2, "intercessor-squad")
	var models: Array[int] = C.living(state, squad)
	models.sort()
	var sergeants := 0
	for model: int in models:
		if bool(state.units[model].get("sergeant", false)): sergeants += 1
	check(models.size() == 3 and sergeants == 1 and squad >= 0 and target >= 0 and C.UnitAbilities.has(state, squad, "annihilator-protocols"), "The legal minimum roster has one Sergeant and Annihilator Protocols")
	var offered := C.UnitActions.choices(state, 1).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "centurion-assault-loadout")
	check(offered.size() == models.size() * 2, "Preparation offers both per-model replacement choices to every Centurion")
	if models.size() == 3:
		var launcher_choice := choice_for(state, "centurion-assault-loadout", models[0], 0, "centurion-assault-launcher")
		var launcher_result := C.UnitActions.apply(state, 1, launcher_choice, Vector2.ZERO, Callable()) if not launcher_choice.is_empty() else {"error": "No launcher option was offered."}
		var meltagun_choice := choice_for(state, "centurion-assault-loadout", models[0], 1, "twin-meltagun")
		var meltagun_result := C.UnitActions.apply(state, 1, meltagun_choice, Vector2.ZERO, Callable()) if not meltagun_choice.is_empty() else {"error": "No Twin Meltagun option was offered."}
		check(launcher_result.get("error", "").is_empty() and meltagun_result.get("error", "").is_empty(), "Both independent source-listed replacements can be selected")
		check(state.units[models[0]].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["twin-meltagun"] and "EXPLOSIVES" in state.units[models[0]].keywords, "Only the launcher bearer loses its bolters and gains EXPLOSIVES")
		check(state.units[models[1]].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["centurion-bolters", "twin-flamer"] and "EXPLOSIVES" not in state.units[models[1]].keywords, "Unselected models keep their default weapons and do not gain EXPLOSIVES")
		var invalid_choice := C.UnitActions.apply(state, 1, {"action": "centurion-assault-loadout", "model": models[0], "target": 0, "value": "unsupported"}, Vector2.ZERO, Callable())
		check(not str(invalid_choice.get("error", "")).is_empty(), "Unsupported equipment selections are rejected")

		state.phase = "shooting"
		state.active = 1
		state.cp[1] = 2
		state.terrain.areas = []
		state.units[models[0]].position = Vector2.ZERO
		for enemy: int in C.living(state, target): state.units[enemy].position = Vector2(4.0, 0.0)
		var explosives := choice_for(state, "explosives", models[0])
		check(not explosives.is_empty(), "A Centurion Assault Launcher bearer can select the core Explosives action")
		if not explosives.is_empty():
			var thrown := C.UnitActions.apply(state, 1, explosives, Vector2.ZERO, func() -> int: return 1)
			check(thrown.get("error", "").is_empty(), "The launcher bearer can use Explosives against a legal nearby target: " + str(thrown))

		state.phase = "fight"
		state.units[models[0]].position = Vector2(-0.5, 0.0)
		state.units[models[1]].position = Vector2.ZERO
		state.units[models[2]].position = Vector2(0.5, 0.0)
		for enemy: int in C.living(state, target):
			state.units[enemy].position = Vector2(1.5, 0.0)
			state.units[enemy].keywords = ["MONSTER"]
		var melee_assignments: Array[Dictionary] = []
		for model: int in models: melee_assignments.append({"model": model, "target": target, "amount": 3, "weapon": "siege-drills", "profile": "standard"})
		var monster_plan := C.AttackPlan.prepare(state, squad, true, melee_assignments, true)
		check(monster_plan.get("error", "").is_empty() and not monster_plan.get("batches", []).is_empty() and monster_plan.batches.all(func(batch: Dictionary) -> bool: return batch.weapon.keywords.get("sustained-hits", 0) == 2), "Annihilator Protocols grants Sustained Hits 2 into MONSTER targets: " + str(monster_plan))
		for enemy: int in C.living(state, target): state.units[enemy].keywords = ["FORTIFICATION"]
		var fortification_plan := C.AttackPlan.prepare(state, squad, true, melee_assignments, true)
		check(fortification_plan.get("error", "").is_empty() and not fortification_plan.get("batches", []).is_empty() and fortification_plan.batches.all(func(batch: Dictionary) -> bool: return batch.weapon.keywords.get("sustained-hits", 0) == 2), "Annihilator Protocols also applies to FORTIFICATION targets")
		for enemy: int in C.living(state, target): state.units[enemy].keywords = ["INFANTRY"]
		var infantry_plan := C.AttackPlan.prepare(state, squad, true, melee_assignments, true)
		check(infantry_plan.get("error", "").is_empty() and not infantry_plan.get("batches", []).is_empty() and infantry_plan.batches.all(func(batch: Dictionary) -> bool: return not batch.weapon.keywords.has("sustained-hits")), "Annihilator Protocols does not affect melee attacks against other keywords")

	provider.free()
	if failures > 0:
		quit(1)
	else:
		print("Centurion Assault Squad source-profile and readiness checks passed.")
		quit(0)

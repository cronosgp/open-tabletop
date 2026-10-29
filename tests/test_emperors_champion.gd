extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "emperor-s-champion"
const UNIT_ID := "40kdc:11e:adeptus-astartes:emperor-s-champion"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "escape_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func model_for(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000162" and profile.get("source_datasheet_id") == "000002795" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Emperor’s Champion cites the pinned Black Templars App export")
	check(profile.get("points_by_models", {}) == {1: 100} and profile.get("max_supported_copies", 0) == 1 and profile.get("base_size_source_mm") == 40, "The one-model 100-point datasheet, one-copy cap and 40 mm base match the source")
	check(profile.get("stats", {}) == {"movement_inches": 8, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Characteristics and 4+ invulnerable save match the source")
	check(profile.get("keywords", []) == ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"], "All source datasheet and faction keywords are present")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return w.id) == ["bolt-pistol"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return w.id) == ["black-sword"], "Bolt Pistol and both Black Sword modes use one physical sword")
	check(AbilityCatalog.RULES.get(UNIT, []).size() == 6, "The three datasheet abilities and the shared Leader, Lone Operative and Combat Doctrines are registered")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 100 and C.RosterValidation.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Current construction and point catalogs admit one Emperor’s Champion")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 100}], "The consolidated local catalog exposes the 100-point profile")
	var duplicate_roster := {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]}
	check(not Catalog.admit(duplicate_roster).get("error", "").is_empty(), "Chosen of the Emperor rejects a second unit during construction")
	for ability: String in AbilityCatalog.RULES.get(UNIT, []):
		check(Registry.KNOWN.get(ability, {}).get("supported", false), "%s has a supported capability record" % ability)
	check(Links.targets(UNIT) == ["assault-intercessor-squad", "intercessor-squad", "sternguard-veteran-squad", "crusader-squad", "sword-brethren-squad"], "All five source-listed Leader targets are recorded, including the not-yet-integrated Sword Brethren endpoint")

	var state := fixture()
	if not state.has("error"):
		var champion := model_for(state, UNIT, 1)
		var champion_squad := int(state.units[champion].squad)
		var enemy_squad := int(state.units[model_for(state, "intercessor-squad", 2)].squad)
		check(champion >= 0 and model_for(state, UNIT, 2) >= 0, "Both players materialize the current Emperor’s Champion profile")
		var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, champion, enemy_squad)
		check(weapon_failures.is_empty(), "Every fixed weapon mode matches through Equipment and AttackPlan: %s" % str(weapon_failures))
		check(C.UnitAbilities.lone_operative_active(state, champion) and C.UnitAbilities.lone_operative_range(state, champion) == 12.0, "Lone Operative applies to the unaccompanied Champion at its 12-inch boundary")
		check(C.UnitAbilities.damage(state, champion, 3) == 2 and C.UnitAbilities.damage(state, champion, 1) == 1 and C.UnitAbilities.damage(state, champion, 0) == 0, "Armour of Faith reduces attack Damage by 1 to a minimum of 1")
		check(C.UnitAbilities.damage(state, champion, 3, "mortal") == 3, "Armour of Faith does not reduce mortal wounds")
		state.phase = "charge"
		check(C.UnitAbilities.charge_modifier(state, champion_squad) == 1, "Sigismund’s Heir adds 1 to the Champion’s own Charge roll")
		state.phase = "deployment"
		C.UnitActions.reconcile(state)
		var bodyguard_squad := int(state.units[model_for(state, "intercessor-squad", 1)].squad)
		var attach_choice := option(state, 1, "attach", "", bodyguard_squad, champion)
		var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
		check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and state.units[champion].get("attachment_role", "") == "leader", "The Champion attaches to a source-listed Intercessor unit through the public preparation command")
		check(not C.UnitAbilities.lone_operative_active(state, champion) and C.UnitAbilities.charge_modifier(state, bodyguard_squad) == 1, "The standalone protection ends on attachment while the Leader’s Charge bonus reaches its joined unit")
		var warlord := option(state, 1, "warlord", "", -1, champion)
		check(not warlord.is_empty(), "The Character is offered as a Warlord in army preparation")
	else:
		check(false, "Both-player current-catalog fixture materializes: %s" % str(state.get("error", "")))

	if failures == 0: print("Emperor’s Champion checks: passed")
	else: print("Emperor’s Champion checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

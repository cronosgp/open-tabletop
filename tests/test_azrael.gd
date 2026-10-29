extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "azrael"
const UNIT_ID := "40kdc:11e:adeptus-astartes:azrael"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5), entry("bladeguard-veteran-squad", 3)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("captain"), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections())

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String, owner: int) -> int:
	var found := models(state, identity, owner)
	return int(state.units[found[0]].squad) if not found.is_empty() else -1

func option(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for item: Dictionary in U.choices(state, player):
		if str(item.get("action", "")) != action: continue
		if model >= 0 and int(item.get("model", -1)) != model: continue
		if target >= 0 and int(item.get("target", -1)) != target: continue
		if not value.is_empty() and str(item.get("value", "")) != value: continue
		return item
	return {}

func weapon(profile: Dictionary, category: String, identity: String) -> Dictionary:
	for item: Dictionary in profile.get(category, []):
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get("standard", {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000218" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Azrael identifies the pinned Dark Angels App datasheet")
	check(profile.get("points_by_models", {}) == {1: 150} and profile.get("models") == 1 and profile.get("max_supported_copies", 0) == 1, "Azrael's one-model 150-point Epic Hero composition and copy cap match the export")
	check(profile.get("base_size_source_mm") == 50 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 25.0 / 25.4), "Azrael uses the source 50 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "M6/T5/Sv2+/W6/Ld6+/OC1 and the Lion Helm's 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["INFANTRY", "CHARACTER", "CHAPTER MASTER", "EPIC HERO", "EXPLOSIVES", "DEATHWING", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "DARK ANGELS"], "All datasheet and faction keywords are represented")
	check(weapon(profile, "ranged", "lions-wrath") == {"name": "Lion's Wrath", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 8, "ap": -3, "damage": 2, "keywords": {"rapid-fire": 1, "devastating-wounds": true, "anti-infantry": 4}}, "Lion's Wrath preserves its source profile and weapon traits")
	check(weapon(profile, "melee", "sword-of-secrets") == {"name": "The Sword of Secrets", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -4, "damage": 2, "keywords": {"devastating-wounds": true}}, "The Sword of Secrets preserves its source profile")
	check(profile.get("default_loadout_by_role", {}).get("Azrael", {}) == {"Lion's Wrath": 1, "The Lion Helm": 1, "The Sword of Secrets": 1}, "The fixed source loadout is represented")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "masterful-tactician", "supreme-grand-master", "watcher-in-the-dark"], "Core, Army and datasheet abilities are assigned")
	for ability: String in ["masterful-tactician", "supreme-grand-master", "watcher-in-the-dark", "the-lion-helm"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z"), "%s has aligned source and ability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 150 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Azrael is in the current construction and roster-price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 150}], "The construction catalog exposes Azrael at 150 points")
	var excess := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(excess.get("error", "")).is_empty(), "The local catalog rejects a second Azrael")

	var expected_targets: Array[String] = ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "hellblaster-squad", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad", "inner-circle-companions"]
	check(LeaderLinks.targets(UNIT).size() == expected_targets.size() and expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "Azrael retains all eight source-listed Leader targets")
	check(LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == expected_targets.size(), "The attachment catalog includes all eight source-listed targets")
	for target: String in expected_targets:
		check(Catalog.SPECS.get(target, {}).get("current_reference", false), "Leader target %s is present in the current construction catalog" % target)

	var state := fixture()
	check(not state.has("error"), "Both current Marine rosters materialize with Azrael: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Azrael checks: %d failures" % (failures + 1))
		quit(1)
		return
	var azrael_models := models(state, UNIT, 1)
	var guards := models(state, "intercessor-squad", 1)
	var blades := models(state, "bladeguard-veteran-squad", 1)
	var enemies := models(state, "intercessor-squad", 2)
	check(azrael_models.size() == 1 and guards.size() == 5 and blades.size() == 3 and not enemies.is_empty(), "The match has Azrael, a five-model Intercessor unit, Bladeguard and an opposing target")
	if azrael_models.is_empty() or guards.is_empty() or blades.is_empty() or enemies.is_empty():
		print("Azrael checks: %d failures" % (failures + 1))
		quit(1)
		return
	var azrael: int = azrael_models[0]
	var azrael_squad := int(state.units[azrael].squad)
	var guard_squad := int(state.units[guards[0]].squad)
	var blade_squad := int(state.units[blades[0]].squad)
	var target_squad := int(state.units[enemies[0]].squad)
	var attach := option(state, 1, "attach", azrael, guard_squad)
	var attach_result := PublicUnitCommand.submit(state, 1, attach)
	check(not attach.is_empty() and str(attach_result.get("error", "")).is_empty() and int(state.units[azrael].squad) == guard_squad, "Azrael attaches to a source-listed Intercessor unit through the public Leader action")
	check("DEATHWING" in state.units[azrael].get("keywords", []) and A.has(state, guard_squad, "leader") and A.has(state, guard_squad, "masterful-tactician"), "Dark Angels context and Azrael's Leader abilities are present after attachment (keywords=%s, abilities_enabled=%s, source=%s, squad=%s)" % [str(state.units[azrael].get("keywords", [])), str(A.enabled(state)), str(AbilityCatalog.RULES.get(A.identity(state.units[azrael]), [])), str(A.sources(state, guard_squad, "leader"))])
	check(A.has(state, guard_squad, "supreme-grand-master") and A.has(state, guard_squad, "watcher-in-the-dark"), "The attached unit receives Supreme Grand Master and Watcher abilities")
	var intercessor := guards[0]
	var bolt_rifle: Dictionary = state.units[intercessor].ranged_weapons[0].get("profiles", {}).values()[0]
	var melee_weapon: Dictionary = state.units[intercessor].melee_weapons[0].get("profiles", {}).values()[0]
	check(int(A.weapon(state, intercessor, target_squad, bolt_rifle, false).keywords.get("sustained-hits", 0)) == 1 and int(A.weapon(state, intercessor, target_squad, melee_weapon, true).keywords.get("sustained-hits", 0)) == 1, "Azrael's attached bodyguards gain Sustained Hits 1 on ranged and melee attacks")
	var stronger_sustained := bolt_rifle.duplicate(true)
	stronger_sustained.keywords["sustained-hits"] = 2
	check(int(A.weapon(state, intercessor, target_squad, stronger_sustained, false).keywords.get("sustained-hits", 0)) == 2, "Supreme Grand Master does not reduce a higher Sustained Hits value")

	state.phase = "movement"
	state.turn = 1
	state.active = 1
	state.units[azrael].position = Vector2(-12, 0)
	for model: int in C.living(state, blade_squad): state.units[model].position = Vector2(-5, 0)
	var tactician := option(state, 1, "masterful-tactician", azrael, blade_squad, "assault")
	check(not tactician.is_empty(), "Masterful Tactician offers a doctrine for a visible friendly Astartes unit within 9 inches")
	if not tactician.is_empty():
		var army_used_before: Array = state.combat_doctrines.used.get(1, []).duplicate()
		var tactician_result := PublicUnitCommand.submit(state, 1, tactician)
		check(str(tactician_result.get("error", "")).is_empty() and Doctrines.has_doctrine(state, blade_squad, "assault"), "Masterful Tactician activates the selected doctrine for the target unit")
		check(state.combat_doctrines.used.get(1, []) == army_used_before and str(state.combat_doctrines.active.get(1, "")).is_empty(), "Azrael's unit-specific doctrine does not consume or set the army-wide doctrine")
		check(option(state, 1, "masterful-tactician", azrael, blade_squad, "assault").is_empty(), "Masterful Tactician cannot be used twice in one Movement phase")
		state.phase = "command"
		state.active = 2
		A.start_command(state)
		check(Doctrines.has_doctrine(state, blade_squad, "assault"), "The doctrine remains active through the opponent's Command phase")
		state.active = 1
		A.start_command(state)
		check(not Doctrines.has_doctrine(state, blade_squad, "assault"), "The doctrine ends at the start of Azrael's next Command phase")

	state.phase = "shooting"
	state.active = 2
	state.pending_attack = {"current": {"phase": "damage", "target": guard_squad, "cursor": 0, "steps": [{"kind": "devastating"}]}}
	state.unit_abilities.window = {"kind": C.DetachmentStratagems.LAYERED_CERAMITE_WINDOW, "owners": [1], "squad": guard_squad}
	var watcher := option(state, 1, "watcher-in-dark", -1, guard_squad, "summon")
	check(not watcher.is_empty(), "The defender can summon the Watcher when Azrael's unit faces a mortal-wound packet")
	if not watcher.is_empty():
		var watcher_result := PublicUnitCommand.submit(state, 1, watcher)
		check(str(watcher_result.get("error", "")).is_empty() and state.unit_abilities.watcher_active.get(guard_squad, false), "The Watcher grants its unit the active mortal-wound protection")
		var bodyguard_rules: Array = Prevention.rules(state, guards[0])
		check({"target": 4, "against": "mortal"} in bodyguard_rules and {"target": 4, "against": "mortal"} in Prevention.rules(state, azrael), "Feel No Pain 4+ applies to Azrael and attached bodyguards")
		var mortal := WoundPrevention.resolve(1, 2, bodyguard_rules, "mortal", func() -> int: return 4)
		var ordinary := WoundPrevention.resolve(1, 2, bodyguard_rules, "normal", func() -> int: return 1)
		check(mortal.get("error", "").is_empty() and int(mortal.get("prevented", 0)) == 1 and ordinary.get("error", "").is_empty() and int(ordinary.get("lost", 0)) == 1, "The Watcher prevents mortal wounds on 4+ and does not prevent ordinary wounds")
		check(option(state, 1, "watcher-in-dark", -1, guard_squad, "summon").is_empty(), "The Watcher cannot be summoned twice for the same unit")
	state.unit_abilities.window = {}
	state.pending_attack = {}

	if failures == 0: print("Azrael source-bounded local checks passed")
	else: print("Azrael checks: %d failures" % failures)
	quit(1 if failures else 0)

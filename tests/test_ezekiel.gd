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
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const PhobosLibrarian = preload("res://scripts/edition_11/phobos_librarian.gd")
const Ezekiel = preload("res://scripts/edition_11/ezekiel.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "ezekiel"
const UNIT_ID := "40kdc:11e:adeptus-astartes:ezekiel"

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections(bodyguard: bool = false) -> Dictionary:
	var friendly: Array = [entry(UNIT)]
	if bodyguard: friendly.append(entry("inner-circle-companions", 3))
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": friendly},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture(bodyguard: bool = false) -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": true, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections(bodyguard))

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String, owner: int) -> int:
	var found := models(state, identity, owner)
	return int(state.units[found[0]].squad) if not found.is_empty() else -1

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000226" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Ezekiel cites the pinned Dark Angels App export identity")
	check(profile.get("points_by_models", {}) == {1: 110} and profile.get("max_supported_copies", 0) == 1, "The one-model 110-point Epic Hero and single-copy limit match the export")
	check(profile.get("psychic_level", 0) == 3, "Chief Librarian records the source PSYKER Level 3")
	check(profile.get("base_size_source_mm") == 25 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 12.5 / 25.4), "Ezekiel's 25 mm source base is represented")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "M6/T5/Sv2+/W5/Ld6+/OC1 and 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "PSYKER", "LIBRARIAN", "DEATHWING", "IMPERIUM", "TACTICUS"], "All eleven source keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Ezekiel", {}) == {"Mind Wipe": 1, "The Deliverer": 1, "Traitor's Bane": 1}, "The fixed source loadout is represented")
	check(profile.get("ranged", []).size() == 2 and profile.ranged[0].profiles.size() == 2, "Mind Wipe's two psychic modes and The Deliverer are in the ranged inventory")
	check(profile.ranged[0].profiles.focused == {"name": "Mind Wipe - Focused Witchfire", "range_inches": 12.0, "attacks": 1, "skill": 2, "strength": 6, "ap": -2, "damage": "D3+3", "keywords": {"devastating-wounds": true, "hazardous": true, "precision": true, "psychic": true, "anti-character": 4, "close-quarters": true}}, "Focused Mind Wipe preserves its sourced profile and traits")
	check(profile.ranged[0].profiles.witchfire.keywords == {"devastating-wounds": true, "precision": true, "close-quarters": true, "psychic": true} and profile.ranged[1].profiles.standard.name == "The Deliverer", "Witchfire and The Deliverer retain their source traits")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Traitor's Bane", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {"precision": true, "psychic": true}}, "Traitor's Bane preserves its source melee profile")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "book-of-salvation", "chief-librarian", "psychic-hood", "engulfing-fear", "whispers-of-the-shadow-forest"], "Leader, doctrines, Warlord and all Ezekiel abilities are assigned")
	for ability: String in ["book-of-salvation", "chief-librarian", "psychic-hood", "engulfing-fear", "whispers-of-the-shadow-forest"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z"), "%s has aligned source and capability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 110 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Ezekiel is admitted to the current construction and roster-price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 110}], "The local construction catalog exposes Ezekiel at 110 points")
	var two_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not two_copies.get("error", "").is_empty(), "Incursion rejects a second Ezekiel copy")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 12.5 / 25.4}, "Current construction resolves the exported base")

	var targets: Array[String] = ["assault-intercessor-squad", "bladeguard-veteran-squad", "hellblaster-squad", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad", "inner-circle-companions"]
	check(LeaderLinks.targets(UNIT).size() == targets.size() and targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "All seven source-listed Ezekiel Leader targets are represented")
	check(LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == targets.size(), "The current attachment catalog includes Ezekiel's seven source targets")

	var state := fixture(true)
	check(not state.has("error"), "Both armies materialize Ezekiel, Inner Circle Companions and Intercessors: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Ezekiel checks: %d failures" % (failures + 1))
		quit(1)
		return
	var ezekiel_models := models(state, UNIT, 1)
	var companions := models(state, "inner-circle-companions", 1)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	check(ezekiel_models.size() == 1 and companions.size() == 3 and enemy_intercessors.size() == 5, "Current rosters materialize all models required by the scope")
	if ezekiel_models.is_empty() or companions.is_empty() or enemy_intercessors.is_empty():
		print("Ezekiel checks: %d failures" % (failures + 1))
		quit(1)
		return
	var ezekiel_model := ezekiel_models[0]
	var ezekiel_squad := int(state.units[ezekiel_model].squad)
	var companion_squad := squad_for(state, "inner-circle-companions", 1)
	var attach_choice := option(state, 1, "attach", "", companion_squad)
	attach_choice.model = ezekiel_model
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[ezekiel_model].squad) == companion_squad, "Ezekiel attaches to Inner Circle Companions through the public Leader command")
	check(UnitPrevention.grants(state, companion_squad).has({"target": 4, "against": "psychic"}) and UnitPrevention.grants(state, companion_squad).has({"target": 4, "against": "mortal"}), "Ezekiel grants his attached unit both Psychic Hood prevention types")
	var weapon_state := fixture(false)
	var weapon_source: int = models(weapon_state, UNIT, 1)[0]
	var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(weapon_state, profile, weapon_source, squad_for(weapon_state, "intercessor-squad", 2))
	check(weapon_failures.is_empty(), "Every Ezekiel weapon mode resolves through Equipment and AttackPlan: %s" % str(weapon_failures))
	var traitors_bane: Dictionary = profile.melee[0].profiles.standard
	check(C.UnitAbilities.melee_bonus(state, companion_squad) == 1 and C.UnitAbilities.melee_attack_count(state, ezekiel_model, traitors_bane) == 5, "Book of Salvation grants one melee attack to the attached unit")
	check(C.UnitAbilities.weapon(state, companions[0], squad_for(state, "intercessor-squad", 2), traitors_bane, true).attacks == 5, "AttackPlan applies the Book of Salvation attack to bodyguard melee")

	var fear_state := fixture(true)
	if not fear_state.has("error"):
		var fear_source: int = models(fear_state, UNIT, 1)[0]
		var fear_squad := int(fear_state.units[fear_source].squad)
		var fear_target := squad_for(fear_state, "intercessor-squad", 2)
		fear_state.units[fear_source].position = Vector2.ZERO
		for model: int in C.living(fear_state, fear_target): fear_state.units[model].position = Vector2(5.0, 0.0)
		fear_state.phase = "shooting"
		fear_state.active = 1
		var fear_use := option(fear_state, 1, "engulfing-fear", "use")
		dice_queue = [1]
		var fear_used := PublicUnitCommand.submit(fear_state, 1, fear_use, Vector2.ZERO, Callable(self, "roll_die"))
		check(fear_used.get("error", "").is_empty() and fear_state.squads[fear_squad].battle_shocked and fear_state.unit_abilities.window.get("kind", "") == "engulfing-fear-target", "A failed psychic roll Battle-shocks Ezekiel's unit and still resolves the selected power")
		var target_choice := option(fear_state, 1, Ezekiel.TARGET_WINDOW, "target", fear_target)
		dice_queue = [4, 3]
		var target_result := PublicUnitCommand.submit(fear_state, 1, target_choice, Vector2.ZERO, Callable(self, "roll_die"))
		check(target_result.get("error", "").is_empty() and not fear_state.squads[fear_target].battle_shocked and fear_state.last_engulfing_fear.get("modified_total", -1) == 6, "Engulfing Fear applies -1 to the enemy Battle-shock result")
		check(option(fear_state, 1, "engulfing-fear").is_empty(), "Engulfing Fear cannot be used a second time in the same phase")

	var incoming := fixture(true)
	if not incoming.has("error"):
		var incoming_source: int = models(incoming, UNIT, 1)[0]
		var defender_squad := int(incoming.units[incoming_source].squad)
		var attacker := models(incoming, "intercessor-squad", 2)[0]
		var attacker_squad := int(incoming.units[attacker].squad)
		incoming.units[incoming_source].position = Vector2.ZERO
		for model: int in C.living(incoming, defender_squad): incoming.units[model].position = Vector2.ZERO
		for model: int in C.living(incoming, attacker_squad): incoming.units[model].position = Vector2(5.0, 0.0)
		incoming.phase = "shooting"
		incoming.active = 2
		incoming.unit_abilities.setup_players = [1, 2]
		incoming.terrain.areas = []
		incoming.mission.objectives = []
		var ranged: Dictionary = incoming.units[attacker].ranged_weapons[0]
		var profile_id := str(ranged.profiles.keys()[0])
		var declaration := [{"model": attacker, "target": defender_squad, "amount": 1, "weapon": ranged.id, "profile": profile_id}]
		dice_queue = [1]
		var declared := C.resolve_attack_plan(incoming, 2, attacker, declaration, incoming.revision, false, false, Callable(self, "roll_die"))
		check(declared.get("error", "").is_empty() and incoming.unit_abilities.window.get("kind", "") == "phobos-shrouding", "An enemy attack opens Whispers before attack dice")
		var whispers := option(incoming, 1, "phobos-shrouding", "whispers", defender_squad)
		check(not whispers.is_empty(), "The defender receives Ezekiel's Whispers choice")
		dice_queue = [4, 1]
		var whispers_result := PublicUnitCommand.submit(incoming, 1, whispers, Vector2.ZERO, Callable(self, "roll_die"))
		var whispers_modifier := C.UnitAbilities.hit_bonus(incoming, attacker_squad, defender_squad, false)
		check(whispers_result.get("error", "").is_empty() and whispers_modifier == -1, "A successful Whispers roll applies -1 to incoming Hit rolls through the phase")
		check(not incoming.squads[defender_squad].battle_shocked and not PhobosLibrarian.whispers_available(incoming, defender_squad), "Successful Whispers remains safe and cannot repeat in the same phase")

	print("Ezekiel checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "deathwing-knights"
const UNIT_ID := "40kdc:11e:adeptus-astartes:deathwing-knights"
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
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 5), entry("belial"), entry("ancient-in-terminator-armour")]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections())

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

func submit(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "", point: Vector2 = Vector2.ZERO) -> String:
	var selected := option(state, player, action, model, target, value)
	if selected.is_empty(): return "Missing %s choice (model=%d target=%d value=%s)." % [action, model, target, value]
	return str(PublicUnitCommand.submit(state, player, selected, point).get("error", ""))

func weapon(profile: Dictionary, category: String, identity: String) -> Dictionary:
	for item: Dictionary in profile.get(category, []):
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get("standard", {})
	for item: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get("standard", {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000231" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Deathwing Knights identifies the pinned Dark Angels App datasheet")
	check(profile.get("points_by_models", {}) == {5: 255} and profile.get("third_plus_points_by_models", {}) == {5: 275} and profile.get("models") == 5 and profile.get("max_supported_copies", 0) == 3, "The fixed five-model composition, copy-price tiers and three-copy cap match the export")
	check(profile.get("base_size_source_mm") == 40 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 40.0 / 50.8), "Every model uses the source 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "M5/T6/Sv2+/W4/Ld6+/OC1 and 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TERMINATOR", "DEATHWING", "IMPERIUM"], "All datasheet and faction keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Knight Master", {}) == {"Great Weapon of the Unforgiven": 1} and profile.get("default_loadout_by_role", {}).get("Deathwing Knights", {}) == {"Mace of Absolution": 1}, "The Knight Master and four regular Knights retain their distinct defaults")
	check(profile.get("ranged", []).is_empty(), "The datasheet has no ranged weapons")
	check(weapon(profile, "melee", "great-weapon-of-the-unforgiven") == {"name": "Great Weapon of the Unforgiven", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {"devastating-wounds": true, "sustained-hits": 1}}, "Great Weapon of the Unforgiven matches its source profile")
	check(weapon(profile, "melee", "mace-of-absolution") == {"name": "Mace of Absolution", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {"anti-monster": 4, "anti-vehicle": 4}}, "Mace of Absolution retains Anti-MONSTER/VEHICLE 4+")
	check(weapon(profile, "melee", "power-weapon").get("attacks") == 5 and weapon(profile, "melee", "relic-weapon").get("strength") == 7 and weapon(profile, "melee", "relic-weapon").get("keywords", {}).get("lethal-hits", false), "Both replacement weapons match the exported Attack, Strength and keyword values")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["deep-strike", "teleport-homer", "combat-doctrines", "inner-circle", "watcher-in-the-dark"], "Deep Strike, Teleport Homer, Army ability and both datasheet abilities are assigned")
	for ability: String in ["inner-circle", "teleport-homer", "watcher-in-the-dark"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z") and capability.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "%s is source-linked and locally closed in the capability registry" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("models", 0) == 5 and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 255, "Deathwing Knights is admitted by the locally validated current-reference and points catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(not current_choice.is_empty() and not current_choice.get("options", []).is_empty(), "The consolidated local catalog exposes the five-model Deathwing Knights profile")

	for link: Array in [["belial", "Belial"], ["captain-in-terminator-armour", "Terminator Captain"], ["chaplain-in-terminator-armour", "Terminator Chaplain"], ["librarian-in-terminator-armour", "Terminator Librarian"]]:
		check(UNIT in LeaderLinks.targets(str(link[0])), "%s retains its source-listed Leader link" % str(link[1]))
	check(UNIT in Supports.BODYGUARDS.get("ancient-in-terminator-armour", []), "Ancient in Terminator Armour retains its source Support relation")
	check(Catalog.SPECS.get("deathwing-terminator-squad", {}).get("current_reference", false), "Deathwing Terminator Squad is now an available source-listed Leader target")

	var state := fixture()
	check(not state.has("error"), "Deathwing Knights and both current Marine rosters materialize: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Deathwing Knights checks: %d failures" % (failures + 1))
		quit(1)
		return
	var knight_models := models(state, UNIT, 1)
	var belial_models := models(state, "belial", 1)
	var ancient_models := models(state, "ancient-in-terminator-armour", 1)
	var enemy_models := models(state, "intercessor-squad", 2)
	check(knight_models.size() == 5 and belial_models.size() == 1 and ancient_models.size() == 1 and enemy_models.size() == 5, "The materialized unit has five Knights, Belial, a Terminator Ancient and an enemy target")
	if knight_models.size() != 5 or belial_models.is_empty() or ancient_models.is_empty() or enemy_models.is_empty():
		print("Deathwing Knights checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := int(state.units[knight_models[0]].squad)
	var master := knight_models[0]
	var regular := knight_models[1]
	var belial := belial_models[0]
	var ancient := ancient_models[0]
	var enemy := int(state.units[enemy_models[0]].squad)
	check(state.units[master].get("sergeant", false) and state.units[master].melee_weapons[0].id == "great-weapon-of-the-unforgiven" and state.units[regular].melee_weapons[0].id == "mace-of-absolution", "The mixed Knight Master/Deathwing Knight defaults materialize on the correct models")
	check("DEATHWING" in state.units[master].keywords, "Dark Angels Chapter context restores the source Deathwing keyword")
	check(not A.has(state, squad, "watcher-in-the-dark"), "The optional Watcher begins unequipped and grants no ability")
	check(submit(state, 1, "deathwing-knights-melee", master, squad, "relic-weapon").is_empty() and state.units[master].melee_weapons[0].id == "relic-weapon", "The Knight Master can replace only the Great Weapon with the Relic Weapon")
	check(submit(state, 1, "deathwing-knights-melee", regular, squad, "power-weapon").is_empty() and state.units[regular].melee_weapons[0].id == "power-weapon", "A regular Knight can independently replace its Mace with a Power Weapon")
	check(option(state, 1, "deathwing-knights-melee", master, squad, "power-weapon").is_empty() and option(state, 1, "deathwing-knights-melee", regular, squad, "relic-weapon").is_empty(), "Each role is limited to its source-listed melee replacements")
	check(submit(state, 1, "deathwing-knights-watcher", -1, squad, "on").is_empty() and A.has(state, squad, "watcher-in-the-dark"), "The optional Watcher can be equipped once during army preparation")
	check(submit(state, 1, "deathwing-knights-watcher", -1, squad, "off").is_empty() and not A.has(state, squad, "watcher-in-the-dark"), "The optional Watcher can be removed again during preparation")
	check(submit(state, 1, "deathwing-knights-watcher", -1, squad, "on").is_empty(), "The final Watcher loadout can be equipped for the mortal-wound response check")
	check(submit(state, 1, "warlord", belial).is_empty(), "Belial can be selected as Warlord while the Knights are in the roster")
	check(submit(state, 1, "attach", belial, squad).is_empty() and int(state.units[belial].squad) == squad, "Belial attaches to Deathwing Knights through the source Leader relation")
	check(submit(state, 1, "attach", ancient, squad).is_empty() and int(state.units[ancient].squad) == squad and str(state.units[ancient].get("attachment_role", "")) == "support", "Ancient in Terminator Armour attaches in its Support role")
	check(A.has(state, squad, "inner-circle") and A.damage(state, regular, 3) == 2 and A.damage(state, regular, 1) == 1 and A.damage(state, belial, 3) == 2 and A.damage(state, regular, 3, "mortal") == 3, "Inner Circle reduces attack Damage by 1 to a minimum of 1 across the attached unit and leaves mortal wounds unchanged")

	C.DetachmentStratagems.enable_terminator_storm(state)
	state.combat_doctrines.detachments[1] = "terminator-storm-force"
	state.phase = "shooting"
	state.active = 2
	var fortitude_error := C.DetachmentStratagems.terminator_fortitude_error(state, 1, squad, enemy, false)
	check(fortitude_error.contains("Inner Circle"), "Inner Circle blocks Tactical Dreadnought Fortitude even though the unit is a Terminator")

	state.pending_attack = {"current": {"phase": "damage", "target": squad, "cursor": 0, "steps": [{"kind": "devastating"}]}}
	state.unit_abilities.window = {"kind": C.DetachmentStratagems.LAYERED_CERAMITE_WINDOW, "owners": [1], "squad": squad}
	var watcher := option(state, 1, "watcher-in-dark", -1, squad, "summon")
	check(not watcher.is_empty(), "The equipped Watcher is offered when this unit receives mortal wounds")
	if not watcher.is_empty():
		var watcher_result := PublicUnitCommand.submit(state, 1, watcher)
		check(str(watcher_result.get("error", "")).is_empty() and state.unit_abilities.watcher_active.get(squad, false), "The Watcher becomes active through the public reaction action")
		check({"target": 4, "against": "mortal"} in Prevention.rules(state, regular) and {"target": 4, "against": "mortal"} in Prevention.rules(state, belial), "The Watcher grants Feel No Pain 4+ against mortal wounds to Knights and attached Leaders")
		check(option(state, 1, "watcher-in-dark", -1, squad, "summon").is_empty(), "The Watcher cannot be summoned twice for this unit")
	state.pending_attack = {}
	state.unit_abilities.window = {}

	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = []
	state.phase = "start_turn"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.unit_abilities.phase_key = U.key(state)
	var zones: Dictionary = state.deployment.get("zones", {})
	var homer_point: Vector2 = (zones.get(2, Rect2(Vector2(8, 0), Vector2(8, 8))) as Rect2).get_center()
	var homer_error := submit(state, 1, "homer", -1, squad, "", homer_point)
	check(U.battle_actor(state) == 1 and homer_error.is_empty(), "The owner can set Deathwing Knights' one Teleport Homer at the start of battle: actor=%d error=%s" % [U.battle_actor(state), homer_error])
	check(state.unit_abilities.homers.get(squad, Vector2.INF) == homer_point and option(state, 1, "homer", -1, squad).is_empty(), "The Teleport Homer token is saved once for that unit")
	state.unit_abilities.reserves[squad] = {"cost": int(state.squads[squad].training_cost), "source": "strategic-reserves", "deep_strike": true}
	for model: int in knight_models + [belial, ancient]: state.units[model].on_battlefield = false
	state.phase = "movement"
	state.active = 2
	state.turn = 4
	state.round = 2
	state.unit_abilities.phase_key = U.key(state)
	state.unit_abilities.end_done = ""
	state.unit_abilities.window = {}
	var ingress_error := C.advance_phase(state, 2, state.revision)
	check(ingress_error.is_empty() and U.pending(state).get("kind", "") == "end", "The opposing Movement phase opens the Rapid Ingress response window: %s" % ingress_error)
	check(not option(state, 1, "homer-ingress", -1, squad).is_empty(), "The saved token enables the zero-CP Rapid Ingress option for Deathwing Knights")

	if failures == 0: print("Deathwing Knights source-bounded local checks passed")
	else: print("Deathwing Knights checks: %d failures" % failures)
	quit(1 if failures else 0)

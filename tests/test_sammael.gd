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
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "sammael"
const UNIT_ID := "40kdc:11e:adeptus-astartes:sammael"

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("outrider-squad", 3), entry("ravenwing-black-knights", 3)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5), entry("roboute-guilliman"), entry("repulsor")]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "escape_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "ULTRAMARINES"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

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
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000002291" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Sammael cites the pinned Dark Angels App export")
	check(profile.get("points_by_models", {}) == {1: 120} and profile.get("max_supported_copies", 0) == 1 and profile.get("base_size_source_mm") == 60, "The one-model 120-point Epic Hero and 60 mm base match the source")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 7, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}, "Sammael's characteristics and invulnerable save match the source")
	check(profile.get("keywords", []) == ["DARK ANGELS", "ADEPTUS ASTARTES", "EPIC HERO", "FLY", "RAVENWING", "IMPERIUM", "FRAME", "EXPLOSIVES", "MOUNTED", "CAPTAIN", "CHARACTER", "MOBILE"], "Source-listed keywords and the runtime MOBILE classification tag are represented")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return w.id) == ["bolt-pistol", "master-crafted-plasma-cannon", "twin-storm-bolter"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return w.id) == ["the-raven-sword"], "All four fixed weapon profiles are catalogued")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "cut-off-their-escape", "grand-master-of-the-ravenwing"], "Sammael has Leader, Army Rule and both datasheet abilities")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 120 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "The current construction and roster-price catalogs admit one Sammael")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 120}], "The local construction catalog exposes Sammael at 120 points")
	check(not Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]}).get("error", "").is_empty(), "The roster rejects a second Sammael")
	var targets: Array[String] = ["outrider-squad", "ravenwing-black-knights"]
	check(LeaderLinks.targets(UNIT) == targets and LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == 2, "Both source Leader links are present in the runtime catalogs")
	for ability: String in ["cut-off-their-escape", "grand-master-of-the-ravenwing"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("supported", false) and capability.get("category", "") == Registry.CATEGORY_UNIT, "%s is declared in the capability registry" % ability)

	var state := fixture()
	check(not state.has("error"), "Both Dark Angels rosters materialize Sammael and source targets: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var sammael_models := models(state, UNIT, 1)
	var outriders := squad_for(state, "outrider-squad", 1)
	var black_knights := squad_for(state, "ravenwing-black-knights", 1)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	var guilliman := models(state, "roboute-guilliman", 2)
	var repulsor := models(state, "repulsor", 2)
	check(sammael_models.size() == 1 and enemy_intercessors.size() == 5 and not guilliman.is_empty() and not repulsor.is_empty(), "All local current-catalog test units materialize")
	var sammael := sammael_models[0]
	check(C.UnitActions.attachment_allowed(state, sammael, outriders) and C.UnitActions.attachment_allowed(state, sammael, black_knights), "Sammael can lead Outriders and Ravenwing Black Knights")
	var warlord_choice := option(state, 1, "warlord", "", -1, sammael)
	var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
	check(not warlord_choice.is_empty() and warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == sammael, "Sammael is eligible for Warlord designation through the public preparation command")
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants its Warlord Command Point at battle-round start")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Sammael grants the Warlord CP only once per battle round")
	var leader_choice := option(state, 1, "attach", "", outriders, sammael)
	var attached := PublicUnitCommand.submit(state, 1, leader_choice)
	check(not leader_choice.is_empty() and attached.get("error", "").is_empty() and int(state.units[sammael].squad) == outriders, "Sammael attaches to Outriders through the public preparation command")
	check(C.UnitAbilities.has(state, outriders, "cut-off-their-escape") and C.UnitAbilities.has(state, outriders, "grand-master-of-the-ravenwing"), "Sammael's unit abilities stay available after attachment")

	state.phase = "command"
	state.active = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	var doctrine := option(state, 1, "ravenwing-doctrine", "assault", outriders, sammael)
	var doctrine_result := PublicUnitCommand.submit(state, 1, doctrine)
	check(not doctrine.is_empty() and doctrine_result.get("error", "").is_empty() and C.Doctrines.active_for(state, outriders) == "assault", "Grand Master of the Ravenwing selects Assault Doctrine for Sammael's attached unit: %s / choice=%s / sources=%s" % [str(doctrine_result.get("error", "")), str(doctrine), str(C.UnitAbilities.sources(state, outriders, "grand-master-of-the-ravenwing"))])
	check(option(state, 1, "ravenwing-doctrine", "devastator", outriders, sammael).is_empty(), "Sammael cannot select a second doctrine in the same Command phase")
	state.active = 2
	C.UnitAbilities.start_command(state)
	C.Doctrines.start_command(state)
	check(C.Doctrines.active_for(state, outriders) == "assault", "Grand Master doctrine remains active through the opponent's Command phase")
	state.active = 1
	C.UnitAbilities.start_command(state)
	C.Doctrines.start_command(state)
	check(C.Doctrines.active_for(state, outriders).is_empty(), "Grand Master doctrine expires at the start of Sammael's next Command phase")

	var weapon_state := fixture()
	if not weapon_state.has("error"):
		var source := models(weapon_state, UNIT, 1)[0]
		var target := squad_for(weapon_state, "intercessor-squad", 2)
		var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(weapon_state, Profiles.profile(UNIT), source, target)
		check(weapon_failures.is_empty(), "Every Sammael weapon resolves through Equipment and AttackPlan: %s" % str(weapon_failures))

	state.phase = "movement"
	state.active = 2
	state.squads[squad_for(state, "intercessor-squad", 2)].battle_shocked = true
	for model: int in C.living(state, squad_for(state, "intercessor-squad", 2)): state.units[model].position = Vector2(2.0, 0.0)
	state.units[sammael].position = Vector2.ZERO
	var fleeing_squad := squad_for(state, "intercessor-squad", 2)
	var forced_error := C.movement_choice_error(state, 2, enemy_intercessors[0], "ordered_retreat", state.revision)
	check(forced_error.contains("Cut Off Their Escape") and not C.UnitAbilities.sammael_escape_hazard_modifiers(state, fleeing_squad, 5).is_empty(), "Sammael forces a Battle-shocked engaged unit to use Desperate Escape with -1 per hazard die")
	for model: int in guilliman: state.units[model].position = Vector2.ZERO
	var guilliman_squad := int(state.units[guilliman[0]].squad)
	check(C.movement_choice_error(state, 2, guilliman[0], "ordered_retreat", state.revision).is_empty(), "Cut Off Their Escape excludes a MONSTER unit")
	for model: int in repulsor: state.units[model].position = Vector2.ZERO
	var repulsor_squad := int(state.units[repulsor[0]].squad)
	check(C.movement_choice_error(state, 2, repulsor[0], "ordered_retreat", state.revision).is_empty(), "Cut Off Their Escape excludes a VEHICLE unit")
	for model: int in guilliman: state.units[model].position = Vector2(12.0, 0.0)
	for model: int in repulsor: state.units[model].position = Vector2(12.0, 0.0)
	check(state.squads[guilliman_squad].owner == 2 and state.squads[repulsor_squad].owner == 2, "Exemption checks use the selected enemy units")
	state.stratagems.escape_rerolls = true
	dice_queue = [3, 6, 6, 6, 6]
	var escape_error := C.begin_movement(state, 2, enemy_intercessors[0], "desperate_escape", state.revision, Callable(self, "roll_die"))
	check(escape_error.is_empty() and state.pending_move.get("hazard_modifiers", []) == [-1, -1, -1, -1, -1] and state.pending_move.get("hazard_remaining", -1) == 1, "Battle-shock modifies each forced Desperate Escape hazard roll")
	if escape_error.is_empty() and state.stratagems.pending.get("kind", "") == "after_escape_roll":
		var reroll_error := C.resolve_escape_reaction(state, 2, fleeing_squad, "command-re-roll", state.revision, 0, Callable(self, "roll_die"))
		check(reroll_error.is_empty() and state.pending_move.hazard_remaining == 0 and state.pending_move.hazard_modifiers == [-1, -1, -1, -1, -1], "Command Re-roll preserves Sammael's per-die modifier")
		check(state.last_command_roll.get("effective_rolls", []) == [5, 5, 5, 5, 5] and state.last_command_roll.get("hazard_modifiers", []) == [-1, -1, -1, -1, -1], "The final hazard journal records raw results, modifiers and effective results")

	if failures == 0: print("Sammael checks: passed")
	else: print("Sammael checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")

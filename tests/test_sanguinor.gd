extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const CommandBattleShock = preload("res://scripts/edition_11/command_battle_shock.gd")
const LeadershipRerolls = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const SanguinorRules = preload("res://scripts/edition_11/sanguinor.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "the-sanguinor"
const UNIT_ID := "40kdc:11e:adeptus-astartes:the-sanguinor"

var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, model_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections())

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

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func place_others_away(state: Dictionary, except_models: Array) -> void:
	for model: int in state.units:
		if model in except_models: continue
		var column := model % 6
		var row := int(model / 6) % 4
		state.units[model].position = Vector2(-18.0 + float(column) * 6.0, -13.0 + float(row) * 8.0)

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000156" and profile.get("source_snapshot_id") == "20261021T130623Z", "The Sanguinor cites the pinned Blood Angels datasheet identity and export snapshot")
	check(profile.get("points_by_models", {}) == {1: 120} and profile.get("max_supported_copies", 0) == 1, "The Sanguinor is one model at 120 points with a one-copy Epic Hero cap")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "The Sanguinor's characteristics match the local export")
	check(profile.get("base_size_source_mm", 0) == 40 and "JUMP PACK" in profile.get("keywords", []) and "FLY" in profile.get("keywords", []) and "EPIC HERO" in profile.get("keywords", []), "The source base and key movement/character keywords are represented")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Encarmine Broadsword", "range_inches": 0.0, "attacks": 8, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {"devastating-wounds": true}}, "Encarmine Broadsword matches its full source profile")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["deep-strike", "fights-first", "lone-operative", "combat-doctrines", "aura-of-fervour", "miraculous-saviour"], "The Sanguinor's movement, core and datasheet abilities are registered")
	for ability: String in ["aura-of-fervour", "miraculous-saviour"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z"), "%s has source-linked runtime capability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 120 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "The Sanguinor is present in the current catalog and roster points")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 120}], "The local current catalog exposes The Sanguinor at 120 points")
	var duplicate := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(duplicate.get("error", "")).is_empty(), "Incursion admission rejects a second The Sanguinor copy")

	var state := fixture()
	check(not state.has("error"), "Blood Angels test rosters materialize The Sanguinor and Leadership targets: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("The Sanguinor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var sanguinor_models := models(state, UNIT, 1)
	var friendly_models := models(state, "intercessor-squad", 1)
	var enemy_captains := models(state, "captain", 2)
	var enemy_models := models(state, "intercessor-squad", 2)
	check(sanguinor_models.size() == 1 and friendly_models.size() == 5 and enemy_captains.size() == 1 and enemy_models.size() == 5, "The fixture contains a source model, a full friendly unit and enemy charge targets")
	if sanguinor_models.is_empty() or friendly_models.is_empty() or enemy_captains.is_empty():
		print("The Sanguinor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var sanguinor := sanguinor_models[0]
	var friendly_squad := int(state.units[friendly_models[0]].squad)
	var enemy_squad := int(state.units[enemy_captains[0]].squad)
	place_others_away(state, [sanguinor, friendly_models[0], enemy_captains[0]])
	state.units[sanguinor].position = Vector2.ZERO
	var exact_aura_edge := float(state.units[sanguinor].radius) + float(state.units[friendly_models[0]].radius) + 12.0
	for index: int in range(1, friendly_models.size()): state.units[friendly_models[index]].position = Vector2(20.0, 10.0 + float(index))
	state.units[friendly_models[0]].position = Vector2(exact_aura_edge, 0.0)
	check(SanguinorRules.aura_of_fervour_active(state, friendly_squad) and LeadershipRerolls.leadership_reroll_available(state, friendly_squad), "Aura of Fervour includes a friendly ADEPTUS ASTARTES unit exactly 12 inches away")
	state.units[friendly_models[0]].position = Vector2(exact_aura_edge + 0.05, 0.0)
	check(not SanguinorRules.aura_of_fervour_active(state, friendly_squad), "Aura of Fervour excludes a friendly unit just beyond 12 inches")
	state.units[friendly_models[0]].position = Vector2(exact_aura_edge, 0.0)
	state.phase = "command"
	state.active = 1
	state.squads[friendly_squad].battle_shocked = true
	dice = [1, 1, 6, 6]
	var command_roll := CommandBattleShock.resolve_command(state, Callable(self, "roll_die"))
	var reroll_options := CommandBattleShock.choices(state, 1)
	var aura_reroll: Dictionary = {}
	for option: Dictionary in reroll_options:
		if str(option.get("value", "")) == "tempered-in-battle": aura_reroll = option
	check(command_roll.get("pending", false) and str(aura_reroll.get("label", "")).begins_with("Aura of Fervour"), "Command-phase Battle-shock offers the matching Sanguinor Leadership reroll")
	if not aura_reroll.is_empty():
		var reroll_result := CommandBattleShock.resolve(state, 1, aura_reroll, int(state.get("revision", -1)), Callable(self, "roll_die"))
		check(str(reroll_result.get("error", "")).is_empty() and not state.squads[friendly_squad].battle_shocked and state.get("last_morale", []).size() == 1 and state.last_morale[0].get("reroll_source", "") == "Aura of Fervour", "Aura of Fervour replaces both Leadership dice and records the true reroll source")

	state = fixture()
	if state.has("error"):
		print("The Sanguinor checks: %d failures" % (failures + 1))
		quit(1)
		return
	sanguinor_models = models(state, UNIT, 1)
	var reserve_model := sanguinor_models[0]
	var reserve_squad := int(state.units[reserve_model].squad)
	enemy_captains = models(state, "captain", 2)
	enemy_models = models(state, "intercessor-squad", 2)
	enemy_squad = int(state.units[enemy_captains[0]].squad)
	place_others_away(state, [reserve_model, enemy_captains[0]])
	state.units[reserve_model].on_battlefield = false
	state.units[enemy_captains[0]].position = Vector2.ZERO
	state.squads[enemy_squad].charged = true
	state.unit_abilities.reserves[reserve_squad] = {"cost": 120, "source": "player-choice", "deep_strike": true}
	state.phase = "charge"
	state.active = 2
	state.turn = 2
	state.round = 2
	var phase_close := ResolutionFrames.begin(state, "phase-close", "phase-close:2:charge", "after-end-of-phase-decisions")
	check(not phase_close.is_empty(), "The test opens the same phase-close parent frame used by the live Charge boundary")
	var end_opened := C.UnitActions.open_end(state)
	var saviour_choice := choice_for(state, 1, "miraculous-saviour", enemy_squad, reserve_squad, "use")
	check(end_opened and not saviour_choice.is_empty(), "End of the opponent's second-round Charge phase offers the reserve ingress against a unit that charged")
	if not saviour_choice.is_empty():
		var use_result := PublicUnitCommand.submit(state, 1, saviour_choice)
		check(str(use_result.get("error", "")).is_empty() and C.UnitActions.pending(state).get("miraculous_saviour", false), "Using Miraculous Saviour opens its dedicated placement continuation: %s / %s" % [str(use_result), str(C.UnitActions.pending(state))])
		var placement := choice_for(state, 1, "ingress-place", reserve_model, reserve_squad)
		var place_result := PublicUnitCommand.submit(state, 1, placement, Vector2(2.0, 0.0))
		var confirm := choice_for(state, 1, "ingress-confirm")
		var confirm_result := PublicUnitCommand.submit(state, 1, confirm)
		check(not placement.is_empty() and str(place_result.get("error", "")).is_empty() and not confirm.is_empty() and str(confirm_result.get("error", "")).is_empty(), "The Sanguinor can be placed in Engagement Range of the selected charger and confirm ingress: %s / %s / %s" % [str(placement), str(place_result), str(confirm_result)])
		check(state.units[reserve_model].get("on_battlefield", false) and not state.unit_abilities.reserves.has(reserve_squad) and int(state.cp[1]) == 0 and state.unit_abilities.used.get("miraculous-saviour:1", false), "Miraculous Saviour sets up the unit without Rapid Ingress CP and consumes its once-per-army use")
		check(sanguinor_engaged(state, reserve_squad, enemy_squad) and C.UnitActions.pending(state).get("kind", "") == "end", "The confirmed Sanguinor is engaged with the charging unit and returns to the phase-end window")
		check(C.UnitActions.choices(state, 1).all(func(option: Dictionary) -> bool: return option.get("action", "") != "miraculous-saviour"), "The army cannot use Miraculous Saviour a second time")

	if failures == 0: print("The Sanguinor checks: passed")
	else: print("The Sanguinor checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func sanguinor_engaged(state: Dictionary, left: int, right: int) -> bool:
	for model: int in Geometry.alive(state, left):
		for enemy: int in Geometry.alive(state, right):
			if Geometry.within_engagement(state.units[model], state.units[enemy]): return true
	return false

func _initialize() -> void:
	call_deferred("run")

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const MephistonRules = preload("res://scripts/edition_11/mephiston.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "mephiston"
const UNIT_ID := "40kdc:11e:adeptus-astartes:mephiston"

var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func entry(identity: String, model_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": 1}

func selections(include_sanguinor: bool = true) -> Dictionary:
	var opponent: Array = [entry("captain"), entry("intercessor-squad", 5)]
	if include_sanguinor: opponent.append(entry("the-sanguinor"))
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": opponent}
	}

func fixture(include_sanguinor: bool = true) -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections(include_sanguinor))

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func place_others_away(state: Dictionary, keep: Array[int]) -> void:
	for model: int in state.units:
		if model in keep: continue
		var column := model % 6
		var row := int(model / 6) % 4
		state.units[model].position = Vector2(-18.0 + float(column) * 6.0, -13.0 + float(row) * 8.0)

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000021" and profile.get("source_datasheet_id", "") == "000000155" and profile.get("source_snapshot_id", "") == "20261021T130623Z", "Mephiston cites the pinned Blood Angels 11e datasheet and local-export snapshot")
	check(profile.get("points_by_models", {}) == {1: 175} and profile.get("models", 0) == 1 and profile.get("max_supported_copies", 0) == 1, "The one-model 175-point Epic Hero has a single-copy limit")
	check(profile.get("base_size_source_mm", 0) == 40 and profile.get("psychic_level", 0) == 3, "The 40 mm base and Chief Librarian PSYKER Level 3 match the export")
	check(profile.get("stats", {}) == {"movement_inches": 8, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Mephiston's characteristics match the local datasheet export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "BLOOD ANGELS", "TACTICUS", "INFANTRY", "CHARACTER", "EPIC HERO", "PSYKER", "IMPERIUM", "EXPLOSIVES"], "All nine source keywords are represented")
	var ranged: Array = profile.get("ranged", [])
	check(ranged.size() == 2 and ranged[0].profiles.size() == 2 and ranged[1].profiles.size() == 2, "Fury of the Ancients and Plasma Pistol expose all four source profiles")
	if ranged.size() == 2:
		check(ranged[0].profiles.focused == {"name": "Fury of the Ancients - Focused Witchfire", "range_inches": 18.0, "attacks": 3, "skill": 2, "strength": 6, "ap": -2, "damage": 3, "keywords": {"assault": true, "close-quarters": true, "psychic": true, "hazardous": true}}, "Focused Witchfire retains its exact profile and traits")
		check(ranged[0].profiles.witchfire.strength == 5 and ranged[0].profiles.witchfire.ap == -1 and ranged[0].profiles.witchfire.damage == 2, "Witchfire retains its distinct S5/AP-1/D2 profile")
		check(ranged[1].profiles.standard.strength == 7 and ranged[1].profiles.standard.damage == 1 and ranged[1].profiles.supercharge.strength == 8 and ranged[1].profiles.supercharge.damage == 2, "Both Plasma Pistol profiles match the source")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Vitarus", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {"psychic": true, "lethal-hits": true}}, "Vitarus matches its fixed source melee profile")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["feel-no-pain-5", "fights-first", "lone-operative", "combat-doctrines", "transhuman-strategist", "chief-librarian", "quickening", "transfixing-gaze"], "Core, faction and psychic abilities are registered for Mephiston")
	for ability: String in ["feel-no-pain-5", "quickening", "transfixing-gaze"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("supported", false) and str(capability.get("source_status", "")).contains("20261021T130623Z"), "%s links to the pinned 11e export" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 175 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Mephiston is admitted to current construction and points catalogs")
	var choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 1, "cost": 175}], "The local construction catalog exposes Mephiston at 175 points")
	var duplicate := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(duplicate.get("error", "")).is_empty(), "Army admission rejects a second Mephiston")

	var state := fixture()
	check(not state.has("error"), "The current local fixture materializes both Blood Angels armies: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Mephiston checks: %d failures" % (failures + 1))
		quit(1)
		return
	var mephiston := models(state, UNIT, 1)[0]
	var mephiston_squad := int(state.units[mephiston].squad)
	var target_captain := models(state, "captain", 2)[0]
	var target_squad := int(state.units[target_captain].squad)
	var sanguinor := models(state, "the-sanguinor", 2)[0]
	var intercessor := models(state, "intercessor-squad", 1)[0]
	check(C.UnitAbilities.has(state, mephiston_squad, "fights-first") and C.UnitAbilities.has(state, mephiston_squad, "lone-operative"), "Fights First and Lone Operative register on Mephiston's unit")
	check({"target": 5, "against": "any"} in UnitPrevention.rules(state, mephiston), "Mephiston receives Feel No Pain 5+ through the shared wound-prevention resolver")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.round = 1
	Doctrines.select_doctrine(state, 1, "tactical")
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)
	var quickening := choice_for(state, 1, "mephiston-psychic", mephiston, mephiston_squad, "quickening")
	dice = [4]
	var quickening_result := PublicUnitCommand.submit(state, 1, quickening, Vector2.ZERO, Callable(self, "roll_die"))
	check(not quickening.is_empty() and str(quickening_result.get("error", "")).is_empty() and "tactical" in Doctrines.active_doctrines_for(state, mephiston_squad) and "assault" in Doctrines.active_doctrines_for(state, mephiston_squad), "Quickening adds Assault Doctrine alongside the selected Tactical Doctrine")
	state.turn = 2
	check("assault" in Doctrines.active_doctrines_for(state, mephiston_squad), "Quickening persists through the opponent's turn")
	state.turn = 3
	check("assault" not in Doctrines.active_doctrines_for(state, mephiston_squad), "Quickening expires at the start of Mephiston's next Command phase")

	state = fixture()
	mephiston = models(state, UNIT, 1)[0]
	mephiston_squad = int(state.units[mephiston].squad)
	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.round = 1
	Doctrines.select_doctrine(state, 1, "tactical")
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)
	quickening = choice_for(state, 1, "mephiston-psychic", mephiston, mephiston_squad, "quickening")
	dice = [1]
	quickening_result = PublicUnitCommand.submit(state, 1, quickening, Vector2.ZERO, Callable(self, "roll_die"))
	check(str(quickening_result.get("error", "")).is_empty() and state.squads[mephiston_squad].battle_shocked and "assault" not in Doctrines.active_doctrines_for(state, mephiston_squad), "Quickening roll of 1 Battle-shocks Mephiston's unit and grants no doctrine")

	state = fixture()
	mephiston = models(state, UNIT, 1)[0]
	mephiston_squad = int(state.units[mephiston].squad)
	target_captain = models(state, "captain", 2)[0]
	target_squad = int(state.units[target_captain].squad)
	sanguinor = models(state, "the-sanguinor", 2)[0]
	intercessor = models(state, "intercessor-squad", 1)[0]
	place_others_away(state, [mephiston, target_captain, sanguinor, intercessor])
	state.units[mephiston].position = Vector2.ZERO
	var exact_edge := 6.0 + float(state.units[mephiston].radius) + float(state.units[target_captain].radius)
	state.units[target_captain].position = Vector2(exact_edge, 0.0)
	state.units[intercessor].position = Vector2(exact_edge - 0.75, 0.0)
	state.units[sanguinor].position = Vector2(exact_edge + 1.0, 0.0)
	state.phase = "movement"
	state.active = 2
	state.turn = 2
	state.round = 2
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)
	var gaze := choice_for(state, 1, "mephiston-psychic", mephiston, mephiston_squad, "transfixing-gaze")
	dice = [4]
	var gaze_result := PublicUnitCommand.submit(state, 1, gaze, Vector2.ZERO, Callable(self, "roll_die"))
	check(not gaze.is_empty() and str(gaze_result.get("error", "")).is_empty() and MephistonRules.transfixing_gaze_sources(state, target_squad) == [mephiston], "Successful Transfixing Gaze covers an enemy unit exactly 6 inches away at the start of its Movement phase")
	var pass_gaze_window := choice_for(state, 1, "pass")
	var pass_gaze_result := PublicUnitCommand.submit(state, 1, pass_gaze_window)
	check(not pass_gaze_window.is_empty() and str(pass_gaze_result.get("error", "")).is_empty() and C.UnitActions.pending(state).is_empty(), "Mephiston's start-of-phase window closes before the opponent declares movement")
	state.units[target_captain].position.x += 0.02
	check(MephistonRules.transfixing_gaze_sources(state, target_squad).is_empty(), "Transfixing Gaze excludes an enemy unit beyond 6 inches")
	state.units[target_captain].position.x -= 0.02
	check(Geometry.distance_to_target(state, state.units[mephiston], target_squad) <= 6.0 + Geometry.EPSILON, "The fall-back target returns to the inclusive 6-inch boundary")
	dice = [1, 1]
	var begin_error := C.begin_movement(state, 2, target_captain, "ordered_retreat", int(state.revision), Callable(self, "roll_die"))
	var reroll_options := C.UnitActions.choices(state, 2)
	var aura_reroll: Dictionary = {}
	for option: Dictionary in reroll_options:
		if str(option.get("action", "")) == MephistonRules.FALLBACK_WINDOW and str(option.get("value", "")) == "reroll": aura_reroll = option
	check(begin_error.is_empty() and C.UnitActions.pending(state).get("kind", "") == MephistonRules.FALLBACK_WINDOW and not aura_reroll.is_empty() and str(aura_reroll.get("label", "")).begins_with("Aura of Fervour"), "A failed initial Leadership result pauses the Fall Back and offers the target controller's eligible Leadership re-roll (error=%s window=%s options=%s in_range=%s)" % [begin_error, str(C.UnitActions.pending(state)), str(reroll_options), str(MephistonRules.transfixing_gaze_sources(state, target_squad))])
	if not aura_reroll.is_empty():
		dice = [6, 6]
		var reroll_result := PublicUnitCommand.submit(state, 2, aura_reroll, Vector2.ZERO, Callable(self, "roll_die"))
		check(str(reroll_result.get("error", "")).is_empty() and state.pending_move.get("squad", -1) == target_squad and state.pending_move.get("move_type", "") == "ordered_retreat", "A passed re-rolled Leadership test resumes the saved Fall Back move")
		check(state.last_morale.back().get("reroll_source", "") == "Aura of Fervour" and C.UnitActions.pending(state).is_empty(), "The Leadership re-roll source is recorded and its pending window closes")

	state = fixture(false)
	mephiston = models(state, UNIT, 1)[0]
	mephiston_squad = int(state.units[mephiston].squad)
	target_captain = models(state, "captain", 2)[0]
	target_squad = int(state.units[target_captain].squad)
	place_others_away(state, [mephiston, target_captain])
	state.units[mephiston].position = Vector2.ZERO
	state.units[target_captain].position = Vector2(1.5, 0.0)
	state.unit_abilities.mephiston_transfixing_gaze = {mephiston: {"source": mephiston, "owner": 1, "phase_key": "2:movement"}}
	state.phase = "movement"
	state.active = 2
	state.turn = 2
	state.round = 2
	dice = [1, 1]
	begin_error = C.begin_movement(state, 2, target_captain, "ordered_retreat", int(state.revision), Callable(self, "roll_die"))
	check(begin_error.is_empty() and state.squads[target_squad].moved and state.squads[target_squad].move_type == "stationary" and state.pending_move.is_empty(), "A failed Transfixing Gaze Leadership test forces the selected unit to Remain Stationary")

	state = fixture()
	mephiston = models(state, UNIT, 1)[0]
	target_captain = models(state, "captain", 2)[0]
	intercessor = models(state, "intercessor-squad", 1)[0]
	place_others_away(state, [mephiston, target_captain, intercessor])
	state.units[mephiston].position = Vector2(-12.0, 0.0)
	state.units[target_captain].position = Vector2(1.5, 0.0)
	state.units[intercessor].position = Vector2.ZERO
	state.unit_abilities.mephiston_transfixing_gaze = {mephiston: {"source": mephiston, "owner": 1, "phase_key": "2:movement"}}
	state.phase = "movement"
	state.active = 2
	state.turn = 2
	state.round = 2
	begin_error = C.begin_movement(state, 2, target_captain, "ordered_retreat", int(state.revision))
	check(begin_error.is_empty() and state.pending_move.get("squad", -1) == int(state.units[target_captain].squad), "A Fall Back outside the 6-inch range is not intercepted by Transfixing Gaze")

	if failures == 0: print("Mephiston checks: passed")
	else: print("Mephiston checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")

const BLADEGUARD_ID := "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad"
const CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const EXPECTED_WEAPONS := {
	"heavy-bolt-pistol:standard": {"melee": false, "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"neo-volkite-pistol:standard": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": 0, "damage": 2, "keywords": {"close-quarters": true, "devastating-wounds": true}},
	"plasma-pistol:standard": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}},
	"plasma-pistol:supercharge": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}},
	"master-crafted-power-sword:standard": {"melee": true, "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": BLADEGUARD_ID, "models": 3, "copies": 1},
		{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1}
	]
	result[2].entries = [
		{"definition_id": BLADEGUARD_ID, "models": 6, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}
	]
	return result

func make_state() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections())

func find_models(state: Dictionary, owner: int, identity: String) -> Dictionary:
	var result := {"squad": -1, "models": [], "sergeant": -1}
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		result.squad = int(unit.squad)
		result.models.append(model)
		if unit.get("sergeant", false): result.sergeant = model
	return result

func choice_for(state: Dictionary, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, 1):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision: Dictionary = C.UnitActions.pending_decision(state)
	if decision.is_empty(): return {"error": "No current unit choice is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current decision does not offer this equipment choice."}
	return MatchCommandService.execute(state, player, {
		"kind": MatchCommandService.SELECT_UNIT_CHOICE,
		"revision": int(state.get("revision", -1)),
		"choice": {
			"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE,
			"decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")),
			"option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")),
			"choice": selected
		}
	})

func check_weapon_profile(state: Dictionary, model: int, weapon_id: String, profile_id: String) -> void:
	var expected: Dictionary = EXPECTED_WEAPONS["%s:%s" % [weapon_id, profile_id]]
	var selected: Dictionary = Equipment.select(state, model, bool(expected.melee), weapon_id, profile_id)
	check(str(selected.get("error", "")).is_empty(), "%s/%s is available through Equipment" % [weapon_id, profile_id])
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s/%s %s matches the pinned export" % [weapon_id, profile_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s/%s retains its source weapon traits" % [weapon_id, profile_id])

func check_current_weapon_plans(state: Dictionary, model: int, target_squad: int) -> void:
	var loadout := {
		"ranged": state.units[model].get("ranged_weapons", []).duplicate(true),
		"melee": state.units[model].get("melee_weapons", []).duplicate(true)
	}
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, loadout, model, target_squad):
		check(false, failure)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("bladeguard-veteran-squad")
	check(profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000000071",
		"Bladeguard Veteran Squad maps to the shared-book source identity")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"The fixed characteristics include the 4+ invulnerable save")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "The circular movement proxy preserves the source 40 mm base")
	var expected_keywords := ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "Shared-book keywords are retained without the conditional Deathwing keyword")
	check(profile.get("points_by_models", {}) == {3: 90, 6: 180} and profile.get("third_plus_points_by_models", {}) == {3: 110, 6: 200},
		"Both source sizes and the third-plus cost tier match the pinned export")
	check(profile.get("models", -1) == 3 and int(profile.get("max_supported_copies", -1)) == 2,
		"The profile's default size and supported Incursion repetition limit are explicit")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].get("id", "") == "heavy-bolt-pistol" and
		profile.get("melee", []).size() == 1 and profile.melee[0].get("id", "") == "master-crafted-power-sword",
		"The source default loadout is one Heavy Bolt Pistol and one Master-crafted Power Sword per model")
	var catalog_choice := Catalog.current_catalog_choice({"id": BLADEGUARD_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [
		{"models": 3, "cost": 90, "third_plus_cost": 110},
		{"models": 6, "cost": 180, "third_plus_cost": 200}
	], "The consolidated catalog publishes both source sizes and both copy-cost tiers")
	check(Catalog.SPECS.get("bladeguard-veteran-squad", {}).get("current_reference", false),
		"Bladeguard remains available through the consolidated current-reference catalog")
	var admit_three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": BLADEGUARD_ID, "models": 3, "copies": 1}]})
	var admit_six := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": BLADEGUARD_ID, "models": 6, "copies": 1}]})
	var admit_two_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": BLADEGUARD_ID, "models": 3, "copies": 2}]})
	var admit_three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": BLADEGUARD_ID, "models": 3, "copies": 3}]})
	check(admit_three.get("error", "").is_empty() and admit_three.get("total", -1) == 90 and
		admit_six.get("error", "").is_empty() and admit_six.get("total", -1) == 180,
		"Catalog admission accepts the 3- and 6-model source formations at first-two-copy prices")
	check(admit_two_copies.get("error", "").is_empty() and admit_two_copies.get("total", -1) == 180 and
		not admit_three_copies.get("error", "").is_empty(),
		"Incursion accepts two copies and rejects a third under the Core Rules battle-size unit limit")

	var state := make_state()
	check(not state.has("error"), "Current Marine catalogs materialize the Bladeguard roster for both players")
	if state.has("error"):
		print("Bladeguard Veteran Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var attacker := find_models(state, 1, "bladeguard-veteran-squad")
	var defender := find_models(state, 2, "bladeguard-veteran-squad")
	var captain := find_models(state, 1, "captain")
	var intercessors := find_models(state, 2, "intercessor-squad")
	check(attacker.models.size() == 3 and attacker.sergeant >= 0 and defender.models.size() == 6 and defender.sergeant >= 0,
		"Both current catalogs materialize the 3- and 6-model formations with one Sergeant each")
	check(not captain.models.is_empty() and intercessors.models.size() == 5,
		"The opposing current-catalog roster also materializes its Captain and Intercessor target")
	if attacker.models.is_empty() or attacker.sergeant < 0 or defender.models.is_empty():
		print("Bladeguard Veteran Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(state.squads[attacker.squad].stats.toughness == 5 and state.squads[attacker.squad].stats.save_target == 3 and
		state.squads[attacker.squad].stats.invulnerable_target == 4 and state.squads[attacker.squad].stats.objective_control == 1,
		"The materialized squad retains its shared characteristics and 4+ invulnerable save")
	for model: int in attacker.models + defender.models:
		var record: Dictionary = state.units[model]
		check(int(record.get("movement", -1)) == 6 and int(record.get("max_wounds", -1)) == 3 and
			is_equal_approx(float(record.get("radius", 0.0)), 20.0 / 25.4),
			"Each Bladeguard model has the source movement, wounds and 40 mm base proxy")
		check(record.get("ranged_weapons", []).size() == 1 and record.ranged_weapons[0].get("id", "") == "heavy-bolt-pistol" and
			record.get("melee_weapons", []).size() == 1 and record.melee_weapons[0].get("id", "") == "master-crafted-power-sword",
			"Every Bladeguard model starts with the source default weapons")
		for keyword: String in expected_keywords:
			check(Terrain.has_keyword(record, [keyword.to_lower()]), "Each model has the %s keyword" % keyword)

	check(C.UnitActions.attachment_allowed(state, int(captain.models[0]), int(attacker.squad)),
		"A common-book Captain can lead the source-listed Bladeguard bodyguard")
	check_weapon_profile(state, int(attacker.sergeant), "heavy-bolt-pistol", "standard")
	check_weapon_profile(state, int(attacker.sergeant), "master-crafted-power-sword", "standard")
	check_current_weapon_plans(state, int(attacker.sergeant), int(defender.squad))

	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var offered: Array[String] = []
	for option: Dictionary in C.unit_choices(state, 1):
		if str(option.get("action", "")) == "bladeguard-pistol" and int(option.get("model", -1)) == int(attacker.sergeant):
			offered.append(str(option.get("value", "")))
	offered.sort()
	check(offered == ["heavy", "plasma", "volkite"], "Setup offers exactly the Sergeant's three source-listed pistol states, including restoration")
	for model: int in attacker.models:
		if model != attacker.sergeant:
			check(choice_for(state, "bladeguard-pistol", model, "plasma").is_empty(), "Ordinary Veterans cannot take the Sergeant-only pistol replacement")
	var first_choice := choice_for(state, "bladeguard-pistol", int(attacker.sergeant), "volkite")
	var original_state := var_to_bytes(state)
	var current_decision: Dictionary = C.UnitActions.pending_decision(state)
	var wrong_owner := submit_choice(state, 2, first_choice)
	var stale_option := submit_choice(state, 1, first_choice, str(current_decision.get("decision_id", "")), "stale-option-id")
	check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and original_state == var_to_bytes(state),
		"Wrong-owner and stale Sergeant equipment choices leave the roster unchanged")

	for kind: String in ["volkite", "plasma", "heavy"]:
		var selected_choice := choice_for(state, "bladeguard-pistol", int(attacker.sergeant), kind)
		check(not selected_choice.is_empty(), "Setup exposes the Sergeant pistol state %s" % kind)
		if selected_choice.is_empty(): continue
		var result := submit_choice(state, 1, selected_choice)
		check(str(result.get("error", "")).is_empty(), "Public setup accepts the Sergeant pistol state %s" % kind)
		var expected_id := "heavy-bolt-pistol" if kind == "heavy" else "neo-volkite-pistol" if kind == "volkite" else "plasma-pistol"
		check(state.units[attacker.sergeant].ranged_weapons.size() == 1 and state.units[attacker.sergeant].ranged_weapons[0].get("id", "") == expected_id,
			"The public choice changes only the Sergeant's pistol to %s" % expected_id)
		for model: int in attacker.models:
			if model != attacker.sergeant:
				check(state.units[model].ranged_weapons[0].get("id", "") == "heavy-bolt-pistol", "The %s choice leaves ordinary Veterans unchanged" % kind)
		if kind == "volkite":
			check_weapon_profile(state, int(attacker.sergeant), "neo-volkite-pistol", "standard")
		elif kind == "plasma":
			check_weapon_profile(state, int(attacker.sergeant), "plasma-pistol", "standard")
			check_weapon_profile(state, int(attacker.sergeant), "plasma-pistol", "supercharge")
		else:
			check_weapon_profile(state, int(attacker.sergeant), "heavy-bolt-pistol", "standard")
		check_current_weapon_plans(state, int(attacker.sergeant), int(defender.squad))

	print("Bladeguard Veteran Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

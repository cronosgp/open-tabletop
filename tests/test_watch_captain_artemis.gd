extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Artemis = preload("res://scripts/edition_11/watch_captain_artemis.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const ID := "40kdc:11e:adeptus-astartes:watch-captain-artemis"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_one() -> int: return 1
func roll_six() -> int: return 6

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry("watch-captain-artemis"), entry("deathwatch-veterans", 5)]
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "DEATHWATCH", 2: "ULTRAMARINES"}}, lists())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and Abilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func find_choice(state: Dictionary, player: int, action: String, model: int) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model: return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("watch-captain-artemis")
	check(profile.get("source_book_id", "") == "000000035" and profile.get("source_datasheet_id", "") == "000003872" and profile.get("source_export_updated_at", "") == "2026-10-28T23:48:19+03:00", "Artemis is pinned to the current Deathwatch App export")
	check(profile.get("points_by_models", {}) == {1: 75} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 32, "Artemis retains her one-model 75-point Epic Hero composition and 32 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Artemis characteristics match the current export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CAPTAIN", "CHARACTER", "DEATHWATCH", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "KILL TEAM"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All Artemis source keywords are retained")
	var ranged: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(ranged.get("range_inches") == 12.0 and ranged.get("attacks") == 3 and ranged.get("skill") == 0 and ranged.get("strength") == 4 and ranged.get("ap") == -1 and ranged.get("damage") == 1 and ranged.get("keywords", {}) == {"torrent": true, "ignores-cover": true, "devastating-wounds": true, "anti-infantry": 4}, "Hellfire Extremis matches the export, including its auto-hit traits")
	check(melee.get("attacks") == 6 and melee.get("skill") == 2 and melee.get("strength") == 6 and melee.get("ap") == -2 and melee.get("damage") == 2, "Master-crafted Power Weapon matches the export")
	check(Army.SPECS.has("watch-captain-artemis") and AbilityCatalog.RULES.get("watch-captain-artemis", []).has("unstoppable-champion") and Capabilities.supported("tactical-instinct") and Capabilities.supported("unstoppable-champion"), "Artemis's current profile and source abilities are registered")
	check(LeaderLinks.targets("watch-captain-artemis").size() == 3 and "deathwatch-veterans" in LeaderLinks.targets("watch-captain-artemis") and "fortis-kill-team" in LeaderLinks.targets("watch-captain-artemis") and "decimus-kill-team" in LeaderLinks.targets("watch-captain-artemis"), "All three current Deathwatch Leader targets remain available")
	var one_copy := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ID, "models": 1, "copies": 1}]})
	var two_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ID, "models": 1, "copies": 2}]})
	check(one_copy.get("error", "").is_empty() and one_copy.get("total", -1) == 75 and not str(two_copies.get("error", "")).is_empty(), "Construction admits one Artemis and enforces the Epic Hero duplicate limit")

	var state := fresh_state()
	check(not state.has("error"), "Artemis and the opponent army materialize from the consolidated current catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var artemis := model_for(state, 1, "watch-captain-artemis")
		var veteran := model_for(state, 1, "deathwatch-veterans")
		var artemis_squad := squad_for(state, 1, "watch-captain-artemis")
		var veteran_squad := squad_for(state, 1, "deathwatch-veterans")
		var enemy_squad := squad_for(state, 2, "intercessor-squad")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		var attach: Dictionary = {}
		for option: Dictionary in UnitActions.choices(state, 1):
			if str(option.get("action", "")) == "attach" and int(option.get("model", -1)) == artemis and int(option.get("target", -1)) == veteran_squad: attach = option
		var attached := PublicUnitCommand.submit(state, 1, attach)
		check(str(attached.get("error", "")).is_empty() and int(state.units[artemis].get("squad", -1)) == veteran_squad, "Artemis attaches to Deathwatch Veterans through the public preparation choice")
		artemis_squad = int(state.units[artemis].squad)
		check({"target": 6, "against": "any"} in UnitPrevention.rules(state, artemis), "Artemis alone receives her personal 6+ Feel No Pain")
		var artemis_gun := Equipment.select(state, artemis, false, "hellfire-extremis", "standard")
		var veteran_gun := Equipment.select(state, veteran, false, "boltgun", "standard")
		var improved_artemis_gun: Dictionary = Abilities.weapon(state, artemis, enemy_squad, artemis_gun.stats, false)
		var improved_veteran_gun: Dictionary = Abilities.weapon(state, veteran, enemy_squad, veteran_gun.stats, false)
		check(improved_artemis_gun.get("keywords", {}).get("sustained-hits", 0) == 1 and improved_veteran_gun.get("keywords", {}).get("sustained-hits", 0) == 1, "Tactical Instinct grants Sustained Hits 1 to Artemis and her attached unit")
		check(UnitPrevention.rules(state, veteran).is_empty(), "Artemis's personal Feel No Pain does not transfer to her bodyguard")

		state.phase = "fight"
		state.turn = 1
		state.active = 2
		state.fight_actor = 2
		state.unit_abilities.end_done = ""
		for index in range(state.units.size()):
			var model: int = state.units.keys()[index]
			if model == artemis: continue
			state.units[model].position = Vector2(20.0 + float(index % 3) * 2.0, 12.0 + float(index / 3) * 1.5)
		state.units[artemis].position = Vector2.ZERO
		state.units[artemis].wounds = 0
		DetachmentStratagems.record_destroyed(state, artemis)
		check(Artemis.pending(state, 1) and not Artemis.pending(state, 2), "Destroying Artemis creates an end-of-this-phase choice for her owner only")
		check(UnitActions.open_end(state), "The public end-of-phase window opens for Unstoppable Champion")
		var use := find_choice(state, 1, Artemis.USE, artemis)
		check(not use.is_empty(), "The end-of-phase choice offers the optional roll")
		var failed_state: Dictionary = state.duplicate(true)
		var failed := PublicUnitCommand.submit(failed_state, 1, use, Vector2.ZERO, Callable(self, "roll_one"))
		check(str(failed.get("error", "")).is_empty() and bool(failed_state.unit_abilities.used.get("unstoppable-champion-used:1", false)) and failed_state.units[artemis].wounds == 0 and Artemis.choices(failed_state, 1).is_empty(), "A roll of 1 leaves Artemis destroyed and spends the once-per-battle army use")
		var returned := PublicUnitCommand.submit(state, 1, use, Vector2.ZERO, Callable(self, "roll_six"))
		check(str(returned.get("error", "")).is_empty() and state.unit_abilities.window.get("artemis_placement", {}).has("position"), "A 2+ roll opens a saved closest-position continuation")
		var place := find_choice(state, 1, Artemis.PLACE, artemis)
		check(not place.is_empty() and not Artemis.position_error(state, artemis, Vector2(5, 0)).is_empty(), "The placement rejects positions farther from the destruction point than the closest legal point")
		var placed := PublicUnitCommand.submit(state, 1, place, Vector2.ZERO)
		var confirm := find_choice(state, 1, Artemis.CONFIRM, artemis)
		var confirmed := PublicUnitCommand.submit(state, 1, confirm)
		check(str(placed.get("error", "")).is_empty() and str(confirmed.get("error", "")).is_empty() and state.units[artemis].wounds == 3 and state.units[artemis].on_battlefield, "The successful return sets Artemis up with 3 wounds and resumes the phase window")
		check(Artemis.choices(state, 1).is_empty() and bool(state.unit_abilities.used.get("unstoppable-champion-used:1", false)), "The once-per-army ability cannot trigger a second time after Artemis returns")

	if failures == 0: print("Watch Captain Artemis checks: 0 failures")
	else: push_error("Watch Captain Artemis checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

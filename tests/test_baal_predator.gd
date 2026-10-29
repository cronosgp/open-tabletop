extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const BAAL_ID := "40kdc:11e:adeptus-astartes:baal-predator"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	var model := find_model(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func choose_loadout(state: Dictionary, player: int, model: int, category: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "baal-predator-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == category and str(option.get("value", "")) == value:
			return PublicUnitCommand.submit(state, player, option)
	return {"error": "Missing projected Baal Predator choice %d/%s." % [category, value]}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("baal-predator")
	check(profile.get("name") == "Baal Predator" and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000168" and profile.get("source_role") == "Vehicle", "Baal Predator maps to its Blood Angels App datasheet identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5", "Profile records verified parent and Blood Angels slice manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 135} and profile.get("third_plus_points_by_models", {}) == {1: 150} and profile.get("max_supported_copies") == 3 and profile.get("models") == 1, "One-model composition, three-copy limit and copy-tier points match the verified export")
	check(profile.get("base_size_source", "") == "Use model" and str(profile.get("geometry_scope", "")).begins_with("Provisional") and profile.get("damaged_threshold") == 4, "Source-defined Use model geometry stays explicitly provisional and Damaged threshold is retained")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "Characteristics match the local data export")
	check(profile.get("keywords", []) == ["VEHICLE", "FRAME", "IMPERIUM", "SMOKE", "BLOOD ANGELS", "ADEPTUS ASTARTES"], "All six exported keywords are preserved")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["twin-assault-cannon"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["armoured-tracks"], "Fixed primary and melee profiles match the default datasheet loadout")
	check(Catalog.SPECS.get("baal-predator", {}).get("current_reference", false) and Roster.POINTS.get("baal-predator", {}).get("sizes", {}) == {1: 135} and Roster.POINTS.get("baal-predator", {}).get("third_plus_sizes", {}) == {1: 150}, "Baal Predator is admitted through the consolidated catalog with source costs")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": BAAL_ID, "models": 1, "copies": 3}]})
	var four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": BAAL_ID, "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 420 and not four.get("error", "").is_empty(), "Construction applies the 135/135/150 costs and rejects a fourth copy")

	var twin: Dictionary = profile.ranged[0].profiles.standard
	var tracks: Dictionary = profile.melee[0].profiles.standard
	check(twin.get("range_inches") == 24.0 and twin.get("attacks") == 6 and twin.get("skill") == 3 and twin.get("strength") == 6 and twin.get("ap") == -2 and twin.get("damage") == 1 and twin.get("keywords", {}) == {"sustained-hits": 1, "twin-linked": true, "assault": true}, "Twin Assault Cannon keeps its exact source profile and traits")
	check(tracks.get("name") == "Armoured Tracks" and tracks.get("attacks") == 3 and tracks.get("skill") == 4 and tracks.get("strength") == 6 and tracks.get("ap") == 0 and tracks.get("damage") == 1, "Armoured Tracks matches the exported melee profile")
	var cannon_set := Profiles.baal_predator_weapons("baal-flamestorm-cannon", "heavy-bolters", true, true)
	check(cannon_set.map(func(w: Dictionary) -> String: return str(w.id)) == ["baal-flamestorm-cannon", "heavy-bolter-sponson-left", "heavy-bolter-sponson-right", "storm-bolter", "hunter-killer-missile"], "Flamestorm cannon, paired Heavy Bolters and both optional weapons form a valid package")
	var flamer_set := Profiles.baal_predator_weapons("twin-assault-cannon", "heavy-flamers")
	check(flamer_set.map(func(w: Dictionary) -> String: return str(w.id)) == ["twin-assault-cannon", "heavy-flamer-sponson-left", "heavy-flamer-sponson-right"] and Profiles.baal_predator_weapons("twin-assault-cannon", "heavy-bolters+heavy-flamers").is_empty(), "Sponson packages equip exactly two matching weapons and reject mixed pairs")
	var cannon_profile: Dictionary = profile.additional_weapon_profiles.ranged.filter(func(w: Dictionary) -> bool: return w.id == "baal-flamestorm-cannon")[0].profiles.standard
	var bolter_profile: Dictionary = profile.additional_weapon_profiles.ranged.filter(func(w: Dictionary) -> bool: return w.id == "heavy-bolter-sponson-left")[0].profiles.standard
	var flamer_profile: Dictionary = profile.additional_weapon_profiles.ranged.filter(func(w: Dictionary) -> bool: return w.id == "heavy-flamer-sponson-left")[0].profiles.standard
	var storm_profile: Dictionary = profile.additional_weapon_profiles.ranged.filter(func(w: Dictionary) -> bool: return w.id == "storm-bolter")[0].profiles.standard
	var missile_profile: Dictionary = profile.additional_weapon_profiles.ranged.filter(func(w: Dictionary) -> bool: return w.id == "hunter-killer-missile")[0].profiles.standard
	check(cannon_profile.get("range_inches") == 18.0 and cannon_profile.get("attacks") == 6 and cannon_profile.get("skill") == 0 and cannon_profile.get("strength") == 6 and cannon_profile.get("ap") == -2 and cannon_profile.get("damage") == 2 and cannon_profile.get("keywords", {}) == {"blast": 2, "torrent": true, "assault": true}, "Baal Flamestorm Cannon matches source")
	check(bolter_profile.get("range_inches") == 36.0 and bolter_profile.get("attacks") == 3 and bolter_profile.get("skill") == 3 and bolter_profile.get("strength") == 5 and bolter_profile.get("ap") == -1 and bolter_profile.get("damage") == 2 and bolter_profile.get("keywords", {}) == {"sustained-hits": 1, "rapid-fire": 2, "assault": true}, "Heavy Bolter sponson matches source")
	check(flamer_profile.get("range_inches") == 12.0 and flamer_profile.get("attacks") == 3 and flamer_profile.get("skill") == 0 and flamer_profile.get("strength") == 5 and flamer_profile.get("ap") == -1 and flamer_profile.get("damage") == 1 and flamer_profile.get("keywords", {}) == {"blast": 2, "assault": true, "torrent": true}, "Heavy Flamer sponson matches source")
	check(storm_profile.get("range_inches") == 24.0 and storm_profile.get("attacks") == 2 and storm_profile.get("skill") == 3 and storm_profile.get("strength") == 5 and storm_profile.get("ap") == -1 and storm_profile.get("damage") == 1 and storm_profile.get("keywords", {}) == {"rapid-fire": 2, "assault": true}, "Storm Bolter matches source")
	check(missile_profile.get("range_inches") == 48.0 and missile_profile.get("attacks") == 1 and missile_profile.get("skill") == 2 and missile_profile.get("strength") == 14 and missile_profile.get("ap") == -3 and missile_profile.get("damage") == "D3+3" and missile_profile.get("keywords", {}) == {"assault": true, "one-shot": true}, "Hunter-killer Missile matches source")

	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry("baal-predator"), entry("intercessor-squad", 5)]
	lists[2].entries = [entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, lists)
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Blood Angels roster materializes from the current local catalog: " + materialization_error)
	if not materialization_error.is_empty():
		quit(1)
		return
	var model := find_model(state, 1, "baal-predator")
	var squad := find_squad(state, 1, "baal-predator")
	check(model >= 0 and squad >= 0, "Admitted profile materializes as a Baal Predator unit")
	if model < 0 or squad < 0:
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var initial_points := int(state.training_points.get(1, 0))
	var initial_choices: Array = C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "baal-predator-loadout")
	check(initial_choices.size() == 5, "Army preparation offers the cannon, mutually exclusive sponson package and two optional weapons")
	var cannon_choice := choose_loadout(state, 1, model, 0, "baal-flamestorm-cannon")
	var sponson_choice := choose_loadout(state, 1, model, 1, "heavy-bolters")
	var storm_choice := choose_loadout(state, 1, model, 2, "on")
	var missile_choice := choose_loadout(state, 1, model, 3, "on")
	check(cannon_choice.get("error", "").is_empty() and sponson_choice.get("error", "").is_empty() and storm_choice.get("error", "").is_empty() and missile_choice.get("error", "").is_empty(), "All source-listed Baal Predator choices apply through the public army-preparation command")
	var expected_ranged := ["baal-flamestorm-cannon", "heavy-bolter-sponson-left", "heavy-bolter-sponson-right", "storm-bolter", "hunter-killer-missile"]
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id)) == expected_ranged, "Prepared weapon instances contain the selected cannon, a paired sponson set and optional weapons")
	var before_invalid := var_to_bytes(state.units[model].ranged_weapons)
	var invalid_choice := C.UnitActions.apply(state, 1, {"action": "baal-predator-loadout", "model": model, "target": 1, "value": "mixed-sponsons"}, Vector2.ZERO, func() -> int: return 1)
	check(not str(invalid_choice.get("error", "")).is_empty() and var_to_bytes(state.units[model].ranged_weapons) == before_invalid, "Unknown sponson packages are rejected without changing the loadout")
	var switched_sponsons := choose_loadout(state, 1, model, 1, "heavy-flamers")
	check(switched_sponsons.get("error", "").is_empty() and state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id)) == ["baal-flamestorm-cannon", "heavy-flamer-sponson-left", "heavy-flamer-sponson-right", "storm-bolter", "hunter-killer-missile"], "Changing sponson package replaces both weapons and cannot retain a mixed pair")
	var remove_storm := choose_loadout(state, 1, model, 2, "off")
	var remove_missile := choose_loadout(state, 1, model, 3, "off")
	check(remove_storm.get("error", "").is_empty() and remove_missile.get("error", "").is_empty() and state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id)) == ["baal-flamestorm-cannon", "heavy-flamer-sponson-left", "heavy-flamer-sponson-right"], "Optional Storm Bolter and Hunter-killer Missile can be removed during preparation")
	check(int(state.training_points.get(1, 0)) == initial_points, "Source-listed wargear choices do not add unexported points")

	check(AbilityCatalog.RULES.get("baal-predator", []) == ["damaged-4", "deadly-demise-d3", "combat-doctrines", "overcharged-engines"] and Capabilities.supported("overcharged-engines") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "damaged-4") and C.UnitAbilities.has(state, squad, "deadly-demise-d3") and C.UnitAbilities.has(state, squad, "overcharged-engines"), "Source-linked abilities are registered and Overcharged Engines is enabled within its tested scope")
	check(C.UnitAbilities.deadly_demise_value(state, model) == "D3", "Deadly Demise retains its D3 value")
	state.units[model].wounds = 4
	check(C.UnitAbilities.damaged_attack_penalty(state, model) == -1, "Damaged 4 applies at four remaining wounds")
	state.units[model].wounds = 5
	check(C.UnitAbilities.damaged_attack_penalty(state, model) == 0, "Damaged 4 does not apply above four remaining wounds")
	state.units[model].wounds = int(state.units[model].max_wounds)

	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "movement"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.resolution_frames = []
	state.stratagems.pending = {}
	state.stratagems.movement_rerolls = false
	for member: int in state.units:
		state.units[member].on_battlefield = true
		state.units[member].position = Vector2(-12, 8) if int(state.units[member].owner) == 1 else Vector2(12, 8)
	state.squads[squad].moved = false
	var cp_before := int(state.cp.get(1, 0))
	var advance_error := C.begin_movement(state, 1, model, "advance", int(state.revision), func() -> int: return 2)
	var window: Dictionary = C.Stratagems.pending(state)
	check(advance_error.is_empty() and window.get("kind", "") == "after_advance_roll" and window.get("overcharged_engines", false), "Baal Predator opens a post-Advance roll decision for Overcharged Engines")
	var decision := C.Stratagems.pending_decision(state)
	var option: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("value", "")) == "overcharged-engines": option = candidate
	check(not option.is_empty(), "Pending decision exposes the free Overcharged Engines re-roll")
	if not option.is_empty():
		var choice := {"action": "stratagem-reaction", "model": -1, "target": squad, "value": "overcharged-engines", "die": -1}
		var envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", "")), "choice": choice}
		var reaction := MatchCommands.execute(state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": envelope, "revision": int(state.revision)}, func() -> int: return 5)
		check(str(reaction.get("error", "")).is_empty() and int(state.cp.get(1, 0)) == cp_before and state.pending_move.get("bonus", -1) == 5 and state.last_command_roll.get("source", "") == "overcharged-engines", "Overcharged Engines uses the host's re-roll, applies the new Advance and costs 0 CP")
		check(state.stratagems.get("uses", []).is_empty(), "Overcharged Engines is not recorded as a stratagem use")

	print("Baal Predator source-bounded checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

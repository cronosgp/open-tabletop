extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const ListRoster = preload("res://scripts/army_roster.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const UNIT := "invader-atvs"
const UNIT_ID := "40kdc:11e:adeptus-astartes:invader-atvs"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 10), entry(UNIT, 1), entry(UNIT, 2)]
	return result

func fixture(chapters: Dictionary = {}) -> Dictionary:
	var options: Dictionary = {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}
	if not chapters.is_empty(): options.marine_chapters = chapters.duplicate(true)
	var state: Dictionary = F.P.initial_state(options, lists())
	if state.has("error"): return state
	state.unit_abilities.setup_players = [2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.terrain.areas = []
	for model: int in state.units: state.units[model].position = Vector2(40, 40) if state.units[model].owner == 1 else Vector2(-40, -40)
	return state

func find_squad(state: Dictionary, owner: int, identity: String, occurrence: int = 0) -> int:
	var matches: Array[int] = []
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner: continue
		var ids: Array[int] = Geometry.alive(state, squad)
		if not ids.is_empty() and C.UnitAbilities.identity(state.units[ids[0]]) == identity: matches.append(squad)
	return matches[occurrence] if occurrence < matches.size() else -1

func models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = Geometry.alive(state, squad)
	result.sort()
	return result

func profile_weapon(profile: Dictionary, category: String, identity: String, profile_id: String = "standard", additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for weapon: Dictionary in rows:
		if str(weapon.get("id", "")) == identity:
			return weapon.get("profiles", {}).get(profile_id, {})
	return {}

func choice_for(options: Array, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func submit_loadout(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No current Invader ATV preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current Invader ATV decision does not offer this loadout."}
	return Commands.execute(state, player, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}})

func check_profile(profile: Dictionary) -> void:
	check(profile.get("name", "") == "Invader ATVs" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000004247" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile identifies the shared-book datasheet and pinned local export")
	check(profile.get("points_by_models", {}) == {1: 65, 2: 130} and profile.get("third_plus_points_by_models", {}) == {1: 75, 2: 140} and profile.get("wargear_costs", {}) == {"multi-melta": 5}, "Both source sizes, third-plus prices, and each Multi-melta surcharge match the export")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "M10/T6/Sv3+/W8/Ld6+/OC2 and no invulnerable save match the datasheet")
	check(profile.get("base_size_source", "") == "Use model" and "proxy" in str(profile.get("base_geometry", "")) and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 45.0 / 25.4), "The runtime labels its oval collision footprint as a proxy; the source gives no fixed base size")
	var keywords: Array = profile.get("keywords", [])
	check(keywords == ["VEHICLE", "MOUNTED", "RAVENWING", "IMPERIUM", "FRAME", "ADEPTUS ASTARTES"], "Exported source keywords are preserved for contextual processing")
	check(profile.get("ranged", []).size() == 3 and profile.get("melee", []).size() == 1 and profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1, "Every fixed and optional weapon profile is represented")
	check(profile_weapon(profile, "ranged", "bolt-pistol") == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol profile matches the source")
	check(profile_weapon(profile, "ranged", "onslaught-gatling-cannon") == {"name": "Onslaught Gatling Cannon", "range_inches": 24.0, "attacks": 8, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"devastating-wounds": true}, "target_restricted_traits": {"devastating-wounds": ["MONSTER", "VEHICLE"]}}, "Onslaught Gatling Cannon stats and non-MONSTER/VEHICLE restriction match the source")
	check(profile_weapon(profile, "ranged", "twin-bolt-rifle") == {"name": "Twin Bolt Rifle", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"twin-linked": true, "assault": true, "rapid-fire": 2}}, "Twin Bolt Rifle profile and traits match the source")
	check(profile_weapon(profile, "ranged", "multi-melta", "standard", true) == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}, "Optional Multi-melta profile matches the source")
	check(profile_weapon(profile, "melee", "armoured-impact") == {"name": "Armoured Impact", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Impact profile matches the source")

func check_catalog_and_links() -> void:
	var choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 1, "cost": 65, "third_plus_cost": 75}, {"models": 2, "cost": 130, "third_plus_cost": 140}], "The consolidated catalog offers both source model counts and copy-price tiers")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 65, 2: 130} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {1: 75, 2: 140} and Roster.POINTS.get(UNIT, {}).get("wargear_costs", {}) == {"multi-melta": 5}, "Roster price authority matches the pinned extraction")
	var three_report := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [entry(UNIT, 2), entry(UNIT, 2), entry(UNIT, 2)]})
	check(three_report.get("error", "").is_empty() and int(three_report.get("total", -1)) == 400, "Third Invader ATVs use the 140-point two-model tier")
	var saved_list := ListRoster.new_list("11e", "Space Marines", "custom", 1000)
	saved_list.entries.append({"unit_id": UNIT_ID, "name": "Invader ATVs", "edition": "11e", "faction": "Space Marines", "role": "Other units", "models": 2, "cost": 130, "third_plus_cost": 140, "copies": 3, "source_digest": Profiles.digest()})
	check(ListRoster.summary(saved_list).points == 400 and ListRoster.entry_cost(saved_list.entries, 0) == 400, "Saved roster summaries apply the third-plus tier to grouped copies")
	saved_list.entries[0].copies = 2
	var third_row: Dictionary = saved_list.entries[0].duplicate(true)
	third_row.copies = 1
	saved_list.entries.append(third_row)
	check(ListRoster.summary(saved_list).points == 400 and ListRoster.entry_cost(saved_list.entries, 1) == 140, "Saved summaries apply the tier when copies use split rows")
	var leaders: Array[String] = []
	for identity: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[identity] and not SupportAttachments.BODYGUARDS.has(identity): leaders.append(identity)
	var supports: Array[String] = []
	for identity: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[identity]: supports.append(identity)
	check(leaders.is_empty() and supports.is_empty(), "The exported datasheet has no Leader or Support attachment links")

func check_aggressive_reconnaissance(state: Dictionary, attacking_unit: int, attacker_model: int, target: int, other_enemy: int, target_owner: int) -> void:
	var target_models := models(state, target)
	var other_models := models(state, other_enemy)
	check(not target_models.is_empty() and not other_models.is_empty(), "Aggressive Reconnaissance fixture has living target and comparison units")
	if target_models.is_empty() or other_models.is_empty(): return
	for model: int in Geometry.alive(state, attacking_unit): state.units[model].position = Vector2.ZERO
	for model: int in target_models: state.units[model].position = Vector2(14, 0)
	for model: int in other_models: state.units[model].position = Vector2(45, 0)
	state.phase = "shooting"
	state.active = int(state.squads[attacking_unit].owner)
	state.turn = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	check(C.UnitAbilities.aggressive_reconnaissance_active(state, attacking_unit, target), "An enemy unit more than 6 inches from every other enemy receives the ability condition")
	var plan: Dictionary = C.AttackPlan.prepare(state, attacking_unit, false, [{"model": attacker_model, "target": target, "weapon": "onslaught-gatling-cannon", "profile": "standard", "amount": 1}], false)
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1 and int(plan.batches[0].context.get("wound_modifier", 0)) == 1, "The prepared ranged attack records +1 to wound against the isolated target: %s" % str(plan.get("error", "")))
	var target_model: Dictionary = state.units[target_models[0]]
	var other_model: Dictionary = state.units[other_models[0]]
	var edge_boundary := 6.0 + float(target_model.radius) + float(other_model.radius)
	for model: int in other_models: state.units[model].position = target_model.position + Vector2(edge_boundary + 0.01, 0)
	check(is_equal_approx(Geometry.distance_to_target(state, target_model, other_enemy), 6.01) and C.UnitAbilities.aggressive_reconnaissance_active(state, attacking_unit, target), "The +1 condition remains active when another enemy is 6.01 inches from the target edge")
	for model: int in other_models: state.units[model].position = target_model.position + Vector2(edge_boundary, 0)
	check(is_equal_approx(Geometry.distance_to_target(state, target_model, other_enemy), 6.0) and not C.UnitAbilities.aggressive_reconnaissance_active(state, attacking_unit, target), "The +1 condition ends at the source 6-inch edge-to-edge boundary")
	for model: int in other_models: state.units[model].position = target_model.position + Vector2(edge_boundary - 0.01, 0)
	plan = C.AttackPlan.prepare(state, attacking_unit, false, [{"model": attacker_model, "target": target, "weapon": "onslaught-gatling-cannon", "profile": "standard", "amount": 1}], false)
	check(plan.get("error", "").is_empty() and plan.batches.size() == 1 and int(plan.batches[0].context.get("wound_modifier", 0)) == 0, "A nearby enemy removes the modifier from the prepared attack: %s" % str(plan.get("error", "")))
	state.active = target_owner
	check(not C.UnitAbilities.aggressive_reconnaissance_active(state, attacking_unit, target), "The ability is unavailable during the opponent's Shooting phase")
	state.phase = "overwatch"
	state.active = int(state.squads[attacking_unit].owner)
	check(not C.UnitAbilities.aggressive_reconnaissance_active(state, attacking_unit, target), "The ability is limited to the controlling player's Shooting phase and excludes Overwatch")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check_profile(profile)
	check_catalog_and_links()
	var state := fixture()
	check(not state.has("error"), "Both players materialize current Marine catalogs with both ATV sizes: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Invader ATVs local checks: %d failures" % (failures + 1))
		quit(1)
		return
	var atv_two := find_squad(state, 1, UNIT, 1)
	var atv_one := find_squad(state, 1, UNIT, 0)
	var enemy_one := find_squad(state, 2, UNIT, 0)
	var enemy_two := find_squad(state, 2, UNIT, 1)
	var target := find_squad(state, 2, "intercessor-squad", 0)
	var other_enemy := find_squad(state, 2, "intercessor-squad", 1)
	var player_two_target := find_squad(state, 1, "intercessor-squad", 0)
	var player_two_other := find_squad(state, 1, "intercessor-squad", 1)
	var atvs := models(state, atv_two)
	check(atv_one > 0 and atv_two > 0 and enemy_one > 0 and enemy_two > 0 and atvs.size() == 2 and models(state, atv_one).size() == 1 and models(state, enemy_one).size() == 1 and models(state, enemy_two).size() == 2 and C.UnitAbilities.has(state, atv_two, "aggressive-reconnaissance") and C.UnitAbilities.has(state, atv_one, "aggressive-reconnaissance") and C.UnitAbilities.has(state, enemy_two, "aggressive-reconnaissance"), "Both current catalogs construct one- and two-model ATVs with Aggressive Reconnaissance")
	var no_chapter_ravenwing := true
	for model: int in models(state, atv_two): no_chapter_ravenwing = no_chapter_ravenwing and "RAVENWING" not in state.units[model].get("keywords", [])
	check(no_chapter_ravenwing, "RAVENWING is removed from the prepared shared profile outside Dark Angels context")
	var dark_angels_state := fixture({1: "DARK ANGELS", 2: "DARK ANGELS"})
	var dark_angels_atv := find_squad(dark_angels_state, 1, UNIT, 1)
	var dark_angels_models := models(dark_angels_state, dark_angels_atv)
	check(not dark_angels_state.has("error") and not dark_angels_models.is_empty() and "RAVENWING" in dark_angels_state.units[dark_angels_models[0]].get("keywords", []), "Dark Angels Chapter context grants RAVENWING to the mounted ATV")
	if atv_two <= 0 or target <= 0 or other_enemy <= 0 or atvs.size() != 2:
		print("Invader ATVs local checks: %d failures" % (failures + 1))
		quit(1)
		return
	for index: int in atvs.size(): state.units[atvs[index]].position = Vector2.ZERO
	for model: int in models(state, atv_one): state.units[model].position = Vector2(-30, 0)
	var single_atv_models := models(state, atv_one)
	var fixed_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, single_atv_models[0], target)
	check(fixed_weapon_failures.is_empty(), "Every default ranged and melee profile resolves through Equipment and AttackPlan: %s melee=%s" % [str(fixed_weapon_failures), str(state.units[atvs[0]].get("melee_weapons", []))])

	var setup := C.UnitActions.choices(state, 1)
	var multi_one := choice_for(setup, "invader-atv-gun", atvs[0], "multi-melta")
	var multi_two := choice_for(setup, "invader-atv-gun", atvs[1], "multi-melta")
	var prep_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_loadout := var_to_bytes(state)
	var wrong_owner := submit_loadout(state, 2, multi_one)
	var stale_option := submit_loadout(state, 1, multi_one, str(prep_decision.get("decision_id", "")), "stale-option")
	check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and before_loadout == var_to_bytes(state), "Wrong-owner and stale ATV loadout commands are rejected without mutation")
	check(not multi_one.is_empty() and submit_loadout(state, 1, multi_one).get("error", "").is_empty(), "The first ATV independently replaces its cannon through the public command")
	setup = C.UnitActions.choices(state, 1)
	multi_two = choice_for(setup, "invader-atv-gun", atvs[1], "multi-melta")
	check(not multi_two.is_empty() and submit_loadout(state, 1, multi_two).get("error", "").is_empty(), "The second ATV independently replaces its cannon through the public command")
	check(state.squads[atv_two].training_cost == 140 and state.units[atvs[0]].ranged_weapons[1].id == "multi-melta" and state.units[atvs[1]].ranged_weapons[1].id == "multi-melta", "Two Multi-meltas each add 5 points and replace the Onslaught cannon")
	var selected_melta: Dictionary = Equipment.select(state, atvs[0], false, "multi-melta", "standard")
	check(selected_melta.get("error", "").is_empty() and selected_melta.get("stats", {}) == profile_weapon(profile, "ranged", "multi-melta", "standard", true), "The selected Multi-melta resolves through Equipment with its source profile")
	setup = C.UnitActions.choices(state, 1)
	var restore := choice_for(setup, "invader-atv-gun", atvs[0], "onslaught")
	check(not restore.is_empty() and submit_loadout(state, 1, restore).get("error", "").is_empty() and state.squads[atv_two].training_cost == 135, "Restoring one cannon refunds exactly one Multi-melta surcharge")

	check_aggressive_reconnaissance(state, atv_two, atvs[0], target, other_enemy, 2)
	check(player_two_target > 0 and player_two_other > 0, "The second player's current Marine targets are materialized for both catalogs")

	print("Invader ATVs local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

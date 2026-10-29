extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Pending = preload("res://scripts/edition_11/pending_decision_registry.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UNIT := "land-speeder-vengeance"
const UNIT_ID := "40kdc:11e:adeptus-astartes:land-speeder-vengeance"

var failures := 0
var rolls: Array[int] = []

func die() -> int:
	return rolls.pop_front() if not rolls.is_empty() else 1

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func weapon(profile: Dictionary, category: String, id: String, mode: String = "standard", additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for item: Dictionary in rows:
		if str(item.get("id", "")) == id: return item.get("profiles", {}).get(mode, {})
	return {}

func selection() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1, "enhancement_id": Enhancements.NIGHTFORGED_BATTERY})
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
	return result

func prepared() -> Dictionary:
	var options := {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "hazard_rerolls": true,
		"reanimation_protocols": true, "awakened_dynasty": true,
		"manual_allocation": false,
		"marine_detachments": {1: Enhancements.DARKFLIGHT, 2: "tacticus-attack-force"},
		"marine_chapters": {1: "DARK ANGELS"}
	}
	var state: Dictionary = F.P.initial_state(options, selection())
	if state.has("error"): return state
	state.terrain.areas = []
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.awakened_dynasty.setup_done = true
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "command"
	state.active = 1
	state.turn = 2
	state.round = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.cp = {1: 3, 2: 3}
	for model: int in state.units:
		state.units[model].position = Vector2(-18, -14) if int(state.units[model].owner) == 1 else Vector2(18, 14)
	return state

func destroyed_vengeance_state() -> Dictionary:
	var state := prepared()
	if state.has("error"): return state
	var vengeance := squads(state, UNIT, 1)
	var enemies := squads(state, "intercessor-squad", 2)
	if vengeance.is_empty() or enemies.size() < 2: return {"error": "The Vengeance and two enemy test units are required."}
	var model := models(state, vengeance[0])[0]
	place(state, vengeance[0], Vector2.ZERO)
	place(state, enemies[0], Vector2(5, 0))
	place(state, enemies[1], Vector2(8, 0))
	state.units[model].wounds = 0
	state._test_vengeance_model = model
	return state

func squads(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var found: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if C.UnitAbilities.identity(unit) != identity or int(unit.owner) != owner: continue
		var squad := int(unit.squad)
		if squad not in found: found.append(squad)
	found.sort()
	return found

func models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = C.living(state, squad)
	result.sort()
	return result

func place(state: Dictionary, squad: int, position: Vector2) -> void:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad: state.units[model].position = position

func unit_choice(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action or int(option.get("target", -1)) != target or int(option.get("model", -1)) != model: continue
		if str(option.get("value", "")) != value: continue
		return option
	return {}

func submit_choice(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	var decision := Pending.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			projected = option
			break
	var selected := unit_choice(state, int(decision.get("priority_player_id", player)), action, target, model, value)
	if projected.is_empty() or selected.is_empty(): return {"error": "No current projected %s choice for target %d/model %d." % [action, target, model]}
	var payload := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, die)

func run() -> void:
	var original_status := str(Catalog.SPECS.get(UNIT, {}).get("validation_status", ""))
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	if original_status in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]:
		check(catalog_choice.is_empty(), "The Vengeance stays out of new construction choices while local checks are pending")

	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000242" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00", "The Vengeance profile identifies its pinned Dark Angels 11e export row")
	check(profile.get("points_by_models", {}) == {1: 150} and profile.get("third_plus_points_by_models", {}) == {1: 160} and profile.get("models") == 1 and profile.get("base_size_source", "") == "60mm flying base", "One-model composition, source base and first/second versus third-plus costs match the export")
	check(profile.get("stats", {}) == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5}, "M14/T9/Sv3+/W11/Ld6+/OC3/5++ match the export")
	check(profile.get("keywords", []) == ["VEHICLE", "SPEEDER", "FRAME", "FLY", "RAVENWING", "IMPERIUM", "ADEPTUS ASTARTES", "DARK ANGELS"], "All datasheet and faction keywords are represented")
	check(weapon(profile, "ranged", "heavy-bolter") == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}}, "Heavy Bolter profile and traits match the export")
	check(weapon(profile, "ranged", "plasma-storm-battery", "standard") == {"name": "Plasma Storm Battery - Standard", "range_inches": 36.0, "attacks": "D3+3", "skill": 3, "strength": 9, "ap": -2, "damage": 2, "keywords": {"blast": 1, "twin-linked": true}}, "Standard Plasma Storm Battery profile matches the export")
	check(weapon(profile, "ranged", "plasma-storm-battery", "supercharge") == {"name": "Plasma Storm Battery - Supercharge", "range_inches": 36.0, "attacks": "D3+3", "skill": 3, "strength": 10, "ap": -3, "damage": 3, "keywords": {"blast": 1, "twin-linked": true, "hazardous": true}}, "Supercharge profile and Hazardous trait match the export")
	check(weapon(profile, "ranged", "assault-cannon", "standard", true) == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}}, "The Heavy Bolter replacement profile matches the export")
	check(weapon(profile, "melee", "armoured-hull") == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull profile matches the export")
	check(profile.get("ranged", []).map(func(item: Dictionary) -> String: return item.id) == ["heavy-bolter", "plasma-storm-battery"] and profile.get("additional_weapon_profiles", {}).get("ranged", []).map(func(item: Dictionary) -> String: return item.id) == ["assault-cannon"], "Default loadout and the one exported Heavy Bolter replacement are represented")

	var catalog_entry := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	var point_record: Dictionary = Roster.POINTS.get(UNIT, {})
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and int(Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0)) == 3 and catalog_entry.get("options", []) == [{"models": 1, "cost": 150, "third_plus_cost": 160}], "The consolidated catalog offers the exported unit size, point tiers and copy ceiling")
	check(point_record.get("sizes", {}) == {1: 150} and point_record.get("third_plus_sizes", {}) == {1: 160}, "Roster validation uses the same Vengeance cost tiers")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 460, "Three copies cost 150, 150 and 160 points")
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(four_copies.get("error", "")).is_empty(), "The local admission ceiling rejects a fourth Vengeance")
	check(Enhancements.valid_for(UNIT_ID, Enhancements.NIGHTFORGED_BATTERY, Enhancements.DARKFLIGHT) and not Enhancements.valid_for("40kdc:11e:adeptus-astartes:land-speeder", Enhancements.NIGHTFORGED_BATTERY, Enhancements.DARKFLIGHT), "Nightforged Battery is restricted to the exported Vengeance sheet")
	var upgraded_list := {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 1, "enhancement_id": Enhancements.NIGHTFORGED_BATTERY}]}
	var upgraded_admission := Catalog.admit(upgraded_list)
	check(upgraded_admission.get("error", "").is_empty() and int(upgraded_admission.get("total", -1)) == 160, "Nightforged Battery adds its 10-point cost to an eligible Vengeance")

	var state := prepared()
	check(not state.has("error"), "Both current Marine rosters materialize with Dark Angels context and one Nightforged Vengeance: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Land Speeder Vengeance checks: %d failures" % (failures + 1))
		quit(1)
		return
	var vengeance := squads(state, UNIT, 1)
	var enemy_squads := squads(state, "intercessor-squad", 2)
	var friendly_squads := squads(state, "intercessor-squad", 1)
	check(vengeance.size() == 2 and not enemy_squads.is_empty() and friendly_squads.size() >= 2, "The prepared match contains the two distinct Vengeance configurations and both sides' source-backed units")
	var upgraded_squad := -1
	for squad: int in vengeance:
		if not models(state, squad).is_empty() and str(state.units[models(state, squad)[0]].get("enhancement_id", "")) == Enhancements.NIGHTFORGED_BATTERY: upgraded_squad = squad
	check(upgraded_squad > 0 and C.UnitAbilities.has(state, upgraded_squad, "storm-of-vengeance") and C.UnitAbilities.has(state, upgraded_squad, "deadly-demise-d3") and C.UnitAbilities.has(state, upgraded_squad, "deep-strike") and C.UnitAbilities.has(state, upgraded_squad, "combat-doctrines") and C.DetachmentStratagems.reserve_unit_has_deep_strike(state, upgraded_squad) and Enhancements.active(state, upgraded_squad, Enhancements.NIGHTFORGED_BATTERY), "Storm of Vengeance, Deadly Demise D3, Deep Strike, Combat Doctrines and the enhancement materialize on the Vengeance")
	if upgraded_squad < 0:
		print("Land Speeder Vengeance checks: %d failures" % (failures + 1))
		quit(1)
		return

	var victim := friendly_squads[0]
	var attacker := enemy_squads[0]
	var other_attacker := enemy_squads[1]
	for squad: int in vengeance: place(state, squad, Vector2.ZERO)
	place(state, victim, Vector2(0, 3))
	place(state, attacker, Vector2(12, 0))
	place(state, other_attacker, Vector2(12, 7))
	for model: int in models(state, victim): state.units[model].wounds = 0
	state.phase = "shooting"
	state.active = 2
	state.turn = 2
	state.squads[attacker].shot = true
	var far_state: Dictionary = bytes_to_var(var_to_bytes(state))
	for squad: int in vengeance: place(far_state, squad, Vector2(10, 0))
	C.DetachmentStratagems.after_attacks(far_state, attacker, [victim], 1)
	check(far_state.detachment_stratagems.get("storm_of_vengeance_pending", {}).is_empty(), "Storm of Vengeance does not trigger when every Vengeance is beyond 6 inches")
	var frame := C.ResolutionFrames.begin(state, "attack", "attack:land-speeder-vengeance-trigger", "attack-post-resolution-choice")
	C.DetachmentStratagems.after_attacks(state, attacker, [victim], 1)
	var frame_error := C._complete_attack_resolution_frame(state, "attack:land-speeder-vengeance-trigger")
	var pending_storm: Dictionary = state.detachment_stratagems.get("storm_of_vengeance_pending", {})
	check(not frame.is_empty() and frame_error.is_empty() and pending_storm.get("squads", []).size() == 2 and int(pending_storm.get("attacker", -1)) == attacker, "Destroying a nearby Dark Angels unit exposes both eligible Vengeance units and binds the attacking unit")
	var first := int(pending_storm.get("squads", [])[0]) if not pending_storm.get("squads", []).is_empty() else -1
	var first_model := models(state, first)[0] if first > 0 and not models(state, first).is_empty() else -1
	var reaction := unit_choice(state, 1, "detachment-stratagem", first, -1, C.DetachmentStratagems.STORM_OF_VENGEANCE)
	var wrong_owner_bytes := var_to_bytes(state)
	var wrong_owner := submit_choice(state, 2, "detachment-stratagem", first, -1, C.DetachmentStratagems.STORM_OF_VENGEANCE)
	check(not reaction.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and wrong_owner_bytes == var_to_bytes(state), "Only the defending player can choose the Storm of Vengeance reaction")
	var chosen := submit_choice(state, 1, "detachment-stratagem", first, -1, C.DetachmentStratagems.STORM_OF_VENGEANCE)
	check(chosen.get("error", "").is_empty() and C.DetachmentStratagems.vengeful_shooter(state, first) and C.DetachmentStratagems.reactive_shooting_target(state, first) == attacker, "The reaction lets the selected Vengeance shoot only the unit that destroyed the nearby Dark Angels unit")
	var wrong_target_bytes := var_to_bytes(state)
	var wrong_target := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "revision": state.revision, "attacker": first_model, "entries": [{"model": first_model, "target": other_attacker, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], "melee": false, "use_lethal": false}, die)
	check(not str(wrong_target.get("error", "")).is_empty() and wrong_target_bytes == var_to_bytes(state), "Storm of Vengeance rejects an attack plan against a different enemy unit without changing state")
	var legal_shot := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "revision": state.revision, "attacker": first_model, "entries": [{"model": first_model, "target": attacker, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], "melee": false, "use_lethal": false}, die)
	var next_storm: Dictionary = state.detachment_stratagems.get("storm_of_vengeance_pending", {})
	check(legal_shot.get("error", "").is_empty() and int(state.detachment_stratagems.get("storm_of_vengeance_used", {}).get(str(first), -1)) == int(state.turn) and next_storm.get("squads", []).size() == 1, "The first Vengeance completes its bound shot and the other eligible unit can react sequentially")
	var second := int(next_storm.get("squads", [])[0]) if not next_storm.get("squads", []).is_empty() else -1
	var second_reaction := submit_choice(state, 1, "detachment-stratagem", second, -1, C.DetachmentStratagems.STORM_OF_VENGEANCE)
	var second_ready := C.DetachmentStratagems.vengeful_shooter(state, second)
	var decline_second := submit_choice(state, 1, "vengeful-pass", second, -1, "")
	check(second > 0 and second_reaction.get("error", "").is_empty() and second_ready and decline_second.get("error", "").is_empty() and state.detachment_stratagems.get("storm_of_vengeance_pending", {}).is_empty(), "The second eligible Vengeance may react once, then decline closes the sequence")

	var demise_state := destroyed_vengeance_state()
	if demise_state.has("error"):
		check(false, "The Deadly Demise fixture materializes: " + str(demise_state.get("error", "")))
	else:
		var demise_model := int(demise_state.get("_test_vengeance_model", -1))
		check(C.UnitAbilities.deadly_demise_value(demise_state, demise_model) == "D3", "The Vengeance identity resolves to its exported Deadly Demise D3 profile")
		rolls = [5]
		var quiet_demise := DeadlyDemise.begin(demise_state, [demise_model], die)
		var quiet_event: Dictionary = demise_state.get("last_deadly_demise", {}).get("events", [{}])[0]
		check(quiet_demise.get("error", "").is_empty() and quiet_demise.get("complete", false) and quiet_event.get("expression", "") == "D3" and not quiet_event.get("triggered", true), "Vengeance Deadly Demise D3 does not trigger on a 5")
		demise_state = destroyed_vengeance_state()
		if demise_state.has("error"):
			check(false, "The triggered Deadly Demise fixture materializes: " + str(demise_state.get("error", "")))
		else:
			demise_model = int(demise_state.get("_test_vengeance_model", -1))
			rolls = [6, 2]
			var triggered_demise := DeadlyDemise.begin(demise_state, [demise_model], die)
			var event: Dictionary = demise_state.get("pending_deadly_demise", {}).get("events", [{}])[0]
			var packets: Array = demise_state.get("pending_deadly_demise", {}).get("packets", [])
			check(triggered_demise.get("error", "").is_empty() and not triggered_demise.get("complete", true) and event.get("expression", "") == "D3" and event.get("triggered", false) and event.get("targets", []).size() == 1 and packets.size() == 1 and int(packets[0].get("target", -1)) == squads(demise_state, "intercessor-squad", 2)[0], "A Vengeance Deadly Demise 6 rolls one D3 packet for the enemy within 6 inches and leaves the outside unit unaffected")

	state = prepared()
	if state.has("error"):
		check(false, "The Nightforged action fixture materializes: " + str(state.get("error", "")))
	else:
		vengeance = squads(state, UNIT, 1)
		enemy_squads = squads(state, "intercessor-squad", 2)
		upgraded_squad = -1
		for squad: int in vengeance:
			if not models(state, squad).is_empty() and str(state.units[models(state, squad)[0]].get("enhancement_id", "")) == Enhancements.NIGHTFORGED_BATTERY: upgraded_squad = squad
		var model := models(state, upgraded_squad)[0] if upgraded_squad > 0 and not models(state, upgraded_squad).is_empty() else -1
		var target := enemy_squads[0] if not enemy_squads.is_empty() else -1
		if model > 0 and target > 0:
			place(state, upgraded_squad, Vector2.ZERO)
			place(state, target, Vector2(8, 0))
			state.phase = "shooting"
			state.active = 1
			state.turn = 2
			rolls = [1, 3, 1, 1, 1, 1, 1, 1, 1, 6]
			var attack := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "revision": state.revision, "attacker": model, "entries": [{"model": model, "target": target, "amount": 1, "weapon": "plasma-storm-battery", "profile": "supercharge"}], "melee": false, "use_lethal": false}, die)
			var generation: Dictionary = state.pending_attack.get("current", {}).get("checkpoint", {})
			check(attack.get("error", "").is_empty() and C.UnitActions.pending(state).get("kind", "") == "nightforged-attack-count" and generation.get("context", {}).get("nightforged_attack_count", false) and generation.get("generated", {}).get("rolls", []) == [1], "Nightforged Battery opens a free choice on the random Plasma Storm Battery Attacks roll")
			var count_reroll := submit_choice(state, 1, "nightforged-attack-count-reroll", 0, -1, "")
			var hazard_window := C.UnitActions.pending(state)
			var hazardous: Dictionary = state.get("pending_hazard", {}).get("resolved", {}).get("hazardous", {})
			check(count_reroll.get("error", "").is_empty() and hazard_window.get("kind", "") == "nightforged-hazard" and hazardous.get("rolls", []) == [1] and int(state.pending_hazard.get("squad", -1)) == upgraded_squad, "Choosing an Attack reroll resumes shooting and exposes the Hazard roll before mortal-wound allocation")
			var hazard_reroll := submit_choice(state, 1, "nightforged-hazard-reroll", 0, -1, "")
			hazard_window = C.UnitActions.pending(state)
			hazardous = state.get("pending_hazard", {}).get("resolved", {}).get("hazardous", {})
			var another_reroll := unit_choice(state, 1, "nightforged-hazard-reroll", 1, -1, "")
			check(hazard_reroll.get("error", "").is_empty() and hazardous.get("rolls", []) == [6] and hazardous.get("rerolls", []).size() == 1 and hazard_window.get("eligible", []) == [] and another_reroll.is_empty(), "Each Hazard die can be rerolled once and the replacement is recorded before allocation")
			var accept_hazard := submit_choice(state, 1, "nightforged-hazard-pass", -1, -1, "")
			check(accept_hazard.get("error", "").is_empty() and state.get("pending_hazard", {}).is_empty() and state.pending_attack.is_empty() and state.squads[upgraded_squad].shot, "Accepting the Hazard result resumes and completes the suspended attack")
		else:
			check(false, "The Vengeance and an enemy target are available for the Nightforged attack and Hazard checks")

	print("Land Speeder Vengeance checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

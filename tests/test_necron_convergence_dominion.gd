extends SceneTree

const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_remaining_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Convergence = preload("res://scripts/edition_11/necron_convergence_of_dominion.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if condition: return
	failures += 1
	push_error(label)

func _deployment_state(count: int, positions: Array[Vector2]) -> Dictionary:
	var units := {}
	for index in count:
		var model := 201 + index
		units[model] = _model(1, 1, "convergence-of-dominion", positions[index], ["NECRONS", "VEHICLE", "FORTIFICATION"])
		units[model].radius = 0.0
		units[model].wounds = 7
		units[model].max_wounds = 7
	var state := {
		"board_size": Vector2(60, 44), "revision": 0, "events": [], "mission": {},
		"terrain": {"id": "clear-test", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "reserves": {}, "setup_players": [1, 2]},
		"squads": {1: {"owner": 1, "name": "Convergence of Dominion", "starting_strength": count, "training_cost": count * 60}},
		"units": units
	}
	Deployment.begin(state)
	return state

func _model(squad: int, owner: int, identity: String, position: Vector2, keywords: Array[String]) -> Dictionary:
	return {"squad": squad, "owner": owner, "definition_id": "40kdc:11e:necrons:" + identity,
		"position": position, "radius": 0.0, "wounds": 7, "max_wounds": 7,
		"on_battlefield": true, "keywords": keywords}

func run() -> void:
	var profile := Profiles.profile("convergence-of-dominion")
	check(profile.get("source_datasheet_id", "") == "000002361" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Convergence profile keeps the local Necrons App v1.2 identity")
	check(profile.get("points_by_models", {}) == {1: 60, 2: 120, 3: 180} and profile.get("source_composition_rows", []) == ["1-3 Convergence of Dominion Starsteles"], "Convergence preserves all three source-priced compositions")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard == {"name": "Transdimensional abductor", "range_inches": 18, "attacks": 3, "skill": 4, "strength": 6, "ap": -2, "damage": 3, "keywords": {}}, "Transdimensional abductor matches the source weapon profile")
	check(profile.get("source_ability_names", []) == ["Reanimation Protocols", "Reanimation Nodes (Aura)", "Ancient Cover", "Fortification", "DEPLOYMENT"], "All five source ability names remain recorded")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "reanimation-nodes", "ancient-cover", "convergence-fortification", "convergence-deployment"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []) == ["resolve the 1-model deployment wording and whole-model 12-inch placement with the source Use model footprint"], "Implemented Convergence interactions stay recorded while the unresolved one-model setup keeps the profile gated")
	check(AbilityCatalog.RULES.get("convergence-of-dominion", []) == ["reanimation-protocols", "reanimation-nodes", "ancient-cover", "convergence-fortification", "convergence-deployment"], "The ability catalog binds the implemented Convergence rules")
	for rule_id: String in ["reanimation-nodes", "ancient-cover", "convergence-fortification", "convergence-deployment"]:
		check(Capabilities.supported(rule_id) and Capabilities.KNOWN[rule_id].validation_status == "implemented_local_checks_pending" and Capabilities.KNOWN[rule_id].source_status.contains("000002361"), "Convergence capability metadata stays source-linked and unadmitted: " + rule_id)
	var admission := Army.resolve("Necrons", "40kdc:11e:necrons:convergence-of-dominion")
	check(not str(admission.get("error", "")).is_empty(), "Convergence stays outside new construction until its full source scope passes")

	var state := {
		"unit_abilities": {"implementation": AbilityCatalog.ID, "reserves": {}},
		"squads": {101: {"owner": 1}, 102: {"owner": 1}, 103: {"owner": 2}},
		"units": {
			101: _model(101, 1, "convergence-of-dominion", Vector2.ZERO, ["NECRONS", "VEHICLE", "FORTIFICATION"]),
			102: _model(102, 1, "necron-warriors", Vector2(6.0, 0.0), ["NECRONS", "INFANTRY"]),
			103: _model(103, 2, "necron-warriors", Vector2(1.0, 0.0), ["NECRONS", "INFANTRY"])
		}
	}
	var expected := {"target": 6, "against": "any"}
	check(UnitPrevention.grants(state, 102).has(expected), "Reanimation Nodes grants Feel No Pain 6+ at the 6-inch edge boundary")
	check(UnitPrevention.rules(state, 102).has(expected), "Reanimation Nodes flows into the shared damage-prevention query")
	check(not UnitPrevention.grants(state, 103).has(expected), "Reanimation Nodes does not protect an enemy Necrons unit")
	state.units[102].position = Vector2(6.002, 0.0)
	check(not UnitPrevention.grants(state, 102).has(expected), "Reanimation Nodes stops outside 6 inches")
	state.units[102].position = Vector2(1.0, 0.0)
	state.units[102].keywords = ["NECRONS", "VEHICLE"]
	check(not UnitPrevention.grants(state, 102).has(expected), "Reanimation Nodes does not protect a non-Infantry target")
	state.units[102].keywords = ["NECRONS", "INFANTRY"]
	state.unit_abilities.reserves[101] = true
	check(not UnitPrevention.grants(state, 102).has(expected), "A Convergence in Reserves does not project its Aura")
	state.unit_abilities.reserves.erase(101)
	state.units[101].wounds = 0
	check(not UnitPrevention.grants(state, 102).has(expected), "A destroyed Convergence does not project its Aura")

	var separated := _deployment_state(2, [Vector2(-24, 0), Vector2(-24, 12)])
	check(Deployment.place(separated, 1, 201, Vector2(-24, 0), separated.revision).is_empty(), "The first Starstele accepts a deployment-zone position")
	check(Deployment.place(separated, 1, 202, Vector2(-24, 12), separated.revision).is_empty(), "The second Starstele accepts the 12-inch boundary")
	check(Deployment.confirm(separated, 1, separated.revision).is_empty() and separated.units[201].squad != separated.units[202].squad, "Two Starsteles split into separate units after deployment")
	check(Reanimation.supported_unit(separated, separated.units[201].squad) and Reanimation.supported_unit(separated, separated.units[202].squad) and int(separated.squads[separated.units[202].squad].training_cost) == 0, "Each resulting Starstele keeps its own Reanimation unit without duplicating the roster cost")
	var distant := _deployment_state(2, [Vector2(-24, 0), Vector2(-24, 12.002)])
	check(Deployment.place(distant, 1, 201, Vector2(-24, 0), distant.revision).is_empty() and Deployment.place(distant, 1, 202, Vector2(-24, 12.002), distant.revision).is_empty(), "Both distant Starsteles can be placed before the range gate")
	check(Deployment.confirm(distant, 1, distant.revision).contains("12 inches") and distant.units[201].squad == distant.units[202].squad, "Starsteles outside 12 inches stay one unit")
	var single := _deployment_state(1, [Vector2(-24, 0)])
	check(Deployment.place(single, 1, 201, Vector2(-24, 0), single.revision).is_empty(), "A one-model Convergence can be positioned")
	check(Deployment.confirm(single, 1, single.revision).contains("one-model"), "A one-model Convergence remains an unresolved source composition")

	var cover_state := {
		"unit_abilities": {"implementation": AbilityCatalog.ID, "reserves": {}},
		"squads": {
			11: {"owner": 2, "stats": {"toughness": 4, "save_target": 4, "invulnerable_target": 0}},
			12: {"owner": 1, "stats": {"toughness": 4, "save_target": 4, "invulnerable_target": 0}},
			13: {"owner": 1, "stats": {"toughness": 9, "save_target": 3, "invulnerable_target": 0}}
		},
		"units": {
			11: _model(11, 2, "necron-warriors", Vector2(8, 0), ["NECRONS", "INFANTRY"]),
			12: _model(11, 2, "necron-warriors", Vector2(0, 8), ["NECRONS", "INFANTRY"]),
			13: _model(12, 1, "necron-warriors", Vector2.ZERO, ["NECRONS", "INFANTRY"]),
			14: _model(13, 1, "convergence-of-dominion", Vector2(3, 0), ["NECRONS", "VEHICLE", "FORTIFICATION"])
		},
		"turn": 1, "phase": "shooting",
		"pending_attack": {"squad": 11, "melee": false, "ability_saves": {}}
	}
	cover_state.units[11].radius = 0.5
	cover_state.units[12].radius = 0.5
	cover_state.units[13].radius = 0.5
	cover_state.units[14].radius = 1.0
	cover_state.units[12].squad = 99
	cover_state.squads[99] = {"owner": 2, "stats": {"toughness": 4, "save_target": 4, "invulnerable_target": 0}}
	check(Convergence.ancient_cover(cover_state, 11, 13), "Ancient Cover applies when every attacking model is blocked by the same Starstele")
	cover_state.units[12].squad = 11
	check(not Convergence.ancient_cover(cover_state, 11, 13), "Ancient Cover does not apply when one attacking model can fully see the target")
	cover_state.units[12].squad = 99
	var covered := Allocation.save_roll_outcome(cover_state, {"weapon": {"ap": 0, "keywords": {}}}, 13, 3)
	check(bool(covered.success) and int(covered.armour_target) == 3, "Ancient Cover improves a 4+ armour save to 3+ for the allocated model")
	var ignored := Allocation.save_roll_outcome(cover_state, {"weapon": {"ap": 0, "keywords": {"ignores-cover": true}}}, 13, 3)
	check(not bool(ignored.success) and int(ignored.armour_target) == 4, "Ignores Cover skips Ancient Cover")

	var fort_state := {
		"unit_abilities": {"implementation": AbilityCatalog.ID, "reserves": {}},
		"phase": "movement", "active": 2, "revision": 4, "turn": 1,
		"pending_move": {}, "pending_attack": {}, "pending_hazard": {}, "pending_deadly_demise": {},
		"squads": {
			401: {"owner": 1, "name": "Convergence", "battle_shocked": false, "moved": false, "stats": {"movement_inches": 6, "toughness": 9, "save_target": 3, "invulnerable_target": 0}},
			402: {"owner": 2, "name": "Warriors", "battle_shocked": true, "moved": false, "stats": {"movement_inches": 5, "toughness": 4, "save_target": 4, "invulnerable_target": 0}}
		},
		"units": {
			401: _model(401, 1, "convergence-of-dominion", Vector2.ZERO, ["NECRONS", "VEHICLE", "FORTIFICATION"]),
			402: _model(402, 2, "necron-warriors", Vector2(1.2, 0), ["NECRONS", "INFANTRY"])
		}
	}
	fort_state.units[401].radius = 1.0
	fort_state.units[401].squad = 401
	fort_state.units[402].radius = 0.5
	fort_state.units[402].squad = 402
	check(Convergence.fortification_ranged_exception(fort_state, 402, 1) and Convergence.fortification_hit_penalty(fort_state, 402, 1, {"keywords": {}}) and not Convergence.fortification_hit_penalty(fort_state, 402, 1, {"keywords": {"pistol": true}}) and not Convergence.fortification_hit_penalty(fort_state, 402, 1, {"keywords": {"close-quarters": true}}), "Fortification allows ranged attacks at -1 to Hit and exempts Pistol attacks")
	check(Convergence.battle_shocked_ordered_retreat_allowed(fort_state, 402), "A Battle-shocked unit engaged only with the Convergence army's Fortifications may Fall Back without a unit-wide Desperate Escape")
	fort_state.pending_move = {"move_type": "ordered_retreat", "paths": {402: [{"from": Vector2(1.2, 0), "to": Vector2(-2, 0), "from_elevation": 0.0, "to_elevation": 0.0}]}}
	check(Convergence.crossing_models(fort_state, 402) == [402], "A Fall Back path that crosses the Starstele still requires that model's Desperate Escape test")
	fort_state.pending_move.paths = {402: [{"from": Vector2(1.2, 0), "to": Vector2(4, 0), "from_elevation": 0.0, "to_elevation": 0.0}]}
	check(Convergence.crossing_models(fort_state, 402).is_empty(), "A Fall Back path that leaves without crossing an enemy model stays exempt")
	fort_state.units[403] = _model(403, 1, "necron-warriors", Vector2(1.2, 1.0), ["NECRONS", "INFANTRY"])
	fort_state.units[403].radius = 0.5
	fort_state.units[403].squad = 403
	fort_state.squads[403] = {"owner": 1}
	check(not Convergence.fortification_ranged_exception(fort_state, 402, 1) and not Convergence.battle_shocked_ordered_retreat_allowed(fort_state, 402), "Engagement with a non-Fortification removes the ranged and Fall Back exceptions")

	if failures == 0: print("Convergence of Dominion scoped local checks: passed")
	else: print("Convergence of Dominion checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

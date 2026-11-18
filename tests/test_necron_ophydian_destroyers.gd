extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const NecronOphydian = preload("res://scripts/edition_11/necron_ophydian_destroyers.gd")

const OPHYDIAN_ID := "40kdc:11e:necrons:ophydian-destroyers"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("ophydian-destroyers")
	check(profile.get("source_datasheet_id", "") == "000002358" and profile.get("points_by_models", {}) == {3: 80, 6: 150} and profile.get("third_plus_points_by_models", {}) == {3: 90, 6: 160}, "Ophydian Destroyers retain both source copy-price tiers")
	check(profile.get("supported_rule_ids", []) == ["deep-strike", "reanimation-protocols", "plasmacyte", "tunnelling-horrors"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("source_options", [{}])[0].get("implemented", false), "Plasmacyte and Tunnelling Horrors are admitted within the local scope")
	var three := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OPHYDIAN_ID, "models": 3, "copies": 1}]})
	var six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OPHYDIAN_ID, "models": 6, "copies": 1}]})
	var third_six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": OPHYDIAN_ID, "models": 6, "copies": 3}]})
	check(str(three.get("error", "")).is_empty() and int(three.get("total", -1)) == 80 and str(six.get("error", "")).is_empty() and int(six.get("total", -1)) == 150, "3- and 6-model Ophydians admit at source first-copy prices")
	check(str(third_six.get("error", "")).is_empty() and int(third_six.get("total", -1)) == 460, "Three 6-model copies cost 150+150+160")
	check(AbilityCatalog.RULES.get("ophydian-destroyers", []) == ["deep-strike", "reanimation-protocols", "plasmacyte", "tunnelling-horrors"], "Ability catalog binds Deep Strike, Reanimation, Plasmacyte and Tunnelling Horrors")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": OPHYDIAN_ID, "models": 3, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}
	})
	if state.has("error"):
		check(false, "Ophydian fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var ophydian_model := -1
	var marine_squad := -1
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "ophydian-destroyers" and ophydian_model < 0: ophydian_model = model
		elif identity == "intercessor-squad" and marine_squad < 0: marine_squad = int(state.units[model].get("squad", -1))
	check(ophydian_model >= 0 and marine_squad >= 0, "Ophydian Destroyers and Intercessors materialize")
	if ophydian_model < 0 or marine_squad < 0:
		quit(1)
		return
	var squad := int(state.units[ophydian_model].get("squad", -1))
	check(Reanimation.supported_unit(state, squad) and UnitAbilities.has(state, squad, "deep-strike") and UnitAbilities.has(state, squad, "plasmacyte") and UnitAbilities.has(state, squad, "tunnelling-horrors"), "Ophydian abilities bind on the live unit")
	NecronOphydian.ensure_tokens(state, squad)
	check(NecronOphydian.tokens_remaining(state, squad) == 1, "A 3-model unit starts with one Plasmacyte token")

	state.phase = "fight"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.unit_abilities.used["plasmacyte:%d:1:fight" % squad] = true
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == marine_squad:
			state.units[model].position = Vector2(1.0, 0.0)
		elif int(state.units[model].get("squad", -1)) == squad:
			# Only the first Ophydian stays engaged so melee allocation covers one weapon profile.
			state.units[model].position = Vector2.ZERO if model == ophydian_model else Vector2(40.0, 0.0)
	var melee_id := str(state.units[ophydian_model].melee_weapons[0].get("id", ""))
	var melee_attacks := int(UnitAbilities.melee_attack_count(state, ophydian_model, state.units[ophydian_model].melee_weapons[0].profiles.standard))
	var with_plasmacyte := AttackPlan.prepare(state, squad, true, [{"model": ophydian_model, "target": marine_squad, "amount": melee_attacks, "weapon": melee_id, "profile": "standard"}], true)
	check(str(with_plasmacyte.get("error", "")).is_empty() and bool(with_plasmacyte.get("batches", [{}])[0].get("weapon", {}).get("keywords", {}).get("devastating-wounds", false)), "Active Plasmacyte grants Devastating Wounds to melee attacks: " + str(with_plasmacyte.get("error", with_plasmacyte)))
	state.unit_abilities.used.erase("plasmacyte:%d:1:fight" % squad)
	var without_plasmacyte := AttackPlan.prepare(state, squad, true, [{"model": ophydian_model, "target": marine_squad, "amount": melee_attacks, "weapon": melee_id, "profile": "standard"}], true)
	check(str(without_plasmacyte.get("error", "")).is_empty() and not bool(without_plasmacyte.get("batches", [{}])[0].get("weapon", {}).get("keywords", {}).get("devastating-wounds", false)), "Without a spent Plasmacyte token, melee attacks lack Devastating Wounds: " + str(without_plasmacyte.get("error", without_plasmacyte)))

	state.active = 2
	state.phase = "fight"
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == marine_squad: state.units[model].position = Vector2(20.0, 0.0)
		elif int(state.units[model].get("squad", -1)) == squad: state.units[model].position = Vector2.ZERO
	check(NecronOphydian.tunnelling_squads(state, 1) == [squad], "Unengaged Ophydians are eligible for Tunnelling Horrors at the opponent's Fight end")
	var tunnelling := UnitActions.apply(state, 1, {"action": "tunnelling-horrors", "model": -1, "target": squad}, Vector2.ZERO, Callable())
	check(str(tunnelling.get("error", "")).is_empty() and state.unit_abilities.reserves.has(squad) and str(state.unit_abilities.reserves[squad].get("source", "")) == "tunnelling-horrors" and not bool(state.units[ophydian_model].get("on_battlefield", true)), "Tunnelling Horrors places the unit in Strategic Reserves: " + str(tunnelling.get("error", "")))
	check(UnitActions.ingress_round_allowed(state, squad), "Tunnelling Horrors permits ingress in battle round 1")

	if failures == 0:
		print("Ophydian Destroyers scoped local checks: passed")
		quit(0)
	else:
		print("Ophydian Destroyers checks: %d failures" % failures)
		quit(1)

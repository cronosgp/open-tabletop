extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const NecronOphydian = preload("res://scripts/edition_11/necron_ophydian_destroyers.gd")

const SKORPEKH_ID := "40kdc:11e:necrons:skorpekh-destroyers"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("skorpekh-destroyers")
	check(profile.get("source_datasheet_id", "") == "000002110" and profile.get("points_by_models", {}) == {3: 85, 6: 170} and profile.get("third_plus_points_by_models", {}) == {3: 95, 6: 180}, "Skorpekh Destroyers retain both source copy-price tiers")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "plasmacyte", "whirling-onslaught"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("source_options", [{}])[0].get("implemented", false), "Plasmacyte and Whirling Onslaught are admitted within the local scope")
	var three := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SKORPEKH_ID, "models": 3, "copies": 1}]})
	var six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SKORPEKH_ID, "models": 6, "copies": 1}]})
	var third_six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": SKORPEKH_ID, "models": 6, "copies": 3}]})
	check(str(three.get("error", "")).is_empty() and int(three.get("total", -1)) == 85 and str(six.get("error", "")).is_empty() and int(six.get("total", -1)) == 170, "3- and 6-model Skorpekh admit at source first-copy prices")
	check(str(third_six.get("error", "")).is_empty() and int(third_six.get("total", -1)) == 520, "Three 6-model copies cost 170+170+180")
	check(AbilityCatalog.RULES.get("skorpekh-destroyers", []) == ["reanimation-protocols", "plasmacyte", "whirling-onslaught"], "Ability catalog binds Reanimation, Plasmacyte and Whirling Onslaught")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SKORPEKH_ID, "models": 3, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}
	})
	if state.has("error"):
		check(false, "Skorpekh fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var skorpekh_model := -1
	var marine_squad := -1
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "skorpekh-destroyers" and skorpekh_model < 0: skorpekh_model = model
		elif identity == "intercessor-squad" and marine_squad < 0: marine_squad = int(state.units[model].get("squad", -1))
	check(skorpekh_model >= 0 and marine_squad >= 0, "Skorpekh Destroyers and Intercessors materialize")
	if skorpekh_model < 0 or marine_squad < 0:
		quit(1)
		return
	var squad := int(state.units[skorpekh_model].get("squad", -1))
	check(Reanimation.supported_unit(state, squad) and UnitAbilities.has(state, squad, "plasmacyte") and UnitAbilities.has(state, squad, "whirling-onslaught"), "Skorpekh abilities bind on the live unit")
	NecronOphydian.ensure_tokens(state, squad)
	check(NecronOphydian.tokens_remaining(state, squad) == 1, "A 3-model unit starts with one Plasmacyte token")

	state.phase = "fight"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == marine_squad:
			state.units[model].position = Vector2(1.0, 0.0)
		elif int(state.units[model].get("squad", -1)) == squad:
			state.units[model].position = Vector2.ZERO if model == skorpekh_model else Vector2(40.0, 0.0)
	var melee_id := str(state.units[skorpekh_model].melee_weapons[0].get("id", ""))
	var melee_attacks := int(UnitAbilities.melee_attack_count(state, skorpekh_model, state.units[skorpekh_model].melee_weapons[0].profiles.standard))
	state.squads[squad].charged = false
	var without_charge := AttackPlan.prepare(state, squad, true, [{"model": skorpekh_model, "target": marine_squad, "amount": melee_attacks, "weapon": melee_id, "profile": "standard"}], true)
	check(str(without_charge.get("error", "")).is_empty() and str(without_charge.get("batches", [{}])[0].get("context", {}).get("hit_reroll", "")) == "ones", "Whirling Onslaught re-rolls Hit rolls of 1 without a Charge: " + str(without_charge.get("error", without_charge)))
	state.squads[squad].charged = true
	var with_charge := AttackPlan.prepare(state, squad, true, [{"model": skorpekh_model, "target": marine_squad, "amount": melee_attacks, "weapon": melee_id, "profile": "standard"}], true)
	check(str(with_charge.get("error", "")).is_empty() and str(with_charge.get("batches", [{}])[0].get("context", {}).get("hit_reroll", "")) == "all", "Whirling Onslaught re-rolls the Hit roll after a Charge: " + str(with_charge.get("error", with_charge)))
	state.unit_abilities.used["plasmacyte:%d:1:fight" % squad] = true
	var with_plasmacyte := AttackPlan.prepare(state, squad, true, [{"model": skorpekh_model, "target": marine_squad, "amount": melee_attacks, "weapon": melee_id, "profile": "standard"}], true)
	check(str(with_plasmacyte.get("error", "")).is_empty() and bool(with_plasmacyte.get("batches", [{}])[0].get("weapon", {}).get("keywords", {}).get("devastating-wounds", false)), "Active Plasmacyte grants Devastating Wounds to Skorpekh melee attacks: " + str(with_plasmacyte.get("error", with_plasmacyte)))

	if failures == 0:
		print("Skorpekh Destroyers scoped local checks: passed")
		quit(0)
	else:
		print("Skorpekh Destroyers checks: %d failures" % failures)
		quit(1)

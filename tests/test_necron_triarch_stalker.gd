extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Stalker = preload("res://scripts/edition_11/necron_triarch_stalker.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const STALKER_ID := "40kdc:11e:necrons:triarch-stalker"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_choice(state: Dictionary, player: int, action: String, target: int = -1) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func run() -> void:
	var profile := Profiles.profile("triarch-stalker")
	var heat: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {})
	check(profile.get("source_datasheet_id", "") == "000000540" and profile.get("points_by_models", {}) == {1: 110} and profile.get("third_plus_points_by_models", {}) == {1: 120} and profile.get("base_size_proxy_mm", 0) == 120, "Triarch Stalker retains App v1.2 identity, copy prices and labelled 120 mm proxy")
	check(heat.get("dispersed", {}).get("keywords", {}) == {"ignores-cover": true, "torrent": true} and heat.get("focused", {}).get("keywords", {}) == {"melta": 4}, "Heat ray dispersed and focused profiles preserve source keywords")
	check(profile.get("supported_rule_ids", []) == ["deadly-demise-d3", "scouts-8", "reanimation-protocols", "targeting-relay"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty(), "Every Triarch Stalker source rule is admitted within the local scope")
	var first := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": STALKER_ID, "models": 1, "copies": 1}]})
	var third := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": STALKER_ID, "models": 1, "copies": 3}]})
	check(str(first.get("error", "")).is_empty() and int(first.get("total", -1)) == 110 and str(third.get("error", "")).is_empty() and int(third.get("total", -1)) == 340, "First/second copies cost 110 and the third copy adds 120")
	check(AbilityCatalog.RULES.get("triarch-stalker", []) == ["deadly-demise-d3", "scouts-8", "reanimation-protocols", "targeting-relay"], "Ability catalog binds all four Triarch Stalker rules")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": STALKER_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1},
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Triarch Stalker fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var stalker_model := -1
	var enemy_squads: Array[int] = []
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "triarch-stalker": stalker_model = model
		elif identity == "intercessor-squad":
			var squad := int(state.units[model].get("squad", -1))
			if squad not in enemy_squads: enemy_squads.append(squad)
	enemy_squads.sort()
	check(stalker_model >= 0 and enemy_squads.size() == 2, "Triarch Stalker and two Interceptor squads materialize")
	if stalker_model < 0 or enemy_squads.size() < 2:
		quit(1)
		return
	var stalker_squad := int(state.units[stalker_model].get("squad", -1))
	check(Reanimation.supported_unit(state, stalker_squad), "The one-model Triarch Stalker can activate Reanimation Protocols")
	UnitActions.reconcile(state)

	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	var single_resolved := {"pools": [{"target_squad": enemy_squads[0], "hits": 2}]}
	check(not Stalker.offer_after_shot(state, stalker_squad, single_resolved, false) and UnitAbilities.cover_denial_mark_active(state, 1, enemy_squads[0]), "A single hit target is auto-marked for Cover denial")

	state.unit_abilities.signum_targets = {}
	var multi_resolved := {"pools": [
		{"target_squad": enemy_squads[0], "hits": 1},
		{"target_squad": enemy_squads[1], "hits": 3}
	]}
	check(Stalker.offer_after_shot(state, stalker_squad, multi_resolved, false) and str(state.unit_abilities.window.get("kind", "")) == Stalker.WINDOW, "Multiple hit targets open a Targeting Relay choice")
	var choice := find_choice(state, 1, Stalker.ACTION, enemy_squads[1])
	var applied := PublicUnitCommand.submit(state, 1, choice)
	check(not choice.is_empty() and str(applied.get("error", "")).is_empty() and UnitAbilities.cover_denial_mark_active(state, 1, enemy_squads[1]) and not UnitAbilities.cover_denial_mark_active(state, 1, enemy_squads[0]), "Targeting Relay marks the selected hit unit for the rest of the Shooting phase")

	if failures == 0:
		print("Triarch Stalker scoped local checks: passed")
		quit(0)
	else:
		print("Triarch Stalker checks: %d failures" % failures)
		quit(1)

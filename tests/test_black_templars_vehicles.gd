extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")

const EXPECTED := {
	"black-templars-gladiator-lancer": ["000002787", "Gladiator Lancer", 165, 185],
	"black-templars-gladiator-reaper": ["000002789", "Gladiator Reaper", 165, 185],
	"black-templars-gladiator-valiant": ["000002788", "Gladiator Valiant", 145, 165],
	"black-templars-impulsor": ["000002786", "Impulsor", 70, 70],
	"black-templars-repulsor": ["000002791", "Repulsor", 190, 210],
	"black-templars-repulsor-executioner": ["000002790", "Repulsor Executioner", 265, 285],
}

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func fixture(identities: Array = []) -> Dictionary:
	var templar_entries: Array = []
	var selected_identities: Array = identities if not identities.is_empty() else EXPECTED.keys()
	for identity: String in selected_identities:
		templar_entries.append(entry(identity, 5 if identity == "intercessor-squad" else 1))
	var selections := {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": templar_entries},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry("intercessor-squad", 5)]},
	}
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"},
	}, selections)
	if state.has("error"):
		return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func model_for(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return model
	return -1

func run() -> void:
	for identity: String in EXPECTED:
		var expected: Array = EXPECTED[identity]
		var profile := Profiles.profile(identity)
		var source_profile := Profiles.profile(str(identity.trim_prefix("black-templars-")))
		check(not profile.is_empty() and profile.get("source_book_id", "") == "000000162" and profile.get("source_datasheet_id", "") == expected[0], "%s maps to its exact Black Templars App source sheet" % identity)
		check(profile.get("name", "") == expected[1] and profile.get("source_snapshot_id", "") == "20261021T130623Z" and profile.get("source_export_updated_at", "") == "2026-10-21 16:06:23 GMT+3", "%s retains its source name and pinned export provenance" % identity)
		check(profile.get("points_by_models", {}).get(1, -1) == expected[2] and profile.get("third_plus_points_by_models", {}).get(1, -1) == expected[3] and profile.get("max_supported_copies", 0) == 3, "%s exposes its sourced copy prices and profile cap" % identity)
		check(profile.get("ranged", []) == source_profile.get("ranged", []) and profile.get("melee", []) == source_profile.get("melee", []) and profile.get("stats", {}) == source_profile.get("stats", {}), "%s reuses the shared datasheet fixed combat profile" % identity)
		check(Catalog.SPECS.get(identity, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(identity, {}).get("cost", -1) == expected[2], "%s is admitted by the consolidated construction and point catalogs" % identity)
		for ability: String in AbilityCatalog.RULES.get(identity, []):
			check(Registry.KNOWN.get(ability, {}).get("supported", false), "%s has a registered supported capability: %s" % [identity, ability])

	var state := fixture()
	check(not state.has("error"), "The six current Black Templars vehicle identities materialize from the local catalog: %s" % str(state.get("error", "")))
	if not state.has("error"):
		var enemy_squad := int(state.units[model_for(state, "intercessor-squad", 2)].squad)
		for identity: String in EXPECTED:
			var model := model_for(state, identity, 1)
			var profile := Profiles.profile(identity)
			check(model >= 0, "%s materializes for its owner" % identity)
			if model >= 0:
				var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, model, enemy_squad)
				check(weapon_failures.is_empty(), "%s default weapons resolve through the current attack plan: %s" % [identity, str(weapon_failures)])

		var templar_impulsor := Profiles.profile("black-templars-impulsor")
		var systems: Array = templar_impulsor.get("transport", {}).get("options", {}).get("one_of", [])
		check("Ironhail Skytalon Array" not in systems and not templar_impulsor.get("additional_weapon_profiles", {}).get("ranged", []).any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "ironhail-skytalon-array"), "Black Templars Impulsor omits the unavailable Ironhail Skytalon Array")
		var loadout_choices := Transport.impulsor_loadout_choices(state, 1)
		check(not loadout_choices.any(func(choice: Dictionary) -> bool: return choice.get("model", -1) == model_for(state, "black-templars-impulsor", 1) and choice.get("value", "") == "ironhail-skytalon-array"), "Impulsor preparation does not offer the Black Templars-excluded array")
		var forbidden_result := Transport.configure_impulsor(state, model_for(state, "black-templars-impulsor", 1), 0, "ironhail-skytalon-array")
		check(not forbidden_result.is_empty(), "Direct Impulsor configuration rejects the excluded array")
		check(Transport.is_transport(state, model_for(state, "black-templars-repulsor", 1)), "Black Templars Repulsor retains its transport profile")
		check(AbilityCatalog.RULES.get("black-templars-repulsor", []).has("combat-embarkation"), "Black Templars Repulsor registers Combat Embarkation")
	var transport_state := fixture(["black-templars-repulsor", "intercessor-squad"])
	check(not transport_state.has("error"), "Black Templars Repulsor reaction fixture is within the roster limit: %s" % str(transport_state.get("error", "")))
	if not transport_state.has("error"):
		var templar_repulsor := model_for(transport_state, "black-templars-repulsor", 1)
		var templar_passenger := model_for(transport_state, "intercessor-squad", 1)
		var charger := model_for(transport_state, "intercessor-squad", 2)
		var passenger_squad := int(transport_state.units[templar_passenger].squad)
		var charger_squad := int(transport_state.units[charger].squad)
		transport_state.units[templar_repulsor].position = Vector2.ZERO
		for model: int in transport_state.units:
			if int(transport_state.units[model].get("squad", -1)) == passenger_squad:
				transport_state.units[model].position = Vector2(0.2, 0.2)
		transport_state.phase = "charge"
		transport_state.active = 2
		transport_state.pending_charge = {"squad": charger_squad, "maximum": 12, "rolls": [6, 6], "targets": [passenger_squad]}
		var candidates := Transport._combat_embarkation_candidates(transport_state, 1)
		check(candidates.size() == 1 and int(candidates[0].transport) == templar_repulsor and int(candidates[0].passenger_squad) == passenger_squad, "Black Templars Repulsor offers its nearby unengaged Astartes target for Combat Embarkation")

	if failures == 0: print("Black Templars vehicle checks: passed")
	else: print("Black Templars vehicle checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

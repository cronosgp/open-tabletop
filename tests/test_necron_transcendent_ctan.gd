extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")

const CTAN_ID := "40kdc:11e:necrons:transcendent-ctan"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func six() -> int:
	return 6

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": CTAN_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}}

func units_for(state: Dictionary, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func run() -> void:
	var profile := Profiles.profile("transcendent-ctan")
	var seismic: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var tendrils: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000000555" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Transcendent C’tan facts retain the verified local App v1.2 snapshot")
	check(profile.get("points_by_models", {}) == {1: 340} and profile.get("second_plus_points_by_models", {}) == {1: 360} and profile.get("base_size_source_mm", 0) == 60 and profile.get("stats", {}).get("wounds", 0) == 16 and profile.get("stats", {}).get("invulnerable_target", 0) == 4, "Transcendent C’tan keeps 340/360 copy prices, 60 mm flying base and 16-wound characteristics")
	check(seismic.get("range_inches") == 12 and seismic.get("attacks") == 6 and seismic.get("strength") == 8 and seismic.get("ap") == -2 and seismic.get("damage") == 2 and seismic.get("keywords", {}) == {"assault": true, "sustained-hits": 1}, "Seismic assault preserves its source Assault and Sustained Hits 1 traits")
	check(tendrils.get("attacks") == 8 and tendrils.get("strength") == 10 and tendrils.get("ap") == -3 and tendrils.get("damage") == "D6" and tendrils.get("keywords", {}) == {"sustained-hits": 1}, "Crackling tendrils preserve their source Sustained Hits 1 and D6 Damage")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "necrodermis", "enslaved-star-god", "ctan-shard", "transdimensional-displacement"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Every Transcendent C’tan datasheet rule is admitted within its locally checked scope")
	var catalog_choice := Army.current_catalog_choice({"id": "40kdc:11e:necrons:transcendent-ctan", "edition": "11e", "faction": "Necrons"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 340, "second_plus_cost": 360}], "Construction exposes the first-copy 340 and second-plus 360 prices")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": CTAN_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 340, "The first Transcendent C’tan enters construction at 340 points")
	var two_copies := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": CTAN_ID, "models": 1, "copies": 2}]})
	check(str(two_copies.get("error", "")).is_empty() and int(two_copies.get("total", -1)) == 700, "A second Transcendent C’tan uses the 360-point later-copy price")
	var forged := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": CTAN_ID, "models": 1, "copies": 1, "enhancement_id": "forged-enhancement"}]})
	check(str(forged.get("error", "")).contains("cannot be given Enhancements"), "C’TAN SHARD continues to reject forged Enhancements")
	var reanimation_counts: Array = Reanimation.PROFILE_MODEL_COUNTS.get(CTAN_ID, [])
	check(int(Reanimation.CHARACTER_WOUNDS.get(CTAN_ID, 0)) == 16 and reanimation_counts.size() == 1 and int(reanimation_counts[0]) == 1, "Reanimation keeps the Transcendent C’tan’s 16-wound one-model profile")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Transcendent C’tan local fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	var ctan_models := units_for(state, "transcendent-ctan")
	var ctan_squad := squad_for(state, "transcendent-ctan")
	check(ctan_models.size() == 1 and ctan_squad >= 0, "The local battle fixture materializes the Transcendent C’tan")
	if ctan_models.is_empty() or ctan_squad < 0:
		quit(1)
		return
	var ctan := ctan_models[0]
	check(AbilityCatalog.sources(state, ctan_squad, "reanimation-protocols") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "deep-strike") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "feel-no-pain-5") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "necrodermis") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "enslaved-star-god") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "ctan-shard") == [ctan] and AbilityCatalog.sources(state, ctan_squad, "transdimensional-displacement") == [ctan] and Abilities.deadly_demise_value(state, ctan) == "D6" and Abilities.cannot_be_warlord(state, ctan), "The Transcendent C’tan binds every local C’tan rule including Transdimensional Displacement")
	check(state.units[ctan].ranged_weapons.size() == 1 and str(state.units[ctan].ranged_weapons[0].profiles.standard.get("name", "")) == "Seismic assault" and state.units[ctan].melee_weapons.size() == 1 and str(state.units[ctan].melee_weapons[0].profiles.standard.get("name", "")) == "Crackling tendrils", "Fixed Seismic assault and Crackling tendrils materialize on the model")
	check(Abilities.damage(state, ctan, 3) == 2 and Abilities.damage(state, ctan, 1) == 1, "Necrodermis subtracts one allocated Damage to a minimum of one")

	for model: int in state.units:
		state.units[model].on_battlefield = false
		state.units[model].position = Vector2.ZERO
	state.units[ctan].on_battlefield = true
	state.units[ctan].position = Vector2(-10, -8)
	state.units[ctan].wounds = 16
	var marine := units_for(state, "intercessor-squad")[0]
	state.units[marine].on_battlefield = true
	state.units[marine].position = Vector2(-4, -8)
	state.phase = "movement"
	state.active = 1
	check(Combat.movement_choice_error(state, 1, ctan, "transdimensional_advance", state.revision).is_empty(), "The admitted Transcendent C’tan can choose Transdimensional Displacement")
	check(Combat.begin_movement(state, 1, ctan, "transdimensional_advance", state.revision, six).is_empty(), "Transdimensional Displacement begins as an Advance")
	check(Combat.move(state, 1, ctan, Vector2(8, -8), state.revision).is_empty() and Combat.finish_movement(state, 1, state.revision).is_empty(), "Transdimensional Displacement can cross an enemy model and finish more than 8 inches away")

	scripted_dice = [6]
	var demise_state: Dictionary = state.duplicate(true)
	demise_state.units[ctan].wounds = 0
	var demise := DeadlyDemise.begin(demise_state, [ctan], Callable(self, "next_die"))
	check(str(demise.get("error", "")).is_empty() and int(demise.get("mortal_wounds", demise.get("amount", 0))) >= 0, "Deadly Demise D6 remains available on the Transcendent C’tan path")

	if failures == 0: print("Transcendent C’tan scoped local checks: passed")
	else: print("Transcendent C’tan checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

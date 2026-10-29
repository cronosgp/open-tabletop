extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const GrimaldusRules = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const DamageAllocation = preload("res://scripts/edition_11/damage_allocation.gd")
const UNIT := "chaplain-grimaldus"
const UNIT_ID := "40kdc:11e:adeptus-astartes:chaplain-grimaldus"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func one() -> int:
	return 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [entry(UNIT, 4), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	return result

func model_with_role(state: Dictionary, owner: int, role: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and str(state.units[model].get("chaplain_grimaldus_role", "")) == role: return model
	return -1

func matches_weapon(actual: Dictionary, range_inches: float, attacks: int, skill: int, strength: int, ap: int, damage: int, keywords: Dictionary) -> bool:
	return float(actual.get("range_inches", -1.0)) == range_inches and int(actual.get("attacks", -1)) == attacks and int(actual.get("skill", -1)) == skill and int(actual.get("strength", -1)) == strength and int(actual.get("ap", 99)) == ap and int(actual.get("damage", -1)) == damage and actual.get("keywords", {}) == keywords

func option(state: Dictionary, owner: int, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, owner):
		if str(candidate.get("action", "")) != action: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		return candidate
	return {}

func select_relic(state: Dictionary, relic: String) -> Dictionary:
	state.phase = "command"
	state.active = 1
	state.turn = 2
	state.combat_doctrines.selected_turn[1] = state.turn
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)
	var chaplain := model_with_role(state, 1, "chaplain")
	var selected := option(state, 1, "grimaldus-temple-relic", int(state.units[chaplain].squad), chaplain, relic)
	return C.UnitActions.apply(state, 1, selected, Vector2.ZERO, Callable()) if not selected.is_empty() else {"error": "Temple Relic choice missing."}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000162" and profile.get("source_datasheet_id", "") == "000002792" and profile.get("source_snapshot_id", "") == "20261021T130623Z", "Grimaldus cites the Black Templars App datasheet in the verified local snapshot")
	check(profile.get("source_manifest_sha256", "") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256", "") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Grimaldus records both source manifest hashes")
	check(profile.get("points_by_models", {}) == {4: 120} and profile.get("models", 0) == 4 and profile.get("base_size_source_mm", []) == [40, 28.5, 28.5, 28.5], "The 120-point four-model composition and mixed bases match the export")
	var roles: Array = profile.get("model_loadouts", [])
	check(roles.size() == 4 and roles[0].get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4} and roles.slice(1).all(func(row: Dictionary) -> bool: return row.get("stats", {}) == {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 1, "leadership_target": 8, "objective_control": 1, "invulnerable_target": 4}), "Chaplain and Cenobyte characteristics are kept per model")
	var weapons_match := false
	if roles.size() == 4 and not roles[0].get("ranged", []).is_empty() and not roles[0].get("melee", []).is_empty() and not roles[1].get("melee", []).is_empty():
		var pistol_profiles: Dictionary = roles[0].ranged[0].get("profiles", {})
		var crozius_profile: Dictionary = roles[0].melee[0].get("profiles", {}).get("standard", {})
		var servitor_profile: Dictionary = roles[1].melee[0].get("profiles", {}).get("standard", {})
		weapons_match = matches_weapon(pistol_profiles.get("standard", {}), 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}) and matches_weapon(pistol_profiles.get("supercharge", {}), 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true}) and matches_weapon(crozius_profile, 0.0, 6, 2, 6, -2, 2, {}) and matches_weapon(servitor_profile, 0.0, 1, 4, 3, 0, 1, {})
	check(weapons_match, "Every Plasma Pistol, Artificer crozius and Servitor combat-weapon stat matches the verified source profiles")
	check(roles[0].get("keywords", []).has("CHARACTER") and roles[0].get("keywords", []).has("EPIC HERO") and not roles[1].get("keywords", []).has("CHARACTER"), "Only Grimaldus carries the Character and Epic Hero model keywords")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS[UNIT].validation_status == "source_bounded_local_scope_passed_2026_10_28", "The profile's bounded local scope passed and is admitted")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 4, "cost": 120}], "The consolidated catalog exposes Grimaldus's four-model 120-point choice")
	check(AbilityCatalog.RULES.get(UNIT, []).has("leader") and AbilityCatalog.RULES[UNIT].has("feel-no-pain-5") and AbilityCatalog.RULES[UNIT].has("temple-relics") and AbilityCatalog.RULES[UNIT].has("faithful-cenobytes") and AbilityCatalog.RULES[UNIT].has("litanies-of-the-devout"), "All source abilities are registered")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["assault-intercessor-squad", "infernus-squad", "intercessor-squad", "crusader-squad", "sword-brethren-squad"], "All five source-listed Leader targets are registered")
	check(Registry.KNOWN.get("temple-relics", {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Registry.KNOWN.get("faithful-cenobytes", {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Registry.KNOWN.get("litanies-of-the-devout", {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "All three new ability scopes match the verified local result")

	var state := fixture()
	if state.has("error"):
		check(false, "Grimaldus focused fixture materializes: %s" % str(state.get("error", "")))
	else:
		var grimaldus_models := models_for(state, 1, UNIT)
		var chaplain := model_with_role(state, 1, "chaplain")
		var cenobyte := model_with_role(state, 1, "cenobyte")
		var bodyguard := -1
		for model: int in state.units:
			if int(state.units[model].owner) == 1 and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad": bodyguard = model; break
		var enemy := -1
		for model: int in state.units:
			if int(state.units[model].owner) == 2 and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad": enemy = model; break
		var squad := int(state.units[chaplain].squad)
		check(grimaldus_models.size() == 4 and chaplain >= 0 and cenobyte >= 0 and bodyguard >= 0 and enemy >= 0, "The mixed Chaplain/Cenobyte unit materializes as four models")
		check(C.UnitAbilities.has(state, squad, "litanies-of-the-devout") and C.UnitAbilities.has(state, squad, "feel-no-pain-5"), "Living Grimaldus provides his unit abilities")
		check(UnitPrevention.rules(state, cenobyte).has({"target": 5, "against": "any"}), "Feel No Pain 5+ applies to the unit")
		check(TransportRules.capacity_cost(state, squad, {}) == 1, "Three Cenobytes take zero transport capacity; Grimaldus takes one")
		var bodyguard_squad := int(state.units[bodyguard].squad)
		check(C.UnitActions.attachment_allowed(state, chaplain, bodyguard_squad), "Grimaldus can attach to a listed Intercessor Squad")
		var attach := option(state, 1, "attach", bodyguard_squad, chaplain)
		var attached := C.UnitActions.apply(state, 1, attach, Vector2.ZERO, Callable()) if not attach.is_empty() else {"error": "No Leader attachment choice."}
		var all_attached := true
		for model: int in grimaldus_models:
			if int(state.units[model].squad) != bodyguard_squad: all_attached = false
		check(attached.get("error", "").is_empty() and all_attached and not state.squads.has(squad), "Attaching Grimaldus preserves all three Cenobytes in the new Leader unit")
		check(TransportRules.capacity_cost(state, bodyguard_squad, {}) == 6, "Attached unit capacity counts the five Intercessors and Grimaldus, but not Cenobytes")
		state.units[chaplain].wounds = 0
		var cascade := GrimaldusRules.destroy_cenobytes(state, chaplain)
		check(cascade.size() == 3 and C.living(state, bodyguard_squad).size() == 5, "Destroying Grimaldus also destroys all remaining Cenobytes while retaining the Bodyguard")

	var damage_state := fixture()
	if not damage_state.has("error"):
		var damaged_chaplain := model_with_role(damage_state, 1, "chaplain")
		var damaged_cenobytes: Array[int] = []
		for model: int in models_for(damage_state, 1, UNIT):
			if str(damage_state.units[model].get("chaplain_grimaldus_role", "")) == "cenobyte": damaged_cenobytes.append(model)
		damage_state.units[damaged_chaplain].wounds = 1
		var result := {"prevented_wounds": 0, "prevention_rolls": [], "dice_history": [], "unsaved": 0, "normal_damage_applied": 0,
			"devastating_attacks_resolved": 0, "mortal_damage_applied": 0, "damage_applied": 0, "excess_damage_discarded": 0,
			"damage_rolls": [], "models_destroyed": 0, "casualty_retention_rolls": [], "allocations": []}
		damage_state.pending_attack = {"unit_prevention": UnitPrevention.snapshot(damage_state), "current": {
			"steps": [{"kind": "normal", "save_roll": 2}], "cursor": 0, "weapon": {"keywords": {}}, "result": result}}
		var allocated := DamageAllocation._apply_rolled_damage(damage_state, damaged_chaplain, {"value": 1, "rolls": []}, Callable(self, "one"))
		var all_destroyed := damaged_chaplain >= 0 and int(damage_state.units[damaged_chaplain].wounds) == 0
		for model: int in damaged_cenobytes:
			if int(damage_state.units[model].wounds) != 0: all_destroyed = false
		check(allocated.get("error", "").is_empty() and all_destroyed and int(damage_state.pending_attack.current.result.models_destroyed) == 4,
			"Actual damage allocation destroys Grimaldus and all three Cenobytes, recording four casualties")

	var advance_state := fixture()
	if not advance_state.has("error"):
		var chosen := select_relic(advance_state, "advance-and-charge")
		var relic_model := model_with_role(advance_state, 1, "chaplain")
		var relic_squad := int(advance_state.units[relic_model].squad)
		check(chosen.get("error", "").is_empty(), "The movement Temple Relic can be selected: %s" % str(chosen.get("error", "")))
		check(GrimaldusRules.active_relic(advance_state, relic_squad, "advance-and-charge"), "The movement Temple Relic is recorded as active")
		check(C.UnitAbilities.advance_modifier(advance_state, relic_squad) == 1 and C.UnitAbilities.charge_modifier(advance_state, relic_squad) == 1, "The movement Temple Relic grants +1 to Advance and Charge")
		advance_state.turn += 1
		check(GrimaldusRules.active_relic(advance_state, relic_squad, "advance-and-charge"), "Temple Relic remains active through the opponent's turn")
		advance_state.turn += 1
		check(not GrimaldusRules.active_relic(advance_state, relic_squad, "advance-and-charge"), "Temple Relic expires at the start of the next friendly Command phase")

	var toughness_state := fixture()
	if not toughness_state.has("error"):
		var chosen := select_relic(toughness_state, "toughness")
		var servitor := model_with_role(toughness_state, 1, "cenobyte")
		check(chosen.get("error", "").is_empty() and C.DefenderGroups.profile(toughness_state, servitor).get("toughness", 0) == 5, "The Toughness relic grants +1 Toughness to the unit")

	var melee_state := fixture()
	if not melee_state.has("error"):
		var chosen := select_relic(melee_state, "melee-ap")
		var fighter := model_with_role(melee_state, 1, "chaplain")
		var target_model := -1
		for model: int in melee_state.units:
			if int(melee_state.units[model].owner) == 2 and C.UnitAbilities.identity(melee_state.units[model]) == "intercessor-squad": target_model = model; break
		var target_squad := int(melee_state.units[target_model].squad)
		for model: int in melee_state.units:
			if int(melee_state.units[model].owner) == 1: melee_state.units[model].position = Vector2.ZERO
			else: melee_state.units[model].position = Vector2(1.5, 0.0)
		melee_state.phase = "fight"
		melee_state.active = 1
		melee_state.fight_step = "attacks"
		melee_state.fight_actor = 1
		var base_profile: Dictionary = melee_state.units[fighter].melee_weapons[0].profiles.standard
		var modified := C.UnitAbilities.weapon(melee_state, fighter, target_squad, base_profile, true)
		check(chosen.get("error", "").is_empty() and int(modified.get("ap", 0)) == int(base_profile.ap) - 1, "The melee relic grants +1 AP to the unit's melee attacks")
		var declarations: Array = C.AttackPlan.single_target(melee_state, int(melee_state.units[fighter].squad), target_squad, true)
		check(not declarations.is_empty(), "Grimaldus melee attacks are planned against an engaged target")
		var plan := C.AttackPlan.prepare(melee_state, int(melee_state.units[fighter].squad), true, declarations, true)
		var all_reroll := true
		for batch: Dictionary in plan.get("batches", []):
			if str(batch.get("context", {}).get("hit_reroll", "none")) != "all": all_reroll = false
		check(plan.get("error", "").is_empty() and all_reroll and not plan.get("batches", []).is_empty(), "Litanies of the Devout enables full melee Hit re-rolls in AttackPlan")

	if failures == 0: print("test_chaplain_grimaldus: OK")
	else: push_error("test_chaplain_grimaldus: %d failure(s)" % failures)
	quit(0 if failures == 0 else 1)

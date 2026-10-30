extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		entry("chaplain-with-jump-pack", 1),
		entry("assault-intercessors-with-jump-packs", 5),
		entry("vanguard-veteran-squad-with-jump-packs", 5),
		entry("intercessor-squad", 5)]
	return result

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity and int(unit.get("wounds", 0)) > 0:
			return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func weapon_batch(plan: Dictionary, weapon_name: String) -> Dictionary:
	for batch: Dictionary in plan.get("batches", []):
		if weapon_name in batch.get("labels", []):
			return batch
	return {}

func attack_entry(model: int, target: int, weapon: String, amount: int = 1) -> Dictionary:
	return {"model": model, "target": target, "amount": amount, "weapon": weapon, "profile": "standard"}

func run() -> void:
	var profile := Profiles.profile("chaplain-with-jump-pack")
	check(profile.get("name") == "Chaplain With Jump Pack" and profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000112" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "The profile keeps its exact common-book source identity and original runtime export stamp")
	check(profile.get("points_by_models", {}) == {1: 75} and profile.get("models") == 1 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 40.0 / (2.0 * 25.4)), "The source defines one Chaplain, 75 points and a 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "M12, T5, Sv3+, W4, Ld5+, OC1 and 4+ invulnerable save match the export")
	var expected_keywords: Array[String] = ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "CHAPLAIN", "JUMP PACK", "FLY", "ADEPTUS ASTARTES"]
	var profile_keywords: Array = profile.get("keywords", []).duplicate()
	expected_keywords.sort()
	profile_keywords.sort()
	check(profile_keywords == expected_keywords, "The profile has the complete source keyword set")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].id == "absolvor-bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "crozius-arcanum" and profile.get("additional_weapon_profiles", {}).is_empty(), "The fixed loadout contains the two source weapons and no runtime equipment choices")
	var pistol_profile: Dictionary = profile.ranged[0].profiles.standard
	var crozius_profile: Dictionary = profile.melee[0].profiles.standard
	check(pistol_profile == {"name": "Absolvor Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"close-quarters": true}}, "Absolvor Bolt Pistol matches the exported profile")
	check(crozius_profile == {"name": "Crozius Arcanum", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -1, "damage": 2, "keywords": {"cleave": 1}}, "Crozius Arcanum matches the exported profile")
	check(Catalog.SPECS.has("chaplain-with-jump-pack") and Roster.POINTS.get("chaplain-with-jump-pack", {}).get("sizes", {}) == {1: 75}, "The current local construction catalog offers this one-model datasheet")
	var roster := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("chaplain-with-jump-pack", 1)]})
	check(str(roster.get("error", "")).is_empty() and int(roster.get("total", 0)) == 75, "The local roster validator admits the current profile at its exported cost")
	check(LeaderLinks.TARGETS.get("chaplain-with-jump-pack", []) == ["assault-intercessors-with-jump-packs", "vanguard-veteran-squad-with-jump-packs"], "The common-book Leader map retains exactly the two in-scope Jump Pack bodyguards")

	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Both players materialize from current local Marine profiles")
	if state.has("error"):
		print("Chaplain With Jump Pack checks: %d failures; %s" % [failures + 1, str(state.get("error", ""))])
		quit(1)
		return
	state.awakened_dynasty.pending = []
	var chaplain_model := model_for(state, 1, "chaplain-with-jump-pack")
	var assault_squad := squad_for(state, 1, "assault-intercessors-with-jump-packs")
	var vanguard_squad := squad_for(state, 1, "vanguard-veteran-squad-with-jump-packs")
	var wrong_bodyguard := squad_for(state, 1, "intercessor-squad")
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(chaplain_model >= 0 and assault_squad >= 0 and vanguard_squad >= 0 and wrong_bodyguard >= 0 and enemy_squad >= 0, "The selected Chaplain, both source-listed bodyguards and comparison units are present: %d %d %d %d %d" % [chaplain_model, assault_squad, vanguard_squad, wrong_bodyguard, enemy_squad])
	if chaplain_model < 0 or assault_squad < 0 or vanguard_squad < 0 or wrong_bodyguard < 0 or enemy_squad < 0:
		print("Chaplain With Jump Pack checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(state, chaplain_model, assault_squad), "The Chaplain can lead Assault Intercessors With Jump Packs")
	check(C.UnitActions.attachment_allowed(state, chaplain_model, vanguard_squad), "The Chaplain can lead Vanguard Veteran Squad With Jump Packs")
	check(not C.UnitActions.attachment_allowed(state, chaplain_model, wrong_bodyguard), "The Chaplain cannot lead an unlisted Intercessor Squad")
	C.UnitActions.attach(state, chaplain_model, assault_squad)
	check(int(state.units[chaplain_model].get("squad", -1)) == assault_squad and state.units[chaplain_model].get("attachment_role", "") == "leader", "The public setup path attaches the Chaplain to the selected Jump Pack bodyguard")
	check(C.UnitAbilities.has(state, assault_squad, "litany-of-hate") and C.UnitAbilities.has(state, assault_squad, "exhortation-of-rage"), "The living Chaplain exposes both datasheet abilities to its attached unit")
	check(C.UnitAbilities.every_model_has(state, assault_squad, "deep-strike"), "The Chaplain and attached Jump Pack bodyguards each have Deep Strike")
	check(int(state.squads[assault_squad].get("starting_strength", 0)) == 6, "The attached unit's starting strength includes the five bodyguards and the Leader model")

	var enemy_model := C.living(state, enemy_squad)[0]
	var index := 0
	for model: int in C.living(state, assault_squad):
		state.units[model].position = Vector2(float(index % 3) * 0.5, float(index / 3) * 0.5)
		index += 1
	index = 0
	for model: int in C.living(state, enemy_squad):
		state.units[model].position = Vector2(10.0, float(index) * 2.0)
		index += 1
	state.units[enemy_model].position = Vector2(10.0, 0.0)
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.turn = 1
	state.active = 1
	state.phase = "shooting"

	var equipment_pistol := Equipment.select(state, chaplain_model, false, "absolvor-bolt-pistol", "standard")
	var equipment_crozius := Equipment.select(state, chaplain_model, true, "crozius-arcanum", "standard")
	check(str(equipment_pistol.get("error", "")).is_empty() and equipment_pistol.get("stats", {}) == pistol_profile, "Equipment exposes the fixed Absolvor Bolt Pistol")
	check(str(equipment_crozius.get("error", "")).is_empty() and equipment_crozius.get("stats", {}) == crozius_profile, "Equipment exposes the fixed Crozius Arcanum")
	var ranged_entries: Array = [attack_entry(chaplain_model, enemy_squad, "absolvor-bolt-pistol")]
	var ranged_plan := C.AttackPlan.prepare(state, assault_squad, false, ranged_entries, true)
	check(str(ranged_plan.get("error", "")).is_empty() and not weapon_batch(ranged_plan, "Absolvor Bolt Pistol").is_empty(), "The fixed ranged profile routes through the current-catalog AttackPlan")

	state.phase = "fight"
	state.units[enemy_model].position = state.units[chaplain_model].position + Vector2(state.units[chaplain_model].radius + state.units[enemy_model].radius + 0.8, 0.0)
	state.squads[assault_squad].charged = true
	var full_entries: Array = C.AttackPlan.single_target(state, assault_squad, enemy_squad, true)
	check(full_entries.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == chaplain_model and str(row.get("weapon", "")) == "crozius-arcanum" and int(row.get("amount", 0)) == 5), "The full attack plan allocates all five Crozius attacks from the Chaplain")
	var full_plan := C.AttackPlan.prepare(state, assault_squad, true, full_entries, true)
	var full_crozius := weapon_batch(full_plan, "Crozius Arcanum")
	check(not Morale.at_half_strength(state, assault_squad) and full_plan.get("error", "").is_empty() and not full_crozius.is_empty() and int(full_crozius.get("context", {}).get("wound_modifier", 0)) == 1 and not full_crozius.get("context", {}).get("free_wound_reroll", false), "Above half-strength, Litany grants Lance after a Charge but Exhortation grants no wound reroll: " + str(full_plan))
	var bodyguard_models: Array[int] = []
	for model: int in C.living(state, assault_squad):
		if model != chaplain_model: bodyguard_models.append(model)
	check(bodyguard_models.size() == 5, "Five source-listed bodyguard models are present")
	state.units[bodyguard_models[0]].wounds = 0
	var above_half_entries: Array = C.AttackPlan.single_target(state, assault_squad, enemy_squad, true)
	var above_half_plan := C.AttackPlan.prepare(state, assault_squad, true, above_half_entries, true)
	var above_half_crozius := weapon_batch(above_half_plan, "Crozius Arcanum")
	check(not Morale.at_half_strength(state, assault_squad) and not above_half_crozius.get("context", {}).get("free_wound_reroll", false), "Exhortation remains off while the attached unit is above half-strength")
	state.units[bodyguard_models[1]].wounds = 0
	state.units[bodyguard_models[2]].wounds = 0
	var half_entries: Array = C.AttackPlan.single_target(state, assault_squad, enemy_squad, true)
	var half_plan := C.AttackPlan.prepare(state, assault_squad, true, half_entries, true)
	var half_crozius := weapon_batch(half_plan, "Crozius Arcanum")
	var half_context: Dictionary = half_crozius.get("context", {})
	check(Morale.at_half_strength(state, assault_squad) and half_plan.get("error", "").is_empty() and half_context.get("free_wound_reroll", false) and half_context.get("free_wound_reroll_source", "") == "Exhortation of Rage" and half_context.get("wound_reroll", "none") == "none", "At exactly half-strength, Exhortation offers optional free wound rerolls in the actual Crozius attack plan: " + str(half_plan))
	state.units[bodyguard_models[3]].wounds = 0
	var below_half_entries: Array = C.AttackPlan.single_target(state, assault_squad, enemy_squad, true)
	var below_half_plan := C.AttackPlan.prepare(state, assault_squad, true, below_half_entries, true)
	var below_half_crozius := weapon_batch(below_half_plan, "Crozius Arcanum")
	check(Morale.at_half_strength(state, assault_squad) and below_half_crozius.get("context", {}).get("free_wound_reroll", false), "Exhortation remains active below half-strength")

	state.units[enemy_model].position = Vector2(5.0, 0.0)
	state.phase = "shooting"
	var half_ranged_plan := C.AttackPlan.prepare(state, assault_squad, false, ranged_entries, true)
	var half_pistol := weapon_batch(half_ranged_plan, "Absolvor Bolt Pistol")
	check(half_ranged_plan.get("error", "").is_empty() and not half_pistol.is_empty() and not half_pistol.context.get("free_wound_reroll", false), "Exhortation of Rage does not grant ranged wound rerolls")

	state.phase = "fight"
	state.pending_attack = {"player": 1, "current": {"checkpoint": {"phase": "wound", "context": half_context.duplicate(true), "effective_wounds": [5, 2], "rerolled_wounds": []}}}
	state.unit_abilities.window = {"kind": "wound", "owners": [1]}
	var reroll_choices: Array = C.UnitActions.choices(state, 1)
	var offers_success_reroll := false
	var offers_failed_reroll := false
	for option: Dictionary in reroll_choices:
		if str(option.get("action", "")) != "wound-reroll" or not str(option.get("label", "")).begins_with("Exhortation of Rage:"): continue
		if int(option.get("target", -1)) == 0: offers_success_reroll = true
		if int(option.get("target", -1)) == 1: offers_failed_reroll = true
	check(offers_success_reroll and offers_failed_reroll, "The optional Exhortation choice can reroll a successful or failed wound die")
	print("Chaplain With Jump Pack checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

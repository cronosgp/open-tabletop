extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:captain-with-jump-pack", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func ten_model_selections() -> Dictionary:
	var result := selections()
	result[1].entries[1].models = 10
	return result

func find_choice(state: Dictionary, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func submit_preparation_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No current Vanguard Veteran preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current Vanguard Veteran preparation decision does not offer this choice."}
	return Commands.execute(state, player, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}})

func _initialize() -> void:
	var profile := Profiles.profile("vanguard-veteran-squad-with-jump-packs")
	check(profile.source_datasheet_id == "000000147" and profile.source_book_id == "000000139" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Vanguard Veterans retain their Space Marines e11 source identity")
	check(profile.stats == {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and is_equal_approx(profile.base_radius_inches, 16.0 / 25.4), "Vanguard Veteran characteristics and 32 mm base match the local export")
	check(profile.points_by_models == {5: 110, 10: 220} and profile.third_plus_points_by_models == {5: 130, 10: 240} and profile.max_supported_copies == 3, "Both size prices, third-plus costs and the source-supported copy boundary are represented")
	var default_sergeant := Profiles.vanguard_veteran_weapons(true)
	var default_veteran := Profiles.vanguard_veteran_weapons(false)
	check(default_sergeant.ranged[0].id == "heavy-bolt-pistol" and default_sergeant.melee[0].id == "relic-blade" and default_veteran.ranged[0].profiles.standard.strength == 5 and default_veteran.melee[0].profiles.standard.attacks == 3, "Default Sergeant and Veteran loadouts match their distinct source roles")
	check(default_sergeant.melee[0].profiles.standard.target_restricted_traits == {"lethal-hits": ["MONSTER", "VEHICLE"]} and default_sergeant.melee[0].profiles.standard.keywords.cleave == 1, "Relic Blade carries its source Cleave and target-restricted Lethal Hits")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 10, "copies": 1}]})
	check(five.error.is_empty() and five.total == 110 and ten.error.is_empty() and ten.total == 220, "Five- and ten-model formations are admitted at their extracted prices")
	var three_five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 3}]})
	var three_ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 10, "copies": 3}]})
	check(three_five.error.is_empty() and three_five.total == 350 and three_ten.error.is_empty() and three_ten.total == 680, "The existing copy-tier catalog prices third five- and ten-model units at 130 and 240 points")
	var too_many := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs", "models": 5, "copies": 4}]})
	check(not too_many.error.is_empty(), "The source-supported three-copy limit rejects a fourth Vanguard Veteran unit")
	var ten_model_battle := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, ten_model_selections())
	check(not ten_model_battle.has("error"), "The ten-model formation materializes for the expanded source-option check")
	if not ten_model_battle.has("error"):
		ten_model_battle.phase = "deployment"
		ten_model_battle.unit_abilities.setup_players = []
		check(UnitActions.attachment_allowed(ten_model_battle, 100, 3), "Captain With Jump Pack is eligible to lead the ten-model Vanguard Veteran formation")
		UnitActions.attach(ten_model_battle, 100, 3)
		ten_model_battle.awakened_dynasty.pending = []
		var ten_model_plasma_choices := 0
		var ordinary_models: Array[int] = []
		for model: int in ten_model_battle.units:
			if int(ten_model_battle.units[model].get("squad", -1)) == 3 and not bool(ten_model_battle.units[model].get("sergeant", false)): ordinary_models.append(model)
		ordinary_models.sort()
		for index: int in mini(4, ordinary_models.size()):
			var model: int = ordinary_models[index]
			var ten_plasma_choice := find_choice(ten_model_battle, "vanguard-veteran-pistol", model, "plasma-pistol")
			if not ten_plasma_choice.is_empty() and submit_preparation_choice(ten_model_battle, 1, ten_plasma_choice).get("error", "").is_empty(): ten_model_plasma_choices += 1
		var fifth_offered := false
		if ordinary_models.size() > 4: fifth_offered = not find_choice(ten_model_battle, "vanguard-veteran-pistol", ordinary_models[4], "plasma-pistol").is_empty()
		check(ordinary_models.size() == 9 and ten_model_plasma_choices == 4 and not fifth_offered, "A ten-model unit allows four ordinary Plasma Pistols and withholds a fifth (models %d; selected %d; strength %d; fifth offered %s)" % [ordinary_models.size(), ten_model_plasma_choices, int(ten_model_battle.squads[3].starting_strength), str(fifth_offered)])
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Captain and Vanguard Veteran Jump Pack profiles materialize from the local catalog")
	if state.has("error"):
		print("Vanguard Veteran checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(UnitActions.attachment_allowed(state, 100, 3), "Captain With Jump Pack has its source-recorded Vanguard Veteran Leader link")
	UnitActions.attach(state, 100, 3)
	state.awakened_dynasty.pending = []
	check(Abilities.every_model_has(state, 3, "deep-strike") and Abilities.has(state, 3, "vanguard-assault"), "Deep Strike and Vanguard Assault are active on the assembled unit")
	var reserve_battle := state.duplicate(true)
	var reserve_choice: Dictionary = {}
	for option: Dictionary in UnitActions.choices(reserve_battle, 1):
		if option.action == "reserve" and int(option.target) == 3:
			reserve_choice = option
			break
	var reserve_result := submit_preparation_choice(reserve_battle, 1, reserve_choice) if not reserve_choice.is_empty() else {"error": "The attached Jump Pack unit was not offered reserves."}
	var veteran_reserve_models := 0
	var all_veterans_reserved := true
	for model: int in reserve_battle.units:
		if int(reserve_battle.units[model].get("squad", -1)) != 3: continue
		veteran_reserve_models += 1
		all_veterans_reserved = all_veterans_reserved and not bool(reserve_battle.units[model].get("on_battlefield", true))
	check(reserve_result.get("error", "").is_empty() and int(reserve_battle.unit_abilities.reserves.get(3, {}).get("cost", 0)) == 200 and veteran_reserve_models == 6 and all_veterans_reserved and 3 not in reserve_battle.deployment.order, "The attached Vanguard Veterans can enter Strategic Reserves with the Leader-inclusive roster cost")
	check("DEATHWING" not in state.units[300].keywords, "Conditional Deathwing is not added to the shared-book Jump Pack squad outside Dark Angels context")
	var shield := find_choice(state, "vanguard-veteran-pistol", 301, "combat-shield")
	var prep_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_choice := var_to_bytes(state)
	var wrong_owner := submit_preparation_choice(state, 2, shield)
	var stale_option := submit_preparation_choice(state, 1, shield, str(prep_decision.get("decision_id", "")), "stale-option")
	check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and before_choice == var_to_bytes(state), "Wrong-owner and stale Vanguard Veteran choices are rejected unchanged")
	check(not shield.is_empty() and submit_preparation_choice(state, 1, shield).get("error", "").is_empty(), "A model can replace its Heavy Bolt Pistol with a Combat Shield through the public command")
	check(Groups.profile(state, 301).invulnerable_target == 5 and Groups.profile(state, 302).invulnerable_target == 0 and state.units[301].ranged_weapons.is_empty(), "Combat Shield removes the pistol and grants an individual 5+ invulnerable save only to its bearer")
	var restore_pistol := find_choice(state, "vanguard-veteran-pistol", 301, "heavy-bolt-pistol")
	check(not restore_pistol.is_empty() and submit_preparation_choice(state, 1, restore_pistol).get("error", "").is_empty() and Groups.profile(state, 301).invulnerable_target == 0 and state.units[301].ranged_weapons[0].id == "heavy-bolt-pistol", "Replacing the Combat Shield with a pistol restores the bearer's ordinary save and Heavy Bolt Pistol")
	shield = find_choice(state, "vanguard-veteran-pistol", 301, "combat-shield")
	check(not shield.is_empty() and submit_preparation_choice(state, 1, shield).get("error", "").is_empty(), "An ordinary Veteran can reselect the Combat Shield before choosing a different pistol")
	var plasma := find_choice(state, "vanguard-veteran-pistol", 301, "plasma-pistol")
	check(not plasma.is_empty() and submit_preparation_choice(state, 1, plasma).get("error", "").is_empty(), "An equipped Combat Shield can be replaced by a Plasma Pistol through the public command")
	check(state.units[301].ranged_weapons[0].profiles.supercharge.keywords.hazardous and state.units[301].ranged_weapons[0].profiles.standard.attacks == 1, "Both extracted Plasma Pistol modes are available")
	for model: int in [302]:
		plasma = find_choice(state, "vanguard-veteran-pistol", model, "plasma-pistol")
		if not plasma.is_empty(): check(submit_preparation_choice(state, 1, plasma).get("error", "").is_empty(), "An ordinary-model Plasma Pistol selection uses the public command")
	check(find_choice(state, "vanguard-veteran-pistol", 303, "plasma-pistol").is_empty() and find_choice(state, "vanguard-veteran-pistol", 304, "plasma-pistol").is_empty(), "Two ordinary Plasma Pistols is the five-model cap")
	var sergeant_plasma := find_choice(state, "vanguard-veteran-pistol", 300, "plasma-pistol")
	check(not sergeant_plasma.is_empty() and submit_preparation_choice(state, 1, sergeant_plasma).get("error", "").is_empty(), "The Sergeant's independent Plasma Pistol option does not consume the ordinary-model limit")
	check(state.units[300].ranged_weapons[0].profiles.standard.strength == 7 and state.units[300].ranged_weapons[0].profiles.supercharge.strength == 8, "The Sergeant's plasma choice retains both source profile values")
	var sergeant_shield := find_choice(state, "vanguard-veteran-pistol", 300, "combat-shield")
	check(not sergeant_shield.is_empty() and submit_preparation_choice(state, 1, sergeant_shield).get("error", "").is_empty() and Groups.profile(state, 300).invulnerable_target == 5 and state.units[300].ranged_weapons.is_empty(), "The Sergeant may independently replace their pistol with a Combat Shield")
	sergeant_plasma = find_choice(state, "vanguard-veteran-pistol", 300, "plasma-pistol")
	check(not sergeant_plasma.is_empty() and submit_preparation_choice(state, 1, sergeant_plasma).get("error", "").is_empty() and Groups.profile(state, 300).invulnerable_target == 0, "The Sergeant can replace the shield with a Plasma Pistol and loses the bearer-only save")
	var power_fist_choice := find_choice(state, "vanguard-veteran-melee", 300, "power-fist")
	check(not power_fist_choice.is_empty() and submit_preparation_choice(state, 1, power_fist_choice).get("error", "").is_empty() and state.units[300].melee_weapons[0].id == "power-fist", "Sergeant can replace the Relic Blade with a Power Fist through the public command")
	var relic_blade_choice := find_choice(state, "vanguard-veteran-melee", 300, "relic-blade")
	check(not relic_blade_choice.is_empty() and submit_preparation_choice(state, 1, relic_blade_choice).get("error", "").is_empty() and state.units[300].melee_weapons[0].id == "relic-blade", "Sergeant can select the source-default Relic Blade after a replacement")
	var hammer := find_choice(state, "vanguard-veteran-melee", 300, "thunder-hammer")
	check(not hammer.is_empty() and submit_preparation_choice(state, 1, hammer).get("error", "").is_empty() and state.units[300].melee_weapons[0].profiles.standard.keywords.get("devastating-wounds", false), "Sergeant may replace the Relic Blade with a Devastating Wounds Thunder Hammer through the public command")
	state.squads[3].charged = false
	check(Abilities.melee_bonus(state, 3) == 0, "Vanguard Assault is inactive before the unit charges")
	state.squads[3].charged = true
	check(Abilities.melee_bonus(state, 3) == 1 and Abilities.weapon(state, 300, 2, state.units[300].melee_weapons[0].profiles.standard, true).attacks == 4, "Vanguard Assault adds one melee Attack after the assembled unit charges")
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20 if state.units[model].owner == 1 else 20, model % 5)
	state.units[300].position = Vector2.ZERO
	state.units[303].position = Vector2.ZERO
	state.units[200].position = Vector2(1.5, 0)
	var heavy_pistol_plan := C.AttackPlan.prepare(state, 3, false, [{"model": 303, "target": 2, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}], true)
	check(heavy_pistol_plan.get("error", "").is_empty() and heavy_pistol_plan.get("batches", []).size() == 1 and heavy_pistol_plan.batches[0].weapon.strength == 5 and heavy_pistol_plan.batches[0].weapon.skill == 3 and heavy_pistol_plan.batches[0].weapon.ap == -1 and heavy_pistol_plan.batches[0].weapon.damage == 1 and state.units[303].ranged_weapons[0].profiles.standard.keywords.get("close-quarters", false) and C.AttackPlan.legal_targets(state, 303, false, "heavy-bolt-pistol", "standard") == [2], "Heavy Bolt Pistol source stats and Close-quarters eligibility reach AttackPlan")
	var plasma_standard_plan := C.AttackPlan.prepare(state, 3, false, [{"model": 300, "target": 2, "amount": 1, "weapon": "plasma-pistol", "profile": "standard"}], true)
	var plasma_supercharge_plan := C.AttackPlan.prepare(state, 3, false, [{"model": 300, "target": 2, "amount": 1, "weapon": "plasma-pistol", "profile": "supercharge"}], true)
	check(plasma_standard_plan.error.is_empty() and plasma_standard_plan.batches[0].weapon.strength == 7 and plasma_standard_plan.batches[0].weapon.ap == -2 and plasma_standard_plan.batches[0].weapon.damage == 1 and plasma_standard_plan.hazardous_count == 0, "Standard Plasma Pistol source stats reach AttackPlan without Hazardous")
	check(plasma_supercharge_plan.error.is_empty() and plasma_supercharge_plan.batches[0].weapon.strength == 8 and plasma_supercharge_plan.batches[0].weapon.ap == -3 and plasma_supercharge_plan.batches[0].weapon.damage == 2 and plasma_supercharge_plan.hazardous_count == 1, "Supercharge Plasma Pistol source stats and Hazardous reach AttackPlan")
	var both_plasma_modes := C.AttackPlan.prepare(state, 3, false, [
		{"model": 300, "target": 2, "amount": 1, "weapon": "plasma-pistol", "profile": "standard"},
		{"model": 300, "target": 2, "amount": 1, "weapon": "plasma-pistol", "profile": "supercharge"}], true)
	check(not both_plasma_modes.error.is_empty(), "A single Plasma Pistol cannot select Standard and Supercharge together")
	state.units[303].position = Vector2(-20, 3)
	state.phase = "fight"
	var hammer_entries := C.AttackPlan.single_target(state, 3, 2, true)
	var hammer_plan := C.AttackPlan.prepare(state, 3, true, hammer_entries, true)
	check(hammer_plan.error.is_empty() and hammer_entries.size() == 1 and hammer_plan.batches.size() == 1 and hammer_plan.batches[0].count == 4 and hammer_plan.batches[0].weapon.strength == 8 and hammer_plan.batches[0].weapon.skill == 4 and hammer_plan.batches[0].weapon.ap == -2 and hammer_plan.batches[0].weapon.damage == 3 and hammer_plan.batches[0].weapon.keywords.get("devastating-wounds", false) and hammer_plan.batches[0].context.attack_sources[0].expression == 4, "Thunder Hammer source stats and Devastating Wounds reach the charged Fight plan with Vanguard Assault's extra Attack (%s; %s; %s)" % [str(hammer_plan.get("error", "")), str(hammer_entries), str(hammer_plan.get("batches", []))])
	var fist_battle := state.duplicate(true)
	fist_battle.units[300].melee_weapons = Profiles.vanguard_veteran_weapons(true, "plasma-pistol", "power-fist").melee.duplicate(true)
	var fist_entries := C.AttackPlan.single_target(fist_battle, 3, 2, true)
	var fist_plan := C.AttackPlan.prepare(fist_battle, 3, true, fist_entries, true)
	check(fist_plan.error.is_empty() and fist_plan.batches.size() == 1 and fist_plan.batches[0].weapon.strength == 8 and fist_plan.batches[0].weapon.skill == 3 and fist_plan.batches[0].weapon.ap == -2 and fist_plan.batches[0].weapon.damage == 2 and fist_plan.batches[0].context.attack_sources[0].expression == 4, "Sergeant Power Fist profile reaches the charged Fight plan")
	var relic_battle := state.duplicate(true)
	relic_battle.units[300].melee_weapons = Profiles.vanguard_veteran_weapons(true, "plasma-pistol", "relic-blade").melee.duplicate(true)
	var relic_entries := C.AttackPlan.single_target(relic_battle, 3, 2, true)
	var relic_plan := C.AttackPlan.prepare(relic_battle, 3, true, relic_entries, true)
	check(relic_plan.error.is_empty() and relic_plan.batches.size() == 1 and relic_plan.batches[0].weapon.strength == 6 and relic_plan.batches[0].weapon.ap == -2 and relic_plan.batches[0].weapon.damage == 2 and relic_plan.batches[0].weapon.keywords.get("lethal-hits", false) and relic_plan.batches[0].count == 5 and relic_plan.batches[0].context.attack_sources[0].expression == 4, "Relic Blade source profile, Cleave and eligible Lethal Hits reach AttackPlan")
	relic_battle.units[200].keywords = ["MONSTER"]
	relic_entries = C.AttackPlan.single_target(relic_battle, 3, 2, true)
	var relic_monster_plan := C.AttackPlan.prepare(relic_battle, 3, true, relic_entries, true)
	check(relic_monster_plan.error.is_empty() and not relic_monster_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Relic Blade removes its source-conditional Lethal Hits against MONSTER targets")
	relic_battle.units[200].keywords = ["VEHICLE"]
	relic_entries = C.AttackPlan.single_target(relic_battle, 3, 2, true)
	var relic_vehicle_plan := C.AttackPlan.prepare(relic_battle, 3, true, relic_entries, true)
	check(relic_vehicle_plan.error.is_empty() and not relic_vehicle_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Relic Blade removes its source-conditional Lethal Hits against VEHICLE targets")
	var veteran_battle := state.duplicate(true)
	veteran_battle.units[300].position = Vector2(-20, 0)
	veteran_battle.units[304].position = Vector2.ZERO
	var veteran_entries := C.AttackPlan.single_target(veteran_battle, 3, 2, true)
	var veteran_plan := C.AttackPlan.prepare(veteran_battle, 3, true, veteran_entries, true)
	check(veteran_plan.error.is_empty() and veteran_plan.batches.size() == 1 and veteran_plan.batches[0].weapon.strength == 5 and veteran_plan.batches[0].weapon.skill == 3 and veteran_plan.batches[0].weapon.ap == -2 and veteran_plan.batches[0].weapon.damage == 2 and veteran_plan.batches[0].context.attack_sources[0].expression == 4, "Ordinary Veteran Master-crafted Power Weapon receives Vanguard Assault through AttackPlan")
	var deathwing := ChapterRules.resolve_and_apply(state, {1: "none", 2: "none"}, {1: "DARK ANGELS"})
	check(deathwing.error.is_empty() and "DEATHWING" in state.units[300].keywords, "Dark Angels Chapter context applies the conditional Deathwing keyword to Vanguard Veterans")
	ChapterRules.resolve_and_apply(state, {1: "none", 2: "none"}, {1: ""})
	check("DEATHWING" not in state.units[300].keywords, "Vanguard Veterans lose conditional Deathwing outside Dark Angels context")
	print("Vanguard Veteran Jump Pack checks: %d failures" % failures)
	quit(1 if failures else 0)

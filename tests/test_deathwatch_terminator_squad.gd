extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const Deathwatch = preload("res://scripts/edition_11/deathwatch_terminatus_assault.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "deathwatch-terminator-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:deathwatch-terminator-squad"

var dice_values: Array[int] = []
var dice_index := 0
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func die() -> int:
	if dice_index >= dice_values.size(): return 6
	var value := dice_values[dice_index]
	dice_index += 1
	return value

func queue_dice(values: Array[int]) -> void:
	dice_values = values.duplicate()
	dice_index = 0

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry(UNIT, 5), entry(UNIT, 10), entry("captain")]
	result[2].entries = [entry(UNIT, 5), entry("captain")]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}
	}, lists())

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength < 0 or int(state.squads[squad].get("starting_strength", -1)) == strength: return squad
	return -1

func models_for(state: Dictionary, squad: int, identity: String = UNIT) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func find_model(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in models_for(state, squad):
		if bool(state.units[model].get("sergeant", false)) == sergeant: return model
	return -1

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	return {}

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func has_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> bool:
	return not find_choice(state, owner, action, squad, model, value).is_empty()

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, owner, find_choice(state, owner, action, squad, model, value))

func submit_reaction(state: Dictionary, player: int, target: int, value: String, roller: Callable) -> Dictionary:
	var decision := C.Stratagems.pending_decision(state)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if int(option.get("target", -1)) == target and str(option.get("value", "")) == value and int(option.get("details", {}).get("die", -1)) == -1:
			projected = option
			break
	if projected.is_empty(): return {"error": "The current roll decision does not offer %s." % value}
	var choice := {"action": "stratagem-reaction", "model": -1, "target": target, "value": value, "die": -1}
	var envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.COMMAND_REACTION, "choice": envelope, "revision": int(state.revision)}, roller)

func battle_state(source: Dictionary, charger: int, target: int, charger_model: int, target_model: int) -> Dictionary:
	var state: Dictionary = source.duplicate(true)
	state.phase = "charge"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.revision = 0
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.pending_charge = {}
	state.pending_contact = {}
	state.stratagems.pending = {}
	state.resolution_frames = []
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-25, -25) if int(state.units[model].owner) == 1 else Vector2(25, 25)
		if model not in [charger_model, target_model]: state.units[model].wounds = 0
	state.units[charger_model].wounds = int(state.units[charger_model].max_wounds)
	state.units[charger_model].position = Vector2.ZERO
	state.units[target_model].wounds = int(state.units[target_model].max_wounds)
	state.units[target_model].position = Vector2(6, 0)
	state.units[target_model].keywords = ["ADEPTUS ASTARTES", "ORKS"]
	state.squads[charger].charged = false
	state.squads[charger].charge_declared = false
	state.squads[charger].battle_shocked = false
	state.squads[target].battle_shocked = true
	state.units[target_model].enhancement_id = Enhancements.TEMPERED_IN_BATTLE
	state.combat_doctrines.detachments = {1: Enhancements.WRATH_OF_THE_ROCK, 2: Enhancements.WRATH_OF_THE_ROCK}
	state.combat_doctrines.detachment = Enhancements.WRATH_OF_THE_ROCK
	return state

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	var snapshot_hash := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
	var slice_hash := "bb1f51192a559283a25ee27ff5d87cb25252f1e99d806d7dca5949e86d51f093"
	check(profile.get("name") == "Deathwatch Terminator Squad" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000003873", "The profile maps to the exact current Deathwatch datasheet identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == snapshot_hash and profile.get("source_slice_manifest_sha256") == slice_hash, "The profile records the verified export snapshot and sliced source hashes")
	check(profile.get("points_by_models", {}) == {5: 190, 10: 380} and profile.get("third_plus_points_by_models", {}) == {5: 230, 10: 420} and profile.get("base_size_source_mm") == 40, "Both unit sizes, later-copy prices and 40 mm bases match the pinned export")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "The shared Deathwatch Terminator profile matches the exported characteristics")
	check(["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "TERMINATOR", "IMPERIUM"].all(func(keyword: String) -> bool: return keyword in profile.get("keywords", [])), "The datasheet keywords are retained")
	check(profile_weapon("ranged", "storm-bolter") == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "The Storm Bolter profile matches the export")
	check(profile_weapon("melee", "power-fist").attacks == 3 and profile_weapon("melee", "power-fist").strength == 8 and profile_weapon("melee", "power-fist").damage == 2, "The default Power Fist profile matches the export")
	check(profile_weapon("ranged", "assault-cannon").keywords == {"sustained-hits": 1} and profile_weapon("ranged", "heavy-flamer").keywords == {"torrent": true, "blast": 2}, "The Assault Cannon and Heavy Flamer traits are recorded")
	check(profile_weapon("ranged", "cyclone-missile-launcher", "frag").keywords == {"blast": 2} and profile_weapon("ranged", "cyclone-missile-launcher", "krak").damage == "D3+3", "Both Cyclone Missile Launcher profiles are recorded")
	check(profile_weapon("ranged", "plasma-cannon", "standard").damage == 2 and profile_weapon("ranged", "plasma-cannon", "supercharge").keywords == {"blast": 1, "hazardous": true}, "Both Plasma Cannon modes are recorded")
	check(profile_weapon("melee", "chainfist", "hunter").keywords == {"hunter": ["Monster", "Vehicle"]} and profile_weapon("melee", "twin-lightning-claws").keywords == {"twin-linked": true}, "The Chainfist and Twin Lightning Claws options retain their traits")
	check(profile.get("wargear_costs", {}) == {"storm-shield": 5, "cyclone-missile-launcher": 10} and profile.get("options", {}).get("max_special_weapons", 0) == 3, "Priced and capped options are source-bounded")
	check(Catalog.SPECS.has(UNIT) and Abilities.RULES.get(UNIT, []) == ["deep-strike", "combat-doctrines", "deathwatch-terminatus-assault", "teleport-homer", "storm-shield"], "The distinct Deathwatch rule set is registered")
	check(UNIT in LeaderLinks.targets("ancient-in-terminator-armour") and UNIT in LeaderLinks.targets("captain-in-terminator-armour") and UNIT in LeaderLinks.targets("chaplain-in-terminator-armour") and UNIT in LeaderLinks.targets("librarian-in-terminator-armour"), "All four source-listed Terminator Leaders can target this unit")
	check(UNIT in SupportAttachments.links("ancient-in-terminator-armour"), "The source-listed Terminator Ancient Support attachment is available")
	check(CapabilityRegistry.known("deathwatch-terminatus-assault") and CapabilityRegistry.known("terminatus-assault"), "Deathwatch and Terminator Assault Squad rules remain separately identified")

	var state := fresh_state()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Five- and ten-model Deathwatch Terminator units materialize from the local catalog: " + state_error)
	if not state_error.is_empty():
		print("Deathwatch Terminator Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, UNIT, 5)
	var large := find_squad(state, 1, UNIT, 10)
	var opposing := find_squad(state, 2, UNIT, 5)
	var captain_squad := find_squad(state, 2, "captain")
	var models := models_for(state, small)
	var sergeant := find_model(state, small, true)
	var ordinary := find_model(state, small, false)
	var initial_training_cost := int(state.squads[small].get("training_cost", -1))
	check(small > 0 and large > 0 and opposing > 0 and captain_squad > 0 and models.size() == 5 and models_for(state, large).size() == 10, "Both source-priced sizes and opposing copies are materialized")
	check(initial_training_cost == 190 and int(state.squads[large].get("training_cost", -1)) == 380 and int(state.squads[opposing].get("training_cost", -1)) == 190, "Prepared unit costs match the source size prices")
	check(int(state.units[ordinary].get("max_wounds", -1)) == 3 and C.DefenderGroups.profile(state, ordinary).invulnerable_target == 4 and C.UnitActions.has_teleport_homer(state, small), "Each model has three Wounds, the unit has its baseline 4++ and the squad receives Teleport Homer")
	check(has_choice(state, 1, "deathwatch-terminator-loadout", small, ordinary, "thunder-hammer-storm-shield"), "The sourced per-model weapon packages are offered during army preparation")
	var shielded := choose(state, 1, "deathwatch-terminator-loadout", small, ordinary, "thunder-hammer-storm-shield")
	check(str(shielded.get("error", "")).is_empty() and int(state.units[ordinary].max_wounds) == 4 and int(state.squads[small].training_cost) == initial_training_cost + 5 and C.DefenderGroups.profile(state, ordinary).invulnerable_target == 4, "Thunder Hammer + Storm Shield adds one Wound and five points without changing the baseline invulnerable save")
	var restored := choose(state, 1, "deathwatch-terminator-loadout", small, ordinary, "power-fist")
	check(str(restored.get("error", "")).is_empty() and int(state.units[ordinary].max_wounds) == 3 and int(state.squads[small].training_cost) == initial_training_cost, "The default Power Fist + Storm Bolter package reverses the shield's wound and points")
	var cycloned := choose(state, 1, "terminator-special-weapon", small, models[1], "cyclone-missile-launcher")
	check(str(cycloned.get("error", "")).is_empty() and state.units[models[1]].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "storm-bolter") and state.units[models[1]].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "cyclone-missile-launcher") and int(state.squads[small].training_cost) == initial_training_cost + 10, "The priced Cyclone keeps the Storm Bolter and costs ten points")
	var assaulted := choose(state, 1, "terminator-special-weapon", small, models[2], "assault-cannon")
	var flamed := choose(state, 1, "terminator-special-weapon", small, models[3], "heavy-flamer")
	check(str(assaulted.get("error", "")).is_empty() and str(flamed.get("error", "")).is_empty() and not has_choice(state, 1, "terminator-special-weapon", small, models[4], "plasma-cannon"), "The five-model unit permits up to three special weapons and withholds a fourth")
	var plasmad := choose(state, 1, "terminator-special-weapon", small, models[3], "plasma-cannon")
	check(str(plasmad.get("error", "")).is_empty() and state.units[models[3]].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "plasma-cannon" and weapon.get("profiles", {}).has("standard") and weapon.get("profiles", {}).has("supercharge")), "Replacing a special option exposes both Plasma Cannon firing modes")
	var forced_package := {"action": "deathwatch-terminator-loadout", "model": models[1], "target": small, "value": "twin-lightning-claws"}
	var before_invalid_package := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forced_package).is_empty() and before_invalid_package == var_to_bytes(state), "A melee package that removes the Storm Bolter cannot coexist with a special replacement")
	var no_special := choose(state, 1, "terminator-special-weapon", small, models[1], "none")
	var claws := choose(state, 1, "deathwatch-terminator-loadout", small, models[1], "twin-lightning-claws")
	check(str(no_special.get("error", "")).is_empty() and str(claws.get("error", "")).is_empty() and state.units[models[1]].ranged_weapons.is_empty() and state.units[models[1]].melee_weapons[0].id == "twin-lightning-claws", "Twin Lightning Claws replace the Power Fist and Storm Bolter")
	var unauthorized := find_choice(state, 1, "deathwatch-terminator-loadout", small, ordinary, "storm-bolter-chainfist")
	var before_wrong_owner_package := var_to_bytes(state)
	check(not unauthorized.is_empty() and not PublicUnitCommand.error(state, 2, unauthorized).is_empty() and before_wrong_owner_package == var_to_bytes(state), "The opposing player cannot alter a Deathwatch Terminator loadout")

	var charger := models[0]
	var enemy_model := C.living(state, captain_squad)[0]
	var battle := battle_state(state, small, captain_squad, charger, enemy_model)
	check(C.UnitAbilities.has(battle, small, "deathwatch-terminatus-assault") and C.UnitAbilities.has(battle, small, "teleport-homer") and Deathwatch.modifier(battle, captain_squad) == -1 and Deathwatch.engaged_targets(battle, small).is_empty(), "The separate Deathwatch rule and Teleport Homer are enabled; Terminatus Assault applies -1 only against a non-Imperium/non-Chaos unit, and unengaged units are not tested")
	battle.units[enemy_model].position = Vector2(2, 0)
	battle.units[enemy_model].enhancement_id = ""
	battle.squads[captain_squad].battle_shocked = false
	battle.combat_doctrines.detachments = {1: "none", 2: "none"}
	battle.combat_doctrines.detachment = "none"
	queue_dice([1, 1])
	var failed_result := Deathwatch.begin_charge(battle, small, 1, Callable(self, "die"), false)
	check(str(failed_result.get("error", "")).is_empty() and failed_result.get("pending", {}).is_empty() and bool(battle.squads[captain_squad].battle_shocked), "A failed post-charge test Battle-shocks the engaged enemy when no Leadership re-roll applies")
	battle.units[enemy_model].keywords = ["ADEPTUS ASTARTES", "IMPERIUM"]
	check(Deathwatch.modifier(battle, captain_squad) == 0, "The modifier is absent when the target has IMPERIUM")

	var reroll_state := battle_state(state, small, captain_squad, charger, enemy_model)
	var cp_before := int(reroll_state.cp[1])
	queue_dice([2, 2])
	var declared := C.declare_charge(reroll_state, 1, charger, reroll_state.revision, Callable(self, "die"))
	var charge_decision := C.Stratagems.pending_decision(reroll_state)
	var free_charge_reroll := false
	for option: Dictionary in charge_decision.get("legal_options", []):
		if int(option.get("target", -1)) == small and str(option.get("value", "")) == "deathwatch-terminatus-assault": free_charge_reroll = true
	check(str(declared.get("error", "")).is_empty() and free_charge_reroll, "The rule opens a source-specific Charge re-roll without spending Command Points")
	queue_dice([5, 5])
	var charge_reaction := submit_reaction(reroll_state, 1, small, "deathwatch-terminatus-assault", Callable(self, "die"))
	check(str(charge_reaction.get("error", "")).is_empty() and int(reroll_state.pending_charge.get("maximum", 0)) == 10 and int(reroll_state.cp[1]) == cp_before, "The free re-roll replaces both Charge dice and preserves the rolled distance")
	var target_choice := C.select_charge_target(reroll_state, 1, enemy_model, reroll_state.revision)
	var contact_error := C.begin_contact_move(reroll_state, 1, charger, "charge", reroll_state.revision)
	var plan := C.Contact.charge_plan(reroll_state, small, captain_squad, int(reroll_state.pending_charge.get("maximum", 0)))
	check(str(target_choice.get("error", "")).is_empty() and contact_error.is_empty() and str(plan.get("error", "")).is_empty(), "The rerolled charge can enter the normal contact-placement flow")
	for model: int in plan.get("positions", {}):
		check(C.stage_contact_move(reroll_state, 1, model, plan.positions[model], reroll_state.revision).is_empty(), "The sourced contact plan stages each living Deathwatch model")
	queue_dice([1, 1])
	var finished := MatchCommandService.execute(reroll_state, 1, {"kind": MatchCommandService.FINISH_CONTACT, "revision": reroll_state.revision}, Callable(self, "die"))
	var morale_window := C.Stratagems.pending(reroll_state)
	var morale_decision := C.Stratagems.pending_decision(reroll_state)
	var current_test: Dictionary = morale_window.get("current_result", {})
	check(str(finished.get("error", "")).is_empty() and bool(reroll_state.squads[small].charged) and morale_window.get("kind", "") == Deathwatch.BATTLE_SHOCK_WINDOW and int(morale_decision.get("priority_player_id", -1)) == 2, "The confirmed charge suspends for the engaged enemy controller's optional Leadership re-roll")
	check(current_test.get("rolls", []) == [1, 1] and int(current_test.get("modifier", 0)) == -1 and bool(reroll_state.squads[captain_squad].battle_shocked), "The modifier and pre-existing Battle-shock remain legible while the result awaits its controller")
	var restored_battle: Dictionary = bytes_to_var(var_to_bytes(reroll_state))
	check(C.Stratagems.pending_decision(restored_battle).get("decision_id", "") == morale_decision.get("decision_id", "") and C.ResolutionFrames.current(restored_battle) == C.ResolutionFrames.current(reroll_state), "The Leadership choice and suspended Charge frame survive save/resume")
	var before_wrong_owner_morale := var_to_bytes(restored_battle)
	var wrong_owner := submit_reaction(restored_battle, 1, captain_squad, "tempered-in-battle", Callable(self, "die"))
	check(not str(wrong_owner.get("error", "")).is_empty() and before_wrong_owner_morale == var_to_bytes(restored_battle), "The charging player cannot choose the defender's Leadership re-roll")
	queue_dice([6, 6])
	var leadership_reroll := submit_reaction(restored_battle, 2, captain_squad, "tempered-in-battle", Callable(self, "die"))
	var final_morale: Dictionary = restored_battle.get("last_morale", [{}])[0] if not restored_battle.get("last_morale", []).is_empty() else {}
	check(str(leadership_reroll.get("error", "")).is_empty() and final_morale.get("rerolled_from", []) == [1, 1] and final_morale.get("rolls", []) == [6, 6] and bool(final_morale.get("passed", false)), "The defender can replace the full 2D6 result through the public command")
	check(bool(restored_battle.squads[captain_squad].battle_shocked) and C.ResolutionFrames.current(restored_battle).is_empty(), "Passing outside the Command phase preserves existing Battle-shock and resumes post-charge resolution")

	print("Deathwatch Terminator Squad source-bounded checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

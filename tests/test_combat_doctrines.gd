extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const D = C.Doctrines
const Save = preload("res://scripts/match_save.gd")
var failures := 0
var calls := 0
func six() -> int:
	calls += 1
	return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(gladius: bool = true, equipped: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 1, false, equipped)
	state.terrain.areas = []
	for id: int in state.units:
		state.units[id].wounds = state.units[id].max_wounds if id in [100, 200] else 0
	state.units[100].position = Vector2(-5, -5)
	state.units[200].position = Vector2(4, -5)
	state.squads[1].weapon.keywords.erase("assault")
	if equipped:
		for instance: Dictionary in state.units[100].ranged_weapons:
			for profile: Dictionary in instance.profiles.values(): profile.keywords.erase("assault")
	D.enable(state, gladius)
	C.advance_phase(state, 1, state.revision)
	return state
func choose(state: Dictionary, doctrine: String) -> String:
	return C.select_combat_doctrine(state, 1, doctrine, state.revision)
func next_command(state: Dictionary) -> void:
	state.turn += 2
	state.active = 1
	state.phase = "start_turn"
	C.advance_phase(state, 1, state.revision)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"combat_doctrines": false}).pack_hash, "Disabled setup identity is unchanged")
	check(P.initial_state().pack_hash != P.initial_state({"combat_doctrines": true}).pack_hash and P.initial_state({"combat_doctrines": 1}).has("error"), "Explicit 11e manifest and strict boolean option")
	check(P.initial_state({"combat_doctrines": true}).pack_hash == P.initial_state({"combat_doctrines": true, "marine_detachment": "gladius"}).pack_hash, "Gladius remains the default identity for older setup records")
	check(P.initial_state({"combat_doctrines": true, "marine_detachment": "stormlance"}).match_manifest.marine_detachment == "stormlance", "Stormlance selection is sealed into match identity")
	var configured_stormlance := P.initial_state({"combat_doctrines": true, "marine_detachment": "stormlance", "unit_abilities": true, "core_stratagems": true})
	check(configured_stormlance.has("detachment_stratagems") and configured_stormlance.capabilities["stormlance-sudden-onslaught"].enabled and configured_stormlance.match_manifest.detachment_stratagems == C.DetachmentStratagems.ID, "Stormlance stratagem implementation is enabled only with current unit data and core stratagems")
	check(P.initial_state({"marine_detachment": "stormlance"}).has("error") and P.initial_state({"combat_doctrines": true, "marine_detachment": "unknown"}).has("error"), "Detachment requires Combat Doctrines and a supported choice")
	check(P.initial_state({"combat_doctrines": true, "marine_detachment": "stormlance", "official_mission": true}).has("error"), "Stormlance cannot claim compatibility with the selected CA mission")
	check(P.initial_state({"combat_doctrines": true, "oath_of_moment": true}).has("error"), "Current doctrines cannot mix with historical Oath")
	var storm_state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 1, false, false)
	for id: int in storm_state.units:
		if storm_state.units[id].owner == 1:
			storm_state.units[id].definition_id = "40kdc:11e:adeptus-astartes:outrider-squad"
			if id not in [100, 101]: storm_state.units[id].wounds = 0
	storm_state.units[100].keywords = ["ADEPTUS ASTARTES", "MOUNTED"]
	storm_state.units[100].movement = 12
	storm_state.squads[3] = storm_state.squads[1].duplicate(true)
	storm_state.units[101].squad = 3
	storm_state.units[101].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
	storm_state.units[101].movement = 6
	D.enable(storm_state, "stormlance")
	check(storm_state.capabilities["lightning-fast-strike"].enabled and is_equal_approx(C.movement_remaining(storm_state, 100), 14.0) and is_equal_approx(C.movement_remaining(storm_state, 101), 6.0), "Stormlance adds 2 inches only to Adeptus Astartes Mounted or Speeder models")
	storm_state.units[101].squad = 1
	check(is_equal_approx(C.movement_remaining(storm_state, 100), 12.0), "Mixed attached keyword sets do not inherit Stormlance movement")
	storm_state.units[101].squad = 3
	storm_state.units[100].keywords = ["ADEPTUS ASTARTES", "SPEEDER"]
	check(is_equal_approx(C.movement_remaining(storm_state, 100), 14.0), "Stormlance covers Speeder units")
	var sudden_state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 1, false, false)
	for id: int in sudden_state.units:
		if sudden_state.units[id].owner == 1:
			sudden_state.units[id].definition_id = "40kdc:11e:adeptus-astartes:outrider-squad"
			sudden_state.units[id].keywords = ["ADEPTUS ASTARTES", "MOUNTED"]
			sudden_state.units[id].movement = 12
	D.enable(sudden_state, "stormlance")
	C.UnitAbilities.enable(sudden_state)
	C.Stratagems.enable(sudden_state)
	C.DetachmentStratagems.enable_stormlance(sudden_state)
	sudden_state.phase = "movement"
	sudden_state.active = 1
	sudden_state.cp[1] = 1
	var dice_before_sudden := calls
	check(C.begin_movement(sudden_state, 1, 100, "advance", sudden_state.revision, Callable(), true).is_empty() and sudden_state.cp[1] == 0 and sudden_state.last_command_roll.rolls == [6] and calls == dice_before_sudden, "Sudden Onslaught spends 1 CP and replaces the Advance D6 with 6 without rolling")
	check(is_equal_approx(C.movement_remaining(sudden_state, 100), 20.0), "Sudden Onslaught applies fixed Advance 6, Stormlance +2 Movement and existing modifiers")
	var wind_state := sudden_state.duplicate(true)
	wind_state.phase = "fight"
	wind_state.active = 2
	wind_state.cp[1] = 1
	wind_state.board_size = Vector2(60, 44)
	wind_state.squads[1].fight_eligible = true
	wind_state.squads[1].fought = true
	wind_state.unit_abilities.window = {"kind": "end", "owners": [1]}
	var wind_choice := {"action": "detachment-stratagem", "model": -1, "target": 1, "value": C.DetachmentStratagems.WIND_SWIFT}
	var wind_result := C.DetachmentStratagems.apply(wind_state, 1, wind_choice)
	check(wind_result.error.is_empty() and wind_state.cp[1] == 0 and wind_state.unit_abilities.window.kind == "tactical-fluidity-placement" and wind_state.unit_abilities.window.get("wind_swift", false) and is_equal_approx(wind_state.unit_abilities.window.distance_by_model.get(100, 0.0), 14.0), "Wind-Swift remains available after the unit fought and previews its Movement characteristic with the Stormlance bonus")
	var wind_completion := C.UnitActions.apply(wind_state, 1, {"action": "fluidity-confirm", "model": -1, "target": 1, "value": ""}, Vector2.ZERO, Callable())
	check(wind_completion.error.is_empty() and wind_state.squads[1].move_type == "normal" and wind_state.squads[1].moved and wind_state.unit_abilities.window.kind == "end", "Wind-Swift confirms a coherent Normal Move and resumes the end-Fight decision window")
	var fall_state := sudden_state.duplicate(true)
	fall_state.phase = "fight"
	fall_state.active = 2
	fall_state.cp[1] = 1
	fall_state.board_size = Vector2(60, 44)
	fall_state.terrain.areas = []
	fall_state.squads[1].fight_eligible = true
	for model: int in C.living(fall_state, 1): fall_state.units[model].position = Vector2(5.0, float(model - 100) * 1.4)
	for model: int in C.living(fall_state, 2):
		if model == 200: fall_state.units[model].position = Vector2(3, 0)
		else: fall_state.units[model].wounds = 0
	var fall_choice := {"action": "detachment-stratagem", "model": -1, "target": 1, "value": C.DetachmentStratagems.WIND_SWIFT}
	var fall_result := C.DetachmentStratagems.apply(fall_state, 1, fall_choice)
	var fall_move_error: String = str(fall_result.get("error", ""))
	if fall_move_error.is_empty() and fall_state.unit_abilities.window.mode == "fallback":
		for model: int in fall_state.unit_abilities.window.positions:
			fall_move_error = C.UnitActions.apply(fall_state, 1, {"action": "fluidity-place", "model": model, "target": 1, "value": ""}, fall_state.units[model].position + Vector2(4, 0), Callable()).get("error", "")
			if not fall_move_error.is_empty(): break
		if fall_move_error.is_empty(): fall_move_error = C.UnitActions.apply(fall_state, 1, {"action": "fluidity-confirm", "model": -1, "target": 1, "value": ""}, Vector2.ZERO, Callable()).get("error", "")
	check(fall_move_error.is_empty() and fall_state.squads[1].fell_back and fall_state.squads[1].move_type == "fall_back", "Wind-Swift completes a Fall Back from engagement and resumes the Fight end window: " + str(fall_move_error))
	var hurtling_state := sudden_state.duplicate(true)
	hurtling_state.phase = "shooting"
	hurtling_state.active = 2
	hurtling_state.cp[1] = 1
	check(C.DetachmentStratagems.use_hurtling(hurtling_state, 1, 1).is_empty() and hurtling_state.cp[1] == 0 and C.DetachmentStratagems.hurtling_active(hurtling_state, 1), "Hurtling Targets spends CP and records the Stormlance defender effect for the Shooting phase")
	var reaction_state := sudden_state.duplicate(true)
	reaction_state.phase = "shooting"
	reaction_state.active = 2
	reaction_state.cp[1] = 1
	reaction_state.pending_move = {}
	reaction_state.pending_contact = {}
	reaction_state.terrain.areas = []
	reaction_state.squads[1].moved = false
	reaction_state.units[100].moved = false
	reaction_state.units[100].position = Vector2(5, 0)
	reaction_state.units[200].position = Vector2(0, 0)
	var target_index := 0
	for target_model: int in C.living(reaction_state, 1):
		reaction_state.units[target_model].position = Vector2(5.0, float(target_index) * 1.4)
		target_index += 1
	var ranged_choices := C.AttackPlan.Equipment.choices(reaction_state, 200, false)
	var attack_entries: Array = []
	var hurtling_reaction_opened := false
	var hurtling_declaration_error := "no ranged weapon choice"
	if not ranged_choices.is_empty():
		var ranged: Dictionary = ranged_choices[0]
		attack_entries = [{"model": 200, "target": 1, "amount": int(ranged.stats.attacks), "weapon": str(ranged.weapon), "profile": str(ranged.profile)}]
		var declared := C.resolve_attack_plan(reaction_state, 2, 200, attack_entries, reaction_state.revision, false, true, func() -> int: return 6)
		hurtling_declaration_error = str(declared.get("error", ""))
		hurtling_reaction_opened = declared.error.is_empty() and reaction_state.unit_abilities.window.get("kind", "") == "stormlance-hurtling" and reaction_state.cp[1] == 1
	check(hurtling_reaction_opened, "Hurtling Targets opens a defender decision before ranged attack resolution: " + hurtling_declaration_error + " / " + str(reaction_state.unit_abilities.window))
	var hurtling_choice := {}
	for option: Dictionary in C.unit_choices(reaction_state, 1):
		if option.action == "hurtling-use": hurtling_choice = option
	var hurtling_use_error := "No Hurtling choice was offered."
	if not hurtling_choice.is_empty(): hurtling_use_error = C.unit_action(reaction_state, 1, hurtling_choice, Vector2.ZERO, reaction_state.revision, func() -> int: return 6)
	var resumed_plan := C.AttackPlan.prepare(reaction_state, 2, false, attack_entries, true)
	var hurtling_modifier := 0
	if resumed_plan.get("error", "").is_empty() and not resumed_plan.get("batches", []).is_empty(): hurtling_modifier = int(resumed_plan.batches[0].context.get("hit_modifier", 0))
	check(hurtling_use_error.is_empty() and reaction_state.cp[1] == 0 and hurtling_modifier == -1, "Choosing Hurtling consumes CP before dice and applies ranged -1 to Hit: " + hurtling_use_error + " / " + str(resumed_plan.get("error", "")))
	var state := fixture()
	check(D.needs_choice(state) and state.cp == {1: 0, 2: 0} and calls == 0, "Start-of-Command doctrine choice precedes core CP and dice")
	var before := var_to_bytes(state)
	check(not C.advance_phase(state, 1, state.revision, six).is_empty() and not C.begin_movement(state, 1, 100, "advance", state.revision, six).is_empty(), "Mandatory start choice blocks ordinary commands")
	check(not C.select_combat_doctrine(state, 2, "assault", state.revision).is_empty() and not C.select_combat_doctrine(state, 1, "assault", -1).is_empty() and not choose(state, "invented").is_empty(), "Wrong player, stale revision and unknown doctrine rejected")
	check(before == var_to_bytes(state) and calls == 0, "Rejected choices do not mutate state or dice")
	check(choose(state, "none").is_empty() and D.active_for(state, 1).is_empty() and D.available(state, 1).size() == 3 and state.cp == {1: 1, 2: 1}, "Declining preserves all uses and proceeds to core CP once")
	check(not choose(state, "assault").is_empty() and state.cp == {1: 1, 2: 1}, "Cannot change decision or gain CP twice")
	next_command(state)
	check(choose(state, "assault").is_empty() and D.active_for(state, 1) == "assault" and D.active_for(state, 2).is_empty(), "Doctrine applies to admitted Marine army only")
	state.active = 2
	state.phase = "command"
	D.start_command(state)
	check(D.active_for(state, 1) == "assault" and not D.needs_choice(state), "Effect persists through enemy Command without granting enemy a choice")
	next_command(state)
	check(D.active_for(state, 1).is_empty() and D.needs_choice(state), "Old doctrine expires before next own choice")
	check(choose(state, "assault").is_empty() and state.combat_doctrines.extra_used[1], "Gladius can spend its one shared extra use on a repeated doctrine")
	next_command(state)
	check("assault" not in D.available(state, 1) and not choose(state, "assault").is_empty(), "Third use forbidden")
	choose(state, "tactical")
	next_command(state)
	check("tactical" not in D.available(state, 1) and choose(state, "devastator").is_empty(), "Gladius extra use is shared across doctrines, not one extra each")
	next_command(state)
	check(not D.needs_choice(state) and state.cp == {1: 6, 2: 6}, "After all uses are spent, Command gains core CP without a useless choice")
	state = fixture(false)
	choose(state, "devastator")
	next_command(state)
	check("devastator" not in D.available(state, 1) and not state.combat_doctrines.extra_used.get(1, false), "Army rule without Gladius permits each doctrine once")
	state = fixture(false)
	state.combat_doctrines.detachment = "assault-brethren"
	state.combat_doctrines.gladius = false
	check(choose(state, "assault").is_empty(), "Assault Doctrine can be selected as the army's first use")
	next_command(state)
	check(choose(state, "tactical").is_empty(), "A different doctrine can still use its ordinary once-per-battle selection")
	next_command(state)
	check("assault" in D.available(state, 1) and "tactical" not in D.available(state, 1), "Assault Mastery reserves the detachment's extra doctrine use for Assault")
	check(choose(state, "assault").is_empty() and state.combat_doctrines.extra_used.get(1, false), "Assault Mastery permits one additional Assault Doctrine selection")
	next_command(state)
	check("assault" not in D.available(state, 1) and not choose(state, "assault").is_empty(), "Assault Mastery does not grant a third Assault Doctrine use")
	state = fixture(false)
	state.combat_doctrines.detachment = "terminator-storm-force"
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "TERMINATOR"]
	check(D.charge_bonus(state, 1) == 1 and D.charge_bonus(state, 2) == 0, "Death Blow adds 1 to charge rolls for friendly Terminator units only")
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
	check(D.charge_bonus(state, 1) == 0, "Death Blow does not affect a non-Terminator unit")
	state = fixture(false)
	state.combat_doctrines.detachment = "tacticus-firestorm-force"
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"]
	var rapid_fire_profile := {"keywords": {"rapid-fire": true}, "range_inches": 24.0}
	check(D.rapid_fire_active(state, 1, rapid_fire_profile, 24.0) and not D.rapid_fire_active(state, 1, rapid_fire_profile, 24.1), "Codex Fire-patterns grants Rapid Fire at any distance within maximum weapon range")
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
	check(not D.rapid_fire_active(state, 1, rapid_fire_profile, 18.0), "Codex Fire-patterns is limited to Tacticus units")
	state = fixture(false)
	state.combat_doctrines.detachment = "tacticus-attack-force"
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"]
	state.phase = "movement"
	state.active = 1
	state.squads[1].moved = false
	var wrath_cp: int = state.cp[1]
	var wrath_open := C.begin_movement(state, 1, 100, "advance", state.revision, func() -> int: return 2)
	var wrath_window: Dictionary = state.stratagems.pending
	var wrath_reroll := C.resolve_roll_reaction(state, 1, 1, "wrath-of-the-chapter", state.revision, func() -> int: return 6)
	check(wrath_open.is_empty() and wrath_window.get("kind", "") == "after_advance_roll" and wrath_window.get("wrath_chapter", false) and wrath_reroll.is_empty() and state.cp[1] == wrath_cp and state.pending_move.bonus == 6, "Wrath of the Chapter offers a free post-roll Advance re-roll to Tacticus and applies its new result")
	state = fixture(false)
	state.combat_doctrines.detachment = "gravis-linebreaker-force"
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "GRAVIS"]
	state.squads[1].normal_moved_this_turn = true
	state.squads[1].moved_distance = 4.0
	check(D.walking_fortress(state, 1) and not D.walking_fortress(state, 2), "Walking Fortress activates after a Normal move for friendly Gravis only")
	state.squads[1].weapon.keywords.heavy = true
	var fortress_plan := C.AttackPlan.prepare(state, 1, false, [{"model": 100, "target": 2, "amount": 1}], true)
	check(fortress_plan.error.is_empty() and fortress_plan.batches[0].context.hit_modifier == 1 and not fortress_plan.batches[0].weapon.keywords.get("heavy", false), "Walking Fortress removes Heavy and adds +1 to Hit on Gravis ranged attacks after the Normal move")
	state.squads[1].normal_moved_this_turn = false
	check(not D.walking_fortress(state, 1), "Walking Fortress does not activate without a Normal move")
	state = fixture(false)
	state.combat_doctrines.detachment = "wrath-of-the-rock"
	state.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
	check(C.UnitAbilities.defensive_wound_modifier(state, 1, 5, 4) == -1 and C.UnitAbilities.defensive_wound_modifier(state, 1, 4, 4) == 0 and C.UnitAbilities.defensive_wound_modifier(state, 2, 5, 4) == 0, "Dutiful Tenacity applies -1 to Wound only against S greater than T for friendly Infantry")
	# Actual Advance flow: doctrine grants Assault to each server-owned ranged profile.
	for equipped in [false, true]:
		state = fixture(true, equipped)
		choose(state, "devastator")
		C.advance_phase(state, 1, state.revision, six)
		check(C.begin_movement(state, 1, 100, "advance", state.revision, six).is_empty() and C.finish_movement(state, 1, state.revision).is_empty(), "Advance roll and zero-distance confirmation retain move type")
		state.phase = "shooting"
		var choice := C.AttackPlan.Equipment.select(state, 100, false)
		check(not choice.stats.keywords.get("assault", false) and D.weapon(state, 1, choice.stats, false).keywords.assault, "Effective Assault keyword does not mutate source weapon")
		check(2 in C.AttackPlan.legal_targets(state, 100, false), "Devastator allows advanced ranged targeting")
		var plan := C.AttackPlan.single_target(state, 1, 2, false)
		check(C.attack_plan_error(state, 1, 100, plan, state.revision, false).is_empty(), "Legacy and equipped plans accept Devastator shooting")
		check(not C.can_start_action(state, 1), "Doctrine does not waive action restrictions after Advance")
		state.phase = "charge"
		check(not C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Devastator does not allow advance-charge")
		state.squads[1].advanced = false
		state.squads[1].fell_back = true
		state.phase = "shooting"
		check(not C.attack_window_error(state, 1, 100, state.revision, false).is_empty(), "Devastator does not waive Fall Back shooting restriction")
	state = fixture()
	choose(state, "assault")
	C.advance_phase(state, 1, state.revision, six)
	C.begin_movement(state, 1, 100, "advance", state.revision, six)
	C.finish_movement(state, 1, state.revision)
	state.phase = "shooting"
	check(C.AttackPlan.legal_targets(state, 100, false).is_empty(), "Assault Doctrine does not grant the Assault weapon keyword")
	state.phase = "charge"
	check(C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Assault permits a real Advance followed by charge declaration")
	state = fixture()
	choose(state, "tactical")
	C.advance_phase(state, 1, state.revision, six)
	state.units[200].position = Vector2(-3.5, -5)
	check(C.begin_movement(state, 1, 100, "ordered_retreat", state.revision).is_empty(), "Tactical does not bypass requirement to be engaged for Fall Back")
	check(C.move(state, 1, 100, Vector2(-9, -5), state.revision).is_empty() and C.finish_movement(state, 1, state.revision).is_empty(), "Actual Fall Back still needs legal movement and leaving engagement")
	state.phase = "shooting"
	check(C.attack_window_error(state, 1, 100, state.revision, false).is_empty(), "Tactical permits shooting after actual Fall Back")
	check(not C.can_start_action(state, 1), "Tactical does not waive Fall Back action restriction")
	state.phase = "charge"
	check(C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Tactical permits charge after actual Fall Back")
	state = fixture()
	choose(state, "assault")
	state.phase = "charge"
	state.squads[1].advanced = true
	state.squads[1].started_action_turn = state.turn
	check(not C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Doctrine never bypasses action/engagement restrictions")
	state.units[100].definition_id = "40kdc:11e:necrons:necron-warriors"
	check(D.active_for(state, 1).is_empty(), "Foreign or mixed faction cannot inherit doctrine")
	var marine_list: Dictionary = P.Training.Capabilities.reference_army("Space Marines").list
	var necron_list: Dictionary = P.Training.Capabilities.reference_army("Necrons").list
	# Current local Wahapedia prices can exceed the historical 500-point training snapshot.
	# Raise both training limits equally so the persistence check still tests the same setup path.
	marine_list.category = "custom"
	necron_list.category = "custom"
	marine_list.points_limit = 1000
	necron_list.points_limit = 1000
	var marine := P.Training.inspect(marine_list)
	var necron := P.Training.inspect(necron_list)
	if not marine.get("error", "").is_empty() or not necron.get("error", "").is_empty():
		push_error("Current reference training lists must admit: %s / %s" % [marine.get("error", ""), necron.get("error", "")])
		quit(1)
		return
	state = P.initial_state({"combat_doctrines": true, "unit_abilities": true}, {1: marine.selection, 2: necron.selection})
	if state.has("error"):
		push_error("Current reference lists must build a doctrine match: " + str(state.error))
		quit(1)
		return
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.combat_doctrines.gladius, "Saved lists freeze declared Gladius effect and reconstruct identity")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.combat_doctrines_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "start_turn"
	game._reset_history()
	game._request_end()
	check(game.action_groups.doctrine.container.visible and not game.doctrine_confirm.disabled and game.end_button.disabled, "Required doctrine choice is focused in Play")
	var saved_state: Dictionary = game.state.duplicate(true)
	var saved_rng: int = game.rng.state
	game._save_match()
	game._load_match()
	check(game.combat_doctrines and game.state == saved_state and game.rng.state == saved_rng, "Pending start choice survives save before core CP gain")
	game.doctrine_choice.select(game.doctrine_choice.get_item_index(3))
	game._request_combat_doctrine()
	check(D.active_for(game.state, 1) == "assault" and game.state.cp == {1: 1, 2: 1} and game.rng.state == saved_rng, "UI selection applies doctrine without dice or CP cost")
	game.state.phase = "charge"
	game.state.squads[1].advanced = true
	game.state.units[200].position = game.state.units[100].position + Vector2(8, 0)
	game.selected = 100
	game._refresh()
	check(not game.charge_button.disabled, "Charge UI reflects Assault eligibility")
	game._reset_history()
	game._save_match()
	saved_state = game.state.duplicate(true)
	game._load_match()
	check(game.state == saved_state and game.state.combat_doctrines.used[1] == ["assault"], "Active effect and spent-use record survive save")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("combat_doctrines")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.combat_doctrines and not game.state.has("combat_doctrines"), "Old saves default to disabled")
	old.config.combat_doctrines = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match()
	check(before == var_to_bytes(game.state) and "Combat Doctrines" in game.status.text, "Conflicting save option rejected")
	game.queue_free()
	await process_frame
	print("11E COMBAT DOCTRINES: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ContactMovement = preload("res://scripts/edition_11/contact_movement.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")
const WarHorde = preload("res://scripts/edition_11/war_horde.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func _base_state() -> Dictionary:
	return {
		"turn": 1,
		"battle_round": 1,
		"phase": "command",
		"cp": {0: 2, 1: 2},
		"warlords": {0: 1, 1: 2},
		"detachments": {0: "war-horde", 1: ""},
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"squads": {
			1: {
				"owner": 0, "moved": false, "advanced": false, "fell_back": false, "charged": false,
				"shot": false, "fought": false, "set_up_this_turn": false, "moved_distance": 0.0,
				"move_type": "stationary", "leader": -1, "attached": false, "support": [],
				"stats": {"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
			},
			2: {
				"owner": 1, "moved": false, "advanced": false, "fell_back": false, "charged": false,
				"shot": false, "fought": false, "set_up_this_turn": false, "moved_distance": 0.0,
				"move_type": "stationary", "leader": -1, "attached": false, "support": [],
				"stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
			}
		},
		"units": {
			10: {
				"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:warboss",
				"position": Vector2(0.0, 0.0), "radius": 0.787, "elevation": 0.0,
				"wounds": 6, "max_wounds": 6, "on_battlefield": true,
				"keywords": ["ORKS", "INFANTRY", "CHARACTER", "WARBOSS"],
				"abilities": ["waaagh", "da-boss", "leader"],
				"stats": {"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
				"ranged_weapons": [{"id": "kombi-weapon", "profiles": {"standard": {"id": "kombi-weapon", "name": "Kombi-weapon", "range_inches": 24.0, "attacks": 2, "skill": 5, "strength": 4, "ap": 0, "damage": 1, "keywords": {"anti-infantry": 4, "devastating-wounds": true}}}}],
				"melee_weapons": [{"id": "power-klaw", "profiles": {"standard": {"id": "power-klaw", "name": "Power klaw", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 10, "ap": -2, "damage": 2, "keywords": {}}}}]
			},
			20: {
				"owner": 1, "squad": 2, "definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad",
				"position": Vector2(0.9, 0.0), "radius": 0.63, "elevation": 0.0,
				"wounds": 2, "max_wounds": 2, "on_battlefield": true,
				"keywords": ["ADEPTUS ASTARTES", "INFANTRY"],
				"abilities": [],
				"stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
				"ranged_weapons": [], "melee_weapons": []
			}
		},
		"terrain": {"areas": []}
	}

func run() -> void:
	# 1. Cleave X attack generation
	var cleave_weapon := {"id": "cleaver", "name": "Deff Cleaver", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {"cleave": 2}}
	var def_16 := {"toughness": 4, "save_target": 3, "wounds_per_model": 2, "invulnerable_target": 0, "remaining_wounds": [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]}
	var single_res := Attacks.generate_attacks(cleave_weapon, {"weapon_count": 1, "target_model_count": 16, "single_target_for_cleave": true}, func() -> int: return 4)
	check(single_res.error.is_empty() and single_res.count == 9, "Cleave 2 against 16 models with single target adds +6 attacks (3 + 6 = 9)")
	var split_res := Attacks.generate_attacks(cleave_weapon, {"weapon_count": 1, "target_model_count": 16, "single_target_for_cleave": false}, func() -> int: return 4)
	check(split_res.error.is_empty() and split_res.count == 3, "Cleave 2 with split targets adds 0 bonus attacks")

	# 2. Conditioned weapon traits validation
	var cond_weapon := {"id": "snagga-choppa", "name": "Snagga choppa", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"devastating-wounds-monster-vehicle": true, "lethal-hits-non-monster-vehicle": true, "sustained-hits-monster-vehicle": 2}}
	var cond_err := Attacks._validate(cond_weapon, def_16, {"weapon_count": 1, "target_model_count": 1})
	check(cond_err.is_empty(), "Conditioned Orks weapon traits pass attack validation")

	# 3. Waaagh! / War Cry / riled up / Da Boss / Unstable Energies / Tokens
	var state := _base_state()
	check(OrksWaaagh.can_reroll_advance(state, 1), "Waaagh! unit can re-roll Advance rolls")
	check(Stratagems.open_roll(state, 0, 1, "after_advance_roll", [1]), "Waaagh! opens after_advance_roll window for free re-roll")
	check(OrksWaaagh.war_cry_available(state, 0), "War Cry is available in Command phase")
	var cry := OrksWaaagh.call_war_cry(state, 0)
	check(cry.error.is_empty() and 1 in cry.affected_squads and cry.until_turn == 2, "War Cry marks Waaagh! unit riled up until end of next turn")
	check(not OrksWaaagh.war_cry_available(state, 0), "War Cry is once per battle per army")
	check(OrksWaaagh.is_riled_up(state, 1), "Unit is riled up on turn 1")
	check(Groups.defender(state, 1).invulnerable_target == 5, "Riled up grants 5+ invulnerable save")
	state.squads[1].advanced = true
	check(Doctrines.charge_error(state, 1).is_empty(), "Riled up allows Charge after Advance")
	state.turn = 3
	check(not OrksWaaagh.is_riled_up(state, 1), "Riled up expires after end of next turn")

	var cp_granted := OrksWaaagh.apply_da_boss_round_cp(state, 1)
	check(cp_granted.get(0, 0) == 1 and state.cp[0] == 3, "Da Boss grants +1 CP at start of battle round when Warlord has Da Boss")
	check(OrksWaaagh.apply_da_boss_round_cp(state, 1).is_empty(), "Da Boss does not double-grant in the same battle round")

	# Unstable Energies
	state.units[10].definition_id = "40kdc:11e:orks:weirdboy"
	# Add weirdboy check only if in RULES; test directly via spend_psyker_level with temporary RULES or check gorkanaut for Super-heavy Walker
	# 4. War Horde Get Stuck In + Headwoppa's Killchoppa + Kunnin' But Brutal
	state.units[10].definition_id = "40kdc:11e:orks:warboss"
	state.turn = 1
	state.squads[1].charged = true
	state.units[10].enhancement = "headwoppas-killchoppa"
	var melee_prof := {"id": "power-klaw", "name": "Power klaw", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 10, "ap": -2, "damage": 2, "keywords": {}}
	WarHorde.apply_melee_weapon_bonuses(state, 1, 10, melee_prof)
	check(int(melee_prof.keywords.get("sustained-hits", 0)) == 1 and int(melee_prof.ap) == -3, "War Horde Get Stuck In grants Sustained Hits 1 and Headwoppa's Killchoppa grants +1 AP on charge")
	state.units[10].enhancement = "kunnin-but-brutal"
	state.squads[1].advanced = false
	state.squads[1].fell_back = true
	check(Doctrines.shoot_after_fallback(state, 1) and Doctrines.charge_error(state, 1).is_empty(), "Kunnin' But Brutal allows shoot and charge after Fall Back")

	# 5. Super-heavy Walker passage + consumable tokens
	check(OrksWaaagh.token_remaining(state, 1, "bomb-squigs", 2, 1) == 1, "Bomb Squigs capped at 1 per turn")
	check(OrksWaaagh.spend_token(state, 1, "bomb-squigs", 2, 1) and not OrksWaaagh.spend_token(state, 1, "bomb-squigs", 2, 1), "Cannot spend Bomb Squigs twice in one turn")
	state.turn = 4
	check(OrksWaaagh.spend_token(state, 1, "bomb-squigs", 2, 1) and OrksWaaagh.token_remaining(state, 1, "bomb-squigs", 2, 1) == 0, "Second Bomb Squig used on later turn exhausts twice-per-battle cap")

	state.units[10].definition_id = "40kdc:11e:orks:gorkanaut"
	state.units[10].keywords = ["ORKS", "VEHICLE", "TITANIC", "WALKER"]
	state.pending_move = {"squad": 1, "move_type": "normal"}
	state.terrain.areas = [{"category": "dense", "bounds": Rect2(0, 0, 10, 10), "features": [{"height": 3.5, "bounds": Rect2(2, -1, 1, 2)}, {"height": 5.0, "bounds": Rect2(5, -1, 1, 2)}]}]
	var obs := Terrain.movement_obstacles(state, 10)
	check(obs.size() == 1 and absf(obs[0].position.x - 5.0) < 0.01, "Super-heavy Walker ignores <=4 inch terrain features and is blocked by >4 inch features")
	var enemy_non_titanic := {"owner": 1, "keywords": ["ADEPTUS ASTARTES", "VEHICLE"]}
	var enemy_titanic := {"owner": 1, "keywords": ["ADEPTUS ASTARTES", "VEHICLE", "TITANIC"]}
	check(ContactMovement.monster_vehicle_can_pass_enemy_model(state.units[10], enemy_non_titanic, "normal", state, 10), "Super-heavy Walker can pass non-TITANIC enemy VEHICLE")
	check(not ContactMovement.monster_vehicle_can_pass_enemy_model(state.units[10], enemy_titanic, "normal", state, 10), "Super-heavy Walker cannot pass TITANIC enemy model")

	quit(1 if failures > 0 else 0)

extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Terrain = Combat.Terrain
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var state := Combat.initial_state()
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	# Synthetic rules fixture, deliberately bypassing army admission.
	state.units[200].definition_id = "40kdc:11e:adeptus-astartes:eliminator-squad"
	state.units[200].position = Vector2(10, -3.2)
	A.enable(state)
	return state

func distance(state: Dictionary, inches: float) -> void:
	state.units[100].position = state.units[200].position - Vector2(inches + state.units[100].radius + state.units[200].radius, 0)

func _initialize() -> void:
	var state := fixture()
	distance(state, 12)
	var result := Terrain.pair(state, 100, 200)
	check(result.hidden and result.visible and result.detection == 12, "Cloaks inclusive base-distance boundary failed")
	distance(state, 12.02)
	check(not Terrain.pair(state, 100, 200).visible, "Cloaked Hidden model visible beyond 12 inches")
	check(A.has(state, 2, "chameleoline-cloaks"), "Cloaks missing from live ability sources")
	state.unit_abilities.implementation = "older-implementation"
	check(Terrain.pair(state, 100, 200).detection == 15, "Cloaks leaked into disabled/historical implementation")
	state = fixture()
	state.units[200].position = Vector2(0, 0)
	state.units[100].position = Vector2(-10, 0)
	result = Terrain.pair(state, 100, 200)
	check(result.hidden and result.gone_to_ground and result.detection == 9 and not result.visible, "Gone to Ground did not add to Cloaks")
	# Cloaks alters detection, never grants Hidden or a line through solid walls.
	state.squads[2].last_ranged_turn = state.turn
	result = Terrain.pair(state, 100, 200)
	check(not result.hidden and not result.gone_to_ground and result.detection == 12 and not result.visible, "Firing history or solid wall bypassed")
	state = fixture()
	distance(state, 14)
	state.squads[2].last_ranged_turn = state.turn
	check(Terrain.pair(state, 100, 200).visible, "Cloaks created Hidden after firing")
	# Unit effect reaches an attached model, but a dead/reserve source cannot confer it.
	state.units[201].wounds = 1
	state.units[201].position = state.units[200].position
	check(Terrain.pair(state, 100, 201).detection == 12, "Unit-level effect omitted attached non-Eliminator")
	state.units[200].wounds = 0
	check(Terrain.pair(state, 100, 201).detection == 15, "Dead source retained Cloaks")
	state.units[200].wounds = 1
	state.units[200].on_battlefield = false
	check(Terrain.pair(state, 100, 201).detection == 15, "Reserve source retained Cloaks")
	state.units[200].on_battlefield = true
	state.units[201].definition_id = state.units[200].definition_id
	check(Terrain.pair(state, 100, 201).detection == 12, "Multiple cloak sources stacked")
	state.units[200].squad = 1
	state.units[201].definition_id = "40kdc:11e:adeptus-astartes:intercessor-squad"
	check(Terrain.pair(state, 100, 201).detection == 15, "Cloaks leaked across squads")
	state = fixture()
	state.terrain = Terrain.layout("legacy-solid-v1")
	check(Terrain.pair(state, 100, 200).detection == 15, "Legacy terrain unexpectedly migrated")
	# Stealth is cover, including in open ground, without creating Hidden.
	state = fixture()
	state.units[100].position = Vector2(-5, -8)
	state.units[200].position = Vector2(5, -8)
	check(not Terrain.hidden(state, 200) and Terrain.targeting(state, 100, 2).cover, "Stealth failed to grant cover in open ground")
	state.units[201].wounds = 1
	state.units[201].position = state.units[200].position
	check(not Terrain.benefit_of_cover(state, 100, 2), "Mixed attached unit incorrectly gained Stealth")
	state.units[201].definition_id = state.units[200].definition_id
	check(Terrain.benefit_of_cover(state, 100, 2), "All-model Stealth requirement rejected")
	state.units[201].definition_id = "40kdc:11e:adeptus-astartes:lieutenant"
	state.units[201].wounds = 0
	check(Terrain.benefit_of_cover(state, 100, 2), "Dead non-Stealth model disabled Stealth")
	state.units[201].wounds = 1
	state.units[201].on_battlefield = false
	check(Terrain.benefit_of_cover(state, 100, 2), "Off-board non-Stealth model disabled Stealth")
	state.unit_abilities.implementation = "older-implementation"
	check(not Terrain.benefit_of_cover(state, 100, 2), "Disabled Stealth retained cover")
	state = fixture()
	state.units[100].position = Vector2(-5, -8)
	state.units[200].position = Vector2(5, -8)
	var gun := {"attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}
	var defender := {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}
	var attack := Combat.Attacks.resolve(gun, defender, {"benefit_of_cover": Terrain.targeting(state, 100, 2).cover}, func() -> int: return 3)
	check(attack.error == "" and attack.effective_skill == 4 and attack.hits == 0, "Stealth did not worsen BS through cover")
	gun.keywords = {"ignores-cover": true}
	attack = Combat.Attacks.resolve(gun, defender, {"benefit_of_cover": Terrain.targeting(state, 100, 2).cover}, func() -> int: return 3)
	check(attack.error == "" and attack.effective_skill == 3 and attack.hits == 1 and not attack.benefit_of_cover, "Ignores Cover did not bypass Stealth")
	check(Army.SPECS.has("eliminator-squad"), "Completed profile missing from admission")
	print("Eliminator detection checks complete: %d failures" % failures)
	quit(1 if failures else 0)

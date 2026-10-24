extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Terrain = Combat.Terrain
const Attacks = Combat.Attacks
var failures := 0
var rolls: Array[int] = []
func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
func roll() -> int: return rolls.pop_front() if not rolls.is_empty() else 0
func six() -> int: return 6
func five() -> int: return 5

func fixture() -> Dictionary:
	var state := Combat.initial_state()
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-5, -8)
	state.units[200].position = Vector2(5, -8)
	state.phase = "movement"
	return state

func weapon() -> Dictionary:
	return {"attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}
func defender() -> Dictionary:
	return {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}

func _initialize() -> void:
	var state := fixture()
	check(state.terrain.id == Terrain.DEFAULT_LAYOUT and state.terrain.areas.size() == 3, "Default terrain layout missing")
	var objective_bounds: Array[Rect2] = [Rect2(-19, -14, 6, 4), Rect2(13, 10, 6, 4), Rect2(-9, 12, 6, 4), Rect2(3, -16, 6, 4), Rect2(-3, -2, 6, 4)]
	var layout_signatures: Array[String] = []
	for option: Dictionary in Terrain.event_layout_options():
		var event_layout: Dictionary = Terrain.layout(str(option.id))
		var signature: Array[String] = []
		check(event_layout.areas.size() == 6, "%s should contain its proxy terrain areas" % option.label)
		for area: Dictionary in event_layout.areas:
			var bounds: Rect2 = area.bounds
			check(Rect2(-30, -22, 60, 44).encloses(bounds), "%s terrain must fit the 60 x 44 board" % option.label)
			for objective: Rect2 in objective_bounds:
				check(not bounds.intersects(objective), "%s terrain must not overlap mission objective areas" % option.label)
			signature.append(str(bounds))
		layout_signatures.append("|".join(signature))
	check(layout_signatures.size() == 3 and layout_signatures[0] != layout_signatures[1] and layout_signatures[1] != layout_signatures[2], "Three distinct 11e layouts should be playable")
	check(state.pack_hash != Combat.initial_state("legacy-solid-v1").pack_hash, "Terrain not pinned in match identity")
	check(Combat.initial_state("unknown").has("error"), "Unknown layout silently accepted")
	# Infantry phase through dense walls but cannot finish inside their material.
	state.units[100].position = Vector2(-5, 0)
	check(Combat.move(state, 1, 100, Vector2(-1, 0), 0) == "", "Infantry cannot pass through ruin wall")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Infantry cannot finish on clear ruin ground")
	state = fixture()
	state.units[100].position = Vector2(-5, 0)
	check(not Combat.move(state, 1, 100, Vector2(-2.9, 0), 0).is_empty(), "Infantry finished embedded in solid wall")
	state.units[100].keywords = ["Vehicle"]
	check(not Combat.Contact.clear_path(state, 100, Vector2(-1, 0), 6), "Vehicle crossed a tall dense wall at ground level")
	state.units[100].keywords = ["Mobile"]
	check(Combat.Contact.clear_path(state, 100, Vector2(-1, 0), 6), "Mobile can cross dense wall horizontally")
	state.units[100].elevation = 1.0
	check(not Combat.Contact.clear_path(state, 100, Vector2(-1, 0), 6), "Unsupported upper-floor move accepted")
	# All models cross light features; destinations still respect physical walls.
	state = fixture()
	state.units[100].keywords = ["Vehicle"]
	state.units[100].position = Vector2(8, -6)
	check(Combat.Contact.clear_path(state, 100, Vector2(8, -2.8), 6), "Vehicle cannot cross light barricade")
	check(not Combat.Contact.clear_path(state, 100, Vector2(8, -4), 6), "Base ended inside barricade")
	# Exposed areas grant cover to infantry but never grant Hidden/Obscuring.
	state = fixture()
	state.units[100].position = Vector2(-13, 1)
	state.units[200].position = Vector2(-9, 4.7)
	check(Terrain.targeting(state, 100, 2).cover and not Terrain.hidden(state, 200), "Exposed terrain cover/Hidden semantics incorrect")
	# Light and dense terrain can make a model Hidden; detection uses base distance.
	state = fixture()
	state.units[200].position = Vector2(10, -3.2)
	check(Terrain.hidden(state, 200), "A model within a light terrain area can be Hidden")
	state.units[200].position = Vector2(0, 1.5)
	var radii: float = state.units[100].radius + state.units[200].radius
	state.units[100].position = Vector2(15 + radii, 1.5)
	var visibility := Terrain.pair(state, 100, 200)
	check(visibility.hidden and visibility.visible and visibility.detection == 15, "Detection boundary incorrectly rejected")
	state.units[100].position.x += 0.02
	check(not Terrain.pair(state, 100, 200).visible, "Hidden model visible beyond detection")
	state.squads[2].last_ranged_turn = 1
	check(not Terrain.hidden(state, 200) and Terrain.pair(state, 100, 200).visible, "Firing did not reveal hidden unit")
	state.turn = 2
	check(not Terrain.hidden(state, 200), "Hidden recovered in immediately following turn")
	state.turn = 3
	check(Terrain.hidden(state, 200), "Hidden did not recover after a full non-firing turn")
	# Opposite sides cannot see through an intervening obscuring area.
	state = fixture()
	state.units[100].position = Vector2(-5, 0)
	state.units[200].position = Vector2(5, 0)
	check(not Terrain.pair(state, 100, 200).visible, "Intervening dense area ignored")
	state.units[200].position = Vector2(0, 0)
	state.units[100].position = Vector2(5, 0)
	check(Terrain.pair(state, 100, 200).visible, "Observer could not see into open side of occupied area")
	state.units[100].position = Vector2(-5, 0)
	visibility = Terrain.pair(state, 100, 200)
	check(not visibility.visible and visibility.gone_to_ground and visibility.detection == 12, "Ground-level solid wall or Gone to Ground missing")
	# Cover is a BS characteristic change, not an armour or hit-roll modifier.
	rolls = [3]
	var result := Attacks.resolve(weapon(), defender(), {"benefit_of_cover": true}, roll)
	check(result.error == "" and result.hits == 0 and result.effective_skill == 4, "Cover did not worsen BS")
	var gun := weapon()
	gun.keywords = {"ignores-cover": true}
	rolls = [3, 4, 4]
	result = Attacks.resolve(gun, defender(), {"benefit_of_cover": true}, roll)
	check(result.hits == 1 and result.unsaved == 0 and not result.benefit_of_cover, "Ignores Cover or unchanged armour save incorrect")
	gun.skill = 6
	gun.keywords = {"heavy": true}
	rolls = [5, 1]
	result = Attacks.resolve(gun, defender(), {"benefit_of_cover": true, "heavy_eligible": true}, roll)
	check(result.hits == 1 and result.effective_skill == 6, "BS cap/Heavy incorrectly treated as combined hit-roll modifiers")
	check(not Attacks.resolve(weapon(), defender(), {"benefit_of_cover": "yes"}, six).error.is_empty(), "Invalid cover context accepted")
	# The same target unit is covered from one firing model, but not another.
	# Pools must split even though both attackers have identical weapons.
	state = fixture()
	state.phase = "shooting"
	state.units[101].wounds = 2
	state.units[201].wounds = 1
	state.units[100].position = Vector2(5, -3.2)
	state.units[101].position = Vector2(0, 4.5)
	state.units[200].position = Vector2(0, 0)
	state.units[201].position = Vector2(0, -3.2)
	check(not Terrain.targeting(state, 100, 2).cover and Terrain.targeting(state, 101, 2).cover, "Per-attacker unit cover incorrectly shared")
	result = Combat.shoot(state, 1, 100, 200, 0, true, six)
	check(result.error == "" and result.pools.size() == 2, "Mixed cover shooters not split into separate attack pools")
	var covered := 0
	for pool: Dictionary in result.pools:
		if pool.benefit_of_cover: covered += 1
	check(covered == 1 and state.squads[1].last_ranged_turn == state.turn, "Cover pool or shooting-history update missing")
	# A terrain certificate from the old solid map cannot waive approach when
	# the current infantry unit can walk through the ruin wall.
	state = fixture()
	state.phase = "charge"
	state.units[100].position = Vector2(-5, 0)
	state.units[200].position = Vector2(5, 0)
	Combat.declare_charge(state, 1, 100, 0, five)
	Combat.select_charge_target(state, 1, 200, state.revision)
	Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	check(not Combat.ContactActions.Reachability.certify_impossible(state, 100, [2], 1.0).impossible, "Proof solver treated traversable ruin as impassable")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(3.6, 0), state.revision) == "" and Combat.finish_contact_move(state, 1, state.revision) == "", "Legal charge through ruin rejected")
	print("Ground terrain checks complete: %d failures" % failures)
	quit(1 if failures else 0)

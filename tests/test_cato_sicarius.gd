extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func action(state: Dictionary, player: int, action_id: String, target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (target < 0 or option.target == target): return option
	return {}

func make_state() -> Dictionary:
	var lists := F.selections()
	lists[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1}]
	lists[2].entries = [
		{"definition_id": "40kdc:11e:necrons:immortals", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	var cato := -1
	for model: int in state.units:
		if state.units[model].owner == 1: cato = model; break
	var profile := Profiles.profile("cato-sicarius")
	state.units[cato].definition_id = "40kdc:11e:adeptus-astartes:cato-sicarius"
	state.units[cato].keywords = profile.keywords.duplicate()
	state.units[cato].ranged_weapons = profile.ranged.duplicate(true)
	state.units[cato].melee_weapons = profile.melee.duplicate(true)
	state.units[cato].movement_inches = profile.stats.movement_inches
	state.units[cato].toughness = profile.stats.toughness
	state.units[cato].save_target = profile.stats.save_target
	state.units[cato].invulnerable_target = profile.stats.invulnerable_target
	state.units[cato].wounds = profile.stats.wounds
	state.units[cato].max_wounds = profile.stats.wounds
	state.units[cato].leadership_target = profile.stats.leadership_target
	state.units[cato].objective_control = profile.stats.objective_control
	Abilities.enable(state)
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.mission.stage = "battle"
	return state

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("cato-sicarius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004184" and profile.points == 115 and profile.base_size_source_mm == 40, "Cato profile identifies the shared-book source, points and base")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Cato characteristics match the local Wahapedia export")
	check(profile.ranged[0].profiles.standard.name == "Artisan Plasma Pistol" and profile.ranged[0].profiles.standard.strength == 8 and profile.melee.size() == 3, "Cato's plasma pistol and all three Tempest Blade profiles are represented")
	check(profile.melee[0].profiles.standard.keywords == {"devastating-wounds": true} and profile.melee[1].profiles.standard.keywords == {"precision": true} and profile.melee[2].profiles.standard.keywords == {"sustained-hits": 1}, "Tempest Blade profiles retain source attack traits")
	var state := make_state()
	check(not state.has("error"), "Cato fixture materializes")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var cato_squad := find_squad(state, 1, "cato-sicarius")
	var cato := Geometry.alive(state, cato_squad)[0]
	var cato_start: Vector2 = state.units[cato].position
	var enemy := find_squad(state, 2, "immortals")
	var enemy_model := Geometry.alive(state, enemy)[0]
	check(Abilities.has(state, cato_squad, "leader") and Abilities.has(state, cato_squad, "knight-champion-of-macragge") and Abilities.has(state, cato_squad, "honour-or-death"), "Cato's Leader and datasheet abilities register")
	check(not action(state, 1, "warlord").is_empty(), "Cato can be selected as the army's Warlord")
	check(not C.UnitActions.attachment_allowed(state, cato, cato_squad), "Cato cannot attach to his own unit")
	check(CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.HEROIC) == 0 and CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.FRAY) == 1 and CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.OVERWATCH) == 1, "Honour or Death discounts Heroic Intervention only and preserves the additional Into the Fray cost")
	state.units[enemy_model].position = cato_start + Vector2(6, 0)
	state.phase = "movement"
	state.active = 2
	state.turn = 1
	C.UnitActions.end_move(state, enemy)
	check(state.unit_abilities.window.get("kind", "") == "knight-champion-of-macragge", "Enemy move ending within 8 inches opens Cato's reaction")
	var use := action(state, 1, "cato-knight-use", cato_squad)
	check(not use.is_empty(), "Cato receives an optional 6-inch Normal Move choice")
	if not use.is_empty():
		var result := C.unit_action(state, 1, use, Vector2.ZERO, state.revision)
		check(result.is_empty(), "Cato can choose the reaction move")
		var place := action(state, 1, "cato-knight-place", cato_squad)
		check(not place.is_empty(), "The reaction offers model placement")
		if not place.is_empty():
			var destination := cato_start + Vector2(1, 0)
			check(C.unit_action(state, 1, place, destination, state.revision).is_empty(), "Cato can preview a legal position within 6 inches")
			var confirm := action(state, 1, "cato-knight-confirm", cato_squad)
			check(not confirm.is_empty() and C.unit_action(state, 1, confirm, Vector2.ZERO, state.revision).is_empty(), "The confirmed reaction is a Normal Move and consumes the per-army use")
			check(state.units[cato].position.distance_to(cato_start) <= 6.001 and state.squads[cato_squad].move_type == "normal" and state.unit_abilities.used.has("cato-knight-champion:1:1"), "Cato's movement state and once-per-phase record are persisted")
			C.UnitActions.end_move(state, enemy)
			check(state.unit_abilities.window.is_empty(), "Knight Champion cannot be used twice in the same opponent Movement phase")
	check(CoreReactions.cost_of(state, 1, cato_squad, CoreReactions.HEROIC) == (1 if state.units[cato].wounds <= 0 else 0), "Honour or Death remains sourced by the living Cato model")
	print("Cato Sicarius profile and rule checks: %d failures" % failures)
	quit(1 if failures else 0)

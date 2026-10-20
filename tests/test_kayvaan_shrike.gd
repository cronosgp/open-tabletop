extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and Abilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, player: int, action_id: String, target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (target < 0 or option.target == target): return option
	return {}

func make_state(attach_shrike: bool = true) -> Dictionary:
	var lists := F.selections()
	lists[1].entries = [entry("captain"), entry("assault-intercessors-with-jump-packs", 5), entry("vanguard-veteran-squad-with-jump-packs", 5), entry("intercessor-squad", 5)]
	lists[2].entries = [
		{"definition_id": "40kdc:11e:necrons:immortals", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	var model := find_model(state, 1, "captain")
	var profile := Profiles.profile("kayvaan-shrike")
	state.units[model].definition_id = "40kdc:11e:adeptus-astartes:kayvaan-shrike"
	state.units[model].keywords = profile.keywords.duplicate()
	state.units[model].ranged_weapons = profile.ranged.duplicate(true)
	state.units[model].melee_weapons = profile.melee.duplicate(true)
	state.units[model].invulnerable_target = profile.stats.invulnerable_target
	state.units[model].wounds = profile.stats.wounds
	state.units[model].max_wounds = profile.stats.wounds
	Abilities.enable(state)
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	var veterans := find_squad(state, 1, "vanguard-veteran-squad-with-jump-packs")
	if attach_shrike and veterans >= 0: C.UnitActions.attach(state, model, veterans)
	state.mission.stage = "battle"
	return state

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("kayvaan-shrike")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002708" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Shrike profile identifies the local shared-book Wahapedia record")
	check(profile.points == 95 and profile.models == 1 and profile.base_size_source_mm == 40 and profile.stats == {"movement_inches": 12, "toughness": 4, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Shrike points, base and characteristics match the local export")
	check(profile.ranged[0].profiles.standard.range_inches == 18.0 and profile.ranged[0].profiles.standard.keywords == {"precision": true, "close-quarters": true} and profile.melee[0].profiles.standard.attacks == 7 and profile.melee[0].profiles.standard.keywords == {"precision": true, "twin-linked": true}, "Blackout and Raven's Talons retain their exported weapon traits")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "CAPTAIN", "EPIC HERO", "PHOBOS", "SMOKE", "JUMP PACK", "IMPERIUM", "FLY", "EXPLOSIVES", "ADEPTUS ASTARTES", "RAVEN GUARD"], "Shrike profile retains all exported keywords")
	var state := make_state()
	check(not state.has("error"), "Shrike fixture materializes")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "kayvaan-shrike")
	var squad: int = state.units[model].squad
	var jump_veterans := find_squad(state, 1, "vanguard-veteran-squad-with-jump-packs")
	var jump_intercessors := find_squad(state, 1, "assault-intercessors-with-jump-packs")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	var standalone := make_state(false)
	var standalone_model := find_model(standalone, 1, "kayvaan-shrike")
	var standalone_veterans := find_squad(standalone, 1, "vanguard-veteran-squad-with-jump-packs")
	var standalone_jumps := find_squad(standalone, 1, "assault-intercessors-with-jump-packs")
	var standalone_intercessors := find_squad(standalone, 1, "intercessor-squad")
	check(Abilities.has(state, squad, "deep-strike") and Abilities.every_model_has(state, squad, "deep-strike") and Abilities.has(state, squad, "lone-operative") and Abilities.has(state, squad, "trifold-path-of-shadow") and Abilities.has(state, squad, "echo-of-the-ravenspire"), "Shrike's abilities register and his attached Jump Pack unit retains Deep Strike")
	check(C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_veterans) and C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_jumps), "Shrike can lead both exact source-listed Jump Pack bodyguards")
	check(not C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_intercessors), "Shrike cannot lead an unlisted non-Jump Pack Intercessor Squad")
	check(Detection.stealth(state, squad) and Detection.detection_range(state, model, true) == 9.0, "Trifold Path grants unit-wide Stealth and -3 inches to grounded detection range")
	check(not Abilities.lone_operative_active(state, model), "Lone Operative is disabled while Shrike leads an attached unit")
	check(Abilities.has(state, squad, "transhuman-strategist"), "Shrike has Transhuman Strategist")
	check(Abilities.lone_operative_active(standalone, standalone_model), "Shrike has Lone Operative while he is not attached")
	var warlord_choice := action(standalone, 1, "warlord")
	check(not warlord_choice.is_empty() and warlord_choice.model == standalone_model, "Shrike is eligible to be declared Warlord")
	if not warlord_choice.is_empty():
		check(C.unit_action(standalone, 1, warlord_choice, Vector2.ZERO, standalone.revision).is_empty(), "Shrike can be recorded as Warlord")
		standalone.first_player = 1
		var cp_before: int = standalone.cp[1]
		C.UnitActions.start_round(standalone)
		check(standalone.cp[1] == cp_before + 1, "Transhuman Strategist grants 1 CP when Shrike is Warlord")
	state.phase = "fight"
	state.active = 2
	state.fight_step = "complete"
	var echo_candidates := C.UnitActions.echo_ravenspire_squads(state, 1)
	check(squad in echo_candidates, "Echo of the Ravenspire is available at the end of the opponent's Fight phase when unengaged")
	check(C.UnitActions.open_end(state), "The end-of-phase window opens for Echo of the Ravenspire")
	var echo := action(state, 1, "echo-of-ravenspire", squad)
	check(not echo.is_empty(), "Shrike's unit receives an end-of-phase Strategic Reserves choice")
	if not echo.is_empty(): check(C.unit_action(state, 1, echo, Vector2.ZERO, state.revision).is_empty(), "Echo of the Ravenspire moves the unit into Strategic Reserves")
	check(state.unit_abilities.reserves.has(squad) and state.unit_abilities.reserves[squad].get("source", "") == "echo-of-ravenspire" and Geometry.alive(state, squad).all(func(id: int) -> bool: return not state.units[id].get("on_battlefield", true)), "Echo records reserve source and removes every model from the battlefield")
	var engaged := make_state()
	var engaged_model := find_model(engaged, 1, "kayvaan-shrike")
	var engaged_squad: int = engaged.units[engaged_model].squad
	var enemy_model := Geometry.alive(engaged, find_squad(engaged, 2, "immortals"))[0]
	engaged.units[enemy_model].position = engaged.units[engaged_model].position
	engaged.phase = "fight"
	engaged.active = 2
	check(engaged_squad not in C.UnitActions.echo_ravenspire_squads(engaged, 1), "Echo of the Ravenspire is unavailable while the unit is engaged")
	print("Kayvaan Shrike profile checks: %d failures" % failures)
	quit(1 if failures else 0)

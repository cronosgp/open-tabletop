extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(faction: String, identity: String, count: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:%s:%s" % [faction, identity], "models": count, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func choose_current(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var option: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == action and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model:
			option = candidate
			break
	if option.is_empty(): return {"error": "Decision does not offer %s for target %d/model %d." % [action, target, model]}
	var choice: Dictionary = {}
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) == action and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model:
			choice = candidate
			break
	if choice.is_empty(): return {"error": "UnitActions no longer offers %s for target %d/model %d." % [action, target, model]}
	return MatchCommandService.execute(state, player, {
		"kind": MatchCommandService.SELECT_UNIT_CHOICE,
		"revision": int(state.get("revision", -1)),
		"point": point,
		"choice": {
			"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE,
			"decision_id": str(decision.get("decision_id", "")),
			"option_id": str(option.get("id", "")),
			"choice": choice
		}
	})

func place_squad_in_clear_area(state: Dictionary, squad: int) -> bool:
	var members := Geometry.alive(state, squad)
	var terrain_areas: Array = Terrain.areas(state)
	for y in range(-18, 19, 2):
		for x in range(-18, 5, 2):
			var candidates: Dictionary = {}
			var fits := true
			for index in range(members.size()):
				var model := members[index]
				var position := Vector2(x + float(index) * 3.8, y)
				var radius := float(state.units[model].get("radius", 0.0))
				if absf(position.x) + radius > float(state.board_size.x) / 2.0 or absf(position.y) + radius > float(state.board_size.y) / 2.0:
					fits = false
					break
				for other: int in state.units:
					if other in members or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
					var required_distance := radius + float(state.units[other].get("radius", 0.0)) + (1.01 if int(state.units[other].get("owner", -1)) != int(state.units[model].get("owner", -1)) else 0.001)
					if position.distance_to(Vector2(state.units[other].get("position", Vector2.ZERO))) <= required_distance:
						fits = false
						break
				if not fits: break
				for area: Dictionary in terrain_areas:
					for feature: Dictionary in area.get("features", []):
						var bounds: Rect2 = feature.get("bounds", Rect2())
						if bool(feature.get("blocks_end", false)) and Terrain.within({"position": position, "radius": radius}, bounds):
							fits = false
							break
					if not fits: break
				if not fits: break
				for placed_model: int in candidates:
					var required_spacing := radius + float(state.units[placed_model].get("radius", 0.0)) + 0.001
					if position.distance_to(Vector2(candidates[placed_model])) <= required_spacing:
						fits = false
						break
				if not fits: break
				candidates[model] = position
			if fits:
				for model: int in candidates: state.units[model].position = candidates[model]
				return true
	return false

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("suboden-khan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004167" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Suboden uses the local shared-book Wahapedia export")
	check(profile.points == 105 and profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4} and profile.base_size_source_mm == [90, 52], "Suboden cost, characteristics and oval base match the source")
	check(profile.ranged[0].id == "heavy-bolt-pistol" and profile.ranged[0].profiles.standard == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Heavy Bolt Pistol retains its complete source profile")
	check(profile.ranged.size() == 2 and profile.ranged[1].id == "onslaught-gatling-cannon" and profile.ranged[1].profiles.standard == {"name": "Onslaught gatling cannon", "range_inches": 24.0, "attacks": 8, "skill": 2, "strength": 5, "ap": 0, "damage": 1, "keywords": {"devastating-wounds": true}}, "Onslaught Gatling Cannon retains its complete source profile")
	check(profile.melee.size() == 2 and profile.melee[0].id == "stormtooth" and profile.melee[0].profiles.standard == {"name": "Stormtooth", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 7, "ap": -3, "damage": 2, "keywords": {"anti-monster": 4, "anti-vehicle": 4, "lance": true}}, "Stormtooth retains its complete source profile")
	check(profile.melee[1].id == "power-sword" and profile.melee[1].profiles.standard == {"name": "Power Sword", "range_inches": 0.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1, "extra-attacks": true}, "target_restricted_traits": {"sustained-hits": ["MONSTER", "VEHICLE"]}}, "Power Sword retains Extra Attacks and its non-MONSTER/VEHICLE Sustained Hits condition")
	check(Catalog.SPECS.get("suboden-khan", {}).get("current_reference", false) and int(Catalog.SPECS.get("suboden-khan", {}).get("max_supported_copies", 0)) == 1 and Roster.POINTS.get("suboden-khan", {}).get("sizes", {}) == {1: 105}, "Suboden is selectable as a unique 105-point model")
	var accepted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("adeptus-astartes", "suboden-khan", 1)]})
	var duplicated := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:suboden-khan", "models": 1, "copies": 2}]})
	check(accepted.get("error", "").is_empty() and accepted.get("total", -1) == 105 and not duplicated.get("error", "").is_empty(), "The current catalog admits one Suboden at 105 points and rejects a second copy")
	var lists := F.current_marine_selections()
	lists[1].entries = [entry("adeptus-astartes", "suboden-khan", 1), entry("adeptus-astartes", "outrider-squad", 3), entry("adeptus-astartes", "intercessor-squad", 5)]
	lists[2].entries = [entry("adeptus-astartes", "assault-intercessor-squad", 5), entry("adeptus-astartes", "intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Suboden and both players' source-listed units materialize from the current Marine catalog")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "suboden-khan")
	var squad := find_squad(state, 1, "suboden-khan")
	var outriders := find_squad(state, 1, "outrider-squad")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	check(C.UnitAbilities.has(state, squad, "spear-of-chogoris") and C.UnitAbilities.has(state, squad, "skilled-riders") and C.UnitAbilities.has(state, squad, "transhuman-strategist"), "Suboden's named rules register")
	check(C.UnitActions.attachment_allowed(state, model, outriders) and not C.UnitActions.attachment_allowed(state, model, find_squad(state, 1, "intercessor-squad")), "Suboden's Leader link is restricted to Outriders")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var warlord_available := false
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == "warlord" and option.model == model: warlord_available = true
	check(warlord_available, "Suboden is eligible to be selected as Warlord")
	state.unit_abilities.warlords = {1: model}
	state.cp[1] = 0
	state.round = 1
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants Suboden's Warlord CP")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist awards Suboden's Warlord CP only once per battle round")
	check(C.UnitAbilities.weapon(state, model, -1, profile.ranged[0].profiles.standard, false).keywords.assault, "Spear of Chogoris grants Assault to Suboden's ranged weapons")
	C.UnitActions.attach(state, model, outriders)
	check(state.units[model].squad == outriders and state.squads[outriders].attached, "Suboden can attach to the Outrider Squad")
	state.units[model].ranged_weapons = profile.ranged.duplicate(true)
	state.units[model].melee_weapons = profile.melee.duplicate(true)
	var outrider := Geometry.alive(state, outriders)[0]
	check(Terrain.mobile_unit(state, outrider), "Skilled Riders grants Mobile to the attached Outrider unit")
	var dense_blockers := 0
	for area: Dictionary in Terrain.areas(state):
		if area.category == "dense": dense_blockers += Terrain.movement_obstacles(state, outrider).filter(func(rect: Rect2) -> bool: return area.features.any(func(feature: Dictionary) -> bool: return feature.bounds == rect)).size()
	check(dense_blockers == 0, "Mobile ignores dense terrain movement obstacles for the attached unit")
	state.phase = "movement"
	state.active = 1
	state.units[model].position = Vector2(0, 0)
	state.combat_doctrines.active.erase(1)
	var advance_error := C.begin_movement(state, 1, model, "advance", state.revision, func() -> int: return 3)
	check(advance_error.is_empty() and state.pending_move.bonus == 3, "Spear gives no Advance modifier outside Assault Doctrine")
	state.squads[outriders].advanced = true
	check(C.Doctrines.charge_error(state, outriders).is_empty(), "Spear of Chogoris permits a charge after Advancing without Assault Doctrine")
	var enemy := find_squad(state, 2, "intercessor-squad")
	var enemy_model := Geometry.alive(state, enemy)[0]
	state.units[enemy_model].position = Vector2(8, 0)
	check(find_squad(state, 2, "assault-intercessor-squad") >= 0, "The opposing roster also materializes from the current local Space Marines catalog")
	var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, model, enemy)
	check(weapon_failures.is_empty(), "All four source weapons pass Equipment and AttackPlan: %s" % str(weapon_failures))
	var charged_plan_state := state.duplicate(true)
	charged_plan_state.pending_move = {}
	charged_plan_state.resolution_frames = []
	charged_plan_state.phase = "fight"
	charged_plan_state.active = 1
	charged_plan_state.squads[outriders].advanced = false
	charged_plan_state.squads[outriders].charged = true
	charged_plan_state.squads[outriders].fight_eligible = true
	charged_plan_state.units[model].position = Vector2.ZERO
	for index in range(Geometry.alive(charged_plan_state, enemy).size()):
		charged_plan_state.units[Geometry.alive(charged_plan_state, enemy)[index]].position = Vector2(1.75, float(index) * 3.0)
	var stormtooth_attack := AttackPlan.prepare(charged_plan_state, outriders, true, [
		{"model": model, "target": enemy, "weapon": "stormtooth", "profile": "standard", "amount": 6},
		{"model": model, "target": enemy, "weapon": "power-sword", "profile": "standard", "amount": 3}
	], false)
	var stormtooth_lance_resolved := false
	for batch: Dictionary in stormtooth_attack.get("batches", []):
		if "Stormtooth" in batch.get("labels", []) and int(batch.get("context", {}).get("wound_modifier", 0)) == 1: stormtooth_lance_resolved = true
	check(stormtooth_attack.get("error", "").is_empty() and stormtooth_lance_resolved, "Stormtooth's Lance applies +1 to Wound in Suboden's actual charged AttackPlan: " + str(stormtooth_attack.get("error", "")))
	var pistol := Equipment.select(state, model, false, "heavy-bolt-pistol", "standard")
	var gatling := Equipment.select(state, model, false, "onslaught-gatling-cannon", "standard")
	check(pistol.get("error", "").is_empty() and gatling.get("error", "").is_empty() and pistol.stats == profile.ranged[0].profiles.standard and gatling.stats == profile.ranged[1].profiles.standard, "Equipment exposes both fixed ranged weapons without changing their exported profiles")
	var power_sword: Dictionary = profile.melee[1].profiles.standard
	var infantry_sword := C.UnitAbilities.weapon(state, model, enemy, power_sword, true)
	check(infantry_sword.keywords.get("sustained-hits", 0) == 1, "Power Sword grants Sustained Hits 1 against a non-MONSTER/non-VEHICLE target")
	for target_model: int in Geometry.alive(state, enemy): state.units[target_model].keywords.append("MONSTER")
	var monster_sword := C.UnitAbilities.weapon(state, model, enemy, power_sword, true)
	check(not monster_sword.keywords.has("sustained-hits"), "Power Sword does not grant Sustained Hits against a MONSTER target")
	for target_model: int in Geometry.alive(state, enemy): state.units[target_model].keywords.erase("MONSTER")
	for target_model: int in Geometry.alive(state, enemy): state.units[target_model].keywords.append("VEHICLE")
	var vehicle_sword := C.UnitAbilities.weapon(state, model, enemy, power_sword, true)
	check(not vehicle_sword.keywords.has("sustained-hits"), "Power Sword does not grant Sustained Hits against a VEHICLE target")
	for target_model: int in Geometry.alive(state, enemy): state.units[target_model].keywords.erase("VEHICLE")
	state.phase = "shooting"
	var pistol_id := str(state.units[model].ranged_weapons[0].id)
	var after_advance_targets := AttackPlan.legal_targets(state, model, false, pistol_id, "standard")
	check(enemy in after_advance_targets, "Assault lets Suboden shoot after Advancing")
	var advanced_pistol_attack := AttackPlan.prepare(state, outriders, false, [{"model": model, "target": enemy, "weapon": pistol_id, "profile": "standard", "amount": 1}], false)
	check(advanced_pistol_attack.get("error", "").is_empty() and not advanced_pistol_attack.get("batches", []).is_empty(), "Suboden's attached Heavy Bolt Pistol is accepted by the actual post-Advance AttackPlan: " + str(advanced_pistol_attack.get("error", "")))
	state.combat_doctrines.active[1] = "assault"
	check(C.Doctrines.advance_bonus(state, outriders) == 1 and C.Doctrines.charge_bonus(state, outriders) == 1, "Assault Doctrine adds one to Suboden's Advance and Charge rolls")
	var doctrine_state := state.duplicate(true)
	doctrine_state.phase = "movement"
	doctrine_state.units[model].position = Vector2(0, 0)
	doctrine_state.squads[outriders].moved = false
	doctrine_state.squads[outriders].advanced = false
	doctrine_state.pending_move = {}
	doctrine_state.resolution_frames = []
	var doctrine_advance_error := C.begin_movement(doctrine_state, 1, model, "advance", doctrine_state.revision, func() -> int: return 3)
	check(doctrine_advance_error.is_empty() and doctrine_state.pending_move.bonus == 4, "Assault Doctrine modifier is applied to the actual Advance roll")
	doctrine_state.phase = "charge"
	doctrine_state.pending_move = {}
	doctrine_state.resolution_frames = []
	doctrine_state.squads[outriders].advanced = true
	var charge_result := C.declare_charge(doctrine_state, 1, model, doctrine_state.revision, func() -> int: return 3)
	check(charge_result.error.is_empty() and doctrine_state.pending_charge.maximum == 7, "Assault Doctrine modifier is applied to the actual Charge roll after Advance")
	var spearpoint_state := state.duplicate(true)
	C.Doctrines.enable(spearpoint_state, "spearpoint-task-force")
	C.DetachmentStratagems.enable_spearpoint(spearpoint_state)
	check("assault" in C.Doctrines.available(spearpoint_state, 1) and "tactical" in C.Doctrines.available(spearpoint_state, 1), "Spearpoint permits an additional Assault or Tactical Doctrine selection")
	spearpoint_state.combat_doctrines.used[1] = ["assault", "tactical"]
	check("assault" in C.Doctrines.available(spearpoint_state, 1) and "tactical" in C.Doctrines.available(spearpoint_state, 1), "Spearpoint keeps its single extra selection available while either eligible doctrine has been used once")
	C.Doctrines.record_selection(spearpoint_state, 1, "tactical")
	check("assault" not in C.Doctrines.available(spearpoint_state, 1) and "tactical" not in C.Doctrines.available(spearpoint_state, 1), "Using Spearpoint's extra doctrine selection consumes it")
	check(C.Doctrines.advance_bonus(spearpoint_state, outriders) == 1 and C.Doctrines.advance_bonus(spearpoint_state, intercessors) == 0, "Spearpoint adds one only to Astartes Mounted/Speeder Advance rolls")
	spearpoint_state.squads[intercessors].advanced = true
	check(not C.Doctrines.charge_error(spearpoint_state, intercessors).is_empty(), "Spearpoint no longer grants charges after Advancing")
	spearpoint_state.squads[intercessors].advanced = false
	spearpoint_state.squads[intercessors].fell_back = true
	check(not C.Doctrines.charge_error(spearpoint_state, intercessors).is_empty(), "Spearpoint no longer grants charges after Falling Back")
	spearpoint_state.phase = "fight"
	spearpoint_state.active = 2
	spearpoint_state.squads[outriders].fight_eligible = true
	var storm_swift_error := TacticalFluidity.start_end_fight(spearpoint_state, 1, outriders)
	var storm_swift_choices := TacticalFluidity.choices(spearpoint_state, 1)
	check(not Geometry.alive(spearpoint_state, enemy).is_empty() and storm_swift_error.is_empty() and spearpoint_state.unit_abilities.window.get("source", "") == "storm-swift-onslaught" and spearpoint_state.unit_abilities.window.get("mode", "") == "normal" and str(storm_swift_choices[0].label).contains("Normal Move up to 12 inches"), "Wrath of the First Khan offers a Movement-characteristic Normal Move after eligibility, without requiring a destroyed enemy")
	var storm_swift_use := TacticalFluidity.apply(spearpoint_state, 1, storm_swift_choices[0], Vector2.ZERO, func() -> int: return 1)
	check(storm_swift_use.error.is_empty() and spearpoint_state.unit_abilities.window.kind == TacticalFluidity.PLACEMENT and spearpoint_state.unit_abilities.window.distance_by_model[model] == 12.0, "Suboden's Normal Move preview uses his 12-inch Movement characteristic")
	check(not TacticalFluidity.suboden_squads(spearpoint_state, 1).has(outriders), "Wrath of the First Khan cannot be used twice in the same Fight phase")
	var engaged_state := state.duplicate(true)
	C.Doctrines.enable(engaged_state, "spearpoint-task-force")
	engaged_state.phase = "fight"
	engaged_state.squads[outriders].fight_eligible = true
	engaged_state.units[enemy_model].position = engaged_state.units[model].position + Vector2(2, 0)
	var engaged_error := TacticalFluidity.start_end_fight(engaged_state, 1, outriders)
	var engaged_choices := TacticalFluidity.choices(engaged_state, 1)
	check(engaged_error.is_empty() and engaged_state.unit_abilities.window.mode == "fallback" and str(engaged_choices[0].label).contains("Fall Back up to 12 inches"), "Wrath of the First Khan offers a Fall Back move when Suboden's unit is engaged")
	var engaged_use := TacticalFluidity.apply(engaged_state, 1, engaged_choices[0], Vector2.ZERO, func() -> int: return 1)
	check(engaged_use.error.is_empty() and engaged_state.unit_abilities.window.kind == TacticalFluidity.PLACEMENT and engaged_state.unit_abilities.window.mode == "fallback" and engaged_state.unit_abilities.window.distance_by_model[model] == 12.0, "Suboden's Fall Back preview uses his Movement characteristic")
	var continuation := state.duplicate(true)
	C.Doctrines.enable(continuation, "spearpoint-task-force")
	C.DetachmentStratagems.enable_spearpoint(continuation)
	continuation.phase = "fight"
	continuation.active = 2
	continuation.turn = 4
	continuation.round = 2
	continuation.fight_step = "complete"
	continuation.fight_actor = 2
	continuation.squads[outriders].fight_eligible = true
	continuation.unit_abilities.window = {}
	continuation.unit_abilities.end_done = ""
	continuation.unit_abilities.used.erase("storm-swift-onslaught:%d:%d:fight" % [outriders, continuation.turn])
	continuation.pending_move = {}
	continuation.pending_charge = {}
	continuation.pending_contact = {}
	continuation.resolution_frames = []
	check(place_squad_in_clear_area(continuation, outriders), "The phase-end placement fixture starts from an unengaged, clear battlefield location")
	var close_error := C.advance_phase(continuation, 2, continuation.revision)
	var end_decision := C.UnitActions.pending_decision(continuation)
	check(close_error.is_empty() and continuation.unit_abilities.window.get("kind", "") == "end" and end_decision.get("priority_player_id", -1) == 1 and ResolutionFrames.current(continuation).get("kind", "") == "phase-close", "Fight close opens Suboden's opponent-owned end decision under a suspended phase-close frame: " + close_error)
	var start_move := choose_current(continuation, 1, "storm-swift-move", outriders)
	check(str(start_move.get("error", "")).is_empty() and continuation.unit_abilities.window.get("kind", "") == TacticalFluidity.WINDOW, "The public unit-choice command starts Wrath of the First Khan from the live phase-end decision: " + str(start_move.get("error", "")))
	var move_use := choose_current(continuation, 1, "fluidity-use", outriders)
	check(str(move_use.get("error", "")).is_empty() and continuation.unit_abilities.window.get("kind", "") == TacticalFluidity.PLACEMENT, "The normalized Tactical Fluidity decision opens model placement: " + str(move_use.get("error", "")))
	var placement_frame_id := str(C.UnitActions.pending_decision(continuation).get("resume_frame_id", ""))
	var restored_continuation: Dictionary = bytes_to_var(var_to_bytes(continuation))
	check(not placement_frame_id.is_empty() and C.UnitActions.pending_decision(restored_continuation).get("resume_frame_id", "") == placement_frame_id and ResolutionFrames.current(restored_continuation).get("status", "") == "suspended", "The phase-close frame identity survives save/resume during Suboden's placement choice")
	var pending_placement_before := var_to_str(restored_continuation)
	var close_while_placing := C.advance_phase(restored_continuation, 2, restored_continuation.revision)
	check("unit ability choices" in close_while_placing and var_to_str(restored_continuation) == pending_placement_before, "The active player cannot close Fight past the opponent's saved movement choice, and the blocked request is read-only")
	for member: int in Geometry.alive(restored_continuation, outriders):
		var staged := choose_current(restored_continuation, 1, "fluidity-place", outriders, member, restored_continuation.units[member].position)
		check(str(staged.get("error", "")).is_empty(), "Suboden placement preview records model %d without committing the move: %s" % [member, str(staged.get("error", ""))])
	var confirm_move := choose_current(restored_continuation, 1, "fluidity-confirm", outriders)
	check(str(confirm_move.get("error", "")).is_empty() and restored_continuation.unit_abilities.window.get("kind", "") == "end" and ResolutionFrames.current(restored_continuation).get("kind", "") == "phase-close", "Confirming Suboden's move returns to the phase-end decision under the same close frame: " + str(confirm_move.get("error", "")))
	var end_pass := choose_current(restored_continuation, 1, "pass")
	var next_boundary_frame := ResolutionFrames.current(restored_continuation)
	check(str(end_pass.get("error", "")).is_empty() and restored_continuation.phase == "end_turn" and next_boundary_frame.get("kind", "") == "phase-close" and next_boundary_frame.get("action_id", "") == "phase-close:%d:end_turn" % continuation.turn and next_boundary_frame.get("resume_point", "") == "end-turn-coherency-casualties", "Passing the end window completes Fight close and enters the distinct mandatory End-of-Turn coherency continuation: " + str(end_pass.get("error", "")))
	print("Suboden Khan local checks: %d failures" % failures)
	quit(1 if failures else 0)

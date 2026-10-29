extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(models: int, leader: String = "librarian-in-phobos-armour") -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": models, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:" + leader, "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func make_state(models: int = 5, leader: String = "librarian-in-phobos-armour") -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections(models, leader))
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
	return state

func option(state: Dictionary, player: int, action: String, model: int, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and item.model == model and item.value == value: return item
	return {}

func submit_scout_choice(state: Dictionary, player: int, action: String, model: int, target: int, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No Scout decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for choice: Dictionary in decision.get("legal_options", []):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and int(choice.get("target", -1)) == target:
			projected = choice
			break
	var selected: Dictionary = {}
	for choice: Dictionary in C.unit_choices(state, player):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and int(choice.get("target", -1)) == target:
			selected = choice
			break
	if projected.is_empty() or selected.is_empty(): return {"error": "The current Scout decision does not offer %s." % action}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func submit_preparation_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No current Scout preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current Scout preparation decision does not offer this choice."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func _initialize() -> void:
	var profile := Profiles.profile("scout-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001160" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Scout Squad is linked to its current local Wahapedia sheet")
	check(profile.points_by_models == {5: 65, 10: 120} and profile.stats == {"movement_inches": 6, "toughness": 4, "save_target": 4, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Scout Squad sizes, costs and characteristics match the extracted sheet")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard.name == "Bolt Pistol" and profile.ranged[1].profiles.standard.name == "Boltgun" and profile.melee[0].profiles.standard.name == "Combat Knife", "Every Scout has the extracted fixed loadout")
	check(is_equal_approx(profile.base_radius_inches, 14.25 / 25.4), "Scout models use the source 28.5 mm base")
	var shotgun_stats: Dictionary = Profiles.scout_ranged("shotgun")[1].profiles.standard
	var sniper_stats: Dictionary = Profiles.scout_ranged("sniper-rifle")[1].profiles.standard
	var heavy_bolter_stats: Dictionary = Profiles.scout_ranged("heavy-bolter")[1].profiles.standard
	var missile_stats: Dictionary = Profiles.scout_ranged("missile-launcher")[1].profiles
	var chainsword_stats: Dictionary = Profiles.scout_melee("chainsword")[0].profiles.standard
	check(shotgun_stats.attacks == 2 and shotgun_stats.skill == 3 and shotgun_stats.strength == 4 and shotgun_stats.ap == -1 and shotgun_stats.damage == 1 and shotgun_stats.keywords == {"assault": true, "blast": 1}, "Shotgun replacement profile matches the local source row")
	check(sniper_stats.attacks == 1 and sniper_stats.skill == 3 and sniper_stats.strength == 5 and sniper_stats.ap == -2 and sniper_stats.damage == 2 and sniper_stats.keywords == {"heavy": true, "precision": true}, "Sniper Rifle replacement profile matches the local source row")
	check(heavy_bolter_stats.attacks == 3 and heavy_bolter_stats.skill == 4 and heavy_bolter_stats.strength == 5 and heavy_bolter_stats.ap == -1 and heavy_bolter_stats.damage == 2 and heavy_bolter_stats.keywords == {"rapid-fire": 2, "sustained-hits": 1, "heavy": true}, "Heavy Bolter replacement profile matches the local source row")
	check(missile_stats.frag.attacks == 4 and missile_stats.frag.skill == 4 and missile_stats.frag.strength == 4 and missile_stats.frag.ap == -1 and missile_stats.frag.damage == 1 and missile_stats.frag.keywords == {"blast": 1, "heavy": true} and missile_stats.krak.attacks == 1 and missile_stats.krak.skill == 4 and missile_stats.krak.strength == 10 and missile_stats.krak.ap == -2 and missile_stats.krak.damage == "D3+3", "Both Missile Launcher profiles match the local source rows")
	check(chainsword_stats.attacks == 4 and chainsword_stats.skill == 3 and chainsword_stats.strength == 4 and chainsword_stats.ap == -1 and chainsword_stats.damage == 1, "Scout Sergeant Chainsword profile matches the local source row")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": 10, "copies": 1}]})
	check(five.error.is_empty() and five.total == 65 and ten.error.is_empty() and ten.total == 120, "Both source model-count options enter the local catalog at Wahapedia points")
	for models: int in [4, 6, 7, 8, 9, 11]:
		var invalid_size := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:scout-squad", "models": models, "copies": 1}]})
		check(not invalid_size.error.is_empty(), "Scout Squad rejects the unpriced %d-model composition" % models)
	var state := make_state()
	check(not state.has("error"), "Scout Squad and supporting Marines materialize from admitted local profiles")
	if state.has("error"):
		print("Scout Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := -1
	var sergeant := -1
	var scouts: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) != "scout-squad": continue
		squad = state.units[model].squad
		if state.units[model].get("sergeant", false): sergeant = model
		else: scouts.append(model)
	check(squad >= 0 and sergeant >= 0 and scouts.size() == 4, "Five-model formation has one Scout Sergeant and four Scouts")
	check(C.UnitAbilities.every_model_has(state, squad, "scouts-6") and C.UnitAbilities.scout_distance(state, squad) == 6 and C.UnitAbilities.Detection.infiltrators(state, squad), "All Scouts provide Scouts 6 and Infiltrators")
	check(C.UnitAbilities.has(state, squad, "flexible-asset"), "Scout Squad has Flexible Asset")
	state.squads[squad].advanced = true
	check(Actions.eligibility_error(state, squad).is_empty(), "Flexible Asset permits an Advanced Scout unit to start an otherwise eligible action")
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = true
	check(Actions.eligibility_error(state, squad).is_empty(), "Flexible Asset permits a Scout unit that Fell Back to start an otherwise eligible action")
	state.squads[squad].fell_back = false
	state.squads[squad].battle_shocked = true
	check(not Actions.eligibility_error(state, squad).is_empty(), "Flexible Asset does not bypass the Battle-shock action restriction")
	state.squads[squad].battle_shocked = false
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var sniper := option(state, 1, "scout-gun", scouts[0], "sniper-rifle")
	var prep_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_scout_choice := var_to_bytes(state)
	var wrong_owner_scout := submit_preparation_choice(state, 2, sniper)
	var stale_scout := submit_preparation_choice(state, 1, sniper, str(prep_decision.get("decision_id", "")), "stale-option")
	check(not wrong_owner_scout.get("error", "").is_empty() and not stale_scout.get("error", "").is_empty() and before_scout_choice == var_to_bytes(state), "Wrong-owner and stale Scout preparation commands are rejected unchanged")
	var sniper_result := submit_preparation_choice(state, 1, sniper)
	check(not sniper.is_empty() and sniper_result.get("error", "").is_empty(), "One Scout may replace its Boltgun with a Sniper Rifle through the public command")
	check(option(state, 1, "scout-gun", scouts[1], "sniper-rifle").is_empty(), "A five-model squad cannot exceed one Sniper Rifle")
	var heavy := option(state, 1, "scout-gun", scouts[1], "heavy-bolter")
	var heavy_result := submit_preparation_choice(state, 1, heavy)
	check(not heavy.is_empty() and heavy_result.get("error", "").is_empty(), "One Scout may take the Heavy Bolter option through the public command")
	check(option(state, 1, "scout-gun", scouts[2], "missile-launcher").is_empty(), "Heavy Bolter and Missile Launcher share one special-weapon slot per five models")
	var shotgun := option(state, 1, "scout-gun", scouts[2], "shotgun")
	var shotgun_result := submit_preparation_choice(state, 1, shotgun)
	check(not shotgun.is_empty() and shotgun_result.get("error", "").is_empty(), "Any Scout may replace its Boltgun with a Shotgun through the public command")
	var sergeant_shotgun := option(state, 1, "scout-gun", sergeant, "shotgun")
	var chainsword := option(state, 1, "scout-blade", sergeant, "chainsword")
	check(not sergeant_shotgun.is_empty() and not chainsword.is_empty(), "Scout Sergeant receives both source-listed individual wargear options")
	if not sergeant_shotgun.is_empty(): check(submit_preparation_choice(state, 1, sergeant_shotgun).get("error", "").is_empty() and state.units[sergeant].ranged_weapons[1].id == "shotgun", "Sergeant Shotgun replaces the Boltgun while retaining its Bolt Pistol")
	chainsword = option(state, 1, "scout-blade", sergeant, "chainsword")
	if not chainsword.is_empty(): check(submit_preparation_choice(state, 1, chainsword).get("error", "").is_empty() and state.units[sergeant].melee_weapons[0].id == "chainsword", "Sergeant Chainsword replaces the Combat Knife through the public command")
	var shotgun_state := make_state()
	shotgun_state.phase = "deployment"
	shotgun_state.unit_abilities.setup_players = []
	var shotgun_scouts: Array[int] = []
	for model: int in shotgun_state.units:
		if C.UnitAbilities.identity(shotgun_state.units[model]) == "scout-squad" and not shotgun_state.units[model].get("sergeant", false): shotgun_scouts.append(model)
	var all_shotguns_legal := shotgun_scouts.size() == 4
	for model: int in shotgun_scouts:
		var choice := option(shotgun_state, 1, "scout-gun", model, "shotgun")
		if choice.is_empty() or not submit_preparation_choice(shotgun_state, 1, choice).get("error", "").is_empty(): all_shotguns_legal = false
	check(all_shotguns_legal and shotgun_scouts.all(func(model: int) -> bool: return shotgun_state.units[model].scout_gun == "shotgun"), "Any number of Scout models may replace their Boltgun with a Shotgun")
	var ten_state := make_state(10)
	var ten_squad := -1
	var ten_scouts: Array[int] = []
	for model: int in ten_state.units:
		if C.UnitAbilities.identity(ten_state.units[model]) != "scout-squad": continue
		ten_squad = ten_state.units[model].squad
		if not ten_state.units[model].get("sergeant", false): ten_scouts.append(model)
	ten_state.phase = "deployment"
	ten_state.unit_abilities.setup_players = []
	check(ten_scouts.size() == 9 and ten_squad >= 0, "Ten-model source composition includes one Sergeant and nine Scouts")
	for slot in [0, 1]:
		var sniper_choice := option(ten_state, 1, "scout-gun", ten_scouts[slot], "sniper-rifle")
		if not sniper_choice.is_empty(): check(submit_preparation_choice(ten_state, 1, sniper_choice).get("error", "").is_empty(), "Each permitted Sniper Rifle choice uses the public command")
	check(option(ten_state, 1, "scout-gun", ten_scouts[2], "sniper-rifle").is_empty(), "Ten-model squad may take two Sniper Rifles")
	var first_heavy := option(ten_state, 1, "scout-gun", ten_scouts[2], "heavy-bolter")
	var second_heavy := option(ten_state, 1, "scout-gun", ten_scouts[3], "missile-launcher")
	var first_heavy_result := submit_preparation_choice(ten_state, 1, first_heavy) if not first_heavy.is_empty() else {"error": "missing Heavy Bolter option"}
	var second_heavy_result := submit_preparation_choice(ten_state, 1, second_heavy) if not second_heavy.is_empty() else {"error": "missing Missile Launcher option"}
	check(first_heavy_result.get("error", "").is_empty() and second_heavy_result.get("error", "").is_empty(), "A ten-model unit may take two Heavy Bolter/Missile Launcher replacements")
	check(option(ten_state, 1, "scout-gun", ten_scouts[4], "heavy-bolter").is_empty() and option(ten_state, 1, "scout-gun", ten_scouts[4], "missile-launcher").is_empty(), "Ten-model unit cannot exceed its two shared heavy-weapon slots")
	var missile_weapons: Array = ten_state.units[ten_scouts[3]].ranged_weapons
	var missile_launcher: Dictionary = {}
	for weapon: Dictionary in missile_weapons:
		if weapon.id == "missile-launcher": missile_launcher = weapon
	check(missile_launcher.profiles.has("frag") and missile_launcher.profiles.has("krak") and missile_launcher.profiles.frag.attacks == 4 and missile_launcher.profiles.krak.damage == "D3+3", "Missile Launcher replacement equips both source fire modes")
	var fire_state := make_state()
	var fire_squad := -1
	var fire_model := -1
	var fire_sergeant := -1
	var fire_scouts: Array[int] = []
	var target_squad := -1
	var target_model := -1
	for model: int in fire_state.units:
		fire_state.units[model].position = Vector2.ZERO if fire_state.units[model].owner == 1 else Vector2(8, 0)
		fire_state.units[model].on_battlefield = true
		var identity := C.UnitAbilities.identity(fire_state.units[model])
		if identity == "scout-squad":
			fire_squad = fire_state.units[model].squad
			fire_scouts.append(model)
			if fire_state.units[model].get("sergeant", false): fire_sergeant = model
			elif fire_model < 0: fire_model = model
		elif fire_state.units[model].owner == 2:
			if target_model < 0:
				target_model = model
				target_squad = fire_state.units[model].squad
			else: fire_state.units[model].wounds = 0
	fire_state.phase = "shooting"
	fire_state.active = 1
	fire_state.mission.stage = "battle"
	fire_state.unit_abilities.setup_players = [1, 2]
	fire_state.deployment.complete = true
	fire_state.terrain.areas = []
	var ranged_attack_cases: Array[Dictionary] = [
		{"loadout": "boltgun", "weapon": "bolt-pistol", "profile": "standard", "name": "Bolt Pistol"},
		{"loadout": "boltgun", "weapon": "boltgun", "profile": "standard", "name": "Boltgun"},
		{"loadout": "shotgun", "weapon": "shotgun", "profile": "standard", "name": "Shotgun"},
		{"loadout": "sniper-rifle", "weapon": "sniper-rifle", "profile": "standard", "name": "Sniper Rifle"},
		{"loadout": "heavy-bolter", "weapon": "heavy-bolter", "profile": "standard", "name": "Heavy Bolter"},
		{"loadout": "missile-launcher", "weapon": "missile-launcher", "profile": "frag", "name": "Missile Launcher - Frag"},
		{"loadout": "missile-launcher", "weapon": "missile-launcher", "profile": "krak", "name": "Missile Launcher - Krak"}]
	for attack_case: Dictionary in ranged_attack_cases:
		if fire_model >= 0: fire_state.units[fire_model].ranged_weapons = Profiles.scout_ranged(attack_case.loadout)
		var entries := [{"model": fire_model, "target": target_squad, "amount": 1, "weapon": attack_case.weapon, "profile": attack_case.profile}]
		var plan: Dictionary = C.AttackPlan.prepare(fire_state, fire_squad, false, entries, true)
		var plan_has_weapon: bool = str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1
		if plan_has_weapon: plan_has_weapon = plan.batches[0].weapon.name == attack_case.name
		check(fire_model >= 0 and target_model >= 0 and plan_has_weapon, "%s option reaches the attack plan with its source profile: %s" % [attack_case.name, str(plan.get("error", "no expected batch"))])
	var melee_state: Dictionary = fire_state.duplicate(true)
	melee_state.phase = "fight"
	var melee_entries: Array[Dictionary] = []
	for model: int in fire_scouts:
		var weapon_id := "chainsword" if model == fire_sergeant else "combat-knife"
		melee_state.units[model].melee_weapons = Profiles.scout_melee(weapon_id)
		melee_entries.append({"model": model, "target": target_squad, "amount": 4 if model == fire_sergeant else 3, "weapon": weapon_id, "profile": "standard"})
		if model == fire_sergeant: melee_state.units[model].position = Vector2.ZERO
	if target_model >= 0: melee_state.units[target_model].position = Vector2(1, 0)
	var chainsword_plan := C.AttackPlan.prepare(melee_state, fire_squad, true, melee_entries, true)
	var chainsword_reached := false
	for batch: Dictionary in chainsword_plan.get("batches", []):
		for source: Dictionary in batch.context.attack_sources:
			if int(source.model) == fire_sergeant and str(source.weapon) == "chainsword": chainsword_reached = true
	check(str(chainsword_plan.get("error", "")).is_empty() and chainsword_reached, "Scout Sergeant Chainsword reaches the melee attack plan: %s" % str(chainsword_plan.get("error", "chainsword source missing")))

	var attached_state := make_state()
	var librarian := -1
	var attached_scouts := -1
	for model: int in attached_state.units:
		match C.UnitAbilities.identity(attached_state.units[model]):
			"librarian-in-phobos-armour": librarian = model
			"scout-squad": attached_scouts = attached_state.units[model].squad
	check(librarian >= 0 and attached_scouts >= 0 and C.UnitActions.attachment_allowed(attached_state, librarian, attached_scouts), "Phobos Librarian may lead the Scout Squad as linked by its datasheet")
	if librarian >= 0 and attached_scouts >= 0:
		C.UnitActions.attach(attached_state, librarian, attached_scouts)
		check(C.UnitAbilities.every_model_has(attached_state, attached_scouts, "scouts-6") and C.UnitAbilities.scout_distance(attached_state, attached_scouts) == 6 and C.UnitAbilities.Detection.infiltrators(attached_state, attached_scouts), "The attached Scout unit retains all-model Scouts and Infiltrators eligibility")
	var captain_state := make_state(5, "captain-in-phobos-armour")
	var phobos_captain := -1
	var captain_scouts := -1
	for model: int in captain_state.units:
		match C.UnitAbilities.identity(captain_state.units[model]):
			"captain-in-phobos-armour": phobos_captain = model
			"scout-squad": captain_scouts = captain_state.units[model].squad
	check(phobos_captain >= 0 and captain_scouts >= 0 and C.UnitActions.attachment_allowed(captain_state, phobos_captain, captain_scouts), "Phobos Captain may lead the Scout Squad as linked by its datasheet")
	if phobos_captain >= 0 and captain_scouts >= 0:
		C.UnitActions.attach(captain_state, phobos_captain, captain_scouts)
		check(C.UnitAbilities.every_model_has(captain_state, captain_scouts, "scouts-6") and C.UnitAbilities.Detection.infiltrators(captain_state, captain_scouts), "The Scout unit led by a Phobos Captain retains its source all-model movement and deployment rules")
	var deployment_state := make_state()
	var deployment_squad := -1
	var deployment_model := -1
	for model: int in deployment_state.units:
		if C.UnitAbilities.identity(deployment_state.units[model]) == "scout-squad":
			deployment_squad = deployment_state.units[model].squad
			if deployment_model < 0 and not deployment_state.units[model].get("sergeant", false): deployment_model = model
		elif deployment_state.units[model].owner == 2: deployment_state.units[model].wounds = 0
	deployment_state.board_size = Vector2(44, 30)
	deployment_state.deployment = {"order": [deployment_squad], "index": 0, "placed": {}, "committed": [], "zones": {1: Rect2(-22, -15, 8, 30), 2: Rect2(14, -15, 8, 30)}, "complete": false}
	var enemy_model := -1
	for model: int in deployment_state.units:
		if deployment_state.units[model].owner == 2:
			enemy_model = model
			deployment_state.units[model].wounds = 1
			deployment_state.units[model].position = Vector2(17, 0)
			deployment_state.deployment.placed[model] = true
			break
	var legal_infiltration := Deployment.position_error(deployment_state, deployment_model, Vector2(0, -8))
	var near_enemy_zone := Deployment.position_error(deployment_state, deployment_model, Vector2(6.0 - deployment_state.units[deployment_model].radius, -8))
	check(deployment_squad >= 0 and deployment_model >= 0 and enemy_model >= 0 and legal_infiltration.is_empty() and not near_enemy_zone.is_empty(), "Scout Infiltrators allow a legal midfield deployment and preserve the more-than-8-inch enemy-zone limit")

	var scout_state := make_state()
	var scout := -1
	var positions: Array[int] = []
	for model: int in scout_state.units:
		if C.UnitAbilities.identity(scout_state.units[model]) == "scout-squad":
			scout = scout_state.units[model].squad
			positions.append(model)
		elif scout_state.units[model].owner == 1:
			scout_state.units[model].position = Vector2(7, 0)
		else:
			scout_state.units[model].position = Vector2(20, 0)
	scout_state.board_size = Vector2(43, 44)
	scout_state.deployment = {"zones": {1: Rect2(-21.5, -22, 11, 44), 2: Rect2(10.5, -22, 11, 44)}, "complete": true}
	for index: int in positions: scout_state.units[index].position = Vector2(-16, (positions.find(index) - 2) * 1.3)
	scout_state.phase = "pre_battle"
	scout_state.first_player = 1
	ScoutMoves.begin(scout_state)
	var scout_move: Dictionary = {}
	for item: Dictionary in C.unit_choices(scout_state, 1):
		if item.action == "scout-move": scout_move = item
	check(not scout_move.is_empty(), "Scout Squad enters the pre-battle Scouts sequence")
	if not scout_move.is_empty():
		var scout_start := submit_scout_choice(scout_state, 1, "scout-move", -1, scout)
		var move_ok := true
		for index: int in positions:
			var placed := submit_scout_choice(scout_state, 1, "scout-place", index, scout, Vector2(-10, scout_state.units[index].position.y))
			if not str(placed.get("error", "")).is_empty(): move_ok = false
		var confirm: Dictionary = {}
		for item: Dictionary in C.unit_choices(scout_state, 1):
			if item.action == "scout-confirm": confirm = item
		var confirmed := submit_scout_choice(scout_state, 1, "scout-confirm", -1, scout)
		check(str(scout_start.get("error", "")).is_empty() and move_ok and not confirm.is_empty() and str(confirmed.get("error", "")).is_empty() and scout_state.phase == "start_turn", "Scout Squad moves up to 6 inches coherently and resolves before turn one")
	var reserve_state := make_state()
	var reserve_squad := -1
	var reserve_models: Array[int] = []
	for model: int in reserve_state.units:
		if C.UnitAbilities.identity(reserve_state.units[model]) == "scout-squad":
			reserve_squad = reserve_state.units[model].squad
			reserve_models.append(model)
			reserve_state.units[model].position = Vector2(-35, (reserve_models.size() - 2) * 1.3)
			reserve_state.units[model].on_battlefield = false
		else:
			reserve_state.units[model].position = Vector2(-5, 0) if reserve_state.units[model].owner == 1 else Vector2(20, 0)
	reserve_state.board_size = Vector2(60, 44)
	reserve_state.deployment = {"zones": {1: Rect2(-30, -22, 11, 44), 2: Rect2(19, -22, 11, 44)}, "complete": true}
	reserve_state.unit_abilities.reserves[reserve_squad] = {"cost": 65}
	reserve_state.phase = "pre_battle"
	reserve_state.first_player = 1
	ScoutMoves.begin(reserve_state)
	var scout_reserve_choice: Dictionary = {}
	for item: Dictionary in C.unit_choices(reserve_state, 1):
		if item.action == "scout-setup" and item.target == reserve_squad: scout_reserve_choice = item
	var reserve_start := submit_scout_choice(reserve_state, 1, "scout-setup", -1, reserve_squad) if not scout_reserve_choice.is_empty() else {"error": "missing Scout Squad reserve set-up choice"}
	var reserve_places_ok := true
	for model: int in reserve_models:
		var place := submit_scout_choice(reserve_state, 1, "scout-place", model, reserve_squad, Vector2(-25, (reserve_models.find(model) - 2) * 1.3))
		if not str(place.get("error", "")).is_empty(): reserve_places_ok = false
	var reserve_confirm_choice: Dictionary = {}
	for item: Dictionary in C.unit_choices(reserve_state, 1):
		if item.action == "scout-confirm" and item.target == reserve_squad: reserve_confirm_choice = item
	var reserve_confirm_result := submit_scout_choice(reserve_state, 1, "scout-confirm", -1, reserve_squad) if not reserve_confirm_choice.is_empty() else {"error": "missing Scout Squad reserve confirmation"}
	check(not scout_reserve_choice.is_empty() and str(reserve_start.get("error", "")).is_empty() and reserve_places_ok and not reserve_confirm_choice.is_empty() and str(reserve_confirm_result.get("error", "")).is_empty() and reserve_state.phase == "start_turn" and not reserve_state.unit_abilities.reserves.has(reserve_squad), "Scout Squad can use Scouts 6 to set up from Strategic Reserves wholly in its deployment zone before turn one")
	print("Scout Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

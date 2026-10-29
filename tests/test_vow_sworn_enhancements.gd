extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = Prepared.Combat

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(identity: String, enhancement_id: String = "", model_count: int = 1) -> Dictionary:
	var entry := {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": 1}
	if not enhancement_id.is_empty(): entry.enhancement_id = enhancement_id
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [entry]}

func fresh(identity: String, enhancement_id: String) -> Dictionary:
	return Prepared.initial_state({
		"manual_allocation": false,
		"unit_abilities": true,
		"combat_doctrines": true,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: "gladius"},
		"marine_chapters": {1: "BLACK TEMPLARS"}
	}, {1: army(identity, enhancement_id), 2: army("intercessor-squad", "", 5)})

func squad_for(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func model_for(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func prepare_unit_choices(state: Dictionary) -> void:
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.mission.stage = "battle"
	state.unit_abilities.setup_done = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = []
	state.unit_abilities.phase_key = C.UnitActions.key(state)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var consecrating_admission := ArmyCapabilities.admit(army("judiciar", MarineEnhancements.CONSECRATING_AURA))
	var incendiary_admission := ArmyCapabilities.admit(army("chaplain", MarineEnhancements.INCENDIARY_ANIMUS))
	var zealous_admission := ArmyCapabilities.admit(army("chaplain", MarineEnhancements.ZEALOUS_VANGUARD))
	var augury_admission := ArmyCapabilities.admit(army("chaplain", MarineEnhancements.AUGURY_SERVO_HOST))
	check(consecrating_admission.get("error", "").is_empty() and consecrating_admission.total == 70, "Consecrating Aura is admitted for its export-linked Judiciar bearer at 20 points")
	check(incendiary_admission.get("error", "").is_empty() and incendiary_admission.total == 85, "Incendiary Animus is admitted for its export-linked Chaplain bearer at 25 points")
	check(zealous_admission.get("error", "").is_empty() and zealous_admission.total == 85, "Zealous Vanguard is admitted for its export-linked Chaplain bearer at 25 points")
	check(augury_admission.get("error", "").is_empty() and augury_admission.total == 80, "Augury Servo-host is admitted for its export-linked Chaplain bearer at 20 points")
	check(not ArmyCapabilities.admit(army("captain", MarineEnhancements.INCENDIARY_ANIMUS)).get("error", "").is_empty(), "Incendiary Animus rejects a source-ineligible Captain")

	var aura_state := fresh("judiciar", MarineEnhancements.CONSECRATING_AURA)
	check(not aura_state.has("error"), "The Consecrating Aura bearer enters a local Vow-sworn match: %s" % str(aura_state.get("error", "")))
	if not aura_state.has("error"):
		var aura_model := model_for(aura_state, squad_for(aura_state, 1))
		var ranged_defense := DefenderGroups.profile(aura_state, aura_model)
		var melee_defense := DefenderGroups.profile(aura_state, aura_model, true)
		check(int(ranged_defense.get("invulnerable_target", 0)) == 5, "Consecrating Aura grants a 5+ invulnerable save to a bearer without a general invulnerable save")
		check(int(melee_defense.get("invulnerable_target", 0)) == 4, "Consecrating Aura preserves the Judiciar's better melee invulnerable save")

	var incendiary_state := fresh("chaplain", MarineEnhancements.INCENDIARY_ANIMUS)
	check(not incendiary_state.has("error"), "The Incendiary Animus bearer enters a local Vow-sworn match: %s" % str(incendiary_state.get("error", "")))
	if not incendiary_state.has("error"):
		var attacker_squad := squad_for(incendiary_state, 1)
		var defender_squad := squad_for(incendiary_state, 2)
		var attacker := model_for(incendiary_state, attacker_squad)
		var weapon: Dictionary = incendiary_state.units[attacker].melee_weapons[0]
		for index: int in C.living(incendiary_state, defender_squad): incendiary_state.units[index].position = Vector2(1.5, float(index - C.living(incendiary_state, defender_squad)[0]) * 3.0)
		incendiary_state.units[attacker].position = Vector2.ZERO
		incendiary_state.phase = "fight"
		incendiary_state.active = 1
		incendiary_state.fight_actor = 1
		incendiary_state.fight_step = "attacks"
		incendiary_state.squads[attacker_squad].fight_eligible = true
		var base_strength := int(weapon.profiles.standard.strength)
		var melee_plan := C.AttackPlan.prepare(incendiary_state, attacker_squad, true, [{"model": attacker, "target": defender_squad, "amount": int(weapon.profiles.standard.attacks), "weapon": str(weapon.id), "profile": "standard"}], false)
		check(melee_plan.get("error", "").is_empty() and melee_plan.get("batches", []).size() == 1 and int(melee_plan.batches[0].weapon.strength) == base_strength + 1, "Incendiary Animus adds exactly +1 Strength to the Chaplain's melee AttackPlan: %s" % str(melee_plan.get("error", "")))

	var zealous_state := fresh("chaplain", MarineEnhancements.ZEALOUS_VANGUARD)
	check(not zealous_state.has("error"), "The Zealous Vanguard bearer enters a local Vow-sworn match: %s" % str(zealous_state.get("error", "")))
	if not zealous_state.has("error"):
		var scout_squad := squad_for(zealous_state, 1)
		var scout_model := model_for(zealous_state, scout_squad)
		var deployment_zone: Rect2 = zealous_state.deployment.zones[1]
		zealous_state.units[scout_model].position = deployment_zone.get_center()
		check(C.UnitAbilities.scout_distance(zealous_state, scout_squad) == 6, "Zealous Vanguard supplies Scouts 6 through the shared ability query")
		ScoutMoves.begin(zealous_state)
		var scout_choices := ScoutMoves.choices(zealous_state, 1)
		var scout_move_offered := false
		for candidate: Dictionary in scout_choices:
			if str(candidate.get("action", "")) == "scout-move" and int(candidate.get("target", -1)) == scout_squad: scout_move_offered = true
		check(zealous_state.unit_abilities.get("window", {}).get("kind", "") == "scouts" and scout_move_offered, "Zealous Vanguard enters the normal pre-battle Scout move flow")

	var augury_state := fresh("chaplain", MarineEnhancements.AUGURY_SERVO_HOST)
	check(not augury_state.has("error"), "The Augury Servo-host bearer enters a local Vow-sworn match: %s" % str(augury_state.get("error", "")))
	if not augury_state.has("error"):
		var source_squad := squad_for(augury_state, 1)
		var source_model := model_for(augury_state, source_squad)
		var target_squad := squad_for(augury_state, 2)
		var source_weapon: Dictionary = augury_state.units[source_model].ranged_weapons[0]
		augury_state.units[source_model].position = Vector2.ZERO
		for target_model: int in C.living(augury_state, target_squad): augury_state.units[target_model].position = Vector2(8, 0)
		augury_state.terrain.id = "terrain-11e-v1"
		augury_state.terrain.areas = [{"name": "Test cover", "category": "light", "bounds": Rect2(6, -2, 4, 4), "features": []}]
		prepare_unit_choices(augury_state)
		var sight: Dictionary = C.Terrain.targeting(augury_state, source_model, target_squad)
		check(bool(sight.get("visible", false)) and bool(sight.get("cover", false)), "The Augury regression target is visible and normally benefits from terrain cover")
		var before_mark := C.AttackPlan.prepare(augury_state, source_squad, false, [{"model": source_model, "target": target_squad, "amount": 1, "weapon": str(source_weapon.id), "profile": "standard"}], false)
		check(before_mark.get("error", "").is_empty() and bool(before_mark.batches[0].context.benefit_of_cover), "The unmarked target receives cover against the Chaplain's ranged attack")
		var selected: Dictionary = {}
		for candidate: Dictionary in C.UnitActions.choices(augury_state, 1):
			if str(candidate.get("action", "")) == "augury-servo-host" and int(candidate.get("target", -1)) == target_squad: selected = candidate
		check(not selected.is_empty(), "Augury Servo-host offers the visible enemy within 18 inches during the Shooting phase")
		if not selected.is_empty():
			var submitted := PublicUnitCommand.submit(augury_state, 1, selected, Vector2.ZERO)
			check(str(submitted.get("error", "")).is_empty() and C.UnitAbilities.cover_denial_mark_active(augury_state, 1, target_squad), "Augury Servo-host marks the selected enemy through the public unit command")
			var after_mark := C.AttackPlan.prepare(augury_state, source_squad, false, [{"model": source_model, "target": target_squad, "amount": 1, "weapon": str(source_weapon.id), "profile": "standard"}], false)
			check(after_mark.get("error", "").is_empty() and not bool(after_mark.batches[0].context.benefit_of_cover), "Augury Servo-host removes cover from the marked target's ranged attack context")
			check(C.UnitActions.augury_servo_host_choices(augury_state, 1).is_empty(), "Augury Servo-host can select only one target for the enhanced unit that phase")
			augury_state.phase = "fight"
			check(not C.UnitAbilities.cover_denial_mark_active(augury_state, 1, target_squad), "Augury Servo-host's cover denial expires after the Shooting phase")

	print("Vow-sworn enhancement checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const R = preload("res://scripts/edition_11/core_reactions.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1

func selections(models: int = 2) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": models, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 10, "copies": 1}]
	return result

func fixture(models: int = 2) -> Dictionary:
	var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections(models))
	if not s.has("error"):
		s.mission.stage = "battle"
		s.awakened_dynasty.pending = []
	return s

func choice(s: Dictionary, player: int, squad: int, action: String, value: String = "", model: int = -2) -> Dictionary:
	for option: Dictionary in C.unit_choices(s, player):
		if option.action == action and option.target == squad and option.value == value and (model == -2 or int(option.model) == model): return option
	return {}

func submit_choice(s: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := C.UnitActions.pending_decision(s)
	if decision.is_empty(): return {"error": "No pending UnitActions decision."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The selected choice is not in the current projection."}
	return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision), "point": Vector2.ZERO, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}})

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := P.profile("firestrike-servo-turrets")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000086" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Firestrike profile is tied to the local Space Marines Wahapedia export")
	check(profile.points_by_models == {1: 80, 2: 160} and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Turret sizes, points and characteristics match the extracted datasheet")
	check(is_equal_approx(profile.base_radius_inches, 40.0 / 25.4) and profile.keywords.has("ARTILLERY") and profile.keywords.has("VEHICLE") and profile.keywords.has("ADEPTUS ASTARTES"), "Firestrike base geometry and datasheet keywords match the source")
	var las_profile: Dictionary = profile.ranged[0].profiles.standard
	var autocannon_profile: Dictionary = P.firestrike_autocannon().profiles.standard
	var hovering_bulk_profile: Dictionary = profile.melee[0].profiles.standard
	check(las_profile.name == "Twin Firestrike Las-talon" and las_profile.range_inches == 36.0 and las_profile.attacks == 2 and las_profile.skill == 2 and las_profile.strength == 10 and las_profile.ap == -3 and las_profile.damage == "D3+3" and las_profile.keywords.get("twin-linked", false), "Twin Firestrike Las-talon retains its exact source profile")
	check(autocannon_profile.name == "Twin Firestrike Autocannon" and autocannon_profile.range_inches == 48.0 and autocannon_profile.attacks == 4 and autocannon_profile.skill == 2 and autocannon_profile.strength == 9 and autocannon_profile.ap == -1 and autocannon_profile.damage == 3 and autocannon_profile.keywords.get("twin-linked", false) and autocannon_profile.keywords.get("rapid-fire", 0) == 2, "Twin Firestrike Autocannon retains Twin-linked and Rapid Fire 2")
	check(hovering_bulk_profile.name == "Hovering Bulk" and hovering_bulk_profile.attacks == 3 and hovering_bulk_profile.skill == 3 and hovering_bulk_profile.strength == 5 and hovering_bulk_profile.ap == 0 and hovering_bulk_profile.damage == 1, "Hovering Bulk retains its melee profile")
	check(Capabilities.supported("sentinel-protocols"), "Sentinel Protocols is declared as locally supported")
	var one := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": 1, "copies": 1}]})
	var two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": 2, "copies": 1}]})
	if not one.error.is_empty() or not two.error.is_empty(): print("Firestrike admission diagnostics: ", one, " / ", two)
	check(one.error.is_empty() and one.total == 80 and two.error.is_empty() and two.total == 160, "Both Wahapedia model-count and cost options enter local construction")
	var s := fixture()
	if s.has("error"): print("Firestrike fixture diagnostic: ", s)
	check(not s.has("error"), "Firestrike formation materializes in the prepared game")
	if s.has("error"):
		print("Firestrike Servo-turrets checks: %d failures" % (failures + 1)); quit(1); return
	var squad := -1
	var target_squad := -1
	var models: Array[int] = []
	for model: int in s.units:
		if C.UnitAbilities.identity(s.units[model]) == "firestrike-servo-turrets":
			squad = s.units[model].squad
			models.append(model)
	for candidate: int in s.squads:
		if s.squads[candidate].owner == 2:
			target_squad = candidate
			break
	check(models.size() == 2 and squad >= 0 and C.UnitAbilities.has(s, squad, "sentinel-protocols"), "Two-turret unit carries Sentinel Protocols")
	if squad >= 0 and not models.is_empty():
		var gun := P.firestrike_autocannon()
		var validation := Attacks._validate(gun.profiles.standard, {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}, {"distance_inches": 20.0, "heavy_eligible": false, "target_model_count": 1, "target_engaged": false})
		check(validation.is_empty(), "Autocannon profile passes the combat validator")
		s.phase = "deployment"
		s.unit_abilities.setup_players = []
		var swap := choice(s, 1, squad, "firestrike-gun", "autocannon")
		var preparation := C.UnitActions.pending_decision(s)
		var before_swap := var_to_bytes(s)
		var wrong_owner_swap := PublicUnitCommand.submit(s, 2, swap)
		var stale_swap := PublicUnitCommand.submit(s, 1, swap, Vector2.ZERO, Callable(), str(preparation.get("decision_id", "")), "stale-option")
		check(not wrong_owner_swap.get("error", "").is_empty() and not stale_swap.get("error", "").is_empty() and before_swap == var_to_bytes(s), "Wrong-owner and stale Firestrike loadout commands are rejected unchanged")
		var swap_result := PublicUnitCommand.error(s, 1, swap) if not swap.is_empty() else "choice unavailable"
		if not swap_result.is_empty(): print("Firestrike gear diagnostic: ", swap_result)
		check(not swap.is_empty() and swap_result.is_empty() and s.units[models[0]].ranged_weapons[0].id == "twin-firestrike-autocannon", "A turret can replace its Las-talon with the source-listed Autocannon")
		var model0_las := false
		var model0_autocannon := false
		for option: Dictionary in C.unit_choices(s, 1):
			if option.action == "firestrike-gun" and option.model == models[0]:
				if option.value == "las-talon": model0_las = true
				if option.value == "autocannon": model0_autocannon = true
		var second_turret_swap := choice(s, 1, squad, "firestrike-gun", "autocannon", models[1])
		check(model0_las and not model0_autocannon and not second_turret_swap.is_empty() and int(second_turret_swap.model) == models[1], "The setup choice offers only the reversible opposite weapon and keeps each turret's swap independent")
		s.phase = "movement"
		s.active = 2
		s.cp = {1: 3, 2: 3}
		s.unit_abilities.window = {"kind": "end", "owners": [1]}
		for model: int in models: s.units[model].position = Vector2(0, 0)
		for model: int in C.living(s, 3): s.units[model].position = Vector2(0, 0)
		for friendly: int in s.units:
			if s.units[friendly].owner == 1: s.units[friendly].position = Vector2(0, 0)
		for model: int in C.living(s, target_squad): s.units[model].position = Vector2(8, 0)
		var prior_squad := -1
		var ordinary_squad := -1
		for friendly: int in s.squads:
			if friendly != squad and s.squads[friendly].owner == 1:
				prior_squad = friendly
				for member: int in C.living(s, friendly):
					if C.UnitAbilities.identity(s.units[member]) != "firestrike-servo-turrets": ordinary_squad = friendly; break
				if ordinary_squad != -1: break
		s.stratagems.uses.append({"player": 1, "squad": prior_squad, "stratagem": R.OVERWATCH, "phase_key": R.phase_key(s), "turn": s.turn})
		s.core_reactions.overwatch = {}
		var sentinel_error := R.error(s, 1, squad, R.OVERWATCH)
		if not sentinel_error.is_empty(): print("Firestrike Overwatch diagnostic: ", sentinel_error, " prior squad=", prior_squad, " current=", squad)
		check(sentinel_error.is_empty(), "Sentinel Protocols allows Fire Overwatch after another unit already used it this phase")
		check(not R.error(s, 1, ordinary_squad, R.OVERWATCH).is_empty(), "The extra Overwatch use does not grant another use to a non-Sentinel unit")
		var overwatch := choice(s, 1, squad, "core-stratagem", R.OVERWATCH)
		var wrong_owner_snapshot := var_to_str(s)
		var wrong_owner_result := submit_choice(s, 2, overwatch) if not overwatch.is_empty() else {"error": "choice unavailable"}
		check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_str(s) == wrong_owner_snapshot, "Firestrike Overwatch rejects the non-priority player without mutation")
		var overwatch_result := submit_choice(s, 1, overwatch) if not overwatch.is_empty() else {"error": "choice unavailable"}
		if not str(overwatch_result.get("error", "")).is_empty(): print("Firestrike Overwatch use diagnostic: ", overwatch_result)
		check(not overwatch.is_empty() and str(overwatch_result.get("error", "")).is_empty(), "Firestrike may take the extra Fire Overwatch use")
		check(not R.error(s, 1, squad, R.OVERWATCH).is_empty(), "This Firestrike unit cannot use Sentinel Protocols twice in one phase")
		var independent_use := s.duplicate(true)
		independent_use.stratagems.uses = independent_use.stratagems.uses.filter(func(record: Dictionary) -> bool: return int(record.get("squad", -1)) != prior_squad)
		independent_use.core_reactions.overwatch = {}
		independent_use.unit_abilities.window = {"kind": "end", "owners": [1]}
		var independent_error := R.error(independent_use, 1, ordinary_squad, R.OVERWATCH)
		check(independent_error.is_empty(), "The Firestrike's extra use does not consume another unit's ordinary Fire Overwatch use (%s)" % independent_error)
		var plan := C.AttackPlan.prepare(s, squad, false, C.AttackPlan.single_target(s, squad, target_squad, false), true)
		check(plan.get("error", "").is_empty() and plan.get("batches", []).size() > 0 and plan.batches[0].context.snap_shooting and plan.batches[0].context.snap_hit_threshold == 4 and plan.batches[0].context.hit_reroll == "none", "Firestrike snap shooting hits on unmodified 4+ without hit re-rolls")
		var has_las_plan := false
		var has_autocannon_plan := false
		for batch: Dictionary in plan.get("batches", []):
			if batch.weapon.name == "Twin Firestrike Las-talon":
				has_las_plan = batch.weapon.range_inches == 36.0 and batch.weapon.attacks == 2 and batch.weapon.skill == 2 and batch.weapon.strength == 10 and batch.weapon.ap == -3 and str(batch.weapon.damage) == "D3+3" and batch.weapon.keywords.get("twin-linked", false) and batch.count == 2
			if batch.weapon.name == "Twin Firestrike Autocannon":
				has_autocannon_plan = batch.weapon.range_inches == 48.0 and batch.weapon.attacks == 6 and batch.weapon.skill == 2 and batch.weapon.strength == 9 and batch.weapon.ap == -1 and batch.weapon.damage == 3 and batch.weapon.keywords.get("twin-linked", false) and batch.count == 6
		check(has_las_plan and has_autocannon_plan, "Both individual turret weapons enter the Overwatch AttackPlan with their source stats and Rapid Fire at half range (%s)" % str(plan.get("batches", [])))
		var melee_battle := fixture(1)
		melee_battle.phase = "fight"
		melee_battle.active = 1
		melee_battle.unit_abilities.setup_players = [1, 2]
		var melee_squad := -1
		var melee_target := -1
		var firestrike_model := -1
		for model: int in melee_battle.units:
			if C.UnitAbilities.identity(melee_battle.units[model]) == "firestrike-servo-turrets":
				melee_squad = int(melee_battle.units[model].squad)
				firestrike_model = model
				melee_battle.units[model].position = Vector2.ZERO
			if int(melee_battle.units[model].owner) == 2 and melee_target == -1: melee_target = int(melee_battle.units[model].squad)
		if melee_target >= 0:
			for model: int in C.living(melee_battle, melee_target):
				melee_battle.units[model].position = Vector2(20 + model % 10, 0)
				break
			var melee_victim := C.living(melee_battle, melee_target)[0]
			melee_battle.units[melee_victim].position = Vector2(1.75, 0)
		var melee_entries := C.AttackPlan.single_target(melee_battle, melee_squad, melee_target, true)
		var melee_plan := C.AttackPlan.prepare(melee_battle, melee_squad, true, melee_entries, true)
		check(melee_plan.get("error", "").is_empty() and melee_plan.get("batches", []).size() == 1 and melee_plan.batches[0].weapon.name == "Hovering Bulk" and melee_plan.batches[0].count == 3 and melee_plan.batches[0].weapon.skill == 3 and melee_plan.batches[0].weapon.strength == 5 and melee_plan.batches[0].weapon.ap == 0 and melee_plan.batches[0].weapon.damage == 1, "Hovering Bulk is available through the Fight AttackPlan against an engaged target (%s)" % str(melee_plan))
	var result := Attacks.roll_pool({"skill": 2, "strength": 9, "ap": -1, "damage": 3, "attacks": 4, "keywords": {"sustained-hits": 1, "lethal-hits": true}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1, 1, 1, 1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true, "snap_hit_threshold": 4, "hit_reroll": "none", "use_lethal_hits": true}, func() -> int: return 4)
	check(result.error.is_empty() and result.hits == 4 and result.hit_rolls == [4, 4, 4, 4], "Unmodified 4s hit during Firestrike snap shooting and remain non-critical hits")
	var invalid_threshold := Attacks.roll_pool({"skill": 2, "strength": 9, "ap": -1, "damage": 3, "attacks": 1, "keywords": {}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_hit_threshold": 1}, func() -> int: return 4)
	check(not invalid_threshold.error.is_empty(), "Invalid snap threshold is rejected outside snap shooting")
	print("Firestrike Servo-turrets checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

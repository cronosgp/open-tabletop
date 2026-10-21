extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const R = preload("res://scripts/edition_11/core_reactions.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1

func selections(models: int = 2) -> Dictionary:
	var result := F.selections()
	var entries: Array = []
	for entry: Dictionary in result[1].entries:
		if entry.definition_id.ends_with(":assault-intercessor-squad"):
			entries.append({"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": models, "copies": 1})
		else: entries.append(entry)
	result[1].entries = entries
	return result

func fixture(models: int = 2) -> Dictionary:
	var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections(models))
	if not s.has("error"):
		s.mission.stage = "battle"
		s.awakened_dynasty.pending = []
	return s

func choice(s: Dictionary, player: int, squad: int, action: String, value: String = "") -> Dictionary:
	for option: Dictionary in C.unit_choices(s, player):
		if option.action == action and option.target == squad and option.value == value: return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := P.profile("firestrike-servo-turrets")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000086" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Firestrike profile is tied to the local Space Marines Wahapedia export")
	check(profile.points_by_models == {1: 80, 2: 160} and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Turret sizes, points and characteristics match the extracted datasheet")
	check(profile.ranged[0].profiles.standard.name == "Twin Firestrike Las-talon" and profile.ranged[0].profiles.standard.damage == "D3+3" and profile.additional_weapon_profiles.ranged[0].profiles.standard.name == "Twin Firestrike Autocannon", "Both source-listed twin weapon profiles are recorded")
	check(C.Capabilities.supported("sentinel-protocols"), "Sentinel Protocols is declared as locally supported")
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
	var models: Array[int] = []
	for model: int in s.units:
		if C.UnitAbilities.identity(s.units[model]) == "firestrike-servo-turrets":
			squad = s.units[model].squad
			models.append(model)
	check(models.size() == 2 and squad >= 0 and C.UnitAbilities.has(s, squad, "sentinel-protocols"), "Two-turret unit carries Sentinel Protocols")
	if squad >= 0 and not models.is_empty():
		var gun := P.firestrike_autocannon()
		var validation := Attacks._validate(gun.profiles.standard, {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}, {"distance_inches": 20.0, "heavy_eligible": false, "target_model_count": 1, "target_engaged": false})
		check(validation.is_empty(), "Autocannon profile passes the combat validator")
		s.phase = "deployment"
		s.unit_abilities.setup_players = []
		var swap := choice(s, 1, squad, "firestrike-gun", "autocannon")
		var swap_result := C.unit_action(s, 1, swap, Vector2.ZERO, s.revision) if not swap.is_empty() else "choice unavailable"
		if not swap_result.is_empty(): print("Firestrike gear diagnostic: ", swap_result)
		check(not swap.is_empty() and swap_result.is_empty() and s.units[models[0]].ranged_weapons[0].id == "twin-firestrike-autocannon", "A turret can replace its Las-talon with the source-listed Autocannon")
		var model0_las := false
		var model0_autocannon := false
		for option: Dictionary in C.unit_choices(s, 1):
			if option.action == "firestrike-gun" and option.model == models[0]:
				if option.value == "las-talon": model0_las = true
				if option.value == "autocannon": model0_autocannon = true
		check(model0_las and not model0_autocannon, "The setup choice only offers the reversible opposite weapon for each turret")
		s.phase = "movement"
		s.active = 2
		s.cp = {1: 3, 2: 3}
		s.unit_abilities.window = {"kind": "end", "owners": [1]}
		for model: int in models: s.units[model].position = Vector2(0, 0)
		for model: int in C.living(s, 3): s.units[model].position = Vector2(0, 0)
		for friendly: int in s.units:
			if s.units[friendly].owner == 1: s.units[friendly].position = Vector2(0, 0)
		for model: int in C.living(s, 2): s.units[model].position = Vector2(8, 0)
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
		var overwatch_result := C.unit_action(s, 1, overwatch, Vector2.ZERO, s.revision) if not overwatch.is_empty() else "choice unavailable"
		if not overwatch_result.is_empty(): print("Firestrike Overwatch use diagnostic: ", overwatch_result)
		check(not overwatch.is_empty() and overwatch_result.is_empty(), "Firestrike may take the extra Fire Overwatch use")
		check(not R.error(s, 1, squad, R.OVERWATCH).is_empty(), "This Firestrike unit cannot use Sentinel Protocols twice in one phase")
		var plan := C.AttackPlan.prepare(s, squad, false, C.AttackPlan.single_target(s, squad, 2, false), true)
		check(plan.get("error", "").is_empty() and plan.get("batches", []).size() > 0 and plan.batches[0].context.snap_shooting and plan.batches[0].context.snap_hit_threshold == 4 and plan.batches[0].context.hit_reroll == "none", "Firestrike snap shooting hits on unmodified 4+ without hit re-rolls")
	var result := Attacks.roll_pool({"skill": 2, "strength": 9, "ap": -1, "damage": 3, "attacks": 4, "keywords": {"sustained-hits": 1, "lethal-hits": true}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1, 1, 1, 1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true, "snap_hit_threshold": 4, "hit_reroll": "none", "use_lethal_hits": true}, func() -> int: return 4)
	check(result.error.is_empty() and result.hits == 4 and result.hit_rolls == [4, 4, 4, 4], "Unmodified 4s hit during Firestrike snap shooting and remain non-critical hits")
	var invalid_threshold := Attacks.roll_pool({"skill": 2, "strength": 9, "ap": -1, "damage": 3, "attacks": 1, "keywords": {}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_hit_threshold": 1}, func() -> int: return 4)
	check(not invalid_threshold.error.is_empty(), "Invalid snap threshold is rejected outside snap shooting")
	print("Firestrike Servo-turrets checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

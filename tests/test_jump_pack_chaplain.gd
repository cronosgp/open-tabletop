extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:chaplain-with-jump-pack", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs", "models": 5, "copies": 1}]
	return result

func _initialize() -> void:
	var profile := Profiles.profile("chaplain-with-jump-pack")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000112" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Jump Pack Chaplain preserves its local Wahapedia source identity")
	check(profile.points_by_models == {1: 75} and profile.stats.movement_inches == 12 and profile.stats.toughness == 5 and profile.stats.save_target == 3 and profile.stats.wounds == 4 and profile.stats.leadership_target == 5 and profile.stats.invulnerable_target == 4, "Jump Pack Chaplain characteristics and points match the local extraction")
	check(profile.ranged[0].profiles.standard.name == "Absolvor Bolt Pistol" and profile.melee[0].profiles.standard.attacks == 5 and profile.melee[0].profiles.standard.skill == 2 and profile.melee[0].profiles.standard.keywords.cleave == 1, "Fixed source equipment and Crozius Arcanum profile are present")
	var roster := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:chaplain-with-jump-pack", "models": 1, "copies": 1}]})
	check(roster.error.is_empty() and roster.total == 75, "Chaplain With Jump Pack is admitted from the consolidated local catalog")
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Jump Pack Chaplain and Assault Intercessors materialize from local profiles")
	if state.has("error"):
		print("Jump Pack Chaplain checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.awakened_dynasty.pending = []
	var chaplain_model := -1
	var chaplain_squad := -1
	var bodyguard_squad := -1
	var enemy_squad := -1
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		if identity == "chaplain-with-jump-pack": chaplain_model = model
		if state.squads[state.units[model].squad].owner == 2: enemy_squad = state.units[model].squad
	for squad: int in state.squads:
		if state.squads[squad].owner != 1: continue
		for model: int in C.living(state, squad):
			var identity := C.UnitAbilities.identity(state.units[model])
			if identity == "chaplain-with-jump-pack": chaplain_squad = squad
			if identity == "assault-intercessors-with-jump-packs": bodyguard_squad = squad
	check(chaplain_model >= 0 and chaplain_squad >= 0 and bodyguard_squad >= 0 and enemy_squad >= 0, "The expected Chaplain, bodyguard and opposing units were created")
	if chaplain_model < 0 or chaplain_squad < 0 or bodyguard_squad < 0 or enemy_squad < 0:
		print("Jump Pack Chaplain checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(state, chaplain_model, bodyguard_squad), "Jump Pack Chaplain can lead both admitted Jump Pack bodyguard sheets")
	C.UnitActions.attach(state, chaplain_model, bodyguard_squad)
	check(state.units[chaplain_model].squad == bodyguard_squad and C.UnitAbilities.has(state, bodyguard_squad, "litany-of-hate") and C.UnitAbilities.has(state, bodyguard_squad, "exhortation-of-rage"), "The attached unit receives Litany of Hate and Exhortation of Rage from the living Chaplain")
	check(C.UnitAbilities.every_model_has(state, bodyguard_squad, "deep-strike"), "The Chaplain and Jump Pack bodyguards all satisfy the Deep Strike every-model condition")
	state.unit_abilities.setup_players = [1, 2]
	state.phase = "fight"
	state.active = 1
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20 if state.units[model].owner == 1 else 20, model % 5)
	state.units[chaplain_model].position = Vector2.ZERO
	var target_model := C.living(state, enemy_squad)[0]
	state.units[target_model].position = Vector2(1.5, 0)
	state.squads[bodyguard_squad].charged = true
	var full_entries := C.AttackPlan.single_target(state, bodyguard_squad, enemy_squad, true)
	var full_plan := C.AttackPlan.prepare(state, bodyguard_squad, true, full_entries, true)
	check(not Morale.at_half_strength(state, bodyguard_squad) and full_plan.error.is_empty() and full_plan.batches.size() == 1 and full_plan.batches[0].context.wound_modifier == 1 and full_plan.batches[0].context.get("wound_reroll", "none") == "none", "At full strength the attached Chaplain grants Lance without Exhortation's conditional wound reroll")
	var killed := 0
	for model: int in C.living(state, bodyguard_squad):
		if model == chaplain_model or killed >= 3: continue
		state.units[model].wounds = 0
		killed += 1
	check(killed == 3 and Morale.at_half_strength(state, bodyguard_squad), "The attached unit reaches its source-defined half-strength threshold")
	var half_entries := C.AttackPlan.single_target(state, bodyguard_squad, enemy_squad, true)
	var half_plan := C.AttackPlan.prepare(state, bodyguard_squad, true, half_entries, true)
	check(half_plan.error.is_empty() and half_plan.batches.size() == 1 and half_plan.batches[0].context.wound_modifier == 1 and half_plan.batches[0].context.get("free_wound_reroll", false) and half_plan.batches[0].context.get("free_wound_reroll_source", "") == "Exhortation of Rage" and half_plan.batches[0].context.get("wound_reroll", "none") == "none", "At or below half strength Exhortation opens optional free wound rerolls in the actual Fight attack plan")
	var checkpoint := {"phase": "wound", "context": half_plan.batches[0].context.duplicate(true), "effective_wounds": [5, 2], "rerolled_wounds": []}
	state.pending_attack = {"player": 1, "current": {"checkpoint": checkpoint}}
	state.unit_abilities.window = {"kind": "wound", "owners": [1]}
	var reroll_choices: Array = C.UnitActions.choices(state, 1)
	var can_reroll_success := false
	for option: Dictionary in reroll_choices:
		if option.action == "wound-reroll" and option.target == 0 and option.label.begins_with("Exhortation of Rage:"): can_reroll_success = true
	check(can_reroll_success and reroll_choices.size() == 3, "Exhortation offers an optional reroll for successful as well as failed wound dice")
	print("Jump Pack Chaplain checks: %d failures" % failures)
	quit(1 if failures else 0)

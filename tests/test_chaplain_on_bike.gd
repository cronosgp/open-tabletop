extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const C = F.C
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, identity: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return int(state.units[model].squad)
	return -1

func models(state: Dictionary, squad_id: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in C.living(state, squad_id): result.append(model)
	return result

func submit_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload := selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
		if projected.is_empty(): return {"error": "The selected Catechism option is not in the current projection."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": payload, "point": Vector2.ZERO, "revision": int(state.revision)})

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("chaplain-on-bike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000094" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Chaplain on Bike cites the pinned local Wahapedia e11 datasheet")
	check(profile.points_by_models == {1: 75} and profile.get("third_plus_points_by_models", {}) == {1: 75} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 45.0 / 25.4), "Chaplain on Bike composition, points and oval base proxy are represented")
	check(profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 2, "invulnerable_target": 4}, "Chaplain on Bike characteristics match the local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["absolvor-bolt-pistol", "twin-bolt-rifle"] and profile.melee[0].id == "crozius-arcanum", "Chaplain on Bike fixed loadout matches the local rows")
	check(profile.ranged[0].profiles.standard == {"name": "Absolvor Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"close-quarters": true}}, "Absolvor Bolt Pistol matches the exported weapon profile")
	check(profile.ranged[1].profiles.standard == {"name": "Twin Bolt Rifle", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"twin-linked": true, "rapid-fire": 2}}, "Twin Bolt Rifle matches the exported weapon profile")
	check(profile.melee[0].profiles.standard == {"name": "Crozius Arcanum", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -1, "damage": 2, "keywords": {"cleave": 1}}, "Crozius Arcanum matches the exported weapon profile")
	check(Catalog.SPECS.has("chaplain-on-bike") and Roster.POINTS["chaplain-on-bike"].sizes == {1: 75}, "Chaplain on Bike enters local roster admission at the extracted cost")
	var lists := F.current_marine_selections()
	lists[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:chaplain-on-bike", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	lists[2].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:heavy-intercessor-squad", "models": 5, "copies": 1}]
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Both players and the Chaplain on Bike materialize from the consolidated current Marine catalog")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.phase = "deployment"
	var chaplain := squad(state, "chaplain-on-bike")
	var outriders := squad(state, "outrider-squad")
	check(chaplain > 0 and outriders > 0 and C.UnitActions.attachment_allowed(state, models(state, chaplain)[0], outriders), "Chaplain on Bike may lead Outrider Squad")
	var source_model: int = models(state, chaplain)[0]
	C.UnitActions.attach(state, source_model, outriders)
	check(state.units[source_model].squad == outriders and state.units[source_model].attachment_role == "leader" and state.squads[outriders].get("attached", false), "Chaplain on Bike attachment to Outriders applies")
	check(not C.UnitActions.attachment_allowed(state, source_model, squad_for(state, 1, "intercessor-squad")), "Chaplain on Bike is not admitted to infantry bodyguards")
	var rider_models := models(state, outriders)
	var rider_model := rider_models[0]
	var target_a := squad_for(state, 2, "intercessor-squad")
	var target_b := squad_for(state, 2, "heavy-intercessor-squad")
	var index := 0
	for model: int in C.living(state, outriders):
		state.units[model].position = Vector2(-5, -3 + index * 3)
		index += 1
	index = 0
	for model: int in C.living(state, target_a):
		state.units[model].position = Vector2(6, -15 + index * 3)
		index += 1
	index = 0
	for model: int in C.living(state, target_b):
		state.units[model].position = Vector2(6, 10 + index * 3)
		index += 1
	state.phase = "shooting"
	state.turn = 1
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.used.erase("catechism-fire:%d" % outriders)
	var absolvor := Equipment.select(state, source_model, false, "absolvor-bolt-pistol", "standard")
	var rifle := Equipment.select(state, source_model, false, "twin-bolt-rifle", "standard")
	var crozius := Equipment.select(state, source_model, true, "crozius-arcanum", "standard")
	check(str(absolvor.get("error", "")).is_empty() and absolvor.get("stats", {}) == profile.ranged[0].profiles.standard, "Equipment routes the fixed Absolvor Bolt Pistol profile")
	check(str(rifle.get("error", "")).is_empty() and rifle.get("stats", {}) == profile.ranged[1].profiles.standard, "Equipment routes the fixed Twin Bolt Rifle profile")
	check(str(crozius.get("error", "")).is_empty() and crozius.get("stats", {}) == profile.melee[0].profiles.standard, "Equipment routes the fixed Crozius Arcanum profile")
	state.units[source_model].on_battlefield = false
	check(C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire").is_empty(), "Off-board Chaplain cannot offer Catechism of Fire")
	state.units[source_model].on_battlefield = true
	var targets: Array = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire")
	check(targets.any(func(choice: Dictionary) -> bool: return choice.target == target_a) and targets.any(func(choice: Dictionary) -> bool: return choice.target == target_b), "Catechism offers each visible enemy unit before shooting")
	if not targets.any(func(choice: Dictionary) -> bool: return choice.target == target_a) or not targets.any(func(choice: Dictionary) -> bool: return choice.target == target_b):
		print("Catechism targets: ", targets, " Visible A/B: ", C.Terrain.targeting(state, rider_model, target_a), " / ", C.Terrain.targeting(state, rider_model, target_b))
		quit(1)
		return
	var selected: Dictionary = targets.filter(func(choice: Dictionary) -> bool: return choice.target == target_a)[0]
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner_result := submit_choice(state, 2, selected)
	check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "A non-priority player cannot select Catechism's target")
	var selected_result := submit_choice(state, 1, selected)
	check(str(selected_result.get("error", "")).is_empty(), "Catechism target selection applies: " + str(selected_result.get("error", "")))
	check(C.UnitAbilities.has(state, outriders, "catechism-of-fire") and C.UnitAbilities.has(state, outriders, "litany-of-hate"), "Attached unit receives Catechism and Litany while the Chaplain lives")
	var twin_bolt_rifle: Dictionary = Profiles.profile("outrider-squad").ranged[1].profiles.standard
	var target_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_a, twin_bolt_rifle, false)
	var other_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_b, twin_bolt_rifle, false)
	var melee_effect: Dictionary = C.UnitAbilities.weapon(state, rider_model, target_a, Profiles.profile("outrider-squad").melee[0].profiles.standard, true)
	check(target_effect.keywords.get("devastating-wounds", false), "Catechism grants Devastating Wounds against the selected target")
	check(not other_effect.keywords.get("devastating-wounds", false) and not melee_effect.keywords.get("devastating-wounds", false), "Catechism does not affect other targets or melee attacks")
	check(melee_effect.keywords.get("lance", false), "Litany of Hate grants Lance to attached Outrider melee attacks")
	var twin_entries: Array = [{"model": source_model, "target": target_a, "amount": 1, "weapon": "twin-bolt-rifle", "profile": "standard"}]
	var twin_plan := C.AttackPlan.prepare(state, outriders, false, twin_entries, true)
	var twin_batch := {}
	for batch: Dictionary in twin_plan.get("batches", []):
		if "Twin Bolt Rifle" in batch.get("labels", []): twin_batch = batch
	check(twin_plan.get("error", "").is_empty() and twin_batch.get("weapon", {}).get("keywords", {}).get("devastating-wounds", false), "The selected target's Devastating Wounds effect reaches the fixed Twin Bolt Rifle attack plan")
	state.phase = "fight"
	state.units[source_model].position = Vector2.ZERO
	var melee_target_model: int = models(state, target_a)[0]
	state.units[melee_target_model].position = Vector2(state.units[source_model].radius + state.units[melee_target_model].radius + 0.8, 0.0)
	state.squads[outriders].charged = true
	var crozius_entries: Array = C.AttackPlan.single_target(state, outriders, target_a, true)
	check(crozius_entries.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == source_model and str(row.get("weapon", "")) == "crozius-arcanum" and int(row.get("amount", 0)) == 5), "The full attack plan allocates all five Crozius attacks from the Chaplain")
	var crozius_plan := C.AttackPlan.prepare(state, outriders, true, crozius_entries, true)
	var crozius_batch := {}
	for batch: Dictionary in crozius_plan.get("batches", []):
		if "Crozius Arcanum" in batch.get("labels", []): crozius_batch = batch
	check(crozius_plan.get("error", "").is_empty() and int(crozius_batch.get("context", {}).get("wound_modifier", 0)) == 1, "The Chaplain's Crozius attack plan applies Litany of Hate Lance after a Charge")
	check(C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "catechism-fire").is_empty(), "Catechism target cannot be changed after selection during that phase")
	print("Current Chaplain on Bike checks: %d failures" % failures)
	quit(1 if failures else 0)

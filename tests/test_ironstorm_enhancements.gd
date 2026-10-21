extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Defenders = preload("res://scripts/edition_11/defender_groups.gd")
const CurrentProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const C = Prepared.Combat
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(source: String, enhancement_id: String) -> Dictionary:
	var profile := CurrentProfiles.profile(source)
	var models := int(profile.models)
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": models, "copies": 1, "enhancement_id": enhancement_id}]}

func first_squad(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func first_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func _roll_six() -> int: return 6

func _initialize() -> void: call_deferred("run")

func run() -> void:
	for spec: Dictionary in [
		{"source": "gladiator-lancer", "id": Enhancements.REDOUBTABLE_MACHINE_SPIRIT, "cost": 25},
		{"source": "invader-atvs", "id": Enhancements.GUNNERY_HONOURS, "cost": 15}
	]:
		var source := str(spec.source)
		var id := str(spec.id)
		var valid := Capabilities.admit(army(source, id))
		var profile := CurrentProfiles.profile(source)
		var models := int(profile.models)
		var base_cost := int(profile.points_by_models[models])
		check(valid.error.is_empty() and valid.total == base_cost + int(spec.cost), "%s is admitted with its local points: %s" % [id, str(valid)])
		check(Enhancements.valid_for("40kdc:11e:adeptus-astartes:" + source, id, Enhancements.IRONSTORM), "%s uses the local eligible datasheet relation" % id)
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:land-raider", Enhancements.REDOUBTABLE_MACHINE_SPIRIT, Enhancements.IRONSTORM), "Ironstorm enhancements exclude Transport role datasheets")
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:redemptor-dreadnought", Enhancements.GUNNERY_HONOURS, Enhancements.IRONSTORM), "Ironstorm enhancements reject Walkers outside their export eligibility relation")

	var lancer := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.IRONSTORM}, {1: army("gladiator-lancer", Enhancements.REDOUBTABLE_MACHINE_SPIRIT), 2: army("intercessor-squad", "")})
	check(not lancer.has("error"), "Redoubtable Machine Spirit enters a local Ironstorm match: " + str(lancer.get("error", "")))
	if not lancer.has("error"):
		var squad := first_squad(lancer, 1)
		var model := first_model(lancer, squad)
		var defense := Defenders.profile(lancer, model)
		check(defense.get("invulnerable_target", 0) == 5, "Redoubtable Machine Spirit gives the unit a 5+ invulnerable save")
		lancer.units[model].wounds -= 1
		lancer.phase = "command"
		lancer.active = 1
		var healing := Enhancements.ironstorm_command_healing(lancer, 1)
		check(healing.size() == 1 and healing[0].restored == 1 and lancer.units[model].wounds == lancer.units[model].max_wounds, "Redoubtable Machine Spirit heals one lost wound at the end-of-Command hook")
		check(Enhancements.ironstorm_command_healing(lancer, 1).is_empty(), "Redoubtable Machine Spirit cannot heal twice during one Command phase")
		var lifecycle := Prepared.initial_state({"manual_allocation": false, "core_stratagems": false, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.IRONSTORM}, {1: army("gladiator-lancer", Enhancements.REDOUBTABLE_MACHINE_SPIRIT), 2: army("intercessor-squad", "")})
		if not lifecycle.has("error"):
			var lifecycle_squad := first_squad(lifecycle, 1)
			var lifecycle_model := first_model(lifecycle, lifecycle_squad)
			lifecycle.phase = "command"
			lifecycle.active = 1
			lifecycle.units[lifecycle_model].wounds -= 1
			lifecycle.combat_doctrines.selected_turn[1] = lifecycle.turn
			lifecycle.erase("stratagems")
			var end_error := C.advance_phase(lifecycle, 1, lifecycle.revision, Callable(self, "_roll_six"))
			check(end_error.is_empty() and lifecycle.phase == "movement" and lifecycle.units[lifecycle_model].wounds == lifecycle.units[lifecycle_model].max_wounds, "The phase transition resolves Redoubtable healing at Command end: " + end_error)

	var gunnery := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.IRONSTORM}, {1: army("invader-atvs", Enhancements.GUNNERY_HONOURS), 2: army("intercessor-squad", "")})
	check(not gunnery.has("error"), "Gunnery Honours enters a local Ironstorm match: " + str(gunnery.get("error", "")))
	if not gunnery.has("error"):
		var squad := first_squad(gunnery, 1)
		var model := first_model(gunnery, squad)
		var ranged := {"strength": 4, "ap": 0, "keywords": {}}
		var enhanced := AttackPlan._enhancement_weapon(gunnery, model, ranged, false)
		check(enhanced.keywords.get("heavy", false), "Gunnery Honours adds Heavy to the assigned unit's ranged attacks")
		var melee := AttackPlan._enhancement_weapon(gunnery, model, {"strength": 4, "ap": 0, "keywords": {}}, true)
		check(not melee.keywords.get("heavy", false), "Gunnery Honours does not modify melee attacks")

	print("Ironstorm enhancement checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const ARK_ID := "40kdc:11e:necrons:doomsday-ark"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [{"definition_id": ARK_ID, "models": 1, "copies": 1}]
	return result

func place(state: Dictionary, models: Array, origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(index * 1.2, 0)
		state.units[models[index]].on_battlefield = true

func prepare(state: Dictionary) -> void:
	state.unit_abilities.setup_players = [1]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		check(C.select_combat_doctrine(state, int(state.active), "none", int(state.revision)).is_empty(), "Clear the unrelated doctrine choice")
	state.phase = "shooting"
	state.active = 2
	state.turn = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}

func weapons_named(unit: Dictionary, weapon_name: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for weapon: Dictionary in unit.get("ranged_weapons", []):
		for profile: Dictionary in weapon.get("profiles", {}).values():
			if str(profile.get("name", "")) == weapon_name:
				found.append(weapon)
				break
	return found

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("doomsday-ark")
	check(profile.get("source_datasheet_id", "") == "000000554" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Doomsday Ark uses the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {1: 200} and profile.get("third_plus_points_by_models", {}) == {1: 230} and profile.stats.wounds == 14 and profile.stats.invulnerable_target == 4 and profile.base_size_source_mm == 60 and "FLY" in profile.keywords, "Doomsday Ark keeps the priced profile, 4+ invulnerable save, FLY and 60 mm flying base")
	check(profile.supported_rule_ids == ["deadly-demise-d3", "reanimation-protocols", "overwhelming-obliteration", "damaged-5"] and profile.unsupported_abilities.is_empty(), "Deadly Demise D3, Reanimation, Overwhelming Obliteration and Damaged 5 are the local ability scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ARK_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 200, "The first Doomsday Ark admits at 200 points: %s" % str(admitted.get("error", "")))
	var second := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": ARK_ID, "models": 1, "copies": 2}]})
	check(str(second.get("error", "")).is_empty() and int(second.get("total", -1)) == 400, "The second Doomsday Ark stays at 200 points")
	var third := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": ARK_ID, "models": 1, "copies": 3}]})
	check(str(third.get("error", "")).is_empty() and int(third.get("total", -1)) == 630, "The third Doomsday Ark uses the 230-point copy price")
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ARK_ID, "models": 2, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "An unpriced Doomsday Ark size stays out of construction")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Doomsday Ark roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	prepare(state)
	var ark_models: Array[int] = []
	var marines: Array[int] = []
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		if identity == "doomsday-ark": ark_models.append(model)
		elif identity == "intercessor-squad": marines.append(model)
	ark_models.sort()
	marines.sort()
	check(ark_models.size() == 1 and marines.size() == 5, "The Doomsday Ark and Marine squad materialize")
	if ark_models.is_empty() or marines.is_empty():
		quit(1)
		return
	var ark := ark_models[0]
	var squad := int(state.units[ark].squad)
	var marine_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, squad), "The one-model Doomsday Ark can activate Reanimation Protocols")
	var arrays := weapons_named(state.units[ark], "Gauss flayer array")
	var cannons := weapons_named(state.units[ark], "Doomsday cannon")
	check(arrays.size() == 2 and cannons.size() == 1 and int(state.squads[squad].stats.get("invulnerable_target", 0)) == 4, "Both gauss flayer arrays, the doomsday cannon and the 4+ invulnerable save materialize")
	if arrays.size() != 2 or cannons.is_empty():
		quit(1)
		return
	var array_id := str(arrays[0].get("id", ""))
	var cannon_id := str(cannons[0].get("id", ""))
	place(state, [ark], Vector2.ZERO)
	place(state, marines, Vector2(0, 20))
	state.units[ark].wounds = 5
	state.squads[squad].move_type = "normal"
	var damaged := AttackPlan.prepare(state, squad, false, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": array_id, "profile": "standard"}], true)
	check(str(damaged.get("error", "")).is_empty() and int(damaged.batches[0].context.get("hit_modifier", 0)) == -1 and not bool(damaged.batches[0].weapon.keywords.get("devastating-wounds", false)), "Damaged 5 subtracts 1 from a normal Hit roll, and a moved Ark does not grant Devastating Wounds: %s" % str(damaged.get("error", "")))
	scripted_dice = [3, 3, 3, 3, 3]
	var missed := C.resolve_attack_plan(state, 2, ark, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": array_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(missed.get("error", "")).is_empty() and int(missed.get("pools", [{}])[0].get("hits", -1)) == 0, "A Hit roll of 3 misses while Damaged 5 applies: %s" % str(missed.get("message", missed)))
	state.squads[squad].shot = false
	state.units[ark].wounds = 6
	var healthy := AttackPlan.prepare(state, squad, false, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": array_id, "profile": "standard"}], true)
	check(str(healthy.get("error", "")).is_empty() and int(healthy.batches[0].context.get("hit_modifier", -9)) == 0, "Damaged 5 does not apply at six remaining wounds")

	state.units[ark].wounds = 14
	state.squads[squad].move_type = "stationary"
	state.squads[squad].moved_distance = 4.0
	var granted := AttackPlan.prepare(state, squad, false, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": cannon_id, "profile": "standard"}], true)
	var arrays_plan := AttackPlan.prepare(state, squad, false, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": array_id, "profile": "standard"}], true)
	check(str(granted.get("error", "")).is_empty() and bool(granted.batches[0].weapon.keywords.get("devastating-wounds", false)), "Remaining Stationary gives the doomsday cannon Devastating Wounds even after a later move: %s" % str(granted.get("error", "")))
	check(str(arrays_plan.get("error", "")).is_empty() and not bool(arrays_plan.batches[0].weapon.keywords.get("devastating-wounds", false)), "The gauss flayer arrays do not gain Devastating Wounds")
	state.squads[squad].shot = false
	scripted_dice = [1, 6, 6, 6, 6]
	var obliterated := C.resolve_attack_plan(state, 2, ark, [{"model": ark, "target": marine_squad, "amount": 1, "weapon": cannon_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	var pool: Dictionary = obliterated.get("pools", [{}])[0]
	check(str(obliterated.get("error", "")).is_empty() and int(pool.get("devastating_wounds", 0)) >= 1 and pool.get("save_rolls", [0]).is_empty(), "A critical wound from the stationary doomsday cannon bypasses the save: %s" % str(obliterated.get("message", obliterated)))

	var demise := state.duplicate(true)
	demise.units[ark].wounds = 0
	for marine: int in marines: demise.units[marine].wounds = 2
	place(demise, [ark], Vector2.ZERO)
	place(demise, marines, Vector2(6, 0))
	demise.unit_abilities.window = {}
	var quiet := DeadlyDemise.begin(demise, [ark], func() -> int: return 5)
	check(str(quiet.get("error", "")).is_empty() and bool(quiet.get("complete", false)) and demise.get("pending_deadly_demise", {}).is_empty(), "Deadly Demise D3 does not trigger on a roll below 6: %s" % str(quiet))
	demise.units[ark].wounds = 0
	scripted_dice = [6, 1]
	var triggered := DeadlyDemise.begin(demise, [ark], Callable(self, "next_die"))
	var packet: Array = DeadlyDemise.choices(demise, 1)
	check(str(triggered.get("error", "")).is_empty() and not packet.is_empty() and int(demise.get("pending_deadly_demise", {}).get("packets", [{}])[0].get("remaining", 0)) == 1, "A Deadly Demise roll of 6 inflicts D3 mortal wounds within 6 inches: %s" % str(triggered))

	if failures == 0: print("Necron Doomsday Ark local checks: passed")
	else: print("Necron Doomsday Ark local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

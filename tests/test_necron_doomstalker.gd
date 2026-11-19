extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const DOOMSTALKER_ID := "40kdc:11e:necrons:canoptek-doomstalker"
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
	result[2].entries = [{"definition_id": DOOMSTALKER_ID, "models": 1, "copies": 1}]
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

func weapon_named(unit: Dictionary, weapon_name: String) -> Dictionary:
	for weapon: Dictionary in unit.get("ranged_weapons", []):
		for profile: Dictionary in weapon.get("profiles", {}).values():
			if str(profile.get("name", "")) == weapon_name: return weapon
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("canoptek-doomstalker")
	check(profile.get("source_datasheet_id", "") == "000002115" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Canoptek Doomstalker uses the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {1: 130} and profile.stats.wounds == 12 and profile.stats.invulnerable_target == 4 and profile.base_size_source_mm == 90, "Doomstalker keeps the 130-point profile, 4+ invulnerable save and 90 mm base")
	check(profile.supported_rule_ids == ["deadly-demise-d3", "reanimation-protocols", "sentinel-construct", "damaged-4"] and profile.unsupported_abilities.is_empty(), "Deadly Demise D3, Reanimation, Sentinel Construct and Damaged 4 are the local ability scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DOOMSTALKER_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 130, "The one-model Doomstalker admits at 130 points: %s" % str(admitted.get("error", "")))
	var copies := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": DOOMSTALKER_ID, "models": 1, "copies": 3}]})
	check(str(copies.get("error", "")).is_empty() and int(copies.get("total", -1)) == 390, "Three Doomstalkers use the 130-point copy price")
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DOOMSTALKER_ID, "models": 2, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "An unpriced Doomstalker size stays out of construction")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Doomstalker roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	prepare(state)
	var stalker_models: Array[int] = []
	var marines: Array[int] = []
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		if identity == "canoptek-doomstalker": stalker_models.append(model)
		elif identity == "intercessor-squad": marines.append(model)
	stalker_models.sort()
	marines.sort()
	check(stalker_models.size() == 1 and marines.size() == 5, "The Doomstalker and Marine squad materialize")
	if stalker_models.is_empty() or marines.is_empty():
		quit(1)
		return
	var stalker := stalker_models[0]
	var squad := int(state.units[stalker].squad)
	var marine_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, squad), "The one-model Doomstalker can activate Reanimation Protocols")
	var flayer := weapon_named(state.units[stalker], "Twin gauss flayer")
	var blaster := weapon_named(state.units[stalker], "Doomsday blaster")
	check(not flayer.is_empty() and not blaster.is_empty() and int(state.squads[squad].stats.get("invulnerable_target", 0)) == 4, "Both source ranged weapons and the 4+ invulnerable save materialize")
	if flayer.is_empty():
		quit(1)
		return
	var flayer_id := str(flayer.get("id", ""))
	place(state, [stalker], Vector2.ZERO)
	place(state, marines, Vector2(0, 18))
	state.units[stalker].wounds = 4
	var damaged := AttackPlan.prepare(state, squad, false, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], true)
	check(str(damaged.get("error", "")).is_empty() and int(damaged.batches[0].context.get("hit_modifier", 0)) == -1, "Damaged 4 subtracts 1 from the Hit roll at four wounds: %s" % str(damaged.get("error", "")))
	scripted_dice = [4]
	var missed := C.resolve_attack_plan(state, 2, stalker, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(missed.get("error", "")).is_empty() and int(missed.get("pools", [{}])[0].get("hits", -1)) == 0, "A Hit roll of 4 misses while Damaged 4 applies: %s" % str(missed.get("message", missed)))
	state.squads[squad].shot = false
	scripted_dice = [5, 6, 1]
	var wounded_shot := C.resolve_attack_plan(state, 2, stalker, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(wounded_shot.get("error", "")).is_empty() and int(wounded_shot.get("pools", [{}])[0].get("hits", 0)) == 1, "A Hit roll of 5 succeeds after the Damaged 4 penalty: %s" % str(wounded_shot.get("message", wounded_shot)))
	state.units[stalker].wounds = 5
	state.squads[squad].shot = false
	var healthy := AttackPlan.prepare(state, squad, false, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], true)
	check(str(healthy.get("error", "")).is_empty() and int(healthy.batches[0].context.get("hit_modifier", -9)) == 0, "Damaged 4 does not apply at five remaining wounds")

	state.phase = "movement"
	state.active = 1
	state.turn = 3
	state.cp[2] = 1
	state.unit_abilities.window = {"kind": "end", "owners": [2]}
	state.squads[squad].shot = false
	check(C.CoreReactions.cost_of(state, 2, squad, C.CoreReactions.OVERWATCH) == 1 and C.CoreReactions.error(state, 2, squad, C.CoreReactions.OVERWATCH).is_empty(), "Sentinel Construct uses the normal 1CP Fire Overwatch permission")
	state.stratagems.uses.append({"player": 2, "squad": marine_squad, "stratagem": "fire-overwatch", "phase_key": C.CoreReactions.phase_key(state), "turn": state.turn})
	check(not C.CoreReactions.error(state, 2, squad, C.CoreReactions.OVERWATCH).is_empty(), "Sentinel Construct does not grant an extra Fire Overwatch use")
	state.stratagems.uses = []
	var overwatch := C.CoreReactions.apply(state, 2, {"action": "core-stratagem", "model": -1, "target": squad, "value": C.CoreReactions.OVERWATCH})
	check(str(overwatch.get("error", "")).is_empty() and int(state.cp[2]) == 0, "Fire Overwatch spends 1CP: %s" % str(overwatch))
	var overwatch_plan := AttackPlan.prepare(state, squad, false, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], true)
	check(str(overwatch_plan.get("error", "")).is_empty() and int(overwatch_plan.batches[0].context.get("snap_hit_threshold", 0)) == 5 and str(overwatch_plan.batches[0].context.get("hit_reroll", "")) == "none", "Sentinel Construct hits on unmodified 5+ without hit re-rolls")
	scripted_dice = [4]
	var overwatch_miss := C.resolve_attack_plan(state, 2, stalker, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(overwatch_miss.get("error", "")).is_empty() and int(overwatch_miss.get("pools", [{}])[0].get("hits", -1)) == 0, "An Overwatch Hit roll of 4 misses")
	state.core_reactions.overwatch = {"player": 2, "squad": squad, "phase_key": C.CoreReactions.phase_key(state)}
	state.squads[squad].shot = false
	scripted_dice = [5, 6, 1]
	var overwatch_hit := C.resolve_attack_plan(state, 2, stalker, [{"model": stalker, "target": marine_squad, "amount": 1, "weapon": flayer_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(overwatch_hit.get("error", "")).is_empty() and int(overwatch_hit.get("pools", [{}])[0].get("hits", 0)) == 1 and int(overwatch_hit.get("pools", [{}])[0].get("snap_hit_threshold", 0)) == 5, "An Overwatch Hit roll of 5 scores a hit: %s" % str(overwatch_hit.get("message", overwatch_hit)))

	var demise := state.duplicate(true)
	var demise_stalker := stalker
	demise.units[demise_stalker].wounds = 0
	for marine: int in marines: demise.units[marine].wounds = 2
	place(demise, [demise_stalker], Vector2.ZERO)
	place(demise, marines, Vector2(6, 0))
	demise.unit_abilities.window = {}
	var quiet := DeadlyDemise.begin(demise, [demise_stalker], func() -> int: return 5)
	check(str(quiet.get("error", "")).is_empty() and bool(quiet.get("complete", false)) and demise.get("pending_deadly_demise", {}).is_empty(), "Deadly Demise D3 does not trigger on a roll below 6: %s" % str(quiet))
	demise.units[demise_stalker].wounds = 0
	scripted_dice = [6, 1]
	var triggered := DeadlyDemise.begin(demise, [demise_stalker], Callable(self, "next_die"))
	var packet: Array = DeadlyDemise.choices(demise, 1)
	check(str(triggered.get("error", "")).is_empty() and not packet.is_empty() and int(demise.get("pending_deadly_demise", {}).get("packets", [{}])[0].get("remaining", 0)) == 1, "A Deadly Demise roll of 6 inflicts D3 mortal wounds within 6 inches: %s" % str(triggered))

	if failures == 0: print("Necron Canoptek Doomstalker local checks: passed")
	else: print("Necron Canoptek Doomstalker local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

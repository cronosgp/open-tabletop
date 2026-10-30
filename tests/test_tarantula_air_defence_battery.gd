extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const R = preload("res://scripts/edition_11/core_reactions.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const SOURCE_ID := "tarantula-air-defence-battery"
const UNIT_ID := "40kdc:11e:adeptus-astartes:tarantula-air-defence-battery"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": UNIT_ID, "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:firestrike-servo-turrets", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func battle() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections())
	if state.has("error"): return state
	state.mission.stage = "battle"
	state.awakened_dynasty.pending = []
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].squad) if model >= 0 else -1

func prepare_overwatch(state: Dictionary) -> void:
	state.phase = "movement"
	state.active = 2
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	state.core_reactions.overwatch = {}
	for model: int in state.units:
		state.units[model].position = Vector2.ZERO if int(state.units[model].owner) == 1 else Vector2(8, 0)

func overwatch_state() -> Dictionary:
	var state := battle()
	if not state.has("error"): prepare_overwatch(state)
	return state

func save_overwatch(state: Dictionary, squad: int) -> Dictionary:
	return R.apply(state, 1, {"value": R.OVERWATCH, "target": squad, "model": -1})

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000000099", "Profile is tied to the local 11e Warhammer Legends sheet")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile retains the verified export and Legends-slice provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Tarantula-Air-Defence-Battery"), "The current source page and Legends status are explicit")
	check(profile.get("points_by_models", {}) == {1: 70} and profile.get("models", 0) == 1 and profile.get("stats", {}) == {"movement_inches": 0, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 0}, "The fixed model count, source points and characteristics are exact")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("not certified"), "The source footprint is kept separate from the documented 60 mm simulation proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "FRAME", "VEHICLE", "IMPERIUM"] and profile.get("default_loadout_by_role", {}).get("Tarantula Air Defence Battery", {}) == {"Armoured Hull": 1, "Tarantula Air Defence Missiles": 1}, "All exported keywords and the fixed loadout are retained")
	var missiles: Dictionary = profile.get("ranged", [])[0].profiles.standard
	var hull: Dictionary = profile.get("melee", [])[0].profiles.standard
	check(missiles.name == "Tarantula Air Defence Missiles" and missiles.range_inches == 48.0 and missiles.attacks == 3 and missiles.skill == 4 and missiles.strength == 7 and missiles.ap == -1 and missiles.damage == 1 and missiles.keywords == {"blast": 2, "anti-fly": 2}, "Missile range, characteristics, Blast 2 and Anti-Fly 2+ match the export")
	check(hull.name == "Armoured Hull" and hull.attacks == 1 and hull.skill == 4 and hull.strength == 4 and hull.ap == 0 and hull.damage == 1 and profile.get("options", {}).is_empty(), "The fixed Armoured Hull profile is exact and the sheet has no options")
	check(Army.SPECS.get(SOURCE_ID, {}).get("validation_status", "") == "tests_passed_local_targeted" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "The source-bounded profile is locally validated with the three-copy catalogue ceiling")
	check(Capabilities.supported("sentry-programming") and Capabilities.supported("deadly-demise-1"), "Sentry Programming and Deadly Demise 1 have supported capability records")
	check("sentry-programming" in C.UnitAbilities.RULES.get(SOURCE_ID, []) and "deadly-demise-1" in C.UnitAbilities.RULES.get(SOURCE_ID, []) and "combat-doctrines" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "All source abilities are registered on the datasheet identity")
	check(C.UnitAbilities.deadly_demise_value({"unit_abilities": {"implementation": C.UnitAbilities.ID}, "units": {1: {"definition_id": UNIT_ID}}}, 1) == "1", "The Tarantula resolves its source-listed Deadly Demise 1 value")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Tarantula enters the consolidated local catalog without network access")
	var unit := provider.lookup(UNIT_ID)
	check(unit.get("source_scope", "") == "Warhammer Legends" and unit.get("options", []) == [{"models": 1, "cost": 70}] and unit.get("scope", "").contains("competitive events require organiser approval"), "Catalog presents one fixed legal size with Legends/event conditions")
	var list := Roster.new_list("11e", "Space Marines", "incursion", 1000)
	list.entries.append(Roster.entry(unit, 0))
	check(Roster.validate(list).is_empty() and list.entries[0].get("source_scope", "") == "Warhammer Legends", "The roster accepts and preserves the Legends label")
	var repriced := Roster.reprice(list, provider.catalog)
	check(repriced.get("error", "") == "" and repriced.list.entries[0].get("source_scope", "") == "Warhammer Legends", "Repricing preserves the Legends identity on saved entries")
	for copies: int in [1, 2]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": copies}]})
		check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == copies * 70, "Roster admission prices %d Tarantula copy/copies correctly" % copies)
	var incursion_over_limit := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(not str(incursion_over_limit.get("error", "")).is_empty(), "Incursion admission enforces its two-copy datasheet limit")
	var strike_force_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var strike_force_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(strike_force_three.get("error", "").is_empty() and strike_force_three.get("total", -1) == 210 and not str(strike_force_four.get("error", "")).is_empty(), "Strike Force permits at most three copies of this non-Battleline datasheet")

	var state := battle()
	if state.has("error"):
		check(false, "Admitted Tarantula and Marine units build in a battle: " + str(state.error))
		quit(1)
		return
	var tarantula := model_for(state, 1, SOURCE_ID)
	var tarantula_squad := squad_for(state, 1, SOURCE_ID)
	var firestrike_squad := squad_for(state, 1, "firestrike-servo-turrets")
	var ordinary_squad := squad_for(state, 1, "intercessor-squad")
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(tarantula >= 0 and C.UnitAbilities.has(state, tarantula_squad, "sentry-programming") and C.UnitAbilities.has(state, tarantula_squad, "deadly-demise-1"), "The battle materializes both unique Tarantula ability effects")
	check(R.cost_of(state, 1, tarantula_squad, R.OVERWATCH) == 0 and R.cost_of(state, 1, ordinary_squad, R.OVERWATCH) == 1, "Sentry Programming makes only the Tarantula Overwatch use free")
	prepare_overwatch(state)
	var overwatch_choice := R.choices(state, 1).filter(func(choice: Dictionary) -> bool: return int(choice.get("target", -1)) == tarantula_squad and str(choice.get("value", "")) == R.OVERWATCH)
	check(not overwatch_choice.is_empty() and str(overwatch_choice[0].get("label", "")).contains("0 CP"), "The legal reaction choice shows the zero-CP cost")

	var tarantula_first := overwatch_state()
	var free_use := save_overwatch(tarantula_first, tarantula_squad)
	check(str(free_use.get("error", "")).is_empty() and int(tarantula_first.cp[1]) == 3, "Tarantula can use Fire Overwatch without spending CP")
	check(not R.error(tarantula_first, 1, tarantula_squad, R.OVERWATCH).is_empty(), "Sentry Programming cannot target its Tarantula twice in one phase")
	if str(free_use.get("error", "")).is_empty():
		tarantula_first.core_reactions.overwatch = {}
		tarantula_first.unit_abilities.window = {"kind": "end", "owners": [1]}
		var normal_after_sentry := R.error(tarantula_first, 1, ordinary_squad, R.OVERWATCH)
		check(normal_after_sentry.is_empty() and R.cost_of(tarantula_first, 1, ordinary_squad, R.OVERWATCH) == 1, "The Tarantula's free use leaves a normal unit's 1-CP use available")
		var normal_use := save_overwatch(tarantula_first, ordinary_squad)
		check(normal_use.get("error", "") == "" and int(tarantula_first.cp[1]) == 2, "A different unit can use its remaining Overwatch for 1 CP")

	var ordinary_first := overwatch_state()
	ordinary_first.stratagems.uses.append({"player": 1, "squad": ordinary_squad, "stratagem": R.OVERWATCH, "phase_key": R.phase_key(ordinary_first), "turn": ordinary_first.turn})
	check(R.error(ordinary_first, 1, tarantula_squad, R.OVERWATCH).is_empty(), "Tarantula can use its extra Overwatch after a normal unit has used it")
	var ordinary_then_sentry := save_overwatch(ordinary_first, tarantula_squad)
	check(ordinary_then_sentry.get("error", "") == "" and int(ordinary_first.cp[1]) == 3, "Its exception preserves the ordinary use and charges no CP")
	check(not R.error(ordinary_first, 1, firestrike_squad, R.OVERWATCH).is_empty(), "One ordinary use plus the Tarantula does not grant an extra use to an ordinary unit")

	var firestrike_first := overwatch_state()
	firestrike_first.stratagems.uses.append({"player": 1, "squad": firestrike_squad, "stratagem": R.OVERWATCH, "phase_key": R.phase_key(firestrike_first), "turn": firestrike_first.turn})
	check(R.error(firestrike_first, 1, tarantula_squad, R.OVERWATCH).is_empty(), "Tarantula's extra use remains available after Firestrike")
	check(save_overwatch(firestrike_first, tarantula_squad).get("error", "") == "", "Tarantula and Firestrike exception paths compose without spending CP")

	var sentry_first := overwatch_state()
	check(save_overwatch(sentry_first, tarantula_squad).get("error", "") == "", "Tarantula's first use succeeds before Firestrike")
	sentry_first.core_reactions.overwatch = {}
	sentry_first.unit_abilities.window = {"kind": "end", "owners": [1]}
	check(R.error(sentry_first, 1, firestrike_squad, R.OVERWATCH).is_empty(), "Tarantula's extra use does not consume Firestrike's extra use")

	var equipment := Equipment.select(state, tarantula, false, "tarantula-air-defence-missiles", "standard")
	check(equipment.get("error", "").is_empty() and equipment.stats.get("keywords", {}) == {"blast": 2, "anti-fly": 2}, "The missiles are selectable through the shared Equipment path")
	if enemy_squad >= 0 and tarantula >= 0:
		state.phase = "shooting"
		state.active = 1
		state.unit_abilities.window = {}
		state.units[tarantula].position = Vector2.ZERO
		for model: int in C.living(state, enemy_squad): state.units[model].position = Vector2(20, 0)
		var plan := C.AttackPlan.prepare(state, tarantula_squad, false, [{"model": tarantula, "target": enemy_squad, "amount": 1, "weapon": "tarantula-air-defence-missiles", "profile": "standard"}], true)
		check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1 and plan.batches[0].weapon.get("keywords", {}) == {"anti-fly": 2} and int(plan.batches[0].count) == 5 and int(plan.batches[0].context.attack_sources[0].bonus) == 2, "The missiles resolve through AttackPlan at range and apply Blast 2 against a five-model target")

	var demise := state.duplicate(true)
	for model: int in demise.units:
		demise.units[model].position = Vector2(-20, -20) if int(demise.units[model].owner) == 1 else Vector2(5, 0)
	demise.units[tarantula].position = Vector2.ZERO
	demise.units[tarantula].wounds = 0
	var enemy_model := model_for(demise, 2, "intercessor-squad")
	var wounds_before := int(demise.units[enemy_model].wounds)
	var explosion := C.DeadlyDemise.begin(demise, [tarantula], Callable(self, "roll_six"))
	var packet := C.DeadlyDemise.choices(demise, 2)
	var allocated := C.DeadlyDemise.allocate(demise, 2, packet[0], Callable()) if not packet.is_empty() else {"error": "No mortal-wound allocation was offered."}
	if explosion.get("error", "") != "" or explosion.get("complete", true) or allocated.get("error", "") != "" or int(demise.units[enemy_model].wounds) != wounds_before - 1:
		print("Tarantula Deadly Demise diagnostic: start=", explosion, " packets=", demise.get("pending_deadly_demise", {}), " choices=", packet, " allocation=", allocated, " wounds=", wounds_before, "->", demise.units[enemy_model].wounds)
	check(explosion.get("error", "") == "" and not explosion.get("complete", true) and allocated.get("error", "") == "" and int(demise.units[enemy_model].wounds) == wounds_before - 1, "Deadly Demise 1 resolves a 6 through mortal-wound allocation")

	provider.free()
	if failures > 0: quit(1)
	else: quit(0)

func roll_six() -> int:
	return 6

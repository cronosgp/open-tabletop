extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const HighMarshal = preload("res://scripts/edition_11/high_marshal_helbrecht.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "high-marshal-helbrecht"
const UNIT_ID := "40kdc:11e:adeptus-astartes:high-marshal-helbrecht"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, model_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func encounter() -> Dictionary:
	var state := fixture()
	if state.has("error"): return state
	var helbrecht := model_for(state, 1, UNIT)
	var bodyguard := model_for(state, 1, "intercessor-squad")
	if helbrecht < 0 or bodyguard < 0: return {"error": "Could not materialize Helbrecht and his Intercessor bodyguard."}
	var bodyguard_squad := int(state.units[bodyguard].squad)
	var attach_choice := option(state, 1, "attach", bodyguard_squad, helbrecht)
	var attached := PublicUnitCommand.submit(state, 1, attach_choice)
	if not str(attached.get("error", "")).is_empty(): return {"error": str(attached.error)}
	var helbrecht_squad := int(state.units[helbrecht].squad)
	var enemy_model := model_for(state, 2, "intercessor-squad")
	var enemy_squad := int(state.units[enemy_model].squad)
	for model: int in C.living(state, helbrecht_squad): state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, enemy_squad): state.units[model].position = Vector2(0.8, 0)
	state.phase = "fight"
	state.active = 1
	state.turn = 1
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.unit_abilities.phase_key = ""
	C.UnitActions.reconcile(state)
	return state

func resolve_roll(sequence: Array) -> Dictionary:
	var state := encounter()
	if state.has("error"): return state
	var helbrecht := model_for(state, 1, UNIT)
	var enemy_model := model_for(state, 2, "intercessor-squad")
	var enemy_squad := int(state.units[enemy_model].squad)
	var selected := option(state, 1, "high-marshal", enemy_squad, helbrecht)
	var rolls := {"values": sequence.duplicate()}
	var roller := func() -> int:
		return int(rolls.values.pop_front()) if not rolls.values.is_empty() else 1
	var result := HighMarshal.apply(state, 1, selected, roller)
	if not str(result.get("error", "")).is_empty(): return {"error": str(result.error)}
	return {"state": state, "record": state.get("last_high_marshal", {}), "result": result, "target": enemy_squad}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000162" and profile.get("source_datasheet_id") == "000002794" and profile.get("source_snapshot_id") == "20261021T130623Z", "Helbrecht cites the verified local Black Templars App export")
	check(profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Helbrecht records the parent and slice manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 125} and profile.get("models", 0) == 1 and profile.get("max_supported_copies", 0) == 1 and profile.get("base_size_source_mm", 0) == 60, "The 125-point Epic Hero uses one model, one supported copy and a 60 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4}, "Helbrecht's characteristics match the verified source")
	check(profile.get("keywords", []).has("EPIC HERO") and profile.get("keywords", []).has("CHAPTER MASTER") and profile.get("keywords", []).has("BLACK TEMPLARS"), "All key datasheet and faction keywords are present")
	var ferocity: Dictionary = profile.get("ranged", [])[0].profiles.standard
	check(ferocity.get("name", "") == "Ferocity" and ferocity.get("attacks", 0) == 2 and ferocity.get("strength", 0) == 5 and ferocity.get("keywords", {}).get("anti-infantry", 0) == 4 and ferocity.get("keywords", {}).get("devastating-wounds", false), "Ferocity matches its source profile and weapon abilities")
	var sword: Dictionary = profile.get("melee", [])[0].profiles
	check(sword.get("strike", {}).get("attacks", 0) == 6 and sword.get("strike", {}).get("strength", 0) == 9 and sword.get("sweep", {}).get("attacks", 0) == 12 and sword.get("sweep", {}).get("strength", 0) == 6, "Both Sword of the High Marshals profiles match the source")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 125, "The current construction and point catalogs admit Helbrecht")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 125}], "The consolidated local catalog exposes one Helbrecht at 125 points")
	var abilities: Array = AbilityCatalog.RULES.get(UNIT, [])
	check(abilities.has("leader") and abilities.has("combat-doctrines") and abilities.has("transhuman-strategist") and abilities.has("high-marshal") and abilities.has("crusade-of-wrath"), "All Helbrecht rules are registered")
	check(Registry.KNOWN.get("high-marshal", {}).get("supported", false) and Registry.KNOWN.get("crusade-of-wrath", {}).get("supported", false), "Both datasheet abilities have supported capability records")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "intercessor-squad", "crusader-squad", "sword-brethren-squad"], "All six source-listed Leader endpoints are registered")

	var state := fixture()
	if state.has("error"):
		check(false, "Current-catalog Black Templars fixture materializes: %s" % str(state.get("error", "")))
	else:
		var helbrecht := model_for(state, 1, UNIT)
		check(not option(state, 1, "warlord", -1, helbrecht).is_empty(), "Helbrecht is selectable as the army Warlord")
		state.unit_abilities.warlords = {}
		state.unit_abilities.warlords[1] = helbrecht
		state.first_player = 1
		state.active = 1
		state.round = 2
		state.cp[1] = 0
		state.unit_abilities.used.erase("warlord-cp:1")
		C.UnitActions.start_round(state)
		check(int(state.cp[1]) == 1, "Transhuman Strategist grants 1 CP at the start of the round when Helbrecht is Warlord")

	var wrath_state := encounter()
	if wrath_state.has("error"):
		check(false, "Helbrecht attached combat fixture materializes: %s" % str(wrath_state.get("error", "")))
	else:
		var bearer := model_for(wrath_state, 1, UNIT)
		var target_model := model_for(wrath_state, 2, "intercessor-squad")
		var target_squad := int(wrath_state.units[target_model].squad)
		var base_strike: Dictionary = Profiles.profile(UNIT).melee[0].profiles.strike
		var modified := C.UnitAbilities.weapon(wrath_state, bearer, target_squad, base_strike, true)
		check(int(modified.get("attacks", 0)) == 7 and int(modified.get("strength", 0)) == 10, "Crusade of Wrath adds +1 Attack and +1 Strength to Helbrecht's melee profile")
		check(C.UnitAbilities.melee_attack_count(wrath_state, bearer, base_strike) == 7, "The melee declaration path includes Crusade of Wrath's extra Attack")

	for case: Dictionary in [
		{"dice": [1], "expected": 0},
		{"dice": [2, 2], "expected": 1},
		{"dice": [5], "expected": 3},
		{"dice": [6, 4], "expected": 5}
	]:
		var resolved := resolve_roll(case.dice)
		check(not resolved.has("error"), "High Marshal deterministic roll case materializes and resolves")
		if not resolved.has("error"):
			check(int(resolved.record.get("remaining", -1)) == int(case.expected), "High Marshal D6 result %d produces the correct mortal-wound packet" % int(case.dice[0]))
			check(int(resolved.record.get("roll", {}).get("value", 0)) == int(case.dice[0]), "High Marshal stores the D6 used for its packet")

	var wound_state := encounter()
	if wound_state.has("error"):
		check(false, "High Marshal wound-allocation fixture materializes: %s" % str(wound_state.get("error", "")))
	else:
		var bearer := model_for(wound_state, 1, UNIT)
		var enemy_model := model_for(wound_state, 2, "intercessor-squad")
		var target := int(wound_state.units[enemy_model].squad)
		var selected := option(wound_state, 1, "high-marshal", target, bearer)
		var roll_source := {"values": [4]}
		var roller := func() -> int: return int(roll_source.values.pop_front())
		var invoked := PublicUnitCommand.submit(wound_state, 1, selected, Vector2.ZERO, roller)
		check(str(invoked.get("error", "")).is_empty() and wound_state.unit_abilities.window.get("kind", "") == HighMarshal.MORTAL_WINDOW, "The public choice opens a mortal-wound allocation for the opponent")
		check(C.UnitActions.choices(wound_state, 1).is_empty(), "Only the targeted opponent can make the mortal-wound allocation")
		var allocated := 0
		for _step in range(3):
			var choices := C.UnitActions.choices(wound_state, 2)
			var allocation: Dictionary = {}
			for candidate: Dictionary in choices:
				if candidate.get("action", "") == "mortal-allocate": allocation = candidate; break
			var result := PublicUnitCommand.submit(wound_state, 2, allocation)
			check(not allocation.is_empty() and str(result.get("error", "")).is_empty(), "The opponent allocates one High Marshal mortal wound through the public command boundary")
			if allocation.is_empty() or not str(result.get("error", "")).is_empty(): break
			allocated += 1
			if allocated == 1: check(C.DetachmentStratagems.mortal_wound_triggered(wound_state, target), "The High Marshal packet opens supported mortal-wound reactions")
		check(allocated == 3, "All three fixed mortal wounds are allocated")
		var resumed_owners: Array = wound_state.unit_abilities.window.get("owners", [])
		check(wound_state.unit_abilities.window.get("kind", "") == "start" and not resumed_owners.is_empty() and int(resumed_owners[0]) == 1, "After allocation, the original Fight-phase start window resumes")
		check(option(wound_state, 1, "high-marshal", target, bearer).is_empty(), "High Marshal cannot be selected a second time in the same Fight phase")

	if failures == 0: print("High Marshal Helbrecht local checks: passed")
	else: print("High Marshal Helbrecht local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

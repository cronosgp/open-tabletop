extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.owner) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		var alive: Array[int] = Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func by_action(options: Array, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty():
		return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": selected}, func() -> int: return 6)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": payload}, func() -> int: return 6)

func choose(state: Dictionary, player: int, action: String, target: int, model: int, value: String) -> Dictionary:
	var option := by_action(C.UnitActions.choices(state, player), action, target, model, value)
	if option.is_empty(): return {"error": "Missing choice: %s/%s" % [action, value]}
	return submit_projected_choice(state, player, option)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("blood-angels-captain")
	check(profile.get("name") == "Blood Angels Captain" and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000003831" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00" and profile.get("source_snapshot_id") == "20261021T130623Z", "Blood Angels Captain is keyed to the local Blood Angels 11e App export and fixed snapshot")
	check(profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5", "The profile records the verified parent and Blood Angels slice manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 90} and profile.get("models", 0) == 1 and profile.get("base_size_source_mm", 0) == 40, "One-model cost and 40 mm base match the verified export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Characteristics and saves match the verified datasheet")
	check(profile.get("keywords", []) == ["BLOOD ANGELS", "ADEPTUS ASTARTES", "TACTICUS", "IMPERIUM", "CHARACTER", "CAPTAIN", "INFANTRY", "EXPLOSIVES"] and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "Faction, unit keywords and base radius match the source profile")
	var default_weapons := Profiles.blood_angels_captain_weapons()
	check(profile.get("ranged", []) == default_weapons.get("ranged", []) and profile.get("melee", []) == default_weapons.get("melee", []), "Default equipment is the Heavy Bolt Pistol and Master-crafted Chainsword")
	check(Profiles.additional_weapon("blood-angels-captain", "ranged", "inferno-pistol").profiles.standard.keywords == {"close-quarters": true, "melta": 1} and Profiles.additional_weapon("blood-angels-captain", "melee", "relic-weapon").profiles.standard.attacks == 6, "Alternate Inferno Pistol and Relic Weapon profiles preserve their source traits")
	check(Profiles.blood_angels_captain_weapons("invalid", "power-fist").is_empty() and Profiles.blood_angels_captain_weapons("inferno-pistol", "invalid").is_empty(), "Profile builder rejects unsupported equipment values")
	check(Catalog.SPECS.get("blood-angels-captain", {}).get("current_reference", false) and Roster.POINTS.get("blood-angels-captain", {}).get("sizes", {}) == {1: 90}, "Blood Angels Captain is exposed through the fixed local catalog at 90 points")
	var expected_targets := ["assault-intercessor-squad", "company-heroes", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad"]
	var source_targets: Array = MarineLinks.targets("blood-angels-captain")
	source_targets.sort()
	check(source_targets == expected_targets, "Blood Angels Captain Leader endpoints exactly match the chapter datasheet")

	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry("blood-angels-captain"), entry("intercessor-squad", 5), entry("heavy-intercessor-squad", 5)]
	lists[2].entries = [entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false,
		"reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false,
		"marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}
	}, lists)
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Both players materialize from current local catalogs under Blood Angels chapter context: " + materialization_error)
	if not materialization_error.is_empty():
		print(materialization_error)
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var captain := find_model(state, 1, "blood-angels-captain")
	var captain_squad: int = state.units[captain].squad if captain >= 0 else -1
	var friendly_intercessors := find_squad(state, 1, "intercessor-squad")
	var friendly_heavies := find_squad(state, 1, "heavy-intercessor-squad")
	var enemy_intercessors := find_squad(state, 2, "intercessor-squad")
	check(captain >= 0 and captain_squad >= 0 and friendly_intercessors >= 0 and friendly_heavies >= 0 and enemy_intercessors >= 0, "Captain and both players' current-catalog units materialize")
	if captain < 0 or captain_squad < 0 or friendly_intercessors < 0 or friendly_heavies < 0 or enemy_intercessors < 0:
		quit(1)
		return
	check(C.UnitActions.attachment_allowed(state, captain, friendly_intercessors), "Captain can lead a source-listed Intercessor Squad")
	check(not C.UnitActions.attachment_allowed(state, captain, friendly_heavies), "Captain cannot lead an unlisted Heavy Intercessor Squad")
	for ability: String in ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist"]:
		check(C.UnitAbilities.has(state, captain_squad, ability), "Captain receives source-listed %s" % ability)
	var projected_choices := C.UnitActions.choices(state, 1)
	check(not by_action(projected_choices, "blood-angels-captain-ranged-loadout", captain_squad, captain, "inferno-pistol").is_empty(), "Inferno Pistol is offered as a public preparation choice")
	for package: String in ["power-fist", "relic-weapon"]:
		check(not by_action(projected_choices, "blood-angels-captain-melee-loadout", captain_squad, captain, package).is_empty(), "%s is offered as a public preparation choice" % package)
	var invalid_choice := {"action": "blood-angels-captain-ranged-loadout", "model": captain, "target": captain_squad, "value": "plasma-pistol"}
	var before_invalid := var_to_bytes(state)
	var rejected_invalid := C.UnitActions.apply(state, 1, invalid_choice, Vector2.ZERO, func() -> int: return 6)
	check(not str(rejected_invalid.get("error", "")).is_empty() and before_invalid == var_to_bytes(state), "Unsupported equipment is rejected without mutating the prepared army")

	var combinations: Array[Dictionary] = []
	for pistol: String in ["heavy-bolt-pistol", "inferno-pistol"]:
		for melee: String in ["master-crafted-chainsword", "power-fist", "relic-weapon"]:
			combinations.append({"pistol": pistol, "melee": melee})
	var weapon_failures: Array[String] = []
	for combination: Dictionary in combinations:
		var pistol: String = str(combination.pistol)
		var melee: String = str(combination.melee)
		var local_state: Dictionary = state.duplicate(true)
		if pistol != "heavy-bolt-pistol":
			var pistol_result := choose(local_state, 1, "blood-angels-captain-ranged-loadout", captain_squad, captain, pistol)
			check(str(pistol_result.get("error", "")).is_empty(), "Captain can choose %s" % pistol)
		if melee != "master-crafted-chainsword":
			var melee_result := choose(local_state, 1, "blood-angels-captain-melee-loadout", captain_squad, captain, melee)
			check(str(melee_result.get("error", "")).is_empty(), "Captain can choose %s" % melee)
		var package := Profiles.blood_angels_captain_weapons(pistol, melee)
		check(not package.is_empty() and local_state.units[captain].ranged_weapons == package.ranged and local_state.units[captain].melee_weapons == package.melee, "Public choices equip the exact %s / %s combination" % [pistol, melee])
		for model: int in local_state.units:
			local_state.units[model].on_battlefield = true
			local_state.units[model].position = Vector2(-14, 14) if int(local_state.units[model].owner) == 1 else Vector2(14, 14)
		weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(local_state, package, captain, enemy_intercessors))
	check(weapon_failures.is_empty(), "Every one of the six legal packages passes Equipment and AttackPlan: %s" % str(weapon_failures))

	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-14, 14) if int(state.units[model].owner) == 1 else Vector2(14, 14)
	state.phase = "command"
	state.active = 1
	state.unit_abilities.warlords = {1: captain}
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants one CP when the Blood Angels Captain is Warlord")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist cannot grant Warlord CP twice in the same round")
	state.combat_doctrines.selected_turn[1] = state.turn
	var acumen := by_action(C.UnitActions.choices(state, 1), "acumen", captain_squad, captain, "assault")
	var acumen_result := submit_projected_choice(state, 1, acumen) if not acumen.is_empty() else {"error": "missing Strategic Acumen option"}
	check(not acumen.is_empty() and str(acumen_result.get("error", "")).is_empty() and C.Doctrines.active_for(state, captain_squad) == "assault", "Strategic Acumen selects a Combat Doctrine for this Captain's unit")
	state.phase = "fight"
	state.active = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = []
	state.squads[captain_squad].charged = true
	state.squads[captain_squad].fought = false
	state.squads[captain_squad].fight_eligible = true
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var finest := by_action(C.UnitActions.choices(state, 1), "finest", captain_squad, captain)
	var finest_result := submit_projected_choice(state, 1, finest) if not finest.is_empty() else {"error": "missing Finest Hour option"}
	var finest_profile: Dictionary = Equipment.select(state, captain, true).get("stats", {})
	check(not finest.is_empty() and str(finest_result.get("error", "")).is_empty() and int(finest_profile.get("attacks", -1)) == 10 and finest_profile.get("keywords", {}).get("devastating-wounds", false), "Finest Hour adds three attacks and Devastating Wounds to the Chainsword for this Fight activation (choice=%s, result=%s, profile=%s, phase=%s, actor=%s, queue=%s)" % [str(finest), str(finest_result), str(finest_profile), str(state.phase), str(state.fight_actor), str(C.FightQueue.choices(state, 1))])
	check(by_action(C.UnitActions.choices(state, 1), "finest", captain_squad, captain).is_empty(), "Finest Hour remains once per battle for the Blood Angels Captain")

	print("Blood Angels Captain source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

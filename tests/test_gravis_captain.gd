extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.owner) == owner and C.UnitAbilities.identity(unit) == identity:
			return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner:
			continue
		var living: Array[int] = Geometry.alive(state, squad)
		if not living.is_empty() and C.UnitAbilities.identity(state.units[living[0]]) == identity:
			return squad
	return -1

func by_action(options: Array, action: String, target: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload := selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty():
			return {"error": "Selected choice is not in the current UnitActions projection."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": payload}, func() -> int: return 6)

func choose(state: Dictionary, player: int, action: String, target: int, model: int, value: String) -> Dictionary:
	var option := by_action(C.UnitActions.choices(state, player), action, target, model, value)
	if option.is_empty():
		return {"error": "Missing choice: %s/%s" % [action, value]}
	return submit_choice(state, player, option)

func three() -> int:
	return 3

func run() -> void:
	var profile := Profiles.profile("captain-in-gravis-armour")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001172" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Captain in Gravis Armour uses the pinned Wahapedia 11e shared-book sheet")
	check(profile.get("points_by_models", {}) == {1: 90} and profile.get("models") == 1 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "The one-model 90-point profile uses its 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Characteristics match the source")
	check(profile.get("keywords", []) == ["INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"], "Keywords match the source without chapter-only tags")
	check(Roster.POINTS.get("captain-in-gravis-armour", {}).get("sizes", {}) == {1: 90}, "Roster admission uses the source-listed 90-point cost")
	check(Catalog.SPECS.get("captain-in-gravis-armour", {}).get("current_reference", false), "Captain in Gravis Armour is selectable from the current local catalog")

	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-in-gravis-armour")]})
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-in-gravis-armour", 1, 3)]})
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-in-gravis-armour", 1, 4)]})
	var incursion_three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-in-gravis-armour", 1, 3)]})
	check(one_copy.get("error", "").is_empty() and int(one_copy.get("total", -1)) == 90 and three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 270 and not str(four_copies.get("error", "")).is_empty() and not str(incursion_three.get("error", "")).is_empty(), "Catalog applies the Incursion and Strike Force copy ceilings and source cost")

	var source_targets: Array = MarineLinks.TARGETS.get("captain-in-gravis-armour", []).duplicate()
	var expected_targets := ["aggressor-squad", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles", "heavy-intercessor-squad"]
	source_targets.sort()
	expected_targets.sort()
	check(source_targets == expected_targets, "Leader map has exactly the four shared-book source targets")

	var lists := F.current_marine_selections()
	lists[1].entries = [
		entry("captain-in-gravis-armour"),
		entry("aggressor-squad", 3),
		entry("eradicator-squad-with-heavy-bolters", 3),
		entry("eradicator-squad-with-melta-rifles", 3),
		entry("heavy-intercessor-squad", 5),
		entry("intercessor-squad", 5)
	]
	lists[2].entries = [entry("assault-intercessor-squad", 5), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Both sides materialize from the current local Space Marines catalogs")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var captain := find_model(state, 1, "captain-in-gravis-armour")
	var captain_squad := find_squad(state, 1, "captain-in-gravis-armour")
	var enemy_squad := find_squad(state, 2, "assault-intercessor-squad")
	var heavy_squad := find_squad(state, 1, "heavy-intercessor-squad")
	check(captain >= 0 and captain_squad >= 0 and enemy_squad >= 0 and heavy_squad >= 0, "Captain and both current-catalog rosters materialize with source-listed units")
	if captain < 0 or captain_squad < 0 or enemy_squad < 0 or heavy_squad < 0:
		quit(1)
		return

	for identity: String in expected_targets:
		var target_squad := find_squad(state, 1, identity)
		check(target_squad >= 0 and C.UnitActions.attachment_allowed(state, captain, target_squad), "Captain can lead source-listed %s" % identity)
	check(not C.UnitActions.attachment_allowed(state, captain, find_squad(state, 1, "intercessor-squad")), "Captain cannot lead an unlisted ordinary Intercessor Squad")
	for ability: String in ["leader", "strategic-acumen", "transhuman-strategist", "refuse-to-yield"]:
		check(C.UnitAbilities.has(state, captain_squad, ability), "Captain has source-listed %s" % ability)
	check(not C.UnitAbilities.has(state, captain_squad, "finest-hour") and not C.UnitAbilities.has(state, captain_squad, "deep-strike"), "Gravis Captain does not inherit unrelated Captain abilities")

	var probe := {"name": "Refuse to Yield probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 3, "range_inches": 24, "keywords": {}}
	state.phase = "shooting"
	state.active = 2
	var resolved := C.AttackPlan.resolve(state, {"targets": [captain_squad], "batches": [{"target": captain_squad, "weapon": probe, "context": {"weapon_count": 1}}]}, three, false)
	check(resolved.get("error", "").is_empty() and int(resolved.get("units", {}).get(captain, {}).get("wounds", -1)) == 4 and int(resolved.get("damage", -1)) == 2, "Attack allocation applies Refuse to Yield to this model and reduces Damage by one")
	check(C.UnitAbilities.damage(state, captain, 3) == 2 and C.UnitAbilities.damage(state, captain, 1) == 1 and C.UnitAbilities.damage(state, captain, 0) == 0, "Refuse to Yield retains the minimum-one Damage boundary")
	var historical_state: Dictionary = state.duplicate(true)
	historical_state.unit_abilities.implementation = "historical"
	check(C.UnitAbilities.damage(historical_state, captain, 3) == 3, "Current Refuse to Yield does not leak into the historical implementation")

	var attached_state: Dictionary = state.duplicate(true)
	C.UnitActions.attach(attached_state, captain, heavy_squad)
	var bodyguard := -1
	for model: int in Geometry.alive(attached_state, heavy_squad):
		if str(attached_state.units[model].get("attachment_role", "")) == "bodyguard":
			bodyguard = model
			break
	check(attached_state.units[captain].attachment_role == "leader" and C.UnitAbilities.damage(attached_state, captain, 3) == 2 and C.UnitAbilities.damage(attached_state, bodyguard, 3) == 3, "Refuse to Yield protects only the Captain after attachment")

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var before_wrong_loadout_owner := var_to_bytes(state)
	var initial_loadout := by_action(C.UnitActions.choices(state, 1), "gravis-captain-loadout", captain_squad, captain, "blade")
	var wrong_loadout_owner := submit_choice(state, 2, initial_loadout)
	check(not initial_loadout.is_empty() and not str(wrong_loadout_owner.get("error", "")).is_empty() and before_wrong_loadout_owner == var_to_bytes(state), "Opponent cannot change the Gravis Captain's loadout or mutate state")

	var weapon_failures: Array[String] = []
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-14, 14) if int(state.units[model].owner) == 1 else Vector2(14, 14)
	var default_package := Profiles.gravis_captain_weapons("rifle")
	weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(state, default_package, captain, enemy_squad))
	var modes := ["blade", "chainsword", "fist"]
	for mode: String in modes:
		var choice := by_action(C.UnitActions.choices(state, 1), "gravis-captain-loadout", captain_squad, captain, mode)
		var result := submit_choice(state, 1, choice) if not choice.is_empty() else {"error": "missing loadout choice"}
		var expected := Profiles.gravis_captain_weapons(mode)
		check(not choice.is_empty() and str(result.get("error", "")).is_empty() and state.units[captain].ranged_weapons == expected.ranged and state.units[captain].melee_weapons == expected.melee, "Public preparation choice equips the exact %s package" % mode)
		weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(state, expected, captain, enemy_squad))
		var prior_phase := str(state.phase)
		var prior_captain_position: Vector2 = state.units[captain].position
		var prior_enemy_positions: Dictionary = {}
		for model: int in Geometry.alive(state, enemy_squad):
			prior_enemy_positions[model] = state.units[model].position
			state.units[model].position = Vector2(1.75, 0.0)
		state.units[captain].position = Vector2.ZERO
		state.phase = "fight"
		var melee_plan := C.AttackPlan.single_target(state, captain_squad, enemy_squad, true)
		var relic_attacks: int = {"blade": 2, "chainsword": 3, "fist": 1}[mode]
		check(melee_plan.size() == 2 and int(melee_plan[0].get("amount", -1)) == 5 and int(melee_plan[1].get("amount", -1)) == relic_attacks, "%s retains the gauntlet's ordinary attacks and adds its Extra Attacks relic" % mode)
		state.phase = prior_phase
		state.units[captain].position = prior_captain_position
		for model: int in prior_enemy_positions:
			state.units[model].position = prior_enemy_positions[model]
	check(weapon_failures.is_empty(), "All fixed and replacement weapon profiles pass Equipment and AttackPlan: %s" % str(weapon_failures))
	var restore := by_action(C.UnitActions.choices(state, 1), "gravis-captain-loadout", captain_squad, captain, "rifle")
	var restore_result := submit_choice(state, 1, restore) if not restore.is_empty() else {"error": "missing restore choice"}
	check(not restore.is_empty() and str(restore_result.get("error", "")).is_empty() and state.units[captain].ranged_weapons == profile.ranged and state.units[captain].melee_weapons == profile.melee, "Rifle and power weapon can be restored after other loadout choices")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	var acumen := by_action(C.UnitActions.choices(state, 1), "acumen", captain_squad, captain, "assault")
	var before_wrong_acumen_owner := var_to_bytes(state)
	var wrong_acumen_owner := submit_choice(state, 2, acumen) if not acumen.is_empty() else {"error": "choice missing"}
	check(not acumen.is_empty() and not str(wrong_acumen_owner.get("error", "")).is_empty() and before_wrong_acumen_owner == var_to_bytes(state), "Opponent cannot use Strategic Acumen or mutate the Captain's choice")
	var acumen_result := submit_choice(state, 1, acumen) if not acumen.is_empty() else {"error": "choice missing"}
	check(not acumen.is_empty() and str(acumen_result.get("error", "")).is_empty() and C.UnitAbilities.doctrine(state, captain_squad) == "assault", "Strategic Acumen activates the selected doctrine for the Captain's unit")
	check(by_action(C.UnitActions.choices(state, 1), "acumen", captain_squad, captain, "tactical").is_empty(), "Strategic Acumen is used once in the current Command phase")
	state.active = 2
	C.Doctrines.start_command(state)
	C.UnitAbilities.start_command(state)
	check(C.UnitAbilities.doctrine(state, captain_squad) == "assault", "Strategic Acumen persists through the opponent's Command phase")
	state.active = 1
	C.Doctrines.start_command(state)
	C.UnitAbilities.start_command(state)
	check(C.UnitAbilities.doctrine(state, captain_squad).is_empty(), "Strategic Acumen expires at the start of the next own Command phase")

	state.unit_abilities.warlords = {1: captain}
	state.round = 1
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants the Warlord's once-per-round CP")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist cannot grant that Warlord CP twice in one battle round")

	print("Captain in Gravis Armour source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

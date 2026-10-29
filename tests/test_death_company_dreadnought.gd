extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const DCD = preload("res://scripts/edition_11/death_company_dreadnought.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const DCD_ID := "40kdc:11e:adeptus-astartes:death-company-dreadnought"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	var model := find_model(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func source_weapon_matches(weapon: Dictionary, range_inches: float, attacks: int, skill: int, strength: int, ap: int, damage: Variant, keywords: Dictionary) -> bool:
	var profile: Dictionary = weapon.get("profiles", {}).get("standard", {})
	return profile.get("range_inches", -1.0) == range_inches and profile.get("attacks", -1) == attacks and profile.get("skill", -1) == skill and profile.get("strength", -1) == strength and profile.get("ap", 99) == ap and profile.get("damage", null) == damage and profile.get("keywords", {}) == keywords

func choose_loadout(state: Dictionary, player: int, model: int, category: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "death-company-dreadnought-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == category and str(option.get("value", "")) == value:
			return PublicUnitCommand.submit(state, player, option)
	return {"error": "Missing projected Death Company Dreadnought choice %d/%s." % [category, value]}

func find_action(state: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action_id and (target < 0 or int(option.get("target", -1)) == target) and (model < 0 or int(option.get("model", -1)) == model): return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("death-company-dreadnought")
	check(profile.get("name") == "Death Company Dreadnought" and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000166" and profile.get("source_role") == "Walker", "Profile maps to the current Blood Angels datasheet identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5", "Profile records the verified local export snapshot and hashes")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("third_plus_points_by_models", {}) == {1: 185} and profile.get("max_supported_copies") == 3 and profile.get("models") == 1 and profile.get("base_size_source_mm") == 90, "Source composition, copy tiers and base size are retained")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.get("damaged_threshold") == 4, "Characteristics and Damaged 4 match the local export")
	check(profile.get("keywords", []) == ["BLOOD ANGELS", "ADEPTUS ASTARTES", "DEATH COMPANY", "IMPERIUM", "WALKER", "VEHICLE", "DREADNOUGHT"], "All exported faction and unit keywords are preserved")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["blood-fist-bolt-rifles", "twin-heavy-bolter-death-company-dreadnought", "twin-icarus-ironhail-heavy-stubber-death-company-dreadnought"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["blood-fists"], "Default weapon package matches the sheet")
	check(source_weapon_matches(profile.ranged[0], 24.0, 4, 3, 5, -1, 1, {"twin-linked": true}), "Blood Fist Bolt Rifles retain their full source profile")
	var default_heavy: Dictionary = profile.ranged[1].profiles.standard
	var stubber: Dictionary = profile.ranged[2].profiles.standard
	check(source_weapon_matches(profile.ranged[1], 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "twin-linked": true}) and not default_heavy.get("keywords", {}).has("rapid-fire"), "Twin Heavy Bolter retains its full source profile without Rapid Fire")
	check(source_weapon_matches(profile.ranged[2], 36.0, 3, 3, 4, -1, 1, {"anti-fly": 3, "rapid-fire": 3, "twin-linked": true}) and stubber.get("keywords", {}).size() == 3, "Twin Icarus Ironhail Heavy Stubber retains its full source profile")
	check(source_weapon_matches(profile.melee[0], 0.0, 6, 3, 12, -3, "D3+3", {"twin-linked": true}), "Blood Fists retain their full source profile")
	var multi_melta_profile: Dictionary = profile.additional_weapon_profiles.ranged[0]
	check(source_weapon_matches(multi_melta_profile, 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3, "twin-linked": true}), "Twin Multi-melta retains its full source profile")
	var talons: Dictionary = profile.additional_weapon_profiles.melee[0].profiles.standard
	var talons_weapon: Dictionary = profile.additional_weapon_profiles.melee[0]
	check(source_weapon_matches(talons_weapon, 0.0, 8, 3, 10, -2, 2, {"cleave": 2, "sustained-hits": 1, "twin-linked": true}) and talons.get("target_restricted_traits", {}).get("sustained-hits", []) == ["MONSTER", "VEHICLE"], "Blood Talons retain their source profile and restrict Sustained Hits against MONSTER/VEHICLE targets")
	check(Catalog.SPECS.get("death-company-dreadnought", {}).get("current_reference", false) and Roster.POINTS.get("death-company-dreadnought", {}).get("sizes", {}) == {1: 165} and Roster.POINTS.get("death-company-dreadnought", {}).get("third_plus_sizes", {}) == {1: 185}, "Current catalog and roster admission use sourced points")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DCD_ID, "models": 1, "copies": 3}]})
	var four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DCD_ID, "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 515 and not four.get("error", "").is_empty(), "Roster construction applies 165/165/185 points and rejects a fourth copy")
	check(AbilityCatalog.RULES.get("death-company-dreadnought", []) == ["damaged-4", "deadly-demise-d3", "combat-doctrines", "feel-no-pain-6", "black-rage", "driven-by-fury"] and Capabilities.supported("black-rage") and Capabilities.supported("driven-by-fury"), "The datasheet abilities are registered in their local support scopes")

	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry("death-company-dreadnought"), entry("captain"), entry("chaplain")]
	lists[2].entries = [entry("captain")]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, lists)
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Blood Angels roster materializes from the local catalog: " + materialization_error)
	if not materialization_error.is_empty():
		quit(1)
		return
	var model := find_model(state, 1, "death-company-dreadnought")
	var squad := find_squad(state, 1, "death-company-dreadnought")
	var captain := find_model(state, 1, "captain")
	var chaplain := find_model(state, 1, "chaplain")
	var enemy := find_model(state, 2, "captain")
	var enemy_squad := find_squad(state, 2, "captain")
	check(model >= 0 and squad >= 0 and captain >= 0 and chaplain >= 0 and enemy >= 0, "Dreadnought and both support model identities materialize")
	if model < 0 or squad < 0 or captain < 0 or chaplain < 0 or enemy < 0:
		quit(1)
		return

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = []
	var initial_points := int(state.training_points.get(1, 0))
	var initial_choices: Array = C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "death-company-dreadnought-loadout")
	check(initial_choices.size() == 2, "Preparation exposes the two optional Dreadnought weapon packages")
	var melta_choice := choose_loadout(state, 1, model, 0, "twin-multi-melta")
	var talons_choice := choose_loadout(state, 1, model, 1, "blood-talons")
	check(melta_choice.get("error", "").is_empty() and talons_choice.get("error", "").is_empty(), "Both source-listed package replacements apply through the public setup command")
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["twin-multi-melta-death-company-dreadnought", "twin-icarus-ironhail-heavy-stubber-death-company-dreadnought"] and state.units[model].melee_weapons[0].get("id", "") == "blood-talons", "Blood Talons replace both Blood Fist Bolt Rifles and Blood Fists while the Twin Multi-melta replaces the Twin Heavy Bolter")
	var talon_weapon: Dictionary = state.units[model].melee_weapons[0].profiles.standard
	var infantry_traits := C.UnitAbilities.weapon(state, model, enemy_squad, talon_weapon, true)
	state.units[enemy].keywords = ["MONSTER"]
	var monster_traits := C.UnitAbilities.weapon(state, model, enemy_squad, talon_weapon, true)
	check(infantry_traits.get("keywords", {}).get("sustained-hits", 0) == 1 and not monster_traits.get("keywords", {}).has("sustained-hits"), "Blood Talons retain Sustained Hits against ordinary targets and lose it against Monsters")
	state.units[enemy].keywords = ["CHARACTER", "INFANTRY", "IMPERIUM", "ADEPTUS ASTARTES"]
	var invalid_before := var_to_bytes(state.units[model])
	var invalid_choice := C.UnitActions.apply(state, 1, {"action": "death-company-dreadnought-loadout", "model": model, "target": 1, "value": "unsupported-claws"}, Vector2.ZERO, func() -> int: return 1)
	check(not str(invalid_choice.get("error", "")).is_empty() and var_to_bytes(state.units[model]) == invalid_before, "Unknown equipment choices are rejected without mutating the unit")
	var fist_choice := choose_loadout(state, 1, model, 1, "blood-fists")
	var bolter_choice := choose_loadout(state, 1, model, 0, "twin-heavy-bolter")
	check(fist_choice.get("error", "").is_empty() and bolter_choice.get("error", "").is_empty() and state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["blood-fist-bolt-rifles", "twin-heavy-bolter-death-company-dreadnought", "twin-icarus-ironhail-heavy-stubber-death-company-dreadnought"] and state.units[model].melee_weapons[0].get("id", "") == "blood-fists", "Switching back restores the complete datasheet default package")
	check(int(state.training_points.get(1, 0)) == initial_points, "Optional equipment does not change points")
	check(UnitPrevention.grants(state, squad) == [{"target": 6, "against": "any"}], "The unit receives its local Feel No Pain 6+ grant")
	check(C.UnitAbilities.deadly_demise_value(state, model) == "D3" and C.UnitAbilities.damaged_attack_penalty(state, model) == 0, "Deadly Demise D3 and the undamaged threshold are available")
	state.units[model].wounds = 4
	check(C.UnitAbilities.damaged_attack_penalty(state, model) == -1, "Damaged 4 applies at four remaining wounds")
	state.units[model].wounds = int(state.units[model].max_wounds)

	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "movement"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.resolution_frames = []
	state.stratagems.pending = {}
	for member: int in state.units:
		state.units[member].on_battlefield = false
		state.units[member].position = Vector2(12, 12)
	state.units[model].on_battlefield = true
	state.units[model].position = Vector2(-10, 8)
	state.units[captain].on_battlefield = true
	state.units[captain].position = Vector2(-6, 8)
	state.units[chaplain].on_battlefield = true
	state.units[chaplain].position = Vector2(-2, 8)
	state.units[enemy].on_battlefield = true
	state.units[enemy].position = Vector2(-7, 8)
	check(not C.UnitAbilities.black_rage_restricted(state, squad) and C.Morale.objective_control(state, model) == 4, "Black Rage leaves Fall Back and OC unrestricted when both supporting ranges are met")
	state.units[chaplain].position = Vector2(10, 8)
	check(C.UnitAbilities.black_rage_restricted(state, squad) and C.Morale.objective_control(state, model) == 0, "Missing Chaplain support sets the Dreadnought's OC to zero")
	state.units[chaplain].position = Vector2(2, 8)
	state.units[captain].position = Vector2(10, 8)
	check(C.UnitAbilities.black_rage_restricted(state, squad), "Missing a Blood Angels Character within six inches independently triggers Black Rage")
	state.units[captain].position = Vector2(-6, 8)
	state.units[enemy].position = Vector2(-7, 8)
	var fall_back_allowed := C.movement_choice_error_after_command(state, 1, model, "ordered_retreat", "")
	check(fall_back_allowed.is_empty(), "The engaged Dreadnought can Fall Back when both support ranges are satisfied")
	state.units[chaplain].position = Vector2(10, 8)
	var fall_back_blocked := C.movement_choice_error_after_command(state, 1, model, "ordered_retreat", "")
	check(fall_back_blocked.contains("Black Rage"), "The standard Fall Back validation blocks the move when either support range is missing")
	state.units[chaplain].position = Vector2(-2, 8)
	state.units[model].position = Vector2(-10, 8)
	state.units[enemy].position = Vector2(-5, 8)
	state.units[captain].on_battlefield = false
	state.units[chaplain].on_battlefield = false
	state.phase = "shooting"
	state.active = 2
	state.squads[squad].moved = false
	state.units[model].moved = false
	state.units[enemy].position = Vector2(-7, 8)
	var melee_plan := C.AttackPlan.prepare(state, squad, true, [{"model": model, "target": enemy_squad, "amount": 6, "weapon": "blood-fists", "profile": "standard"}], true)
	check(str(melee_plan.get("error", "")).is_empty() and melee_plan.get("batches", []).size() == 1 and melee_plan.batches[0].context.get("hit_reroll", "") == "ones", "Black Rage grants melee Hit rerolls of 1 through AttackPlan")
	state.units[enemy].position = Vector2(-5, 8)
	state.unit_abilities.window = {}
	DCD.open_after_enemy_shot(state, enemy_squad, [{"target_squad": squad, "hits": 0}])
	check(state.unit_abilities.window.is_empty(), "Driven by Fury does not trigger when the enemy attack scored no hits")
	state.squads[squad].battle_shocked = true
	DCD.open_after_enemy_shot(state, enemy_squad, [{"target_squad": squad, "hits": 1}])
	check(state.unit_abilities.window.is_empty(), "Driven by Fury does not trigger while the Dreadnought is Battle-shocked")
	state.squads[squad].battle_shocked = false
	state.squads[squad].moved = true
	DCD.open_after_enemy_shot(state, enemy_squad, [{"target_squad": squad, "hits": 1}])
	check(state.unit_abilities.window.is_empty(), "Driven by Fury does not trigger after the Dreadnought already moved this phase")
	state.squads[squad].moved = false
	state.units[enemy].position = Vector2(-7, 8)
	DCD.open_after_enemy_shot(state, enemy_squad, [{"target_squad": squad, "hits": 1}])
	check(state.unit_abilities.window.is_empty(), "Driven by Fury does not trigger when the Dreadnought is already engaged")
	state.units[enemy].position = Vector2(-5, 8)
	var shooter_weapons: Array = state.units[enemy].get("ranged_weapons", [])
	var shot_result: Dictionary = {"error": "The opponent Captain has no local ranged weapon to test the post-shot hook."}
	if not shooter_weapons.is_empty():
		var weapon: Dictionary = shooter_weapons[0]
		var profile_names: Array = weapon.get("profiles", {}).keys()
		if not profile_names.is_empty():
			var profile_name := str(profile_names[0])
			var profile_data: Dictionary = weapon.profiles[profile_name]
			var attacks: Variant = profile_data.get("attacks", 1)
			var attack_count := int(attacks) if attacks is int else 1
			shot_result = C.resolve_attack_plan(state, 2, enemy, [{"model": enemy, "target": squad, "amount": attack_count, "weapon": str(weapon.get("id", "")), "profile": profile_name}], int(state.revision), false, true, six)
	check(str(shot_result.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == DCD.WINDOW and state.unit_abilities.window.get("owners", []) == [1], "A resolved enemy shooting attack with hits opens the defending player's Driven by Fury window: " + str(shot_result.get("error", "")))
	check(not PhaseCloseGate.close_request_error(state, 2, int(state.revision)).is_empty(), "The Shooting phase cannot close while Driven by Fury is pending")
	var use := find_action(state, 1, "death-company-fury-use", squad)
	check(not use.is_empty(), "The defender receives the optional Surge move choice")
	if not use.is_empty():
		var rolled := PublicUnitCommand.submit(state, 1, use, Vector2.ZERO, func() -> int: return 2)
		check(str(rolled.get("error", "")).is_empty() and state.unit_abilities.window.get("distance", 0) == 3, "Driven by Fury rolls a host-owned D6 and adds one inch")
		var target_choice := find_action(state, 1, "death-company-fury-target", squad)
		check(int(target_choice.get("enemy_target", -1)) == enemy_squad, "The reaction selects the closest enemy Surge target")
		if not target_choice.is_empty():
			var selected_target := PublicUnitCommand.submit(state, 1, target_choice)
			check(str(selected_target.get("error", "")).is_empty(), "The closest target selection advances to placement")
			var place := find_action(state, 1, "death-company-fury-place", squad, model)
			var placement_result := PublicUnitCommand.submit(state, 1, place, Vector2(-8, 8)) if not place.is_empty() else {"error": "Missing placement choice."}
			check(str(placement_result.get("error", "")).is_empty(), "A legal closer destination can be previewed")
			var confirm := find_action(state, 1, "death-company-fury-confirm", squad)
			var confirm_result := PublicUnitCommand.submit(state, 1, confirm) if not confirm.is_empty() else {"error": "Missing confirmation choice."}
			check(str(confirm_result.get("error", "")).is_empty() and state.squads[squad].get("move_type", "") == "surge" and state.units[model].moved, "Confirming the Surge records the move and its per-phase movement state")
			check(C.ResolutionFrames.current(state).is_empty(), "Completing Driven by Fury closes its suspended attack continuation")

	print("Death Company Dreadnought source-bounded checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

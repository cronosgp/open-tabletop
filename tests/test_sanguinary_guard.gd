extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const GUARD := "sanguinary-guard"
const JUMP_CAPTAIN := "captain-with-jump-pack"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func models_for(state: Dictionary, squad: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity:
			result.append(model)
	return result

func squad_for_size(state: Dictionary, owner: int, identity: String, size: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if models_for(state, squad, identity).size() == size: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return model
	return -1

func find_choice(state: Dictionary, player: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func submit_choice(state: Dictionary, player: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	var option := find_choice(state, player, action, squad, model, value)
	if option.is_empty(): return {"error": "Missing projected Sanguinary Guard choice %s/%s for model %d." % [action, value, model]}
	return PublicUnitCommand.submit(state, player, option)

func fresh_state() -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry(GUARD, 6), entry(GUARD, 3), entry(JUMP_CAPTAIN)]
	lists[2].entries = [entry(GUARD, 3)]
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, lists)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(GUARD)
	var snapshot_hash := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
	var slice_hash := "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5"
	check(profile.get("name") == "Sanguinary Guard" and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000165", "Sanguinary Guard maps to its exact Blood Angels App datasheet identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00" and profile.get("source_manifest_sha256") == snapshot_hash and profile.get("source_slice_manifest_sha256") == slice_hash, "Profile records the verified local Data Export snapshot and hashes")
	check(profile.get("points_by_models", {}) == {3: 135, 6: 275} and profile.get("third_plus_points_by_models", {}) == {3: 150, 6: 290} and profile.get("max_supported_copies") == 3, "Only exported 3/6 model sizes, both point tiers and the local copy gate are declared")
	check(profile.get("base_size_source_mm") == 40 and profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}, "Source base and all characteristics match the pinned profile")
	for keyword: String in ["BLOOD ANGELS", "ADEPTUS ASTARTES", "JUMP PACK", "INFANTRY", "EXPLOSIVES", "FLY", "IMPERIUM", "TACTICUS"]:
		check(keyword in profile.get("keywords", []), "Sanguinary Guard retains source keyword %s" % keyword)
	var angelus: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var inferno: Dictionary = profile.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var encarmine: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(angelus.get("range_inches") == 18.0 and angelus.get("attacks") == 3 and angelus.get("skill") == 2 and angelus.get("strength") == 5 and angelus.get("ap") == -1 and angelus.get("damage") == 1 and angelus.get("keywords", {}).get("assault", false) and angelus.get("keywords", {}).get("close-quarters", false), "Angelus Boltgun profile and traits match the source")
	check(inferno.get("range_inches") == 9.0 and inferno.get("attacks") == 1 and inferno.get("skill") == 2 and inferno.get("strength") == 8 and inferno.get("ap") == -3 and inferno.get("damage") == "D3+2" and inferno.get("keywords", {}).get("melta", 0) == 1 and inferno.get("keywords", {}).get("close-quarters", false), "Inferno Pistol profile and traits match the source")
	check(encarmine.get("attacks") == 4 and encarmine.get("skill") == 2 and encarmine.get("strength") == 6 and encarmine.get("ap") == -2 and encarmine.get("damage") == 2 and encarmine.get("keywords", {}).get("lance", false), "Encarmine Weapon profile and Lance match the source")
	check(Profiles.sanguinary_guard_inferno_limit(3) == 1 and Profiles.sanguinary_guard_inferno_limit(6) == 2 and Profiles.sanguinary_guard_inferno_limit(4) == 0, "Inferno replacement limit is available only at the source-priced unit sizes")
	check(Profiles.sanguinary_guard_loadouts_valid(["inferno-pistol", "angelus-boltgun", "angelus-boltgun"], 3), "A three-model unit can replace one Angelus Boltgun")
	check(not Profiles.sanguinary_guard_loadouts_valid(["inferno-pistol", "inferno-pistol", "angelus-boltgun"], 3), "A three-model unit cannot exceed one Inferno Pistol")
	check(Profiles.sanguinary_guard_loadouts_valid(["inferno-pistol", "inferno-pistol", "angelus-boltgun", "angelus-boltgun", "angelus-boltgun", "angelus-boltgun"], 6), "A six-model unit can replace two Angelus Boltguns")
	check(not Profiles.sanguinary_guard_loadouts_valid(["inferno-pistol", "inferno-pistol", "inferno-pistol", "angelus-boltgun", "angelus-boltgun", "angelus-boltgun"], 6), "A six-model unit cannot exceed two Inferno Pistols")
	var unpriced_loadout: Array[String] = ["angelus-boltgun", "angelus-boltgun", "angelus-boltgun", "angelus-boltgun"]
	check(not Profiles.sanguinary_guard_loadouts_valid(unpriced_loadout, 4), "Unpriced 4-model unit size is not admitted")
	check(AbilityCatalog.RULES.get(GUARD, []) == ["deep-strike", "combat-doctrines", "heirs-of-azkaellon", "angelic-visage"], "Only the datasheet's two abilities and source-listed army rules are registered")
	check(Catalog.SPECS.get(GUARD, {}).get("current_reference", false) and Catalog.SPECS.get(GUARD, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Roster.POINTS.get(GUARD, {}).get("sizes", {}) == {3: 135, 6: 275}, "Verified 3/6 model profile is admitted through current roster construction")
	check(GUARD in MarineLinks.targets(JUMP_CAPTAIN), "Captain With Jump Pack can lead Sanguinary Guard")
	check(Capabilities.supported("heirs-of-azkaellon") and Capabilities.supported("angelic-visage"), "Both Sanguinary Guard abilities have runtime capability gates")

	var state := fresh_state()
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Both-player Blood Angels rosters materialize from the current catalog: " + materialization_error)
	if not materialization_error.is_empty():
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.setup_players = []
	state.unit_abilities.window = {}
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-12, 12) if int(state.units[model].owner) == 1 else Vector2(12, 12)
	var six_squad := squad_for_size(state, 1, GUARD, 6)
	var three_squad := squad_for_size(state, 1, GUARD, 3)
	var enemy_guard_squad := squad_for_size(state, 2, GUARD, 3)
	var jump_captain := find_model(state, 1, JUMP_CAPTAIN)
	check(six_squad >= 0 and three_squad >= 0 and enemy_guard_squad >= 0 and jump_captain >= 0, "Both players' legal Guard sizes and the Jump Pack Captain materialize")
	if six_squad < 0 or three_squad < 0 or enemy_guard_squad < 0 or jump_captain < 0:
		quit(1)
		return
	check(C.UnitActions.attachment_allowed(state, jump_captain, six_squad), "The Captain With Jump Pack can attach to the six-model unit")
	C.UnitActions.attach(state, jump_captain, six_squad)
	var six_models := models_for(state, six_squad, GUARD)
	check(six_models.size() == 6 and C.UnitActions._component_starting_strength(state, state.units[six_models[0]]) == 6, "Attached Captain does not inflate the Guard unit's one-per-three equipment count")
	check(C.UnitAbilities.has(state, six_squad, "deep-strike") and C.UnitAbilities.every_model_has(state, six_squad, "deep-strike"), "Deep Strike is retained by the attached Guard unit")
	check(C.UnitAbilities.has(state, six_squad, "combat-doctrines"), "Sanguinary Guard gains the shared Combat Doctrines rule")

	var first_guard := six_models[0]
	var second_guard := six_models[1]
	var third_guard := six_models[2]
	var first_result := submit_choice(state, 1, "sanguinary-guard-inferno-pistol", six_squad, first_guard, "on")
	var first_weapons := Profiles.sanguinary_guard_weapons(true)
	check(str(first_result.get("error", "")).is_empty() and state.units[first_guard].ranged_weapons == first_weapons.ranged, "Public Army Preparation replaces the first Angelus Boltgun with an Inferno Pistol")
	var second_result := submit_choice(state, 1, "sanguinary-guard-inferno-pistol", six_squad, second_guard, "on")
	check(str(second_result.get("error", "")).is_empty() and state.units[second_guard].ranged_weapons == first_weapons.ranged, "A six-model unit can assign its second source-legal Inferno Pistol")
	check(find_choice(state, 1, "sanguinary-guard-inferno-pistol", six_squad, third_guard, "on").is_empty(), "Preparation withholds a third Inferno Pistol from a six-model unit")
	var over_limit := PublicUnitCommand.submit(state, 1, {"action": "sanguinary-guard-inferno-pistol", "target": six_squad, "model": third_guard, "value": "on"})
	check(not str(over_limit.get("error", "")).is_empty() and not state.units[third_guard].get("sanguinary_guard_inferno_pistol", false), "Public command rejects an over-limit replacement without changing the third model")
	var restore_result := submit_choice(state, 1, "sanguinary-guard-inferno-pistol", six_squad, first_guard, "off")
	check(str(restore_result.get("error", "")).is_empty() and state.units[first_guard].ranged_weapons == Profiles.sanguinary_guard_weapons(false).ranged and not find_choice(state, 1, "sanguinary-guard-inferno-pistol", six_squad, third_guard, "on").is_empty(), "Restoring an Angelus Boltgun frees the unit's replacement slot")
	var inferno_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, first_weapons, second_guard, enemy_guard_squad)
	check(inferno_weapon_failures.is_empty(), "Inferno Pistol and Encarmine Weapon pass Equipment and AttackPlan: %s" % str(inferno_weapon_failures))
	var default_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, first_guard, enemy_guard_squad)
	check(default_weapon_failures.is_empty(), "Default Angelus Boltgun and Encarmine Weapon pass Equipment and AttackPlan: %s" % str(default_weapon_failures))

	var enemy_model := models_for(state, enemy_guard_squad, GUARD)[0]
	state.units[enemy_model].position = Vector2(0, 0)
	state.units[first_guard].position = Vector2(1.5, 0)
	state.phase = "fight"
	state.active = 2
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var melee_plan := C.AttackPlan.prepare(state, enemy_guard_squad, true, [{"model": enemy_model, "target": six_squad, "amount": 4, "weapon": "encarmine-weapon", "profile": "standard"}], true)
	var melee_context: Dictionary = melee_plan.get("batches", [{}])[0].get("context", {}) if not melee_plan.get("batches", []).is_empty() else {}
	check(str(melee_plan.get("error", "")).is_empty() and melee_context.get("hit_modifier", 0) == -1 and melee_context.get("wound_modifier", 0) == -1, "Incoming Strength 6 melee attacks receive -1 to Hit and -1 to Wound against Sanguinary Guard")
	state.units[enemy_model].position = Vector2(-8, 0)
	state.units[first_guard].position = Vector2(0, 0)
	state.phase = "shooting"
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var ranged_plan := C.AttackPlan.prepare(state, enemy_guard_squad, false, [{"model": enemy_model, "target": six_squad, "amount": 1, "weapon": "angelus-boltgun", "profile": "standard"}], false)
	var ranged_context: Dictionary = ranged_plan.get("batches", [{}])[0].get("context", {}) if not ranged_plan.get("batches", []).is_empty() else {}
	check(str(ranged_plan.get("error", "")).is_empty() and ranged_context.get("hit_modifier", 0) == 0 and ranged_context.get("wound_modifier", 0) == 0, "Ranged attacks receive neither melee Visage penalty nor Heirs penalty when Strength equals Toughness")

	print("Sanguinary Guard source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

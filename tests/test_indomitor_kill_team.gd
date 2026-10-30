extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "indomitor-kill-team"
const UNIT_ID := "40kdc:11e:adeptus-astartes:indomitor-kill-team"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func fixture() -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry(UNIT, 10), entry("captain-in-gravis-armour"), entry("apothecary-biologis")]
	lists[2].entries = [entry("intercessor-squad", 5), entry("repulsor")]
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, lists)

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func models_for(state: Dictionary, squad: int, identity: String = UNIT) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func model_at_index(state: Dictionary, squad: int, index: int) -> int:
	for model: int in models_for(state, squad):
		if int(state.units[model].get("indomitor_kill_team_model", -1)) == index: return model
	return -1

func weapon_ids(unit: Dictionary, category: String) -> Array[String]:
	var result: Array[String] = []
	for weapon: Dictionary in unit.get(category + "_weapons", []): result.append(str(weapon.get("id", "")))
	return result

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	return {}

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func has_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> bool:
	return not find_choice(state, owner, action, squad, model, value).is_empty()

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, owner, find_choice(state, owner, action, squad, model, value))

func prepare_battle(state: Dictionary, phase: String = "shooting") -> void:
	state.phase = phase
	state.active = 1
	state.turn = 1
	state.round = 1
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Indomitor Kill Team" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002781", "The runtime profile maps to the current Deathwatch App datasheet")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "d52d0ec3d53cf0a24bce0b7c9a89afe7612ea3d4868a8baa8bd46bbb1ce0f08d", "The verified export and Indomitor source slice are pinned by SHA-256")
	check(profile.get("points_by_models", {}) == {10: 280} and profile.get("third_plus_points_by_models", {}) == {10: 300} and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 40, "The fixed ten-model size, 40 mm bases and source copy-tier costs are recorded")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "The source model rows share the recorded Gravis characteristics")
	check(profile.get("model_loadouts", []).size() == 10 and profile.model_loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ["flamestorm-heavy-intercessor", "flamestorm-heavy-intercessor", "flamestorm-heavy-intercessor", "melta-heavy-intercessor", "melta-heavy-intercessor", "melta-heavy-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor"], "The source composition is three Flamestorm, three Melta and four Heavy Rifle models")
	check(profile.keywords == ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "GRAVIS", "IMPERIUM"], "The profile retains the source unit keywords")
	check(profile_weapon("ranged", "flamestorm-gauntlets").keywords == {"blast": 2, "torrent": true, "twin-linked": true} and profile_weapon("ranged", "flamestorm-gauntlets", "close-quarters").keywords.has("close-quarters"), "Both Flamestorm Gauntlet profiles are represented")
	check(profile_weapon("ranged", "auto-boltstorm-gauntlets").keywords == {"twin-linked": true, "close-quarters": true} and profile_weapon("ranged", "fragstorm-grenade-launcher").keywords == {"blast": 1}, "The replacement package carries both its listed weapons")
	check(profile_weapon("ranged", "deathwatch-heavy-bolt-rifle").strength == 5 and profile_weapon("ranged", "deathwatch-heavy-bolter").get("damage", -1) == 3, "The Heavy Bolt Rifle and Heavy Bolter profiles match the source")
	check(profile_weapon("ranged", "melta-rifle", "hunter").strength == 12 and profile_weapon("ranged", "melta-rifle", "hunter").keywords.get("hunter", []) == ["Monster", "Vehicle"] and profile_weapon("ranged", "multi-melta", "hunter").keywords.get("melta", 0) == 3, "Melta Hunter profiles preserve target eligibility and Melta values")
	check(profile_weapon("melee", "twin-power-fists").keywords == {"twin-linked": true} and profile_weapon("melee", "ceramite-fists").strength == 5, "Both source melee profiles are represented")
	check(Catalog.SPECS.has(UNIT) and Abilities.RULES.get(UNIT, []) == ["combat-doctrines", "indomitor-doctrines"] and CapabilityRegistry.known("indomitor-doctrines") and CapabilityRegistry.supported("indomitor-doctrines"), "The profile and named unit ability are registered")
	check(UNIT in LeaderLinks.targets("captain-in-gravis-armour") and UNIT in SupportAttachments.links("apothecary-biologis"), "Captain in Gravis Armour and Apothecary Biologis keep the source attachment links")
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 10, 3)]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 860, "Three copies use the 280, 280 and 300 point source tiers")
	var invalid_size := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 5)]})
	check(not str(invalid_size.get("error", "")).is_empty(), "Admission rejects sizes outside the fixed source composition")

	var state := fixture()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Indomitor materializes in both local Deathwatch current-catalog forces: " + state_error)
	if not state_error.is_empty():
		print("Indomitor Kill Team source-bounded checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT)
	var indomitor_models := models_for(state, squad)
	var expected_ranged := [["flamestorm-gauntlets"], ["flamestorm-gauntlets"], ["flamestorm-gauntlets"], ["bolt-pistol", "melta-rifle"], ["bolt-pistol", "melta-rifle"], ["bolt-pistol", "melta-rifle"], ["deathwatch-heavy-bolt-rifle"], ["deathwatch-heavy-bolt-rifle"], ["deathwatch-heavy-bolt-rifle"], ["deathwatch-heavy-bolt-rifle"]]
	check(indomitor_models.size() == 10 and int(state.squads[squad].get("training_cost", -1)) == 280, "The fixed unit materializes at its 280-point initial price")
	for model: int in indomitor_models:
		var index := int(state.units[model].get("indomitor_kill_team_model", -1))
		check(state.units[model].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))) == expected_ranged[index] and state.units[model].radius > 0.0 and state.units[model].movement == 5 and state.units[model].max_wounds == 3 and state.units[model].defense.toughness == 6, "Model %d receives its source-specific 40 mm Gravis profile and default weapons" % index)
	check(C.UnitAbilities.has(state, squad, "indomitor-doctrines"), "Indomitor Doctrines is active on the current-reference unit")
	var captain_squad := find_squad(state, 1, "captain-in-gravis-armour")
	var biologis_squad := find_squad(state, 1, "apothecary-biologis")
	check(C.UnitActions.attachment_allowed(state, C.living(state, captain_squad)[0], squad), "Captain in Gravis Armour can attach through its source Leader link")
	check(C.UnitActions.attachment_allowed(state, C.living(state, biologis_squad)[0], squad), "Apothecary Biologis can attach through its source Support link")

	var flamestorm_one := model_at_index(state, squad, 0)
	var flamestorm_two := model_at_index(state, squad, 1)
	var heavy_one := model_at_index(state, squad, 6)
	var heavy_two := model_at_index(state, squad, 7)
	var heavy_three := model_at_index(state, squad, 8)
	var melta_one := model_at_index(state, squad, 3)
	var melta_two := model_at_index(state, squad, 4)
	check(has_choice(state, 1, "indomitor-flamestorm-gauntlets", squad, flamestorm_one, "on") and has_choice(state, 1, "indomitor-multi-melta", squad, melta_one, "on"), "Each eligible model receives its listed preparation option")
	var auto_one := choose(state, 1, "indomitor-flamestorm-gauntlets", squad, flamestorm_one, "on")
	var auto_two := choose(state, 1, "indomitor-flamestorm-gauntlets", squad, flamestorm_two, "on")
	check(auto_one.get("error", "").is_empty() and auto_two.get("error", "").is_empty() and weapon_ids(state.units[flamestorm_one], "ranged") == ["auto-boltstorm-gauntlets", "fragstorm-grenade-launcher"], "Any number of Flamestorm bearers can take both replacement weapons")
	var heavy_first := choose(state, 1, "indomitor-heavy-bolter", squad, heavy_one, "on")
	var heavy_second := choose(state, 1, "indomitor-heavy-bolter", squad, heavy_two, "on")
	check(heavy_first.get("error", "").is_empty() and heavy_second.get("error", "").is_empty() and not has_choice(state, 1, "indomitor-heavy-bolter", squad, heavy_three, "on"), "The ten-model unit permits two Heavy Bolters and withholds a third")
	var forged_heavy := {"action": "indomitor-heavy-bolter", "model": heavy_three, "target": squad, "value": "on"}
	var before_forged_heavy := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forged_heavy).is_empty() and before_forged_heavy == var_to_bytes(state), "A forged action cannot exceed the per-five-model Heavy Bolter limit")
	var multi_choice := choose(state, 1, "indomitor-multi-melta", squad, melta_one, "on")
	check(multi_choice.get("error", "").is_empty() and weapon_ids(state.units[melta_one], "ranged") == ["bolt-pistol", "multi-melta"] and not has_choice(state, 1, "indomitor-multi-melta", squad, melta_two, "on"), "The one Multi-melta replacement changes only its bearer")
	var forged_melta := {"action": "indomitor-multi-melta", "model": melta_two, "target": squad, "value": "on"}
	var before_forged_melta := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forged_melta).is_empty() and before_forged_melta == var_to_bytes(state), "A forged action cannot exceed the one Multi-melta limit")
	choose(state, 1, "indomitor-heavy-bolter", squad, heavy_one, "off")
	choose(state, 1, "indomitor-multi-melta", squad, melta_one, "off")
	choose(state, 1, "indomitor-flamestorm-gauntlets", squad, flamestorm_one, "off")
	check(weapon_ids(state.units[heavy_one], "ranged") == ["deathwatch-heavy-bolt-rifle"] and weapon_ids(state.units[melta_one], "ranged") == ["bolt-pistol", "melta-rifle"] and weapon_ids(state.units[flamestorm_one], "ranged") == ["flamestorm-gauntlets"], "Reversing a choice restores each source-default weapon set")

	prepare_battle(state)
	var target := find_squad(state, 2, "intercessor-squad")
	var vehicle := find_squad(state, 2, "repulsor")
	for model: int in indomitor_models: state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, target): state.units[model].position = Vector2(10.0, 0.0)
	for model: int in C.living(state, vehicle): state.units[model].position = Vector2(20.0, 0.0)
	var heavy_model := model_at_index(state, squad, 9)
	var assignment := {"model": heavy_model, "target": target, "amount": 1, "weapon": "deathwatch-heavy-bolt-rifle", "profile": "standard"}
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.batches[0].weapon.strength) == 6, "Ranged Indomitor Doctrines adds +1 Strength against the closest eligible target")
	assignment.target = vehicle
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.batches[0].weapon.strength) == 5, "A farther eligible target does not receive the ranged Strength bonus")
	var melta_model := model_at_index(state, squad, 5)
	assignment = {"model": melta_model, "target": vehicle, "amount": 1, "weapon": "melta-rifle", "profile": "hunter"}
	var hunter_targets := C.AttackPlan.legal_targets(state, melta_model, false, "melta-rifle", "hunter")
	check(vehicle in hunter_targets and target not in hunter_targets, "Hunter target eligibility is applied before closest-target selection")
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.batches[0].weapon.strength) == 13, "The nearest eligible Vehicle receives +1 Strength from the Hunter profile")

	state.phase = "fight"
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	for model: int in indomitor_models: state.units[model].position = Vector2(20.0, 0.0)
	var fists_model := model_at_index(state, squad, 0)
	state.units[fists_model].position = Vector2.ZERO
	for model: int in C.living(state, target): state.units[model].position = Vector2(1.0, 0.0)
	for model: int in C.living(state, vehicle): state.units[model].position = Vector2(40.0, 0.0)
	state.squads[squad].charged = false
	assignment = {"model": fists_model, "target": target, "amount": 3, "weapon": "twin-power-fists", "profile": "standard"}
	plan = C.AttackPlan.prepare(state, squad, true, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("strength", -1)) == 8, "The melee Strength bonus is absent without a Charge move: " + str(plan))
	state.squads[squad].charged = true
	plan = C.AttackPlan.prepare(state, squad, true, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("strength", -1)) == 9, "A completed Charge move gives Indomitor melee attacks +1 Strength: " + str(plan))

	print("Indomitor Kill Team source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

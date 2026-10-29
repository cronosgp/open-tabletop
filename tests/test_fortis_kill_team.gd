extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const FortisDoctrines = preload("res://scripts/edition_11/fortis_doctrines.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "fortis-kill-team"
const UNIT_ID := "40kdc:11e:adeptus-astartes:fortis-kill-team"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries.append(entry(UNIT, 10))
	result[2].entries.append(entry("captain"))
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, lists())

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength < 0 or int(state.squads[squad].get("starting_strength", -1)) == strength: return squad
	return -1

func models_for(state: Dictionary, squad: int, identity: String = UNIT) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func model_with_index(state: Dictionary, squad: int, model_index: int) -> int:
	for model: int in models_for(state, squad):
		if int(state.units[model].get("fortis_kill_team_model", -1)) == model_index: return model
	return -1

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
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

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Fortis Kill Team" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002780", "The runtime profile maps to the current Deathwatch App datasheet identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "815e9a66fe60f16513dcd436fc48835047b9a76febcf09e7cd4ba18b15f39998", "The source export and Fortis slice manifests are identified by their verified hashes")
	check(profile.get("points_by_models", {}) == {10: 210} and profile.get("third_plus_points_by_models", {}) == {10: 225} and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 32, "The fixed ten-model size, copy-tier prices and 32 mm bases match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "The Fortis shared characteristics match every local model row")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 10 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ["castellan-launcher-intercessor", "sergeant", "plasma-incinerator-intercessor", "plasma-incinerator-intercessor", "deathwatch-bolt-rifle-intercessor", "deathwatch-bolt-rifle-intercessor", "heavy-bolt-pistol-intercessor", "heavy-bolt-pistol-intercessor", "pyreblaster-intercessor", "pyreblaster-intercessor"], "The ten model-specific loadouts retain their export composition and source order")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS"], "Only the seven source-listed unit keywords are registered")
	check(profile_weapon("ranged", "deathwatch-bolt-rifle").keywords == {"assault": true, "lethal-hits": true, "heavy": true} and profile_weapon("ranged", "plasma-incinerator", "supercharge").keywords.get("hazardous", false), "The Deathwatch Bolt Rifle and supercharged Plasma Incinerator preserve their source traits")
	check(profile_weapon("ranged", "grenade-launcher", "frag").attacks == 4 and profile_weapon("ranged", "grenade-launcher", "krak").get("damage", -1) == 3, "Both Astartes Grenade Launcher profiles are available")
	check(profile_weapon("ranged", "superkrak-rocket-launcher").get("damage", "") == "D3+3" and profile_weapon("ranged", "vengor-launcher").keywords == {"blast": 1, "indirect-fire": true, "heavy": true}, "The two alternate rocket launcher profiles preserve their source damage and traits")
	check(profile_weapon("melee", "chainsword").attacks == 4 and profile_weapon("melee", "power-fist").strength == 8 and profile_weapon("melee", "thunder-hammer").keywords.get("devastating-wounds", false), "All listed Fortis melee replacements are in the local profile")
	check(Catalog.SPECS.has(UNIT) and Catalog.SPECS[UNIT].get("max_supported_copies", 0) == 3 and Abilities.RULES.get(UNIT, []) == ["combat-doctrines", "fortis-doctrines"], "The three-copy admission limit and distinct Fortis Doctrines rule are registered")
	check(CapabilityRegistry.known("fortis-doctrines") and CapabilityRegistry.supported("fortis-doctrines"), "Fortis Doctrines is visible in the capability registry")
	for leader: String in ["captain", "chaplain", "librarian", "techmarine", "watch-captain-artemis", "watch-master"]:
		check(UNIT in LeaderLinks.targets(leader), "%s keeps its source-listed Fortis Leader link" % leader)
	for support: String in ["ancient", "apothecary", "judiciar", "lieutenant"]:
		check(UNIT in SupportAttachments.links(support), "%s keeps its source-listed Fortis Support link" % support)
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 10, "copies": 3}]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 645, "Three Fortis copies use 210, 210 and 225 point prices")

	var state := fresh_state()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Fortis Kill Team materializes in both local current-reference rosters: " + state_error)
	if not state_error.is_empty():
		print("Fortis Kill Team source-bounded checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT, 10)
	var fortis_models := models_for(state, squad)
	var sergeant := model_with_index(state, squad, 1)
	var rocket_model := model_with_index(state, squad, 0)
	var plasma_one := model_with_index(state, squad, 2)
	var plasma_two := model_with_index(state, squad, 3)
	var rifle_one := model_with_index(state, squad, 4)
	var rifle_two := model_with_index(state, squad, 5)
	check(squad > 0 and fortis_models.size() == 10 and int(state.squads[squad].get("training_cost", -1)) == 210, "The source unit materializes as ten models for 210 points")
	check(sergeant >= 0 and state.units[sergeant].get("sergeant", false) and not state.units[rocket_model].get("sergeant", false), "Only the source Kill Team Sergeant is marked as Sergeant")
	var expected_ranged := [["castellan-launcher", "superfrag-rocket-launcher"], ["bolt-pistol", "deathwatch-bolt-rifle"], ["plasma-incinerator", "bolt-pistol"], ["plasma-incinerator", "bolt-pistol"], ["deathwatch-bolt-rifle", "bolt-pistol"], ["deathwatch-bolt-rifle", "bolt-pistol"], ["heavy-bolt-pistol"], ["heavy-bolt-pistol"], ["bolt-pistol", "pyreblaster"], ["bolt-pistol", "pyreblaster"]]
	var expected_melee := [["knives-and-fists"], ["knives-and-fists"], ["knives-and-fists"], ["knives-and-fists"], ["knives-and-fists"], ["knives-and-fists"], ["chainsword"], ["chainsword"], ["knives-and-fists"], ["knives-and-fists"]]
	for model: int in fortis_models:
		var index := int(state.units[model].get("fortis_kill_team_model", -1))
		check(state.units[model].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))) == expected_ranged[index] and state.units[model].get("melee_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))) == expected_melee[index], "Fortis model %d receives its exact source-defined default weapons" % index)
		check(state.units[model].keywords == profile.model_loadouts[index].keywords, "Fortis model %d keeps source model keywords" % index)
	check(C.UnitAbilities.has(state, squad, "fortis-doctrines"), "The local unit ability catalog activates Fortis Doctrines")

	check(has_choice(state, 1, "fortis-sergeant-melee", squad, sergeant, "thunder-hammer") and has_choice(state, 1, "fortis-sergeant-ranged", squad, sergeant, "hand-flamer"), "The Sergeant receives both source replacement option groups")
	var sergeant_melee_choice := choose(state, 1, "fortis-sergeant-melee", squad, sergeant, "power-fist")
	var sergeant_ranged_choice := choose(state, 1, "fortis-sergeant-ranged", squad, sergeant, "hand-flamer")
	check(sergeant_melee_choice.get("error", "").is_empty() and sergeant_ranged_choice.get("error", "").is_empty() and state.units[sergeant].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "hand-flamer") and state.units[sergeant].melee_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["power-fist"], "Sergeant choices replace the correct ranged and melee weapons through the public setup command")
	check(not has_choice(state, 1, "fortis-grenade-launcher", squad, sergeant, "on"), "The Sergeant cannot take a Grenade Launcher after replacing its Deathwatch Bolt Rifle")
	choose(state, 1, "fortis-sergeant-ranged", squad, sergeant, "deathwatch-bolt-rifle")
	var grenade_one := choose(state, 1, "fortis-grenade-launcher", squad, sergeant, "on")
	var grenade_two := choose(state, 1, "fortis-grenade-launcher", squad, rifle_one, "on")
	check(grenade_one.get("error", "").is_empty() and grenade_two.get("error", "").is_empty() and state.units[sergeant].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "grenade-launcher"), "Two models in the ten-model unit can take the per-five-model Grenade Launcher")
	check(not has_choice(state, 1, "fortis-grenade-launcher", squad, rifle_two, "on"), "The unit withholds a third Grenade Launcher")
	var forged_launcher := {"action": "fortis-grenade-launcher", "model": rifle_two, "target": squad, "value": "on"}
	var before_forged_launcher := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forged_launcher).is_empty() and before_forged_launcher == var_to_bytes(state), "A forged command cannot exceed the source Grenade Launcher limit")
	var plasma_choice := choose(state, 1, "fortis-plasma-pistol", squad, plasma_one, "on")
	check(plasma_choice.get("error", "").is_empty() and state.units[plasma_one].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "plasma-pistol") and not has_choice(state, 1, "fortis-plasma-pistol", squad, plasma_two, "on"), "Only one of the two Plasma Incinerator Intercessors can replace its Bolt Pistol")
	var rocket_choice := choose(state, 1, "fortis-rocket-launcher", squad, rocket_model, "vengor")
	check(rocket_choice.get("error", "").is_empty() and state.units[rocket_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "vengor-launcher" and weapon.profiles.standard.keywords.get("indirect-fire", false)), "The unique Castellan carrier can switch to the source Vengor Launcher")
	var wrong_owner_choice := find_choice(state, 1, "fortis-rocket-launcher", squad, rocket_model, "superfrag")
	var before_wrong_owner := var_to_bytes(state)
	check(not wrong_owner_choice.is_empty() and not PublicUnitCommand.error(state, 2, wrong_owner_choice).is_empty() and before_wrong_owner == var_to_bytes(state), "The opposing player cannot alter Fortis preparation")

	var target := find_squad(state, 2, "intercessor-squad", 5)
	var target_models := C.living(state, target)
	var attack_model := rifle_two
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.squads[squad].moved_distance = 4.0
	for model: int in fortis_models: state.units[model].position = Vector2.ZERO
	for model: int in target_models: state.units[model].position = Vector2(12.0, float(model % 3))
	var assignment := {"model": attack_model, "target": target, "amount": 1, "weapon": "deathwatch-bolt-rifle", "profile": "standard"}
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 0 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 0, "Fortis Doctrines adds no modifiers against a target at Starting Strength (plan: %s)" % str(plan))
	state.units[target_models[4]].wounds = 0
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and FortisDoctrines.target_strength_tier(state, target) == 1 and int(plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 1 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 0, "One model lost gives +1 to Hit but not +1 to Wound")
	for index in range(2, target_models.size()): state.units[target_models[index]].wounds = 0
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and FortisDoctrines.target_strength_tier(state, target) == 2 and int(plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 1 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 1, "At or below half-strength, the attack gains +1 to Hit and +1 to Wound")
	var captain_squad := find_squad(state, 2, "captain")
	var captain_model := C.living(state, captain_squad)[0]
	state.units[captain_model].wounds = 1
	state.units[captain_model].position = Vector2(12.0, 0.0)
	check(FortisDoctrines.target_strength_tier(state, captain_squad) == 0, "A damaged one-model unit remains at Starting Strength until that model is destroyed")
	assignment.target = captain_squad
	plan = C.AttackPlan.prepare(state, squad, false, [assignment], true)
	check(plan.get("error", "").is_empty() and int(plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 0 and int(plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) == 0, "Fortis Doctrines counts living models rather than lost wounds on a single model")

	print("Fortis Kill Team source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

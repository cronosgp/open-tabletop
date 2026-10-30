extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "decimus-kill-team"
const UNIT_ID := "40kdc:11e:adeptus-astartes:decimus-kill-team"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func fixture(models: int = 10, composition_id: String = "") -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry(UNIT, models), entry("captain")]
	lists[2].entries = [entry("intercessor-squad", 5)]
	if not composition_id.is_empty(): lists[1].entries[0].composition_choice_id = composition_id
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, lists)

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func models_for(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in C.living(state, squad):
		if C.UnitAbilities.identity(state.units[model]) == UNIT: result.append(model)
	result.sort()
	return result

func model_for_role(state: Dictionary, squad: int, role: String, occurrence: int = 0) -> int:
	for model: int in models_for(state, squad):
		if str(state.units[model].get("decimus_kill_team_role", "")) != role: continue
		if occurrence == 0: return model
		occurrence -= 1
	return -1

func weapon_ids(unit: Dictionary, category: String) -> Array[String]:
	var result: Array[String] = []
	for weapon: Dictionary in unit.get(category + "_weapons", []): result.append(str(weapon.get("id", "")))
	return result

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, owner, find_choice(state, owner, action, squad, model, value))

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Decimus Kill Team" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000004175", "The profile maps to the current Deathwatch App datasheet")
	check(profile.get("source_snapshot_id") == "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z" and profile.get("source_export_updated_at") == "2026-10-28T23:48:19+03:00" and profile.get("source_manifest_sha256") == "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e" and profile.get("source_slice_manifest_sha256") == "b258edd148a8b4f1dcb1dd174721c132b8337e6533b8aea597871dd96cd1aa88", "The latest verified export and Decimus audit slice are pinned by SHA-256")
	check(profile.get("points_by_models", {}) == {5: 110, 10: 210} and profile.get("points", 0) == 210 and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 32, "Source costs are recorded while the runtime defaults to the legal 10-model, 210-point roster and its 32 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "The common Veteran characteristics match the local model table")
	check(profile.get("composition_options", []).filter(func(option: Dictionary) -> bool: return int(option.models) == 5).is_empty() and profile.composition_options.filter(func(option: Dictionary) -> bool: return int(option.models) == 10).size() == 1 and profile.get("default_composition_choice_ids", {}) == {10: "ten-balanced"}, "The runtime composition contains only the source-legal 10-model roster")
	var ten_option: Dictionary = profile.composition_options.filter(func(option: Dictionary) -> bool: return int(option.models) == 10)[0]
	check(ten_option.roles == ["xenophase-veteran", "sergeant", "marksman-veteran", "marksman-veteran", "heavy-veteran", "heavy-veteran", "stalker-veteran", "stalker-veteran", "gravis-veteran", "gravis-veteran"], "The 10-model configuration contains two of each 1–2 specialist role")
	var source_model_names: Array = profile.model_loadouts.map(func(model: Dictionary) -> String: return str(model.get("source_model_name", "")))
	check(profile.model_loadouts.size() == 6 and source_model_names.size() == 6 and source_model_names.has("Gravis Veteran") and source_model_names.has("Deathwatch Veteran with Stalker Bolt Rifle") and source_model_names.has("Kill Team Sergeant") and source_model_names.has("Deathwatch Veteran with Xenophase Blade and Special-issue Bolt Pistol") and source_model_names.has("Deathwatch Veteran with Deathwatch Marksman Bolt Carbine") and source_model_names.has("Deathwatch Veteran with Heavy Thunder Hammer and Bolt Pistol"), "All six named source model rows receive a runtime loadout")
	check(profile.keywords == ["ADEPTUS ASTARTES", "DEATHWATCH", "BATTLELINE", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "GRAVIS"], "All source faction and unit keywords are preserved")
	check(profile_weapon("ranged", "deathwatch-marksman-bolt-carbine").keywords == {"lethal-hits": true, "heavy": true} and profile_weapon("ranged", "stalker-bolt-rifle").keywords == {"precision": true, "heavy": true, "lethal-hits": true}, "Marksman and Stalker weapon traits match the export")
	check(profile_weapon("ranged", "infernus-heavy-bolter", "infernus").keywords == {"blast": 1, "torrent": true} and profile_weapon("ranged", "grenade-launcher", "krak").get("damage", -1) == 3, "Infernus and Grenade Launcher profiles retain their distinct modes")
	check(profile_weapon("ranged", "plasma-incinerator", "supercharge").keywords.get("hazardous", false) and profile_weapon("melee", "heavy-thunder-hammer").keywords.get("devastating-wounds", false) and profile_weapon("melee", "xenophase-blade").keywords.get("devastating-wounds", false), "Hazardous and Devastating Wounds profiles are source-defined")
	check(Catalog.SPECS.has(UNIT) and Abilities.RULES.get(UNIT, []) == ["combat-doctrines", "death-to-the-alien", "storm-shield"], "Decimus retains its runtime profile and source-specific unit abilities")
	check(CapabilityRegistry.supported("death-to-the-alien") and CapabilityRegistry.supported("storm-shield"), "Death to the Alien and Storm Shield remain registered capabilities")
	for leader: String in ["captain", "chaplain", "librarian", "techmarine", "watch-captain-artemis", "watch-master"]:
		check(UNIT in LeaderLinks.targets(leader), "%s has the source-listed Decimus Leader link" % leader)
	for support: String in ["ancient", "apothecary", "judiciar", "lieutenant"]:
		check(UNIT in SupportAttachments.links(support), "%s has the source-listed Decimus Support link" % support)
	var builder_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "name": profile.name, "edition": "11e", "faction": "Space Marines", "options": [], "source_digest": "local"})
	check(builder_choice.get("options", []) == [{"models": 10, "cost": 210}] and builder_choice.get("composition_options", []).size() == 1 and Catalog.construction_model_sizes(UNIT, profile) == [10], "Construction exposes only the source-consistent 10-model option while retaining the 5-model row as blocked evidence")
	for option: Dictionary in profile.composition_options:
		if int(option.models) != 10: continue
		var admission := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": UNIT_ID, "models": option.models, "copies": 1, "composition_choice_id": option.id}]})
		var configured: Dictionary = admission.get("configurations", {}).values()[0] if not admission.get("configurations", {}).is_empty() else {}
		check(admission.get("error", "").is_empty() and configured.get("decimus_roles", []) == option.roles and admission.get("total", -1) == profile.points_by_models[option.models], "%s admits its exact %d-model composition at the source cost" % [str(option.id), int(option.models)])
	var invalid_composition := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": UNIT_ID, "models": 5, "copies": 1, "composition_choice_id": "five-invalid"}]})
	check(not str(invalid_composition.get("error", "")).is_empty(), "Army admission rejects an unlisted Decimus role composition")
	var default_five := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": UNIT_ID, "models": 5, "copies": 1}]})
	var default_ten := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 100000, "entries": [{"definition_id": UNIT_ID, "models": 10, "copies": 1}]})
	check(not default_five.get("error", "").is_empty() and default_ten.get("error", "").is_empty() and default_ten.selection.entries[0].get("composition_choice_id", "") == "ten-balanced", "Army admission blocks the unresolved 5-model size and chooses the reconciled 10-model composition")

	var state := fixture()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "The reconciled ten-model unit materializes into the local current-reference match: " + state_error)
	if not state_error.is_empty():
		print("Decimus Kill Team source-bounded checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT)
	var decimus_models := models_for(state, squad)
	var xeno := model_for_role(state, squad, "xenophase-veteran")
	var sergeant := model_for_role(state, squad, "sergeant")
	var heavy := model_for_role(state, squad, "heavy-veteran")
	var stalker := model_for_role(state, squad, "stalker-veteran")
	var gravis := model_for_role(state, squad, "gravis-veteran")
	check(decimus_models.size() == 10 and int(state.squads[squad].get("training_cost", -1)) == 210 and state.units[sergeant].get("sergeant", false), "The selected ten-model roster uses the 210-point price and role-bound Sergeant")
	check(weapon_ids(state.units[xeno], "ranged") == ["special-issue-bolt-pistol"] and weapon_ids(state.units[xeno], "melee") == ["xenophase-blade"] and weapon_ids(state.units[sergeant], "ranged") == ["plasma-pistol"] and weapon_ids(state.units[sergeant], "melee") == ["power-weapon"], "The fixed Xenophase Veteran and Kill Team Sergeant receive their source loadouts")
	check(weapon_ids(state.units[heavy], "ranged") == ["bolt-pistol"] and weapon_ids(state.units[heavy], "melee") == ["heavy-thunder-hammer"] and weapon_ids(state.units[stalker], "ranged") == ["bolt-pistol", "stalker-bolt-rifle"] and weapon_ids(state.units[gravis], "ranged") == ["bolt-pistol", "infernus-heavy-bolter"], "Heavy, Stalker and Gravis specialists receive their source loadouts")
	var gravis_defense := Groups.profile(state, gravis)
	var veteran_defense := Groups.profile(state, stalker)
	check(state.units[gravis].movement == 5 and state.units[gravis].radius > state.units[stalker].radius and gravis_defense.toughness == 6 and gravis_defense.wounds_per_model == 3 and veteran_defense.toughness == 5 and veteran_defense.wounds_per_model == 2, "The mixed unit keeps distinct Gravis movement, base, Toughness and Wounds")
	check(C.UnitAbilities.has(state, squad, "death-to-the-alien") and Abilities.sources(state, squad, "storm-shield").is_empty(), "Death to the Alien is active while an unselected Storm Shield has no bearer")
	var captain_squad := find_squad(state, 1, "captain")
	var captain_model := C.living(state, captain_squad)[0]
	check(C.UnitActions.attachment_allowed(state, captain_model, squad), "A Captain is eligible to attach to Decimus through the source Leader link")
	var gravis_frag := choose(state, 1, "decimus-gravis-weapon", squad, gravis, "frag-cannon")
	var shield_choice := choose(state, 1, "decimus-storm-shield", squad, heavy, "on")
	var plasma_choice := choose(state, 1, "decimus-plasma-incinerator", squad, stalker, "on")
	check(gravis_frag.get("error", "").is_empty() and shield_choice.get("error", "").is_empty() and plasma_choice.get("error", "").is_empty(), "Each per-five-model replacement is selectable during preparation")
	check(weapon_ids(state.units[gravis], "ranged") == ["bolt-pistol", "frag-cannon"] and weapon_ids(state.units[heavy], "melee") == ["power-weapon"] and weapon_ids(state.units[stalker], "ranged") == ["bolt-pistol", "plasma-incinerator"], "Each option replaces only its named weapon and model loadout")
	check(Groups.profile(state, heavy).invulnerable_target == 4 and Abilities.sources(state, squad, "storm-shield") == [heavy], "The selected Storm Shield grants a 4+ invulnerable save only to its bearer")
	var gravis_hellstorm := choose(state, 1, "decimus-gravis-weapon", squad, gravis, "hellstorm-bolt-rifle")
	check(gravis_hellstorm.get("error", "").is_empty() and weapon_ids(state.units[gravis], "ranged") == ["bolt-pistol", "hellstorm-bolt-rifle", "grenade-launcher"], "Hellstorm Bolt Rifle replacement also adds the listed Grenade Launcher")
	choose(state, 1, "decimus-storm-shield", squad, heavy, "off")
	choose(state, 1, "decimus-plasma-incinerator", squad, stalker, "off")
	check(Groups.profile(state, heavy).invulnerable_target == 0 and weapon_ids(state.units[heavy], "melee") == ["heavy-thunder-hammer"] and weapon_ids(state.units[stalker], "ranged").has("stalker-bolt-rifle"), "Reverting replacements restores the hammer, Stalker Rifle and bearer save")

	var battle_state := state.duplicate(true)
	battle_state.phase = "start_turn"
	battle_state.turn = 1
	battle_state.revision = 0
	var battle_captain_squad := find_squad(battle_state, 1, "captain")
	var attach_error := Attachments.form_practice_unit(battle_state, squad, battle_captain_squad, -1, true)
	check(attach_error.is_empty() and C.UnitAbilities.has(battle_state, squad, "death-to-the-alien"), "A Captain forms a source-listed Decimus attachment and receives its unit ability: " + attach_error)
	battle_state.phase = "shooting"
	battle_state.active = 1
	battle_state.round = 1
	battle_state.mission.stage = "battle"
	battle_state.deployment.complete = true
	battle_state.unit_abilities.setup_players = []
	battle_state.unit_abilities.battle_players = [1, 2]
	battle_state.unit_abilities.phase_key = C.UnitActions.key(battle_state)
	battle_state.unit_abilities.window = {}
	for model: int in C.living(battle_state, squad): battle_state.units[model].position = Vector2.ZERO
	var opponent := find_squad(battle_state, 2, "intercessor-squad")
	for model: int in C.living(battle_state, opponent): battle_state.units[model].position = Vector2(12.0, float(model % 3))
	var assignment := {"model": stalker, "target": opponent, "amount": 1, "weapon": "stalker-bolt-rifle", "profile": "standard"}
	var imperium_plan: Dictionary = C.AttackPlan.prepare(battle_state, squad, false, [assignment], true)
	check(imperium_plan.get("error", "").is_empty() and imperium_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Death to the Alien re-rolls Hit rolls of 1 against IMPERIUM targets, including the attached Leader: " + str(imperium_plan))
	for model: int in C.living(battle_state, opponent): battle_state.units[model].keywords = ["ORKS"]
	var xenos_plan: Dictionary = C.AttackPlan.prepare(battle_state, squad, false, [assignment], true)
	check(xenos_plan.get("error", "").is_empty() and xenos_plan.batches[0].context.get("hit_reroll", "none") == "all", "Death to the Alien re-rolls all Hits against targets without IMPERIUM or CHAOS: " + str(xenos_plan))

	var capped_state := fixture(10, "ten-balanced")
	var capped_squad := find_squad(capped_state, 1, UNIT)
	var heavy_one := model_for_role(capped_state, capped_squad, "heavy-veteran")
	var heavy_two := model_for_role(capped_state, capped_squad, "heavy-veteran", 1)
	var shield_on := choose(capped_state, 1, "decimus-storm-shield", capped_squad, heavy_one, "on")
	check(shield_on.get("error", "").is_empty() and not find_choice(capped_state, 1, "decimus-storm-shield", capped_squad, heavy_two, "on").is_empty(), "A 10-model unit can allocate one Storm Shield to each of its two eligible Heavy Veterans")
	var second_shield := choose(capped_state, 1, "decimus-storm-shield", capped_squad, heavy_two, "on")
	check(second_shield.get("error", "").is_empty() and Groups.profile(capped_state, heavy_two).invulnerable_target == 4, "The second per-five-model Storm Shield allowance applies to the second Heavy Veteran")
	var forged_shield := {"action": "decimus-storm-shield", "model": heavy_two, "target": capped_squad, "value": "on"}
	var before_forged_shield := var_to_bytes(capped_state)
	check(not PublicUnitCommand.error(capped_state, 1, forged_shield).is_empty() and before_forged_shield == var_to_bytes(capped_state), "A forged command cannot exceed the per-five-model Storm Shield limit")
	var blocked_size_state := fixture(10, "ten-balanced")
	var blocked_size_squad := find_squad(blocked_size_state, 1, UNIT)
	var blocked_size_gravis := model_for_role(blocked_size_state, blocked_size_squad, "gravis-veteran")
	blocked_size_state.squads[blocked_size_squad].starting_strength = 5
	var blocked_size_choices := C.UnitActions.choices(blocked_size_state, 1).filter(
		func(option: Dictionary) -> bool: return str(option.get("action", "")).begins_with("decimus-")
	)
	var blocked_size_command := {"action": "decimus-gravis-weapon", "model": blocked_size_gravis, "target": blocked_size_squad, "value": "frag-cannon"}
	var before_blocked_size_command := var_to_bytes(blocked_size_state)
	var blocked_size_error := PublicUnitCommand.error(blocked_size_state, 1, blocked_size_command)
	check(blocked_size_choices.is_empty() and not blocked_size_error.is_empty() and before_blocked_size_command == var_to_bytes(blocked_size_state), "The blocked five-model Decimus size offers no equipment choices and rejects forged preparation without mutating state")

	print("Decimus Kill Team source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

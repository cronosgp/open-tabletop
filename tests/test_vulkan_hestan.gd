extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/prepared_training.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and (model < 0 or option.model == model): return option
	return {}

func apply_choice(state: Dictionary, player: int, action: String, model: int = -1) -> String:
	var option := find_choice(state, player, action, model)
	if option.is_empty(): return "Choice not offered: " + action
	var result: Dictionary = PublicUnitCommand.submit(state, player, option, Vector2.ZERO, func() -> int: return 6)
	return str(result.get("error", ""))

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("vulkan-hestan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002726" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Vulkan follows the local Wahapedia e11 source record")
	check(profile.points_by_models == {1: 105} and profile.models == 1 and profile.base_size_source_mm == 40, "Vulkan cost, composition and base match the export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Vulkan characteristics, including the 4+ invulnerable save, match the export")
	check(profile.keywords.has("SALAMANDERS") and profile.keywords.has("TACTICUS") and profile.keywords.has("EXPLOSIVES") and profile.keywords.has("EPIC HERO"), "Vulkan source keywords are present")
	check(profile.ranged.size() == 2 and profile.ranged[1].profiles.standard.attacks == "D6+3" and profile.ranged[1].profiles.standard.skill == 0 and profile.ranged[1].profiles.standard.keywords.torrent, "Gauntlet of the Forge preserves its Torrent attack profile")
	check(profile.melee[0].profiles.standard.keywords.get("devastating-wounds", false), "Spear of Vulkan preserves Devastating Wounds")
	var catalog_row := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:vulkan-hestan", "edition": "11e", "faction": "Space Marines", "options": [{"models": 1, "cost": 105}]})
	check(Catalog.SPECS.get("vulkan-hestan", {}).get("current_reference", false) and catalog_row.get("options", []).size() == 1 and catalog_row.options[0].cost == 105, "Vulkan is published at the local source cost in the consolidated construction catalog")

	var selections := F.selections()
	var marine: Dictionary = selections[1]
	var retained: Array = []
	for entry: Dictionary in marine.entries:
		if entry.definition_id != "40kdc:11e:adeptus-astartes:captain": retained.append(entry)
	retained.append({"definition_id": "40kdc:11e:adeptus-astartes:vulkan-hestan", "models": 1, "copies": 1})
	marine.entries = retained
	selections[1] = marine
	var state: Dictionary = P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Vulkan is admitted into the prepared local Marine match")
	if state.has("error"):
		print("Vulkan local checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.awakened_dynasty.pending.clear()
	var vulkan := find_model(state, 1, "vulkan-hestan")
	var squad: int = state.units[vulkan].squad if vulkan >= 0 else -1
	var intercessor := find_model(state, 1, "assault-intercessor-squad")
	var enemy := find_model(state, 2, "necron-warriors")
	check(vulkan >= 0 and C.UnitAbilities.has(state, squad, "leader") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "transhuman-strategist") and C.UnitAbilities.has(state, squad, "seeker-of-the-unfound") and C.UnitAbilities.has(state, squad, "forgefather"), "Vulkan's Leader, faction and datasheet abilities register")
	check(intercessor >= 0 and enemy >= 0 and C.UnitActions.attachment_allowed(state, vulkan, int(state.units[intercessor].squad)), "Vulkan can lead a source-listed, locally admitted Assault Intercessor Squad")
	check(not C.UnitActions.attachment_allowed(state, vulkan, int(state.units[enemy].squad)), "Vulkan cannot attach to a foreign army")
	if vulkan < 0 or enemy < 0:
		print("Vulkan local checks: %d failures" % failures)
		quit(1)
		return

	var warlord := find_choice(state, 1, "warlord", vulkan)
	check(not warlord.is_empty(), "Vulkan is offered as Warlord during army preparation")
	if not warlord.is_empty():
		var warlord_result: Dictionary = PublicUnitCommand.submit(state, 1, warlord, Vector2.ZERO, func() -> int: return 6)
		check(warlord_result.get("error", "").is_empty(), "Vulkan Warlord declaration applies")
		state.active = 1
		state.round = 1
		state.cp[1] = 0
		C.UnitActions.start_round(state)
		check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP when Vulkan is Warlord")
		C.UnitActions.start_round(state)
		check(state.cp[1] == 1, "Vulkan grants Warlord CP only once per battle round")

	state.phase = "deployment"
	state.unit_abilities.setup_players = [1, 2]
	state.deployment.order = [squad]
	state.deployment.index = 0
	state.deployment.complete = false
	state.deployment.placed = {vulkan: true}
	state.units[vulkan].position = Vector2(-12, 0)
	state.terrain.areas = []
	state.mission.objectives = [{"name": "Vulkan test marker", "kind": "marker", "position": Vector2(-12, 0), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
	check(C.Deployment.confirm_error(state).contains("Seeker of the Unfound"), "Deployment cannot finish until Vulkan chooses an objective")
	state.deployment.order = [int(state.units[intercessor].squad), squad]
	state.deployment.index = 0
	check(not find_choice(state, 1, "seeker-objective", vulkan).is_empty(), "Seeker remains available during deployment if the player advances to another unit")
	state.deployment.order = [squad]
	state.deployment.index = 0
	var seeker := find_choice(state, 1, "seeker-objective", vulkan)
	var seeker_decision := C.UnitActions.pending_decision(state)
	var seeker_option: Dictionary = {}
	for option: Dictionary in seeker_decision.get("legal_options", []):
		if str(option.get("action", "")) == "seeker-objective" and int(option.get("model", -1)) == vulkan and int(option.get("target", -1)) == int(seeker.get("target", -1)): seeker_option = option
	check(seeker_decision.get("priority_player_id", -1) == 1 and seeker_decision.get("timing", "") == "deployment:unit-choice" and not seeker_option.is_empty(), "The deploying player receives a normalized Seeker of the Unfound decision")
	var before_wrong_seeker := var_to_bytes(state)
	var wrong_seeker := MatchCommands.execute(state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(seeker_decision.get("decision_id", "")), "option_id": str(seeker_option.get("id", "")), "choice": seeker}}, func() -> int: return 6)
	check(not str(wrong_seeker.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_seeker, "The opponent cannot submit or mutate the deploying player's Seeker decision")
	var before_stale_seeker := var_to_bytes(state)
	var stale_seeker := MatchCommands.execute(state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(seeker_decision.get("decision_id", "")), "option_id": "stale-seeker-option", "choice": seeker}}, func() -> int: return 6)
	check(not str(stale_seeker.get("error", "")).is_empty() and var_to_bytes(state) == before_stale_seeker, "A stale deployment option is rejected without changing the match")
	state = bytes_to_var(var_to_bytes(state))
	var restored_seeker_decision := C.UnitActions.pending_decision(state)
	check(restored_seeker_decision.get("decision_id", "") == seeker_decision.get("decision_id", "") and restored_seeker_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return option.get("id", "") == seeker_option.get("id", "")), "The deployment choice keeps its decision and option identities through save/restore")
	var seeker_error := apply_choice(state, 1, "seeker-objective", vulkan)
	check(seeker_error.is_empty(), "Seeker of the Unfound selects an objective after Vulkan is placed: " + seeker_error)
	check(C.Deployment.confirm_error(state).is_empty(), "The source-required objective choice clears the deployment gate")
	check(Morale.objective_control(state, vulkan) == 10 and Morale.leadership(state, squad).target == 5, "Vulkan gains OC 10 and Leadership 5+ while within range of his selected objective")
	check(Prevention.rules(state, vulkan).has({"target": 4, "against": "any"}), "Seeker of the Unfound grants Vulkan Feel No Pain 4+ at the selected objective")
	state.units[vulkan].position = Vector2(0, 0)
	check(Morale.objective_control(state, vulkan) == 1 and Morale.leadership(state, squad).target == 6 and not Prevention.rules(state, vulkan).has({"target": 4, "against": "any"}), "Seeker bonuses end when Vulkan leaves objective range")

	state.phase = "shooting"
	state.active = 1
	state.units[vulkan].position = Vector2(-12, 0)
	state.units[enemy].position = Vector2(4, 0)
	var forgefather := find_choice(state, 1, "forgefather-target", vulkan)
	check(not forgefather.is_empty() and forgefather.target == state.units[enemy].squad, "Forgefather offers a visible enemy unit within 24 inches")
	if not forgefather.is_empty():
		var marked := int(forgefather.target)
		var result: Dictionary = PublicUnitCommand.submit(state, 1, forgefather, Vector2.ZERO, func() -> int: return 6)
		check(result.get("error", "").is_empty(), "Forgefather target selection resolves")
		var melta := {"name": "Test Melta", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {"melta": 2}}
		var torrent := {"name": "Test Torrent", "range_inches": 12.0, "attacks": 1, "skill": 0, "strength": 5, "ap": -1, "damage": 1, "keywords": {"torrent": true}}
		var improved_melta := C.UnitAbilities.weapon(state, intercessor, marked, melta, false)
		var improved_torrent := C.UnitAbilities.weapon(state, vulkan, marked, torrent, false)
		var other_target := C.UnitAbilities.weapon(state, intercessor, int(state.units[find_model(state, 2, "immortals")].squad), melta, false)
		check(improved_melta.strength == 10 and improved_torrent.strength == 7 and other_target.strength == 8, "Forgefather adds +2 Strength only to friendly Adeptus Astartes Melta/Torrent attacks against its selected target")
		check(find_choice(state, 1, "forgefather-target", vulkan).is_empty(), "Forgefather selects one target in the Shooting phase")

	print("Vulkan He’stan local checks: %d failures" % failures)
	quit(1 if failures else 0)

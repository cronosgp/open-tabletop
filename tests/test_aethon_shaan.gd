extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Core = preload("res://scripts/edition_11/core_reactions.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(name: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}

func find_unit(s: Dictionary, owner: int, identity: String) -> int:
	for model: int in s.units:
		if s.units[model].owner == owner and C.UnitAbilities.identity(s.units[model]) == identity: return model
	return -1

func by_action(options: Array, action: String, target: int = -1) -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and (target < 0 or option.target == target): return option
	return {}

func one() -> int: return 1
func six() -> int: return 6

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := P.profile("aethon-shaan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004148" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Aethon Shaan retains its pinned local Wahapedia source identity")
	check(profile.points_by_models == {1: 105} and profile.stats == {"movement_inches": 14, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Aethon characteristics and points match the extraction")
	check(profile.ranged[0].profiles.standard.skill == 2 and profile.melee[0].profiles.standard.keywords == {"twin-linked": true, "sustained-hits": 2} and profile.melee[0].profiles.standard.target_restricted_traits["sustained-hits"] == ["MONSTER", "VEHICLE"], "Aethon weapons preserve the source traits and target restriction")
	check(Catalog.SPECS["aethon-shaan"].max_supported_copies == 1, "Aethon is unique in construction")

	var lists := F.selections()
	lists[1].entries = [entry("aethon-shaan"), entry("intercessor-squad", 5)]
	var s: Dictionary = F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not s.has("error"), "Aethon and current Intercessors materialize from local profiles")
	if s.has("error"):
		print(s.error)
		quit(1)
		return
	var aethon := find_unit(s, 1, "aethon-shaan")
	var infantry := find_unit(s, 1, "intercessor-squad")
	var enemy := find_unit(s, 2, "necron-warriors")
	var aethon_squad: int = s.units[aethon].squad
	var infantry_squad: int = s.units[infantry].squad
	var enemy_squad: int = s.units[enemy].squad
	check(not C.UnitAbilities.has(s, aethon_squad, "leader") and not C.UnitActions.attachment_allowed(s, aethon, infantry_squad), "Aethon has no Leader ability or Leader target link")
	for ability: String in ["deep-strike", "lone-operative", "stealth", "combat-doctrines", "transhuman-strategist", "master-of-shadows", "blackwing-mantle"]:
		check(C.UnitAbilities.has(s, aethon_squad, ability), "Aethon receives the exported %s ability" % ability)
	s.phase = "deployment"
	s.unit_abilities.setup_players = [2]
	s.awakened_dynasty.pending = []
	var choices := C.UnitActions.choices(s, 1)
	var warlord_eligible := false
	for option: Dictionary in choices:
		if option.action == "warlord" and option.model == aethon: warlord_eligible = true
	check(warlord_eligible, "Aethon is offered as a Warlord during the local setup flow")
	check(not by_action(choices, "reserve", aethon_squad).is_empty(), "Deep Strike lets Aethon enter Strategic Reserves through the supported reserve flow")
	check(Detection.stealth(s, aethon_squad), "Stealth grants Aethon the supported ranged cover effect")
	s.combat_doctrines.active[1] = "assault"
	check(C.Doctrines.active_for(s, aethon_squad) == "assault" and C.Doctrines.charge_error(s, aethon_squad).is_empty(), "Aethon receives the active Combat Doctrine effects")
	check(C.UnitAbilities.lone_operative_active(s, aethon), "Lone Operative is active while Aethon is a standalone unit")
	s.squads[aethon_squad].attached = true
	check(not C.UnitAbilities.lone_operative_active(s, aethon), "Lone Operative is disabled if Aethon joins an Attached unit")
	s.squads[aethon_squad].attached = false
	s.unit_abilities.warlords = {1: aethon}
	s.active = s.first_player
	s.round = 1
	s.cp[1] = 0
	C.UnitActions.start_round(s)
	check(s.cp[1] == 1, "Transhuman Strategist grants its Warlord CP at the start of the battle round")
	C.UnitActions.start_round(s)
	check(s.cp[1] == 1, "Transhuman Strategist awards CP only once in the battle round")
	s.mission.stage = "battle"
	s.phase = "command"
	s.turn = 1
	s.round = 1
	s.active = 1
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.unit_abilities.window = {}
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.awakened_dynasty.pending = []
	s.terrain.areas = []
	s.cp = {1: 0, 2: 0}
	s.combat_doctrines.selected_turn[1] = s.turn
	for model: int in s.units:
		s.units[model].on_battlefield = true
		s.units[model].position = Vector2(-20, 15) if s.units[model].owner == 1 else Vector2(20, 15)
	for model: int in C.living(s, aethon_squad): s.units[model].position = Vector2(-2, 0)
	for model: int in C.living(s, infantry_squad): s.units[model].position = Vector2(-2, 3)
	for model: int in C.living(s, enemy_squad): s.units[model].position = Vector2(4, 0)
	var master := by_action(C.UnitActions.choices(s, 1), "master-shadows", infantry_squad)
	check(not master.is_empty() and C.UnitActions.pending_decision(s).is_empty(), "Master of Shadows offers an immediate Command choice without a persisted decision")
	if not master.is_empty():
		var before_wrong_master_choice_owner := var_to_bytes(s)
		var wrong_master_choice_owner := MatchCommands.execute(s, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": master, "revision": s.revision}, one)
		check(not str(wrong_master_choice_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_master_choice_owner, "The opponent cannot submit or mutate the immediate Master of Shadows choice")
		var master_choice_result := MatchCommands.execute(s, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": master, "revision": s.revision}, one)
		check(str(master_choice_result.get("error", "")).is_empty(), "Master of Shadows selects a friendly Astartes Infantry unit through the public command")
	check(C.UnitAbilities.master_shadows_active(s, infantry_squad) and not C.UnitAbilities.master_shadows_active(s, enemy_squad), "Master of Shadows is scoped to the selected friendly unit")
	s.phase = "charge"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	var declared := C.declare_charge(s, 1, infantry, s.revision, one)
	check(declared.error.is_empty() and s.stratagems.pending.get("master_shadows", false), "Master of Shadows opens a free Charge re-roll decision without Command Re-roll enabled")
	var reaction_decision := C.Stratagems.pending_decision(s)
	var master_option: Dictionary = {}
	for option: Dictionary in reaction_decision.get("legal_options", []):
		if int(option.get("target", -1)) == infantry_squad and str(option.get("value", "")) == "master-shadows": master_option = option
	var master_choice := {"action": "stratagem-reaction", "model": -1, "target": infantry_squad, "value": "master-shadows", "die": -1}
	var master_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(reaction_decision.get("decision_id", "")), "option_id": str(master_option.get("id", "")), "choice": master_choice}
	var before_wrong_master_owner := var_to_bytes(s)
	var wrong_master_owner := MatchCommands.execute(s, 2, {"kind": MatchCommands.COMMAND_REACTION, "choice": master_envelope, "revision": s.revision}, six)
	check(not str(wrong_master_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_master_owner, "The opponent cannot submit or mutate Master of Shadows' Charge re-roll decision")
	var master_result := MatchCommands.execute(s, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": master_envelope, "revision": s.revision}, six)
	check(str(master_result.get("error", "")).is_empty() and s.pending_charge.rolls == [6, 6] and s.cp[1] == 0 and s.last_command_roll.source == "master-shadows", "Master of Shadows re-rolls both Charge dice through the public command for 0 CP and keeps the mandatory result")
	s.turn = 2
	check(C.UnitAbilities.master_shadows_active(s, infantry_squad), "Master of Shadows remains active through the opponent's turn")
	s.turn = 3
	check(not C.UnitAbilities.master_shadows_active(s, infantry_squad), "Master of Shadows expires at the owner's next Command phase")

	# Exercise the Blackwing exception in both orders: first the ordinary use, then
	# Shaan's free use; the second branch is covered by reversing the setup below.
	s.turn = 2
	s.phase = "charge"
	s.active = 2
	s.unit_abilities.window = {"kind": "end", "owners": [1]}
	s.unit_abilities.used.erase("blackwing:1")
	s.squads[enemy_squad].charge_declared = true
	s.squads[infantry_squad].charge_declared = false
	s.squads[aethon_squad].charge_declared = false
	s.core_reactions.chargers = [enemy_squad]
	check(Core.cost_of(s, 1, aethon_squad, Core.HEROIC) == 0 and Core.error(s, 1, aethon_squad, Core.HEROIC).is_empty(), "Blackwing Mantle permits Shaan's Heroic Intervention at zero CP")
	var special := by_action(Core.choices(s, 1), "core-stratagem", aethon_squad)
	check(not special.is_empty() and Core.apply(s, 1, special).error.is_empty() and s.stratagems.uses.is_empty(), "Blackwing Mantle does not record or consume the ordinary Heroic Intervention use")
	check(not Core.error(s, 1, aethon_squad, Core.HEROIC).is_empty(), "Blackwing Mantle can be used only once per phase per army")
	Core.clear_heroic(s)
	s.unit_abilities.window = {}
	s.cp[1] = 1
	check(Core.reopen_heroic_choices(s) and not by_action(Core.choices(s, 1), "core-stratagem", infantry_squad).is_empty(), "Blackwing use does not prevent a normal Heroic Intervention on another unit")
	var ordinary := by_action(Core.choices(s, 1), "core-stratagem", infantry_squad)
	check(not ordinary.is_empty() and Core.apply(s, 1, ordinary).error.is_empty() and s.cp[1] == 0, "The ordinary intervention remains a separate 1 CP use after Blackwing Mantle")
	Core.clear_heroic(s)
	s.unit_abilities.window = {}
	s.unit_abilities.used.erase("blackwing:1")
	s.stratagems.uses = []
	s.cp[1] = 1
	s.squads[infantry_squad].charge_declared = false
	s.unit_abilities.window = {"kind": "end", "owners": [1]}
	check(Core.error(s, 1, infantry_squad, Core.HEROIC).is_empty() and Core.apply(s, 1, {"action": "core-stratagem", "model": -1, "target": infantry_squad, "value": Core.HEROIC}).error.is_empty(), "An ordinary Heroic Intervention can be used before Blackwing Mantle")
	Core.clear_heroic(s)
	s.unit_abilities.window = {}
	check(Core.reopen_heroic_choices(s) and Core.error(s, 1, aethon_squad, Core.HEROIC).is_empty() and Core.cost_of(s, 1, aethon_squad, Core.HEROIC) == 0, "Blackwing Mantle remains available after a prior Heroic Intervention elsewhere")

	print("Aethon Shaan local checks: %d failures" % failures)
	quit(1 if failures else 0)

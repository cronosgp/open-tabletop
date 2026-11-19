extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ContactMovement = preload("res://scripts/edition_11/contact_movement.gd")

const OVERLORD_ID := "40kdc:11e:necrons:overlord"
const TRANSLOCATION_OVERLORD_ID := "40kdc:11e:necrons:overlord-with-translocation-shroud"
const LYCHGUARD_ID := "40kdc:11e:necrons:lychguard"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice_calls := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func dummy_die() -> int:
	scripted_dice_calls += 1
	return 4

func run() -> void:
	test_datasheet_facts_and_admission()
	test_overlord_loadouts_and_rules()
	test_translocation_overlord_rules()
	test_lychguard_rules_and_reanimation()
	print("Necron Overlords & Lychguard checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	# 1. Overlord (000000523)
	var overlord := Profiles.profile("overlord")
	check(overlord.get("source_datasheet_id") == "000000523", "Overlord ID matches 000000523")
	check(overlord.get("points_by_models") == {1: 90}, "Overlord points are 90 for 1 model")
	check(overlord.get("base_size_source_mm") == 40, "Overlord base is 40 mm")
	check(overlord.get("stats") == {"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Overlord stats match source")
	var tachyon: Dictionary = overlord.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var blade: Dictionary = overlord.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(tachyon == {"name": "Tachyon arrow", "range_inches": 72.0, "attacks": 1, "skill": 2, "strength": 16, "ap": -5, "damage": "D6+2", "keywords": {"one-shot": true}}, "Overlord default tachyon arrow matches source")
	check(blade == {"name": "Overlord's blade", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 8, "ap": -3, "damage": 2, "keywords": {"devastating-wounds": true}}, "Overlord default Overlord's blade matches source")
	check(overlord.get("source_options", []).size() == 2 and overlord.source_options.all(func(opt: Dictionary) -> bool: return opt.get("implemented", false)), "Overlord options are marked implemented")
	check(overlord.get("pending_source_checks", []).is_empty() and overlord.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Overlord profile readiness is complete")

	# 2. Overlord with translocation shroud (000003693)
	var trans_overlord := Profiles.profile("overlord-with-translocation-shroud")
	check(trans_overlord.get("source_datasheet_id") == "000003693", "Overlord with translocation shroud ID matches 000003693")
	check(trans_overlord.get("points_by_models") == {1: 90}, "Overlord with translocation shroud points are 90")
	check(trans_overlord.get("base_size_source_mm") == 40, "Overlord with translocation shroud base is 40 mm")
	check(trans_overlord.get("stats") == {"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Overlord with translocation shroud stats match source")
	check(trans_overlord.get("supported_rule_ids", []) == ["leader", "reanimation-protocols", "resurrection-orb", "my-will-be-done", "translocation-shroud"], "Translocation Overlord supported rules match")
	check(trans_overlord.get("unsupported_abilities", []).is_empty() and trans_overlord.get("pending_source_checks", []).is_empty() and trans_overlord.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Translocation Overlord readiness is complete")

	# 3. Lychguard (000000536)
	var lychguard := Profiles.profile("lychguard")
	check(lychguard.get("source_datasheet_id") == "000000536", "Lychguard ID matches 000000536")
	check(lychguard.get("points_by_models") == {5: 80, 10: 160}, "Lychguard points are 80/160 for 5/10 models")
	check(lychguard.get("base_size_source_mm") == 32, "Lychguard base is 32 mm")
	check(lychguard.get("stats") == {"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0}, "Lychguard stats match source (no baseline invuln)")
	check(lychguard.get("ranged", []).is_empty(), "Lychguard has NO ranged weapons")
	var warscythe: Dictionary = lychguard.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(warscythe == {"name": "Warscythe", "range_inches": 0.0, "attacks": 2, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"devastating-wounds": true}}, "Lychguard default Warscythe matches source")
	var hyperphase: Dictionary = lychguard.get("additional_weapon_profiles", {}).get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(hyperphase == {"name": "Hyperphase sword", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {}}, "Lychguard additional Hyperphase sword matches source")
	check(lychguard.get("supported_rule_ids", []) == ["reanimation-protocols", "dispersion-shield", "guardian-protocols"], "Lychguard supported rules match")
	check(lychguard.get("unsupported_abilities", []).is_empty() and lychguard.get("pending_source_checks", []).is_empty() and lychguard.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Lychguard readiness is complete")

	# Admission check
	var res_o := Army.resolve("Necrons", OVERLORD_ID)
	var res_to := Army.resolve("Necrons", TRANSLOCATION_OVERLORD_ID)
	var res_lg := Army.resolve("Necrons", LYCHGUARD_ID)
	check(res_o.get("error", "").is_empty() and int(res_o.get("cost", -1)) == 90 and int(res_o.get("models", -1)) == 1, "Overlord resolves cleanly for construction")
	check(res_to.get("error", "").is_empty() and int(res_to.get("cost", -1)) == 90 and int(res_to.get("models", -1)) == 1, "Overlord with translocation shroud resolves cleanly for construction")
	check(res_lg.get("error", "").is_empty() and int(res_lg.get("cost", -1)) == 80 and int(res_lg.get("models", -1)) == 5, "Lychguard resolves cleanly for construction")

func test_overlord_loadouts_and_rules() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": OVERLORD_ID, "models": 1, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state.has("error"), "Fixture with Overlord and Lychguard materializes")
	if state.has("error"): return

	var overlord_model := -1
	var lychguard_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == OVERLORD_ID: overlord_model = m
		elif str(u.get("definition_id", "")) == LYCHGUARD_ID and lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))

	check(overlord_model >= 0, "Overlord model exists")
	var o_unit: Dictionary = state.units[overlord_model]
	var o_squad := int(o_unit.get("squad", -1))

	# Default tachyon arrow loadout has NO resurrection orb
	check(o_unit.get("wargear", []) == [], "Default Overlord has no resurrection orb in wargear")
	check(UnitAbilities.sources(state, o_squad, "resurrection-orb").is_empty(), "Resurrection Orb is not active with tachyon arrow")
	check(UnitAbilities.has(state, o_squad, "my-will-be-done"), "Overlord has My Will Be Done")
	check(UnitAbilities.damage(state, overlord_model, 3) == 2 and UnitAbilities.damage(state, overlord_model, 1) == 1, "Implacable Resilience reduces Damage by 1, min 1")

	# Leader attachment links
	check("40kdc:11e:necrons:necron-warriors" in LeaderCatalog.ATTACHMENTS[OVERLORD_ID], "Overlord can attach to Warriors")
	check("40kdc:11e:necrons:immortals" in LeaderCatalog.ATTACHMENTS[OVERLORD_ID], "Overlord can attach to Immortals")
	check("40kdc:11e:necrons:lychguard" in LeaderCatalog.ATTACHMENTS[OVERLORD_ID], "Overlord can attach to Lychguard")

	# Match preparation loadout choices
	var choices := UnitActions.necron_overlord_loadout_choices(state, 1)
	check(choices.size() == 4, "Overlord offers 4 alternate loadout packages (5 minus default)")

	# Switch to staff-of-light-and-resurrection-orb
	var change_result: Dictionary = UnitActions.apply(state, 1, {"action": "necron-overlord-loadout", "model": overlord_model, "target": o_squad, "value": "staff-of-light-and-resurrection-orb"}, Vector2.ZERO, Callable())
	check(str(change_result.get("error", "")).is_empty(), "Switched Overlord to Staff of Light + Orb")
	check(o_unit.get("wargear", []) == ["resurrection-orb"] and bool(o_unit.get("overlord_resurrection_orb", false)), "Overlord wargear has resurrection orb")
	check(UnitAbilities.sources(state, o_squad, "resurrection-orb") == [overlord_model], "Resurrection Orb is now active")

	# Switch to voidscythe (no orb)
	var change_void: Dictionary = UnitActions.apply(state, 1, {"action": "necron-overlord-loadout", "model": overlord_model, "target": o_squad, "value": "voidscythe"}, Vector2.ZERO, Callable())
	check(str(change_void.get("error", "")).is_empty(), "Switched Overlord to Voidscythe")
	check(o_unit.get("wargear", []).is_empty() and not bool(o_unit.get("overlord_resurrection_orb", false)), "Voidscythe loadout removes orb")
	check(o_unit.get("ranged_weapons", []).is_empty(), "Voidscythe has no ranged weapons")
	check(UnitAbilities.sources(state, o_squad, "resurrection-orb").is_empty(), "Resurrection Orb is inactive without orb")

	# Switch to voidscythe-and-resurrection-orb
	var change_void_orb: Dictionary = UnitActions.apply(state, 1, {"action": "necron-overlord-loadout", "model": overlord_model, "target": o_squad, "value": "voidscythe-and-resurrection-orb"}, Vector2.ZERO, Callable())
	check(str(change_void_orb.get("error", "")).is_empty(), "Switched Overlord to Voidscythe + Orb")
	check(o_unit.get("wargear", []) == ["resurrection-orb"] and bool(o_unit.get("overlord_resurrection_orb", false)), "Voidscythe + Orb adds orb")
	check(UnitAbilities.sources(state, o_squad, "resurrection-orb") == [overlord_model], "Resurrection Orb is active with Voidscythe + Orb")

	# Same loadout rejection
	var reject_same: Dictionary = UnitActions.apply(state, 1, {"action": "necron-overlord-loadout", "model": overlord_model, "target": o_squad, "value": "voidscythe-and-resurrection-orb"}, Vector2.ZERO, Callable())
	check(not str(reject_same.get("error", "")).is_empty(), "Rejects selecting the already equipped package")

	# Locked loadout rejection
	o_unit.overlord_loadout_locked = true
	var reject_locked: Dictionary = UnitActions.apply(state, 1, {"action": "necron-overlord-loadout", "model": overlord_model, "target": o_squad, "value": "staff-of-light"}, Vector2.ZERO, Callable())
	check(not str(reject_locked.get("error", "")).is_empty(), "Rejects changing loadout when locked")
	o_unit.overlord_loadout_locked = false

func test_translocation_overlord_rules() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": TRANSLOCATION_OVERLORD_ID, "models": 1, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": IMMORTALS_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state.has("error"), "Fixture with Translocation Overlord materializes")
	if state.has("error"): return

	var trans_model := -1
	var lychguard_squad := -1
	var warriors_squad := -1
	var immortals_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var def: String = str(u.get("definition_id", ""))
		if def == TRANSLOCATION_OVERLORD_ID and trans_model < 0: trans_model = m
		elif def == LYCHGUARD_ID and lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))
		elif def == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
		elif def == IMMORTALS_ID and immortals_squad < 0: immortals_squad = int(u.get("squad", -1))

	check(trans_model >= 0, "Translocation Overlord model exists")
	var t_unit: Dictionary = state.units[trans_model]
	var t_squad := int(t_unit.get("squad", -1))

	# Fixed loadout: Overlord's blade + resurrection orb
	check(t_unit.get("wargear", []) == ["resurrection-orb"], "Translocation Overlord has fixed resurrection orb in wargear")
	check(UnitAbilities.sources(state, t_squad, "resurrection-orb") == [trans_model], "Resurrection orb is active on Translocation Overlord")
	check(UnitAbilities.has(state, t_squad, "my-will-be-done"), "Translocation Overlord has My Will Be Done")
	check(UnitAbilities.has(state, t_squad, "translocation-shroud"), "Translocation Overlord has Translocation Shroud")

	# Leader attachment links
	check("40kdc:11e:necrons:necron-warriors" in LeaderCatalog.ATTACHMENTS[TRANSLOCATION_OVERLORD_ID], "Translocation Overlord can attach to Warriors")
	check("40kdc:11e:necrons:immortals" in LeaderCatalog.ATTACHMENTS[TRANSLOCATION_OVERLORD_ID], "Translocation Overlord can attach to Immortals")
	check("40kdc:11e:necrons:lychguard" in LeaderCatalog.ATTACHMENTS[TRANSLOCATION_OVERLORD_ID], "Translocation Overlord can attach to Lychguard")

	# Setup choices: Warlord eligibility and Leader attachment to Lychguard, Warriors, Immortals
	state.unit_abilities.setup_players = []
	var setup_choices := UnitActions.choices(state, 1)

	var warlord_options := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "warlord" and int(c.get("model", -1)) == trans_model)
	check(not warlord_options.is_empty(), "Translocation Overlord is projected as Warlord choice during setup")

	var attach_lych := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == trans_model and int(c.get("target", -1)) == lychguard_squad)
	var attach_war := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == trans_model and int(c.get("target", -1)) == warriors_squad)
	var attach_imm := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == trans_model and int(c.get("target", -1)) == immortals_squad)
	check(not attach_lych.is_empty(), "Translocation Overlord is projected to attach to Lychguard during setup")
	check(not attach_war.is_empty(), "Translocation Overlord is projected to attach to Necron Warriors during setup")
	check(not attach_imm.is_empty(), "Translocation Overlord is projected to attach to Immortals during setup")

	var warlord_res := UnitActions.apply(state, 1, warlord_options[0], Vector2.ZERO, Callable())
	check(str(warlord_res.get("error", "")).is_empty(), "Translocation Overlord Warlord applied cleanly via UnitActions.apply()")
	check(state.unit_abilities.warlords.get(1, -1) == trans_model and t_unit.keywords.has("WARLORD"), "Translocation Overlord is recorded as Warlord with WARLORD keyword")

	var attach_res := UnitActions.apply(state, 1, attach_lych[0], Vector2.ZERO, Callable())
	check(str(attach_res.get("error", "")).is_empty(), "Translocation Overlord attach to Lychguard applied cleanly via UnitActions.apply()")
	check(t_unit.get("attachment_role", "") == "leader" and state.squads[lychguard_squad].attached, "Translocation Overlord is attached as leader to Lychguard")

	# Test Advance with Translocation Shroud: automatic +6" without D6 roll
	state.phase = "movement"
	state.active = 1
	state.round = 1
	state.turn = 1
	scripted_dice_calls = 0
	var begin_error := C.begin_movement(state, 1, trans_model, "advance", int(state.get("revision", -1)), Callable(self, "dummy_die"))
	check(begin_error.is_empty(), "Translocation Overlord begins Advance: " + begin_error)
	check(scripted_dice_calls == 0, "Advance D6 roll is NOT made for Translocation Shroud")
	var pending_move: Dictionary = state.get("pending_move", {})
	check(bool(pending_move.get("translocation_shroud_advance", false)), "Pending move marks translocation_shroud_advance true")
	check(int(pending_move.get("raw_bonus", 0)) == 6 and int(pending_move.get("bonus", 0)) >= 6, "Advance bonus is 6 inches")

	# Translocation Shroud active during normal, advance, fall back moves
	check(Terrain.translocation_shroud_active(state, trans_model), "Translocation Shroud is active during advance move")
	check(Terrain.movement_obstacles(state, trans_model).is_empty(), "Movement obstacles are empty while Translocation Shroud is active")

	# ContactMovement clear_path sets through_models = true
	var t_pos: Vector2 = t_unit.position
	var test_dest: Vector2 = t_pos + Vector2(4.0, 0.0)
	check(ContactMovement.clear_path(state, trans_model, test_dest, 12.0), "Can move horizontally through obstacles/models")

func test_lychguard_rules_and_reanimation() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": OVERLORD_ID, "models": 1, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state.has("error"), "Fixture with Overlord and Lychguard materializes")
	if state.has("error"): return

	var overlord_model := -1
	var lychguard_models: Array[int] = []
	var lychguard_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == OVERLORD_ID: overlord_model = m
		elif str(u.get("definition_id", "")) == LYCHGUARD_ID:
			lychguard_models.append(m)
			if lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))

	check(lychguard_models.size() == 5, "5 Lychguard models materialized")

	# Default warscythe has NO invulnerable save
	var def_profile_default: Dictionary = DefenderGroups.profile(state, lychguard_models[0])
	check(int(def_profile_default.get("invulnerable_target", -1)) == 0, "Default warscythe Lychguard has 0 invulnerable target")

	# Match-prep switch to hyperphase sword and dispersion shield
	var switch_shield: Dictionary = UnitActions.apply(state, 1, {"action": "necron-lychguard-loadout", "model": lychguard_models[0], "target": lychguard_squad, "value": "hyperphase-sword-and-dispersion-shield"}, Vector2.ZERO, Callable())
	check(str(switch_shield.get("error", "")).is_empty(), "Switched Lychguard to Sword and Shield")
	for m: int in lychguard_models:
		check(bool(state.units[m].get("lychguard_dispersion_shield", false)), "All Lychguard models have dispersion shield")
		check(state.units[m].get("melee_weapons", [{}])[0].get("id", "") == "hyperphase-sword", "All Lychguard models equipped with hyperphase sword")

	# Dispersion shield gives 4+ invulnerable save
	var def_profile_shield: Dictionary = DefenderGroups.profile(state, lychguard_models[0])
	check(int(def_profile_shield.get("invulnerable_target", -1)) == 4, "Dispersion shield grants 4+ invulnerable save")

	# Switch back to warscythe
	var switch_scythe: Dictionary = UnitActions.apply(state, 1, {"action": "necron-lychguard-loadout", "model": lychguard_models[0], "target": lychguard_squad, "value": "warscythe"}, Vector2.ZERO, Callable())
	check(str(switch_scythe.get("error", "")).is_empty(), "Switched Lychguard back to Warscythes")
	check(not bool(state.units[lychguard_models[0]].get("lychguard_dispersion_shield", false)), "Dispersion shield removed")
	check(int(DefenderGroups.profile(state, lychguard_models[0]).get("invulnerable_target", -1)) == 0, "Invulnerable target restored to 0")

	# Switch to sword and shield for remaining tests
	UnitActions.apply(state, 1, {"action": "necron-lychguard-loadout", "model": lychguard_models[0], "target": lychguard_squad, "value": "hyperphase-sword-and-dispersion-shield"}, Vector2.ZERO, Callable())

	# Test Guardian Protocols:
	# Without leader attached:
	check(not UnitAbilities.noble_leading(state, lychguard_squad), "No NOBLE leading unattached Lychguard")
	check(UnitAbilities.defensive_wound_modifier(state, lychguard_squad, 6, 5, false) == 0, "No wound modifier when unattached")

	# Attach Overlord (a NOBLE) to Lychguard
	UnitActions.attach(state, overlord_model, lychguard_squad)
	check(UnitAbilities.noble_leading(state, lychguard_squad), "NOBLE is now leading Lychguard")

	# When S > T (e.g. S6 vs T5): -1 to wound
	check(UnitAbilities.defensive_wound_modifier(state, lychguard_squad, 6, 5, false) == -1, "Guardian Protocols grants -1 to Wound when S > T")
	check(UnitAbilities.defensive_wound_modifier(state, lychguard_squad, 10, 5, false) == -1, "Guardian Protocols grants -1 to Wound when S > T (S10)")

	# When S <= T (e.g. S5 vs T5, S4 vs T5): 0 modifier
	check(UnitAbilities.defensive_wound_modifier(state, lychguard_squad, 5, 5, false) == 0, "No modifier when S == T")
	check(UnitAbilities.defensive_wound_modifier(state, lychguard_squad, 4, 5, false) == 0, "No modifier when S < T")

	# Reanimation Protocols for attached Overlord + Lychguard
	check(Reanimation._supported_attachment(state, lychguard_squad), "Attached Overlord + Lychguard is a supported attachment for Reanimation")
	check(Reanimation.PROFILE_WOUNDS.get(LYCHGUARD_ID) == 2, "Lychguard profile wounds is 2")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(LYCHGUARD_ID) == [5, 10], "Lychguard model counts are 5 and 10")
	check(LYCHGUARD_ID in Reanimation.ATTACHABLE_TROOPS, "Lychguard is in ATTACHABLE_TROOPS")

	# Wound a Lychguard model to 1 wound remaining and test reanimation healing
	state.units[lychguard_models[0]].wounds = 1
	Reanimation.enable(state)
	state.reanimation.anchors = {lychguard_squad: []}
	state.reanimation.pending = {"player": 1, "remaining": [lychguard_squad], "current": {}, "results": []}
	var prep: Dictionary = Reanimation._prepare_healing(state, lychguard_squad, 2, Callable(self, "dummy_die"))
	check(prep.get("error", "").is_empty() and state.units[lychguard_models[0]].wounds == 2, "Reanimation heals wounded 2W Lychguard to max wounds")

extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")

const SKORPEKH_LORD_ID := "40kdc:11e:necrons:skorpekh-lord"
const LOKHUST_LORD_ID := "40kdc:11e:necrons:lokhust-lord"
const SKORPEKH_DESTROYERS_ID := "40kdc:11e:necrons:skorpekh-destroyers"
const LOKHUST_DESTROYERS_ID := "40kdc:11e:necrons:lokhust-destroyers"
const LOKHUST_HEAVY_ID := "40kdc:11e:necrons:lokhust-heavy-destroyers"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_datasheet_facts_and_admission()
	test_skorpekh_lord_rules()
	test_lokhust_lord_rules()
	print("Necron Destroyer Lords checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	# 1. Skorpekh Lord (000002109)
	var skorpekh := Profiles.profile("skorpekh-lord")
	check(skorpekh.get("source_datasheet_id") == "000002109", "Skorpekh Lord datasheet ID is 000002109")
	check(skorpekh.get("points_by_models") == {1: 95}, "Skorpekh Lord points are 95 for 1 model")
	check(skorpekh.get("third_plus_points_by_models") == {1: 105}, "Skorpekh Lord third-plus points are 105")
	check(skorpekh.get("base_size_source_mm") == 60, "Skorpekh Lord base is 60 mm")
	check(skorpekh.get("stats") == {
		"movement_inches": 8, "toughness": 7, "save_target": 3, "wounds": 7,
		"leadership_target": 6, "objective_control": 2, "invulnerable_target": 4
	}, "Skorpekh Lord stats match source (7W, 4++ invuln)")
	check(skorpekh.get("keywords") == ["NECRONS", "SKORPEKH LORD", "CHARACTER", "INFANTRY", "DESTROYER CULT"], "Skorpekh Lord keywords match source")
	var enmitic: Dictionary = skorpekh.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(enmitic == {
		"name": "Enmitic annihilator", "range_inches": 18.0, "attacks": 2, "skill": 2,
		"strength": 6, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}
	}, "Skorpekh Lord default ranged weapon is Enmitic annihilator")
	check(skorpekh.get("melee", []).size() == 2, "Skorpekh Lord has two default melee weapons")
	var flensing: Dictionary = skorpekh.melee[0].profiles.standard
	var harvester: Dictionary = skorpekh.melee[1].profiles.standard
	check(flensing == {
		"name": "Flensing claw", "range_inches": 0.0, "attacks": 8, "skill": 2,
		"strength": 6, "ap": -1, "damage": 1, "keywords": {}
	}, "Skorpekh Lord flensing claw profile matches source")
	check(harvester == {
		"name": "Hyperphase harvester", "range_inches": 0.0, "attacks": 4, "skill": 2,
		"strength": 10, "ap": -3, "damage": 3, "keywords": {}
	}, "Skorpekh Lord hyperphase harvester profile matches source")
	check(skorpekh.get("supported_rule_ids") == ["leader", "reanimation-protocols", "united-in-destruction", "crimson-harvest"], "Skorpekh Lord supported rules match local scope")
	check(skorpekh.get("unsupported_abilities", []).is_empty() and skorpekh.get("pending_source_checks", []).is_empty()
		and skorpekh.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Skorpekh Lord profile readiness is complete")
	var skorpekh_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": SKORPEKH_LORD_ID, "models": 1, "copies": 1}]})
	check(str(skorpekh_admit.get("error", "")).is_empty() and int(skorpekh_admit.get("total", -1)) == 95, "Skorpekh Lord is admitted to construction at 95 points")

	# 2. Lokhust Lord (000002351)
	var lokhust := Profiles.profile("lokhust-lord")
	check(lokhust.get("source_datasheet_id") == "000002351", "Lokhust Lord datasheet ID is 000002351")
	check(lokhust.get("points_by_models") == {1: 80}, "Lokhust Lord points are 80 for 1 model")
	check(lokhust.get("base_size_source_mm") == 60, "Lokhust Lord base is 60 mm")
	check(lokhust.get("stats") == {
		"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 6,
		"leadership_target": 6, "objective_control": 2, "invulnerable_target": 4
	}, "Lokhust Lord stats match source (6W, 4++ invuln)")
	check(lokhust.get("keywords") == ["NECRONS", "FLY", "MOUNTED", "CHARACTER", "DESTROYER CULT", "LOKHUST LORD"], "Lokhust Lord keywords match source")
	var staff_ranged: Dictionary = lokhust.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var staff_melee: Dictionary = lokhust.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(staff_ranged == {
		"name": "Staff of light", "range_inches": 18.0, "attacks": 3, "skill": 2,
		"strength": 5, "ap": -2, "damage": 1, "keywords": {}
	}, "Lokhust Lord default ranged weapon is Staff of light")
	check(staff_melee == {
		"name": "Staff of light", "range_inches": 0.0, "attacks": 4, "skill": 2,
		"strength": 5, "ap": -2, "damage": 1, "keywords": {}
	}, "Lokhust Lord default melee weapon is Staff of light")
	var blade: Dictionary = lokhust.get("additional_weapon_profiles", {}).get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(blade == {
		"name": "Lord’s blade", "range_inches": 0.0, "attacks": 4, "skill": 2,
		"strength": 8, "ap": -3, "damage": 2, "keywords": {"devastating-wounds": true}
	}, "Lokhust Lord additional melee weapon Lord’s blade matches source")
	check(lokhust.get("source_options", []).size() == 2 and lokhust.source_options.all(func(opt: Dictionary) -> bool: return opt.get("implemented", false)), "Lokhust Lord options are both marked implemented")
	check(lokhust.get("supported_rule_ids") == ["leader", "reanimation-protocols", "nanoscarab-amulet", "resurrection-orb", "destroyer-cult", "driven-by-hatred"], "Lokhust Lord supported rules match local scope")
	check(lokhust.get("unsupported_abilities", []).is_empty() and lokhust.get("pending_source_checks", []).is_empty()
		and lokhust.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Lokhust Lord profile readiness is complete")
	var lokhust_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": LOKHUST_LORD_ID, "models": 1, "copies": 1}]})
	check(str(lokhust_admit.get("error", "")).is_empty() and int(lokhust_admit.get("total", -1)) == 80, "Lokhust Lord is admitted to construction at 80 points")

func test_skorpekh_lord_rules() -> void:
	# 1. Multiple Melee Weapons selection
	var lord_profile := Profiles.profile("skorpekh-lord")
	var state := {
		"active": 1,
		"phase": "fight",
		"turn": 1,
		"round": 1,
		"cp": {1: 0, 2: 0},
		"pending_move": {},
		"pending_contact": {},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Skorpekh Lord Squad", "attached": false, "starting_strength": 1, "charged": false, "advanced": false, "fallen_back": false, "set_up_this_turn": false, "moved_distance": 0.0, "stats": {"toughness": 7, "save_target": 3, "wounds": 7, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}},
			2: {"owner": 2, "name": "Intercessor Squad", "attached": false, "starting_strength": 5, "charged": false, "advanced": false, "fallen_back": false, "set_up_this_turn": false, "moved_distance": 0.0, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {
				"owner": 1, "squad": 1, "definition_id": SKORPEKH_LORD_ID, "wounds": 7, "max_wounds": 7,
				"position": Vector2(0, 0), "radius": 60.0 / 50.8,
				"ranged_weapons": lord_profile.get("ranged", []).duplicate(true),
				"melee_weapons": lord_profile.get("melee", []).duplicate(true),
				"keywords": ["NECRONS", "SKORPEKH LORD", "CHARACTER", "INFANTRY", "DESTROYER CULT"]
			},
			201: {
				"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2,
				"position": Vector2(1, 0), "radius": 32.0 / 50.8,
				"keywords": ["INFANTRY"]
			}
		},
		"revision": 1
	}

	# Both ordinary melee weapons without choosing one yields an error
	var multiple_melee_plan := AttackPlan.prepare(state, 1, true, [
		{"model": 101, "target": 2, "amount": 8, "weapon": "flensing-claw", "profile": "standard"},
		{"model": 101, "target": 2, "amount": 4, "weapon": "hyperphase-harvester", "profile": "standard"}
	], false)
	check(not str(multiple_melee_plan.get("error", "")).is_empty() and str(multiple_melee_plan.error).contains("Select only one ordinary melee weapon"), "Multiple ordinary melee weapons without Extra Attacks cannot both be selected")

	# Selecting flensing claw succeeds
	var claw_plan := AttackPlan.prepare(state, 1, true, [{"model": 101, "target": 2, "amount": 8, "weapon": "flensing-claw", "profile": "standard"}], false)
	check(str(claw_plan.get("error", "")).is_empty() and claw_plan.batches.size() == 1 and claw_plan.batches[0].count == 8, "Flensing claw plans 8 attacks")

	# Selecting hyperphase harvester succeeds
	var harvester_plan := AttackPlan.prepare(state, 1, true, [{"model": 101, "target": 2, "amount": 4, "weapon": "hyperphase-harvester", "profile": "standard"}], false)
	check(str(harvester_plan.get("error", "")).is_empty() and harvester_plan.batches.size() == 1 and harvester_plan.batches[0].count == 4, "Hyperphase harvester plans 4 attacks")

	# 2. Leader Attachment to Skorpekh Destroyers
	check(LeaderCatalog.ATTACHMENTS.get(SKORPEKH_LORD_ID, []) == [SKORPEKH_DESTROYERS_ID], "Skorpekh Lord attaches exclusively to Skorpekh Destroyers")

	# 3. United in Destruction: [LETHAL HITS] in melee while leading
	# When unattached:
	check(not UnitAbilities.leading(state, 1, "united-in-destruction"), "Unattached Skorpekh Lord is not leading a unit")
	check(not claw_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Unattached Skorpekh Lord melee attacks do not have Lethal Hits")

	# Attach Skorpekh Lord to Skorpekh Destroyers:
	var skorpekh_profile := Profiles.profile("skorpekh-destroyers")
	state.squads[1].attached = true
	state.squads[1].components = [SKORPEKH_LORD_ID, SKORPEKH_DESTROYERS_ID]
	state.squads[1].starting_strength = 4
	state.units[101].attachment_role = "leader"
	for idx in range(3):
		state.units[102 + idx] = {
			"owner": 1, "squad": 1, "definition_id": SKORPEKH_DESTROYERS_ID, "wounds": 3, "max_wounds": 3,
			"attachment_role": "bodyguard", "position": Vector2(0, float(idx) + 1.0), "radius": 50.0 / 50.8,
			"ranged_weapons": [],
			"melee_weapons": skorpekh_profile.get("melee", []).duplicate(true),
			"keywords": ["NECRONS", "INFANTRY", "DESTROYER CULT"]
		}
	check(UnitAbilities.leading(state, 1, "united-in-destruction"), "Skorpekh Lord is leading when attached with living bodyguards")

	# In melee, all living models in the unit allocate attacks:
	var led_melee_plan := AttackPlan.prepare(state, 1, true, [
		{"model": 101, "target": 2, "amount": 8, "weapon": "flensing-claw", "profile": "standard"},
		{"model": 102, "target": 2, "amount": 4, "weapon": "skorpekh-hyperphase-weapons", "profile": "standard"},
		{"model": 103, "target": 2, "amount": 4, "weapon": "skorpekh-hyperphase-weapons", "profile": "standard"},
		{"model": 104, "target": 2, "amount": 4, "weapon": "skorpekh-hyperphase-weapons", "profile": "standard"}
	], false)
	check(str(led_melee_plan.get("error", "")).is_empty() and led_melee_plan.batches.size() == 2, "Led melee plan produces batches for both Skorpekh Lord and Skorpekh Destroyers")
	var lord_batch: Dictionary = led_melee_plan.batches.filter(func(b: Dictionary) -> bool: return str(b.weapon.name).contains("Flensing claw"))[0]
	var bodyguard_batch: Dictionary = led_melee_plan.batches.filter(func(b: Dictionary) -> bool: return str(b.weapon.name).contains("Skorpekh hyperphase weapons"))[0]
	check(bool(lord_batch.weapon.keywords.get("lethal-hits", false)), "United in Destruction grants Lethal Hits to Skorpekh Lord melee weapons while leading")
	check(bool(bodyguard_batch.weapon.keywords.get("lethal-hits", false)), "United in Destruction grants Lethal Hits to bodyguard melee weapons while leading")

	# When bodyguards are all destroyed:
	for idx in range(3): state.units[102 + idx].wounds = 0
	check(not UnitAbilities.leading(state, 1, "united-in-destruction"), "Skorpekh Lord stops leading when all bodyguards are destroyed")
	var sole_claw_plan := AttackPlan.prepare(state, 1, true, [{"model": 101, "target": 2, "amount": 8, "weapon": "flensing-claw", "profile": "standard"}], false)
	check(not bool(sole_claw_plan.batches[0].weapon.keywords.get("lethal-hits", false)), "Lethal Hits ends when Skorpekh Lord is no longer leading")

	# 4. Crimson Harvest
	# Reset state for charge
	state.units[101].position = Vector2(0, 0)
	state.units[201].position = Vector2(0.5, 0) # within engagement
	state.unit_abilities.window = {}
	var charge_ok := Hammer.charge_completed(state, 1, 1)
	check(charge_ok and state.unit_abilities.window.kind == Hammer.ID, "Ending a charge with Skorpekh Lord opens post-charge window")
	var crimson_choices := Hammer.choices(state, 1)
	check(crimson_choices.size() == 1 and str(crimson_choices[0].action) == Hammer.CRIMSON_HARVEST, "Mandatory Crimson Harvest target is offered without pass option when target is engaged")
	check(int(crimson_choices[0].model) == 101 and int(crimson_choices[0].target) == 2, "Crimson Harvest targets engaged enemy squad")

	# Test roll of 1: 0 mortal wounds
	var roll_seq: Array[int] = [1]
	var roller := func() -> int: return roll_seq.pop_front() if not roll_seq.is_empty() else 1
	var res1 := Hammer.resolve(state, 1, crimson_choices[0], roller)
	check(str(res1.get("error", "")).is_empty() and int(state.last_crimson_harvest.mortal_wounds) == 0 and state.unit_abilities.window.is_empty(), "Crimson Harvest roll of 1 inflicts 0 mortal wounds and completes charge")

	# Test roll of 3 (2-5): D3 mortal wounds (d3 roll of 4 -> 2 MW)
	state.unit_abilities.window = {"kind": Hammer.ID, "owners": [1], "squad": 1, "targets": [], "armoured_impact_targets": [], "wrath_targets": [], "crimson_harvest_targets": [{"model": 101, "target": 2}]}
	roll_seq.clear()
	roll_seq.append_array([3, 4]) # d6 = 3, d3_raw = 4 -> d3 = 2
	var res2 := Hammer.resolve(state, 1, crimson_choices[0], roller)
	check(str(res2.get("error", "")).is_empty() and int(state.last_crimson_harvest.mortal_wounds) == 2
		and state.unit_abilities.window.kind == Hammer.CRIMSON_HARVEST_MORTAL and int(state.unit_abilities.window.target) == 2, "Crimson Harvest roll of 3 inflicts D3 (2) mortal wounds and opens mortal allocation window")

	# Allocate 1 mortal wound
	var alloc_choices: Array = CoreReactions.mortal_allocations(state, 2, CoreReactions.CRIMSON_HARVEST_MORTAL)
	check(not alloc_choices.is_empty(), "Mortal allocations are offered for Crimson Harvest")
	var alloc_res := CoreReactions.allocate_mortal(state, 2, alloc_choices[0], func() -> int: return 1, CoreReactions.CRIMSON_HARVEST_MORTAL)
	check(str(alloc_res.get("error", "")).is_empty() and state.units[201].wounds == 1 and int(state.last_crimson_harvest.remaining) == 1, "Mortal wound allocates to target model")

	# Test roll of 6: D3+3 mortal wounds (d3 roll of 2 -> 1 + 3 = 4 MW)
	state.unit_abilities.window = {"kind": Hammer.ID, "owners": [1], "squad": 1, "targets": [], "armoured_impact_targets": [], "wrath_targets": [], "crimson_harvest_targets": [{"model": 101, "target": 2}]}
	roll_seq.clear()
	roll_seq.append_array([6, 2]) # d6 = 6, d3_raw = 2 -> d3 = 1 -> 4 MW
	var res6 := Hammer.resolve(state, 1, crimson_choices[0], roller)
	check(str(res6.get("error", "")).is_empty() and int(state.last_crimson_harvest.mortal_wounds) == 4, "Crimson Harvest roll of 6 inflicts D3+3 (4) mortal wounds")

	# 5. Reanimation Protocols
	# Standalone Skorpekh Lord
	var standalone_state := {
		"turn": 1,
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}},
		"squads": {1: {"owner": 1, "name": "Skorpekh Lord", "attached": false, "starting_strength": 1}},
		"units": {101: {"owner": 1, "squad": 1, "definition_id": SKORPEKH_LORD_ID, "wounds": 4, "max_wounds": 7, "elevation": 0.0}}
	}
	check(Reanimation.supported_unit(standalone_state, 1), "Standalone wounded Skorpekh Lord is supported by Reanimation Protocols")
	Reanimation.enable(standalone_state)
	standalone_state.reanimation.anchors = {1: []}
	standalone_state.reanimation.pending = {"player": 1, "remaining": [1], "current": {}, "results": []}
	var prep: Dictionary = Reanimation._prepare_healing(standalone_state, 1, 3, func() -> int: return 3) # D6=3 -> D3=2 wounds healed
	check(prep.get("error", "").is_empty() and standalone_state.units[101].wounds == 6, "Reanimation Protocols heals 2 wounds on Skorpekh Lord (4 -> 6)")

	# Attached Skorpekh Lord + Skorpekh Destroyers
	var attached_reanim_state := {
		"turn": 1,
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}},
		"squads": {1: {"owner": 1, "name": "Attached Skorpekhs", "attached": true, "components": [SKORPEKH_LORD_ID, SKORPEKH_DESTROYERS_ID], "starting_strength": 4}},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": SKORPEKH_LORD_ID, "wounds": 7, "max_wounds": 7, "attachment_role": "leader", "elevation": 0.0},
			102: {"owner": 1, "squad": 1, "definition_id": SKORPEKH_DESTROYERS_ID, "wounds": 2, "max_wounds": 3, "attachment_role": "bodyguard", "elevation": 0.0},
			103: {"owner": 1, "squad": 1, "definition_id": SKORPEKH_DESTROYERS_ID, "wounds": 3, "max_wounds": 3, "attachment_role": "bodyguard", "elevation": 0.0},
			104: {"owner": 1, "squad": 1, "definition_id": SKORPEKH_DESTROYERS_ID, "wounds": 3, "max_wounds": 3, "attachment_role": "bodyguard", "elevation": 0.0}
		}
	}
	check(Reanimation.supported_unit(attached_reanim_state, 1), "Attached Skorpekh Lord + Destroyers is supported by Reanimation Protocols")
	Reanimation.enable(attached_reanim_state)
	attached_reanim_state.reanimation.anchors = {1: []}
	attached_reanim_state.reanimation.pending = {"player": 1, "remaining": [1], "current": {}, "results": []}
	var att_res: Dictionary = Reanimation._prepare_healing(attached_reanim_state, 1, 1, func() -> int: return 1) # D3=1 wound
	check(att_res.get("error", "").is_empty() and attached_reanim_state.units[102].wounds == 3, "Reanimation Protocols heals wounded Skorpekh Destroyer in attached unit")

func test_lokhust_lord_rules() -> void:
	# 1. Saved Equipment: default vs replacement choices
	check(SavedEquipment.supports(LOKHUST_LORD_ID) and not SavedEquipment.is_model_scoped(LOKHUST_LORD_ID), "Lokhust Lord is supported as a copy-scoped saved equipment profile")
	var def_ctrls := SavedEquipment.controls(LOKHUST_LORD_ID)
	check(def_ctrls.size() == 2, "Lokhust Lord has 2 equipment controls (weapon and wargear)")
	check(SavedEquipment.defaults(LOKHUST_LORD_ID) == {"lokhust_lord_weapon": "staff-of-light", "lokhust_lord_wargear": "none"}, "Lokhust Lord default equipment is Staff of light and no optional wargear")

	# Prepare unit with lords-blade and nanoscarab-amulet
	var unit := {"definition_id": LOKHUST_LORD_ID, "ranged_weapons": [], "melee_weapons": []}
	SavedEquipment.prepare(unit, LOKHUST_LORD_ID, {"lokhust_lord_weapon": "lords-blade", "lokhust_lord_wargear": "nanoscarab-amulet"}, 1, 0)
	check(unit.ranged_weapons.is_empty() and unit.melee_weapons.size() == 1 and unit.melee_weapons[0].id == "lords-blade", "Lords blade replaces ranged and melee Staff of light")
	check(unit.lokhust_lord_wargear == "nanoscarab-amulet" and unit.wargear == ["nanoscarab-amulet"] and bool(unit.lokhust_lord_loadout_locked), "Nanoscarab Amulet is saved and locked")

	# Prepare unit with staff-of-light and resurrection-orb
	var unit2 := {"definition_id": LOKHUST_LORD_ID, "ranged_weapons": [], "melee_weapons": []}
	SavedEquipment.prepare(unit2, LOKHUST_LORD_ID, {"lokhust_lord_weapon": "staff-of-light", "lokhust_lord_wargear": "resurrection-orb"}, 1, 0)
	check(unit2.ranged_weapons.size() == 1 and unit2.melee_weapons.size() == 1 and unit2.ranged_weapons[0].id == "staff-of-light-lokhust-lord", "Staff of light materializes for ranged and melee")
	check(unit2.lokhust_lord_wargear == "resurrection-orb" and unit2.wargear == ["resurrection-orb"], "Resurrection Orb is saved as wargear")

	# 2. Nanoscarab Amulet: bearer-only Feel No Pain 5+
	var state := {
		"active": 1,
		"phase": "movement",
		"turn": 1,
		"round": 1,
		"cp": {1: 0, 2: 0},
		"pending_move": {},
		"pending_contact": {},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {1: [101, 102], 2: [201]}},
		"squads": {
			1: {"owner": 1, "name": "Lokhust Lord Squad", "attached": true, "starting_strength": 2, "charged": false, "advanced": false, "fallen_back": false, "set_up_this_turn": false, "moved_distance": 0.0, "components": [LOKHUST_LORD_ID, LOKHUST_DESTROYERS_ID], "stats": {"toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}},
			2: {"owner": 2, "name": "Intercessor Squad", "attached": false, "starting_strength": 5, "charged": false, "advanced": false, "fallen_back": false, "set_up_this_turn": false, "moved_distance": 0.0, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {
				"owner": 1, "squad": 1, "definition_id": LOKHUST_LORD_ID, "wounds": 6, "max_wounds": 6,
				"attachment_role": "leader", "elevation": 0.0, "position": Vector2(0, 0), "radius": 60.0 / 50.8,
				"lokhust_lord_wargear": "nanoscarab-amulet", "wargear": ["nanoscarab-amulet"],
				"keywords": ["NECRONS", "FLY", "MOUNTED", "CHARACTER", "DESTROYER CULT", "LOKHUST LORD"]
			},
			102: {
				"owner": 1, "squad": 1, "definition_id": LOKHUST_DESTROYERS_ID, "wounds": 3, "max_wounds": 3,
				"attachment_role": "bodyguard", "elevation": 0.0, "position": Vector2(0, 1), "radius": 60.0 / 50.8,
				"keywords": ["NECRONS", "MOUNTED", "DESTROYER CULT"]
			},
			201: {
				"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2,
				"position": Vector2(10, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]
			}
		},
		"revision": 1
	}
	Reanimation.enable(state)
	var lord_fnp: Variant = UnitPrevention.rules(state, 101)
	check(lord_fnp is Array and lord_fnp.has({"target": 5, "against": "any"}), "Lokhust Lord with Nanoscarab Amulet has Feel No Pain 5+")
	var bodyguard_fnp: Variant = UnitPrevention.rules(state, 102)
	check(bodyguard_fnp is Array and not bodyguard_fnp.has({"target": 5, "against": "any"}), "Bodyguard does not receive Nanoscarab Amulet Feel No Pain (bearer-only)")

	# When wargear is resurrection-orb, no FNP
	state.units[101].lokhust_lord_wargear = "resurrection-orb"
	state.units[101].wargear = ["resurrection-orb"]
	var no_fnp: Variant = UnitPrevention.rules(state, 101)
	check(no_fnp is Array and not no_fnp.has({"target": 5, "against": "any"}), "Lokhust Lord with Resurrection Orb has no Nanoscarab Amulet Feel No Pain")

	# 3. Resurrection Orb end-of-phase activation
	check(UnitActions.orb_available(state, 1), "Resurrection Orb is available when equipped on Lokhust Lord")
	state.turn = 1
	state.phase = "end"
	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	state.unit_abilities.anchors = {1: [101, 102], 2: [201]}
	state.reanimation.anchors = {1: []}
	state.reanimation.pending = {}
	state.units[102].wounds = 1 # wounded bodyguard
	state.units[101].melee_weapons = [{"id": "lords-blade", "profiles": {"standard": {"name": "Lord's blade", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 8, "ap": -3, "damage": 2, "keywords": {}}}}]
	var orb_choices := UnitActions.choices(state, 1)
	var has_orb_choice := orb_choices.any(func(c: Dictionary) -> bool: return str(c.get("action", "")) == "orb" and int(c.get("model", -1)) == 101)
	check(has_orb_choice, "Resurrection Orb offers end-of-phase D6 healing choice")
	var orb_res := UnitActions.apply(state, 1, {"action": "orb", "model": 101, "target": -1, "value": ""}, Vector2.ZERO, func() -> int: return 4) # D6=4 wounds
	check(str(orb_res.get("error", "")).is_empty() and state.units[102].wounds == 3, "Resurrection Orb activates Reanimation Protocols healing the bodyguard to full")

	# 4. Leader Attachment
	check(LeaderCatalog.ATTACHMENTS.get(LOKHUST_LORD_ID, []) == [LOKHUST_DESTROYERS_ID, LOKHUST_HEAVY_ID], "Lokhust Lord attaches to Lokhust Destroyers and Lokhust Heavy Destroyers")
	check(Reanimation.supported_unit(state, 1), "Attached Lokhust Lord + Lokhust Destroyers is supported by Reanimation Protocols")

	# Test attached with Lokhust Heavy Destroyers
	var heavy_state := {
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}},
		"squads": {1: {"owner": 1, "name": "Heavy Squad", "attached": true, "starting_strength": 2, "components": [LOKHUST_LORD_ID, LOKHUST_HEAVY_ID]}},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": LOKHUST_LORD_ID, "wounds": 6, "max_wounds": 6, "attachment_role": "leader", "elevation": 0.0},
			102: {"owner": 1, "squad": 1, "definition_id": LOKHUST_HEAVY_ID, "wounds": 4, "max_wounds": 4, "attachment_role": "bodyguard", "elevation": 0.0}
		}
	}
	check(Reanimation.supported_unit(heavy_state, 1), "Attached Lokhust Lord + Lokhust Heavy Destroyers is supported by Reanimation Protocols")

	# 5. Destroyer Cult: Critical Hits on unmodified 5+ for ranged attacks while leading
	state.phase = "shooting"
	state.unit_abilities.window = {}
	state.reanimation.pending = {}
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	var lokhust_profile := Profiles.profile("lokhust-lord")
	state.units[101].ranged_weapons = lokhust_profile.get("ranged", []).duplicate(true)
	state.units[101].melee_weapons = lokhust_profile.get("melee", []).duplicate(true)
	var ld_profile := Profiles.profile("lokhust-destroyers")
	state.units[102].ranged_weapons = ld_profile.get("ranged", []).duplicate(true)
	state.units[102].melee_weapons = ld_profile.get("melee", []).duplicate(true)

	check(UnitAbilities.leading(state, 1, "destroyer-cult"), "Lokhust Lord is leading for Destroyer Cult")
	var ranged_plan := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "staff-of-light-lokhust-lord", "profile": "standard"}], false)
	check(str(ranged_plan.get("error", "")).is_empty() and int(ranged_plan.batches[0].context.get("critical_hit_threshold", 6)) == 5, "Destroyer Cult grants Critical Hits on 5+ to led ranged attacks")

	# Melee attacks in engagement range do NOT get threshold 5
	state.units[201].position = Vector2(0.5, 0)
	var melee_plan := AttackPlan.prepare(state, 1, true, [
		{"model": 101, "target": 2, "amount": 4, "weapon": "staff-of-light-lokhust-lord", "profile": "standard"},
		{"model": 102, "target": 2, "amount": 2, "weapon": "close-combat-weapon-lokhust", "profile": "standard"}
	], false)
	check(str(melee_plan.get("error", "")).is_empty() and int(melee_plan.batches[0].context.get("critical_hit_threshold", 6)) == 6, "Destroyer Cult does not alter melee Critical Hit threshold")

	# When unattached, ranged attacks do NOT get threshold 5
	state.units[201].position = Vector2(10, 0)
	state.squads[1].attached = false
	var unattached_ranged := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "staff-of-light-lokhust-lord", "profile": "standard"}], false)
	check(str(unattached_ranged.get("error", "")).is_empty() and int(unattached_ranged.batches[0].context.get("critical_hit_threshold", 6)) == 6, "Unattached Lokhust Lord does not grant 5+ Critical Hits")
	state.squads[1].attached = true

	# 6. Driven by Hatred: Hit and Wound re-rolls against Below Half-strength enemy
	# Target Intercessors at full strength (5 of 5 models alive)
	state.squads[2].starting_strength = 5
	for mid in [202, 203, 204, 205]:
		state.units[mid] = {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(10, float(mid - 200)), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]}
	check(not Morale.below_half_strength(state, 2), "Target squad with 5 of 5 models is above half strength")
	var full_plan := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "staff-of-light-lokhust-lord", "profile": "standard"}], false)
	check(str(full_plan.get("error", "")).is_empty() and full_plan.batches[0].context.get("hit_reroll", "none") != "all"
		and full_plan.batches[0].context.get("wound_reroll", "none") != "all", "Driven by Hatred does not trigger against target above half strength")

	# Set target squad to Below Half-strength (2 of 5 models alive)
	for mid in [203, 204, 205]: state.units[mid].wounds = 0
	check(Morale.below_half_strength(state, 2), "Target squad with 2 of 5 models is Below Half-strength")

	# Lokhust Lord attacking Below Half-strength target
	var hatred_plan := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "staff-of-light-lokhust-lord", "profile": "standard"}], false)
	check(str(hatred_plan.get("error", "")).is_empty() and hatred_plan.batches[0].context.get("hit_reroll", "") == "all"
		and hatred_plan.batches[0].context.get("wound_reroll", "") == "all", "Driven by Hatred grants Hit and Wound re-rolls to Lokhust Lord against Below Half-strength target")

	# Bodyguard attacking Below Half-strength target does NOT get Driven by Hatred
	var bodyguard_attack := AttackPlan.prepare(state, 1, false, [{"model": 102, "target": 2, "amount": 1, "weapon": "gauss-cannon", "profile": "standard"}], false)
	check(str(bodyguard_attack.get("error", "")).is_empty() and bodyguard_attack.batches[0].context.get("hit_reroll", "none") != "all"
		and bodyguard_attack.batches[0].context.get("wound_reroll", "none") != "all", "Bodyguard does not receive Driven by Hatred re-rolls (model-only)")

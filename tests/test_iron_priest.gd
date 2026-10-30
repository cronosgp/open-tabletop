extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Tech = preload("res://scripts/edition_11/techmarine.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const IRON_PRIEST_ID := "40kdc:11e:adeptus-astartes:iron-priest"
const BALLISTUS_ID := "40kdc:11e:adeptus-astartes:ballistus-dreadnought"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int: return 6

func entry(name: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}

func fixture() -> Dictionary:
	var lists := F.current_marine_selections()
	lists[1].entries = [entry("iron-priest"), entry("ballistus-dreadnought"), entry("intercessor-squad", 5)]
	lists[2].entries = [entry("intercessor-squad", 5), entry("redemptor-dreadnought")]
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-18, 16) if state.units[model].owner == 1 else Vector2(18, 16)
	state.phase = "movement"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.combat_doctrines.selected_turn[1] = 3
	state.awakened_dynasty.pending = []
	return state

func find(state: Dictionary, identity: String, owner: int = 1) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and Tech.identity(state.units[model]) == identity: return model
	return -1

func select(state: Dictionary, action: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, 1):
		if option.action == action: return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The current decision does not project the submitted Iron Priest choice."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, roller)

func ranged_plan(state: Dictionary, squad: int, model: int, target: int, weapon_id: String, profile_id: String) -> Dictionary:
	var selected := Equipment.select(state, model, false, weapon_id, profile_id)
	if not str(selected.get("error", "")).is_empty(): return selected
	return C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon_id, "profile": profile_id}], true)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("iron-priest")
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000000306" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764", "Iron Priest cites the local Space Wolves 11e export slice")
	check(profile.points == 60 and profile.points_by_models == {1: 60} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 16.0 / 25.4), "Iron Priest cost, fixed one-model composition and 32 mm base match the local export")
	check(profile.stats == {"movement_inches": 7, "toughness": 5, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Iron Priest characteristics match the local export")
	check(profile.keywords == ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TECHMARINE"], "Iron Priest preserves all exported keywords")
	check(profile.ranged.size() == 1 and profile.ranged[0].profiles.size() == 2 and profile.melee.size() == 1 and profile.get("options", {}).is_empty(), "The fixed sheet has two Helfrost Pistol profiles, one melee weapon and no options")
	check(AbilityCatalog.RULES.get("iron-priest", []) == ["leader", "combat-doctrines", "transhuman-strategist", "gift-of-the-iron-wolf", "iron-priest-lone-operative", "judgement-of-the-omnissiah"], "All Iron Priest abilities are registered")
	check(Links.targets("iron-priest") == ["intercessor-squad", "wolf-guard-headtakers", "blood-claws", "assault-intercessor-squad", "grey-hunters"], "Iron Priest Leader endpoints match its local datasheet")
	check("000000306" in Enhancements.RECORDS[Enhancements.TARGET_AUGURY_WEB].get("source_datasheet_ids", []) and not Enhancements.valid_for(IRON_PRIEST_ID, Enhancements.TARGET_AUGURY_WEB, Enhancements.MEDUSA_WRATH), "Target Augury Web preserves the source link but stays unavailable until its Iron Priest action route is supported")
	check("000000306" in Enhancements.RECORDS[Enhancements.ADEPT_OF_THE_OMNISSIAH].get("source_datasheet_ids", []) and not Enhancements.valid_for(IRON_PRIEST_ID, Enhancements.ADEPT_OF_THE_OMNISSIAH, Enhancements.MEDUSA_WRATH), "Adept of the Omnissiah preserves the source link but stays unavailable until its Iron Priest reaction route is supported")
	check(Enhancements.valid_for("40kdc:11e:adeptus-astartes:techmarine", Enhancements.TARGET_AUGURY_WEB, Enhancements.MEDUSA_WRATH) and Enhancements.valid_for("40kdc:11e:adeptus-astartes:techmarine", Enhancements.ADEPT_OF_THE_OMNISSIAH, Enhancements.MEDUSA_WRATH), "The existing Techmarine enhancement routes remain selectable")
	check(Catalog.current_catalog_choice({"id": IRON_PRIEST_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 60}], "Current construction exposes the source's fixed Iron Priest composition and cost")
	var state := fixture()
	check(not state.has("error"), "Iron Priest fixture could not be admitted")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var priest := find(state, "iron-priest")
	var vehicle := find(state, "ballistus-dreadnought")
	var enemy := find(state, "intercessor-squad", 2)
	var bodyguard := find(state, "intercessor-squad")
	check(priest > 0 and vehicle > 0 and enemy > 0 and bodyguard > 0, "Iron Priest rules fixture is missing a required unit")
	if priest < 0 or vehicle < 0 or enemy < 0 or bodyguard < 0:
		quit(1)
		return
	check(C.UnitAbilities.has(state, int(state.units[priest].squad), "leader") and C.UnitAbilities.has(state, int(state.units[priest].squad), "gift-of-the-iron-wolf") and C.UnitAbilities.has(state, int(state.units[priest].squad), "iron-priest-lone-operative") and C.UnitAbilities.has(state, int(state.units[priest].squad), "judgement-of-the-omnissiah"), "Admitted Iron Priest materializes its Leader and three datasheet abilities")
	var warlord_lists := F.current_marine_selections()
	warlord_lists[1].entries = [entry("iron-priest"), entry("intercessor-squad", 5)]
	warlord_lists[2].entries = [entry("intercessor-squad", 5)]
	var warlord_state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, warlord_lists)
	var warlord_priest := find(warlord_state, "iron-priest") if not warlord_state.has("error") else -1
	warlord_state.phase = "deployment"
	warlord_state.active = 1
	check(warlord_priest > 0 and C.UnitActions.choices(warlord_state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == warlord_priest), "Iron Priest is eligible to be Warlord for Transhuman Strategist")
	var pistol_modes := {"dispersed": {"skill": 0, "strength": 4, "ap": -1, "damage": 1, "attacks": 3}, "focused": {"skill": 2, "strength": 6, "ap": -3, "damage": 3, "attacks": 1}}
	for mode: String in pistol_modes:
		var selected_weapon := Equipment.select(state, priest, false, "helfrost-pistol", mode)
		check(str(selected_weapon.get("error", "")).is_empty(), "Helfrost Pistol %s is selectable" % mode)
		if not str(selected_weapon.get("error", "")).is_empty(): continue
		for stat: String in pistol_modes[mode]: check(selected_weapon.stats.get(stat) == pistol_modes[mode][stat], "Helfrost Pistol %s %s matches the local export" % [mode, stat])
	var hammer := Equipment.select(state, priest, true, "tempest-hammer-servo-arm", "standard")
	check(str(hammer.get("error", "")).is_empty() and hammer.stats.get("attacks") == 4 and hammer.stats.get("skill") == 4 and hammer.stats.get("strength") == 8 and hammer.stats.get("ap") == -2 and hammer.stats.get("damage") == 3, "Tempest Hammer and Servo-arm matches the local export")
	# The local common Marine catalog has no Space Wolves Vehicle profile yet. Add the faction keyword only to this isolated rules fixture.
	state.units[vehicle].keywords.append("SPACE WOLVES")
	state.units[priest].position = Vector2.ZERO
	state.units[vehicle].position = Vector2(3.0, 0)
	check(Tech.vehicle_targets(state, priest).has(vehicle) and C.UnitAbilities.lone_operative_active(state, priest), "Gift and Lone Operative recognize a nearby friendly SPACE WOLVES VEHICLE")
	state.units[vehicle].keywords.erase("SPACE WOLVES")
	check(not Tech.vehicle_targets(state, priest).has(vehicle) and not C.UnitAbilities.lone_operative_active(state, priest), "An ordinary Adeptus Astartes Vehicle does not satisfy the Space Wolves restriction")
	state.units[vehicle].keywords.append("SPACE WOLVES")
	var exact_edge_distance: float = 3.0 + float(state.units[priest].radius) + float(state.units[vehicle].radius)
	state.units[vehicle].position = Vector2(exact_edge_distance, 0)
	check(absf(Tech.Geometry.edge(state.units[priest], state.units[vehicle]) - 3.0) <= 0.0002 and Tech.vehicle_targets(state, priest).has(vehicle), "Iron Priest range uses base edges and includes the 3-inch boundary")
	state.units[vehicle].position = Vector2(exact_edge_distance + 0.01, 0)
	check(not Tech.vehicle_targets(state, priest).has(vehicle) and not C.UnitAbilities.lone_operative_active(state, priest), "Iron Priest abilities stop immediately beyond 3 inches")
	state.units[vehicle].position = Vector2(3.0, 0)
	state.units[vehicle].wounds = int(state.units[vehicle].max_wounds) - 2
	var start_move_error := C.begin_movement(state, 1, priest, "normal", state.revision)
	check(start_move_error.is_empty() and state.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Gift opens through the normal start-of-move flow")
	var gift := select(state, "gift-of-the-iron-wolf")
	check(not gift.is_empty(), "Gift offers the nearby Space Wolves Vehicle")
	if not gift.is_empty():
		var rejected := submit_choice(state, 2, gift, six)
		check(not str(rejected.get("error", "")).is_empty(), "The opponent cannot submit the Iron Priest's movement choice")
		gift = select(state, "gift-of-the-iron-wolf")
		var result := submit_choice(state, 1, gift, six)
		check(str(result.get("error", "")).is_empty() and int(state.units[vehicle].wounds) == int(state.units[vehicle].max_wounds) and Tech.modifier_ignore_active(state, vehicle), "Gift heals D3 wounds, capped at the Vehicle's maximum (result=%s wounds=%d/%d)" % [str(result), int(state.units[vehicle].wounds), int(state.units[vehicle].max_wounds)])
		check(Tech.modifier_ignore_active(state, vehicle), "Gift protects the Vehicle from Hit and Wound modifiers")
		check(not Tech.vehicle_targets(state, priest).has(vehicle), "A Vehicle model already selected by Gift is unavailable again this phase")
	check(not state.unit_abilities.window.size() or state.unit_abilities.window.get("kind", "") != "blessings-of-the-omnissiah", "Gift resumes the pending movement flow")
	state.turn += 2
	check(not Tech.modifier_ignore_active(state, vehicle), "Gift protection ends at the owner's next Movement phase")

	state = fixture()
	priest = find(state, "iron-priest")
	vehicle = find(state, "ballistus-dreadnought")
	enemy = find(state, "intercessor-squad", 2)
	var target_squad := int(state.units[enemy].squad)
	var vehicle_squad := int(state.units[vehicle].squad)
	state.units[vehicle].keywords.append("SPACE WOLVES")
	state.units[vehicle].position = Vector2.ZERO
	for model: int in C.living(state, target_squad): state.units[model].position = Vector2(2.8, 0)
	state.units[priest].position = Vector2(4.2, 0)
	state.phase = "shooting"
	state.active = 1
	check(Tech.judgement_applies(state, priest, target_squad), "Judgement sees the enemy unit engaged with a friendly Space Wolves Vehicle")
	check(not Tech.judgement_applies(state, bodyguard, target_squad), "Judgement is limited to the Iron Priest model's attacks")
	var plan := ranged_plan(state, int(state.units[priest].squad), priest, target_squad, "helfrost-pistol", "focused")
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1 and plan.batches[0].context.get("wound_reroll", "") == "all", "Iron Priest attack planning allows re-rolling all Wound rolls")
	check(Attacks.reroll_wound(6, 4, 0, {"keywords": {}}, {"wound_reroll": "all"}), "The all-Wound-roll mode permits re-rolling a successful Wound roll")
	state.units[vehicle].keywords.erase("SPACE WOLVES")
	check(not Tech.judgement_applies(state, priest, target_squad), "Judgement does not apply when the engaged Vehicle lacks SPACE WOLVES")
	print("Iron Priest checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

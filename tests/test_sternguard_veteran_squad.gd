extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "sternguard-veteran-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:sternguard-veteran-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("captain"), entry(UNIT, 5), entry(UNIT, 10)]
	result[2].entries = [entry(UNIT, 5), entry(UNIT, 10)]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func find_model(state: Dictionary, identity: String, owner: int = 1) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return model
	return -1

func model_for(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in C.living(state, squad):
		if C.UnitAbilities.identity(state.units[model]) == UNIT and bool(state.units[model].get("sergeant", false)) == sergeant:
			return model
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true,
		"awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false
	}, lists())
	if state.has("error"):
		return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	return state

func choice_for(state: Dictionary, owner: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func apply_choice(state: Dictionary, action: String, model: int, value: String) -> String:
	var choice := choice_for(state, 1, action, model, value)
	if choice.is_empty(): return "Missing projected %s=%s choice for model %d." % [action, value, model]
	return str(PublicUnitCommand.submit(state, 1, choice).get("error", ""))

func check_model_weapons(state: Dictionary, model: int, target: int, label: String) -> void:
	var loadout := {
		"ranged": state.units[model].get("ranged_weapons", []).duplicate(true),
		"melee": state.units[model].get("melee_weapons", []).duplicate(true)
	}
	var issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, loadout, model, target)
	check(issues.is_empty(), "%s profiles resolve through Equipment and AttackPlan: %s" % [label, str(issues)])

func place_enemy(state: Dictionary, squad: int, distance: float) -> void:
	var source := model_for(state, find_squad(state, 1, UNIT), true)
	for model: int in C.living(state, squad):
		state.units[model].position = state.units[source].position + Vector2(distance + state.units[source].radius + state.units[model].radius, 0.0)

func declaration(model: int, target: int, weapon: String, profile: String) -> Array[Dictionary]:
	return [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile}]

func check_profile(profile: Dictionary) -> void:
	check(profile.get("name", "") == "Sternguard Veteran Squad" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000002255" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile matches the shared-book identity and retained export stamp")
	check(profile.get("models", -1) == 5 and profile.get("points_by_models", {}) == {5: 105, 10: 210} and profile.get("third_plus_points_by_models", {}) == {5: 120, 10: 225}, "Five/ten-model compositions and both source cost tiers match the export")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 16.0 / 25.4) and profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "The shared 32 mm base and all seven characteristics match")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "Shared-book keywords omit conditional Deathwing")
	check(profile.get("default_loadout_by_role", {}) == {
		"Sternguard Veteran Sergeant": {"Artificer Firearm": 1, "Bolt Pistol": 1, "Chainsword": 1},
		"Sternguard Veteran": {"Artificer Firearm": 1, "Bolt Pistol": 1, "Ceramite Fists": 1}
	}, "Sergeant and Veteran defaults retain their distinct melee weapons")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["artificer-firearm", "bolt-pistol"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["ceramite-fists"], "Default ranged and Veteran melee weapons match the sheet")
	check(profile.ranged[0].profiles.infernus == {"name": "Artificer Firearm - Infernus", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "rapid-fire": 2}}, "Infernus profile matches its source stats and traits")
	check(profile.ranged[0].profiles.purgatus == {"name": "Artificer Firearm - Purgatus", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 2, "keywords": {"assault": true, "rapid-fire": 1}}, "Purgatus profile matches its source stats and traits")
	check(profile.ranged[0].profiles.damnatus == {"name": "Artificer Firearm - Damnatus", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 9, "ap": -3, "damage": "D3+2", "keywords": {"assault": true, "melta": 2}}, "Damnatus profile retains Assault and Melta 2")
	check(profile.ranged[1].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol matches the source")
	check(profile.melee[0].profiles.standard == {"name": "Ceramite Fists", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}, "Ceramite Fists match the source")
	var heavy: Dictionary = Profiles.sternguard_gun("heavy").profiles.standard
	check(heavy == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 2, "sustained-hits": 1}}, "Optional Heavy Bolter is the Sternguard Strength 5 profile")
	var pyre: Dictionary = Profiles.sternguard_gun("pyre").profiles.standard
	check(pyre == {"name": "Pyrecannon", "range_inches": 12.0, "attacks": 4, "skill": 0, "strength": 6, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}, "Optional Pyrecannon retains Torrent and Blast 2")
	check(Profiles.sternguard_melee("fist").profiles.standard == {"name": "Power Fist", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}, "Sergeant Power Fist matches the source")
	check(Profiles.sternguard_melee("power").profiles.standard == {"name": "Power Weapon", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {}}, "Sergeant Power Weapon matches the source")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["veteran-marksmen"], "Veteran Marksmen is registered to this datasheet")

func run() -> void:
	check_profile(Profiles.profile(UNIT))
	var state := fixture()
	check(not state.has("error"), "Current Marine catalogs admit Sternguard for both players: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Sternguard Veteran Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, UNIT, 5)
	var large := find_squad(state, 1, UNIT, 10)
	var enemy_small := find_squad(state, 2, UNIT, 5)
	var enemy_large := find_squad(state, 2, UNIT, 10)
	var captain := find_model(state, "captain")
	check(small > 0 and large > 0 and enemy_small > 0 and enemy_large > 0 and captain >= 0, "Both model sizes materialize from both catalogs with an available Captain and enemy targets")
	if small < 0 or large < 0 or enemy_small < 0 or enemy_large < 0 or captain < 0:
		print("Sternguard Veteran Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(state.training_points[1] == 405 and state.squads[small].training_cost == 105 and state.squads[large].training_cost == 210 and state.squads[enemy_small].training_cost == 105 and state.squads[enemy_large].training_cost == 210 and C.living(state, small).size() == 5 and C.living(state, large).size() == 10 and C.living(state, enemy_large).size() == 10, "Both catalogs materialize exact five/ten model sizes and first-two prices")
	for model: int in C.living(state, small) + C.living(state, large) + C.living(state, enemy_small) + C.living(state, enemy_large):
		check(is_equal_approx(float(state.units[model].radius), 16.0 / 25.4) and "DEATHWING" not in state.units[model].keywords, "Model %d uses the common-book base and conditional keyword boundary" % model)
	check(state.units[model_for(state, small, true)].melee_weapons[0].id == "chainsword" and state.units[model_for(state, small, false)].melee_weapons[0].id == "ceramite-fists", "Materialized Sergeant and Veteran use separate melee defaults")
	var catalog := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 5, "cost": 105, "third_plus_cost": 120}, {"models": 10, "cost": 210, "third_plus_cost": 225}], "Consolidated catalog retains both sizes and source costs")
	check(Roster.POINTS[UNIT].get("sizes", {}) == {5: 105, 10: 210} and Roster.POINTS[UNIT].get("third_plus_sizes", {}) == {5: 120, 10: 225}, "Roster pricing preserves first-two and third-plus cost tiers")
	var roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), entry(UNIT, 5), entry(UNIT, 10)]}
	check(C.RosterValidation.admit(roster).get("error", "").is_empty(), "The local Incursion path admits two source-sized Sternguard copies")
	roster.entries.append(entry(UNIT, 5))
	check(not str(C.RosterValidation.admit(roster).get("error", "")).is_empty(), "The local Incursion path rejects a third non-Battleline copy")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0) == 2, "Catalog exposes only the checked scope and local two-copy ceiling")
	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader] and not SupportAttachments.BODYGUARDS.has(leader): source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["adrax-agatone", "captain", "captain-titus", "chaplain", "chief-librarian-tigurius", "kor-sarro-khan", "librarian", "marneus-calgar"], "All eight common-book Leader identities match the source link map: %s" % str(source_leaders))
	var source_supports: Array[String] = []
	for support: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[support]: source_supports.append(support)
	source_supports.sort()
	check(source_supports == ["ancient", "apothecary", "judiciar", "kaius-konorius", "lieutenant", "wardens-of-ultramar"], "All six common-book Supported by identities match the source link map: %s" % str(source_supports))
	check(C.UnitActions.attachment_allowed(state, captain, small), "Captain attachment is accepted for Sternguard")
	C.UnitActions.attach(state, captain, small)
	check(state.units[captain].squad == small and C.UnitAbilities.has(state, small, "veteran-marksmen"), "Attached Captain joins the bodyguard and living Sternguard grants Veteran Marksmen")

	var sergeant := model_for(state, small, true)
	var trooper := model_for(state, small, false)
	check_model_weapons(state, sergeant, enemy_small, "Default Sergeant firearm, pistol and Chainsword")
	check_model_weapons(state, trooper, enemy_small, "Default Veteran firearm, pistol and Ceramite Fists")
	check(choice_for(state, 1, "sternguard-gun", sergeant, "heavy").is_empty() and choice_for(state, 1, "sternguard-gun", sergeant, "pyre").is_empty(), "Sergeant is excluded from the per-five-model ranged replacement")
	check(choice_for(state, 1, "sternguard-melee", trooper, "fist").is_empty(), "Sergeant melee choices are restricted away from ordinary Veterans")
	var melee_choices := C.unit_choices(state, 1).filter(func(option: Dictionary) -> bool: return option.get("action", "") == "sternguard-melee" and int(option.get("model", -1)) == sergeant)
	check(melee_choices.map(func(option: Dictionary) -> String: return str(option.get("value", ""))) == ["chain", "fist", "power"], "Sergeant exposes the two replacements and restore choice through setup")
	var heavy_choice := choice_for(state, 1, "sternguard-gun", trooper, "heavy")
	check(not heavy_choice.is_empty(), "Five-model unit exposes one special weapon choice on an ordinary Veteran")
	if heavy_choice.is_empty():
		print("Sternguard Veteran Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var before_invalid := var_to_bytes(state)
	var forged := heavy_choice.duplicate(true)
	forged.value = "plasma-cannon"
	check(not PublicUnitCommand.error(state, 1, forged).is_empty() and before_invalid == var_to_bytes(state), "Forged equipment value is rejected without mutation")
	check(not PublicUnitCommand.error(state, 2, heavy_choice).is_empty() and before_invalid == var_to_bytes(state), "The opposing player cannot change the Sternguard loadout")
	check(apply_choice(state, "sternguard-gun", trooper, "heavy").is_empty() and state.units[trooper].ranged_weapons[0].id == "heavy-bolter", "Public setup command equips the Heavy Bolter")
	check_model_weapons(state, trooper, enemy_small, "Optional Heavy Bolter loadout")
	var small_second_trooper := -1
	for model: int in C.living(state, small):
		if C.UnitAbilities.identity(state.units[model]) == UNIT and not bool(state.units[model].get("sergeant", false)) and model != trooper:
			small_second_trooper = model
			break
	check(small_second_trooper >= 0 and choice_for(state, 1, "sternguard-gun", small_second_trooper, "heavy").is_empty(), "Five-model unit retains a single special weapon allowance after an attached Character joins")
	check(apply_choice(state, "sternguard-gun", trooper, "pyre").is_empty() and state.units[trooper].ranged_weapons[0].id == "pyrecannon", "Special weapon can change type while the allowance is full")
	check_model_weapons(state, trooper, enemy_small, "Optional Pyrecannon loadout")
	check(apply_choice(state, "sternguard-gun", trooper, "firearm").is_empty() and state.units[trooper].ranged_weapons[0].id == "artificer-firearm" and not choice_for(state, 1, "sternguard-gun", trooper, "pyre").is_empty(), "Restoring the Artificer Firearm reopens the special weapon slot")
	check(apply_choice(state, "sternguard-gun", trooper, "pyre").is_empty(), "The reopened special weapon slot can be used again")
	var large_veterans: Array[int] = []
	for model: int in C.living(state, large):
		if C.UnitAbilities.identity(state.units[model]) == UNIT and not bool(state.units[model].get("sergeant", false)): large_veterans.append(model)
	check(large_veterans.size() == 9 and apply_choice(state, "sternguard-gun", large_veterans[0], "heavy").is_empty() and apply_choice(state, "sternguard-gun", large_veterans[1], "pyre").is_empty() and choice_for(state, 1, "sternguard-gun", large_veterans[2], "heavy").is_empty(), "Ten-model unit allows two, and only two, ordinary-model replacements")
	check_model_weapons(state, model_for(state, large, false), enemy_large, "Ten-model Pyrecannon loadout")
	check(apply_choice(state, "sternguard-melee", sergeant, "fist").is_empty() and state.units[sergeant].melee_weapons[0].id == "power-fist", "Sergeant can replace the Chainsword with a Power Fist")
	check_model_weapons(state, sergeant, enemy_small, "Sergeant Power Fist loadout")
	check(apply_choice(state, "sternguard-melee", sergeant, "power").is_empty() and state.units[sergeant].melee_weapons[0].id == "power-weapon", "Sergeant can switch to a Power Weapon")
	check_model_weapons(state, sergeant, enemy_small, "Sergeant Power Weapon loadout")
	check(apply_choice(state, "sternguard-melee", sergeant, "chain").is_empty() and state.units[sergeant].melee_weapons[0].id == "chainsword", "Sergeant can restore the Chainsword")

	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	place_enemy(state, enemy_large, 6.0)
	var large_pyrecannon_model := large_veterans[1]
	var pyrecannon := C.AttackPlan.prepare(state, large, false, declaration(large_pyrecannon_model, enemy_large, "pyrecannon", "standard"), true)
	check(pyrecannon.get("error", "").is_empty() and pyrecannon.batches.size() == 1 and pyrecannon.batches[0].count == 8 and pyrecannon.batches[0].weapon.keywords.torrent, "Pyrecannon Blast 2 adds attacks against the ten-model unit and keeps Torrent: %s" % str(pyrecannon))
	place_enemy(state, enemy_small, 6.0)
	var firearm := C.AttackPlan.prepare(state, small, false, declaration(sergeant, enemy_small, "artificer-firearm", "infernus"), true)
	check(firearm.get("error", "").is_empty() and firearm.batches[0].count == 4 and firearm.batches[0].context.get("hit_reroll", "none") == "ones", "Infernus Rapid Fire 2 and Veteran Marksmen enter the real attack plan")
	var purgatus := C.AttackPlan.prepare(state, small, false, declaration(sergeant, enemy_small, "artificer-firearm", "purgatus"), true)
	check(purgatus.get("error", "").is_empty() and purgatus.batches[0].count == 2 and purgatus.batches[0].weapon.strength == 7 and purgatus.batches[0].weapon.damage == 2, "Purgatus Rapid Fire 1 and profile stats resolve")
	var damnatus := C.AttackPlan.prepare(state, small, false, declaration(sergeant, enemy_small, "artificer-firearm", "damnatus"), true)
	check(damnatus.get("error", "").is_empty() and damnatus.batches[0].weapon.damage == "D3+4", "Damnatus gains Melta 2 at the inclusive half-range boundary")
	place_enemy(state, enemy_small, 6.02)
	damnatus = C.AttackPlan.prepare(state, small, false, declaration(sergeant, enemy_small, "artificer-firearm", "damnatus"), true)
	check(damnatus.get("error", "").is_empty() and damnatus.batches[0].weapon.damage == "D3+2", "Damnatus loses Melta beyond half range")
	state.squads[small].advanced = true
	check(enemy_small in C.AttackPlan.legal_targets(state, sergeant, false, "artificer-firearm", "infernus") and enemy_small in C.AttackPlan.legal_targets(state, sergeant, false, "artificer-firearm", "damnatus"), "All Artificer profiles retain Assault after Advance")
	state.squads[small].advanced = false
	var attached_gun: Dictionary = state.units[captain].ranged_weapons[0]
	var attached_profile := str(attached_gun.profiles.keys()[0])
	var attached_plan := C.AttackPlan.prepare(state, small, false, declaration(captain, enemy_small, str(attached_gun.id), attached_profile), true)
	check(attached_plan.get("error", "").is_empty() and attached_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Veteran Marksmen also affects the attached Leader's ranged attacks")
	var melee_state := fixture()
	var melee_squad := find_squad(melee_state, 1, UNIT, 5)
	var melee_target := find_squad(melee_state, 2, UNIT, 5)
	var melee_model := model_for(melee_state, melee_squad, false)
	var ordinary_melee: Dictionary = melee_state.units[melee_model].melee_weapons[0]
	melee_state.phase = "fight"
	melee_state.active = 1
	melee_state.unit_abilities.phase_key = C.UnitActions.key(melee_state)
	for model: int in C.living(melee_state, melee_squad): melee_state.units[model].position = Vector2(-30.0, 20.0)
	melee_state.units[melee_model].position = Vector2.ZERO
	for model: int in C.living(melee_state, melee_target):
		melee_state.units[model].position = Vector2(1.75 + melee_state.units[melee_model].radius + melee_state.units[model].radius, 0.0) if model == C.living(melee_state, melee_target)[0] else Vector2(30.0, 20.0)
	var melee_declaration := declaration(melee_model, melee_target, str(ordinary_melee.id), "standard")
	melee_declaration[0].amount = int(ordinary_melee.profiles.standard.attacks)
	var melee_plan := C.AttackPlan.prepare(melee_state, melee_squad, true, melee_declaration, true)
	check(melee_plan.get("error", "").is_empty() and melee_plan.batches[0].context.get("hit_reroll", "none") == "none", "Veteran Marksmen does not reroll melee hits: %s" % str(melee_plan))

	var gun: Dictionary = purgatus.batches[0].weapon.duplicate(true)
	gun.attacks = 1
	var target := {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}
	var dice: Array = [1, 4, 1]
	var resolved := C.Attacks.resolve(gun, target, {"weapon_count": 1, "hit_reroll": "ones"}, func() -> int: return dice.pop_front())
	check(resolved.get("error", "").is_empty() and resolved.hits == 1 and dice.is_empty(), "Veteran Marksmen replaces one natural 1 and resolves the replacement")
	dice = [1, 1]
	resolved = C.Attacks.resolve(gun, target, {"weapon_count": 1, "hit_reroll": "ones"}, func() -> int: return dice.pop_front())
	check(resolved.get("error", "").is_empty() and resolved.hits == 0 and dice.is_empty(), "A replacement natural 1 is not rerolled again")
	state.phase = "movement"
	state.active = 2
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.core_reactions.overwatch = {"phase_key": C.CoreReactions.phase_key(state), "squad": small, "player": 1}
	var snap := C.AttackPlan.prepare(state, small, false, declaration(sergeant, enemy_small, "artificer-firearm", "infernus"), true)
	check(C.CoreReactions.overwatch_shooter(state, small) and snap.get("error", "").is_empty() and snap.batches[0].context.get("hit_reroll", "none") == "none" and snap.batches[0].context.snap_shooting, "Veteran Marksmen does not bypass the Snap Shooting reroll prohibition: %s" % str(snap))
	for model: int in C.living(state, small): state.units[model].wounds = 0
	check(not C.UnitAbilities.has(state, small, "veteran-marksmen"), "Destroyed Sternguard no longer supplies Veteran Marksmen")
	check(C.unit_choices(state, 1).all(func(option: Dictionary) -> bool: return option.get("action", "") not in ["sternguard-gun", "sternguard-melee"]), "Equipment preparation choices close after the setup phase")
	print("Sternguard Veteran Squad checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

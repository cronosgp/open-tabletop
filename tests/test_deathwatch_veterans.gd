extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "deathwatch-veterans"
const UNIT_ID := "40kdc:11e:adeptus-astartes:deathwatch-veterans"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry(UNIT, 5), entry(UNIT, 10), entry("captain")]
	result[2].entries = [entry(UNIT, 5), entry("captain")]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}
	}, lists())

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

func model_role(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in models_for(state, squad):
		if bool(state.units[model].get("sergeant", false)) == sergeant: return model
	return -1

func profile_weapon(category: String, weapon_id: String, profile_name: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_name, {})
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_name, {})
	return {}

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func has_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> bool:
	return not find_choice(state, owner, action, squad, model, value).is_empty()

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	var selected := find_choice(state, owner, action, squad, model, value)
	if selected.is_empty(): return {"error": "Missing projected Deathwatch choice %s/%s for model %d." % [action, value, model]}
	return PublicUnitCommand.submit(state, owner, selected)

func declaration(model: int, target: int, weapon: String, profile_name: String = "standard") -> Array[Dictionary]:
	return [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile_name}]

func place_for_attack(state: Dictionary, shooter: int, target_squad: int) -> void:
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-30.0, 20.0) if int(state.units[model].owner) == 1 else Vector2(30.0, 20.0)
	state.units[shooter].position = Vector2.ZERO
	var target_models := C.living(state, target_squad)
	if not target_models.is_empty():
		var first_target: int = target_models[0]
		state.units[first_target].position = Vector2(11.5, 0.0)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	var snapshot_hash := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
	var slice_hash := "2ea710d11525e1ac9bb5d38cd5ea4b20f8dbcc36d615cd7c4f485cdf3f77ba58"
	check(profile.get("name") == "Deathwatch Veterans" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002783", "The runtime profile maps to the exact Deathwatch source identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == snapshot_hash and profile.get("source_slice_manifest_sha256") == slice_hash, "The profile records the verified export snapshot and source-slice hashes")
	check(profile.get("points_by_models", {}) == {5: 115, 10: 220} and profile.get("models") == 5 and profile.get("base_size_source_mm") == 32, "The source-priced five/ten-model sizes and 32 mm bases are recorded")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Exported shared model characteristics match both roles")
	check(["ADEPTUS ASTARTES", "DEATHWATCH", "BATTLELINE", "INFANTRY", "IMPERIUM", "EXPLOSIVES", "KILL TEAM"].all(func(keyword: String) -> bool: return keyword in profile.get("keywords", [])), "The faction and datasheet keywords are present")
	check(profile_weapon("ranged", "boltgun") == {"name": "Boltgun", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 1}}, "The default Boltgun profile matches the export")
	check(profile_weapon("ranged", "combi-weapon", "damnatus").damage == "D3+2" and not profile_weapon("ranged", "combi-weapon", "damnatus").keywords.has("melta") and profile_weapon("ranged", "combi-weapon", "infernus").keywords == {"torrent": true, "blast": 1} and profile_weapon("ranged", "combi-weapon", "purgatus").keywords == {"melta": 2}, "Each Combi-weapon profile retains only its source-listed traits")
	check(profile_weapon("ranged", "infernus-heavy-bolter", "bolt").keywords == {"heavy": true, "rapid-fire": 2, "sustained-hits": 1} and profile_weapon("ranged", "infernus-heavy-bolter", "infernus").keywords == {"torrent": true, "blast": 1}, "Both Infernus Heavy Bolter modes are recorded")
	check(profile_weapon("ranged", "stalker-pattern-boltgun").keywords == {"heavy": true, "precision": true} and profile_weapon("ranged", "deathwatch-shotgun").keywords == {"assault": true} and profile_weapon("ranged", "frag-cannon").keywords == {"heavy": true, "lethal-hits": true, "rapid-fire": 1, "blast": 1}, "The three ranged Veteran options preserve their weapon traits")
	check(profile_weapon("melee", "knives-and-fists").attacks == 3 and profile_weapon("melee", "heavy-thunder-hammer").damage == 3 and profile_weapon("melee", "black-shield-blades").keywords == {"twin-linked": true} and profile_weapon("melee", "xenophase-blade").keywords == {"devastating-wounds": true}, "The melee options preserve their source profiles and traits")
	check(Catalog.SPECS.has(UNIT) and Abilities.RULES.get(UNIT, []) == ["death-to-the-alien", "storm-shield"], "Death to the Alien and conditional Storm Shield are registered for the current catalog")
	check(UNIT in LeaderLinks.targets("captain") and UNIT in LeaderLinks.targets("chaplain") and UNIT in LeaderLinks.targets("librarian") and UNIT in LeaderLinks.targets("watch-master") and UNIT in LeaderLinks.targets("watch-captain-artemis"), "All source-listed Deathwatch Leader endpoints remain registered, including the integrated Watch Master")
	for support: String in ["ancient", "apothecary", "judiciar", "lieutenant"]:
		check(UNIT in SupportAttachments.links(support), "%s retains its source-listed Deathwatch Veterans Support link" % support)

	var state := fresh_state()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Both players can materialize Deathwatch Veterans from the current local catalog: " + state_error)
	if not state_error.is_empty():
		print(state_error)
		quit(1)
		return
	var small := find_squad(state, 1, UNIT, 5)
	var large := find_squad(state, 1, UNIT, 10)
	var initial_training_points := int(state.training_points.get(1, 0))
	var opponent := find_squad(state, 2, "captain")
	var enemy_model := models_for(state, opponent, "captain")[0]
	var small_models := models_for(state, small)
	var large_models := models_for(state, large)
	var opponent_veterans := find_squad(state, 2, UNIT, 5)
	check(small >= 0 and large >= 0 and opponent_veterans >= 0 and small_models.size() == 5 and large_models.size() == 10, "Both priced squad sizes and the opposing catalog copy materialize")
	check(int(state.squads[small].get("training_cost", -1)) == 115 and int(state.squads[large].get("training_cost", -1)) == 220, "Prepared units use the exact source costs")
	check(small_models[0] == model_role(state, small, true) and large_models[0] == model_role(state, large, true), "Each unit has one Watch Sergeant followed by ordinary Veterans")
	check(has_choice(state, 1, "deathwatch-sergeant-ranged-loadout", small, small_models[0], "combi-weapon") and has_choice(state, 1, "deathwatch-sergeant-melee-loadout", small, small_models[0], "xenophase-blade") and not has_choice(state, 1, "deathwatch-veteran-loadout", small, small_models[0], "black-shield-blades"), "Sergeant choices are separate and ordinary Veteran options do not leak onto the Sergeant")

	var sergeant := small_models[0]
	var combi := choose(state, 1, "deathwatch-sergeant-ranged-loadout", small, sergeant, "combi-weapon")
	var xenophase := choose(state, 1, "deathwatch-sergeant-melee-loadout", small, sergeant, "xenophase-blade")
	check(str(combi.get("error", "")).is_empty() and state.units[sergeant].ranged_weapons[0].id == "combi-weapon" and state.units[sergeant].ranged_weapons[0].profiles.size() == 3, "The Watch Sergeant's Combi-weapon choice exposes all three source profiles")
	check(str(xenophase.get("error", "")).is_empty() and state.units[sergeant].melee_weapons[0].id == "xenophase-blade", "The Watch Sergeant can independently take the Xenophase Blade")

	var five_veterans := small_models.slice(1)
	var stalker := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[0], "stalker-pattern-boltgun")
	check(str(stalker.get("error", "")).is_empty() and state.units[five_veterans[0]].ranged_weapons[0].id == "stalker-pattern-boltgun" and state.units[five_veterans[0]].melee_weapons[0].id == "knives-and-fists", "A five-model unit can exchange both default weapons for the Stalker package")
	check(not has_choice(state, 1, "deathwatch-veteran-loadout", small, five_veterans[1], "stalker-pattern-boltgun"), "The five-model unit withholds a second one-per-five Stalker Boltgun")
	var reverted := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[0], "default")
	check(str(reverted.get("error", "")).is_empty() and state.units[five_veterans[0]].melee_weapons[0].id == "power-weapon" and has_choice(state, 1, "deathwatch-veteran-loadout", small, five_veterans[1], "stalker-pattern-boltgun"), "Veteran equipment changes are reversible and restore both default weapons")

	for index in [1, 2]:
		var shotgunned := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[index], "deathwatch-shotgun")
		check(str(shotgunned.get("error", "")).is_empty(), "The five-model cap permits two Deathwatch Shotguns")
	check(not has_choice(state, 1, "deathwatch-veteran-loadout", small, five_veterans[3], "deathwatch-shotgun"), "The five-model cap withholds a third Deathwatch Shotgun")
	var shielded := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[0], "boltgun-storm-shield")
	var shielded_second := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[3], "power-weapon-storm-shield")
	check(str(shielded.get("error", "")).is_empty() and str(shielded_second.get("error", "")).is_empty() and Groups.profile(state, five_veterans[0]).invulnerable_target == 4 and Groups.profile(state, five_veterans[3]).invulnerable_target == 4, "Two source-listed Storm Shields give only their bearers a 4+ invulnerable save")
	check(not has_choice(state, 1, "deathwatch-veteran-loadout", small, five_veterans[2], "boltgun-storm-shield") and state.units[five_veterans[0]].melee_weapons.is_empty() and state.units[five_veterans[3]].ranged_weapons.is_empty(), "The combined two-per-five Storm Shield limit and replacement weapon omissions are enforced")
	var shield_removed := choose(state, 1, "deathwatch-veteran-loadout", small, five_veterans[0], "default")
	check(str(shield_removed.get("error", "")).is_empty() and Groups.profile(state, five_veterans[0]).invulnerable_target == 0 and not Abilities.sources(state, small, "storm-shield").has(five_veterans[0]), "Reverting a Storm Shield restores that model's save and removes the ability source")

	var ordinary_forged := find_choice(state, 1, "deathwatch-veteran-loadout", small, five_veterans[2], "frag-cannon")
	var before_invalid := var_to_bytes(state)
	var forged := ordinary_forged.duplicate(true)
	forged.value = "unsupported"
	check(not ordinary_forged.is_empty() and not PublicUnitCommand.error(state, 1, forged).is_empty() and before_invalid == var_to_bytes(state), "Forged model equipment is rejected without state mutation")
	check(not ordinary_forged.is_empty() and not PublicUnitCommand.error(state, 2, ordinary_forged).is_empty() and before_invalid == var_to_bytes(state), "The opposing player cannot change a Deathwatch loadout")

	var ten_veterans := large_models.slice(1)
	for index in [0, 1, 2, 3]:
		var heavy_hammer := choose(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[index], "heavy-thunder-hammer")
		check(str(heavy_hammer.get("error", "")).is_empty(), "A ten-model unit can take four Heavy Thunder Hammers across two five-model blocks")
	check(not has_choice(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[4], "heavy-thunder-hammer"), "The ten-model unit withholds a fifth Heavy Thunder Hammer")
	for index in [3, 4]:
		var frag := choose(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[index], "frag-cannon")
		check(str(frag.get("error", "")).is_empty(), "The ten-model unit supports two Frag Cannons")
	check(not has_choice(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[5], "frag-cannon"), "The ten-model unit withholds a third Frag Cannon")
	var shield_five := choose(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[6], "boltgun-storm-shield")
	var shield_six := choose(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[7], "power-weapon-storm-shield")
	check(str(shield_five.get("error", "")).is_empty() and str(shield_six.get("error", "")).is_empty() and has_choice(state, 1, "deathwatch-veteran-loadout", large, ten_veterans[8], "boltgun-storm-shield"), "A ten-model unit permits up to four Storm Shields in either listed combination")
	check(int(state.training_points.get(1, 0)) == initial_training_points, "All Deathwatch wargear options are zero-cost under the local source")

	var battle_state := state.duplicate(true)
	battle_state.phase = "start_turn"
	battle_state.turn = 1
	battle_state.revision = 0
	var captain_squad := find_squad(battle_state, 1, "captain")
	var captain := models_for(battle_state, captain_squad, "captain")[0]
	var attach_error := Attachments.form_practice_unit(battle_state, small, captain_squad, -1, true)
	check(attach_error.is_empty() and C.UnitAbilities.has(battle_state, small, "death-to-the-alien") and C.UnitActions.attachment_allowed(state, captain, small), "A Captain can attach to the source-listed unit and receives its unit attack ability")
	if attach_error.is_empty():
		battle_state.deployment.complete = true
		battle_state.mission.stage = "battle"
		battle_state.phase = "shooting"
		battle_state.active = 1
		battle_state.round = 1
		battle_state.unit_abilities.setup_players = []
		battle_state.unit_abilities.battle_players = [1, 2]
		battle_state.unit_abilities.phase_key = C.UnitActions.key(battle_state)
		battle_state.unit_abilities.window = {}
		place_for_attack(battle_state, captain, opponent)
		var gun: Dictionary = battle_state.units[captain].ranged_weapons[0]
		var gun_profile := str(gun.profiles.keys()[0])
		var imperium_plan := C.AttackPlan.prepare(battle_state, small, false, declaration(captain, opponent, str(gun.id), gun_profile), true)
		check(imperium_plan.get("error", "").is_empty() and imperium_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Death to the Alien grants re-rolls of 1 against an Imperium target, including attached Leaders")
		for target_model: int in C.living(battle_state, opponent): battle_state.units[target_model].keywords = ["ORKS"]
		var xenos_plan := C.AttackPlan.prepare(battle_state, small, false, declaration(captain, opponent, str(gun.id), gun_profile), true)
		check(xenos_plan.get("error", "").is_empty() and xenos_plan.batches[0].context.get("hit_reroll", "none") == "all", "Death to the Alien grants full Hit re-rolls when the target has neither IMPERIUM nor CHAOS")
		battle_state.phase = "fight"
		battle_state.active = 1
		battle_state.fight_actor = 1
		battle_state.fight_step = "attacks"
		battle_state.units[captain].wounds = 0
		var melee_entries: Array[Dictionary] = []
		var melee_weapons := ["xenophase-blade", "power-weapon", "knives-and-fists", "knives-and-fists", "power-weapon"]
		for index in small_models.size():
			var attacker: int = small_models[index]
			battle_state.units[attacker].position = Vector2.ZERO
			melee_entries.append({"model": attacker, "target": opponent, "amount": 4 if index == 0 else 3, "weapon": melee_weapons[index], "profile": "standard"})
		var enemy_base := float(battle_state.units[C.living(battle_state, opponent)[0]].radius)
		battle_state.units[C.living(battle_state, opponent)[0]].position = Vector2(0.5 + float(battle_state.units[small_models[0]].radius) + enemy_base, 0.0)
		var melee_plan := C.AttackPlan.prepare(battle_state, small, true, melee_entries, true)
		var melee_rerolls: Array[String] = []
		for batch: Dictionary in melee_plan.get("batches", []): melee_rerolls.append(str(batch.context.get("hit_reroll", "none")))
		check(melee_plan.get("error", "").is_empty() and not melee_rerolls.is_empty() and melee_rerolls.all(func(mode: String) -> bool: return mode == "all"), "Death to the Alien also applies to melee attacks against targets without IMPERIUM or CHAOS: " + str(melee_plan.get("error", "")) + " rerolls=" + str(melee_rerolls))

	print("Deathwatch Veterans source-bounded checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

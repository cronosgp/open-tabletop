extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ASSAULT_ID := "40kdc:11e:adeptus-astartes:assault-intercessor-squad"
const CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := {
	"heavy-bolt-pistol:standard": {"melee": false, "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"hand-flamer:standard": {"melee": false, "range_inches": 9.0, "attacks": 3, "skill": 0, "strength": 4, "ap": 0, "damage": 1, "keywords": {"close-quarters": true, "torrent": true}},
	"plasma-pistol:standard": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}},
	"plasma-pistol:supercharge": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}},
	"chainsword:standard": {"melee": true, "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {}},
	"power-fist:standard": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {}},
	"power-weapon:standard": {"melee": true, "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {}},
	"thunder-hammer:standard": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 8, "ap": -2, "damage": 3, "keywords": {"devastating-wounds": true}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(models: int = 5) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": ASSAULT_ID, "models": models, "copies": 1},
		{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1}]
	result[2].entries = [{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]
	return result

func make_state(models: int = 5) -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections(models))

func find_models(state: Dictionary, owner: int, identity: String) -> Dictionary:
	var result := {"squad": -1, "models": [], "sergeant": -1}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		result.squad = int(unit.squad)
		result.models.append(model)
		if unit.get("sergeant", false): result.sergeant = model
	return result

func choice_for(state: Dictionary, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, 1):
		if option.action == action and int(option.model) == model and str(option.value) == value: return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty(): return {"error": "No UnitActions preparation decision is open."}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The current preparation decision does not offer this choice."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}})

func check_weapon_profile(state: Dictionary, squad: int, model: int, target_squad: int, weapon_id: String, profile_id: String = "standard") -> void:
	var key := "%s:%s" % [weapon_id, profile_id]
	var expected: Dictionary = WEAPONS[key]
	var selected: Dictionary = Equipment.select(state, model, bool(expected.melee), weapon_id, profile_id)
	check(str(selected.get("error", "")).is_empty(), "%s/%s is available through Equipment" % [weapon_id, profile_id])
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s/%s %s matches the pinned export" % [weapon_id, profile_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s/%s retains its complete source weapon traits" % [weapon_id, profile_id])
	var prior_phase: String = str(state.phase)
	var old_attacker_position: Vector2 = state.units[model].position
	var targets: Array[int] = C.living(state, target_squad)
	if targets.is_empty():
		check(false, "AttackPlan target squad has a living model")
		return
	var target_model := targets[0]
	var old_target_position: Vector2 = state.units[target_model].position
	state.units[model].position = Vector2(0, 0)
	state.units[target_model].position = Vector2(1, 0)
	state.phase = "fight" if expected.melee else "shooting"
	var amount := int(selected.stats.attacks) if expected.melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, bool(expected.melee), [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": profile_id}], true)
	state.phase = prior_phase
	state.units[model].position = old_attacker_position
	state.units[target_model].position = old_target_position
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s/%s routes through AttackPlan: %s" % [weapon_id, profile_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan preserves %s as the attack source" % weapon_id)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("assault-intercessor-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001606" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Assault Intercessor identity is tied to the shared-book local Wahapedia profile")
	check(profile.points_by_models == {5: 85, 10: 170} and profile.models == 5 and is_equal_approx(profile.base_radius_inches, 16.0 / 25.4), "5/10-model prices and 32 mm bases match the local export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "The model characteristics match the local source record")
	var expected_keywords := ["ADEPTUS ASTARTES", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"]
	var actual_keywords: Array = profile.keywords.duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All six source keywords are retained")
	check(profile.ranged.size() == 1 and profile.ranged[0].id == "heavy-bolt-pistol" and profile.melee.size() == 1 and profile.melee[0].id == "chainsword", "Every model starts with the source Heavy Bolt Pistol and Chainsword")
	check(profile.additional_weapon_profiles.ranged.size() == 2 and profile.additional_weapon_profiles.melee.size() == 3, "Every source-listed Sergeant replacement profile is present")
	check(Catalog.SPECS["assault-intercessor-squad"].get("current_reference", false), "The profile remains admitted through the current local catalog")
	var catalog_choice := Army.current_catalog_choice({"id": ASSAULT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 5, "cost": 85}, {"models": 10, "cost": 170}], "Construction exposes only the source-priced 5/10-model sizes")
	check(RosterValidation.POINTS["assault-intercessor-squad"].get("sizes", {}) == {5: 85, 10: 170}, "Checked roster admission retains both source prices")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ASSAULT_ID, "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ASSAULT_ID, "models": 10, "copies": 1}]})
	var unsupported := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ASSAULT_ID, "models": 6, "copies": 1}]})
	check(five.error.is_empty() and five.total == 85 and ten.error.is_empty() and ten.total == 170 and not unsupported.error.is_empty(), "Roster admission prices both source sizes and rejects an unsupported six-model size")

	var state := make_state()
	check(not state.has("error"), "The current-catalog Assault Intercessor match materializes")
	if state.has("error"):
		print("Assault Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find_models(state, 1, "assault-intercessor-squad")
	var enemy := find_models(state, 2, "intercessor-squad")
	var captain := find_models(state, 1, "captain")
	check(found.models.size() == 5 and found.sergeant >= 0 and enemy.models.size() == 5 and not captain.models.is_empty(), "One Sergeant and four Assault Intercessors materialize alongside current-catalog Leaders and target models")
	if found.models.is_empty() or found.sergeant < 0 or enemy.models.is_empty():
		print("Assault Intercessor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := int(found.squad)
	for model: int in found.models:
		var record: Dictionary = state.units[model]
		check(int(record.get("movement", -1)) == 6 and int(record.get("max_wounds", -1)) == 2, "Each model has the source movement and wounds")
		for keyword: String in expected_keywords: check(Terrain.has_keyword(record, [keyword.to_lower()]), "Each model carries the %s source keyword" % keyword)
		check(record.get("ranged_weapons", []).size() == 1 and record.ranged_weapons[0].id == "heavy-bolt-pistol" and record.get("melee_weapons", []).size() == 1 and record.melee_weapons[0].id == "chainsword", "Every model starts with its source-listed fixed loadout")
	check(state.squads[squad].stats.toughness == 5 and state.squads[squad].stats.save_target == 3 and state.squads[squad].stats.leadership_target == 6 and state.squads[squad].stats.objective_control == 2, "The shared squad characteristics match the local datasheet")
	check("assault-intercessor-squad" in LeaderLinks.TARGETS.get("captain", []) and C.UnitActions.attachment_allowed(state, int(captain.models[0]), squad), "The source-listed Captain can lead this unit")
	check(C.UnitAbilities.has(state, squad, "targeted-intercession"), "Targeted Intercession is registered for the current profile")
	check_weapon_profile(state, squad, found.sergeant, enemy.squad, "heavy-bolt-pistol")
	check_weapon_profile(state, squad, found.sergeant, enemy.squad, "chainsword")

	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var trooper := -1
	for model: int in found.models:
		if model != found.sergeant: trooper = model; break
	var default_pistol_options: Array[String] = []
	var default_melee_options: Array[String] = []
	for choice: Dictionary in C.unit_choices(state, 1):
		if int(choice.get("model", -1)) != found.sergeant: continue
		if str(choice.get("action", "")) == "assault-intercessor-pistol": default_pistol_options.append(str(choice.get("value", "")))
		if str(choice.get("action", "")) == "assault-intercessor-melee": default_melee_options.append(str(choice.get("value", "")))
	default_pistol_options.sort()
	default_melee_options.sort()
	check(default_pistol_options == ["hand-flamer", "plasma-pistol"] and default_melee_options == ["power-fist", "power-weapon", "thunder-hammer"], "Setup offers only the Sergeant's legal alternatives to the current default loadout")
	check(choice_for(state, "assault-intercessor-pistol", trooper, "plasma-pistol").is_empty() and choice_for(state, "assault-intercessor-melee", trooper, "thunder-hammer").is_empty(), "Ordinary Assault Intercessors cannot receive Sergeant-only replacements")
	var pistol_choice := choice_for(state, "assault-intercessor-pistol", found.sergeant, "hand-flamer")
	var before_rejected_choice := var_to_bytes(state)
	var wrong_owner := submit_choice(state, 2, pistol_choice)
	var forged_trooper := pistol_choice.duplicate(true)
	forged_trooper.model = trooper
	var wrong_model := submit_choice(state, 1, forged_trooper)
	var stale_decision := C.UnitActions.pending_decision(state)
	var stale_choice := submit_choice(state, 1, pistol_choice, str(stale_decision.get("decision_id", "")), "stale-option-id")
	check(not wrong_owner.get("error", "").is_empty() and not wrong_model.get("error", "").is_empty() and not stale_choice.get("error", "").is_empty() and before_rejected_choice == var_to_bytes(state), "Wrong-owner, non-Sergeant and stale setup choices are rejected without changing loadout")

	for kind: String in ["hand-flamer", "plasma-pistol", "heavy-bolt-pistol"]:
		var selected := choice_for(state, "assault-intercessor-pistol", found.sergeant, kind)
		check(not selected.is_empty(), "Setup exposes the legal pistol option %s" % kind)
		if selected.is_empty(): continue
		var result := submit_choice(state, 1, selected)
		check(str(result.get("error", "")).is_empty(), "Public setup accepts the pistol option %s" % kind)
		var expected_id := "heavy-bolt-pistol" if kind == "heavy-bolt-pistol" else kind
		check(state.units[found.sergeant].ranged_weapons.size() == 1 and state.units[found.sergeant].ranged_weapons[0].id == expected_id, "The pistol choice equips only the Sergeant with %s" % expected_id)
		for model: int in found.models:
			if model != found.sergeant: check(state.units[model].ranged_weapons[0].id == "heavy-bolt-pistol", "The %s choice leaves ordinary models unchanged" % kind)
		if kind == "hand-flamer": check_weapon_profile(state, squad, found.sergeant, enemy.squad, "hand-flamer")
		if kind == "plasma-pistol":
			check_weapon_profile(state, squad, found.sergeant, enemy.squad, "plasma-pistol", "standard")
			check_weapon_profile(state, squad, found.sergeant, enemy.squad, "plasma-pistol", "supercharge")

	for kind: String in ["power-fist", "power-weapon", "thunder-hammer", "chainsword"]:
		var selected := choice_for(state, "assault-intercessor-melee", found.sergeant, kind)
		check(not selected.is_empty(), "Setup exposes the legal melee option %s" % kind)
		if selected.is_empty(): continue
		var result := submit_choice(state, 1, selected)
		check(str(result.get("error", "")).is_empty(), "Public setup accepts the melee option %s" % kind)
		var expected_id := "chainsword" if kind == "chainsword" else kind
		check(state.units[found.sergeant].melee_weapons.size() == 1 and state.units[found.sergeant].melee_weapons[0].id == expected_id, "The melee choice equips only the Sergeant with %s" % expected_id)
		for model: int in found.models:
			if model != found.sergeant: check(state.units[model].melee_weapons[0].id == "chainsword", "The %s choice leaves ordinary models unchanged" % kind)
		check_weapon_profile(state, squad, found.sergeant, enemy.squad, expected_id)

	var hammer_choice := choice_for(state, "assault-intercessor-melee", found.sergeant, "thunder-hammer")
	check(not hammer_choice.is_empty() and submit_choice(state, 1, hammer_choice).get("error", "").is_empty(), "The setup flow can restore the Thunder Hammer for the post-charge interaction check")
	var hammer: Dictionary = state.units[found.sergeant].melee_weapons[0].profiles.standard
	state.squads[squad].charged = true
	var charged_hammer: Dictionary = C.UnitAbilities.weapon(state, found.sergeant, enemy.squad, hammer, true)
	check(charged_hammer.strength == hammer.strength + 1 and charged_hammer.ap == hammer.ap - 1 and hammer.strength == 8 and hammer.ap == -2, "Targeted Intercession modifies the selected Thunder Hammer after a charge without changing its printed data")
	var pistol: Dictionary = state.units[found.sergeant].ranged_weapons[0].profiles.standard
	var charged_pistol: Dictionary = C.UnitAbilities.weapon(state, found.sergeant, enemy.squad, pistol, false)
	check(charged_pistol.strength == pistol.strength and charged_pistol.ap == pistol.ap, "Targeted Intercession leaves the Sergeant's ranged attacks unchanged")
	state.squads[squad].charged = false

	var ten_state := make_state(10)
	var ten_found := find_models(ten_state, 1, "assault-intercessor-squad")
	check(not ten_state.has("error") and ten_found.models.size() == 10 and ten_found.sergeant >= 0, "The ten-model source composition materializes with one Sergeant and nine Assault Intercessors")

	print("Current Assault Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

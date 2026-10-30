extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const CombatDoctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, owner: int, identity: String, pack_leader: bool = false) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity and bool(unit.get("sergeant", false)) == pack_leader: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return int(unit.squad)
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:blood-claws", "models": 10, "copies": 1})
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections())

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("blood-claws")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000303" and profile.get("source_snapshot_id", "") == "20261029T003124Z", "Blood Claws profile is bound to the current Space Wolves App sheet and verified e11 export")
	check(profile.get("points_by_models", {}) == {10: 150, 20: 290} and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 32, "Blood Claws source prices, default size and base are retained")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Blood Claws characteristics match the source export")
	check(profile.get("keywords", []).has("BATTLELINE") and profile.keywords.has("SPACE WOLVES") and profile.keywords.has("TACTICUS"), "Blood Claws source keywords are published")
	check(profile.options.pack_leader_ranged_packages == ["bolt-pistol", "plasma-pistol"] and profile.options.pack_leader_melee_packages == ["chainsword", "power-weapon"], "The Pack Leader's two independent source-listed replacements are bounded")
	check(Profiles.blood_claws_pack_leader_weapons("invented", "chainsword").is_empty() and Profiles.blood_claws_pack_leader_weapons("plasma-pistol", "power-weapon").ranged[0].profiles.supercharge.keywords.hazardous, "Unsupported loadouts are rejected and plasma supercharge retains Hazardous")
	var state := fresh()
	check(not state.has("error"), "Blood Claws prepare from the consolidated local construction catalog")
	if state.has("error"):
		print(str(state.error))
		quit(1)
		return
	var leader := find_model(state, 1, "blood-claws", true)
	var regular := find_model(state, 1, "blood-claws", false)
	var squad := int(state.units[leader].squad) if leader >= 0 else -1
	var regular_squad := int(state.units[regular].squad) if regular >= 0 else -1
	check(leader >= 0 and regular >= 0 and C.living(state, squad).size() == 10, "Ten-model roster has one Pack Leader and nine Blood Claws")
	if leader < 0 or regular < 0:
		print("Blood Claws local checks: %d failures" % failures)
		quit(1)
		return
	check(state.units[leader].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["bolt-pistol"] and state.units[leader].melee_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["chainsword"], "Pack Leader starts with the source-listed Bolt Pistol and Chainsword")
	check(find_choice(state, 1, "blood-claws-pack-leader-pistol", leader, "plasma-pistol").size() > 0 and find_choice(state, 1, "blood-claws-pack-leader-melee", leader, "power-weapon").size() > 0, "Army preparation offers both source-listed Pack Leader replacements")
	check(find_choice(state, 1, "blood-claws-pack-leader-pistol", regular, "plasma-pistol").is_empty() and find_choice(state, 1, "blood-claws-pack-leader-melee", regular, "power-weapon").is_empty(), "Pack Leader-only equipment is not offered to regular Blood Claws")
	var invalid := PublicUnitCommand.submit(state, 1, {"action": "blood-claws-pack-leader-pistol", "model": leader, "target": squad, "value": "invented"})
	check(not str(invalid.get("error", "")).is_empty(), "An unsupported Pack Leader weapon is rejected")
	var pistol_choice := find_choice(state, 1, "blood-claws-pack-leader-pistol", leader, "plasma-pistol")
	var selected_pistol := PublicUnitCommand.submit(state, 1, pistol_choice)
	check(str(selected_pistol.get("error", "")).is_empty() and state.units[leader].ranged_weapons[0].id == "plasma-pistol" and state.units[leader].ranged_weapons[0].profiles.supercharge.keywords.hazardous, "Selecting Plasma Pistol updates the Pack Leader's equipped profiles")
	var melee_choice := find_choice(state, 1, "blood-claws-pack-leader-melee", leader, "power-weapon")
	var selected_melee := PublicUnitCommand.submit(state, 1, melee_choice)
	check(str(selected_melee.get("error", "")).is_empty() and state.units[leader].melee_weapons[0].id == "power-weapon", "Selecting Power Weapon replaces only the Pack Leader's melee weapon")
	check(C.UnitAbilities.has(state, squad, "berserk-charge"), "Berserk Charge is registered for Blood Claws")
	state.squads[squad].advanced = true
	check(CombatDoctrines.charge_error(state, squad).is_empty(), "Blood Claws remain eligible to declare a charge after Advancing")
	var ordinary_squad := find_squad(state, 2, "intercessor-squad")
	state.squads[ordinary_squad].advanced = true
	check(not CombatDoctrines.charge_error(state, ordinary_squad).is_empty(), "Berserk Charge does not remove the normal Advance-to-Charge restriction from another unit")
	state.phase = "charge"
	state.active = 1
	for model: int in state.units: state.units[model].position = Vector2(-10.0, -10.0) if int(state.units[model].get("owner", -1)) == 1 else Vector2(10.0, 10.0)
	state.units[leader].position = Vector2.ZERO
	var nearby_enemy := find_model(state, 2, "intercessor-squad", false)
	if nearby_enemy < 0: nearby_enemy = find_model(state, 2, "intercessor-squad", true)
	state.units[nearby_enemy].position = Vector2(8.0, 0.0)
	var charge := C.declare_charge(state, 1, leader, int(state.revision), func() -> int: return 6)
	check(str(charge.get("error", "")).is_empty() and bool(state.squads[squad].get("charge_declared", false)), "An Advanced Blood Claws unit passes the real Charge declaration path")
	check(regular_squad == squad and state.units[regular].melee_weapons[0].id == "chainsword", "Pack Leader changes do not alter the rest of the unit's equipment")
	print("Blood Claws checks: %d failures" % failures)
	quit(1 if failures else 0)

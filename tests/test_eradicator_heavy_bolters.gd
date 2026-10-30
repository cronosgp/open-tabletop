extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const UNIT := "eradicator-squad-with-heavy-bolters"
const UNIT_ID := "40kdc:11e:adeptus-astartes:eradicator-squad-with-heavy-bolters"
const BIOLOGIS_ID := "40kdc:11e:adeptus-astartes:apothecary-biologis"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WEAPONS := {
	"heavy-bolter": {"melee": false, "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1, "rapid-fire": 2, "heavy": true}},
	"bolt-pistol": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"ceramite-fists": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}
}
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": BIOLOGIS_ID, "models": 1, "copies": 1},
		{"definition_id": UNIT_ID, "models": 3, "copies": 1},
		{"definition_id": UNIT_ID, "models": 6, "copies": 1}]
	result[2].entries = [
		{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 10, "copies": 1}]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func check_weapon_profile(state: Dictionary, squad: int, model: int, target: int, weapon: String) -> void:
	var expected: Dictionary = WEAPONS[weapon]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon)
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the verified source" % [weapon, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s preserves every source weapon trait" % weapon)
	var old_phase: String = str(state.phase)
	var old_active: int = int(state.active)
	var attackers: Array[int] = C.living(state, squad)
	var targets: Array[int] = C.living(state, target)
	var old_positions := {}
	for member: int in attackers + targets: old_positions[member] = state.units[member].position
	for index in range(attackers.size()): state.units[attackers[index]].position = Vector2.ZERO if attackers[index] == model else Vector2(-10, 4 + index * 3)
	for index in range(targets.size()): state.units[targets[index]].position = Vector2(1, 0) if bool(expected.melee) and index == 0 else Vector2(4, 0) if index == 0 else Vector2(10, 4 + index * 3)
	state.phase = "fight" if bool(expected.melee) else "shooting"
	state.active = int(state.squads[squad].owner)
	var amount := int(selected.stats.attacks) if bool(expected.melee) else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, bool(expected.melee), [{"model": model, "target": target, "amount": amount, "weapon": weapon, "profile": "standard"}], true)
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon, "AttackPlan retains %s as its weapon source" % weapon)
func fixture() -> Dictionary:
	var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists())
	if s.has("error"): return s
	s.awakened_dynasty.pending = []
	s.mission.stage = "battle"
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.phase = "shooting"
	s.turn = 3
	s.round = 2
	s.active = 1
	s.cp = {1: 3, 2: 3}
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	s.terrain.areas = []
	if s.has("stratagems"):
		for key in ["attack_rerolls", "save_rerolls", "damage_rerolls", "count_rerolls", "hazard_rerolls"]: s.stratagems[key] = false
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -15) if s.units[model].owner == 1 else Vector2(20, 15)
	var small := find_squad(s, 1, UNIT, 3)
	var large := find_squad(s, 1, UNIT, 6)
	var target := find_squad(s, 2, "intercessor-squad", 10)
	var other := find_squad(s, 2, "intercessor-squad", 5)
	for model: int in C.living(s, small): s.units[model].position = Vector2.ZERO
	for model: int in C.living(s, large): s.units[model].position = Vector2(-10, 0)
	for model: int in C.living(s, target): s.units[model].position = Vector2(8, 0)
	for model: int in C.living(s, other): s.units[model].position = Vector2(12, 0)
	return s
func mark(s: Dictionary, squad: int, target: int) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "overlap-target" and s.units[selected.model].squad == squad and selected.target == target: return selected
	return {}
func apply(s: Dictionary, selected: Dictionary) -> String:
	return PublicUnitCommand.error(s, 1, selected)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error"), "Current Heavy Bolter Eradicator configurations admit with a legal Biologis bodyguard")
	if s.has("error"):
		print(s)
		quit(1)
		return
	var small := find_squad(s, 1, UNIT, 3)
	var large := find_squad(s, 1, UNIT, 6)
	var biologis := find_squad(s, 1, "apothecary-biologis")
	var target := find_squad(s, 2, "intercessor-squad", 10)
	var other := find_squad(s, 2, "intercessor-squad", 5)
	check(small > 0 and large > 0 and biologis > 0 and target > 0 and other > 0, "Both current-catalog players materialize all intended profiles and sizes")
	if small < 0 or large < 0 or biologis < 0 or target < 0 or other < 0:
		print("Heavy Bolter Eradicator checks: %d failures" % (failures + 1))
		quit(1)
		return
	var profile: Dictionary = Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000004231" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Profile maps to the verified shared-book export identity and retains its source stamp")
	check(profile.get("points_by_models", {}) == {3: 100, 6: 215} and profile.get("third_plus_points_by_models", {}) == {3: 130, 6: 245} and profile.get("models") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Both compositions, cost tiers and 40mm bases match the export")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Shared Eradicator characteristics match the export")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "INFANTRY"], "All source keywords are preserved")
	check(profile.get("ranged", []).size() == 2 and profile.ranged[0].id == "heavy-bolter" and profile.ranged[1].id == "bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "ceramite-fists", "Fixed Heavy Bolter, Bolt Pistol and Ceramite Fists loadout matches the export")
	check(s.training_points[1] == 375 and s.squads[small].training_cost == 100 and s.squads[large].training_cost == 215, "3/6 formations preserve first-two source prices in the materialized army")
	check(C.living(s, small).size() == 3 and C.living(s, large).size() == 6 and s.units[C.living(s, small)[0]].radius == 20.0 / 25.4, "Current composition and 40mm bases materialize")
	check(C.UnitActions.attachment_allowed(s, biologis * 100, small) and C.UnitActions.attachment_allowed(s, biologis * 100, large), "Biologis Support accepts both Heavy Bolter Eradicator configurations")
	var catalog := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 3, "cost": 100, "third_plus_cost": 130}, {"models": 6, "cost": 215, "third_plus_cost": 245}], "Current construction exposes only the sourced composition and cost tiers")
	check(Roster.POINTS[UNIT].get("sizes", {}) == {3: 100, 6: 215} and Roster.POINTS[UNIT].get("third_plus_sizes", {}) == {3: 130, 6: 245}, "Army roster validation retains both cost tiers")
	var two_copy_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": BIOLOGIS_ID, "models": 1, "copies": 1}, {"definition_id": UNIT_ID, "models": 3, "copies": 1}, {"definition_id": UNIT_ID, "models": 6, "copies": 1}]}
	var two_copy_admission := C.RosterValidation.admit(two_copy_roster)
	check(two_copy_admission.get("error", "").is_empty() and two_copy_admission.get("total", -1) == 375, "The checked Incursion roster admits both sourced sizes at their first-two prices")
	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader]: source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["apothecary-biologis", "captain-in-gravis-armour", "iron-father-feirros", "marneus-calgar", "tor-garadon"], "All five source Leader links are present")
	check(UNIT in SupportAttachments.BODYGUARDS.get("apothecary-biologis", []), "The separate Support relation map lists the Biologis link")
	var small_models := C.living(s, small)
	var attacker_model: int = small_models[0]
	check_weapon_profile(s, small, attacker_model, target, "heavy-bolter")
	check_weapon_profile(s, small, attacker_model, target, "bolt-pistol")
	check_weapon_profile(s, small, attacker_model, target, "ceramite-fists")
	var raw: Dictionary = Profiles.profile(UNIT).ranged[0].profiles.standard
	check(not C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.has("blast"), "Optional ability does not apply without selecting a target")
	var selected_mark := mark(s, small, target)
	var before_mark := var_to_bytes(s)
	var opponent_choice := PublicUnitCommand.error(s, 2, selected_mark)
	check(not opponent_choice.is_empty() and before_mark == var_to_bytes(s), "Opponent cannot submit the active player's Overlapping Destruction choice")
	check(apply(s, selected_mark).is_empty() and s.cp[1] == 3 and s.get("stratagems", {}).get("uses", {}).is_empty(), "Target selection spends no CP and is not a stratagem")
	check(C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.get("blast", 0) == 1 and not raw.keywords.has("blast"), "Only selected Heavy Bolter gains Blast 1; source profile stays immutable")
	var pistol: Dictionary = Profiles.profile(UNIT).ranged[1].profiles.standard
	check(not C.UnitAbilities.weapon(s, attacker_model, target, pistol, false).keywords.has("blast") and not C.UnitAbilities.weapon(s, attacker_model, target, raw, true).keywords.has("blast"), "Pistol and melee are unaffected")
	check(not C.UnitAbilities.weapon(s, C.living(s, large)[0], target, raw, false).keywords.has("blast") and not C.UnitAbilities.weapon(s, attacker_model, other, raw, false).keywords.has("blast"), "Other squads and other targets are unaffected")
	var declaration := [{"model": attacker_model, "target": target, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}]
	var plan := C.AttackPlan.prepare(s, small, false, declaration, true)
	check(plan.error.is_empty() and plan.batches[0].context.attack_sources[0].bonus == 4, "Actual attack combines Rapid Fire 2 and Blast 1 against ten models")
	var target_models := C.living(s, target)
	s.units[target_models.back()].wounds = 0
	plan = C.AttackPlan.prepare(s, small, false, declaration, true)
	check(plan.error.is_empty() and plan.batches[0].context.attack_sources[0].bonus == 3, "Blast uses current target size when preparing the attack")
	check(apply(s, mark(s, small, other)).is_empty() and not C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.has("blast"), "Revising an uncommitted choice replaces the previous target rather than accumulating effects")
	check(apply(s, mark(s, small, target)).is_empty(), "Target can be restored before committing attacks")
	s = bytes_to_var(var_to_bytes(s))
	check(C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.get("blast", 0) == 1, "Target selection survives state serialization")
	var attack := C.resolve_attack_plan(s, 1, attacker_model, declaration, s.revision, false, true, func() -> int: return 1)
	check(attack.error.is_empty() and s.has("last_attack") and s.last_attack.pools[0].attacks == 6 and mark(s, small, target).is_empty(), "Committed shot uses the selected target and closes further target changes: " + str(attack.get("error", "")))
	s.phase = "charge"
	check(not C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.has("blast"), "Effect expires after own Shooting")
	s.phase = "shooting"
	s.turn += 2
	check(not C.UnitAbilities.weapon(s, attacker_model, target, raw, false).keywords.has("blast"), "Selection cannot leak into later turns")
	s = fixture()
	s.active = 2
	small = find_squad(s, 1, UNIT, 3)
	target = find_squad(s, 2, "intercessor-squad", 10)
	check(mark(s, small, target).is_empty(), "Ability is unavailable in the opponent turn")
	s = fixture()
	# An engaged Vehicle can be a normal ranged target, but not a Blast target.
	small = find_squad(s, 1, UNIT, 3)
	target = find_squad(s, 2, "intercessor-squad", 10)
	var vehicle_models := C.living(s, target)
	for model: int in vehicle_models:
		s.units[model].position = Vector2(5, 0)
		s.units[model].keywords.append("VEHICLE")
	biologis = find_squad(s, 1, "apothecary-biologis")
	s.units[C.living(s, biologis)[0]].position = Vector2(5, 0)
	attacker_model = C.living(s, small)[0]
	check(target in C.AttackPlan.legal_targets(s, attacker_model, false, "heavy-bolter", "standard"), "Unmarked Heavy Bolter can target an engaged Vehicle under the shared rules")
	check(apply(s, mark(s, small, target)).is_empty(), "Ability can select the enemy without inventing a visibility/range eligibility condition")
	check(target not in C.AttackPlan.legal_targets(s, attacker_model, false, "heavy-bolter", "standard") and not C.AttackPlan.prepare(s, small, false, declaration, true).error.is_empty(), "Ability-granted Blast also enforces engaged-target restrictions before dice")
	var three_copy_roster := two_copy_roster.duplicate(true)
	three_copy_roster.entries.append({"definition_id": UNIT_ID, "models": 3, "copies": 1})
	check(not C.RosterValidation.admit(three_copy_roster).get("error", "").is_empty(), "The current checked-roster format rejects a third non-Battleline copy while preserving its sourced third-plus price tier")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "tests_passed_local_targeted", "Heavy Bolter Eradicator remains admitted with targeted validation metadata")
	print("Heavy Bolter Eradicator checks: %d failures" % failures)
	quit(1 if failures else 0)

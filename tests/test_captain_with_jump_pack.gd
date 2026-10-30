extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const A = C.UnitAbilities
const U = C.UnitActions
const SOURCE_WEAPONS := {
	"heavy-bolt-pistol": {"standard": {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}},
	"hand-flamer": {"standard": {"name": "Hand Flamer", "range_inches": 9.0, "attacks": 3, "skill": 0, "strength": 4, "ap": 0, "damage": 1, "keywords": {"close-quarters": true, "torrent": true}}},
	"plasma-pistol": {
		"standard": {"name": "Plasma Pistol - Standard", "range_inches": 12.0, "attacks": 1, "skill": 2, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}},
		"supercharge": {"name": "Plasma Pistol - Supercharge", "range_inches": 12.0, "attacks": 1, "skill": 2, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}}
	},
	"chainsword": {"standard": {"name": "Chainsword", "range_inches": 0.0, "attacks": 8, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1}}},
	"power-fist": {"standard": {"name": "Power Fist", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}},
	"relic-weapon": {"standard": {"name": "Relic Weapon", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {}}},
	"thunder-hammer": {"standard": {"name": "Thunder Hammer", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 8, "ap": -2, "damage": 3, "keywords": {"devastating-wounds": true}}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and A.identity(state.units[model]) == identity:
			return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner:
			continue
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and A.identity(state.units[members[0]]) == identity:
			return squad
	return -1

func choice_for(options: Array, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func source_weapon_failures(package: Dictionary) -> Array[String]:
	var problems: Array[String] = []
	for kind: String in ["ranged", "melee"]:
		for weapon: Dictionary in package.get(kind, []):
			var weapon_id := str(weapon.get("id", ""))
			if not SOURCE_WEAPONS.has(weapon_id):
				problems.append("unexpected %s weapon %s" % [kind, weapon_id])
				continue
			if weapon.get("profiles", {}) != SOURCE_WEAPONS[weapon_id]:
				problems.append("source profile mismatch for %s: %s" % [weapon_id, str(weapon.get("profiles", {}))])
	return problems

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty():
		return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": selected}, func() -> int: return 6)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty():
		return {"error": "Selected choice is not in the current UnitActions projection."}
	var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": payload}, func() -> int: return 6)

func selections() -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
		lists[owner].entries = [
			entry("captain-with-jump-pack"),
			entry("assault-intercessors-with-jump-packs", 5),
			entry("vanguard-veteran-squad-with-jump-packs", 5),
			entry("intercessor-squad", 5)
		]
	return lists

func run() -> void:
	var profile := Profiles.profile("captain-with-jump-pack")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000083" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Profile identifies the pinned shared-book datasheet and its export revision")
	check(profile.get("name") == "Captain With Jump Pack" and profile.get("points_by_models", {}) == {1: 90} and profile.get("models") == 1, "The one-model Captain costs 90 points")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "M12, T5, Sv3+, W5, Ld6+, OC1 and 4+ invulnerable save match the export")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "The model's 40 mm base is represented")
	var expected_keywords: Array[String] = ["INFANTRY", "FLY", "JUMP PACK", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	expected_keywords.sort()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All nine source keywords are represented")
	check(Roster.POINTS.get("captain-with-jump-pack", {}).get("sizes", {}) == {1: 90}, "The current local roster catalog exposes the source cost")
	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-with-jump-pack")]})
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-with-jump-pack", 1, 3)]})
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-with-jump-pack", 1, 4)]})
	var incursion_three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-with-jump-pack", 1, 3)]})
	check(one_copy.get("error", "").is_empty() and int(one_copy.get("total", -1)) == 90 and three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 270 and not str(four_copies.get("error", "")).is_empty() and not str(incursion_three.get("error", "")).is_empty(), "Current construction applies the Incursion and Strike Force copy ceilings")
	var common_targets: Array = MarineLinks.TARGETS.get("captain-with-jump-pack", []).duplicate()
	common_targets.sort()
	check(common_targets == ["assault-intercessors-with-jump-packs", "vanguard-veteran-squad-with-jump-packs"], "The common-book Leader map contains exactly both supported Jump Pack bodyguards")

	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Both players materialize from the current consolidated Marine catalog")
	if state.has("error"):
		print("Captain With Jump Pack checks: %d failures; %s" % [failures + 1, str(state.get("error", ""))])
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.awakened_dynasty.pending = []
	var captain := find_model(state, 1, "captain-with-jump-pack")
	var enemy_captain := find_model(state, 2, "captain-with-jump-pack")
	var assault := find_squad(state, 1, "assault-intercessors-with-jump-packs")
	var vanguard := find_squad(state, 1, "vanguard-veteran-squad-with-jump-packs")
	var ordinary := find_squad(state, 1, "intercessor-squad")
	var enemy_infantry := find_squad(state, 2, "intercessor-squad")
	check(captain > 0 and enemy_captain > 0 and assault > 0 and vanguard > 0 and ordinary > 0 and enemy_infantry > 0, "Both current catalogs materialize the Captain and every source-linked comparison unit")
	if captain <= 0 or enemy_captain <= 0 or assault <= 0 or vanguard <= 0 or ordinary <= 0 or enemy_infantry <= 0:
		quit(1)
		return
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-14, 14) if int(state.units[model].owner) == 1 else Vector2(14, 14)
	for model: int in [captain, enemy_captain]:
		for ability: String in ["leader", "deep-strike", "combat-doctrines", "strategic-acumen", "angel-s-wrath", "transhuman-strategist"]:
			check(A.has(state, int(state.units[model].squad), ability), "Captain exposes its source-listed %s ability" % ability)
	check(U.attachment_allowed(state, captain, assault) and U.attachment_allowed(state, captain, vanguard), "Captain can lead both common-book Jump Pack bodyguards")
	check(not U.attachment_allowed(state, captain, ordinary), "Captain cannot lead an unlisted Intercessor Squad")
	var attached := U.apply(state, 1, {"action": "attach", "model": captain, "target": assault}, Vector2.ZERO, func() -> int: return 1)
	check(attached.get("error", "").is_empty() and int(state.units[captain].squad) == assault, "Captain attaches through the current unit-action path")
	check(A.every_model_has(state, assault, "deep-strike"), "Deep Strike is available to every model in the attached unit")
	check(A.advance_modifier(state, assault) == 1 and A.charge_modifier(state, assault) == 1 and A.advance_modifier(state, enemy_infantry) == 0, "Angel's Wrath adds one to this attached unit's Advance and Charge modifiers only")
	var reserve_state: Dictionary = state.duplicate(true)
	var reserve_choice: Dictionary = {}
	for option: Dictionary in U.choices(reserve_state, 1):
		if str(option.get("action", "")) == "reserve" and int(option.get("target", -1)) == assault:
			reserve_choice = option
			break
	var reserve_result := submit_projected_choice(reserve_state, 1, reserve_choice) if not reserve_choice.is_empty() else {"error": "The attached Jump Pack unit was not offered reserves."}
	var reserve_model_count := 0
	var all_reserved := true
	for model: int in reserve_state.units:
		if int(reserve_state.units[model].get("squad", -1)) != assault: continue
		reserve_model_count += 1
		all_reserved = all_reserved and not bool(reserve_state.units[model].get("on_battlefield", true))
	check(reserve_result.get("error", "").is_empty() and reserve_model_count == 6 and all_reserved and reserve_state.unit_abilities.reserves.has(assault), "The assembled six-model unit enters Strategic Reserves through the public Deep Strike path")
	var advance_state: Dictionary = state.duplicate(true)
	advance_state.phase = "movement"
	advance_state.active = 1
	advance_state.turn = 1
	advance_state.round = 1
	advance_state.squads[assault].moved = false
	var advance_error := Combat.begin_movement(advance_state, 1, captain, "advance", int(advance_state.revision), func() -> int: return 3)
	check(advance_error.is_empty() and int(advance_state.pending_move.get("raw_bonus", -1)) == 3 and int(advance_state.pending_move.get("bonus", -1)) == 4, "Angel's Wrath adds one after the resolved Advance D6")
	var charge_state: Dictionary = state.duplicate(true)
	charge_state.phase = "charge"
	charge_state.active = 1
	charge_state.turn = 1
	charge_state.round = 1
	var nearby_enemy := Geometry.alive(charge_state, enemy_infantry)[0]
	charge_state.units[nearby_enemy].position = charge_state.units[captain].position + Vector2(6.0, 0.0)
	var charge_result := Combat.declare_charge(charge_state, 1, captain, int(charge_state.revision), func() -> int: return 3)
	check(charge_result.get("error", "").is_empty() and int(charge_state.pending_charge.get("maximum", -1)) == 7, "Angel's Wrath adds one to the two-die Charge result")

	var expected_default: Dictionary = Profiles.jump_pack_captain_weapons("default")
	check(profile.get("ranged", []) == expected_default.ranged and profile.get("melee", []) == expected_default.melee, "Default Heavy Bolt Pistol and Chainsword match their source profiles")
	var loadouts: Array[String] = ["default", "hand-flamer", "plasma-pistol", "power-fist", "relic-weapon", "thunder-hammer-shield", "chainsword-shield"]
	var expected_packages := {
		"default": {"ranged": ["heavy-bolt-pistol"], "melee": ["chainsword"], "shield": false},
		"hand-flamer": {"ranged": ["hand-flamer"], "melee": ["chainsword"], "shield": false},
		"plasma-pistol": {"ranged": ["plasma-pistol"], "melee": ["chainsword"], "shield": false},
		"power-fist": {"ranged": ["heavy-bolt-pistol"], "melee": ["power-fist"], "shield": false},
		"relic-weapon": {"ranged": ["heavy-bolt-pistol"], "melee": ["relic-weapon"], "shield": false},
		"thunder-hammer-shield": {"ranged": [], "melee": ["thunder-hammer"], "shield": true},
		"chainsword-shield": {"ranged": [], "melee": ["chainsword"], "shield": true}
	}
	var weapon_failures: Array[String] = []
	for loadout: String in loadouts:
		var package: Dictionary = Profiles.jump_pack_captain_weapons(loadout)
		var ranged_ids: Array[String] = []
		var melee_ids: Array[String] = []
		for weapon: Dictionary in package.get("ranged", []): ranged_ids.append(str(weapon.get("id", "")))
		for weapon: Dictionary in package.get("melee", []): melee_ids.append(str(weapon.get("id", "")))
		check(ranged_ids == expected_packages[loadout].ranged and melee_ids == expected_packages[loadout].melee and bool(package.get("relic_shield", false)) == bool(expected_packages[loadout].shield), "The %s choice is one of the source-listed replacement sets" % loadout)
		var local_state: Dictionary = state.duplicate(true)
		var local_captain := find_model(local_state, 1, "captain-with-jump-pack")
		if loadout != "default":
			var selected := choice_for(U.choices(local_state, 1), "jump-pack-captain-loadout", local_captain, loadout)
			check(not selected.is_empty(), "Public preparation offers the source package %s" % loadout)
			var choice_result := submit_projected_choice(local_state, 1, selected)
			check(choice_result.get("error", "").is_empty(), "Public preparation accepts the source package %s" % loadout)
		check(not package.is_empty() and local_state.units[local_captain].ranged_weapons == package.ranged and local_state.units[local_captain].melee_weapons == package.melee, "The %s choice equips the exact source package" % loadout)
		var shield: bool = bool(package.get("relic_shield", false))
		check(bool(local_state.units[local_captain].get("relic_shield", false)) == shield and int(local_state.units[local_captain].max_wounds) == (6 if shield else 5), "Relic Shield changes only its selected bearer's wound profile for %s" % loadout)
		check(A.has(local_state, assault, "relic-shield") == shield and int(local_state.units[find_model(local_state, 1, "assault-intercessors-with-jump-packs")].max_wounds) == 2, "Relic Shield remains bearer-specific for %s" % loadout)
		weapon_failures.append_array(source_weapon_failures(package))
		weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(local_state, package, local_captain, enemy_infantry))
		if loadout != "default":
			var restore := choice_for(U.choices(local_state, 1), "jump-pack-captain-loadout", local_captain, "default")
			var restored := submit_projected_choice(local_state, 1, restore) if not restore.is_empty() else {"error": "The source default was not offered for restoration."}
			check(restored.get("error", "").is_empty() and local_state.units[local_captain].ranged_weapons == expected_default.ranged and local_state.units[local_captain].melee_weapons == expected_default.melee and int(local_state.units[local_captain].max_wounds) == 5 and not A.has(local_state, assault, "relic-shield"), "The %s choice restores the default equipment and removes shield wounds" % loadout)
	check(weapon_failures.is_empty(), "Every legal package and profile passes Equipment and AttackPlan: %s" % str(weapon_failures))

	var warlord := choice_for(U.choices(state, 1), "warlord", captain, "")
	check(not warlord.is_empty(), "The Captain is eligible to be Warlord")
	if not warlord.is_empty():
		var warlord_result := submit_projected_choice(state, 1, warlord)
		check(warlord_result.get("error", "").is_empty(), "The owner can designate the Captain as Warlord")
	state.cp[1] = 0
	state.first_player = 1
	state.round = 1
	U.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants one CP while the Captain is Warlord")
	U.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants CP only once per battle round")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	var acumen := choice_for(U.choices(state, 1), "acumen", captain, "assault")
	check(not acumen.is_empty(), "Strategic Acumen offers a Doctrine in the owner's Command phase")
	if not acumen.is_empty():
		var before_wrong_owner := var_to_bytes(state)
		var rejected_owner := submit_projected_choice(state, 2, acumen)
		check(not str(rejected_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(state), "The opponent cannot use the Captain's Strategic Acumen")
		var selected_doctrine := submit_projected_choice(state, 1, acumen)
		check(selected_doctrine.get("error", "").is_empty() and C.Doctrines.active_for(state, assault) == "assault", "The owner activates Assault Doctrine through Strategic Acumen")
		check(choice_for(U.choices(state, 1), "acumen", captain, "tactical").is_empty(), "Strategic Acumen cannot be used twice in the same Command phase")
		state.active = 2
		C.Doctrines.start_command(state)
		C.UnitAbilities.start_command(state)
		check(C.Doctrines.active_for(state, assault) == "assault", "The selected Doctrine persists through the opponent's Command phase")
		state.active = 1
		C.Doctrines.start_command(state)
		C.UnitAbilities.start_command(state)
		check(C.Doctrines.active_for(state, assault).is_empty(), "Strategic Acumen expires at the start of the next own Command phase")

	print("Captain With Jump Pack source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

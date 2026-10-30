extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const A = C.UnitAbilities
const U = C.UnitActions

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

func run() -> void:
	var profile := Profiles.profile("captain-on-bike")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002702" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Captain on Bike points to the pinned shared-book 11e export identity")
	check(profile.name == "Captain on Bike" and profile.models == 1 and profile.points_by_models == {1: 110} and profile.third_plus_points_by_models == {1: 110}, "The one-model 110-point cost matches the source")
	check(profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}, "Characteristics match the pinned source profile")
	check(profile.base_size_source_mm == [90, 52] and profile.base_geometry == "oval" and profile.geometry_scope == "90 x 52 mm bounding-circle proxy", "Source oval-base dimensions are recorded with the runtime geometry limitation")
	check(profile.keywords == ["CHARACTER", "RAVENWING", "CAPTAIN", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"], "Source keywords, including Ravenwing, are represented")
	check(MarineLinks.TARGETS.get("captain-on-bike", []) == ["outrider-squad"], "Shared-book Leader map includes Outrider Squad; Ravenwing Black Knights remain Chapter-book content")

	var source_packages: Array[Dictionary] = []
	for plasma: bool in [false, true]:
		for hammer: bool in [false, true]:
			source_packages.append({"plasma": plasma, "hammer": hammer, "weapons": Profiles.captain_bike_weapons(plasma, hammer)})
	var default_package: Dictionary = source_packages[0].weapons
	check(profile.ranged == default_package.ranged and profile.melee == default_package.melee, "Default Heavy Bolt Pistol, Twin Bolt Rifle and Master-crafted Power Weapon match the source")
	check(profile.ranged[1].profiles.standard.keywords == {"twin-linked": true, "assault": true, "rapid-fire": 2} and profile.additional_weapon_profiles.ranged[0].profiles.supercharge.keywords.hazardous, "Twin Bolt Rifle traits and Plasma Pistol Hazardous profile are preserved")
	check(profile.melee[0].profiles.standard.attacks == 6 and profile.additional_weapon_profiles.melee[0].profiles.standard.keywords.get("devastating-wounds", false), "Power Weapon and Thunder Hammer profiles match the source")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:captain-on-bike", "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 110, "third_plus_cost": 110}], "Current construction catalog exposes the source cost")
	var one_copy := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-on-bike")]})
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-on-bike", 1, 3)]})
	var four_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry("captain-on-bike", 1, 4)]})
	check(one_copy.get("error", "").is_empty() and int(one_copy.get("total", -1)) == 110 and three_copies.get("error", "").is_empty() and int(three_copies.get("total", -1)) == 330 and not str(four_copies.get("error", "")).is_empty(), "Strike Force applies the three-copy Captain ceiling and rejects a fourth")

	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
		lists[owner].entries = [entry("captain-on-bike"), entry("outrider-squad", 3), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Both players construct Space Marines from current local catalogs")
	if state.has("error"):
		print(str(state.error))
		quit(1)
		return

	var bike := find_model(state, 1, "captain-on-bike")
	var bike_enemy := find_model(state, 2, "captain-on-bike")
	var outriders := find_squad(state, 1, "outrider-squad")
	var enemy_intercessors := find_squad(state, 2, "intercessor-squad")
	check(bike > 0 and bike_enemy > 0 and outriders > 0 and enemy_intercessors > 0, "Both current-catalog rosters materialize the Captain, with the shared-book Leader target available")
	if bike <= 0 or bike_enemy <= 0 or outriders <= 0 or enemy_intercessors <= 0:
		quit(1)
		return

	state.phase = "deployment"
	state.active = 1
	state.awakened_dynasty.pending = []
	var bike_squad: int = int(state.units[bike].squad)
	var enemy_bike_squad: int = int(state.units[bike_enemy].squad)
	for ability: String in ["leader", "combat-doctrines", "strategic-acumen", "transhuman-strategist", "into-the-fray"]:
		check(A.has(state, bike_squad, ability), "Captain on Bike exposes source-listed %s" % ability)
		check(A.has(state, enemy_bike_squad, ability), "Opponent Captain on Bike exposes source-listed %s" % ability)
	check(U.attachment_allowed(state, bike, outriders), "Captain on Bike can lead the shared-book Outrider Squad")
	var attach_result := U.apply(state, 1, {"action": "attach", "model": bike, "target": outriders}, Vector2.ZERO, func() -> int: return 1)
	check(attach_result.get("error", "").is_empty() and int(state.units[bike].squad) == outriders, "Captain attaches to its source-listed Outriders unit")
	bike_squad = int(state.units[bike].squad)
	check(A.has(state, bike_squad, "into-the-fray"), "Captain abilities remain available while attached")
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-14, 14) if int(state.units[model].owner) == 1 else Vector2(14, 14)

	var weapon_failures: Array[String] = []
	for package: Dictionary in source_packages:
		var local_state: Dictionary = state.duplicate(true)
		var local_bike := find_model(local_state, 1, "captain-on-bike")
		var plasma_choice := choice_for(U.choices(local_state, 1), "captain-bike-pistol", local_bike, "plasma")
		var hammer_choice := choice_for(U.choices(local_state, 1), "captain-bike-melee", local_bike, "thunder-hammer")
		check(not plasma_choice.is_empty() and not hammer_choice.is_empty(), "Both reversible equipment replacements are offered for each package")
		if bool(package.plasma):
			var plasma_result := U.apply(local_state, 1, plasma_choice, Vector2.ZERO, func() -> int: return 1)
			check(plasma_result.get("error", "").is_empty(), "Plasma Pistol replacement is accepted")
		if bool(package.hammer):
			var hammer_result := U.apply(local_state, 1, hammer_choice, Vector2.ZERO, func() -> int: return 1)
			check(hammer_result.get("error", "").is_empty(), "Thunder Hammer replacement is accepted")
		var expected: Dictionary = package.weapons
		check(local_state.units[local_bike].ranged_weapons == expected.ranged and local_state.units[local_bike].melee_weapons == expected.melee, "Public choices equip the exact source package")
		weapon_failures.append_array(WeaponChecks.fixed_weapon_plan_failures(local_state, expected, local_bike, enemy_intercessors))
	check(weapon_failures.is_empty(), "Every legal package and profile passes Equipment and AttackPlan: %s" % str(weapon_failures))
	var restore_state: Dictionary = state.duplicate(true)
	var restore_bike := find_model(restore_state, 1, "captain-on-bike")
	var replace_pistol := choice_for(U.choices(restore_state, 1), "captain-bike-pistol", restore_bike, "plasma")
	var replace_melee := choice_for(U.choices(restore_state, 1), "captain-bike-melee", restore_bike, "thunder-hammer")
	U.apply(restore_state, 1, replace_pistol, Vector2.ZERO, func() -> int: return 1)
	U.apply(restore_state, 1, replace_melee, Vector2.ZERO, func() -> int: return 1)
	var restore_pistol := choice_for(U.choices(restore_state, 1), "captain-bike-pistol", restore_bike, "bolt")
	var restore_melee := choice_for(U.choices(restore_state, 1), "captain-bike-melee", restore_bike, "power-weapon")
	var pistol_restored := U.apply(restore_state, 1, restore_pistol, Vector2.ZERO, func() -> int: return 1)
	var melee_restored := U.apply(restore_state, 1, restore_melee, Vector2.ZERO, func() -> int: return 1)
	check(pistol_restored.get("error", "").is_empty() and melee_restored.get("error", "").is_empty() and restore_state.units[restore_bike].ranged_weapons == default_package.ranged and restore_state.units[restore_bike].melee_weapons == default_package.melee, "Both replacements restore to the source defaults")

	var warlord_choice: Dictionary = {}
	for option: Dictionary in U.choices(state, 1):
		if str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == bike:
			warlord_choice = option
			break
	check(not warlord_choice.is_empty(), "Captain on Bike is offered as Warlord")
	if not warlord_choice.is_empty():
		var warlord_result := U.apply(state, 1, warlord_choice, Vector2.ZERO, func() -> int: return 1)
		check(warlord_result.get("error", "").is_empty(), "Owner can designate Captain on Bike as Warlord")
	state.cp[1] = 0
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP while Captain on Bike is Warlord")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants CP only once per battle round")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.combat_doctrines.selected_turn[1] = state.turn
	var acumen := choice_for(U.choices(state, 1), "acumen", bike, "assault")
	check(not acumen.is_empty(), "Strategic Acumen offers a Combat Doctrine in the owner's Command phase")
	if not acumen.is_empty():
		var before_wrong_owner := var_to_bytes(state)
		var rejected_owner := submit_projected_choice(state, 2, acumen)
		check(not str(rejected_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(state), "Opponent cannot use the Captain's Strategic Acumen")
		var selected := submit_projected_choice(state, 1, acumen)
		check(selected.get("error", "").is_empty() and C.Doctrines.active_for(state, bike_squad) == "assault", "Owner's Strategic Acumen selects Assault Doctrine")
		check(choice_for(U.choices(state, 1), "acumen", bike, "tactical").is_empty(), "Strategic Acumen cannot be used twice in the same Command phase")
		state.active = 2
		C.Doctrines.start_command(state)
		C.UnitAbilities.start_command(state)
		check(C.Doctrines.active_for(state, bike_squad) == "assault", "Strategic Acumen persists through the opponent's Command phase")
		state.active = 1
		C.Doctrines.start_command(state)
		C.UnitAbilities.start_command(state)
		check(C.Doctrines.active_for(state, bike_squad).is_empty(), "Strategic Acumen expires at the start of the next own Command phase")

	state.phase = "fight"
	state.active = 1
	state.squads[bike_squad].charged = true
	var target := enemy_intercessors
	var melee_profile: Dictionary = state.units[bike].melee_weapons[0].profiles.standard
	var charged_weapon: Dictionary = A.weapon(state, bike, target, melee_profile, true)
	check(int(charged_weapon.get("keywords", {}).get("cleave", 0)) == 1, "Into the Fray grants Cleave 1 after a charge move")
	state.squads[bike_squad].charged = false
	var uncharged_weapon: Dictionary = A.weapon(state, bike, target, melee_profile, true)
	check(int(uncharged_weapon.get("keywords", {}).get("cleave", 0)) == 0, "Into the Fray does not grant Cleave without a charge move")

	print("Captain on Bike source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

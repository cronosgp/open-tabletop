extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(name: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}

func find_unit(s: Dictionary, owner: int, identity: String) -> int:
	for model: int in s.units:
		if s.units[model].owner == owner and C.UnitAbilities.identity(s.units[model]) == identity: return model
	return -1

func by_action(options: Array, action: String, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and (target < 0 or option.target == target) and (value.is_empty() or option.value == value): return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("captain")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000073" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Current Captain is keyed to the Wahapedia shared-book datasheet")
	check(profile.name == "Captain" and profile.points_by_models == {1: 90} and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Captain characteristics, base-profile cost and saves match the extraction")
	check(profile.keywords.has("ADEPTUS ASTARTES") and profile.keywords.has("TACTICUS") and profile.base_radius_inches > 0.78 and profile.base_radius_inches < 0.79, "Captain source keywords and 40 mm base are represented")
	check(profile.ranged[1].profiles.standard.keywords == {"assault": true, "rapid-fire": 1} and profile.melee[0].profiles.standard.attacks == 6, "Default weapons preserve Master-crafted Bolter traits and Power Weapon profile")
	check(Catalog.SPECS["captain"].get("current_reference", false), "The historical Captain entry has been migrated to a current-reference profile")

	var lists := F.selections()
	lists[1].entries = [entry("captain"), entry("intercessor-squad", 5)]
	var s: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not s.has("error"), "Current Captain and supported Intercessors materialize from local source profiles")
	if s.has("error"):
		print(s.error)
		quit(1)
		return
	var captain := find_unit(s, 1, "captain")
	var intercessors := find_unit(s, 1, "intercessor-squad")
	var squad: int = s.units[captain].squad
	var bodyguard: int = s.units[intercessors].squad
	for ability: String in ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist"]:
		check(C.UnitAbilities.has(s, squad, ability), "Captain has the source-listed %s ability" % ability)
	check(C.UnitActions.attachment_allowed(s, captain, bodyguard), "Captain can lead an eligible current Intercessor bodyguard")
	check(s.units[captain].ranged_weapons.size() == 2 and s.units[captain].max_wounds == 5, "Default Captain loadout has its pistol, bolter and five wounds")

	s.phase = "deployment"
	s.unit_abilities.setup_players = [2]
	s.awakened_dynasty.pending = []
	var choices := C.UnitActions.choices(s, 1)
	var warlord_available := false
	for option: Dictionary in choices:
		if option.action == "warlord" and option.model == captain: warlord_available = true
	check(warlord_available, "Captain is offered for Warlord designation")
	for ranged: String in ["neo-volkite", "plasma-pistol", "relic-shield"]:
		var ranged_choice := by_action(choices, "captain-ranged-loadout", squad, ranged)
		var ranged_result: String = C.unit_action(s, 1, ranged_choice, Vector2.ZERO, s.revision) if not ranged_choice.is_empty() else "choice missing"
		check(not ranged_choice.is_empty() and ranged_result.is_empty(), "Captain's %s replacement is selectable from the source options" % ranged)
		if ranged == "neo-volkite":
			check(s.units[captain].ranged_weapons.size() == 1 and s.units[captain].ranged_weapons[0].profiles.standard.keywords.get("devastating-wounds", false), "Neo-volkite option replaces both default guns and keeps Devastating Wounds")
		elif ranged == "plasma-pistol":
			var plasma: Dictionary = s.units[captain].ranged_weapons[0].profiles
			check(plasma.has("standard") and plasma.has("supercharge") and plasma.supercharge.keywords.get("hazardous", false), "Plasma Pistol offers both source profiles and Hazardous")
		else:
			check(s.units[captain].max_wounds == 6 and C.UnitAbilities.has(s, squad, "relic-shield") and s.units[captain].ranged_weapons.size() == 1, "Relic Shield replaces the bolter, preserves Heavy Bolt Pistol and grants +1 W")
		choices = C.UnitActions.choices(s, 1)
	var fist := by_action(choices, "captain-melee-loadout", squad, "power-fist")
	var fist_result: String = C.unit_action(s, 1, fist, Vector2.ZERO, s.revision) if not fist.is_empty() else "choice missing"
	check(not fist.is_empty() and fist_result.is_empty() and s.units[captain].melee_weapons[0].profiles.standard.strength == 8, "Power Fist replaces the Master-crafted Power Weapon independently")
	choices = C.UnitActions.choices(s, 1)
	var restore := by_action(choices, "captain-ranged-loadout", squad, "default")
	var restore_result: String = C.unit_action(s, 1, restore, Vector2.ZERO, s.revision) if not restore.is_empty() else "choice missing"
	check(not restore.is_empty() and restore_result.is_empty() and s.units[captain].max_wounds == 5 and not C.UnitAbilities.has(s, squad, "relic-shield"), "Restoring default ranged weapons removes Relic Shield and its wound")

	s.phase = "command"
	s.active = 1
	s.turn = 1
	s.combat_doctrines.selected_turn[1] = s.turn
	choices = C.UnitActions.choices(s, 1)
	var acumen := by_action(choices, "acumen", squad, "assault")
	var acumen_result: String = C.unit_action(s, 1, acumen, Vector2.ZERO, s.revision) if not acumen.is_empty() else "choice missing"
	check(not acumen.is_empty() and acumen_result.is_empty() and C.Doctrines.active_for(s, squad) == "assault", "Strategic Acumen activates its selected doctrine for the Captain")
	s.unit_abilities.warlords = {1: captain}
	s.round = 1
	s.cp[1] = 0
	C.UnitActions.start_round(s)
	check(s.cp[1] == 1, "Transhuman Strategist grants 1 CP when the Captain is Warlord")
	C.UnitActions.start_round(s)
	check(s.cp[1] == 1, "Captain's Transhuman Strategist cannot grant the Warlord CP twice in one round")

	print("Current Captain local checks: %d failures" % failures)
	quit(1 if failures else 0)

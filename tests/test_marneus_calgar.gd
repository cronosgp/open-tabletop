extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var members := Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, owner: int, action: String, model: int = -999, target: int = -999, value: String = "") -> Dictionary:
	for selected: Dictionary in C.UnitActions.choices(state, owner):
		if selected.action != action: continue
		if model != -999 and selected.model != model: continue
		if target != -999 and selected.target != target: continue
		if not value.is_empty() and selected.value != value: continue
		return selected
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("marneus-calgar")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004246" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Calgar profile cites the current local Wahapedia e11 export")
	check(profile.points == 180 and profile.points_by_models == {1: 180} and profile.max_supported_copies == 1, "Calgar cost, one-model composition and unique-copy restriction match the source profile")
	check(profile.stats == {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4} and profile.base_size_source_mm == 50, "Calgar characteristics, 4+ invulnerable save and base size match the export")
	check(profile.ranged[0].profiles.standard == {"name": "Gauntlets of Ultramar", "range_inches": 18.0, "attacks": 4, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"close-quarters": true, "twin-linked": true}}, "Gauntlets ranged profile matches the extracted source")
	check(profile.melee[0].profiles.standard == {"name": "Gauntlets of Ultramar", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {"twin-linked": true}} and profile.melee[1].profiles.standard.keywords == {"extra-attacks": true, "twin-linked": true}, "Both melee profiles retain their source traits, including Extra Attacks")
	check(Catalog.SPECS.get("marneus-calgar", {}).get("current_reference", false) and int(Catalog.SPECS["marneus-calgar"].get("max_supported_copies", 0)) == 1, "Calgar is admitted as one unique current-reference profile")
	check(Roster.POINTS.get("marneus-calgar", {}).get("sizes", {}) == {1: 180}, "Roster uses Calgar's local Wahapedia price")
	var conditional_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("marneus-calgar", 1), entry("cato-sicarius", 1), entry("victrix-honour-guard", 3)]}
	var conditional_admission := Roster.admit(conditional_roster)
	check(conditional_admission.error.is_empty(), "Calgar and Cato's conditional Support assignment fits the exact Victrix roster link")

	var lists := F.selections()
	lists[1].entries = [entry("marneus-calgar", 1), entry("cato-sicarius", 1), entry("victrix-honour-guard", 3), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Calgar and his current-reference targets materialize locally")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var calgar := find_model(state, 1, "marneus-calgar")
	var calgar_squad := find_squad(state, 1, "marneus-calgar")
	var cato := find_model(state, 1, "cato-sicarius")
	var cato_squad := find_squad(state, 1, "cato-sicarius")
	var victrix := find_squad(state, 1, "victrix-honour-guard")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	var terminators := find_squad(state, 1, "terminator-squad")
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	check(calgar >= 0 and C.UnitAbilities.has(state, calgar_squad, "leader") and C.UnitAbilities.has(state, calgar_squad, "deep-strike") and C.UnitAbilities.has(state, calgar_squad, "codex-adept") and C.UnitAbilities.has(state, calgar_squad, "master-tactician") and C.UnitAbilities.has(state, calgar_squad, "thunderhawk-insertion"), "Calgar exposes the Leader, Deep Strike and all three datasheet abilities")
	check(C.UnitActions.attachment_allowed(state, calgar, intercessors) and C.UnitActions.attachment_allowed(state, calgar, terminators), "Calgar can lead source-listed Intercessor and Terminator units")
	check(not C.UnitActions.attachment_allowed(state, calgar, find_squad(state, 2, "necron-warriors")), "Calgar cannot lead a target outside the local source Leader list")
	check(not C.UnitAbilities.has(state, cato_squad, "leader") and C.UnitAbilities.has(state, cato_squad, "support"), "Cato's Leader ability becomes Support while Calgar is in the army")
	check(C.UnitActions.attachment_allowed(state, cato, victrix), "Cato retains his exact Victrix target as a conditional Support")
	check(option(state, 1, "warlord", cato).is_empty() and not option(state, 1, "warlord", calgar).is_empty(), "Cato is no longer eligible as Warlord after his Leader role is replaced")
	var cato_attach := option(state, 1, "attach", cato, victrix)
	check(not cato_attach.is_empty() and C.unit_action(state, 1, cato_attach, Vector2.ZERO, state.revision).is_empty(), "Cato can attach to Victrix in the Support role when Calgar is present")
	check(state.units[cato].get("attachment_role", "") == "support", "Cato's formation is stored as Support while Calgar is in the army")
	check("assault" in Doctrines.active_doctrines_for(state, calgar_squad) and "devastator" in Doctrines.active_doctrines_for(state, calgar_squad) and "tactical" in Doctrines.active_doctrines_for(state, calgar_squad), "Codex Adept keeps all three doctrines active for Calgar's unit")

	var thunderhawk := option(state, 1, "thunderhawk-insertion", calgar, intercessors)
	check(not thunderhawk.is_empty(), "Army preparation offers a qualifying Tacticus target")
	if not thunderhawk.is_empty():
		check(C.unit_action(state, 1, thunderhawk, Vector2.ZERO, state.revision).is_empty(), "Thunderhawk Insertion records the selected target")
		check(C.UnitAbilities.every_model_has(state, intercessors, "deep-strike"), "Every model in the selected unit gains Deep Strike")
		check(option(state, 1, "thunderhawk-insertion", calgar).is_empty(), "Thunderhawk Insertion cannot select a second target")
		check(not option(state, 1, "reserve", -1, intercessors).is_empty(), "The selected unit can be placed in Strategic Reserves")
	var warlord := option(state, 1, "warlord", calgar)
	check(not warlord.is_empty(), "Calgar is eligible to be selected as Warlord")

	state.phase = "movement"
	state.turn = 1
	state.active = 1
	state.units[calgar].position = Vector2(-12, 0)
	for model: int in Geometry.alive(state, intercessors): state.units[model].position = Vector2(-5, 0)
	var tactician := option(state, 1, "master-tactician", calgar, intercessors, "assault")
	check(not tactician.is_empty(), "Master Tactician offers an unused doctrine for a visible unit within 9 inches")
	if not tactician.is_empty():
		check(C.unit_action(state, 1, tactician, Vector2.ZERO, state.revision).is_empty(), "Master Tactician applies the selected Combat Doctrine")
		check(Doctrines.has_doctrine(state, intercessors, "assault"), "The selected doctrine is active for the target unit")
		check(option(state, 1, "master-tactician", calgar, intercessors, "assault").is_empty(), "Master Tactician cannot be used twice in the same Movement phase")
		check("assault" in state.combat_doctrines.used[1], "The rule-driven doctrine selection consumes the army's shared limit")
	state.phase = "command"
	C.UnitAbilities.start_command(state)
	check(not Doctrines.has_doctrine(state, intercessors, "assault"), "Master Tactician's doctrine ends at the next own Command phase")

	print("Marneus Calgar local checks: %d failures" % failures)
	quit(1 if failures else 0)

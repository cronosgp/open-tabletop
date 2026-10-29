extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.owner) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("sanguinary-priest")
	check(profile.get("name") == "Sanguinary Priest" and profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000158", "Sanguinary Priest maps to its Blood Angels App identity")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5", "Profile records the verified local Data Export snapshot and Blood Angels App slice")
	check(profile.get("points_by_models", {}) == {1: 60} and profile.get("models", 0) == 1 and profile.get("base_size_source_mm", 0) == 40, "One-model cost and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Characteristics match the local datasheet export")
	var absolvor: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var chainsword: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(absolvor.get("name") == "Absolvor Bolt Pistol" and absolvor.get("range_inches") == 18.0 and absolvor.get("attacks") == 1 and absolvor.get("skill") == 3 and absolvor.get("strength") == 5 and absolvor.get("ap") == -2 and absolvor.get("damage") == 2 and absolvor.get("keywords", {}).get("close-quarters", false), "Absolvor Bolt Pistol retains the exact export profile")
	check(chainsword.get("name") == "Chainsword" and chainsword.get("attacks") == 5 and chainsword.get("skill") == 3 and chainsword.get("strength") == 5 and chainsword.get("ap") == -1 and chainsword.get("damage") == 1, "Chainsword retains the exact export profile")
	check(Catalog.SPECS.get("sanguinary-priest", {}).get("current_reference", false) and Roster.POINTS.get("sanguinary-priest", {}).get("sizes", {}) == {1: 60}, "The 60-point profile is admitted through the consolidated catalog")
	var expected_targets := ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "desolation-squad", "hellblaster-squad", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad"]
	var marine_targets: Array = Links.targets("sanguinary-priest")
	var support_targets: Array = Supports.links("sanguinary-priest").duplicate()
	marine_targets.sort()
	support_targets.sort()
	check(marine_targets == expected_targets and support_targets == expected_targets, "Support links match all and only the eight datasheet targets")

	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry("sanguinary-priest"), entry("intercessor-squad", 5), entry("heavy-intercessor-squad", 5)]
	lists[2].entries = [entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "movement_rerolls": false,
		"reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false,
		"marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}
	}, lists)
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Blood Angels roster materializes from the current local catalog: " + materialization_error)
	if not materialization_error.is_empty():
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var priest := find_model(state, 1, "sanguinary-priest")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	var heavies := find_squad(state, 1, "heavy-intercessor-squad")
	check(priest >= 0 and intercessors >= 0 and heavies >= 0, "Priest, eligible Intercessors and ineligible Heavy Intercessors materialize")
	if priest < 0 or intercessors < 0 or heavies < 0:
		quit(1)
		return
	check(C.UnitActions.attachment_allowed(state, priest, intercessors), "Priest can attach as Support to Intercessors")
	check(not C.UnitActions.attachment_allowed(state, priest, heavies), "Priest cannot attach to an unlisted Heavy Intercessor Squad")
	C.UnitActions.attach(state, priest, intercessors)
	check(int(state.units[priest].squad) == intercessors and str(state.units[priest].attachment_role) == "support", "Priest attaches to the source-listed bodyguard as Support")
	check(C.UnitAbilities.has(state, intercessors, "blood-chalice") and C.UnitAbilities.has(state, intercessors, "narthecium"), "The attached Priest grants Blood Chalice and Narthecium")
	var defense := DefenderGroups.defender(state, intercessors)
	check(defense.get("toughness", -1) == int(state.squads[intercessors].stats.toughness) + 1, "Blood Chalice adds one Toughness to the attached unit's defensive profile")
	state.units[priest].wounds = 0
	check(not C.UnitAbilities.has(state, intercessors, "blood-chalice") and DefenderGroups.defender(state, intercessors).get("toughness", -1) == int(state.squads[intercessors].stats.toughness), "Blood Chalice ends when the Priest is destroyed")
	state.units[priest].wounds = int(state.units[priest].max_wounds)
	state.phase = "command"
	state.active = 1
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-14, 14) if int(state.units[model].owner) == 1 else Vector2(14, 14)
	for model: int in C.living(state, intercessors):
		if model == priest: continue
		state.units[model].wounds = 1
		break
	var narthecium_choices := C.UnitActions.healing_choices(state, 1)
	var has_narthecium := false
	for option: Dictionary in narthecium_choices:
		if str(option.get("action", "")) == "narthecium" and int(option.get("model", -1)) == priest and int(option.get("target", -1)) == intercessors: has_narthecium = true
	check(has_narthecium, "Sanguinary Priest exposes the existing once-per-unit D3+1 Narthecium healing flow")
	var selected_heal := {"action": "narthecium", "model": priest, "target": intercessors}
	var heal_result: Dictionary = C.UnitActions.apply(state, 1, selected_heal, Vector2.ZERO, six)
	check(str(heal_result.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == "healing" and int(state.unit_abilities.window.get("total", 0)) == 4, "Narthecium begins its shared D3+1 healing workflow for the attached unit")

	var equipped := Equipment.select(state, priest, false)
	check(str(equipped.get("error", "")).is_empty() and equipped.stats.get("name") == "Absolvor Bolt Pistol", "Equipment resolves the Sanguinary Priest's default ranged weapon")
	print("Sanguinary Priest source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

extends SceneTree

const ArmyLegality = preload("res://scripts/edition_11/army_legality.gd")
const DetachmentCatalog = preload("res://scripts/edition_11/detachment_catalog.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/army_roster.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const ArmyLegalityPresenter = preload("res://scripts/ui/army_legality_presenter.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_detachment_dp_rules()
	_test_valid_rosters()
	_test_copy_and_epic_hero_limits()
	_test_warlord_and_supreme_commander()
	_test_enhancements()
	_test_chapters_and_supports()
	_test_transports_and_reserves_seal()
	_test_legends_gate()
	_test_presenter_read_only()
	print("Army legality checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _marine(slug: String, models: int = 1, copies: int = 1, enhancement_id: String = "") -> Dictionary:
	var entry := {"definition_id": "40kdc:11e:adeptus-astartes:" + slug, "models": models, "copies": copies}
	if not enhancement_id.is_empty():
		entry.enhancement_id = enhancement_id
	return entry

func _necron(slug: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:necrons:" + slug, "models": models, "copies": copies}

func _sel(faction: String, category: String, points_limit: int, entries: Array) -> Dictionary:
	return {"schema_version": 2, "faction": faction, "category": category, "points_limit": points_limit, "entries": entries}

func _test_detachment_dp_rules() -> void:
	var gladius := DetachmentCatalog.detachment_for("Space Marines", "gladius")
	var ironstorm := DetachmentCatalog.detachment_for("Space Marines", "ironstorm-spearhead")
	var wrath := DetachmentCatalog.detachment_for("Space Marines", "wrath-of-the-rock")
	check(DetachmentCatalog.dp_error([gladius], "incursion").is_empty(), "Incursion allows single 3 DP detachment exception")
	check(not DetachmentCatalog.dp_error([gladius, ironstorm], "incursion").is_empty(), "Incursion rejects 3 DP + 1 DP")
	check(DetachmentCatalog.dp_error([gladius, ironstorm], "strike_force").is_empty(), "Strike Force allows 3 DP + 1 DP = 4 DP")
	check(not DetachmentCatalog.dp_error([gladius, wrath], "strike_force").is_empty(), "Strike Force rejects 3 DP + 2 DP = 5 DP")
	check(DetachmentCatalog.dp_error([gladius, wrath, ironstorm], "onslaught").is_empty(), "Onslaught allows 3 + 2 + 1 = 6 DP")

func _test_valid_rosters() -> void:
	var marine_incursion := _sel("Space Marines", "incursion", 1000, [
		_marine("captain", 1, 1, StormlanceEnhancements.ADEPT_OF_THE_CODEX),
		_marine("intercessor-squad", 5, 2),
		_marine("hellblaster-squad", 5, 1),
	])
	var m_res := ArmyLegality.evaluate_selection(marine_incursion, {"detachment_id": "gladius"})
	check(bool(m_res.get("valid", false)), "Valid Space Marines Incursion roster passes: %s" % str(m_res.get("errors", [])))

	var necron_incursion := _sel("Necrons", "incursion", 1000, [
		_necron("overlord", 1, 1),
		_necron("plasmancer", 1, 1),
		_necron("necron-warriors", 10, 2),
		_necron("immortals", 5, 1),
	])
	var n_res := ArmyLegality.evaluate_selection(necron_incursion, {"detachment_id": "awakened-dynasty"})
	check(bool(n_res.get("valid", false)), "Valid Necrons Incursion roster with Cryptek Support passes: %s" % str(n_res.get("errors", [])))

func _test_copy_and_epic_hero_limits() -> void:
	var too_many_copies := _sel("Space Marines", "incursion", 1000, [
		_marine("captain", 1, 1),
		_marine("hellblaster-squad", 5, 3),
	])
	check(not bool(ArmyLegality.evaluate_selection(too_many_copies, {"detachment_id": "gladius"}).get("valid", false)), "Incursion rejects 3rd non-Battleline copy")

	var sf_3_copies := _sel("Space Marines", "strike_force", 2000, [
		_marine("captain", 1, 1),
		_marine("hellblaster-squad", 5, 3),
	])
	check(bool(ArmyLegality.evaluate_selection(sf_3_copies, {"detachment_id": "gladius"}).get("valid", false)), "Strike Force allows 3 copies of non-Battleline")

	var dup_epic := _sel("Space Marines", "strike_force", 2000, [
		_marine("roboute-guilliman", 1, 2),
	])
	check(not bool(ArmyLegality.evaluate_selection(dup_epic, {"detachment_id": "gladius"}).get("valid", false)), "Rejects duplicate EPIC HERO")

func _test_warlord_and_supreme_commander() -> void:
	var no_char := _sel("Space Marines", "incursion", 1000, [
		_marine("intercessor-squad", 5, 1),
	])
	var res := ArmyLegality.evaluate_selection(no_char, {"detachment_id": "gladius"})
	check(not bool(res.get("valid", false)) and "Warlord-eligible Character" in str(res.get("errors", [])), "Rejects roster with 0 Characters")

	var dual_sc := _sel("Space Marines", "strike_force", 2000, [
		_marine("roboute-guilliman", 1, 1),
		_marine("lion-eljonson", 1, 1),
	])
	var sc_res := ArmyLegality.evaluate_selection(dual_sc, {"detachment_id": "gladius"})
	check(not bool(sc_res.get("valid", false)), "Rejects conflicting Supreme Commanders / Chapters")

func _test_enhancements() -> void:
	var four_enh := _sel("Space Marines", "strike_force", 2000, [
		_marine("captain", 1, 1, StormlanceEnhancements.ADEPT_OF_THE_CODEX),
		_marine("captain-in-gravis-armour", 1, 1, StormlanceEnhancements.LAURELS_OF_TRIUMPH),
		_marine("captain-in-terminator-armour", 1, 1, StormlanceEnhancements.ARTIFICER_ARMOUR),
		_marine("chaplain", 1, 1, StormlanceEnhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT),
	])
	var res := ArmyLegality.evaluate_selection(four_enh, {"detachment_id": "gladius"})
	check(not bool(res.get("valid", false)), "Rejects >3 Enhancements per army")

	var wrong_det := _sel("Space Marines", "incursion", 1000, [
		_marine("captain", 1, 1, StormlanceEnhancements.TARGET_AUGURY_WEB),
	])
	var det_res := ArmyLegality.evaluate_selection(wrong_det, {"detachment_id": "gladius"})
	check(not bool(det_res.get("valid", false)), "Rejects Enhancement from another detachment")

func _test_chapters_and_supports() -> void:
	var bt_in_da := _sel("Space Marines", "incursion", 1000, [
		_marine("high-marshal-helbrecht", 1, 1),
		_marine("intercessor-squad", 5, 1),
	])
	var res := ArmyLegality.evaluate_selection(bt_in_da, {"detachment_id": "wrath-of-the-rock"})
	check(not bool(res.get("valid", false)), "Rejects Black Templars unit in Dark Angels Chapter-locked detachment")

	var orphan_support := _sel("Necrons", "incursion", 1000, [
		_necron("overlord", 1, 1),
		_necron("plasmancer", 1, 1),
	])
	var sup_res := ArmyLegality.evaluate_selection(orphan_support, {"detachment_id": "awakened-dynasty"})
	check(not bool(sup_res.get("valid", false)), "Rejects unmatched Necron Cryptek Support without bodyguard")

func _test_transports_and_reserves_seal() -> void:
	var empty_transport_list := _sel("Space Marines", "incursion", 1000, [
		_marine("captain-in-terminator-armour", 1, 1),
		_marine("impulsor", 1, 1),
	])
	# Note: Captain in Terminator Armour is INFANTRY so list-level count passes, but let's test 2 Impulsors with 1 Infantry
	var too_many_transports := _sel("Space Marines", "incursion", 1000, [
		_marine("captain", 1, 1),
		_marine("impulsor", 1, 2),
	])
	var tr_res := ArmyLegality.evaluate_selection(too_many_transports, {"detachment_id": "gladius"})
	check(not bool(tr_res.get("valid", false)), "Rejects Dedicated Transports exceeding embarkable Infantry units")

	var seal_state := {
		"points_limit": 1000,
		"unit_abilities": {"warlords": {1: 100}, "reserves": {3: {"cost": 300, "source": "strategic-reserves", "deep_strike": false}}},
		"squads": {1: {"owner": 1}, 2: {"owner": 1}, 3: {"owner": 1}},
		"units": {
			100: {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:captain", "keywords": ["CHARACTER", "INFANTRY"], "name": "Captain"},
			200: {"owner": 1, "squad": 2, "definition_id": "40kdc:11e:adeptus-astartes:impulsor", "keywords": ["VEHICLE", "DEDICATED TRANSPORT", "TRANSPORT"], "name": "Impulsor"},
		},
	}
	var seal_res := ArmyLegality.seal_formations(seal_state, 1, {"require_occupied_dedicated_transports": true})
	check(not bool(seal_res.get("ok", false)) and seal_res.get("errors", []).size() == 2, "Formation seal catches both empty Dedicated Transport and >25% Strategic Reserves")

func _test_legends_gate() -> void:
	var legends_list := _sel("Space Marines", "incursion", 1000, [
		_marine("captain", 1, 1),
		_marine("vindicator", 1, 1),
	])
	var matched := ArmyLegality.evaluate_selection(legends_list, {"detachment_id": "gladius", "legality_mode": "matched_play"})
	check(not bool(matched.get("valid", false)), "Matched Play blocks Warhammer Legends units")
	var casual := ArmyLegality.evaluate_selection(legends_list, {"detachment_id": "gladius", "legality_mode": "casual_legends"})
	check(bool(casual.get("valid", false)) and not casual.get("warnings", []).is_empty(), "Casual/Legends mode allows Warhammer Legends units with advisory warning")

func _test_presenter_read_only() -> void:
	var draft := Roster.new_list("11e", "Space Marines", "incursion", 1000)
	var before := var_to_bytes(draft)
	var summary := ArmyLegalityPresenter.summarize_draft(draft, {"legality_mode": "casual_legends"})
	check(not bool(summary.get("valid", false)) and "Legality" in str(summary.get("status_text", "")), "Presenter summarizes incomplete draft legality")
	check(var_to_bytes(draft) == before, "Presenter never mutates the army draft")

extends SceneTree

const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(copies: int) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": copies}]}

func contains_outrider_battleline(state: Dictionary, owner: int, expected: bool) -> bool:
	var found := false
	for unit: Dictionary in state.get("units", {}).values():
		if int(unit.get("owner", -1)) != owner: continue
		if str(unit.get("definition_id", "")).get_slice(":", 3) != "outrider-squad": continue
		found = true
		if ("BATTLELINE" in unit.get("keywords", [])) != expected: return false
	return found

func outrider_keywords(state: Dictionary, owner: int) -> Array:
	var result: Array = []
	for unit: Dictionary in state.get("units", {}).values():
		if int(unit.get("owner", -1)) == owner and str(unit.get("definition_id", "")).get_slice(":", 3) == "outrider-squad":
			result.append(unit.get("keywords", []).duplicate())
	return result

func run() -> void:
	for detachment_id: String in Marines.DETACHMENT_KEYWORD_GRANTS:
		var grants_by_identity: Dictionary = Marines.DETACHMENT_KEYWORD_GRANTS[detachment_id]
		for identity: String in grants_by_identity:
			var grant_profile := Marines.profile(identity)
			var effective_keywords := Marines.roster_keywords(identity, grant_profile, {}, detachment_id)
			check(not grant_profile.is_empty(), "%s keyword grant points to a current profile" % identity)
			for keyword: String in grants_by_identity[identity]:
				check(effective_keywords.has(keyword), "%s receives its registered %s grant from %s" % [identity, keyword, detachment_id])
	var profile := Marines.profile("outrider-squad")
	var baseline_keywords := Marines.roster_keywords("outrider-squad", profile, {}, "gladius")
	var darkflight_keywords := Marines.roster_keywords("outrider-squad", profile, {}, "darkflight-pursuit")
	check(not baseline_keywords.has("BATTLELINE"), "The exported Outrider profile does not have datasheet BATTLELINE")
	check(darkflight_keywords.has("BATTLELINE"), "Darkflight Pursuit adds its source-granted BATTLELINE keyword to Outriders")
	check(not Marines.roster_keywords("outrider-squad", profile, {}, "darkflight-pursuit").has("EPIC HERO"), "The detachment grant does not alter unrelated keywords")

	var baseline_three := Army.admit(selection(3), 24, {"marine_detachment": "gladius"})
	var darkflight_three := Army.admit(selection(3), 24, {"marine_detachment": "darkflight-pursuit"})
	var darkflight_four := Army.admit(selection(4), 24, {"marine_detachment": "darkflight-pursuit"})
	var darkflight_five := Army.admit(selection(5), 24, {"marine_detachment": "darkflight-pursuit"})
	check(not baseline_three.error.is_empty(), "The ordinary Incursion cap remains two without the detachment grant")
	check(darkflight_three.error.is_empty() and darkflight_three.copy_limit_keyword_context == "darkflight-pursuit", "The Incursion copy limit uses the declared Darkflight keyword context")
	check(darkflight_four.error.is_empty(), "The granted BATTLELINE keyword doubles the Incursion datasheet cap to four")
	check(not darkflight_five.error.is_empty(), "Darkflight Pursuit still rejects a fifth Outrider copy in Incursion")

	var setup := Prepared.initial_state({"combat_doctrines": true, "unit_abilities": true,
		"marine_detachments": {1: "darkflight-pursuit", 2: "gladius"}},
		{1: selection(3), 2: selection(2)})
	check(not setup.has("error"), "Prepared-match admission rechecks each current Marine roster with that player's detachment: %s" % str(setup.get("error", "")))
	if not setup.has("error"):
		check(contains_outrider_battleline(setup, 1, true), "Materialized Player 1 Outriders carry Darkflight Pursuit BATTLELINE: %s; %s" % [str(setup.get("combat_doctrines", {})), str(outrider_keywords(setup, 1))])
		check(contains_outrider_battleline(setup, 2, false), "Player 2's Gladius Outriders do not inherit Player 1's detachment keyword")

	print("Marine detachment roster admission checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

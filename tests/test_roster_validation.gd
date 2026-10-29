extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = F.P
const V = C.RosterValidation
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func pick(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, owner):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func act(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> String:
	var selected := pick(s, owner, action, model, target)
	if action.begins_with("mission-"):
		return str(submit_mission_choice(s, owner, selected, func() -> int: return 6).get("error", ""))
	return str(submit_public_unit_choice(s, owner, selected).get("error", ""))
func submit_public_unit_choice(s: Dictionary, owner: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(s, ["unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		if int(decision.get("priority_player_id", -1)) != owner: return {"error": "The current unit-action decision belongs to another player."}
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The selected unit action is not in the current decision projection."}
		payload = {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(s, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": payload, "point": Vector2.ZERO, "revision": int(s.revision)}, func() -> int: return 6)
func submit_mission_choice(s: Dictionary, owner: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var decision := PendingDecisions.current(s, ["mission-preparation"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The mission choice is not in the current projection."}
	var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(s, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": payload, "point": Vector2.ZERO, "revision": int(s.revision)}, roller)
func model_for(s: Dictionary, identity: String, owner: int) -> int:
	for model: int in s.units:
		if s.units[model].owner == owner and str(s.units[model].definition_id).get_slice(":", 3) == identity: return model
	return -1
func options() -> Dictionary:
	return {"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "terrain_layout": "ca-2026-27-take-and-hold-mirror-a-v1"}
func marine_roster_entry(identity: String, composition_choice_id: String = "") -> Dictionary:
	var profile := CurrentMarines.profile(identity)
	var entry := {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": int(profile.get("models", 1)), "copies": 1}
	if not composition_choice_id.is_empty(): entry.composition_choice_id = composition_choice_id
	return entry
func admit_marine_entries(entries: Array) -> Dictionary:
	var selection: Dictionary = F.selections()[1].duplicate(true)
	selection.entries = entries
	return V.admit(selection)
func run() -> void:
	check(V.POINTS.get("roboute-guilliman", {}).get("cost", 0) == 415 and V.POINTS.get("roboute-guilliman", {}).get("max_supported_copies", 0) == 1, "Guilliman's construction price and unique-copy boundary come from the current Wahapedia profile")
	check(V.POINTS.get("land-raider", {}).get("sizes", {}).get(1) == 245 and V.POINTS.get("land-raider", {}).get("second_plus_sizes", {}).get(1) == 265, "Checked roster pricing keeps Land Raider's separate first and second-plus source costs")
	check(V.dp_error([{"id":"gladius", "dp":3}]).is_empty(), "One 3DP detachment is a legal Incursion exception")
	check(not V.dp_error([{"id":"gladius", "dp":3},{"id":"other", "dp":1}]).is_empty(), "The 3DP exception cannot admit another detachment")
	check(not V.dp_error([{"id":"same", "dp":1},{"id":"same", "dp":1}]).is_empty(), "Duplicate detachments are rejected")
	var choices := F.selections()
	var guilliman_lists := F.selections()
	guilliman_lists[1].entries = [
		{"definition_id":"40kdc:11e:adeptus-astartes:roboute-guilliman", "models":1, "copies":1},
		{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1},
		{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":1}
	]
	var guilliman_state := P.initial_state(options(), guilliman_lists)
	check(not guilliman_state.has("error"), "Checked Roboute roster setup succeeds: " + str(guilliman_state.get("error", "")))
	if guilliman_state.has("error"):
		print("Checked Roboute roster setup error: " + str(guilliman_state.error))
		quit(1)
		return
	guilliman_state.phase = "deployment"
	guilliman_state.awakened_dynasty.pending = []
	var guilliman_model := model_for(guilliman_state, "roboute-guilliman", 1)
	var competing_warlord := model_for(guilliman_state, "captain", 1)
	var warlord_choices: Array[int] = []
	for option: Dictionary in UnitActions.choices(guilliman_state, 1):
		if option.action == "warlord": warlord_choices.append(int(option.model))
	check(guilliman_model > 0 and competing_warlord > 0 and warlord_choices == [guilliman_model], "Supreme Commander makes Guilliman the only Warlord choice in checked preparation")
	var one := V.admit(choices[1])
	var two := V.admit(choices[2])
	check(one.error.is_empty() and one.total == 615 and two.error.is_empty() and two.total == 290, "Both armies use current official MFM 1.6 totals, not historical snapshot prices")
	var tiered_roster: Dictionary = choices[1].duplicate(true)
	tiered_roster.entries = [
		{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1},
		{"definition_id":"40kdc:11e:adeptus-astartes:land-raider", "models":1, "copies":2}
	]
	var tiered_admission := V.admit(tiered_roster)
	check(tiered_admission.error.is_empty() and tiered_admission.total == int(V.POINTS.captain.cost) + 510, "Checked roster totals price Land Raider copy two at its source second-plus rate")
	var marine_full := V.inspect(V.marine_incursion_list().list)
	check(marine_full.error.is_empty() and marine_full.total == 930 and marine_full.unit_count == 7, "Checked Marines admit a 930-point Incursion list above the old six-unit training cap")
	var necron_full := V.inspect(V.necron_incursion_list().list)
	check(necron_full.error.is_empty() and necron_full.total == 880 and necron_full.unit_count == 12, "Checked Necrons admit the 880-point repetition-ceiling Incursion list")
	var invalid: Dictionary = choices[1].duplicate(true)
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:roboute-guilliman", "models":1, "copies":2}]
	check(not V.admit(invalid).error.is_empty(), "Roboute Guilliman cannot be selected more than once")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:roboute-guilliman", "models":1, "copies":1}]
	check(V.admit(invalid).error.is_empty() and V.admit(invalid).total == 415, "Guilliman's one-model roster composition uses the Wahapedia cost")
	invalid = choices[1].duplicate(true)
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:terminator-squad", "models":5, "copies":3},{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "Third Terminator is rejected by Incursion's two-unit limit, irrespective of its surcharge")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":4},{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1}]
	check(V.admit(invalid).error.is_empty() and V.admit(invalid).total == 430, "Four Battleline units plus Warlord are admitted: %s" % str(V.admit(invalid)))
	invalid.entries[0].copies = 5
	check(not V.admit(invalid).error.is_empty(), "Battleline cannot use a fifth datasheet copy in Incursion")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "A roster without a Character Warlord candidate is rejected")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1},{"definition_id":"40kdc:11e:adeptus-astartes:lieutenant", "models":1, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "Support without an eligible bodyguard is rejected before preparation")
	var source_support_roster_checks := 0
	for support_variant: Variant in Supports.BODYGUARDS:
		var support := str(support_variant)
		var target: String = Supports.BODYGUARDS[support][0]
		var source_support_admission := admit_marine_entries([
			marine_roster_entry("captain"), marine_roster_entry(support), marine_roster_entry(target)])
		check(str(source_support_admission.get("error", "")).is_empty(),
			"Checked Incursion admission accepts %s with its source-listed %s bodyguard" % [support, target])
		source_support_roster_checks += 1
	check(source_support_roster_checks == 14, "Checked Incursion admission exercises every static Support identity")
	var support_reassignment_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("ancient"), marine_roster_entry("bladeguard-ancient"),
		marine_roster_entry("intercessor-squad"), marine_roster_entry("bladeguard-veteran-squad")])
	check(str(support_reassignment_admission.get("error", "")).is_empty(),
		"Checked Incursion admission finds a legal broad-Ancient reassignment around the Bladeguard-only Support")
	var support_collision_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("ancient"), marine_roster_entry("bladeguard-ancient"),
		marine_roster_entry("bladeguard-veteran-squad")])
	check(str(support_collision_admission.get("error", "")).contains("Every Support needs an eligible admitted bodyguard"),
		"Checked Incursion admission rejects two Supports competing for one eligible bodyguard")
	var apothecary_lieutenant_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("apothecary"), marine_roster_entry("lieutenant"),
		marine_roster_entry("intercessor-squad")])
	check(str(apothecary_lieutenant_admission.get("error", "")).is_empty(),
		"Checked Incursion admission permits the source-supported Apothecary/Lieutenant shared assignment")
	var third_support_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("apothecary"), marine_roster_entry("lieutenant"),
		marine_roster_entry("judiciar"), marine_roster_entry("intercessor-squad")])
	check(str(third_support_admission.get("error", "")).contains("Every Support needs an eligible admitted bodyguard"),
		"Checked Incursion admission rejects a third Support when only one bodyguard is available")
	var separated_support_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("apothecary"), marine_roster_entry("lieutenant"),
		marine_roster_entry("judiciar"), marine_roster_entry("intercessor-squad"), marine_roster_entry("bladeguard-veteran-squad")])
	check(str(separated_support_admission.get("error", "")).is_empty(),
		"Checked Incursion admission assigns the Apothecary/Lieutenant pair and Judiciar to separate bodyguards")
	var combined_land_raider := marine_roster_entry("land-raider")
	combined_land_raider.copies = 2
	var combined_list_admission := admit_marine_entries([
		marine_roster_entry("captain"), marine_roster_entry("apothecary"), marine_roster_entry("lieutenant"),
		marine_roster_entry("intercessor-squad"), marine_roster_entry("crusader-squad"), combined_land_raider])
	var combined_land_raider_total := 0
	for row: Dictionary in combined_list_admission.get("construction", {}).get("breakdown", []):
		if str(row.get("definition_id", "")).ends_with(":land-raider"):
			combined_land_raider_total = int(row.get("total", 0))
	var combined_land_raider_price: Dictionary = V.POINTS["land-raider"]
	var combined_land_raider_expected := int(combined_land_raider_price.sizes[1]) + int(combined_land_raider_price.second_plus_sizes[1])
	check(str(combined_list_admission.get("error", "")).is_empty()
		and int(combined_list_admission.get("total", 1001)) <= 1000
		and combined_land_raider_total == combined_land_raider_expected,
		"One checked Incursion combines a Black Templars unit, shared profiles, Apothecary/Lieutenant Support assignment and tiered Land Raider copies: %s" % str(combined_list_admission.get("error", "")))
	var cato_without_victrix_admission := admit_marine_entries([
		marine_roster_entry("marneus-calgar"), marine_roster_entry("cato-sicarius"), marine_roster_entry("intercessor-squad")])
	check(str(cato_without_victrix_admission.get("error", "")).contains("Every Support needs an eligible admitted bodyguard"),
		"Checked Incursion admission treats Cato as Support with Calgar present and rejects a missing Victrix bodyguard")
	var cato_with_victrix_admission := admit_marine_entries([
		marine_roster_entry("marneus-calgar"), marine_roster_entry("cato-sicarius"),
		marine_roster_entry("victrix-honour-guard", "guards-only")])
	check(str(cato_with_victrix_admission.get("error", "")).is_empty(),
		"Checked Incursion admission accepts Cato's conditional Support slot with its source-listed Victrix bodyguard")
	invalid = choices[1].duplicate(true)
	invalid.entries = [{"definition_id": "40kdc:11e:adeptus-astartes:captain-in-phobos-armour", "models": 10, "copies": 1}]
	check(not V.admit(invalid).error.is_empty(), "An unimplemented size is not silently resized or certified")
	invalid = choices[1].duplicate(true)
	invalid.entries[0].cost = 1
	check(not V.admit(invalid).error.is_empty(), "Public selections cannot inject a client price")
	var list: Dictionary = V.preset("Space Marines").list
	var original := var_to_bytes(list)
	check(V.inspect(list).total == 290 and var_to_bytes(list) == original, "Checking never mutates a profile list")
	for entry: Dictionary in list.entries: entry.cost = 1; entry.role = "fake"; entry.source_digest = "fake"
	check(V.inspect(list).total == 290 and V.inspect(list).saved_reference_points == 3, "Saved prices, roles and source claims cannot lower current match costs")
	list.entries[0].wargear = ["custom"]
	check(not V.inspect(list).error.is_empty(), "Explicit unimplemented wargear is rejected")
	list = V.preset("Space Marines").list
	list.enhancements = ["custom"]
	check(not V.inspect(list).error.is_empty(), "Unknown enhancements cannot disappear into a fixed-loadout claim")
	list = V.preset("Space Marines").list
	list.edition = "10e"
	for entry: Dictionary in list.entries: entry.edition = "10e"
	check(not V.inspect(list).error.is_empty(), "A historical-edition list cannot be certified")
	check(P.initial_state({"checked_rosters":true}).has("error"), "Checked mode requires current mission/rule options")
	var s := P.initial_state(options(), choices)
	check(not s.has("error") and V.enabled(s) and s.roster_points_validated and s.training_points == {1:615,2:290} and s.squads[11].training_cost == 190, "Authoritative materialization and reserve costs use verified prices")
	check(s.stratagems.get("movement_rerolls", false) and s.stratagems.get("attack_rerolls", false) and s.stratagems.get("save_rerolls", false) and s.stratagems.get("damage_rerolls", false) and s.stratagems.get("hazard_rerolls", false) and s.stratagems.get("count_rerolls", false) and s.stratagems.get("escape_rerolls", false), "Checked matches enable every implemented Command Re-roll window")
	check(s.match_manifest.checked_rosters.digest == V.digest() and not s.match_manifest.official_legality_validated and not s.roster_validation.full_match_certified and not s.match_manifest.checked_rosters.full_match_certified and not s.match_manifest.checked_rosters.official_legality_validated and s.match_manifest.rules_source_status == V.CURRENT_SOURCE_STATUS, "Reference construction preserves provenance without certifying unresolved Codex rules")
	check(P.from_setup(s.saved_army_setup).pack_hash == s.pack_hash and s.pack_hash != F.fresh().pack_hash, "Setup, save and peer identities freeze the checked profile")
	check(not V.seal(s,1).is_empty() and not s.roster_validation.armies[1].formations_verified, "Formations cannot be stamped without a Warlord")
	check(act(s,1,"mission-terrain").is_empty(), "Checked setup integrates with mission choices")
	# Tied role dice require a new roll; deterministic direct provider selects P1 next.
	var rolls: Array[int] = [6,1]
	var selected := pick(s,1,"mission-roles")
	check(submit_mission_choice(s, 1, selected, func() -> int: return rolls.pop_front()).get("error", "").is_empty(), "Role roll-off")
	check(act(s,1,"mission-side",-2,1).is_empty() and act(s,1,"mission-ready",-2,0).is_empty() and act(s,2,"mission-ready",-2,0).is_empty(), "Mission preparation")
	check(C.select_awakened_attachment(s,2,4,s.revision).is_empty(), "Checked Overlord uses verified pairing")
	check(act(s,1,"warlord",300).is_empty() and not act(s,1,"setup-done").is_empty() and not s.roster_validation.armies[1].formations_verified, "Unattached Support blocks completion without setting the stamp")
	check(act(s,1,"attach",900,1).is_empty() and act(s,1,"setup-done").is_empty(), "Legal Support/Warlord declarations complete P1 construction checks")
	check(act(s,2,"warlord",600).is_empty() and act(s,2,"setup-done").is_empty() and s.roster_validation.armies[1].formations_verified and s.roster_validation.armies[2].formations_verified, "Both formations carry a persisted checked status")
	check(not s.roster_validation.full_match_certified and not s.match_manifest.official_legality_validated and not s.match_manifest.checked_rosters.full_match_certified, "Warlord/Support declarations cannot promote unresolved sources to full-match certification")
	var combined_selections: Dictionary = {1: combined_list_admission.selection, 2: choices[2]}
	var combined_state := P.initial_state(options(), combined_selections)
	check(not combined_state.has("error") and int(combined_state.get("training_points", {}).get(1, 0)) == int(combined_list_admission.total),
		"The combined Chapter/Support/tiered-price roster materializes with its checked cost")
	if not combined_state.has("error"):
		check(act(combined_state, 1, "mission-terrain").is_empty(), "Combined roster enters checked mission preparation")
		var combined_rolls: Array[int] = [6, 1]
		var combined_role_choice := pick(combined_state, 1, "mission-roles")
		check(not combined_role_choice.is_empty()
			and submit_mission_choice(combined_state, 1, combined_role_choice, func() -> int: return combined_rolls.pop_front()).get("error", "").is_empty(),
			"Combined roster passes the checked role roll-off")
		check(act(combined_state, 1, "mission-side", -2, 1).is_empty()
			and act(combined_state, 1, "mission-ready", -2, 0).is_empty()
			and act(combined_state, 2, "mission-ready", -2, 0).is_empty(),
			"Combined roster completes the checked mission setup")
		check(C.select_awakened_attachment(combined_state, 2, 4, combined_state.revision).is_empty(),
			"Opponent roster records its checked Awakened Dynasty attachment")
		var combined_captain := model_for(combined_state, "captain", 1)
		var combined_apothecary := model_for(combined_state, "apothecary", 1)
		var combined_lieutenant := model_for(combined_state, "lieutenant", 1)
		var combined_crusader := model_for(combined_state, "crusader-squad", 1)
		var combined_warlord := model_for(combined_state, "overlord", 2)
		var combined_bodyguard_squad := int(combined_state.units[combined_crusader].squad) if combined_crusader >= 0 else -1
		check(combined_captain >= 0 and combined_apothecary >= 0 and combined_lieutenant >= 0
			and combined_bodyguard_squad >= 0 and combined_warlord >= 0,
			"Combined roster materializes the Warlord, both Supports, Chapter bodyguard and opposing Warlord")
		if combined_captain >= 0 and combined_apothecary >= 0 and combined_lieutenant >= 0 and combined_bodyguard_squad >= 0 and combined_warlord >= 0:
			check(act(combined_state, 1, "warlord", combined_captain).is_empty(), "Combined Space Marines player declares its Warlord")
			check(act(combined_state, 1, "attach", combined_apothecary, combined_bodyguard_squad).is_empty()
				and act(combined_state, 1, "attach", combined_lieutenant, combined_bodyguard_squad).is_empty(),
				"The Apothecary/Lieutenant pair attaches to its shared Black Templars bodyguard through public choices")
			check(combined_state.units[combined_apothecary].squad == combined_bodyguard_squad
				and combined_state.units[combined_lieutenant].squad == combined_bodyguard_squad
				and combined_state.units[combined_apothecary].attachment_role == "support"
				and combined_state.units[combined_lieutenant].attachment_role == "support",
				"Both attached Support identities preserve their roles on the selected bodyguard")
			check(act(combined_state, 1, "setup-done").is_empty(),
				"The combined Space Marines roster seals after Warlord and Support assignment")
			check(act(combined_state, 2, "warlord", combined_warlord).is_empty()
				and act(combined_state, 2, "setup-done").is_empty()
				and combined_state.roster_validation.armies[1].formations_verified
				and combined_state.roster_validation.armies[2].formations_verified,
				"Both players seal the combined checked match without claiming full army certification")
			check(not combined_state.roster_validation.full_match_certified
				and not combined_state.match_manifest.official_legality_validated,
				"End-to-end roster sealing preserves the unresolved full-legality boundary")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.checked_rosters_choice.button_pressed = true
	var checked_ids: Array[String] = []
	for index in range(game.saved_army_pickers[1].item_count):
		var metadata: Variant = game.saved_army_pickers[1].get_item_metadata(index)
		if metadata is Dictionary and str(metadata.get("id", "")).begins_with("preset:checked-mfm16"): checked_ids.append(metadata.id)
	check(checked_ids.is_empty(), "Historical MFM rosters stay out of new-match construction choices")
	game._start_saved_match()
	check(not game.saved_army_mode and "historical" in game.status.text, "Historical MFM checks cannot start a new current-catalog match")
	var corrupt: Dictionary = s.duplicate(true)
	corrupt.roster_validation.digest = "stale"
	check(not V.enabled(corrupt), "A changed pricing profile is not silently treated as checked")
	print("Roster validation checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

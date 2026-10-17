extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = F.P
const V = C.RosterValidation
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func pick(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, owner):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func act(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> String:
	return C.unit_action(s, owner, pick(s, owner, action, model, target), Vector2.ZERO, s.revision, func() -> int: return 6)
func options() -> Dictionary:
	return {"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}
func run() -> void:
	check(V.dp_error([{"id":"gladius", "dp":3}]).is_empty(), "One 3DP detachment is a legal Incursion exception")
	check(not V.dp_error([{"id":"gladius", "dp":3},{"id":"other", "dp":1}]).is_empty(), "The 3DP exception cannot admit another detachment")
	check(not V.dp_error([{"id":"same", "dp":1},{"id":"same", "dp":1}]).is_empty(), "Duplicate detachments are rejected")
	var choices := F.selections()
	var one := V.admit(choices[1])
	var two := V.admit(choices[2])
	check(one.error.is_empty() and one.total == 615 and two.error.is_empty() and two.total == 290, "Both armies use current official MFM 1.6 totals, not historical snapshot prices")
	var marine_full := V.inspect(V.marine_incursion_list().list)
	check(marine_full.error.is_empty() and marine_full.total == 930 and marine_full.unit_count == 7, "Checked Marines admit a 930-point Incursion list above the old six-unit training cap")
	var necron_full := V.inspect(V.necron_incursion_list().list)
	check(necron_full.error.is_empty() and necron_full.total == 880 and necron_full.unit_count == 12, "Checked Necrons admit the 880-point repetition-ceiling Incursion list")
	var invalid: Dictionary = choices[1].duplicate(true)
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:terminator-squad", "models":5, "copies":3},{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "Third Terminator is rejected by Incursion's two-unit limit, irrespective of its surcharge")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":4},{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1}]
	check(V.admit(invalid).error.is_empty() and V.admit(invalid).total == 430, "Four Battleline units plus Warlord are admitted")
	invalid.entries[0].copies = 5
	check(not V.admit(invalid).error.is_empty(), "Battleline cannot use a fifth datasheet copy in Incursion")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "A roster without a Character Warlord candidate is rejected")
	invalid.entries = [{"definition_id":"40kdc:11e:adeptus-astartes:captain", "models":1, "copies":1},{"definition_id":"40kdc:11e:adeptus-astartes:lieutenant", "models":1, "copies":1}]
	check(not V.admit(invalid).error.is_empty(), "Support without an eligible bodyguard is rejected before preparation")
	invalid = choices[1].duplicate(true)
	invalid.entries[0].models = 10
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
	check(s.match_manifest.checked_rosters.digest == V.digest() and s.match_manifest.official_legality_validated and s.roster_validation.full_match_certified, "Checked CA provenance includes the implemented infantry core match")
	check(P.from_setup(s.saved_army_setup).pack_hash == s.pack_hash and s.pack_hash != F.fresh().pack_hash, "Setup, save and peer identities freeze the checked profile")
	check(not V.seal(s,1).is_empty() and not s.roster_validation.armies[1].formations_verified, "Formations cannot be stamped without a Warlord")
	check(act(s,1,"mission-terrain").is_empty(), "Checked setup integrates with mission choices")
	# Tied role dice require a new roll; deterministic direct provider selects P1 next.
	var rolls: Array[int] = [6,1]
	var selected := pick(s,1,"mission-roles")
	check(C.unit_action(s,1,selected,Vector2.ZERO,s.revision,func() -> int: return rolls.pop_front()).is_empty(), "Role roll-off")
	check(act(s,1,"mission-side",-2,1).is_empty() and act(s,1,"mission-ready",-2,0).is_empty() and act(s,2,"mission-ready",-2,0).is_empty(), "Mission preparation")
	check(C.select_awakened_attachment(s,2,4,s.revision).is_empty(), "Checked Overlord uses verified pairing")
	check(act(s,1,"warlord",300).is_empty() and not act(s,1,"setup-done").is_empty() and not s.roster_validation.armies[1].formations_verified, "Unattached Support blocks completion without setting the stamp")
	check(act(s,1,"attach",900,1).is_empty() and act(s,1,"setup-done").is_empty(), "Legal Support/Warlord declarations complete P1 construction checks")
	check(act(s,2,"warlord",600).is_empty() and act(s,2,"setup-done").is_empty() and s.roster_validation.armies[1].formations_verified and s.roster_validation.armies[2].formations_verified, "Both formations carry a persisted checked status")
	check(s.roster_validation.full_match_certified, "Warlord/Support stamps complete the checked infantry match")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.checked_rosters_choice.button_pressed = true
	var checked_ids: Array[String] = []
	for index in range(game.saved_army_pickers[1].item_count):
		var metadata: Variant = game.saved_army_pickers[1].get_item_metadata(index)
		if metadata is Dictionary and str(metadata.get("id", "")).begins_with("preset:checked-mfm16"): checked_ids.append(metadata.id)
	check(game.official_mission_choice.button_pressed and game.unit_abilities_choice.button_pressed and "preset:checked-mfm16:Space Marines" in checked_ids and "preset:checked-mfm16:Necrons" in checked_ids, "UI enables the required rules and adds two independent checked presets")
	check("preset:checked-mfm16-1000:Space Marines" in checked_ids and "preset:checked-mfm16-1000:Necrons" in checked_ids, "UI offers the 930-point Gladius and 880-point Awakened Incursion lists")
	game._start_saved_match()
	check(game.checked_rosters and V.enabled(game.state) and "MFM 1.6" in game.saved_army_review.text and game.state.training_points == {1:290,2:290}, "Real saved-list admission displays verified and stored prices separately")
	var saved: Dictionary = game.state.duplicate(true)
	var rng_state: int = game.rng.state
	game._save_match()
	game.state = F.fresh()
	game._load_match()
	check(game.state == saved and game.rng.state == rng_state and game.checked_rosters and game.checked_rosters_choice.button_pressed, "Save/load preserves source identity, option and pending formation checks")
	var corrupt: Dictionary = game.state.duplicate(true)
	corrupt.roster_validation.digest = "stale"
	check(not V.enabled(corrupt), "A changed pricing profile is not silently treated as checked")
	print("Roster validation checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

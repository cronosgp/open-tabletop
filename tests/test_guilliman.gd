extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, identity: String, owner: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func run() -> void:
	var selection := F.selections()
	selection[1].entries = [
		{"definition_id":"40kdc:11e:adeptus-astartes:roboute-guilliman", "models":1, "copies":1},
		{"definition_id":"40kdc:11e:adeptus-astartes:intercessor-squad", "models":5, "copies":1}
	]
	var state := P.initial_state({"unit_abilities":true, "combat_doctrines":true, "reanimation_protocols":true, "awakened_dynasty":true, "core_stratagems":true, "manual_allocation":false}, selection)
	check(not state.has("error"), "Wahapedia fixed profiles materialize in the current match")
	state.awakened_dynasty.pending = []
	var primarch := find_model(state, "roboute-guilliman", 1)
	var infantry := find_model(state, "intercessor-squad", 1)
	var target := find_model(state, "necron-warriors", 2)
	check(primarch > 0 and infantry > 0 and target > 0, "The fixed profile is identified in match state")
	if primarch < 0 or infantry < 0 or target < 0:
		quit(1)
		return
	var profile := Profiles.profile("roboute-guilliman")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000138" and profile.points == 415 and profile.models == 1 and profile.max_supported_copies == 1, "Source identity, composition, uniqueness and cost match the local Wahapedia export")
	check(profile.stats == {"movement_inches":8, "toughness":10, "save_target":2, "wounds":16, "leadership_target":5, "objective_control":4, "invulnerable_target":4}, "Characteristics and invulnerable save match the source")
	check(Doctrines.active_doctrines_for(state, state.units[primarch].squad).size() == 3, "Codex Adept keeps all three Combat Doctrines active")
	check({"target":5, "against":"any"} in Prevention.rules(state, primarch), "Guilliman receives one 5+ Feel No Pain roll against each wound")
	state.unit_abilities.warlords = {1:primarch}
	state.active = 1
	state.round = 2
	var cp_before := int(state.cp[1])
	UnitActions.start_round(state)
	UnitActions.start_round(state)
	check(state.cp[1] == cp_before + 1, "Transhuman Strategist grants its Warlord CP once each battle round")
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-18, 8) if state.units[model].owner == 1 else Vector2(-8, 8)
	state.units[primarch].position = Vector2(-18, 8)
	state.units[infantry].position = Vector2(-16, 8)
	state.phase = "shooting"
	state.active = 1
	check(UnitAbilities.primarch_aura_active(state, state.units[infantry].squad), "Primarch aura reaches a friendly Astartes unit within 6 inches")
	var attacks := C.AttackPlan.single_target(state, state.units[infantry].squad, state.units[target].squad, false)
	var prepared := C.AttackPlan.prepare(state, state.units[infantry].squad, false, attacks, true)
	check(prepared.get("error", "").is_empty() and prepared.get("batches", []).size() > 0 and prepared.batches[0].context.hit_reroll == "ones" and prepared.batches[0].context.wound_reroll == "ones", "Primarch aura reaches actual ranged attack hit and wound rerolls")
	check(UnitAbilities.lone_operative_active(state, primarch), "Leader of Astartes grants Lone Operative near friendly Astartes Infantry")
	state.phase = "movement"
	var author_choice := false
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.action == "author" and option.model == primarch and option.target == state.units[infantry].squad: author_choice = true
	check(author_choice, "Author of the Codex offers a visible friendly Astartes target in Movement")
	for model: int in state.units:
		if state.units[model].squad == state.units[infantry].squad: state.units[model].position = Vector2(-7, 8)
	check(not UnitAbilities.primarch_aura_active(state, state.units[infantry].squad) and not UnitAbilities.lone_operative_active(state, primarch), "Aura and conditional Lone Operative end beyond their source distances")
	print("Roboute Guilliman checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

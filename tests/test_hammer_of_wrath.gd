extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const F = preload("res://tests/all_units_fixture.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].definition_id = "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
	state.units[100].position = Vector2(-8, -8)
	state.units[200].position = Vector2(-3, -8)
	state.phase = "charge"
	Abilities.enable(state)
	return state

func charge(state: Dictionary) -> bool:
	var result := Combat.declare_charge(state, 1, 100, state.revision, func() -> int: return 3)
	if not result.error.is_empty():
		check(false, "Jump Intercessors declare a charge: " + result.error)
		return false
	result = Combat.select_charge_target(state, 1, 200, state.revision)
	if not result.error.is_empty():
		check(false, "Charge target is selected: " + result.error)
		return false
	var error := Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	if not error.is_empty():
		check(false, "Charge placement begins: " + error)
		return false
	error = Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -7.5), state.revision)
	if not error.is_empty():
		check(false, "Charging model reaches target: " + error)
		return false
	error = Combat.finish_contact_move(state, 1, state.revision)
	if not error.is_empty():
		check(false, "Legal charge ends: " + error)
		return false
	return true

func _initialize() -> void:
	var state := fixture()
	if not charge(state):
		quit(1)
		return
	check(state.squads[1].charged and state.unit_abilities.window.kind == Hammer.ID, "Completed charge opens Hammer of Wrath")
	var targets := Combat.unit_choices(state, 1)
	check(targets.size() == 2, "Attacker may select the engaged enemy or skip")
	var choice: Dictionary = targets[0] if targets[0].action == Hammer.ID else targets[1]
	check("1 engaged models" in choice.label, "Dice count follows models engaged with the chosen unit")
	var before := state.duplicate(true)
	check(not Combat.unit_action(state, 1, choice, Vector2.ZERO, state.revision, func() -> int: return 7).is_empty() and state == before, "Invalid dice reject atomically")
	check(Combat.unit_action(state, 1, choice, Vector2.ZERO, state.revision, func() -> int: return 4).is_empty(), "Host resolves one D6 for each engaged model")
	check(state.last_hammer_of_wrath.rolls == [4] and state.last_hammer_of_wrath.mortal_wounds == 1, "Each 4+ inflicts one mortal wound")
	check(state.unit_abilities.window.kind == Hammer.MORTAL_WINDOW and Combat.actor(state) == 2, "Defender receives mandatory mortal-wound allocation")
	state = bytes_to_var(var_to_bytes(state))
	var allocations := Combat.unit_choices(state, 2)
	check(not allocations.is_empty(), "Mortal allocation survives serialization")
	if not allocations.is_empty():
		state.units[allocations[0].model].feel_no_pain = [{"target": 5, "against": "mortal"}]
		check(Combat.unit_action(state, 2, allocations[0], Vector2.ZERO, state.revision, func() -> int: return 5).is_empty(), "Mortal Feel No Pain is applied")
		check(state.units[allocations[0].model].wounds == state.units[allocations[0].model].max_wounds and state.unit_abilities.window.is_empty(), "Prevented mortal closes the allocation")
	state = fixture()
	if not charge(state):
		quit(1)
		return
	targets = Combat.unit_choices(state, 1)
	choice = targets[0] if targets[0].action == Hammer.ID else targets[1]
	check(Combat.unit_action(state, 1, choice, Vector2.ZERO, state.revision, func() -> int: return 3).is_empty(), "A failed 3+ result resolves")
	check(state.last_hammer_of_wrath.mortal_wounds == 0 and state.unit_abilities.window.is_empty(), "No mortal successes opens no defender window")
	state = fixture()
	if not charge(state):
		quit(1)
		return
	targets = Combat.unit_choices(state, 1)
	var skip: Dictionary
	for item: Dictionary in targets:
		if item.action == "hammer-of-wrath-pass": skip = item
	check(not skip.is_empty() and Combat.unit_action(state, 1, skip, Vector2.ZERO, state.revision).is_empty(), "Optional Hammer of Wrath may be declined")
	check(state.unit_abilities.window.is_empty(), "Skipping the ability closes its choice window")
	var profile := Profiles.profile("assault-intercessors-with-jump-packs")
	check(profile.stats.movement_inches == 12 and profile.stats.toughness == 5 and profile.stats.wounds == 2, "Profile characteristics match the local e11 source")
	check(profile.points_by_models == {5: 95, 10: 190} and profile.max_supported_copies == 2, "Supported sizes/prices remain inside the exported first-two-unit price tier")
	check(profile.source_datasheet_id == "000002776" and "JUMP PACK" in profile.keywords and "FLY" in profile.keywords, "Runtime profile retains local source identity and source keywords")
	var jump_id := "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
	var accepted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": jump_id, "models": 10, "copies": 2}]})
	check(accepted.error.is_empty() and accepted.total == 380, "Checked local roster accepts two 10-model units at source prices")
	var too_many := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": jump_id, "models": 5, "copies": 3}]})
	check("repetition limit" in too_many.error, "Third copy is held out because its higher price tier is not represented")
	var prep := F.fresh()
	prep.phase = "deployment"
	prep.awakened_dynasty.pending = []
	prep.unit_abilities.setup_players = []
	for model: int in prep.units:
		if prep.units[model].squad != 1: continue
		prep.units[model].definition_id = "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
		prep.units[model].sergeant = model == 100
	var prep_choices := Combat.unit_choices(prep, 1)
	var sergeant_options := 0
	var trooper_plasma_options := 0
	for item: Dictionary in prep_choices:
		if item.action in ["jump-pack-sergeant-pistol", "jump-pack-sergeant-melee"]: sergeant_options += 1
		if item.action == "jump-pack-trooper-pistol" and item.value == "plasma-pistol": trooper_plasma_options += 1
	check(sergeant_options == 6 and trooper_plasma_options == 4, "Preparation exposes all Sergeant options and one regular plasma pistol bearer for a five-model squad")
	var plasma_choice: Dictionary = {}
	for item: Dictionary in prep_choices:
		if item.action == "jump-pack-trooper-pistol" and item.value == "plasma-pistol": plasma_choice = item; break
	check(not plasma_choice.is_empty() and Combat.unit_action(prep, 1, plasma_choice, Vector2.ZERO, prep.revision).is_empty(), "Regular model may replace its Heavy Bolt Pistol")
	prep_choices = Combat.unit_choices(prep, 1)
	trooper_plasma_options = 0
	for item: Dictionary in prep_choices:
		if item.action == "jump-pack-trooper-pistol" and item.value == "plasma-pistol": trooper_plasma_options += 1
	check(trooper_plasma_options == 0, "The five-model datasheet cannot exceed one regular Plasma Pistol")
	print("Hammer of Wrath checks: %d failures" % failures)
	quit(1 if failures else 0)

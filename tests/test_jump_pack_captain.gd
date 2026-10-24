extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	state.board_size = Vector2(43, 43)
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	var captain := Profiles.profile("captain-with-jump-pack")
	var bearer: Dictionary = state.units[100]
	bearer.definition_id = "40kdc:11e:adeptus-astartes:captain-with-jump-pack"
	bearer.movement = captain.stats.movement_inches
	bearer.toughness = captain.stats.toughness
	bearer.save_target = captain.stats.save_target
	bearer.max_wounds = captain.stats.wounds
	bearer.wounds = captain.stats.wounds
	bearer.objective_control = captain.stats.objective_control
	bearer.invulnerable_target = captain.stats.invulnerable_target
	bearer.keywords = captain.keywords.duplicate()
	bearer.ranged_weapons = captain.ranged.duplicate(true)
	bearer.melee_weapons = captain.melee.duplicate(true)
	var body: Dictionary = state.squads[1].duplicate(true)
	body.owner = 1
	body.name = "Assault Intercessors With Jump Packs"
	body.starting_strength = 1
	body.stats = {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds_per_model": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
	body.moved = false
	body.charge_declared = false
	state.squads[3] = body
	var trooper: Dictionary = bearer.duplicate(true)
	trooper.definition_id = "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
	trooper.squad = 3
	trooper.movement = 12
	trooper.toughness = 5
	trooper.save_target = 3
	trooper.max_wounds = 2
	trooper.wounds = 2
	trooper.objective_control = 1
	trooper.invulnerable_target = 0
	trooper.keywords = Profiles.profile("assault-intercessors-with-jump-packs").keywords.duplicate()
	trooper.ranged_weapons = Profiles.profile("assault-intercessors-with-jump-packs").ranged.duplicate(true)
	trooper.melee_weapons = Profiles.profile("assault-intercessors-with-jump-packs").melee.duplicate(true)
	trooper.sergeant = true
	trooper.position = Vector2(-8, -8)
	state.units[300] = trooper
	state.units[100].position = Vector2(-8, -8)
	state.units[200].position = Vector2(0, -8)
	Abilities.enable(state)
	state.test_jump_pack_captain_attachment_allowed = UnitActions.attachment_allowed(state, 100, 3)
	UnitActions.attach(state, 100, 3)
	state.units[100].position = Vector2(-9, -8)
	state.units[300].position = Vector2(-8, -8)
	state.units[200].position = Vector2(0, -8)
	return state

func find_choice(state: Dictionary, action: String, value: String) -> Dictionary:
	for option: Dictionary in Combat.unit_choices(state, 1):
		if option.action == action and option.value == value: return option
	return {}

func _initialize() -> void:
	var profile := Profiles.profile("captain-with-jump-pack")
	check(profile.points == 90 and profile.points_by_models == {1: 90}, "Captain source price is 90 points")
	check(profile.stats.movement_inches == 12 and profile.stats.toughness == 5 and profile.stats.wounds == 5 and profile.stats.invulnerable_target == 4, "Captain source characteristics are correct")
	check(profile.source_datasheet_id == "000000083" and "JUMP PACK" in profile.keywords and "FLY" in profile.keywords, "Captain retains local source identity and keywords")
	check(profile.ranged[0].profiles.standard.attacks == 1 and profile.melee[0].profiles.standard.attacks == 8, "Default pistol and chainsword match the extracted source")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:captain-with-jump-pack", "models": 1, "copies": 1}]})
	check(admitted.error.is_empty() and admitted.total == 90, "Locally reconciled Captain is admitted at 90 points")
	for loadout: String in ["default", "hand-flamer", "plasma-pistol", "power-fist", "relic-weapon", "thunder-hammer-shield", "chainsword-shield"]:
		var weapons := Profiles.jump_pack_captain_weapons(loadout)
		check(not weapons.is_empty() and weapons.melee.size() == 1 and weapons.relic_shield == (loadout in ["thunder-hammer-shield", "chainsword-shield"]), "Source-legal Captain loadout resolves: " + loadout)
	var state := fixture()
	check(state.get("test_jump_pack_captain_attachment_allowed", false), "Captain's source-compatible Jump Pack Leader link is admitted")
	check(not state.has("error") and state.units[100].squad == 3, "Captain attaches to the admitted Jump Pack bodyguard")
	check(Abilities.advance_modifier(state, 3) == 1 and Abilities.charge_modifier(state, 3) == 1, "Angel's Wrath reaches the attached unit")
	var offered := find_choice(state, "jump-pack-captain-loadout", "thunder-hammer-shield")
	check(not offered.is_empty() and PublicUnitCommand.error(state, 1, offered).is_empty(), "Thunder Hammer and Relic Shield are offered as one replacement set")
	check(state.units[100].max_wounds == 6 and state.units[100].wounds == 6 and Abilities.has(state, 3, "relic-shield"), "Relic Shield grants +1 W to its selected bearer")
	offered = find_choice(state, "jump-pack-captain-loadout", "default")
	check(not offered.is_empty() and PublicUnitCommand.error(state, 1, offered).is_empty(), "Default pistol/chainsword combination can be restored through the public unit-choice command")
	check(state.units[100].max_wounds == 5 and not Abilities.has(state, 3, "relic-shield"), "Restoring defaults removes the shield wound and effect")
	state.phase = "movement"
	state.squads[3].moved = false
	var error := Combat.begin_movement(state, 1, 300, "advance", state.revision, func() -> int: return 3)
	check(error.is_empty() and state.pending_move.bonus == 4 and state.pending_move.raw_bonus == 3, "Angel's Wrath adds one after the Advance D6")
	state = fixture()
	state.phase = "charge"
	var result := Combat.declare_charge(state, 1, 300, state.revision, func() -> int: return 3)
	check(result.error.is_empty() and state.pending_charge.maximum == 7, "Angel's Wrath adds one to the charge result")
	state = fixture()
	state.phase = "movement"
	state.squads[3].moved = false
	Stratagems.enable(state, true)
	state.cp[1] = 1
	error = Combat.begin_movement(state, 1, 300, "advance", state.revision, func() -> int: return 2)
	check(error.is_empty() and Stratagems.pending(state).kind == "after_advance_roll", "Command Re-roll opens before applying Angel's Wrath")
	error = Combat.resolve_roll_reaction(state, 1, 3, "command-re-roll", state.revision, func() -> int: return 5)
	check(error.is_empty() and state.pending_move.raw_bonus == 5 and state.pending_move.bonus == 6, "Re-rolled Advance adds Angel's Wrath after the final D6")
	print("Jump Pack Captain checks: %d failures" % failures)
	quit(1 if failures else 0)

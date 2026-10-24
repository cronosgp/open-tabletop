extends RefCounted
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const A = C.Awakened
const UnitActions = C.UnitActions
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
static func selections() -> Dictionary:
	return {1: {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Necrons", "category": "incursion", "points_limit": 1000, "entries": [
		{"definition_id": A.OVERLORD, "models": 1, "copies": 1},
		{"definition_id": A.BODYGUARDS[0], "models": 10, "copies": 1},
		{"definition_id": A.BODYGUARDS[1], "models": 5, "copies": 1}]}}
static func fresh(options: Dictionary = {}) -> Dictionary:
	var enabled_options := {"awakened_dynasty": true, "unit_abilities": true}
	for key: Variant in options: enabled_options[key] = options[key]
	return P.initial_state(enabled_options, selections())

static func finish_preparations(state: Dictionary) -> String:
	var action := UnitActions.setup_actor(state)
	if action == 1:
		var marine_done := _choice(state, 1, "setup-done")
		if not marine_done.is_empty(): return marine_done
	if UnitActions.setup_actor(state) == 2:
		var warlord := _choice(state, 2, "warlord", 600)
		if not warlord.is_empty(): return warlord
		var necron_done := _choice(state, 2, "setup-done")
		if not necron_done.is_empty(): return necron_done
	return "" if UnitActions.setup_actor(state) == -1 else "Preparation fixture did not finish both players."

static func _choice(state: Dictionary, player: int, action: String, model: int = -1) -> String:
	for option: Dictionary in C.unit_choices(state, player):
		if option.action == action and (model < 0 or option.model == model):
			return PublicUnitCommand.error(state, player, option)
	return "Missing preparation choice: %s" % action
static func populate(game, owner: int) -> void:
	var selection: Dictionary = selections()[owner]
	var list := P.Training.Roster.new_list("11e", selection.faction, "incursion", 1000)
	list.id = "awakened-fixture-" + str(owner)
	for entry: Dictionary in selection.entries:
		var resolved := P.Training.Capabilities.resolve(selection.faction, entry.definition_id)
		list.entries.append({"unit_id": entry.definition_id, "name": resolved.unit.name, "edition": "11e", "faction": selection.faction, "role": P.Training.Roster.role(resolved.unit.keywords), "models": entry.models, "cost": resolved.cost, "copies": entry.copies, "source_digest": resolved.pack_hash})
	var picker: OptionButton = game.saved_army_pickers[owner]
	picker.add_item("Awakened fixture " + str(owner))
	picker.set_item_metadata(picker.item_count - 1, list)
	picker.select(picker.item_count - 1)
static func combat(state: Dictionary) -> void:
	state.phase = "shooting"
	state.active = 2
	state.turn = 2
	state.terrain.areas = []
	state.cp = {1: 3, 2: 3}
	for id: int in state.units:
		if state.units[id].owner == 1:
			state.units[id].position = Vector2(-4, -4 + (id % 100) * 1.3)
		else:
			state.units[id].position = Vector2(5 + (id % 100) / 5, -4 + (id % 5) * 1.3)
	state.units[600].position = Vector2(7, -4)

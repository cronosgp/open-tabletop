extends RefCounted
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const MARINES := ["assault-intercessor-squad", "captain", "heavy-intercessor-squad", "intercessor-squad", "lieutenant", "terminator-squad"]
const NECRONS := ["immortals", "necron-warriors", "overlord", "royal-warden"]
static func selections() -> Dictionary:
	var result := {}
	for owner in [1, 2]:
		var entries: Array = []
		for name: String in MARINES if owner == 1 else NECRONS:
			entries.append({"definition_id": "40kdc:11e:%s:%s" % ["adeptus-astartes" if owner == 1 else "necrons", name], "models": 10 if name == "necron-warriors" else 1 if name in ["captain", "lieutenant", "overlord", "royal-warden"] else 5, "copies": 1})
		result[owner] = {"schema_version": 2, "faction": "Space Marines" if owner == 1 else "Necrons", "category": "incursion", "points_limit": 1000, "entries": entries}
	return result

static func current_marine_selections() -> Dictionary:
	var result := {}
	for owner in [1, 2]:
		var entries := [
			{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
			{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 10, "copies": 1}]
		if owner == 1: entries.append({"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1})
		result[owner] = {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": entries}
	return result
static func fresh() -> Dictionary:
	return P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections())
static func populate(game, owner: int) -> void:
	var selection: Dictionary = selections()[owner]
	var list := P.Training.Roster.new_list("11e", selection.faction, "incursion", 1000)
	list.id = "all-units-fixture-" + str(owner)
	for entry: Dictionary in selection.entries:
		var resolved := P.Training.Capabilities.resolve(selection.faction, entry.definition_id)
		list.entries.append({"unit_id": entry.definition_id, "name": resolved.unit.name, "edition": "11e", "faction": selection.faction, "role": P.Training.Roster.role(resolved.unit.keywords), "models": entry.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	var picker: OptionButton = game.saved_army_pickers[owner]
	picker.add_item("All unit types " + str(owner))
	picker.set_item_metadata(picker.item_count - 1, list)
	picker.select(picker.item_count - 1)

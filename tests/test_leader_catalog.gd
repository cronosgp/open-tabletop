extends SceneTree

const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const Leaders = preload("res://scripts/edition_11/leaders.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var state := {"units": {
		10: {"owner": 1, "definition_id": "40kdc:11e:adeptus-astartes:marneus-calgar"},
		11: {"owner": 2, "definition_id": "40kdc:11e:adeptus-astartes:cato-sicarius"},
	}}
	check(LeaderCatalog.army_has_calgar(state, 1), "Leader catalogue finds Calgar in the requested player's army")
	check(not LeaderCatalog.army_has_calgar(state, 2), "Leader catalogue does not find another player's Calgar")
	check(Leaders.ATTACHMENTS == LeaderCatalog.ATTACHMENTS, "Leader setup preserves the public pairing table while using the low-level catalogue")
	check(UnitAbilities != null, "Rules module loads with the leader catalogue as its low-level identity dependency")
	print("Leader catalogue checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

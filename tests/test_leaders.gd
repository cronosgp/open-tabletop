extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const Leaders = preload("res://scripts/edition_11/leaders.gd")
const CAPTAIN := "40kdc:11e:adeptus-astartes:captain"
const INTERCESSOR := "40kdc:11e:adeptus-astartes:intercessor-squad"
const TERMINATOR := "40kdc:11e:adeptus-astartes:terminator-squad"
const OVERLORD := "40kdc:11e:necrons:overlord"
const WARRIORS := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS := "40kdc:11e:necrons:immortals"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture() -> Dictionary:
	var s := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2)
	for id in range(301, 305): s.units[id].wounds = 0
	s.squads[3].starting_strength = 1
	for id in range(300, 305): s.units[id].definition_id = CAPTAIN
	return s
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(Leaders.ATTACHMENTS[CAPTAIN].has(INTERCESSOR) and Leaders.ATTACHMENTS[CAPTAIN].has(TERMINATOR), "Captain leads Intercessors and Terminators")
	check(Leaders.ATTACHMENTS[OVERLORD].has(WARRIORS) and Leaders.ATTACHMENTS[OVERLORD].has(IMMORTALS), "Overlord leads Warriors and Immortals")
	check(not Leaders.ATTACHMENTS[CAPTAIN].has(WARRIORS) and not Leaders.ATTACHMENTS[OVERLORD].has(INTERCESSOR), "No cross-faction pairing")
	var s := fixture()
	check(not Leaders.attach_error(s, 3, 1).is_empty() and not Leaders.designate_warlord(s, 3).is_empty(), "Leader rules are disabled until enabled")
	Leaders.enable(s)
	check(Leaders.is_leader(s, 3) and not Leaders.is_leader(s, 1), "Leader detection by canonical definition")
	check("leader" in s.squads[3].enabled_abilities and "leader" not in s.squads[3].disabled_abilities, "enable admits the leader capability")
	check(Leaders.can_attach(s, 3, 1) and not Leaders.can_attach(s, 3, 2) and not Leaders.can_attach(s, 1, 3), "Attachment permission and ownership checks")
	check(not Leaders.designate_warlord(s, 1).is_empty(), "A non-leader cannot be the Warlord")
	check(Leaders.designate_warlord(s, 3).is_empty() and s.warlord == 300, "Warlord is stored as a living leader model")
	var before := var_to_str(s)
	check(not Leaders.attach_error(s, 3, 2).is_empty() and var_to_str(s) == before, "Cross-owner attachment is rejected transactionally")
	check(not Leaders.attach_error(s, 3, 4).is_empty() and var_to_str(s) == before, "Unlisted bodyguard is rejected transactionally")
	check(Leaders.attach_error(s, 3, 1).is_empty() and s.squads[1].attached and s.units[300].squad == 1 and not s.squads.has(3), "Captain attaches to Intercessors as one unit")
	check(s.warlord == 300 and s.units[300].attachment_role == "leader", "Warlord pointer survives the attachment merge")
	print("Leader checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

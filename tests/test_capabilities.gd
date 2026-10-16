extends SceneTree
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Pack = preload("res://scripts/data_pack.gd")
const DIRECTORY := "res://data/imported/starter-11e-v1"
# Units that make up the Track A target armies (4 whitelisted types + commanders).
const TARGETS := {
	"adeptus-astartes": ["intercessor-squad", "terminator-squad", "captain"],
	"necrons": ["necron-warriors", "immortals", "overlord", "royal-warden"],
}
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture() -> Dictionary:
	return {"squads": {1: {"disabled_abilities": ["deep-strike", "their-number-is-legion"]}, 2: {"disabled_abilities": ["leader"]}},
		"capabilities": {}, "units": {}}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	# Registry completeness against the target army datasheets.
	for faction: String in TARGETS:
		var pack: Dictionary = Pack.load_pack(DIRECTORY.path_join(faction))
		if not pack.error.is_empty():
			push_error("Missing starter pack: " + pack.error)
			failures += 1
			continue
		for unit: Dictionary in pack.units:
			if unit.get("source_id") not in TARGETS[faction]: continue
			for slug: String in unit.get("unsupported_rules", []):
				check(Capabilities.known(slug), "%s/%s has a capability missing from the registry: %s" % [faction, unit.source_id, slug])
	# Supported flags: implemented vs blocked.
	check(Capabilities.supported("objective-secured") and Capabilities.supported("hail-of-bolts") and Capabilities.supported("implacable-eradication"), "Implemented abilities are marked supported")
	check(Capabilities.supported("insane-bravery") and Capabilities.supported("command-re-roll"), "Core stratagems are marked supported")
	check(not Capabilities.supported("deep-strike") and not Capabilities.supported("leader") and not Capabilities.supported("their-number-is-legion"), "Unimplemented unit abilities stay blocked")
	check(not Capabilities.supported("oath-of-moment") and not Capabilities.supported("reanimation-protocols"), "Faction rules stay blocked")
	check(not Capabilities.supported("combat-doctrines") and not Capabilities.supported("awakened-dynasty"), "Detachments stay blocked")
	check(not Capabilities.supported("upper-floors"), "Geometry gaps stay blocked")
	check(Capabilities.category("oath-of-moment") == Capabilities.CATEGORY_FACTION and Capabilities.category("deep-strike") == Capabilities.CATEGORY_UNIT, "Categories are correct")
	# Bookkeeping: admit + admit_squad.
	var state := fixture()
	check(not Capabilities.enabled(state, "objective-secured"), "No capability is enabled by default")
	Capabilities.admit(state, "objective-secured", "intercessor-objective-secured-v1")
	Capabilities.admit_squad(state, 1, "objective-secured")
	check(Capabilities.enabled(state, "objective-secured") and state.capabilities["objective-secured"].implementation == "intercessor-objective-secured-v1", "admit records the implementation and enabled flag")
	check("objective-secured" in state.squads[1].enabled_abilities and "objective-secured" not in state.squads[1].disabled_abilities, "admit_squad moves the capability to enabled")
	check("deep-strike" in state.squads[1].disabled_abilities and "leader" in state.squads[2].disabled_abilities, "Unrelated disabled abilities are preserved")
	Capabilities.admit_squad(state, 1, "objective-secured")
	check(state.squads[1].enabled_abilities.count("objective-secured") == 1, "admit_squad is idempotent")
	# blocked() and summary().
	var blocked := Capabilities.blocked(state)
	check("deep-strike" in blocked and "leader" in blocked and "objective-secured" not in blocked, "blocked lists only recognised unsupported abilities still disabled")
	var summary := Capabilities.summary(state)
	check("Deep Strike" in summary and "Oath of Moment" in summary and "Leader" in summary, "summary names the remaining unsupported capabilities")
	print("Capability registry checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

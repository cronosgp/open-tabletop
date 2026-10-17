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
	return {"squads": {1: {"disabled_abilities": ["deep-strike", "their-number-is-legion", "judgement-of-the-weak"]}, 2: {"disabled_abilities": ["oath-of-moment"]}},
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
	check(Capabilities.supported("objective-secured") and Capabilities.supported("hail-of-bolts") and Capabilities.supported("implacable-eradication") and Capabilities.supported("leader"), "Implemented abilities are marked supported")
	check(Capabilities.supported("insane-bravery") and Capabilities.supported("command-re-roll"), "Core stratagems are marked supported")
	check(Capabilities.supported("fire-overwatch") and Capabilities.supported("heroic-intervention") and Capabilities.supported("counteroffensive") and Capabilities.supported("epic-challenge"), "Infantry core reaction stratagems are marked supported")
	check(Capabilities.known("explosives") and not Capabilities.supported("explosives") and not Capabilities.supported("smokescreen") and not Capabilities.supported("crushing-impact"), "Keyword/role core cards unused by these lists stay blocked")
	check(Capabilities.supported("deep-strike") and Capabilities.supported("their-number-is-legion"), "Current unit implementations are registered")
	check(Capabilities.supported("oath-of-moment") and Capabilities.KNOWN["oath-of-moment"].get("reference", false), "Oath has an explicit versioned reference implementation")
	check(Capabilities.supported("reanimation-protocols"), "Scoped Reanimation implementation is registered")
	check(Capabilities.supported("combat-doctrines") and Capabilities.category("combat-doctrines") == Capabilities.CATEGORY_FACTION and Capabilities.supported("codex-discipline") and Capabilities.supported("awakened-dynasty"), "Implemented e11 doctrine and detachment effects are registered")
	check(Capabilities.supported("gladius-storm-of-devastation") and Capabilities.supported("gladius-adaptive-strategy") and Capabilities.supported("gladius-armour-of-contempt") and Capabilities.supported("gladius-might-of-angels") and Capabilities.supported("gladius-a-worthy-death") and Capabilities.supported("gladius-responsive-tactics") and Capabilities.supported("protocol-of-the-hungry-void") and Capabilities.supported("protocol-of-the-sudden-storm") and Capabilities.supported("protocol-of-the-conquering-tyrant") and Capabilities.supported("protocol-of-the-undying-legions") and Capabilities.supported("protocol-of-the-eternal-revenant") and Capabilities.supported("protocol-of-the-vengeful-stars"), "Implemented Gladius/Awakened stratagems are registered")
	check(Capabilities.supported("rapid-ingress") and Capabilities.category("transhuman-strategist") == Capabilities.CATEGORY_FACTION, "Current reserve stratagem and Captain army rule are classified")
	check(not Capabilities.supported("upper-floors"), "Geometry gaps stay blocked")
	check(Capabilities.category("oath-of-moment") == Capabilities.CATEGORY_FACTION and Capabilities.category("deep-strike") == Capabilities.CATEGORY_UNIT, "Categories are correct")
	# Bookkeeping: admit + admit_squad.
	var state := fixture()
	check(not Capabilities.enabled(state, "objective-secured"), "No capability is enabled by default")
	Capabilities.admit(state, "objective-secured", "intercessor-objective-secured-v1")
	Capabilities.admit_squad(state, 1, "objective-secured")
	check(Capabilities.enabled(state, "objective-secured") and state.capabilities["objective-secured"].implementation == "intercessor-objective-secured-v1", "admit records the implementation and enabled flag")
	check("objective-secured" in state.squads[1].enabled_abilities and "objective-secured" not in state.squads[1].disabled_abilities, "admit_squad moves the capability to enabled")
	check("deep-strike" in state.squads[1].disabled_abilities and "oath-of-moment" in state.squads[2].disabled_abilities, "Unrelated disabled abilities are preserved")
	Capabilities.admit_squad(state, 1, "objective-secured")
	check(state.squads[1].enabled_abilities.count("objective-secured") == 1, "admit_squad is idempotent")
	# blocked() and summary().
	var blocked := Capabilities.blocked(state)
	check("deep-strike" not in blocked and "their-number-is-legion" not in blocked and "judgement-of-the-weak" in blocked and "oath-of-moment" not in blocked and "objective-secured" not in blocked, "blocked lists only recognised unsupported abilities still disabled")
	var summary := Capabilities.summary(state)
	check("Judgement of the Weak" not in summary and "Upper floors" in summary, "summary names the remaining unsupported capabilities")
	print("Capability registry checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

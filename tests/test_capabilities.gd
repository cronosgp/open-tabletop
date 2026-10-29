extends SceneTree
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Pack = preload("res://scripts/data_pack.gd")
const DIRECTORY := "res://data/imported/starter-11e-v1"
const LOCALLY_VALIDATED_STATUSES := ["tests_passed_local_targeted", "source_bounded_local_scope_passed_2026_10_27", "source_bounded_local_scope_passed_2026_10_28", "source_bounded_local_scope_passed_2026_10_29", "implemented_local_checks_passed_2026_10_28"]
const IMPLEMENTATION_PENDING_STATUSES := ["implemented_local_checks_pending", "local_checks_pending"]
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
	# Every supported capability declares source, local validation and an explicit runtime scope.
	for capability: String in Capabilities.KNOWN:
		var metadata: Dictionary = Capabilities.KNOWN[capability]
		if metadata.get("supported", false):
			check(not str(metadata.get("source_status", "")).is_empty(), "%s records source applicability" % capability)
			var validation_status := str(metadata.get("validation_status", ""))
			var locally_validated := validation_status in LOCALLY_VALIDATED_STATUSES
			var implementation_pending := validation_status in IMPLEMENTATION_PENDING_STATUSES
			check(locally_validated or implementation_pending, "%s states whether local validation passed or remains pending" % capability)
			check(not str(metadata.get("scope", "")).is_empty(), "%s states its bounded scope" % capability)
			var evidence := Capabilities.validation_metadata(capability)
			check(evidence.get("network_validation_status", "") in ["not_mapped", "targeted_loopback", "partial_loopback", "deferred"], "%s exposes an explicit network evidence state" % capability)
			check(evidence.get("certification_status", "") in ["not_certified", "certified_scope"], "%s exposes an explicit certification state" % capability)
			if implementation_pending:
				check(evidence.certification_status == "not_certified", "%s remains uncertified while focused local checks are pending" % capability)
	check(Capabilities.validation_metadata("their-number-is-legion").network_validation_status == "targeted_loopback" and Capabilities.validation_metadata("command-re-roll").network_validation_status == "partial_loopback", "Mapped loopback evidence is scoped and distinguished from a complete network pass")
	check(Capabilities.validation_metadata("upper-floors").certification_status == "not_certified", "Unsupported scope is never implied certified")
	# Supported flags: implemented vs blocked.
	check(Capabilities.supported("objective-secured") and Capabilities.supported("hail-of-bolts") and Capabilities.supported("implacable-eradication") and Capabilities.supported("leader"), "Implemented abilities are marked supported")
	check(Capabilities.supported("insane-bravery") and Capabilities.supported("command-re-roll"), "Core stratagems are marked supported")
	check(Capabilities.supported("fire-overwatch") and Capabilities.supported("heroic-intervention") and Capabilities.supported("counteroffensive") and Capabilities.supported("epic-challenge"), "Infantry core reaction stratagems are marked supported")
	check(Capabilities.supported("explosives") and Capabilities.supported("smokescreen") and Capabilities.supported("crushing-impact") and Capabilities.supported("brutalis-charge") and Capabilities.supported("forward-assault-warsuit") and Capabilities.supported("strategic-knowledge") and Capabilities.supported("watch-master") and Capabilities.supported("purgatus-quarry") and Capabilities.supported("scouts-8") and Capabilities.supported("targeter-optics"), "Tank Shock, Forward Assault, Watch Master rules, Invictor Scouts 8 and Desolation Targeter Optics are exposed within their tested local scope")
	check(Capabilities.supported("deep-strike") and Capabilities.supported("their-number-is-legion") and Capabilities.supported("death-visions-of-sanguinius") and Capabilities.supported("forlorn-hero") and Capabilities.supported("lost-to-fury") and Capabilities.supported("redeemer-of-the-lost") and Capabilities.supported("mass-of-doom") and Capabilities.supported("fury-unbound") and Capabilities.supported("guardian-of-the-lost") and Capabilities.supported("heirs-of-azkaellon") and Capabilities.supported("angelic-visage") and Capabilities.supported("indomitor-doctrines"), "Current unit implementations, including Blood Angels characters, Indomitor Doctrines and Sanguinary Guard abilities, are registered")
	for capability: String in ["heirs-of-azkaellon", "angelic-visage"]:
		var validation_status := str(Capabilities.KNOWN.get(capability, {}).get("validation_status", ""))
		check(validation_status in LOCALLY_VALIDATED_STATUSES and Capabilities.source_status(capability).begins_with("wahapedia_e11_sanguinary_guard_page_observed_2026_10_28"), "%s records passed local checks and the observed 11e Guard source" % capability)
	check(Capabilities.supported("veil-of-time") and Capabilities.supported("force-dome"), "Librarian level-1 psychic abilities are registered after focused local checks")
	check(Capabilities.supported("master-of-shadows") and Capabilities.supported("blackwing-mantle"), "Aethon Shaan's current charge and Heroic Intervention abilities are registered")
	check(Capabilities.supported("rampart") and Capabilities.supported("icon-of-obstinacy") and Capabilities.supported("siege-captain") and Capabilities.supported("signum-array"), "Current Epic Hero combat abilities are registered")
	check(Capabilities.supported("oath-of-moment") and Capabilities.KNOWN["oath-of-moment"].get("reference", false), "Oath has an explicit versioned reference implementation")
	check(Capabilities.supported("reanimation-protocols"), "Scoped Reanimation implementation is registered")
	for capability: String in ["aquilon-optics", "targeter-optics", "narthecium", "honour-of-the-company", "deeds-of-legend", "bladeguard", "litany-of-hate", "spiritual-leader", "veteran-marksmen", "unstoppable-valour", "infiltrators", "hammer-of-wrath", "stealth", "chameleoline-cloaks", "hail-of-bolts", "implacable-eradication", "ca-dominance-hammer-fixed", "fights-first", "zealous-fortitude", "angel-s-wrath", "tempormortis", "special-issue-optics-and-ammunition", "priority-target-identified", "total-obliteration", "vivispectral-analysis-targeting", "close-quarters-firestorm", "rites-of-thermal-appeasement", "implacable-resilience", "engrammatic-logic", "lone-operative", "librarius", "psychic-hood", "shrouding", "soul-sight", "might-of-heroes", "thunderous-force", "epic-challenge", "explosives", "fire-overwatch", "smokescreen", "heroic-intervention", "counteroffensive", "rapid-ingress", "evade-and-survive", "driven-from-cover", "objective-secured", "vanguard-assault", "exhortation-of-rage", "combat-shield", "flexible-asset", "sentinel-protocols", "their-number-is-legion", "tactical-precision", "demi-company-commander", "my-will-be-done", "resurrection-orb", "adaptive-strategy", "oath-of-moment", "reanimation-protocols", "insane-bravery", "protocol-of-the-hungry-void", "protocol-of-the-sudden-storm", "protocol-of-the-eternal-revenant", "protocol-of-the-vengeful-stars", "protocol-of-the-conquering-tyrant", "protocol-of-the-undying-legions", "awakened-dynasty", "overlapping-destruction", "command-re-roll", "deep-strike", "scouts-6", "leader", "custom-training-mission"]:
		var validation_status := str(Capabilities.KNOWN.get(capability, {}).get("validation_status", ""))
		check(validation_status in LOCALLY_VALIDATED_STATUSES or validation_status in IMPLEMENTATION_PENDING_STATUSES, "%s records an explicit local validation state" % capability)
	check(Capabilities.source_status("implacable-resilience") == "legacy_training_reference_only" and Capabilities.source_status("engrammatic-logic") == "legacy_training_reference_only" and Capabilities.source_status("implacable-eradication") == "historical_training_reference_only" and Capabilities.source_status("hail-of-bolts") == "historical_training_reference_only" and Capabilities.source_status("objective-secured") == "historical_training_reference_only", "Historical Necron and Marine abilities remain explicitly bounded to training references")
	for capability: String in ["ironstorm-layered-ceramite", "ironstorm-might-of-the-machine-spirit", "ironstorm-headhunter-doctrine"]:
		check(Capabilities.supported(capability), "%s has focused local validation" % capability)
	var pending_local: Array[String] = ["vanguard-ambushers"]
	for capability: String in pending_local:
		check(not Capabilities.supported(capability), "%s remains blocked pending local validation" % capability)
	check(Capabilities.supported("combat-doctrines") and Capabilities.category("combat-doctrines") == Capabilities.CATEGORY_FACTION and Capabilities.supported("codex-discipline") and Capabilities.supported("awakened-dynasty") and Capabilities.supported("ironstorm-auto-targeters") and Capabilities.supported("ironstorm-redoubtable-machine-spirit") and Capabilities.supported("ironstorm-gunnery-honours"), "Implemented e11 doctrine, Ironstorm rule and enhancements are registered")
	check(not Capabilities.supported("vanguard-ambushers") and Capabilities.KNOWN["vanguard-ambushers"].validation_status == "pending_local_rule_context_validation", "Vanguard Ambushers stays blocked until unit-level Hidden, the Movement-end trigger and attack integration are locally validated")
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
	for capability: String in pending_local:
		check(not Capabilities.admit(state, capability, "unvalidated-test") and not Capabilities.enabled(state, capability), "%s cannot be admitted before local validation" % capability)
	var vanguard_admitted := Capabilities.admit(state, "vanguard-ambushers", "phobos-shock-force-vanguard-ambushers-v1")
	var vanguard_squad_admitted := Capabilities.admit_squad(state, 1, "vanguard-ambushers")
	check(not vanguard_admitted and not vanguard_squad_admitted, "Vanguard Ambushers cannot be admitted while its rule context remains unvalidated")
	for capability: String in ["ironstorm-layered-ceramite", "ironstorm-might-of-the-machine-spirit", "ironstorm-headhunter-doctrine"]:
		check(Capabilities.admit(state, capability, "ironstorm-stratagems-v1"), "%s can be admitted after targeted local validation" % capability)
	check(not Capabilities.admit_squad(state, 1, "ironstorm-headhunter-doctrine"), "Detachment stratagems cannot be admitted as per-squad abilities")
	state.capabilities["judgement-of-the-weak"] = {"implementation": "legacy-snapshot", "enabled": true}
	check(not Capabilities.enabled(state, "judgement-of-the-weak"), "Saved capability flags cannot bypass current support gates")
	check("objective-secured" in state.squads[1].enabled_abilities and "objective-secured" not in state.squads[1].disabled_abilities, "admit_squad moves the capability to enabled")
	check("deep-strike" in state.squads[1].disabled_abilities and "oath-of-moment" in state.squads[2].disabled_abilities, "Unrelated disabled abilities are preserved")
	Capabilities.admit_squad(state, 1, "objective-secured")
	check(state.squads[1].enabled_abilities.count("objective-secured") == 1, "admit_squad is idempotent")
	# blocked() and summary().
	var blocked := Capabilities.blocked(state)
	check("deep-strike" not in blocked and "their-number-is-legion" not in blocked and "judgement-of-the-weak" in blocked and "oath-of-moment" not in blocked and "objective-secured" not in blocked, "blocked lists only recognised unsupported abilities still disabled")
	var summary := Capabilities.summary(state)
	check("Judgement of the Weak" not in summary and "Complete upper floors and vertical battlefield geometry" in summary, "summary names the remaining unsupported capabilities")
	print("Capability registry checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

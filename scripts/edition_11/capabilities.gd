extends RefCounted
## Unified capability registry (roadmap A4).
## Single machine-readable source of truth for what is recognised, what is
## supported, and what is activated for a given match. Never drives gameplay
## directly; consumed by the validator, the UI and the tests.
##
## "recognised" (in KNOWN) means the id is understood and tracked.
## "supported" means a verified implementation exists.
## "enabled" (state.capabilities) means the option is active for this match.

const CATEGORY_UNIT := "unit_ability"
const CATEGORY_FACTION := "faction_rule"
const CATEGORY_DETACHMENT := "detachment"
const CATEGORY_STRATAGEM := "stratagem"
const CATEGORY_MISSION := "mission"
const CATEGORY_GEOMETRY := "geometry"

## Registry id -> metadata. supported=false means recognised but blocked until
## a verified implementation exists. Ids use the datasheet kebab-case slugs.
const KNOWN := {
	# Implemented unit abilities.
	"objective-secured": {"category": CATEGORY_UNIT, "name": "Objective Secured", "supported": true},
	"hail-of-bolts": {"category": CATEGORY_UNIT, "name": "Hail of Bolts", "supported": true},
	"implacable-eradication": {"category": CATEGORY_UNIT, "name": "Implacable Eradication", "supported": true, "reference": true},
	# Track A target unit abilities (recognised, not yet implemented).
	"target-elimination": {"category": CATEGORY_UNIT, "name": "Target Elimination", "supported": false},
	"deep-strike": {"category": CATEGORY_UNIT, "name": "Deep Strike", "supported": false},
	"fury-of-the-first": {"category": CATEGORY_UNIT, "name": "Fury of the First", "supported": false},
	"judgement-of-the-weak": {"category": CATEGORY_UNIT, "name": "Judgement of the Weak", "supported": false},
	"teleport-homer": {"category": CATEGORY_UNIT, "name": "Teleport Homer", "supported": false},
	"their-number-is-legion": {"category": CATEGORY_UNIT, "name": "Their Number is Legion", "supported": false},
	"targeted-intercession": {"category": CATEGORY_UNIT, "name": "Targeted Intercession", "supported": false},
	"unyielding-in-the-face-of-the-foe": {"category": CATEGORY_UNIT, "name": "Unyielding in the Face of the Foe", "supported": false},
	# Leaders and commanders.
	"leader": {"category": CATEGORY_UNIT, "name": "Leader", "supported": false},
	"my-will-be-done": {"category": CATEGORY_UNIT, "name": "My Will Be Done", "supported": false},
	"implacable-resilience": {"category": CATEGORY_UNIT, "name": "Implacable Resilience", "supported": false},
	"resurrection-orb": {"category": CATEGORY_UNIT, "name": "Resurrection Orb", "supported": false},
	"adaptive-strategy": {"category": CATEGORY_UNIT, "name": "Adaptive Strategy", "supported": false},
	"engrammatic-logic": {"category": CATEGORY_UNIT, "name": "Engrammatic Logic", "supported": false},
	# Faction rules.
	"oath-of-moment": {"category": CATEGORY_FACTION, "name": "Oath of Moment", "supported": false},
	"reanimation-protocols": {"category": CATEGORY_FACTION, "name": "Reanimation Protocols", "supported": false},
	# Detachments.
	"combat-doctrines": {"category": CATEGORY_DETACHMENT, "name": "Combat Doctrines", "supported": false},
	"awakened-dynasty": {"category": CATEGORY_DETACHMENT, "name": "Awakened Dynasty", "supported": false},
	# Core stratagems (implemented).
	"insane-bravery": {"category": CATEGORY_STRATAGEM, "name": "Insane Bravery", "supported": true},
	"command-re-roll": {"category": CATEGORY_STRATAGEM, "name": "Command Re-roll", "supported": true},
	# Missions and geometry.
	"custom-training-mission": {"category": CATEGORY_MISSION, "name": "Custom training mission", "supported": true},
	"upper-floors": {"category": CATEGORY_GEOMETRY, "name": "Upper floors and vertical movement", "supported": false},
	"exact-mesh-visibility": {"category": CATEGORY_GEOMETRY, "name": "Exact imported-mesh visibility", "supported": false},
}

static func known(capability: String) -> bool:
	return KNOWN.has(capability)

static func supported(capability: String) -> bool:
	return KNOWN.get(capability, {}).get("supported", false)

static func category(capability: String) -> String:
	return KNOWN.get(capability, {}).get("category", "")

static func name(capability: String) -> String:
	return KNOWN.get(capability, {}).get("name", capability)

## Record that a verified implementation is active for this match.
static func admit(state: Dictionary, capability: String, implementation: String) -> void:
	if not state.has("capabilities"): state.capabilities = {}
	state.capabilities[capability] = {"implementation": implementation, "enabled": true}

## Canonical per-squad bookkeeping: move a capability from disabled to enabled.
static func admit_squad(state: Dictionary, squad: int, capability: String) -> void:
	var entry: Dictionary = state.squads[squad]
	var disabled: Array = entry.get("disabled_abilities", []).duplicate()
	disabled.erase(capability)
	entry.disabled_abilities = disabled
	var enabled: Array = entry.get("enabled_abilities", []).duplicate()
	if capability not in enabled: enabled.append(capability)
	entry.enabled_abilities = enabled

static func enabled(state: Dictionary, capability: String) -> bool:
	return state.get("capabilities", {}).get(capability, {}).get("enabled", false)

## Recognised-but-unsupported capabilities still disabled on any squad.
static func blocked(state: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for squad: int in state.squads:
		for capability: String in state.squads[squad].get("disabled_abilities", []):
			if KNOWN.has(capability) and not supported(capability) and capability not in result:
				result.append(capability)
	result.sort()
	return result

## Human-readable scope derived from the registry, replacing hand-edited strings.
static func summary(_state: Dictionary) -> String:
	var unsupported: Array[String] = []
	for capability: String in KNOWN:
		if not KNOWN[capability].supported and capability not in unsupported:
			unsupported.append(capability)
	unsupported.sort()
	var names: Array[String] = []
	for capability: String in unsupported:
		names.append(str(KNOWN[capability].name))
	if names.is_empty(): return "All registered capabilities are supported."
	return "Not implemented: " + ", ".join(names) + "."

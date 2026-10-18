extends RefCounted
## Unified capability registry (roadmap A4).
## Single machine-readable source of truth for what is recognised, what is
## supported, and what is activated for a given match. Never drives gameplay
## directly; consumed by the validator, the UI and the tests.
##
## "recognised" (in KNOWN) means the id is understood and tracked.
## "supported" means an implementation is enabled for its declared code scope.
## "source_status" records whether current source applicability is reconciled.
## "enabled" (state.capabilities) means the option is active for this match.

const CATEGORY_UNIT := "unit_ability"
const CATEGORY_FACTION := "faction_rule"
const CATEGORY_DETACHMENT := "detachment"
const CATEGORY_STRATAGEM := "stratagem"
const CATEGORY_MISSION := "mission"
const CATEGORY_ROSTER := "roster"
const CATEGORY_GEOMETRY := "geometry"

## Registry id -> metadata. supported=false means recognised but blocked until
## a verified implementation exists. Ids use the datasheet kebab-case slugs.
const KNOWN := {
	"gladius-adaptive-strategy": {"category": CATEGORY_STRATAGEM, "name": "Adaptive Strategy (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; one unit doctrine until next own Command"},
	"gladius-storm-of-devastation": {"category": CATEGORY_STRATAGEM, "name": "Storm of Devastation (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; your Shooting, ranged Ignores Cover until the attacking unit finishes"},
	"gladius-armour-of-contempt": {"category": CATEGORY_STRATAGEM, "name": "Armour of Contempt (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; opponent Shooting or Fight, worsen incoming AP by 1 until that attacker finishes"},
	"gladius-might-of-angels": {"category": CATEGORY_STRATAGEM, "name": "Might of Angels (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; Fight, melee Lance; +1 to wound if the unit Charged"},
	"gladius-a-worthy-death": {"category": CATEGORY_STRATAGEM, "name": "A Worthy Death (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; Fight, 4+ destroyed models remain until the unit fights or the phase ends"},
	"gladius-responsive-tactics": {"category": CATEGORY_STRATAGEM, "name": "Responsive Tactics (Gladius)", "supported": true, "source_status": "current_codex_applicability_pending", "scope": "Reference profile; opponent Movement, unengaged Infantry/Mounted D6 inch reaction after an enemy ends within 8 inches"},
	"protocol-of-the-hungry-void": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Hungry Void", "supported": true, "scope": "Checked rosters v3; Fight-phase melee S and non-stacking led AP bonus"},
	"protocol-of-the-sudden-storm": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Sudden Storm", "supported": true, "scope": "Checked rosters v5; your Movement, ranged Assault until the end of the turn; led units may re-roll the Advance D6 in the existing roll window without extra CP"},
	"protocol-of-the-eternal-revenant": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Eternal Revenant", "supported": true, "scope": "Checked rosters v5; end of phase, once per Infantry Character model, unengaged set-up at half starting wounds, starting strength 1, not attached"},
	"protocol-of-the-vengeful-stars": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Vengeful Stars", "supported": true, "scope": "Checked rosters v5; opponent Shooting, after a Necron unit is destroyed, a Character within 6 inches may shoot only that attacker"},
	"protocol-of-the-conquering-tyrant": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Conquering Tyrant", "supported": true, "scope": "Checked rosters v4; your Shooting, half-range hit re-roll of 1s or all hits if led"},
	"protocol-of-the-undying-legions": {"category": CATEGORY_STRATAGEM, "name": "Protocol of the Undying Legions", "supported": true, "scope": "Checked rosters v4; after enemy attacks destroy models, Reanimation D3 or D3+1 if led"},
	"checked-incursion-rosters": {"category": CATEGORY_ROSTER, "name": "MFM 1.6 reference Incursion rosters", "supported": false, "source_status": "pending_current_codex_datasheet_and_effect_reconciliation", "scope": "Executable ten-profile reference snapshot; MFM 1.6 prices were checked 17 October after the 14 October official update, but current datasheet effects and full army legality remain uncertified"},
	"ca-dominance-hammer-fixed": {"category": CATEGORY_MISSION, "name": "CA 2026-27: Dominance / Hammer / fixed Engage + Assassination", "supported": true, "scope": "Selected mission; custom terrain, reference armies; no points legality certification"},
	# Implemented unit abilities.
	"objective-secured": {"category": CATEGORY_UNIT, "name": "Objective Secured", "supported": true},
	"hail-of-bolts": {"category": CATEGORY_UNIT, "name": "Hail of Bolts", "supported": true},
	"implacable-eradication": {"category": CATEGORY_UNIT, "name": "Implacable Eradication", "supported": true, "reference": true},
	# Current implementations and explicitly superseded historical names.
	"target-elimination": {"category": CATEGORY_UNIT, "name": "Target Elimination", "supported": false, "superseded": true},
	"deep-strike": {"category": CATEGORY_UNIT, "name": "Deep Strike", "supported": true, "source_status": "current_codex_applicability_pending"},
	"fury-of-the-first": {"category": CATEGORY_UNIT, "name": "Fury of the First", "supported": true, "source_status": "current_codex_applicability_pending"},
	"judgement-of-the-weak": {"category": CATEGORY_UNIT, "name": "Judgement of the Weak", "supported": false, "superseded": true},
	"teleport-homer": {"category": CATEGORY_UNIT, "name": "Teleport Homer", "supported": true, "source_status": "current_codex_applicability_pending"},
	"their-number-is-legion": {"category": CATEGORY_UNIT, "name": "Their Number is Legion", "supported": true},
	"targeted-intercession": {"category": CATEGORY_UNIT, "name": "Targeted Intercession", "supported": true, "source_status": "current_codex_applicability_pending"},
	"unyielding-in-the-face-of-the-foe": {"category": CATEGORY_UNIT, "name": "Unyielding in the Face of the Foe", "supported": true, "source_status": "current_codex_applicability_pending"},
	"bolter-discipline": {"category": CATEGORY_UNIT, "name": "Bolter Discipline", "supported": true, "source_status": "current_codex_applicability_pending"},
	"tactical-mainstay": {"category": CATEGORY_UNIT, "name": "Tactical Mainstay", "supported": true, "source_status": "current_codex_applicability_pending"},
	"strategic-acumen": {"category": CATEGORY_UNIT, "name": "Strategic Acumen", "supported": true, "source_status": "current_codex_applicability_pending"},
	"finest-hour": {"category": CATEGORY_UNIT, "name": "Finest Hour", "supported": true, "source_status": "current_codex_applicability_pending"},
	"transhuman-strategist": {"category": CATEGORY_FACTION, "name": "Transhuman Strategist", "supported": true, "source_status": "current_codex_applicability_pending"},
	"support": {"category": CATEGORY_UNIT, "name": "Support", "supported": true, "source_status": "current_codex_applicability_pending"},
	"tactical-precision": {"category": CATEGORY_UNIT, "name": "Tactical Precision", "supported": true, "source_status": "current_codex_applicability_pending"},
	"target-priority": {"category": CATEGORY_UNIT, "name": "Target Priority (historical)", "supported": false, "superseded": true},
	"demi-company-commander": {"category": CATEGORY_UNIT, "name": "Demi Company Commander", "supported": true, "source_status": "current_codex_applicability_pending"},
	# Leaders and commanders.
	"leader": {"category": CATEGORY_UNIT, "name": "Leader", "supported": true, "reference": true},
	"my-will-be-done": {"category": CATEGORY_UNIT, "name": "My Will Be Done", "supported": true},
	"implacable-resilience": {"category": CATEGORY_UNIT, "name": "Implacable Resilience", "supported": true},
	"resurrection-orb": {"category": CATEGORY_UNIT, "name": "Resurrection Orb", "supported": true},
	"adaptive-strategy": {"category": CATEGORY_UNIT, "name": "Adaptive Strategy", "supported": true},
	"engrammatic-logic": {"category": CATEGORY_UNIT, "name": "Engrammatic Logic", "supported": true},
	# Faction rules.
	"oath-of-moment": {"category": CATEGORY_FACTION, "name": "Oath of Moment (June 2026 profile)", "supported": true, "reference": true},
	"reanimation-protocols": {"category": CATEGORY_FACTION, "name": "Reanimation Protocols", "supported": true, "scope": "Warriors/Immortals, living Overlords/Royal Wardens and their admitted attachments"},
	# Detachments.
	"combat-doctrines": {"category": CATEGORY_FACTION, "name": "Combat Doctrines (11e)", "supported": true, "source_status": "current_codex_applicability_pending"},
	"codex-discipline": {"category": CATEGORY_DETACHMENT, "name": "Codex Discipline (Gladius extra doctrine use)", "supported": true, "source_status": "current_codex_applicability_pending"},
	"awakened-dynasty": {"category": CATEGORY_DETACHMENT, "name": "Awakened Dynasty: Command Protocols", "supported": true, "scope": "Led Necron units; other detachment rules remain pending"},
	# Core stratagems (implemented).
	"insane-bravery": {"category": CATEGORY_STRATAGEM, "name": "Insane Bravery", "supported": true},
	"rapid-ingress": {"category": CATEGORY_STRATAGEM, "name": "Rapid Ingress", "supported": true, "scope": "Current-unit Terminator reserve workflow"},
	"command-re-roll": {"category": CATEGORY_STRATAGEM, "name": "Command Re-roll", "supported": true, "scope": "Checked matches enable every implemented Command Re-roll window"},
	"epic-challenge": {"category": CATEGORY_STRATAGEM, "name": "Epic Challenge (15.03)", "supported": true, "scope": "Core; melee Precision for a Character model after it is selected to fight"},
	"explosives": {"category": CATEGORY_STRATAGEM, "name": "Explosives / Grenades (15.05)", "supported": false, "scope": "Core; requires EXPLOSIVES/GRENADES. Track A loadouts do not expose that keyword yet"},
	"crushing-impact": {"category": CATEGORY_STRATAGEM, "name": "Crushing Impact / Tank Shock (15.06)", "supported": false, "scope": "Core; Monster/Vehicle only — outside Gladius 930 vs Awakened 880"},
	"fire-overwatch": {"category": CATEGORY_STRATAGEM, "name": "Fire Overwatch (15.08)", "supported": true, "scope": "Core; end of opponent Movement, snap shooting (unmodified 6s, not critical hits, no hit rerolls)"},
	"smokescreen": {"category": CATEGORY_STRATAGEM, "name": "Smokescreen (15.10)", "supported": false, "scope": "Core; requires SMOKE. Track A loadouts do not expose that keyword yet"},
	"heroic-intervention": {"category": CATEGORY_STRATAGEM, "name": "Heroic Intervention (15.11)", "supported": true, "scope": "Core; end of opponent Charge. Leap to Defend 1 CP or Into the Fray +1 CP with charge cap 6"},
	"counteroffensive": {"category": CATEGORY_STRATAGEM, "name": "Counteroffensive (15.12)", "supported": true, "scope": "Core; opponent Fight, 2 CP, Fights First after an enemy unit resolves attacks"},
	# Missions and geometry.
	"custom-training-mission": {"category": CATEGORY_MISSION, "name": "Custom training mission", "supported": true},
	"upper-floors": {"category": CATEGORY_GEOMETRY, "name": "Upper floors and vertical movement", "supported": false},
	"exact-mesh-visibility": {"category": CATEGORY_GEOMETRY, "name": "Exact imported-mesh visibility", "supported": false},
}

static func known(capability: String) -> bool:
	return KNOWN.has(capability)

static func supported(capability: String) -> bool:
	return KNOWN.get(capability, {}).get("supported", false)

static func source_status(capability: String) -> String:
	return str(KNOWN.get(capability, {}).get("source_status", "not_recorded"))

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
		if not KNOWN[capability].supported and not KNOWN[capability].get("superseded", false) and capability not in unsupported:
			unsupported.append(capability)
	unsupported.sort()
	var names: Array[String] = []
	for capability: String in unsupported:
		names.append(str(KNOWN[capability].name))
	if names.is_empty(): return "All registered capabilities are supported."
	return "Not implemented: " + ", ".join(names) + "."

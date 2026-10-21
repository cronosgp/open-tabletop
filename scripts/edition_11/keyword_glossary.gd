extends RefCounted
## Contextual summaries for weapon abilities and combat traits used by supported 11e attacks.
## Checked against the June 2026 Core Rules; this glossary is not a support declaration.

const RULES_VERSION := "Warhammer 40,000 11th edition Core Rules (June 2026)"
const RULES_URL := "https://wahapedia.ru/wh40k11ed/the-rules/core-rules/"

const PHASES := {
	"start_turn": {"name": "Start of Turn", "summary": "Resolve rules triggered at the start of this turn before Command.", "ref": "§07.02"},
	"command": {"name": "Command Phase", "summary": "Core CP, Battle-shock and Command Abilities are handled in the sequence shown for this match.", "ref": "§08"},
	"movement": {"name": "Movement Phase", "summary": "Move eligible units and resolve supported arrival or movement decisions.", "ref": "§09"},
	"shooting": {"name": "Shooting Phase", "summary": "Select eligible units to make ranged attacks and resolve the resulting decisions.", "ref": "§10"},
	"charge": {"name": "Charge Phase", "summary": "Declare eligible charges, roll, then resolve or decline the charge move.", "ref": "§11"},
	"fight": {"name": "Fight Phase", "summary": "Both players resolve eligible melee combats. Follow the current pile-in, attacks or consolidation step shown in Play.", "ref": "§12"},
	"end_turn": {"name": "End of Turn", "summary": "Resolve end-of-turn rules and mission checks before the turn changes.", "ref": "§07.02.02"}
}

const DEFINITIONS := {
	"assault": {"name": "Assault", "rule": "A unit that Advanced can use Assault Shooting if it has an Assault weapon; that shooting can select only Assault weapons.", "ref": "§§10.05, 24.04"},
	"anti-fly": {"name": "Anti-Fly X+", "rule": "Against a target with the FLY keyword, an unmodified Wound roll of X+ is a Critical Wound.", "ref": "Core Rules — Anti-X"},
	"anti-vehicle": {"name": "Anti-Vehicle X+", "rule": "Against a target with the VEHICLE keyword, an unmodified Wound roll of X+ is a Critical Wound.", "ref": "Core Rules — Anti-X"},
	"blast": {"name": "Blast", "rule": "Adds attack dice for each five models the target had when selected (round down). Blast X adds X dice per five. It cannot target an engaged unit.", "ref": "§24.05"},
	"close-quarters": {"name": "Close-quarters", "rule": "Enables close-quarters shooting against units your unit is engaged with, subject to the shooting-type and model restrictions in the Core Rules.", "ref": "§§10.06, 24.07"},
	"devastating-wounds": {"name": "Devastating Wounds", "rule": "A critical wound inflicts mortal wounds equal to the weapon's Damage after its normal damage; each critical wound can damage at most one model, and excess is lost.", "ref": "§24.10"},
	"extra-attacks": {"name": "Extra Attacks", "rule": "When the model fights, it selects all its Extra Attacks weapons in addition to one other melee weapon, if possible.", "ref": "§24.11"},
	"hazardous": {"name": "Hazardous", "rule": "After attacks, the unit rolls once per selected Hazardous weapon. A 1–2 causes 1 mortal wound, or 3 if every model is a MONSTER/VEHICLE.", "ref": "§§06.03, 24.15"},
	"heavy": {"name": "Heavy", "rule": "In the Shooting phase, +1 to the Hit roll applies if the unit is unengaged, was not set up this turn, and no model in it moved more than 3 inches this turn.", "ref": "§24.16"},
	"hunter": {"name": "Hunter", "rule": "This weapon profile can target only units with at least one of its listed keywords.", "ref": "§04.01.03"},
	"ignores-cover": {"name": "Ignores Cover", "rule": "The target cannot have the Benefit of Cover against this attack.", "ref": "§24.18"},
	"lance": {"name": "Lance", "rule": "Each attack with this weapon gets +1 to its Wound roll if the attacking model's unit made a Charge move this turn.", "ref": "§24.21"},
	"lethal-hits": {"name": "Lethal Hits", "rule": "On a Critical Hit, you may automatically wound instead of making a Wound roll. That attack then cannot cause a Critical Wound.", "ref": "§24.23"},
	"precision": {"name": "Precision", "rule": "When allocating these attacks, the attacker may select an allocation group containing a visible Character in the target unit.", "ref": "§24.28"},
	"rapid-fire": {"name": "Rapid Fire", "rule": "Rapid Fire X adds X attack dice if the target was within half the weapon's Range when selected.", "ref": "§24.30"},
	"sustained-hits": {"name": "Sustained Hits", "rule": "On a Critical Hit, the attack scores X additional hits, where X is the weapon's value.", "ref": "§24.36"},
	"torrent": {"name": "Torrent", "rule": "Attacks made with this weapon automatically hit; no Hit roll is made.", "ref": "§24.37"},
	"twin-linked": {"name": "Twin-linked", "rule": "You may re-roll the Wound roll for each attack made with this weapon.", "ref": "§24.38"}
}

static func describe_weapon(option: Dictionary) -> String:
	if option.is_empty() or option.has("error"): return "Select a weapon profile to view its supported keywords."
	var stats: Dictionary = option.get("stats", {})
	var keywords: Dictionary = stats.get("keywords", {})
	var lines: Array[String] = [str(option.get("label", stats.get("name", "Weapon profile")))]
	if keywords.is_empty():
		lines.append("No supported weapon abilities are listed on this profile.")
	else:
		for key: String in keywords:
			var definition: Dictionary = DEFINITIONS.get(key, {})
			if definition.is_empty():
				lines.append("%s: no glossary entry. A listed trait does not imply that its full effect is implemented." % key.replace("-", " ").capitalize())
				continue
			var value: Variant = keywords[key]
			var name := str(definition.name)
			if value is int and value > 0: name += " %d" % value
			elif key == "hunter": name += " • " + str(value)
			lines.append("%s: %s (%s)." % [name, definition.rule, definition.ref])
	lines.append("Scope: current 11e rules summary; only mechanics enabled by this match are resolved.")
	lines.append(RULES_VERSION)
	lines.append("Reference: " + RULES_URL)
	return "\n\n".join(lines)

static func describe_attack_target() -> String:
	return "The listed targets passed this profile's current attack-planner eligibility checks. Range, visibility, engagement and weapon restrictions are checked again when the plan is confirmed."

static func describe_move_type(move_type: String) -> String:
	var summary := ""
	match move_type:
		"normal": summary = "Normal Move: an eligible unengaged unit can move up to its M characteristic and must end unengaged. Core Rules §§09.02, 09.05."
		"advance": summary = "Advance: roll one D6 before moving; an eligible unengaged unit can move up to M plus that result. It must end unengaged and, until turn end, cannot declare a charge or start an Action unless a rule says otherwise. Core Rules §09.06."
		"ordered_retreat": summary = "Ordered Retreat: a Fall Back mode for an engaged unit that is not Battle-shocked. Move up to M and end unengaged; until turn end, the unit cannot shoot, declare a charge or start an Action unless a rule says otherwise. Core Rules §09.07."
		"desperate_escape": summary = "Desperate Escape: a Fall Back mode; you may choose it while not Battle-shocked, but a Battle-shocked unit must use it. Before moving, make a Hazard roll for each model. Moved models can pass through enemy models, but the unit must end unengaged; shooting, charges and Actions are unavailable until turn end. If the unit was not Battle-shocked, it takes a Battle-shock roll after moving. Core Rules §§01.07, 06.03, 09.07."
		"stationary": summary = "Remain Stationary: move or rotate no models. The unit does not trigger rules for starting or ending a move. Core Rules §09.04."
		_: return ""
	return summary + "\n" + RULES_VERSION + ".\nReference: " + RULES_URL

static func describe_charge_roll() -> String:
	return "Charge roll: roll 2D6; the result is the maximum distance for this charge move. After the roll, select one or more eligible charge targets, then attempt a legal move or decline. Core Rules §§11.02, 11.04.\n" + RULES_VERSION + ".\nReference: " + RULES_URL

static func describe_contact_action(phase: String, fight_step: String = "") -> String:
	var summary := ""
	if phase == "charge":
		summary = "Charge placement: choose the charge target(s) shown by the current eligibility check. The unit must end engaged with every selected target and cannot end engaged with a non-target. Review the preview before confirming. Core Rules §11.04."
	elif phase == "fight" and fight_step == "pile_in":
		summary = "Pile-in: move eligible models up to 3\" toward the selected target; models in base contact cannot move. The unit must end engaged, and models already engaged must remain engaged with those enemies. Core Rules §12.03."
	elif phase == "fight" and fight_step == "consolidate":
		summary = "Consolidation: an eligible unit can move up to 3\" using an allowed mode. Depending on nearby enemies and objectives, the move must preserve engagement, engage selected enemies or reach a selected objective. Core Rules §12.08."
	elif phase == "fight":
		summary = "This placement control is available only for the supported Fight-step action shown by the button. The validator checks legal positions before confirmation. Core Rules §§12.03, 12.06, 12.08."
	else:
		return ""
	return summary + "\n" + RULES_VERSION + ".\nReference: " + RULES_URL

static func describe_phase(phase: String, fight_step: String = "") -> String:
	var definition: Dictionary = PHASES.get(phase, {})
	if definition.is_empty(): return "Resolve the current setup or match decision shown above before continuing."
	var result := "%s — %s (%s)." % [definition.name, definition.summary, definition.ref]
	if phase == "fight" and not fight_step.is_empty():
		result += "\nCurrent Fight step: %s." % fight_step.replace("_", " ").capitalize()
	result += "\nThis prototype resolves only its documented supported rules. " + RULES_VERSION + "."
	result += "\nReference: " + RULES_URL
	return result

static func describe_action_group_reference(group: String, phase: String) -> String:
	var reference := ""
	match group:
		"movement": reference = "Core Rules §03.03 (Coherency) and §09."
		"contact": reference = "Core Rules §11 (Charge) and §12 (Fight)."
		"attack": reference = "Core Rules §§04–05; Shooting §10 or Fight §12 as applicable."
		"defense": reference = "Core Rules §§05.03–05.04 and 06.02–06.03."
		"objectives": reference = "Core Rules §14 and §16 where an Action is involved."
		"phase": return describe_phase(phase)
		_: return ""
	return reference + "\n" + RULES_VERSION + "\nReference: " + RULES_URL

static func describe_lethal_choice() -> String:
	return "For each Lethal Hits Critical Hit in this plan, choose whether to automatically wound or make a Wound roll. Automatic wounds cannot trigger Critical Wound abilities such as Devastating Wounds. Core Rules §24.23 (June 2026). " + RULES_URL

static func describe_stratagem_decision(kind: String, eligible: bool, reason: String = "") -> String:
	var summary := ""
	match kind:
		"before_battle_shock":
			summary = "Insane Bravery costs 1 CP and automatically passes this Battle-shock roll. It can be used once per battle, before rolling. Core Rules §15.04."
		"after_advance_roll":
			summary = "Command Re-roll costs 1 CP. It replaces the selected Advance die; the new result stands. Core Rules §§15.01–15.02."
		"after_charge_roll":
			summary = "Command Re-roll costs 1 CP. It replaces both Charge dice; the new result stands. Core Rules §§15.01–15.02."
		"after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll":
			summary = "Command Re-roll costs 1 CP. Select one eligible die to replace; the new result stands. Core Rules §§15.01–15.02."
		_:
			return ""
	if not eligible and not reason.is_empty(): summary += "\nUnavailable: " + reason
	summary += "\n" + RULES_VERSION + ".\nReference: " + RULES_URL
	return summary

static func describe_accept_decision(kind: String) -> String:
	if kind == "before_battle_shock":
		return "Roll this Battle-shock test normally. This choice costs no CP. Core Rules §08. " + RULES_VERSION + ".\nReference: " + RULES_URL
	if kind.begins_with("after_"):
		return "Keep the result currently shown and continue. This choice costs no CP. " + RULES_VERSION + ".\nReference: " + RULES_URL
	return ""

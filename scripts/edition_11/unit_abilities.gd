extends RefCounted
## Current e11 datasheet effects; fixed-loadout training, not list certification.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ID := "track-a-current-datasheets-2026-10-v2"
const RULES := {
	"intercessor-squad": ["bolter-discipline", "tactical-mainstay"],
	"assault-intercessor-squad": ["targeted-intercession"],
	"heavy-intercessor-squad": ["unyielding-in-the-face-of-the-foe"],
	"terminator-squad": ["deep-strike", "teleport-homer", "fury-of-the-first"],
	"captain": ["leader", "strategic-acumen", "finest-hour", "transhuman-strategist"],
	"lieutenant": ["support", "tactical-precision", "demi-company-commander"],
	"roboute-guilliman": ["codex-adept", "author-of-the-codex"],
	"necron-warriors": ["their-number-is-legion"],
	"immortals": ["implacable-eradication"],
	"overlord": ["leader", "my-will-be-done", "implacable-resilience", "resurrection-orb"],
	"royal-warden": ["leader", "adaptive-strategy", "engrammatic-logic"]}

static func identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func enabled(state: Dictionary) -> bool:
	return state.get("unit_abilities", {}).get("implementation", "") == ID

static func sources(state: Dictionary, squad: int, name: String) -> Array[int]:
	var result: Array[int] = []
	if not enabled(state): return result
	for model: int in Geometry.alive(state, squad):
		if name in RULES.get(identity(state.units[model]), []): result.append(model)
	return result

static func has(state: Dictionary, squad: int, name: String) -> bool:
	return not sources(state, squad, name).is_empty()

static func enable(state: Dictionary) -> void:
	state.unit_abilities = {"implementation": ID, "used": {}, "doctrines": {}, "additional_doctrines": {}, "discounts": {}, "discount_armed": {}, "phase_start": -1, "end_done": "", "window": {}, "reserves": {}, "homers": {}, "setup_done": false}
	for squad: int in state.squads:
		state.squads[squad].disabled_abilities = []
		for model: int in Geometry.alive(state, squad):
			if identity(state.units[model]) == "overlord": state.units[model].wargear = ["resurrection-orb"]
			if identity(state.units[model]) == "terminator-squad": state.units[model].erase("melee_weapons")
			for ability: String in RULES.get(identity(state.units[model]), []):
				Registry.admit(state, ability, ID)
				Registry.admit_squad(state, squad, ability)
			if identity(state.units[model]) == "terminator-squad": Registry.admit(state, "rapid-ingress", ID)

static func near_objective(state: Dictionary, squad: int, controlled: bool = false) -> bool:
	if controlled:
		if state.squads[squad].battle_shocked: return false
		var positive_oc := false
		for model: int in Geometry.alive(state, squad):
			if int(state.units[model].get("objective_control", state.squads[squad].stats.objective_control)) > 0: positive_oc = true
		if not positive_oc: return false
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		if controlled and objective.controller != state.squads[squad].owner: continue
		for model: int in Geometry.alive(state, squad):
			if Objectives.in_range(state.units[model], objective): return true
	return false

static func hit_bonus(state: Dictionary, squad: int, target: int, melee: bool) -> int:
	return 1 if not melee and state.phase == "shooting" and state.active == state.squads[squad].owner and has(state, squad, "bolter-discipline") and (near_objective(state, squad) or near_objective(state, target)) else 0

static func weapon(state: Dictionary, model: int, target: int, original: Dictionary, melee: bool) -> Dictionary:
	if not enabled(state): return original.duplicate(true)
	var copy := original.duplicate(true)
	var squad: int = state.units[model].squad
	if has(state, squad, "fury-of-the-first"):
		for source: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target(state, state.units[source], target) <= 9.001:
				copy.ap -= 1
				break
	if melee and state.squads[squad].charged and has(state, squad, "targeted-intercession"):
		copy.strength += 1
		copy.ap -= 1
	if has(state, squad, "tactical-precision"):
		var heavy := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: String in state.units[enemy].get("keywords", []):
				if keyword.to_upper() in ["MONSTER", "VEHICLE"]: heavy = true
		if not heavy: copy.keywords["lethal-hits"] = true
	return copy

static func save_bonus(state: Dictionary, squad: int) -> int:
	return 1 if has(state, squad, "unyielding-in-the-face-of-the-foe") and near_objective(state, squad, true) else 0

static func damage(state: Dictionary, model: int, amount: int) -> int:
	return maxi(1, amount - 1) if enabled(state) and identity(state.units[model]) == "overlord" and amount > 0 else amount

static func discount(state: Dictionary, player: int, squad: int) -> int:
	return 1 if enabled(state) and has(state, squad, "my-will-be-done") and state.unit_abilities.discount_armed.get(squad, -1) == state.round and state.unit_abilities.discounts.get(player, -1) != state.round else 0

static func consume_discount(state: Dictionary, player: int, squad: int) -> void:
	if discount(state, player, squad) == 0: return
	state.unit_abilities.discounts[player] = state.round
	state.unit_abilities.discount_armed.erase(squad)

static func doctrine(state: Dictionary, squad: int) -> String:
	if not enabled(state): return ""
	var record: Dictionary = state.unit_abilities.doctrines.get(squad, {})
	return str(record.get("doctrine", ""))

static func additional_doctrines(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	if not enabled(state): return result
	for doctrine: String in state.unit_abilities.get("additional_doctrines", {}).get(squad, []):
		if doctrine not in result: result.append(doctrine)
	return result

static func start_command(state: Dictionary) -> void:
	if not enabled(state): return
	for squad: int in state.unit_abilities.doctrines.keys():
		if state.squads[squad].owner == state.active: state.unit_abilities.doctrines.erase(squad)
	for squad: int in state.unit_abilities.additional_doctrines.keys():
		if state.squads.has(squad) and state.squads[squad].owner == state.active: state.unit_abilities.additional_doctrines.erase(squad)

static func implacable_mode(state: Dictionary, squad: int, target: int) -> String:
	if not has(state, squad, "implacable-eradication"): return "none"
	return "failed" if near_objective(state, target) else "ones"

static func potential_discount(state: Dictionary, player: int, squad: int) -> int:
	return 1 if has(state, squad, "my-will-be-done") and state.unit_abilities.discounts.get(player, -1) != state.round else 0

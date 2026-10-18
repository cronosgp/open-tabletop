extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Current 11e army rule plus the explicitly declared Gladius detachment effect.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const ID := "combat-doctrines-11e-gladius-v1"
const SOURCE := "https://www.warhammer-community.com/en-gb/articles/ifgezlgu/space-marines-rules-first-look/"
const REFERENCE := "https://wahapedia.ru/wh40k11ed/factions/space-marines/#Combat-Doctrines"
const NAMES := {"none": "No doctrine this turn", "devastator": "Devastator: shoot after Advance", "tactical": "Tactical: shoot and charge after Fall Back", "assault": "Assault: charge after Advance"}
const ORDER := ["devastator", "tactical", "assault"]

static func enable(state: Dictionary, gladius: bool = true) -> void:
	var owners: Array[int] = []
	for owner in [1, 2]:
		if Marines.marine_army(state, owner): owners.append(owner)
	state.combat_doctrines = {"implementation": ID, "owners": owners, "gladius": gladius, "cp_pending_turn": -1, "extra_used": {}, "active": {}, "used": {}, "selected_turn": {}}
	Capabilities.admit(state, "combat-doctrines", ID)
	if gladius: Capabilities.admit(state, "codex-discipline", ID)
	for squad: int in state.squads:
		if state.squads[squad].owner in owners: Capabilities.admit_squad(state, squad, "combat-doctrines")

static func enabled(state: Dictionary) -> bool:
	return state.get("combat_doctrines", {}).get("implementation", "") == ID

static func available(state: Dictionary, player: int) -> Array[String]:
	var result: Array[String] = []
	if not enabled(state) or player not in state.combat_doctrines.owners or not Marines.marine_army(state, player): return result
	for doctrine: String in ORDER:
		var used: Array = state.combat_doctrines.used.get(player, [])
		if doctrine not in used or (used.count(doctrine) == 1 and state.combat_doctrines.gladius and not state.combat_doctrines.extra_used.get(player, false)): result.append(doctrine)
	return result

static func start_command(state: Dictionary) -> void:
	if enabled(state): state.combat_doctrines.active.erase(state.active)

static func needs_choice(state: Dictionary) -> bool:
	return enabled(state) and state.get("test_winner", 0) == 0 and state.phase == "command" and state.combat_doctrines.selected_turn.get(state.active, -1) != state.turn and not available(state, state.active).is_empty()

static func choice_error(state: Dictionary, player: int, doctrine: String, revision: int) -> String:
	if not needs_choice(state): return "No Combat Doctrine decision is pending."
	if revision != state.revision: return "State changed; synchronize before selecting a doctrine."
	if player != state.active: return "Only the active Space Marine player selects the doctrine."
	if doctrine != "none" and doctrine not in available(state, player): return "Choose an unused Combat Doctrine or no doctrine."
	return ""

static func select_doctrine(state: Dictionary, player: int, doctrine: String) -> void:
	state.combat_doctrines.selected_turn[player] = state.turn
	if doctrine == "none": return
	state.combat_doctrines.active[player] = doctrine
	record_selection(state, player, doctrine)

## Record every rule-driven doctrine selection against the shared once-per-battle limit.
## Unit abilities can activate the doctrine locally without changing the army-wide active doctrine.
static func record_selection(state: Dictionary, player: int, doctrine: String) -> void:
	if not state.combat_doctrines.used.has(player): state.combat_doctrines.used[player] = []
	if doctrine in state.combat_doctrines.used[player]: state.combat_doctrines.extra_used[player] = true
	state.combat_doctrines.used[player].append(doctrine)

static func active_for(state: Dictionary, squad: int) -> String:
	if not UnitAbilities.doctrine(state, squad).is_empty(): return UnitAbilities.doctrine(state, squad)
	if not enabled(state) or not state.squads.has(squad): return ""
	var owner: int = state.squads[squad].owner
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return ""
	return str(state.combat_doctrines.active.get(owner, ""))

## Some current datasheets maintain or gain doctrines alongside their normal selection.
## Keep the army-wide/override lookup intact and expose the combined effects separately.
static func active_doctrines_for(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	var selected := active_for(state, squad)
	if selected in ORDER: result.append(selected)
	if UnitAbilities.has(state, squad, "codex-adept"):
		for doctrine: String in ORDER:
			if doctrine not in result: result.append(doctrine)
	return result

static func has_doctrine(state: Dictionary, squad: int, doctrine: String) -> bool:
	return doctrine in active_doctrines_for(state, squad)

static func weapon(state: Dictionary, squad: int, profile: Dictionary, melee: bool) -> Dictionary:
	if melee or not has_doctrine(state, squad, "devastator"): return profile
	var copy := profile.duplicate(true)
	copy.keywords.assault = true
	return copy

static func shoot_after_fallback(state: Dictionary, squad: int) -> bool:
	return has_doctrine(state, squad, "tactical") or UnitAbilities.has(state, squad, "adaptive-strategy")

static func charge_error(state: Dictionary, squad: int) -> String:
	if state.squads[squad].advanced and not has_doctrine(state, squad, "assault"): return "A unit that Advanced needs Assault Doctrine to declare a charge."
	if state.squads[squad].fell_back and not has_doctrine(state, squad, "tactical") and not UnitAbilities.has(state, squad, "adaptive-strategy"): return "A unit that Fell Back needs Tactical Doctrine to declare a charge."
	return ""

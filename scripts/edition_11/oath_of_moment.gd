extends RefCounted
## Explicit June-2026 profile, not certification of the later October Codex.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const ID := "oath-of-moment-june-2026-v1"
const SOURCE := "https://assets.warhammer-community.com/eng_08-06_warhammer40000_faction_pack_space-marines-nd2ezs5yzn-wxe2nf2ckk.pdf"
const EXCLUDED_CHAPTERS := ["BLOOD ANGELS", "DARK ANGELS", "DEATHWATCH", "SPACE WOLVES"]

static func marine_army(state: Dictionary, owner: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.owner != owner: continue
		if not str(model.get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): return false
		found = true
	return found

static func enable(state: Dictionary, codex_context: bool = true) -> void:
	var owners: Array[int] = []
	for owner in [1, 2]:
		if marine_army(state, owner): owners.append(owner)
	state.oath_of_moment = {"implementation": ID, "owners": owners, "codex_context": codex_context, "targets": {}, "selected_turn": {}}
	Capabilities.admit(state, "oath-of-moment", ID)

static func enabled(state: Dictionary) -> bool:
	return state.get("oath_of_moment", {}).get("implementation", "") == ID

static func targets(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == owner: continue
		for model: Dictionary in state.units.values():
			if model.squad == squad and model.wounds > 0:
				result.append(squad)
				break
	return result

static func start_command(state: Dictionary) -> void:
	if not enabled(state) or state.active not in state.oath_of_moment.owners: return
	state.oath_of_moment.targets.erase(state.active)

static func needs_choice(state: Dictionary) -> bool:
	return enabled(state) and state.get("test_winner", 0) == 0 and state.phase == "command" and state.active in state.oath_of_moment.owners and state.oath_of_moment.selected_turn.get(state.active, -1) != state.turn and not targets(state, state.active).is_empty()

static func pending_decision(state: Dictionary) -> Dictionary:
	if not needs_choice(state): return {}
	var owner := int(state.active)
	var options: Array[Dictionary] = []
	for target: int in targets(state, owner):
		options.append({"label": "Oath of Moment: %s" % state.squads[target].name, "action": "oath-target", "target": target})
	return PendingDecision.create(state, "oath-of-moment", "command-phase:oath-target", owner, options, false)

static func choice_error(state: Dictionary, player: int, target: int, revision: int) -> String:
	if not needs_choice(state): return "No Oath of Moment target selection is pending."
	if revision != state.revision: return "State changed; synchronize before selecting the Oath target."
	if player != state.active: return "Only the active Space Marine player selects this Oath target."
	if target not in targets(state, player): return "Select a living enemy unit as the Oath of Moment target."
	return ""

static func select_target(state: Dictionary, player: int, target: int) -> void:
	state.oath_of_moment.targets[player] = target
	state.oath_of_moment.selected_turn[player] = state.turn

static func codex_bonus(state: Dictionary, owner: int) -> bool:
	if not state.oath_of_moment.codex_context: return false
	for model: Dictionary in state.units.values():
		if model.owner != owner: continue
		for keyword: Variant in model.get("keywords", []):
			if str(keyword).replace("_", " ").replace("-", " ").to_upper() in EXCLUDED_CHAPTERS: return false
	return true

static func context(state: Dictionary, squad: int, target: int) -> Dictionary:
	if not enabled(state) or not state.squads.has(squad): return {}
	var owner: int = state.squads[squad].owner
	if owner not in state.oath_of_moment.owners or not marine_army(state, owner) or state.oath_of_moment.targets.get(owner, -1) != target: return {}
	return {"hit_reroll": "failed", "wound_modifier": 1 if codex_bonus(state, owner) else 0}

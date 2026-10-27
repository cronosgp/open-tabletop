extends RefCounted
## Tactical choices composed into the shared host/guest lifecycle.
const Tactical = preload("res://scripts/edition_11/tactical_training.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
var guest_rejection_checked := false
var lifecycle: SceneTree
var game: Node

func _init(controller: SceneTree) -> void:
	lifecycle = controller
	game = controller.game

func wait_for(predicate: Callable, label: String, seconds: float = 150.0) -> bool:
	return await lifecycle.wait_for(predicate, label, seconds)

func select_reference_list(owner: int) -> bool:
	var wanted := Tactical.FIRE_ID if owner == 1 else Tactical.ASSAULT_ID
	var picker: OptionButton = game.saved_army_pickers[owner]
	for index in range(picker.item_count):
		var item: Variant = picker.get_item_metadata(index)
		if item is Dictionary and str(item.get("id", "")) == wanted:
			game._network_army_selected(index)
			return true
	return false

func rejected_guest_choice(payload: Dictionary, revision: int, reason: String) -> bool:
	var before: Dictionary = game.state.duplicate(true)
	game.status.text = "Waiting for the authoritative rejection"
	game.request_unit_action.rpc_id(1, payload, Vector2.ZERO, revision)
	if not await wait_for(func(): return reason in game.status.text, "host rejects the invalid guest command: " + reason): return false
	if game.state != before:
		push_error("An invalid guest choice mutated the tactical state.")
		return false
	return true

func submit_setup(owner: int) -> bool:
	if str(game.state.get("match_manifest", {}).get("scenario", "")) != Tactical.ID:
		push_error("Both peers must agree on the versioned tactical scenario identity.")
		return false
	var leader := -1
	var target := -1
	for model: int in game.state.units:
		var unit: Dictionary = game.state.units[model]
		if int(unit.owner) != owner: continue
		if str(unit.definition_id).ends_with(":captain" if owner == 1 else ":chaplain"): leader = model
		if str(unit.definition_id).ends_with(":intercessor-squad" if owner == 1 else ":assault-intercessor-squad"): target = int(unit.squad)
	for action: String in ["warlord", "attach", "setup-done"]:
		var selected: Dictionary = {}
		for choice: Dictionary in UnitActions.choices(game.state, owner):
			if str(choice.action) == action and (action == "setup-done" or (int(choice.model) == leader and (action != "attach" or int(choice.target) == target))):
				selected = choice
				break
		if selected.is_empty():
			push_error("The tactical owner cannot declare " + action)
			return false
		var revision: int = game.state.revision
		var payload: Dictionary = game._unit_choice_payload(selected)
		if game.mode == "client":
			if action == "warlord":
				if not await rejected_guest_choice(payload, revision - 1, "State changed"): return false
				var obsolete := payload.duplicate(true)
				obsolete.option_id = "obsolete-tactical-option"
				if not await rejected_guest_choice(obsolete, revision, "Choose an option"): return false
			game.request_unit_action.rpc_id(1, payload, Vector2.ZERO, revision)
		else: game._apply_unit_action(owner, payload, Vector2.ZERO, revision)
		if not await wait_for(func(): return game.state.revision > revision, "tactical " + action): return false
		if game.mode == "client" and action == "warlord":
			if not await rejected_guest_choice(payload, int(game.state.revision), "Decision changed"): return false
			guest_rejection_checked = true
	if game.mode == "client" and not guest_rejection_checked: return false
	return true

func commit_host_ranged_attack() -> bool:
	# Declaration can suspend for a live attacker/defender roll reaction.
	for attacker: int in game.state.units:
		var unit: Dictionary = game.state.units[attacker]
		if int(unit.owner) != 1 or int(unit.wounds) <= 0: continue
		for target: int in AttackPlan.legal_targets(game.state, attacker, false):
			var entries := AttackPlan.single_target(game.state, int(unit.squad), target, false)
			if entries.is_empty(): continue
			var revision: int = game.state.revision
			game._apply_attack_plan(1, attacker, entries, revision, false, false)
			return game.state.revision > revision
	return false

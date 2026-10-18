extends RefCounted
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const RollWindows = preload("res://scripts/edition_11/attack_roll_window.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const R = preload("res://scripts/edition_11/reanimation_protocols.gd")
const D = preload("res://scripts/edition_11/deployment.gd")
const T = preload("res://scripts/edition_11/terrain.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")

static func key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func pending(state: Dictionary) -> Dictionary:
	return state.get("unit_abilities", {}).get("window", {})

static func setup_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "deployment": return -1
	for player in [1, 2]:
		if not state.unit_abilities.get("setup_players", []).has(player): return player
	return -1

static func actor(state: Dictionary) -> int:
	if setup_actor(state) > 0: return setup_actor(state)
	if battle_actor(state) > 0: return battle_actor(state)
	var window := pending(state)
	return int(window.owners[0]) if not window.is_empty() else -1

static func choice(label: String, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	return {"label": label, "action": action, "model": model, "target": target, "value": value}

static func models(state: Dictionary, player: int, ability: String) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == player: result.append_array(A.sources(state, squad, ability))
	return result

static func choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.get("test_winner", 0) != 0: return result
	if not state.get("awakened_dynasty", {}).get("pending", []).is_empty(): return result
	if Doctrines.needs_choice(state): return result
	var rp := R.pending(state)
	if not rp.is_empty():
		if rp.player == player and rp.current.get("reroll_pending", false):
			result.append(choice("Their Number is Legion: keep D6 %d" % rp.current.raw_roll, "legion-keep"))
			result.append(choice("Their Number is Legion: re-roll once (new result required)", "legion-reroll"))
		return result
	var strat_window: Dictionary = state.get("stratagems", {}).get("pending", {})
	if not strat_window.is_empty():
		if strat_window.player == player:
			var squads: Array = [strat_window.squad] if strat_window.has("squad") else strat_window.get("remaining", [])
			for squad: int in squads:
				if A.potential_discount(state, player, squad) > 0 and A.discount(state, player, squad) == 0:
					result.append(choice("My Will Be Done: reduce %s stratagem by 1 CP" % state.squads[squad].name, "discount", -1, squad))
		return result
	if pending(state).get("kind", "") == "wound":
		if pending(state).owners[0] != player: return result
		var checkpoint: Dictionary = state.pending_attack.current.checkpoint
		result.append(choice("Keep remaining wound rolls and continue", "wound-finish"))
		for index: int in RollWindows.eligible(checkpoint): result.append(choice("Implacable Eradication: re-roll wound die %d (%d), 0 CP" % [index + 1, checkpoint.effective_wounds[index]], "wound-reroll", -1, index))
		return result
	if not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): return result
	var setup := setup_actor(state)
	if setup > 0:
		if player != setup: return result
		result.append(choice("Finish army preparations / optional declarations", "setup-done"))
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner != player: continue
			var source := A.identity(unit)
			if source in ["captain", "lieutenant", "overlord", "royal-warden"]: result.append(choice("Warlord: model %d" % model, "warlord", model))
			if source in ["captain", "lieutenant", "royal-warden"] and not unit.has("attachment_role"):
				for target: int in state.squads:
					if attachment_allowed(state, model, target): result.append(choice("Attach %s %d to %s" % [source, model, state.squads[target].name], "attach", model, target))
		for squad: int in state.squads:
			if state.squads[squad].owner != player: continue
			var terminators := false
			for unit: Dictionary in state.units.values():
				if unit.squad == squad and A.identity(unit) == "terminator-squad": terminators = true
			if terminators:
				if not state.unit_abilities.reserves.has(squad): result.append(choice("Place %s in strategic reserves" % state.squads[squad].name, "reserve", -1, squad))

		return result
	var battle := battle_actor(state)
	if battle > 0:
		if battle != player: return result
		result.append(choice("Finish start-of-battle Teleport Homer declarations", "battle-done"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.unit_abilities.used.has("homer-set:%d" % squad): continue
			for unit: Dictionary in state.units.values():
				if unit.squad == squad and A.identity(unit) == "terminator-squad":
					result.append(choice("Set Teleport Homer for %s at X/Z" % state.squads[squad].name, "homer", -1, squad))
					break
		return result
	var window := pending(state)
	if not window.is_empty():
		if window.owners[0] != player: return result
		if window.kind == "tactics":
			for model: int in G.alive(state, window.squad): result.append(choice("Responsive Tactics: preview model %d" % model, "tactics-place", model, window.squad))
			result.append(choice("Confirm Responsive Tactics move", "tactics-confirm"))
			result.append(choice("Leave %s in place" % state.squads[window.squad].name, "tactics-cancel"))
			return result
		if window.kind == "eternal":
			result.append(choice("Eternal Revenant: preview returned model %d" % window.model, "eternal-place", window.model, window.squad))
			result.append(choice("Confirm Eternal Revenant set-up", "eternal-confirm", window.model, window.squad))
			return result
		if window.kind == "ingress":
			for model: int in state.units:
				if state.units[model].squad == window.squad: result.append(choice("Ingress model %d: preview at X/Z" % model, "ingress-place", model, window.squad))
			result.append(choice("Confirm ingress positions", "ingress-confirm"))
			result.append(choice("Cancel ingress preview", "ingress-cancel"))
			return result
		result.append(choice("Decline remaining %s abilities" % window.kind, "pass"))
		if window.kind == "start":
			for model: int in models(state, player, "engrammatic-logic"):
				if state.unit_abilities.used.has("logic:%d" % model): continue
				for target: int in state.squads:
					if state.squads[target].owner == player and state.squads[target].battle_shocked and not G.alive(state, target).is_empty() and str(state.units[G.alive(state, target)[0]].get("definition_id", "")).begins_with("40kdc:11e:necrons:") and G.distance_to_target(state, state.units[model], target) <= 12.001:
						result.append(choice("Engrammatic Logic %d: clear %s Battle-shock" % [model, state.squads[target].name], "logic", model, target))
		if window.kind == "end":
			for model: int in models(state, player, "resurrection-orb"):
				var squad: int = state.units[model].squad
				if R.enabled(state) and R.supported_unit(state, squad) and not state.unit_abilities.used.has("orb:%d" % squad) and state.unit_abilities.used.get("resurrect-turn:%d" % player, -1) != state.turn:
					result.append(choice("Resurrection Orb %d: activate D6 healing" % model, "orb", model))
			if state.phase == "movement" and state.active != player and state.round > 1 and state.has("stratagems"):
				for squad: int in state.unit_abilities.reserves:
					if state.squads[squad].owner != player or state.unit_abilities.used.get("ingress:%d:%s" % [player, key(state)], false) or state.squads[squad].battle_shocked: continue
					if state.cp[player] >= 1: result.append(choice("Rapid Ingress: %s (1 CP)" % state.squads[squad].name, "ingress", -1, squad))
					if state.unit_abilities.homers.has(squad): result.append(choice("Rapid Ingress via Teleport Homer: %s (0 CP)" % state.squads[squad].name, "homer-ingress", -1, squad))
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(CoreReactions.choices(state, player))
		if window.kind == "counter":
			result.append_array(CoreReactions.choices(state, player))
		if window.kind == "demi":
			for model: int in models(state, player, "demi-company-commander"):
				var squad: int = state.units[model].squad
				if state.unit_abilities.used.get("demi:%d" % squad, -1) != state.turn: result.append(choice("Demi-company Commander: %s" % state.squads[squad].name, "demi", model, squad, window.doctrine))
		return result
	if player != state.active and state.phase != "fight":
		if state.pending_move.is_empty() and state.pending_contact.is_empty():
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(CoreReactions.choices(state, player))
		return result
	if not state.pending_move.is_empty() or not state.pending_contact.is_empty(): return result
	result.append_array(DetachmentStratagems.choices(state, player))
	result.append_array(CoreReactions.choices(state, player))
	for model: int in models(state, player, "strategic-acumen"):
		var squad: int = state.units[model].squad
		if state.phase == "command" and state.active == player and state.unit_abilities.used.get("acumen:%d" % squad, -1) != state.turn:
			for doctrine: String in Doctrines.available(state, player): result.append(choice("Strategic Acumen %d: %s" % [model, doctrine], "acumen", model, squad, doctrine))
	for model: int in models(state, player, "author-of-the-codex"):
		if state.phase != "movement" or state.active != player or not Doctrines.enabled(state) or state.unit_abilities.used.get("author:%d" % model, "") == key(state): continue
		for doctrine: String in Doctrines.available(state, player):
			for target: int in state.squads:
				if G.alive(state, target).is_empty() or state.squads[target].owner != player: continue
				var is_astartes := false
				for target_model: int in G.alive(state, target):
					if str(state.units[target_model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"):
						is_astartes = true
						break
				if not is_astartes: continue
				var sight := T.targeting(state, model, target)
				if sight.visible and sight.distance <= 12.001:
					result.append(choice("Author of the Codex %d: %s for %s" % [model, doctrine, state.squads[target].name], "author", model, target, doctrine))
	for model: int in models(state, player, "finest-hour"):
		var squad: int = state.units[model].squad
		if state.phase == "fight" and state.fight_actor == player and state.fight_step == "attacks" and squad in FightQueue.choices(state, player) and not state.squads[squad].fought and not state.unit_abilities.used.has("finest:%d" % squad): result.append(choice("Finest Hour: Captain %d (+3 A, Devastating Wounds)" % model, "finest", model, squad))
	for model: int in models(state, player, "my-will-be-done"):
		var squad: int = state.units[model].squad
		if state.unit_abilities.discounts.get(player, -1) != state.round and state.unit_abilities.discount_armed.get(squad, -1) != state.round: result.append(choice("My Will Be Done %d: use -1 CP on next eligible stratagem" % model, "discount", model, squad))
	if state.phase == "movement" and state.active == player and state.round > 1:
		for squad: int in state.unit_abilities.reserves:
			if state.squads[squad].owner == player: result.append(choice("Deep Strike ingress: %s" % state.squads[squad].name, "ingress", -1, squad))
	return result

static func attachment_allowed(state: Dictionary, model: int, target: int) -> bool:
	var source: Dictionary = state.units[model]
	if target == source.squad or source.owner != state.squads[target].owner: return false
	var name := A.identity(source)
	var allowed := ["intercessor-squad", "assault-intercessor-squad"] if name in ["captain", "lieutenant"] else ["necron-warriors", "immortals"]
	var found := false
	var role := "support" if name == "lieutenant" else "leader"
	for id: int in G.alive(state, target):
		var unit: Dictionary = state.units[id]
		if unit.get("attachment_role", "") == role: return false
		if A.identity(unit) in allowed: found = true
	return found

static func attach(state: Dictionary, model: int, target: int) -> void:
	var origin: int = state.units[model].squad
	var source: Dictionary = state.squads[origin]
	var unit: Dictionary = state.units[model]
	var defense := Groups.profile(state, model)
	unit.ranged_weapons = Equipment.inventory(state, model, false).duplicate(true)
	unit.melee_weapons = Equipment.inventory(state, model, true).duplicate(true)
	unit.defense = {"toughness": defense.toughness, "save_target": defense.save_target, "invulnerable_target": defense.invulnerable_target}
	unit.leadership_target = source.stats.leadership_target
	unit.objective_control = source.stats.objective_control
	unit.component_squad = origin
	unit.attachment_role = "support" if A.identity(unit) == "lieutenant" else "leader"
	var body: Dictionary = state.squads[target]
	if not body.get("attached", false):
		body.components = [{"squad": target, "role": "bodyguard", "name": body.name, "starting_strength": body.starting_strength}]
		for id: int in G.alive(state, target):
			state.units[id].attachment_role = "bodyguard"
			state.units[id].component_squad = target
			state.units[id].ranged_weapons = Equipment.inventory(state, id, false).duplicate(true)
			state.units[id].melee_weapons = Equipment.inventory(state, id, true).duplicate(true)
	body.components.append({"squad": origin, "role": unit.attachment_role, "name": source.name, "starting_strength": source.starting_strength})
	for ability: String in source.get("enabled_abilities", []):
		if ability not in body.enabled_abilities: body.enabled_abilities.append(ability)
	body.attached = true
	body.starting_strength += source.starting_strength
	unit.squad = target
	state.squads.erase(origin)
	D.begin(state)

static func reconcile(state: Dictionary) -> void:
	if not A.enabled(state): return
	var a: Dictionary = state.unit_abilities
	if a.get("phase_key", "") != key(state) and state.phase in ["command", "movement", "shooting", "charge", "fight"]:
		a.phase_key = key(state)
		a.phase_start = state.revision + 1
		a.anchors = {}
		for squad: int in state.squads: a.anchors[squad] = G.alive(state, squad)
		var owners: Array = []
		for owner in [state.active, 3 - int(state.active)]:
			if logic_available(state, owner): owners.append(owner)
		if not owners.is_empty(): a.window = {"kind": "start", "owners": owners}
	if state.round > 3:
		for squad: int in a.reserves.keys():
			for unit: Dictionary in state.units.values():
				if unit.squad == squad: unit.wounds = 0
			a.reserves.erase(squad)

static func open_end(state: Dictionary) -> bool:
	if not A.enabled(state) or state.phase not in ["command", "movement", "shooting", "charge", "fight"] or state.unit_abilities.end_done == key(state): return false
	var owners: Array = []
	for owner in [state.active, 3 - int(state.active)]:
		if orb_available(state, owner) or DetachmentStratagems.eternal_pending(state, owner) or CoreReactions.end_available(state, owner) or (state.phase == "movement" and owner != state.active and state.round > 1 and not state.unit_abilities.reserves.is_empty()): owners.append(owner)
	state.unit_abilities.end_done = key(state)
	if owners.is_empty(): return false
	state.unit_abilities.window = {"kind": "end", "owners": owners}
	return true

static func point_error(state: Dictionary, point: Vector2, radius: float) -> String:
	if not point.is_finite() or absf(point.x) + radius > state.board_size.x / 2.0 or absf(point.y) + radius > state.board_size.y / 2.0: return "The whole base must fit on the battlefield."
	return ""

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var a: Dictionary = state.unit_abilities
	var model: int = selected.model
	var target: int = selected.target
	match selected.action:
		"core-stratagem":
			return CoreReactions.apply(state, player, selected)
		"overwatch-pass":
			CoreReactions.clear_overwatch(state)
			return {"error": ""}
		"detachment-stratagem":
			var spent := DetachmentStratagems.apply(state, player, selected, roller)
			if not spent.get("error", "").is_empty(): return spent
			if spent.has("undying"):
				var squad: int = int(spent.undying)
				state.reanimation.anchors[squad] = G.alive(state, squad)
				state.reanimation.pending = {"kind": "undying", "led": spent.led, "player": player, "turn": state.turn, "remaining": [squad], "current": {}, "results": []}
				return R.roll_unit(state, squad, roller)
			return spent
		"vengeful-pass":
			DetachmentStratagems.clear_vengeful(state)
			return {"error": ""}
		"wound-reroll":
			var current: Dictionary = state.pending_attack.current
			var replacement := RollWindows.reroll(current.checkpoint, target, current.checkpoint.revision, roller)
			if not replacement.error.is_empty(): return replacement
			current.checkpoint = replacement
		"wound-finish":
			state.pending_attack.current.free_done = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"legion-keep", "legion-reroll": return R.accept_roll(state, selected.action == "legion-reroll", roller)
		"pass":
			var kind: String = a.window.kind
			var resume_cursor: int = int(a.window.get("resume_cursor", state.active))
			a.window.owners.pop_front()
			if a.window.owners.is_empty():
				a.window = {}
				if kind == "counter": return {"error": "", "resume_fight": true, "resume_cursor": resume_cursor}
				return {"error": "", "advance": kind == "end"}
		"setup-done":
			for unit: Dictionary in state.units.values():
				if unit.owner == player and A.identity(unit) == "lieutenant" and unit.get("attachment_role", "") != "support": return {"error": "Support units must be attached to an eligible bodyguard."}
			var character := false
			for unit: Dictionary in state.units.values():
				if unit.owner == player and Groups.character(unit): character = true
			if character and not a.get("warlords", {}).has(player): return {"error": "Select your Warlord before finishing preparation."}
			var roster_error := RosterValidation.seal(state, player)
			if not roster_error.is_empty(): return {"error": roster_error}
			if not a.has("setup_players"): a.setup_players = []
			a.setup_players.append(player)
			if a.setup_players.size() == 2 and state.deployment.order.is_empty():
				state.deployment.complete = true
				state.phase = "mission_first_turn" if state.get("mission", {}).get("id", "") == "ca-2026-27-dominance-hammer-fixed-v1" else "start_turn"
		"battle-done":
			if not a.has("battle_players"): a.battle_players = []
			a.battle_players.append(player)
		"warlord":
			if not a.has("warlords"): a.warlords = {}
			a.warlords[player] = model
			for unit: Dictionary in state.units.values():
				if unit.owner == player: unit.keywords.erase("WARLORD")
			state.units[model].keywords.append("WARLORD")
		"attach": attach(state, model, target)
		"homer":
			var error := point_error(state, point, 0.0)
			if not error.is_empty(): return {"error": error}
			a.homers[target] = point
			a.used["homer-set:%d" % target] = true
		"reserve":
			var spent := 0
			for squad: int in a.reserves:
				if state.squads[squad].owner == player: spent += a.reserves[squad].cost
			var cost: int = state.squads[target].get("training_cost", 0)
			if cost <= 0: return {"error": "Missing reserve points for this unit."}
			if spent + cost > int(state.get("points_limit", 500)) / 2: return {"error": "Strategic reserves cannot exceed half the battle points limit."}
			a.reserves[target] = {"cost": cost}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"logic":
			a.used["logic:%d" % model] = true
			state.squads[target].battle_shocked = false
		"acumen":
			a.used["acumen:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
			Doctrines.record_selection(state, player, selected.value)
			a.window = {"kind": "demi", "owners": [player], "doctrine": selected.value}
		"author":
			a.used["author:%d" % model] = key(state)
			if not a.has("additional_doctrines"): a.additional_doctrines = {}
			if not a.additional_doctrines.has(target): a.additional_doctrines[target] = []
			if selected.value not in a.additional_doctrines[target]: a.additional_doctrines[target].append(selected.value)
			Doctrines.record_selection(state, player, selected.value)
		"demi":
			a.used["demi:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
		"finest":
			state.fight_selected = target
			a.used["finest:%d" % target] = true
			a.used["finest-active:%d" % model] = state.turn
		"discount": a.discount_armed[target] = state.round
		"orb":
			var squad: int = state.units[model].squad
			a.used["orb:%d" % squad] = true
			a.used["resurrect-turn:%d" % player] = state.turn
			state.reanimation.anchors = a.anchors.duplicate(true)
			state.reanimation.pending = {"kind": "orb", "player": player, "turn": state.turn, "remaining": [squad], "current": {}, "results": []}
			return R.roll_unit(state, squad, roller)
		"tactics-place":
			var error := DetachmentStratagems.tactics_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"tactics-confirm": return DetachmentStratagems.confirm_tactics(state)
		"tactics-cancel": a.window = {}
		"eternal-place":
			var error := DetachmentStratagems.eternal_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"eternal-confirm": return DetachmentStratagems.confirm_eternal(state)
		"ingress", "homer-ingress":
			a.window = {"kind": "ingress", "owners": [player], "squad": target, "positions": {}, "homer": selected.action == "homer-ingress", "return_window": a.window.duplicate(true)}
		"ingress-place":
			var error := ingress_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"ingress-cancel": a.window = a.window.return_window
		"ingress-confirm":
			var window: Dictionary = a.window
			var projected := state.duplicate(true)
			for id: int in state.units:
				if state.units[id].squad != window.squad: continue
				if not window.positions.has(id): return {"error": "Preview every model before confirming ingress."}
				var error := ingress_position_error(state, id, window.positions[id])
				if not error.is_empty(): return {"error": error}
				projected.units[id].on_battlefield = true
				projected.units[id].position = window.positions[id]
			if window.homer:
				var in_range := false
				for id: int in window.positions:
					if window.positions[id].distance_to(a.homers[window.squad]) - float(state.units[id].radius) <= 3.001: in_range = true
				if not in_range: return {"error": "The arriving unit must be within 3 inches of its Teleport Homer."}
			if not G.coherent(projected, window.squad): return {"error": "Ingress must leave the unit coherent."}
			for id: int in window.positions:
				state.units[id].position = window.positions[id]
				state.units[id].on_battlefield = true
			state.squads[window.squad].moved = true
			state.squads[window.squad].move_type = "ingress"
			state.squads[window.squad].set_up_this_turn = true
			a.reserves.erase(window.squad)
			end_move(state, window.squad)
			if state.active != player:
				state.cp[player] -= 0 if window.homer else 1
				a.used["ingress:%d:%s" % [player, key(state)]] = true
				if state.has("stratagems"): state.stratagems.uses.append({"player": player, "squad": window.squad, "stratagem": "rapid-ingress", "phase_key": key(state), "turn": state.turn})
				if window.homer: a.homers.erase(window.squad)
			a.window = window.return_window
	return {"error": ""}

static func ingress_position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window := pending(state)
	var unit: Dictionary = state.units[model]
	var error := point_error(state, point, float(unit.radius))
	if not error.is_empty(): return error
	for other: int in state.units:
		if other == model: continue
		var enemy: Dictionary = state.units[other]
		if enemy.wounds <= 0 or (not enemy.get("on_battlefield", true) and not window.positions.has(other)): continue
		var position: Vector2 = window.positions.get(other, enemy.position)
		var distance: float = point.distance_to(position) - float(unit.radius) - float(enemy.radius)
		if distance < -0.001: return "Ingress bases cannot overlap."
		if enemy.owner != unit.owner and distance <= 8.001: return "Ingress requires more than 8 inches from every enemy unit."
	var projected := state.duplicate(true)
	projected.units[model].on_battlefield = true
	projected.units[model].position = point
	return T.path_error(projected, model, point)

static func start_round(state: Dictionary) -> void:
	if not A.enabled(state) or state.active != state.get("first_player", 1): return
	for owner: int in state.unit_abilities.get("warlords", {}):
		var model: int = state.unit_abilities.warlords[owner]
		if state.unit_abilities.used.get("warlord-cp:%d" % owner, -1) == state.round: continue
		state.unit_abilities.used["warlord-cp:%d" % owner] = state.round
		if state.units[model].wounds > 0 and A.identity(state.units[model]) == "captain": state.cp[owner] += 1

static func logic_available(state: Dictionary, owner: int) -> bool:
	for model: int in models(state, owner, "engrammatic-logic"):
		if state.unit_abilities.used.has("logic:%d" % model): continue
		for squad: int in state.squads:
			if state.squads[squad].owner == owner and state.squads[squad].battle_shocked and not G.alive(state, squad).is_empty() and G.distance_to_target(state, state.units[model], squad) <= 12.001: return true
	return false

static func orb_available(state: Dictionary, owner: int) -> bool:
	if not R.enabled(state) or state.unit_abilities.used.get("resurrect-turn:%d" % owner, -1) == state.turn: return false
	for model: int in models(state, owner, "resurrection-orb"):
		var squad: int = state.units[model].squad
		if R.supported_unit(state, squad) and not state.unit_abilities.used.has("orb:%d" % squad): return true
	return false

static func battle_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "start_turn" or state.turn != 1: return -1
	for owner in [state.get("first_player", 1), 3 - int(state.get("first_player", 1))]:
		if owner in state.unit_abilities.get("battle_players", []): continue
		for unit: Dictionary in state.units.values():
			if unit.owner == owner and A.identity(unit) == "terminator-squad": return owner
	return -1

static func end_move(state: Dictionary, moved_squad: int) -> void:
	DetachmentStratagems.record_move(state, moved_squad)
	if not A.enabled(state): return
	for squad: int in state.unit_abilities.homers.keys():
		if state.squads[squad].owner == state.squads[moved_squad].owner: continue
		for model: int in G.alive(state, moved_squad):
			var unit: Dictionary = state.units[model]
			if unit.position.distance_to(state.unit_abilities.homers[squad]) - float(unit.radius) <= 1.001:
				state.unit_abilities.homers.erase(squad)
				break

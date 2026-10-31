extends RefCounted
const ReturnPlacement = preload("res://scripts/edition_11/return_placement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
## Necrons App v1.2 rule; runtime scope is still limited to explicitly admitted profiles.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Board = preload("res://scripts/rules.gd")
const ID := "reanimation-core-profiles-2026-10-31-v8"
const SOURCE := "wahapedia-e11-necrons-app-000000029-v1.2-local-export-20261031T053336Z"
const CORE_RULES_GAP_SOURCE := "https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Healing-Or-Regaining-Lost-Wounds"
const PROFILE_WOUNDS := {
	"40kdc:11e:necrons:necron-warriors": 1,
	"40kdc:11e:necrons:immortals": 1,
	"40kdc:11e:necrons:deathmarks": 1,
	"40kdc:11e:necrons:flayed-ones": 1,
	"40kdc:11e:necrons:skorpekh-destroyers": 3,
	"40kdc:11e:necrons:canoptek-scarab-swarms": 4,
	"40kdc:11e:necrons:canoptek-wraiths": 4,
	"40kdc:11e:necrons:lokhust-destroyers": 3,
	"40kdc:11e:necrons:lokhust-heavy-destroyers": 4,
	"40kdc:11e:necrons:ghost-ark": 14,
	"40kdc:11e:necrons:canoptek-doomstalker": 12,
	"40kdc:11e:necrons:doomsday-ark": 14,
	"40kdc:11e:necrons:monolith": 22,
	"40kdc:11e:necrons:triarch-stalker": 12,
	"40kdc:11e:necrons:ophydian-destroyers": 3,
	"40kdc:11e:necrons:annihilation-barge": 9,
	"40kdc:11e:necrons:canoptek-macrocytes": 1,
	"40kdc:11e:necrons:canoptek-reanimator": 6,
	"40kdc:11e:necrons:canoptek-spyders": 6,
	"40kdc:11e:necrons:canoptek-tomb-crawlers": 3,
	"40kdc:11e:necrons:doom-scythe": 12,
	"40kdc:11e:necrons:convergence-of-dominion": 7,
	"40kdc:11e:necrons:cryptothralls": 3,
	"40kdc:11e:necrons:night-scythe": 12,
	"40kdc:11e:necrons:obelisk": 24,
	"40kdc:11e:necrons:tesseract-vault": 24,
	"40kdc:11e:necrons:tomb-blades": 2,
}
const CHARACTER_WOUNDS := {
	"40kdc:11e:necrons:catacomb-command-barge": 9,
	"40kdc:11e:necrons:hexmark-destroyer": 5,
	"40kdc:11e:necrons:overlord": 6,
	"40kdc:11e:necrons:royal-warden": 4,
	"40kdc:11e:necrons:ctan-shard-of-the-deceiver": 16,
	"40kdc:11e:necrons:ctan-shard-of-the-nightbringer": 16,
	"40kdc:11e:necrons:ctan-shard-of-the-void-dragon": 16,
	"40kdc:11e:necrons:geomancer": 4,
	"40kdc:11e:necrons:nekrosor-ammentar": 9,
	"40kdc:11e:necrons:overlord-with-translocation-shroud": 6,
	"40kdc:11e:necrons:transcendent-ctan": 16,
}
const PROFILE_MODEL_COUNTS := {
	"40kdc:11e:necrons:necron-warriors": [10, 20],
	"40kdc:11e:necrons:immortals": [5, 10],
	"40kdc:11e:necrons:deathmarks": [5, 10],
	"40kdc:11e:necrons:flayed-ones": [5, 10],
	"40kdc:11e:necrons:skorpekh-destroyers": [3, 6],
	"40kdc:11e:necrons:canoptek-scarab-swarms": [3, 6],
	"40kdc:11e:necrons:canoptek-wraiths": [3, 6],
	"40kdc:11e:necrons:lokhust-destroyers": [1, 2, 3, 6],
	"40kdc:11e:necrons:lokhust-heavy-destroyers": [1, 2, 3],
	"40kdc:11e:necrons:ghost-ark": [1],
	"40kdc:11e:necrons:canoptek-doomstalker": [1],
	"40kdc:11e:necrons:doomsday-ark": [1],
	"40kdc:11e:necrons:monolith": [1],
	"40kdc:11e:necrons:catacomb-command-barge": [1],
	"40kdc:11e:necrons:triarch-stalker": [1],
	"40kdc:11e:necrons:hexmark-destroyer": [1],
	"40kdc:11e:necrons:ophydian-destroyers": [3, 6],
	"40kdc:11e:necrons:annihilation-barge": [1],
	"40kdc:11e:necrons:canoptek-macrocytes": [5],
	"40kdc:11e:necrons:canoptek-reanimator": [1],
	"40kdc:11e:necrons:canoptek-spyders": [1, 2],
	"40kdc:11e:necrons:canoptek-tomb-crawlers": [2],
	"40kdc:11e:necrons:doom-scythe": [1],
	"40kdc:11e:necrons:convergence-of-dominion": [1, 2, 3],
	"40kdc:11e:necrons:cryptothralls": [2],
	"40kdc:11e:necrons:night-scythe": [1],
	"40kdc:11e:necrons:obelisk": [1],
	"40kdc:11e:necrons:tesseract-vault": [1],
	"40kdc:11e:necrons:tomb-blades": [3, 6],
	"40kdc:11e:necrons:ctan-shard-of-the-deceiver": [1],
	"40kdc:11e:necrons:ctan-shard-of-the-nightbringer": [1],
	"40kdc:11e:necrons:ctan-shard-of-the-void-dragon": [1],
	"40kdc:11e:necrons:geomancer": [1],
	"40kdc:11e:necrons:nekrosor-ammentar": [1],
	"40kdc:11e:necrons:overlord-with-translocation-shroud": [1],
	"40kdc:11e:necrons:transcendent-ctan": [1],
	OVERLORD: [1],
	WARDEN: [1],
}
const ATTACHABLE_TROOPS := ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:immortals"]
const OVERLORD := "40kdc:11e:necrons:overlord"
const WARDEN := "40kdc:11e:necrons:royal-warden"
const EPSILON := 0.001

static func necron_army(state: Dictionary, owner: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.owner != owner: continue
		if not str(model.get("definition_id", "")).begins_with("40kdc:11e:necrons:"): return false
		found = true
	return found

static func supported_unit(state: Dictionary, squad: int) -> bool:
	var wounded_survivors := 0
	for model: Dictionary in state.units.values():
		if model.squad != squad: continue
		if int(model.wounds) > 0 and int(model.wounds) < int(model.max_wounds): wounded_survivors += 1
	if wounded_survivors > 1: return false
	if state.squads[squad].get("attached", false): return _supported_attachment(state, squad)
	var identity := ""
	var models := 0
	for unit: Dictionary in state.units.values():
		if unit.squad != squad: continue
		if identity.is_empty(): identity = str(unit.get("definition_id", ""))
		if identity != unit.get("definition_id", "") or (not PROFILE_WOUNDS.has(identity) and not CHARACTER_WOUNDS.has(identity)): return false
		if unit.get("elevation", 0.0) != 0.0: return false
		var source_wounds := int(PROFILE_WOUNDS.get(identity, CHARACTER_WOUNDS.get(identity, 0)))
		if source_wounds <= 0 or unit.max_wounds != source_wounds: return false
		models += 1
	return models > 0 and PROFILE_MODEL_COUNTS.has(identity) and models in PROFILE_MODEL_COUNTS[identity]

# One Character and one 1W troop component: healing order has no ambiguous
# wounded-model choice. Retain the original unit and its combined strength (19).
static func _supported_attachment(state: Dictionary, squad: int) -> bool:
	var components: Array = state.squads[squad].get("components", [])
	if components.size() != 2: return false
	var troop_identity := ""
	var leader_count := 0
	var troop_count := 0
	for unit: Dictionary in state.units.values():
		if unit.squad != squad: continue
		if unit.owner != state.squads[squad].owner or unit.get("elevation", 0.0) != 0.0: return false
		var identity: String = unit.get("definition_id", "")
		if unit.get("attachment_role", "") == "leader":
			if identity not in [OVERLORD, WARDEN] or unit.max_wounds != (6 if identity == OVERLORD else 4): return false
			leader_count += 1
		elif unit.get("attachment_role", "") == "bodyguard":
			if identity not in ATTACHABLE_TROOPS or unit.max_wounds != 1: return false
			if troop_identity.is_empty(): troop_identity = identity
			if identity != troop_identity: return false
			troop_count += 1
		else: return false
	return leader_count == 1 and troop_count > 0 and state.squads[squad].starting_strength == troop_count + leader_count

## The core Command-phase trigger in the local export applies to units that
## are on the battlefield. Reserve and embarked activations need their own
## rules windows and are not inferred from this trigger.
static func on_battlefield(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	if state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	# Read the model marker here to avoid a preload cycle through TransportRules.
	for unit: Dictionary in state.get("units", {}).values():
		if int(unit.get("squad", -1)) == squad and int(unit.get("embarked_transport", -1)) >= 0: return false
	for unit: Dictionary in state.units.values():
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		if bool(unit.get("on_battlefield", true)): return true
	return false

## Nanoscarab Reanimation Beam is an Aura. The 11e Core Rules make the
## source's own unit eligible while it is on the battlefield and limit a
## unit to one application of the same Aura, regardless of source count.
static func nanoscarab_aura_applies(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.get("squads", {}).has(squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	for model: int in state.get("units", {}):
		var source: Dictionary = state.units[model]
		if str(source.get("definition_id", "")) != "40kdc:11e:necrons:canoptek-reanimator": continue
		if int(source.get("owner", -1)) != owner or int(source.get("wounds", 0)) <= 0: continue
		var source_squad := int(source.get("squad", -1))
		if not on_battlefield(state, source_squad): continue
		if Geometry.distance_to_target(state, source, squad) <= 3.0 + EPSILON: return true
	return false

static func enable(state: Dictionary) -> void:
	state.reanimation = {"implementation": ID, "done_turn": {}, "morale_turn": -1, "command_turn": -1, "anchors": {}, "pending": {}, "last_results": []}
	Capabilities.admit(state, "reanimation-protocols", ID)
	for squad: int in state.squads:
		if necron_army(state, state.squads[squad].owner) and supported_unit(state, squad): Capabilities.admit_squad(state, squad, "reanimation-protocols")

static func enabled(state: Dictionary) -> bool:
	return state.get("reanimation", {}).get("implementation", "") == ID

static func pending(state: Dictionary) -> Dictionary:
	return state.get("reanimation", {}).get("pending", {})

## Project Reanimation's staged choices without duplicating its admission rules.
## Placement coordinates remain free-form inputs and are checked by position_error.
static func pending_decision(state: Dictionary) -> Dictionary:
	var window := pending(state)
	if window.is_empty(): return {}
	for required: String in ["revision", "squads", "units", "turn", "phase"]:
		if not state.has(required): return {}
	var owner := int(window.get("player", -1))
	if owner not in [1, 2] or int(window.get("turn", -1)) != int(state.turn): return {}
	if not choice_error(state, owner, int(state.revision)).is_empty(): return {}
	var options: Array[Dictionary] = []
	var current: Dictionary = window.get("current", {})
	if current.is_empty():
		for squad_value: Variant in window.get("remaining", []):
			var squad := int(squad_value)
			if not state.get("squads", {}).has(squad) or not on_battlefield(state, squad) or not supported_unit(state, squad) or Geometry.alive(state, squad).is_empty(): continue
			options.append(_decision_option("Roll Reanimation for %s" % str(state.squads[squad].name), squad, -1, "roll"))
	elif current.get("reroll_pending", false):
		# The paired UnitActions decision owns Their Number is Legion's keep/re-roll choice.
		return {}
	else:
		var squad := int(current.get("squad", -1))
		if not state.get("squads", {}).has(squad): return {}
		var assigned: int = current.get("placements", {}).size() + current.get("unplaced", []).size()
		for model: int in returnable(state):
			var already_assigned: bool = current.get("placements", {}).has(model)
			if model not in current.get("unplaced", []) and (already_assigned or assigned < int(current.get("slots", 0))):
				options.append(_decision_option("Choose a return position for model %d" % model, squad, model, "place", {"position": "validated-by-rules"}))
				options.append(_decision_option("Declare model %d unplaceable" % model, squad, model, "unplaceable"))
		if assigned < int(current.get("slots", 0)):
			options.append(_decision_option("Suggest return positions", squad, -1, "suggest"))
		if assigned > 0:
			options.append(_decision_option("Reset placement preview", squad, -1, "reset"))
		if confirm_error(state).is_empty():
			options.append(_decision_option("Confirm Reanimation for %s" % str(state.squads[squad].name), squad, -1, "confirm"))
	if options.is_empty(): return {}
	var timing := "command-phase:reanimation"
	if str(window.get("kind", "")) == "orb": timing = "end-phase:%s:reanimation" % str(state.get("phase", ""))
	elif str(window.get("kind", "")) == "undying": timing = "post-destruction:%s:reanimation" % str(state.get("phase", ""))
	return PendingDecision.create(state, "reanimation", timing, owner, options, false)

static func _decision_option(label: String, squad: int, model: int, value: String, details: Dictionary = {}) -> Dictionary:
	var option := {"label": label, "action": "reanimation", "model": model, "target": squad, "value": value}
	if not details.is_empty(): option.details = details
	return option

static func start_command(state: Dictionary) -> void:
	if not enabled(state): return
	state.reanimation.command_turn = state.turn
	state.reanimation.anchors = {}
	for squad: int in state.squads:
		if state.squads[squad].owner == state.active and on_battlefield(state, squad): state.reanimation.anchors[squad] = Geometry.alive(state, squad)

static func phase_error(state: Dictionary) -> String:
	if not enabled(state) or not necron_army(state, state.active) or state.reanimation.done_turn.get(state.active, -1) == state.turn: return ""
	if state.reanimation.command_turn != state.turn: return "Missing Command-entry snapshot for Reanimation Protocols."
	for squad: int in state.squads:
		if state.squads[squad].owner != state.active or Geometry.alive(state, squad).is_empty() or not on_battlefield(state, squad): continue
		if not supported_unit(state, squad): return "Reanimation is not implemented for every Necron profile currently on the battlefield."
	return ""

static func morale_done(state: Dictionary) -> bool:
	return enabled(state) and state.reanimation.morale_turn == state.turn

static func open_end_command(state: Dictionary) -> bool:
	if not enabled(state) or not necron_army(state, state.active) or state.reanimation.done_turn.get(state.active, -1) == state.turn: return false
	var squads: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == state.active and on_battlefield(state, squad) and not Geometry.alive(state, squad).is_empty(): squads.append(squad)
	squads.sort()
	state.reanimation.morale_turn = state.turn
	if squads.is_empty():
		state.reanimation.done_turn[state.active] = state.turn
		return false
	state.reanimation.pending = {"player": state.active, "turn": state.turn, "remaining": squads, "current": {}, "results": []}
	return true

static func choice_error(state: Dictionary, player: int, revision: int) -> String:
	var window := pending(state)
	if window.is_empty(): return "No Reanimation Protocols decision is pending."
	if revision != state.revision: return "State changed; synchronize before resolving Reanimation."
	if window.turn != state.turn or player != window.player or (window.get("kind", "") not in ["orb", "undying"] and (state.phase != "command" or player != state.active)): return "This Reanimation decision belongs to the active Necron player."
	if state.get("test_winner", 0) != 0: return "The match has ended."
	return ""

static func returnable(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty() or current.get("reroll_pending", false): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.squad == current.squad and unit.wounds == 0 and PROFILE_WOUNDS.has(unit.definition_id): result.append(model)
	result.sort()
	return result

static func roll_unit(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	var window := pending(state)
	if not window.current.is_empty() or squad not in window.remaining: return {"error": "Select an unresolved unit before rolling its Reanimation."}
	if not on_battlefield(state, squad) or not supported_unit(state, squad) or Geometry.alive(state, squad).is_empty(): return {"error": "That unit is no longer eligible for Reanimation."}
	if not roller.is_valid(): return {"error": "Reanimation requires the host's D6 provider."}
	var raw: Variant = roller.call()
	if not raw is int or raw < 1 or raw > 6: return {"error": "Reanimation dice must be integers from 1 to 6."}
	if UnitAbilities.has(state, squad, "their-number-is-legion"):
		window.current = {"squad": squad, "raw_roll": raw, "reroll_pending": true, "placements": {}, "unplaced": []}
		return {"error": "", "message": "Their Number is Legion: accept this roll or re-roll once before assigning healing."}
	return _prepare_healing(state, squad, raw, roller)

static func accept_roll(state: Dictionary, reroll: bool, roller: Callable) -> Dictionary:
	var current: Dictionary = pending(state).get("current", {})
	if not current.get("reroll_pending", false): return {"error": "No Legion roll decision is pending."}
	var raw: int = current.raw_roll
	if reroll:
		if not roller.is_valid(): return {"error": "Host dice provider required."}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "Invalid host D6."}
		raw = rolled
	return _prepare_healing(state, current.squad, raw, roller)

static func _prepare_healing(state: Dictionary, squad: int, raw: int, roller: Callable) -> Dictionary:
	var window := pending(state)
	var budget := raw if window.get("kind", "") == "orb" else ceili(float(raw) / 2.0)
	if window.get("kind", "") == "undying" and window.get("led", false): budget += 1
	var base_budget := budget
	var nanoscarab_roll := -1
	var nanoscarab_bonus := 0
	if nanoscarab_aura_applies(state, squad):
		if not roller.is_valid(): return {"error": "Nanoscarab Reanimation Beam requires the host's D6 provider."}
		var bonus_raw: Variant = roller.call()
		if not bonus_raw is int or bonus_raw < 1 or bonus_raw > 6: return {"error": "Nanoscarab Reanimation Beam D3 must use a D6 result from 1 to 6."}
		nanoscarab_roll = int(bonus_raw)
		nanoscarab_bonus = ceili(float(nanoscarab_roll) / 2.0)
		budget += nanoscarab_bonus
	var healed: Dictionary = {}
	var remaining := budget
	for model: int in Geometry.alive(state, squad):
		var lost: int = state.units[model].max_wounds - state.units[model].wounds
		if lost > 0:
			var amount := mini(remaining, lost)
			if amount > 0: healed[model] = amount
			remaining -= amount
	var engaged: Array[int] = []
	for target: int in state.squads:
		if state.squads[target].owner == window.player: continue
		for model: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target_at_height(state, state.units[model], target) <= 2.0 + EPSILON:
				engaged.append(target)
				break
	var healing_die := "D6" if window.get("kind", "") == "orb" else "D3"
	if nanoscarab_bonus > 0: healing_die += "+D3"
	window.current = {"squad": squad, "raw_roll": raw, "base_budget": base_budget, "nanoscarab_roll": nanoscarab_roll, "nanoscarab_bonus": nanoscarab_bonus, "budget": budget, "healing_die": healing_die, "healed": healed, "placements": {}, "unplaced": [], "engaged": engaged, "anchors": state.reanimation.anchors.get(squad, []).duplicate()}
	window.current.slots = mini(remaining, returnable(state).size())
	if window.current.slots == 0: return confirm_unit(state)
	var message := "%s: Reanimation D6 %d becomes %s %d" % [state.squads[squad].name, raw, "D6" if window.get("kind", "") == "orb" else "D3", base_budget]
	if nanoscarab_bonus > 0: message += "; Nanoscarab D6 %d adds D3 %d (total %d)" % [nanoscarab_roll, nanoscarab_bonus, budget]
	message += ". Preview %d returned models, then confirm." % window.current.slots
	return {"error": "", "message": message}

static func projected(state: Dictionary) -> Dictionary:
	return ReturnPlacement.projected(state, pending(state).get("current", {}))

static func position_error(state: Dictionary, model: int, destination: Vector2) -> String:
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty() or model not in returnable(state): return "Choose a destroyed troop model from the active Reanimation unit."
	if model in current.unplaced: return "Reset this preview before placing a model already declared unplaceable."
	if not current.placements.has(model) and current.placements.size() + current.unplaced.size() >= current.slots: return "The D3 healing budget is already assigned."
	return ReturnPlacement.error(state, model, destination, current)

static func place_model(state: Dictionary, model: int, destination: Vector2) -> Dictionary:
	var error := position_error(state, model, destination)
	if not error.is_empty(): return {"error": error}
	pending(state).current.placements[model] = destination
	return {"error": "", "message": "Reanimation model %d previewed; confirm the unit to restore its wound." % model}

static func declare_unplaceable(state: Dictionary, model: int) -> Dictionary:
	var current: Dictionary = pending(state).current
	if current.is_empty() or model not in returnable(state) or model in current.unplaced: return {"error": "Choose a destroyed troop model that has not already been declared unplaceable."}
	if not current.placements.has(model) and current.placements.size() + current.unplaced.size() >= current.slots: return {"error": "All return attempts are already assigned."}
	current.placements.erase(model)
	current.unplaced.append(model)
	return {"error": "", "message": "Controller declares model %d cannot be placed. It remains destroyed; this failed return will be recorded." % model}

static func reset_preview(state: Dictionary) -> Dictionary:
	var current: Dictionary = pending(state).current
	if current.is_empty() or current.get("reroll_pending", false): return {"error": "Resolve the roll decision before resetting a placement preview."}
	current.placements = {}
	current.unplaced = []
	return {"error": "", "message": "Reanimation preview reset; original D3 and healing budget retained."}

static func suggest(state: Dictionary) -> Dictionary:
	if pending(state).current.is_empty() or pending(state).current.get("reroll_pending", false): return {"error": "Resolve the roll decision before suggesting return positions."}
	var working := state.duplicate(true)
	var current: Dictionary = pending(working).current
	for model: int in returnable(working):
		if current.placements.size() + current.unplaced.size() >= current.slots: break
		if current.placements.has(model) or model in current.unplaced: continue
		var points: Array[Vector2] = [working.units[model].position]
		for anchor: int in current.anchors:
			if working.units[anchor].wounds <= 0: continue
			for gap in [0.1, 0.7, 1.3, 1.9]:
				for direction in range(24):
					var offset: Vector2 = Vector2.RIGHT.rotated(direction * TAU / 24.0) * (float(working.units[anchor].radius) + float(working.units[model].radius) + float(gap))
					points.append(working.units[anchor].position + offset)
		var found := false
		for point: Vector2 in points:
			if position_error(working, model, point).is_empty():
				current.placements[model] = point
				found = true
				break
		if not found: return {"error": "No complete suggestion found. Place models manually or record a controller-declared inability to place; the search is not exhaustive."}
	state.reanimation.pending.current.placements = current.placements.duplicate()
	return {"error": "", "message": "Suggested return positions are previews; review and confirm the unit."}

static func confirm_error(state: Dictionary) -> String:
	var current: Dictionary = pending(state).get("current", {})
	if current.is_empty(): return "Roll a unit's Reanimation first."
	if current.get("reroll_pending", false): return "Accept or re-roll Their Number is Legion first."
	if current.placements.size() + current.unplaced.size() != current.slots: return "Place each available returned model or explicitly record an inability to place it."
	for model: int in current.placements:
		var error := position_error(state, model, current.placements[model])
		if not error.is_empty(): return error
	if not current.placements.is_empty() and not Geometry.coherent(projected(state), current.squad): return "Returned models must leave the unit in coherency."
	return ""

static func confirm_unit(state: Dictionary) -> Dictionary:
	var error := confirm_error(state)
	if not error.is_empty(): return {"error": error}
	var window := pending(state)
	var current: Dictionary = window.current
	var restored := 0
	for model: int in current.healed:
		state.units[model].wounds += int(current.healed[model])
		restored += int(current.healed[model])
	for model: int in current.placements:
		state.units[model].wounds = 1
		state.units[model].position = current.placements[model]
		restored += 1
	var report := {"squad": current.squad, "raw_roll": current.raw_roll, "budget": current.budget, "healed": current.healed.duplicate(), "returned": current.placements.duplicate(), "unplaced": current.unplaced.duplicate(), "discarded": current.budget - restored}
	window.results.append(report)
	window.remaining.erase(current.squad)
	window.current = {}
	if window.remaining.is_empty():
		state.reanimation.last_results = window.results.duplicate(true)
		if window.get("kind", "") != "undying": state.reanimation.done_turn[window.player] = state.turn
		state.reanimation.pending = {}
	return {"error": "", "message": "%s: Reanimation restored %d wounds, returned %d models; %d healing unused, %d controller-declared placement failures." % [state.squads[current.squad].name, restored, current.placements.size(), report.discarded, current.unplaced.size()]}

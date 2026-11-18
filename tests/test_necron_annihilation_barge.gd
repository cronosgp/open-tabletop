extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const BARGE_ID := "40kdc:11e:necrons:annihilation-barge"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 3}]
	result[2].faction = "Necrons"
	result[2].points_limit = 1000
	result[2].entries = [{"definition_id": BARGE_ID, "models": 1, "copies": 1}]
	return result

func barge_models(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if C.UnitAbilities.identity(state.units[model]) == "annihilation-barge": result.append(model)
	result.sort()
	return result

func marine_squads(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != 1: continue
		var models := Geometry.alive(state, squad)
		if not models.is_empty() and C.UnitAbilities.identity(state.units[models[0]]) == "intercessor-squad": result.append(squad)
	result.sort()
	return result

func models_in_squad(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) == squad: result.append(model)
	result.sort()
	return result

func wounds_in_squad(state: Dictionary, squad: int) -> int:
	var total := 0
	for model: int in models_in_squad(state, squad): total += int(state.units[model].get("wounds", 0))
	return total

func place(state: Dictionary, models: Array[int], origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(float(index % 5) * 1.2, float(index / 5) * 1.2)
		state.units[models[index]].on_battlefield = true

func find_choice(state: Dictionary, player: int, action: String, value: String = "") -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func act(state: Dictionary, player: int, option: Dictionary) -> String:
	return C.unit_action(state, player, option, Vector2.ZERO, int(state.get("revision", -1)), Callable(self, "next_die"))

func run() -> void:
	var profile := Profiles.profile("annihilation-barge")
	check(profile.get("source_datasheet_id", "") == "000000553" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Barge facts come from the verified local App v1.2 export")
	check(profile.get("points_by_models", {}) == {1: 100} and profile.get("stats", {}).get("wounds", 0) == 9 and profile.get("base_size_source_mm", 0) == 60 and profile.get("base_size_source", "") == "60mm flying base", "Barge cost, wounds and flying-base measurement match the source")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-1", "malevolent-arcing"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("source_options", [{}])[0].get("implemented", false), "Reanimation, Deadly Demise, Malevolent Arcing and the cannon replacement are admitted")
	var construction := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": BARGE_ID, "models": 1, "copies": 1}]})
	check(str(construction.get("error", "")).is_empty() and int(construction.get("total", -1)) == 100, "The one-model Barge enters construction at 100 points: %s" % str(construction.get("error", "")))
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": BARGE_ID, "models": 2, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "Unpriced Barge sizes remain blocked")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Barge roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	var barges := barge_models(state)
	var enemies := marine_squads(state)
	check(barges.size() == 1 and enemies.size() == 3, "One Barge and three distinct Marine units materialize")
	if barges.size() != 1 or enemies.size() != 3:
		quit(1)
		return
	var barge := barges[0]
	var barge_squad := int(state.units[barge].squad)
	state.unit_abilities.setup_players = [1]
	state.unit_abilities.window = {}
	state.phase = "deployment"
	state.active = 2
	var tesla_choice := find_choice(state, 2, "necron-annihilation-barge-tesla-cannon", "tesla")
	check(not tesla_choice.is_empty(), "Army preparations offer the Gauss-to-Tesla cannon replacement")
	if not tesla_choice.is_empty():
		var tesla_error := act(state, 2, tesla_choice)
		check(tesla_error.is_empty(), "The Barge accepts its source-listed Tesla cannon replacement: %s" % tesla_error)
	var ranged: Array = state.units[barge].get("ranged_weapons", [])
	var gauss_found := false
	var tesla_found := false
	var destructor_id := ""
	for weapon: Dictionary in ranged:
		var weapon_name := str(weapon.get("profiles", {}).get("standard", {}).get("name", ""))
		if weapon_name == "Gauss cannon": gauss_found = true
		if weapon_name == "Tesla cannon": tesla_found = true
		if weapon_name == "Twin tesla destructor": destructor_id = str(weapon.get("id", ""))
	check(not gauss_found and tesla_found and not destructor_id.is_empty() and ranged.size() == 2, "Tesla cannon replaces only the Gauss cannon; destructor stays")
	var gauss_choice := find_choice(state, 2, "necron-annihilation-barge-tesla-cannon", "gauss")
	check(not gauss_choice.is_empty() and act(state, 2, gauss_choice).is_empty(), "The setup choice can restore the Gauss cannon")
	check(Reanimation.supported_unit(state, barge_squad), "The Barge enters the exact-size Reanimation scope")

	state.phase = "shooting"
	state.active = 2
	state.turn = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.units[barge].position = Vector2.ZERO
	state.units[barge].on_battlefield = true
	for model: int in models_in_squad(state, barge_squad): state.units[model].on_battlefield = true
	place(state, models_in_squad(state, enemies[0]), Vector2(0, 30))
	place(state, models_in_squad(state, enemies[1]), Vector2(0, 31.5))
	place(state, models_in_squad(state, enemies[2]), Vector2(0, 33.2))
	var starting_living: Dictionary = {}
	for squad: int in enemies: starting_living[squad] = wounds_in_squad(state, squad)
	var entries := [{"model": barge, "target": enemies[0], "amount": 1, "weapon": destructor_id, "profile": "standard"}]
	var plan := C.AttackPlan.prepare(state, barge_squad, false, entries, true)
	check(str(plan.get("error", "")).is_empty() and int(plan.get("batches", [{}])[0].get("weapon", {}).get("keywords", {}).get("sustained-hits", 0)) == 2 and bool(plan.get("batches", [{}])[0].get("weapon", {}).get("keywords", {}).get("twin-linked", false)), "Twin Tesla destructor retains its source weapon traits")
	if destructor_id.is_empty():
		print("Barge source profile diagnostic: " + var_to_str(profile))
		quit(1)
		return
	# Target rolls: primary 5+, adjacent squad 4 (not struck), next squad 5+.
	# Six 1s miss with the destructor; each triggered D3 then rolls a 1.
	scripted_dice = [5, 4, 5, 1, 1, 1, 1, 1, 1, 1, 1]
	var attack := C.resolve_attack_plan(state, 2, barge, entries, int(state.revision), false, true, Callable(self, "next_die"))
	check(str(attack.get("error", "")).is_empty() and str(state.pending_attack.get("current", {}).get("phase", "")) == "malevolent-arcing", "The arcing mortal packets enter defender allocation after the destructor resolves: %s" % str(attack.get("message", attack)))
	if not str(attack.get("error", "")).is_empty() or not state.has("pending_attack") or state.pending_attack.is_empty():
		quit(1)
		return
	var decision := Allocation.pending_decision(state)
	var decision_target := int(decision.get("legal_options", [{}])[0].get("target", -1)) if not decision.get("legal_options", []).is_empty() else -1
	check(int(decision.get("priority_player_id", -1)) == 1 and decision_target == enemies[0] and not decision.is_empty(), "The selected target's controller receives the first mortal allocation choice")
	check(not Allocation.choice_error(state, 2, models_in_squad(state, enemies[0])[0]).is_empty(), "The Barge's controller cannot allocate the defender's mortal wound")
	var allocation_count := 0
	while not state.get("pending_attack", {}).is_empty() and allocation_count < 8:
		var eligible := Allocation.eligible(state)
		if eligible.is_empty(): break
		var allocation_error := C.allocate_damage(state, 1, eligible[0], int(state.revision), Callable(self, "next_die"))
		check(allocation_error.is_empty(), "Defender allocation continues without error: %s" % allocation_error)
		allocation_count += 1
	check(state.get("pending_attack", {}).is_empty() and allocation_count == 2, "Only the two units struck on 5+ require separate D3 mortal allocation")
	check(wounds_in_squad(state, enemies[0]) == starting_living[enemies[0]] - 1 and wounds_in_squad(state, enemies[1]) == starting_living[enemies[1]] and wounds_in_squad(state, enemies[2]) == starting_living[enemies[2]] - 1, "Malevolent Arcing damages only the primary and the adjacent unit that rolled 5+")
	var arcing_rolls: Array = state.get("last_attack", {}).get("malevolent_arcing", [{}])[0].get("rolls", [])
	check(arcing_rolls.size() == 3 and int(arcing_rolls[0].get("roll", 0)) == 5 and bool(arcing_rolls[0].get("struck", false)) and int(arcing_rolls[1].get("roll", 0)) == 4 and not bool(arcing_rolls[1].get("struck", true)) and int(arcing_rolls[2].get("roll", 0)) == 5 and bool(arcing_rolls[2].get("struck", false)), "Malevolent Arcing records one D6 per unit and applies the 5+ threshold")
	check(state.get("last_attack", {}).get("malevolent_arcing_results", []).size() == 2, "Each struck living unit records a separate D3 mortal packet")
	state.units[barge].position = Vector2(0, 30)
	state.units[barge].wounds = 0
	scripted_dice = [6]
	var demise := DeadlyDemise.begin(state, [barge], Callable(self, "next_die"))
	var demise_event: Dictionary = state.get("pending_deadly_demise", {}).get("events", [{}])[0] if not state.get("pending_deadly_demise", {}).get("events", []).is_empty() else {}
	check(demise.get("error", "").is_empty() and not demise.get("complete", true) and demise_event.get("expression", "") == "1" and demise_event.get("triggered", false) and demise_event.get("targets", []).size() == 3, "The Barge's Deadly Demise 1 triggers on a 6 and affects each unit within 6 inches")
	var demise_guard := 8
	while not state.get("pending_deadly_demise", {}).is_empty() and demise_guard > 0:
		demise_guard -= 1
		var pending_packet: Dictionary = state.pending_deadly_demise.packets[state.pending_deadly_demise.packet_cursor]
		var demise_options := DeadlyDemise.choices(state, int(pending_packet.owner))
		check(not demise_options.is_empty(), "Each affected unit owner can allocate the Barge's mortal wound")
		if demise_options.is_empty(): break
		var allocation := DeadlyDemise.allocate(state, int(pending_packet.owner), demise_options[0], Callable(self, "next_die"))
		check(allocation.get("error", "").is_empty(), "Barge Deadly Demise resolves through the shared mortal-wound allocation path")
	check(state.get("pending_deadly_demise", {}).is_empty() and demise_guard > 0 and state.get("last_deadly_demise", {}).get("events", [{}])[0].get("expression", "") == "1", "The Barge's Deadly Demise event finishes with its source expression recorded")
	if failures == 0: print("Necron Annihilation Barge local checks: passed")
	else: print("Necron Annihilation Barge local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

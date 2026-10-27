extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "eradicator-squad-with-melta-rifles"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func lists() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:apothecary-biologis", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 6, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists())
	if s.has("error"): return s
	s.awakened_dynasty.pending = []
	s.mission.stage = "battle"
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.phase = "shooting"
	s.turn = 3
	s.round = 2
	s.active = 1
	s.cp = {1: 3, 2: 3}
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	s.terrain.areas = []
	for key in ["attack_rerolls", "save_rerolls", "damage_rerolls", "count_rerolls", "hazard_rerolls"]: s.stratagems[key] = false
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -15) if s.units[model].owner == 1 else Vector2(20, 15)
	return s
func place(s: Dictionary, edge: float) -> void:
	var radius := 20.0 / 25.4
	s.units[300].position = Vector2.ZERO
	for model: int in C.living(s, 4): s.units[model].position = Vector2(edge + radius * 2.0, 0)
func shoot(s: Dictionary, profile: String, dice: Array) -> Dictionary:
	var queue := dice.duplicate()
	var declaration := [{"model": 300, "target": 4, "amount": 1, "weapon": "melta-rifle", "profile": profile}]
	return C.resolve_attack_plan(s, 1, 300, declaration, s.revision, false, true, func() -> int: return queue.pop_front())
func submit_damage_choice(s: Dictionary, player: int, action: String, roller: Callable = Callable()) -> Dictionary:
	var decision := C.UnitActions.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching damage decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action: projected = option; break
	if projected.is_empty(): return {"error": "No projected damage choice %s." % action}
	var selected: Dictionary = {}
	for choice: Dictionary in C.UnitActions.choices(s, player):
		if str(choice.get("action", "")) == action: selected = choice; break
	if selected.is_empty(): return {"error": "No current damage choice %s." % action}
	var envelope := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision), "choice": envelope}, roller)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error"), "Melta Eradicator configurations admit with a Biologis bodyguard")
	if s.has("error"):
		print(s)
		quit(1)
		return
	check(s.training_points[1] == 360 and s.squads[3].training_cost == 100 and s.squads[5].training_cost == 200, "3/6 formations use the Melta Rifle prices, separate from Heavy Bolters")
	check(C.living(s, 3).size() == 3 and C.living(s, 5).size() == 6 and s.units[300].radius == 20.0 / 25.4, "Current composition and 40mm bases materialize")
	check(C.UnitActions.attachment_allowed(s, 100, 3) and not C.UnitAbilities.has(s, 3, "overlapping-destruction"), "Biologis accepts this sheet and it does not gain Heavy Bolter Blast selection")
	var raw: Dictionary = Profiles.profile(UNIT).ranged[0].profiles.standard
	check(raw.damage == "D3+2" and raw.keywords.melta == 2, "Source Melta Rifle keeps D3+2 and Melta 2")
	place(s, 8.0)
	var near := C.AttackPlan.prepare(s, 3, false, [{"model": 300, "target": 4, "amount": 1, "weapon": "melta-rifle", "profile": "standard"}], true)
	check(near.error.is_empty() and near.batches[0].weapon.damage == "D3+4" and raw.damage == "D3+2", "Half-range Melta 2 is frozen on the attack and the source profile stays unchanged")
	place(s, 10.0)
	var far := C.AttackPlan.prepare(s, 3, false, [{"model": 300, "target": 4, "amount": 1, "weapon": "melta-rifle", "profile": "standard"}], true)
	check(far.error.is_empty() and far.batches[0].weapon.damage == "D3+2", "Beyond half range the printed Damage characteristic remains")
	check(4 not in C.AttackPlan.legal_targets(s, 300, false, "melta-rifle", "hunter"), "Hunter cannot select a unit without Monster or Vehicle")
	for model: int in C.living(s, 4): s.units[model].keywords.append("VEHICLE")
	check(4 in C.AttackPlan.legal_targets(s, 300, false, "melta-rifle", "hunter"), "Hunter can select a Vehicle")
	var hunter := C.AttackPlan.prepare(s, 3, false, [{"model": 300, "target": 4, "amount": 1, "weapon": "melta-rifle", "profile": "hunter"}], true)
	check(hunter.error.is_empty() and hunter.batches[0].weapon.skill == 2 and hunter.batches[0].weapon.strength == 12, "Hunter uses the printed BS 2+ and Strength 12 profile")
	s = fixture()
	place(s, 10.0)
	var paused := shoot(s, "standard", [6, 6, 1, 6])
	check(paused.error.is_empty() and C.UnitActions.pending(s).kind == "damage-reroll" and s.pending_attack.current.pending_damage.rolled.value == 5 and s.cp[1] == 3, "Ranged Damage roll opens an optional re-roll before prevention")
	var reroll: Dictionary = {}
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "damage-reroll": reroll = selected
	var applied := submit_damage_choice(s, 1, "damage-reroll", func() -> int: return 1)
	var rerolled: Dictionary = s.last_attack.pools[0].damage_rolls[0]
	check(not reroll.is_empty() and str(applied.get("error", "")).is_empty() and s.get("pending_attack", {}).is_empty() and rerolled.expression == "D3+2" and rerolled.value == 3 and s.last_attack.pools[0].excess_damage_discarded == 2, "Re-rolling replaces the whole D3 and the constant stays through the public command")
	s = fixture()
	place(s, 8.0)
	paused = shoot(s, "standard", [6, 6, 1, 1])
	check(paused.error.is_empty() and s.pending_attack.current.pending_damage.rolled.expression == "D3+4" and s.pending_attack.current.pending_damage.rolled.value == 5, "Melta bonus is part of the Damage roll that can be kept")
	var keep: Dictionary = {}
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "damage-keep": keep = selected
	applied = submit_damage_choice(s, 1, "damage-keep")
	var kept: Dictionary = s.last_attack.pools[0].damage_rolls[0]
	check(not keep.is_empty() and str(applied.get("error", "")).is_empty() and kept.expression == "D3+4" and kept.value == 5 and s.last_attack.pools[0].excess_damage_discarded == 4 and s.cp[1] == 3, "Keeping the roll applies the Melta-adjusted Damage without spending CP through the public command")
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	var upgrades := 0
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "eradicator-melta" and selected.value == "multi" and selected.target == 3: upgrades += 1
	check(upgrades == 3, "A 3-model unit offers the Multi-melta replacement on every Eradicator")
	var first: Dictionary = {}
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "eradicator-melta" and selected.value == "multi" and selected.target == 3: first = selected
	check(PublicUnitCommand.error(s, 1, first).is_empty() and s.units[first.model].ranged_weapons[0].id == "multi-melta", "One model can replace its Melta Rifle through the public command")
	upgrades = 0
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "eradicator-melta" and selected.value == "multi" and selected.target == 3: upgrades += 1
	check(upgrades == 0, "The one-per-three-models cap blocks a second Multi-melta")
	var six := 0
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "eradicator-melta" and selected.value == "multi" and selected.target == 5: six += 1
	check(six == 6, "A 6-model unit starts with a replacement offer for each Eradicator")
	var invalid := lists()
	invalid[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 3, "copies": 1})
	check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Both sizes share this datasheet's Incursion repetition cap")
	var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:" + UNIT, "edition": "11e", "faction": "Space Marines"})
	check(catalog.options == [{"models": 3, "cost": 100}, {"models": 6, "cost": 200}], "Builder uses the current Melta Rifle sizes and costs")
	print("Melta Rifle Eradicator checks: %d failures" % failures)
	quit(1 if failures else 0)

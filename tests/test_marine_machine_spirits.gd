extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const CombatDoctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state(identity: String, target_keywords: Array = ["INFANTRY"], target_x: float = 0.0) -> Dictionary:
	var state := F.fresh()
	state.units.clear()
	state.squads.clear()
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.window = {}
	state.awakened_dynasty.pending = []
	state.stratagems.pending = {}
	state.stratagems.attack_rerolls = false
	state.stratagems.count_rerolls = false
	var profile := Profiles.profile(identity)
	state.squads[1] = {"owner": 1, "name": profile.name, "starting_strength": 1, "stats": profile.stats.duplicate(true), "shot": false, "advanced": false, "moved_distance": 0.0}
	state.units[100] = {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:" + identity, "position": Vector2(-10, 0), "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "ranged_weapons": profile.ranged.duplicate(true), "melee_weapons": profile.melee.duplicate(true), "transport_profile": profile.get("transport", {}).duplicate(true)}
	state.squads[2] = {"owner": 2, "name": "Target", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 7, "wounds": 100, "objective_control": 1}, "battle_shocked": false}
	state.units[200] = {"owner": 2, "squad": 2, "definition_id": "test:target", "position": Vector2(target_x, 0), "radius": 0.5, "keywords": target_keywords, "wounds": 100, "max_wounds": 100, "on_battlefield": true}
	UnitAbilities.enable(state)
	return state

func _roll_three() -> int:
	return 3

func assignment(state: Dictionary, weapon_index: int = 0) -> Dictionary:
	var choices: Array[Dictionary] = AttackPlan.Equipment.choices(state, 100, false)
	return {"model": 100, "target": 2, "amount": 1, "weapon": choices[weapon_index].weapon, "profile": choices[weapon_index].profile}

func run() -> void:
	var crusader := make_state("land-raider-crusader")
	var prepared := AttackPlan.prepare(crusader, 1, false, [assignment(crusader)], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].weapon.keywords.get("lethal-hits", false), "Crusader ranged attacks gain Lethal Hits against a target within 12 inches")
	var far_crusader := make_state("land-raider-crusader", ["INFANTRY"], 8.0)
	prepared = AttackPlan.prepare(far_crusader, 1, false, [assignment(far_crusader)], false)
	check(prepared.get("error", "").is_empty() and not prepared.batches[0].weapon.keywords.get("lethal-hits", false), "Crusader Lethal Hits ends beyond 12 inches")
	var redeemer := make_state("land-raider-redeemer")
	prepared = AttackPlan.prepare(redeemer, 1, false, [assignment(redeemer, 2)], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].weapon.keywords.get("devastating-wounds", false), "Redeemer ranged attacks gain Devastating Wounds against non-MONSTER, non-VEHICLE targets within 12 inches")
	var monster := make_state("land-raider-redeemer", ["MONSTER"], 0.0)
	prepared = AttackPlan.prepare(monster, 1, false, [assignment(monster, 2)], false)
	check(prepared.get("error", "").is_empty() and not prepared.batches[0].weapon.keywords.get("devastating-wounds", false), "Redeemer does not gain the Devastating Wounds rider against MONSTER targets")
	var vehicle := make_state("land-raider-redeemer", ["VEHICLE"], 0.0)
	prepared = AttackPlan.prepare(vehicle, 1, false, [assignment(vehicle, 2)], false)
	check(prepared.get("error", "").is_empty() and not prepared.batches[0].weapon.keywords.get("devastating-wounds", false), "Redeemer does not gain the Devastating Wounds rider against VEHICLE targets")
	var land_raider := make_state("land-raider")
	var entry := assignment(land_raider)
	prepared = AttackPlan.prepare(land_raider, 1, false, [entry], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.get("machine_spirit_power", false), "Land Raider ranged attacks carry the Power of the Machine Spirit re-roll choices")
	Allocation.start(land_raider, prepared, 1, 1, [entry], false, true, false)
	var result := Allocation.pump(land_raider, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and land_raider.unit_abilities.window.get("kind", "") == "machine-spirit-hit", "Land Raider may pause to choose one ranged Hit re-roll")
	var hit_choices := UnitActions.choices(land_raider, 1)
	var hit_reroll := hit_choices.filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-reroll")
	check(not hit_reroll.is_empty(), "Power of the Machine Spirit offers individual Hit dice")
	if not hit_reroll.is_empty():
		var applied := UnitActions.apply(land_raider, 1, hit_reroll[0], Vector2.ZERO, Callable(self, "_roll_three"))
		check(applied.get("error", "").is_empty() and land_raider.pending_attack.machine_spirit_used.hit, "Land Raider Hit re-roll is optional and used at most once")
	result = Allocation.pump(land_raider, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and land_raider.unit_abilities.window.get("kind", "") == "machine-spirit-wound", "Land Raider may separately choose one ranged Wound re-roll")
	var wound_choices := UnitActions.choices(land_raider, 1)
	var wound_reroll := wound_choices.filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-reroll")
	check(not wound_reroll.is_empty(), "Power of the Machine Spirit offers individual Wound dice")
	if not wound_reroll.is_empty():
		var applied := UnitActions.apply(land_raider, 1, wound_reroll[0], Vector2.ZERO, Callable(self, "_roll_three"))
		check(applied.get("error", "").is_empty() and land_raider.pending_attack.machine_spirit_used.wound, "Land Raider Wound re-roll is optional and used at most once")
	result = Allocation.pump(land_raider, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and result.get("complete", false), "Land Raider attack sequence resumes and completes after its chosen re-rolls")
	var split_targets := make_state("land-raider")
	split_targets.squads[3] = {"owner": 2, "name": "Second Target", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 7, "wounds": 100, "objective_control": 1}, "battle_shocked": false}
	split_targets.units[300] = {"owner": 2, "squad": 3, "definition_id": "test:target", "position": Vector2(0, 3), "radius": 0.5, "keywords": ["INFANTRY"], "wounds": 100, "max_wounds": 100, "on_battlefield": true}
	var first_entry := assignment(split_targets)
	var second_entry := assignment(split_targets, 1)
	second_entry.target = 3
	prepared = AttackPlan.prepare(split_targets, 1, false, [first_entry, second_entry], false)
	check(prepared.get("error", "").is_empty() and prepared.batches.size() >= 2, "Land Raider weapon profiles split into separate target attack batches")
	Allocation.start(split_targets, prepared, 1, 1, [first_entry, second_entry], false, true, false)
	result = Allocation.pump(split_targets, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and split_targets.unit_abilities.window.get("kind", "") == "machine-spirit-hit", "The first target batch may use the Machine Spirit Hit re-roll")
	var finish_hit := UnitActions.choices(split_targets, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-finish")
	if not finish_hit.is_empty(): UnitActions.apply(split_targets, 1, finish_hit[0], Vector2.ZERO, Callable(self, "_roll_three"))
	result = Allocation.pump(split_targets, Callable(self, "_roll_three"))
	var finish_wound := UnitActions.choices(split_targets, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-finish")
	if not finish_wound.is_empty(): UnitActions.apply(split_targets, 1, finish_wound[0], Vector2.ZERO, Callable(self, "_roll_three"))
	result = Allocation.pump(split_targets, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and result.get("complete", false) and split_targets.pending_attack.machine_spirit_used.hit and split_targets.pending_attack.machine_spirit_used.wound, "Power of the Machine Spirit is once per Land Raider attack activation, even across targets")
	var ironstorm := make_state("storm-speeder-hailstrike")
	CombatDoctrines.enable(ironstorm, "ironstorm-spearhead")
	check(CombatDoctrines.ironstorm_auto_targeters(ironstorm, 100), "Ironstorm Auto-targeters accepts a friendly Astartes Vehicle that is not a Walker")
	var iron_entry := assignment(ironstorm)
	prepared = AttackPlan.prepare(ironstorm, 1, false, [iron_entry], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.get("machine_spirit_source", "") == "Ironstorm Auto-targeters", "Ironstorm ranged vehicle attacks enter the named Auto-targeters choice flow")
	Allocation.start(ironstorm, prepared, 1, 1, [iron_entry], false, true, false)
	result = Allocation.pump(ironstorm, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and ironstorm.unit_abilities.window.get("source", "") == "Ironstorm Auto-targeters", "Ironstorm Hit re-roll window retains its Wahapedia rule name")
	var iron_reroll := UnitActions.choices(ironstorm, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-reroll")
	check(not iron_reroll.is_empty() and iron_reroll[0].label.begins_with("Ironstorm Auto-targeters"), "Ironstorm offers a source-labelled optional Hit re-roll")
	if not iron_reroll.is_empty(): UnitActions.apply(ironstorm, 1, iron_reroll[0], Vector2.ZERO, Callable(self, "_roll_three"))
	result = Allocation.pump(ironstorm, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and ironstorm.unit_abilities.window.get("kind", "") == "machine-spirit-wound", "Ironstorm separately offers one Wound re-roll")
	var iron_finish := UnitActions.choices(ironstorm, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "machine-spirit-finish")
	if not iron_finish.is_empty(): UnitActions.apply(ironstorm, 1, iron_finish[0], Vector2.ZERO, Callable(self, "_roll_three"))
	result = Allocation.pump(ironstorm, Callable(self, "_roll_three"))
	check(result.get("error", "").is_empty() and result.get("complete", false) and ironstorm.pending_attack.machine_spirit_used.hit and ironstorm.pending_attack.machine_spirit_used.wound, "Ironstorm can use each optional re-roll once and then complete its attack")
	var iron_walker := make_state("redemptor-dreadnought")
	CombatDoctrines.enable(iron_walker, "ironstorm-spearhead")
	check(not CombatDoctrines.ironstorm_auto_targeters(iron_walker, 100), "Ironstorm Auto-targeters excludes Walker vehicles")
	var iron_infantry := make_state("intercessor-squad")
	CombatDoctrines.enable(iron_infantry, "ironstorm-spearhead")
	check(not CombatDoctrines.ironstorm_auto_targeters(iron_infantry, 100), "Ironstorm Auto-targeters excludes non-Vehicle Astartes units")
	print("Land Raider Machine Spirit rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")

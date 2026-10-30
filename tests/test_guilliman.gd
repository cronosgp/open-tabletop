extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")

var failures := 0
var dice_queue: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func queued_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and UnitAbilities.identity(state.units[model]) == identity:
			return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner: continue
		for model: int in Geometry.alive(state, squad):
			if UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func place_squad(state: Dictionary, squad: int, origin: Vector2) -> void:
	var index := 0
	for model: int in Geometry.alive(state, squad):
		state.units[model].on_battlefield = true
		state.units[model].position = origin + Vector2(float(index) * 1.35, 0.0)
		index += 1

func action(state: Dictionary, player: int, action_id: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action_id: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		return option
	return {}

func submit_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var pending := PendingDecisions.current(state, ["unit-actions"])
	var payload: Dictionary = selected
	if not pending.is_empty():
		if int(pending.get("priority_player_id", -1)) != player:
			return {"error": "The current unit-action decision belongs to another player."}
		var projected: Dictionary = {}
		for option: Dictionary in pending.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) \
				and int(option.get("model", -1)) == int(selected.get("model", -1)) \
				and int(option.get("target", -1)) == int(selected.get("target", -1)) \
				and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return {"error": "The selected Guilliman choice is not in the current decision projection."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE,
			"decision_id": str(pending.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"revision": int(state.revision),
		"choice": payload
	}, Callable(self, "queued_die"))

func make_state() -> Dictionary:
	var selections := F.current_marine_selections()
	selections[1].entries = [entry("roboute-guilliman"), entry("intercessor-squad", 5), entry("captain")]
	selections[2].entries = [entry("roboute-guilliman"), entry("intercessor-squad", 5)]
	var state: Dictionary = P.initial_state({
		"checked_rosters": false,
		"official_mission": false,
		"unit_abilities": true,
		"combat_doctrines": true,
		"core_stratagems": true,
		"reanimation_protocols": true,
		"awakened_dynasty": true,
		"manual_allocation": false
	}, selections)
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.setup_players = []
	return state

func run() -> void:
	var profile := Profiles.profile("roboute-guilliman")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000138"
		and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00",
		"Guilliman profile identifies the exact shared-book Wahapedia datasheet")
	check(profile.points == 415 and profile.points_by_models == {1: 415} and profile.models == 1
		and profile.max_supported_copies == 1
		and is_equal_approx(profile.base_radius_inches, 30.0 / 25.4)
		and profile.stats == {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 16,
		"leadership_target": 5, "objective_control": 4, "invulnerable_target": 4},
		"Guilliman source cost, one-model composition, unique-copy limit, 60 mm base and characteristics match")
	check(profile.keywords == ["MONSTER", "CHARACTER", "EPIC HERO", "IMPERIUM", "MOBILE", "PRIMARCH", "ADEPTUS ASTARTES", "ULTRAMARINES"]
		and profile.get("additional_weapon_profiles", {}).is_empty(),
		"Guilliman preserves the source keywords and has no selectable equipment options")
	check(profile.ranged.size() == 1 and profile.melee.size() == 2
		and profile.ranged[0].physical_weapon_id == "hand-of-dominion"
		and profile.melee[1].physical_weapon_id == "hand-of-dominion",
		"The Hand of Dominion's ranged and melee profiles resolve from one physical weapon")
	if profile.ranged.size() == 1 and profile.melee.size() == 2:
		var ranged: Dictionary = profile.ranged[0].profiles.standard
		var sword: Dictionary = profile.melee[0].profiles.standard
		var gauntlet: Dictionary = profile.melee[1].profiles.standard
		check(ranged.range_inches == 36 and ranged.attacks == 4 and ranged.skill == 2 and ranged.strength == 6
			and ranged.ap == -2 and ranged.damage == 2 and ranged.keywords == {"rapid-fire": 2, "sustained-hits": 1},
			"Hand of Dominion ranged profile and traits match the local export")
		check(sword.attacks == 10 and sword.skill == 2 and sword.strength == 10 and sword.ap == -3
			and sword.damage == 2 and sword.keywords == {"devastating-wounds": true, "cleave": 2},
			"Emperor's Sword profile preserves Devastating Wounds and CLEAVE 2")
		check(gauntlet.attacks == 7 and gauntlet.skill == 2 and gauntlet.strength == 14 and gauntlet.ap == -4
			and gauntlet.damage == 4 and gauntlet.keywords == {"lethal-hits": true},
			"Hand of Dominion melee profile and Lethal Hits match the local export")
	var identity := "40kdc:11e:adeptus-astartes:roboute-guilliman"
	var catalog_choice := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0].get("models", 0) == 1
		and catalog_choice.options[0].get("cost", 0) == 415
		and Catalog.resolve("Space Marines", identity).get("error", "").is_empty(),
		"The consolidated current catalog admits Guilliman as one 415-point model")

	var state := make_state()
	check(not state.has("error"), "Both players' current Space Marines catalogs materialize Guilliman")
	if state.has("error"):
		print(state.get("error", ""))
		quit(1)
		return
	state.terrain.areas = []
	var primarch := find_model(state, 1, "roboute-guilliman")
	var opponent_primarch := find_model(state, 2, "roboute-guilliman")
	var infantry := find_squad(state, 1, "intercessor-squad")
	var enemy_infantry := find_squad(state, 2, "intercessor-squad")
	check(primarch > 0 and opponent_primarch > 0 and infantry > 0 and enemy_infantry > 0,
		"Both Guilliman models and current Intercessor squads resolve to runtime state")
	if primarch < 0 or opponent_primarch < 0 or infantry < 0 or enemy_infantry < 0:
		quit(1)
		return
	var primarch_squad: int = int(state.units[primarch].squad)
	check(UnitAbilities.has(state, primarch_squad, "supreme-commander")
		and UnitAbilities.has(state, primarch_squad, "transhuman-strategist")
		and UnitAbilities.has(state, primarch_squad, "codex-adept")
		and UnitAbilities.has(state, primarch_squad, "primarch-of-the-xiii")
		and UnitAbilities.has(state, primarch_squad, "author-of-the-codex")
		and UnitAbilities.has(state, primarch_squad, "feel-no-pain-5-guilliman")
		and UnitAbilities.has(state, primarch_squad, "leader-of-the-astartes"),
		"All seven Guilliman unit abilities are registered; Combat Doctrines are checked separately")
	var doctrines: Array[String] = Doctrines.active_doctrines_for(state, primarch_squad)
	check(doctrines.size() == 3 and "assault" in doctrines and "devastator" in doctrines and "tactical" in doctrines,
		"Codex Adept keeps all three Combat Doctrines active for Guilliman's unit")

	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-18.0, 8.0) if int(state.units[model].owner) == 1 else Vector2(-8.0, 8.0)
	state.units[primarch].position = Vector2(-18.0, 8.0)
	state.units[opponent_primarch].position = Vector2(30.0, 8.0)
	place_squad(state, infantry, Vector2(-16.0, 8.0))
	place_squad(state, enemy_infantry, Vector2(-4.0, 8.0))
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, primarch, enemy_infantry):
		check(false, "Guilliman source weapon plan: " + failure)
	state.phase = "shooting"
	state.active = 1
	check(UnitAbilities.primarch_aura_active(state, infantry)
		and not UnitAbilities.primarch_aura_active(state, enemy_infantry),
		"Primarch of the XIII applies only to friendly Astartes units within 6 inches")
	var attacker_model := find_model(state, 1, "intercessor-squad")
	var selected_weapon: Dictionary = Equipment.select(state, attacker_model, false) if attacker_model > 0 else {"error": "No living Intercessor"}
	var attacks: Array = []
	if str(selected_weapon.get("error", "")).is_empty():
		attacks = [{"model": attacker_model, "target": enemy_infantry, "weapon": selected_weapon.weapon,
			"profile": selected_weapon.profile, "amount": 1}]
	var prepared := C.AttackPlan.prepare(state, infantry, false, attacks, true)
	check(prepared.get("error", "").is_empty() and prepared.get("batches", []).size() > 0
		and prepared.batches[0].context.hit_reroll == "ones"
		and prepared.batches[0].context.wound_reroll == "ones",
		"Primarch of the XIII reaches the actual attack plan with Hit and Wound rerolls of 1: %s" % str(prepared))
	var fnp_rules: Array = Prevention.rules(state, primarch)
	check({"target": 5, "against": "any"} in fnp_rules and {"target": 6, "against": "any"} not in fnp_rules,
		"Guilliman has the source-listed Feel No Pain 5+, not 6+")
	dice_queue = [4, 5]
	var failed_fnp := C.Attacks.Prevention.resolve(1, 1, fnp_rules, "normal", Callable(self, "queued_die"))
	var passed_fnp := C.Attacks.Prevention.resolve(1, 1, fnp_rules, "normal", Callable(self, "queued_die"))
	check(failed_fnp.get("lost", -1) == 1 and passed_fnp.get("lost", -1) == 0
		and passed_fnp.get("prevented", 0) == 1,
		"Feel No Pain 5+ fails on 4 and prevents the wound on 5")

	state.phase = "deployment"
	var warlord_choice := action(state, 1, "warlord", "", -1, primarch)
	var other_warlord_choices: Array[int] = []
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.action == "warlord" and int(option.get("model", -1)) != primarch:
			other_warlord_choices.append(int(option.model))
	check(not warlord_choice.is_empty() and other_warlord_choices.is_empty(),
		"Supreme Commander offers Guilliman as the army's only Warlord choice")
	if not warlord_choice.is_empty():
		var before_wrong_warlord_owner := var_to_bytes(state)
		var wrong_warlord_owner := submit_choice(state, 2, warlord_choice)
		check(not str(wrong_warlord_owner.get("error", "")).is_empty()
			and var_to_bytes(state) == before_wrong_warlord_owner,
			"The opposing player cannot submit or mutate Guilliman's Warlord choice")
		var warlord_result := submit_choice(state, 1, warlord_choice)
		check(str(warlord_result.get("error", "")).is_empty()
			and int(state.unit_abilities.warlords.get(1, -1)) == primarch,
			"Guilliman is recorded as Warlord through the public unit-choice command: %s" % str(warlord_result))

	state.phase = "movement"
	state.active = 1
	state.turn = 1
	state.round = 1
	var author_choice := action(state, 1, "author", "devastator", infantry, primarch)
	check(not author_choice.is_empty()
		and action(state, 2, "author", "devastator", infantry, primarch).is_empty(),
		"Author of the Codex is offered in the owner's Movement phase for a visible friendly Astartes unit within 12 inches")
	if not author_choice.is_empty():
		var before_wrong_author_owner := var_to_bytes(state)
		var wrong_author_owner := submit_choice(state, 2, author_choice)
		check(not str(wrong_author_owner.get("error", "")).is_empty()
			and var_to_bytes(state) == before_wrong_author_owner,
			"The opponent cannot submit or mutate Author of the Codex")
		var author_result := submit_choice(state, 1, author_choice)
		check(str(author_result.get("error", "")).is_empty()
			and Doctrines.has_doctrine(state, infantry, "devastator"),
			"Author of the Codex grants the selected additional doctrine through the public command")
		check(action(state, 1, "author", "devastator", infantry, primarch).is_empty(),
			"Guilliman cannot use Author of the Codex a second time in the same Movement phase")
		state.active = 2
		state.phase = "command"
		UnitAbilities.start_command(state)
		check(Doctrines.has_doctrine(state, infantry, "devastator"),
			"Author's additional doctrine remains active through the opponent's Command phase")
		state.active = 1
		UnitAbilities.start_command(state)
		check(not Doctrines.has_doctrine(state, infantry, "devastator"),
			"Author's additional doctrine expires at the start of the owner's next Command phase")

	state.units[primarch].position = Vector2.ZERO
	place_squad(state, infantry, Vector2(2.0, 0.0))
	check(UnitAbilities.lone_operative_active(state, primarch),
		"Leader of Astartes grants Lone Operative within 3 inches of friendly Astartes Infantry")
	place_squad(state, infantry, Vector2(5.0, 0.0))
	check(not UnitAbilities.lone_operative_active(state, primarch),
		"Leader of Astartes ends beyond its 3-inch boundary")
	place_squad(state, infantry, Vector2(20.0, 0.0))
	place_squad(state, enemy_infantry, Vector2.ZERO)
	check(not UnitAbilities.lone_operative_active(state, primarch),
		"An opposing Astartes Infantry unit does not grant Guilliman Lone Operative")

	state.unit_abilities.warlords = {1: primarch}
	state.first_player = 1
	state.active = 1
	state.round = 2
	var cp_before := int(state.cp[1])
	UnitActions.start_round(state)
	UnitActions.start_round(state)
	check(int(state.cp[1]) == cp_before + 1,
		"Transhuman Strategist grants 1 CP once per battle round while Guilliman is Warlord")
	print("Roboute Guilliman source-bounded current scope checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

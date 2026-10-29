extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "lion-eljonson"
const UNIT_ID := "40kdc:11e:adeptus-astartes:lion-eljonson"

var failures := 0
var dice_queue: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "escape_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "ULTRAMARINES"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String, owner: int) -> int:
	var found := models(state, identity, owner)
	return int(state.units[found[0]].squad) if not found.is_empty() else -1

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000002682" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Lion cites the pinned Dark Angels App export")
	check(profile.get("points_by_models", {}) == {1: 415} and profile.get("max_supported_copies", 0) == 1 and profile.get("base_size_source_mm") == 60, "The one-model 415-point Epic Hero and 60 mm base match the source")
	check(profile.get("stats", {}) == {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 16, "leadership_target": 5, "objective_control": 4, "invulnerable_target": 3}, "Characteristics and the 3+ invulnerable save match the source")
	check(profile.get("keywords", []) == ["MONSTER", "CHARACTER", "EPIC HERO", "IMPERIUM", "MOBILE", "PRIMARCH", "ADEPTUS ASTARTES", "DARK ANGELS"], "All exported faction and datasheet keywords are present")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return w.id) == ["arma-luminis"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return w.id) == ["fealty"], "Arma Luminis and Fealty are each represented as one physical weapon with two modes")
	check(AbilityCatalog.RULES.get(UNIT, []).size() == 13 and "supreme-commander" in AbilityCatalog.RULES.get(UNIT, []), "All core and datasheet abilities are registered")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 415 and C.RosterValidation.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "The current construction and price catalogs admit one Lion")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 415}], "The consolidated local catalog exposes Lion at 415 points")
	var duplicate_roster := {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]}
	check(not Catalog.admit(duplicate_roster).get("error", "").is_empty(), "Construction rejects a second Lion")
	for ability: String in AbilityCatalog.RULES.get(UNIT, []):
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("supported", false), "%s is declared in the capability registry" % ability)

	var state := fixture()
	check(not state.has("error"), "Both Chapter rosters materialize Lion and source targets: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var lion_models := models(state, UNIT, 1)
	var friendly_models := models(state, "intercessor-squad", 1)
	var enemy_models := models(state, "intercessor-squad", 2)
	var lion := lion_models[0] if not lion_models.is_empty() else -1
	var friendly := friendly_models[0] if not friendly_models.is_empty() else -1
	var enemy_squad := squad_for(state, "intercessor-squad", 2)
	var lion_squad := int(state.units[lion].squad) if lion >= 0 else -1
	var friendly_squad := int(state.units[friendly].squad) if friendly >= 0 else -1
	check(lion >= 0 and friendly_models.size() == 5 and enemy_models.size() == 5, "Lion and both Intercessor squads materialize from current catalogs")
	if lion < 0 or friendly < 0 or enemy_models.is_empty():
		quit(1)
		return

	var source_weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, profile, lion, enemy_squad)
	check(source_weapon_failures.is_empty(), "Every Lion weapon mode resolves through Equipment and AttackPlan: %s" % str(source_weapon_failures))
	check(C.UnitAbilities.defensive_wound_modifier(state, lion_squad, 11, 10, false) == -1 and C.UnitAbilities.defensive_wound_modifier(state, lion_squad, 10, 10, true) == 0, "The Emperor’s Shield worsens Wound rolls only when attacking Strength exceeds Toughness")
	var personal_fnp: Array = C.UnitPrevention.rules(state, lion)
	check({"target": 4, "against": "psychic"} in personal_fnp and {"target": 4, "against": "mortal"} in personal_fnp, "The Watchers grant Lion Feel No Pain 4+ against psychic and mortal wounds")
	dice_queue = [3, 4, 4]
	var psychic_fnp := C.Attacks.Prevention.resolve(1, 1, personal_fnp, "normal", Callable(self, "roll_die"), "psychic")
	var mortal_fnp := C.Attacks.Prevention.resolve(1, 1, personal_fnp, "mortal", Callable(self, "roll_die"))
	check(psychic_fnp.get("lost", -1) == 1 and mortal_fnp.get("prevented", 0) == 1, "Lion’s 4+ prevention is applied to a psychic wound and a mortal wound")

	for model: int in lion_models: state.units[model].position = Vector2.ZERO
	for index: int in range(friendly_models.size()): state.units[friendly_models[index]].position = Vector2(0.65 * index, 0.0)
	for model: int in enemy_models: state.units[model].position = Vector2(30.0 + float(model % 5), 0.0)
	check(str(state.marine_chapters.get(1, "")) == "DARK ANGELS" and C.UnitAbilities.lone_operative_active(state, lion), "Lion gains Lone Operative within 3 inches of friendly Dark Angels Infantry")
	for model: int in friendly_models: state.units[model].position = Vector2(12.0, 0.0)
	check(not C.UnitAbilities.lone_operative_active(state, lion), "Dark Angels Bodyguard stops granting Lone Operative beyond 3 inches")
	for model: int in friendly_models: state.units[model].position = Vector2(1.5, 0.0)

	var warlord_choice := option(state, 1, "warlord", "", -1, lion)
	var other_warlords: Array[Dictionary] = []
	for candidate: Dictionary in C.UnitActions.choices(state, 1):
		if str(candidate.get("action", "")) == "warlord" and int(candidate.get("model", -1)) != lion: other_warlords.append(candidate)
	var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
	check(not warlord_choice.is_empty() and other_warlords.is_empty() and warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == lion, "Supreme Commander makes Lion the sole Warlord choice through public preparation")
	check(not PublicUnitCommand.submit(state, 2, warlord_choice).get("error", "").is_empty(), "The opposing player cannot submit Lion’s Warlord choice")

	state.phase = "command"
	state.active = 1
	state.turn = 1
	C.UnitAbilities.start_command(state)
	C.Doctrines.start_command(state)
	state.combat_doctrines.selected_turn[1] = state.turn
	C.UnitActions.reconcile(state)
	var master_choice := option(state, 1, "lion-master-strategist", "devastator", lion_squad, lion)
	var doctrine_result := PublicUnitCommand.submit(state, 1, master_choice)
	var available_actions: Array = C.UnitActions.choices(state, 1).map(func(candidate: Dictionary) -> String: return str(candidate.get("action", "")))
	check(not master_choice.is_empty() and doctrine_result.get("error", "").is_empty() and C.Doctrines.has_doctrine(state, lion_squad, "devastator") and not C.Doctrines.has_doctrine(state, friendly_squad, "devastator"), "Master Strategist adds its selected doctrine to Lion’s unit only; choice=%s result=%s window=%s available=%s sources=%s enabled=%s actions=%s" % [str(master_choice), str(doctrine_result), str(state.unit_abilities.get("window", {})), str(C.Doctrines.available(state, 1)), str(C.UnitAbilities.sources(state, lion_squad, "primarch-of-the-first-legion")), str(C.UnitAbilities.enabled(state)), str(available_actions)])
	var martial_choice := option(state, 1, "lion-primarch", "martial-exemplar", lion_squad, lion)
	var martial_result := PublicUnitCommand.submit(state, 1, martial_choice)
	check(not martial_choice.is_empty() and martial_result.get("error", "").is_empty(), "Primarch of the First Legion accepts its first ability through the public Command choice; choice=%s result=%s window=%s" % [str(martial_choice), str(martial_result), str(state.unit_abilities.get("window", {}))])
	var watchers_choice := option(state, 1, "lion-primarch", "no-hiding-from-the-watchers", lion_squad, lion)
	var watchers_result := PublicUnitCommand.submit(state, 1, watchers_choice)
	check(not watchers_choice.is_empty() and watchers_result.get("error", "").is_empty() and C.UnitAbilities.lion_primarch_selected(state, lion_squad, "martial-exemplar") and C.UnitAbilities.lion_primarch_selected(state, lion_squad, "no-hiding-from-the-watchers"), "Lion can select two distinct Primarch abilities for the Command phase")
	check(option(state, 1, "lion-primarch", "mist-wreathed-shadow-realms", lion_squad, lion).is_empty(), "Lion cannot select a third Primarch ability this Command phase")
	check({"target": 5, "against": "psychic"} in C.UnitPrevention.rules(state, friendly) and {"target": 5, "against": "mortal"} in C.UnitPrevention.rules(state, friendly), "No Hiding from the Watchers grants the selected Dark Angels unit its 5+ prevention aura")
	check(C.UnitAbilities.lion_aura_active(state, friendly_squad, "martial-exemplar") and not C.UnitAbilities.lion_aura_active(state, enemy_squad, "martial-exemplar"), "Martial Exemplar is limited to friendly Dark Angels within 6 inches")

	state.phase = "fight"
	state.active = 1
	for model: int in enemy_models: state.units[model].position = Vector2(2.5, 0.0)
	var attack_rows: Array = C.AttackPlan.single_target(state, friendly_squad, enemy_squad, true)
	var attack_plan: Dictionary = C.AttackPlan.prepare(state, friendly_squad, true, attack_rows, true)
	check(attack_plan.get("error", "").is_empty() and not attack_plan.get("batches", []).is_empty() and attack_plan.batches[0].context.get("hit_reroll", "") == "ones" and attack_plan.batches[0].context.get("wound_reroll", "") == "ones", "Martial Exemplar reaches the allied melee attack plan with Hit and Wound rerolls of 1; plan=%s active=%s" % [str(attack_plan), str(C.UnitAbilities.lion_aura_active(state, friendly_squad, "martial-exemplar"))])

	state.phase = "command"
	state.active = 1
	state.turn = 2
	C.UnitAbilities.start_command(state)
	check(not C.UnitAbilities.lion_primarch_selected(state, lion_squad, "martial-exemplar") and not C.Doctrines.has_doctrine(state, lion_squad, "devastator"), "Lion’s selected abilities and additional doctrine expire at the next owner Command phase")

	var reserve_state := fixture()
	if not reserve_state.has("error"):
		var reserve_lion := models(reserve_state, UNIT, 1)[0]
		var reserve_squad := int(reserve_state.units[reserve_lion].squad)
		reserve_state.phase = "command"
		reserve_state.active = 1
		reserve_state.turn = 1
		C.UnitAbilities.start_command(reserve_state)
		reserve_state.combat_doctrines.selected_turn[1] = reserve_state.turn
		C.UnitActions.reconcile(reserve_state)
		var reserve_martial := option(reserve_state, 1, "lion-primarch", "martial-exemplar", reserve_squad, reserve_lion)
		var first_selection := PublicUnitCommand.submit(reserve_state, 1, reserve_martial)
		var reserve_mist := option(reserve_state, 1, "lion-primarch", "mist-wreathed-shadow-realms", reserve_squad, reserve_lion)
		var second_selection := PublicUnitCommand.submit(reserve_state, 1, reserve_mist)
		check(first_selection.get("error", "").is_empty() and second_selection.get("error", "").is_empty() and reserve_state.unit_abilities.reserves.has(reserve_squad) and not reserve_state.units[reserve_lion].get("on_battlefield", true), "Mist-wreathed Shadow Realms places unengaged Lion in Strategic Reserves after selecting two abilities")
		var pass_choice := option(reserve_state, 1, "pass")
		var pass_result := PublicUnitCommand.submit(reserve_state, 1, pass_choice)
		reserve_state.phase = "movement"
		C.UnitActions.reconcile(reserve_state)
		var ingress_choice := option(reserve_state, 1, "ingress", "", reserve_squad)
		var ingress_result := PublicUnitCommand.submit(reserve_state, 1, ingress_choice)
		check(pass_result.get("error", "").is_empty() and not ingress_choice.is_empty() and ingress_result.get("error", "").is_empty() and reserve_state.unit_abilities.window.get("kind", "") == "ingress" and reserve_state.cp[1] == reserve_state.cp.get(1, 0), "Lion’s Mist ingress opens in its first own Movement phase without spending CP")
	else:
		check(false, "The reserve test fixture materializes: %s" % str(reserve_state.get("error", "")))

	var reserve_cap_state := fixture()
	if not reserve_cap_state.has("error"):
		var cap_lion := models(reserve_cap_state, UNIT, 1)[0]
		var cap_squad := int(reserve_cap_state.units[cap_lion].squad)
		var other_squad := squad_for(reserve_cap_state, "intercessor-squad", 1)
		reserve_cap_state.phase = "command"
		reserve_cap_state.active = 1
		reserve_cap_state.turn = 1
		C.UnitAbilities.start_command(reserve_cap_state)
		reserve_cap_state.combat_doctrines.selected_turn[1] = reserve_cap_state.turn
		C.UnitActions.reconcile(reserve_cap_state)
		reserve_cap_state.unit_abilities.reserves[other_squad] = {"cost": 100, "source": "test-existing-reserve"}
		var unavailable_mist := option(reserve_cap_state, 1, "lion-primarch", "mist-wreathed-shadow-realms", cap_squad, cap_lion)
		check(unavailable_mist.is_empty() and not reserve_cap_state.unit_abilities.reserves.has(cap_squad), "Mist-wreathed is not offered when Lion would exceed the half-army Strategic Reserves limit")
	else:
		check(false, "The reserve-limit test fixture materializes: %s" % str(reserve_cap_state.get("error", "")))

	if failures == 0: print("Lion El’jonson checks: passed")
	else: print("Lion El’jonson checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

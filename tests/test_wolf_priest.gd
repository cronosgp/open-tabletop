extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const CommandBattleShock = preload("res://scripts/edition_11/command_battle_shock.gd")
const UNIT := "wolf-priest"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
	result[1].entries = [entry(UNIT), entry("intercessor-squad", 5)]
	result[2].entries = [entry("intercessor-squad", 5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units.get(model, {}).get("squad", -1))

func find_choice(state: Dictionary, player: int, action: String, model: int, squad: int) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad: return option
	return {}

func six() -> int: return 6

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000004129" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764", "Wolf Priest cites its Space Wolves App sheet and verified local slice")
	check(profile.get("points_by_models", {}) == {1: 75} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 3 and profile.get("base_size_source_mm", -1) == 40, "Fixed 75-point profile, copy cap and 40 mm base match the local export")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Wolf Priest characteristics include the baseline 4+ invulnerable save")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"], "All six source keywords are retained")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard.range_inches == 18 and profile.ranged[0].profiles.standard.skill == 3 and profile.ranged[0].profiles.standard.strength == 5 and profile.ranged[0].profiles.standard.ap == -2 and profile.ranged[0].profiles.standard.damage == 2, "Absolvor Bolt Pistol profile matches the export")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard.attacks == 5 and profile.melee[0].profiles.standard.skill == 2 and profile.melee[0].profiles.standard.strength == 6 and profile.melee[0].profiles.standard.ap == -1 and profile.melee[0].profiles.standard.damage == 2, "Crozius Arcanum profile matches the export")
	check(profile.get("options", {}).is_empty(), "Wolf Priest has no datasheet weapon replacements")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "healing-balms", "litany-of-hate"], "Leader, doctrines, Warlord eligibility and both datasheet abilities register")
	check(Registry.supported("healing-balms") and Registry.supported("litany-of-hate"), "Healing Balms and Litany of Hate are recorded as supported capabilities")
	check(LeaderLinks.targets(UNIT) == ["wolf-guard-headtakers", "assault-intercessor-squad", "grey-hunters", "blood-claws", "bladeguard-veteran-squad", "intercessor-squad"], "All six source-listed Leader endpoints remain in export order")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 2000, "entries": [entry(UNIT)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 75, "The current local catalog admits Wolf Priest at source cost")

	var state := fresh()
	check(not state.has("error"), "The local roster prepares from the consolidated catalog: %s" % state.get("error", ""))
	if state.has("error"):
		quit(1)
		return
	var priest := model_for(state, 1, UNIT)
	var squad := squad_for(state, 1, "intercessor-squad")
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(priest > 0 and squad > 0 and enemy_squad > 0 and C.UnitActions.attachment_allowed(state, priest, squad), "Wolf Priest can join a source-listed Intercessor unit")
	if priest < 0 or squad < 0 or enemy_squad < 0:
		quit(1)
		return
	C.UnitActions.attach(state, priest, squad)
	check(C.UnitAbilities.has(state, squad, "healing-balms") and C.UnitAbilities.has(state, squad, "litany-of-hate"), "Both datasheet abilities remain active in the attached unit")
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(0, 0) if int(state.units[model].owner) == 1 else Vector2(1.0, 0)
	var attack_state := fresh()
	var attack_priest := model_for(attack_state, 1, UNIT)
	var attack_squad := squad_for(attack_state, 1, UNIT)
	var attack_target := squad_for(attack_state, 2, "intercessor-squad")
	for model: int in attack_state.units:
		attack_state.units[model].on_battlefield = true
		attack_state.units[model].position = Vector2(0, 0) if int(attack_state.units[model].owner) == 1 else Vector2(1.0, 0)
	attack_state.phase = "fight"
	attack_state.active = 1
	var attacks := [{"model": attack_priest, "target": attack_target, "amount": 5, "weapon": "crozius-arcanum", "profile": "standard"}]
	var crozius: Dictionary = attack_state.units[attack_priest].melee_weapons[0].profiles.standard
	var lance_profile: Dictionary = C.UnitAbilities.weapon(attack_state, attack_priest, attack_target, crozius, true)
	check(bool(lance_profile.get("keywords", {}).get("lance", false)), "Litany grants Lance to the Priest's melee profile")
	attack_state.squads[attack_squad].charged = false
	var uncharged_plan := C.AttackPlan.prepare(attack_state, attack_squad, true, attacks, false)
	var uncharged_ok: bool = uncharged_plan.get("error", "").is_empty() and not uncharged_plan.get("batches", []).is_empty()
	for batch: Dictionary in uncharged_plan.get("batches", []):
		uncharged_ok = uncharged_ok and int(batch.context.get("wound_modifier", 0)) == 0
	check(uncharged_ok, "Litany has no uncharged wound bonus: " + str(uncharged_plan))
	attack_state.squads[attack_squad].charged = true
	var charged_plan := C.AttackPlan.prepare(attack_state, attack_squad, true, attacks, false)
	var charged_ok: bool = charged_plan.get("error", "").is_empty() and not charged_plan.get("batches", []).is_empty()
	for batch: Dictionary in charged_plan.get("batches", []):
		charged_ok = charged_ok and int(batch.context.get("wound_modifier", 0)) == 1
	check(charged_ok, "Litany adds +1 to Wound only after a Charge: " + str(charged_plan))

	state.phase = "command"
	state.active = 1
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Doctrines.select_doctrine(state, 1, "none")
	var morale_result: Dictionary = CommandBattleShock.resolve_command(state, six)
	check(str(morale_result.get("error", "")).is_empty(), "Command Battle-shock resolves before healing choices: " + str(morale_result))
	var wounded_bodyguard := -1
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad":
			wounded_bodyguard = model
			break
	check(wounded_bodyguard > 0, "Attached Intercessor bodyguard model is available for the healing test")
	if wounded_bodyguard < 0:
		quit(1)
		return
	state.units[wounded_bodyguard].wounds = int(state.units[wounded_bodyguard].max_wounds) - 1
	check(C.UnitActions.offer_command_healing(state), "Command phase opens the shared healing-order decision")
	var heal_choice: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "healing-balms" and int(option.get("model", -1)) == priest:
			heal_choice = option
			break
	check(not heal_choice.is_empty(), "Healing Balms appears for a wounded attached unit in its owner's Command phase")
	var started: Dictionary = PublicUnitCommand.submit(state, 1, heal_choice, Vector2.ZERO, six)
	check(str(started.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == "healing" and int(state.unit_abilities.window.get("total", 0)) == 4, "Healing Balms rolls D3+1 through the shared healing decision: " + str(started) + " / window " + str(state.unit_abilities.window))
	check(int(state.units[wounded_bodyguard].wounds) == int(state.units[wounded_bodyguard].max_wounds) - 1, "Healing Balms previews healing without mutating the model before confirmation")
	var confirm: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "heal-confirm":
			confirm = option
			break
	var confirmed: Dictionary = PublicUnitCommand.submit(state, 1, confirm, Vector2.ZERO, six)
	check(str(confirmed.get("error", "")).is_empty() and int(state.units[wounded_bodyguard].wounds) == int(state.units[wounded_bodyguard].max_wounds) and int(state.unit_abilities.last_healing.get("restored", 0)) == 1, "Healing Balms confirms living-model healing and accounts for discarded excess")
	var repeated_heal: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "healing-balms" and int(option.get("model", -1)) == priest:
			repeated_heal = option
			break
	check(repeated_heal.is_empty(), "Healing Balms cannot be used twice in one turn")
	state.phase = "shooting"
	check(C.UnitActions.healing_choices(state, 1).is_empty(), "Healing Balms is unavailable outside the Command phase")

	print("Wolf Priest checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

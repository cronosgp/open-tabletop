extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func selection(body: String = "intercessor-squad") -> Dictionary:
	var body_models := 3 if body == "bladeguard-veteran-squad" else 5
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [entry("judiciar"), entry(body, body_models)]}

func find_squad(s: Dictionary, owner: int, identity: String) -> int:
	for squad: int in s.squads:
		if int(s.squads[squad].owner) != owner: continue
		var members: Array[int] = Geometry.alive(s, squad)
		if not members.is_empty() and C.UnitAbilities.identity(s.units[members[0]]) == identity: return squad
	return -1

func find_model(s: Dictionary, owner: int, identity: String) -> int:
	for model: int in s.units:
		if int(s.units[model].owner) == owner and C.UnitAbilities.identity(s.units[model]) == identity: return model
	return -1

func fixture() -> Dictionary:
	var lists := F.current_marine_selections()
	lists[1] = selection()
	lists[2].entries = [entry("captain"), entry("assault-intercessor-squad", 5), entry("intercessor-squad", 5)]
	var s: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "manual_allocation": true}, lists)
	if s.has("error"): return s
	var reports := {}
	for player: int in [1, 2]:
		reports[player] = Roster.admit(lists[player])
		if not str(reports[player].get("error", "")).is_empty(): return {"error": str(reports[player].error)}
	Roster.enable(s, reports)
	s.mission.stage = "battle"
	s.active = 1
	s.unit_abilities.window = {}
	s.unit_abilities.setup_players = []
	var judiciar := find_model(s, 1, "judiciar")
	if judiciar < 0: return {"error": "Current-catalog Judiciar was not materialized."}
	s.unit_abilities["warlords"] = {1: judiciar}
	return s

func dice() -> int:
	return 4

func submit_attachment(s: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := C.UnitActions.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player:
		return {"error": "No matching attachment decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) \
			and int(option.get("model", -1)) == int(selected.get("model", -1)) \
			and int(option.get("target", -1)) == int(selected.get("target", -1)) \
			and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Judiciar attachment is not present in the current decision."}
	var choice := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")),
		"option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": choice, "revision": int(s.revision)})

func attack(s: Dictionary, target_squad: int, melee: bool) -> Dictionary:
	var weapon := {"name": "Conditional save probe", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": 1,
		"range_inches": 24, "keywords": {}}
	return C.AttackPlan.resolve(s, {"targets": [target_squad], "batches": [{"target": target_squad, "weapon": weapon,
		"context": {"weapon_count": 1}}]}, Callable(self, "dice"), melee)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("judiciar")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002707"
		and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Judiciar profile identifies the local shared-book Wahapedia datasheet")
	check(profile.points == 50 and profile.points_by_models == {1: 50} and profile.models == 1
		and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4)
		and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6,
		"objective_control": 1, "invulnerable_target": 0, "melee_invulnerable_target": 4},
		"Judiciar points, base, characteristics and conditional save match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]
		and profile.get("additional_weapon_profiles", {}).is_empty(), "Judiciar keywords and fixed loadout match the no-option source profile")
	check(profile.ranged.size() == 1 and profile.melee.size() == 1 and profile.ranged[0].id == "absolvor-bolt-pistol"
		and profile.melee[0].id == "executioner-relic-blade", "Judiciar has only its two source-listed fixed weapons")
	var blade: Dictionary = profile.melee[0].profiles.standard
	check(blade.attacks == 5 and blade.skill == 2 and blade.strength == 7 and blade.ap == -2 and blade.damage == 2
		and blade.keywords.get("precision", false) and blade.keywords.get("devastating-wounds", false), "Executioner Relic Blade profile is preserved")
	var identity := "40kdc:11e:adeptus-astartes:judiciar"
	var catalog_choice := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(Catalog.SPECS.get("judiciar", {}).get("current_reference", false)
		and catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0].get("models", 0) == 1
		and catalog_choice.options[0].get("cost", 0) == 50, "Consolidated catalog publishes Judiciar's fixed one-model cost")
	check(Catalog.resolve("Space Marines", identity).get("error", "").is_empty(), "Judiciar resolves from the consolidated current-reference catalog")

	var s := fixture()
	check(not s.has("error"), "Judiciar and both current Marine rosters materialize and pass bounded roster admission")
	if s.has("error"):
		print(s)
		quit(1)
		return
	var model := find_model(s, 1, "judiciar")
	var judiciar_squad: int = int(s.units[model].squad)
	var bodyguard_squad := find_squad(s, 1, "intercessor-squad")
	var enemy_squad := find_squad(s, 2, "assault-intercessor-squad")
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(s, profile, model, enemy_squad):
		check(false, "Judiciar source weapon plan: " + failure)
	check(Groups.profile(s, model).invulnerable_target == 0 and Groups.profile(s, model, true).invulnerable_target == 4,
		"Judiciar's conditional save applies only against melee attacks")
	check("EXPLOSIVES" not in s.units[model].keywords, "Judiciar does not gain the EXPLOSIVES keyword")
	var ranged := attack(s, judiciar_squad, false)
	var melee := attack(s, judiciar_squad, true)
	check(ranged.error.is_empty() and ranged.units[model].wounds == 3, "Ranged attack resolution does not use Judiciar's melee save")
	check(melee.error.is_empty() and melee.units[model].wounds == 4, "Melee attack resolution applies Judiciar's conditional save")
	var validation := s.duplicate(true)
	validation.units[model].defense = {"invulnerable_target": 2, "melee_invulnerable_target": 4}
	check(Groups.profile(validation, model, true).invulnerable_target == 2, "Conditional save preserves a better universal invulnerable save")
	validation.units[model].defense.melee_invulnerable_target = 1
	check(not Groups.profile(validation, model).error.is_empty(), "Invalid conditional invulnerable save fails validation")

	s.phase = "deployment"
	var attach: Dictionary = {}
	for row: Dictionary in C.UnitActions.choices(s, 1):
		if row.action == "attach" and row.model == model and row.target == bodyguard_squad: attach = row
	check(not attach.is_empty(), "Judiciar Support attachment to Intercessors is offered")
	check(not Roster.seal(s, 1).is_empty(), "Unattached Support fails the checked formation gate")
	if attach.is_empty():
		quit(1)
		return
	var before_wrong_attachment_owner := var_to_bytes(s)
	var wrong_attachment_owner := submit_attachment(s, 2, attach)
	check(not str(wrong_attachment_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_attachment_owner,
		"Opponent cannot submit or mutate Judiciar's attachment decision")
	var attachment_result := submit_attachment(s, 1, attach)
	check(str(attachment_result.get("error", "")).is_empty(), "Judiciar attachment resolves through the normalized public command")
	check(s.units[model].attachment_role == "support" and s.units[model].squad == bodyguard_squad,
		"Judiciar attaches as Support without consuming the Leader slot")
	check(Groups.profile(s, model).invulnerable_target == 0 and Groups.profile(s, model, true).invulnerable_target == 4
		and Groups.profile(s, Geometry.alive(s, bodyguard_squad)[0], true).invulnerable_target == 0,
		"Conditional save remains on Judiciar and is not shared with bodyguards")
	s.pending_attack = {"melee": true, "ability_saves": {}}
	var current := {"weapon": {"ap": -6}}
	var bodyguard_model := Geometry.alive(s, bodyguard_squad)[0]
	check(C.Allocation.saved(s, current, model, 4) and not C.Allocation.saved(s, current, bodyguard_model, 4)
		and not C.Allocation.saved(s, current, model, 1), "Manual melee save uses the selected model's conditional invulnerable save")
	s.pending_attack.melee = false
	check(not C.Allocation.saved(s, current, model, 4), "Manual ranged allocation does not use the melee-only save")
	s.pending_attack = {}

	s.phase = "fight"
	s.fight_step = "attacks"
	s.fight_selected = -1
	for squad: int in s.squads:
		s.squads[squad].fought = false
		s.squads[squad].charged = false
		s.squads[squad].was_engaged = true
	check(C.FightQueue.pool(s) == [bodyguard_squad] and C.FightQueue.first(s, bodyguard_squad),
		"Tempormortis grants Fights First priority to the attached bodyguards")
	check(C.FightQueue.choose_actor(s, 2) and s.fight_actor == bodyguard_squad,
		"Fights First leaves the eligible player's bodyguards as the selected actor")
	s.squads[enemy_squad].charged = true
	check(C.FightQueue.choose_actor(s, 2) and s.fight_actor == enemy_squad and bodyguard_squad in C.FightQueue.pool(s),
		"Opponent selection priority applies when both players have Fights First")
	s.squads[enemy_squad].charged = false
	var implementation: String = s.unit_abilities.implementation
	s.unit_abilities.implementation = "historical"
	check(not C.FightQueue.first(s, bodyguard_squad), "Tempormortis does not leak into historical ability profiles")
	s.unit_abilities.implementation = implementation
	s.units[model].on_battlefield = false
	check(not C.FightQueue.first(s, bodyguard_squad), "Off-board Judiciar does not retain Tempormortis")
	s.units[model].on_battlefield = true
	s.units[model].wounds = 0
	check(not C.FightQueue.first(s, bodyguard_squad) and C.FightQueue.pool(s).size() > 1,
		"Destroyed Judiciar no longer grants Tempormortis to attached bodyguards")
	s.squads[bodyguard_squad].charged = true
	check(C.FightQueue.first(s, bodyguard_squad), "Bodyguard charge priority remains after Judiciar is destroyed")
	s.squads[bodyguard_squad].charged = false
	s.squads[bodyguard_squad].fights_first = true
	check(C.FightQueue.first(s, bodyguard_squad), "Independent Fights First remains after the Judiciar source is lost")

	check(not Roster.admit(selection("hellblaster-squad")).error.is_empty(), "Judiciar rejects an ineligible Hellblaster bodyguard")
	var two_supports := selection()
	two_supports.entries.append(entry("kaius-konorius"))
	check(not Roster.admit(two_supports).error.is_empty(), "Two Support models are rejected by the construction slot limit")
	for body: String in ["intercessor-squad", "assault-intercessor-squad", "infernus-squad", "sternguard-veteran-squad", "bladeguard-veteran-squad"]:
		check(Roster.admit(selection(body)).error.is_empty(), "Legal Judiciar bodyguard rejected: " + body)
	print("Judiciar checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

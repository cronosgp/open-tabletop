extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")

const CHAPLAIN_ID := "40kdc:11e:adeptus-astartes:chaplain"
const BODYGUARDS := [
	"assault-intercessor-squad",
	"bladeguard-veteran-squad",
	"hellblaster-squad",
	"infernus-squad",
	"intercessor-squad",
	"sternguard-veteran-squad"
]

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists(bodyguard_identity: String = "intercessor-squad") -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("chaplain", 1), entry(bodyguard_identity, 3 if bodyguard_identity == "bladeguard-veteran-squad" else 5)]
	return result

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity and int(unit.get("wounds", 0)) > 0:
			return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func find_choice(state: Dictionary, action: String, model: int = -1, target: int = -1) -> Dictionary:
	for selected: Dictionary in C.unit_choices(state, 1):
		if str(selected.get("action", "")) != action:
			continue
		if model >= 0 and int(selected.get("model", -1)) != model:
			continue
		if target >= 0 and int(selected.get("target", -1)) != target:
			continue
		return selected
	return {}

func submit_choice(state: Dictionary, selected: Dictionary) -> Dictionary:
	if selected.is_empty():
		return {"error": "The requested Chaplain choice is not available."}
	var decision := PendingDecisions.current(state, ["mission-preparation", "unit-actions"])
	var payload: Dictionary = selected
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
				projected = option
				break
		if projected.is_empty():
			return {"error": "The Chaplain choice is absent from the current decision."}
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, int(C.UnitActions.actor(state)), {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload})

func place_target(state: Dictionary, target_squad: int, distance: float) -> void:
	var source := model_for(state, 1, "chaplain")
	for model: int in C.living(state, target_squad):
		state.units[model].position = state.units[source].position + Vector2(distance + state.units[source].radius + state.units[model].radius, 0.0)

func open_start_window(state: Dictionary) -> void:
	state.unit_abilities.erase("phase_key")
	state.unit_abilities.window = {}
	C.UnitActions.reconcile(state)

func weapon_batch(plan: Dictionary, weapon_name: String) -> Dictionary:
	for batch: Dictionary in plan.get("batches", []):
		if weapon_name in batch.get("labels", []):
			return batch
	return {}

func fixture(bodyguard_identity: String = "intercessor-squad") -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists(bodyguard_identity))
	if state.has("error"):
		return state
	state.awakened_dynasty.pending = []
	state.mission.stage = "battle"
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20.0, float(model % 7) * 2.0) if state.units[model].owner == 1 else Vector2(20.0, float(model % 7) * 2.0)
	var chaplain := model_for(state, 1, "chaplain")
	state.units[chaplain].position = Vector2.ZERO
	return state

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile: Dictionary = Profiles.profile("chaplain")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001174" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Chaplain maps to the shared-book source identity and retains its runtime export stamp")
	check(profile.get("models") == 1 and profile.get("points_by_models", {}) == {1: 60} and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "Chaplain composition, 60-point cost and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "Chaplain characteristics match the local export")
	check(profile.get("keywords", []) == ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"], "Chaplain keywords match the local export")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].id == "absolvor-bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "crozius-arcanum" and profile.get("additional_weapon_profiles", {}).is_empty(), "The fixed loadout has its two source weapons and no equipment options")
	if profile.get("ranged", []).size() == 1:
		check(profile.ranged[0].profiles.standard == {"name": "Absolvor Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"close-quarters": true}}, "Absolvor Bolt Pistol matches every exported characteristic")
	if profile.get("melee", []).size() == 1:
		check(profile.melee[0].profiles.standard == {"name": "Crozius Arcanum", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -1, "damage": 2, "keywords": {"cleave": 1}}, "Crozius Arcanum matches every exported characteristic")
	var catalog_choice := Catalog.current_catalog_choice({"id": CHAPLAIN_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("id", "") == CHAPLAIN_ID and catalog_choice.get("options", []) == [{"models": 1, "cost": 60}], "Current construction exposes one fixed 60-point Chaplain")
	var chaplain_rules: Array = C.UnitAbilities.RULES.get("chaplain", [])
	check(chaplain_rules.has("litany-of-hate") and chaplain_rules.has("spiritual-leader"), "Runtime registers both Chaplain datasheet abilities")

	var roster := C.RosterValidation.admit(lists()[1])
	check(str(roster.get("error", "")).is_empty() and int(roster.get("total", 1001)) <= 1000, "Current-catalog roster admission accepts the Chaplain with a legal bodyguard")
	var state := fixture()
	check(not state.has("error"), "Chaplain and bodyguards materialize from the current catalog for both players")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var chaplain := model_for(state, 1, "chaplain")
	var expected_targets: Array = BODYGUARDS.duplicate()
	expected_targets.sort()
	var actual_targets: Array = LeaderLinks.TARGETS.get("chaplain", []).duplicate()
	actual_targets.sort()
	check(actual_targets == expected_targets, "Chaplain Leader map matches all six shared-book bodyguards")
	for identity: String in BODYGUARDS:
		var link_state := fixture(identity)
		var link_chaplain := model_for(link_state, 1, "chaplain")
		var bodyguard := squad_for(link_state, 1, identity)
		check(not link_state.has("error") and bodyguard >= 0 and C.UnitActions.attachment_allowed(link_state, link_chaplain, bodyguard), "Chaplain attaches to current-catalog %s" % identity)
	var attach_choices := 0
	for identity: String in BODYGUARDS:
		var link_state := fixture(identity)
		var link_chaplain := model_for(link_state, 1, "chaplain")
		var link_bodyguard := squad_for(link_state, 1, identity)
		if not find_choice(link_state, "attach", link_chaplain, link_bodyguard).is_empty():
			attach_choices += 1
	check(attach_choices == BODYGUARDS.size(), "Preparation projects each of the six Chaplain Leader targets")
	var intercessor_squad := squad_for(state, 1, "intercessor-squad")
	var warlord_result := submit_choice(state, find_choice(state, "warlord", chaplain))
	check(str(warlord_result.get("error", "")).is_empty(), "Chaplain can be selected as Warlord through the public command: " + str(warlord_result.get("error", "")))
	var attachment_result := submit_choice(state, find_choice(state, "attach", chaplain, intercessor_squad))
	check(str(attachment_result.get("error", "")).is_empty(), "Chaplain attachment uses the projected public preparation command: " + str(attachment_result.get("error", "")))
	check(int(state.units[chaplain].squad) == intercessor_squad and str(state.units[chaplain].get("attachment_role", "")) == "leader", "Chaplain and Intercessors materialize as one attached unit")

	var bodyguard_model := C.living(state, intercessor_squad)[0]
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	var enemy_model := C.living(state, enemy_squad)[0]
	var pistol := Equipment.select(state, chaplain, false, "absolvor-bolt-pistol", "standard")
	var crozius := Equipment.select(state, chaplain, true, "crozius-arcanum", "standard")
	check(str(pistol.get("error", "")).is_empty() and pistol.get("stats", {}) == profile.ranged[0].profiles.standard, "Fixed Absolvor Bolt Pistol enters Equipment with the exported profile")
	check(str(crozius.get("error", "")).is_empty() and crozius.get("stats", {}) == profile.melee[0].profiles.standard, "Fixed Crozius Arcanum enters Equipment with the exported profile")
	var pistol_state := fixture()
	var pistol_model := model_for(pistol_state, 1, "chaplain")
	var pistol_squad := squad_for(pistol_state, 1, "chaplain")
	var pistol_target := squad_for(pistol_state, 2, "intercessor-squad")
	pistol_state.phase = "shooting"
	pistol_state.active = 1
	pistol_state.deployment.complete = true
	for model: int in C.living(pistol_state, pistol_target):
		pistol_state.units[model].position = Vector2(10.0, float(model % 3))
	var pistol_plan := C.AttackPlan.prepare(pistol_state, pistol_squad, false, [{"model": pistol_model, "target": pistol_target, "amount": 1, "weapon": "absolvor-bolt-pistol", "profile": "standard"}], true)
	check(pistol_plan.get("error", "").is_empty() and not weapon_batch(pistol_plan, "Absolvor Bolt Pistol").is_empty(), "Absolvor Bolt Pistol reaches the current-catalog ranged AttackPlan: " + str(pistol_plan.get("error", "")))
	var bodyguard_melee: Dictionary = Profiles.profile("intercessor-squad").melee[0].profiles.standard
	var bodyguard_ranged: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	check(C.UnitAbilities.weapon(state, bodyguard_model, enemy_model, bodyguard_melee, true).keywords.get("lance", false), "Living Chaplain grants Litany of Hate to attached melee attacks")
	check(not C.UnitAbilities.weapon(state, bodyguard_model, enemy_model, bodyguard_ranged, false).keywords.get("lance", false), "Litany of Hate does not affect ranged attacks")
	check(not bodyguard_melee.keywords.has("lance"), "Applying Litany does not mutate the source weapon profile")

	state.phase = "fight"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.deployment.complete = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	for model: int in C.living(state, intercessor_squad):
		state.units[model].position = Vector2(state.units[chaplain].radius + state.units[model].radius + 1.5, 0.0)
	state.units[enemy_model].position = Vector2(1.5, 0.0)
	var uncharged_entries := C.AttackPlan.single_target(state, intercessor_squad, enemy_squad, true)
	var uncharged := C.AttackPlan.prepare(state, intercessor_squad, true, uncharged_entries, true)
	var uncharged_crozius := weapon_batch(uncharged, "Crozius Arcanum")
	check(uncharged.get("error", "").is_empty() and not uncharged_crozius.is_empty() and int(uncharged_crozius.context.get("wound_modifier", 0)) == 0, "Litany grants Lance but no wound bonus before a Charge: " + str(uncharged.get("error", "")))
	state.squads[intercessor_squad].charged = true
	var charged_entries := C.AttackPlan.single_target(state, intercessor_squad, enemy_squad, true)
	var charged := C.AttackPlan.prepare(state, intercessor_squad, true, charged_entries, true)
	var charged_crozius := weapon_batch(charged, "Crozius Arcanum")
	check(charged.get("error", "").is_empty() and not charged_crozius.is_empty() and int(charged_crozius.context.get("wound_modifier", 0)) == 1, "Lance grants +1 to Wound after the attached unit charges: " + str(charged.get("error", "")))
	state.units[chaplain].wounds = 0
	check(not C.UnitAbilities.weapon(state, bodyguard_model, enemy_model, bodyguard_melee, true).keywords.get("lance", false), "Destroying the Chaplain removes Litany from future attacks")

	# Spiritual Leader is exercised on the Chaplain while alive, attached, and within the exact range boundary.
	state = fixture()
	chaplain = model_for(state, 1, "chaplain")
	intercessor_squad = squad_for(state, 1, "intercessor-squad")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var spiritual_attachment := submit_choice(state, find_choice(state, "attach", chaplain, intercessor_squad))
	check(str(spiritual_attachment.get("error", "")).is_empty(), "Preparation attaches the Chaplain before phase ability checks: " + str(spiritual_attachment.get("error", "")))
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.round = 1
	state.phase = "command"
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.squads[intercessor_squad].battle_shocked = true
	open_start_window(state)
	var doctrine_error: String = C.select_combat_doctrine(state, 1, "none", int(state.revision))
	check(doctrine_error.is_empty(), "Resolve Command Doctrine before checking Spiritual Leader: " + doctrine_error)
	var spiritual := find_choice(state, "spiritual-leader", chaplain, intercessor_squad)
	check(not spiritual.is_empty(), "Spiritual Leader can target its own attached unit at the phase start")
	var unchanged := var_to_bytes(state)
	var wrong_owner := MatchCommands.execute(state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": spiritual})
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == unchanged, "Wrong player cannot use Spiritual Leader")
	var stale := MatchCommands.execute(state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision) - 1, "choice": spiritual})
	check(not str(stale.get("error", "")).is_empty() and var_to_bytes(state) == unchanged, "Stale Spiritual Leader choice does not mutate state")
	var spiritual_result := submit_choice(state, spiritual)
	check(str(spiritual_result.get("error", "")).is_empty() and not state.squads[intercessor_squad].battle_shocked and int(state.cp[1]) == 0, "Spiritual Leader removes Battle-shock without spending CP: " + str(spiritual_result.get("error", "")))
	state.squads[intercessor_squad].battle_shocked = true
	state.phase = "movement"
	open_start_window(state)
	check(find_choice(state, "spiritual-leader", chaplain, intercessor_squad).is_empty(), "Spiritual Leader cannot be used twice by this Chaplain in one battle round")
	state.turn += 1
	state.active = 2
	state.phase = "fight"
	open_start_window(state)
	check(find_choice(state, "spiritual-leader", chaplain, intercessor_squad).is_empty(), "The opposing player's turn does not reset the Chaplain's per-round use")
	state.round += 1
	state.active = 1
	state.phase = "shooting"
	open_start_window(state)
	check(not find_choice(state, "spiritual-leader", chaplain, intercessor_squad).is_empty(), "Spiritual Leader refreshes in the next battle round")

	for phase: String in ["command", "movement", "shooting", "charge", "fight"]:
		var phase_state := fixture("bladeguard-veteran-squad")
		var phase_chaplain := model_for(phase_state, 1, "chaplain")
		var phase_target := squad_for(phase_state, 1, "bladeguard-veteran-squad")
		phase_state.units[phase_chaplain].position = Vector2.ZERO
		place_target(phase_state, phase_target, 6.0)
		phase_state.squads[phase_target].battle_shocked = true
		phase_state.phase = phase
		phase_state.active = 2 if phase == "fight" else 1
		phase_state.unit_abilities.setup_players = [1, 2]
		phase_state.unit_abilities.battle_players = [1, 2]
		phase_state.deployment.complete = true
		phase_state.unit_abilities.phase_key = C.UnitActions.key(phase_state)
		open_start_window(phase_state)
		if phase == "command":
			var phase_doctrine_error: String = C.select_combat_doctrine(phase_state, 1, "none", int(phase_state.revision))
			check(phase_doctrine_error.is_empty(), "Resolve Command Doctrine in current phase fixture: " + phase_doctrine_error)
		check(not find_choice(phase_state, "spiritual-leader", phase_chaplain, phase_target).is_empty(), "Spiritual Leader is available at the start of the %s phase" % phase)

	var range_state := fixture("bladeguard-veteran-squad")
	var range_chaplain := model_for(range_state, 1, "chaplain")
	var range_target := squad_for(range_state, 1, "bladeguard-veteran-squad")
	range_state.phase = "movement"
	range_state.unit_abilities.setup_players = [1, 2]
	range_state.unit_abilities.battle_players = [1, 2]
	range_state.deployment.complete = true
	range_state.unit_abilities.phase_key = C.UnitActions.key(range_state)
	place_target(range_state, range_target, 6.0)
	range_state.squads[range_target].battle_shocked = true
	open_start_window(range_state)
	check(not find_choice(range_state, "spiritual-leader", range_chaplain, range_target).is_empty(), "The exact six-inch base-edge range is eligible")
	place_target(range_state, range_target, 6.02)
	open_start_window(range_state)
	check(find_choice(range_state, "spiritual-leader", range_chaplain, range_target).is_empty(), "Targets beyond six inches are excluded")

	var sight_state := fixture("bladeguard-veteran-squad")
	var sight_chaplain := model_for(sight_state, 1, "chaplain")
	var sight_target := squad_for(sight_state, 1, "bladeguard-veteran-squad")
	sight_state.phase = "movement"
	sight_state.unit_abilities.setup_players = [1, 2]
	sight_state.unit_abilities.battle_players = [1, 2]
	sight_state.deployment.complete = true
	sight_state.unit_abilities.phase_key = C.UnitActions.key(sight_state)
	sight_state.units[sight_chaplain].position = Vector2(0, -8)
	place_target(sight_state, sight_target, 6.0)
	sight_state.squads[sight_target].battle_shocked = true
	sight_state.squads[squad_for(sight_state, 1, "chaplain")].battle_shocked = true
	sight_state.terrain.areas = [{"name": "Opaque screen", "category": "dense", "bounds": Rect2(2, -10, 1, 4), "features": [{"bounds": Rect2(2, -10, 1, 4), "height": 4.0, "blocks_end": true}]}]
	open_start_window(sight_state)
	check(not C.Terrain.targeting(sight_state, sight_chaplain, sight_target).visible and not find_choice(sight_state, "spiritual-leader", sight_chaplain, sight_target).is_empty(), "Spiritual Leader does not require visibility")
	check(not find_choice(sight_state, "spiritual-leader", sight_chaplain, squad_for(sight_state, 1, "chaplain")).is_empty(), "A battle-shocked Chaplain can still use Spiritual Leader")

	var unavailable := fixture()
	var unavailable_chaplain := model_for(unavailable, 1, "chaplain")
	unavailable.phase = "movement"
	unavailable.unit_abilities.setup_players = [1, 2]
	unavailable.unit_abilities.battle_players = [1, 2]
	unavailable.deployment.complete = true
	unavailable.unit_abilities.phase_key = C.UnitActions.key(unavailable)
	open_start_window(unavailable)
	unavailable.units[unavailable_chaplain].wounds = 0
	check(find_choice(unavailable, "spiritual-leader").is_empty(), "A destroyed Chaplain offers no Spiritual Leader choice")
	unavailable.units[unavailable_chaplain].wounds = 4
	unavailable.units[unavailable_chaplain].on_battlefield = false
	check(find_choice(unavailable, "spiritual-leader").is_empty(), "An off-board Chaplain offers no Spiritual Leader choice")

	print("Chaplain current-catalog checks: %d failures" % failures)
	quit(1 if failures else 0)

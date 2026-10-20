extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int: return 6
func four() -> int: return 4
func one() -> int: return 1
func queued_die() -> int: return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-terminator-armour", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:terminator-squad", "models": 5, "copies": 1}]
	return result

func make_state() -> Dictionary:
	var result := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if not result.has("error"):
		result.mission.stage = "battle"
		result.awakened_dynasty.pending = []
	return result

func find_squads(state: Dictionary) -> Array[int]:
	var librarian := -1
	var terminators := -1
	var enemy := -1
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var identity := C.UnitAbilities.identity(unit)
		if identity == "librarian-in-terminator-armour": librarian = model
		if identity == "terminator-squad" and unit.owner == 1: terminators = unit.squad
		if unit.owner == 2: enemy = unit.squad
	return [librarian, terminators, enemy]

func _initialize() -> void:
	var profile := Profiles.profile("librarian-in-terminator-armour")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000079" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Librarian preserves its local Wahapedia source identity")
	check(profile.points_by_models == {1: 80} and profile.stats.movement_inches == 5 and profile.stats.toughness == 6 and profile.stats.save_target == 2 and profile.stats.wounds == 5 and profile.stats.leadership_target == 6 and profile.stats.objective_control == 1 and profile.stats.invulnerable_target == 4, "Librarian characteristics and points match the local extraction")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.focused.attacks == "D3+3" and profile.ranged[0].profiles.focused.keywords == {"devastating-wounds": true, "psychic": true, "hazardous": true} and profile.melee[0].profiles.standard.keywords.psychic, "Smite modes and Psychic weapon traits are transcribed")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:librarian-in-terminator-armour", "models": 1, "copies": 1}]})
	check(admitted.error.is_empty() and admitted.total == 80, "Librarian is admitted at its local 80-point cost")
	var state := make_state()
	check(not state.has("error"), "Librarian and Terminator Squad materialize from current local profiles")
	if state.has("error"):
		print("Terminator Librarian checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find_squads(state)
	var librarian: int = found[0]
	var terminators: int = found[1]
	var enemy: int = found[2]
	check(librarian >= 0 and terminators >= 0 and enemy >= 0, "Expected Librarian, Terminators and enemy units exist")
	if librarian < 0 or terminators < 0 or enemy < 0:
		print("Terminator Librarian checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(state, librarian, terminators), "Librarian can lead the admitted Terminator Squad")
	C.UnitActions.attach(state, librarian, terminators)
	check(C.UnitAbilities.has(state, terminators, "librarius") and C.UnitAbilities.every_model_has(state, terminators, "deep-strike"), "Attached unit receives Librarius and Deep Strike eligibility")
	check("DEATHWING" not in state.units[librarian].keywords, "Unscoped chapter-conditional Deathwing keyword stays out")
	var rules: Array = Prevention.rules(state, librarian)
	check(rules == [{"target": 4, "against": "psychic"}] and Prevention.rules(state, C.living(state, terminators)[0]) == rules, "Psychic Hood grants its unit-wide 4+ Feel No Pain")
	var saved := C.Attacks.Prevention.resolve(1, 3, rules, "normal", four, "psychic")
	check(saved.error.is_empty() and saved.prevented == 1 and saved.lost == 0, "Psychic Hood prevents normal Psychic attack damage")
	saved = C.Attacks.Prevention.resolve(1, 3, rules, "mortal", four, "psychic")
	check(saved.error.is_empty() and saved.prevented == 1 and saved.lost == 0, "Psychic Hood also prevents mortal damage caused by a Psychic attack")
	saved = C.Attacks.Prevention.resolve(1, 3, rules, "normal", four)
	check(saved.error.is_empty() and saved.lost == 1 and saved.rolls.is_empty(), "Psychic Hood does not protect against non-Psychic damage")
	var psychic_probe := {"name": "Psychic probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 1, "range_inches": 24, "keywords": {"psychic": true}}
	dice_queue = [6, 6, 1, 4]
	var psychic_hit := C.AttackPlan.resolve(state, {"targets": [terminators], "batches": [{"target": terminators, "weapon": psychic_probe, "context": {"weapon_count": 1}}]}, queued_die, false)
	var bodyguard: int = C.living(state, terminators)[0]
	check(psychic_hit.error.is_empty() and psychic_hit.units[bodyguard].wounds == state.units[bodyguard].max_wounds and psychic_hit.damage == 0, "Automatic allocation applies Psychic Hood against an unsaved Psychic attack")
	state.phase = "fight"
	state.active = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.unit_abilities.setup_players = [1, 2]
	var might: Dictionary = {}
	for option: Dictionary in C.unit_choices(state, 1):
		if option.action == "librarius-power" and option.value == "might-of-heroes": might = option
	check(not might.is_empty(), "Might of Heroes is available in the Fight phase")
	if not might.is_empty(): check(C.unit_action(state, 1, might, Vector2.ZERO, state.revision, six).is_empty(), "Might of Heroes resolves its psychic roll")
	var fist: Dictionary = Profiles.profile("terminator-squad").melee[0].profiles.standard.duplicate(true)
	check(C.UnitAbilities.weapon(state, C.living(state, terminators)[0], enemy, fist, true).strength == 10, "Might of Heroes adds +2 Strength to attached melee weapons")
	check(C.UnitActions.librarius_choices(state, 1).is_empty(), "Librarius level 1 prevents using the second level-1 power in the same battle round")
	var shocked := make_state()
	found = find_squads(shocked)
	shocked.phase = "deployment"
	shocked.unit_abilities.setup_players = []
	C.UnitActions.attach(shocked, found[0], found[1])
	shocked.phase = "fight"
	shocked.active = 1
	shocked.fight_actor = 1
	shocked.fight_step = "attacks"
	shocked.unit_abilities.setup_players = [1, 2]
	var shock_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(shocked, 1):
		if option.action == "librarius-power" and option.value == "might-of-heroes": shock_choice = option
	if not shock_choice.is_empty(): check(C.unit_action(shocked, 1, shock_choice, Vector2.ZERO, shocked.revision, one).is_empty() and shocked.squads[found[1]].battle_shocked, "A psychic roll of 1 Battle-shocks the Librarian's unit")
	var shooting := make_state()
	found = find_squads(shooting)
	shooting.phase = "deployment"
	shooting.unit_abilities.setup_players = []
	C.UnitActions.attach(shooting, found[0], found[1])
	shooting.phase = "shooting"
	shooting.active = 1
	shooting.unit_abilities.setup_players = [1, 2]
	shooting.awakened_dynasty.pending = []
	shooting.terrain.areas = []
	for model: int in shooting.units:
		shooting.units[model].position = Vector2(-20, 0) if shooting.units[model].owner == 1 else Vector2(9, 0)
	var thunder: Dictionary = {}
	for option: Dictionary in C.unit_choices(shooting, 1):
		if option.action == "librarius-power" and option.value == "thunderous-force": thunder = option
	if not thunder.is_empty(): check(C.unit_action(shooting, 1, thunder, Vector2.ZERO, shooting.revision, six).is_empty(), "Thunderous Force resolves its psychic roll")
	var storm_bolter: Dictionary = Profiles.profile("terminator-squad").ranged[0].profiles.standard.duplicate(true)
	check(C.UnitAbilities.weapon(shooting, C.living(shooting, found[1])[0], found[2], storm_bolter, false).range_inches == 30.0, "Thunderous Force adds 6 inches to ranged weapon range")
	check(found[2] in C.AttackPlan.legal_targets(shooting, C.living(shooting, found[1])[0], false), "Thunderous Force permits the attached Terminators to target beyond the base 24-inch range")
	print("Terminator Librarian checks: %d failures" % failures)
	quit(1 if failures else 0)

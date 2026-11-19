extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")

const VAULT_ID := "40kdc:11e:necrons:tesseract-vault"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	test_datasheet_facts_and_admission()
	test_powers_of_the_ctan_and_damaged()
	print("Necron Tesseract Vault checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var tv := Profiles.profile("tesseract-vault")
	check(tv.get("source_datasheet_id") == "000000556", "Tesseract Vault ID matches 000000556")
	check(tv.get("points_by_models") == {1: 465}, "1st copy points are 465")
	check(tv.get("second_plus_points_by_models") == {1: 505}, "2nd+ copy points are 505")
	check(tv.get("base_size_source_mm") == 92, "Base size is 92 mm (120x92mm flying base)")
	check(tv.get("stats") == {"movement_inches": 8, "toughness": 12, "save_target": 2, "wounds": 24, "leadership_target": 7, "objective_control": 8, "invulnerable_target": 4}, "Stats match source")
	for kw: String in ["NECRONS", "VEHICLE", "TITANIC", "FLY", "TESSERACT VAULT", "FRAME", "TOWERING"]:
		check(kw in tv.get("keywords", []), "Has %s keyword" % kw)
	check(tv.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(tv.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", VAULT_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 465 and int(res.get("models", -1)) == 1, "Resolves to 1 model for 465")
	var roster2 := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": VAULT_ID, "models": 1, "copies": 2}]})
	check(roster2.get("error", "").is_empty() and int(roster2.get("total", -1)) == 970, "2 copies cost 465 + 505 = 970 (got %s)" % str(roster2.get("total", -1)))
	check(Reanimation.PROFILE_MODEL_COUNTS.get(VAULT_ID) == [1], "Reanimation profile model count is [1]")

func test_powers_of_the_ctan_and_damaged() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": VAULT_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var tv_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == VAULT_ID: tv_model = m
	check(tv_model >= 0, "Tesseract Vault spawned")
	check(Morale.objective_control(state, tv_model) == 8, "Full-health OC is 8")
	check(UnitAbilities.damaged_attack_penalty(state, tv_model) == 0, "No damaged hit penalty at full wounds")

	state.phase = "shooting"
	state.turn = 1
	state.active = 1
	state.unit_abilities.window = {"kind": "start", "owners": [1]}
	var c1 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "tesseract-vault-ctan-power")
	check(c1.size() == 3, "Undamaged Tesseract Vault is offered all 3 C'tan Powers")
	UnitActions.apply(state, 1, c1[0], Vector2.ZERO, Callable())
	var c2 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "tesseract-vault-ctan-power")
	check(c2.size() == 2, "2 remaining C'tan Powers offered after selecting 1st")
	UnitActions.apply(state, 1, c2[0], Vector2.ZERO, Callable())
	var c3 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "tesseract-vault-ctan-power")
	check(c3.is_empty(), "No more C'tan Powers offered after selecting 2")
	check(state.units[tv_model].ranged_weapons.size() == 3, "Tesseract Vault equips Tesla spheres + 2 C'tan Powers")

	# Damaged: 1-8 wounds remaining -> OC drops by 4 (to 4), no -1 to Hit, only 1 C'tan Power on turn 2
	state.units[tv_model].wounds = 8
	check(Morale.objective_control(state, tv_model) == 4, "Damaged (1-8W) OC drops by 4 to 4")
	check(UnitAbilities.damaged_attack_penalty(state, tv_model) == 0, "Damaged Tesseract Vault has no -1 to Hit penalty")
	state.turn = 2
	var c_dmg1 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "tesseract-vault-ctan-power")
	check(c_dmg1.size() == 3, "Turn 2 damaged offers 3 C'tan Powers initially")
	UnitActions.apply(state, 1, c_dmg1[0], Vector2.ZERO, Callable())
	var c_dmg2 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "tesseract-vault-ctan-power")
	check(c_dmg2.is_empty(), "Damaged Tesseract Vault capped at 1 C'tan Power")

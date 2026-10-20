extends SceneTree
const F = preload("res://tests/fixtures/weapon_selection_fixture.gd")
const C = F.C
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func setup_enhancement(state: Dictionary, model: int, identity: String, enhancement_id: String) -> void:
	state.combat_doctrines = {"detachment": Enhancements.ASSAULT_BRETHREN}
	state.squads[1].enhancement_id = enhancement_id
	state.units[model].definition_id = identity
	state.units[model].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
	state.units[model].enhancement_id = enhancement_id

func attacks_for(target: int) -> Array:
	var chain_attacks := int(F.instance(F.state(), "chain").profiles.standard.attacks)
	return [F.row("chain", "standard", chain_attacks, target), F.row("servo", "standard", 1, target), F.row("servo-two", "standard", 1, target)]

func roster(source: String, models: int, enhancement_id: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": models, "copies": 1, "enhancement_id": enhancement_id}]}

func _initialize() -> void:
	var captain := "40kdc:11e:adeptus-astartes:captain"
	var terminators := "40kdc:11e:adeptus-astartes:terminator-assault-squad"
	check(Enhancements.valid_for(captain, Enhancements.IMPERIUMS_SWORD, Enhancements.ASSAULT_BRETHREN), "Imperium's Sword accepts a model on an eligible exported datasheet")
	check(not Enhancements.valid_for(terminators, Enhancements.IMPERIUMS_SWORD, Enhancements.ASSAULT_BRETHREN), "Imperium's Sword rejects an ineligible exported datasheet")
	check(Enhancements.valid_for(terminators, Enhancements.FURIOUS_ASSAULT, Enhancements.ASSAULT_BRETHREN), "Furious Assault accepts an eligible Infantry datasheet")
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:stormraven-gunship", Enhancements.FURIOUS_ASSAULT, Enhancements.ASSAULT_BRETHREN), "Furious Assault rejects non-Infantry datasheets")
	check(int(Enhancements.RECORDS[Enhancements.IMPERIUMS_SWORD].cost) == 20 and int(Enhancements.RECORDS[Enhancements.FURIOUS_ASSAULT].cost) == 10, "Enhancement points match the local Wahapedia export")
	var catalog: Dictionary = {}
	for record: Dictionary in Enhancements.catalog_records([captain, terminators]): catalog[record.id] = record
	check(catalog.has(Enhancements.IMPERIUMS_SWORD) and catalog.has(Enhancements.FURIOUS_ASSAULT), "Both eligible enhancements are emitted to the consolidated local catalog")
	var admitted_sword: Dictionary = Army.admit(roster("captain", 1, Enhancements.IMPERIUMS_SWORD))
	var admitted_furious: Dictionary = Army.admit(roster("terminator-assault-squad", 5, Enhancements.FURIOUS_ASSAULT))
	check(admitted_sword.get("error", "").is_empty() and admitted_sword.total == 110, "Army admission applies Imperium's Sword's 20-point cost to an eligible bearer")
	check(admitted_furious.get("error", "").is_empty() and admitted_furious.total == 180, "Army admission applies Furious Assault's 10-point cost to an eligible unit")
	var match_state: Dictionary = Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachment": Enhancements.ASSAULT_BRETHREN}, {
		1: roster("terminator-assault-squad", 5, Enhancements.FURIOUS_ASSAULT), 2: roster("captain", 1, "")})
	check(not match_state.has("error") and match_state.get("combat_doctrines", {}).get("detachment", "") == Enhancements.ASSAULT_BRETHREN and match_state.get("squads", {}).get(1, {}).get("enhancement_id", "") == Enhancements.FURIOUS_ASSAULT, "The eligible enhancement survives roster admission and prepared-match materialization")

	var state := F.state()
	setup_enhancement(state, 100, captain, Enhancements.IMPERIUMS_SWORD)
	var sword := {}
	for option: Dictionary in C.AttackPlan.Equipment.choices(state, 100, true):
		if option.weapon == "imperiums-sword": sword = option.stats
	check(not sword.is_empty() and sword.attacks == 6 and sword.skill == 2 and sword.strength == 7 and sword.ap == -3 and sword.damage == 3, "The assigned bearer receives the exact Imperium's Sword profile")
	state.units[100].enhancement_id = ""
	var absent := true
	for option: Dictionary in C.AttackPlan.Equipment.choices(state, 100, true):
		if option.weapon == "imperiums-sword": absent = false
	check(absent, "Imperium's Sword is absent when its bearer assignment is removed")

	state = F.state()
	setup_enhancement(state, 100, terminators, Enhancements.FURIOUS_ASSAULT)
	var rows := attacks_for(2)
	var prepared: Dictionary = C.AttackPlan.prepare(state, 1, true, rows, true)
	var sustained := true
	if prepared.get("error", "").is_empty():
		for batch: Dictionary in prepared.batches:
			if int(batch.weapon.keywords.get("sustained-hits", 0)) != 1: sustained = false
	check(prepared.get("error", "").is_empty() and sustained, "Furious Assault grants Sustained Hits 1 to melee weapons against Infantry")
	var surviving_member: Dictionary = state.units[100].duplicate(true)
	surviving_member.enhancement_id = ""
	state.units[101] = surviving_member
	state.units[101].wounds = 1
	state.units[100].wounds = 0
	check(Enhancements.furious_assault_active(state, 1), "Furious Assault remains active while the enhanced unit has another living model")

	for excluded_keyword: String in ["Monster", "Vehicle"]:
		state = F.state()
		setup_enhancement(state, 100, terminators, Enhancements.FURIOUS_ASSAULT)
		state.units[400].keywords = [excluded_keyword]
		rows = attacks_for(4)
		prepared = C.AttackPlan.prepare(state, 1, true, rows, true)
		var excluded := true
		if prepared.get("error", "").is_empty():
			for batch: Dictionary in prepared.batches:
				if int(batch.weapon.keywords.get("sustained-hits", 0)) != 0: excluded = false
		check(prepared.get("error", "").is_empty() and excluded, "Furious Assault excludes %s targets" % excluded_keyword)
	print("Assault Brethren enhancement checks: %d failures" % failures)
	quit(1 if failures else 0)

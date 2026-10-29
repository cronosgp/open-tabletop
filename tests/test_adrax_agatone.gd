extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const A = F.C.UnitAbilities
const U = F.C.UnitActions
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_unit(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and A.identity(state.units[model]) == identity: return model
	return -1

func run() -> void:
	var profile := Profiles.profile("adrax-agatone")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002100" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Adrax cites the pinned local Wahapedia 11e extraction")
	check(profile.points_by_models == {1: 90} and profile.max_supported_copies == 1 and profile.base_radius_inches == 20.0 / 25.4 and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Adrax's characteristics, 40 mm base and 90 point cost match the export")
	check(profile.keywords == ["INFANTRY", "CAPTAIN", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "SALAMANDERS", "ADEPTUS ASTARTES"] and profile.ranged[0].profiles.standard.keywords == {"torrent": true, "close-quarters": true} and profile.ranged[0].profiles.standard.attacks == "D6+3", "Adrax's exported keyword set and Drakkis match")
	check(profile.melee[0].profiles.standard.attacks == 5 and profile.melee[0].profiles.standard.strength == 10 and profile.melee[0].profiles.standard.keywords.get("devastating-wounds", false), "Malleus Noctum's source profile matches")
	var catalog := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:adrax-agatone", "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 1, "cost": 90, "third_plus_cost": 90}], "Adrax is selectable at the source cost")
	var selections := F.current_marine_selections()
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:adrax-agatone", "models": 1, "copies": 1})
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Both players' current Space Marines rosters materialize from the local catalog")
	if not state.has("error"):
		var adrax := find_unit(state, 1, "adrax-agatone")
		var intercessors := find_unit(state, 1, "intercessor-squad")
		var enemy := find_unit(state, 2, "intercessor-squad")
		check(adrax > 0 and intercessors > 0 and enemy > 0 and A.has(state, int(state.units[adrax].squad), "combat-doctrines") and A.has(state, int(state.units[adrax].squad), "lord-of-the-pyroclasts") and A.has(state, int(state.units[adrax].squad), "unto-the-anvil") and A.has(state, int(state.units[adrax].squad), "transhuman-strategist"), "Adrax's current Core, Army Rules and datasheet abilities are present")
		check(U.attachment_allowed(state, adrax, int(state.units[intercessors].squad)) and not U.attachment_allowed(state, adrax, int(state.units[enemy].squad)), "Only source-listed, locally admitted bodyguards are allowed")
		if adrax > 0 and intercessors > 0 and enemy > 0:
			for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, adrax, int(state.units[enemy].squad)):
				check(false, "Adrax weapon plan: " + failure)
			state.phase = "deployment"
			state.awakened_dynasty.pending = []
			var applied := U.apply(state, 1, {"action": "attach", "model": adrax, "target": state.units[intercessors].squad}, Vector2.ZERO, func() -> int: return 1)
			check(applied.get("error", "").is_empty() and state.units[adrax].squad == state.units[intercessors].squad, "Adrax attaches to Intercessors")
			var warlord_option := {}
			for option: Dictionary in U.choices(state, 1):
				if option.action == "warlord" and option.model == adrax: warlord_option = option
			check(not warlord_option.is_empty(), "Adrax is available as Warlord")
			if not warlord_option.is_empty():
				var cp_before := int(state.cp[1])
				var warlord_result := U.apply(state, 1, warlord_option, Vector2.ZERO, func() -> int: return 1)
				state.active = 1
				U.start_round(state)
				U.start_round(state)
				check(warlord_result.get("error", "").is_empty() and state.cp[1] == cp_before + 1, "Transhuman Strategist grants its Warlord CP effect once per battle round")
			state.units[adrax].position = Vector2(0, 0)
			state.units[enemy].position = Vector2(1, 0)
			check(Morale.objective_control(state, enemy) == 1, "Lord of the Pyroclasts subtracts 1 from engaged enemy OC")
			state.units[enemy].position = Vector2(20, 0)
			check(Morale.objective_control(state, enemy) == 2, "Lord of the Pyroclasts does not affect unengaged enemies")
			state.units[enemy].position = Vector2(1, 0)
			state.phase = "fight"
			var target := int(state.units[enemy].squad)
			var melee := [{"model": adrax, "target": target, "amount": 5, "weapon": "malleus-noctum", "profile": "standard"}]
			var ordinary := F.C.AttackPlan.prepare(state, int(state.units[adrax].squad), true, melee, true)
			check(ordinary.error.is_empty() and ordinary.batches[0].context.wound_reroll == "ones", "Unto the Anvil re-rolls melee wound rolls of 1 without Assault Doctrine")
			state.combat_doctrines.active[1] = "assault"
			var assault := F.C.AttackPlan.prepare(state, int(state.units[adrax].squad), true, melee, true)
			check(assault.error.is_empty() and assault.batches[0].context.wound_reroll == "failed", "Unto the Anvil re-rolls failed melee wounds under Assault Doctrine")
	print("Adrax Agatone local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

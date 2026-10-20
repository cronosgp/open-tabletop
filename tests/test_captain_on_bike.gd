extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
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

func choice_for(options: Array, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func run() -> void:
	var profile := Profiles.profile("captain-on-bike")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002702" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Captain on Bike cites the local Wahapedia e11 export")
	check(profile.points_by_models == {1: 110} and profile.third_plus_points_by_models == {1: 110} and profile.stats == {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}, "The 110-point profile and characteristics match the extraction")
	check(profile.ranged.size() == 2 and profile.ranged[1].profiles.standard.keywords == {"twin-linked": true, "assault": true, "rapid-fire": 2} and profile.additional_weapon_profiles.ranged[0].profiles.supercharge.keywords.hazardous, "Default and optional ranged profiles retain their extracted weapon traits")
	check(profile.melee[0].profiles.standard.attacks == 6 and profile.additional_weapon_profiles.melee[0].profiles.standard.keywords.get("devastating-wounds", false), "Default melee profile and Thunder Hammer replacement match the extraction")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:captain-on-bike", "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 110, "third_plus_cost": 110}], "Captain on Bike is selectable at its local source price")
	var selections := F.selections()
	var marine_entries: Array = []
	for entry: Dictionary in selections[1].entries:
		if str(entry.definition_id).ends_with(":captain") or str(entry.definition_id).ends_with(":terminator-squad"): continue
		marine_entries.append(entry)
	selections[1].entries = marine_entries
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:captain-on-bike", "models": 1, "copies": 1})
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1})
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Captain on Bike and Outriders materialize from the local catalog")
	if not state.has("error"):
		state.phase = "deployment"
		state.awakened_dynasty.pending = []
		var captain := find_unit(state, 1, "captain-on-bike")
		var outriders := find_unit(state, 1, "outrider-squad")
		check(captain > 0 and outriders > 0 and A.has(state, int(state.units[captain].squad), "into-the-fray") and A.has(state, int(state.units[captain].squad), "strategic-acumen") and A.has(state, int(state.units[captain].squad), "transhuman-strategist"), "The Captain receives its three datasheet abilities")
		check(captain > 0 and outriders > 0 and U.attachment_allowed(state, captain, int(state.units[outriders].squad)), "Captain on Bike may lead Outrider Squad")
		if captain > 0:
			var attach_result := U.apply(state, 1, {"action": "attach", "model": captain, "target": state.units[outriders].squad}, Vector2.ZERO, func() -> int: return 1)
			check(attach_result.get("error", "").is_empty() and state.units[captain].squad == state.units[outriders].squad, "Captain on Bike attaches to Outriders during preparation")
			var options := U.choices(state, 1)
			var can_be_warlord := false
			for option: Dictionary in options:
				if option.action == "warlord" and option.model == captain: can_be_warlord = true
			check(can_be_warlord, "Captain on Bike is eligible for the Warlord selection")
			var plasma := choice_for(options, "captain-bike-pistol", captain, "plasma")
			var hammer := choice_for(options, "captain-bike-melee", captain, "thunder-hammer")
			check(not plasma.is_empty() and not hammer.is_empty(), "Both free source weapon replacements are offered")
			check(U.apply(state, 1, plasma, Vector2.ZERO, func() -> int: return 1).get("error", "").is_empty(), "Captain may replace the Heavy Bolt Pistol with a Plasma Pistol")
			check(U.apply(state, 1, hammer, Vector2.ZERO, func() -> int: return 1).get("error", "").is_empty(), "Captain may replace the Master-crafted Power Weapon with a Thunder Hammer")
			check(state.units[captain].ranged_weapons[0].profiles.standard.name == "Plasma Pistol - Standard" and state.units[captain].melee_weapons[0].profiles.standard.name == "Thunder Hammer", "Both replacements update the equipped weapons")
			check(U.apply(state, 1, choice_for(U.choices(state, 1), "captain-bike-pistol", captain, "bolt"), Vector2.ZERO, func() -> int: return 1).get("error", "").is_empty(), "Captain may restore the Heavy Bolt Pistol")
			check(U.apply(state, 1, choice_for(U.choices(state, 1), "captain-bike-melee", captain, "power-weapon"), Vector2.ZERO, func() -> int: return 1).get("error", "").is_empty(), "Captain may restore the Master-crafted Power Weapon")
			check(state.units[captain].ranged_weapons[0].profiles.standard.name == "Heavy Bolt Pistol" and state.units[captain].melee_weapons[0].profiles.standard.name == "Master-crafted Power Weapon", "Both source weapons restore correctly")
			state.squads[state.units[captain].squad].charged = true
			var target := int(state.units[find_unit(state, 2, "necron-warriors")].squad)
			var hammer_profile: Dictionary = state.units[captain].melee_weapons[0].profiles.standard
			check(A.weapon(state, captain, target, hammer_profile, true).keywords.get("cleave", 0) == 1, "After charging, Into the Fray grants Cleave 1 to melee attacks")
	print("Captain on Bike local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

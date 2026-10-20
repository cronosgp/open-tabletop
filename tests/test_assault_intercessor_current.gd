extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const UnitAbilities = C.UnitAbilities
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("assault-intercessor-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001606" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Assault Intercessor profile is tied to the local Wahapedia e11 sheet")
	check(profile.get("points_by_models", {}) == {5: 85, 10: 170} and profile.get("models") == 5 and is_equal_approx(profile.get("base_radius_inches", 0.0), 16.0 / 25.4), "Current fixed profile has the extracted sizes, prices and 32 mm base")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0} and "ADEPTUS ASTARTES" in profile.keywords and "BATTLELINE" in profile.keywords, "Current characteristics or shared keywords differ from the local export")
	check(profile.ranged[0].id == "heavy-bolt-pistol" and profile.melee[0].id == "chainsword" and profile.additional_weapon_profiles.ranged.size() == 2 and profile.additional_weapon_profiles.melee.size() == 3, "Default loadout or source-listed Sergeant weapon profiles are missing")
	check(Catalog.SPECS["assault-intercessor-squad"].get("current_reference", false), "Assault Intercessor is admitted into the current local catalog")
	var choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 5, "cost": 85}, {"models": 10, "cost": 170}], "Consolidated construction choices use only current 5/10 profiles and prices")
	var source_prices: Dictionary = RosterValidation.POINTS["assault-intercessor-squad"]
	check(source_prices.get("source", "") == "wahapedia-e11-2026-10-19" and source_prices.sizes == {5: 85, 10: 170}, "Current roster price resolves to the local Wahapedia profile")

	var state := F.fresh()
	check(not state.has("error"), "Assault Intercessor Squad materializes with current source data")
	if not state.has("error"):
		var model := -1
		for candidate: int in state.units:
			if state.units[candidate].owner == 1 and UnitAbilities.identity(state.units[candidate]) == "assault-intercessor-squad":
				model = candidate
				break
		var squad := int(state.units[model].squad) if model >= 0 else -1
		check(model >= 0 and UnitAbilities.has(state, squad, "targeted-intercession"), "The current admitted squad receives Targeted Intercession")
		if model >= 0:
			var base_weapon: Dictionary = state.units[model].melee_weapons[0].profiles.standard
			var original := var_to_bytes(base_weapon)
			check(UnitAbilities.weapon(state, model, 2, base_weapon, true).strength == base_weapon.strength and UnitAbilities.weapon(state, model, 2, base_weapon, true).ap == base_weapon.ap, "Uncharged melee attacks retain their printed profile")
			state.squads[squad].charged = true
			var charged := UnitAbilities.weapon(state, model, 2, base_weapon, true)
			check(charged.strength == base_weapon.strength + 1 and charged.ap == base_weapon.ap - 1, "Targeted Intercession adds +1 Strength and +1 AP after a charge")
			check(var_to_bytes(base_weapon) == original, "Targeted Intercession does not mutate the printed Chainsword profile")
			var pistol: Dictionary = state.units[model].ranged_weapons[0].profiles.standard
			var ranged := UnitAbilities.weapon(state, model, 2, pistol, false)
			check(ranged.strength == pistol.strength and ranged.ap == pistol.ap, "Targeted Intercession does not modify ranged attacks")

	print("Current Assault Intercessor checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

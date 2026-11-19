extends RefCounted
## Source-bounded Canoptek Tomb Crawlers equipment and Retinue rule.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const NecronProfiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

const IDENTITY := "canoptek-tomb-crawlers"
const ISOLATOR := "transdimensional-isolator"
const GAUSS_REAPER := "twin-gauss-reaper"
const LOADOUT_ACTION := "canoptek-tomb-crawlers-loadout"
const RETINUE_ACTION := "canoptek-tomb-crawlers-retinue"
const CRYPTEK_LEADERS := ["orikan-the-diviner", "plasmancer", "technomancer", "psychomancer", "chronomancer", "geomancer"]

static func _profile() -> Dictionary:
	return NecronProfiles.profile(IDENTITY)

static func _ranged_weapon(profile: Dictionary, weapon_id: String) -> Dictionary:
	for weapon: Dictionary in profile.get("ranged", []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get("ranged", []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

static func weapons(loadout: String) -> Dictionary:
	if loadout not in [GAUSS_REAPER, ISOLATOR]: return {}
	var profile := _profile()
	if profile.is_empty(): return {}
	var weapon_id := "source-ranged-2" if loadout == GAUSS_REAPER else "source-ranged-1"
	var ranged := _ranged_weapon(profile, weapon_id)
	var melee: Array = profile.get("melee", []).duplicate(true)
	if ranged.is_empty() or melee.is_empty(): return {}
	return {"ranged": [ranged], "melee": melee}

static func prepare_model(unit: Dictionary) -> String:
	var loadout := str(unit.get("canoptek_tomb_crawlers_loadout", GAUSS_REAPER))
	var selected := weapons(loadout)
	if selected.is_empty(): return "Canoptek Tomb Crawlers require a source-listed local equipment profile."
	unit.canoptek_tomb_crawlers_loadout = loadout
	unit.ranged_weapons = selected.ranged
	unit.melee_weapons = selected.melee
	return ""

static func valid_loadout_change(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if next_loadout not in [GAUSS_REAPER, ISOLATOR] or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) not in [1, 2]: return false
	var found_changed := false
	var isolator_count := 0
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or AbilityCatalog.identity(unit) != IDENTITY: continue
		var loadout := str(unit.get("canoptek_tomb_crawlers_loadout", GAUSS_REAPER))
		if model == changed_model:
			loadout = next_loadout
			found_changed = true
		if loadout == ISOLATOR: isolator_count += 1
	return found_changed and isolator_count <= 1

static func loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player or state.get("unit_abilities", {}).get("setup_players", []).has(player): return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY or bool(unit.get("canoptek_tomb_crawlers_loadout_locked", false)): continue
		var squad := int(unit.get("squad", -1))
		var current := str(unit.get("canoptek_tomb_crawlers_loadout", GAUSS_REAPER))
		for loadout: String in [GAUSS_REAPER, ISOLATOR]:
			if loadout == current or not valid_loadout_change(state, squad, model, loadout): continue
			var label := "Twin gauss reaper" if loadout == GAUSS_REAPER else "Transdimensional isolator"
			result.append({"label": "Canoptek Tomb Crawler %d: equip %s" % [model, label], "action": LOADOUT_ACTION, "model": model, "target": squad, "value": loadout})
	return result

static func configure_model(state: Dictionary, player: int, model: int, squad: int, loadout: String) -> String:
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player or state.get("unit_abilities", {}).get("setup_players", []).has(player):
		return "Canoptek Tomb Crawlers equipment is selected during your army preparations."
	if not state.get("units", {}).has(model): return "Choose a Canoptek Tomb Crawler from your army."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY:
		return "Choose a living Canoptek Tomb Crawler from its own unit."
	if bool(unit.get("canoptek_tomb_crawlers_loadout_locked", false)):
		return "This saved-list Canoptek Tomb Crawler equipment is fixed for the match. Edit the saved list before starting another match."
	if not valid_loadout_change(state, squad, model, loadout): return "Only one Canoptek Tomb Crawler may replace its twin gauss reaper with a transdimensional isolator."
	var selected := weapons(loadout)
	if selected.is_empty(): return "The selected Canoptek Tomb Crawlers equipment is missing from the local source profile."
	unit.canoptek_tomb_crawlers_loadout = loadout
	unit.ranged_weapons = selected.ranged
	unit.melee_weapons = selected.melee
	return ""

static func weapon_sentinels_applies(state: Dictionary, model: int, target: int, melee: bool = false) -> bool:
	if melee or not state.get("units", {}).has(model) or not state.get("squads", {}).has(target): return false
	if AbilityCatalog.identity(state.units[model]) != IDENTITY: return false
	return Geometry.distance_to_target(state, state.units[model], target) <= 12.0 + 0.001

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	for value: Variant in unit.get("keywords", []):
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _is_leading_cryptek(unit: Dictionary) -> bool:
	if AbilityCatalog.identity(unit) not in CRYPTEK_LEADERS or not _has_keyword(unit, "CRYPTEK"): return false
	return str(unit.get("attachment_role", "")) in ["leader", "support"]

static func retinue_error(state: Dictionary, model: int, target: int) -> String:
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) not in [1, 2] or state.get("unit_abilities", {}).get("setup_players", []).has(int(state.get("active", -1))):
		return "Canoptek Retinue is declared during Declare Battle Formations."
	if not state.get("units", {}).has(model) or not state.get("squads", {}).has(target): return "Choose a Canoptek Tomb Crawlers unit and an eligible friendly unit."
	var source: Dictionary = state.units[model]
	var origin := int(source.get("squad", -1))
	if AbilityCatalog.identity(source) != IDENTITY or origin == target or not state.get("squads", {}).has(origin): return "Choose a separate Canoptek Tomb Crawlers unit."
	var player := int(state.get("active", -1))
	if int(source.get("owner", -1)) != player or int(state.squads[target].get("owner", -1)) != player: return "Canoptek Retinue can join only a friendly unit."
	if bool(state.squads[origin].get("attached", false)) or state.get("unit_abilities", {}).get("reserves", {}).has(origin) or state.get("unit_abilities", {}).get("reserves", {}).has(target): return "Canoptek Retinue requires units that are not already attached or in Reserves."
	var crawler_models := 0
	for member: int in state.get("units", {}):
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != origin: continue
		if AbilityCatalog.identity(unit) != IDENTITY or int(unit.get("wounds", 0)) <= 0: return "Canoptek Retinue requires the intact two-model Canoptek Tomb Crawlers unit."
		crawler_models += 1
	if crawler_models != 2 or int(state.squads[origin].get("starting_strength", 0)) != 2: return "Canoptek Retinue requires the intact two-model Canoptek Tomb Crawlers unit."
	if not state.squads[target].get("attached", false): return "Canoptek Retinue can join only a unit already led by a Cryptek model."
	var has_cryptek_leader := false
	for member: int in state.get("units", {}):
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != target: continue
		if unit.get("wounds", 0) > 0 and _is_leading_cryptek(unit): has_cryptek_leader = true
		var identity := AbilityCatalog.identity(unit)
		if identity in [IDENTITY, "cryptothralls"]: return "A unit cannot include both Canoptek Tomb Crawlers and Cryptothralls, or more than one Tomb Crawlers unit."
	if not has_cryptek_leader: return "Canoptek Retinue can join only a unit already led by a Cryptek model."
	return ""

static func retinue_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player or state.get("unit_abilities", {}).get("setup_players", []).has(player): return result
	var seen_origins: Dictionary = {}
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY: continue
		var origin := int(unit.get("squad", -1))
		if seen_origins.has(origin): continue
		seen_origins[origin] = true
		for target: int in state.get("squads", {}):
			if not retinue_error(state, model, target).is_empty(): continue
			result.append({"label": "Canoptek Retinue: join %s to %s" % [str(state.squads[origin].get("name", "Canoptek Tomb Crawlers")), str(state.squads[target].get("name", "Cryptek-led unit"))], "action": RETINUE_ACTION, "model": model, "target": target, "value": "join"})
	return result

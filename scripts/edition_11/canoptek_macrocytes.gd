extends RefCounted
## Source-bounded Canoptek Macrocytes equipment and ability effects.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const NecronProfiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

const IDENTITY := "canoptek-macrocytes"
const GAUSS_SCALPEL := "gauss-scalpel"
const TESLA_CASTER := "tesla-caster"
const ATOMISER_PROJECTOR := "atomiser-beam-projector"
const ACCELERATOR_MANDIBLE := "accelerator-mandible"
const LOADOUTS := [GAUSS_SCALPEL, TESLA_CASTER, ATOMISER_PROJECTOR, ACCELERATOR_MANDIBLE]

static func _profile() -> Dictionary:
	return NecronProfiles.profile(IDENTITY)

static func loadout_label(loadout: String) -> String:
	return str({
		GAUSS_SCALPEL: "Gauss scalpel",
		TESLA_CASTER: "Tesla caster",
		ATOMISER_PROJECTOR: "Atomiser beam + Nanoscarab Projector",
		ACCELERATOR_MANDIBLE: "Accelerator Mandible"
	}.get(loadout, ""))

static func _find_ranged_weapon(profile: Dictionary, weapon_id: String) -> Dictionary:
	for weapon: Dictionary in profile.get("ranged", []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get("ranged", []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

static func weapons(loadout: String) -> Dictionary:
	if loadout not in LOADOUTS: return {}
	var profile := _profile()
	if profile.is_empty(): return {}
	var weapon_id := str({
		GAUSS_SCALPEL: "source-ranged-2",
		TESLA_CASTER: "source-ranged-3",
		ATOMISER_PROJECTOR: "source-ranged-1"
	}.get(loadout, ""))
	var ranged: Array = []
	if not weapon_id.is_empty():
		var weapon := _find_ranged_weapon(profile, weapon_id)
		if weapon.is_empty(): return {}
		ranged.append(weapon)
	var melee: Array = profile.get("melee", []).duplicate(true)
	if melee.is_empty(): return {}
	return {"ranged": ranged, "melee": melee}

static func valid_loadout_change(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if next_loadout not in LOADOUTS or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) not in [1, 2]: return false
	var found_changed := false
	var atomiser_count := 0
	var accelerator_count := 0
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad: continue
		if AbilityCatalog.identity(unit) != IDENTITY: return false
		var loadout := str(unit.get("canoptek_macrocytes_loadout", GAUSS_SCALPEL))
		if model == changed_model:
			loadout = next_loadout
			found_changed = true
		if loadout == ATOMISER_PROJECTOR: atomiser_count += 1
		if loadout == ACCELERATOR_MANDIBLE: accelerator_count += 1
	return found_changed and atomiser_count <= 1 and accelerator_count <= 1

static func configure_model(state: Dictionary, player: int, model: int, squad: int, loadout: String) -> String:
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player:
		return "Canoptek Macrocytes equipment is selected during your army preparations."
	if not state.get("units", {}).has(model): return "Choose a Canoptek Macrocyte from your army."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY:
		return "Choose a living Canoptek Macrocyte from its own unit."
	if bool(unit.get("canoptek_macrocytes_loadout_locked", false)):
		return "This Canoptek Macrocyte's equipment was saved with the army and is fixed for this match."
	if not valid_loadout_change(state, squad, model, loadout):
		return "That choice would exceed a source-listed one-model specialist equipment limit."
	var selected_weapons := weapons(loadout)
	if selected_weapons.is_empty(): return "The selected Canoptek Macrocytes equipment is missing from the local source profile."
	unit.canoptek_macrocytes_loadout = loadout
	unit.ranged_weapons = selected_weapons.ranged
	unit.melee_weapons = selected_weapons.melee
	return ""

static func loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player: return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY or bool(unit.get("canoptek_macrocytes_loadout_locked", false)): continue
		var squad := int(unit.get("squad", -1))
		var current := str(unit.get("canoptek_macrocytes_loadout", GAUSS_SCALPEL))
		for loadout: String in LOADOUTS:
			if loadout == current or not valid_loadout_change(state, squad, model, loadout): continue
			result.append({"label": "Canoptek Macrocyte %d: %s" % [model, loadout_label(loadout)], "action": "canoptek-macrocytes-loadout", "model": model, "target": squad, "value": loadout})
	return result

static func _on_battlefield(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)): return false
	var squad := int(unit.get("squad", -1))
	if state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	return int(unit.get("embarked_transport", -1)) < 0

static func _has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in Geometry.alive(state, squad):
		for entry: Variant in state.units[model].get("keywords", []):
			if str(entry).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func harassment_swarm_applies(state: Dictionary, attacker: int, target: int) -> bool:
	if not state.get("squads", {}).has(attacker) or not state.get("squads", {}).has(target): return false
	if int(state.squads[attacker].get("owner", -1)) == int(state.squads[target].get("owner", -2)): return false
	if _has_keyword(state, attacker, "MONSTER") or _has_keyword(state, attacker, "VEHICLE"): return false
	for source: int in AbilityCatalog.sources(state, target, "harassment-swarm"):
		if not _on_battlefield(state, source): continue
		if Geometry.distance_to_target(state, state.units[source], attacker) <= 3.0 + 0.001: return true
	return false

static func _accelerator_targets(state: Dictionary, bearer: int) -> Array[int]:
	var result: Array[int] = []
	if not _on_battlefield(state, bearer): return result
	var owner := int(state.units[bearer].get("owner", -1))
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -2)) != owner or Geometry.alive(state, squad).is_empty() or not _has_keyword(state, squad, "CANOPTEK"): continue
		if Geometry.distance_to_target(state, state.units[bearer], squad) <= 3.0 + 0.001: result.append(squad)
	return result

static func fight_start_available(state: Dictionary, player: int) -> bool:
	if state.get("phase", "") != "fight": return false
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player: continue
		for bearer: int in AbilityCatalog.sources(state, squad, "accelerator-mandible"):
			if state.get("unit_abilities", {}).get("used", {}).get("accelerator-mandible:%d:%d" % [bearer, int(state.get("turn", -1))], false): continue
			if not _accelerator_targets(state, bearer).is_empty(): return true
	return false

static func fight_start_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "fight": return result
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player: continue
		for bearer: int in AbilityCatalog.sources(state, squad, "accelerator-mandible"):
			if state.get("unit_abilities", {}).get("used", {}).get("accelerator-mandible:%d:%d" % [bearer, int(state.get("turn", -1))], false): continue
			for target: int in _accelerator_targets(state, bearer):
				result.append({"label": "Accelerator Mandible %d: improve %s melee weapons by 1 WS" % [bearer, str(state.squads[target].get("name", "Canoptek unit"))], "action": "canoptek-accelerator-mandible", "model": bearer, "target": target, "value": "use"})
	return result

static func apply_fight_start_choice(state: Dictionary, player: int, selected: Dictionary) -> String:
	var bearer := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var use_key := "accelerator-mandible:%d:%d" % [bearer, int(state.get("turn", -1))]
	if state.get("phase", "") != "fight" or selected.get("value", "") != "use": return "Accelerator Mandible is only used at the start of the Fight phase."
	if not state.get("units", {}).has(bearer) or int(state.units[bearer].get("owner", -1)) != player or bearer not in AbilityCatalog.sources(state, int(state.units[bearer].get("squad", -1)), "accelerator-mandible") or not _on_battlefield(state, bearer):
		return "Choose a living Accelerator Mandible bearer on the battlefield."
	if state.get("unit_abilities", {}).get("used", {}).get(use_key, false): return "This Accelerator Mandible has already been used this Fight phase."
	if target not in _accelerator_targets(state, bearer): return "Choose a friendly Canoptek unit within 3 inches of the bearer’s unit."
	if not state.unit_abilities.has("canoptek_macrocytes_ws"): state.unit_abilities.canoptek_macrocytes_ws = {"turn": int(state.get("turn", -1)), "squads": {}}
	var bonuses: Dictionary = state.unit_abilities.canoptek_macrocytes_ws
	if int(bonuses.get("turn", -2)) != int(state.get("turn", -1)): bonuses = {"turn": int(state.get("turn", -1)), "squads": {}}
	if not bonuses.has("squads"): bonuses.squads = {}
	bonuses.squads[target] = int(bonuses.squads.get(target, 0)) + 1
	state.unit_abilities.canoptek_macrocytes_ws = bonuses
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	state.unit_abilities.used[use_key] = true
	return ""

static func clear_fight_modifiers(state: Dictionary) -> void:
	if state.get("unit_abilities", {}).has("canoptek_macrocytes_ws"):
		state.unit_abilities.canoptek_macrocytes_ws = {"turn": -1, "squads": {}}

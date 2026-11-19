extends RefCounted
## Source-bounded The Silent King (000002360): composite Szarekh + 2 Triarchal Menhirs,
## Triarch Abilities, The Silent King Ld aura, Damaged 1-6, and TRIARCHAL MENHIRS.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const IDENTITY := "the-silent-king"
const ABILITIES := ["phaeron-of-the-stars", "phaeron-of-the-blades", "relentless-march"]
const LABELS := {
	"phaeron-of-the-stars": "Phaeron of the Stars (Aura: re-roll Hit 1 and Wound 1)",
	"phaeron-of-the-blades": "Phaeron of the Blades (Aura: re-roll Charge and +1S melee)",
	"relentless-march": "Relentless March (Aura: +2\" Move)"
}

static func _weapon_from_source(profile: Dictionary, group: String, wid: String) -> Dictionary:
	for w: Variant in profile.get("source_weapon_profiles", {}).get(group, []):
		if w is Dictionary and str(w.get("id", "")) == wid:
			return {"id": wid, "profiles": w.get("profiles", {}).duplicate(true)}
	return {}

static func prepare_model(unit: Dictionary, model_index: int, profile: Dictionary) -> void:
	if model_index == 0:
		unit.silent_king_role = "szarekh"
		unit.wounds = 16
		unit.max_wounds = 16
		unit.objective_control = 6
		unit.radius = 100.0 / 50.8
		unit.keywords = ["NECRONS", "THE SILENT KING", "VEHICLE", "CHARACTER", "TRIARCH", "EPIC HERO"]
		unit.ranged_weapons = [
			_weapon_from_source(profile, "ranged", "source-ranged-2"),
			_weapon_from_source(profile, "ranged", "source-ranged-3")
		]
		unit.melee_weapons = [_weapon_from_source(profile, "melee", "source-melee-5")]
	else:
		unit.silent_king_role = "menhir"
		unit.wounds = 5
		unit.max_wounds = 5
		unit.objective_control = 1
		unit.radius = 50.0 / 50.8
		unit.keywords = ["NECRONS", "VEHICLE", "TRIARCH", "EPIC HERO"]
		unit.ranged_weapons = [_weapon_from_source(profile, "ranged", "source-ranged-1")]
		unit.melee_weapons = [_weapon_from_source(profile, "melee", "source-melee-4")]
	unit.defense = {"toughness": 10, "save_target": 2, "invulnerable_target": 4}

static func szarekh_model(state: Dictionary, squad: int) -> int:
	for m: int in state.get("units", {}):
		var u: Dictionary = state.units[m]
		if int(u.get("squad", -1)) == squad and int(u.get("wounds", 0)) > 0 and bool(u.get("on_battlefield", true)) and str(u.get("silent_king_role", "")) == "szarekh":
			return m
	return -1

static func is_damaged(state: Dictionary, squad: int) -> bool:
	var szarekh := szarekh_model(state, squad)
	if szarekh < 0: return false
	return int(state.units[szarekh].get("wounds", 0)) <= 6

static func enforce_menhirs(state: Dictionary, destroyed_models: Array[int] = []) -> Array[int]:
	var extra_destroyed: Array[int] = []
	var checked_squads: Dictionary = {}
	for m: int in destroyed_models:
		if state.get("units", {}).has(m):
			checked_squads[int(state.units[m].get("squad", -1))] = true
	if checked_squads.is_empty():
		for sq: int in state.get("squads", {}): checked_squads[sq] = true
	for sq: int in checked_squads:
		if not state.get("squads", {}).has(sq): continue
		var has_silent_king := false
		var szarekh_alive := false
		var menhirs: Array[int] = []
		for m: int in state.get("units", {}):
			var u: Dictionary = state.units[m]
			if int(u.get("squad", -1)) != sq or AbilityCatalog.identity(u) != IDENTITY: continue
			has_silent_king = true
			if str(u.get("silent_king_role", "")) == "szarekh" and int(u.get("wounds", 0)) > 0:
				szarekh_alive = true
			elif str(u.get("silent_king_role", "")) == "menhir" and int(u.get("wounds", 0)) > 0:
				menhirs.append(m)
		if has_silent_king and not szarekh_alive:
			for m: int in menhirs:
				state.units[m].wounds = 0
				extra_destroyed.append(m)
	return extra_destroyed

static func selected_ability(state: Dictionary, squad: int) -> String:
	var record: Dictionary = state.get("unit_abilities", {}).get("triarch_abilities", {}).get(squad, {})
	if int(record.get("round", -1)) != int(state.get("round", 0)): return ""
	return str(record.get("ability", ""))

static func triarch_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not AbilityCatalog.enabled(state) or str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != player:
		return result
	var current_round := int(state.get("round", 0))
	for m: int in state.get("units", {}):
		var u: Dictionary = state.units[m]
		if int(u.get("owner", -1)) != player or int(u.get("wounds", 0)) <= 0 or not bool(u.get("on_battlefield", true)): continue
		if AbilityCatalog.identity(u) != IDENTITY or str(u.get("silent_king_role", "")) != "szarekh": continue
		var squad := int(u.get("squad", -1))
		if not selected_ability(state, squad).is_empty(): continue
		for ability_id: String in ABILITIES:
			result.append({
				"label": "Triarch Abilities %d: %s" % [m, str(LABELS.get(ability_id, ability_id))],
				"action": "silent-king-triarch",
				"model": m,
				"target": squad,
				"value": ability_id
			})
	return result

static func apply_triarch_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in triarch_choices(state, player):
		return {"error": "Triarch Abilities can be selected once per battle round in your Command phase."}
	var squad := int(selected.get("target", -1))
	var ability_id := str(selected.get("value", ""))
	if not state.unit_abilities.has("triarch_abilities"):
		state.unit_abilities.triarch_abilities = {}
	state.unit_abilities.triarch_abilities[squad] = {"round": int(state.get("round", 0)), "ability": ability_id, "owner": player}
	return {"error": "", "message": "The Silent King selected %s for battle round %d." % [ability_id, int(state.get("round", 0))]}

static func _is_friendly_necrons(state: Dictionary, squad: int, exclude_monsters: bool) -> bool:
	var has_necrons := false
	for m: int in Geometry.alive(state, squad):
		var kw: Array = state.units[m].get("keywords", [])
		if "NECRONS" in kw: has_necrons = true
		if exclude_monsters and "MONSTER" in kw: return false
	return has_necrons

static func _within_szarekh_aura(state: Dictionary, target_squad: int, required_triarch_ability: String = "") -> bool:
	if not AbilityCatalog.enabled(state) or not state.get("squads", {}).has(target_squad): return false
	var exclude_monsters := not required_triarch_ability.is_empty()
	if not _is_friendly_necrons(state, target_squad, exclude_monsters): return false
	var owner := int(state.squads[target_squad].get("owner", -1))
	for sq: int in state.squads:
		if int(state.squads[sq].get("owner", -2)) != owner: continue
		if not required_triarch_ability.is_empty() and selected_ability(state, sq) != required_triarch_ability: continue
		var szarekh := szarekh_model(state, sq)
		if szarekh < 0: continue
		if Geometry.distance_to_target(state, state.units[szarekh], target_squad) <= 6.001:
			return true
	return false

static func leadership_delta(state: Dictionary, target_squad: int) -> int:
	return -1 if _within_szarekh_aura(state, target_squad, "") else 0

static func movement_bonus(state: Dictionary, target_squad: int) -> float:
	return 2.0 if _within_szarekh_aura(state, target_squad, "relentless-march") else 0.0

static func charge_reroll_active(state: Dictionary, target_squad: int) -> bool:
	return _within_szarekh_aura(state, target_squad, "phaeron-of-the-blades")

static func stars_aura_active(state: Dictionary, target_squad: int) -> bool:
	return _within_szarekh_aura(state, target_squad, "phaeron-of-the-stars")

static func blades_aura_active(state: Dictionary, target_squad: int) -> bool:
	return _within_szarekh_aura(state, target_squad, "phaeron-of-the-blades")

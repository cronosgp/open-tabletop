extends RefCounted
## Black Templars Crusade Ancient abilities resolved by the current combat flow.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const MARTIAL_HONOUR_WINDOW := "crusade-martial-honour"
const MARTIAL_HONOUR_USE := "crusade-martial-honour"
const MARTIAL_HONOUR_PASS := "crusade-martial-honour-pass"
const VENGEFUL_EXHORTATION_USE := "crusade-vengeful-exhortation"

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", -1)), str(state.get("phase", ""))]

static func can_offer_vengeful_exhortation(state: Dictionary, squad: int) -> bool:
	if not UnitAbilities.enabled(state) or state.get("phase", "") != "fight" or not state.get("squads", {}).has(squad): return false
	if not UnitAbilities.has(state, squad, "vengeful-exhortation") or bool(state.squads[squad].get("fought", false)): return false
	if int(state.get("fight_selected", -1)) == squad: return false
	var active: Dictionary = state.get("unit_abilities", {}).get("crusade_vengeful_exhortation", {})
	return str(active.get(squad, {}).get("phase_key", "")) != phase_key(state)

static func activate_vengeful_exhortation(state: Dictionary, player: int, squad: int, model: int) -> String:
	if not can_offer_vengeful_exhortation(state, squad): return "Vengeful Exhortation is unavailable after its unit has fought or already used it this phase."
	if int(state.squads[squad].get("owner", -1)) != player or model not in UnitAbilities.sources(state, squad, "vengeful-exhortation"):
		return "Vengeful Exhortation must be activated by your living Crusade Ancient."
	if not state.unit_abilities.has("crusade_vengeful_exhortation"): state.unit_abilities.crusade_vengeful_exhortation = {}
	state.unit_abilities.crusade_vengeful_exhortation[squad] = {"phase_key": phase_key(state), "source_model": model}
	return ""

static func vengeful_exhortation_active(state: Dictionary, squad: int) -> bool:
	if not UnitAbilities.enabled(state) or not state.get("squads", {}).has(squad): return false
	var record: Dictionary = state.get("unit_abilities", {}).get("crusade_vengeful_exhortation", {}).get(squad, {})
	return str(record.get("phase_key", "")) == phase_key(state)

static func martial_honour_used_key(squad: int) -> String:
	return "crusade-martial-honour:%d" % squad

static func open_martial_honour(state: Dictionary, squad: int, targets: Array, killed: int) -> bool:
	if killed <= 0 or not UnitAbilities.enabled(state) or state.get("phase", "") != "fight" or not state.get("squads", {}).has(squad): return false
	var destroyed_target := -1
	for target_value: Variant in targets:
		var target := int(target_value)
		if state.get("squads", {}).has(target) and int(state.squads[target].get("owner", -1)) != int(state.squads[squad].get("owner", -1)) and Geometry.alive(state, target).is_empty():
			destroyed_target = target
			break
	if destroyed_target < 0: return false
	var used: Dictionary = state.unit_abilities.get("used", {})
	if used.has(martial_honour_used_key(squad)): return false
	var sources := UnitAbilities.sources(state, squad, "martial-honour")
	if sources.is_empty(): return false
	var resume_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": MARTIAL_HONOUR_WINDOW, "owners": [int(state.squads[squad].owner)], "squad": squad, "model": sources[0], "destroyed_target": destroyed_target, "resume_window": resume_window}
	return true

static func martial_honour_choice_valid(state: Dictionary, player: int, squad: int, model: int, destroyed_target: int) -> bool:
	if not UnitAbilities.enabled(state) or state.get("phase", "") != "fight" or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) != player or model not in UnitAbilities.sources(state, squad, "martial-honour"): return false
	if not state.get("squads", {}).has(destroyed_target) or int(state.squads[destroyed_target].get("owner", -1)) == player or not Geometry.alive(state, destroyed_target).is_empty(): return false
	return not state.unit_abilities.get("used", {}).has(martial_honour_used_key(squad))

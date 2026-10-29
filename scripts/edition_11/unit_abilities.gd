extends RefCounted
## Current e11 datasheet effects; fixed-loadout training, not list certification.
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Bladeguard = preload("res://scripts/edition_11/bladeguard.gd")
const CombiLieutenant = preload("res://scripts/edition_11/combi_lieutenant.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const RagnarBlackmane = preload("res://scripts/edition_11/ragnar_blackmane.gd")
const UlrikTheSlayer = preload("res://scripts/edition_11/ulrik_the_slayer.gd")
const ID := AbilityCatalog.ID
const RULES := AbilityCatalog.RULES
const CHAPLAIN_MODEL_IDENTITIES := ["chaplain", "chaplain-in-terminator-armour", "chaplain-on-bike", "chaplain-with-jump-pack", "astorath", "lemartes", "chaplain-grimaldus", "execrator"]
const TRANSPORT_DEADLY_DEMISE := {
	"land-raider": "D6",
	"land-raider-crusader": "D6",
	"land-raider-redeemer": "D6",
	"drop-pod": 1,
	"impulsor": "D3",
	"black-templars-impulsor": "D3",
	"repulsor": "D6",
	"black-templars-repulsor": "D6",
	"repulsor-executioner": "D6",
	"black-templars-repulsor-executioner": "D6",
	"corvus-blackstar": "D6",
	"rhino": "D3",
}
static func identity(unit: Dictionary) -> String:
	return AbilityCatalog.identity(unit)
static func enabled(state: Dictionary) -> bool:
	return AbilityCatalog.enabled(state)
static func sources(state: Dictionary, squad: int, name: String) -> Array[int]:
	return AbilityCatalog.sources(state, squad, name)

static func vehement_aggression_result(state: Dictionary, squad: int) -> Dictionary:
	if not enabled(state) or not has(state, squad, "vehement-aggression"): return {}
	if str(state.get("phase", "")) != "fight" or str(state.get("fight_step", "")) not in ["attacks", "consolidation_reaction"] or int(state.get("fight_selected", -1)) != squad or bool(state.get("squads", {}).get(squad, {}).get("fought", false)): return {}
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var result: Variant = used.get("vehement-aggression:%d" % squad, {})
	if not result is Dictionary or int(result.get("round", -1)) != int(state.get("round", -2)): return {}
	return result.duplicate(true)

static func pious_fervour_bonus(state: Dictionary, model: int) -> int:
	if not enabled(state) or not state.get("units", {}).has(model) or identity(state.units[model]) != "marshal": return 0
	var squad := int(state.units[model].get("squad", -1))
	if not state.get("squads", {}).has(squad) or not has(state, squad, "pious-fervour"): return 0
	if str(state.get("phase", "")) != "fight" or str(state.get("fight_step", "")) not in ["attacks", "consolidation_reaction"] or int(state.get("fight_selected", -1)) != squad or bool(state.squads[squad].get("fought", false)): return 0
	var record: Dictionary = state.get("unit_abilities", {}).get("pious_fervour", {}).get(squad, {})
	if int(record.get("model", -1)) != model or int(record.get("owner", -1)) != int(state.units[model].get("owner", -2)) or int(record.get("turn", -1)) != int(state.get("turn", -2)): return 0
	return clampi(int(record.get("bonus", 0)), 0, 3)

static func every_model_has(state: Dictionary, squad: int, name: String) -> bool:
	var alive := Geometry.alive(state, squad)
	return not alive.is_empty() and sources(state, squad, name).size() == alive.size()

static func scout_distance(state: Dictionary, squad: int) -> int:
	if not enabled(state): return 0
	if has(state, squad, "forlorn-hero"): return 6
	if int(state.get("unit_abilities", {}).get("cerebrex_targets", {}).get(squad, -1)) == squad and not Geometry.alive(state, squad).is_empty(): return 6
	if MarineEnhancements.active(state, squad, MarineEnhancements.SPEARPOINT_WAR_LEADER): return 6
	if MarineEnhancements.active(state, squad, MarineEnhancements.RELENTLESS_ADVANCE): return 5
	if MarineEnhancements.zealous_vanguard_active(state, squad): return 6
	var alive: Array[int] = []
	for model: int in state.units:
		if state.units[model].squad == squad and state.units[model].wounds > 0: alive.append(model)
	if alive.is_empty(): return 0
	var distance := -1
	for model: int in alive:
		var current := 8 if identity(state.units[model]) in ["invictor-tactical-warsuit", "wolf-scouts"] else 6 if identity(state.units[model]) in ["impulsor", "black-templars-impulsor"] and state.units[model].get("impulsor_system", "none") == "orbital-comms-array" else 6 if identity(state.units[model]) in ["lieutenant-in-phobos-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "scout-squad", "incursor-squad", "reiver-squad", "death-company-captain", "spectrus-kill-team"] else 0
		if current <= 0: return 0
		if distance < 0: distance = current
		elif distance != current: return 0
	return distance

static func deadly_stalkers_wound_bonus(state: Dictionary, squad: int, target: int) -> int:
	if not enabled(state) or not has(state, squad, "deadly-stalkers") or not state.get("squads", {}).has(squad) or not state.get("squads", {}).has(target): return 0
	var owner := int(state.squads[squad].get("owner", -1))
	if int(state.squads[target].get("owner", -2)) == owner: return 0
	var target_models: Array[int] = []
	for model: int in Geometry.alive(state, target):
		if state.units[model].get("on_battlefield", true): target_models.append(model)
	if target_models.is_empty(): return 0
	for other_squad: int in state.squads:
		if other_squad == target or int(state.squads[other_squad].get("owner", -2)) == owner: continue
		for target_model: int in target_models:
			for other_model: int in Geometry.alive(state, other_squad):
				if not state.units[other_model].get("on_battlefield", true): continue
				if Geometry.edge(state.units[target_model], state.units[other_model]) <= 6.001: return 0
	return 1

static func forward_assault_targets(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == owner: continue
		for model: int in state.units:
			if state.units[model].squad == squad and state.units[model].wounds > 0:
				result.append(squad)
				break
	return result

static func living_enemy_targets(state: Dictionary, owner: int) -> Array[int]:
	return forward_assault_targets(state, owner)

static func forward_assault_mark(state: Dictionary, squad: int) -> int:
	return int(state.get("unit_abilities", {}).get("forward_assault_marks", {}).get(squad, -1))

static func high_king_fenris_selected(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.get("squads", {}).has(squad): return false
	var abilities: Dictionary = state.get("unit_abilities", {})
	var selected: Dictionary = abilities.get("high_king_fenris", {}).get(squad, {})
	if selected.is_empty() or not abilities.get("reserves", {}).has(squad): return false
	return int(selected.get("owner", -1)) == int(state.squads[squad].get("owner", -2)) and has_living_unit_keyword(state, squad, "SPACE WOLVES")

static func purgatus_quarry(state: Dictionary, squad: int) -> int:
	return int(state.get("unit_abilities", {}).get("purgatus_quarries", {}).get(squad, -1))

static func headhunter_quarry(state: Dictionary, squad: int) -> int:
	return int(state.get("unit_abilities", {}).get("headhunter_quarries", {}).get(squad, -1))

static func hunted_target(state: Dictionary, squad: int) -> int:
	if has(state, squad, "forward-assault-warsuit"): return forward_assault_mark(state, squad)
	if has(state, squad, "purgatus-quarry"): return purgatus_quarry(state, squad)
	return -1

static func headhunter_initial_resolved(state: Dictionary, squad: int) -> bool:
	return bool(state.get("unit_abilities", {}).get("used", {}).get("headhunters-initial:%d" % squad, false))

static func resolve_initial_headhunter_quarry(state: Dictionary, squad: int, target: int) -> String:
	if not state.squads.has(squad) or not has(state, squad, "headhunter-quarry"): return "Headhunters requires a Wolf Guard Headtakers unit."
	if headhunter_initial_resolved(state, squad): return "This unit has already resolved its initial Headhunters choice."
	if target >= 0 and target not in living_enemy_targets(state, int(state.squads[squad].owner)): return "Select a living enemy unit as the quarry, or explicitly pass."
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	if target < 0:
		state.unit_abilities.get("headhunter_quarries", {}).erase(squad)
	else:
		if not state.unit_abilities.has("headhunter_quarries"): state.unit_abilities.headhunter_quarries = {}
		state.unit_abilities.headhunter_quarries[squad] = target
	state.unit_abilities.used["headhunters-initial:%d" % squad] = true
	return ""

static func purgatus_initial_resolved(state: Dictionary, squad: int) -> bool:
	return bool(state.get("unit_abilities", {}).get("used", {}).get("purgatus-initial:%d" % squad, false))

static func set_forward_assault_mark(state: Dictionary, squad: int, target: int) -> String:
	if not state.squads.has(squad) or not has(state, squad, "forward-assault-warsuit"): return "Forward Assault Warsuit requires an Invictor Tactical Warsuit."
	if target not in forward_assault_targets(state, int(state.squads[squad].owner)): return "Select a living enemy unit as this Invictor's mark."
	if not state.unit_abilities.has("forward_assault_marks"): state.unit_abilities.forward_assault_marks = {}
	state.unit_abilities.forward_assault_marks[squad] = target
	return ""

static func resolve_initial_purgatus_quarry(state: Dictionary, squad: int, target: int) -> String:
	if not state.squads.has(squad) or not has(state, squad, "purgatus-quarry"): return "Purgatus Quarry requires a Watch Master."
	if purgatus_initial_resolved(state, squad): return "This Watch Master has already resolved its initial quarry choice."
	if target >= 0 and target not in living_enemy_targets(state, int(state.squads[squad].owner)): return "Select a living enemy unit as the hunted quarry, or explicitly pass."
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	if target < 0:
		state.unit_abilities.get("purgatus_quarries", {}).erase(squad)
	else:
		if not state.unit_abilities.has("purgatus_quarries"): state.unit_abilities.purgatus_quarries = {}
		state.unit_abilities.purgatus_quarries[squad] = target
	state.unit_abilities.used["purgatus-initial:%d" % squad] = true
	return ""

static func open_destroyed_mark_replacements(state: Dictionary) -> bool:
	var queue: Array[int] = []
	var queue_abilities: Array[String] = []
	var previous_window: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	for mark_record: Dictionary in [
		{"ability": "forward-assault-warsuit", "field": "forward_assault_marks"},
		{"ability": "purgatus-quarry", "field": "purgatus_quarries"},
		{"ability": "headhunter-quarry", "field": "headhunter_quarries"}
	]:
		var marks: Dictionary = state.get("unit_abilities", {}).get(str(mark_record.field), {})
		for source: Variant in marks.keys():
			var squad := int(source)
			var ability := str(mark_record.ability)
			if not state.squads.has(squad) or not has(state, squad, ability):
				marks.erase(squad)
				continue
			var target := int(marks.get(source, -1))
			var target_alive := false
			for model: int in state.units:
				if int(state.units[model].get("squad", -1)) == target and int(state.units[model].get("wounds", 0)) > 0: target_alive = true
			if target_alive or target < 0: continue
			if living_enemy_targets(state, int(state.squads[squad].owner)).is_empty(): marks.erase(squad)
			else:
				queue.append(squad)
				queue_abilities.append(ability)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": "forward-assault-mark", "owners": [state.squads[queue[0]].owner], "queue": queue, "queue_abilities": queue_abilities, "source_squad": queue[0], "source_ability": queue_abilities[0]}
	if not previous_window.is_empty(): state.unit_abilities.window.resume_window = previous_window
	return true

static func advance_destroyed_mark_queue(state: Dictionary, selected_squad: int, target: int) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "forward-assault-mark" or int(window.get("source_squad", -1)) != selected_squad or not state.get("squads", {}).has(selected_squad): return "No enemy-mark replacement is pending."
	var ability := str(window.get("source_ability", "forward-assault-warsuit"))
	if target < 0:
		if ability != "purgatus-quarry": return "This ability does not permit passing on a replacement target."
		state.unit_abilities.get("purgatus_quarries", {}).erase(selected_squad)
	else:
		var error := ""
		if ability == "forward-assault-warsuit": error = set_forward_assault_mark(state, selected_squad, target)
		elif ability == "purgatus-quarry":
			if target not in living_enemy_targets(state, int(state.squads[selected_squad].owner)): error = "Select a living enemy unit as the hunted quarry."
			elif not state.get("unit_abilities", {}).get("purgatus_quarries", {}).has(selected_squad): error = "The pending Purgatus Quarry no longer has a hunted target."
			else: state.unit_abilities.purgatus_quarries[selected_squad] = target
		elif ability == "headhunter-quarry":
			if target not in living_enemy_targets(state, int(state.squads[selected_squad].owner)): error = "Select a living enemy unit as the replacement quarry."
			elif not state.get("unit_abilities", {}).get("headhunter_quarries", {}).has(selected_squad): error = "The pending Headhunters choice no longer has a quarry."
			else: state.unit_abilities.headhunter_quarries[selected_squad] = target
		else: error = "Unsupported enemy mark ability."
		if not error.is_empty(): return error
	var queue: Array = window.get("queue", [])
	var abilities: Array = window.get("queue_abilities", ["forward-assault-warsuit"])
	if not queue.is_empty(): queue.pop_front()
	if not abilities.is_empty(): abilities.pop_front()
	if queue.is_empty(): state.unit_abilities.window = window.get("resume_window", {})
	else:
		window.queue = queue
		window.queue_abilities = abilities
		window.source_squad = int(queue[0])
		window.source_ability = str(abilities[0])
		window.owners = [state.squads[int(queue[0])].owner]
	return ""

static func has(state: Dictionary, squad: int, name: String) -> bool:
	return AbilityCatalog.has(state, squad, name)

static func deadly_demise_value(state: Dictionary, model: int) -> Variant:
	if not enabled(state) or not state.get("units", {}).has(model): return null
	var unit: Dictionary = state.units[model]
	var unit_identity := identity(unit)
	var abilities: Array = RULES.get(unit_identity, [])
	if "deadly-demise-d3" in abilities: return "D3"
	if "deadly-demise-1" in abilities: return "1"
	if "transport-deadly-demise" in abilities: return TRANSPORT_DEADLY_DEMISE.get(unit_identity)
	return null
static func enable(state: Dictionary) -> void:
	state.unit_abilities = {"implementation": ID, "used": {}, "doctrines": {}, "additional_doctrines": {}, "lion_primarch": {}, "lion_primarch_pending": {}, "watcher_active": {}, "discounts": {}, "discount_armed": {}, "phase_start": -1, "end_done": "", "window": {}, "reserves": {}, "high_king_fenris": {}, "ingress_history": {}, "homers": {}, "force_dome": {}, "veil_of_time_pending": {}, "master_shadows": {}, "thunderhawk_targets": {}, "seeker_objectives": {}, "forgefather_targets": {}, "forward_assault_marks": {}, "purgatus_quarries": {}, "headhunter_quarries": {}, "slayer_oaths": {}, "njal_psychic_uses": {}, "njal_psychic_results": [], "njal_storm_caller_detection": {}, "snap_shooting_block_targets": {}, "tempests_wrath_targets": {}, "artemis_destroyed": [], "weapon_skill_characteristic_modifiers": {"squads": {}, "models": {}}, "setup_done": false}
	Registry.admit(state, "aircraft-core-rules", ID)
	for squad: int in state.squads:
		state.squads[squad].disabled_abilities = []
		for model: int in Geometry.alive(state, squad):
			if identity(state.units[model]) == "overlord": state.units[model].wargear = ["resurrection-orb"]
			var personal_fnp_target := 0
			if identity(state.units[model]) in ["vulkan-hestan", "watch-captain-artemis", "murderfang", "wulfen-dreadnought"]: personal_fnp_target = 6
			elif identity(state.units[model]) in ["roboute-guilliman", "lieutenant-with-combi-weapon", "iron-father-feirros", "caanok-var", "captain-titus", "mephiston", "bjorn-the-fell-handed"]: personal_fnp_target = 5
			if personal_fnp_target > 0:
				var prevention: Array = state.units[model].get("feel_no_pain", [])
				var has_personal_fnp := false
				for rule: Dictionary in prevention:
					if rule.get("target") == personal_fnp_target and rule.get("against") == "any": has_personal_fnp = true
				if not has_personal_fnp: prevention.append({"target": personal_fnp_target, "against": "any"})
				state.units[model].feel_no_pain = prevention
			for ability: String in RULES.get(identity(state.units[model]), []):
				Registry.admit(state, ability, ID)
				Registry.admit_squad(state, squad, ability)
			if "deep-strike" in RULES.get(identity(state.units[model]), []): Registry.admit(state, "rapid-ingress", ID)

static func near_objective(state: Dictionary, squad: int, controlled: bool = false) -> bool:
	if controlled:
		if state.squads[squad].battle_shocked: return false
		var positive_oc := false
		for model: int in Geometry.alive(state, squad):
			if int(state.units[model].get("objective_control", state.squads[squad].stats.objective_control)) > 0: positive_oc = true
		if not positive_oc: return false
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		if controlled and objective.controller != state.squads[squad].owner: continue
		for model: int in Geometry.alive(state, squad):
			if Objectives.in_range(state.units[model], objective): return true
	return false

static func seeker_of_the_unfound_active(state: Dictionary, model: int) -> bool:
	if not enabled(state) or not state.units.has(model) or identity(state.units[model]) != "vulkan-hestan": return false
	var selected: int = int(state.get("unit_abilities", {}).get("seeker_objectives", {}).get(model, -1))
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	if selected < 0 or selected >= objectives.size(): return false
	return Objectives.in_range(state.units[model], objectives[selected])

static func forgefather_target(state: Dictionary, owner: int) -> int:
	var record: Dictionary = state.get("unit_abilities", {}).get("forgefather_targets", {}).get(owner, {})
	return int(record.get("target", -1)) if record.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] else -1

static func hit_bonus(state: Dictionary, squad: int, target: int, melee: bool, model: int = -1, weapon: Dictionary = {}) -> int:
	var shrouded: Dictionary = state.get("unit_abilities", {}).get("shrouded_targets", {}).get(target, {})
	var shrouding_penalty := -1 if state.squads[target].owner != state.squads[squad].owner and shrouded.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] else 0
	var tempest_record: Dictionary = state.get("unit_abilities", {}).get("tempests_wrath_targets", {}).get(squad, {})
	var tempests_wrath_penalty := -1 if not tempest_record.is_empty() and int(state.turn) < int(tempest_record.get("expires_turn", -1)) else 0
	var obstinacy_penalty := -1 if has(state, target, "icon-of-obstinacy") else 0
	var braziers_penalty := -1 if melee and has(state, target, "braziers-of-judgement") else 0
	var angelic_visage_penalty := -1 if melee and has(state, target, "angelic-visage") else 0
	var character_bonus := 1 if has(state, squad, "emnity-for-the-unworthy") and has_target_keyword(state, target, "CHARACTER") else 0
	var inspirational_exemplar := 1 if melee and has(state, squad, "inspirational-exemplar") else 0
	var meteoric_descent := 1 if not melee and has(state, squad, "meteoric-descent") and state.squads[squad].get("move_type", "") == "ingress" else 0
	var outrider_hammer := 1 if melee and has(state, squad, "full-throttle-assault") and state.squads[squad].get("charged", false) and model >= 0 and identity(state.units[model]) == "outrider-squad" and str(weapon.get("name", "")) == "Thunder Hammer" else 0
	var ulrik_oathbound := UlrikTheSlayer.oathbound_hit_bonus(state, squad, melee)
	return Bladeguard.hit_modifier(state, squad, target, melee) + shrouding_penalty + tempests_wrath_penalty + obstinacy_penalty + braziers_penalty + angelic_visage_penalty + character_bonus + inspirational_exemplar + meteoric_descent + outrider_hammer + ulrik_oathbound + (1 if not melee and state.phase == "shooting" and state.active == state.squads[squad].owner and has(state, squad, "bolter-discipline") and (near_objective(state, squad) or near_objective(state, target)) else 0)

static func slayer_oath_targets(state: Dictionary, owner: int) -> Array[int]:
	return UlrikTheSlayer.initial_targets(state, owner)

static func slayer_oath_resolved(state: Dictionary, squad: int) -> bool:
	return UlrikTheSlayer.initial_resolved(state, squad)

static func slayer_oath_target(state: Dictionary, squad: int) -> int:
	return UlrikTheSlayer.selected_target(state, squad)

static func slayer_oath_active(state: Dictionary, squad: int, target: int) -> bool:
	return UlrikTheSlayer.targets_oath(state, squad, target)

static func slayer_oath_hit_bonus(state: Dictionary, squad: int, melee: bool) -> int:
	return UlrikTheSlayer.oathbound_hit_bonus(state, squad, melee)

static func slayer_oath_wound_bonus(state: Dictionary, squad: int, target: int, melee: bool) -> int:
	return UlrikTheSlayer.oathbound_wound_bonus(state, squad, target, melee)

static func melee_bonus(state: Dictionary, squad: int) -> int:
	return int(has(state, squad, "deeds-of-legend") and near_objective(state, squad)) + int(has(state, squad, "vanguard-assault") and state.squads[squad].get("charged", false)) + int(has(state, squad, "book-of-salvation")) + int(has(state, squad, "crusade-of-wrath"))

static func advance_modifier(state: Dictionary, squad: int) -> int:
	return int(has(state, squad, "angel-s-wrath")) + int(has(state, squad, "ravenwing-honour-or-death")) + int(ChaplainGrimaldus.active_relic(state, squad, "advance-and-charge")) + int(_space_wolves_fervour_active(state, squad))

static func charge_modifier(state: Dictionary, squad: int) -> int:
	return int(has(state, squad, "angel-s-wrath")) + int(has(state, squad, "ravenwing-honour-or-death")) + int(has(state, squad, "sigismunds-heir")) + int(has(state, squad, "savage-fury")) + int(ChaplainGrimaldus.active_relic(state, squad, "advance-and-charge")) + int(_space_wolves_fervour_active(state, squad))

static func _space_wolves_fervour_active(state: Dictionary, target_squad: int) -> bool:
	if not enabled(state) or not state.squads.has(target_squad): return false
	var owner := int(state.squads[target_squad].get("owner", -1))
	var target_is_space_wolves := str(state.get("marine_chapters", {}).get(owner, "")).strip_edges().to_upper() == "SPACE WOLVES"
	for target_model: int in Geometry.alive(state, target_squad):
		var keywords: Array = state.units[target_model].get("keywords", [])
		if "SPACE WOLVES" in keywords or ("ADEPTUS ASTARTES" in keywords and "SPACE WOLVES" in str(state.get("marine_chapters", {}).get(owner, "")).strip_edges().to_upper()): target_is_space_wolves = true
	if not target_is_space_wolves: return false
	for source_squad: int in state.squads:
		if int(state.squads[source_squad].get("owner", -2)) != owner or not has(state, source_squad, "fervour-of-the-ancients"): continue
		for source_model: int in Geometry.alive(state, source_squad):
			if identity(state.units[source_model]) != "venerable-dreadnought" or not state.units[source_model].get("on_battlefield", true): continue
			if Geometry.distance_to_target(state, state.units[source_model], target_squad) <= 6.001: return true
	return false

static func sammael_forces_desperate_escape(state: Dictionary, fleeing_squad: int) -> bool:
	return _forces_desperate_escape_from(state, fleeing_squad, ["cut-off-their-escape"])

static func savage_frenzy_forces_desperate_escape(state: Dictionary, fleeing_squad: int) -> bool:
	return _forces_desperate_escape_from(state, fleeing_squad, ["savage-frenzy"])

static func forces_desperate_escape(state: Dictionary, fleeing_squad: int) -> bool:
	return _forces_desperate_escape_from(state, fleeing_squad, ["cut-off-their-escape", "savage-frenzy"])

static func _forces_desperate_escape_from(state: Dictionary, fleeing_squad: int, ability_names: Array[String]) -> bool:
	if not enabled(state) or not state.squads.has(fleeing_squad) or _unit_has_keyword(state, fleeing_squad, "MONSTER") or _unit_has_keyword(state, fleeing_squad, "VEHICLE"): return false
	var fleeing_owner := int(state.squads[fleeing_squad].get("owner", -1))
	for source_squad: int in state.squads:
		if int(state.squads[source_squad].get("owner", -1)) == fleeing_owner: continue
		for ability_name: String in ability_names:
			for source_model: int in sources(state, source_squad, ability_name):
				for fleeing_model: int in Geometry.alive(state, fleeing_squad):
					if Geometry.within_engagement(state.units[source_model], state.units[fleeing_model]): return true
	return false

static func _unit_has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in Geometry.alive(state, squad):
		for item: Variant in state.units[model].get("keywords", []):
			if str(item).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func sammael_escape_hazard_modifiers(state: Dictionary, fleeing_squad: int, hazard_count: int) -> Array[int]:
	return forced_escape_hazard_modifiers(state, fleeing_squad, hazard_count, ["cut-off-their-escape"])

static func forced_escape_hazard_modifiers(state: Dictionary, fleeing_squad: int, hazard_count: int, ability_names: Array[String] = ["cut-off-their-escape", "savage-frenzy"]) -> Array[int]:
	var result: Array[int] = []
	if not state.squads.get(fleeing_squad, {}).get("battle_shocked", false) or not _forces_desperate_escape_from(state, fleeing_squad, ability_names): return result
	for _die in range(hazard_count): result.append(-1)
	return result

static func wulfen_death_totem_active(state: Dictionary, squad: int) -> bool:
	if not has(state, squad, "death-totem"): return false
	for model: int in Geometry.alive(state, squad):
		if identity(state.units[model]) in ["wulfen", "wulfen-with-storm-shields"] and bool(state.units[model].get("wulfen_death_totem", false)): return true
	return false

static func curse_of_the_wulfen_oc_bonus(state: Dictionary, model: int) -> int:
	if not enabled(state) or not state.units.has(model): return 0
	var unit: Dictionary = state.units[model]
	var squad := int(unit.get("squad", -1))
	if not state.squads.has(squad) or not has(state, squad, "curse-of-the-wulfen"): return 0
	var owner := int(unit.get("owner", -1))
	for candidate_model: int in state.units:
		var candidate: Dictionary = state.units[candidate_model]
		if int(candidate.get("owner", -2)) != owner or int(candidate.get("wounds", 0)) <= 0 or not candidate.get("on_battlefield", true): continue
		var keywords: Array = candidate.get("keywords", [])
		if "WULFEN" in keywords: continue
		var wolf_priest := "WOLF PRIEST" in keywords
		var space_wolves_character := "SPACE WOLVES" in keywords and "CHARACTER" in keywords
		if not wolf_priest and not space_wolves_character: continue
		for wulfen_model: int in Geometry.alive(state, squad):
			if not state.units[wulfen_model].get("on_battlefield", true): continue
			var distance := Geometry.edge(state.units[wulfen_model], candidate)
			if (space_wolves_character and distance <= 6.001) or (wolf_priest and distance <= 12.001):
				return 3 if "VEHICLE" in unit.get("keywords", []) else 1
	return 0

static func master_shadows_active(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var record: Dictionary = state.unit_abilities.get("master_shadows", {}).get(squad, {})
	return not record.is_empty() and int(record.get("owner", -1)) == int(state.squads[squad].owner) and state.turn <= int(record.get("turn", -2)) + 1

static func melee_attack_count(state: Dictionary, model: int, weapon: Dictionary) -> int:
	var bonus := melee_bonus(state, state.units[model].squad)
	bonus += RagnarBlackmane.battle_lust_attack_bonus(state, model)
	bonus += pious_fervour_bonus(state, model)
	if state.get("unit_abilities", {}).get("banner_active", {}).has(int(state.units[model].squad)): bonus += 1
	bonus += MarineEnhancements.standard_melee_attack_bonus(state, int(state.units[model].squad))
	return 1 if weapon.attacks is String else int(weapon.attacks) + bonus

static func tempered_ferocity_target_active(state: Dictionary, squad: int, target: int) -> bool:
	if not enabled(state) or not state.get("squads", {}).has(squad) or not state.get("squads", {}).has(target) or not has(state, squad, "tempered-ferocity"): return false
	for model: int in Geometry.alive(state, squad):
		if identity(state.units[model]) != "wolf-guard-battle-leader": continue
		if Geometry.distance_to_target(state, state.units[model], target) <= 6.001: return true
	return false

static func cunning_hunters_active(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("phase", "")) != "fight" or not has(state, squad, "cunning-hunters"): return false
	for model: int in Geometry.alive(state, squad):
		for objective: Dictionary in state.get("mission", {}).get("objectives", []):
			if Objectives.in_range(state.units[model], objective): return true
	return false

static func weapon(state: Dictionary, model: int, target: int, original: Dictionary, melee: bool) -> Dictionary:
	if not enabled(state): return original.duplicate(true)
	var copy := original.duplicate(true)
	var squad: int = state.units[model].squad
	if melee and has(state, squad, "violent-fury") and state.units[model].get("melee_weapons", []).size() >= 2:
		copy.keywords["twin-linked"] = true
	if melee and cunning_hunters_active(state, squad):
		copy.strength = int(copy.strength) + 1
		copy.ap = int(copy.ap) - 1
	if not melee and has(state, squad, "strategic-knowledge"): copy.keywords["assault"] = true
	if not melee and has(state, squad, "wind-walker"): copy.keywords["assault"] = true
	if melee and RagnarBlackmane.blood_claws_war_howl_active(state, squad):
		copy.strength += 1
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	var battle_lust_attacks := RagnarBlackmane.battle_lust_attack_bonus(state, model)
	if melee and battle_lust_attacks > 0: copy.attacks = RandomStat.add_bonus(copy.attacks, battle_lust_attacks)
	if has(state, squad, "tactical-instinct"): copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if has(state, squad, "tempered-ferocity"): copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if melee and has(state, squad, "fury-unbound"): copy.keywords["lethal-hits"] = true
	if melee and has(state, squad, "lost-to-fury"): copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if melee and has(state, squad, "mass-of-doom") and state.squads[squad].get("charged", false) and not has_target_keyword(state, target, "MONSTER") and not has_target_keyword(state, target, "VEHICLE"):
		copy.keywords["devastating-wounds"] = true
	if melee and ChaplainGrimaldus.active_relic(state, squad, "melee-ap"): copy.ap -= 1
	if has(state, squad, "supreme-grand-master"):
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if melee and has(state, squad, "knights-of-caliban") and state.squads[squad].get("charged", false):
		copy.keywords["anti-monster"] = maxi(4, int(copy.keywords.get("anti-monster", 0)))
		copy.keywords["anti-vehicle"] = maxi(4, int(copy.keywords.get("anti-vehicle", 0)))
	var forgefather_target_squad := forgefather_target(state, int(state.units[model].owner))
	if forgefather_target_squad == target and "ADEPTUS ASTARTES" in state.units[model].get("keywords", []) and (int(copy.keywords.get("melta", 0)) > 0 or copy.keywords.get("torrent", false)): copy.strength = int(copy.strength) + 2
	if melee and state.get("unit_abilities", {}).get("banner_active", {}).has(squad): copy.strength = int(copy.strength) + 1
	if melee and has(state, squad, "crusade-of-wrath"): copy.strength = int(copy.strength) + 1
	if melee and identity(state.units[model]) == "captain-titus":
		if state.get("unit_abilities", {}).get("used", {}).get("righteous-active:%d" % squad, false): copy.strength += 1
		var monster_or_vehicle := has_target_keyword(state, target, "MONSTER") or has_target_keyword(state, target, "VEHICLE")
		if not monster_or_vehicle or Doctrines.has_doctrine(state, squad, "assault"): copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if has(state, squad, "cold-and-calculating"):
		var selection := str(state.unit_abilities.get("used", {}).get("cold:%d:%s" % [squad, str(state.phase)], ""))
		var tactical := Doctrines.has_doctrine(state, squad, "tactical")
		var monster_or_vehicle := has_target_keyword(state, target, "MONSTER") or has_target_keyword(state, target, "VEHICLE")
		if monster_or_vehicle and (selection == "lethal" or tactical): copy.keywords["lethal-hits"] = true
		if not monster_or_vehicle and (selection == "sustained" or tactical): copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if identity(state.units[model]) == "suboden-khan" and not melee: copy.keywords.assault = true
	if has(state, squad, "for-the-khan"):
		if melee: copy.keywords.lance = true
		else: copy.keywords.assault = true
	if identity(state.units[model]) == "tor-garadon" and (has_target_keyword(state, target, "FORTIFICATION") or has_target_keyword(state, target, "MONSTER") or has_target_keyword(state, target, "VEHICLE")):
		copy.strength += 2
		copy.ap -= 2
		copy.damage = RandomStat.add_bonus(copy.damage, 2)
	if not melee and has(state, squad, "priority-target-acquisition") and Geometry.distance_to_target(state, state.units[model], target) <= 12.001:
		copy.strength += 1
	if not melee and has(state, squad, "hammerstrike") and target_within_terrain_area(state, squad, target):
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	var psychic_power := psychic_power_used(state, squad)
	if melee and psychic_power == "might-of-heroes": copy.strength = int(copy.strength) + 2
	if not melee and psychic_power == "thunderous-force": copy.range_inches = float(copy.range_inches) + 6.0
	var restricted: Dictionary = original.get("target_restricted_traits", {})
	for trait_name: String in restricted:
		if not copy.get("keywords", {}).has(trait_name): continue
		var excluded: Array = restricted[trait_name]
		var blocked := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: Variant in state.units[enemy].get("keywords", []):
				if str(keyword).strip_edges().to_upper() in excluded: blocked = true
		if blocked: copy.keywords.erase(trait_name)
	var required_traits: Dictionary = original.get("target_required_traits", {})
	for trait_name: String in required_traits:
		if not copy.get("keywords", {}).has(trait_name): continue
		var required_keywords: Array = required_traits[trait_name]
		var eligible := false
		for keyword: Variant in required_keywords:
			if has_target_keyword(state, target, str(keyword)):
				eligible = true
				break
		if not eligible: copy.keywords.erase(trait_name)
	if melee and melee_bonus(state, squad) > 0: copy.attacks = RandomStat.add_bonus(copy.attacks, 1)
	if melee and has(state, squad, "full-throttle-assault") and state.squads[squad].get("charged", false):
		copy.keywords["sustained-hits"] = 1
		if str(original.get("name", "")) != "Thunder Hammer": copy.damage = RandomStat.add_bonus(copy.damage, 1)
	if melee and has(state, squad, "thunderous-charge") and state.squads[squad].get("charged", false):
		copy.strength = int(copy.strength) + 1
		copy.damage = RandomStat.add_bonus(copy.damage, 1)
	if melee and has(state, squad, "litany-of-hate"): copy.keywords["lance"] = true
	if melee and has(state, squad, "into-the-fray") and state.squads[squad].get("charged", false):
		copy.keywords["cleave"] = maxi(1, int(copy.keywords.get("cleave", 0)))
	if melee and has(state, squad, "terminatus-assault") and state.squads[squad].get("charged", false):
		var monster_or_vehicle := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: Variant in state.units[enemy].get("keywords", []):
				if str(keyword).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: monster_or_vehicle = true
		var hammer := str(original.get("name", "")) == "Thunder Hammer"
		if hammer == monster_or_vehicle: copy.keywords["sustained-hits"] = 1
	if not melee and has(state, squad, "catechism-of-fire"):
		var catechism: Dictionary = state.unit_abilities.get("used", {}).get("catechism-fire:%d" % squad, {})
		if catechism.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] and int(catechism.get("target", -1)) == target:
			copy.keywords["devastating-wounds"] = true
	var optics := Detection.selection(state)
	if not melee and optics.get("squad", -1) == squad and optics.get("mode", "") == "cover": copy.keywords["ignores-cover"] = true
	if not melee and str(original.get("name", "")) == "Heavy Bolter" and has(state, squad, "overlapping-destruction") and state.phase == "shooting" and state.active == state.squads[squad].owner:
		var selected: Dictionary = state.unit_abilities.get("overlap_targets", {}).get(squad, {})
		if selected.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] and selected.get("target", -1) == target: copy.keywords.blast = maxi(1, int(copy.keywords.get("blast", 0)))
	if has(state, squad, "vivispectral-analysis-targeting"):
		var vehicle := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: String in state.units[enemy].get("keywords", []):
				if keyword.to_upper() == "VEHICLE": vehicle = true
		if not vehicle: copy.keywords["lethal-hits"] = true
	if has(state, squad, "close-quarters-firestorm"):
		for source: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target(state, state.units[source], target) <= 9.001:
				copy.strength += 1
				break
	if not melee and ignores_cover_mark(state, squad, target): copy.keywords["ignores-cover"] = true
	if not melee and shattered_defences_mark(state, squad, target): copy.ap -= 1
	if has(state, squad, "fury-of-the-first"):
		for source: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target(state, state.units[source], target) <= 9.001:
				copy.ap -= 1
				break
	if not melee and has(state, squad, "reaping-tally"):
		var excluded_target := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: String in state.units[enemy].get("keywords", []):
				if keyword.to_upper() in ["MONSTER", "VEHICLE"]: excluded_target = true
		if not excluded_target: copy.ap -= 1
	if melee and state.squads[squad].charged and has(state, squad, "targeted-intercession"):
		copy.strength += 1
		copy.ap -= 1
	if has(state, squad, "tactical-precision"):
		var heavy := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: String in state.units[enemy].get("keywords", []):
				if keyword.to_upper() in ["MONSTER", "VEHICLE"]: heavy = true
		if not heavy: copy.keywords["lethal-hits"] = true
	return copy

static func target_within_terrain_area(state: Dictionary, attacker: int, target: int) -> bool:
	if not state.squads.has(attacker) or not state.squads.has(target) or state.squads[attacker].owner == state.squads[target].owner: return false
	for enemy: int in Geometry.alive(state, target):
		for area: Dictionary in Terrain.model_areas(state, enemy):
			if area.get("category", "") != "legacy": return true
	return false

static func psychic_power_used(state: Dictionary, squad: int) -> String:
	if not enabled(state): return ""
	return str(state.unit_abilities.used.get("librarius:%d:%d" % [squad, state.round], ""))

static func ignores_cover_mark(state: Dictionary, squad: int, target: int) -> bool:
	if not state.squads.has(squad) or not state.squads.has(target): return false
	var friendly_astartes := false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): friendly_astartes = true
	if not friendly_astartes: return false
	var mark: Dictionary = state.get("unit_abilities", {}).get("cover_marks", {}).get(target, {})
	return mark.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] and mark.get("owner", -1) == state.squads[squad].owner

static func has_target_keyword(state: Dictionary, target: int, required: String) -> bool:
	for model: int in Geometry.alive(state, target):
		for keyword: Variant in state.units[model].get("keywords", []):
			if str(keyword).strip_edges().to_upper() == required.to_upper(): return true
	return false

static func has_living_unit_keyword(state: Dictionary, squad: int, required: String) -> bool:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) != squad or int(state.units[model].get("wounds", 0)) <= 0: continue
		for keyword: Variant in state.units[model].get("keywords", []):
			if str(keyword).strip_edges().to_upper() == required.to_upper(): return true
	return false

static func black_rage_support(state: Dictionary, squad: int) -> Dictionary:
	if not enabled(state) or not state.get("squads", {}).has(squad) or not has(state, squad, "black-rage"):
		return {}
	var members := Geometry.alive(state, squad)
	if members.is_empty(): return {}
	var owner := int(state.squads[squad].get("owner", -1))
	var near_blood_angels_character := false
	var near_chaplain := false
	for source_squad: int in state.squads:
		if int(state.squads[source_squad].get("owner", -1)) != owner or source_squad == squad: continue
		for source: int in Geometry.alive(state, source_squad):
			var model: Dictionary = state.units[source]
			if not model.get("on_battlefield", true): continue
			var identity_id := identity(model)
			var keywords: Array = model.get("keywords", [])
			var is_blood_angels := str(state.get("marine_chapters", {}).get(owner, "")).strip_edges().to_upper() == "BLOOD ANGELS" or "BLOOD ANGELS" in keywords
			if is_blood_angels and "CHARACTER" in keywords and Geometry.distance_to_target(state, model, squad) <= 6.001:
				near_blood_angels_character = true
			if (identity_id in CHAPLAIN_MODEL_IDENTITIES or "CHAPLAIN" in keywords) and Geometry.distance_to_target(state, model, squad) <= 12.001:
				near_chaplain = true
	return {"blood_angels_character": near_blood_angels_character, "chaplain": near_chaplain}

static func black_rage_restricted(state: Dictionary, squad: int) -> bool:
	var support := black_rage_support(state, squad)
	if support.is_empty(): return false
	return not bool(support.blood_angels_character) or not bool(support.chaplain)

static func shattered_defences_mark(state: Dictionary, squad: int, target: int) -> bool:
	if not state.squads.has(squad) or not state.squads.has(target) or state.squads[squad].owner == state.squads[target].owner: return false
	var mark: Dictionary = state.get("unit_abilities", {}).get("shattered_defences_marks", {}).get(target, {})
	var source := int(mark.get("source", -1))
	if not state.squads.has(source): return false
	var astartes := false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): astartes = true
	if not astartes: return false
	return mark.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] and mark.get("owner", -1) == state.squads[squad].owner and mark.get("owner", -1) == state.squads[source].owner

static func offer_cover_target(state: Dictionary, squad: int, prepared: Dictionary, resolved: Dictionary, melee: bool) -> void:
	if melee or state.phase != "shooting" or state.active != state.squads[squad].owner: return
	var window_kind := "driven-from-cover" if prepared.get("driven_from_cover", false) else "hailstrike" if prepared.get("hailstrike", false) else "shattered-defences" if prepared.get("shattered_defences", false) else ""
	if window_kind.is_empty(): return
	var targets: Array[int] = []
	for pool: Dictionary in resolved.pools:
		var target: int = pool.target_squad
		if int(pool.get("hits", 0)) > 0 and target not in targets and not Geometry.alive(state, target).is_empty():
			if window_kind == "shattered-defences" and not (has_target_keyword(state, target, "MONSTER") or has_target_keyword(state, target, "VEHICLE")): continue
			targets.append(target)
	if not targets.is_empty(): state.unit_abilities.window = {"kind": window_kind, "owners": [state.squads[squad].owner], "targets": targets, "source": squad}

static func hazard_modifier(state: Dictionary, squad: int, weapon_id: String) -> int:
	return 1 if has(state, squad, "rites-of-thermal-appeasement") and weapon_id in ["plasma-incinerator", "plasma-pistol"] else 0

static func save_bonus(state: Dictionary, squad: int, control_value: Callable) -> int:
	var prescience: Dictionary = state.get("unit_abilities", {}).get("tigurius_prescience", {}).get(squad, {})
	var bonus := 1 if not prescience.is_empty() and state.turn <= int(prescience.get("expires_turn", -1)) else 0
	if not has(state, squad, "unyielding-in-the-face-of-the-foe"): return bonus
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		if objective.get("controller", 0) == state.squads[squad].owner and squad in Objectives.controlling_squads(state, objective, control_value): return bonus + 1
	return bonus

static func defensive_wound_modifier(state: Dictionary, target: int, strength: int, toughness: int, melee: bool = false) -> int:
	if not melee and has(state, target, "lightning-fast-manoeuvres"): return -1
	if has(state, target, "command-squad"): return -1
	if has(state, target, "honour-guard-of-macragge"): return -1
	if strength <= toughness: return 0
	if has(state, target, "legendary-tenacity"): return -1
	if has(state, target, "rugged-resilience"): return -1
	if has(state, target, "heirs-of-azkaellon"): return -1
	if MarineEnhancements.active(state, target, MarineEnhancements.INDEFATIGABLE_FORTITUDE): return -1
	if Doctrines.indomitable_defence(state, target): return -1
	if Doctrines.dutiful_tenacity(state, target): return -1
	if has(state, target, "rites-of-tempering"): return -1
	if has(state, target, "duty-eternal"): return -1
	if strength > toughness and has(state, target, "emperors-shield"): return -1
	return -1 if has(state, target, "never-shall-the-standard-fall") and near_objective(state, target) else 0

static func aggressive_reconnaissance_active(state: Dictionary, squad: int, target: int) -> bool:
	if not enabled(state) or not state.squads.has(squad) or not state.squads.has(target): return false
	if not has(state, squad, "aggressive-reconnaissance") or state.phase != "shooting" or state.active != state.squads[squad].owner: return false
	if state.squads[target].owner == state.squads[squad].owner or Geometry.alive(state, target).is_empty(): return false
	for other: int in state.squads:
		if other == target or state.squads[other].owner != state.squads[target].owner: continue
		for model: int in Geometry.alive(state, target):
			if Geometry.distance_to_target(state, state.units[model], other) <= 6.001: return false
	return true

static func cover_denial_mark_active(state: Dictionary, owner: int, target: int) -> bool:
	var mark: Dictionary = state.get("unit_abilities", {}).get("signum_targets", {}).get(target, {})
	return mark.get("phase_key", "") == "%d:%s" % [state.turn, state.phase] and int(mark.get("owner", -1)) == owner and state.phase == "shooting"

static func signum_array_active(state: Dictionary, owner: int, target: int) -> bool:
	return cover_denial_mark_active(state, owner, target)

static func rampart_active(state: Dictionary, model: int) -> bool:
	if not enabled(state) or model not in state.get("units", {}) or identity(state.units[model]) != "darnath-lysander": return false
	var mark: Dictionary = state.get("unit_abilities", {}).get("rampart_active", {}).get(model, {})
	return mark.get("phase_key", "") == "%d:%s" % [state.turn, state.phase]

static func damage(state: Dictionary, model: int, amount: int, damage_kind: String = "normal") -> int:
	if amount <= 0 or not state.get("units", {}).has(model): return amount
	var reduced := amount
	if enabled(state) and identity(state.units[model]) in ["overlord", "captain-in-gravis-armour"]: reduced -= 1
	if damage_kind == "normal" and enabled(state) and has(state, int(state.units[model].get("squad", -1)), "guardian-of-the-lost"): reduced -= 1
	if damage_kind == "normal" and enabled(state) and identity(state.units[model]) == "emperor-s-champion" and has(state, int(state.units[model].get("squad", -1)), "armour-of-faith"): reduced -= 1
	if damage_kind == "normal" and enabled(state) and has(state, int(state.units[model].get("squad", -1)), "inner-circle"): reduced -= 1
	if MarineEnhancements.artificer_sarcophagus_active(state, int(state.units[model].squad)): reduced -= 1
	var pending_attack: Dictionary = state.get("pending_attack", {})
	var prepared_attack: Dictionary = pending_attack.get("prepared", {})
	var fortitude_targets: Variant = prepared_attack.get("terminator_fortitude_targets", [])
	if fortitude_targets is Array and int(state.units[model].get("squad", -1)) in fortitude_targets: reduced -= 1
	return maxi(1, reduced) if reduced < amount else amount

static func damaged_attack_penalty(state: Dictionary, model: int) -> int:
	if not enabled(state) or model not in state.get("units", {}): return 0
	var unit: Dictionary = state.units[model]
	var threshold := int(MarineProfiles.profile(identity(unit)).get("damaged_threshold", 0))
	var identity_rules: Array = RULES.get(identity(unit), [])
	return -1 if threshold > 0 and ("damaged-5" in identity_rules or "damaged-4" in identity_rules or "damaged-3" in identity_rules) and int(unit.get("wounds", 0)) > 0 and int(unit.wounds) <= threshold else 0

static func discount(state: Dictionary, player: int, squad: int) -> int:
	if not enabled(state): return 0
	if has(state, squad, "ancient-tactician") and int(state.unit_abilities.used.get("ancient-tactician:%d" % player, -1)) != int(state.turn): return 1
	return 1 if has(state, squad, "my-will-be-done") and state.unit_abilities.discount_armed.get(squad, -1) == state.round and state.unit_abilities.discounts.get(player, -1) != state.round else 0

static func consume_discount(state: Dictionary, player: int, squad: int) -> void:
	if discount(state, player, squad) == 0: return
	if has(state, squad, "ancient-tactician") and int(state.unit_abilities.used.get("ancient-tactician:%d" % player, -1)) != int(state.turn):
		state.unit_abilities.used["ancient-tactician:%d" % player] = int(state.turn)
		return
	state.unit_abilities.discounts[player] = state.round
	state.unit_abilities.discount_armed.erase(squad)

static func doctrine(state: Dictionary, squad: int) -> String:
	return AbilityCatalog.doctrine(state, squad)
static func additional_doctrines(state: Dictionary, squad: int) -> Array[String]:
	return AbilityCatalog.additional_doctrines(state, squad)
static func primarch_aura_active(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = state.squads[squad].owner
	var astartes := false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"):
			astartes = true
			break
	if not astartes: return false
	for source_squad: int in state.squads:
		if state.squads[source_squad].owner != owner: continue
		for model: int in Geometry.alive(state, source_squad):
			if identity(state.units[model]) != "roboute-guilliman": continue
			if Geometry.distance_to_target(state, state.units[model], squad) <= 6.001: return true
	return false

static func lion_primarch_selected(state: Dictionary, squad: int, ability: String) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var record: Dictionary = state.unit_abilities.get("lion_primarch", {}).get(squad, {})
	return ability in record.get("abilities", []) and int(record.get("owner", -1)) == int(state.squads[squad].owner)

static func lion_aura_active(state: Dictionary, target_squad: int, ability: String) -> bool:
	if not enabled(state) or not state.squads.has(target_squad) or not _friendly_dark_angel_unit(state, target_squad): return false
	var owner: int = int(state.squads[target_squad].owner)
	for source_squad: int in state.squads:
		if int(state.squads[source_squad].owner) != owner or not lion_primarch_selected(state, source_squad, ability): continue
		for model: int in Geometry.alive(state, source_squad):
			if identity(state.units[model]) != "lion-eljonson" or not state.units[model].get("on_battlefield", true): continue
			if Geometry.distance_to_target(state, state.units[model], target_squad) <= 6.001: return true
	return false

static func _friendly_dark_angel_unit(state: Dictionary, squad: int) -> bool:
	var owner := int(state.squads[squad].get("owner", -1))
	if str(state.get("marine_chapters", {}).get(owner, "")).strip_edges().to_upper() == "DARK ANGELS":
		for model: int in Geometry.alive(state, squad):
			if "ADEPTUS ASTARTES" in state.units[model].get("keywords", []): return true
	for model: int in Geometry.alive(state, squad):
		var keywords: Array = state.units[model].get("keywords", [])
		if "ADEPTUS ASTARTES" in keywords and "DARK ANGELS" in keywords: return true
	return false

static func lone_operative_active(state: Dictionary, model: int) -> bool:
	if not enabled(state) or not state.units.has(model): return false
	var own_squad: int = int(state.units[model].squad)
	if identity(state.units[model]) in ["techmarine", "iron-father-feirros", "iron-priest"]: return Techmarine.lone_operative_active(state, model)
	if has(state, own_squad, "lone-operative") and not state.squads[own_squad].get("attached", false): return true
	if identity(state.units[model]) == "lion-eljonson":
		var owner: int = int(state.units[model].owner)
		for friendly_squad: int in state.squads:
			if int(state.squads[friendly_squad].owner) != owner or not _friendly_dark_angel_unit(state, friendly_squad) or friendly_squad == own_squad: continue
			var has_infantry := false
			for friendly_model: int in Geometry.alive(state, friendly_squad):
				if "INFANTRY" in state.units[friendly_model].get("keywords", []): has_infantry = true
			if has_infantry and Geometry.distance_to_target(state, state.units[model], friendly_squad) <= 3.001: return true
		return false
	if identity(state.units[model]) != "roboute-guilliman": return false
	var owner: int = state.units[model].owner
	for friendly_squad: int in state.squads:
		if state.squads[friendly_squad].owner != owner: continue
		for friendly_model: int in Geometry.alive(state, friendly_squad):
			if friendly_model == model or not str(state.units[friendly_model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): continue
			if "INFANTRY" not in state.units[friendly_model].get("keywords", []): continue
			if Geometry.distance_to_target(state, state.units[model], friendly_squad) <= 3.001: return true
	return false

static func lone_operative_range(state: Dictionary, model: int) -> float:
	if not lone_operative_active(state, model): return 0.0
	return 15.0 if identity(state.units[model]) == "ravenwing-darkshroud" else 12.0

static func start_command(state: Dictionary) -> void:
	if not enabled(state): return
	for squad: int in state.unit_abilities.get("tigurius_prescience", {}).keys():
		if int(state.unit_abilities.tigurius_prescience[squad].get("expires_turn", -1)) <= state.turn: state.unit_abilities.tigurius_prescience.erase(squad)
	for squad: int in state.unit_abilities.get("force_dome", {}).keys():
		if int(state.unit_abilities.force_dome[squad].get("expires_turn", -1)) <= state.turn: state.unit_abilities.force_dome.erase(squad)
	for squad: int in state.unit_abilities.get("veil_of_time_pending", {}).keys():
		if state.squads.has(squad) and state.squads[squad].owner == state.active: state.unit_abilities.veil_of_time_pending.erase(squad)
	for squad: int in state.unit_abilities.doctrines.keys():
		if state.squads[squad].owner == state.active: state.unit_abilities.doctrines.erase(squad)
	for squad: int in state.unit_abilities.additional_doctrines.keys():
		if state.squads.has(squad) and state.squads[squad].owner == state.active: state.unit_abilities.additional_doctrines.erase(squad)
	for squad: int in state.unit_abilities.get("lion_primarch", {}).keys():
		if state.squads.has(squad) and int(state.squads[squad].owner) == int(state.active): state.unit_abilities.lion_primarch.erase(squad)
	for squad: int in state.unit_abilities.get("lion_primarch_pending", {}).keys():
		if state.squads.has(squad) and int(state.squads[squad].owner) == int(state.active): state.unit_abilities.lion_primarch_pending.erase(squad)

static func implacable_mode(state: Dictionary, squad: int, target: int) -> String:
	if not has(state, squad, "implacable-eradication"): return "none"
	return "failed" if near_objective(state, target) else "ones"

static func potential_discount(state: Dictionary, player: int, squad: int) -> int:
	if not enabled(state): return 0
	if has(state, squad, "ancient-tactician") and int(state.unit_abilities.used.get("ancient-tactician:%d" % player, -1)) != int(state.turn): return 1
	return 1 if has(state, squad, "my-will-be-done") and state.unit_abilities.discounts.get(player, -1) != state.round else 0

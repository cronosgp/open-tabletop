extends RefCounted
## Current e11 datasheet effects; fixed-loadout training, not list certification.
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Bladeguard = preload("res://scripts/edition_11/bladeguard.gd")
const CombiLieutenant = preload("res://scripts/edition_11/combi_lieutenant.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const ID := AbilityCatalog.ID
const RULES := AbilityCatalog.RULES
const TRANSPORT_DEADLY_DEMISE := {
	"land-raider": "D6",
	"land-raider-crusader": "D6",
	"land-raider-redeemer": "D6",
	"drop-pod": 1,
	"impulsor": "D3",
	"repulsor": "D6",
	"repulsor-executioner": "D6",
	"rhino": "D3",
}
static func identity(unit: Dictionary) -> String:
	return AbilityCatalog.identity(unit)
static func enabled(state: Dictionary) -> bool:
	return AbilityCatalog.enabled(state)
static func sources(state: Dictionary, squad: int, name: String) -> Array[int]:
	return AbilityCatalog.sources(state, squad, name)
static func every_model_has(state: Dictionary, squad: int, name: String) -> bool:
	var alive := Geometry.alive(state, squad)
	return not alive.is_empty() and sources(state, squad, name).size() == alive.size()

static func scout_distance(state: Dictionary, squad: int) -> int:
	if not enabled(state): return 0
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
		var current := 8 if identity(state.units[model]) == "invictor-tactical-warsuit" else 6 if identity(state.units[model]) == "impulsor" and state.units[model].get("impulsor_system", "none") == "orbital-comms-array" else 6 if identity(state.units[model]) in ["lieutenant-in-phobos-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "scout-squad", "incursor-squad", "reiver-squad"] else 0
		if current <= 0: return 0
		if distance < 0: distance = current
		elif distance != current: return 0
	return distance

static func forward_assault_targets(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == owner: continue
		for model: int in state.units:
			if state.units[model].squad == squad and state.units[model].wounds > 0:
				result.append(squad)
				break
	return result

static func forward_assault_mark(state: Dictionary, squad: int) -> int:
	return int(state.get("unit_abilities", {}).get("forward_assault_marks", {}).get(squad, -1))

static func set_forward_assault_mark(state: Dictionary, squad: int, target: int) -> String:
	if not state.squads.has(squad) or not has(state, squad, "forward-assault-warsuit"): return "Forward Assault Warsuit requires an Invictor Tactical Warsuit."
	if target not in forward_assault_targets(state, int(state.squads[squad].owner)): return "Select a living enemy unit as this Invictor's mark."
	if not state.unit_abilities.has("forward_assault_marks"): state.unit_abilities.forward_assault_marks = {}
	state.unit_abilities.forward_assault_marks[squad] = target
	return ""

static func open_destroyed_mark_replacements(state: Dictionary) -> bool:
	var queue: Array[int] = []
	var previous_window: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	for source: Variant in state.get("unit_abilities", {}).get("forward_assault_marks", {}).keys():
		var squad := int(source)
		if not state.squads.has(squad) or not has(state, squad, "forward-assault-warsuit"):
			state.unit_abilities.forward_assault_marks.erase(squad)
			continue
		var target := forward_assault_mark(state, squad)
		var target_alive := false
		for model: int in state.units:
			if state.units[model].squad == target and state.units[model].wounds > 0: target_alive = true
		if target_alive or target < 0: continue
		if forward_assault_targets(state, int(state.squads[squad].owner)).is_empty():
			state.unit_abilities.forward_assault_marks.erase(squad)
		else: queue.append(squad)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": "forward-assault-mark", "owners": [state.squads[queue[0]].owner], "queue": queue, "source_squad": queue[0]}
	if not previous_window.is_empty(): state.unit_abilities.window.resume_window = previous_window
	return true

static func advance_destroyed_mark_queue(state: Dictionary, selected_squad: int, target: int) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "forward-assault-mark" or int(window.get("source_squad", -1)) != selected_squad: return "No Invictor mark replacement is pending."
	var error := set_forward_assault_mark(state, selected_squad, target)
	if not error.is_empty(): return error
	var queue: Array = window.get("queue", [])
	if not queue.is_empty(): queue.pop_front()
	if queue.is_empty(): state.unit_abilities.window = window.get("resume_window", {})
	else:
		window.queue = queue
		window.source_squad = int(queue[0])
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
	if "transport-deadly-demise" in abilities: return TRANSPORT_DEADLY_DEMISE.get(unit_identity)
	return null
static func enable(state: Dictionary) -> void:
	state.unit_abilities = {"implementation": ID, "used": {}, "doctrines": {}, "additional_doctrines": {}, "discounts": {}, "discount_armed": {}, "phase_start": -1, "end_done": "", "window": {}, "reserves": {}, "homers": {}, "force_dome": {}, "veil_of_time_pending": {}, "master_shadows": {}, "thunderhawk_targets": {}, "seeker_objectives": {}, "forgefather_targets": {}, "weapon_skill_characteristic_modifiers": {"squads": {}, "models": {}}, "setup_done": false}
	for squad: int in state.squads:
		state.squads[squad].disabled_abilities = []
		for model: int in Geometry.alive(state, squad):
			if identity(state.units[model]) == "overlord": state.units[model].wargear = ["resurrection-orb"]
			if identity(state.units[model]) == "terminator-squad": state.units[model].erase("melee_weapons")
			if identity(state.units[model]) in ["roboute-guilliman", "lieutenant-with-combi-weapon", "iron-father-feirros", "caanok-var"]:
				var prevention: Array = state.units[model].get("feel_no_pain", [])
				var has_personal_fnp := false
				var fnp_target := 6 if identity(state.units[model]) == "roboute-guilliman" else 5
				for rule: Dictionary in prevention:
					if rule.get("target") == fnp_target and rule.get("against") == "any": has_personal_fnp = true
				if not has_personal_fnp: prevention.append({"target": fnp_target, "against": "any"})
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
	var obstinacy_penalty := -1 if has(state, target, "icon-of-obstinacy") else 0
	var meteoric_descent := 1 if not melee and has(state, squad, "meteoric-descent") and state.squads[squad].get("move_type", "") == "ingress" else 0
	var outrider_hammer := 1 if melee and has(state, squad, "full-throttle-assault") and state.squads[squad].get("charged", false) and model >= 0 and identity(state.units[model]) == "outrider-squad" and str(weapon.get("name", "")) == "Thunder Hammer" else 0
	return Bladeguard.hit_modifier(state, squad, target, melee) + shrouding_penalty + obstinacy_penalty + meteoric_descent + outrider_hammer + (1 if not melee and state.phase == "shooting" and state.active == state.squads[squad].owner and has(state, squad, "bolter-discipline") and (near_objective(state, squad) or near_objective(state, target)) else 0)

static func melee_bonus(state: Dictionary, squad: int) -> int:
	return int(has(state, squad, "deeds-of-legend") and near_objective(state, squad)) + int(has(state, squad, "vanguard-assault") and state.squads[squad].get("charged", false))

static func advance_modifier(state: Dictionary, squad: int) -> int:
	return 1 if has(state, squad, "angel-s-wrath") else 0

static func charge_modifier(state: Dictionary, squad: int) -> int:
	return 1 if has(state, squad, "angel-s-wrath") else 0

static func master_shadows_active(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var record: Dictionary = state.unit_abilities.get("master_shadows", {}).get(squad, {})
	return not record.is_empty() and int(record.get("owner", -1)) == int(state.squads[squad].owner) and state.turn <= int(record.get("turn", -2)) + 1

static func melee_attack_count(state: Dictionary, model: int, weapon: Dictionary) -> int:
	var bonus := melee_bonus(state, state.units[model].squad)
	if state.get("unit_abilities", {}).get("banner_active", {}).has(int(state.units[model].squad)): bonus += 1
	bonus += MarineEnhancements.standard_melee_attack_bonus(state, int(state.units[model].squad))
	return 1 if weapon.attacks is String else int(weapon.attacks) + bonus

static func weapon(state: Dictionary, model: int, target: int, original: Dictionary, melee: bool) -> Dictionary:
	if not enabled(state): return original.duplicate(true)
	var copy := original.duplicate(true)
	var squad: int = state.units[model].squad
	var forgefather_target_squad := forgefather_target(state, int(state.units[model].owner))
	if forgefather_target_squad == target and "ADEPTUS ASTARTES" in state.units[model].get("keywords", []) and (int(copy.keywords.get("melta", 0)) > 0 or copy.keywords.get("torrent", false)): copy.strength = int(copy.strength) + 2
	if melee and state.get("unit_abilities", {}).get("banner_active", {}).has(squad): copy.strength = int(copy.strength) + 1
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
	if melee and melee_bonus(state, squad) > 0: copy.attacks = RandomStat.add_bonus(copy.attacks, 1)
	if melee and has(state, squad, "full-throttle-assault") and state.squads[squad].get("charged", false):
		copy.keywords["sustained-hits"] = 1
		if str(original.get("name", "")) != "Thunder Hammer": copy.damage = RandomStat.add_bonus(copy.damage, 1)
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
	if not melee and original.get("name", "") == "Instigator Bolt Carbine":
		var heavy := false
		for enemy: int in Geometry.alive(state, target):
			for keyword: String in state.units[enemy].get("keywords", []):
				if keyword.to_upper() in ["MONSTER", "VEHICLE"]: heavy = true
		if not heavy: copy.keywords["lethal-hits"] = true
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

static func defensive_wound_modifier(state: Dictionary, target: int, strength: int, toughness: int) -> int:
	if has(state, target, "command-squad"): return -1
	if has(state, target, "honour-guard-of-macragge"): return -1
	if strength <= toughness: return 0
	if MarineEnhancements.active(state, target, MarineEnhancements.INDEFATIGABLE_FORTITUDE): return -1
	if Doctrines.indomitable_defence(state, target): return -1
	if Doctrines.dutiful_tenacity(state, target): return -1
	if has(state, target, "rites-of-tempering"): return -1
	if has(state, target, "duty-eternal"): return -1
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

static func damage(state: Dictionary, model: int, amount: int) -> int:
	if amount <= 0 or not state.get("units", {}).has(model): return amount
	var reduced := amount
	if enabled(state) and identity(state.units[model]) in ["overlord", "captain-in-gravis-armour"]: reduced -= 1
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
	return -1 if threshold > 0 and "damaged-4" in RULES.get(identity(unit), []) and int(unit.get("wounds", 0)) > 0 and int(unit.wounds) <= threshold else 0

static func discount(state: Dictionary, player: int, squad: int) -> int:
	return 1 if enabled(state) and has(state, squad, "my-will-be-done") and state.unit_abilities.discount_armed.get(squad, -1) == state.round and state.unit_abilities.discounts.get(player, -1) != state.round else 0

static func consume_discount(state: Dictionary, player: int, squad: int) -> void:
	if discount(state, player, squad) == 0: return
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

static func lone_operative_active(state: Dictionary, model: int) -> bool:
	if not enabled(state) or not state.units.has(model): return false
	var own_squad: int = int(state.units[model].squad)
	if identity(state.units[model]) in ["techmarine", "iron-father-feirros"]: return Techmarine.lone_operative_active(state, model)
	if has(state, own_squad, "lone-operative") and not state.squads[own_squad].get("attached", false): return true
	if identity(state.units[model]) != "roboute-guilliman": return false
	var owner: int = state.units[model].owner
	for friendly_squad: int in state.squads:
		if state.squads[friendly_squad].owner != owner: continue
		for friendly_model: int in Geometry.alive(state, friendly_squad):
			if friendly_model == model or not str(state.units[friendly_model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): continue
			if "INFANTRY" not in state.units[friendly_model].get("keywords", []): continue
			if Geometry.distance_to_target(state, state.units[model], friendly_squad) <= 3.001: return true
	return false

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

static func implacable_mode(state: Dictionary, squad: int, target: int) -> String:
	if not has(state, squad, "implacable-eradication"): return "none"
	return "failed" if near_objective(state, target) else "ones"

static func potential_discount(state: Dictionary, player: int, squad: int) -> int:
	return 1 if has(state, squad, "my-will-be-done") and state.unit_abilities.discounts.get(player, -1) != state.round else 0

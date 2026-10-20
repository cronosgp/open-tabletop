extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Current 11e army rule plus the explicitly declared Space Marine detachment effects.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ID := "combat-doctrines-11e-gladius-v1"
const REFERENCE := "https://wahapedia.ru/wh40k11ed/factions/space-marines/#Combat-Doctrines"
const NAMES := {"none": "No doctrine this turn", "devastator": "Devastator: shoot after Advance", "tactical": "Tactical: shoot and charge after Fall Back", "assault": "Assault: charge after Advance"}
const ORDER := ["devastator", "tactical", "assault"]
const DETACHMENT_EXTRA_DOCTRINE := {"assault-brethren": "assault", "tactical-brethren": "tactical", "devastator-brethren": "devastator"}
const CHAPTER_KEYWORDS := ["ULTRAMARINES", "WHITE SCARS", "IRON HANDS", "IMPERIAL FISTS", "SALAMANDERS", "DARK ANGELS", "BLOOD ANGELS", "SPACE WOLVES", "BLACK TEMPLARS", "DEATHWATCH", "RAVEN GUARD"]

static func enable(state: Dictionary, detachment: Variant = "gladius") -> void:
	# Preserve callers from the older bool API while prepared setup migrates to names.
	if detachment is bool: detachment = "gladius" if detachment else "none"
	var selected_detachment := str(detachment)
	var owners: Array[int] = []
	for owner in [1, 2]:
		if Marines.marine_army(state, owner): owners.append(owner)
	state.combat_doctrines = {"implementation": ID, "owners": owners, "detachment": selected_detachment, "gladius": selected_detachment == "gladius", "stormlance": selected_detachment == "stormlance", "ironclad_champions": selected_detachment == "ironclad-champions", "ironstorm_spearhead": selected_detachment == "ironstorm-spearhead", "extra_used": {}, "active": {}, "used": {}, "selected_turn": {}, "spearpoint_destroyed_units": {}}
	state.marine_enhancements = {"standard_used": {}, "standard_active": {}}
	Capabilities.admit(state, "combat-doctrines", ID)
	if selected_detachment == "gladius": Capabilities.admit(state, "codex-discipline", ID)
	if selected_detachment == "stormlance": Capabilities.admit(state, "lightning-fast-strike", ID)
	if selected_detachment == "ironclad-champions": Capabilities.admit(state, "enduring-vengeance", ID)
	if selected_detachment == "ironstorm-spearhead": Capabilities.admit(state, "ironstorm-auto-targeters", ID)
	if selected_detachment == "phobos-shock-force": Capabilities.admit(state, "vanguard-ambushers", ID)
	if selected_detachment == "terminator-storm-force": Capabilities.admit(state, "death-blow", ID)
	if selected_detachment == "tacticus-firestorm-force": Capabilities.admit(state, "codex-fire-patterns", ID)
	if selected_detachment == "tacticus-attack-force": Capabilities.admit(state, "wrath-of-the-chapter", ID)
	if selected_detachment == "gravis-linebreaker-force": Capabilities.admit(state, "walking-fortress", ID)
	if selected_detachment == "wrath-of-the-rock": Capabilities.admit(state, "dutiful-tenacity", ID)
	if selected_detachment == "spearpoint-task-force": Capabilities.admit(state, "storm-swift-onslaught", ID)
	if selected_detachment in DETACHMENT_EXTRA_DOCTRINE:
		var capability := str(selected_detachment) + "-mastery"
		Capabilities.admit(state, capability, ID)
	for squad: int in state.squads:
		if state.squads[squad].owner in owners: Capabilities.admit_squad(state, squad, "combat-doctrines")

static func enabled(state: Dictionary) -> bool:
	return state.get("combat_doctrines", {}).get("implementation", "") == ID

static func chapter_restriction_error(state: Dictionary, detachment: String) -> String:
	if detachment != "spearpoint-task-force": return ""
	var profile_cache: Dictionary = {}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.get("wounds", 0) <= 0: continue
		var identity := UnitAbilities.identity(unit)
		if not profile_cache.has(identity): profile_cache[identity] = MarineProfiles.profile(identity)
		var profile: Dictionary = profile_cache[identity]
		var keywords: Array = profile.get("keywords", unit.get("keywords", []))
		if "ADEPTUS ASTARTES" not in keywords: continue
		for chapter: String in CHAPTER_KEYWORDS:
			if chapter != "WHITE SCARS" and chapter in keywords:
				return "Spearpoint Task Force cannot include Adeptus Astartes units from %s." % chapter
	return ""

static func available(state: Dictionary, player: int) -> Array[String]:
	var result: Array[String] = []
	if not enabled(state) or player not in state.combat_doctrines.owners or not Marines.marine_army(state, player): return result
	for doctrine: String in ORDER:
		var used: Array = state.combat_doctrines.used.get(player, [])
		var fixed_extra: bool = DETACHMENT_EXTRA_DOCTRINE.get(str(state.combat_doctrines.detachment), "") == doctrine
		var extra_available: bool = (fixed_extra or state.combat_doctrines.gladius) and not state.combat_doctrines.extra_used.get(player, false)
		if doctrine not in used or (used.count(doctrine) == 1 and extra_available): result.append(doctrine)
	return result

static func start_command(state: Dictionary) -> void:
	if enabled(state): state.combat_doctrines.active.erase(state.active)

static func needs_choice(state: Dictionary) -> bool:
	return enabled(state) and state.get("test_winner", 0) == 0 and state.phase == "command" and state.combat_doctrines.selected_turn.get(state.active, -1) != state.turn and not available(state, state.active).is_empty()

static func choice_error(state: Dictionary, player: int, doctrine: String, revision: int) -> String:
	if not needs_choice(state): return "No Combat Doctrine decision is pending."
	if revision != state.revision: return "State changed; synchronize before selecting a doctrine."
	if player != state.active: return "Only the active Space Marine player selects the doctrine."
	if doctrine != "none" and doctrine not in available(state, player): return "Choose an unused Combat Doctrine or no doctrine."
	return ""

static func select_doctrine(state: Dictionary, player: int, doctrine: String) -> void:
	state.combat_doctrines.selected_turn[player] = state.turn
	if doctrine == "none": return
	state.combat_doctrines.active[player] = doctrine
	record_selection(state, player, doctrine)

## Record every rule-driven doctrine selection against the shared once-per-battle limit.
## Unit abilities can activate the doctrine locally without changing the army-wide active doctrine.
static func record_selection(state: Dictionary, player: int, doctrine: String) -> void:
	if not state.combat_doctrines.used.has(player): state.combat_doctrines.used[player] = []
	if doctrine in state.combat_doctrines.used[player]: state.combat_doctrines.extra_used[player] = true
	state.combat_doctrines.used[player].append(doctrine)

static func active_for(state: Dictionary, squad: int) -> String:
	if not UnitAbilities.doctrine(state, squad).is_empty(): return UnitAbilities.doctrine(state, squad)
	if not enabled(state) or not state.squads.has(squad): return ""
	var owner: int = state.squads[squad].owner
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return ""
	return str(state.combat_doctrines.active.get(owner, ""))

## Some current datasheets maintain or gain doctrines alongside their normal selection.
## Keep the army-wide/override lookup intact and expose the combined effects separately.
static func active_doctrines_for(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	var selected := active_for(state, squad)
	if selected in ORDER: result.append(selected)
	for doctrine: String in UnitAbilities.additional_doctrines(state, squad):
		if doctrine in ORDER and doctrine not in result: result.append(doctrine)
	for doctrine: String in MarineEnhancements.additional_doctrines(state, squad):
		if doctrine in ORDER and doctrine not in result: result.append(doctrine)
	if UnitAbilities.has(state, squad, "codex-adept"):
		for doctrine: String in ORDER:
			if doctrine not in result: result.append(doctrine)
	return result

static func has_doctrine(state: Dictionary, squad: int, doctrine: String) -> bool:
	return doctrine in active_doctrines_for(state, squad)

static func weapon(state: Dictionary, squad: int, profile: Dictionary, melee: bool) -> Dictionary:
	if melee or not has_doctrine(state, squad, "devastator"): return profile
	var copy := profile.duplicate(true)
	copy.keywords.assault = true
	return copy

static func shoot_after_fallback(state: Dictionary, squad: int) -> bool:
	var mobile_lethality: Dictionary = state.get("detachment_stratagems", {}).get("mobile_lethality", {}).get(squad, {})
	var mobile_lethality_active: bool = state.get("detachment_stratagems", {}).get("implementation", "") == "gladius-awakened-stratagems-11e-v5" and int(mobile_lethality.get("turn", -1)) == int(state.get("turn", -2))
	return has_doctrine(state, squad, "tactical") or UnitAbilities.has(state, squad, "adaptive-strategy") or mobile_lethality_active

static func charge_error(state: Dictionary, squad: int) -> String:
	if state.squads[squad].advanced and not has_doctrine(state, squad, "assault") and not UnitAbilities.has(state, squad, "spear-of-chogoris") and not storm_swift_onslaught(state, squad): return "A unit that Advanced needs Assault Doctrine to declare a charge."
	if state.squads[squad].fell_back and not has_doctrine(state, squad, "tactical") and not UnitAbilities.has(state, squad, "adaptive-strategy") and not storm_swift_onslaught(state, squad): return "A unit that Fell Back needs Tactical Doctrine to declare a charge."
	return ""

static func advance_bonus(state: Dictionary, squad: int) -> int:
	return 1 if has_doctrine(state, squad, "assault") and UnitAbilities.has(state, squad, "spear-of-chogoris") else 0

## Storm-swift Onslaught: Adeptus Astartes units may charge after Advancing or Falling Back.
static func storm_swift_onslaught(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "spearpoint-task-force" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_astra := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		found_astra = true
	return found_astra

static func record_spearpoint_destroyed_unit(state: Dictionary, attacker: int, target: int) -> void:
	if state.phase != "fight" or not storm_swift_onslaught(state, attacker) or not state.squads.has(target): return
	if int(state.squads[target].get("owner", -1)) == int(state.squads[attacker].get("owner", -1)): return
	if not _squad_destroyed(state, target): return
	if not state.combat_doctrines.has("spearpoint_destroyed_units"): state.combat_doctrines.spearpoint_destroyed_units = {}
	state.combat_doctrines.spearpoint_destroyed_units[attacker] = true

static func _squad_destroyed(state: Dictionary, squad: int) -> bool:
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true): return false
	return true

static func charge_bonus(state: Dictionary, squad: int) -> int:
	var bonus := 1 if has_doctrine(state, squad, "assault") and UnitAbilities.has(state, squad, "spear-of-chogoris") else 0
	if death_blow(state, squad): bonus += 1
	return bonus

## Terminator Storm Force: friendly Adeptus Astartes Terminator units add 1 to Charge rolls.
static func death_blow(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "terminator-storm-force" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_terminator := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		if keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "TERMINATOR"): found_terminator = true
	return found_terminator

## Codex Fire-patterns: Tacticus units retain Rapid Fire at any distance within weapon range.
static func codex_fire_patterns(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "tacticus-firestorm-force" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_tacticus := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		if keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "TACTICUS"): found_tacticus = true
	return found_tacticus

## Tacticus Attack Force: friendly Tacticus units can re-roll Advance rolls.
static func wrath_of_the_chapter(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "tacticus-attack-force" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_tacticus := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		if keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "TACTICUS"): found_tacticus = true
	return found_tacticus

## Gravis Linebreaker Force: after a Normal move, Gravis ranged attacks lose Heavy and gain +1 to Hit.
static func walking_fortress(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "gravis-linebreaker-force" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	if not state.squads[squad].get("normal_moved_this_turn", false): return false
	var found_gravis := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		if keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "GRAVIS"): found_gravis = true
	return found_gravis

## Wrath of the Rock: incoming attacks with Strength greater than Toughness suffer -1 to Wound.
static func dutiful_tenacity(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or str(state.get("combat_doctrines", {}).get("detachment", "")) != "wrath-of-the-rock" or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_type := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		if not has_astra: return false
		if keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() in ["INFANTRY", "MOUNTED"]): found_type = true
	return found_type

static func rapid_fire_active(state: Dictionary, squad: int, profile: Dictionary, distance: float) -> bool:
	if not profile.get("keywords", {}).has("rapid-fire"): return false
	var weapon_range := float(profile.get("range_inches", 0.0))
	return distance <= weapon_range / 2.0 or (codex_fire_patterns(state, squad) and distance <= weapon_range)

static func movement_bonus(state: Dictionary, squad: int) -> float:
	if not enabled(state) or not state.combat_doctrines.get("stormlance", false) or not state.squads.has(squad): return 0.0
	var owner: int = state.squads[squad].owner
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return 0.0
	var found_model := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		found_model = true
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).to_upper() == "ADEPTUS ASTARTES")
		var fast_unit: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).to_upper() in ["MOUNTED", "SPEEDER"])
		if not has_astra or not fast_unit: return 0.0
	return 2.0 if found_model else 0.0

## Ironclad Champions: friendly Adeptus Astartes Dreadnought units re-roll hit rolls of 1.
static func enduring_vengeance(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.combat_doctrines.get("ironclad_champions", false) or not state.squads.has(squad): return false
	var owner: int = state.squads[squad].owner
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var found_model := false
	for id: int in state.units:
		if state.units[id].squad != squad or state.units[id].wounds <= 0: continue
		found_model = true
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		var is_dreadnought: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "DREADNOUGHT")
		if not has_astra or not is_dreadnought: return false
	return found_model

## Ironstorm Auto-targeters: once per ranged attack activation, an eligible unit can
## re-roll one Hit roll and one Wound roll. Walker units are excluded.
static func ironstorm_auto_targeters(state: Dictionary, model: int) -> bool:
	if not enabled(state) or not state.get("combat_doctrines", {}).get("ironstorm_spearhead", false) or not state.units.has(model): return false
	var unit: Dictionary = state.units[model]
	var squad := int(unit.get("squad", -1))
	var owner := int(unit.get("owner", -1))
	if not state.squads.has(squad) or int(state.squads[squad].get("owner", -2)) != owner: return false
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var identity := UnitAbilities.identity(unit)
	var profile := MarineProfiles.profile(identity)
	var keywords: Array = profile.get("keywords", unit.get("keywords", []))
	var normalized: Array[String] = []
	for keyword: Variant in keywords: normalized.append(str(keyword).replace("_", " ").replace("-", " ").to_upper())
	return "ADEPTUS ASTARTES" in normalized and "VEHICLE" in normalized and "WALKER" not in normalized

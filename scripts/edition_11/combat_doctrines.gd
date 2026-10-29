extends RefCounted
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const RagnarBlackmane = preload("res://scripts/edition_11/ragnar_blackmane.gd")
const Mephiston = preload("res://scripts/edition_11/mephiston.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
## Current 11e army rule plus the explicitly declared Space Marine detachment effects.
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const TemplarVows = preload("res://scripts/edition_11/templar_vows.gd")
const ID := "combat-doctrines-11e-fist-of-the-god-emperor-v2"
const DETACHMENTS := ["none", "gladius", "stormlance", "ironclad-champions", "gauntlet-task-force", "assault-brethren", "tactical-brethren", "devastator-brethren", "terminator-storm-force", "tacticus-firestorm-force", "tacticus-attack-force", "gravis-linebreaker-force", "gravis-siege-force", "wrath-of-the-rock", "spearpoint-task-force", "ironstorm-spearhead", "phobos-shock-force", "phobos-shadow-force", "darkflight-pursuit", "inner-circle-task-force", "medusa-wrath", "blade-of-ultramar", "fist-of-the-god-emperor", "vow-sworn-crusaders"]
const REFERENCE := "https://wahapedia.ru/wh40k11ed/factions/space-marines/#Combat-Doctrines"
const NAMES := {"none": "No doctrine this turn", "devastator": "Devastator: shoot after Advance", "tactical": "Tactical: shoot and charge after Fall Back", "assault": "Assault: charge after Advance"}
const ORDER := ["devastator", "tactical", "assault"]
const DETACHMENT_EXTRA_DOCTRINES := {"assault-brethren": ["assault"], "tactical-brethren": ["tactical"], "devastator-brethren": ["devastator"], "spearpoint-task-force": ["assault", "tactical"]}
static func enable(state: Dictionary, detachment: Variant = "gladius") -> void:
	# Preserve callers from the older bool API while prepared setup migrates to names.
	if detachment is bool: detachment = "gladius" if detachment else "none"
	var requested: Dictionary = detachment.duplicate(true) if detachment is Dictionary else {}
	var legacy_detachment := str(detachment) if not detachment is Dictionary else ""
	var owners: Array[int] = []
	var detachments: Dictionary = {}
	for owner in [1, 2]:
		if not Marines.marine_army(state, owner): continue
		owners.append(owner)
		var selected := str(requested.get(owner, requested.get(str(owner), legacy_detachment)))
		if selected.is_empty(): selected = "none"
		detachments[owner] = selected
	var selected_values: Array[String] = []
	for selected: Variant in detachments.values():
		if str(selected) not in selected_values: selected_values.append(str(selected))
	var common_detachment := str(selected_values[0]) if selected_values.size() == 1 else ""
	state.combat_doctrines = {"implementation": ID, "owners": owners, "detachment": common_detachment, "detachments": detachments, "gladius": "gladius" in selected_values, "stormlance": "stormlance" in selected_values, "ironclad_champions": "ironclad-champions" in selected_values, "gauntlet_task_force": "gauntlet-task-force" in selected_values, "ironstorm_spearhead": "ironstorm-spearhead" in selected_values, "extra_used": {}, "active": {}, "used": {}, "selected_turn": {}, "cp_pending_turn": -1, "templar_vows": {}, "templar_vow_passed": {}}
	state.marine_enhancements = {"standard_used": {}, "standard_active": {}, "master_machine_war_targets": {}, "master_machine_war_used": {}}
	Capabilities.admit(state, "combat-doctrines", ID)
	for selected_detachment: String in selected_values:
		if selected_detachment == "gladius": Capabilities.admit(state, "codex-discipline", ID)
		if selected_detachment == "blade-of-ultramar":
			Capabilities.admit(state, "mastered-doctrines", ID)
			Capabilities.admit(state, "student-of-the-codex", ID)
		if selected_detachment == "stormlance": Capabilities.admit(state, "lightning-fast-strike", ID)
		if selected_detachment == "ironclad-champions": Capabilities.admit(state, "enduring-vengeance", ID)
		if selected_detachment == "gauntlet-task-force":
			Capabilities.admit(state, "gauntlet-combined-deployment", ID)
			Capabilities.admit(state, "damocles-class-uplink", ID)
		if selected_detachment == "ironstorm-spearhead": Capabilities.admit(state, "ironstorm-auto-targeters", ID)
		if selected_detachment == "vow-sworn-crusaders":
			Capabilities.admit(state, "templar-vows", TemplarVows.ID)
			Capabilities.admit(state, "augury-servo-host", ID)
			Capabilities.admit(state, "consecrating-aura", ID)
			Capabilities.admit(state, "incendiary-animus", ID)
			Capabilities.admit(state, "zealous-vanguard", ID)
		if selected_detachment == "fist-of-the-god-emperor":
			Capabilities.admit(state, "purge-and-sanctify", ID)
			Capabilities.admit(state, "fist-doctrinal-flexibility", ID)
			Capabilities.admit(state, "fist-angels-defiant", ID)
			Capabilities.admit(state, "fist-avowed-destruction", ID)
		if selected_detachment == "phobos-shock-force":
			Capabilities.admit(state, "vanguard-ambushers", ID)
			Capabilities.admit(state, "phobos-shock-seal-of-shrouding", ID)
			Capabilities.admit(state, "phobos-shock-venator-omni-auspex", ID)
		if selected_detachment == "phobos-shadow-force":
			Capabilities.admit(state, "phobos-shadow-masters", ID)
			Capabilities.admit(state, "phobos-shadow-venator-omni-auspex", ID)
			Capabilities.admit(state, "phobos-shadow-execute-and-redeploy", ID)
			Capabilities.admit(state, "phobos-shadow-strike-from-the-shadows", ID)
			Capabilities.admit(state, "phobos-shadow-tactical-withdrawal", ID)
			Capabilities.admit(state, "phobos-shadow-mortis-snares", ID)
		if selected_detachment == "darkflight-pursuit":
			Capabilities.admit(state, "black-winged-vigilance", ID)
			Capabilities.admit(state, "thundercowl-turbines", ID)
			Capabilities.admit(state, "darkflight-wings-of-shadow", ID)
		if selected_detachment == "terminator-storm-force":
			Capabilities.admit(state, "death-blow", ID)
			Capabilities.admit(state, "champion-of-first-company", ID)
			Capabilities.admit(state, "corporeum-reliquary", ID)
			Capabilities.admit(state, "terminator-tactical-dreadnought-fortitude", ID)
			Capabilities.admit(state, "terminator-merciless-veterans", ID)
			Capabilities.admit(state, "terminator-gunship-extraction", ID)
		if selected_detachment == "tacticus-firestorm-force": Capabilities.admit(state, "codex-fire-patterns", ID)
		if selected_detachment == "tacticus-attack-force":
			Capabilities.admit(state, "wrath-of-the-chapter", ID)
			Capabilities.admit(state, "spearpoint-war-leader", ID)
			Capabilities.admit(state, "tacticus-tactical-focus", ID)
			Capabilities.admit(state, "tacticus-transhuman-swiftness", ID)
			Capabilities.admit(state, "tacticus-attack-relentless-assault", ID)
			Capabilities.admit(state, "martial-paragon", ID)
		if selected_detachment == "gravis-linebreaker-force":
			Capabilities.admit(state, "walking-fortress", ID)
			Capabilities.admit(state, "indefatigable-fortitude", ID)
			Capabilities.admit(state, "relentless-advance", ID)
		if selected_detachment == "gravis-siege-force":
			Capabilities.admit(state, "indomitable-defence", ID)
			Capabilities.admit(state, "immovable-conquerors", ID)
			Capabilities.admit(state, "narthecis-gauntlet", ID)
		if selected_detachment == "wrath-of-the-rock":
			Capabilities.admit(state, "dutiful-tenacity", ID)
			Capabilities.admit(state, "lord-of-the-ravenwing", ID)
			Capabilities.admit(state, "deathwing-assault", ID)
			Capabilities.admit(state, "ancient-weapons", ID)
		if selected_detachment == "spearpoint-task-force": Capabilities.admit(state, "storm-swift-onslaught", ID)
		if selected_detachment in DETACHMENT_EXTRA_DOCTRINES and selected_detachment != "spearpoint-task-force":
			var capability := str(selected_detachment) + "-mastery"
			Capabilities.admit(state, capability, ID)
	for squad: int in state.squads:
		if state.squads[squad].owner in owners: Capabilities.admit_squad(state, squad, "combat-doctrines")
	apply_detachment_roster_keywords(state)

static func apply_detachment_roster_keywords(state: Dictionary) -> void:
	if not enabled(state): return
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var owner := int(unit.get("owner", -1))
		var identity := AbilityCatalog.identity(unit)
		var profile := MarineProfiles.profile(identity)
		if profile.is_empty(): continue
		var grants := MarineProfiles.detachment_keyword_grants(identity, detachment_for(state, owner), profile.get("keywords", []))
		if grants.is_empty(): continue
		var keywords: Array = unit.get("keywords", []).duplicate()
		for keyword: String in grants:
			if keyword not in keywords: keywords.append(keyword)
		unit.keywords = keywords
		state.units[model] = unit

static func detachment_for(state: Dictionary, player: int) -> String:
	var doctrine_state: Dictionary = state.get("combat_doctrines", {})
	var assignments: Dictionary = doctrine_state.get("detachments", {})
	var values: Array = assignments.values()
	if not values.is_empty() and values.all(func(value: Variant) -> bool: return str(value) == str(values[0])) and not str(doctrine_state.get("detachment", "")).is_empty(): return str(doctrine_state.detachment)
	return str(assignments.get(player, assignments.get(str(player), doctrine_state.get("detachment", "none"))))

static func enabled(state: Dictionary) -> bool:
	return state.get("combat_doctrines", {}).get("implementation", "") == ID

static func blade_mastered_doctrines_active(state: Dictionary, player: int) -> bool:
	return detachment_for(state, player) == "blade-of-ultramar" and LeaderCatalog.army_has_calgar(state, player)

static func chapter_restriction_error(state: Dictionary, detachment: String, player: int = -1) -> String:
	var allowed_chapter := ChapterRules.required_chapter_for_detachment(detachment)
	if allowed_chapter.is_empty(): return ""
	var selected_detachment_name := ChapterRules.detachment_name(detachment)
	if player >= 0:
		var selected_context: Dictionary = state.get("marine_chapters", {})
		var chapter := str(selected_context.get(player, selected_context.get(str(player), "")))
		if not chapter.is_empty() and chapter != allowed_chapter:
			return "%s requires %s Chapter context for Player %d." % [selected_detachment_name, MarineProfiles.chapter_name(allowed_chapter), player]
	var profile_cache: Dictionary = {}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if player >= 0 and int(unit.get("owner", -1)) != player: continue
		if unit.get("wounds", 0) <= 0: continue
		var identity := AbilityCatalog.identity(unit)
		if not profile_cache.has(identity): profile_cache[identity] = MarineProfiles.profile(identity)
		var profile: Dictionary = profile_cache[identity]
		var keywords: Array = profile.get("keywords", unit.get("keywords", []))
		if "ADEPTUS ASTARTES" not in keywords: continue
		for chapter: String in MarineProfiles.chapter_keywords_for(keywords):
			if chapter != allowed_chapter:
				return "%s cannot include Adeptus Astartes units from %s." % [selected_detachment_name, chapter]
	return ""

static func available(state: Dictionary, player: int) -> Array[String]:
	var result: Array[String] = []
	if not enabled(state) or player not in state.combat_doctrines.owners or not Marines.marine_army(state, player): return result
	for doctrine: String in ORDER:
		var used: Array = state.combat_doctrines.used.get(player, [])
		var selected_detachment := detachment_for(state, player)
		var fixed_extra: bool = doctrine in DETACHMENT_EXTRA_DOCTRINES.get(selected_detachment, [])
		var shared_extra_available: bool = (fixed_extra or selected_detachment == "gladius") and not state.combat_doctrines.extra_used.get(player, false)
		var mastered_doctrines_available: bool = blade_mastered_doctrines_active(state, player)
		var doctrine_uses := used.count(doctrine)
		if doctrine_uses == 0 or (doctrine_uses == 1 and (shared_extra_available or mastered_doctrines_available)): result.append(doctrine)
	return result

static func start_command(state: Dictionary) -> void:
	if enabled(state): state.combat_doctrines.active.erase(state.active)

static func needs_choice(state: Dictionary) -> bool:
	return enabled(state) and state.get("test_winner", 0) == 0 and state.phase == "command" and state.combat_doctrines.selected_turn.get(state.active, -1) != state.turn and not available(state, state.active).is_empty()

## Normalized read-only view; choice_error/select_doctrine remain authoritative.
static func pending_decision(state: Dictionary) -> Dictionary:
	if not needs_choice(state): return {}
	var owner := int(state.active)
	var options: Array[Dictionary] = [{"label": NAMES.none, "action": "combat-doctrine", "value": "none"}]
	for doctrine: String in available(state, owner):
		options.append({"label": NAMES[doctrine], "action": "combat-doctrine", "value": doctrine})
	return PendingDecision.create(state, "combat-doctrines", "command-phase:doctrine", owner, options, false)

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
	if doctrine in state.combat_doctrines.used[player] and detachment_for(state, player) != "blade-of-ultramar": state.combat_doctrines.extra_used[player] = true
	state.combat_doctrines.used[player].append(doctrine)

static func active_for(state: Dictionary, squad: int) -> String:
	var gauntlet_doctrine := MarineEnhancements.damocles_class_uplink_doctrine(state, squad)
	if not gauntlet_doctrine.is_empty(): return gauntlet_doctrine
	if not AbilityCatalog.doctrine(state, squad).is_empty(): return AbilityCatalog.doctrine(state, squad)
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
	for doctrine: String in AbilityCatalog.additional_doctrines(state, squad):
		if doctrine in ORDER and doctrine not in result: result.append(doctrine)
	for doctrine: String in MarineEnhancements.additional_doctrines(state, squad):
		if doctrine in ORDER and doctrine not in result: result.append(doctrine)
	for doctrine: String in Mephiston.quickening_additional_doctrine(state, squad):
		if doctrine in ORDER and doctrine not in result: result.append(doctrine)
	if AbilityCatalog.has(state, squad, "codex-adept"):
		for doctrine: String in ORDER:
			if doctrine not in result: result.append(doctrine)
	return result

static func master_machine_war_doctrine(state: Dictionary, squad: int) -> String:
	return MarineEnhancements.master_machine_war_doctrine(state, squad)

static func has_doctrine(state: Dictionary, squad: int, doctrine: String) -> bool:
	return doctrine in active_doctrines_for(state, squad)

static func weapon(state: Dictionary, squad: int, profile: Dictionary, melee: bool) -> Dictionary:
	if melee: return profile
	var add_assault := has_doctrine(state, squad, "devastator")
	var add_ignores_cover := darkflight_ravenwing_fly_unit(state, squad)
	if not add_assault and not add_ignores_cover: return profile
	var copy := profile.duplicate(true)
	if add_assault: copy.keywords.assault = true
	if add_ignores_cover: copy.keywords["ignores-cover"] = true
	return copy

static func darkflight_ravenwing_fly_unit(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	if owner not in state.combat_doctrines.owners or detachment_for(state, owner) != "darkflight-pursuit": return false
	if not Marines.marine_army(state, owner): return false
	var chapters: Dictionary = state.get("marine_chapters", {})
	if str(chapters.get(owner, chapters.get(str(owner), ""))) != "DARK ANGELS": return false
	var found_model := false
	var unit_keywords: Array[String] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		found_model = true
		var identity := AbilityCatalog.identity(unit)
		var profile := MarineProfiles.profile(identity)
		if profile.is_empty() or "ADEPTUS ASTARTES" not in profile.get("keywords", []): return false
		for keyword: Variant in unit.get("keywords", []):
			var normalized := str(keyword).replace("_", " ").replace("-", " ").strip_edges().to_upper()
			if normalized not in unit_keywords: unit_keywords.append(normalized)
	return found_model and "RAVENWING" in unit_keywords and "FLY" in unit_keywords

static func shoot_after_fallback(state: Dictionary, squad: int) -> bool:
	var mobile_lethality: Dictionary = state.get("detachment_stratagems", {}).get("mobile_lethality", {}).get(squad, {})
	var detachment_implementation := str(state.get("detachment_stratagems", {}).get("implementation", ""))
	var current_detachment_state := detachment_implementation.begins_with("gladius-awakened-stratagems-11e-v")
	var mobile_lethality_active: bool = current_detachment_state and int(mobile_lethality.get("turn", -1)) == int(state.get("turn", -2))
	return has_doctrine(state, squad, "tactical") or AbilityCatalog.has(state, squad, "adaptive-strategy") or AbilityCatalog.has(state, squad, "strategic-knowledge") or mobile_lethality_active

static func charge_error(state: Dictionary, squad: int) -> String:
	if state.squads[squad].advanced and not has_doctrine(state, squad, "assault") and not AbilityCatalog.has(state, squad, "spear-of-chogoris") and not AbilityCatalog.has(state, squad, "remorseless-persecution") and not AbilityCatalog.has(state, squad, "berserk-charge") and not AbilityCatalog.has(state, squad, "strategic-knowledge") and not RagnarBlackmane.headtakers_war_howl_active(state, squad): return "A unit that Advanced needs Assault Doctrine to declare a charge."
	if state.squads[squad].fell_back and not has_doctrine(state, squad, "tactical") and not AbilityCatalog.has(state, squad, "adaptive-strategy") and not AbilityCatalog.has(state, squad, "strategic-knowledge"): return "A unit that Fell Back needs Tactical Doctrine to declare a charge."
	return ""

static func advance_bonus(state: Dictionary, squad: int) -> int:
	if has_doctrine(state, squad, "assault") and AbilityCatalog.has(state, squad, "spear-of-chogoris"): return 1
	if not enabled(state) or not state.squads.has(squad): return 0
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "spearpoint-task-force": return 0
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return 0
	var found_model := false
	for id: int in state.units:
		if int(state.units[id].get("squad", -1)) != squad or int(state.units[id].get("wounds", 0)) <= 0: continue
		found_model = true
		var keywords: Array = state.units[id].get("keywords", [])
		var has_astra: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES")
		var fast_unit: bool = keywords.any(func(keyword: Variant) -> bool: return str(keyword).to_upper() in ["MOUNTED", "SPEEDER"])
		if not has_astra or not fast_unit: return 0
	return 1 if found_model else 0

static func charge_bonus(state: Dictionary, squad: int) -> int:
	var bonus := 1 if has_doctrine(state, squad, "assault") and AbilityCatalog.has(state, squad, "spear-of-chogoris") else 0
	if death_blow(state, squad): bonus += 1
	return bonus

## Terminator Storm Force: friendly Adeptus Astartes Terminator units add 1 to Charge rolls.
static func death_blow(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "terminator-storm-force": return false
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
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "tacticus-firestorm-force": return false
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
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "tacticus-attack-force": return false
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
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "gravis-linebreaker-force": return false
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

## Gravis Siege Force: stronger attacks worsen Wound rolls against Gravis units in objective range.
static func indomitable_defence(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "gravis-siege-force": return false
	if owner not in state.combat_doctrines.owners or not Marines.marine_army(state, owner): return false
	var has_gravis := false
	var in_objective_range := false
	for id: int in state.units:
		var model: Dictionary = state.units[id]
		if model.squad != squad or model.wounds <= 0: continue
		for keyword: Variant in model.get("keywords", []):
			if str(keyword).replace("_", " ").replace("-", " ").strip_edges().to_upper() == "GRAVIS": has_gravis = true
		for objective: Dictionary in state.get("mission", {}).get("objectives", []):
			if Objectives.in_range(model, objective): in_objective_range = true
	return has_gravis and in_objective_range

## Wrath of the Rock: incoming attacks with Strength greater than Toughness suffer -1 to Wound.
static func dutiful_tenacity(state: Dictionary, squad: int) -> bool:
	if not enabled(state) or not state.squads.has(squad): return false
	var owner: int = int(state.squads[squad].get("owner", -1))
	if detachment_for(state, owner) != "wrath-of-the-rock": return false
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
	var identity := AbilityCatalog.identity(unit)
	var profile := MarineProfiles.profile(identity)
	var keywords: Array = profile.get("keywords", unit.get("keywords", []))
	var normalized: Array[String] = []
	for keyword: Variant in keywords: normalized.append(str(keyword).replace("_", " ").replace("-", " ").to_upper())
	return "ADEPTUS ASTARTES" in normalized and "VEHICLE" in normalized and "WALKER" not in normalized

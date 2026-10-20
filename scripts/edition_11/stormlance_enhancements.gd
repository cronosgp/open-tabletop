extends RefCounted
## Space Marine enhancement records transcribed from the pinned local Wahapedia e11 export.
const SUPERCHARGED := "000008486002"
const AUSPEX := "000008486003"
const ARTIFICER_SARCOPHAGUS := "000011224002"
const VENERABLE_CHAMPION := "000011224003"
const ADEPT_OF_THE_CODEX := "000008353004"
const LAURELS_OF_TRIUMPH := "000008353003"
const ARTIFICER_ARMOUR := "000008353005"
const STANDARD_OF_THE_EMPEROR_ASCENDANT := "000008353002"
const IMPERIUMS_SWORD := "000011204002"
const FURIOUS_ASSAULT := "000011204003"
const LAURELS_OF_VIGILANCE := "000011220002"
const TACTICAL_INSIGHT := "000011220003"
const MASTER_FORGED_FIREARMS := "000011212002"
const HONOUR_OF_VIGILANCE := "000011212003"
const STORMSEERS_WISDOM := "000010629002"
const CHOGORIAN_HUNTMASTER := "000010629003"
const HUNTERS_EYE := "000010629004"
const SPEARPOINT_PARAGON := "000010629005"
const REDOUBTABLE_MACHINE_SPIRIT := "000008478002"
const GUNNERY_HONOURS := "000008478003"
const STORMLANCE := "stormlance"
const IRONCLAD := "ironclad-champions"
const GLADIUS := "gladius"
const ASSAULT_BRETHREN := "assault-brethren"
const TACTICAL_BRETHREN := "tactical-brethren"
const DEVASTATOR_BRETHREN := "devastator-brethren"
const SPEARPOINT := "spearpoint-task-force"
const IRONSTORM := "ironstorm-spearhead"
const Current = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const RECORDS := {
	SUPERCHARGED: {"id": SUPERCHARGED, "name": "Supercharged Engines", "cost": 10, "detachment": STORMLANCE,
		"source_datasheet_ids": ["000000094", "000000137", "000000241", "000000322", "000002702", "000002712", "000002748", "000004247"],
		"datasheets": ["chaplain-on-bike", "captain-on-bike", "outrider-squad", "invader-atvs"],
		"rule": "Adeptus Astartes Mounted unit only. This unit can re-roll Advance rolls."},
	AUSPEX: {"id": AUSPEX, "name": "Auspex Triangulation Shrines", "cost": 10, "detachment": STORMLANCE,
		"source_datasheet_ids": ["000000114", "000000124", "000000238", "000000242", "000001610", "000002711"],
		"datasheets": ["storm-speeder-hammerstrike", "storm-speeder-hailstrike", "storm-speeder-thunderstrike", "land-speeder"],
		"rule": "Adeptus Astartes Speeder unit only. At the start of your Shooting phase, select one visible enemy unit within 12 inches of this unit. That enemy unit is spotted; while spotted, it has +3 inches detection range."},
	ARTIFICER_SARCOPHAGUS: {"id": ARTIFICER_SARCOPHAGUS, "name": "Artificer Sarcophagus", "cost": 40, "detachment": IRONCLAD,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["DREADNOUGHT"],
		"rule": "Dreadnought unit only. Attacks that target this unit have -1 Damage."},
	VENERABLE_CHAMPION: {"id": VENERABLE_CHAMPION, "name": "Venerable Champion (Aura)", "cost": 30, "detachment": IRONCLAD,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["DREADNOUGHT"],
		"rule": "Dreadnought unit only. Friendly Adeptus Astartes Infantry/Mounted units within 6 inches can re-roll hit rolls of 1."},
	ADEPT_OF_THE_CODEX: {"id": ADEPT_OF_THE_CODEX, "name": "Adept of the Codex", "cost": 20, "detachment": GLADIUS,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["CAPTAIN"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Captain model only. Tactical Doctrine is active for this unit in addition to any other Combat Doctrine."},
	ARTIFICER_ARMOUR: {"id": ARTIFICER_ARMOUR, "name": "Artificer Armour", "cost": 15, "detachment": GLADIUS,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Adeptus Astartes model only. The bearer has a 2+ Save and Feel No Pain 5+."},
	LAURELS_OF_TRIUMPH: {"id": LAURELS_OF_TRIUMPH, "name": "Laurels of Triumph", "cost": 20, "detachment": GLADIUS,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Adeptus Astartes model only. The bearer's melee attacks have +1 Strength and AP, or +2 Strength and AP while Assault Doctrine is active for its unit."},
	STANDARD_OF_THE_EMPEROR_ASCENDANT: {"id": STANDARD_OF_THE_EMPEROR_ASCENDANT, "name": "Standard of the Emperor Ascendant", "cost": 25, "detachment": GLADIUS,
		"source_datasheet_ids": [], "datasheets": [], "required_keywords": ["ANCIENT"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Ancient model only. The bearer has +1 OC, +1 Leadership and Feel No Pain 5+. Once per battle per army, when the unit is selected to fight, it can gain +1 Attack for its melee attacks until the end of the phase."},
	IMPERIUMS_SWORD: {"id": IMPERIUMS_SWORD, "name": "Imperium's Sword", "cost": 20, "detachment": ASSAULT_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. The bearer has an additional melee weapon: 6 attacks, WS 2+, Strength 7, AP -3, Damage 3."},
	FURIOUS_ASSAULT: {"id": FURIOUS_ASSAULT, "name": "Furious Assault", "cost": 10, "detachment": ASSAULT_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000060", "000000071", "000000073", "000000076", "000000079", "000000083", "000000112", "000000115", "000000118", "000000119", "000000125", "000000126", "000000128", "000000135", "000000140", "000000147", "000001157", "000001159", "000001160", "000001165", "000001172", "000001174", "000001177", "000001183", "000001346", "000001606", "000001668", "000002098", "000002099", "000002255", "000002266", "000002270", "000002530", "000002677", "000002701", "000002707", "000002718", "000002772", "000002773", "000002775", "000002776", "000004231", "000004249"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keywords": ["INFANTRY"],
		"rule": "Adeptus Astartes Infantry unit only. Its melee attacks have Sustained Hits 1 against targets without Monster or Vehicle."},
	LAURELS_OF_VIGILANCE: {"id": LAURELS_OF_VIGILANCE, "name": "Laurels of Vigilance", "cost": 10, "detachment": TACTICAL_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. Once per battle round per army, Fire Overwatch or Heroic Intervention targeting a friendly Adeptus Astartes Battleline unit within 12 inches of the bearer costs 1 fewer CP."},
	TACTICAL_INSIGHT: {"id": TACTICAL_INSIGHT, "name": "Tactical Insight", "cost": 15, "detachment": TACTICAL_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000073", "000000083", "000000135", "000001172", "000002701", "000002702"],
		"datasheets": [],
		"rule": "Captain model only. Tactical Doctrine is active for this unit in addition to any other Combat Doctrine."},
	MASTER_FORGED_FIREARMS: {"id": MASTER_FORGED_FIREARMS, "name": "Master-forged Firearms", "cost": 15, "detachment": DEVASTATOR_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"],
		"datasheets": [],
		"rule": "Adeptus Astartes Infantry/Mounted model only. Its ranged attacks, excluding Psychic attacks, gain +1 Attack, Strength, AP and Damage."},
	HONOUR_OF_VIGILANCE: {"id": HONOUR_OF_VIGILANCE, "name": "Honour of Vigilance", "cost": 20, "detachment": DEVASTATOR_BRETHREN,
		"source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"],
		"datasheets": [],
		"rule": "Adeptus Astartes model only. Its unit's ranged attacks have Lethal Hits; while Devastator Doctrine is active, the unit can re-roll Advance rolls."},
	STORMSEERS_WISDOM: {"id": STORMSEERS_WISDOM, "name": "Stormseer's Wisdom", "cost": 15, "detachment": SPEARPOINT, "source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"], "datasheets": [], "rule": "Adeptus Astartes model only. This unit can re-roll Advance rolls."},
	CHOGORIAN_HUNTMASTER: {"id": CHOGORIAN_HUNTMASTER, "name": "Chogorian Huntmaster", "cost": 20, "detachment": SPEARPOINT, "source_restricted": true, "source_datasheet_ids": ["000000094", "000000114", "000000124", "000001610", "000002702", "000002711", "000002712", "000004247"], "datasheets": [], "rule": "Adeptus Astartes Mounted/Speeder unit only. When selected to make an ingress move, treat the current battle round number as one higher."},
	HUNTERS_EYE: {"id": HUNTERS_EYE, "name": "Hunter's Eye", "cost": 25, "detachment": SPEARPOINT, "source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"], "datasheets": [], "rule": "Adeptus Astartes model only. This unit's ranged attacks have Ignores Cover and Sustained Hits 1."},
	SPEARPOINT_PARAGON: {"id": SPEARPOINT_PARAGON, "name": "Spearpoint Paragon", "cost": 25, "detachment": SPEARPOINT, "source_restricted": true, "source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002773", "000002775"], "datasheets": [], "rule": "Adeptus Astartes model only. Bearer's melee attacks have +1 Strength and AP, or +2 Strength and AP after its unit made a Charge move this turn."},
	REDOUBTABLE_MACHINE_SPIRIT: {"id": REDOUBTABLE_MACHINE_SPIRIT, "name": "Redoubtable Machine Spirit", "cost": 25, "detachment": IRONSTORM, "source_restricted": true, "source_datasheet_ids": ["000000086", "000001667", "000001825", "000002705", "000004247"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keywords": ["VEHICLE"], "forbidden_keywords": ["FLY", "WALKER"], "excluded_source_roles": ["Transport"], "rule": "Adeptus Astartes Vehicle unit only, excluding Dedicated Transport/Fly/Walker. This unit has a 5+ invulnerable save and heals 1 wound at the end of your Command phase."},
	GUNNERY_HONOURS: {"id": GUNNERY_HONOURS, "name": "Gunnery Honours", "cost": 15, "detachment": IRONSTORM, "source_restricted": true, "source_datasheet_ids": ["000000086", "000001667", "000001825", "000002705", "000004247"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keywords": ["VEHICLE"], "forbidden_keywords": ["FLY", "WALKER"], "excluded_source_roles": ["Transport"], "rule": "Adeptus Astartes Vehicle unit only, excluding Dedicated Transport/Fly/Walker. This unit's ranged attacks have Heavy."}
}

static func for_datasheet(identity: String, detachment: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in RECORDS:
		var record: Dictionary = RECORDS[id]
		if str(record.detachment) != detachment: continue
		var short_id := identity.get_slice(":", 3)
		if short_id in record.datasheets:
			result.append(record.duplicate(true))
			continue
		var profile := Current.profile(short_id)
		var keywords: Array = profile.get("keywords", [])
		var source_id := str(profile.get("source_datasheet_id", ""))
		var source_role := str(profile.get("source_role", ""))
		var required: Array = record.get("required_keywords", [])
		var source_eligible: bool = source_id in record.get("source_datasheet_ids", [])
		var named_captain := id == ADEPT_OF_THE_CODEX and str(profile.get("name", "")) == "Captain"
		var named_ancient := id == STANDARD_OF_THE_EMPEROR_ASCENDANT and str(profile.get("name", "")) in ["Ancient", "Bladeguard Ancient", "Ancient in Terminator Armour"]
		var eligible: bool = not profile.is_empty() and (source_eligible or not required.is_empty() or named_captain or named_ancient)
		if record.get("source_restricted", false) and not source_eligible: eligible = false
		if source_role in record.get("excluded_source_roles", []): eligible = false
		if not record.get("required_unit_keywords", []).is_empty():
			for keyword: String in record.required_unit_keywords:
				if keyword not in keywords: eligible = false
		for keyword: String in required:
			if keyword not in keywords and not named_captain and not named_ancient: eligible = false
		if record.get("required_keywords", []).is_empty() and not source_eligible and not named_captain and not named_ancient: eligible = false
		for keyword: String in record.get("forbidden_keywords", []):
			if keyword in keywords: eligible = false
		if eligible: result.append(record.duplicate(true))
	return result

static func valid_for(identity: String, enhancement_id: String, detachment: String) -> bool:
	for record: Dictionary in for_datasheet(identity, detachment):
		if record.id == enhancement_id: return true
	return false

static func catalog_records(eligible_identities: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in RECORDS:
		var record: Dictionary = RECORDS[id].duplicate(true)
		record.datasheets = []
		var source_ids: Array = record.get("source_datasheet_ids", []).duplicate()
		for identity: String in eligible_identities:
			if not valid_for(identity, id, str(record.detachment)): continue
			record.datasheets.append(identity.get_slice(":", 3))
			var profile := Current.profile(identity.get_slice(":", 3))
			var source_id := str(profile.get("source_datasheet_id", ""))
			if not source_id.is_empty() and source_id not in source_ids: source_ids.append(source_id)
		record.source_datasheet_ids = source_ids
		if not record.datasheets.is_empty(): result.append(record)
	return result

static func active(state: Dictionary, squad: int, enhancement_id: String) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var record: Dictionary = RECORDS.get(enhancement_id, {})
	if record.is_empty(): return false
	if not detachment_active(state, str(record.detachment)): return false
	if enhancement_id == FURIOUS_ASSAULT:
		if str(state.squads[squad].get("enhancement_id", "")) != FURIOUS_ASSAULT: return false
		for model: int in state.get("units", {}):
			var unit: Dictionary = state.units[model]
			if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
			return valid_for(str(unit.get("definition_id", "")), FURIOUS_ASSAULT, ASSAULT_BRETHREN)
		return false
	var found := false
	var source_eligible := false
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		found = true
		if model_active(state, model, enhancement_id): source_eligible = true
		elif str(state.squads[squad].get("enhancement_id", "")) == enhancement_id and "ADEPTUS ASTARTES" in unit.get("keywords", []) and valid_for(str(unit.get("definition_id", "")), enhancement_id, str(record.detachment)): source_eligible = true
	if record.get("source_restricted", false): return found and source_eligible
	return found and (record.get("required_keywords", []).is_empty() or source_eligible)

static func model_active(state: Dictionary, model: int, enhancement_id: String) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if int(unit.get("wounds", 0)) <= 0 or str(unit.get("enhancement_id", "")) != enhancement_id: return false
	var squad := int(unit.get("squad", -1))
	if not state.get("squads", {}).has(squad): return false
	var record: Dictionary = RECORDS.get(enhancement_id, {})
	if record.is_empty(): return false
	if not detachment_active(state, str(record.detachment)): return false
	if "ADEPTUS ASTARTES" not in unit.get("keywords", []): return false
	return valid_for(str(unit.get("definition_id", "")), enhancement_id, str(record.detachment))

static func additional_doctrines(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	if active(state, squad, ADEPT_OF_THE_CODEX) or active(state, squad, TACTICAL_INSIGHT): result.append("tactical")
	return result

static func master_forged_firearms_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, MASTER_FORGED_FIREARMS)

static func honour_of_vigilance_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, HONOUR_OF_VIGILANCE)

static func artificer_armour_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, ARTIFICER_ARMOUR)

static func laurels_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, LAURELS_OF_TRIUMPH)

static func standard_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, STANDARD_OF_THE_EMPEROR_ASCENDANT)

static func imperiums_sword_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, IMPERIUMS_SWORD)

static func furious_assault_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, FURIOUS_ASSAULT)

static func detachment_active(state: Dictionary, detachment: String) -> bool:
	if detachment in [ASSAULT_BRETHREN, TACTICAL_BRETHREN, DEVASTATOR_BRETHREN]: return active_detachment(state, detachment)
	if detachment == SPEARPOINT: return active_detachment(state, detachment)
	if detachment == IRONSTORM: return active_detachment(state, detachment)
	var doctrine_key: String = {STORMLANCE: "stormlance", IRONCLAD: "ironclad_champions", GLADIUS: "gladius"}.get(detachment, "")
	return not doctrine_key.is_empty() and bool(state.get("combat_doctrines", {}).get(doctrine_key, false))

static func laurels_vigilance_discount(state: Dictionary, player: int, target_squad: int, stratagem_id: String) -> int:
	if stratagem_id not in ["fire-overwatch", "heroic-intervention"] or not detachment_active(state, TACTICAL_BRETHREN): return 0
	if int(state.get("marine_enhancements", {}).get("laurels_used", {}).get(player, -1)) == int(state.get("round", -2)): return 0
	if not state.get("squads", {}).has(target_squad) or int(state.squads[target_squad].get("owner", -1)) != player: return 0
	var targets: Array[int] = []
	for target_model: int in state.get("units", {}):
		var target: Dictionary = state.units[target_model]
		if int(target.get("squad", -1)) != target_squad or int(target.get("wounds", 0)) <= 0: continue
		if "ADEPTUS ASTARTES" not in target.get("keywords", []) or "BATTLELINE" not in target.get("keywords", []): return 0
		targets.append(target_model)
	if targets.is_empty(): return 0
	for bearer: int in state.get("units", {}):
		if not model_active(state, bearer, LAURELS_OF_VIGILANCE): continue
		for target_model: int in targets:
			if Geometry.edge(state.units[bearer], state.units[target_model]) <= 12.001: return 1
	return 0

static func consume_laurels_vigilance(state: Dictionary, player: int) -> void:
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("laurels_used"): state.marine_enhancements.laurels_used = {}
	state.marine_enhancements.laurels_used[player] = int(state.get("round", 0))

static func standard_fight_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not active_detachment(state, GLADIUS) or state.get("test_winner", 0) != 0 or state.get("phase", "") != "fight" or int(state.get("fight_actor", -1)) != player or state.get("fight_step", "") != "attacks": return result
	if state.get("marine_enhancements", {}).get("standard_used", {}).get(player, false): return result
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player or state.squads[squad].get("fought", false) or squad not in FightQueue.choices(state, player): continue
		for model: int in Geometry.alive(state, squad):
			if standard_bearer(state, model):
				result.append({"label": "Ancient Exhortation: +1 melee Attack for %s" % str(state.squads[squad].get("name", "unit")), "action": "standard-exhortation", "model": model, "target": squad, "value": ""})
				break
	return result

static func apply_standard_exhortation(state: Dictionary, player: int, selected: Dictionary) -> String:
	var model := int(selected.get("model", -1))
	var squad := int(selected.get("target", -1))
	if standard_fight_choices(state, player).is_empty(): return "Ancient Exhortation is not available for this fight selection."
	var valid_choice := false
	for option: Dictionary in standard_fight_choices(state, player):
		if int(option.model) == model and int(option.target) == squad: valid_choice = true
	if not valid_choice: return "Choose the living bearer’s unit when it is selected to fight."
	if not state.has("marine_enhancements"): state.marine_enhancements = {"standard_used": {}, "standard_active": {}}
	if not state.marine_enhancements.has("standard_used"): state.marine_enhancements.standard_used = {}
	if not state.marine_enhancements.has("standard_active"): state.marine_enhancements.standard_active = {}
	state.marine_enhancements.standard_used[player] = true
	state.marine_enhancements.standard_active[squad] = {"owner": player, "turn": int(state.turn)}
	state.fight_selected = squad
	return ""

static func active_detachment(state: Dictionary, detachment: String) -> bool:
	return str(state.get("combat_doctrines", {}).get("detachment", "")) == detachment

static func stormseers_wisdom_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, STORMSEERS_WISDOM)

static func hunters_eye_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, HUNTERS_EYE)

static func chogorian_huntmaster_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, CHOGORIAN_HUNTMASTER)

static func ingress_round_allowed(state: Dictionary, squad: int) -> bool:
	return int(state.get("round", 0)) > 1 or chogorian_huntmaster_active(state, squad)

static func redoubtable_machine_spirit_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, REDOUBTABLE_MACHINE_SPIRIT)

static func gunnery_honours_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, GUNNERY_HONOURS)

## Resolve the enhancement once at the end of its owner's Command phase.
static func ironstorm_command_healing(state: Dictionary, player: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if state.get("phase", "") != "command" or int(state.get("active", -1)) != player or not active_detachment(state, IRONSTORM): return results
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("ironstorm_healed"): state.marine_enhancements.ironstorm_healed = {}
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player or not redoubtable_machine_spirit_active(state, squad): continue
		var key := "%d:%d" % [int(state.get("turn", 0)), squad]
		if state.marine_enhancements.ironstorm_healed.get(key, false): continue
		state.marine_enhancements.ironstorm_healed[key] = true
		for model: int in Geometry.alive(state, squad):
			var before := int(state.units[model].get("wounds", 0))
			var maximum := int(state.units[model].get("max_wounds", before))
			state.units[model].wounds = mini(maximum, before + 1)
			var restored := int(state.units[model].wounds) - before
			if restored > 0: results.append({"squad": squad, "model": model, "restored": restored})
			break
	return results

static func spearpoint_paragon_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, SPEARPOINT_PARAGON)

static func standard_melee_attack_bonus(state: Dictionary, squad: int) -> int:
	var active_record: Dictionary = state.get("marine_enhancements", {}).get("standard_active", {}).get(squad, {})
	if active_record.is_empty() or not state.get("squads", {}).has(squad) or str(state.get("phase", "")) != "fight": return 0
	if int(active_record.get("owner", -1)) != int(state.squads[squad].get("owner", -2)) or int(active_record.get("turn", -1)) != int(state.get("turn", -2)): return 0
	return 1

static func artificer_sarcophagus_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, ARTIFICER_SARCOPHAGUS)

static func venerable_hit_reroll(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var eligible_target := false
	for model: int in Geometry.alive(state, squad):
		var keywords: Array = state.units[model].get("keywords", [])
		if "ADEPTUS ASTARTES" not in keywords: return false
		if "INFANTRY" in keywords or "MOUNTED" in keywords: eligible_target = true
	if not eligible_target: return false
	for source: int in state.squads:
		if source == squad or state.squads[source].owner != state.squads[squad].owner or not active(state, source, VENERABLE_CHAMPION): continue
		for source_model: int in Geometry.alive(state, source):
			for target_model: int in Geometry.alive(state, squad):
				if Geometry.edge(state.units[source_model], state.units[target_model]) <= 6.001: return true
	return false

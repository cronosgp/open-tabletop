extends RefCounted
## Current e11 detachment stratagem effects, enabled only for the selected local detachment scope.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ID := "gladius-awakened-stratagems-11e-v5"
const ADAPTIVE := "gladius-adaptive-strategy"
const STORM := "gladius-storm-of-devastation"
const ARMOUR := "gladius-armour-of-contempt"
const MIGHT := "gladius-might-of-angels"
const WORTHY := "gladius-a-worthy-death"
const TACTICS := "gladius-responsive-tactics"
const WIND_SWIFT := "stormlance-wind-swift-evasion"
const SUDDEN_ONSLAUGHT := "stormlance-sudden-onslaught"
const HURTLING_TARGETS := "stormlance-hurtling-targets"
const SPEAR_THRUST := "spearpoint-spear-thrust-and-sabre-swing"
const FLAWLESS_RIDERS := "spearpoint-flawless-riders"
const EVASIVE_MANOEUVRES := "spearpoint-evasive-manoeuvres"
const MOBILE_LETHALITY := "spearpoint-mobile-lethality"
const WITHDRAW_AND_REGROUP := "spearpoint-withdraw-and-regroup"
const HUNTERS_INSTINCTS := "spearpoint-hunters-instincts"
const GENE_WROUGHT_MIGHT := "assault-brethren-gene-wrought-might"
const ASSAULT_ARMOUR := "assault-brethren-armour-of-contempt"
const DUTY_IN_DEATH := "assault-brethren-duty-in-death"
const DOMINATION_FIRE := "tactical-brethren-domination-fire"
const MASTERFUL_TACTICS := "tactical-brethren-masterful-tactics"
const TACTICAL_ARMOUR := "tactical-brethren-armour-of-contempt"
const DEVASTATOR_ARMOUR := "devastator-brethren-armour-of-contempt"
const IRONSTORM_LAYERED_CERAMITE := "ironstorm-layered-ceramite"
const IRONSTORM_MIGHT := "ironstorm-might-of-the-machine-spirit"
const IRONSTORM_HEADHUNTER := "ironstorm-headhunter-doctrine"
const HAIL_OF_VENGEANCE := "devastator-brethren-hail-of-vengeance"
const STORM_OF_FIRE := "devastator-brethren-storm-of-fire"
const WORTHY_WINDOW := "worthy-death"
const MERCY_IS_WEAKNESS := "ironclad-mercy-is-weakness"
const ADAMANTINE_TERROR := "ironclad-adamantine-terror"
const UNSTOPPABLE_ADVANCE := "ironclad-unstoppable-advance"
const UNSTOPPABLE_WINDOW := "ironclad-unstoppable-advance"
const ARMOUR_WINDOW := "gladius-armour-of-contempt"
const HEADHUNTER_WINDOW := "ironstorm-headhunter-doctrine"
const LAYERED_CERAMITE_WINDOW := "ironstorm-layered-ceramite-reaction"
const IRONSTORM_TRANSPORT_IDENTITIES := ["land-raider", "land-raider-crusader", "land-raider-redeemer", "repulsor", "repulsor-executioner"]
const HUNGRY := "protocol-of-the-hungry-void"
const SUDDEN := "protocol-of-the-sudden-storm"
const TYRANT := "protocol-of-the-conquering-tyrant"
const UNDYING := "protocol-of-the-undying-legions"
const ETERNAL := "protocol-of-the-eternal-revenant"
const VENGEFUL := "protocol-of-the-vengeful-stars"
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")

static func enable(s: Dictionary) -> void:
	s.detachment_stratagems = {"implementation": ID, "modes": ["checked"], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	for ability in [ADAPTIVE, STORM, ARMOUR, MIGHT, WORTHY, TACTICS, HUNGRY, SUDDEN, TYRANT, UNDYING, ETERNAL, VENGEFUL]: Registry.admit(s, ability, ID)

static func enable_stormlance(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "stormlance" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("stormlance")
	for ability in [WIND_SWIFT, SUDDEN_ONSLAUGHT, HURTLING_TARGETS]: Registry.admit(s, ability, ID)

static func enable_ironclad(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "ironclad-champions" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("ironclad-champions")
	Registry.admit(s, ADAMANTINE_TERROR, ID)
	Registry.admit(s, MERCY_IS_WEAKNESS, ID)
	Registry.admit(s, UNSTOPPABLE_ADVANCE, ID)

static func enable_spearpoint(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "spearpoint" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("spearpoint")
	if not s.detachment_stratagems.has("evasive"): s.detachment_stratagems.evasive = {}
	if not s.detachment_stratagems.has("mobile_lethality"): s.detachment_stratagems.mobile_lethality = {}
	for ability in [SPEAR_THRUST, FLAWLESS_RIDERS, EVASIVE_MANOEUVRES, MOBILE_LETHALITY, WITHDRAW_AND_REGROUP, HUNTERS_INSTINCTS]: Registry.admit(s, ability, ID)

static func enable_assault_brethren(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "gene_wrought": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "assault-brethren" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("assault-brethren")
	if not s.detachment_stratagems.has("gene_wrought"): s.detachment_stratagems.gene_wrought = {}
	for ability in [GENE_WROUGHT_MIGHT, ASSAULT_ARMOUR, DUTY_IN_DEATH]: Registry.admit(s, ability, ID)

static func enable_tactical_brethren(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "gene_wrought": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}, "domination_pending": {}, "suppressed": {}}
	if "tactical-brethren" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("tactical-brethren")
	if not s.detachment_stratagems.has("domination_pending"): s.detachment_stratagems.domination_pending = {}
	if not s.detachment_stratagems.has("suppressed"): s.detachment_stratagems.suppressed = {}
	Registry.admit(s, DOMINATION_FIRE, ID)
	Registry.admit(s, MASTERFUL_TACTICS, ID)
	Registry.admit(s, TACTICAL_ARMOUR, ID)

static func enable_devastator_brethren(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "gene_wrought": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}, "hail_of_vengeance": {}}
	if "devastator-brethren" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("devastator-brethren")
	if not s.detachment_stratagems.has("hail_of_vengeance"): s.detachment_stratagems.hail_of_vengeance = {}
	for ability in [DEVASTATOR_ARMOUR, HAIL_OF_VENGEANCE, STORM_OF_FIRE]: Registry.admit(s, ability, ID)

static func enable_ironstorm(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "ironstorm" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("ironstorm")
	for key in ["layered_ceramite", "might_machine_spirit", "headhunter"]:
		if not s.detachment_stratagems.has(key): s.detachment_stratagems[key] = {}
	for ability in [IRONSTORM_LAYERED_CERAMITE, IRONSTORM_MIGHT, IRONSTORM_HEADHUNTER]: Registry.admit(s, ability, ID)

static func ironstorm_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "ironstorm" in s.detachment_stratagems.get("modes", []) and str(s.get("combat_doctrines", {}).get("detachment", "")) == "ironstorm-spearhead" and player in s.get("combat_doctrines", {}).get("owners", [])

static func ironstorm_vehicle_unit(s: Dictionary, squad: int, ignore_detachment_exclusions: bool = false) -> bool:
	if not s.squads.has(squad): return false
	var found := false
	for model: int in living(s, squad):
		found = true
		var unit: Dictionary = s.units[model]
		var keywords: Array = unit.get("keywords", [])
		var identity := str(unit.get("definition_id", "")).get_slice(":", 3)
		var source_role := str(unit.get("source_role", MarineProfiles.profile(identity).get("source_role", ""))).to_lower()
		var astartes := str(unit.get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:") or "ADEPTUS ASTARTES" in keywords
		if not astartes or "VEHICLE" not in keywords: return false
		if not ignore_detachment_exclusions:
			if "FLY" in keywords or "WALKER" in keywords: return false
			if source_role in ["dedicated transport", "transport"] or identity in IRONSTORM_TRANSPORT_IDENTITIES or "DEDICATED TRANSPORT" in keywords: return false
	return found

static func _ironstorm_squad_for_model(s: Dictionary, model: int) -> int:
	if not s.units.has(model): return -1
	return int(s.units[model].get("squad", -1))

static func enabled(s: Dictionary) -> bool:
	return s.get("detachment_stratagems", {}).get("implementation", "") == ID

static func adamantine_targets(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(squad): return result
	for enemy: int in s.squads:
		if s.squads[enemy].owner == s.squads[squad].owner: continue
		var engaged := false
		for source: int in G.alive(s, squad):
			for target: int in G.alive(s, enemy):
				if G.edge(s.units[source], s.units[target]) <= 2.001:
					engaged = true
					break
			if engaged: break
		if engaged: result.append(enemy)
	result.sort()
	return result

static func adamantine_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s) or s.phase != "fight": return result
	if "ironclad-champions" not in s.detachment_stratagems.get("modes", []) or not s.get("combat_doctrines", {}).get("ironclad_champions", false) or player not in s.get("combat_doctrines", {}).get("owners", []): return result
	for squad: int in s.squads:
		if s.squads[squad].owner != player or s.squads[squad].battle_shocked or not Doctrines.enduring_vengeance(s, squad): continue
		if adamantine_targets(s, squad).is_empty(): continue
		if s.cp.get(player, 0) < maxi(0, 1 - A.discount(s, player, squad)): continue
		var available := true
		for use: Dictionary in s.stratagems.uses:
			if use.player == player and use.phase_key == phase_key(s) and (use.stratagem == ADAMANTINE_TERROR or use.squad == squad): available = false
		if available: result.append(squad)
	return result

static func stormlance_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "stormlance" in s.detachment_stratagems.get("modes", []) and s.get("combat_doctrines", {}).get("stormlance", false) and player in s.get("combat_doctrines", {}).get("owners", [])

static func stormlance_unit(s: Dictionary, squad: int, mounted_only: bool = false) -> bool:
	if not s.squads.has(squad): return false
	var found := false
	for model: int in living(s, squad):
		found = true
		var keywords: Array = s.units[model].get("keywords", [])
		var astartes := false
		var fast := false
		for keyword: Variant in keywords:
			var value := str(keyword).strip_edges().to_upper()
			if value == "ADEPTUS ASTARTES": astartes = true
			if value in (["MOUNTED"] if mounted_only else ["MOUNTED", "SPEEDER"]): fast = true
		if not astartes or not fast: return false
	return found

static func spearpoint_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "spearpoint" in s.detachment_stratagems.get("modes", []) and s.get("combat_doctrines", {}).get("detachment", "") == "spearpoint-task-force" and player in s.get("combat_doctrines", {}).get("owners", [])

static func assault_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "assault-brethren" in s.detachment_stratagems.get("modes", []) and s.get("combat_doctrines", {}).get("detachment", "") == "assault-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func tactical_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "tactical-brethren" in s.detachment_stratagems.get("modes", []) and s.get("combat_doctrines", {}).get("detachment", "") == "tactical-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func devastator_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "devastator-brethren" in s.detachment_stratagems.get("modes", []) and s.get("combat_doctrines", {}).get("detachment", "") == "devastator-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func worthy_stratagem(s: Dictionary, player: int) -> String:
	if assault_brethren_enabled(s, player): return DUTY_IN_DEATH
	if enabled(s) and "checked" in s.detachment_stratagems.get("modes", []) and Marines.marine_army(s, player): return WORTHY
	return ""

static func armour_stratagem(s: Dictionary, player: int) -> String:
	if assault_brethren_enabled(s, player): return ASSAULT_ARMOUR
	if tactical_brethren_enabled(s, player): return TACTICAL_ARMOUR
	if devastator_brethren_enabled(s, player): return DEVASTATOR_ARMOUR
	if enabled(s) and "checked" in s.detachment_stratagems.get("modes", []) and Marines.marine_army(s, player): return ARMOUR
	return ""

static func spearpoint_unit(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var found := false
	for model: int in living(s, squad):
		found = true
		var keywords: Array = s.units[model].get("keywords", [])
		if not keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES"): return false
	return found

static func spearpoint_mounted(s: Dictionary, squad: int) -> bool:
	if not spearpoint_unit(s, squad): return false
	for model: int in living(s, squad):
		if not s.units[model].get("keywords", []).any(func(keyword: Variant) -> bool: return str(keyword).strip_edges().to_upper() == "MOUNTED"): return false
	return true

static func mobile_declaration_available(s: Dictionary, player: int, squad: int, rule: String, move_type: String = "") -> bool:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s) or not s.squads.has(squad): return false
	if int(s.squads[squad].get("owner", -1)) != player or s.squads[squad].get("battle_shocked", false) or living(s, squad).is_empty(): return false
	if s.phase not in ["movement", "charge"] or int(s.active) != player: return false
	if rule == UNSTOPPABLE_ADVANCE:
		if "ironclad-champions" not in s.detachment_stratagems.get("modes", []) or not s.get("combat_doctrines", {}).get("ironclad_champions", false) or player not in s.get("combat_doctrines", {}).get("owners", []) or not Doctrines.enduring_vengeance(s, squad): return false
	elif rule == FLAWLESS_RIDERS:
		if not spearpoint_enabled(s, player) or not spearpoint_mounted(s, squad): return false
	elif rule == MOBILE_LETHALITY:
		if not spearpoint_enabled(s, player) or s.phase != "movement" or int(s.active) != player or move_type not in ["advance", "ordered_retreat", "desperate_escape"] or not spearpoint_unit(s, squad): return false
	else: return false
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return false
	for use: Dictionary in s.stratagems.uses:
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and (str(use.get("stratagem", "")) == rule or int(use.get("squad", -1)) == squad): return false
	return true

static func withdraw_and_regroup_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s) or s.phase != "fight" or int(s.active) == player: return result
	for squad: int in s.squads:
		if _withdraw_and_regroup_available(s, player, squad): result.append(squad)
	return result

static func _withdraw_and_regroup_available(s: Dictionary, player: int, squad: int) -> bool:
	if not spearpoint_enabled(s, player) or not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or s.squads[squad].get("battle_shocked", false): return false
	if not _mounted_or_speeder(s, squad) or Queue.engaged(s, squad) or s.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	if int(s.squads[squad].get("training_cost", 0)) <= 0: return false
	for model: int in living(s, squad):
		if not s.units[model].get("on_battlefield", true): return false
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return false
	for use: Dictionary in s.stratagems.uses:
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and (str(use.get("stratagem", "")) == WITHDRAW_AND_REGROUP or int(use.get("squad", -1)) == squad): return false
	return true

static func wind_swift_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if s.phase != "fight": return result
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", -1)) == player and error(s, player, squad, WIND_SWIFT).is_empty(): result.append(squad)
	return result

static func living(s: Dictionary, squad: int) -> Array[int]:
	# A unit in reserves can still be selected by rules that target an army unit.
	var result: Array[int] = []
	for model: int in s.units:
		if s.units[model].squad == squad and s.units[model].wounds > 0: result.append(model)
	return result

static func led(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		if s.units[model].get("attachment_role", "") == "leader" and "CHARACTER" in str(s.units[model].keywords).to_upper(): return true
	return false

static func phase_key(s: Dictionary) -> String:
	return "%d:%s" % [s.turn, s.phase]

static func error(s: Dictionary, player: int, squad: int, rule: String, model: int = -1) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	rule = rule_of(rule)
	if rule != ETERNAL:
		if not s.squads.has(squad) or s.squads[squad].owner != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
		if s.squads[squad].battle_shocked: return "Battle-shocked units cannot receive friendly stratagems."
	if rule == ADAPTIVE:
		if s.phase != "command" or s.active != player or not s.get("combat_doctrines", {}).get("gladius", false) or player not in s.combat_doctrines.owners or "checked" not in s.detachment_stratagems.get("modes", []): return "Adaptive Strategy requires your Gladius Command phase."
	elif rule == STORM:
		if s.phase != "shooting" or s.active != player or not Marines.marine_army(s, player) or s.squads[squad].shot or "checked" not in s.detachment_stratagems.get("modes", []): return "Storm of Devastation requires your Gladius Shooting phase and a unit that has not shot."
	elif rule == STORM_OF_FIRE:
		if not devastator_brethren_enabled(s, player) or s.phase != "shooting" or s.active != player or s.squads[squad].shot: return "Storm of Fire requires your Devastator Brethren Shooting phase and a unit that has not shot."
	elif rule == ARMOUR:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		return armour_error(s, player, squad, int(window.get("attacker_squad", -1)), true)
	elif rule == MIGHT:
		if s.phase != "fight" or not Marines.marine_army(s, player) or s.squads[squad].fought or "checked" not in s.detachment_stratagems.get("modes", []): return "Might of Angels requires a Gladius unit selected to fight."
		if s.fight_selected != squad and s.fight_actor != player: return "Might of Angels requires a Gladius unit selected to fight."
	elif rule == HUNGRY:
		if s.phase != "fight" or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].fought or s.get("fight_selected", -1) == squad: return "Hungry Void requires an Awakened unit not yet selected to fight."
	elif rule == SUDDEN:
		if s.phase != "movement" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []): return "Sudden Storm requires your Awakened Movement phase."
	elif rule == TYRANT:
		if s.phase != "shooting" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].shot: return "Conquering Tyrant requires your Awakened Shooting phase and a unit that has not shot."
	elif rule == WORTHY:
		if s.phase != "fight" or s.squads[squad].fought or worthy_stratagem(s, player).is_empty(): return "Duty in Death or A Worthy Death requires an eligible unit in the Fight phase."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		if window.get("kind", "") != WORTHY_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or int(declaration.get("player", -1)) == player: return "An enemy attack must target this unit before it can use this stratagem."
		var declared_target := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: declared_target = true
		if not declared_target: return "The pending enemy attack does not target this unit."
	elif rule == TACTICS:
		if s.phase != "movement" or s.active == player or not Marines.marine_army(s, player) or "checked" not in s.detachment_stratagems.get("modes", []): return "Responsive Tactics is used in your opponent's Movement phase."
		if Queue.engaged(s, squad) or not _infantry_or_mounted(s, squad): return "Responsive Tactics requires an unengaged Adeptus Astartes Infantry or Mounted unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		if moved.get("phase_key", "") != phase_key(s) or int(moved.get("owner", player)) == player: return "An enemy unit must have just ended a move."
		if not _within(s, squad, int(moved.squad), 8.0): return "Responsive Tactics requires the enemy move to end within 8 inches."
	elif rule == MASTERFUL_TACTICS:
		if not tactical_brethren_enabled(s, player) or s.phase != "movement" or s.active == player: return "Masterful Tactics is used in the opponent's Movement phase with Tactical Brethren."
		if Queue.engaged(s, squad) or not _marine_infantry_or_mounted(s, squad): return "Masterful Tactics requires an unengaged Adeptus Astartes Infantry or Mounted unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		if moved.get("phase_key", "") != phase_key(s) or int(moved.get("owner", player)) == player: return "An enemy unit must have just ended a move."
		if not _within(s, squad, int(moved.squad), 8.0): return "Masterful Tactics requires the enemy move to end within 8 inches."
	elif rule == DOMINATION_FIRE:
		if not tactical_brethren_enabled(s, player) or s.phase != "shooting" or s.active != player: return "Domination Fire requires your Tactical Brethren Shooting phase."
		var pending: Dictionary = s.detachment_stratagems.get("domination_pending", {}).get(squad, {})
		if pending.get("phase_key", "") != phase_key(s) or int(pending.get("owner", -1)) != player or not s.squads[squad].shot: return "Domination Fire requires a Tactical Brethren unit that has just shot and hit a target."
	elif rule == HAIL_OF_VENGEANCE:
		var pending: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
		if not devastator_brethren_enabled(s, player) or s.phase != "shooting" or s.active == player or pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player: return "Hail of Vengeance requires a Devastator Brethren unit destroyed by an enemy Shooting attack."
		if squad not in pending.get("victims", []) or living(s, squad).is_empty(): return "Hail of Vengeance targets a friendly unit that lost a model to the pending enemy shooting attack."
		if living(s, int(pending.get("attacker", -1))).is_empty(): return "The enemy shooting unit must still be on the battlefield."
	elif rule == HUNTERS_INSTINCTS:
		if not spearpoint_enabled(s, player) or s.phase != "movement" or int(s.active) == player: return "Hunter's Instincts is used in your opponent's Movement phase."
		if Queue.engaged(s, squad) or not _spearpoint_reactive_unit(s, squad): return "Hunter's Instincts requires an unengaged Adeptus Astartes Infantry, Mounted or Speeder unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		if moved.get("phase_key", "") != phase_key(s) or int(moved.get("owner", player)) == player: return "An enemy unit must have just ended a move."
		if not _within(s, squad, int(moved.squad), 8.0): return "Hunter's Instincts requires the enemy move to end within 8 inches."
	elif rule == WIND_SWIFT:
		if not stormlance_enabled(s, player) or s.phase != "fight" or not s.squads[squad].get("fight_eligible", false) or not stormlance_unit(s, squad, true): return "Wind-Swift Evasion requires a Stormlance Mounted unit that was eligible to fight this phase."
	elif rule == SUDDEN_ONSLAUGHT:
		if not stormlance_enabled(s, player) or s.phase != "movement" or s.active != player or s.squads[squad].moved or not stormlance_unit(s, squad): return "Sudden Onslaught requires your unmoved Stormlance Mounted or Speeder unit in the Movement phase."
		if s.get("unit_abilities", {}).get("veil_of_time_pending", {}).has(squad): return "Sudden Onslaught cannot replace an Advance already fixed to 6."
	elif rule == HURTLING_TARGETS:
		if not stormlance_enabled(s, player) or s.phase != "shooting" or s.active == player or not stormlance_unit(s, squad): return "Hurtling Targets requires an enemy Shooting attack targeting your Stormlance Mounted or Speeder unit."
	elif rule == EVASIVE_MANOEUVRES:
		if not spearpoint_enabled(s, player) or s.phase != "shooting" or s.active == player or not _mounted_or_speeder(s, squad): return "Evasive Manoeuvres requires an enemy Shooting attack targeting your Spearpoint Mounted or Speeder unit."
		var reaction: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if reaction.get("kind", "") not in ["mounted-shooting-reaction", "stormlance-hurtling"] or reaction.get("owners", []) != [player] or int(reaction.get("squad", -1)) != squad: return "No matching mounted-unit shooting reaction is pending."
		var declaration: Dictionary = reaction.get("declaration", {})
		var targeted := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: targeted = true
		if not targeted or int(declaration.get("player", player)) == player: return "The pending enemy shooting declaration does not target this unit."
	elif rule == SPEAR_THRUST:
		if not spearpoint_enabled(s, player) or s.phase != "fight" or s.fight_actor != player or s.fight_step not in ["attacks", "consolidation_reaction"] or squad not in Queue.choices(s, player) or not spearpoint_unit(s, squad): return "Spear Thrust and Sabre Swing requires your eligible Adeptus Astartes unit when it is selected to fight."
	elif rule == GENE_WROUGHT_MIGHT:
		if not assault_brethren_enabled(s, player) or s.phase != "fight" or s.fight_actor != player or s.fight_step not in ["attacks", "consolidation_reaction"] or squad not in Queue.choices(s, player) or not spearpoint_unit(s, squad): return "Gene-Wrought Might requires your eligible Adeptus Astartes unit when it is selected to fight."
	elif rule == FLAWLESS_RIDERS:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if not mobile_declaration_available(s, player, squad, rule): return "Flawless Riders requires an eligible mounted Spearpoint unit selected to move or charge, with 1 CP available."
		if window.get("kind", "") != UNSTOPPABLE_WINDOW or int(window.get("squad", -1)) != squad or window.get("owners", []) != [player] or str(window.get("trigger", "")) != s.phase: return "Flawless Riders is used when this mounted unit is selected to move or declares a charge."
	elif rule == MOBILE_LETHALITY:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var move_type := str(window.get("move_type", ""))
		if not mobile_declaration_available(s, player, squad, rule, move_type): return "Mobile Lethality requires your eligible Spearpoint Adeptus Astartes unit to be selected to Advance or Fall Back in your Movement phase, with 1 CP available."
		if window.get("kind", "") != UNSTOPPABLE_WINDOW or int(window.get("squad", -1)) != squad or window.get("owners", []) != [player] or str(window.get("trigger", "")) != "movement": return "Mobile Lethality is used when this unit is selected to Advance or Fall Back."
	elif rule == WITHDRAW_AND_REGROUP:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if s.phase != "fight" or int(s.active) == player or window.get("kind", "") != "end" or player not in window.get("owners", []): return "Withdraw and Regroup is used at the end of your opponent's Fight phase."
		if not _withdraw_and_regroup_available(s, player, squad): return "Withdraw and Regroup requires an eligible, unengaged Adeptus Astartes Mounted or Speeder unit on the battlefield, with 1 CP available."
	elif rule == MERCY_IS_WEAKNESS:
		if "ironclad-champions" not in s.detachment_stratagems.get("modes", []) or not s.get("combat_doctrines", {}).get("ironclad_champions", false) or player not in s.get("combat_doctrines", {}).get("owners", []) or not Doctrines.enduring_vengeance(s, squad): return "Mercy is Weakness requires your Ironclad Champions Dreadnought unit."
		var selected_to_attack: bool = s.phase == "shooting" and s.active == player and not s.squads[squad].shot
		selected_to_attack = selected_to_attack or (s.phase == "fight" and s.fight_actor == player and s.fight_step == "attacks" and (s.fight_selected == squad or squad in Queue.choices(s, player)))
		if not selected_to_attack: return "Mercy is Weakness is used when your Dreadnought is selected to attack."
	elif rule == ADAMANTINE_TERROR:
		if "ironclad-champions" not in s.detachment_stratagems.get("modes", []) or not s.get("combat_doctrines", {}).get("ironclad_champions", false) or player not in s.get("combat_doctrines", {}).get("owners", []) or not Doctrines.enduring_vengeance(s, squad): return "Adamantine Terror requires your Ironclad Champions Dreadnought unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if s.phase != "fight" or window.get("kind", "") != "start" or window.get("owners", []).is_empty() or int(window.owners[0]) != player: return "Adamantine Terror is used at the start of the Fight phase."
		if adamantine_targets(s, squad).is_empty(): return "Adamantine Terror requires at least one enemy unit engaged with this Dreadnought."
	elif rule == UNSTOPPABLE_ADVANCE:
		if not mobile_declaration_available(s, player, squad, rule): return "Unstoppable Advance requires your eligible Ironclad Champions Dreadnought to be selected to move or charge, with 1 CP available."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != UNSTOPPABLE_WINDOW or int(window.get("squad", -1)) != squad or window.get("owners", []) != [player]: return "Unstoppable Advance is used when this Dreadnought is selected to move or declares a charge."
		if str(window.get("trigger", "")) != str(s.phase): return "Unstoppable Advance is only available for the selected Movement or Charge phase action."
	elif rule == IRONSTORM_MIGHT:
		if not ironstorm_enabled(s, player) or s.phase != "command" or int(s.active) != player or not ironstorm_vehicle_unit(s, squad): return "Might of the Machine Spirit requires your Command phase and an eligible Ironstorm Vehicle unit."
	elif rule == IRONSTORM_HEADHUNTER:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		if not ironstorm_enabled(s, player) or s.phase != "shooting" or int(s.active) != player or s.squads[squad].shot or not ironstorm_vehicle_unit(s, squad): return "Headhunter Doctrine requires an eligible Ironstorm Vehicle selected to shoot in your Shooting phase."
		if window.get("kind", "") != HEADHUNTER_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad: return "Headhunter Doctrine is used when the Vehicle is selected to shoot."
	elif rule == IRONSTORM_LAYERED_CERAMITE:
		if not ironstorm_enabled(s, player) or not layered_ceramite_triggered(s, squad): return "Layered Ceramite is available when this friendly Ironstorm Vehicle suffers a mortal wound."
	elif rule == UNDYING:
		var after: Dictionary = s.detachment_stratagems.get("after", {})
		if player not in s.get("awakened_dynasty", {}).get("owners", []): return "Undying Legions requires an Awakened unit."
		if after.get("phase_key", "") != phase_key(s) or squad not in after.get("victims", []): return "Undying Legions is used just after an enemy unit destroys models in your unit."
	elif rule == ETERNAL:
		if player not in s.get("awakened_dynasty", {}).get("owners", []): return "Eternal Revenant requires an Awakened Infantry Character."
		if s.get("unit_abilities", {}).get("window", {}).get("kind", "") != "end": return "Eternal Revenant is used at the end of the phase."
		var destroyed := _destroyed_record(s, player, squad, model)
		if destroyed.is_empty(): return "Eternal Revenant requires a Necron Infantry Character destroyed this phase."
		if s.detachment_stratagems.revived.has(destroyed.model): return "Each model can return with Eternal Revenant only once per battle."
	elif rule == VENGEFUL:
		if s.phase != "shooting" or s.active == player or player not in s.get("awakened_dynasty", {}).get("owners", []): return "Vengeful Stars is used in your opponent's Shooting phase."
		if not s.detachment_stratagems.get("vengeful", {}).is_empty() and s.detachment_stratagems.vengeful.get("phase_key", "") == phase_key(s): return "A Vengeful Stars shooting is already waiting."
		if not _character_unit(s, squad): return "Vengeful Stars requires a living Necron Character unit."
		var after: Dictionary = s.detachment_stratagems.get("after", {})
		if after.get("phase_key", "") != phase_key(s) or after.get("wiped", []).is_empty(): return "Vengeful Stars is used just after an enemy unit destroys a nearby Necron unit."
		if living(s, int(after.get("attacker", -1))).is_empty(): return "The destroying unit must still be on the battlefield."
		if not _near_wiped(s, squad, after.wiped, 6.0): return "Vengeful Stars requires a Character within 6 inches of the destroyed unit."
	else: return "Unknown detachment stratagem."
	var stratagem_cost := 2 if rule == HAIL_OF_VENGEANCE else 1
	if s.cp.get(player, 0) < maxi(0, stratagem_cost - A.discount(s, player, squad)): return "This stratagem costs %d CP; arm an eligible discount first." % stratagem_cost
	for use: Dictionary in s.stratagems.uses:
		if use.player == player and use.phase_key == phase_key(s):
			if use.stratagem == rule or (rule == ARMOUR and use.stratagem in [ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR]) or (rule == WORTHY and use.stratagem == DUTY_IN_DEATH): return "This stratagem has already been used this phase."
			if use.squad == squad: return "This unit already received a stratagem this phase."
	return ""

static func layered_ceramite_triggered(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad) or not ironstorm_vehicle_unit(s, squad, true): return false
	if living(s, squad).is_empty(): return false
	var hazard: Dictionary = s.get("pending_hazard", {})
	if int(hazard.get("squad", -1)) == squad and int(hazard.get("remaining", 0)) > 0: return true
	var escape: Dictionary = s.get("pending_move", {})
	if int(escape.get("squad", -1)) == squad and int(escape.get("hazard_remaining", 0)) > 0: return true
	var transport: Dictionary = s.get("unit_abilities", {}).get("transport_window", {})
	if int(transport.get("passenger_squad", -1)) == squad and transport.get("stage", "") == "hazard" and int(transport.get("hazard_remaining", 0)) > 0: return true
	var attack: Dictionary = s.get("pending_attack", {})
	var current: Dictionary = attack.get("current", {})
	if not current.is_empty() and current.get("phase", "") in ["damage", "damage_finalize", "damage_ability", "damage_decision", "damage_after_ability"] and int(current.get("target", -1)) == squad and int(current.get("cursor", 0)) < current.get("steps", []).size() and current.steps[int(current.cursor)].get("kind", "") == "devastating": return true
	var demise: Dictionary = s.get("pending_deadly_demise", {})
	if not demise.is_empty() and int(demise.get("packet_cursor", 0)) < demise.get("packets", []).size():
		var packet: Dictionary = demise.packets[int(demise.packet_cursor)]
		if int(packet.get("target", -1)) == squad and int(packet.get("remaining", 0)) > 0: return true
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var mortal_windows := ["explosives", "crushing-impact-mortal", "hammer-of-wrath-mortal", "tigurius-telepathic-assault-mortal", "incursor-haywire-mortal"]
	if str(window.get("kind", "")) in mortal_windows and int(window.get("target", -1)) == squad: return true
	return false

static func layered_ceramite_choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not ironstorm_enabled(s, player): return result
	for squad: int in s.squads:
		if error(s, player, squad, IRONSTORM_LAYERED_CERAMITE).is_empty():
			result.append({"label": "Ironstorm Layered Ceramite: %s gains Feel No Pain 5+ against mortal wounds (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_LAYERED_CERAMITE})
	return result

static func armour_error(s: Dictionary, player: int, squad: int, attacker_squad: int, require_window: bool = false) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
	if s.squads[squad].get("battle_shocked", false): return "Battle-shocked units cannot receive friendly stratagems."
	var doctrine: Dictionary = s.get("combat_doctrines", {})
	var assault_brethren := assault_brethren_enabled(s, player)
	var tactical_brethren := tactical_brethren_enabled(s, player)
	var devastator_brethren := devastator_brethren_enabled(s, player)
	var gladius: bool = Marines.marine_army(s, player) and doctrine.get("gladius", false) and player in doctrine.get("owners", []) and "checked" in s.detachment_stratagems.get("modes", [])
	if not assault_brethren and not tactical_brethren and not devastator_brethren and not gladius: return "Armour of Contempt requires a supported Adeptus Astartes detachment."
	if s.phase == "shooting":
		if int(s.active) == player: return "Armour of Contempt is used in your opponent's Shooting phase."
	elif s.phase != "fight": return "Armour of Contempt requires the opponent's Shooting phase or the Fight phase."
	for model: int in living(s, squad):
		if "ADEPTUS ASTARTES" not in s.units[model].get("keywords", []): return "Armour of Contempt targets a friendly ADEPTUS ASTARTES unit."
	if attacker_squad < 0 or not s.squads.has(attacker_squad) or int(s.squads[attacker_squad].get("owner", -1)) == player or living(s, attacker_squad).is_empty(): return "An enemy unit must target this unit."
	if require_window:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != ARMOUR_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or int(window.get("attacker_squad", -1)) != attacker_squad: return "No matching Armour of Contempt target decision is pending."
		var declaration: Dictionary = window.get("declaration", {})
		if int(declaration.get("squad", -1)) != attacker_squad or int(declaration.get("player", -1)) != int(s.squads[attacker_squad].owner): return "The enemy attack declaration no longer matches this target."
		var declared_target := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: declared_target = true
		if not declared_target: return "The declared enemy attack does not target this unit."
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return "This stratagem costs 1 CP; arm an eligible discount first."
	for use: Dictionary in s.stratagems.uses:
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s):
			if str(use.get("stratagem", "")) in [ARMOUR, ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR]: return "Armour of Contempt has already been used this phase."
			if int(use.get("squad", -1)) == squad: return "This unit already received a stratagem this phase."
	return ""

static func use_armour(s: Dictionary, player: int, squad: int, attacker_squad: int) -> String:
	var failure := armour_error(s, player, squad, attacker_squad, true)
	if not failure.is_empty(): return failure
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, squad))
	A.consume_discount(s, player, squad)
	var source_rule := armour_stratagem(s, player)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": source_rule, "phase_key": phase_key(s), "turn": s.turn})
	s.detachment_stratagems.armour[squad] = {"phase_key": phase_key(s), "attacker": attacker_squad, "source": source_rule}
	return ""

static func spend_sudden_onslaught(s: Dictionary, player: int, squad: int) -> String:
	var failure := error(s, player, squad, SUDDEN_ONSLAUGHT)
	if not failure.is_empty(): return failure
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, squad))
	A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": SUDDEN_ONSLAUGHT, "phase_key": phase_key(s), "turn": s.turn})
	s.detachment_stratagems.sudden_onslaught[squad] = {"phase_key": phase_key(s)}
	return ""

static func use_hurtling(s: Dictionary, player: int, squad: int) -> String:
	var failure := error(s, player, squad, HURTLING_TARGETS)
	if not failure.is_empty(): return failure
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, squad))
	A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": HURTLING_TARGETS, "phase_key": phase_key(s), "turn": s.turn})
	s.detachment_stratagems.hurtling[squad] = {"phase_key": phase_key(s)}
	return ""

static func use_evasive_manoeuvres(s: Dictionary, player: int, squad: int) -> String:
	var failure := error(s, player, squad, EVASIVE_MANOEUVRES)
	if not failure.is_empty(): return failure
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, squad))
	A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": EVASIVE_MANOEUVRES, "phase_key": phase_key(s), "turn": s.turn})
	s.detachment_stratagems.evasive[squad] = {"phase_key": phase_key(s)}
	return ""

static func hurtling_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and stormlance_enabled(s, int(s.squads[squad].owner)) and s.detachment_stratagems.get("hurtling", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func evasive_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and spearpoint_enabled(s, int(s.squads[squad].owner)) and s.detachment_stratagems.get("evasive", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func mark_spotted(s: Dictionary, enemy: int, source: int) -> void:
	if not s.detachment_stratagems.has("spotted"): s.detachment_stratagems.spotted = {}
	if not s.detachment_stratagems.has("spotted_sources"): s.detachment_stratagems.spotted_sources = {}
	s.detachment_stratagems.spotted[enemy] = {"source": source, "turn": s.turn}
	s.detachment_stratagems.spotted_sources[source] = phase_key(s)

static func spotted(s: Dictionary, enemy: int) -> bool:
	return enabled(s) and s.detachment_stratagems.get("spotted", {}).has(enemy)

static func spotted_source_used(s: Dictionary, source: int) -> bool:
	return enabled(s) and str(s.detachment_stratagems.get("spotted_sources", {}).get(source, "")) == phase_key(s)

static func choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not enabled(s): return result
	for squad: int in s.squads:
		if error(s, player, squad, ADAPTIVE).is_empty():
			for doctrine in ["devastator", "tactical", "assault"]:
				result.append({"label": "Gladius Adaptive Strategy: %s / %s (%d CP, replaces doctrine)" % [s.squads[squad].name, doctrine, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": doctrine})
		if error(s, player, squad, STORM).is_empty(): result.append({"label": "Gladius Storm of Devastation: %s (ranged Ignores Cover; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM})
		if error(s, player, squad, STORM_OF_FIRE).is_empty():
			var bonus_text := "Ignores Cover and +1 AP" if Doctrines.has_doctrine(s, squad, "devastator") else "Ignores Cover"
			result.append({"label": "Devastator Brethren Storm of Fire: %s (%s; %d CP)" % [s.squads[squad].name, bonus_text, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM_OF_FIRE})
		if error(s, player, squad, HAIL_OF_VENGEANCE).is_empty():
			var pending_hail_choice: Dictionary = s.detachment_stratagems.hail_of_vengeance_pending
			result.append({"label": "Devastator Brethren Hail of Vengeance: %s shoots %s (2 CP)" % [s.squads[squad].name, s.squads[int(pending_hail_choice.attacker)].name], "action": "detachment-stratagem", "model": -1, "target": squad, "value": HAIL_OF_VENGEANCE})
		if error(s, player, squad, MIGHT).is_empty(): result.append({"label": "Gladius Might of Angels: %s (melee Lance; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MIGHT})
		if error(s, player, squad, HUNGRY).is_empty(): result.append({"label": "Hungry Void: %s (+1 melee S; led: +1 AP; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": HUNGRY})
		if error(s, player, squad, SUDDEN).is_empty(): result.append({"label": "Sudden Storm: %s (ranged Assault this turn%s; %d CP)" % [s.squads[squad].name, "; led: re-roll Advance" if led(s, squad) else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SUDDEN})
		if error(s, player, squad, TYRANT).is_empty(): result.append({"label": "Conquering Tyrant: %s (half range hit re-roll; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TYRANT})
		if error(s, player, squad, TACTICS).is_empty(): result.append({"label": "Gladius Responsive Tactics: %s (D6 inch reaction move; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TACTICS})
		if error(s, player, squad, MASTERFUL_TACTICS).is_empty():
			var movement_distance := "6 inches (Tactical Doctrine)" if Doctrines.has_doctrine(s, squad, "tactical") else "D6 inches"
			result.append({"label": "Tactical Brethren Masterful Tactics: %s (Normal Move up to %s; %d CP)" % [s.squads[squad].name, movement_distance, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MASTERFUL_TACTICS})
		if error(s, player, squad, DOMINATION_FIRE).is_empty():
			var pending: Dictionary = s.detachment_stratagems.domination_pending.get(squad, {})
			for enemy: int in pending.get("targets", []):
				if not s.squads.has(enemy) or s.squads[enemy].owner == player or living(s, enemy).is_empty(): continue
				result.append({"label": "Tactical Brethren Domination Fire: suppress %s (-1 to Hit until your next turn; %d CP)" % [s.squads[enemy].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "enemy_target": enemy, "value": DOMINATION_FIRE})
		if error(s, player, squad, HUNTERS_INSTINCTS).is_empty(): result.append({"label": "Spearpoint Hunter's Instincts: %s (Normal Move up to D3+3 inches; 1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": HUNTERS_INSTINCTS})
		if error(s, player, squad, WIND_SWIFT).is_empty(): result.append({"label": "Stormlance Wind-Swift Evasion: %s (move up to 6 inches; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": WIND_SWIFT})
		if error(s, player, squad, SPEAR_THRUST).is_empty():
			var cost := maxi(0, 1 - A.discount(s, player, squad))
			if spearpoint_mounted(s, squad): result.append({"label": "Spearpoint Spear Thrust and Sabre Swing: %s (Lethal Hits + Lance; %d CP)" % [s.squads[squad].name, cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SPEAR_THRUST, "mode": "both"})
			else:
				result.append({"label": "Spearpoint Spear Thrust and Sabre Swing: %s (Lethal Hits; %d CP)" % [s.squads[squad].name, cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SPEAR_THRUST, "mode": "lethal"})
				result.append({"label": "Spearpoint Spear Thrust and Sabre Swing: %s (Lance; %d CP)" % [s.squads[squad].name, cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SPEAR_THRUST, "mode": "lance"})
		if error(s, player, squad, GENE_WROUGHT_MIGHT).is_empty(): result.append({"label": "Assault Brethren Gene-Wrought Might: %s gains Lance%s (%d CP)" % [s.squads[squad].name, " and +1 AP with Assault Doctrine" if Doctrines.has_doctrine(s, squad, "assault") else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": GENE_WROUGHT_MIGHT})
		if error(s, player, squad, MERCY_IS_WEAKNESS).is_empty():
			result.append({"label": "Ironclad Mercy is Weakness: %s — Lethal Hits (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MERCY_IS_WEAKNESS, "mode": "lethal"})
			result.append({"label": "Ironclad Mercy is Weakness: %s — Sustained Hits 1 (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MERCY_IS_WEAKNESS, "mode": "sustained"})
		if error(s, player, squad, ADAMANTINE_TERROR).is_empty(): result.append({"label": "Ironclad Adamantine Terror: %s forces engaged enemies to take Battle-shock at -1 (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": ADAMANTINE_TERROR})
		if error(s, player, squad, UNSTOPPABLE_ADVANCE).is_empty(): result.append({"label": "Ironclad Unstoppable Advance: %s gains Mobile (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": UNSTOPPABLE_ADVANCE})
		if error(s, player, squad, IRONSTORM_MIGHT).is_empty(): result.append({"label": "Ironstorm Might of the Machine Spirit: %s ignores Move/BS/Hit/Wound modifiers until your next Command phase (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_MIGHT})
		if error(s, player, squad, IRONSTORM_HEADHUNTER).is_empty(): result.append({"label": "Ironstorm Headhunter Doctrine: %s gains Lethal Hits against Monster/Vehicle targets this phase (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_HEADHUNTER})
		if error(s, player, squad, FLAWLESS_RIDERS).is_empty(): result.append({"label": "Spearpoint Flawless Riders: %s gains Mobile (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": FLAWLESS_RIDERS})
		if error(s, player, squad, WITHDRAW_AND_REGROUP).is_empty(): result.append({"label": "Spearpoint Withdraw and Regroup: place %s in Strategic Reserves (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": WITHDRAW_AND_REGROUP})
		if error(s, player, squad, UNDYING).is_empty(): result.append({"label": "Undying Legions: %s (Reanimation D3%s; %d CP)" % [s.squads[squad].name, "+1 if led" if led(s, squad) else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": UNDYING})
		if error(s, player, squad, VENGEFUL).is_empty(): result.append({"label": "Vengeful Stars: %s shoots the destroying unit (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": VENGEFUL})
		for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
			if int(record.get("owner", -1)) != player or record.get("phase_key", "") != phase_key(s): continue
			if error(s, player, int(record.squad), ETERNAL, int(record.model)).is_empty():
				result.append({"label": "Eternal Revenant: return model %d (%d CP, half wounds, unattached)" % [int(record.model), maxi(0, 1 - A.discount(s, player, int(record.squad)))], "action": "detachment-stratagem", "model": int(record.model), "target": int(record.squad), "value": ETERNAL})
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("player", -1)) == player:
		result.append({"label": "Decline Vengeful Stars shooting", "action": "vengeful-pass", "model": -1, "target": int(vengeful.squad), "value": ""})
	var pending_hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	if pending_hail.get("phase_key", "") == phase_key(s) and int(pending_hail.get("player", -1)) == player:
		result.append({"label": "Decline Hail of Vengeance shooting", "action": "vengeful-pass", "model": -1, "target": -1, "value": ""})
	return result

static func rule_of(value: String) -> String:
	if value in ["devastator", "tactical", "assault"]: return ADAPTIVE
	if value == ASSAULT_ARMOUR: return ARMOUR
	if value == TACTICAL_ARMOUR: return ARMOUR
	if value == DEVASTATOR_ARMOUR: return ARMOUR
	if value == DUTY_IN_DEATH: return WORTHY
	return value

static func apply(s: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var source_rule := str(selected.value)
	var rule := rule_of(source_rule)
	var failure := error(s, player, selected.target, source_rule, selected.model)
	if not failure.is_empty(): return {"error": failure}
	if rule == ADAPTIVE and selected.value not in ["devastator", "tactical", "assault"]: return {"error": "Invalid doctrine."}
	if rule == MERCY_IS_WEAKNESS and selected.get("mode", "") not in ["lethal", "sustained"]: return {"error": "Choose Lethal Hits or Sustained Hits 1."}
	if rule == SPEAR_THRUST:
		var allowed_modes := ["both"] if spearpoint_mounted(s, int(selected.target)) else ["lethal", "lance"]
		if selected.get("mode", "") not in allowed_modes: return {"error": "Choose Lethal Hits, Lance, or the combined Mounted effect."}
	if rule == WIND_SWIFT:
		s.cp[player] -= maxi(0, 1 - A.discount(s, player, selected.target))
		A.consume_discount(s, player, selected.target)
		s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": rule, "phase_key": phase_key(s), "turn": s.turn})
		s.detachment_stratagems.wind_swift[selected.target] = {"phase_key": phase_key(s)}
		TacticalFluidity.start_wind(s, player, int(selected.target), TacticalFluidity.wind_mode(s, int(selected.target)))
		return {"error": "", "message": "Wind-Swift Evasion: move up to 6 inches."}
	var inches := 0
	if rule in [TACTICS, HUNTERS_INSTINCTS, MASTERFUL_TACTICS]:
		if rule == MASTERFUL_TACTICS and Doctrines.has_doctrine(s, int(selected.target), "tactical"):
			inches = 6
		else:
			if not roller.is_valid(): return {"error": "%s requires the host's die." % ("Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "Masterful Tactics" if rule == MASTERFUL_TACTICS else "Responsive Tactics")}
			var rolled: Variant = roller.call()
			var maximum := 3 if rule == HUNTERS_INSTINCTS else 6
			if not rolled is int or rolled < 1 or rolled > maximum: return {"error": "%s die result is outside its legal range." % ("Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "D6" if rule == MASTERFUL_TACTICS else "Responsive Tactics")}
			inches = int(rolled) + 3 if rule == HUNTERS_INSTINCTS else int(rolled)
	var terror_results: Array[Dictionary] = []
	if rule == ADAMANTINE_TERROR:
		for enemy: int in adamantine_targets(s, int(selected.target)):
			var morale: Dictionary = Morale.roll_battle_shock(s, enemy, roller, -1)
			if not morale.error.is_empty(): return morale
			morale["source"] = ADAMANTINE_TERROR
			terror_results.append(morale)
	var stratagem_cost := 2 if rule == HAIL_OF_VENGEANCE else 1
	s.cp[player] -= maxi(0, stratagem_cost - A.discount(s, player, selected.target))
	A.consume_discount(s, player, selected.target)
	var used_rule := source_rule if source_rule in [ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR, DUTY_IN_DEATH, HAIL_OF_VENGEANCE, STORM_OF_FIRE] else rule
	s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": used_rule, "phase_key": phase_key(s), "turn": s.turn})
	if rule == ADAPTIVE: s.unit_abilities.doctrines[selected.target] = {"doctrine": selected.value}
	elif rule == STORM: s.detachment_stratagems.storm[selected.target] = {"phase_key": phase_key(s)}
	elif rule == STORM_OF_FIRE: s.detachment_stratagems.storm[selected.target] = {"phase_key": phase_key(s), "source": STORM_OF_FIRE, "devastator_bonus": Doctrines.has_doctrine(s, int(selected.target), "devastator")}
	elif rule == ARMOUR:
		var armour_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		s.detachment_stratagems.armour[selected.target] = {"phase_key": phase_key(s), "attacker": int(armour_window.get("attacker_squad", -1))}
	elif rule == MIGHT: s.detachment_stratagems.might[selected.target] = {"phase_key": phase_key(s)}
	elif rule == WORTHY:
		s.detachment_stratagems.worthy[selected.target] = {"phase_key": phase_key(s), "source": source_rule}
	elif rule == HUNGRY: s.detachment_stratagems.hungry[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == SUDDEN: s.detachment_stratagems.sudden[selected.target] = {"turn": s.turn, "phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == TYRANT: s.detachment_stratagems.tyrant[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == SPEAR_THRUST:
		if not s.detachment_stratagems.has("spearpoint_melee"): s.detachment_stratagems.spearpoint_melee = {}
		s.detachment_stratagems.spearpoint_melee[selected.target] = {"phase_key": phase_key(s), "mode": str(selected.mode)}
	elif rule == GENE_WROUGHT_MIGHT:
		if not s.detachment_stratagems.has("gene_wrought"): s.detachment_stratagems.gene_wrought = {}
		s.detachment_stratagems.gene_wrought[selected.target] = {"phase_key": phase_key(s)}
	elif rule in [TACTICS, HUNTERS_INSTINCTS, MASTERFUL_TACTICS]:
		var origins := {}
		for model: int in living(s, selected.target): origins[model] = s.units[model].position
		s.detachment_stratagems.tactics[selected.target] = {"inches": inches, "origins": origins, "phase_key": phase_key(s), "source": rule}
		s.unit_abilities.window = {"kind": "tactics", "owners": [player], "squad": selected.target, "positions": {}, "source": rule}
		var move_name := "Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "Masterful Tactics" if rule == MASTERFUL_TACTICS else "Responsive Tactics"
		return {"error": "", "message": "%s: Normal Move up to %d inches; preview every model and confirm." % [move_name, inches]}
	elif rule == DOMINATION_FIRE:
		var enemy_target := int(selected.get("enemy_target", -1))
		var pending: Dictionary = s.detachment_stratagems.domination_pending.get(selected.target, {})
		if enemy_target not in pending.get("targets", []): return {"error": "Choose an enemy unit hit by this unit's attack."}
		s.detachment_stratagems.suppressed[enemy_target] = {"owner": player, "turn": s.turn, "source": DOMINATION_FIRE}
		s.detachment_stratagems.domination_pending.erase(selected.target)
	elif rule == UNDYING:
		var victims: Array = s.detachment_stratagems.after.get("victims", [])
		victims.erase(selected.target)
		s.detachment_stratagems.after.victims = victims
		return {"error": "", "undying": selected.target, "led": led(s, selected.target)}
	elif rule == VENGEFUL:
		s.detachment_stratagems.vengeful = {"player": player, "squad": selected.target, "attacker": int(s.detachment_stratagems.after.attacker), "phase_key": phase_key(s)}
	elif rule == HAIL_OF_VENGEANCE:
		var pending_hail: Dictionary = s.detachment_stratagems.hail_of_vengeance_pending
		s.detachment_stratagems.hail_of_vengeance = {"player": player, "squad": selected.target, "attacker": int(pending_hail.attacker), "phase_key": phase_key(s)}
		s.detachment_stratagems.hail_of_vengeance_pending = {}
	elif rule == MERCY_IS_WEAKNESS: s.detachment_stratagems.mercy[selected.target] = {"phase_key": phase_key(s), "mode": str(selected.mode)}
	elif rule == ADAMANTINE_TERROR:
		for result: Dictionary in terror_results:
			s.squads[int(result.squad)].battle_shocked = bool(s.squads[int(result.squad)].battle_shocked) or not bool(result.passed)
		s.last_adamantine_terror = terror_results.duplicate(true)
		var messages: Array[String] = []
		for result: Dictionary in terror_results:
			messages.append("%s %s (-1 = %d vs Leadership %d): %s" % [s.squads[int(result.squad)].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"])
		return {"error": "", "message": "Adamantine Terror: " + "; ".join(messages) + "."}
	elif rule == IRONSTORM_MIGHT:
		s.detachment_stratagems.might_machine_spirit[selected.target] = {"owner": player, "expires_turn": int(s.turn) + 2}
	elif rule == IRONSTORM_HEADHUNTER:
		s.detachment_stratagems.headhunter[selected.target] = {"phase_key": phase_key(s)}
	elif rule == IRONSTORM_LAYERED_CERAMITE:
		s.detachment_stratagems.layered_ceramite[selected.target] = {"phase_key": phase_key(s)}
	elif rule in [UNSTOPPABLE_ADVANCE, FLAWLESS_RIDERS, MOBILE_LETHALITY]:
		var mobile_window: Dictionary = s.unit_abilities.window.duplicate(true)
		if rule == MOBILE_LETHALITY: s.detachment_stratagems.mobile_lethality[selected.target] = {"turn": s.turn}
		else: s.detachment_stratagems.mobile[selected.target] = {"phase_key": phase_key(s)}
		s.unit_abilities.window = {}
		return {"error": "", "resume_mobile_declaration": mobile_window}
	elif rule == WITHDRAW_AND_REGROUP:
		var cost := int(s.squads[selected.target].get("training_cost", 0))
		if cost <= 0: return {"error": "This unit has no admitted reserve cost."}
		s.unit_abilities.reserves[selected.target] = {"cost": cost, "source": WITHDRAW_AND_REGROUP}
		for model: int in living(s, selected.target): s.units[model].on_battlefield = false
		s.deployment.order.erase(selected.target)
	elif rule == ETERNAL:
		var destroyed := _destroyed_record(s, player, selected.target, selected.model)
		s.detachment_stratagems.revived[destroyed.model] = true
		s.unit_abilities.window = {"kind": "eternal", "owners": [player], "model": destroyed.model, "squad": destroyed.squad, "origin": destroyed.position, "max_wounds": destroyed.max_wounds, "positions": {}}
	else: return {"error": "Unknown detachment stratagem."}
	return {"error": ""}

static func hungry_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.hungry.get(squad, {}).get("phase_key", "") == phase_key(s)

static func storm_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.storm.get(squad, {}).get("phase_key", "") == phase_key(s)

static func suppression_hit_modifier(s: Dictionary, squad: int) -> int:
	if not enabled(s) or not s.squads.has(squad) or str(s.get("combat_doctrines", {}).get("detachment", "")) != "tactical-brethren" or living(s, squad).is_empty(): return 0
	var record: Dictionary = s.detachment_stratagems.get("suppressed", {}).get(squad, {})
	if not record.is_empty() and int(s.turn) < int(record.get("turn", -2)) + 2: return -1
	return 0

static func might_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.might.get(squad, {}).get("phase_key", "") == phase_key(s)

static func sudden_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and int(s.detachment_stratagems.sudden.get(squad, {}).get("turn", -1)) == int(s.turn)

static func sudden_led_advance(s: Dictionary, squad: int) -> bool:
	return sudden_active(s, squad) and s.detachment_stratagems.sudden.get(squad, {}).get("led", false) == true and s.phase == "movement"

static func open_advance(s: Dictionary, player: int, squad: int, rolls: Array, draft: Dictionary) -> bool:
	if not enabled(s) or not s.has("stratagems"): return false
	s.stratagems.pending = {"kind": "after_advance_roll", "player": player, "squad": squad, "phase_key": phase_key(s), "rolls": rolls.duplicate(), "draft": draft.duplicate(true), "sudden": true}
	return true

static func mobile_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.get("mobile", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func mobile_lethality_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.get("mobile_lethality", {}).get(squad, {}).get("turn", -1) == s.turn

static func tyrant_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.tyrant.get(squad, {}).get("phase_key", "") == phase_key(s)

static func weapon(s: Dictionary, squad: int, original: Dictionary, profile: Dictionary, melee: bool, target_squad: int = -1) -> Dictionary:
	var copy := profile
	var mercy: Dictionary = s.get("detachment_stratagems", {}).get("mercy", {}).get(squad, {})
	var mercy_active: bool = enabled(s) and mercy.get("phase_key", "") == phase_key(s)
	if mercy_active:
		copy = copy.duplicate(true)
		if mercy.get("mode", "") == "lethal": copy.keywords["lethal-hits"] = true
		elif mercy.get("mode", "") == "sustained": copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	var spearpoint: Dictionary = s.get("detachment_stratagems", {}).get("spearpoint_melee", {}).get(squad, {})
	if melee and spearpoint.get("phase_key", "") == phase_key(s):
		copy = copy.duplicate(true)
		if spearpoint.get("mode", "") in ["lethal", "both"]: copy.keywords["lethal-hits"] = true
		if spearpoint.get("mode", "") in ["lance", "both"]: copy.keywords["lance"] = true
	if not melee and storm_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["ignores-cover"] = true
		var storm_record: Dictionary = s.detachment_stratagems.storm.get(squad, {})
		if storm_record.get("source", "") == STORM_OF_FIRE and storm_record.get("devastator_bonus", false): copy.ap = int(copy.ap) - 1
	if not melee and s.get("detachment_stratagems", {}).get("headhunter", {}).get(squad, {}).get("phase_key", "") == phase_key(s):
		var monster_or_vehicle := false
		for target_model: int in living(s, target_squad):
			var target_keywords: Array = s.units[target_model].get("keywords", [])
			if "MONSTER" in target_keywords or "VEHICLE" in target_keywords:
				monster_or_vehicle = true
				break
		if monster_or_vehicle:
			copy = copy.duplicate(true)
			copy.keywords["lethal-hits"] = true

	if not melee and mobile_lethality_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["assault"] = true
	if not melee and sudden_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["assault"] = true
	if melee and might_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["lance"] = true
	var gene_wrought: Dictionary = s.get("detachment_stratagems", {}).get("gene_wrought", {}).get(squad, {})
	if melee and gene_wrought.get("phase_key", "") == phase_key(s):
		copy = copy.duplicate(true)
		copy.keywords["lance"] = true
		if Doctrines.has_doctrine(s, squad, "assault"): copy.ap -= 1
	if melee and hungry_active(s, squad):
		copy = copy.duplicate(true)
		copy.strength += 1
		if s.detachment_stratagems.hungry[squad].led and int(copy.ap) >= int(original.ap): copy.ap -= 1
	return copy

static func might_ignore_active(s: Dictionary, squad: int) -> bool:
	if not enabled(s) or not s.squads.has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("might_machine_spirit", {}).get(squad, {})
	return not record.is_empty() and int(s.squads[squad].get("owner", -1)) == int(record.get("owner", -2)) and int(s.turn) < int(record.get("expires_turn", -1))

static func defend(s: Dictionary, attacker: int, target: int, profile: Dictionary) -> Dictionary:
	if not enabled(s): return profile
	var record: Dictionary = s.detachment_stratagems.armour.get(target, {})
	if record.get("phase_key", "") != phase_key(s): return profile
	if int(record.get("attacker", -1)) != attacker: return profile
	var copy := profile.duplicate(true)
	copy.ap = mini(0, int(copy.ap) + 1)
	return copy

static func hit_policy(s: Dictionary, squad: int, distance: float, range_inches: float) -> String:
	if not tyrant_active(s, squad) or not is_finite(distance) or not is_finite(range_inches) or range_inches <= 0.0: return ""
	if distance > range_inches / 2.0: return ""
	return "failed" if s.detachment_stratagems.tyrant[squad].led else "ones"

static func lance_wound(s: Dictionary, squad: int, profile: Dictionary) -> bool:
	return profile.get("keywords", {}).get("lance", false) == true and s.squads[squad].get("charged", false)

static func worthy_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.worthy.get(squad, {}).get("phase_key", "") == phase_key(s) and not s.squads[squad].fought

static func hold_destroyed(s: Dictionary, model: int, roller: Callable) -> Dictionary:
	if not s.units.has(model): return {"error": "", "held": false}
	var unit: Dictionary = s.units[model]
	if unit.wounds > 0 or unit.get("lingering", false): return {"error": "", "held": false}
	var current_abilities: Dictionary = s.get("unit_abilities", {})
	var identity := str(unit.get("definition_id", "")).get_slice(":", 3)
	if current_abilities.get("implementation", "") == A.ID and identity == "captain-titus" and s.phase == "fight" and not s.squads[unit.squad].fought:
		if not roller.is_valid(): return {"error": "Honour of Ultramar requires the host's D6."}
		var honour_roll: Variant = roller.call()
		if not honour_roll is int or honour_roll < 1 or honour_roll > 6: return {"error": "Honour of Ultramar dice must be 1–6."}
		if honour_roll >= 2:
			unit.wounds = 1
			unit.lingering = true
			unit.titus_honour_lingering = true
			return {"error": "", "held": true, "rule": "honour-of-ultramar", "roll": honour_roll}
	if not enabled(s): return {"error": "", "held": false}
	if worthy_active(s, unit.squad):
		var worthy: Dictionary = s.detachment_stratagems.worthy.get(unit.squad, {})
		var card_name := "Duty in Death" if worthy.get("source", "") == DUTY_IN_DEATH else "A Worthy Death"
		if not roller.is_valid(): return {"error": "%s requires the host's D6." % card_name}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "%s dice must be 1–6." % card_name}
		var doctrine_bonus := 1 if worthy.get("source", "") == DUTY_IN_DEATH and Doctrines.has_doctrine(s, unit.squad, "assault") else 0
		if int(rolled) + doctrine_bonus >= 4:
			unit.wounds = 1
			unit.lingering = true
			return {"error": "", "held": true, "roll": rolled, "modifier": doctrine_bonus}
		record_destroyed(s, model)
		return {"error": "", "held": false, "roll": rolled, "modifier": doctrine_bonus}
	record_destroyed(s, model)
	return {"error": "", "held": false}

static func remove_lingering(s: Dictionary, squad: int = -1) -> void:
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if unit.get("titus_honour_lingering", false) and (squad == -1 or unit.squad == squad):
			unit.wounds = 0
			unit.erase("titus_honour_lingering")
			unit.erase("lingering")
			record_destroyed(s, model)
	if not enabled(s): return
	for model: int in s.units:
		if s.units[model].get("lingering", false) and (squad == -1 or s.units[model].squad == squad):
			s.units[model].wounds = 0
			s.units[model].erase("lingering")
			record_destroyed(s, model)

static func record_move(s: Dictionary, squad: int) -> void:
	if enabled(s) and s.squads.has(squad): s.detachment_stratagems.last_move = {"squad": squad, "owner": s.squads[squad].owner, "phase_key": phase_key(s)}

static func after_attacks(s: Dictionary, attacker: int, targets: Array, killed: int, prepared: Dictionary = {}, resolved: Dictionary = {}) -> void:
	if not enabled(s): return
	if s.squads.has(attacker) and s.get("combat_doctrines", {}).get("detachment", "") == "tactical-brethren" and "tactical-brethren" in s.detachment_stratagems.get("modes", []) and s.phase == "shooting" and int(s.active) == int(s.squads[attacker].owner):
		var hit_targets: Array[int] = []
		var batches: Array = prepared.get("batches", [])
		var pools: Array = resolved.get("pools", [])
		for index in range(mini(batches.size(), pools.size())):
			var target := int(batches[index].get("target", -1)) if batches[index] is Dictionary else -1
			if target in hit_targets or int(pools[index].get("hits", 0)) <= 0 or not s.squads.has(target) or living(s, target).is_empty(): continue
			hit_targets.append(target)
		if not hit_targets.is_empty(): s.detachment_stratagems.domination_pending[attacker] = {"owner": int(s.squads[attacker].owner), "phase_key": phase_key(s), "targets": hit_targets}
	var cleared_armour: Array[int] = []
	for target: int in s.detachment_stratagems.get("armour", {}):
		var armour_record: Dictionary = s.detachment_stratagems.armour[target]
		if int(armour_record.get("attacker", -1)) == attacker: cleared_armour.append(target)
	for target: int in cleared_armour: s.detachment_stratagems.armour.erase(target)
	if killed <= 0: return
	var victims: Array = []
	var wiped: Array = []
	var devastator_victims: Array[int] = []
	for target: Variant in targets:
		if not target is int or not s.squads.has(target): continue
		var lost := false
		var origin := Vector2.ZERO
		var count := 0
		for model: int in s.units:
			if s.units[model].squad != target: continue
			origin += s.units[model].position
			count += 1
			if s.units[model].wounds <= 0: lost = true
		if count > 0: origin /= float(count)
		if not lost: continue
		if s.phase == "shooting" and s.squads.has(attacker) and int(s.squads[attacker].owner) == int(s.active) and not living(s, target).is_empty() and devastator_brethren_enabled(s, int(s.squads[target].owner)):
			var is_astartes := false
			for target_model: int in living(s, target):
				if "ADEPTUS ASTARTES" not in s.units[target_model].get("keywords", []): is_astartes = false; break
				is_astartes = true
			if is_astartes and int(target) not in devastator_victims: devastator_victims.append(int(target))
		if living(s, target).is_empty(): wiped.append({"squad": target, "origin": origin, "attacker": attacker})
		else: victims.append(target)
	if not victims.is_empty() or not wiped.is_empty(): s.detachment_stratagems.after = {"phase_key": phase_key(s), "attacker": attacker, "victims": victims, "wiped": wiped}
	if not devastator_victims.is_empty(): s.detachment_stratagems.hail_of_vengeance_pending = {"phase_key": phase_key(s), "player": int(s.squads[devastator_victims[0]].owner), "attacker": attacker, "victims": devastator_victims}

static func record_destroyed(s: Dictionary, model: int) -> void:
	if not enabled(s) or not s.units.has(model): return
	var unit: Dictionary = s.units[model]
	if unit.wounds > 0 or unit.get("lingering", false): return
	if not _has_keyword(unit, "CHARACTER") or not _has_keyword(unit, "INFANTRY"): return
	if unit.owner not in s.get("awakened_dynasty", {}).get("owners", []): return
	if s.detachment_stratagems.revived.has(model): return
	for record: Dictionary in s.detachment_stratagems.destroyed:
		if int(record.model) == model and record.phase_key == phase_key(s): return
	s.detachment_stratagems.destroyed.append({"model": model, "squad": unit.squad, "owner": unit.owner, "position": unit.position, "max_wounds": int(unit.get("max_wounds", 1)), "phase_key": phase_key(s)})

static func eternal_pending(s: Dictionary, owner: int) -> bool:
	if not enabled(s): return false
	for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
		if int(record.get("owner", -1)) == owner and record.get("phase_key", "") == phase_key(s) and not s.detachment_stratagems.revived.has(record.model): return true
	return false

static func vengeful_actor(s: Dictionary) -> int:
	if not enabled(s): return -1
	var shot: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if shot.get("phase_key", "") == phase_key(s) and int(shot.get("player", -1)) > 0: return int(shot.player)
	var hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance", {})
	if hail.get("phase_key", "") == phase_key(s) and int(hail.get("player", -1)) > 0: return int(hail.player)
	var pending_hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	if pending_hail.get("phase_key", "") == phase_key(s) and int(pending_hail.get("player", -1)) > 0: return int(pending_hail.player)
	return -1

static func vengeful_shooter(s: Dictionary, squad: int) -> bool:
	if vengeful_actor(s) <= 0: return false
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("squad", -1)) == squad: return true
	var hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance", {})
	return hail.get("phase_key", "") == phase_key(s) and int(hail.get("squad", -1)) == squad

static func reactive_shooting_target(s: Dictionary, squad: int) -> int:
	if not vengeful_shooter(s, squad): return -1
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("squad", -1)) == squad: return int(vengeful.get("attacker", -1))
	var hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance", {})
	if hail.get("phase_key", "") == phase_key(s) and int(hail.get("squad", -1)) == squad: return int(hail.get("attacker", -1))
	return -1

static func clear_vengeful(s: Dictionary) -> void:
	if enabled(s):
		s.detachment_stratagems.vengeful = {}
		s.detachment_stratagems.hail_of_vengeance = {}
		s.detachment_stratagems.hail_of_vengeance_pending = {}

static func _infantry_or_mounted(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		for keyword: Variant in s.units[model].get("keywords", []):
			if str(keyword).strip_edges().to_upper() in ["INFANTRY", "MOUNTED"]: return true
	return false

static func _marine_infantry_or_mounted(s: Dictionary, squad: int) -> bool:
	var found := false
	for model: int in living(s, squad):
		var keywords: Array = s.units[model].get("keywords", [])
		if "ADEPTUS ASTARTES" not in keywords or ("INFANTRY" not in keywords and "MOUNTED" not in keywords): return false
		found = true
	return found

static func _mounted_or_speeder(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var found := false
	for model: int in living(s, squad):
		found = true
		if not _has_keyword(s.units[model], "ADEPTUS ASTARTES") or not (_has_keyword(s.units[model], "MOUNTED") or _has_keyword(s.units[model], "SPEEDER")): return false
	return found

static func _spearpoint_reactive_unit(s: Dictionary, squad: int) -> bool:
	if not spearpoint_unit(s, squad): return false
	for model: int in living(s, squad):
		for keyword: String in ["INFANTRY", "MOUNTED", "SPEEDER"]:
			if _has_keyword(s.units[model], keyword): return true
	return false

static func _within(s: Dictionary, squad: int, other: int, inches: float) -> bool:
	for model: int in living(s, squad):
		if G.distance_to_target(s, s.units[model], other) <= inches + 0.001: return true
	return false

static func tactics_position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var record: Dictionary = s.detachment_stratagems.get("tactics", {}).get(window.get("squad", -1), {})
	var movement_source := "Hunter's Instincts" if record.get("source", "") == HUNTERS_INSTINCTS else "Masterful Tactics" if record.get("source", "") == MASTERFUL_TACTICS else "Responsive Tactics"
	if window.get("kind", "") != "tactics" or not s.units.has(model) or s.units[model].squad != window.squad: return "This is not a %s placement." % movement_source
	if not record.has("origins") or not record.origins.has(model): return "This model cannot make the reaction move."
	if not point.is_finite(): return "Choose a finite reaction destination."
	if record.origins[model].distance_to(point) > float(record.inches) + 0.001: return "%s is a normal move of up to %s inches." % [movement_source, "D6 or 6" if movement_source == "Masterful Tactics" else "D6" if movement_source == "Responsive Tactics" else "D3+3"]
	var half: Vector2 = s.board_size / 2.0
	var radius: float = float(s.units[model].radius)
	if absf(point.x) + radius > half.x or absf(point.y) + radius > half.y: return "The whole base must fit on the battlefield."
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0 or not s.units[other].get("on_battlefield", true): continue
		var position: Vector2 = window.positions.get(other, s.units[other].position)
		if point.distance_to(position) < radius + float(s.units[other].radius) - 0.001: return "Reaction move bases cannot overlap."
		if s.units[other].owner != s.units[model].owner and G.edge({"position": point, "radius": radius}, {"position": position, "radius": s.units[other].radius}) <= 2.001: return "The reaction move must end unengaged."
	return ""

static func confirm_tactics(s: Dictionary) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var record: Dictionary = s.get("detachment_stratagems", {}).get("tactics", {}).get(window.get("squad", -1), {})
	var movement_source := "Hunter's Instincts" if record.get("source", "") == HUNTERS_INSTINCTS else "Masterful Tactics" if record.get("source", "") == MASTERFUL_TACTICS else "Responsive Tactics"
	if window.get("kind", "") != "tactics": return {"error": "No %s move is pending." % movement_source}
	var projected := s.duplicate(true)
	for model: int in living(s, window.squad):
		var point: Vector2 = window.positions.get(model, s.units[model].position)
		var error := tactics_position_error(s, model, point)
		if not error.is_empty(): return {"error": error}
		projected.units[model].position = point
	if Queue.engaged(projected, window.squad): return {"error": "The reaction move must end unengaged."}
	for model: int in living(s, window.squad): s.units[model].position = window.positions.get(model, s.units[model].position)
	s.unit_abilities.window = {}
	return {"error": ""}

static func eternal_position_error(s: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "eternal" or int(window.get("model", -1)) != model: return "This is not an Eternal Revenant placement."
	if not s.units.has(model): return "Choose the destroyed Infantry Character."
	if not point.is_finite(): return "Choose a finite set-up position."
	var radius: float = float(s.units[model].radius)
	var half: Vector2 = s.board_size / 2.0
	if absf(point.x) + radius > half.x or absf(point.y) + radius > half.y: return "The whole base must fit on the battlefield."
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0 or not s.units[other].get("on_battlefield", true): continue
		var position: Vector2 = window.positions.get(other, s.units[other].position)
		if point.distance_to(position) < radius + float(s.units[other].radius) - 0.001: return "Returned bases cannot overlap."
		if s.units[other].owner != s.units[model].owner and G.edge({"position": point, "radius": radius}, {"position": position, "radius": s.units[other].radius}) <= 2.001: return "Eternal Revenant must set up unengaged."
	return ""

static func confirm_eternal(s: Dictionary) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "eternal": return {"error": "No Eternal Revenant set-up is pending."}
	var model: int = int(window.model)
	if not window.positions.has(model): return {"error": "Preview the returned model's position before confirming."}
	var point: Vector2 = window.positions[model]
	var error := eternal_position_error(s, model, point)
	if not error.is_empty(): return {"error": error}
	_detach_revived(s, model)
	s.units[model].position = point
	s.units[model].on_battlefield = true
	s.units[model].wounds = maxi(1, ceili(float(window.max_wounds) / 2.0))
	s.units[model].erase("lingering")
	s.squads[s.units[model].squad].starting_strength = 1
	s.squads[s.units[model].squad].set_up_this_turn = true
	s.squads[s.units[model].squad].moved = true
	s.squads[s.units[model].squad].shot = true
	s.squads[s.units[model].squad].fought = true
	s.unit_abilities.window = {}
	return {"error": ""}

static func _has_keyword(unit: Dictionary, word: String) -> bool:
	for keyword: Variant in unit.get("keywords", []):
		if str(keyword).strip_edges().to_upper() == word: return true
	return false

static func _character_unit(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		if _has_keyword(s.units[model], "CHARACTER"): return true
	return false

static func _near_wiped(s: Dictionary, squad: int, wiped: Array, inches: float) -> bool:
	for record: Variant in wiped:
		if not record is Dictionary: continue
		var origin: Vector2 = record.origin
		for model: int in living(s, squad):
			if s.units[model].position.distance_to(origin) - float(s.units[model].radius) <= inches + 0.001: return true
	return false

static func _destroyed_record(s: Dictionary, player: int, squad: int, model: int) -> Dictionary:
	for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
		if record.get("phase_key", "") != phase_key(s) or int(record.owner) != player: continue
		if int(record.squad) != squad: continue
		if model != -1 and int(record.model) != model: continue
		return record
	return {}

static func _free_squad(s: Dictionary) -> int:
	var highest := 0
	for squad: int in s.squads: highest = maxi(highest, squad)
	return highest + 1

static func _detach_revived(s: Dictionary, model: int) -> void:
	var unit: Dictionary = s.units[model]
	if not unit.has("attachment_role") or unit.attachment_role == "bodyguard": return
	var body: int = unit.squad
	var origin: int = int(unit.get("component_squad", -1))
	if origin <= 0 or s.squads.has(origin): origin = _free_squad(s)
	var template: Dictionary = s.squads[body].duplicate(true)
	template.attached = false
	template.erase("components")
	template.starting_strength = 1
	s.squads[origin] = template
	if s.squads.has(body):
		s.squads[body].starting_strength = maxi(1, int(s.squads[body].starting_strength) - 1)
		var kept: Array = []
		for component: Dictionary in s.squads[body].get("components", []):
			if int(component.get("squad", -1)) != int(unit.get("component_squad", origin)): kept.append(component)
		s.squads[body].components = kept
		if kept.size() <= 1: s.squads[body].attached = false
	unit.squad = origin
	unit.erase("attachment_role")
	unit.erase("component_squad")

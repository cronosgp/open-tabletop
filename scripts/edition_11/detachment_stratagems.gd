extends RefCounted
## Current e11 detachment stratagem effects, enabled only for the selected local detachment scope.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const TemplarVows = preload("res://scripts/edition_11/templar_vows.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ID := "gladius-awakened-stratagems-11e-v9"
const ADAPTIVE := "gladius-adaptive-strategy"
const STORM := "gladius-storm-of-devastation"
const ARMOUR := "gladius-armour-of-contempt"
const MIGHT := "gladius-might-of-angels"
const WORTHY := "gladius-a-worthy-death"
const TACTICS := "gladius-responsive-tactics"
const TACTICAL_FOCUS := "tacticus-tactical-focus"
const RELENTLESS_ASSAULT := "tacticus-attack-relentless-assault"
const FIRESTORM_RELENTLESS_ASSAULT := "tacticus-firestorm-relentless-assault"
const FIRESTORM_POINT_BLANK_BRUTALITY := "tacticus-firestorm-point-blank-brutality"
const PHOBOS_STRIKE_FROM_SHADOWS := "phobos-shock-strike-from-the-shadows"
const PHOBOS_SHADOW_STRIKE_FROM_SHADOWS := "phobos-shadow-strike-from-the-shadows"
const PHOBOS_TRANSHUMAN_REACTIONS := "phobos-shock-transhuman-reactions"
const PHOBOS_UMBRAL_EVASION := "phobos-shock-umbral-evasion"
const PHOBOS_SHADOW_TACTICAL_WITHDRAWAL := "phobos-shadow-tactical-withdrawal"
const PHOBOS_SHADOW_MORTIS_SNARES := "phobos-shadow-mortis-snares"
const PHOBOS_SHADOW_MASTERS := "phobos-shadow-masters"
const PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW := "phobos-shadow-mortis-trigger"
const PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW := "phobos-shadow-mortis-damage"
const PHOBOS_SHADOW_MORTIS_MORTAL_WINDOW := "phobos-shadow-mortis-mortal"
const TRANSHUMAN_SWIFTNESS := "tacticus-transhuman-swiftness"
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
const ULTRAMARINES_ARMOUR := "ultramarines-armour-of-contempt"
const ULTRAMARINES_COURAGE := "ultramarines-courage-and-honour"
const ULTRAMARINES_EXEMPLARY_VIGILANCE := "ultramarines-exemplary-vigilance"
const ULTRAMARIAN_ADAPTIVITY := "ultramarines-adaptivity"
const ULTRAMARIAN_PRACTICAL_TACTICS := "ultramarines-practical-tactics"
const ULTRAMARINES_TACTICAL_FORESIGHT := "ultramarines-tactical-foresight"
const IRONSTORM_LAYERED_CERAMITE := "ironstorm-layered-ceramite"
const IRONSTORM_MIGHT := "ironstorm-might-of-the-machine-spirit"
const IRONSTORM_HEADHUNTER := "ironstorm-headhunter-doctrine"
const MEDUSA_SPIRITS_OF_IRON := "medusa-spirits-of-iron"
const MEDUSA_VENGEFUL_ANIMUS := "medusa-vengeful-animus"
const MEDUSA_METHODICAL_BRUTALITY := "medusa-methodical-brutality"
const MEDUSA_UNBOWED_CONVICTION := "medusa-unbowed-conviction"
const MEDUSA_ANCIENT_FURY := "medusa-ancient-fury"
const VOW_PIOUS_ENMITY := "vow-sworn-pious-enmity"
const MEDUSA_POWER_OF_MACHINE_SPIRIT := "medusa-power-of-the-machine-spirit"
const MEDUSA_ARMOURED_WRATH := "medusa-armoured-wrath"
const VENGEFUL_ANIMUS_WINDOW := "deadly-demise-vengeful-animus"
const METHODICAL_BRUTALITY_WINDOW := "medusa-methodical-brutality"
const PIOUS_ENMITY_WINDOW := "vow-sworn-pious-enmity"
const RELENTLESS_ASSAULT_WINDOW := "tacticus-relentless-assault"
const POINT_BLANK_BRUTALITY_WINDOW := "tacticus-point-blank-brutality"
const HAIL_OF_VENGEANCE := "devastator-brethren-hail-of-vengeance"
const STORM_OF_VENGEANCE := "storm-of-vengeance"
const STORM_OF_FIRE := "devastator-brethren-storm-of-fire"
const WORTHY_WINDOW := "worthy-death"
const MOVEMENT_REACTION_WINDOW := "detachment-movement-reaction"
const SHOOTING_REACTION_WINDOW := "detachment-shooting-reaction"
const MERCY_IS_WEAKNESS := "ironclad-mercy-is-weakness"
const GRAVIS_LINEBREAKER_ANNIHILATING_FORCE := "gravis-linebreaker-annihilating-force"
const GRAVIS_SIEGE_ANNIHILATING_FORCE := "gravis-siege-annihilating-force"
const GRAVIS_LINEBREAKER_PURGATION_PUSH := "gravis-linebreaker-purgation-push"
const GRAVIS_LINEBREAKER_ARMOURED_IMPACT := "gravis-linebreaker-armoured-impact"
const GRAVIS_SIEGE_STAND_UNYIELDING := "gravis-siege-stand-unyielding"
const GRAVIS_SIEGE_SUPPRESSION_VOLLEYS := "gravis-siege-suppression-volleys"
const TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE := "terminator-tactical-dreadnought-fortitude"
const TERMINATOR_MERCILESS_VETERANS := "terminator-merciless-veterans"
const TERMINATOR_GUNSHIP_EXTRACTION := "terminator-gunship-extraction"
const WINGS_OF_SHADOW := "darkflight-wings-of-shadow"
const DARKFLIGHT_WINDOW := "darkflight-wings-of-shadow"
const SKYBORNE_SURVEILLANCE := "darkflight-skyborne-surveillance"
const WE_ARE_VENGEANCE := "darkflight-we-are-vengeance"
const ADAMANTINE_TERROR := "ironclad-adamantine-terror"
const UNSTOPPABLE_ADVANCE := "ironclad-unstoppable-advance"
const UNSTOPPABLE_WINDOW := "ironclad-unstoppable-advance"
const COMBINED_DEPLOYMENT := "gauntlet-combined-deployment"
const GAUNTLET_STORM_AND_SECURE := "gauntlet-storm-and-secure"
const GAUNTLET_DUTY_IS_NEVER_DONE := "gauntlet-duty-is-never-done"
const GAUNTLET_AGGRESSIVE_DISEMBARKATION := "gauntlet-aggressive-disembarkation"
const KNIGHTS_OF_IRON := "wrath-of-the-rock-knights-of-iron"
const TACTICAL_MASTERY := "wrath-of-the-rock-tactical-mastery"
const LIONS_WILL := "wrath-of-the-rock-lions-will"
const FOR_THE_EMPEROR := "tacticus-firestorm-for-the-emperor"
const INESCAPABLE_JUSTICE := "wrath-of-the-rock-inescapable-justice"
const RELICS_OF_THE_DARK_AGE := "wrath-of-the-rock-relics-of-the-dark-age"
const IN_SACRIFICE := "wrath-of-the-rock-in-sacrifice-victory"
const INNER_CIRCLE_WRATH_OF_THE_LION := "inner-circle-wrath-of-the-lion"
const INNER_CIRCLE_DUTY_UNTO_DEATH := "inner-circle-duty-unto-death"
const INNER_CIRCLE_RELIC_TELEPORTARIUM := "inner-circle-relic-teleportarium"
const DEATHWING_CONDITIONAL_IDENTITIES := ChapterRules.DARK_ANGELS_DEATHWING_IDENTITIES
const GLADIUS_ABILITIES := [ADAPTIVE, STORM, ARMOUR, MIGHT, WORTHY, TACTICS]
const ARMOUR_WINDOW := "gladius-armour-of-contempt"
const HEADHUNTER_WINDOW := "ironstorm-headhunter-doctrine"
const GRAVIS_ANNIHILATING_WINDOW := "gravis-annihilating-force"
const TERMINATOR_FORTITUDE_WINDOW := "terminator-tactical-dreadnought-fortitude"
const TERMINATOR_MERCILESS_WINDOW := "terminator-merciless-veterans"
const PHOBOS_STRIKE_WINDOW := "phobos-strike-from-the-shadows"
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
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const VowedTarget = preload("res://scripts/edition_11/vowed_target.gd")

static func enable(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "checked" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("checked")
	if not s.detachment_stratagems.has("storm_of_vengeance_pending"): s.detachment_stratagems.storm_of_vengeance_pending = {}
	if not s.detachment_stratagems.has("storm_of_vengeance_used"): s.detachment_stratagems.storm_of_vengeance_used = {}
	for ability: String in GLADIUS_ABILITIES + [HUNGRY, SUDDEN, TYRANT, UNDYING, ETERNAL, VENGEFUL]: Registry.admit(s, ability, ID)

static func enable_gladius(s: Dictionary) -> void:
	enable(s)

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

static func enable_gauntlet(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "gauntlet-task-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("gauntlet-task-force")
	if not s.detachment_stratagems.has("gauntlet_assailed"): s.detachment_stratagems.gauntlet_assailed = {}
	if not s.detachment_stratagems.has("gauntlet_pending"): s.detachment_stratagems.gauntlet_pending = {}
	Registry.admit(s, COMBINED_DEPLOYMENT, ID)
	Registry.admit(s, "linebreaker-onslaught", ID)
	Registry.admit(s, "damocles-class-uplink", ID)
	Registry.admit(s, GAUNTLET_STORM_AND_SECURE, ID)
	Registry.admit(s, GAUNTLET_DUTY_IS_NEVER_DONE, ID)
	Registry.admit(s, GAUNTLET_AGGRESSIVE_DISEMBARKATION, ID)

static func gauntlet_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "gauntlet-task-force" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and player in s.get("combat_doctrines", {}).get("owners", []) and Doctrines.detachment_for(s, player) == "gauntlet-task-force"

static func gauntlet_duty_cost(s: Dictionary, player: int, squad: int) -> int:
	return maxi(0, 1 - A.discount(s, player, squad))

static func gauntlet_aggressive_disembarkation_cost(s: Dictionary, player: int, squad: int) -> int:
	return maxi(0, 1 - A.discount(s, player, squad))

static func gauntlet_assailed(s: Dictionary, attacker_squad: int, target_squad: int) -> bool:
	if not s.squads.has(attacker_squad) or not s.squads.has(target_squad): return false
	var owner := int(s.squads[attacker_squad].get("owner", -1))
	if owner not in [1, 2] or not gauntlet_enabled(s, owner) or not marine_unit(s, attacker_squad): return false
	if int(s.squads[attacker_squad].get("disembarked_turn", -1)) != int(s.get("turn", -2)): return false
	var marks: Dictionary = s.get("detachment_stratagems", {}).get("gauntlet_assailed", {})
	var player_marks: Dictionary = marks.get(owner, marks.get(str(owner), {}))
	var record: Dictionary = player_marks.get(target_squad, player_marks.get(str(target_squad), {}))
	return int(record.get("turn", -1)) == int(s.get("turn", -2)) and int(s.squads[target_squad].get("owner", -1)) != owner

static func gauntlet_combined_actor(s: Dictionary) -> int:
	if not enabled(s) or str(s.get("phase", "")) != "shooting": return -1
	var pending: Dictionary = s.get("detachment_stratagems", {}).get("gauntlet_pending", {})
	var player := int(pending.get("player", -1))
	if player not in [1, 2] or player != int(s.get("active", -1)) or str(pending.get("phase_key", "")) != phase_key(s) or not gauntlet_enabled(s, player): return -1
	for target_value: Variant in pending.get("targets", []):
		if target_value is int and s.squads.has(int(target_value)) and int(s.squads[int(target_value)].get("owner", -1)) != player: return player
	return -1

static func gauntlet_combined_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if gauntlet_combined_actor(s) != player: return result
	var pending: Dictionary = s.detachment_stratagems.get("gauntlet_pending", {})
	for target_value: Variant in pending.get("targets", []):
		if not target_value is int: continue
		var target := int(target_value)
		if not s.squads.has(target) or int(s.squads[target].get("owner", -1)) == player: continue
		result.append({"label": "Combined Deployment: mark %s Assailed for the rest of this turn" % str(s.squads[target].get("name", "enemy unit")), "action": "combined-deployment-assail", "model": -1, "target": target, "value": target})
	result.append({"label": "Pass Combined Deployment", "action": "combined-deployment-pass", "model": -1, "target": -1, "value": ""})
	return result

static func resolve_gauntlet_combined(s: Dictionary, player: int, target: int) -> Dictionary:
	if gauntlet_combined_actor(s) != player: return {"error": "No Combined Deployment target choice is pending for this player."}
	var pending: Dictionary = s.detachment_stratagems.get("gauntlet_pending", {})
	if target not in pending.get("targets", []) or not s.squads.has(target) or int(s.squads[target].get("owner", -1)) == player: return {"error": "Choose one enemy unit hit by the transport's shooting attacks."}
	var marks: Dictionary = s.detachment_stratagems.get("gauntlet_assailed", {}).duplicate(true)
	var player_marks: Dictionary = marks.get(player, marks.get(str(player), {})).duplicate(true)
	player_marks[target] = {"turn": int(s.turn), "source_squad": int(pending.get("attacker", -1))}
	marks[player] = player_marks
	s.detachment_stratagems.gauntlet_assailed = marks
	s.detachment_stratagems.gauntlet_pending = {}
	return {"error": "", "message": "Combined Deployment: %s is Assailed until the end of this turn." % str(s.squads[target].get("name", "Enemy unit"))}

static func pass_gauntlet_combined(s: Dictionary, player: int) -> String:
	if gauntlet_combined_actor(s) != player: return "No Combined Deployment target choice is pending for this player."
	s.detachment_stratagems.gauntlet_pending = {}
	return ""

static func enable_gravis(s: Dictionary, detachment: String) -> void:
	if detachment not in ["gravis-linebreaker-force", "gravis-siege-force"]: return
	if not enabled(s): enable(s)
	if detachment not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append(detachment)
	if not s.detachment_stratagems.has("gravis_annihilating"): s.detachment_stratagems.gravis_annihilating = {}
	if not s.detachment_stratagems.has("gravis_suppression_pending"): s.detachment_stratagems.gravis_suppression_pending = {}
	var rule := GRAVIS_LINEBREAKER_ANNIHILATING_FORCE if detachment == "gravis-linebreaker-force" else GRAVIS_SIEGE_ANNIHILATING_FORCE
	Registry.admit(s, rule, ID)
	if detachment == "gravis-linebreaker-force":
		Registry.admit(s, GRAVIS_LINEBREAKER_ARMOURED_IMPACT, ID)
		Registry.admit(s, GRAVIS_LINEBREAKER_PURGATION_PUSH, ID)
	if detachment == "gravis-siege-force":
		Registry.admit(s, GRAVIS_SIEGE_STAND_UNYIELDING, ID)
		Registry.admit(s, GRAVIS_SIEGE_SUPPRESSION_VOLLEYS, ID)

static func enable_terminator_storm(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "terminator-storm-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("terminator-storm-force")
	if not s.detachment_stratagems.has("terminator_merciless"): s.detachment_stratagems.terminator_merciless = {}
	Registry.admit(s, TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE, ID)
	Registry.admit(s, TERMINATOR_MERCILESS_VETERANS, ID)
	Registry.admit(s, TERMINATOR_GUNSHIP_EXTRACTION, ID)

static func enable_firestorm(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "tacticus-firestorm-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("tacticus-firestorm-force")
	if not s.detachment_stratagems.has("for_the_emperor"): s.detachment_stratagems.for_the_emperor = {}
	Registry.admit(s, FOR_THE_EMPEROR, ID)
	Registry.admit(s, FIRESTORM_RELENTLESS_ASSAULT, ID)
	Registry.admit(s, FIRESTORM_POINT_BLANK_BRUTALITY, ID)

static func enable_phobos_shock(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "phobos-shock-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("phobos-shock-force")
	if not s.detachment_stratagems.has("phobos_strike"): s.detachment_stratagems.phobos_strike = {}
	if not s.detachment_stratagems.has("phobos_umbral"): s.detachment_stratagems.phobos_umbral = {}
	Registry.admit(s, PHOBOS_STRIKE_FROM_SHADOWS, ID)
	Registry.admit(s, PHOBOS_TRANSHUMAN_REACTIONS, ID)
	Registry.admit(s, PHOBOS_UMBRAL_EVASION, ID)

static func enable_phobos_shadow(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "phobos-shadow-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("phobos-shadow-force")
	if not s.detachment_stratagems.has("mortis_snares"): s.detachment_stratagems.mortis_snares = {}
	Registry.admit(s, PHOBOS_SHADOW_STRIKE_FROM_SHADOWS, ID)
	Registry.admit(s, PHOBOS_SHADOW_TACTICAL_WITHDRAWAL, ID)
	Registry.admit(s, PHOBOS_SHADOW_MORTIS_SNARES, ID)
	Registry.admit(s, PHOBOS_SHADOW_MASTERS, ID)

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

static func enable_medusa_wrath(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "medusa-wrath" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("medusa-wrath")
	if not s.detachment_stratagems.has("spirits_of_iron"): s.detachment_stratagems.spirits_of_iron = {}
	if not s.detachment_stratagems.has("medusa_power_pending"): s.detachment_stratagems.medusa_power_pending = {}
	if not s.detachment_stratagems.has("medusa_power_reactive"): s.detachment_stratagems.medusa_power_reactive = {}
	Registry.admit(s, MEDUSA_SPIRITS_OF_IRON, ID)
	Registry.admit(s, MEDUSA_VENGEFUL_ANIMUS, ID)
	Registry.admit(s, MEDUSA_METHODICAL_BRUTALITY, ID)
	Registry.admit(s, MEDUSA_UNBOWED_CONVICTION, ID)
	Registry.admit(s, MEDUSA_ANCIENT_FURY, ID)
	Registry.admit(s, MEDUSA_POWER_OF_MACHINE_SPIRIT, ID)
	Registry.admit(s, MEDUSA_ARMOURED_WRATH, ID)

static func enable_vow_sworn(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "vow-sworn-crusaders" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("vow-sworn-crusaders")
	if not s.detachment_stratagems.has("pious_enmity"): s.detachment_stratagems.pious_enmity = {}
	Registry.admit(s, VOW_PIOUS_ENMITY, ID)

static func enable_blade_of_ultramar(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "blade-of-ultramar" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("blade-of-ultramar")
	Registry.admit(s, ULTRAMARINES_ARMOUR, ID)
	Registry.admit(s, ULTRAMARINES_COURAGE, ID)
	Registry.admit(s, ULTRAMARINES_EXEMPLARY_VIGILANCE, ID)
	Registry.admit(s, ULTRAMARIAN_ADAPTIVITY, ID)
	Registry.admit(s, ULTRAMARIAN_PRACTICAL_TACTICS, ID)
	Registry.admit(s, ULTRAMARINES_TACTICAL_FORESIGHT, ID)

static func enable_wrath_of_the_rock(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}}
	if "wrath-of-the-rock" not in s.detachment_stratagems.modes: s.detachment_stratagems.modes.append("wrath-of-the-rock")
	if not s.detachment_stratagems.has("wrath_destroyed"): s.detachment_stratagems.wrath_destroyed = []
	for key in ["lion_will", "inescapable", "relics"]:
		if not s.detachment_stratagems.has(key): s.detachment_stratagems[key] = {}
	for ability in [KNIGHTS_OF_IRON, LIONS_WILL, TACTICAL_MASTERY, INESCAPABLE_JUSTICE, RELICS_OF_THE_DARK_AGE, IN_SACRIFICE]: Registry.admit(s, ability, ID)

static func enable_inner_circle(s: Dictionary) -> void:
	if not enabled(s): enable(s)
	if "inner-circle-task-force" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("inner-circle-task-force")
	Registry.admit(s, INNER_CIRCLE_DUTY_UNTO_DEATH, ID)
	Registry.admit(s, INNER_CIRCLE_RELIC_TELEPORTARIUM, ID)
	Registry.admit(s, INNER_CIRCLE_WRATH_OF_THE_LION, ID)

static func enable_darkflight(s: Dictionary) -> void:
	if not enabled(s):
		s.detachment_stratagems = {"implementation": ID, "modes": [], "hungry": {}, "storm": {}, "armour": {}, "might": {}, "worthy": {}, "tactics": {}, "sudden": {}, "tyrant": {}, "sudden_onslaught": {}, "wind_swift": {}, "hurtling": {}, "spearpoint_melee": {}, "evasive": {}, "mobile_lethality": {}, "adamantine": {}, "mercy": {}, "mobile": {}, "spotted": {}, "after": {}, "last_move": {}, "destroyed": [], "revived": {}, "vengeful": {}, "wings_shadow": {}, "darkflight_skyborne_pending": {}, "skyborne_surveillance": {}, "darkflight_vengeance_pending": {}}
	if "darkflight-pursuit" not in s.detachment_stratagems.get("modes", []): s.detachment_stratagems.modes.append("darkflight-pursuit")
	if not s.detachment_stratagems.has("wings_shadow"): s.detachment_stratagems.wings_shadow = {}
	if not s.detachment_stratagems.has("darkflight_skyborne_pending"): s.detachment_stratagems.darkflight_skyborne_pending = {}
	if not s.detachment_stratagems.has("skyborne_surveillance"): s.detachment_stratagems.skyborne_surveillance = {}
	if not s.detachment_stratagems.has("darkflight_vengeance_pending"): s.detachment_stratagems.darkflight_vengeance_pending = {}
	Registry.admit(s, WINGS_OF_SHADOW, ID)
	Registry.admit(s, SKYBORNE_SURVEILLANCE, ID)
	Registry.admit(s, WE_ARE_VENGEANCE, ID)

static func ironstorm_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "ironstorm" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "ironstorm-spearhead" and player in s.get("combat_doctrines", {}).get("owners", [])

static func firestorm_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "tacticus-firestorm-force" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and Doctrines.detachment_for(s, player) == "tacticus-firestorm-force" and player in s.get("combat_doctrines", {}).get("owners", []) and Marines.marine_army(s, player) and Registry.enabled(s, FOR_THE_EMPEROR)

static func phobos_shock_detachment_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "phobos-shock-force" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and Doctrines.detachment_for(s, player) == "phobos-shock-force" and player in s.get("combat_doctrines", {}).get("owners", [])

static func phobos_shadow_detachment_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "phobos-shadow-force" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and Doctrines.detachment_for(s, player) == "phobos-shadow-force" and player in s.get("combat_doctrines", {}).get("owners", [])

static func phobos_shadow_strike_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shadow_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_SHADOW_STRIKE_FROM_SHADOWS)

static func phobos_tactical_withdrawal_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shadow_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_SHADOW_TACTICAL_WITHDRAWAL)

static func phobos_mortis_snares_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shadow_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_SHADOW_MORTIS_SNARES)

static func phobos_shadow_masters_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shadow_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_SHADOW_MASTERS)

static func phobos_mortis_snares_objectives(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(squad) or living(s, squad).is_empty(): return result
	var player := int(s.squads[squad].get("owner", -1))
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		var objective: Dictionary = objectives[index]
		if int(objective.get("controller", 0)) != player: continue
		if squad in Objectives.controlling_squads(s, objective, Callable(Morale, "objective_control")): result.append(index)
	return result

static func _phobos_mortis_snares_available(s: Dictionary, player: int, squad: int) -> bool:
	if not phobos_mortis_snares_enabled(s, player) or not s.has("stratagems") or not A.enabled(s): return false
	if s.phase != "movement" or int(s.active) != player or not s.squads.has(squad): return false
	if int(s.squads[squad].get("owner", -1)) != player or bool(s.squads[squad].get("battle_shocked", false)) or living(s, squad).is_empty(): return false
	var keywords := unit_keywords(s, squad)
	if "PHOBOS" not in keywords and "SCOUT SQUAD" not in keywords: return false
	if Queue.engaged(s, squad) or s.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	for model: int in living(s, squad):
		if not s.units[model].get("on_battlefield", true): return false
	if phobos_mortis_snares_objectives(s, squad).is_empty(): return false
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return false
	for use: Dictionary in s.stratagems.get("uses", []):
		if int(use.get("player", -1)) != player or str(use.get("phase_key", "")) != phase_key(s): continue
		if str(use.get("stratagem", "")) == PHOBOS_SHADOW_MORTIS_SNARES or int(use.get("squad", -1)) == squad: return false
	return true

static func phobos_mortis_snares_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if s.phase != "movement" or int(s.active) != player: return result
	for squad: int in s.squads:
		if _phobos_mortis_snares_available(s, player, squad): result.append(squad)
	result.sort()
	return result

static func _squad_within_objective(s: Dictionary, squad: int, objective: Dictionary) -> bool:
	for model: int in living(s, squad):
		if Objectives.in_range(s.units[model], objective): return true
	return false

static func open_mortis_snares_after_move(s: Dictionary, moved_squad: int, move_type: String) -> bool:
	if move_type in ["ingress", "setup"] or not enabled(s) or not s.has("unit_abilities") or not s.squads.has(moved_squad): return false
	var moved_owner := int(s.squads[moved_squad].get("owner", -1))
	if moved_owner not in [1, 2] or living(s, moved_squad).is_empty(): return false
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	var snares_value: Variant = s.detachment_stratagems.get("mortis_snares", {})
	if not snares_value is Dictionary or snares_value.is_empty(): return false
	var snares: Dictionary = snares_value.duplicate(true)
	var triggers: Array[Dictionary] = []
	for objective_index in range(objectives.size()):
		var key := str(objective_index)
		if not snares.has(key) or not objectives[objective_index] is Dictionary: continue
		var snare: Variant = snares[key]
		if not snare is Dictionary: continue
		var snare_owner := int(snare.get("owner", -1))
		if snare_owner == moved_owner or not phobos_mortis_snares_enabled(s, snare_owner): continue
		if not _squad_within_objective(s, moved_squad, objectives[objective_index]): continue
		triggers.append({"objective": objective_index, "owner": snare_owner, "moved_squad": moved_squad})
		snares.erase(key)
	if triggers.is_empty(): return false
	s.detachment_stratagems.mortis_snares = snares
	var resume_window: Dictionary = s.unit_abilities.get("window", {}).duplicate(true)
	for index in range(triggers.size() - 1, -1, -1):
		var trigger: Dictionary = triggers[index]
		resume_window = {"kind": PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW, "owners": [int(trigger.owner)], "objective": int(trigger.objective), "moved_squad": moved_squad, "resume_window": resume_window}
	s.unit_abilities.window = resume_window
	return true

static func mortis_snares_trigger_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW or window.get("owners", []) != [player]: return []
	var objective_index := int(window.get("objective", -1))
	var moved_squad := int(window.get("moved_squad", -1))
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	if objective_index < 0 or objective_index >= objectives.size() or not s.squads.has(moved_squad) or living(s, moved_squad).is_empty(): return []
	return [{"label": "Mortis Snares: roll D6 for %s at %s" % [str(s.squads[moved_squad].get("name", "the moving enemy unit")), str(objectives[objective_index].get("name", "the snared objective"))], "action": "mortis-snares-trigger-roll", "model": -1, "target": moved_squad, "value": str(objective_index)}]

static func resolve_mortis_snares_trigger(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW or window.get("owners", []) != [player] or selected.get("action", "") != "mortis-snares-trigger-roll": return {"error": "No Mortis Snares trigger roll is pending for this player."}
	var moved_squad := int(window.get("moved_squad", -1))
	var objective_index := int(window.get("objective", -1))
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	if not s.squads.has(moved_squad) or objective_index < 0 or objective_index >= objectives.size() or int(selected.get("target", -1)) != moved_squad or str(selected.get("value", "")) != str(objective_index): return {"error": "The Mortis Snares trigger no longer matches the moving unit and objective."}
	if not roller.is_valid(): return {"error": "Mortis Snares requires the host's D6."}
	var trigger_roll: Variant = roller.call()
	if not trigger_roll is int or trigger_roll < 1 or trigger_roll > 6: return {"error": "Mortis Snares trigger rolls must be integers from 1 to 6."}
	var record := {"objective": objective_index, "snare_owner": player, "target": moved_squad, "trigger_roll": int(trigger_roll), "damage_roll": 0, "mortal_wounds": 0, "remaining": 0, "allocations": [], "discarded": 0, "stage": "complete" if int(trigger_roll) < 2 else "damage_pending"}
	s.last_mortis_snares = record
	var resume_window: Dictionary = window.get("resume_window", {}).duplicate(true)
	if int(trigger_roll) < 2:
		s.unit_abilities.window = resume_window
		return {"error": "", "message": "Mortis Snares at %s triggered on %d; no mortal wounds. The objective is no longer snared." % [str(objectives[objective_index].get("name", "Objective")), int(trigger_roll)]}
	s.unit_abilities.window = {"kind": PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW, "owners": [player], "objective": objective_index, "moved_squad": moved_squad, "trigger_roll": int(trigger_roll), "resume_window": resume_window}
	return {"error": "", "message": "Mortis Snares at %s triggered on %d; roll the D6 mortal-wound amount." % [str(objectives[objective_index].get("name", "Objective")), int(trigger_roll)]}

static func mortis_snares_damage_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW or window.get("owners", []) != [player]: return []
	var moved_squad := int(window.get("moved_squad", -1))
	if not s.squads.has(moved_squad): return []
	return [{"label": "Mortis Snares: roll D6 mortal wounds for %s" % str(s.squads[moved_squad].get("name", "the moving enemy unit")), "action": "mortis-snares-damage-roll", "model": -1, "target": moved_squad, "value": str(int(window.get("objective", -1)))}]

static func resolve_mortis_snares_damage(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW or window.get("owners", []) != [player] or selected.get("action", "") != "mortis-snares-damage-roll": return {"error": "No Mortis Snares damage roll is pending for this player."}
	var moved_squad := int(window.get("moved_squad", -1))
	if not s.squads.has(moved_squad) or int(selected.get("target", -1)) != moved_squad or str(selected.get("value", "")) != str(int(window.get("objective", -1))): return {"error": "The Mortis Snares damage roll no longer matches the moving unit."}
	if not roller.is_valid(): return {"error": "Mortis Snares requires the host's D6."}
	var damage_roll: Variant = roller.call()
	if not damage_roll is int or damage_roll < 1 or damage_roll > 6: return {"error": "Mortis Snares damage rolls must be integers from 1 to 6."}
	var record: Dictionary = s.get("last_mortis_snares", {}).duplicate(true)
	if int(record.get("target", -1)) != moved_squad or int(record.get("objective", -1)) != int(window.get("objective", -2)) or int(record.get("trigger_roll", 0)) < 2: return {"error": "The Mortis Snares trigger result is missing."}
	record.damage_roll = int(damage_roll)
	record.mortal_wounds = int(damage_roll)
	record.remaining = int(damage_roll)
	record.stage = "allocation"
	s.last_mortis_snares = record
	s.unit_abilities.window = {"kind": PHOBOS_SHADOW_MORTIS_MORTAL_WINDOW, "owners": [int(s.squads[moved_squad].get("owner", -1))], "target": moved_squad, "moved_squad": moved_squad, "resume_window": window.get("resume_window", {}).duplicate(true)}
	return {"error": "", "message": "Mortis Snares inflicted %d mortal wounds on %s; the objective is no longer snared." % [int(damage_roll), str(s.squads[moved_squad].get("name", "the moving enemy unit"))]}

static func phobos_shock_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shock_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_STRIKE_FROM_SHADOWS)

static func phobos_transhuman_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shock_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_TRANSHUMAN_REACTIONS)

static func phobos_umbral_enabled(s: Dictionary, player: int) -> bool:
	return phobos_shock_detachment_enabled(s, player) and Registry.enabled(s, PHOBOS_UMBRAL_EVASION)

static func relentless_assault_rule(s: Dictionary, player: int) -> String:
	return FIRESTORM_RELENTLESS_ASSAULT if firestorm_enabled(s, player) else RELENTLESS_ASSAULT

static func point_blank_brutality_error(s: Dictionary, player: int, squad: int, declaration: Dictionary) -> String:
	var preview := s.duplicate(true)
	preview.unit_abilities.window = {"kind": POINT_BLANK_BRUTALITY_WINDOW, "owners": [player], "squad": squad, "declaration": declaration.duplicate(true)}
	return error(preview, player, squad, FIRESTORM_POINT_BLANK_BRUTALITY)

static func point_blank_brutality_available(s: Dictionary, player: int, squad: int) -> bool:
	if not s.squads.has(squad) or living(s, squad).is_empty(): return false
	var declaration := {"kind": "attack", "player": player, "attacker": living(s, squad)[0], "squad": squad, "entries": [], "melee": false}
	return point_blank_brutality_error(s, player, squad, declaration).is_empty()

static func point_blank_brutality_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != POINT_BLANK_BRUTALITY_WINDOW or window.get("owners", []) != [player] or not s.squads.has(squad): return result
	if error(s, player, squad, FIRESTORM_POINT_BLANK_BRUTALITY).is_empty():
		var cost := maxi(0, 1 - A.discount(s, player, squad))
		result.append({"label": "Point-Blank Brutality: %s gains Close-Quarters and Ignores Cover for non-Blast ranged attacks (%d CP)" % [str(s.squads[squad].get("name", "Tacticus unit")), cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": FIRESTORM_POINT_BLANK_BRUTALITY})
	return result

static func point_blank_brutality_active(s: Dictionary, squad: int) -> bool:
	if not enabled(s) or not Registry.enabled(s, FIRESTORM_POINT_BLANK_BRUTALITY) or not s.squads.has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("point_blank_brutality", {}).get(squad, {})
	return record.get("phase_key", "") == phase_key(s)

static func medusa_wrath_enabled(s: Dictionary, player: int) -> bool:
	var chapters: Dictionary = s.get("marine_chapters", {})
	return enabled(s) and "medusa-wrath" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and Doctrines.detachment_for(s, player) == "medusa-wrath" and player in s.get("combat_doctrines", {}).get("owners", []) and str(chapters.get(player, chapters.get(str(player), ""))) == "IRON HANDS"

static func armoured_wrath_context(s: Dictionary, squad: int) -> Dictionary:
	if not s.squads.has(squad): return {}
	var player := int(s.squads[squad].get("owner", -1))
	if not Registry.supported(MEDUSA_ARMOURED_WRATH) or not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, player) or not marine_unit(s, squad): return {}
	var feirros_rerolls := false
	for model: int in s.units:
		var source: Dictionary = s.units[model]
		var source_squad := int(source.get("squad", -1))
		if int(source.get("wounds", 0)) <= 0 or not source.get("on_battlefield", true) or not s.squads.has(source_squad) or int(s.squads[source_squad].get("owner", -1)) != player or A.identity(source) != "iron-father-feirros": continue
		if G.distance_to_target(s, source, squad) <= 6.0:
			feirros_rerolls = true
			break
	return {"active": true, "full_rerolls": feirros_rerolls}

static func medusa_power_actor(s: Dictionary) -> int:
	if s.get("phase", "") != "shooting": return -1
	var pending: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_pending", {})
	if pending.get("phase_key", "") == phase_key(s) and int(pending.get("player", -1)) == 3 - int(s.get("active", -1)):
		for squad_value: Variant in pending.get("targets", []):
			if squad_value is int and error(s, int(pending.player), int(squad_value), MEDUSA_POWER_OF_MACHINE_SPIRIT).is_empty(): return int(pending.player)
	var reactive: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	var squad := int(reactive.get("squad", -1))
	var attacker := int(reactive.get("attacker", -1))
	if reactive.get("phase_key", "") == phase_key(s) and int(reactive.get("player", -1)) == 3 - int(s.get("active", -1)) and s.squads.has(squad) and int(reactive.get("player", -1)) == int(s.squads[squad].get("owner", -2)) and not living(s, squad).is_empty() and not living(s, attacker).is_empty():
		return int(reactive.player)
	return -1

static func shooting_reaction_actor(s: Dictionary) -> int:
	var owner := vengeful_actor(s)
	return owner if owner > 0 else medusa_power_actor(s)

static func medusa_power_snap_shooting(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var reactive: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	return reactive.get("phase_key", "") == phase_key(s) and int(reactive.get("player", -1)) == int(s.squads[squad].get("owner", -2)) and int(reactive.get("squad", -1)) == squad and not Morale.at_half_strength(s, squad)

static func methodical_brutality_active(s: Dictionary, squad: int) -> bool:
	var record: Dictionary = s.get("detachment_stratagems", {}).get("methodical_brutality", {}).get(squad, {})
	return Registry.enabled(s, MEDUSA_METHODICAL_BRUTALITY) and s.squads.has(squad) and record.get("phase_key", "") == phase_key(s)

static func methodical_brutality_wound_bonus(s: Dictionary, squad: int) -> int:
	return 1 if methodical_brutality_active(s, squad) and "VEHICLE" in unit_keywords(s, squad) else 0

static func vow_sworn_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "vow-sworn-crusaders" in s.detachment_stratagems.get("modes", []) and Registry.enabled(s, VOW_PIOUS_ENMITY) and TemplarVows.enabled_for(s, player)

static func pious_enmity_record(s: Dictionary, squad: int) -> Dictionary:
	if not Registry.enabled(s, VOW_PIOUS_ENMITY) or not s.squads.has(squad): return {}
	var record: Dictionary = s.get("detachment_stratagems", {}).get("pious_enmity", {}).get(squad, {})
	return record.duplicate(true) if str(record.get("phase_key", "")) == phase_key(s) else {}

static func pious_enmity_active(s: Dictionary, squad: int) -> bool:
	return not pious_enmity_record(s, squad).is_empty()

static func unbowed_conviction_active(s: Dictionary, squad: int) -> bool:
	if not Registry.enabled(s, MEDUSA_UNBOWED_CONVICTION) or not s.squads.has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("unbowed_conviction", {}).get(squad, {})
	return not record.is_empty() and int(record.get("owner", -1)) == int(s.squads[squad].get("owner", -2)) and int(s.turn) < int(record.get("expires_turn", -1))

static func below_starting_strength(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var starting_strength := int(s.squads[squad].get("starting_strength", 0))
	return starting_strength > 0 and living(s, squad).size() < starting_strength

static func methodical_brutality_choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != METHODICAL_BRUTALITY_WINDOW or window.get("owners", []) != [player] or not s.squads.has(squad): return result
	if error(s, player, squad, MEDUSA_METHODICAL_BRUTALITY).is_empty():
		result.append({"label": "Medusa's Wrath Methodical Brutality: %s gains Sustained Hits 1%s (1 CP)" % [str(s.squads[squad].get("name", "Astartes unit")), "; Vehicle: +1 to Wound" if "VEHICLE" in unit_keywords(s, squad) else ""], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MEDUSA_METHODICAL_BRUTALITY})
	return result

static func pious_enmity_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != PIOUS_ENMITY_WINDOW or window.get("owners", []) != [player] or not s.squads.has(squad): return result
	if not error(s, player, squad, VOW_PIOUS_ENMITY).is_empty(): return result
	var name := str(s.squads[squad].get("name", "Chaplain/Judiciar unit"))
	result.append({"label": "Pious Enmity: re-roll melee Hit rolls of 1 for %s (1 CP)" % name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": VOW_PIOUS_ENMITY, "mode": "hit-ones"})
	result.append({"label": "Pious Enmity: against Monsters/Vehicles, re-roll melee Hit and Wound rolls of 1 for %s (1 CP)" % name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": VOW_PIOUS_ENMITY, "mode": "monster-vehicle-ones"})
	return result

static func relentless_assault_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != RELENTLESS_ASSAULT_WINDOW or window.get("owners", []) != [player] or not s.squads.has(squad): return result
	var source_rule := str(window.get("stratagem", relentless_assault_rule(s, player)))
	if error(s, player, squad, source_rule).is_empty():
		var cost := maxi(0, 1 - A.discount(s, player, squad))
		result.append({"label": "Relentless Assault: %s gains Sustained Hits 1 against non-Monster/Vehicle targets and Lethal Hits against Monster/Vehicle targets (%d CP)" % [str(s.squads[squad].get("name", "Tacticus unit")), cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": source_rule})
	return result

static func phobos_strike_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != PHOBOS_STRIKE_WINDOW or window.get("owners", []) != [player] or not s.squads.has(squad): return result
	var rule := phobos_strike_rule(s, player)
	if not rule.is_empty() and error(s, player, squad, rule).is_empty():
		var cost := maxi(0, 1 - A.discount(s, player, squad))
		result.append({"label": "Strike from the Shadows: %s gains +1 Strength and Lethal Hits for this attack (%d CP)" % [str(s.squads[squad].get("name", "Phobos unit")), cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": rule})
	return result

static func relentless_assault_active(s: Dictionary, squad: int) -> bool:
	if not enabled(s) or not (Registry.enabled(s, RELENTLESS_ASSAULT) or Registry.enabled(s, FIRESTORM_RELENTLESS_ASSAULT)) or not s.squads.has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("relentless_assault", {}).get(squad, {})
	return record.get("phase_key", "") == phase_key(s)

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

static func darkflight_enabled(s: Dictionary, player: int) -> bool:
	if not enabled(s) or "darkflight-pursuit" not in s.detachment_stratagems.get("modes", []): return false
	if not Doctrines.enabled(s) or player not in s.get("combat_doctrines", {}).get("owners", []) or Doctrines.detachment_for(s, player) != "darkflight-pursuit": return false
	var chapters: Dictionary = s.get("marine_chapters", {})
	return str(chapters.get(player, chapters.get(str(player), ""))) == "DARK ANGELS"

static func darkflight_ravenwing_unit(s: Dictionary, player: int, squad: int) -> bool:
	if not darkflight_enabled(s, player) or not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return false
	var keywords := unit_keywords(s, squad)
	return "ADEPTUS ASTARTES" in keywords and "RAVENWING" in keywords and ("FLY" in keywords or "MOUNTED" in keywords)

static func darkflight_ravenwing_fly_unit(s: Dictionary, player: int, squad: int) -> bool:
	if not darkflight_enabled(s, player) or not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return false
	var keywords := unit_keywords(s, squad)
	return "ADEPTUS ASTARTES" in keywords and "RAVENWING" in keywords and "FLY" in keywords

static func gladius_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and Doctrines.enabled(s) and "checked" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "gladius" and player in s.get("combat_doctrines", {}).get("owners", []) and Marines.marine_army(s, player)

static func adamantine_targets(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(squad): return result
	for enemy: int in s.squads:
		if s.squads[enemy].owner == s.squads[squad].owner: continue
		var engaged := false
		for source: int in G.alive(s, squad):
			for target: int in G.alive(s, enemy):
				if G.within_engagement(s.units[source], s.units[target]):
					engaged = true
					break
			if engaged: break
		if engaged: result.append(enemy)
	result.sort()
	return result

static func adamantine_pending(s: Dictionary) -> Dictionary:
	return s.get("detachment_stratagems", {}).get("adamantine_pending", {})

static func adamantine_decision_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var pending := adamantine_pending(s)
	var result: Array[Dictionary] = []
	var current: Dictionary = pending.get("current_result", {})
	var target := int(current.get("squad", -1))
	if pending.is_empty() or current.is_empty() or int(pending.get("decision_owner", -1)) != player or not s.squads.has(target): return result
	var source := str(pending.get("source", ADAMANTINE_TERROR))
	var source_name := "Suppression Volleys" if source == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS else "Adamantine Terror"
	result.append({"label": "Keep %s's current result for %s" % [source_name, s.squads[target].name], "action": "adamantine-terror-decision", "model": -1, "target": target, "value": "keep"})
	if MarineEnhancements.tempered_in_battle_active(s, target):
		result.append({"label": "Tempered in Battle: re-roll both Leadership dice for %s (free)" % s.squads[target].name, "action": "adamantine-terror-decision", "model": -1, "target": target, "value": "tempered-in-battle"})
	return result

static func _apply_adamantine_result(s: Dictionary, pending: Dictionary, result: Dictionary, was_battle_shocked: bool) -> void:
	var target := int(result.get("squad", -1))
	s.squads[target].battle_shocked = was_battle_shocked or not bool(result.get("passed", false))
	result["source"] = str(pending.get("source", ADAMANTINE_TERROR))
	result["modifier"] = -1
	result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
	result["phase_key"] = phase_key(s)
	pending.results.append(result.duplicate(true))
	var targets: Array = pending.get("targets", [])
	if not targets.is_empty() and int(targets[0]) == target: targets.pop_front()
	pending.targets = targets
	pending.erase("current_result")
	pending.erase("was_battle_shocked")
	pending.erase("decision_owner")

static func _pump_adamantine(s: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = adamantine_pending(s)
	while not pending.is_empty() and not pending.get("targets", []).is_empty():
		var target := int(pending.targets[0])
		var result := Morale.roll_battle_shock(s, target, roller, -1)
		if not result.error.is_empty(): return result
		if MarineEnhancements.tempered_in_battle_active(s, target):
			result["source"] = str(pending.get("source", ADAMANTINE_TERROR))
			result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
			pending.current_result = result.duplicate(true)
			pending.was_battle_shocked = bool(s.squads[target].battle_shocked)
			pending.decision_owner = int(s.squads[target].owner)
			var source_name := "Suppression Volleys" if str(pending.get("source", ADAMANTINE_TERROR)) == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS else "Adamantine Terror"
			return {"error": "", "pending_reroll": true, "message": "%s Leadership result is waiting for the target unit's controller." % source_name}
		_apply_adamantine_result(s, pending, result, bool(s.squads[target].battle_shocked))
	var completed_results: Array = []
	if not pending.is_empty():
		completed_results = pending.get("results", []).duplicate(true)
		var source := str(pending.get("source", ADAMANTINE_TERROR))
		if source == ADAMANTINE_TERROR:
			s.detachment_stratagems.last_adamantine_terror = completed_results.duplicate(true)
			s.last_adamantine_terror = completed_results.duplicate(true)
		else:
			s.detachment_stratagems.last_suppression_volleys = completed_results.duplicate(true)
		s.last_morale = completed_results.duplicate(true)
		s.detachment_stratagems.erase("adamantine_pending")
	var messages: Array[String] = []
	for result: Dictionary in completed_results:
		messages.append("%s %s (-1 = %d vs Leadership %d): %s" % [s.squads[int(result.squad)].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"])
	var source_name := "Suppression Volleys" if not completed_results.is_empty() and str(completed_results[0].get("source", "")) == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS else "Adamantine Terror"
	return {"error": "", "message": source_name + ": " + "; ".join(messages) + "."}

static func resolve_adamantine_decision(s: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var choices := adamantine_decision_choices(s, player)
	if selected not in choices: return {"error": "Choose a current detachment Battle-shock result decision."}
	var pending: Dictionary = adamantine_pending(s)
	var current: Dictionary = pending.get("current_result", {}).duplicate(true)
	var target := int(current.get("squad", -1))
	var was_battle_shocked := bool(pending.get("was_battle_shocked", false))
	var result: Dictionary
	if selected.value == "tempered-in-battle":
		if not MarineEnhancements.tempered_in_battle_active(s, target): return {"error": "Tempered in Battle does not apply to this Battle-shock roll."}
		result = Morale.roll_battle_shock(s, target, roller, -1)
		if not result.error.is_empty(): return result
		result["rerolled_from"] = current.get("rolls", []).duplicate()
	else:
		result = current
	_apply_adamantine_result(s, pending, result, was_battle_shocked)
	return _pump_adamantine(s, roller)

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
	return enabled(s) and "spearpoint" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "spearpoint-task-force" and player in s.get("combat_doctrines", {}).get("owners", [])

static func assault_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "assault-brethren" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "assault-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func tactical_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "tactical-brethren" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "tactical-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func devastator_brethren_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "devastator-brethren" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "devastator-brethren" and player in s.get("combat_doctrines", {}).get("owners", [])

static func blade_ultramar_enabled(s: Dictionary, player: int) -> bool:
	var chapters: Dictionary = s.get("marine_chapters", {})
	return enabled(s) and "blade-of-ultramar" in s.detachment_stratagems.get("modes", []) and Doctrines.enabled(s) and Doctrines.detachment_for(s, player) == "blade-of-ultramar" and player in s.get("combat_doctrines", {}).get("owners", []) and str(chapters.get(player, chapters.get(str(player), ""))) == "ULTRAMARINES"

static func worthy_stratagem(s: Dictionary, player: int) -> String:
	if inner_circle_enabled(s, player): return INNER_CIRCLE_DUTY_UNTO_DEATH
	if assault_brethren_enabled(s, player): return DUTY_IN_DEATH
	if gladius_enabled(s, player): return WORTHY
	return ""

static func armour_stratagem(s: Dictionary, player: int) -> String:
	if blade_ultramar_enabled(s, player): return ULTRAMARINES_ARMOUR
	if assault_brethren_enabled(s, player): return ASSAULT_ARMOUR
	if tactical_brethren_enabled(s, player): return TACTICAL_ARMOUR
	if devastator_brethren_enabled(s, player): return DEVASTATOR_ARMOUR
	if gladius_enabled(s, player): return ARMOUR
	return ""

static func spearpoint_unit(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var found := false
	for model: int in living(s, squad):
		found = true
		var keywords: Array = s.units[model].get("keywords", [])
		if not keywords.any(func(keyword: Variant) -> bool: return str(keyword).replace("_", " ").replace("-", " ").to_upper() == "ADEPTUS ASTARTES"): return false
	return found

static func unit_keywords(s: Dictionary, squad: int) -> Array[String]:
	return _unit_keywords(s, squad, false)

static func _unit_keywords(s: Dictionary, squad: int, include_destroyed: bool) -> Array[String]:
	var result: Array[String] = []
	for model: int in s.units:
		if int(s.units[model].get("squad", -1)) != squad: continue
		if not include_destroyed and int(s.units[model].get("wounds", 0)) <= 0: continue
		for keyword: Variant in s.units[model].get("keywords", []):
			var normalized := str(keyword).replace("_", " ").replace("-", " ").strip_edges().to_upper()
			if normalized not in result: result.append(normalized)
	return result

static func marine_unit(s: Dictionary, squad: int) -> bool:
	return s.squads.has(squad) and "ADEPTUS ASTARTES" in unit_keywords(s, squad)

static func chaplain_or_judiciar_unit(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	if "CHAPLAIN" in unit_keywords(s, squad) or "JUDICIAR" in unit_keywords(s, squad): return true
	for model: int in living(s, squad):
		if AbilityCatalog.identity(s.units[model]) in ["chaplain", "chaplain-on-bike", "chaplain-with-jump-pack", "chaplain-in-terminator-armour", "judiciar"]: return true
	return false

static func vengeful_animus_triggered(s: Dictionary, player: int, squad: int, model: int = -1) -> bool:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var pending: Dictionary = s.get("pending_deadly_demise", {})
	if window.get("kind", "") != VENGEFUL_ANIMUS_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return false
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return false
	if bool(s.squads[squad].get("battle_shocked", false)): return false
	if pending.is_empty() or int(pending.get("queue_cursor", -1)) >= pending.get("queue", []).size(): return false
	var source := int(pending.queue[int(pending.queue_cursor)])
	if source != int(window.get("source_model", -1)) or not s.units.has(source): return false
	if model >= 0 and model != source: return false
	var unit: Dictionary = s.units[source]
	if int(unit.get("wounds", 1)) > 0 or int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad: return false
	if not living(s, squad).is_empty(): return false
	if A.deadly_demise_value(s, source) == null: return false
	var keywords := _unit_keywords(s, squad, true)
	return "ADEPTUS ASTARTES" in keywords and "VEHICLE" in keywords

static func unit_within_objective_range(s: Dictionary, squad: int) -> bool:
	for model: int in living(s, squad):
		for objective: Dictionary in s.get("mission", {}).get("objectives", []):
			if Objectives.in_range(s.units[model], objective): return true
	return false

static func ravenwing_unit(s: Dictionary, squad: int) -> bool:
	var keywords := unit_keywords(s, squad)
	return s.squads.has(squad) and "ADEPTUS ASTARTES" in keywords and ("RAVENWING" in keywords or "MOUNTED" in keywords or ("VEHICLE" in keywords and "FLY" in keywords))

static func deathwing_unit(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var keywords := unit_keywords(s, squad)
	if "ADEPTUS ASTARTES" not in keywords: return false
	if "DEATHWING" in keywords or "TERMINATOR" in keywords or "DREADNOUGHT" in keywords: return true
	for model: int in living(s, squad):
		if AbilityCatalog.identity(s.units[model]) in DEATHWING_CONDITIONAL_IDENTITIES: return true
	return false

static func deathwing_or_ravenwing_unit(s: Dictionary, squad: int) -> bool:
	return deathwing_unit(s, squad) or ravenwing_unit(s, squad)

static func wrath_of_the_rock_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and Doctrines.enabled(s) and player in s.get("combat_doctrines", {}).get("owners", []) and Marines.marine_army(s, player) and "wrath-of-the-rock" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "wrath-of-the-rock"

static func inner_circle_enabled(s: Dictionary, player: int) -> bool:
	if not enabled(s) or not Doctrines.enabled(s) or player not in s.get("combat_doctrines", {}).get("owners", []) or not Marines.marine_army(s, player): return false
	if "inner-circle-task-force" not in s.detachment_stratagems.get("modes", []) or Doctrines.detachment_for(s, player) != "inner-circle-task-force": return false
	var chapters: Dictionary = s.get("marine_chapters", {})
	return str(chapters.get(player, chapters.get(str(player), ""))) == "DARK ANGELS"

static func inner_circle_deathwing_unit(s: Dictionary, player: int, squad: int) -> bool:
	if not inner_circle_enabled(s, player) or not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return false
	var keywords := unit_keywords(s, squad)
	return "ADEPTUS ASTARTES" in keywords and "DEATHWING" in keywords

static func inner_circle_deathwing_reserve(s: Dictionary, player: int, squad: int) -> bool:
	if not inner_circle_enabled(s, player) or not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return false
	var found := false
	var keywords: Array[String] = []
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		found = true
		for keyword: Variant in unit.get("keywords", []):
			var normalized := str(keyword).replace("_", " ").replace("-", " ").strip_edges().to_upper()
			if normalized not in keywords: keywords.append(normalized)
	return found and "ADEPTUS ASTARTES" in keywords and "DEATHWING" in keywords

static func reserve_unit_has_deep_strike(s: Dictionary, squad: int) -> bool:
	var found := false
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		found = true
		if "deep-strike" not in AbilityCatalog.RULES.get(AbilityCatalog.identity(unit), []): return false
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
	elif rule == KNIGHTS_OF_IRON:
		if not wrath_of_the_rock_enabled(s, player) or not ravenwing_unit(s, squad): return false
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

static func gunship_extraction_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if s.phase != "fight" or int(s.active) == player or terminator_gunship_extraction_rule(s, player).is_empty(): return result
	for squad: int in s.squads:
		if _gunship_extraction_available(s, player, squad): result.append(squad)
	return result

static func phobos_tactical_withdrawal_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if s.phase != "fight" or int(s.active) == player or not phobos_tactical_withdrawal_enabled(s, player): return result
	for squad: int in s.squads:
		if _phobos_tactical_withdrawal_available(s, player, squad): result.append(squad)
	return result

static func _phobos_tactical_withdrawal_available(s: Dictionary, player: int, squad: int) -> bool:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s) or not phobos_tactical_withdrawal_enabled(s, player): return false
	if s.phase != "fight" or int(s.active) == player or not s.squads.has(squad): return false
	if int(s.squads[squad].get("owner", -1)) != player or bool(s.squads[squad].get("battle_shocked", false)) or living(s, squad).is_empty(): return false
	var keywords := unit_keywords(s, squad)
	if "PHOBOS" not in keywords and "SCOUT SQUAD" not in keywords: return false
	if Queue.engaged(s, squad) or s.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	if int(s.squads[squad].get("training_cost", 0)) <= 0: return false
	for model: int in living(s, squad):
		if not s.units[model].get("on_battlefield", true): return false
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return false
	for use: Dictionary in s.stratagems.get("uses", []):
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and (str(use.get("stratagem", "")) == PHOBOS_SHADOW_TACTICAL_WITHDRAWAL or int(use.get("squad", -1)) == squad): return false
	return true

static func _gunship_extraction_available(s: Dictionary, player: int, squad: int) -> bool:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s) or terminator_gunship_extraction_rule(s, player).is_empty(): return false
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or bool(s.squads[squad].get("battle_shocked", false)): return false
	var keywords := unit_keywords(s, squad)
	if living(s, squad).is_empty() or "ADEPTUS ASTARTES" not in keywords or "TERMINATOR" not in keywords: return false
	if Queue.engaged(s, squad) or s.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	if int(s.squads[squad].get("training_cost", 0)) <= 0: return false
	for model: int in living(s, squad):
		if not s.units[model].get("on_battlefield", true): return false
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return false
	for use: Dictionary in s.stratagems.get("uses", []):
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and (str(use.get("stratagem", "")) == TERMINATOR_GUNSHIP_EXTRACTION or int(use.get("squad", -1)) == squad): return false
	return true

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

static func tactical_focus_roll_key(s: Dictionary, player: int, squad: int) -> String:
	return "%d:%d:%d:%d" % [int(s.get("round", 0)), int(s.get("turn", 0)), player, squad]

static func tactical_focus_roll(s: Dictionary, player: int, squad: int) -> Dictionary:
	var value: Variant = s.get("tactical_focus_rolls", {})
	if not value is Dictionary: return {}
	var key := tactical_focus_roll_key(s, player, squad)
	var roll_value: Variant = value.get(key, {})
	if not roll_value is Dictionary: return {}
	var roll: Dictionary = roll_value
	var rolls_value: Variant = roll.get("rolls", [])
	if not rolls_value is Array or rolls_value.size() != 1 or not rolls_value[0] is int: return {}
	var die := int(rolls_value[0])
	if str(roll.get("expression", "")) != "D3+3" or die < 1 or die > 6: return {}
	if int(roll.get("value", -1)) != ceili(float(die) / 2.0) + 3: return {}
	if int(roll.get("round", -1)) != int(s.get("round", 0)) or int(roll.get("turn", -1)) != int(s.get("turn", 0)) or int(roll.get("player", -1)) != player or int(roll.get("squad", -1)) != squad or str(roll.get("phase_key", "")) != phase_key(s): return {}
	for use: Dictionary in s.get("stratagems", {}).get("uses", []):
		if int(use.get("player", -1)) == player and int(use.get("squad", -1)) == squad and str(use.get("stratagem", "")) == TACTICAL_FOCUS and str(use.get("phase_key", "")) == phase_key(s): return roll.duplicate(true)
	return {}

static func error(s: Dictionary, player: int, squad: int, rule: String, model: int = -1, objective: int = -1, enemy_squad: int = -1, enemy_target: int = -1, require_end_window: bool = true) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	var source_rule := rule
	rule = rule_of(rule)
	if rule not in [ETERNAL, IN_SACRIFICE, INNER_CIRCLE_RELIC_TELEPORTARIUM, MEDUSA_VENGEFUL_ANIMUS]:
		if not s.squads.has(squad) or s.squads[squad].owner != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
		if rule != STORM_OF_VENGEANCE and bool(s.squads[squad].get("battle_shocked", false)): return "Battle-shocked units cannot receive friendly stratagems."
	if rule == IN_SACRIFICE:
		if not wrath_of_the_rock_enabled(s, player): return "In Sacrifice, Victory requires your Wrath of the Rock detachment."
		if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player: return "Choose the destroyed friendly Deathwing or Ravenwing unit."
		if not _in_sacrifice_reaction_safe(s): return "Resolve the current destruction and reaction choices first."
		var destroyed_record := _in_sacrifice_record(s, player, squad, model)
		if destroyed_record.is_empty(): return "In Sacrifice, Victory requires a Deathwing or Ravenwing unit destroyed this phase within objective range."
		if objective not in _in_sacrifice_objectives(s, destroyed_record, player): return "Choose an objective with no enemy non-Aircraft units in range, or one this unit controlled at the end of the previous phase."
	elif rule == ADAPTIVE:
		if source_rule == ULTRAMARIAN_ADAPTIVITY:
			if not blade_ultramar_enabled(s, player) or s.phase != "command" or s.active != player: return "Ultramarian Adaptivity requires your Blade of Ultramar Command phase."
			if not marine_unit(s, squad): return "Ultramarian Adaptivity requires a friendly Adeptus Astartes unit."
		elif s.phase != "command" or s.active != player or not gladius_enabled(s, player): return "Adaptive Strategy requires your Gladius Command phase."
	elif rule == LIONS_WILL:
		if not wrath_of_the_rock_enabled(s, player) or s.phase != "command" or int(s.active) != player: return "Lion's Will requires your Wrath of the Rock Command phase."
		if not marine_unit(s, squad) or not unit_within_objective_range(s, squad): return "Lion's Will requires a friendly Adeptus Astartes unit within range of an objective."
	elif rule == FOR_THE_EMPEROR:
		if not firestorm_enabled(s, player) or s.phase != "command" or int(s.active) != player: return "For the Emperor! requires your Tacticus Firestorm Force Command phase."
		if not Doctrines.codex_fire_patterns(s, squad) or not unit_within_objective_range(s, squad): return "For the Emperor! requires a friendly Tacticus unit within range of an objective."
	elif rule == TACTICAL_MASTERY:
		if not wrath_of_the_rock_enabled(s, player) or s.phase != "command" or s.active != player or player not in s.get("combat_doctrines", {}).get("owners", []): return "Tactical Mastery requires your Wrath of the Rock Command phase."
		if not deathwing_or_ravenwing_unit(s, squad): return "Tactical Mastery requires a friendly Deathwing or Ravenwing unit."
	elif rule == INESCAPABLE_JUSTICE:
		if not wrath_of_the_rock_enabled(s, player) or s.phase != "fight" or int(s.get("fight_actor", -1)) != player or s.get("fight_step", "") != "attacks" or squad not in Queue.choices(s, player) or s.squads[squad].fought: return "Inescapable Justice is used when your eligible unit is selected to fight."
		if not marine_unit(s, squad): return "Inescapable Justice requires a friendly Adeptus Astartes unit."
	elif rule == TACTICAL_FOCUS:
		if not Registry.supported(rule) or not Doctrines.wrath_of_the_chapter(s, squad): return "Tactical Focus requires your Tacticus Attack Force and a friendly TACTICUS unit."
		if s.phase != "fight" or s.get("fight_step", "") != "consolidate" or int(s.get("fight_actor", -1)) != player or squad not in Queue.choices(s, player): return "Tactical Focus is used when your eligible TACTICUS unit is selected to consolidate."
	elif rule == TRANSHUMAN_SWIFTNESS:
		if not Registry.supported(rule) or not Doctrines.wrath_of_the_chapter(s, squad): return "Transhuman Swiftness requires your Tacticus Attack Force and a friendly TACTICUS unit."
		var fight_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var fighter := int(fight_window.get("fighter", -1))
		var resume_step := str(fight_window.get("resume_step", "attacks"))
		if s.phase != "fight" or s.get("fight_step", "") not in ["attacks", "consolidation_reaction"] or s.get("fight_step", "") != resume_step or fight_window.get("kind", "") != "counter" or fight_window.get("owners", []) != [player] or str(fight_window.get("phase_key", "")) != phase_key(s): return "Transhuman Swiftness requires the immediate post-fight reaction window."
		if not s.squads.has(fighter) or int(s.squads[fighter].get("owner", -1)) == player or not bool(s.squads[fighter].get("fought", false)): return "Transhuman Swiftness requires an enemy unit that has just fought."
		if int(s.get("fight_actor", -1)) != int(s.squads[fighter].get("owner", -2)): return "Transhuman Swiftness requires the unit that just fought to own the current Fight action."
		if not Queue.eligible(s, squad): return "Transhuman Swiftness requires a friendly unit eligible to fight."
		if not unit_within_objective_range(s, squad): return "Transhuman Swiftness requires the unit to be within range of an objective."
		if resume_step == "consolidation_reaction" and typeof(s.get("reaction_queue", null)) != TYPE_ARRAY: return "The forced consolidation reaction queue is malformed."
		if resume_step == "consolidation_reaction" and fighter not in s.get("reaction_queue", []): return "Transhuman Swiftness's trigger is no longer in the forced consolidation reaction queue."
	elif rule == RELENTLESS_ASSAULT:
		if source_rule == FIRESTORM_RELENTLESS_ASSAULT:
			if not firestorm_enabled(s, player) or not Registry.enabled(s, FIRESTORM_RELENTLESS_ASSAULT) or not Doctrines.codex_fire_patterns(s, squad): return "Relentless Assault requires your Tacticus Firestorm Force and a friendly TACTICUS unit."
		elif not Registry.enabled(s, RELENTLESS_ASSAULT) or not Doctrines.wrath_of_the_chapter(s, squad): return "Relentless Assault requires your Tacticus Attack Force and a friendly TACTICUS unit."
		var attack_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = attack_window.get("declaration", {})
		var is_fight := s.phase == "fight"
		if s.phase not in ["shooting", "fight"] or (s.phase == "shooting" and int(s.active) != player): return "Relentless Assault is used in your Shooting phase or Fight phase."
		if is_fight and (int(s.get("fight_actor", -1)) != player or s.get("fight_step", "") != "attacks"): return "Relentless Assault requires your selected unit's Fight-phase attack activation."
		if attack_window.get("kind", "") != RELENTLESS_ASSAULT_WINDOW or attack_window.get("owners", []) != [player] or int(attack_window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", false)) != is_fight: return "Relentless Assault requires the selected unit's immediate attack declaration window."
	elif rule == FIRESTORM_POINT_BLANK_BRUTALITY:
		var attack_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = attack_window.get("declaration", {})
		if not firestorm_enabled(s, player) or not Registry.enabled(s, FIRESTORM_POINT_BLANK_BRUTALITY): return "Point-Blank Brutality requires your Tacticus Firestorm Force."
		if s.phase != "shooting" or int(s.active) != player or s.squads[squad].shot: return "Point-Blank Brutality is used when this unit is selected to shoot in your Shooting phase."
		if "TACTICUS" not in unit_keywords(s, squad): return "Point-Blank Brutality requires a friendly TACTICUS unit."
		if not Queue.engaged(s, squad): return "Point-Blank Brutality requires the selected unit to be engaged."
		if attack_window.get("kind", "") != POINT_BLANK_BRUTALITY_WINDOW or attack_window.get("owners", []) != [player] or int(attack_window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", false)): return "Point-Blank Brutality requires this unit's immediate Shooting attack declaration."
	elif rule == RELICS_OF_THE_DARK_AGE:
		var keywords := unit_keywords(s, squad)
		if not wrath_of_the_rock_enabled(s, player) or s.phase != "shooting" or int(s.active) != player or s.squads[squad].shot: return "Relics of the Dark Age is used when your eligible unit is selected to shoot."
		if "ADEPTUS ASTARTES" not in keywords or ("INFANTRY" not in keywords and "MOUNTED" not in keywords): return "Relics of the Dark Age requires a friendly Adeptus Astartes Infantry or Mounted unit."
	elif rule == STORM:
		if source_rule == ULTRAMARINES_EXEMPLARY_VIGILANCE:
			if not blade_ultramar_enabled(s, player) or s.phase != "shooting" or s.active != player or s.squads[squad].shot or not marine_unit(s, squad): return "Exemplary Vigilance requires your Blade of Ultramar Shooting phase and a friendly Adeptus Astartes unit selected to shoot."
		elif s.phase != "shooting" or s.active != player or not gladius_enabled(s, player) or s.squads[squad].shot: return "Storm of Devastation requires your Gladius Shooting phase and a unit that has not shot."
	elif rule == STORM_OF_FIRE:
		if not devastator_brethren_enabled(s, player) or s.phase != "shooting" or s.active != player or s.squads[squad].shot: return "Storm of Fire requires your Devastator Brethren Shooting phase and a unit that has not shot."
	elif rule == ARMOUR:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		return armour_error(s, player, squad, int(window.get("attacker_squad", -1)), true)
	elif rule == ULTRAMARINES_TACTICAL_FORESIGHT:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		return tactical_foresight_error(s, player, squad, int(window.get("attacker_squad", -1)), true)
	elif rule == MIGHT:
		if source_rule == ULTRAMARINES_COURAGE:
			if not blade_ultramar_enabled(s, player) or s.phase != "fight" or s.fight_actor != player or s.fight_step not in ["attacks", "consolidation_reaction"] or squad not in Queue.choices(s, player) or s.squads[squad].fought: return "Courage and Honour! requires your eligible Blade of Ultramar unit when it is selected to fight."
		else:
			if s.phase != "fight" or not gladius_enabled(s, player) or s.squads[squad].fought: return "Might of Angels requires a Gladius unit selected to fight."
			if s.fight_selected != squad and s.fight_actor != player: return "Might of Angels requires a Gladius unit selected to fight."
		if not marine_unit(s, squad): return "Courage and Honour! requires a friendly Adeptus Astartes unit." if source_rule == ULTRAMARINES_COURAGE else "Might of Angels requires a friendly Adeptus Astartes unit."
	elif rule == HUNGRY:
		if s.phase != "fight" or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].fought or s.get("fight_selected", -1) == squad: return "Hungry Void requires an Awakened unit not yet selected to fight."
	elif rule == SUDDEN:
		if s.phase != "movement" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []): return "Sudden Storm requires your Awakened Movement phase."
	elif rule == TYRANT:
		if s.phase != "shooting" or s.active != player or player not in s.get("awakened_dynasty", {}).get("owners", []) or s.squads[squad].shot: return "Conquering Tyrant requires your Awakened Shooting phase and a unit that has not shot."
	elif rule == WORTHY:
		var available_worthy := worthy_stratagem(s, player)
		if s.phase != "fight" or s.squads[squad].fought or available_worthy.is_empty() or source_rule != available_worthy: return "The selected reaction requires its eligible unit in the Fight phase."
		if source_rule == INNER_CIRCLE_DUTY_UNTO_DEATH and (not Registry.enabled(s, INNER_CIRCLE_DUTY_UNTO_DEATH) or not inner_circle_deathwing_unit(s, player, squad)): return "Duty Unto Death requires your Inner Circle Task Force and a friendly Deathwing unit not yet selected to fight."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		if window.get("kind", "") != WORTHY_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or int(declaration.get("player", -1)) == player: return "An enemy attack must target this unit before it can use this stratagem."
		var declared_target := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: declared_target = true
		if not declared_target: return "The pending enemy attack does not target this unit."
	elif rule == TACTICS:
		if s.phase != "movement" or s.active == player or not gladius_enabled(s, player): return "Responsive Tactics is used in your opponent's Movement phase with Gladius."
		if Queue.engaged(s, squad) or not _infantry_or_mounted(s, squad): return "Responsive Tactics requires an unengaged Adeptus Astartes Infantry or Mounted unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		if moved.get("phase_key", "") != phase_key(s) or int(moved.get("owner", player)) == player: return "An enemy unit must have just ended a move."
		if not _within(s, squad, int(moved.squad), 8.0): return "Responsive Tactics requires the enemy move to end within 8 inches."
	elif rule == PHOBOS_TRANSHUMAN_REACTIONS:
		if not phobos_transhuman_enabled(s, player) or s.phase != "movement" or int(s.active) == player: return "Transhuman Reactions is used in your opponent's Movement phase with Phobos Shock Force."
		if G.alive(s, squad).is_empty() or Queue.engaged(s, squad) or "PHOBOS" not in unit_keywords(s, squad): return "Transhuman Reactions requires an unengaged friendly PHOBOS unit on the battlefield."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		var moved_squad := int(moved.get("squad", -1))
		if moved.get("phase_key", "") != phase_key(s) or moved_squad < 0 or not s.squads.has(moved_squad) or int(moved.get("owner", player)) != int(s.active) or G.alive(s, moved_squad).is_empty(): return "An enemy unit must have just ended a move."
		if not _within(s, squad, moved_squad, 8.0): return "Transhuman Reactions requires the enemy move to end within 8 inches."
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
	elif rule == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS:
		if not Registry.supported(rule) or not gravis_suppression_enabled(s, player): return "Suppression Volleys requires your Gravis Siege Force detachment."
		if s.phase != "shooting" or int(s.active) != player or not gravis_unit(s, squad) or not bool(s.squads[squad].get("shot", false)): return "Suppression Volleys requires your GRAVIS unit after it has shot in your Shooting phase."
		var pending: Dictionary = s.detachment_stratagems.get("gravis_suppression_pending", {}).get(squad, {})
		if pending.get("phase_key", "") != phase_key(s) or int(pending.get("owner", -1)) != player or enemy_target not in pending.get("targets", []): return "Choose an enemy unit hit by this GRAVIS unit's attacks."
		if not s.squads.has(enemy_target) or int(s.squads[enemy_target].get("owner", -1)) == player or living(s, enemy_target).is_empty(): return "Choose a living enemy unit hit by this GRAVIS unit's attacks."
	elif rule == HAIL_OF_VENGEANCE:
		var pending: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
		if not devastator_brethren_enabled(s, player) or s.phase != "shooting" or s.active == player or pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player: return "Hail of Vengeance requires a Devastator Brethren unit destroyed by an enemy Shooting attack."
		if squad not in pending.get("victims", []) or living(s, squad).is_empty(): return "Hail of Vengeance targets a friendly unit that lost a model to the pending enemy shooting attack."
		if living(s, int(pending.get("attacker", -1))).is_empty(): return "The enemy shooting unit must still be on the battlefield."
	elif rule == STORM_OF_VENGEANCE:
		var pending: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {})
		var selected_reaction: Dictionary = s.detachment_stratagems.get("vengeful", {})
		if s.phase != "shooting" or int(s.active) == player or pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player: return "Storm of Vengeance requires a friendly Land Speeder Vengeance after an enemy Shooting activation destroys a nearby Dark Angels unit."
		if str(selected_reaction.get("source", "")) == STORM_OF_VENGEANCE: return "Resolve the selected Storm of Vengeance shooter before choosing another."
		if squad not in pending.get("squads", []) or not A.has(s, squad, STORM_OF_VENGEANCE): return "Choose a Land Speeder Vengeance in the pending Storm of Vengeance reaction."
		if int(s.detachment_stratagems.get("storm_of_vengeance_used", {}).get(str(squad), -1)) == int(s.turn): return "This Land Speeder Vengeance has already used Storm of Vengeance this turn."
		if living(s, int(pending.get("attacker", -1))).is_empty(): return "The enemy shooting unit must still be on the battlefield."
	elif rule == HUNTERS_INSTINCTS:
		var practical_tactics := source_rule == ULTRAMARIAN_PRACTICAL_TACTICS
		if practical_tactics:
			if not blade_ultramar_enabled(s, player) or s.phase != "movement" or int(s.active) == player: return "Practical Tactics is used in your opponent's Movement phase with Blade of Ultramar."
			if Queue.engaged(s, squad) or not _marine_infantry_or_mounted(s, squad): return "Practical Tactics requires an unengaged friendly Adeptus Astartes Infantry or Mounted unit."
		else:
			if not spearpoint_enabled(s, player) or s.phase != "movement" or int(s.active) == player: return "Hunter's Instincts is used in your opponent's Movement phase."
			if Queue.engaged(s, squad) or not _spearpoint_reactive_unit(s, squad): return "Hunter's Instincts requires an unengaged Adeptus Astartes Infantry, Mounted or Speeder unit."
		var moved: Dictionary = s.detachment_stratagems.get("last_move", {})
		var moved_squad := int(moved.get("squad", -1))
		if moved.get("phase_key", "") != phase_key(s) or moved_squad < 0 or not s.squads.has(moved_squad) or int(moved.get("owner", -1)) != int(s.active) or living(s, moved_squad).is_empty(): return "An enemy unit must have just ended a move."
		if not _within(s, squad, moved_squad, 8.0): return "Practical Tactics requires the enemy move to end within 8 inches." if practical_tactics else "Hunter's Instincts requires the enemy move to end within 8 inches."
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
		if reaction.get("kind", "") not in [SHOOTING_REACTION_WINDOW, "mounted-shooting-reaction", "stormlance-hurtling"] or reaction.get("owners", []) != [player] or int(reaction.get("squad", -1)) != squad: return "No matching detachment shooting reaction is pending."
		var declaration: Dictionary = reaction.get("declaration", {})
		var targeted := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: targeted = true
		if not targeted or int(declaration.get("player", player)) == player: return "The pending enemy shooting declaration does not target this unit."
	elif rule == PHOBOS_UMBRAL_EVASION:
		if not phobos_umbral_enabled(s, player) or s.phase != "shooting" or int(s.active) == player or "PHOBOS" not in unit_keywords(s, squad): return "Umbral Evasion requires a friendly PHOBOS unit targeted during the opponent's Shooting phase."
		var reaction: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var umbral_targets: Array = reaction.get("umbral_targets", [int(reaction.get("squad", -1))])
		if reaction.get("kind", "") not in [SHOOTING_REACTION_WINDOW, "mounted-shooting-reaction", "stormlance-hurtling"] or reaction.get("owners", []) != [player] or squad not in umbral_targets: return "No matching Umbral Evasion shooting reaction is pending."
		var declaration: Dictionary = reaction.get("declaration", {})
		if declaration.get("kind", "") != "attack" or bool(declaration.get("melee", false)) or int(declaration.get("player", player)) == player: return "Umbral Evasion requires a pending enemy ranged attack declaration."
		var targeted := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: targeted = true
		if not targeted: return "The pending enemy shooting declaration does not target this PHOBOS unit."
	elif rule == SKYBORNE_SURVEILLANCE:
		if not Registry.supported(rule) or not darkflight_enabled(s, player) or s.phase != "shooting" or int(s.active) != player: return "Skyborne Surveillance requires your Darkflight Pursuit Shooting phase."
		var pending: Dictionary = s.detachment_stratagems.get("darkflight_skyborne_pending", {})
		if pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player or int(pending.get("squad", -1)) != squad: return "Skyborne Surveillance is only available after this Ravenwing Fly unit has shot."
		if not darkflight_ravenwing_fly_unit(s, player, squad) or not bool(s.squads[squad].get("shot", false)): return "Skyborne Surveillance requires the Ravenwing Fly unit that just shot."
	elif rule == WINGS_OF_SHADOW:
		if not Registry.supported(rule) or not darkflight_enabled(s, player) or s.phase != "shooting" or int(s.active) == player: return "Wings of Shadow requires a Darkflight Pursuit unit targeted during your opponent's Shooting phase."
		var reaction: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = reaction.get("declaration", {})
		if reaction.get("kind", "") != DARKFLIGHT_WINDOW or reaction.get("owners", []) != [player] or int(reaction.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or bool(declaration.get("melee", false)) or int(declaration.get("player", player)) == player: return "No matching Wings of Shadow attack declaration is pending."
		var targeted := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: targeted = true
		if not targeted or not darkflight_ravenwing_unit(s, player, squad): return "Wings of Shadow requires the pending enemy attack to target a Ravenwing Fly or Mounted unit."
	elif rule == WE_ARE_VENGEANCE:
		if not Registry.supported(rule) or not darkflight_enabled(s, player) or s.phase != "shooting" or int(s.active) == player: return "We Are Vengeance requires Darkflight Pursuit during your opponent's Shooting phase."
		if Queue.engaged(s, squad) or not darkflight_ravenwing_fly_unit(s, player, squad): return "We Are Vengeance requires an unengaged Ravenwing Fly unit."
		var pending: Dictionary = s.detachment_stratagems.get("darkflight_vengeance_pending", {})
		if pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player or squad not in pending.get("targets", []): return "An enemy unit must have just shot after targeting this Ravenwing Fly unit."
		var attacker := int(pending.get("attacker", -1))
		if not s.squads.has(attacker) or int(s.squads[attacker].get("owner", -1)) != int(s.active) or not bool(s.squads[attacker].get("shot", false)): return "The triggering enemy shooting activation is no longer available."
		for use: Dictionary in s.get("stratagems", {}).get("uses", []):
			if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and str(use.get("stratagem", "")) == WE_ARE_VENGEANCE: return "We Are Vengeance has already been used this phase."
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
	elif rule == TERMINATOR_GUNSHIP_EXTRACTION:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if s.phase != "fight" or int(s.active) == player or window.get("kind", "") != "end" or player not in window.get("owners", []): return "Gunship Extraction is used at the end of your opponent's Fight phase."
		if squad not in gunship_extraction_squads(s, player): return "Gunship Extraction requires an unengaged friendly Adeptus Astartes Terminator unit on the battlefield, with 1 CP available."
	elif rule == PHOBOS_SHADOW_TACTICAL_WITHDRAWAL:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if not Registry.supported(rule) or not phobos_tactical_withdrawal_enabled(s, player): return "Tactical Withdrawal requires your Phobos Shadow Force detachment."
		if s.phase != "fight" or int(s.active) == player or window.get("kind", "") != "end" or player not in window.get("owners", []): return "Tactical Withdrawal is used at the end of your opponent's Fight phase."
		if squad not in phobos_tactical_withdrawal_squads(s, player): return "Tactical Withdrawal requires an unengaged friendly PHOBOS or SCOUT SQUAD unit on the battlefield, with 1 CP available."
	elif rule == PHOBOS_SHADOW_MORTIS_SNARES:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if not Registry.supported(rule) or not phobos_mortis_snares_enabled(s, player): return "Mortis Snares requires your Phobos Shadow Force detachment."
		if s.phase != "movement" or int(s.active) != player or window.get("kind", "") != "end" or player not in window.get("owners", []): return "Mortis Snares is used at the end of your Movement phase."
		if not _phobos_mortis_snares_available(s, player, squad): return "Mortis Snares requires an eligible unengaged friendly PHOBOS or SCOUT SQUAD unit controlling an objective, with 1 CP available."
	elif rule == MERCY_IS_WEAKNESS:
		if "ironclad-champions" not in s.detachment_stratagems.get("modes", []) or not s.get("combat_doctrines", {}).get("ironclad_champions", false) or player not in s.get("combat_doctrines", {}).get("owners", []) or not Doctrines.enduring_vengeance(s, squad): return "Mercy is Weakness requires your Ironclad Champions Dreadnought unit."
		var selected_to_attack: bool = s.phase == "shooting" and s.active == player and not s.squads[squad].shot
		selected_to_attack = selected_to_attack or (s.phase == "fight" and s.fight_actor == player and s.fight_step == "attacks" and (s.fight_selected == squad or squad in Queue.choices(s, player)))
		if not selected_to_attack: return "Mercy is Weakness is used when your Dreadnought is selected to attack."
	elif rule in [GRAVIS_LINEBREAKER_ANNIHILATING_FORCE, GRAVIS_SIEGE_ANNIHILATING_FORCE]:
		if not Registry.supported(rule) or gravis_annihilating_rule(s, player) != rule: return "Annihilating Force requires your Gravis Linebreaker or Gravis Siege Force detachment."
		if not gravis_unit(s, squad): return "Annihilating Force requires a friendly GRAVIS unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		var selected_to_attack: bool = s.phase == "shooting" and s.active == player and not s.squads[squad].shot
		selected_to_attack = selected_to_attack or (s.phase == "fight" and s.fight_actor == player and s.fight_step == "attacks" and (s.fight_selected == squad or squad in Queue.choices(s, player)) and not s.squads[squad].fought)
		if not selected_to_attack or window.get("kind", "") != GRAVIS_ANNIHILATING_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", false)) != (s.phase == "fight"):
			return "Annihilating Force is used when your GRAVIS unit is selected to attack."
	elif rule == TERMINATOR_MERCILESS_VETERANS:
		if terminator_merciless_rule(s, player).is_empty(): return "Merciless Veterans requires your Terminator Storm Force detachment."
		if s.phase != "shooting" or int(s.active) != player or s.squads[squad].shot: return "Merciless Veterans is used when your Terminator unit is selected to shoot."
		var keywords := unit_keywords(s, squad)
		if "ADEPTUS ASTARTES" not in keywords or "TERMINATOR" not in keywords: return "Merciless Veterans requires a friendly Adeptus Astartes Terminator unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		if window.get("kind", "") != TERMINATOR_MERCILESS_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", true)):
			return "Merciless Veterans is used when your Terminator unit is selected to shoot."
	elif rule in [PHOBOS_STRIKE_FROM_SHADOWS, PHOBOS_SHADOW_STRIKE_FROM_SHADOWS]:
		if rule == PHOBOS_STRIKE_FROM_SHADOWS and not phobos_shock_enabled(s, player): return "Strike from the Shadows requires your Phobos Shock Force detachment."
		if rule == PHOBOS_SHADOW_STRIKE_FROM_SHADOWS and not phobos_shadow_strike_enabled(s, player): return "Strike from the Shadows requires your Phobos Shadow Force detachment."
		if "PHOBOS" not in unit_keywords(s, squad): return "Strike from the Shadows requires a friendly PHOBOS unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		var is_fight := s.phase == "fight"
		var selected_to_attack := s.phase == "shooting" and int(s.active) == player and not bool(s.squads[squad].get("shot", false))
		selected_to_attack = selected_to_attack or (is_fight and int(s.get("fight_actor", -1)) == player and s.get("fight_step", "") == "attacks" and (int(s.get("fight_selected", -1)) == squad or squad in Queue.choices(s, player)) and not bool(s.squads[squad].get("fought", false)))
		if not selected_to_attack or s.phase not in ["shooting", "fight"]: return "Strike from the Shadows is used when your hidden PHOBOS unit is selected to attack in your Shooting or Fight phase."
		if not phobos_unit_hidden(s, squad): return "Strike from the Shadows requires every living model in the PHOBOS unit to be hidden."
		if window.get("kind", "") != PHOBOS_STRIKE_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", false)) != is_fight:
			return "Strike from the Shadows requires the selected unit's immediate attack declaration window."
	elif rule == MEDUSA_METHODICAL_BRUTALITY:
		if not Registry.supported(rule): return "Methodical Brutality is blocked pending local validation."
		if not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, player): return "Methodical Brutality requires current unit abilities, Medusa's Wrath and Iron Hands Chapter context."
		if not marine_unit(s, squad): return "Methodical Brutality requires a friendly Adeptus Astartes unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		var selected_to_attack := s.phase == "shooting" and int(s.active) == player and not bool(s.squads[squad].get("shot", false))
		selected_to_attack = selected_to_attack or (s.phase == "fight" and int(s.fight_actor) == player and s.fight_step == "attacks" and (int(s.fight_selected) == squad or squad in Queue.choices(s, player)) and not bool(s.squads[squad].get("fought", false)))
		if not selected_to_attack or window.get("kind", "") != METHODICAL_BRUTALITY_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or bool(declaration.get("melee", false)) != (s.phase == "fight"):
			return "Methodical Brutality is used when your Adeptus Astartes unit is selected to attack."
	elif rule == VOW_PIOUS_ENMITY:
		if not Registry.supported(rule) or not A.enabled(s) or not vow_sworn_enabled(s, player): return "Pious Enmity requires current unit abilities, Vow-sworn Crusaders and Black Templars Chapter context."
		if not chaplain_or_judiciar_unit(s, squad): return "Pious Enmity requires a friendly Chaplain or Judiciar unit."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		var selected_to_fight := s.phase == "fight" and int(s.get("fight_actor", -1)) == player and s.get("fight_step", "") == "attacks" and (int(s.get("fight_selected", -1)) == squad or squad in Queue.choices(s, player)) and not bool(s.squads[squad].get("fought", false))
		if not selected_to_fight or window.get("kind", "") != PIOUS_ENMITY_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad or int(declaration.get("player", -1)) != player or not bool(declaration.get("melee", false)):
			return "Pious Enmity is used when your Chaplain or Judiciar unit is selected to fight."
	elif rule == MEDUSA_UNBOWED_CONVICTION:
		if not Registry.supported(rule): return "Unbowed Conviction is blocked pending local validation."
		if not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, player): return "Unbowed Conviction requires current unit abilities, Medusa's Wrath and Iron Hands Chapter context."
		if not marine_unit(s, squad): return "Unbowed Conviction requires a friendly Adeptus Astartes unit."
		if s.phase != "command" or int(s.active) != player: return "Unbowed Conviction is used in your Command phase."
		if not below_starting_strength(s, squad): return "Unbowed Conviction requires a friendly unit below Starting Strength."
	elif rule == MEDUSA_ANCIENT_FURY:
		if not Registry.supported(rule): return "Ancient Fury is blocked pending local validation."
		if not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, player): return "Ancient Fury requires current unit abilities, Medusa's Wrath and Iron Hands Chapter context."
		if not marine_unit(s, squad) or "DREADNOUGHT" not in unit_keywords(s, squad): return "Ancient Fury requires a friendly Adeptus Astartes Dreadnought unit."
		if s.phase != "command" or int(s.active) != player: return "Ancient Fury is used in your Command phase."
	elif rule == MEDUSA_POWER_OF_MACHINE_SPIRIT:
		if not Registry.supported(rule): return "Power of the Machine Spirit is blocked pending local validation."
		if not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, player): return "Power of the Machine Spirit requires current unit abilities, Medusa's Wrath and Iron Hands Chapter context."
		if s.phase != "shooting" or int(s.active) == player: return "Power of the Machine Spirit is used in your opponent's Shooting phase."
		var pending: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_pending", {})
		if pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player or squad not in pending.get("targets", []): return "Power of the Machine Spirit requires this Vehicle to have been targeted while unengaged by the enemy unit that just shot."
		if living(s, int(pending.get("attacker", -1))).is_empty(): return "The enemy unit that triggered Power of the Machine Spirit must still be on the battlefield."
		if not marine_unit(s, squad) or "VEHICLE" not in unit_keywords(s, squad): return "Power of the Machine Spirit requires a friendly Adeptus Astartes Vehicle."
	elif rule == TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		return terminator_fortitude_error(s, player, squad, int(window.get("attacker_squad", -1)), true)
	elif rule == GRAVIS_LINEBREAKER_ARMOURED_IMPACT:
		if not Registry.supported(rule) or Doctrines.detachment_for(s, player) != "gravis-linebreaker-force" or "gravis-linebreaker-force" not in s.detachment_stratagems.get("modes", []): return "Armoured Impact requires your Gravis Linebreaker Force detachment."
		if not gravis_unit(s, squad) or s.phase != "charge" or int(s.active) != player or not bool(s.squads[squad].get("charged", false)): return "Armoured Impact requires your GRAVIS unit after it ends a charge move."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != "hammer-of-wrath" or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return "Armoured Impact requires the current post-charge choice."
		if not s.squads.has(enemy_squad) or int(s.squads[enemy_squad].get("owner", -1)) == player or living(s, enemy_squad).is_empty(): return "Choose a living enemy unit engaged with your charging unit."
		var engaged := false
		for friendly_model: int in living(s, squad):
			for enemy_model: int in living(s, enemy_squad):
				if G.within_engagement(s.units[friendly_model], s.units[enemy_model]):
					engaged = true
					break
			if engaged: break
		if not engaged: return "Choose a living enemy unit engaged with your charging unit."
	elif rule == INNER_CIRCLE_WRATH_OF_THE_LION:
		if not Registry.supported(rule) or not inner_circle_deathwing_unit(s, player, squad): return "Wrath of the Lion requires your Inner Circle Task Force and a friendly Deathwing unit."
		if s.phase != "charge" or int(s.active) != player or not bool(s.squads[squad].get("charged", false)): return "Wrath of the Lion is used when your Deathwing unit ends a Charge move."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != "hammer-of-wrath" or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return "Wrath of the Lion requires the current post-charge choice."
		if not s.squads.has(enemy_squad) or int(s.squads[enemy_squad].get("owner", -1)) == player or living(s, enemy_squad).is_empty(): return "Choose a living enemy unit engaged with your charging Deathwing unit."
		var engaged := false
		for friendly_model: int in G.alive(s, squad):
			for enemy_model: int in G.alive(s, enemy_squad):
				if G.within_engagement(s.units[friendly_model], s.units[enemy_model]):
					engaged = true
					break
			if engaged: break
		if not engaged: return "Choose a living enemy unit engaged with your charging Deathwing unit."
	elif rule == INNER_CIRCLE_RELIC_TELEPORTARIUM:
		if not Registry.enabled(s, INNER_CIRCLE_RELIC_TELEPORTARIUM) or not inner_circle_deathwing_reserve(s, player, squad): return "Relic Teleportarium requires your Inner Circle Task Force and a friendly Deathwing unit in reserves."
		if s.phase != "movement" or int(s.active) != player: return "Relic Teleportarium is used in your Movement phase."
		var reserves: Variant = s.get("unit_abilities", {}).get("reserves", {})
		if not reserves is Dictionary or not reserves.has(squad): return "Relic Teleportarium requires this Deathwing unit to be in Strategic Reserves."
		if not reserve_unit_has_deep_strike(s, squad): return "Relic Teleportarium requires every model in the unit to have Deep Strike."
		if not StormlanceEnhancements.ingress_round_allowed(s, squad): return "This unit cannot make an ingress move in this battle round."
	elif rule == GRAVIS_LINEBREAKER_PURGATION_PUSH:
		if not Registry.supported(rule) or Doctrines.detachment_for(s, player) != "gravis-linebreaker-force" or "gravis-linebreaker-force" not in s.detachment_stratagems.get("modes", []): return "Purgation Push requires your Gravis Linebreaker Force detachment."
		if not gravis_unit(s, squad): return "Purgation Push requires a friendly GRAVIS unit."
		if not TacticalFluidity.purgation_push_eligible(s, squad, player): return "Purgation Push requires your unengaged GRAVIS unit after it shoots in your Shooting phase."
	elif rule == GRAVIS_SIEGE_STAND_UNYIELDING:
		if not Registry.supported(rule) or not gravis_siege_enabled(s, player): return "Stand Unyielding requires your Gravis Siege Force detachment."
		if s.phase != "movement" or int(s.active) != player or squad not in stand_unyielding_squads(s, player): return "Stand Unyielding requires your GRAVIS unit controlling an objective at the end of your Movement phase."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != "end" or player not in window.get("owners", []): return "Stand Unyielding is chosen in your Movement phase end window."
		if objective not in stand_unyielding_objectives(s, squad): return "Choose one objective controlled by this GRAVIS unit."
	elif rule == GAUNTLET_STORM_AND_SECURE:
		if not Registry.supported(rule) or not gauntlet_enabled(s, player): return "Storm and Secure requires your Gauntlet Task Force detachment."
		if s.phase != "movement" or int(s.active) != player or squad not in gauntlet_storm_and_secure_squads(s, player): return "Storm and Secure requires your eligible Astartes Transport at the end of your Movement phase."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != "end" or player not in window.get("owners", []): return "Storm and Secure is chosen in your Movement phase end window."
		if objective not in gauntlet_storm_and_secure_objectives(s, squad): return "Choose one objective controlled by this Transport while it carries an Astartes Battleline unit."
	elif rule == GAUNTLET_DUTY_IS_NEVER_DONE:
		if not Registry.supported(rule) or not gauntlet_enabled(s, player): return "Duty is Never Done requires your Gauntlet Task Force detachment."
		if s.phase != "fight": return "Duty is Never Done is used at the end of the Fight phase."
		if not _marine_infantry(s, squad): return "Duty is Never Done requires a friendly ADEPTUS ASTARTES INFANTRY unit."
		if not bool(s.squads[squad].get("fight_eligible", false)): return "Duty is Never Done requires a unit that was eligible to fight this phase."
		if Queue.engaged(s, squad): return "Duty is Never Done requires the unit to be unengaged."
		if require_end_window:
			var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
			if window.get("kind", "") != "end" or player not in window.get("owners", []): return "Duty is Never Done is chosen in the Fight phase end window."
	elif rule == GAUNTLET_AGGRESSIVE_DISEMBARKATION:
		if not Registry.supported(rule) or not gauntlet_enabled(s, player): return "Aggressive Disembarkation requires your Gauntlet Task Force detachment."
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
	elif rule == KNIGHTS_OF_IRON:
		if not mobile_declaration_available(s, player, squad, rule): return "Knights of Iron requires an eligible Ravenwing unit selected to move or charge in your Wrath of the Rock detachment, with 1 CP available."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != UNSTOPPABLE_WINDOW or int(window.get("squad", -1)) != squad or window.get("owners", []) != [player]: return "Knights of Iron is used when this Ravenwing unit is selected to move or declares a charge."
		if str(window.get("trigger", "")) != str(s.phase): return "Knights of Iron is only available for the selected Movement or Charge phase action."
	elif rule == IRONSTORM_MIGHT:
		if not Registry.supported(rule): return "Might of the Machine Spirit is blocked pending local validation."
		if not ironstorm_enabled(s, player) or s.phase != "command" or int(s.active) != player or not ironstorm_vehicle_unit(s, squad): return "Might of the Machine Spirit requires your Command phase and an eligible Ironstorm Vehicle unit."
	elif rule == IRONSTORM_HEADHUNTER:
		if not Registry.supported(rule): return "Headhunter Doctrine is blocked pending local validation."
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		var declaration: Dictionary = window.get("declaration", {})
		if not ironstorm_enabled(s, player) or s.phase != "shooting" or int(s.active) != player or s.squads[squad].shot or not ironstorm_vehicle_unit(s, squad): return "Headhunter Doctrine requires an eligible Ironstorm Vehicle selected to shoot in your Shooting phase."
		if window.get("kind", "") != HEADHUNTER_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != squad: return "Headhunter Doctrine is used when the Vehicle is selected to shoot."
	elif rule == IRONSTORM_LAYERED_CERAMITE:
		if not Registry.supported(rule): return "Layered Ceramite is blocked pending local validation."
		if not ironstorm_enabled(s, player) or not layered_ceramite_triggered(s, squad): return "Layered Ceramite is available when this friendly Ironstorm Vehicle suffers a mortal wound."
	elif rule == MEDUSA_SPIRITS_OF_IRON:
		if not Registry.supported(rule): return "Spirits of Iron is blocked pending local validation."
		if not medusa_wrath_enabled(s, player): return "Spirits of Iron requires Medusa's Wrath and Iron Hands Chapter context."
		if not spirits_of_iron_triggered(s, squad): return "Spirits of Iron is available when this friendly Adeptus Astartes unit suffers a mortal wound."
	elif rule == MEDUSA_VENGEFUL_ANIMUS:
		if not Registry.supported(rule): return "Vengeful Animus is blocked pending local validation."
		if not medusa_wrath_enabled(s, player): return "Vengeful Animus requires Medusa's Wrath and Iron Hands Chapter context."
		if not vengeful_animus_triggered(s, player, squad, model): return "Vengeful Animus is used after this friendly Adeptus Astartes Vehicle is destroyed and before its Deadly Demise roll."
	elif rule == UNDYING:
		var after: Dictionary = s.detachment_stratagems.get("after", {})
		if player not in s.get("awakened_dynasty", {}).get("owners", []): return "Undying Legions requires an Awakened unit."
		if s.phase not in ["shooting", "fight"] or not Reanimation.enabled(s) or not supported_reanimation_unit(s, squad): return "Undying Legions requires a supported Necron unit in the opponent's Shooting or Fight phase."
		if after.get("phase_key", "") != phase_key(s) or squad not in after.get("victims", []): return "Undying Legions is used just after an enemy unit destroys models in your unit."
		if bool(after.get("undying_closed", false)): return "The Undying Legions reaction for this attack has already been resolved."
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
		if bool(after.get("vengeful_closed", false)): return "The Vengeful Stars reaction for this attack has already been resolved."
		if living(s, int(after.get("attacker", -1))).is_empty(): return "The destroying unit must still be on the battlefield."
		if not _near_wiped(s, squad, after.wiped, 6.0): return "Vengeful Stars requires a Character within 6 inches of the destroyed unit."
	else: return "Unknown detachment stratagem."
	if rule != STORM_OF_VENGEANCE:
		var resuming_tactical_focus := rule == TACTICAL_FOCUS and not tactical_focus_roll(s, player, squad).is_empty()
		var stratagem_cost := 2 if rule in [HAIL_OF_VENGEANCE, TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE] else 1
		if not resuming_tactical_focus and s.cp.get(player, 0) < maxi(0, stratagem_cost - A.discount(s, player, squad)): return "This stratagem costs %d CP; arm an eligible discount first." % stratagem_cost
		for use: Dictionary in s.stratagems.uses:
			if use.player == player and use.phase_key == phase_key(s):
				if resuming_tactical_focus and int(use.get("squad", -1)) == squad and str(use.get("stratagem", "")) == TACTICAL_FOCUS: continue
				if use.stratagem == rule or (rule == RELENTLESS_ASSAULT and use.stratagem in [RELENTLESS_ASSAULT, FIRESTORM_RELENTLESS_ASSAULT]) or (rule == ARMOUR and use.stratagem in [ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR, ULTRAMARINES_ARMOUR]) or (rule == MIGHT and use.stratagem in [MIGHT, ULTRAMARINES_COURAGE]) or (rule == STORM and use.stratagem in [STORM, ULTRAMARINES_EXEMPLARY_VIGILANCE]) or (rule == ADAPTIVE and use.stratagem in [ADAPTIVE, ULTRAMARIAN_ADAPTIVITY]) or (rule == HUNTERS_INSTINCTS and use.stratagem in [HUNTERS_INSTINCTS, ULTRAMARIAN_PRACTICAL_TACTICS]) or (rule == WORTHY and use.stratagem in [DUTY_IN_DEATH, INNER_CIRCLE_DUTY_UNTO_DEATH]): return "This stratagem has already been used this phase."
				if use.squad == squad: return "This unit already received a stratagem this phase."
	return ""

static func layered_ceramite_triggered(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad) or not ironstorm_vehicle_unit(s, squad, true): return false
	return mortal_wound_triggered(s, squad)

static func spirits_of_iron_triggered(s: Dictionary, squad: int) -> bool:
	return marine_unit(s, squad) and mortal_wound_triggered(s, squad)

static func mortal_wound_triggered(s: Dictionary, squad: int) -> bool:
	if not marine_unit(s, squad) or living(s, squad).is_empty(): return false
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
	var mortal_windows := ["explosives", "crushing-impact-mortal", "hammer-of-wrath-mortal", "gravis-armoured-impact-mortal", "inner-circle-wrath-of-the-lion-mortal", "tigurius-telepathic-assault-mortal", "incursor-haywire-mortal", PHOBOS_SHADOW_MORTIS_MORTAL_WINDOW]
	if str(window.get("kind", "")) in mortal_windows and int(window.get("target", -1)) == squad: return true
	return false

static func layered_ceramite_choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not ironstorm_enabled(s, player): return result
	for squad: int in s.squads:
		if error(s, player, squad, IRONSTORM_LAYERED_CERAMITE).is_empty():
			result.append({"label": "Ironstorm Layered Ceramite: %s gains Feel No Pain 5+ against mortal wounds (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_LAYERED_CERAMITE})
	return result

static func spirits_of_iron_choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not medusa_wrath_enabled(s, player): return result
	for squad: int in s.squads:
		if error(s, player, squad, MEDUSA_SPIRITS_OF_IRON).is_empty():
			result.append({"label": "Medusa's Wrath Spirits of Iron: %s gains Feel No Pain 5+ against mortal wounds (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": MEDUSA_SPIRITS_OF_IRON})
	return result

static func vengeful_animus_choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != VENGEFUL_ANIMUS_WINDOW or window.get("owners", []) != [player]: return result
	var squad := int(window.get("squad", -1))
	if error(s, player, squad, MEDUSA_VENGEFUL_ANIMUS).is_empty():
		result.append({"label": "Medusa's Wrath Vengeful Animus: force Deadly Demise rolls for %s to 6 (1 CP)" % str(s.squads[squad].get("name", "the destroyed Vehicle")), "action": "detachment-stratagem", "model": int(window.get("source_model", -1)), "target": squad, "value": MEDUSA_VENGEFUL_ANIMUS})
	return result

static func mortal_wound_stratagem_choices(s: Dictionary, player: int) -> Array:
	var result := layered_ceramite_choices(s, player)
	result.append_array(spirits_of_iron_choices(s, player))
	return result

static func mortal_wound_reaction_name(s: Dictionary, player: int) -> String:
	return "Spirits of Iron" if medusa_wrath_enabled(s, player) else "Layered Ceramite"

static func armour_error(s: Dictionary, player: int, squad: int, attacker_squad: int, require_window: bool = false) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
	if s.squads[squad].get("battle_shocked", false): return "Battle-shocked units cannot receive friendly stratagems."
	var doctrine: Dictionary = s.get("combat_doctrines", {})
	var assault_brethren := assault_brethren_enabled(s, player)
	var tactical_brethren := tactical_brethren_enabled(s, player)
	var devastator_brethren := devastator_brethren_enabled(s, player)
	var gladius := gladius_enabled(s, player)
	var blade_ultramar := blade_ultramar_enabled(s, player)
	if not assault_brethren and not tactical_brethren and not devastator_brethren and not gladius and not blade_ultramar: return "Armour of Contempt requires a supported Adeptus Astartes detachment."
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
			if str(use.get("stratagem", "")) in [ARMOUR, ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR, ULTRAMARINES_ARMOUR]: return "Armour of Contempt has already been used this phase."
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

static func tactical_foresight_error(s: Dictionary, player: int, squad: int, attacker_squad: int, require_window: bool = false) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	if not blade_ultramar_enabled(s, player): return "Tactical Foresight requires Blade of Ultramar and Ultramarines Chapter context."
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or living(s, squad).is_empty(): return "Choose a living friendly unit."
	if bool(s.squads[squad].get("battle_shocked", false)): return "Battle-shocked units cannot receive friendly stratagems."
	for model: int in living(s, squad):
		if "ADEPTUS ASTARTES" not in s.units[model].get("keywords", []): return "Tactical Foresight targets a friendly ADEPTUS ASTARTES unit."
	if s.phase == "shooting":
		if int(s.active) == player: return "Tactical Foresight is used in your opponent's Shooting phase."
	elif s.phase != "fight": return "Tactical Foresight requires the opponent's Shooting phase or the Fight phase."
	if attacker_squad < 0 or not s.squads.has(attacker_squad) or int(s.squads[attacker_squad].get("owner", -1)) == player or living(s, attacker_squad).is_empty(): return "An enemy unit must target this unit."
	if require_window:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != ARMOUR_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or int(window.get("attacker_squad", -1)) != attacker_squad: return "No matching Tactical Foresight target decision is pending."
		var declaration: Dictionary = window.get("declaration", {})
		if int(declaration.get("squad", -1)) != attacker_squad or int(declaration.get("player", -1)) != int(s.squads[attacker_squad].get("owner", -2)): return "The enemy attack declaration no longer matches this target."
		var declared_target := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: declared_target = true
		if not declared_target: return "The declared enemy attack does not target this unit."
	if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): return "This stratagem costs 1 CP; arm an eligible discount first."
	for use: Dictionary in s.stratagems.uses:
		if int(use.get("player", -1)) != player or str(use.get("phase_key", "")) != phase_key(s): continue
		if str(use.get("stratagem", "")) == ULTRAMARINES_TACTICAL_FORESIGHT: return "Tactical Foresight has already been used this phase."
		if int(use.get("squad", -1)) == squad: return "This unit already received a stratagem this phase."
	return ""

static func tactical_foresight_wound_modifier(s: Dictionary, attacker: int, target: int, strength: int, toughness: int) -> int:
	if not enabled(s): return 0
	var record: Dictionary = s.get("detachment_stratagems", {}).get("tactical_foresight", {}).get(target, {})
	if record.get("phase_key", "") != phase_key(s) or int(record.get("attacker", -1)) != attacker: return 0
	return -1 if strength > toughness else 0

static func terminator_fortitude_error(s: Dictionary, player: int, squad: int, attacker_squad: int, require_window: bool = false) -> String:
	if not enabled(s) or not s.has("stratagems") or not A.enabled(s): return "Detachment stratagems are disabled."
	if not s.squads.has(squad) or int(s.squads[squad].get("owner", -1)) != player or living(s, squad).is_empty(): return "Choose a living friendly Terminator unit."
	if bool(s.squads[squad].get("battle_shocked", false)): return "Battle-shocked units cannot receive friendly stratagems."
	if terminator_fortitude_rule(s, player).is_empty(): return "Tactical Dreadnought Fortitude requires your Terminator Storm Force detachment."
	if s.phase == "shooting":
		if int(s.active) == player: return "Tactical Dreadnought Fortitude is used in your opponent's Shooting phase."
	elif s.phase != "fight": return "Tactical Dreadnought Fortitude requires your opponent's Shooting phase or the Fight phase."
	var keywords := unit_keywords(s, squad)
	if "ADEPTUS ASTARTES" not in keywords or "TERMINATOR" not in keywords: return "Tactical Dreadnought Fortitude requires a friendly Adeptus Astartes Terminator unit."
	if attacker_squad < 0 or not s.squads.has(attacker_squad) or int(s.squads[attacker_squad].get("owner", -1)) == player or living(s, attacker_squad).is_empty(): return "An enemy unit must target this Terminator unit."
	if require_window:
		var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if window.get("kind", "") != TERMINATOR_FORTITUDE_WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad or int(window.get("attacker_squad", -1)) != attacker_squad: return "No matching Tactical Dreadnought Fortitude decision is pending."
		var declaration: Dictionary = window.get("declaration", {})
		if declaration.get("kind", "") != "attack" or int(declaration.get("squad", -1)) != attacker_squad or int(declaration.get("player", -1)) != int(s.squads[attacker_squad].owner): return "The enemy attack declaration no longer matches this target."
		var declared_target := false
		for row: Variant in declaration.get("entries", []):
			if row is Dictionary and int(row.get("target", -1)) == squad: declared_target = true
		if not declared_target: return "The declared enemy attack does not target this unit."
	if int(s.cp.get(player, 0)) < maxi(0, 2 - A.discount(s, player, squad)): return "This stratagem costs 2 CP; arm an eligible discount first."
	for use: Dictionary in s.stratagems.get("uses", []):
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s):
			if str(use.get("stratagem", "")) == TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE: return "Tactical Dreadnought Fortitude has already been used this phase."
			if int(use.get("squad", -1)) == squad: return "This unit already received a stratagem this phase."
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

static func use_umbral_evasion(s: Dictionary, player: int, squad: int) -> String:
	var failure := error(s, player, squad, PHOBOS_UMBRAL_EVASION)
	if not failure.is_empty(): return failure
	s.cp[player] -= maxi(0, 1 - A.discount(s, player, squad))
	A.consume_discount(s, player, squad)
	s.stratagems.uses.append({"player": player, "squad": squad, "stratagem": PHOBOS_UMBRAL_EVASION, "phase_key": phase_key(s), "turn": s.turn})
	if not s.detachment_stratagems.has("phobos_umbral"): s.detachment_stratagems.phobos_umbral = {}
	s.detachment_stratagems.phobos_umbral[squad] = {"phase_key": phase_key(s)}
	return ""

static func hurtling_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and stormlance_enabled(s, int(s.squads[squad].owner)) and s.detachment_stratagems.get("hurtling", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func evasive_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and spearpoint_enabled(s, int(s.squads[squad].owner)) and s.detachment_stratagems.get("evasive", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func umbral_evasion_active(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad): return false
	var player := int(s.squads[squad].get("owner", -1))
	return phobos_umbral_enabled(s, player) and s.detachment_stratagems.get("phobos_umbral", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func mark_spotted(s: Dictionary, enemy: int, source: int) -> void:
	if not s.detachment_stratagems.has("spotted"): s.detachment_stratagems.spotted = {}
	if not s.detachment_stratagems.has("spotted_sources"): s.detachment_stratagems.spotted_sources = {}
	s.detachment_stratagems.spotted[enemy] = {"source": source, "turn": s.turn}
	s.detachment_stratagems.spotted_sources[source] = phase_key(s)

static func spotted(s: Dictionary, enemy: int) -> bool:
	return enabled(s) and s.detachment_stratagems.get("spotted", {}).has(enemy)

static func spotted_source_used(s: Dictionary, source: int) -> bool:
	return enabled(s) and str(s.detachment_stratagems.get("spotted_sources", {}).get(source, "")) == phase_key(s)

static func in_sacrifice_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _in_sacrifice_reaction_safe(s): return result
	for record_value: Variant in s.get("detachment_stratagems", {}).get("wrath_destroyed", []):
		if not record_value is Dictionary: continue
		var record: Dictionary = record_value
		if int(record.get("owner", -1)) != player or str(record.get("phase_key", "")) != phase_key(s): continue
		var squad := int(record.get("squad", -1))
		var model := int(record.get("model", -1))
		for objective in _in_sacrifice_objectives(s, record, player):
			if not error(s, player, squad, IN_SACRIFICE, model, objective).is_empty(): continue
			var marker_name := str(s.get("mission", {}).get("objectives", [])[objective].get("name", "Objective %d" % (objective + 1)))
			result.append({"label": "Wrath of the Rock In Sacrifice, Victory: %s secures %s (1 CP)" % [str(s.squads[squad].get("name", "Destroyed unit")), marker_name],
				"action": "detachment-stratagem", "model": model, "target": squad, "value": IN_SACRIFICE, "details": {"objective": objective}})
	return result

static func sacrifice_actor(s: Dictionary) -> int:
	if not _in_sacrifice_reaction_safe(s): return -1
	for record_value: Variant in s.get("detachment_stratagems", {}).get("wrath_destroyed", []):
		if not record_value is Dictionary: continue
		var record: Dictionary = record_value
		var player := int(record.get("owner", -1))
		if player not in [1, 2] or str(record.get("phase_key", "")) != phase_key(s): continue
		if not in_sacrifice_choices(s, player).is_empty(): return player
	return -1

static func darkflight_vengeance_actor(s: Dictionary) -> int:
	if not enabled(s) or s.phase != "shooting": return -1
	var pending: Dictionary = s.detachment_stratagems.get("darkflight_vengeance_pending", {})
	if str(pending.get("phase_key", "")) != phase_key(s): return -1
	var player := int(pending.get("player", -1))
	if player not in [1, 2] or player == int(s.active): return -1
	for squad_value: Variant in pending.get("targets", []):
		if squad_value is int and s.squads.has(int(squad_value)) and error(s, player, int(squad_value), WE_ARE_VENGEANCE).is_empty(): return player
	return -1

static func darkflight_skyborne_actor(s: Dictionary) -> int:
	if not enabled(s) or s.phase != "shooting": return -1
	var pending: Dictionary = s.detachment_stratagems.get("darkflight_skyborne_pending", {})
	if str(pending.get("phase_key", "")) != phase_key(s): return -1
	var player := int(pending.get("player", -1))
	if player not in [1, 2] or player != int(s.active): return -1
	return player

static func darkflight_skyborne_targets(s: Dictionary, player: int, source_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(source_squad) or not darkflight_ravenwing_fly_unit(s, player, source_squad): return result
	var observers := G.alive(s, source_squad)
	for enemy_squad_value: Variant in s.squads.keys():
		if not enemy_squad_value is int: continue
		var enemy_squad := int(enemy_squad_value)
		if int(s.squads[enemy_squad].get("owner", -1)) == player or G.alive(s, enemy_squad).is_empty(): continue
		for observer: int in observers:
			var sight := Terrain.targeting(s, observer, enemy_squad)
			if bool(sight.get("visible", false)) and float(sight.get("distance", INF)) <= 6.001:
				result.append(enemy_squad)
				break
	return result

static func darkflight_skyborne_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if darkflight_skyborne_actor(s) != player: return result
	var pending: Dictionary = s.detachment_stratagems.get("darkflight_skyborne_pending", {})
	var squad := int(pending.get("squad", -1))
	if not s.squads.has(squad): return result
	if not error(s, player, squad, SKYBORNE_SURVEILLANCE).is_empty(): return result
	var targets := darkflight_skyborne_targets(s, player, squad)
	var names: Array[String] = []
	for enemy: int in targets: names.append(str(s.squads[enemy].get("name", "enemy unit")))
	var affected := ", ".join(names) if not names.is_empty() else "no visible enemy units within 6 inches"
	result.append({"label": "Skyborne Surveillance: %s marks %s (+3 detection this phase; %d CP)" % [str(s.squads[squad].get("name", "Ravenwing unit")), affected, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": SKYBORNE_SURVEILLANCE})
	return result

static func decline_darkflight_skyborne(s: Dictionary, player: int) -> String:
	if darkflight_skyborne_actor(s) != player: return "No Skyborne Surveillance decision is pending for this player."
	s.detachment_stratagems.darkflight_skyborne_pending = {}
	return ""

static func darkflight_vengeance_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if darkflight_vengeance_actor(s) != player: return result
	var pending: Dictionary = s.detachment_stratagems.get("darkflight_vengeance_pending", {})
	for squad_value: Variant in pending.get("targets", []):
		if not squad_value is int: continue
		var squad := int(squad_value)
		if not error(s, player, squad, WE_ARE_VENGEANCE).is_empty(): continue
		result.append({"label": "We Are Vengeance: move %s up to D3+3 inches (%d CP)" % [str(s.squads[squad].get("name", "Ravenwing unit")), maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": WE_ARE_VENGEANCE})
	return result

static func decline_darkflight_vengeance(s: Dictionary, player: int) -> String:
	if darkflight_vengeance_actor(s) != player: return "No We Are Vengeance decision is pending for this player."
	s.detachment_stratagems.darkflight_vengeance_pending = {}
	return ""

static func decline_in_sacrifice(s: Dictionary, player: int, squad: int, model: int) -> String:
	if not _in_sacrifice_reaction_safe(s): return "Resolve the current destruction and reaction choices first."
	var record := _in_sacrifice_record(s, player, squad, model)
	if record.is_empty(): return "No In Sacrifice, Victory decision is pending for this destroyed unit."
	_remove_in_sacrifice_record(s, record)
	return ""

static func clear_expired_in_sacrifice(s: Dictionary) -> void:
	if not enabled(s): return
	var records: Array = s.detachment_stratagems.get("wrath_destroyed", [])
	var current_phase := phase_key(s)
	for index in range(records.size() - 1, -1, -1):
		var record: Variant = records[index]
		if not record is Dictionary or str(record.get("phase_key", "")) != current_phase: records.remove_at(index)
	s.detachment_stratagems.wrath_destroyed = records

static func choices(s: Dictionary, player: int) -> Array:
	var result: Array = []
	if not enabled(s): return result
	result.append_array(in_sacrifice_choices(s, player))
	var stand_squads := stand_unyielding_squads(s, player)
	var gauntlet_storm_squads := gauntlet_storm_and_secure_squads(s, player)
	for squad: int in s.squads:
		if error(s, player, squad, ADAPTIVE).is_empty():
			for doctrine in ["devastator", "tactical", "assault"]:
				result.append({"label": "Gladius Adaptive Strategy: %s / %s (%d CP, replaces doctrine)" % [s.squads[squad].name, doctrine, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": doctrine})
		if error(s, player, squad, ULTRAMARIAN_ADAPTIVITY).is_empty():
			for doctrine: String in Doctrines.ORDER:
				result.append({"label": "Blade of Ultramar Ultramarian Adaptivity: %s / %s (%d CP)" % [s.squads[squad].name, doctrine, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": doctrine, "stratagem": ULTRAMARIAN_ADAPTIVITY})
		if error(s, player, squad, LIONS_WILL).is_empty(): result.append({"label": "Wrath of the Rock Lion's Will: %s gains +1 OC until end of turn (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": LIONS_WILL})
		if error(s, player, squad, FOR_THE_EMPEROR).is_empty(): result.append({"label": "For the Emperor!: %s gains +1 OC until end of turn (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": FOR_THE_EMPEROR})
		if error(s, player, squad, TACTICAL_MASTERY).is_empty():
			for doctrine: String in Doctrines.ORDER:
				result.append({"label": "Wrath of the Rock Tactical Mastery: %s / %s (%d CP)" % [s.squads[squad].name, doctrine, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": doctrine, "stratagem": TACTICAL_MASTERY})
		var gravis_rule := gravis_annihilating_rule(s, player)
		if not gravis_rule.is_empty() and error(s, player, squad, gravis_rule).is_empty():
			result.append({"label": "Annihilating Force: %s gains Lethal Hits for this phase (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": gravis_rule})
		if error(s, player, squad, TERMINATOR_MERCILESS_VETERANS).is_empty():
			var merciless_cost := maxi(0, 1 - A.discount(s, player, squad))
			result.append({"label": "Merciless Veterans: %s gains Lethal Hits and Sustained Hits 1 for ranged attacks (%d CP)" % [s.squads[squad].name, merciless_cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TERMINATOR_MERCILESS_VETERANS})
		if error(s, player, squad, MEDUSA_UNBOWED_CONVICTION).is_empty():
			result.append({"label": "Medusa's Wrath Unbowed Conviction: %s ignores BS/WS, Hit and Wound modifiers until your next Command phase (1 CP)" % str(s.squads[squad].get("name", "Astartes unit")), "action": "detachment-stratagem", "model": -1, "target": squad, "value": MEDUSA_UNBOWED_CONVICTION})
		if error(s, player, squad, MEDUSA_ANCIENT_FURY).is_empty():
			result.append({"label": "Medusa's Wrath Ancient Fury: %s gains +1 M, T, Ld, OC and Hit rolls until your next Command phase (1 CP)" % str(s.squads[squad].get("name", "Dreadnought")), "action": "detachment-stratagem", "model": -1, "target": squad, "value": MEDUSA_ANCIENT_FURY})
		if error(s, player, squad, MEDUSA_POWER_OF_MACHINE_SPIRIT).is_empty():
			var pending_power: Dictionary = s.detachment_stratagems.medusa_power_pending
			var shooting_mode := "normal shooting" if Morale.at_half_strength(s, squad) else "Snap shooting"
			result.append({"label": "Medusa's Wrath Power of the Machine Spirit: %s shoots %s using %s (1 CP)" % [s.squads[squad].name, s.squads[int(pending_power.attacker)].name, shooting_mode], "action": "detachment-stratagem", "model": -1, "target": squad, "value": MEDUSA_POWER_OF_MACHINE_SPIRIT})
		if error(s, player, squad, GRAVIS_LINEBREAKER_PURGATION_PUSH).is_empty():
			var purgation_cost := maxi(0, 1 - A.discount(s, player, squad))
			result.append({"label": "Gravis Linebreaker Purgation Push: move %s up to 5 inches and end within objective range; no Charge or embark this turn (%d CP)" % [s.squads[squad].name, purgation_cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": GRAVIS_LINEBREAKER_PURGATION_PUSH})
		if squad in stand_squads:
			for objective_index: int in stand_unyielding_objectives(s, squad):
				if error(s, player, squad, GRAVIS_SIEGE_STAND_UNYIELDING, -1, objective_index).is_empty():
					var marker_name := str(s.get("mission", {}).get("objectives", [])[objective_index].get("name", "Objective %d" % (objective_index + 1)))
					var cost := maxi(0, 1 - A.discount(s, player, squad))
					result.append({"label": "Stand Unyielding: %s secures %s (%d CP)" % [s.squads[squad].name, marker_name, cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": GRAVIS_SIEGE_STAND_UNYIELDING, "details": {"objective": objective_index}})
		if squad in gauntlet_storm_squads:
			for objective_index: int in gauntlet_storm_and_secure_objectives(s, squad):
				if error(s, player, squad, GAUNTLET_STORM_AND_SECURE, -1, objective_index).is_empty():
					var marker_name := str(s.get("mission", {}).get("objectives", [])[objective_index].get("name", "Objective %d" % (objective_index + 1)))
					var cost := maxi(0, 1 - A.discount(s, player, squad))
					result.append({"label": "Gauntlet Storm and Secure: %s secures %s (%d CP)" % [s.squads[squad].name, marker_name, cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": GAUNTLET_STORM_AND_SECURE, "details": {"objective": objective_index}})
		if error(s, player, squad, INESCAPABLE_JUSTICE).is_empty(): result.append({"label": "Wrath of the Rock Inescapable Justice: %s gains Precision in melee (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": INESCAPABLE_JUSTICE})
		if error(s, player, squad, RELICS_OF_THE_DARK_AGE).is_empty(): result.append({"label": "Wrath of the Rock Relics of the Dark Age: %s gains +2 ranged Strength (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": RELICS_OF_THE_DARK_AGE})
		if error(s, player, squad, STORM).is_empty(): result.append({"label": "Gladius Storm of Devastation: %s (ranged Ignores Cover; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM})
		if error(s, player, squad, ULTRAMARINES_EXEMPLARY_VIGILANCE).is_empty(): result.append({"label": "Blade of Ultramar Exemplary Vigilance: %s (ranged Ignores Cover; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": ULTRAMARINES_EXEMPLARY_VIGILANCE})
		if error(s, player, squad, STORM_OF_FIRE).is_empty():
			var bonus_text := "Ignores Cover and +1 AP" if Doctrines.has_doctrine(s, squad, "devastator") else "Ignores Cover"
			result.append({"label": "Devastator Brethren Storm of Fire: %s (%s; %d CP)" % [s.squads[squad].name, bonus_text, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM_OF_FIRE})
		if error(s, player, squad, HAIL_OF_VENGEANCE).is_empty():
			var pending_hail_choice: Dictionary = s.detachment_stratagems.hail_of_vengeance_pending
			result.append({"label": "Devastator Brethren Hail of Vengeance: %s shoots %s (2 CP)" % [s.squads[squad].name, s.squads[int(pending_hail_choice.attacker)].name], "action": "detachment-stratagem", "model": -1, "target": squad, "value": HAIL_OF_VENGEANCE})
		if error(s, player, squad, STORM_OF_VENGEANCE).is_empty():
			var storm_pending: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {})
			result.append({"label": "Storm of Vengeance: %s shoots %s" % [s.squads[squad].name, s.squads[int(storm_pending.attacker)].name], "action": "detachment-stratagem", "model": -1, "target": squad, "value": STORM_OF_VENGEANCE})
		var might_rule := ULTRAMARINES_COURAGE if blade_ultramar_enabled(s, player) else MIGHT
		if error(s, player, squad, might_rule).is_empty():
			var might_name := "Courage and Honour!" if might_rule == ULTRAMARINES_COURAGE else "Gladius Might of Angels"
			result.append({"label": "%s: %s (melee Lance; %d CP)" % [might_name, s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": might_rule})
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
		var suppression_pending: Dictionary = s.detachment_stratagems.get("gravis_suppression_pending", {}).get(squad, {})
		for enemy: int in suppression_pending.get("targets", []):
			if error(s, player, squad, GRAVIS_SIEGE_SUPPRESSION_VOLLEYS, -1, -1, -1, enemy).is_empty():
				result.append({"label": "Gravis Siege Suppression Volleys: test %s at -1 (%d CP)" % [s.squads[enemy].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "enemy_target": enemy, "value": GRAVIS_SIEGE_SUPPRESSION_VOLLEYS, "details": {"enemy_target": enemy}})
		if error(s, player, squad, HUNTERS_INSTINCTS).is_empty(): result.append({"label": "Spearpoint Hunter's Instincts: %s (Normal Move up to D3+3 inches; 1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": HUNTERS_INSTINCTS})
		if error(s, player, squad, ULTRAMARIAN_PRACTICAL_TACTICS).is_empty(): result.append({"label": "Blade of Ultramar Practical Tactics: %s (Normal Move up to D3+3 inches; %d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": ULTRAMARIAN_PRACTICAL_TACTICS})
		if error(s, player, squad, PHOBOS_TRANSHUMAN_REACTIONS).is_empty():
			var reaction_distance := "6 inches (Tactical Doctrine)" if Doctrines.has_doctrine(s, squad, "tactical") else "D6 inches"
			result.append({"label": "Phobos Shock Force Transhuman Reactions: %s (Normal Move up to %s; %d CP)" % [s.squads[squad].name, reaction_distance, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": PHOBOS_TRANSHUMAN_REACTIONS})
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
		if error(s, player, squad, KNIGHTS_OF_IRON).is_empty(): result.append({"label": "Wrath of the Rock Knights of Iron: %s gains Mobile (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": KNIGHTS_OF_IRON})
		if error(s, player, squad, IRONSTORM_MIGHT).is_empty(): result.append({"label": "Ironstorm Might of the Machine Spirit: %s ignores Move/BS/Hit/Wound modifiers until your next Command phase (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_MIGHT})
		if error(s, player, squad, IRONSTORM_HEADHUNTER).is_empty(): result.append({"label": "Ironstorm Headhunter Doctrine: %s gains Lethal Hits against Monster/Vehicle targets this phase (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": IRONSTORM_HEADHUNTER})
		if error(s, player, squad, FLAWLESS_RIDERS).is_empty(): result.append({"label": "Spearpoint Flawless Riders: %s gains Mobile (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": FLAWLESS_RIDERS})
		if error(s, player, squad, WITHDRAW_AND_REGROUP).is_empty(): result.append({"label": "Spearpoint Withdraw and Regroup: place %s in Strategic Reserves (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": WITHDRAW_AND_REGROUP})
		if error(s, player, squad, TERMINATOR_GUNSHIP_EXTRACTION).is_empty(): result.append({"label": "Gunship Extraction: place %s in Strategic Reserves (1 CP)" % s.squads[squad].name, "action": "detachment-stratagem", "model": -1, "target": squad, "value": TERMINATOR_GUNSHIP_EXTRACTION})
		if error(s, player, squad, PHOBOS_SHADOW_TACTICAL_WITHDRAWAL).is_empty(): result.append({"label": "Tactical Withdrawal: place %s in Strategic Reserves (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": PHOBOS_SHADOW_TACTICAL_WITHDRAWAL})
		if error(s, player, squad, PHOBOS_SHADOW_MORTIS_SNARES).is_empty():
			var marker_names := PackedStringArray()
			for objective_index: int in phobos_mortis_snares_objectives(s, squad):
				marker_names.append(str(s.get("mission", {}).get("objectives", [])[objective_index].get("name", "Objective %d" % (objective_index + 1))))
			result.append({"label": "Mortis Snares: trap %s (%s) (%d CP)" % [str(s.squads[squad].get("name", "Phobos unit")), ", ".join(marker_names), maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": PHOBOS_SHADOW_MORTIS_SNARES})
		if error(s, player, squad, UNDYING).is_empty(): result.append({"label": "Undying Legions: %s (Reanimation D3%s; %d CP)" % [s.squads[squad].name, "+1 if led" if led(s, squad) else "", maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": UNDYING})
		if error(s, player, squad, VENGEFUL).is_empty(): result.append({"label": "Vengeful Stars: %s shoots the destroying unit (%d CP)" % [s.squads[squad].name, maxi(0, 1 - A.discount(s, player, squad))], "action": "detachment-stratagem", "model": -1, "target": squad, "value": VENGEFUL})
		for record: Dictionary in s.detachment_stratagems.get("destroyed", []):
			if int(record.get("owner", -1)) != player or record.get("phase_key", "") != phase_key(s): continue
			if error(s, player, int(record.squad), ETERNAL, int(record.model)).is_empty():
				result.append({"label": "Eternal Revenant: return model %d (%d CP, half wounds, unattached)" % [int(record.model), maxi(0, 1 - A.discount(s, player, int(record.squad)))], "action": "detachment-stratagem", "model": int(record.model), "target": int(record.squad), "value": ETERNAL})
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("player", -1)) == player:
		var reaction_name := "Storm of Vengeance" if str(vengeful.get("source", "")) == STORM_OF_VENGEANCE else "Vengeful Stars"
		result.append({"label": "Decline %s shooting" % reaction_name, "action": "vengeful-pass", "model": -1, "target": int(vengeful.squad), "value": ""})
	var pending_hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	if pending_hail.get("phase_key", "") == phase_key(s) and int(pending_hail.get("player", -1)) == player:
		result.append({"label": "Decline Hail of Vengeance shooting", "action": "vengeful-pass", "model": -1, "target": -1, "value": ""})
	var pending_storm: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {})
	if pending_storm.get("phase_key", "") == phase_key(s) and int(pending_storm.get("player", -1)) == player:
		result.append({"label": "Decline Storm of Vengeance", "action": "vengeful-pass", "model": -1, "target": -1, "value": ""})
	var medusa_power_pending: Dictionary = s.detachment_stratagems.get("medusa_power_pending", {})
	if medusa_power_pending.get("phase_key", "") == phase_key(s) and int(medusa_power_pending.get("player", -1)) == player:
		result.append({"label": "Decline Power of the Machine Spirit", "action": "medusa-power-pass", "model": -1, "target": -1, "value": ""})
	return result

static func transhuman_swiftness_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if not enabled(s) or window.get("kind", "") != "counter" or window.get("owners", []) != [player]: return result
	for squad: int in s.squads:
		if error(s, player, squad, TRANSHUMAN_SWIFTNESS).is_empty():
			var cost := maxi(0, 1 - A.discount(s, player, squad))
			result.append({"label": "Transhuman Swiftness: %s gains Fights First and must fight next (%d CP)" % [str(s.squads[squad].get("name", "Tacticus unit")), cost], "action": "detachment-stratagem", "model": -1, "target": squad, "value": TRANSHUMAN_SWIFTNESS})
	return result

static func rule_of(value: String) -> String:
	if value in ["devastator", "tactical", "assault"]: return ADAPTIVE
	if value == FIRESTORM_RELENTLESS_ASSAULT: return RELENTLESS_ASSAULT
	if value == ASSAULT_ARMOUR: return ARMOUR
	if value == TACTICAL_ARMOUR: return ARMOUR
	if value == DEVASTATOR_ARMOUR: return ARMOUR
	if value == ULTRAMARINES_ARMOUR: return ARMOUR
	if value == ULTRAMARINES_COURAGE: return MIGHT
	if value == ULTRAMARINES_EXEMPLARY_VIGILANCE: return STORM
	if value == ULTRAMARIAN_ADAPTIVITY: return ADAPTIVE
	if value == ULTRAMARIAN_PRACTICAL_TACTICS: return HUNTERS_INSTINCTS
	if value == DUTY_IN_DEATH: return WORTHY
	if value == INNER_CIRCLE_DUTY_UNTO_DEATH: return WORTHY
	return value

static func apply(s: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var source_rule := str(selected.get("stratagem", selected.value))
	var rule := rule_of(source_rule)
	var details_value: Variant = selected.get("details", {})
	if typeof(details_value) != TYPE_DICTIONARY: return {"error": "Invalid detachment stratagem choice details."}
	if rule == VOW_PIOUS_ENMITY and str(selected.get("mode", "")) not in ["hit-ones", "monster-vehicle-ones"]: return {"error": "Choose one of the available Pious Enmity effects."}
	var objective := int(details_value.get("objective", -1)) if rule in [IN_SACRIFICE, GRAVIS_SIEGE_STAND_UNYIELDING, GAUNTLET_STORM_AND_SECURE] else -1
	var enemy_squad := int(details_value.get("enemy_squad", -1)) if rule in [GRAVIS_LINEBREAKER_ARMOURED_IMPACT, INNER_CIRCLE_WRATH_OF_THE_LION] else -1
	var suppression_target := int(selected.get("enemy_target", details_value.get("enemy_target", -1))) if rule == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS else -1
	var failure := error(s, player, selected.target, source_rule, selected.model, objective, enemy_squad, suppression_target)
	if not failure.is_empty(): return {"error": failure}
	if rule == TACTICAL_FOCUS and not tactical_focus_roll(s, player, int(selected.target)).is_empty(): return {"error": "Tactical Focus has already been spent; resume its saved consolidation move."}
	if rule == STORM_OF_VENGEANCE:
		var pending_storm: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {})
		var remaining_squads: Array = pending_storm.get("squads", []).duplicate()
		remaining_squads.erase(int(selected.target))
		var used: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_used", {}).duplicate(true)
		used[str(selected.target)] = int(s.turn)
		s.detachment_stratagems.storm_of_vengeance_used = used
		s.detachment_stratagems.storm_of_vengeance_pending = {}
		s.detachment_stratagems.vengeful = {"player": player, "squad": int(selected.target), "attacker": int(pending_storm.attacker), "phase_key": phase_key(s), "source": STORM_OF_VENGEANCE, "remaining_squads": remaining_squads}
		return {"error": "", "message": "Storm of Vengeance: %s may shoot the enemy unit that just destroyed a nearby Dark Angels unit." % str(s.squads[int(selected.target)].get("name", "Land Speeder Vengeance"))}
	if rule in [ADAPTIVE, TACTICAL_MASTERY] and selected.value not in Doctrines.ORDER: return {"error": "Invalid doctrine."}
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
	if rule in [TACTICS, HUNTERS_INSTINCTS, MASTERFUL_TACTICS, PHOBOS_TRANSHUMAN_REACTIONS, WE_ARE_VENGEANCE]:
		if rule == WE_ARE_VENGEANCE:
			var rolled_move := RandomStat.roll("D3+3", roller)
			if not rolled_move.get("error", "").is_empty(): return rolled_move
			inches = int(rolled_move.value)
		elif rule in [MASTERFUL_TACTICS, PHOBOS_TRANSHUMAN_REACTIONS] and Doctrines.has_doctrine(s, int(selected.target), "tactical"):
			inches = 6
		else:
			var movement_name := "Practical Tactics" if source_rule == ULTRAMARIAN_PRACTICAL_TACTICS else "Transhuman Reactions" if rule == PHOBOS_TRANSHUMAN_REACTIONS else "Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "Masterful Tactics" if rule == MASTERFUL_TACTICS else "Responsive Tactics"
			if not roller.is_valid(): return {"error": "%s requires the host's die." % movement_name}
			var rolled: Variant = roller.call()
			var maximum := 3 if rule == HUNTERS_INSTINCTS else 6
			if not rolled is int or rolled < 1 or rolled > maximum: return {"error": "%s die result is outside its legal range." % ("Practical Tactics" if source_rule == ULTRAMARIAN_PRACTICAL_TACTICS else "Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "D6" if rule in [MASTERFUL_TACTICS, PHOBOS_TRANSHUMAN_REACTIONS] else "Responsive Tactics")}
			inches = int(rolled) + 3 if rule == HUNTERS_INSTINCTS else int(rolled)
	var terror_targets: Array = adamantine_targets(s, int(selected.target)) if rule == ADAMANTINE_TERROR else []
	var stratagem_cost := 2 if rule in [HAIL_OF_VENGEANCE, TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE] else 1
	s.cp[player] -= maxi(0, stratagem_cost - A.discount(s, player, selected.target))
	A.consume_discount(s, player, selected.target)
	var used_rule := source_rule if source_rule in [ASSAULT_ARMOUR, TACTICAL_ARMOUR, DEVASTATOR_ARMOUR, ULTRAMARINES_ARMOUR, ULTRAMARINES_COURAGE, ULTRAMARINES_EXEMPLARY_VIGILANCE, ULTRAMARIAN_ADAPTIVITY, ULTRAMARIAN_PRACTICAL_TACTICS, DUTY_IN_DEATH, INNER_CIRCLE_DUTY_UNTO_DEATH, HAIL_OF_VENGEANCE, STORM_OF_FIRE, FIRESTORM_RELENTLESS_ASSAULT] else rule
	s.stratagems.uses.append({"player": player, "squad": selected.target, "stratagem": used_rule, "phase_key": phase_key(s), "turn": s.turn})
	if rule in [ADAPTIVE, TACTICAL_MASTERY]: s.unit_abilities.doctrines[selected.target] = {"doctrine": selected.value}
	elif rule == LIONS_WILL: s.detachment_stratagems.lion_will[selected.target] = {"turn": int(s.turn), "owner": player}
	elif rule == FOR_THE_EMPEROR: s.detachment_stratagems.for_the_emperor[selected.target] = {"turn": int(s.turn), "owner": player}
	elif rule == INESCAPABLE_JUSTICE: s.detachment_stratagems.inescapable[selected.target] = {"phase_key": phase_key(s)}
	elif rule == RELICS_OF_THE_DARK_AGE: s.detachment_stratagems.relics[selected.target] = {"phase_key": phase_key(s)}
	elif rule == STORM: s.detachment_stratagems.storm[selected.target] = {"phase_key": phase_key(s), "source": source_rule}
	elif rule == STORM_OF_FIRE: s.detachment_stratagems.storm[selected.target] = {"phase_key": phase_key(s), "source": STORM_OF_FIRE, "devastator_bonus": Doctrines.has_doctrine(s, int(selected.target), "devastator")}
	elif rule == ARMOUR:
		var armour_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		s.detachment_stratagems.armour[selected.target] = {"phase_key": phase_key(s), "attacker": int(armour_window.get("attacker_squad", -1))}
	elif rule == ULTRAMARINES_TACTICAL_FORESIGHT:
		var foresight_window: Dictionary = s.get("unit_abilities", {}).get("window", {})
		if not s.detachment_stratagems.has("tactical_foresight"): s.detachment_stratagems.tactical_foresight = {}
		s.detachment_stratagems.tactical_foresight[selected.target] = {"phase_key": phase_key(s), "attacker": int(foresight_window.get("attacker_squad", -1))}
		return {"error": "", "message": "Tactical Foresight: attacks by %s against %s with Strength greater than Toughness have -1 to Wound during this attack sequence." % [str(s.squads[int(foresight_window.get("attacker_squad", -1))].get("name", "the enemy unit")), str(s.squads[int(selected.target)].get("name", "the selected unit"))]}
	elif rule == MIGHT: s.detachment_stratagems.might[selected.target] = {"phase_key": phase_key(s)}
	elif rule == WORTHY:
		s.detachment_stratagems.worthy[selected.target] = {"phase_key": phase_key(s), "source": source_rule}
	elif rule == INNER_CIRCLE_RELIC_TELEPORTARIUM:
		s.squads[selected.target].cannot_charge_until_turn = int(s.turn)
	elif rule == HUNGRY: s.detachment_stratagems.hungry[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == SUDDEN: s.detachment_stratagems.sudden[selected.target] = {"turn": s.turn, "phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == TYRANT: s.detachment_stratagems.tyrant[selected.target] = {"phase_key": phase_key(s), "led": led(s, selected.target)}
	elif rule == SPEAR_THRUST:
		if not s.detachment_stratagems.has("spearpoint_melee"): s.detachment_stratagems.spearpoint_melee = {}
		s.detachment_stratagems.spearpoint_melee[selected.target] = {"phase_key": phase_key(s), "mode": str(selected.mode)}
	elif rule == GENE_WROUGHT_MIGHT:
		if not s.detachment_stratagems.has("gene_wrought"): s.detachment_stratagems.gene_wrought = {}
		s.detachment_stratagems.gene_wrought[selected.target] = {"phase_key": phase_key(s)}
	elif rule == WE_ARE_VENGEANCE:
		s.detachment_stratagems.darkflight_vengeance_pending = {}
		var movement_error := TacticalFluidity.start_we_are_vengeance(s, player, int(selected.target), inches)
		if not movement_error.is_empty(): return {"error": movement_error}
		return {"error": "", "message": "We Are Vengeance: Normal Move up to %d inches; preview every model and confirm." % inches}
	elif rule in [TACTICS, HUNTERS_INSTINCTS, MASTERFUL_TACTICS, PHOBOS_TRANSHUMAN_REACTIONS]:
		var origins := {}
		for model: int in living(s, selected.target): origins[model] = s.units[model].position
		s.detachment_stratagems.tactics[selected.target] = {"inches": inches, "origins": origins, "phase_key": phase_key(s), "source": source_rule}
		var reaction_window: Dictionary = s.get("unit_abilities", {}).get("window", {}).duplicate(true)
		var trigger := int(reaction_window.get("squad", s.detachment_stratagems.get("last_move", {}).get("squad", -1))) if reaction_window.get("kind", "") == MOVEMENT_REACTION_WINDOW else int(s.detachment_stratagems.get("last_move", {}).get("squad", -1))
		s.unit_abilities.window = {"kind": "tactics", "owners": [player], "squad": selected.target, "positions": {}, "source": source_rule,
			"trigger": trigger, "resume_window": reaction_window}
		var move_name := "Practical Tactics" if source_rule == ULTRAMARIAN_PRACTICAL_TACTICS else "Transhuman Reactions" if rule == PHOBOS_TRANSHUMAN_REACTIONS else "Hunter's Instincts" if rule == HUNTERS_INSTINCTS else "Masterful Tactics" if rule == MASTERFUL_TACTICS else "Responsive Tactics"
		return {"error": "", "message": "%s: Normal Move up to %d inches; preview every model and confirm." % [move_name, inches]}
	elif rule == DOMINATION_FIRE:
		var enemy_target := int(selected.get("enemy_target", -1))
		var pending: Dictionary = s.detachment_stratagems.domination_pending.get(selected.target, {})
		if enemy_target not in pending.get("targets", []): return {"error": "Choose an enemy unit hit by this unit's attack."}
		s.detachment_stratagems.suppressed[enemy_target] = {"owner": player, "turn": s.turn, "source": DOMINATION_FIRE}
		s.detachment_stratagems.domination_pending.erase(selected.target)
	elif rule == GRAVIS_SIEGE_SUPPRESSION_VOLLEYS:
		var pending: Dictionary = s.detachment_stratagems.get("gravis_suppression_pending", {}).get(selected.target, {})
		if suppression_target not in pending.get("targets", []): return {"error": "Choose an enemy unit hit by this GRAVIS unit's attacks."}
		s.detachment_stratagems.gravis_suppression_pending.erase(selected.target)
		s.detachment_stratagems.adamantine_pending = {"owner": player, "source": GRAVIS_SIEGE_SUPPRESSION_VOLLEYS, "source_squad": int(selected.target), "phase_key": phase_key(s), "targets": [suppression_target], "results": []}
		return _pump_adamantine(s, roller)
	elif rule == UNDYING:
		var victims: Array = s.detachment_stratagems.after.get("victims", [])
		victims.erase(selected.target)
		s.detachment_stratagems.after.victims = victims
		s.detachment_stratagems.after.undying_closed = true
		return {"error": "", "undying": selected.target, "led": led(s, selected.target)}
	elif rule == VENGEFUL:
		s.detachment_stratagems.vengeful = {"player": player, "squad": selected.target, "attacker": int(s.detachment_stratagems.after.attacker), "phase_key": phase_key(s)}
	elif rule == MEDUSA_POWER_OF_MACHINE_SPIRIT:
		var pending_power: Dictionary = s.detachment_stratagems.get("medusa_power_pending", {})
		s.detachment_stratagems.medusa_power_reactive = {"player": player, "squad": int(selected.target), "attacker": int(pending_power.attacker), "phase_key": phase_key(s)}
		s.detachment_stratagems.medusa_power_pending = {}
	elif rule == HAIL_OF_VENGEANCE:
		var pending_hail: Dictionary = s.detachment_stratagems.hail_of_vengeance_pending
		s.detachment_stratagems.hail_of_vengeance = {"player": player, "squad": selected.target, "attacker": int(pending_hail.attacker), "phase_key": phase_key(s)}
		s.detachment_stratagems.hail_of_vengeance_pending = {}
	elif rule == MERCY_IS_WEAKNESS: s.detachment_stratagems.mercy[selected.target] = {"phase_key": phase_key(s), "mode": str(selected.mode)}
	elif rule in [GRAVIS_LINEBREAKER_ANNIHILATING_FORCE, GRAVIS_SIEGE_ANNIHILATING_FORCE]:
		if not s.detachment_stratagems.has("gravis_annihilating"): s.detachment_stratagems.gravis_annihilating = {}
		s.detachment_stratagems.gravis_annihilating[selected.target] = {"phase_key": phase_key(s), "source": rule}
	elif rule == TERMINATOR_MERCILESS_VETERANS:
		if not s.detachment_stratagems.has("terminator_merciless"): s.detachment_stratagems.terminator_merciless = {}
		s.detachment_stratagems.terminator_merciless[selected.target] = {"phase_key": phase_key(s)}
	elif rule in [PHOBOS_STRIKE_FROM_SHADOWS, PHOBOS_SHADOW_STRIKE_FROM_SHADOWS]:
		if not s.detachment_stratagems.has("phobos_strike"): s.detachment_stratagems.phobos_strike = {}
		s.detachment_stratagems.phobos_strike[selected.target] = {"phase_key": phase_key(s)}
	elif rule == TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE: pass
	elif rule == TACTICAL_FOCUS: pass
	elif rule == GAUNTLET_DUTY_IS_NEVER_DONE: pass
	elif rule == GAUNTLET_AGGRESSIVE_DISEMBARKATION: pass
	elif rule == RELENTLESS_ASSAULT:
		if not s.detachment_stratagems.has("relentless_assault"): s.detachment_stratagems.relentless_assault = {}
		s.detachment_stratagems.relentless_assault[selected.target] = {"phase_key": phase_key(s), "source": source_rule}
	elif rule == FIRESTORM_POINT_BLANK_BRUTALITY:
		if not s.detachment_stratagems.has("point_blank_brutality"): s.detachment_stratagems.point_blank_brutality = {}
		s.detachment_stratagems.point_blank_brutality[selected.target] = {"phase_key": phase_key(s), "source": source_rule}
	elif rule == TRANSHUMAN_SWIFTNESS:
		s.squads[selected.target].fights_first = true
		if str(s.get("fight_step", "")) == "consolidation_reaction":
			var reaction_queue: Array = s.get("reaction_queue", []).duplicate()
			if selected.target not in reaction_queue: reaction_queue.append(selected.target)
			s.reaction_queue = reaction_queue
		s.fight_selected = int(selected.target)
		s.fight_actor = player
		s.unit_abilities.window = {}
		return {"error": "", "message": "Transhuman Swiftness: %s must be selected to fight next." % str(s.squads[selected.target].get("name", "Tacticus unit"))}
	elif rule == GRAVIS_LINEBREAKER_ARMOURED_IMPACT:
		return {"error": "", "gravis_armoured_impact": enemy_squad}
	elif rule == INNER_CIRCLE_WRATH_OF_THE_LION:
		return {"error": "", "wrath_of_the_lion": enemy_squad}
	elif rule == GRAVIS_LINEBREAKER_PURGATION_PUSH:
		var movement_error := TacticalFluidity.start_purgation_push(s, player, int(selected.target))
		if not movement_error.is_empty(): return {"error": movement_error}
		return {"error": "", "message": "Purgation Push: Normal Move up to 5 inches; the unit must end within range of an objective."}
	elif rule == ADAMANTINE_TERROR:
		s.detachment_stratagems.adamantine_pending = {"owner": player, "source_squad": int(selected.target), "phase_key": phase_key(s), "targets": terror_targets.duplicate(), "results": []}
		return _pump_adamantine(s, roller)
	elif rule == IRONSTORM_MIGHT:
		s.detachment_stratagems.might_machine_spirit[selected.target] = {"owner": player, "expires_turn": int(s.turn) + 2}
	elif rule == IRONSTORM_HEADHUNTER:
		s.detachment_stratagems.headhunter[selected.target] = {"phase_key": phase_key(s)}
	elif rule == IRONSTORM_LAYERED_CERAMITE:
		s.detachment_stratagems.layered_ceramite[selected.target] = {"phase_key": phase_key(s)}
	elif rule == MEDUSA_SPIRITS_OF_IRON:
		s.detachment_stratagems.spirits_of_iron[selected.target] = {"phase_key": phase_key(s)}
	elif rule == MEDUSA_METHODICAL_BRUTALITY:
		if not s.detachment_stratagems.has("methodical_brutality"): s.detachment_stratagems.methodical_brutality = {}
		s.detachment_stratagems.methodical_brutality[selected.target] = {"phase_key": phase_key(s)}
	elif rule == VOW_PIOUS_ENMITY:
		if not s.detachment_stratagems.has("pious_enmity"): s.detachment_stratagems.pious_enmity = {}
		s.detachment_stratagems.pious_enmity[selected.target] = {"phase_key": phase_key(s), "mode": str(selected.get("mode", ""))}
		var mode_text := "melee Hit rolls of 1" if selected.mode == "hit-ones" else "melee Hit and Wound rolls of 1 against MONSTER/VEHICLE units"
		return {"error": "", "message": "Pious Enmity: %s can re-roll %s for this Fight phase." % [str(s.squads[int(selected.target)].get("name", "The selected unit")), mode_text]}
	elif rule == MEDUSA_UNBOWED_CONVICTION:
		if not s.detachment_stratagems.has("unbowed_conviction"): s.detachment_stratagems.unbowed_conviction = {}
		s.detachment_stratagems.unbowed_conviction[selected.target] = {"owner": player, "expires_turn": int(s.turn) + 2}
		return {"error": "", "message": "Unbowed Conviction: %s ignores BS/WS, Hit and Wound modifiers until the start of your next Command phase." % str(s.squads[int(selected.target)].get("name", "The selected unit"))}
	elif rule == MEDUSA_ANCIENT_FURY:
		if not s.detachment_stratagems.has("ancient_fury"): s.detachment_stratagems.ancient_fury = {}
		s.detachment_stratagems.ancient_fury[selected.target] = {"owner": player, "expires_turn": int(s.turn) + 2}
		return {"error": "", "message": "Ancient Fury: %s gains +1 M, T, Ld, OC and Hit rolls until the start of your next Command phase." % str(s.squads[int(selected.target)].get("name", "The selected unit"))}
	elif rule == MEDUSA_VENGEFUL_ANIMUS:
		var pending: Dictionary = s.get("pending_deadly_demise", {})
		var forced_squads: Dictionary = pending.get("vengeful_animus_squads", {}).duplicate(true)
		forced_squads[str(selected.target)] = true
		pending.vengeful_animus_squads = forced_squads
	elif rule == SKYBORNE_SURVEILLANCE:
		var marked_targets := darkflight_skyborne_targets(s, player, int(selected.target))
		if not s.detachment_stratagems.has("skyborne_surveillance"): s.detachment_stratagems.skyborne_surveillance = {}
		for enemy: int in marked_targets:
			s.detachment_stratagems.skyborne_surveillance[enemy] = {"phase_key": phase_key(s), "owner": player, "source": int(selected.target)}
		if not s.detachment_stratagems.has("darkflight_skyborne_pending"): s.detachment_stratagems.darkflight_skyborne_pending = {}
		s.detachment_stratagems.darkflight_skyborne_pending = {}
		var marked_text := "%d visible enemy unit(s)" % [marked_targets.size()]
		return {"error": "", "message": "Skyborne Surveillance: %s gain +3 detection until the end of this Shooting phase." % marked_text}
	elif rule == WINGS_OF_SHADOW:
		s.detachment_stratagems.wings_shadow[selected.target] = {"phase_key": phase_key(s), "owner": player}
		return {"error": "", "message": "Wings of Shadow: %s has Stealth for this Shooting phase." % str(s.squads[int(selected.target)].get("name", "The selected unit"))}
	elif rule == IN_SACRIFICE:
		var destroyed_record := _in_sacrifice_record(s, player, int(selected.target), int(selected.model))
		var objectives: Array = s.get("mission", {}).get("objectives", [])
		var secure_error := Objectives.secure_by_stratagem(s, objective, player)
		if not secure_error.is_empty(): return {"error": secure_error}
		_remove_in_sacrifice_record(s, destroyed_record)
		return {"error": "", "message": "In Sacrifice, Victory: %s secures %s." % [str(s.squads[int(selected.target)].get("name", "The destroyed unit")), str(objectives[objective].get("name", "Objective"))]}
	elif rule == GRAVIS_SIEGE_STAND_UNYIELDING:
		var objectives: Array = s.get("mission", {}).get("objectives", [])
		var secure_error := Objectives.secure(s, objective, player)
		if not secure_error.is_empty(): return {"error": secure_error}
		return {"error": "", "message": "Stand Unyielding: %s secures %s." % [str(s.squads[int(selected.target)].get("name", "Gravis unit")), str(objectives[objective].get("name", "Objective"))]}
	elif rule == GAUNTLET_STORM_AND_SECURE:
		var objectives: Array = s.get("mission", {}).get("objectives", [])
		var secure_error := Objectives.secure(s, objective, player)
		if not secure_error.is_empty(): return {"error": secure_error}
		return {"error": "", "message": "Storm and Secure: %s secures %s." % [str(s.squads[int(selected.target)].get("name", "Astartes Transport")), str(objectives[objective].get("name", "Objective"))]}
	elif rule in [UNSTOPPABLE_ADVANCE, KNIGHTS_OF_IRON, FLAWLESS_RIDERS, MOBILE_LETHALITY]:
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
	elif rule == TERMINATOR_GUNSHIP_EXTRACTION:
		var reserve_cost := int(s.squads[selected.target].get("training_cost", 0))
		if reserve_cost <= 0: return {"error": "This Terminator unit has no admitted reserve cost."}
		s.unit_abilities.reserves[selected.target] = {"cost": reserve_cost, "source": TERMINATOR_GUNSHIP_EXTRACTION}
		for model: int in living(s, selected.target): s.units[model].on_battlefield = false
		s.deployment.order.erase(selected.target)
	elif rule == PHOBOS_SHADOW_TACTICAL_WITHDRAWAL:
		var reserve_cost := int(s.squads[selected.target].get("training_cost", 0))
		if reserve_cost <= 0: return {"error": "This Phobos/Scout unit has no admitted reserve cost."}
		s.unit_abilities.reserves[selected.target] = {"cost": reserve_cost, "source": PHOBOS_SHADOW_TACTICAL_WITHDRAWAL}
		for model: int in living(s, selected.target): s.units[model].on_battlefield = false
		s.deployment.order.erase(selected.target)
	elif rule == PHOBOS_SHADOW_MORTIS_SNARES:
		var objectives_to_snare := phobos_mortis_snares_objectives(s, int(selected.target))
		if objectives_to_snare.is_empty(): return {"error": "The selected unit no longer controls an objective."}
		var snares: Dictionary = s.detachment_stratagems.get("mortis_snares", {}).duplicate(true)
		var marker_names := PackedStringArray()
		var objectives: Array = s.get("mission", {}).get("objectives", [])
		for objective_index: int in objectives_to_snare:
			snares[str(objective_index)] = {"owner": player, "source_squad": int(selected.target), "armed_turn": int(s.turn), "armed_phase_key": phase_key(s)}
			marker_names.append(str(objectives[objective_index].get("name", "Objective %d" % (objective_index + 1))))
		s.detachment_stratagems.mortis_snares = snares
		return {"error": "", "message": "Mortis Snares armed on %s." % ", ".join(marker_names)}
	elif rule == ETERNAL:
		var destroyed := _destroyed_record(s, player, selected.target, selected.model)
		s.detachment_stratagems.revived[destroyed.model] = true
		var resume_window: Dictionary = s.unit_abilities.get("window", {}).duplicate(true)
		s.unit_abilities.window = {"kind": "eternal", "owners": [player], "model": destroyed.model, "squad": destroyed.squad, "origin": destroyed.position, "max_wounds": destroyed.max_wounds, "positions": {}, "resume_window": resume_window}
	else: return {"error": "Unknown detachment stratagem."}
	return {"error": ""}

static func hungry_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.hungry.get(squad, {}).get("phase_key", "") == phase_key(s)

static func storm_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.detachment_stratagems.storm.get(squad, {}).get("phase_key", "") == phase_key(s)

static func inescapable_justice_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.squads.has(squad) and wrath_of_the_rock_enabled(s, int(s.squads[squad].get("owner", -1))) and s.detachment_stratagems.get("inescapable", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func relics_of_the_dark_age_active(s: Dictionary, squad: int) -> bool:
	return enabled(s) and s.squads.has(squad) and wrath_of_the_rock_enabled(s, int(s.squads[squad].get("owner", -1))) and s.detachment_stratagems.get("relics", {}).get(squad, {}).get("phase_key", "") == phase_key(s)

static func suppression_hit_modifier(s: Dictionary, squad: int) -> int:
	if not enabled(s) or not s.squads.has(squad) or Doctrines.detachment_for(s, int(s.squads[squad].get("owner", -1))) != "tactical-brethren" or living(s, squad).is_empty(): return 0
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
	if gauntlet_assailed(s, squad, target_squad):
		copy = copy.duplicate(true)
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if methodical_brutality_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	var gravis_record: Dictionary = s.get("detachment_stratagems", {}).get("gravis_annihilating", {}).get(squad, {})
	if enabled(s) and s.squads.has(squad) and gravis_record.get("phase_key", "") == phase_key(s) and gravis_annihilating_rule(s, int(s.squads[squad].get("owner", -1))) == str(gravis_record.get("source", "")):
		copy = copy.duplicate(true)
		copy.keywords["lethal-hits"] = true
	if not melee and terminator_merciless_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["lethal-hits"] = true
		copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	if phobos_strike_active(s, squad):
		copy = copy.duplicate(true)
		copy.strength = int(copy.get("strength", 0)) + 1
		copy.keywords["lethal-hits"] = true
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
	if melee and inescapable_justice_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["precision"] = true
	if not melee and relics_of_the_dark_age_active(s, squad):
		copy = copy.duplicate(true)
		copy.strength = int(copy.get("strength", 0)) + 2
	if not melee and storm_active(s, squad):
		copy = copy.duplicate(true)
		copy.keywords["ignores-cover"] = true
		var storm_record: Dictionary = s.detachment_stratagems.storm.get(squad, {})
		if storm_record.get("source", "") == STORM_OF_FIRE and storm_record.get("devastator_bonus", false): copy.ap = int(copy.ap) - 1
	if not melee and point_blank_brutality_active(s, squad) and not copy.keywords.get("blast", false):
		copy = copy.duplicate(true)
		copy.keywords["close-quarters"] = true
		copy.keywords["ignores-cover"] = true
	if not melee and Registry.enabled(s, IRONSTORM_HEADHUNTER) and s.get("detachment_stratagems", {}).get("headhunter", {}).get(squad, {}).get("phase_key", "") == phase_key(s):
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
	if relentless_assault_active(s, squad) and s.squads.has(target_squad):
		var target_keywords := unit_keywords(s, target_squad)
		copy = copy.duplicate(true)
		if "MONSTER" in target_keywords or "VEHICLE" in target_keywords: copy.keywords["lethal-hits"] = true
		else: copy.keywords["sustained-hits"] = maxi(1, int(copy.keywords.get("sustained-hits", 0)))
	return copy

static func might_ignore_active(s: Dictionary, squad: int) -> bool:
	if not enabled(s) or not Registry.enabled(s, IRONSTORM_MIGHT) or not s.squads.has(squad): return false
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

static func inner_circle_duty_modifier(s: Dictionary, squad: int, destroyed_model: int = -1) -> int:
	if not s.squads.has(squad): return 0
	var player := int(s.squads[squad].get("owner", -1))
	var objective_index := VowedTarget.selected_objective(s, player)
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	if objective_index < 0 or objective_index >= objectives.size() or not objectives[objective_index] is Dictionary: return 0
	var objective: Dictionary = objectives[objective_index]
	var friendly_models := living(s, squad)
	if s.units.has(destroyed_model) and int(s.units[destroyed_model].get("squad", -1)) == squad and s.units[destroyed_model].get("on_battlefield", true) and destroyed_model not in friendly_models:
		friendly_models.append(destroyed_model)
	if friendly_models.is_empty(): return 0
	for enemy_squad: int in s.squads:
		if int(s.squads[enemy_squad].get("owner", -1)) == player: continue
		for enemy_model: int in living(s, enemy_squad):
			if not Objectives.in_range(s.units[enemy_model], objective): continue
			for friendly_model: int in friendly_models:
				if G.within_engagement(s.units[friendly_model], s.units[enemy_model]): return 1
	return 0

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
			return {"error": "", "held": true, "rule": "honour-of-ultramar", "rule_name": "Honour of Ultramar", "roll": honour_roll}
	if not enabled(s): return {"error": "", "held": false}
	if worthy_active(s, unit.squad):
		var worthy: Dictionary = s.detachment_stratagems.worthy.get(unit.squad, {})
		var source_rule := str(worthy.get("source", ""))
		var card_name := "Duty Unto Death" if source_rule == INNER_CIRCLE_DUTY_UNTO_DEATH else "Duty in Death" if source_rule == DUTY_IN_DEATH else "A Worthy Death"
		if not roller.is_valid(): return {"error": "%s requires the host's D6." % card_name}
		var rolled: Variant = roller.call()
		if not rolled is int or rolled < 1 or rolled > 6: return {"error": "%s dice must be 1–6." % card_name}
		var modifier := 0
		if source_rule == DUTY_IN_DEATH and Doctrines.has_doctrine(s, unit.squad, "assault"):
			modifier = 1
		elif source_rule == INNER_CIRCLE_DUTY_UNTO_DEATH:
			modifier = inner_circle_duty_modifier(s, int(unit.squad), model)
		if int(rolled) + modifier >= 4:
			unit.wounds = 1
			unit.lingering = true
			return {"error": "", "held": true, "rule_name": card_name, "roll": rolled, "modifier": modifier}
		record_destroyed(s, model)
		return {"error": "", "held": false, "rule_name": card_name, "roll": rolled, "modifier": modifier}
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

static func open_movement_reaction(s: Dictionary, moved_squad: int) -> bool:
	if not enabled(s) or s.phase != "movement" or not s.squads.has(moved_squad) or int(s.squads[moved_squad].owner) != int(s.active): return false
	var player := 3 - int(s.active)
	var has_reaction := false
	for option: Dictionary in choices(s, player):
		if str(option.get("value", "")) in [TACTICS, MASTERFUL_TACTICS, HUNTERS_INSTINCTS, PHOBOS_TRANSHUMAN_REACTIONS, ULTRAMARIAN_PRACTICAL_TACTICS]:
			has_reaction = true
			break
	if not has_reaction: return false
	var previous: Dictionary = s.get("unit_abilities", {}).get("window", {}).duplicate(true)
	s.unit_abilities.window = {"kind": MOVEMENT_REACTION_WINDOW, "owners": [player], "squad": moved_squad,
		"phase_key": phase_key(s), "resume_window": previous}
	return true

static func movement_reaction_choices(s: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != MOVEMENT_REACTION_WINDOW or window.get("owners", []) != [player] or window.get("phase_key", "") != phase_key(s): return []
	var result: Array[Dictionary] = []
	for option: Dictionary in choices(s, player):
		if str(option.get("value", "")) in [TACTICS, MASTERFUL_TACTICS, HUNTERS_INSTINCTS, PHOBOS_TRANSHUMAN_REACTIONS, ULTRAMARIAN_PRACTICAL_TACTICS]: result.append(option)
	result.append({"label": "Pass post-move reaction", "action": "detachment-movement-pass", "model": -1, "target": int(window.get("squad", -1)), "value": ""})
	return result

static func after_attacks(s: Dictionary, attacker: int, targets: Array, killed: int, prepared: Dictionary = {}, resolved: Dictionary = {}, melee: bool = false) -> void:
	if not enabled(s): return
	if not melee: _record_medusa_power_trigger(s, attacker, prepared)
	if s.squads.has(attacker):
		var owner := int(s.squads[attacker].get("owner", -1))
		if not melee and s.phase == "shooting" and int(s.active) == owner and bool(s.squads[attacker].get("shot", false)):
			if gauntlet_enabled(s, owner) and marine_unit(s, attacker) and "TRANSPORT" in unit_keywords(s, attacker):
				var gauntlet_targets: Array[int] = []
				var gauntlet_batches: Array = prepared.get("batches", [])
				var gauntlet_pools: Array = resolved.get("pools", [])
				for index in range(mini(gauntlet_batches.size(), gauntlet_pools.size())):
					var gauntlet_target := int(gauntlet_batches[index].get("target", -1)) if gauntlet_batches[index] is Dictionary else -1
					if gauntlet_target in gauntlet_targets or int(gauntlet_pools[index].get("hits", 0)) <= 0 or not s.squads.has(gauntlet_target) or int(s.squads[gauntlet_target].get("owner", -1)) == owner: continue
					gauntlet_targets.append(gauntlet_target)
				if not gauntlet_targets.is_empty() and s.detachment_stratagems.get("gauntlet_pending", {}).is_empty():
					s.detachment_stratagems.gauntlet_pending = {"phase_key": phase_key(s), "player": owner, "attacker": attacker, "targets": gauntlet_targets}
			if darkflight_ravenwing_fly_unit(s, owner, attacker):
				if not s.detachment_stratagems.has("darkflight_skyborne_pending"): s.detachment_stratagems.darkflight_skyborne_pending = {}
				s.detachment_stratagems.darkflight_skyborne_pending = {"phase_key": phase_key(s), "player": owner, "squad": attacker}
				if not error(s, owner, attacker, SKYBORNE_SURVEILLANCE).is_empty(): s.detachment_stratagems.darkflight_skyborne_pending = {}
			var eligible_targets: Array[int] = []
			var defender := 3 - owner
			for target_value: Variant in targets:
				if not target_value is int: continue
				var target := int(target_value)
				if target in eligible_targets or not s.squads.has(target) or int(s.squads[target].get("owner", -1)) != defender or living(s, target).is_empty(): continue
				if not darkflight_ravenwing_fly_unit(s, defender, target) or Queue.engaged(s, target): continue
				eligible_targets.append(target)
			if not eligible_targets.is_empty():
				s.detachment_stratagems.darkflight_vengeance_pending = {"phase_key": phase_key(s), "player": defender, "attacker": attacker, "targets": eligible_targets}
		if s.phase == "shooting" and int(s.active) == owner and bool(s.squads[attacker].get("shot", false)) and gravis_suppression_enabled(s, owner) and gravis_unit(s, attacker):
			var suppression_targets: Array[int] = []
			var shot_batches: Array = prepared.get("batches", [])
			var shot_pools: Array = resolved.get("pools", [])
			for index in range(mini(shot_batches.size(), shot_pools.size())):
				var target := int(shot_batches[index].get("target", -1)) if shot_batches[index] is Dictionary else -1
				if target in suppression_targets or int(shot_pools[index].get("hits", 0)) <= 0 or not s.squads.has(target) or int(s.squads[target].get("owner", -1)) == owner or living(s, target).is_empty(): continue
				suppression_targets.append(target)
			if not s.detachment_stratagems.has("gravis_suppression_pending"): s.detachment_stratagems.gravis_suppression_pending = {}
			s.detachment_stratagems.gravis_suppression_pending.erase(attacker)
			if not suppression_targets.is_empty():
				s.detachment_stratagems.gravis_suppression_pending[attacker] = {"owner": owner, "phase_key": phase_key(s), "targets": suppression_targets}
	if s.squads.has(attacker) and Doctrines.detachment_for(s, int(s.squads[attacker].get("owner", -1))) == "tactical-brethren" and "tactical-brethren" in s.detachment_stratagems.get("modes", []) and s.phase == "shooting" and int(s.active) == int(s.squads[attacker].owner):
		var hit_targets: Array[int] = []
		var batches: Array = prepared.get("batches", [])
		var pools: Array = resolved.get("pools", [])
		for index in range(mini(batches.size(), pools.size())):
			var target := int(batches[index].get("target", -1)) if batches[index] is Dictionary else -1
			if target in hit_targets or int(pools[index].get("hits", 0)) <= 0 or not s.squads.has(target) or living(s, target).is_empty(): continue
			hit_targets.append(target)
		if not hit_targets.is_empty(): s.detachment_stratagems.domination_pending[attacker] = {"owner": int(s.squads[attacker].owner), "phase_key": phase_key(s), "targets": hit_targets}
	if s.squads.has(attacker) and not melee and s.phase == "shooting" and int(s.active) == int(s.squads[attacker].get("owner", -1)) and bool(s.squads[attacker].get("shot", false)) and killed > 0:
		var defender := 3 - int(s.squads[attacker].owner)
		var destroyed_dark_angels: Array[int] = []
		for target_value: Variant in targets:
			if not target_value is int: continue
			var target := int(target_value)
			if not s.squads.has(target) or int(s.squads[target].get("owner", -1)) != defender or not living(s, target).is_empty(): continue
			if not _dark_angels_unit(s, defender, target): continue
			if target not in destroyed_dark_angels: destroyed_dark_angels.append(target)
		if not destroyed_dark_angels.is_empty() and not living(s, attacker).is_empty():
			var candidates: Array[int] = []
			var used: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_used", {})
			for vengeance_squad: int in s.squads:
				if int(s.squads[vengeance_squad].get("owner", -1)) != defender or not A.has(s, vengeance_squad, STORM_OF_VENGEANCE): continue
				if int(used.get(str(vengeance_squad), -1)) == int(s.turn): continue
				var near_destroyed_unit := false
				for destroyed_squad: int in destroyed_dark_angels:
					if _unit_within_destroyed_unit(s, vengeance_squad, destroyed_squad, 6.0):
						near_destroyed_unit = true
						break
				if near_destroyed_unit: candidates.append(vengeance_squad)
			if not candidates.is_empty():
				s.detachment_stratagems.storm_of_vengeance_pending = {"phase_key": phase_key(s), "player": defender, "attacker": attacker, "squads": candidates}
	var cleared_armour: Array[int] = []
	for target: int in s.detachment_stratagems.get("armour", {}):
		var armour_record: Dictionary = s.detachment_stratagems.armour[target]
		if int(armour_record.get("attacker", -1)) == attacker: cleared_armour.append(target)
	for target: int in cleared_armour: s.detachment_stratagems.armour.erase(target)
	var cleared_foresight: Array[int] = []
	for target: int in s.detachment_stratagems.get("tactical_foresight", {}):
		var foresight_record: Dictionary = s.detachment_stratagems.tactical_foresight[target]
		if int(foresight_record.get("attacker", -1)) == attacker: cleared_foresight.append(target)
	for target: int in cleared_foresight: s.detachment_stratagems.tactical_foresight.erase(target)
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
	if not victims.is_empty() or not wiped.is_empty(): s.detachment_stratagems.after = {"phase_key": phase_key(s), "attacker": attacker, "victims": victims, "wiped": wiped, "undying_closed": false}
	if not devastator_victims.is_empty(): s.detachment_stratagems.hail_of_vengeance_pending = {"phase_key": phase_key(s), "player": int(s.squads[devastator_victims[0]].owner), "attacker": attacker, "victims": devastator_victims}

static func _record_medusa_power_trigger(s: Dictionary, attacker: int, prepared: Dictionary) -> void:
	if s.phase != "shooting" or not s.squads.has(attacker): return
	var firing_player := int(s.squads[attacker].get("owner", -1))
	if int(s.active) != firing_player or not bool(s.squads[attacker].get("shot", false)): return
	var reacting_player := 3 - firing_player
	if not UnitAbilities.enabled(s) or not medusa_wrath_enabled(s, reacting_player) or not Registry.supported(MEDUSA_POWER_OF_MACHINE_SPIRIT): return
	var eligible_targets: Array[int] = []
	var batches: Array = prepared.get("batches", [])
	for batch_value: Variant in batches:
		if not batch_value is Dictionary: continue
		var batch: Dictionary = batch_value
		var target := int(batch.get("target", -1))
		var context: Variant = batch.get("context", {})
		if not context is Dictionary or not context.get("target_engaged", true): continue
		if not s.squads.has(target) or int(s.squads[target].get("owner", -1)) != reacting_player or living(s, target).is_empty(): continue
		if not marine_unit(s, target) or "VEHICLE" not in unit_keywords(s, target) or target in eligible_targets: continue
		eligible_targets.append(target)
	if not eligible_targets.is_empty():
		s.detachment_stratagems.medusa_power_pending = {"phase_key": phase_key(s), "player": reacting_player, "attacker": attacker, "targets": eligible_targets}

static func _dark_angels_unit(s: Dictionary, player: int, squad: int) -> bool:
	var keywords := unit_keywords(s, squad)
	if "ADEPTUS ASTARTES" not in keywords: return false
	var chapters: Dictionary = s.get("marine_chapters", {})
	if "DARK ANGELS" in keywords or str(chapters.get(player, chapters.get(str(player), ""))) == "DARK ANGELS": return true
	for model: int in s.units:
		if int(s.units[model].get("owner", -1)) == player and "DARK ANGELS" in s.units[model].get("keywords", []): return true
	return false

static func _unit_within_destroyed_unit(s: Dictionary, source_squad: int, destroyed_squad: int, inches: float) -> bool:
	var sources := G.alive(s, source_squad)
	if sources.is_empty(): return false
	for source: int in sources:
		for model: int in s.units:
			if int(s.units[model].get("squad", -1)) != destroyed_squad: continue
			if G.edge(s.units[source], s.units[model]) <= inches + 0.001: return true
	return false

static func supported_reanimation_unit(s: Dictionary, squad: int) -> bool:
	if not s.squads.has(squad) or not Reanimation.enabled(s): return false
	for model: int in s.units:
		if int(s.units[model].get("squad", -1)) == squad and str(s.units[model].get("definition_id", "")).begins_with("40kdc:11e:necrons:"):
			return Reanimation.supported_unit(s, squad)
	return false

static func undying_actor(s: Dictionary) -> int:
	if not enabled(s) or s.phase not in ["shooting", "fight"]: return -1
	if not s.get("unit_abilities", {}).get("window", {}).is_empty() or not s.get("reanimation", {}).get("pending", {}).is_empty(): return -1
	var after: Dictionary = s.get("detachment_stratagems", {}).get("after", {})
	if after.get("phase_key", "") != phase_key(s) or bool(after.get("undying_closed", false)): return -1
	var attacker := int(after.get("attacker", -1))
	if not s.squads.has(attacker): return -1
	var player := 3 - int(s.squads[attacker].get("owner", -1))
	if player not in s.get("awakened_dynasty", {}).get("owners", []): return -1
	for squad_value: Variant in after.get("victims", []):
		if error(s, player, int(squad_value), UNDYING).is_empty(): return player
	return -1

static func record_destroyed(s: Dictionary, model: int) -> void:
	if not enabled(s) or not s.units.has(model): return
	var unit: Dictionary = s.units[model]
	if unit.wounds > 0 or unit.get("lingering", false): return
	var squad := int(unit.get("squad", -1))
	var owner := int(unit.get("owner", -1))
	if s.squads.has(squad) and living(s, squad).is_empty() and wrath_of_the_rock_enabled(s, owner) and _destroyed_deathwing_or_ravenwing_unit(s, squad, model):
		var model_at_destruction := unit.duplicate(true)
		model_at_destruction.wounds = maxi(1, int(unit.get("max_wounds", 1)))
		var within_range: Array[int] = []
		var previously_controlled: Array[int] = []
		var objectives: Array = s.get("mission", {}).get("objectives", [])
		for index in range(objectives.size()):
			var objective: Dictionary = objectives[index]
			if Objectives.in_range(model_at_destruction, objective): within_range.append(index)
			var previous_squads: Variant = objective.get("previous_phase_controlled_squads", [])
			if previous_squads is Array and squad in previous_squads: previously_controlled.append(index)
		if not within_range.is_empty():
			var records: Array = s.detachment_stratagems.get("wrath_destroyed", [])
			var already_recorded := false
			for record: Variant in records:
				if record is Dictionary and int(record.get("squad", -1)) == squad and str(record.get("phase_key", "")) == phase_key(s):
					already_recorded = true
					break
			if not already_recorded:
				records.append({"model": model, "squad": squad, "owner": owner, "phase_key": phase_key(s), "objectives_in_range": within_range, "previously_controlled": previously_controlled})
				s.detachment_stratagems.wrath_destroyed = records
	if not _has_keyword(unit, "CHARACTER") or not _has_keyword(unit, "INFANTRY"): return
	if owner not in s.get("awakened_dynasty", {}).get("owners", []): return
	if s.detachment_stratagems.revived.has(model): return
	for record: Dictionary in s.detachment_stratagems.destroyed:
		if int(record.model) == model and record.phase_key == phase_key(s): return
	s.detachment_stratagems.destroyed.append({"model": model, "squad": squad, "owner": owner, "position": unit.position, "max_wounds": int(unit.get("max_wounds", 1)), "phase_key": phase_key(s)})

static func _destroyed_deathwing_or_ravenwing_unit(s: Dictionary, squad: int, model: int) -> bool:
	if not s.squads.has(squad) or not s.units.has(model): return false
	var unit: Dictionary = s.units[model]
	if not _has_keyword(unit, "ADEPTUS ASTARTES"): return false
	var ravenwing := _has_keyword(unit, "RAVENWING") or _has_keyword(unit, "MOUNTED") or (_has_keyword(unit, "VEHICLE") and _has_keyword(unit, "FLY"))
	var deathwing := _has_keyword(unit, "DEATHWING") or _has_keyword(unit, "TERMINATOR") or _has_keyword(unit, "DREADNOUGHT") or AbilityCatalog.identity(unit) in DEATHWING_CONDITIONAL_IDENTITIES
	return ravenwing or deathwing

static func _in_sacrifice_record(s: Dictionary, player: int, squad: int, model: int) -> Dictionary:
	var raw_records: Variant = s.get("detachment_stratagems", {}).get("wrath_destroyed", [])
	if not raw_records is Array: return {}
	for record_value: Variant in raw_records:
		if not record_value is Dictionary: continue
		var record: Dictionary = record_value
		if int(record.get("owner", -1)) != player or int(record.get("squad", -1)) != squad or int(record.get("model", -1)) != model or str(record.get("phase_key", "")) != phase_key(s): continue
		return record
	return {}

static func _in_sacrifice_objectives(s: Dictionary, record: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	var in_range_value: Variant = record.get("objectives_in_range", [])
	var previous_value: Variant = record.get("previously_controlled", [])
	if not in_range_value is Array or not previous_value is Array: return result
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		# The unit must be near an objective when destroyed, but the marker it
		# secures can be a different one it controlled at the end of the prior phase.
		if index in previous_value or (index in in_range_value and not _enemy_non_aircraft_in_range(s, player, objectives[index])): result.append(index)
	return result

static func _enemy_non_aircraft_in_range(s: Dictionary, player: int, objective: Dictionary) -> bool:
	for model: int in s.get("units", {}):
		var unit: Dictionary = s.units[model]
		if int(unit.get("owner", -1)) == player or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
		if _has_keyword(unit, "AIRCRAFT"): continue
		if Objectives.in_range(unit, objective): return true
	return false

static func _in_sacrifice_reaction_safe(s: Dictionary) -> bool:
	if not enabled(s) or not s.has("stratagems") or s.get("phase", "") not in ["command", "movement", "shooting", "charge", "fight"]: return false
	for field: String in ["pending_attack", "pending_hazard", "pending_deadly_demise", "pending_move", "pending_contact"]:
		var pending_value: Variant = s.get(field, {})
		if typeof(pending_value) != TYPE_DICTIONARY or not pending_value.is_empty(): return false
	var abilities_value: Variant = s.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return false
	var abilities: Dictionary = abilities_value
	if typeof(abilities.get("window", {})) != TYPE_DICTIONARY or not abilities.get("window", {}).is_empty(): return false
	if typeof(abilities.get("transport_window", {})) != TYPE_DICTIONARY or not abilities.get("transport_window", {}).is_empty(): return false
	var core_value: Variant = s.get("core_reactions", {})
	if typeof(core_value) != TYPE_DICTIONARY: return false
	for field: String in ["overwatch", "heroic"]:
		if typeof(core_value.get(field, {})) != TYPE_DICTIONARY or not core_value.get(field, {}).is_empty(): return false
	var stratagem_value: Variant = s.get("stratagems", {})
	if typeof(stratagem_value) != TYPE_DICTIONARY or typeof(stratagem_value.get("pending", {})) != TYPE_DICTIONARY or not stratagem_value.get("pending", {}).is_empty(): return false
	var reanimation_value: Variant = s.get("reanimation", {})
	if typeof(reanimation_value) != TYPE_DICTIONARY or typeof(reanimation_value.get("pending", {})) != TYPE_DICTIONARY or not reanimation_value.get("pending", {}).is_empty(): return false
	var morale_value: Variant = s.get("command_battle_shock", {})
	if typeof(morale_value) != TYPE_DICTIONARY or typeof(morale_value.get("pending", {})) != TYPE_DICTIONARY or not morale_value.get("pending", {}).is_empty(): return false
	return true

static func _remove_in_sacrifice_record(s: Dictionary, record_to_remove: Dictionary) -> void:
	var records: Array = s.get("detachment_stratagems", {}).get("wrath_destroyed", [])
	for index in range(records.size()):
		var record: Variant = records[index]
		if record is Dictionary and int(record.get("model", -1)) == int(record_to_remove.get("model", -1)) and int(record.get("squad", -1)) == int(record_to_remove.get("squad", -1)) and str(record.get("phase_key", "")) == str(record_to_remove.get("phase_key", "")):
			records.remove_at(index)
			break
	s.detachment_stratagems.wrath_destroyed = records

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
	var pending_storm: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {})
	if pending_storm.get("phase_key", "") == phase_key(s) and int(pending_storm.get("player", -1)) > 0: return int(pending_storm.player)
	var after: Dictionary = s.detachment_stratagems.get("after", {})
	var player := 3 - int(s.get("active", -1))
	if s.phase == "shooting" and after.get("phase_key", "") == phase_key(s) and not after.get("wiped", []).is_empty() and player in s.get("awakened_dynasty", {}).get("owners", []):
		for squad: int in s.squads:
			if error(s, player, squad, VENGEFUL).is_empty(): return player
	return -1

static func vengeful_shooter(s: Dictionary, squad: int) -> bool:
	if vengeful_actor(s) <= 0: return false
	var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
	if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("squad", -1)) == squad: return true
	var hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance", {})
	return hail.get("phase_key", "") == phase_key(s) and int(hail.get("squad", -1)) == squad

static func reactive_shooting_shooter(s: Dictionary, squad: int) -> bool:
	if vengeful_shooter(s, squad): return true
	if not s.squads.has(squad): return false
	var reactive: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	var player := int(reactive.get("player", -1))
	return reactive.get("phase_key", "") == phase_key(s) and player == 3 - int(s.get("active", -1)) and player == int(s.squads[squad].get("owner", -2)) and int(reactive.get("squad", -1)) == squad and not living(s, squad).is_empty() and not living(s, int(reactive.get("attacker", -1))).is_empty()

static func reactive_shooting_target(s: Dictionary, squad: int) -> int:
	if vengeful_shooter(s, squad):
		var vengeful: Dictionary = s.detachment_stratagems.get("vengeful", {})
		if vengeful.get("phase_key", "") == phase_key(s) and int(vengeful.get("squad", -1)) == squad: return int(vengeful.get("attacker", -1))
		var hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance", {})
		if hail.get("phase_key", "") == phase_key(s) and int(hail.get("squad", -1)) == squad: return int(hail.get("attacker", -1))
	var reactive: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	if reactive.get("phase_key", "") == phase_key(s) and int(reactive.get("squad", -1)) == squad: return int(reactive.get("attacker", -1))
	return -1

static func clear_reactive_shooting(s: Dictionary, squad: int) -> void:
	var reactive: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_reactive", {})
	if reactive.get("phase_key", "") == phase_key(s) and int(reactive.get("squad", -1)) == squad:
		s.detachment_stratagems.medusa_power_reactive = {}
	if vengeful_shooter(s, squad): clear_vengeful(s)

static func decline_medusa_power(s: Dictionary, player: int) -> String:
	var pending: Dictionary = s.get("detachment_stratagems", {}).get("medusa_power_pending", {})
	if pending.get("phase_key", "") != phase_key(s) or int(pending.get("player", -1)) != player: return "No Power of the Machine Spirit reaction is pending."
	s.detachment_stratagems.medusa_power_pending = {}
	return ""

static func clear_vengeful(s: Dictionary) -> void:
	if enabled(s):
		var active_reaction: Dictionary = s.detachment_stratagems.get("vengeful", {}).duplicate(true)
		var pending_storm: Dictionary = s.detachment_stratagems.get("storm_of_vengeance_pending", {}).duplicate(true)
		var next_storm: Dictionary = pending_storm
		var other_reaction_pending := not active_reaction.is_empty() or not s.detachment_stratagems.get("hail_of_vengeance", {}).is_empty() or not s.detachment_stratagems.get("hail_of_vengeance_pending", {}).is_empty()
		if str(active_reaction.get("source", "")) == STORM_OF_VENGEANCE and active_reaction.get("phase_key", "") == phase_key(s):
			var remaining: Array = active_reaction.get("remaining_squads", [])
			next_storm = {"phase_key": phase_key(s), "player": int(active_reaction.get("player", -1)), "attacker": int(active_reaction.get("attacker", -1)), "squads": remaining.duplicate()} if not remaining.is_empty() else {}
		elif pending_storm.get("phase_key", "") == phase_key(s) and not other_reaction_pending:
			next_storm = {}
		if not s.detachment_stratagems.get("after", {}).is_empty(): s.detachment_stratagems.after.vengeful_closed = true
		s.detachment_stratagems.vengeful = {}
		s.detachment_stratagems.hail_of_vengeance = {}
		s.detachment_stratagems.hail_of_vengeance_pending = {}
		s.detachment_stratagems.storm_of_vengeance_pending = next_storm

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

static func _marine_infantry(s: Dictionary, squad: int) -> bool:
	var members := living(s, squad)
	if members.is_empty(): return false
	for model: int in members:
		if not _has_keyword(s.units[model], "ADEPTUS ASTARTES") or not _has_keyword(s.units[model], "INFANTRY"): return false
	return true

static func gravis_unit(s: Dictionary, squad: int) -> bool:
	return "GRAVIS" in unit_keywords(s, squad)

static func gravis_annihilating_rule(s: Dictionary, player: int) -> String:
	if not enabled(s): return ""
	var detachment := Doctrines.detachment_for(s, player)
	if detachment == "gravis-linebreaker-force" and "gravis-linebreaker-force" in s.detachment_stratagems.get("modes", []) and Registry.enabled(s, GRAVIS_LINEBREAKER_ANNIHILATING_FORCE): return GRAVIS_LINEBREAKER_ANNIHILATING_FORCE
	if detachment == "gravis-siege-force" and "gravis-siege-force" in s.detachment_stratagems.get("modes", []) and Registry.enabled(s, GRAVIS_SIEGE_ANNIHILATING_FORCE): return GRAVIS_SIEGE_ANNIHILATING_FORCE
	return ""

static func terminator_merciless_rule(s: Dictionary, player: int) -> String:
	if not enabled(s) or "terminator-storm-force" not in s.detachment_stratagems.get("modes", []): return ""
	if Doctrines.detachment_for(s, player) == "terminator-storm-force" and Registry.enabled(s, TERMINATOR_MERCILESS_VETERANS): return TERMINATOR_MERCILESS_VETERANS
	return ""

static func terminator_fortitude_rule(s: Dictionary, player: int) -> String:
	if not enabled(s) or "terminator-storm-force" not in s.detachment_stratagems.get("modes", []): return ""
	if Doctrines.detachment_for(s, player) == "terminator-storm-force" and Registry.enabled(s, TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE): return TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE
	return ""

static func terminator_gunship_extraction_rule(s: Dictionary, player: int) -> String:
	if not enabled(s) or "terminator-storm-force" not in s.detachment_stratagems.get("modes", []): return ""
	if Doctrines.detachment_for(s, player) == "terminator-storm-force" and Registry.enabled(s, TERMINATOR_GUNSHIP_EXTRACTION): return TERMINATOR_GUNSHIP_EXTRACTION
	return ""

static func terminator_merciless_active(s: Dictionary, squad: int) -> bool:
	if not s.get("squads", {}).has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("terminator_merciless", {}).get(squad, {})
	var owner := int(s.squads[squad].get("owner", -1))
	return not terminator_merciless_rule(s, owner).is_empty() and record.get("phase_key", "") == phase_key(s)

static func phobos_strike_rule(s: Dictionary, player: int) -> String:
	if phobos_shock_enabled(s, player): return PHOBOS_STRIKE_FROM_SHADOWS
	if phobos_shadow_strike_enabled(s, player): return PHOBOS_SHADOW_STRIKE_FROM_SHADOWS
	return ""

static func phobos_unit_hidden(s: Dictionary, squad: int) -> bool:
	var models := living(s, squad)
	if models.is_empty(): return false
	for model: int in models:
		if not Terrain.hidden(s, model): return false
	return true

static func phobos_strike_active(s: Dictionary, squad: int) -> bool:
	if not s.get("squads", {}).has(squad): return false
	var record: Dictionary = s.get("detachment_stratagems", {}).get("phobos_strike", {}).get(squad, {})
	var owner := int(s.squads[squad].get("owner", -1))
	return not phobos_strike_rule(s, owner).is_empty() and record.get("phase_key", "") == phase_key(s)

static func gravis_siege_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "gravis-siege-force" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "gravis-siege-force" and Registry.enabled(s, GRAVIS_SIEGE_STAND_UNYIELDING)

static func gravis_suppression_enabled(s: Dictionary, player: int) -> bool:
	return enabled(s) and "gravis-siege-force" in s.detachment_stratagems.get("modes", []) and Doctrines.detachment_for(s, player) == "gravis-siege-force" and Registry.enabled(s, GRAVIS_SIEGE_SUPPRESSION_VOLLEYS)

static func stand_unyielding_objectives(s: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(squad) or living(s, squad).is_empty(): return result
	var player := int(s.squads[squad].get("owner", -1))
	var objectives: Array = s.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		var objective: Dictionary = objectives[index]
		if int(objective.get("controller", 0)) != player: continue
		if squad in Objectives.controlling_squads(s, objective, Callable(Morale, "objective_control")): result.append(index)
	return result

static func stand_unyielding_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if not gravis_siege_enabled(s, player) or not s.has("stratagems") or s.phase != "movement" or int(s.active) != player: return result
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", -1)) != player or bool(s.squads[squad].get("battle_shocked", false)) or not gravis_unit(s, squad): continue
		if living(s, squad).is_empty() or stand_unyielding_objectives(s, squad).is_empty(): continue
		if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): continue
		var available := true
		for use: Dictionary in s.stratagems.uses:
			if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and (str(use.get("stratagem", "")) == GRAVIS_SIEGE_STAND_UNYIELDING or int(use.get("squad", -1)) == squad):
				available = false
				break
		if available: result.append(squad)
	result.sort()
	return result

static func gauntlet_storm_and_secure_objectives(s: Dictionary, transport_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not s.squads.has(transport_squad) or living(s, transport_squad).is_empty(): return result
	var player := int(s.squads[transport_squad].get("owner", -1))
	var carries_battleline := false
	for transport_model: int in living(s, transport_squad):
		var transport: Dictionary = s.units[transport_model]
		if not transport.get("on_battlefield", true) or not _has_keyword(transport, "TRANSPORT"): continue
		var transport_profile_value: Variant = transport.get("transport_profile", {})
		if not transport_profile_value is Dictionary: continue
		var transport_profile: Dictionary = transport_profile_value
		if transport_profile.is_empty(): continue
		if not _has_keyword(transport, "ADEPTUS ASTARTES"): continue
		for passenger_squad: int in s.squads:
			var passenger: Dictionary = s.squads[passenger_squad]
			if int(passenger.get("owner", -1)) != player or int(passenger.get("embarked_in", -1)) != transport_model: continue
			if living(s, passenger_squad).is_empty() or not marine_unit(s, passenger_squad): continue
			if "BATTLELINE" in unit_keywords(s, passenger_squad):
				carries_battleline = true
				break
		if carries_battleline: break
	if carries_battleline:
		result = stand_unyielding_objectives(s, transport_squad)
	return result

static func gauntlet_storm_and_secure_squads(s: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if not gauntlet_enabled(s, player) or not Registry.supported(GAUNTLET_STORM_AND_SECURE) or not s.has("stratagems") or s.phase != "movement" or int(s.active) != player: return result
	var phase_used := false
	for use: Dictionary in s.stratagems.get("uses", []):
		if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s):
			if str(use.get("stratagem", "")) == GAUNTLET_STORM_AND_SECURE:
				phase_used = true
				break
	if phase_used: return result
	for squad: int in s.squads:
		if int(s.squads[squad].get("owner", -1)) != player or bool(s.squads[squad].get("battle_shocked", false)) or living(s, squad).is_empty(): continue
		if int(s.cp.get(player, 0)) < maxi(0, 1 - A.discount(s, player, squad)): continue
		var unit_used := false
		for use: Dictionary in s.stratagems.get("uses", []):
			if int(use.get("player", -1)) == player and str(use.get("phase_key", "")) == phase_key(s) and int(use.get("squad", -1)) == squad:
				unit_used = true
				break
		if unit_used: continue
		if gauntlet_storm_and_secure_objectives(s, squad).is_empty(): continue
		result.append(squad)
	result.sort()
	return result

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
	var movement_source := "Practical Tactics" if record.get("source", "") == ULTRAMARIAN_PRACTICAL_TACTICS else "We Are Vengeance" if record.get("source", "") == WE_ARE_VENGEANCE else "Transhuman Reactions" if record.get("source", "") == PHOBOS_TRANSHUMAN_REACTIONS else "Hunter's Instincts" if record.get("source", "") == HUNTERS_INSTINCTS else "Masterful Tactics" if record.get("source", "") == MASTERFUL_TACTICS else "Responsive Tactics"
	if window.get("kind", "") != "tactics" or not s.units.has(model) or s.units[model].squad != window.squad: return "This is not a %s placement." % movement_source
	if not record.has("origins") or not record.origins.has(model): return "This model cannot make the reaction move."
	if not point.is_finite(): return "Choose a finite reaction destination."
	if record.origins[model].distance_to(point) > float(record.inches) + 0.001: return "%s is a normal move of up to %s inches." % [movement_source, "D6 or 6" if movement_source in ["Masterful Tactics", "Transhuman Reactions"] else "D6" if movement_source == "Responsive Tactics" else "D3+3"]
	var half: Vector2 = s.board_size / 2.0
	var radius: float = float(s.units[model].radius)
	if absf(point.x) + radius > half.x or absf(point.y) + radius > half.y: return "The whole base must fit on the battlefield."
	for other: int in s.units:
		if other == model or s.units[other].wounds <= 0 or not s.units[other].get("on_battlefield", true): continue
		var position: Vector2 = window.positions.get(other, s.units[other].position)
		if point.distance_to(position) < radius + float(s.units[other].radius) - 0.001: return "Reaction move bases cannot overlap."
		var moved_model: Dictionary = s.units[model].duplicate(true)
		moved_model.position = point
		var other_model: Dictionary = s.units[other].duplicate(true)
		other_model.position = position
		if s.units[other].owner != s.units[model].owner and G.within_engagement(moved_model, other_model): return "The reaction move must end unengaged."
	return ""

static func confirm_tactics(s: Dictionary) -> Dictionary:
	var window: Dictionary = s.get("unit_abilities", {}).get("window", {})
	var record: Dictionary = s.get("detachment_stratagems", {}).get("tactics", {}).get(window.get("squad", -1), {})
	var movement_source := "Practical Tactics" if record.get("source", "") == ULTRAMARIAN_PRACTICAL_TACTICS else "We Are Vengeance" if record.get("source", "") == WE_ARE_VENGEANCE else "Transhuman Reactions" if record.get("source", "") == PHOBOS_TRANSHUMAN_REACTIONS else "Hunter's Instincts" if record.get("source", "") == HUNTERS_INSTINCTS else "Masterful Tactics" if record.get("source", "") == MASTERFUL_TACTICS else "Responsive Tactics"
	if window.get("kind", "") != "tactics": return {"error": "No %s move is pending." % movement_source}
	var projected := s.duplicate(true)
	for model: int in living(s, window.squad):
		var point: Vector2 = window.positions.get(model, s.units[model].position)
		var error := tactics_position_error(s, model, point)
		if not error.is_empty(): return {"error": error}
		projected.units[model].position = point
	if Queue.engaged(projected, window.squad): return {"error": "The reaction move must end unengaged."}
	for model: int in living(s, window.squad): s.units[model].position = window.positions.get(model, s.units[model].position)
	s.unit_abilities.window = window.get("resume_window", {})
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
		var returned_model: Dictionary = s.units[model].duplicate(true)
		returned_model.position = point
		var other_model: Dictionary = s.units[other].duplicate(true)
		other_model.position = position
		if s.units[other].owner != s.units[model].owner and G.within_engagement(returned_model, other_model): return "Eternal Revenant must set up unengaged."
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
	s.unit_abilities.window = window.get("resume_window", {})
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

extends RefCounted
## Space Marine enhancement records transcribed from the pinned local Wahapedia e11 export.
const SUPERCHARGED := "000008486002"
const AUSPEX := "000008486003"
const ARTIFICER_SARCOPHAGUS := "000011224002"
const VENERABLE_CHAMPION := "000011224003"
const ADEPT_OF_THE_CODEX := "000008353004"
const STUDENT_OF_THE_CODEX := "000010633002"
const ARMOUR_OF_ANTONINUS := "000010633003"
const OATH_OF_MACRAGGE := "000010633004"
const VETERAN_OF_BEHEMOTH := "000010633005"
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
const LORD_OF_THE_RAVENWING := "000010155003"
const TEMPERED_IN_BATTLE := "000010155002"
const DEATHWING_ASSAULT := "000010155004"
const ANCIENT_WEAPONS := "000010155005"
const SINGULAR_WILL := "000008774002"
const CHAMPION_OF_THE_DEATHWING := "000008774003"
const THUNDERCOWL_TURBINES := "000011095002"
const NIGHTFORGED_BATTERY := "000011095003"
const GAUNTLET := "gauntlet-task-force"
const LINEBREAKER_ONSLAUGHT := "000011184002"
const DAMOCLES_CLASS_UPLINK := "000011184003"
const IMMOVABLE_CONQUERORS := "000011216002"
const NARTHECIS_GAUNTLET := "000011216003"
const THE_FLESH_IS_WEAK := "000011180005"
const TARGET_AUGURY_WEB := "000011180002"
const MASTER_OF_THE_MACHINE_WAR := "000011180004"
const ADEPT_OF_THE_OMNISSIAH := "000011180003"
const CHAMPION_OF_FIRST_COMPANY := "000011200002"
const CORPOREUM_RELIQUARY := "000011200003"
const INDEFATIGABLE_FORTITUDE := "000011208002"
const RELENTLESS_ADVANCE := "000011208003"
const SPEARPOINT_WAR_LEADER := "000011192003"
const MARTIAL_PARAGON := "000011192002"
const CYBER_FAMILIAR := "000011228002"
const FIRESTORM_TEMPERED_IN_BATTLE := "000011228003"
const PHOBOS_SHOCK_SEAL := "000011196002"
const PHOBOS_SHOCK_VENATOR := "000011196003"
const PHOBOS_SHADOW_VENATOR := "000011188002"
const PHOBOS_SHADOW_EXECUTE_REDEPLOY := "000011188003"
const OATHBOUND_EXEMPLAR := "000011176003"
const CONSECRATING_AURA := "000011172003"
const INCENDIARY_ANIMUS := "000011172004"
const ZEALOUS_VANGUARD := "000011172005"
const STORMLANCE := "stormlance"
const IRONCLAD := "ironclad-champions"
const GLADIUS := "gladius"
const TERMINATOR_STORM := "terminator-storm-force"
const ASSAULT_BRETHREN := "assault-brethren"
const TACTICAL_BRETHREN := "tactical-brethren"
const DEVASTATOR_BRETHREN := "devastator-brethren"
const SPEARPOINT := "spearpoint-task-force"
const IRONSTORM := "ironstorm-spearhead"
const WRATH_OF_THE_ROCK := "wrath-of-the-rock"
const DARKFLIGHT := "darkflight-pursuit"
const GRAVIS_SIEGE := "gravis-siege-force"
const GRAVIS_LINEBREAKER := "gravis-linebreaker-force"
const TACTICUS_ATTACK := "tacticus-attack-force"
const TACTICUS_FIRESTORM := "tacticus-firestorm-force"
const MEDUSA_WRATH := "medusa-wrath"
const PHOBOS_SHOCK := "phobos-shock-force"
const PHOBOS_SHADOW := "phobos-shadow-force"
const FIST_OF_THE_GOD_EMPEROR := "fist-of-the-god-emperor"
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
	STUDENT_OF_THE_CODEX: {"id": STUDENT_OF_THE_CODEX, "name": "Student of the Codex", "cost": 20, "detachment": "blade-of-ultramar", "source_restricted": true,
		"source_datasheet_ids": ["000000073", "000000083", "000000135", "000001172", "000002701", "000002702", "000002796", "000003831", "000003832", "000003833", "000003871"],
		"datasheets": [], "required_keywords": ["CAPTAIN"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Captain model only. Tactical Doctrine is active for this unit in addition to any other Combat Doctrine."},
	ARMOUR_OF_ANTONINUS: {"id": ARMOUR_OF_ANTONINUS, "name": "Armour of Antoninus", "cost": 15, "detachment": "blade-of-ultramar", "source_restricted": true,
		"source_datasheet_ids": [
			"000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135",
			"000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677",
			"000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831",
			"000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES", "CHARACTER"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Adeptus Astartes Character model only. The bearer has a 2+ Save and Feel No Pain 5+."},
	OATH_OF_MACRAGGE: {"id": OATH_OF_MACRAGGE, "name": "Oath of Macragge", "cost": 20, "detachment": "blade-of-ultramar", "source_restricted": true,
		"source_datasheet_ids": [
			"000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135",
			"000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677",
			"000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831",
			"000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES", "CHARACTER"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Adeptus Astartes Character model only. The bearer's melee attacks have +1 Strength and AP, or +2 Strength and AP while Assault Doctrine is active for its unit."},
	VETERAN_OF_BEHEMOTH: {"id": VETERAN_OF_BEHEMOTH, "name": "Veteran of Behemoth", "cost": 20, "detachment": "blade-of-ultramar", "source_restricted": true,
		"source_datasheet_ids": [
			"000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135",
			"000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677",
			"000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831",
			"000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES", "CHARACTER"], "forbidden_keywords": ["EPIC HERO"],
		"rule": "Adeptus Astartes Character model only. This unit's ranged attacks have Sustained Hits 1."},
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
	GUNNERY_HONOURS: {"id": GUNNERY_HONOURS, "name": "Gunnery Honours", "cost": 15, "detachment": IRONSTORM, "source_restricted": true, "source_datasheet_ids": ["000000086", "000001667", "000001825", "000002705", "000004247"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keywords": ["VEHICLE"], "forbidden_keywords": ["FLY", "WALKER"], "excluded_source_roles": ["Transport"], "rule": "Adeptus Astartes Vehicle unit only, excluding Dedicated Transport/Fly/Walker. This unit's ranged attacks have Heavy."},
	IMMOVABLE_CONQUERORS: {"id": IMMOVABLE_CONQUERORS, "name": "Immovable Conquerors", "cost": 15, "detachment": GRAVIS_SIEGE, "source_restricted": true, "source_datasheet_ids": ["000000060", "000000125", "000001172", "000001177", "000002099", "000002781", "000003874", "000004175", "000004231", "000004249"], "datasheets": [], "required_keywords": ["GRAVIS"], "rule": "Gravis unit only. This unit has +1 OC."},
	NARTHECIS_GAUNTLET: {"id": NARTHECIS_GAUNTLET, "name": "Narthecis Gauntlet", "cost": 20, "detachment": GRAVIS_SIEGE, "source_restricted": true, "source_datasheet_ids": ["000000060"], "datasheets": [], "rule": "Apothecary Biologis model only. In your Command phase, this unit heals D3+1 wounds."},
	THE_FLESH_IS_WEAK: {"id": THE_FLESH_IS_WEAK, "name": "The Flesh is Weak", "cost": 15, "detachment": MEDUSA_WRATH, "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. The bearer has +1 Toughness and Feel No Pain 5+."},
	TARGET_AUGURY_WEB: {"id": TARGET_AUGURY_WEB, "name": "Target Augury Web", "cost": 30, "detachment": MEDUSA_WRATH, "source_restricted": true,
		"source_datasheet_ids": ["000000140", "000000306"], "datasheets": [],
		"rule": "Techmarine model only. In your Movement phase, at the start or end of this unit's move, select one friendly Adeptus Astartes Vehicle model within 3 inches of this unit. That Vehicle model's attacks have Lethal Hits until the start of your next Command phase."},
	MASTER_OF_THE_MACHINE_WAR: {"id": MASTER_OF_THE_MACHINE_WAR, "name": "Master of the Machine War", "cost": 25, "detachment": MEDUSA_WRATH, "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. In your Movement phase, select one visible friendly Adeptus Astartes Vehicle unit within 6 inches of this model and choose Devastator or Tactical Doctrine. That doctrine is active for that Vehicle unit until the start of your next Command phase."},
	ADEPT_OF_THE_OMNISSIAH: {"id": ADEPT_OF_THE_OMNISSIAH, "name": "Adept of the Omnissiah", "cost": 25, "detachment": MEDUSA_WRATH, "source_restricted": true,
		"source_datasheet_ids": ["000000140", "000000306"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Techmarine model only. Once per battle round, per army, when an enemy unit targets a friendly Adeptus Astartes Vehicle unit within 6 inches of this unit, you can give that Vehicle unit Feel No Pain 5+ until that enemy unit has attacked."},
	CHAMPION_OF_FIRST_COMPANY: {"id": CHAMPION_OF_FIRST_COMPANY, "name": "Champion of the First Company", "cost": 20, "detachment": TERMINATOR_STORM, "source_restricted": true, "source_datasheet_ids": ["000000079", "000000115", "000000135", "000002677"], "datasheets": [], "required_keywords": ["TERMINATOR"], "rule": "Adeptus Astartes Terminator model only. This unit's melee attacks have Lethal Hits."},
	CORPOREUM_RELIQUARY: {"id": CORPOREUM_RELIQUARY, "name": "Corporeum Reliquary", "cost": 25, "detachment": TERMINATOR_STORM, "source_restricted": true, "source_datasheet_ids": ["000000079", "000000115", "000000135", "000002677"], "datasheets": [], "required_keywords": ["TERMINATOR"], "rule": "Adeptus Astartes Terminator model only. In your first Movement phase, this unit can make an ingress move."},
	PHOBOS_SHOCK_SEAL: {"id": PHOBOS_SHOCK_SEAL, "name": "Seal of Shrouding", "cost": 15, "detachment": PHOBOS_SHOCK, "source_restricted": true,
		"source_datasheet_ids": ["000000076", "000000119", "000002530", "000002701"], "datasheets": [], "required_keywords": ["PHOBOS"],
		"rule": "PHOBOS model only. Enemy units cannot target this unit with Snap Shooting attacks."},
	PHOBOS_SHOCK_VENATOR: {"id": PHOBOS_SHOCK_VENATOR, "name": "Venator Omni-auspex", "cost": 15, "detachment": PHOBOS_SHOCK, "source_restricted": true,
		"source_datasheet_ids": ["000000076", "000000119", "000002530", "000002701"], "datasheets": [], "required_keywords": ["PHOBOS"],
		"rule": "PHOBOS model only. This unit's attacks that target a hidden unit can re-roll Wound rolls of 1, or 1 and 2 if Assault Doctrine is active for this unit."},
	PHOBOS_SHADOW_VENATOR: {"id": PHOBOS_SHADOW_VENATOR, "name": "Venator Omni-auspex", "cost": 15, "detachment": PHOBOS_SHADOW, "source_restricted": true,
		"source_datasheet_ids": ["000000076", "000000119", "000002530", "000002701"], "datasheets": [], "required_keywords": ["PHOBOS"],
		"rule": "PHOBOS model only. This unit's attacks that target a hidden unit can re-roll Wound rolls of 1, or 1 and 2 if Assault Doctrine is active for this unit."},
	PHOBOS_SHADOW_EXECUTE_REDEPLOY: {"id": PHOBOS_SHADOW_EXECUTE_REDEPLOY, "name": "Execute and Redeploy", "cost": 25, "detachment": PHOBOS_SHADOW, "source_restricted": true,
		"source_datasheet_ids": ["000000076", "000000119", "000002530", "000002701"], "datasheets": [], "required_keywords": ["PHOBOS"],
		"rule": "PHOBOS model only. In your Shooting phase, after this unit has shot, if this unit is unengaged, it can make a Normal Move of up to 6 inches. If it does, this unit is not eligible to declare a Charge until the end of the turn."},
	OATHBOUND_EXEMPLAR: {"id": OATHBOUND_EXEMPLAR, "name": "Oathbound Exemplar", "cost": 10, "detachment": FIST_OF_THE_GOD_EMPEROR, "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002707", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keywords": ["INFANTRY"],
		"rule": "Adeptus Astartes Infantry unit only. When this unit is selected to make an Advance or Fall Back move, that move does not prevent this unit from being eligible to start an action."},
	CONSECRATING_AURA: {"id": CONSECRATING_AURA, "name": "Consecrating Aura", "cost": 20, "detachment": "vow-sworn-crusaders", "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. This unit has a 5+ invulnerable save."},
	INCENDIARY_ANIMUS: {"id": INCENDIARY_ANIMUS, "name": "Incendiary Animus", "cost": 25, "detachment": "vow-sworn-crusaders", "source_restricted": true,
		"source_datasheet_ids": ["000000094", "000000112", "000000115", "000001174", "000002707", "000004135"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Chaplain or Judiciar model only. This unit's melee attacks have +1 Strength."},
	ZEALOUS_VANGUARD: {"id": ZEALOUS_VANGUARD, "name": "Zealous Vanguard", "cost": 25, "detachment": "vow-sworn-crusaders", "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Adeptus Astartes model only. This unit has Scouts 6 inches."},
	THUNDERCOWL_TURBINES: {"id": THUNDERCOWL_TURBINES, "name": "Thundercowl Turbines", "cost": 15, "detachment": DARKFLIGHT, "source_restricted": true,
		"source_datasheet_ids": ["000000084", "000000094", "000000114", "000000124", "000000137", "000000139", "000000238", "000000239", "000000240", "000000241", "000000242", "000001190", "000001191", "000001610", "000002702", "000002711", "000002712", "000002748", "000004247"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "required_unit_keyword_groups": [["FLY", "MOUNTED"]],
		"rule": "Ravenwing Fly or Ravenwing Mounted unit only. In your first Movement phase, this unit can make an ingress move."},
	NIGHTFORGED_BATTERY: {"id": NIGHTFORGED_BATTERY, "name": "Nightforged Battery", "cost": 10, "detachment": DARKFLIGHT, "source_restricted": true,
		"source_datasheet_ids": ["000000242"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"],
		"rule": "Land Speeder Vengeance unit only. This unit can re-roll rolls to determine the Attacks characteristic of its weapons, and Hazard rolls."},
	INDEFATIGABLE_FORTITUDE: {"id": INDEFATIGABLE_FORTITUDE, "name": "Indefatigable Fortitude", "cost": 20, "detachment": GRAVIS_LINEBREAKER, "source_restricted": true, "source_datasheet_ids": ["000000060", "000001172"], "datasheets": [], "required_keywords": ["GRAVIS"], "rule": "Gravis model only. Attacks that target this unit with Strength greater than its Toughness have -1 to Wound rolls."},
	RELENTLESS_ADVANCE: {"id": RELENTLESS_ADVANCE, "name": "Relentless Advance", "cost": 20, "detachment": GRAVIS_LINEBREAKER, "source_restricted": true, "source_datasheet_ids": ["000000060", "000001172"], "datasheets": [], "required_keywords": ["GRAVIS"], "rule": "Gravis model only. This unit has Scouts 5 inches."},
	SPEARPOINT_WAR_LEADER: {"id": SPEARPOINT_WAR_LEADER, "name": "Spearpoint War Leader", "cost": 15, "detachment": TACTICUS_ATTACK, "source_restricted": true, "source_datasheet_ids": ["000000073", "000000083", "000000112", "000000140", "000001165", "000001174", "000001346", "000002266", "000002707", "000002773", "000002775"], "datasheets": [], "required_keywords": ["TACTICUS"], "rule": "Tacticus model only. This unit has Scouts 6 inches."},
	MARTIAL_PARAGON: {"id": MARTIAL_PARAGON, "name": "Martial Paragon", "cost": 10, "detachment": TACTICUS_ATTACK, "source_restricted": true, "source_datasheet_ids": ["000000073", "000000083", "000000112", "000000140", "000001165", "000001174", "000001346", "000002266", "000002707", "000002773", "000002775"], "datasheets": [], "required_keywords": ["TACTICUS"], "rule": "Tacticus model only. This unit's attacks can re-roll one hit roll and one wound roll."},
	CYBER_FAMILIAR: {"id": CYBER_FAMILIAR, "name": "Cyber-familiar", "cost": 15, "detachment": TACTICUS_FIRESTORM, "source_restricted": true, "source_datasheet_ids": ["000000073", "000000083", "000000112", "000000140", "000000158", "000001165", "000001174", "000001346", "000002266", "000002707", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000004129", "000004130", "000004135", "000004136"], "datasheets": [], "required_keywords": ["TACTICUS"], "rule": "Tacticus model only. After both armies have deployed, redeploy up to three friendly Adeptus Astartes Infantry units; each may be placed in Strategic Reserves regardless of the normal limit."},
	FIRESTORM_TEMPERED_IN_BATTLE: {"id": FIRESTORM_TEMPERED_IN_BATTLE, "name": "Tempered in Battle (Aura)", "cost": 10, "detachment": TACTICUS_FIRESTORM, "source_restricted": true, "source_datasheet_ids": ["000000073", "000000083", "000000112", "000000140", "000000158", "000001165", "000001174", "000001346", "000002266", "000002707", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000004129", "000004130", "000004135", "000004136"], "datasheets": [], "required_keywords": ["TACTICUS"], "rule": "Tacticus model only. Friendly Adeptus Astartes units within 6 inches can re-roll Leadership rolls."},
	LORD_OF_THE_RAVENWING: {"id": LORD_OF_THE_RAVENWING, "name": "Lord of the Ravenwing", "cost": 15, "detachment": WRATH_OF_THE_ROCK, "source_restricted": true, "source_datasheet_ids": ["000000094", "000002702"], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "RAVENWING model only. This unit can re-roll Charge rolls."},
	TEMPERED_IN_BATTLE: {"id": TEMPERED_IN_BATTLE, "name": "Tempered in Battle (Aura)", "cost": 10, "detachment": WRATH_OF_THE_ROCK, "source_datasheet_ids": [], "datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "Adeptus Astartes model only. Friendly Adeptus Astartes units within 6 inches can re-roll Leadership rolls."},
	DEATHWING_ASSAULT: {"id": DEATHWING_ASSAULT, "name": "Deathwing Assault", "cost": 15, "detachment": WRATH_OF_THE_ROCK, "source_restricted": true,
		"source_datasheet_ids": ["000000079", "000000115", "000000135", "000002677"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "DEATHWING model with the Deep Strike ability only. In your first Movement phase, this unit can make an ingress move."},
	ANCIENT_WEAPONS: {"id": ANCIENT_WEAPONS, "name": "Ancient Weapons", "cost": 20, "detachment": WRATH_OF_THE_ROCK, "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000094", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002702", "000002707", "000002748", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "Adeptus Astartes model only. This model's melee attacks have +2 Strength and +1 AP."},
	SINGULAR_WILL: {"id": SINGULAR_WILL, "name": "Singular Will", "cost": 20, "detachment": "inner-circle-task-force", "source_restricted": true,
		"source_datasheet_ids": ["000000079", "000000115", "000000135", "000001165", "000002677"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "DEATHWING model only. When this unit is selected to make a Consolidation move, it can move up to D3+3 inches."},
	CHAMPION_OF_THE_DEATHWING: {"id": CHAMPION_OF_THE_DEATHWING, "name": "Champion of the Deathwing", "cost": 20, "detachment": "inner-circle-task-force", "source_restricted": true,
		"source_datasheet_ids": ["000000079", "000000115", "000000135", "000001165", "000002677"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES"], "rule": "DEATHWING model only. This unit's attacks that target an enemy unit within range of your Vowed objective have Sustained Hits 1."},
	LINEBREAKER_ONSLAUGHT: {"id": LINEBREAKER_ONSLAUGHT, "name": "Linebreaker Onslaught", "cost": 20, "detachment": GAUNTLET, "source_restricted": true,
		"source_datasheet_ids": ["000000060", "000000073", "000000076", "000000079", "000000083", "000000112", "000000115", "000000119", "000000135", "000000140", "000000158", "000000306", "000001165", "000001172", "000001174", "000001346", "000002266", "000002530", "000002677", "000002701", "000002707", "000002773", "000002775", "000002793", "000002795", "000002796", "000003831", "000003832", "000003833", "000003871", "000004129", "000004130", "000004135", "000004136"],
		"datasheets": [], "required_keywords": ["INFANTRY"], "rule": "Adeptus Astartes Infantry model only. If this unit disembarked this turn, it can re-roll Charge rolls and cannot be targeted by Snap Shooting attacks."},
	DAMOCLES_CLASS_UPLINK: {"id": DAMOCLES_CLASS_UPLINK, "name": "Damocles-class Uplink", "cost": 15, "detachment": GAUNTLET, "source_restricted": true,
		"source_datasheet_ids": ["000000073", "000000083", "000000135", "000001172", "000002701", "000002702", "000002796", "000003831", "000003832", "000003833", "000003871"],
		"datasheets": [], "required_keywords": ["ADEPTUS ASTARTES", "CAPTAIN"], "rule": "Captain model only. In your Movement phase, if this unit is embarked within a Transport unit, select one friendly Adeptus Astartes Infantry unit within 6 inches of that Transport and select one Combat Doctrine. That doctrine is active for that Infantry unit."}
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
		var named_captain := id in [ADEPT_OF_THE_CODEX, STUDENT_OF_THE_CODEX] and str(profile.get("name", "")) == "Captain"
		var named_ancient := id == STANDARD_OF_THE_EMPEROR_ASCENDANT and str(profile.get("name", "")) in ["Ancient", "Bladeguard Ancient", "Ancient in Terminator Armour"]
		var eligible: bool = not profile.is_empty() and (source_eligible or not required.is_empty() or named_captain or named_ancient)
		if record.get("source_restricted", false) and not source_eligible: eligible = false
		if source_role in record.get("excluded_source_roles", []): eligible = false
		if not record.get("required_unit_keywords", []).is_empty():
			for keyword: String in record.required_unit_keywords:
				if keyword not in keywords: eligible = false
		for group_value: Variant in record.get("required_unit_keyword_groups", []):
			if not group_value is Array:
				eligible = false
				continue
			var group_matches := false
			for keyword_value: Variant in group_value:
				if str(keyword_value) in keywords:
					group_matches = true
					break
			if not group_matches: eligible = false
		for keyword: String in required:
			if keyword not in keywords and not named_captain and not named_ancient: eligible = false
		if record.get("required_keywords", []).is_empty() and not source_eligible and not named_captain and not named_ancient: eligible = false
		for keyword: String in record.get("forbidden_keywords", []):
			if keyword in keywords: eligible = false
		if eligible: result.append(record.duplicate(true))
	return result

static func valid_for(identity: String, enhancement_id: String, detachment: String) -> bool:
	if bool(RECORDS.get(enhancement_id, {}).get("admission_blocked", false)): return false
	for record: Dictionary in for_datasheet(identity, detachment):
		if record.id == enhancement_id: return true
	return false

static func catalog_records(eligible_identities: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in RECORDS:
		var record: Dictionary = RECORDS[id].duplicate(true)
		if record.get("admission_blocked", false): continue
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
	var owner := int(state.squads[squad].get("owner", -1))
	if not detachment_active(state, str(record.detachment), owner): return false
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
	if not detachment_active(state, str(record.detachment), int(state.squads[squad].get("owner", -1))): return false
	if "ADEPTUS ASTARTES" not in unit.get("keywords", []): return false
	return valid_for(str(unit.get("definition_id", "")), enhancement_id, str(record.detachment))

static func venator_omni_auspex_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, PHOBOS_SHOCK_VENATOR) or active(state, squad, PHOBOS_SHADOW_VENATOR)

static func execute_and_redeploy_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, PHOBOS_SHADOW_EXECUTE_REDEPLOY)

static func oathbound_exemplar_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, OATHBOUND_EXEMPLAR)

static func consecrating_aura_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, CONSECRATING_AURA)

static func incendiary_animus_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, INCENDIARY_ANIMUS)

static func zealous_vanguard_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, ZEALOUS_VANGUARD)

static func linebreaker_onslaught_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, LINEBREAKER_ONSLAUGHT) and int(state.squads[squad].get("disembarked_turn", -1)) == int(state.get("turn", -2))

static func damocles_class_uplink_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, DAMOCLES_CLASS_UPLINK)

static func damocles_class_uplink_doctrine(state: Dictionary, squad: int) -> String:
	if not state.get("squads", {}).has(squad): return ""
	var effect: Dictionary = state.get("marine_enhancements", {}).get("damocles_doctrine_targets", {}).get(squad, {})
	if int(effect.get("owner", -1)) != int(state.squads[squad].get("owner", -2)) or int(state.get("turn", 0)) >= int(effect.get("expires_turn", -1)): return ""
	var doctrine := str(effect.get("doctrine", ""))
	return doctrine if doctrine in ["devastator", "tactical", "assault"] else ""

static func blocks_snap_shooting(state: Dictionary, squad: int) -> bool:
	return active(state, squad, PHOBOS_SHOCK_SEAL) or linebreaker_onslaught_active(state, squad)

static func snap_shooting_block_name(state: Dictionary, squad: int) -> String:
	if linebreaker_onslaught_active(state, squad): return "Linebreaker Onslaught"
	if active(state, squad, PHOBOS_SHOCK_SEAL): return "Seal of Shrouding"
	return "This unit's enhancement"

static func additional_doctrines(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	if active(state, squad, ADEPT_OF_THE_CODEX) or active(state, squad, STUDENT_OF_THE_CODEX) or active(state, squad, TACTICAL_INSIGHT): result.append("tactical")
	var machine_war_doctrine := master_machine_war_doctrine(state, squad)
	if machine_war_doctrine in ["devastator", "tactical"] and machine_war_doctrine not in result: result.append(machine_war_doctrine)
	return result

static func master_machine_war_doctrine(state: Dictionary, squad: int) -> String:
	if not state.get("squads", {}).has(squad): return ""
	var effect: Dictionary = state.get("marine_enhancements", {}).get("master_machine_war_targets", {}).get(squad, {})
	if int(effect.get("owner", -1)) != int(state.squads[squad].get("owner", -2)) or int(state.get("turn", 0)) >= int(effect.get("expires_turn", -1)): return ""
	var doctrine := str(effect.get("doctrine", ""))
	return doctrine if doctrine in ["devastator", "tactical"] else ""

static func master_forged_firearms_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, MASTER_FORGED_FIREARMS)

static func honour_of_vigilance_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, HONOUR_OF_VIGILANCE)

static func artificer_armour_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, ARTIFICER_ARMOUR)

static func armour_of_antoninus_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, ARMOUR_OF_ANTONINUS)

static func oath_of_macragge_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, OATH_OF_MACRAGGE)

static func veteran_of_behemoth_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, VETERAN_OF_BEHEMOTH)

static func melee_strength_ap_enhancement_bearer(state: Dictionary, model: int) -> bool:
	return laurels_bearer(state, model) or oath_of_macragge_bearer(state, model)

static func laurels_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, LAURELS_OF_TRIUMPH)

static func standard_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, STANDARD_OF_THE_EMPEROR_ASCENDANT)

static func flesh_is_weak_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, THE_FLESH_IS_WEAK)

static func target_augury_web_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, TARGET_AUGURY_WEB)

static func master_of_the_machine_war_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, MASTER_OF_THE_MACHINE_WAR)

static func adept_of_the_omnissiah_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, ADEPT_OF_THE_OMNISSIAH)

static func imperiums_sword_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, IMPERIUMS_SWORD)

static func furious_assault_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, FURIOUS_ASSAULT)

static func champion_of_the_deathwing_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, CHAMPION_OF_THE_DEATHWING)

static func singular_will_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, SINGULAR_WILL)

static func detachment_active(state: Dictionary, detachment: String, player: int = -1) -> bool:
	if player < 0: return active_detachment(state, detachment)
	return active_detachment(state, detachment, player)

static func laurels_vigilance_discount(state: Dictionary, player: int, target_squad: int, stratagem_id: String) -> int:
	if stratagem_id not in ["fire-overwatch", "heroic-intervention"] or not detachment_active(state, TACTICAL_BRETHREN, player): return 0
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
	if not active_detachment(state, GLADIUS, player) or state.get("test_winner", 0) != 0 or state.get("phase", "") != "fight" or int(state.get("fight_actor", -1)) != player or state.get("fight_step", "") != "attacks": return result
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

static func active_detachment(state: Dictionary, detachment: String, player: int = -1) -> bool:
	var doctrine_state: Dictionary = state.get("combat_doctrines", {})
	if player >= 0:
		var assignments: Dictionary = doctrine_state.get("detachments", {})
		var values: Array = assignments.values()
		if not values.is_empty() and values.all(func(value: Variant) -> bool: return str(value) == str(values[0])) and not str(doctrine_state.get("detachment", "")).is_empty(): return str(doctrine_state.detachment) == detachment
		return str(assignments.get(player, assignments.get(str(player), doctrine_state.get("detachment", "")))) == detachment
	return str(doctrine_state.get("detachment", "")) == detachment

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

static func lord_of_the_ravenwing_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, LORD_OF_THE_RAVENWING)

static func tempered_in_battle_active(state: Dictionary, target_squad: int) -> bool:
	if not state.get("squads", {}).has(target_squad) or Geometry.alive(state, target_squad).is_empty(): return false
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	for target_model: int in Geometry.alive(state, target_squad):
		if "ADEPTUS ASTARTES" not in state.units[target_model].get("keywords", []): return false
	for bearer: int in state.get("units", {}):
		var bearer_unit: Dictionary = state.units[bearer]
		var enhancement_id := str(bearer_unit.get("enhancement_id", ""))
		if int(bearer_unit.get("owner", -1)) != target_owner or enhancement_id not in [TEMPERED_IN_BATTLE, FIRESTORM_TEMPERED_IN_BATTLE]: continue
		if not model_active(state, bearer, enhancement_id): continue
		if Geometry.distance_to_target(state, bearer_unit, target_squad) <= 6.0 + Geometry.EPSILON: return true
	return false

## Resolve the enhancement once at the end of its owner's Command phase.
static func ironstorm_command_healing(state: Dictionary, player: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if state.get("phase", "") != "command" or int(state.get("active", -1)) != player or not active_detachment(state, IRONSTORM, player): return results
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

static func martial_paragon_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, MARTIAL_PARAGON)

static func ancient_weapons_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, ANCIENT_WEAPONS)

static func champion_of_first_company_applies_to_unit(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var squad := int(state.units[model].get("squad", -1))
	if not state.get("squads", {}).has(squad): return false
	for bearer_model: int in state.get("units", {}):
		if int(state.units[bearer_model].get("squad", -1)) != squad: continue
		if model_active(state, bearer_model, CHAMPION_OF_FIRST_COMPANY): return true
	return false

static func deathwing_assault_active(state: Dictionary, squad: int) -> bool:
	return active(state, squad, DEATHWING_ASSAULT)

static func deathwing_assault_bearer(state: Dictionary, model: int) -> bool:
	return model_active(state, model, DEATHWING_ASSAULT)

static func first_movement_ingress_enhancement(state: Dictionary, squad: int) -> String:
	if not state.get("squads", {}).has(squad): return ""
	if thundercowl_turbines_active(state, squad): return THUNDERCOWL_TURBINES
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) != squad: continue
		if model_active(state, model, DEATHWING_ASSAULT): return DEATHWING_ASSAULT
		if model_active(state, model, CORPOREUM_RELIQUARY): return CORPOREUM_RELIQUARY
	return ""

static func thundercowl_turbines_bearer(state: Dictionary, model: int) -> bool:
	if not model_active(state, model, THUNDERCOWL_TURBINES): return false
	var squad := int(state.units[model].get("squad", -1))
	var owner := int(state.squads[squad].get("owner", -1))
	var chapters: Dictionary = state.get("marine_chapters", {})
	if str(chapters.get(owner, chapters.get(str(owner), ""))) != "DARK ANGELS": return false
	var keywords: Array = state.units[model].get("keywords", [])
	return "RAVENWING" in keywords and ("FLY" in keywords or "MOUNTED" in keywords)

static func thundercowl_turbines_active(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) == squad and thundercowl_turbines_bearer(state, model): return true
	return false

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

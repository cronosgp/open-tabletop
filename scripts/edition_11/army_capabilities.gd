extends RefCounted
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
## Explicit core-profile admission, independent of display names and API prices.
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const CurrentNecrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const CanoptekMacrocytes = preload("res://scripts/edition_11/canoptek_macrocytes.gd")
const CanoptekSpyders = preload("res://scripts/edition_11/canoptek_spyders.gd")
const CanoptekTombCrawlers = preload("res://scripts/edition_11/canoptek_tomb_crawlers.gd")
const NecronVehicleLoadouts = preload("res://scripts/edition_11/necron_vehicle_loadouts.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const UnitAbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const ID := "mixed-core-profiles-v109-brutalis-saved-equipment"
const DIRECTORY := "res://data/imported/starter-11e-v1"
const MAX_SQUADS := 6
## Saved current-catalog lists use this ceiling. Direct core-profile calls keep MAX_SQUADS.
const MATCH_UNIT_CAP := 24
const STANDARD_COPY_LIMITS := {"incursion": 2, "strike_force": 3}
const INTERCESSOR_SQUAD_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const ELIMINATOR_SQUAD_ID := "40kdc:11e:adeptus-astartes:eliminator-squad"
const OUTRIDER_SQUAD_ID := "40kdc:11e:adeptus-astartes:outrider-squad"
const RAVENWING_DARKSHROUD_ID := "40kdc:11e:adeptus-astartes:ravenwing-darkshroud"
const LAND_SPEEDER_ID := "40kdc:11e:adeptus-astartes:land-speeder"
const LAND_SPEEDER_VENGEANCE_ID := "40kdc:11e:adeptus-astartes:land-speeder-vengeance"
const BAAL_PREDATOR_ID := "40kdc:11e:adeptus-astartes:baal-predator"
const PREDATOR_DESTRUCTOR_ID := "40kdc:11e:adeptus-astartes:predator-destructor"
const PREDATOR_ANNIHILATOR_ID := "40kdc:11e:adeptus-astartes:predator-annihilator"
const HELLBLASTER_SQUAD_ID := "40kdc:11e:adeptus-astartes:hellblaster-squad"
const ASSAULT_INTERCESSOR_SQUAD_ID := "40kdc:11e:adeptus-astartes:assault-intercessor-squad"
const HEAVY_INTERCESSOR_SQUAD_ID := "40kdc:11e:adeptus-astartes:heavy-intercessor-squad"
const INCEPTOR_SQUAD_ID := "40kdc:11e:adeptus-astartes:inceptor-squad"
const INVADER_ATV_ID := "40kdc:11e:adeptus-astartes:invader-atvs"
const REIVER_SQUAD_ID := "40kdc:11e:adeptus-astartes:reiver-squad"
const SCOUT_SQUAD_ID := "40kdc:11e:adeptus-astartes:scout-squad"
const NECRON_WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const CANOPTEK_MACROCYTES_ID := "40kdc:11e:necrons:canoptek-macrocytes"
const CANOPTEK_SPIDERS_ID := "40kdc:11e:necrons:canoptek-spyders"
const CANOPTEK_TOMB_CRAWLERS_ID := "40kdc:11e:necrons:canoptek-tomb-crawlers"
const NECRON_ANNIHILATION_BARGE_ID := "40kdc:11e:necrons:annihilation-barge"
const NECRON_MONOLITH_ID := "40kdc:11e:necrons:monolith"
const SPECS := {
	"crusade-ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"execrator": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"chaplain-grimaldus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"sword-brethren-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"crusader-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_partial_2026_10_30", "max_supported_copies": 6},
	"castellan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"high-marshal-helbrecht": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"marshal": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"emperor-s-champion": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"black-templars-gladiator-lancer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"black-templars-gladiator-reaper": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"black-templars-gladiator-valiant": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"black-templars-impulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"black-templars-repulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"black-templars-repulsor-executioner": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"victrix-honour-guard": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"marneus-calgar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"kor-sarro-khan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"captain-titus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"wardens-of-ultramar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 6, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "source_bounded_local_scope_passed_2026_10_27"},
	"land-raider": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"land-raider-excelsior": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "source_scope": "Warhammer Legends"},
	"land-raider-crusader": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"land-raider-redeemer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"drop-pod": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 4, "validation_status": "tests_passed_local_targeted"},
	"impulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"repulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"repulsor-executioner": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"rhino": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"rhino-primaris": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "source_scope": "Warhammer Legends", "validation_status": "source_bounded_local_scope_passed_2026_10_30"},
	"razorback": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 6, "source_scope": "Warhammer Legends", "validation_status": "source_bounded_local_scope_passed_2026_10_30"},
	"relic-razorback": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 6, "source_scope": "Warhammer Legends", "validation_status": "source_bounded_local_scope_passed_2026_10_30"},
	"hammerfall-bunker": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "source_scope": "Warhammer Legends", "validation_status": "source_bounded_local_rules_passed_placement_partial_2026_10_30"},
	"mastodon": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "source_scope": "Warhammer Legends", "validation_status": "source_bounded_local_rules_passed_placement_partial_2026_10_30"},
	"company-heroes": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true},
	"outrider-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"gladiator-reaper": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"gladiator-valiant": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"gladiator-lancer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"land-speeder": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"land-speeder-vengeance": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"ravenwing-darkshroud": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"azrael": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"belial": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"ezekiel": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"lion-eljonson": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"sammael": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"ravenwing-command-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"nephilim-jetfighter": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"ravenwing-dark-talon": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"deathwing-knights": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"deathwing-terminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"ravenwing-black-knights": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"inner-circle-companions": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"asmodai": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"lazarus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"invader-atvs": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"storm-speeder-hammerstrike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"storm-speeder-hailstrike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"storm-speeder-thunderstrike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"infiltrator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["70dc-ed18-2788-b35a"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"assault-intercessors-with-jump-packs": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"captain-with-jump-pack": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"vanguard-veteran-squad-with-jump-packs": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"vanguard-veteran-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"chaplain-with-jump-pack": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"lieutenant-in-phobos-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["fe0e-6070-e7b-d4b8"], "current_reference": true, "validation_status": "tests_passed_local_targeted", "inactive_in_admitted_formations": ["scouts-6", "deep-strike"]},
	"lieutenant-with-combi-weapon": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"techmarine": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"roboute-guilliman": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"captain-in-gravis-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["1d56-1cc3-de57-10e2"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed"},
	"tor-garadon": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"darnath-lysander": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"suboden-khan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"iron-father-feirros": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"caanok-var": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"chief-librarian-tigurius": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"kayvaan-shrike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"cato-sicarius": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"ancient-in-terminator-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["fc7f-8176-c10c-ca8"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"captain-in-terminator-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["dc24-dd64-5d97-df3c"], "current_reference": true},
	"chaplain-in-terminator-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["c026-b762-d0a6-5ef1"], "current_reference": true},
	"apothecary": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["8a9d-11f-fad-bd0f"], "current_reference": true},
	"ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["6562-d718-b8e0-c457"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"bladeguard-ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["9ca5-e5f4-f85d-bcca"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"bladeguard-veteran-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["7044-bf1-f949-c32d"], "current_reference": true},
	"judiciar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["8dcb-987c-1ab4-b976"], "current_reference": true},
	"chaplain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["ceb5-55c7-2d49-d952"], "current_reference": true},
	"chaplain-on-bike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"captain-on-bike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"adrax-agatone": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"kaius-konorius": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"sternguard-veteran-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["907f-11-c4d1-ec21"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"eliminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["d6c3-e9d2-430d-6c2f"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"eradicator-squad-with-melta-rifles": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"eradicator-squad-with-heavy-bolters": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["3bc7-8328-a080-3958"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"apothecary-biologis": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["c6e9-c0c8-5f13-5771"], "current_reference": true},
	"aggressor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["129d-2da5-66f3-f4ec"], "current_reference": true},
	"infernus-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["b007-fc7b-8e4a-b017"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"hellblaster-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["7102-b3a4-9bfc-1b84"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["8da0-4570-c3c-819f"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 4},
	"terminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["4808-a80b-309a-7933", "80ad-6e62-65e3-e667"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"terminator-assault-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"librarian-in-terminator-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"librarian-in-phobos-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"librarian": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"aethon-shaan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"captain-in-phobos-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"scout-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"scout-bike-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"incursor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"reiver-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"firestrike-servo-turrets": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"tarantula-air-defence-battery": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"tarantula-sentry-battery": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"rapier-carrier": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"centurion-devastator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"centurion-assault-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"vindicator": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"predator-annihilator": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"predator-destructor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"whirlwind": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"stormhawk-interceptor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"stormtalon-gunship": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"cerberus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"typhon": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"falchion": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"venerable-dreadnought-legends": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_30", "max_supported_copies": 3, "source_scope": "Warhammer Legends"},
	"ballistus-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"redemptor-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"brutalis-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"invictor-tactical-warsuit": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"desolation-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"necron-warriors": {"faction": "Necrons", "folder": "necrons", "models": 10, "template": 2,
		"aliases": ["58e9-5212-f5a6-c12d"], "gun": ["gauss-flayer", "Gauss flayer"], "blade": ["close-combat-weapon", "Close combat weapon"],
		"current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000000534", "source_name": "Necron Warriors", "source_scope": "Necrons App v1.2", "construction_model_sizes": [10, 20], "max_supported_copies": 4},
	"immortals": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2,
		"aliases": ["f81-b23c-e183-39d7"], "gun": ["gauss-blaster", "Gauss blaster"], "blade": ["close-combat-weapon-immortals", "Close combat weapon"],
		"current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000000535", "source_name": "Immortals", "source_scope": "Necrons App v1.2", "construction_model_sizes": [5, 10]},
	"assault-intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"inceptor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"heavy-intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"lieutenant": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "gun": ["master-crafted-bolter-lieutenant", "Master-crafted Bolter"], "blade": ["ceramite-fists-lieutenant", "Ceramite Fists"]},
	"vulkan-hestan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"royal-warden": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 2, "aliases": [], "gun": ["relic-gauss-blaster", "Relic gauss blaster"], "blade": ["close-combat-weapon-royal-warden", "Close combat weapon"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000002350", "source_name": "Royal Warden", "source_scope": "Necrons App v1.2"},
	"captain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"blood-angels-captain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"sanguinary-priest": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"baal-predator": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"death-company-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"death-company-marines": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"fortis-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"talonstrike-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"spectrus-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"watch-master": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"watch-captain-artemis": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"indomitor-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"decimus-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_wahapedia_configuration_passed_2026_10_30_points_crosscheck_conflict", "construction_model_sizes": [10], "max_supported_copies": 3},
	"deathwatch-veterans": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"deathwatch-terminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"corvus-blackstar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"blood-claws": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"grey-hunters": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"fenrisian-wolves": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wolf-guard-terminators": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"thunderwolf-cavalry": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wulfen": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wulfen-with-storm-shields": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wolf-scouts": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 6, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wolf-guard-headtakers": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 6, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_partial_2026_10_30", "construction_model_sizes": [6, 12], "max_supported_copies": 3},
	"arjac-rockfist": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"logan-grimnar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"ragnar-blackmane": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"ulrik-the-slayer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"iron-priest": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wolf-guard-battle-leader": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wolf-priest": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"bjorn-the-fell-handed": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"murderfang": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"venerable-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"wulfen-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 3},
	"njal-stormcaller": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_29", "max_supported_copies": 1},
	"death-company-marines-with-jump-packs": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"sanguinary-guard": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"commander-dante": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"the-sanguinor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"mephiston": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"death-company-captain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"death-company-captain-with-jump-pack": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"astorath": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"lemartes": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"overlord": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 2,
		"aliases": [], "gun": ["staff-of-light-overlord", "Ranged"], "blade": ["staff-of-light-overlord", "Melee"], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000523", "source_name": "Overlord", "source_scope": "Necrons App v1.2"},
	"imotekh-the-stormlord": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000522", "source_name": "Imotekh The Stormlord", "source_scope": "Necrons App v1.2"},
	"orikan-the-diviner": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000530", "source_name": "Orikan The Diviner", "source_scope": "Necrons App v1.2"},
	"trazyn-the-infinite": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000532", "source_name": "Trazyn The Infinite", "source_scope": "Necrons App v1.2"},
	"catacomb-command-barge": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000533", "source_name": "Catacomb Command Barge", "source_scope": "Necrons App v1.2"},
	"lychguard": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000536", "source_name": "Lychguard", "source_scope": "Necrons App v1.2"},
	"deathmarks": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2, "aliases": [], "gun": ["synaptic-disintegrator", "Synaptic disintegrator"], "blade": ["close-combat-weapon-deathmarks", "Close combat weapon"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000000537", "source_name": "Deathmarks", "source_scope": "Necrons App v1.2", "construction_model_sizes": [5, 10]},
	"flayed-ones": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2, "aliases": [], "blade": ["flayer-claws", "Flayer claws"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000000538", "source_name": "Flayed Ones", "source_scope": "Necrons App v1.2", "construction_model_sizes": [5, 10]},
	"triarch-praetorians": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000539", "source_name": "Triarch Praetorians", "source_scope": "Necrons App v1.2", "construction_model_sizes": [5, 10]},
	"triarch-stalker": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000540", "source_name": "Triarch Stalker", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"ctan-shard-of-the-nightbringer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000541", "source_name": "C’tan Shard of the Nightbringer", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"ctan-shard-of-the-deceiver": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000542", "source_name": "C’tan Shard of the Deceiver", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"ghost-ark": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000543", "source_name": "Ghost Ark", "source_scope": "Necrons App v1.2"},
	"night-scythe": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000544", "source_name": "Night Scythe", "source_scope": "Necrons App v1.2"},
	"doom-scythe": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000545", "source_name": "Doom Scythe", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"canoptek-wraiths": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000546", "source_name": "Canoptek Wraiths", "source_scope": "Necrons App v1.2"},
	"tomb-blades": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000548", "source_name": "Tomb Blades", "source_scope": "Necrons App v1.2"},
	"canoptek-spyders": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000551", "source_name": "Canoptek Spyders", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1, 2]},
	"monolith": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000552", "source_name": "Monolith", "source_scope": "Necrons App v1.2"},
	"annihilation-barge": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000553", "source_name": "Annihilation Barge", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"doomsday-ark": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "gun": ["doomsday-cannon", "Doomsday cannon"], "blade": ["armoured-bulk", "Armoured bulk"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000000554", "source_name": "Doomsday Ark", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"transcendent-ctan": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000555", "source_name": "Transcendent C’tan", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"tesseract-vault": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000000556", "source_name": "Tesseract Vault", "source_scope": "Necrons App v1.2"},
	"obelisk": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000000557", "source_name": "Obelisk", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"illuminor-szeras": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002092", "source_name": "Illuminor Szeras", "source_scope": "Necrons App v1.2"},
	"plasmancer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002108", "source_name": "Plasmancer", "source_scope": "Necrons App v1.2"},
	"skorpekh-lord": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002109", "source_name": "Skorpekh Lord", "source_scope": "Necrons App v1.2"},
	"skorpekh-destroyers": {"faction": "Necrons", "folder": "necrons", "models": 3, "template": 1, "aliases": [], "blade": ["skorpekh-hyperphase-weapons", "Skorpekh hyperphase weapons"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002110", "source_name": "Skorpekh Destroyers", "source_scope": "Necrons App v1.2", "construction_model_sizes": [3, 6]},
	"cryptothralls": {"faction": "Necrons", "folder": "necrons", "models": 2, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002111", "source_name": "Cryptothralls", "source_scope": "Necrons App v1.2", "construction_model_sizes": [2]},
	"canoptek-reanimator": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000002112", "source_name": "Canoptek Reanimator", "source_scope": "Necrons App v1.2"},
	"canoptek-scarab-swarms": {"faction": "Necrons", "folder": "necrons", "models": 3, "template": 2, "aliases": [], "blade": ["feeder-mandibles", "Feeder mandibles"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000002114", "source_name": "Canoptek Scarab Swarms", "source_scope": "Necrons App v1.2", "construction_model_sizes": [3, 6]},
	"canoptek-doomstalker": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "gun": ["doomsday-blaster", "Doomsday blaster"], "blade": ["doomstalker-limbs", "Doomstalker limbs"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000002115", "source_name": "Canoptek Doomstalker", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"lokhust-heavy-destroyers": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "gun": ["gauss-destructor", "Gauss destructor"], "blade": ["close-combat-weapon-lokhust-heavy", "Close combat weapon"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002116", "source_name": "Lokhust Heavy Destroyers", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1, 2, 3]},
	"lokhust-lord": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002351", "source_name": "Lokhust Lord", "source_scope": "Necrons App v1.2"},
	"technomancer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002352", "source_name": "Technomancer", "source_scope": "Necrons App v1.2"},
	"psychomancer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002353", "source_name": "Psychomancer", "source_scope": "Necrons App v1.2"},
	"chronomancer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002354", "source_name": "Chronomancer", "source_scope": "Necrons App v1.2"},
	"hexmark-destroyer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "gun": ["enmitic-disintegrator-pistols", "Enmitic disintegrator pistols"], "blade": ["close-combat-weapon-hexmark", "Close combat weapon"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_31", "source_datasheet_id": "000002355", "source_name": "Hexmark Destroyer", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"ctan-shard-of-the-void-dragon": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002357", "source_name": "C’tan Shard of the Void Dragon", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1]},
	"ophydian-destroyers": {"faction": "Necrons", "folder": "necrons", "models": 3, "template": 1, "aliases": [], "blade": ["ophydian-hyperphase-weapons", "Ophydian hyperphase weapons"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002358", "source_name": "Ophydian Destroyers", "source_scope": "Necrons App v1.2", "construction_model_sizes": [3, 6]},
	"lokhust-destroyers": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "gun": ["gauss-cannon", "Gauss cannon"], "blade": ["close-combat-weapon-lokhust", "Close combat weapon"], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000002359", "source_name": "Lokhust Destroyers", "source_scope": "Necrons App v1.2", "construction_model_sizes": [1, 2, 3, 6]},
	"the-silent-king": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002360", "source_name": "The Silent King", "source_scope": "Necrons App v1.2"},
	"convergence-of-dominion": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000002361", "source_name": "Convergence Of Dominion", "source_scope": "Necrons App v1.2"},
	"overlord-with-translocation-shroud": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000003693", "source_name": "Overlord with translocation shroud", "source_scope": "Necrons App v1.2"},
	"canoptek-macrocytes": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000004176", "source_name": "Canoptek Macrocytes", "source_scope": "Necrons App v1.2", "construction_model_sizes": [5]},
	"canoptek-tomb-crawlers": {"faction": "Necrons", "folder": "necrons", "models": 2, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_11_12", "source_datasheet_id": "000004177", "source_name": "Canoptek Tomb Crawlers", "source_scope": "Necrons App v1.2", "construction_model_sizes": [2]},
	"geomancer": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000004178", "source_name": "Geomancer", "source_scope": "Necrons App v1.2"},
	"nekrosor-ammentar": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "implemented_local_checks_pending", "source_datasheet_id": "000004186", "source_name": "Nekrosor Ammentar", "source_scope": "Necrons App v1.2"}}

static func weapon(unit: Dictionary, choice: Array) -> Dictionary:
	for item: Dictionary in unit.get("source_weapon_definitions", []):
		if item.id != choice[0]: continue
		for profile: Dictionary in item.profiles:
			if profile.name != choice[1]: continue
			var stats: Dictionary = profile.stats
			return {"name": item.name + " / " + profile.name, "attacks": stats.get("A"), "skill": stats.get("BS", stats.get("WS")),
				"strength": stats.get("S"), "ap": stats.get("AP"), "damage": stats.get("D"), "range_inches": profile.get("range"),
				"keywords": Attacks.Traits.import_profile(profile)}
	return {}

static func canonical_id(faction: String, identity: String) -> String:
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		for alias: String in spec.get("aliases", []):
			if identity == "openhammer:11e:%s:%s" % [faction.uri_encode(), alias]: return "40kdc:11e:%s:%s" % [spec.folder, source]
	return identity

static func current_reference_profile(faction: String, source: String) -> Dictionary:
	if faction == "Space Marines": return CurrentMarines.profile(source)
	if faction == "Necrons": return CurrentNecrons.profile(source)
	return {}

static func current_reference_digest(faction: String) -> String:
	if faction == "Space Marines": return CurrentMarines.digest()
	if faction == "Necrons": return CurrentNecrons.digest()
	return ""

static func standard_unit_copy_limit(category: String, keywords: Array) -> int:
	if not STANDARD_COPY_LIMITS.has(category): return 0
	if "EPIC HERO" in keywords: return 1
	var limit := int(STANDARD_COPY_LIMITS[category])
	if "BATTLELINE" in keywords or "DEDICATED TRANSPORT" in keywords: limit *= 2
	return limit

static func local_copy_limit(profile: Dictionary, spec: Dictionary) -> int:
	var keywords: Array = profile.get("keywords", [])
	var repeated_category := "BATTLELINE" in keywords or "DEDICATED TRANSPORT" in keywords
	return int(spec.get("max_supported_copies", profile.get("max_supported_copies", 6 if repeated_category else 3)))

static func current_catalog_choice(unit: Dictionary) -> Dictionary:
	var faction := str(unit.get("faction", ""))
	if unit.get("edition", "") != "11e" or faction not in ["Space Marines", "Necrons"]: return {}
	var identity := canonical_id(faction, str(unit.get("id", "")))
	var source := identity.get_slice(":", 3)
	if identity != "40kdc:11e:%s:%s" % [str(SPECS.get(source, {}).get("folder", "")), source]: return {}
	if not SPECS.get(source, {}).get("current_reference", false) or str(SPECS[source].faction) != faction: return {}
	if SPECS[source].get("validation_status", "") in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]: return {}
	var profile := current_reference_profile(faction, source)
	if profile.is_empty(): return {}
	if not profile.get("unsupported_abilities", []).is_empty() or not profile.get("unsupported_weapon_rules", []).is_empty(): return {}
	for option: Dictionary in profile.get("source_options", []):
		if not option.get("implemented", false): return {}
	var result := unit.duplicate(true)
	result.id = identity
	result.name = profile.name
	result.source_digest = current_reference_digest(faction)
	result.options = []
	var source_points: Dictionary = profile.get("source_roster_points", profile)
	var source_sizes: Dictionary = source_points.get("points_by_models", profile.points_by_models)
	var second_sizes: Dictionary = source_points.get("second_plus_points_by_models", profile.get("second_plus_points_by_models", {}))
	var third_sizes: Dictionary = source_points.get("third_plus_points_by_models", profile.get("third_plus_points_by_models", {}))
	var fourth_sizes: Dictionary = source_points.get("fourth_plus_points_by_models", profile.get("fourth_plus_points_by_models", {}))
	for models: int in construction_model_sizes(source, profile):
		var option := {"models": models, "cost": source_sizes[models]}
		if second_sizes.has(models): option.second_plus_cost = second_sizes[models]
		if third_sizes.has(models): option.third_plus_cost = third_sizes[models]
		if fourth_sizes.has(models): option.fourth_plus_cost = fourth_sizes[models]
		result.options.append(option)
	if profile.has("composition_options"):
		var allowed_sizes := construction_model_sizes(source, profile)
		result.composition_options = profile.composition_options.filter(func(option: Dictionary) -> bool: return int(option.get("models", -1)) in allowed_sizes)
	var readiness_note := construction_readiness_note(source)
	if not readiness_note.is_empty():
		result.construction_scope = readiness_note
		result.scope = readiness_note
	return result

static func construction_readiness_note(source: String) -> String:
	match source:
		"annihilation-barge":
			return "Necrons App v1.2 local export: the one-model profile costs 100 points and has a 60 mm flying base. Its Gauss cannon can be replaced by a Tesla cannon; the twin Tesla destructor and Armoured bulk remain. Reanimation Protocols, Deadly Demise 1 and Malevolent Arcing are bound to the current Annihilation Barge. Malevolent Arcing rolls for its selected target and each other enemy unit within 3 inches; each 5+ unit suffers a separate D3 mortal-wound packet after the Barge resolves attacks against that target. The defender allocates each packet through mortal-wound prevention. Full Necron roster legality remains separate."
		"transcendent-ctan":
			return "Necrons App v1.2 local export: the one-model profile costs 340 points for the first copy and 360 points for each additional copy, on a 60 mm flying base. Seismic assault and Crackling tendrils are fixed. Reanimation Protocols, Deadly Demise D6, Deep Strike, Feel No Pain 5+, Necrodermis, ENSLAVED STAR GOD, C’TAN SHARD and Transdimensional Displacement are bound to the current Transcendent C’tan. C’TAN SHARD forbids Enhancements; ENSLAVED STAR GOD forbids Warlord selection. Transdimensional Displacement is a special Advance with no distance cap that may pass through models and must finish more than 8 inches from every enemy unit. Full Necron roster legality remains separate."
		"cryptothralls":
			return "Necrons App v1.2 local export: the two-model profile costs 60 points on 32 mm bases with Scouring eye and Scythed limbs. Reanimation Protocols, Bound Creation, Systematic Vigour and Cryptek Retinue are bound to the current Cryptothralls. Bound Creation grants Feel No Pain 4+ to a Cryptek that shares the unit. Systematic Vigour lets a Cryptothrall destroyed by a melee attack before it has fought remain on a 2+ to fight after the attacking unit finishes, then be removed. Cryptek Retinue joins a Cryptek-led bodyguard at Declare Battle Formations and cannot share that unit with Canoptek Tomb Crawlers or another Cryptothralls unit. Full Necron roster legality remains separate."
		"obelisk":
			return "Necrons App v1.2 local export: the one-model profile costs 280 points for the first copy and 310 points for each additional copy, on a labelled 92 mm circle for its 120 x 92 mm flying base. Four Tesla spheres and Armoured bulk are fixed. Reanimation Protocols, Deadly Demise D6, Deep Strike, Gravitic Pulse and Damaged 8 are bound to the current Obelisk. Gravitic Pulse at the start of the opponent's Movement phase halves Move and Advance/Charge rolls until the end of that turn, and marked FLY units take D3 mortal wounds on a 4+ after ending moves until the Obelisk owner's next Movement phase. Full Necron roster legality remains separate."
		"triarch-stalker":
			return "Necrons App v1.2 local export: the one-model profile costs 110 points for each of the first two copies and 120 points from the third copy. Heat ray (dispersed/focused) and Stalker's forelimbs are default; the per-copy particle shredder and heavy gauss cannon array replacements are saved. Deadly Demise D3, Scouts 8, Reanimation Protocols and Targeting Relay are bound to the current Triarch Stalker. After its Shooting attacks, Targeting Relay selects one hit enemy unit so it cannot have the Benefit of Cover for the rest of the phase. The source says Use model; runtime uses a labelled 120 mm circular proxy. Full Necron roster legality remains separate."
		"triarch-praetorians":
			return "Necrons App v1.2 local export: the 5/10-model profiles cost 80/160 points on 32 mm bases with Rod of covenant. Deep Strike, Reanimation Protocols and Relentless Combatants are bound to the current Triarch Praetorians. Relentless Combatants lets the unit re-roll Charge rolls and remain eligible to declare a charge after Falling Back. The per-model Particle Caster and Voidblade replacements are saved. Full Necron roster legality remains separate."
		"lokhust-destroyers":
			return "Necrons App v1.2 local export: priced 1/2/3/6-model profiles cost 40/55/80/190 for the first two copies and 70/85/110/220 from the third copy. Gauss cannon and close combat weapon are fixed. Reanimation Protocols and Hard-wired for Destruction are bound to the current Lokhust Destroyers. Hard-wired re-rolls Hit rolls of 1 against the closest eligible enemy, or all Hit rolls when that target is within range of an objective marker the opponent controls. Unpriced 4- and 5-model sizes remain gated. Full Necron roster legality remains separate."
		"lokhust-heavy-destroyers":
			return "Necrons App v1.2 local export: priced 1/2/3-model profiles cost 50/100/165 for the first two copies and 60/110/175 from the third copy. Gauss destructor is default; any model may replace it with an Enmitic exterminator. Reanimation Protocols and Optimised for Slaughter are bound to the current Lokhust Heavy Destroyers. Optimised re-rolls Wound rolls of 1 for Enmitic exterminator attacks against non-MONSTER/VEHICLE targets, and for Gauss destructor attacks against MONSTER or VEHICLE targets. Full Necron roster legality remains separate."
		"ophydian-destroyers":
			return "Necrons App v1.2 local export: priced 3/6-model profiles cost 80/150 for the first two copies and 90/160 from the third copy on 50 mm bases. Ophydian hyperphase weapons are fixed. Deep Strike, Reanimation Protocols, Plasmacyte and Tunnelling Horrors are bound to the current Ophydian Destroyers. The unit starts with one Plasmacyte token per three models; when selected to fight it may spend one token once per battle per token to give its melee weapons Devastating Wounds for the phase. At the end of the opponent's Fight phase an unengaged unit may enter Strategic Reserves and must ingress in its next Movement phase, including battle round 1. Full Necron roster legality remains separate."
		"skorpekh-destroyers":
			return "Necrons App v1.2 local export: priced 3/6-model profiles cost 85/170 for the first two copies and 95/180 from the third copy on 50 mm bases. Skorpekh hyperphase weapons are fixed. Reanimation Protocols, Plasmacyte and Whirling Onslaught are bound to the current Skorpekh Destroyers. The unit starts with one Plasmacyte token per three models; when selected to fight it may spend one token once per battle per token to give its melee weapons Devastating Wounds for the phase. Whirling Onslaught re-rolls melee Hit rolls of 1, or the Hit roll if the unit charged this turn. Full Necron roster legality remains separate."
		"doomsday-ark":
			return "Necrons App v1.2 local export: the one-model profile costs 200 points for each of the first two copies and 230 points from the third copy. It has a doomsday cannon, two gauss flayer arrays, armoured bulk and a 4+ invulnerable save on a 60 mm flying base. Deadly Demise D3, Reanimation Protocols, Overwhelming Obliteration and Damaged 5 are bound to the current Doomsday Ark. Overwhelming Obliteration gives the doomsday cannon Devastating Wounds until the end of the turn when the model Remains Stationary in its Movement phase. While the model has 1-5 wounds remaining, each of its attacks subtracts 1 from the Hit roll. Full Necron roster legality remains separate."
		"canoptek-doomstalker":
			return "Necrons App v1.2 local export: the one-model profile costs 130 points. It has a doomsday blaster, twin gauss flayer, Doomstalker limbs and a 4+ invulnerable save. Deadly Demise D3, Reanimation Protocols, Sentinel Construct and Damaged 4 are bound to the current Canoptek Doomstalker. Sentinel Construct scores Overwatch hits on unmodified 5+. While the model has 1-4 wounds remaining, each of its attacks subtracts 1 from the Hit roll. Full Necron roster legality remains separate."
		"hexmark-destroyer":
			return "Necrons App v1.2 local export: the one-model profile costs 75 points. Enmitic disintegrator pistols use the project's close-quarters shooting keyword for the local Pistol rule, plus Ignores Cover. Deep Strike, Lone Operative, Reanimation Protocols, Inescapable Death and Multi-threat Eliminator are bound to the current Hexmark Destroyer. Inescapable Death lets one such unit use Fire Overwatch for 0CP once per turn, including after another unit has used that Stratagem this phase, and its Overwatch hits on unmodified 2+. Multi-threat Eliminator is an optional shot after an enemy unit shoots a friendly Necrons unit within 3 inches. Full Necron roster legality remains separate."
		"canoptek-scarab-swarms":
			return "Necrons App v1.2 local export: the 3/6-model profiles cost 40/80 points, with no separate later-copy price. Every model has feeder mandibles. Reanimation Protocols, Self-destruction and Chittering Swarm are bound to current sourced Scarab Swarms. Self-destruction is optional at the start of the Fight phase. Chittering Swarm reduces an engaged enemy model's Objective Control by 1 per Scarab unit, to a minimum of 1, and sets this unit's Objective Control to 1 while a friendly Cryptek is within 6 inches. Full Necron roster legality remains separate."
		"flayed-ones":
			return "Necrons App v1.2 local export: the 5/10-model profiles cost 55/100 points, with no separate later-copy price. Every model has flayer claws. Infiltrators, Stealth, Reanimation Protocols and Flesh Hunger are bound to current sourced Flayed Ones. Flesh Hunger makes each successful melee Hit a Critical Hit while the target is Below Half-strength. Full Necron roster legality remains separate."
		"immortals":
			return "Necrons App v1.2 local export: the 5/10-model profiles cost 65/130 points; any number of Gauss blasters can be replaced per model with Tesla carbines. Reanimation Protocols and Implacable Eradication are bound to current sourced Immortals; against an objective-range target, the ability offers an optional re-roll of any Wound die. Current event-pack cost reconciliation and full Necron roster legality remain separate."
		"necron-warriors":
			return "Necrons App v1.2 local export: the 10/20-model profiles cost 85/190 points and allow any number of Gauss Flayers to be replaced with Gauss Reapers. Reanimation Protocols, Their Number is Legion and source-listed Leader/Support links are represented. Current event-pack cost reconciliation and full Necron roster legality remain separate."
		"canoptek-reanimator":
			return "Necrons App v1.2 local export: the fixed one-model/75-point profile includes two Atomiser beams, Reanimator's claws, model-only Feel No Pain 4+, Reanimation Protocols and the once-per-unit 3-inch Nanoscarab Reanimation Beam. The local checks cover its own-unit Aura, non-stacking, Reanimation and prevention behavior; full Necron roster legality remains separate."
		"crusader-squad":
			return "Wahapedia e11 points (runtime): 10 models/160 pts; 20/305. Current GW MFM v1.0 lists 10/150 and 20/290; confirm the roster cost with your opponent or event. Righteous Zeal uses validated Surge routes, but route candidates and whole-squad coherency search are bounded; some legal placements on complex terrain may be missed."
		"decimus-kill-team":
			return "Wahapedia e11 runtime configuration: 10 models for 210 pts. Current GW MFM v1.0 lists 10 models for 190 pts; confirm the roster cost with your opponent or event. The 5-model/110-point row is blocked because it cannot satisfy the six-model minimum: the sheet requires one Sergeant, one Xenophase Veteran and at least one of each of four specialist roles."
		"land-raider-excelsior":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each one-model copy at 250 points. The four optional weapons, all Combi-weapon profiles, 12-space transport with Centurion occupancy, Damaged 5, Deadly Demise D6, Combat Doctrines and Rites of Battle are represented. The source says Use model without defining a footprint; the simulation uses a labelled 60 mm circle proxy, so exact physical clearance is not certified."
		"rhino-primaris":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each one-model copy at 95 points. The 6-model Transport capacity and restrictions, Twin Plasma Gun, optional One Shot Hunter-killer Missile, Combat Doctrines, Deadly Demise D3, Self-repair and Orbital Comms Array are represented. The source says Use model without defining a footprint; the simulation uses a labelled 120 mm circle proxy, so exact physical hull clearance is not certified."
		"razorback":
			return "Warhammer Legends: permitted by project policy for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each copy at 95 points. The standard Dedicated Transport repetition limit permits up to 4 copies in Incursion or 6 in Strike Force. Its 6-model capacity, Infantry restrictions, Twin Heavy Bolter/Twin Lascannon choice, optional Hunter-killer Missile and Storm Bolter, Fire Support, Combat Doctrines and Deadly Demise D3 are represented. The source says Use model; the labelled 120 mm circle is an interaction proxy and does not certify exact hull clearance."
		"relic-razorback":
			return "Warhammer Legends: permitted by project policy for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each copy at 105 points. The standard Dedicated Transport repetition limit permits up to 4 copies in Incursion or 6 in Strike Force. Its 6-model capacity, Infantry restrictions, all four primary-weapon choices, optional Hunter-killer Missile and Storm Bolter, Fire Support, Combat Doctrines and Deadly Demise D3 are represented. The export misspells the ability name as Fire Supprt; the matching description is normalized for runtime lookup. The source says Use model; the labelled 120 mm circle is an interaction proxy and does not certify exact hull clearance."
		"hammerfall-bunker":
			return "Warhammer Legends: permitted by project policy for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each one-model copy at 175 points; the standard non-Battleline repetition limit is 2 copies in Incursion or 3 in Strike Force. Both launcher profiles, the Heavy Bolter/Heavy Flamer replacement, Damaged 5, Deadly Demise D6, Combat Doctrines, Ceramite Cover, Defensive Array and Fortification target/Fall Back effects are represented. The source says Use model without dimensions; a labelled 120 mm circle interaction proxy is used, so exact placement and clearance are not certified."
		"mastodon":
			return "Warhammer Legends: permitted by the project's local game-mode policy for home, store, club and campaign games; competitive events require organiser approval. Wahapedia prices each one-model copy at 540 points. All seven source weapon profiles and both independent three-choice replacement groups are represented. Its 45-space transport accepts up to two of the eight currently catalogued Dreadnought datasheet identities, each using its W characteristic in capacity; Jump Pack, Gravis and Terminator models count twice and Centurions three times. Damaged 10 and Inviolable Transport pass focused local checks; the Mastodon profile carries Deadly Demise 2D6, whose full resolution is still pending. The export says Use model without hull dimensions; the labelled 60 mm circle is only an interaction-test proxy and does not certify Mastodon placement or clearance."
		"scout-bike-squad":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. Source-priced 3/6-model formations cost 75/150 points, with two copies in Incursion and three in Strike Force. All listed Scout Biker Sergeant replacements, per-model Grenade Launchers, Scouts 9 and Outflank are represented. The source specifies 75 x 25 mm oval bases; the simulation uses a labelled 75 mm bounding-circle proxy, so exact oval clearance is not certified."
		"wolf-guard-headtakers":
			return "Partial source reconciliation: 3 Headtakers + 3 Hunting Wolves (6 models, 115 pts) and 6+6 (12 models, 230 pts) are selectable. The sheet requires 3–6 of each role; Headtakers-only price rows conflict, and other allowed mixes have no confirmed cost."
		"tarantula-air-defence-battery":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source says Use model without defining a footprint; the game uses a 60 mm circle proxy, so exact physical clearance is not certified."
		"tarantula-sentry-battery":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source says Use model without defining a footprint; the game uses a 60 mm circle proxy for each battery, so exact physical clearance is not certified."
		"rapier-carrier":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source says Use model without defining a footprint; the game uses a 60 mm circle proxy, so exact physical clearance is not certified."
		"centurion-devastator-squad":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The exact 50 mm base, 3- and 6-model costs, all per-model ranged replacements and Decimator Protocols are represented."
		"centurion-assault-squad":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The exact 50 mm base, 3- and 6-model costs, per-model Centurion Assault Launcher and Twin Meltagun options, EXPLOSIVES bearer keyword and Annihilator Protocols are represented."
		"vindicator":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 185-point first-two and 200-point third-plus prices, optional Hunter-killer Missile and Storm Bolter, Damaged 4, Deadly Demise D3 and Siege Shield are represented. The source gives no model footprint diameter; the simulation uses a labelled 60 mm circle proxy."
		"predator-annihilator":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 135-point first-two and 145-point third-plus prices, both sponson loadouts, optional Hunter-killer Missile and Storm Bolter, Annihilator damage re-rolls, Damaged 4 and Deadly Demise D3 are represented. The source gives no model footprint diameter; the simulation uses a labelled 60 mm circle proxy."
		"predator-destructor":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 140-point first-two and 150-point third-plus prices, both sponson loadouts, optional Hunter-killer Missile and Storm Bolter, Destructor AP bonus against INFANTRY, Damaged 4 and Deadly Demise D3 are represented. The source gives no model footprint diameter; the simulation uses a labelled 60 mm circle proxy."
		"whirlwind":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The one-model profile uses 175 points for the first unit and 195 points for each additional copy, with the optional Hunter-killer Missile and Storm Bolter, Indirect Fire, Blast 2, Punishing Bombardment, Damaged 4 and Deadly Demise D3 represented. The source says Use model without defining a footprint; the simulation uses a labelled 60 mm circle proxy."
		"stormhawk-interceptor":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 155-point one-model profile, all weapon profiles, both replacement options, Anti-Fly 2+, Interceptor, Combat Doctrines and Deadly Demise D3 are represented. The source specifies a 120 x 92 mm oval; the simulation uses a labelled 60 mm bounding-circle proxy, so exact physical base clearance is not certified."
		"stormtalon-gunship":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 165-point one-model profile, all weapons, all three Skyhammer replacements, Strafing Run, Combat Doctrines and Deadly Demise D3 are represented. The source specifies a 120 x 92 mm oval; the simulation uses a labelled 60 mm bounding-circle proxy, so exact physical base clearance is not certified."
		"cerberus":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source-priced 270-point profile, all seven weapon profiles, both independent optional-weapon groups, Deadly Demise D6 and the stationary Atomantic Arc-reactor effect are represented. The source says Use model without defining a footprint; the simulation uses a labelled 60 mm circle proxy, so exact physical clearance is not certified."
		"dreadnought":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source-priced 135-point profile, exact 60 mm base, all ranged and melee profiles, three equipment choices with their shared-weapon dependency, Combat Doctrines, Deadly Demise 1 and the 6-inch Wisdom of the Ancients aura are represented."
		"typhon":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The source-priced 320-point profile, full weapon options, Damaged 6, Deadly Demise D6, Combat Doctrines and Sunderer of Fortresses are represented; the source says Use model, so the runtime uses a labelled 60 mm circular footprint proxy."
		"falchion":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 420-point profile, all source weapon profiles and replacement choices, Damaged 8, Deadly Demise D6+2, Combat Doctrines and Titan-killer are represented. The source says Use model; the simulation uses a labelled 60 mm circle proxy, so exact physical clearance is not certified."
		"venerable-dreadnought-legends":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. This is the separate 165-point Space Marines Legends datasheet, with the source-listed 60 mm base and all 32 combinations of its two independent weapon replacement groups. The similarly named Space Wolves profile is a distinct datasheet. Deadly Demise 1, Combat Doctrines and Wisdom of the Ancients are represented."
		"vanguard-veteran-squad":
			return "Warhammer Legends: legal for home, store, club and campaign games; competitive events require organiser approval. The 5/10-model costs, exact 32 mm bases, Scouts 6, all five Bolt Pistol replacements, the 4+ Storm Shield and charge-triggered melee Lethal Hits are represented."
	return ""

static func construction_model_sizes(source: String, profile: Dictionary = {}) -> Array[int]:
	var spec: Dictionary = SPECS.get(source, {})
	var current := profile if not profile.is_empty() else current_reference_profile(str(spec.get("faction", "")), source)
	var points: Dictionary = current.get("points_by_models", {})
	var candidates: Array = spec.get("construction_model_sizes", points.keys())
	var result: Array[int] = []
	for candidate: Variant in candidates:
		var models := int(candidate)
		if points.has(models) and models not in result: result.append(models)
	result.sort()
	return result

static func resolve(faction: String, identity: String, prefer_current_reference: bool = true) -> Dictionary:
	identity = canonical_id(faction, identity)
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		var canonical := "40kdc:11e:%s:%s" % [spec.folder, source]
		if identity != canonical: continue
		if spec.get("current_reference", false) and prefer_current_reference:
			if spec.get("validation_status", "") in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]: return {"error": "Local validation pending for current profile: " + source}
			var current := current_reference_profile(faction, source)
			if current.is_empty(): return {"error": "Missing current %s profile: %s" % [faction, source]}
			var unit := {"id": canonical, "name": current.name, "stats": current.stats.duplicate(true), "keywords": current.keywords.duplicate(), "base": {"shape": "circle", "radius_inches": current.base_radius_inches}}
			var gun: Dictionary = current.ranged[0].profiles.values()[0].duplicate(true) if not current.ranged.is_empty() else {}
			var blade: Dictionary = current.melee[0].profiles.values()[0].duplicate(true) if not current.melee.is_empty() else {}
			if source in ["canoptek-doomstalker", "doomsday-ark", "doom-scythe", "monolith"]:
				var expanded_ranged: Array = []
				for ranged_weapon: Dictionary in current.ranged:
					var copies := maxi(1, int(ranged_weapon.get("count", 1)))
					for copy_index in copies:
						var ranged_copy: Dictionary = ranged_weapon.duplicate(true)
						ranged_copy.erase("count")
						if copies > 1: ranged_copy.id = "%s-%d" % [str(ranged_weapon.get("id", "weapon")), copy_index + 1]
						expanded_ranged.append(ranged_copy)
				unit.fixed_ranged_weapons = expanded_ranged
			unit.source_scope = str(current.get("source_scope", ""))
			return {"error": "", "unit": unit, "spec": spec, "cost": current.points, "models": current.models,
				"weapons": {"gun": gun, "blade": blade}, "uses_current_reference": true,
				"pack_hash": current_reference_digest(faction), "unsupported_abilities": current.get("unsupported_abilities", []).duplicate(),
				"unsupported_weapon_rules": current.get("unsupported_weapon_rules", []).duplicate(), "requires_current_abilities": true}
		var pack := Pack.load_pack(DIRECTORY.path_join(spec.folder))
		if not pack.error.is_empty(): return pack
		for unit: Dictionary in pack.units:
			if unit.id != canonical: continue
			if not unit.get("base") is Dictionary or unit.base.get("shape") != "circle": return {"error": "Unresolved base geometry: " + source}
			for key: String in ["movement_inches", "toughness", "save_target", "wounds", "leadership_target", "objective_control"]:
				if not Roster.integer(unit.stats.get(key), 1): return {"error": "Unresolved characteristic: " + source + "/" + key}
				unit.stats[key] = int(unit.stats[key])
			var invulnerable: Variant = unit.stats.get("invulnerable_target", 0)
			if invulnerable == null: invulnerable = 0
			if not Roster.integer(invulnerable, 0, 6) or int(invulnerable) not in [0, 2, 3, 4, 5, 6]: return {"error": "Unresolved invulnerable save: " + source}
			unit.stats.invulnerable_target = int(invulnerable)
			var cost := 0
			for price: Dictionary in unit.get("points", []):
				if price.get("models") == spec.models and not price.has("unit_count_min") and Roster.integer(price.get("cost"), 1): cost = int(price.cost)
			if cost == 0: return {"error": "Unresolved canonical cost: " + source}
			var weapons: Dictionary = {}
			for key: String in ["gun", "blade", "sergeant"]:
				if not spec.has(key): continue
				var profile := weapon(unit, spec[key])
				if profile.is_empty(): return {"error": "Unresolved default weapon: " + source + "/" + key}
				var issue := Attacks._validate(profile, {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}, {"distance_inches": 0.0, "heavy_eligible": false, "target_model_count": 1, "target_engaged": false})
				if not issue.is_empty(): return {"error": source + ": " + issue}
				weapons[key] = profile
			return {"error": "", "unit": unit, "spec": spec, "cost": cost, "models": spec.models, "weapons": weapons, "uses_current_reference": false,
				"pack_hash": pack.manifest.units_sha256, "unsupported_abilities": unit.get("unsupported_rules", []).duplicate()}
	return {"error": "Unit is not implemented for this faction: " + identity}

static func admit(selection: Variant, unit_cap: int = MAX_SQUADS, roster_context: Dictionary = {}, prefer_current_reference: bool = true) -> Dictionary:
	if not selection is Dictionary or selection.size() != 5 or selection.get("schema_version") != 2: return {"error": "Invalid mixed army selection."}
	if roster_context.size() > 1 or roster_context.has("marine_detachment") and not roster_context.get("marine_detachment") is String: return {"error": "Invalid current Space Marine roster context."}
	for context_key: Variant in roster_context.keys():
		if str(context_key) != "marine_detachment": return {"error": "Unsupported current Space Marine roster context: " + str(context_key)}
	var marine_detachment := str(roster_context.get("marine_detachment", "none"))
	if not selection.get("faction") is String or not selection.get("category") is String or selection.category not in Roster.LIMITS: return {"error": "Invalid army identity or category."}
	if not Roster.integer(selection.get("points_limit"), 100, 100000) or (selection.category != "custom" and selection.points_limit != Roster.LIMITS[selection.category]): return {"error": "Category and points limit do not match."}
	if not Roster.integer(unit_cap, 1, 24): return {"error": "Invalid army unit cap."}
	if not selection.get("entries") is Array or selection.entries.is_empty() or selection.entries.size() > unit_cap: return {"error": "Choose 1–%d supported units per army." % unit_cap}
	var counts: Dictionary = {}
	var definitions: Dictionary = {}
	var configurations: Dictionary = {}
	var sheet_counts: Dictionary = {}
	var pricing: Dictionary = {}
	var priced_counts: Dictionary = {}
	var enhancement_counts: Dictionary = {}
	var selected_chapter := ""
	var sheet_epic_hero_counts: Dictionary = {}
	var sheet_repetition_keywords: Dictionary = {}
	for entry: Variant in selection.entries:
		if not entry is Dictionary or entry.size() < 3 or entry.size() > 20 or not entry.get("definition_id") is String or not Roster.integer(entry.get("models"), 1, 20) or not Roster.integer(entry.get("copies"), 1, unit_cap): return {"error": "Invalid mixed army entry."}
		for key: Variant in entry:
			if str(key) not in ["definition_id", "models", "copies", "enhancement_id", "composition_choice_id", "intercessor_sergeant_loadouts", "intercessor_grenade_launcher_loadouts", "intercessor_rifle_choice", "intercessor_melee_choice", "eliminator_sergeant_loadouts", "eliminator_trooper_loadouts", "outrider_loadouts", "ravenwing_darkshroud_loadouts", "land_speeder_loadouts", "land_speeder_vengeance_loadouts", "baal_predator_loadouts", "predator_destructor_loadouts", "predator_annihilator_loadouts", "saved_model_loadouts", "saved_unit_loadouts", "hellblaster_sergeant_pistol_loadouts", "assault_intercessor_sergeant_loadouts", "heavy_intercessor_bolter_loadouts", "inceptor_loadouts", "invader_atv_loadouts", "reiver_loadouts", "aggressor_loadouts", "scout_loadouts", "necron_warrior_loadouts", "immortal_loadouts", "canoptek_macrocytes_loadouts", "canoptek_spyders_loadouts", "canoptek_tomb_crawlers_loadouts", "necron_annihilation_barge_loadouts", "necron_monolith_loadouts"]: return {"error": "Unsupported mixed army entry field: " + str(key)}
		if entry.has("saved_unit_loadouts"):
			if not SavedEquipment.supports_unit(identity_for_saved_entry(selection, entry)) or not entry.saved_unit_loadouts is Array or entry.saved_unit_loadouts.size() != int(entry.copies): return {"error": "Invalid saved unit loadout copies."}
			for equipment: Variant in entry.saved_unit_loadouts:
				if not SavedEquipment.valid_unit(identity_for_saved_entry(selection, entry), equipment): return {"error": "Unsupported saved unit equipment."}
		if entry.has("saved_model_loadouts"):
			if not SavedEquipment.supports(identity_for_saved_entry(selection, entry)) or not entry.saved_model_loadouts is Array or entry.saved_model_loadouts.size() != int(entry.copies): return {"error": "Invalid saved model loadout copies."}
			for equipment: Variant in entry.saved_model_loadouts:
				if not SavedEquipment.valid_saved_loadout(identity_for_saved_entry(selection, entry), equipment, int(entry.models)): return {"error": "Unsupported saved model equipment."}
		if entry.has("enhancement_id") and not entry.enhancement_id is String: return {"error": "Enhancement ID must be a string."}
		if entry.has("composition_choice_id") and (not entry.composition_choice_id is String or entry.composition_choice_id.is_empty() or entry.composition_choice_id.length() > 64): return {"error": "Invalid source-defined unit composition choice."}
		var enhancement_id := str(entry.get("enhancement_id", ""))
		if enhancement_id != "" and int(entry.copies) != 1: return {"error": "Assign an enhancement to one individual unit entry."}
		var identity := canonical_id(selection.faction, entry.definition_id)
		if entry.has("intercessor_sergeant_loadouts"):
			if identity != INTERCESSOR_SQUAD_ID or entry.has("intercessor_rifle_choice") or entry.has("intercessor_melee_choice") or not entry.intercessor_sergeant_loadouts is Array or entry.intercessor_sergeant_loadouts.size() != int(entry.copies): return {"error": "Sergeant equipment choices are supported only for each selected Intercessor Squad copy."}
			for loadout: Variant in entry.intercessor_sergeant_loadouts:
				if not Roster.valid_intercessor_sergeant_loadout(loadout): return {"error": "Invalid Intercessor Sergeant equipment choice."}
		if entry.has("intercessor_grenade_launcher_loadouts"):
			if identity != INTERCESSOR_SQUAD_ID or not entry.intercessor_grenade_launcher_loadouts is Array or entry.intercessor_grenade_launcher_loadouts.size() != int(entry.copies): return {"error": "Intercessor Grenade Launcher choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.intercessor_grenade_launcher_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Intercessor Grenade Launcher choices must match every model."}
				var launcher_count := 0
				for model_index in range(copy_loadouts.size()):
					var equipped: Variant = copy_loadouts[model_index]
					if not equipped is bool or (model_index == 0 and bool(equipped)) or (model_index > 0 and not Roster.valid_model_equipment(identity, model_index, {"intercessor_grenade_launcher": equipped}, int(entry.models))): return {"error": "Only non-Sergeant Intercessors can select the source-listed Grenade Launcher."}
					if equipped: launcher_count += 1
				if launcher_count > int(int(entry.models) / 5.0): return {"error": "An Intercessor unit exceeds its per-five-model Grenade Launcher limit."}
		if entry.has("intercessor_rifle_choice") or entry.has("intercessor_melee_choice"):
			var single_loadout := {"rifle_choice": entry.get("intercessor_rifle_choice", ""), "melee_choice": entry.get("intercessor_melee_choice", "")}
			if identity != INTERCESSOR_SQUAD_ID or entry.has("intercessor_sergeant_loadouts") or not Roster.valid_intercessor_sergeant_loadout(single_loadout): return {"error": "Invalid canonical Intercessor Sergeant equipment choice."}
		if entry.has("eliminator_sergeant_loadouts"):
			if identity != ELIMINATOR_SQUAD_ID or not entry.eliminator_sergeant_loadouts is Array or entry.eliminator_sergeant_loadouts.size() != int(entry.copies): return {"error": "Eliminator Sergeant equipment choices must match each selected Eliminator Squad copy."}
			for weapon_choice: Variant in entry.eliminator_sergeant_loadouts:
				if not weapon_choice is String or not Roster.ELIMINATOR_SERGEANT_WEAPONS.has(weapon_choice): return {"error": "Invalid Eliminator Sergeant ranged weapon choice."}
		if entry.has("eliminator_trooper_loadouts"):
			if identity != ELIMINATOR_SQUAD_ID or not entry.eliminator_trooper_loadouts is Array or entry.eliminator_trooper_loadouts.size() != int(entry.copies): return {"error": "Eliminator trooper equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.eliminator_trooper_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models) - 1: return {"error": "Eliminator trooper equipment choices must match each ordinary model."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or weapon_choice not in ["sniper", "las"]: return {"error": "Ordinary Eliminators can select only a Bolt Sniper Rifle or Las Fusil."}
		if entry.has("necron_warrior_loadouts"):
			if identity != NECRON_WARRIORS_ID or not entry.necron_warrior_loadouts is Array or entry.necron_warrior_loadouts.size() != int(entry.copies): return {"error": "Necron Warrior equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.necron_warrior_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Necron Warrior equipment choices must match every model."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or weapon_choice not in Roster.NECRON_WARRIOR_WEAPONS: return {"error": "Necron Warriors can select only the source-listed Gauss flayer or Gauss reaper."}
		if entry.has("immortal_loadouts"):
			if identity != IMMORTALS_ID or not entry.immortal_loadouts is Array or entry.immortal_loadouts.size() != int(entry.copies): return {"error": "Immortal equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.immortal_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Immortal equipment choices must match every model."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or weapon_choice not in Roster.IMMORTAL_WEAPONS: return {"error": "Immortals can select only the source-listed Gauss blaster or Tesla carbine."}
		if entry.has("canoptek_macrocytes_loadouts"):
			if identity != CANOPTEK_MACROCYTES_ID or not entry.canoptek_macrocytes_loadouts is Array or entry.canoptek_macrocytes_loadouts.size() != int(entry.copies): return {"error": "Canoptek Macrocytes equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.canoptek_macrocytes_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Canoptek Macrocytes equipment choices must match every model."}
				var atomiser_count := 0
				var accelerator_count := 0
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or weapon_choice not in CanoptekMacrocytes.LOADOUTS: return {"error": "Canoptek Macrocytes can select only source-listed model equipment."}
					if weapon_choice == CanoptekMacrocytes.ATOMISER_PROJECTOR: atomiser_count += 1
					if weapon_choice == CanoptekMacrocytes.ACCELERATOR_MANDIBLE: accelerator_count += 1
				if atomiser_count > 1 or accelerator_count > 1: return {"error": "A Canoptek Macrocytes unit can have at most one Atomiser beam + Nanoscarab Projector and one Accelerator Mandible."}
		if entry.has("canoptek_spyders_loadouts"):
			if identity != CANOPTEK_SPIDERS_ID or not entry.canoptek_spyders_loadouts is Array or entry.canoptek_spyders_loadouts.size() != int(entry.copies): return {"error": "Canoptek Spyders equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.canoptek_spyders_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Canoptek Spyders equipment choices must match every model."}
				for model_index in range(copy_loadouts.size()):
					if not Roster.valid_model_equipment(CANOPTEK_SPIDERS_ID, model_index, copy_loadouts[model_index], int(entry.models)): return {"error": "Canoptek Spyders can select only source-listed per-model equipment."}
		if entry.has("canoptek_tomb_crawlers_loadouts"):
			if identity != CANOPTEK_TOMB_CRAWLERS_ID or not entry.canoptek_tomb_crawlers_loadouts is Array or entry.canoptek_tomb_crawlers_loadouts.size() != int(entry.copies): return {"error": "Canoptek Tomb Crawlers equipment choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.canoptek_tomb_crawlers_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Canoptek Tomb Crawlers equipment choices must match every model."}
				var isolator_count := 0
				for model_index in range(copy_loadouts.size()):
					var equipment: Variant = copy_loadouts[model_index]
					if not Roster.valid_model_equipment(CANOPTEK_TOMB_CRAWLERS_ID, model_index, equipment, int(entry.models)): return {"error": "Canoptek Tomb Crawlers can select only the twin gauss reaper or transdimensional isolator."}
					if str(equipment.get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER)) == CanoptekTombCrawlers.ISOLATOR: isolator_count += 1
				if isolator_count > 1: return {"error": "Only one Canoptek Tomb Crawler per unit may equip the transdimensional isolator."}
		if entry.has("necron_annihilation_barge_loadouts"):
			if identity != NECRON_ANNIHILATION_BARGE_ID or not entry.necron_annihilation_barge_loadouts is Array or entry.necron_annihilation_barge_loadouts.size() != int(entry.copies): return {"error": "Annihilation Barge cannon choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.necron_annihilation_barge_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Annihilation Barge cannon choices must match every model."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or not NecronVehicleLoadouts.valid_choice(identity, weapon_choice): return {"error": "Annihilation Barge can select only the source-listed Gauss cannon or Tesla cannon."}
		if entry.has("necron_monolith_loadouts"):
			if identity != NECRON_MONOLITH_ID or not entry.necron_monolith_loadouts is Array or entry.necron_monolith_loadouts.size() != int(entry.copies): return {"error": "Monolith weapon choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.necron_monolith_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Monolith weapon choices must match every model."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or not NecronVehicleLoadouts.valid_choice(identity, weapon_choice): return {"error": "Monolith can select only four Gauss Flux Arcs or four Death Rays."}
		if entry.has("outrider_loadouts"):
			if identity != OUTRIDER_SQUAD_ID or not entry.outrider_loadouts is Array or entry.outrider_loadouts.size() != int(entry.copies): return {"error": "Outrider equipment choices must match each selected unit copy."}
			for copy_loadout: Variant in entry.outrider_loadouts:
				if not Roster.valid_outrider_loadout(copy_loadout, int(entry.models)): return {"error": "Outriders may replace their Sergeant's Chainsword with a Power Weapon or Thunder Hammer and take at most one Plasma Pistol per three models."}
		if entry.has("ravenwing_darkshroud_loadouts"):
			if identity != RAVENWING_DARKSHROUD_ID or int(entry.models) != 1 or not entry.ravenwing_darkshroud_loadouts is Array or entry.ravenwing_darkshroud_loadouts.size() != int(entry.copies): return {"error": "Ravenwing Darkshroud weapon choices must match each selected one-model copy."}
			for weapon_choice: Variant in entry.ravenwing_darkshroud_loadouts:
				if not weapon_choice is String or weapon_choice not in ["heavy-bolter", "assault-cannon"]: return {"error": "Ravenwing Darkshroud can select only the source-listed Heavy Bolter or Assault Cannon."}
		if entry.has("land_speeder_loadouts"):
			if identity != LAND_SPEEDER_ID or int(entry.models) != 1 or not entry.land_speeder_loadouts is Array or entry.land_speeder_loadouts.size() != int(entry.copies): return {"error": "Land Speeder cannon choices must match each selected one-model copy."}
			for weapon_choice: Variant in entry.land_speeder_loadouts:
				if not weapon_choice is String or weapon_choice not in ["onslaught", "pyrecannon"]: return {"error": "Land Speeder can select only the source-listed Onslaught Gatling Cannon or Pyrecannon."}
		if entry.has("land_speeder_vengeance_loadouts"):
			if identity != LAND_SPEEDER_VENGEANCE_ID or int(entry.models) != 1 or not entry.land_speeder_vengeance_loadouts is Array or entry.land_speeder_vengeance_loadouts.size() != int(entry.copies): return {"error": "Land Speeder Vengeance cannon choices must match each selected one-model copy."}
			for weapon_choice: Variant in entry.land_speeder_vengeance_loadouts:
				if not weapon_choice is String or weapon_choice not in ["heavy-bolter", "assault-cannon"]: return {"error": "Land Speeder Vengeance can select only the source-listed Heavy Bolter or Assault Cannon."}
		if entry.has("baal_predator_loadouts"):
			if identity != BAAL_PREDATOR_ID or int(entry.models) != 1 or not entry.baal_predator_loadouts is Array or entry.baal_predator_loadouts.size() != int(entry.copies): return {"error": "Baal Predator equipment choices must match each selected one-model copy."}
			for copy_loadout: Variant in entry.baal_predator_loadouts:
				if not Roster.valid_model_equipment(identity, 0, copy_loadout, 1): return {"error": "Baal Predator can select only its source-listed cannon, paired sponson package, Storm Bolter and Hunter-killer Missile options."}
		if entry.has("predator_destructor_loadouts"):
			if identity != PREDATOR_DESTRUCTOR_ID or int(entry.models) != 1 or not entry.predator_destructor_loadouts is Array or entry.predator_destructor_loadouts.size() != int(entry.copies): return {"error": "Predator Destructor equipment choices must match each selected one-model copy."}
			for copy_loadout: Variant in entry.predator_destructor_loadouts:
				if not Roster.valid_model_equipment(identity, 0, copy_loadout, 1): return {"error": "Predator Destructor can select only its source-listed sponson replacement, Storm Bolter and Hunter-killer Missile options."}
		if entry.has("predator_annihilator_loadouts"):
			if identity != PREDATOR_ANNIHILATOR_ID or int(entry.models) != 1 or not entry.predator_annihilator_loadouts is Array or entry.predator_annihilator_loadouts.size() != int(entry.copies): return {"error": "Predator Annihilator equipment choices must match each selected one-model copy."}
			for copy_loadout: Variant in entry.predator_annihilator_loadouts:
				if not Roster.valid_model_equipment(identity, 0, copy_loadout, 1): return {"error": "Predator Annihilator can select only its source-listed sponson replacement, Storm Bolter and Hunter-killer Missile options."}
		if entry.has("hellblaster_sergeant_pistol_loadouts"):
			if identity != HELLBLASTER_SQUAD_ID or not entry.hellblaster_sergeant_pistol_loadouts is Array or entry.hellblaster_sergeant_pistol_loadouts.size() != int(entry.copies): return {"error": "Hellblaster Sergeant pistol choices must match each selected Squad copy."}
			for pistol_choice: Variant in entry.hellblaster_sergeant_pistol_loadouts:
				if not pistol_choice is String or pistol_choice not in ["bolt-pistol", "plasma-pistol"]: return {"error": "A Hellblaster Sergeant can select only the source-listed Bolt Pistol or Plasma Pistol."}
		if entry.has("assault_intercessor_sergeant_loadouts"):
			if identity != ASSAULT_INTERCESSOR_SQUAD_ID or not entry.assault_intercessor_sergeant_loadouts is Array or entry.assault_intercessor_sergeant_loadouts.size() != int(entry.copies): return {"error": "Assault Intercessor Sergeant choices must match each selected Squad copy."}
			for loadout: Variant in entry.assault_intercessor_sergeant_loadouts:
				if not Roster.valid_assault_intercessor_sergeant_loadout(loadout): return {"error": "An Assault Intercessor Sergeant can select only the source-listed pistol and melee replacements."}
		if entry.has("heavy_intercessor_bolter_loadouts"):
			if identity != HEAVY_INTERCESSOR_SQUAD_ID or not entry.heavy_intercessor_bolter_loadouts is Array or entry.heavy_intercessor_bolter_loadouts.size() != int(entry.copies): return {"error": "Heavy Intercessor Heavy Bolter choices must match each selected Squad copy."}
			for copy_loadouts: Variant in entry.heavy_intercessor_bolter_loadouts:
				if not Roster.valid_heavy_intercessor_bolter_loadout(copy_loadouts, int(entry.models)): return {"error": "Each Heavy Intercessor unit can equip one Heavy Bolter per five models on a non-Sergeant."}
		if entry.has("inceptor_loadouts"):
			if identity != INCEPTOR_SQUAD_ID or not entry.inceptor_loadouts is Array or entry.inceptor_loadouts.size() != int(entry.copies): return {"error": "Inceptor weapon choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.inceptor_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Inceptor weapon choices must match every model in the unit."}
				for weapon_choice: Variant in copy_loadouts:
					if not weapon_choice is String or weapon_choice not in ["assault-bolters", "plasma-exterminators"]: return {"error": "Inceptors can select only source-listed Assault Bolters or Plasma Exterminators."}
		if entry.has("invader_atv_loadouts"):
			if identity != INVADER_ATV_ID or not entry.invader_atv_loadouts is Array or entry.invader_atv_loadouts.size() != int(entry.copies): return {"error": "Invader ATV weapon choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.invader_atv_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Invader ATV weapon choices must match every model in the unit."}
				for multi_melta: Variant in copy_loadouts:
					if not multi_melta is bool: return {"error": "Each Invader ATV model can select only its source-listed Onslaught Gatling Cannon or Multi-melta."}
		if entry.has("reiver_loadouts"):
			if identity != REIVER_SQUAD_ID or not entry.reiver_loadouts is Array or entry.reiver_loadouts.size() != int(entry.copies): return {"error": "Reiver equipment choices must match each selected unit copy."}
			for reiver_loadout: Variant in entry.reiver_loadouts:
				if not Roster.valid_unit_equipment(identity, reiver_loadout): return {"error": "Reivers can select only the source-listed Grav-chutes and Grapnel Launchers."}
		if entry.has("aggressor_loadouts"):
			if identity != "40kdc:11e:adeptus-astartes:aggressor-squad" or not entry.aggressor_loadouts is Array or entry.aggressor_loadouts.size() != int(entry.copies): return {"error": "Aggressor model weapon choices must match each selected unit copy."}
			for copy_loadouts: Variant in entry.aggressor_loadouts:
				if not copy_loadouts is Array or copy_loadouts.size() != int(entry.models): return {"error": "Aggressor weapon choices must match every model in the unit."}
				for boltstorm: Variant in copy_loadouts:
					if not boltstorm is bool: return {"error": "Aggressors can select only the source-listed Flamestorm or Boltstorm/Fragstorm package."}
		if entry.has("scout_loadouts"):
			if identity != SCOUT_SQUAD_ID or not entry.scout_loadouts is Array or entry.scout_loadouts.size() != int(entry.copies): return {"error": "Scout weapon choices must match each selected unit copy."}
			for scout_loadout: Variant in entry.scout_loadouts:
				if not Roster.valid_scout_loadout(identity, scout_loadout, int(entry.models)): return {"error": "Scout equipment must match the source-listed model choices and one-per-five-model specialist limits."}
		if enhancement_id != "" and UnitAbilityCatalog.cannot_receive_enhancements(identity): return {"error": "This datasheet cannot be given Enhancements: " + identity}
		var resolved: Dictionary = definitions.get(identity, {})
		if resolved.is_empty(): resolved = resolve(selection.faction, identity, prefer_current_reference)
		if not resolved.error.is_empty(): return resolved
		definitions[identity] = resolved
		if selection.faction == "Space Marines" and resolved.get("uses_current_reference", false):
			var profile_chapters := CurrentMarines.chapter_keywords(identity.get_slice(":", 3))
			if profile_chapters.size() > 1: return {"error": "Current Marine profile has multiple Chapter faction keywords: " + resolved.unit.name}
			if not profile_chapters.is_empty():
				var chapter: String = profile_chapters[0]
				if not selected_chapter.is_empty() and selected_chapter != chapter:
					return {"error": "A Space Marines army cannot include units from more than one Chapter (%s and %s)." % [CurrentMarines.chapter_name(selected_chapter), CurrentMarines.chapter_name(chapter)]}
				selected_chapter = chapter
		var variant: Dictionary = resolved.duplicate(true)
		var current_profile_data: Dictionary = {}
		var source_points: Dictionary = {}
		var composition_choice_id := str(entry.get("composition_choice_id", ""))
		var composition_choice: Dictionary = {}
		if resolved.get("uses_current_reference", false):
			current_profile_data = current_reference_profile(selection.faction, identity.get_slice(":", 3))
			if int(entry.models) not in construction_model_sizes(identity.get_slice(":", 3), current_profile_data):
				return {"error": "This model-count configuration is blocked pending source reconciliation: %s (%d models)." % [resolved.unit.name, int(entry.models)]}
			source_points = current_profile_data.get("source_roster_points", current_profile_data)
			var costs: Dictionary = source_points.get("points_by_models", current_profile_data.get("points_by_models", {}))
			if not costs.has(entry.models): return {"error": "Unsupported current squad size: " + resolved.unit.name}
			variant.models = entry.models
			variant.cost = costs[entry.models]
			if current_profile_data.has("composition_options"):
				if composition_choice_id.is_empty():
					composition_choice_id = str(current_profile_data.get("default_composition_choice_ids", {}).get(int(entry.models), current_profile_data.get("default_composition_choice_id", "")))
				for option: Dictionary in current_profile_data.composition_options:
					if int(option.get("models", -1)) == int(entry.models) and str(option.get("id", "")) == composition_choice_id:
						composition_choice = option
						break
				if composition_choice.is_empty(): return {"error": "Unsupported source-defined model-role composition: " + composition_choice_id}
				variant.composition_choice_id = composition_choice_id
				if identity.ends_with(":victrix-honour-guard"): variant.victrix_roles = composition_choice.roles.duplicate()
				if identity.ends_with(":decimus-kill-team"): variant.decimus_roles = composition_choice.roles.duplicate()
				if identity.ends_with(":wolf-guard-headtakers"): variant.wolf_guard_headtaker_roles = composition_choice.roles.duplicate()
				variant.cost = int(variant.cost) + int(composition_choice.get("wargear_cost", 0))
			elif not composition_choice_id.is_empty(): return {"error": "This datasheet has no selectable model-role composition."}
		elif entry.models != resolved.models: return {"error": "%s requires %d models in this core-profile mode." % [resolved.unit.name, resolved.models]}
		if enhancement_id != "":
			if not resolved.get("uses_current_reference", false) or not StormlanceEnhancements.valid_for(identity, enhancement_id, str(StormlanceEnhancements.RECORDS.get(enhancement_id, {}).get("detachment", ""))): return {"error": "Enhancement is not eligible for this current datasheet in the local Wahapedia catalog."}
			if enhancement_counts.has(enhancement_id): return {"error": "Each selected detachment enhancement can be assigned only once in this list."}
			enhancement_counts[enhancement_id] = true
			variant.cost = int(variant.cost) + int(StormlanceEnhancements.RECORDS[enhancement_id].cost)
			variant.enhancement_id = enhancement_id
		var intercessor_sergeant := identity == INTERCESSOR_SQUAD_ID
		var eliminator_sergeant := identity == ELIMINATOR_SQUAD_ID
		var outrider_squad := identity == OUTRIDER_SQUAD_ID
		var ravenwing_darkshroud := identity == RAVENWING_DARKSHROUD_ID
		var default_rifle := "bolt-rifle"
		var default_melee := "knives-and-fists"
		for copy_index in range(int(entry.copies)):
			var copy_variant := variant.duplicate(true)
			copy_variant.definition_id = identity
			copy_variant.models = int(entry.models)
			if entry.has("saved_model_loadouts"): copy_variant.saved_model_equipment = entry.saved_model_loadouts[copy_index].duplicate(true)
			if entry.has("saved_unit_loadouts"): copy_variant.saved_unit_equipment = entry.saved_unit_loadouts[copy_index].duplicate(true)
			if intercessor_sergeant and (entry.has("intercessor_sergeant_loadouts") or entry.has("intercessor_rifle_choice")):
				var loadout := Roster.intercessor_sergeant_loadout(entry, copy_index) if entry.has("intercessor_sergeant_loadouts") else {"rifle_choice": str(entry.intercessor_rifle_choice), "melee_choice": str(entry.intercessor_melee_choice)}
				if str(loadout.rifle_choice) != default_rifle or str(loadout.melee_choice) != default_melee:
					copy_variant.intercessor_rifle_choice = str(loadout.rifle_choice)
					copy_variant.intercessor_melee_choice = str(loadout.melee_choice)
			if intercessor_sergeant and entry.has("intercessor_grenade_launcher_loadouts"):
				copy_variant.intercessor_grenade_launcher_choices = entry.intercessor_grenade_launcher_loadouts[copy_index].duplicate(true)
			if eliminator_sergeant and entry.has("eliminator_sergeant_loadouts"):
				copy_variant.eliminator_sergeant_weapon_choice = str(entry.eliminator_sergeant_loadouts[copy_index])
			if eliminator_sergeant and entry.has("eliminator_trooper_loadouts"):
				copy_variant.eliminator_trooper_weapon_choices = entry.eliminator_trooper_loadouts[copy_index].duplicate(true)
			if outrider_squad and entry.has("outrider_loadouts"):
				var outrider_loadout: Dictionary = entry.outrider_loadouts[copy_index]
				copy_variant.outrider_sergeant_melee_choice = str(outrider_loadout.sergeant_melee_choice)
				copy_variant.outrider_plasma_pistol_choices = outrider_loadout.plasma_pistol_choices.duplicate(true)
			if ravenwing_darkshroud and entry.has("ravenwing_darkshroud_loadouts"):
				copy_variant.ravenwing_darkshroud_cannon_choice = str(entry.ravenwing_darkshroud_loadouts[copy_index])
			if identity == LAND_SPEEDER_ID and entry.has("land_speeder_loadouts"):
				copy_variant.land_speeder_cannon_choice = str(entry.land_speeder_loadouts[copy_index])
			if identity == LAND_SPEEDER_VENGEANCE_ID and entry.has("land_speeder_vengeance_loadouts"):
				copy_variant.land_speeder_vengeance_cannon_choice = str(entry.land_speeder_vengeance_loadouts[copy_index])
			if identity == BAAL_PREDATOR_ID and entry.has("baal_predator_loadouts"):
				copy_variant.baal_predator_model_loadout = entry.baal_predator_loadouts[copy_index].duplicate(true)
			if identity == PREDATOR_DESTRUCTOR_ID and entry.has("predator_destructor_loadouts"):
				copy_variant.predator_destructor_model_loadout = entry.predator_destructor_loadouts[copy_index].duplicate(true)
			if identity == PREDATOR_ANNIHILATOR_ID and entry.has("predator_annihilator_loadouts"):
				copy_variant.predator_annihilator_model_loadout = entry.predator_annihilator_loadouts[copy_index].duplicate(true)
			if identity == HELLBLASTER_SQUAD_ID and entry.has("hellblaster_sergeant_pistol_loadouts"):
				copy_variant.hellblaster_sergeant_pistol_choice = str(entry.hellblaster_sergeant_pistol_loadouts[copy_index])
			if identity == ASSAULT_INTERCESSOR_SQUAD_ID and entry.has("assault_intercessor_sergeant_loadouts"):
				var assault_intercessor_loadout: Dictionary = entry.assault_intercessor_sergeant_loadouts[copy_index]
				copy_variant.assault_intercessor_sergeant_pistol_choice = str(assault_intercessor_loadout.pistol_choice)
				copy_variant.assault_intercessor_sergeant_melee_choice = str(assault_intercessor_loadout.melee_choice)
			if identity == HEAVY_INTERCESSOR_SQUAD_ID and entry.has("heavy_intercessor_bolter_loadouts"):
				copy_variant.heavy_intercessor_bolter_choices = entry.heavy_intercessor_bolter_loadouts[copy_index].duplicate(true)
			if identity == INCEPTOR_SQUAD_ID and entry.has("inceptor_loadouts"):
				copy_variant.inceptor_weapon_choices = entry.inceptor_loadouts[copy_index].duplicate(true)
			if identity == INVADER_ATV_ID and entry.has("invader_atv_loadouts"):
				copy_variant.invader_atv_multi_melta_choices = entry.invader_atv_loadouts[copy_index].duplicate(true)
			if identity == REIVER_SQUAD_ID and entry.has("reiver_loadouts"):
				copy_variant.reiver_loadout = entry.reiver_loadouts[copy_index].duplicate(true)
			if identity == "40kdc:11e:adeptus-astartes:aggressor-squad" and entry.has("aggressor_loadouts"):
				copy_variant.aggressor_boltstorm_choices = entry.aggressor_loadouts[copy_index].duplicate(true)
			if identity == SCOUT_SQUAD_ID and entry.has("scout_loadouts"):
				copy_variant.scout_weapon_choices = entry.scout_loadouts[copy_index].duplicate(true)
			if identity == NECRON_WARRIORS_ID and entry.has("necron_warrior_loadouts"):
				copy_variant.necron_warrior_weapon_choices = entry.necron_warrior_loadouts[copy_index].duplicate(true)
			if identity == IMMORTALS_ID and entry.has("immortal_loadouts"):
				copy_variant.immortal_weapon_choices = entry.immortal_loadouts[copy_index].duplicate(true)
			if identity == CANOPTEK_MACROCYTES_ID and entry.has("canoptek_macrocytes_loadouts"):
				copy_variant.canoptek_macrocytes_loadout_choices = entry.canoptek_macrocytes_loadouts[copy_index].duplicate(true)
			if identity == CANOPTEK_SPIDERS_ID and entry.has("canoptek_spyders_loadouts"):
				copy_variant.canoptek_spyders_model_choices = entry.canoptek_spyders_loadouts[copy_index].duplicate(true)
			if identity == CANOPTEK_TOMB_CRAWLERS_ID and entry.has("canoptek_tomb_crawlers_loadouts"):
				copy_variant.canoptek_tomb_crawlers_model_choices = entry.canoptek_tomb_crawlers_loadouts[copy_index].duplicate(true)
			if identity == NECRON_ANNIHILATION_BARGE_ID and entry.has("necron_annihilation_barge_loadouts"):
				copy_variant.necron_annihilation_barge_model_choices = entry.necron_annihilation_barge_loadouts[copy_index].duplicate(true)
			if identity == NECRON_MONOLITH_ID and entry.has("necron_monolith_loadouts"):
				copy_variant.necron_monolith_model_choices = entry.necron_monolith_loadouts[copy_index].duplicate(true)
			var configuration := configuration_key(copy_variant)
			configurations[configuration] = copy_variant
			if resolved.get("uses_current_reference", false):
				var premium := int(StormlanceEnhancements.RECORDS[enhancement_id].cost) if enhancement_id != "" else 0
				var banner_cost := int(composition_choice.get("wargear_cost", 0))
				var model_wargear_cost := 0
				if copy_variant.has("saved_model_equipment"):
					model_wargear_cost += SavedEquipment.points_for_loadout(identity, copy_variant.saved_model_equipment, int(entry.models))
				if identity == INVADER_ATV_ID and copy_variant.has("invader_atv_multi_melta_choices"):
					var multi_melta_choices: Array = copy_variant.invader_atv_multi_melta_choices
					var multi_melta_count := 0
					for equipped: bool in multi_melta_choices:
						if equipped: multi_melta_count += 1
					model_wargear_cost = multi_melta_count * int(current_profile_data.get("wargear_costs", {}).get("multi-melta", 0))
				var standard_cost := int(source_points.get("points_by_models", current_profile_data.get("points_by_models", {})).get(entry.models, variant.cost - premium - banner_cost)) + premium + banner_cost + model_wargear_cost
				var second_sizes: Dictionary = source_points.get("second_plus_points_by_models", current_profile_data.get("second_plus_points_by_models", {}))
				var second_base := int(second_sizes.get(entry.models, standard_cost - premium - banner_cost - model_wargear_cost))
				var third_sizes: Dictionary = source_points.get("third_plus_points_by_models", current_profile_data.get("third_plus_points_by_models", {}))
				var fourth_sizes: Dictionary = source_points.get("fourth_plus_points_by_models", third_sizes)
				pricing[configuration] = {"standard": standard_cost,
					"second_plus": second_base + premium + banner_cost + model_wargear_cost,
					"third_plus": int(third_sizes.get(entry.models, second_base)) + premium + banner_cost + model_wargear_cost,
					"fourth_plus": int(fourth_sizes.get(entry.models, third_sizes.get(entry.models, second_base))) + premium + banner_cost + model_wargear_cost}
			counts[configuration] = int(counts.get(configuration, 0)) + 1
		if resolved.get("uses_current_reference", false):
			var composed_keywords: Array = current_profile_data.get("keywords", []).duplicate()
			if selection.faction == "Space Marines":
				sheet_repetition_keywords[identity] = CurrentMarines.roster_keywords(identity.get_slice(":", 3), current_profile_data, {}, marine_detachment)
				composed_keywords = CurrentMarines.unit_keywords_for_composition(current_profile_data, composition_choice)
			else:
				sheet_repetition_keywords[identity] = composed_keywords.duplicate()
			if "EPIC HERO" in composed_keywords:
				sheet_epic_hero_counts[identity] = int(sheet_epic_hero_counts.get(identity, 0)) + int(entry.copies)
		sheet_counts[identity] = int(sheet_counts.get(identity, 0)) + int(entry.copies)
	var canonical: Array[Dictionary] = []
	var warnings: Array[String] = []
	var total := 0
	var count := 0
	var keys := counts.keys()
	keys.sort()
	for configuration: String in keys:
		var resolved: Dictionary = configurations[configuration]
		var identity: String = resolved.unit.id
		count += int(counts[configuration])
		var current_profile: Dictionary = current_reference_profile(selection.faction, identity.get_slice(":", 3)) if resolved.get("uses_current_reference", false) else {}
		var effective_keywords: Array = sheet_repetition_keywords.get(identity, current_profile.get("keywords", []))
		var source_limit := standard_unit_copy_limit(selection.category, effective_keywords) if not current_profile.is_empty() else 0
		var repetition_limit := 0
		if source_limit > 0:
			repetition_limit = source_limit
		elif not current_profile.is_empty():
			repetition_limit = local_copy_limit(current_profile, resolved.spec)
		else:
			var legacy_keywords: Array = resolved.unit.get("keywords", [])
			var legacy_repeat_category := "Battleline" in legacy_keywords or "Dedicated Transport" in legacy_keywords
			repetition_limit = int(resolved.spec.get("max_supported_copies", 6 if legacy_repeat_category else 3))
		if int(sheet_epic_hero_counts.get(identity, 0)) > 1: return {"error": "An army cannot include more than one EPIC HERO unit with the same datasheet: " + resolved.unit.name}
		if sheet_counts[identity] > repetition_limit: return {"error": "Core-profile repetition limit exceeded: " + resolved.unit.name}
		var identity_pricing: Dictionary = pricing.get(configuration, {"standard": int(resolved.cost), "second_plus": int(resolved.cost), "third_plus": int(resolved.cost), "fourth_plus": int(resolved.cost)})
		var already_counted := int(priced_counts.get(identity, 0))
		var configuration_copies := int(counts[configuration])
		total += int(Roster.tiered_cost(identity_pricing.standard, identity_pricing.third_plus, configuration_copies, already_counted, identity_pricing.fourth_plus, identity_pricing.second_plus))
		priced_counts[identity] = already_counted + configuration_copies
		var canonical_entry := {"definition_id": identity, "models": int(resolved.models) if not resolved.get("uses_current_reference", false) else int(configurations[configuration].models), "copies": int(counts[configuration])}
		if configurations[configuration].has("saved_unit_equipment"):
			var unit_loadouts: Array = []
			for _copy in range(int(counts[configuration])): unit_loadouts.append(configurations[configuration].saved_unit_equipment.duplicate(true))
			canonical_entry.saved_unit_loadouts = unit_loadouts
		if configurations[configuration].has("saved_model_equipment"):
			var loadouts: Array = []
			for _copy in range(int(counts[configuration])): loadouts.append(configurations[configuration].saved_model_equipment.duplicate(true))
			canonical_entry.saved_model_loadouts = loadouts
		if configurations[configuration].has("enhancement_id"): canonical_entry.enhancement_id = str(configurations[configuration].enhancement_id)
		if configurations[configuration].has("composition_choice_id"): canonical_entry.composition_choice_id = str(configurations[configuration].composition_choice_id)
		if configurations[configuration].has("intercessor_rifle_choice"):
			canonical_entry.intercessor_rifle_choice = str(configurations[configuration].intercessor_rifle_choice)
			canonical_entry.intercessor_melee_choice = str(configurations[configuration].intercessor_melee_choice)
		if configurations[configuration].has("intercessor_grenade_launcher_choices"):
			var launcher_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): launcher_loadouts.append(configurations[configuration].intercessor_grenade_launcher_choices.duplicate(true))
			canonical_entry.intercessor_grenade_launcher_loadouts = launcher_loadouts
		if configurations[configuration].has("outrider_sergeant_melee_choice"):
			var outrider_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])):
				outrider_loadouts.append({"sergeant_melee_choice": str(configurations[configuration].outrider_sergeant_melee_choice), "plasma_pistol_choices": configurations[configuration].outrider_plasma_pistol_choices.duplicate(true)})
			canonical_entry.outrider_loadouts = outrider_loadouts
		if configurations[configuration].has("ravenwing_darkshroud_cannon_choice"):
			var darkshroud_loadouts: Array[String] = []
			for _copy in range(int(counts[configuration])): darkshroud_loadouts.append(str(configurations[configuration].ravenwing_darkshroud_cannon_choice))
			canonical_entry.ravenwing_darkshroud_loadouts = darkshroud_loadouts
		if configurations[configuration].has("land_speeder_cannon_choice"):
			var land_speeder_loadouts: Array[String] = []
			for _copy in range(int(counts[configuration])): land_speeder_loadouts.append(str(configurations[configuration].land_speeder_cannon_choice))
			canonical_entry.land_speeder_loadouts = land_speeder_loadouts
		if configurations[configuration].has("land_speeder_vengeance_cannon_choice"):
			var land_speeder_vengeance_loadouts: Array[String] = []
			for _copy in range(int(counts[configuration])): land_speeder_vengeance_loadouts.append(str(configurations[configuration].land_speeder_vengeance_cannon_choice))
			canonical_entry.land_speeder_vengeance_loadouts = land_speeder_vengeance_loadouts
		if configurations[configuration].has("baal_predator_model_loadout"):
			var baal_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])): baal_loadouts.append(configurations[configuration].baal_predator_model_loadout.duplicate(true))
			canonical_entry.baal_predator_loadouts = baal_loadouts
		if configurations[configuration].has("predator_destructor_model_loadout"):
			var destructor_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])): destructor_loadouts.append(configurations[configuration].predator_destructor_model_loadout.duplicate(true))
			canonical_entry.predator_destructor_loadouts = destructor_loadouts
		if configurations[configuration].has("predator_annihilator_model_loadout"):
			var annihilator_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])): annihilator_loadouts.append(configurations[configuration].predator_annihilator_model_loadout.duplicate(true))
			canonical_entry.predator_annihilator_loadouts = annihilator_loadouts
		if configurations[configuration].has("hellblaster_sergeant_pistol_choice"):
			var hellblaster_loadouts: Array[String] = []
			for _copy in range(int(counts[configuration])): hellblaster_loadouts.append(str(configurations[configuration].hellblaster_sergeant_pistol_choice))
			canonical_entry.hellblaster_sergeant_pistol_loadouts = hellblaster_loadouts
		if configurations[configuration].has("assault_intercessor_sergeant_pistol_choice"):
			var assault_intercessor_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])):
				assault_intercessor_loadouts.append({"pistol_choice": str(configurations[configuration].assault_intercessor_sergeant_pistol_choice), "melee_choice": str(configurations[configuration].assault_intercessor_sergeant_melee_choice)})
			canonical_entry.assault_intercessor_sergeant_loadouts = assault_intercessor_loadouts
		if configurations[configuration].has("heavy_intercessor_bolter_choices"):
			var heavy_intercessor_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): heavy_intercessor_loadouts.append(configurations[configuration].heavy_intercessor_bolter_choices.duplicate(true))
			canonical_entry.heavy_intercessor_bolter_loadouts = heavy_intercessor_loadouts
		if configurations[configuration].has("inceptor_weapon_choices"):
			var inceptor_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): inceptor_loadouts.append(configurations[configuration].inceptor_weapon_choices.duplicate(true))
			canonical_entry.inceptor_loadouts = inceptor_loadouts
		if configurations[configuration].has("invader_atv_multi_melta_choices"):
			var invader_atv_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): invader_atv_loadouts.append(configurations[configuration].invader_atv_multi_melta_choices.duplicate(true))
			canonical_entry.invader_atv_loadouts = invader_atv_loadouts
		if configurations[configuration].has("reiver_loadout"):
			var reiver_loadouts: Array[Dictionary] = []
			for _copy in range(int(counts[configuration])): reiver_loadouts.append(configurations[configuration].reiver_loadout.duplicate(true))
			canonical_entry.reiver_loadouts = reiver_loadouts
		if configurations[configuration].has("aggressor_boltstorm_choices"):
			var aggressor_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): aggressor_loadouts.append(configurations[configuration].aggressor_boltstorm_choices.duplicate(true))
			canonical_entry.aggressor_loadouts = aggressor_loadouts
		if configurations[configuration].has("scout_weapon_choices"):
			var scout_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): scout_loadouts.append(configurations[configuration].scout_weapon_choices.duplicate(true))
			canonical_entry.scout_loadouts = scout_loadouts
		if configurations[configuration].has("eliminator_sergeant_weapon_choice"):
			var eliminator_loadouts: Array[String] = []
			for _copy in range(int(counts[configuration])): eliminator_loadouts.append(str(configurations[configuration].eliminator_sergeant_weapon_choice))
			canonical_entry.eliminator_sergeant_loadouts = eliminator_loadouts
		if configurations[configuration].has("eliminator_trooper_weapon_choices"):
			var trooper_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): trooper_loadouts.append(configurations[configuration].eliminator_trooper_weapon_choices.duplicate(true))
			canonical_entry.eliminator_trooper_loadouts = trooper_loadouts
		if configurations[configuration].has("necron_warrior_weapon_choices"):
			var warrior_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): warrior_loadouts.append(configurations[configuration].necron_warrior_weapon_choices.duplicate(true))
			canonical_entry.necron_warrior_loadouts = warrior_loadouts
		if configurations[configuration].has("immortal_weapon_choices"):
			var immortal_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): immortal_loadouts.append(configurations[configuration].immortal_weapon_choices.duplicate(true))
			canonical_entry.immortal_loadouts = immortal_loadouts
		if configurations[configuration].has("canoptek_macrocytes_loadout_choices"):
			var macrocyte_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): macrocyte_loadouts.append(configurations[configuration].canoptek_macrocytes_loadout_choices.duplicate(true))
			canonical_entry.canoptek_macrocytes_loadouts = macrocyte_loadouts
		if configurations[configuration].has("canoptek_spyders_model_choices"):
			var spyder_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): spyder_loadouts.append(configurations[configuration].canoptek_spyders_model_choices.duplicate(true))
			canonical_entry.canoptek_spyders_loadouts = spyder_loadouts
		if configurations[configuration].has("canoptek_tomb_crawlers_model_choices"):
			var tomb_crawler_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): tomb_crawler_loadouts.append(configurations[configuration].canoptek_tomb_crawlers_model_choices.duplicate(true))
			canonical_entry.canoptek_tomb_crawlers_loadouts = tomb_crawler_loadouts
		if configurations[configuration].has("necron_annihilation_barge_model_choices"):
			var barge_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): barge_loadouts.append(configurations[configuration].necron_annihilation_barge_model_choices.duplicate(true))
			canonical_entry.necron_annihilation_barge_loadouts = barge_loadouts
		if configurations[configuration].has("necron_monolith_model_choices"):
			var monolith_loadouts: Array[Array] = []
			for _copy in range(int(counts[configuration])): monolith_loadouts.append(configurations[configuration].necron_monolith_model_choices.duplicate(true))
			canonical_entry.necron_monolith_loadouts = monolith_loadouts
		canonical.append(canonical_entry)
		if not resolved.unsupported_abilities.is_empty(): warnings.append(resolved.unit.name + ": " + ", ".join(resolved.unsupported_abilities))
		if not resolved.get("unsupported_weapon_rules", []).is_empty(): warnings.append(resolved.unit.name + " weapon rules: " + ", ".join(resolved.unsupported_weapon_rules))
	if count > unit_cap: return {"error": "The core-profile mode supports at most %d units per player." % unit_cap}
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	var copy_limit_basis := "wahapedia-e11-core-rules-25.03" if STANDARD_COPY_LIMITS.has(selection.category) else "project-local-supported-copy-ceiling"
	return {"error": "", "selection": {"schema_version": 2, "faction": selection.faction, "entries": canonical, "category": selection.category, "points_limit": int(selection.points_limit)},
		"total": total, "unit_count": count, "definitions": definitions, "configurations": configurations, "configuration_pricing": pricing, "warnings": warnings, "copy_limit_basis": copy_limit_basis,
		"copy_limit_keyword_context": marine_detachment if roster_context.has("marine_detachment") else "datasheet-keywords"}

static func configuration_key(entry: Dictionary) -> String:
	var configuration := "%s:%02d:%s" % [str(entry.get("definition_id", "")), int(entry.get("models", 0)), str(entry.get("enhancement_id", ""))]
	if entry.has("saved_unit_equipment"): configuration += ":unit-saved=" + JSON.stringify(entry.saved_unit_equipment)
	elif entry.has("saved_unit_loadouts") and not entry.saved_unit_loadouts.is_empty(): configuration += ":unit-saved=" + JSON.stringify(entry.saved_unit_loadouts[0])
	if entry.has("saved_model_equipment"): configuration += ":saved=" + JSON.stringify(entry.saved_model_equipment)
	elif entry.has("saved_model_loadouts") and not entry.saved_model_loadouts.is_empty(): configuration += ":saved=" + JSON.stringify(entry.saved_model_loadouts[0])
	if entry.has("composition_choice_id"): configuration += ":" + str(entry.composition_choice_id)
	if entry.has("intercessor_rifle_choice") or entry.has("intercessor_melee_choice"):
		configuration += ":%s:%s" % [str(entry.get("intercessor_rifle_choice", "")), str(entry.get("intercessor_melee_choice", ""))]
	var intercessor_launcher_choices: Variant = entry.get("intercessor_grenade_launcher_choices", null)
	if intercessor_launcher_choices == null:
		var launcher_loadouts: Variant = entry.get("intercessor_grenade_launcher_loadouts", [])
		if launcher_loadouts is Array and not launcher_loadouts.is_empty(): intercessor_launcher_choices = launcher_loadouts[0]
	if intercessor_launcher_choices is Array: configuration += ":grenade-launchers=" + JSON.stringify(intercessor_launcher_choices)
	var outrider_melee_choice := str(entry.get("outrider_sergeant_melee_choice", ""))
	var outrider_plasma_choices: Variant = entry.get("outrider_plasma_pistol_choices", null)
	if outrider_melee_choice.is_empty() or outrider_plasma_choices == null:
		var outrider_loadouts: Variant = entry.get("outrider_loadouts", [])
		if outrider_loadouts is Array and not outrider_loadouts.is_empty() and outrider_loadouts[0] is Dictionary:
			if outrider_melee_choice.is_empty(): outrider_melee_choice = str(outrider_loadouts[0].get("sergeant_melee_choice", ""))
			if outrider_plasma_choices == null: outrider_plasma_choices = outrider_loadouts[0].get("plasma_pistol_choices", null)
	if not outrider_melee_choice.is_empty() or outrider_plasma_choices is Array:
		configuration += ":outrider=%s:%s" % [outrider_melee_choice, JSON.stringify(outrider_plasma_choices)]
	var darkshroud_choice := str(entry.get("ravenwing_darkshroud_cannon_choice", ""))
	if darkshroud_choice.is_empty():
		var darkshroud_loadouts: Variant = entry.get("ravenwing_darkshroud_loadouts", [])
		if darkshroud_loadouts is Array and not darkshroud_loadouts.is_empty(): darkshroud_choice = str(darkshroud_loadouts[0])
	if not darkshroud_choice.is_empty(): configuration += ":darkshroud=" + darkshroud_choice
	var land_speeder_choice := str(entry.get("land_speeder_cannon_choice", ""))
	if land_speeder_choice.is_empty():
		var land_speeder_loadouts: Variant = entry.get("land_speeder_loadouts", [])
		if land_speeder_loadouts is Array and not land_speeder_loadouts.is_empty(): land_speeder_choice = str(land_speeder_loadouts[0])
	if not land_speeder_choice.is_empty(): configuration += ":land-speeder=" + land_speeder_choice
	var land_speeder_vengeance_choice := str(entry.get("land_speeder_vengeance_cannon_choice", ""))
	if land_speeder_vengeance_choice.is_empty():
		var land_speeder_vengeance_loadouts: Variant = entry.get("land_speeder_vengeance_loadouts", [])
		if land_speeder_vengeance_loadouts is Array and not land_speeder_vengeance_loadouts.is_empty(): land_speeder_vengeance_choice = str(land_speeder_vengeance_loadouts[0])
	if not land_speeder_vengeance_choice.is_empty(): configuration += ":land-speeder-vengeance=" + land_speeder_vengeance_choice
	var baal_loadout: Variant = entry.get("baal_predator_model_loadout", null)
	if baal_loadout == null:
		var baal_loadouts: Variant = entry.get("baal_predator_loadouts", [])
		if baal_loadouts is Array and not baal_loadouts.is_empty(): baal_loadout = baal_loadouts[0]
	if baal_loadout is Dictionary: configuration += ":baal-predator=" + JSON.stringify(baal_loadout)
	var destructor_loadout: Variant = entry.get("predator_destructor_model_loadout", null)
	if destructor_loadout == null:
		var destructor_loadouts: Variant = entry.get("predator_destructor_loadouts", [])
		if destructor_loadouts is Array and not destructor_loadouts.is_empty(): destructor_loadout = destructor_loadouts[0]
	if destructor_loadout is Dictionary: configuration += ":predator-destructor=" + JSON.stringify(destructor_loadout)
	var annihilator_loadout: Variant = entry.get("predator_annihilator_model_loadout", null)
	if annihilator_loadout == null:
		var annihilator_loadouts: Variant = entry.get("predator_annihilator_loadouts", [])
		if annihilator_loadouts is Array and not annihilator_loadouts.is_empty(): annihilator_loadout = annihilator_loadouts[0]
	if annihilator_loadout is Dictionary: configuration += ":predator-annihilator=" + JSON.stringify(annihilator_loadout)
	var hellblaster_pistol_choice := str(entry.get("hellblaster_sergeant_pistol_choice", ""))
	if hellblaster_pistol_choice.is_empty():
		var hellblaster_loadouts: Variant = entry.get("hellblaster_sergeant_pistol_loadouts", [])
		if hellblaster_loadouts is Array and not hellblaster_loadouts.is_empty(): hellblaster_pistol_choice = str(hellblaster_loadouts[0])
	if not hellblaster_pistol_choice.is_empty(): configuration += ":hellblaster-pistol=" + hellblaster_pistol_choice
	var assault_intercessor_pistol_choice := str(entry.get("assault_intercessor_sergeant_pistol_choice", ""))
	var assault_intercessor_melee_choice := str(entry.get("assault_intercessor_sergeant_melee_choice", ""))
	if assault_intercessor_pistol_choice.is_empty() or assault_intercessor_melee_choice.is_empty():
		var assault_intercessor_loadouts: Variant = entry.get("assault_intercessor_sergeant_loadouts", [])
		if assault_intercessor_loadouts is Array and not assault_intercessor_loadouts.is_empty() and assault_intercessor_loadouts[0] is Dictionary:
			if assault_intercessor_pistol_choice.is_empty(): assault_intercessor_pistol_choice = str(assault_intercessor_loadouts[0].get("pistol_choice", ""))
			if assault_intercessor_melee_choice.is_empty(): assault_intercessor_melee_choice = str(assault_intercessor_loadouts[0].get("melee_choice", ""))
	if not assault_intercessor_pistol_choice.is_empty() or not assault_intercessor_melee_choice.is_empty():
		configuration += ":assault-intercessor=%s:%s" % [assault_intercessor_pistol_choice, assault_intercessor_melee_choice]
	var heavy_intercessor_choices: Variant = entry.get("heavy_intercessor_bolter_choices", null)
	if heavy_intercessor_choices == null:
		var heavy_intercessor_loadouts: Variant = entry.get("heavy_intercessor_bolter_loadouts", [])
		if heavy_intercessor_loadouts is Array and not heavy_intercessor_loadouts.is_empty(): heavy_intercessor_choices = heavy_intercessor_loadouts[0]
	if heavy_intercessor_choices is Array: configuration += ":heavy-intercessors=" + JSON.stringify(heavy_intercessor_choices)
	var inceptor_choices: Variant = entry.get("inceptor_weapon_choices", null)
	if inceptor_choices == null:
		var inceptor_loadouts: Variant = entry.get("inceptor_loadouts", [])
		if inceptor_loadouts is Array and not inceptor_loadouts.is_empty(): inceptor_choices = inceptor_loadouts[0]
	if inceptor_choices is Array: configuration += ":inceptors=" + JSON.stringify(inceptor_choices)
	var invader_atv_choices: Variant = entry.get("invader_atv_multi_melta_choices", null)
	if invader_atv_choices == null:
		var invader_atv_loadouts: Variant = entry.get("invader_atv_loadouts", [])
		if invader_atv_loadouts is Array and not invader_atv_loadouts.is_empty(): invader_atv_choices = invader_atv_loadouts[0]
	if invader_atv_choices is Array: configuration += ":invader-atv=" + JSON.stringify(invader_atv_choices)
	var reiver_loadout: Variant = entry.get("reiver_loadout", null)
	if reiver_loadout == null:
		var reiver_loadouts: Variant = entry.get("reiver_loadouts", [])
		if reiver_loadouts is Array and not reiver_loadouts.is_empty(): reiver_loadout = reiver_loadouts[0]
	if reiver_loadout is Dictionary: configuration += ":reiver=" + JSON.stringify(reiver_loadout)
	var aggressor_choices: Variant = entry.get("aggressor_boltstorm_choices", null)
	if aggressor_choices == null:
		var aggressor_loadouts: Variant = entry.get("aggressor_loadouts", [])
		if aggressor_loadouts is Array and not aggressor_loadouts.is_empty(): aggressor_choices = aggressor_loadouts[0]
	if aggressor_choices is Array: configuration += ":aggressor-model-packages=" + JSON.stringify(aggressor_choices)
	var scout_choices: Variant = entry.get("scout_weapon_choices", null)
	if scout_choices == null:
		var scout_loadouts: Variant = entry.get("scout_loadouts", [])
		if scout_loadouts is Array and not scout_loadouts.is_empty(): scout_choices = scout_loadouts[0]
	if scout_choices is Array: configuration += ":scouts=" + JSON.stringify(scout_choices)
	var eliminator_choice := str(entry.get("eliminator_sergeant_weapon_choice", ""))
	if eliminator_choice.is_empty():
		var eliminator_loadouts: Variant = entry.get("eliminator_sergeant_loadouts", [])
		if eliminator_loadouts is Array and not eliminator_loadouts.is_empty(): eliminator_choice = str(eliminator_loadouts[0])
	if not eliminator_choice.is_empty(): configuration += ":" + eliminator_choice
	var trooper_choices: Variant = entry.get("eliminator_trooper_weapon_choices", null)
	if trooper_choices == null:
		var trooper_loadouts: Variant = entry.get("eliminator_trooper_loadouts", [])
		if trooper_loadouts is Array and not trooper_loadouts.is_empty(): trooper_choices = trooper_loadouts[0]
	if trooper_choices is Array: configuration += ":troopers=" + JSON.stringify(trooper_choices)
	var warrior_choices: Variant = entry.get("necron_warrior_weapon_choices", null)
	if warrior_choices == null:
		var warrior_loadouts: Variant = entry.get("necron_warrior_loadouts", [])
		if warrior_loadouts is Array and not warrior_loadouts.is_empty(): warrior_choices = warrior_loadouts[0]
	if warrior_choices is Array: configuration += ":warriors=" + JSON.stringify(warrior_choices)
	var immortal_choices: Variant = entry.get("immortal_weapon_choices", null)
	if immortal_choices == null:
		var immortal_loadouts: Variant = entry.get("immortal_loadouts", [])
		if immortal_loadouts is Array and not immortal_loadouts.is_empty(): immortal_choices = immortal_loadouts[0]
	if immortal_choices is Array: configuration += ":immortals=" + JSON.stringify(immortal_choices)
	var macrocyte_choices: Variant = entry.get("canoptek_macrocytes_loadout_choices", null)
	if macrocyte_choices == null:
		var macrocyte_loadouts: Variant = entry.get("canoptek_macrocytes_loadouts", [])
		if macrocyte_loadouts is Array and not macrocyte_loadouts.is_empty(): macrocyte_choices = macrocyte_loadouts[0]
	if macrocyte_choices is Array: configuration += ":macrocytes=" + JSON.stringify(macrocyte_choices)
	var spyder_choices: Variant = entry.get("canoptek_spyders_model_choices", null)
	if spyder_choices == null:
		var spyder_loadouts: Variant = entry.get("canoptek_spyders_loadouts", [])
		if spyder_loadouts is Array and not spyder_loadouts.is_empty(): spyder_choices = spyder_loadouts[0]
	if spyder_choices is Array: configuration += ":spyders=" + JSON.stringify(spyder_choices)
	var tomb_crawler_choices: Variant = entry.get("canoptek_tomb_crawlers_model_choices", null)
	if tomb_crawler_choices == null:
		var tomb_crawler_loadouts: Variant = entry.get("canoptek_tomb_crawlers_loadouts", [])
		if tomb_crawler_loadouts is Array and not tomb_crawler_loadouts.is_empty(): tomb_crawler_choices = tomb_crawler_loadouts[0]
	if tomb_crawler_choices is Array: configuration += ":tomb-crawlers=" + JSON.stringify(tomb_crawler_choices)
	var barge_choices: Variant = entry.get("necron_annihilation_barge_model_choices", null)
	if barge_choices == null:
		var barge_loadouts: Variant = entry.get("necron_annihilation_barge_loadouts", [])
		if barge_loadouts is Array and not barge_loadouts.is_empty(): barge_choices = barge_loadouts[0]
	if barge_choices is Array: configuration += ":annihilation-barge=" + JSON.stringify(barge_choices)
	var monolith_choices: Variant = entry.get("necron_monolith_model_choices", null)
	if monolith_choices == null:
		var monolith_loadouts: Variant = entry.get("necron_monolith_loadouts", [])
		if monolith_loadouts is Array and not monolith_loadouts.is_empty(): monolith_choices = monolith_loadouts[0]
	if monolith_choices is Array: configuration += ":monolith=" + JSON.stringify(monolith_choices)
	return configuration

static func reference_army(faction: String) -> Dictionary:
	if faction not in ["Space Marines", "Necrons"]: return {"error": "No reference army for this faction."}
	var list := Roster.new_list("11e", faction, "custom", 1000)
	list.id = "reference:core-v2:" + faction
	list.name = "Mixed reference — " + faction
	list.pricing_source = "local-reference-profiles"
	list.notes = "Reference draft with fixed weapons; this is not a complete army legality or rules-support claim. Necron entries intentionally resolve against retained historical starter profiles."
	for source: String in (["intercessor-squad", "terminator-squad"] if faction == "Space Marines" else ["necron-warriors", "immortals"]):
		var spec: Dictionary = SPECS[source]
		var resolved := resolve(faction, "40kdc:11e:%s:%s" % [spec.folder, source], faction != "Necrons")
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost,
			"copies": 4 if source == "necron-warriors" else 2, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

static func identity_for_saved_entry(selection: Dictionary, entry: Dictionary) -> String:
	return canonical_id(str(selection.faction), str(entry.definition_id))

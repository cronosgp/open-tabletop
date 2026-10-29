extends RefCounted
## Explicit core-profile admission, independent of display names and API prices.
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const ID := "mixed-core-profiles-v66-wolf-guard-headtakers"
const DIRECTORY := "res://data/imported/starter-11e-v1"
const MAX_SQUADS := 6
const STANDARD_COPY_LIMITS := {"incursion": 2, "strike_force": 3}
const SPECS := {
	"crusade-ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"execrator": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"chaplain-grimaldus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 1},
	"sword-brethren-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 3},
	"crusader-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 10, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 6},
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
	"land-raider-crusader": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"land-raider-redeemer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"drop-pod": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 4, "validation_status": "tests_passed_local_targeted"},
	"impulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"repulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"repulsor-executioner": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
	"rhino": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "source_bounded_local_scope_passed_2026_10_28"},
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
	"incursor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"reiver-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"firestrike-servo-turrets": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"ballistus-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"redemptor-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"brutalis-dreadnought": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"invictor-tactical-warsuit": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"desolation-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "max_supported_copies": 2},
	"necron-warriors": {"faction": "Necrons", "folder": "necrons", "models": 10, "template": 2,
		"aliases": ["58e9-5212-f5a6-c12d"], "gun": ["gauss-flayer", "Gauss flayer"], "blade": ["close-combat-weapon", "Close combat weapon"]},
	"immortals": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2,
		"aliases": ["f81-b23c-e183-39d7"], "gun": ["gauss-blaster", "Gauss blaster"], "blade": ["close-combat-weapon-immortals", "Close combat weapon"]},
	"assault-intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"inceptor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"heavy-intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"lieutenant": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "gun": ["master-crafted-bolter-lieutenant", "Master-crafted Bolter"], "blade": ["ceramite-fists-lieutenant", "Ceramite Fists"]},
	"vulkan-hestan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 1},
	"royal-warden": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 2, "aliases": [], "gun": ["relic-gauss-blaster", "Relic gauss blaster"], "blade": ["close-combat-weapon-royal-warden", "Close combat weapon"]},
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
	"decimus-kill-team": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "source_bounded_local_scope_passed_2026_10_28", "construction_model_sizes": [10], "max_supported_copies": 3},
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
	"wolf-guard-headtakers": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 6, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "construction_model_sizes": [6, 12], "max_supported_copies": 3},
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
		"aliases": [], "gun": ["staff-of-light-overlord", "Ranged"], "blade": ["staff-of-light-overlord", "Melee"]}}

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
	if unit.get("edition", "") != "11e" or unit.get("faction", "") != "Space Marines": return {}
	var identity := canonical_id("Space Marines", str(unit.get("id", "")))
	var source := identity.get_slice(":", 3)
	if identity != "40kdc:11e:adeptus-astartes:" + source: return {}
	if not SPECS.get(source, {}).get("current_reference", false): return {}
	if SPECS[source].get("validation_status", "") in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]: return {}
	var profile := CurrentMarines.profile(source)
	var result := unit.duplicate(true)
	result.id = identity
	result.name = profile.name
	result.source_digest = CurrentMarines.digest()
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
	if SPECS[source].has("construction_model_sizes"):
		result.construction_scope = "Only the source-consistent %s-model configuration is currently admitted; other listed sizes remain blocked pending source reconciliation." % ", ".join(construction_model_sizes(source, profile).map(func(size: int) -> String: return str(size)))
	return result

static func construction_model_sizes(source: String, profile: Dictionary = {}) -> Array[int]:
	var current := profile if not profile.is_empty() else CurrentMarines.profile(source)
	var points: Dictionary = current.get("points_by_models", {})
	var candidates: Array = SPECS.get(source, {}).get("construction_model_sizes", points.keys())
	var result: Array[int] = []
	for candidate: Variant in candidates:
		var models := int(candidate)
		if points.has(models) and models not in result: result.append(models)
	result.sort()
	return result

static func resolve(faction: String, identity: String) -> Dictionary:
	identity = canonical_id(faction, identity)
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		var canonical := "40kdc:11e:%s:%s" % [spec.folder, source]
		if identity != canonical: continue
		if spec.get("current_reference", false):
			if spec.get("validation_status", "") in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]: return {"error": "Local validation pending for current profile: " + source}
			var current := CurrentMarines.profile(source)
			if current.is_empty(): return {"error": "Missing current Marine profile: " + source}
			var unit := {"id": canonical, "name": current.name, "stats": current.stats.duplicate(true), "keywords": current.keywords.duplicate(), "base": {"shape": "circle", "radius_inches": current.base_radius_inches}}
			var gun: Dictionary = current.ranged[0].profiles.values()[0].duplicate(true) if not current.ranged.is_empty() else {}
			var blade: Dictionary = current.melee[0].profiles.values()[0].duplicate(true) if not current.melee.is_empty() else {}
			return {"error": "", "unit": unit, "spec": spec, "cost": current.points, "models": current.models,
				"weapons": {"gun": gun, "blade": blade},
				"pack_hash": CurrentMarines.digest(), "unsupported_abilities": [], "requires_current_abilities": true}
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
			return {"error": "", "unit": unit, "spec": spec, "cost": cost, "models": spec.models, "weapons": weapons,
				"pack_hash": pack.manifest.units_sha256, "unsupported_abilities": unit.get("unsupported_rules", []).duplicate()}
	return {"error": "Unit is not implemented for this faction: " + identity}

static func admit(selection: Variant, unit_cap: int = MAX_SQUADS, roster_context: Dictionary = {}) -> Dictionary:
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
		if not entry is Dictionary or entry.size() < 3 or entry.size() > 5 or not entry.get("definition_id") is String or not Roster.integer(entry.get("models"), 1, 20) or not Roster.integer(entry.get("copies"), 1, unit_cap): return {"error": "Invalid mixed army entry."}
		for key: Variant in entry:
			if str(key) not in ["definition_id", "models", "copies", "enhancement_id", "composition_choice_id"]: return {"error": "Unsupported mixed army entry field: " + str(key)}
		if entry.has("enhancement_id") and not entry.enhancement_id is String: return {"error": "Enhancement ID must be a string."}
		if entry.has("composition_choice_id") and (not entry.composition_choice_id is String or entry.composition_choice_id.is_empty() or entry.composition_choice_id.length() > 64): return {"error": "Invalid source-defined unit composition choice."}
		var enhancement_id := str(entry.get("enhancement_id", ""))
		if enhancement_id != "" and int(entry.copies) != 1: return {"error": "Assign an enhancement to one individual unit entry."}
		var identity := canonical_id(selection.faction, entry.definition_id)
		var resolved: Dictionary = definitions.get(identity, {})
		if resolved.is_empty(): resolved = resolve(selection.faction, identity)
		if not resolved.error.is_empty(): return resolved
		definitions[identity] = resolved
		if selection.faction == "Space Marines" and resolved.spec.get("current_reference", false):
			var profile_chapters := CurrentMarines.chapter_keywords(identity.get_slice(":", 3))
			if profile_chapters.size() > 1: return {"error": "Current Marine profile has multiple Chapter faction keywords: " + resolved.unit.name}
			if not profile_chapters.is_empty():
				var chapter: String = profile_chapters[0]
				if not selected_chapter.is_empty() and selected_chapter != chapter:
					return {"error": "A Space Marines army cannot include units from more than one Chapter (%s and %s)." % [CurrentMarines.chapter_name(selected_chapter), CurrentMarines.chapter_name(chapter)]}
				selected_chapter = chapter
		var variant: Dictionary = resolved.duplicate(true)
		var marine_profile: Dictionary = {}
		var source_points: Dictionary = {}
		var composition_choice_id := str(entry.get("composition_choice_id", ""))
		var composition_choice: Dictionary = {}
		if resolved.spec.get("current_reference", false):
			marine_profile = CurrentMarines.profile(identity.get_slice(":", 3))
			if int(entry.models) not in construction_model_sizes(identity.get_slice(":", 3), marine_profile):
				return {"error": "This model-count configuration is blocked pending source reconciliation: %s (%d models)." % [resolved.unit.name, int(entry.models)]}
			source_points = marine_profile.get("source_roster_points", marine_profile)
			var costs: Dictionary = source_points.get("points_by_models", marine_profile.get("points_by_models", {}))
			if not costs.has(entry.models): return {"error": "Unsupported current squad size: " + resolved.unit.name}
			variant.models = entry.models
			variant.cost = costs[entry.models]
			if marine_profile.has("composition_options"):
				if composition_choice_id.is_empty():
					composition_choice_id = str(marine_profile.get("default_composition_choice_ids", {}).get(int(entry.models), marine_profile.get("default_composition_choice_id", "")))
				for option: Dictionary in marine_profile.composition_options:
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
			if not resolved.spec.get("current_reference", false) or not StormlanceEnhancements.valid_for(identity, enhancement_id, str(StormlanceEnhancements.RECORDS.get(enhancement_id, {}).get("detachment", ""))): return {"error": "Enhancement is not eligible for this current datasheet in the local Wahapedia catalog."}
			if enhancement_counts.has(enhancement_id): return {"error": "Each selected detachment enhancement can be assigned only once in this list."}
			enhancement_counts[enhancement_id] = true
			variant.cost = int(variant.cost) + int(StormlanceEnhancements.RECORDS[enhancement_id].cost)
			variant.enhancement_id = enhancement_id
		var configuration := "%s:%02d:%s" % [identity, int(entry.models), enhancement_id]
		if not composition_choice_id.is_empty(): configuration += ":" + composition_choice_id
		configurations[configuration] = variant
		if resolved.spec.get("current_reference", false):
			var premium := int(StormlanceEnhancements.RECORDS[enhancement_id].cost) if enhancement_id != "" else 0
			var banner_cost := int(composition_choice.get("wargear_cost", 0))
			var standard_cost := int(source_points.get("points_by_models", marine_profile.get("points_by_models", {})).get(entry.models, variant.cost - premium - banner_cost)) + premium + banner_cost
			var second_sizes: Dictionary = source_points.get("second_plus_points_by_models", marine_profile.get("second_plus_points_by_models", {}))
			var second_base := int(second_sizes.get(entry.models, standard_cost - premium - banner_cost))
			var third_sizes: Dictionary = source_points.get("third_plus_points_by_models", marine_profile.get("third_plus_points_by_models", {}))
			var fourth_sizes: Dictionary = source_points.get("fourth_plus_points_by_models", third_sizes)
			pricing[configuration] = {"standard": standard_cost,
				"second_plus": second_base + premium + banner_cost,
				"third_plus": int(third_sizes.get(entry.models, second_base)) + premium + banner_cost,
				"fourth_plus": int(fourth_sizes.get(entry.models, third_sizes.get(entry.models, second_base))) + premium + banner_cost}
			sheet_repetition_keywords[identity] = CurrentMarines.roster_keywords(identity.get_slice(":", 3), marine_profile, {}, marine_detachment)
			var composed_keywords := CurrentMarines.unit_keywords_for_composition(marine_profile, composition_choice)
			if "EPIC HERO" in composed_keywords:
				sheet_epic_hero_counts[identity] = int(sheet_epic_hero_counts.get(identity, 0)) + int(entry.copies)
		counts[configuration] = int(counts.get(configuration, 0)) + int(entry.copies)
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
		var current_profile: Dictionary = CurrentMarines.profile(identity.get_slice(":", 3)) if resolved.spec.get("current_reference", false) else {}
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
		var canonical_entry := {"definition_id": identity, "models": int(resolved.models) if not resolved.spec.get("current_reference", false) else int(configurations[configuration].models), "copies": int(counts[configuration])}
		if configurations[configuration].has("enhancement_id"): canonical_entry.enhancement_id = str(configurations[configuration].enhancement_id)
		if configurations[configuration].has("composition_choice_id"): canonical_entry.composition_choice_id = str(configurations[configuration].composition_choice_id)
		canonical.append(canonical_entry)
		if not resolved.unsupported_abilities.is_empty(): warnings.append(resolved.unit.name + ": " + ", ".join(resolved.unsupported_abilities))
	if count > unit_cap: return {"error": "The core-profile mode supports at most %d units per player." % unit_cap}
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	var copy_limit_basis := "wahapedia-e11-core-rules-25.03" if STANDARD_COPY_LIMITS.has(selection.category) else "project-local-supported-copy-ceiling"
	return {"error": "", "selection": {"schema_version": 2, "faction": selection.faction, "entries": canonical, "category": selection.category, "points_limit": int(selection.points_limit)},
		"total": total, "unit_count": count, "definitions": definitions, "configurations": configurations, "warnings": warnings, "copy_limit_basis": copy_limit_basis,
		"copy_limit_keyword_context": marine_detachment if roster_context.has("marine_detachment") else "datasheet-keywords"}

static func reference_army(faction: String) -> Dictionary:
	if faction not in ["Space Marines", "Necrons"]: return {"error": "No reference army for this faction."}
	var list := Roster.new_list("11e", faction, "custom", 1000)
	list.id = "reference:core-v2:" + faction
	list.name = "Mixed reference — " + faction
	list.pricing_source = "local-reference-profiles"
	list.notes = "Reference draft with fixed weapons; this is not a complete army legality or rules-support claim. Necron profile facts remain historical starter data and are not current construction choices."
	for source: String in (["intercessor-squad", "terminator-squad"] if faction == "Space Marines" else ["necron-warriors", "immortals"]):
		var spec: Dictionary = SPECS[source]
		var resolved := resolve(faction, "40kdc:11e:%s:%s" % [spec.folder, source])
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost,
			"copies": 4 if source == "necron-warriors" else 2, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

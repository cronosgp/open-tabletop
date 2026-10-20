extends RefCounted
## Explicit core-profile admission, independent of display names and API prices.
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const ID := "mixed-core-profiles-v30-vulkan-hestan"
const DIRECTORY := "res://data/imported/starter-11e-v1"
const MAX_SQUADS := 6
const SPECS := {
	"victrix-honour-guard": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"marneus-calgar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"kor-sarro-khan": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"captain-titus": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"wardens-of-ultramar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 6, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"land-raider": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"land-raider-crusader": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"land-raider-redeemer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"drop-pod": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"impulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"repulsor": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"repulsor-executioner": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"rhino": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"company-heroes": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 4, "template": 1, "aliases": [], "current_reference": true},
	"outrider-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"gladiator-reaper": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"gladiator-valiant": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"gladiator-lancer": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"land-speeder": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
	"invader-atvs": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
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
	"captain-in-gravis-armour": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["1d56-1cc3-de57-10e2"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
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
	"ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["6562-d718-b8e0-c457"], "current_reference": true},
	"bladeguard-ancient": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["9ca5-e5f4-f85d-bcca"], "current_reference": true},
	"bladeguard-veteran-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["7044-bf1-f949-c32d"], "current_reference": true},
	"judiciar": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["8dcb-987c-1ab4-b976"], "current_reference": true},
	"chaplain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["ceb5-55c7-2d49-d952"], "current_reference": true},
	"chaplain-on-bike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"captain-on-bike": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 3, "validation_status": "tests_passed_local_targeted"},
	"adrax-agatone": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"kaius-konorius": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "max_supported_copies": 1, "validation_status": "tests_passed_local_targeted"},
	"sternguard-veteran-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["907f-11-c4d1-ec21"], "current_reference": true},
	"eliminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["d6c3-e9d2-430d-6c2f"], "current_reference": true},
	"eradicator-squad-with-melta-rifles": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": [], "current_reference": true},
	"eradicator-squad-with-heavy-bolters": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["3bc7-8328-a080-3958"], "current_reference": true},
	"apothecary-biologis": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": ["c6e9-c0c8-5f13-5771"], "current_reference": true},
	"aggressor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 3, "template": 1, "aliases": ["129d-2da5-66f3-f4ec"], "current_reference": true},
	"infernus-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["b007-fc7b-8e4a-b017"], "current_reference": true},
	"hellblaster-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["7102-b3a4-9bfc-1b84"], "current_reference": true},
	"intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["8da0-4570-c3c-819f"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"terminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": ["4808-a80b-309a-7933", "80ad-6e62-65e3-e667"], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
	"terminator-assault-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
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
	"desolation-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted", "max_supported_copies": 3},
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
	"captain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1, "aliases": [], "current_reference": true, "validation_status": "tests_passed_local_targeted"},
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

static func current_catalog_choice(unit: Dictionary) -> Dictionary:
	if unit.get("edition", "") != "11e" or unit.get("faction", "") != "Space Marines": return {}
	var identity := canonical_id("Space Marines", str(unit.get("id", "")))
	var source := identity.get_slice(":", 3)
	if identity != "40kdc:11e:adeptus-astartes:" + source: return {}
	if not SPECS.get(source, {}).get("current_reference", false): return {}
	if SPECS[source].get("validation_status", "") in ["tests_written_not_run", "local_checks_pending"]: return {}
	var profile := CurrentMarines.profile(source)
	var result := unit.duplicate(true)
	result.id = identity
	result.name = profile.name
	result.source_digest = CurrentMarines.digest()
	result.options = []
	for models: int in profile.points_by_models:
		var option := {"models": models, "cost": profile.points_by_models[models]}
		if profile.get("third_plus_points_by_models", {}).has(models): option.third_plus_cost = profile.third_plus_points_by_models[models]
		result.options.append(option)
	return result

static func resolve(faction: String, identity: String) -> Dictionary:
	identity = canonical_id(faction, identity)
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		var canonical := "40kdc:11e:%s:%s" % [spec.folder, source]
		if identity != canonical: continue
		if spec.get("current_reference", false):
			if spec.get("validation_status", "") in ["tests_written_not_run", "local_checks_pending"]: return {"error": "Local validation pending for current profile: " + source}
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

static func admit(selection: Variant, unit_cap: int = MAX_SQUADS) -> Dictionary:
	if not selection is Dictionary or selection.size() != 5 or selection.get("schema_version") != 2: return {"error": "Invalid mixed army selection."}
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
	for entry: Variant in selection.entries:
		if not entry is Dictionary or entry.size() not in [3, 4] or not entry.get("definition_id") is String or not Roster.integer(entry.get("models"), 1, 20) or not Roster.integer(entry.get("copies"), 1, unit_cap): return {"error": "Invalid mixed army entry."}
		for key: Variant in entry:
			if str(key) not in ["definition_id", "models", "copies", "enhancement_id"]: return {"error": "Unsupported mixed army entry field: " + str(key)}
		if entry.has("enhancement_id") and not entry.enhancement_id is String: return {"error": "Enhancement ID must be a string."}
		var enhancement_id := str(entry.get("enhancement_id", ""))
		if enhancement_id != "" and (entry.size() != 4 or int(entry.copies) != 1): return {"error": "Assign an enhancement to one individual unit entry."}
		var identity := canonical_id(selection.faction, entry.definition_id)
		var resolved: Dictionary = definitions.get(identity, {})
		if resolved.is_empty(): resolved = resolve(selection.faction, identity)
		if not resolved.error.is_empty(): return resolved
		definitions[identity] = resolved
		var variant: Dictionary = resolved.duplicate(true)
		var marine_profile: Dictionary = {}
		if resolved.spec.get("current_reference", false):
			marine_profile = CurrentMarines.profile(identity.get_slice(":", 3))
			var costs: Dictionary = marine_profile.get("points_by_models", {})
			if not costs.has(entry.models): return {"error": "Unsupported current squad size: " + resolved.unit.name}
			variant.models = entry.models
			variant.cost = costs[entry.models]
		elif entry.models != resolved.models: return {"error": "%s requires %d models in this core-profile mode." % [resolved.unit.name, resolved.models]}
		if enhancement_id != "":
			if not resolved.spec.get("current_reference", false) or not StormlanceEnhancements.valid_for(identity, enhancement_id, str(StormlanceEnhancements.RECORDS.get(enhancement_id, {}).get("detachment", ""))): return {"error": "Enhancement is not eligible for this current datasheet in the local Wahapedia catalog."}
			if enhancement_counts.has(enhancement_id): return {"error": "Each selected detachment enhancement can be assigned only once in this list."}
			enhancement_counts[enhancement_id] = true
			variant.cost = int(variant.cost) + int(StormlanceEnhancements.RECORDS[enhancement_id].cost)
			variant.enhancement_id = enhancement_id
		var configuration := "%s:%02d:%s" % [identity, int(entry.models), enhancement_id]
		configurations[configuration] = variant
		if resolved.spec.get("current_reference", false):
			var premium := int(StormlanceEnhancements.RECORDS[enhancement_id].cost) if enhancement_id != "" else 0
			pricing[configuration] = {"standard": int(marine_profile.get("points_by_models", {}).get(entry.models, variant.cost - premium)) + premium,
				"third_plus": int(marine_profile.get("third_plus_points_by_models", {}).get(entry.models, marine_profile.get("points_by_models", {}).get(entry.models, variant.cost - premium))) + premium}
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
		var battleline: bool = "BATTLELINE" in current_profile.get("keywords", []) if not current_profile.is_empty() else "Battleline" in resolved.unit.get("keywords", [])
		var repetition_limit := int(current_profile.get("max_supported_copies", 6 if battleline else 3))
		if sheet_counts[identity] > repetition_limit: return {"error": "Core-profile repetition limit exceeded: " + resolved.unit.name}
		var identity_pricing: Dictionary = pricing.get(configuration, {"standard": int(resolved.cost), "third_plus": int(resolved.cost)})
		var already_counted := int(priced_counts.get(identity, 0))
		var normal_copies := mini(int(counts[configuration]), maxi(0, 2 - already_counted))
		total += normal_copies * int(identity_pricing.standard) + (int(counts[configuration]) - normal_copies) * int(identity_pricing.third_plus)
		priced_counts[identity] = already_counted + int(counts[configuration])
		var canonical_entry := {"definition_id": identity, "models": int(resolved.models) if not resolved.spec.get("current_reference", false) else int(configurations[configuration].models), "copies": int(counts[configuration])}
		if configurations[configuration].has("enhancement_id"): canonical_entry.enhancement_id = str(configurations[configuration].enhancement_id)
		canonical.append(canonical_entry)
		if not resolved.unsupported_abilities.is_empty(): warnings.append(resolved.unit.name + ": " + ", ".join(resolved.unsupported_abilities))
	if count > unit_cap: return {"error": "The core-profile mode supports at most %d units per player." % unit_cap}
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	return {"error": "", "selection": {"schema_version": 2, "faction": selection.faction, "entries": canonical, "category": selection.category, "points_limit": int(selection.points_limit)},
		"total": total, "unit_count": count, "definitions": definitions, "configurations": configurations, "warnings": warnings}

static func reference_army(faction: String) -> Dictionary:
	if faction not in ["Space Marines", "Necrons"]: return {"error": "No reference army for this faction."}
	var list := Roster.new_list("11e", faction, "training", 500)
	list.id = "reference:core-v1:" + faction
	list.name = "Mixed reference — " + faction
	list.pricing_source = "starter-training-v1"
	list.notes = "Core-profile training. Fixed weapons; unit/faction abilities and official legality are not implemented."
	for source: String in (["intercessor-squad", "terminator-squad"] if faction == "Space Marines" else ["necron-warriors", "immortals"]):
		var spec: Dictionary = SPECS[source]
		var resolved := resolve(faction, "40kdc:11e:%s:%s" % [spec.folder, source])
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost,
			"copies": 4 if source == "necron-warriors" else 2, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

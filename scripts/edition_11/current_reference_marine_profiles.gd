extends RefCounted
## Fixed default loadouts transcribed from the local Wahapedia e11 extraction.
## Wahapedia is the project's sole rules authority; local admission remains scoped and uncertified for full army legality.
const ID := "space-marines-e11-fixed-reference-2026-10-19-v85-wardens-of-ultramar"

static func _build_profiles() -> Dictionary:
	return {
	"cato-sicarius": {
		"name": "Cato Sicarius", "source_book_id": "000000139", "source_datasheet_id": "000004184", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {1: 115}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [{"id": "artisan-plasma-pistol", "profiles": {"standard": _weapon("Artisan Plasma Pistol", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true})}}],
		"melee": [
			{"id": "talassarian-tempest-blade-strike", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Strike", 0.0, 4, 2, 6, -3, 3, {"devastating-wounds": true})}},
			{"id": "talassarian-tempest-blade-coup-de-grace", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Coup de Grace", 0.0, 6, 2, 5, -2, 2, {"precision": true})}},
			{"id": "talassarian-tempest-blade-sweep", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Sweep", 0.0, 9, 2, 5, -2, 1, {"sustained-hits": 1})}}
		]
	},
	"victrix-honour-guard": {
		"name": "Victrix Honour Guard", "source_book_id": "000000139", "source_datasheet_id": "000004185", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 135, "points_by_models": {3: 135, 6: 265}, "third_plus_points_by_models": {3: 165, 6: 295}, "models": 3, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"default_loadout_by_role": {"Chapter Ancient": {"Banner of Macragge": 1, "Master-crafted Bolt Carbine": 1, "Master-crafted Power Weapon": 1}, "Chapter Champion": {"Blades of Honour": 1}, "Victrix Honour Guard": {"Master-crafted Bolt Carbine": 1, "Master-crafted Power Weapon": 1}},
		"model_loadouts": [victrix_honour_guard_model_loadout(0), victrix_honour_guard_model_loadout(1), victrix_honour_guard_model_loadout(2)],
		"ranged": [{"id": "master-crafted-bolt-carbine", "profiles": {"standard": _weapon("Master-crafted Bolt Carbine", 24.0, 2, 2, 5, -1, 2, {"rapid-fire": 1, "assault": true})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {})}}],
		"additional_weapon_profiles": {"melee": [{"id": "blades-of-honour", "profiles": {"standard": _weapon("Blades of Honour", 0.0, 6, 2, 6, -2, 2, {"twin-linked": true, "precision": true})}}]}
	},
	"marneus-calgar": {
		"name": "Marneus Calgar", "source_book_id": "000000139", "source_datasheet_id": "000004246", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 180, "points_by_models": {1: 180}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "TERMINATOR", "IMPERIUM", "CHAPTER MASTER", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [{"id": "gauntlets-of-ultramar-ranged", "profiles": {"standard": _weapon("Gauntlets of Ultramar", 18.0, 4, 2, 5, -2, 2, {"close-quarters": true, "twin-linked": true})}}],
		"melee": [
			{"id": "gauntlets-of-ultramar-melee", "profiles": {"standard": _weapon("Gauntlets of Ultramar", 0.0, 6, 2, 10, -3, 3, {"twin-linked": true})}},
			{"id": "gauntlets-of-ultramar-overhead-smash", "profiles": {"standard": _weapon("Gauntlets of Ultramar - Overhead Smash", 0.0, 1, 2, 14, -3, "D3+3", {"extra-attacks": true, "twin-linked": true})}}
		]
	},
	"kor-sarro-khan": {
		"name": "Kor'sarro Khan", "source_book_id": "000000139", "source_datasheet_id": "000002709", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 80, "points_by_models": {1: 80}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CAPTAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "WHITE SCARS"],
		"ranged": [
			{"id": "anzuq", "profiles": {"standard": _weapon("Anzuq", 18.0, 2, 3, 4, -1, 2, {"close-quarters": true, "devastating-wounds": true, "anti-infantry": 4})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "moonfang", "profiles": {"standard": _weapon("Moonfang", 0.0, 6, 2, 6, -3, 2, {"anti-character": 5, "precision": true, "devastating-wounds": true})}}]
	},
	"captain-titus": {
		"name": "Captain Titus", "source_book_id": "000000139", "source_datasheet_id": "000004187", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {1: 115}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CAPTAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-bolter", "profiles": {"standard": _weapon("Master-crafted Bolter", 24.0, 2, 2, 5, -1, 2, {"assault": true, "rapid-fire": 1, "heavy": true})}}
		],
		"melee": [{"id": "master-crafted-chainsword", "profiles": {"standard": _weapon("Master-crafted Chainsword", 0.0, 8, 2, 5, -1, 2, {"anti-non-monster-vehicle": 2})}}]
	},
	"wardens-of-ultramar": {
		"name": "Wardens of Ultramar", "source_book_id": "000000139", "source_datasheet_id": "000004188", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {6: 115}, "max_supported_copies": 1, "models": 6, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EPIC HERO", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"model_loadouts": [wardens_model_loadout(0), wardens_model_loadout(1), wardens_model_loadout(2), wardens_model_loadout(3), wardens_model_loadout(4), wardens_model_loadout(5)],
		"ranged": [{"id": "archeotech-laspistol", "profiles": {"standard": _weapon("Archeotech Laspistol", 12.0, 1, 3, 4, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 2, 4, -2, 1, {})}}]
	},
	"kayvaan-shrike": {
		"name": "Kayvaan Shrike", "source_book_id": "000000139", "source_datasheet_id": "000002708", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 95, "points_by_models": {1: 95}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 4, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "CAPTAIN", "EPIC HERO", "PHOBOS", "SMOKE", "JUMP PACK", "IMPERIUM", "FLY", "EXPLOSIVES", "ADEPTUS ASTARTES", "RAVEN GUARD"],
		"ranged": [{"id": "blackout", "profiles": {"standard": _weapon("Blackout", 18.0, 1, 2, 5, -1, 2, {"precision": true, "close-quarters": true})}}],
		"melee": [{"id": "ravens-talons", "profiles": {"standard": _weapon("Raven's Talons", 0.0, 7, 2, 5, -2, 2, {"precision": true, "twin-linked": true})}}]
	},
	"chief-librarian-tigurius": {
		"name": "Chief Librarian Tigurius", "source_book_id": "000000139", "source_datasheet_id": "000001611", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {1: 115}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "TACTICUS", "PSYKER", "EXPLOSIVES", "EPIC HERO", "CHARACTER", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "storm-of-the-emperors-wrath", "profiles": {"standard": _weapon("Storm of the Emperor's Wrath", 18.0, "D3+6", 2, 6, -2, 2, {"psychic": true, "blast": 1})}}
		],
		"melee": [{"id": "rod-of-tigurius", "profiles": {"standard": _weapon("Rod of Tigurius", 0.0, 5, 2, 7, -2, 2, {"psychic": true})}}]
	},
	"caanok-var": {
		"name": "Caanok Var", "source_book_id": "000000139", "source_datasheet_id": "000004166", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 100, "points_by_models": {1: 100}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "TERMINATOR", "IMPERIUM", "EPIC HERO", "CHARACTER", "CAPTAIN", "ADEPTUS ASTARTES", "IRON HANDS"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 2, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "axiom", "profiles": {"standard": _weapon("Axiom", 0.0, 5, 2, 8, -3, 2, {"cleave": 1})}}]
	},
	"company-heroes": {
		"name": "Company Heroes", "source_book_id": "000000139", "source_datasheet_id": "000002772", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 125, "points_by_models": {4: 125}, "third_plus_points_by_models": {4: 145}, "models": 4, "base_radius_inches": 40.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"default_loadout_by_role": {
			"Ancient": {"combat knife": 1, "master-crafted bolt pistol": 1, "master-crafted bolt rifle": 1},
			"Company Champion": {"master-crafted bolt pistol": 1, "master-crafted power weapon": 1},
			"Company Veteran with Bolt Rifle": {"combat knife": 1, "master-crafted bolt pistol": 1, "master-crafted bolt rifle": 1},
			"Company Veteran with Heavy Bolter": {"combat knife": 1, "master-crafted bolt pistol": 1, "master-crafted heavy bolter": 1}},
		"model_loadouts": [company_heroes_model_loadout(0), company_heroes_model_loadout(1), company_heroes_model_loadout(2), company_heroes_model_loadout(3)],
		"ranged": [{"id": "master-crafted-bolt-pistol", "profiles": {"standard": _weapon("Master-crafted Bolt Pistol", 12.0, 1, 3, 5, -1, 2, {"close-quarters": true})}}],
		"melee": [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 5, 3, 5, -1, 1, {})}}]
	},
	"outrider-squad": {
		"name": "Outrider Squad", "source_book_id": "000000139", "source_datasheet_id": "000002712", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 80, "points_by_models": {3: 80, 6: 160}, "third_plus_points_by_models": {3: 80, 6: 160}, "models": 3,
		"base_size_source_mm": [90, 52], "base_geometry": "oval", "base_radius_inches": 45.0 / 25.4, "geometry_scope": "90mm bounding-circle proxy",
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["RAVENWING", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "twin-bolt-rifle", "profiles": {"standard": _weapon("Twin Bolt Rifle", 24.0, 2, 2, 5, -1, 1, {"twin-linked": true, "assault": true, "rapid-fire": 2})}}
		],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "plasma-pistol", "profiles": {
				"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
				"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 3, 3, 5, -2, 1, {})}},
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
		]}
	},
	"gladiator-reaper": {
		"name": "Gladiator Reaper", "source_book_id": "000000139", "source_datasheet_id": "000001667", "source_role": "Vehicle", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 165, "points_by_models": {1: 165}, "third_plus_points_by_models": {1: 185}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 50.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "SMOKE", "FRAME", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "defensive-array", "profiles": {"standard": _weapon("Defensive Array", 24.0, 12, 3, 5, -1, 1, {"rapid-fire": 12})}},
			{"id": "twin-heavy-onslaught-gatling-cannon", "profiles": {"standard": _gladiator_reaper_cannon()}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"gladiator-valiant": {
		"name": "Gladiator Valiant", "source_book_id": "000000139", "source_datasheet_id": "000001825", "source_role": "Vehicle", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 165, "points_by_models": {1: 165}, "third_plus_points_by_models": {1: 185}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 50.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "FRAME", "IMPERIUM", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "defensive-array", "profiles": {"standard": _weapon("Defensive Array", 24.0, 6, 3, 5, -1, 1, {"rapid-fire": 6})}},
			{"id": "multi-melta-left", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "multi-melta-right", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "twin-las-talon", "profiles": {"standard": _weapon("Twin Las-talon", 36.0, 2, 3, 10, -3, "D3+3", {"twin-linked": true})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"gladiator-lancer": {
		"name": "Gladiator Lancer", "source_book_id": "000000139", "source_datasheet_id": "000002705", "source_role": "Vehicle", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 160, "points_by_models": {1: 160}, "third_plus_points_by_models": {1: 180}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 50.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "SMOKE", "FRAME", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "defensive-array", "profiles": {"standard": _weapon("Defensive Array", 24.0, 6, 3, 5, -1, 1, {"rapid-fire": 6})}},
			{"id": "laser-destroyer", "profiles": {"standard": _weapon("Laser Destroyer", 72.0, 2, 3, 14, -3, "D6+3", {"heavy": true})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"land-speeder": {
		"name": "Land Speeder", "source_book_id": "000000139", "source_datasheet_id": "000002711", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 105, "points_by_models": {1: 105}, "third_plus_points_by_models": {1: 105}, "max_supported_copies": 3, "models": 1,
		"base_size_source_mm": [105, 70], "base_geometry": "oval", "base_radius_inches": 52.5 / 25.4, "geometry_scope": "105 x 70 mm bounding-circle proxy",
		"stats": {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "FRAME", "FLY", "IMPERIUM", "RAVENWING", "SPEEDER", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "onslaught-gatling-cannon", "profiles": {"standard": _land_speeder_onslaught()}},
			{"id": "stormfury-missile-launcher", "profiles": {"standard": _weapon("Stormfury Missile Launcher", 48.0, 1, 3, 10, -3, "D3+3", {})}}
		],
		"melee": [{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "pyrecannon", "profiles": {"standard": _weapon("Pyrecannon", 12.0, 4, 0, 6, -1, 1, {"blast": 2, "torrent": true})}}], "melee": []}
	},
	"invader-atvs": {
		"name": "Invader ATVs", "source_book_id": "000000139", "source_datasheet_id": "000004247", "source_role": "Mounted", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 65, "points_by_models": {1: 65, 2: 130}, "third_plus_points_by_models": {1: 75, 2: 140}, "wargear_costs": {"multi-melta": 5}, "max_supported_copies": 3, "models": 1,
		"base_size_source": "Use model", "base_geometry": "90 x 52 mm oval model-footprint proxy", "base_size_source_mm": [90, 52], "base_radius_inches": 45.0 / 25.4,
		"stats": {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "MOUNTED", "RAVENWING", "IMPERIUM", "FRAME", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			_onslaught_gatling_cannon(),
			{"id": "twin-bolt-rifle", "profiles": {"standard": _weapon("Twin Bolt Rifle", 24.0, 2, 2, 5, -1, 1, {"twin-linked": true, "assault": true, "rapid-fire": 2})}}
		],
		"melee": [{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 4, 3, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [_invader_atv_multi_melta()], "melee": []}
	},
	"storm-speeder-hammerstrike": {
		"name": "Storm Speeder Hammerstrike", "source_book_id": "000000139", "source_datasheet_id": "000000114", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 140, "points_by_models": {1: 140}, "third_plus_points_by_models": {1: 150}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "FLY", "FRAME", "RAVENWING", "IMPERIUM", "ADEPTUS ASTARTES", "SPEEDER"],
		"ranged": [
			{"id": "hammerstrike-missile-launcher", "profiles": {"standard": _weapon("Hammerstrike Missile Launcher", 36.0, 2, 3, 10, -3, "D3+2", {})}},
			{"id": "krakstorm-grenade-launchers", "profiles": {"standard": _weapon("Krakstorm Grenade Launchers", 18.0, 2, 3, 9, -1, 2, {})}},
			{"id": "melta-destroyer", "profiles": {"standard": _weapon("Melta Destroyer", 18.0, 3, 3, 10, -3, "D3+2", {"melta": 3})}}
		],
		"melee": [{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"storm-speeder-hailstrike": {
		"name": "Storm Speeder Hailstrike", "source_book_id": "000000139", "source_datasheet_id": "000000124", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 110, "points_by_models": {1: 110}, "third_plus_points_by_models": {1: 120}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "RAVENWING", "SPEEDER", "IMPERIUM", "FLY", "FRAME", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "fragstorm-grenade-launchers", "profiles": {"standard": _weapon("Fragstorm Grenade Launchers", 18.0, 6, 3, 4, -1, 1, {"blast": 2, "ignores-cover": true})}},
			{"id": "ironhail-heavy-stubber-array", "profiles": {"standard": _weapon("Ironhail Heavy Stubber Array", 36.0, 6, 3, 4, -1, 1, {"rapid-fire": 6, "ignores-cover": true})}},
			{"id": "onslaught-gatling-cannon", "profiles": {"standard": _hailstrike_onslaught()}}
		],
		"melee": [{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"storm-speeder-thunderstrike": {
		"name": "Storm Speeder Thunderstrike", "source_book_id": "000000139", "source_datasheet_id": "000001610", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 140, "points_by_models": {1: 140}, "third_plus_points_by_models": {1: 150}, "max_supported_copies": 3, "models": 1,
		"base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "FLY", "RAVENWING", "SPEEDER", "IMPERIUM", "FRAME", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "stormfury-missile-launcher", "profiles": {"standard": _weapon("Stormfury Missile Launcher", 48.0, 2, 3, 10, -3, "D3+3", {})}},
			{"id": "thunderstrike-icarus-rocket-pod", "profiles": {"standard": _weapon("Thunderstrike Icarus Rocket Pod", 24.0, 6, 3, 6, -1, 2, {"anti-fly": 2})}},
			{"id": "thunderstrike-las-talon", "profiles": {"standard": _weapon("Thunderstrike Las-talon", 36.0, 2, 3, 10, -3, "D3+3", {})}}
		],
		"melee": [{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"lieutenant-with-combi-weapon": {
		"name": "Lieutenant with Combi-weapon", "source_book_id": "000000139", "source_datasheet_id": "000000076", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {1: 85}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "PHOBOS", "SMOKE", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "combi-weapon", "profiles": {
			"bolter": _weapon("Combi-weapon - Bolter", 24.0, 2, 2, 5, -1, 2, {"rapid-fire": 1, "assault": true}),
			"flamer": _weapon("Combi-weapon - Flamer", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "assault": true, "blast": 1})}}],
		"melee": [{"id": "paired-combat-blades", "profiles": {"standard": _weapon("Paired Combat Blades", 0.0, 6, 2, 5, -1, 1, {"sustained-hits": 1})}}]
	},
	"techmarine": {
		"name": "Techmarine", "source_book_id": "000000139", "source_datasheet_id": "000000140", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 55, "points_by_models": {1: 55}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "TACTICUS", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "forge-bolter", "profiles": {"standard": _weapon("Forge Bolter", 24.0, 3, 2, 5, -1, 2, {"sustained-hits": 1})}},
			{"id": "grav-pistol", "profiles": {"standard": _weapon("Grav-pistol", 12.0, 2, 2, 2, -1, 3, {"anti-vehicle": 2, "close-quarters": true})}}],
		"melee": [{"id": "omnissian-power-axe-and-servo-arm", "profiles": {"standard": _weapon("Omnissian Power Axe and Servo-arm", 0.0, 5, 3, 6, -2, 2, {})}}]
	},
	"infiltrator-squad": {
		"name": "Infiltrator Squad", "points": 85, "points_by_models": {5: 85, 10: 150}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "marksman-bolt-carbine", "profiles": {"standard": _weapon("Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 1, "precision": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"lieutenant-in-phobos-armour": {
		"name": "Lieutenant in Phobos Armour", "points": 40, "points_by_models": {1: 40}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 12.0, 1, 2, 5, -2, 2, {"precision": true, "close-quarters": true})}}],
		"melee": [{"id": "monomolecular-combat-blades", "profiles": {"standard": _weapon("Monomolecular Combat Blades", 0.0, 6, 2, 5, -1, 1, {"sustained-hits": 1, "precision": true})}}]
	},
	"captain-in-gravis-armour": {
		"name": "Captain in Gravis Armour", "points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "master-crafted-heavy-bolt-rifle", "profiles": {"standard": _weapon("Master-crafted Heavy Bolt Rifle", 30.0, 2, 2, 6, -1, 3, {"heavy": true, "assault": true, "rapid-fire": 1})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}]
	},
	"tor-garadon": {
		"name": "Tor Garadon", "source_book_id": "000000139", "source_datasheet_id": "000002473", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "max_supported_copies": 1, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "IMPERIUM", "GRAVIS", "EPIC HERO", "CHARACTER", "CAPTAIN", "ADEPTUS ASTARTES", "IMPERIAL FISTS"],
		"ranged": [{"id": "artificer-grav-gun", "profiles": {"standard": _weapon("Artificer Grav-gun", 18.0, 3, 2, 5, -1, 2, {"anti-vehicle": 2})}}],
		"melee": [{"id": "hand-of-defiance", "profiles": {"standard": _weapon("Hand of Defiance", 0.0, 5, 2, 12, -2, 2, {})}}]
	},
	"darnath-lysander": {
		"name": "Darnath Lysander", "source_book_id": "000000139", "source_datasheet_id": "000002105", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 160, "points_by_models": {1: 160}, "max_supported_copies": 1, "models": 1, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "TERMINATOR", "EPIC HERO", "CAPTAIN", "IMPERIUM", "ADEPTUS ASTARTES", "IMPERIAL FISTS"],
		"ranged": [],
		"melee": [{"id": "fist-of-dorn", "profiles": {"standard": _weapon("Fist of Dorn", 0.0, 5, 2, 10, -3, 3, {"devastating-wounds": true, "cleave": 1})}}]
	},
	"suboden-khan": {
		"name": "Suboden Khan", "source_book_id": "000000139", "source_datasheet_id": "000004167", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 105, "points_by_models": {1: 105}, "max_supported_copies": 1, "models": 1,
		"base_size_source_mm": [90, 52], "base_geometry": "oval", "geometry_scope": "90 x 52 mm bounding-circle proxy", "base_radius_inches": 45.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["MOUNTED", "EXPLOSIVES", "IMPERIUM", "CAPTAIN", "CHARACTER", "EPIC HERO", "ADEPTUS ASTARTES", "WHITE SCARS", "MOBILE"],
		"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "onslaught-gatling-cannon", "profiles": {"standard": _weapon("Onslaught gatling cannon", 24.0, 8, 2, 5, 0, 1, {"devastating-wounds": true})}}
		],
		"melee": [
			{"id": "stormtooth", "profiles": {"standard": _weapon("Stormtooth", 0.0, 6, 2, 7, -3, 2, {"anti-monster": 4, "anti-vehicle": 4, "lance": true})}},
			{"id": "power-sword", "profiles": {"standard": {"name": "Power Sword", "range_inches": 0.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1, "extra-attacks": true}, "target_restricted_traits": {"sustained-hits": ["MONSTER", "VEHICLE"]}}}}
		]
	},
	"iron-father-feirros": {
		"name": "Iron Father Feirros", "source_book_id": "000000139", "source_datasheet_id": "000000127", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {1: 85}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "GRAVIS", "CHARACTER", "EPIC HERO", "IMPERIUM", "ADEPTUS ASTARTES", "IRON HANDS"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "gorgons-wrath", "profiles": {"standard": _weapon("Gorgon's Wrath", 36.0, 3, 2, 6, -1, 2, {"rapid-fire": 2, "sustained-hits": 2})}}
		],
		"melee": [
			{"id": "harrowhand", "profiles": {"standard": _weapon("Harrowhand", 0.0, 6, 3, 7, -2, 2, {})}},
			{"id": "medusan-manipuli", "profiles": {"standard": _weapon("Medusan Manipuli", 0.0, 2, 3, 10, -2, 3, {"extra-attacks": true})}}
		]
	},
	"ancient-in-terminator-armour": {
		"name": "Ancient in Terminator Armour", "points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "ANCIENT", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 3, 5, -2, 2, {})}}]
	},
	"captain-in-terminator-armour": {
		"name": "Captain in Terminator Armour", "points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 2, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 6, 2, 6, -2, 2, {})}}]
	},
	"adrax-agatone": {
		"name": "Adrax Agatone", "source_book_id": "000000139", "source_datasheet_id": "000002100", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "third_plus_points_by_models": {1: 90}, "max_supported_copies": 1, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "SALAMANDERS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "drakkis", "profiles": {"standard": _weapon("Drakkis", 12.0, "D6+3", 0, 5, -1, 1, {"torrent": true, "close-quarters": true})}}],
		"melee": [{"id": "malleus-noctum", "profiles": {"standard": _weapon("Malleus Noctum", 0.0, 5, 2, 10, -2, 3, {"devastating-wounds": true})}}]
	},
	"kaius-konorius": {
		"name": "Kaius Konorius", "source_book_id": "000000139", "source_datasheet_id": "000004248", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 100, "points_by_models": {1: 100}, "third_plus_points_by_models": {1: 100}, "max_supported_copies": 1, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "TACTICUS", "ULTRAMARINES", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "severance-and-rebuke", "profiles": {
			"strike": _weapon("Severance and Rebuke - Strike", 0.0, 5, 2, 10, -3, 3, {"precision": true}),
			"sweep": _weapon("Severance and Rebuke - Sweep", 0.0, 6, 2, 6, -3, 2, {"cleave": 2})
		}}]
	},
	"chaplain-in-terminator-armour": {
		"name": "Chaplain in Terminator Armour", "points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHAPLAIN", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}]
	},
	"apothecary": {
		"name": "Apothecary", "points": 45, "points_by_models": {1: 45}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [
			{"id": "servo-armature", "profiles": {"standard": _weapon("Servo-armature", 0.0, 4, 3, 5, 0, 1, {})}},
			{"id": "reductor-pistol", "profiles": {"standard": _weapon("Reductor Pistol", 0.0, 1, 3, 5, -4, 2, {"extra-attacks": true})}}]
	},
	"ancient": {
		"name": "Ancient", "points": 40, "points_by_models": {1: 40}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-rifle", "profiles": {"focused": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"rapid-fire": 1, "heavy": true}), "saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 1, "assault": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 4, 3, 5, 0, 1, {})}}]
	},
	"bladeguard-ancient": {
		"name": "Bladeguard Ancient", "points": 70, "points_by_models": {1: 70}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "ANCIENT", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "relics-of-battle", "profiles": {"standard": _weapon("Relics of Battle", 0.0, 4, 3, 5, -2, 2, {})}}]
	},
	"bladeguard-veteran-squad": {
		"name": "Bladeguard Veteran Squad", "max_supported_copies": 2, "points": 90, "points_by_models": {3: 90, 6: 180}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-power-sword", "profiles": {"standard": _weapon("Master-crafted Power Sword", 0.0, 4, 3, 5, -2, 2, {})}}]
	},
	"judiciar": {
		"name": "Judiciar", "points": 50, "points_by_models": {1: 50}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0, "melee_invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "executioner-relic-blade", "profiles": {"standard": _weapon("Executioner Relic Blade", 0.0, 5, 2, 7, -2, 2, {"precision": true, "devastating-wounds": true})}}]
	},
	"chaplain": {
		"name": "Chaplain", "points": 60, "points_by_models": {1: 60}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}]
	},
	"chaplain-on-bike": {
		"name": "Chaplain on Bike", "source_book_id": "000000139", "source_datasheet_id": "000000094", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "third_plus_points_by_models": {1: 75}, "max_supported_copies": 3, "models": 1,
		"base_size_source_mm": [90, 52], "base_geometry": "oval", "base_radius_inches": 45.0 / 25.4, "geometry_scope": "90 x 52 mm bounding-circle proxy",
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["CHARACTER", "RAVENWING", "CHAPLAIN", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}},
			{"id": "twin-bolt-rifle", "profiles": {"standard": _weapon("Twin Bolt Rifle", 24.0, 2, 3, 5, -1, 1, {"twin-linked": true, "rapid-fire": 2})}}
		],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}]
	},
	"captain-on-bike": {
		"name": "Captain on Bike", "source_book_id": "000000139", "source_datasheet_id": "000002702", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 110, "points_by_models": {1: 110}, "third_plus_points_by_models": {1: 110}, "max_supported_copies": 3, "models": 1,
		"base_size_source_mm": [90, 52], "base_geometry": "oval", "base_radius_inches": 45.0 / 25.4, "geometry_scope": "90 x 52 mm bounding-circle proxy",
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["CHARACTER", "RAVENWING", "CAPTAIN", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "twin-bolt-rifle", "profiles": {"standard": _weapon("Twin Bolt Rifle", 24.0, 2, 2, 5, -1, 1, {"twin-linked": true, "assault": true, "rapid-fire": 2})}}
		],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 5, 3, 8, -2, 3, {"devastating-wounds": true})}}
		]}
	},
	"chaplain-with-jump-pack": {
		"name": "Chaplain With Jump Pack", "source_book_id": "000000139", "source_datasheet_id": "000000112", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "CHAPLAIN", "TACTICUS", "JUMP PACK", "IMPERIUM", "FLY", "EXPLOSIVES", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}]
	},
	"sternguard-veteran-squad": {
		"name": "Sternguard Veteran Squad", "points": 105, "points_by_models": {5: 105, 10: 210}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "artificer-firearm", "profiles": {
				"infernus": _weapon("Artificer Firearm - Infernus", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 2}),
				"purgatus": _weapon("Artificer Firearm - Purgatus", 24.0, 1, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}),
				"damnatus": _weapon("Artificer Firearm - Damnatus", 12.0, 1, 3, 9, -3, "D3+2", {"assault": true, "melta": 2})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 4, 3, 5, 0, 1, {})}}]
	},
	"eliminator-squad": {
		"name": "Eliminator Squad", "points": 85, "points_by_models": {3: 85}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-sniper-rifle", "profiles": {"standard": _weapon("Bolt Sniper Rifle", 36.0, 1, 3, 6, -2, 3, {"heavy": true, "precision": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"eradicator-squad-with-melta-rifles": {
		"name": "Eradicator Squad with Melta Rifles", "points": 100, "points_by_models": {3: 100, 6: 200}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "melta-rifle", "profiles": {
				"standard": _weapon("Melta Rifle", 18.0, 1, 3, 10, -3, "D3+2", {"melta": 2}),
				"hunter": _weapon("Melta Rifle - Hunter", 18.0, 1, 2, 12, -3, "D3+2", {"melta": 2, "hunter": ["Monster", "Vehicle"]})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"eradicator-squad-with-heavy-bolters": {
		"name": "Eradicator Squad with Heavy Bolters", "points": 100, "points_by_models": {3: 100, 6: 215}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 6, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "heavy": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"apothecary-biologis": {
		"name": "Apothecary Biologis", "points": 60, "points_by_models": {1: 60}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "APOTHECARY", "CHARACTER", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "servo-armature", "profiles": {"standard": _weapon("Servo-armature", 0.0, 4, 3, 5, 0, 1, {})}}]
	},
	"aggressor-squad": {
		"name": "Aggressor Squad", "points": 90, "points_by_models": {3: 90, 6: 180}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "flamestorm-gauntlets", "profiles": {
			"close_quarters": _weapon("Flamestorm Gauntlets - Close Quarters", 12.0, 3, 3, 4, -1, 1, {"close-quarters": true, "torrent": true, "twin-linked": true}),
			"ranged": _weapon("Flamestorm Gauntlets - Ranged", 12.0, 3, 3, 4, -1, 1, {"torrent": true, "twin-linked": true, "blast": 2})}}],
		"melee": [{"id": "twin-power-fists", "profiles": {"standard": _weapon("Twin Power Fists", 0.0, 3, 3, 8, -2, 2, {"twin-linked": true})}}]
	},
	"infernus-squad": {
		"name": "Infernus Squad", "points": 95, "points_by_models": {5: 95, 10: 190}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "pyreblaster", "profiles": {"standard": _weapon("Pyreblaster", 12.0, 3, 3, 5, -1, 1, {"torrent": true, "blast": 1})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"hellblaster-squad": {
		"name": "Hellblaster Squad", "points": 115, "points_by_models": {5: 115, 10: 230}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "plasma-incinerator", "profiles": {
				"standard": _weapon("Plasma Incinerator - Standard", 24.0, 2, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}),
				"supercharge": _weapon("Plasma Incinerator - Supercharge", 24.0, 2, 3, 8, -3, 2, {"assault": true, "rapid-fire": 1, "hazardous": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"intercessor-squad": {
		"name": "Intercessor Squad", "source_book_id": "000000139", "source_datasheet_id": "000001157", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {5: 85, 10: 170}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-rifle", "profiles": {
				"focused_fire": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"heavy": true, "rapid-fire": 1}),
				"saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 1})
			}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "grenade-launcher", "profiles": {"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}), "krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}},
				{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
				{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
			],
			"melee": [
				{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 5, 3, 5, -1, 1, {})}},
				{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
				{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}},
				{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
			]
		}
	},
	"assault-intercessor-squad": {
		"name": "Assault Intercessor Squad", "source_book_id": "000000139", "source_datasheet_id": "000001606", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {5: 85, 10: 170}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"close-quarters": true, "torrent": true})}},
				{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
			],
			"melee": [
				{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
				{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}},
				{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
			]
		}
	},
	"assault-intercessors-with-jump-packs": {
		"name": "Assault Intercessors With Jump Packs", "source_book_id": "000000139", "source_datasheet_id": "000002776", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 95, "points_by_models": {5: 95, 10: 190}, "max_supported_copies": 2, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "FLY", "JUMP PACK", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}]
	},
	"inceptor-squad": {
		"name": "Inceptor Squad", "source_book_id": "000000139", "source_datasheet_id": "000000125", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 130, "points_by_models": {3: 130, 6: 260}, "third_plus_points_by_models": {3: 150, 6: 280}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "GRAVIS", "JUMP PACK", "IMPERIUM", "FLY", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "assault-bolters", "profiles": {"standard": _weapon("Assault Bolters", 18.0, 3, 3, 5, -1, 2, {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true})}}],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "plasma-exterminators", "profiles": {
			"standard": _weapon("Plasma Exterminators - Standard", 18.0, 2, 3, 7, -2, 2, {"assault": true, "twin-linked": true, "close-quarters": true}),
			"supercharge": _weapon("Plasma Exterminators - Supercharge", 18.0, 2, 3, 8, -3, 3, {"assault": true, "twin-linked": true, "close-quarters": true, "hazardous": true})}}]}
	},
	"captain-with-jump-pack": {
		"name": "Captain With Jump Pack", "source_book_id": "000000139", "source_datasheet_id": "000000083", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "FLY", "JUMP PACK", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 8, 2, 5, -1, 1, {"sustained-hits": 1})}}]
	},
	"vanguard-veteran-squad-with-jump-packs": {
		"name": "Vanguard Veteran Squad With Jump Packs", "source_book_id": "000000139", "source_datasheet_id": "000000147", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 110, "points_by_models": {5: 110, 10: 220}, "third_plus_points_by_models": {5: 130, 10: 240}, "max_supported_copies": 2, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "FLY", "JUMP PACK", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"conditional_keywords": ["DEATHWING"],
		"default_loadout_by_role": {
			"Vanguard Veteran Sergeant with Jump Pack": {"heavy bolt pistol": 1, "relic blade": 1},
			"Vanguard Veteran with Jump Pack": {"heavy bolt pistol": 1, "master-crafted power weapon": 1}
		},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 3, 3, 5, -2, 2, {})}}],
		"additional_weapon_profiles": {
			"ranged": [{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}],
			"melee": [
				{"id": "relic-blade", "profiles": {"standard": _vanguard_relic_blade()}},
				{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
				{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
			]
		}
	},
	"heavy-intercessor-squad": {
		"name": "Heavy Intercessor Squad", "source_book_id": "000000139", "source_datasheet_id": "000001177", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {5: 115, 10: 230}, "models": 5, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolt-rifle", "profiles": {"standard": _weapon("Heavy Bolt Rifle", 30.0, 2, 3, 5, -1, 2, {"heavy": true, "rapid-fire": 1})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"heavy": true, "sustained-hits": 1, "rapid-fire": 2})}}
		], "melee": []}
	},
	"terminator-squad": {
		"name": "Terminator Squad", "source_book_id": "000000139", "source_datasheet_id": "000001183", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 190, "points_by_models": {5: 190, 10: 380}, "third_plus_points_by_models": {5: 230, 10: 420}, "wargear_costs": {"cyclone-missile-launcher": 10}, "models": 5, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "IMPERIUM", "TERMINATOR", "TERMINATOR SQUAD"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 2})}},
			{"id": "cyclone-missile-launcher", "profiles": {
				"frag": _weapon("Cyclone Missile Launcher - Frag", 36.0, 8, 3, 4, -1, 1, {"blast": 2}),
				"krak": _weapon("Cyclone Missile Launcher - Krak", 36.0, 2, 3, 10, -2, "D3+3", {})}}
		], "melee": [
			{"id": "chainfist", "profiles": {
				"standard": _weapon("Chainfist - Standard", 0.0, 2, 4, 8, -2, 2, {}),
				"hunter": _weapon("Chainfist - Hunter", 0.0, 3, 3, 12, -2, 3, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 3, 5, -2, 1, {})}}
		]}
	},
	"terminator-assault-squad": {
		"name": "Terminator Assault Squad", "source_book_id": "000000139", "source_datasheet_id": "000000118", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 170, "points_by_models": {5: 170, 10: 340}, "third_plus_points_by_models": {5: 210, 10: 380}, "wargear_costs": {"storm-shield": 5}, "models": 5, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "IMPERIUM", "TERMINATOR", "DEATHWING", "ADEPTUS ASTARTES"],
		"ranged": [],
		"melee": [{"id": "twin-lightning-claws", "profiles": {"standard": _weapon("Twin Lightning Claws", 0.0, 6, 3, 5, -2, 1, {"twin-linked": true})}}],
		"additional_weapon_profiles": {"ranged": [], "melee": [
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 3, 8, -2, 3, {"devastating-wounds": true})}}
		]}
	},
	"librarian-in-terminator-armour": {
		"name": "Librarian in Terminator Armour", "source_book_id": "000000139", "source_datasheet_id": "000000079", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM", "TERMINATOR", "PSYKER", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "smite", "profiles": {
				"focused": _weapon("Smite - Focused Witchfire", 24.0, "D3+3", 3, 6, -2, 2, {"devastating-wounds": true, "psychic": true, "hazardous": true}),
				"witchfire": _weapon("Smite - Witchfire", 24.0, "D6", 3, 6, -1, 2, {"psychic": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "force-weapon", "profiles": {"standard": _weapon("Force Weapon", 0.0, 4, 3, 6, -2, 2, {"psychic": true})}}]
	},
	"librarian": {
		"name": "Librarian", "source_book_id": "000000139", "source_datasheet_id": "000002266", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "TACTICUS", "PSYKER", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "smite", "profiles": {
				"focused": _weapon("Smite - Focused Witchfire", 24.0, "D3+3", 3, 6, -2, 2, {"devastating-wounds": true, "psychic": true, "hazardous": true}),
				"witchfire": _weapon("Smite - Witchfire", 24.0, "D6", 3, 6, -1, 2, {"psychic": true})}}
		],
		"melee": [{"id": "force-weapon", "profiles": {"standard": _weapon("Force Weapon", 0.0, 4, 3, 6, -2, 2, {"psychic": true})}}]
	},
	"aethon-shaan": {
		"name": "Aethon Shaan", "source_book_id": "000000139", "source_datasheet_id": "000004148", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 105, "points_by_models": {1: 105}, "models": 1, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 14, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CHAPTER MASTER", "JUMP PACK", "FLY", "TACTICUS", "SMOKE", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES", "RAVEN GUARD"],
		"ranged": [{"id": "heavy-bolt-pistol-aethon-shaan", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [_aethon_claws()]
	},
	"librarian-in-phobos-armour": {
		"name": "Librarian in Phobos Armour", "source_book_id": "000000139", "source_datasheet_id": "000000119", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4, "scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "PSYKER", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "smite", "profiles": {
				"focused": _weapon("Smite - Focused Witchfire", 24.0, "D3+3", 3, 6, -2, 2, {"devastating-wounds": true, "psychic": true, "hazardous": true}),
				"witchfire": _weapon("Smite - Witchfire", 24.0, "D6", 3, 6, -1, 2, {"psychic": true})}}],
		"melee": [{"id": "force-weapon", "profiles": {"standard": _weapon("Force Weapon", 0.0, 4, 3, 6, -2, 2, {"psychic": true})}}]
	},
	"captain-in-phobos-armour": {
		"name": "Captain in Phobos Armour", "source_book_id": "000000139", "source_datasheet_id": "000002701", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4, "scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "CAPTAIN", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "instigator-bolt-carbine", "profiles": {"standard": _weapon("Instigator Bolt Carbine", 24.0, 1, 2, 4, -2, 2, {"precision": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 6, 2, 5, -1, 1, {"precision": true, "sustained-hits": 1})}}]
	},
	"scout-squad": {
		"name": "Scout Squad", "source_book_id": "000000139", "source_datasheet_id": "000001160", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 65, "points_by_models": {5: 65, 10: 120}, "models": 5, "base_radius_inches": 14.25 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 4, "save_target": 4, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "SMOKE", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}}],
		"melee": [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 3, 3, 4, -1, 1, {})}}]
	},
	"incursor-squad": {
		"name": "Incursor Squad", "source_book_id": "000000139", "source_datasheet_id": "000001159", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {5: 90, 10: 170}, "third_plus_points_by_models": {5: 100, 10: 180}, "max_supported_copies": 2, "models": 5, "base_radius_inches": 16.0 / 25.4, "scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "SMOKE", "PHOBOS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "occulus-bolt-carbine", "profiles": {"standard": _weapon("Occulus Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"assault": true, "ignores-cover": true})}}
		],
		"melee": [{"id": "paired-combat-blades", "profiles": {"standard": _weapon("Paired Combat Blades", 0.0, 3, 3, 5, -1, 1, {"sustained-hits": 1})}}]
	},
	"reiver-squad": {
		"name": "Reiver Squad", "source_book_id": "000000139", "source_datasheet_id": "000002718", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {5: 85, 10: 165}, "models": 5, "base_radius_inches": 16.0 / 25.4, "scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-carbine", "profiles": {"standard": _weapon("Bolt Carbine", 18.0, 3, 3, 5, -1, 1, {"precision": true, "assault": true})}},
			{"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 12.0, 1, 3, 5, -2, 1, {"close-quarters": true, "precision": true})}}
		],
		"melee": [{"id": "monomolecular-combat-knife", "profiles": {"standard": _weapon("Monomolecular Combat Knife", 0.0, 4, 3, 5, -1, 1, {"precision": true})}}]
	},
	"captain": {
		"name": "Captain", "source_book_id": "000000139", "source_datasheet_id": "000000073", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-bolter", "profiles": {"standard": _weapon("Master-crafted Bolter", 24.0, 2, 2, 5, -1, 2, {"assault": true, "rapid-fire": 1})}}
		],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}]
	},
	"lieutenant": {
		"name": "Lieutenant", "source_book_id": "000000139", "source_datasheet_id": "000001346", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 50, "points_by_models": {1: 50}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"options": {"ranged_packages": ["default", "heavy-bolt-pistol", "power-weapon", "heavy-pistol-power-weapon", "plasma-pistol", "heavy-pistol-plasma-pistol", "power-fist", "heavy-pistol-power-fist", "neo-volkite"], "fists_replacements": ["ceramite-fists", "power-weapon", "power-fist"], "storm_shield_requires": "neo-volkite"},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-bolter", "profiles": {"standard": _weapon("Master-crafted Bolter", 24.0, 2, 2, 5, -1, 2, {})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 5, 2, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "neo-volkite-pistol", "profiles": {"standard": _weapon("Neo-volkite Pistol", 12.0, 1, 2, 5, 0, 2, {"close-quarters": true, "devastating-wounds": true})}},
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 6, -2, 2, {})}},
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 4, 2, 8, -2, 2, {})}}
		]}
	},
	"roboute-guilliman": {
		"name": "Roboute Guilliman", "source_book_id": "000000139", "source_datasheet_id": "000000138", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 415, "points_by_models": {1: 415}, "models": 1, "max_supported_copies": 1, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 16, "leadership_target": 5, "objective_control": 4, "invulnerable_target": 4},
		"keywords": ["MONSTER", "CHARACTER", "EPIC HERO", "IMPERIUM", "MOBILE", "PRIMARCH", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [{"id": "hand-of-dominion-ranged", "physical_weapon_id": "hand-of-dominion", "profiles": {"standard": _weapon("Hand of Dominion", 36.0, 4, 2, 6, -2, 2, {"rapid-fire": 2, "sustained-hits": 1})}}],
		"melee": [
			{"id": "emperors-sword", "profiles": {"standard": _weapon("Emperor’s Sword", 0.0, 10, 2, 10, -3, 2, {"devastating-wounds": true, "cleave": 2})}},
			{"id": "hand-of-dominion-melee", "physical_weapon_id": "hand-of-dominion", "profiles": {"standard": _weapon("Hand of Dominion", 0.0, 7, 2, 14, -4, 4, {"lethal-hits": true})}}
		]
	},
	"firestrike-servo-turrets": {
		"name": "Firestrike Servo-turrets", "source_book_id": "000000139", "source_datasheet_id": "000000086", "source_role": "Artillery", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 80, "points_by_models": {1: 80, 2: 160}, "models": 1, "base_radius_inches": 40.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ARTILLERY", "VEHICLE", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "twin-firestrike-las-talon", "profiles": {"standard": _weapon("Twin Firestrike Las-talon", 36.0, 2, 2, 10, -3, "D3+3", {"twin-linked": true})}}],
		"melee": [{"id": "hovering-bulk", "profiles": {"standard": _weapon("Hovering Bulk", 0.0, 3, 3, 5, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "twin-firestrike-autocannon", "profiles": {"standard": _weapon("Twin Firestrike Autocannon", 48.0, 4, 2, 9, -1, 3, {"twin-linked": true, "rapid-fire": 2})}}]}
	},
	"ballistus-dreadnought": {
		"name": "Ballistus Dreadnought", "source_book_id": "000000139", "source_datasheet_id": "000000091", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 150, "points_by_models": {1: 150}, "third_plus_points_by_models": {1: 170}, "models": 1, "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0},
		"keywords": ["DREADNOUGHT", "IMPERIUM", "WALKER", "DEATHWING", "VEHICLE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "ballistus-lascannon", "profiles": {"standard": _weapon("Ballistus Lascannon", 48.0, 2, 3, 12, -3, "D3+3", {})}},
			{"id": "ballistus-missile-launcher", "profiles": {
				"frag": _weapon("Ballistus Missile Launcher - Frag", 48.0, "D6+6", 3, 5, -1, 1, {"blast": 2}),
				"krak": _weapon("Ballistus Missile Launcher - Krak", 48.0, 2, 3, 10, -2, "D3+3", {})}},
			{"id": "storm-bolters", "profiles": {"standard": _weapon("Storm Bolters", 24.0, 4, 3, 5, -1, 1, {"rapid-fire": 4})}}
		],
		"melee": [{"id": "armoured-feet", "profiles": {"standard": _weapon("Armoured Feet", 0.0, 5, 3, 7, 0, 1, {})}}]
	},
	"redemptor-dreadnought": {
		"name": "Redemptor Dreadnought", "source_book_id": "000000139", "source_datasheet_id": "000002717", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 170, "points_by_models": {1: 170}, "third_plus_points_by_models": {1: 190}, "models": 1, "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0},
		"keywords": ["DREADNOUGHT", "IMPERIUM", "WALKER", "DEATHWING", "VEHICLE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "fragstorm-grenade-launchers", "profiles": {"standard": _weapon("Fragstorm Grenade Launchers", 18.0, 6, 3, 4, -1, 1, {"blast": 2})}},
		{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
			_redemptor_heavy_onslaught()
		],
		"melee": [{"id": "redemptor-fist", "profiles": {"standard": _weapon("Redemptor Fist", 0.0, 5, 3, 12, -3, "D3+3", {})}}],
		"wargear_costs": {"macro-plasma-incinerator": 10},
		"additional_weapon_profiles": {
			"fragstorm": {"id": "fragstorm-grenade-launchers", "profiles": {"standard": _weapon("Fragstorm Grenade Launchers", 18.0, 6, 3, 4, -1, 1, {"blast": 2})}},
			"storm_bolters": {"id": "storm-bolters", "profiles": {"standard": _weapon("Storm Bolters", 24.0, 4, 3, 5, -1, 1, {"rapid-fire": 4})}},
			"heavy_flamer": {"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"blast": 2, "torrent": true})}},
			"onslaught": _redemptor_onslaught(),
			"macro_plasma": {"id": "macro-plasma-incinerator", "profiles": {
				"standard": _weapon("Macro Plasma Incinerator - Standard", 36.0, "D3+3", 3, 9, -3, 2, {"blast": 1}),
				"supercharge": _weapon("Macro Plasma Incinerator - Supercharge", 36.0, "D3+3", 3, 10, -4, 3, {"blast": 1, "hazardous": true})}},
			"icarus_rocket_pod": {"id": "icarus-rocket-pod", "profiles": {"standard": _weapon("Icarus Rocket Pod", 24.0, 3, 3, 6, -1, 2, {"anti-fly": 2})}}
		}
	},
	"brutalis-dreadnought": {
		"name": "Brutalis Dreadnought", "source_book_id": "000000139", "source_datasheet_id": "000000136", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 160, "points_by_models": {1: 160}, "third_plus_points_by_models": {1: 180}, "models": 1, "max_supported_copies": 3, "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0},
		"keywords": ["DREADNOUGHT", "IMPERIUM", "WALKER", "DEATHWING", "VEHICLE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-rifles", "profiles": {"standard": _weapon("Bolt Rifles", 24.0, 4, 3, 5, -1, 1, {"twin-linked": true})}},
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2})}},
			{"id": "twin-icarus-ironhail-heavy-stubber", "profiles": {"standard": _weapon("Twin Icarus Ironhail Heavy Stubber", 36.0, 3, 3, 4, -1, 1, {"anti-fly": 3, "rapid-fire": 3, "twin-linked": true})}}
		],
		"melee": [{"id": "brutalis-fists", "profiles": {"standard": _weapon("Brutalis Fists", 0.0, 6, 3, 12, -3, "D3+3", {"twin-linked": true})}}],
		"additional_weapon_profiles": {
			"brutalis_talons": _brutalis_talons(),
			"twin_heavy_bolter": {"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2})}},
			"twin_multi_melta": {"id": "twin-multi-melta", "profiles": {"standard": _weapon("Twin Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"twin-linked": true, "melta": 3})}}
		}
	},
	"invictor-tactical-warsuit": {
		"name": "Invictor Tactical Warsuit", "source_book_id": "000000139", "source_datasheet_id": "000001156", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 135, "points_by_models": {1: 135}, "third_plus_points_by_models": {1: 150}, "models": 1, "max_supported_copies": 3, "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0},
		"keywords": ["WALKER", "PHOBOS", "IMPERIUM", "VEHICLE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "fragstorm-grenade-launcher", "profiles": {"standard": _weapon("Fragstorm Grenade Launcher", 18.0, 3, 3, 4, -1, 1, {"blast": 1})}},
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2})}},
			{"id": "incendium-cannon", "profiles": {"standard": _weapon("Incendium Cannon", 12.0, 4, 0, 6, -1, 2, {"torrent": true, "blast": 2})}},
			{"id": "ironhail-heavy-stubbers", "profiles": {"standard": _weapon("Ironhail Heavy Stubbers", 36.0, 6, 3, 4, -1, 1, {"rapid-fire": 6})}}
		],
		"melee": [{"id": "invictor-fist", "profiles": {"standard": _weapon("Invictor Fist", 0.0, 5, 3, 12, -2, 3, {})}}],
		"additional_weapon_profiles": {"twin_ironhail_autocannon": {"id": "twin-ironhail-autocannon", "profiles": {"standard": _weapon("Twin Ironhail Autocannon", 48.0, 4, 3, 9, -1, 3, {"twin-linked": true})}}}
	},
	"desolation-squad": {
		"name": "Desolation Squad", "source_book_id": "000000139", "source_datasheet_id": "000002270", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 140, "points_by_models": {5: 140}, "third_plus_points_by_models": {5: 150}, "max_supported_copies": 3, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "TACTICUS", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": desolation_weapons("superfrag"),
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}],
		"wargear_costs": {"vengor-launcher": 5},
		"additional_weapon_profiles": {"superkrak": {"id": "superkrak-rocket-launcher", "profiles": {"standard": _weapon("Superkrak Rocket Launcher", 48.0, 1, 3, 10, -2, "D3+3", {"heavy": true})}},
			"vengor": {"id": "vengor-launcher", "profiles": {"standard": _weapon("Vengor Launcher", 48.0, 4, 3, 7, -1, 2, {"blast": 1, "indirect-fire": true, "heavy": true})}}}
	},
	"vulkan-hestan": {
		"name": "Vulkan He’stan", "source_book_id": "000000139", "source_datasheet_id": "000002726", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 105, "points_by_models": {1: 105}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "SALAMANDERS"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "gauntlet-of-the-forge", "profiles": {"standard": _weapon("Gauntlet of the Forge", 12.0, "D6+3", 0, 6, -1, 1, {"torrent": true, "close-quarters": true})}}
		],
		"melee": [{"id": "spear-of-vulkan", "profiles": {"standard": _weapon("Spear of Vulkan", 0.0, 6, 2, 7, -2, 2, {"devastating-wounds": true})}}]
	}
}

static func desolation_weapons(rocket_kind: String = "superfrag") -> Array[Dictionary]:
	var rocket := _weapon("Superfrag Rocket Launcher", 48.0, 4, 3, 5, -1, 1, {"blast": 1, "heavy": true})
	if rocket_kind == "superkrak": rocket = _weapon("Superkrak Rocket Launcher", 48.0, 1, 3, 10, -2, "D3+3", {"heavy": true})
	if rocket_kind == "vengor": rocket = _weapon("Vengor Launcher", 48.0, 4, 3, 7, -1, 2, {"blast": 1, "indirect-fire": true, "heavy": true})
	return [
		{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		{"id": "castellan-launcher", "profiles": {"standard": _weapon("Castellan Launcher", 24.0, 2, 3, 5, -1, 1, {"heavy": true})}},
		{"id": "rocket-launcher", "profiles": {"standard": rocket}}
	]

static func catalog() -> Dictionary:
	# A fresh dictionary keeps consumers from mutating the reference source.
	var result := _build_profiles()
	result.merge(transport_profiles(), true)
	return result

static func _aethon_claws() -> Dictionary:
	var weapon := {"id": "claws-of-severax", "profiles": {"standard": _weapon("Claws of Severax", 0.0, 7, 2, 5, -2, 2, {"twin-linked": true, "sustained-hits": 2})}}
	weapon.profiles.standard.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func profile(identity: String) -> Dictionary:
	var result: Dictionary = _build_profiles().get(identity, {})
	if result.is_empty(): result = transport_profiles().get(identity, {})
	return result.duplicate(true)

static func transport_profiles() -> Dictionary:
	var file := FileAccess.open("res://data/edition_11/space_marines_transport_profiles.json", FileAccess.READ)
	if file == null: return {}
	var document: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not document is Dictionary or document.get("source_book_id", "") != "000000139" or document.get("source_export_updated_at", "") != "2026-10-16T21:03:46+03:00": return {}
	var result: Dictionary = document.get("profiles", {}).duplicate(true)
	for identity: String in result:
		var source: Dictionary = result[identity]
		for stat_name: String in ["movement_inches", "toughness", "save_target", "wounds", "leadership_target", "objective_control", "invulnerable_target", "damaged_threshold"]:
			var stat: Variant = source.get("stats", {}).get(stat_name)
			if (stat is int or stat is float) and is_finite(float(stat)) and float(stat) == floor(float(stat)):
				source.stats[stat_name] = int(stat)
		_normalize_transport_weapons(source.get("ranged", []))
		_normalize_transport_weapons(source.get("melee", []))
		for weapon_group: Array in source.get("additional_weapon_profiles", {}).values(): _normalize_transport_weapons(weapon_group)
		var points: Dictionary = source.get("points_by_models", {})
		var third: Dictionary = source.get("third_plus_points_by_models", {})
		source.points_by_models = {1: int(points.get("1", points.get(1, source.get("points", 0))))}
		source.third_plus_points_by_models = {1: int(third.get("1", third.get(1, source.get("points", 0))))}
		result[identity] = source
	return result

static func _normalize_transport_weapons(weapons: Array) -> void:
	for weapon: Variant in weapons:
		if not weapon is Dictionary or not weapon.get("profiles", {}) is Dictionary: continue
		for profile_name: String in weapon.profiles:
			var stats: Variant = weapon.profiles[profile_name]
			if not stats is Dictionary: continue
			var ap: Variant = stats.get("ap")
			if ap is String and str(ap).is_valid_int(): stats.ap = int(ap)
			for stat_name: String in ["attacks", "skill", "strength", "ap"]:
				var stat: Variant = stats.get(stat_name)
				if (stat is int or stat is float) and is_finite(float(stat)) and float(stat) == floor(float(stat)):
					stats[stat_name] = int(stat)
			var damage: Variant = stats.get("damage")
			if (damage is int or damage is float) and is_finite(float(damage)) and float(damage) == floor(float(damage)):
				stats.damage = int(damage)

static func captain_bike_weapons(plasma_pistol: bool = false, thunder_hammer: bool = false) -> Dictionary:
	var data := profile("captain-on-bike")
	var ranged: Array = data.ranged.duplicate(true)
	if plasma_pistol: ranged[0] = data.additional_weapon_profiles.ranged[0].duplicate(true)
	var melee: Dictionary = data.additional_weapon_profiles.melee[0].duplicate(true) if thunder_hammer else data.melee[0].duplicate(true)
	return {"ranged": ranged, "melee": [melee]}

static func company_heroes_model_loadout(model_index: int) -> Dictionary:
	var bolt_pistol := {"id": "master-crafted-bolt-pistol", "profiles": {"standard": _weapon("Master-crafted Bolt Pistol", 12.0, 1, 3, 5, -1, 2, {"close-quarters": true})}}
	var rifle := {"id": "master-crafted-bolt-rifle", "profiles": {"standard": _weapon("Master-crafted Bolt Rifle", 24.0, 2, 3, 5, -1, 2, {"assault": true, "rapid-fire": 1})}}
	var heavy_bolter := {"id": "master-crafted-heavy-bolter", "profiles": {"standard": _weapon("Master-crafted Heavy Bolter", 36.0, 4, 3, 6, -1, 2, {"assault": true, "rapid-fire": 2, "heavy": true, "sustained-hits": 1})}}
	var knife := {"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 5, 3, 5, -1, 1, {})}}
	var power_weapon := {"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {"precision": true})}}
	match model_index:
		0: return {"role": "ancient", "ranged": [bolt_pistol.duplicate(true), rifle.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ANCIENT"]}
		1: return {"role": "company-champion", "ranged": [bolt_pistol.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "CHAMPION"]}
		2: return {"role": "bolt-rifle-veteran", "ranged": [bolt_pistol.duplicate(true), rifle.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]}
		3: return {"role": "heavy-bolter-veteran", "ranged": [bolt_pistol.duplicate(true), heavy_bolter.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]}
	return {}

static func wardens_model_loadout(model_index: int) -> Dictionary:
	var stats: Dictionary
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var laser := {"id": "archeotech-laspistol", "profiles": {"standard": _weapon("Archeotech Laspistol", 12.0, 1, 3, 4, -1, 1, {"close-quarters": true})}}
	var power := {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 2, 4, -2, 1, {})}}
	match model_index:
		0: # Aemelia Minervas
			stats = {"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
			ranged = [laser.duplicate(true)]
			melee = [power.duplicate(true)]
		1: # Ancient Gadriel
			stats = {"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
			ranged = [{"id": "bolt-rifle", "profiles": {
				"focused-fire": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"heavy": true, "rapid-fire": 1}),
				"saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 1})}}]
			melee = [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 4, 3, 5, 0, 1, {})}}]
		2: # Dainal Kornelius (model table spells the surname Komelius)
			stats = {"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
			ranged = [{"id": "astropathic-blast", "profiles": {"standard": _weapon("Astropathic Blast", 12.0, 3, 3, 4, -1, 1, {"psychic": true, "blast": 1})}}]
			melee = [{"id": "force-stave", "profiles": {"standard": _weapon("Force Stave", 0.0, 1, 2, 5, -2, 2, {"psychic": true})}}]
		3: # Gaius Silva
			stats = {"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5}
			ranged = [laser.duplicate(true)]
			melee = [power.duplicate(true)]
		4: # Lucia Vestha
			stats = {"toughness": 3, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
			ranged = [laser.duplicate(true)]
			melee = [{"id": "ultramarian-combat-weapons", "profiles": {"standard": _weapon("Ultramarian Combat Weapons", 0.0, 4, 3, 4, 0, 1, {})}}]
		5: # Veteran Sergeant Metaurus
			stats = {"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
			ranged = [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}]
			melee = [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {"precision": true})}}]
		_: return {}
	return {"stats": stats, "ranged": ranged, "melee": melee}

static func victrix_honour_guard_model_loadout(model_index: int) -> Dictionary:
	var carbine := {"id": "master-crafted-bolt-carbine", "profiles": {"standard": _weapon("Master-crafted Bolt Carbine", 24.0, 2, 2, 5, -1, 2, {"rapid-fire": 1, "assault": true})}}
	var power_weapon := {"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {})}}
	var blades := {"id": "blades-of-honour", "profiles": {"standard": _weapon("Blades of Honour", 0.0, 6, 2, 6, -2, 2, {"twin-linked": true, "precision": true})}}
	match model_index:
		0: return {"role": "chapter-ancient", "ranged": [carbine.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES", "EPIC HERO", "ANCIENT"]}
		1: return {"role": "chapter-champion", "ranged": [], "melee": [blades.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES", "EPIC HERO", "CHAMPION"]}
		_: return {"role": "victrix-honour-guard", "ranged": [carbine.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"]}

static func firestrike_autocannon() -> Dictionary:
	return profile("firestrike-servo-turrets").additional_weapon_profiles.ranged[0].duplicate(true)

static func _redemptor_heavy_onslaught() -> Dictionary:
	var weapon := {"id": "heavy-onslaught-gatling-cannon", "profiles": {"standard": _weapon("Heavy Onslaught Gatling Cannon", 24.0, 12, 3, 6, -1, 1, {"devastating-wounds": true, "sustained-hits": 2})}}
	weapon.profiles.standard.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func _redemptor_onslaught() -> Dictionary:
	var weapon := {"id": "onslaught-gatling-cannon", "profiles": {"standard": _weapon("Onslaught Gatling Cannon", 24.0, 8, 3, 5, -1, 1, {"devastating-wounds": true})}}
	weapon.profiles.standard.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"]}
	return weapon

static func _hailstrike_onslaught() -> Dictionary:
	var weapon := _weapon("Onslaught Gatling Cannon", 24.0, 8, 3, 5, -1, 1, {"devastating-wounds": true, "ignores-cover": true})
	weapon.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"]}
	return weapon

static func redemptor_weapons(fragstorm: bool = true, heavy_flamer: bool = true, macro_plasma: bool = false, icarus_rocket_pod: bool = false) -> Array[Dictionary]:
	var data := profile("redemptor-dreadnought")
	var options: Dictionary = data.additional_weapon_profiles
	var ranged: Array[Dictionary] = [options.fragstorm.duplicate(true) if fragstorm else options.storm_bolters.duplicate(true),
		options.heavy_flamer.duplicate(true) if heavy_flamer else options.onslaught.duplicate(true),
		options.macro_plasma.duplicate(true) if macro_plasma else data.ranged[2].duplicate(true)]
	if icarus_rocket_pod: ranged.append(options.icarus_rocket_pod.duplicate(true))
	return ranged

static func _brutalis_talons() -> Dictionary:
	var weapon := {"id": "brutalis-talons", "profiles": {"standard": _weapon("Brutalis Talons", 0.0, 8, 3, 10, -2, 2, {"sustained-hits": 1, "twin-linked": true, "cleave": 2})}}
	weapon.profiles.standard.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func brutalis_weapons(talons: bool = false, multi_melta: bool = false) -> Dictionary:
	var data := profile("brutalis-dreadnought")
	var ranged: Array[Dictionary] = []
	if not talons: ranged.append(data.ranged[0].duplicate(true))
	ranged.append(data.additional_weapon_profiles.twin_multi_melta.duplicate(true) if multi_melta else data.additional_weapon_profiles.twin_heavy_bolter.duplicate(true))
	ranged.append(data.ranged[2].duplicate(true))
	var melee: Array[Dictionary] = [data.additional_weapon_profiles.brutalis_talons.duplicate(true) if talons else data.melee[0].duplicate(true)]
	return {"ranged": ranged, "melee": melee}

static func invictor_weapons(autocannon: bool = false) -> Array[Dictionary]:
	var data := profile("invictor-tactical-warsuit")
	var result: Array[Dictionary] = []
	for index in range(data.ranged.size()):
		if index == 2 and autocannon: result.append(data.additional_weapon_profiles.twin_ironhail_autocannon.duplicate(true))
		else: result.append(data.ranged[index].duplicate(true))
	return result

static func digest() -> String:
	return var_to_str({"id": ID, "profiles": catalog(), "ancient_power_weapon": ancient_weapons(true), "bladeguard_pistols": [bladeguard_pistol("volkite"), bladeguard_pistol("plasma")], "hellblaster_plasma_pistol": hellblaster_pistol(true), "aggressor_boltstorm": aggressor_ranged(true), "eradicator_multi_melta": eradicator_ranged(true), "eliminator_las": eliminator_gun("las"), "eliminator_instigator": eliminator_gun("carbine"), "sternguard_heavy": sternguard_gun("heavy"), "sternguard_pyrecannon": sternguard_gun("pyre"), "sternguard_sergeant": [sternguard_melee("chain"), sternguard_melee("fist"), sternguard_melee("power")], "captain_loadouts": [captain_weapons("neo-volkite"), captain_weapons("plasma-pistol"), captain_weapons("relic-shield", true)], "terminator_captain_alternatives": terminator_captain_weapons(true, true), "gravis_captain_alternatives": [gravis_captain_weapons("blade"), gravis_captain_weapons("chainsword"), gravis_captain_weapons("fist")], "phobos_lieutenant_carbine": phobos_lieutenant_gun(true)}).sha256_text()

static func aggressor_ranged(boltstorm: bool) -> Array:
	if not boltstorm: return profile("aggressor-squad").ranged.duplicate(true)
	return [
		{"id": "auto-boltstorm-gauntlets", "profiles": {"standard": _weapon("Auto Boltstorm Gauntlets", 18.0, 3, 3, 5, -1, 1, {"close-quarters": true, "twin-linked": true})}},
		{"id": "fragstorm-grenade-launcher", "profiles": {"standard": _weapon("Fragstorm Grenade Launcher", 18.0, 3, 3, 4, -1, 1, {"blast": 1})}}
	]

static func eradicator_ranged(multi: bool) -> Dictionary:
	var rifle: Dictionary = profile("eradicator-squad-with-melta-rifles").ranged[0].duplicate(true)
	if not multi: return rifle
	return {"id": "multi-melta", "profiles": {
		"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3}),
		"hunter": _weapon("Multi-melta - Hunter", 18.0, 2, 2, 12, -3, "D3+2", {"melta": 3, "hunter": ["Monster", "Vehicle"]})}}

static func hellblaster_pistol(plasma: bool) -> Dictionary:
	if not plasma: return profile("hellblaster-squad").ranged[1].duplicate(true)
	return {"id": "plasma-pistol", "profiles": {
		"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
		"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}

static func jump_pack_pistol(kind: String) -> Dictionary:
	if kind == "hand-flamer": return {"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"close-quarters": true, "torrent": true})}}
	if kind == "plasma-pistol": return {"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
	return profile("assault-intercessors-with-jump-packs").ranged[0].duplicate(true)

static func jump_pack_sergeant_melee(kind: String) -> Dictionary:
	if kind == "power-fist": return {"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}
	if kind == "power-weapon": return {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
	return profile("assault-intercessors-with-jump-packs").melee[0].duplicate(true)

static func jump_pack_captain_weapons(loadout: String) -> Dictionary:
	var pistol: Dictionary
	var melee: Dictionary
	var shield := false
	match loadout:
		"default":
			pistol = {"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}
			melee = {"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 8, 2, 5, -1, 1, {"sustained-hits": 1})}}
		"hand-flamer":
			pistol = {"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"close-quarters": true, "torrent": true})}}
			melee = jump_pack_captain_weapons("default").melee[0]
		"plasma-pistol":
			pistol = {"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
			melee = jump_pack_captain_weapons("default").melee[0]
		"power-fist":
			pistol = jump_pack_captain_weapons("default").ranged[0]
			melee = {"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 5, 2, 8, -2, 2, {})}}
		"relic-weapon":
			pistol = jump_pack_captain_weapons("default").ranged[0]
			melee = {"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 6, 2, 6, -2, 2, {})}}
		"thunder-hammer-shield":
			melee = {"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 5, 3, 8, -2, 3, {"devastating-wounds": true})}}
			shield = true
		"chainsword-shield":
			melee = jump_pack_captain_weapons("default").melee[0]
			shield = true
		_:
			return {}
	return {"ranged": [pistol] if not pistol.is_empty() else [], "melee": [melee], "relic_shield": shield}

static func vanguard_veteran_weapons(is_sergeant: bool, pistol: String = "heavy-bolt-pistol", melee: String = "default", shield: bool = false) -> Dictionary:
	var ranged: Array[Dictionary] = []
	if not shield:
		if pistol == "heavy-bolt-pistol": ranged.append({"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}})
		elif pistol == "plasma-pistol": ranged.append({"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}})
		else: return {}
	elif pistol != "combat-shield": return {}
	var stats: Dictionary
	var weapon_id: String
	if is_sergeant:
		match melee:
			"default", "relic-blade":
				weapon_id = "relic-blade"
				stats = _vanguard_relic_blade()
			"power-fist":
				weapon_id = "power-fist"
				stats = _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})
			"thunder-hammer":
				weapon_id = "thunder-hammer"
				stats = _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})
			_:
				return {}
	else:
		if melee not in ["default", "master-crafted-power-weapon"]: return {}
		weapon_id = "master-crafted-power-weapon"
		stats = _weapon("Master-crafted Power Weapon", 0.0, 3, 3, 5, -2, 2, {})
	return {"ranged": ranged, "melee": [{"id": weapon_id, "profiles": {"standard": stats}}], "combat_shield": shield}

static func _weapon(label: String, range_inches: float, attacks: Variant, skill: Variant, strength: int, ap: int, damage: Variant, keywords: Dictionary) -> Dictionary:
	return {"name": label, "range_inches": range_inches, "attacks": attacks, "skill": skill,
		"strength": strength, "ap": ap, "damage": damage, "keywords": keywords}

static func _onslaught_gatling_cannon() -> Dictionary:
	var weapon := {"id": "onslaught-gatling-cannon", "profiles": {"standard": _weapon("Onslaught Gatling Cannon", 24.0, 8, 3, 5, -1, 1, {"devastating-wounds": true})}}
	weapon.profiles.standard.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"]}
	return weapon

static func _invader_atv_multi_melta() -> Dictionary:
	return {"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}}

static func invader_atv_weapons(multi_melta: bool = false) -> Array[Dictionary]:
	var source := profile("invader-atvs")
	var guns: Array[Dictionary] = []
	for weapon: Dictionary in source.ranged: guns.append(weapon.duplicate(true))
	if multi_melta: guns[1] = source.additional_weapon_profiles.ranged[0].duplicate(true)
	return guns

static func _vanguard_relic_blade() -> Dictionary:
	var stats := _weapon("Relic Blade", 0.0, 3, 3, 6, -2, 2, {"cleave": 1, "lethal-hits": true})
	stats.target_restricted_traits = {"lethal-hits": ["MONSTER", "VEHICLE"]}
	return stats

static func eliminator_gun(kind: String) -> Dictionary:
	if kind == "las": return {"id": "las-fusil", "profiles": {"standard": _weapon("Las Fusil", 36.0, 1, 3, 10, -3, "D3+3", {"heavy": true})}}
	# Conditional Lethal Hits is applied against the selected target, never baked into a universal trait.
	if kind == "carbine": return {"id": "instigator-bolt-carbine", "profiles": {"standard": _weapon("Instigator Bolt Carbine", 24.0, 2, 2, 5, -2, 2, {"rapid-fire": 2, "precision": true})}}
	return profile("eliminator-squad").ranged[0].duplicate(true)

static func sternguard_gun(kind: String) -> Dictionary:
	if kind == "heavy": return {"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"heavy": true, "rapid-fire": 2, "sustained-hits": 1})}}
	if kind == "pyre": return {"id": "pyrecannon", "profiles": {"standard": _weapon("Pyrecannon", 12.0, 4, 3, 6, -1, 1, {"blast": 2, "torrent": true})}}
	return profile("sternguard-veteran-squad").ranged[0].duplicate(true)

static func sternguard_melee(kind: String) -> Dictionary:
	if kind == "fist": return {"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 4, 3, 8, -2, 2, {})}}
	if kind == "power": return {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 3, 5, -2, 1, {})}}
	return {"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 6, 3, 5, -1, 1, {})}}

static func bladeguard_pistol(kind: String) -> Dictionary:
	if kind == "volkite": return {"id": "neo-volkite-pistol", "profiles": {"standard": _weapon("Neo-volkite Pistol", 12.0, 1, 3, 5, 0, 2, {"close-quarters": true, "devastating-wounds": true})}}
	if kind == "plasma": return {"id": "plasma-pistol", "profiles": {
		"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
		"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
	return profile("bladeguard-veteran-squad").ranged[0].duplicate(true)

static func ancient_weapons(power: bool) -> Dictionary:
	var data := profile("ancient")
	if power:
		data.ranged = [data.ranged[1]]
		data.melee.append({"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 3, 5, -2, 1, {})}})
	return {"ranged": data.ranged, "melee": data.melee}

static func scout_ranged(gun: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}]
	match gun:
		"boltgun": result.append({"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}})
		"shotgun": result.append({"id": "shotgun", "profiles": {"standard": _weapon("Shotgun", 18.0, 2, 3, 4, -1, 1, {"assault": true, "blast": 1})}})
		"sniper-rifle": result.append({"id": "sniper-rifle", "profiles": {"standard": _weapon("Sniper Rifle", 36.0, 1, 3, 5, -2, 2, {"heavy": true, "precision": true})}})
		"heavy-bolter": result.append({"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 4, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1, "heavy": true})}})
		"missile-launcher": result.append({"id": "missile-launcher", "profiles": {
			"frag": _weapon("Missile Launcher - Frag", 48.0, 4, 4, 4, -1, 1, {"blast": 1, "heavy": true}),
			"krak": _weapon("Missile Launcher - Krak", 48.0, 1, 4, 10, -2, "D3+3", {})}})
		_: return []
	return result

static func scout_melee(blade: String) -> Array[Dictionary]:
	if blade == "chainsword": return [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 4, -1, 1, {})}}]
	if blade == "combat-knife": return [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 3, 3, 4, -1, 1, {})}}]
	return []

static func terminator_captain_weapons(combi: bool, fist: bool) -> Dictionary:
	var data := profile("captain-in-terminator-armour")
	if combi:
		data.ranged = [{"id": "combi-weapon", "profiles": {
			"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"torrent": true, "blast": 1}),
			"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 2, 7, -2, 2, {}),
			"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 2, 9, -3, "D3+2", {"melta": 2})}}]
	if fist: data.melee = [{"id": "relic-fist", "profiles": {"standard": _weapon("Relic Fist", 0.0, 5, 2, 8, -2, 2, {})}}]
	return {"ranged": data.ranged, "melee": data.melee}

static func captain_weapons(ranged_loadout: String = "default", fist: bool = false) -> Dictionary:
	var ranged: Array = []
	var relic_shield := false
	match ranged_loadout:
		"default": ranged = profile("captain").ranged.duplicate(true)
		"neo-volkite": ranged = [{"id": "neo-volkite-pistol", "profiles": {"standard": _weapon("Neo-volkite Pistol", 12.0, 1, 2, 5, 0, 2, {"close-quarters": true, "devastating-wounds": true})}}]
		"plasma-pistol": ranged = [{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"hazardous": true, "close-quarters": true})}}]
		"relic-shield":
			relic_shield = true
			ranged = [profile("captain").ranged[0].duplicate(true)]
		_:
			return {}
	var melee: Array = profile("captain").melee.duplicate(true)
	if fist: melee = [{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 5, 2, 8, -2, 2, {})}}]
	return {"ranged": ranged, "melee": melee, "relic_shield": relic_shield}

static func lieutenant_weapons(ranged_package: String = "default", fists_replacement: String = "ceramite-fists", storm_shield: bool = false) -> Dictionary:
	var data := profile("lieutenant")
	if data.is_empty() or ranged_package not in data.options.ranged_packages or fists_replacement not in data.options.fists_replacements: return {}
	if storm_shield and ranged_package != data.options.storm_shield_requires: return {}
	var ranged: Array = []
	var melee: Array = []
	var pistol: Dictionary = data.ranged[0].duplicate(true)
	var bolter: Dictionary = data.ranged[1].duplicate(true)
	var fists: Dictionary = data.melee[0].duplicate(true)
	match ranged_package:
		"default": ranged = [pistol, bolter]
		"heavy-bolt-pistol": ranged = [data.additional_weapon_profiles.ranged[0].duplicate(true), bolter]
		"power-weapon":
			ranged = [pistol]
			melee.append(data.additional_weapon_profiles.melee[0].duplicate(true))
		"heavy-pistol-power-weapon":
			ranged = [data.additional_weapon_profiles.ranged[0].duplicate(true)]
			melee.append(data.additional_weapon_profiles.melee[0].duplicate(true))
		"plasma-pistol": ranged = [pistol, data.additional_weapon_profiles.ranged[2].duplicate(true)]
		"heavy-pistol-plasma-pistol": ranged = [data.additional_weapon_profiles.ranged[0].duplicate(true), data.additional_weapon_profiles.ranged[2].duplicate(true)]
		"power-fist":
			ranged = [pistol]
			melee.append(data.additional_weapon_profiles.melee[1].duplicate(true))
		"heavy-pistol-power-fist":
			ranged = [data.additional_weapon_profiles.ranged[0].duplicate(true)]
			melee.append(data.additional_weapon_profiles.melee[1].duplicate(true))
		"neo-volkite":
			ranged = [data.additional_weapon_profiles.ranged[1].duplicate(true)]
			melee.append(data.additional_weapon_profiles.melee[0].duplicate(true))
		_:
			return {}
	match fists_replacement:
		"ceramite-fists": melee.append(fists)
		"power-weapon": melee.append(data.additional_weapon_profiles.melee[0].duplicate(true))
		"power-fist": melee.append(data.additional_weapon_profiles.melee[1].duplicate(true))
	if ranged.is_empty() or melee.is_empty(): return {}
	return {"ranged": ranged, "melee": melee, "storm_shield": storm_shield, "invulnerable_target": 4 if storm_shield else 0}

static func gravis_captain_weapons(mode: String) -> Dictionary:
	var data := profile("captain-in-gravis-armour")
	if mode == "rifle": return {"ranged": data.ranged, "melee": data.melee}
	var relic: Dictionary
	match mode:
		"blade": relic = {"id": "relic-blade", "profiles": {"standard": _weapon("Relic Blade", 0.0, 2, 2, 6, -2, 2, {"extra-attacks": true})}}
		"chainsword": relic = {"id": "relic-chainsword", "profiles": {"standard": _weapon("Relic Chainsword", 0.0, 3, 2, 5, -1, 2, {"extra-attacks": true})}}
		"fist": relic = {"id": "relic-power-fist", "profiles": {"standard": _weapon("Relic Power Fist", 0.0, 1, 2, 8, -2, 2, {"extra-attacks": true})}}
		_: return {}
	return {"ranged": [{"id": "boltstorm-gauntlet", "profiles": {"standard": _weapon("Boltstorm Gauntlet", 12.0, 3, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "boltstorm-gauntlet", "profiles": {"standard": _weapon("Boltstorm Gauntlet", 0.0, 5, 2, 8, -2, 2, {})}}, relic]}

static func phobos_lieutenant_gun(carbine: bool) -> Array:
	if carbine: return [{"id": "master-crafted-bolt-carbine", "profiles": {"standard": _weapon("Master-crafted bolt carbine", 24.0, 2, 2, 4, 0, 2, {})}}]
	return profile("lieutenant-in-phobos-armour").ranged.duplicate(true)

static func outrider_weapons(plasma: bool, melee_kind: String) -> Dictionary:
	var data := profile("outrider-squad")
	var ranged: Array = data.ranged.duplicate(true)
	if plasma: ranged[0] = data.additional_weapon_profiles.ranged[0].duplicate(true)
	var melee: Dictionary = data.melee[0].duplicate(true)
	match melee_kind:
		"power-weapon": melee = data.additional_weapon_profiles.melee[0].duplicate(true)
		"thunder-hammer": melee = data.additional_weapon_profiles.melee[1].duplicate(true)
	return {"ranged": ranged, "melee": [melee]}

static func _gladiator_reaper_cannon() -> Dictionary:
	var cannon := _weapon("Twin Heavy Onslaught Gatling Cannon", 24.0, 12, 3, 6, -1, 1, {"twin-linked": true, "sustained-hits": 2, "devastating-wounds": true})
	cannon.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"], "devastating-wounds": ["MONSTER", "VEHICLE"]}
	return cannon

static func _land_speeder_onslaught() -> Dictionary:
	var cannon := _weapon("Onslaught Gatling Cannon", 24.0, 8, 3, 5, -1, 1, {"devastating-wounds": true})
	cannon.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"]}
	return cannon

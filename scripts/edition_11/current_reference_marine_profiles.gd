extends RefCounted
## Fixed default loadouts transcribed from the local Wahapedia e11 extraction.
## Wahapedia is the project's sole rules authority; local admission remains scoped and uncertified for full army legality.
const ID := "space-marines-e11-fixed-reference-2026-10-30-v151-hammerfall-bunker"
const VERIFIED_EXPORT_SNAPSHOT_ID := "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z"
const VERIFIED_EXPORT_UPDATED_AT := "2026-10-28T23:48:19+03:00"
const VERIFIED_EXPORT_MANIFEST_SHA256 := "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e"
const VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK := {
	"000000139": "735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535",
	"000000021": "0ef16f837a955ea6b832a53c66e5ddae56680c2e629afd83d4cdd970d8b3a0ea",
	"000000023": "63babe1ca34885808f13f7250bd2f1f490fbeb0ba386e9bae1280a93802397f8",
	"000000035": "ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109",
	"000000036": "427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327",
	"000000162": "49b1df5633b88744e6b4f9ee60d0b1e3841178e2ed9bcb76c3eab021efba3f97",
	"000000356": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
}
const BLACK_TEMPLARS_VEHICLE_SOURCES := {
	"black-templars-gladiator-lancer": {"base": "gladiator-lancer", "name": "Gladiator Lancer", "datasheet_id": "000002787", "cost": 165, "third_cost": 185, "wargear_costs": {"Multi-melta": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]},
	"black-templars-gladiator-reaper": {"base": "gladiator-reaper", "name": "Gladiator Reaper", "datasheet_id": "000002789", "cost": 165, "third_cost": 185, "wargear_costs": {"Multi-melta": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]},
	"black-templars-gladiator-valiant": {"base": "gladiator-valiant", "name": "Gladiator Valiant", "datasheet_id": "000002788", "cost": 145, "third_cost": 165, "wargear_costs": {"Multi-melta": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]},
	"black-templars-impulsor": {"base": "impulsor", "name": "Impulsor", "datasheet_id": "000002786", "cost": 70, "third_cost": 70, "fourth_cost": 80, "wargear_costs": {"Multi-melta": 10, "Orbital Comms Array": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "DEDICATED TRANSPORT", "FRAME", "IMPERIUM", "TRANSPORT", "VEHICLE"], "excluded_weapon_profiles": ["ironhail-skytalon-array"], "excluded_impulsor_systems": ["Ironhail Skytalon Array"]},
	"black-templars-repulsor": {"base": "repulsor", "name": "Repulsor", "datasheet_id": "000002791", "cost": 190, "third_cost": 210, "wargear_costs": {"Multi-melta": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "FRAME", "IMPERIUM", "SMOKE", "TRANSPORT", "VEHICLE"]},
	"black-templars-repulsor-executioner": {"base": "repulsor-executioner", "name": "Repulsor Executioner", "datasheet_id": "000002790", "cost": 265, "third_cost": 285, "wargear_costs": {"Multi-melta": 10}, "keywords": ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "FRAME", "IMPERIUM", "SMOKE", "TRANSPORT", "VEHICLE"]},
}
const CHAPTER_VEHICLE_SOURCE_SNAPSHOT := "20261021T130623Z"
const CHAPTER_VEHICLE_SOURCE_UPDATED_AT := "2026-10-21 16:06:23 GMT+3"
const CHAPTER_VEHICLE_SOURCE_MANIFEST_SHA256 := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
const CHAPTER_VEHICLE_SLICE_MANIFEST_SHA256 := "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe"
const CHAPTER_KEYWORD_NAMES := {
	"BLACK TEMPLARS": "Black Templars",
	"BLOOD ANGELS": "Blood Angels",
	"DARK ANGELS": "Dark Angels",
	"DEATHWATCH": "Deathwatch",
	"IMPERIAL FISTS": "Imperial Fists",
	"IRON HANDS": "Iron Hands",
	"RAVEN GUARD": "Raven Guard",
	"SALAMANDERS": "Salamanders",
	"SPACE WOLVES": "Space Wolves",
	"ULTRAMARINES": "Ultramarines",
	"WHITE SCARS": "White Scars",
}
const DETACHMENT_KEYWORD_GRANTS := {
	"darkflight-pursuit": {"outrider-squad": ["BATTLELINE"]},
}
static var _profile_catalog_cache: Dictionary = {}

static func _build_profiles() -> Dictionary:
	return {
	"crusade-ancient": {
		"name": "Crusade Ancient", "source_book_id": "000000162", "source_datasheet_id": "000004136", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 45, "points_by_models": {1: 45}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["CHARACTER", "INFANTRY", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {"lethal-hits": true})}}]
	},
	"execrator": {
		"name": "Execrator", "source_book_id": "000000162", "source_datasheet_id": "000004135", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 65, "points_by_models": {1: 65}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "CHAPLAIN", "IMPERIUM", "TACTICUS", "EXPLOSIVES", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"default_loadout_by_role": {"Execrator": {"Absolvor Bolt Pistol": 1, "Crozius Arcanum": 1}},
		"options": {"ranged_packages": ["absolvor-bolt-pistol", "hand-flamer"], "additional_melee": ["master-crafted-power-weapon"]},
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}],
		"additional_weapon_profiles": {
			"ranged": [{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}}],
			"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 3, 2, 6, -2, 2, {"extra-attacks": true, "lethal-hits": true})}}]
		}
	},
	"chaplain-grimaldus": {
		"name": "Chaplain Grimaldus", "source_book_id": "000000162", "source_datasheet_id": "000002792", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 120, "points_by_models": {4: 120}, "models": 4, "max_supported_copies": 1,
		"base_size_source_mm": [40, 28.5, 28.5, 28.5], "base_radius_inches": 20.0 / 25.4, "base_geometry": "per-model-circles",
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CHAPLAIN", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"default_loadout_by_role": {"Chaplain Grimaldus": {"Plasma Pistol": 1, "Artificer crozius": 1}, "Cenobyte Servitor": {"Servitor Combat Weapon": 1}},
		"model_loadouts": [grimaldus_model_loadout(0), grimaldus_model_loadout(1), grimaldus_model_loadout(2), grimaldus_model_loadout(3)],
		"ranged": [{"id": "plasma-pistol", "physical_weapon_id": "plasma-pistol", "profiles": {
			"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}),
			"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})
		}}],
		"melee": [
			{"id": "artificer-crozius", "physical_weapon_id": "artificer-crozius", "profiles": {"standard": _weapon("Artificer crozius", 0.0, 6, 2, 6, -2, 2, {})}},
			{"id": "servitor-combat-weapon", "physical_weapon_id": "servitor-combat-weapon", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 1, 4, 3, 0, 1, {})}}
		]
	},
	"sword-brethren-squad": {
		"name": "Sword Brethren Squad", "source_book_id": "000000162", "source_datasheet_id": "000002798", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 115, "points_by_models": {4: 115, 5: 140, 9: 250, 10: 275}, "third_plus_points_by_models": {4: 135, 5: 160, 9: 270, 10: 295}, "models": 4, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "TACTICUS", "IMPERIUM", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"default_loadout_by_role": {"Sword Brethren": {"Heavy Bolt Pistol": 1, "Chainsword": 1}},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 6, 2, 5, -1, 1, {"sustained-hits": 1})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
				{"id": "plasma-pistol", "profiles": {
					"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
					"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
			],
			"melee": [
				{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 3, 2, 5, -2, 2, {"lethal-hits": true})}},
				{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 3, 8, -2, 3, {"devastating-wounds": true})}},
				{"id": "twin-lightning-claws", "profiles": {"standard": _weapon("Twin Lightning Claws", 0.0, 5, 2, 5, -2, 1, {"twin-linked": true})}}
			]
		}
	},
	"crusader-squad": {
		"name": "Crusader Squad", "source_book_id": "000000162", "source_datasheet_id": "000002799", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z", "source_manifest_sha256": "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e", "source_slice_manifest_sha256": "c826abb55add7cc48814b3df865546da059e17f311a62fc581092c2d43aa1bc8",
		"points": 160, "points_by_models": {10: 160, 20: 305}, "models": 10, "base_size_source_mm": 28.5, "base_radius_inches": 14.25 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["BATTLELINE", "INFANTRY", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"default_loadout_by_role": {
			"Sword Brother": {"Heavy Bolt Pistol": 1, "Master-crafted Power Weapon": 1},
			"Neophyte": {"Bolt Pistol": 1, "Neophyte Chainsword": 1},
			"Initiate": {"Bolt Pistol": 1, "Bolt Rifle": 1, "Close combat weapon": 1}},
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "close-combat-weapon", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 3, 3, 4, 0, 1, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "bolt-rifle", "profiles": {
					"focused-fire": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"rapid-fire": 1, "heavy": true}),
					"saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 1})}},
				{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
				{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
				{"id": "pyreblaster", "profiles": {"standard": _weapon("Pyreblaster", 12.0, 3, 0, 5, -1, 1, {"blast": 1, "torrent": true})}},
				{"id": "shotgun", "profiles": {"standard": _weapon("Shotgun", 18.0, 2, 3, 4, -1, 1, {"assault": true, "blast": 1})}}
			],
			"melee": [
				{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 3, 3, 4, -1, 1, {})}},
				{"id": "initiate-chainsword", "profiles": {"standard": _weapon("Initiate Chainsword", 0.0, 4, 3, 5, -1, 1, {"sustained-hits": 1})}},
				{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 3, 2, 5, -2, 2, {"lethal-hits": true})}},
				{"id": "neophyte-chainsword", "profiles": {"standard": _weapon("Neophyte Chainsword", 0.0, 4, 3, 4, -1, 1, {"sustained-hits": 1})}},
				{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}
			]
		}
	},
	"cato-sicarius": {
		"name": "Cato Sicarius", "source_book_id": "000000139", "source_datasheet_id": "000004184", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {1: 115}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"ranged": [{"id": "artisan-plasma-pistol", "profiles": {"standard": _weapon("Artisan Plasma Pistol", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true})}}],
		"melee": [
			{"id": "talassarian-tempest-blade-strike", "physical_weapon_id": "talassarian-tempest-blade", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Strike", 0.0, 4, 2, 6, -3, 3, {"devastating-wounds": true})}},
			{"id": "talassarian-tempest-blade-coup-de-grace", "physical_weapon_id": "talassarian-tempest-blade", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Coup de Grace", 0.0, 6, 2, 5, -2, 2, {"precision": true})}},
			{"id": "talassarian-tempest-blade-sweep", "physical_weapon_id": "talassarian-tempest-blade", "profiles": {"standard": _weapon("Talassarian Tempest Blade - Sweep", 0.0, 9, 2, 5, -2, 1, {"sustained-hits": 1})}}
		]
	},
	"victrix-honour-guard": {
		"name": "Victrix Honour Guard", "source_book_id": "000000139", "source_datasheet_id": "000004185", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 135, "points_by_models": {3: 135, 6: 265}, "third_plus_points_by_models": {3: 165, 6: 295}, "source_roster_points": {"points": 120, "points_by_models": {3: 120, 6: 250}, "third_plus_points_by_models": {3: 150, 6: 280}}, "wargear_costs": {"banner-of-macragge": 15}, "models": 3, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"],
		"default_loadout_by_role": {"Chapter Ancient": {"Banner of Macragge": 1, "Master-crafted Bolt Carbine": 1, "Master-crafted Power Weapon": 1}, "Chapter Champion": {"Blades of Honour": 1}, "Victrix Honour Guard": {"Master-crafted Bolt Carbine": 1, "Master-crafted Power Weapon": 1}},
		"composition_options": victrix_honour_guard_composition_options(), "default_composition_choice_id": "ancient-champion",
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
		"ranged": [{"id": "gauntlets-of-ultramar-ranged", "physical_weapon_id": "gauntlets-of-ultramar", "profiles": {"standard": _weapon("Gauntlets of Ultramar", 18.0, 4, 2, 5, -2, 2, {"close-quarters": true, "twin-linked": true})}}],
		"melee": [
			{"id": "gauntlets-of-ultramar-melee", "physical_weapon_id": "gauntlets-of-ultramar", "profiles": {"standard": _weapon("Gauntlets of Ultramar", 0.0, 6, 2, 10, -3, 3, {"twin-linked": true})}},
			{"id": "gauntlets-of-ultramar-overhead-smash", "physical_weapon_id": "gauntlets-of-ultramar", "profiles": {"standard": _weapon("Gauntlets of Ultramar - Overhead Smash", 0.0, 1, 2, 14, -3, "D3+3", {"extra-attacks": true, "twin-linked": true})}}
		]
	},
	"kor-sarro-khan": {
		"name": "Kor'sarro Khan", "source_book_id": "000000139", "source_datasheet_id": "000002709", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 80, "points_by_models": {1: 80}, "max_supported_copies": 1, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CAPTAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "WHITE SCARS"],
		"ranged": [
			{"id": "anzuq", "profiles": {"standard": _kor_sarro_anzuQ()}},
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
		"points": 115, "points_by_models": {6: 115}, "max_supported_copies": 1, "models": 6, "base_size_source_mm": [28.5, 40, 28.5, 28.5, 28.5, 40], "base_geometry": "per-model-circles", "base_radius_inches": 20.0 / 25.4, "geometry_scope": "Catalog proxy uses the largest 40 mm base; exact source base sizes are assigned per model.",
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
		"points": 125, "points_by_models": {4: 125}, "third_plus_points_by_models": {4: 145}, "models": 4, "base_radius_inches": 20.0 / 25.4,
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
		"base_size_source_mm": [90, 52], "base_geometry": "oval", "base_radius_inches": 45.0 / 25.4, "geometry_scope": "90 x 52 mm bounding-circle proxy",
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
	"inner-circle-companions": {
		"name": "Inner Circle Companions", "source_book_id": "000000023", "source_datasheet_id": "000003698", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 90, "points_by_models": {3: 90, 6: 180}, "third_plus_points_by_models": {3: 105, 6: 195}, "models": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TACTICUS", "IMPERIUM", "DEATHWING"],
		"default_loadout_by_role": {"Inner Circle Companions": {"Calibanite Greatsword": 1, "Heavy Bolt Pistol": 1}},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "calibanite-greatsword", "physical_weapon_id": "calibanite-greatsword", "profiles": {
			"sweep": _weapon("Calibanite Greatsword - Sweep", 0.0, 5, 3, 6, -2, 1, {"sustained-hits": 2}),
			"strike": _weapon("Calibanite Greatsword - Strike", 0.0, 4, 3, 6, -2, 2, {"lethal-hits": true})}}
		]
	},
	"asmodai": {
		"name": "Asmodai", "source_book_id": "000000023", "source_datasheet_id": "000000225", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CHARACTER", "EPIC HERO", "CHAPLAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "DEATHWING"],
		"default_loadout_by_role": {"Asmodai": {"Heavy Bolt Pistol": 1, "Crozius Arcanum and Power Weapon": 1}},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "crozius-arcanum-and-power-weapon", "physical_weapon_id": "crozius-arcanum-and-power-weapon", "profiles": {
			"strike": _weapon("Crozius Arcanum and Power Weapon - Strike", 0.0, 5, 2, 6, -2, 2, {"precision": true}),
			"sweep": _weapon("Crozius Arcanum and Power Weapon - Sweep", 0.0, 8, 2, 5, -2, 1, {"cleave": 1})}}
		]
	},
	"lazarus": {
		"name": "Lazarus", "source_book_id": "000000023", "source_datasheet_id": "000002296", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CAPTAIN", "TACTICUS", "IMPERIUM", "DEATHWING", "EXPLOSIVES", "EPIC HERO", "CHARACTER"],
		"default_loadout_by_role": {"Lazarus": {"Bolt Pistol": 1, "Enmity's Edge": 1}},
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "enmitys-edge", "profiles": {"standard": _weapon("Enmity's Edge", 0.0, 6, 2, 6, -3, 2, {"anti-psyker": 2})}}]
	},
	"azrael": {
		"name": "Azrael", "source_book_id": "000000023", "source_datasheet_id": "000000218", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 150, "points_by_models": {1: 150}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "CHAPTER MASTER", "EPIC HERO", "EXPLOSIVES", "DEATHWING", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "DARK ANGELS"],
		"default_loadout_by_role": {"Azrael": {"Lion's Wrath": 1, "The Lion Helm": 1, "The Sword of Secrets": 1}},
		"ranged": [{"id": "lions-wrath", "profiles": {"standard": _weapon("Lion's Wrath", 24.0, 2, 2, 8, -3, 2, {"rapid-fire": 1, "devastating-wounds": true, "anti-infantry": 4})}}],
		"melee": [{"id": "sword-of-secrets", "physical_weapon_id": "sword-of-secrets", "profiles": {"standard": _weapon("The Sword of Secrets", 0.0, 6, 2, 6, -4, 2, {"devastating-wounds": true})}}]
	},
	"belial": {
		"name": "Belial", "source_book_id": "000000023", "source_datasheet_id": "000000219", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 100, "points_by_models": {1: 100}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CAPTAIN", "CHARACTER", "EPIC HERO", "TERMINATOR", "DEATHWING", "IMPERIUM"],
		"default_loadout_by_role": {"Belial": {"Master-crafted Storm Bolter": 1, "The Sword of Silence": 1}},
		"ranged": [{"id": "master-crafted-storm-bolter", "profiles": {"standard": _weapon("Master-crafted Storm Bolter", 24.0, 2, 2, 5, -1, 2, {"precision": true})}}],
		"melee": [{"id": "the-sword-of-silence", "profiles": {"standard": _weapon("The Sword of Silence", 0.0, 6, 2, 6, -3, 2, {})}}]
	},
	"ezekiel": {
		"name": "Ezekiel", "source_book_id": "000000023", "source_datasheet_id": "000000226", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 110, "points_by_models": {1: 110}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 25, "base_radius_inches": 12.5 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "psychic_level": 3,
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "PSYKER", "LIBRARIAN", "DEATHWING", "IMPERIUM", "TACTICUS"],
		"default_loadout_by_role": {"Ezekiel": {"Mind Wipe": 1, "The Deliverer": 1, "Traitor's Bane": 1}},
		"ranged": [
			{"id": "mind-wipe", "profiles": {
				"focused": _weapon("Mind Wipe - Focused Witchfire", 12.0, 1, 2, 6, -2, "D3+3", {"devastating-wounds": true, "hazardous": true, "precision": true, "psychic": true, "anti-character": 4, "close-quarters": true}),
				"witchfire": _weapon("Mind Wipe - Witchfire", 12.0, 1, 2, 6, -2, "D6", {"devastating-wounds": true, "precision": true, "close-quarters": true, "psychic": true})}},
			{"id": "the-deliverer", "profiles": {"standard": _weapon("The Deliverer", 12.0, 1, 2, 5, -1, 2, {"precision": true, "close-quarters": true})}}
		],
		"melee": [{"id": "traitors-bane", "profiles": {"standard": _weapon("Traitor's Bane", 0.0, 4, 2, 6, -3, 2, {"precision": true, "psychic": true})}}]
	},
	"sammael": {
		"name": "Sammael", "source_book_id": "000000023", "source_datasheet_id": "000002291", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 120, "points_by_models": {1: 120}, "models": 1, "max_supported_copies": 1, "source_role": "Mounted Epic Hero",
		"base_size_source_mm": 60, "base_geometry": "round flying base", "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 7, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["DARK ANGELS", "ADEPTUS ASTARTES", "EPIC HERO", "FLY", "RAVENWING", "IMPERIUM", "FRAME", "EXPLOSIVES", "MOUNTED", "CAPTAIN", "CHARACTER", "MOBILE"],
		"default_loadout_by_role": {"Sammael": {"Bolt Pistol": 1, "Master-crafted Plasma Cannon": 1, "The Raven Sword": 1, "Twin Storm Bolter": 1}},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-plasma-cannon", "profiles": {"standard": _weapon("Master-crafted Plasma Cannon", 36.0, 3, 2, 8, -3, 3, {"blast": 1})}},
			{"id": "twin-storm-bolter", "profiles": {"standard": _weapon("Twin Storm Bolter", 24.0, 2, 2, 5, -1, 1, {"twin-linked": true, "rapid-fire": 2})}}
		],
		"melee": [{"id": "the-raven-sword", "profiles": {"standard": _weapon("The Raven Sword", 0.0, 6, 2, 6, -3, 2, {"sustained-hits": 2})}}]
	},
	"ravenwing-command-squad": {
		"name": "Ravenwing Command Squad", "source_book_id": "000000023", "source_datasheet_id": "000002748", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 115, "points_by_models": {3: 115}, "third_plus_points_by_models": {3: 135}, "models": 3, "max_supported_copies": 3, "source_role": "Mounted Character",
		"base_size_source_mm": [75, 42], "base_geometry": "oval", "base_radius_inches": 37.5 / 25.4, "geometry_scope": "75 x 42 mm oval represented by a labelled 37.5 mm bounding-circle proxy",
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 5},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "IMPERIUM", "RAVENWING", "CHARACTER", "MOUNTED", "EXPLOSIVES"],
		"default_loadout_by_role": {
			"Ravenwing Ancient": {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1},
			"Ravenwing Apothecary": {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1},
			"Ravenwing Champion": {"Bolt Pistol": 1, "Master-crafted Power Weapon": 1, "Plasma Talon": 1}},
		"model_loadouts": [ravenwing_command_model_loadout("Ravenwing Ancient"), ravenwing_command_model_loadout("Ravenwing Apothecary"), ravenwing_command_model_loadout("Ravenwing Champion")],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "plasma-talon", "profiles": {
				"standard": _weapon("Plasma Talon - Standard", 18.0, 2, 3, 7, -2, 1, {"rapid-fire": 1}),
				"supercharge": _weapon("Plasma Talon - Supercharge", 18.0, 2, 3, 8, -3, 2, {"rapid-fire": 1, "hazardous": true})}}
		],
		"melee": [
			{"id": "corvus-hammers", "profiles": {"standard": _weapon("Corvus Hammers", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}},
			{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}
		],
		"additional_weapon_profiles": {"ranged": [{"id": "grenade-launcher", "profiles": {
			"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}),
			"krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}}
		]}
	},
	"nephilim-jetfighter": {
		"name": "Nephilim Jetfighter", "source_book_id": "000000023", "source_datasheet_id": "000000239", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3", "source_role": "Vehicle",
		"points": 200, "points_by_models": {1: 200}, "models": 1, "max_supported_copies": 3, "damaged_threshold": 3,
		"base_size_source_mm": [120, 92], "base_geometry": "oval", "base_radius_inches": 60.0 / 25.4, "geometry_scope": "120 x 92 mm oval represented by a labelled 60 mm bounding-circle proxy",
		"stats": {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 5},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "VEHICLE", "AIRCRAFT", "RAVENWING", "FLY", "IMPERIUM"],
		"default_loadout_by_role": {"Nephilim Jetfighter": {"Armoured Hull": 1, "Avenger Mega Bolter": 1, "Blacksword Missiles": 1, "Twin Heavy Bolter": 1}},
		"ranged": [
			{"id": "avenger-mega-bolter", "profiles": {"standard": _weapon("Avenger Mega Bolter", 36.0, 10, 3, 5, -1, 2, {"sustained-hits": 1})}},
			{"id": "blacksword-missiles", "profiles": {"standard": _weapon("Blacksword Missiles", 36.0, 2, 3, 8, -2, "D3+2", {"anti-fly": 2})}},
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "nephilim-lascannons", "profiles": {"standard": _weapon("Nephilim Lascannons", 48.0, 2, 3, 12, -3, "D3+3", {})}}], "melee": []}
	},
	"ravenwing-dark-talon": {
		"name": "Ravenwing Dark Talon", "source_book_id": "000000023", "source_datasheet_id": "000000240", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3", "source_role": "Vehicle",
		"points": 190, "points_by_models": {1: 190}, "models": 1, "max_supported_copies": 3, "damaged_threshold": 3,
		"base_size_source_mm": [120, 92], "base_geometry": "oval", "base_radius_inches": 60.0 / 25.4, "geometry_scope": "120 x 92 mm oval represented by a labelled 60 mm bounding-circle proxy",
		"stats": {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 5},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "VEHICLE", "AIRCRAFT", "RAVENWING", "FLY", "IMPERIUM"],
		"default_loadout_by_role": {"Ravenwing Dark Talon": {"Armoured Hull": 1, "Hurricane Bolter": 2, "Rift Cannon": 1}},
		"ranged": [
			{"id": "rift-cannon", "profiles": {"standard": _weapon("Rift Cannon", 18.0, "D3+1", 3, 16, -4, 3, {"devastating-wounds": true, "blast": 1})}},
			{"id": "hurricane-bolter-1", "profiles": {"standard": _weapon("Hurricane Bolter", 24.0, 6, 3, 5, -1, 1, {"rapid-fire": 6, "twin-linked": true})}},
			{"id": "hurricane-bolter-2", "profiles": {"standard": _weapon("Hurricane Bolter", 24.0, 6, 3, 5, -1, 1, {"rapid-fire": 6, "twin-linked": true})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}]
	},
	"deathwing-knights": {
		"name": "Deathwing Knights", "source_book_id": "000000023", "source_datasheet_id": "000000231", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 255, "points_by_models": {5: 255}, "third_plus_points_by_models": {5: 275}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TERMINATOR", "DEATHWING", "IMPERIUM"],
		"default_loadout_by_role": {"Knight Master": {"Great Weapon of the Unforgiven": 1}, "Deathwing Knights": {"Mace of Absolution": 1}},
		"ranged": [],
		"melee": [{"id": "mace-of-absolution", "profiles": {"standard": _weapon("Mace of Absolution", 0.0, 4, 2, 6, -2, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
		"additional_weapon_profiles": {"melee": [
			{"id": "great-weapon-of-the-unforgiven", "profiles": {"standard": _weapon("Great Weapon of the Unforgiven", 0.0, 5, 2, 6, -2, 2, {"devastating-wounds": true, "sustained-hits": 1})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 2, 6, -2, 2, {})}},
			{"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 6, 2, 7, -2, 2, {"lethal-hits": true})}}
		]}
	},
	"deathwing-terminator-squad": {
		"name": "Deathwing Terminator Squad", "source_book_id": "000000023", "source_datasheet_id": "000000230", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 190, "points_by_models": {5: 190, 10: 380}, "third_plus_points_by_models": {5: 230, 10: 420}, "wargear_costs": {"cyclone-missile-launcher": 10}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TERMINATOR", "DEATHWING", "IMPERIUM"],
		"default_loadout_by_role": {"Deathwing Sergeant": {"Power Fist": 1, "Storm Bolter": 1}, "Deathwing Terminators": {"Power Fist": 1, "Storm Bolter": 1}},
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 2})}},
			{"id": "cyclone-missile-launcher", "profiles": {
				"frag": _weapon("Cyclone Missile Launcher - Frag", 36.0, 8, 3, 4, -1, 1, {"blast": 2}),
				"krak": _weapon("Cyclone Missile Launcher - Krak", 36.0, 2, 3, 10, -2, "D3+3", {})}},
			{"id": "plasma-cannon", "profiles": {
				"standard": _weapon("Plasma Cannon - Standard", 36.0, 3, 3, 7, -2, 2, {"blast": 1}),
				"supercharge": _weapon("Plasma Cannon - Supercharge", 36.0, 3, 3, 8, -3, 3, {"blast": 1, "hazardous": true})}}
		], "melee": [
			{"id": "chainfist", "profiles": {
				"standard": _weapon("Chainfist - Standard", 0.0, 2, 4, 8, -2, 2, {}),
				"hunter": _weapon("Chainfist - Hunter", 0.0, 3, 3, 12, -2, 3, {"hunter": ["Monster", "Vehicle"]})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 3, 5, -2, 1, {})}}
		]}
	},
	"ravenwing-black-knights": {
		"name": "Ravenwing Black Knights", "source_book_id": "000000023", "source_datasheet_id": "000000241", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 85, "points_by_models": {3: 85, 6: 170}, "third_plus_points_by_models": {3: 95, 6: 180}, "models": 3,
		"base_size_source_mm": [75, 42], "base_geometry": "oval", "base_radius_inches": 37.5 / 25.4, "geometry_scope": "75 x 42 mm oval represented by a labelled 37.5 mm bounding-circle proxy",
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 5},
		"keywords": ["DARK ANGELS", "RAVENWING", "MOUNTED", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"],
		"default_loadout_by_role": {
			"Ravenwing Huntmaster": {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1},
			"Ravenwing Black Knight": {"Bolt Pistol": 1, "Corvus Hammers": 1, "Plasma Talon": 1}},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "plasma-talon", "profiles": {
				"standard": _weapon("Plasma Talon - Standard", 18.0, 2, 3, 7, -2, 1, {"rapid-fire": 1}),
				"supercharge": _weapon("Plasma Talon - Supercharge", 18.0, 2, 3, 8, -3, 2, {"rapid-fire": 1, "hazardous": true})}}
		],
		"melee": [{"id": "corvus-hammers", "profiles": {"standard": _weapon("Corvus Hammers", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "grenade-launcher", "profiles": {
			"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}),
			"krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}}
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
	"land-speeder-vengeance": {
		"name": "Land Speeder Vengeance", "source_book_id": "000000023", "source_datasheet_id": "000000242", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"points": 150, "points_by_models": {1: 150}, "third_plus_points_by_models": {1: 160}, "points_source": "wahapedia_e11_local_export_2026_10_21_dark_angels_app", "max_supported_copies": 3, "models": 1,
		"base_size_source": "60mm flying base", "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
		"keywords": ["VEHICLE", "SPEEDER", "FRAME", "FLY", "RAVENWING", "IMPERIUM", "ADEPTUS ASTARTES", "DARK ANGELS"],
		"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "plasma-storm-battery", "profiles": {
				"standard": _weapon("Plasma Storm Battery - Standard", 36.0, "D3+3", 3, 9, -2, 2, {"blast": 1, "twin-linked": true}),
				"supercharge": _weapon("Plasma Storm Battery - Supercharge", 36.0, "D3+3", 3, 10, -3, 3, {"blast": 1, "twin-linked": true, "hazardous": true})
			}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}}], "melee": []}
	},
	"ravenwing-darkshroud": {
		"name": "Ravenwing Darkshroud", "source_book_id": "000000023", "source_datasheet_id": "000000238", "source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_role": "Vehicle",
		"points": 80, "points_by_models": {1: 80}, "max_supported_copies": 3, "models": 1,
		"base_size_source": "Large Flying Base (60 mm circular runtime proxy)", "geometry_scope": "Provisional 60 mm circular proxy; the pinned export names a Large Flying Base but does not specify its physical dimensions.", "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
		"keywords": ["VEHICLE", "SPEEDER", "FRAME", "FLY", "RAVENWING", "IMPERIUM", "ADEPTUS ASTARTES", "DARK ANGELS"],
		"ranged": [{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}}],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}}], "melee": []}
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
		"name": "Infiltrator Squad", "source_book_id": "000000139", "source_datasheet_id": "000000128", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {5: 85, 10: 150}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "marksman-bolt-carbine", "profiles": {"standard": _weapon("Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 1, "precision": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"lieutenant-in-phobos-armour": {
		"name": "Lieutenant in Phobos Armour", "source_book_id": "000000139", "source_datasheet_id": "000002530", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 40, "points_by_models": {1: 40}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"scouts_inches": 6,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 12.0, 1, 2, 5, -2, 2, {"precision": true, "close-quarters": true})}}],
		"melee": [{"id": "monomolecular-combat-blades", "profiles": {"standard": _weapon("Monomolecular Combat Blades", 0.0, 6, 2, 5, -1, 1, {"sustained-hits": 1, "precision": true})}}]
	},
	"captain-in-gravis-armour": {
		"name": "Captain in Gravis Armour", "source_book_id": "000000139", "source_datasheet_id": "000001172", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
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
		"keywords": ["INFANTRY", "TERMINATOR", "EPIC HERO", "CHARACTER", "CAPTAIN", "IMPERIUM", "ADEPTUS ASTARTES", "IMPERIAL FISTS"],
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
		"name": "Ancient in Terminator Armour", "source_book_id": "000000139", "source_datasheet_id": "000002677", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "ANCIENT", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 3, 5, -2, 2, {})}}]
	},
	"captain-in-terminator-armour": {
		"name": "Captain in Terminator Armour", "source_book_id": "000000139", "source_datasheet_id": "000000135", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "base_radius_inches": 20.0 / 25.4,
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
		"name": "Chaplain in Terminator Armour", "source_book_id": "000000139", "source_datasheet_id": "000000115", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHAPLAIN", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {"cleave": 1})}}]
	},
	"apothecary": {
		"name": "Apothecary", "source_book_id": "000000139", "source_datasheet_id": "000002773", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 45, "points_by_models": {1: 45}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [
			{"id": "servo-armature", "profiles": {"standard": _weapon("Servo-armature", 0.0, 4, 3, 5, 0, 1, {})}},
			{"id": "reductor-pistol", "profiles": {"standard": _weapon("Reductor Pistol", 0.0, 1, 3, 5, -4, 2, {"extra-attacks": true})}}]
	},
	"ancient": {
		"name": "Ancient", "source_book_id": "000000139", "source_datasheet_id": "000002775", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 40, "points_by_models": {1: 40}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-rifle", "profiles": {"focused": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"rapid-fire": 1, "heavy": true}), "saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 1, "assault": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 4, 3, 5, 0, 1, {})}}]
	},
	"bladeguard-ancient": {
		"name": "Bladeguard Ancient", "source_book_id": "000000139", "source_datasheet_id": "000001165", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 70, "points_by_models": {1: 70}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "ANCIENT", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "relics-of-battle", "profiles": {"standard": _weapon("Relics of Battle", 0.0, 4, 3, 5, -2, 2, {})}}]
	},
	"bladeguard-veteran-squad": {
		"name": "Bladeguard Veteran Squad", "source_book_id": "000000139", "source_datasheet_id": "000000071", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"max_supported_copies": 2, "points": 90, "points_by_models": {3: 90, 6: 180}, "third_plus_points_by_models": {3: 110, 6: 200}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-power-sword", "profiles": {"standard": _weapon("Master-crafted Power Sword", 0.0, 4, 3, 5, -2, 2, {})}}]
	},
	"judiciar": {
		"name": "Judiciar", "source_book_id": "000000139", "source_datasheet_id": "000002707", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 50, "points_by_models": {1: 50}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0, "melee_invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "executioner-relic-blade", "profiles": {"standard": _weapon("Executioner Relic Blade", 0.0, 5, 2, 7, -2, 2, {"precision": true, "devastating-wounds": true})}}]
	},
	"chaplain": {
		"name": "Chaplain", "source_book_id": "000000139", "source_datasheet_id": "000001174", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 60, "points_by_models": {1: 60}, "models": 1, "base_radius_inches": 20.0 / 25.4,
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
		"name": "Sternguard Veteran Squad", "source_book_id": "000000139", "source_datasheet_id": "000002255", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 105, "points_by_models": {5: 105, 10: 210}, "third_plus_points_by_models": {5: 120, 10: 225}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"default_loadout_by_role": {
			"Sternguard Veteran Sergeant": {"Artificer Firearm": 1, "Bolt Pistol": 1, "Chainsword": 1},
			"Sternguard Veteran": {"Artificer Firearm": 1, "Bolt Pistol": 1, "Ceramite Fists": 1}},
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
		"name": "Eliminator Squad", "source_book_id": "000000139", "source_datasheet_id": "000001668", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 85, "points_by_models": {3: 85}, "max_supported_copies": 2, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "SMOKE", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "bolt-sniper-rifle", "profiles": {"standard": _weapon("Bolt Sniper Rifle", 36.0, 1, 3, 6, -2, 3, {"heavy": true, "precision": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"eradicator-squad-with-melta-rifles": {
		"name": "Eradicator Squad with Melta Rifles", "source_book_id": "000000139", "source_datasheet_id": "000004249", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 100, "points_by_models": {3: 100, 6: 200}, "third_plus_points_by_models": {3: 120, 6: 220}, "models": 3, "base_radius_inches": 20.0 / 25.4,
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
		"name": "Eradicator Squad with Heavy Bolters", "source_book_id": "000000139", "source_datasheet_id": "000004231", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 100, "points_by_models": {3: 100, 6: 215}, "third_plus_points_by_models": {3: 130, 6: 245}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 6, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "heavy": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"apothecary-biologis": {
		"name": "Apothecary Biologis", "source_book_id": "000000139", "source_datasheet_id": "000000060", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 60, "points_by_models": {1: 60}, "models": 1, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "APOTHECARY", "CHARACTER", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "servo-armature", "profiles": {"standard": _weapon("Servo-armature", 0.0, 4, 3, 5, 0, 1, {})}}]
	},
	"aggressor-squad": {
		"name": "Aggressor Squad", "source_book_id": "000000139", "source_datasheet_id": "000002099", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 90, "points_by_models": {3: 90, 6: 180}, "models": 3, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"],
		"ranged": [{"id": "flamestorm-gauntlets", "profiles": {
			"close_quarters": _weapon("Flamestorm Gauntlets - Close Quarters", 12.0, 3, 0, 4, -1, 1, {"close-quarters": true, "torrent": true, "twin-linked": true}),
			"ranged": _weapon("Flamestorm Gauntlets - Ranged", 12.0, 3, 0, 4, -1, 1, {"torrent": true, "twin-linked": true, "blast": 2})}}],
		"melee": [{"id": "twin-power-fists", "profiles": {"standard": _weapon("Twin Power Fists", 0.0, 3, 3, 8, -2, 2, {"twin-linked": true})}}]
	},
	"infernus-squad": {
		"name": "Infernus Squad", "source_book_id": "000000139", "source_datasheet_id": "000000126", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 95, "points_by_models": {5: 95, 10: 190}, "third_plus_points_by_models": {5: 105, 10: 200}, "models": 5, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"],
		"ranged": [
			{"id": "pyreblaster", "profiles": {"standard": _weapon("Pyreblaster", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 1})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"hellblaster-squad": {
		"name": "Hellblaster Squad", "source_book_id": "000000139", "source_datasheet_id": "000002098", "source_export_updated_at": "2026-10-16T21:03:46+03:00",
		"points": 115, "points_by_models": {5: 115, 10: 230}, "third_plus_points_by_models": {5: 130, 10: 245}, "models": 5, "base_radius_inches": 16.0 / 25.4,
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
		"points": 95, "points_by_models": {5: 95, 10: 190}, "third_plus_points_by_models": {5: 105, 10: 200}, "max_supported_copies": 2, "models": 5, "base_radius_inches": 16.0 / 25.4,
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
		"points": 110, "points_by_models": {5: 110, 10: 220}, "third_plus_points_by_models": {5: 130, 10: 240}, "max_supported_copies": 3, "models": 5, "base_radius_inches": 16.0 / 25.4,
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
	"vanguard-veteran-squad": {
		"name": "Vanguard Veteran Squad", "source_book_id": "000000356", "source_datasheet_id": "000001154",
		"source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT, "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Vanguard-Veteran-Squad", "source_scope": "Warhammer Legends",
		"points": 120, "points_by_models": {5: 120, 10: 240}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"scouts_inches": 6,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "EXPLOSIVES"],
		"default_loadout_by_role": {
			"Vanguard Veteran Sergeant": {"Bolt Pistol": 1, "Heirloom Weapon": 1},
			"Vanguard Veteran": {"Bolt Pistol": 1, "Heirloom Weapon": 1}
		},
		"options": {"pistol_replacements": ["bolt-pistol", "storm-shield", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol"]},
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "heirloom-weapon", "profiles": {"standard": _weapon("Heirloom Weapon", 0.0, 4, 3, 5, -2, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "grav-pistol", "profiles": {"standard": _weapon("Grav-pistol", 12.0, 2, 3, 2, -1, 3, {"close-quarters": true, "anti-vehicle": 2})}},
			{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"close-quarters": true, "torrent": true})}},
			{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 3, 8, -3, "D3+2", {"melta": 2, "close-quarters": true})}},
			{"id": "plasma-pistol", "profiles": {
				"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
				"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		]},
		"special_rules": ["Scouts 6 inches", "Combat Doctrines", "Vanguard Assault (Lethal Hits)", "Storm Shield (4+ invulnerable save)"]
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
		"keywords": ["INFANTRY", "IMPERIUM", "ADEPTUS ASTARTES", "TERMINATOR", "TERMINATOR SQUAD"],
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
				"hunter": _weapon("Chainfist - Hunter", 0.0, 3, 3, 12, -2, 3, {"hunter": ["Monster", "Vehicle"]})}},
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
	"blood-angels-captain": {
		"name": "Blood Angels Captain", "source_book_id": "000000021", "source_datasheet_id": "000003831",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "TACTICUS", "IMPERIUM", "CHARACTER", "CAPTAIN", "INFANTRY", "EXPLOSIVES"],
		"options": {"ranged_packages": ["heavy-bolt-pistol", "inferno-pistol"], "melee_packages": ["master-crafted-chainsword", "power-fist", "relic-weapon"]},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-chainsword", "profiles": {"standard": _weapon("Master-crafted Chainsword", 0.0, 7, 2, 5, -1, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 2, 8, -3, "D3+2", {"close-quarters": true, "melta": 1})}}
		], "melee": [
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 5, 2, 8, -2, 2, {})}},
			{"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 6, 2, 6, -2, 2, {})}}
		]}
	},
	"death-company-captain": {
		"name": "Death Company Captain", "source_book_id": "000000021", "source_datasheet_id": "000003832",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "max_supported_copies": 3, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4, "scouts_inches": 6,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "CHARACTER", "DEATH COMPANY", "EXPLOSIVES", "CAPTAIN", "INFANTRY", "TACTICUS", "IMPERIUM"],
		"options": {"ranged_packages": ["heavy-bolt-pistol", "inferno-pistol"], "melee_packages": ["master-crafted-chainsword", "power-fist", "relic-weapon"]},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "master-crafted-chainsword", "profiles": {"standard": _weapon("Master-crafted Chainsword", 0.0, 8, 2, 5, -1, 2, {"sustained-hits": 1})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 2, 8, -3, "D3+2", {"close-quarters": true, "melta": 1})}}
		], "melee": [
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 6, 2, 8, -2, 2, {})}},
			{"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 7, 2, 6, -2, 2, {})}}
		]}
	},
	"death-company-captain-with-jump-pack": {
		"name": "Death Company Captain with Jump Pack", "source_book_id": "000000021", "source_datasheet_id": "000003833",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 85, "points_by_models": {1: 85}, "models": 1, "max_supported_copies": 3, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "JUMP PACK", "TACTICUS", "INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "DEATH COMPANY", "FLY"],
		"options": {"loadout_packages": ["default", "hand-flamer-power-fist", "plasma-pistol-power-fist", "heavy-bolt-pistol-power-fist", "hand-flamer-relic-weapon", "plasma-pistol-relic-weapon", "heavy-bolt-pistol-relic-weapon", "thunder-hammer-shield", "chainsword-shield"]},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 8, 2, 5, -1, 1, {"sustained-hits": 1})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 5, 2, 8, -2, 2, {})}},
			{"id": "relic-weapon", "profiles": {"standard": _weapon("Relic Weapon", 0.0, 6, 2, 6, -2, 2, {})}},
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 5, 3, 8, -2, 3, {})}}
		]}
	},
	"astorath": {
		"name": "Astorath", "source_book_id": "000000021", "source_datasheet_id": "000000157",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "max_supported_copies": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "BLOOD ANGELS", "FLY", "CHARACTER", "CHAPLAIN", "INFANTRY", "EPIC HERO", "TACTICUS", "IMPERIUM", "JUMP PACK"],
		"ranged": [], "melee": [{"id": "executioners-axe", "profiles": {"standard": _weapon("The Executioner's Axe", 0.0, 6, 2, 7, -3, 2, {"precision": true, "devastating-wounds": true})}}]
	},
	"lemartes": {
		"name": "Lemartes", "source_book_id": "000000021", "source_datasheet_id": "000000164",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 110, "points_by_models": {1: 110}, "models": 1, "max_supported_copies": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "TACTICUS", "INFANTRY", "IMPERIUM", "DEATH COMPANY", "JUMP PACK", "FLY", "EXPLOSIVES", "EPIC HERO", "CHARACTER", "CHAPLAIN"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 2, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "blood-crozius", "profiles": {"standard": _weapon("The Blood Crozius", 0.0, 6, 2, 6, -2, 2, {"lethal-hits": true, "cleave": 1})}}]
	},
	"sanguinary-guard": {
		"name": "Sanguinary Guard", "source_book_id": "000000021", "source_datasheet_id": "000000165",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 135, "points_by_models": {3: 135, 6: 275}, "third_plus_points_by_models": {3: 150, 6: 290}, "models": 3, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "JUMP PACK", "INFANTRY", "EXPLOSIVES", "FLY", "IMPERIUM", "TACTICUS"],
		"options": {"priced_model_counts": [3, 6], "inferno_pistol_replacements_per": 3},
		"ranged": [{"id": "angelus-boltgun", "profiles": {"standard": _weapon("Angelus Boltgun", 18.0, 3, 2, 5, -1, 1, {"assault": true, "close-quarters": true})}}],
		"melee": [{"id": "encarmine-weapon", "profiles": {"standard": _weapon("Encarmine Weapon", 0.0, 4, 2, 6, -2, 2, {"lance": true})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 2, 8, -3, "D3+2", {"melta": 1, "close-quarters": true})}}
		]}
	},
	"commander-dante": {
		"name": "Commander Dante", "source_book_id": "000000021", "source_datasheet_id": "000000151",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 140, "points_by_models": {1: 140}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "EPIC HERO", "JUMP PACK", "CHARACTER", "EXPLOSIVES", "FLY", "INFANTRY", "IMPERIUM", "TACTICUS", "CHAPTER MASTER"],
		"ranged": [{"id": "perdition-pistol", "profiles": {"standard": _weapon("Perdition Pistol", 9.0, 1, 2, 10, -3, "D3+2", {"sustained-hits": 1, "melta": 2, "close-quarters": true})}}],
		"melee": [{"id": "axe-mortalis", "profiles": {"standard": _weapon("The Axe Mortalis", 0.0, 8, 2, 8, -3, 2, {"lethal-hits": true})}}]
	},
	"the-sanguinor": {
		"name": "The Sanguinor", "source_book_id": "000000021", "source_datasheet_id": "000000156",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 120, "points_by_models": {1: 120}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "FLY", "INFANTRY", "IMPERIUM", "TACTICUS", "JUMP PACK"],
		"ranged": [],
		"melee": [{"id": "encarmine-broadsword", "profiles": {"standard": _weapon("Encarmine Broadsword", 0.0, 8, 2, 6, -3, 2, {"devastating-wounds": true})}}]
	},
	"mephiston": {
		"name": "Chief Librarian Mephiston", "source_book_id": "000000021", "source_datasheet_id": "000000155",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 175, "points_by_models": {1: 175}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "psychic_level": 3,
		"keywords": ["ADEPTUS ASTARTES", "BLOOD ANGELS", "TACTICUS", "INFANTRY", "CHARACTER", "EPIC HERO", "PSYKER", "IMPERIUM", "EXPLOSIVES"],
		"default_loadout_by_role": {"Chief Librarian Mephiston": {"Fury of the Ancients": 1, "Plasma Pistol": 1, "Vitarus": 1}},
		"ranged": [
			{"id": "fury-of-the-ancients", "profiles": {
				"focused": _weapon("Fury of the Ancients - Focused Witchfire", 18.0, 3, 2, 6, -2, 3, {"assault": true, "close-quarters": true, "psychic": true, "hazardous": true}),
				"witchfire": _weapon("Fury of the Ancients - Witchfire", 18.0, 3, 2, 5, -1, 2, {"assault": true, "close-quarters": true, "psychic": true})}},
			{"id": "plasma-pistol", "profiles": {
				"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true, "assault": true}),
				"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "assault": true})}}
		],
		"melee": [{"id": "vitarus", "profiles": {"standard": _weapon("Vitarus", 0.0, 6, 2, 10, -3, 3, {"psychic": true, "lethal-hits": true})}}]
	},
	"sanguinary-priest": {
		"name": "Sanguinary Priest", "source_book_id": "000000021", "source_datasheet_id": "000000158",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 60, "points_by_models": {1: 60}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "IMPERIUM", "TACTICUS", "INFANTRY", "CHARACTER", "EXPLOSIVES"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 5, 3, 5, -1, 1, {})}}]
	},
	"baal-predator": {
		"name": "Baal Predator", "source_book_id": "000000021", "source_datasheet_id": "000000168", "source_role": "Vehicle",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 135, "points_by_models": {1: 135}, "third_plus_points_by_models": {1: 150}, "max_supported_copies": 3, "models": 1,
		"base_size_source": "Use model", "geometry_scope": "Provisional 90 mm circular model-footprint proxy; the source does not provide dimensions.", "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 12, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["VEHICLE", "FRAME", "IMPERIUM", "SMOKE", "BLOOD ANGELS", "ADEPTUS ASTARTES"],
		"options": {"primary_cannon": ["twin-assault-cannon", "baal-flamestorm-cannon"], "sponson_package": ["none", "heavy-bolters", "heavy-flamers"], "storm_bolter": true, "hunter_killer_missile": true},
		"ranged": [{"id": "twin-assault-cannon", "profiles": {"standard": _weapon("Twin Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1, "twin-linked": true, "assault": true})}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "baal-flamestorm-cannon", "profiles": {"standard": _weapon("Baal Flamestorm Cannon", 18.0, 6, 0, 6, -2, 2, {"blast": 2, "torrent": true, "assault": true})}},
			{"id": "heavy-bolter-sponson-left", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "assault": true})}},
			{"id": "heavy-bolter-sponson-right", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "assault": true})}},
			{"id": "heavy-flamer-sponson-left", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"blast": 2, "assault": true, "torrent": true})}},
			{"id": "heavy-flamer-sponson-right", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"blast": 2, "assault": true, "torrent": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2, "assault": true})}},
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"assault": true, "one-shot": true})}}
		]}
	},
	"death-company-dreadnought": {
		"name": "Death Company Dreadnought", "source_book_id": "000000021", "source_datasheet_id": "000000166", "source_role": "Walker",
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": 165, "points_by_models": {1: 165}, "third_plus_points_by_models": {1: 185}, "max_supported_copies": 3, "models": 1,
		"base_size_source_mm": 90, "base_radius_inches": 45.0 / 25.4, "damaged_threshold": 4,
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0},
		"keywords": ["BLOOD ANGELS", "ADEPTUS ASTARTES", "DEATH COMPANY", "IMPERIUM", "WALKER", "VEHICLE", "DREADNOUGHT"],
		"options": {"twin_multi_melta": true, "blood_talons": true},
		"ranged": [
			{"id": "blood-fist-bolt-rifles", "profiles": {"standard": _weapon("Blood Fist Bolt Rifles", 24.0, 4, 3, 5, -1, 1, {"twin-linked": true})}},
			{"id": "twin-heavy-bolter-death-company-dreadnought", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "twin-linked": true})}},
			{"id": "twin-icarus-ironhail-heavy-stubber-death-company-dreadnought", "profiles": {"standard": _weapon("Twin Icarus Ironhail Heavy Stubber", 36.0, 3, 3, 4, -1, 1, {"anti-fly": 3, "rapid-fire": 3, "twin-linked": true})}}
		],
		"melee": [{"id": "blood-fists", "profiles": {"standard": _weapon("Blood Fists", 0.0, 6, 3, 12, -3, "D3+3", {"twin-linked": true})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "twin-multi-melta-death-company-dreadnought", "profiles": {"standard": _weapon("Twin Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3, "twin-linked": true})}}
		], "melee": [_death_company_blood_talons()]}
	},
	"death-company-marines": _death_company_squad_profile(false),
	"death-company-marines-with-jump-packs": _death_company_squad_profile(true),
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
	"lion-eljonson": {
		"name": "Lion El’jonson", "source_book_id": "000000023", "source_datasheet_id": "000002682", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 415, "points_by_models": {1: 415}, "models": 1, "max_supported_copies": 1, "base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 16, "leadership_target": 5, "objective_control": 4, "invulnerable_target": 3},
		"keywords": ["MONSTER", "CHARACTER", "EPIC HERO", "IMPERIUM", "MOBILE", "PRIMARCH", "ADEPTUS ASTARTES", "DARK ANGELS"],
		"ranged": [{"id": "arma-luminis", "physical_weapon_id": "arma-luminis", "profiles": {
			"plasma": _weapon("Arma Luminis - Plasma", 18.0, 2, 2, 10, -3, 3, {"close-quarters": true}),
			"bolt": _weapon("Arma Luminis - Bolt", 18.0, 4, 2, 6, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "fealty", "physical_weapon_id": "fealty", "profiles": {
			"sweep": _weapon("Fealty - Sweep", 0.0, 12, 2, 6, -3, 2, {"sustained-hits": 1, "cleave": 2}),
			"strike": _weapon("Fealty - Strike", 0.0, 8, 2, 12, -4, 4, {"lethal-hits": true})}}]
	},
	"emperor-s-champion": {
		"name": "Emperor’s Champion", "source_book_id": "000000162", "source_datasheet_id": "000002795", "source_export_updated_at": "2026-10-21 16:06:23 GMT+3",
		"points": 100, "points_by_models": {1: 100}, "models": 1, "max_supported_copies": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "black-sword", "physical_weapon_id": "black-sword", "profiles": {
			"sweep": _weapon("Black Sword - Sweep", 0.0, 10, 2, 6, -2, 1, {}),
			"strike": _weapon("Black Sword - Strike", 0.0, 6, 2, 8, -3, 3, {"precision": true, "anti-character": 5, "devastating-wounds": true})}}]
	},
	"high-marshal-helbrecht": {
		"name": "High Marshal Helbrecht", "source_book_id": "000000162", "source_datasheet_id": "000002794", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 125, "points_by_models": {1: 125}, "models": 1, "max_supported_copies": 1, "base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "EPIC HERO", "CHAPTER MASTER", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"ranged": [{"id": "ferocity", "profiles": {"standard": _weapon("Ferocity", 24.0, 2, 2, 5, -1, 2, {"anti-infantry": 4, "devastating-wounds": true})}}],
		"melee": [{"id": "sword-of-the-high-marshals", "physical_weapon_id": "sword-of-the-high-marshals", "profiles": {
			"strike": _weapon("Sword of the High Marshals - Strike", 0.0, 6, 2, 9, -3, 3, {}),
			"sweep": _weapon("Sword of the High Marshals - Sweep", 0.0, 12, 2, 6, -3, 1, {})}}]
	},
	"castellan": {
		"name": "Castellan", "source_book_id": "000000162", "source_datasheet_id": "000002793", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "LIEUTENANT", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"options": {"ranged_packages": ["combi-weapon", "heavy-bolt-pistol"], "melee_packages": ["master-crafted-power-weapon", "chainsword"]},
		"ranged": [{"id": "combi-weapon", "physical_weapon_id": "combi-weapon", "profiles": {
			"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 2, 7, -2, 2, {}),
			"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 2, 9, -3, "D3+2", {"melta": 2}),
			"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"torrent": true, "blast": 1})
		}}],
		"melee": [{"id": "master-crafted-power-weapon", "physical_weapon_id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {"lethal-hits": true})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "heavy-bolt-pistol", "physical_weapon_id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 4, -1, 1, {"close-quarters": true})}}],
			"melee": [{"id": "chainsword", "physical_weapon_id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 7, 2, 5, -1, 1, {"sustained-hits": 1})}}]}
	},
	"marshal": {
		"name": "Marshal", "source_book_id": "000000162", "source_datasheet_id": "000002796", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"options": {"ranged_packages": ["plasma-pistol", "combi-weapon"]},
		"ranged": [{"id": "plasma-pistol", "physical_weapon_id": "plasma-pistol", "profiles": {
			"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}),
			"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"hazardous": true, "close-quarters": true})
		}}],
		"melee": [{"id": "master-crafted-power-weapon", "physical_weapon_id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 7, 2, 6, -2, 2, {"lethal-hits": true})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "combi-weapon", "physical_weapon_id": "combi-weapon", "profiles": {
			"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 2, 9, -3, "D3+2", {"melta": 2}),
			"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"blast": 1, "torrent": true}),
			"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 2, 7, -2, 2, {})
		}}]}
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
			"heavy_flamer": {"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
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
		"points": 140, "points_by_models": {5: 140}, "third_plus_points_by_models": {5: 150}, "max_supported_copies": 2, "models": 5, "base_radius_inches": 16.0 / 25.4,
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
	},
	"deathwatch-veterans": {
		"name": "Deathwatch Veterans", "source_book_id": "000000035", "source_datasheet_id": "000002783", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "2ea710d11525e1ac9bb5d38cd5ea4b20f8dbcc36d615cd7c4f485cdf3f77ba58",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwatch-Veterans",
		"points": 115, "points_by_models": {5: 115, 10: 220}, "models": 5, "base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "DEATHWATCH", "KILL TEAM"],
		"default_loadout_by_role": {
			"Watch Sergeant": {"Boltgun": 1, "Power Weapon": 1},
			"Deathwatch Veteran": {"Boltgun": 1, "Power Weapon": 1}
		},
		"options": {
			"sergeant_ranged_replacements": ["combi-weapon"],
			"sergeant_melee_replacements": ["xenophase-blade"],
			"veteran_loadouts": ["default", "stalker-pattern-boltgun", "infernus-heavy-bolter", "deathwatch-shotgun", "heavy-thunder-hammer", "frag-cannon", "black-shield-blades", "boltgun-storm-shield", "power-weapon-storm-shield"]
		},
		"ranged": [{"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}}],
		"melee": [{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 3, 3, 5, -2, 1, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "combi-weapon", "profiles": {
					"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 3, 9, -3, "D3+2", {}),
					"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"torrent": true, "blast": 1}),
					"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 3, 7, -2, 2, {"melta": 2})}},
				{"id": "stalker-pattern-boltgun", "profiles": {"standard": _weapon("Stalker-pattern Boltgun", 24.0, 1, 3, 5, -1, 2, {"heavy": true, "precision": true})}},
				{"id": "infernus-heavy-bolter", "profiles": {
					"bolt": _weapon("Infernus Heavy Bolter - Bolt", 36.0, 3, 3, 5, -1, 2, {"heavy": true, "rapid-fire": 2, "sustained-hits": 1}),
					"infernus": _weapon("Infernus Heavy Bolter - Infernus", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 1})}},
				{"id": "deathwatch-shotgun", "profiles": {"standard": _weapon("Deathwatch Shotgun", 18.0, 2, 3, 4, -1, 2, {"assault": true})}},
				{"id": "frag-cannon", "profiles": {"standard": _weapon("Frag Cannon", 18.0, 2, 3, 7, -2, 2, {"heavy": true, "lethal-hits": true, "rapid-fire": 1, "blast": 1})}}
			],
			"melee": [
				{"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}},
				{"id": "heavy-thunder-hammer", "profiles": {"standard": _weapon("Heavy Thunder Hammer", 0.0, 3, 4, 10, -2, 3, {"devastating-wounds": true})}},
				{"id": "black-shield-blades", "profiles": {"standard": _weapon("Black Shield Blades", 0.0, 4, 3, 5, -2, 1, {"twin-linked": true})}},
				{"id": "xenophase-blade", "profiles": {"standard": _weapon("Xenophase Blade", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}}
			]
		}
	},
	"fortis-kill-team": {
		"name": "Fortis Kill Team", "source_book_id": "000000035", "source_datasheet_id": "000002780", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "815e9a66fe60f16513dcd436fc48835047b9a76febcf09e7cd4ba18b15f39998",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Fortis-Kill-Team",
		"points": 210, "points_by_models": {10: 210}, "third_plus_points_by_models": {10: 225}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS"],
		"model_loadouts": [fortis_kill_team_model_loadout(0), fortis_kill_team_model_loadout(1), fortis_kill_team_model_loadout(2), fortis_kill_team_model_loadout(3), fortis_kill_team_model_loadout(4), fortis_kill_team_model_loadout(5), fortis_kill_team_model_loadout(6), fortis_kill_team_model_loadout(7), fortis_kill_team_model_loadout(8), fortis_kill_team_model_loadout(9)],
		"options": {
			"sergeant_melee_replacements": ["chainsword", "power-fist", "power-weapon", "thunder-hammer"],
			"sergeant_ranged_replacements": ["chainsword", "hand-flamer", "plasma-pistol", "power-weapon"],
			"grenade_launchers_per_five_models": 1,
			"plasma_pistol_limit": 1,
			"rocket_launcher_replacements": ["superkrak", "vengor"]
		},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "castellan-launcher", "profiles": {"standard": _weapon("Castellan Launcher", 24.0, 2, 3, 5, -1, 1, {"heavy": true})}},
			{"id": "deathwatch-bolt-rifle", "profiles": {"standard": _weapon("Deathwatch Bolt Rifle", 24.0, 2, 3, 5, -2, 1, {"assault": true, "lethal-hits": true, "heavy": true})}},
			{"id": "grenade-launcher", "profiles": {"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}), "krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}},
			{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "plasma-incinerator", "profiles": {"standard": _weapon("Plasma Incinerator - Standard", 24.0, 2, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}), "supercharge": _weapon("Plasma Incinerator - Supercharge", 24.0, 2, 3, 8, -3, 2, {"assault": true, "rapid-fire": 1, "hazardous": true})}},
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}},
			{"id": "pyreblaster", "profiles": {"standard": _weapon("Pyreblaster", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 1})}},
			{"id": "superfrag-rocket-launcher", "profiles": {"standard": _weapon("Superfrag Rocket Launcher", 48.0, 4, 3, 5, -1, 1, {"blast": 1, "heavy": true})}},
			{"id": "superkrak-rocket-launcher", "profiles": {"standard": _weapon("Superkrak Rocket Launcher", 48.0, 1, 3, 10, -2, "D3+3", {"heavy": true})}},
			{"id": "vengor-launcher", "profiles": {"standard": _weapon("Vengor Launcher", 48.0, 4, 3, 7, -1, 2, {"blast": 1, "indirect-fire": true, "heavy": true})}}
		],
		"melee": [
			{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}},
			{"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}},
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}},
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
		]
	},
	"spectrus-kill-team": {
		"name": "Spectrus Kill Team", "source_book_id": "000000035", "source_datasheet_id": "000002779", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "4290befd02adf74ce1500df2c2425f9cb81b87d4d4b62fc0f9a39b17e3f05ade",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Spectrus-Kill-Team",
		"points": 185, "points_by_models": {10: 185}, "third_plus_points_by_models": {10: 195}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "IMPERIUM", "SMOKE", "EXPLOSIVES", "KILL TEAM", "PHOBOS"],
		"model_loadouts": [spectrus_kill_team_model_loadout(0), spectrus_kill_team_model_loadout(1), spectrus_kill_team_model_loadout(2), spectrus_kill_team_model_loadout(3), spectrus_kill_team_model_loadout(4), spectrus_kill_team_model_loadout(5), spectrus_kill_team_model_loadout(6), spectrus_kill_team_model_loadout(7), spectrus_kill_team_model_loadout(8), spectrus_kill_team_model_loadout(9)],
		"options": {"helix_gauntlet_limit": 1, "sniper_rifle_replacements": ["las-fusil", "instigator-bolt-carbine"], "combat_knife_replacement": "deathwatch-bolt-carbine-and-ceramite-fists"},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "bolt-sniper-rifle", "profiles": {"standard": _weapon("Bolt Sniper Rifle", 36.0, 1, 3, 6, -2, 3, {"precision": true, "heavy": true})}},
			{"id": "deathwatch-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"precision": true, "lethal-hits": true})}},
			{"id": "deathwatch-marksman-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"heavy": true, "lethal-hits": true})}},
			{"id": "deathwatch-occulus-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Occulus Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"assault": true, "ignores-cover": true, "lethal-hits": true})}},
			{"id": "instigator-bolt-carbine", "profiles": {"standard": _spectrus_instigator_bolt_carbine()}},
			{"id": "las-fusil", "profiles": {"standard": _weapon("Las Fusil", 36.0, 1, 3, 10, -3, "D3+3", {"heavy": true})}},
			{"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true, "precision": true})}}
		],
		"melee": [
			{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}},
			{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 4, 3, 5, -1, 1, {"precision": true})}},
			{"id": "paired-combat-blades", "profiles": {"standard": _weapon("Paired Combat Blades", 0.0, 3, 3, 5, -1, 1, {"sustained-hits": 1})}}
		]
	},
	"indomitor-kill-team": {
		"name": "Indomitor Kill Team", "source_book_id": "000000035", "source_datasheet_id": "000002781", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "d52d0ec3d53cf0a24bce0b7c9a89afe7612ea3d4868a8baa8bd46bbb1ce0f08d",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Indomitor-Kill-Team",
		"points": 280, "points_by_models": {10: 280}, "third_plus_points_by_models": {10: 300}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "GRAVIS", "IMPERIUM"],
		"model_loadouts": [indomitor_kill_team_model_loadout(0), indomitor_kill_team_model_loadout(1), indomitor_kill_team_model_loadout(2), indomitor_kill_team_model_loadout(3), indomitor_kill_team_model_loadout(4), indomitor_kill_team_model_loadout(5), indomitor_kill_team_model_loadout(6), indomitor_kill_team_model_loadout(7), indomitor_kill_team_model_loadout(8), indomitor_kill_team_model_loadout(9)],
		"options": {"heavy_bolters_per_five_models": 1, "auto_boltstorm_gauntlets": "any flamestorm gauntlet bearer", "multi_melta_limit": 1},
		"ranged": [
			{"id": "auto-boltstorm-gauntlets", "profiles": {"standard": _weapon("Auto Boltstorm Gauntlets", 18.0, 3, 3, 5, -1, 1, {"twin-linked": true, "close-quarters": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "deathwatch-heavy-bolt-rifle", "profiles": {"standard": _weapon("Deathwatch Heavy Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"assault": true, "lethal-hits": true, "heavy": true})}},
			{"id": "deathwatch-heavy-bolter", "profiles": {"standard": _weapon("Deathwatch Heavy Bolter", 36.0, 3, 3, 5, -2, 3, {"assault": true, "heavy": true, "lethal-hits": true, "sustained-hits": 1})}},
			{"id": "flamestorm-gauntlets", "profiles": {"standard": _weapon("Flamestorm Gauntlets", 12.0, 3, 0, 4, -1, 1, {"blast": 2, "torrent": true, "twin-linked": true}), "close-quarters": _weapon("Flamestorm Gauntlets - Close Quarters", 12.0, 3, 0, 4, -1, 1, {"close-quarters": true, "twin-linked": true, "torrent": true})}},
			{"id": "fragstorm-grenade-launcher", "profiles": {"standard": _weapon("Fragstorm Grenade Launcher", 18.0, 3, 3, 4, -1, 1, {"blast": 1})}},
			{"id": "melta-rifle", "profiles": {"standard": _weapon("Melta Rifle", 18.0, 1, 3, 10, -3, "D3+2", {"melta": 2}), "hunter": _weapon("Melta Rifle - Hunter", 18.0, 1, 2, 12, -3, "D3+2", {"melta": 2, "hunter": ["Monster", "Vehicle"]})}},
			{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3}), "hunter": _weapon("Multi-melta - Hunter", 18.0, 2, 2, 12, -3, "D3+2", {"melta": 3, "hunter": ["Monster", "Vehicle"]})}}
		],
		"melee": [
			{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}},
			{"id": "twin-power-fists", "profiles": {"standard": _weapon("Twin Power Fists", 0.0, 3, 3, 8, -2, 2, {"twin-linked": true})}}
		]
	},
	"decimus-kill-team": {
		"name": "Decimus Kill Team", "source_book_id": "000000035", "source_datasheet_id": "000004175", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z", "source_manifest_sha256": "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e", "source_slice_manifest_sha256": "b258edd148a8b4f1dcb1dd174721c132b8337e6533b8aea597871dd96cd1aa88",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team",
		"points": 210, "points_by_models": {5: 110, 10: 210}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "BATTLELINE", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "GRAVIS"],
		"model_loadouts": [decimus_kill_team_model_loadout("xenophase-veteran"), decimus_kill_team_model_loadout("sergeant"), decimus_kill_team_model_loadout("marksman-veteran"), decimus_kill_team_model_loadout("heavy-veteran"), decimus_kill_team_model_loadout("stalker-veteran"), decimus_kill_team_model_loadout("gravis-veteran")],
		"composition_options": decimus_kill_team_composition_options(), "default_composition_choice_ids": {10: "ten-balanced"},
		"options": {"gravis_replacements_per_five_models": 1, "storm_shields_per_five_models": 1, "plasma_incinerators_per_five_models": 1},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "deathwatch-marksman-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"lethal-hits": true, "heavy": true})}},
			{"id": "frag-cannon", "profiles": {"standard": _weapon("Frag Cannon", 18.0, 2, 3, 7, -2, 2, {"lethal-hits": true, "blast": 1, "heavy": true, "rapid-fire": 1})}},
			{"id": "grenade-launcher", "profiles": {"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}), "krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}},
			{"id": "hellstorm-bolt-rifle", "profiles": {"standard": _weapon("Hellstorm Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"lethal-hits": true, "assault": true, "heavy": true})}},
			{"id": "infernus-heavy-bolter", "profiles": {"bolt": _weapon("Infernus Heavy Bolter - Bolt", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "heavy": true, "sustained-hits": 1}), "infernus": _weapon("Infernus Heavy Bolter - Infernus", 12.0, 3, 0, 5, -1, 1, {"blast": 1, "torrent": true})}},
			{"id": "plasma-incinerator", "profiles": {"standard": _weapon("Plasma Incinerator - Standard", 24.0, 2, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}), "supercharge": _weapon("Plasma Incinerator - Supercharge", 24.0, 2, 3, 8, -3, 2, {"hazardous": true, "rapid-fire": 1, "assault": true})}},
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}},
			{"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true, "precision": true, "lethal-hits": true})}},
			{"id": "stalker-bolt-rifle", "profiles": {"standard": _weapon("Stalker Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"precision": true, "heavy": true, "lethal-hits": true})}}
		],
		"melee": [
			{"id": "heavy-thunder-hammer", "profiles": {"standard": _weapon("Heavy Thunder Hammer", 0.0, 3, 4, 10, -2, 3, {"devastating-wounds": true})}},
			{"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {"sustained-hits": 1})}},
			{"id": "xenophase-blade", "profiles": {"standard": _weapon("Xenophase Blade", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}}
		]
	},
	"talonstrike-kill-team": {
		"name": "Talonstrike Kill Team", "source_book_id": "000000035", "source_datasheet_id": "000003874", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T072022Z", "source_manifest_sha256": "772952e313b6772022c68226514eba7cdde00464468fd79c8291d20c24da4801", "source_slice_manifest_sha256": "14091c1c687942cffa668a3cab4deaf007562f9a4c40c94a7d15893394e85d26",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Talonstrike-Kill-Team",
		"points": 280, "points_by_models": {10: 280}, "third_plus_points_by_models": {10: 300}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": [32, 40, 40, 40, 40, 32, 32, 32, 32, 32], "base_radius_inches": 20.0 / 25.4, "base_geometry": "per-model-circles", "geometry_scope": "The 32 mm Sergeant and Intercessor bases and 40 mm Heavy Intercessor bases are assigned by model index; the catalog proxy uses the largest 40 mm base.",
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "JUMP PACK", "FLY", "IMPERIUM", "GRAVIS", "TACTICUS"],
		"model_loadouts": [talonstrike_kill_team_model_loadout(0), talonstrike_kill_team_model_loadout(1), talonstrike_kill_team_model_loadout(2), talonstrike_kill_team_model_loadout(3), talonstrike_kill_team_model_loadout(4), talonstrike_kill_team_model_loadout(5), talonstrike_kill_team_model_loadout(6), talonstrike_kill_team_model_loadout(7), talonstrike_kill_team_model_loadout(8), talonstrike_kill_team_model_loadout(9)],
		"options": {"sergeant_melee_replacements": ["power-fist", "power-weapon"], "sergeant_ranged_replacements": ["hand-flamer", "plasma-pistol"], "intercessor_plasma_pistols_per_five_models": 1, "heavy_intercessor_plasma_exterminators": "any"},
		"ranged": [
			{"id": "assault-bolters", "profiles": {"standard": _weapon("Assault Bolters", 18.0, 3, 3, 5, -1, 2, {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true})}},
			{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "plasma-exterminators", "profiles": {"standard": _weapon("Plasma Exterminators - Standard", 18.0, 2, 3, 7, -2, 2, {"twin-linked": true, "assault": true, "close-quarters": true}), "supercharge": _weapon("Plasma Exterminators - Supercharge", 18.0, 2, 3, 8, -3, 3, {"close-quarters": true, "assault": true, "hazardous": true, "twin-linked": true})}},
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		],
		"melee": [
			{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}},
			{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}},
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
		]
	},
	"deathwatch-terminator-squad": {
		"name": "Deathwatch Terminator Squad", "source_book_id": "000000035", "source_datasheet_id": "000003873", "source_export_updated_at": "2026-10-21T16:06:23+03:00",
		"source_snapshot_id": "20261021T130623Z", "source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf", "source_slice_manifest_sha256": "bb1f51192a559283a25ee27ff5d87cb25252f1e99d806d7dca5949e86d51f093",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwatch-Terminator-Squad",
		"points": 190, "points_by_models": {5: 190, 10: 380}, "third_plus_points_by_models": {5: 230, 10: 420}, "wargear_costs": {"storm-shield": 5, "cyclone-missile-launcher": 10}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "TERMINATOR", "IMPERIUM"],
		"default_loadout_by_role": {"Deathwatch Terminator Sergeant": {"Power Fist": 1, "Storm Bolter": 1}, "Deathwatch Terminator": {"Power Fist": 1, "Storm Bolter": 1}},
		"options": {
			"melee_packages": ["power-fist", "storm-bolter-chainfist", "storm-bolter-power-weapon", "thunder-hammer-storm-shield", "twin-lightning-claws"],
			"special_weapons": ["assault-cannon", "cyclone-missile-launcher", "heavy-flamer", "plasma-cannon"],
			"max_special_weapons": 3,
			"special_weapons_require_storm_bolter": true
		},
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
			{"id": "cyclone-missile-launcher", "profiles": {
				"frag": _weapon("Cyclone Missile Launcher - Frag", 36.0, 8, 3, 4, -1, 1, {"blast": 2}),
				"krak": _weapon("Cyclone Missile Launcher - Krak", 36.0, 2, 3, 10, -2, "D3+3", {})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 2})}},
			{"id": "plasma-cannon", "profiles": {
				"standard": _weapon("Plasma Cannon - Standard", 36.0, 3, 3, 9, -2, 2, {"blast": 1}),
				"supercharge": _weapon("Plasma Cannon - Supercharge", 36.0, 3, 3, 10, -3, 3, {"blast": 1, "hazardous": true})}}
		], "melee": [
			{"id": "chainfist", "profiles": {
				"standard": _weapon("Chainfist - Standard", 0.0, 2, 4, 8, -2, 2, {}),
				"hunter": _weapon("Chainfist - Hunter", 0.0, 3, 3, 12, -2, 3, {"hunter": ["Monster", "Vehicle"]})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 5, 3, 5, -2, 1, {})}},
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 3, 8, -2, 3, {"devastating-wounds": true})}},
			{"id": "twin-lightning-claws", "profiles": {"standard": _weapon("Twin Lightning Claws", 0.0, 6, 3, 5, -2, 1, {"twin-linked": true})}}
		]}
	},
	"watch-master": {
		"name": "Watch Master", "source_book_id": "000000035", "source_datasheet_id": "000003871", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "680cff731d32f16de516ae815963dc18ecb5091e51b95843dacc595999aca4de",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Watch-Master",
		"points": 105, "points_by_models": {1: 105}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES", "DEATHWATCH"],
		"ranged": [{"id": "vigil-spear", "physical_weapon_id": "vigil-spear", "profiles": {"standard": _weapon("Vigil Spear", 24.0, 2, 2, 5, -1, 2, {})}}],
		"melee": [{"id": "vigil-spear-lance", "physical_weapon_id": "vigil-spear", "profiles": {"standard": _weapon("Vigil Spear", 0.0, 6, 2, 6, -2, 2, {"lance": true})}}]
	},
	"watch-captain-artemis": {
		"name": "Watch Captain Artemis", "source_book_id": "000000035", "source_datasheet_id": "000003872", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "eb17311be3c05709b6f91c747dee5e7e8ec91b9a90c2555c3232ba9dfbdfbfca",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Watch-Captain-Artemis",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CAPTAIN", "CHARACTER", "EPIC HERO", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES", "DEATHWATCH"],
		"ranged": [{"id": "hellfire-extremis", "profiles": {"standard": _weapon("Hellfire Extremis", 12.0, 3, 0, 4, -1, 1, {"torrent": true, "ignores-cover": true, "devastating-wounds": true, "anti-infantry": 4})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}]
	},
	"arjac-rockfist": {
		"name": "Arjac Rockfist", "source_book_id": "000000036", "source_datasheet_id": "000000317", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "D63245311AC15F3B13E1A0235E9A642FD374D2ECD0B1853F791EE4981633DC06",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Arjac-Rockfist",
		"points": 105, "points_by_models": {1: 105}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TERMINATOR"],
		"ranged": [{"id": "foehammer-ranged", "physical_weapon_id": "foehammer", "profiles": {"standard": _weapon("Foehammer", 9.0, 1, 2, 10, -2, 3, {"assault": true, "anti-monster": 3, "anti-vehicle": 3})}}],
		"melee": [{"id": "foehammer-melee", "physical_weapon_id": "foehammer", "profiles": {"standard": _weapon("Foehammer", 0.0, 5, 2, 10, -2, 3, {"anti-monster": 3, "anti-vehicle": 3, "precision": true})}}]
	},
	"logan-grimnar": {
		"name": "Logan Grimnar", "source_book_id": "000000036", "source_datasheet_id": "000000282", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "6DB0CD7F582C0A87EC57AB91C02C8A5CF88A2E5B102224F26F9F1B3C5FD12E92",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Logan-Grimnar",
		"points": 150, "points_by_models": {1: 150}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 80, "base_radius_inches": 40.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "CHAPTER MASTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TERMINATOR"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 2, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [
			{"id": "axe-morkai", "physical_weapon_id": "axe-morkai", "profiles": {
				"strike": _weapon("Axe Morkai - Strike", 0.0, 6, 2, 10, -2, 3, {}),
				"sweep": _weapon("Axe Morkai - Sweep", 0.0, 10, 2, 6, -2, 1, {"cleave": 1})}},
			{"id": "tyrnak-and-fenrir", "profiles": {"standard": _weapon("Tyrnak and Fenrir", 0.0, 6, 2, 5, -1, 1, {"extra-attacks": true})}}
		]
	},
	"ragnar-blackmane": {
		"name": "Ragnar Blackmane", "source_book_id": "000000036", "source_datasheet_id": "000000285", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "5286C01DE5055F9D64992C43612387119BAA3F0F48851F284250A079626B18C2",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Ragnar-Blackmane",
		"points": 100, "points_by_models": {1: 100}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CAPTAIN", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"],
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "frostfang", "profiles": {"standard": _weapon("Frostfang", 0.0, 8, 2, 6, -3, 2, {"sustained-hits": 1})}}],
		"special_rules": ["Battle-lust", "War Howl"]
	},
	"ulrik-the-slayer": {
		"name": "Ulrik the Slayer", "source_book_id": "000000036", "source_datasheet_id": "000000297", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Ulrik-The-Slayer",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WOLF PRIEST"],
		"ranged": [{"id": "plasma-pistol", "physical_weapon_id": "plasma-pistol", "profiles": {
			"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}),
			"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"hazardous": true, "close-quarters": true})}}],
		"melee": [{"id": "artificer-crozius-arcanum", "profiles": {"standard": _weapon("Artificer Crozius Arcanum", 0.0, 5, 2, 6, -2, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
		"special_rules": ["Slayer's Oath", "Oathbound"]
	},
	"iron-priest": {
		"name": "Iron Priest", "source_book_id": "000000036", "source_datasheet_id": "000000306", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Iron-Priest",
		"points": 60, "points_by_models": {1: 60}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TECHMARINE"],
		"ranged": [{"id": "helfrost-pistol", "physical_weapon_id": "helfrost-pistol", "profiles": {
			"dispersed": _weapon("Helfrost Pistol - Dispersed", 12.0, 3, 0, 4, -1, 1, {"close-quarters": true, "torrent": true}),
			"focused": _weapon("Helfrost Pistol - Focused", 12.0, 1, 2, 6, -3, 3, {"close-quarters": true})}}],
		"melee": [{"id": "tempest-hammer-servo-arm", "profiles": {"standard": _weapon("Tempest Hammer and Servo-arm", 0.0, 4, 4, 8, -2, 3, {})}}],
		"special_rules": ["Gift of the Iron Wolf", "Iron Priest", "Judgement of the Omnissiah"]
	},
	"wolf-guard-battle-leader": {
		"name": "Wolf Guard Battle Leader", "source_book_id": "000000036", "source_datasheet_id": "000004130", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Battle-Leader",
		"points": 80, "points_by_models": {1: 80}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"],
		"options": {"ranged_loadouts": ["plasma-pistol", "storm-shield"], "melee_loadouts": ["master-crafted-power-weapon", "thunder-hammer"]},
		"ranged": [{"id": "plasma-pistol", "physical_weapon_id": "plasma-pistol", "profiles": {
			"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
			"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"hazardous": true, "close-quarters": true})}}],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 7, 2, 6, -2, 2, {})}}],
		"additional_weapon_profiles": {"melee": [{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 5, 3, 8, -2, 3, {"devastating-wounds": true})}}]},
		"special_rules": ["Tempered Ferocity", "Heroic Last Stand", "Storm Shield"]
	},
	"wolf-priest": {
		"name": "Wolf Priest", "source_book_id": "000000036", "source_datasheet_id": "000004129", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Priest",
		"points": 75, "points_by_models": {1: 75}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"],
		"ranged": [{"id": "absolvor-bolt-pistol", "profiles": {"standard": _weapon("Absolvor Bolt Pistol", 18.0, 1, 3, 5, -2, 2, {"close-quarters": true})}}],
		"melee": [{"id": "crozius-arcanum", "profiles": {"standard": _weapon("Crozius Arcanum", 0.0, 5, 2, 6, -1, 2, {})}}],
		"special_rules": ["Healing Balms", "Litany of Hate"]
	},
	"njal-stormcaller": {
		"name": "Njal Stormcaller", "source_book_id": "000000036", "source_datasheet_id": "000000292", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z", "source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d", "source_slice_manifest_sha256": "F41AEB60436222F786E32DEE7E4D472E5C5DED5A01C8A33F02A98EBAA86BB113",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Njal-Stormcaller",
		"points": 100, "points_by_models": {1: 100}, "models": 1, "max_supported_copies": 1,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "PSYKER", "SPACE WOLVES", "TACTICUS"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "living-lightning", "physical_weapon_id": "living-lightning", "profiles": {
				"focused-witchfire": _weapon("Living Lightning - Focused Witchfire", 24.0, "D6+6", 3, 7, -2, 1, {"psychic": true, "hazardous": true, "sustained-hits": 2}),
				"witchfire": _weapon("Living Lightning - Witchfire", 24.0, "D3+3", 3, 7, -1, 1, {"psychic": true, "sustained-hits": 2})}}
		],
		"melee": [{"id": "staff-of-the-stormcaller", "profiles": {"standard": _weapon("Staff of the Stormcaller", 0.0, 4, 3, 7, -1, 2, {"psychic": true, "sustained-hits": 2})}}]
	},
	"corvus-blackstar": {
		"name": "Corvus Blackstar", "source_book_id": "000000035", "source_datasheet_id": "000000358", "source_role": "Vehicle",
		"source_snapshot_id": "20261029T003124Z", "source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "fb094a1ec9d55c54de7d19d3b0b61f4d7517c00341bfa3c331b5d32d6109530b",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Corvus-Blackstar",
		"points": 180, "points_by_models": {1: 180}, "models": 1, "max_supported_copies": 3, "points_source": "wahapedia_e11_local_export_2026_10_29_deathwatch_app",
		"base_size_source_mm": [120, 92], "base_geometry": "oval", "base_radius_inches": 60.0 / 25.4,
		"geometry_scope": "The 120 x 92 mm oval uses a labelled 60 mm bounding-circle proxy for movement-over checks.", "damaged_threshold": 5,
		"stats": {"movement_inches": 14, "toughness": 10, "save_target": 3, "wounds": 14, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWATCH", "FLY", "IMPERIUM", "SMOKE", "TRANSPORT", "VEHICLE"],
		"default_loadout_by_role": {"Corvus Blackstar": {"Armoured Hull": 1, "Auspex Array": 1, "Blackstar Rocket Launcher": 2, "Twin Assault Cannon": 1}},
		"ranged": [
			{"id": "blackstar-rocket-launcher-left", "profiles": {"standard": _weapon("Blackstar Rocket Launcher", 30.0, 4, 3, 5, 0, 1, {"blast": true, "ignores-cover": true})}},
			{"id": "blackstar-rocket-launcher-right", "profiles": {"standard": _weapon("Blackstar Rocket Launcher", 30.0, 4, 3, 5, 0, 1, {"blast": true, "ignores-cover": true})}},
			{"id": "twin-assault-cannon", "profiles": {"standard": _weapon("Twin Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"twin-linked": true, "sustained-hits": 1, "ignores-cover": true})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "hurricane-bolter", "profiles": {"standard": _weapon("Hurricane Bolter", 24.0, 6, 3, 5, -1, 1, {"twin-linked": true, "rapid-fire": 6, "ignores-cover": true})}},
			{"id": "stormstrike-missile-launcher-left", "profiles": {"standard": _weapon("Stormstrike Missile Launcher", 48.0, 1, 3, 10, -2, 3, {"ignores-cover": true})}},
			{"id": "stormstrike-missile-launcher-right", "profiles": {"standard": _weapon("Stormstrike Missile Launcher", 48.0, 1, 3, 10, -2, 3, {"ignores-cover": true})}},
			{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true, "ignores-cover": true})}}
		]},
		"transport": {"capacity": 12, "required": ["DEATHWATCH", "INFANTRY"], "double_space": ["GRAVIS", "JUMP PACK", "TERMINATOR"], "options": {
			"add": ["Hurricane Bolter"], "replacements": {"Twin Assault Cannon": "Twin Lascannon"},
			"replacement_groups": {"blackstar-rocket-launchers": {"name": "Both Blackstar Rocket Launchers with two Stormstrike Missile Launchers", "from_ids": ["blackstar-rocket-launcher-left", "blackstar-rocket-launcher-right"], "to_ids": ["stormstrike-missile-launcher-left", "stormstrike-missile-launcher-right"]}}
		}},
		"core_abilities": ["Damaged 5", "Deadly Demise D6", "Hover", "Stealth"],
		"special_rules": ["Blackstar Cluster Launcher", "Auspex Array"]
	},
	"blood-claws": {
		"name": "Blood Claws", "source_book_id": "000000036", "source_datasheet_id": "000000303",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "8C713E966DCB17BEEFD5B3556FBCF674A6EAA7080F628C2ED128D1DEC89B78A2",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Blood-Claws",
		"points": 150, "points_by_models": {10: 150, 20: 290}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"],
		"default_loadout_by_role": {"Blood Claw Pack Leader": {"Bolt Pistol": 1, "Chainsword": 1}, "Blood Claw": {"Bolt Pistol": 1, "Chainsword": 1}},
		"options": {"pack_leader_ranged_packages": ["bolt-pistol", "plasma-pistol"], "pack_leader_melee_packages": ["chainsword", "power-weapon"]},
		"ranged": [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
		]},
		"special_rules": ["Berserk Charge"]
	},
	"grey-hunters": {
		"name": "Grey Hunters", "source_book_id": "000000036", "source_datasheet_id": "000000305",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "B7E39365429434EE6416607CA5AFE7B4AC59D5D7738392BDFC526518F716568F",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Grey-Hunters",
		"points": 180, "points_by_models": {10: 180}, "models": 10, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"],
		"default_loadout_by_role": {"Grey Hunter Pack Leader": {"Bolt Carbine": 1, "Bolt Pistol": 1, "Chainsword": 1}, "Grey Hunter": {"Bolt Carbine": 1, "Bolt Pistol": 1, "Chainsword": 1}},
		"options": {"pack_leader_ranged_packages": ["bolt-pistol", "plasma-pistol"], "pack_leader_melee_packages": ["chainsword", "power-fist", "power-weapon"]},
		"ranged": [
			{"id": "bolt-carbine", "profiles": {"standard": _weapon("Bolt Carbine", 24.0, 3, 3, 5, -1, 1, {"rapid-fire": 1, "assault": true})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
		], "melee": [
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
		]},
		"special_rules": ["Old Greymanes", "Cunning Hunters"]
	},
	"fenrisian-wolves": {
		"name": "Fenrisian Wolves", "source_book_id": "000000036", "source_datasheet_id": "000000323",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "DD01804235496759470C95A4B73CAFE3E04F924E10B5C62A68E2407B8E720EA1",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Fenrisian-Wolves",
		"points": 45, "points_by_models": {5: 45, 10: 75}, "third_plus_points_by_models": {5: 50, 10: 80}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 10, "toughness": 4, "save_target": 6, "wounds": 1, "leadership_target": 8, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "BEASTS", "IMPERIUM"],
		"default_loadout_by_role": {"Fenrisian Wolf": {"Teeth and Claws": 1}},
		"ranged": [],
		"melee": [{"id": "teeth-and-claws", "profiles": {"standard": _weapon("Teeth and Claws", 0.0, 3, 4, 4, 0, 1, {})}}],
		"special_rules": ["Predatory Instinct", "Hunting Hounds"]
	},
	"wolf-guard-terminators": {
		"name": "Wolf Guard Terminators", "source_book_id": "000000036", "source_datasheet_id": "000000318",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "BBF8E8372AA7A599BEEB7EC92CE309D2C8073C3A638F8A0CA4A52FB4AC78FB1E",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Terminators",
		"points": 180, "points_by_models": {5: 180, 10: 365}, "third_plus_points_by_models": {5: 220, 10: 405}, "wargear_costs": {"storm-shield": 5}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "INFANTRY", "IMPERIUM", "SPACE WOLVES", "TERMINATOR"],
		"default_loadout_by_role": {"Wolf Guard Terminator Pack Leader": {"Storm Bolter": 1, "Master-crafted Power Weapon": 1}, "Wolf Guard Terminator": {"Storm Bolter": 1, "Master-crafted Power Weapon": 1}},
		"options": {"pack_leader_loadouts": ["default", "storm-shield", "relic-greataxe", "twin-lightning-claws"], "terminator_loadouts": ["default", "storm-shield", "assault-cannon-power-fist"]},
		"ranged": [
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		],
		"melee": [
			{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 4, 3, 5, -2, 2, {})}}
		],
		"additional_weapon_profiles": {"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}}
		], "melee": [
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
			{"id": "relic-greataxe", "profiles": {"standard": _weapon("Relic Greataxe", 0.0, 3, 3, 8, -2, 3, {"devastating-wounds": true})}},
			{"id": "twin-lightning-claws", "profiles": {"standard": _weapon("Twin Lightning Claws", 0.0, 6, 3, 5, -2, 1, {"twin-linked": true})}}
		]},
		"special_rules": ["Rugged Resilience"]
	},
	"thunderwolf-cavalry": {
		"name": "Thunderwolf Cavalry", "source_book_id": "000000036", "source_datasheet_id": "000000322",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "238c7c2f9d776cab7fc5ebe7103157781cb2d72397fce3872a923c4f37f627ff",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Thunderwolf-Cavalry",
		"points": 115, "points_by_models": {3: 115, 6: 230}, "third_plus_points_by_models": {3: 145, 6: 260}, "wargear_costs": {"storm-shield": 5}, "models": 3, "max_supported_copies": 3,
		"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 12, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "MOUNTED", "SPACE WOLVES"],
		"default_loadout_by_role": {"Thunderwolf Cavalry Pack Leader": {"Bolt Pistol": 1, "Teeth and Claws": 1, "Wolf Guard Weapon": 1}, "Thunderwolf Cavalry": {"Bolt Pistol": 1, "Teeth and Claws": 1, "Wolf Guard Weapon": 1}},
		"options": {"loadouts": ["default", "plasma-pistol", "boltgun-storm-shield"], "plasma_pistols_per_three_models": 1, "storm_shield_cost_per_model": 5},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [
			{"id": "teeth-and-claws", "profiles": {"standard": _weapon("Teeth and Claws", 0.0, 3, 4, 5, -1, 1, {"extra-attacks": true})}},
			{"id": "wolf-guard-weapon", "profiles": {"standard": _weapon("Wolf Guard Weapon", 0.0, 4, 3, 5, -2, 2, {})}}
		],
		"additional_weapon_profiles": {"ranged": [
			{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}},
			{"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}}
		]},
		"special_rules": ["Combat Doctrines", "Thunderous Charge", "Storm Shield"]
	},
	"wulfen": {
		"name": "Wulfen", "source_book_id": "000000036", "source_datasheet_id": "000000311",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "f3dedbf36bf9fa30d6db0b22f1a6cc4f95f2dceef136def80846496eaf2fe9d3",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wulfen",
		"points": 90, "points_by_models": {5: 90, 10: 180}, "third_plus_points_by_models": {5: 105, 10: 195}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 9, "toughness": 6, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WULFEN"],
		"default_loadout_by_role": {"Wulfen": {"Death Totem": 1, "Wulfen Weapons": 1}},
		"options": {"loadouts": ["death-totem", "stormfrag-auto-launcher"]},
		"ranged": [],
		"melee": [
			{"id": "wulfen-weapons", "profiles": {"standard": _weapon("Wulfen Weapons", 0.0, 3, 3, 6, -2, 2, {"sustained-hits": 1})}}
		],
		"additional_weapon_profiles": {"ranged": [
			{"id": "stormfrag-auto-launcher", "profiles": {"standard": _weapon("Stormfrag Auto-launcher", 12.0, 2, 4, 4, -1, 1, {"assault": true, "blast": 1})}}
		]},
		"special_rules": ["Combat Doctrines", "Curse of the Wulfen", "Savage Frenzy", "Death Totem", "Bestial Forms"]
	},
	"wulfen-with-storm-shields": {
		"name": "Wulfen with Storm Shields", "source_book_id": "000000036", "source_datasheet_id": "000004132",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "6cc0d72accb62915e6233a42d92a1f8d0da90566a60818597e569b3c562d2ae5",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wulfen-with-Storm-Shields",
		"points": 125, "points_by_models": {5: 125, 10: 250}, "third_plus_points_by_models": {5: 155, 10: 280}, "models": 5, "max_supported_copies": 3,
		"base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4,
		"stats": {"movement_inches": 9, "toughness": 6, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 4},
		"keywords": ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WULFEN"],
		"default_loadout_by_role": {"Wulfen with Storm Shield": {"Stormfrag Auto-launcher": 1, "Thunder Hammer": 1}},
		"options": {"loadouts": ["stormfrag-auto-launcher", "death-totem"]},
		"ranged": [
			{"id": "stormfrag-auto-launcher", "profiles": {"standard": _weapon("Stormfrag Auto-launcher", 12.0, 2, 4, 4, -1, 1, {"assault": true, "blast": 1})}}
		],
		"melee": [
			{"id": "thunder-hammer", "physical_weapon_id": "thunder-hammer", "profiles": {
				"standard": _weapon("Thunder Hammer", 0.0, 2, 3, 8, -2, 3, {"devastating-wounds": true}),
				"hunter": _weapon("Thunder Hammer - Hunter", 0.0, 3, 3, 10, -3, 3, {"devastating-wounds": true})
			}}
		],
		"special_rules": ["Combat Doctrines", "Curse of the Wulfen", "Hammer Blow", "Death Totem", "Bestial Forms"]
	},
	"wolf-scouts": {
		"name": "Wolf Scouts", "source_book_id": "000000036", "source_datasheet_id": "000004182",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "af19b879ba7ecfd116ac06d5cd9aeaae2231a385a7bbca195fe34f5058cdb88d",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Scouts-1",
		"points": 95, "points_by_models": {6: 95, 12: 190}, "third_plus_points_by_models": {6: 105, 12: 200}, "models": 6, "max_supported_copies": 3,
		"base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"model_base_sizes_source_mm": {"Wolf Scout Pack Leader": 32, "Hunting Wolf": "60 x 35.5", "Wolf Scout": 32},
		"stats": {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "INFANTRY", "IMPERIUM", "PHOBOS", "SMOKE", "EXPLOSIVES"],
		"default_loadout_by_role": {"Wolf Scout Pack Leader": {"Plasma Pistol": 1, "Power Weapon": 1}, "Hunting Wolf": {"Teeth and Claws": 1}, "Wolf Scout": {"Combat Knife": 1, "Plasma Pistol": 1}},
		"options": {"wolf_scout_loadouts": ["default", "bolt-pistol", "runic-stave", "thunderclap", "instigator-bolt-carbine", "plasma-gun"], "special_replacements_per_unit": 1, "instigator_carbine_per_12_models": 1, "plasma_gun_per_unit": 1, "haywire_mines_per_unit": 1},
		"ranged": [{"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}],
		"melee": [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 4, 3, 4, -1, 1, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
				{"id": "instigator-bolt-carbine", "profiles": {"standard": _weapon("Instigator Bolt Carbine", 24.0, 2, 3, 5, -2, 2, {"precision": true, "lethal-hits": true})}},
				{"id": "plasma-gun", "profiles": {"standard": _weapon("Plasma Gun - Standard", 24.0, 1, 3, 7, -2, 1, {"rapid-fire": 1}), "supercharge": _weapon("Plasma Gun - Supercharge", 24.0, 1, 3, 8, -3, 2, {"hazardous": true, "rapid-fire": 1})}},
				{"id": "thunderclap", "profiles": {"standard": _weapon("Thunderclap", 12.0, 2, 3, 5, -1, 2, {"blast": 1, "psychic": true})}}
			],
			"melee": [
				{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}},
				{"id": "runic-stave", "profiles": {"standard": _weapon("Runic Stave", 0.0, 3, 3, 6, -1, 2, {"psychic": true})}},
				{"id": "teeth-and-claws", "profiles": {"standard": _weapon("Teeth and Claws", 0.0, 2, 4, 4, 0, 1, {})}}
			]
		},
		"special_rules": ["Scouts 8 inches", "Infiltrators", "Combat Doctrines", "Deadly Stalkers", "Hunting Hounds", "Haywire Mine"]
	},
	"wolf-guard-headtakers": {
		"name": "Wolf Guard Headtakers", "source_book_id": "000000036", "source_datasheet_id": "000004131",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z",
		"source_manifest_sha256": "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e",
		"source_slice_manifest_sha256": "e0178a7d1203b781f24987b55980b832a6ff10112d1a5b1a70a21df4df50ebc7",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Headtakers",
		"points": 115, "points_by_models": {6: 115, 12: 230}, "third_plus_points_by_models": {6: 125, 12: 240},
		"points_source": "Munitorum Field Manual Space Wolves v1.0 observed 2026-10-29; composition rows cross-checked against the Wahapedia 11e local export",
		"mfm_composition_cost_rows": [
			{"models": 3, "headtakers": 3, "hunting_wolves": 0, "first_to_second_points": 85, "third_plus_points": 95, "wahapedia_composition_compatible": false},
			{"models": 6, "headtakers": 3, "hunting_wolves": 3, "first_to_second_points": 115, "third_plus_points": 125, "wahapedia_composition_compatible": true},
			{"models": 6, "headtakers": 6, "hunting_wolves": 0, "first_to_second_points": 170, "third_plus_points": 180, "wahapedia_composition_compatible": false},
			{"models": 12, "headtakers": 6, "hunting_wolves": 6, "first_to_second_points": 230, "third_plus_points": 240, "wahapedia_composition_compatible": true}
		],
		"unpriced_source_permitted_role_mix_note": "Wahapedia permits 3-6 models of each role, but the current Munitorum Field Manual lists exact prices only for the 3+3 and 6+6 mixed compositions; other legal role mixes remain unavailable until explicitly priced.",
		"models": 6, "max_supported_copies": 3,
		"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"base_geometry": "per-model-circles", "geometry_scope": "40 mm Headtaker bases are represented exactly; each 60 x 35.5 mm Hunting Wolf oval is represented by a conservative 60 mm circle proxy.",
		"model_base_sizes_source_mm": {"Wolf Guard Headtaker": 40, "Hunting Wolf": "60 x 35.5"},
		"stats": {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "IMPERIUM", "BEASTS", "INFANTRY", "TACTICUS"],
		"model_loadouts": [wolf_guard_headtaker_model_loadout("wolf-guard-headtaker"), wolf_guard_headtaker_model_loadout("hunting-wolf")],
		"composition_options": wolf_guard_headtakers_composition_options(), "default_composition_choice_ids": {6: "six-mixed", 12: "twelve-mixed"},
		"options": {"storm_shield_replaces_paired_master_crafted_power_weapons": true},
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "paired-master-crafted-power-weapons", "profiles": {"standard": _weapon("Paired Master-crafted Power Weapons", 0.0, 6, 3, 5, -2, 2, {})}}],
		"additional_weapon_profiles": {"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 4, 3, 5, -2, 2, {})}}, {"id": "teeth-and-claws", "profiles": {"standard": _weapon("Teeth and Claws", 0.0, 3, 4, 4, 0, 1, {})}}]},
		"special_rules": ["Combat Doctrines", "Headhunters", "Let Loose the Wolves", "Hunting Hounds", "Storm Shield"]
	},
	"tarantula-air-defence-battery": {
		"name": "Tarantula Air Defence Battery", "source_book_id": "000000356", "source_datasheet_id": "000000099",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Tarantula-Air-Defence-Battery", "source_scope": "Warhammer Legends",
		"points": 70, "points_by_models": {1: 70}, "models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; physical model footprint clearance is not certified.",
		"stats": {"movement_inches": 0, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "FRAME", "VEHICLE", "IMPERIUM"],
		"default_loadout_by_role": {"Tarantula Air Defence Battery": {"Armoured Hull": 1, "Tarantula Air Defence Missiles": 1}},
		"ranged": [{"id": "tarantula-air-defence-missiles", "profiles": {"standard": _weapon("Tarantula Air Defence Missiles", 48.0, 3, 4, 7, -1, 1, {"blast": 2, "anti-fly": 2})}}],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 1, 4, 4, 0, 1, {})}}],
		"special_rules": ["Combat Doctrines", "Deadly Demise 1", "Sentry Programming"]
	},
	"tarantula-sentry-battery": {
		"name": "Tarantula Sentry Battery", "source_book_id": "000000356", "source_datasheet_id": "000000098",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Tarantula-Sentry-Battery", "source_scope": "Warhammer Legends",
		"points": 30, "points_by_models": {1: 30, 2: 60, 3: 90}, "models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy for each battery; physical model footprint clearance is not certified.",
		"stats": {"movement_inches": 0, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "ARTILLERY", "FRAME", "IMPERIUM"],
		"default_loadout_by_role": {"Tarantula Sentry Battery": {"Armoured Hull": 1, "Twin Heavy Bolter": 1}},
		"options": {"replace_twin_heavy_bolter": ["twin-lascannon"]},
		"ranged": [{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2})}}],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 1, 6, 3, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})}}]},
		"special_rules": ["Combat Doctrines", "Sentinel Protocols"]
	},
	"rapier-carrier": {
		"name": "Rapier Carrier", "source_book_id": "000000356", "source_datasheet_id": "000000110",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Rapier-Carrier", "source_scope": "Warhammer Legends",
		"points": 90, "points_by_models": {1: 90}, "models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; physical model footprint clearance is not certified.",
		"stats": {"movement_inches": 3, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "IMPERIUM", "ARTILLERY", "FRAME", "VEHICLE"],
		"default_loadout_by_role": {"Rapier Carrier": {"Armoured Hull": 1, "Boltgun": 1, "Quad Heavy Bolter": 1}},
		"options": {"replace_quad_heavy_bolter": ["graviton-cannon", "laser-destroyer", "quad-launcher"]},
		"ranged": [
			{"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}},
			{"id": "quad-heavy-bolter", "profiles": {"standard": _weapon("Quad Heavy Bolter", 36.0, 6, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "twin-linked": true, "heavy": true})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 2, 3, 4, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "graviton-cannon", "profiles": {"standard": _weapon("Graviton Cannon", 36.0, 3, 3, 6, -2, 2, {"blast": 2, "anti-vehicle": 2, "heavy": true})}},
			{"id": "laser-destroyer", "profiles": {"standard": _weapon("Laser Destroyer", 72.0, 2, 3, 14, -3, "D6+3", {"heavy": true})}},
			{"id": "quad-launcher", "profiles": {
				"shatter-shells": _weapon("Quad Launcher - Shatter Shells", 24.0, 4, 3, 9, -2, 3, {"heavy": true}),
				"thunderfire-shells": _weapon("Quad Launcher - Thunderfire Shells", 60.0, "D3+6", 3, 5, 0, 1, {"indirect-fire": true, "heavy": true, "blast": 1})
			}}
		]},
		"special_rules": ["Combat Doctrines", "Powerful Volley"]
	},
	"centurion-devastator-squad": {
		"name": "Centurion Devastator Squad", "source_book_id": "000000356", "source_datasheet_id": "000001193",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Centurion-Devastator-Squad", "source_scope": "Warhammer Legends",
		"points": 175, "points_by_models": {3: 175, 6: 350}, "models": 3, "max_supported_copies": 3,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 4, "toughness": 7, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "INFANTRY", "CENTURION", "IMPERIUM"],
		"default_loadout_by_role": {
			"Devastator Centurion": {"Centurion Bolters": 1, "Centurion Fists": 1, "Grav-cannon": 1},
			"Devastator Centurion Sergeant": {"Centurion Bolters": 1, "Centurion Fists": 1, "Grav-cannon": 1}
		},
		"options": {"replace_centurion_bolters": ["centurion-missile-launcher"], "replace_grav_cannon": ["twin-heavy-bolter", "twin-lascannon"]},
		"ranged": [
			{"id": "centurion-bolters", "profiles": {"standard": _weapon("Centurion Bolters", 24.0, 3, 3, 5, -1, 1, {"rapid-fire": 3, "twin-linked": true})}},
			{"id": "grav-cannon", "profiles": {"standard": _weapon("Grav-cannon", 24.0, 3, 3, 6, -1, 3, {"anti-vehicle": 2})}}
		],
		"melee": [{"id": "centurion-fists", "profiles": {"standard": _weapon("Centurion Fists", 0.0, 3, 4, 5, -1, 2, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "centurion-missile-launcher", "profiles": {"standard": _weapon("Centurion Missile Launcher", 36.0, 2, 3, 9, -2, 3, {"blast": 1})}},
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "sustained-hits": 1, "rapid-fire": 2})}},
			{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})}}
		]},
		"special_rules": ["Combat Doctrines", "Decimator Protocols"]
	},
	"centurion-assault-squad": {
		"name": "Centurion Assault Squad", "source_book_id": "000000356", "source_datasheet_id": "000002703",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Centurion-Assault-Squad", "source_scope": "Warhammer Legends",
		"points": 150, "points_by_models": {3: 150, 6: 300}, "models": 3, "max_supported_copies": 3,
		"base_size_source_mm": 50, "base_radius_inches": 25.0 / 25.4,
		"stats": {"movement_inches": 4, "toughness": 7, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "INFANTRY", "CENTURION", "IMPERIUM"],
		"default_loadout_by_role": {
			"Assault Centurion Sergeant": {"Centurion Bolters": 1, "Siege Drills": 1, "Twin Flamer": 1},
			"Assault Centurion": {"Centurion Bolters": 1, "Siege Drills": 1, "Twin Flamer": 1}
		},
		"options": {"replace_centurion_bolters": ["centurion-assault-launcher"], "replace_twin_flamer": ["twin-meltagun"]},
		"wargear_abilities": {"centurion-assault-launcher": "The bearer has the EXPLOSIVES keyword."},
		"ranged": [
			{"id": "centurion-bolters", "profiles": {"standard": _weapon("Centurion Bolters", 24.0, 3, 3, 5, -1, 1, {"rapid-fire": 3, "twin-linked": true})}},
			{"id": "twin-flamer", "profiles": {"standard": _weapon("Twin Flamer", 12.0, 3, null, 4, 0, 1, {"blast": 1, "twin-linked": true, "torrent": true})}}
		],
		"melee": [{"id": "siege-drills", "profiles": {"standard": _weapon("Siege Drills", 0.0, 3, 3, 10, -2, 3, {"twin-linked": true})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "twin-meltagun", "profiles": {"standard": _weapon("Twin Meltagun", 12.0, 1, 3, 9, -3, "D3+2", {"melta": 2, "twin-linked": true})}}
		]},
		"special_rules": ["Combat Doctrines", "Annihilator Protocols"]
	},
	"vindicator": {
		"name": "Vindicator", "source_book_id": "000000356", "source_datasheet_id": "000001188",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Vindicator", "source_scope": "Warhammer Legends",
		"points": 185, "points_by_models": {1: 185}, "third_plus_points_by_models": {1: 200}, "models": 1, "max_supported_copies": 3,
		"damaged_threshold": 4,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 9, "toughness": 11, "save_target": 2, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"],
		"default_loadout_by_role": {"Vindicator": {"Armoured Tracks": 1, "Demolisher Cannon": 1}},
		"options": {"add_optional_hunter_killer_missile": true, "add_optional_storm_bolter": true},
		"ranged": [{"id": "demolisher-cannon", "profiles": {
			"standard": _weapon("Demolisher Cannon", 24.0, "D3+3", 3, 14, -3, 4, {"blast": 1}),
			"siege-shield-close-quarters": _weapon("Demolisher Cannon - Siege Shield (Close-quarters, No Blast)", 24.0, "D3+3", 3, 14, -3, 4, {})
		}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Siege Shield"]
	},
	"predator-annihilator": {
		"name": "Predator Annihilator", "source_book_id": "000000356", "source_datasheet_id": "000002714",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Predator-Annihilator", "source_scope": "Warhammer Legends",
		"points": 135, "points_by_models": {1: 135}, "third_plus_points_by_models": {1: 145}, "models": 1, "max_supported_copies": 3,
		"damaged_threshold": 4,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"],
		"default_loadout_by_role": {"Predator Annihilator": {"Armoured Tracks": 1, "Lascannon": 2, "Predator Twin Lascannon": 1}},
		"options": {"replace_two_lascannons_with_two_heavy_bolters": true, "add_optional_hunter_killer_missile": true, "add_optional_storm_bolter": true},
		"ranged": [
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "predator-twin-lascannon", "profiles": {"standard": _weapon("Predator Twin Lascannon", 48.0, 1, 3, 14, -3, "D3+3", {"twin-linked": true})}}
		],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Annihilator"]
	},
	"predator-destructor": {
		"name": "Predator Destructor", "source_book_id": "000000356", "source_datasheet_id": "000002715",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Predator-Destructor", "source_scope": "Warhammer Legends",
		"points": 140, "points_by_models": {1: 140}, "third_plus_points_by_models": {1: 150}, "models": 1, "max_supported_copies": 3,
		"damaged_threshold": 4,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"],
		"default_loadout_by_role": {"Predator Destructor": {"Armoured Tracks": 1, "Lascannon": 2, "Predator Autocannon": 1}},
		"options": {"replace_two_lascannons_with_two_heavy_bolters": true, "add_optional_hunter_killer_missile": true, "add_optional_storm_bolter": true},
		"ranged": [
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "predator-autocannon", "profiles": {"standard": _weapon("Predator Autocannon", 48.0, 4, 3, 9, -1, 3, {"rapid-fire": 2})}}
		],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Destructor"]
	},
	"whirlwind": {
		"name": "Whirlwind", "source_book_id": "000000356", "source_datasheet_id": "000002727",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Whirlwind", "source_scope": "Warhammer Legends",
		"points": 175, "points_by_models": {1: 175}, "second_plus_points_by_models": {1: 195}, "third_plus_points_by_models": {1: 195}, "models": 1, "max_supported_copies": 3,
		"damaged_threshold": 4,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no base diameter. The simulation uses a 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"],
		"default_loadout_by_role": {"Whirlwind": {"Armoured Tracks": 1, "Whirlwind Vengeance Launcher": 1}},
		"options": {"add_optional_hunter_killer_missile": true, "add_optional_storm_bolter": true},
		"ranged": [{"id": "whirlwind-vengeance-launcher", "profiles": {"standard": _weapon("Whirlwind Vengeance Launcher", 72.0, 6, 3, 8, -2, 2, {"indirect-fire": true, "blast": 2})}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Punishing Bombardment"]
	},
	"stormhawk-interceptor": {
		"name": "Stormhawk Interceptor", "source_book_id": "000000356", "source_datasheet_id": "000000084",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Stormhawk-Interceptor", "source_scope": "Warhammer Legends",
		"points": 155, "points_by_models": {1: 155}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": [120, 92], "base_geometry": "oval", "base_radius_inches": 60.0 / 25.4,
		"geometry_scope": "The verified source specifies a 120 x 92 mm oval. The local simulation uses a labelled 60 mm bounding-circle proxy; exact physical base clearance is not certified.",
		"stats": {"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "SMOKE", "RAVENWING", "IMPERIUM", "FLY", "AIRCRAFT"],
		"default_loadout_by_role": {"Stormhawk Interceptor": {"Armoured Hull": 1, "Las-talon": 1, "Skyhammer Missile Launcher": 1, "Twin Assault Cannon": 1}},
		"options": {"las_talon_replacement": "icarus-stormcannon", "skyhammer_missile_launcher_replacements": ["twin-heavy-bolter", "typhoon-missile-launcher"]},
		"ranged": [
			{"id": "las-talon", "profiles": {"standard": _weapon("Las-talon", 36.0, 2, 3, 10, -3, "D3+3", {})}},
			{"id": "skyhammer-missile-launcher", "profiles": {"standard": _weapon("Skyhammer Missile Launcher", 48.0, 3, 3, 8, -1, 2, {"anti-fly": 2})}},
			{"id": "twin-assault-cannon", "profiles": {"standard": _weapon("Twin Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"twin-linked": true, "sustained-hits": 1})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "icarus-stormcannon", "profiles": {"standard": _weapon("Icarus Stormcannon", 48.0, 6, 3, 7, -1, 2, {"anti-fly": 2})}},
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "typhoon-missile-launcher", "profiles": {
				"krak": _weapon("Typhoon Missile Launcher - Krak", 48.0, 2, 3, 10, -2, "D3+3", {}),
				"frag": _weapon("Typhoon Missile Launcher - Frag", 48.0, 6, 3, 4, -1, 1, {"blast": 2})
			}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Interceptor"]
	},
	"stormtalon-gunship": {
		"name": "Stormtalon Gunship", "source_book_id": "000000356", "source_datasheet_id": "000001190",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Stormtalon-Gunship", "source_scope": "Warhammer Legends",
		"points": 165, "points_by_models": {1: 165}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": [120, 92], "base_geometry": "oval", "base_radius_inches": 60.0 / 25.4,
		"geometry_scope": "The verified source specifies a 120 x 92 mm oval. The local simulation uses a labelled 60 mm bounding-circle proxy; exact physical base clearance is not certified.",
		"stats": {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "RAVENWING", "FLY", "VEHICLE", "AIRCRAFT", "IMPERIUM"],
		"default_loadout_by_role": {"Stormtalon Gunship": {"Armoured Hull": 1, "Skyhammer Missile Launcher": 1, "Twin Assault Cannon": 1}},
		"options": {"skyhammer_missile_launcher_replacements": ["twin-heavy-bolter", "twin-lascannon", "typhoon-missile-launcher"]},
		"ranged": [
			{"id": "skyhammer-missile-launcher", "profiles": {"standard": _weapon("Skyhammer Missile Launcher", 48.0, 3, 3, 8, -1, 2, {"twin-linked": true, "anti-fly": 2})}},
			{"id": "twin-assault-cannon", "profiles": {"standard": _weapon("Twin Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"twin-linked": true, "sustained-hits": 1})}}
		],
		"melee": [{"id": "armoured-hull", "profiles": {"standard": _weapon("Armoured Hull", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})}},
			{"id": "typhoon-missile-launcher", "profiles": {
				"frag": _weapon("Typhoon Missile Launcher - Frag", 48.0, 6, 3, 4, -1, 1, {"blast": 2}),
				"krak": _weapon("Typhoon Missile Launcher - Krak", 48.0, 2, 3, 10, -2, "D3+3", {})
			}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Strafing Run"]
	},
	"cerberus": {
		"name": "Cerberus", "source_book_id": "000000356", "source_datasheet_id": "000001153",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Cerberus", "source_scope": "Warhammer Legends",
		"points": 270, "points_by_models": {1: 270}, "models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no footprint diameter. The simulation uses a labelled 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 18, "leadership_target": 6, "objective_control": 6, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "FRAME", "IMPERIUM", "VEHICLE", "SMOKE"],
		"default_loadout_by_role": {"Cerberus": {"Armoured Tracks": 1, "Cerberus Neutron Pulse Array": 1}},
		"options": {"optional_weapon": ["heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"], "optional_pair": ["two-heavy-bolters", "two-lascannons"]},
		"ranged": [{"id": "cerberus-neutron-pulse-array", "profiles": {"standard": _weapon("Cerberus Neutron Pulse Array", 48.0, 3, 3, 16, -3, "D3+6", {"twin-linked": true})}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 6, 4, 8, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D6", "Atomantic Arc-reactor"]
	},
	"dreadnought": {
		"name": "Dreadnought", "source_book_id": "000000356", "source_datasheet_id": "000000117",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00", "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Dreadnought", "source_scope": "Warhammer Legends",
		"points": 135, "points_by_models": {1: 135}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "DEATHWING", "WALKER", "VEHICLE", "SMOKE", "IMPERIUM"],
		"default_loadout_by_role": {"Dreadnought": {"Assault Cannon": 1, "Dreadnought Fist": 1, "Storm Bolter": 1}},
		"options": {"primary": ["heavy-plasma-cannon", "multi-melta", "twin-lascannon"], "melee_package": ["missile-launcher-crushing-feet"], "secondary": ["heavy-flamer"]},
		"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		],
		"melee": [{"id": "dreadnought-fist", "profiles": {"standard": _weapon("Dreadnought Fist", 0.0, 5, 3, 12, -2, 3, {})}}],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
				{"id": "heavy-plasma-cannon", "profiles": {
					"standard": _weapon("Heavy Plasma Cannon - Standard", 36.0, 3, 3, 9, -2, 2, {"blast": 1, "heavy": true}),
					"supercharge": _weapon("Heavy Plasma Cannon - Supercharge", 36.0, 3, 3, 10, -3, 3, {"blast": 1, "hazardous": true, "heavy": true})}},
				{"id": "missile-launcher", "profiles": {
					"frag": _weapon("Missile Launcher - Frag", 48.0, 4, 3, 4, -1, 1, {"blast": 1}),
					"krak": _weapon("Missile Launcher - Krak", 48.0, 1, 3, 10, -2, "D3+3", {})}},
				{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
				{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}},
				{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})}}
			],
			"melee": [{"id": "crushing-feet", "profiles": {"standard": _weapon("Crushing Feet", 0.0, 5, 3, 6, 0, 1, {})}}]
		},
		"special_rules": ["Combat Doctrines", "Deadly Demise 1", "Wisdom of the Ancients"]
	},
	"venerable-dreadnought-legends": {
		"name": "Venerable Dreadnought (Warhammer Legends)", "source_book_id": "000000356", "source_datasheet_id": "000000120",
		"source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT, "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Venerable-Dreadnought", "source_scope": "Warhammer Legends",
		"points": 165, "points_by_models": {1: 165}, "models": 1, "max_supported_copies": 3,
		"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
		"stats": {"movement_inches": 6, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "IMPERIUM", "DEATHWING", "VEHICLE", "WALKER", "DREADNOUGHT", "SMOKE"],
		"default_loadout_by_role": {"Venerable Dreadnought": {"Armoured Feet": 1, "Assault Cannon": 1, "Dreadnought Fist": 1, "Storm Bolter": 1}},
		"options": {"primary": ["dreadnought-inferno-cannon", "heavy-plasma-cannon", "multi-melta", "twin-autocannon", "twin-heavy-bolter", "twin-heavy-flamer", "twin-lascannon"], "fist-and-storm-bolter-package": ["heavy-flamer-and-fist", "missile-launcher", "twin-autocannon"]},
		"ranged": [
			{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		],
		"melee": [
			{"id": "armoured-feet", "profiles": {"standard": _weapon("Armoured Feet", 0.0, 5, 3, 6, 0, 1, {})}},
			{"id": "dreadnought-fist", "profiles": {"standard": _weapon("Dreadnought Fist", 0.0, 5, 3, 12, -2, 3, {})}}
		],
		"additional_weapon_profiles": {"ranged": [
			{"id": "dreadnought-inferno-cannon", "profiles": {"standard": _weapon("Dreadnought Inferno Cannon", 12.0, 7, null, 6, -1, 1, {"blast": 2, "torrent": true})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"torrent": true, "blast": 2})}},
			{"id": "heavy-plasma-cannon", "profiles": {
				"standard": _weapon("Heavy Plasma Cannon - Standard", 36.0, 3, 3, 9, -2, 2, {"blast": 1, "heavy": true}),
				"supercharge": _weapon("Heavy Plasma Cannon - Supercharge", 36.0, 3, 3, 10, -3, 3, {"hazardous": true, "blast": 1, "heavy": true})}},
			{"id": "missile-launcher", "profiles": {
				"frag": _weapon("Missile Launcher - Frag", 48.0, 4, 3, 4, -1, 1, {"blast": 1, "heavy": true}),
				"krak": _weapon("Missile Launcher - Krak", 48.0, 1, 3, 10, -2, "D3+3", {})}},
			{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "twin-autocannon", "profiles": {"standard": _weapon("Twin Autocannon", 48.0, 2, 3, 9, -1, 3, {"twin-linked": true})}},
			{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "twin-linked": true})}},
			{"id": "twin-heavy-flamer", "profiles": {"standard": _weapon("Twin Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "twin-linked": true, "torrent": true})}},
			{"id": "twin-lascannon", "profiles": {"standard": _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise 1", "Wisdom of the Ancients"]
	},
	"typhon": {
		"name": "Typhon", "source_book_id": "000000356", "source_datasheet_id": "000000093",
		"source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT, "source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Typhon", "source_scope": "Warhammer Legends",
		"points": 320, "points_by_models": {1: 320}, "models": 1, "max_supported_copies": 3, "damaged_threshold": 6,
		"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no footprint dimensions. The simulation uses a labelled 60 mm circular footprint proxy; exact physical model clearance is not certified.",
		"stats": {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 18, "leadership_target": 6, "objective_control": 6, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "FRAME", "VEHICLE", "IMPERIUM", "SMOKE"],
		"default_loadout_by_role": {"Typhon": {"Armoured Tracks": 1, "Dreadhammer Siege Cannon": 1}},
		"options": {"sponsons": ["two-heavy-bolters", "two-lascannons"], "hull-weapon": ["heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]},
		"ranged": [{"id": "dreadhammer-siege-cannon", "profiles": {"standard": _weapon("Dreadhammer Siege Cannon", 24.0, "D6+6", 3, 14, -3, "D3+3", {"blast": 1})}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 6, 4, 8, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
			{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"torrent": true, "blast": 2})}},
			{"id": "lascannon", "profiles": {"standard": _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})}},
			{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		]},
		"special_rules": ["Combat Doctrines", "Deadly Demise D6", "Damaged 6", "Sunderer of Fortresses"]
	}
}

static func wolf_guard_headtaker_model_loadout(role: String, storm_shield: bool = false) -> Dictionary:
	if role == "wolf-guard-headtaker":
		var stats := {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4 if storm_shield else 0}
		var ranged := [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}]
		var melee := [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 4, 3, 5, -2, 2, {})}}] if storm_shield else [{"id": "paired-master-crafted-power-weapons", "profiles": {"standard": _weapon("Paired Master-crafted Power Weapons", 0.0, 6, 3, 5, -2, 2, {})}}]
		return {"role": role, "source_model_name": "Wolf Guard Headtaker", "stats": stats, "base_size_source_mm": 40, "base_radius_inches": 20.0 / 25.4, "keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "IMPERIUM", "BEASTS", "INFANTRY", "TACTICUS"], "ranged": ranged, "melee": melee}
	if role == "hunting-wolf":
		var stats := {"movement_inches": 10, "toughness": 4, "save_target": 6, "wounds": 1, "leadership_target": 8, "objective_control": 0, "invulnerable_target": 0}
		var melee := [{"id": "teeth-and-claws", "profiles": {"standard": _weapon("Teeth and Claws", 0.0, 3, 4, 4, 0, 1, {})}}]
		return {"role": role, "source_model_name": "Hunting Wolf", "stats": stats, "base_size_source_mm": "60 x 35.5", "base_radius_inches": 30.0 / 25.4, "keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "IMPERIUM", "BEASTS", "INFANTRY", "TACTICUS"], "ranged": [], "melee": melee}
	return {}

static func wolf_guard_headtakers_composition_options() -> Array[Dictionary]:
	var six_roles: Array[String] = ["wolf-guard-headtaker", "wolf-guard-headtaker", "wolf-guard-headtaker", "hunting-wolf", "hunting-wolf", "hunting-wolf"]
	var twelve_roles := six_roles.duplicate()
	twelve_roles.append_array(six_roles)
	return [
		{"id": "six-mixed", "models": 6, "label": "6 models: 3 Wolf Guard Headtakers + 3 Hunting Wolves", "roles": six_roles},
		{"id": "twelve-mixed", "models": 12, "label": "12 models: 6 Wolf Guard Headtakers + 6 Hunting Wolves", "roles": twelve_roles}
	]

static func desolation_weapons(rocket_kind: String = "superfrag") -> Array[Dictionary]:
	var rocket := _weapon("Superfrag Rocket Launcher", 48.0, 4, 3, 5, -1, 1, {"blast": 1, "heavy": true})
	if rocket_kind == "superkrak": rocket = _weapon("Superkrak Rocket Launcher", 48.0, 1, 3, 10, -2, "D3+3", {"heavy": true})
	if rocket_kind == "vengor": rocket = _weapon("Vengor Launcher", 48.0, 4, 3, 7, -1, 2, {"blast": 1, "indirect-fire": true, "heavy": true})
	return [
		{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		{"id": "castellan-launcher", "profiles": {"standard": _weapon("Castellan Launcher", 24.0, 2, 3, 5, -1, 1, {"heavy": true})}},
		{"id": "rocket-launcher", "profiles": {"standard": rocket}}
	]

static func _all_profiles() -> Dictionary:
	if _profile_catalog_cache.is_empty():
		_profile_catalog_cache = _build_profiles()
		_profile_catalog_cache.merge(_space_wolves_walker_profiles(), true)
		_profile_catalog_cache.merge(transport_profiles(), true)
		_profile_catalog_cache.merge(_legends_transport_profiles(), true)
		_profile_catalog_cache.merge(_legends_razorback_profiles(), true)
		_profile_catalog_cache.merge(_legends_hammerfall_profiles(), true)
		_profile_catalog_cache.merge({"mastodon": _legends_mastodon_profile()}, true)
		_profile_catalog_cache.merge(_legends_scout_profiles(), true)
		_profile_catalog_cache.merge(_legends_falchion_profiles(), true)
		_profile_catalog_cache.merge(_chapter_vehicle_profiles(_profile_catalog_cache), true)
		_apply_current_source_verification(_profile_catalog_cache)
	return _profile_catalog_cache

static func _apply_current_source_verification(profiles: Dictionary) -> void:
	for identity: String in profiles:
		var profile: Dictionary = profiles[identity]
		var book_id := str(profile.get("source_book_id", ""))
		var slice_sha256 := str(VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK.get(book_id, ""))
		if str(profile.get("source_datasheet_id", "")).is_empty() or slice_sha256.is_empty():
			push_error("Cannot bind current Wahapedia verification provenance for Marine profile %s" % identity)
			continue
		profile["source_verified_against_snapshot_id"] = VERIFIED_EXPORT_SNAPSHOT_ID
		profile["source_verified_against_export_updated_at"] = VERIFIED_EXPORT_UPDATED_AT
		profile["source_verified_against_manifest_sha256"] = VERIFIED_EXPORT_MANIFEST_SHA256
		profile["source_verified_against_slice_manifest_sha256"] = slice_sha256

static func _legends_transport_profiles() -> Dictionary:
	return {
		"land-raider-excelsior": {
			"name": "Land Raider Excelsior", "source_book_id": "000000356", "source_datasheet_id": "000000067", "source_role": "Transport",
			"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
			"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Land-Raider-Excelsior", "source_scope": "Warhammer Legends",
			"points": 250, "points_by_models": {1: 250}, "second_plus_points_by_models": {1: 250}, "third_plus_points_by_models": {1: 250},
			"source_cost_sections": {"first": {"1": 250}, "second_plus": {"1": 250}, "third_plus": {"1": 250}},
			"models": 1, "max_supported_copies": 3,
			"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
			"geometry_scope": "The verified source says Use model and gives no footprint diameter. The simulation uses a labelled 60 mm circular footprint proxy; exact physical model clearance is not certified.",
			"damaged_threshold": 5,
			"stats": {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 16, "leadership_target": 6, "objective_control": 5, "invulnerable_target": 5},
			"keywords": ["ADEPTUS ASTARTES", "SMOKE", "IMPERIUM", "TRANSPORT", "FRAME", "VEHICLE"],
			"default_loadout_by_role": {"Land Raider Excelsior": {"Armoured Tracks": 1, "Godhammer Lascannon": 2, "Grav-cannon": 1}},
			"ranged": [
				{"id": "godhammer-lascannon", "profiles": {"standard": _weapon("Godhammer Lascannon", 48.0, 2, 3, 12, -3, "D3+3", {})}},
				{"id": "godhammer-lascannon-2", "profiles": {"standard": _weapon("Godhammer Lascannon", 48.0, 2, 3, 12, -3, "D3+3", {})}},
				{"id": "grav-cannon", "profiles": {"standard": _weapon("Grav-cannon", 24.0, 3, 3, 6, -1, 3, {"anti-vehicle": 2})}}
			],
			"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 6, 4, 8, 0, 1, {})}}],
			"additional_weapon_profiles": {"ranged": [
				{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
				{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}},
				{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}},
				{"id": "combi-weapon", "physical_weapon_id": "combi-weapon", "profiles": {
					"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 3, 9, -3, "D3+2", {"melta": 2}),
					"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, null, 4, 0, 1, {"torrent": true, "blast": 1}),
					"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 3, 7, -2, 2, {})}}
			]},
			"transport": {
				"capacity": 12, "required": ["ADEPTUS ASTARTES", "INFANTRY"],
				"double_space": ["JUMP PACK", "GRAVIS", "TERMINATOR"], "triple_space": ["CENTURION"],
				"options": {"add": ["Multi-melta", "Hunter-killer Missile", "Storm Bolter", "Combi-weapon - Damnatus"]},
				"abilities": [
					{"name": "Damaged", "parameter": "5", "type": "Core", "text": "While a model’s remaining wounds are equal to or less than 5, that model is damaged: while damaged, its attacks have -1 to Hit rolls."},
					{"name": "Deadly Demise", "parameter": "D6", "type": "Core", "text": "Each time a model with this ability is destroyed, after units embarked within it have made their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D6 mortal wounds; roll separately for each unit."},
					{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, select one listed Combat Doctrine. It is active for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase. Assault Doctrine: an Advance move does not prevent the unit declaring a Charge. Devastator Doctrine: ranged attacks gain Assault. Tactical Doctrine: a Fall Back move does not prevent the unit shooting or declaring a Charge. Each doctrine can be selected once per battle; only one doctrine can be active for each unit."},
					{"name": "Rites of Battle", "type": "Datasheet", "text": "Once per battle round, one unit from your army with this ability can use it when it is targeted with a Stratagem. If it does, reduce the cost of that Stratagem by 1 CP."}
				]
			},
			"special_rules": ["Combat Doctrines", "Damaged 5", "Deadly Demise D6", "Rites of Battle"]
		},
		"rhino-primaris": _rhino_primaris_profile()
	}

static func _legends_razorback_profiles() -> Dictionary:
	return {
		"razorback": _legend_razorback_profile("Razorback", "000000129", "Razorback", 95, ["JUMP PACK", "TERMINATOR", "CENTURION", "GRAVIS"], false),
		"relic-razorback": _legend_razorback_profile("Relic Razorback", "000002720", "Relic-Razorback", 105, ["JUMP PACK", "GRAVIS", "CENTURION", "TERMINATOR"], true)
	}

static func _legends_hammerfall_profiles() -> Dictionary:
	return {"hammerfall-bunker": _legend_hammerfall_bunker_profile()}

static func _legend_hammerfall_bunker_profile() -> Dictionary:
	var heavy_bolter_array := _weapon("Hammerfall Heavy Bolter Array", 36.0, 6, 4, 5, -1, 2, {"sustained-hits": 1, "rapid-fire": 2, "twin-linked": true})
	var heavy_flamer_array := _weapon("Hammerfall Heavy Flamer Array", 12.0, 6, null, 5, -1, 1, {"twin-linked": true, "torrent": true, "blast": 2})
	var superfrag := _weapon("Hammerfall Missile Launcher - Superfrag", 48.0, 7, 4, 5, -1, 1, {"blast": 1})
	var superkrak := _weapon("Hammerfall Missile Launcher - Superkrak", 48.0, 2, 4, 10, -2, "D3+3", {})
	var abilities: Array[Dictionary] = [
		{"name": "Deadly Demise", "parameter": "D6", "source_ability_id": "000008339", "type": "Core", "text": "Each time this model is destroyed, after any embarked units make their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D6 mortal wounds; roll separately for each unit."},
		{"name": "Damaged", "parameter": "5", "source_ability_id": "000011125", "type": "Core", "text": "While this model has 5 or fewer wounds remaining, its attacks have -1 to Hit."},
		{"name": "Combat Doctrines", "source_ability_id": "000011158", "type": "Faction", "text": "At the start of your Command phase, select one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase."},
		{"name": "Ceramite Cover", "type": "Datasheet", "text": "When an attack targets a unit that is not fully visible to the attacking model because of this unit, the target has the benefit of cover against that attack."},
		{"name": "Defensive Array (Once per phase, per unit)", "type": "Datasheet", "text": "You can target this unit with the Fire Overwatch stratagem regardless of any other uses of that stratagem this phase. If you do, that use is -1 CP."},
		{"name": "Fortification", "type": "Datasheet", "text": "While an enemy unit is engaged with only FORTIFICATION units, it can be selected as a target of ranged attacks. Those attacks have -1 to Hit (excluding CLOSE-QUARTERS attacks). When that enemy unit is selected to Fall Back and is not Battle-shocked, its Hazard rolls automatically pass."}
	]
	var source_files: Array[Dictionary] = [
		{"name": "Datasheets.csv", "sha256": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469"},
		{"name": "Datasheets_abilities.csv", "sha256": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d"},
		{"name": "Datasheets_keywords.csv", "sha256": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8"},
		{"name": "Datasheets_models.csv", "sha256": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5"},
		{"name": "Datasheets_models_cost.csv", "sha256": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8"},
		{"name": "Datasheets_options.csv", "sha256": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe"},
		{"name": "Datasheets_unit_composition.csv", "sha256": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7"},
		{"name": "Datasheets_wargear.csv", "sha256": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"}
	]
	return {
		"name": "Hammerfall Bunker", "source_book_id": "000000356", "source_datasheet_id": "000000097", "source_role": "Fortifications",
		"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_retrieved_at_utc": "2026-10-30T01:33:48.347556+00:00", "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
		"source_files": source_files, "source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Hammerfall-Bunker", "source_scope": "Warhammer Legends",
		"points": 175, "points_by_models": {1: 175}, "second_plus_points_by_models": {1: 175}, "third_plus_points_by_models": {1: 175},
		"source_cost_sections": {"first": {"1": 175}, "second_plus": {"1": 175}, "third_plus": {"1": 175}},
		"models": 1, "max_supported_copies": 3, "damaged_threshold": 5, "base_size_source": "Use model", "base_radius_inches": 60.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model without hull dimensions. The game uses a labelled 120 mm circular interaction proxy; exact physical footprint, placement and clearance are not certified.",
		"stats": {"movement_inches": 0, "toughness": 12, "save_target": 2, "wounds": 14, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "VEHICLE", "FORTIFICATION", "FRAME", "IMPERIUM"],
		"default_loadout_by_role": {"Hammerfall Bunker": {"Hammerfall Heavy Bolter Array": 1, "Hammerfall Missile Launcher": 1}},
		"ranged": [
			{"id": "hammerfall-heavy-bolter-array", "profiles": {"standard": heavy_bolter_array}},
			{"id": "hammerfall-missile-launcher", "profiles": {"superfrag": superfrag, "superkrak": superkrak}}
		],
		"melee": [], "additional_weapon_profiles": {"ranged": [{"id": "hammerfall-heavy-flamer-array", "profiles": {"standard": heavy_flamer_array}}]},
		"options": {"replacement_groups": {"heavy-weapon-array": {"name": "Hammerfall Heavy Bolter Array", "from_ids": ["hammerfall-heavy-bolter-array"], "choices": {"hammerfall-heavy-flamer-array": {"name": "Hammerfall Heavy Flamer Array", "to_ids": ["hammerfall-heavy-flamer-array"]}}}}},
		"abilities": abilities, "special_rules": ["Combat Doctrines", "Deadly Demise D6", "Damaged 5", "Ceramite Cover", "Defensive Array", "Fortification"]
	}

static func hammerfall_weapons(heavy_flamer_array: bool = false) -> Dictionary:
	var source := profile("hammerfall-bunker")
	if source.is_empty(): return {}
	var ranged: Array = source.get("ranged", []).duplicate(true)
	if heavy_flamer_array:
		ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "hammerfall-heavy-bolter-array")
		for weapon: Dictionary in source.get("additional_weapon_profiles", {}).get("ranged", []):
			if str(weapon.get("id", "")) == "hammerfall-heavy-flamer-array": ranged.append(weapon.duplicate(true))
	return {"ranged": ranged, "melee": []}

static func _legend_razorback_profile(profile_name: String, datasheet_id: String, url_name: String, points: int, forbidden_keywords: Array[String], relic: bool) -> Dictionary:
	var twin_heavy_bolter := _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1})
	var twin_lascannon := _weapon("Twin Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {"twin-linked": true})
	var hunter_killer := _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})
	var storm_bolter := _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})
	var additional_ranged: Array = [
		{"id": "twin-lascannon", "profiles": {"standard": twin_lascannon.duplicate(true)}},
		{"id": "hunter-killer-missile", "profiles": {"standard": hunter_killer.duplicate(true)}},
		{"id": "storm-bolter", "profiles": {"standard": storm_bolter.duplicate(true)}}
	]
	var replacement_choices: Dictionary = {
		"twin-lascannon": {"name": "Twin Lascannon", "to_ids": ["twin-lascannon"]}
	}
	if relic:
		additional_ranged.append({"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}})
		additional_ranged.append({"id": "twin-assault-cannon", "profiles": {"standard": _weapon("Twin Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"twin-linked": true, "sustained-hits": 1})}})
		replacement_choices["multi-melta"] = {"name": "Multi-melta", "to_ids": ["multi-melta"]}
		replacement_choices["twin-assault-cannon"] = {"name": "Twin Assault Cannon", "to_ids": ["twin-assault-cannon"]}
	var abilities: Array[Dictionary] = [
		{"name": "Deadly Demise", "parameter": "D3", "type": "Core", "text": "Each time this model is destroyed, after any embarked units make their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D3 mortal wounds; roll separately for each unit."},
		{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, select one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase."},
		{"name": "Fire Support", "type": "Datasheet", "text": "In your Shooting phase, when this unit has shot, select one enemy unit hit by those attacks. Attacks that target that unit made by friendly ADEPTUS ASTARTES units that Disembarked from this TRANSPORT this turn can re-roll Wound rolls."}
	]
	if relic:
		abilities[2].source_name = "Fire Supprt"
		abilities[2].source_name_note = "The verified export spells the ability name Fire Supprt; its description matches Fire Support and is normalized for runtime lookup."
	var source_files: Array[Dictionary] = [
		{"name": "Datasheets.csv", "sha256": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469"},
		{"name": "Datasheets_abilities.csv", "sha256": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d"},
		{"name": "Datasheets_keywords.csv", "sha256": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8"},
		{"name": "Datasheets_models.csv", "sha256": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5"},
		{"name": "Datasheets_models_cost.csv", "sha256": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8"},
		{"name": "Datasheets_options.csv", "sha256": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe"},
		{"name": "Datasheets_unit_composition.csv", "sha256": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7"},
		{"name": "Datasheets_wargear.csv", "sha256": "13e3e6d1e0c4114e41d1cc9c80fe94e8d0e37b628b9af5625d88aeba0c7cbe9d"}
	]
	return {
		"name": profile_name, "source_book_id": "000000356", "source_datasheet_id": datasheet_id, "source_role": "Dedicated Transports",
		"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_retrieved_at_utc": "2026-10-30T01:33:48.347556+00:00", "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
		"source_files": source_files, "source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/%s" % url_name, "source_scope": "Warhammer Legends",
		"points": points, "points_by_models": {1: points}, "second_plus_points_by_models": {1: points}, "third_plus_points_by_models": {1: points},
		"source_cost_sections": {"first": {"1": points}, "second_plus": {"1": points}, "third_plus": {"1": points}},
		"models": 1, "max_supported_copies": 6,
		"base_size_source": "Use model", "base_radius_inches": 60.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and does not define a hull footprint. The game uses a labelled 120 mm circular interaction proxy; exact physical placement, overlap and clearance are not certified.",
		"stats": {"movement_inches": 12, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "SMOKE", "FRAME", "VEHICLE", "DEDICATED TRANSPORT", "TRANSPORT", "IMPERIUM"],
		"default_loadout_by_role": {profile_name: {"Armoured Tracks": 1, "Twin Heavy Bolter": 1}},
		"ranged": [{"id": "twin-heavy-bolter", "profiles": {"standard": twin_heavy_bolter.duplicate(true)}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": additional_ranged},
		"transport": {
			"capacity": 6, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": forbidden_keywords.duplicate(),
			"options": {"add": ["Hunter-killer Missile", "Storm Bolter"], "replacement_groups": {
				"primary-weapon": {"name": "Twin Heavy Bolter", "from_ids": ["twin-heavy-bolter"], "choices": replacement_choices}}},
			"abilities": abilities.duplicate(true)
		},
		"abilities": abilities.duplicate(true),
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Fire Support"]
	}

static func _legends_mastodon_profile() -> Dictionary:
	var heavy_bolter := _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})
	var heavy_flamer := _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})
	var lascannon := _weapon("Lascannon", 48.0, 1, 3, 12, -3, "D3+3", {})
	var volkite_culverin := _weapon("Volkite Culverin", 36.0, 4, 3, 6, 0, 2, {"devastating-wounds": true})
	var optional_profiles: Array = [
		{"id": "mastodon-hb-for-flamers-left", "profiles": {"standard": heavy_bolter.duplicate(true)}},
		{"id": "mastodon-hb-for-flamers-right", "profiles": {"standard": heavy_bolter.duplicate(true)}},
		{"id": "mastodon-las-for-flamers-left", "profiles": {"standard": lascannon.duplicate(true)}},
		{"id": "mastodon-las-for-flamers-right", "profiles": {"standard": lascannon.duplicate(true)}},
		{"id": "mastodon-volkite-for-flamers-left", "profiles": {"standard": volkite_culverin.duplicate(true)}},
		{"id": "mastodon-volkite-for-flamers-right", "profiles": {"standard": volkite_culverin.duplicate(true)}},
		{"id": "mastodon-hb-for-lascannons-left", "profiles": {"standard": heavy_bolter.duplicate(true)}},
		{"id": "mastodon-hb-for-lascannons-right", "profiles": {"standard": heavy_bolter.duplicate(true)}},
		{"id": "mastodon-flamer-for-lascannons-left", "profiles": {"standard": heavy_flamer.duplicate(true)}},
		{"id": "mastodon-flamer-for-lascannons-right", "profiles": {"standard": heavy_flamer.duplicate(true)}},
		{"id": "mastodon-volkite-for-lascannons-left", "profiles": {"standard": volkite_culverin.duplicate(true)}},
		{"id": "mastodon-volkite-for-lascannons-right", "profiles": {"standard": volkite_culverin.duplicate(true)}}
	]
	var source_files: Array[Dictionary] = [
		{"name": "Datasheets.csv", "sha256": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469"},
		{"name": "Datasheets_abilities.csv", "sha256": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d"},
		{"name": "Datasheets_keywords.csv", "sha256": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8"},
		{"name": "Datasheets_models.csv", "sha256": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5"},
		{"name": "Datasheets_models_cost.csv", "sha256": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8"},
		{"name": "Datasheets_options.csv", "sha256": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe"},
		{"name": "Datasheets_unit_composition.csv", "sha256": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7"},
		{"name": "Datasheets_wargear.csv", "sha256": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"}
	]
	return {
		"name": "Mastodon", "source_book_id": "000000356", "source_datasheet_id": "000001189", "source_role": "Transport",
		"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_retrieved_at_utc": "2026-10-30T01:33:48.347556+00:00", "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
		"source_files": source_files, "source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Mastodon", "source_scope": "Warhammer Legends",
		"points": 540, "points_by_models": {1: 540}, "second_plus_points_by_models": {1: 540}, "third_plus_points_by_models": {1: 540},
		"source_cost_sections": {"first": {"1": 540}, "second_plus": {"1": 540}, "third_plus": {"1": 540}},
		"models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 60.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and supplies no hull dimensions. The match uses a labelled 60 mm circle proxy for interaction testing only; exact Mastodon placement, overlap and clearance are not certified.",
		"damaged_threshold": 10,
		"stats": {"movement_inches": 9, "toughness": 14, "save_target": 2, "wounds": 30, "leadership_target": 6, "objective_control": 12, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "TITANIC", "SMOKE", "IMPERIUM", "VEHICLE", "FRAME", "TRANSPORT"],
		"default_loadout_by_role": {"Mastodon": {"Armoured Tracks": 1, "Heavy Flamer": 2, "Lascannon": 2, "Siege Melta Array": 1, "Skyreaper Battery": 1}},
		"ranged": [
			{"id": "mastodon-heavy-flamer-left", "profiles": {"standard": heavy_flamer.duplicate(true)}},
			{"id": "mastodon-heavy-flamer-right", "profiles": {"standard": heavy_flamer.duplicate(true)}},
			{"id": "mastodon-lascannon-left", "profiles": {"standard": lascannon.duplicate(true)}},
			{"id": "mastodon-lascannon-right", "profiles": {"standard": lascannon.duplicate(true)}},
			{"id": "siege-melta-array", "profiles": {"standard": _weapon("Siege Melta Array", 24.0, 6, 3, 10, -3, "D3+2", {"melta": 3})}},
			{"id": "skyreaper-battery", "profiles": {"standard": _weapon("Skyreaper Battery", 48.0, 8, 3, 7, -1, 2, {"anti-fly": 4})}}
		],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 6, 4, 8, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": optional_profiles},
		"transport": {
			"capacity": 45, "required": ["ADEPTUS ASTARTES"], "required_any": ["INFANTRY"], "required_any_groups": ["DREADNOUGHT"],
			"double_space": ["JUMP PACK", "GRAVIS", "TERMINATOR"], "triple_space": ["CENTURION"],
			"identity_groups": {"DREADNOUGHT": {
				"display_name": "Dreadnought", "identities": ["dreadnought", "venerable-dreadnought", "venerable-dreadnought-legends", "ballistus-dreadnought", "redemptor-dreadnought", "brutalis-dreadnought", "death-company-dreadnought", "wulfen-dreadnought"],
				"capacity_by_wounds": true}}, "max_models_by_identity_group": {"DREADNOUGHT": 2},
			"options": {"replacement_groups": {
				"heavy-flamers": {"name": "2 Heavy Flamers", "from_ids": ["mastodon-heavy-flamer-left", "mastodon-heavy-flamer-right"], "choices": {
					"heavy-bolters": {"name": "2 Heavy Bolters", "to_ids": ["mastodon-hb-for-flamers-left", "mastodon-hb-for-flamers-right"]},
					"lascannons": {"name": "2 Lascannons", "to_ids": ["mastodon-las-for-flamers-left", "mastodon-las-for-flamers-right"]},
					"volkite-culverins": {"name": "2 Volkite Culverins", "to_ids": ["mastodon-volkite-for-flamers-left", "mastodon-volkite-for-flamers-right"]}}},
				"lascannons": {"name": "2 Lascannons", "from_ids": ["mastodon-lascannon-left", "mastodon-lascannon-right"], "choices": {
					"heavy-bolters": {"name": "2 Heavy Bolters", "to_ids": ["mastodon-hb-for-lascannons-left", "mastodon-hb-for-lascannons-right"]},
					"heavy-flamers": {"name": "2 Heavy Flamers", "to_ids": ["mastodon-flamer-for-lascannons-left", "mastodon-flamer-for-lascannons-right"]},
					"volkite-culverins": {"name": "2 Volkite Culverins", "to_ids": ["mastodon-volkite-for-lascannons-left", "mastodon-volkite-for-lascannons-right"]}}}}},
			"abilities": [
				{"name": "Damaged", "parameter": "10", "type": "Core", "text": "While a model’s remaining wounds are equal to or less than 10, that model is damaged: while damaged, its attacks have -1 to Hit rolls."},
				{"name": "Deadly Demise", "parameter": "2D6", "type": "Core", "text": "Each time this model is destroyed, after any embarked units make their Emergency Disembark moves, roll 2D6. On a 6, each unit within 6 inches suffers D6 mortal wounds; roll separately for each unit."},
				{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, select one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase."},
				{"name": "Inviolable Transport", "type": "Datasheet", "text": "Attacks allocated to this unit have -1 Damage."}
			]
		},
		"special_rules": ["Combat Doctrines", "Damaged 10", "Deadly Demise 2D6", "Inviolable Transport"]
	}

static func _rhino_primaris_profile() -> Dictionary:
	var source: Dictionary = transport_profiles().get("rhino", {}).duplicate(true)
	if source.is_empty():
		push_error("The verified common Rhino transport template is unavailable for Rhino Primaris.")
		return {}
	source.merge({
		"name": "Rhino Primaris", "source_book_id": "000000356", "source_datasheet_id": "000000085", "source_role": "Transport",
		"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_retrieved_at_utc": "2026-10-30T01:33:48.347556+00:00", "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Rhino-Primaris", "source_scope": "Warhammer Legends",
		"source_files": [
			{"name": "Datasheets.csv", "sha256": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469"},
			{"name": "Datasheets_abilities.csv", "sha256": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d"},
			{"name": "Datasheets_keywords.csv", "sha256": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8"},
			{"name": "Datasheets_models.csv", "sha256": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5"},
			{"name": "Datasheets_models_cost.csv", "sha256": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8"},
			{"name": "Datasheets_options.csv", "sha256": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe"},
			{"name": "Datasheets_unit_composition.csv", "sha256": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7"},
			{"name": "Datasheets_wargear.csv", "sha256": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"}
		],
		"points": 95, "points_by_models": {1: 95}, "second_plus_points_by_models": {1: 95}, "third_plus_points_by_models": {1: 95},
		"source_cost_sections": {"first": {"1": 95}, "second_plus": {"1": 95}, "third_plus": {"1": 95}},
		"models": 1, "max_supported_copies": 3,
		"base_size_source": "Use model", "base_radius_inches": 60.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
		"geometry_scope": "The verified source says Use model and gives no footprint diameter. The simulation uses a labelled 120 mm circular footprint proxy; exact physical hull clearance is not certified.",
		"stats": {"movement_inches": 12, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"keywords": ["ADEPTUS ASTARTES", "TRANSPORT", "IMPERIUM", "SMOKE", "VEHICLE", "FRAME"],
		"default_loadout_by_role": {"Rhino Primaris": {"Armoured Tracks": 1, "Twin Plasma Gun": 1}},
		"ranged": [{"id": "twin-plasma-gun", "profiles": {
			"standard": _weapon("Twin Plasma Gun - Standard", 24.0, 1, 3, 7, -2, 1, {"rapid-fire": 1, "twin-linked": true}),
			"supercharge": _weapon("Twin Plasma Gun - Supercharge", 24.0, 1, 3, 8, -3, 2, {"rapid-fire": 1, "hazardous": true, "twin-linked": true})
		}}],
		"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 3, 4, 6, 0, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "hunter-killer-missile", "profiles": {"standard": _weapon("Hunter-killer Missile", 48.0, 1, 2, 14, -3, "D3+3", {"one-shot": true})}}
		]},
		"transport": {
			"capacity": 6, "required": ["ADEPTUS ASTARTES", "INFANTRY"],
			"forbidden": ["JUMP PACK", "GRAVIS", "CENTURION", "TERMINATOR"], "double_space": [],
			"options": {"add": ["Hunter-killer Missile"]},
			"abilities": [{"name": "Deadly Demise", "parameter": "D3", "type": "Core", "text": "Each time this model is destroyed, after any embarked units make their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D3 mortal wounds; roll separately for each unit."}]
		},
		"abilities": [
			{"name": "Deadly Demise", "parameter": "D3", "type": "Core", "text": "Each time this model is destroyed, after any embarked units make their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D3 mortal wounds; roll separately for each unit."},
			{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, select one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase. Assault Doctrine permits charging after Advancing; Devastator Doctrine grants Assault to ranged weapons; Tactical Doctrine permits shooting and charging after Falling Back. Each doctrine can be selected once per battle and only one doctrine can be active per unit."},
			{"name": "Self-repair", "type": "Datasheet", "text": "In your Command phase, this unit heals 1 wound."},
			{"name": "Orbital Comms Array", "type": "Datasheet", "text": "While a friendly ADEPTUS ASTARTES unit is within 6 inches of this unit, each time you target that unit with a stratagem roll 1D6; on a 5+, you gain 1 CP."}
		],
		"special_rules": ["Combat Doctrines", "Deadly Demise D3", "Self-repair", "Orbital Comms Array"]
	}, true)
	source.erase("base_size_source_mm")
	source.erase("fourth_plus_points_by_models")
	return source

static func _legends_scout_profiles() -> Dictionary:
	return {"scout-bike-squad": {
		"name": "Scout Bike Squad", "source_book_id": "000000356", "source_datasheet_id": "000000137", "source_role": "Mounted",
		"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_retrieved_at_utc": "2026-10-30T01:33:48.347556+00:00", "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
		"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Scout-Bike-Squad", "source_scope": "Warhammer Legends",
		"source_files": [
			{"name": "Datasheets.csv", "sha256": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469"},
			{"name": "Datasheets_abilities.csv", "sha256": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d"},
			{"name": "Datasheets_keywords.csv", "sha256": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8"},
			{"name": "Datasheets_models.csv", "sha256": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5"},
			{"name": "Datasheets_models_cost.csv", "sha256": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8"},
			{"name": "Datasheets_options.csv", "sha256": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe"},
			{"name": "Datasheets_unit_composition.csv", "sha256": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7"},
			{"name": "Datasheets_wargear.csv", "sha256": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"}
		],
		"points": 75, "points_by_models": {3: 75, 6: 150}, "second_plus_points_by_models": {3: 75, 6: 150}, "third_plus_points_by_models": {3: 75, 6: 150},
		"source_cost_sections": {"first": {3: 75, 6: 150}, "second_plus": {3: 75, 6: 150}, "third_plus": {3: 75, 6: 150}},
		"models": 3, "max_supported_copies": 3,
		"source_unit_composition": {3: {"Scout Biker Sergeant": 1, "Scout Biker": 2}, 6: {"Scout Biker Sergeant": 1, "Scout Biker": 5}},
		"base_size_source_mm": [75, 25], "base_geometry": "oval", "base_radius_inches": 37.5 / 25.4,
		"geometry_scope": "The source specifies a 75 x 25 mm oval. The simulation uses a labelled 75 mm bounding-circle proxy, so exact oval clearance is not certified.",
		"stats": {"movement_inches": 12, "toughness": 5, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"model_role_stats": {"Scout Biker Sergeant": {"M": "12\"", "T": 5, "Sv": "4+", "W": 3, "Ld": "6+", "OC": 2}, "Scout Biker": {"M": "12\"", "T": 5, "Sv": "4+", "W": 3, "Ld": "6+", "OC": 2}},
		"keywords": ["ADEPTUS ASTARTES", "MOUNTED", "IMPERIUM", "EXPLOSIVES", "SMOKE", "RAVENWING"],
		"default_loadout_by_role": {
			"Scout Biker Sergeant": {"Bolt Pistol": 1, "Combat Knife": 1, "Shotgun": 1, "Twin Boltgun": 1},
			"Scout Biker": {"Bolt Pistol": 1, "Combat Knife": 1, "Shotgun": 1, "Twin Boltgun": 1}},
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
			{"id": "shotgun", "profiles": {"standard": _weapon("Shotgun", 18.0, 2, 3, 4, -1, 1, {"assault": true, "blast": 1})}},
			{"id": "twin-boltgun", "profiles": {"standard": _weapon("Twin Boltgun", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 1, "twin-linked": true})}}
		],
		"melee": [{"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 3, 3, 4, -1, 1, {})}}],
		"additional_weapon_profiles": {"ranged": [
			{"id": "boltgun", "profiles": {"standard": _weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})}},
			{"id": "combi-weapon", "physical_weapon_id": "combi-weapon", "profiles": {
				"damnatus": _weapon("Combi-weapon - Damnatus", 12.0, 1, 3, 9, -3, "D3+2", {"melta": 2}),
				"infernus": _weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"torrent": true, "blast": 1}),
				"purgatus": _weapon("Combi-weapon - Purgatus", 24.0, 2, 3, 7, -2, 2, {})}},
			{"id": "grav-pistol", "profiles": {"standard": _weapon("Grav-pistol", 12.0, 2, 3, 2, -1, 3, {"anti-vehicle": 2, "close-quarters": true})}},
			{"id": "grenade-launcher", "profiles": {
				"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 4, 4, -1, 1, {"blast": 1}),
				"krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 4, 10, -2, 3, {"rapid-fire": 1})}},
			{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
			{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 3, 8, -3, "D3+2", {"melta": 2, "close-quarters": true})}},
			{"id": "plasma-pistol", "profiles": {
				"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
				"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"hazardous": true, "close-quarters": true})}},
			{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
		], "melee": [
			{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 4, -1, 1, {})}},
			{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 2, 3, 8, -2, 2, {})}},
			{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 4, -2, 1, {})}},
			{"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
		]},
		"datasheet_options": [
			"Any number of models can each have their Twin Boltgun replaced with 1 Grenade Launcher.",
			"The Scout Biker Sergeant can have their Bolt Pistol replaced with one of the following: 1 Boltgun, 1 Chainsword, 1 Combi-weapon, 1 Grav-pistol, 1 Hand Flamer, 1 Inferno Pistol, 1 Plasma Pistol, 1 Power Fist, 1 Power Weapon, 1 Storm Bolter, 1 Thunder Hammer."
		],
		"abilities": [
			{"name": "Scouts", "parameter": "9\"", "type": "Core", "text": "The source lists Scouts with a 9-inch parameter. The Core rule determines whether the unit makes a Scout move or is set up in Strategic Reserves."},
			{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, select one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until the start of your next Command phase. Assault Doctrine permits charging after Advancing; Devastator Doctrine grants Assault to ranged weapons; Tactical Doctrine permits shooting and charging after Falling Back. Each doctrine can be selected once per battle and only one doctrine can be active per unit."},
			{"name": "Outflank", "type": "Datasheet", "text": "When this unit makes an ingress move, it can be set up within your opponent’s deployment zone."}
		],
		"special_rules": ["Scouts 9", "Combat Doctrines", "Outflank"]
	}}

static func _legends_falchion_profiles() -> Dictionary:
	return {
		"falchion": {
			"name": "Falchion", "source_book_id": "000000356", "source_datasheet_id": "000001666", "source_role": "Titanic",
			"source_snapshot_id": VERIFIED_EXPORT_SNAPSHOT_ID, "source_export_updated_at": VERIFIED_EXPORT_UPDATED_AT,
			"source_manifest_sha256": VERIFIED_EXPORT_MANIFEST_SHA256, "source_slice_manifest_sha256": VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"],
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Falchion", "source_scope": "Warhammer Legends",
			"points": 420, "points_by_models": {1: 420}, "second_plus_points_by_models": {1: 420}, "third_plus_points_by_models": {1: 420},
			"source_cost_sections": {"first": {"1": 420}, "second_plus": {"1": 420}, "third_plus": {"1": 420}},
			"models": 1, "max_supported_copies": 3, "damaged_threshold": 8,
			"base_size_source": "Use model", "base_radius_inches": 30.0 / 25.4, "base_geometry": "circular-model-footprint-proxy",
			"geometry_scope": "The verified source says Use model and gives no footprint diameter. The simulation uses a labelled 60 mm circular footprint proxy; exact physical model clearance is not certified.",
			"stats": {"movement_inches": 9, "toughness": 13, "save_target": 2, "wounds": 24, "leadership_target": 6, "objective_control": 8, "invulnerable_target": 0},
			"keywords": ["ADEPTUS ASTARTES", "FRAME", "SMOKE", "IMPERIUM", "TITANIC", "VEHICLE"],
			"default_loadout_by_role": {"Falchion": {"Armoured Tracks": 1, "Quad Lascannon": 2, "Twin Falchion Volcano Cannon": 1, "Twin Heavy Bolter": 1}},
			"options": {"optional-weapon": ["heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"], "main-armament": ["quad-lascannons", "laser-destroyers"], "twin-heavy-bolter-replacement": ["twin-heavy-bolter", "twin-heavy-flamer"]},
			"ranged": [
				{"id": "quad-lascannon", "profiles": {"standard": _weapon("Quad Lascannon", 48.0, 4, 3, 12, -3, "D3+3", {})}},
				{"id": "quad-lascannon-2", "profiles": {"standard": _weapon("Quad Lascannon", 48.0, 4, 3, 12, -3, "D3+3", {})}},
				{"id": "twin-falchion-volcano-cannon", "profiles": {"standard": _weapon("Twin Falchion Volcano Cannon", 120.0, "D3+1", 3, 24, -4, 12, {"blast": 1, "twin-linked": true})}},
				{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "twin-linked": true, "sustained-hits": 1})}}
			],
			"melee": [{"id": "armoured-tracks", "profiles": {"standard": _weapon("Armoured Tracks", 0.0, 6, 4, 8, 0, 1, {})}}],
			"additional_weapon_profiles": {"ranged": [
				{"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "sustained-hits": 1})}},
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"torrent": true, "blast": 2})}},
				{"id": "laser-destroyer", "profiles": {"standard": _weapon("Laser Destroyer", 72.0, 2, 3, 14, -3, "D6+3", {"heavy": true})}},
				{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
				{"id": "quad-lascannon", "profiles": {"standard": _weapon("Quad Lascannon", 48.0, 4, 3, 12, -3, "D3+3", {})}},
				{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}},
				{"id": "twin-heavy-bolter", "profiles": {"standard": _weapon("Twin Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "twin-linked": true, "sustained-hits": 1})}},
				{"id": "twin-heavy-flamer", "profiles": {"standard": _weapon("Twin Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "twin-linked": true, "torrent": true})}}
			]},
			"abilities": [
				{"name": "Deadly Demise", "parameter": "D6+2", "type": "Core", "text": "Each time a model with this ability is destroyed, after any embarked units make their Emergency Disembark moves, roll one D6. On a 6, each unit within 6 inches suffers D6+2 mortal wounds; roll separately for each unit."},
				{"name": "Damaged", "parameter": "8", "type": "Core", "text": "While a model has 8 or fewer wounds remaining, it is damaged and its attacks have -1 to Hit rolls."},
				{"name": "Combat Doctrines", "type": "Faction", "text": "At the start of your Command phase, choose one Combat Doctrine for friendly ADEPTUS ASTARTES units with this ability until your next Command phase. Assault Doctrine permits charging after Advancing; Devastator Doctrine grants Assault to ranged weapons; Tactical Doctrine permits shooting and charging after Falling Back. Each doctrine can be selected once per battle and only one can be active per unit."},
				{"name": "Titan-killer", "type": "Datasheet", "text": "The Twin Falchion Volcano Cannon ranged attacks made by this unit against a MONSTER or VEHICLE unit have Devastating Wounds."}
			],
			"special_rules": ["Combat Doctrines", "Deadly Demise D6+2", "Damaged 8", "Titan-killer"]
		}
	}

static func _space_wolves_walker_profiles() -> Dictionary:
	var metadata := {
		"source_book_id": "000000036",
		"source_export_updated_at": "2026-10-28T23:48:19+03:00",
		"source_snapshot_id": "20261029T003124Z",
		"source_manifest_sha256": "457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d",
		"source_slice_manifest_sha256": "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764",
	}
	var profiles := {
		"bjorn-the-fell-handed": {
			"name": "Bjorn the Fell-handed", "source_datasheet_id": "000000302", "source_role": "Vehicle Epic Hero",
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Bjorn-The-Fell-handed",
			"points": 160, "points_by_models": {1: 160}, "models": 1, "max_supported_copies": 1,
			"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
			"stats": {"movement_inches": 9, "toughness": 10, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
			"keywords": ["SPACE WOLVES", "ADEPTUS ASTARTES", "VEHICLE", "SMOKE", "IMPERIUM", "DREADNOUGHT", "EPIC HERO", "CHARACTER", "WALKER"],
			"default_loadout_by_role": {"Bjorn the Fell-handed": {"Assault Cannon": 1, "Heavy Flamer": 1, "Trueclaw": 1}},
			"walker_loadout_options": {"ranged-primary": ["assault-cannon", "helfrost-cannon", "multi-melta"]},
			"ranged": [
				{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 2, 6, -2, 1, {"sustained-hits": 1})}},
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"torrent": true, "blast": 2})}},
			],
			"melee": [{"id": "trueclaw", "profiles": {"standard": _weapon("Trueclaw", 0.0, 6, 2, 12, -2, 3, {"lethal-hits": true})}}],
			"additional_weapon_profiles": {"ranged": [
				{"id": "helfrost-cannon", "profiles": {
					"dispersed": _weapon("Helfrost Cannon - Dispersed", 12.0, 3, null, 6, -1, 2, {"torrent": true}),
					"focused": _weapon("Helfrost Cannon - Focused", 36.0, 1, 2, 10, -3, 5, {})}},
				{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 2, 10, -3, "D3+2", {"melta": 3})}},
			]},
		},
		"murderfang": {
			"name": "Murderfang", "source_datasheet_id": "000000314", "source_role": "Vehicle Epic Hero",
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Murderfang",
			"points": 150, "points_by_models": {1: 150}, "models": 1, "max_supported_copies": 1,
			"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
			"stats": {"movement_inches": 9, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
			"keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "DREADNOUGHT", "CHARACTER", "EPIC HERO", "WULFEN", "VEHICLE", "IMPERIUM", "WALKER"],
			"default_loadout_by_role": {"Murderfang": {"Heavy Flamer": 1, "Murderclaws": 1, "Storm Bolter": 1}},
			"ranged": [
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
				{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}},
			],
			"melee": [{"id": "murderclaws", "profiles": {"standard": _weapon("Murderclaws", 0.0, 8, 3, 14, -2, 3, {"twin-linked": true, "sustained-hits": 1})}}],
		},
		"venerable-dreadnought": {
			"name": "Venerable Dreadnought", "source_datasheet_id": "000002801", "source_role": "Walker",
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Venerable-Dreadnought-1",
			"points": 130, "points_by_models": {1: 130}, "third_plus_points_by_models": {1: 140}, "models": 1, "max_supported_copies": 3,
			"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
			"stats": {"movement_inches": 8, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
			"keywords": ["SPACE WOLVES", "ADEPTUS ASTARTES", "SMOKE", "IMPERIUM", "DREADNOUGHT", "WALKER", "VEHICLE"],
			"default_loadout_by_role": {"Venerable Dreadnought": {"Assault Cannon": 1, "Dreadnought Combat Weapon": 1, "Storm Bolter": 1}},
			"walker_loadout_options": {"ranged-primary": ["assault-cannon", "helfrost-cannon", "multi-melta"], "ranged-secondary": ["storm-bolter", "heavy-flamer"], "melee-package": ["combat-weapon", "fenrisian-great-axe-blizzard-shield"]},
			"ranged": [
				{"id": "assault-cannon", "profiles": {"standard": _weapon("Assault Cannon", 24.0, 6, 3, 6, -2, 1, {"sustained-hits": 1})}},
				{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}},
			],
			"melee": [{"id": "dreadnought-combat-weapon", "profiles": {"standard": _weapon("Dreadnought Combat Weapon", 0.0, 5, 3, 12, -2, 3, {})}}],
			"additional_weapon_profiles": {"ranged": [
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}},
				{"id": "helfrost-cannon", "profiles": {
					"dispersed": _weapon("Helfrost Cannon - Dispersed", 12.0, 3, null, 6, -1, 2, {"torrent": true}),
					"focused": _weapon("Helfrost Cannon - Focused", 36.0, 1, 3, 10, -3, 5, {})}},
				{"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3})}},
			], "melee": [
				{"id": "fenrisian-great-axe", "profiles": {
					"strike": _weapon("Fenrisian Great Axe - Strike", 0.0, 6, 3, 10, -2, "D3+3", {}),
					"sweep": _weapon("Fenrisian Great Axe - Sweep", 0.0, 12, 3, 6, -2, 1, {})}},
			]},
		},
		"wulfen-dreadnought": {
			"name": "Wulfen Dreadnought", "source_datasheet_id": "000004133", "source_role": "Walker",
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/space-marines/Wulfen-Dreadnought-1",
			"points": 140, "points_by_models": {1: 140}, "third_plus_points_by_models": {1: 150}, "models": 1, "max_supported_copies": 3,
			"base_size_source_mm": 60, "base_radius_inches": 30.0 / 25.4,
			"stats": {"movement_inches": 9, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0},
			"keywords": ["ADEPTUS ASTARTES", "SPACE WOLVES", "IMPERIUM", "VEHICLE", "DREADNOUGHT", "WULFEN", "WALKER"],
			"default_loadout_by_role": {"Wulfen Dreadnought": {"Storm Bolter": 1, "Fenrisian Great Axe": 1, "Great Wolf Claw": 1}},
			"walker_loadout_options": {"ranged-secondary": ["storm-bolter", "heavy-flamer"], "melee-weapon": ["fenrisian-great-axe", "blizzard-shield"]},
			"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
			"melee": [
				{"id": "fenrisian-great-axe", "profiles": {
					"strike": _weapon("Fenrisian Great Axe - Strike", 0.0, 6, 3, 10, -2, "D3+3", {}),
					"sweep": _weapon("Fenrisian Great Axe - Sweep", 0.0, 12, 3, 6, -2, 1, {})}},
				{"id": "great-wolf-claw", "profiles": {"standard": _weapon("Great Wolf Claw", 0.0, 6, 3, 10, -3, 3, {})}},
			],
			"additional_weapon_profiles": {"ranged": [
				{"id": "heavy-flamer", "profiles": {"standard": _weapon("Heavy Flamer", 12.0, 3, null, 5, -1, 1, {"blast": 2, "torrent": true})}}
			]},
		},
	}
	for identity: String in profiles:
		profiles[identity].merge(metadata, true)
	return profiles


static func catalog() -> Dictionary:
	# Keep the canonical cache private; callers receive an isolated copy.
	return _all_profiles().duplicate(true)

static func _aethon_claws() -> Dictionary:
	var weapon := {"id": "claws-of-severax", "profiles": {"standard": _weapon("Claws of Severax", 0.0, 7, 2, 5, -2, 2, {"twin-linked": true, "sustained-hits": 2})}}
	weapon.profiles.standard.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func _kor_sarro_anzuQ() -> Dictionary:
	var stats := _weapon("Anzuq", 18.0, 2, 3, 4, -1, 2, {"close-quarters": true, "devastating-wounds": true, "anti-infantry": 4})
	stats.target_required_traits = {"devastating-wounds": ["INFANTRY"]}
	return stats

static func profile(identity: String) -> Dictionary:
	return _all_profiles().get(identity, {}).duplicate(true)

static func rapier_carrier_weapons(primary: String = "quad-heavy-bolter") -> Dictionary:
	if primary not in ["quad-heavy-bolter", "graviton-cannon", "laser-destroyer", "quad-launcher"]: return {}
	var data := profile("rapier-carrier")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if primary != "quad-heavy-bolter":
		for weapon: Dictionary in data.get("additional_weapon_profiles", {}).get("ranged", []):
			if str(weapon.get("id", "")) == primary:
				ranged[1] = weapon.duplicate(true)
				break
	if ranged.size() < 2 or str(ranged[1].get("id", "")) != primary: return {}
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "primary": primary}

static func centurion_devastator_weapons(bolter_replacement: String = "centurion-bolters", grav_replacement: String = "grav-cannon") -> Dictionary:
	if bolter_replacement not in ["centurion-bolters", "centurion-missile-launcher"]: return {}
	if grav_replacement not in ["grav-cannon", "twin-heavy-bolter", "twin-lascannon"]: return {}
	var data := profile("centurion-devastator-squad")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if bolter_replacement != "centurion-bolters": ranged[0] = _profile_weapon(data, "ranged", bolter_replacement)
	if grav_replacement != "grav-cannon": ranged[1] = _profile_weapon(data, "ranged", grav_replacement)
	if ranged.size() != 2 or str(ranged[0].get("id", "")) != bolter_replacement or str(ranged[1].get("id", "")) != grav_replacement: return {}
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "bolters": bolter_replacement, "support": grav_replacement}

static func centurion_assault_weapons(assault_launcher: bool = false, twin_meltagun: bool = false) -> Dictionary:
	var data := profile("centurion-assault-squad")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if assault_launcher:
		var bolter_index := -1
		for index: int in ranged.size():
			if str(ranged[index].get("id", "")) == "centurion-bolters": bolter_index = index
		if bolter_index < 0: return {}
		ranged.remove_at(bolter_index)
	if twin_meltagun:
		var flamer_index := -1
		for index: int in ranged.size():
			if str(ranged[index].get("id", "")) == "twin-flamer": flamer_index = index
		if flamer_index < 0: return {}
		var meltagun := additional_weapon("centurion-assault-squad", "ranged", "twin-meltagun")
		if meltagun.is_empty(): return {}
		ranged[flamer_index] = meltagun
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "assault_launcher": assault_launcher, "twin_meltagun": twin_meltagun}

static func vindicator_weapons(storm_bolter: bool = false, hunter_killer_missile: bool = false) -> Dictionary:
	var data := profile("vindicator")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if hunter_killer_missile:
		var missile := additional_weapon("vindicator", "ranged", "hunter-killer-missile")
		if missile.is_empty(): return {}
		ranged.append(missile)
	if storm_bolter:
		var bolter := additional_weapon("vindicator", "ranged", "storm-bolter")
		if bolter.is_empty(): return {}
		ranged.append(bolter)
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "storm_bolter": storm_bolter, "hunter_killer_missile": hunter_killer_missile}

static func predator_annihilator_weapons(heavy_bolters: bool = false, hunter_killer_missile: bool = false, storm_bolter: bool = false) -> Dictionary:
	var data := profile("predator-annihilator")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if heavy_bolters:
		var heavy := additional_weapon("predator-annihilator", "ranged", "heavy-bolter")
		if heavy.is_empty(): return {}
		ranged[0] = heavy.duplicate(true)
		ranged[1] = heavy.duplicate(true)
	if hunter_killer_missile:
		var missile := additional_weapon("predator-annihilator", "ranged", "hunter-killer-missile")
		if missile.is_empty(): return {}
		ranged.append(missile)
	if storm_bolter:
		var bolter := additional_weapon("predator-annihilator", "ranged", "storm-bolter")
		if bolter.is_empty(): return {}
		ranged.append(bolter)
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "heavy_bolters": heavy_bolters, "hunter_killer_missile": hunter_killer_missile, "storm_bolter": storm_bolter}

static func predator_destructor_weapons(heavy_bolters: bool = false, hunter_killer_missile: bool = false, storm_bolter: bool = false) -> Dictionary:
	var data := profile("predator-destructor")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if heavy_bolters:
		var heavy := additional_weapon("predator-destructor", "ranged", "heavy-bolter")
		if heavy.is_empty(): return {}
		ranged[0] = heavy.duplicate(true)
		ranged[1] = heavy.duplicate(true)
	if hunter_killer_missile:
		var missile := additional_weapon("predator-destructor", "ranged", "hunter-killer-missile")
		if missile.is_empty(): return {}
		ranged.append(missile)
	if storm_bolter:
		var bolter := additional_weapon("predator-destructor", "ranged", "storm-bolter")
		if bolter.is_empty(): return {}
		ranged.append(bolter)
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "heavy_bolters": heavy_bolters, "hunter_killer_missile": hunter_killer_missile, "storm_bolter": storm_bolter}

static func whirlwind_weapons(hunter_killer_missile: bool = false, storm_bolter: bool = false) -> Dictionary:
	var data := profile("whirlwind")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if hunter_killer_missile:
		var missile := additional_weapon("whirlwind", "ranged", "hunter-killer-missile")
		if missile.is_empty(): return {}
		ranged.append(missile)
	if storm_bolter:
		var bolter := additional_weapon("whirlwind", "ranged", "storm-bolter")
		if bolter.is_empty(): return {}
		ranged.append(bolter)
	return {"ranged": ranged, "melee": data.melee.duplicate(true), "hunter_killer_missile": hunter_killer_missile, "storm_bolter": storm_bolter}

static func space_wolves_walker_weapons(identity: String, ranged_primary: String = "", ranged_secondary: String = "", melee_package: String = "") -> Dictionary:
	if identity not in ["bjorn-the-fell-handed", "murderfang", "venerable-dreadnought", "wulfen-dreadnought"]: return {}
	var data := profile(identity)
	if data.is_empty(): return {}
	var ranged: Array = data.get("ranged", []).duplicate(true)
	var melee: Array = data.get("melee", []).duplicate(true)
	var shield := false
	var alternatives: Dictionary = data.get("additional_weapon_profiles", {})
	match identity:
		"bjorn-the-fell-handed":
			if ranged_primary.is_empty(): ranged_primary = "assault-cannon"
			if ranged_primary not in ["assault-cannon", "helfrost-cannon", "multi-melta"]: return {}
			if ranged_primary != "assault-cannon": ranged[0] = _walker_alternate_weapon(alternatives, "ranged", ranged_primary)
		"venerable-dreadnought":
			if ranged_primary.is_empty(): ranged_primary = "assault-cannon"
			if ranged_secondary.is_empty(): ranged_secondary = "storm-bolter"
			if melee_package.is_empty(): melee_package = "combat-weapon"
			if ranged_primary not in ["assault-cannon", "helfrost-cannon", "multi-melta"] or ranged_secondary not in ["storm-bolter", "heavy-flamer"] or melee_package not in ["combat-weapon", "fenrisian-great-axe-blizzard-shield"]: return {}
			if melee_package == "fenrisian-great-axe-blizzard-shield" and ranged_primary != "assault-cannon": return {}
			if ranged_primary != "assault-cannon": ranged[0] = _walker_alternate_weapon(alternatives, "ranged", ranged_primary)
			if ranged_secondary != "storm-bolter": ranged[1] = _walker_alternate_weapon(alternatives, "ranged", ranged_secondary)
			if melee_package == "fenrisian-great-axe-blizzard-shield":
				ranged.remove_at(0)
				melee = [_walker_alternate_weapon(alternatives, "melee", "fenrisian-great-axe")]
				shield = true
		"wulfen-dreadnought":
			if ranged_secondary.is_empty(): ranged_secondary = "storm-bolter"
			if melee_package.is_empty(): melee_package = "fenrisian-great-axe"
			if ranged_secondary not in ["storm-bolter", "heavy-flamer"] or melee_package not in ["fenrisian-great-axe", "blizzard-shield"]: return {}
			if ranged_secondary != "storm-bolter": ranged[0] = _walker_alternate_weapon(alternatives, "ranged", ranged_secondary)
			if melee_package == "blizzard-shield":
				melee = [melee[1].duplicate(true)]
				shield = true
	return {"ranged": ranged, "melee": melee, "blizzard_shield": shield, "ranged_primary": ranged_primary, "ranged_secondary": ranged_secondary, "melee_package": melee_package}

static func _walker_alternate_weapon(alternatives: Dictionary, category: String, weapon_id: String) -> Dictionary:
	for weapon: Dictionary in alternatives.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

static func deathwatch_veteran_weapons(is_sergeant: bool, loadout: String = "default", sergeant_ranged: String = "boltgun", sergeant_melee: String = "power-weapon") -> Dictionary:
	var data := profile("deathwatch-veterans")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	var melee: Array = data.melee.duplicate(true)
	if not is_sergeant and loadout != "default":
		ranged = []
		melee = []
		match loadout:
			"stalker-pattern-boltgun":
				ranged = [_profile_weapon(data, "ranged", loadout)]
				melee = [_profile_weapon(data, "melee", "knives-and-fists")]
			"infernus-heavy-bolter":
				ranged = [_profile_weapon(data, "ranged", loadout)]
				melee = [_profile_weapon(data, "melee", "knives-and-fists")]
			"deathwatch-shotgun":
				ranged = [_profile_weapon(data, "ranged", loadout)]
				melee = [_profile_weapon(data, "melee", "knives-and-fists")]
			"heavy-thunder-hammer": melee = [_profile_weapon(data, "melee", loadout)]
			"frag-cannon":
				ranged = [_profile_weapon(data, "ranged", loadout)]
				melee = [_profile_weapon(data, "melee", "knives-and-fists")]
			"black-shield-blades": melee = [_profile_weapon(data, "melee", loadout)]
			"boltgun-storm-shield": ranged = [data.ranged[0].duplicate(true)]
			"power-weapon-storm-shield": melee = [data.melee[0].duplicate(true)]
			_:
				return {}
	if is_sergeant:
		if loadout != "default": return {}
		if sergeant_ranged == "combi-weapon": ranged = [_profile_weapon(data, "ranged", "combi-weapon")]
		elif sergeant_ranged != "boltgun": return {}
		if sergeant_melee == "xenophase-blade": melee = [_profile_weapon(data, "melee", "xenophase-blade")]
		elif sergeant_melee != "power-weapon": return {}
	elif sergeant_ranged != "boltgun" or sergeant_melee != "power-weapon":
		return {}
	if ranged.any(func(weapon: Dictionary) -> bool: return weapon.is_empty()) or melee.any(func(weapon: Dictionary) -> bool: return weapon.is_empty()): return {}
	return {"ranged": ranged, "melee": melee}

static func _profile_weapon(data: Dictionary, category: String, weapon_id: String) -> Dictionary:
	for weapon: Dictionary in data.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	for weapon: Dictionary in data.get("additional_weapon_profiles", {}).get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

static func wolf_guard_terminator_weapons(loadout: String = "default") -> Dictionary:
	var data := profile("wolf-guard-terminators")
	if data.is_empty() or loadout not in data.options.pack_leader_loadouts + data.options.terminator_loadouts: return {}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	match loadout:
		"default", "storm-shield":
			if loadout == "default": ranged.append(_profile_weapon(data, "ranged", "storm-bolter"))
			melee.append(_profile_weapon(data, "melee", "master-crafted-power-weapon"))
		"assault-cannon-power-fist":
			ranged.append(_profile_weapon(data, "ranged", "assault-cannon"))
			melee.append(_profile_weapon(data, "melee", "power-fist"))
		"relic-greataxe": melee.append(_profile_weapon(data, "melee", "relic-greataxe"))
		"twin-lightning-claws": melee.append(_profile_weapon(data, "melee", "twin-lightning-claws"))
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func wolf_guard_battle_leader_weapons(ranged_loadout: String = "plasma-pistol", melee_loadout: String = "master-crafted-power-weapon") -> Dictionary:
	var data := profile("wolf-guard-battle-leader")
	if data.is_empty() or ranged_loadout not in data.options.ranged_loadouts or melee_loadout not in data.options.melee_loadouts: return {}
	var ranged: Array[Dictionary] = []
	if ranged_loadout == "plasma-pistol": ranged.append(_profile_weapon(data, "ranged", "plasma-pistol"))
	var melee: Array[Dictionary] = [_profile_weapon(data, "melee", "master-crafted-power-weapon") if melee_loadout == "master-crafted-power-weapon" else _profile_weapon(data, "melee", "thunder-hammer")]
	if (ranged_loadout == "plasma-pistol" and ranged.has({})) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func thunderwolf_cavalry_weapons(loadout: String = "default") -> Dictionary:
	var data := profile("thunderwolf-cavalry")
	if data.is_empty() or loadout not in data.options.loadouts: return {}
	var ranged: Array[Dictionary] = []
	match loadout:
		"default": ranged.append(_profile_weapon(data, "ranged", "bolt-pistol"))
		"plasma-pistol": ranged.append(_profile_weapon(data, "ranged", "plasma-pistol"))
		"boltgun-storm-shield": ranged.append(_profile_weapon(data, "ranged", "boltgun"))
	var melee: Array[Dictionary] = [
		_profile_weapon(data, "melee", "teeth-and-claws"),
		_profile_weapon(data, "melee", "wolf-guard-weapon")
	]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func wulfen_weapons(loadout: String = "death-totem") -> Dictionary:
	var data := profile("wulfen")
	if data.is_empty() or loadout not in data.options.loadouts: return {}
	var ranged: Array[Dictionary] = []
	if loadout == "stormfrag-auto-launcher": ranged.append(_profile_weapon(data, "ranged", loadout))
	var melee: Array[Dictionary] = [_profile_weapon(data, "melee", "wulfen-weapons")]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func wulfen_storm_shields_weapons(loadout: String = "stormfrag-auto-launcher") -> Dictionary:
	var data := profile("wulfen-with-storm-shields")
	if data.is_empty() or loadout not in data.options.loadouts: return {}
	var ranged: Array[Dictionary] = []
	if loadout == "stormfrag-auto-launcher": ranged.append(_profile_weapon(data, "ranged", loadout))
	var melee: Array[Dictionary] = [_profile_weapon(data, "melee", "thunder-hammer")]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func wolf_scouts_model_loadout(model_index: int, model_count: int, scout_loadout: String = "default") -> Dictionary:
	var data := profile("wolf-scouts")
	var options: Array = data.get("options", {}).get("wolf_scout_loadouts", [])
	if data.is_empty() or model_count not in [6, 12] or model_index < 0 or model_index >= model_count: return {}
	var hunting_wolves := 2 if model_count == 12 else 1
	var role := "Wolf Scout Pack Leader" if model_index == 0 else "Hunting Wolf" if model_index <= hunting_wolves else "Wolf Scout"
	if role != "Wolf Scout" and scout_loadout != "default": return {}
	if role == "Wolf Scout" and scout_loadout not in options: return {}
	var stats: Dictionary
	var radius := 16.0 / 25.4
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	if role == "Hunting Wolf":
		stats = {"movement_inches": 10, "toughness": 4, "save_target": 6, "wounds": 1, "leadership_target": 8, "objective_control": 0, "invulnerable_target": 0}
		radius = 30.0 / 25.4
		melee.append(_profile_weapon(data, "melee", "teeth-and-claws"))
	elif role == "Wolf Scout Pack Leader":
		stats = {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
		ranged.append(_profile_weapon(data, "ranged", "plasma-pistol"))
		melee.append(_profile_weapon(data, "melee", "power-weapon"))
	else:
		stats = {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
		match scout_loadout:
			"default":
				ranged.append(_profile_weapon(data, "ranged", "plasma-pistol"))
				melee.append(_profile_weapon(data, "melee", "combat-knife"))
			"bolt-pistol": ranged.append(_profile_weapon(data, "ranged", "bolt-pistol"))
			"runic-stave": melee.append(_profile_weapon(data, "melee", "runic-stave"))
			"thunderclap": ranged.append(_profile_weapon(data, "ranged", "thunderclap"))
			"instigator-bolt-carbine":
				var carbine := _profile_weapon(data, "ranged", "instigator-bolt-carbine")
				carbine.profiles.standard.target_restricted_traits = {"lethal-hits": ["MONSTER", "VEHICLE"]}
				ranged.append(carbine)
				melee.append(_profile_weapon(data, "melee", "combat-knife"))
			"plasma-gun":
				ranged.append(_profile_weapon(data, "ranged", "plasma-gun"))
				melee.append(_profile_weapon(data, "melee", "combat-knife"))
	if ranged.has({}) or melee.has({}): return {}
	return {"role": role, "stats": stats, "base_radius_inches": radius, "ranged": ranged, "melee": melee}

static func blood_claws_pack_leader_weapons(pistol_package: String = "bolt-pistol", melee_package: String = "chainsword") -> Dictionary:
	var data := profile("blood-claws")
	if data.is_empty() or pistol_package not in data.options.pack_leader_ranged_packages or melee_package not in data.options.pack_leader_melee_packages: return {}
	var ranged := [_profile_weapon(data, "ranged", pistol_package)]
	var melee := [_profile_weapon(data, "melee", melee_package)]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func grey_hunters_pack_leader_weapons(pistol_package: String = "bolt-pistol", melee_package: String = "chainsword") -> Dictionary:
	var data := profile("grey-hunters")
	if data.is_empty() or pistol_package not in data.options.pack_leader_ranged_packages or melee_package not in data.options.pack_leader_melee_packages: return {}
	var ranged := [_profile_weapon(data, "ranged", "bolt-carbine"), _profile_weapon(data, "ranged", pistol_package)]
	var melee := [_profile_weapon(data, "melee", melee_package)]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func grimaldus_model_loadout(model_index: int) -> Dictionary:
	if model_index == 0:
		return {
			"role": "Chaplain Grimaldus",
			"keywords": ["INFANTRY", "CHARACTER", "EPIC HERO", "CHAPLAIN", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
			"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4},
			"base_radius_inches": 20.0 / 25.4,
			"ranged": [{"id": "plasma-pistol", "physical_weapon_id": "plasma-pistol", "profiles": {
				"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 2, 7, -2, 1, {"close-quarters": true}),
				"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 2, 8, -3, 2, {"close-quarters": true, "hazardous": true})
			}}],
			"melee": [{"id": "artificer-crozius", "physical_weapon_id": "artificer-crozius", "profiles": {"standard": _weapon("Artificer crozius", 0.0, 6, 2, 6, -2, 2, {})}}]
		}
	return {
		"role": "Cenobyte Servitor",
		"keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"],
		"stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 1, "leadership_target": 8, "objective_control": 1, "invulnerable_target": 4},
		"base_radius_inches": 14.25 / 25.4,
		"ranged": [],
		"melee": [{"id": "servitor-combat-weapon", "physical_weapon_id": "servitor-combat-weapon", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 1, 4, 3, 0, 1, {})}}]
	}

static func castellan_weapons(ranged_package: String = "combi-weapon", melee_package: String = "master-crafted-power-weapon") -> Dictionary:
	var data := profile("castellan")
	if data.is_empty() or ranged_package not in data.options.ranged_packages or melee_package not in data.options.melee_packages: return {}
	var ranged: Array = [data.ranged[0].duplicate(true)] if ranged_package == "combi-weapon" else [data.additional_weapon_profiles.ranged[0].duplicate(true)]
	var melee: Array = [data.melee[0].duplicate(true)] if melee_package == "master-crafted-power-weapon" else [data.additional_weapon_profiles.melee[0].duplicate(true)]
	return {"ranged": ranged, "melee": melee}

static func marshal_weapons(ranged_package: String = "plasma-pistol") -> Dictionary:
	var data := profile("marshal")
	if data.is_empty() or ranged_package not in data.options.ranged_packages: return {}
	var ranged: Array = [data.ranged[0].duplicate(true)] if ranged_package == "plasma-pistol" else [data.additional_weapon_profiles.ranged[0].duplicate(true)]
	return {"ranged": ranged, "melee": data.melee.duplicate(true)}

static func tarantula_sentry_battery_weapons(primary: String = "twin-heavy-bolter") -> Dictionary:
	if primary not in ["twin-heavy-bolter", "twin-lascannon"]: return {}
	var data := profile("tarantula-sentry-battery")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true) if primary == "twin-heavy-bolter" else data.get("additional_weapon_profiles", {}).get("ranged", []).duplicate(true)
	return {"ranged": ranged}

static func baal_predator_weapons(primary_cannon: String = "twin-assault-cannon", sponson_package: String = "none", storm_bolter: bool = false, hunter_killer_missile: bool = false) -> Array[Dictionary]:
	var data := profile("baal-predator")
	if data.is_empty() or primary_cannon not in data.options.primary_cannon or sponson_package not in data.options.sponson_package: return []
	var result: Array[Dictionary] = []
	var cannon: Dictionary = data.ranged[0].duplicate(true) if primary_cannon == "twin-assault-cannon" else additional_weapon("baal-predator", "ranged", primary_cannon)
	if cannon.is_empty(): return []
	result.append(cannon)
	match sponson_package:
		"heavy-bolters":
			for weapon_id: String in ["heavy-bolter-sponson-left", "heavy-bolter-sponson-right"]:
				var weapon := additional_weapon("baal-predator", "ranged", weapon_id)
				if weapon.is_empty(): return []
				result.append(weapon)
		"heavy-flamers":
			for weapon_id: String in ["heavy-flamer-sponson-left", "heavy-flamer-sponson-right"]:
				var weapon := additional_weapon("baal-predator", "ranged", weapon_id)
				if weapon.is_empty(): return []
				result.append(weapon)
	if storm_bolter:
		var storm := additional_weapon("baal-predator", "ranged", "storm-bolter")
		if storm.is_empty(): return []
		result.append(storm)
	if hunter_killer_missile:
		var missile := additional_weapon("baal-predator", "ranged", "hunter-killer-missile")
		if missile.is_empty(): return []
		result.append(missile)
	return result

static func death_company_dreadnought_weapons(twin_multi_melta: bool = false, blood_talons: bool = false) -> Dictionary:
	var data := profile("death-company-dreadnought")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	if not blood_talons: ranged.append(data.ranged[0].duplicate(true))
	var heavy_weapon: Dictionary = additional_weapon("death-company-dreadnought", "ranged", "twin-multi-melta-death-company-dreadnought") if twin_multi_melta else data.ranged[1].duplicate(true)
	if heavy_weapon.is_empty(): return {}
	ranged.append(heavy_weapon)
	ranged.append(data.ranged[2].duplicate(true))
	var melee: Dictionary = additional_weapon("death-company-dreadnought", "melee", "blood-talons") if blood_talons else data.melee[0].duplicate(true)
	if melee.is_empty(): return {}
	return {"ranged": ranged, "melee": [melee]}

static func _death_company_squad_profile(jump_packs: bool) -> Dictionary:
	var identity := "death-company-marines-with-jump-packs" if jump_packs else "death-company-marines"
	var display_name := "Death Company Marines With Jump Packs" if jump_packs else "Death Company Marines"
	var datasheet_id := "000002737" if jump_packs else "000001997"
	var cost := {5: 130, 10: 260} if jump_packs else {5: 90, 10: 170}
	var third_cost := {5: 160, 10: 290} if jump_packs else {5: 105, 10: 185}
	var keywords: Array[String] = ["INFANTRY", "EXPLOSIVES", "DEATH COMPANY", "IMPERIUM", "TACTICUS"]
	if jump_packs:
		keywords.append("JUMP PACK")
		keywords.append("FLY")
	keywords.append("ADEPTUS ASTARTES")
	keywords.append("BLOOD ANGELS")
	return {
		"name": display_name, "source_book_id": "000000021", "source_datasheet_id": datasheet_id,
		"source_export_updated_at": "2026-10-21T16:06:23+03:00", "source_snapshot_id": "20261021T130623Z",
		"source_manifest_sha256": "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf",
		"source_slice_manifest_sha256": "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5",
		"points": int(cost[5]), "points_by_models": cost, "third_plus_points_by_models": third_cost,
		"max_supported_copies": 3, "models": 5, "base_size_source_mm": 32, "base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 12 if jump_packs else 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": keywords,
		"options": {"melee_packages": ["chainsword", "eviscerator", "power-fist", "power-weapon"] if jump_packs else ["chainsword", "bolt-rifle-fire", "eviscerator", "power-fist", "power-weapon", "thunder-hammer"], "pistol_packages": ["heavy-bolt-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol"]},
		"ranged": [_death_company_heavy_bolt_pistol()],
		"melee": [_death_company_chainsword()],
		"additional_weapon_profiles": {"ranged": _death_company_optional_ranged(jump_packs), "melee": _death_company_optional_melee(jump_packs)}
	}

static func death_company_melee_options(identity: String) -> Array[String]:
	var profile_record := profile(identity)
	var options: Array[String] = []
	for option: Variant in profile_record.get("options", {}).get("melee_packages", []):
		if option is String: options.append(str(option))
	return options

static func death_company_pistol_options(identity: String) -> Array[String]:
	var profile_record := profile(identity)
	var options: Array[String] = []
	for option: Variant in profile_record.get("options", {}).get("pistol_packages", []):
		if option is String: options.append(str(option))
	return options

static func death_company_loadout_limits_valid(identity: String, model_count: int, melee_packages: Array, pistol_packages: Array, grenade_launchers: Array) -> bool:
	if identity not in ["death-company-marines", "death-company-marines-with-jump-packs"] or model_count not in [5, 10]: return false
	if melee_packages.size() != model_count or pistol_packages.size() != model_count or grenade_launchers.size() != model_count: return false
	var jump_packs := identity == "death-company-marines-with-jump-packs"
	var limit_per_five := floori(float(model_count) / 5.0)
	var counts := {"eviscerator": 0, "power-fist": 0, "power-weapon": 0, "thunder-hammer": 0, "bolt-rifle-fire": 0,
		"hand-flamer": 0, "inferno-pistol": 0, "plasma-pistol": 0, "grenade-launcher": 0}
	var allowed_melee := death_company_melee_options(identity)
	var allowed_pistols := death_company_pistol_options(identity)
	for index in range(model_count):
		var melee_package := str(melee_packages[index])
		var pistol_package := str(pistol_packages[index])
		if melee_package not in allowed_melee or pistol_package not in allowed_pistols: return false
		if bool(grenade_launchers[index]) and (jump_packs or melee_package != "bolt-rifle-fire"): return false
		counts[melee_package] = int(counts.get(melee_package, 0)) + 1
		if pistol_package != "heavy-bolt-pistol": counts[pistol_package] = int(counts.get(pistol_package, 0)) + 1
		if bool(grenade_launchers[index]): counts["grenade-launcher"] = int(counts["grenade-launcher"]) + 1
	if counts.eviscerator > limit_per_five or counts["power-fist"] > limit_per_five: return false
	if jump_packs:
		if counts["power-weapon"] > 2 * limit_per_five or counts["hand-flamer"] > limit_per_five or counts["inferno-pistol"] > limit_per_five or counts["plasma-pistol"] > 2 * limit_per_five: return false
	else:
		if counts["power-weapon"] + counts["thunder-hammer"] + counts["power-fist"] > 1: return false
		if counts["hand-flamer"] + counts["inferno-pistol"] + counts["plasma-pistol"] > 1: return false
		if counts["bolt-rifle-fire"] + counts["eviscerator"] + counts["power-fist"] + counts["power-weapon"] + counts["thunder-hammer"] > model_count: return false
		if counts["grenade-launcher"] > limit_per_five: return false
	return true

static func death_company_model_weapons(identity: String, melee_package: String = "chainsword", pistol_package: String = "heavy-bolt-pistol", grenade_launcher: bool = false) -> Dictionary:
	if melee_package not in death_company_melee_options(identity) or pistol_package not in death_company_pistol_options(identity): return {}
	var jump_packs := identity == "death-company-marines-with-jump-packs"
	if grenade_launcher and (jump_packs or melee_package != "bolt-rifle-fire"): return {}
	var profile_record := profile(identity)
	if profile_record.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	if pistol_package == "heavy-bolt-pistol": ranged.append(profile_record.ranged[0].duplicate(true))
	else:
		var pistol := additional_weapon(identity, "ranged", pistol_package)
		if pistol.is_empty(): return {}
		ranged.append(pistol)
	if melee_package == "bolt-rifle-fire":
		var rifle := additional_weapon(identity, "ranged", "bolt-rifle-fire")
		var combat_blade := additional_weapon(identity, "melee", "combat-blade")
		if rifle.is_empty() or combat_blade.is_empty(): return {}
		ranged.append(rifle)
		var melee: Array[Dictionary] = [combat_blade]
		if grenade_launcher:
			var launcher := additional_weapon(identity, "ranged", "grenade-launcher")
			if launcher.is_empty(): return {}
			ranged.append(launcher)
		return {"ranged": ranged, "melee": melee}
	var melee: Array[Dictionary] = []
	if melee_package == "chainsword": melee.append(profile_record.melee[0].duplicate(true))
	else:
		var replacement := additional_weapon(identity, "melee", melee_package)
		if replacement.is_empty(): return {}
		melee.append(replacement)
	return {"ranged": ranged, "melee": melee}

static func _chapter_vehicle_profiles(base_profiles: Dictionary = {}) -> Dictionary:
	var bases := base_profiles.duplicate(true)
	if bases.is_empty():
		bases = _build_profiles()
		bases.merge(transport_profiles(), true)
	var result := {}
	for identity: String in BLACK_TEMPLARS_VEHICLE_SOURCES:
		var source: Dictionary = BLACK_TEMPLARS_VEHICLE_SOURCES[identity]
		var base: Dictionary = bases.get(str(source.get("base", "")), {})
		if base.is_empty(): continue
		var profile: Dictionary = base.duplicate(true)
		profile.name = source.name
		profile.source_book_id = "000000162"
		profile.source_datasheet_id = source.datasheet_id
		profile.source_snapshot_id = CHAPTER_VEHICLE_SOURCE_SNAPSHOT
		profile.source_export_updated_at = CHAPTER_VEHICLE_SOURCE_UPDATED_AT
		profile.source_manifest_sha256 = CHAPTER_VEHICLE_SOURCE_MANIFEST_SHA256
		profile.source_slice_manifest_sha256 = CHAPTER_VEHICLE_SLICE_MANIFEST_SHA256
		profile.points = int(source.cost)
		profile.points_by_models = {1: int(source.cost)}
		profile.third_plus_points_by_models = {1: int(source.third_cost)}
		profile.max_supported_copies = 3
		profile.points_source = "wahapedia_e11_local_export_2026_10_21_black_templars_app"
		profile.wargear_costs = source.wargear_costs.duplicate(true)
		profile.keywords = source.keywords.duplicate()
		if source.has("fourth_cost"):
			profile.fourth_plus_points_by_models = {1: int(source.fourth_cost)}
		if source.has("excluded_weapon_profiles"):
			var excluded: Array = source.excluded_weapon_profiles
			var additional: Dictionary = profile.get("additional_weapon_profiles", {})
			for group: String in additional:
				additional[group] = (additional[group] as Array).filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) not in excluded)
			profile.additional_weapon_profiles = additional
		if source.has("excluded_impulsor_systems"):
			var transport: Dictionary = profile.get("transport", {}).duplicate(true)
			var options: Dictionary = transport.get("options", {}).duplicate(true)
			options.one_of = (options.get("one_of", []) as Array).filter(func(option: String) -> bool: return option not in source.excluded_impulsor_systems)
			options.wargear_costs = source.wargear_costs.duplicate(true)
			transport.options = options
			profile.transport = transport
		result[identity] = profile
	return result

static func unit_keywords_for_composition(profile_record: Dictionary, composition_choice: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for keyword: Variant in profile_record.get("keywords", []):
		if keyword is String and not result.has(keyword): result.append(keyword)
	var roles: Variant = composition_choice.get("roles", [])
	if not roles is Array: return result
	for role: Variant in roles:
		for model_profile: Variant in profile_record.get("model_loadouts", []):
			if not model_profile is Dictionary or str(model_profile.get("role", "")) != str(role): continue
			for keyword: Variant in model_profile.get("keywords", []):
				if keyword is String and not result.has(keyword): result.append(keyword)
	return result

static func detachment_keyword_grants(identity: String, detachment_id: String, profile_keywords: Array = []) -> Array[String]:
	var result: Array[String] = []
	if "ADEPTUS ASTARTES" not in profile_keywords: return result
	var detachment_grants: Dictionary = DETACHMENT_KEYWORD_GRANTS.get(detachment_id, {})
	for keyword: Variant in detachment_grants.get(identity, []):
		if keyword is String and not result.has(keyword): result.append(keyword)
	return result

static func roster_keywords(identity: String, profile_record: Dictionary, composition_choice: Dictionary = {}, detachment_id: String = "") -> Array[String]:
	var result := unit_keywords_for_composition(profile_record, composition_choice)
	for keyword: String in detachment_keyword_grants(identity, detachment_id, profile_record.get("keywords", [])):
		if not result.has(keyword): result.append(keyword)
	return result

static func additional_weapon(identity: String, category: String, weapon_id: String) -> Dictionary:
	var options: Variant = profile(identity).get("additional_weapon_profiles", {}).get(category, [])
	if options is Array:
		for option: Variant in options:
			if option is Dictionary and str(option.get("id", "")) == weapon_id:
				return option.duplicate(true)
	elif options is Dictionary:
		var option: Variant = options.get(weapon_id, {})
		if option is Dictionary: return option.duplicate(true)
	return {}

static func execrator_weapons(pistol_package: String = "absolvor-bolt-pistol", mastercrafted_power_weapon: bool = false) -> Dictionary:
	var record := profile("execrator")
	if record.is_empty() or pistol_package not in record.get("options", {}).get("ranged_packages", []): return {}
	if mastercrafted_power_weapon and pistol_package != "absolvor-bolt-pistol": return {}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = [record.melee[0].duplicate(true)]
	if pistol_package == "absolvor-bolt-pistol": ranged.append(record.ranged[0].duplicate(true))
	else:
		var hand_flamer := additional_weapon("execrator", "ranged", "hand-flamer")
		if hand_flamer.is_empty(): return {}
		ranged.append(hand_flamer)
	if mastercrafted_power_weapon:
		var power_weapon := additional_weapon("execrator", "melee", "master-crafted-power-weapon")
		if power_weapon.is_empty(): return {}
		melee.append(power_weapon)
	return {"ranged": ranged, "melee": melee}

static func deathwing_knight_melee_weapon(weapon_id: String) -> Dictionary:
	if weapon_id == "mace-of-absolution":
		var profile_record := profile("deathwing-knights")
		return profile_record.get("melee", [{}])[0].duplicate(true) if not profile_record.get("melee", []).is_empty() else {}
	return additional_weapon("deathwing-knights", "melee", weapon_id)

static func chapter_keywords(identity: String) -> Array[String]:
	return chapter_keywords_for(profile(identity).get("keywords", []))

static func chapter_keywords_for(keywords: Array) -> Array[String]:
	var result: Array[String] = []
	for keyword: String in CHAPTER_KEYWORD_NAMES:
		if keyword in keywords: result.append(keyword)
	return result

static func chapter_name(keyword: String) -> String:
	return str(CHAPTER_KEYWORD_NAMES.get(keyword, keyword))

static func transport_profiles() -> Dictionary:
	var file := FileAccess.open("res://data/edition_11/space_marines_transport_profiles.json", FileAccess.READ)
	if file == null: return {}
	var document: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not document is Dictionary or document.get("source_book_id", "") != "000000139" or document.get("source_export_updated_at", "") != "2026-10-21T16:06:23+03:00" or document.get("source_snapshot_id", "") != "20261021T130623Z": return {}
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
		var wargear_costs: Dictionary = source.get("wargear_costs", {})
		for wargear_name: String in wargear_costs:
			var wargear_cost: Variant = wargear_costs[wargear_name]
			if (wargear_cost is int or wargear_cost is float) and is_finite(float(wargear_cost)) and float(wargear_cost) == floor(float(wargear_cost)):
				wargear_costs[wargear_name] = int(wargear_cost)
		source.wargear_costs = wargear_costs
		var points: Dictionary = source.get("points_by_models", {})
		var second: Dictionary = source.get("second_plus_points_by_models", {})
		var third: Dictionary = source.get("third_plus_points_by_models", {})
		var fourth: Dictionary = source.get("fourth_plus_points_by_models", {})
		source.points_by_models = {1: int(points.get("1", points.get(1, source.get("points", 0))))}
		if second.has("1") or second.has(1): source.second_plus_points_by_models = {1: int(second.get("1", second.get(1, source.points_by_models[1])))}
		var third_fallback := int(source.get("second_plus_points_by_models", {}).get(1, source.points_by_models[1]))
		source.third_plus_points_by_models = {1: int(third.get("1", third.get(1, third_fallback)))}
		if fourth.has("1") or fourth.has(1): source.fourth_plus_points_by_models = {1: int(fourth.get("1", fourth.get(1, source.get("points", 0))))}
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
			var keywords: Dictionary = stats.get("keywords", {})
			for keyword: String in keywords:
				var parameter: Variant = keywords[keyword]
				if (parameter is int or parameter is float) and is_finite(float(parameter)) and float(parameter) == floor(float(parameter)):
					keywords[keyword] = int(parameter)
			stats.keywords = keywords

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
		0: return {"role": "ancient", "source_model_name": "Ancient", "ranged": [bolt_pistol.duplicate(true), rifle.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ANCIENT", "CHARACTER"]}
		1: return {"role": "company-champion", "source_model_name": "Company Champion", "ranged": [bolt_pistol.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "CHAMPION"]}
		2: return {"role": "bolt-rifle-veteran", "source_model_name": "Company veteran with bolt rifle", "ranged": [bolt_pistol.duplicate(true), rifle.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]}
		3: return {"role": "heavy-bolter-veteran", "source_model_name": "Company Veteran with heavy bolter", "ranged": [bolt_pistol.duplicate(true), heavy_bolter.duplicate(true)], "melee": [knife.duplicate(true)], "keywords": ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]}
	return {}

static func fortis_kill_team_model_loadout(model_index: int, sergeant_melee: String = "knives-and-fists", sergeant_ranged: String = "deathwatch-bolt-rifle", grenade_launcher: bool = false, plasma_pistol: bool = false, rocket_launcher: String = "superfrag") -> Dictionary:
	if model_index < 0 or model_index >= 10: return {}
	if sergeant_melee not in ["knives-and-fists", "chainsword", "power-fist", "power-weapon", "thunder-hammer"]: return {}
	if sergeant_ranged not in ["deathwatch-bolt-rifle", "chainsword", "hand-flamer", "plasma-pistol", "power-weapon"]: return {}
	if rocket_launcher not in ["superfrag", "superkrak", "vengor"]: return {}
	if grenade_launcher and model_index not in [1, 4, 5]: return {}
	if plasma_pistol and model_index not in [2, 3]: return {}
	if model_index == 1 and grenade_launcher and sergeant_ranged != "deathwatch-bolt-rifle": return {}
	var ranged_library := {
		"bolt-pistol": {"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		"castellan-launcher": {"id": "castellan-launcher", "profiles": {"standard": _weapon("Castellan Launcher", 24.0, 2, 3, 5, -1, 1, {"heavy": true})}},
		"deathwatch-bolt-rifle": {"id": "deathwatch-bolt-rifle", "profiles": {"standard": _weapon("Deathwatch Bolt Rifle", 24.0, 2, 3, 5, -2, 1, {"assault": true, "lethal-hits": true, "heavy": true})}},
		"grenade-launcher": {"id": "grenade-launcher", "profiles": {"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}), "krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}},
		"hand-flamer": {"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
		"heavy-bolt-pistol": {"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		"plasma-incinerator": {"id": "plasma-incinerator", "profiles": {"standard": _weapon("Plasma Incinerator - Standard", 24.0, 2, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}), "supercharge": _weapon("Plasma Incinerator - Supercharge", 24.0, 2, 3, 8, -3, 2, {"assault": true, "rapid-fire": 1, "hazardous": true})}},
		"plasma-pistol": {"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}},
		"pyreblaster": {"id": "pyreblaster", "profiles": {"standard": _weapon("Pyreblaster", 12.0, 3, 0, 5, -1, 1, {"torrent": true, "blast": 1})}},
		"superfrag-rocket-launcher": {"id": "superfrag-rocket-launcher", "profiles": {"standard": _weapon("Superfrag Rocket Launcher", 48.0, 4, 3, 5, -1, 1, {"blast": 1, "heavy": true})}},
		"superkrak-rocket-launcher": {"id": "superkrak-rocket-launcher", "profiles": {"standard": _weapon("Superkrak Rocket Launcher", 48.0, 1, 3, 10, -2, "D3+3", {"heavy": true})}},
		"vengor-launcher": {"id": "vengor-launcher", "profiles": {"standard": _weapon("Vengor Launcher", 48.0, 4, 3, 7, -1, 2, {"blast": 1, "indirect-fire": true, "heavy": true})}}
	}
	var melee_library := {
		"chainsword": {"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}},
		"knives-and-fists": {"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}},
		"power-fist": {"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
		"power-weapon": {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}},
		"thunder-hammer": {"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
	}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var role := ""
	var source_model_name := ""
	match model_index:
		0:
			role = "castellan-launcher-intercessor"
			source_model_name = "Kill Team Intercessor with Castellan Launcher"
			var rocket_id: String = {"superfrag": "superfrag-rocket-launcher", "superkrak": "superkrak-rocket-launcher", "vengor": "vengor-launcher"}[rocket_launcher]
			ranged = [ranged_library["castellan-launcher"], ranged_library[rocket_id]]
			melee = [melee_library["knives-and-fists"]]
		1:
			role = "sergeant"
			source_model_name = "Kill Team Sergeant"
			ranged = [ranged_library["bolt-pistol"]]
			if sergeant_ranged == "deathwatch-bolt-rifle": ranged.append(ranged_library["deathwatch-bolt-rifle"])
			elif sergeant_ranged == "hand-flamer": ranged.append(ranged_library["hand-flamer"])
			elif sergeant_ranged == "plasma-pistol": ranged.append(ranged_library["plasma-pistol"])
			elif sergeant_ranged in ["chainsword", "power-weapon"]: pass
			melee = [melee_library[sergeant_melee]]
			if sergeant_ranged in ["chainsword", "power-weapon"]: melee.append(melee_library[sergeant_ranged])
			if grenade_launcher: ranged.append(ranged_library["grenade-launcher"])
		2, 3:
			role = "plasma-incinerator-intercessor"
			source_model_name = "Deathwatch Intercessor with Plasma Incinerator"
			ranged = [ranged_library["plasma-incinerator"], ranged_library["plasma-pistol"] if plasma_pistol else ranged_library["bolt-pistol"]]
			melee = [melee_library["knives-and-fists"]]
		4, 5:
			role = "deathwatch-bolt-rifle-intercessor"
			source_model_name = "Kill Team Intercessor with Deathwatch Bolt Rifle"
			ranged = [ranged_library["deathwatch-bolt-rifle"], ranged_library["bolt-pistol"]]
			melee = [melee_library["knives-and-fists"]]
			if grenade_launcher: ranged.append(ranged_library["grenade-launcher"])
		6, 7:
			role = "heavy-bolt-pistol-intercessor"
			source_model_name = "Kill Team Intercessor with Heavy Bolt Pistol"
			ranged = [ranged_library["heavy-bolt-pistol"]]
			melee = [melee_library["chainsword"]]
		8, 9:
			role = "pyreblaster-intercessor"
			source_model_name = "Kill Team Intercessor with Pyreblaster"
			ranged = [ranged_library["bolt-pistol"], ranged_library["pyreblaster"]]
			melee = [melee_library["knives-and-fists"]]
	return {"role": role, "source_model_name": source_model_name, "keywords": ["INFANTRY", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "DEATHWATCH"], "ranged": ranged.duplicate(true), "melee": melee.duplicate(true)}

static func indomitor_kill_team_model_loadout(model_index: int, auto_boltstorm: bool = false, heavy_bolter: bool = false, multi_melta: bool = false) -> Dictionary:
	if model_index < 0 or model_index >= 10: return {}
	if auto_boltstorm and model_index not in [0, 1, 2]: return {}
	if heavy_bolter and model_index not in [6, 7, 8, 9]: return {}
	if multi_melta and model_index not in [3, 4, 5]: return {}
	var flamestorm := {"id": "flamestorm-gauntlets", "profiles": {"standard": _weapon("Flamestorm Gauntlets", 12.0, 3, 0, 4, -1, 1, {"blast": 2, "torrent": true, "twin-linked": true}), "close-quarters": _weapon("Flamestorm Gauntlets - Close Quarters", 12.0, 3, 0, 4, -1, 1, {"close-quarters": true, "twin-linked": true, "torrent": true})}}
	var auto_gauntlets := {"id": "auto-boltstorm-gauntlets", "profiles": {"standard": _weapon("Auto Boltstorm Gauntlets", 18.0, 3, 3, 5, -1, 1, {"twin-linked": true, "close-quarters": true})}}
	var fragstorm := {"id": "fragstorm-grenade-launcher", "profiles": {"standard": _weapon("Fragstorm Grenade Launcher", 18.0, 3, 3, 4, -1, 1, {"blast": 1})}}
	var bolt_pistol := {"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
	var melta_rifle := {"id": "melta-rifle", "profiles": {"standard": _weapon("Melta Rifle", 18.0, 1, 3, 10, -3, "D3+2", {"melta": 2}), "hunter": _weapon("Melta Rifle - Hunter", 18.0, 1, 2, 12, -3, "D3+2", {"melta": 2, "hunter": ["Monster", "Vehicle"]})}}
	var multi_melta_weapon := {"id": "multi-melta", "profiles": {"standard": _weapon("Multi-melta", 18.0, 2, 3, 10, -3, "D3+2", {"melta": 3}), "hunter": _weapon("Multi-melta - Hunter", 18.0, 2, 2, 12, -3, "D3+2", {"melta": 3, "hunter": ["Monster", "Vehicle"]})}}
	var heavy_rifle := {"id": "deathwatch-heavy-bolt-rifle", "profiles": {"standard": _weapon("Deathwatch Heavy Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"assault": true, "lethal-hits": true, "heavy": true})}}
	var heavy_bolter_profile := {"id": "deathwatch-heavy-bolter", "profiles": {"standard": _weapon("Deathwatch Heavy Bolter", 36.0, 3, 3, 5, -2, 3, {"assault": true, "heavy": true, "lethal-hits": true, "sustained-hits": 1})}}
	var ceramite_fists := {"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}
	var twin_power_fists := {"id": "twin-power-fists", "profiles": {"standard": _weapon("Twin Power Fists", 0.0, 3, 3, 8, -2, 2, {"twin-linked": true})}}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var role := ""
	var source_model_name := ""
	match model_index:
		0, 1, 2:
			role = "flamestorm-heavy-intercessor"
			source_model_name = "Kill Team Heavy Intercessor with Flamestorm Gauntlets and Twin Power Fists"
			if auto_boltstorm:
				ranged.append(auto_gauntlets)
				ranged.append(fragstorm)
			else: ranged.append(flamestorm)
			melee.append(twin_power_fists)
		3, 4, 5:
			role = "melta-heavy-intercessor"
			source_model_name = "Kill Team Heavy Intercessor with Melta Rifle, Bolt Pistol and Ceramite Fists"
			ranged.append(bolt_pistol)
			ranged.append(multi_melta_weapon if multi_melta else melta_rifle)
			melee.append(ceramite_fists)
		6, 7, 8, 9:
			role = "heavy-rifle-intercessor"
			source_model_name = "Kill Team Heavy Intercessor with Deathwatch Heavy Bolt Rifle and Ceramite Fists"
			ranged.append(heavy_bolter_profile if heavy_bolter else heavy_rifle)
			melee.append(ceramite_fists)
	var stats := {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
	var keywords: Array[String] = ["INFANTRY", "KILL TEAM", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES", "DEATHWATCH"]
	return {"role": role, "source_model_name": source_model_name, "stats": stats, "base_radius_inches": 20.0 / 25.4, "keywords": keywords, "ranged": ranged.duplicate(true), "melee": melee.duplicate(true)}

static func _spectrus_instigator_bolt_carbine() -> Dictionary:
	var weapon := _weapon("Instigator Bolt Carbine", 24.0, 2, 2, 5, -2, 2, {"lethal-hits": true, "precision": true, "rapid-fire": 2})
	weapon.target_restricted_traits = {"lethal-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func spectrus_kill_team_model_loadout(model_index: int, sniper_weapon: String = "bolt-sniper-rifle", knife_replaced: bool = false, helix_gauntlet: bool = false) -> Dictionary:
	if model_index < 0 or model_index >= 10: return {}
	if sniper_weapon not in ["bolt-sniper-rifle", "las-fusil", "instigator-bolt-carbine"]: return {}
	if model_index not in [0, 1] and sniper_weapon != "bolt-sniper-rifle": return {}
	if knife_replaced and model_index not in [4, 5]: return {}
	if helix_gauntlet and model_index not in [6, 7, 8, 9]: return {}
	var ranged_library := {
		"bolt-pistol": {"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		"bolt-sniper-rifle": {"id": "bolt-sniper-rifle", "profiles": {"standard": _weapon("Bolt Sniper Rifle", 36.0, 1, 3, 6, -2, 3, {"precision": true, "heavy": true})}},
		"deathwatch-bolt-carbine": {"id": "deathwatch-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"precision": true, "lethal-hits": true})}},
		"deathwatch-marksman-bolt-carbine": {"id": "deathwatch-marksman-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"heavy": true, "lethal-hits": true})}},
		"deathwatch-occulus-bolt-carbine": {"id": "deathwatch-occulus-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Occulus Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"assault": true, "ignores-cover": true, "lethal-hits": true})}},
		"instigator-bolt-carbine": {"id": "instigator-bolt-carbine", "profiles": {"standard": _spectrus_instigator_bolt_carbine()}},
		"las-fusil": {"id": "las-fusil", "profiles": {"standard": _weapon("Las Fusil", 36.0, 1, 3, 10, -3, "D3+3", {"heavy": true})}},
		"special-issue-bolt-pistol": {"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true, "precision": true})}}
	}
	var melee_library := {
		"ceramite-fists": {"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}},
		"combat-knife": {"id": "combat-knife", "profiles": {"standard": _weapon("Combat Knife", 0.0, 4, 3, 5, -1, 1, {"precision": true})}},
		"paired-combat-blades": {"id": "paired-combat-blades", "profiles": {"standard": _weapon("Paired Combat Blades", 0.0, 3, 3, 5, -1, 1, {"sustained-hits": 1})}}
	}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var role := ""
	var source_model_name := ""
	match model_index:
		0, 1:
			role = "sniper-infiltrator"
			source_model_name = "Kill Team Infiltrator with %s, Bolt Pistol and Ceramite Fists" % str({"bolt-sniper-rifle": "Bolt Sniper Rifle", "las-fusil": "Las Fusil", "instigator-bolt-carbine": "Instigator Bolt Carbine"}[sniper_weapon])
			ranged = [ranged_library["bolt-pistol"], ranged_library[sniper_weapon]]
			melee = [melee_library["ceramite-fists"]]
		2, 3:
			role = "oculus-infiltrator"
			source_model_name = "Kill Team Infiltrator with Deathwatch Occulus Bolt Carbine, Bolt Pistol and Paired Combat Blades"
			ranged = [ranged_library["bolt-pistol"], ranged_library["deathwatch-occulus-bolt-carbine"]]
			melee = [melee_library["paired-combat-blades"]]
		4, 5:
			role = "special-issue-infiltrator"
			source_model_name = "Kill Team Infiltrator with Special-issue Bolt Pistol and Combat Knife"
			ranged = [ranged_library["special-issue-bolt-pistol"]]
			if knife_replaced: melee.append(melee_library["ceramite-fists"])
			else: melee.append(melee_library["combat-knife"])
			if knife_replaced: ranged.append(ranged_library["deathwatch-bolt-carbine"])
		6, 7, 8, 9:
			role = "marksman-infiltrator"
			source_model_name = "Kill Team Infiltrator with Deathwatch Marksman Bolt Carbine, Bolt Pistol and Ceramite Fists"
			ranged = [ranged_library["bolt-pistol"]]
			if not helix_gauntlet: ranged.append(ranged_library["deathwatch-marksman-bolt-carbine"])
			melee = [melee_library["ceramite-fists"]]
	var stats := {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
	var keywords: Array[String] = ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "IMPERIUM", "SMOKE", "EXPLOSIVES", "KILL TEAM", "PHOBOS"]
	return {"role": role, "source_model_name": source_model_name, "stats": stats, "base_radius_inches": 16.0 / 25.4, "keywords": keywords, "ranged": ranged.duplicate(true), "melee": melee.duplicate(true), "helix_gauntlet": helix_gauntlet}

static func decimus_kill_team_model_loadout(role: String, gravis_weapon: String = "infernus-heavy-bolter", storm_shield: bool = false, plasma_incinerator: bool = false) -> Dictionary:
	if role not in ["xenophase-veteran", "sergeant", "marksman-veteran", "heavy-veteran", "stalker-veteran", "gravis-veteran"]: return {}
	if gravis_weapon not in ["infernus-heavy-bolter", "frag-cannon", "hellstorm-bolt-rifle"]: return {}
	if storm_shield and role != "heavy-veteran": return {}
	if plasma_incinerator and role != "stalker-veteran": return {}
	var pistol := {"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
	var special_pistol := {"id": "special-issue-bolt-pistol", "profiles": {"standard": _weapon("Special-issue Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true, "precision": true, "lethal-hits": true})}}
	var marksman_carbine := {"id": "deathwatch-marksman-bolt-carbine", "profiles": {"standard": _weapon("Deathwatch Marksman Bolt Carbine", 24.0, 2, 3, 5, -1, 1, {"lethal-hits": true, "heavy": true})}}
	var frag_cannon := {"id": "frag-cannon", "profiles": {"standard": _weapon("Frag Cannon", 18.0, 2, 3, 7, -2, 2, {"lethal-hits": true, "blast": 1, "heavy": true, "rapid-fire": 1})}}
	var grenade_launcher := {"id": "grenade-launcher", "profiles": {"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}), "krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}}
	var hellstorm_rifle := {"id": "hellstorm-bolt-rifle", "profiles": {"standard": _weapon("Hellstorm Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"lethal-hits": true, "assault": true, "heavy": true})}}
	var infernus_bolter := {"id": "infernus-heavy-bolter", "profiles": {"bolt": _weapon("Infernus Heavy Bolter - Bolt", 36.0, 3, 3, 5, -1, 2, {"rapid-fire": 2, "heavy": true, "sustained-hits": 1}), "infernus": _weapon("Infernus Heavy Bolter - Infernus", 12.0, 3, 0, 5, -1, 1, {"blast": 1, "torrent": true})}}
	var plasma_rifle := {"id": "plasma-incinerator", "profiles": {"standard": _weapon("Plasma Incinerator - Standard", 24.0, 2, 3, 7, -2, 2, {"assault": true, "rapid-fire": 1}), "supercharge": _weapon("Plasma Incinerator - Supercharge", 24.0, 2, 3, 8, -3, 2, {"hazardous": true, "rapid-fire": 1, "assault": true})}}
	var plasma_pistol := {"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
	var stalker_rifle := {"id": "stalker-bolt-rifle", "profiles": {"standard": _weapon("Stalker Bolt Rifle", 30.0, 2, 3, 5, -2, 2, {"precision": true, "heavy": true, "lethal-hits": true})}}
	var hammer := {"id": "heavy-thunder-hammer", "profiles": {"standard": _weapon("Heavy Thunder Hammer", 0.0, 3, 4, 10, -2, 3, {"devastating-wounds": true})}}
	var knives := {"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}}
	var power_weapon := {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {"sustained-hits": 1})}}
	var xenophase := {"id": "xenophase-blade", "profiles": {"standard": _weapon("Xenophase Blade", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var source_model_name := ""
	var stats := {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
	var base_radius := 16.0 / 25.4
	var keywords: Array[String] = ["INFANTRY", "BATTLELINE", "KILL TEAM", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "DEATHWATCH"]
	match role:
		"xenophase-veteran":
			source_model_name = "Deathwatch Veteran with Xenophase Blade and Special-issue Bolt Pistol"
			ranged = [special_pistol]
			melee = [xenophase]
		"sergeant":
			source_model_name = "Kill Team Sergeant"
			ranged = [plasma_pistol]
			melee = [power_weapon]
		"marksman-veteran":
			source_model_name = "Deathwatch Veteran with Deathwatch Marksman Bolt Carbine"
			ranged = [marksman_carbine, special_pistol]
			melee = [knives]
		"heavy-veteran":
			source_model_name = "Deathwatch Veteran with Heavy Thunder Hammer and Bolt Pistol"
			ranged = [pistol]
			melee = [power_weapon if storm_shield else hammer]
		"stalker-veteran":
			source_model_name = "Deathwatch Veteran with Stalker Bolt Rifle"
			ranged = [pistol, plasma_rifle if plasma_incinerator else stalker_rifle]
			melee = [knives]
		"gravis-veteran":
			source_model_name = "Gravis Veteran"
			stats = {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
			base_radius = 20.0 / 25.4
			keywords.append("GRAVIS")
			ranged = [pistol]
			match gravis_weapon:
				"infernus-heavy-bolter": ranged.append(infernus_bolter)
				"frag-cannon": ranged.append(frag_cannon)
				"hellstorm-bolt-rifle":
					ranged.append(hellstorm_rifle)
					ranged.append(grenade_launcher)
			melee = [knives]
	return {"role": role, "source_model_name": source_model_name, "stats": stats, "base_radius_inches": base_radius, "keywords": keywords, "ranged": ranged.duplicate(true), "melee": melee.duplicate(true), "storm_shield": storm_shield}

static func talonstrike_kill_team_model_loadout(model_index: int, sergeant_melee: String = "chainsword", sergeant_ranged: String = "heavy-bolt-pistol", intercessor_plasma_pistol: bool = false, plasma_exterminator: bool = false) -> Dictionary:
	if model_index < 0 or model_index >= 10: return {}
	if sergeant_melee not in ["chainsword", "power-fist", "power-weapon"]: return {}
	if sergeant_ranged not in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]: return {}
	if intercessor_plasma_pistol and model_index not in [5, 6, 7, 8, 9]: return {}
	if plasma_exterminator and model_index not in [1, 2, 3, 4]: return {}
	var ranged_library := {
		"assault-bolters": {"id": "assault-bolters", "profiles": {"standard": _weapon("Assault Bolters", 18.0, 3, 3, 5, -1, 2, {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true})}},
		"hand-flamer": {"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
		"heavy-bolt-pistol": {"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}},
		"plasma-exterminators": {"id": "plasma-exterminators", "profiles": {"standard": _weapon("Plasma Exterminators - Standard", 18.0, 2, 3, 7, -2, 2, {"twin-linked": true, "assault": true, "close-quarters": true}), "supercharge": _weapon("Plasma Exterminators - Supercharge", 18.0, 2, 3, 8, -3, 3, {"close-quarters": true, "assault": true, "hazardous": true, "twin-linked": true})}},
		"plasma-pistol": {"id": "plasma-pistol", "profiles": {"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}), "supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"close-quarters": true, "hazardous": true})}}
	}
	var melee_library := {
		"ceramite-fists": {"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}},
		"chainsword": {"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}},
		"power-fist": {"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
		"power-weapon": {"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
	}
	var role := ""
	var source_model_name := ""
	var movement := 12
	var toughness := 5
	var wounds := 2
	var base_mm := 32
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	match model_index:
		0:
			role = "sergeant"
			source_model_name = "Kill Team Sergeant with Jump Pack"
			match sergeant_ranged:
				"heavy-bolt-pistol": ranged = [ranged_library["heavy-bolt-pistol"]]
				"hand-flamer": ranged = [ranged_library["hand-flamer"]]
				"plasma-pistol": ranged = [ranged_library["plasma-pistol"]]
			melee = [melee_library[sergeant_melee]]
		1, 2, 3, 4:
			role = "heavy-intercessor"
			source_model_name = "Kill Team Heavy Intercessor with Jump Pack"
			movement = 10
			toughness = 6
			wounds = 3
			base_mm = 40
			ranged = [ranged_library["plasma-exterminators"] if plasma_exterminator else ranged_library["assault-bolters"]]
			melee = [melee_library["ceramite-fists"]]
		_:
			role = "intercessor"
			source_model_name = "Kill Team Intercessor with Jump Pack"
			var pistol_id := "plasma-pistol" if intercessor_plasma_pistol else "heavy-bolt-pistol"
			ranged = [ranged_library[pistol_id]]
			melee = [melee_library["chainsword"]]
	var stats := {"movement_inches": movement, "toughness": toughness, "save_target": 3, "wounds": wounds, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
	var keywords: Array[String] = ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "KILL TEAM", "EXPLOSIVES", "JUMP PACK", "FLY", "IMPERIUM", "GRAVIS", "TACTICUS"]
	return {"role": role, "source_model_name": source_model_name, "stats": stats, "base_size_source_mm": base_mm, "base_radius_inches": float(base_mm) / 50.8, "keywords": keywords, "ranged": ranged.duplicate(true), "melee": melee.duplicate(true)}

static func decimus_kill_team_composition_options() -> Array[Dictionary]:
	var role_ids := ["marksman-veteran", "heavy-veteran", "stalker-veteran", "gravis-veteran"]
	var ten_roles: Array[String] = ["xenophase-veteran", "sergeant"]
	for role: String in role_ids:
		ten_roles.append(role)
		ten_roles.append(role)
	return [{"id": "ten-balanced", "models": 10, "label": "10 models: Xenophase Veteran + Sergeant + 2 of each specialist", "roles": ten_roles}]

static func crusader_squad_loadout_options(model_index: int, model_count: int) -> Array[String]:
	if model_count not in [10, 20] or model_index < 0 or model_index >= model_count: return []
	if model_index == 0: return ["default", "hand-flamer"]
	if model_index <= (4 if model_count == 10 else 8): return ["default", "shotgun"]
	return ["default", "pistol-chainsword", "heavy-pistol-power-fist", "pyreblaster"]

static func crusader_squad_model_loadout(model_index: int, model_count: int, loadout_id: String = "default") -> Dictionary:
	if model_count not in [10, 20] or model_index < 0 or model_index >= model_count: return {}
	var role := "Sword Brother" if model_index == 0 else "Neophyte" if model_index <= (4 if model_count == 10 else 8) else "Initiate"
	if loadout_id not in crusader_squad_loadout_options(model_index, model_count): return {}
	var profile_record := profile("crusader-squad")
	var pistol: Dictionary = profile_record.ranged[0].duplicate(true)
	var close_combat: Dictionary = profile_record.melee[0].duplicate(true)
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var stats := {"toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
	var heavy_pistol := additional_weapon("crusader-squad", "ranged", "heavy-bolt-pistol")
	var mastercrafted := additional_weapon("crusader-squad", "melee", "master-crafted-power-weapon")
	match role:
		"Sword Brother":
			ranged = [additional_weapon("crusader-squad", "ranged", "hand-flamer") if loadout_id == "hand-flamer" else heavy_pistol]
			melee = [mastercrafted]
		"Neophyte":
			stats.toughness = 4
			stats.save_target = 4
			if loadout_id == "shotgun":
				ranged = [additional_weapon("crusader-squad", "ranged", "shotgun")]
				melee = [additional_weapon("crusader-squad", "melee", "combat-knife")]
			else:
				ranged = [pistol]
				melee = [additional_weapon("crusader-squad", "melee", "neophyte-chainsword")]
		"Initiate":
			melee = [close_combat]
			match loadout_id:
				"default":
					ranged = [pistol, additional_weapon("crusader-squad", "ranged", "bolt-rifle")]
				"pistol-chainsword":
					ranged = [pistol, heavy_pistol]
					melee.append(additional_weapon("crusader-squad", "melee", "initiate-chainsword"))
				"heavy-pistol-power-fist":
					ranged = [pistol, heavy_pistol]
					melee.append(additional_weapon("crusader-squad", "melee", "power-fist"))
				"pyreblaster":
					ranged = [pistol, additional_weapon("crusader-squad", "ranged", "pyreblaster")]
	return {"role": role, "loadout_id": loadout_id, "stats": stats, "ranged": ranged, "melee": melee}

static func sword_brethren_loadout_options(model_index: int, model_count: int) -> Array[String]:
	if model_count not in [4, 5, 9, 10] or model_index < 0 or model_index >= model_count: return []
	return ["default", "hand-flamer-chainsword", "hand-flamer-power-weapon", "hand-flamer-thunder-hammer",
		"plasma-pistol-chainsword", "plasma-pistol-power-weapon", "plasma-pistol-thunder-hammer",
		"heavy-pistol-power-weapon", "heavy-pistol-thunder-hammer", "twin-lightning-claws"]

static func sword_brethren_loadout_limits_valid(loadout_ids: Array, model_count: int) -> bool:
	if model_count not in [4, 5, 9, 10] or loadout_ids.size() != model_count: return false
	var group_count := int(model_count / 4)
	var hand_flamers := 0
	var plasma_pistols := 0
	var thunder_hammers := 0
	var lightning_claws := 0
	for loadout_value: Variant in loadout_ids:
		var loadout_id := str(loadout_value)
		if loadout_id not in ["default", "hand-flamer-chainsword", "hand-flamer-power-weapon", "hand-flamer-thunder-hammer",
			"plasma-pistol-chainsword", "plasma-pistol-power-weapon", "plasma-pistol-thunder-hammer",
			"heavy-pistol-power-weapon", "heavy-pistol-thunder-hammer", "twin-lightning-claws"]: return false
		if loadout_id.begins_with("hand-flamer-"): hand_flamers += 1
		if loadout_id.begins_with("plasma-pistol-"): plasma_pistols += 1
		if loadout_id.ends_with("thunder-hammer"): thunder_hammers += 1
		if loadout_id == "twin-lightning-claws": lightning_claws += 1
	return hand_flamers <= group_count * 2 and plasma_pistols <= group_count and thunder_hammers <= group_count and lightning_claws <= group_count

static func sword_brethren_model_loadout(model_index: int, model_count: int, loadout_id: String = "default") -> Dictionary:
	if loadout_id not in sword_brethren_loadout_options(model_index, model_count): return {}
	var profile_record := profile("sword-brethren-squad")
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var pistol_id := "heavy-bolt-pistol"
	var melee_id := "chainsword"
	match loadout_id:
		"hand-flamer-chainsword", "hand-flamer-power-weapon", "hand-flamer-thunder-hammer": pistol_id = "hand-flamer"
		"plasma-pistol-chainsword", "plasma-pistol-power-weapon", "plasma-pistol-thunder-hammer": pistol_id = "plasma-pistol"
		"twin-lightning-claws": pistol_id = ""
	if loadout_id.ends_with("power-weapon"): melee_id = "master-crafted-power-weapon"
	elif loadout_id.ends_with("thunder-hammer"): melee_id = "thunder-hammer"
	elif loadout_id == "twin-lightning-claws": melee_id = "twin-lightning-claws"
	if pistol_id == "heavy-bolt-pistol": ranged.append(profile_record.ranged[0].duplicate(true))
	elif not pistol_id.is_empty(): ranged.append(additional_weapon("sword-brethren-squad", "ranged", pistol_id))
	if melee_id == "chainsword": melee.append(profile_record.melee[0].duplicate(true))
	else: melee.append(additional_weapon("sword-brethren-squad", "melee", melee_id))
	return {"role": "Sword Brethren", "loadout_id": loadout_id, "ranged": ranged, "melee": melee}

static func wardens_model_loadout(model_index: int) -> Dictionary:
	var stats: Dictionary
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	var source_base_sizes_mm := [28.5, 40.0, 28.5, 28.5, 28.5, 40.0]
	var model_keywords: Array[String] = []
	if model_index == 2: model_keywords.append("PSYKER")
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
			stats = {"toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}
			ranged = [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}]
			melee = [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {"precision": true})}}]
		_: return {}
	var source_model_names := ["Aemelia Minervas", "Ancient Gadriel", "Dainal Komelius", "Gaius Silva", "Lucia Vestha", "Veteran Sergeant Metaurus"]
	var source_loadout_name: String = "Dainal Kornelius" if model_index == 2 else source_model_names[model_index]
	return {"stats": stats, "ranged": ranged, "melee": melee, "keywords": model_keywords, "base_size_source_mm": source_base_sizes_mm[model_index], "base_radius_inches": float(source_base_sizes_mm[model_index]) / 50.8, "source_model_name": source_model_names[model_index], "source_loadout_name": source_loadout_name}

static func victrix_honour_guard_model_loadout(model_index: int) -> Dictionary:
	var carbine := {"id": "master-crafted-bolt-carbine", "profiles": {"standard": _weapon("Master-crafted Bolt Carbine", 24.0, 2, 2, 5, -1, 2, {"rapid-fire": 1, "assault": true})}}
	var power_weapon := {"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 5, 2, 5, -2, 2, {})}}
	var blades := {"id": "blades-of-honour", "profiles": {"standard": _weapon("Blades of Honour", 0.0, 6, 2, 6, -2, 2, {"twin-linked": true, "precision": true})}}
	match model_index:
		0: return {"role": "chapter-ancient", "source_model_name": "Chapter Ancient", "ranged": [carbine.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES", "EPIC HERO", "ANCIENT"]}
		1: return {"role": "chapter-champion", "source_model_name": "Chapter Champion", "ranged": [], "melee": [blades.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES", "EPIC HERO", "CHAMPION"]}
		_: return {"role": "victrix-honour-guard", "source_model_name": "Victrix Honour Guard", "ranged": [carbine.duplicate(true)], "melee": [power_weapon.duplicate(true)], "keywords": ["INFANTRY", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"]}

static func victrix_honour_guard_composition_options() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_count in [3, 6]:
		for include_ancient in [false, true]:
			for include_champion in [false, true]:
				var guard_count := int(model_count) - int(include_ancient) - int(include_champion)
				if guard_count < 1: continue
				var roles: Array[String] = []
				if include_ancient: roles.append("chapter-ancient")
				if include_champion: roles.append("chapter-champion")
				for _guard in range(guard_count): roles.append("victrix-honour-guard")
				var role_names: Array[String] = []
				if include_ancient: role_names.append("Ancient")
				if include_champion: role_names.append("Champion")
				role_names.append("%d Guard%s" % [guard_count, "s" if guard_count != 1 else ""])
				var id := "guards-only"
				if include_ancient and include_champion: id = "ancient-champion"
				elif include_ancient: id = "ancient"
				elif include_champion: id = "champion"
				result.append({"id": id, "models": int(model_count), "label": " + ".join(role_names), "roles": roles, "wargear_cost": 15 if include_ancient else 0})
	return result

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

static func _death_company_blood_talons() -> Dictionary:
	var weapon := {"id": "blood-talons", "profiles": {"standard": _weapon("Blood Talons", 0.0, 8, 3, 10, -2, 2, {"sustained-hits": 1, "twin-linked": true, "cleave": 2})}}
	weapon.profiles.standard.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"]}
	return weapon

static func _death_company_heavy_bolt_pistol() -> Dictionary:
	return {"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}

static func _death_company_chainsword() -> Dictionary:
	return {"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}

static func _death_company_optional_ranged(jump_packs: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not jump_packs:
		result.append({"id": "bolt-rifle-fire", "profiles": {
			"focused-fire": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"heavy": true, "rapid-fire": 1}),
			"saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 1})}})
		result.append({"id": "grenade-launcher", "profiles": {
			"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}),
			"krak": _weapon("Grenade Launcher - Krak", 24.0, 2, 3, 10, -2, 3, {"rapid-fire": 1})}})
	result.append_array([
		{"id": "hand-flamer", "profiles": {"standard": _weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})}},
		{"id": "inferno-pistol", "profiles": {"standard": _weapon("Inferno Pistol", 9.0, 1, 3, 8, -3, "D3+2", {"melta": 1, "close-quarters": true})}},
		{"id": "plasma-pistol", "profiles": {
			"standard": _weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
			"supercharge": _weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"hazardous": true, "close-quarters": true})}}
	])
	return result

static func _death_company_optional_melee(jump_packs: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not jump_packs: result.append({"id": "combat-blade", "profiles": {"standard": _weapon("Combat Blade", 0.0, 3, 3, 5, 0, 1, {})}})
	result.append_array([
		{"id": "eviscerator", "profiles": {"standard": _weapon("Eviscerator", 0.0, 3, 3, 7, -2, 2, {"cleave": 1})}},
		{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}},
		{"id": "power-weapon", "profiles": {"standard": _weapon("Power Weapon", 0.0, 4, 3, 5, -2, 1, {})}}
	])
	if not jump_packs: result.append({"id": "thunder-hammer", "profiles": {"standard": _weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}})
	return result

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

static func assault_intercessor_sergeant_pistol(kind: String) -> Dictionary:
	if kind == "heavy-bolt-pistol": return profile("assault-intercessor-squad").ranged[0].duplicate(true)
	return additional_weapon("assault-intercessor-squad", "ranged", kind)

static func assault_intercessor_sergeant_melee(kind: String) -> Dictionary:
	if kind == "chainsword": return profile("assault-intercessor-squad").melee[0].duplicate(true)
	return additional_weapon("assault-intercessor-squad", "melee", kind)

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

static func vanguard_veteran_squad_weapons(loadout: String = "bolt-pistol") -> Dictionary:
	var data := profile("vanguard-veteran-squad")
	if data.is_empty() or loadout not in data.get("options", {}).get("pistol_replacements", []): return {}
	var ranged: Array[Dictionary] = []
	var shield := loadout == "storm-shield"
	if not shield:
		var pistol := _profile_weapon(data, "ranged", loadout)
		if pistol.is_empty(): return {}
		ranged.append(pistol)
	var melee := [_profile_weapon(data, "melee", "heirloom-weapon")]
	if melee.has({}): return {}
	return {"ranged": ranged, "melee": melee, "invulnerable_target": 4 if shield else 0}

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
	if kind == "carbine":
		var stats := _weapon("Instigator Bolt Carbine", 24.0, 2, 2, 5, -2, 2, {"lethal-hits": true, "rapid-fire": 2, "precision": true})
		stats.target_restricted_traits = {"lethal-hits": ["MONSTER", "VEHICLE"]}
		return {"id": "instigator-bolt-carbine", "profiles": {"standard": stats}}
	return profile("eliminator-squad").ranged[0].duplicate(true)

static func sternguard_gun(kind: String) -> Dictionary:
	if kind == "heavy": return {"id": "heavy-bolter", "profiles": {"standard": _weapon("Heavy Bolter", 36.0, 3, 3, 5, -1, 2, {"heavy": true, "rapid-fire": 2, "sustained-hits": 1})}}
	if kind == "pyre": return {"id": "pyrecannon", "profiles": {"standard": _weapon("Pyrecannon", 12.0, 4, 0, 6, -1, 1, {"blast": 2, "torrent": true})}}
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
	if ranged_loadout == "relic-shield" and fist: return {}
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

static func blood_angels_captain_weapons(pistol_package: String = "heavy-bolt-pistol", melee_package: String = "master-crafted-chainsword") -> Dictionary:
	var data := profile("blood-angels-captain")
	if data.is_empty() or pistol_package not in data.get("options", {}).get("ranged_packages", []) or melee_package not in data.get("options", {}).get("melee_packages", []): return {}
	var ranged: Array = data.ranged.duplicate(true) if pistol_package == "heavy-bolt-pistol" else [additional_weapon("blood-angels-captain", "ranged", pistol_package)]
	var melee: Array = data.melee.duplicate(true) if melee_package == "master-crafted-chainsword" else [additional_weapon("blood-angels-captain", "melee", melee_package)]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func death_company_captain_weapons(pistol_package: String = "heavy-bolt-pistol", melee_package: String = "master-crafted-chainsword") -> Dictionary:
	var data := profile("death-company-captain")
	if data.is_empty() or pistol_package not in data.get("options", {}).get("ranged_packages", []) or melee_package not in data.get("options", {}).get("melee_packages", []): return {}
	var ranged: Array = data.ranged.duplicate(true) if pistol_package == "heavy-bolt-pistol" else [additional_weapon("death-company-captain", "ranged", pistol_package)]
	var melee: Array = data.melee.duplicate(true) if melee_package == "master-crafted-chainsword" else [additional_weapon("death-company-captain", "melee", melee_package)]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee}

static func death_company_jump_captain_weapons(loadout: String = "default") -> Dictionary:
	var data := profile("death-company-captain-with-jump-pack")
	if data.is_empty() or loadout not in data.get("options", {}).get("loadout_packages", []): return {}
	var ranged: Array = []
	var melee: Array = []
	var shield := false
	var pistol := "heavy-bolt-pistol"
	var blade := "chainsword"
	match loadout:
		"default": pass
		"thunder-hammer-shield":
			pistol = "none"
			blade = "thunder-hammer"
			shield = true
		"chainsword-shield":
			pistol = "none"
			shield = true
		_:
			var parts := loadout.split("-", false)
			if parts.size() < 3: return {}
			blade = parts[parts.size() - 2] + "-" + parts[parts.size() - 1]
			pistol = "-".join(parts.slice(0, parts.size() - 2))
	if pistol != "none":
		if pistol == "heavy-bolt-pistol": ranged = data.ranged.duplicate(true)
		else: ranged = [additional_weapon("death-company-captain-with-jump-pack", "ranged", pistol)]
	if blade == "chainsword": melee = data.melee.duplicate(true)
	else: melee = [additional_weapon("death-company-captain-with-jump-pack", "melee", blade)]
	if ranged.has({}) or melee.has({}): return {}
	return {"ranged": ranged, "melee": melee, "relic_shield": shield}

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

static func scout_bike_sergeant_option_label(option: String) -> String:
	var labels := {"bolt-pistol": "Bolt Pistol", "boltgun": "Boltgun", "combi-weapon": "Combi-weapon", "chainsword": "Chainsword", "grav-pistol": "Grav-pistol", "hand-flamer": "Hand Flamer", "inferno-pistol": "Inferno Pistol", "plasma-pistol": "Plasma Pistol", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "storm-bolter": "Storm Bolter", "thunder-hammer": "Thunder Hammer"}
	return str(labels.get(option, ""))

static func scout_bike_squad_weapons(grenade_launcher: bool = false, sergeant_option: String = "bolt-pistol") -> Dictionary:
	var data := profile("scout-bike-squad")
	var legal_options: Array[String] = ["bolt-pistol", "boltgun", "combi-weapon", "chainsword", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol", "power-fist", "power-weapon", "storm-bolter", "thunder-hammer"]
	if data.is_empty() or sergeant_option not in legal_options: return {}
	var ranged: Array = data.ranged.duplicate(true)
	var melee: Array = data.melee.duplicate(true)
	if grenade_launcher:
		var launcher := additional_weapon("scout-bike-squad", "ranged", "grenade-launcher")
		if launcher.is_empty(): return {}
		ranged[2] = launcher
	if sergeant_option != "bolt-pistol":
		ranged.remove_at(0)
		var sidearm := additional_weapon("scout-bike-squad", "ranged", sergeant_option)
		if sergeant_option in ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]:
			sidearm = additional_weapon("scout-bike-squad", "melee", sergeant_option)
			if sidearm.is_empty(): return {}
			melee.append(sidearm)
		else:
			if sidearm.is_empty(): return {}
			ranged.insert(0, sidearm)
	return {"ranged": ranged, "melee": melee}

static func ravenwing_black_knight_weapons(grenade_launcher: bool = false) -> Dictionary:
	var data := profile("ravenwing-black-knights")
	var ranged: Array = data.ranged.duplicate(true)
	if grenade_launcher: ranged[1] = data.additional_weapon_profiles.ranged[0].duplicate(true)
	return {"ranged": ranged, "melee": data.melee.duplicate(true)}

static func sanguinary_guard_weapons(inferno_pistol: bool = false) -> Dictionary:
	var data := profile("sanguinary-guard")
	if data.is_empty(): return {}
	var ranged: Array = data.ranged.duplicate(true)
	if inferno_pistol: ranged[0] = data.additional_weapon_profiles.ranged[0].duplicate(true)
	return {"ranged": ranged, "melee": data.melee.duplicate(true)}

static func sanguinary_guard_inferno_limit(model_count: int) -> int:
	return floori(float(model_count) / 3.0) if model_count in [3, 6] else 0

static func sanguinary_guard_loadouts_valid(loadouts: Array[String], model_count: int) -> bool:
	if model_count not in [3, 6] or loadouts.size() != model_count: return false
	var inferno_count := 0
	for loadout: String in loadouts:
		if loadout == "inferno-pistol": inferno_count += 1
		elif loadout != "angelus-boltgun": return false
	return inferno_count <= sanguinary_guard_inferno_limit(model_count)

static func ravenwing_command_model_loadout(role: String, grenade_launcher: bool = false) -> Dictionary:
	var ranged: Array = [{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}]
	if grenade_launcher:
		ranged.append({"id": "grenade-launcher", "profiles": {
			"frag": _weapon("Grenade Launcher - Frag", 24.0, 4, 3, 4, -1, 1, {"blast": 1}),
			"krak": _weapon("Grenade Launcher - Krak", 24.0, 1, 3, 10, -2, 3, {"rapid-fire": 1})}})
	else:
		ranged.append({"id": "plasma-talon", "profiles": {
			"standard": _weapon("Plasma Talon - Standard", 18.0, 2, 3, 7, -2, 1, {"rapid-fire": 1}),
			"supercharge": _weapon("Plasma Talon - Supercharge", 18.0, 2, 3, 8, -3, 2, {"rapid-fire": 1, "hazardous": true})}})
	var melee := [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}] if role == "Ravenwing Champion" else [{"id": "corvus-hammers", "profiles": {"standard": _weapon("Corvus Hammers", 0.0, 4, 3, 5, -2, 1, {"devastating-wounds": true})}}]
	return {"role": role, "ranged": ranged, "melee": melee}

static func ravenwing_command_weapons(role: String, grenade_launcher: bool = false) -> Dictionary:
	var loadout := ravenwing_command_model_loadout(role, grenade_launcher)
	return {"ranged": loadout.ranged, "melee": loadout.melee}

static func nephilim_jetfighter_weapons(lascannons: bool = false) -> Array[Dictionary]:
	var data := profile("nephilim-jetfighter")
	if data.is_empty(): return []
	var result: Array[Dictionary] = [data.ranged[0].duplicate(true), data.ranged[1].duplicate(true)]
	result.append(data.additional_weapon_profiles.ranged[0].duplicate(true) if lascannons else data.ranged[2].duplicate(true))
	return result

static func stormhawk_interceptor_weapons(icarus_stormcannon: bool = false, skyhammer_replacement: String = "skyhammer-missile-launcher") -> Array[Dictionary]:
	var data := profile("stormhawk-interceptor")
	if data.is_empty(): return []
	var ranged: Array[Dictionary] = []
	for weapon: Dictionary in data.get("ranged", []): ranged.append(weapon.duplicate(true))
	var additional: Array = data.get("additional_weapon_profiles", {}).get("ranged", [])
	for index in range(ranged.size()):
		if str(ranged[index].get("id", "")) == "las-talon" and icarus_stormcannon:
			for option: Dictionary in additional:
				if str(option.get("id", "")) == "icarus-stormcannon": ranged[index] = option.duplicate(true)
		if str(ranged[index].get("id", "")) == "skyhammer-missile-launcher" and skyhammer_replacement != "skyhammer-missile-launcher":
			for option: Dictionary in additional:
				if str(option.get("id", "")) == skyhammer_replacement: ranged[index] = option.duplicate(true)
	return ranged

static func stormtalon_gunship_weapons(skyhammer_replacement: String = "skyhammer-missile-launcher") -> Array[Dictionary]:
	var data := profile("stormtalon-gunship")
	if data.is_empty(): return []
	var ranged: Array[Dictionary] = []
	for weapon: Dictionary in data.get("ranged", []): ranged.append(weapon.duplicate(true))
	if skyhammer_replacement == "skyhammer-missile-launcher": return ranged
	for replacement: Dictionary in data.get("additional_weapon_profiles", {}).get("ranged", []):
		if str(replacement.get("id", "")) == skyhammer_replacement:
			for index in range(ranged.size()):
				if str(ranged[index].get("id", "")) == "skyhammer-missile-launcher": ranged[index] = replacement.duplicate(true)
			return ranged
	return []

static func cerberus_weapons(optional_weapon: String = "none", optional_pair: String = "none") -> Dictionary:
	if optional_weapon not in ["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]: return {}
	if optional_pair not in ["none", "two-heavy-bolters", "two-lascannons"]: return {}
	var data := profile("cerberus")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	for weapon: Dictionary in data.get("ranged", []): ranged.append(weapon.duplicate(true))
	var additional: Array = data.get("additional_weapon_profiles", {}).get("ranged", [])
	if optional_weapon != "none":
		for weapon: Dictionary in additional:
			if str(weapon.get("id", "")) == optional_weapon: ranged.append(weapon.duplicate(true))
	if optional_pair != "none":
		var pair_id := "heavy-bolter" if optional_pair == "two-heavy-bolters" else "lascannon"
		for weapon: Dictionary in additional:
			if str(weapon.get("id", "")) == pair_id:
				ranged.append(weapon.duplicate(true))
				ranged.append(weapon.duplicate(true))
	if ranged.size() != 1 + int(optional_weapon != "none") + 2 * int(optional_pair != "none"): return {}
	return {"ranged": ranged, "melee": data.get("melee", []).duplicate(true)}

static func dreadnought_weapons(primary: String = "assault-cannon", melee_package: String = "dreadnought-fist", secondary: String = "none") -> Dictionary:
	if primary not in ["assault-cannon", "heavy-plasma-cannon", "multi-melta", "twin-lascannon"]: return {}
	if melee_package not in ["dreadnought-fist", "crushing-feet"]: return {}
	if secondary not in ["none", "heavy-flamer"]: return {}
	if melee_package == "crushing-feet" and secondary != "none": return {}
	var data := profile("dreadnought")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = []
	for weapon: Dictionary in data.ranged:
		if str(weapon.get("id", "")) == primary: ranged.append(weapon.duplicate(true))
	if primary != "assault-cannon":
		for weapon: Dictionary in data.additional_weapon_profiles.ranged:
			if str(weapon.get("id", "")) == primary: ranged.append(weapon.duplicate(true))
	if melee_package == "dreadnought-fist":
		melee.append(data.melee[0].duplicate(true))
		var secondary_id := "storm-bolter" if secondary == "none" else "heavy-flamer"
		for weapon: Dictionary in data.additional_weapon_profiles.ranged:
			if str(weapon.get("id", "")) == secondary_id: ranged.append(weapon.duplicate(true))
	else:
		for weapon: Dictionary in data.additional_weapon_profiles.ranged:
			if str(weapon.get("id", "")) == "missile-launcher": ranged.append(weapon.duplicate(true))
		for weapon: Dictionary in data.additional_weapon_profiles.melee:
			if str(weapon.get("id", "")) == "crushing-feet": melee.append(weapon.duplicate(true))
	if ranged.size() != 2 or melee.size() != 1: return {}
	return {"ranged": ranged, "melee": melee}

static func venerable_dreadnought_legends_weapons(primary: String = "assault-cannon", package: String = "fist-and-storm-bolter") -> Dictionary:
	if primary not in ["assault-cannon", "dreadnought-inferno-cannon", "heavy-plasma-cannon", "multi-melta", "twin-autocannon", "twin-heavy-bolter", "twin-heavy-flamer", "twin-lascannon"]: return {}
	if package not in ["fist-and-storm-bolter", "heavy-flamer-and-fist", "missile-launcher", "twin-autocannon"]: return {}
	var data := profile("venerable-dreadnought-legends")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	var melee: Array[Dictionary] = [data.melee[0].duplicate(true)]
	if primary == "assault-cannon":
		for weapon: Dictionary in data.ranged:
			if str(weapon.get("id", "")) == primary: ranged.append(weapon.duplicate(true))
	else:
		for weapon: Dictionary in data.additional_weapon_profiles.ranged:
			if str(weapon.get("id", "")) == primary: ranged.append(weapon.duplicate(true))
	match package:
		"fist-and-storm-bolter":
			ranged.append(data.ranged[1].duplicate(true))
			melee.append(data.melee[1].duplicate(true))
		"heavy-flamer-and-fist":
			for weapon: Dictionary in data.additional_weapon_profiles.ranged:
				if str(weapon.get("id", "")) == "heavy-flamer": ranged.append(weapon.duplicate(true))
			melee.append(data.melee[1].duplicate(true))
		"missile-launcher", "twin-autocannon":
			var replacement_id := str(package)
			for weapon: Dictionary in data.additional_weapon_profiles.ranged:
				if str(weapon.get("id", "")) == replacement_id: ranged.append(weapon.duplicate(true))
	if ranged.size() != 2 or melee.size() != (1 if package in ["missile-launcher", "twin-autocannon"] else 2): return {}
	return {"ranged": ranged, "melee": melee, "primary": primary, "package": package}

static func typhon_weapons(sponsons: String = "none", hull_weapon: String = "none") -> Dictionary:
	if sponsons not in ["none", "two-heavy-bolters", "two-lascannons"]: return {}
	if hull_weapon not in ["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]: return {}
	var data := profile("typhon")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	for weapon: Dictionary in data.get("ranged", []): ranged.append(weapon.duplicate(true))
	var additional: Array = data.get("additional_weapon_profiles", {}).get("ranged", [])
	if hull_weapon != "none":
		for weapon: Dictionary in additional:
			if str(weapon.get("id", "")) == hull_weapon: ranged.append(weapon.duplicate(true))
	if sponsons != "none":
		var sponson_id := "heavy-bolter" if sponsons == "two-heavy-bolters" else "lascannon"
		for weapon: Dictionary in additional:
			if str(weapon.get("id", "")) == sponson_id:
				ranged.append(weapon.duplicate(true))
				ranged.append(weapon.duplicate(true))
	if ranged.size() != 1 + int(hull_weapon != "none") + 2 * int(sponsons != "none"): return {}
	return {"ranged": ranged, "melee": data.get("melee", []).duplicate(true)}

static func falchion_weapons(optional_weapon: String = "none", main_armament: String = "quad-lascannons", twin_bolter_replacement: String = "twin-heavy-bolter") -> Dictionary:
	if optional_weapon not in ["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]: return {}
	if main_armament not in ["quad-lascannons", "laser-destroyers"]: return {}
	if twin_bolter_replacement not in ["twin-heavy-bolter", "twin-heavy-flamer"]: return {}
	var data := profile("falchion")
	if data.is_empty(): return {}
	var ranged: Array[Dictionary] = []
	var additional: Array = data.get("additional_weapon_profiles", {}).get("ranged", [])
	for weapon: Dictionary in data.get("ranged", []):
		if str(weapon.get("id", "")).begins_with("quad-lascannon"): continue
		if str(weapon.get("id", "")) == "twin-heavy-bolter": continue
		ranged.append(weapon.duplicate(true))
	var main_id := "quad-lascannon" if main_armament == "quad-lascannons" else "laser-destroyer"
	for index in range(2):
		var main: Dictionary = {}
		for weapon: Dictionary in additional:
			if str(weapon.get("id", "")) == main_id: main = weapon.duplicate(true)
		if main.is_empty(): return {}
		main.id = "%s%s" % [main_id, "" if index == 0 else "-2"]
		ranged.append(main)
	for weapon: Dictionary in additional:
		if str(weapon.get("id", "")) == twin_bolter_replacement:
			ranged.append(weapon.duplicate(true))
		if optional_weapon != "none" and str(weapon.get("id", "")) == optional_weapon:
			ranged.append(weapon.duplicate(true))
	if ranged.size() != 4 + int(optional_weapon != "none"): return {}
	return {"ranged": ranged, "melee": data.get("melee", []).duplicate(true), "optional_weapon": optional_weapon, "main_armament": main_armament, "twin_bolter_replacement": twin_bolter_replacement}

static func _gladiator_reaper_cannon() -> Dictionary:
	var cannon := _weapon("Twin Heavy Onslaught Gatling Cannon", 24.0, 12, 3, 6, -1, 1, {"twin-linked": true, "sustained-hits": 2, "devastating-wounds": true})
	cannon.target_restricted_traits = {"sustained-hits": ["MONSTER", "VEHICLE"], "devastating-wounds": ["MONSTER", "VEHICLE"]}
	return cannon

static func _land_speeder_onslaught() -> Dictionary:
	var cannon := _weapon("Onslaught Gatling Cannon", 24.0, 8, 3, 5, -1, 1, {"devastating-wounds": true})
	cannon.target_restricted_traits = {"devastating-wounds": ["MONSTER", "VEHICLE"]}
	return cannon

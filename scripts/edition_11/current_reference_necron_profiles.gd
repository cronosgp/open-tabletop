extends RefCounted
## Small, source-bounded Necron runtime catalog. Raw exports remain under .tools/.
const RemainingProfiles = preload("res://scripts/edition_11/current_reference_necron_remaining_profiles.gd")
const ID := "necrons-e11-fixed-reference-2026-10-31-v2"
const SNAPSHOT_ID := "20261031T053336Z"
const EXPORT_UPDATED_AT := "2026-10-30T22:19:16+03:00"
const SOURCE_BOOK_ID := "000000029"
const SOURCE_BOOK_VERSION := "1.2"
const SOURCE_DATASHEET_ID := "000000534"
const SOURCE_URL := "https://wahapedia.ru/wh40k11ed/factions/necrons/Necron-Warriors"
const PARENT_MANIFEST_SHA256 := "e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef"
const SLICE_MANIFEST_SHA256 := "651601ce1262894f1fb5f20429daab8e88e0eab6fd8260b5b40041dc9dfbaae4"
const SLICE_CATALOG_SHA256 := "cee4e1ebfb73eda7c9596be33c4fed12fc421ed15f02932e11a948758078283f"
const SOURCE_FILE_SHA256 := {
	"Factions.csv": "d5038518059e5deeafa8d74e814a51598929a45c2864d3056c92c8629e7d4608",
	"Source.csv": "1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9",
	"Datasheets.csv": "39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c",
	"Datasheets_abilities.csv": "49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6",
	"Datasheets_keywords.csv": "bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341",
	"Datasheets_models.csv": "9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03",
	"Datasheets_options.csv": "642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853",
	"Datasheets_wargear.csv": "565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d",
	"Datasheets_unit_composition.csv": "c17b923ce78ac0f2a78d04efc06ad89c3394d854de9c4d00173e91fcef8d8e8f",
	"Datasheets_models_cost.csv": "2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e",
	"Datasheets_leader.csv": "ba3d15232183fa402d4fbd6feadd491f245236abccee52dbcaca9e216c04a9b6",
	"Datasheets_stratagems.csv": "cc9929a1a551dc1c608e84ea481285ece82296b9227815edb89404fcc2152cc7",
	"Datasheets_enhancements.csv": "97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f",
	"Datasheets_detachment_abilities.csv": "c0011f8310f137969e0943059638587efb1b1821d78717340c831c05c80f87dc"
}

## Local source identity inventory. Presence here records cataloging only; a sheet is
## usable only when profile() returns a complete record and its admission checks pass.
const SOURCE_SHEETS := {
	"imotekh-the-stormlord": {"id": "000000522", "name": "Imotekh The Stormlord"},
	"overlord": {"id": "000000523", "name": "Overlord"},
	"orikan-the-diviner": {"id": "000000530", "name": "Orikan The Diviner"},
	"trazyn-the-infinite": {"id": "000000532", "name": "Trazyn The Infinite"},
	"catacomb-command-barge": {"id": "000000533", "name": "Catacomb Command Barge"},
	"necron-warriors": {"id": "000000534", "name": "Necron Warriors"},
	"immortals": {"id": "000000535", "name": "Immortals"},
	"lychguard": {"id": "000000536", "name": "Lychguard"},
	"deathmarks": {"id": "000000537", "name": "Deathmarks"},
	"flayed-ones": {"id": "000000538", "name": "Flayed Ones"},
	"triarch-praetorians": {"id": "000000539", "name": "Triarch Praetorians"},
	"triarch-stalker": {"id": "000000540", "name": "Triarch Stalker"},
	"ctan-shard-of-the-nightbringer": {"id": "000000541", "name": "C’tan Shard of the Nightbringer"},
	"ctan-shard-of-the-deceiver": {"id": "000000542", "name": "C’tan Shard of the Deceiver"},
	"ghost-ark": {"id": "000000543", "name": "Ghost Ark"},
	"night-scythe": {"id": "000000544", "name": "Night Scythe"},
	"doom-scythe": {"id": "000000545", "name": "Doom Scythe"},
	"canoptek-wraiths": {"id": "000000546", "name": "Canoptek Wraiths"},
	"tomb-blades": {"id": "000000548", "name": "Tomb Blades"},
	"canoptek-spyders": {"id": "000000551", "name": "Canoptek Spyders"},
	"monolith": {"id": "000000552", "name": "Monolith"},
	"annihilation-barge": {"id": "000000553", "name": "Annihilation Barge"},
	"doomsday-ark": {"id": "000000554", "name": "Doomsday Ark"},
	"transcendent-ctan": {"id": "000000555", "name": "Transcendent C’tan"},
	"tesseract-vault": {"id": "000000556", "name": "Tesseract Vault"},
	"obelisk": {"id": "000000557", "name": "Obelisk"},
	"illuminor-szeras": {"id": "000002092", "name": "Illuminor Szeras"},
	"plasmancer": {"id": "000002108", "name": "Plasmancer"},
	"skorpekh-lord": {"id": "000002109", "name": "Skorpekh Lord"},
	"skorpekh-destroyers": {"id": "000002110", "name": "Skorpekh Destroyers"},
	"cryptothralls": {"id": "000002111", "name": "Cryptothralls"},
	"canoptek-reanimator": {"id": "000002112", "name": "Canoptek Reanimator"},
	"canoptek-scarab-swarms": {"id": "000002114", "name": "Canoptek Scarab Swarms"},
	"canoptek-doomstalker": {"id": "000002115", "name": "Canoptek Doomstalker"},
	"lokhust-heavy-destroyers": {"id": "000002116", "name": "Lokhust Heavy Destroyers"},
	"royal-warden": {"id": "000002350", "name": "Royal Warden"},
	"lokhust-lord": {"id": "000002351", "name": "Lokhust Lord"},
	"technomancer": {"id": "000002352", "name": "Technomancer"},
	"psychomancer": {"id": "000002353", "name": "Psychomancer"},
	"chronomancer": {"id": "000002354", "name": "Chronomancer"},
	"hexmark-destroyer": {"id": "000002355", "name": "Hexmark Destroyer"},
	"ctan-shard-of-the-void-dragon": {"id": "000002357", "name": "C’tan Shard of the Void Dragon"},
	"ophydian-destroyers": {"id": "000002358", "name": "Ophydian Destroyers"},
	"lokhust-destroyers": {"id": "000002359", "name": "Lokhust Destroyers"},
	"the-silent-king": {"id": "000002360", "name": "The Silent King"},
	"convergence-of-dominion": {"id": "000002361", "name": "Convergence Of Dominion"},
	"overlord-with-translocation-shroud": {"id": "000003693", "name": "Overlord with translocation shroud"},
	"canoptek-macrocytes": {"id": "000004176", "name": "Canoptek Macrocytes"},
	"canoptek-tomb-crawlers": {"id": "000004177", "name": "Canoptek Tomb Crawlers"},
	"geomancer": {"id": "000004178", "name": "Geomancer"},
	"nekrosor-ammentar": {"id": "000004186", "name": "Nekrosor Ammentar"}
}

static func inventory() -> Dictionary:
	return SOURCE_SHEETS.duplicate(true)

static func profile(source: String) -> Dictionary:
	var remaining_profile := RemainingProfiles.profile(source)
	if not remaining_profile.is_empty(): return remaining_profile
	if source == "immortals":
		return {
			"name": "Immortals",
			"source_book_id": SOURCE_BOOK_ID,
			"source_book_version": SOURCE_BOOK_VERSION,
			"source_datasheet_id": "000000535",
			"source_snapshot_id": SNAPSHOT_ID,
			"source_export_updated_at": EXPORT_UPDATED_AT,
			"source_manifest_sha256": PARENT_MANIFEST_SHA256,
			"source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
			"source_slice_catalog_sha256": SLICE_CATALOG_SHA256,
			"source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Immortals",
			"points": 65,
			"points_by_models": {5: 65, 10: 130},
			"construction_model_sizes": [5, 10],
			"models": 5,
			"base_size_source_mm": 32,
			"base_radius_inches": 16.0 / 25.4,
			"stats": {"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			"keywords": ["NECRONS", "BATTLELINE", "INFANTRY", "IMMORTALS"],
			"ranged": [
				{"id": "gauss-blaster", "profiles": {"standard": _weapon("Gauss blaster", 24.0, 2, 3, 5, -1, 1, {"lethal-hits": true})}}
			],
			"melee": [
				{"id": "close-combat-weapon-immortals", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 2, 3, 4, 0, 1, {})}}
			],
			"additional_weapon_profiles": {
				"ranged": [
					{"id": "tesla-carbine", "profiles": {"standard": _weapon("Tesla carbine", 24.0, 2, 3, 5, 0, 1, {"assault": true, "sustained-hits": 2})}}
				]
			},
			"source_options": [
				{"id": "immortals-tesla-carbine-replacement", "kind": "per_model_weapon_replacement", "from": "gauss-blaster", "to": "tesla-carbine", "minimum": 0, "maximum": "unit_size", "implemented": true}
			],
			"source_ability_names": ["Reanimation Protocols", "Implacable Eradication"],
			"supported_rule_ids": ["reanimation-protocols", "implacable-eradication"],
			"source_leader_datasheet_ids": ["000000522", "000000523", "000000524", "000000527", "000000528", "000000530", "000000531", "000000532", "000002350", "000002352", "000002353", "000002354", "000002108", "000003693", "000004178"],
			"source_scope": "Necrons App v1.2",
			"unsupported_abilities": []
		}
	if source == "overlord":
		return {
			"name": "Overlord",
			"source_book_id": SOURCE_BOOK_ID,
			"source_book_version": SOURCE_BOOK_VERSION,
			"source_datasheet_id": "000000523",
			"source_snapshot_id": SNAPSHOT_ID,
			"source_export_updated_at": EXPORT_UPDATED_AT,
			"source_manifest_sha256": PARENT_MANIFEST_SHA256,
			"source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
			"source_slice_catalog_sha256": SLICE_CATALOG_SHA256,
			"source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Overlord",
			"points": 90,
			"points_by_models": {1: 90},
			"construction_model_sizes": [1],
			"models": 1,
			"max_supported_copies": 3,
			"base_size_source_mm": 40,
			"base_radius_inches": 20.0 / 25.4,
			"stats": {"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
			"keywords": ["NECRONS", "NOBLE", "CHARACTER", "INFANTRY", "OVERLORD"],
			"ranged": [
				{"id": "tachyon-arrow", "profiles": {"standard": _weapon("Tachyon arrow", 72.0, 1, 2, 16, -5, "D6+2", {"one-shot": true})}}
			],
			"melee": [
				{"id": "overlords-blade", "profiles": {"standard": _weapon("Overlord's blade", 0.0, 4, 2, 8, -3, 2, {"devastating-wounds": true})}}
			],
			"additional_weapon_profiles": {
				"ranged": [
					{"id": "staff-of-light-overlord", "profiles": {"standard": _weapon("Staff of light", 18.0, 3, 2, 5, -2, 1, {})}}
				],
				"melee": [
					{"id": "staff-of-light-overlord", "profiles": {"standard": _weapon("Staff of light", 0.0, 4, 2, 5, -2, 1, {})}},
					{"id": "voidscythe", "profiles": {"standard": _weapon("Voidscythe", 0.0, 3, 3, 12, -3, 3, {"devastating-wounds": true})}}
				]
			},
			"source_options": [
				{"id": "overlord-arrow-melee-replacement", "kind": "linked_weapon_replacement_group", "replaces": ["tachyon-arrow", "overlords-blade"], "choices": [["staff-of-light-overlord"], ["voidscythe"]], "implemented": false},
				{"id": "overlord-resurrection-orb", "kind": "conditional_wargear_addition", "item": "resurrection-orb", "condition": "tachyon-arrow-not-equipped", "implemented": false}
			],
			"source_ability_names": ["Leader", "Reanimation Protocols", "Resurrection Orb", "My Will Be Done", "Implacable Resilience", "One Shot"],
			"supported_rule_ids": ["leader", "reanimation-protocols", "resurrection-orb", "my-will-be-done", "implacable-resilience", "one-shot"],
			"source_bodyguard_datasheet_ids": ["000000534", "000000536", "000000535"],
			"source_scope": "Necrons App v1.2",
			"unsupported_abilities": []
		}
	if source == "royal-warden":
		return {
			"name": "Royal Warden",
			"source_book_id": SOURCE_BOOK_ID,
			"source_book_version": SOURCE_BOOK_VERSION,
			"source_datasheet_id": "000002350",
			"source_snapshot_id": SNAPSHOT_ID,
			"source_export_updated_at": EXPORT_UPDATED_AT,
			"source_manifest_sha256": PARENT_MANIFEST_SHA256,
			"source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
			"source_slice_catalog_sha256": SLICE_CATALOG_SHA256,
			"source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
			"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Royal-Warden",
			"points": 50,
			"points_by_models": {1: 50},
			"construction_model_sizes": [1],
			"models": 1,
			"base_size_source_mm": 32,
			"base_radius_inches": 16.0 / 25.4,
			"stats": {"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
			"keywords": ["NECRONS", "ROYAL WARDEN", "CHARACTER", "INFANTRY"],
			"ranged": [
				{"id": "relic-gauss-blaster", "profiles": {"standard": _weapon("Relic gauss blaster", 24.0, 2, 3, 5, -1, 2, {"lethal-hits": true, "rapid-fire": 2})}}
			],
			"melee": [
				{"id": "close-combat-weapon-royal-warden", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 4, 3, 5, 0, 1, {})}}
			],
			"source_ability_names": ["Leader", "Reanimation Protocols", "Adaptive Strategy", "Engrammatic Logic"],
			"supported_rule_ids": ["leader", "reanimation-protocols", "adaptive-strategy", "engrammatic-logic"],
			"source_bodyguard_datasheet_ids": ["000000534", "000000535"],
			"source_scope": "Necrons App v1.2",
			"unsupported_abilities": []
		}
	if source == "orikan-the-diviner":
		return _record("orikan-the-diviner", "Orikan The Diviner", "000000530", "Orikan-The-Diviner", {1: 90}, 1, 40,
			{"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
			["NECRONS", "INFANTRY", "CHARACTER", "EPIC HERO", "CRYPTEK", "CHRONOMANCER", "ORIKAN THE DIVINER"], [],
			[{"id": "staff-of-tomorrow", "profiles": {"standard": _weapon("Staff of Tomorrow", 0.0, 2, 3, 4, -3, "D3", {"devastating-wounds": true})}}],
			["Support", "Reanimation Protocols", "Master Chronomancer", "The Stars Are Right"],
			["support"], ["Reanimation Protocols", "Master Chronomancer", "The Stars Are Right"], [],
			["000000534", "000000535"], [])
	if source == "trazyn-the-infinite":
		var trazyn := _record("trazyn-the-infinite", "Trazyn The Infinite", "000000532", "Trazyn-The-Infinite", {1: 60}, 1, 25,
			{"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
			["NECRONS", "NOBLE", "EPIC HERO", "CHARACTER", "INFANTRY", "TRAZYN THE INFINITE"], [],
			[{"id": "empathic-obliterator", "profiles": {"standard": _weapon("Empathic Obliterator", 0.0, 4, 2, 7, 0, "D3", {"sustained-hits": "D3"})}}],
			["Leader", "Reanimation Protocols", "Ancient Collector", "Surrogate Hosts"],
			["leader"], ["Reanimation Protocols", "Ancient Collector", "Surrogate Hosts"],
			[], ["000000534", "000000536", "000000535"], [])
		trazyn.unsupported_weapon_rules = ["Empathic Obliterator: Sustained Hits D3"]
		return trazyn
	if source == "lychguard":
		return _record("lychguard", "Lychguard", "000000536", "Lychguard", {5: 80, 10: 160}, 5, 32,
			{"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "LYCHGUARD"],
			[{"id": "warscythe", "profiles": {"standard": _weapon("Warscythe", 0.0, 2, 3, 8, -3, 2, {"devastating-wounds": true})}}],
			[{"id": "hyperphase-sword", "profiles": {"standard": _weapon("Hyperphase sword", 0.0, 3, 3, 6, -2, 1, {})}}],
			["Reanimation Protocols", "Dispersion Shield", "Guardian Protocols"], [],
			["Reanimation Protocols", "Dispersion Shield", "Guardian Protocols"],
			["000000522", "000000523", "000000524", "000000527", "000000528", "000000532", "000003693"], [],
			[{"id": "lychguard-shielded-loadout", "kind": "replace_all_warscythes_with_swords_and_shields", "grants": "dispersion-shield", "implemented": false}])
	if source == "deathmarks":
		return _record("deathmarks", "Deathmarks", "000000537", "Deathmarks", {5: 60, 10: 120}, 5, 32,
			{"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 1, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "DEATHMARKS"],
			[{"id": "synaptic-disintegrator", "profiles": {"standard": _weapon("Synaptic disintegrator", 36.0, 1, 3, 5, -2, 2, {"heavy": true, "precision": true})}}],
			[{"id": "close-combat-weapon-deathmarks", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 2, 3, 4, 0, 1, {})}}],
			["Deep Strike", "Reanimation Protocols", "Hyperspace Hunters"],
			["deep-strike", "reanimation-protocols", "hyperspace-hunters"], [], [], [], [], {5: 70, 10: 130})
	if source == "flayed-ones":
		return _record("flayed-ones", "Flayed Ones", "000000538", "Flayed-Ones", {5: 55, 10: 100}, 5, 28.5,
			{"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 1, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "FLAYED ONES"], [],
			[{"id": "flayer-claws", "profiles": {"standard": _weapon("Flayer claws", 0.0, 4, 3, 4, -1, 1, {"sustained-hits": 1, "twin-linked": true})}}],
			["Infiltrators", "Stealth", "Reanimation Protocols", "Flesh Hunger"], ["infiltrators", "stealth", "reanimation-protocols", "flesh-hunger"], [], [], [])
	if source == "triarch-praetorians":
		var praetorians := _record("triarch-praetorians", "Triarch Praetorians", "000000539", "Triarch-Praetorians", {5: 80, 10: 160}, 5, 32,
			{"movement_inches": 10, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "FLY", "TRIARCH", "PRAETORIANS", "INFANTRY"],
			[{"id": "rod-of-covenant", "profiles": {"standard": _weapon("Rod of covenant", 12.0, 1, 3, 5, -2, 2, {})}}],
			[{"id": "rod-of-covenant", "profiles": {"standard": _weapon("Rod of covenant", 0.0, 3, 3, 5, -2, 2, {})}}],
			["Deep Strike", "Reanimation Protocols", "Relentless Combatants"], ["deep-strike", "reanimation-protocols"], ["Relentless Combatants"], [], [],
			[{"id": "praetorians-rod-replacement", "kind": "all_models_linked_weapon_replacement", "from": ["rod-of-covenant-ranged", "rod-of-covenant-melee"], "to": ["particle-caster", "voidblade"], "implemented": false}])
		praetorians.additional_weapon_profiles = {
			"ranged": [{"id": "particle-caster", "profiles": {"standard": _weapon("Particle caster", 12.0, 3, 3, 5, 0, 1, {"devastating-wounds": true, "pistol": true})}}],
			"melee": [{"id": "voidblade", "profiles": {"standard": _weapon("Voidblade", 0.0, 4, 3, 5, -2, 1, {})}}]
		}
		return praetorians
	if source == "skorpekh-destroyers":
		return _record("skorpekh-destroyers", "Skorpekh Destroyers", "000002110", "Skorpekh-Destroyers", {3: 85, 6: 170}, 3, 50,
			{"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "SKORPEKH DESTROYERS", "DESTROYER CULT"], [],
			[{"id": "skorpekh-hyperphase-weapons", "profiles": {"standard": _weapon("Skorpekh hyperphase weapons", 0.0, 4, 3, 7, -2, 2, {})}}],
			["Reanimation Protocols", "Plasmacyte", "Whirling Onslaught"], ["reanimation-protocols"], ["Plasmacyte", "Whirling Onslaught"], ["000002109"], [],
			[{"id": "skorpekh-plasmacytes", "kind": "optional-unit-equipment", "item": "Plasmacyte", "maximum": "one-per-three-models", "implemented": false}], {3: 95, 6: 180})
	if source == "canoptek-scarab-swarms":
		return _record("canoptek-scarab-swarms", "Canoptek Scarab Swarms", "000002114", "Canoptek-Scarab-Swarms", {3: 40, 6: 80}, 3, 40,
			{"movement_inches": 10, "toughness": 2, "save_target": 6, "wounds": 4, "leadership_target": 8, "objective_control": 0, "invulnerable_target": 0},
			["NECRONS", "CANOPTEK", "SCARAB SWARMS", "SWARM", "FLY"], [],
			[{"id": "feeder-mandibles", "profiles": {"standard": _weapon("Feeder mandibles", 0.0, 6, 5, 2, 0, 1, {"lethal-hits": true})}}],
			["Reanimation Protocols", "Self-destruction", "Chittering Swarm"], ["reanimation-protocols", "self-destruction", "chittering-swarm"], [], [], [])
	if source == "canoptek-wraiths":
		var wraiths := _record("canoptek-wraiths", "Canoptek Wraiths", "000000546", "Canoptek-Wraiths", {3: 95, 6: 220}, 3, 50,
			{"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 4},
			["NECRONS", "BEASTS", "CANOPTEK", "WRAITHS", "FLY"], [],
			[{"id": "vicious-claws", "profiles": {"standard": _weapon("Vicious claws", 0.0, 4, 4, 6, -1, 2, {})}}],
			["Reanimation Protocols", "Wraith Form"], ["reanimation-protocols"], ["Wraith Form"], [], [], [
			{"id": "wraith-optional-ranged-weapons", "kind": "per-model-selective-ranged-weapon", "choices": ["particle-caster", "transdimensional-beamer"], "maximum": "unit_size", "implemented": false},
			{"id": "wraith-whip-coils", "kind": "per-model-melee-replacement", "from": "vicious-claws", "to": "whip-coils", "maximum": "unit_size", "implemented": false}
		], {3: 115, 6: 240})
		wraiths.additional_weapon_profiles = {
			"ranged": [
				{"id": "particle-caster", "profiles": {"standard": _weapon("Particle caster", 12.0, 3, 4, 5, 0, 1, {"devastating-wounds": true, "pistol": true})}},
				{"id": "transdimensional-beamer", "profiles": {"standard": _weapon("Transdimensional beamer", 12.0, 1, 4, 4, -2, 3, {})}}
			],
			"melee": [{"id": "whip-coils", "profiles": {"standard": _weapon("Whip coils", 0.0, 8, 4, 5, 0, 1, {})}}]
		}
		return wraiths
	if source == "canoptek-reanimator":
		var reanimator := _record("canoptek-reanimator", "Canoptek Reanimator", "000002112", "Canoptek-Reanimator", {1: 75}, 1, 60,
			{"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 8, "objective_control": 3, "invulnerable_target": 0},
			["NECRONS", "WALKER", "VEHICLE", "CANOPTEK", "REANIMATOR"],
			[{"id": "atomiser-beam", "count": 2, "profiles": {"standard": _weapon("Atomiser beam", 12.0, 3, 4, 6, -2, 1, {})}}],
			[{"id": "reanimators-claws", "profiles": {"standard": _weapon("Reanimator’s claws", 0.0, 4, 4, 5, 0, 1, {})}}],
			["Feel No Pain 4+", "Reanimation Protocols", "Nanoscarab Reanimation Beam (Aura)"], ["feel-no-pain-4", "reanimation-protocols", "nanoscarab-reanimation-beam"],
			[], [], [])
		reanimator.source_ability_bindings = [
			{"source_line": 1, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "4+"},
			{"source_line": 2, "ability_id": "000008369", "name": "Reanimation Protocols", "model_role": "", "type": "Faction", "parameter": ""},
			{"source_line": 3, "ability_id": "", "name": "Nanoscarab Reanimation Beam (Aura)", "model_role": "", "type": "Datasheet", "parameter": ""}
		]
		return reanimator
	if source == "ghost-ark":
		var ghost_ark := _record("ghost-ark", "Ghost Ark", "000000543", "Ghost-Ark", {1: 100}, 1, 60,
			{"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 14, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 4},
			["NECRONS", "VEHICLE", "FLY", "FRAME", "TRANSPORT", "GHOST ARK", "DEDICATED TRANSPORT"],
			[{"id": "gauss-flayer-array", "count": 2, "profiles": {"standard": _weapon("Gauss flayer array", 24.0, 5, 3, 4, 0, 1, {"lethal-hits": true, "rapid-fire": 5})}}],
			[{"id": "armoured-bulk", "profiles": {"standard": _weapon("Armoured bulk", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Deadly Demise D3", "Reanimation Protocols", "Repair Barge"], ["deadly-demise-d3", "reanimation-protocols"], ["Repair Barge"], [], [], [])
		ghost_ark.source_transport_capacity = "10 Necron Warrior models and 1 Necrons Infantry Character model"
		ghost_ark.unsupported_transport_rules = ["Transport capacity and passenger embark/disembark are not implemented for this profile."]
		return ghost_ark
	if source == "canoptek-doomstalker":
		var doomstalker := _record("canoptek-doomstalker", "Canoptek Doomstalker", "000002115", "Canoptek-Doomstalker", {1: 130}, 1, 90,
			{"movement_inches": 8, "toughness": 8, "save_target": 3, "wounds": 12, "leadership_target": 8, "objective_control": 4, "invulnerable_target": 4},
			["NECRONS", "DOOMSTALKER", "WALKER", "CANOPTEK", "VEHICLE"],
			[
				{"id": "doomsday-blaster", "profiles": {"standard": _weapon("Doomsday blaster", 48.0, "D6+1", 4, 14, -3, 3, {"blast": true, "heavy": true})}},
				{"id": "twin-gauss-flayer", "profiles": {"standard": _weapon("Twin gauss flayer", 24.0, 1, 4, 4, 0, 1, {"lethal-hits": true, "rapid-fire": 1, "twin-linked": true})}}
			],
			[{"id": "doomstalker-limbs", "profiles": {"standard": _weapon("Doomstalker limbs", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Deadly Demise D3", "Reanimation Protocols", "Sentinel Construct", "Damaged 4"], ["deadly-demise-d3", "reanimation-protocols", "sentinel-construct", "damaged-4"], [], [], [], [])
		doomstalker.source_damaged_wounds = "1-4"
		doomstalker.source_damaged_description = "While this model has 1-4 wounds remaining, each time this model makes an attack, subtract 1 from the Hit roll."
		return doomstalker
	if source == "doomsday-ark":
		var doomsday_ark := _record("doomsday-ark", "Doomsday Ark", "000000554", "Doomsday-Ark", {1: 200}, 1, 60,
			{"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 14, "leadership_target": 7, "objective_control": 5, "invulnerable_target": 4},
			["NECRONS", "FLY", "FRAME", "DOOMSDAY ARK", "VEHICLE"],
			[
				{"id": "doomsday-cannon", "profiles": {"standard": _weapon("Doomsday cannon", 72.0, "D6+1", 3, 18, -4, 4, {"blast": true, "heavy": true})}},
				{"id": "gauss-flayer-array", "count": 2, "profiles": {"standard": _weapon("Gauss flayer array", 24.0, 5, 3, 4, 0, 1, {"lethal-hits": true, "rapid-fire": 5})}}
			],
			[{"id": "armoured-bulk", "profiles": {"standard": _weapon("Armoured bulk", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Deadly Demise D3", "Reanimation Protocols", "Overwhelming Obliteration", "Damaged 5"], ["deadly-demise-d3", "reanimation-protocols", "damaged-5"], ["Overwhelming Obliteration"], [], [], [], {1: 230})
		doomsday_ark.source_damaged_wounds = "1-5"
		doomsday_ark.source_damaged_description = "While this model has 1-5 wounds remaining, each time this model makes an attack, subtract 1 from the Hit roll."
		return doomsday_ark
	if source == "monolith":
		var monolith := _record("monolith", "Monolith", "000000552", "Monolith", {1: 420}, 1, 160,
			{"movement_inches": 8, "toughness": 13, "save_target": 2, "wounds": 22, "leadership_target": 7, "objective_control": 8, "invulnerable_target": 0},
			["NECRONS", "TITANIC", "FLY", "FRAME", "TOWERING", "MONOLITH", "VEHICLE"],
			[
				{"id": "gauss-flux-arc", "count": 4, "profiles": {"standard": _weapon("Gauss flux arc", 24.0, 3, 3, 6, -1, 1, {"lethal-hits": true, "rapid-fire": 3})}},
				{"id": "particle-whip", "profiles": {"standard": _weapon("Particle whip", 24.0, "3D6", 3, 8, -1, 2, {"blast": true, "devastating-wounds": true})}}
			],
			[{"id": "portal-of-exile", "profiles": {"standard": _weapon("Portal of exile", 0.0, 6, 2, 8, -2, 3, {})}}],
			["Deadly Demise D6", "Deep Strike", "Reanimation Protocols", "Eternity Gate", "Damaged"], ["deadly-demise-d6", "deep-strike", "reanimation-protocols"], ["Eternity Gate", "Damaged profile: Objective Control and Hit penalties"], [], [], [
				{"id": "monolith-gauss-flux-arc-replacement", "kind": "all_models_weapon_replacement", "from": "4 gauss flux arcs", "to": "4 death rays", "implemented": false}
			])
		monolith.additional_weapon_profiles = {"ranged": [{"id": "death-ray", "profiles": {"standard": _weapon("Death ray", 24.0, 1, 3, 12, -4, "D6+1", {"sustained-hits": "D3"})}}]}
		monolith.unsupported_weapon_rules = ["Death ray: Sustained Hits D3"]
		monolith.source_repeat_copy_costs = {"2ND+": {1: 440}}
		monolith.source_damaged_wounds = "1-7"
		monolith.source_damaged_description = "While this model has 1-7 wounds remaining, subtract 4 from its Objective Control characteristic and each time this model makes an attack, subtract 1 from the Hit roll."
		return monolith
	if source == "catacomb-command-barge":
		var command_barge := _record("catacomb-command-barge", "Catacomb Command Barge", "000000533", "Catacomb-Command-Barge", {1: 120}, 1, 60,
			{"movement_inches": 10, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
			["NECRONS", "VEHICLE", "CHARACTER", "NOBLE", "FLY", "FRAME", "CATACOMB COMMAND BARGE"],
			[{"id": "gauss-cannon-command-barge", "profiles": {"standard": _weapon("Gauss cannon", 24.0, 3, 3, 5, -2, 2, {"lethal-hits": true})}},
				{"id": "staff-of-light-command-barge", "profiles": {"standard": _weapon("Staff of light", 18.0, 3, 2, 5, -2, 1, {})}}],
			[{"id": "staff-of-light-command-barge", "profiles": {"standard": _weapon("Staff of light", 0.0, 4, 3, 5, -2, 1, {})}}],
			["Deadly Demise 1", "Reanimation Protocols", "Resurrection Orb", "Carrier Wave (Aura)", "Advanced Quantum Shielding"],
			["deadly-demise-1", "reanimation-protocols"], ["Carrier Wave (Aura)", "Advanced Quantum Shielding", "Resurrection Orb (optional wargear)"], [], [], [
				{"id": "command-barge-gauss-cannon-replacement", "kind": "weapon_replacement", "from": "gauss-cannon", "to": "tesla-cannon", "implemented": false},
				{"id": "command-barge-staff-melee-replacement", "kind": "weapon_replacement", "from": "staff-of-light-melee", "to": "overlords-blade", "implemented": false},
				{"id": "command-barge-resurrection-orb", "kind": "optional_wargear_addition", "item": "resurrection-orb", "minimum": 0, "maximum": 1, "implemented": false}
			])
		command_barge.additional_weapon_profiles = {
			"ranged": [
				{"id": "tesla-cannon-command-barge", "profiles": {"standard": _weapon("Tesla cannon", 24.0, 4, 3, 6, 0, 1, {"sustained-hits": 2})}}
			],
			"melee": [
				{"id": "overlords-blade-command-barge", "profiles": {"standard": _weapon("Overlord’s blade", 0.0, 4, 2, 8, -3, 2, {"devastating-wounds": true})}}
			]
		}
		return command_barge
	if source == "triarch-stalker":
		var stalker := _record("triarch-stalker", "Triarch Stalker", "000000540", "Triarch-Stalker", {1: 110}, 1, 120,
			{"movement_inches": 8, "toughness": 8, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 4, "invulnerable_target": 4},
			["NECRONS", "STALKER", "VEHICLE", "TRIARCH", "WALKER", "FRAME"],
			[{"id": "heat-ray", "profiles": {
				"dispersed": _weapon("Heat ray – dispersed", 12.0, "2D6", "-", 5, -1, 1, {"ignores-cover": true, "torrent": true}),
				"focused": _weapon("Heat ray – focused", 18.0, 2, 3, 9, -4, "D6", {"melta": 4})
			}}],
			[{"id": "stalkers-forelimbs", "profiles": {"standard": _weapon("Stalker’s forelimbs", 0.0, 4, 3, 7, -1, 3, {})}}],
			["Deadly Demise D3", "Scouts 8", "Reanimation Protocols", "Targeting Relay"],
			["deadly-demise-d3", "scouts-8", "reanimation-protocols"], ["Targeting Relay"], [], [], [
				{"id": "triarch-stalker-heat-ray-replacement", "kind": "weapon_replacement", "from": "heat-ray", "choices": ["particle-shredder", "heavy-gauss-cannon-array"], "implemented": false}
			], {1: 120})
		stalker.erase("base_size_source_mm")
		stalker.source_base_size_label = "Use model"
		stalker.base_size_proxy_mm = 120
		stalker.base_size_proxy_note = "The local sheet does not specify model dimensions; runtime uses a labelled 120 mm circular proxy pending footprint validation."
		stalker.unsupported_geometry = ["Exact Triarch Stalker model footprint and base clearance"]
		stalker.additional_weapon_profiles = {"ranged": [
			{"id": "particle-shredder", "profiles": {"standard": _weapon("Particle shredder", 18.0, "D6+6", 2, 7, 0, 1, {"blast": true, "devastating-wounds": true})}},
			{"id": "heavy-gauss-cannon-array", "profiles": {"standard": _weapon("Heavy gauss cannon array", 24.0, 6, 3, 8, -2, 2, {"lethal-hits": true})}}
		]}
		return stalker
	if source == "hexmark-destroyer":
		return _record("hexmark-destroyer", "Hexmark Destroyer", "000002355", "Hexmark-Destroyer", {1: 75}, 1, 50,
			{"movement_inches": 8, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "CHARACTER", "DESTROYER CULT", "HEXMARK DESTROYER"],
			[{"id": "enmitic-disintegrator-pistols", "profiles": {"standard": _weapon("Enmitic disintegrator pistols", 18.0, 6, 2, 6, -2, 1, {"close-quarters": true, "ignores-cover": true})}}],
			[{"id": "close-combat-weapon-hexmark", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 4, 3, 5, 0, 1, {})}}],
			["Deep Strike", "Lone Operative", "Reanimation Protocols", "Inescapable Death", "Multi-threat Eliminator"],
			["deep-strike", "lone-operative", "reanimation-protocols", "inescapable-death", "multi-threat-eliminator"], [], [], [], [])
	if source == "ophydian-destroyers":
		return _record("ophydian-destroyers", "Ophydian Destroyers", "000002358", "Ophydian-Destroyers", {3: 80, 6: 150}, 3, 50,
			{"movement_inches": 10, "toughness": 5, "save_target": 4, "wounds": 3, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			["NECRONS", "OPHYDIAN DESTROYERS", "DESTROYER CULT", "INFANTRY"], [],
			[{"id": "ophydian-hyperphase-weapons", "profiles": {"standard": _weapon("Ophydian hyperphase weapons", 0.0, 5, 3, 4, -2, 2, {})}}],
			["Deep Strike", "Reanimation Protocols", "Plasmacyte", "Tunnelling Horrors"], ["deep-strike", "reanimation-protocols"], ["Plasmacyte", "Tunnelling Horrors"], [], [], [
				{"id": "ophydian-plasmacyte-count", "kind": "size_scaled_wargear_count", "models_per_wargear": 3, "wargear": "Plasmacyte", "implemented": false}
			], {3: 90, 6: 160})
	if source == "lokhust-destroyers":
		return _record("lokhust-destroyers", "Lokhust Destroyers", "000002359", "Lokhust-Destroyers", {1: 40, 2: 55, 3: 80, 6: 190}, 1, 60,
			{"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			["NECRONS", "MOUNTED", "FLY", "DESTROYER CULT", "LOKHUST DESTROYERS"],
			[{"id": "gauss-cannon", "profiles": {"standard": _weapon("Gauss cannon", 24.0, 3, 3, 5, -2, 2, {"lethal-hits": true})}}],
			[{"id": "close-combat-weapon-lokhust", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 2, 3, 4, 0, 1, {})}}],
			["Reanimation Protocols", "Hard-wired for Destruction"], ["reanimation-protocols"], ["Hard-wired for Destruction"], ["000002351"], [],
			[{"id": "lokhust-unpriced-sizes-and-third-plus-six-model-cost", "kind": "unpriced-composition-or-copy-tier", "unpriced_sizes": [4, 5], "missing_third_plus_size": 6, "implemented": false}], {1: 70, 2: 85, 3: 110})
	if source == "lokhust-heavy-destroyers":
		return _record("lokhust-heavy-destroyers", "Lokhust Heavy Destroyers", "000002116", "Lokhust-Heavy-Destroyers", {1: 50, 2: 100, 3: 165}, 1, 60,
			{"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			["NECRONS", "DESTROYER CULT", "MOUNTED", "LOKHUST HEAVY DESTROYERS", "FLY"],
			[{"id": "gauss-destructor", "profiles": {"standard": _weapon("Gauss destructor", 48.0, 1, 3, 14, -4, 6, {"heavy": true, "lethal-hits": true})}}],
			[{"id": "close-combat-weapon-lokhust-heavy", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 2, 3, 4, 0, 1, {})}}],
			["Reanimation Protocols", "Optimised for Slaughter"], ["reanimation-protocols"], ["Optimised for Slaughter"], ["000002351"], [],
			[{"id": "lokhust-heavy-enmitic-replacement", "kind": "per-model-weapon-replacement", "from": "gauss-destructor", "to": "enmitic-exterminator", "maximum": "unit_size", "implemented": false}], {1: 60, 2: 110, 3: 175})
	if source == "imotekh-the-stormlord":
		return _record("imotekh-the-stormlord", "Imotekh The Stormlord", "000000522", "Imotekh-The-Stormlord", {1: 100}, 1, 40,
			{"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
			["NECRONS", "NOBLE", "INFANTRY", "EPIC HERO", "CHARACTER", "IMOTEKH THE STORMLORD"],
			[
				{"id": "gauntlet-of-fire", "profiles": {"standard": _weapon("Gauntlet of Fire", 12.0, "D6", "-", 5, -1, 1, {"ignores-cover": true, "torrent": true})}},
				{"id": "staff-of-the-destroyer", "profiles": {"standard": _weapon("Staff of the Destroyer", 18.0, 3, 2, 6, -3, 2, {})}}
			],
			[
				{"id": "staff-of-the-destroyer", "profiles": {"standard": _weapon("Staff of the Destroyer", 0.0, 4, 2, 6, -3, 2, {"devastating-wounds": true})}}
			],
			["Leader", "Reanimation Protocols", "Grand Strategist", "Lord of the Storm"], ["leader"], ["Reanimation Protocols", "Grand Strategist", "Lord of the Storm"], [], ["000000534", "000000536", "000000535"])
	if source == "illuminor-szeras":
		return _record("illuminor-szeras", "Illuminor Szeras", "000002092", "Illuminor-Szeras", {1: 175}, 1, 80,
			{"movement_inches": 8, "toughness": 8, "save_target": 2, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
			["NECRONS", "CHARACTER", "EPIC HERO", "ILLUMINOR SZERAS", "CRYPTEK", "INFANTRY"],
			[{"id": "eldritch-lance", "profiles": {"standard": _weapon("Eldritch lance", 36.0, 3, 3, 9, -3, 3, {})}}],
			[
				{"id": "eldritch-lance", "profiles": {"standard": _weapon("Eldritch lance", 0.0, 4, 3, 9, -3, 3, {})}},
				{"id": "impaling-legs", "profiles": {"standard": _weapon("Impaling legs", 0.0, 4, 3, 6, -1, 1, {"extra-attacks": true})}}
			],
			["Feel No Pain 4+", "Reanimation Protocols", "Illuminor", "Mechanical Augmentation (Aura)", "Atomic Energy Manipulator"], [],
			["Feel No Pain 4+", "Reanimation Protocols", "Illuminor", "Mechanical Augmentation (Aura)", "Atomic Energy Manipulator"], [], [])
	if source == "plasmancer":
		return _record("plasmancer", "Plasmancer", "000002108", "Plasmancer", {1: 60}, 1, 32,
			{"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "INFANTRY", "CHARACTER", "CRYPTEK", "PLASMANCER"],
			[{"id": "plasmic-lance", "profiles": {"standard": _weapon("Plasmic lance", 18.0, 3, 4, 7, -3, 2, {})}}],
			[{"id": "plasmic-lance", "profiles": {"standard": _weapon("Plasmic lance", 0.0, 2, 4, 7, -3, 2, {})}}],
			["Support", "Reanimation Protocols", "Harbinger of Destruction", "Living Lightning"], ["support"],
			["Reanimation Protocols", "Harbinger of Destruction", "Living Lightning"], [], ["000000534", "000000535"])
	if source == "skorpekh-lord":
		return _record("skorpekh-lord", "Skorpekh Lord", "000002109", "Skorpekh-Lord", {1: 95}, 1, 60,
			{"movement_inches": 8, "toughness": 7, "save_target": 3, "wounds": 7, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
			["NECRONS", "SKORPEKH LORD", "CHARACTER", "INFANTRY", "DESTROYER CULT"],
			[{"id": "enmitic-annihilator", "profiles": {"standard": _weapon("Enmitic annihilator", 18.0, 2, 2, 6, -1, 1, {"rapid-fire": 2})}}],
			[
				{"id": "flensing-claw", "profiles": {"standard": _weapon("Flensing claw", 0.0, 8, 2, 6, -1, 1, {})}},
				{"id": "hyperphase-harvester", "profiles": {"standard": _weapon("Hyperphase harvester", 0.0, 4, 2, 10, -3, 3, {})}}
			],
			["Leader", "Reanimation Protocols", "United in Destruction", "Crimson Harvest"], ["leader"], ["Reanimation Protocols", "United in Destruction", "Crimson Harvest"], [], ["000002110"], [], {1: 105})
	if source == "lokhust-lord":
		var lokhust_lord := _record("lokhust-lord", "Lokhust Lord", "000002351", "Lokhust-Lord", {1: 80}, 1, 60,
			{"movement_inches": 8, "toughness": 6, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4},
			["NECRONS", "FLY", "MOUNTED", "CHARACTER", "DESTROYER CULT", "LOKHUST LORD"],
			[{"id": "staff-of-light-lokhust-lord", "profiles": {"standard": _weapon("Staff of light", 18.0, 3, 2, 5, -2, 1, {})}}],
			[{"id": "staff-of-light-lokhust-lord", "profiles": {"standard": _weapon("Staff of light", 0.0, 4, 2, 5, -2, 1, {})}}],
			["Leader", "Reanimation Protocols", "Nanoscarab Amulet", "Resurrection Orb", "Destroyer Cult", "Driven by Hatred"], ["leader"],
			["Reanimation Protocols", "Nanoscarab Amulet", "Resurrection Orb", "Destroyer Cult", "Driven by Hatred"], [], ["000002116", "000002359"], [
			{"id": "lokhust-lord-staff-replacement", "kind": "linked-weapon-replacement", "from": ["staff-of-light-ranged", "staff-of-light-melee"], "to": ["lords-blade"], "implemented": false},
			{"id": "lokhust-lord-wargear", "kind": "select-one-wargear", "choices": ["nanoscarab-amulet", "resurrection-orb"], "implemented": false}
		])
		lokhust_lord.additional_weapon_profiles = {"melee": [{"id": "lords-blade", "profiles": {"standard": _weapon("Lord’s blade", 0.0, 4, 2, 8, -3, 2, {"devastating-wounds": true})}}]}
		return lokhust_lord
	if source == "technomancer":
		return _record("technomancer", "Technomancer", "000002352", "Technomancer", {1: 80}, 1, 50,
			{"movement_inches": 10, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "FLY", "INFANTRY", "CHARACTER", "CRYPTEK", "TECHNOMANCER"],
			[{"id": "staff-of-light-technomancer", "profiles": {"standard": _weapon("Staff of light", 18.0, 3, 4, 5, -2, 1, {})}}],
			[{"id": "staff-of-light-technomancer", "profiles": {"standard": _weapon("Staff of light", 0.0, 2, 4, 5, -2, 1, {})}}],
			["Support", "Reanimation Protocols", "Rites of Reanimation", "Technomancer"], ["support"], ["Reanimation Protocols", "Rites of Reanimation", "Technomancer"], [],
			["000000534", "000000535", "000000546"], [], {1: 90})
	if source == "psychomancer":
		return _record("psychomancer", "Psychomancer", "000002353", "Psychomancer", {1: 65}, 1, 40,
			{"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
			["NECRONS", "PSYCHOMANCER", "INFANTRY", "CHARACTER", "CRYPTEK"],
			[{"id": "abyssal-lance", "profiles": {"standard": _weapon("Abyssal lance", 18.0, 1, 4, 6, -3, 3, {})}}],
			[{"id": "abyssal-lance", "profiles": {"standard": _weapon("Abyssal lance", 0.0, 1, 4, 6, -3, 3, {})}}],
			["Support", "Reanimation Protocols", "Nightmare Shroud (Aura)", "Harbinger of Despair"], ["support"], ["Reanimation Protocols", "Nightmare Shroud (Aura)", "Harbinger of Despair"], [],
			["000000534", "000000535"])
	if source == "chronomancer":
		var chronomancer := _record("chronomancer", "Chronomancer", "000002354", "Chronomancer", {1: 70}, 1, 40,
			{"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
			["NECRONS", "CHARACTER", "INFANTRY", "CHRONOMANCER", "CRYPTEK"],
			[{"id": "aeonstave", "profiles": {"standard": _weapon("Aeonstave", 18.0, "D6", 4, 5, -1, 1, {"blast": true})}}],
			[{"id": "aeonstave", "profiles": {"standard": _weapon("Aeonstave", 0.0, 3, 4, 5, -1, 1, {})}}],
			["Support", "Reanimation Protocols", "Timesplinter Mantle", "Chronometron"], ["support"], ["Reanimation Protocols", "Timesplinter Mantle", "Chronometron"], [],
			["000000534", "000000535"], [], {1: 80})
		chronomancer.source_loadout_label = "Chronomancer’s stave"
		chronomancer.source_wargear_table_label = "Aeonstave"
		chronomancer.source_label_note = "The local export and current App page both use Chronomancer’s stave in composition text and Aeonstave in the weapon table; runtime profile keys the weapon-table entry."
		return chronomancer
	if source != "necron-warriors": return {}
	return {
		"name": "Necron Warriors",
		"source_book_id": SOURCE_BOOK_ID,
		"source_book_version": SOURCE_BOOK_VERSION,
		"source_datasheet_id": SOURCE_DATASHEET_ID,
		"source_snapshot_id": SNAPSHOT_ID,
		"source_export_updated_at": EXPORT_UPDATED_AT,
		"source_manifest_sha256": PARENT_MANIFEST_SHA256,
		"source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
		"source_slice_catalog_sha256": SLICE_CATALOG_SHA256,
		"source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
		"source_url": SOURCE_URL,
		"points": 85,
		"points_by_models": {10: 85, 20: 190},
		"construction_model_sizes": [10, 20],
		"models": 10,
		"base_radius_inches": 16.0 / 25.4,
		"stats": {"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["NECRONS", "INFANTRY", "BATTLELINE", "NECRON WARRIORS"],
		"ranged": [
			{"id": "gauss-flayer", "profiles": {"standard": _weapon("Gauss flayer", 24.0, 1, 4, 4, 0, 1, {"lethal-hits": true, "rapid-fire": 1})}}
		],
		"melee": [
			{"id": "close-combat-weapon", "profiles": {"standard": _weapon("Close combat weapon", 0.0, 1, 4, 4, 0, 1, {})}}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{"id": "gauss-reaper", "profiles": {"standard": _weapon("Gauss reaper", 12.0, 2, 4, 4, -1, 1, {"lethal-hits": true})}}
			]
		},
		"supported_rule_ids": ["reanimation-protocols", "their-number-is-legion"],
		"source_ability_names": ["Reanimation Protocols", "Their Number is Legion"],
		"source_options": [
			{"id": "gauss-reaper-replacement", "kind": "per_model_weapon_replacement", "from": "gauss-flayer", "to": "gauss-reaper", "minimum": 0, "maximum": "unit_size", "implemented": true}
		],
		"source_scope": "Necrons App v1.2",
		"unsupported_abilities": []
	}

static func catalog() -> Dictionary:
	var result := {"necron-warriors": profile("necron-warriors"), "immortals": profile("immortals"),
		"overlord": profile("overlord"), "royal-warden": profile("royal-warden"),
		"orikan-the-diviner": profile("orikan-the-diviner"), "trazyn-the-infinite": profile("trazyn-the-infinite"),
		"lychguard": profile("lychguard"), "deathmarks": profile("deathmarks"),
		"flayed-ones": profile("flayed-ones"), "triarch-praetorians": profile("triarch-praetorians"),
		"skorpekh-destroyers": profile("skorpekh-destroyers"), "canoptek-scarab-swarms": profile("canoptek-scarab-swarms"),
		"canoptek-wraiths": profile("canoptek-wraiths"), "canoptek-reanimator": profile("canoptek-reanimator"),
		"ghost-ark": profile("ghost-ark"), "canoptek-doomstalker": profile("canoptek-doomstalker"),
		"doomsday-ark": profile("doomsday-ark"), "monolith": profile("monolith"),
		"catacomb-command-barge": profile("catacomb-command-barge"), "triarch-stalker": profile("triarch-stalker"),
		"hexmark-destroyer": profile("hexmark-destroyer"), "ophydian-destroyers": profile("ophydian-destroyers"),
		"lokhust-destroyers": profile("lokhust-destroyers"), "lokhust-heavy-destroyers": profile("lokhust-heavy-destroyers"),
		"imotekh-the-stormlord": profile("imotekh-the-stormlord"), "illuminor-szeras": profile("illuminor-szeras"),
		"plasmancer": profile("plasmancer"), "skorpekh-lord": profile("skorpekh-lord"),
		"lokhust-lord": profile("lokhust-lord"), "technomancer": profile("technomancer"),
		"psychomancer": profile("psychomancer"), "chronomancer": profile("chronomancer")}
	result.merge(RemainingProfiles.catalog(), false)
	return result

static func digest() -> String:
	return var_to_str({"id": ID, "snapshot_id": SNAPSHOT_ID, "parent_manifest_sha256": PARENT_MANIFEST_SHA256,
		"slice_manifest_sha256": SLICE_MANIFEST_SHA256, "source_sheets": SOURCE_SHEETS, "profiles": catalog()}).sha256_text()

static func _record(source: String, display_name: String, datasheet_id: String, slug: String, costs: Dictionary,
		default_models: int, base_size_mm: float, stats: Dictionary, keywords: Array, ranged: Array, melee: Array,
		ability_names: Array, supported_rules: Array, unsupported_abilities: Array, leader_ids: Array,
		bodyguard_ids: Array = [], options: Array = [], third_plus_costs: Dictionary = {}) -> Dictionary:
	var result := {
		"name": display_name, "source_book_id": SOURCE_BOOK_ID, "source_book_version": SOURCE_BOOK_VERSION,
		"source_datasheet_id": datasheet_id, "source_snapshot_id": SNAPSHOT_ID, "source_export_updated_at": EXPORT_UPDATED_AT,
		"source_manifest_sha256": PARENT_MANIFEST_SHA256, "source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
		"source_slice_catalog_sha256": SLICE_CATALOG_SHA256, "source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/" + slug,
		"points": costs[default_models], "points_by_models": costs.duplicate(true), "construction_model_sizes": costs.keys(),
		"models": default_models, "base_size_source_mm": base_size_mm, "base_radius_inches": float(base_size_mm) / 50.8,
		"stats": stats.duplicate(true), "keywords": keywords.duplicate(), "ranged": ranged.duplicate(true), "melee": melee.duplicate(true),
		"source_ability_names": ability_names.duplicate(), "supported_rule_ids": supported_rules.duplicate(),
		"unsupported_abilities": unsupported_abilities.duplicate(), "source_scope": "Necrons App v1.2"
	}
	if not leader_ids.is_empty(): result.source_leader_datasheet_ids = leader_ids.duplicate()
	if not bodyguard_ids.is_empty(): result.source_bodyguard_datasheet_ids = bodyguard_ids.duplicate()
	if not options.is_empty(): result.source_options = options.duplicate(true)
	if not third_plus_costs.is_empty(): result.third_plus_points_by_models = third_plus_costs.duplicate(true)
	if "EPIC HERO" in keywords: result.max_supported_copies = 1
	return result

static func _weapon(label: String, range_inches: float, attacks: Variant, skill: Variant, strength: int, ap: int, damage: Variant, keywords: Dictionary) -> Dictionary:
	return {"name": label, "range_inches": range_inches, "attacks": attacks, "skill": skill,
		"strength": strength, "ap": ap, "damage": damage, "keywords": keywords}

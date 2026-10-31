extends RefCounted
## Locally transcribed Necrons App v1.2 facts for the remaining 19 core sheets.
## These source records remain excluded until their abilities, loadouts, options and interactions pass focused checks.
const SNAPSHOT_ID := "20261031T053336Z"
const SOURCE_BOOK_ID := "000000029"
const SOURCE_BOOK_VERSION := "1.2"
const SOURCE_SCOPE := "Necrons App v1.2"
const SOURCE_EXPORT_UPDATED_AT := "2026-10-30T22:19:16+03:00"
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
const SOURCE_METADATA := {
    "source_book_id": SOURCE_BOOK_ID, "source_book_version": SOURCE_BOOK_VERSION,
    "source_scope": SOURCE_SCOPE, "source_snapshot_id": SNAPSHOT_ID,
    "source_export_updated_at": SOURCE_EXPORT_UPDATED_AT, "source_manifest_sha256": PARENT_MANIFEST_SHA256,
    "source_slice_manifest_sha256": SLICE_MANIFEST_SHA256, "source_slice_catalog_sha256": SLICE_CATALOG_SHA256
}
const SOURCE_PROFILE_DATA := {
	"annihilation-barge": {
		"name": "Annihilation Barge",
		"source_datasheet_id": "000000553",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Annihilation-Barge",
		"source_role": "Vehicle",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551003",
			"000008551004",
			"000008555003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 100,
		"points_by_models": {
			1: 100
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 60,
		"base_size_source": "60mm flying base",
		"base_radius_inches": 1.1811023622047245,
		"stats": {
			"movement_inches": 10,
			"toughness": 8,
			"save_target": 3,
			"wounds": 9,
			"leadership_target": 7,
			"objective_control": 3,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"VEHICLE",
			"FLY",
			"FRAME",
			"ANNIHILATION BARGE"
		],
		"source_keywords": [
			"Necrons",
			"Vehicle",
			"Fly",
			"Frame",
			"Annihilation Barge"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Frame",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Annihilation Barge",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Gauss cannon",
						"range_inches": 24,
						"attacks": 3,
						"skill": 3,
						"strength": 5,
						"ap": -2,
						"damage": 2,
						"keywords": {
							"lethal-hits": true
						}
					}
				}
			},
			{
				"id": "source-ranged-3",
				"profiles": {
					"standard": {
						"name": "Twin tesla destructor",
						"range_inches": 36,
						"attacks": 6,
						"skill": 3,
						"strength": 8,
						"ap": 0,
						"damage": 2,
						"keywords": {
							"sustained-hits": 2,
							"twin-linked": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-4",
				"profiles": {
					"standard": {
						"name": "Armoured bulk",
						"range_inches": 0,
						"attacks": 3,
						"skill": 4,
						"strength": 6,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Tesla cannon",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla cannon",
							"range_inches": 24,
							"attacks": 4,
							"skill": 3,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Annihilation Barge",
				"stats": {
					"movement_inches": 10,
					"toughness": 8,
					"save_target": 3,
					"wounds": 9,
					"leadership_target": 7,
					"objective_control": 3,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "10\"",
					"T": "8",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "9",
					"Ld": "7+",
					"OC": "3"
				},
				"base_size_source": "60mm flying base",
				"base_size_source_mm": 60
			}
		],
		"source_composition_rows": [
			"1 Annihilation Barge"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 100
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "gauss cannon"
					},
					{
						"count": 1,
						"name": "twin tesla destructor"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "gauss cannon"
					},
					{
						"weapon_id": "source-ranged-3",
						"count_per_model": 1,
						"name": "twin tesla destructor"
					},
					{
						"weapon_id": "source-melee-4",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Gauss cannon",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Gauss cannon",
							"range_inches": 24,
							"attacks": 3,
							"skill": 3,
							"strength": 5,
							"ap": -2,
							"damage": 2,
							"keywords": {
								"lethal-hits": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Tesla cannon",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla cannon",
							"range_inches": 24,
							"attacks": 4,
							"skill": 3,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Twin tesla destructor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin tesla destructor",
							"range_inches": 36,
							"attacks": 6,
							"skill": 3,
							"strength": 8,
							"ap": 0,
							"damage": 2,
							"keywords": {
								"sustained-hits": 2,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-4",
					"source_line": 4,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 3,
							"skill": 4,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Malevolent Arcing"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "1"
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Malevolent Arcing",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [
			{
				"source_line": 1,
				"description": "This model’s gauss cannon can be replaced with 1 tesla cannon.",
				"implemented": false
			}
		],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-1"],
		"unsupported_abilities": [
			"Malevolent Arcing"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"ctan-shard-of-the-deceiver": {
		"name": "C’tan Shard of the Deceiver",
		"source_datasheet_id": "000000542",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/C-tan-Shard-of-the-Deceiver",
		"source_role": "Monster Epic Hero",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551003",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673002",
			"000010673003",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000010672002"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000010671"
		],
		"points": 330,
		"points_by_models": {
			1: 330
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 40,
		"base_size_source": "40mm",
		"base_radius_inches": 0.7874015748031497,
		"stats": {
			"movement_inches": 8,
			"toughness": 11,
			"save_target": 3,
			"wounds": 16,
			"leadership_target": 6,
			"objective_control": 4,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"MONSTER",
			"CHARACTER",
			"FLY",
			"C’TAN SHARD OF THE DECEIVER",
			"EPIC HERO"
		],
		"source_keywords": [
			"Necrons",
			"Monster",
			"Character",
			"Fly",
			"C’tan Shard of the Deceiver",
			"Epic Hero"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Monster",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "C’tan Shard of the Deceiver",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Epic Hero",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Cosmic insanity",
						"range_inches": 18,
						"attacks": 6,
						"skill": 2,
						"strength": 6,
						"ap": -2,
						"damage": 2,
						"keywords": {
							"anti-character": 4,
							"devastating-wounds": true,
							"precision": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Golden fists",
						"range_inches": 0,
						"attacks": 8,
						"skill": 2,
						"strength": 10,
						"ap": -3,
						"damage": 3,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "C’tan Shard of the Deceiver",
				"stats": {
					"movement_inches": 8,
					"toughness": 11,
					"save_target": 3,
					"wounds": 16,
					"leadership_target": 6,
					"objective_control": 4,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "8\"",
					"T": "11",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "16",
					"Ld": "6+",
					"OC": "4"
				},
				"base_size_source": "40mm",
				"base_size_source_mm": 40
			}
		],
		"source_composition_rows": [
			"1 C’tan Shard of the Deceiver – EPIC HERO"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 330
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "cosmic insanity"
					},
					{
						"count": 1,
						"name": "golden fists"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "cosmic insanity"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "golden fists"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Cosmic insanity",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Cosmic insanity",
							"range_inches": 18,
							"attacks": 6,
							"skill": 2,
							"strength": 6,
							"ap": -2,
							"damage": 2,
							"keywords": {
								"anti-character": 4,
								"devastating-wounds": true,
								"precision": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Golden fists",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Golden fists",
							"range_inches": 0,
							"attacks": 8,
							"skill": 2,
							"strength": 10,
							"ap": -3,
							"damage": 3,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Feel No Pain",
			"Stealth",
			"Reanimation Protocols",
			"Grand Illusion",
			"Necrodermis",
			"ENSLAVED STAR GOD"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008338",
				"name": "Feel No Pain",
				"model_role": "",
				"type": "Core",
				"parameter": "5+"
			},
			{
				"source_line": 4,
				"ability_id": "000008337",
				"name": "Stealth",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Grand Illusion",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "Necrodermis",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 8,
				"ability_id": "",
				"name": "ENSLAVED STAR GOD",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "stealth", "necrodermis", "enslaved-star-god"],
		"unsupported_abilities": [
			"Grand Illusion"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending",
		"max_supported_copies": 1
	},
	"ctan-shard-of-the-nightbringer": {
		"name": "C’tan Shard of the Nightbringer",
		"source_datasheet_id": "000000541",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/C-tan-Shard-of-the-Nightbringer",
		"source_role": "Monster Epic Hero",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551003",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673002",
			"000010673003",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000010672003"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000010671"
		],
		"points": 360,
		"points_by_models": {
			1: 360
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 90,
		"base_size_source": "90mm",
		"base_radius_inches": 1.7716535433070868,
		"stats": {
			"movement_inches": 10,
			"toughness": 11,
			"save_target": 3,
			"wounds": 16,
			"leadership_target": 6,
			"objective_control": 4,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"CHARACTER",
			"EPIC HERO",
			"FLY",
			"C’TAN SHARD OF THE NIGHTBRINGER",
			"MONSTER"
		],
		"source_keywords": [
			"Necrons",
			"Character",
			"Epic Hero",
			"Fly",
			"C’tan Shard of the Nightbringer",
			"Monster"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Epic Hero",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "C’tan Shard of the Nightbringer",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Monster",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Gaze of death",
						"range_inches": 18,
						"attacks": "D3",
						"skill": 2,
						"strength": 12,
						"ap": -3,
						"damage": "D6+3",
						"keywords": {}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"strike": {
						"name": "Scythe of the Nightbringer – strike",
						"range_inches": 0,
						"attacks": 6,
						"skill": 2,
						"strength": 14,
						"ap": -4,
						"damage": "D6+2",
						"keywords": {
							"devastating-wounds": true
						}
					},
					"sweep": {
						"name": "Scythe of the Nightbringer – sweep",
						"range_inches": 0,
						"attacks": 14,
						"skill": 2,
						"strength": 8,
						"ap": -2,
						"damage": 2,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "C’tan Shard of the Nightbringer",
				"stats": {
					"movement_inches": 10,
					"toughness": 11,
					"save_target": 3,
					"wounds": 16,
					"leadership_target": 6,
					"objective_control": 4,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "10\"",
					"T": "11",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "16",
					"Ld": "6+",
					"OC": "4"
				},
				"base_size_source": "90mm",
				"base_size_source_mm": 90
			}
		],
		"source_composition_rows": [
			"1 C’tan Shard of the Nightbringer – EPIC HERO"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 360
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "gaze of death"
					},
					{
						"count": 1,
						"name": "scythe of the Nightbringer"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "gaze of death"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "scythe of the Nightbringer"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Gaze of death",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Gaze of death",
							"range_inches": 18,
							"attacks": "D3",
							"skill": 2,
							"strength": 12,
							"ap": -3,
							"damage": "D6+3",
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Scythe of the Nightbringer",
					"type": "melee",
					"profiles": {
						"strike": {
							"name": "Scythe of the Nightbringer – strike",
							"range_inches": 0,
							"attacks": 6,
							"skill": 2,
							"strength": 14,
							"ap": -4,
							"damage": "D6+2",
							"keywords": {
								"devastating-wounds": true
							}
						},
						"sweep": {
							"name": "Scythe of the Nightbringer – sweep",
							"range_inches": 0,
							"attacks": 14,
							"skill": 2,
							"strength": 8,
							"ap": -2,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Feel No Pain",
			"Reanimation Protocols",
			"Drain Life",
			"Necrodermis",
			"ENSLAVED STAR GOD"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008338",
				"name": "Feel No Pain",
				"model_role": "",
				"type": "Core",
				"parameter": "5+"
			},
			{
				"source_line": 4,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Drain Life",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Necrodermis",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "ENSLAVED STAR GOD",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "necrodermis", "enslaved-star-god"],
		"unsupported_abilities": [
			"Drain Life"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending",
		"max_supported_copies": 1
	},
	"ctan-shard-of-the-void-dragon": {
		"name": "C’tan Shard of the Void Dragon",
		"source_datasheet_id": "000002357",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/C-tan-Shard-of-the-Void-Dragon",
		"source_role": "Monster Epic Hero",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551003",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673002",
			"000010673003",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000010672004"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000010671"
		],
		"points": 345,
		"points_by_models": {
			1: 345
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 80,
		"base_size_source": "80mm",
		"base_radius_inches": 1.5748031496062993,
		"stats": {
			"movement_inches": 10,
			"toughness": 11,
			"save_target": 3,
			"wounds": 16,
			"leadership_target": 6,
			"objective_control": 4,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"C’TAN SHARD OF THE VOID DRAGON",
			"FLY",
			"MONSTER",
			"CHARACTER",
			"EPIC HERO"
		],
		"source_keywords": [
			"Necrons",
			"C’tan Shard of the Void Dragon",
			"Fly",
			"Monster",
			"Character",
			"Epic Hero"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "C’tan Shard of the Void Dragon",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Monster",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Epic Hero",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Spear of the Void Dragon",
						"range_inches": 12,
						"attacks": "D3",
						"skill": 2,
						"strength": 8,
						"ap": -3,
						"damage": "D6+2",
						"keywords": {
							"anti-vehicle": 2
						}
					}
				}
			},
			{
				"id": "source-ranged-2",
				"profiles": {
					"standard": {
						"name": "Voltaic storm",
						"range_inches": 18,
						"attacks": "D6+3",
						"skill": 2,
						"strength": 7,
						"ap": -1,
						"damage": 2,
						"keywords": {
							"blast": true,
							"sustained-hits": 2
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-3",
				"profiles": {
					"strike": {
						"name": "Spear of the Void Dragon – strike",
						"range_inches": 0,
						"attacks": 5,
						"skill": 2,
						"strength": 12,
						"ap": -4,
						"damage": "D6+2",
						"keywords": {
							"anti-vehicle": 2
						}
					},
					"sweep": {
						"name": "Spear of the Void Dragon – sweep",
						"range_inches": 0,
						"attacks": 10,
						"skill": 2,
						"strength": 8,
						"ap": -1,
						"damage": 2,
						"keywords": {}
					}
				}
			},
			{
				"id": "source-melee-5",
				"profiles": {
					"standard": {
						"name": "Canoptek tail blades",
						"range_inches": 0,
						"attacks": 6,
						"skill": 2,
						"strength": 6,
						"ap": -1,
						"damage": 1,
						"keywords": {
							"extra-attacks": true
						}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "C’tan Shard of the Void Dragon",
				"stats": {
					"movement_inches": 10,
					"toughness": 11,
					"save_target": 3,
					"wounds": 16,
					"leadership_target": 6,
					"objective_control": 4,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "10\"",
					"T": "11",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "16",
					"Ld": "6+",
					"OC": "4"
				},
				"base_size_source": "80mm",
				"base_size_source_mm": 80
			}
		],
		"source_composition_rows": [
			"1 C’tan Shard of the Void Dragon – EPIC HERO"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 345
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "spear of the Void Dragon"
					},
					{
						"count": 1,
						"name": "voltaic storm"
					},
					{
						"count": 1,
						"name": "canoptek tail blades"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "spear of the Void Dragon"
					},
					{
						"weapon_id": "source-melee-3",
						"count_per_model": 1,
						"name": "spear of the Void Dragon"
					},
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "voltaic storm"
					},
					{
						"weapon_id": "source-melee-5",
						"count_per_model": 1,
						"name": "canoptek tail blades"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Spear of the Void Dragon",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Spear of the Void Dragon",
							"range_inches": 12,
							"attacks": "D3",
							"skill": 2,
							"strength": 8,
							"ap": -3,
							"damage": "D6+2",
							"keywords": {
								"anti-vehicle": 2
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Voltaic storm",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Voltaic storm",
							"range_inches": 18,
							"attacks": "D6+3",
							"skill": 2,
							"strength": 7,
							"ap": -1,
							"damage": 2,
							"keywords": {
								"blast": true,
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-3",
					"source_line": 3,
					"name": "Spear of the Void Dragon",
					"type": "melee",
					"profiles": {
						"strike": {
							"name": "Spear of the Void Dragon – strike",
							"range_inches": 0,
							"attacks": 5,
							"skill": 2,
							"strength": 12,
							"ap": -4,
							"damage": "D6+2",
							"keywords": {
								"anti-vehicle": 2
							}
						},
						"sweep": {
							"name": "Spear of the Void Dragon – sweep",
							"range_inches": 0,
							"attacks": 10,
							"skill": 2,
							"strength": 8,
							"ap": -1,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-melee-5",
					"source_line": 5,
					"name": "Canoptek tail blades",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Canoptek tail blades",
							"range_inches": 0,
							"attacks": 6,
							"skill": 2,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"extra-attacks": true
							}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Feel No Pain",
			"Reanimation Protocols",
			"Matter Absorption",
			"Necrodermis",
			"ENSLAVED STAR GOD"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008338",
				"name": "Feel No Pain",
				"model_role": "",
				"type": "Core",
				"parameter": "5+"
			},
			{
				"source_line": 4,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Matter Absorption",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Necrodermis",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "ENSLAVED STAR GOD",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "necrodermis", "enslaved-star-god"],
		"unsupported_abilities": [
			"Matter Absorption"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending",
		"max_supported_copies": 1
	},
	"canoptek-macrocytes": {
		"name": "Canoptek Macrocytes",
		"source_datasheet_id": "000004176",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Canoptek-Macrocytes",
		"source_role": "Beast",
		"source_is_support": false,
		"source_leader_relations": [
			{
				"leader_id": "000004178",
				"attached_id": "000004176",
				"": ""
			}
		],
		"source_leader_datasheet_ids": [
			"000004178"
		],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008547003",
			"000008547005",
			"000008547006",
			"000008547007",
			"000008551003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008545",
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 70,
		"points_by_models": {
			5: 70
		},
		"construction_model_sizes": [
			5
		],
		"models": 5,
		"base_size_source_mm": 28.5,
		"base_size_source": "28.5mm",
		"base_radius_inches": 0.5610236220472441,
		"stats": {
			"movement_inches": 8,
			"toughness": 3,
			"save_target": 4,
			"wounds": 1,
			"leadership_target": 8,
			"objective_control": 1,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"BEASTS",
			"FLY",
			"CANOPTEK",
			"MACROCYTES"
		],
		"source_keywords": [
			"Necrons",
			"Beasts",
			"Fly",
			"Canoptek",
			"Macrocytes"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Beasts",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Canoptek",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Macrocytes",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-2",
				"profiles": {
					"standard": {
						"name": "Gauss scalpel",
						"range_inches": 18,
						"attacks": 1,
						"skill": 4,
						"strength": 4,
						"ap": -1,
						"damage": 1,
						"keywords": {
							"lethal-hits": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-4",
				"profiles": {
					"standard": {
						"name": "Claws",
						"range_inches": 0,
						"attacks": 2,
						"skill": 4,
						"strength": 4,
						"ap": -1,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Atomiser beam",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Atomiser beam",
							"range_inches": 12,
							"attacks": 1,
							"skill": 4,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Tesla caster",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla caster",
							"range_inches": 18,
							"attacks": 1,
							"skill": 4,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"assault": true,
								"sustained-hits": 1
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Canoptek Macrocytes",
				"stats": {
					"movement_inches": 8,
					"toughness": 3,
					"save_target": 4,
					"wounds": 1,
					"leadership_target": 8,
					"objective_control": 1,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "8\"",
					"T": "3",
					"Sv": "4+",
					"inv_sv": "-",
					"W": "1",
					"Ld": "8+",
					"OC": "1"
				},
				"base_size_source": "28.5mm",
				"base_size_source_mm": 28.5
			}
		],
		"source_composition_rows": [
			"5 Canoptek Macrocytes"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 5,
				"points": 70
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "gauss scalpel"
					},
					{
						"count": 1,
						"name": "claws"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "gauss scalpel"
					},
					{
						"weapon_id": "source-melee-4",
						"count_per_model": 1,
						"name": "claws"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Atomiser beam",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Atomiser beam",
							"range_inches": 12,
							"attacks": 1,
							"skill": 4,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Gauss scalpel",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Gauss scalpel",
							"range_inches": 18,
							"attacks": 1,
							"skill": 4,
							"strength": 4,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"lethal-hits": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Tesla caster",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla caster",
							"range_inches": 18,
							"attacks": 1,
							"skill": 4,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"assault": true,
								"sustained-hits": 1
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-4",
					"source_line": 4,
					"name": "Claws",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Claws",
							"range_inches": 0,
							"attacks": 2,
							"skill": 4,
							"strength": 4,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Scouts",
			"Reanimation Protocols",
			"Harassment Swarm (Aura)",
			"Accelerator Mandible",
			"Nanoscarab Projector"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008344",
				"name": "Scouts",
				"model_role": "",
				"type": "Core",
				"parameter": "8\""
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Harassment Swarm (Aura)",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Accelerator Mandible",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Nanoscarab Projector",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			}
		],
		"source_options": [
			{
				"source_line": 1,
				"description": "All models in this unit can each have their gauss scalpel replaced with 1 tesla caster.",
				"implemented": false
			},
			{
				"source_line": 2,
				"description": "1 model’s gauss scalpel or tesla caster can be replaced with 1 atomiser beam and 1 nanoscarab projector.",
				"implemented": false
			},
			{
				"source_line": 3,
				"description": "1 model’s gauss scalpel or tesla caster can be replaced with 1 accelerator mandible.",
				"implemented": false
			}
		],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "scouts-8"],
		"unsupported_abilities": [
			"Harassment Swarm (Aura)",
			"Accelerator Mandible",
			"Nanoscarab Projector"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"canoptek-spyders": {
		"name": "Canoptek Spyders",
		"source_datasheet_id": "000000551",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Canoptek-Spyders",
		"source_role": "Vehicle",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008547003",
			"000008547005",
			"000008547006",
			"000008547007",
			"000008551003",
			"000008551004",
			"000008555003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008545",
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 65,
		"points_by_models": {
			1: 65,
			2: 110
		},
		"construction_model_sizes": [
			1,
			2
		],
		"models": 1,
		"base_size_source_mm": 60,
		"base_size_source": "60mm flying base",
		"base_radius_inches": 1.1811023622047245,
		"stats": {
			"movement_inches": 5,
			"toughness": 7,
			"save_target": 3,
			"wounds": 6,
			"leadership_target": 8,
			"objective_control": 2,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"CANOPTEK",
			"FLY",
			"VEHICLE",
			"SPYDERS"
		],
		"source_keywords": [
			"Necrons",
			"Canoptek",
			"Fly",
			"Vehicle",
			"Spyders"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Canoptek",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Spyders",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Automaton claws",
						"range_inches": 0,
						"attacks": 5,
						"skill": 4,
						"strength": 8,
						"ap": -2,
						"damage": 2,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Particle beamer",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Particle beamer",
							"range_inches": 18,
							"attacks": "D6",
							"skill": 3,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"blast": true,
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Canoptek Spyders",
				"stats": {
					"movement_inches": 5,
					"toughness": 7,
					"save_target": 3,
					"wounds": 6,
					"leadership_target": 8,
					"objective_control": 2,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "5\"",
					"T": "7",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "6",
					"Ld": "8+",
					"OC": "2"
				},
				"base_size_source": "60mm flying base",
				"base_size_source_mm": 60
			}
		],
		"source_composition_rows": [
			"1-2 Canoptek Spyders"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 65
			},
			{
				"category": "ordinary",
				"models": 2,
				"points": 110
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "automaton claws"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "automaton claws"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Particle beamer",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Particle beamer",
							"range_inches": 18,
							"attacks": "D6",
							"skill": 3,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"blast": true,
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Automaton claws",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Automaton claws",
							"range_inches": 0,
							"attacks": 5,
							"skill": 4,
							"strength": 8,
							"ap": -2,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Fabricator Claw Array (Aura)",
			"Gloom Prism (Aura)",
			"Canoptek Swarm"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "1"
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Fabricator Claw Array (Aura)",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Gloom Prism (Aura)",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Canoptek Swarm",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [
			{
				"source_line": 1,
				"description": "Any number of models can each be equipped with 2 particle beamers.",
				"implemented": false
			},
			{
				"source_line": 2,
				"description": "Any number of models can each be equipped with 1 fabricator claw array.",
				"implemented": false
			},
			{
				"source_line": 3,
				"description": "Any number of models can each be equipped with 1 gloom prism.",
				"implemented": false
			}
		],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-1"],
		"unsupported_abilities": [
			"Fabricator Claw Array (Aura)",
			"Gloom Prism (Aura)",
			"Canoptek Swarm"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"canoptek-tomb-crawlers": {
		"name": "Canoptek Tomb Crawlers",
		"source_datasheet_id": "000004177",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Canoptek-Tomb-Crawlers",
		"source_role": "Beast",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008547003",
			"000008547005",
			"000008547006",
			"000008547007",
			"000008551003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008545",
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 60,
		"points_by_models": {
			2: 60
		},
		"construction_model_sizes": [
			2
		],
		"models": 2,
		"base_size_source_mm": 50,
		"base_size_source": "50mm",
		"base_radius_inches": 0.984251968503937,
		"stats": {
			"movement_inches": 5,
			"toughness": 4,
			"save_target": 3,
			"wounds": 3,
			"leadership_target": 8,
			"objective_control": 1,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"CANOPTEK",
			"BEASTS",
			"TOMB CRAWLERS"
		],
		"source_keywords": [
			"Necrons",
			"Canoptek",
			"Beasts",
			"Tomb Crawlers"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Canoptek",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Beasts",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Tomb Crawlers",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-2",
				"profiles": {
					"standard": {
						"name": "Twin gauss reaper",
						"range_inches": 12,
						"attacks": 2,
						"skill": 4,
						"strength": 4,
						"ap": -1,
						"damage": 1,
						"keywords": {
							"lethal-hits": true,
							"twin-linked": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-3",
				"profiles": {
					"standard": {
						"name": "Claws",
						"range_inches": 0,
						"attacks": 4,
						"skill": 4,
						"strength": 6,
						"ap": -1,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Transdimensional isolator",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Transdimensional isolator",
							"range_inches": 12,
							"attacks": 2,
							"skill": 4,
							"strength": 4,
							"ap": -2,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Canoptek Tomb Crawlers",
				"stats": {
					"movement_inches": 5,
					"toughness": 4,
					"save_target": 3,
					"wounds": 3,
					"leadership_target": 8,
					"objective_control": 1,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "5\"",
					"T": "4",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "3",
					"Ld": "8+",
					"OC": "1"
				},
				"base_size_source": "50mm",
				"base_size_source_mm": 50
			}
		],
		"source_composition_rows": [
			"2 Canoptek Tomb Crawlers"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 2,
				"points": 60
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "twin gauss reaper"
					},
					{
						"count": 1,
						"name": "claws"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "twin gauss reaper"
					},
					{
						"weapon_id": "source-melee-3",
						"count_per_model": 1,
						"name": "claws"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Transdimensional isolator",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Transdimensional isolator",
							"range_inches": 12,
							"attacks": 2,
							"skill": 4,
							"strength": 4,
							"ap": -2,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Twin gauss reaper",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin gauss reaper",
							"range_inches": 12,
							"attacks": 2,
							"skill": 4,
							"strength": 4,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"lethal-hits": true,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-3",
					"source_line": 3,
					"name": "Claws",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Claws",
							"range_inches": 0,
							"attacks": 4,
							"skill": 4,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Reanimation Protocols",
			"Weapon Sentinels",
			"CANOPTEK RETINUE"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "",
				"name": "Weapon Sentinels",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "CANOPTEK RETINUE",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [
			{
				"source_line": 1,
				"description": "1 model’s twin gauss reaper can be replaced with 1 transdimensional isolator.",
				"implemented": false
			}
		],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Weapon Sentinels",
			"CANOPTEK RETINUE"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"doom-scythe": {
		"name": "Doom Scythe",
		"source_datasheet_id": "000000545",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Doom-Scythe",
		"source_role": "Aircraft",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371006",
			"000008551003",
			"000008551004",
			"000008555003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 200,
		"points_by_models": {
			1: 200
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 92,
		"base_size_source": "120 x 92mm flying base",
		"base_radius_inches": 1.8110236220472442,
		"stats": {
			"movement_inches": 0,
			"toughness": 9,
			"save_target": 3,
			"wounds": 12,
			"leadership_target": 7,
			"objective_control": 0,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"VEHICLE",
			"FLY",
			"DOOM SCYTHE",
			"AIRCRAFT"
		],
		"source_keywords": [
			"Necrons",
			"Vehicle",
			"Fly",
			"Doom Scythe",
			"Aircraft"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Doom Scythe",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Aircraft",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Heavy death ray",
						"range_inches": 36,
						"attacks": 3,
						"skill": 3,
						"strength": 16,
						"ap": -4,
						"damage": "D6+1",
						"keywords": {
							"sustained-hits": "d3"
						}
					}
				}
			},
			{
				"id": "source-ranged-2",
				"profiles": {
					"standard": {
						"name": "Twin tesla destructor",
						"range_inches": 36,
						"attacks": 6,
						"skill": 3,
						"strength": 8,
						"ap": 0,
						"damage": 2,
						"keywords": {
							"sustained-hits": 2,
							"twin-linked": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-3",
				"profiles": {
					"standard": {
						"name": "Armoured bulk",
						"range_inches": 0,
						"attacks": 3,
						"skill": 4,
						"strength": 6,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Doom Scythe",
				"stats": {
					"movement_inches": 0,
					"toughness": 9,
					"save_target": 3,
					"wounds": 12,
					"leadership_target": 7,
					"objective_control": 0,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "-",
					"T": "9",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "12",
					"Ld": "7+",
					"OC": "-"
				},
				"base_size_source": "120 x 92mm flying base",
				"base_size_source_mm": 92
			}
		],
		"source_composition_rows": [
			"1 Doom Scythe"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 200
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "heavy death ray"
					},
					{
						"count": 1,
						"name": "twin tesla destructor"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "heavy death ray"
					},
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "twin tesla destructor"
					},
					{
						"weapon_id": "source-melee-3",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Heavy death ray",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Heavy death ray",
							"range_inches": 36,
							"attacks": 3,
							"skill": 3,
							"strength": 16,
							"ap": -4,
							"damage": "D6+1",
							"keywords": {
								"sustained-hits": "d3"
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Twin tesla destructor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin tesla destructor",
							"range_inches": 36,
							"attacks": 6,
							"skill": 3,
							"strength": 8,
							"ap": 0,
							"damage": 2,
							"keywords": {
								"sustained-hits": 2,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-3",
					"source_line": 3,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 3,
							"skill": 4,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Atavistic Instigation"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D3"
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Atavistic Instigation",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "1-4",
		"source_damaged_description": "While this model has 1-4 wounds remaining, each time this model makes an attack, subtract 1 from the Hit roll.",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d3"],
		"unsupported_abilities": [
			"Atavistic Instigation"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"convergence-of-dominion": {
		"name": "Convergence Of Dominion",
		"source_datasheet_id": "000002361",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Convergence-Of-Dominion",
		"source_role": "Fortifications",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371006",
			"000008551003",
			"000008551004",
			"000008555003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 60,
		"points_by_models": {
			1: 60,
			2: 120,
			3: 180
		},
		"construction_model_sizes": [
			1,
			2,
			3
		],
		"models": 1,
		"base_size_source_mm": 0,
		"base_size_source": "Use model",
		"base_radius_inches": 0,
		"stats": {
			"movement_inches": 0,
			"toughness": 9,
			"save_target": 3,
			"wounds": 7,
			"leadership_target": 8,
			"objective_control": 0,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"VEHICLE",
			"FORTIFICATION",
			"CONVERGENCE OF DOMINION",
			"FRAME"
		],
		"source_keywords": [
			"Necrons",
			"Vehicle",
			"Fortification",
			"Convergence of Dominion",
			"Frame"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fortification",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Convergence of Dominion",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Frame",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Transdimensional abductor",
						"range_inches": 18,
						"attacks": 3,
						"skill": 4,
						"strength": 6,
						"ap": -2,
						"damage": 3,
						"keywords": {}
					}
				}
			}
		],
		"melee": [],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Convergence Of Dominion",
				"stats": {
					"movement_inches": 0,
					"toughness": 9,
					"save_target": 3,
					"wounds": 7,
					"leadership_target": 8,
					"objective_control": 0,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "-",
					"T": "9",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "7",
					"Ld": "8+",
					"OC": "0"
				},
				"base_size_source": "Use model",
				"base_size_source_mm": 0
			}
		],
		"source_composition_rows": [
			"1-3 Convergence of Dominion Starsteles"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 60
			},
			{
				"category": "ordinary",
				"models": 2,
				"points": 120
			},
			{
				"category": "ordinary",
				"models": 3,
				"points": 180
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "transdimensional abductor"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "transdimensional abductor"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Transdimensional abductor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Transdimensional abductor",
							"range_inches": 18,
							"attacks": 3,
							"skill": 4,
							"strength": 6,
							"ap": -2,
							"damage": 3,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_ability_names": [
			"Reanimation Protocols",
			"Reanimation Nodes (Aura)",
			"Ancient Cover",
			"Fortification",
			"DEPLOYMENT"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "",
				"name": "Reanimation Nodes (Aura)",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Ancient Cover",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Fortification",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "DEPLOYMENT",
				"model_role": "",
				"type": "Special (правая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Reanimation Nodes (Aura)",
			"Ancient Cover",
			"Fortification",
			"DEPLOYMENT"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"cryptothralls": {
		"name": "Cryptothralls",
		"source_datasheet_id": "000002111",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Cryptothralls",
		"source_role": "Infantry",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551003",
			"000008555002",
			"000008555005",
			"000008555006",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 60,
		"points_by_models": {
			2: 60
		},
		"construction_model_sizes": [
			2
		],
		"models": 2,
		"base_size_source_mm": 32,
		"base_size_source": "32mm",
		"base_radius_inches": 0.6299212598425197,
		"stats": {
			"movement_inches": 5,
			"toughness": 4,
			"save_target": 3,
			"wounds": 3,
			"leadership_target": 8,
			"objective_control": 1,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"CRYPTOTHRALLS",
			"INFANTRY"
		],
		"source_keywords": [
			"Necrons",
			"Cryptothralls",
			"Infantry"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Cryptothralls",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Infantry",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Scouring eye",
						"range_inches": 6,
						"attacks": 2,
						"skill": 4,
						"strength": 5,
						"ap": -1,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Scythed limbs",
						"range_inches": 0,
						"attacks": 4,
						"skill": 4,
						"strength": 5,
						"ap": -1,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Cryptothralls",
				"stats": {
					"movement_inches": 5,
					"toughness": 4,
					"save_target": 3,
					"wounds": 3,
					"leadership_target": 8,
					"objective_control": 1,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "5\"",
					"T": "4",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "3",
					"Ld": "8+",
					"OC": "1"
				},
				"base_size_source": "32mm",
				"base_size_source_mm": 32
			}
		],
		"source_composition_rows": [
			"2 Cryptothralls"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 2,
				"points": 60
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "scouring eye"
					},
					{
						"count": 1,
						"name": "scythed limbs"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "scouring eye"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "scythed limbs"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Scouring eye",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Scouring eye",
							"range_inches": 6,
							"attacks": 2,
							"skill": 4,
							"strength": 5,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Scythed limbs",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Scythed limbs",
							"range_inches": 0,
							"attacks": 4,
							"skill": 4,
							"strength": 5,
							"ap": -1,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Reanimation Protocols",
			"Bound Creation",
			"Systematic Vigour",
			"CRYPTEK RETINUE"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "",
				"name": "Bound Creation",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Systematic Vigour",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "CRYPTEK RETINUE",
				"model_role": "",
				"type": "Special (правая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Bound Creation",
			"Systematic Vigour",
			"CRYPTEK RETINUE"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"geomancer": {
		"name": "Geomancer",
		"source_datasheet_id": "000004178",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Geomancer",
		"source_role": "Infantry Character",
		"source_is_support": true,
		"source_leader_relations": [
			{
				"leader_id": "000004178",
				"attached_id": "000000535",
				"": ""
			},
			{
				"leader_id": "000004178",
				"attached_id": "000000534",
				"": ""
			},
			{
				"leader_id": "000004178",
				"attached_id": "000004176",
				"": ""
			}
		],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [
			"000000534",
			"000000535",
			"000004176"
		],
		"source_stratagem_ids": [
			"000008371002",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008547002",
			"000008547003",
			"000008547004",
			"000008551002",
			"000008551003",
			"000008555002",
			"000008555004",
			"000008555005",
			"000008555006",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665003",
			"000010665004",
			"000010665005",
			"000010665006",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010736002",
			"000010736003",
			"000010736004",
			"000010736005",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000008372002",
			"000008372003",
			"000008372004",
			"000008372005",
			"000008543002",
			"000008543003",
			"000008546002",
			"000008546003",
			"000008546004",
			"000008546005",
			"000008554002",
			"000008554003",
			"000008554004",
			"000008554005",
			"000009749003",
			"000009749004",
			"000009749005",
			"000010664002",
			"000010664003",
			"000010664004",
			"000010664005",
			"000010668003",
			"000010735002",
			"000010735003",
			"000010891002"
		],
		"source_detachment_ability_ids": [
			"000008545",
			"000008553",
			"000009748",
			"000010663",
			"000010667",
			"000010734"
		],
		"points": 75,
		"points_by_models": {
			1: 75
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 50,
		"base_size_source": "50mm",
		"base_radius_inches": 0.984251968503937,
		"stats": {
			"movement_inches": 8,
			"toughness": 4,
			"save_target": 4,
			"wounds": 4,
			"leadership_target": 6,
			"objective_control": 1,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"INFANTRY",
			"CHARACTER",
			"CRYPTEK",
			"GEOMANCER"
		],
		"source_keywords": [
			"Necrons",
			"Infantry",
			"Character",
			"Cryptek",
			"Geomancer"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Infantry",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Cryptek",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Geomancer",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"reverberating-beam": {
						"name": "Tremorglaive – reverberating beam",
						"range_inches": 18,
						"attacks": 2,
						"skill": 4,
						"strength": 8,
						"ap": -2,
						"damage": 2,
						"keywords": {
							"melta": 2
						}
					},
					"shock-wave-pulse": {
						"name": "Tremorglaive – shock wave pulse",
						"range_inches": 18,
						"attacks": "D6+2",
						"skill": "-",
						"strength": 4,
						"ap": 0,
						"damage": 1,
						"keywords": {
							"ignores-cover": true,
							"torrent": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-3",
				"profiles": {
					"standard": {
						"name": "Tremorglaive",
						"range_inches": 0,
						"attacks": 2,
						"skill": 4,
						"strength": 8,
						"ap": -2,
						"damage": 2,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Geomancer",
				"stats": {
					"movement_inches": 8,
					"toughness": 4,
					"save_target": 4,
					"wounds": 4,
					"leadership_target": 6,
					"objective_control": 1,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "8\"",
					"T": "4",
					"Sv": "4+",
					"inv_sv": "-",
					"W": "4",
					"Ld": "6+",
					"OC": "1"
				},
				"base_size_source": "50mm",
				"base_size_source_mm": 50
			}
		],
		"source_composition_rows": [
			"1 Geomancer"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 75
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "tremorglaive"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "tremorglaive"
					},
					{
						"weapon_id": "source-melee-3",
						"count_per_model": 1,
						"name": "tremorglaive"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Tremorglaive",
					"type": "ranged",
					"profiles": {
						"reverberating-beam": {
							"name": "Tremorglaive – reverberating beam",
							"range_inches": 18,
							"attacks": 2,
							"skill": 4,
							"strength": 8,
							"ap": -2,
							"damage": 2,
							"keywords": {
								"melta": 2
							}
						},
						"shock-wave-pulse": {
							"name": "Tremorglaive – shock wave pulse",
							"range_inches": 18,
							"attacks": "D6+2",
							"skill": "-",
							"strength": 4,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"ignores-cover": true,
								"torrent": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-3",
					"source_line": 3,
					"name": "Tremorglaive",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Tremorglaive",
							"range_inches": 0,
							"attacks": 2,
							"skill": 4,
							"strength": 8,
							"ap": -2,
							"damage": 2,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Support",
			"Reanimation Protocols",
			"Tectonic Reverberations",
			"Obelisk Node Control",
			"VANGUARD PROTOCOLS"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000010857",
				"name": "Support",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Tectonic Reverberations",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Obelisk Node Control",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "VANGUARD PROTOCOLS",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Support",
			"Tectonic Reverberations",
			"Obelisk Node Control",
			"VANGUARD PROTOCOLS"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"nekrosor-ammentar": {
		"name": "Nekrosor Ammentar",
		"source_datasheet_id": "000004186",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Nekrosor-Ammentar",
		"source_role": "Infantry Epic Hero",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371002",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008405002",
			"000008405003",
			"000008405004",
			"000008405005",
			"000008405006",
			"000008405007",
			"000008551002",
			"000008551003",
			"000008555002",
			"000008555004",
			"000008555005",
			"000008555006",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669003",
			"000010669004",
			"000010669005",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008542",
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 195,
		"points_by_models": {
			1: 195
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 80,
		"base_size_source": "80mm",
		"base_radius_inches": 1.5748031496062993,
		"stats": {
			"movement_inches": 10,
			"toughness": 8,
			"save_target": 3,
			"wounds": 9,
			"leadership_target": 6,
			"objective_control": 3,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"INFANTRY",
			"CHARACTER",
			"EPIC HERO",
			"DESTROYER CULT",
			"NEKROSOR AMMENTAR"
		],
		"source_keywords": [
			"Necrons",
			"Infantry",
			"Character",
			"Epic Hero",
			"Destroyer Cult",
			"Nekrosor Ammentar"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Infantry",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Epic Hero",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Destroyer Cult",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Nekrosor Ammentar",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Enmitic disintegrators",
						"range_inches": 18,
						"attacks": 4,
						"skill": 2,
						"strength": 6,
						"ap": -2,
						"damage": 1,
						"keywords": {
							"ignores-cover": true,
							"pistol": true,
							"sustained-hits": 2
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Blade tail and whip coils",
						"range_inches": 0,
						"attacks": 6,
						"skill": 2,
						"strength": 6,
						"ap": -1,
						"damage": 1,
						"keywords": {
							"extra-attacks": true
						}
					}
				}
			},
			{
				"id": "source-melee-3",
				"profiles": {
					"standard": {
						"name": "Unmaker Gauntlet",
						"range_inches": 0,
						"attacks": 6,
						"skill": 2,
						"strength": 10,
						"ap": -3,
						"damage": 3,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Nekrosor Ammentar",
				"stats": {
					"movement_inches": 10,
					"toughness": 8,
					"save_target": 3,
					"wounds": 9,
					"leadership_target": 6,
					"objective_control": 3,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "10\"",
					"T": "8",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "9",
					"Ld": "6+",
					"OC": "3"
				},
				"base_size_source": "80mm",
				"base_size_source_mm": 80
			}
		],
		"source_composition_rows": [
			"1 Nekrosor Ammentar – EPIC HERO"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 195
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "enmitic disintegrators"
					},
					{
						"count": 1,
						"name": "Unmaker Gauntlet"
					},
					{
						"count": 1,
						"name": "blade tail and whip coils"
					},
					{
						"count": 1,
						"name": "nullstone field generator"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "enmitic disintegrators"
					},
					{
						"weapon_id": "source-melee-3",
						"count_per_model": 1,
						"name": "Unmaker Gauntlet"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "blade tail and whip coils"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [
			{
				"role": "This model",
				"item": "nullstone field generator",
				"reason": "source wargear outside the weapon table"
			}
		],
		"source_non_weapon_loadout_equipment": [
			{
				"role": "This model",
				"item": "nullstone field generator",
				"reason": "source wargear outside the weapon table"
			}
		],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Enmitic disintegrators",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Enmitic disintegrators",
							"range_inches": 18,
							"attacks": 4,
							"skill": 2,
							"strength": 6,
							"ap": -2,
							"damage": 1,
							"keywords": {
								"ignores-cover": true,
								"pistol": true,
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Blade tail and whip coils",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Blade tail and whip coils",
							"range_inches": 0,
							"attacks": 6,
							"skill": 2,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"extra-attacks": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-melee-3",
					"source_line": 3,
					"name": "Unmaker Gauntlet",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Unmaker Gauntlet",
							"range_inches": 0,
							"attacks": 6,
							"skill": 2,
							"strength": 10,
							"ap": -3,
							"damage": 3,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deep Strike",
			"Fights First",
			"Reanimation Protocols",
			"Protective Disciples",
			"Infectious Murder-madness (Aura)",
			"Prophet of Destruction",
			"Nullstone Field Generator (Aura)"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "000008340",
				"name": "Fights First",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Protective Disciples",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Infectious Murder-madness (Aura)",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Prophet of Destruction",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "Nullstone Field Generator (Aura)",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Deep Strike",
			"Fights First",
			"Protective Disciples",
			"Infectious Murder-madness (Aura)",
			"Prophet of Destruction",
			"Nullstone Field Generator (Aura)"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks",
			"source default equipment mapping requires reconciliation"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending",
		"max_supported_copies": 1
	},
	"night-scythe": {
		"name": "Night Scythe",
		"source_datasheet_id": "000000544",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Night-Scythe",
		"source_role": "Transport",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551003",
			"000008551004",
			"000008555003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 125,
		"points_by_models": {
			1: 125
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 92,
		"base_size_source": "120 x 92mm flying base",
		"base_radius_inches": 1.8110236220472442,
		"stats": {
			"movement_inches": 14,
			"toughness": 9,
			"save_target": 3,
			"wounds": 12,
			"leadership_target": 7,
			"objective_control": 0,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"VEHICLE",
			"FLY",
			"TRANSPORT",
			"NIGHT SCYTHE"
		],
		"source_keywords": [
			"Necrons",
			"Vehicle",
			"Fly",
			"Transport",
			"Night Scythe"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Transport",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Night Scythe",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Twin tesla destructor",
						"range_inches": 36,
						"attacks": 6,
						"skill": 3,
						"strength": 8,
						"ap": 0,
						"damage": 2,
						"keywords": {
							"sustained-hits": 2,
							"twin-linked": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Armoured bulk",
						"range_inches": 0,
						"attacks": 3,
						"skill": 4,
						"strength": 6,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Night Scythe",
				"stats": {
					"movement_inches": 14,
					"toughness": 9,
					"save_target": 3,
					"wounds": 12,
					"leadership_target": 7,
					"objective_control": 0,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "14\"",
					"T": "9",
					"Sv": "3+",
					"inv_sv": "-",
					"W": "12",
					"Ld": "7+",
					"OC": "0"
				},
				"base_size_source": "120 x 92mm flying base",
				"base_size_source_mm": 92
			}
		],
		"source_composition_rows": [
			"1 Night Scythe"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 125
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "twin tesla destructor"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "twin tesla destructor"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Twin tesla destructor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin tesla destructor",
							"range_inches": 36,
							"attacks": 6,
							"skill": 3,
							"strength": 8,
							"ap": 0,
							"damage": 2,
							"keywords": {
								"sustained-hits": 2,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 3,
							"skill": 4,
							"strength": 6,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Reanimation Protocols",
			"Invasion Beams",
			"Quantum Invader",
			"Hover"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D3"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Invasion Beams",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Quantum Invader",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "000008342",
				"name": "Hover",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "1-4",
		"source_damaged_description": "While this model has 1-4 wounds remaining, each time this model makes an attack, subtract 1 from the Hit roll.",
		"source_transport_text": "This model has a transport capacity of 1 Necrons Infantry unit.",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d3", "deep-strike"],
		"unsupported_abilities": [
			"Invasion Beams",
			"Quantum Invader",
			"Hover"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"obelisk": {
		"name": "Obelisk",
		"source_datasheet_id": "000000557",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Obelisk",
		"source_role": "Titanic",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551004",
			"000008555003",
			"000008555005",
			"000008555007",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810012",
			"000010892002",
			"000010892003",
			"000010892004"
		],
		"source_enhancement_ids": [
			"000010891003"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010890"
		],
		"points": 280,
		"points_by_models": {
			1: 280
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 92,
		"base_size_source": "120 x 92mm flying base",
		"base_radius_inches": 1.8110236220472442,
		"stats": {
			"movement_inches": 8,
			"toughness": 13,
			"save_target": 2,
			"wounds": 24,
			"leadership_target": 7,
			"objective_control": 8,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"FRAME",
			"OBELISK",
			"TOWERING",
			"FLY",
			"TITANIC",
			"VEHICLE"
		],
		"source_keywords": [
			"Necrons",
			"Frame",
			"Obelisk",
			"Towering",
			"Fly",
			"Titanic",
			"Vehicle"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Frame",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Obelisk",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Towering",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Titanic",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Tesla sphere",
						"range_inches": 24,
						"attacks": 6,
						"skill": 3,
						"strength": 7,
						"ap": 0,
						"damage": 1,
						"keywords": {
							"anti-fly": 4,
							"sustained-hits": 2
						}
					}
				},
				"count": 4
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Armoured bulk",
						"range_inches": 0,
						"attacks": 6,
						"skill": 4,
						"strength": 8,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Obelisk",
				"stats": {
					"movement_inches": 8,
					"toughness": 13,
					"save_target": 2,
					"wounds": 24,
					"leadership_target": 7,
					"objective_control": 8,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "8\"",
					"T": "13",
					"Sv": "2+",
					"inv_sv": "-",
					"W": "24",
					"Ld": "7+",
					"OC": "8"
				},
				"base_size_source": "120 x 92mm flying base",
				"base_size_source_mm": 92
			}
		],
		"source_composition_rows": [
			"1 Obelisk"
		],
		"source_cost_rows": [
			{
				"category": "first",
				"models": 1,
				"points": 280
			},
			{
				"category": "second_plus",
				"models": 1,
				"points": 310
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 4,
						"name": "tesla spheres"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 4,
						"name": "tesla spheres"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Tesla sphere",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla sphere",
							"range_inches": 24,
							"attacks": 6,
							"skill": 3,
							"strength": 7,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"anti-fly": 4,
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 6,
							"skill": 4,
							"strength": 8,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Reanimation Protocols",
			"Gravitic Pulse"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Gravitic Pulse",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "1-8",
		"source_damaged_description": "While this model has 1-8 wounds remaining, subtract 4 from its Objective Control characteristic and each time this model makes an attack, subtract 1 from the Hit roll.",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6", "deep-strike"],
		"unsupported_abilities": [
			"Gravitic Pulse"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"overlord-with-translocation-shroud": {
		"name": "Overlord with translocation shroud",
		"source_datasheet_id": "000003693",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Overlord-with-translocation-shroud",
		"source_role": "Infantry Character",
		"source_is_support": false,
		"source_leader_relations": [
			{
				"leader_id": "000003693",
				"attached_id": "000000534",
				"": ""
			},
			{
				"leader_id": "000003693",
				"attached_id": "000000535",
				"": ""
			},
			{
				"leader_id": "000003693",
				"attached_id": "000000536",
				"": ""
			}
		],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [
			"000000534",
			"000000535",
			"000000536"
		],
		"source_stratagem_ids": [
			"000008371002",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551002",
			"000008551003",
			"000008555002",
			"000008555004",
			"000008555005",
			"000008555006",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009589002",
			"000009589003",
			"000009589004",
			"000009589005",
			"000009750002",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000008372002",
			"000008372003",
			"000008372004",
			"000008372005",
			"000008543002",
			"000008543003",
			"000008550002",
			"000008550003",
			"000008550004",
			"000008550005",
			"000008554002",
			"000008554003",
			"000008554004",
			"000008554005",
			"000009588002",
			"000009749002",
			"000009749003",
			"000009749004",
			"000009749005",
			"000010664002",
			"000010664004",
			"000010668002",
			"000010891002"
		],
		"source_detachment_ability_ids": [
			"000008549",
			"000008553",
			"000009587",
			"000009748",
			"000010667"
		],
		"points": 90,
		"points_by_models": {
			1: 90
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 40,
		"base_size_source": "40mm",
		"base_radius_inches": 0.7874015748031497,
		"stats": {
			"movement_inches": 5,
			"toughness": 5,
			"save_target": 2,
			"wounds": 6,
			"leadership_target": 6,
			"objective_control": 1,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"CHARACTER",
			"INFANTRY",
			"NOBLE",
			"OVERLORD",
			"OVERLORD WITH TRANSLOCATION SHROUD"
		],
		"source_keywords": [
			"Necrons",
			"Character",
			"Infantry",
			"Noble",
			"Overlord",
			"Overlord with translocation shroud"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Infantry",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Noble",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Overlord",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Overlord with translocation shroud",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [],
		"melee": [
			{
				"id": "source-melee-1",
				"profiles": {
					"standard": {
						"name": "Overlord's blade",
						"range_inches": 0,
						"attacks": 4,
						"skill": 2,
						"strength": 8,
						"ap": -3,
						"damage": 2,
						"keywords": {
							"devastating-wounds": true
						}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "",
				"stats": {
					"movement_inches": 5,
					"toughness": 5,
					"save_target": 2,
					"wounds": 6,
					"leadership_target": 6,
					"objective_control": 1,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "5\"",
					"T": "5",
					"Sv": "2+",
					"inv_sv": "4",
					"W": "6",
					"Ld": "6+",
					"OC": "1"
				},
				"base_size_source": "40mm",
				"base_size_source_mm": 40
			}
		],
		"source_composition_rows": [
			"1 Overlord with Translocation Shroud"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 1,
				"points": 90
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "Overlord’s blade"
					},
					{
						"count": 1,
						"name": "resurrection orb"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-melee-1",
						"count_per_model": 1,
						"name": "Overlord’s blade"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [
			{
				"role": "This model",
				"item": "resurrection orb",
				"reason": "source wargear outside the weapon table"
			}
		],
		"source_non_weapon_loadout_equipment": [
			{
				"role": "This model",
				"item": "resurrection orb",
				"reason": "source wargear outside the weapon table"
			}
		],
		"source_weapon_profiles": {
			"ranged": [],
			"melee": [
				{
					"id": "source-melee-1",
					"source_line": 1,
					"name": "Overlord's blade",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Overlord's blade",
							"range_inches": 0,
							"attacks": 4,
							"skill": 2,
							"strength": 8,
							"ap": -3,
							"damage": 2,
							"keywords": {
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Leader",
			"Reanimation Protocols",
			"Resurrection Orb",
			"My Will Be Done",
			"Translocation Shroud"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008346",
				"name": "Leader",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Resurrection Orb",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "My Will Be Done",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Translocation Shroud",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols"],
		"unsupported_abilities": [
			"Leader",
			"Resurrection Orb",
			"My Will Be Done",
			"Translocation Shroud"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks",
			"source default equipment mapping requires reconciliation"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"tesseract-vault": {
		"name": "Tesseract Vault",
		"source_datasheet_id": "000000556",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Tesseract-Vault",
		"source_role": "Titanic",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551004",
			"000008555003",
			"000008555005",
			"000008555007",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810012",
			"000010892002",
			"000010892003",
			"000010892004"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010890"
		],
		"points": 465,
		"points_by_models": {
			1: 465
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 92,
		"base_size_source": "120 x 92mm flying base",
		"base_radius_inches": 1.8110236220472442,
		"stats": {
			"movement_inches": 8,
			"toughness": 12,
			"save_target": 2,
			"wounds": 24,
			"leadership_target": 7,
			"objective_control": 8,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"VEHICLE",
			"TITANIC",
			"FLY",
			"TESSERACT VAULT",
			"FRAME",
			"TOWERING"
		],
		"source_keywords": [
			"Necrons",
			"Vehicle",
			"Titanic",
			"Fly",
			"Tesseract Vault",
			"Frame",
			"Towering"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Vehicle",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Titanic",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Tesseract Vault",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Frame",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Towering",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Tesla spheres",
						"range_inches": 24,
						"attacks": 6,
						"skill": 3,
						"strength": 7,
						"ap": 0,
						"damage": 1,
						"keywords": {
							"sustained-hits": 2
						}
					}
				},
				"count": 4
			}
		],
		"melee": [
			{
				"id": "source-melee-5",
				"profiles": {
					"standard": {
						"name": "Armoured bulk",
						"range_inches": 0,
						"attacks": 6,
						"skill": 4,
						"strength": 8,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Antimatter Meteor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Antimatter Meteor",
							"range_inches": 24,
							"attacks": "D6+3",
							"skill": 3,
							"strength": 10,
							"ap": -3,
							"damage": 3,
							"keywords": {
								"blast": true,
								"devastating-wounds": true,
								"indirect-fire": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Cosmic Fire",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Cosmic Fire",
							"range_inches": 18,
							"attacks": "3D6",
							"skill": "-",
							"strength": 6,
							"ap": -2,
							"damage": 1,
							"keywords": {
								"ignores-cover": true,
								"devastating-wounds": true,
								"torrent": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				},
				{
					"id": "source-ranged-4",
					"source_line": 4,
					"name": "Time’s Arrow",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Time’s Arrow",
							"range_inches": 24,
							"attacks": 1,
							"skill": 2,
							"strength": 3,
							"ap": -2,
							"damage": 6,
							"keywords": {
								"anti-character": 4,
								"devastating-wounds": true,
								"precision": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Tesseract Vault",
				"stats": {
					"movement_inches": 8,
					"toughness": 12,
					"save_target": 2,
					"wounds": 24,
					"leadership_target": 7,
					"objective_control": 8,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "8\"",
					"T": "12",
					"Sv": "2+",
					"inv_sv": "4",
					"W": "24",
					"Ld": "7+",
					"OC": "8"
				},
				"base_size_source": "120 x 92mm flying base",
				"base_size_source_mm": 92
			}
		],
		"source_composition_rows": [
			"1 Tesseract Vault"
		],
		"source_cost_rows": [
			{
				"category": "first",
				"models": 1,
				"points": 465
			},
			{
				"category": "second_plus",
				"models": 1,
				"points": 505
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 4,
						"name": "tesla spheres"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 4,
						"name": "tesla spheres"
					},
					{
						"weapon_id": "source-melee-5",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Tesla spheres",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Tesla spheres",
							"range_inches": 24,
							"attacks": 6,
							"skill": 3,
							"strength": 7,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"sustained-hits": 2
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Antimatter Meteor",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Antimatter Meteor",
							"range_inches": 24,
							"attacks": "D6+3",
							"skill": 3,
							"strength": 10,
							"ap": -3,
							"damage": 3,
							"keywords": {
								"blast": true,
								"devastating-wounds": true,
								"indirect-fire": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Cosmic Fire",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Cosmic Fire",
							"range_inches": 18,
							"attacks": "3D6",
							"skill": "-",
							"strength": 6,
							"ap": -2,
							"damage": 1,
							"keywords": {
								"ignores-cover": true,
								"devastating-wounds": true,
								"torrent": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				},
				{
					"id": "source-ranged-4",
					"source_line": 4,
					"name": "Time’s Arrow",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Time’s Arrow",
							"range_inches": 24,
							"attacks": 1,
							"skill": 2,
							"strength": 3,
							"ap": -2,
							"damage": 6,
							"keywords": {
								"anti-character": 4,
								"devastating-wounds": true,
								"precision": true
							}
						}
					},
					"unmapped_traits": [
						"c'tan power"
					]
				}
			],
			"melee": [
				{
					"id": "source-melee-5",
					"source_line": 5,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 6,
							"skill": 4,
							"strength": 8,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Powers of the C’tan"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6+3"
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Powers of the C’tan",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "1-8",
		"source_damaged_description": "While this model has 1-8 wounds remaining, subtract 4 from its Objective Control characteristic and you can only select one of the C’tan Powers weapons in your Shooting phase, instead of two.",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [
			"c'tan power"
		],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6-plus-three"],
		"unsupported_abilities": [
			"Powers of the C’tan"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks",
			"unmapped weapon traits: c'tan power"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"the-silent-king": {
		"name": "The Silent King",
		"source_datasheet_id": "000002360",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/The-Silent-King",
		"source_role": "Vehicle Epic Hero",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551002",
			"000008551003",
			"000008551004",
			"000008551006",
			"000008551007",
			"000008555003",
			"000008555004",
			"000008555005",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [],
		"source_detachment_ability_ids": [
			"000008549",
			"000008553",
			"000009748",
			"000010667"
		],
		"points": 420,
		"points_by_models": {
			3: 420
		},
		"construction_model_sizes": [
			3
		],
		"models": 3,
		"base_size_source_mm": 100,
		"base_size_source": "100mm",
		"base_radius_inches": 1.968503937007874,
		"stats": {
			"movement_inches": 8,
			"toughness": 10,
			"save_target": 2,
			"wounds": 16,
			"leadership_target": 6,
			"objective_control": 6,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"THE SILENT KING",
			"VEHICLE",
			"CHARACTER",
			"TRIARCH",
			"EPIC HERO"
		],
		"source_keywords": [
			"Necrons",
			"The Silent King",
			"Vehicle",
			"Character",
			"Triarch",
			"Epic Hero"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "The Silent King",
				"model_role": "SZAREKH MODEL",
				"is_faction_keyword": false
			},
			{
				"keyword": "Vehicle",
				"model_role": "ALL MODELS",
				"is_faction_keyword": false
			},
			{
				"keyword": "Character",
				"model_role": "SZAREKH MODEL",
				"is_faction_keyword": false
			},
			{
				"keyword": "Triarch",
				"model_role": "ALL MODELS",
				"is_faction_keyword": false
			},
			{
				"keyword": "Epic Hero",
				"model_role": "ALL MODELS",
				"is_faction_keyword": false
			}
		],
		"ranged": [],
		"melee": [],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "SZAREKH",
				"stats": {
					"movement_inches": 8,
					"toughness": 10,
					"save_target": 2,
					"wounds": 16,
					"leadership_target": 6,
					"objective_control": 6,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "8\"",
					"T": "10",
					"Sv": "2+",
					"inv_sv": "4",
					"W": "16",
					"Ld": "6+",
					"OC": "6"
				},
				"base_size_source": "100mm",
				"base_size_source_mm": 100
			},
			{
				"name": "TRIARCHAL MENHIR",
				"stats": {
					"movement_inches": 8,
					"toughness": 10,
					"save_target": 2,
					"wounds": 5,
					"leadership_target": 6,
					"objective_control": 1,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "8\"",
					"T": "10",
					"Sv": "2+",
					"inv_sv": "4",
					"W": "5",
					"Ld": "6+",
					"OC": "1"
				},
				"base_size_source": "50mm",
				"base_size_source_mm": 50
			}
		],
		"source_composition_rows": [
			"1 Szarekh – EPIC HERO",
			"2 Triarchal Menhirs"
		],
		"source_cost_rows": [
			{
				"category": "ordinary",
				"models": 3,
				"points": 420
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Szarekh",
				"items": [
					{
						"count": 1,
						"name": "Sceptre of Eternal Glory"
					},
					{
						"count": 1,
						"name": "Staff of Stars"
					},
					{
						"count": 1,
						"name": "Weapons of the Final Triarch"
					}
				]
			},
			{
				"model_role": "Every Triarchal Menhir",
				"items": [
					{
						"count": 1,
						"name": "annihilator beam"
					},
					{
						"count": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Szarekh",
				"weapons": [
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "Sceptre of Eternal Glory"
					},
					{
						"weapon_id": "source-ranged-3",
						"count_per_model": 1,
						"name": "Staff of Stars"
					},
					{
						"weapon_id": "source-melee-5",
						"count_per_model": 1,
						"name": "Weapons of the Final Triarch"
					}
				]
			},
			{
				"model_role": "Every Triarchal Menhir",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "annihilator beam"
					},
					{
						"weapon_id": "source-melee-4",
						"count_per_model": 1,
						"name": "armoured bulk"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Annihilator beam",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Annihilator beam",
							"range_inches": 24,
							"attacks": 1,
							"skill": 2,
							"strength": 14,
							"ap": -4,
							"damage": 6,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Sceptre of Eternal Glory",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Sceptre of Eternal Glory",
							"range_inches": 24,
							"attacks": 2,
							"skill": 2,
							"strength": 10,
							"ap": -3,
							"damage": 3,
							"keywords": {
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Staff of Stars",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Staff of Stars",
							"range_inches": 24,
							"attacks": 12,
							"skill": 2,
							"strength": 6,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"indirect-fire": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-4",
					"source_line": 4,
					"name": "Armoured bulk",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Armoured bulk",
							"range_inches": 0,
							"attacks": 1,
							"skill": 4,
							"strength": 4,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-melee-5",
					"source_line": 5,
					"name": "Weapons of the Final Triarch",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Weapons of the Final Triarch",
							"range_inches": 0,
							"attacks": 12,
							"skill": 2,
							"strength": 8,
							"ap": -3,
							"damage": 2,
							"keywords": {
								"lethal-hits": true
							}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Triarch Abilities",
			"The Silent King",
			"SUPREME COMMANDER",
			"TRIARCHAL MENHIRS",
			"Phaeron of the Stars (Aura)",
			"Phaeron of the Blades (Aura)",
			"Relentless March (Aura)"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6+3 (Szarekh model only)"
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Triarch Abilities",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "The Silent King",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "SUPREME COMMANDER",
				"model_role": "",
				"type": "Special (правая колонка)",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "TRIARCHAL MENHIRS",
				"model_role": "",
				"type": "Special (правая колонка)",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "Phaeron of the Stars (Aura)",
				"model_role": "",
				"type": "Primarch",
				"parameter": ""
			},
			{
				"source_line": 8,
				"ability_id": "",
				"name": "Phaeron of the Blades (Aura)",
				"model_role": "",
				"type": "Primarch",
				"parameter": ""
			},
			{
				"source_line": 9,
				"ability_id": "",
				"name": "Relentless March (Aura)",
				"model_role": "",
				"type": "Primarch",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "1-6",
		"source_damaged_description": "While this unit’s Szarekh model has 1-6 wounds remaining, halve the Attacks characteristic of that model’s weapons, and each time this unit makes an attack, subtract 1 from the Hit roll.",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": [],
		"unsupported_abilities": [
			"Deadly Demise",
			"Reanimation Protocols",
			"Triarch Abilities",
			"The Silent King",
			"SUPREME COMMANDER",
			"TRIARCHAL MENHIRS",
			"Phaeron of the Stars (Aura)",
			"Phaeron of the Blades (Aura)",
			"Relentless March (Aura)"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks",
			"composite model role runtime mapping"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending",
		"max_supported_copies": 1
	},
	"tomb-blades": {
		"name": "Tomb Blades",
		"source_datasheet_id": "000000548",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Tomb-Blades",
		"source_role": "Mounted",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371003",
			"000008371004",
			"000008371005",
			"000008371006",
			"000008551003",
			"000008555005",
			"000009218002",
			"000009218004",
			"000009218005",
			"000009218006",
			"000009750002",
			"000009750003",
			"000009750004",
			"000009750005",
			"000009750006",
			"000009750007",
			"000010665002",
			"000010665007",
			"000010669002",
			"000010669004",
			"000010669006",
			"000010669007",
			"000010673004",
			"000010673005",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810004",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012",
			"000010888002",
			"000010888003",
			"000010888004"
		],
		"source_enhancement_ids": [
			"000010887002"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000009748",
			"000010667",
			"000010886"
		],
		"points": 70,
		"points_by_models": {
			3: 70,
			6: 140
		},
		"construction_model_sizes": [
			3,
			6
		],
		"models": 3,
		"base_size_source_mm": 32,
		"base_size_source": "32mm flying base",
		"base_radius_inches": 0.6299212598425197,
		"stats": {
			"movement_inches": 12,
			"toughness": 5,
			"save_target": 4,
			"wounds": 2,
			"leadership_target": 7,
			"objective_control": 2,
			"invulnerable_target": 0
		},
		"keywords": [
			"NECRONS",
			"MOUNTED",
			"FLY",
			"TOMB BLADES"
		],
		"source_keywords": [
			"Necrons",
			"Mounted",
			"Fly",
			"Tomb Blades"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Mounted",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Tomb Blades",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-2",
				"profiles": {
					"standard": {
						"name": "Twin gauss blaster",
						"range_inches": 24,
						"attacks": 2,
						"skill": 3,
						"strength": 5,
						"ap": -1,
						"damage": 1,
						"keywords": {
							"lethal-hits": true,
							"twin-linked": true
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-4",
				"profiles": {
					"standard": {
						"name": "Close combat weapon",
						"range_inches": 0,
						"attacks": 1,
						"skill": 4,
						"strength": 4,
						"ap": 0,
						"damage": 1,
						"keywords": {}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Particle beamer",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Particle beamer",
							"range_inches": 18,
							"attacks": "D6",
							"skill": 3,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"blast": true,
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Twin tesla carbine",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin tesla carbine",
							"range_inches": 24,
							"attacks": 2,
							"skill": 3,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"assault": true,
								"sustained-hits": 2,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Tomb Blades",
				"stats": {
					"movement_inches": 12,
					"toughness": 5,
					"save_target": 4,
					"wounds": 2,
					"leadership_target": 7,
					"objective_control": 2,
					"invulnerable_target": 0
				},
				"source_stats": {
					"M": "12\"",
					"T": "5",
					"Sv": "4+",
					"inv_sv": "-",
					"W": "2",
					"Ld": "7+",
					"OC": "2"
				},
				"base_size_source": "32mm flying base",
				"base_size_source_mm": 32
			}
		],
		"source_composition_rows": [
			"3-6 Tomb Blades"
		],
		"source_cost_rows": [
			{
				"category": "first_second",
				"models": 3,
				"points": 70
			},
			{
				"category": "first_second",
				"models": 6,
				"points": 140
			},
			{
				"category": "third_plus",
				"models": 3,
				"points": 80
			},
			{
				"category": "third_plus",
				"models": 6,
				"points": 150
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "Every model",
				"items": [
					{
						"count": 1,
						"name": "twin gauss blaster"
					},
					{
						"count": 1,
						"name": "close combat weapon"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "Every model",
				"weapons": [
					{
						"weapon_id": "source-ranged-2",
						"count_per_model": 1,
						"name": "twin gauss blaster"
					},
					{
						"weapon_id": "source-melee-4",
						"count_per_model": 1,
						"name": "close combat weapon"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Particle beamer",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Particle beamer",
							"range_inches": 18,
							"attacks": "D6",
							"skill": 3,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"blast": true,
								"devastating-wounds": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-2",
					"source_line": 2,
					"name": "Twin gauss blaster",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin gauss blaster",
							"range_inches": 24,
							"attacks": 2,
							"skill": 3,
							"strength": 5,
							"ap": -1,
							"damage": 1,
							"keywords": {
								"lethal-hits": true,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				},
				{
					"id": "source-ranged-3",
					"source_line": 3,
					"name": "Twin tesla carbine",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Twin tesla carbine",
							"range_inches": 24,
							"attacks": 2,
							"skill": 3,
							"strength": 5,
							"ap": 0,
							"damage": 1,
							"keywords": {
								"assault": true,
								"sustained-hits": 2,
								"twin-linked": true
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-4",
					"source_line": 4,
					"name": "Close combat weapon",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Close combat weapon",
							"range_inches": 0,
							"attacks": 1,
							"skill": 4,
							"strength": 4,
							"ap": 0,
							"damage": 1,
							"keywords": {}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Scouts",
			"Reanimation Protocols",
			"Nebuloscope",
			"Shadowloom",
			"Shieldvanes",
			"Evasion Engrams"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008344",
				"name": "Scouts",
				"model_role": "",
				"type": "Core",
				"parameter": "9\""
			},
			{
				"source_line": 2,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "",
				"name": "Nebuloscope",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 4,
				"ability_id": "",
				"name": "Shadowloom",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Shieldvanes",
				"model_role": "",
				"type": "Wargear",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Evasion Engrams",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			}
		],
		"source_options": [
			{
				"source_line": 1,
				"description": "Any number of models can each have their twin gauss blaster replaced with one of the following: 1 particle beamer 1 twin tesla carbine",
				"implemented": false
			},
			{
				"source_line": 2,
				"description": "Any number of models can each be equipped with 1 shieldvanes.",
				"implemented": false
			},
			{
				"source_line": 3,
				"description": "Any number of models can each be equipped with one of the following: 1 nebuloscope 1 shadowloom",
				"implemented": false
			}
		],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "scouts-9"],
		"unsupported_abilities": [
			"Nebuloscope",
			"Shadowloom",
			"Shieldvanes",
			"Evasion Engrams"
		],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	},
	"transcendent-ctan": {
		"name": "Transcendent C’tan",
		"source_datasheet_id": "000000555",
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/necrons/Transcendent-C-tan",
		"source_role": "Monster Character",
		"source_is_support": false,
		"source_leader_relations": [],
		"source_leader_datasheet_ids": [],
		"source_bodyguard_datasheet_ids": [],
		"source_stratagem_ids": [
			"000008371004",
			"000008371005",
			"000008371006",
			"000008371007",
			"000008551003",
			"000009218002",
			"000009218003",
			"000009218004",
			"000009218005",
			"000009218006",
			"000010665002",
			"000010665007",
			"000010673002",
			"000010673003",
			"000010673006",
			"000010673007",
			"000010810002",
			"000010810003",
			"000010810004",
			"000010810006",
			"000010810007",
			"000010810008",
			"000010810011",
			"000010810012"
		],
		"source_enhancement_ids": [
			"000010672005",
			"000010891002"
		],
		"source_detachment_ability_ids": [
			"000008553",
			"000010671"
		],
		"points": 340,
		"points_by_models": {
			1: 340
		},
		"construction_model_sizes": [
			1
		],
		"models": 1,
		"base_size_source_mm": 60,
		"base_size_source": "60mm flying base",
		"base_radius_inches": 1.1811023622047245,
		"stats": {
			"movement_inches": 8,
			"toughness": 11,
			"save_target": 3,
			"wounds": 16,
			"leadership_target": 6,
			"objective_control": 4,
			"invulnerable_target": 4
		},
		"keywords": [
			"NECRONS",
			"CHARACTER",
			"FLY",
			"TRANSCENDENT C’TAN",
			"MONSTER"
		],
		"source_keywords": [
			"Necrons",
			"Character",
			"Fly",
			"Transcendent C’tan",
			"Monster"
		],
		"source_keyword_rows": [
			{
				"keyword": "Necrons",
				"model_role": "",
				"is_faction_keyword": true
			},
			{
				"keyword": "Character",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Fly",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Transcendent C’tan",
				"model_role": "",
				"is_faction_keyword": false
			},
			{
				"keyword": "Monster",
				"model_role": "",
				"is_faction_keyword": false
			}
		],
		"ranged": [
			{
				"id": "source-ranged-1",
				"profiles": {
					"standard": {
						"name": "Seismic assault",
						"range_inches": 12,
						"attacks": 6,
						"skill": 2,
						"strength": 8,
						"ap": -2,
						"damage": 2,
						"keywords": {
							"assault": true,
							"sustained-hits": 1
						}
					}
				}
			}
		],
		"melee": [
			{
				"id": "source-melee-2",
				"profiles": {
					"standard": {
						"name": "Crackling tendrils",
						"range_inches": 0,
						"attacks": 8,
						"skill": 2,
						"strength": 10,
						"ap": -3,
						"damage": "D6",
						"keywords": {
							"sustained-hits": 1
						}
					}
				}
			}
		],
		"additional_weapon_profiles": {
			"ranged": [],
			"melee": []
		},
		"source_model_profiles": [
			{
				"name": "Transcendent C’tan",
				"stats": {
					"movement_inches": 8,
					"toughness": 11,
					"save_target": 3,
					"wounds": 16,
					"leadership_target": 6,
					"objective_control": 4,
					"invulnerable_target": 4
				},
				"source_stats": {
					"M": "8\"",
					"T": "11",
					"Sv": "3+",
					"inv_sv": "4",
					"W": "16",
					"Ld": "6+",
					"OC": "4"
				},
				"base_size_source": "60mm flying base",
				"base_size_source_mm": 60
			}
		],
		"source_composition_rows": [
			"1 Transcendent C’tan"
		],
		"source_cost_rows": [
			{
				"category": "first",
				"models": 1,
				"points": 340
			},
			{
				"category": "second_plus",
				"models": 1,
				"points": 360
			}
		],
		"source_loadout_by_model": [
			{
				"model_role": "This model",
				"items": [
					{
						"count": 1,
						"name": "seismic assault"
					},
					{
						"count": 1,
						"name": "crackling tendrils"
					}
				]
			}
		],
		"source_model_loadout_weapon_map": [
			{
				"model_role": "This model",
				"weapons": [
					{
						"weapon_id": "source-ranged-1",
						"count_per_model": 1,
						"name": "seismic assault"
					},
					{
						"weapon_id": "source-melee-2",
						"count_per_model": 1,
						"name": "crackling tendrils"
					}
				]
			}
		],
		"source_unmatched_loadout_equipment": [],
		"source_non_weapon_loadout_equipment": [],
		"source_weapon_profiles": {
			"ranged": [
				{
					"id": "source-ranged-1",
					"source_line": 1,
					"name": "Seismic assault",
					"type": "ranged",
					"profiles": {
						"standard": {
							"name": "Seismic assault",
							"range_inches": 12,
							"attacks": 6,
							"skill": 2,
							"strength": 8,
							"ap": -2,
							"damage": 2,
							"keywords": {
								"assault": true,
								"sustained-hits": 1
							}
						}
					},
					"unmapped_traits": []
				}
			],
			"melee": [
				{
					"id": "source-melee-2",
					"source_line": 2,
					"name": "Crackling tendrils",
					"type": "melee",
					"profiles": {
						"standard": {
							"name": "Crackling tendrils",
							"range_inches": 0,
							"attacks": 8,
							"skill": 2,
							"strength": 10,
							"ap": -3,
							"damage": "D6",
							"keywords": {
								"sustained-hits": 1
							}
						}
					},
					"unmapped_traits": []
				}
			]
		},
		"source_ability_names": [
			"Deadly Demise",
			"Deep Strike",
			"Feel No Pain",
			"Reanimation Protocols",
			"Transdimensional Displacement",
			"Necrodermis",
			"ENSLAVED STAR GOD",
			"C’TAN SHARD"
		],
		"source_ability_bindings": [
			{
				"source_line": 1,
				"ability_id": "000008339",
				"name": "Deadly Demise",
				"model_role": "",
				"type": "Core",
				"parameter": "D6"
			},
			{
				"source_line": 2,
				"ability_id": "000008343",
				"name": "Deep Strike",
				"model_role": "",
				"type": "Core",
				"parameter": ""
			},
			{
				"source_line": 3,
				"ability_id": "000008338",
				"name": "Feel No Pain",
				"model_role": "",
				"type": "Core",
				"parameter": "5+"
			},
			{
				"source_line": 4,
				"ability_id": "000008369",
				"name": "Reanimation Protocols",
				"model_role": "",
				"type": "Faction",
				"parameter": ""
			},
			{
				"source_line": 5,
				"ability_id": "",
				"name": "Transdimensional Displacement",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 6,
				"ability_id": "",
				"name": "Necrodermis",
				"model_role": "",
				"type": "Datasheet",
				"parameter": ""
			},
			{
				"source_line": 7,
				"ability_id": "",
				"name": "ENSLAVED STAR GOD",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			},
			{
				"source_line": 8,
				"ability_id": "",
				"name": "C’TAN SHARD",
				"model_role": "",
				"type": "Fortification (левая колонка)",
				"parameter": ""
			}
		],
		"source_options": [],
		"source_damaged_wounds": "",
		"source_damaged_description": "",
		"source_transport_text": "",
		"source_unmapped_weapon_traits": [],
		"supported_rule_ids": ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "necrodermis", "enslaved-star-god", "ctan-shard", "transdimensional-displacement"],
		"unsupported_abilities": [],
		"pending_source_checks": [
			"default equipment mapping",
			"all listed weapon rules",
			"all datasheet abilities",
			"every source option",
			"profile and roster interaction checks"
		],
		"source_profile_readiness": "source_facts_transcribed_implementation_pending"
	}
}

static func inventory() -> Dictionary:
	var result: Dictionary = {}
	for source: String in SOURCE_PROFILE_DATA:
		result[source] = {"id": SOURCE_PROFILE_DATA[source].source_datasheet_id, "name": SOURCE_PROFILE_DATA[source].name}
	return result

static func profile(source: String) -> Dictionary:
	var result: Dictionary = SOURCE_PROFILE_DATA.get(source, {}).duplicate(true)
	if result.is_empty(): return {}
	result.merge(SOURCE_METADATA, false)
	result["source_file_sha256"] = SOURCE_FILE_SHA256.duplicate(true)
	return result

static func catalog() -> Dictionary:
	var result: Dictionary = {}
	for source: String in SOURCE_PROFILE_DATA:
		result[source] = profile(source)
	return result

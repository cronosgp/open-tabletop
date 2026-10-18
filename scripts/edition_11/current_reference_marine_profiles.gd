extends RefCounted
## Fixed default loadouts transcribed from the current e11 reference snapshot.
## This is experimental reference data, not Codex/app certification.
const ID := "space-marines-e11-fixed-reference-2026-10-18-v1"

static func _build_profiles() -> Dictionary:
	return {
	"intercessor-squad": {
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "TACTICUS"],
		"ranged": [
			{"id": "bolt-rifle", "profiles": {
				"saturation": _weapon("Bolt Rifle - Saturation", 24.0, 2, 3, 5, -1, 1, {"assault": true, "rapid-fire": 1}),
				"focused_fire": _weapon("Bolt Rifle - Focused Fire", 24.0, 1, 3, 6, -1, 2, {"heavy": true, "rapid-fire": 1})
			}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "knives-and-fists", "profiles": {"standard": _weapon("Knives and Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"assault-intercessor-squad": {
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "IMPERIUM", "TACTICUS"],
		"ranged": [{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}],
		"melee": [{"id": "chainsword", "profiles": {"standard": _weapon("Chainsword", 0.0, 4, 3, 5, -1, 1, {})}}]
	},
	"heavy-intercessor-squad": {
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "BATTLELINE", "EXPLOSIVES", "GRAVIS", "IMPERIUM"],
		"ranged": [
			{"id": "heavy-bolt-rifle", "profiles": {"standard": _weapon("Heavy Bolt Rifle", 30.0, 2, 3, 5, -1, 2, {"heavy": true, "rapid-fire": 1})}},
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 3, 5, -1, 1, {"close-quarters": true})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 3, 3, 5, 0, 1, {})}}]
	},
	"terminator-squad": {
		"stats": {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "IMPERIUM", "TERMINATOR", "TERMINATOR SQUAD"],
		"ranged": [{"id": "storm-bolter", "profiles": {"standard": _weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}],
		"melee": [{"id": "power-fist", "profiles": {"standard": _weapon("Power Fist", 0.0, 3, 3, 8, -2, 2, {})}}]
	},
	"captain": {
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM"],
		"ranged": [
			{"id": "heavy-bolt-pistol", "profiles": {"standard": _weapon("Heavy Bolt Pistol", 18.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-bolter", "profiles": {"standard": _weapon("Master-crafted Bolter", 24.0, 2, 2, 5, -1, 2, {"assault": true, "rapid-fire": 1})}}
		],
		"melee": [{"id": "master-crafted-power-weapon", "profiles": {"standard": _weapon("Master-crafted Power Weapon", 0.0, 6, 2, 6, -2, 2, {})}}]
	},
	"lieutenant": {
		"stats": {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0},
		"keywords": ["INFANTRY", "CHARACTER", "IMPERIUM"],
		"ranged": [
			{"id": "bolt-pistol", "profiles": {"standard": _weapon("Bolt Pistol", 12.0, 1, 2, 5, -1, 1, {"close-quarters": true})}},
			{"id": "master-crafted-bolter", "profiles": {"standard": _weapon("Master-crafted Bolter", 24.0, 2, 2, 5, -1, 2, {})}}
		],
		"melee": [{"id": "ceramite-fists", "profiles": {"standard": _weapon("Ceramite Fists", 0.0, 5, 2, 5, 0, 1, {})}}]
	}
}

static func profile(identity: String) -> Dictionary:
	return _build_profiles().get(identity, {}).duplicate(true)

static func digest() -> String:
	return var_to_str({"id": ID, "profiles": _build_profiles()}).sha256_text()

static func _weapon(label: String, range_inches: float, attacks: int, skill: int, strength: int, ap: int, damage: int, keywords: Dictionary) -> Dictionary:
	return {"name": label, "range_inches": range_inches, "attacks": attacks, "skill": skill,
		"strength": strength, "ap": ap, "damage": damage, "keywords": keywords}

extends RefCounted
## Shared low-level state for Core Rules reaction stratagems.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ID := "core-reaction-stratagems-2026-10-tank-shock-v1"
const ADMITTED_ABILITIES := ["fire-overwatch", "heroic-intervention", "counteroffensive", "epic-challenge", "explosives", "smokescreen", "crushing-impact"]

static func enable(state: Dictionary) -> void:
	if state.has("core_reactions"): return
	state.core_reactions = {"implementation": ID, "overwatch": {}, "heroic": {}, "chargers": [], "charge_closed": false, "epic": {}}
	state.pack_hash = (str(state.pack_hash) + ID).sha256_text()
	state.scope = "Core stratagems: Smokescreen, Explosives, Fire Overwatch, Heroic Intervention, Counteroffensive, Epic Challenge and Crushing Impact/Tank Shock. " + str(state.get("scope", ""))
	for ability: String in ADMITTED_ABILITIES: Registry.admit(state, ability, ID)

static func enabled(state: Dictionary) -> bool:
	return state.get("core_reactions", {}).get("implementation", "") == ID and state.has("stratagems") and UnitAbilities.enabled(state)

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func heroic_charger(state: Dictionary, player: int, squad: int) -> bool:
	if not enabled(state): return false
	var heroic: Dictionary = state.core_reactions.get("heroic", {})
	return heroic.get("phase_key", "") == phase_key(state) and int(heroic.get("player", -1)) == player and int(heroic.get("squad", -1)) == squad

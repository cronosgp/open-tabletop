extends RefCounted
## Verified effect, explicit canonical units/equipment; imported DSL stays inert.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ID := "intercessor-hail-of-bolts-v1"
const DEFINITION := "40kdc:11e:adeptus-astartes:intercessor-squad"
const SOURCE := "https://assets.warhammer-community.com/eng_04-06_warhammer40k_new40k_armageddon_spacemarines_datasheet_cards-hcuj9cke0r-h2rfuky1yw.pdf"

static func intercessors(state: Dictionary, squad: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad: continue
		if model.get("definition_id", "") != DEFINITION: return false
		found = true
	return found

static func enable(state: Dictionary) -> void:
	state.hail_of_bolts = {"implementation": ID}
	for squad: int in state.squads:
		if not intercessors(state, squad): continue
		# Replace the provisional slot with the verified named ability, not its DSL.
		state.squads[squad].disabled_abilities.erase("target-elimination")
		state.squads[squad].superseded_abilities = {"target-elimination": "hail-of-bolts"}
		var abilities: Array = state.squads[squad].get("enabled_abilities", []).duplicate()
		if "hail-of-bolts" not in abilities: abilities.append("hail-of-bolts")
		state.squads[squad].enabled_abilities = abilities

static func available(state: Dictionary, squad: int) -> bool:
	return state.get("hail_of_bolts", {}).get("implementation", "") == ID and intercessors(state, squad) and state.phase == "shooting" and state.active == state.squads[squad].owner

static func targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not available(state, squad): return result
	for target: int in state.squads:
		if state.squads[target].owner == state.squads[squad].owner or Geometry.alive(state, target).is_empty(): continue
		for model: int in Geometry.alive(state, squad):
			if Terrain.targeting(state, model, target).visible:
				result.append(target)
				break
	return result

static func choice_error(state: Dictionary, squad: int, target: int, melee: bool) -> String:
	if target == -1: return ""
	if melee or not available(state, squad): return "Hail of Bolts requires an enabled Intercessor unit in its own Shooting phase."
	if target not in targets(state, squad): return "Choose a living enemy unit visible to the Intercessors for Hail of Bolts."
	return ""

static func bolt_rifle(state: Dictionary, model: int, choice: Dictionary) -> bool:
	# These are server-owned inventory IDs, never client-supplied weapon stats.
	if state.units[model].has("ranged_weapons"):
		return choice.weapon == "rifle" and choice.profile in ["saturation", "focused"]
	return choice.weapon == "default" and choice.profile == "default" and state.squads[state.units[model].squad].weapon.get("name", "") == "Bolt Rifle / Saturation"

static func bonus(state: Dictionary, squad: int, target: int, selected: int, model: int, choice: Dictionary) -> int:
	return 2 if selected != -1 and selected == target and available(state, squad) and bolt_rifle(state, model, choice) else 0

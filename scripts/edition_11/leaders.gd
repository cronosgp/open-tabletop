extends RefCounted
## Leader attachment and Warlord designation (roadmap A1, first increment).
## Provisional reference: the attachment permissions below are curated from the
## pinned community snapshot's four reference squads and must be verified against
## the final 11e dataslate before being treated as official. Never executes the
## imported ability DSL; every pairing here is explicit and gated.

const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const ID := "leader-attachment-reference-v1"
const SOURCE := "community starter snapshot (pre-launch provisional); verify against the final 11e dataslate"

## Leader definition_id -> bodyguard definition_ids it may lead (provisional).
const ATTACHMENTS := {
	"40kdc:11e:adeptus-astartes:captain": ["40kdc:11e:adeptus-astartes:intercessor-squad", "40kdc:11e:adeptus-astartes:terminator-squad"],
	"40kdc:11e:necrons:overlord": ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:immortals"],
}

static func enable(state: Dictionary) -> void:
	state.leaders = {"implementation": ID}
	Capabilities.admit(state, "leader", ID)
	for squad: int in state.squads:
		if not is_leader(state, squad): continue
		Capabilities.admit_squad(state, squad, "leader")

static func definition_of(state: Dictionary, squad: int) -> String:
	for model: Dictionary in state.units.values():
		if model.squad == squad: return str(model.get("definition_id", ""))
	return ""

static func is_leader(state: Dictionary, squad: int) -> bool:
	return definition_of(state, squad) in ATTACHMENTS

static func can_attach(state: Dictionary, leader: int, bodyguard: int) -> bool:
	if not state.squads.has(leader) or not state.squads.has(bodyguard): return false
	if state.squads[leader].owner != state.squads[bodyguard].owner: return false
	return definition_of(state, bodyguard) in ATTACHMENTS.get(definition_of(state, leader), [])

static func attach_error(state: Dictionary, leader: int, bodyguard: int) -> String:
	if state.get("leaders", {}).get("implementation", "") != ID: return "Leader attachment is disabled."
	if not is_leader(state, leader): return "Select a unit with the Leader ability."
	if not can_attach(state, leader, bodyguard): return "This leader cannot attach to that bodyguard unit."
	return Attachments.form_practice_unit(state, bodyguard, leader)

static func warlord_error(state: Dictionary, squad: int) -> String:
	if state.get("leaders", {}).get("implementation", "") != ID: return "Leader/Warlord rules are disabled."
	if not state.squads.has(squad): return "Invalid Warlord unit."
	if not is_leader(state, squad): return "The Warlord must be a unit with the Leader ability."
	return ""

## Designate the Warlord as a model id so the pointer survives attachment merge.
static func designate_warlord(state: Dictionary, squad: int) -> String:
	var error := warlord_error(state, squad)
	if not error.is_empty(): return error
	for model: int in Geometry.alive(state, squad):
		state.warlord = model
		return ""
	return "The Warlord unit has no living models."

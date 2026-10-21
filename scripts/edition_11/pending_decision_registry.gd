extends RefCounted
## Read-only registry for normalized pending-choice projections.
## Caller-supplied source order preserves rules-specific priority checkpoints.

const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const DamageAllocation = preload("res://scripts/edition_11/damage_allocation.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

static func current(state: Dictionary, source_order: Array) -> Dictionary:
	for source: Variant in source_order:
		var decision := _for_source(state, str(source))
		if not decision.is_empty(): return decision
	return {}

static func _for_source(state: Dictionary, source: String) -> Dictionary:
	match source:
		"combat-doctrines": return Doctrines.pending_decision(state)
		"damage-allocation": return DamageAllocation.pending_decision(state)
		"reanimation": return Reanimation.pending_decision(state)
		"stratagems": return Stratagems.pending_decision(state)
		"unit-actions": return UnitActions.pending_decision(state)
	return {}

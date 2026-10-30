extends RefCounted

const C = preload("res://scripts/edition_11/prepared_training.gd").Combat
const Equipment = preload("res://scripts/edition_11/equipment.gd")

static func fixed_weapon_plan_failures(state: Dictionary, profile: Dictionary, model: int, target_squad: int) -> Array[String]:
	var failures: Array[String] = []
	var targets: Array[int] = C.living(state, target_squad)
	if targets.is_empty():
		return ["target squad %d has no living models" % target_squad]
	var target_model: int = targets[0]
	var old_phase := str(state.phase)
	var old_active := int(state.active)
	var old_phase_key := str(state.unit_abilities.get("phase_key", ""))
	var old_attacker_position: Vector2 = state.units[model].position
	var old_target_position: Vector2 = state.units[target_model].position
	for melee: bool in [false, true]:
		var weapons: Array = profile.get("melee", []) if melee else profile.get("ranged", [])
		for weapon: Dictionary in weapons:
			var weapon_id := str(weapon.get("id", ""))
			for profile_id: String in weapon.get("profiles", {}):
				var expected: Dictionary = weapon.profiles[profile_id]
				state.units[model].position = Vector2.ZERO
				state.units[target_model].position = Vector2(1.75, 0.0) if melee else Vector2(10.0, 0.0)
				state.phase = "fight" if melee else "shooting"
				state.active = int(state.units[model].owner)
				state.unit_abilities.phase_key = C.UnitActions.key(state)
				var selected := Equipment.select(state, model, melee, weapon_id, profile_id)
				if not str(selected.get("error", "")).is_empty() or selected.get("stats", {}) != expected:
					failures.append("%s/%s Equipment mismatch: %s" % [weapon_id, profile_id, str(selected.get("error", ""))])
					continue
				var amount := C.UnitAbilities.melee_attack_count(state, model, expected) if melee else 1
				var assignments: Array[Dictionary] = [{
					"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": profile_id
				}]
				if melee:
					var current_is_extra: bool = bool(expected.get("keywords", {}).get("extra-attacks", false))
					var seen_weapon_ids := {weapon_id: true}
					var ordinary_added := not current_is_extra
					for other_weapon: Dictionary in weapons:
						var other_id := str(other_weapon.get("id", ""))
						if other_id.is_empty() or seen_weapon_ids.has(other_id): continue
						for other_profile_id: String in other_weapon.get("profiles", {}):
							var other_profile: Dictionary = other_weapon.profiles[other_profile_id]
							var is_extra: bool = bool(other_profile.get("keywords", {}).get("extra-attacks", false))
							if is_extra:
								assignments.append({"model": model, "target": target_squad, "amount": int(other_profile.get("attacks", 1)) if other_profile.get("attacks", 1) is int else 1, "weapon": other_id, "profile": other_profile_id})
								seen_weapon_ids[other_id] = true
								break
							if current_is_extra and not ordinary_added and not is_extra:
								assignments.append({"model": model, "target": target_squad, "amount": int(other_profile.get("attacks", 1)) if other_profile.get("attacks", 1) is int else 1, "weapon": other_id, "profile": other_profile_id})
								ordinary_added = true
								seen_weapon_ids[other_id] = true
								break
				var plan: Dictionary = C.AttackPlan.prepare(state, int(state.units[model].squad), melee, assignments, true)
				var planned_weapons: Dictionary = {}
				for batch: Dictionary in plan.get("batches", []):
					for source: Dictionary in batch.get("context", {}).get("attack_sources", []):
						planned_weapons["%d:%s" % [int(source.get("model", -1)), str(source.get("weapon", ""))]] = true
				if not str(plan.get("error", "")).is_empty() or not planned_weapons.has("%d:%s" % [model, weapon_id]):
					failures.append("%s/%s AttackPlan rejected: %s" % [weapon_id, profile_id, str(plan.get("error", "missing selected weapon from attack batches"))])
	state.phase = old_phase
	state.active = old_active
	state.unit_abilities.phase_key = old_phase_key
	state.units[model].position = old_attacker_position
	state.units[target_model].position = old_target_position
	return failures

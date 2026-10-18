extends RefCounted
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Implacable = preload("res://scripts/edition_11/implacable_eradication.gd")
const Hail = preload("res://scripts/edition_11/hail_of_bolts.gd")
const Awakened = preload("res://scripts/edition_11/awakened_dynasty.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Oath = preload("res://scripts/edition_11/oath_of_moment.gd")
## Owned weapons/profiles; target assignments freeze before dice/casualties.
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Allocation = preload("res://scripts/edition_11/damage_allocation.gd")

static func _combine_rerolls(current: String, additional: String) -> String:
	if current == "failed" or additional == "failed": return "failed"
	if current == "ones" or additional == "ones": return "ones"
	return current

static func _weapon_targets_one_unit(state: Dictionary, entries: Array, model: int, weapon_id: String, target: int, melee: bool) -> bool:
	for row: Variant in entries:
		if not row is Dictionary or row.get("model", -1) != model: continue
		var selected := Equipment.select(state, model, melee, str(row.get("weapon", "")), str(row.get("profile", "")))
		if selected.has("error") or selected.weapon != weapon_id: continue
		if row.get("target", -1) != target: return false
	return true

static func legal_targets(state: Dictionary, model: int, melee: bool, weapon_id: String = "", profile_id: String = "") -> Array[int]:
	var result: Array[int] = []
	if not state.units.has(model) or state.units[model].wounds <= 0 or not state.units[model].get("on_battlefield", true): return result
	var unit: Dictionary = state.units[model]
	var choice := Equipment.select(state, model, melee, weapon_id, profile_id)
	if choice.has("error"): return result
	var weapon: Dictionary = DetachmentStratagems.weapon(state, unit.squad, choice.stats, Doctrines.weapon(state, unit.squad, choice.stats, melee), melee)
	if not melee and state.squads[unit.squad].advanced and not weapon.keywords.get("assault", false): return result
	var engaged_shooter := Queue.engaged(state, unit.squad)
	var heavy_model := Traits.heavy_model(unit)
	if not melee and engaged_shooter and (state.squads[unit.squad].advanced or (not heavy_model and not weapon.keywords.get("close-quarters", false))): return result
	for target: int in state.squads:
		if state.squads[target].owner == unit.owner or Geometry.alive(state, target).is_empty(): continue
		if not Traits.hunter_error(weapon, Traits.target_keywords(state, target)).is_empty(): continue
		if melee:
			if Geometry.distance_to_target(state, unit, target) <= 2.001: result.append(target)
		else:
			var target_engaged := Queue.engaged(state, target)
			if target_engaged and weapon.keywords.get("blast", false): continue
			if engaged_shooter and not heavy_model:
				if not engaged_with(state, unit.squad, target): continue
			elif target_engaged and not engaged_with(state, unit.squad, target) and not Traits.heavy_unit(state, target): continue
			var sight := Terrain.targeting(state, model, target)
			if not sight.visible or sight.distance > float(weapon.range_inches): continue
			var lone_operative_blocked := false
			for target_model: int in Geometry.alive(state, target):
				if UnitAbilities.lone_operative_active(state, target_model) and sight.distance > 12.001: lone_operative_blocked = true
			if lone_operative_blocked: continue
			if DetachmentStratagems.vengeful_shooter(state, unit.squad) and target != int(state.detachment_stratagems.vengeful.attacker): continue
			if CoreReactions.overwatch_shooter(state, unit.squad) and sight.distance > 24.001: continue
			result.append(target)
	return result

static func engaged_with(state: Dictionary, squad: int, target: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		if Geometry.distance_to_target(state, state.units[model], target) <= 2.001: return true
	return false

static func single_target(state: Dictionary, squad: int, target: int, melee: bool) -> Array:
	var entries: Array = []
	for model: int in Geometry.alive(state, squad):
		if melee and Equipment.explicit_loadout(state, model, true):
			var ordinary := false
			var used: Array[String] = []
			for option: Dictionary in Equipment.choices(state, model, true):
				if option.weapon in used or target not in legal_targets(state, model, true, option.weapon, option.profile): continue
				var extra := Traits.extra(option.stats)
				if not extra and ordinary: continue
				used.append(option.weapon)
				if not extra: ordinary = true
				entries.append({"model": model, "target": target, "weapon": option.weapon, "profile": option.profile, "amount": 1 if option.stats.attacks is String else int(option.stats.attacks)})
			continue
		if target in legal_targets(state, model, melee):
			var attacks: Variant = Equipment.select(state, model, melee).stats.attacks
			entries.append({"model": model, "target": target, "amount": int(attacks) if melee and not attacks is String else 1})
	return entries

static func defender(state: Dictionary, target: int) -> Dictionary:
	return Groups.defender(state, target)

static func prepare(state: Dictionary, squad: int, melee: bool, entries: Array, lethal: bool, hail_target: int = -1) -> Dictionary:
	if UnitAbilities.enabled(state): return _prepare_equipped(state, squad, melee, entries, lethal, hail_target)
	var ability_error := Hail.choice_error(state, squad, hail_target, melee)
	if not ability_error.is_empty(): return {"error": ability_error}
	if hail_target != -1:
		var prepared := _prepare_equipped(state, squad, melee, entries, lethal, hail_target)
		if prepared.error.is_empty(): prepared.hail_of_bolts = {"implementation": Hail.ID, "target": hail_target}
		return prepared
	if not melee:
		if Queue.engaged(state, squad): return _prepare_equipped(state, squad, false, entries, lethal)
		for row: Variant in entries:
			if row is Dictionary and row.get("target") is int and state.squads.has(row.target) and Queue.engaged(state, row.target): return _prepare_equipped(state, squad, false, entries, lethal)
	var primary: Dictionary = state.squads[squad].melee_weapon if melee else state.squads[squad].weapon
	if primary.keywords.get("precision", false): return _prepare_equipped(state, squad, melee, entries, lethal)
	if melee and primary.attacks is String: return _prepare_equipped(state, squad, melee, entries, lethal)
	if primary.keywords.has("hunter") or primary.keywords.get("extra-attacks", false): return _prepare_equipped(state, squad, melee, entries, lethal)
	if not melee and Attacks.RandomStat.random(state.squads[squad].weapon.attacks): return _prepare_equipped(state, squad, melee, entries, lethal)
	for model: int in Geometry.alive(state, squad):
		if Equipment.explicit_loadout(state, model, melee): return _prepare_equipped(state, squad, melee, entries, lethal)
	for entry: Variant in entries:
		if entry is Dictionary and entry.has("weapon"): return _prepare_equipped(state, squad, melee, entries, lethal)
	return _prepare_legacy(state, squad, melee, entries, lethal)

static func _prepare_equipped(state: Dictionary, squad: int, melee: bool, entries: Array, lethal: bool, hail_target: int = -1) -> Dictionary:
	if entries.is_empty() or entries.size() > 256: return {"error": "Declare between 1 and 256 attack assignments."}
	if CoreReactions.overwatch_shooter(state, squad):
		if melee: return {"error": "Fire Overwatch is a ranged attack."}
		var seen: Dictionary = {}
		for row: Variant in entries:
			if row is Dictionary and row.get("target") is int: seen[row.target] = true
		if seen.size() != 1: return {"error": "Overwatch can target only one visible enemy unit."}
	var selected: Dictionary = {}
	var totals: Dictionary = {}
	var pairs: Dictionary = {}
	var batches: Dictionary = {}
	var order: Array[int] = []
	var sidearms: Dictionary = {}
	var ordinary_weapons: Dictionary = {}
	for row: Variant in entries:
		if not row is Dictionary or row.size() not in [3, 5]: return {"error": "Invalid equipped attack assignment."}
		for key in ["model", "target", "amount"]:
			if not row.get(key) is int: return {"error": "Attack IDs and amounts must be integers."}
		if row.size() == 5 and (not row.get("weapon") is String or not row.get("profile") is String or row.weapon.is_empty() or row.profile.is_empty()): return {"error": "Select weapon and profile IDs, not client weapon stats."}
		var model: int = row.model
		if not state.units.has(model) or state.units[model].wounds <= 0 or state.units[model].squad != squad: return {"error": "Assign only living models in this unit."}
		var choice := Equipment.select(state, model, melee, row.get("weapon", ""), row.get("profile", ""))
		if choice.has("error"): return choice
		var weapon: Dictionary = Doctrines.weapon(state, squad, choice.stats, melee)
		if not state.squads.has(row.target) or state.squads[row.target].owner == state.squads[squad].owner or Geometry.alive(state, row.target).is_empty(): return {"error": "Select a living enemy target unit."}
		var raw_context := {"weapon_count": 1, "distance_inches": 0.0, "heavy_eligible": false, "target_model_count": Geometry.alive(state, row.target).size(), "target_engaged": Queue.engaged(state, row.target), "single_target_for_cleave": _weapon_targets_one_unit(state, entries, model, choice.weapon, row.target, melee)}
		raw_context.target_keywords = Traits.target_keywords(state, row.target)
		var raw_error := Attacks._validate(weapon, defender(state, row.target), raw_context)
		if not raw_error.is_empty(): return {"error": raw_error}
		var random_melee: bool = melee and Attacks.RandomStat.random(weapon.attacks)
		if not melee and not Traits.heavy_model(state.units[model]):
			var sidearm: bool = weapon.keywords.get("close-quarters", false)
			if sidearms.has(model) and sidearms[model] != sidearm: return {"error": "Select Close-quarters weapons or other ranged weapons for this model, not both."}
			sidearms[model] = sidearm
		if not melee and Traits.extra(weapon): return {"error": "Extra Attacks is a melee weapon selection rule."}
		if melee and not Traits.extra(weapon):
			if ordinary_weapons.has(model) and ordinary_weapons[model] != choice.weapon: return {"error": "Select only one ordinary melee weapon for each model, plus its Extra Attacks weapons."}
			ordinary_weapons[model] = choice.weapon
		var slot := "%d:%s" % [model, choice.weapon]
		if selected.has(slot) and (selected[slot].weapon != choice.weapon or selected[slot].profile != choice.profile): return {"error": "Select only one profile for each weapon instance."}
		selected[slot] = choice
		if row.amount <= 0 or row.amount > 1000: return {"error": "Assign a positive attack amount."}
		var pair := "%s:%d" % [slot, row.target]
		if pairs.has(pair): return {"error": "Combine duplicate assignments."}
		pairs[pair] = true
		totals[slot] = int(totals.get(slot, 0)) + row.amount
		if random_melee and (row.amount != 1 or totals[slot] != 1): return {"error": "A random-A melee weapon currently assigns one whole weapon to one target; split declarations are unavailable."}
		if not melee and totals[slot] != 1: return {"error": "Each ranged weapon instance has one target."}
		if row.target not in legal_targets(state, model, melee, choice.weapon, choice.profile): return {"error": "Selected profile cannot target this unit (range, visibility, engagement or Advance)."}
		var context := {"weapon_count": 1, "use_lethal_hits": lethal, "benefit_of_cover": false, "hit_modifier": Awakened.hit_bonus(state, squad), "attack_sources": []}
		context.merge(Oath.context(state, squad, row.target), true)
		if CoreReactions.overwatch_shooter(state, squad):
			context.snap_shooting = true
			context.hit_reroll = "none"
		context.hit_modifier += UnitAbilities.hit_bonus(state, squad, row.target, melee)
		var reroll_mode := UnitAbilities.implacable_mode(state, squad, row.target) if UnitAbilities.enabled(state) else Implacable.mode(state, squad, row.target)
		if reroll_mode != "none": context.wound_reroll = reroll_mode
		if UnitAbilities.enabled(state) and reroll_mode == "failed":
			context.wound_reroll = "none"
			context.free_wound_reroll = true
		var effective := DetachmentStratagems.defend(state, squad, row.target, CoreReactions.weapon(state, model, DetachmentStratagems.weapon(state, squad, weapon, UnitAbilities.weapon(state, model, row.target, weapon, melee), melee), melee))
		var expression: Variant = (int(row.amount) + int(effective.attacks) - int(weapon.attacks)) if melee and not random_melee else effective.attacks
		var bonus := 0
		if melee and int(weapon.keywords.get("cleave", 0)) > 0 and raw_context.single_target_for_cleave:
			bonus += int(weapon.keywords.cleave) * floori(float(raw_context.target_model_count) / 5.0)
		var attacks: int = Attacks.RandomStat.spec(expression).maximum
		var profile := DetachmentStratagems.defend(state, squad, row.target, CoreReactions.weapon(state, model, DetachmentStratagems.weapon(state, squad, weapon, UnitAbilities.weapon(state, model, row.target, weapon, melee), melee), melee))
		if DetachmentStratagems.lance_wound(state, squad, profile): context.wound_modifier = clampi(int(context.get("wound_modifier", 0)) + 1, -1, 1)
		if not melee:
			var hail_bonus := Hail.bonus(state, squad, row.target, hail_target, model, choice)
			bonus += hail_bonus
			if hail_bonus > 0: context.hail_of_bolts = {"target": hail_target, "bonus_per_weapon": hail_bonus}
			var sight := Terrain.targeting(state, model, row.target)
			var policy := DetachmentStratagems.hit_policy(state, squad, sight.distance, float(weapon.range_inches))
			if not policy.is_empty() and not context.get("snap_shooting", false): context.hit_reroll = policy
			context.benefit_of_cover = sight.cover and not profile.keywords.get("ignores-cover", false)
			if weapon.keywords.has("rapid-fire") and sight.distance <= float(weapon.range_inches) / 2.0: bonus += int(weapon.keywords["rapid-fire"])
			if weapon.keywords.get("blast", false): bonus += (1 if weapon.keywords.blast is bool else int(weapon.keywords.blast)) * floori(float(raw_context.target_model_count) / 5.0)
			var engaged_shooter := Queue.engaged(state, squad)
			var close_target: bool = weapon.keywords.get("close-quarters", false) and engaged_with(state, squad, row.target)
			if engaged_shooter and Traits.heavy_model(state.units[model]) and not close_target: context.hit_modifier -= 1
			if Queue.engaged(state, row.target) and Traits.heavy_unit(state, row.target) and not close_target: context.hit_modifier -= 1
			if weapon.keywords.get("heavy", false) and not engaged_shooter and not state.squads[squad].set_up_this_turn and state.squads[squad].moved_distance <= 3.0: context.hit_modifier += 1
			context.hit_modifier = clampi(context.hit_modifier, -1, 1)
		if UnitAbilities.primarch_aura_active(state, squad):
			if not context.get("snap_shooting", false): context.hit_reroll = _combine_rerolls(str(context.get("hit_reroll", "none")), "ones")
			context.wound_reroll = _combine_rerolls(str(context.get("wound_reroll", "none")), "ones")
		# Expand attack-count/eligibility mechanics before pooling identical attacks.
		for keyword in ["rapid-fire", "assault", "heavy", "ignores-cover", "blast", "hazardous", "close-quarters", "hunter", "extra-attacks", "lance", "cleave"]: profile.keywords.erase(keyword)
		if UnitAbilities.enabled(state): context.use_lethal_hits = true
		if not lethal and not UnitAbilities.enabled(state): profile.keywords.erase("lethal-hits")
		profile.attacks = 1
		var signature := {"skill": profile.skill, "strength": profile.strength, "ap": profile.ap, "damage": profile.damage, "keywords": profile.keywords}
		var key := "%d:%s:%s:%d" % [row.target, var_to_str(signature), str(context.benefit_of_cover), context.hit_modifier]
		if context.has("wound_reroll"): key += ":" + context.wound_reroll
		if context.get("free_wound_reroll", false): key += ":implacable-choice"
		if context.has("hail_of_bolts"): key += ":hail-of-bolts"
		if context.has("hit_reroll"): key += ":hit-reroll:" + str(context.hit_reroll)
		if context.has("wound_modifier"): key += ":wound-modifier:" + str(context.wound_modifier)
		if not batches.has(key): batches[key] = {"target": row.target, "weapon": profile, "context": context, "labels": [], "count": 0}
		batches[key].count += attacks + bonus
		batches[key].context.attack_sources.append({"model": model, "weapon": choice.weapon, "expression": expression, "bonus": bonus})
		if choice.label not in batches[key].labels: batches[key].labels.append(choice.label)
		if row.target not in order: order.append(row.target)
	if melee:
		for slot: String in selected:
			var required: int = 1 if selected[slot].stats.attacks is String else int(selected[slot].stats.attacks)
			if int(totals[slot]) != required: return {"error": "Allocate every attack from each selected melee weapon."}
		for model: int in Geometry.alive(state, squad):
			var required := _melee_selection_error(state, model, selected, ordinary_weapons)
			if not required.is_empty(): return {"error": required}
	var prepared: Array[Dictionary] = []
	for target: int in order:
		for batch: Dictionary in batches.values():
			if batch.target != target: continue
			batch.weapon.attacks = batch.count
			batch.weapon.name = ", ".join(batch.labels)
			var error := Attacks._validate(batch.weapon, defender(state, target), batch.context)
			if not error.is_empty(): return {"error": error}
			prepared.append(batch)
	var hazardous := 0
	for choice: Dictionary in selected.values():
		if choice.stats.keywords.get("hazardous", false): hazardous += 1
	return {"error": "", "batches": prepared, "targets": order, "hazardous_count": hazardous}

static func _melee_selection_error(state: Dictionary, model: int, selected: Dictionary, ordinary: Dictionary) -> String:
	var ordinary_available := false
	for instance: Dictionary in Equipment.inventory(state, model, true):
		var kind: Variant = null
		var available := false
		for profile: String in instance.profiles:
			var extra := Traits.extra(instance.profiles[profile])
			if kind != null and kind != extra: return "Profiles of one weapon must agree on Extra Attacks; unresolved equipment is blocked."
			kind = extra
			if not legal_targets(state, model, true, instance.id, profile).is_empty(): available = true
		if not available: continue
		if kind == true:
			if not selected.has("%d:%s" % [model, instance.id]):
				var label := "Extra Attacks weapon"
				for option: Dictionary in Equipment.choices(state, model, true):
					if option.weapon == instance.id:
						label = option.label
						break
				return "Select every eligible Extra Attacks weapon for model %d: %s." % [model, label]
		else: ordinary_available = true
	if ordinary_available and not ordinary.has(model): return "Select one eligible ordinary melee weapon for model %d as well as its Extra Attacks weapons." % model
	return ""

static func _prepare_legacy(state: Dictionary, squad: int, melee: bool, entries: Array, lethal: bool) -> Dictionary:
	if entries.is_empty() or entries.size() > 256: return {"error": "Declare between 1 and 256 attack assignments."}
	var weapon: Dictionary = Doctrines.weapon(state, squad, state.squads[squad].melee_weapon if melee else state.squads[squad].weapon, melee)
	if melee and Attacks.RandomStat.random(weapon.attacks): return {"error": "Random melee A is not supported yet."}
	var totals: Dictionary = {}
	var pairs: Dictionary = {}
	var batches: Dictionary = {}
	var order: Array[int] = []
	for entry: Variant in entries:
		if not entry is Dictionary: return {"error": "Invalid attack assignment."}
		if entry.size() != 3: return {"error": "Each assignment needs only model, target and amount."}
		for key in ["model", "target", "amount"]:
			if not entry.get(key) is int: return {"error": "Attack assignment IDs and amounts must be integers."}
		var model: int = entry.model
		var target: int = entry.target
		if not state.units.has(model) or state.units[model].wounds <= 0 or state.units[model].squad != squad: return {"error": "Assign only living models in the selected unit."}
		if entry.amount <= 0 or entry.amount > 1000: return {"error": "Assign a positive number of attacks."}
		if target not in legal_targets(state, model, melee): return {"error": "Model %d cannot target unit %d." % [model, target]}
		var pair := "%d:%d" % [model, target]
		if pairs.has(pair): return {"error": "Combine duplicate model/target assignments into one row."}
		pairs[pair] = true
		totals[model] = int(totals.get(model, 0)) + entry.amount
		if not melee and totals[model] != 1: return {"error": "A ranged weapon must target one unit with all of its attacks."}
		if target not in order: order.append(target)
		var cover := false
		var half := false
		if not melee:
			var sight := Terrain.targeting(state, model, target)
			cover = sight.cover
			half = weapon.keywords.has("rapid-fire") and sight.distance <= float(weapon.range_inches) / 2.0
		var key := "%d:%s:%s" % [target, str(cover), str(half)]
		if not batches.has(key): batches[key] = {"target": target, "cover": cover, "half": half, "count": 0}
		batches[key].count += entry.amount
	if melee:
		for model: int in Geometry.alive(state, squad):
			if not legal_targets(state, model, true).is_empty() and int(totals.get(model, 0)) != int(weapon.attacks):
				return {"error": "Allocate all %d melee attacks for model %d before resolving." % [weapon.attacks, model]}
	var prepared: Array[Dictionary] = []
	for target: int in order:
		for key: String in batches:
			var batch: Dictionary = batches[key]
			if batch.target != target: continue
			var profile := weapon.duplicate(true)
			var context := {"weapon_count": batch.count, "use_lethal_hits": lethal, "hit_modifier": Awakened.hit_bonus(state, squad)}
			context.merge(Oath.context(state, squad, target), true)
			var reroll_mode := Implacable.mode(state, squad, target)
			if reroll_mode != "none": context.wound_reroll = reroll_mode
			context.target_model_count = Geometry.alive(state, target).size()
			context.target_engaged = Queue.engaged(state, target)
			if melee:
				profile.attacks = batch.count
				context.weapon_count = 1
			else:
				context.distance_inches = 0.0 if batch.half else float(weapon.range_inches)
				context.benefit_of_cover = batch.cover
				context.heavy_eligible = not state.squads[squad].set_up_this_turn and state.squads[squad].moved_distance <= 3.0
			var error := Attacks._validate(profile, defender(state, target), context)
			if not error.is_empty(): return {"error": error}
			var count: int = profile.attacks * context.weapon_count
			if batch.half: count += int(profile.keywords.get("rapid-fire", 0)) * context.weapon_count
			if count > 1000: return {"error": "Attack pool exceeds prototype limit."}
			prepared.append({"target": target, "weapon": profile, "context": context})
	return {"error": "", "batches": prepared, "targets": order, "hazardous_count": totals.size() if weapon.keywords.get("hazardous", false) else 0}

static func resolve(state: Dictionary, prepared: Dictionary, roller: Callable) -> Dictionary:
	var working := state.duplicate(true)
	Allocation.start(working, prepared, 0, 0, [], false, true, false)
	var result := Allocation.pump(working, roller)
	if not result.error.is_empty(): return result
	var pending: Dictionary = working.pending_attack
	return {"error": "", "units": working.units, "pools": pending.pools, "damage": pending.damage, "killed": pending.killed}

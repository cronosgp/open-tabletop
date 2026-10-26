extends RefCounted
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const RollWindows = preload("res://scripts/edition_11/attack_roll_window.gd")
const DamageAllocation = preload("res://scripts/edition_11/damage_allocation.gd")
const Hazard = preload("res://scripts/edition_11/hazardous.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const TemplarVows = preload("res://scripts/edition_11/templar_vows.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const Bladeguard = preload("res://scripts/edition_11/bladeguard.gd")
const Healing = preload("res://scripts/edition_11/unit_healing.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const R = preload("res://scripts/edition_11/reanimation_protocols.gd")
const D = preload("res://scripts/edition_11/deployment.gd")
const T = preload("res://scripts/edition_11/terrain.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DamoclesUplink = preload("res://scripts/edition_11/gauntlet_damocles_uplink.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const PhobosLibrarian = preload("res://scripts/edition_11/phobos_librarian.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
const Reivers = preload("res://scripts/edition_11/reivers.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const CombiLieutenant = preload("res://scripts/edition_11/combi_lieutenant.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const TargetAuguryWeb = preload("res://scripts/edition_11/target_augury_web.gd")
const MasterMachineWar = preload("res://scripts/edition_11/master_machine_war.gd")
const AdeptOfTheOmnissiah = preload("res://scripts/edition_11/adept_of_the_omnissiah.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const PurgationRun = preload("res://scripts/edition_11/purgation_run.gd")
const PhobosShadowMasters = preload("res://scripts/edition_11/phobos_shadow_masters.gd")
const PhobosExecuteRedeploy = preload("res://scripts/edition_11/phobos_execute_redeploy.gd")
const CatoSicarius = preload("res://scripts/edition_11/cato_sicarius.gd")
const VictrixHonourGuard = preload("res://scripts/edition_11/victrix_honour_guard.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const CommandBattleShock = preload("res://scripts/edition_11/command_battle_shock.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")

static func key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func _ingress_action_id(state: Dictionary, player: int, squad: int, homer: bool) -> String:
	return "ingress:%d:%s:%d:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", "")), player, squad, "homer" if homer else "reserve"]

static func _ingress_frame_error(state: Dictionary, window: Dictionary) -> String:
	var frame_id := str(window.get("resolution_frame_id", ""))
	var owners: Array = window.get("owners", [])
	if owners.is_empty(): return "The active ingress continuation has no decision owner."
	var action_id := _ingress_action_id(state, int(owners[0]), int(window.get("squad", -1)), bool(window.get("homer", false)))
	var frame := ResolutionFrames.current(state)
	if frame_id.is_empty() or str(frame.get("frame_id", "")) != frame_id or str(frame.get("kind", "")) != "unit-action" or str(frame.get("action_id", "")) != action_id:
		return "The active ingress continuation is missing."
	return ""

static func pending(state: Dictionary) -> Dictionary:
	return state.get("unit_abilities", {}).get("window", {})

## Exhaustive discriminator set for persisted UnitActions windows handled by this dispatcher.
## Keep unknown kinds out of the generic phase-window decline path.
static func supported_window_kind(kind: String) -> bool:
	return kind in [
		"start", "end", "counter", "demi",
		"damage-reroll", "aquilon-hit", "machine-spirit-hit", "machine-spirit-wound", "armoured-wrath-hit", "armoured-wrath-wound", "martial-paragon-hit", "martial-paragon-wound", "wound", "nightforged-attack-count", "nightforged-hazard",
		DeadlyDemise.WINDOW, DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW, DetachmentStratagems.LAYERED_CERAMITE_WINDOW,
		"evade-and-survive", "evade-placement", CatoSicarius.WINDOW, CatoSicarius.PLACEMENT,
		TacticalFluidity.WINDOW, TacticalFluidity.PLACEMENT, PurgationRun.WINDOW, PurgationRun.PLACEMENT, PhobosShadowMasters.WINDOW, PhobosExecuteRedeploy.WINDOW,
		VictrixHonourGuard.WINDOW, VictrixHonourGuard.PLACEMENT, "forward-assault-mark",
		CoreReactions.EXPLOSIVES, CoreReactions.CRUSHING_MORTAL, Hammer.MORTAL_WINDOW, CoreReactions.GRAVIS_ARMOURED_IMPACT_MORTAL, CoreReactions.WRATH_OF_THE_LION_MORTAL, CoreReactions.PHOBOS_MORTIS_SNARES_MORTAL, Hammer.ID,
		DetachmentStratagems.PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW, DetachmentStratagems.PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW,
		DetachmentStratagems.HEADHUNTER_WINDOW, DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW, DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW, DetachmentStratagems.PHOBOS_STRIKE_WINDOW, DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW, DetachmentStratagems.PIOUS_ENMITY_WINDOW, DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW, DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW, DetachmentStratagems.UNSTOPPABLE_WINDOW,
		DetachmentStratagems.ARMOUR_WINDOW, DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW, DetachmentStratagems.WORTHY_WINDOW, DetachmentStratagems.DARKFLIGHT_WINDOW,
		"mounted-shooting-reaction", "stormlance-hurtling", DetachmentStratagems.SHOOTING_REACTION_WINDOW, "blessings-of-the-omnissiah", TargetAuguryWeb.WINDOW, AdeptOfTheOmnissiah.WINDOW,
		"healing", "healing-order", TransportRules.EMERGENCY_WINDOW, TransportRules.DISEMBARK_WINDOW, TransportRules.COMBAT_EMBARKATION_WINDOW,
		"bladeguard", "phobos-shrouding", Incursors.DIVINATOR_WINDOW, Incursors.MINE_WINDOW,
		CoreReactions.TIGURIUS_MORTAL, "scouts", "strategium-command",
		"driven-from-cover", "hailstrike", "shattered-defences", "tactics", "eternal", "ingress",
		CoreReactions.CRUSHING, DetachmentStratagems.MOVEMENT_REACTION_WINDOW
	]

static func setup_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "deployment": return -1
	for player in [1, 2]:
		if not state.unit_abilities.get("setup_players", []).has(player): return player
	return -1

static func actor(state: Dictionary) -> int:
	if setup_actor(state) > 0: return setup_actor(state)
	if state.get("phase", "") == "deployment" and D.current(state) >= 0:
		var deploying_owner := D.actor(state)
		if not choices(state, deploying_owner).is_empty(): return deploying_owner
	if DetachmentStratagems.shooting_reaction_actor(state) > 0: return DetachmentStratagems.shooting_reaction_actor(state)
	var reanimation := R.pending(state)
	if bool(reanimation.get("current", {}).get("reroll_pending", false)): return int(reanimation.get("player", -1))
	if pending(state).get("kind", "") in [DeadlyDemise.WINDOW, DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW] and not pending(state).get("owners", []).is_empty(): return int(pending(state).owners[0])
	if battle_actor(state) > 0: return battle_actor(state)
	if ScoutMoves.actor(state) > 0: return ScoutMoves.actor(state)
	if CommandBattleShock.actor(state) > 0: return CommandBattleShock.actor(state)
	var adamantine_pending := DetachmentStratagems.adamantine_pending(state)
	if not adamantine_pending.is_empty() and not adamantine_pending.get("current_result", {}).is_empty(): return int(adamantine_pending.get("decision_owner", -1))
	if not state.get("fearsome_assault", {}).is_empty():
		var fearsome: Dictionary = state.fearsome_assault
		if not fearsome.get("current_result", {}).is_empty(): return int(fearsome.get("decision_owner", -1))
		return int(fearsome.get("owner", -1))
	var window := pending(state)
	if not window.is_empty(): return int(window.owners[0])
	var undying_owner := DetachmentStratagems.undying_actor(state)
	if undying_owner > 0: return undying_owner
	var sacrifice_owner := DetachmentStratagems.sacrifice_actor(state)
	if sacrifice_owner > 0: return sacrifice_owner
	var vengeance_owner := DetachmentStratagems.darkflight_vengeance_actor(state)
	if vengeance_owner > 0: return vengeance_owner
	var skyborne_owner := DetachmentStratagems.darkflight_skyborne_actor(state)
	if skyborne_owner > 0: return skyborne_owner
	return DetachmentStratagems.gauntlet_combined_actor(state)

## Common decision envelope for the combined phase-start/end ability/reaction windows.
## Specialized action handlers remain authoritative and recompute choices on submit.
static func phase_decision_actor(state: Dictionary) -> int:
	# MatchActor validates pending containers before using this read-only shortcut.
	# Keep the same priority as pending_decision(), without building every legal
	# Overwatch/ability option just to read the owner of a phase window.
	var command_morale_decision := CommandBattleShock.pending_decision(state)
	if not command_morale_decision.is_empty(): return int(command_morale_decision.priority_player_id)
	var window := pending(state)
	if str(window.get("kind", "")) not in ["start", "end"] or not A.enabled(state): return -1
	var owners: Variant = window.get("owners", [])
	if not owners is Array or owners.is_empty() or not owners[0] is int or int(owners[0]) not in [1, 2]: return -1
	return int(owners[0])

static func phase_decision(state: Dictionary) -> Dictionary:
	var window := pending(state)
	var kind := str(window.get("kind", ""))
	if kind not in ["start", "end"] or not A.enabled(state): return {}
	var owners: Array = window.get("owners", [])
	if owners.is_empty(): return {}
	var owner := int(owners[0])
	var options := choices(state, owner)
	var pass_allowed := options.any(func(option: Dictionary) -> bool: return option.get("action", "") in ["pass", "detachment-movement-pass"])
	return PendingDecision.create(state, "unit-actions", "%s-phase:%s" % [kind, str(state.get("phase", ""))], owner, options, pass_allowed)

## Normalized projection of specialized unit-ability and preparation windows.
## Rule handlers still recompute their legal options when a command is submitted.
static func pending_decision(state: Dictionary) -> Dictionary:
	var command_morale_decision := CommandBattleShock.pending_decision(state)
	if not command_morale_decision.is_empty(): return command_morale_decision
	var phase_choice := phase_decision(state)
	if not phase_choice.is_empty(): return phase_choice
	var owner := actor(state)
	if owner <= 0: return {}
	var window := pending(state)
	var timing: String
	if DetachmentStratagems.shooting_reaction_actor(state) == owner:
		timing = "shooting:post-shot-reaction"
	elif bool(R.pending(state).get("current", {}).get("reroll_pending", false)):
		var reanimation_kind := str(R.pending(state).get("kind", ""))
		timing = "post-destruction:%s:reanimation-reroll" % str(state.get("phase", "")) if reanimation_kind == "undying" else "command-phase:reanimation-reroll"
	elif DetachmentStratagems.undying_actor(state) == owner:
		timing = "post-attack:%s:undying-legions" % str(state.get("phase", ""))
	elif DetachmentStratagems.sacrifice_actor(state) == owner:
		timing = "post-destruction:%s:in-sacrifice-victory" % str(state.get("phase", ""))
	elif not window.is_empty():
		var kind := str(window.get("kind", "pending-choice"))
		timing = "%s:%s" % [str(state.get("phase", "")), str(window.get("trigger", kind))]
	elif not state.get("fearsome_assault", {}).is_empty():
		timing = "fight:fearsome-assault"
	elif battle_actor(state) == owner:
		timing = "%s:battle-start-declarations" % str(state.get("phase", ""))
	elif setup_actor(state) == owner:
		timing = "%s:army-preparation" % str(state.get("phase", ""))
	elif state.get("phase", "") == "deployment" and D.current(state) >= 0 and D.actor(state) == owner:
		timing = "deployment:unit-choice"
	elif DetachmentStratagems.darkflight_vengeance_actor(state) == owner:
		timing = "post-attack:shooting:we-are-vengeance"
	elif DetachmentStratagems.darkflight_skyborne_actor(state) == owner:
		timing = "post-attack:shooting:skyborne-surveillance"
	elif DetachmentStratagems.gauntlet_combined_actor(state) == owner:
		timing = "shooting:combined-deployment"
	else:
		return {}
	var options := choices(state, owner)
	if options.is_empty(): return {}
	var pass_allowed := options.any(func(option: Dictionary) -> bool:
		var action := str(option.get("action", ""))
		return action == "pass" or action.ends_with("-pass") or str(option.get("value", "")) == "pass"
	)
	return PendingDecision.create(state, "unit-actions", timing, owner, options, pass_allowed)

static func choice(label: String, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	return {"label": label, "action": action, "model": model, "target": target, "value": value}

static func _apply_lieutenant_loadout(state: Dictionary, model: int) -> String:
	var bearer: Dictionary = state.units.get(model, {})
	if bearer.is_empty() or A.identity(bearer) != "lieutenant": return "Equipment choice belongs to a Lieutenant model."
	var weapons := MarineProfiles.lieutenant_weapons(str(bearer.get("lieutenant_weapon_package", "default")), str(bearer.get("lieutenant_fists_replacement", "ceramite-fists")), bool(bearer.get("lieutenant_storm_shield", false)))
	if weapons.is_empty(): return "Lieutenant equipment combination is not listed on its source datasheet."
	bearer.ranged_weapons = weapons.ranged.duplicate(true)
	bearer.melee_weapons = weapons.melee.duplicate(true)
	var defense: Dictionary = bearer.get("defense", {}).duplicate(true)
	if weapons.invulnerable_target > 0: defense.invulnerable_target = weapons.invulnerable_target
	else: defense.erase("invulnerable_target")
	if defense.is_empty(): bearer.erase("defense")
	else: bearer.defense = defense
	return ""

static func models(state: Dictionary, player: int, ability: String) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner == player: result.append_array(A.sources(state, squad, ability))
	return result

static func is_support_identity(state: Dictionary, unit: Dictionary) -> bool:
	var calgar_in_army := LeaderCatalog.army_has_calgar(state, int(unit.get("owner", -1)))
	return Supports.is_support_identity(A.identity(unit), calgar_in_army)

static func guilliman_model(state: Dictionary, player: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == player and A.identity(state.units[model]) == "roboute-guilliman": return model
	return -1

static func _intercessor_additional_weapon(profile: Dictionary, category: String, identity: String) -> Dictionary:
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(category, []):
		if weapon.get("id", "") == identity: return weapon.duplicate(true)
	return {}

static func _intercessor_weapons(unit: Dictionary) -> void:
	var profile := MarineProfiles.profile("intercessor-squad")
	unit.ranged_weapons = profile.ranged.duplicate(true)
	unit.melee_weapons = profile.melee.duplicate(true)
	var rifle_choice: String = unit.get("intercessor_rifle_choice", "bolt-rifle")
	if rifle_choice != "bolt-rifle":
		unit.ranged_weapons = unit.ranged_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "bolt-rifle")
		var category := "melee" if rifle_choice in ["chainsword", "power-weapon"] else "ranged"
		var replacement := _intercessor_additional_weapon(profile, category, rifle_choice)
		if not replacement.is_empty():
			if category == "melee": unit.melee_weapons.append(replacement)
			else: unit.ranged_weapons.append(replacement)
	var melee_choice: String = unit.get("intercessor_melee_choice", "knives-and-fists")
	if melee_choice != "knives-and-fists":
		unit.melee_weapons = unit.melee_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "knives-and-fists")
		var replacement := _intercessor_additional_weapon(profile, "melee", melee_choice)
		if not replacement.is_empty(): unit.melee_weapons.append(replacement)
	if unit.get("intercessor_grenade_launcher", false):
		var launcher := _intercessor_additional_weapon(profile, "ranged", "grenade-launcher")
		if not launcher.is_empty(): unit.ranged_weapons.append(launcher)

static func _heavy_intercessor_weapons(unit: Dictionary) -> void:
	var profile := MarineProfiles.profile("heavy-intercessor-squad")
	unit.ranged_weapons = profile.ranged.duplicate(true)
	unit.melee_weapons = profile.melee.duplicate(true)
	if unit.get("heavy_intercessor_heavy_bolter", false):
		var heavy_bolter := _intercessor_additional_weapon(profile, "ranged", "heavy-bolter")
		if not heavy_bolter.is_empty():
			unit.ranged_weapons = unit.ranged_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "heavy-bolt-rifle")
			unit.ranged_weapons.append(heavy_bolter)

static func _terminator_weapons(unit: Dictionary) -> void:
	var profile := MarineProfiles.profile("terminator-squad")
	unit.ranged_weapons = profile.ranged.duplicate(true)
	unit.melee_weapons = profile.melee.duplicate(true)
	var melee_choice: String = unit.get("terminator_melee_choice", "power-fist")
	if melee_choice != "power-fist":
		unit.melee_weapons = unit.melee_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "power-fist")
		var replacement := _intercessor_additional_weapon(profile, "melee", melee_choice)
		if not replacement.is_empty(): unit.melee_weapons.append(replacement)
	var special: String = unit.get("terminator_special_weapon", "")
	if special in ["assault-cannon", "heavy-flamer"]:
		unit.ranged_weapons = unit.ranged_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "storm-bolter")
	var replacement := _intercessor_additional_weapon(profile, "ranged", special)
	if not replacement.is_empty(): unit.ranged_weapons.append(replacement)

static func _terminator_special_count(state: Dictionary, squad: int) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) == "terminator-squad" and not state.units[member].get("sergeant", false) and not str(state.units[member].get("terminator_special_weapon", "")).is_empty(): count += 1
	return count

static func _vulkan_placement_complete(state: Dictionary, squad: int) -> bool:
	for model: int in G.alive(state, squad):
		if not state.get("deployment", {}).get("placed", {}).has(model): return false
	return not G.alive(state, squad).is_empty()

static func _objective_index_valid(state: Dictionary, index: int) -> bool:
	return index >= 0 and index < state.get("mission", {}).get("objectives", []).size()

static func _reserve_required_drop_pods(state: Dictionary, player: int) -> String:
	var a: Dictionary = state.unit_abilities
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != player or not TransportRules.is_drop_pod(state, squad) or a.reserves.has(squad): continue
		var cost := int(state.squads[squad].get("training_cost", 0))
		if cost <= 0: return "Drop Pod Assault requires a valid local reserve cost for every Drop Pod."
		var spent := 0
		for reserved: int in a.reserves:
			if int(state.squads[reserved].get("owner", -1)) == player: spent += int(a.reserves[reserved].get("cost", 0))
		if spent + cost > int(state.get("points_limit", 500)) / 2: return "The mandatory Drop Pod reserve placement would exceed the half-army Strategic Reserves limit."
		a.reserves[squad] = {"cost": cost, "source": "drop-pod-assault"}
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == squad: state.units[model].on_battlefield = false
		state.deployment.order.erase(squad)
	return ""

static func choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if state.get("test_winner", 0) != 0: return result
	if not CommandBattleShock.pending(state).is_empty(): return CommandBattleShock.choices(state, player)
	if DetachmentStratagems.sacrifice_actor(state) == player:
		var sacrifice_options := DetachmentStratagems.in_sacrifice_choices(state, player)
		result.append_array(sacrifice_options)
		if not sacrifice_options.is_empty():
			var first_option: Dictionary = sacrifice_options[0]
			result.append(choice("Decline In Sacrifice, Victory for %s" % str(state.squads[int(first_option.target)].get("name", "this destroyed unit")), "wrath-sacrifice-pass", int(first_option.model), int(first_option.target)))
		return result
	var ability_window := pending(state)
	if not ability_window.is_empty() and not supported_window_kind(str(ability_window.get("kind", ""))): return []
	if ability_window.get("kind", "") == DetachmentStratagems.PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW: return DetachmentStratagems.mortis_snares_trigger_choices(state, player)
	if ability_window.get("kind", "") == DetachmentStratagems.PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW: return DetachmentStratagems.mortis_snares_damage_choices(state, player)
	if ability_window.get("kind", "") == PhobosShadowMasters.WINDOW: return PhobosShadowMasters.choices(state, player)
	if ability_window.get("kind", "") == PhobosExecuteRedeploy.WINDOW: return PhobosExecuteRedeploy.choices(state, player)
	if ability_window.get("kind", "") == TargetAuguryWeb.WINDOW: return TargetAuguryWeb.choices(state, player)
	if ability_window.get("kind", "") == AdeptOfTheOmnissiah.WINDOW:
		for row: Dictionary in AdeptOfTheOmnissiah.choices(state, player): result.append(choice(row.label, row.action, row.model, row.target, row.value))
		return result
	result.append_array(StormlanceEnhancements.standard_fight_choices(state, player))
	if Doctrines.enabled(state) and pending(state).is_empty() and state.get("stratagems", {}).get("pending", {}).is_empty():
		result.append_array(MasterMachineWar.choices(state, player, Doctrines.available(state, player)))
		result.append_array(DamoclesUplink.choices(state, player, Doctrines.available(state, player)))
	if ability_window.is_empty() and state.get("pending_attack", {}).is_empty() and DetachmentStratagems.gauntlet_combined_actor(state) == player:
		return DetachmentStratagems.gauntlet_combined_choices(state, player)
	if not A.enabled(state): return [] if not pending(state).is_empty() else result
	if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty():
		result.append_array(TransportRules.choices(state, player))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") in ["scouts", "strategium-command"]:
		return ScoutMoves.choices(state, player)
	if not state.get("awakened_dynasty", {}).get("pending", []).is_empty(): return result
	if Doctrines.needs_choice(state): return result
	var rp := R.pending(state)
	if not rp.is_empty():
		if rp.player == player and rp.current.get("reroll_pending", false):
			result.append(choice("Their Number is Legion: keep D6 %d" % rp.current.raw_roll, "legion-keep"))
			result.append(choice("Their Number is Legion: re-roll once (new result required)", "legion-reroll"))
		return result
	if DetachmentStratagems.undying_actor(state) == player and DetachmentStratagems.shooting_reaction_actor(state) != player:
		for option: Dictionary in DetachmentStratagems.choices(state, player):
			if str(option.get("value", "")) == DetachmentStratagems.UNDYING: result.append(option)
		result.append(choice("Decline Undying Legions for this attack", "undying-pass"))
		return result
	var strat_window: Dictionary = state.get("stratagems", {}).get("pending", {})
	if not strat_window.is_empty():
		if strat_window.player == player:
			var squads: Array = [strat_window.squad] if strat_window.has("squad") else strat_window.get("remaining", [])
			for squad: int in squads:
				if A.potential_discount(state, player, squad) > 0 and A.discount(state, player, squad) == 0:
					result.append(choice("My Will Be Done: reduce %s stratagem by 1 CP" % state.squads[squad].name, "discount", -1, squad))
			result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == "damage-reroll":
		if pending(state).owners[0] != player: return result
		var sources: Array = pending(state).get("sources", [pending(state).get("source", "Total Obliteration")])
		if sources.size() == 1:
			var source := str(sources[0])
			result.append(choice(source + ": keep this Damage roll", "damage-keep"))
			result.append(choice(source + ": re-roll this Damage roll", "damage-reroll", -1, -1, source))
		else:
			result.append(choice("Keep this Damage roll", "damage-keep"))
			for source_value: Variant in sources:
				var source := str(source_value)
				result.append(choice(source + ": re-roll this Damage roll", "damage-reroll", -1, -1, source))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == "nightforged-attack-count":
		if pending(state).get("owners", []) != [player] or state.get("pending_attack", {}).is_empty(): return result
		var checkpoint: Dictionary = state.pending_attack.get("current", {}).get("checkpoint", {})
		if checkpoint.get("phase", "") != "generation" or not checkpoint.get("context", {}).get("nightforged_attack_count", false): return result
		result.append(choice("Nightforged Battery: keep the current Attack characteristic", "nightforged-attack-count-pass"))
		for index: int in RollWindows.eligible(checkpoint): result.append(choice("Nightforged Battery: re-roll A die %d (%d)" % [index + 1, checkpoint.generated.rolls[index]], "nightforged-attack-count-reroll", -1, index))
		return result
	if pending(state).get("kind", "") == "nightforged-hazard":
		if pending(state).get("owners", []) != [player]: return result
		var hazard_pending: Dictionary = state.get("pending_hazard", {})
		if hazard_pending.is_empty() or not StormlanceEnhancements.active(state, int(hazard_pending.get("squad", -1)), StormlanceEnhancements.NIGHTFORGED_BATTERY): return result
		var hazard: Dictionary = hazard_pending.get("resolved", {}).get("hazardous", {})
		result.append(choice("Nightforged Battery: keep the Hazard rolls and continue", "nightforged-hazard-pass"))
		for index: int in pending(state).get("eligible", []):
			if index >= 0 and index < hazard.get("rolls", []).size(): result.append(choice("Nightforged Battery: re-roll Hazard die %d (%d)" % [index + 1, hazard.rolls[index]], "nightforged-hazard-reroll", -1, index))
		return result
	if pending(state).get("kind", "") == "aquilon-hit":
		if pending(state).owners[0] != player: return result
		result.append(choice("Aquilon Optics: continue without a hit re-roll", "hit-finish"))
		var checkpoint: Dictionary = state.pending_attack.current.checkpoint
		for index: int in RollWindows.eligible(checkpoint): result.append(choice("Aquilon Optics: re-roll hit die %d (%d)" % [index + 1, checkpoint.hit_rolls[index]], "hit-reroll", -1, index))
		return result
	if pending(state).get("kind", "") in ["machine-spirit-hit", "machine-spirit-wound"]:
		if pending(state).owners[0] != player: return result
		var machine_checkpoint: Dictionary = state.pending_attack.current.checkpoint
		var hit_window: bool = pending(state).kind == "machine-spirit-hit"
		var dice: Array = machine_checkpoint.hit_rolls if hit_window else machine_checkpoint.effective_wounds
		var die_kind := "hit" if hit_window else "wound"
		var source := str(pending(state).get("source", "Power of the Machine Spirit"))
		result.append(choice("%s: continue without a %s re-roll" % [source, die_kind], "machine-spirit-finish"))
		for index: int in RollWindows.eligible(machine_checkpoint): result.append(choice("%s: re-roll %s die %d (%d)" % [source, die_kind, index + 1, dice[index]], "machine-spirit-reroll", -1, index))
		return result
	if pending(state).get("kind", "") in ["armoured-wrath-hit", "armoured-wrath-wound"]:
		if pending(state).get("owners", []) != [player] or state.pending_attack.is_empty() or state.pending_attack.current.get("phase", "") != "rolls": return result
		var wrath_checkpoint: Dictionary = state.pending_attack.current.get("checkpoint", {})
		var hit_window: bool = pending(state).kind == "armoured-wrath-hit"
		var dice: Array = wrath_checkpoint.get("hit_rolls", []) if hit_window else wrath_checkpoint.get("effective_wounds", [])
		var die_kind := "hit" if hit_window else "wound"
		var use_kind := "hit" if hit_window else "wound"
		if wrath_checkpoint.get("phase", "") != use_kind or not DamageAllocation.armoured_wrath_available(state.pending_attack, wrath_checkpoint.get("context", {}), use_kind): return result
		result.append(choice("Armoured Wrath: continue without a re-roll", "armoured-wrath-finish"))
		for index: int in RollWindows.eligible(wrath_checkpoint): result.append(choice("Armoured Wrath: re-roll %s die %d (%d)" % [die_kind, index + 1, dice[index]], "armoured-wrath-reroll", -1, index))
		return result
	if pending(state).get("kind", "") in ["martial-paragon-hit", "martial-paragon-wound"]:
		if pending(state).get("owners", []) != [player] or state.pending_attack.is_empty() or state.pending_attack.current.get("phase", "") != "rolls": return result
		var paragon_checkpoint: Dictionary = state.pending_attack.current.get("checkpoint", {})
		var paragon_window_kind := str(pending(state).get("kind", ""))
		var die_kind := "hit" if paragon_window_kind == "martial-paragon-hit" else "wound"
		if paragon_checkpoint.get("phase", "") != die_kind or not paragon_checkpoint.get("context", {}).get("martial_paragon", false) or bool(state.pending_attack.get("martial_paragon_used", {}).get(die_kind, false)): return result
		var dice: Array = paragon_checkpoint.get("hit_rolls", []) if die_kind == "hit" else paragon_checkpoint.get("effective_wounds", [])
		result.append(choice("Continue without using the %s re-roll yet" % die_kind.capitalize(), "martial-paragon-finish"))
		for index: int in RollWindows.eligible(paragon_checkpoint): result.append(choice("Martial Paragon: re-roll %s die %d (%d)" % [die_kind.capitalize(), index + 1, dice[index]], "martial-paragon-reroll", -1, index))
		return result
	if pending(state).get("kind", "") == "wound":
		if pending(state).owners[0] != player: return result
		var checkpoint: Dictionary = state.pending_attack.current.checkpoint
		result.append(choice("Keep remaining wound rolls and continue", "wound-finish"))
		var source := str(state.pending_attack.current.checkpoint.context.get("free_wound_reroll_source", "Implacable Eradication"))
		if not (checkpoint.context.get("aquilon_optics", false) and state.pending_attack.current.get("aquilon_wound_done", false)):
			var eligible_wounds := RollWindows.eligible(checkpoint)
			if checkpoint.context.get("venator_successful_twos_choice", false): eligible_wounds = RollWindows.eligible_natural_wounds(checkpoint, 2)
			for index: int in eligible_wounds:
				var label := "%s: re-roll successful Wound 2 (die %d), 0 CP" % [source, index + 1] if checkpoint.context.get("venator_successful_twos_choice", false) else "%s: re-roll wound die %d (%d), 0 CP" % [source, index + 1, checkpoint.effective_wounds[index]]
				result.append(choice(label, "wound-reroll", -1, index))
		return result
	if pending(state).get("kind", "") == DeadlyDemise.WINDOW:
		result.append_array(DeadlyDemise.choices(state, player))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW:
		if pending(state).get("owners", []) != [player]: return result
		result.append_array(DetachmentStratagems.vengeful_animus_choices(state, player))
		var squad := int(pending(state).get("squad", -1))
		var squad_name := str(state.squads[squad].get("name", "the destroyed Vehicle")) if state.squads.has(squad) else "the destroyed Vehicle"
		result.append(choice("Roll Deadly Demise for %s without Vengeful Animus" % squad_name, "deadly-demise-vengeful-pass", int(pending(state).get("source_model", -1)), squad))
		return result
	if pending(state).get("kind", "") == DetachmentStratagems.LAYERED_CERAMITE_WINDOW:
		if pending(state).get("owners", []) != [player]: return result
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		result.append(choice("Decline %s" % DetachmentStratagems.mortal_wound_reaction_name(state, player), "mortal-wound-protection-pass", -1, int(pending(state).get("squad", -1))))
		return result
	if pending(state).get("kind", "") in ["evade-and-survive", "evade-placement"]:
		return CombiLieutenant.choices(state, player)
	if pending(state).get("kind", "") in [CatoSicarius.WINDOW, CatoSicarius.PLACEMENT]:
		return CatoSicarius.choices(state, player)
	if pending(state).get("kind", "") in [TacticalFluidity.WINDOW, TacticalFluidity.PLACEMENT]:
		return TacticalFluidity.choices(state, player)
	if pending(state).get("kind", "") in [PurgationRun.WINDOW, PurgationRun.PLACEMENT]:
		return PurgationRun.choices(state, player)
	if pending(state).get("kind", "") in [VictrixHonourGuard.WINDOW, VictrixHonourGuard.PLACEMENT]:
		return VictrixHonourGuard.choices(state, player)
	if pending(state).get("kind", "") == "forward-assault-mark":
		var source_squad: int = int(pending(state).source_squad)
		var source_models := A.sources(state, source_squad, "forward-assault-warsuit")
		if source_models.is_empty() or int(pending(state).owners[0]) != player: return result
		for target: int in A.forward_assault_targets(state, int(state.squads[source_squad].owner)):
			result.append(choice("Invictor %d: replace destroyed mark with %s" % [source_models[0], state.squads[target].name], "invictor-mark", source_models[0], target, "replacement"))
		return result
	if not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty():
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == CoreReactions.EXPLOSIVES:
		result.append_array(CoreReactions.explosives_allocations(state, player))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == CoreReactions.CRUSHING_MORTAL:
		result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.CRUSHING_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == Hammer.MORTAL_WINDOW:
		result.append_array(CoreReactions.mortal_allocations(state, player, Hammer.MORTAL_WINDOW))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == CoreReactions.GRAVIS_ARMOURED_IMPACT_MORTAL:
		result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.GRAVIS_ARMOURED_IMPACT_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == CoreReactions.WRATH_OF_THE_LION_MORTAL:
		result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.WRATH_OF_THE_LION_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == DetachmentStratagems.PHOBOS_SHADOW_MORTIS_MORTAL_WINDOW:
		result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.PHOBOS_MORTIS_SNARES_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if pending(state).get("kind", "") == Hammer.ID:
		return Hammer.choices(state, player)
	if state.phase == "deployment":
		for model: int in state.units:
			var vulkan: Dictionary = state.units[model]
			if vulkan.owner != player or A.identity(vulkan) != "vulkan-hestan" or not vulkan.get("on_battlefield", true) or not state.deployment.get("placed", {}).get(model, false) or state.unit_abilities.get("seeker_objectives", {}).has(model): continue
			if not _vulkan_placement_complete(state, int(vulkan.squad)): continue
			for index in range(state.get("mission", {}).get("objectives", []).size()):
				var objective: Dictionary = state.mission.objectives[index]
				result.append(choice("Vulkan He’stan: Seeker of the Unfound — select %s" % objective.name, "seeker-objective", model, index))
			if not result.is_empty(): return result
	if state.phase == "movement" and state.active == player:
		result.append_array(TransportRules.disembark_choices(state, player))
		for squad: int in state.squads:
			var passenger_models := G.alive(state, squad)
			if int(state.squads[squad].owner) != player or passenger_models.is_empty(): continue
			for transport_model: int in state.units:
				if int(state.units[transport_model].owner) != player or not TransportRules.is_transport(state, transport_model): continue
				if TransportRules.embark_error(state, player, transport_model, squad).is_empty():
					result.append(choice("Embark %s in %s" % [state.squads[squad].name, state.squads[state.units[transport_model].squad].name], "transport-embark", passenger_models[0], transport_model))
	if state.phase == "shooting" and state.active == player:
		result.append_array(auspex_triangulation_choices(state, player))
		if Actions.has_mission_action(state, player, Actions.SECURE_ASSET):
			var home_role := "attacker" if player == state.get("mission", {}).get("attacker", 0) else "defender"
			for squad: int in state.squads:
				if int(state.squads[squad].owner) != player or G.alive(state, squad).is_empty(): continue
				for objective_index in Actions.targets(state, squad):
					if state.mission.objectives[objective_index].get("role", "") == home_role: continue
					if not Actions.start_error(state, squad, objective_index).is_empty(): continue
					result.append(choice("Secure Asset: %s secures %s" % [state.squads[squad].name, state.mission.objectives[objective_index].name], "mission-secure-asset", G.alive(state, squad)[0], objective_index))
		for model: int in state.units:
			var vulkan: Dictionary = state.units[model]
			if vulkan.owner != player or vulkan.wounds <= 0 or not vulkan.get("on_battlefield", true) or A.identity(vulkan) != "vulkan-hestan": continue
			if state.unit_abilities.get("used", {}).has("forgefather:%d:%d" % [player, state.turn]): continue
			for enemy: int in state.squads:
				if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
				var sight := T.targeting(state, model, enemy)
				if sight.visible and sight.distance <= 24.001:
					result.append(choice("Vulkan He’stan: Forgefather — mark %s" % state.squads[enemy].name, "forgefather-target", model, enemy))
	var setup := setup_actor(state)
	if setup > 0:
		if player != setup: return result
		result.append(choice("Finish army preparations / optional declarations", "setup-done"))
		result.append_array(TransportRules.start_embark_choices(state, player))
		result.append_array(TransportRules.impulsor_loadout_choices(state, player))
		result.append_array(TransportRules.transport_weapon_loadout_choices(state, player))
		for model: int in models(state, player, "cerebrex-logic-engine"):
			if state.unit_abilities.get("used", {}).has("cerebrex:%d" % model): continue
			for target_squad: int in state.squads:
				if state.squads[target_squad].owner != player or not cerebrex_target_eligible(state, target_squad): continue
				result.append(choice("Cerebrex Logic Engine %d: grant Scouts 6 to %s" % [model, state.squads[target_squad].name], "cerebrex-scout", model, target_squad))
		for model: int in models(state, player, "thunderhawk-insertion"):
			if state.unit_abilities.get("thunderhawk_targets", {}).has(player): continue
			for target_squad: int in state.squads:
				if state.squads[target_squad].owner != player or not thunderhawk_target_eligible(state, target_squad): continue
				result.append(choice("Thunderhawk Insertion %d: grant Deep Strike to %s" % [model, state.squads[target_squad].name], "thunderhawk-insertion", model, target_squad))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "close-quarters-firestorm"): continue
			var boltstorm: bool = state.squads[squad].get("boltstorm_loadout", false)
			result.append(choice("Aggressors %d: all %s" % [squad, "Flamestorm" if boltstorm else "Boltstorm/Fragstorm"], "aggressor-loadout", -1, squad, "flame" if boltstorm else "bolt"))
		for model: int in state.units:
			var inceptor: Dictionary = state.units[model]
			if inceptor.owner != player or inceptor.wounds <= 0 or A.identity(inceptor) != "inceptor-squad": continue
			var plasma: bool = inceptor.get("inceptor_plasma_exterminators", false)
			result.append(choice("Inceptor %d: %s" % [model, "Assault Bolters" if plasma else "Plasma Exterminators"], "inceptor-loadout", model, inceptor.squad, "bolters" if plasma else "plasma"))
		for model: int in state.units:
			var speeder: Dictionary = state.units[model]
			if speeder.owner != player or speeder.wounds <= 0 or A.identity(speeder) != "land-speeder": continue
			var pyrecannon: bool = speeder.get("land_speeder_pyrecannon", false)
			result.append(choice("Land Speeder %d: %s" % [model, "Onslaught Gatling Cannon" if pyrecannon else "Pyrecannon"], "land-speeder-cannon", model, speeder.squad, "onslaught" if pyrecannon else "pyrecannon"))
		for model: int in state.units:
			var vengeance: Dictionary = state.units[model]
			if vengeance.owner != player or vengeance.wounds <= 0 or A.identity(vengeance) != "land-speeder-vengeance": continue
			var assault_cannon: bool = vengeance.get("land_speeder_vengeance_assault_cannon", false)
			result.append(choice("Land Speeder Vengeance %d: %s" % [model, "Heavy Bolter" if assault_cannon else "Assault Cannon"], "land-speeder-vengeance-cannon", model, vengeance.squad, "heavy-bolter" if assault_cannon else "assault-cannon"))
		for model: int in state.units:
			var intercessor: Dictionary = state.units[model]
			if intercessor.owner != player or intercessor.wounds <= 0 or A.identity(intercessor) != "intercessor-squad": continue
			if intercessor.get("sergeant", false):
				var melee_choice: String = intercessor.get("intercessor_melee_choice", "knives-and-fists")
				for kind: String in ["knives-and-fists", "chainsword", "power-fist", "power-weapon", "thunder-hammer"]:
					if kind != melee_choice: result.append(choice("Intercessor Sergeant %d: %s" % [model, {"knives-and-fists": "Knives and Fists", "chainsword": "Chainsword (melee replacement)", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}[kind]], "intercessor-melee", model, intercessor.squad, kind))
				var rifle_choice: String = intercessor.get("intercessor_rifle_choice", "bolt-rifle")
				for kind: String in ["bolt-rifle", "chainsword", "hand-flamer", "plasma-pistol", "power-weapon"]:
					if kind != rifle_choice: result.append(choice("Intercessor Sergeant: replace Bolt Rifle with %s" % {"bolt-rifle": "Bolt Rifle", "chainsword": "Chainsword", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol", "power-weapon": "Power Weapon"}[kind], "intercessor-rifle", model, intercessor.squad, kind))
			if not intercessor.get("sergeant", false):
				var equipped: bool = intercessor.get("intercessor_grenade_launcher", false)
				var equipped_count := 0
				for member: int in G.alive(state, intercessor.squad):
					if A.identity(state.units[member]) == "intercessor-squad" and state.units[member].get("intercessor_grenade_launcher", false): equipped_count += 1
				var launcher_limit := int(state.squads[intercessor.squad].starting_strength / 5.0)
				if equipped or equipped_count < launcher_limit:
					result.append(choice("Intercessor %d: %s Grenade Launcher" % [model, "remove" if equipped else "equip"], "intercessor-grenade-launcher", model, intercessor.squad, "off" if equipped else "on"))
		for model: int in state.units:
			var heavy_intercessor: Dictionary = state.units[model]
			if heavy_intercessor.owner != player or heavy_intercessor.wounds <= 0 or A.identity(heavy_intercessor) != "heavy-intercessor-squad" or heavy_intercessor.get("sergeant", false): continue
			var equipped: bool = heavy_intercessor.get("heavy_intercessor_heavy_bolter", false)
			var equipped_count := 0
			for member: int in G.alive(state, heavy_intercessor.squad):
				if A.identity(state.units[member]) == "heavy-intercessor-squad" and state.units[member].get("heavy_intercessor_heavy_bolter", false): equipped_count += 1
			var heavy_bolter_limit := int(state.squads[heavy_intercessor.squad].starting_strength / 5.0)
			if equipped or equipped_count < heavy_bolter_limit:
				result.append(choice("Heavy Intercessor %d: %s Heavy Bolter" % [model, "restore Heavy Bolt Rifle" if equipped else "replace Heavy Bolt Rifle"], "heavy-intercessor-bolter", model, heavy_intercessor.squad, "off" if equipped else "on"))
		for model: int in state.units:
			var terminator: Dictionary = state.units[model]
			if terminator.owner != player or terminator.wounds <= 0 or A.identity(terminator) != "terminator-squad": continue
			var melee_choice: String = terminator.get("terminator_melee_choice", "power-fist")
			var melee_options: Array = ["power-fist", "chainfist", "power-weapon"] if terminator.get("sergeant", false) else ["power-fist", "chainfist"]
			for kind: String in melee_options:
				if kind != melee_choice: result.append(choice("Terminator %d: %s" % [model, {"power-fist": "Power Fist", "chainfist": "Chainfist", "power-weapon": "Power Weapon"}[kind]], "terminator-melee", model, terminator.squad, kind))
			if terminator.get("sergeant", false): continue
			var equipped: String = terminator.get("terminator_special_weapon", "")
			var special_limit := int(state.squads[terminator.squad].starting_strength / 5.0)
			if equipped.is_empty() and _terminator_special_count(state, terminator.squad) >= special_limit: continue
			for kind: String in ["none", "assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]:
				if kind == "none" and equipped.is_empty(): continue
				if kind != "none" and kind == equipped: continue
				result.append(choice("Terminator %d: %s" % [model, {"none": "Storm Bolter", "assault-cannon": "Assault Cannon", "heavy-flamer": "Heavy Flamer", "cyclone-missile-launcher": "Cyclone Missile Launcher + Storm Bolter"}[kind]], "terminator-special-weapon", model, terminator.squad, kind))
		for model: int in state.units:
			var assault_terminator: Dictionary = state.units[model]
			if assault_terminator.owner != player or assault_terminator.wounds <= 0 or A.identity(assault_terminator) != "terminator-assault-squad": continue
			var shielded: bool = assault_terminator.get("terminator_assault_storm_shield", false)
			result.append(choice("Terminator Assault %d: %s" % [model, "Storm Shield + Thunder Hammer" if not shielded else "Twin Lightning Claws"], "terminator-assault-loadout", model, assault_terminator.squad, "off" if shielded else "on"))
		for model: int in state.units:
			var outrider: Dictionary = state.units[model]
			if outrider.owner != player or outrider.wounds <= 0 or A.identity(outrider) != "outrider-squad": continue
			if outrider.get("sergeant", false):
				var outrider_melee: String = outrider.get("outrider_melee_choice", "chainsword")
				for kind: String in ["chainsword", "power-weapon", "thunder-hammer"]:
					if kind != outrider_melee: result.append(choice("Outrider Sergeant %d: %s" % [model, {"chainsword": "Chainsword", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}[kind]], "outrider-melee", model, outrider.squad, kind))
			var plasma_equipped: bool = outrider.get("outrider_plasma_pistol", false)
			var plasma_count := 0
			for member: int in state.units:
				if state.units[member].squad == outrider.squad and A.identity(state.units[member]) == "outrider-squad" and state.units[member].get("outrider_plasma_pistol", false): plasma_count += 1
			var plasma_limit := int(state.squads[outrider.squad].starting_strength / 3.0)
			if plasma_equipped or plasma_count < plasma_limit:
				result.append(choice("Outrider %d: %s Plasma Pistol" % [model, "restore Heavy Bolt Pistol" if plasma_equipped else "replace Heavy Bolt Pistol with"], "outrider-plasma-pistol", model, outrider.squad, "off" if plasma_equipped else "on"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "chameleoline-cloaks"): continue
			var fusils: bool = state.squads[squad].get("eliminator_fusils", false)
			result.append(choice("Eliminators %d: both troopers use %s" % [squad, "Bolt Sniper Rifles" if fusils else "Las Fusils"], "eliminator-troopers", -1, squad, "sniper" if fusils else "las"))
			for model: int in G.alive(state, squad):
				if not state.units[model].get("sergeant", false): continue
				for kind: String in ["sniper", "las", "carbine"]:
					result.append(choice("Eliminator Sergeant %d: %s" % [model, {"sniper": "Bolt Sniper Rifle", "las": "Las Fusil", "carbine": "Instigator Bolt Carbine"}[kind]], "eliminator-sergeant", model, squad, kind))
		for model: int in state.units:
			var veteran: Dictionary = state.units[model]
			if veteran.owner != player or veteran.wounds <= 0 or A.identity(veteran) != "sternguard-veteran-squad": continue
			if veteran.get("sergeant", false):
				for kind: String in ["chain", "fist", "power"]:
					result.append(choice("Sternguard Sergeant %d: %s" % [model, {"chain": "Chainsword", "fist": "Power Fist", "power": "Power Weapon"}[kind]], "sternguard-melee", model, veteran.squad, kind))
			else:
				var models_in_sheet := 0
				var replaced := 0
				for id: int in G.alive(state, veteran.squad):
					if A.identity(state.units[id]) != "sternguard-veteran-squad": continue
					models_in_sheet += 1
					if state.units[id].get("sternguard_special", false): replaced += 1
				if veteran.get("sternguard_special", false) or replaced < int(models_in_sheet / 5.0):
					for kind: String in ["firearm", "heavy", "pyre"]:
						result.append(choice("Sternguard %d: %s" % [model, {"firearm": "Artificer Firearm", "heavy": "Heavy Bolter", "pyre": "Pyrecannon"}[kind]], "sternguard-gun", model, veteran.squad, kind))
		for model: int in state.units:
			if state.units[model].owner == player and A.identity(state.units[model]) == "ancient":
				result.append(choice("Ancient %d: %s" % [model, "Bolt Rifle" if state.units[model].get("ancient_power", false) else "Power Weapon"], "ancient-loadout", model, state.units[model].squad, "rifle" if state.units[model].get("ancient_power", false) else "power"))
		for model: int in state.units:
			var veteran: Dictionary = state.units[model]
			if veteran.owner == player and veteran.wounds > 0 and veteran.get("sergeant", false) and A.identity(veteran) == "bladeguard-veteran-squad":
				for kind: String in ["heavy", "volkite", "plasma"]:
					result.append(choice("Bladeguard Sergeant %d: %s" % [model, {"heavy": "Heavy Bolt Pistol", "volkite": "Neo-volkite Pistol", "plasma": "Plasma Pistol"}[kind]], "bladeguard-pistol", model, veteran.squad, kind))
		for model: int in state.units:
			var scout: Dictionary = state.units[model]
			if scout.owner != player or scout.wounds <= 0 or A.identity(scout) != "scout-squad": continue
			for gun: String in _scout_gun_options(state, model):
				result.append(choice("Scout %d: %s" % [model, {"boltgun": "Boltgun", "shotgun": "Shotgun", "sniper-rifle": "Sniper Rifle", "heavy-bolter": "Heavy Bolter", "missile-launcher": "Missile Launcher"}[gun]], "scout-gun", model, scout.squad, gun))
			if scout.get("sergeant", false):
				for blade: String in ["combat-knife", "chainsword"]:
					if blade != scout.get("scout_blade", "combat-knife"): result.append(choice("Scout Sergeant %d: %s" % [model, "Combat Knife" if blade == "combat-knife" else "Chainsword"], "scout-blade", model, scout.squad, blade))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or G.alive(state, squad).is_empty(): continue
			var reiver := false
			for model: int in G.alive(state, squad):
				if A.identity(state.units[model]) == "reiver-squad": reiver = true
			if not reiver: continue
			var grav: bool = state.squads[squad].get("reiver_grav_chutes", false)
			var grapnel: bool = state.squads[squad].get("reiver_grapnel_launchers", false)
			result.append(choice("Reiver Squad %d: %s Grav-chutes" % [squad, "remove" if grav else "equip"], "reiver-grav-chutes", -1, squad, "off" if grav else "on"))
			result.append(choice("Reiver Squad %d: %s Grapnel Launchers" % [squad, "remove" if grapnel else "equip"], "reiver-grapnel-launchers", -1, squad, "off" if grapnel else "on"))
		for model: int in state.units:
			if state.units[model].owner != player or state.units[model].wounds <= 0 or A.identity(state.units[model]) != "firestrike-servo-turrets": continue
			var autocannon: bool = state.units[model].get("firestrike_autocannon", false)
			result.append(choice("Firestrike Servo-turret %d: %s" % [model, "Twin Firestrike Las-talon" if autocannon else "Twin Firestrike Autocannon"], "firestrike-gun", model, state.units[model].squad, "las-talon" if autocannon else "autocannon"))
		for model: int in state.units:
			var dreadnought: Dictionary = state.units[model]
			if dreadnought.owner != player or dreadnought.wounds <= 0 or A.identity(dreadnought) != "redemptor-dreadnought": continue
			result.append(choice("Redemptor %d: %s" % [model, "Storm Bolters" if dreadnought.get("redemptor_fragstorm", true) else "Fragstorm Grenade Launchers"], "redemptor-fragstorm", model, dreadnought.squad, "fragstorm" if not dreadnought.get("redemptor_fragstorm", true) else "storm-bolters"))
			result.append(choice("Redemptor %d: %s" % [model, "Onslaught Gatling Cannon" if dreadnought.get("redemptor_heavy_flamer", true) else "Heavy Flamer"], "redemptor-auxiliary", model, dreadnought.squad, "heavy-flamer" if not dreadnought.get("redemptor_heavy_flamer", true) else "onslaught"))
			result.append(choice("Redemptor %d: %s" % [model, "Macro Plasma Incinerator (+10 points)" if not dreadnought.get("redemptor_macro_plasma", false) else "Heavy Onslaught Gatling Cannon"], "redemptor-main", model, dreadnought.squad, "macro-plasma" if not dreadnought.get("redemptor_macro_plasma", false) else "heavy-onslaught"))
			result.append(choice("Redemptor %d: %s" % [model, "Icarus Rocket Pod" if not dreadnought.get("redemptor_icarus", false) else "remove Icarus Rocket Pod"], "redemptor-icarus", model, dreadnought.squad, "on" if not dreadnought.get("redemptor_icarus", false) else "off"))
		for model: int in state.units:
			var brutalis: Dictionary = state.units[model]
			if brutalis.owner != player or brutalis.wounds <= 0 or A.identity(brutalis) != "brutalis-dreadnought": continue
			result.append(choice("Brutalis %d: %s" % [model, "Brutalis Fists + Bolt Rifles" if brutalis.get("brutalis_talons", false) else "Brutalis Talons"], "brutalis-melee", model, brutalis.squad, "fists" if brutalis.get("brutalis_talons", false) else "talons"))
			result.append(choice("Brutalis %d: %s" % [model, "Twin Heavy Bolter" if brutalis.get("brutalis_multi_melta", false) else "Twin Multi-melta"], "brutalis-ranged", model, brutalis.squad, "heavy-bolter" if brutalis.get("brutalis_multi_melta", false) else "multi-melta"))
		for model: int in state.units:
			var invictor: Dictionary = state.units[model]
			if invictor.owner != player or invictor.wounds <= 0 or A.identity(invictor) != "invictor-tactical-warsuit": continue
			result.append(choice("Invictor %d: %s" % [model, "Incendium Cannon" if invictor.get("invictor_autocannon", false) else "Twin Ironhail Autocannon"], "invictor-gun", model, invictor.squad, "incendium" if invictor.get("invictor_autocannon", false) else "autocannon"))
		for model: int in state.units:
			var desolation: Dictionary = state.units[model]
			if desolation.owner != player or desolation.wounds <= 0 or A.identity(desolation) != "desolation-squad": continue
			var rocket: String = desolation.get("desolation_rocket", "superfrag")
			for option: String in (["superfrag", "superkrak", "vengor"] if desolation.get("sergeant", false) else ["superfrag", "superkrak"]):
				if option != rocket: result.append(choice("Desolation %d: %s" % [model, {"superfrag": "Superfrag Rocket Launcher", "superkrak": "Superkrak Rocket Launcher", "vengor": "Vengor Launcher (+5 points)"}[option]], "desolation-rocket", model, desolation.squad, option))
		for model: int in state.units:
			var bearer: Dictionary = state.units[model]
			if bearer.owner != player or bearer.wounds <= 0 or A.identity(bearer) != "eradicator-squad-with-melta-rifles": continue
			var multi: bool = bearer.get("multi_melta", false)
			var equipped := 0
			var eradicators := 0
			for other: int in G.alive(state, bearer.squad):
				if A.identity(state.units[other]) == "eradicator-squad-with-melta-rifles": eradicators += 1
				if state.units[other].get("multi_melta", false): equipped += 1
			if multi or equipped < int(eradicators / 3.0): result.append(choice("Eradicator %d: %s" % [model, "Melta Rifle" if multi else "Multi-melta"], "eradicator-melta", model, bearer.squad, "rifle" if multi else "multi"))
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner == player and unit.get("sergeant", false) and A.identity(unit) == "hellblaster-squad":
				var plasma: bool = unit.get("plasma_pistol", false)
				result.append(choice("Sergeant %d: equip %s (free)" % [model, "Bolt Pistol" if plasma else "Plasma Pistol"], "hellblaster-pistol", model, unit.squad, "bolt" if plasma else "plasma"))
			if unit.owner == player and unit.get("sergeant", false) and A.identity(unit) == "assault-intercessors-with-jump-packs":
				for kind: String in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]:
					result.append(choice("Jump Intercessor Sergeant %d: %s" % [model, {"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}[kind]], "jump-pack-sergeant-pistol", model, unit.squad, kind))
				for kind: String in ["chainsword", "power-fist", "power-weapon"]:
					result.append(choice("Jump Intercessor Sergeant %d: %s" % [model, {"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon"}[kind]], "jump-pack-sergeant-melee", model, unit.squad, kind))
			if unit.owner == player and not unit.get("sergeant", false) and A.identity(unit) == "assault-intercessors-with-jump-packs":
				var plasma_bearers := 0
				for member: int in G.alive(state, unit.squad):
					if A.identity(state.units[member]) == "assault-intercessors-with-jump-packs" and state.units[member].get("jump_plasma_pistol", false): plasma_bearers += 1
				if unit.get("jump_plasma_pistol", false):
					result.append(choice("Jump Intercessor %d: restore Heavy Bolt Pistol" % model, "jump-pack-trooper-pistol", model, unit.squad, "heavy-bolt-pistol"))
				elif plasma_bearers < int(G.alive(state, unit.squad).size() / 5.0):
					result.append(choice("Jump Intercessor %d: replace with Plasma Pistol" % model, "jump-pack-trooper-pistol", model, unit.squad, "plasma-pistol"))
		var required_warlord := guilliman_model(state, player)
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner != player: continue
			if A.identity(unit) == "captain-with-jump-pack":
				var jump_loadouts := {"default": "Heavy Bolt Pistol + Chainsword", "hand-flamer": "Hand Flamer + Chainsword", "plasma-pistol": "Plasma Pistol + Chainsword", "power-fist": "Heavy Bolt Pistol + Power Fist", "relic-weapon": "Heavy Bolt Pistol + Relic Weapon", "thunder-hammer-shield": "Thunder Hammer + Relic Shield", "chainsword-shield": "Chainsword + Relic Shield"}
				for loadout: String in jump_loadouts:
					if loadout != unit.get("jump_captain_loadout", "default"):
						result.append(choice("Jump Captain %d: %s" % [model, jump_loadouts[loadout]], "jump-pack-captain-loadout", model, unit.squad, loadout))
			if A.identity(unit) == "captain-on-bike":
				result.append(choice("Bike Captain %d: %s" % [model, "Heavy Bolt Pistol" if unit.get("captain_bike_plasma_pistol", false) else "Plasma Pistol"], "captain-bike-pistol", model, unit.squad, "bolt" if unit.get("captain_bike_plasma_pistol", false) else "plasma"))
				result.append(choice("Bike Captain %d: %s" % [model, "Master-crafted Power Weapon" if unit.get("captain_bike_thunder_hammer", false) else "Thunder Hammer"], "captain-bike-melee", model, unit.squad, "power-weapon" if unit.get("captain_bike_thunder_hammer", false) else "thunder-hammer"))
			if A.identity(unit) == "vanguard-veteran-squad-with-jump-packs":
				var current_pistol: String = unit.get("vanguard_pistol", "heavy-bolt-pistol")
				for kind: String in ["heavy-bolt-pistol", "plasma-pistol", "combat-shield"]:
					if kind == current_pistol: continue
					if kind == "plasma-pistol" and not unit.get("sergeant", false) and _vanguard_plasma_count(state, unit.squad, model) >= int(state.squads[unit.squad].starting_strength / 5.0) * 2: continue
					result.append(choice("Vanguard Veteran %d: %s" % [model, {"heavy-bolt-pistol": "Heavy Bolt Pistol", "plasma-pistol": "Plasma Pistol", "combat-shield": "Combat Shield (5+ invulnerable save)"}[kind]], "vanguard-veteran-pistol", model, unit.squad, kind))
			if A.identity(unit) == "vanguard-veteran-squad-with-jump-packs" and unit.get("sergeant", false):
				for kind: String in ["relic-blade", "power-fist", "thunder-hammer"]:
					if kind != unit.get("vanguard_melee", "default"):
						result.append(choice("Vanguard Veteran Sergeant %d: %s" % [model, {"relic-blade": "Relic Blade", "power-fist": "Power Fist", "thunder-hammer": "Thunder Hammer"}[kind]], "vanguard-veteran-melee", model, unit.squad, kind))
			if A.identity(unit) == "lieutenant-in-phobos-armour": result.append(choice("Phobos Lieutenant %d: %s" % [model, "Precision pistol" if unit.get("phobos_carbine", false) else "Bolt carbine"], "phobos-lieutenant-gun", model, unit.squad, "pistol" if unit.get("phobos_carbine", false) else "carbine"))
			if A.identity(unit) == "infiltrator-squad": result.append(choice("Infiltrator %d: %s Helix" % [model, "remove" if unit.get("helix_gauntlet", false) else "carry"], "helix-bearer", model, unit.squad, "off" if unit.get("helix_gauntlet", false) else "on"))
			if A.identity(unit) == "captain-in-gravis-armour":
				for loadout: String in ["rifle", "blade", "chainsword", "fist"]:
					if loadout != unit.get("gravis_loadout", "rifle"): result.append(choice("Gravis Captain %d: %s" % [model, {"rifle": "Rifle + power weapon", "blade": "Gauntlet + relic blade", "chainsword": "Gauntlet + chainsword", "fist": "Gauntlet + relic fist"}[loadout]], "gravis-captain-loadout", model, unit.squad, loadout))
			if A.identity(unit) == "captain-in-terminator-armour":
				result.append(choice("Captain %d: %s" % [model, "Storm Bolter" if unit.get("terminator_combi", false) else "Combi-weapon"], "terminator-captain-gun", model, unit.squad, "bolter" if unit.get("terminator_combi", false) else "combi"))
				result.append(choice("Captain %d: %s" % [model, "Relic Weapon" if unit.get("terminator_fist", false) else "Relic Fist"], "terminator-captain-blade", model, unit.squad, "weapon" if unit.get("terminator_fist", false) else "fist"))
			if A.identity(unit) == "captain":
				var ranged_loadout: String = unit.get("captain_ranged_loadout", "default")
				for loadout: String in ["default", "neo-volkite", "plasma-pistol", "relic-shield"]:
					if loadout != ranged_loadout: result.append(choice("Captain %d: %s" % [model, {"default": "Master-crafted Bolter + Heavy Bolt Pistol", "neo-volkite": "Neo-volkite Pistol", "plasma-pistol": "Plasma Pistol", "relic-shield": "Relic Shield + Heavy Bolt Pistol"}[loadout]], "captain-ranged-loadout", model, unit.squad, loadout))
				var fist: bool = unit.get("captain_power_fist", false)
				result.append(choice("Captain %d: %s" % [model, "Master-crafted Power Weapon" if fist else "Power Fist"], "captain-melee-loadout", model, unit.squad, "power-weapon" if fist else "power-fist"))
			if A.identity(unit) == "lieutenant":
				var current_package: String = unit.get("lieutenant_weapon_package", "default")
				var package_labels := {"default": "Bolt Pistol + Master-crafted Bolter", "heavy-bolt-pistol": "Heavy Bolt Pistol + Master-crafted Bolter", "power-weapon": "Bolt Pistol + Master-crafted Power Weapon", "heavy-pistol-power-weapon": "Heavy Bolt Pistol + Master-crafted Power Weapon", "plasma-pistol": "Bolt Pistol + Plasma Pistol", "heavy-pistol-plasma-pistol": "Heavy Bolt Pistol + Plasma Pistol", "power-fist": "Bolt Pistol + Power Fist", "heavy-pistol-power-fist": "Heavy Bolt Pistol + Power Fist", "neo-volkite": "Neo-volkite Pistol + Master-crafted Power Weapon"}
				for package: String in MarineProfiles.profile("lieutenant").options.ranged_packages:
					if package != current_package: result.append(choice("Lieutenant %d: %s" % [model, package_labels[package]], "lieutenant-ranged-loadout", model, unit.squad, package))
				var current_fists: String = unit.get("lieutenant_fists_replacement", "ceramite-fists")
				for replacement: String in MarineProfiles.profile("lieutenant").options.fists_replacements:
					if replacement != current_fists: result.append(choice("Lieutenant %d: %s" % [model, {"ceramite-fists": "Ceramite Fists", "power-weapon": "Master-crafted Power Weapon (fists replacement)", "power-fist": "Power Fist (fists replacement)"}[replacement]], "lieutenant-melee-loadout", model, unit.squad, replacement))
				if current_package == "neo-volkite":
					var shield: bool = unit.get("lieutenant_storm_shield", false)
					result.append(choice("Lieutenant %d: %s" % [model, "unequip Storm Shield" if shield else "equip Storm Shield (4+ invulnerable save)"], "lieutenant-storm-shield", model, unit.squad, "off" if shield else "on"))
			if A.identity(unit) == "invader-atvs":
				var multi_melta: bool = unit.get("invader_atv_multi_melta", false)
				result.append(choice("Invader ATV %d: %s" % [model, "Onslaught Gatling Cannon" if multi_melta else "Multi-melta (+5 points)"], "invader-atv-gun", model, unit.squad, "onslaught" if multi_melta else "multi-melta"))
			if A.identity(unit) == "chaplain-in-terminator-armour":
				var shield: bool = unit.get("relic_shield", false)
				result.append(choice("Chaplain %d: equip %s" % [model, "Storm Bolter" if shield else "Relic Shield (+1 W)"], "terminator-chaplain-shield", model, unit.squad, "bolter" if shield else "shield"))
			var source := A.identity(unit)
			if source in ["lieutenant-in-phobos-armour", "librarian", "librarian-in-phobos-armour", "chief-librarian-tigurius", "kayvaan-shrike", "cato-sicarius", "aethon-shaan", "captain-in-phobos-armour", "captain-in-gravis-armour", "tor-garadon", "darnath-lysander", "iron-father-feirros", "caanok-var", "ancient-in-terminator-armour", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "librarian-in-terminator-armour", "apothecary", "ancient", "bladeguard-ancient", "judiciar", "captain", "chaplain", "chaplain-on-bike", "captain-on-bike", "suboden-khan", "chaplain-with-jump-pack", "lieutenant", "apothecary-biologis", "captain-with-jump-pack", "adrax-agatone", "kaius-konorius", "vulkan-hestan", "overlord", "royal-warden", "roboute-guilliman", "marneus-calgar"] and (source != "cato-sicarius" or not LeaderCatalog.army_has_calgar(state, player)) and (required_warlord == -1 or model == required_warlord): result.append(choice("Warlord: model %d" % model, "warlord", model))
			if source in ["chief-librarian-tigurius", "kayvaan-shrike", "cato-sicarius", "librarian", "lieutenant-in-phobos-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "captain-in-gravis-armour", "tor-garadon", "darnath-lysander", "iron-father-feirros", "caanok-var", "ancient-in-terminator-armour", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "librarian-in-terminator-armour", "apothecary", "ancient", "bladeguard-ancient", "judiciar", "captain", "chaplain", "chaplain-on-bike", "suboden-khan", "chaplain-with-jump-pack", "lieutenant", "apothecary-biologis", "captain-with-jump-pack", "adrax-agatone", "kaius-konorius", "vulkan-hestan", "royal-warden", "marneus-calgar"] and not unit.has("attachment_role"):
				for target: int in state.squads:
					if attachment_allowed(state, model, target): result.append(choice("Attach %s %d to %s" % [source, model, state.squads[target].name], "attach", model, target))
		for squad: int in state.squads:
			if state.squads[squad].owner != player: continue
			var unassigned_support := false
			for unit: Dictionary in state.units.values():
				if unit.squad == squad and is_support_identity(state, unit) and unit.get("attachment_role", "") != "support": unassigned_support = true
			if unassigned_support: continue
			var reserve_eligible := TransportRules.is_drop_pod(state, squad) or A.every_model_has(state, squad, "deep-strike") or A.scout_distance(state, squad) > 0
			if reserve_eligible:
				if not state.unit_abilities.reserves.has(squad): result.append(choice("Place %s in strategic reserves" % state.squads[squad].name, "reserve", -1, squad))

		return result
	if not DetachmentStratagems.adamantine_pending(state).is_empty(): return DetachmentStratagems.adamantine_decision_choices(state, player)
	if not state.get("fearsome_assault", {}).is_empty(): return Reivers.choices(state, player)
	var battle := battle_actor(state)
	if battle > 0:
		if battle != player: return result
		result.append(choice("Finish start-of-battle declarations", "battle-done"))
		result.append_array(TemplarVows.choices(state, player))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "forward-assault-warsuit") or A.forward_assault_mark(state, squad) >= 0: continue
			var source_models := A.sources(state, squad, "forward-assault-warsuit")
			if source_models.is_empty(): continue
			for target: int in A.forward_assault_targets(state, player):
				result.append(choice("Invictor %d: mark %s" % [source_models[0], state.squads[target].name], "invictor-mark", source_models[0], target, "initial"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.unit_abilities.used.has("homer-set:%d" % squad): continue
			for unit: Dictionary in state.units.values():
				if unit.squad == squad and A.identity(unit) in ["terminator-squad", "terminator-assault-squad"]:
					result.append(choice("Set Teleport Homer for %s at X/Z" % state.squads[squad].name, "homer", -1, squad))
					break
		return result
	var window := pending(state)
	if not window.is_empty():
		if window.owners[0] != player: return result
		if window.kind == DetachmentStratagems.HEADHUNTER_WINDOW:
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append(choice("Decline Headhunter Doctrine", "head-hunter-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW:
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append(choice("Decline Annihilating Force", "gravis-annihilating-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW:
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append(choice("Decline Merciless Veterans", "terminator-merciless-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.PHOBOS_STRIKE_WINDOW:
			result.append_array(DetachmentStratagems.phobos_strike_choices(state, player))
			result.append(choice("Decline Strike from the Shadows", "phobos-strike-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW:
			result.append_array(DetachmentStratagems.methodical_brutality_choices(state, player))
			result.append(choice("Decline Methodical Brutality", "methodical-brutality-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.PIOUS_ENMITY_WINDOW:
			result.append_array(DetachmentStratagems.pious_enmity_choices(state, player))
			result.append(choice("Decline Pious Enmity", "pious-enmity-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW:
			result.append_array(DetachmentStratagems.relentless_assault_choices(state, player))
			result.append(choice("Decline Relentless Assault", "relentless-assault-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW:
			result.append_array(DetachmentStratagems.point_blank_brutality_choices(state, player))
			result.append(choice("Decline Point-Blank Brutality", "point-blank-brutality-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.UNSTOPPABLE_WINDOW:
			var target := int(window.squad)
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.UNSTOPPABLE_ADVANCE).is_empty(): result.append(choice("Unstoppable Advance: %s gains Mobile (1 CP)" % state.squads[target].name, "detachment-stratagem", -1, target, DetachmentStratagems.UNSTOPPABLE_ADVANCE))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.KNIGHTS_OF_IRON).is_empty(): result.append(choice("Knights of Iron: %s gains Mobile (1 CP)" % state.squads[target].name, "detachment-stratagem", -1, target, DetachmentStratagems.KNIGHTS_OF_IRON))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.FLAWLESS_RIDERS).is_empty(): result.append(choice("Flawless Riders: %s gains Mobile (1 CP)" % state.squads[target].name, "detachment-stratagem", -1, target, DetachmentStratagems.FLAWLESS_RIDERS))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.MOBILE_LETHALITY).is_empty(): result.append(choice("Mobile Lethality: %s gains ranged Assault and can shoot after Falling Back (1 CP)" % state.squads[target].name, "detachment-stratagem", -1, target, DetachmentStratagems.MOBILE_LETHALITY))
			result.append(choice("Decline available movement stratagems for %s" % state.squads[target].name, "pass", -1, target))
			return result
		if window.kind == DetachmentStratagems.ARMOUR_WINDOW:
			var target: int = int(window.squad)
			var attacker_squad: int = int(window.get("attacker_squad", -1))
			var armour_rule := DetachmentStratagems.armour_stratagem(state, player)
			if not armour_rule.is_empty() and DetachmentStratagems.error(state, player, target, armour_rule).is_empty(): result.append(choice("Armour of Contempt: worsen %s's AP by 1 against %s (1 CP)" % [state.squads[attacker_squad].name, state.squads[target].name], "armour-use", -1, target))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.ULTRAMARINES_TACTICAL_FORESIGHT).is_empty():
				var foresight_cost := maxi(0, 1 - A.discount(state, player, target))
				result.append(choice("Tactical Foresight: -1 to Wound when %s's Strength exceeds %s's Toughness (%d CP)" % [state.squads[attacker_squad].name, state.squads[target].name, foresight_cost], "tactical-foresight-use", -1, target))
			result.append(choice("Decline defensive stratagem for %s" % state.squads[target].name, "armour-pass", -1, target))
			return result
		if window.kind == DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW:
			var target: int = int(window.squad)
			var attacker_squad: int = int(window.get("attacker_squad", -1))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE).is_empty():
				result.append(choice("Tactical Dreadnought Fortitude: -1 Damage to %s from %s's attacks (2 CP)" % [state.squads[target].name, state.squads[attacker_squad].name], "detachment-stratagem", -1, target, DetachmentStratagems.TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE))
			result.append(choice("Decline Tactical Dreadnought Fortitude for %s" % state.squads[target].name, "terminator-fortitude-pass", -1, target))
			return result
		if window.kind == DetachmentStratagems.DARKFLIGHT_WINDOW:
			var target: int = int(window.squad)
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.WINGS_OF_SHADOW).is_empty():
				result.append(choice("Wings of Shadow: %s gains Stealth for this Shooting phase (1 CP)" % state.squads[target].name, "detachment-stratagem", -1, target, DetachmentStratagems.WINGS_OF_SHADOW))
			result.append(choice("Decline Wings of Shadow for %s" % state.squads[target].name, "wings-shadow-pass", -1, target))
			return result
		if window.kind == DetachmentStratagems.WORTHY_WINDOW:
			var target: int = int(window.squad)
			var worthy_rule := str(window.get("stratagem", ""))
			var card_name := "Duty Unto Death" if worthy_rule == DetachmentStratagems.INNER_CIRCLE_DUTY_UNTO_DEATH else "Duty in Death" if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH else "A Worthy Death"
			var effect_text := "each destroyed model remains on a 4+ until the unit fights or the phase ends"
			if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH: effect_text = "each destroyed model remains on a 4+ (+1 in Assault Doctrine) until the unit fights or the phase ends"
			elif worthy_rule == DetachmentStratagems.INNER_CIRCLE_DUTY_UNTO_DEATH: effect_text = "each destroyed model remains on a 4+ (+1 if engaged with an enemy within your Vowed objective range) until the unit fights or the phase ends"
			if not worthy_rule.is_empty() and DetachmentStratagems.error(state, player, target, worthy_rule).is_empty(): result.append(choice("%s: %s (1 CP)" % [card_name, effect_text], "detachment-stratagem", -1, target, worthy_rule))
			result.append(choice("Decline %s for %s" % [card_name, state.squads[target].name], "worthy-pass", -1, target))
			return result
		if window.kind in [DetachmentStratagems.SHOOTING_REACTION_WINDOW, "mounted-shooting-reaction", "stormlance-hurtling"]:
			var target: int = int(window.squad)
			if bool(window.get("can_hurtling", false)): result.append(choice("Hurtling Targets: attacks against %s hit at -1 (1 CP)" % state.squads[target].name, "hurtling-use", -1, target))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.EVASIVE_MANOEUVRES).is_empty(): result.append(choice("Evasive Manoeuvres: attacks against %s wound at -1 (1 CP)" % state.squads[target].name, "evasive-use", -1, target))
			var umbral_targets: Array = window.get("umbral_targets", [target])
			for umbral_target: Variant in umbral_targets:
				if umbral_target is int and DetachmentStratagems.error(state, player, int(umbral_target), DetachmentStratagems.PHOBOS_UMBRAL_EVASION).is_empty():
					result.append(choice("Umbral Evasion: ranged attacks against %s hit at -1 (1 CP)" % state.squads[int(umbral_target)].name, "umbral-evasion-use", -1, int(umbral_target)))
			result.append(choice("Decline defensive stratagems for %s" % state.squads[target].name, "mounted-reaction-pass", -1, target))
			return result
		if window.kind == "blessings-of-the-omnissiah": return Techmarine.choices(state, player)
		if window.kind == "healing":
			for row: Dictionary in Healing.choices(state): result.append(choice(row.label, row.action, row.model, window.squad))
			return result
		if window.kind == "healing-order":
			result.append_array(healing_choices(state, player))
			return result
		if window.kind == TransportRules.COMBAT_EMBARKATION_WINDOW: return TransportRules.combat_embarkation_choices(state, player)
		if window.kind == "forward-assault-mark":
			var source_squad: int = int(window.source_squad)
			var source_models := A.sources(state, source_squad, "forward-assault-warsuit")
			if source_models.is_empty(): return result
			for target: int in A.forward_assault_targets(state, int(state.squads[source_squad].owner)):
				result.append(choice("Invictor %d: replace destroyed mark with %s" % [source_models[0], state.squads[target].name], "invictor-mark", source_models[0], target, "replacement"))
			return result
		if window.kind == "bladeguard":
			var squad: int = window.remaining[0]
			for mode: String in ["attack", "defend", "pass"]:
				result.append(choice("Bladeguard %d: %s" % [squad, {"attack": "+1 melee hit", "defend": "enemy hit -1", "pass": "decline this trigger"}[mode]], "bladeguard", -1, squad, mode))
			return result
		if window.kind == "phobos-shrouding": return PhobosLibrarian.choices(state, player)
		if window.kind == Incursors.DIVINATOR_WINDOW: return Incursors.choices(state, player)
		if window.kind == Incursors.MINE_WINDOW:
			result.append_array(CoreReactions.mortal_allocations(state, player, Incursors.MINE_WINDOW))
			result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
			return result
		if window.kind == CoreReactions.TIGURIUS_MORTAL:
			result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.TIGURIUS_MORTAL))
			result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
			return result
		if window.kind in ["scouts", "strategium-command"]: return ScoutMoves.choices(state, player)
		if window.kind in ["driven-from-cover", "hailstrike", "shattered-defences"]:
			var source_ability := "Hailstrike" if window.kind == "hailstrike" else "Shattered Defences" if window.kind == "shattered-defences" else "Driven from Cover"
			var benefit := "+1 AP to friendly Adeptus Astartes ranged attacks this phase" if window.kind == "shattered-defences" else "friendly ranged attacks ignore cover this phase"
			for target: int in window.targets: result.append(choice("%s: mark %s (%s)" % [source_ability, state.squads[target].name, benefit], "cover-mark", -1, target))
			return result
		if window.kind == "tactics":
			var movement_source := "Practical Tactics" if window.get("source", "") == DetachmentStratagems.ULTRAMARIAN_PRACTICAL_TACTICS else "We Are Vengeance" if window.get("source", "") == DetachmentStratagems.WE_ARE_VENGEANCE else "Transhuman Reactions" if window.get("source", "") == DetachmentStratagems.PHOBOS_TRANSHUMAN_REACTIONS else "Hunter's Instincts" if window.get("source", "") == DetachmentStratagems.HUNTERS_INSTINCTS else "Masterful Tactics" if window.get("source", "") == DetachmentStratagems.MASTERFUL_TACTICS else "Responsive Tactics"
			for model: int in G.alive(state, window.squad): result.append(choice("%s: preview model %d" % [movement_source, model], "tactics-place", model, window.squad))
			result.append(choice("Confirm %s move" % movement_source, "tactics-confirm"))
			result.append(choice("Leave %s in place" % state.squads[window.squad].name, "tactics-cancel"))
			return result
		if window.kind == DetachmentStratagems.MOVEMENT_REACTION_WINDOW:
			return DetachmentStratagems.movement_reaction_choices(state, player)
		if window.kind == "eternal":
			result.append(choice("Eternal Revenant: preview returned model %d" % window.model, "eternal-place", window.model, window.squad))
			result.append(choice("Confirm Eternal Revenant set-up", "eternal-confirm", window.model, window.squad))
			return result
		if window.kind == "ingress":
			for model: int in state.units:
				if state.units[model].squad == window.squad: result.append(choice("Ingress model %d: preview at X/Z" % model, "ingress-place", model, window.squad))
			result.append(choice("Confirm ingress positions", "ingress-confirm"))
			result.append(choice("Cancel ingress preview", "ingress-cancel"))
			return result
		if window.kind == CoreReactions.CRUSHING: return CoreReactions.crushing_choices(state, player)
		result.append(choice("Decline remaining %s abilities" % window.kind, "pass"))
		if window.kind == "start":
			result.append_array(CoreReactions.choices(state, player))
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(spiritual_choices(state, player))
			result.append_array(rampart_choices(state, player))
			for model: int in models(state, player, "engrammatic-logic"):
				if state.unit_abilities.used.has("logic:%d" % model): continue
				for target: int in state.squads:
					if state.squads[target].owner == player and state.squads[target].battle_shocked and not G.alive(state, target).is_empty() and str(state.units[G.alive(state, target)[0]].get("definition_id", "")).begins_with("40kdc:11e:necrons:") and G.distance_to_target(state, state.units[model], target) <= 12.001:
						result.append(choice("Engrammatic Logic %d: clear %s Battle-shock" % [model, state.squads[target].name], "logic", model, target))
		if window.kind == "end":
			for squad: int in TacticalFluidity.end_fight_squads(state, player):
				var suboden := squad in TacticalFluidity.suboden_squads(state, player)
				var mode := "Normal Move" if suboden else ("Fall Back" if FightQueue.engaged(state, squad) else "Normal Move")
				var limit := "%d inches" % int(state.units[G.alive(state, squad)[0]].get("movement", 0)) if suboden else "6 inches"
				var source := "Suboden Khan: Wrath of the First Khan" if suboden else "Captain in Phobos Armour: Tactical Fluidity"
				result.append(choice("%s: %s up to %s" % [source, mode, limit], "storm-swift-move" if suboden else "fluidity-end", -1, squad))
			for squad: int in echo_ravenspire_squads(state, player):
				result.append(choice("Kayvaan Shrike: place %s in Strategic Reserves" % state.squads[squad].name, "echo-of-ravenspire", -1, squad))
			for squad: int in parabolic_jetleap_squads(state, player):
				result.append(choice("Parabolic Jetleap: place %s in Strategic Reserves" % state.squads[squad].name, "parabolic-jetleap", -1, squad))
			for model: int in models(state, player, "resurrection-orb"):
				var squad: int = state.units[model].squad
				if R.enabled(state) and R.supported_unit(state, squad) and not state.unit_abilities.used.has("orb:%d" % squad) and state.unit_abilities.used.get("resurrect-turn:%d" % player, -1) != state.turn:
					result.append(choice("Resurrection Orb %d: activate D6 healing" % model, "orb", model))
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(TransportRules.gauntlet_duty_candidates(state, player, true))
			result.append_array(CoreReactions.choices(state, player))
		if state.phase == "movement" and state.active != player and state.has("stratagems"):
			for squad: int in rapid_ingress_squads(state, player):
				if state.cp[player] >= 1: result.append(choice("Rapid Ingress: %s (1 CP)" % state.squads[squad].name, "ingress", -1, squad))
				if state.unit_abilities.homers.has(squad): result.append(choice("Rapid Ingress via Teleport Homer: %s (0 CP)" % state.squads[squad].name, "homer-ingress", -1, squad))
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(CoreReactions.choices(state, player))
		if window.kind == "counter":
			result.append_array(CoreReactions.choices(state, player))
			result.append_array(DetachmentStratagems.transhuman_swiftness_choices(state, player))
		if window.kind == "demi":
			for model: int in models(state, player, "demi-company-commander"):
				var squad: int = state.units[model].squad
				if state.unit_abilities.used.get("demi:%d" % squad, -1) != state.turn: result.append(choice("Demi-company Commander: %s" % state.squads[squad].name, "demi", model, squad, window.doctrine))
		return result
	var optics := A.Detection.selection(state)
	if not optics.is_empty():
		if player == state.active:
			result.append(choice("Cancel Eliminator shooting selection", "optics-cancel"))
			result.append_array(optics_choices(state, player, optics.squad))
		return result
	if DetachmentStratagems.darkflight_vengeance_actor(state) == player and DetachmentStratagems.shooting_reaction_actor(state) != player:
		result.append_array(DetachmentStratagems.darkflight_vengeance_choices(state, player))
		result.append(choice("Decline We Are Vengeance", "darkflight-vengeance-pass"))
		return result
	if DetachmentStratagems.darkflight_skyborne_actor(state) == player:
		result.append_array(DetachmentStratagems.darkflight_skyborne_choices(state, player))
		result.append(choice("Decline Skyborne Surveillance", "darkflight-skyborne-pass"))
		return result
	if player != state.active and state.phase != "fight":
		if state.pending_move.is_empty() and state.pending_contact.is_empty():
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(CoreReactions.choices(state, player))
			var has_vengeful_pass := result.any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "vengeful-pass")
			if state.phase == "shooting" and DetachmentStratagems.vengeful_actor(state) == player and not has_vengeful_pass:
				result.append(choice("Decline Vengeful Stars or Hail of Vengeance", "vengeful-pass"))
			if DetachmentStratagems.undying_actor(state) == player:
				result.append(choice("Decline Undying Legions for this attack", "undying-pass"))
		return result
	if not state.pending_move.is_empty() or not state.pending_contact.is_empty():
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	result.append_array(healing_choices(state, player))
	result.append_array(CombiLieutenant.priority_choices(state, player))
	result.append_array(librarius_choices(state, player))
	result.append_array(DetachmentStratagems.choices(state, player))
	result.append_array(CoreReactions.choices(state, player))
	for model: int in models(state, player, "strategic-acumen"):
		var squad: int = state.units[model].squad
		if state.phase == "command" and state.active == player and state.unit_abilities.used.get("acumen:%d" % squad, -1) != state.turn:
			for doctrine: String in Doctrines.available(state, player): result.append(choice("Strategic Acumen %d: %s" % [model, doctrine], "acumen", model, squad, doctrine))
	for model: int in models(state, player, "master-of-shadows"):
		var source_squad: int = state.units[model].squad
		if state.phase != "command" or state.active != player or not state.units[model].get("on_battlefield", true) or state.unit_abilities.used.get("master-shadows:%d" % source_squad, -1) == state.turn: continue
		for target: int in state.squads:
			if state.squads[target].owner != player or G.alive(state, target).is_empty(): continue
			var eligible := false
			for target_model: int in G.alive(state, target):
				var keywords: Array = state.units[target_model].get("keywords", [])
				if "ADEPTUS ASTARTES" in keywords and "INFANTRY" in keywords: eligible = true
			if eligible: result.append(choice("Master of Shadows %d: re-roll Charges for %s" % [model, state.squads[target].name], "master-shadows", model, target))
	for model: int in models(state, player, "master-tactician"):
		var source_squad: int = state.units[model].squad
		if state.phase != "movement" or state.active != player or not state.units[model].get("on_battlefield", true): continue
		if state.unit_abilities.used.get("master-tactician:%d:%d" % [model, state.turn], false): continue
		for doctrine: String in Doctrines.available(state, player):
			for target: int in state.squads:
				if state.squads[target].owner != player or G.alive(state, target).is_empty() or not astartes_target_eligible(state, target): continue
				var sight := T.targeting(state, model, target)
				if sight.visible and sight.distance <= 9.001:
					result.append(choice("Master Tactician %d: %s for %s" % [model, doctrine, state.squads[target].name], "master-tactician", model, target, doctrine))
	if state.phase == "shooting" and state.active == player:
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.squads[squad].shot or not A.has(state, squad, "cold-and-calculating") or Doctrines.has_doctrine(state, squad, "tactical"): continue
			if state.unit_abilities.used.has("cold:%d:shooting" % squad): continue
			result.append(choice("Cold and Calculating %d: Lethal Hits against Monsters/Vehicles" % squad, "cold-select", G.alive(state, squad)[0], squad, "lethal"))
			result.append(choice("Cold and Calculating %d: Sustained Hits 1 against other targets" % squad, "cold-select", G.alive(state, squad)[0], squad, "sustained"))
		result.append_array(signum_array_choices(state, player))
		result.append_array(augury_servo_host_choices(state, player))
		result.append_array(optics_choices(state, player))
		result.append_array(omni_choices(state, player))
		result.append_array(Incursors.haywire_choices(state, player))
		result.append_array(catechism_fire_choices(state, player))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.squads[squad].shot or not A.has(state, squad, "overlapping-destruction"): continue
			for enemy: int in state.squads:
				if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
				result.append(choice("Eradicators %d: Blast target %s" % [squad, state.squads[enemy].name], "overlap-target", G.alive(state, squad)[0], enemy))
	for model: int in models(state, player, "author-of-the-codex"):
		if state.phase != "movement" or state.active != player or not Doctrines.enabled(state) or state.unit_abilities.used.get("author:%d" % model, "") == key(state): continue
		for doctrine: String in Doctrines.available(state, player):
			for target: int in state.squads:
				if G.alive(state, target).is_empty() or state.squads[target].owner != player: continue
				var is_astartes := false
				for target_model: int in G.alive(state, target):
					if str(state.units[target_model].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"):
						is_astartes = true
						break
				if not is_astartes: continue
				var sight := T.targeting(state, model, target)
				if sight.visible and sight.distance <= 12.001:
					result.append(choice("Author of the Codex %d: %s for %s" % [model, doctrine, state.squads[target].name], "author", model, target, doctrine))
	for model: int in models(state, player, "finest-hour"):
		var squad: int = state.units[model].squad
		if state.phase == "fight" and state.fight_actor == player and state.fight_step == "attacks" and squad in FightQueue.choices(state, player) and not state.squads[squad].fought and not state.unit_abilities.used.has("finest:%d" % squad): result.append(choice("Finest Hour: Captain %d (+3 A, Devastating Wounds)" % model, "finest", model, squad))
	for model: int in models(state, player, "righteous-fury"):
		var squad: int = state.units[model].squad
		if state.phase == "fight" and state.fight_actor == player and state.fight_step == "attacks" and squad in FightQueue.choices(state, player) and not state.squads[squad].fought and not state.unit_abilities.used.has("righteous-used:%d" % player): result.append(choice("Righteous Fury: Captain Titus %d (+1 melee Strength; heal after fighting)" % model, "righteous-fury", model, squad))
	if state.phase == "fight" and state.fight_actor == player and state.fight_step == "attacks":
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.squads[squad].fought or squad not in FightQueue.choices(state, player) or not A.has(state, squad, "cold-and-calculating") or Doctrines.has_doctrine(state, squad, "tactical"): continue
			if state.unit_abilities.used.has("cold:%d:fight" % squad): continue
			result.append(choice("Cold and Calculating %d: Lethal Hits against Monsters/Vehicles" % squad, "cold-select", G.alive(state, squad)[0], squad, "lethal"))
			result.append(choice("Cold and Calculating %d: Sustained Hits 1 against other targets" % squad, "cold-select", G.alive(state, squad)[0], squad, "sustained"))
		if not state.unit_abilities.used.get("banner-macragge-used:%d" % player, false):
			for squad: int in state.squads:
				if state.squads[squad].owner != player or state.squads[squad].fought or squad not in FightQueue.choices(state, player) or not A.has(state, squad, "banner-of-macragge"): continue
				for bearer: int in G.alive(state, squad):
					if A.identity(state.units[bearer]) == "victrix-honour-guard" and state.units[bearer].get("victrix_honour_guard_role", "") == "chapter-ancient":
						result.append(choice("Banner of Macragge: +1 melee Attack and Strength for %s" % state.squads[squad].name, "victrix-banner", bearer, squad))
						break
	for model: int in models(state, player, "my-will-be-done"):
		var squad: int = state.units[model].squad
		if state.unit_abilities.discounts.get(player, -1) != state.round and state.unit_abilities.discount_armed.get(squad, -1) != state.round: result.append(choice("My Will Be Done %d: use -1 CP on next eligible stratagem" % model, "discount", model, squad))
	if state.phase == "movement" and state.active == player:
		for squad: int in state.unit_abilities.reserves:
			if state.squads[squad].owner != player: continue
			var early_ingress_enhancement := first_movement_phase_ingress_enhancement(state, squad, player)
			if TransportRules.is_drop_pod(state, squad) or StormlanceEnhancements.ingress_round_allowed(state, squad) or not early_ingress_enhancement.is_empty():
				var ingress_label := "Deep Strike ingress"
				if TransportRules.is_drop_pod(state, squad): ingress_label = "Drop Pod Assault ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.DEATHWING_ASSAULT: ingress_label = "Deathwing Assault ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.CORPOREUM_RELIQUARY: ingress_label = "Corporeum Reliquary ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.THUNDERCOWL_TURBINES: ingress_label = "Thundercowl Turbines ingress"
				result.append(choice("%s: %s" % [ingress_label, state.squads[squad].name], "ingress", -1, squad))
				if StormlanceEnhancements.ingress_round_allowed(state, squad) and DetachmentStratagems.error(state, player, squad, DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM).is_empty():
					result.append(choice("Relic Teleportarium: %s ingress from more than 6 inches away; cannot Charge this turn (1 CP)" % state.squads[squad].name, "relic-teleportarium-ingress", -1, squad))
	if DetachmentStratagems.undying_actor(state) == player:
		result.append(choice("Decline Undying Legions for this attack", "undying-pass"))
	return result

static func catechism_fire_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	for model: int in models(state, player, "catechism-of-fire"):
		if not state.units[model].get("on_battlefield", true): continue
		var squad: int = state.units[model].squad
		if state.squads[squad].shot: continue
		var use_key := "catechism-fire:%d" % squad
		if state.unit_abilities.used.get(use_key, {}).get("phase_key", "") == key(state): continue
		for target: int in state.squads:
			if state.squads[target].owner == player or G.alive(state, target).is_empty(): continue
			var visible := false
			for observer: int in G.alive(state, squad):
				if not state.units[observer].get("on_battlefield", true): continue
				if T.targeting(state, observer, target).visible: visible = true
			if visible: result.append(choice("Catechism of Fire %d: select %s" % [model, state.squads[target].name], "catechism-fire", model, target))
	return result

static func augury_servo_host_target_eligible(state: Dictionary, source_squad: int, target: int) -> bool:
	if not A.enabled(state) or not state.squads.has(source_squad) or not state.squads.has(target): return false
	if int(state.squads[source_squad].get("owner", -1)) == int(state.squads[target].get("owner", -2)) or G.alive(state, target).is_empty(): return false
	var distance := INF
	var visible := false
	var unsupported_geometry := false
	for observer: int in G.alive(state, source_squad):
		for target_model: int in G.alive(state, target):
			distance = minf(distance, G.edge(state.units[observer], state.units[target_model]))
			var sight: Dictionary = T.pair(state, observer, target_model)
			visible = visible or bool(sight.get("visible", false))
			unsupported_geometry = unsupported_geometry or bool(sight.get("unsupported_geometry", false))
	return visible and not unsupported_geometry and distance <= 18.001

static func augury_servo_host_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.phase != "shooting" or state.active != player: return result
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != player or not StormlanceEnhancements.augury_servo_host_active(state, squad): continue
		var use_key := "augury-servo-host:%d" % squad
		if state.unit_abilities.used.get(use_key, "") == key(state): continue
		var source_models := G.alive(state, squad)
		if source_models.is_empty(): continue
		for target: int in state.squads:
			if not augury_servo_host_target_eligible(state, squad, target): continue
			result.append(choice("Augury Servo-host: %s cannot benefit from cover this phase" % state.squads[target].name, "augury-servo-host", source_models[0], target))
	return result

static func signum_array_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if state.phase != "shooting" or state.active != player: return result
	var use_key := "signum:%d" % player
	if state.unit_abilities.used.get(use_key, "") == key(state): return result
	for model: int in models(state, player, "signum-array"):
		var source: Dictionary = state.units[model]
		if source.wounds <= 0 or not source.get("on_battlefield", true): continue
		for target: int in state.squads:
			if state.squads[target].owner == player or G.alive(state, target).is_empty(): continue
			var sight := T.targeting(state, model, target)
			if sight.visible and sight.distance <= 18.001:
				result.append(choice("Tor Garadon %d: deny cover to %s" % [model, state.squads[target].name], "signum-array", model, target))
	return result

static func attachment_allowed(state: Dictionary, model: int, target: int) -> bool:
	var source: Dictionary = state.units[model]
	if target == source.squad or source.owner != state.squads[target].owner: return false
	if state.unit_abilities.get("reserves", {}).has(source.squad) or state.unit_abilities.get("reserves", {}).has(target): return false
	var name := A.identity(source)
	var allowed := ["bladeguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "infernus-squad", "hellblaster-squad", "sternguard-veteran-squad"] if name in ["captain", "chaplain", "lieutenant"] else ["necron-warriors", "immortals"]
	if name == "captain": allowed.append_array(["company-heroes", "desolation-squad"])
	if name == "librarian": allowed = ["vanguard-veteran-squad", "assault-intercessor-squad", "infernus-squad", "desolation-squad", "sternguard-veteran-squad", "hellblaster-squad", "intercessor-squad"]
	if name == "chief-librarian-tigurius": allowed = ["bladeguard-veteran-squad", "infernus-squad", "intercessor-squad", "assault-intercessor-squad", "sternguard-veteran-squad", "desolation-squad"]
	if name in ["chaplain-on-bike", "captain-on-bike", "suboden-khan"]: allowed = ["outrider-squad"]
	if name == "librarian-in-phobos-armour": allowed = ["infiltrator-squad", "eliminator-squad", "scout-squad", "incursor-squad", "reiver-squad"]
	if name == "captain-in-phobos-armour": allowed = ["infiltrator-squad", "eliminator-squad", "scout-squad", "incursor-squad", "reiver-squad"]
	if name == "lieutenant-in-phobos-armour": allowed = ["infiltrator-squad", "incursor-squad", "reiver-squad"]
	if name in ["captain-with-jump-pack", "chaplain-with-jump-pack"]: allowed = ["assault-intercessors-with-jump-packs", "vanguard-veteran-squad-with-jump-packs"]
	if name == "kayvaan-shrike": allowed = ["assault-intercessors-with-jump-packs", "vanguard-veteran-squad-with-jump-packs"]
	if name == "vulkan-hestan": allowed = ["infernus-squad", "bladeguard-veteran-squad", "eradicator-squad-with-melta-rifles", "company-heroes", "assault-intercessor-squad"]
	if name == "cato-sicarius": allowed = ["victrix-honour-guard"]
	if name in ["captain-in-terminator-armour", "chaplain-in-terminator-armour", "librarian-in-terminator-armour"]: allowed = ["terminator-squad"]
	if name in ["darnath-lysander", "caanok-var"]: allowed = ["terminator-squad", "terminator-assault-squad"]
	if name == "caanok-var": allowed = ["terminator-squad", "terminator-assault-squad"]
	if name == "iron-father-feirros": allowed = ["aggressor-squad", "heavy-intercessor-squad", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles"]
	if name == "kaius-konorius": allowed = ["sternguard-veteran-squad", "bladeguard-veteran-squad", "assault-intercessor-squad", "victrix-honour-guard"]
	if name == "captain-in-gravis-armour": allowed = ["aggressor-squad", "heavy-intercessor-squad", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles"]
	if name == "tor-garadon": allowed = ["aggressor-squad", "heavy-intercessor-squad", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles"]
	if name == "adrax-agatone": allowed = ["intercessor-squad", "assault-intercessor-squad", "infernus-squad", "bladeguard-veteran-squad", "sternguard-veteran-squad", "company-heroes"]
	if name == "marneus-calgar": allowed = ["bladeguard-veteran-squad", "terminator-assault-squad", "infernus-squad", "vanguard-veteran-squad", "intercessor-squad", "heavy-intercessor-squad", "terminator-squad", "assault-intercessor-squad", "aggressor-squad", "sternguard-veteran-squad", "company-heroes", "victrix-honour-guard", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles"]
	if name == "kor-sarro-khan": allowed = ["bladeguard-veteran-squad", "sternguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "company-heroes", "vanguard-veteran-squad"]
	if name in Supports.BODYGUARDS: allowed = Supports.BODYGUARDS[name]
	if Supports.CONDITIONAL_BODYGUARDS.has(name): allowed = Supports.CONDITIONAL_BODYGUARDS[name]
	var found := false
	var role := "support" if is_support_identity(state, source) else "leader"
	var existing: Array[String] = []
	var has_leader := false
	for id: int in G.alive(state, target):
		var unit: Dictionary = state.units[id]
		if unit.get("attachment_role", "") == "leader": has_leader = true
		if unit.get("attachment_role", "") == "support": existing.append(A.identity(unit))
		if role == "leader" and unit.get("attachment_role", "") == "leader": return false
		if A.identity(unit) in allowed: found = true
	if role == "support":
		if not Supports.compatible(existing, name): return false
		# Three attached Characters remain outside this bounded profile.
		if has_leader and not existing.is_empty(): return false
	elif existing.size() > 1: return false
	return found

static func _scout_gun_options(state: Dictionary, model: int) -> Array[String]:
	var u: Dictionary = state.units[model]
	if u.get("sergeant", false): return ["boltgun", "shotgun"]
	var quota: int = int(float(state.squads[u.squad].starting_strength) / 5.0)
	var sniper_count := 0
	var heavy_count := 0
	for other: int in state.units:
		if other == model or state.units[other].squad != u.squad or A.identity(state.units[other]) != "scout-squad": continue
		var gun := str(state.units[other].get("scout_gun", "boltgun"))
		if gun == "sniper-rifle": sniper_count += 1
		if gun in ["heavy-bolter", "missile-launcher"]: heavy_count += 1
	var current := str(u.get("scout_gun", "boltgun"))
	var result: Array[String] = ["boltgun", "shotgun"]
	if current == "sniper-rifle" or sniper_count < quota: result.append("sniper-rifle")
	if current in ["heavy-bolter", "missile-launcher"] or heavy_count < quota: result.append_array(["heavy-bolter", "missile-launcher"])
	return result

static func attach(state: Dictionary, model: int, target: int) -> void:
	var origin: int = state.units[model].squad
	var source: Dictionary = state.squads[origin]
	var unit: Dictionary = state.units[model]
	var defense := Groups.profile(state, model)
	unit.ranged_weapons = Equipment.inventory(state, model, false).duplicate(true)
	unit.melee_weapons = Equipment.inventory(state, model, true).duplicate(true)
	unit.defense = {"toughness": defense.toughness, "save_target": defense.save_target, "invulnerable_target": defense.invulnerable_target, "melee_invulnerable_target": defense.melee_invulnerable_target}
	unit.leadership_target = source.stats.leadership_target
	unit.objective_control = source.stats.objective_control
	unit.component_squad = origin
	unit.attachment_role = "support" if is_support_identity(state, unit) else "leader"
	var body: Dictionary = state.squads[target]
	if not body.get("attached", false):
		body.components = [{"squad": target, "role": "bodyguard", "name": body.name, "starting_strength": body.starting_strength}]
		for id: int in G.alive(state, target):
			state.units[id].attachment_role = "bodyguard"
			state.units[id].component_squad = target
			state.units[id].ranged_weapons = Equipment.inventory(state, id, false).duplicate(true)
			state.units[id].melee_weapons = Equipment.inventory(state, id, true).duplicate(true)
	body.components.append({"squad": origin, "role": unit.attachment_role, "name": source.name, "starting_strength": source.starting_strength})
	for ability: String in source.get("enabled_abilities", []):
		if ability not in body.enabled_abilities: body.enabled_abilities.append(ability)
	body.attached = true
	body.starting_strength += source.starting_strength
	body.training_cost = int(body.get("training_cost", 0)) + int(source.get("training_cost", 0))
	unit.squad = target
	state.squads.erase(origin)
	D.begin(state)

static func reconcile(state: Dictionary) -> void:
	if not A.enabled(state): return
	var a: Dictionary = state.unit_abilities
	if a.get("phase_key", "") != key(state) and state.phase in ["command", "movement", "shooting", "charge", "fight"]:
		a.phase_key = key(state)
		a.phase_start = state.revision + 1
		a.anchors = {}
		for squad: int in state.squads: a.anchors[squad] = G.alive(state, squad)
		var owners: Array = []
		for owner in [state.active, 3 - int(state.active)]:
			if logic_available(state, owner) or CoreReactions.start_available(state, owner) or not spiritual_choices(state, owner).is_empty() or not rampart_choices(state, owner).is_empty() or not DetachmentStratagems.adamantine_squads(state, owner).is_empty(): owners.append(owner)
		if not owners.is_empty(): a.window = {"kind": "start", "owners": owners}
	if state.round > 3:
		for squad: int in a.reserves.keys():
			for unit: Dictionary in state.units.values():
				if unit.squad == squad: unit.wounds = 0
			a.reserves.erase(squad)

static func open_end(state: Dictionary) -> bool:
	if not A.enabled(state) or state.phase not in ["command", "movement", "shooting", "charge", "fight"] or state.unit_abilities.end_done == key(state): return false
	var owners: Array = []
	for owner in [state.active, 3 - int(state.active)]:
		var stand_unyielding: bool = state.phase == "movement" and not DetachmentStratagems.stand_unyielding_squads(state, owner).is_empty()
		var phobos_mortis_snares: bool = state.phase == "movement" and not DetachmentStratagems.phobos_mortis_snares_squads(state, owner).is_empty()
		var gauntlet_storm_and_secure: bool = state.phase == "movement" and not DetachmentStratagems.gauntlet_storm_and_secure_squads(state, owner).is_empty()
		var gauntlet_duty_is_never_done: bool = state.phase == "fight" and not TransportRules.gauntlet_duty_candidates(state, owner, false).is_empty()
		var phobos_tactical_withdrawal: bool = not DetachmentStratagems.phobos_tactical_withdrawal_squads(state, owner).is_empty()
		if orb_available(state, owner) or DetachmentStratagems.eternal_pending(state, owner) or CoreReactions.end_available(state, owner) or not rapid_ingress_squads(state, owner).is_empty() or stand_unyielding or phobos_mortis_snares or gauntlet_storm_and_secure or gauntlet_duty_is_never_done or (state.phase == "fight" and owner != state.active and (not parabolic_jetleap_squads(state, owner).is_empty() or not echo_ravenspire_squads(state, owner).is_empty() or not DetachmentStratagems.withdraw_and_regroup_squads(state, owner).is_empty() or not DetachmentStratagems.gunship_extraction_squads(state, owner).is_empty())) or phobos_tactical_withdrawal or (state.phase == "fight" and (not DetachmentStratagems.wind_swift_squads(state, owner).is_empty() or not TacticalFluidity.end_fight_squads(state, owner).is_empty())): owners.append(owner)
	state.unit_abilities.end_done = key(state)
	if not owners.is_empty(): state.unit_abilities.window = {"kind": "end", "owners": owners}
	if owners.is_empty(): return false
	return true

static func rapid_ingress_squads(state: Dictionary, player: int) -> Array[int]:
	## Keep end-window ownership aligned with choices(): reserve presence alone does not create a reaction.
	var result: Array[int] = []
	if state.get("phase", "") != "movement" or player == int(state.get("active", -1)) or not state.has("stratagems"): return result
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return result
	var abilities: Dictionary = abilities_value
	var reserves_value: Variant = abilities.get("reserves", {})
	var used_value: Variant = abilities.get("used", {})
	var homers_value: Variant = abilities.get("homers", {})
	if typeof(reserves_value) != TYPE_DICTIONARY or typeof(used_value) != TYPE_DICTIONARY or typeof(homers_value) != TYPE_DICTIONARY: return result
	var reserves: Dictionary = reserves_value
	var used: Dictionary = used_value
	var homers: Dictionary = homers_value
	for squad_value: Variant in reserves:
		var squad := int(squad_value)
		if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player: continue
		if used.get("ingress:%d:%s" % [player, key(state)], false) or state.squads[squad].get("battle_shocked", false): continue
		if not StormlanceEnhancements.ingress_round_allowed(state, squad): continue
		if int(state.get("cp", {}).get(player, 0)) >= 1 or homers.has(squad): result.append(squad)
	result.sort()
	return result

static func first_movement_phase_ingress_enhancement(state: Dictionary, squad: int, player: int) -> String:
	if int(state.get("round", 0)) != 1 or str(state.get("phase", "")) != "movement": return ""
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player: return ""
	if int(state.get("active", -1)) != player: return ""
	var enhancement_id := StormlanceEnhancements.first_movement_ingress_enhancement(state, squad)
	if enhancement_id.is_empty(): return ""
	if enhancement_id == StormlanceEnhancements.CORPOREUM_RELIQUARY: return enhancement_id
	if enhancement_id == StormlanceEnhancements.THUNDERCOWL_TURBINES: return enhancement_id
	if not DetachmentStratagems.deathwing_unit(state, squad): return ""
	for model: int in A.sources(state, squad, "deep-strike"):
		if StormlanceEnhancements.model_active(state, model, enhancement_id): return enhancement_id
	return ""

static func deathwing_assault_first_movement_allowed(state: Dictionary, squad: int, player: int) -> bool:
	return first_movement_phase_ingress_enhancement(state, squad, player) == StormlanceEnhancements.DEATHWING_ASSAULT

static func parabolic_jetleap_squads(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not A.enabled(state) or state.phase != "fight" or owner == state.active: return result
	for squad: int in state.squads:
		if state.squads[squad].owner != owner or state.unit_abilities.get("reserves", {}).has(squad) or not A.has(state, squad, "parabolic-jetleap"): continue
		var alive := G.alive(state, squad)
		if alive.is_empty() or FightQueue.engaged(state, squad): continue
		var all_on_battlefield := true
		for model: int in alive:
			if not state.units[model].get("on_battlefield", true): all_on_battlefield = false
		if all_on_battlefield: result.append(squad)
	return result

static func echo_ravenspire_squads(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not A.enabled(state) or state.phase != "fight" or owner == state.active: return result
	for squad: int in state.squads:
		if state.squads[squad].owner != owner or state.unit_abilities.get("reserves", {}).has(squad) or G.alive(state, squad).is_empty() or FightQueue.engaged(state, squad) or not A.has(state, squad, "echo-of-the-ravenspire"): continue
		var all_on_battlefield := true
		for model: int in G.alive(state, squad):
			if not state.units[model].get("on_battlefield", true): all_on_battlefield = false
		if all_on_battlefield: result.append(squad)
	return result

static func point_error(state: Dictionary, point: Vector2, radius: float) -> String:
	if not point.is_finite() or absf(point.x) + radius > state.board_size.x / 2.0 or absf(point.y) + radius > state.board_size.y / 2.0: return "The whole base must fit on the battlefield."
	return ""

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	if str(selected.get("action", "")) in ["templar-vow-select", "templar-vow-pass"]:
		var vow_error := TemplarVows.pass_choice(state, player) if str(selected.get("action", "")) == "templar-vow-pass" else TemplarVows.apply_choice(state, player, selected)
		var vow_message := "Templar Vows: %s is active for the battle." % TemplarVows.display_name(str(selected.get("value", ""))) if str(selected.get("action", "")) == "templar-vow-select" else "Templar Vow selection was skipped."
		return {"error": vow_error, "message": vow_message if vow_error.is_empty() else ""}
	if str(selected.get("action", "")) == "combined-deployment-assail":
		return DetachmentStratagems.resolve_gauntlet_combined(state, player, int(selected.get("target", -1)))
	if str(selected.get("action", "")) == "combined-deployment-pass":
		var combined_pass_error := DetachmentStratagems.pass_gauntlet_combined(state, player)
		return {"error": combined_pass_error, "message": "Combined Deployment was passed." if combined_pass_error.is_empty() else ""}
	if str(selected.get("action", "")) in [AdeptOfTheOmnissiah.USE, AdeptOfTheOmnissiah.PASS]: return AdeptOfTheOmnissiah.apply(state, player, selected)
	if str(selected.get("action", "")) == "master-machine-war":
		var machine_war_result := MasterMachineWar.apply(state, player, selected, Doctrines.available(state, player))
		if str(machine_war_result.get("error", "")).is_empty(): Doctrines.record_selection(state, player, str(selected.get("value", "")))
		return machine_war_result
	if str(selected.get("action", "")) == "damocles-class-uplink":
		var uplink_result := DamoclesUplink.apply(state, player, selected, Doctrines.available(state, player))
		if str(uplink_result.get("error", "")).is_empty(): Doctrines.record_selection(state, player, str(selected.get("value", "")))
		return uplink_result
	if str(selected.get("action", "")) in [TargetAuguryWeb.APPLY, TargetAuguryWeb.PASS]: return TargetAuguryWeb.apply(state, player, selected)
	if str(selected.get("action", "")) == "command-battle-shock-decision":
		return CommandBattleShock.resolve(state, player, selected, int(state.get("revision", -1)), roller)
	if str(selected.get("action", "")) == "standard-exhortation":
		var exhortation_error := StormlanceEnhancements.apply_standard_exhortation(state, player, selected)
		return {"error": exhortation_error} if not exhortation_error.is_empty() else {"message": "Ancient Exhortation: the unit’s melee attacks gain +1 Attack until the end of the phase."}
	if str(selected.get("action", "")) == "mission-secure-asset":
		var asset_model: Dictionary = state.units.get(int(selected.get("model", -1)), {})
		if not Actions.has_mission_action(state, player, Actions.SECURE_ASSET) or asset_model.is_empty() or int(asset_model.get("owner", -1)) != player:
			return {"error": "Secure Asset requires the selected current mission and one of your units."}
		var asset_error := Actions.start_error(state, int(asset_model.squad), int(selected.get("target", -1)))
		if not asset_error.is_empty(): return {"error": asset_error}
		Actions.start(state, int(asset_model.squad), int(selected.get("target", -1)))
		return {"message": "%s started Secure Asset on %s; complete it at end of turn while controlling the objective." % [state.squads[int(asset_model.squad)].name, state.mission.objectives[int(selected.target)].name]}
	var a: Dictionary = state.unit_abilities
	var model: int = selected.model
	var target: int = selected.target
	if str(selected.get("action", "")).begins_with("transport-disembark-") or str(selected.get("action", "")).begins_with("transport-emergency-"):
		var transport_error := TransportRules.apply(state, player, selected, point, roller)
		if not transport_error.is_empty(): return {"error": transport_error}
		if not state.get("pending_deadly_demise", {}).is_empty() and state.get("unit_abilities", {}).get("transport_window", {}).is_empty():
			var destruction := DeadlyDemise.pump(state, roller)
			if not destruction.get("error", "").is_empty(): return destruction
			if destruction.get("complete", false) and not state.get("pending_attack", {}).is_empty(): return {"resume_attack": true, "message": "Emergency Disembark resolved; resume destruction effects."}
		if str(selected.get("action", "")) == "transport-disembark-start-aggressive": return {"message": "Aggressive Disembarkation: set up each model within the Transport's set-up distance; the disembark mode's other restrictions still apply."}
		if str(selected.get("action", "")) == "transport-emergency-aggressive-use": return {"message": "Aggressive Disembarkation: each Emergency Disembark model may be set up within 6 inches of the Transport, while still as close as possible."}
		if str(selected.get("action", "")) == "transport-disembark-aggressive-use": return {"message": "Aggressive Disembarkation: each Drop Pod passenger may be set up within 3 inches of the Drop Pod and must remain more than 8 inches from every enemy unit."}
		if str(selected.get("action", "")) == "transport-disembark-aggressive-pass": return {"message": "Drop Pod Assault Rapid Disembark continues with each model wholly within 3 inches and more than 8 inches from every enemy unit."}
		return {"message": "Transport disembarkation updated."}
	if str(selected.get("action", "")).begins_with("repulsor-combat-embarkation-"):
		var combat_embarkation_error := TransportRules.apply_combat_embarkation(state, player, selected)
		if not combat_embarkation_error.is_empty(): return {"error": combat_embarkation_error}
		return {"message": "Repulsor Combat Embarkation resolved. The charging unit can revise its targets before placement."}
	if selected.get("action", "") == "impulsor-loadout":
		if setup_actor(state) != player or selected.get("model", -1) < 0 or not state.units.has(int(selected.model)) or int(state.units[int(selected.model)].owner) != player: return {"error": "Impulsor wargear choices belong to your army preparations."}
		var impulsor_error := TransportRules.configure_impulsor(state, int(selected.model), int(selected.target), str(selected.value))
		if not impulsor_error.is_empty(): return {"error": impulsor_error}
		return {"message": "Impulsor wargear and its rules are updated from the local datasheet."}
	if selected.get("action", "") == "transport-weapon-loadout":
		if setup_actor(state) != player or selected.get("model", -1) < 0 or not state.units.has(int(selected.model)) or int(state.units[int(selected.model)].owner) != player: return {"error": "Optional transport weapons are selected during your army preparations."}
		var transport_weapon_error := TransportRules.configure_optional_transport_weapon(state, int(selected.model), str(selected.value))
		if not transport_weapon_error.is_empty(): return {"error": transport_weapon_error}
		return {"message": "Optional transport weapon updated from the local datasheet."}
	match selected.action:
		"transport-embark-start":
			var setup_passenger: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or setup_passenger.is_empty(): return {"error": "Starting embarked units is selected during your army preparations."}
			var start_error := TransportRules.start_embark(state, player, target, int(setup_passenger.squad))
			if not start_error.is_empty(): return {"error": start_error}
		"transport-embark":
			var movement_passenger: Dictionary = state.units.get(model, {})
			if movement_passenger.is_empty(): return {"error": "Select a living passenger model."}
			var movement_error := TransportRules.embark(state, player, target, int(movement_passenger.squad))
			if not movement_error.is_empty(): return {"error": movement_error}
		"seeker-objective":
			var source: Dictionary = state.units.get(model, {})
			if state.phase != "deployment" or source.is_empty() or source.owner != player or A.identity(source) != "vulkan-hestan" or not _vulkan_placement_complete(state, int(source.squad)) or not _objective_index_valid(state, target): return {"error": "Seeker of the Unfound selects one battlefield objective after Vulkan is fully placed."}
			if a.get("seeker_objectives", {}).has(model): return {"error": "Vulkan has already selected an objective for this battle."}
			a.seeker_objectives[model] = target
		"forgefather-target":
			var source: Dictionary = state.units.get(model, {})
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or A.identity(source) != "vulkan-hestan" or state.phase != "shooting" or state.active != player: return {"error": "Forgefather requires Vulkan He’stan in your Shooting phase."}
			if a.used.has("forgefather:%d:%d" % [player, state.turn]): return {"error": "Forgefather has already selected a target this Shooting phase."}
			if not state.squads.has(target) or state.squads[target].owner == player or G.alive(state, target).is_empty(): return {"error": "Forgefather must select a living enemy unit."}
			var sight := T.targeting(state, model, target)
			if not sight.visible or sight.distance > 24.001: return {"error": "Forgefather must select a visible enemy unit within 24 inches."}
			a.forgefather_targets[player] = {"target": target, "phase_key": "%d:%s" % [state.turn, state.phase], "source": model}
			a.used["forgefather:%d:%d" % [player, state.turn]] = true
		"cold-select":
			if not state.squads.has(target) or selected.value not in ["lethal", "sustained"] or not A.has(state, target, "cold-and-calculating") or state.squads[target].owner != player: return {"error": "Cold and Calculating requires Caanok Var's living unit and one listed attack mode."}
			if Doctrines.has_doctrine(state, target, "tactical"): return {"error": "Tactical Doctrine grants both Cold and Calculating effects without a separate choice."}
			var can_select: bool = state.phase == "shooting" and state.active == player and not state.squads[target].shot
			can_select = can_select or (state.phase == "fight" and state.fight_actor == player and state.fight_step == "attacks" and target in FightQueue.choices(state, player) and not state.squads[target].fought)
			var use_key := "cold:%d:%s" % [target, str(state.phase)]
			if not can_select or a.used.has(use_key): return {"error": "Cold and Calculating is chosen once when this unit is selected to attack."}
			a.used[use_key] = selected.value
		"cerebrex-scout":
			var source: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or source.is_empty() or source.owner != player or source.wounds <= 0 or A.identity(source) != "caanok-var" or not cerebrex_target_eligible(state, target): return {"error": "Cerebrex Logic Engine selects one friendly Adeptus Astartes Infantry unit during army preparation."}
			var use_key := "cerebrex:%d" % model
			if a.used.has(use_key): return {"error": "Cerebrex Logic Engine can select one unit once per battle."}
			if not a.has("cerebrex_targets"): a.cerebrex_targets = {}
			a.cerebrex_targets[target] = target
			a.used[use_key] = target
		"thunderhawk-insertion":
			var source: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or source.is_empty() or source.owner != player or source.wounds <= 0 or A.identity(source) != "marneus-calgar" or not thunderhawk_target_eligible(state, target): return {"error": "Thunderhawk Insertion selects one friendly Gravis, Phobos or Tacticus unit during army preparation."}
			if a.get("thunderhawk_targets", {}).has(player): return {"error": "Thunderhawk Insertion has already selected a unit for this army."}
			if not a.has("thunderhawk_targets"): a.thunderhawk_targets = {}
			a.thunderhawk_targets[player] = target
		"master-tactician":
			var source: Dictionary = state.units.get(model, {})
			var use_key := "master-tactician:%d:%d" % [model, state.turn]
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or A.identity(source) != "marneus-calgar": return {"error": "Master Tactician requires living Marneus Calgar on the battlefield."}
			if state.phase != "movement" or state.active != player or a.used.get(use_key, false): return {"error": "Master Tactician is used once in its owner's Movement phase."}
			if not state.squads.has(target) or state.squads[target].owner != player or not astartes_target_eligible(state, target): return {"error": "Choose a friendly Adeptus Astartes target unit."}
			var sight := T.targeting(state, model, target)
			if not sight.visible or sight.distance > 9.001 or selected.value not in Doctrines.available(state, player): return {"error": "Choose one unused doctrine for a visible friendly unit within 9 inches."}
			a.doctrines[target] = {"doctrine": selected.value}
			a.used[use_key] = true
			Doctrines.record_selection(state, player, selected.value)
		"rampart":
			var source: Dictionary = state.units.get(model, {})
			if source.is_empty() or source.owner != player or source.wounds <= 0 or A.identity(source) != "darnath-lysander": return {"error": "Rampart belongs to a living Darnath Lysander."}
			if a.get("window", {}).get("kind", "") != "start" or a.window.get("owners", []).is_empty() or int(a.window.owners[0]) != player: return {"error": "Rampart can only be used at the start-of-phase decision window."}
			var use_key := "rampart-used:%d" % model
			if a.used.has(use_key): return {"error": "Rampart has already been used this battle."}
			if not a.has("rampart_active"): a.rampart_active = {}
			a.rampart_active[model] = {"phase_key": key(state)}
			a.used[use_key] = true
		"augury-servo-host":
			var source: Dictionary = state.units.get(model, {})
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or not A.enabled(state) or not state.squads.has(int(source.get("squad", -1))) or not StormlanceEnhancements.augury_servo_host_active(state, int(source.squad)):
				return {"error": "Augury Servo-host belongs to a living bearer in its enhanced unit."}
			if state.phase != "shooting" or state.active != player or not state.squads.has(target) or not augury_servo_host_target_eligible(state, int(source.squad), target):
				return {"error": "Augury Servo-host requires a visible enemy within 18 inches of its unit during your Shooting phase."}
			var use_key := "augury-servo-host:%d" % int(source.squad)
			if a.used.get(use_key, "") == key(state): return {"error": "Augury Servo-host has already selected a target for this unit this phase."}
			if not a.has("signum_targets"): a.signum_targets = {}
			a.signum_targets[target] = {"owner": player, "phase_key": key(state), "source": model, "ability": "augury-servo-host"}
			a.used[use_key] = key(state)
		"signum-array":
			var source: Dictionary = state.units.get(model, {})
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or A.identity(source) != "tor-garadon":
				return {"error": "Signum Array belongs to a living Tor Garadon on the battlefield."}
			if state.phase != "shooting" or state.active != player or not state.squads.has(target) or state.squads[target].owner == player or G.alive(state, target).is_empty():
				return {"error": "Signum Array requires a living enemy during your Shooting phase."}
			var sight := T.targeting(state, model, target)
			if not sight.visible or sight.distance > 18.001: return {"error": "Signum Array requires a visible enemy within 18 inches."}
			var use_key := "signum:%d" % player
			if a.used.get(use_key, "") == key(state): return {"error": "Signum Array has already been used this phase."}
			if not a.has("signum_targets"): a.signum_targets = {}
			a.signum_targets[target] = {"owner": player, "phase_key": key(state), "source": model}
			a.used[use_key] = key(state)
		"catechism-fire":
			var source: Dictionary = state.units.get(model, {})
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or A.identity(source) != "chaplain-on-bike" or not A.has(state, source.squad, "catechism-of-fire"):
				return {"error": "Catechism of Fire belongs to a living Chaplain on Bike."}
			if state.phase != "shooting" or state.active != player or state.squads[source.squad].shot or not state.squads.has(target) or state.squads[target].owner == player or G.alive(state, target).is_empty():
				return {"error": "Catechism of Fire requires an unshot unit in its own Shooting phase and a living enemy target."}
			var visible := false
			for observer: int in G.alive(state, source.squad):
				if not state.units[observer].get("on_battlefield", true): continue
				if T.targeting(state, observer, target).visible: visible = true
			if not visible: return {"error": "Catechism of Fire can only select a visible enemy unit."}
			var use_key := "catechism-fire:%d" % source.squad
			if state.unit_abilities.used.get(use_key, {}).get("phase_key", "") == key(state): return {"error": "Catechism of Fire has already selected a target for this phase."}
			state.unit_abilities.used[use_key] = {"target": target, "phase_key": key(state)}
		"blessings-of-the-omnissiah", "blessings-defer", "blessings-pass", "master-of-the-forge", "master-forge-defer", "master-forge-pass":
			return Techmarine.apply(state, player, selected, roller)
		"priority-target":
			var priority_error := CombiLieutenant.select_priority_target(state, player, selected)
			if not priority_error.is_empty(): return {"error": priority_error}
		"evade-use", "evade-pass", "evade-place", "evade-confirm":
			return CombiLieutenant.apply(state, player, selected, point, roller)
		"cato-knight-use", "cato-knight-pass", "cato-knight-place", "cato-knight-confirm":
			return CatoSicarius.apply(state, player, selected, point)
		"fluidity-use", "fluidity-pass", "fluidity-place", "fluidity-confirm":
			if pending(state).get("source", "") == PhobosShadowMasters.MOVE_SOURCE: return PhobosShadowMasters.apply_move(state, player, selected, point, roller)
			if pending(state).get("source", "") == PhobosExecuteRedeploy.MOVE_SOURCE: return PhobosExecuteRedeploy.apply_move(state, player, selected, point, roller)
			return TacticalFluidity.apply(state, player, selected, point, roller)
		"shadow-masters-hidden", "shadow-masters-move":
			return PhobosShadowMasters.apply(state, player, selected, point, roller)
		"execute-redeploy-use", "execute-redeploy-pass":
			return PhobosExecuteRedeploy.apply(state, player, selected, point, roller)
		"fluidity-end":
			var fluidity_error := TacticalFluidity.start_end_fight(state, player, target)
			return {"error": fluidity_error}
		"storm-swift-move":
			var storm_swift_error := TacticalFluidity.start_storm_swift(state, player, target)
			return {"error": storm_swift_error}
		"purgation-use", "purgation-pass", "purgation-place", "purgation-confirm":
			return PurgationRun.apply(state, player, selected, point, roller)
		"glory-use", "glory-pass", "glory-place", "glory-confirm":
			return VictrixHonourGuard.apply(state, player, selected, point, roller)
		Incursors.DIVINATOR_WINDOW: return Incursors.choose(state, player, selected)
		"haywire-mine": return Incursors.haywire(state, player, selected, roller)
		"fearsome-assault": return Reivers.resolve(state, player, selected, roller)
		"adamantine-terror-decision": return DetachmentStratagems.resolve_adamantine_decision(state, player, selected, roller)
		"reiver-grav-chutes", "reiver-grapnel-launchers":
			if not state.squads.has(target) or state.squads[target].owner != player or selected.value not in ["on", "off"]: return {"error": "This option belongs to a Reiver Squad unit."}
			var members := G.alive(state, target)
			if members.is_empty() or A.identity(state.units[members[0]]) != "reiver-squad": return {"error": "This option belongs to a Reiver Squad unit."}
			if selected.action == "reiver-grav-chutes": state.squads[target].reiver_grav_chutes = selected.value == "on"
			else: state.squads[target].reiver_grapnel_launchers = selected.value == "on"
		"inceptor-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "inceptor-squad" or selected.value not in ["bolters", "plasma"]: return {"error": "This option belongs to an Inceptor model."}
			var profile := MarineProfiles.profile("inceptor-squad")
			var ranged: Dictionary = profile.ranged[0].duplicate(true) if selected.value == "bolters" else profile.additional_weapon_profiles.ranged[0].duplicate(true)
			bearer.ranged_weapons = [ranged]
		"land-speeder-cannon":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or A.identity(bearer) != "land-speeder" or selected.value not in ["onslaught", "pyrecannon"]: return {"error": "This option belongs to a Land Speeder."}
			var profile := MarineProfiles.profile("land-speeder")
			var ranged: Array = profile.ranged.duplicate(true)
			if selected.value == "pyrecannon":
				ranged = ranged.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "onslaught-gatling-cannon")
				ranged.append(profile.additional_weapon_profiles.ranged[0].duplicate(true))
			bearer.ranged_weapons = ranged
			bearer.land_speeder_pyrecannon = selected.value == "pyrecannon"
			bearer.inceptor_plasma_exterminators = selected.value == "plasma"
		"land-speeder-vengeance-cannon":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "land-speeder-vengeance" or selected.value not in ["heavy-bolter", "assault-cannon"]: return {"error": "This option belongs to a living Land Speeder Vengeance."}
			var profile := MarineProfiles.profile("land-speeder-vengeance")
			var ranged: Array = profile.ranged.duplicate(true)
			if selected.value == "assault-cannon":
				ranged = ranged.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "heavy-bolter")
				ranged.append(profile.additional_weapon_profiles.ranged[0].duplicate(true))
			bearer.ranged_weapons = ranged
			bearer.land_speeder_vengeance_assault_cannon = selected.value == "assault-cannon"
		"invader-atv-gun":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "invader-atvs" or selected.value not in ["multi-melta", "onslaught"]: return {"error": "This option belongs to a living Invader ATV model."}
			bearer.invader_atv_multi_melta = selected.value == "multi-melta"
			bearer.ranged_weapons = MarineProfiles.invader_atv_weapons(bearer.invader_atv_multi_melta)
			var source_profile := MarineProfiles.profile("invader-atvs")
			var equipped_count := 0
			for member: int in G.alive(state, target):
				if A.identity(state.units[member]) == "invader-atvs" and state.units[member].get("invader_atv_multi_melta", false): equipped_count += 1
			state.squads[target].training_cost = int(source_profile.points_by_models[state.squads[target].starting_strength]) + equipped_count * int(source_profile.wargear_costs["multi-melta"])
		"intercessor-melee", "intercessor-rifle", "intercessor-grenade-launcher":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "intercessor-squad": return {"error": "This equipment choice belongs to an Intercessor model."}
			if selected.action == "intercessor-melee":
				if not bearer.get("sergeant", false) or selected.value not in ["knives-and-fists", "chainsword", "power-fist", "power-weapon", "thunder-hammer"]: return {"error": "Only the Intercessor Sergeant may replace Knives and Fists with the listed melee weapon."}
				bearer.intercessor_melee_choice = selected.value
			elif selected.action == "intercessor-rifle":
				if not bearer.get("sergeant", false) or selected.value not in ["bolt-rifle", "chainsword", "hand-flamer", "plasma-pistol", "power-weapon"]: return {"error": "Only the Intercessor Sergeant may replace its Bolt Rifle with a listed option."}
				bearer.intercessor_rifle_choice = selected.value
			else:
				if bearer.get("sergeant", false): return {"error": "The Grenade Launcher option applies to an Intercessor model, not the Sergeant."}
				if selected.value not in ["on", "off"]: return {"error": "Invalid Grenade Launcher choice."}
				var equipped_count := 0
				for member: int in G.alive(state, target):
					if A.identity(state.units[member]) == "intercessor-squad" and state.units[member].get("intercessor_grenade_launcher", false): equipped_count += 1
				var limit := int(state.squads[target].starting_strength / 5.0)
				if selected.value == "on" and (bearer.get("intercessor_grenade_launcher", false) or equipped_count >= limit): return {"error": "This Intercessor unit has reached its Grenade Launcher limit."}
				if selected.value == "off" and not bearer.get("intercessor_grenade_launcher", false): return {"error": "This model is not equipped with a Grenade Launcher."}
				bearer.intercessor_grenade_launcher = selected.value == "on"
			_intercessor_weapons(bearer)
		"heavy-intercessor-bolter":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "heavy-intercessor-squad" or bearer.get("sergeant", false): return {"error": "Only a living Heavy Intercessor model, not its Sergeant, may take this option."}
			if selected.value not in ["on", "off"]: return {"error": "Invalid Heavy Bolter choice."}
			var equipped_count := 0
			for member: int in G.alive(state, target):
				if A.identity(state.units[member]) == "heavy-intercessor-squad" and state.units[member].get("heavy_intercessor_heavy_bolter", false): equipped_count += 1
			var limit := int(state.squads[target].starting_strength / 5.0)
			if selected.value == "on" and (bearer.get("heavy_intercessor_heavy_bolter", false) or equipped_count >= limit): return {"error": "This Heavy Intercessor unit has reached its Heavy Bolter limit."}
			if selected.value == "off" and not bearer.get("heavy_intercessor_heavy_bolter", false): return {"error": "This model does not have a Heavy Bolter to replace."}
			bearer.heavy_intercessor_heavy_bolter = selected.value == "on"
			_heavy_intercessor_weapons(bearer)
		"terminator-melee":
			var bearer: Dictionary = state.units.get(model, {})
			var allowed: Array = ["power-fist", "chainfist", "power-weapon"] if bearer.get("sergeant", false) else ["power-fist", "chainfist"]
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "terminator-squad" or selected.value not in allowed: return {"error": "This melee replacement does not match the Terminator model's source options."}
			bearer.terminator_melee_choice = selected.value
			_terminator_weapons(bearer)
		"terminator-assault-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "terminator-assault-squad" or selected.value not in ["on", "off"]: return {"error": "This equipment choice belongs to a living Terminator Assault model."}
			var old_shield: bool = bearer.get("terminator_assault_storm_shield", false)
			var new_shield: bool = selected.value == "on"
			if old_shield == new_shield: return {"error": "That Terminator Assault loadout is already equipped."}
			var delta := 5 if new_shield else -5
			var cost_error := _adjust_profile_option_cost(state, player, target, "terminator-assault-squad", delta, "Storm Shield")
			if not cost_error.is_empty(): return {"error": cost_error}
			state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + delta
			var wound_delta := 1 if new_shield else -1
			bearer.max_wounds = int(bearer.get("max_wounds", bearer.wounds)) + wound_delta
			bearer.wounds = maxi(0, int(bearer.wounds) + wound_delta)
			bearer.terminator_assault_storm_shield = new_shield
			var assault_profile := MarineProfiles.profile("terminator-assault-squad")
			var selected_weapon: Dictionary = assault_profile.additional_weapon_profiles.melee[0] if new_shield else assault_profile.melee[0]
			bearer.melee_weapons = [selected_weapon.duplicate(true)]
		"outrider-melee", "outrider-plasma-pistol":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "outrider-squad": return {"error": "This equipment choice belongs to a living Outrider model."}
			if selected.action == "outrider-melee":
				if not bearer.get("sergeant", false) or selected.value not in ["chainsword", "power-weapon", "thunder-hammer"]: return {"error": "Only the Outrider Sergeant may replace its Chainsword with a listed melee weapon."}
				bearer.outrider_melee_choice = selected.value
			else:
				if selected.value not in ["on", "off"]: return {"error": "Invalid Plasma Pistol choice."}
				var equipped_count := 0
				for member: int in state.units:
					if state.units[member].squad == target and A.identity(state.units[member]) == "outrider-squad" and state.units[member].get("outrider_plasma_pistol", false): equipped_count += 1
				var limit := int(state.squads[target].starting_strength / 3.0)
				if selected.value == "on" and (bearer.get("outrider_plasma_pistol", false) or equipped_count >= limit): return {"error": "This Outrider unit has reached its one Plasma Pistol per three models limit."}
				if selected.value == "off" and not bearer.get("outrider_plasma_pistol", false): return {"error": "This model does not have a Plasma Pistol to replace."}
				bearer.outrider_plasma_pistol = selected.value == "on"
			var weapons := MarineProfiles.outrider_weapons(bearer.get("outrider_plasma_pistol", false), bearer.get("outrider_melee_choice", "chainsword"))
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"terminator-special-weapon":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "terminator-squad" or bearer.get("sergeant", false): return {"error": "Only a living Terminator model, not its Sergeant, may replace its Storm Bolter."}
			if selected.value not in ["none", "assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]: return {"error": "Unsupported Terminator ranged weapon replacement."}
			var previous: String = bearer.get("terminator_special_weapon", "")
			var next: String = "" if selected.value == "none" else selected.value
			var limit := int(state.squads[target].starting_strength / 5.0)
			if not next.is_empty() and previous.is_empty() and _terminator_special_count(state, target) >= limit: return {"error": "This Terminator unit has reached its one special weapon per five models limit."}
			if (previous == "cyclone-missile-launcher") != (next == "cyclone-missile-launcher"):
				var point_delta := 10 if next == "cyclone-missile-launcher" else -10
				var cost_error := _adjust_profile_option_cost(state, player, target, "terminator-squad", point_delta, "Cyclone Missile Launcher")
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + point_delta
			bearer.terminator_special_weapon = next
			_terminator_weapons(bearer)
		"captain-bike-pistol", "captain-bike-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "captain-on-bike": return {"error": "This weapon choice belongs to a living Captain on Bike."}
			if selected.action == "captain-bike-pistol":
				if selected.value not in ["bolt", "plasma"]: return {"error": "Unsupported Captain on Bike pistol replacement."}
				bearer.captain_bike_plasma_pistol = selected.value == "plasma"
			else:
				if selected.value not in ["power-weapon", "thunder-hammer"]: return {"error": "Unsupported Captain on Bike melee replacement."}
				bearer.captain_bike_thunder_hammer = selected.value == "thunder-hammer"
			var bike_weapons := MarineProfiles.captain_bike_weapons(bearer.get("captain_bike_plasma_pistol", false), bearer.get("captain_bike_thunder_hammer", false))
			bearer.ranged_weapons = bike_weapons.ranged
			bearer.melee_weapons = bike_weapons.melee
		"firestrike-gun":
			if not state.units.has(model) or state.units[model].owner != player or state.units[model].squad != target or A.identity(state.units[model]) != "firestrike-servo-turrets" or selected.value not in ["autocannon", "las-talon"]: return {"error": "This weapon choice belongs to a Firestrike Servo-turret."}
			var weapon: Dictionary = MarineProfiles.firestrike_autocannon() if selected.value == "autocannon" else MarineProfiles.profile("firestrike-servo-turrets").ranged[0].duplicate(true)
			state.units[model].firestrike_autocannon = selected.value == "autocannon"
			state.units[model].ranged_weapons = [weapon]
		"redemptor-fragstorm", "redemptor-auxiliary", "redemptor-main", "redemptor-icarus":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "redemptor-dreadnought": return {"error": "This equipment choice belongs to a living Redemptor Dreadnought."}
			var old_macro: bool = bearer.get("redemptor_macro_plasma", false)
			var new_macro: bool = selected.value == "macro-plasma" if selected.action == "redemptor-main" else old_macro
			if selected.action == "redemptor-fragstorm" and selected.value not in ["fragstorm", "storm-bolters"]: return {"error": "Unsupported Redemptor primary weapon replacement."}
			if selected.action == "redemptor-auxiliary" and selected.value not in ["heavy-flamer", "onslaught"]: return {"error": "Unsupported Redemptor auxiliary weapon replacement."}
			if selected.action == "redemptor-main" and selected.value not in ["macro-plasma", "heavy-onslaught"]: return {"error": "Unsupported Redemptor main weapon replacement."}
			if selected.action == "redemptor-icarus" and selected.value not in ["on", "off"]: return {"error": "Unsupported Icarus Rocket Pod choice."}
			if old_macro != new_macro:
				var cost_error := _adjust_redemptor_option_cost(state, player, 10 if new_macro else -10)
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + (10 if new_macro else -10)
			bearer.redemptor_macro_plasma = new_macro
			if selected.action == "redemptor-fragstorm": bearer.redemptor_fragstorm = selected.value == "fragstorm"
			if selected.action == "redemptor-auxiliary": bearer.redemptor_heavy_flamer = selected.value == "heavy-flamer"
			if selected.action == "redemptor-icarus": bearer.redemptor_icarus = selected.value == "on"
			bearer.ranged_weapons = MarineProfiles.redemptor_weapons(bearer.get("redemptor_fragstorm", true), bearer.get("redemptor_heavy_flamer", true), new_macro, bearer.get("redemptor_icarus", false))
		"brutalis-melee", "brutalis-ranged":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "brutalis-dreadnought": return {"error": "This equipment choice belongs to a living Brutalis Dreadnought."}
			if selected.action == "brutalis-melee":
				if selected.value not in ["fists", "talons"]: return {"error": "Unsupported Brutalis melee replacement."}
				bearer.brutalis_talons = selected.value == "talons"
			else:
				if selected.value not in ["heavy-bolter", "multi-melta"]: return {"error": "Unsupported Brutalis ranged replacement."}
				bearer.brutalis_multi_melta = selected.value == "multi-melta"
			var replacement := MarineProfiles.brutalis_weapons(bearer.get("brutalis_talons", false), bearer.get("brutalis_multi_melta", false))
			bearer.ranged_weapons = replacement.ranged
			bearer.melee_weapons = replacement.melee
		"invictor-gun":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "invictor-tactical-warsuit": return {"error": "This equipment choice belongs to a living Invictor Tactical Warsuit."}
			if selected.value not in ["incendium", "autocannon"]: return {"error": "Unsupported Invictor weapon replacement."}
			bearer.invictor_autocannon = selected.value == "autocannon"
			bearer.ranged_weapons = MarineProfiles.invictor_weapons(bearer.invictor_autocannon)
		"desolation-rocket":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "desolation-squad": return {"error": "This rocket choice belongs to a living Desolation Marine."}
			if selected.value not in (["superfrag", "superkrak", "vengor"] if bearer.get("sergeant", false) else ["superfrag", "superkrak"]): return {"error": "Only the Desolation Sergeant may take a Vengor Launcher."}
			var old_vengor: bool = bearer.get("desolation_rocket", "superfrag") == "vengor"
			var new_vengor: bool = selected.value == "vengor"
			if old_vengor != new_vengor:
				var cost_error := _adjust_profile_option_cost(state, player, target, "desolation-squad", 5 if new_vengor else -5, "Vengor Launcher")
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + (5 if new_vengor else -5)
			bearer.desolation_rocket = selected.value
			bearer.ranged_weapons = MarineProfiles.desolation_weapons(selected.value)
		"invictor-mark":
			var source_squad: int = int(state.units.get(model, {}).get("squad", -1))
			if selected.value == "initial":
				if battle_actor(state) != player or A.forward_assault_mark(state, source_squad) >= 0: return {"error": "Initial Invictor marks are chosen at the start of the first battle round."}
				var mark_error := A.set_forward_assault_mark(state, source_squad, target)
				if not mark_error.is_empty(): return {"error": mark_error}
			elif selected.value == "replacement":
				var replace_error := A.advance_destroyed_mark_queue(state, source_squad, target)
				if not replace_error.is_empty(): return {"error": replace_error}
				if a.window.is_empty() and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true}
			else: return {"error": "Invalid Invictor mark choice."}
		"scout-gun":
			if A.identity(state.units[model]) != "scout-squad" or target != state.units[model].squad or selected.value not in _scout_gun_options(state, model): return {"error": "This Scout ranged replacement exceeds its source option limits."}
			state.units[model].scout_gun = selected.value
			state.units[model].ranged_weapons = MarineProfiles.scout_ranged(selected.value)
		"scout-blade":
			if A.identity(state.units[model]) != "scout-squad" or not state.units[model].get("sergeant", false) or target != state.units[model].squad or selected.value not in ["combat-knife", "chainsword"]: return {"error": "Only the Scout Sergeant may replace its Combat Knife with a Chainsword."}
			state.units[model].scout_blade = selected.value
			state.units[model].melee_weapons = MarineProfiles.scout_melee(selected.value)
		"scout-move", "scout-setup", "scout-pass", "scout-place", "scout-cancel", "scout-confirm", "strategium-select", "strategium-finish", "strategium-redeploy", "strategium-reserve", "strategium-place", "strategium-cancel", "strategium-confirm":
			return {"error": ScoutMoves.apply(state, selected.action, model, target, point)}
		"phobos-lieutenant-gun":
			state.units[model].phobos_carbine = selected.value == "carbine"
			state.units[model].ranged_weapons = MarineProfiles.phobos_lieutenant_gun(selected.value == "carbine")
		"helix-bearer":
			for member: int in state.units:
				if state.units[member].squad == target and A.identity(state.units[member]) == "infiltrator-squad": state.units[member].helix_gauntlet = selected.value == "on" and member == model
		"helix-heal":
			var rolled := RandomStat.roll("D3", roller)
			if not rolled.error.is_empty(): return rolled
			a.used["helix:%d" % target] = state.turn
			var result := Healing.begin(state, target, rolled.value, model, rolled)
			if result.error.is_empty(): a.window.ability_name = "Helix Gauntlet"
			return result
		"omni-scramblers":
			a.used["omni:%d" % state.units[model].squad] = key(state)
			if not a.has("detected"): a.detected = {}
			a.detected[target] = {"phase_key": key(state), "source": model}
		"gravis-captain-loadout":
			var weapons := MarineProfiles.gravis_captain_weapons(selected.value)
			if weapons.is_empty(): return {"error": "Unknown Gravis Captain loadout."}
			state.units[model].ranged_weapons = weapons.ranged
			state.units[model].melee_weapons = weapons.melee
			state.units[model].gravis_loadout = selected.value
		"captain-ranged-loadout", "captain-melee-loadout":
			var bearer: Dictionary = state.units[model]
			if selected.action == "captain-ranged-loadout": bearer.captain_ranged_loadout = selected.value
			else: bearer.captain_power_fist = selected.value == "power-fist"
			var weapons := MarineProfiles.captain_weapons(bearer.get("captain_ranged_loadout", "default"), bearer.get("captain_power_fist", false))
			if weapons.is_empty(): return {"error": "Unknown Captain loadout."}
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
			bearer.relic_shield = weapons.relic_shield
			bearer.max_wounds = 6 if weapons.relic_shield else 5
			bearer.wounds = bearer.max_wounds
		"lieutenant-ranged-loadout", "lieutenant-melee-loadout", "lieutenant-storm-shield":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "lieutenant": return {"error": "Choose source-listed Lieutenant equipment during army preparation."}
			if selected.action == "lieutenant-ranged-loadout":
				if selected.value not in MarineProfiles.profile("lieutenant").options.ranged_packages: return {"error": "Unsupported Lieutenant ranged equipment package."}
				bearer.lieutenant_weapon_package = selected.value
				if selected.value != "neo-volkite": bearer.lieutenant_storm_shield = false
			elif selected.action == "lieutenant-melee-loadout":
				if selected.value not in MarineProfiles.profile("lieutenant").options.fists_replacements: return {"error": "Unsupported Lieutenant Ceramite Fists replacement."}
				bearer.lieutenant_fists_replacement = selected.value
			else:
				if bearer.get("lieutenant_weapon_package", "default") != "neo-volkite" or selected.value not in ["on", "off"]: return {"error": "The Lieutenant Storm Shield is available only with the Neo-volkite Pistol package."}
				bearer.lieutenant_storm_shield = selected.value == "on"
			var loadout_error := _apply_lieutenant_loadout(state, model)
			if not loadout_error.is_empty(): return {"error": loadout_error}
		"terminator-captain-gun", "terminator-captain-blade":
			var bearer: Dictionary = state.units[model]
			if selected.action == "terminator-captain-gun": bearer.terminator_combi = selected.value == "combi"
			else: bearer.terminator_fist = selected.value == "fist"
			var weapons := MarineProfiles.terminator_captain_weapons(bearer.get("terminator_combi", false), bearer.get("terminator_fist", false))
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"terminator-chaplain-shield":
			var bearer: Dictionary = state.units[model]
			var shield: bool = selected.value == "shield"
			bearer.relic_shield = shield
			bearer.ranged_weapons = [] if shield else MarineProfiles.profile("chaplain-in-terminator-armour").ranged.duplicate(true)
			bearer.max_wounds = 6 if shield else 5
			bearer.wounds = bearer.max_wounds
		"jump-pack-captain-loadout":
			var bearer: Dictionary = state.units[model]
			var weapons := MarineProfiles.jump_pack_captain_weapons(selected.value)
			if weapons.is_empty(): return {"error": "Unknown Jump Pack Captain loadout."}
			bearer.ranged_weapons = weapons.ranged.duplicate(true)
			bearer.melee_weapons = weapons.melee.duplicate(true)
			bearer.relic_shield = weapons.relic_shield
			bearer.max_wounds = 6 if weapons.relic_shield else 5
			bearer.wounds = bearer.max_wounds
			bearer.jump_captain_loadout = selected.value
		"vanguard-veteran-pistol":
			var bearer: Dictionary = state.units[model]
			if selected.value not in ["heavy-bolt-pistol", "plasma-pistol", "combat-shield"]: return {"error": "Unsupported Vanguard Veteran pistol/shield option."}
			if selected.value == "plasma-pistol" and not bearer.get("sergeant", false) and _vanguard_plasma_count(state, target, model) >= int(state.squads[target].starting_strength / 5.0) * 2: return {"error": "Vanguard Veteran Plasma Pistols exceed the source limit."}
			bearer.vanguard_pistol = selected.value
			bearer.combat_shield = selected.value == "combat-shield"
			var melee_kind: String = bearer.get("vanguard_melee", "default")
			var weapons := MarineProfiles.vanguard_veteran_weapons(bearer.get("sergeant", false), selected.value, melee_kind, bearer.combat_shield)
			if weapons.is_empty(): return {"error": "Could not resolve the Vanguard Veteran pistol/shield option."}
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
			if bearer.has("defense"): bearer.defense.invulnerable_target = 5 if bearer.combat_shield else 0
		"vanguard-veteran-melee":
			var bearer: Dictionary = state.units[model]
			if not bearer.get("sergeant", false) or selected.value not in ["relic-blade", "power-fist", "thunder-hammer"]: return {"error": "Unsupported Vanguard Veteran Sergeant melee option."}
			var pistol_kind: String = bearer.get("vanguard_pistol", "heavy-bolt-pistol")
			var shield: bool = bearer.get("combat_shield", false)
			var weapons := MarineProfiles.vanguard_veteran_weapons(true, pistol_kind, selected.value, shield)
			if weapons.is_empty(): return {"error": "Could not resolve the Vanguard Veteran Sergeant melee option."}
			bearer.vanguard_melee = selected.value
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"narthecium":
			var rolled := RandomStat.roll("D3+1", roller)
			if not rolled.error.is_empty(): return rolled
			a.used["narthecium:%d" % target] = state.turn
			return Healing.begin(state, target, rolled.value, model, rolled)
		"narthecis-gauntlet":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "command" or state.active != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or not bearer.get("on_battlefield", true): return {"error": "Narthecis Gauntlet can only be used by its living Apothecary Biologis during your Command phase."}
			if not StormlanceEnhancements.model_active(state, model, StormlanceEnhancements.NARTHECIS_GAUNTLET): return {"error": "The selected Apothecary Biologis does not have an active Narthecis Gauntlet."}
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or G.alive(state, target).is_empty() or not Healing.needed(state, target): return {"error": "Narthecis Gauntlet requires a living unit that can receive healing."}
			if a.used.get("narthecis-gauntlet:%d" % target, -1) == state.turn: return {"error": "This unit has already used its Narthecis Gauntlet this turn."}
			var gauntlet_roll := RandomStat.roll("D3+1", roller)
			if not gauntlet_roll.error.is_empty(): return gauntlet_roll
			var healing_result := Healing.begin(state, target, gauntlet_roll.value, model, gauntlet_roll)
			if str(healing_result.get("error", "")).is_empty(): a.used["narthecis-gauntlet:%d" % target] = state.turn
			return healing_result
		"heal-wound", "heal-revive", "heal-place", "heal-unplaceable", "heal-reset", "heal-confirm":
			return Healing.apply(state, selected.action, model, point)
		"ancient-loadout":
			var weapons := MarineProfiles.ancient_weapons(selected.value == "power")
			state.units[model].ranged_weapons = weapons.ranged
			state.units[model].melee_weapons = weapons.melee
			state.units[model].ancient_power = selected.value == "power"
		"bladeguard": return Bladeguard.choose(state, selected.value)
		"bladeguard-pistol":
			state.units[model].ranged_weapons = [MarineProfiles.bladeguard_pistol(selected.value)]
		"sternguard-melee":
			state.units[model].melee_weapons = [MarineProfiles.sternguard_melee(selected.value)]
		"sternguard-gun":
			state.units[model].ranged_weapons[0] = MarineProfiles.sternguard_gun(selected.value)
			state.units[model].sternguard_special = selected.value != "firearm"
		"eliminator-sergeant":
			state.units[model].ranged_weapons[0] = MarineProfiles.eliminator_gun(selected.value)
		"eliminator-troopers":
			for id: int in G.alive(state, target):
				if A.identity(state.units[id]) == "eliminator-squad" and not state.units[id].get("sergeant", false): state.units[id].ranged_weapons[0] = MarineProfiles.eliminator_gun(selected.value)
			state.squads[target].eliminator_fusils = selected.value == "las"
		"optics":
			a.optics = {"squad": state.units[model].squad, "mode": selected.value, "target": target, "phase_key": key(state)}
		"auspex-spotted":
			DetachmentStratagems.mark_spotted(state, target, state.units[model].squad)
		"optics-cancel":
			a.erase("optics")
		"overlap-target":
			if not a.has("overlap_targets"): a.overlap_targets = {}
			a.overlap_targets[state.units[model].squad] = {"phase_key": key(state), "target": target}
		"aggressor-loadout":
			var boltstorm: bool = selected.value == "bolt"
			var inventory := MarineProfiles.aggressor_ranged(boltstorm)
			for id: int in G.alive(state, target):
				if A.identity(state.units[id]) == "aggressor-squad": state.units[id].ranged_weapons = inventory.duplicate(true)
			state.squads[target].weapon = inventory[0].profiles.values()[0].duplicate(true)
			state.squads[target].boltstorm_loadout = boltstorm
		"hellblaster-pistol":
			var plasma: bool = selected.value == "plasma"
			state.units[model].ranged_weapons[1] = MarineProfiles.hellblaster_pistol(plasma)
			state.units[model].plasma_pistol = plasma
		"jump-pack-sergeant-pistol":
			if selected.value not in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]: return {"error": "Unknown Jump Intercessor Sergeant pistol."}
			state.units[model].ranged_weapons = [MarineProfiles.jump_pack_pistol(selected.value)]
		"jump-pack-sergeant-melee":
			if selected.value not in ["chainsword", "power-fist", "power-weapon"]: return {"error": "Unknown Jump Intercessor Sergeant melee weapon."}
			state.units[model].melee_weapons = [MarineProfiles.jump_pack_sergeant_melee(selected.value)]
		"jump-pack-trooper-pistol":
			if selected.value not in ["heavy-bolt-pistol", "plasma-pistol"] or state.units[model].get("sergeant", false): return {"error": "Invalid Jump Intercessor pistol selection."}
			state.units[model].jump_plasma_pistol = selected.value == "plasma-pistol"
			state.units[model].ranged_weapons = [MarineProfiles.jump_pack_pistol(selected.value)]
		"eradicator-melta":
			var multi: bool = selected.value == "multi"
			state.units[model].ranged_weapons[0] = MarineProfiles.eradicator_ranged(multi)
			state.units[model].multi_melta = multi
		"damage-keep":
			state.pending_attack.current.phase = "damage_after_ability"
			a.window = {}
			return {"error": "", "resume_attack": true}
		"damage-reroll":
			var attack: Dictionary = state.pending_attack.current
			var damage_window: Dictionary = a.get("window", {})
			if damage_window.get("kind", "") != "damage-reroll" or damage_window.get("owners", []) != [player]: return {"error": "No matching Damage re-roll decision is pending."}
			var source := str(selected.get("value", damage_window.get("source", "Total Obliteration")))
			var sources: Array = damage_window.get("sources", [damage_window.get("source", "Total Obliteration")])
			if source not in sources: return {"error": "Choose one of the available Damage re-roll sources."}
			if source == "Armoured Wrath":
				var armoured_context := {"armoured_wrath": attack.get("armoured_wrath", false), "armoured_wrath_full": attack.get("armoured_wrath_full", false)}
				if not DamageAllocation.armoured_wrath_available(state.pending_attack, armoured_context, "damage"): return {"error": "Armoured Wrath has no Damage re-roll available for this attack."}
				DamageAllocation.consume_armoured_wrath(state.pending_attack, armoured_context, "damage")
			var fresh := RandomStat.roll(attack.damage, roller)
			if not fresh.error.is_empty(): return fresh
			var original: Array = attack.pending_damage.rolled.rolls
			var records: Array = []
			for index in range(fresh.rolls.size()): records.append({"index": index, "original": original[index], "replacement": fresh.rolls[index]})
			fresh.rerolls = records
			attack.result.dice_history.append_array(fresh.rolls)
			attack.pending_damage.rolled = fresh
			attack.phase = "damage_finalize"
			a.window = {}
			return {"error": "", "resume_attack": true}
		"nightforged-attack-count-pass", "nightforged-attack-count-reroll":
			if state.get("pending_attack", {}).is_empty() or pending(state).get("kind", "") != "nightforged-attack-count" or pending(state).get("owners", []) != [player]: return {"error": "No matching Nightforged Battery Attack characteristic choice is pending."}
			var attack_current: Dictionary = state.pending_attack.current
			var attack_checkpoint: Dictionary = attack_current.get("checkpoint", {})
			if attack_checkpoint.get("phase", "") != "generation" or not attack_checkpoint.get("context", {}).get("nightforged_attack_count", false) or not StormlanceEnhancements.active(state, int(state.pending_attack.squad), StormlanceEnhancements.NIGHTFORGED_BATTERY): return {"error": "Nightforged Battery cannot re-roll this Attack characteristic."}
			if selected.action == "nightforged-attack-count-reroll":
				var attack_replacement := RollWindows.reroll(attack_checkpoint, target, int(attack_checkpoint.get("revision", -1)), roller)
				if not attack_replacement.get("error", "").is_empty(): return attack_replacement
				attack_current.checkpoint = attack_replacement
			attack_current.nightforged_attack_count_decided = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"nightforged-hazard-pass", "nightforged-hazard-reroll":
			var hazard_window: Dictionary = pending(state)
			var hazard_pending: Dictionary = state.get("pending_hazard", {})
			if hazard_window.get("kind", "") != "nightforged-hazard" or hazard_window.get("owners", []) != [player] or hazard_pending.is_empty() or not StormlanceEnhancements.active(state, int(hazard_pending.get("squad", -1)), StormlanceEnhancements.NIGHTFORGED_BATTERY): return {"error": "No matching Nightforged Battery Hazard choice is pending."}
			if selected.action == "nightforged-hazard-pass":
				a.window = {}
				return {"error": "", "resolve_nightforged_hazard": true, "hazard_choice_complete": true, "message": "Nightforged Battery Hazard re-rolls accepted."}
			var hazard_result: Dictionary = hazard_pending.get("resolved", {}).get("hazardous", {})
			if target not in hazard_window.get("eligible", []) or target < 0 or target >= hazard_result.get("rolls", []).size(): return {"error": "Select an eligible Hazard die to re-roll."}
			if not roller.is_valid(): return {"error": "Missing Hazard dice provider."}
			var hazard_value: Variant = roller.call()
			if not hazard_value is int or hazard_value < 1 or hazard_value > 6: return {"error": "Hazard dice must be integers from 1 to 6."}
			var original_hazard_rolls: Array = hazard_result.rolls.duplicate()
			var replacement_rolls: Array = original_hazard_rolls.duplicate()
			replacement_rolls[target] = hazard_value
			var replacement_hazard := Hazard.from_rolls(state, int(hazard_pending.squad), replacement_rolls, hazard_pending.prepared.get("hazard_modifiers", []))
			if not replacement_hazard.get("error", "").is_empty(): return replacement_hazard
			var hazard_rerolls: Array = hazard_result.get("rerolls", []).duplicate(true)
			hazard_rerolls.append({"index": target, "original": original_hazard_rolls[target], "replacement": hazard_value, "source": "Nightforged Battery"})
			replacement_hazard.rerolls = hazard_rerolls
			hazard_pending.resolved.hazardous = replacement_hazard
			hazard_pending.remaining = replacement_hazard.total
			var rerolled_hazard_indices: Array[int] = []
			for reroll: Dictionary in hazard_rerolls: rerolled_hazard_indices.append(int(reroll.get("index", -1)))
			var next_hazard_eligible: Array[int] = []
			for index in range(replacement_hazard.rolls.size()):
				if index not in rerolled_hazard_indices: next_hazard_eligible.append(index)
			hazard_window.eligible = next_hazard_eligible
			return {"error": "", "resolve_nightforged_hazard": true, "hazard_choice_complete": false, "message": "Nightforged Battery re-rolled Hazard die %d from %d to %d." % [target + 1, original_hazard_rolls[target], hazard_value]}
		"cover-mark":
			var mark_table := "shattered_defences_marks" if a.window.get("kind", "") == "shattered-defences" else "cover_marks"
			if not a.has(mark_table): a[mark_table] = {}
			a[mark_table][target] = {"owner": player, "phase_key": key(state), "source": a.window.source}
			a.window = {}
		"mortis-snares-trigger-roll": return DetachmentStratagems.resolve_mortis_snares_trigger(state, player, selected, roller)
		"mortis-snares-damage-roll": return DetachmentStratagems.resolve_mortis_snares_damage(state, player, selected, roller)
		"explosives": return CoreReactions.throw_explosives(state, player, selected, roller)
		"mortal-allocate": return CoreReactions.allocate_mortal(state, player, selected, roller, selected.value)
		"deadly-demise-allocate":
			var demise := DeadlyDemise.allocate(state, player, selected, roller)
			if demise.get("error", "").is_empty() and state.phase == "charge" and CoreReactions.charge_closed(state) and state.get("unit_abilities", {}).get("window", {}).is_empty(): CoreReactions.reopen_heroic_choices(state)
			return demise
		"deadly-demise-vengeful-pass":
			var vengeful_window: Dictionary = a.get("window", {})
			if vengeful_window.get("kind", "") != DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW or vengeful_window.get("owners", []) != [player] or int(vengeful_window.get("squad", -1)) != target or int(vengeful_window.get("source_model", -1)) != model: return {"error": "No matching Vengeful Animus decision is pending."}
			var demise_pending: Dictionary = state.get("pending_deadly_demise", {})
			if demise_pending.is_empty(): return {"error": "The Deadly Demise continuation is missing."}
			var declined_squads: Dictionary = demise_pending.get("vengeful_animus_declined", {}).duplicate(true)
			declined_squads[str(target)] = true
			demise_pending.vengeful_animus_declined = declined_squads
			a.window = {}
			var declined_demise := DeadlyDemise.pump(state, roller)
			if not declined_demise.get("error", "").is_empty(): return declined_demise
			if declined_demise.get("complete", false) and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true, "message": "Deadly Demise resolved; resume the attack sequence."}
			return {"error": "", "message": str(declined_demise.get("message", "Rolling Deadly Demise without Vengeful Animus."))}
		"explosives-allocate": return CoreReactions.allocate_explosives(state, player, selected, roller)
		"hammer-of-wrath": return Hammer.resolve(state, player, selected, roller)
		"gravis-armoured-impact": return Hammer.resolve_armoured_impact(state, player, selected, roller)
		"inner-circle-wrath-of-the-lion": return Hammer.resolve_wrath_of_the_lion(state, player, selected, roller)
		"hammer-of-wrath-pass": return {"error": Hammer.skip(state, player, selected)}
		"core-stratagem":
			return CoreReactions.apply(state, player, selected, roller)
		"crushing-impact-pass":
			return {"error": CoreReactions.skip_crushing(state, player, selected)}
		"overwatch-pass":
			CoreReactions.clear_overwatch(state)
			return {"error": ""}
		"detachment-stratagem":
			var reaction_window: Dictionary = a.get("window", {})
			var selected_detachment_rule := DetachmentStratagems.rule_of(str(selected.get("stratagem", selected.get("value", ""))))
			if selected_detachment_rule == DetachmentStratagems.GAUNTLET_DUTY_IS_NEVER_DONE:
				var duty_error := TransportRules.gauntlet_duty_error(state, player, target, model, true)
				if not duty_error.is_empty(): return {"error": duty_error}
			var spent := DetachmentStratagems.apply(state, player, selected, roller)
			if not spent.get("error", "").is_empty(): return spent
			if selected_detachment_rule == DetachmentStratagems.GAUNTLET_DUTY_IS_NEVER_DONE:
				TransportRules.resolve_gauntlet_duty_embark(state, target, model)
				spent["message"] = "Duty is Never Done: %s embarks within %s." % [str(state.squads[target].get("name", "The selected Infantry unit")), str(state.squads[int(state.units[model].get("squad", -1))].get("name", "the selected Transport"))]
				return spent
			if reaction_window.get("kind", "") == DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW:
				a.window = {}
				var vengeful_demise := DeadlyDemise.pump(state, roller)
				if not vengeful_demise.get("error", "").is_empty(): return vengeful_demise
				if vengeful_demise.get("complete", false) and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true, "message": str(spent.get("message", "Vengeful Animus resolved."))}
				return {"error": "", "message": str(vengeful_demise.get("message", spent.get("message", "Vengeful Animus resolved.")))}
			if reaction_window.get("kind", "") == DetachmentStratagems.LAYERED_CERAMITE_WINDOW:
				a.window = {}
				return {"error": "", "resume_attack": true}
			if reaction_window.get("kind", "") == DetachmentStratagems.HEADHUNTER_WINDOW:
				var headhunter_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": headhunter_declaration}
			if reaction_window.get("kind", "") == DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW:
				var gravis_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": gravis_declaration}
			if reaction_window.get("kind", "") == DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW:
				var merciless_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": merciless_declaration}
			if reaction_window.get("kind", "") == DetachmentStratagems.PHOBOS_STRIKE_WINDOW:
				var phobos_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": phobos_declaration, "message": str(spent.get("message", "Strike from the Shadows resolved."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW:
				var methodical_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": methodical_declaration}
			if reaction_window.get("kind", "") == DetachmentStratagems.PIOUS_ENMITY_WINDOW:
				var pious_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": pious_declaration, "message": str(spent.get("message", "Pious Enmity resolved."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW:
				var relentless_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": relentless_declaration, "message": str(spent.get("message", "Relentless Assault resolved."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW:
				var point_blank_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": point_blank_declaration, "message": str(spent.get("message", "Point-Blank Brutality resolved."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW:
				var fortitude_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				if DetachmentStratagems.rule_of(str(selected.get("stratagem", selected.get("value", "")))) == DetachmentStratagems.TERMINATOR_TACTICAL_DREADNOUGHT_FORTITUDE:
					var fortitude_targets: Array = fortitude_declaration.get("terminator_fortitude_targets", []).duplicate()
					if target not in fortitude_targets: fortitude_targets.append(target)
					fortitude_declaration.terminator_fortitude_targets = fortitude_targets
				a.window = {}
				return {"error": "", "resume_declaration": fortitude_declaration}
			if reaction_window.get("kind", "") == DetachmentStratagems.DARKFLIGHT_WINDOW:
				var shadow_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": shadow_declaration, "message": str(spent.get("message", "Wings of Shadow grants Stealth for this Shooting phase."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.WORTHY_WINDOW:
				var worthy_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": worthy_declaration}
			if spent.has("undying"):
				var squad: int = int(spent.undying)
				state.reanimation.anchors[squad] = G.alive(state, squad)
				state.reanimation.pending = {"kind": "undying", "led": spent.led, "player": player, "turn": state.turn, "remaining": [squad], "current": {}, "results": []}
				return R.roll_unit(state, squad, roller)
			return spent
		"detachment-movement-pass":
			var movement_reaction_window: Dictionary = a.get("window", {})
			if movement_reaction_window.get("kind", "") != DetachmentStratagems.MOVEMENT_REACTION_WINDOW or movement_reaction_window.get("owners", []) != [player]: return {"error": "No matching post-move detachment reaction is pending."}
			a.window = movement_reaction_window.get("resume_window", {})
			return {"error": ""}
		"hurtling-use", "evasive-use", "umbral-evasion-use", "mounted-reaction-pass":
			var hurtling_window: Dictionary = a.get("window", {})
			if hurtling_window.get("kind", "") not in [DetachmentStratagems.SHOOTING_REACTION_WINDOW, "mounted-shooting-reaction", "stormlance-hurtling"] or hurtling_window.get("owners", []) != [player]: return {"error": "No matching detachment shooting reaction is pending."}
			if selected.action == "umbral-evasion-use":
				var umbral_candidates: Array = hurtling_window.get("umbral_targets", [int(hurtling_window.get("squad", -1))])
				if target not in umbral_candidates: return {"error": "Choose a PHOBOS unit targeted by this attack declaration."}
			elif int(hurtling_window.get("squad", -1)) != target: return {"error": "No matching detachment shooting reaction is pending."}
			if selected.action == "hurtling-use":
				if not bool(hurtling_window.get("can_hurtling", false)): return {"error": "Hurtling Targets is not eligible for this reaction."}
				var hurtling_error := DetachmentStratagems.use_hurtling(state, player, target)
				if not hurtling_error.is_empty(): return {"error": hurtling_error}
			elif selected.action == "evasive-use":
				var eligibility_error := DetachmentStratagems.error(state, player, target, DetachmentStratagems.EVASIVE_MANOEUVRES)
				if not eligibility_error.is_empty(): return {"error": eligibility_error}
				var evasive_error := DetachmentStratagems.use_evasive_manoeuvres(state, player, target)
				if not evasive_error.is_empty(): return {"error": evasive_error}
			elif selected.action == "umbral-evasion-use":
				var umbral_error := DetachmentStratagems.use_umbral_evasion(state, player, target)
				if not umbral_error.is_empty(): return {"error": umbral_error}
			var hurtling_declaration: Dictionary = hurtling_window.get("declaration", {}).duplicate(true)
			a.window = {}
			var reaction_result := {"error": "", "resume_declaration": hurtling_declaration}
			if selected.action == "umbral-evasion-use": reaction_result.message = "Umbral Evasion: ranged attacks targeting %s have -1 to Hit this Shooting phase." % str(state.squads[target].get("name", "the PHOBOS unit"))
			return reaction_result
		"armour-use", "armour-pass", "tactical-foresight-use":
			var armour_window: Dictionary = a.get("window", {})
			if armour_window.get("kind", "") != DetachmentStratagems.ARMOUR_WINDOW or armour_window.get("owners", []) != [player] or int(armour_window.get("squad", -1)) != target: return {"error": "No matching defensive stratagem decision is pending."}
			var foresight_spent: Dictionary = {}
			if selected.action == "armour-use":
				var armour_error := DetachmentStratagems.use_armour(state, player, target, int(armour_window.get("attacker_squad", -1)))
				if not armour_error.is_empty(): return {"error": armour_error}
			elif selected.action == "tactical-foresight-use":
				foresight_spent = DetachmentStratagems.apply(state, player, {"stratagem": DetachmentStratagems.ULTRAMARINES_TACTICAL_FORESIGHT, "value": DetachmentStratagems.ULTRAMARINES_TACTICAL_FORESIGHT, "target": target, "model": -1})
				if not str(foresight_spent.get("error", "")).is_empty(): return foresight_spent
			var armour_declaration: Dictionary = armour_window.get("declaration", {}).duplicate(true)
			a.window = {}
			if selected.action == "tactical-foresight-use": return {"error": "", "resume_declaration": armour_declaration, "message": str(foresight_spent.get("message", "Tactical Foresight resolved."))}
			return {"error": "", "resume_declaration": armour_declaration}
		"terminator-fortitude-pass":
			var fortitude_window: Dictionary = a.get("window", {})
			if fortitude_window.get("kind", "") != DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW or fortitude_window.get("owners", []) != [player] or int(fortitude_window.get("squad", -1)) != target: return {"error": "No matching Tactical Dreadnought Fortitude decision is pending."}
			var fortitude_declaration: Dictionary = fortitude_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": fortitude_declaration}
		"wings-shadow-pass":
			var shadow_window: Dictionary = a.get("window", {})
			if shadow_window.get("kind", "") != DetachmentStratagems.DARKFLIGHT_WINDOW or shadow_window.get("owners", []) != [player] or int(shadow_window.get("squad", -1)) != target: return {"error": "No matching Wings of Shadow decision is pending."}
			var shadow_declaration: Dictionary = shadow_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": shadow_declaration, "message": "Wings of Shadow declined for %s." % str(state.squads[target].get("name", "the selected unit"))}
		"worthy-pass":
			var worthy_window: Dictionary = a.get("window", {})
			if worthy_window.get("kind", "") != DetachmentStratagems.WORTHY_WINDOW or worthy_window.get("owners", []) != [player] or int(worthy_window.get("squad", -1)) != target: return {"error": "No matching Duty in Death or A Worthy Death decision is pending."}
			var worthy_declaration: Dictionary = worthy_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": worthy_declaration}
		"vengeful-pass":
			DetachmentStratagems.clear_vengeful(state)
			return {"error": ""}
		"medusa-power-pass":
			var medusa_power_error := DetachmentStratagems.decline_medusa_power(state, player)
			return {"error": medusa_power_error, "message": "Power of the Machine Spirit declined." if medusa_power_error.is_empty() else ""}
		"darkflight-vengeance-pass":
			var vengeance_error := DetachmentStratagems.decline_darkflight_vengeance(state, player)
			return {"error": vengeance_error, "message": "We Are Vengeance declined." if vengeance_error.is_empty() else ""}
		"darkflight-skyborne-pass":
			var skyborne_error := DetachmentStratagems.decline_darkflight_skyborne(state, player)
			return {"error": skyborne_error, "message": "Skyborne Surveillance declined." if skyborne_error.is_empty() else ""}
		"undying-pass":
			if DetachmentStratagems.undying_actor(state) != player: return {"error": "No matching Undying Legions reaction is pending."}
			state.detachment_stratagems.after.undying_closed = true
			return {"error": "", "message": "Undying Legions declined."}
		"wrath-sacrifice-pass":
			var sacrifice_error := DetachmentStratagems.decline_in_sacrifice(state, player, target, model)
			if not sacrifice_error.is_empty(): return {"error": sacrifice_error}
			return {"error": "", "message": "In Sacrifice, Victory declined for the destroyed unit."}
		"head-hunter-pass":
			var headhunter_window: Dictionary = a.get("window", {})
			if headhunter_window.get("kind", "") != DetachmentStratagems.HEADHUNTER_WINDOW or headhunter_window.get("owners", []) != [player] or int(headhunter_window.get("squad", -1)) != target: return {"error": "No matching Headhunter Doctrine decision is pending."}
			var head_hunter_declaration: Dictionary = headhunter_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": head_hunter_declaration}
		"gravis-annihilating-pass":
			var gravis_window: Dictionary = a.get("window", {})
			if gravis_window.get("kind", "") != DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW or gravis_window.get("owners", []) != [player] or int(gravis_window.get("squad", -1)) != target: return {"error": "No matching Annihilating Force decision is pending."}
			var gravis_declaration: Dictionary = gravis_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": gravis_declaration}
		"terminator-merciless-pass":
			var merciless_window: Dictionary = a.get("window", {})
			if merciless_window.get("kind", "") != DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW or merciless_window.get("owners", []) != [player] or int(merciless_window.get("squad", -1)) != target: return {"error": "No matching Merciless Veterans decision is pending."}
			var merciless_declaration: Dictionary = merciless_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": merciless_declaration}
		"phobos-strike-pass":
			var phobos_window: Dictionary = a.get("window", {})
			if phobos_window.get("kind", "") != DetachmentStratagems.PHOBOS_STRIKE_WINDOW or phobos_window.get("owners", []) != [player] or int(phobos_window.get("squad", -1)) != target: return {"error": "No matching Strike from the Shadows decision is pending."}
			var phobos_declaration: Dictionary = phobos_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": phobos_declaration}
		"methodical-brutality-pass":
			var methodical_window: Dictionary = a.get("window", {})
			if methodical_window.get("kind", "") != DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW or methodical_window.get("owners", []) != [player] or int(methodical_window.get("squad", -1)) != target: return {"error": "No matching Methodical Brutality decision is pending."}
			var methodical_declaration: Dictionary = methodical_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": methodical_declaration}
		"pious-enmity-pass":
			var pious_window: Dictionary = a.get("window", {})
			if pious_window.get("kind", "") != DetachmentStratagems.PIOUS_ENMITY_WINDOW or pious_window.get("owners", []) != [player] or int(pious_window.get("squad", -1)) != target: return {"error": "No matching Pious Enmity decision is pending."}
			var pious_declaration: Dictionary = pious_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": pious_declaration}
		"relentless-assault-pass":
			var relentless_window: Dictionary = a.get("window", {})
			if relentless_window.get("kind", "") != DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW or relentless_window.get("owners", []) != [player] or int(relentless_window.get("squad", -1)) != target: return {"error": "No matching Relentless Assault decision is pending."}
			var relentless_declaration: Dictionary = relentless_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": relentless_declaration}
		"point-blank-brutality-pass":
			var point_blank_window: Dictionary = a.get("window", {})
			if point_blank_window.get("kind", "") != DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW or point_blank_window.get("owners", []) != [player] or int(point_blank_window.get("squad", -1)) != target: return {"error": "No matching Point-Blank Brutality decision is pending."}
			var point_blank_declaration: Dictionary = point_blank_window.get("declaration", {}).duplicate(true)
			point_blank_declaration.point_blank_declined = true
			a.window = {}
			return {"error": "", "resume_declaration": point_blank_declaration}
		"mortal-wound-protection-pass", "layered-ceramite-pass":
			var layered_window: Dictionary = a.get("window", {})
			if layered_window.get("kind", "") != DetachmentStratagems.LAYERED_CERAMITE_WINDOW or layered_window.get("owners", []) != [player] or int(layered_window.get("squad", -1)) != target: return {"error": "No matching mortal-wound protection reaction is pending."}
			a.window = {}
			return {"error": "", "resume_attack": true}
		"wound-reroll":
			var current: Dictionary = state.pending_attack.current
			if current.checkpoint.context.get("venator_successful_twos_choice", false) and target not in RollWindows.eligible_natural_wounds(current.checkpoint, 2): return {"error": "Venator Omni-auspex can only re-roll an unused natural Wound 2 in this choice."}
			var replacement := RollWindows.reroll(current.checkpoint, target, current.checkpoint.revision, roller)
			if not replacement.error.is_empty(): return replacement
			current.checkpoint = replacement
			if current.checkpoint.context.get("aquilon_optics", false):
				current.aquilon_wound_done = true
				current.free_done = true
				state.pending_attack.aquilon_used[str(current.target)].wound = true
				a.window = {}
				return {"error": "", "resume_attack": true}
		"hit-reroll":
			var current: Dictionary = state.pending_attack.current
			var replacement := RollWindows.reroll(current.checkpoint, target, current.checkpoint.revision, roller)
			if not replacement.error.is_empty(): return replacement
			current.checkpoint = replacement
			current.aquilon_hit_done = true
			state.pending_attack.aquilon_used[str(current.target)].hit = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"hit-finish":
			var current: Dictionary = state.pending_attack.current
			current.aquilon_hit_done = true
			state.pending_attack.aquilon_used[str(current.target)].hit = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"machine-spirit-reroll", "machine-spirit-finish":
			if state.pending_attack.is_empty() or state.pending_attack.current.get("phase", "") != "rolls" or state.pending_attack.current.get("checkpoint", {}).get("context", {}).get("machine_spirit_power", false) == false or pending(state).get("kind", "") != ("machine-spirit-hit" if state.pending_attack.current.checkpoint.phase == "hit" else "machine-spirit-wound") or pending(state).get("owners", []) != [player]: return {"error": "No matching vehicle re-roll choice is pending."}
			var current: Dictionary = state.pending_attack.current
			if selected.action == "machine-spirit-reroll":
				var replacement := RollWindows.reroll(current.checkpoint, target, current.checkpoint.revision, roller)
				if not replacement.error.is_empty(): return replacement
				current.checkpoint = replacement
			if current.checkpoint.phase == "hit": state.pending_attack.machine_spirit_used.hit = true
			else: state.pending_attack.machine_spirit_used.wound = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"armoured-wrath-reroll", "armoured-wrath-finish":
			if state.pending_attack.is_empty() or state.pending_attack.current.get("phase", "") != "rolls" or pending(state).get("owners", []) != [player]: return {"error": "No matching Armoured Wrath re-roll choice is pending."}
			var current: Dictionary = state.pending_attack.current
			var checkpoint: Dictionary = current.get("checkpoint", {})
			var window_kind := str(pending(state).get("kind", ""))
			var die_kind := "hit" if window_kind == "armoured-wrath-hit" else "wound"
			var armoured_context: Dictionary = checkpoint.get("context", {})
			if window_kind not in ["armoured-wrath-hit", "armoured-wrath-wound"] or checkpoint.get("phase", "") != die_kind or not DamageAllocation.armoured_wrath_available(state.pending_attack, armoured_context, die_kind): return {"error": "Armoured Wrath is not available for this roll."}
			if selected.action == "armoured-wrath-reroll":
				var replacement := RollWindows.reroll(checkpoint, target, int(checkpoint.get("revision", -1)), roller)
				if not replacement.get("error", "").is_empty(): return replacement
				current.checkpoint = replacement
				DamageAllocation.consume_armoured_wrath(state.pending_attack, armoured_context, die_kind)
			a.window = {}
			return {"error": "", "resume_attack": true}
		"martial-paragon-reroll", "martial-paragon-finish":
			if state.pending_attack.is_empty() or state.pending_attack.current.get("phase", "") != "rolls" or pending(state).get("owners", []) != [player]: return {"error": "No matching Martial Paragon re-roll decision is pending."}
			var current: Dictionary = state.pending_attack.current
			var checkpoint: Dictionary = current.get("checkpoint", {})
			var window_kind := str(pending(state).get("kind", ""))
			var die_kind := "hit" if window_kind == "martial-paragon-hit" else "wound"
			var usage: Dictionary = state.pending_attack.get("martial_paragon_used", {})
			if window_kind not in ["martial-paragon-hit", "martial-paragon-wound"] or checkpoint.get("phase", "") != die_kind or not checkpoint.get("context", {}).get("martial_paragon", false) or bool(usage.get(die_kind, false)): return {"error": "Martial Paragon is not available for this roll."}
			if selected.action == "martial-paragon-reroll":
				if target not in RollWindows.eligible(checkpoint): return {"error": "Choose a Martial Paragon die that has not already been re-rolled."}
				var replacement := RollWindows.reroll(checkpoint, target, int(checkpoint.get("revision", -1)), roller)
				if not replacement.get("error", "").is_empty(): return replacement
				current.checkpoint = replacement
				usage[die_kind] = true
				state.pending_attack["martial_paragon_used"] = usage
			current["martial_paragon_%s_decided" % die_kind] = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"wound-finish":
			var current: Dictionary = state.pending_attack.current
			current.free_done = true
			if current.checkpoint.context.get("aquilon_optics", false): state.pending_attack.aquilon_used[str(current.target)].wound = true
			a.window = {}
			return {"error": "", "resume_attack": true}
		"legion-keep", "legion-reroll": return R.accept_roll(state, selected.action == "legion-reroll", roller)
		"pass":
			var kind: String = a.window.kind
			if kind == DetachmentStratagems.UNSTOPPABLE_WINDOW:
				var mobile_declaration: Dictionary = a.window.duplicate(true)
				a.window = {}
				return {"error": "", "resume_mobile_declaration": mobile_declaration, "message": "The available stratagem was declined."}
			var resume_cursor: int = int(a.window.get("resume_cursor", state.active))
			var resume_fight_step := str(a.window.get("resume_step", "attacks"))
			a.window.owners.pop_front()
			if a.window.owners.is_empty():
				a.window = {}
				if kind == "counter": return {"error": "", "resume_fight": true, "resume_cursor": resume_cursor, "resume_fight_step": resume_fight_step}
				return {"error": "", "advance": kind == "end"}
		"setup-done":
			var pod_reserve_error := _reserve_required_drop_pods(state, player)
			if not pod_reserve_error.is_empty(): return {"error": pod_reserve_error}
			for unit: Dictionary in state.units.values():
				if unit.owner == player and is_support_identity(state, unit) and unit.get("attachment_role", "") != "support": return {"error": "Support units must be attached to an eligible bodyguard."}
			var character := false
			for unit: Dictionary in state.units.values():
				if unit.owner == player and Groups.character(unit): character = true
			if character and not a.get("warlords", {}).has(player): return {"error": "Select your Warlord before finishing preparation."}
			var guilliman := guilliman_model(state, player)
			if guilliman != -1 and a.get("warlords", {}).get(player, -1) != guilliman: return {"error": "Roboute Guilliman must be your Warlord."}
			var roster_error := RosterValidation.seal(state, player)
			if not roster_error.is_empty(): return {"error": roster_error}
			if not a.has("setup_players"): a.setup_players = []
			a.setup_players.append(player)
			if a.setup_players.size() == 2 and state.deployment.order.is_empty():
				state.deployment.complete = true
				state.phase = "mission_first_turn" if state.get("mission", {}).get("id", "") == "ca-2026-27-dominance-hammer-fixed-v1" else "pre_battle"
				if state.phase == "pre_battle": ScoutMoves.begin(state)
		"battle-done":
			if TemplarVows.needs_choice(state, player):
				var vow_pass_error := TemplarVows.pass_choice(state, player)
				if not vow_pass_error.is_empty(): return {"error": vow_pass_error}
			if not a.has("battle_players"): a.battle_players = []
			a.battle_players.append(player)
		"warlord":
			if A.identity(state.units.get(model, {})) == "cato-sicarius" and LeaderCatalog.army_has_calgar(state, player): return {"error": "Captain of the Honour Guard replaces Cato's Leader role with Support while Marneus Calgar is in the army; choose another Warlord."}
			if not a.has("warlords"): a.warlords = {}
			a.warlords[player] = model
			for unit: Dictionary in state.units.values():
				if unit.owner == player: unit.keywords.erase("WARLORD")
			state.units[model].keywords.append("WARLORD")
		"attach": attach(state, model, target)
		"homer":
			var error := point_error(state, point, 0.0)
			if not error.is_empty(): return {"error": error}
			a.homers[target] = point
			a.used["homer-set:%d" % target] = true
		"reserve":
			var spent := 0
			for squad: int in a.reserves:
				if state.squads[squad].owner == player: spent += a.reserves[squad].cost
			var cost: int = state.squads[target].get("training_cost", 0)
			if cost <= 0: return {"error": "Missing reserve points for this unit."}
			if spent + cost > int(state.get("points_limit", 500)) / 2: return {"error": "Strategic reserves cannot exceed half the battle points limit."}
			a.reserves[target] = {"cost": cost}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"parabolic-jetleap":
			if target not in parabolic_jetleap_squads(state, player): return {"error": "Parabolic Jetleap requires an unengaged Inceptor Squad at the end of the opponent's Fight phase."}
			var cost := int(state.squads[target].get("training_cost", 0))
			if cost <= 0: return {"error": "The Inceptor Squad is missing its admitted reserve cost."}
			a.reserves[target] = {"cost": cost, "source": "parabolic-jetleap"}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"echo-of-ravenspire":
			if target not in echo_ravenspire_squads(state, player): return {"error": "Echo of the Ravenspire requires Kayvaan Shrike's unengaged unit at the end of your opponent's Fight phase."}
			var reserve_cost := int(state.squads[target].get("training_cost", 0))
			if reserve_cost <= 0: return {"error": "Kayvaan Shrike's unit is missing its admitted reserve cost."}
			a.reserves[target] = {"cost": reserve_cost, "source": "echo-of-ravenspire"}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"spiritual-leader":
			a.used["spiritual:%d" % model] = state.round
			state.squads[target].battle_shocked = false
		"tigurius-psychic":
			var psyker: Dictionary = state.units.get(model, {})
			var psyker_squad: int = int(psyker.get("squad", -1))
			if psyker.is_empty() or psyker.owner != player or psyker.wounds <= 0 or A.identity(psyker) != "chief-librarian-tigurius" or not A.has(state, psyker_squad, "librarius") or state.squads[psyker_squad].battle_shocked or state.active != player:
				return {"error": "This psychic ability requires a living, un-Battle-shocked Chief Librarian Tigurius in your turn."}
			var power_key := "tigurius-prescience:%d:%d" % [psyker_squad, state.turn] if selected.value == "prescience" else "tigurius-telepathic:%d:%d" % [psyker_squad, state.turn]
			if a.used.has(power_key): return {"error": "Tigurius has already used this psychic ability this turn."}
			var target_squad := -1
			if selected.value == "telepathic-assault":
				if state.phase != "shooting" or not state.squads.has(target) or state.squads[target].owner == player or G.alive(state, target).is_empty(): return {"error": "Telepathic Assault requires a living enemy in your Shooting phase."}
				var sight := T.targeting(state, model, target)
				if not sight.visible or sight.distance > 24.001: return {"error": "Telepathic Assault requires a visible enemy within 24 inches."}
				target_squad = target
			elif selected.value == "prescience":
				if state.phase != "movement" or target != psyker_squad: return {"error": "Prescience is used in your Movement phase and affects Tigurius's unit."}
			else: return {"error": "Unknown Chief Librarian psychic ability."}
			var psychic_roll := RandomStat.roll("D6", roller)
			if not psychic_roll.error.is_empty(): return psychic_roll
			var psychic_record := {"squad": psyker_squad, "target": target_squad, "power": selected.value, "roll": psychic_roll.value, "battle_shocked": psychic_roll.value == 1}
			if selected.value == "telepathic-assault":
				var damage_rolls: Array[int] = []
				var mortal_wounds := 0
				for _die in range(2):
					var die := RandomStat.roll("D3", roller)
					if not die.error.is_empty(): return die
					damage_rolls.append_array(die.rolls)
					mortal_wounds += die.value
				psychic_record.damage_rolls = damage_rolls
				psychic_record.mortal_wounds = mortal_wounds
				psychic_record.remaining = mortal_wounds
				psychic_record.allocations = []
				psychic_record.discarded = 0
				state.last_tigurius_telepathic_assault = psychic_record.duplicate(true)
				if mortal_wounds > 0: a.window = {"kind": CoreReactions.TIGURIUS_MORTAL, "owners": [state.squads[target_squad].owner], "target": target_squad}
				else: a.window = {}
			elif selected.value == "prescience":
				a.window = {}
				if not a.has("tigurius_prescience"): a.tigurius_prescience = {}
				a.tigurius_prescience[psyker_squad] = {"expires_turn": state.turn + 2, "source": model, "roll": psychic_roll.value}
				state.last_tigurius_prescience = psychic_record
			else: return {"error": "Unknown Chief Librarian psychic ability."}
			a.used[power_key] = true
			if psychic_roll.value == 1:
				state.squads[psyker_squad].battle_shocked = true
				Actions.interrupt(state, psyker_squad, "psychic test caused Battle-shock")
		"librarius-power":
			var librarian_identity := A.identity(state.units[model])
			var librarian_squad: int = state.units[model].squad
			if selected.value not in ["might-of-heroes", "thunderous-force", "soul-sight", "veil-of-time", "force-dome"] or librarian_identity not in ["librarian", "librarian-in-terminator-armour", "librarian-in-phobos-armour"] or not A.has(state, librarian_squad, "librarius"): return {"error": "Invalid Librarius ability selection."}
			if state.squads[librarian_squad].battle_shocked or a.used.has("librarius:%d:%d" % [librarian_squad, state.round]): return {"error": "This Librarius ability is unavailable this phase or battle round."}
			if selected.value != "soul-sight" and target != librarian_squad: return {"error": "This Librarius power affects its own unit."}
			if selected.value == "might-of-heroes" and (librarian_identity != "librarian-in-terminator-armour" or state.phase != "fight"): return {"error": "Might of Heroes is used in the Fight phase by the Terminator Librarian."}
			if selected.value == "thunderous-force" and (librarian_identity != "librarian-in-terminator-armour" or librarian_squad != target or state.phase != "shooting" or state.squads[librarian_squad].shot): return {"error": "Thunderous Force is used before this unit shoots in the Shooting phase."}
			if selected.value == "soul-sight" and (librarian_identity != "librarian-in-phobos-armour" or state.phase != "shooting" or state.active != player or not state.squads.has(target) or state.squads[target].owner == player or G.alive(state, target).is_empty() or not T.targeting(state, model, target).visible): return {"error": "Soul Sight requires a visible enemy unit in your Shooting phase."}
			if selected.value == "veil-of-time" and (librarian_identity != "librarian" or state.phase != "movement" or state.active != player or state.squads[librarian_squad].moved or FightQueue.engaged(state, librarian_squad) or a.veil_of_time_pending.has(librarian_squad)): return {"error": "Veil of Time requires an unengaged Librarian unit before it moves in your Movement phase."}
			if selected.value == "force-dome" and (librarian_identity != "librarian" or state.phase != "movement" or state.active != player): return {"error": "Force Dome is used in your Movement phase by the Librarian."}
			var psychic_roll := RandomStat.roll("D6", roller)
			if not psychic_roll.error.is_empty(): return psychic_roll
			a.used["librarius:%d:%d" % [librarian_squad, state.round]] = selected.value
			if not a.has("librarius_results"): a.librarius_results = []
			a.librarius_results.append({"squad": librarian_squad, "target": target, "power": selected.value, "roll": psychic_roll.value, "battle_shocked": psychic_roll.value == 1})
			if selected.value == "veil-of-time": a.veil_of_time_pending[librarian_squad] = true
			if selected.value == "force-dome": a.force_dome[librarian_squad] = {"expires_turn": state.turn + 2, "source": model}
			if selected.value == "soul-sight":
				if not a.has("cover_marks"): a.cover_marks = {}
				a.cover_marks[target] = {"owner": player, "phase_key": key(state), "source": librarian_squad}
			if psychic_roll.value == 1:
				state.squads[librarian_squad].battle_shocked = true
				Actions.interrupt(state, librarian_squad, "unit became battle-shocked")
		"phobos-shrouding": return PhobosLibrarian.choose(state, player, selected, roller)
		"logic":
			a.used["logic:%d" % model] = true
			state.squads[target].battle_shocked = false
		"acumen":
			a.used["acumen:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
			Doctrines.record_selection(state, player, selected.value)
			a.window = {"kind": "demi", "owners": [player], "doctrine": selected.value}
		"author":
			a.used["author:%d" % model] = key(state)
			if not a.has("additional_doctrines"): a.additional_doctrines = {}
			if not a.additional_doctrines.has(target): a.additional_doctrines[target] = []
			if selected.value not in a.additional_doctrines[target]: a.additional_doctrines[target].append(selected.value)
			Doctrines.record_selection(state, player, selected.value)
		"demi":
			a.used["demi:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
		"finest":
			state.fight_selected = target
			a.used["finest:%d" % target] = true
			a.used["finest-active:%d" % model] = state.turn
		"righteous-fury":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "fight" or state.fight_actor != player or state.fight_step != "attacks" or target not in FightQueue.choices(state, player) or not state.squads.has(target) or state.squads[target].owner != player or state.squads[target].fought or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "captain-titus" or not A.has(state, target, "righteous-fury"):
				return {"error": "Righteous Fury is used when Captain Titus is selected to fight."}
			if a.used.has("righteous-used:%d" % player): return {"error": "Righteous Fury has already been used by this army this battle."}
			a.used["righteous-used:%d" % player] = true
			a.used["righteous-active:%d" % target] = true
			state.fight_selected = target
		"victrix-banner":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "fight" or state.fight_actor != player or state.fight_step != "attacks" or target not in FightQueue.choices(state, player) or not state.squads.has(target) or state.squads[target].owner != player or state.squads[target].fought or not A.has(state, target, "banner-of-macragge"):
				return {"error": "Banner of Macragge is used when its eligible Victrix unit is selected to fight."}
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "victrix-honour-guard" or bearer.get("victrix_honour_guard_role", "") != "chapter-ancient":
				return {"error": "The living Chapter Ancient carrying Banner of Macragge must be present."}
			if a.used.get("banner-macragge-used:%d" % player, false): return {"error": "Banner of Macragge has already been used by this army this battle."}
			a.used["banner-macragge-used:%d" % player] = true
			if not a.has("banner_active"): a.banner_active = {}
			a.banner_active[target] = {"owner": player, "turn": state.turn}
			state.fight_selected = target
		"discount": a.discount_armed[target] = state.round
		"master-shadows":
			if not A.has(state, state.units.get(model, {}).get("squad", -1), "master-of-shadows") or state.phase != "command" or state.active != player or state.unit_abilities.used.get("master-shadows:%d" % state.units[model].squad, -1) == state.turn: return {"error": "Master of Shadows is chosen once in its owner's Command phase."}
			if selected not in choices(state, player): return {"error": "Choose one eligible friendly Adeptus Astartes Infantry unit."}
			state.unit_abilities.master_shadows[target] = {"owner": player, "turn": state.turn, "source": model}
			state.unit_abilities.used["master-shadows:%d" % state.units[model].squad] = state.turn
		"orb":
			var squad: int = state.units[model].squad
			a.used["orb:%d" % squad] = true
			a.used["resurrect-turn:%d" % player] = state.turn
			state.reanimation.anchors = a.anchors.duplicate(true)
			state.reanimation.pending = {"kind": "orb", "player": player, "turn": state.turn, "remaining": [squad], "current": {}, "results": []}
			return R.roll_unit(state, squad, roller)
		"tactics-place":
			var error := DetachmentStratagems.tactics_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"tactics-confirm": return DetachmentStratagems.confirm_tactics(state)
		"tactics-cancel": a.window = a.window.get("resume_window", {})
		"eternal-place":
			var error := DetachmentStratagems.eternal_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"eternal-confirm": return DetachmentStratagems.confirm_eternal(state)
		"ingress", "homer-ingress", "relic-teleportarium-ingress":
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player: return {"error": "Select one of your own reserve units to ingress."}
			var reserves_value: Variant = state.get("unit_abilities", {}).get("reserves", {})
			if typeof(reserves_value) != TYPE_DICTIONARY or not reserves_value.has(target): return {"error": "This unit is not in strategic reserves."}
			var teleportarium := str(selected.get("action", "")) == "relic-teleportarium-ingress"
			if teleportarium:
				var teleportarium_error := DetachmentStratagems.error(state, player, target, DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM)
				if not teleportarium_error.is_empty(): return {"error": teleportarium_error}
			var early_ingress_enhancement := first_movement_phase_ingress_enhancement(state, target, player)
			if not TransportRules.is_drop_pod(state, target) and not StormlanceEnhancements.ingress_round_allowed(state, target) and early_ingress_enhancement.is_empty(): return {"error": "This unit cannot make an ingress move before battle round 2."}
			var parent_frame := ResolutionFrames.current(state)
			if int(state.get("active", -1)) != player and str(parent_frame.get("kind", "")) == "phase-close" and str(parent_frame.get("status", "")) == "resolving":
				var parent_suspend_error := ResolutionFrames.suspend(state, str(parent_frame.get("frame_id", "")), "opponent-rapid-ingress")
				if not parent_suspend_error.is_empty(): return {"error": parent_suspend_error}
			var homer: bool = str(selected.get("action", "")) == "homer-ingress"
			var ingress_action_id := _ingress_action_id(state, player, target, homer)
			var ingress_frame := ResolutionFrames.begin(state, "unit-action", ingress_action_id, "ingress-placement")
			if ingress_frame.is_empty(): return {"error": "Could not open the ingress continuation frame."}
			var ingress_frame_id := str(ingress_frame.get("frame_id", ""))
			var ingress_suspend_error := ResolutionFrames.suspend(state, ingress_frame_id, "ingress-placement")
			if not ingress_suspend_error.is_empty():
				ResolutionFrames.complete(state, ingress_frame_id)
				return {"error": ingress_suspend_error}
			if teleportarium:
				var use_result := DetachmentStratagems.apply(state, player, {"stratagem": DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM, "target": target, "model": model, "value": DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM}, roller)
				if not use_result.get("error", "").is_empty():
					ResolutionFrames.complete(state, ingress_frame_id)
					return use_result
			a.window = {"kind": "ingress", "owners": [player], "squad": target, "positions": {}, "homer": homer, "relic_teleportarium": teleportarium, "resolution_frame_id": ingress_frame_id, "return_window": a.window.duplicate(true)}
			if teleportarium: return {"error": "", "message": "Relic Teleportarium: set up more than 6 inches from every enemy; this unit cannot declare a Charge this turn."}
		"ingress-place":
			var error := ingress_position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			a.window.positions[model] = point
		"ingress-cancel":
			var window: Dictionary = a.window
			var frame_error := _ingress_frame_error(state, window)
			if not frame_error.is_empty(): return {"error": frame_error}
			var complete_error := ResolutionFrames.complete(state, str(window.resolution_frame_id))
			if not complete_error.is_empty(): return {"error": complete_error}
			a.window = window.return_window
		"ingress-confirm":
			var window: Dictionary = a.window
			var frame_error := _ingress_frame_error(state, window)
			if not frame_error.is_empty(): return {"error": frame_error}
			var projected := state.duplicate(true)
			for id: int in state.units:
				if state.units[id].squad != window.squad: continue
				if not window.positions.has(id): return {"error": "Preview every model before confirming ingress."}
				var error := ingress_position_error(state, id, window.positions[id])
				if not error.is_empty(): return {"error": error}
				projected.units[id].on_battlefield = true
				projected.units[id].position = window.positions[id]
			if window.homer:
				var in_range := false
				for id: int in window.positions:
					if window.positions[id].distance_to(a.homers[window.squad]) - float(state.units[id].radius) <= 3.001: in_range = true
				if not in_range: return {"error": "The arriving unit must be within 3 inches of its Teleport Homer."}
			if not G.coherent(projected, window.squad): return {"error": "Ingress must leave the unit coherent."}
			for id: int in window.positions:
				state.units[id].position = window.positions[id]
				state.units[id].on_battlefield = true
			state.squads[window.squad].moved = true
			state.squads[window.squad].move_type = "ingress"
			state.squads[window.squad].set_up_this_turn = true
			a.reserves.erase(window.squad)
			end_move(state, window.squad)
			if state.active != player:
				state.cp[player] -= 0 if window.homer else 1
				a.used["ingress:%d:%s" % [player, key(state)]] = true
				if state.has("stratagems"): state.stratagems.uses.append({"player": player, "squad": window.squad, "stratagem": "rapid-ingress", "phase_key": key(state), "turn": state.turn})
				if window.homer: a.homers.erase(window.squad)
			a.window = window.return_window
			if TransportRules.is_drop_pod(state, int(window.squad)):
				var pod_model := TransportRules.drop_pod_model(state, int(window.squad))
				var pod_error := TransportRules.begin_drop_pod_arrival(state, player, pod_model, roller)
				if not pod_error.is_empty(): return {"error": pod_error}
				if state.get("unit_abilities", {}).get("transport_window", {}).is_empty():
					var ingress_complete_error := ResolutionFrames.complete(state, str(window.resolution_frame_id))
					if not ingress_complete_error.is_empty(): return {"error": ingress_complete_error}
			else:
				var ingress_complete_error := ResolutionFrames.complete(state, str(window.resolution_frame_id))
				if not ingress_complete_error.is_empty(): return {"error": ingress_complete_error}
	return {"error": ""}

static func ingress_position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window := pending(state)
	var unit: Dictionary = state.units[model]
	var enemy_clearance := 6.0 if bool(window.get("relic_teleportarium", false)) else 8.0
	var error := point_error(state, point, float(unit.radius))
	if not error.is_empty(): return error
	var half: Vector2 = state.board_size / 2.0
	var nearest_edge_gap := minf(half.x - absf(point.x), half.y - absf(point.y)) - float(unit.radius)
	if nearest_edge_gap > 6.001: return "Ingress models must be set up wholly within 6 inches of a battlefield edge."
	if int(state.get("round", 0)) < 3:
		var zones_value: Variant = state.get("deployment", {}).get("zones", {})
		if typeof(zones_value) != TYPE_DICTIONARY: return "Cannot validate ingress without deployment zones."
		var enemy_owner := 3 - int(unit.owner)
		var zones: Dictionary = zones_value
		if not zones.has(enemy_owner): return "Cannot validate ingress without the opponent's deployment zone."
		var enemy_zone_value: Variant = zones[enemy_owner]
		if typeof(enemy_zone_value) != TYPE_RECT2: return "Cannot validate ingress without the opponent's deployment zone."
		var enemy_zone: Rect2 = enemy_zone_value
		if point.distance_to(point.clamp(enemy_zone.position, enemy_zone.end)) <= float(unit.radius) + 0.001:
			return "Ingress models cannot be set up within the opponent's deployment zone before battle round 3."
	for other: int in state.units:
		if other == model: continue
		var enemy: Dictionary = state.units[other]
		if enemy.wounds <= 0 or (not enemy.get("on_battlefield", true) and not window.positions.has(other)): continue
		var position: Vector2 = window.positions.get(other, enemy.position)
		var distance: float = point.distance_to(position) - float(unit.radius) - float(enemy.radius)
		if distance < -0.001: return "Ingress bases cannot overlap."
		if enemy.owner != unit.owner and distance <= enemy_clearance + 0.001: return "Ingress requires more than %d inches from every enemy unit." % int(enemy_clearance)
	var projected := state.duplicate(true)
	projected.units[model].on_battlefield = true
	projected.units[model].position = point
	return T.path_error(projected, model, point)

static func start_round(state: Dictionary) -> void:
	if not A.enabled(state) or state.active != state.get("first_player", 1): return
	for owner: int in state.unit_abilities.get("warlords", {}):
		var model: int = state.unit_abilities.warlords[owner]
		if state.unit_abilities.used.get("warlord-cp:%d" % owner, -1) == state.round: continue
		state.unit_abilities.used["warlord-cp:%d" % owner] = state.round
		if state.units[model].wounds > 0 and "transhuman-strategist" in A.RULES.get(A.identity(state.units[model]), []): state.cp[owner] += 1

static func logic_available(state: Dictionary, owner: int) -> bool:
	for model: int in models(state, owner, "engrammatic-logic"):
		if state.unit_abilities.used.has("logic:%d" % model): continue
		for squad: int in state.squads:
			if state.squads[squad].owner == owner and state.squads[squad].battle_shocked and not G.alive(state, squad).is_empty() and G.distance_to_target(state, state.units[model], squad) <= 12.001: return true
	return false

static func orb_available(state: Dictionary, owner: int) -> bool:
	if not R.enabled(state) or state.unit_abilities.used.get("resurrect-turn:%d" % owner, -1) == state.turn: return false
	for model: int in models(state, owner, "resurrection-orb"):
		var squad: int = state.units[model].squad
		if R.supported_unit(state, squad) and not state.unit_abilities.used.has("orb:%d" % squad): return true
	return false

static func battle_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "start_turn" or state.turn != 1: return -1
	for owner in [state.get("first_player", 1), 3 - int(state.get("first_player", 1))]:
		if owner in state.unit_abilities.get("battle_players", []): continue
		if TemplarVows.needs_choice(state, int(owner)): return int(owner)
		for unit: Dictionary in state.units.values():
			if unit.owner != owner or unit.wounds <= 0: continue
			if A.identity(unit) in ["terminator-squad", "terminator-assault-squad"]: return owner
			if A.identity(unit) == "invictor-tactical-warsuit" and A.forward_assault_mark(state, int(unit.squad)) < 0: return owner
	return -1

static func end_move(state: Dictionary, moved_squad: int) -> void:
	DetachmentStratagems.record_move(state, moved_squad)
	if not A.enabled(state):
		TargetAuguryWeb.open_for_move(state, moved_squad, "end")
		return
	DetachmentStratagems.open_movement_reaction(state, moved_squad)
	for squad: int in state.unit_abilities.homers.keys():
		if state.squads[squad].owner == state.squads[moved_squad].owner: continue
		for model: int in G.alive(state, moved_squad):
			var unit: Dictionary = state.units[model]
			if unit.position.distance_to(state.unit_abilities.homers[squad]) - float(unit.radius) <= 1.001:
				state.unit_abilities.homers.erase(squad)
				break
	CombiLieutenant.open_after_enemy_move(state, moved_squad)
	CatoSicarius.open_after_enemy_move(state, moved_squad)
	Techmarine.open_for_move(state, moved_squad, "end")
	TargetAuguryWeb.open_for_move(state, moved_squad, "end")

static func open_mortis_snares_after_move(state: Dictionary, moved_squad: int, move_type: String) -> bool:
	return DetachmentStratagems.open_mortis_snares_after_move(state, moved_squad, move_type)

## Return the squad whose Movement action owns the open decision stack.
## These specialized windows can be nested through resume_window, so inspect the whole stack.
static func movement_reaction_squad(state: Dictionary) -> int:
	return _movement_reaction_squad(pending(state), 0)

static func _movement_reaction_squad(window: Dictionary, depth: int) -> int:
	if window.is_empty() or depth >= 8: return -1
	var kind := str(window.get("kind", ""))
	if kind == DetachmentStratagems.UNSTOPPABLE_WINDOW and str(window.get("action", "")) == "movement":
		var selected_squad: Variant = window.get("squad", -1)
		if selected_squad is int and selected_squad >= 0: return selected_squad
	if kind in [CatoSicarius.WINDOW, CatoSicarius.PLACEMENT]:
		var trigger: Variant = window.get("trigger", -1)
		if trigger is int and trigger >= 0: return trigger
	if kind == DetachmentStratagems.MOVEMENT_REACTION_WINDOW:
		var trigger: Variant = window.get("squad", -1)
		if trigger is int and trigger >= 0: return trigger
	if kind == "tactics":
		var trigger: Variant = window.get("trigger", -1)
		if trigger is int and trigger >= 0: return trigger
	if kind in ["evade-and-survive", "evade-placement"]:
		var queue: Array = window.get("queue", [])
		if not queue.is_empty() and typeof(queue[0]) == TYPE_DICTIONARY:
			var row: Dictionary = queue[0]
			var trigger: Variant = row.get("trigger", -1)
			if trigger is int and trigger >= 0: return trigger
	if kind == "blessings-of-the-omnissiah" and str(window.get("moment", "")) == "end":
		var moved_squad: Variant = window.get("squad", -1)
		if moved_squad is int and moved_squad >= 0: return moved_squad
	if kind in [DetachmentStratagems.PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW, DetachmentStratagems.PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW, DetachmentStratagems.PHOBOS_SHADOW_MORTIS_MORTAL_WINDOW]:
		var moved_squad: Variant = window.get("moved_squad", -1)
		if moved_squad is int and moved_squad >= 0: return moved_squad
	if kind == TargetAuguryWeb.WINDOW and str(window.get("moment", "")) == "end":
		var augury_squad: Variant = window.get("squad", -1)
		if augury_squad is int and augury_squad >= 0: return augury_squad
	var resume_window: Variant = window.get("resume_window", {})
	return _movement_reaction_squad(resume_window, depth + 1) if typeof(resume_window) == TYPE_DICTIONARY else -1

static func optics_choices(state: Dictionary, player: int, only_squad: int = -1) -> Array:
	var result: Array = []
	if state.phase != "shooting" or state.active != player: return result
	for squad: int in state.squads:
		if only_squad >= 0 and squad != only_squad: continue
		if state.squads[squad].owner != player or state.squads[squad].shot or not A.has(state, squad, "special-issue-optics-and-ammunition"): continue
		if Actions.shooting_blocked(state, squad): continue
		if state.squads[squad].fell_back and not Doctrines.shoot_after_fallback(state, squad): continue
		if state.squads[squad].advanced and not Doctrines.has_doctrine(state, squad, "devastator"): continue
		var source: int = G.alive(state, squad)[0]
		result.append(choice("Eliminators %d: Ignores Cover" % squad, "optics", source, -1, "cover"))
		for enemy: int in state.squads:
			if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
			for model: int in G.alive(state, squad):
				if G.distance_to_target(state, state.units[model], enemy) <= 24.001:
					result.append(choice("Eliminators %d: +6 detection on %s" % [squad, state.squads[enemy].name], "optics", source, enemy, "detect"))
					break
	return result

static func auspex_triangulation_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if state.phase != "shooting" or state.active != player or not state.get("combat_doctrines", {}).get("stormlance", false): return result
	for friendly: int in state.squads:
		if int(state.squads[friendly].owner) == player and state.squads[friendly].shot: return result
	for squad: int in state.squads:
		if state.squads[squad].owner != player or not StormlanceEnhancements.active(state, squad, StormlanceEnhancements.AUSPEX) or DetachmentStratagems.spotted_source_used(state, squad): continue
		var source_models: Array[int] = G.alive(state, squad)
		if source_models.is_empty(): continue
		var source: int = source_models[0]
		if not state.units[source].get("on_battlefield", true): continue
		for enemy: int in state.squads:
			if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
			for candidate: int in source_models:
				var sight: Dictionary = T.targeting(state, candidate, enemy)
				if sight.get("visible", false) and float(sight.get("distance", 999.0)) <= 12.001:
					result.append(choice("Auspex Triangulation %d: mark %s spotted (+3 detection)" % [squad, state.squads[enemy].name], "auspex-spotted", candidate, enemy))
					break
	return result

static func cerebrex_target_eligible(state: Dictionary, squad: int) -> bool:
	if not state.squads.has(squad) or G.alive(state, squad).is_empty(): return false
	for model: int in G.alive(state, squad):
		var keywords: Array = state.units[model].get("keywords", [])
		if "ADEPTUS ASTARTES" not in keywords or "INFANTRY" not in keywords: return false
	return true

static func astartes_target_eligible(state: Dictionary, squad: int) -> bool:
	if not state.squads.has(squad) or G.alive(state, squad).is_empty(): return false
	for model: int in G.alive(state, squad):
		if "ADEPTUS ASTARTES" not in state.units[model].get("keywords", []): return false
	return true

static func thunderhawk_target_eligible(state: Dictionary, squad: int) -> bool:
	if not astartes_target_eligible(state, squad): return false
	var has_armour_class := false
	for model: int in G.alive(state, squad):
		var keywords: Array = state.units[model].get("keywords", [])
		if "GRAVIS" in keywords or "PHOBOS" in keywords or "TACTICUS" in keywords: has_armour_class = true
	return has_armour_class

static func _vanguard_plasma_count(state: Dictionary, squad: int, excluding: int = -1) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if member == excluding: continue
		if A.identity(state.units[member]) == "vanguard-veteran-squad-with-jump-packs" and not state.units[member].get("sergeant", false) and state.units[member].get("vanguard_pistol", "heavy-bolt-pistol") == "plasma-pistol": count += 1
	return count

static func _adjust_redemptor_option_cost(state: Dictionary, player: int, delta: int) -> String:
	return _adjust_profile_option_cost(state, player, -1, "redemptor-dreadnought", delta, "Macro Plasma Incinerator")

static func _adjust_profile_option_cost(state: Dictionary, player: int, squad: int, identity: String, delta: int, label: String) -> String:
	var training_points: Dictionary = state.get("training_points", {})
	var new_training_total := int(training_points.get(player, 0)) + delta
	var points_limit := int(state.get("points_limit", 0))
	if delta > 0 and points_limit > 0 and new_training_total > points_limit: return "The %s would exceed the admitted army's point limit." % label
	if training_points.has(player):
		training_points[player] = new_training_total
		state.training_points = training_points
	var armies: Dictionary = state.get("roster_validation", {}).get("armies", {})
	if not armies.has(player): return ""
	var construction: Dictionary = armies[player]
	var updated_total := int(construction.get("total", 0)) + delta
	var roster_points_limit := int(construction.get("points_limit", points_limit))
	if delta > 0 and roster_points_limit > 0 and updated_total > roster_points_limit: return "The %s would exceed the admitted army's point limit." % label
	construction.total = updated_total
	for index in range(construction.get("breakdown", []).size()):
		var row: Dictionary = construction.breakdown[index]
		if row.get("definition_id", "") != "40kdc:11e:adeptus-astartes:" + identity or (squad >= 0 and int(row.get("squad", squad)) != squad): continue
		row.wargear_cost = int(row.get("wargear_cost", 0)) + delta
		row.total = int(row.get("total", 0)) + delta
		construction.breakdown[index] = row
		break
	armies[player] = construction
	state.roster_validation.armies = armies
	return ""

static func spiritual_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.phase not in ["command", "movement", "shooting", "charge", "fight"]: return result
	for model: int in models(state, player, "spiritual-leader"):
		if state.unit_abilities.used.get("spiritual:%d" % model, -1) == state.round: continue
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not state.squads[squad].battle_shocked or G.alive(state, squad).is_empty(): continue
			var astartes := false
			for target: int in G.alive(state, squad):
				if str(state.units[target].get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"): astartes = true
			if astartes and G.distance_to_target(state, state.units[model], squad) <= 6.001:
				result.append(choice("Spiritual Leader %d: %s" % [model, str(state.squads[squad].name).replace(" Squad", "")], "spiritual-leader", model, squad))
	return result

static func rampart_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.phase not in ["command", "movement", "shooting", "charge", "fight"]: return result
	for model: int in models(state, player, "rampart"):
		if state.unit_abilities.used.has("rampart-used:%d" % model): continue
		result.append(choice("Darnath Lysander %d: activate Rampart (2+ invulnerable save this phase)" % model, "rampart", model))
	return result

static func librarius_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.phase not in ["movement", "shooting", "fight"]: return result
	if state.active != player: return result
	for model: int in models(state, player, "librarius"):
		var squad: int = state.units[model].squad
		if A.identity(state.units[model]) == "chief-librarian-tigurius":
			if state.squads[squad].battle_shocked: continue
			if state.phase == "movement" and not state.unit_abilities.used.has("tigurius-prescience:%d:%d" % [squad, state.turn]):
				result.append(choice("Tigurius %d: Prescience (+1 Save until your next turn)" % model, "tigurius-psychic", model, squad, "prescience"))
			elif state.phase == "shooting" and not state.unit_abilities.used.has("tigurius-telepathic:%d:%d" % [squad, state.turn]):
				for enemy: int in state.squads:
					if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
					var sight := T.targeting(state, model, enemy)
					if sight.visible and sight.distance <= 24.001:
						result.append(choice("Tigurius %d: Telepathic Assault against %s (2D3 mortal wounds)" % [model, state.squads[enemy].name], "tigurius-psychic", model, enemy, "telepathic-assault"))
			continue
		if state.squads[squad].battle_shocked or state.unit_abilities.used.has("librarius:%d:%d" % [squad, state.round]): continue
		if state.phase == "movement" and A.identity(state.units[model]) == "librarian":
			if not state.squads[squad].moved:
				result.append(choice("Librarius %d: Force Dome (4+ invulnerable save this turn)" % model, "librarius-power", model, squad, "force-dome"))
				if not FightQueue.engaged(state, squad) and not state.unit_abilities.veil_of_time_pending.has(squad):
					result.append(choice("Librarius %d: Veil of Time (change this Advance to 6)" % model, "librarius-power", model, squad, "veil-of-time"))
		elif state.phase == "shooting":
			if A.identity(state.units[model]) == "librarian-in-terminator-armour":
				if state.squads[squad].shot or Actions.shooting_blocked(state, squad): continue
				result.append(choice("Librarius %d: Thunderous Force (+6\" ranged weapon range)" % model, "librarius-power", model, squad, "thunderous-force"))
			elif A.identity(state.units[model]) == "librarian-in-phobos-armour":
				for enemy: int in state.squads:
					if state.squads[enemy].owner == player or G.alive(state, enemy).is_empty(): continue
					if T.targeting(state, model, enemy).visible:
						result.append(choice("Librarius %d: Soul Sight (ignore cover against %s this phase)" % [model, state.squads[enemy].name], "librarius-power", model, enemy, "soul-sight"))
		else:
			if A.identity(state.units[model]) == "librarian-in-terminator-armour": result.append(choice("Librarius %d: Might of Heroes (+2 melee Strength)" % model, "librarius-power", model, squad, "might-of-heroes"))
	return result

static func healing_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if state.phase != "command" or state.active != player: return result
	for model: int in models(state, player, "narthecium"):
		var squad: int = state.units[model].squad
		if state.unit_abilities.used.get("narthecium:%d" % squad, -1) != state.turn and Healing.needed(state, squad): result.append(choice("Narthecium %d: heal D3+1" % model, "narthecium", model, squad))
	for model: int in models(state, player, "helix-gauntlet"):
		var squad: int = state.units[model].squad
		if state.unit_abilities.used.get("helix:%d" % squad, -1) != state.turn and Healing.needed(state, squad): result.append(choice("Helix %d: heal D3" % model, "helix-heal", model, squad))
	for model: int in state.units:
		var bearer: Dictionary = state.units[model]
		if int(bearer.get("owner", -1)) != player or not bearer.get("on_battlefield", true): continue
		if not StormlanceEnhancements.model_active(state, model, StormlanceEnhancements.NARTHECIS_GAUNTLET): continue
		var squad := int(bearer.get("squad", -1))
		if state.unit_abilities.used.get("narthecis-gauntlet:%d" % squad, -1) != state.turn and not G.alive(state, squad).is_empty() and Healing.needed(state, squad): result.append(choice("Narthecis Gauntlet %d: heal D3+1" % model, "narthecis-gauntlet", model, squad))
	return result

static func offer_command_healing(state: Dictionary) -> bool:
	if not A.enabled(state) or healing_choices(state, state.active).is_empty(): return false
	state.unit_abilities.window = {"kind": "healing-order", "owners": [state.active]}
	return true

static func omni_choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	if not A.enabled(state) or state.phase != "shooting" or state.active != player: return result
	for squad: int in state.squads:
		var providers := A.sources(state, squad, "omni-scramblers")
		if state.squads[squad].owner != player or providers.is_empty() or state.unit_abilities.used.get("omni:%d" % squad, "") == key(state): continue
		for target: int in state.squads:
			if state.squads[target].owner == player or G.alive(state, target).is_empty(): continue
			for model: int in G.alive(state, squad):
				var sight := T.targeting(state, model, target)
				if sight.visible and sight.distance <= 18.001:
					result.append(choice("Omni %d: detect %s (+3)" % [squad, state.squads[target].name], "omni-scramblers", providers[0], target))
					break
	return result

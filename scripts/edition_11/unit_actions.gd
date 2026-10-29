extends RefCounted
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const CorvusBlackstar = preload("res://scripts/edition_11/corvus_blackstar.gd")
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
const MarineLeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
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
const NjalStormcaller = preload("res://scripts/edition_11/njal_stormcaller.gd")
const UlrikTheSlayer = preload("res://scripts/edition_11/ulrik_the_slayer.gd")
const Ezekiel = preload("res://scripts/edition_11/ezekiel.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
const Reivers = preload("res://scripts/edition_11/reivers.gd")
const Asmodai = preload("res://scripts/edition_11/asmodai.gd")
const CommanderDante = preload("res://scripts/edition_11/commander_dante.gd")
const Sanguinor = preload("res://scripts/edition_11/sanguinor.gd")
const Mephiston = preload("res://scripts/edition_11/mephiston.gd")
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
const FenrisianWolves = preload("res://scripts/edition_11/fenrisian_wolves.gd")
const SwordBrethren = preload("res://scripts/edition_11/sword_brethren.gd")
const VictrixHonourGuard = preload("res://scripts/edition_11/victrix_honour_guard.gd")
const WatchCaptainArtemis = preload("res://scripts/edition_11/watch_captain_artemis.gd")
const WulfenStormShields = preload("res://scripts/edition_11/wulfen_storm_shields.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const CrusaderSurge = preload("res://scripts/edition_11/crusader_surge.gd")
const DeathCompanyDreadnought = preload("res://scripts/edition_11/death_company_dreadnought.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const CommandBattleShock = preload("res://scripts/edition_11/command_battle_shock.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const StasisBomb = preload("res://scripts/edition_11/stasis_bomb.gd")
const HighMarshalHelbrecht = preload("res://scripts/edition_11/high_marshal_helbrecht.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const CrusadeAncient = preload("res://scripts/edition_11/crusade_ancient.gd")
const BloodAngelsCharacters = preload("res://scripts/edition_11/blood_angels_characters.gd")
const Execrator = preload("res://scripts/edition_11/execrator.gd")

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

static func open_death_visions(state: Dictionary, attacker: int) -> bool:
	return BloodAngelsCharacters.after_fight(state, attacker)

static func window_state_error(state: Dictionary) -> String:
	var kind := str(pending(state).get("kind", ""))
	if kind == HeresyRetribution.WINDOW: return HeresyRetribution.window_error(state)
	if kind in [CrusaderSurge.WINDOW, CrusaderSurge.TARGET_WINDOW, CrusaderSurge.PLACEMENT]: return CrusaderSurge.window_error(state)
	if kind in [DeathCompanyDreadnought.WINDOW, DeathCompanyDreadnought.TARGET_WINDOW, DeathCompanyDreadnought.PLACEMENT]: return DeathCompanyDreadnought.window_error(state)
	return ""

## Exhaustive discriminator set for persisted UnitActions windows handled by this dispatcher.
## Keep unknown kinds out of the generic phase-window decline path.
static func supported_window_kind(kind: String) -> bool:
	return kind in [
		"start", "end", "counter", "demi", "vehement-aggression-reroll", Mephiston.FALLBACK_WINDOW,
		"damage-reroll", "aquilon-hit", "machine-spirit-hit", "machine-spirit-wound", "armoured-wrath-hit", "armoured-wrath-wound", "martial-paragon-hit", "martial-paragon-wound", "wound", "nightforged-attack-count", "nightforged-hazard",
		DeadlyDemise.WINDOW, DetachmentStratagems.VENGEFUL_ANIMUS_WINDOW, DetachmentStratagems.LAYERED_CERAMITE_WINDOW, CorvusBlackstar.WINDOW, WulfenStormShields.WINDOW,
		"evade-and-survive", "evade-placement", CatoSicarius.WINDOW, CatoSicarius.PLACEMENT, FenrisianWolves.WINDOW, FenrisianWolves.PLACEMENT, SwordBrethren.WINDOW, SwordBrethren.PLACEMENT,
		TacticalFluidity.WINDOW, TacticalFluidity.PLACEMENT, PurgationRun.WINDOW, PurgationRun.PLACEMENT, PhobosShadowMasters.WINDOW, PhobosExecuteRedeploy.WINDOW,
		VictrixHonourGuard.WINDOW, VictrixHonourGuard.PLACEMENT, HeresyRetribution.WINDOW, CrusaderSurge.WINDOW, CrusaderSurge.TARGET_WINDOW, CrusaderSurge.PLACEMENT, DeathCompanyDreadnought.WINDOW, DeathCompanyDreadnought.TARGET_WINDOW, DeathCompanyDreadnought.PLACEMENT, "forward-assault-mark",
		CoreReactions.EXPLOSIVES, CoreReactions.CRUSHING_MORTAL, CoreReactions.CORVUS_CLUSTER_MORTAL, Hammer.MORTAL_WINDOW, CoreReactions.GRAVIS_ARMOURED_IMPACT_MORTAL, CoreReactions.WRATH_OF_THE_LION_MORTAL, CoreReactions.PHOBOS_MORTIS_SNARES_MORTAL, StasisBomb.MORTAL_WINDOW, HighMarshalHelbrecht.MORTAL_WINDOW, BloodAngelsCharacters.DEATH_VISIONS_WINDOW, BloodAngelsCharacters.DEATH_VISIONS_MORTAL, StasisBomb.RESUME_WINDOW, Hammer.ID,
		DetachmentStratagems.PHOBOS_SHADOW_MORTIS_TRIGGER_WINDOW, DetachmentStratagems.PHOBOS_SHADOW_MORTIS_DAMAGE_WINDOW,
		DetachmentStratagems.HEADHUNTER_WINDOW, DetachmentStratagems.GRAVIS_ANNIHILATING_WINDOW, DetachmentStratagems.TERMINATOR_MERCILESS_WINDOW, DetachmentStratagems.PHOBOS_STRIKE_WINDOW, DetachmentStratagems.METHODICAL_BRUTALITY_WINDOW, DetachmentStratagems.PIOUS_ENMITY_WINDOW, DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW, DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW, DetachmentStratagems.DREAD_CRUSADERS_WINDOW, DetachmentStratagems.RELENTLESS_ASSAULT_WINDOW, DetachmentStratagems.POINT_BLANK_BRUTALITY_WINDOW, DetachmentStratagems.UNSTOPPABLE_WINDOW,
		DetachmentStratagems.ARMOUR_WINDOW, DetachmentStratagems.TERMINATOR_FORTITUDE_WINDOW, DetachmentStratagems.WORTHY_WINDOW, DetachmentStratagems.DARKFLIGHT_WINDOW,
		CrusadeAncient.MARTIAL_HONOUR_WINDOW,
		"mounted-shooting-reaction", "stormlance-hurtling", DetachmentStratagems.SHOOTING_REACTION_WINDOW, "blessings-of-the-omnissiah", TargetAuguryWeb.WINDOW, AdeptOfTheOmnissiah.WINDOW,
		"healing", "healing-order", TransportRules.EMERGENCY_WINDOW, TransportRules.DISEMBARK_WINDOW, TransportRules.COMBAT_EMBARKATION_WINDOW,
		"bladeguard", "phobos-shrouding", NjalStormcaller.STORM_CALLER_WINDOW, Ezekiel.TARGET_WINDOW, Ezekiel.REROLL_WINDOW, Incursors.DIVINATOR_WINDOW, Incursors.MINE_WINDOW,
		CoreReactions.TIGURIUS_MORTAL, "scouts", "strategium-command",
		"driven-from-cover", "hailstrike", "shattered-defences", "tactics", "eternal", "ingress",
		CoreReactions.CRUSHING, DetachmentStratagems.MOVEMENT_REACTION_WINDOW
	]

static func setup_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "deployment": return -1
	for player in [1, 2]:
		if not state.unit_abilities.get("setup_players", []).has(player): return player
	return -1

static func eradicator_model_label(state: Dictionary, model: int) -> String:
	var bearer: Dictionary = state.units.get(model, {})
	if A.identity(bearer) != "eradicator-squad-with-melta-rifles": return "Eradicator"
	if bearer.get("sergeant", false): return "Eradicator Sergeant"
	var members: Array[int] = G.alive(state, int(bearer.get("squad", -1)))
	members.sort()
	var ordinal := 0
	for member: int in members:
		var unit: Dictionary = state.units[member]
		if A.identity(unit) != "eradicator-squad-with-melta-rifles" or unit.get("sergeant", false): continue
		ordinal += 1
		if member == model: return "Eradicator %d" % ordinal
	return "Eradicator"

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
	if Asmodai.actor(state) > 0: return Asmodai.actor(state)
	if CommanderDante.actor(state) > 0: return CommanderDante.actor(state)
	var window := pending(state)
	if not window.is_empty(): return int(window.owners[0])
	if Execrator.actor(state) > 0: return Execrator.actor(state)
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
	elif Asmodai.actor(state) > 0:
		timing = "fight:feared-interrogator"
	elif CommanderDante.actor(state) > 0:
		timing = "fight:death-mask-of-sanguinius"
	elif Execrator.actor(state) == owner:
		timing = "fight:condemnatory-annihilation-reroll"
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

static func _grey_hunter_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) == squad and A.identity(state.units[model]) == "grey-hunters": result.append(model)
	result.sort()
	return result

static func _headtaker_models(state: Dictionary, squad: int, role: String = "") -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != "wolf-guard-headtakers": continue
		if not role.is_empty() and str(unit.get("wolf_guard_headtaker_role", "")) != role: continue
		result.append(model)
	result.sort()
	return result

static func wolf_guard_headtakers_split_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var seen: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		var squad := int(unit.get("squad", -1))
		if int(unit.get("owner", -1)) != player or A.identity(unit) != "wolf-guard-headtakers" or squad in seen: continue
		seen.append(squad)
		if not state.squads.has(squad) or bool(state.squads[squad].get("let_loose_split", false)) or not A.has(state, squad, "let-loose-the-wolves"): continue
		var headtakers := _headtaker_models(state, squad, "wolf-guard-headtaker")
		var wolves := _headtaker_models(state, squad, "hunting-wolf")
		if headtakers.is_empty() or headtakers.size() != wolves.size(): continue
		result.append(choice("Let Loose the Wolves — split %s into %d Headtakers and %d Hunting Wolves" % [state.squads[squad].name, headtakers.size(), wolves.size()], "wolf-guard-headtakers-split", -1, squad, "split"))
	return result

static func _split_wolf_guard_headtakers(state: Dictionary, squad: int) -> String:
	if not state.squads.has(squad) or not A.has(state, squad, "let-loose-the-wolves"): return "Let Loose the Wolves requires a Wolf Guard Headtakers unit during Declare Battle Formations."
	var current_group: Dictionary = state.squads[squad]
	if bool(current_group.get("let_loose_split", false)): return "This unit has already split its Hunting Wolves."
	var headtakers := _headtaker_models(state, squad, "wolf-guard-headtaker")
	var wolves := _headtaker_models(state, squad, "hunting-wolf")
	if headtakers.is_empty() or headtakers.size() != wolves.size(): return "The split requires the source-priced equal Headtaker and Hunting Wolf composition."
	if bool(current_group.get("attached", false)):
		var bodyguard_found := false
		for component: Dictionary in current_group.get("components", []):
			if int(component.get("squad", -1)) == squad and str(component.get("role", "")) == "bodyguard": bodyguard_found = true
		if not bodyguard_found: return "Let Loose the Wolves cannot split an attached Headtakers unit without its bodyguard component record."
	var owner := int(current_group.get("owner", -1))
	var second_squad := owner
	while state.squads.has(second_squad): second_squad += 2
	var second_group: Dictionary = current_group.duplicate(true)
	var first_name := str(current_group.get("name", "Wolf Guard Headtakers")) + " — Headtakers"
	var second_name := str(current_group.get("name", "Wolf Guard Headtakers")) + " — Hunting Wolves"
	var combined_cost := int(current_group.get("training_cost", 0))
	current_group.name = first_name
	second_group.name = second_name
	current_group.let_loose_split = true
	second_group.let_loose_split = true
	current_group.training_cost = combined_cost
	second_group.training_cost = 0
	var attached := bool(current_group.get("attached", false))
	if attached:
		var kept_components: Array[Dictionary] = []
		var remaining_strength := 0
		for source_component: Dictionary in current_group.get("components", []):
			var component := source_component.duplicate(true)
			if int(component.get("squad", -1)) == squad and str(component.get("role", "")) == "bodyguard":
				component.starting_strength = headtakers.size()
				component.name = first_name
			else:
				remaining_strength += int(component.get("starting_strength", 0))
			kept_components.append(component)
		current_group.components = kept_components
		current_group.starting_strength = headtakers.size() + remaining_strength
		second_group.attached = false
		second_group.components = [{"squad": second_squad, "role": "bodyguard", "name": second_name, "starting_strength": wolves.size()}]
		second_group.starting_strength = wolves.size()
	else:
		current_group.starting_strength = headtakers.size()
		second_group.attached = false
		second_group.components = [{"squad": second_squad, "role": "bodyguard", "name": second_name, "starting_strength": wolves.size()}]
		second_group.starting_strength = wolves.size()
	var first_models := headtakers.duplicate()
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and A.identity(state.units[model]) != "wolf-guard-headtakers": first_models.append(model)
	for member: int in wolves:
		state.units[member].squad = second_squad
		state.units[member].attachment_role = "bodyguard"
		state.units[member].component_squad = second_squad
	state.squads[squad] = current_group
	var wolf_profile := MarineProfiles.wolf_guard_headtaker_model_loadout("hunting-wolf")
	second_group.stats = wolf_profile.stats.duplicate(true)
	second_group.weapon = {}
	second_group.melee_weapon = wolf_profile.melee[0].profiles.values()[0].duplicate(true)
	state.squads[second_squad] = second_group
	if not state.unit_abilities.has("let_loose_wolf_splits"): state.unit_abilities.let_loose_wolf_splits = {}
	state.unit_abilities.let_loose_wolf_splits[str(squad)] = {"owner": owner, "first_squad": squad, "second_squad": second_squad, "first_models": first_models, "second_models": wolves.duplicate()}
	return ""

static func wolf_guard_headtaker_shield_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "wolf-guard-headtakers" or str(unit.get("wolf_guard_headtaker_role", "")) != "wolf-guard-headtaker": continue
		var shield := bool(unit.get("wolf_guard_headtaker_storm_shield", false))
		result.append(choice("Wolf Guard Headtaker %d: %s" % [model, "restore Paired Master-crafted Power Weapons" if shield else "replace Paired Master-crafted Power Weapons with Master-crafted Power Weapon + Storm Shield (4+ invulnerable save)"], "wolf-guard-headtaker-storm-shield", model, int(unit.squad), "off" if shield else "on"))
	return result

static func grey_hunters_split_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var drafts: Dictionary = state.get("unit_abilities", {}).get("old_greymanes_drafts", {})
	var seen: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		var squad := int(unit.get("squad", -1))
		if int(unit.get("owner", -1)) != player or A.identity(unit) != "grey-hunters" or squad in seen: continue
		seen.append(squad)
		if not state.squads.has(squad) or bool(state.squads[squad].get("old_greymanes_split", false)): continue
		var members := _grey_hunter_models(state, squad)
		if members.size() != 10: continue
		var draft: Array = drafts.get(str(squad), [])
		for member: int in members:
			var selected := member in draft
			if selected or draft.size() < 5:
				var role := " Pack Leader" if state.units[member].get("sergeant", false) else ""
				var verb := "Remove" if selected else "Select"
				result.append(choice("Old Greymanes — Grey Hunters %d: %s model %d%s for Pack 2 (%d/5)" % [squad, verb, int(state.units[member].get("grey_hunters_model", -1)) + 1, role, draft.size()], "grey-hunters-split-toggle", member, squad, "remove" if selected else "select"))
		if not draft.is_empty(): result.append(choice("Old Greymanes — Grey Hunters %d: cancel this split draft" % squad, "old-greymanes-cancel", -1, squad, "cancel"))
		if draft.size() == 5: result.append(choice("Old Greymanes — confirm two equal Grey Hunters packs (%d)" % squad, "old-greymanes-confirm", -1, squad, "split"))
	return result

static func _split_grey_hunters(state: Dictionary, squad: int, selected_models: Array[int]) -> String:
	if not state.squads.has(squad): return "Old Greymanes requires a Grey Hunters unit during Declare Battle Formations."
	var first_models := _grey_hunter_models(state, squad)
	if first_models.size() != 10 or selected_models.size() != 5: return "Old Greymanes splits the ten Grey Hunter models into two groups of five."
	for model: int in selected_models:
		if model not in first_models: return "Every Old Greymanes selection must be a model from this Grey Hunters unit."
	var current_group: Dictionary = state.squads[squad]
	if bool(current_group.get("old_greymanes_split", false)): return "This Grey Hunters unit has already used Old Greymanes."
	if bool(current_group.get("attached", false)):
		var bodyguard_found := false
		for component: Dictionary in current_group.get("components", []):
			if int(component.get("squad", -1)) == squad and str(component.get("role", "")) == "bodyguard": bodyguard_found = true
		if not bodyguard_found: return "Old Greymanes cannot split an attached Grey Hunters unit without its bodyguard component record."
	var profile := MarineProfiles.profile("grey-hunters")
	var source_cost := int(profile.get("points", 0))
	var combined_cost := int(current_group.get("training_cost", 0))
	if source_cost != 180 or combined_cost < source_cost: return "The Grey Hunters split cannot preserve its source roster cost."
	var owner := int(current_group.get("owner", -1))
	var second_squad := owner
	while state.squads.has(second_squad): second_squad += 2
	var second_group: Dictionary = current_group.duplicate(true)
	var first_name := str(current_group.get("name", "Grey Hunters")) + " — Pack 1"
	var second_name := str(current_group.get("name", "Grey Hunters")) + " — Pack 2"
	current_group.name = first_name
	second_group.name = second_name
	current_group.old_greymanes_split = true
	second_group.old_greymanes_split = true
	current_group.training_cost = combined_cost - int(source_cost / 2)
	second_group.training_cost = int(source_cost / 2)
	if bool(current_group.get("attached", false)):
		var kept_components: Array[Dictionary] = []
		var bodyguard_found := false
		var remaining_strength := 0
		for source_component: Dictionary in current_group.get("components", []):
			var component := source_component.duplicate(true)
			if int(component.get("squad", -1)) == squad and str(component.get("role", "")) == "bodyguard":
				component.starting_strength = 5
				component.name = first_name
				bodyguard_found = true
			else:
				remaining_strength += int(component.get("starting_strength", 0))
			kept_components.append(component)
		current_group.components = kept_components
		current_group.starting_strength = 5 + remaining_strength
		second_group.attached = false
		second_group.components = [{"squad": second_squad, "role": "bodyguard", "name": second_name, "starting_strength": 5}]
		second_group.starting_strength = 5
	else:
		current_group.starting_strength = 5
		second_group.starting_strength = 5
	state.squads[squad] = current_group
	state.squads[second_squad] = second_group
	var second_models := selected_models.duplicate()
	second_models.sort()
	var first_half: Array[int] = []
	for member: int in first_models:
		if member not in second_models: first_half.append(member)
	for member: int in second_models:
		state.units[member].squad = second_squad
		if bool(current_group.get("attached", false)):
			state.units[member].attachment_role = "bodyguard"
			state.units[member].component_squad = second_squad
	state.unit_abilities.get("old_greymanes_drafts", {}).erase(str(squad))
	if not state.unit_abilities.has("old_greymanes_splits"): state.unit_abilities.old_greymanes_splits = {}
	state.unit_abilities.old_greymanes_splits[str(squad)] = {"owner": owner, "first_squad": squad, "second_squad": second_squad, "first_models": first_half, "second_models": second_models}
	return ""

static func baal_predator_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var data := MarineProfiles.profile("baal-predator")
	if data.is_empty(): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "baal-predator": continue
		var primary := str(unit.get("baal_predator_primary_cannon", "twin-assault-cannon"))
		for package: String in data.options.primary_cannon:
			if package == primary: continue
			var label := "Baal Flamestorm Cannon" if package == "baal-flamestorm-cannon" else "Twin Assault Cannon"
			result.append(choice("Baal Predator %d: select %s" % [model, label], "baal-predator-loadout", model, 0, package))
		var sponsons := str(unit.get("baal_predator_sponson_package", "none"))
		for package: String in data.options.sponson_package:
			if package == sponsons: continue
			var label := str({"none": "no sponson weapons", "heavy-bolters": "two Heavy Bolters", "heavy-flamers": "two Heavy Flamers"}.get(package, package))
			result.append(choice("Baal Predator %d: select %s" % [model, label], "baal-predator-loadout", model, 1, package))
		var storm_bolter := bool(unit.get("baal_predator_storm_bolter", false))
		result.append(choice("Baal Predator %d: %s Storm Bolter" % [model, "remove" if storm_bolter else "add"], "baal-predator-loadout", model, 2, "off" if storm_bolter else "on"))
		var missile := bool(unit.get("baal_predator_hunter_killer_missile", false))
		result.append(choice("Baal Predator %d: %s Hunter-killer Missile" % [model, "remove" if missile else "add"], "baal-predator-loadout", model, 3, "off" if missile else "on"))
	return result

static func _configure_baal_predator_loadout(state: Dictionary, player: int, model: int, category: int, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Baal Predator equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "baal-predator": return "Choose a living Baal Predator from your army."
	var profile := MarineProfiles.profile("baal-predator")
	if profile.is_empty(): return "The local Blood Angels Baal Predator profile is missing."
	var primary := str(unit.get("baal_predator_primary_cannon", "twin-assault-cannon"))
	var sponsons := str(unit.get("baal_predator_sponson_package", "none"))
	var storm_bolter := bool(unit.get("baal_predator_storm_bolter", false))
	var missile := bool(unit.get("baal_predator_hunter_killer_missile", false))
	match category:
		0:
			if value not in profile.options.primary_cannon: return "Choose a primary cannon listed on the Baal Predator datasheet."
			primary = value
		1:
			if value not in profile.options.sponson_package: return "Choose no sponsons, two Heavy Bolters or two Heavy Flamers."
			sponsons = value
		2:
			if value not in ["on", "off"]: return "Choose whether to add the Storm Bolter."
			storm_bolter = value == "on"
		3:
			if value not in ["on", "off"]: return "Choose whether to add the Hunter-killer Missile."
			missile = value == "on"
		_:
			return "Unsupported Baal Predator equipment category."
	var weapons := MarineProfiles.baal_predator_weapons(primary, sponsons, storm_bolter, missile)
	if weapons.is_empty(): return "That Baal Predator equipment combination is not present in the local datasheet profile."
	unit.baal_predator_primary_cannon = primary
	unit.baal_predator_sponson_package = sponsons
	unit.baal_predator_storm_bolter = storm_bolter
	unit.baal_predator_hunter_killer_missile = missile
	unit.ranged_weapons = weapons
	return ""

static func death_company_dreadnought_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var data := MarineProfiles.profile("death-company-dreadnought")
	if data.is_empty(): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "death-company-dreadnought": continue
		var multi_melta := bool(unit.get("death_company_twin_multi_melta", false))
		result.append(choice("Death Company Dreadnought %d: select %s" % [model, "Twin Heavy Bolter" if multi_melta else "Twin Multi-melta"], "death-company-dreadnought-loadout", model, 0, "twin-heavy-bolter" if multi_melta else "twin-multi-melta"))
		var blood_talons := bool(unit.get("death_company_blood_talons", false))
		result.append(choice("Death Company Dreadnought %d: select %s" % [model, "Blood Fists + Bolt Rifles" if blood_talons else "Blood Talons"], "death-company-dreadnought-loadout", model, 1, "blood-fists" if blood_talons else "blood-talons"))
	return result

static func space_wolves_walker_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0: continue
		var identity := A.identity(unit)
		if identity == "bjorn-the-fell-handed":
			var primary := str(unit.get("space_wolves_walker_primary", "assault-cannon"))
			for option: String in ["assault-cannon", "helfrost-cannon", "multi-melta"]:
				if option == primary: continue
				result.append(choice("Bjorn %d: replace Assault Cannon with %s" % [model, {"assault-cannon": "Assault Cannon", "helfrost-cannon": "Helfrost Cannon", "multi-melta": "Multi-melta"}[option]], "space-wolves-walker-loadout", model, 0, option))
		elif identity == "venerable-dreadnought":
			var primary := str(unit.get("space_wolves_walker_primary", "assault-cannon"))
			var secondary := str(unit.get("space_wolves_walker_secondary", "storm-bolter"))
			var melee_package := str(unit.get("space_wolves_walker_melee_package", "combat-weapon"))
			var primary_options: Array[String] = ["assault-cannon", "helfrost-cannon", "multi-melta"]
			if melee_package == "fenrisian-great-axe-blizzard-shield": primary_options = ["assault-cannon"]
			for option: String in primary_options:
				if option == primary: continue
				result.append(choice("Venerable Dreadnought %d: Assault Cannon option — %s" % [model, {"assault-cannon": "Assault Cannon", "helfrost-cannon": "Helfrost Cannon", "multi-melta": "Multi-melta"}[option]], "space-wolves-walker-loadout", model, 0, option))
			for option: String in ["storm-bolter", "heavy-flamer"]:
				if option == secondary: continue
				result.append(choice("Venerable Dreadnought %d: replace Storm Bolter with %s" % [model, "Storm Bolter" if option == "storm-bolter" else "Heavy Flamer"], "space-wolves-walker-loadout", model, 1, option))
			var melee_options: Array[String] = ["combat-weapon"]
			if primary == "assault-cannon": melee_options.append("fenrisian-great-axe-blizzard-shield")
			for option: String in melee_options:
				if option == melee_package: continue
				result.append(choice("Venerable Dreadnought %d: %s" % [model, "Assault Cannon + Combat Weapon" if option == "combat-weapon" else "Fenrisian Great Axe + Blizzard Shield"], "space-wolves-walker-loadout", model, 2, option))
		elif identity == "wulfen-dreadnought":
			var secondary := str(unit.get("space_wolves_walker_secondary", "storm-bolter"))
			var melee_package := str(unit.get("space_wolves_walker_melee_package", "fenrisian-great-axe"))
			for option: String in ["storm-bolter", "heavy-flamer"]:
				if option == secondary: continue
				result.append(choice("Wulfen Dreadnought %d: replace Storm Bolter with %s" % [model, "Storm Bolter" if option == "storm-bolter" else "Heavy Flamer"], "space-wolves-walker-loadout", model, 1, option))
			for option: String in ["fenrisian-great-axe", "blizzard-shield"]:
				if option == melee_package: continue
				result.append(choice("Wulfen Dreadnought %d: %s" % [model, "Fenrisian Great Axe" if option == "fenrisian-great-axe" else "replace Fenrisian Great Axe with Blizzard Shield"], "space-wolves-walker-loadout", model, 2, option))
	return result

static func death_company_marines_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var identity := A.identity(unit)
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or identity not in ["death-company-marines", "death-company-marines-with-jump-packs"]: continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var model_name := "Death Company Marine with Jump Pack" if identity == "death-company-marines-with-jump-packs" else "Death Company Marine"
		var current_melee := str(unit.get("death_company_melee_package", "chainsword"))
		for package: String in MarineProfiles.death_company_melee_options(identity):
			if package == current_melee or not _death_company_loadout_valid(state, squad, identity, model, package): continue
			var melee_label := str({"chainsword": "Chainsword", "bolt-rifle-fire": "Bolt Rifle Fire + Combat Blade", "eviscerator": "Eviscerator", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}.get(package, package))
			result.append(choice("%s %d: replace Chainsword with %s" % [model_name, model, melee_label], "death-company-melee-loadout", model, squad, package))
		var current_pistol := str(unit.get("death_company_pistol_package", "heavy-bolt-pistol"))
		for package: String in MarineProfiles.death_company_pistol_options(identity):
			if package == current_pistol or not _death_company_loadout_valid(state, squad, identity, model, "", package): continue
			var pistol_label := str({"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "inferno-pistol": "Inferno Pistol", "plasma-pistol": "Plasma Pistol"}.get(package, package))
			result.append(choice("%s %d: replace Heavy Bolt Pistol with %s" % [model_name, model, pistol_label], "death-company-pistol-loadout", model, squad, package))
		if identity == "death-company-marines" and current_melee == "bolt-rifle-fire":
			var has_launcher := bool(unit.get("death_company_grenade_launcher", false))
			var next_value := "off" if has_launcher else "on"
			if _death_company_loadout_valid(state, squad, identity, model, "", "", next_value):
				result.append(choice("%s %d: %s Grenade Launcher" % [model_name, model, "remove" if has_launcher else "add"], "death-company-grenade-launcher", model, squad, next_value))
	return result

static func deathwatch_veterans_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("deathwatch-veterans")
	if profile.is_empty(): return result
	var labels := {
		"default": "Boltgun + Power Weapon",
		"stalker-pattern-boltgun": "Stalker-pattern Boltgun + Knives and Fists",
		"infernus-heavy-bolter": "Infernus Heavy Bolter + Knives and Fists",
		"deathwatch-shotgun": "Deathwatch Shotgun + Knives and Fists",
		"heavy-thunder-hammer": "Heavy Thunder Hammer",
		"frag-cannon": "Frag Cannon + Knives and Fists",
		"black-shield-blades": "Black Shield Blades",
		"boltgun-storm-shield": "Boltgun + Storm Shield",
		"power-weapon-storm-shield": "Power Weapon + Storm Shield"
	}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "deathwatch-veterans": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		if unit.get("sergeant", false):
			var ranged_choice := str(unit.get("deathwatch_sergeant_ranged_loadout", "boltgun"))
			var ranged_value := "boltgun" if ranged_choice == "combi-weapon" else "combi-weapon"
			var ranged_label := "restore Boltgun" if ranged_value == "boltgun" else "replace Boltgun with Combi-weapon"
			result.append(choice("Watch Sergeant %d: %s" % [model, ranged_label], "deathwatch-sergeant-ranged-loadout", model, squad, ranged_value))
			var melee_choice := str(unit.get("deathwatch_sergeant_melee_loadout", "power-weapon"))
			var melee_value := "power-weapon" if melee_choice == "xenophase-blade" else "xenophase-blade"
			var melee_label := "restore Power Weapon" if melee_value == "power-weapon" else "replace Power Weapon with Xenophase Blade"
			result.append(choice("Watch Sergeant %d: %s" % [model, melee_label], "deathwatch-sergeant-melee-loadout", model, squad, melee_value))
			continue
		var current := str(unit.get("deathwatch_veteran_loadout", "default"))
		for package: String in profile.options.veteran_loadouts:
			if package == current or not _deathwatch_veteran_loadout_valid(state, squad, model, package): continue
			result.append(choice("Deathwatch Veteran %d: %s" % [model, labels.get(package, package)], "deathwatch-veteran-loadout", model, squad, package))
	return result

static func _deathwatch_veteran_loadout_valid(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if not state.squads.has(squad) or int(state.squads[squad].get("starting_strength", 0)) not in [5, 10]: return false
	var profile := MarineProfiles.profile("deathwatch-veterans")
	var options: Array = profile.get("options", {}).get("veteran_loadouts", [])
	if next_loadout not in options: return false
	var counts: Dictionary = {}
	var found_changed := false
	for model: int in G.alive(state, squad):
		var unit: Dictionary = state.units[model]
		if A.identity(unit) != "deathwatch-veterans" or unit.get("sergeant", false): continue
		var loadout := str(unit.get("deathwatch_veteran_loadout", "default"))
		if model == changed_model:
			loadout = next_loadout
			found_changed = true
		if loadout not in options: return false
		counts[loadout] = int(counts.get(loadout, 0)) + 1
	if not found_changed: return false
	var blocks := int(state.squads[squad].starting_strength / 5.0)
	for package: String in ["stalker-pattern-boltgun", "infernus-heavy-bolter", "frag-cannon"]:
		if int(counts.get(package, 0)) > blocks: return false
	for package: String in ["deathwatch-shotgun", "heavy-thunder-hammer"]:
		if int(counts.get(package, 0)) > 2 * blocks: return false
	if int(counts.get("black-shield-blades", 0)) > 1: return false
	var storm_shields := int(counts.get("boltgun-storm-shield", 0)) + int(counts.get("power-weapon-storm-shield", 0))
	return storm_shields <= 2 * blocks

static func _configure_deathwatch_veteran_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Deathwatch equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "deathwatch-veterans":
		return "Choose a living Deathwatch Veterans model from your army."
	var is_sergeant := bool(unit.get("sergeant", false))
	var loadout := str(unit.get("deathwatch_veteran_loadout", "default"))
	var sergeant_ranged := str(unit.get("deathwatch_sergeant_ranged_loadout", "boltgun"))
	var sergeant_melee := str(unit.get("deathwatch_sergeant_melee_loadout", "power-weapon"))
	match action:
		"deathwatch-veteran-loadout":
			if is_sergeant or value not in MarineProfiles.profile("deathwatch-veterans").options.veteran_loadouts: return "Choose a Veteran loadout listed on the Deathwatch Veterans datasheet."
			if not _deathwatch_veteran_loadout_valid(state, squad, model, value): return "That choice would exceed a per-five-model Deathwatch Veterans equipment limit."
			loadout = value
		"deathwatch-sergeant-ranged-loadout":
			if not is_sergeant or value not in ["boltgun", "combi-weapon"]: return "Only the Watch Sergeant can choose a Boltgun or Combi-weapon."
			sergeant_ranged = value
		"deathwatch-sergeant-melee-loadout":
			if not is_sergeant or value not in ["power-weapon", "xenophase-blade"]: return "Only the Watch Sergeant can choose a Power Weapon or Xenophase Blade."
			sergeant_melee = value
		_:
			return "Unsupported Deathwatch Veterans equipment choice."
	var weapons := MarineProfiles.deathwatch_veteran_weapons(is_sergeant, loadout, sergeant_ranged, sergeant_melee)
	if weapons.is_empty(): return "That Deathwatch Veterans equipment combination is not present in the local datasheet profile."
	unit.deathwatch_veteran_loadout = loadout
	unit.deathwatch_sergeant_ranged_loadout = sergeant_ranged
	unit.deathwatch_sergeant_melee_loadout = sergeant_melee
	unit.deathwatch_veteran_storm_shield = not is_sergeant and loadout in ["boltgun-storm-shield", "power-weapon-storm-shield"]
	unit.ranged_weapons = weapons.ranged
	unit.melee_weapons = weapons.melee
	return ""

static func _configure_death_company_dreadnought_loadout(state: Dictionary, player: int, model: int, category: int, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Death Company Dreadnought equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "death-company-dreadnought": return "Choose a living Death Company Dreadnought from your army."
	var multi_melta := bool(unit.get("death_company_twin_multi_melta", false))
	var blood_talons := bool(unit.get("death_company_blood_talons", false))
	match category:
		0:
			if value not in ["twin-heavy-bolter", "twin-multi-melta"]: return "Choose the Twin Heavy Bolter or Twin Multi-melta listed on the Death Company Dreadnought datasheet."
			multi_melta = value == "twin-multi-melta"
		1:
			if value not in ["blood-fists", "blood-talons"]: return "Choose Blood Fists with Bolt Rifles or Blood Talons from the datasheet."
			blood_talons = value == "blood-talons"
		_:
			return "Unsupported Death Company Dreadnought equipment category."
	var weapons := MarineProfiles.death_company_dreadnought_weapons(multi_melta, blood_talons)
	if weapons.is_empty(): return "That Death Company Dreadnought equipment combination is not present in the local datasheet profile."
	unit.death_company_twin_multi_melta = multi_melta
	unit.death_company_blood_talons = blood_talons
	unit.ranged_weapons = weapons.ranged
	unit.melee_weapons = weapons.melee
	return ""

static func _configure_space_wolves_walker_loadout(state: Dictionary, player: int, model: int, category: int, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Space Wolves Dreadnought equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	var identity := A.identity(unit)
	if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or identity not in ["bjorn-the-fell-handed", "venerable-dreadnought", "wulfen-dreadnought"]: return "Choose a living Space Wolves Dreadnought from your army."
	var primary := str(unit.get("space_wolves_walker_primary", "assault-cannon"))
	var secondary := str(unit.get("space_wolves_walker_secondary", "storm-bolter"))
	var melee_package := str(unit.get("space_wolves_walker_melee_package", "combat-weapon" if identity == "venerable-dreadnought" else "fenrisian-great-axe"))
	match identity:
		"bjorn-the-fell-handed":
			if category != 0 or value not in ["assault-cannon", "helfrost-cannon", "multi-melta"]: return "Choose an Assault Cannon, Helfrost Cannon or Multi-melta for Bjorn."
			primary = value
		"venerable-dreadnought":
			match category:
				0:
					if value not in ["assault-cannon", "helfrost-cannon", "multi-melta"]: return "Choose an Assault Cannon, Helfrost Cannon or Multi-melta."
					primary = value
				1:
					if value not in ["storm-bolter", "heavy-flamer"]: return "Choose a Storm Bolter or Heavy Flamer."
					secondary = value
				2:
					if value not in ["combat-weapon", "fenrisian-great-axe-blizzard-shield"]: return "Choose the Combat Weapon or Fenrisian Great Axe with Blizzard Shield package."
					melee_package = value
				_:
					return "Unsupported Venerable Dreadnought equipment category."
		"wulfen-dreadnought":
			match category:
				1:
					if value not in ["storm-bolter", "heavy-flamer"]: return "Choose a Storm Bolter or Heavy Flamer."
					secondary = value
				2:
					if value not in ["fenrisian-great-axe", "blizzard-shield"]: return "Choose the Fenrisian Great Axe or Blizzard Shield."
					melee_package = value
				_:
					return "Unsupported Wulfen Dreadnought equipment category."
	var weapons := MarineProfiles.space_wolves_walker_weapons(identity, primary, secondary, melee_package)
	if weapons.is_empty(): return "That equipment combination is not listed on this Space Wolves Dreadnought datasheet."
	unit.space_wolves_walker_primary = primary
	unit.space_wolves_walker_secondary = secondary
	unit.space_wolves_walker_melee_package = melee_package
	unit.space_wolves_blizzard_shield = bool(weapons.blizzard_shield)
	unit.ranged_weapons = weapons.ranged
	unit.melee_weapons = weapons.melee
	return ""

static func _death_company_loadout_valid(state: Dictionary, squad: int, identity: String, changed_model: int = -1, melee_replacement: String = "", pistol_replacement: String = "", grenade_replacement: Variant = null) -> bool:
	if not state.squads.has(squad): return false
	var melee_packages: Array[String] = []
	var pistol_packages: Array[String] = []
	var grenade_launchers: Array[bool] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != identity: continue
		var melee_package := str(unit.get("death_company_melee_package", "chainsword"))
		var pistol_package := str(unit.get("death_company_pistol_package", "heavy-bolt-pistol"))
		var grenade_launcher := bool(unit.get("death_company_grenade_launcher", false))
		if model == changed_model:
			if not melee_replacement.is_empty(): melee_package = melee_replacement
			if not pistol_replacement.is_empty(): pistol_package = pistol_replacement
			if grenade_replacement != null: grenade_launcher = str(grenade_replacement) == "on"
		melee_packages.append(melee_package)
		pistol_packages.append(pistol_package)
		grenade_launchers.append(grenade_launcher)
	return MarineProfiles.death_company_loadout_limits_valid(identity, melee_packages.size(), melee_packages, pistol_packages, grenade_launchers)

static func _configure_death_company_marine_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Death Company equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	var identity := A.identity(unit)
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or identity not in ["death-company-marines", "death-company-marines-with-jump-packs"]:
		return "Choose a living Death Company Marines model from your army."
	var melee_package := str(unit.get("death_company_melee_package", "chainsword"))
	var pistol_package := str(unit.get("death_company_pistol_package", "heavy-bolt-pistol"))
	var grenade_launcher := bool(unit.get("death_company_grenade_launcher", false))
	match action:
		"death-company-melee-loadout":
			if value not in MarineProfiles.death_company_melee_options(identity): return "Choose a melee replacement listed on this Death Company datasheet."
			melee_package = value
		"death-company-pistol-loadout":
			if value not in MarineProfiles.death_company_pistol_options(identity): return "Choose a pistol replacement listed on this Death Company datasheet."
			pistol_package = value
		"death-company-grenade-launcher":
			if identity != "death-company-marines" or melee_package != "bolt-rifle-fire" or value not in ["on", "off"]: return "The Grenade Launcher is available only to a Death Company Marine equipped with Bolt Rifle Fire."
			grenade_launcher = value == "on"
		_:
			return "Unsupported Death Company equipment choice."
	if not _death_company_loadout_valid(state, squad, identity, model, melee_package if action == "death-company-melee-loadout" else "", pistol_package if action == "death-company-pistol-loadout" else "", ("on" if grenade_launcher else "off") if action == "death-company-grenade-launcher" else null):
		return "That choice would exceed a source-listed Death Company replacement limit."
	var weapons := MarineProfiles.death_company_model_weapons(identity, melee_package, pistol_package, grenade_launcher)
	if weapons.is_empty(): return "That Death Company equipment combination is not present in the local datasheet profile."
	unit.death_company_melee_package = melee_package
	unit.death_company_pistol_package = pistol_package
	unit.death_company_grenade_launcher = grenade_launcher
	unit.ranged_weapons = weapons.ranged
	unit.melee_weapons = weapons.melee
	return ""

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

static func ingress_round_allowed(state: Dictionary, squad: int) -> bool:
	return StormlanceEnhancements.ingress_round_allowed(state, squad) or A.high_king_fenris_selected(state, squad)

static func is_support_identity(state: Dictionary, unit: Dictionary) -> bool:
	var calgar_in_army := LeaderCatalog.army_has_calgar(state, int(unit.get("owner", -1)))
	return Supports.is_support_identity(A.identity(unit), calgar_in_army)

static func _component_starting_strength(state: Dictionary, unit: Dictionary) -> int:
	var squad := int(unit.get("squad", -1))
	if not state.squads.has(squad): return 0
	var component := int(unit.get("component_squad", squad))
	for record: Dictionary in state.squads[squad].get("components", []):
		if int(record.get("squad", -1)) == component: return int(record.get("starting_strength", 0))
	return int(state.squads[squad].get("starting_strength", 0))

static func guilliman_model(state: Dictionary, player: int) -> int:
	for model: int in state.units:
		if state.units[model].owner == player and A.identity(state.units[model]) == "roboute-guilliman": return model
	return -1

static func lion_model(state: Dictionary, player: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == player and A.identity(state.units[model]) == "lion-eljonson": return model
	return -1

static func _strategic_reserve_capacity_error(state: Dictionary, player: int, squad: int) -> String:
	if not state.squads.has(squad) or int(state.squads[squad].get("owner", -1)) != player: return "Strategic Reserves require a friendly unit."
	var cost := int(state.squads[squad].get("training_cost", 0))
	if cost <= 0: return "The unit is missing its admitted reserve cost."
	var spent := 0
	for reserved: Variant in state.unit_abilities.get("reserves", {}):
		if state.squads.has(int(reserved)) and int(state.squads[int(reserved)].get("owner", -1)) == player:
			spent += int(state.unit_abilities.reserves[reserved].get("cost", 0))
	if spent + cost > int(state.get("points_limit", 500)) / 2: return "Strategic reserves cannot exceed half the battle points limit."
	return ""

static func _complete_lion_primarch_choice(state: Dictionary, player: int, model: int, squad: int) -> String:
	var pending: Array = state.unit_abilities.get("lion_primarch_pending", {}).get(squad, [])
	if pending.is_empty(): return "Select at least one Primarch of the First Legion ability before confirming."
	if not A.sources(state, squad, "primarch-of-the-first-legion").has(model) or int(state.squads[squad].get("owner", -1)) != player: return "Primarch of the First Legion belongs to a living Lion El’jonson in your army."
	if "mist-wreathed-shadow-realms" in pending:
		if FightQueue.engaged(state, squad) or not state.units[model].get("on_battlefield", true): return "Mist-wreathed Shadow Realms requires Lion’s unit to be on the battlefield and unengaged."
		var reserve_error := _strategic_reserve_capacity_error(state, player, squad)
		if not reserve_error.is_empty(): return reserve_error
	if not state.unit_abilities.has("lion_primarch"): state.unit_abilities.lion_primarch = {}
	state.unit_abilities.lion_primarch[squad] = {"abilities": pending.duplicate(), "owner": player, "turn": int(state.turn)}
	state.unit_abilities.used["lion-primarch:%d" % squad] = state.turn
	state.unit_abilities.lion_primarch_pending.erase(squad)
	if "mist-wreathed-shadow-realms" in pending:
		var cost := int(state.squads[squad].get("training_cost", 0))
		if not state.unit_abilities.has("reserves"): state.unit_abilities.reserves = {}
		state.unit_abilities.reserves[squad] = {"cost": cost, "source": "mist-wreathed-shadow-realms", "deep_strike": true, "ingress_turn": int(state.turn)}
		for unit: Dictionary in state.units.values():
			if int(unit.get("squad", -1)) == squad: unit.on_battlefield = false
		state.deployment.order.erase(squad)
	return ""

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
	var profile := MarineProfiles.profile(A.identity(unit))
	unit.ranged_weapons = profile.ranged.duplicate(true)
	unit.melee_weapons = profile.melee.duplicate(true)
	if A.identity(unit) == "deathwatch-terminator-squad":
		var package := str(unit.get("deathwatch_terminator_melee_package", "power-fist"))
		var replacement_id := ""
		match package:
			"storm-bolter-chainfist": replacement_id = "chainfist"
			"storm-bolter-power-weapon": replacement_id = "power-weapon"
			"thunder-hammer-storm-shield": replacement_id = "thunder-hammer"
			"twin-lightning-claws": replacement_id = "twin-lightning-claws"
		if not replacement_id.is_empty():
			unit.melee_weapons = unit.melee_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "power-fist")
			var melee_replacement := _intercessor_additional_weapon(profile, "melee", replacement_id)
			if not melee_replacement.is_empty(): unit.melee_weapons.append(melee_replacement)
		if package in ["thunder-hammer-storm-shield", "twin-lightning-claws"]:
			unit.ranged_weapons.clear()
		var deathwatch_special := str(unit.get("terminator_special_weapon", ""))
		if deathwatch_special in ["assault-cannon", "heavy-flamer", "plasma-cannon"]:
			unit.ranged_weapons = unit.ranged_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "storm-bolter")
		var deathwatch_ranged_replacement := _intercessor_additional_weapon(profile, "ranged", deathwatch_special)
		if not deathwatch_ranged_replacement.is_empty(): unit.ranged_weapons.append(deathwatch_ranged_replacement)
		return
	var melee_choice: String = unit.get("terminator_melee_choice", "power-fist")
	if melee_choice != "power-fist":
		unit.melee_weapons = unit.melee_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "power-fist")
		var replacement := _intercessor_additional_weapon(profile, "melee", melee_choice)
		if not replacement.is_empty(): unit.melee_weapons.append(replacement)
	var special: String = unit.get("terminator_special_weapon", "")
	if special in ["assault-cannon", "heavy-flamer", "plasma-cannon"]:
		unit.ranged_weapons = unit.ranged_weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "storm-bolter")
	var replacement := _intercessor_additional_weapon(profile, "ranged", special)
	if not replacement.is_empty(): unit.ranged_weapons.append(replacement)

static func _terminator_special_count(state: Dictionary, squad: int) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) in ["terminator-squad", "deathwing-terminator-squad", "deathwatch-terminator-squad"] and not state.units[member].get("sergeant", false) and not str(state.units[member].get("terminator_special_weapon", "")).is_empty(): count += 1
	return count

static func _wolf_guard_terminator_special_count(state: Dictionary, squad: int, skip_model: int = -1) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if member != skip_model and A.identity(state.units[member]) == "wolf-guard-terminators" and str(state.units[member].get("wolf_guard_terminator_loadout", "default")) == "assault-cannon-power-fist": count += 1
	return count

static func _wolf_guard_terminator_loadout_valid(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if not state.squads.has(squad) or not state.units.has(changed_model) or int(state.squads[squad].get("starting_strength", 0)) not in [5, 10]: return false
	var bearer: Dictionary = state.units[changed_model]
	if int(bearer.get("squad", -1)) != squad or A.identity(bearer) != "wolf-guard-terminators": return false
	var is_pack_leader := bool(bearer.get("sergeant", false))
	var profile := MarineProfiles.profile("wolf-guard-terminators")
	var options: Array = profile.get("options", {}).get("pack_leader_loadouts" if is_pack_leader else "terminator_loadouts", [])
	if next_loadout not in options: return false
	if next_loadout == "assault-cannon-power-fist" and _wolf_guard_terminator_special_count(state, squad, changed_model) >= int(state.squads[squad].get("starting_strength", 0)) / 5: return false
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) != "wolf-guard-terminators": return false
	return true

static func wolf_guard_terminator_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var labels := {"default": "Storm Bolter + Master-crafted Power Weapon", "storm-shield": "Storm Shield (+1 Wound, +5 points)", "assault-cannon-power-fist": "Assault Cannon + Power Fist", "relic-greataxe": "Relic Greataxe", "twin-lightning-claws": "Twin Lightning Claws"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "wolf-guard-terminators": continue
		var squad := int(unit.get("squad", -1))
		var current := str(unit.get("wolf_guard_terminator_loadout", "default"))
		var options: Array = MarineProfiles.profile("wolf-guard-terminators").options.pack_leader_loadouts if unit.get("sergeant", false) else MarineProfiles.profile("wolf-guard-terminators").options.terminator_loadouts
		for next_loadout: String in options:
			if next_loadout == current or not _wolf_guard_terminator_loadout_valid(state, squad, model, next_loadout): continue
			var role := "Pack Leader" if unit.get("sergeant", false) else "Terminator"
			result.append(choice("Wolf Guard %s %d: %s" % [role, model, labels[next_loadout]], "wolf-guard-terminator-loadout", model, squad, next_loadout))
	return result

static func wolf_guard_battle_leader_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var profile := MarineProfiles.profile("wolf-guard-battle-leader")
	if profile.is_empty(): return result
	var ranged_labels := {"plasma-pistol": "Plasma Pistol", "storm-shield": "Storm Shield (+1 Wound)"}
	var melee_labels := {"master-crafted-power-weapon": "Master-crafted Power Weapon", "thunder-hammer": "Thunder Hammer"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "wolf-guard-battle-leader": continue
		var squad := int(unit.get("squad", -1))
		var ranged_current := str(unit.get("wolf_guard_battle_leader_ranged_loadout", "plasma-pistol"))
		var melee_current := str(unit.get("wolf_guard_battle_leader_melee_loadout", "master-crafted-power-weapon"))
		for next_loadout: String in profile.options.ranged_loadouts:
			if next_loadout == ranged_current: continue
			result.append(choice("Wolf Guard Battle Leader %d: %s" % [model, ranged_labels[next_loadout]], "wolf-guard-battle-leader-ranged", model, squad, next_loadout))
		for next_loadout: String in profile.options.melee_loadouts:
			if next_loadout == melee_current: continue
			result.append(choice("Wolf Guard Battle Leader %d: %s" % [model, melee_labels[next_loadout]], "wolf-guard-battle-leader-melee", model, squad, next_loadout))
	return result

static func _thunderwolf_plasma_pistol_count(state: Dictionary, squad: int, skip_model: int = -1) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if member != skip_model and A.identity(state.units[member]) == "thunderwolf-cavalry" and str(state.units[member].get("thunderwolf_cavalry_loadout", "default")) == "plasma-pistol": count += 1
	return count

static func _thunderwolf_cavalry_loadout_valid(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if not state.squads.has(squad) or not state.units.has(changed_model) or int(state.squads[squad].get("starting_strength", 0)) not in [3, 6]: return false
	var bearer: Dictionary = state.units[changed_model]
	if int(bearer.get("squad", -1)) != squad or A.identity(bearer) != "thunderwolf-cavalry": return false
	var profile := MarineProfiles.profile("thunderwolf-cavalry")
	var options: Array = profile.get("options", {}).get("loadouts", [])
	if next_loadout not in options: return false
	if next_loadout == "plasma-pistol" and _thunderwolf_plasma_pistol_count(state, squad, changed_model) >= int(state.squads[squad].starting_strength / 3): return false
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) != "thunderwolf-cavalry": return false
	return true

static func thunderwolf_cavalry_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var labels := {"default": "Bolt Pistol", "plasma-pistol": "Plasma Pistol", "boltgun-storm-shield": "Boltgun + Storm Shield (+5 points, 4+ invulnerable save)"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "thunderwolf-cavalry": continue
		var squad := int(unit.get("squad", -1))
		var current := str(unit.get("thunderwolf_cavalry_loadout", "default"))
		for next_loadout: String in MarineProfiles.profile("thunderwolf-cavalry").options.loadouts:
			if next_loadout == current or not _thunderwolf_cavalry_loadout_valid(state, squad, model, next_loadout): continue
			var role := "Pack Leader" if bool(unit.get("sergeant", false)) else "Cavalry"
			result.append(choice("Thunderwolf %s %d: %s" % [role, model, labels[next_loadout]], "thunderwolf-cavalry-loadout", model, squad, next_loadout))
	return result

static func _wulfen_loadout_valid(state: Dictionary, squad: int, model: int, next_loadout: String) -> bool:
	if not state.squads.has(squad) or not state.units.has(model) or int(state.squads[squad].get("starting_strength", 0)) not in [5, 10]: return false
	var bearer: Dictionary = state.units[model]
	var identity := A.identity(bearer)
	if int(bearer.get("squad", -1)) != squad or identity not in ["wulfen", "wulfen-with-storm-shields"]: return false
	return next_loadout in MarineProfiles.profile(identity).get("options", {}).get("loadouts", [])

static func wulfen_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var labels := {"death-totem": "Death Totem (melee hit re-rolls)", "stormfrag-auto-launcher": "Stormfrag Auto-launcher (replace Death Totem)"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var identity := A.identity(unit)
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or identity not in ["wulfen", "wulfen-with-storm-shields"]: continue
		var profile := MarineProfiles.profile(identity)
		if profile.is_empty(): continue
		var squad := int(unit.get("squad", -1))
		var default_loadout := "death-totem" if identity == "wulfen" else "stormfrag-auto-launcher"
		var current := str(unit.get("wulfen_loadout", default_loadout))
		for next_loadout: String in profile.options.loadouts:
			if next_loadout == current or not _wulfen_loadout_valid(state, squad, model, next_loadout): continue
			var label: String = "Death Totem (replace Stormfrag Auto-launcher)" if identity == "wulfen-with-storm-shields" and next_loadout == "death-totem" else labels[next_loadout]
			result.append(choice("%s %d: %s" % ["Wulfen with Storm Shield" if identity == "wulfen-with-storm-shields" else "Wulfen", model, label], "wulfen-loadout", model, squad, next_loadout))
	return result

static func _wolf_scouts_model_has_plasma_pistol(unit: Dictionary) -> bool:
	for weapon: Dictionary in unit.get("ranged_weapons", []):
		if str(weapon.get("id", "")) == "plasma-pistol": return true
	return false

static func _wolf_scouts_loadout_valid(state: Dictionary, squad: int, changed_model: int, next_loadout: String) -> bool:
	if not state.squads.has(squad) or int(state.squads[squad].get("starting_strength", 0)) not in [6, 12]: return false
	var profile := MarineProfiles.profile("wolf-scouts")
	var options: Array = profile.get("options", {}).get("wolf_scout_loadouts", [])
	if next_loadout not in options: return false
	var counts: Dictionary = {}
	var changed_found := false
	for member: int in state.units:
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != "wolf-scouts" or str(unit.get("wolf_scouts_role", "")) != "Wolf Scout": continue
		var loadout := str(unit.get("wolf_scouts_loadout", "default"))
		if member == changed_model:
			loadout = next_loadout
			changed_found = true
		if loadout not in options: return false
		counts[loadout] = int(counts.get(loadout, 0)) + 1
	if not changed_found: return false
	var special_count := int(counts.get("bolt-pistol", 0)) + int(counts.get("runic-stave", 0)) + int(counts.get("thunderclap", 0))
	if special_count > int(profile.options.special_replacements_per_unit): return false
	if int(counts.get("instigator-bolt-carbine", 0)) > int(state.squads[squad].starting_strength / 12.0) * int(profile.options.instigator_carbine_per_12_models): return false
	return int(counts.get("plasma-gun", 0)) <= int(profile.options.plasma_gun_per_unit)

static func wolf_scouts_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	var profile := MarineProfiles.profile("wolf-scouts")
	if profile.is_empty(): return result
	var labels := {"default": "restore Plasma Pistol + Combat Knife", "bolt-pistol": "Bolt Pistol (replaces both weapons)", "runic-stave": "Runic Stave (replaces both weapons)", "thunderclap": "Thunderclap (replaces both weapons)", "instigator-bolt-carbine": "Instigator Bolt Carbine", "plasma-gun": "Plasma Gun"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "wolf-scouts": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var role := str(unit.get("wolf_scouts_role", ""))
		if role == "Wolf Scout":
			var current := str(unit.get("wolf_scouts_loadout", "default"))
			for package: String in profile.options.wolf_scout_loadouts:
				if package == current or not _wolf_scouts_loadout_valid(state, squad, model, package): continue
				result.append(choice("Wolf Scout %d: %s" % [model, labels.get(package, package)], "wolf-scouts-loadout", model, squad, package))
		if role in ["Wolf Scout Pack Leader", "Wolf Scout"] and (_wolf_scouts_model_has_plasma_pistol(unit) or bool(unit.get("wolf_scouts_haywire_mine", false))):
			var has_mine := bool(unit.get("wolf_scouts_haywire_mine", false))
			if has_mine:
				result.append(choice("Wolf Scout %d: remove Haywire Mine" % model, "wolf-scouts-haywire-mine", model, squad, "off"))
			elif not state.units.values().any(func(member: Dictionary) -> bool: return int(member.get("squad", -1)) == squad and bool(member.get("wolf_scouts_haywire_mine", false))):
				result.append(choice("Wolf Scout %d: equip Haywire Mine" % model, "wolf-scouts-haywire-mine", model, squad, "on"))
	return result

static func _configure_wolf_scouts_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var model := int(selected.get("model", -1))
	var squad := int(selected.get("target", -1))
	var bearer: Dictionary = state.units.get(model, {})
	if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != squad or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "wolf-scouts": return {"error": "Wolf Scouts equipment is selected during your army preparations."}
	var role := str(bearer.get("wolf_scouts_role", ""))
	if selected.action == "wolf-scouts-loadout":
		var next_loadout := str(selected.get("value", ""))
		if role != "Wolf Scout" or not _wolf_scouts_loadout_valid(state, squad, model, next_loadout): return {"error": "Choose a Wolf Scout replacement listed on its datasheet and within the model-count limits."}
		if bool(bearer.get("wolf_scouts_haywire_mine", false)) and next_loadout != "default": return {"error": "Remove the Haywire Mine before replacing this model's Plasma Pistol."}
		var weapons := MarineProfiles.wolf_scouts_model_loadout(int(bearer.wolf_scouts_model), int(state.squads[squad].starting_strength), next_loadout)
		if weapons.is_empty(): return {"error": "That Wolf Scout option has no source-matched weapon profile."}
		bearer.wolf_scouts_loadout = next_loadout
		bearer.ranged_weapons = weapons.ranged
		bearer.melee_weapons = weapons.melee
		return {"error": ""}
	if selected.action != "wolf-scouts-haywire-mine" or role not in ["Wolf Scout Pack Leader", "Wolf Scout"]: return {"error": "Choose the Wolf Scout model and equipment option shown in your preparations."}
	var equipped := bool(bearer.get("wolf_scouts_haywire_mine", false))
	var value := str(selected.get("value", ""))
	if value == "on":
		if equipped or not _wolf_scouts_model_has_plasma_pistol(bearer): return {"error": "Haywire Mine can be equipped only by a model that still has its Plasma Pistol."}
		for member: int in state.units:
			if int(state.units[member].get("squad", -1)) == squad and bool(state.units[member].get("wolf_scouts_haywire_mine", false)): return {"error": "A Wolf Scout unit can equip only one Haywire Mine."}
	elif value == "off":
		if not equipped: return {"error": "This model does not have a Haywire Mine to remove."}
	else:
		return {"error": "Choose to equip or remove the Haywire Mine."}
	bearer.wolf_scouts_haywire_mine = value == "on"
	return {"error": ""}

static func _deathwatch_terminator_keeps_storm_bolter(package: String) -> bool:
	return package in ["power-fist", "storm-bolter-chainfist", "storm-bolter-power-weapon"]

static func _deathwatch_terminator_special_limit(state: Dictionary, squad: int) -> int:
	return mini(3, maxi(0, int(state.squads[squad].get("starting_strength", 0)) - 1))

static func deathwatch_terminator_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("deathwatch-terminator-squad")
	if profile.is_empty(): return result
	var labels := {
		"power-fist": "Power Fist + Storm Bolter",
		"storm-bolter-chainfist": "Storm Bolter + Chainfist",
		"storm-bolter-power-weapon": "Storm Bolter + Power Weapon",
		"thunder-hammer-storm-shield": "Thunder Hammer + Storm Shield (+1 Wound)",
		"twin-lightning-claws": "Twin Lightning Claws"
	}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "deathwatch-terminator-squad": continue
		var squad := int(unit.get("squad", -1))
		var current_package := str(unit.get("deathwatch_terminator_melee_package", "power-fist"))
		for package: String in profile.get("options", {}).get("melee_packages", []):
			if package != current_package and _deathwatch_terminator_loadout_valid(state, squad, model, package):
				result.append(choice("Deathwatch Terminator %d: %s" % [model, str(labels.get(package, package))], "deathwatch-terminator-loadout", model, squad, package))
	return result

static func _deathwatch_terminator_loadout_valid(state: Dictionary, squad: int, changed_model: int, next_package: String) -> bool:
	if not state.squads.has(squad) or not state.units.has(changed_model) or int(state.squads[squad].get("starting_strength", 0)) not in [5, 10]: return false
	var options: Array = MarineProfiles.profile("deathwatch-terminator-squad").get("options", {}).get("melee_packages", [])
	if next_package not in options: return false
	if not _deathwatch_terminator_keeps_storm_bolter(next_package) and not str(state.units[changed_model].get("terminator_special_weapon", "")).is_empty(): return false
	for model: int in G.alive(state, squad):
		if model != changed_model and A.identity(state.units[model]) != "deathwatch-terminator-squad": return false
	return A.identity(state.units[changed_model]) == "deathwatch-terminator-squad"

static func fortis_kill_team_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("fortis-kill-team")
	if profile.is_empty(): return result
	var sergeant_melee_options: Array = ["knives-and-fists"] + profile.options.sergeant_melee_replacements
	var sergeant_melee_labels := {"knives-and-fists": "Knives and Fists", "chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}
	var sergeant_ranged_options: Array = ["deathwatch-bolt-rifle"] + profile.options.sergeant_ranged_replacements
	var sergeant_ranged_labels := {"deathwatch-bolt-rifle": "Deathwatch Bolt Rifle", "chainsword": "Chainsword", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol", "power-weapon": "Power Weapon"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "fortis-kill-team": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var model_index := int(unit.get("fortis_kill_team_model", -1))
		if model_index == 1:
			var melee_choice := str(unit.get("fortis_kill_team_sergeant_melee", "knives-and-fists"))
			for option: String in sergeant_melee_options:
				if option != melee_choice:
					result.append(choice("Fortis Kill Team Sergeant %d: %s" % [model, str(sergeant_melee_labels.get(option, option))], "fortis-sergeant-melee", model, squad, option))
			var ranged_choice := str(unit.get("fortis_kill_team_sergeant_ranged", "deathwatch-bolt-rifle"))
			if not unit.get("fortis_kill_team_grenade_launcher", false):
				for option: String in sergeant_ranged_options:
					if option != ranged_choice:
						result.append(choice("Fortis Kill Team Sergeant %d: replace Deathwatch Bolt Rifle with %s" % [model, str(sergeant_ranged_labels.get(option, option))], "fortis-sergeant-ranged", model, squad, option))
		if model_index in [1, 4, 5]:
			var grenade_equipped := bool(unit.get("fortis_kill_team_grenade_launcher", false))
			var grenade_limit := int(_component_starting_strength(state, unit) / 5.0)
			var grenade_count := 0
			for member: int in G.alive(state, squad):
				if A.identity(state.units[member]) == "fortis-kill-team" and state.units[member].get("fortis_kill_team_grenade_launcher", false): grenade_count += 1
			var can_take_rifle_grenade := model_index != 1 or str(unit.get("fortis_kill_team_sergeant_ranged", "deathwatch-bolt-rifle")) == "deathwatch-bolt-rifle"
			if grenade_equipped or (can_take_rifle_grenade and grenade_count < grenade_limit):
				result.append(choice("Fortis Kill Team model %d: %s Astartes Grenade Launcher" % [model, "remove" if grenade_equipped else "equip"], "fortis-grenade-launcher", model, squad, "off" if grenade_equipped else "on"))
		if model_index in [2, 3]:
			var plasma_pistol_equipped := bool(unit.get("fortis_kill_team_plasma_pistol", false))
			var plasma_pistol_count := 0
			for member: int in G.alive(state, squad):
				if A.identity(state.units[member]) == "fortis-kill-team" and state.units[member].get("fortis_kill_team_plasma_pistol", false): plasma_pistol_count += 1
			if plasma_pistol_equipped or plasma_pistol_count < int(profile.options.plasma_pistol_limit):
				var plasma_label := "restore Bolt Pistol" if plasma_pistol_equipped else "replace Bolt Pistol with Plasma Pistol"
				result.append(choice("Fortis Plasma Incinerator Intercessor %d: %s" % [model, plasma_label], "fortis-plasma-pistol", model, squad, "off" if plasma_pistol_equipped else "on"))
		if model_index == 0:
			var rocket_choice := str(unit.get("fortis_kill_team_rocket_launcher", "superfrag"))
			var rocket_labels := {"superfrag": "Superfrag Rocket Launcher", "superkrak": "Superkrak Rocket Launcher", "vengor": "Vengor Launcher"}
			for option: String in ["superfrag", "superkrak", "vengor"]:
				if option != rocket_choice:
					result.append(choice("Fortis Kill Team model %d: %s" % [model, str(rocket_labels.get(option, option))], "fortis-rocket-launcher", model, squad, option))
	return result

static func _fortis_replacement_count(state: Dictionary, squad: int, field: String, changed_model: int, next_value: bool) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) != "fortis-kill-team": continue
		var equipped := bool(state.units[member].get(field, false))
		if member == changed_model: equipped = next_value
		if equipped: count += 1
	return count

static func _configure_fortis_kill_team_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Fortis Kill Team equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "fortis-kill-team": return "Choose a living Fortis Kill Team model from your army."
	var model_index := int(unit.get("fortis_kill_team_model", -1))
	var profile := MarineProfiles.profile("fortis-kill-team")
	var sergeant_melee := str(unit.get("fortis_kill_team_sergeant_melee", "knives-and-fists"))
	var sergeant_ranged := str(unit.get("fortis_kill_team_sergeant_ranged", "deathwatch-bolt-rifle"))
	var grenade_launcher := bool(unit.get("fortis_kill_team_grenade_launcher", false))
	var plasma_pistol := bool(unit.get("fortis_kill_team_plasma_pistol", false))
	var rocket_launcher := str(unit.get("fortis_kill_team_rocket_launcher", "superfrag"))
	match action:
		"fortis-sergeant-melee":
			var allowed_melee: Array = ["knives-and-fists"] + profile.options.sergeant_melee_replacements
			if model_index != 1 or value not in allowed_melee: return "Only the Fortis Kill Team Sergeant can select a listed melee replacement."
			sergeant_melee = value
		"fortis-sergeant-ranged":
			var allowed_ranged: Array = ["deathwatch-bolt-rifle"] + profile.options.sergeant_ranged_replacements
			if model_index != 1 or value not in allowed_ranged or (grenade_launcher and value != "deathwatch-bolt-rifle"): return "Only the Fortis Kill Team Sergeant can replace its Deathwatch Bolt Rifle with a listed option; remove its Grenade Launcher first."
			sergeant_ranged = value
		"fortis-grenade-launcher":
			if model_index not in [1, 4, 5] or value not in ["on", "off"]: return "Only a Fortis model equipped with a Deathwatch Bolt Rifle can select an Astartes Grenade Launcher."
			if model_index == 1 and sergeant_ranged != "deathwatch-bolt-rifle": return "The Sergeant must retain its Deathwatch Bolt Rifle to take an Astartes Grenade Launcher."
			if value == "on" and grenade_launcher: return "This model already has an Astartes Grenade Launcher."
			grenade_launcher = value == "on"
			if not grenade_launcher and not unit.get("fortis_kill_team_grenade_launcher", false): return "This model has no Astartes Grenade Launcher to remove."
			var grenade_limit := int(_component_starting_strength(state, unit) / 5.0) * int(profile.options.grenade_launchers_per_five_models)
			if grenade_launcher and _fortis_replacement_count(state, squad, "fortis_kill_team_grenade_launcher", model, true) > grenade_limit: return "This Fortis Kill Team has reached its per-five-model Astartes Grenade Launcher limit."
		"fortis-plasma-pistol":
			if model_index not in [2, 3] or value not in ["on", "off"]: return "Only a Plasma Incinerator Intercessor can replace its Bolt Pistol with a Plasma Pistol."
			if value == "on" and plasma_pistol: return "This model already has a Plasma Pistol."
			plasma_pistol = value == "on"
			if not plasma_pistol and not unit.get("fortis_kill_team_plasma_pistol", false): return "This model has no Plasma Pistol to restore to a Bolt Pistol."
			if plasma_pistol and _fortis_replacement_count(state, squad, "fortis_kill_team_plasma_pistol", model, true) > int(profile.options.plasma_pistol_limit): return "This Fortis Kill Team has reached its one Plasma Pistol limit."
		"fortis-rocket-launcher":
			if model_index != 0 or value not in ["superfrag", "superkrak", "vengor"]: return "Only the Castellan Launcher model can select a listed rocket launcher."
			rocket_launcher = value
		_:
			return "Unsupported Fortis Kill Team equipment choice."
	var loadout := MarineProfiles.fortis_kill_team_model_loadout(model_index, sergeant_melee, sergeant_ranged, grenade_launcher, plasma_pistol, rocket_launcher)
	if loadout.is_empty(): return "That Fortis Kill Team equipment combination is not present in the local datasheet profile."
	unit.fortis_kill_team_sergeant_melee = sergeant_melee
	unit.fortis_kill_team_sergeant_ranged = sergeant_ranged
	unit.fortis_kill_team_grenade_launcher = grenade_launcher
	unit.fortis_kill_team_plasma_pistol = plasma_pistol
	unit.fortis_kill_team_rocket_launcher = rocket_launcher
	unit.ranged_weapons = loadout.ranged
	unit.melee_weapons = loadout.melee
	unit.keywords = loadout.keywords
	return ""

static func talonstrike_kill_team_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("talonstrike-kill-team")
	if profile.is_empty(): return result
	var sergeant_melee_options: Array = ["chainsword"] + profile.options.sergeant_melee_replacements
	var sergeant_ranged_options: Array = ["heavy-bolt-pistol"] + profile.options.sergeant_ranged_replacements
	var melee_labels := {"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon"}
	var ranged_labels := {"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "talonstrike-kill-team": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var model_index := int(unit.get("talonstrike_kill_team_model", -1))
		if model_index == 0:
			var melee_choice := str(unit.get("talonstrike_sergeant_melee", "chainsword"))
			for option: String in sergeant_melee_options:
				if option != melee_choice:
					result.append(choice("Talonstrike Sergeant %d: %s" % [model, str(melee_labels.get(option, option))], "talonstrike-sergeant-melee", model, squad, option))
			var ranged_choice := str(unit.get("talonstrike_sergeant_ranged", "heavy-bolt-pistol"))
			for option: String in sergeant_ranged_options:
				if option != ranged_choice:
					result.append(choice("Talonstrike Sergeant %d: %s" % [model, str(ranged_labels.get(option, option))], "talonstrike-sergeant-ranged", model, squad, option))
		if model_index in [1, 2, 3, 4]:
			var equipped := bool(unit.get("talonstrike_plasma_exterminator", false))
			var label := "restore Assault Bolters" if equipped else "replace Assault Bolters with Plasma Exterminators"
			result.append(choice("Talonstrike Heavy Intercessor %d: %s" % [model, label], "talonstrike-plasma-exterminator", model, squad, "off" if equipped else "on"))
		if model_index in [5, 6, 7, 8, 9]:
			var equipped := bool(unit.get("talonstrike_intercessor_plasma_pistol", false))
			var plasma_count := 0
			for member: int in G.alive(state, squad):
				if A.identity(state.units[member]) == "talonstrike-kill-team" and int(state.units[member].get("talonstrike_kill_team_model", -1)) in [5, 6, 7, 8, 9] and state.units[member].get("talonstrike_intercessor_plasma_pistol", false): plasma_count += 1
			var limit := int(_component_starting_strength(state, unit) / 5.0) * int(profile.options.intercessor_plasma_pistols_per_five_models)
			if equipped or plasma_count < limit:
				var label := "restore Heavy Bolt Pistol" if equipped else "replace Heavy Bolt Pistol with Plasma Pistol"
				result.append(choice("Talonstrike Intercessor %d: %s" % [model, label], "talonstrike-intercessor-plasma-pistol", model, squad, "off" if equipped else "on"))
	return result

static func _talonstrike_replacement_count(state: Dictionary, squad: int, field: String, changed_model: int, next_value: bool) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) != "talonstrike-kill-team": continue
		var equipped := bool(state.units[member].get(field, false))
		if member == changed_model: equipped = next_value
		if equipped: count += 1
	return count

static func _configure_talonstrike_kill_team_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Talonstrike Kill Team equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "talonstrike-kill-team": return "Choose a living Talonstrike Kill Team model from your army."
	var model_index := int(unit.get("talonstrike_kill_team_model", -1))
	var profile := MarineProfiles.profile("talonstrike-kill-team")
	var sergeant_melee := str(unit.get("talonstrike_sergeant_melee", "chainsword"))
	var sergeant_ranged := str(unit.get("talonstrike_sergeant_ranged", "heavy-bolt-pistol"))
	var intercessor_plasma_pistol := bool(unit.get("talonstrike_intercessor_plasma_pistol", false))
	var plasma_exterminator := bool(unit.get("talonstrike_plasma_exterminator", false))
	match action:
		"talonstrike-sergeant-melee":
			var allowed: Array = ["chainsword"] + profile.options.sergeant_melee_replacements
			if model_index != 0 or value not in allowed: return "Only the Talonstrike Sergeant can select a listed melee replacement."
			sergeant_melee = value
		"talonstrike-sergeant-ranged":
			var allowed: Array = ["heavy-bolt-pistol"] + profile.options.sergeant_ranged_replacements
			if model_index != 0 or value not in allowed: return "Only the Talonstrike Sergeant can select a listed ranged replacement."
			sergeant_ranged = value
		"talonstrike-intercessor-plasma-pistol":
			if model_index not in [5, 6, 7, 8, 9] or value not in ["on", "off"]: return "Only a Talonstrike Intercessor can replace its Heavy Bolt Pistol with a Plasma Pistol."
			if value == "on" and intercessor_plasma_pistol: return "This model already has a Plasma Pistol."
			if value == "off" and not intercessor_plasma_pistol: return "This model has no Plasma Pistol to restore to a Heavy Bolt Pistol."
			intercessor_plasma_pistol = value == "on"
			var limit := int(_component_starting_strength(state, unit) / 5.0) * int(profile.options.intercessor_plasma_pistols_per_five_models)
			if intercessor_plasma_pistol and _talonstrike_replacement_count(state, squad, "talonstrike_intercessor_plasma_pistol", model, true) > limit: return "This Talonstrike Kill Team has reached its per-five-model Plasma Pistol limit."
		"talonstrike-plasma-exterminator":
			if model_index not in [1, 2, 3, 4] or value not in ["on", "off"]: return "Only a Talonstrike Heavy Intercessor can replace its Assault Bolters with Plasma Exterminators."
			if value == "on" and plasma_exterminator: return "This model already has Plasma Exterminators."
			if value == "off" and not plasma_exterminator: return "This model has no Plasma Exterminators to restore to Assault Bolters."
			plasma_exterminator = value == "on"
		_:
			return "Unsupported Talonstrike Kill Team equipment choice."
	var loadout := MarineProfiles.talonstrike_kill_team_model_loadout(model_index, sergeant_melee, sergeant_ranged, intercessor_plasma_pistol, plasma_exterminator)
	if loadout.is_empty(): return "That Talonstrike Kill Team equipment combination is not present in the local datasheet profile."
	unit.talonstrike_sergeant_melee = sergeant_melee
	unit.talonstrike_sergeant_ranged = sergeant_ranged
	unit.talonstrike_intercessor_plasma_pistol = intercessor_plasma_pistol
	unit.talonstrike_plasma_exterminator = plasma_exterminator
	unit.ranged_weapons = loadout.ranged
	unit.melee_weapons = loadout.melee
	return ""

static func indomitor_kill_team_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("indomitor-kill-team")
	if profile.is_empty(): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "indomitor-kill-team": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var model_index := int(unit.get("indomitor_kill_team_model", -1))
		if model_index in [0, 1, 2]:
			var auto_equipped := bool(unit.get("indomitor_auto_boltstorm", false))
			result.append(choice("Indomitor Model %d: %s" % [model, "Flamestorm Gauntlets" if auto_equipped else "Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher"], "indomitor-flamestorm-gauntlets", model, squad, "off" if auto_equipped else "on"))
		if model_index in [6, 7, 8, 9]:
			var heavy_bolter_equipped := bool(unit.get("indomitor_heavy_bolter", false))
			var heavy_bolter_limit := int(profile.options.heavy_bolters_per_five_models) * int(state.squads[squad].get("starting_strength", 0) / 5.0)
			if heavy_bolter_equipped or _indomitor_replacement_count(state, squad, "indomitor_heavy_bolter", model, true) <= heavy_bolter_limit:
				result.append(choice("Indomitor Model %d: %s" % [model, "Deathwatch Heavy Bolt Rifle" if heavy_bolter_equipped else "Deathwatch Heavy Bolter"], "indomitor-heavy-bolter", model, squad, "off" if heavy_bolter_equipped else "on"))
		if model_index in [3, 4, 5]:
			var multi_melta_equipped := bool(unit.get("indomitor_multi_melta", false))
			if multi_melta_equipped or _indomitor_replacement_count(state, squad, "indomitor_multi_melta", model, true) <= int(profile.options.multi_melta_limit):
				result.append(choice("Indomitor Model %d: %s" % [model, "Melta Rifle" if multi_melta_equipped else "Multi-melta"], "indomitor-multi-melta", model, squad, "off" if multi_melta_equipped else "on"))
	return result

static func spectrus_kill_team_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("spectrus-kill-team")
	if profile.is_empty(): return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "spectrus-kill-team": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		var model_index := int(unit.get("spectrus_kill_team_model", -1))
		if model_index in [0, 1]:
			var current_sniper := str(unit.get("spectrus_sniper_weapon", "bolt-sniper-rifle"))
			for option: String in ["bolt-sniper-rifle", "las-fusil", "instigator-bolt-carbine"]:
				if option == current_sniper: continue
				var label := str({"bolt-sniper-rifle": "Bolt Sniper Rifle", "las-fusil": "Las Fusil", "instigator-bolt-carbine": "Instigator Bolt Carbine"}[option])
				result.append(choice("Spectrus Sniper %d: replace with %s" % [model, label], "spectrus-sniper-rifle", model, squad, option))
		if model_index in [4, 5]:
			var knife_replaced := bool(unit.get("spectrus_knife_replaced", false))
			result.append(choice("Spectrus Special-issue Infiltrator %d: %s" % [model, "restore Combat Knife" if knife_replaced else "replace Combat Knife with Deathwatch Bolt Carbine and Ceramite Fists"], "spectrus-combat-knife", model, squad, "off" if knife_replaced else "on"))
		if model_index in [6, 7, 8, 9]:
			var helix_equipped := bool(unit.get("spectrus_helix_gauntlet", false))
			var helix_limit := int(profile.options.helix_gauntlet_limit)
			if helix_equipped or _spectrus_helix_count(state, squad, model, true) <= helix_limit:
				result.append(choice("Spectrus Marksman %d: %s" % [model, "restore Deathwatch Marksman Bolt Carbine" if helix_equipped else "replace Deathwatch Marksman Bolt Carbine with Helix Gauntlet"], "spectrus-helix-gauntlet", model, squad, "off" if helix_equipped else "on"))
	return result

static func _spectrus_helix_count(state: Dictionary, squad: int, changed_model: int, next_value: bool) -> int:
	var count := 0
	for member: int in state.units:
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != "spectrus-kill-team": continue
		var equipped := bool(unit.get("spectrus_helix_gauntlet", false))
		if member == changed_model: equipped = next_value
		if equipped: count += 1
	return count

static func _configure_spectrus_kill_team_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Spectrus Kill Team equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "spectrus-kill-team": return "Choose a living Spectrus Kill Team model from your army."
	if not state.squads.has(squad) or int(state.squads[squad].get("starting_strength", 0)) != 10: return "Spectrus Kill Team equipment requires its fixed 10-model unit."
	var model_index := int(unit.get("spectrus_kill_team_model", -1))
	var sniper_weapon := str(unit.get("spectrus_sniper_weapon", "bolt-sniper-rifle"))
	var knife_replaced := bool(unit.get("spectrus_knife_replaced", false))
	var helix_gauntlet := bool(unit.get("spectrus_helix_gauntlet", false))
	var profile := MarineProfiles.profile("spectrus-kill-team")
	match action:
		"spectrus-sniper-rifle":
			if model_index not in [0, 1] or value not in ["bolt-sniper-rifle", "las-fusil", "instigator-bolt-carbine"]: return "Only a Spectrus sniper model can select a listed replacement for its Bolt Sniper Rifle."
			sniper_weapon = value
		"spectrus-combat-knife":
			if model_index not in [4, 5] or value not in ["on", "off"]: return "Only a Special-issue Spectrus Infiltrator can replace its Combat Knife."
			knife_replaced = value == "on"
			if not knife_replaced and not unit.get("spectrus_knife_replaced", false): return "This model has no Deathwatch Bolt Carbine replacement to restore."
		"spectrus-helix-gauntlet":
			if model_index not in [6, 7, 8, 9] or value not in ["on", "off"]: return "Only a Deathwatch Marksman Bolt Carbine bearer can select the Helix Gauntlet replacement."
			helix_gauntlet = value == "on"
			if helix_gauntlet and _spectrus_helix_count(state, squad, model, true) > int(profile.options.helix_gauntlet_limit): return "This Spectrus Kill Team has reached its one Helix Gauntlet limit."
			if not helix_gauntlet and not unit.get("spectrus_helix_gauntlet", false): return "This model has no Helix Gauntlet to replace."
		_:
			return "Unsupported Spectrus Kill Team equipment choice."
	var loadout := MarineProfiles.spectrus_kill_team_model_loadout(model_index, sniper_weapon, knife_replaced, helix_gauntlet)
	if loadout.is_empty(): return "That Spectrus Kill Team equipment combination is not present in the local datasheet profile."
	unit.spectrus_sniper_weapon = sniper_weapon
	unit.spectrus_knife_replaced = knife_replaced
	unit.spectrus_helix_gauntlet = helix_gauntlet
	unit.helix_gauntlet = bool(loadout.helix_gauntlet)
	unit.ranged_weapons = loadout.ranged
	unit.melee_weapons = loadout.melee
	unit.keywords = loadout.keywords
	return ""

static func _indomitor_replacement_count(state: Dictionary, squad: int, field: String, changed_model: int, next_value: bool) -> int:
	var count := 0
	for member: int in state.units:
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != "indomitor-kill-team": continue
		var equipped := bool(unit.get(field, false))
		if member == changed_model: equipped = next_value
		if equipped: count += 1
	return count

static func _configure_indomitor_kill_team_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Indomitor Kill Team equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "indomitor-kill-team": return "Choose a living Indomitor Kill Team model from your army."
	if not state.squads.has(squad) or int(state.squads[squad].get("starting_strength", 0)) != 10: return "Indomitor Kill Team equipment requires its fixed 10-model unit."
	var model_index := int(unit.get("indomitor_kill_team_model", -1))
	var auto_boltstorm := bool(unit.get("indomitor_auto_boltstorm", false))
	var heavy_bolter := bool(unit.get("indomitor_heavy_bolter", false))
	var multi_melta := bool(unit.get("indomitor_multi_melta", false))
	var profile := MarineProfiles.profile("indomitor-kill-team")
	match action:
		"indomitor-flamestorm-gauntlets":
			if model_index not in [0, 1, 2] or value not in ["on", "off"]: return "Only a Flamestorm Gauntlet bearer can choose the Auto Boltstorm and Fragstorm replacement."
			auto_boltstorm = value == "on"
			if not auto_boltstorm and not unit.get("indomitor_auto_boltstorm", false): return "This model has no Auto Boltstorm replacement to remove."
		"indomitor-heavy-bolter":
			if model_index not in [6, 7, 8, 9] or value not in ["on", "off"]: return "Only a Heavy Bolt Rifle bearer can choose the Deathwatch Heavy Bolter replacement."
			heavy_bolter = value == "on"
			if heavy_bolter and _indomitor_replacement_count(state, squad, "indomitor_heavy_bolter", model, true) > int(profile.options.heavy_bolters_per_five_models) * 2: return "This Indomitor Kill Team has reached its two Heavy Bolter limit."
			if not heavy_bolter and not unit.get("indomitor_heavy_bolter", false): return "This model has no Heavy Bolter to replace."
		"indomitor-multi-melta":
			if model_index not in [3, 4, 5] or value not in ["on", "off"]: return "Only a Melta Rifle bearer can choose the Multi-melta replacement."
			multi_melta = value == "on"
			if multi_melta and _indomitor_replacement_count(state, squad, "indomitor_multi_melta", model, true) > int(profile.options.multi_melta_limit): return "This Indomitor Kill Team has reached its one Multi-melta limit."
			if not multi_melta and not unit.get("indomitor_multi_melta", false): return "This model has no Multi-melta to replace."
		_:
			return "Unsupported Indomitor Kill Team equipment choice."
	var loadout := MarineProfiles.indomitor_kill_team_model_loadout(model_index, auto_boltstorm, heavy_bolter, multi_melta)
	if loadout.is_empty(): return "That Indomitor Kill Team equipment combination is not present in the local datasheet profile."
	unit.indomitor_auto_boltstorm = auto_boltstorm
	unit.indomitor_heavy_bolter = heavy_bolter
	unit.indomitor_multi_melta = multi_melta
	unit.ranged_weapons = loadout.ranged
	unit.melee_weapons = loadout.melee
	unit.keywords = loadout.keywords
	return ""

static func decimus_kill_team_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var profile := MarineProfiles.profile("decimus-kill-team")
	if profile.is_empty(): return result
	var gravis_labels := {"infernus-heavy-bolter": "Infernus Heavy Bolter", "frag-cannon": "Frag Cannon", "hellstorm-bolt-rifle": "Hellstorm Bolt Rifle + Grenade Launcher"}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "decimus-kill-team": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad): continue
		if int(state.squads[squad].get("starting_strength", 0)) != 10: continue
		var role := str(unit.get("decimus_kill_team_role", ""))
		if role == "gravis-veteran":
			var current_gravis_weapon := str(unit.get("decimus_gravis_weapon", "infernus-heavy-bolter"))
			for option: String in ["infernus-heavy-bolter", "frag-cannon", "hellstorm-bolt-rifle"]:
				if option != current_gravis_weapon and _decimus_replacement_count(state, squad, "decimus_gravis_weapon", model, option) <= int(profile.options.gravis_replacements_per_five_models) * int(state.squads[squad].starting_strength / 5.0):
					result.append(choice("Decimus Gravis Veteran %d: %s" % [model, str(gravis_labels[option])], "decimus-gravis-weapon", model, squad, option))
		if role == "heavy-veteran":
			var shield_equipped := bool(unit.get("decimus_storm_shield", false))
			var shield_value := "off" if shield_equipped else "on"
			if shield_equipped or _decimus_replacement_count(state, squad, "decimus_storm_shield", model, true) <= int(profile.options.storm_shields_per_five_models) * int(state.squads[squad].starting_strength / 5.0):
				result.append(choice("Decimus Heavy Veteran %d: %s" % [model, "Heavy Thunder Hammer" if shield_equipped else "Power Weapon + Storm Shield (4+ invulnerable save)"], "decimus-storm-shield", model, squad, shield_value))
		if role == "stalker-veteran":
			var plasma_equipped := bool(unit.get("decimus_plasma_incinerator", false))
			var plasma_value := "off" if plasma_equipped else "on"
			if plasma_equipped or _decimus_replacement_count(state, squad, "decimus_plasma_incinerator", model, true) <= int(profile.options.plasma_incinerators_per_five_models) * int(state.squads[squad].starting_strength / 5.0):
				result.append(choice("Decimus Stalker Veteran %d: %s" % [model, "restore Stalker Bolt Rifle" if plasma_equipped else "replace Stalker Bolt Rifle with Plasma Incinerator"], "decimus-plasma-incinerator", model, squad, plasma_value))
	return result

static func _decimus_replacement_count(state: Dictionary, squad: int, field: String, changed_model: int, next_value: Variant) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		var unit: Dictionary = state.units[member]
		if A.identity(unit) != "decimus-kill-team": continue
		var value: Variant = unit.get(field, false)
		if member == changed_model: value = next_value
		if field == "decimus_gravis_weapon":
			if str(value) != "infernus-heavy-bolter": count += 1
		elif bool(value): count += 1
	return count

static func _configure_decimus_kill_team_loadout(state: Dictionary, player: int, model: int, squad: int, action: String, value: String) -> String:
	if setup_actor(state) != player or not state.units.has(model): return "Decimus Kill Team equipment is selected during your army preparations."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or A.identity(unit) != "decimus-kill-team": return "Choose a living Decimus Kill Team model from your army."
	if not state.squads.has(squad) or int(state.squads[squad].get("starting_strength", 0)) != 10:
		return "Decimus Kill Team equipment requires the reconciled 10-model size; the five-model source row is blocked by its minimum-composition conflict."
	var role := str(unit.get("decimus_kill_team_role", ""))
	var gravis_weapon := str(unit.get("decimus_gravis_weapon", "infernus-heavy-bolter"))
	var storm_shield := bool(unit.get("decimus_storm_shield", false))
	var plasma_incinerator := bool(unit.get("decimus_plasma_incinerator", false))
	var profile := MarineProfiles.profile("decimus-kill-team")
	var per_five := int(state.squads[squad].starting_strength / 5.0)
	match action:
		"decimus-gravis-weapon":
			if role != "gravis-veteran" or value not in ["infernus-heavy-bolter", "frag-cannon", "hellstorm-bolt-rifle"]: return "Only a Gravis Veteran can select a listed Infernus Heavy Bolter replacement."
			gravis_weapon = value
			if _decimus_replacement_count(state, squad, "decimus_gravis_weapon", model, gravis_weapon) > int(profile.options.gravis_replacements_per_five_models) * per_five: return "This Decimus Kill Team has reached its per-five-model Gravis weapon replacement limit."
		"decimus-storm-shield":
			if role != "heavy-veteran" or value not in ["on", "off"]: return "Only a Heavy Thunder Hammer Veteran can select the Power Weapon and Storm Shield replacement."
			storm_shield = value == "on"
			if storm_shield and _decimus_replacement_count(state, squad, "decimus_storm_shield", model, true) > int(profile.options.storm_shields_per_five_models) * per_five: return "This Decimus Kill Team has reached its per-five-model Storm Shield limit."
			if not storm_shield and not unit.get("decimus_storm_shield", false): return "This model has no Storm Shield to remove."
		"decimus-plasma-incinerator":
			if role != "stalker-veteran" or value not in ["on", "off"]: return "Only a Stalker Bolt Rifle Veteran can select the Plasma Incinerator replacement."
			plasma_incinerator = value == "on"
			if plasma_incinerator and _decimus_replacement_count(state, squad, "decimus_plasma_incinerator", model, true) > int(profile.options.plasma_incinerators_per_five_models) * per_five: return "This Decimus Kill Team has reached its per-five-model Plasma Incinerator limit."
			if not plasma_incinerator and not unit.get("decimus_plasma_incinerator", false): return "This model has no Plasma Incinerator to replace."
		_:
			return "Unsupported Decimus Kill Team equipment choice."
	var loadout := MarineProfiles.decimus_kill_team_model_loadout(role, gravis_weapon, storm_shield, plasma_incinerator)
	if loadout.is_empty(): return "That Decimus Kill Team equipment combination is not present in the local datasheet profile."
	unit.decimus_gravis_weapon = gravis_weapon
	unit.decimus_storm_shield = storm_shield
	unit.decimus_plasma_incinerator = plasma_incinerator
	unit.ranged_weapons = loadout.ranged
	unit.melee_weapons = loadout.melee
	unit.keywords = loadout.keywords
	var defense: Dictionary = unit.get("defense", {}).duplicate(true)
	defense.invulnerable_target = 4 if storm_shield else int(loadout.stats.invulnerable_target)
	unit.defense = defense
	return ""

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
		a.reserves[squad] = {"cost": cost, "source": "drop-pod-assault", "deep_strike": A.every_model_has(state, squad, "deep-strike")}
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
	if ability_window.get("kind", "") == CorvusBlackstar.WINDOW: return CorvusBlackstar.choices(state, player)
	if ability_window.get("kind", "") == WulfenStormShields.WINDOW: return WulfenStormShields.choices(state, player)
	if ability_window.get("kind", "") == CoreReactions.CORVUS_CLUSTER_MORTAL:
		result.append_array(CoreReactions.mortal_allocations(state, player, CoreReactions.CORVUS_CLUSTER_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if ability_window.get("kind", "") == "vehement-aggression-reroll":
		var target := int(ability_window.get("squad", -1))
		if ability_window.get("owners", []) != [player] or not state.squads.has(target): return []
		result.append(choice("Keep Vehement Aggression's Leadership result", "vehement-aggression-reroll", -1, target, "keep"))
		if StormlanceEnhancements.leadership_reroll_available(state, target):
			result.append(choice("%s: re-roll both Leadership dice" % StormlanceEnhancements.leadership_reroll_name(state, target), "vehement-aggression-reroll", -1, target, "reroll"))
		return result
	if ability_window.get("kind", "") == Mephiston.FALLBACK_WINDOW: return Mephiston.fallback_choices(state, player)
	if ability_window.get("kind", "") == CrusadeAncient.MARTIAL_HONOUR_WINDOW:
		if ability_window.get("owners", []) != [player]: return result
		var honour_squad := int(ability_window.get("squad", -1))
		var honour_model := int(ability_window.get("model", -1))
		var destroyed_target := int(ability_window.get("destroyed_target", -1))
		if CrusadeAncient.martial_honour_choice_valid(state, player, honour_squad, honour_model, destroyed_target):
			result.append(choice("Martial Honour: Crusade Ancient %d gains +5 Objective Control for the battle" % honour_model, CrusadeAncient.MARTIAL_HONOUR_USE, honour_model, honour_squad))
		result.append(choice("Pass Martial Honour for %s" % str(state.squads.get(honour_squad, {}).get("name", "the unit")), CrusadeAncient.MARTIAL_HONOUR_PASS, honour_model, honour_squad))
		return result
	if ability_window.is_empty() and Execrator.actor(state) == player: return Execrator.choices(state, player)
	if ability_window.get("kind", "") == "counter" and Execrator.has_pending(state): return Execrator.choices(state, player)
	if ability_window.get("kind", "") == StasisBomb.MORTAL_WINDOW:
		result.append_array(CoreReactions.mortal_allocations(state, player, StasisBomb.MORTAL_WINDOW))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if ability_window.get("kind", "") == HighMarshalHelbrecht.MORTAL_WINDOW:
		result.append_array(CoreReactions.mortal_allocations(state, player, HighMarshalHelbrecht.MORTAL_WINDOW))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if ability_window.get("kind", "") == BloodAngelsCharacters.DEATH_VISIONS_WINDOW: return BloodAngelsCharacters.choices(state, player)
	if ability_window.get("kind", "") == BloodAngelsCharacters.DEATH_VISIONS_MORTAL:
		result.append_array(CoreReactions.mortal_allocations(state, player, BloodAngelsCharacters.DEATH_VISIONS_MORTAL))
		result.append_array(DetachmentStratagems.mortal_wound_stratagem_choices(state, player))
		return result
	if ability_window.get("kind", "") == StasisBomb.RESUME_WINDOW: return StasisBomb.resume_choices(state, player)
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
				if A.has(state, squad, "my-will-be-done") and A.potential_discount(state, player, squad) > 0 and A.discount(state, player, squad) == 0:
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
	if pending(state).get("kind", "") in [FenrisianWolves.WINDOW, FenrisianWolves.PLACEMENT]:
		return FenrisianWolves.choices(state, player)
	if pending(state).get("kind", "") in [SwordBrethren.WINDOW, SwordBrethren.PLACEMENT]:
		return SwordBrethren.choices(state, player)
	if pending(state).get("kind", "") in [TacticalFluidity.WINDOW, TacticalFluidity.PLACEMENT]:
		return TacticalFluidity.choices(state, player)
	if pending(state).get("kind", "") in [PurgationRun.WINDOW, PurgationRun.PLACEMENT]:
		return PurgationRun.choices(state, player)
	if pending(state).get("kind", "") in [VictrixHonourGuard.WINDOW, VictrixHonourGuard.PLACEMENT]:
		return VictrixHonourGuard.choices(state, player)
	if pending(state).get("kind", "") == HeresyRetribution.WINDOW:
		return HeresyRetribution.choices(state, player)
	if pending(state).get("kind", "") in [CrusaderSurge.WINDOW, CrusaderSurge.TARGET_WINDOW, CrusaderSurge.PLACEMENT]:
		return CrusaderSurge.choices(state, player)
	if pending(state).get("kind", "") in [DeathCompanyDreadnought.WINDOW, DeathCompanyDreadnought.TARGET_WINDOW, DeathCompanyDreadnought.PLACEMENT]:
		return DeathCompanyDreadnought.choices(state, player)
	if pending(state).get("kind", "") == "forward-assault-mark":
		var source_squad: int = int(pending(state).source_squad)
		if int(pending(state).owners[0]) != player: return result
		result.append_array(_enemy_mark_choices(state, player, source_squad, str(pending(state).get("source_ability", "forward-assault-warsuit")), "replacement"))
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
		if Actions.has_mission_action(state, player, Actions.SECURE_ASSET) or Actions.has_mission_action(state, player, Actions.SABOTAGE):
			var mission_action := Actions.SABOTAGE if Actions.has_mission_action(state, player, Actions.SABOTAGE) else Actions.SECURE_ASSET
			var action_name := "Sabotage" if mission_action == Actions.SABOTAGE else "Secure Asset"
			for squad: int in state.squads:
				if int(state.squads[squad].owner) != player or G.alive(state, squad).is_empty(): continue
				for objective_index in Actions.action_targets(state, squad):
					if not Actions.start_error(state, squad, objective_index).is_empty(): continue
					var action_id := "mission-sabotage" if mission_action == Actions.SABOTAGE else "mission-secure-asset"
					result.append(choice("%s: %s targets %s" % [action_name, state.squads[squad].name, state.mission.objectives[objective_index].name], action_id, G.alive(state, squad)[0], objective_index))
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
		result.append_array(grey_hunters_split_choices(state, player))
		result.append_array(wolf_guard_headtakers_split_choices(state, player))
		result.append_array(wolf_guard_headtaker_shield_choices(state, player))
		result.append_array(TransportRules.start_embark_choices(state, player))
		result.append_array(TransportRules.impulsor_loadout_choices(state, player))
		result.append_array(TransportRules.transport_weapon_loadout_choices(state, player))
		result.append_array(baal_predator_loadout_choices(state, player))
		result.append_array(death_company_dreadnought_loadout_choices(state, player))
		result.append_array(space_wolves_walker_loadout_choices(state, player))
		result.append_array(death_company_marines_loadout_choices(state, player))
		result.append_array(deathwatch_veterans_loadout_choices(state, player))
		result.append_array(deathwatch_terminator_loadout_choices(state, player))
		result.append_array(wolf_guard_terminator_loadout_choices(state, player))
		result.append_array(wolf_guard_battle_leader_loadout_choices(state, player))
		result.append_array(thunderwolf_cavalry_loadout_choices(state, player))
		result.append_array(wulfen_loadout_choices(state, player))
		result.append_array(wolf_scouts_loadout_choices(state, player))
		result.append_array(fortis_kill_team_loadout_choices(state, player))
		result.append_array(talonstrike_kill_team_loadout_choices(state, player))
		result.append_array(indomitor_kill_team_loadout_choices(state, player))
		result.append_array(spectrus_kill_team_loadout_choices(state, player))
		result.append_array(decimus_kill_team_loadout_choices(state, player))
		for crusader_model: int in state.units:
			var crusader_unit: Dictionary = state.units[crusader_model]
			if int(crusader_unit.get("owner", -1)) != player or int(crusader_unit.get("wounds", 0)) <= 0 or A.identity(crusader_unit) != "crusader-squad": continue
			var crusader_squad := int(crusader_unit.get("squad", -1))
			if not state.squads.has(crusader_squad): continue
			var crusader_count := int(state.squads[crusader_squad].get("starting_strength", 0))
			var crusader_index := int(crusader_unit.get("crusader_squad_model", -1))
			var current_loadout := str(crusader_unit.get("crusader_squad_loadout", "default"))
			var limited_count := _crusader_squad_limited_loadout_count(state, crusader_squad)
			var limited_max := int(crusader_count / 10.0) * 2
			for loadout_id: String in MarineProfiles.crusader_squad_loadout_options(crusader_index, crusader_count):
				if loadout_id == current_loadout: continue
				if loadout_id in ["heavy-pistol-power-fist", "pyreblaster"] and current_loadout not in ["heavy-pistol-power-fist", "pyreblaster"] and limited_count >= limited_max: continue
				var label: String = {"default": "restore the datasheet default", "hand-flamer": "Hand Flamer", "shotgun": "Shotgun + Combat Knife", "pistol-chainsword": "Heavy Bolt Pistol + Initiate Chainsword", "heavy-pistol-power-fist": "Heavy Bolt Pistol + Power Fist", "pyreblaster": "Pyreblaster"}.get(loadout_id, loadout_id)
				result.append(choice("Crusader Squad model %d: %s" % [crusader_index + 1, label], "crusader-squad-loadout", crusader_model, crusader_squad, loadout_id))
		for sword_brethren_model: int in state.units:
			var sword_brethren_unit: Dictionary = state.units[sword_brethren_model]
			if int(sword_brethren_unit.get("owner", -1)) != player or int(sword_brethren_unit.get("wounds", 0)) <= 0 or A.identity(sword_brethren_unit) != "sword-brethren-squad": continue
			var sword_brethren_squad := int(sword_brethren_unit.get("squad", -1))
			if not state.squads.has(sword_brethren_squad): continue
			var sword_brethren_count := int(state.squads[sword_brethren_squad].get("starting_strength", 0))
			var sword_brethren_index := int(sword_brethren_unit.get("sword_brethren_model", -1))
			var current_sword_brethren_loadout := str(sword_brethren_unit.get("sword_brethren_loadout", "default"))
			for loadout_id: String in MarineProfiles.sword_brethren_loadout_options(sword_brethren_index, sword_brethren_count):
				if loadout_id == current_sword_brethren_loadout or not _sword_brethren_loadout_valid(state, sword_brethren_squad, sword_brethren_model, loadout_id): continue
				var label := str({"default": "restore Heavy Bolt Pistol + Chainsword", "hand-flamer-chainsword": "Hand Flamer + Chainsword", "hand-flamer-power-weapon": "Hand Flamer + Master-crafted Power Weapon", "hand-flamer-thunder-hammer": "Hand Flamer + Thunder Hammer", "plasma-pistol-chainsword": "Plasma Pistol + Chainsword", "plasma-pistol-power-weapon": "Plasma Pistol + Master-crafted Power Weapon", "plasma-pistol-thunder-hammer": "Plasma Pistol + Thunder Hammer", "heavy-pistol-power-weapon": "Heavy Bolt Pistol + Master-crafted Power Weapon", "heavy-pistol-thunder-hammer": "Heavy Bolt Pistol + Thunder Hammer", "twin-lightning-claws": "Twin Lightning Claws"}.get(loadout_id, loadout_id))
				result.append(choice("Sword Brethren model %d: %s" % [sword_brethren_index + 1, label], "sword-brethren-loadout", sword_brethren_model, sword_brethren_squad, loadout_id))
		for execrator_model: int in state.units:
			var execrator_unit: Dictionary = state.units[execrator_model]
			if int(execrator_unit.get("owner", -1)) != player or int(execrator_unit.get("wounds", 0)) <= 0 or A.identity(execrator_unit) != "execrator": continue
			var execrator_squad := int(execrator_unit.get("squad", -1))
			var pistol_package := str(execrator_unit.get("execrator_pistol_package", "absolvor-bolt-pistol"))
			var extra_power_weapon := bool(execrator_unit.get("execrator_mastercrafted_power_weapon", false))
			if not extra_power_weapon:
				var replacement := "hand-flamer" if pistol_package == "absolvor-bolt-pistol" else "absolvor-bolt-pistol"
				var replacement_label := "replace Absolvor Bolt Pistol with Hand Flamer" if replacement == "hand-flamer" else "restore Absolvor Bolt Pistol"
				result.append(choice("Execrator %d: %s" % [execrator_model, replacement_label], "execrator-pistol-loadout", execrator_model, execrator_squad, replacement))
			if extra_power_weapon or pistol_package == "absolvor-bolt-pistol":
				var power_label := "remove the additional Master-crafted Power Weapon" if extra_power_weapon else "add the Extra Attacks Master-crafted Power Weapon"
				result.append(choice("Execrator %d: %s" % [execrator_model, power_label], "execrator-extra-melee", execrator_model, execrator_squad, "off" if extra_power_weapon else "on"))
		for squad: int in state.squads:
			if int(state.squads[squad].get("owner", -1)) != player: continue
			var watcher_identity := ""
			for model: int in G.alive(state, squad):
				var identity := A.identity(state.units[model])
				if identity in ["deathwing-knights", "deathwing-terminator-squad"]: watcher_identity = identity
			if watcher_identity.is_empty(): continue
			var watcher_field := "deathwing_knights_watcher_equipped" if watcher_identity == "deathwing-knights" else "deathwing_terminator_watcher_equipped"
			var watcher_equipped := bool(state.squads[squad].get(watcher_field, false))
			result.append(choice("%s: %s Watcher in the Dark" % [state.squads[squad].name, "remove" if watcher_equipped else "equip"], "deathwing-knights-watcher", -1, squad, "off" if watcher_equipped else "on"))
		for model: int in state.units:
			var knight: Dictionary = state.units[model]
			if int(knight.get("owner", -1)) != player or int(knight.get("wounds", 0)) <= 0 or A.identity(knight) != "deathwing-knights": continue
			var melee_choice := str(knight.get("deathwing_knight_melee", "great-weapon-of-the-unforgiven" if knight.get("sergeant", false) else "mace-of-absolution"))
			var weapon_options: Array[String] = []
			if knight.get("sergeant", false): weapon_options.append_array(["great-weapon-of-the-unforgiven", "relic-weapon"])
			else: weapon_options.append_array(["mace-of-absolution", "power-weapon"])
			var weapon_labels := {"great-weapon-of-the-unforgiven": "Great Weapon of the Unforgiven", "relic-weapon": "Relic Weapon", "mace-of-absolution": "Mace of Absolution", "power-weapon": "Power Weapon"}
			for weapon_id: String in weapon_options:
				if weapon_id == melee_choice: continue
				result.append(choice("%s %d: %s" % ["Knight Master" if knight.get("sergeant", false) else "Deathwing Knight", model, weapon_labels[weapon_id]], "deathwing-knights-melee", model, knight.squad, weapon_id))
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
			var darkshroud: Dictionary = state.units[model]
			if darkshroud.owner != player or darkshroud.wounds <= 0 or A.identity(darkshroud) != "ravenwing-darkshroud": continue
			var assault_cannon: bool = darkshroud.get("ravenwing_darkshroud_assault_cannon", false)
			result.append(choice("Ravenwing Darkshroud %d: %s" % [model, "Heavy Bolter" if assault_cannon else "Assault Cannon"], "ravenwing-darkshroud-cannon", model, darkshroud.squad, "heavy-bolter" if assault_cannon else "assault-cannon"))
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
			var identity := A.identity(terminator)
			if terminator.owner != player or terminator.wounds <= 0 or identity not in ["terminator-squad", "deathwing-terminator-squad", "deathwatch-terminator-squad"]: continue
			if identity == "deathwatch-terminator-squad":
				if terminator.get("sergeant", false): continue
				var equipped: String = terminator.get("terminator_special_weapon", "")
				var package := str(terminator.get("deathwatch_terminator_melee_package", "power-fist"))
				if not _deathwatch_terminator_keeps_storm_bolter(package): continue
				var special_limit := _deathwatch_terminator_special_limit(state, terminator.squad)
				if equipped.is_empty() and _terminator_special_count(state, terminator.squad) >= special_limit: continue
				for kind: String in ["none", "assault-cannon", "cyclone-missile-launcher", "heavy-flamer", "plasma-cannon"]:
					if kind == "none" and equipped.is_empty(): continue
					if kind != "none" and kind == equipped: continue
					var labels := {"none": "restore Storm Bolter", "assault-cannon": "Assault Cannon", "cyclone-missile-launcher": "Cyclone Missile Launcher + Storm Bolter", "heavy-flamer": "Heavy Flamer", "plasma-cannon": "Plasma Cannon"}
					result.append(choice("Deathwatch Terminator %d: %s" % [model, labels[kind]], "terminator-special-weapon", model, terminator.squad, kind))
				continue
			var unit_label := "Deathwing Terminator" if identity == "deathwing-terminator-squad" else "Terminator"
			var melee_choice: String = terminator.get("terminator_melee_choice", "power-fist")
			var melee_options: Array = ["power-fist", "chainfist", "power-weapon"] if terminator.get("sergeant", false) else ["power-fist", "chainfist"]
			for kind: String in melee_options:
				if kind != melee_choice: result.append(choice("%s %d: %s" % [unit_label, model, {"power-fist": "Power Fist", "chainfist": "Chainfist", "power-weapon": "Power Weapon"}[kind]], "terminator-melee", model, terminator.squad, kind))
			if terminator.get("sergeant", false): continue
			var equipped: String = terminator.get("terminator_special_weapon", "")
			var special_limit := int(state.squads[terminator.squad].starting_strength / 5.0)
			if equipped.is_empty() and _terminator_special_count(state, terminator.squad) >= special_limit: continue
			var special_options: Array[String] = ["none", "assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]
			if identity == "deathwing-terminator-squad": special_options.append("plasma-cannon")
			for kind: String in special_options:
				if kind == "none" and equipped.is_empty(): continue
				if kind != "none" and kind == equipped: continue
				var special_labels := {"none": "Storm Bolter", "assault-cannon": "Assault Cannon", "heavy-flamer": "Heavy Flamer", "cyclone-missile-launcher": "Cyclone Missile Launcher + Storm Bolter", "plasma-cannon": "Plasma Cannon"}
				result.append(choice("%s %d: %s" % [unit_label, model, special_labels[kind]], "terminator-special-weapon", model, terminator.squad, kind))
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
		for model: int in state.units:
			var guard: Dictionary = state.units[model]
			if guard.owner != player or guard.wounds <= 0 or A.identity(guard) != "sanguinary-guard": continue
			var inferno_equipped := bool(guard.get("sanguinary_guard_inferno_pistol", false))
			var inferno_count := 0
			for member: int in state.units:
				if state.units[member].squad == guard.squad and A.identity(state.units[member]) == "sanguinary-guard" and state.units[member].get("sanguinary_guard_inferno_pistol", false): inferno_count += 1
			var guard_model_count := _component_starting_strength(state, guard)
			var inferno_limit := MarineProfiles.sanguinary_guard_inferno_limit(guard_model_count)
			if inferno_equipped or inferno_count < inferno_limit:
				result.append(choice("Sanguinary Guard %d: %s" % [model, "restore Angelus Boltgun" if inferno_equipped else "replace Angelus Boltgun with Inferno Pistol"], "sanguinary-guard-inferno-pistol", model, guard.squad, "off" if inferno_equipped else "on"))
		for model: int in state.units:
			var black_knight: Dictionary = state.units[model]
			if black_knight.owner != player or black_knight.wounds <= 0 or A.identity(black_knight) != "ravenwing-black-knights": continue
			var launcher_equipped: bool = black_knight.get("black_knight_grenade_launcher", false)
			var launcher_count := 0
			for member: int in state.units:
				if state.units[member].squad == black_knight.squad and A.identity(state.units[member]) == "ravenwing-black-knights" and state.units[member].get("black_knight_grenade_launcher", false): launcher_count += 1
			var launcher_limit := int(_component_starting_strength(state, black_knight) / 3.0)
			if launcher_equipped or launcher_count < launcher_limit:
				result.append(choice("Ravenwing Black Knight %d: %s" % [model, "restore Plasma Talon instead of Grenade Launcher" if launcher_equipped else "replace Plasma Talon with Grenade Launcher"], "black-knight-grenade-launcher", model, black_knight.squad, "off" if launcher_equipped else "on"))
		for model: int in state.units:
			var command_model: Dictionary = state.units[model]
			if command_model.owner != player or command_model.wounds <= 0 or A.identity(command_model) != "ravenwing-command-squad": continue
			var launcher_equipped: bool = command_model.get("ravenwing_command_grenade_launcher", false)
			var launcher_count := 0
			for member: int in state.units:
				if state.units[member].squad == command_model.squad and A.identity(state.units[member]) == "ravenwing-command-squad" and state.units[member].get("ravenwing_command_grenade_launcher", false): launcher_count += 1
			var launcher_limit := int(_component_starting_strength(state, command_model) / 3.0)
			if launcher_equipped or launcher_count < launcher_limit:
				result.append(choice("%s %d: %s" % [command_model.get("ravenwing_command_role", "Ravenwing Command model"), model, "restore Plasma Talon" if launcher_equipped else "replace Plasma Talon with Grenade Launcher"], "ravenwing-command-grenade-launcher", model, command_model.squad, "off" if launcher_equipped else "on"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "chameleoline-cloaks"): continue
			var squad_models: Array[int] = G.alive(state, squad)
			squad_models.sort()
			var eliminator_ordinal := 0
			for model: int in squad_models:
				if A.identity(state.units[model]) != "eliminator-squad": continue
				if not state.units[model].get("sergeant", false):
					eliminator_ordinal += 1
					var fusil: bool = not state.units[model].ranged_weapons.is_empty() and str(state.units[model].ranged_weapons[0].get("id", "")) == "las-fusil"
					if fusil or (not state.units[model].ranged_weapons.is_empty() and str(state.units[model].ranged_weapons[0].get("id", "")) == "bolt-sniper-rifle"):
						var label := "Eliminator %d: Restore Bolt Sniper Rifle" % eliminator_ordinal if fusil else "Eliminator %d: Replace Bolt Sniper Rifle with Las Fusil" % eliminator_ordinal
						result.append(choice(label, "eliminator-troopers", model, squad, "sniper" if fusil else "las"))
					continue
				for kind: String in ["sniper", "las", "carbine"]:
					result.append(choice("Eliminator Sergeant: %s" % {"sniper": "Bolt Sniper Rifle", "las": "Las Fusil", "carbine": "Instigator Bolt Carbine"}[kind], "eliminator-sergeant", model, squad, kind))
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
			for other: int in state.units:
				if state.units[other].squad == bearer.squad and A.identity(state.units[other]) == "eradicator-squad-with-melta-rifles" and state.units[other].get("multi_melta", false): equipped += 1
			var multi_limit := int(float(state.squads[bearer.squad].get("starting_strength", 0)) / 3.0)
			if multi or equipped < multi_limit:
				var loadout_label := "Restore Melta Rifle" if multi else "Equip Multi-melta"
				result.append(choice(loadout_label, "eradicator-melta", model, bearer.squad, "rifle" if multi else "multi"))
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner == player and unit.get("sergeant", false) and A.identity(unit) == "hellblaster-squad":
				var plasma: bool = unit.get("plasma_pistol", false)
				result.append(choice("Sergeant %d: equip %s (free)" % [model, "Bolt Pistol" if plasma else "Plasma Pistol"], "hellblaster-pistol", model, unit.squad, "bolt" if plasma else "plasma"))
			if unit.owner == player and unit.get("sergeant", false) and A.identity(unit) == "assault-intercessor-squad":
				var current_pistol := str(unit.get("ranged_weapons", [{}])[0].get("id", "heavy-bolt-pistol")) if not unit.get("ranged_weapons", []).is_empty() else "heavy-bolt-pistol"
				for kind: String in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]:
					if kind == current_pistol: continue
					var pistol_label := "restore Heavy Bolt Pistol" if kind == "heavy-bolt-pistol" else "replace Heavy Bolt Pistol with %s" % {"hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}[kind]
					result.append(choice("Assault Intercessor Sergeant %d: %s" % [model, pistol_label], "assault-intercessor-pistol", model, unit.squad, kind))
				var current_melee := str(unit.get("melee_weapons", [{}])[0].get("id", "chainsword")) if not unit.get("melee_weapons", []).is_empty() else "chainsword"
				for kind: String in ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]:
					if kind == current_melee: continue
					var melee_label := "restore Chainsword" if kind == "chainsword" else "replace Chainsword with %s" % {"power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}[kind]
					result.append(choice("Assault Intercessor Sergeant %d: %s" % [model, melee_label], "assault-intercessor-melee", model, unit.squad, kind))
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
		if required_warlord < 0: required_warlord = lion_model(state, player)
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if unit.owner != player: continue
			if A.identity(unit) == "nephilim-jetfighter":
				var lascannons := bool(unit.get("nephilim_lascannons", false))
				result.append(choice("Nephilim Jetfighter %d: %s" % [model, "restore Twin Heavy Bolter" if lascannons else "replace Twin Heavy Bolter with Nephilim Lascannons"], "nephilim-jetfighter-loadout", model, unit.squad, "twin-heavy-bolter" if lascannons else "lascannons"))
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
					if loadout == "relic-shield" and unit.get("captain_power_fist", false): continue
					if loadout != ranged_loadout: result.append(choice("Captain %d: %s" % [model, {"default": "Master-crafted Bolter + Heavy Bolt Pistol", "neo-volkite": "Neo-volkite Pistol", "plasma-pistol": "Plasma Pistol", "relic-shield": "Relic Shield + Heavy Bolt Pistol"}[loadout]], "captain-ranged-loadout", model, unit.squad, loadout))
				if ranged_loadout != "relic-shield":
					var fist: bool = unit.get("captain_power_fist", false)
					result.append(choice("Captain %d: %s" % [model, "Master-crafted Power Weapon" if fist else "Power Fist"], "captain-melee-loadout", model, unit.squad, "power-weapon" if fist else "power-fist"))
			if A.identity(unit) == "blood-angels-captain":
				var pistol_package: String = str(unit.get("blood_angels_captain_pistol_package", "heavy-bolt-pistol"))
				for package: String in ["heavy-bolt-pistol", "inferno-pistol"]:
					if package != pistol_package: result.append(choice("Blood Angels Captain %d: %s" % [model, {"heavy-bolt-pistol": "Heavy Bolt Pistol", "inferno-pistol": "Inferno Pistol"}[package]], "blood-angels-captain-ranged-loadout", model, unit.squad, package))
				var melee_package: String = str(unit.get("blood_angels_captain_melee_package", "master-crafted-chainsword"))
				for package: String in ["master-crafted-chainsword", "power-fist", "relic-weapon"]:
					if package != melee_package: result.append(choice("Blood Angels Captain %d: %s" % [model, {"master-crafted-chainsword": "Master-crafted Chainsword", "power-fist": "Power Fist", "relic-weapon": "Relic Weapon"}[package]], "blood-angels-captain-melee-loadout", model, unit.squad, package))
			if A.identity(unit) == "death-company-captain":
				var pistol_package: String = str(unit.get("death_company_captain_pistol_package", "heavy-bolt-pistol"))
				for package: String in ["heavy-bolt-pistol", "inferno-pistol"]:
					if package != pistol_package: result.append(choice("Death Company Captain %d: %s" % [model, {"heavy-bolt-pistol": "Heavy Bolt Pistol", "inferno-pistol": "Inferno Pistol"}[package]], "death-company-captain-ranged-loadout", model, unit.squad, package))
				var melee_package: String = str(unit.get("death_company_captain_melee_package", "master-crafted-chainsword"))
				for package: String in ["master-crafted-chainsword", "power-fist", "relic-weapon"]:
					if package != melee_package: result.append(choice("Death Company Captain %d: %s" % [model, {"master-crafted-chainsword": "Master-crafted Chainsword", "power-fist": "Power Fist", "relic-weapon": "Relic Weapon"}[package]], "death-company-captain-melee-loadout", model, unit.squad, package))
			if A.identity(unit) == "death-company-captain-with-jump-pack":
				var packages := {"default": "Heavy Bolt Pistol + Chainsword", "hand-flamer-power-fist": "Hand Flamer + Power Fist", "plasma-pistol-power-fist": "Plasma Pistol + Power Fist", "heavy-bolt-pistol-power-fist": "Heavy Bolt Pistol + Power Fist", "hand-flamer-relic-weapon": "Hand Flamer + Relic Weapon", "plasma-pistol-relic-weapon": "Plasma Pistol + Relic Weapon", "heavy-bolt-pistol-relic-weapon": "Heavy Bolt Pistol + Relic Weapon", "thunder-hammer-shield": "Thunder Hammer + Relic Shield", "chainsword-shield": "Chainsword + Relic Shield"}
				var current_package: String = str(unit.get("death_company_jump_captain_loadout", "default"))
				for package: String in MarineProfiles.profile("death-company-captain-with-jump-pack").options.loadout_packages:
					if package != current_package: result.append(choice("Death Company Jump Captain %d: %s" % [model, packages[package]], "death-company-jump-captain-loadout", model, unit.squad, package))
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
			if A.identity(unit) == "blood-claws" and unit.get("sergeant", false):
				var pistol_package := str(unit.get("blood_claws_pack_leader_pistol", "bolt-pistol"))
				for package: String in MarineProfiles.profile("blood-claws").options.pack_leader_ranged_packages:
					if package != pistol_package: result.append(choice("Blood Claw Pack Leader %d: %s" % [model, "Bolt Pistol" if package == "bolt-pistol" else "Plasma Pistol"], "blood-claws-pack-leader-pistol", model, unit.squad, package))
				var melee_package := str(unit.get("blood_claws_pack_leader_melee", "chainsword"))
				for package: String in MarineProfiles.profile("blood-claws").options.pack_leader_melee_packages:
					if package != melee_package: result.append(choice("Blood Claw Pack Leader %d: %s" % [model, "Chainsword" if package == "chainsword" else "Power Weapon"], "blood-claws-pack-leader-melee", model, unit.squad, package))
			if A.identity(unit) == "grey-hunters" and unit.get("sergeant", false):
				var pistol_package := str(unit.get("grey_hunters_pack_leader_pistol", "bolt-pistol"))
				for package: String in MarineProfiles.profile("grey-hunters").options.pack_leader_ranged_packages:
					if package != pistol_package: result.append(choice("Grey Hunter Pack Leader %d: %s" % [model, "Bolt Pistol" if package == "bolt-pistol" else "Plasma Pistol"], "grey-hunters-pack-leader-pistol", model, unit.squad, package))
				var melee_package := str(unit.get("grey_hunters_pack_leader_melee", "chainsword"))
				for package: String in MarineProfiles.profile("grey-hunters").options.pack_leader_melee_packages:
					if package != melee_package: result.append(choice("Grey Hunter Pack Leader %d: %s" % [model, {"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon"}[package]], "grey-hunters-pack-leader-melee", model, unit.squad, package))
			if A.identity(unit) == "castellan":
				var ranged_package: String = str(unit.get("castellan_ranged_package", "combi-weapon"))
				var melee_package: String = str(unit.get("castellan_melee_package", "master-crafted-power-weapon"))
				if ranged_package == "combi-weapon": result.append(choice("Castellan %d: replace Combi-weapon with Heavy Bolt Pistol" % model, "castellan-ranged-loadout", model, unit.squad, "heavy-bolt-pistol"))
				else: result.append(choice("Castellan %d: restore Combi-weapon" % model, "castellan-ranged-loadout", model, unit.squad, "combi-weapon"))
				if melee_package == "master-crafted-power-weapon": result.append(choice("Castellan %d: replace Master-crafted Power Weapon with Chainsword" % model, "castellan-melee-loadout", model, unit.squad, "chainsword"))
				else: result.append(choice("Castellan %d: restore Master-crafted Power Weapon" % model, "castellan-melee-loadout", model, unit.squad, "master-crafted-power-weapon"))
			if A.identity(unit) == "marshal":
				var ranged_package: String = str(unit.get("marshal_ranged_package", "plasma-pistol"))
				if ranged_package == "plasma-pistol": result.append(choice("Marshal %d: replace Plasma Pistol with Combi-weapon" % model, "marshal-ranged-loadout", model, unit.squad, "combi-weapon"))
				else: result.append(choice("Marshal %d: restore Plasma Pistol" % model, "marshal-ranged-loadout", model, unit.squad, "plasma-pistol"))
			if A.identity(unit) == "invader-atvs":
				var multi_melta: bool = unit.get("invader_atv_multi_melta", false)
				result.append(choice("Invader ATV %d: %s" % [model, "Onslaught Gatling Cannon" if multi_melta else "Multi-melta (+5 points)"], "invader-atv-gun", model, unit.squad, "onslaught" if multi_melta else "multi-melta"))
			if A.identity(unit) == "chaplain-in-terminator-armour":
				var shield: bool = unit.get("relic_shield", false)
				result.append(choice("Chaplain %d: equip %s" % [model, "Storm Bolter" if shield else "Relic Shield (+1 W)"], "terminator-chaplain-shield", model, unit.squad, "bolter" if shield else "shield"))
			var source := A.identity(unit)
			if (source in ["lieutenant-in-phobos-armour", "librarian", "librarian-in-phobos-armour", "chief-librarian-tigurius", "kayvaan-shrike", "cato-sicarius", "aethon-shaan", "captain-in-phobos-armour", "captain-in-gravis-armour", "tor-garadon", "darnath-lysander", "iron-father-feirros", "caanok-var", "ancient-in-terminator-armour", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "librarian-in-terminator-armour", "apothecary", "ancient", "bladeguard-ancient", "judiciar", "captain", "chaplain", "chaplain-on-bike", "captain-on-bike", "sammael", "suboden-khan", "chaplain-with-jump-pack", "lieutenant", "apothecary-biologis", "captain-with-jump-pack", "death-company-captain", "death-company-captain-with-jump-pack", "astorath", "lemartes", "adrax-agatone", "kaius-konorius", "vulkan-hestan", "asmodai", "lazarus", "azrael", "belial", "ezekiel", "overlord", "royal-warden", "roboute-guilliman", "lion-eljonson", "emperor-s-champion", "castellan", "marshal", "marneus-calgar", "captain-titus", "techmarine", "arjac-rockfist", "logan-grimnar", "ragnar-blackmane", "ulrik-the-slayer", "njal-stormcaller"] or "transhuman-strategist" in A.RULES.get(source, [])) and source != "murderfang" and (source != "cato-sicarius" or not LeaderCatalog.army_has_calgar(state, player)) and (required_warlord == -1 or model == required_warlord): result.append(choice("Warlord: model %d" % model, "warlord", model))
			if (MarineLeaderLinks.TARGETS.has(source) or MarineLeaderLinks.CHAPTER_TARGETS.has(source) or source in ["overlord", "royal-warden"]) and not unit.has("attachment_role"):
					for target: int in state.squads:
						if attachment_allowed(state, model, target): result.append(choice("Attach %s %d to %s" % [source, model, state.squads[target].name], "attach", model, target))
		for squad: int in state.squads:
			if state.squads[squad].owner != player: continue
			var unassigned_support := false
			for unit: Dictionary in state.units.values():
				if unit.squad == squad and is_support_identity(state, unit) and unit.get("attachment_role", "") != "support": unassigned_support = true
			if unassigned_support: continue
			if AircraftRules.is_aircraft(state, squad): continue
			var reserve_eligible := TransportRules.is_drop_pod(state, squad) or A.every_model_has(state, squad, "deep-strike") or A.scout_distance(state, squad) > 0
			if reserve_eligible:
				if not state.unit_abilities.reserves.has(squad): result.append(choice("Place %s in strategic reserves" % state.squads[squad].name, "reserve", -1, squad))

		return result
	if not DetachmentStratagems.adamantine_pending(state).is_empty(): return DetachmentStratagems.adamantine_decision_choices(state, player)
	if not state.get("fearsome_assault", {}).is_empty(): return Reivers.choices(state, player)
	if Asmodai.actor(state) > 0: return Asmodai.choices(state, player)
	if CommanderDante.actor(state) > 0: return CommanderDante.choices(state, player)
	var battle := battle_actor(state)
	if battle > 0:
		if battle != player: return result
		result.append(choice("Finish start-of-battle declarations", "battle-done"))
		result.append_array(TemplarVows.choices(state, player))
		for squad: int in state.squads:
			if int(state.squads[squad].get("owner", -1)) != player or not A.has(state, squad, "slayer-s-oath") or A.slayer_oath_resolved(state, squad): continue
			var ulrik_models := A.sources(state, squad, "slayer-s-oath")
			if ulrik_models.is_empty(): continue
			for target: int in A.slayer_oath_targets(state, player):
				result.append(choice("Ulrik %d: select %s as Slayer's Oath" % [ulrik_models[0], state.squads[target].name], "slayer-oath", ulrik_models[0], target, "initial"))
			result.append(choice("Ulrik %d: do not select a Slayer's Oath" % ulrik_models[0], "slayer-oath", ulrik_models[0], squad, "pass-initial"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "forward-assault-warsuit") or A.forward_assault_mark(state, squad) >= 0: continue
			var source_models := A.sources(state, squad, "forward-assault-warsuit")
			if source_models.is_empty(): continue
			for target: int in A.forward_assault_targets(state, player):
				result.append(choice("Invictor %d: mark %s" % [source_models[0], state.squads[target].name], "invictor-mark", source_models[0], target, "initial"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "purgatus-quarry") or A.purgatus_initial_resolved(state, squad): continue
			result.append_array(_enemy_mark_choices(state, player, squad, "purgatus-quarry", "initial"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or not A.has(state, squad, "headhunter-quarry") or A.headhunter_initial_resolved(state, squad): continue
			result.append_array(_enemy_mark_choices(state, player, squad, "headhunter-quarry", "initial"))
		for squad: int in state.squads:
			if state.squads[squad].owner != player or state.unit_abilities.used.has("homer-set:%d" % squad) or not has_teleport_homer(state, squad): continue
			result.append(choice("Set Teleport Homer for %s at X/Z" % state.squads[squad].name, "homer", -1, squad))
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
		if window.kind == DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW:
			result.append_array(DetachmentStratagems.for_emperors_honour_choices(state, player))
			result.append(choice("Decline For the Emperor's Honour!", "for-emperors-honour-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW:
			result.append_array(DetachmentStratagems.spoor_of_the_unholy_choices(state, player))
			result.append(choice("Decline Spoor of the Unholy", "spoor-of-the-unholy-pass", -1, int(window.squad)))
			return result
		if window.kind == DetachmentStratagems.DREAD_CRUSADERS_WINDOW:
			result.append_array(DetachmentStratagems.dread_crusaders_choices(state, player))
			if window.get("current_result", {}).is_empty(): result.append(choice("Decline Dread Crusaders", "dread-crusaders-pass", -1, int(window.squad)))
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
			var card_name := "Duty Unto Death" if worthy_rule == DetachmentStratagems.INNER_CIRCLE_DUTY_UNTO_DEATH else "Duty in Death" if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH else "A Worthy Death" if not worthy_rule.is_empty() else ""
			var effect_text := "each destroyed model remains on a 4+ until the unit fights or the phase ends"
			if worthy_rule == DetachmentStratagems.DUTY_IN_DEATH: effect_text = "each destroyed model remains on a 4+ (+1 in Assault Doctrine) until the unit fights or the phase ends"
			elif worthy_rule == DetachmentStratagems.INNER_CIRCLE_DUTY_UNTO_DEATH: effect_text = "each destroyed model remains on a 4+ (+1 if engaged with an enemy within your Vowed objective range) until the unit fights or the phase ends"
			if not worthy_rule.is_empty() and DetachmentStratagems.error(state, player, target, worthy_rule).is_empty(): result.append(choice("%s: %s (1 CP)" % [card_name, effect_text], "detachment-stratagem", -1, target, worthy_rule))
			if CrusadeAncient.can_offer_vengeful_exhortation(state, target):
				var exhortation_sources := A.sources(state, target, "vengeful-exhortation")
				if not exhortation_sources.is_empty(): result.append(choice("Vengeful Exhortation: arm %s to retain destroyed models on a 4+ until it fights or the Fight phase ends" % state.squads[target].name, CrusadeAncient.VENGEFUL_EXHORTATION_USE, exhortation_sources[0], target))
			var decline_label := "Decline Vengeful Exhortation for %s" % state.squads[target].name if worthy_rule.is_empty() else "Decline %s and Vengeful Exhortation for %s" % [card_name, state.squads[target].name]
			result.append(choice(decline_label, "worthy-pass", -1, target))
			return result
		if window.kind in [DetachmentStratagems.SHOOTING_REACTION_WINDOW, "mounted-shooting-reaction", "stormlance-hurtling"]:
			var target: int = int(window.squad)
			if bool(window.get("can_hurtling", false)): result.append(choice("Hurtling Targets: attacks against %s hit at -1 (1 CP)" % state.squads[target].name, "hurtling-use", -1, target))
			if DetachmentStratagems.error(state, player, target, DetachmentStratagems.EVASIVE_MANOEUVRES).is_empty(): result.append(choice("Evasive Manoeuvres: attacks against %s wound at -1 (1 CP)" % state.squads[target].name, "evasive-use", -1, target))
			if bool(window.get("can_angels_defiant", false)) and DetachmentStratagems.error(state, player, target, DetachmentStratagems.FIST_ANGELS_DEFIANT).is_empty():
				var angels_cost := maxi(0, 1 - A.discount(state, player, target))
				result.append(choice("Angels Defiant: attacks stronger than %s's Toughness wound at -1 (%d CP)" % [state.squads[target].name, angels_cost], "angels-defiant-use", -1, target, DetachmentStratagems.FIST_ANGELS_DEFIANT))
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
			result.append_array(_enemy_mark_choices(state, player, source_squad, str(window.get("source_ability", "forward-assault-warsuit")), "replacement"))
			return result
		if window.kind == "bladeguard":
			var squad: int = window.remaining[0]
			for mode: String in ["attack", "defend", "pass"]:
				result.append(choice("Bladeguard %d: %s" % [squad, {"attack": "+1 melee hit", "defend": "enemy hit -1", "pass": "decline this trigger"}[mode]], "bladeguard", -1, squad, mode))
			return result
		if window.kind == "phobos-shrouding": return PhobosLibrarian.choices(state, player)
		if window.kind == NjalStormcaller.STORM_CALLER_WINDOW: return NjalStormcaller.choices(state, player)
		if window.kind in [Ezekiel.TARGET_WINDOW, Ezekiel.REROLL_WINDOW]: return Ezekiel.choices(state, player)
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
			result.append_array(HighMarshalHelbrecht.choices(state, player))
			result.append_array(ChaplainGrimaldus.choices(state, player))
			result.append_array(Mephiston.start_choices(state, player))
			if state.phase == "command" and state.active == player:
				for model: int in models(state, player, "primarch-of-the-first-legion"):
					var squad: int = int(state.units[model].squad)
					if state.unit_abilities.used.get("lion-primarch:%d" % squad, -1) == state.turn: continue
					var selected_primarch: Array = state.unit_abilities.get("lion_primarch_pending", {}).get(squad, [])
					var options := ["mist-wreathed-shadow-realms", "martial-exemplar", "no-hiding-from-the-watchers"]
					for ability: String in options:
						if ability in selected_primarch: continue
						if ability == "mist-wreathed-shadow-realms" and (not state.units[model].get("on_battlefield", true) or FightQueue.engaged(state, squad)): continue
						if ability == "mist-wreathed-shadow-realms" and not _strategic_reserve_capacity_error(state, player, squad).is_empty(): continue
						result.append(choice("Lion El’jonson: select %s" % ability.replace("-", " ").capitalize(), "lion-primarch", model, squad, ability))
					if not selected_primarch.is_empty(): result.append(choice("Lion El’jonson: confirm Primarch of the First Legion", "lion-primarch-done", model, squad))
					if state.units[model].get("on_battlefield", true) and state.unit_abilities.used.get("lion-master-strategist:%d" % squad, -1) != state.turn:
						for doctrine: String in Doctrines.available(state, player): result.append(choice("Lion El’jonson: Master Strategist — %s" % doctrine.capitalize(), "lion-master-strategist", model, squad, doctrine))
			for model: int in models(state, player, "engrammatic-logic"):
				if state.unit_abilities.used.has("logic:%d" % model): continue
				for target: int in state.squads:
					if state.squads[target].owner == player and state.squads[target].battle_shocked and not G.alive(state, target).is_empty() and str(state.units[G.alive(state, target)[0]].get("definition_id", "")).begins_with("40kdc:11e:necrons:") and G.distance_to_target(state, state.units[model], target) <= 12.001:
						result.append(choice("Engrammatic Logic %d: clear %s Battle-shock" % [model, state.squads[target].name], "logic", model, target))
		if window.kind == "end":
			var artemis_placement := WatchCaptainArtemis.placement_choices(state, player)
			if not artemis_placement.is_empty(): return artemis_placement
			result.append_array(WatchCaptainArtemis.choices(state, player))
			result.append_array(Sanguinor.choices(state, player))
			for squad: int in TacticalFluidity.end_fight_squads(state, player):
				var suboden := squad in TacticalFluidity.suboden_squads(state, player)
				var mode := "Normal Move" if suboden else ("Fall Back" if FightQueue.engaged(state, squad) else "Normal Move")
				var limit := "%d inches" % int(state.units[G.alive(state, squad)[0]].get("movement", 0)) if suboden else "6 inches"
				var source := "Suboden Khan: Wrath of the First Khan" if suboden else "Captain in Phobos Armour: Tactical Fluidity"
				result.append(choice("%s: %s up to %s" % [source, mode, limit], "storm-swift-move" if suboden else "fluidity-end", -1, squad))
			for squad: int in echo_ravenspire_squads(state, player):
				result.append(choice("Kayvaan Shrike: place %s in Strategic Reserves" % state.squads[squad].name, "echo-of-ravenspire", -1, squad))
			for squad: int in spectrus_doctrine_squads(state, player):
				result.append(choice("Spectrus Doctrines: place %s in Strategic Reserves" % state.squads[squad].name, "spectrus-doctrines-reserve", -1, squad))
			for squad: int in parabolic_jetleap_squads(state, player):
				result.append(choice("Parabolic Jetleap: place %s in Strategic Reserves" % state.squads[squad].name, "parabolic-jetleap", -1, squad))
			for model: int in models(state, player, "resurrection-orb"):
				var squad: int = state.units[model].squad
				if R.enabled(state) and R.supported_unit(state, squad) and not state.unit_abilities.used.has("orb:%d" % squad) and state.unit_abilities.used.get("resurrect-turn:%d" % player, -1) != state.turn:
					result.append(choice("Resurrection Orb %d: activate D6 healing" % model, "orb", model))
			result.append_array(DetachmentStratagems.choices(state, player))
			result.append_array(TransportRules.gauntlet_duty_candidates(state, player, true))
			result.append_array(CoreReactions.choices(state, player))
			result.append_array(StasisBomb.choices(state, player))
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
	result.append_array(NjalStormcaller.psychic_choices(state, player))
	result.append_array(Ezekiel.choices(state, player))
	result.append_array(DetachmentStratagems.choices(state, player))
	result.append_array(CoreReactions.choices(state, player))
	for model: int in models(state, player, "strategic-acumen"):
		var squad: int = state.units[model].squad
		if state.phase == "command" and state.active == player and state.unit_abilities.used.get("acumen:%d" % squad, -1) != state.turn:
			for doctrine: String in Doctrines.available(state, player): result.append(choice("Strategic Acumen %d: %s" % [model, doctrine], "acumen", model, squad, doctrine))
	for model: int in models(state, player, "grand-master-of-the-ravenwing"):
		var squad: int = state.units[model].squad
		if state.phase != "command" or state.active != player or state.unit_abilities.used.get("ravenwing-doctrine:%d" % squad, -1) == state.turn: continue
		for doctrine: String in Doctrines.available(state, player): result.append(choice("Grand Master of the Ravenwing %d: %s" % [model, doctrine], "ravenwing-doctrine", model, squad, doctrine))
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
	for model: int in models(state, player, "masterful-tactician"):
		if state.phase != "movement" or state.active != player or not state.units[model].get("on_battlefield", true): continue
		if state.unit_abilities.used.get("masterful-tactician:%d:%d" % [model, state.turn], false): continue
		for doctrine: String in Doctrines.ORDER:
			for target: int in state.squads:
				if state.squads[target].owner != player or not astartes_target_eligible(state, target): continue
				var sight := T.targeting(state, model, target)
				if sight.visible and sight.distance <= 9.001:
					result.append(choice("Masterful Tactician %d: %s for %s" % [model, doctrine, state.squads[target].name], "masterful-tactician", model, target, doctrine))
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
	for model: int in models(state, player, "vehement-aggression"):
		var squad: int = state.units[model].squad
		var previous_test: Dictionary = state.unit_abilities.used.get("vehement-aggression:%d" % squad, {})
		if state.phase == "fight" and state.fight_actor == player and state.fight_step in ["attacks", "consolidation_reaction"] and squad in FightQueue.choices(state, player) and not state.squads[squad].fought and int(previous_test.get("round", -1)) != int(state.round): result.append(choice("Vehement Aggression: Castellan %d Leadership roll for %s" % [model, state.squads[squad].name], "vehement-aggression", model, squad))
	for model: int in models(state, player, "pious-fervour"):
		var squad: int = state.units[model].squad
		var previous_activation: Dictionary = state.unit_abilities.get("pious_fervour", {}).get(squad, {})
		if state.phase == "fight" and state.fight_actor == player and state.fight_step in ["attacks", "consolidation_reaction"] and squad in FightQueue.choices(state, player) and not state.squads[squad].fought and int(previous_activation.get("turn", -1)) != int(state.turn): result.append(choice("Pious Fervour: Marshal %d gains up to +3 melee Attacks" % model, "pious-fervour", model, squad))
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
			var reserve_record: Dictionary = state.unit_abilities.reserves[squad]
			var lion_mist_ingress := str(reserve_record.get("source", "")) == "mist-wreathed-shadow-realms" and int(reserve_record.get("ingress_turn", -1)) == int(state.turn)
			var early_ingress_enhancement := first_movement_phase_ingress_enhancement(state, squad, player)
			if TransportRules.is_drop_pod(state, squad) or ingress_round_allowed(state, squad) or not early_ingress_enhancement.is_empty() or lion_mist_ingress:
				var ingress_label := "Deep Strike ingress"
				if TransportRules.is_drop_pod(state, squad): ingress_label = "Drop Pod Assault ingress"
				elif lion_mist_ingress: ingress_label = "Mist-wreathed Shadow Realms ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.DEATHWING_ASSAULT: ingress_label = "Deathwing Assault ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.CORPOREUM_RELIQUARY: ingress_label = "Corporeum Reliquary ingress"
				elif early_ingress_enhancement == StormlanceEnhancements.THUNDERCOWL_TURBINES: ingress_label = "Thundercowl Turbines ingress"
				result.append(choice("%s: %s" % [ingress_label, state.squads[squad].name], "ingress", -1, squad))
				if ingress_round_allowed(state, squad) and DetachmentStratagems.error(state, player, squad, DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM).is_empty():
					result.append(choice("Relic Teleportarium: %s ingress from more than 6 inches away; cannot Charge this turn (1 CP)" % state.squads[squad].name, "relic-teleportarium-ingress", -1, squad))
		for model: int in models(state, player, "high-king-of-fenris"):
			var source_squad := int(state.units[model].get("squad", -1))
			var use_key := "high-king-fenris:%d" % source_squad
			if state.unit_abilities.used.get(use_key, -1) == int(state.round): continue
			for squad: int in state.squads:
				if not state.unit_abilities.reserves.has(squad) or int(state.squads[squad].get("owner", -1)) != player: continue
				if not A.has_living_unit_keyword(state, squad, "SPACE WOLVES") or A.high_king_fenris_selected(state, squad): continue
				result.append(choice("Logan Grimnar: High King of Fenris — select %s in Strategic Reserves" % state.squads[squad].name, "high-king-fenris", model, squad))
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
	var allowed: Array = MarineLeaderLinks.targets(name)
	if allowed.is_empty() and name in ["overlord", "royal-warden"]: allowed = ["necron-warriors", "immortals"]
	for support_target: String in Supports.BODYGUARDS.get(name, []):
		if support_target not in allowed: allowed.append(support_target)
	if is_support_identity(state, source):
		for support_target: String in Supports.CONDITIONAL_BODYGUARDS.get(name, []):
			if support_target not in allowed: allowed.append(support_target)
	var found := false
	var role := _attachment_role_for_target(state, source, target)
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

static func _attachment_role_for_target(state: Dictionary, source: Dictionary, target: int) -> String:
	var source_identity := A.identity(source)
	var target_models: Array[int] = G.alive(state, target)
	if target_models.is_empty(): return "support" if is_support_identity(state, source) else "leader"
	var target_identity := A.identity(state.units[target_models[0]])
	var support_targets: Array = Supports.BODYGUARDS.get(source_identity, []).duplicate()
	if is_support_identity(state, source):
		for support_target: String in Supports.CONDITIONAL_BODYGUARDS.get(source_identity, []):
			if support_target not in support_targets: support_targets.append(support_target)
	if target_identity in support_targets: return "support"
	if target_identity in MarineLeaderLinks.targets(source_identity): return "leader"
	return "support" if is_support_identity(state, source) else "leader"

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
	var attachment_role := _attachment_role_for_target(state, unit, target)
	var attachment_models: Array[int] = [model]
	if attachment_role == "support" or A.identity(unit) == "chaplain-grimaldus":
		attachment_models.clear()
		for member: int in state.units:
			if int(state.units[member].get("squad", -1)) == origin: attachment_models.append(member)
	for member: int in attachment_models:
		var attached_unit: Dictionary = state.units[member]
		var defense := Groups.profile(state, member)
		attached_unit.ranged_weapons = Equipment.inventory(state, member, false).duplicate(true)
		attached_unit.melee_weapons = Equipment.inventory(state, member, true).duplicate(true)
		attached_unit.defense = {"toughness": defense.toughness, "save_target": defense.save_target, "invulnerable_target": defense.invulnerable_target, "melee_invulnerable_target": defense.melee_invulnerable_target}
		attached_unit.leadership_target = source.stats.leadership_target
		attached_unit.objective_control = source.stats.objective_control
		attached_unit.component_squad = origin
		attached_unit.attachment_role = attachment_role
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
	for member: int in attachment_models: state.units[member].squad = target
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
			var lion_command: bool = state.phase == "command" and int(state.active) == int(owner) and not models(state, int(owner), "primarch-of-the-first-legion").is_empty()
			if logic_available(state, owner) or CoreReactions.start_available(state, owner) or not spiritual_choices(state, owner).is_empty() or not rampart_choices(state, owner).is_empty() or HighMarshalHelbrecht.start_available(state, int(owner)) or ChaplainGrimaldus.start_available(state, int(owner)) or Mephiston.start_available(state, int(owner)) or not DetachmentStratagems.adamantine_squads(state, owner).is_empty() or lion_command: owners.append(owner)
		if not owners.is_empty(): a.window = {"kind": "start", "owners": owners}
	if state.round > 3:
		for squad: int in a.reserves.keys():
			var reserve_record: Dictionary = a.reserves.get(squad, {})
			if bool(reserve_record.get("has_ingressed", false)) or bool(a.get("ingress_history", {}).get(squad, false)) or str(reserve_record.get("source", "")) in ["parabolic-jetleap", "echo-of-ravenspire"]: continue
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
		var spectrus_doctrines: bool = state.phase == "fight" and not spectrus_doctrine_squads(state, int(owner)).is_empty()
		if WatchCaptainArtemis.pending(state, int(owner)) or orb_available(state, owner) or DetachmentStratagems.eternal_pending(state, owner) or CoreReactions.end_available(state, owner) or not rapid_ingress_squads(state, owner).is_empty() or not Sanguinor.choices(state, int(owner)).is_empty() or stand_unyielding or phobos_mortis_snares or gauntlet_storm_and_secure or gauntlet_duty_is_never_done or spectrus_doctrines or StasisBomb.has_candidates(state, owner) or (state.phase == "fight" and owner != state.active and (not parabolic_jetleap_squads(state, owner).is_empty() or not echo_ravenspire_squads(state, owner).is_empty() or not DetachmentStratagems.withdraw_and_regroup_squads(state, owner).is_empty() or not DetachmentStratagems.gunship_extraction_squads(state, owner).is_empty())) or phobos_tactical_withdrawal or (state.phase == "fight" and (not DetachmentStratagems.wind_swift_squads(state, owner).is_empty() or not TacticalFluidity.end_fight_squads(state, owner).is_empty())): owners.append(owner)
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
		if AircraftRules.is_aircraft(state, squad): continue
		if used.get("ingress:%d:%s" % [player, key(state)], false) or state.squads[squad].get("battle_shocked", false): continue
		if not ingress_round_allowed(state, squad): continue
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

static func spectrus_doctrine_squads(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not A.enabled(state) or state.phase != "fight" or owner == state.active: return result
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner or state.unit_abilities.get("reserves", {}).has(squad) or not A.has(state, squad, "spectrus-doctrines") or FightQueue.engaged(state, squad) or TransportRules.squad_embarked(state, squad): continue
		var alive := G.alive(state, squad)
		if alive.is_empty(): continue
		var includes_spectrus := false
		var all_on_battlefield := true
		for model: int in alive:
			if A.identity(state.units[model]) == "spectrus-kill-team": includes_spectrus = true
			if not state.units[model].get("on_battlefield", true): all_on_battlefield = false
		if includes_spectrus and all_on_battlefield: result.append(squad)
	return result

static func point_error(state: Dictionary, point: Vector2, radius: float) -> String:
	if not point.is_finite() or absf(point.x) + radius > state.board_size.x / 2.0 or absf(point.y) + radius > state.board_size.y / 2.0: return "The whole base must fit on the battlefield."
	return ""

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable, destination_elevation: float = -1.0) -> Dictionary:
	if str(selected.get("action", "")).begins_with("corvus-cluster-"): return CorvusBlackstar.apply(state, player, selected, roller)
	if selected.get("action", "") in [WulfenStormShields.USE, WulfenStormShields.PASS]: return WulfenStormShields.apply(state, player, selected)
	if selected.get("action", "") in [WatchCaptainArtemis.USE, WatchCaptainArtemis.PASS]: return WatchCaptainArtemis.apply_choice(state, player, selected, roller)
	if selected.get("action", "") in [WatchCaptainArtemis.PLACE, WatchCaptainArtemis.CONFIRM]: return WatchCaptainArtemis.apply_placement(state, player, selected, point)
	if str(selected.get("action", "")) in [Execrator.KEEP_ACTION, Execrator.REROLL_ACTION]: return Execrator.resolve(state, player, selected, roller)
	if str(selected.get("action", "")) == "mephiston-psychic":
		var mephiston_result := Mephiston.use_psychic(state, player, selected, roller)
		if str(mephiston_result.get("error", "")).is_empty() and mephiston_result.has("interrupt_squad"):
			Actions.interrupt(state, int(mephiston_result.interrupt_squad), "Mephiston's Psychic test caused Battle-shock")
		return mephiston_result
	if str(selected.get("action", "")) == Mephiston.FALLBACK_WINDOW:
		var fallback_window: Dictionary = pending(state)
		var fallback_target := int(fallback_window.get("squad", -1))
		var fallback_result: Dictionary = fallback_window.get("current_result", {}).duplicate(true)
		if str(selected.get("value", "")) == "reroll":
			if not StormlanceEnhancements.leadership_reroll_available(state, fallback_target): return {"error": "No eligible Leadership re-roll remains for this unit."}
			fallback_result = Morale.roll_leadership_test(state, fallback_target, roller)
			if not str(fallback_result.get("error", "")).is_empty(): return fallback_result
			fallback_result.rerolled = true
			fallback_result.reroll_source = StormlanceEnhancements.leadership_reroll_name(state, fallback_target)
		return Mephiston.complete_fallback_choice(state, player, selected, fallback_result)
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
	if str(selected.get("action", "")) == "high-marshal":
		return HighMarshalHelbrecht.apply(state, player, selected, roller)
	if str(selected.get("action", "")) in [BloodAngelsCharacters.DEATH_VISIONS_USE, BloodAngelsCharacters.DEATH_VISIONS_PASS]:
		return BloodAngelsCharacters.apply(state, player, selected, roller)
	if str(selected.get("action", "")) == "grimaldus-temple-relic":
		return ChaplainGrimaldus.apply(state, player, selected)
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
	if str(selected.get("action", "")) == "mission-sabotage":
		var sabotage_model: Dictionary = state.units.get(int(selected.get("model", -1)), {})
		if not Actions.has_mission_action(state, player, Actions.SABOTAGE) or sabotage_model.is_empty() or int(sabotage_model.get("owner", -1)) != player:
			return {"error": "Sabotage requires the selected current mission and one of your units."}
		var sabotage_error := Actions.start_error(state, int(sabotage_model.squad), int(selected.get("target", -1)))
		if not sabotage_error.is_empty(): return {"error": sabotage_error}
		Actions.start(state, int(sabotage_model.squad), int(selected.get("target", -1)))
		return {"message": "%s started Sabotage at %s; complete it at end of turn while controlling that objective." % [state.squads[int(sabotage_model.squad)].name, state.mission.objectives[int(selected.target)].name]}
	var a: Dictionary = state.unit_abilities
	var model: int = selected.model
	var target: int = selected.target
	if str(selected.get("action", "")) in [CrusadeAncient.MARTIAL_HONOUR_USE, CrusadeAncient.MARTIAL_HONOUR_PASS]:
		var honour_window: Dictionary = a.get("window", {})
		if honour_window.get("kind", "") != CrusadeAncient.MARTIAL_HONOUR_WINDOW or honour_window.get("owners", []) != [player] or int(honour_window.get("squad", -1)) != target or int(honour_window.get("model", -1)) != model:
			return {"error": "No matching Martial Honour decision is pending."}
		if selected.action == CrusadeAncient.MARTIAL_HONOUR_PASS:
			a.window = honour_window.get("resume_window", {})
			return {"error": "", "message": "Martial Honour was passed."}
		var destroyed_target := int(honour_window.get("destroyed_target", -1))
		if not CrusadeAncient.martial_honour_choice_valid(state, player, target, model, destroyed_target): return {"error": "Martial Honour is no longer eligible for this unit."}
		if not a.has("crusade_martial_honour"): a.crusade_martial_honour = {}
		a.crusade_martial_honour[model] = true
		if not a.has("used"): a.used = {}
		a.used[CrusadeAncient.martial_honour_used_key(target)] = true
		a.window = honour_window.get("resume_window", {})
		return {"error": "", "message": "Martial Honour: Crusade Ancient %d gains +5 Objective Control for the rest of the battle." % model}
	if str(selected.get("action", "")) == CrusadeAncient.VENGEFUL_EXHORTATION_USE:
		var exhortation_window: Dictionary = a.get("window", {})
		if exhortation_window.get("kind", "") != DetachmentStratagems.WORTHY_WINDOW or exhortation_window.get("owners", []) != [player] or int(exhortation_window.get("squad", -1)) != target:
			return {"error": "No matching Vengeful Exhortation decision is pending."}
		var exhortation_error := CrusadeAncient.activate_vengeful_exhortation(state, player, target, model)
		if not exhortation_error.is_empty(): return {"error": exhortation_error}
		var exhortation_declaration: Dictionary = exhortation_window.get("declaration", {}).duplicate(true)
		if exhortation_declaration.is_empty(): return {"error": "Vengeful Exhortation has no saved attack declaration."}
		a.window = {}
		return {"error": "", "resume_declaration": exhortation_declaration, "message": "Vengeful Exhortation is active for %s until it fights or the Fight phase ends." % str(state.squads[target].get("name", "the unit"))}
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
	if selected.get("action", "") == "baal-predator-loadout":
		var loadout_error := _configure_baal_predator_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("value", "")))
		if not loadout_error.is_empty(): return {"error": loadout_error}
		return {"message": "Baal Predator equipment updated from the local Blood Angels datasheet."}
	if selected.get("action", "") == "death-company-dreadnought-loadout":
		var death_company_loadout_error := _configure_death_company_dreadnought_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("value", "")))
		if not death_company_loadout_error.is_empty(): return {"error": death_company_loadout_error}
		return {"message": "Death Company Dreadnought equipment updated from the local Blood Angels datasheet."}
	if selected.get("action", "") == "space-wolves-walker-loadout":
		var walker_loadout_error := _configure_space_wolves_walker_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("value", "")))
		if not walker_loadout_error.is_empty(): return {"error": walker_loadout_error}
		return {"message": "Dreadnought equipment updated from its local Space Wolves datasheet."}
	if selected.get("action", "") in ["death-company-melee-loadout", "death-company-pistol-loadout", "death-company-grenade-launcher"]:
		var marine_loadout_error := _configure_death_company_marine_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not marine_loadout_error.is_empty(): return {"error": marine_loadout_error}
		return {"message": "Death Company Marine equipment updated from its local Blood Angels datasheet."}
	if selected.get("action", "") in ["deathwatch-veteran-loadout", "deathwatch-sergeant-ranged-loadout", "deathwatch-sergeant-melee-loadout"]:
		var deathwatch_error := _configure_deathwatch_veteran_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not deathwatch_error.is_empty(): return {"error": deathwatch_error}
		return {"message": "Deathwatch Veterans equipment updated from its local datasheet."}
	if selected.get("action", "") in ["fortis-sergeant-melee", "fortis-sergeant-ranged", "fortis-grenade-launcher", "fortis-plasma-pistol", "fortis-rocket-launcher"]:
		var fortis_error := _configure_fortis_kill_team_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not fortis_error.is_empty(): return {"error": fortis_error}
		return {"message": "Fortis Kill Team equipment updated from the local datasheet."}
	if selected.get("action", "") in ["talonstrike-sergeant-melee", "talonstrike-sergeant-ranged", "talonstrike-intercessor-plasma-pistol", "talonstrike-plasma-exterminator"]:
		var talonstrike_error := _configure_talonstrike_kill_team_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not talonstrike_error.is_empty(): return {"error": talonstrike_error}
		return {"message": "Talonstrike Kill Team equipment updated from the local datasheet."}
	if selected.get("action", "") in ["indomitor-flamestorm-gauntlets", "indomitor-heavy-bolter", "indomitor-multi-melta"]:
		var indomitor_error := _configure_indomitor_kill_team_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not indomitor_error.is_empty(): return {"error": indomitor_error}
		return {"message": "Indomitor Kill Team equipment updated from its local datasheet."}
	if selected.get("action", "") in ["spectrus-sniper-rifle", "spectrus-combat-knife", "spectrus-helix-gauntlet"]:
		var spectrus_error := _configure_spectrus_kill_team_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not spectrus_error.is_empty(): return {"error": spectrus_error}
		return {"message": "Spectrus Kill Team equipment updated from its local datasheet."}
	if selected.get("action", "") in ["decimus-gravis-weapon", "decimus-storm-shield", "decimus-plasma-incinerator"]:
		var decimus_error := _configure_decimus_kill_team_loadout(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("action", "")), str(selected.get("value", "")))
		if not decimus_error.is_empty(): return {"error": decimus_error}
		return {"message": "Decimus Kill Team equipment updated from its local datasheet."}
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
		"masterful-tactician":
			var source: Dictionary = state.units.get(model, {})
			var use_key := "masterful-tactician:%d:%d" % [model, state.turn]
			if source.is_empty() or source.owner != player or source.wounds <= 0 or not source.get("on_battlefield", true) or A.identity(source) != "azrael": return {"error": "Masterful Tactician requires living Azrael on the battlefield."}
			if state.phase != "movement" or state.active != player or a.used.get(use_key, false): return {"error": "Masterful Tactician is used once in Azrael's Movement phase."}
			if not state.squads.has(target) or state.squads[target].owner != player or not astartes_target_eligible(state, target): return {"error": "Choose one friendly Adeptus Astartes target unit."}
			var sight := T.targeting(state, model, target)
			if not sight.visible or sight.distance > 9.001 or selected.value not in Doctrines.ORDER: return {"error": "Choose a Combat Doctrine for one visible friendly Adeptus Astartes unit within 9 inches."}
			a.doctrines[target] = {"doctrine": selected.value, "source": "azrael", "owner": player}
			a.used[use_key] = true
		"watcher-in-dark":
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or G.alive(state, target).is_empty() or not A.has(state, target, "watcher-in-the-dark"):
				return {"error": "Watcher in the Dark requires a living unit equipped with this wargear."}
			if not DetachmentStratagems.mortal_wound_triggered(state, target): return {"error": "Watcher in the Dark can only be summoned when this unit suffers a mortal wound."}
			var use_key := "watcher:%d" % target
			if a.used.get(use_key, false): return {"error": "Watcher in the Dark can be summoned only once per battle for this unit."}
			if not a.has("watcher_active"): a.watcher_active = {}
			a.watcher_active[target] = true
			a.used[use_key] = true
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
		"blessings-of-the-omnissiah", "blessings-defer", "blessings-pass", "gift-of-the-iron-wolf", "gift-of-the-iron-wolf-defer", "gift-of-the-iron-wolf-pass", "master-of-the-forge", "master-forge-defer", "master-forge-pass":
			return Techmarine.apply(state, player, selected, roller)
		"priority-target":
			var priority_error := CombiLieutenant.select_priority_target(state, player, selected)
			if not priority_error.is_empty(): return {"error": priority_error}
		"evade-use", "evade-pass", "evade-place", "evade-confirm":
			return CombiLieutenant.apply(state, player, selected, point, roller)
		"cato-knight-use", "cato-knight-pass", "cato-knight-place", "cato-knight-confirm":
			return CatoSicarius.apply(state, player, selected, point)
		"predatory-instinct-use", "predatory-instinct-pass", "predatory-instinct-place", "predatory-instinct-confirm":
			return FenrisianWolves.apply(state, player, selected, point, roller)
		"sword-brethren-exploit-use", "sword-brethren-exploit-pass", "sword-brethren-exploit-place", "sword-brethren-exploit-confirm":
			return SwordBrethren.apply(state, player, selected, point)
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
		"heresy-retribution-place", "heresy-retribution-reset", "heresy-retribution-confirm":
			var surge_result := HeresyRetribution.apply(state, player, selected, point, destination_elevation)
			if surge_result.get("completed", false): end_move(state, target)
			return surge_result
		"crusader-surge-use", "crusader-surge-pass", "crusader-surge-enemy", "crusader-surge-objective", "crusader-surge-place", "crusader-surge-reset", "crusader-surge-confirm":
			return CrusaderSurge.apply(state, player, selected, point, roller, destination_elevation)
		"death-company-fury-use", "death-company-fury-pass", "death-company-fury-target", "death-company-fury-place", "death-company-fury-reset", "death-company-fury-confirm":
			return DeathCompanyDreadnought.apply(state, player, selected, point, roller)
		"glory-use", "glory-pass", "glory-place", "glory-confirm":
			return VictrixHonourGuard.apply(state, player, selected, point, roller)
		Incursors.DIVINATOR_WINDOW: return Incursors.choose(state, player, selected)
		"haywire-mine": return Incursors.haywire(state, player, selected, roller)
		"fearsome-assault": return Reivers.resolve(state, player, selected, roller)
		"feared-interrogator": return Asmodai.resolve(state, player, selected, roller)
		"death-mask-of-sanguinius": return CommanderDante.resolve(state, player, selected, roller)
		"miraculous-saviour": return Sanguinor.begin_ingress(state, player, selected)
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
		"ravenwing-darkshroud-cannon":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "ravenwing-darkshroud" or selected.value not in ["heavy-bolter", "assault-cannon"]: return {"error": "This option belongs to a living Ravenwing Darkshroud."}
			var profile := MarineProfiles.profile("ravenwing-darkshroud")
			var ranged: Array = profile.ranged.duplicate(true)
			if selected.value == "assault-cannon":
				ranged = ranged.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "heavy-bolter")
				ranged.append(profile.additional_weapon_profiles.ranged[0].duplicate(true))
			bearer.ranged_weapons = ranged
			bearer.ravenwing_darkshroud_assault_cannon = selected.value == "assault-cannon"
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
			var identity := A.identity(bearer)
			var allowed: Array = ["power-fist", "chainfist", "power-weapon"] if bearer.get("sergeant", false) else ["power-fist", "chainfist"]
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or identity not in ["terminator-squad", "deathwing-terminator-squad"] or selected.value not in allowed: return {"error": "This melee replacement does not match the Terminator model's source options."}
			bearer.terminator_melee_choice = selected.value
			_terminator_weapons(bearer)
		"deathwatch-terminator-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "deathwatch-terminator-squad": return {"error": "Choose a living Deathwatch Terminator from your army preparations."}
			var package := str(selected.value)
			if package not in MarineProfiles.profile("deathwatch-terminator-squad").get("options", {}).get("melee_packages", []) or not _deathwatch_terminator_loadout_valid(state, target, model, package): return {"error": "Choose a source-listed Deathwatch Terminator melee-and-shield package compatible with its Storm Bolter options."}
			var old_shield := bool(bearer.get("deathwatch_terminator_storm_shield", false))
			var new_shield := package == "thunder-hammer-storm-shield"
			if old_shield != new_shield:
				var delta := 5 if new_shield else -5
				var cost_error := _adjust_profile_option_cost(state, player, target, "deathwatch-terminator-squad", delta, "Storm Shield")
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + delta
				var wound_delta := 1 if new_shield else -1
				bearer.max_wounds = int(bearer.get("max_wounds", bearer.wounds)) + wound_delta
				bearer.wounds = maxi(0, int(bearer.wounds) + wound_delta)
			bearer.deathwatch_terminator_storm_shield = new_shield
			bearer.deathwatch_terminator_melee_package = package
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
		"wolf-guard-battle-leader-ranged", "wolf-guard-battle-leader-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "wolf-guard-battle-leader": return {"error": "Choose your living Wolf Guard Battle Leader during army preparations."}
			var profile := MarineProfiles.profile("wolf-guard-battle-leader")
			var ranged_loadout := str(bearer.get("wolf_guard_battle_leader_ranged_loadout", "plasma-pistol"))
			var melee_loadout := str(bearer.get("wolf_guard_battle_leader_melee_loadout", "master-crafted-power-weapon"))
			var next_loadout := str(selected.get("value", ""))
			if str(selected.get("action", "")) == "wolf-guard-battle-leader-ranged":
				if next_loadout not in profile.options.ranged_loadouts or next_loadout == ranged_loadout: return {"error": "Choose a source-listed Wolf Guard Battle Leader ranged replacement."}
				ranged_loadout = next_loadout
			else:
				if next_loadout not in profile.options.melee_loadouts or next_loadout == melee_loadout: return {"error": "Choose a source-listed Wolf Guard Battle Leader melee replacement."}
				melee_loadout = next_loadout
			var weapons := MarineProfiles.wolf_guard_battle_leader_weapons(ranged_loadout, melee_loadout)
			if weapons.is_empty(): return {"error": "The selected Wolf Guard Battle Leader loadout has no source-matched weapon profile."}
			var old_shield := str(bearer.get("wolf_guard_battle_leader_ranged_loadout", "plasma-pistol")) == "storm-shield"
			var new_shield := ranged_loadout == "storm-shield"
			if old_shield != new_shield:
				var wound_delta := 1 if new_shield else -1
				bearer.max_wounds = int(bearer.get("max_wounds", bearer.wounds)) + wound_delta
				bearer.wounds = maxi(1, int(bearer.wounds) + wound_delta)
			bearer.wolf_guard_battle_leader_storm_shield = new_shield
			bearer.wolf_guard_battle_leader_ranged_loadout = ranged_loadout
			bearer.wolf_guard_battle_leader_melee_loadout = melee_loadout
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"wolf-guard-terminator-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "wolf-guard-terminators": return {"error": "Choose a living Wolf Guard Terminator from your army preparations."}
			var next_loadout := str(selected.get("value", ""))
			if not _wolf_guard_terminator_loadout_valid(state, target, model, next_loadout): return {"error": "Choose a source-listed Wolf Guard Terminator loadout that fits this model's role and per-five-model limit."}
			var previous := str(bearer.get("wolf_guard_terminator_loadout", "default"))
			if previous == next_loadout: return {"error": "That Wolf Guard Terminator loadout is already equipped."}
			var old_shield := previous == "storm-shield"
			var new_shield := next_loadout == "storm-shield"
			if old_shield != new_shield:
				var delta := 5 if new_shield else -5
				var cost_error := _adjust_profile_option_cost(state, player, target, "wolf-guard-terminators", delta, "Storm Shield")
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + delta
				var wound_delta := 1 if new_shield else -1
				bearer.max_wounds = int(bearer.get("max_wounds", bearer.wounds)) + wound_delta
				bearer.wounds = maxi(0, int(bearer.wounds) + wound_delta)
			bearer.wolf_guard_terminator_storm_shield = new_shield
			var weapons := MarineProfiles.wolf_guard_terminator_weapons(next_loadout)
			if weapons.is_empty(): return {"error": "The selected Wolf Guard Terminator loadout has no source-matched weapon profile."}
			bearer.wolf_guard_terminator_loadout = next_loadout
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"thunderwolf-cavalry-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "thunderwolf-cavalry": return {"error": "Choose a living Thunderwolf Cavalry model from your army preparations."}
			var next_loadout := str(selected.get("value", ""))
			if not _thunderwolf_cavalry_loadout_valid(state, target, model, next_loadout): return {"error": "Choose a source-listed Thunderwolf Cavalry loadout that respects its per-three-model Plasma Pistol limit."}
			var previous := str(bearer.get("thunderwolf_cavalry_loadout", "default"))
			if previous == next_loadout: return {"error": "That Thunderwolf Cavalry loadout is already equipped."}
			var weapons := MarineProfiles.thunderwolf_cavalry_weapons(next_loadout)
			if weapons.is_empty(): return {"error": "The selected Thunderwolf Cavalry loadout has no source-matched weapon profile."}
			var old_shield := previous == "boltgun-storm-shield"
			var new_shield := next_loadout == "boltgun-storm-shield"
			if old_shield != new_shield:
				var delta := 5 if new_shield else -5
				var cost_error := _adjust_profile_option_cost(state, player, target, "thunderwolf-cavalry", delta, "Storm Shield")
				if not cost_error.is_empty(): return {"error": cost_error}
				state.squads[target].training_cost = int(state.squads[target].get("training_cost", 0)) + delta
			bearer.thunderwolf_cavalry_loadout = next_loadout
			bearer.thunderwolf_cavalry_storm_shield = new_shield
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"wulfen-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			var identity := A.identity(bearer)
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or identity not in ["wulfen", "wulfen-with-storm-shields"]: return {"error": "Choose a living Wulfen model from your army preparations."}
			var next_loadout := str(selected.get("value", ""))
			if not _wulfen_loadout_valid(state, target, model, next_loadout): return {"error": "Choose Death Totem or the source-listed Stormfrag Auto-launcher replacement."}
			var weapons := MarineProfiles.wulfen_weapons(next_loadout) if identity == "wulfen" else MarineProfiles.wulfen_storm_shields_weapons(next_loadout)
			if weapons.is_empty(): return {"error": "The selected Wulfen loadout has no source-matched weapon profile."}
			bearer.wulfen_loadout = next_loadout
			bearer.wulfen_death_totem = next_loadout == "death-totem"
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"wolf-scouts-loadout", "wolf-scouts-haywire-mine":
			return _configure_wolf_scouts_choice(state, player, selected)
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
		"sanguinary-guard-inferno-pistol":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "sanguinary-guard": return {"error": "Choose a living Sanguinary Guard model during your army preparation."}
			if selected.value not in ["on", "off"]: return {"error": "Choose whether this model replaces its Angelus Boltgun with an Inferno Pistol."}
			var currently_equipped := bool(bearer.get("sanguinary_guard_inferno_pistol", false))
			if selected.value == "on" and currently_equipped: return {"error": "This model already has an Inferno Pistol."}
			if selected.value == "off" and not currently_equipped: return {"error": "This model has no Inferno Pistol to replace."}
			var component_count := _component_starting_strength(state, bearer)
			var component_limit := MarineProfiles.sanguinary_guard_inferno_limit(component_count)
			var equipped_count := 0
			var loadouts: Array[String] = []
			for member: int in state.units:
				var member_unit: Dictionary = state.units[member]
				if member_unit.squad != target or A.identity(member_unit) != "sanguinary-guard": continue
				var member_equipped := bool(member_unit.get("sanguinary_guard_inferno_pistol", false))
				if member == model: member_equipped = selected.value == "on"
				if member_equipped: equipped_count += 1
				loadouts.append("inferno-pistol" if member_equipped else "angelus-boltgun")
			if selected.value == "on" and equipped_count > component_limit: return {"error": "This Sanguinary Guard unit has reached its one Inferno Pistol per three models limit."}
			if not MarineProfiles.sanguinary_guard_loadouts_valid(loadouts, component_count): return {"error": "The chosen Sanguinary Guard replacement exceeds the source-listed per-three-model limit."}
			bearer.sanguinary_guard_inferno_pistol = selected.value == "on"
			var weapons := MarineProfiles.sanguinary_guard_weapons(bearer.sanguinary_guard_inferno_pistol)
			if weapons.is_empty(): return {"error": "The source-listed Sanguinary Guard weapon profile is unavailable."}
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"black-knight-grenade-launcher":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "ravenwing-black-knights": return {"error": "This equipment choice belongs to a living Ravenwing Black Knight."}
			if selected.value not in ["on", "off"]: return {"error": "Invalid Grenade Launcher replacement."}
			var equipped_count := 0
			for member: int in state.units:
				if state.units[member].squad == target and A.identity(state.units[member]) == "ravenwing-black-knights" and state.units[member].get("black_knight_grenade_launcher", false): equipped_count += 1
			var limit := int(_component_starting_strength(state, bearer) / 3.0)
			if selected.value == "on" and (bearer.get("black_knight_grenade_launcher", false) or equipped_count >= limit): return {"error": "This Ravenwing Black Knight unit has reached its one Grenade Launcher per three models limit."}
			if selected.value == "off" and not bearer.get("black_knight_grenade_launcher", false): return {"error": "This model does not have a Grenade Launcher to replace."}
			bearer.black_knight_grenade_launcher = selected.value == "on"
			var weapons := MarineProfiles.ravenwing_black_knight_weapons(bearer.black_knight_grenade_launcher)
			if weapons.ranged.size() != 2 or weapons.melee.is_empty(): return {"error": "The selected Ravenwing Black Knight loadout is not listed on its source datasheet."}
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"ravenwing-command-grenade-launcher":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "ravenwing-command-squad" or str(bearer.get("ravenwing_command_role", "")) not in ["Ravenwing Ancient", "Ravenwing Apothecary", "Ravenwing Champion"]: return {"error": "This equipment choice belongs to a living Ravenwing Command Squad model."}
			if selected.value not in ["on", "off"]: return {"error": "Invalid Ravenwing Command Squad Grenade Launcher replacement."}
			var equipped_count := 0
			for member: int in state.units:
				if state.units[member].squad == target and A.identity(state.units[member]) == "ravenwing-command-squad" and state.units[member].get("ravenwing_command_grenade_launcher", false): equipped_count += 1
			var limit := int(state.squads[target].starting_strength / 3.0)
			if selected.value == "on" and (bearer.get("ravenwing_command_grenade_launcher", false) or equipped_count >= limit): return {"error": "This Ravenwing Command Squad has reached its one Grenade Launcher per three models limit."}
			if selected.value == "off" and not bearer.get("ravenwing_command_grenade_launcher", false): return {"error": "This model has no Grenade Launcher to replace."}
			bearer.ravenwing_command_grenade_launcher = selected.value == "on"
			var weapons := MarineProfiles.ravenwing_command_weapons(str(bearer.ravenwing_command_role), bearer.ravenwing_command_grenade_launcher)
			if weapons.ranged.size() != 2 or weapons.melee.size() != 1: return {"error": "Could not resolve the selected Ravenwing Command Squad loadout."}
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"terminator-special-weapon":
			var bearer: Dictionary = state.units.get(model, {})
			var identity := A.identity(bearer)
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or identity not in ["terminator-squad", "deathwing-terminator-squad", "deathwatch-terminator-squad"] or bearer.get("sergeant", false): return {"error": "Only a living Terminator model, not its Sergeant, may replace its Storm Bolter."}
			if identity == "deathwatch-terminator-squad" and not _deathwatch_terminator_keeps_storm_bolter(str(bearer.get("deathwatch_terminator_melee_package", "power-fist"))): return {"error": "This Deathwatch Terminator package has replaced its Storm Bolter, so it cannot take a second Storm Bolter replacement."}
			var allowed_specials: Array[String] = ["none", "assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]
			if identity in ["deathwing-terminator-squad", "deathwatch-terminator-squad"]: allowed_specials.append("plasma-cannon")
			if selected.value not in allowed_specials: return {"error": "Unsupported Terminator ranged weapon replacement."}
			var previous: String = bearer.get("terminator_special_weapon", "")
			var next: String = "" if selected.value == "none" else selected.value
			var limit := _deathwatch_terminator_special_limit(state, target) if identity == "deathwatch-terminator-squad" else int(state.squads[target].starting_strength / 5.0)
			if not next.is_empty() and previous.is_empty() and _terminator_special_count(state, target) >= limit: return {"error": "This Terminator unit has reached its one special weapon per five models limit."}
			if (previous == "cyclone-missile-launcher") != (next == "cyclone-missile-launcher"):
				var point_delta := 10 if next == "cyclone-missile-launcher" else -10
				var cost_error := _adjust_profile_option_cost(state, player, target, identity, point_delta, "Cyclone Missile Launcher")
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
		"slayer-oath":
			var ulrik: Dictionary = state.units.get(model, {})
			var ulrik_squad := int(ulrik.get("squad", -1))
			if ulrik.is_empty() or int(ulrik.get("owner", -1)) != player or int(ulrik.get("wounds", 0)) <= 0 or A.identity(ulrik) != "ulrik-the-slayer": return {"error": "Slayer's Oath choices belong to a living Ulrik the Slayer."}
			if battle_actor(state) != player: return {"error": "Slayer's Oath is selected at the start of the first battle round."}
			if selected.value not in ["initial", "pass-initial"]: return {"error": "Invalid Slayer's Oath choice."}
			if selected.value == "pass-initial" and target != ulrik_squad: return {"error": "Invalid Slayer's Oath skip choice."}
			var oath_error := UlrikTheSlayer.resolve_initial(state, ulrik_squad, target if selected.value == "initial" else -1)
			if not oath_error.is_empty(): return {"error": oath_error}
		"purgatus-quarry":
			var quarry_model: Dictionary = state.units.get(model, {})
			var source_squad: int = int(quarry_model.get("squad", -1))
			if quarry_model.is_empty() or int(quarry_model.get("owner", -1)) != player or quarry_model.get("wounds", 0) <= 0 or A.identity(quarry_model) != "watch-master" or not state.squads.has(source_squad): return {"error": "Purgatus Quarry choices belong to a living Watch Master."}
			if selected.value == "initial":
				if battle_actor(state) != player: return {"error": "The initial quarry is selected at the start of the first battle round."}
				var initial_error := A.resolve_initial_purgatus_quarry(state, source_squad, target)
				if not initial_error.is_empty(): return {"error": initial_error}
			elif selected.value == "pass-initial":
				if battle_actor(state) != player or target != source_squad: return {"error": "Only the owning player may pass on this Watch Master's initial quarry choice."}
				var pass_initial_error := A.resolve_initial_purgatus_quarry(state, source_squad, -1)
				if not pass_initial_error.is_empty(): return {"error": pass_initial_error}
			elif selected.value == "replacement" or selected.value == "pass-replacement":
				var replacement_target := target if selected.value == "replacement" else -1
				if selected.value == "pass-replacement" and target != source_squad: return {"error": "Invalid Purgatus Quarry pass choice."}
				var replacement_error := A.advance_destroyed_mark_queue(state, source_squad, replacement_target)
				if not replacement_error.is_empty(): return {"error": replacement_error}
				if a.window.is_empty() and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true}
			else: return {"error": "Invalid Purgatus Quarry choice."}
		"headhunter-quarry":
			var headhunter_model: Dictionary = state.units.get(model, {})
			var source_squad := int(headhunter_model.get("squad", -1))
			if headhunter_model.is_empty() or int(headhunter_model.get("owner", -1)) != player or int(headhunter_model.get("wounds", 0)) <= 0 or A.identity(headhunter_model) != "wolf-guard-headtakers" or not state.squads.has(source_squad): return {"error": "Headhunters choices belong to a living Wolf Guard Headtaker unit."}
			if selected.value == "initial":
				if battle_actor(state) != player: return {"error": "Headhunters selects its initial quarry at the start of the first battle round."}
				var initial_error := A.resolve_initial_headhunter_quarry(state, source_squad, target)
				if not initial_error.is_empty(): return {"error": initial_error}
			elif selected.value == "pass-initial":
				if battle_actor(state) != player or target != source_squad: return {"error": "Only the owning player may pass on this unit's initial Headhunters choice."}
				var pass_initial_error := A.resolve_initial_headhunter_quarry(state, source_squad, -1)
				if not pass_initial_error.is_empty(): return {"error": pass_initial_error}
			elif selected.value == "replacement":
				var replacement_error := A.advance_destroyed_mark_queue(state, source_squad, target)
				if not replacement_error.is_empty(): return {"error": replacement_error}
				if a.window.is_empty() and not state.get("pending_attack", {}).is_empty(): return {"error": "", "resume_attack": true}
			else: return {"error": "Invalid Headhunters quarry choice."}
		"wolf-guard-headtakers-split":
			if setup_actor(state) != player or selected.model != -1 or selected.value != "split" or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player: return {"error": "Let Loose the Wolves is optional during your Declare Battle Formations step."}
			var split_error := _split_wolf_guard_headtakers(state, target)
			if not split_error.is_empty(): return {"error": split_error}
		"wolf-guard-headtaker-storm-shield":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or A.identity(bearer) != "wolf-guard-headtakers" or str(bearer.get("wolf_guard_headtaker_role", "")) != "wolf-guard-headtaker" or selected.value not in ["on", "off"]: return {"error": "Choose Storm Shield equipment for a Wolf Guard Headtaker during your army preparations."}
			var shield_equipped: bool = selected.value == "on"
			var headtaker_loadout := MarineProfiles.wolf_guard_headtaker_model_loadout("wolf-guard-headtaker", shield_equipped)
			if headtaker_loadout.is_empty(): return {"error": "The selected Headtaker equipment is not listed on its source datasheet."}
			bearer.wolf_guard_headtaker_storm_shield = shield_equipped
			bearer.melee_weapons = headtaker_loadout.melee.duplicate(true)
			bearer.defense = {"toughness": headtaker_loadout.stats.toughness, "save_target": headtaker_loadout.stats.save_target, "invulnerable_target": headtaker_loadout.stats.invulnerable_target}
		"scout-gun":
			if A.identity(state.units[model]) != "scout-squad" or target != state.units[model].squad or selected.value not in _scout_gun_options(state, model): return {"error": "This Scout ranged replacement exceeds its source option limits."}
			state.units[model].scout_gun = selected.value
			state.units[model].ranged_weapons = MarineProfiles.scout_ranged(selected.value)
		"scout-blade":
			if A.identity(state.units[model]) != "scout-squad" or not state.units[model].get("sergeant", false) or target != state.units[model].squad or selected.value not in ["combat-knife", "chainsword"]: return {"error": "Only the Scout Sergeant may replace its Combat Knife with a Chainsword."}
			state.units[model].scout_blade = selected.value
			state.units[model].melee_weapons = MarineProfiles.scout_melee(selected.value)
		"assault-intercessor-pistol", "assault-intercessor-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "assault-intercessor-squad" or not bearer.get("sergeant", false): return {"error": "This replacement belongs to a living Assault Intercessor Sergeant."}
			if selected.action == "assault-intercessor-pistol":
				if selected.value not in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]: return {"error": "Unsupported Assault Intercessor Sergeant pistol replacement."}
				var pistol := MarineProfiles.assault_intercessor_sergeant_pistol(str(selected.value))
				if pistol.is_empty(): return {"error": "The selected Assault Intercessor pistol profile is unavailable."}
				bearer.ranged_weapons = [pistol]
			else:
				if selected.value not in ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]: return {"error": "Unsupported Assault Intercessor Sergeant melee replacement."}
				var melee := MarineProfiles.assault_intercessor_sergeant_melee(str(selected.value))
				if melee.is_empty(): return {"error": "The selected Assault Intercessor melee profile is unavailable."}
				bearer.melee_weapons = [melee]
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
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "captain": return {"error": "Choose source-listed Captain equipment during your army preparation."}
			var ranged_loadout: String = str(bearer.get("captain_ranged_loadout", "default"))
			var power_fist: bool = bool(bearer.get("captain_power_fist", false))
			if selected.action == "captain-ranged-loadout":
				if selected.value not in ["default", "neo-volkite", "plasma-pistol", "relic-shield"]: return {"error": "Unsupported Captain ranged equipment choice."}
				if selected.value == "relic-shield" and power_fist: return {"error": "The Relic Shield cannot be combined with a Power Fist."}
				ranged_loadout = str(selected.value)
			else:
				if selected.value not in ["power-weapon", "power-fist"]: return {"error": "Unsupported Captain melee equipment choice."}
				if selected.value == "power-fist" and ranged_loadout == "relic-shield": return {"error": "The Relic Shield prevents replacing the Master-crafted Power Weapon."}
				power_fist = selected.value == "power-fist"
			var weapons := MarineProfiles.captain_weapons(ranged_loadout, power_fist)
			if weapons.is_empty(): return {"error": "Unknown Captain loadout."}
			bearer.captain_ranged_loadout = ranged_loadout
			bearer.captain_power_fist = power_fist
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
			bearer.relic_shield = weapons.relic_shield
			bearer.max_wounds = 6 if weapons.relic_shield else 5
			bearer.wounds = bearer.max_wounds
		"blood-angels-captain-ranged-loadout", "blood-angels-captain-melee-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "blood-angels-captain": return {"error": "Choose source-listed Blood Angels Captain equipment during your army preparation."}
			var pistol_package: String = str(bearer.get("blood_angels_captain_pistol_package", "heavy-bolt-pistol"))
			var melee_package: String = str(bearer.get("blood_angels_captain_melee_package", "master-crafted-chainsword"))
			if selected.action == "blood-angels-captain-ranged-loadout":
				if selected.value not in ["heavy-bolt-pistol", "inferno-pistol"]: return {"error": "Unsupported Blood Angels Captain ranged equipment choice."}
				pistol_package = str(selected.value)
			else:
				if selected.value not in ["master-crafted-chainsword", "power-fist", "relic-weapon"]: return {"error": "Unsupported Blood Angels Captain melee equipment choice."}
				melee_package = str(selected.value)
			var weapons := MarineProfiles.blood_angels_captain_weapons(pistol_package, melee_package)
			if weapons.is_empty(): return {"error": "Unknown Blood Angels Captain loadout."}
			bearer.blood_angels_captain_pistol_package = pistol_package
			bearer.blood_angels_captain_melee_package = melee_package
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"death-company-captain-ranged-loadout", "death-company-captain-melee-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "death-company-captain": return {"error": "Choose source-listed Death Company Captain equipment during your army preparation."}
			var pistol_package: String = str(bearer.get("death_company_captain_pistol_package", "heavy-bolt-pistol"))
			var melee_package: String = str(bearer.get("death_company_captain_melee_package", "master-crafted-chainsword"))
			if selected.action == "death-company-captain-ranged-loadout":
				if selected.value not in ["heavy-bolt-pistol", "inferno-pistol"]: return {"error": "Unsupported Death Company Captain ranged equipment choice."}
				pistol_package = str(selected.value)
			else:
				if selected.value not in ["master-crafted-chainsword", "power-fist", "relic-weapon"]: return {"error": "Unsupported Death Company Captain melee equipment choice."}
				melee_package = str(selected.value)
			var weapons := MarineProfiles.death_company_captain_weapons(pistol_package, melee_package)
			if weapons.is_empty(): return {"error": "Unknown Death Company Captain loadout."}
			bearer.death_company_captain_pistol_package = pistol_package
			bearer.death_company_captain_melee_package = melee_package
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"death-company-jump-captain-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "death-company-captain-with-jump-pack": return {"error": "Choose source-listed Death Company Captain with Jump Pack equipment during your army preparation."}
			var weapons := MarineProfiles.death_company_jump_captain_weapons(str(selected.value))
			if weapons.is_empty(): return {"error": "Unsupported Death Company Captain with Jump Pack equipment choice."}
			bearer.death_company_jump_captain_loadout = str(selected.value)
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
			bearer.relic_shield = bool(weapons.get("relic_shield", false))
			bearer.max_wounds = 6 if bearer.relic_shield else 5
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
		"blood-claws-pack-leader-pistol", "blood-claws-pack-leader-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "blood-claws" or not bearer.get("sergeant", false): return {"error": "Choose source-listed Blood Claws Pack Leader equipment during army preparation."}
			var pistol_package := str(bearer.get("blood_claws_pack_leader_pistol", "bolt-pistol"))
			var melee_package := str(bearer.get("blood_claws_pack_leader_melee", "chainsword"))
			var profile := MarineProfiles.profile("blood-claws")
			if selected.action == "blood-claws-pack-leader-pistol":
				if selected.value not in profile.options.pack_leader_ranged_packages: return {"error": "Choose the Bolt Pistol or Plasma Pistol listed for the Blood Claw Pack Leader."}
				pistol_package = str(selected.value)
			else:
				if selected.value not in profile.options.pack_leader_melee_packages: return {"error": "Choose the Chainsword or Power Weapon listed for the Blood Claw Pack Leader."}
				melee_package = str(selected.value)
			var blood_claws_weapons := MarineProfiles.blood_claws_pack_leader_weapons(pistol_package, melee_package)
			if blood_claws_weapons.is_empty(): return {"error": "The selected Blood Claw Pack Leader equipment is not listed on its source datasheet."}
			bearer.blood_claws_pack_leader_pistol = pistol_package
			bearer.blood_claws_pack_leader_melee = melee_package
			bearer.ranged_weapons = blood_claws_weapons.ranged
			bearer.melee_weapons = blood_claws_weapons.melee
		"grey-hunters-pack-leader-pistol", "grey-hunters-pack-leader-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "grey-hunters" or not bearer.get("sergeant", false): return {"error": "Choose source-listed Grey Hunters Pack Leader equipment during army preparation."}
			var pistol_package := str(bearer.get("grey_hunters_pack_leader_pistol", "bolt-pistol"))
			var melee_package := str(bearer.get("grey_hunters_pack_leader_melee", "chainsword"))
			var profile := MarineProfiles.profile("grey-hunters")
			if selected.action == "grey-hunters-pack-leader-pistol":
				if selected.value not in profile.options.pack_leader_ranged_packages: return {"error": "Choose the Bolt Pistol or Plasma Pistol listed for the Grey Hunter Pack Leader."}
				pistol_package = str(selected.value)
			else:
				if selected.value not in profile.options.pack_leader_melee_packages: return {"error": "Choose the Chainsword, Power Fist or Power Weapon listed for the Grey Hunter Pack Leader."}
				melee_package = str(selected.value)
			var grey_hunters_weapons := MarineProfiles.grey_hunters_pack_leader_weapons(pistol_package, melee_package)
			if grey_hunters_weapons.is_empty(): return {"error": "The selected Grey Hunter Pack Leader equipment is not listed on its source datasheet."}
			bearer.grey_hunters_pack_leader_pistol = pistol_package
			bearer.grey_hunters_pack_leader_melee = melee_package
			bearer.ranged_weapons = grey_hunters_weapons.ranged
			bearer.melee_weapons = grey_hunters_weapons.melee
		"grey-hunters-split-toggle":
			if setup_actor(state) != player or selected.value not in ["select", "remove"] or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or bool(state.squads[target].get("old_greymanes_split", false)): return {"error": "Old Greymanes model selection is available only during your Declare Battle Formations step."}
			var available_models := _grey_hunter_models(state, target)
			if available_models.size() != 10 or model not in available_models: return {"error": "Select a model from the ten Grey Hunters in this unit."}
			var drafts: Dictionary = state.unit_abilities.get("old_greymanes_drafts", {}).duplicate(true)
			var draft: Array[int] = []
			for drafted_model: Variant in drafts.get(str(target), []): draft.append(int(drafted_model))
			if selected.value == "select":
				if draft.has(model) or draft.size() >= 5: return {"error": "Select no more than five distinct Grey Hunter models for Pack 2."}
				draft.append(model)
			else:
				if not draft.has(model): return {"error": "Remove only a model currently selected for Pack 2."}
				draft.erase(model)
			drafts[str(target)] = draft
			state.unit_abilities.old_greymanes_drafts = drafts
		"old-greymanes-cancel":
			if setup_actor(state) != player or selected.value != "cancel" or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player: return {"error": "Cancel only your pending Old Greymanes split draft during Declare Battle Formations."}
			state.unit_abilities.get("old_greymanes_drafts", {}).erase(str(target))
		"old-greymanes-confirm":
			if setup_actor(state) != player or selected.model != -1 or selected.value != "split" or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player: return {"error": "Confirm Old Greymanes only for your Grey Hunters unit during Declare Battle Formations."}
			var selected_models: Array[int] = []
			for drafted_model: Variant in state.unit_abilities.get("old_greymanes_drafts", {}).get(str(target), []): selected_models.append(int(drafted_model))
			if selected_models.size() != 5: return {"error": "Select exactly five Grey Hunter models before confirming the Old Greymanes split."}
			var split_error := _split_grey_hunters(state, target, selected_models)
			if not split_error.is_empty(): return {"error": split_error}
		"castellan-ranged-loadout", "castellan-melee-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "castellan": return {"error": "Choose Castellan equipment during your army preparation."}
			var ranged_package := str(bearer.get("castellan_ranged_package", "combi-weapon"))
			var melee_package := str(bearer.get("castellan_melee_package", "master-crafted-power-weapon"))
			if selected.action == "castellan-ranged-loadout":
				if selected.value not in MarineProfiles.profile("castellan").options.ranged_packages: return {"error": "Choose the Combi-weapon or its Heavy Bolt Pistol replacement."}
				ranged_package = str(selected.value)
			else:
				if selected.value not in MarineProfiles.profile("castellan").options.melee_packages: return {"error": "Choose the Master-crafted Power Weapon or its Chainsword replacement."}
				melee_package = str(selected.value)
			var weapons := MarineProfiles.castellan_weapons(ranged_package, melee_package)
			if weapons.is_empty(): return {"error": "The selected Castellan equipment combination is not listed on its source datasheet."}
			bearer.castellan_ranged_package = ranged_package
			bearer.castellan_melee_package = melee_package
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"marshal-ranged-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "marshal": return {"error": "Choose Marshal equipment during your army preparation."}
			if selected.value not in MarineProfiles.profile("marshal").options.ranged_packages: return {"error": "Choose the Plasma Pistol or its Combi-weapon replacement."}
			var weapons := MarineProfiles.marshal_weapons(str(selected.value))
			if weapons.is_empty(): return {"error": "The selected Marshal equipment is not listed on its source datasheet."}
			bearer.marshal_ranged_package = str(selected.value)
			bearer.ranged_weapons = weapons.ranged
			bearer.melee_weapons = weapons.melee
		"nephilim-jetfighter-loadout":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or A.identity(bearer) != "nephilim-jetfighter": return {"error": "Nephilim Jetfighter weapons are selected during army preparation."}
			if selected.value not in ["twin-heavy-bolter", "lascannons"]: return {"error": "Choose the Twin Heavy Bolter or Nephilim Lascannons replacement."}
			bearer.nephilim_lascannons = selected.value == "lascannons"
			bearer.ranged_weapons = MarineProfiles.nephilim_jetfighter_weapons(bearer.nephilim_lascannons)
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
		"healing-balms":
			var priest: Dictionary = state.units.get(model, {})
			if state.phase != "command" or state.active != player or priest.is_empty() or int(priest.get("owner", -1)) != player or int(priest.get("squad", -1)) != target or A.identity(priest) != "wolf-priest" or not priest.get("on_battlefield", true): return {"error": "Healing Balms can only be used by your living Wolf Priest during your Command phase."}
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or not A.sources(state, target, "healing-balms").has(model) or state.unit_abilities.get("reserves", {}).has(target) or TransportRules.squad_embarked(state, target) or not Healing.needed(state, target): return {"error": "Healing Balms requires its living Wolf Priest to be with a friendly unit that can receive healing."}
			if a.used.get("healing-balms:%d" % target, -1) == state.turn: return {"error": "This unit has already used Healing Balms this turn."}
			var balms_roll := RandomStat.roll("D3+1", roller)
			if not balms_roll.error.is_empty(): return balms_roll
			var balms_result := Healing.begin(state, target, balms_roll.value, model, balms_roll)
			if str(balms_result.get("error", "")).is_empty(): a.used["healing-balms:%d" % target] = state.turn
			return balms_result
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
		"crusader-squad-loadout":
			var crusader_unit: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or crusader_unit.is_empty() or int(crusader_unit.get("owner", -1)) != player or int(crusader_unit.get("squad", -1)) != target or int(crusader_unit.get("wounds", 0)) <= 0 or A.identity(crusader_unit) != "crusader-squad": return {"error": "Crusader Squad equipment is selected during its owner's army preparation."}
			var crusader_count := int(state.squads[target].get("starting_strength", 0))
			var crusader_index := int(crusader_unit.get("crusader_squad_model", -1))
			var current_loadout := str(crusader_unit.get("crusader_squad_loadout", "default"))
			if str(selected.value) not in MarineProfiles.crusader_squad_loadout_options(crusader_index, crusader_count): return {"error": "This Crusader Squad model cannot take the selected source-listed loadout."}
			if str(selected.value) in ["heavy-pistol-power-fist", "pyreblaster"] and current_loadout not in ["heavy-pistol-power-fist", "pyreblaster"] and _crusader_squad_limited_loadout_count(state, target) >= int(crusader_count / 10.0) * 2: return {"error": "This Crusader Squad has used all source-listed Initiate heavy-weapon replacements."}
			var crusader_loadout := MarineProfiles.crusader_squad_model_loadout(crusader_index, crusader_count, str(selected.value))
			if crusader_loadout.is_empty(): return {"error": "The selected Crusader Squad loadout is not present in the local profile."}
			crusader_unit.crusader_squad_role = crusader_loadout.role
			crusader_unit.crusader_squad_loadout = str(selected.value)
			crusader_unit.ranged_weapons = crusader_loadout.ranged.duplicate(true)
			crusader_unit.melee_weapons = crusader_loadout.melee.duplicate(true)
		"execrator-pistol-loadout", "execrator-extra-melee":
			var execrator_unit: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or execrator_unit.is_empty() or int(execrator_unit.get("owner", -1)) != player or int(execrator_unit.get("squad", -1)) != target or int(execrator_unit.get("wounds", 0)) <= 0 or A.identity(execrator_unit) != "execrator": return {"error": "Execrator equipment is selected during its owner's army preparation."}
			var pistol_package := str(execrator_unit.get("execrator_pistol_package", "absolvor-bolt-pistol"))
			var extra_power_weapon := bool(execrator_unit.get("execrator_mastercrafted_power_weapon", false))
			if selected.action == "execrator-pistol-loadout":
				if extra_power_weapon: return {"error": "An Execrator equipped with the Master-crafted Power Weapon cannot replace its Absolvor Bolt Pistol."}
				if str(selected.get("value", "")) not in MarineProfiles.profile("execrator").get("options", {}).get("ranged_packages", []): return {"error": "Choose the Absolvor Bolt Pistol or its Hand Flamer replacement."}
				pistol_package = str(selected.value)
			else:
				if str(selected.get("value", "")) not in ["on", "off"]: return {"error": "Choose whether to equip the additional Master-crafted Power Weapon."}
				extra_power_weapon = str(selected.value) == "on"
				if extra_power_weapon and pistol_package != "absolvor-bolt-pistol": return {"error": "The additional Master-crafted Power Weapon requires the Absolvor Bolt Pistol to remain equipped."}
			var execrator_loadout := MarineProfiles.execrator_weapons(pistol_package, extra_power_weapon)
			if execrator_loadout.is_empty(): return {"error": "That Execrator equipment combination is not listed on its current datasheet."}
			execrator_unit.execrator_pistol_package = pistol_package
			execrator_unit.execrator_mastercrafted_power_weapon = extra_power_weapon
			execrator_unit.ranged_weapons = execrator_loadout.ranged
			execrator_unit.melee_weapons = execrator_loadout.melee
		"sword-brethren-loadout":
			var sword_brethren_unit: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or sword_brethren_unit.is_empty() or int(sword_brethren_unit.get("owner", -1)) != player or int(sword_brethren_unit.get("squad", -1)) != target or int(sword_brethren_unit.get("wounds", 0)) <= 0 or A.identity(sword_brethren_unit) != "sword-brethren-squad": return {"error": "Sword Brethren equipment is selected during its owner's army preparation."}
			var sword_brethren_count := int(state.squads[target].get("starting_strength", 0))
			var sword_brethren_index := int(sword_brethren_unit.get("sword_brethren_model", -1))
			var sword_brethren_loadout_id := str(selected.get("value", ""))
			if sword_brethren_loadout_id not in MarineProfiles.sword_brethren_loadout_options(sword_brethren_index, sword_brethren_count): return {"error": "This Sword Brethren model cannot take the selected source-listed loadout."}
			if not _sword_brethren_loadout_valid(state, target, model, sword_brethren_loadout_id): return {"error": "This Sword Brethren unit exceeds one of the datasheet's per-four-model replacement limits."}
			var sword_brethren_loadout := MarineProfiles.sword_brethren_model_loadout(sword_brethren_index, sword_brethren_count, sword_brethren_loadout_id)
			if sword_brethren_loadout.is_empty(): return {"error": "This Sword Brethren loadout is not in the current local datasheet profile."}
			sword_brethren_unit.sword_brethren_loadout = sword_brethren_loadout_id
			sword_brethren_unit.ranged_weapons = sword_brethren_loadout.ranged.duplicate(true)
			sword_brethren_unit.melee_weapons = sword_brethren_loadout.melee.duplicate(true)
		"bladeguard": return Bladeguard.choose(state, selected.value)
		"bladeguard-pistol":
			state.units[model].ranged_weapons = [MarineProfiles.bladeguard_pistol(selected.value)]
		"sternguard-melee":
			state.units[model].melee_weapons = [MarineProfiles.sternguard_melee(selected.value)]
		"sternguard-gun":
			state.units[model].ranged_weapons[0] = MarineProfiles.sternguard_gun(selected.value)
			state.units[model].sternguard_special = selected.value != "firearm"
		"eliminator-sergeant":
			var sergeant: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or sergeant.is_empty() or sergeant.owner != player or sergeant.squad != target or sergeant.wounds <= 0 or A.identity(sergeant) != "eliminator-squad" or not sergeant.get("sergeant", false): return {"error": "Choose a living Eliminator Sergeant during your army preparation."}
			if selected.value not in ["sniper", "las", "carbine"]: return {"error": "Unsupported Eliminator Sergeant replacement."}
			if sergeant.ranged_weapons.is_empty() or str(sergeant.ranged_weapons[0].get("id", "")) not in ["bolt-sniper-rifle", "las-fusil", "instigator-bolt-carbine"]: return {"error": "The Sergeant's current ranged weapon cannot be replaced through this datasheet option."}
			sergeant.ranged_weapons[0] = MarineProfiles.eliminator_gun(selected.value)
		"eliminator-troopers":
			var trooper: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or trooper.is_empty() or trooper.owner != player or trooper.squad != target or trooper.wounds <= 0 or A.identity(trooper) != "eliminator-squad" or trooper.get("sergeant", false): return {"error": "Choose a living ordinary Eliminator during your army preparation."}
			if selected.value not in ["sniper", "las"]: return {"error": "Ordinary Eliminators may exchange only their Bolt Sniper Rifle for a Las Fusil."}
			if trooper.ranged_weapons.is_empty() or str(trooper.ranged_weapons[0].get("id", "")) not in ["bolt-sniper-rifle", "las-fusil"]: return {"error": "The Eliminator's current ranged weapon cannot be replaced through this datasheet option."}
			trooper.ranged_weapons[0] = MarineProfiles.eliminator_gun(selected.value)
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
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or not state.squads.has(target) or int(state.squads[target].owner) != player or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "eradicator-squad-with-melta-rifles": return {"error": "Choose a living model in your Melta Rifle Eradicator squad during army preparation."}
			if selected.value not in ["multi", "rifle"] or bearer.get("ranged_weapons", []).is_empty(): return {"error": "Choose a supported Melta Rifle or Multi-melta loadout."}
			var current_weapon := str(bearer.ranged_weapons[0].get("id", ""))
			var equip_multi: bool = selected.value == "multi"
			if equip_multi and (bearer.get("multi_melta", false) or current_weapon != "melta-rifle"): return {"error": "Only a model with its current Melta Rifle can take this Multi-melta option."}
			if not equip_multi and (not bearer.get("multi_melta", false) or current_weapon != "multi-melta"): return {"error": "Only a model with a Multi-melta can restore its Melta Rifle."}
			var equipped := 0
			for other: int in state.units:
				if int(state.units[other].get("squad", -1)) == target and A.identity(state.units[other]) == "eradicator-squad-with-melta-rifles" and state.units[other].get("multi_melta", false): equipped += 1
			var multi_limit := int(float(state.squads[target].get("starting_strength", 0)) / 3.0)
			if equip_multi and equipped >= multi_limit: return {"error": "This squad already has its maximum number of Multi-meltas."}
			bearer.ranged_weapons[0] = MarineProfiles.eradicator_ranged(equip_multi)
			bearer.multi_melta = equip_multi
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
		"stasis-bomb": return StasisBomb.apply(state, player, selected)
		"stasis-movement-resume": return StasisBomb.continuation(state, player, selected)
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
			if reaction_window.get("kind", "") == DetachmentStratagems.DREAD_CRUSADERS_WINDOW:
				if selected_detachment_rule != DetachmentStratagems.VOW_DREAD_CRUSADERS: return {"error": "Choose Dread Crusaders or decline its current reaction."}
				if spent.get("pending_reroll", false): return spent
				var charge_frame_id := str(reaction_window.get("resolution_frame_id", ""))
				if charge_frame_id.is_empty(): return {"error": "Dread Crusaders has no saved Charge continuation."}
				a.window = {}
				return {"error": "", "resume_charge": true, "charge_frame_id": charge_frame_id, "message": str(spent.get("message", "Dread Crusaders resolved."))}
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
			if reaction_window.get("kind", "") == DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW:
				var honour_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": honour_declaration, "message": str(spent.get("message", "For the Emperor's Honour! resolved."))}
			if reaction_window.get("kind", "") == DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW:
				var spoor_declaration: Dictionary = reaction_window.get("declaration", {}).duplicate(true)
				a.window = {}
				return {"error": "", "resume_declaration": spoor_declaration, "message": str(spent.get("message", "Spoor of the Unholy resolved."))}
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
		"hurtling-use", "evasive-use", "umbral-evasion-use", "angels-defiant-use", "mounted-reaction-pass":
			var hurtling_window: Dictionary = a.get("window", {})
			var angels_spent: Dictionary = {}
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
			elif selected.action == "angels-defiant-use":
				if not bool(hurtling_window.get("can_angels_defiant", false)): return {"error": "Angels Defiant is not eligible for this reaction."}
				angels_spent = DetachmentStratagems.apply(state, player, {"stratagem": DetachmentStratagems.FIST_ANGELS_DEFIANT, "value": DetachmentStratagems.FIST_ANGELS_DEFIANT, "target": target, "model": -1})
				if not str(angels_spent.get("error", "")).is_empty(): return angels_spent
			var hurtling_declaration: Dictionary = hurtling_window.get("declaration", {}).duplicate(true)
			a.window = {}
			var reaction_result := {"error": "", "resume_declaration": hurtling_declaration}
			if selected.action == "umbral-evasion-use": reaction_result.message = "Umbral Evasion: ranged attacks targeting %s have -1 to Hit this Shooting phase." % str(state.squads[target].get("name", "the PHOBOS unit"))
			elif selected.action == "angels-defiant-use": reaction_result.message = str(angels_spent.get("message", "Angels Defiant resolved."))
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
		"for-emperors-honour-pass":
			var honour_window: Dictionary = a.get("window", {})
			if honour_window.get("kind", "") != DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW or honour_window.get("owners", []) != [player] or int(honour_window.get("squad", -1)) != target: return {"error": "No matching For the Emperor's Honour! decision is pending."}
			var honour_declaration: Dictionary = honour_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": honour_declaration}
		"spoor-of-the-unholy-pass":
			var spoor_window: Dictionary = a.get("window", {})
			if spoor_window.get("kind", "") != DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW or spoor_window.get("owners", []) != [player] or int(spoor_window.get("squad", -1)) != target: return {"error": "No matching Spoor of the Unholy decision is pending."}
			var spoor_declaration: Dictionary = spoor_window.get("declaration", {}).duplicate(true)
			a.window = {}
			return {"error": "", "resume_declaration": spoor_declaration}
		"dread-crusaders-pass":
			var dread_window: Dictionary = a.get("window", {})
			var pending_charge: Dictionary = state.get("pending_charge", {})
			var charge_frame_id := str(dread_window.get("resolution_frame_id", ""))
			if dread_window.get("kind", "") != DetachmentStratagems.DREAD_CRUSADERS_WINDOW or dread_window.get("owners", []) != [player] or int(dread_window.get("squad", -1)) != target: return {"error": "No matching Dread Crusaders decision is pending."}
			if not dread_window.get("current_result", {}).is_empty(): return {"error": "The charging unit must resolve its Dread Crusaders Leadership result."}
			if charge_frame_id.is_empty() or pending_charge.is_empty() or int(pending_charge.get("squad", -1)) != int(dread_window.get("attacker_squad", -2)) or target not in pending_charge.get("targets", []): return {"error": "The saved Dread Crusaders Charge continuation is no longer available."}
			a.window = {}
			return {"error": "", "resume_charge": true, "charge_frame_id": charge_frame_id, "message": "Dread Crusaders declined; the charging player can continue selecting targets."}
		"dread-crusaders-roll-decision":
			return DetachmentStratagems.resolve_dread_crusaders_roll_decision(state, player, selected, roller)
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
			for draft_squad: Variant in state.unit_abilities.get("old_greymanes_drafts", {}):
				if state.squads.has(int(draft_squad)) and int(state.squads[int(draft_squad)].get("owner", -1)) == player and not state.unit_abilities.old_greymanes_drafts[draft_squad].is_empty(): return {"error": "Finish or cancel the pending Old Greymanes model selection before completing Declare Battle Formations."}
			var pod_reserve_error := _reserve_required_drop_pods(state, player)
			if not pod_reserve_error.is_empty(): return {"error": pod_reserve_error}
			var aircraft_reserve_error := AircraftRules.force_reserves(state, player)
			if not aircraft_reserve_error.is_empty(): return {"error": aircraft_reserve_error}
			for unit: Dictionary in state.units.values():
				if unit.owner == player and is_support_identity(state, unit) and unit.get("attachment_role", "") != "support": return {"error": "Support units must be attached to an eligible bodyguard."}
			var character := false
			for unit: Dictionary in state.units.values():
				if unit.owner == player and Groups.character(unit): character = true
			if character and not a.get("warlords", {}).has(player): return {"error": "Select your Warlord before finishing preparation."}
			var guilliman := guilliman_model(state, player)
			var lion := lion_model(state, player)
			if guilliman >= 0 and lion >= 0: return {"error": "Roboute Guilliman and Lion El’jonson both require the Warlord role; this roster cannot include both."}
			if guilliman != -1 and a.get("warlords", {}).get(player, -1) != guilliman: return {"error": "Roboute Guilliman must be your Warlord."}
			if lion != -1 and a.get("warlords", {}).get(player, -1) != lion: return {"error": "Lion El’jonson must be your Warlord."}
			var roster_error := RosterValidation.seal(state, player)
			if not roster_error.is_empty(): return {"error": roster_error}
			if not a.has("setup_players"): a.setup_players = []
			a.setup_players.append(player)
			if a.setup_players.size() == 2 and state.deployment.order.is_empty():
				state.deployment.complete = true
				state.phase = "mission_first_turn" if state.get("mission", {}).get("id", "") == "ca-2026-27-dominance-hammer-fixed-v1" else "pre_battle"
				if state.phase == "pre_battle": ScoutMoves.begin(state)
		"deathwing-knights-watcher":
			if setup_actor(state) != player or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or selected.value not in ["on", "off"]: return {"error": "Watcher in the Dark is selected during army preparation for one Deathwing unit."}
			var watcher_identity := ""
			for member: int in G.alive(state, target):
				var identity := A.identity(state.units[member])
				if identity in ["deathwing-knights", "deathwing-terminator-squad"]: watcher_identity = identity
			if watcher_identity.is_empty(): return {"error": "Watcher in the Dark can only be equipped by a Deathwing Knights or Deathwing Terminator unit."}
			var watcher_field := "deathwing_knights_watcher_equipped" if watcher_identity == "deathwing-knights" else "deathwing_terminator_watcher_equipped"
			var equip_watcher: bool = selected.value == "on"
			if bool(state.squads[target].get(watcher_field, false)) == equip_watcher: return {"error": "That Watcher in the Dark loadout is already selected."}
			state.squads[target][watcher_field] = equip_watcher
		"deathwing-knights-melee":
			var bearer: Dictionary = state.units.get(model, {})
			if setup_actor(state) != player or bearer.is_empty() or bearer.owner != player or bearer.squad != target or bearer.wounds <= 0 or A.identity(bearer) != "deathwing-knights": return {"error": "Deathwing Knights melee replacements are selected during army preparation for a living model."}
			var allowed_weapons: Array = ["great-weapon-of-the-unforgiven", "relic-weapon"] if bearer.get("sergeant", false) else ["mace-of-absolution", "power-weapon"]
			if selected.value not in allowed_weapons: return {"error": "This melee replacement does not match the Deathwing Knights model's source options."}
			var selected_weapon := MarineProfiles.deathwing_knight_melee_weapon(str(selected.value))
			if selected_weapon.is_empty(): return {"error": "The selected weapon is not present in the verified Deathwing Knights profile."}
			bearer.deathwing_knight_melee = str(selected.value)
			bearer.melee_weapons = [selected_weapon]
		"battle-done":
			if TemplarVows.needs_choice(state, player):
				var vow_pass_error := TemplarVows.pass_choice(state, player)
				if not vow_pass_error.is_empty(): return {"error": vow_pass_error}
			if not a.has("battle_players"): a.battle_players = []
			a.battle_players.append(player)
		"warlord":
			if A.identity(state.units.get(model, {})) == "murderfang": return {"error": "Murderfang cannot be selected as your Warlord."}
			if A.identity(state.units.get(model, {})) == "cato-sicarius" and LeaderCatalog.army_has_calgar(state, player): return {"error": "Captain of the Honour Guard replaces Cato's Leader role with Support while Marneus Calgar is in the army; choose another Warlord."}
			var mandatory_warlord := guilliman_model(state, player)
			var mandatory_lion := lion_model(state, player)
			if mandatory_warlord >= 0 and mandatory_lion >= 0: return {"error": "Roboute Guilliman and Lion El’jonson both require the Warlord role; this roster cannot include both."}
			if mandatory_warlord < 0: mandatory_warlord = mandatory_lion
			if mandatory_warlord >= 0 and model != mandatory_warlord: return {"error": "The Supreme Commander in your army must be selected as Warlord."}
			if not a.has("warlords"): a.warlords = {}
			a.warlords[player] = model
			for unit: Dictionary in state.units.values():
				if unit.owner == player: unit.keywords.erase("WARLORD")
			state.units[model].keywords.append("WARLORD")
		"attach": attach(state, model, target)
		"homer":
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or not has_teleport_homer(state, target) or a.used.has("homer-set:%d" % target): return {"error": "Set one Teleport Homer for a living friendly unit with that ability during its start-of-battle declaration."}
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
			a.reserves[target] = {"cost": cost, "deep_strike": A.every_model_has(state, target, "deep-strike")}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"parabolic-jetleap":
			if target not in parabolic_jetleap_squads(state, player): return {"error": "Parabolic Jetleap requires an unengaged Inceptor Squad at the end of the opponent's Fight phase."}
			var cost := int(state.squads[target].get("training_cost", 0))
			if cost <= 0: return {"error": "The Inceptor Squad is missing its admitted reserve cost."}
			a.reserves[target] = {"cost": cost, "source": "parabolic-jetleap", "deep_strike": A.every_model_has(state, target, "deep-strike")}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"echo-of-ravenspire":
			if target not in echo_ravenspire_squads(state, player): return {"error": "Echo of the Ravenspire requires Kayvaan Shrike's unengaged unit at the end of your opponent's Fight phase."}
			var reserve_cost := int(state.squads[target].get("training_cost", 0))
			if reserve_cost <= 0: return {"error": "Kayvaan Shrike's unit is missing its admitted reserve cost."}
			a.reserves[target] = {"cost": reserve_cost, "source": "echo-of-ravenspire", "deep_strike": A.every_model_has(state, target, "deep-strike")}
			for unit: Dictionary in state.units.values():
				if unit.squad == target: unit.on_battlefield = false
			state.deployment.order.erase(target)
		"spectrus-doctrines-reserve":
			if target not in spectrus_doctrine_squads(state, player): return {"error": "Spectrus Doctrines requires its unengaged unit at the end of your opponent's Fight phase."}
			var reserve_cost := int(state.squads[target].get("training_cost", 0))
			if reserve_cost <= 0: return {"error": "Spectrus Kill Team is missing its admitted reserve cost."}
			a.reserves[target] = {"cost": reserve_cost, "source": "spectrus-doctrines", "deep_strike": A.every_model_has(state, target, "deep-strike")}
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
		"njal-psychic": return NjalStormcaller.resolve_psychic(state, player, selected, roller)
		NjalStormcaller.STORM_CALLER_WINDOW: return NjalStormcaller.choose_storm_caller(state, player, selected, roller)
		"engulfing-fear", Ezekiel.TARGET_WINDOW, Ezekiel.REROLL_WINDOW: return Ezekiel.resolve(state, player, selected, roller)
		"logic":
			a.used["logic:%d" % model] = true
			state.squads[target].battle_shocked = false
		"acumen":
			a.used["acumen:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
			Doctrines.record_selection(state, player, selected.value)
			a.window = {"kind": "demi", "owners": [player], "doctrine": selected.value}
		"ravenwing-doctrine":
			if state.phase != "command" or state.active != player or model not in A.sources(state, target, "grand-master-of-the-ravenwing") or selected.value not in Doctrines.available(state, player): return {"error": "Grand Master of the Ravenwing is not available for this unit or Combat Doctrine."}
			a.used["ravenwing-doctrine:%d" % target] = state.turn
			a.doctrines[target] = {"doctrine": selected.value}
			Doctrines.record_selection(state, player, selected.value)
		"author":
			a.used["author:%d" % model] = key(state)
			if not a.has("additional_doctrines"): a.additional_doctrines = {}
			if not a.additional_doctrines.has(target): a.additional_doctrines[target] = []
			if selected.value not in a.additional_doctrines[target]: a.additional_doctrines[target].append(selected.value)
			Doctrines.record_selection(state, player, selected.value)
		"lion-primarch":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "command" or state.active != player or pending(state).get("kind", "") != "start" or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or A.identity(bearer) != "lion-eljonson": return {"error": "Primarch of the First Legion is selected for Lion during the owner’s Command phase."}
			if a.used.get("lion-primarch:%d" % target, -1) == state.turn: return {"error": "Lion has already selected Primarch of the First Legion abilities this Command phase."}
			if selected.value not in ["mist-wreathed-shadow-realms", "martial-exemplar", "no-hiding-from-the-watchers"]: return {"error": "Choose one of Lion’s three source-listed Primarch abilities."}
			if selected.value == "mist-wreathed-shadow-realms" and (not bearer.get("on_battlefield", true) or FightQueue.engaged(state, target)): return {"error": "Mist-wreathed Shadow Realms requires Lion’s unit to be on the battlefield and unengaged."}
			if selected.value == "mist-wreathed-shadow-realms":
				var reserve_error := _strategic_reserve_capacity_error(state, player, target)
				if not reserve_error.is_empty(): return {"error": reserve_error}
			if not a.has("lion_primarch_pending"): a.lion_primarch_pending = {}
			if not a.lion_primarch_pending.has(target): a.lion_primarch_pending[target] = []
			if a.lion_primarch_pending[target].size() >= 2 or selected.value in a.lion_primarch_pending[target]: return {"error": "Select at most two different Primarch abilities."}
			a.lion_primarch_pending[target].append(selected.value)
			if a.lion_primarch_pending[target].size() == 2:
				var completion_error := _complete_lion_primarch_choice(state, player, model, target)
				if not completion_error.is_empty():
					a.lion_primarch_pending[target].pop_back()
					return {"error": completion_error}
		"lion-primarch-done":
			if state.phase != "command" or state.active != player or pending(state).get("kind", "") != "start": return {"error": "Finish the Primarch of the First Legion selection in Lion’s owner Command phase."}
			var completion_error := _complete_lion_primarch_choice(state, player, model, target)
			if not completion_error.is_empty(): return {"error": completion_error}
		"lion-master-strategist":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "command" or state.active != player or pending(state).get("kind", "") != "start" or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or A.identity(bearer) != "lion-eljonson": return {"error": "Master Strategist is used for Lion during the owner’s Command phase."}
			if a.used.get("lion-master-strategist:%d" % target, -1) == state.turn or selected.value not in Doctrines.available(state, player): return {"error": "Choose an available Combat Doctrine once during Lion’s Command phase."}
			if not a.has("additional_doctrines"): a.additional_doctrines = {}
			if not a.additional_doctrines.has(target): a.additional_doctrines[target] = []
			if selected.value not in a.additional_doctrines[target]: a.additional_doctrines[target].append(selected.value)
			a.used["lion-master-strategist:%d" % target] = state.turn
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
		"vehement-aggression":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "fight" or state.fight_actor != player or state.fight_step not in ["attacks", "consolidation_reaction"] or target not in FightQueue.choices(state, player) or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or bool(state.squads[target].get("fought", false)) or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "castellan" or not A.has(state, target, "vehement-aggression"):
				return {"error": "Vehement Aggression is chosen when a living Castellan’s unit is selected to fight."}
			var aggression_key := "vehement-aggression:%d" % target
			var previous_test: Dictionary = a.used.get(aggression_key, {})
			if int(previous_test.get("round", -1)) == int(state.round): return {"error": "Vehement Aggression has already been tested for this Fight activation."}
			var leadership_roll := Morale.roll_battle_shock(state, target, roller)
			if not leadership_roll.error.is_empty(): return leadership_roll
			if StormlanceEnhancements.leadership_reroll_available(state, target):
				a.window = {"kind": "vehement-aggression-reroll", "owners": [player], "squad": target, "model": model, "current_result": leadership_roll.duplicate(true), "round": int(state.round)}
				return {"error": "", "pending_reroll": true, "message": "Vehement Aggression: choose whether to re-roll the Leadership test or keep it."}
			var passed := bool(leadership_roll.passed)
			a.used[aggression_key] = {"round": state.round, "owner": player, "rolls": leadership_roll.rolls.duplicate(), "total": leadership_roll.modified_total, "target": leadership_roll.target, "modifier": leadership_roll.modifier, "passed": passed}
			state.fight_selected = target
			var effect := "melee Hit rolls of 1 can be re-rolled" if not passed else "melee Hit and Wound rolls of 1 can be re-rolled"
			return {"error": "", "message": "Vehement Aggression: Leadership roll (%d+) totaled %d (%s); %s for this Fight activation." % [int(leadership_roll.target), int(leadership_roll.modified_total), "passed" if passed else "failed", effect]}
		"vehement-aggression-reroll":
			var window: Dictionary = pending(state)
			var source := int(window.get("model", -1))
			var leadership_roll: Dictionary = window.get("current_result", {}).duplicate(true)
			if window.get("kind", "") != "vehement-aggression-reroll" or window.get("owners", []) != [player] or int(window.get("round", -1)) != int(state.get("round", -2)) or target != int(selected.get("target", -1)) or selected not in choices(state, player):
				return {"error": "There is no matching Vehement Aggression Leadership decision."}
			if selected.get("value", "") == "reroll":
				if not StormlanceEnhancements.leadership_reroll_available(state, target): return {"error": "No eligible Leadership re-roll applies to this roll."}
				var rerolled := Morale.roll_battle_shock(state, target, roller)
				if not str(rerolled.get("error", "")).is_empty(): return rerolled
				rerolled["rerolled_from"] = leadership_roll.get("rolls", []).duplicate()
				rerolled["reroll_source"] = StormlanceEnhancements.leadership_reroll_name(state, target)
				leadership_roll = rerolled
			elif selected.get("value", "") != "keep": return {"error": "Keep the current Vehement Aggression result or use the available Leadership re-roll."}
			var passed := bool(leadership_roll.get("passed", false))
			var aggression_key := "vehement-aggression:%d" % target
			a.used[aggression_key] = {"round": int(state.round), "owner": player, "rolls": leadership_roll.get("rolls", []).duplicate(), "total": leadership_roll.get("modified_total", 0), "target": leadership_roll.get("target", 0), "modifier": leadership_roll.get("modifier", 0), "passed": passed, "rerolled_from": leadership_roll.get("rerolled_from", []).duplicate(), "reroll_source": leadership_roll.get("reroll_source", "")}
			state.fight_selected = target
			a.window = {}
			var effect := "melee Hit rolls of 1 can be re-rolled" if not passed else "melee Hit and Wound rolls of 1 can be re-rolled"
			return {"error": "", "message": "Vehement Aggression: Leadership roll (%d+) totaled %d (%s); %s for this Fight activation." % [int(leadership_roll.get("target", 0)), int(leadership_roll.get("modified_total", 0)), "passed" if passed else "failed", effect]}
		"pious-fervour":
			var bearer: Dictionary = state.units.get(model, {})
			if state.phase != "fight" or state.fight_actor != player or state.fight_step not in ["attacks", "consolidation_reaction"] or target not in FightQueue.choices(state, player) or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or bool(state.squads[target].get("fought", false)) or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("squad", -1)) != target or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "marshal" or not A.has(state, target, "pious-fervour"):
				return {"error": "Pious Fervour is chosen when a living Marshal's unit is selected to fight."}
			var prior_activation: Dictionary = a.get("pious_fervour", {}).get(target, {})
			if int(prior_activation.get("turn", -1)) == int(state.turn): return {"error": "Pious Fervour has already been used for this Fight activation."}
			var nearby_enemy_units := 0
			for enemy_squad: int in state.squads:
				if int(state.squads[enemy_squad].get("owner", -1)) == player or G.alive(state, enemy_squad).is_empty(): continue
				if G.distance_to_target_at_height(state, bearer, enemy_squad) <= 6.0 + G.EPSILON: nearby_enemy_units += 1
			var attack_bonus := mini(nearby_enemy_units, 3)
			if not a.has("pious_fervour"): a.pious_fervour = {}
			a.pious_fervour[target] = {"model": model, "owner": player, "turn": state.turn, "nearby_enemy_units": nearby_enemy_units, "bonus": attack_bonus}
			state.fight_selected = target
			return {"error": "", "message": "Pious Fervour: the Marshal gains +%d melee Attack(s) for this Fight activation." % attack_bonus}
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
		"high-king-fenris":
			var bearer: Dictionary = state.units.get(model, {})
			var source_squad := int(bearer.get("squad", -1))
			var use_key := "high-king-fenris:%d" % source_squad
			if state.phase != "movement" or int(state.get("active", -1)) != player or bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or A.identity(bearer) != "logan-grimnar" or not A.has(state, source_squad, "high-king-of-fenris"):
				return {"error": "High King of Fenris is selected during Logan Grimnar's Movement phase."}
			if int(a.used.get(use_key, -1)) == int(state.round): return {"error": "Logan Grimnar has already selected a unit for High King of Fenris this battle round."}
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player or not a.reserves.has(target) or not A.has_living_unit_keyword(state, target, "SPACE WOLVES"):
				return {"error": "High King of Fenris requires a living friendly SPACE WOLVES unit in Strategic Reserves."}
			if A.high_king_fenris_selected(state, target): return {"error": "This unit already has a High King of Fenris ingress selection."}
			if not a.has("high_king_fenris"): a.high_king_fenris = {}
			a.high_king_fenris[target] = {"owner": player, "source_model": model, "source_squad": source_squad, "selected_round": int(state.round)}
			a.used[use_key] = int(state.round)
		"ingress", "homer-ingress", "relic-teleportarium-ingress":
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) != player: return {"error": "Select one of your own reserve units to ingress."}
			var reserves_value: Variant = state.get("unit_abilities", {}).get("reserves", {})
			if typeof(reserves_value) != TYPE_DICTIONARY or not reserves_value.has(target): return {"error": "This unit is not in strategic reserves."}
			var teleportarium := str(selected.get("action", "")) == "relic-teleportarium-ingress"
			if teleportarium:
				var teleportarium_error := DetachmentStratagems.error(state, player, target, DetachmentStratagems.INNER_CIRCLE_RELIC_TELEPORTARIUM)
				if not teleportarium_error.is_empty(): return {"error": teleportarium_error}
			var early_ingress_enhancement := first_movement_phase_ingress_enhancement(state, target, player)
			var reserve_record: Dictionary = reserves_value[target]
			var lion_mist_ingress: bool = str(reserve_record.get("source", "")) == "mist-wreathed-shadow-realms" and int(reserve_record.get("ingress_turn", -1)) == int(state.turn) and state.phase == "movement" and int(state.active) == player
			if not TransportRules.is_drop_pod(state, target) and not ingress_round_allowed(state, target) and early_ingress_enhancement.is_empty() and not lion_mist_ingress: return {"error": "This unit cannot make an ingress move before battle round 2."}
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
			var deep_strike_ingress := bool(reserve_record.get("deep_strike", _reserve_unit_has_deep_strike(state, target))) and not teleportarium
			a.window = {"kind": "ingress", "owners": [player], "squad": target, "positions": {}, "homer": homer, "deep_strike": deep_strike_ingress, "relic_teleportarium": teleportarium, "resolution_frame_id": ingress_frame_id, "return_window": a.window.duplicate(true)}
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
			if bool(window.get("miraculous_saviour", false)):
				var engaged_enemy := int(window.get("engaged_enemy", -1))
				if engaged_enemy not in Sanguinor.charged_enemy_squads(state, player): return {"error": "Miraculous Saviour requires the selected enemy to remain a unit that made a Charge move this phase."}
				if not Sanguinor.confirms_engagement(projected, int(window.squad), engaged_enemy): return {"error": "Set up The Sanguinor in Engagement Range of the selected charging unit."}
			for id: int in window.positions:
				state.units[id].position = window.positions[id]
				state.units[id].on_battlefield = true
			state.squads[window.squad].moved = true
			state.squads[window.squad].move_type = "ingress"
			state.squads[window.squad].set_up_this_turn = true
			if not a.has("ingress_history"): a.ingress_history = {}
			a.ingress_history[window.squad] = true
			a.reserves.erase(window.squad)
			if a.has("high_king_fenris"): a.high_king_fenris.erase(window.squad)
			end_move(state, window.squad)
			if state.active != player and not bool(window.get("miraculous_saviour", false)):
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
	var uses_deep_strike := bool(window.get("deep_strike", false)) and not bool(window.get("relic_teleportarium", false))
	if not uses_deep_strike:
		var half: Vector2 = state.board_size / 2.0
		var nearest_edge_gap := minf(half.x - absf(point.x), half.y - absf(point.y)) - float(unit.radius)
		if nearest_edge_gap > 6.001: return "Ingress models must be set up wholly within 6 inches of a battlefield edge."
	var ingress_round := int(state.get("round", 0))
	if A.high_king_fenris_selected(state, int(window.get("squad", -1))): ingress_round += 1
	if not uses_deep_strike and ingress_round < 3:
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
		if enemy.owner != unit.owner and not bool(window.get("miraculous_saviour", false)) and distance <= enemy_clearance + 0.001: return "Ingress requires more than %d inches from every enemy unit." % int(enemy_clearance)
	var projected := state.duplicate(true)
	projected.units[model].on_battlefield = true
	projected.units[model].position = point
	return T.path_error(projected, model, point)

static func _reserve_unit_has_deep_strike(state: Dictionary, squad: int) -> bool:
	var found := false
	var owner := int(state.get("squads", {}).get(squad, {}).get("owner", -1))
	var thunderhawk_target := int(state.get("unit_abilities", {}).get("thunderhawk_targets", {}).get(owner, -1)) == squad
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		found = true
		var identity := A.identity(unit)
		var has_deep_strike: bool = "deep-strike" in A.RULES.get(identity, [])
		if identity == "reiver-squad" and not bool(state.squads[squad].get("reiver_grav_chutes", false)): has_deep_strike = false
		if thunderhawk_target: has_deep_strike = true
		if not has_deep_strike: return false
	return found

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

static func _enemy_mark_choices(state: Dictionary, player: int, source_squad: int, ability: String, stage: String) -> Array:
	var result: Array = []
	if not state.squads.has(source_squad): return result
	var sources := A.sources(state, source_squad, ability)
	if sources.is_empty(): return result
	var source_model := sources[0]
	var owner := int(state.squads[source_squad].owner)
	for target: int in A.forward_assault_targets(state, owner):
		if ability == "purgatus-quarry":
			var label := "Watch Master %d: select %s as the hunted unit" % [source_model, state.squads[target].name] if stage == "initial" else "Watch Master %d: replace destroyed quarry with %s" % [source_model, state.squads[target].name]
			result.append(choice(label, "purgatus-quarry", source_model, target, "initial" if stage == "initial" else "replacement"))
		elif ability == "headhunter-quarry":
			var label := "Wolf Guard Headtakers: select %s as quarry" % state.squads[target].name if stage == "initial" else "Wolf Guard Headtakers: select %s as replacement quarry" % state.squads[target].name
			result.append(choice(label, "headhunter-quarry", source_model, target, "initial" if stage == "initial" else "replacement"))
		else:
			var label := "Invictor %d: %s %s" % [source_model, "mark" if stage == "initial" else "replace destroyed mark with", state.squads[target].name]
			result.append(choice(label, "invictor-mark", source_model, target, "initial" if stage == "initial" else "replacement"))
	if ability == "purgatus-quarry" or ability == "headhunter-quarry" and stage == "initial":
		var pass_value := "pass-initial" if stage == "initial" else "pass-replacement"
		var pass_label := "Watch Master %d: do not select a quarry" % source_model if ability == "purgatus-quarry" and stage == "initial" else "Watch Master %d: do not select a new quarry" % source_model if ability == "purgatus-quarry" else "Wolf Guard Headtakers: do not select a quarry"
		result.append(choice(pass_label, ability, source_model, source_squad, pass_value))
	return result

static func battle_actor(state: Dictionary) -> int:
	if not A.enabled(state) or state.phase != "start_turn" or state.turn != 1: return -1
	for owner in [state.get("first_player", 1), 3 - int(state.get("first_player", 1))]:
		if owner in state.unit_abilities.get("battle_players", []): continue
		if TemplarVows.needs_choice(state, int(owner)): return int(owner)
		for unit: Dictionary in state.units.values():
			if unit.owner != owner or unit.wounds <= 0: continue
			if has_teleport_homer(state, int(unit.squad)): return owner
			if A.identity(unit) == "invictor-tactical-warsuit" and A.forward_assault_mark(state, int(unit.squad)) < 0: return owner
			if A.identity(unit) == "watch-master" and not A.purgatus_initial_resolved(state, int(unit.squad)): return owner
			if A.identity(unit) == "wolf-guard-headtakers" and not A.headhunter_initial_resolved(state, int(unit.squad)): return owner
			if A.has(state, int(unit.squad), "slayer-s-oath") and not A.slayer_oath_resolved(state, int(unit.squad)): return owner
	return -1

static func has_teleport_homer(state: Dictionary, squad: int) -> bool:
	if not state.squads.has(squad): return false
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and A.identity(unit) in ["terminator-squad", "terminator-assault-squad", "deathwing-knights", "deathwatch-terminator-squad"]: return true
	return false

static func end_move(state: Dictionary, moved_squad: int, move_type: String = "", sword_brethren_reactions: Array[int] = [], movement_paths: Dictionary = {}) -> void:
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
	FenrisianWolves.open_after_enemy_move(state, moved_squad)
	Techmarine.open_for_move(state, moved_squad, "end")
	TargetAuguryWeb.open_for_move(state, moved_squad, "end")
	SwordBrethren.open_after_enemy_fall_back(state, moved_squad, move_type, sword_brethren_reactions)
	CorvusBlackstar.open_after_normal_move(state, moved_squad, move_type, movement_paths)

static func open_mortis_snares_after_move(state: Dictionary, moved_squad: int, move_type: String) -> bool:
	return DetachmentStratagems.open_mortis_snares_after_move(state, moved_squad, move_type)

## Return the squad whose Movement action owns the open decision stack.
## These specialized windows can be nested through resume_window, so inspect the whole stack.
static func movement_reaction_squad(state: Dictionary) -> int:
	return _movement_reaction_squad(pending(state), 0)

static func _movement_reaction_squad(window: Dictionary, depth: int) -> int:
	if window.is_empty() or depth >= 8: return -1
	var kind := str(window.get("kind", ""))
	if kind == CorvusBlackstar.WINDOW:
		var corvus_squad: Variant = window.get("squad", -1)
		if corvus_squad is int and corvus_squad >= 0: return corvus_squad
	if kind == DetachmentStratagems.UNSTOPPABLE_WINDOW and str(window.get("action", "")) == "movement":
		var selected_squad: Variant = window.get("squad", -1)
		if selected_squad is int and selected_squad >= 0: return selected_squad
	if kind in [CatoSicarius.WINDOW, CatoSicarius.PLACEMENT, FenrisianWolves.WINDOW, FenrisianWolves.PLACEMENT, SwordBrethren.WINDOW, SwordBrethren.PLACEMENT]:
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

static func _crusader_squad_limited_loadout_count(state: Dictionary, squad: int) -> int:
	var count := 0
	for member: int in G.alive(state, squad):
		if A.identity(state.units[member]) != "crusader-squad": continue
		if str(state.units[member].get("crusader_squad_loadout", "default")) in ["heavy-pistol-power-fist", "pyreblaster"]: count += 1
	return count

static func _sword_brethren_loadout_valid(state: Dictionary, squad: int, replaced_model: int, replacement: String) -> bool:
	if not state.squads.has(squad): return false
	var model_count := int(state.squads[squad].get("starting_strength", 0))
	var loadouts: Array[String] = []
	for member: int in state.units:
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != squad or A.identity(unit) != "sword-brethren-squad": continue
		loadouts.append(replacement if member == replaced_model else str(unit.get("sword_brethren_loadout", "default")))
	return MarineProfiles.sword_brethren_loadout_limits_valid(loadouts, model_count)

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
	for model: int in models(state, player, "healing-balms"):
		var squad: int = state.units[model].squad
		if not state.units[model].get("on_battlefield", true) or state.unit_abilities.get("reserves", {}).has(squad) or TransportRules.squad_embarked(state, squad): continue
		if state.unit_abilities.used.get("healing-balms:%d" % squad, -1) != state.turn and Healing.needed(state, squad): result.append(choice("Healing Balms %d: heal D3+1" % model, "healing-balms", model, squad))
	for model: int in models(state, player, "helix-gauntlet"):
		var squad: int = state.units[model].squad
		if not state.units[model].get("on_battlefield", true) or state.unit_abilities.get("reserves", {}).has(squad) or TransportRules.squad_embarked(state, squad): continue
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

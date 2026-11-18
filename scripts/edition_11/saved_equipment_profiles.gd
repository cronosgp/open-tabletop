extends RefCounted
## Explicit source-bounded adapters; never derive legality from visual metadata.
const FIRESTRIKE := "40kdc:11e:adeptus-astartes:firestrike-servo-turrets"
const INFILTRATORS := "40kdc:11e:adeptus-astartes:infiltrator-squad"
const BLADEGUARD := "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad"
const TEMPLAR_GLADIATORS := ["40kdc:11e:adeptus-astartes:black-templars-gladiator-lancer", "40kdc:11e:adeptus-astartes:black-templars-gladiator-reaper", "40kdc:11e:adeptus-astartes:black-templars-gladiator-valiant"]
const THUNDERWOLF := "40kdc:11e:adeptus-astartes:thunderwolf-cavalry"
const WULFEN := "40kdc:11e:adeptus-astartes:wulfen"
const WULFEN_SHIELDS := "40kdc:11e:adeptus-astartes:wulfen-with-storm-shields"
const Deathwing = preload("res://scripts/edition_11/deathwing_saved_equipment.gd")
const Terminators = preload("res://scripts/edition_11/terminator_saved_equipment.gd")
const Deathwatch = preload("res://scripts/edition_11/deathwatch_saved_equipment.gd")
const VanguardVeterans = preload("res://scripts/edition_11/vanguard_veteran_saved_equipment.gd")
const Ravenwing = preload("res://scripts/edition_11/ravenwing_saved_equipment.gd")
const ScoutBikes = preload("res://scripts/edition_11/scout_bike_saved_equipment.gd")
const SwordBrethren = preload("res://scripts/edition_11/sword_brethren_saved_equipment.gd")
const Indomitor = preload("res://scripts/edition_11/indomitor_saved_equipment.gd")
const Crusader = preload("res://scripts/edition_11/crusader_saved_equipment.gd")
const Decimus = preload("res://scripts/edition_11/decimus_saved_equipment.gd")
const Fortis = preload("res://scripts/edition_11/fortis_saved_equipment.gd")
const Spectrus = preload("res://scripts/edition_11/spectrus_saved_equipment.gd")
const Talonstrike = preload("res://scripts/edition_11/talonstrike_saved_equipment.gd")
const SpecialistSquads = preload("res://scripts/edition_11/specialist_squad_equipment.gd")
const SergeantSquads = preload("res://scripts/edition_11/sergeant_squad_equipment.gd")
const MixedWolves = preload("res://scripts/edition_11/mixed_space_wolves_equipment.gd")
const TransportEquipment = preload("res://scripts/edition_11/transport_equipment.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const NecronEquipment = preload("res://scripts/edition_11/necron_saved_equipment.gd")
const INVICTOR := "40kdc:11e:adeptus-astartes:invictor-tactical-warsuit"
const DREADNOUGHT := "40kdc:11e:adeptus-astartes:dreadnought"
const VENERABLE_DREADNOUGHT := "40kdc:11e:adeptus-astartes:venerable-dreadnought-legends"

const ANCIENT := "40kdc:11e:adeptus-astartes:ancient"
const VINDICATOR := "40kdc:11e:adeptus-astartes:vindicator"
const WHIRLWIND := "40kdc:11e:adeptus-astartes:whirlwind"
const HAMMERFALL := "40kdc:11e:adeptus-astartes:hammerfall-bunker"
const NEPHILIM := "40kdc:11e:adeptus-astartes:nephilim-jetfighter"
const CERBERUS := "40kdc:11e:adeptus-astartes:cerberus"
const TYPHON := "40kdc:11e:adeptus-astartes:typhon"
const FALCHION := "40kdc:11e:adeptus-astartes:falchion"
const STORMHAWK := "40kdc:11e:adeptus-astartes:stormhawk-interceptor"
const STORMTALON := "40kdc:11e:adeptus-astartes:stormtalon-gunship"
const BJORN := "40kdc:11e:adeptus-astartes:bjorn-the-fell-handed"
const SPACE_WOLVES_VENERABLE := "40kdc:11e:adeptus-astartes:venerable-dreadnought"
const WULFEN_DREADNOUGHT := "40kdc:11e:adeptus-astartes:wulfen-dreadnought"
const DEATH_COMPANY_DREADNOUGHT := "40kdc:11e:adeptus-astartes:death-company-dreadnought"
const DEATH_COMPANY_CAPTAIN := "40kdc:11e:adeptus-astartes:death-company-captain"
const DEATH_COMPANY_JUMP_CAPTAIN := "40kdc:11e:adeptus-astartes:death-company-captain-with-jump-pack"
const BLOOD_ANGELS_CAPTAIN := "40kdc:11e:adeptus-astartes:blood-angels-captain"
const CAPTAIN := "40kdc:11e:adeptus-astartes:captain"
const CAPTAIN_WITH_JUMP_PACK := "40kdc:11e:adeptus-astartes:captain-with-jump-pack"
const GRAVIS_CAPTAIN := "40kdc:11e:adeptus-astartes:captain-in-gravis-armour"
const TERMINATOR_CAPTAIN := "40kdc:11e:adeptus-astartes:captain-in-terminator-armour"
const BIKE_CAPTAIN := "40kdc:11e:adeptus-astartes:captain-on-bike"
const BRUTALIS := "40kdc:11e:adeptus-astartes:brutalis-dreadnought"
const SANGUINARY_GUARD := "40kdc:11e:adeptus-astartes:sanguinary-guard"
const DEATH_COMPANY_MARINES := "40kdc:11e:adeptus-astartes:death-company-marines"
const DEATH_COMPANY_JUMP_PACK_MARINES := "40kdc:11e:adeptus-astartes:death-company-marines-with-jump-packs"
const TARANTULA_SENTRY_BATTERY := "40kdc:11e:adeptus-astartes:tarantula-sentry-battery"
const CASTELLAN := "40kdc:11e:adeptus-astartes:castellan"
const MARSHAL := "40kdc:11e:adeptus-astartes:marshal"
const LIEUTENANT := "40kdc:11e:adeptus-astartes:lieutenant"
const RHINO := "40kdc:11e:adeptus-astartes:rhino"
const RHINO_PRIMARIS := "40kdc:11e:adeptus-astartes:rhino-primaris"
const EXECRATOR := "40kdc:11e:adeptus-astartes:execrator"
const PHOBOS_LIEUTENANT := "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour"
const TERMINATOR_CHAPLAIN := "40kdc:11e:adeptus-astartes:chaplain-in-terminator-armour"
const RAPIER_CARRIER := "40kdc:11e:adeptus-astartes:rapier-carrier"
const REDEMPTOR := "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
const CENTURION_ASSAULT := "40kdc:11e:adeptus-astartes:centurion-assault-squad"
const CENTURION_DEVASTATOR := "40kdc:11e:adeptus-astartes:centurion-devastator-squad"
const WOLF_GUARD_BATTLE_LEADER := "40kdc:11e:adeptus-astartes:wolf-guard-battle-leader"

static func supports(definition: String) -> bool:
	if NecronEquipment.supports(definition): return true
	if Deathwing.supports(definition): return true
	if Terminators.supports(definition): return true
	if Deathwatch.supports(definition): return true
	if VanguardVeterans.supports(definition): return true
	if Ravenwing.supports(definition): return true
	if ScoutBikes.supports(definition): return true
	if SwordBrethren.supports(definition): return true
	if Indomitor.supports(definition): return true
	if Crusader.supports(definition): return true
	if Decimus.supports(definition): return true
	if Fortis.supports(definition): return true
	if Spectrus.supports(definition): return true
	if Talonstrike.supports(definition): return true
	if SpecialistSquads.supports(definition): return true
	if SergeantSquads.supports(definition): return true
	if MixedWolves.supports(definition): return true
	if definition in [THUNDERWOLF, WULFEN, WULFEN_SHIELDS]: return true
	if definition in TEMPLAR_GLADIATORS: return true
	if definition in [FIRESTRIKE, INFILTRATORS, BLADEGUARD]: return true
	if TransportEquipment.supports(definition): return true
	if definition in [REDEMPTOR, CENTURION_ASSAULT, CENTURION_DEVASTATOR, WOLF_GUARD_BATTLE_LEADER]: return true
	if definition in [EXECRATOR, PHOBOS_LIEUTENANT, TERMINATOR_CHAPLAIN, RAPIER_CARRIER]: return true
	return definition in [INVICTOR, ANCIENT, VINDICATOR, WHIRLWIND, HAMMERFALL, NEPHILIM, CERBERUS, TYPHON, FALCHION, STORMHAWK, STORMTALON, BJORN, SPACE_WOLVES_VENERABLE, WULFEN_DREADNOUGHT, DEATH_COMPANY_DREADNOUGHT, DEATH_COMPANY_CAPTAIN, DEATH_COMPANY_JUMP_CAPTAIN, BLOOD_ANGELS_CAPTAIN, CAPTAIN, CAPTAIN_WITH_JUMP_PACK, GRAVIS_CAPTAIN, TERMINATOR_CAPTAIN, BIKE_CAPTAIN, BRUTALIS, SANGUINARY_GUARD, DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES, TARANTULA_SENTRY_BATTERY, CASTELLAN, MARSHAL, LIEUTENANT, DREADNOUGHT, VENERABLE_DREADNOUGHT, RHINO, RHINO_PRIMARIS]

static func is_model_scoped(definition: String) -> bool:
	if NecronEquipment.supports(definition): return NecronEquipment.is_model_scoped(definition)
	if Deathwing.supports(definition): return true
	if Terminators.supports(definition): return true
	if Deathwatch.supports(definition): return true
	if VanguardVeterans.supports(definition): return true
	if Ravenwing.supports(definition): return true
	if ScoutBikes.supports(definition): return true
	if SwordBrethren.supports(definition): return true
	if Indomitor.supports(definition): return true
	if Crusader.supports(definition): return true
	if Decimus.supports(definition): return true
	if Fortis.supports(definition): return true
	if Spectrus.supports(definition): return true
	if Talonstrike.supports(definition): return true
	if SpecialistSquads.supports(definition): return true
	if SergeantSquads.supports(definition): return true
	if MixedWolves.supports(definition): return true
	if definition in [THUNDERWOLF, WULFEN, WULFEN_SHIELDS]: return true
	if definition in [FIRESTRIKE, INFILTRATORS, BLADEGUARD]: return true
	if definition in [CENTURION_ASSAULT, CENTURION_DEVASTATOR]: return true
	return definition in [SANGUINARY_GUARD, DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES, TARANTULA_SENTRY_BATTERY]

static func uses_stacked_model_controls(definition: String) -> bool:
	return Deathwatch.supports(definition) or definition == VanguardVeterans.JUMP_PACKS or Ravenwing.supports(definition) or ScoutBikes.supports(definition) or SwordBrethren.supports(definition) or Indomitor.supports(definition) or Crusader.supports(definition) or Decimus.supports(definition) or Fortis.supports(definition) or Spectrus.supports(definition) or Talonstrike.supports(definition)

static func defaults(definition: String) -> Dictionary:
	if NecronEquipment.supports(definition): return NecronEquipment.defaults(definition)
	if Deathwing.supports(definition): return Deathwing.defaults(definition)
	if Terminators.supports(definition): return Terminators.defaults(definition)
	if Deathwatch.supports(definition): return Deathwatch.defaults(definition)
	if VanguardVeterans.supports(definition): return VanguardVeterans.defaults(definition)
	if Ravenwing.supports(definition): return Ravenwing.defaults(definition)
	if ScoutBikes.supports(definition): return ScoutBikes.defaults(definition)
	if SwordBrethren.supports(definition): return SwordBrethren.defaults(definition)
	if Indomitor.supports(definition): return Indomitor.defaults(definition)
	if Crusader.supports(definition): return Crusader.defaults(definition)
	if Decimus.supports(definition): return Decimus.defaults(definition)
	if Fortis.supports(definition): return Fortis.defaults(definition)
	if Spectrus.supports(definition): return Spectrus.defaults(definition)
	if Talonstrike.supports(definition): return Talonstrike.defaults(definition)
	if SpecialistSquads.supports(definition): return SpecialistSquads.defaults(definition)
	if SergeantSquads.supports(definition): return SergeantSquads.defaults(definition)
	if MixedWolves.supports(definition): return MixedWolves.defaults(definition)
	if definition == THUNDERWOLF: return {"thunderwolf_cavalry_loadout": "default"}
	if definition in [WULFEN, WULFEN_SHIELDS]: return {"wulfen_loadout": "death-totem" if definition == WULFEN else "stormfrag-auto-launcher"}
	if definition in TEMPLAR_GLADIATORS: return {"gladiator_extra_multi_melta": false}
	if definition == FIRESTRIKE: return {"firestrike_autocannon": false}
	if definition == INFILTRATORS: return {"helix_gauntlet": false}
	if definition == BLADEGUARD: return {"bladeguard_pistol": "heavy"}
	if TransportEquipment.supports(definition): return TransportEquipment.defaults(definition)
	if definition == REDEMPTOR: return {"redemptor_fragstorm": true, "redemptor_heavy_flamer": true, "redemptor_macro_plasma": false, "redemptor_icarus": false}
	if definition == CENTURION_ASSAULT: return {"centurion_assault_launcher": false, "centurion_twin_meltagun": false}
	if definition == CENTURION_DEVASTATOR: return {"centurion_devastator_bolters": "centurion-bolters", "centurion_devastator_support": "grav-cannon"}
	if definition == WOLF_GUARD_BATTLE_LEADER: return {"wolf_guard_battle_leader_ranged_loadout": "plasma-pistol", "wolf_guard_battle_leader_melee_loadout": "master-crafted-power-weapon"}
	if definition == EXECRATOR: return {"execrator_pistol_package": "absolvor-bolt-pistol", "execrator_mastercrafted_power_weapon": false}
	if definition == PHOBOS_LIEUTENANT: return {"phobos_carbine": false}
	if definition == TERMINATOR_CHAPLAIN: return {"terminator_chaplain_relic_shield": false}
	if definition == RAPIER_CARRIER: return {"rapier_carrier_primary": "quad-heavy-bolter"}
	if definition == ANCIENT: return {"ancient_weapon": "rifle"}
	if definition == VINDICATOR: return {"vindicator_hunter_killer_missile": false, "vindicator_storm_bolter": false}
	if definition == WHIRLWIND: return {"whirlwind_hunter_killer_missile": false, "whirlwind_storm_bolter": false}
	if definition == HAMMERFALL: return {"hammerfall_heavy_flamer_array": false}
	if definition == NEPHILIM: return {"nephilim_lascannon_package": "twin-heavy-bolter"}
	if definition == CERBERUS: return {"cerberus_optional_weapon": "none", "cerberus_optional_pair": "none"}
	if definition == TYPHON: return {"typhon_sponson_package": "none", "typhon_hull_weapon": "none"}
	if definition == FALCHION: return {"falchion_optional_weapon": "none", "falchion_main_armament": "quad-lascannons", "falchion_twin_replacement": "twin-heavy-bolter"}
	if definition == STORMHAWK: return {"stormhawk_icarus_stormcannon": false, "stormhawk_missile_launcher": "skyhammer-missile-launcher"}
	if definition == STORMTALON: return {"stormtalon_missile_launcher": "skyhammer-missile-launcher"}
	if definition == BJORN: return {"space_wolves_walker_primary": "assault-cannon"}
	if definition == SPACE_WOLVES_VENERABLE: return {"space_wolves_walker_primary": "assault-cannon", "space_wolves_walker_secondary": "storm-bolter", "space_wolves_walker_melee_package": "combat-weapon"}
	if definition == WULFEN_DREADNOUGHT: return {"space_wolves_walker_secondary": "storm-bolter", "space_wolves_walker_melee_package": "fenrisian-great-axe"}
	if definition == DEATH_COMPANY_DREADNOUGHT: return {"death_company_twin_multi_melta": false, "death_company_blood_talons": false}
	if definition == DEATH_COMPANY_CAPTAIN: return {"death_company_captain_pistol": "heavy-bolt-pistol", "death_company_captain_melee": "master-crafted-chainsword"}
	if definition == DEATH_COMPANY_JUMP_CAPTAIN: return {"death_company_jump_captain_loadout": "default"}
	if definition == BLOOD_ANGELS_CAPTAIN: return {"blood_angels_captain_pistol": "heavy-bolt-pistol", "blood_angels_captain_melee": "master-crafted-chainsword"}
	if definition == CAPTAIN: return {"captain_ranged_loadout": "default", "captain_melee_weapon": "master-crafted-power-weapon"}
	if definition == CAPTAIN_WITH_JUMP_PACK: return {"jump_captain_loadout": "default"}
	if definition == GRAVIS_CAPTAIN: return {"gravis_loadout": "rifle"}
	if definition == TERMINATOR_CAPTAIN: return {"terminator_captain_combi_weapon": false, "terminator_captain_relic_fist": false}
	if definition == BIKE_CAPTAIN: return {"captain_bike_plasma_pistol": false, "captain_bike_thunder_hammer": false}
	if definition == BRUTALIS: return {"brutalis_talons": false, "brutalis_multi_melta": false}
	if definition == SANGUINARY_GUARD: return {"sanguinary_guard_inferno_pistol": false}
	if definition == TARANTULA_SENTRY_BATTERY: return {"tarantula_sentry_primary": "twin-heavy-bolter"}
	if definition in [DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES]:
		var loadout := {"death_company_melee_package": "chainsword", "death_company_pistol_package": "heavy-bolt-pistol"}
		if definition == DEATH_COMPANY_MARINES: loadout.death_company_grenade_launcher = false
		return loadout
	if definition == CASTELLAN: return {"castellan_ranged_package": "combi-weapon", "castellan_melee_package": "master-crafted-power-weapon"}
	if definition == MARSHAL: return {"marshal_ranged_package": "plasma-pistol"}
	if definition == LIEUTENANT: return {"lieutenant_weapon_package": "default", "lieutenant_fists_replacement": "ceramite-fists", "lieutenant_storm_shield": false}
	if definition in [RHINO, RHINO_PRIMARIS]: return {"rhino_hunter_killer_missile": false}
	if definition == DREADNOUGHT: return {"dreadnought_primary": "assault-cannon", "dreadnought_melee_package": "dreadnought-fist", "dreadnought_secondary": "none"}
	if definition == VENERABLE_DREADNOUGHT: return {"venerable_dreadnought_legends_primary": "assault-cannon", "venerable_dreadnought_legends_package": "fist-and-storm-bolter"}
	return {"invictor_cannon": "incendium"} if definition == INVICTOR else {}

## Some mixed-role units need a different schema-shaped default for each stable model.
static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	if NecronEquipment.supports(definition): return NecronEquipment.defaults(definition)
	if Indomitor.supports(definition): return Indomitor.defaults_for_model(definition, models, model_index)
	if Crusader.supports(definition): return Crusader.defaults_for_model(definition, models, model_index)
	if Decimus.supports(definition): return Decimus.defaults_for_model(definition, models, model_index)
	if Fortis.supports(definition): return Fortis.defaults_for_model(definition, models, model_index)
	if Spectrus.supports(definition): return Spectrus.defaults_for_model(definition, models, model_index)
	if Talonstrike.supports(definition): return Talonstrike.defaults_for_model(definition, models, model_index)
	return defaults(definition)

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if NecronEquipment.supports(definition): return NecronEquipment.valid(definition, equipment, models)
	if Deathwing.supports(definition): return Deathwing.valid(definition, equipment, models)
	if Terminators.supports(definition): return Terminators.valid(definition, equipment, models)
	if Deathwatch.supports(definition): return Deathwatch.valid(definition, equipment, models)
	if VanguardVeterans.supports(definition): return VanguardVeterans.valid(definition, equipment, models)
	if Ravenwing.supports(definition): return Ravenwing.valid(definition, equipment, models)
	if ScoutBikes.supports(definition): return ScoutBikes.valid(definition, equipment, models)
	if SwordBrethren.supports(definition): return SwordBrethren.valid(definition, equipment, models)
	if Indomitor.supports(definition): return Indomitor.valid(definition, equipment, models)
	if Crusader.supports(definition): return Crusader.valid(definition, equipment, models)
	if Decimus.supports(definition): return Decimus.valid(definition, equipment, models)
	if Fortis.supports(definition): return Fortis.valid(definition, equipment, models)
	if Spectrus.supports(definition): return Spectrus.valid(definition, equipment, models)
	if Talonstrike.supports(definition): return Talonstrike.valid(definition, equipment, models)
	if SpecialistSquads.supports(definition): return SpecialistSquads.valid(definition, equipment, models)
	if SergeantSquads.supports(definition): return SergeantSquads.valid(definition, equipment, models)
	if MixedWolves.supports(definition): return MixedWolves.valid(definition, equipment, models)
	if TransportEquipment.supports(definition): return TransportEquipment.valid(definition, equipment, models)
	if not supports(definition) or not equipment is Dictionary: return false
	if is_model_scoped(definition):
		if definition in [CENTURION_ASSAULT, CENTURION_DEVASTATOR] and models not in [3, 6]: return false
		if definition == SANGUINARY_GUARD:
			return models in [3, 6] and equipment.size() == 1 and equipment.has("sanguinary_guard_inferno_pistol") and equipment.sanguinary_guard_inferno_pistol is bool
		if definition == TARANTULA_SENTRY_BATTERY:
			return models in [1, 2, 3] and equipment.size() == 1 and equipment.has("tarantula_sentry_primary") and not Marines.tarantula_sentry_battery_weapons(str(equipment.tarantula_sentry_primary)).is_empty()
		if definition in [DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES]:
			if models not in [5, 10] or equipment.size() != (3 if definition == DEATH_COMPANY_MARINES else 2): return false
			if not equipment.has("death_company_melee_package") or not equipment.has("death_company_pistol_package"): return false
			var identity := _death_company_identity(definition)
			var common_valid := equipment.death_company_melee_package is String and str(equipment.death_company_melee_package) in Marines.death_company_melee_options(identity) \
				and equipment.death_company_pistol_package is String and str(equipment.death_company_pistol_package) in Marines.death_company_pistol_options(identity)
			if definition == DEATH_COMPANY_MARINES:
				return common_valid and equipment.has("death_company_grenade_launcher") and equipment.death_company_grenade_launcher is bool
			return common_valid and not equipment.has("death_company_grenade_launcher")
	if definition == THUNDERWOLF and models not in [3, 6]: return false
	if definition in [WULFEN, WULFEN_SHIELDS] and models not in [5, 10]: return false
	if definition == FIRESTRIKE and models not in [1, 2]: return false
	if definition == INFILTRATORS and models not in [5, 10]: return false
	if definition == BLADEGUARD and models not in [3, 6]: return false
	if models != 1 and definition not in [CENTURION_ASSAULT, CENTURION_DEVASTATOR, FIRESTRIKE, INFILTRATORS, BLADEGUARD, THUNDERWOLF, WULFEN, WULFEN_SHIELDS]: return false
	var descriptors := controls(definition)
	if equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		var field := str(descriptor.field)
		if not equipment.has(field): return false
		var matched := false
		for choice: Dictionary in descriptor.choices:
			if typeof(equipment[field]) == typeof(choice.id) and equipment[field] == choice.id: matched = true
		if not matched: return false
	if definition == THUNDERWOLF:
		var cost: Variant = Marines.profile("thunderwolf-cavalry").get("wargear_costs", {}).get("storm-shield")
		return cost is int and cost >= 0 and not Marines.thunderwolf_cavalry_weapons(str(equipment.thunderwolf_cavalry_loadout)).is_empty()
	if definition == WULFEN: return not Marines.wulfen_weapons(str(equipment.wulfen_loadout)).is_empty()
	if definition == WULFEN_SHIELDS: return not Marines.wulfen_storm_shields_weapons(str(equipment.wulfen_loadout)).is_empty()
	if definition in TEMPLAR_GLADIATORS:
		var source := Marines.profile(definition.get_slice(":", 3))
		var cost: Variant = source.get("wargear_costs", {}).get("Multi-melta")
		return cost is int and cost >= 0 and not Marines.additional_weapon("land-raider", "ranged", "multi-melta").is_empty()
	if definition == REDEMPTOR:
		var cost: Variant = Marines.profile("redemptor-dreadnought").get("wargear_costs", {}).get("macro-plasma-incinerator")
		return cost is int and cost >= 0 and not Marines.redemptor_weapons(bool(equipment.redemptor_fragstorm), bool(equipment.redemptor_heavy_flamer), bool(equipment.redemptor_macro_plasma), bool(equipment.redemptor_icarus)).is_empty()
	if definition == CENTURION_ASSAULT:
		return not Marines.centurion_assault_weapons(bool(equipment.centurion_assault_launcher), bool(equipment.centurion_twin_meltagun)).is_empty()
	if definition == CENTURION_DEVASTATOR:
		return not Marines.centurion_devastator_weapons(str(equipment.centurion_devastator_bolters), str(equipment.centurion_devastator_support)).is_empty()
	if definition == WOLF_GUARD_BATTLE_LEADER:
		return not Marines.wolf_guard_battle_leader_weapons(str(equipment.wolf_guard_battle_leader_ranged_loadout), str(equipment.wolf_guard_battle_leader_melee_loadout)).is_empty()
	if definition == EXECRATOR:
		return not Marines.execrator_weapons(str(equipment.execrator_pistol_package), bool(equipment.execrator_mastercrafted_power_weapon)).is_empty()
	if definition == RAPIER_CARRIER:
		return not Marines.rapier_carrier_weapons(str(equipment.rapier_carrier_primary)).is_empty()
	if definition == DREADNOUGHT:
		return not Marines.dreadnought_weapons(str(equipment.dreadnought_primary), str(equipment.dreadnought_melee_package), str(equipment.dreadnought_secondary)).is_empty()
	if definition == VENERABLE_DREADNOUGHT:
		return not Marines.venerable_dreadnought_legends_weapons(str(equipment.venerable_dreadnought_legends_primary), str(equipment.venerable_dreadnought_legends_package)).is_empty()
	if definition == TARANTULA_SENTRY_BATTERY:
		return not Marines.tarantula_sentry_battery_weapons(str(equipment.tarantula_sentry_primary)).is_empty()
	if definition == STORMHAWK:
		return not Marines.stormhawk_interceptor_weapons(bool(equipment.stormhawk_icarus_stormcannon), str(equipment.stormhawk_missile_launcher)).is_empty()
	if definition == STORMTALON:
		return not Marines.stormtalon_gunship_weapons(str(equipment.stormtalon_missile_launcher)).is_empty()
	if definition in [BJORN, SPACE_WOLVES_VENERABLE, WULFEN_DREADNOUGHT]:
		var identity := definition.get_slice(":", 3)
		return not Marines.space_wolves_walker_weapons(identity, str(equipment.get("space_wolves_walker_primary", "")), str(equipment.get("space_wolves_walker_secondary", "")), str(equipment.get("space_wolves_walker_melee_package", ""))).is_empty()
	if definition == DEATH_COMPANY_DREADNOUGHT:
		return not Marines.death_company_dreadnought_weapons(bool(equipment.death_company_twin_multi_melta), bool(equipment.death_company_blood_talons)).is_empty()
	if definition == DEATH_COMPANY_CAPTAIN:
		return not Marines.death_company_captain_weapons(str(equipment.death_company_captain_pistol), str(equipment.death_company_captain_melee)).is_empty()
	if definition == DEATH_COMPANY_JUMP_CAPTAIN:
		return not Marines.death_company_jump_captain_weapons(str(equipment.death_company_jump_captain_loadout)).is_empty()
	if definition == BLOOD_ANGELS_CAPTAIN:
		return not Marines.blood_angels_captain_weapons(str(equipment.blood_angels_captain_pistol), str(equipment.blood_angels_captain_melee)).is_empty()
	if definition == CAPTAIN:
		if str(equipment.captain_ranged_loadout) == "relic-shield" and str(equipment.captain_melee_weapon) == "power-fist": return false
		return not Marines.captain_weapons(str(equipment.captain_ranged_loadout), str(equipment.captain_melee_weapon) == "power-fist").is_empty()
	if definition == CAPTAIN_WITH_JUMP_PACK:
		return not Marines.jump_pack_captain_weapons(str(equipment.jump_captain_loadout)).is_empty()
	if definition == GRAVIS_CAPTAIN:
		return not Marines.gravis_captain_weapons(str(equipment.gravis_loadout)).is_empty()
	if definition == TERMINATOR_CAPTAIN:
		return not Marines.terminator_captain_weapons(bool(equipment.terminator_captain_combi_weapon), bool(equipment.terminator_captain_relic_fist)).is_empty()
	if definition == BIKE_CAPTAIN:
		return not Marines.captain_bike_weapons(bool(equipment.captain_bike_plasma_pistol), bool(equipment.captain_bike_thunder_hammer)).is_empty()
	if definition == BRUTALIS:
		return not Marines.brutalis_weapons(bool(equipment.brutalis_talons), bool(equipment.brutalis_multi_melta)).is_empty()
	if definition == CASTELLAN:
		return not Marines.castellan_weapons(str(equipment.castellan_ranged_package), str(equipment.castellan_melee_package)).is_empty()
	if definition == MARSHAL:
		return not Marines.marshal_weapons(str(equipment.marshal_ranged_package)).is_empty()
	if definition == LIEUTENANT:
		return not Marines.lieutenant_weapons(str(equipment.lieutenant_weapon_package), str(equipment.lieutenant_fists_replacement), bool(equipment.lieutenant_storm_shield)).is_empty()
	if definition == RHINO:
		return not Marines.rhino_weapons(bool(equipment.rhino_hunter_killer_missile)).is_empty()
	if definition == RHINO_PRIMARIS:
		return not Marines.rhino_primaris_weapons(bool(equipment.rhino_hunter_killer_missile)).is_empty()
	return true

static func valid_for_model(definition: String, model_index: int, equipment: Variant, models: int) -> bool:
	if NecronEquipment.supports(definition): return NecronEquipment.valid_for_model(definition, equipment, models, model_index)
	if Indomitor.supports(definition): return Indomitor.valid_for_model(definition, equipment, models, model_index)
	if Crusader.supports(definition): return Crusader.valid_for_model(definition, equipment, models, model_index)
	if Decimus.supports(definition): return Decimus.valid_for_model(definition, equipment, models, model_index)
	if Fortis.supports(definition): return Fortis.valid_for_model(definition, equipment, models, model_index)
	if Spectrus.supports(definition): return Spectrus.valid_for_model(definition, equipment, models, model_index)
	if Talonstrike.supports(definition): return Talonstrike.valid_for_model(definition, equipment, models, model_index)
	return valid(definition, equipment, models)

static func valid_saved_loadout(definition: String, loadout: Variant, models: int) -> bool:
	if NecronEquipment.supports(definition): return NecronEquipment.valid_saved(definition, loadout, models)
	if Deathwing.supports(definition): return Deathwing.valid_saved(definition, loadout, models)
	if Terminators.supports(definition): return Terminators.valid_saved(definition, loadout, models)
	if Deathwatch.supports(definition): return Deathwatch.valid_saved(definition, loadout, models)
	if VanguardVeterans.supports(definition): return VanguardVeterans.valid_saved(definition, loadout, models)
	if Ravenwing.supports(definition): return Ravenwing.valid_saved(definition, loadout, models)
	if ScoutBikes.supports(definition): return ScoutBikes.valid_saved(definition, loadout, models)
	if SwordBrethren.supports(definition): return SwordBrethren.valid_saved(definition, loadout, models)
	if Indomitor.supports(definition): return Indomitor.valid_saved(definition, loadout, models)
	if Crusader.supports(definition): return Crusader.valid_saved(definition, loadout, models)
	if Decimus.supports(definition): return Decimus.valid_saved(definition, loadout, models)
	if Fortis.supports(definition): return Fortis.valid_saved(definition, loadout, models)
	if Spectrus.supports(definition): return Spectrus.valid_saved(definition, loadout, models)
	if Talonstrike.supports(definition): return Talonstrike.valid_saved(definition, loadout, models)
	if SpecialistSquads.supports(definition): return SpecialistSquads.valid_saved(definition, loadout, models)
	if SergeantSquads.supports(definition): return SergeantSquads.valid_saved(definition, loadout, models)
	if MixedWolves.supports(definition): return MixedWolves.valid_saved(definition, loadout, models)
	if not supports(definition) or models <= 0: return false
	if is_model_scoped(definition):
		if not loadout is Array or loadout.size() != models: return false
		if definition in [THUNDERWOLF, WULFEN, WULFEN_SHIELDS]:
			var plasma := 0
			for equipment: Variant in loadout:
				if not valid(definition, equipment, models): return false
				if definition == THUNDERWOLF and str(equipment.thunderwolf_cavalry_loadout) == "plasma-pistol": plasma += 1
			return plasma <= int(models / 3) if definition == THUNDERWOLF else true
		if definition in [FIRESTRIKE, INFILTRATORS, BLADEGUARD]:
			var helix_count := 0
			for index in range(models):
				if not valid(definition, loadout[index], models): return false
				if definition == INFILTRATORS and bool(loadout[index].helix_gauntlet): helix_count += 1
				if definition == BLADEGUARD and index > 0 and str(loadout[index].bladeguard_pistol) != "heavy": return false
			return helix_count <= 1
		if definition in [TARANTULA_SENTRY_BATTERY, CENTURION_ASSAULT, CENTURION_DEVASTATOR]:
			for equipment: Variant in loadout:
				if not valid(definition, equipment, models): return false
			return true
		if definition in [DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES]:
			var melee_packages: Array[String] = []
			var pistol_packages: Array[String] = []
			var grenade_launchers: Array[bool] = []
			for equipment: Variant in loadout:
				if not valid(definition, equipment, models): return false
				melee_packages.append(str(equipment.death_company_melee_package))
				pistol_packages.append(str(equipment.death_company_pistol_package))
				grenade_launchers.append(bool(equipment.get("death_company_grenade_launcher", false)))
			return Marines.death_company_loadout_limits_valid(_death_company_identity(definition), models, melee_packages, pistol_packages, grenade_launchers)
		var choices: Array[String] = []
		for model_index in range(models):
			var equipment: Variant = loadout[model_index]
			if not valid(definition, equipment, models): return false
			choices.append("inferno-pistol" if bool(equipment.sanguinary_guard_inferno_pistol) else "angelus-boltgun")
		return Marines.sanguinary_guard_loadouts_valid(choices, models)
	return valid(definition, loadout, models)

static func visual_model_role(definition: String, models: int, model_index: int) -> String:
	if NecronEquipment.supports(definition): return NecronEquipment.role(definition, models, model_index)
	if Deathwing.supports(definition): return Deathwing.role(definition, models, model_index)
	if Terminators.supports(definition): return Terminators.role(definition, models, model_index)
	if Deathwatch.supports(definition): return Deathwatch.role(definition, models, model_index)
	if VanguardVeterans.supports(definition): return VanguardVeterans.role(definition, models, model_index)
	if Ravenwing.supports(definition): return Ravenwing.role(definition, models, model_index)
	if ScoutBikes.supports(definition): return ScoutBikes.role(definition, models, model_index)
	if SwordBrethren.supports(definition): return SwordBrethren.role(definition, models, model_index)
	if Indomitor.supports(definition): return Indomitor.role(definition, models, model_index)
	if Crusader.supports(definition): return Crusader.role(definition, models, model_index)
	if Decimus.supports(definition): return Decimus.role(definition, models, model_index)
	if Fortis.supports(definition): return Fortis.role(definition, models, model_index)
	if Spectrus.supports(definition): return Spectrus.role(definition, models, model_index)
	if Talonstrike.supports(definition): return Talonstrike.role(definition, models, model_index)
	if SpecialistSquads.supports(definition): return SpecialistSquads.role(definition, models, model_index)
	if SergeantSquads.supports(definition): return SergeantSquads.role(definition, models, model_index)
	if MixedWolves.supports(definition): return MixedWolves.role(definition, models, model_index)
	if definition == BLADEGUARD: return "sergeant" if model_index == 0 else "bladeguard"
	return ""

static func model_label(definition: String, models: int, model_index: int) -> String:
	if NecronEquipment.supports(definition): return NecronEquipment.model_label(definition, models, model_index)
	if Deathwing.supports(definition): return ("Knight Master" if definition == Deathwing.KNIGHTS else "Sergeant") if model_index == 0 else "Model %d" % (model_index + 1)
	if Terminators.supports(definition): return ("Pack Leader" if definition == Terminators.WOLVES else "Sergeant") if model_index == 0 else "Model %d" % (model_index + 1)
	if definition == Deathwatch.VETERANS: return "Watch Sergeant" if model_index == 0 else "Deathwatch Veteran %d" % (model_index + 1)
	if definition == Deathwatch.TERMINATORS: return "Terminator Sergeant" if model_index == 0 else "Terminator %d" % (model_index + 1)
	if VanguardVeterans.supports(definition): return VanguardVeterans.model_label(definition, models, model_index)
	if Ravenwing.supports(definition): return Ravenwing.model_label(definition, models, model_index)
	if ScoutBikes.supports(definition): return ScoutBikes.model_label(definition, models, model_index)
	if SwordBrethren.supports(definition): return SwordBrethren.model_label(definition, models, model_index)
	if Indomitor.supports(definition): return Indomitor.model_label(definition, models, model_index)
	if Crusader.supports(definition): return Crusader.model_label(definition, models, model_index)
	if Decimus.supports(definition): return Decimus.model_label(definition, models, model_index)
	if Fortis.supports(definition): return Fortis.model_label(definition, models, model_index)
	if Spectrus.supports(definition): return Spectrus.model_label(definition, models, model_index)
	if Talonstrike.supports(definition): return Talonstrike.model_label(definition, models, model_index)
	if SpecialistSquads.supports(definition): return "Sergeant" if model_index == 0 else "Model %d" % (model_index + 1)
	if SergeantSquads.supports(definition): return ("Sergeant" if definition == SergeantSquads.JUMP else "Pack Leader") if model_index == 0 else "Model %d" % (model_index + 1)
	if MixedWolves.supports(definition):
		var role := MixedWolves.role(definition, models, model_index)
		var names := {"pack-leader": "Pack Leader", "hunting-wolf": "Hunting Wolf", "wolf-scout": "Wolf Scout", "wolf-guard-headtaker": "Headtaker"}
		return "%s %d" % [names.get(role, "Model"), model_index + 1]
	return "Sergeant" if definition == BLADEGUARD and model_index == 0 else "Model %d" % (model_index + 1)

static func controls_for_model(definition: String, model_index: int, models: int = 0) -> Array[Dictionary]:
	if NecronEquipment.supports(definition): return NecronEquipment.controls_for_model(definition, models, model_index)
	if Deathwing.supports(definition): return Deathwing.controls_for_model(definition, models, model_index)
	if Terminators.supports(definition): return Terminators.controls_for_model(definition, models, model_index)
	if Deathwatch.supports(definition): return Deathwatch.controls_for_model(definition, models, model_index)
	if VanguardVeterans.supports(definition): return VanguardVeterans.controls_for_model(definition, models, model_index)
	if Ravenwing.supports(definition): return Ravenwing.controls_for_model(definition, models, model_index)
	if ScoutBikes.supports(definition): return ScoutBikes.controls_for_model(definition, models, model_index)
	if SwordBrethren.supports(definition): return SwordBrethren.controls_for_model(definition, models, model_index)
	if Indomitor.supports(definition): return Indomitor.controls_for_model(definition, models, model_index)
	if Crusader.supports(definition): return Crusader.controls_for_model(definition, models, model_index)
	if Decimus.supports(definition): return Decimus.controls_for_model(definition, models, model_index)
	if Fortis.supports(definition): return Fortis.controls_for_model(definition, models, model_index)
	if Spectrus.supports(definition): return Spectrus.controls_for_model(definition, models, model_index)
	if Talonstrike.supports(definition): return Talonstrike.controls_for_model(definition, models, model_index)
	if SpecialistSquads.supports(definition): return SpecialistSquads.controls_for_model(definition, models, model_index)
	if SergeantSquads.supports(definition): return SergeantSquads.controls_for_model(definition, models, model_index)
	if MixedWolves.supports(definition): return MixedWolves.controls_for_model(definition, models, model_index)
	var descriptors := controls(definition)
	if definition == BLADEGUARD and model_index > 0:
		descriptors[0].label = "Fixed pistol"
		descriptors[0].choices = [{"id": "heavy", "label": "Heavy Bolt Pistol"}]
	return descriptors

static func controls(definition: String) -> Array[Dictionary]:
	if NecronEquipment.supports(definition): return NecronEquipment.controls(definition)
	if Deathwing.supports(definition): return Deathwing.controls(definition)
	if Terminators.supports(definition): return Terminators.controls(definition)
	if Deathwatch.supports(definition): return Deathwatch.controls(definition)
	if VanguardVeterans.supports(definition): return VanguardVeterans.controls(definition)
	if Ravenwing.supports(definition): return Ravenwing.controls(definition)
	if ScoutBikes.supports(definition): return ScoutBikes.controls(definition)
	if SwordBrethren.supports(definition): return SwordBrethren.controls(definition)
	if Indomitor.supports(definition): return Indomitor.controls(definition)
	if Crusader.supports(definition): return Crusader.controls(definition)
	if Decimus.supports(definition): return Decimus.controls(definition)
	if Fortis.supports(definition): return Fortis.controls(definition)
	if Spectrus.supports(definition): return Spectrus.controls(definition)
	if Talonstrike.supports(definition): return Talonstrike.controls(definition)
	if SpecialistSquads.supports(definition): return SpecialistSquads.controls(definition)
	if SergeantSquads.supports(definition): return SergeantSquads.controls(definition)
	if MixedWolves.supports(definition): return MixedWolves.controls(definition)
	if definition == THUNDERWOLF: return [{"field": "thunderwolf_cavalry_loadout", "label": "Equipment (Plasma: 1 per 3 models)", "choices": _choices(["default", "plasma-pistol", "boltgun-storm-shield"], ["Bolt Pistol", "Plasma Pistol", "Boltgun + Storm Shield (+5 points)"])}]
	if definition in [WULFEN, WULFEN_SHIELDS]: return [{"field": "wulfen_loadout", "label": "Model equipment", "choices": _choices(["death-totem", "stormfrag-auto-launcher"], ["Death Totem", "Stormfrag Auto-launcher"])}]
	if definition in TEMPLAR_GLADIATORS: return [{"field": "gladiator_extra_multi_melta", "label": "Additional Multi-melta", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped (+10 points)"}]}]
	if definition == FIRESTRIKE: return [{"field": "firestrike_autocannon", "label": "Turret weapon", "choices": [{"id": false, "label": "Twin Firestrike Las-talon"}, {"id": true, "label": "Twin Firestrike Autocannon"}]}]
	if definition == INFILTRATORS: return [{"field": "helix_gauntlet", "label": "Helix Gauntlet (one per squad)", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]}]
	if definition == BLADEGUARD: return [{"field": "bladeguard_pistol", "label": "Sergeant pistol", "choices": _choices(["heavy", "volkite", "plasma"], ["Heavy Bolt Pistol", "Neo-volkite Pistol", "Plasma Pistol"])}]
	if TransportEquipment.supports(definition): return TransportEquipment.controls(definition)
	if definition == REDEMPTOR:
		return [
			{"field": "redemptor_fragstorm", "label": "Fragstorm Grenade Launchers replacement", "choices": [{"id": true, "label": "Fragstorm Grenade Launchers"}, {"id": false, "label": "Storm Bolters"}]},
			{"field": "redemptor_heavy_flamer", "label": "Heavy Flamer replacement", "choices": [{"id": true, "label": "Heavy Flamer"}, {"id": false, "label": "Onslaught Gatling Cannon"}]},
			{"field": "redemptor_macro_plasma", "label": "Heavy Onslaught Gatling Cannon replacement", "choices": [{"id": false, "label": "Heavy Onslaught Gatling Cannon"}, {"id": true, "label": "Macro Plasma Incinerator (+10 points)"}]},
			{"field": "redemptor_icarus", "label": "Icarus Rocket Pod", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]}
		]
	if definition == CENTURION_ASSAULT:
		return [
			{"field": "centurion_assault_launcher", "label": "Centurion Bolters replacement", "choices": [{"id": false, "label": "Centurion Bolters"}, {"id": true, "label": "Centurion Assault Launcher (Explosives)"}]},
			{"field": "centurion_twin_meltagun", "label": "Twin Flamer replacement", "choices": [{"id": false, "label": "Twin Flamer"}, {"id": true, "label": "Twin Meltagun"}]}
		]
	if definition == CENTURION_DEVASTATOR:
		return [
			{"field": "centurion_devastator_bolters", "label": "Centurion Bolters replacement", "choices": _choices(["centurion-bolters", "centurion-missile-launcher"], ["Centurion Bolters", "Centurion Missile Launcher"])},
			{"field": "centurion_devastator_support", "label": "Grav-cannon replacement", "choices": _choices(["grav-cannon", "twin-heavy-bolter", "twin-lascannon"], ["Grav-cannon", "Twin Heavy Bolter", "Twin Lascannon"])}
		]
	if definition == WOLF_GUARD_BATTLE_LEADER:
		return [
			{"field": "wolf_guard_battle_leader_ranged_loadout", "label": "Plasma Pistol replacement", "choices": _choices(["plasma-pistol", "storm-shield"], ["Plasma Pistol", "Storm Shield (+1 Wound)"])},
			{"field": "wolf_guard_battle_leader_melee_loadout", "label": "Master-crafted Power Weapon replacement", "choices": _choices(["master-crafted-power-weapon", "thunder-hammer"], ["Master-crafted Power Weapon", "Thunder Hammer"])}
		]
	if definition == EXECRATOR:
		return [
			{"field": "execrator_pistol_package", "label": "Pistol replacement", "choices": _choices(["absolvor-bolt-pistol", "hand-flamer"], ["Absolvor Bolt Pistol", "Hand Flamer"])},
			{"field": "execrator_mastercrafted_power_weapon", "label": "Additional Master-crafted Power Weapon (Absolvor only)", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]}
		]
	if definition == PHOBOS_LIEUTENANT:
		return [{"field": "phobos_carbine", "label": "Special-issue Bolt Pistol replacement", "choices": [{"id": false, "label": "Special-issue Bolt Pistol"}, {"id": true, "label": "Master-crafted Bolt Carbine"}]}]
	if definition == TERMINATOR_CHAPLAIN:
		return [{"field": "terminator_chaplain_relic_shield", "label": "Storm Bolter replacement", "choices": [{"id": false, "label": "Storm Bolter"}, {"id": true, "label": "Relic Shield (+1 Wound)"}]}]
	if definition == RAPIER_CARRIER:
		return [{"field": "rapier_carrier_primary", "label": "Quad Heavy Bolter replacement", "choices": _choices(["quad-heavy-bolter", "graviton-cannon", "laser-destroyer", "quad-launcher"], ["Quad Heavy Bolter", "Graviton Cannon", "Laser Destroyer", "Quad Launcher"])}]
	if definition == SANGUINARY_GUARD:
		return [{"field": "sanguinary_guard_inferno_pistol", "label": "Angelus Boltgun replacement", "choices": [{"id": false, "label": "Angelus Boltgun"}, {"id": true, "label": "Inferno Pistol"}]}]
	if definition == TARANTULA_SENTRY_BATTERY:
		return [{"field": "tarantula_sentry_primary", "label": "Twin Heavy Bolter replacement", "choices": _choices(["twin-heavy-bolter", "twin-lascannon"], ["Twin Heavy Bolter", "Twin Lascannon"])}]
	if definition in [DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES]:
		var identity := _death_company_identity(definition)
		var melee_labels := {"chainsword": "Chainsword", "bolt-rifle-fire": "Bolt Rifle Fire + Combat Blade", "eviscerator": "Eviscerator", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}
		var pistol_labels := {"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "inferno-pistol": "Inferno Pistol", "plasma-pistol": "Plasma Pistol"}
		var melee_options := Marines.death_company_melee_options(identity)
		var pistol_options := Marines.death_company_pistol_options(identity)
		var melee_choices: Array[Dictionary] = []
		var pistol_choices: Array[Dictionary] = []
		for option: String in melee_options: melee_choices.append({"id": option, "label": str(melee_labels.get(option, option))})
		for option: String in pistol_options: pistol_choices.append({"id": option, "label": str(pistol_labels.get(option, option))})
		var result: Array[Dictionary] = [
			{"field": "death_company_melee_package", "label": "Chainsword replacement", "choices": melee_choices},
			{"field": "death_company_pistol_package", "label": "Heavy Bolt Pistol replacement", "choices": pistol_choices}
		]
		if definition == DEATH_COMPANY_MARINES:
			result.append({"field": "death_company_grenade_launcher", "label": "Grenade Launcher (Bolt Rifle carrier only)", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]})
		return result
	if definition == ANCIENT: return [{"field": "ancient_weapon", "label": "Weapon replacement", "choices": [{"id": "rifle", "label": "Bolt Rifle"}, {"id": "power", "label": "Power Weapon"}]}]
	if definition == VINDICATOR: return _optional_weapon_controls("vindicator")
	if definition == WHIRLWIND: return _optional_weapon_controls("whirlwind")
	if definition == HAMMERFALL: return [{"field": "hammerfall_heavy_flamer_array", "label": "Heavy weapon array", "choices": [{"id": false, "label": "Heavy Bolter Array"}, {"id": true, "label": "Heavy Flamer Array"}]}]
	if definition == NEPHILIM: return [{"field": "nephilim_lascannon_package", "label": "Primary weapon package", "choices": [{"id": "twin-heavy-bolter", "label": "Twin Heavy Bolter"}, {"id": "lascannons", "label": "Nephilim Lascannons"}]}]
	if definition == CERBERUS:
		return [
			{"field": "cerberus_optional_weapon", "label": "Optional hull weapon", "choices": _choices(["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"], ["No optional weapon", "Heavy Bolter", "Heavy Flamer", "Multi-melta", "Storm Bolter"])},
			{"field": "cerberus_optional_pair", "label": "Optional sponson pair", "choices": _choices(["none", "two-heavy-bolters", "two-lascannons"], ["No optional pair", "Two Heavy Bolters", "Two Lascannons"])},
		]
	if definition == TYPHON:
		return [
			{"field": "typhon_sponson_package", "label": "Optional sponson pair", "choices": _choices(["none", "two-heavy-bolters", "two-lascannons"], ["No optional pair", "Two Heavy Bolters", "Two Lascannons"])},
			{"field": "typhon_hull_weapon", "label": "Optional hull weapon", "choices": _choices(["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"], ["No optional weapon", "Heavy Bolter", "Heavy Flamer", "Multi-melta", "Storm Bolter"])},
		]
	if definition == FALCHION:
		return [
			{"field": "falchion_optional_weapon", "label": "Optional hull weapon", "choices": _choices(["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"], ["No optional weapon", "Heavy Bolter", "Heavy Flamer", "Multi-melta", "Storm Bolter"])},
			{"field": "falchion_main_armament", "label": "Main armament", "choices": _choices(["quad-lascannons", "laser-destroyers"], ["Quad Lascannons", "Laser Destroyers"])},
			{"field": "falchion_twin_replacement", "label": "Twin weapon replacement", "choices": _choices(["twin-heavy-bolter", "twin-heavy-flamer"], ["Twin Heavy Bolter", "Twin Heavy Flamer"])},
		]
	if definition == STORMHAWK:
		return [
			{"field": "stormhawk_icarus_stormcannon", "label": "Las-talon replacement", "choices": [{"id": false, "label": "Las-talon"}, {"id": true, "label": "Icarus Stormcannon"}]},
			{"field": "stormhawk_missile_launcher", "label": "Skyhammer replacement", "choices": _choices(["skyhammer-missile-launcher", "twin-heavy-bolter", "typhoon-missile-launcher"], ["Skyhammer Missile Launcher", "Twin Heavy Bolter", "Typhoon Missile Launcher"])}
		]
	if definition == STORMTALON:
		return [{"field": "stormtalon_missile_launcher", "label": "Skyhammer replacement", "choices": _choices(["skyhammer-missile-launcher", "twin-heavy-bolter", "twin-lascannon", "typhoon-missile-launcher"], ["Skyhammer Missile Launcher", "Twin Heavy Bolter", "Twin Lascannon", "Typhoon Missile Launcher"])}]
	if definition == BJORN:
		return [{"field": "space_wolves_walker_primary", "label": "Assault Cannon replacement", "choices": _choices(["assault-cannon", "helfrost-cannon", "multi-melta"], ["Assault Cannon", "Helfrost Cannon", "Multi-melta"])}]
	if definition == SPACE_WOLVES_VENERABLE:
		return [
			{"field": "space_wolves_walker_primary", "label": "Assault Cannon replacement", "choices": _choices(["assault-cannon", "helfrost-cannon", "multi-melta"], ["Assault Cannon", "Helfrost Cannon", "Multi-melta"])},
			{"field": "space_wolves_walker_secondary", "label": "Storm Bolter replacement", "choices": _choices(["storm-bolter", "heavy-flamer"], ["Storm Bolter", "Heavy Flamer"])},
			{"field": "space_wolves_walker_melee_package", "label": "Melee weapon package", "choices": _choices(["combat-weapon", "fenrisian-great-axe-blizzard-shield"], ["Dreadnought Combat Weapon", "Fenrisian Great Axe + Blizzard Shield"])}
		]
	if definition == WULFEN_DREADNOUGHT:
		return [
			{"field": "space_wolves_walker_secondary", "label": "Storm Bolter replacement", "choices": _choices(["storm-bolter", "heavy-flamer"], ["Storm Bolter", "Heavy Flamer"])},
			{"field": "space_wolves_walker_melee_package", "label": "Fenrisian Great Axe replacement", "choices": _choices(["fenrisian-great-axe", "blizzard-shield"], ["Fenrisian Great Axe", "Blizzard Shield"])}
		]
	if definition == DEATH_COMPANY_DREADNOUGHT:
		return [
			{"field": "death_company_twin_multi_melta", "label": "Twin Heavy Bolter replacement", "choices": [{"id": false, "label": "Twin Heavy Bolter"}, {"id": true, "label": "Twin Multi-melta"}]},
			{"field": "death_company_blood_talons", "label": "Linked weapon package", "choices": [{"id": false, "label": "Blood Fists + Bolt Rifles"}, {"id": true, "label": "Blood Talons"}]}
		]
	if definition == DEATH_COMPANY_CAPTAIN:
		return [
			{"field": "death_company_captain_pistol", "label": "Pistol replacement", "choices": _choices(["heavy-bolt-pistol", "inferno-pistol"], ["Heavy Bolt Pistol", "Inferno Pistol"])},
			{"field": "death_company_captain_melee", "label": "Melee weapon replacement", "choices": _choices(["master-crafted-chainsword", "power-fist", "relic-weapon"], ["Master-crafted Chainsword", "Power Fist", "Relic Weapon"])}
		]
	if definition == DEATH_COMPANY_JUMP_CAPTAIN:
		return [{"field": "death_company_jump_captain_loadout", "label": "Complete weapon package", "choices": _choices(["default", "hand-flamer-power-fist", "plasma-pistol-power-fist", "heavy-bolt-pistol-power-fist", "hand-flamer-relic-weapon", "plasma-pistol-relic-weapon", "heavy-bolt-pistol-relic-weapon", "thunder-hammer-shield", "chainsword-shield"], ["Heavy Bolt Pistol + Chainsword", "Hand Flamer + Power Fist", "Plasma Pistol + Power Fist", "Heavy Bolt Pistol + Power Fist", "Hand Flamer + Relic Weapon", "Plasma Pistol + Relic Weapon", "Heavy Bolt Pistol + Relic Weapon", "Thunder Hammer + Relic Shield", "Chainsword + Relic Shield"])}]
	if definition == BLOOD_ANGELS_CAPTAIN:
		return [
			{"field": "blood_angels_captain_pistol", "label": "Pistol replacement", "choices": _choices(["heavy-bolt-pistol", "inferno-pistol"], ["Heavy Bolt Pistol", "Inferno Pistol"])},
			{"field": "blood_angels_captain_melee", "label": "Melee weapon replacement", "choices": _choices(["master-crafted-chainsword", "power-fist", "relic-weapon"], ["Master-crafted Chainsword", "Power Fist", "Relic Weapon"])}
		]
	if definition == CAPTAIN:
		return [
			{"field": "captain_ranged_loadout", "label": "Ranged weapon package", "choices": _choices(["default", "neo-volkite", "plasma-pistol", "relic-shield"], ["Master-crafted Bolter + Heavy Bolt Pistol", "Neo-volkite Pistol", "Plasma Pistol", "Relic Shield + Heavy Bolt Pistol"])},
			{"field": "captain_melee_weapon", "label": "Melee weapon", "choices": _choices(["master-crafted-power-weapon", "power-fist"], ["Master-crafted Power Weapon", "Power Fist"])}
		]
	if definition == CAPTAIN_WITH_JUMP_PACK:
		return [{"field": "jump_captain_loadout", "label": "Complete weapon package", "choices": _choices(["default", "hand-flamer", "plasma-pistol", "power-fist", "relic-weapon", "thunder-hammer-shield", "chainsword-shield"], ["Heavy Bolt Pistol + Chainsword", "Hand Flamer + Chainsword", "Plasma Pistol + Chainsword", "Heavy Bolt Pistol + Power Fist", "Heavy Bolt Pistol + Relic Weapon", "Thunder Hammer + Relic Shield", "Chainsword + Relic Shield"])}]
	if definition == GRAVIS_CAPTAIN:
		return [{"field": "gravis_loadout", "label": "Complete weapon package", "choices": _choices(["rifle", "blade", "chainsword", "fist"], ["Master-crafted Heavy Bolt Rifle + Master-crafted Power Weapon", "Boltstorm Gauntlet + Relic Blade", "Boltstorm Gauntlet + Relic Chainsword", "Boltstorm Gauntlet + Relic Power Fist"])}]
	if definition == TERMINATOR_CAPTAIN:
		return [
			{"field": "terminator_captain_combi_weapon", "label": "Storm Bolter replacement", "choices": [{"id": false, "label": "Storm Bolter"}, {"id": true, "label": "Combi-weapon"}]},
			{"field": "terminator_captain_relic_fist", "label": "Relic Weapon replacement", "choices": [{"id": false, "label": "Relic Weapon"}, {"id": true, "label": "Relic Fist"}]}
		]
	if definition == BIKE_CAPTAIN:
		return [
			{"field": "captain_bike_plasma_pistol", "label": "Heavy Bolt Pistol replacement", "choices": [{"id": false, "label": "Heavy Bolt Pistol"}, {"id": true, "label": "Plasma Pistol"}]},
			{"field": "captain_bike_thunder_hammer", "label": "Master-crafted Power Weapon replacement", "choices": [{"id": false, "label": "Master-crafted Power Weapon"}, {"id": true, "label": "Thunder Hammer"}]}
		]
	if definition == BRUTALIS:
		return [
			{"field": "brutalis_talons", "label": "Linked melee and rifle package", "choices": [{"id": false, "label": "Brutalis Fists + Bolt Rifles"}, {"id": true, "label": "Brutalis Talons"}]},
			{"field": "brutalis_multi_melta", "label": "Twin Heavy Bolter replacement", "choices": [{"id": false, "label": "Twin Heavy Bolter"}, {"id": true, "label": "Twin Multi-melta"}]}
		]
	if definition == CASTELLAN:
		return [
			{"field": "castellan_ranged_package", "label": "Ranged weapon", "choices": _choices(["combi-weapon", "heavy-bolt-pistol"], ["Combi-weapon", "Heavy Bolt Pistol"])},
			{"field": "castellan_melee_package", "label": "Melee weapon", "choices": _choices(["master-crafted-power-weapon", "chainsword"], ["Master-crafted Power Weapon", "Chainsword"])}
		]
	if definition == MARSHAL:
		return [{"field": "marshal_ranged_package", "label": "Plasma Pistol replacement", "choices": _choices(["plasma-pistol", "combi-weapon"], ["Plasma Pistol", "Combi-weapon"])}]
	if definition == LIEUTENANT:
		return [
			{"field": "lieutenant_weapon_package", "label": "Ranged weapon package", "choices": _choices(["default", "heavy-bolt-pistol", "power-weapon", "heavy-pistol-power-weapon", "plasma-pistol", "heavy-pistol-plasma-pistol", "power-fist", "heavy-pistol-power-fist", "neo-volkite"], ["Bolt Pistol + Master-crafted Bolter", "Heavy Bolt Pistol + Master-crafted Bolter", "Bolt Pistol + Master-crafted Power Weapon", "Heavy Bolt Pistol + Master-crafted Power Weapon", "Bolt Pistol + Plasma Pistol", "Heavy Bolt Pistol + Plasma Pistol", "Bolt Pistol + Power Fist", "Heavy Bolt Pistol + Power Fist", "Neo-volkite Pistol + Master-crafted Power Weapon"])},
			{"field": "lieutenant_fists_replacement", "label": "Ceramite Fists replacement", "choices": _choices(["ceramite-fists", "power-weapon", "power-fist"], ["Ceramite Fists", "Master-crafted Power Weapon", "Power Fist"])},
			{"field": "lieutenant_storm_shield", "label": "Storm Shield (Neo-volkite package only)", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped (4+ invulnerable save)"}]}
		]
	if definition in [RHINO, RHINO_PRIMARIS]:
		return [{"field": "rhino_hunter_killer_missile", "label": "Hunter-killer Missile", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]}]
	if definition == DREADNOUGHT:
		return [
			{"field": "dreadnought_primary", "label": "Primary weapon", "choices": _choices(["assault-cannon", "heavy-plasma-cannon", "multi-melta", "twin-lascannon"], ["Assault Cannon", "Heavy Plasma Cannon", "Multi-melta", "Twin Lascannon"])},
			{"field": "dreadnought_melee_package", "label": "Melee and linked weapon package", "choices": _choices(["dreadnought-fist", "crushing-feet"], ["Dreadnought Fist + Storm Bolter", "Missile Launcher + Crushing Feet"])},
			{"field": "dreadnought_secondary", "label": "Storm Bolter replacement", "choices": _choices(["none", "heavy-flamer"], ["Keep Storm Bolter", "Heavy Flamer"])}
		]
	if definition == VENERABLE_DREADNOUGHT:
		return [
			{"field": "venerable_dreadnought_legends_primary", "label": "Primary weapon", "choices": _choices(["assault-cannon", "dreadnought-inferno-cannon", "heavy-plasma-cannon", "multi-melta", "twin-autocannon", "twin-heavy-bolter", "twin-heavy-flamer", "twin-lascannon"], ["Assault Cannon", "Dreadnought Inferno Cannon", "Heavy Plasma Cannon", "Multi-melta", "Twin Autocannon", "Twin Heavy Bolter", "Twin Heavy Flamer", "Twin Lascannon"])},
			{"field": "venerable_dreadnought_legends_package", "label": "Dreadnought Fist and ranged weapon package", "choices": _choices(["fist-and-storm-bolter", "heavy-flamer-and-fist", "missile-launcher", "twin-autocannon"], ["Fist + Storm Bolter", "Heavy Flamer + Fist", "Missile Launcher", "Twin Autocannon"])}
		]
	if not supports(definition): return []
	return [{"field": "invictor_cannon", "label": "Main weapon", "choices": [{"id": "incendium", "label": "Incendium Cannon"}, {"id": "autocannon", "label": "Twin Ironhail Autocannon"}]}]

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int = 0, model_index: int = -1) -> void:
	if NecronEquipment.supports(definition):
		NecronEquipment.prepare(unit, definition, equipment, models, model_index)
		return
	if Deathwing.supports(definition):
		Deathwing.prepare(unit, definition, equipment, models, model_index)
		return
	if Terminators.supports(definition):
		Terminators.prepare(unit, definition, equipment, models, model_index)
		return
	if Deathwatch.supports(definition):
		Deathwatch.prepare(unit, definition, equipment, models, model_index)
		return
	if VanguardVeterans.supports(definition):
		VanguardVeterans.prepare(unit, definition, equipment, models, model_index)
		return
	if Ravenwing.supports(definition):
		Ravenwing.prepare(unit, definition, equipment, models, model_index)
		return
	if ScoutBikes.supports(definition):
		ScoutBikes.prepare(unit, definition, equipment, models, model_index)
		return
	if SwordBrethren.supports(definition):
		SwordBrethren.prepare(unit, definition, equipment, models, model_index)
		return
	if Indomitor.supports(definition):
		Indomitor.prepare(unit, definition, equipment, models, model_index)
		return
	if Crusader.supports(definition):
		Crusader.prepare(unit, definition, equipment, models, model_index)
		return
	if Decimus.supports(definition):
		Decimus.prepare(unit, definition, equipment, models, model_index)
		return
	if Fortis.supports(definition):
		Fortis.prepare(unit, definition, equipment, models, model_index)
		return
	if Spectrus.supports(definition):
		Spectrus.prepare(unit, definition, equipment, models, model_index)
		return
	if Talonstrike.supports(definition):
		Talonstrike.prepare(unit, definition, equipment, models, model_index)
		return
	if SpecialistSquads.supports(definition):
		SpecialistSquads.prepare(unit, definition, equipment, models, model_index)
		return
	if SergeantSquads.supports(definition):
		SergeantSquads.prepare(unit, definition, equipment, models, model_index)
		return
	if MixedWolves.supports(definition):
		MixedWolves.prepare(unit, definition, equipment, models, model_index)
		return
	if definition in [THUNDERWOLF, WULFEN, WULFEN_SHIELDS]:
		if not valid(definition, equipment, 3 if definition == THUNDERWOLF else 5): return
		var weapons: Dictionary
		if definition == THUNDERWOLF:
			unit.thunderwolf_cavalry_loadout = str(equipment.thunderwolf_cavalry_loadout)
			unit.thunderwolf_cavalry_storm_shield = unit.thunderwolf_cavalry_loadout == "boltgun-storm-shield"
			weapons = Marines.thunderwolf_cavalry_weapons(unit.thunderwolf_cavalry_loadout)
		else:
			unit.wulfen_loadout = str(equipment.wulfen_loadout)
			unit.wulfen_death_totem = unit.wulfen_loadout == "death-totem"
			weapons = Marines.wulfen_weapons(unit.wulfen_loadout) if definition == WULFEN else Marines.wulfen_storm_shields_weapons(unit.wulfen_loadout)
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.space_wolves_squad_loadout_locked = true
		return
	if definition in [FIRESTRIKE, INFILTRATORS, BLADEGUARD]:
		var minimum := 1 if definition == FIRESTRIKE else 5 if definition == INFILTRATORS else 3
		if not valid(definition, equipment, minimum): return
		var profile := Marines.profile(definition.get_slice(":", 3))
		unit.melee_weapons = profile.melee.duplicate(true)
		if definition == FIRESTRIKE:
			unit.firestrike_autocannon = bool(equipment.firestrike_autocannon)
			unit.ranged_weapons = [Marines.firestrike_autocannon()] if unit.firestrike_autocannon else profile.ranged.duplicate(true)
			unit.firestrike_loadout_locked = true
		elif definition == INFILTRATORS:
			unit.helix_gauntlet = bool(equipment.helix_gauntlet)
			unit.ranged_weapons = profile.ranged.duplicate(true)
			unit.infiltrator_loadout_locked = true
		else:
			unit.bladeguard_pistol = str(equipment.bladeguard_pistol)
			unit.ranged_weapons = [Marines.bladeguard_pistol(unit.bladeguard_pistol)]
			unit.bladeguard_loadout_locked = true
		return
	if TransportEquipment.supports(definition):
		TransportEquipment.prepare(unit, definition, equipment)
		return
	if definition in [CENTURION_ASSAULT, CENTURION_DEVASTATOR]:
		if not valid(definition, equipment, 3): return
		for field: String in equipment: unit[field] = equipment[field]
		if definition == CENTURION_ASSAULT:
			var weapons := Marines.centurion_assault_weapons(bool(equipment.centurion_assault_launcher), bool(equipment.centurion_twin_meltagun))
			unit.ranged_weapons = weapons.ranged
			unit.melee_weapons = weapons.melee
			var keywords: Array = unit.get("keywords", []).duplicate()
			keywords.erase("EXPLOSIVES")
			if bool(equipment.centurion_assault_launcher): keywords.append("EXPLOSIVES")
			unit.keywords = keywords
		else:
			var weapons := Marines.centurion_devastator_weapons(str(equipment.centurion_devastator_bolters), str(equipment.centurion_devastator_support))
			unit.ranged_weapons = weapons.ranged
			unit.melee_weapons = weapons.melee
		unit.centurion_loadout_locked = true
		return
	if definition == TARANTULA_SENTRY_BATTERY:
		if not valid(definition, equipment, 1): return
		var weapons := Marines.tarantula_sentry_battery_weapons(str(equipment.tarantula_sentry_primary))
		if weapons.is_empty(): return
		unit.tarantula_sentry_primary = str(equipment.tarantula_sentry_primary)
		unit.ranged_weapons = weapons.ranged
		unit.tarantula_sentry_loadout_locked = true
		return
	if definition in [DEATH_COMPANY_MARINES, DEATH_COMPANY_JUMP_PACK_MARINES]:
		if not valid(definition, equipment, 5): return
		var identity := _death_company_identity(definition)
		var grenade_launcher := bool(equipment.get("death_company_grenade_launcher", false))
		var weapons := Marines.death_company_model_weapons(identity, str(equipment.death_company_melee_package), str(equipment.death_company_pistol_package), grenade_launcher)
		if weapons.is_empty(): return
		unit.death_company_melee_package = str(equipment.death_company_melee_package)
		unit.death_company_pistol_package = str(equipment.death_company_pistol_package)
		unit.death_company_grenade_launcher = grenade_launcher
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.death_company_saved_loadout_locked = true
		return
	if definition == SANGUINARY_GUARD:
		if not valid(definition, equipment, 3): return
		var inferno_pistol := bool(equipment.sanguinary_guard_inferno_pistol)
		var guard_weapons := Marines.sanguinary_guard_weapons(inferno_pistol)
		if guard_weapons.is_empty(): return
		unit.sanguinary_guard_inferno_pistol = inferno_pistol
		unit.ranged_weapons = guard_weapons.ranged
		unit.melee_weapons = guard_weapons.melee
		unit.sanguinary_guard_loadout_locked = true
		return
	if not valid(definition, equipment, 1): return
	if definition in TEMPLAR_GLADIATORS:
		var source := Marines.profile(definition.get_slice(":", 3))
		unit.ranged_weapons = source.ranged.duplicate(true)
		unit.melee_weapons = source.melee.duplicate(true)
		unit.gladiator_extra_multi_melta = bool(equipment.gladiator_extra_multi_melta)
		if unit.gladiator_extra_multi_melta:
			# All three BT export rows match the independently verified Land Raider weapon.
			var extra := Marines.additional_weapon("land-raider", "ranged", "multi-melta")
			extra.id = "gladiator-additional-multi-melta"
			unit.ranged_weapons.append(extra)
		unit.templar_gladiator_loadout_locked = true
		return
	if definition == REDEMPTOR:
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = Marines.redemptor_weapons(bool(equipment.redemptor_fragstorm), bool(equipment.redemptor_heavy_flamer), bool(equipment.redemptor_macro_plasma), bool(equipment.redemptor_icarus))
		unit.melee_weapons = Marines.profile("redemptor-dreadnought").melee.duplicate(true)
		unit.redemptor_loadout_locked = true
		return
	if definition == WOLF_GUARD_BATTLE_LEADER:
		var source := Marines.profile("wolf-guard-battle-leader")
		var weapons := Marines.wolf_guard_battle_leader_weapons(str(equipment.wolf_guard_battle_leader_ranged_loadout), str(equipment.wolf_guard_battle_leader_melee_loadout))
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.wolf_guard_battle_leader_storm_shield = str(equipment.wolf_guard_battle_leader_ranged_loadout) == "storm-shield"
		unit.max_wounds = int(source.stats.wounds) + (1 if unit.wolf_guard_battle_leader_storm_shield else 0)
		unit.wounds = unit.max_wounds
		unit.wolf_guard_battle_leader_loadout_locked = true
		return
	if definition == EXECRATOR:
		var weapons := Marines.execrator_weapons(str(equipment.execrator_pistol_package), bool(equipment.execrator_mastercrafted_power_weapon))
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.execrator_loadout_locked = true
		return
	if definition == PHOBOS_LIEUTENANT:
		unit.phobos_carbine = bool(equipment.phobos_carbine)
		unit.ranged_weapons = Marines.phobos_lieutenant_gun(unit.phobos_carbine)
		unit.melee_weapons = Marines.profile("lieutenant-in-phobos-armour").melee.duplicate(true)
		unit.phobos_lieutenant_loadout_locked = true
		return
	if definition == TERMINATOR_CHAPLAIN:
		var source := Marines.profile("chaplain-in-terminator-armour")
		var shield := bool(equipment.terminator_chaplain_relic_shield)
		unit.relic_shield = shield
		unit.ranged_weapons = [] if shield else source.ranged.duplicate(true)
		unit.melee_weapons = source.melee.duplicate(true)
		unit.max_wounds = int(source.stats.wounds) + (1 if shield else 0)
		unit.wounds = unit.max_wounds
		unit.terminator_chaplain_loadout_locked = true
		return
	if definition == RAPIER_CARRIER:
		var weapons := Marines.rapier_carrier_weapons(str(equipment.rapier_carrier_primary))
		unit.rapier_carrier_primary = str(equipment.rapier_carrier_primary)
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.rapier_carrier_loadout_locked = true
		return
	if definition == RHINO:
		var missile := bool(equipment.rhino_hunter_killer_missile)
		var weapons := Marines.rhino_weapons(missile)
		if weapons.is_empty(): return
		unit.rhino_hunter_killer_missile = missile
		unit.optional_transport_weapons = {"hunter-killer-missile": missile}
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.transport_loadout_locked = true
		return
	if definition == RHINO_PRIMARIS:
		var missile := bool(equipment.rhino_hunter_killer_missile)
		var weapons := Marines.rhino_primaris_weapons(missile)
		if weapons.is_empty(): return
		unit.rhino_hunter_killer_missile = missile
		unit.optional_transport_weapons = {"hunter-killer-missile": missile}
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.transport_loadout_locked = true
		return
	if definition == NEPHILIM:
		var lascannons := str(equipment.nephilim_lascannon_package) == "lascannons"
		unit.nephilim_lascannons = lascannons
		unit.ranged_weapons = Marines.nephilim_jetfighter_weapons(lascannons)
		unit.nephilim_loadout_locked = true
		return
	if definition == CERBERUS or definition == TYPHON or definition == FALCHION:
		var source := "cerberus" if definition == CERBERUS else ("typhon" if definition == TYPHON else "falchion")
		var weapons: Dictionary
		if definition == CERBERUS:
			weapons = Marines.cerberus_weapons(str(equipment.cerberus_optional_weapon), str(equipment.cerberus_optional_pair))
		elif definition == TYPHON:
			weapons = Marines.typhon_weapons(str(equipment.typhon_sponson_package), str(equipment.typhon_hull_weapon))
		else:
			weapons = Marines.falchion_weapons(str(equipment.falchion_optional_weapon), str(equipment.falchion_main_armament), str(equipment.falchion_twin_replacement))
		if weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit[source + "_loadout_locked"] = true
		return
	if definition == DREADNOUGHT:
		var dreadnought_weapons := Marines.dreadnought_weapons(str(equipment.dreadnought_primary), str(equipment.dreadnought_melee_package), str(equipment.dreadnought_secondary))
		if dreadnought_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = dreadnought_weapons.ranged
		unit.melee_weapons = dreadnought_weapons.melee
		unit.dreadnought_loadout_locked = true
		return
	if definition == VENERABLE_DREADNOUGHT:
		var venerable_weapons := Marines.venerable_dreadnought_legends_weapons(str(equipment.venerable_dreadnought_legends_primary), str(equipment.venerable_dreadnought_legends_package))
		if venerable_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = venerable_weapons.ranged
		unit.melee_weapons = venerable_weapons.melee
		unit.venerable_dreadnought_legends_loadout_locked = true
		return
	if definition == STORMHAWK:
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = Marines.stormhawk_interceptor_weapons(bool(equipment.stormhawk_icarus_stormcannon), str(equipment.stormhawk_missile_launcher))
		unit.stormhawk_loadout_locked = true
		return
	if definition == STORMTALON:
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = Marines.stormtalon_gunship_weapons(str(equipment.stormtalon_missile_launcher))
		unit.stormtalon_loadout_locked = true
		return
	if definition in [BJORN, SPACE_WOLVES_VENERABLE, WULFEN_DREADNOUGHT]:
		var identity := definition.get_slice(":", 3)
		var walker_weapons := Marines.space_wolves_walker_weapons(identity, str(equipment.get("space_wolves_walker_primary", "")), str(equipment.get("space_wolves_walker_secondary", "")), str(equipment.get("space_wolves_walker_melee_package", "")))
		if walker_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.space_wolves_walker_primary = str(walker_weapons.ranged_primary)
		unit.space_wolves_walker_secondary = str(walker_weapons.ranged_secondary)
		unit.space_wolves_walker_melee_package = str(walker_weapons.melee_package)
		unit.space_wolves_blizzard_shield = bool(walker_weapons.blizzard_shield)
		unit.ranged_weapons = walker_weapons.ranged
		unit.melee_weapons = walker_weapons.melee
		unit.space_wolves_walker_loadout_locked = true
		return
	if definition == DEATH_COMPANY_DREADNOUGHT:
		var death_company_weapons := Marines.death_company_dreadnought_weapons(bool(equipment.death_company_twin_multi_melta), bool(equipment.death_company_blood_talons))
		if death_company_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = death_company_weapons.ranged
		unit.melee_weapons = death_company_weapons.melee
		unit.death_company_dreadnought_loadout_locked = true
		return
	if definition == DEATH_COMPANY_CAPTAIN:
		var captain_weapons := Marines.death_company_captain_weapons(str(equipment.death_company_captain_pistol), str(equipment.death_company_captain_melee))
		if captain_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = captain_weapons.ranged
		unit.melee_weapons = captain_weapons.melee
		unit.death_company_captain_loadout_locked = true
		return
	if definition == DEATH_COMPANY_JUMP_CAPTAIN:
		var jump_captain_weapons := Marines.death_company_jump_captain_weapons(str(equipment.death_company_jump_captain_loadout))
		if jump_captain_weapons.is_empty(): return
		unit.death_company_jump_captain_loadout = str(equipment.death_company_jump_captain_loadout)
		unit.ranged_weapons = jump_captain_weapons.ranged
		unit.melee_weapons = jump_captain_weapons.melee
		unit.relic_shield = bool(jump_captain_weapons.get("relic_shield", false))
		unit.max_wounds = 6 if unit.relic_shield else 5
		unit.wounds = unit.max_wounds
		unit.death_company_jump_captain_loadout_locked = true
		return
	if definition == BLOOD_ANGELS_CAPTAIN:
		var blood_angels_captain_weapons := Marines.blood_angels_captain_weapons(str(equipment.blood_angels_captain_pistol), str(equipment.blood_angels_captain_melee))
		if blood_angels_captain_weapons.is_empty(): return
		for field: String in equipment: unit[field] = equipment[field]
		unit.ranged_weapons = blood_angels_captain_weapons.ranged
		unit.melee_weapons = blood_angels_captain_weapons.melee
		unit.blood_angels_captain_loadout_locked = true
		return
	if definition == CAPTAIN:
		var captain_weapons := Marines.captain_weapons(str(equipment.captain_ranged_loadout), str(equipment.captain_melee_weapon) == "power-fist")
		if captain_weapons.is_empty(): return
		unit.captain_ranged_loadout = str(equipment.captain_ranged_loadout)
		unit.captain_power_fist = str(equipment.captain_melee_weapon) == "power-fist"
		unit.ranged_weapons = captain_weapons.ranged
		unit.melee_weapons = captain_weapons.melee
		unit.relic_shield = bool(captain_weapons.relic_shield)
		unit.max_wounds = 6 if unit.relic_shield else 5
		unit.wounds = unit.max_wounds
		unit.captain_loadout_locked = true
		return
	if definition == CAPTAIN_WITH_JUMP_PACK:
		var jump_pack_captain_weapons := Marines.jump_pack_captain_weapons(str(equipment.jump_captain_loadout))
		if jump_pack_captain_weapons.is_empty(): return
		unit.jump_captain_loadout = str(equipment.jump_captain_loadout)
		unit.ranged_weapons = jump_pack_captain_weapons.ranged
		unit.melee_weapons = jump_pack_captain_weapons.melee
		unit.relic_shield = bool(jump_pack_captain_weapons.relic_shield)
		unit.max_wounds = 6 if unit.relic_shield else 5
		unit.wounds = unit.max_wounds
		unit.jump_captain_loadout_locked = true
		return
	if definition == GRAVIS_CAPTAIN:
		var gravis_captain_weapons := Marines.gravis_captain_weapons(str(equipment.gravis_loadout))
		if gravis_captain_weapons.is_empty(): return
		unit.gravis_loadout = str(equipment.gravis_loadout)
		unit.ranged_weapons = gravis_captain_weapons.ranged
		unit.melee_weapons = gravis_captain_weapons.melee
		unit.gravis_loadout_locked = true
		return
	if definition == TERMINATOR_CAPTAIN:
		var terminator_captain_combi := bool(equipment.terminator_captain_combi_weapon)
		var terminator_captain_fist := bool(equipment.terminator_captain_relic_fist)
		var terminator_captain_weapons := Marines.terminator_captain_weapons(terminator_captain_combi, terminator_captain_fist)
		if terminator_captain_weapons.is_empty(): return
		unit.terminator_combi = terminator_captain_combi
		unit.terminator_fist = terminator_captain_fist
		unit.ranged_weapons = terminator_captain_weapons.ranged
		unit.melee_weapons = terminator_captain_weapons.melee
		unit.terminator_captain_loadout_locked = true
		return
	if definition == BIKE_CAPTAIN:
		var bike_plasma_pistol := bool(equipment.captain_bike_plasma_pistol)
		var bike_thunder_hammer := bool(equipment.captain_bike_thunder_hammer)
		var bike_weapons := Marines.captain_bike_weapons(bike_plasma_pistol, bike_thunder_hammer)
		if bike_weapons.is_empty(): return
		unit.captain_bike_plasma_pistol = bike_plasma_pistol
		unit.captain_bike_thunder_hammer = bike_thunder_hammer
		unit.ranged_weapons = bike_weapons.ranged
		unit.melee_weapons = bike_weapons.melee
		unit.captain_bike_loadout_locked = true
		return
	if definition == BRUTALIS:
		var brutalis_talons := bool(equipment.brutalis_talons)
		var brutalis_multi_melta := bool(equipment.brutalis_multi_melta)
		var brutalis_weapons := Marines.brutalis_weapons(brutalis_talons, brutalis_multi_melta)
		if brutalis_weapons.is_empty(): return
		unit.brutalis_talons = brutalis_talons
		unit.brutalis_multi_melta = brutalis_multi_melta
		unit.ranged_weapons = brutalis_weapons.ranged
		unit.melee_weapons = brutalis_weapons.melee
		unit.brutalis_loadout_locked = true
		return
	if definition == CASTELLAN:
		var castellan_weapons := Marines.castellan_weapons(str(equipment.castellan_ranged_package), str(equipment.castellan_melee_package))
		if castellan_weapons.is_empty(): return
		unit.castellan_ranged_package = str(equipment.castellan_ranged_package)
		unit.castellan_melee_package = str(equipment.castellan_melee_package)
		unit.ranged_weapons = castellan_weapons.ranged
		unit.melee_weapons = castellan_weapons.melee
		unit.castellan_loadout_locked = true
		return
	if definition == MARSHAL:
		var marshal_weapons := Marines.marshal_weapons(str(equipment.marshal_ranged_package))
		if marshal_weapons.is_empty(): return
		unit.marshal_ranged_package = str(equipment.marshal_ranged_package)
		unit.ranged_weapons = marshal_weapons.ranged
		unit.melee_weapons = marshal_weapons.melee
		unit.marshal_loadout_locked = true
		return
	if definition == LIEUTENANT:
		var lieutenant_weapons := Marines.lieutenant_weapons(str(equipment.lieutenant_weapon_package), str(equipment.lieutenant_fists_replacement), bool(equipment.lieutenant_storm_shield))
		if lieutenant_weapons.is_empty(): return
		unit.lieutenant_weapon_package = str(equipment.lieutenant_weapon_package)
		unit.lieutenant_fists_replacement = str(equipment.lieutenant_fists_replacement)
		unit.lieutenant_storm_shield = bool(equipment.lieutenant_storm_shield)
		unit.ranged_weapons = lieutenant_weapons.ranged
		unit.melee_weapons = lieutenant_weapons.melee
		var defense: Dictionary = unit.get("defense", {}).duplicate(true)
		if bool(equipment.lieutenant_storm_shield): defense["invulnerable_target"] = 4
		else: defense.erase("invulnerable_target")
		if defense.is_empty(): unit.erase("defense")
		else: unit.defense = defense
		unit.lieutenant_loadout_locked = true
		return
	if definition == HAMMERFALL:
		var weapons := Marines.hammerfall_weapons(bool(equipment.hammerfall_heavy_flamer_array))
		if weapons.is_empty(): return
		unit.hammerfall_heavy_flamer_array = bool(equipment.hammerfall_heavy_flamer_array)
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.hammerfall_loadout_locked = true
		return
	if definition == VINDICATOR or definition == WHIRLWIND:
		var prefix := "vindicator" if definition == VINDICATOR else "whirlwind"
		var missile_field := prefix + "_hunter_killer_missile"
		var storm_field := prefix + "_storm_bolter"
		var missile := bool(equipment[missile_field])
		var storm_bolter := bool(equipment[storm_field])
		var weapons: Dictionary = Marines.vindicator_weapons(storm_bolter, missile) if definition == VINDICATOR else Marines.whirlwind_weapons(missile, storm_bolter)
		if weapons.is_empty(): return
		unit[missile_field] = missile
		unit[storm_field] = storm_bolter
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit[prefix + "_loadout_locked"] = true
		return
	if definition == ANCIENT:
		unit.ancient_power = equipment.ancient_weapon == "power"
		var weapons := Marines.ancient_weapons(unit.ancient_power)
		unit.ranged_weapons = weapons.ranged
		unit.melee_weapons = weapons.melee
		unit.ancient_loadout_locked = true
		return
	unit.invictor_autocannon = equipment.invictor_cannon == "autocannon"
	unit.ranged_weapons = Marines.invictor_weapons(unit.invictor_autocannon)
	unit.invictor_loadout_locked = true

static func points_for_loadout(definition: String, loadout: Variant, models: int) -> int:
	if NecronEquipment.supports(definition): return NecronEquipment.points(definition, loadout, models)
	if Deathwing.supports(definition): return Deathwing.points(definition, loadout, models)
	if Terminators.supports(definition): return Terminators.points(definition, loadout, models)
	if Deathwatch.supports(definition): return Deathwatch.points(definition, loadout, models)
	if VanguardVeterans.supports(definition): return VanguardVeterans.points(definition, loadout, models)
	if Ravenwing.supports(definition): return Ravenwing.points(definition, loadout, models)
	if ScoutBikes.supports(definition): return ScoutBikes.points(definition, loadout, models)
	if SwordBrethren.supports(definition): return SwordBrethren.points(definition, loadout, models)
	if Crusader.supports(definition): return Crusader.points(definition, loadout, models)
	if Decimus.supports(definition): return Decimus.points(definition, loadout, models)
	if Fortis.supports(definition): return Fortis.points(definition, loadout, models)
	if Spectrus.supports(definition): return Spectrus.points(definition, loadout, models)
	if Talonstrike.supports(definition): return Talonstrike.points(definition, loadout, models)
	if SpecialistSquads.supports(definition): return SpecialistSquads.points(definition, loadout, models)
	if definition == THUNDERWOLF:
		if not valid_saved_loadout(definition, loadout, models): return 0
		var shields := 0
		for equipment: Dictionary in loadout:
			if str(equipment.thunderwolf_cavalry_loadout) == "boltgun-storm-shield": shields += 1
		return shields * int(Marines.profile("thunderwolf-cavalry").wargear_costs["storm-shield"])
	if definition in TEMPLAR_GLADIATORS:
		if not valid_saved_loadout(definition, loadout, models): return 0
		var source := Marines.profile(definition.get_slice(":", 3))
		var count := 1 if bool(loadout.gladiator_extra_multi_melta) else 0
		for weapon: Dictionary in source.ranged:
			if str(weapon.get("profiles", {}).get("standard", {}).get("name", "")) == "Multi-melta": count += 1
		return count * int(source.wargear_costs["Multi-melta"])
	if TransportEquipment.supports(definition): return TransportEquipment.points(definition, loadout, models)
	if definition != REDEMPTOR or not valid_saved_loadout(definition, loadout, models): return 0
	return int(Marines.profile("redemptor-dreadnought").wargear_costs["macro-plasma-incinerator"]) if bool(loadout.redemptor_macro_plasma) else 0

static func summary(definition: String, equipment: Dictionary, models: int = 0, model_index: int = -1) -> String:
	var labels: Array[String] = []
	var descriptors := controls(definition)
	if NecronEquipment.supports(definition) and model_index >= 0: descriptors = NecronEquipment.controls_for_model(definition, models, model_index)
	if VanguardVeterans.supports(definition) and model_index >= 0: descriptors = VanguardVeterans.controls_for_model(definition, models, model_index)
	if Indomitor.supports(definition) and model_index >= 0: descriptors = Indomitor.controls_for_model(definition, models, model_index)
	if Decimus.supports(definition) and model_index >= 0: descriptors = Decimus.controls_for_model(definition, models, model_index)
	if Fortis.supports(definition) and model_index >= 0: descriptors = Fortis.controls_for_model(definition, models, model_index)
	if Spectrus.supports(definition) and model_index >= 0: descriptors = Spectrus.controls_for_model(definition, models, model_index)
	if Talonstrike.supports(definition) and model_index >= 0: descriptors = Talonstrike.controls_for_model(definition, models, model_index)
	for descriptor: Dictionary in descriptors:
		for choice: Dictionary in descriptor.choices:
			if equipment.get(descriptor.field) == choice.id: labels.append(str(choice.label))
	return " + ".join(labels) if not labels.is_empty() else "No optional weapons"

static func _death_company_identity(definition: String) -> String:
	return "death-company-marines-with-jump-packs" if definition == DEATH_COMPANY_JUMP_PACK_MARINES else "death-company-marines"

static func _optional_weapon_controls(prefix: String) -> Array[Dictionary]:
	var missile := prefix + "_hunter_killer_missile"
	var storm := prefix + "_storm_bolter"
	return [
		{"field": missile, "label": "Hunter-killer Missile", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]},
		{"field": storm, "label": "Storm Bolter", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped"}]}
	]

static func _choices(ids: Array, labels: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in range(ids.size()): result.append({"id": ids[index], "label": labels[index]})
	return result

static func supports_unit(definition: String) -> bool:
	return Deathwing.supports(definition)
static func unit_defaults(definition: String) -> Dictionary:
	return Deathwing.unit_defaults(definition)
static func unit_controls(definition: String) -> Array[Dictionary]:
	return Deathwing.unit_controls(definition)
static func valid_unit(definition: String, equipment: Variant) -> bool:
	return Deathwing.unit_valid(definition, equipment)
static func prepare_unit(squad: Dictionary, definition: String, equipment: Dictionary) -> void:
	Deathwing.prepare_unit(squad, definition, equipment)

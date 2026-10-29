extends SceneTree
## Offline audit helper; exports runtime data without starting a match or using saves.
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const IDENTITIES := ["chaplain-on-bike", "captain-on-bike", "adrax-agatone", "kaius-konorius", "librarian", "aethon-shaan", "intercessor-squad", "assault-intercessor-squad", "heavy-intercessor-squad", "terminator-squad", "terminator-assault-squad", "captain", "lieutenant",
	"infiltrator-squad", "lieutenant-in-phobos-armour", "captain-in-gravis-armour", "tor-garadon", "darnath-lysander", "suboden-khan", "iron-father-feirros", "chief-librarian-tigurius", "kayvaan-shrike", "cato-sicarius", "victrix-honour-guard", "marneus-calgar", "caanok-var", "ancient-in-terminator-armour", "wardens-of-ultramar", "captain-in-terminator-armour", "chaplain-in-terminator-armour", "apothecary", "ancient", "bladeguard-ancient", "bladeguard-veteran-squad", "judiciar", "chaplain", "sternguard-veteran-squad", "eliminator-squad", "eradicator-squad-with-melta-rifles", "eradicator-squad-with-heavy-bolters", "apothecary-biologis", "aggressor-squad", "infernus-squad", "hellblaster-squad", "assault-intercessors-with-jump-packs", "captain-with-jump-pack", "vanguard-veteran-squad-with-jump-packs", "chaplain-with-jump-pack", "librarian-in-terminator-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "scout-squad", "incursor-squad", "reiver-squad", "firestrike-servo-turrets", "ballistus-dreadnought", "redemptor-dreadnought", "brutalis-dreadnought", "invictor-tactical-warsuit", "desolation-squad", "lieutenant-with-combi-weapon", "techmarine", "roboute-guilliman", "lion-eljonson", "emperor-s-champion", "black-templars-gladiator-lancer", "black-templars-gladiator-reaper", "black-templars-gladiator-valiant", "black-templars-impulsor", "black-templars-repulsor", "black-templars-repulsor-executioner", "inceptor-squad", "company-heroes", "outrider-squad", "gladiator-reaper", "gladiator-valiant", "gladiator-lancer", "land-speeder", "storm-speeder-hammerstrike", "storm-speeder-hailstrike", "storm-speeder-thunderstrike", "invader-atvs", "kor-sarro-khan", "captain-titus", "vulkan-hestan", "land-raider", "land-raider-crusader", "drop-pod", "land-raider-redeemer", "impulsor", "repulsor", "repulsor-executioner", "rhino"]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--output":
		push_error("Expected --output <new JSON path>")
		quit(1)
		return
	if FileAccess.file_exists(args[1]):
		push_error("Output already exists")
		quit(1)
		return
	var current_catalog: Dictionary = Profiles.catalog()
	var identities: Array[String] = []
	for identity_variant: Variant in IDENTITIES:
		var identity := str(identity_variant)
		if not identities.has(identity): identities.append(identity)
	for identity_variant: Variant in current_catalog:
		var identity := str(identity_variant)
		if not identities.has(identity): identities.append(identity)
	identities.sort()
	var profiles := {}
	for identity: String in identities:
		profiles[identity] = Profiles.profile(identity)
		if identity == "crusader-squad":
			var crusader_loadouts: Array[Dictionary] = []
			var crusader_model_count := int(profiles[identity].get("models", 10))
			for model_index in range(crusader_model_count):
				var loadout := Profiles.crusader_squad_model_loadout(model_index, crusader_model_count)
				if not loadout.is_empty(): crusader_loadouts.append(loadout)
			profiles[identity].model_loadouts = crusader_loadouts
		if identity == "wolf-scouts":
			var wolf_scout_loadouts: Array[Dictionary] = []
			var wolf_scout_model_count := int(profiles[identity].get("models", 6))
			for model_index in range(wolf_scout_model_count):
				var loadout := Profiles.wolf_scouts_model_loadout(model_index, wolf_scout_model_count)
				if not loadout.is_empty(): wolf_scout_loadouts.append(loadout)
			profiles[identity].model_loadouts = wolf_scout_loadouts
			var instigator_loadout: Dictionary = Profiles.wolf_scouts_model_loadout(3, 12, "instigator-bolt-carbine")
			var instigator_weapons: Array = instigator_loadout.get("ranged", [])
			var additional_profiles: Dictionary = profiles[identity].get("additional_weapon_profiles", {}).duplicate(true)
			var additional_ranged: Array = additional_profiles.get("ranged", []).duplicate(true)
			if not instigator_weapons.is_empty():
				for option_index in range(additional_ranged.size()):
					if str(additional_ranged[option_index].get("id", "")) == "instigator-bolt-carbine":
						additional_ranged[option_index] = instigator_weapons[0].duplicate(true)
			additional_profiles["ranged"] = additional_ranged
			profiles[identity].additional_weapon_profiles = additional_profiles
		var keywords: Array = profiles[identity].get("keywords", [])
		profiles[identity].max_supported_copies = int(Army.SPECS.get(identity, {}).get("max_supported_copies", 6 if "BATTLELINE" in keywords else 3))
		if Roster.POINTS.has(identity):
			profiles[identity].fixed_roster = Roster.POINTS[identity].duplicate(true)
			var profile_wargear_costs: Dictionary = profiles[identity].get("wargear_costs", {})
			if not profile_wargear_costs.is_empty():
				profiles[identity].fixed_roster.wargear_costs = profile_wargear_costs.duplicate(true)
		if identity == "scout-squad":
			profiles[identity].additional_weapon_profiles = {"ranged": [
				Profiles.scout_ranged("shotgun")[1], Profiles.scout_ranged("sniper-rifle")[1],
				Profiles.scout_ranged("heavy-bolter")[1], Profiles.scout_ranged("missile-launcher")[1]],
				"melee": [Profiles.scout_melee("chainsword")[0]]}
		if identity == "firestrike-servo-turrets":
			profiles[identity].additional_weapon_profiles = {"ranged": [Profiles.firestrike_autocannon()]}
		if identity == "redemptor-dreadnought":
			var options: Dictionary = profiles[identity].additional_weapon_profiles
			profiles[identity].additional_weapon_profiles = {"ranged": [options.storm_bolters, options.onslaught, options.macro_plasma, options.icarus_rocket_pod], "melee": []}
		if identity == "brutalis-dreadnought":
			var options: Dictionary = profiles[identity].additional_weapon_profiles
			profiles[identity].additional_weapon_profiles = {"ranged": [options.twin_multi_melta], "melee": [options.brutalis_talons]}
		if identity == "invictor-tactical-warsuit":
			profiles[identity].additional_weapon_profiles = {"ranged": [profiles[identity].additional_weapon_profiles.twin_ironhail_autocannon], "melee": []}
		if identity == "desolation-squad":
			profiles[identity].additional_weapon_profiles = {"ranged": [profiles[identity].additional_weapon_profiles.superkrak, profiles[identity].additional_weapon_profiles.vengor], "melee": []}
		if identity == "inceptor-squad":
			profiles[identity].additional_weapon_profiles = {"ranged": profiles[identity].additional_weapon_profiles.ranged, "melee": []}
		if identity == "captain":
			var neo_volkite: Dictionary = Profiles.captain_weapons("neo-volkite")
			var plasma_pistol: Dictionary = Profiles.captain_weapons("plasma-pistol")
			var relic_shield: Dictionary = Profiles.captain_weapons("relic-shield")
			var power_fist: Dictionary = Profiles.captain_weapons("default", true)
			profiles[identity].additional_weapon_profiles = {"ranged": [neo_volkite.ranged[0], plasma_pistol.ranged[0], relic_shield.ranged[0]], "melee": [power_fist.melee[0]]}
		if identity == "captain-with-jump-pack":
			var hand_flamer: Dictionary = Profiles.jump_pack_captain_weapons("hand-flamer")
			var plasma_pistol: Dictionary = Profiles.jump_pack_captain_weapons("plasma-pistol")
			var power_fist: Dictionary = Profiles.jump_pack_captain_weapons("power-fist")
			var relic_weapon: Dictionary = Profiles.jump_pack_captain_weapons("relic-weapon")
			var thunder_hammer: Dictionary = Profiles.jump_pack_captain_weapons("thunder-hammer-shield")
			profiles[identity].additional_weapon_profiles = {
				"ranged": [hand_flamer.ranged[0], plasma_pistol.ranged[0]],
				"melee": [power_fist.melee[0], relic_weapon.melee[0], thunder_hammer.melee[0]]}
		if identity == "captain-in-gravis-armour":
			var blade_loadout: Dictionary = Profiles.gravis_captain_weapons("blade")
			var chainsword_loadout: Dictionary = Profiles.gravis_captain_weapons("chainsword")
			var fist_loadout: Dictionary = Profiles.gravis_captain_weapons("fist")
			profiles[identity].additional_weapon_profiles = {
				"ranged": [blade_loadout.ranged[0]],
				"melee": [blade_loadout.melee[0], blade_loadout.melee[1], chainsword_loadout.melee[1], fist_loadout.melee[1]]}
		if identity == "sternguard-veteran-squad":
			profiles[identity].additional_weapon_profiles = {
				"ranged": [Profiles.sternguard_gun("heavy"), Profiles.sternguard_gun("pyre")],
				"melee": [Profiles.sternguard_melee("chain"), Profiles.sternguard_melee("fist"), Profiles.sternguard_melee("power")]}
		if identity == "assault-intercessors-with-jump-packs":
			profiles[identity].additional_weapon_profiles = {
				"ranged": [Profiles.jump_pack_pistol("hand-flamer"), Profiles.jump_pack_pistol("plasma-pistol")],
				"melee": [Profiles.jump_pack_sergeant_melee("power-fist"), Profiles.jump_pack_sergeant_melee("power-weapon")]}
		if identity == "captain-in-terminator-armour":
			var alternatives: Dictionary = Profiles.terminator_captain_weapons(true, true)
			profiles[identity].additional_weapon_profiles = {"ranged": alternatives.ranged, "melee": alternatives.melee}
		if identity == "bladeguard-veteran-squad":
			profiles[identity].additional_weapon_profiles = {
				"ranged": [Profiles.bladeguard_pistol("volkite"), Profiles.bladeguard_pistol("plasma")],
				"melee": []}
		if identity == "eradicator-squad-with-melta-rifles":
			profiles[identity].additional_weapon_profiles = {"ranged": [Profiles.eradicator_ranged(true)], "melee": []}
		if identity == "hellblaster-squad":
			profiles[identity].additional_weapon_profiles = {"ranged": [Profiles.hellblaster_pistol(true)], "melee": []}
		if identity == "eliminator-squad":
			profiles[identity].additional_weapon_profiles = {
				"ranged": [Profiles.eliminator_gun("carbine"), Profiles.eliminator_gun("las")],
				"melee": []}
		if identity == "aggressor-squad":
			profiles[identity].additional_weapon_profiles = {"ranged": Profiles.aggressor_ranged(true), "melee": []}
		if identity == "lieutenant-in-phobos-armour":
			profiles[identity].additional_weapon_profiles = {"ranged": Profiles.phobos_lieutenant_gun(true), "melee": []}
		if identity == "ancient":
			var power_loadout: Dictionary = Profiles.ancient_weapons(true)
			profiles[identity].additional_weapon_profiles = {"ranged": [], "melee": [power_loadout.melee[1]]}
		if identity == "company-heroes":
			var ranged: Array[Dictionary] = []
			var melee: Array[Dictionary] = []
			for model_index in range(4):
				var model_loadout := Profiles.company_heroes_model_loadout(model_index)
				for weapon: Dictionary in model_loadout.ranged:
					if profiles[identity].ranged.any(func(existing: Dictionary) -> bool: return existing.id == weapon.id): continue
					if not ranged.any(func(existing: Dictionary) -> bool: return existing.id == weapon.id): ranged.append(weapon)
				for weapon: Dictionary in model_loadout.melee:
					if profiles[identity].melee.any(func(existing: Dictionary) -> bool: return existing.id == weapon.id): continue
					if not melee.any(func(existing: Dictionary) -> bool: return existing.id == weapon.id): melee.append(weapon)
			profiles[identity].additional_weapon_profiles = {"ranged": ranged, "melee": melee}
		if identity == "invader-atvs":
			profiles[identity].additional_weapon_profiles = {"ranged": [profiles[identity].additional_weapon_profiles.ranged[0]], "melee": []}
	var file := FileAccess.open(args[1], FileAccess.WRITE)
	if file == null:
		push_error("Cannot write profile export")
		quit(1)
		return
	file.store_string(JSON.stringify({"id": Profiles.ID, "digest": Profiles.digest(), "roster_digest": Roster.digest(),
		"profile_count": profiles.size(), "manual_option_profile_count": IDENTITIES.size(),
		"audit_scope": "All current runtime profiles; numeric model/default-weapon checks for exported entries; optional weapon profiles are enriched only for the manually enumerated subset.",
		"profiles": profiles}, "\t"))
	file.close()
	if profiles.size() != current_catalog.size():
		push_error("Runtime audit export did not cover the complete current Marine catalog")
		quit(1)
		return
	print("Exported %d runtime Marine profiles for audit (%d with manually enriched option profiles)" % [profiles.size(), IDENTITIES.size()])
	quit(0)

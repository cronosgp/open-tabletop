extends SceneTree
## Offline audit helper; exports runtime data without starting a match or using saves.
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const IDENTITIES := ["chaplain-on-bike", "captain-on-bike", "adrax-agatone", "kaius-konorius", "librarian", "aethon-shaan", "intercessor-squad", "assault-intercessor-squad", "heavy-intercessor-squad", "terminator-squad", "terminator-assault-squad", "captain", "lieutenant",
	"infiltrator-squad", "lieutenant-in-phobos-armour", "captain-in-gravis-armour", "tor-garadon", "darnath-lysander", "suboden-khan", "iron-father-feirros", "chief-librarian-tigurius", "kayvaan-shrike", "cato-sicarius", "victrix-honour-guard", "marneus-calgar", "caanok-var", "ancient-in-terminator-armour", "assault-intercessors-with-jump-packs", "captain-with-jump-pack", "vanguard-veteran-squad-with-jump-packs", "chaplain-with-jump-pack", "librarian-in-terminator-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "scout-squad", "incursor-squad", "reiver-squad", "firestrike-servo-turrets", "ballistus-dreadnought", "redemptor-dreadnought", "brutalis-dreadnought", "invictor-tactical-warsuit", "desolation-squad", "lieutenant-with-combi-weapon", "techmarine", "roboute-guilliman", "inceptor-squad", "company-heroes", "outrider-squad", "gladiator-reaper", "gladiator-valiant", "gladiator-lancer", "land-speeder", "storm-speeder-hammerstrike", "storm-speeder-hailstrike", "storm-speeder-thunderstrike", "invader-atvs", "kor-sarro-khan", "captain-titus", "vulkan-hestan", "land-raider", "land-raider-crusader", "drop-pod", "land-raider-redeemer", "impulsor", "repulsor", "repulsor-executioner", "rhino"]

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
	var profiles := {}
	for identity: String in IDENTITIES:
		profiles[identity] = Profiles.profile(identity)
		if Roster.POINTS.has(identity): profiles[identity].fixed_roster = Roster.POINTS[identity].duplicate(true)
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
			profiles[identity].fixed_roster.wargear_costs = profiles[identity].wargear_costs.duplicate(true)
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
	file.store_string(JSON.stringify({"id": Profiles.ID, "digest": Profiles.digest(), "roster_digest": Roster.digest(), "profiles": profiles}, "\t"))
	file.close()
	print("Exported %d runtime Marine profiles for audit" % profiles.size())
	quit(0)

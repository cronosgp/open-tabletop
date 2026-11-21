extends RefCounted
## Persistent, source-bounded model equipment for the Orks App v1.2 profiles.
const Profiles = preload("res://scripts/edition_11/current_reference_orks_profiles.gd")

const BOYZ := "40kdc:11e:orks:boyz"
const BEAST_SNAGGA_BOYZ := "40kdc:11e:orks:beast-snagga-boyz"
const NOBZ := "40kdc:11e:orks:nobz"
const MEGANOBZ := "40kdc:11e:orks:meganobz"
const WARBOSS := "40kdc:11e:orks:warboss"
const BREAKA_BOYZ := "40kdc:11e:orks:breaka-boyz"
const TANKBUSTAS := "40kdc:11e:orks:tankbustas"
const KOMMANDOS := "40kdc:11e:orks:kommandos"
const STORMBOYZ := "40kdc:11e:orks:stormboyz"
const BIG_MEK := "40kdc:11e:orks:big-mek"
const BIG_MEK_MEGA := "40kdc:11e:orks:big-mek-in-mega-armour"
const BEASTBOSS_SQUIGOSAUR := "40kdc:11e:orks:beastboss-on-squigosaur"
const DEFFKOPTAS := "40kdc:11e:orks:deffkoptas"
const MEK_GUNZ := "40kdc:11e:orks:mek-gunz"
const WARBUGGIES := "40kdc:11e:orks:warbuggies"
const DEFF_DREAD := "40kdc:11e:orks:deff-dread"
const TRUKK := "40kdc:11e:orks:trukk"
const BATTLEWAGON := "40kdc:11e:orks:battlewagon"
const GUNWAGON := "40kdc:11e:orks:gunwagon"
const BOSSBUNKA := "40kdc:11e:orks:biged-bossbunka"
const BURNA_BOMMER := "40kdc:11e:orks:burna-bommer"
const DAKKAJET := "40kdc:11e:orks:dakkajet"
const WAZBOM := "40kdc:11e:orks:wazbom-blastajet"

const BOYZ_NOB_FIELD := "ork_boyz_nob_loadout"
const BOYZ_RANGED_FIELD := "ork_boyz_ranged"
const BEAST_SNAGGA_SPECIAL_FIELD := "ork_beast_snagga_special"
const NOBZ_LOADOUT_FIELD := "ork_nobz_loadout"
const MEGANOBZ_LOADOUT_FIELD := "ork_meganobz_loadout"
const WARBOSS_MELEE_FIELD := "ork_warboss_melee"
const WARBOSS_RANGED_FIELD := "ork_warboss_ranged"
const BREAKA_LOADOUT_FIELD := "ork_breaka_loadout"
const TANKBUSTA_LOADOUT_FIELD := "ork_tankbusta_loadout"
const KOMMANDO_LOADOUT_FIELD := "ork_kommando_loadout"
const STORMBOYZ_NOB_FIELD := "ork_stormboyz_nob_melee"
const BIG_MEK_MELEE_FIELD := "ork_big_mek_melee"
const BIG_MEK_RANGED_FIELD := "ork_big_mek_ranged"
const BIG_MEK_MEGA_GEAR_FIELD := "ork_big_mek_mega_gear"
const BIG_MEK_MEGA_WEAPON_FIELD := "ork_big_mek_mega_weapon"
const BEASTBOSS_SQUIGOSAUR_FIELD := "ork_beastboss_squigosaur_ranged"
const DEFFKOPTAS_FIELD := "ork_deffkoptas_ranged"
const MEK_GUNZ_FIELD := "ork_mek_gunz_weapon"
const WARBUGGIES_FIELD := "ork_warbuggies_weapon"
const DEFF_DREAD_SLOT1_FIELD := "ork_deff_dread_slot1"
const DEFF_DREAD_SLOT2_FIELD := "ork_deff_dread_slot2"
const TRUKK_RANGED_FIELD := "ork_trukk_ranged"
const TRUKK_MELEE_FIELD := "ork_trukk_melee"
const BATTLEWAGON_WRECKIN_FIELD := "ork_battlewagon_wreckin_ball"
const BATTLEWAGON_KLAW_FIELD := "ork_battlewagon_grabbin_klaw"
const BATTLEWAGON_SHOOTAS_FIELD := "ork_battlewagon_big_shootas"
const GUNWAGON_CANNON_FIELD := "ork_gunwagon_cannon"
const GUNWAGON_LOBBA_FIELD := "ork_gunwagon_lobba"
const BOSSBUNKA_SHOOTAS_FIELD := "ork_bossbunka_big_shootas"
const BURNA_BOMMER_RACK_FIELD := "ork_burna_bommer_rack"
const DAKKAJET_SUPA_FIELD := "ork_dakkajet_supa_shoota"
const WAZBOM_MAIN_FIELD := "ork_wazbom_main"
const WAZBOM_FIELD_FIELD := "ork_wazbom_force_field"
const WAZBOM_SUPA_FIELD := "ork_wazbom_supa_shoota"

static func supports(definition: String) -> bool:
	return definition in [BOYZ, BEAST_SNAGGA_BOYZ, NOBZ, MEGANOBZ, WARBOSS, BREAKA_BOYZ, TANKBUSTAS, KOMMANDOS, STORMBOYZ, BIG_MEK, BIG_MEK_MEGA, BEASTBOSS_SQUIGOSAUR, DEFFKOPTAS, MEK_GUNZ, WARBUGGIES, DEFF_DREAD, TRUKK, BATTLEWAGON, GUNWAGON, BOSSBUNKA, BURNA_BOMMER, DAKKAJET, WAZBOM]

static func is_model_scoped(definition: String) -> bool:
	return definition in [BOYZ, BEAST_SNAGGA_BOYZ, NOBZ, MEGANOBZ, BREAKA_BOYZ, TANKBUSTAS, KOMMANDOS, STORMBOYZ, DEFFKOPTAS, MEK_GUNZ, WARBUGGIES]

static func _identity(definition: String) -> String:
	return definition.get_slice(":", 3)

static func _size_supported(definition: String, models: int) -> bool:
	if definition in [BOYZ, BEAST_SNAGGA_BOYZ]: return models in [10, 20]
	if definition == NOBZ: return models in [5, 10]
	if definition == MEGANOBZ: return models in [2, 3, 5, 6]
	if definition in [BREAKA_BOYZ, TANKBUSTAS]: return models == 6
	if definition == KOMMANDOS: return models == 10
	if definition == STORMBOYZ: return models in [5, 10]
	if definition in [WARBOSS, BIG_MEK, BIG_MEK_MEGA, BEASTBOSS_SQUIGOSAUR, DEFF_DREAD, TRUKK, BATTLEWAGON, GUNWAGON, BOSSBUNKA, BURNA_BOMMER, DAKKAJET, WAZBOM]: return models == 1
	if definition == DEFFKOPTAS: return models in [3, 6]
	if definition == MEK_GUNZ: return models in [1, 2, 3]
	if definition == WARBUGGIES: return models in [1, 2]
	return false

static func defaults(definition: String) -> Dictionary:
	if definition == BOYZ: return {BOYZ_NOB_FIELD: "kustom-choppa-kombi-skorcha", BOYZ_RANGED_FIELD: "shoota"}
	if definition == BEAST_SNAGGA_BOYZ: return {BEAST_SNAGGA_SPECIAL_FIELD: "none"}
	if definition == NOBZ: return {NOBZ_LOADOUT_FIELD: "kustom-krumpa-kustom-shoota"}
	if definition == MEGANOBZ: return {MEGANOBZ_LOADOUT_FIELD: "power-klaw-kustom-shoota"}
	if definition == WARBOSS: return {WARBOSS_MELEE_FIELD: "kustom-choppa", WARBOSS_RANGED_FIELD: "kustom-shoota"}
	if definition == BREAKA_BOYZ: return {BREAKA_LOADOUT_FIELD: "smash-hammer"}
	if definition == TANKBUSTAS: return {TANKBUSTA_LOADOUT_FIELD: "rokkit-launcha"}
	if definition == KOMMANDOS: return {KOMMANDO_LOADOUT_FIELD: "choppa"}
	if definition == STORMBOYZ: return {STORMBOYZ_NOB_FIELD: "kustom-choppa"}
	if definition == BIG_MEK: return {BIG_MEK_MELEE_FIELD: "power-klaw", BIG_MEK_RANGED_FIELD: "kustom-mega-blasta"}
	if definition == BIG_MEK_MEGA: return {BIG_MEK_MEGA_GEAR_FIELD: "none", BIG_MEK_MEGA_WEAPON_FIELD: "kustom-shoota"}
	if definition == BEASTBOSS_SQUIGOSAUR: return {BEASTBOSS_SQUIGOSAUR_FIELD: "none"}
	if definition == DEFFKOPTAS: return {DEFFKOPTAS_FIELD: "rokkit-launcha"}
	if definition == MEK_GUNZ: return {MEK_GUNZ_FIELD: "smasha-gun"}
	if definition == WARBUGGIES: return {WARBUGGIES_FIELD: "mek-speshul"}
	if definition == DEFF_DREAD: return {DEFF_DREAD_SLOT1_FIELD: "big-shoota", DEFF_DREAD_SLOT2_FIELD: "skorcha"}
	if definition == TRUKK: return {TRUKK_RANGED_FIELD: "dual-big-shoota", TRUKK_MELEE_FIELD: "none"}
	if definition == BATTLEWAGON: return {BATTLEWAGON_WRECKIN_FIELD: "none", BATTLEWAGON_KLAW_FIELD: "none", BATTLEWAGON_SHOOTAS_FIELD: "0"}
	if definition == GUNWAGON: return {GUNWAGON_CANNON_FIELD: "kannon", GUNWAGON_LOBBA_FIELD: "none", BATTLEWAGON_WRECKIN_FIELD: "none", BATTLEWAGON_KLAW_FIELD: "none", BATTLEWAGON_SHOOTAS_FIELD: "0"}
	if definition == BOSSBUNKA: return {BOSSBUNKA_SHOOTAS_FIELD: "0"}
	if definition == BURNA_BOMMER: return {BURNA_BOMMER_RACK_FIELD: "none"}
	if definition == DAKKAJET: return {DAKKAJET_SUPA_FIELD: "none"}
	if definition == WAZBOM: return {WAZBOM_MAIN_FIELD: "dual-wazbom-mega-kannon", WAZBOM_FIELD_FIELD: "none", WAZBOM_SUPA_FIELD: "none"}
	return {}

static func controls(definition: String) -> Array[Dictionary]:
	if definition == BOYZ:
		return [
			{"field": BOYZ_NOB_FIELD, "label": "Nob Loadout", "choices": [
				{"id": "kustom-choppa-kombi-skorcha", "label": "Kustom Choppa + Kombi-skorcha"},
				{"id": "big-choppa", "label": "Big Choppa"},
				{"id": "power-klaw-kombi-skorcha", "label": "Power Klaw + Kombi-skorcha"},
				{"id": "kustom-choppa-kombi-rokkit", "label": "Kustom Choppa + Kombi-rokkit"},
				{"id": "kustom-choppa-kustom-shoota", "label": "Kustom Choppa + Kustom Shoota"},
				{"id": "power-klaw-kombi-rokkit", "label": "Power Klaw + Kombi-rokkit"},
				{"id": "power-klaw-kustom-shoota", "label": "Power Klaw + Kustom Shoota"}
			]},
			{"field": BOYZ_RANGED_FIELD, "label": "Boy Ranged Weapon", "choices": [
				{"id": "shoota", "label": "Shoota"},
				{"id": "big-shoota", "label": "Big Shoota (1 per 10)"},
				{"id": "rokkit-launcha", "label": "Rokkit Launcha (1 per 10)"},
				{"id": "burna", "label": "Burna (1 per 10)"}
			]}
		]
	if definition == BEAST_SNAGGA_BOYZ:
		return [
			{"field": BEAST_SNAGGA_SPECIAL_FIELD, "label": "Special Weapon", "choices": [
				{"id": "none", "label": "Standard (Slugga + Choppa)"},
				{"id": "thump-gun", "label": "Thump Gun (1 per 10)"}
			]}
		]
	if definition == NOBZ:
		return [
			{"field": NOBZ_LOADOUT_FIELD, "label": "Nob Loadout", "choices": [
				{"id": "kustom-krumpa-kustom-shoota", "label": "Kustom Krumpa + Kustom Shoota"},
				{"id": "kustom-krumpa-kombi-rokkit", "label": "Kustom Krumpa + Kombi-rokkit"},
				{"id": "kustom-krumpa-paired-krumpas", "label": "Kustom Krumpa + Paired Krumpas (+5 pts, 1 per 5)"},
				{"id": "big-skorcha-kustom-choppa", "label": "Big Skorcha + Kustom Choppa (1 per 5)"},
				{"id": "kustom-big-shoota-kustom-choppa", "label": "Kustom Big Shoota + Kustom Choppa (1 per 5)"},
				{"id": "big-choppa", "label": "Big Choppa (1 per 5)"}
			]}
		]
	if definition == MEGANOBZ:
		return [
			{"field": MEGANOBZ_LOADOUT_FIELD, "label": "Meganob Loadout", "choices": [
				{"id": "power-klaw-kustom-shoota", "label": "Power Klaw + Kustom Shoota"},
				{"id": "power-klaw-kombi-weapon", "label": "Power Klaw + Kombi-weapon"},
				{"id": "killsaw-kustom-shoota", "label": "Killsaw + Kustom Shoota (+5 pts)"},
				{"id": "killsaw-kombi-weapon", "label": "Killsaw + Kombi-weapon (+5 pts)"},
				{"id": "twin-killsaws", "label": "Twin Killsaws (+5 pts)"}
			]}
		]
	if definition == WARBOSS:
		return [
			{"field": WARBOSS_MELEE_FIELD, "label": "Melee Weapon", "choices": [
				{"id": "kustom-choppa", "label": "Kustom Choppa"},
				{"id": "power-klaw", "label": "Power Klaw"}
			]},
			{"field": WARBOSS_RANGED_FIELD, "label": "Ranged Weapon", "choices": [
				{"id": "kustom-shoota", "label": "Kustom Shoota"},
				{"id": "kombi-rokkit", "label": "Kombi-rokkit"},
				{"id": "kombi-skorcha", "label": "Kombi-skorcha"}
			]}
		]
	if definition == BREAKA_BOYZ:
		return [
			{"field": BREAKA_LOADOUT_FIELD, "label": "Breaka Boyz Loadout", "choices": [
				{"id": "smash-hammer", "label": "Smash Hammer"},
				{"id": "rokkit-pistol", "label": "Rokkit Pistol (Nob only)"},
				{"id": "knucklebustas", "label": "Knucklebustas (1 Breaka Boy)"},
				{"id": "tankhammer", "label": "Tankhammer (1 Breaka Boy)"}
			]}
		]
	if definition == TANKBUSTAS:
		return [
			{"field": TANKBUSTA_LOADOUT_FIELD, "label": "Tankbustas Loadout", "choices": [
				{"id": "rokkit-launcha", "label": "Rokkit Launcha / Default"},
				{"id": "smash-hammer", "label": "Smash Hammer (Nob only)"},
				{"id": "busta-rokkit-launcha", "label": "Busta Rokkit Launcha (1 Tankbusta)"},
				{"id": "pulsa-rokkit", "label": "Pulsa Rokkit (1 Tankbusta)"}
			]}
		]
	if definition == KOMMANDOS:
		return [
			{"field": KOMMANDO_LOADOUT_FIELD, "label": "Kommandos Loadout", "choices": [
				{"id": "choppa", "label": "Slugga + Choppa"},
				{"id": "big-choppa", "label": "Big Choppa (Nob only)"},
				{"id": "power-klaw", "label": "Power Klaw (Nob only)"},
				{"id": "burna", "label": "Burna (1 Kommando)"},
				{"id": "rokkit-launcha", "label": "Rokkit Launcha (1 Kommando)"},
				{"id": "breacha-ram", "label": "Breacha Ram (1 Kommando)"},
				{"id": "kustom-shoota", "label": "Kustom Shoota (up to 2 Kommandos)"}
			]}
		]
	if definition == STORMBOYZ:
		return [
			{"field": STORMBOYZ_NOB_FIELD, "label": "Nob Melee", "choices": [
				{"id": "kustom-choppa", "label": "Kustom Choppa"},
				{"id": "power-klaw", "label": "Power Klaw"}
			]}
		]
	if definition == BIG_MEK:
		return [
			{"field": BIG_MEK_MELEE_FIELD, "label": "Melee Weapon", "choices": [
				{"id": "power-klaw", "label": "Power Klaw"},
				{"id": "drilla", "label": "Drilla"}
			]},
			{"field": BIG_MEK_RANGED_FIELD, "label": "Ranged Weapon", "choices": [
				{"id": "kustom-mega-blasta", "label": "Kustom Mega-blasta"},
				{"id": "traktor-blasta", "label": "Traktor Blasta"}
			]}
		]
	if definition == BIG_MEK_MEGA:
		return [
			{"field": BIG_MEK_MEGA_GEAR_FIELD, "label": "Optional Wargear", "choices": [
				{"id": "none", "label": "None"},
				{"id": "tellyport-blasta", "label": "Tellyport Blasta"},
				{"id": "kustom-force-field", "label": "Kustom Force Field"}
			]},
			{"field": BIG_MEK_MEGA_WEAPON_FIELD, "label": "Kustom Shoota Replacement", "choices": [
				{"id": "kustom-shoota", "label": "Kustom Shoota"},
				{"id": "killsaw", "label": "Killsaw"},
				{"id": "kombi-weapon", "label": "Kombi-weapon"},
				{"id": "kustom-mega-blasta", "label": "Kustom Mega-blasta"}
			]}
		]
	if definition == BEASTBOSS_SQUIGOSAUR:
		return [
			{"field": BEASTBOSS_SQUIGOSAUR_FIELD, "label": "Optional Ranged", "choices": [
				{"id": "none", "label": "None"},
				{"id": "thump-gun", "label": "Thump Gun"}
			]}
		]
	if definition == DEFFKOPTAS:
		return [
			{"field": DEFFKOPTAS_FIELD, "label": "Ranged Weapon", "choices": [
				{"id": "rokkit-launcha", "label": "Rokkit Launcha"},
				{"id": "kustom-mega-blasta", "label": "Kustom Mega-blasta (1 per 3)"}
			]}
		]
	if definition == MEK_GUNZ:
		return [
			{"field": MEK_GUNZ_FIELD, "label": "Mek Gun", "choices": [
				{"id": "smasha-gun", "label": "Smasha Gun"},
				{"id": "bubblechukka", "label": "Bubblechukka"},
				{"id": "kustom-mega-kannon", "label": "Kustom Mega-kannon"},
				{"id": "traktor-kannon", "label": "Traktor Kannon"}
			]}
		]
	if definition == WARBUGGIES:
		return [
			{"field": WARBUGGIES_FIELD, "label": "Main Weapon", "choices": [
				{"id": "mek-speshul", "label": "Mek Speshul"},
				{"id": "rivet-kannon", "label": "Rivet Kannon"}
			]}
		]
	if definition == DEFF_DREAD:
		return [
			{"field": DEFF_DREAD_SLOT1_FIELD, "label": "Arm Slot 1", "choices": [
				{"id": "big-shoota", "label": "Big Shoota"},
				{"id": "extra-klaw", "label": "Extra Klaw"},
				{"id": "kustom-mega-blasta", "label": "Kustom Mega-blasta"},
				{"id": "rokkit-launcha", "label": "Rokkit Launcha"}
			]},
			{"field": DEFF_DREAD_SLOT2_FIELD, "label": "Arm Slot 2", "choices": [
				{"id": "skorcha", "label": "Skorcha"},
				{"id": "extra-klaw", "label": "Extra Klaw"},
				{"id": "big-shoota", "label": "Big Shoota"},
				{"id": "kustom-mega-blasta", "label": "Kustom Mega-blasta"},
				{"id": "rokkit-launcha", "label": "Rokkit Launcha"}
			]}
		]
	if definition == TRUKK:
		return [
			{"field": TRUKK_RANGED_FIELD, "label": "Ranged", "choices": [{"id": "dual-big-shoota", "label": "Dual Big Shoota"}, {"id": "rokkit-launcha", "label": "Rokkit Launcha"}]},
			{"field": TRUKK_MELEE_FIELD, "label": "Optional Melee", "choices": [{"id": "none", "label": "None"}, {"id": "buzzsaw", "label": "Buzzsaw"}, {"id": "grabbin-klaw", "label": "Grabbin' Klaw"}]}
		]
	if definition == BATTLEWAGON:
		return [
			{"field": BATTLEWAGON_WRECKIN_FIELD, "label": "Wreckin' Ball", "choices": [{"id": "none", "label": "None"}, {"id": "wreckin-ball", "label": "Wreckin' Ball"}]},
			{"field": BATTLEWAGON_KLAW_FIELD, "label": "Grabbin' Klaw", "choices": [{"id": "none", "label": "None"}, {"id": "grabbin-klaw", "label": "Grabbin' Klaw"}]},
			{"field": BATTLEWAGON_SHOOTAS_FIELD, "label": "Big Shootas", "choices": [{"id": "0", "label": "0"}, {"id": "1", "label": "1"}, {"id": "2", "label": "2"}, {"id": "3", "label": "3"}, {"id": "4", "label": "4"}]}
		]
	if definition == GUNWAGON:
		return [
			{"field": GUNWAGON_CANNON_FIELD, "label": "Main Cannon", "choices": [{"id": "kannon", "label": "Kannon"}, {"id": "killkannon", "label": "Killkannon"}, {"id": "zzap-gun", "label": "Zzap Gun (+10 pts)"}]},
			{"field": GUNWAGON_LOBBA_FIELD, "label": "Lobba", "choices": [{"id": "none", "label": "None"}, {"id": "lobba", "label": "Lobba"}]},
			{"field": BATTLEWAGON_WRECKIN_FIELD, "label": "Wreckin' Ball", "choices": [{"id": "none", "label": "None"}, {"id": "wreckin-ball", "label": "Wreckin' Ball"}]},
			{"field": BATTLEWAGON_KLAW_FIELD, "label": "Grabbin' Klaw", "choices": [{"id": "none", "label": "None"}, {"id": "grabbin-klaw", "label": "Grabbin' Klaw"}]},
			{"field": BATTLEWAGON_SHOOTAS_FIELD, "label": "Big Shootas", "choices": [{"id": "0", "label": "0"}, {"id": "1", "label": "1"}, {"id": "2", "label": "2"}, {"id": "3", "label": "3"}, {"id": "4", "label": "4"}]}
		]
	if definition == BOSSBUNKA:
		return [{"field": BOSSBUNKA_SHOOTAS_FIELD, "label": "Big Shootas", "choices": [{"id": "0", "label": "0"}, {"id": "1", "label": "1"}, {"id": "2", "label": "2"}, {"id": "3", "label": "3"}]}]
	if definition == BURNA_BOMMER:
		return [{"field": BURNA_BOMMER_RACK_FIELD, "label": "Missile Rack", "choices": [{"id": "none", "label": "None"}, {"id": "skorcha-missile-rack", "label": "Skorcha Missile Rack"}]}]
	if definition == DAKKAJET:
		return [{"field": DAKKAJET_SUPA_FIELD, "label": "Extra Supa-shoota", "choices": [{"id": "none", "label": "None"}, {"id": "dual-supa-shoota", "label": "Dual Supa-shoota"}]}]
	if definition == WAZBOM:
		return [
			{"field": WAZBOM_MAIN_FIELD, "label": "Main Weapon", "choices": [{"id": "dual-wazbom-mega-kannon", "label": "Dual Wazbom Mega-kannon"}, {"id": "dual-tellyport-mega-blasta", "label": "Dual Tellyport Mega-blasta"}]},
			{"field": WAZBOM_FIELD_FIELD, "label": "Force Field", "choices": [{"id": "none", "label": "None"}, {"id": "blastajet-force-field", "label": "Blastajet Force Field"}]},
			{"field": WAZBOM_SUPA_FIELD, "label": "Extra Supa-shoota", "choices": [{"id": "none", "label": "None"}, {"id": "dual-supa-shoota", "label": "Dual Supa-shoota"}]}
		]
	return []

static func wargear_cost(definition: String, models_list: Array) -> int:
	var extra := 0
	if definition == NOBZ:
		for m: Variant in models_list:
			if m is Dictionary and str(m.get(NOBZ_LOADOUT_FIELD, "")) == "kustom-krumpa-paired-krumpas":
				extra += 5
	elif definition == MEGANOBZ:
		for m: Variant in models_list:
			if m is Dictionary and str(m.get(MEGANOBZ_LOADOUT_FIELD, "")) in ["killsaw-kustom-shoota", "killsaw-kombi-weapon", "twin-killsaws"]:
				extra += 5
	elif definition == GUNWAGON:
		for m: Variant in models_list:
			if m is Dictionary and str(m.get(GUNWAGON_CANNON_FIELD, "")) == "zzap-gun":
				extra += 10
	return extra

static func validate_entry(definition: String, models: int, selection: Variant) -> String:
	if not supports(definition): return "Unsupported Orks saved equipment profile."
	if not _size_supported(definition, models): return "Unsupported model count for " + _identity(definition)
	if not is_model_scoped(definition):
		if not selection is Dictionary: return "Copy equipment selection must be a dictionary."
		var ctrl_map := {}
		for c: Dictionary in controls(definition):
			ctrl_map[c.field] = c.choices.map(func(ch: Dictionary) -> String: return str(ch.id))
		for f: String in ctrl_map:
			var val := str(selection.get(f, defaults(definition)[f]))
			if val not in ctrl_map[f]: return "Invalid Orks equipment choice %s for %s." % [val, f]
		return ""
	if not selection is Array or selection.size() != models:
		return "Saved model equipment must match the %d selected models." % models
	if definition == BOYZ:
		var nob_count := models / 10
		var special_count := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Boyz model equipment row."
			var is_nob := i < nob_count
			var nob_val := str(row.get(BOYZ_NOB_FIELD, "kustom-choppa-kombi-skorcha"))
			var boy_val := str(row.get(BOYZ_RANGED_FIELD, "shoota"))
			if is_nob and nob_val not in ["kustom-choppa-kombi-skorcha", "big-choppa", "power-klaw-kombi-skorcha", "kustom-choppa-kombi-rokkit", "kustom-choppa-kustom-shoota", "power-klaw-kombi-rokkit", "power-klaw-kustom-shoota"]:
				return "Invalid Boyz Nob loadout: " + nob_val
			if not is_nob:
				if boy_val not in ["shoota", "big-shoota", "rokkit-launcha", "burna"]:
					return "Invalid Boyz ranged weapon: " + boy_val
				if boy_val != "shoota":
					special_count += 1
		if special_count > models / 10:
			return "Boyz may only replace 1 Shoota per 10 models."
		return ""
	if definition == BEAST_SNAGGA_BOYZ:
		var nob_count := models / 10
		var thump_count := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Beast Snagga Boyz model equipment row."
			var spec_val := str(row.get(BEAST_SNAGGA_SPECIAL_FIELD, "none"))
			if spec_val not in ["none", "thump-gun"]: return "Invalid Beast Snagga Boyz special weapon: " + spec_val
			if i < nob_count and spec_val != "none": return "Beast Snagga Nob cannot take a Thump Gun."
			if spec_val == "thump-gun": thump_count += 1
		if thump_count > models / 10:
			return "Beast Snagga Boyz may take at most 1 Thump Gun per 10 models."
		return ""
	if definition == NOBZ:
		var cap := models / 5
		var counts := {"big-skorcha-kustom-choppa": 0, "kustom-big-shoota-kustom-choppa": 0, "big-choppa": 0, "kustom-krumpa-paired-krumpas": 0}
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Nobz model equipment row."
			var val := str(row.get(NOBZ_LOADOUT_FIELD, "kustom-krumpa-kustom-shoota"))
			if val not in ["kustom-krumpa-kustom-shoota", "kustom-krumpa-kombi-rokkit", "kustom-krumpa-paired-krumpas", "big-skorcha-kustom-choppa", "kustom-big-shoota-kustom-choppa", "big-choppa"]:
				return "Invalid Nobz loadout: " + val
			if counts.has(val):
				counts[val] += 1
				if counts[val] > cap:
					return "Nobz option %s exceeds 1 per 5 models." % val
		return ""
	if definition == MEGANOBZ:
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Meganobz model equipment row."
			var val := str(row.get(MEGANOBZ_LOADOUT_FIELD, "power-klaw-kustom-shoota"))
			if val not in ["power-klaw-kustom-shoota", "power-klaw-kombi-weapon", "killsaw-kustom-shoota", "killsaw-kombi-weapon", "twin-killsaws"]:
				return "Invalid Meganobz loadout: " + val
		return ""
	if definition == BREAKA_BOYZ:
		var kb := 0
		var th := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Breaka Boyz row."
			var val := str(row.get(BREAKA_LOADOUT_FIELD, "smash-hammer"))
			if val not in ["smash-hammer", "rokkit-pistol", "knucklebustas", "tankhammer"]: return "Invalid Breaka Boyz option: " + val
			if i == 0 and val in ["knucklebustas", "tankhammer"]: return "Nob cannot take Knucklebustas or Tankhammer."
			if i > 0 and val == "rokkit-pistol": return "Only the Nob can replace Smash Hammer with Rokkit Pistol."
			if val == "knucklebustas": kb += 1
			if val == "tankhammer": th += 1
		if kb > 1 or th > 1: return "Breaka Boyz allow at most 1 Knucklebustas and 1 Tankhammer."
		return ""
	if definition == TANKBUSTAS:
		var special := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Tankbustas row."
			var val := str(row.get(TANKBUSTA_LOADOUT_FIELD, "rokkit-launcha"))
			if val not in ["rokkit-launcha", "smash-hammer", "busta-rokkit-launcha", "pulsa-rokkit"]: return "Invalid Tankbustas option: " + val
			if i == 0 and val in ["busta-rokkit-launcha", "pulsa-rokkit"]: return "Nob cannot take Busta/Pulsa Rokkit."
			if i > 0 and val == "smash-hammer": return "Only the Nob can take Smash Hammer."
			if val in ["busta-rokkit-launcha", "pulsa-rokkit"]: special += 1
		if special > 1: return "Tankbustas allow at most 1 Busta Rokkit Launcha or Pulsa Rokkit."
		return ""
	if definition == KOMMANDOS:
		var burna := 0
		var rokkit := 0
		var ram := 0
		var kustom := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Kommandos row."
			var val := str(row.get(KOMMANDO_LOADOUT_FIELD, "choppa"))
			if val not in ["choppa", "big-choppa", "power-klaw", "burna", "rokkit-launcha", "breacha-ram", "kustom-shoota"]: return "Invalid Kommandos option: " + val
			if i == 0 and val in ["burna", "rokkit-launcha", "breacha-ram", "kustom-shoota"]: return "Nob cannot take Kommando specialist weapons."
			if i > 0 and val in ["big-choppa", "power-klaw"]: return "Only the Nob can take Big Choppa or Power Klaw."
			if val == "burna": burna += 1
			elif val == "rokkit-launcha": rokkit += 1
			elif val == "breacha-ram": ram += 1
			elif val == "kustom-shoota": kustom += 1
		if burna > 1 or rokkit > 1 or ram > 1 or kustom > 2:
			return "Kommandos weapon limits exceeded."
		return ""
	if definition == STORMBOYZ:
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Stormboyz row."
			var val := str(row.get(STORMBOYZ_NOB_FIELD, "kustom-choppa"))
			if val not in ["kustom-choppa", "power-klaw"]: return "Invalid Stormboyz option: " + val
			if i > 0 and val != "kustom-choppa": return "Only the Stormboyz Nob can take Power Klaw."
		return ""
	if definition == DEFFKOPTAS:
		var kmb := 0
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Deffkoptas row."
			var val := str(row.get(DEFFKOPTAS_FIELD, "rokkit-launcha"))
			if val not in ["rokkit-launcha", "kustom-mega-blasta"]: return "Invalid Deffkoptas option: " + val
			if val == "kustom-mega-blasta": kmb += 1
		if kmb > models / 3: return "Deffkoptas allow at most 1 Kustom Mega-blasta per 3 models."
		return ""
	if definition == MEK_GUNZ:
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Mek Gunz row."
			var val := str(row.get(MEK_GUNZ_FIELD, "smasha-gun"))
			if val not in ["smasha-gun", "bubblechukka", "kustom-mega-kannon", "traktor-kannon"]: return "Invalid Mek Gunz option: " + val
		return ""
	if definition == WARBUGGIES:
		for i in range(models):
			var row: Variant = selection[i]
			if not row is Dictionary: return "Invalid Warbuggies row."
			var val := str(row.get(WARBUGGIES_FIELD, "mek-speshul"))
			if val not in ["mek-speshul", "rivet-kannon"]: return "Invalid Warbuggies option: " + val
		return ""
	return "Unhandled Orks saved equipment definition."

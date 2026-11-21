extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const OrkProfiles = preload("res://scripts/edition_11/current_reference_orks_profiles.gd")
const OrkEquipment = preload("res://scripts/edition_11/ork_saved_equipment.gd")
const OrksBatch1 = preload("res://scripts/edition_11/orks_batch1_abilities.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# 1. Catalog admission for all 11 Batch 1 datasheets
	var cat := Catalog.new()
	root.add_child(cat)
	check(cat.select_edition("11e").is_empty(), "11e catalog loads cleanly with Orks Batch 1")
	var admitted_orks := {}
	for u: Dictionary in cat.catalog.units:
		if u.faction == "Orks":
			admitted_orks[u.source_id] = u
	var expected := [
		"boyz", "beast-snagga-boyz", "gretchin", "nobz", "meganobz",
		"warboss", "warboss-in-mega-armour", "bigboss", "bannernob", "runtherd", "painboy"
	]
	check(admitted_orks.size() >= 11, "Expected at least 11 Batch 1 Orks datasheets admitted, got %d" % admitted_orks.size())
	for slug: String in expected:
		check(admitted_orks.has(slug), "Batch 1 datasheet admitted: " + slug)

	# 2. Pricing, copy-tiers & wargear surcharges
	check(OrkProfiles.profile("boyz").points_by_models == {10: 85, 20: 170}, "Boyz 10/20 pricing matches 85/170")
	check(OrkProfiles.profile("boyz").fourth_plus_points_by_models == {10: 95, 20: 180}, "Boyz 4th+ pricing matches 95/180")
	check(OrkProfiles.profile("meganobz").wargear_costs.get("killsaw", 0) == 5, "Meganobz Killsaw surcharge is +5 pts")
	check(OrkProfiles.profile("nobz").wargear_costs.get("paired-krumpas", 0) == 5, "Nobz Paired Krumpas surcharge is +5 pts")

	# 3. Saved equipment validation & surcharge calculation
	var boyz_models := []
	for i in range(10):
		boyz_models.append({"ork_boyz_nob_loadout": "power-klaw-kombi-rokkit" if i == 0 else "kustom-choppa-kombi-skorcha", "ork_boyz_ranged": "rokkit-launcha" if i == 1 else "shoota"})
	check(OrkEquipment.validate_entry(OrkEquipment.BOYZ, 10, boyz_models).is_empty(), "Boyz 10-model valid equipment passes")
	boyz_models[2].ork_boyz_ranged = "burna"
	check(not OrkEquipment.validate_entry(OrkEquipment.BOYZ, 10, boyz_models).is_empty(), "Boyz rejects 2 special weapons in 10-model squad")

	var nobz_models := [{"ork_nobz_loadout": "kustom-krumpa-paired-krumpas"}, {"ork_nobz_loadout": "big-choppa"}, {"ork_nobz_loadout": "kustom-krumpa-kustom-shoota"}, {"ork_nobz_loadout": "kustom-krumpa-kustom-shoota"}, {"ork_nobz_loadout": "kustom-krumpa-kombi-rokkit"}]
	check(OrkEquipment.validate_entry(OrkEquipment.NOBZ, 5, nobz_models).is_empty(), "Nobz 5-model valid equipment passes")
	check(OrkEquipment.wargear_cost(OrkEquipment.NOBZ, nobz_models) == 5, "Nobz Paired Krumpas adds +5 pts")

	var meganobz_models := [{"ork_meganobz_loadout": "twin-killsaws"}, {"ork_meganobz_loadout": "killsaw-kombi-weapon"}, {"ork_meganobz_loadout": "power-klaw-kustom-shoota"}]
	check(OrkEquipment.validate_entry(OrkEquipment.MEGANOBZ, 3, meganobz_models).is_empty(), "Meganobz 3-model valid equipment passes")
	check(OrkEquipment.wargear_cost(OrkEquipment.MEGANOBZ, meganobz_models) == 10, "Meganobz 2 Killsaw/Twin Killsaws models add +10 pts")

	check(OrkEquipment.validate_entry(OrkEquipment.WARBOSS, 1, {"ork_warboss_melee": "power-klaw", "ork_warboss_ranged": "kombi-skorcha"}).is_empty(), "Warboss copy equipment passes")

	# 4. Leader & Support links
	check("40kdc:11e:orks:boyz" in LeaderCatalog.ATTACHMENTS["40kdc:11e:orks:warboss"], "Warboss leads Boyz")
	check("40kdc:11e:orks:meganobz" in LeaderCatalog.ATTACHMENTS["40kdc:11e:orks:warboss-in-mega-armour"], "Warboss in Mega Armour leads Meganobz")
	check("40kdc:11e:orks:gretchin" in LeaderCatalog.ATTACHMENTS["40kdc:11e:orks:runtherd"], "Runtherd leads Gretchin")
	check("boyz" in Supports.BODYGUARDS["painboy"] and "nobz" in Supports.BODYGUARDS["bannernob"], "Painboy and Bannernob Support links present")

	# 5. Batch 1 abilities
	var state := {
		"turn": 1, "battle_round": 1, "phase": "shooting", "cp": {0: 2, 1: 2},
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"squads": {
			1: {"owner": 0, "charged": true, "battle_shocked": false, "attached": false},
			2: {"owner": 0, "charged": false, "battle_shocked": true, "attached": false},
			3: {"owner": 1, "charged": false, "battle_shocked": false, "attached": false}
		},
		"units": {
			10: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:warboss", "wounds": 6, "max_wounds": 6, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			11: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:meganobz", "wounds": 2, "max_wounds": 3, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			12: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:painboy", "wounds": 4, "max_wounds": 4, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			13: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:bannernob", "wounds": 4, "max_wounds": 4, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			20: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:runtherd", "wounds": 3, "max_wounds": 3, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			21: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:gretchin", "wounds": 1, "max_wounds": 1, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			22: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:gretchin", "wounds": 1, "max_wounds": 1, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			23: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:gretchin", "wounds": 1, "max_wounds": 1, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			24: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:gretchin", "wounds": 1, "max_wounds": 1, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			30: {"owner": 1, "squad": 3, "definition_id": "40kdc:11e:necrons:monolith", "wounds": 22, "max_wounds": 22, "on_battlefield": true, "keywords": ["NECRONS", "VEHICLE", "TITANIC"]}
		}
	}
	check(OrksBatch1.activate_ammo_runt(state, 1, 10).error.is_empty(), "Warboss Boss' Ammo Runt activates once per battle")
	check(OrksBatch1.ranged_hit_bonus(state, 1, 10) == 1 and OrksBatch1.ranged_hit_bonus(state, 1, 11) == 0, "Boss' Ammo Runt applies +1 to Warboss model only")
	check(OrksBatch1.arrogant_invulnerability_ap(state, 1, -2) == -1, "Arrogant Invulnerability worsens AP -2 to -1")
	check(OrksBatch1.might_is_right_active(state, 1, 10, true), "Might Is Right active for Warboss after charge")
	check(Doctrines.charge_bonus(state, 1) == 1, "Waaagh! Banner grants +1 to Charge rolls")
	check(OrksBatch1.downtrodden_transport_slots(11) == 6, "Downtrodden: 11 Gretchin take 6 transport slots")
	check(OrksBatch1.krushin_impetus_mortal_wounds(3, func() -> int: return 4) == 3, "Krushin' Impetus deals 1 MW per 3+")

	var heal_res := OrksBatch1.crude_surgery_heal(state, 1, false)
	check(heal_res.error.is_empty() and heal_res.healed == 1 and state.units[11].wounds == 3, "Painboy Crude Surgery heals wounded model")

	var learn_res := OrksBatch1.thatll_learn_ya(state, 2, func() -> int: return 4)
	check(learn_res.error.is_empty() and learn_res.slain == 2 and not state.squads[2].battle_shocked, "Runtherd That'll Learn Ya slays D3 Gretchin and clears Battle-shock")

	var mot_res := OrksBatch1.use_intimidating_motivation(state, 0, 1, 2)
	check(mot_res.error.is_empty() and OrksWaaagh.is_riled_up(state, 2), "Intimidating Motivation clears Battle-shock and riles up target ORKS unit")

	quit(1 if failures > 0 else 0)

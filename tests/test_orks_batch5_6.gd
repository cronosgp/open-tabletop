extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const OrkProfiles = preload("res://scripts/edition_11/current_reference_orks_profiles.gd")
const OrkEquipment = preload("res://scripts/edition_11/ork_saved_equipment.gd")
const OrksBatch56 = preload("res://scripts/edition_11/orks_batch5_6_abilities.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var cat := Catalog.new()
	root.add_child(cat)
	check(cat.select_edition("11e").is_empty(), "11e catalog loads cleanly with all 54 Orks datasheets")
	var admitted := {}
	for u: Dictionary in cat.catalog.units:
		if u.faction == "Orks": admitted[u.source_id] = u
	check(admitted.size() == 54, "Expected all 54/54 Orks datasheets admitted, got %d" % admitted.size())
	for slug: String in OrkProfiles.SOURCE_SHEETS:
		check(admitted.has(slug), "Orks datasheet admitted: " + slug)

	# Saved equipment & Gunwagon Zzap Gun (+10 pts) surcharge
	check(OrkEquipment.validate_entry(OrkEquipment.TRUKK, 1, {"ork_trukk_ranged": "rokkit-launcha", "ork_trukk_melee": "grabbin-klaw"}).is_empty(), "Trukk equipment passes")
	check(OrkEquipment.validate_entry(OrkEquipment.GUNWAGON, 1, {"ork_gunwagon_cannon": "zzap-gun", "ork_gunwagon_lobba": "lobba", "ork_battlewagon_wreckin_ball": "wreckin-ball", "ork_battlewagon_grabbin_klaw": "none", "ork_battlewagon_big_shootas": "2"}).is_empty(), "Gunwagon equipment passes")
	check(OrkEquipment.wargear_cost(OrkEquipment.GUNWAGON, [{"ork_gunwagon_cannon": "zzap-gun"}]) == 10, "Gunwagon Zzap Gun adds +10 pts")
	check(OrkEquipment.validate_entry(OrkEquipment.WAZBOM, 1, {"ork_wazbom_main": "dual-tellyport-mega-blasta", "ork_wazbom_force_field": "blastajet-force-field", "ork_wazbom_supa_shoota": "dual-supa-shoota"}).is_empty(), "Wazbom Blastajet equipment passes")

	var state := {
		"turn": 1, "battle_round": 1, "phase": "shooting",
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"squads": {
			1: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false},
			2: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false},
			3: {"owner": 1, "charged": false, "battle_shocked": false, "attached": false}
		},
		"units": {
			10: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:stompa", "wounds": 30, "max_wounds": 30, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "TITANIC"]},
			11: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:hunta-rig", "wounds": 16, "max_wounds": 16, "on_battlefield": true, "keywords": ["ORKS", "MONSTER"]},
			12: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:battlewagon", "wounds": 16, "max_wounds": 16, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE"]},
			20: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:dakkajet", "wounds": 12, "max_wounds": 12, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "AIRCRAFT", "FLY"]},
			21: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:wazbom-blastajet", "wounds": 12, "max_wounds": 12, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "AIRCRAFT", "FLY"]},
			22: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:burna-bommer", "wounds": 12, "max_wounds": 12, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "AIRCRAFT", "FLY"]},
			30: {"owner": 1, "squad": 3, "definition_id": "40kdc:11e:necrons:monolith", "wounds": 22, "max_wounds": 22, "on_battlefield": true, "keywords": ["NECRONS", "VEHICLE", "TITANIC"]}
		}
	}
	check(OrksWaaagh.is_riled_up(state, 1), "Stompa Waaagh! Effigy keeps unit riled up")
	OrksBatch56.idol_of_belligerence_disembark(state, 1, 2)
	check(OrksWaaagh.is_riled_up(state, 2), "Stompa Idol of Belligerence riles up disembarked unit")
	check(OrksBatch56.mobile_fortress_damage_reduction(state, 1, false) == 1, "Battlewagon Mobile Fortress reduces ranged damage by 1")
	check(OrksBatch56.fully_loaded_butchery_bonus(state, 1, "Butcha Boyz", 12) == 22, "Hunta Rig Fully Loaded Butchery caps at +22 A")
	check(OrksBatch56.strafing_run_hit_bonus(state, 2, 3, false) == 1, "Dakkajet Strafing Run grants +1 Hit vs non-FLY")
	check(OrksBatch56.go_fer_da_weak_spot_wound_bonus(state, 2, 3, false) == 1, "Wazbom Go fer da Weak Spot grants +1 Wound vs MONSTER/VEHICLE")
	check(OrksBatch56.boom_bomb_mortal_wounds(6, 4) == 5, "Blitza-bommer Boom Bomb on 6 deals D3+3 MW")
	var bb := OrksBatch56.burna_bomb(state, 2, 3, 2, 6)
	check(bb.error.is_empty() and bb.hit and bb.mortal_wounds == 3 and OrksBatch56.is_burna_bombed(state, 3), "Burna-bommer Burna Bomb deals D3 MW and marks target")

	quit(1 if failures > 0 else 0)

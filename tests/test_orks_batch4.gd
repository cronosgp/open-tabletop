extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const OrkEquipment = preload("res://scripts/edition_11/ork_saved_equipment.gd")
const OrksBatch4 = preload("res://scripts/edition_11/orks_batch4_abilities.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")
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
	var cat := Catalog.new()
	root.add_child(cat)
	check(cat.select_edition("11e").is_empty(), "11e catalog loads cleanly with Orks Batch 4")
	var admitted := {}
	for u: Dictionary in cat.catalog.units:
		if u.faction == "Orks": admitted[u.source_id] = u
	check(admitted.size() >= 41, "Expected at least 41 Orks datasheets admitted (Batches 1-4), got %d" % admitted.size())
	for slug: String in ["warbikers", "wartrakks", "deffkoptas", "deffkilla-wartrike", "warbuggies", "rukkatrukk-squigbuggies", "mek-gunz", "big-mek-dakkarig", "deff-dread", "killa-kans"]:
		check(admitted.has(slug), "Batch 4 datasheet admitted: " + slug)

	check(OrkEquipment.validate_entry(OrkEquipment.DEFFKOPTAS, 3, [{"ork_deffkoptas_ranged": "kustom-mega-blasta"}, {"ork_deffkoptas_ranged": "rokkit-launcha"}, {"ork_deffkoptas_ranged": "rokkit-launcha"}]).is_empty(), "Deffkoptas 1-per-3 KMB passes")
	check(not OrkEquipment.validate_entry(OrkEquipment.DEFFKOPTAS, 3, [{"ork_deffkoptas_ranged": "kustom-mega-blasta"}, {"ork_deffkoptas_ranged": "kustom-mega-blasta"}, {"ork_deffkoptas_ranged": "rokkit-launcha"}]).is_empty(), "Deffkoptas rejects 2 KMB in 3-model unit")
	check(OrkEquipment.validate_entry(OrkEquipment.MEK_GUNZ, 2, [{"ork_mek_gunz_weapon": "bubblechukka"}, {"ork_mek_gunz_weapon": "traktor-kannon"}]).is_empty(), "Mek Gunz per-model weapon choices pass")
	check(OrkEquipment.validate_entry(OrkEquipment.WARBUGGIES, 2, [{"ork_warbuggies_weapon": "rivet-kannon"}, {"ork_warbuggies_weapon": "mek-speshul"}]).is_empty(), "Warbuggies per-model weapon choices pass")
	check(OrkEquipment.validate_entry(OrkEquipment.DEFF_DREAD, 1, {"ork_deff_dread_slot1": "extra-klaw", "ork_deff_dread_slot2": "rokkit-launcha"}).is_empty(), "Deff Dread slot choices pass")

	var state := {
		"turn": 1, "battle_round": 1, "phase": "movement",
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"squads": {
			1: {"owner": 0, "charged": true, "battle_shocked": true, "attached": false},
			2: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false},
			3: {"owner": 1, "charged": false, "battle_shocked": false, "attached": false}
		},
		"units": {
			10: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:warbikers", "wounds": 3, "max_wounds": 3, "on_battlefield": true, "keywords": ["ORKS", "MOUNTED", "SPEED FREEKS"]},
			11: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:deffkilla-wartrike", "wounds": 9, "max_wounds": 9, "on_battlefield": true, "keywords": ["ORKS", "MOUNTED", "CHARACTER", "SPEED FREEKS"]},
			20: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:deff-dread", "wounds": 8, "max_wounds": 8, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "WALKER"]},
			21: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:killa-kans", "wounds": 5, "max_wounds": 5, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "WALKER"]},
			22: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:big-mek-dakkarig", "wounds": 10, "max_wounds": 10, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "CHARACTER"]},
			30: {"owner": 1, "squad": 3, "definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "wounds": 2, "max_wounds": 2, "on_battlefield": true, "keywords": ["ADEPTUS ASTARTES", "INFANTRY"], "stats": {"toughness": 4}}
		}
	}
	check(OrksBatch4.high_speed_carnage_active(state, 1, true), "Warbikers High-speed Carnage active after charge")
	check(Doctrines.advance_bonus(state, 1) == 1, "Deffkilla Wartrike Fuel-mixa Grot grants +1 Advance")
	var gb := OrksBatch4.get_back_in_da_race(state, 0, 1, 1)
	check(gb.error.is_empty() and not state.squads[1].battle_shocked and OrksWaaagh.is_riled_up(state, 1), "Get Back in da Race! clears Battle-shock and riles up Speed Freeks")
	OrksBatch4.mark_busted(state, 3)
	check(OrksBatch4.is_busted_for(state, 1, 3), "Wartrakks Bust 'Em grants Lethal Hits to Speed Freeks")
	OrksBatch4.mark_covered_in_squigs(state, 3)
	check(OrksBatch4.covered_in_squigs_penalty(state, 3) == -1, "Squig Barrage applies -1 Hit to covered enemy")
	check(OrksBatch4.dread_ard_damage_reduction(state, 2) == 1, "Deff Dread Dread 'Ard reduces damage by 1")
	check(OrksBatch4.spiteful_power_trip_hit_bonus(state, 2, 3) == 1, "Killa Kans Spiteful Power Trip grants +1 Hit vs T<7")
	check(OrksBatch4.blitz_dem_gitz_bonus(state, 2, 3, "Blitzkannon", false) == 6, "Big Mek Dakkarig Blitzkannon gains +6 A vs non-MONSTER/VEHICLE")

	quit(1 if failures > 0 else 0)

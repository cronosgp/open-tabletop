extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const OrkEquipment = preload("res://scripts/edition_11/ork_saved_equipment.gd")
const OrksBatch2 = preload("res://scripts/edition_11/orks_batch2_abilities.gd")
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
	check(cat.select_edition("11e").is_empty(), "11e catalog loads cleanly with Orks Batch 2")
	var admitted := {}
	for u: Dictionary in cat.catalog.units:
		if u.faction == "Orks": admitted[u.source_id] = u
	check(admitted.size() >= 22, "Expected at least 22 Orks datasheets admitted (Batch 1 + Batch 2), got %d" % admitted.size())
	for slug: String in ["breaka-boyz", "tankbustas", "flash-gitz", "kommandos", "stormboyz", "big-mek", "big-mek-in-mega-armour", "big-mek-with-shokk-attack-gun", "mek", "weirdboy", "beastboss"]:
		check(admitted.has(slug), "Batch 2 datasheet admitted: " + slug)

	# Saved equipment checks
	var breaka := [{"ork_breaka_loadout": "rokkit-pistol"}, {"ork_breaka_loadout": "knucklebustas"}, {"ork_breaka_loadout": "tankhammer"}, {"ork_breaka_loadout": "smash-hammer"}, {"ork_breaka_loadout": "smash-hammer"}, {"ork_breaka_loadout": "smash-hammer"}]
	check(OrkEquipment.validate_entry(OrkEquipment.BREAKA_BOYZ, 6, breaka).is_empty(), "Breaka Boyz valid 6-model equipment passes")
	breaka[3].ork_breaka_loadout = "knucklebustas"
	check(not OrkEquipment.validate_entry(OrkEquipment.BREAKA_BOYZ, 6, breaka).is_empty(), "Breaka Boyz rejects duplicate Knucklebustas")

	var kommandos := [{"ork_kommando_loadout": "power-klaw"}, {"ork_kommando_loadout": "burna"}, {"ork_kommando_loadout": "rokkit-launcha"}, {"ork_kommando_loadout": "breacha-ram"}, {"ork_kommando_loadout": "kustom-shoota"}, {"ork_kommando_loadout": "kustom-shoota"}, {"ork_kommando_loadout": "choppa"}, {"ork_kommando_loadout": "choppa"}, {"ork_kommando_loadout": "choppa"}, {"ork_kommando_loadout": "choppa"}]
	check(OrkEquipment.validate_entry(OrkEquipment.KOMMANDOS, 10, kommandos).is_empty(), "Kommandos valid 10-model equipment passes")
	check(OrkEquipment.validate_entry(OrkEquipment.BIG_MEK, 1, {"ork_big_mek_melee": "drilla", "ork_big_mek_ranged": "traktor-blasta"}).is_empty(), "Big Mek equipment passes")
	check(OrkEquipment.validate_entry(OrkEquipment.BIG_MEK_MEGA, 1, {"ork_big_mek_mega_gear": "kustom-force-field", "ork_big_mek_mega_weapon": "killsaw"}).is_empty(), "Big Mek in Mega Armour equipment passes")

	# Abilities checks
	var state := {
		"turn": 1, "battle_round": 1, "phase": "shooting",
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"objectives": [{"position": Vector2(0, 0), "radius": 3.0}],
		"squads": {
			1: {"owner": 0, "charged": true, "battle_shocked": false, "attached": false},
			2: {"owner": 0, "charged": false, "battle_shocked": true, "attached": false},
			3: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false}
		},
		"units": {
			10: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:breaka-boyz", "position": Vector2(0, 0), "radius": 0.63, "wounds": 2, "max_wounds": 2, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			11: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:flash-gitz", "position": Vector2(1, 0), "radius": 0.787, "wounds": 2, "max_wounds": 2, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY"]},
			12: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:big-mek-in-mega-armour", "position": Vector2(2, 0), "radius": 0.787, "wounds": 2, "max_wounds": 5, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			20: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:beastboss", "position": Vector2(5, 0), "radius": 0.787, "wounds": 6, "max_wounds": 6, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER", "BEAST SNAGGA"]},
			30: {"owner": 0, "squad": 3, "definition_id": "40kdc:11e:orks:trukk", "position": Vector2(6, 0), "radius": 1.18, "wounds": 5, "max_wounds": 10, "on_battlefield": true, "keywords": ["ORKS", "VEHICLE", "TRANSPORT"]},
			31: {"owner": 0, "squad": 3, "definition_id": "40kdc:11e:orks:mek", "position": Vector2(7, 0), "radius": 0.63, "wounds": 4, "max_wounds": 4, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]}
		}
	}
	check(Doctrines.charge_bonus(state, 1) == 1, "Breaka Boyz Trophy Hunters grants +1 Charge")
	var bomb := OrksBatch2.use_bomb_squig(state, 1, func() -> int: return 4)
	check(bomb.error.is_empty() and bomb.hit and bomb.mortal_wounds == 2, "Bomb Squig deals D3 MW on 3+")
	check(not OrksBatch2.use_bomb_squig(state, 1, func() -> int: return 4).error.is_empty(), "Bomb Squig capped at 1 per turn")
	check(OrksBatch2.finderz_keeperz_ap_bonus(state, 1, 2, false) == 1, "Flash Gitz Finderz Keeperz grants +1 AP near objective")
	var fix := OrksBatch2.fix_dat_armour_up(state, 1)
	check(fix.error.is_empty() and fix.healed == 3 and state.units[12].wounds == 5, "Big Mek in Mega Armour heals 3 wounds once per battle")
	var kh := OrksBatch2.keep_huntin(state, 0, 2, 2)
	check(kh.error.is_empty() and not state.squads[2].battle_shocked and OrksWaaagh.is_riled_up(state, 2), "Beastboss Keep Huntin' clears Battle-shock and riles up Beast Snagga unit")
	var ckw := OrksBatch2.clever_know_wotz(state, 3, 3, func() -> int: return 6)
	check(ckw.error.is_empty() and ckw.healed == 3 and OrksBatch2.hit_bonus(state, 3, false) == 1, "Mek Clever Know-wotz heals D3 on Vehicle and grants +1 Hit")

	quit(1 if failures > 0 else 0)

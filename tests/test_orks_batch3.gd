extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const OrkProfiles = preload("res://scripts/edition_11/current_reference_orks_profiles.gd")
const OrkEquipment = preload("res://scripts/edition_11/ork_saved_equipment.gd")
const OrksBatch3 = preload("res://scripts/edition_11/orks_batch3_abilities.gd")
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
	check(cat.select_edition("11e").is_empty(), "11e catalog loads cleanly with Orks Batch 3")
	var admitted := {}
	for u: Dictionary in cat.catalog.units:
		if u.faction == "Orks": admitted[u.source_id] = u
	check(admitted.size() >= 31, "Expected at least 31 Orks datasheets admitted (Batches 1-3), got %d" % admitted.size())
	for slug: String in ["ghazghkull-thraka", "boss-snikrot", "nazdreg", "zodgrod-wortsnagga", "mozrog-skragbad", "wazdakka-gutsmek", "painboss", "beastboss-on-squigosaur", "squighog-boyz"]:
		check(admitted.has(slug), "Batch 3 datasheet admitted: " + slug)
	for epic: String in ["ghazghkull-thraka", "boss-snikrot", "nazdreg", "zodgrod-wortsnagga", "mozrog-skragbad", "wazdakka-gutsmek"]:
		check(OrkProfiles.profile(epic).get("max_supported_copies", 0) == 1, "Epic Hero single-copy cap: " + epic)

	check(OrkEquipment.validate_entry(OrkEquipment.BEASTBOSS_SQUIGOSAUR, 1, {"ork_beastboss_squigosaur_ranged": "thump-gun"}).is_empty(), "Beastboss on Squigosaur Thump Gun passes")

	var state := {
		"turn": 1, "battle_round": 2, "phase": "movement",
		"unit_abilities": {"implementation": UnitAbilities.ID, "enabled": true, "doctrines": {}},
		"squads": {
			1: {"owner": 0, "charged": true, "battle_shocked": false, "attached": false},
			2: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false},
			3: {"owner": 0, "charged": false, "battle_shocked": false, "attached": false},
			4: {"owner": 1, "charged": false, "battle_shocked": false, "attached": false}
		},
		"units": {
			10: {"owner": 0, "squad": 1, "definition_id": "40kdc:11e:orks:ghazghkull-thraka", "position": Vector2(0, 0), "radius": 1.57, "wounds": 12, "max_wounds": 12, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER", "EPIC HERO"]},
			20: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:beastboss-on-squigosaur", "position": Vector2(4, 0), "radius": 1.57, "wounds": 6, "max_wounds": 8, "on_battlefield": true, "keywords": ["ORKS", "MONSTER", "CHARACTER", "BEAST SNAGGA"]},
			21: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:squighog-boyz", "position": Vector2(5, 0), "radius": 1.48, "wounds": 4, "max_wounds": 4, "on_battlefield": true, "keywords": ["ORKS", "MOUNTED", "BEAST SNAGGA"]},
			22: {"owner": 0, "squad": 2, "definition_id": "40kdc:11e:orks:painboss", "position": Vector2(6, 0), "radius": 0.787, "wounds": 4, "max_wounds": 4, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER"]},
			30: {"owner": 0, "squad": 3, "definition_id": "40kdc:11e:orks:zodgrod-wortsnagga", "position": Vector2(20, 0), "radius": 0.98, "wounds": 5, "max_wounds": 5, "on_battlefield": true, "keywords": ["ORKS", "INFANTRY", "CHARACTER", "EPIC HERO"]},
			31: {"owner": 0, "squad": 3, "definition_id": "40kdc:11e:orks:mozrog-skragbad", "position": Vector2(21, 0), "radius": 1.57, "wounds": 8, "max_wounds": 8, "on_battlefield": true, "keywords": ["ORKS", "MONSTER", "CHARACTER", "EPIC HERO"]},
			40: {"owner": 1, "squad": 4, "definition_id": "40kdc:11e:necrons:monolith", "position": Vector2(22, 0), "radius": 3.15, "wounds": 22, "max_wounds": 22, "on_battlefield": true, "keywords": ["NECRONS", "VEHICLE", "TITANIC"]}
		}
	}
	var makari := OrksBatch3.makari_hoist_banner(state, 0, 1, [1, 2])
	check(makari.error.is_empty() and OrksWaaagh.is_riled_up(state, 1) and OrksWaaagh.is_riled_up(state, 2), "Makari Hoist Dat Banner! riles up up to battle_round units")
	check(not OrksBatch3.makari_hoist_banner(state, 0, 1, [1]).error.is_empty(), "Makari banner is once per battle")
	check(OrksBatch3.prophet_melee_bonus(state, 2, true) == 1, "Ghazghkull Prophet aura grants +1 Hit/Wound within 6 inches")
	check(Doctrines.charge_bonus(state, 2) == 1, "Thundering Stampede grants +1 Charge to Beast Snagga within 6 inches")
	check(OrksBatch3.da_bigger_dey_iz_reroll(state, 3, 4, true) == "all", "Mozrog re-rolls melee wounds vs MONSTER/VEHICLE")
	check(OrksBatch3.hardy_bioniks_wound_modifier(state, 2, 10, 5) == -1, "Painboss Hardy Bioniks applies -1 to Wound when S > T")
	check(OrksBatch3.brutal_impact_damage_bonus(state, 1) == 0 and OrksBatch3.brutal_impact_damage_bonus(state, 2) == 0, "Brutal Impact requires charged == true")
	state.squads[2].charged = true
	check(OrksBatch3.brutal_impact_damage_bonus(state, 2) == 1, "Squighog Boyz Brutal Impact grants +1 D on charge")
	check(OrksWaaagh.is_riled_up(state, 3), "Zodgrod Super Runts keeps unit riled up")
	var push := OrksBatch3.push_dat_bit_back_in(state, 0, 2, 2)
	check(push.error.is_empty() and push.healed == 2 and state.units[20].wounds == 8, "Painboss Push Dat Bit Back In heals 3 wounds once per battle")

	quit(1 if failures > 0 else 0)

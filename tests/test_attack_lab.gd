extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var lab = load("res://scenes/attack_lab.tscn").instantiate()
	root.add_child(lab)
	if lab.catalog.is_empty():
		push_error("Import starter data before running this optional integration check.")
		quit(1)
		return
	lab.rng.seed = 42
	if lab.weapon_profiles[lab.weapons.selected].source_weapon_id != "bolt-rifle-intercessor-squad":
		push_error("Default lab weapon must be the imported Bolt Rifle, not a fallback profile.")
		quit(1)
		return
	lab._roll()
	if "Cannot resolve" in lab.report.text or "Attacks" not in lab.report.text:
		push_error(lab.report.text)
		quit(1)
		return
	# The imported training hammer exposes mortal damage in the isolated report.
	for index in range(lab.weapon_profiles.size()):
		if lab.weapon_profiles[index].source_weapon_id == "thunder-hammer-intercessor-squad": lab.weapons.select(index)
	lab.weapon_count.value = 20
	lab.rng.seed = 42
	lab._roll()
	if "Cannot resolve" in lab.report.text or "Devastating Wounds:" not in lab.report.text:
		push_error("Thunder Hammer report must identify devastating mortal damage: " + lab.report.text)
		quit(1)
		return
	lab.weapon_count.value = 5
	# Hunter uses the selected defender's actual imported keywords.
	var vehicle_index := -1
	for index in range(lab.catalog.size()):
		if lab.catalog[index].source_id == "terminator-squad": lab.attacker.select(index)
		if lab.catalog[index].source_id == "land-raider": vehicle_index = index
	lab._refresh_weapons()
	for index in range(lab.weapon_profiles.size()):
		if lab.weapon_profiles[index].get("name") == "Chainfist - Hunter": lab.weapons.select(index)
	lab._roll()
	if "Hunter profile requires" not in lab.report.text or vehicle_index < 0:
		push_error("Hunter must reject the infantry defender in the lab.")
		quit(1)
		return
	lab.defender.select(vehicle_index)
	lab._roll()
	if "Cannot resolve" in lab.report.text or "Attacks" not in lab.report.text:
		push_error(lab.report.text)
		quit(1)
		return
	for index in range(lab.catalog.size()):
		if lab.catalog[index].source_id == "techmarine": lab.attacker.select(index)
	lab._refresh_weapons()
	for index in range(lab.weapon_profiles.size()):
		if lab.weapon_profiles[index].get("name") == "Servo-arm": lab.weapons.select(index)
	lab._roll()
	if "Cannot resolve" in lab.report.text or "extra-attacks" not in lab.report.text:
		push_error("Extra Attacks lab calculation must disclose isolated selection scope: " + lab.report.text)
		quit(1)
		return
	# Reverse the factions and exercise Gauss flayer's actual linked profile.
	var marine_index: int = lab.attacker.selected
	var necron_index: int = lab.defender.selected
	lab.attacker.select(necron_index)
	lab.defender.select(marine_index)
	lab._refresh_weapons()
	for index in range(lab.weapon_profiles.size()):
		if lab.weapon_profiles[index].get("name", "").to_lower() == "gauss flayer":
			lab.weapons.select(index)
	lab._roll()
	if "Cannot resolve" in lab.report.text or "Attacks" not in lab.report.text:
		push_error(lab.report.text)
		quit(1)
		return
	print("Two-faction lab integration: PASS")
	quit()

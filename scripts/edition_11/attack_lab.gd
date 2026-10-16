extends Control
## Isolated attack inspection UI. This is not an enforced full-faction match.

const Pack = preload("res://scripts/data_pack.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const DIRECTORY := "res://data/imported/starter-11e-v1"
var catalog: Array = []
var attacker: OptionButton
var defender: OptionButton
var weapons: OptionButton
var weapon_count: SpinBox
var target_count: SpinBox
var distance: SpinBox
var feel_no_pain: SpinBox
var heavy: CheckBox
var lethal: CheckBox
var report: RichTextLabel
var weapon_profiles: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	var background := ColorRect.new()
	background.color = Color("131b25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var title := Label.new()
	title.text = "11th edition • Attack sequence lab"
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)
	var scope := Label.new()
	scope.text = "Space Marines / Necrons • Real core attack sequence, isolated profiles.\nArmy rules, unit abilities, targeting, terrain and phase eligibility are not applied here."
	column.add_child(scope)
	var back := Button.new()
	back.text = "Return to 3D movement prototype"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main.tscn"))
	column.add_child(back)
	for faction in ["adeptus-astartes", "necrons"]:
		var pack: Dictionary = Pack.load_pack(DIRECTORY.path_join(faction))
		if not pack.error.is_empty():
			var missing := Label.new()
			missing.text = "Local starter data missing. Run:\npython tools/import_starter_factions.py --output data/imported/starter-11e-v1\nThen reopen this scene. No web requests are made by this screen."
			column.add_child(missing)
			return
		catalog.append_array(pack.units)
	attacker = _selector(column, "Attacker")
	defender = _selector(column, "Defender")
	weapons = _selector(column, "Weapon profile")
	for unit: Dictionary in catalog:
		var label: String = "%s / %s" % [unit.faction, unit.name]
		attacker.add_item(label)
		defender.add_item(label)
	for index in range(catalog.size()):
		if catalog[index].source_id == "intercessor-squad": attacker.select(index)
		if catalog[index].source_id == "necron-warriors": defender.select(index)
	var row := HBoxContainer.new()
	column.add_child(row)
	weapon_count = _number(row, "Identical weapons", 1, 100, 5)
	target_count = _number(row, "Target models", 1, 100, 10)
	distance = _number(row, "Distance (inches)", 0, 100, 12)
	distance.step = 0.5
	var prevention_row := HBoxContainer.new()
	column.add_child(prevention_row)
	feel_no_pain = _number(prevention_row, "Test Feel No Pain (0 = off; 2–6)", 0, 6, 0)
	heavy = CheckBox.new()
	heavy.text = "Heavy eligible (test context)"
	column.add_child(heavy)
	lethal = CheckBox.new()
	lethal.text = "Use Lethal Hits automatic wounds"
	lethal.button_pressed = true
	column.add_child(lethal)
	var roll := Button.new()
	roll.text = "Roll isolated attack pool"
	roll.pressed.connect(_roll)
	column.add_child(roll)
	report = RichTextLabel.new()
	report.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report.custom_minimum_size.y = 180
	column.add_child(report)
	attacker.item_selected.connect(func(_index: int): _refresh_weapons())
	_refresh_weapons()

func _selector(parent: Node, text: String) -> OptionButton:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 140
	row.add_child(label)
	var select := OptionButton.new()
	select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(select)
	return select

func _number(parent: Node, text: String, minimum: int, maximum: int, initial: int) -> SpinBox:
	var label := Label.new()
	label.text = text
	parent.add_child(label)
	var input := SpinBox.new()
	input.min_value = minimum
	input.max_value = maximum
	input.value = initial
	parent.add_child(input)
	return input

func _refresh_weapons() -> void:
	weapons.clear()
	weapon_profiles.clear()
	var unit: Dictionary = catalog[attacker.selected]
	for weapon: Dictionary in unit.get("source_weapon_definitions", []):
		for profile: Dictionary in weapon.get("profiles", []):
			var labeled: Dictionary = profile.duplicate(true)
			labeled["source_weapon_id"] = weapon.id
			labeled["display_name"] = "%s / %s" % [weapon.name, profile.get("name", weapon.name)]
			weapon_profiles.append(labeled)
			weapons.add_item(labeled.display_name)
	for index in range(weapon_profiles.size()):
		if weapon_profiles[index].source_weapon_id == "bolt-rifle-intercessor-squad" and weapon_profiles[index].get("name") == "Saturation": weapons.select(index)
	report.text = "Local profiles loaded. These are source snapshots, not certified complete datasheets.\nFull faction rules remain disabled in matches. This lab only tests the attack sequence."

func _roll() -> void:
	if weapons.selected < 0:
		report.text = "No weapon profile available."
		return
	var profile: Dictionary = weapon_profiles[weapons.selected]
	var stats: Dictionary = profile.get("stats", {})
	var keywords := Attacks.Traits.import_profile(profile)
	var selection_only: Array[String] = []
	for entry: Dictionary in profile.get("keywords", []):
		var id: String = entry.get("keyword_id", "")
		if id in ["hazardous", "precision"]:
			report.text = "Cannot resolve %s in this isolated target-only lab. Use the combat exercise for unit allocation choices." % id
			return
		if id in ["assault", "close-quarters", "extra-attacks"]:
			selection_only.append(id)
			keywords.erase(id)
			continue
	var weapon := {"attacks": stats.get("A"), "skill": stats.get("BS", stats.get("WS")),
		"strength": stats.get("S"), "ap": stats.get("AP"), "damage": stats.get("D"),
		"range_inches": profile.get("range"), "keywords": keywords}
	var unit: Dictionary = catalog[defender.selected]
	var wounds: Variant = unit.stats.get("wounds")
	if not wounds is int and not wounds is float:
		report.text = "Defender has an unresolved wounds characteristic."
		return
	var remaining: Array[int] = []
	for index in range(int(target_count.value)): remaining.append(int(wounds))
	var target := {"toughness": unit.stats.get("toughness"), "save_target": unit.stats.get("save_target"),
		"invulnerable_target": unit.stats.get("invulnerable_target", 0),
		"wounds_per_model": wounds, "remaining_wounds": remaining}
	if target.invulnerable_target == null: target.invulnerable_target = 0
	target.prevention = []
	for index in range(remaining.size()): target.prevention.append([] if int(feel_no_pain.value) == 0 else [{"target": int(feel_no_pain.value), "against": "any"}])
	var context := {"weapon_count": int(weapon_count.value), "distance_inches": distance.value,
		"heavy_eligible": heavy.button_pressed, "use_lethal_hits": lethal.button_pressed,
		"target_keywords": unit.get("keywords", []), "target_model_count": int(target_count.value), "target_engaged": false}
	var result: Dictionary = Attacks.resolve(weapon, target, context, _d6)
	if not result.error.is_empty():
		report.text = "Cannot resolve this profile: " + result.error
		return
	report.text = "%s → %s\n%s\nAttacks %d | Hits %d | Wounds %d | Unsaved %d\nModels destroyed %d | Damage applied %d\nHit rolls: %s\nWound rolls: %s\nSave rolls (ascending): %s\nRemaining model wounds: %s\nSelection-only keywords outside this lab: %s\nUnit and army abilities are outside this isolated calculation." % [catalog[attacker.selected].name, unit.name, profile.get("display_name", "Weapon"), result.attacks, result.hits, result.wounds, result.unsaved, result.models_destroyed, result.damage_applied, str(result.hit_rolls), str(result.wound_rolls), str(result.save_rolls), str(result.remaining_wounds), str(selection_only)]

	if result.devastating_wounds > 0: report.text += "\nDevastating Wounds: %d critical wounds, %d mortal damage, %d normal damage. Each critical damages at most one model." % [result.devastating_wounds, result.mortal_damage_applied, result.normal_damage_applied]

	if int(feel_no_pain.value) > 0: report.text += "\nTest Feel No Pain %d+: %d wounds prevented. This test setting does not grant an army ability." % [int(feel_no_pain.value), result.prevented_wounds]

func _d6() -> int:
	return rng.randi_range(1, 6)

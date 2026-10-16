extends Node3D

const Rules = preload("res://scripts/rules.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const AllocationPractice = preload("res://scripts/edition_11/allocation_practice.gd")
const TacticalGuides = preload("res://scripts/tactical_guides.gd")
const ModelImports = preload("res://scripts/model_import_panel.gd")
const TestBattlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const PreparedTraining = preload("res://scripts/edition_11/prepared_training.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const ArmyBuilder = preload("res://scripts/army_builder_panel.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const MatchSave = preload("res://scripts/match_save.gd")
const MatchJournal = preload("res://scripts/match_journal.gd")
const MatchHistoryPanel = preload("res://scripts/match_history_panel.gd")
var journal = MatchJournal.new()
var history_panel
const SessionSeat = preload("res://scripts/session_seat.gd")
var host_session: Dictionary = {}
var pending_seats: Dictionary = {}
var seat_challenge: Dictionary = {}
var autosave_error := ""
var auto_models: CheckBox
var local_model_status: Label
var saved_army_mode := false
var saved_army_pickers: Dictionary = {}
var saved_training_consent: CheckBox
var saved_army_review: Label
var setup_notice: Label
var pending_armies: Dictionary = {}
var submitted_army: Dictionary = {}
var validated_saved_setup := ""
var army_builder
var prepared_match := false
var objective_secured := false
var implacable_eradication := false
var hail_of_bolts := false
var objective_secured_choice: CheckBox
var implacable_eradication_choice: CheckBox
var hail_of_bolts_choice: CheckBox
var core_stratagems := false
var count_rerolls := false
var count_reroll_choice: CheckBox
var hazard_rerolls := false
var escape_rerolls := false
var hazard_reroll_choice: CheckBox
var escape_reroll_choice: CheckBox
var damage_rerolls := false
var damage_reroll_choice: CheckBox
var save_rerolls := false
var save_reroll_choice: CheckBox
var attack_rerolls := false
var attack_reroll_choice: CheckBox
var reaction_die: OptionButton
var movement_rerolls := false
var reroll_choice: CheckBox
var stratagem_choice: CheckBox
var reaction_help: Label
var reaction_squad: OptionButton
var reaction_roll: Button
var reaction_use: Button
var prepared_button: Button
var deployment_preset_button: Button
var deployment_confirm_button: Button
var deployment_help: Label
var board_root: Node3D
var rendered_board_size := Vector2.ZERO
var model_imports: VBoxContainer
const PORT := 24560
var state: Dictionary = Rules.initial_state()
var pieces: Dictionary = {}
var selected := -1
var mode := "local"
var guest_id := 0
var camera: Camera3D
var pivot: Node3D
var status: Label
var details: Label
var selection_card: Label
var decision_details: Label
var technical_toggle: CheckButton
var address: LineEdit
var session_label: Label
var decision_label: Label
var objective_summary: Label
var match_tabs: TabContainer
var gameplay_scroll: ScrollContainer
var ui_combat_enabled := false
var host_button: Button
var join_button: Button
var end_button: Button
var zoom := 24.0
var angle := 0.0
var combat_enabled := false
var terrain_layout := Combat.Terrain.DEFAULT_LAYOUT
var terrain_root: Node3D
var terrain_signature := ""
var combat_button: Button
var objective_button: Button
var mission_id := "elimination"
var squads_per_side := 1
var multi_button: Button
var defender_choice: CheckBox
var manual_allocation := false
var varied_equipment := false
var allocation_practice := false
var equipment_choice: CheckBox
var allocate_button: Button
var precision_skip: Button
var scope_label: Label
var lethal_choice: CheckBox
var event_log: RichTextLabel
var log_toggle: CheckButton
var result_summary: Label
var charge_button: Button
var finish_move_button: Button
var cancel_move_button: Button
var coherency_button: Button
var movement_choice: OptionButton
var begin_move_button: Button
var escape_wound_button: Button
var abandon_move_button: Button
var begin_contact_button: Button
var consolidation_objective: OptionButton
var contact_enemy: OptionButton
var action_objective: OptionButton
var action_button: Button
var attack_draft: Dictionary = {}
var plan_begin: Button
var plan_hail: OptionButton
var plan_target: OptionButton
var plan_weapon: OptionButton
var plan_amount: SpinBox
var plan_add: Button
var plan_clear: Button
var plan_confirm: Button
var plan_cancel: Button
var plan_summary: Label
var plan_steps: Label
var defense_steps: Label
var defense_picker: OptionButton
var action_groups: Dictionary = {}
var confirm_contact_button: Button
var cancel_contact_button: Button
const MOVE_TYPES := ["normal", "advance", "ordered_retreat", "desperate_escape", "stationary"]
var sidebar_panel: PanelContainer
var guide_panel: PanelContainer
var guide_label: Label
var guides_toggle: CheckBox
var guides
var hover_time := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_reset_history()
	if state.is_empty():
		push_error("Startup stopped: the local demo data pack is invalid.")
		get_tree().quit(1)
		return
	_build_board()
	_build_ui()
	_spawn_pieces()
	get_viewport().size_changed.connect(_layout_ui)
	_layout_ui()
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(func(): _offline("Connection failed."))
	multiplayer.server_disconnected.connect(func(): _offline("Host disconnected. Local preview restored."))
	_refresh()

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material

func _box(size: Vector3, at: Vector3, color: Color, parent: Node3D = null) -> void:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = at
	mesh.material_override = _material(color)
	if parent == null: add_child(mesh)
	else: parent.add_child(mesh)

func _build_board() -> void:
	board_root = Node3D.new()
	add_child(board_root)
	_sync_board()
	terrain_root = Node3D.new()
	add_child(terrain_root)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_energy = 1.3
	add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b3c5da")
	environment.environment.ambient_light_energy = 0.6
	add_child(environment)
	pivot = Node3D.new()
	add_child(pivot)
	camera = Camera3D.new()
	camera.h_offset = -7.0
	pivot.add_child(camera)
	camera.current = true
	_update_camera()
	_spawn_pieces()
	guides = TacticalGuides.new()
	add_child(guides)

func _sync_board() -> void:
	var size := Rules.half_board(state) * 2.0
	if size == rendered_board_size: return
	rendered_board_size = size
	for child in board_root.get_children():
		board_root.remove_child(child)
		child.queue_free()
	_box(Vector3(size.x, 0.3, size.y), Vector3(0, -0.16, 0), Color("343f44"), board_root)
	for x in range(ceili(-size.x / 2.0), floori(size.x / 2.0) + 1):
		_box(Vector3(0.018, 0.01, size.y), Vector3(x, 0.01, 0), Color("485358"), board_root)
	for z in range(ceili(-size.y / 2.0), floori(size.y / 2.0) + 1):
		_box(Vector3(size.x, 0.01, 0.018), Vector3(0, 0.01, z), Color("485358"), board_root)
	for side in [-1, 1]:
		_box(Vector3(0.035, 0.02, size.y), Vector3(side * size.x / 2.0, 0.01, 0), Color("a3b4bc"), board_root)
		_box(Vector3(size.x, 0.02, 0.035), Vector3(0, 0.01, side * size.y / 2.0), Color("a3b4bc"), board_root)
	zoom = maxf(24.0, maxf(size.x, size.y) * 1.1)
	if camera != null: _update_camera()

func _spawn_pieces() -> void:
	for piece: MeshInstance3D in pieces.values(): piece.queue_free()
	pieces.clear()
	for id: int in state.units:
		var piece := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = state.units[id].radius if combat_enabled else 0.32
		mesh.bottom_radius = state.units[id].radius
		mesh.height = 1.3
		piece.mesh = mesh
		add_child(piece)
		pieces[id] = piece
		if model_imports != null:
			var visual: Node3D = model_imports.visual_for(str(state.units[id].get("definition_id", "")))
			if visual != null:
				mesh.height = 0.08
				mesh.top_radius = state.units[id].radius
				var base_offset := Node3D.new()
				base_offset.position.y = 0.04
				piece.add_child(base_offset)
				base_offset.add_child(visual)
				# Keep the colored selection base on the board; visuals are cosmetic.
				piece.set_meta("imported_visual", true)

func _scroll_column(parent: Node, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(column)
	return column

func _setup_section(parent: VBoxContainer, title_text: String, description: String = "") -> VBoxContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("171e25")
	card_style.border_color = Color("344654")
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(8)
	card_style.content_margin_left = 12
	card_style.content_margin_right = 12
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", card_style)
	parent.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	card.add_child(content)
	var heading := Label.new()
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", Color("e8bc62"))
	content.add_child(heading)
	if not description.is_empty():
		var caption := Label.new()
		caption.text = description
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.add_theme_color_override("font_color", Color("b8c5ce"))
		content.add_child(caption)
	return content

func _make_setup_foldout(parent: VBoxContainer, title_text: String, description: String = "") -> VBoxContainer:
	var header := Button.new()
	header.text = "＋  " + title_text
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.toggle_mode = true
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.custom_minimum_size.y = 38
	parent.add_child(header)
	var body := _setup_section(parent, title_text, description)
	var card := body.get_parent() as PanelContainer
	card.visible = false
	# Remove the heading duplicated by the foldout button.
	body.get_child(0).queue_free()
	header.toggled.connect(func(open: bool):
		card.visible = open
		header.text = ("－  " if open else "＋  ") + title_text
	)
	return body

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	sidebar_panel = panel
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(440, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("e610151c")
	panel_style.border_color = Color("586b78")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	margin.add_child(header)
	var title := Label.new()
	title.text = "OPEN TABLETOP"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("f2df83"))
	header.add_child(title)
	decision_label = Label.new()
	decision_label.custom_minimum_size.x = 400
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.add_theme_color_override("font_color", Color("f2df83"))
	header.add_child(decision_label)
	objective_summary = Label.new()
	objective_summary.custom_minimum_size.x = 400
	objective_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(objective_summary)
	session_label = Label.new()
	session_label.custom_minimum_size.x = 400
	session_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(session_label)
	match_tabs = TabContainer.new()
	match_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header.add_child(match_tabs)
	var setup := _scroll_column(match_tabs, "Match setup")
	setup.add_theme_constant_override("separation", 12)
	var column := _scroll_column(match_tabs, "Play")
	gameplay_scroll = column.get_parent() as ScrollContainer
	var models := _scroll_column(match_tabs, "Models")
	match_tabs.set_tab_title(2, "Models / Import")
	model_imports = ModelImports.new()
	model_imports.selected_definition = func(): return str(state.units[selected].get("definition_id", "")) if state.units.has(selected) else ""
	model_imports.mappings_changed.connect(func(): _spawn_pieces(); _refresh())
	models.add_child(model_imports)
	var armies := _scroll_column(match_tabs, "Armies")
	army_builder = ArmyBuilder.new()
	armies.add_child(army_builder)
	var history := _scroll_column(match_tabs, "History")
	history_panel = MatchHistoryPanel.new()
	history.add_child(history_panel)
	history_panel.page_requested.connect(_history_page)
	history_panel.visibility_changed.connect(func():
		if history_panel.is_visible_in_tree(): _history_page(-1))
	army_builder.library_changed.connect(_refresh_army_choices)
	var overview := _setup_section(setup, "GET STARTED", "Choose an exercise to open the table. Each mode shows its training scope before play begins.")
	scope_label = Label.new()
	scope_label.custom_minimum_size.x = 400
	scope_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overview.add_child(scope_label)
	var launch := _setup_section(setup, "EXERCISES", "Local matches for learning the table and practicing implemented rules.")
	var network := _setup_section(setup, "PLAY OVER LAN", "The host and guest must choose the same exercise and options.")
	var row := HBoxContainer.new()
	network.add_child(row)
	address = LineEdit.new()
	address.text = "127.0.0.1"
	address.placeholder_text = "Host IP address"
	address.custom_minimum_size.x = 180
	row.add_child(address)
	host_button = _button(row, "Host LAN", _host)
	join_button = _button(row, "Join", _join)
	var recovery_help := Label.new()
	recovery_help.text = "Joining reserves your seat on this computer. To return after the host restarts, choose the same exercise or army list, then select Join."
	recovery_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_help.custom_minimum_size.x = 400
	network.add_child(recovery_help)
	var recovery := _setup_section(setup, "RESUME MATCH", "Save or continue a match on this computer.")
	_button(recovery, "Save match now", _save_match)
	_button(recovery, "Resume last match locally", _load_match)
	_button(recovery, "Resume last match as LAN host", func(): _load_match(true))
	var advanced := _make_setup_foldout(setup, "Advanced match options", "Optional rules for the next match. In LAN games, both players must choose the same options.")
	defender_choice = CheckBox.new()
	defender_choice.text = "Next match: defender chooses damage recipients"
	advanced.add_child(defender_choice)
	equipment_choice = CheckBox.new()
	equipment_choice.text = "Next match: varied training equipment"
	advanced.add_child(equipment_choice)
	hail_of_bolts_choice = CheckBox.new()
	hail_of_bolts_choice.text = "Next prepared match: Intercessor Hail of Bolts"
	hail_of_bolts_choice.tooltip_text = "In your Shooting phase, choose one visible enemy in the attack plan. Bolt rifles attacking that unit gain +2 attacks. Both LAN players must choose the same option."
	advanced.add_child(hail_of_bolts_choice)
	hail_of_bolts_choice.toggled.connect(func(_enabled: bool): _review_saved_armies())
	implacable_eradication_choice = CheckBox.new()
	implacable_eradication_choice.text = "Next prepared match: Immortals Implacable Eradication (reference)"
	implacable_eradication_choice.tooltip_text = "Training reference: automatically re-roll wound rolls of 1; re-roll failed wounds against units in objective range. Successful rolls are kept. Both LAN players must agree."
	advanced.add_child(implacable_eradication_choice)
	implacable_eradication_choice.toggled.connect(func(_enabled: bool): _review_saved_armies())
	objective_secured_choice = CheckBox.new()
	objective_secured_choice.text = "Next prepared match: Intercessor Objective Secured"
	objective_secured_choice.tooltip_text = "At the end of your Command phase, Intercessors secure objectives they control. Both LAN players must choose the same option."
	advanced.add_child(objective_secured_choice)
	objective_secured_choice.toggled.connect(func(_enabled: bool): _review_saved_armies())
	stratagem_choice = CheckBox.new()
	stratagem_choice.text = "Next prepared match: Insane Bravery"
	stratagem_choice.tooltip_text = "Opens decisions before Battle-shock tests in prepared matches and saved-army matches. Both players must choose the same option."
	advanced.add_child(stratagem_choice)
	reroll_choice = CheckBox.new()
	reroll_choice.text = "Next match: Command Re-roll Advance/Charge"
	reroll_choice.tooltip_text = "Also enables Insane Bravery. Advance: one new D6; Charge: two new D6. Each player can use Command Re-roll once per phase."
	reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: reroll_choice.button_pressed = false)
	advanced.add_child(reroll_choice)
	attack_reroll_choice = CheckBox.new()
	attack_reroll_choice.text = "Next match: Hit/Wound re-roll"
	attack_reroll_choice.tooltip_text = "Choose one D6 before rolling the next step. Save re-rolls use a separate option. Damage, Hazardous, and attack-count re-rolls each use separate options. Desperate Escape is not included."
	attack_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: attack_reroll_choice.button_pressed = false)
	advanced.add_child(attack_reroll_choice)
	save_reroll_choice = CheckBox.new()
	save_reroll_choice.text = "Next match: Save re-roll"
	save_reroll_choice.tooltip_text = "The defender can replace one D6 before ordering saves and resolving damage. Costs 1 CP and shares the phase limit."
	save_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: save_reroll_choice.button_pressed = false)
	advanced.add_child(save_reroll_choice)
	damage_reroll_choice = CheckBox.new()
	damage_reroll_choice.text = "Next match: Damage re-roll"
	damage_reroll_choice.tooltip_text = "The attacker can replace one random damage die before prevention and casualties. Costs 1 CP and shares the phase limit. Fixed damage does not open a decision. Synthetic labs start with 2 CP per player."
	damage_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: damage_reroll_choice.button_pressed = false)
	advanced.add_child(damage_reroll_choice)
	escape_reroll_choice = CheckBox.new()
	escape_reroll_choice.text = "Next match: Desperate Escape re-roll"
	escape_reroll_choice.tooltip_text = "Replace one escape hazard D6 before mortal wounds and movement. Costs 1 CP, shares the phase limit and cannot target Battle-shocked units."
	escape_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: escape_reroll_choice.button_pressed = false)
	advanced.add_child(escape_reroll_choice)
	hazard_reroll_choice = CheckBox.new()
	hazard_reroll_choice.text = "Next match: Hazardous re-roll"
	hazard_reroll_choice.tooltip_text = "Replace one weapon Hazardous D6 before allocating mortal wounds. Use varied equipment and supercharged plasma. Desperate Escape is not included."
	hazard_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: hazard_reroll_choice.button_pressed = false)
	advanced.add_child(hazard_reroll_choice)
	count_reroll_choice = CheckBox.new()
	count_reroll_choice.text = "Next match: Attack-count re-roll"
	count_reroll_choice.tooltip_text = "Replace one random attack-count die before rolling hits. In the lab, choose the random-A rifle; each player starts with 2 CP. Bonuses and other dice are preserved."
	count_reroll_choice.toggled.connect(func(enabled: bool):
		if enabled: stratagem_choice.button_pressed = true)
	stratagem_choice.toggled.connect(func(enabled: bool):
		if not enabled: count_reroll_choice.button_pressed = false)
	advanced.add_child(count_reroll_choice)
	combat_button = _button(launch, "Start 3D combat • Marines vs. Necrons", _toggle_combat)
	objective_button = _button(launch, "Objective training • 5 rounds", _start_objectives)
	multi_button = _button(launch, "Expanded training • 2 units per player", func(): _start_objectives(2))
	prepared_button = _button(launch, "Prepare match • deployment + 5 rounds", _start_prepared_match)
	for primary: Button in [combat_button, objective_button, prepared_button]:
		primary.custom_minimum_size.y = 42
		primary.add_theme_color_override("font_color", Color("101820"))
		var button_style := StyleBoxFlat.new()
		button_style.bg_color = Color("d9aa4f")
		button_style.set_corner_radius_all(6)
		button_style.content_margin_left = 8
		button_style.content_margin_right = 8
		primary.add_theme_stylebox_override("normal", button_style)
		var hover_style := button_style.duplicate() as StyleBoxFlat
		hover_style.bg_color = Color("f1c875")
		primary.add_theme_stylebox_override("hover", hover_style)
	var saved_title := Label.new()
	saved_title.text = "Ready armies • 500-point training category • fixed weapons"
	var saved_lists := _setup_section(setup, "LOCAL MATCH • TWO ARMIES", "Training: Intercessors, Terminators, Warriors and Immortals; up to six units per side. Fixed weapons and partial rules. Deployment + five rounds on this computer.")
	setup.move_child(saved_lists.get_parent(), 0)
	saved_lists.add_child(saved_title)
	for owner in [1, 2]:
		var picker := OptionButton.new()
		picker.fit_to_longest_item = false
		picker.custom_minimum_size.x = 400
		saved_lists.add_child(picker)
		saved_army_pickers[owner] = picker
		picker.item_selected.connect(func(_index: int): _review_saved_armies())
	var create_local := _button(saved_lists, "Create local match with these two lists", _start_saved_match)
	create_local.custom_minimum_size.y = 42
	create_local.add_theme_color_override("font_color", Color("f2df83"))
	_button(saved_lists, "Refresh profile lists", _refresh_army_choices)
	for owner in [1, 2]:
		_button(saved_lists, "Save a copy of player %d's list to my profile" % owner, func(): _save_selected_army(owner))
	auto_models = CheckBox.new()
	auto_models.text = "Download and link ForceOrg models automatically"
	auto_models.button_pressed = true
	saved_lists.add_child(auto_models)
	local_model_status = Label.new()
	local_model_status.custom_minimum_size.x = 400
	local_model_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_model_status.text = "Models: ForceOrg catalog and compatible miniatures download automatically. Saved links are reused."
	saved_lists.add_child(local_model_status)
	var model_play_notice := Label.new()
	model_play_notice.custom_minimum_size.x = 400
	model_play_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	model_play_notice.visible = false
	column.add_child(model_play_notice)
	model_imports.automatic_status.connect(func(message: String):
		local_model_status.text = message
		model_play_notice.text = "ForceOrg • " + message.get_slice("\n", message.get_slice_count("\n") - 1)
		model_play_notice.visible = not message.is_empty()
	)
	_button(saved_lists, "Configure ForceOrg catalog / model variants", func(): match_tabs.current_tab = 2)
	_button(saved_lists, "Retry automatic models for current match", func(): _prepare_local_models(true))
	_button(saved_lists, "Cancel automatic models", func(): model_imports.cancel_automatic())
	saved_army_review = Label.new()
	saved_army_review.custom_minimum_size.x = 400
	saved_army_review.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	saved_lists.add_child(saved_army_review)
	setup_notice = Label.new()
	setup_notice.custom_minimum_size.x = 400
	setup_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	saved_lists.add_child(setup_notice)
	saved_training_consent = CheckBox.new()
	saved_training_consent.text = "LAN: accept partial training rules"
	saved_lists.add_child(saved_training_consent)
	_button(saved_lists, "Enable saved-list LAN training, then Host / Join", func(): _start_saved_match(false))
	_button(saved_lists, "Send my list to LAN training", _submit_saved_army)
	_refresh_army_choices()
	var labs := _setup_section(setup, "LABS AND TOOLS", "Practice scenarios and development shortcuts.")
	_button(labs, "Rules lab • mixed defense / Precision", _start_allocation_practice)
	_button(labs, "Local preview / disconnect", func(): _offline("Local preview: control both sides."))
	_button(labs, "11th edition attack sequence lab", func():
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		get_tree().change_scene_to_file("res://scenes/attack_lab.tscn")
	)
	selection_card = Label.new()
	selection_card.custom_minimum_size.x = 400
	selection_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(selection_card)
	decision_details = Label.new()
	decision_details.custom_minimum_size.x = 400
	decision_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(decision_details)
	technical_toggle = CheckButton.new()
	technical_toggle.text = "Show equipment and technical details"
	technical_toggle.toggled.connect(func(expanded: bool): details.visible = expanded)
	column.add_child(technical_toggle)
	details = Label.new()
	details.visible = false
	details.custom_minimum_size.x = 400
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(details)
	reaction_help = Label.new()
	reaction_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reaction_help.custom_minimum_size.x = 400
	column.add_child(reaction_help)
	reaction_squad = OptionButton.new()
	reaction_squad.item_selected.connect(func(_index: int): _refresh())
	column.add_child(reaction_squad)
	reaction_roll = _button(column, "Rolar Battle-shock normalmente", func(): _request_command_reaction(""))
	reaction_use = _button(column, "Insane Bravery • 1 CP • uma vez por batalha", _request_use_reaction)
	movement_choice = OptionButton.new()
	for label in ["Normal move", "Advance (D6)", "Fall Back: Ordered Retreat", "Fall Back: Desperate Escape", "Remain stationary"]:
		movement_choice.add_item(label)
	movement_choice.item_selected.connect(func(_index: int): _refresh())
	column.add_child(movement_choice)
	begin_move_button = _button(column, "Begin selected movement", _request_begin_movement)
	escape_wound_button = _button(column, "Allocate escape wound to selected model", _request_escape_wound)
	finish_move_button = _button(column, "Confirm squad movement", func(): _request_finish_movement(false))
	cancel_move_button = _button(column, "Cancel pending movement", func(): _request_finish_movement(true))
	abandon_move_button = _button(column, "Abandon Fall Back (retain casualties)", _request_abandon_fall_back)
	coherency_button = _button(column, "Remove selected model for coherency", _request_coherency_removal)
	allocate_button = _button(column, "Allocate next damaging attack to selected model", _request_allocate_damage)
	precision_skip = _button(column, "Do not use Precision", _request_skip_precision)
	defense_steps = Label.new()
	defense_steps.custom_minimum_size.x = 400
	defense_steps.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(defense_steps)
	defense_picker = OptionButton.new()
	defense_picker.fit_to_longest_item = false
	defense_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	defense_picker.item_selected.connect(func(index: int):
		selected = defense_picker.get_item_id(index)
		_refresh()
	)
	column.add_child(defense_picker)
	action_objective = OptionButton.new()
	column.add_child(action_objective)
	action_button = _button(column, "Start Secure Ground (custom action)", _request_action)
	end_button = _button(column, "End turn", _request_end)
	charge_button = _button(column, "Roll charge (2D6)", _request_charge_roll)
	begin_contact_button = _button(column, "Begin contact movement", _request_begin_contact)
	consolidation_objective = OptionButton.new()
	column.add_child(consolidation_objective)
	contact_enemy = OptionButton.new()
	column.add_child(contact_enemy)
	confirm_contact_button = _button(column, "Confirm contact movement", func(): _request_finish_contact(false))
	cancel_contact_button = _button(column, "Cancel contact placement (retain roll)", func(): _request_finish_contact(true))
	lethal_choice = CheckBox.new()
	lethal_choice.text = "Use Lethal Hits automatic wounds"
	lethal_choice.button_pressed = true
	column.add_child(lethal_choice)
	plan_begin = _button(column, "Plan attacks across targets", _begin_attack_plan)
	plan_steps = Label.new()
	plan_steps.custom_minimum_size.x = 400
	plan_steps.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(plan_steps)
	plan_hail = OptionButton.new()
	plan_hail.fit_to_longest_item = false
	plan_hail.tooltip_text = "Optional Hail of Bolts target, selected before confirming all attacks. Only bolt rifles assigned to this unit gain +2 attacks."
	plan_hail.item_selected.connect(func(index: int):
		if attack_draft.is_empty(): return
		attack_draft.hail_target = -1 if index == 0 else plan_hail.get_item_id(index)
		_refresh())
	column.add_child(plan_hail)
	plan_weapon = OptionButton.new()
	plan_weapon.fit_to_longest_item = false
	plan_weapon.item_selected.connect(func(_index: int): _refresh())
	column.add_child(plan_weapon)
	plan_target = OptionButton.new()
	plan_target.fit_to_longest_item = false
	plan_target.item_selected.connect(func(_index: int): _refresh())
	column.add_child(plan_target)
	plan_amount = SpinBox.new()
	plan_amount.min_value = 1
	plan_amount.step = 1
	column.add_child(plan_amount)
	plan_add = _button(column, "Assign selected model to target", _assign_attack)
	plan_clear = _button(column, "Clear selected model's assignments", _clear_attack_model)
	plan_summary = Label.new()
	plan_summary.custom_minimum_size.x = 400
	plan_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(plan_summary)
	plan_confirm = _button(column, "Confirm complete attack plan", _confirm_attack_plan)
	plan_cancel = _button(column, "Cancel attack plan", func(): attack_draft = {}; _refresh())
	status = Label.new()
	status.custom_minimum_size.x = 400
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "Local preview: control both sides."
	column.add_child(status)
	column.move_child(status, 0)
	var notice_heading := Label.new()
	notice_heading.text = "Latest notice"
	column.add_child(notice_heading)
	column.move_child(notice_heading, 0)
	var help := Label.new()
	help.text = "Left: select miniature • Right: move / target\nMovement: reposition models, confirm squad.\nWheel: zoom • Middle drag: orbit • WASD: pan"
	column.add_child(help)
	result_summary = Label.new()
	result_summary.custom_minimum_size.x = 400
	result_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(result_summary)
	log_toggle = CheckButton.new()
	log_toggle.text = "Show combat history and dice"
	log_toggle.toggled.connect(func(expanded: bool): event_log.visible = combat_enabled and expanded)
	column.add_child(log_toggle)
	event_log = RichTextLabel.new()
	event_log.visible = false
	event_log.custom_minimum_size = Vector2(400, 130)
	column.add_child(event_log)
	deployment_help = Label.new()
	deployment_help.custom_minimum_size.x = 400
	deployment_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(deployment_help)
	deployment_preset_button = _button(column, "Accept this unit's preview positions", _request_deployment_preset)
	deployment_confirm_button = _button(column, "Confirm unit deployment", _request_end)
	_build_action_groups(column)
	match_tabs.current_tab = 0
	setup.get_parent().visible = true
	column.move_child(help, column.get_child_count() - 1)
	guide_panel = PanelContainer.new()
	guide_panel.custom_minimum_size.x = 360
	layer.add_child(guide_panel)
	var guide_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: guide_margin.add_theme_constant_override("margin_" + side, 12)
	guide_panel.add_child(guide_margin)
	var guide_column := VBoxContainer.new()
	guide_margin.add_child(guide_column)
	guides_toggle = CheckBox.new()
	guides_toggle.text = "Show tactical ranges"
	guides_toggle.button_pressed = true
	guides_toggle.toggled.connect(func(enabled: bool):
		guides.visible = enabled
		_update_guides()
	)
	guide_column.add_child(guides_toggle)
	guide_label = Label.new()
	guide_label.custom_minimum_size.x = 336
	guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_column.add_child(guide_label)

func _build_action_groups(column: VBoxContainer) -> void:
	var definitions := {
		"reaction": {"title": "Decision window", "controls": [reaction_help, reaction_squad, reaction_roll, reaction_use]},
		"deployment": {"title": "Deploy your army", "controls": [deployment_help, deployment_preset_button, deployment_confirm_button]},
		"movement": {"title": "Movement / coherency", "controls": [movement_choice, begin_move_button, escape_wound_button, finish_move_button, cancel_move_button, abandon_move_button, coherency_button]},
		"contact": {"title": "Charge / contact placement", "controls": [charge_button, begin_contact_button, consolidation_objective, contact_enemy, confirm_contact_button, cancel_contact_button]},
		"attack": {"title": "Attacks", "controls": [lethal_choice, plan_begin, plan_steps, plan_hail, plan_weapon, plan_target, plan_amount, plan_add, plan_clear, plan_summary, plan_confirm, plan_cancel]},
		"defense": {"title": "Resolve attack / damage", "controls": [defense_steps, defense_picker, allocate_button, precision_skip]},
		"objectives": {"title": "Objective actions", "controls": [action_objective, action_button]},
		"phase": {"title": "Phase progression", "controls": [end_button]}}
	var position_index := details.get_index() + 1
	for key: String in definitions:
		var group := VBoxContainer.new()
		column.add_child(group)
		column.move_child(group, position_index)
		position_index += 1
		var heading := Label.new()
		heading.text = definitions[key].title
		heading.add_theme_color_override("font_color", Color("f2df83"))
		group.add_child(heading)
		var reason := Label.new()
		reason.custom_minimum_size.x = 400
		reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(reason)
		for control: Control in definitions[key].controls: control.reparent(group)
		action_groups[key] = {"container": group, "reason": reason, "controls": definitions[key].controls}
	column.move_child(action_groups.deployment.container, 0)
	column.move_child(action_groups.reaction.container, 0)

func _refresh_action_groups() -> void:
	if combat_enabled and state.phase == "army_selection":
		for group: Dictionary in action_groups.values(): group.container.visible = false
		return
	var exclusive := ""
	if combat_enabled:
		if state.phase == "deployment": exclusive = "deployment"
		elif not Combat.Stratagems.pending(state).is_empty(): exclusive = "reaction"
		elif not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): exclusive = "defense"
		elif not state.pending_move.is_empty() or coherency_button.visible: exclusive = "movement"
		elif not state.pending_contact.is_empty(): exclusive = "contact"
		elif not attack_draft.is_empty(): exclusive = "attack"
	for key: String in action_groups:
		var group: Dictionary = action_groups[key]
		var has_controls := false
		for control: Control in group.controls:
			if control.visible: has_controls = true
		group.container.visible = has_controls and (exclusive.is_empty() or exclusive == key)
		group.reason.text = ""
		group.reason.visible = false
		for control: Control in group.controls: control.tooltip_text = ""
	if not combat_enabled: return
	var common := ""
	if state.test_winner != 0: common = "The exercise is complete. Start another exercise in Match setup."
	elif mode == "host" and guest_id == 0: common = "Waiting for player 2 to connect."
	elif Combat.actor(state) != _local_player(): common = "Waiting for player %d to make this decision." % Combat.actor(state)
	if not common.is_empty():
		for key: String in action_groups:
			if action_groups[key].container.visible: _action_reason(key, common)
		return
	if state.phase == "deployment":
		_action_reason("deployment", Deployment.confirm_error(state))
		return
	if plan_begin.visible and plan_begin.disabled:
		_action_reason("attack", Combat.attack_window_error(state, _local_player(), selected, state.revision, state.phase == "fight"))
	if not attack_draft.is_empty():
		var reason := Combat.attack_plan_error(state, _local_player(), attack_draft.attacker, attack_draft.entries, attack_draft.revision, attack_draft.melee, lethal_choice.button_pressed, attack_draft.get("hail_target", -1))
		if not reason.is_empty(): _action_reason("attack", "Cannot confirm: " + reason)
		elif plan_add.disabled: _action_reason("attack", "To add an assignment, select a living model from this unit with a legal weapon target. The current plan can still be confirmed.")
	if begin_move_button.visible and begin_move_button.disabled:
		_action_reason("movement", Combat.movement_choice_error(state, _local_player(), selected, MOVE_TYPES[movement_choice.selected], state.revision))
	if finish_move_button.visible and finish_move_button.disabled:
		var reason := "The unit must end movement coherent and outside enemy engagement range."
		if escape_wound_button.visible: reason = "Allocate the remaining escape wounds before confirming movement."
		_action_reason("movement", reason)
	if coherency_button.visible and coherency_button.disabled:
		_action_reason("movement", "Select a living model from %s for the coherency removal." % state.squads[Combat.incoherent_squad(state)].name)
	if escape_wound_button.visible and escape_wound_button.disabled:
		_action_reason("movement", "Select a living model from the withdrawing unit to receive the escape wound.")
	if allocate_button.visible and allocate_button.disabled:
		var reason := Combat.Hazard.choice_error(state, _local_player(), selected) if not state.get("pending_hazard", {}).is_empty() else Combat.Allocation.choice_error(state, _local_player(), selected)
		if reason.is_empty(): reason = "Select a visible character for Precision, or use Do not use Precision."
		_action_reason("defense", reason)
	if action_button.visible and action_button.disabled:
		var reason := "Select your living model to choose an objective action."
		if state.units.has(selected) and state.units[selected].owner == _local_player() and state.units[selected].wounds > 0:
			reason = Combat.Actions.start_error(state, state.units[selected].squad, action_objective.get_selected_id())
		_action_reason("objectives", reason)
	if charge_button.visible and charge_button.disabled:
		var reason := "Select your living model to declare a charge."
		if state.units.has(selected) and state.units[selected].owner == _local_player() and state.units[selected].wounds > 0:
			var squad: Dictionary = state.squads[state.units[selected].squad]
			if squad.charge_declared: reason = "This unit has already declared a charge."
			elif squad.advanced: reason = "This unit Advanced and cannot declare a charge."
			elif squad.fell_back: reason = "This unit Fell Back and cannot declare a charge."
			elif Combat.Actions.charge_blocked(state, state.units[selected].squad): reason = "This unit started an action that prevents charging."
		_action_reason("contact", reason)
	if begin_contact_button.visible and begin_contact_button.disabled:
		var reason := "Select your living unit for the current contact step."
		if state.phase == "charge" and state.pending_charge.get("targets", []).is_empty(): reason = "Choose a charge target before beginning placement."
		elif state.phase == "fight" and state.units.has(selected) and state.units[selected].owner == _local_player() and state.units[selected].wounds > 0:
			var squad: int = state.units[selected].squad
			if squad not in Combat.FightQueue.choices(state, _local_player()): reason = "Select a unit in the current fight priority or reaction queue."
			elif state.squads[squad].fought: reason = "This unit has already fought."
			elif state.squads[squad].overrun_used: reason = "This unit has already used its overrun movement."
			elif not Combat._eligible_fighter(state, squad): reason = "This unit is not eligible to fight in the current step."
			elif Combat._engaged(state, squad) and state.squads[squad].was_engaged: reason = "This unit cannot use an overrun pile-in while already engaged."
		_action_reason("contact", reason)
	if end_button.disabled and action_groups.phase.container.visible:
		_action_reason("phase", end_button.text + ". Complete the required decision before advancing.")

func _action_reason(key: String, text: String) -> void:
	if text.is_empty(): return
	var group: Dictionary = action_groups[key]
	group.reason.text = text
	group.reason.visible = true
	for control: Control in group.controls:
		if control is BaseButton and control.disabled: control.tooltip_text = text

func _layout_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var sidebar_width := minf(480.0, maxf(440.0, viewport_size.x * 0.38))
	sidebar_panel.size = Vector2(sidebar_width, maxf(300, viewport_size.y - 32))
	guide_panel.visible = viewport_size.x >= sidebar_width + 400.0
	guide_panel.position = Vector2(maxf(sidebar_width + 32.0, viewport_size.x - 376.0), 16)

func _update_guides() -> void:
	if guides == null or guide_label == null: return
	if not guides.visible:
		guide_label.text = "Range guides hidden."
		return
	guides.rebuild(state, selected, combat_enabled, _local_player())
	_update_hover_guides()

func _update_hover_guides() -> void:
	if guides == null or guide_label == null or not guides.visible: return
	var hit: Variant = null
	if get_viewport().gui_get_hovered_control() == null:
		var mouse := get_viewport().get_mouse_position()
		var world: Variant = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
		if world != null: hit = Vector2(world.x, world.z)
	guides.preview(state, selected, combat_enabled, _local_player(), hit)
	guide_label.text = guides.caption + ("\n" + guides.hover_caption if not guides.hover_caption.is_empty() else "")

func _initial_state() -> Dictionary:
	if combat_enabled and saved_army_mode: return PreparedTraining.waiting({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts})
	if combat_enabled and prepared_match: return PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts})
	if combat_enabled and allocation_practice: return TestBattlefield.apply(AllocationPractice.initial_state(damage_rerolls, count_rerolls))
	return TestBattlefield.apply(Combat.initial_state(terrain_layout, mission_id, squads_per_side, manual_allocation, varied_equipment)) if combat_enabled else Rules.initial_state()

func _refresh_army_choices() -> void:
	if saved_army_pickers.is_empty(): return
	var presets := TrainingRoster.presets()
	for owner: int in saved_army_pickers:
		var picker: OptionButton = saved_army_pickers[owner]
		var previous := ""
		if picker.item_count > 0 and picker.get_selected_metadata() is Dictionary: previous = str(picker.get_selected_metadata().get("id", ""))
		picker.clear()
		picker.add_item("Player %d: choose a saved list" % owner)
		picker.set_item_metadata(0, {})
		for list: Dictionary in presets:
			var report := TrainingRoster.inspect(list)
			picker.add_item("P%d • %s • %d/500 pts" % [owner, list.name, report.total])
			picker.set_item_metadata(picker.item_count - 1, list.duplicate(true))
			if list.id == previous or (previous.is_empty() and list.faction == ("Space Marines" if owner == 1 else "Necrons") and report.selection.get("copies", 0) == 2): picker.select(picker.item_count - 1)
		for profile: Dictionary in army_builder.store.data.profiles:
			for list: Dictionary in profile.lists:
				picker.add_item("%s / %s" % [profile.name, list.name])
				picker.set_item_metadata(picker.item_count - 1, list.duplicate(true))
				if list.id == previous: picker.select(picker.item_count - 1)
	_review_saved_armies()

func _save_selected_army(owner: int) -> void:
	var list := _picked_army(owner)
	if list.is_empty(): return
	list.id = ""
	var result: Dictionary = army_builder.store.save_list(list)
	status.text = result.error if not result.error.is_empty() else "Copy saved to the active profile. Open Armies to edit it."
	army_builder._render_profiles()
	_refresh_army_choices()

func _prepare_local_models(force: bool = false) -> void:
	if auto_models == null or (not force and not auto_models.button_pressed): return
	var definitions: Array[String] = []
	for unit: Dictionary in state.get("units", {}).values():
		var definition := str(unit.get("definition_id", ""))
		if not definition.is_empty() and definition not in definitions: definitions.append(definition)
	model_imports.prepare_armies(definitions)

func _picked_army(owner: int) -> Dictionary:
	var picker: OptionButton = saved_army_pickers[owner]
	return picker.get_selected_metadata().duplicate(true) if picker.item_count > 0 and picker.get_selected_metadata() is Dictionary else {}

func _saved_army_report(owner: int) -> Dictionary:
	var list := _picked_army(owner)
	return {"error": "Choose a list for player %d." % owner} if list.is_empty() else TrainingRoster.inspect(list)

func _review_saved_armies() -> void:
	if saved_army_review == null: return
	var lines: Array[String] = ["Core-profile training: up to six units per player. Intercessors, Terminators and Immortals: 5 models; Warriors: 10. Only explicitly enabled unit abilities run; faction abilities and equipment notes are not executed. Insane Bravery is available only when prepared-match options are enabled."]
	for owner in [1, 2]:
		var report := _saved_army_report(owner)
		lines.append("P%d: %s" % [owner, report.error if not report.error.is_empty() else "%s • %d units • %d/%d local pack points (saved list: %d pts)" % [report.selection.faction, report.get("unit_count", report.selection.get("copies", 0)), report.total, report.selection.points_limit, report.saved_reference_points]])
	for owner in [1, 2]:
		var report := _saved_army_report(owner)
		if report.error.is_empty():
			for warning: String in report.get("warnings", []):
				if objective_secured_choice.button_pressed:
					warning = warning.replace("objective-secured, ", "").replace(", objective-secured", "")
				if implacable_eradication_choice.button_pressed:
					warning = warning.replace("implacable-eradication, ", "").replace(", implacable-eradication", "")
					if warning.ends_with(": implacable-eradication") or warning == "implacable-eradication": continue
				if hail_of_bolts_choice.button_pressed:
					warning = warning.replace("target-elimination, ", "").replace(", target-elimination", "")
					if warning.ends_with(": target-elimination") or warning == "target-elimination": continue
				lines.append("P%d • unavailable abilities: %s" % [owner, warning])
	if hail_of_bolts_choice.button_pressed: lines.append("Enabled: Intercessor Hail of Bolts; choose one visible enemy in the shooting plan for +2 bolt-rifle attacks against it.")
	if objective_secured_choice.button_pressed: lines.append("Enabled: Intercessor Objective Secured at the end of your Command phase.")
	if implacable_eradication_choice.button_pressed: lines.append("Enabled: Immortal Implacable Eradication training reference; successful wound rolls are kept.")
	lines.append("On LAN, each player submits only their own selection. Both computers must use the same allocation option.")
	saved_army_review.text = "\n".join(lines)

func _start_saved_match(local_match: bool = true) -> void:
	if mode != "local": return
	if not local_match and not saved_training_consent.button_pressed:
		status.text = "Review the scope and accept the partial training rules for LAN."
		return
	var selections: Dictionary = {}
	for owner in [1, 2]:
		if _picked_army(owner).is_empty() and not local_match: continue
		var report := _saved_army_report(owner)
		if not report.error.is_empty():
			status.text = report.error
			return
		selections[owner] = report.selection
	if selections.is_empty():
		status.text = "Select at least your saved list before enabling LAN."
		return
	var options := {"manual_allocation": defender_choice.button_pressed, "varied_equipment": false, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed}
	var candidate := PreparedTraining.initial_state(options, selections) if local_match else PreparedTraining.waiting(options)
	if candidate.has("error"):
		status.text = candidate.error
		return
	saved_army_mode = true
	core_stratagems = stratagem_choice.button_pressed
	movement_rerolls = reroll_choice.button_pressed
	attack_rerolls = attack_reroll_choice.button_pressed
	save_rerolls = save_reroll_choice.button_pressed
	damage_rerolls = damage_reroll_choice.button_pressed
	hazard_rerolls = hazard_reroll_choice.button_pressed
	escape_rerolls = escape_reroll_choice.button_pressed
	count_rerolls = count_reroll_choice.button_pressed
	objective_secured = objective_secured_choice.button_pressed
	implacable_eradication = implacable_eradication_choice.button_pressed
	hail_of_bolts = hail_of_bolts_choice.button_pressed
	prepared_match = true
	allocation_practice = false
	host_session = {}
	combat_enabled = true
	manual_allocation = defender_choice.button_pressed
	varied_equipment = false
	pending_armies = {}
	submitted_army = {}
	validated_saved_setup = ""
	state = candidate
	_reset_history()
	attack_draft = {}
	selected = -1
	_spawn_pieces()
	if local_match: _prepare_local_models()
	status.text = "Saved lists accepted for partial training. Confirm each unit's deployment." if local_match else "Saved-list LAN mode is active. Player 1: Host; player 2: Join. Each player must select their own list."
	_refresh()

func _connected_to_server() -> void:
	status.text = "Connected. Verifying session seat…"

func _submit_saved_army() -> void:
	if not saved_army_mode or state.get("phase", "") != "army_selection": return
	var owner := 2 if mode == "client" else 1
	var report := _saved_army_report(owner)
	if not report.error.is_empty():
		status.text = report.error
		return
	if mode == "client":
		submitted_army = report.selection
		request_saved_army.rpc_id(1, submitted_army)
	elif mode == "host":
		pending_armies[1] = report.selection
		_try_saved_armies()

@rpc("any_peer", "call_remote", "reliable")
func request_saved_army(selection: Dictionary) -> void:
	if mode != "host" or not saved_army_mode or multiplayer.get_remote_sender_id() != guest_id: return
	var report := TrainingRoster.admit(selection)
	if not report.error.is_empty():
		_feedback(2, report.error)
		return
	if state.phase != "army_selection":
		if state.has("saved_army_setup") and TrainingRoster.digest(report.selection) == TrainingRoster.digest(state.saved_army_setup.armies[2]): _broadcast()
		else: _feedback(2, "The list does not match this match's locked selection.")
		return
	pending_armies[2] = report.selection
	_try_saved_armies()

func _try_saved_armies() -> void:
	state.ready_armies = pending_armies.keys()
	if pending_armies.size() != 2:
		_broadcast()
		return
	var candidate := PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts}, pending_armies)
	if candidate.has("error"):
		_broadcast()
		status.text = candidate.error
		_feedback(2, candidate.error)
		return
	state = candidate
	_reset_history()
	selected = -1
	_spawn_pieces()
	_broadcast()
	status.text = "Both lists passed partial training validation. Deployment started."

func _start_prepared_match() -> void:
	if mode != "local": return
	var candidate := PreparedTraining.initial_state({"manual_allocation": defender_choice.button_pressed, "varied_equipment": equipment_choice.button_pressed, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed})
	if candidate.has("error"):
		status.text = candidate.error
		return
	host_session = {}
	combat_enabled = true
	saved_army_mode = false
	prepared_match = true
	allocation_practice = false
	core_stratagems = stratagem_choice.button_pressed
	movement_rerolls = reroll_choice.button_pressed
	attack_rerolls = attack_reroll_choice.button_pressed
	save_rerolls = save_reroll_choice.button_pressed
	damage_rerolls = damage_reroll_choice.button_pressed
	hazard_rerolls = hazard_reroll_choice.button_pressed
	escape_rerolls = escape_reroll_choice.button_pressed
	count_rerolls = count_reroll_choice.button_pressed
	objective_secured = objective_secured_choice.button_pressed
	implacable_eradication = implacable_eradication_choice.button_pressed
	hail_of_bolts = hail_of_bolts_choice.button_pressed
	manual_allocation = defender_choice.button_pressed
	varied_equipment = equipment_choice.button_pressed
	state = candidate
	_reset_history()
	attack_draft = {}
	selected = Combat.living(state, Deployment.current(state))[0]
	_spawn_pieces()
	status.text = "Custom prepared match. Deploy each unit, then play the five-round training mission. Official army legality is not validated."
	_refresh()

func _request_deployment_preset() -> void:
	if mode == "client": request_deployment_preset.rpc_id(1, state.revision)
	else: _apply_deployment(_local_player(), state.revision, false)

@rpc("any_peer", "call_remote", "reliable")
func request_deployment_preset(revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_deployment(2, revision, false)

func _apply_deployment(player: int, revision: int, confirm: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error := Deployment.confirm(state, player, revision) if confirm else Deployment.preset(state, player, revision)
	if not error.is_empty():
		_feedback(player, error)
		return
	if state.phase == "deployment": selected = Combat.living(state, Deployment.current(state))[0]
	_broadcast()
	_feedback(player, "Unit deployment confirmed." if confirm else "Preview positions accepted; confirm this unit when ready.")

func _start_allocation_practice() -> void:
	objective_secured = false
	implacable_eradication = false
	hail_of_bolts = false
	if mode != "local": return
	var candidate := TestBattlefield.apply(AllocationPractice.initial_state(damage_reroll_choice.button_pressed, count_reroll_choice.button_pressed))
	if candidate.has("error"):
		status.text = candidate.error
		return
	core_stratagems = damage_reroll_choice.button_pressed or count_reroll_choice.button_pressed
	movement_rerolls = false
	attack_rerolls = false
	save_rerolls = false
	damage_rerolls = damage_reroll_choice.button_pressed
	hazard_rerolls = false
	escape_rerolls = false
	count_rerolls = count_reroll_choice.button_pressed
	saved_army_mode = false
	prepared_match = false
	host_session = {}
	combat_enabled = true
	allocation_practice = true
	attack_draft = {}
	terrain_layout = Combat.Terrain.DEFAULT_LAYOUT
	mission_id = Combat.Objectives.TRAINING
	squads_per_side = 2
	manual_allocation = true
	varied_equipment = true
	defender_choice.button_pressed = true
	equipment_choice.button_pressed = true
	state = candidate
	_reset_history()
	selected = 100
	_spawn_pieces()
	status.text = "Synthetic rules lab: select model 100 to attack mixed defenders. Precision, Feel No Pain and random A/D are practice profiles, not an army loadout."
	if damage_rerolls or count_rerolls: status.text += " Random-characteristic re-roll enabled; each player starts with 2 CP in this lab."
	_refresh()

func _start_objectives(unit_count: int = 1) -> void:
	if mode != "local": return
	var candidate := TestBattlefield.apply(Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING, unit_count, defender_choice.button_pressed, equipment_choice.button_pressed))
	if candidate.has("error"):
		status.text = candidate.error
		return
	core_stratagems = false
	movement_rerolls = false
	attack_rerolls = false
	save_rerolls = false
	damage_rerolls = false
	hazard_rerolls = false
	escape_rerolls = false
	count_rerolls = false
	objective_secured = false
	implacable_eradication = false
	hail_of_bolts = false
	saved_army_mode = false
	prepared_match = false
	host_session = {}
	combat_enabled = true
	allocation_practice = false
	terrain_layout = Combat.Terrain.DEFAULT_LAYOUT
	mission_id = Combat.Objectives.TRAINING
	squads_per_side = unit_count
	manual_allocation = defender_choice.button_pressed
	varied_equipment = equipment_choice.button_pressed
	state = candidate
	_reset_history()
	selected = -1
	_spawn_pieces()
	status.text = "Custom training: 1 VP per controlled terrain objective at each round end; 5 rounds."
	_refresh()

func _toggle_combat(layout: String = Combat.Terrain.DEFAULT_LAYOUT) -> void:
	if mode != "local": return
	var next_terrain := terrain_layout if combat_enabled else layout
	var next_manual := manual_allocation if combat_enabled else defender_choice.button_pressed
	var next_varied := varied_equipment if combat_enabled else equipment_choice.button_pressed
	var candidate: Dictionary = Rules.initial_state() if combat_enabled else TestBattlefield.apply(Combat.initial_state(next_terrain, "elimination", 1, next_manual, next_varied))
	if candidate.has("error"):
		status.text = candidate.error + " Run tools/import_starter_factions.py as documented."
		return
	core_stratagems = false
	movement_rerolls = false
	attack_rerolls = false
	save_rerolls = false
	damage_rerolls = false
	hazard_rerolls = false
	escape_rerolls = false
	count_rerolls = false
	objective_secured = false
	implacable_eradication = false
	hail_of_bolts = false
	saved_army_mode = false
	prepared_match = false
	allocation_practice = false
	mission_id = "elimination"
	squads_per_side = 1
	terrain_layout = next_terrain
	manual_allocation = next_manual
	varied_equipment = next_varied
	host_session = {}
	combat_enabled = not combat_enabled
	state = candidate
	_reset_history()
	selected = -1
	_spawn_pieces()
	status.text = "Local combat exercise ready. Advance through Start turn and Command to move." if combat_enabled else "Local movement preview restored."
	_refresh()

func _button(parent: Node, title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _update_camera() -> void:
	camera.position = Vector3(sin(angle) * zoom, zoom * 0.85, cos(angle) * zoom)
	camera.look_at(pivot.position, Vector3.UP)

func _process(delta: float) -> void:
	if setup_notice != null and status != null:
		var notice := status.text
		if not autosave_error.is_empty() and state.get("phase") != "army_selection": notice += "\nFalha no autosave: " + autosave_error
		if setup_notice.text != notice: setup_notice.text = notice
	hover_time += delta
	if hover_time >= 0.05:
		hover_time = 0.0
		_update_hover_guides()
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return
	var direction := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W): direction.z -= 1
	if Input.is_physical_key_pressed(KEY_S): direction.z += 1
	if Input.is_physical_key_pressed(KEY_A): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D): direction.x += 1
	pivot.position += direction.rotated(Vector3.UP, angle) * delta * 12
	pivot.position.x = clampf(pivot.position.x, -15, 15)
	pivot.position.z = clampf(pivot.position.z, -10, 10)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		angle -= event.relative.x * 0.006
		_update_camera()
	if not event is InputEventMouseButton or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom = clampf(zoom + (-2 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 2), 10, 55)
		_update_camera()
		return
	var hit: Variant = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
	if hit == null:
		return
	var target := Vector2(hit.x, hit.z)
	if event.button_index == MOUSE_BUTTON_LEFT:
		selected = _pick_model(target)
		_refresh()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if combat_enabled and not state.pending_contact.is_empty():
			if mode == "client": request_contact_move.rpc_id(1, selected, target, state.revision)
			else: _apply_contact_move(_local_player(), selected, target, state.revision)
			return
		if combat_enabled and state.phase in ["shooting", "charge", "fight"]:
			var target_id := _pick_model(target)
			if not attack_draft.is_empty():
				if state.units.has(target_id):
					var index := plan_target.get_item_index(state.units[target_id].squad)
					if index >= 0:
						plan_target.select(index)
						_assign_attack()
				return
			if state.phase == "charge":
				if mode == "client": request_charge.rpc_id(1, target_id, state.revision)
				else: _apply_charge(_local_player(), target_id, state.revision)
			elif state.phase == "fight":
				if mode == "client": request_fight.rpc_id(1, selected, target_id, state.revision)
				else: _apply_fight(_local_player(), selected, target_id, state.revision)
			elif mode == "client": request_attack.rpc_id(1, selected, target_id, state.revision, lethal_choice.button_pressed)
			else: _apply_attack(_local_player(), selected, target_id, state.revision, lethal_choice.button_pressed)
			return
		if mode == "client":
			request_move.rpc_id(1, selected, target, int(state.get("revision", -1)))
		else:
			_apply_move(_local_player(), selected, target, int(state.get("revision", -1)))

func _pick_model(point: Vector2) -> int:
	var nearest := -1
	var closest := 1.0
	for id: int in state.units:
		if state.units[id].get("wounds", 1) <= 0: continue
		var distance: float = point.distance_to(state.units[id].position)
		if distance < closest:
			closest = distance
			nearest = id
	return nearest

func _local_player() -> int:
	return (Combat.actor(state) if combat_enabled else int(state.active)) if mode == "local" else (1 if mode == "host" else 2)

func _refresh_decision() -> void:
	if combat_enabled != ui_combat_enabled:
		match_tabs.current_tab = 1 if combat_enabled else 0
		ui_combat_enabled = combat_enabled
	objective_summary.visible = combat_enabled and Combat.Objectives.training(state) and state.phase != "army_selection"
	if objective_summary.visible:
		objective_summary.text = "CUSTOM TRAINING • VP %d / %d" % [state.mission.scores[1], state.mission.scores[2]]
		var objectives: Array[String] = []
		for objective: Dictionary in state.mission.get("objectives", []):
			objectives.append("%s: %s%s" % [objective.name, "neutral" if objective.controller == 0 else "P%d" % objective.controller, " (secured)" if objective.secured != 0 else ""])
		objective_summary.text += "\n" + " • ".join(objectives)
	if not combat_enabled:
		decision_label.text = "LOCAL PREVIEW • Choose a training exercise in Match setup to play."
		return
	if state.phase == "army_selection":
		match_tabs.current_tab = 0
		decision_label.text = "Choose lists for LAN training • received: %s\nSelect your list, then use Host / Join. If the budgets differ, update your selection and submit it again." % str(state.get("ready_armies", []))
		return
	if state.test_winner != 0:
		decision_label.text = "EXERCISE COMPLETE • " + ("Draw" if state.test_winner == -1 else "Player %d wins" % state.test_winner)
		return
	if mode == "host" and guest_id == 0:
		decision_label.text = "WAITING FOR PLAYER 2 • Both players must select the same exercise."
		return
	var actor := Combat.actor(state)
	var instruction := "Select a model to see its available actions below."
	if state.phase == "deployment":
		instruction = "Deploy %s: select each model and right-click inside your marked zone, or accept its preview positions. Then confirm the unit." % state.squads[Deployment.current(state)].name
	elif not Combat.Stratagems.pending(state).is_empty():
		instruction = "Battle-shock pending: choose a unit and roll, or use Insane Bravery (1 CP)." if Combat.Stratagems.pending(state).kind == "before_battle_shock" else "Decision pending: accept the roll or use Command Re-roll (1 CP) to continue."
	elif not state.get("pending_hazard", {}).is_empty():
		instruction = "Required: select an eligible model, then allocate Hazardous wounds."
	elif not state.get("pending_attack", {}).is_empty():
		match str(state.pending_attack.current.phase):
			"precision": instruction = "Choose a visible character for Precision, or choose Do not use Precision."
			"order": instruction = "Required: select a model from the next defense group, then confirm its allocation group."
			_: instruction = "Required: select an eligible model, then allocate the attack's damage."
	elif not state.get("pending_contact", {}).is_empty():
		instruction = "Place the unit's models, then confirm or cancel contact placement."
	elif state.phase == "end_turn" and Combat.incoherent_squad(state) != -1:
		instruction = "Required: remove models to restore unit coherency before ending the turn."
	var owner_text := "Player %d to act" % actor
	if mode != "local" and actor != _local_player(): owner_text = "Waiting for player %d" % actor
	decision_label.text = "Round %d • %s • %s\n%s" % [state.round, str(state.phase).replace("_", " ").capitalize(), owner_text, instruction]

func _refresh_selection_card() -> void:
	if not state.units.has(selected):
		selection_card.text = "No model selected • select a miniature on the battlefield."
		return
	var unit: Dictionary = state.units[selected]
	if not combat_enabled:
		selection_card.text = "Player %d • Model %d\n%s" % [unit.owner, selected, "Moved" if unit.moved else "Ready to move"]
		return
	var squad: Dictionary = state.squads[unit.squad]
	var living := 0
	for model: Dictionary in state.units.values():
		if model.squad == unit.squad and model.wounds > 0: living += 1
	selection_card.text = "%s • Player %d\n%d models alive • Model %d: %d/%d wounds" % [squad.name, unit.owner, living, selected, unit.wounds, unit.max_wounds]
	if "implacable-eradication" in squad.get("enabled_abilities", []): selection_card.text += "\nAbility: Implacable Eradication (reference)"
	if "hail-of-bolts" in squad.get("enabled_abilities", []): selection_card.text += "\nAbility: Hail of Bolts (select target in attack plan)"
	if "objective-secured" in squad.get("enabled_abilities", []): selection_card.text += "\nAbility: Objective Secured"
	if unit.wounds <= 0:
		selection_card.text += "\nDestroyed • select a living model to act."
		return
	var defense := Combat.Allocation.Groups.profile(state, selected)
	if defense.error.is_empty(): selection_card.text += "\nT%d • Sv%d+ • InSv%s" % [defense.toughness, defense.save_target, "—" if defense.invulnerable_target == 0 else "%d+" % defense.invulnerable_target]
	selection_card.text += "\n%s • OC %d" % ["Battle-shocked" if squad.battle_shocked else "Steady", Combat.Morale.objective_control(state, selected)]
	if not unit.get("feel_no_pain", []).is_empty(): selection_card.text += " • FNP " + Combat.Attacks.Prevention.describe(unit.feel_no_pain)
	if not squad.get("action", {}).is_empty(): selection_card.text += "\nSecure Ground in progress."
	if state.phase == "movement": selection_card.text += "\nMovement remaining: %.2f inches" % Combat.movement_remaining(state, selected)
	if state.get("rules_practice", false): selection_card.text += "\nSYNTHETIC RULES LAB • practice profiles"

func _refresh() -> void:
	if not attack_draft.is_empty() and (not combat_enabled or attack_draft.revision != state.revision or attack_draft.get("pack_hash") != state.get("pack_hash")): attack_draft = {}
	_sync_board()
	_sync_terrain()
	for id: int in pieces:
		var unit: Dictionary = state.units[id]
		pieces[id].visible = unit.get("wounds", 1) > 0
		pieces[id].position = Vector3(unit.position.x, 0.04 if pieces[id].get_meta("imported_visual", false) else 0.65, unit.position.y)
		var color := Color("52b9d1") if unit.owner == 1 else Color("e68d5c")
		if unit.moved: color = color.darkened(0.4)
		if combat_enabled and state.units.has(selected) and unit.squad == state.units[selected].squad: color = color.lightened(0.12)
		if id == selected: color = Color("f2df83")
		pieces[id].material_override = _material(color)
	session_label.text = "Mode: %s | UDP %d | You: %s" % [mode, PORT, "both sides" if mode == "local" else str(_local_player())]
	_refresh_decision()
	if combat_enabled and state.get("test_battlefield", "") == TestBattlefield.ID:
		session_label.text = "Incursion test • 1,000 points • 43 × 43 inches\n%s • Rosters not points-validated" % ("Local: both players" if mode == "local" else "%s: player %d" % [mode, _local_player()])
	if state.has("saved_army_setup"):
		session_label.text += "\nSaved-list training • %d-point limit • P1 %d / P2 %d local points\n43 × 43 inches • official list legality is not validated" % [state.points_limit, state.training_points[1], state.training_points[2]]
	elif state.has("match_manifest"): session_label.text += "\nPrepared custom mission • two units per side"
	if state.get("rules_practice", false): session_label.text += "\nSYNTHETIC RULES LAB • practice profiles"
	_refresh_selection_card()
	decision_details.text = ""
	details.text = "Turn %d • Player %d active\nSelected: %s" % [state.turn, state.active, str(selected) if selected >= 0 else "none"]
	if combat_enabled:
		details.text = "Round %d • Player %d • %s\nPlayer 1: %d models / Player 2: %d models\nCP: %d / %d" % [state.round, state.active, state.phase, Combat.living_owner(state, 1).size(), Combat.living_owner(state, 2).size(), state.cp[1], state.cp[2]]
		details.text += "\nDamage: " + ("defender choice" if state.get("manual_allocation", false) else "automatic allocation assist")
		if state.get("varied_equipment", false): details.text += "\nEquipment: curated varied training roster"
		if state.get("rules_practice", false): details.text += "\nSYNTHETIC RULES LAB • not an army loadout"
		var decision_start := details.text.length()
		if not state.get("pending_hazard", {}).is_empty():
			details.text += "\nPlayer %d: Hazardous • %d mortal wounds remaining\nHazard rolls: %s\nEligible models: %s" % [Combat.actor(state), state.pending_hazard.remaining, str(state.pending_hazard.resolved.hazardous.rolls), str(Combat.Hazard.eligible(state))]
		if not state.get("pending_attack", {}).is_empty():
			var current: Dictionary = state.pending_attack.current
			if current.phase in ["rolls", "save_decision", "damage_decision"]: details.text += "\nAttack paused before the next step: accept or choose a die for Command Re-roll."
			elif current.phase == "precision": details.text += "\nPlayer %d: choose a visible CHARACTER for Precision, or decline." % Combat.actor(state)
			elif current.phase == "order": details.text += "\nPlayer %d: choose the next allocation group. Select one of its models. Saves have not been rolled.\nGroups ordered: %d/%d" % [Combat.actor(state), current.order.size(), current.groups.size()]
			else:
				var step: Dictionary = current.steps[current.cursor]
				var source := "Devastating Wounds • no save" if step.kind == "devastating" else "Failed save %d" % step.save_roll
				details.text += "\nPlayer %d: allocate to %s\n%s • damage %s • %d remaining" % [Combat.actor(state), state.squads[current.target].name, source, str(current.damage), current.steps.size() - current.cursor]
				if current.damage is String: details.text += "\nDamage rolls after the recipient is selected."
			details.text += "\nEligible models: " + str(Combat.Allocation.eligible(state))
			if current.phase == "order":
				for group: Dictionary in current.groups: details.text += "\n%s %s • W%d • Sv%d+ • InSv%s" % ["Character" if group.character else "Group", str(group.models), group.profile.wounds_per_model, group.profile.save_target, "—" if group.profile.invulnerable_target == 0 else "%d+" % group.profile.invulnerable_target]
		decision_details.text = details.text.substr(decision_start).strip_edges()
		if state.units.has(selected):
			var unit: Dictionary = state.units[selected]
			if not unit.get("feel_no_pain", []).is_empty(): details.text += "\nFeel No Pain: " + Combat.Attacks.Prevention.describe(unit.feel_no_pain)
			if state.get("varied_equipment", false):
				var gear: Array[String] = []
				for melee in [false, true]:
					for option: Dictionary in Combat.AttackPlan.Equipment.choices(state, selected, melee): gear.append(option.label)
				details.text += "\nEquipped profiles: " + ", ".join(gear)
			details.text += "\n%s • selected model: %d/%d wounds" % [state.squads[unit.squad].name, unit.wounds, unit.max_wounds]
			var defense := Combat.Allocation.Groups.profile(state, selected)
			if defense.error.is_empty(): details.text += "\nT%d • Sv%d+ • InSv%s" % [defense.toughness, defense.save_target, "—" if defense.invulnerable_target == 0 else "%d+" % defense.invulnerable_target]
			details.text += "\n%s • OC %d" % ["Battle-shocked" if state.squads[unit.squad].battle_shocked else "Steady", Combat.Morale.objective_control(state, selected)]
			var squad_action: Dictionary = state.squads[unit.squad].get("action", {})
			if not squad_action.is_empty(): details.text += "\nSecure Ground: in progress; completes at end of turn."
			elif not state.squads[unit.squad].get("last_action", {}).is_empty():
				var last: Dictionary = state.squads[unit.squad].last_action
				details.text += "\nLast action: " + last.status + (" • " + last.reason if last.has("reason") else "")
			if Combat.Actions.charge_blocked(state, unit.squad): details.text += "\nAction started this turn: no charge" + (", no shooting." if Combat.Actions.shooting_blocked(state, unit.squad) else ".")
			if not Combat.Terrain.legacy(state):
				var names: Array[String] = []
				for area: Dictionary in Combat.Terrain.model_areas(state, selected): names.append(area.name)
				details.text += "\nTerrain: %s • %s" % [", ".join(names) if not names.is_empty() else "none", "Hidden" if Combat.Terrain.hidden(state, selected) else "Not hidden"]
			if state.phase == "movement": details.text += "\nModel %d: %.2f inches remaining" % [selected, Combat.movement_remaining(state, selected)]
			if state.squads[unit.squad].moved: details.text += "\nResolved move: %s" % state.squads[unit.squad].move_type.replace("_", " ")
		if Combat.Objectives.training(state):
			details.text += "\nCUSTOM TRAINING • VP %d / %d • 5 rounds" % [state.mission.scores[1], state.mission.scores[2]]
			for objective: Dictionary in state.mission.objectives:
				details.text += "\n%s: %s • OC %d/%d%s" % [objective.name, "neutral" if objective.controller == 0 else "P%d" % objective.controller, objective.levels[1], objective.levels[2], " secured" if objective.secured != 0 else ""]
		if state.test_winner != 0: details.text += "\nExercise finished: " + ("draw" if state.test_winner == -1 else "player %d wins" % state.test_winner)
		var queue_start := details.text.length()
		if state.phase == "fight": details.text += "\nFight: %s • player %d acts • %s" % [state.fight_step, Combat.actor(state), state.fight_priority]
		if state.phase == "fight" and state.fight_step != "complete":
			var names: Array[String] = []
			for squad: int in Combat.FightQueue.choices(state, Combat.actor(state)): names.append("%d: %s" % [squad, state.squads[squad].name])
			details.text += "\nEligible units: " + ", ".join(names)
			if not state.get("reaction_queue", []).is_empty(): details.text += "\nMandatory reactions: " + str(state.reaction_queue)
		if not state.pending_charge.is_empty(): details.text += "\nCharge rolled %d inches: choose target." % state.pending_charge.maximum
		if not state.pending_charge.is_empty():
			var target_names: Array[String] = []
			for target_squad: int in state.pending_charge.get("targets", []): target_names.append(state.squads[target_squad].name)
			details.text += "\nCharge targets: " + (", ".join(target_names) if not target_names.is_empty() else "none — right-click enemies to select")
		if not state.pending_contact.is_empty():
			details.text += "\nPlacing: %s" % state.pending_contact.kind.replace("_", " ")
			if state.pending_contact.origins.has(selected): details.text += " • %.2f inches left" % Combat.ContactActions.remaining(state, selected)
		if not state.pending_move.is_empty():
			details.text += "\nSelected move: %s" % state.pending_move.move_type.replace("_", " ")
			if state.pending_move.bonus > 0: details.text += " • Advance +%d inches" % state.pending_move.bonus
			if state.pending_move.hazard_remaining > 0: details.text += "\nAllocate %d escape mortal wounds before moving." % state.pending_move.hazard_remaining
		if state.phase == "end_turn" and Combat.incoherent_squad(state) != -1:
			details.text += "\nPlayer %d: select a model to remove from the incoherent squad." % Combat.actor(state)
		decision_details.text += details.text.substr(queue_start)
	decision_details.text = "\n".join(Array(decision_details.text.split("\n")).filter(func(line: String): return not line.begins_with("Hazard rolls:"))).strip_edges()
	decision_details.visible = not decision_details.text.is_empty()
	scope_label.text = "COMBAT INTEGRATION EXERCISE — partial 11e. " + str(state.get("scope", Combat.DISABLED)) if combat_enabled else "Movement demo — use the combat exercise for persistent shooting."
	combat_button.text = "Return to movement demo" if combat_enabled else "Start 3D combat exercise: Marines / Necrons"
	combat_button.disabled = mode != "local"
	objective_button.disabled = mode != "local"
	multi_button.disabled = mode != "local"
	defender_choice.disabled = mode != "local"
	equipment_choice.disabled = mode != "local"
	stratagem_choice.disabled = mode != "local"
	reroll_choice.disabled = mode != "local"
	attack_reroll_choice.disabled = mode != "local"
	save_reroll_choice.disabled = mode != "local"
	damage_reroll_choice.disabled = mode != "local"
	hazard_reroll_choice.disabled = mode != "local"
	escape_reroll_choice.disabled = mode != "local"
	count_reroll_choice.disabled = mode != "local"
	lethal_choice.visible = combat_enabled and state.phase == "shooting"
	charge_button.visible = combat_enabled and state.phase == "charge"
	var pending_move: bool = combat_enabled and not state.pending_move.is_empty()
	finish_move_button.visible = pending_move
	cancel_move_button.visible = pending_move
	var can_act: bool = not combat_enabled or (Combat.actor(state) == _local_player() and state.test_winner == 0 and not (mode == "host" and guest_id == 0))
	var deploying: bool = combat_enabled and state.phase == "deployment"
	prepared_button.disabled = mode != "local"
	saved_training_consent.disabled = mode != "local"
	for owner: int in saved_army_pickers:
		saved_army_pickers[owner].disabled = mode != "local" and (not saved_army_mode or state.phase != "army_selection" or owner != _local_player())
	deployment_help.visible = deploying
	deployment_preset_button.visible = deploying
	deployment_confirm_button.visible = deploying
	deployment_preset_button.disabled = not can_act
	deployment_confirm_button.disabled = not can_act or (deploying and not Deployment.confirm_error(state).is_empty())
	if deploying:
		var squad := Deployment.current(state)
		var placed := 0
		for id: int in Combat.living(state, squad):
			if state.deployment.placed.has(id): placed += 1
		deployment_help.text = "Custom setup • P1 left / P2 right\n%s: %d/%d models placed\nUnplaced miniatures show preview positions only. No distance limit during setup. Confirming locks the unit's deployment." % [state.squads[squad].name, placed, Combat.living(state, squad).size()]
	var previous_action_target := action_objective.get_selected_id()
	action_objective.clear()
	action_button.visible = combat_enabled and Combat.Objectives.training(state) and state.phase == "shooting"
	action_objective.visible = action_button.visible
	action_button.disabled = true
	if action_button.visible and state.units.has(selected):
		var squad: int = state.units[selected].squad
		for index: int in Combat.Actions.targets(state, squad): action_objective.add_item("Secure: " + state.mission.objectives[index].name, index)
		var old_index := action_objective.get_item_index(previous_action_target)
		if old_index >= 0: action_objective.select(old_index)
		action_button.disabled = not can_act or state.units[selected].owner != _local_player() or state.units[selected].wounds <= 0 or not Combat.Actions.start_error(state, squad, action_objective.get_selected_id()).is_empty()
		action_button.tooltip_text = Combat.Actions.start_error(state, squad, action_objective.get_selected_id())
	action_objective.disabled = not can_act
	var pending_contact: bool = combat_enabled and not state.pending_contact.is_empty()
	var previous_enemy := contact_enemy.get_selected_id()
	contact_enemy.clear()
	contact_enemy.visible = false
	if combat_enabled and state.phase == "fight" and state.fight_step != "complete" and not pending_contact and state.units.has(selected):
		var squad: int = state.units[selected].squad
		if not Combat._engaged(state, squad):
			var distance := 3.0 if state.fight_step == "consolidate" else 5.0
			for enemy: int in Combat.ContactActions.enemies(state, squad, distance): contact_enemy.add_item("Contact target: " + state.squads[enemy].name, enemy)
			contact_enemy.visible = contact_enemy.item_count > 0
			var old_index := contact_enemy.get_item_index(previous_enemy)
			if old_index >= 0: contact_enemy.select(old_index)
	contact_enemy.disabled = not can_act
	begin_contact_button.visible = combat_enabled and not pending_contact and ((state.phase == "charge" and not state.pending_charge.is_empty()) or (state.phase == "fight" and state.fight_step != "complete"))
	var previous_objective := consolidation_objective.get_selected_id()
	consolidation_objective.clear()
	consolidation_objective.visible = false
	if combat_enabled and state.phase == "fight" and state.fight_step == "consolidate" and not pending_contact and state.units.has(selected):
		var squad: int = state.units[selected].squad
		if Combat.ContactActions.enemies(state, squad, 3.0).is_empty():
			for index: int in Combat.Objectives.consolidation_candidates(state, squad):
				consolidation_objective.add_item("Objective: " + state.mission.objectives[index].name, index)
			consolidation_objective.visible = consolidation_objective.item_count > 0
			var previous_index := consolidation_objective.get_item_index(previous_objective)
			if previous_index >= 0: consolidation_objective.select(previous_index)
	consolidation_objective.disabled = not can_act
	begin_contact_button.text = "Begin charge placement" if combat_enabled and state.phase == "charge" else "Begin pile-in" if combat_enabled and state.fight_step == "pile_in" else "Begin consolidation" if combat_enabled and state.fight_step == "consolidate" else "Begin overrun pile-in"
	begin_contact_button.disabled = not can_act or not state.units.has(selected)
	if state.units.has(selected): begin_contact_button.disabled = not can_act or state.units[selected].wounds <= 0 or state.units[selected].owner != _local_player()
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.fight_step in ["attacks", "consolidation_reaction"]:
		var squad: int = state.units[selected].squad
		if state.squads[squad].fought or state.squads[squad].overrun_used or not Combat._eligible_fighter(state, squad) or (Combat._engaged(state, squad) and state.squads[squad].was_engaged): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.units[selected].squad not in Combat.FightQueue.choices(state, _local_player()): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "charge" and state.pending_charge.get("targets", []).is_empty(): begin_contact_button.disabled = true
	confirm_contact_button.visible = pending_contact
	cancel_contact_button.visible = pending_contact
	cancel_contact_button.text = "Cancel contact placement (retain charge roll)" if pending_contact and state.pending_contact.kind == "charge" else "Cancel contact placement"
	confirm_contact_button.disabled = not can_act
	cancel_contact_button.disabled = not can_act
	movement_choice.visible = combat_enabled and state.phase == "movement" and not pending_move
	begin_move_button.visible = movement_choice.visible
	begin_move_button.disabled = not can_act
	if begin_move_button.visible:
		begin_move_button.disabled = not can_act or not Combat.movement_choice_error(state, _local_player(), selected, MOVE_TYPES[movement_choice.selected], state.revision).is_empty()
	movement_choice.disabled = not can_act
	escape_wound_button.visible = pending_move and state.pending_move.hazard_remaining > 0
	escape_wound_button.disabled = not can_act or not state.units.has(selected)
	if escape_wound_button.visible and state.units.has(selected):
		escape_wound_button.disabled = not can_act or state.units[selected].wounds <= 0 or state.units[selected].squad != state.pending_move.squad
	finish_move_button.disabled = not can_act
	cancel_move_button.disabled = not can_act
	cancel_move_button.text = "Reset placement (retain dice and casualties)" if pending_move and state.pending_move.locked else "Cancel pending movement"
	if pending_move and (not Combat.Contact.coherent(state, state.pending_move.squad) or Combat._engaged(state, state.pending_move.squad)): finish_move_button.disabled = true
	if escape_wound_button.visible: finish_move_button.disabled = true
	abandon_move_button.visible = pending_move and state.pending_move.move_type in ["ordered_retreat", "desperate_escape"]
	abandon_move_button.disabled = not can_act or escape_wound_button.visible
	coherency_button.visible = combat_enabled and state.phase == "end_turn" and Combat.incoherent_squad(state) != -1
	coherency_button.disabled = not can_act or not state.units.has(selected)
	if coherency_button.visible and state.units.has(selected):
		coherency_button.disabled = not can_act or state.units[selected].wounds <= 0 or state.units[selected].squad != Combat.incoherent_squad(state)
	charge_button.text = "Finish pending charge without moving" if combat_enabled and not state.pending_charge.is_empty() else "Roll charge for selected squad (2D6)"
	charge_button.disabled = combat_enabled and (Combat.actor(state) != _local_player() or state.test_winner != 0 or (mode == "host" and guest_id == 0))
	if combat_enabled and state.pending_charge.is_empty():
		if not state.units.has(selected) or state.units[selected].get("wounds", 0) <= 0 or state.units[selected].owner != _local_player():
			charge_button.disabled = true
		elif state.squads[state.units[selected].squad].charge_declared or state.squads[state.units[selected].squad].advanced or state.squads[state.units[selected].squad].fell_back or Combat.Actions.charge_blocked(state, state.units[selected].squad):
			charge_button.disabled = true
	end_button.text = "Advance phase" if combat_enabled else "End turn"
	if combat_enabled and state.phase == "command": end_button.text = "Resolve battle-shock / advance"
	if combat_enabled and state.phase == "fight":
		end_button.text = "Decline optional pile-in" if state.fight_step == "pile_in" else "Decline optional consolidation" if state.fight_step == "consolidate" else "Advance fight step / phase"
	log_toggle.visible = combat_enabled
	event_log.visible = combat_enabled and log_toggle.button_pressed
	_refresh_result_summary()
	if combat_enabled:
		var log_text := ""
		for entry: Dictionary in state.events: log_text += entry.message + "\n"
		if state.has("last_attack"):
			var hazard: Dictionary = state.last_attack.get("hazardous", {})
			if not hazard.get("rolls", []).is_empty():
				log_text += "Hazardous: %s • %d mortal wounds • recipients %s\n" % [str(hazard.rolls), hazard.total, str(hazard.allocations)]
				for prevention: Dictionary in hazard.get("prevention", []):
					if prevention.target > 0: log_text += "Feel No Pain: %d+ %s • %d prevented\n" % [prevention.target, str(prevention.rolls), prevention.prevented]
			for pool: Dictionary in state.last_attack.pools:
				if pool.has("target_squad"): log_text += "Target: %s • %d attacks\n" % [state.squads[pool.target_squad].name, pool.attacks]
				if pool.has("weapon_name"): log_text += pool.weapon_name + "\n"
				if pool.get("precision_model", -1) >= 0: log_text += "Precision: selected character %d\n" % pool.precision_model
				if pool.get("allocation_groups", []).size() > 1:
					var order: Array[String] = []
					for index: int in pool.allocation_order: order.append(str(pool.allocation_groups[index].models))
					log_text += "Allocation groups: " + " → ".join(order) + "\n"
				if pool.get("hit_modifier", 0) != 0: log_text += "Hit modifier: %+d\n" % pool.hit_modifier
				for prevention: Dictionary in pool.get("prevention_rolls", []):
					if prevention.target > 0: log_text += "Feel No Pain: %d+ %s • %d prevented\n" % [prevention.target, str(prevention.rolls), prevention.prevented]
				if pool.get("devastating_wounds", 0) > 0: log_text += "Devastating Wounds: %d critical wounds • %d mortal damage • %d normal damage\n" % [pool.devastating_wounds, pool.mortal_damage_applied, pool.normal_damage_applied]
				for generated: Dictionary in pool.get("attack_generation", []):
					if generated.expression is String or generated.bonus > 0: log_text += "A %s: %s + %d = %d\n" % [str(generated.expression), str(generated.value), generated.bonus, generated.total]
				for damage: Dictionary in pool.get("damage_rolls", []):
					if damage.expression is String: log_text += "D %s: %s = %d\n" % [str(damage.expression), str(damage.rolls), damage.value]
				if pool.get("benefit_of_cover", false): log_text += "Cover: BS worsened to %d+.\n" % pool.effective_skill
				log_text += "Dice: hit %s / wound %s / save %s\n" % [str(pool.hit_rolls), str(pool.wound_rolls), str(pool.save_rolls)]
		if event_log.text != log_text:
			event_log.text = log_text
			event_log.scroll_to_line(maxi(0, event_log.get_line_count() - 1))
	host_button.disabled = mode != "local"
	join_button.disabled = mode != "local"
	end_button.disabled = mode != "local" and (_local_player() != (Combat.actor(state) if combat_enabled else state.active) or (mode == "host" and guest_id == 0))
	if combat_enabled and not state.pending_charge.is_empty(): end_button.disabled = true
	if pending_move: end_button.disabled = true
	if pending_contact:
		end_button.text = "Confirm or cancel contact placement first"
		end_button.disabled = true
	if coherency_button.visible:
		end_button.text = "Resolve coherency casualties first"
		end_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.fight_step in ["attacks", "consolidation_reaction"] and not pending_contact:
		var options := Combat.FightQueue.choices(state, Combat.actor(state))
		var squad: int = state.units[selected].squad if state.units.has(selected) else -1
		if squad not in options and options.size() == 1: squad = options[0]
		if squad in options and Combat._engaged(state, squad):
			end_button.text = "Required melee: select eligible unit, right-click enemy"
			end_button.disabled = true
	if combat_enabled and state.test_winner != 0: end_button.disabled = true
	if combat_enabled and state.phase == "army_selection": end_button.disabled = true
	if not Combat.Stratagems.pending(state).is_empty(): end_button.disabled = true
	_refresh_command_reaction()
	_refresh_attack_plan()
	var hazard_pending: bool = combat_enabled and not state.get("pending_hazard", {}).is_empty()
	var allocating: bool = combat_enabled and Combat.Stratagems.pending(state).is_empty() and (hazard_pending or not state.get("pending_attack", {}).is_empty())
	allocate_button.visible = allocating
	allocate_button.text = "Allocate one Hazardous mortal wound to selected model" if hazard_pending else "Allocate next damaging attack to selected model"
	var precision_pending: bool = allocating and not hazard_pending and state.pending_attack.current.phase == "precision"
	precision_skip.visible = precision_pending
	precision_skip.disabled = not can_act
	if precision_pending: allocate_button.text = "Direct Precision to selected character"
	elif allocating and not hazard_pending:
		if state.pending_attack.current.phase == "order": allocate_button.text = "Choose selected model's allocation group next"
		elif state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": allocate_button.text = "Allocate Devastating Wounds to selected model"
	allocate_button.disabled = not allocating or not can_act or not (Combat.Hazard.choice_error(state, _local_player(), selected) if hazard_pending else Combat.Allocation.choice_error(state, _local_player(), selected)).is_empty()
	if precision_pending and selected < 0: allocate_button.disabled = true
	if allocating:
		for control in [end_button, charge_button, begin_contact_button, begin_move_button, action_button, plan_begin, plan_confirm, coherency_button, escape_wound_button, abandon_move_button, finish_move_button, cancel_move_button, confirm_contact_button, cancel_contact_button]: control.disabled = true
	_refresh_defense_steps(allocating, hazard_pending)
	_refresh_action_groups()
	_update_guides()

func _refresh_result_summary() -> void:
	result_summary.visible = combat_enabled and state.has("last_attack")
	if not result_summary.visible:
		result_summary.text = ""
		return
	var last: Dictionary = state.last_attack
	result_summary.text = "Last completed attack"
	if not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): result_summary.text += " • another attack is pending"
	result_summary.text += "\n" + str(last.get("message", ""))
	var targets: Dictionary = {}
	var prevented := 0
	var discarded := 0
	for pool: Dictionary in last.get("pools", []):
		var target_id: int = pool.get("target_squad", -1)
		if not targets.has(target_id): targets[target_id] = {"attacks": 0, "damage": 0, "destroyed": 0}
		targets[target_id].attacks += int(pool.get("attacks", 0))
		targets[target_id].damage += int(pool.get("damage_applied", 0))
		targets[target_id].destroyed += int(pool.get("models_destroyed", 0))
		prevented += int(pool.get("prevented_wounds", 0))
		discarded += int(pool.get("excess_damage_discarded", 0))
	for target_id: int in targets:
		var target_name: String = state.squads[target_id].name if state.squads.has(target_id) else "Target"
		var totals: Dictionary = targets[target_id]
		result_summary.text += "\n%s: %d attacks • %d damage applied • %d models destroyed" % [target_name, totals.attacks, totals.damage, totals.destroyed]
	if prevented > 0: result_summary.text += "\nFeel No Pain: %d wounds prevented" % prevented
	if discarded > 0: result_summary.text += "\nExcess damage discarded: %d" % discarded
	var hazard: Dictionary = last.get("hazardous", {})
	if int(hazard.get("total", 0)) > 0:
		var hazard_lost := 0
		var hazard_prevented := 0
		for prevention: Dictionary in hazard.get("prevention", []):
			hazard_lost += int(prevention.get("lost", 0))
			hazard_prevented += int(prevention.get("prevented", 0))
		result_summary.text += "\nHazardous (attacking unit): %d wounds lost • %d prevented" % [hazard_lost, hazard_prevented]
		if int(hazard.get("discarded", 0)) > 0: result_summary.text += " • %d unallocated wounds discarded" % hazard.discarded

func _model_choice_label(model: int) -> String:
	var unit: Dictionary = state.units[model]
	return "%s • Model %d • %d/%d wounds" % [state.squads[unit.squad].name, model, unit.wounds, unit.max_wounds]

func _refresh_defense_steps(allocating: bool, hazard: bool) -> void:
	defense_steps.visible = allocating
	defense_picker.visible = allocating
	defense_picker.clear()
	if not allocating: return
	defense_picker.add_item("Choose an eligible model…", -1)
	# OptionButton auto-assigns -1 IDs; explicitly set the prompt's sentinel.
	defense_picker.set_item_id(0, -1)
	var eligible: Array[int] = Combat.Hazard.eligible(state) if hazard else Combat.Allocation.eligible(state)
	for model: int in eligible:
		defense_picker.add_item(_model_choice_label(model), model)
		if model == selected: defense_picker.select(defense_picker.item_count - 1)
	defense_picker.disabled = Combat.actor(state) != _local_player() or (mode == "host" and guest_id == 0)
	var stage := "Allocate Hazardous wounds" if hazard else str(state.pending_attack.current.phase)
	var instruction := "Choose the recipient, then confirm one damaging attack."
	if stage == "precision":
		stage = "1 • Optional Precision"
		instruction = "Attacker: choose a visible character and confirm, or decline Precision."
	elif stage == "order":
		stage = "2 • Defense group order"
		instruction = "Defender: choose a model from the next group. Confirm each group before saves are rolled."
	elif not hazard:
		stage = "3 • Allocate damage"
		if state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": instruction = "Choose the recipient for Devastating Wounds. This packet allows no save."
	else: instruction = "Choose the recipient, then confirm one Hazardous mortal wound."
	defense_steps.text = "%s\nPlayer %d decides. %s" % [stage, Combat.actor(state), instruction]
	defense_steps.text += "\nSelected: " + (_model_choice_label(selected) if selected in eligible else "no eligible model")
	if not hazard: defense_steps.text += "\nTarget unit: " + state.squads[state.pending_attack.current.target].name

func _request_allocate_damage() -> void:
	if not combat_enabled: return
	if mode == "client": request_allocate_damage.rpc_id(1, selected, state.revision)
	else: _apply_allocate_damage(_local_player(), selected, state.revision)

func _request_skip_precision() -> void:
	if not combat_enabled: return
	if mode == "client": request_allocate_damage.rpc_id(1, -1, state.revision)
	else: _apply_allocate_damage(_local_player(), -1, state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_allocate_damage(model: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_allocate_damage(2, model, revision)

func _apply_allocate_damage(player: int, model: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error := Combat.allocate_hazard(state, player, model, revision, _d6) if not state.get("pending_hazard", {}).is_empty() else Combat.allocate_damage(state, player, model, revision, _d6)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	if Combat.Stratagems.pending(state).get("kind") == "after_damage_roll":
		_feedback(player, "Recipient confirmed. The attacker resolves damage before prevention and casualties.")
	else: _feedback(player, "Damage choice accepted; continue allocation or the next action window.")

func _begin_attack_plan() -> void:
	if not combat_enabled or not state.units.has(selected): return
	var melee: bool = state.phase == "fight"
	var error := Combat.attack_window_error(state, _local_player(), selected, state.revision, melee)
	if not error.is_empty():
		status.text = error
		return
	attack_draft = {"squad": state.units[selected].squad, "attacker": selected, "melee": melee, "revision": state.revision, "pack_hash": state.pack_hash, "entries": []}
	_refresh()

func _assign_attack() -> void:
	if attack_draft.is_empty() or not state.units.has(selected) or state.units[selected].squad != attack_draft.squad or plan_target.get_selected_id() < 0: return
	var target := plan_target.get_selected_id()
	var choice := _plan_weapon_choice()
	if choice.is_empty(): return
	var equipped := Combat.AttackPlan.Equipment.explicit_loadout(state, selected, attack_draft.melee)
	# Assignment replaces this model/target row; other melee targets are retained.
	var entries: Array = []
	for entry: Dictionary in attack_draft.entries:
		if entry.model == selected:
			if equipped:
				if attack_draft.melee:
					var previous := Combat.AttackPlan.Equipment.select(state, selected, true, entry.get("weapon", ""), entry.get("profile", ""))
					if previous.has("error"): continue
					if entry.get("weapon", "") == choice.weapon and entry.get("profile", "") != choice.profile: continue
					if not Combat.AttackPlan.Traits.extra(choice.stats) and not Combat.AttackPlan.Traits.extra(previous.stats) and entry.get("weapon", "") != choice.weapon: continue
				if entry.get("weapon", "") == choice.weapon and (not attack_draft.melee or entry.target == target): continue
			elif not attack_draft.melee or entry.target == target: continue
		entries.append(entry)
	var row := {"model": selected, "target": target, "amount": int(plan_amount.value) if attack_draft.melee else 1}
	if equipped:
		row.weapon = choice.weapon
		row.profile = choice.profile
	entries.append(row)
	attack_draft.entries = entries
	_refresh()

func _clear_attack_model() -> void:
	if attack_draft.is_empty(): return
	var entries: Array = []
	for entry: Dictionary in attack_draft.entries:
		if entry.model != selected: entries.append(entry)
	attack_draft.entries = entries
	_refresh()

func _confirm_attack_plan() -> void:
	if attack_draft.is_empty(): return
	var draft := attack_draft.duplicate(true)
	if mode == "client": request_attack_plan.rpc_id(1, draft.attacker, draft.entries, draft.revision, draft.melee, lethal_choice.button_pressed, draft.get("hail_target", -1))
	else: _apply_attack_plan(_local_player(), draft.attacker, draft.entries, draft.revision, draft.melee, lethal_choice.button_pressed, draft.get("hail_target", -1))

func _refresh_attack_plan() -> void:
	var editing := not attack_draft.is_empty()
	plan_begin.visible = combat_enabled and state.phase in ["shooting", "fight"] and not editing
	plan_begin.disabled = true
	if plan_begin.visible: plan_begin.disabled = not Combat.attack_window_error(state, _local_player(), selected, state.revision, state.phase == "fight").is_empty() or (mode == "host" and guest_id == 0)
	for control in [plan_steps, plan_hail, plan_weapon, plan_target, plan_amount, plan_add, plan_clear, plan_summary, plan_confirm, plan_cancel]: control.visible = editing
	if not editing: return
	plan_hail.visible = not attack_draft.melee and Combat.HailOfBolts.available(state, attack_draft.squad)
	plan_hail.clear()
	plan_hail.add_item("Hail of Bolts: do not use", 0)
	if plan_hail.visible:
		for target: int in Combat.HailOfBolts.targets(state, attack_draft.squad): plan_hail.add_item("Hail of Bolts: " + state.squads[target].name, target)
	plan_hail.select(maxi(0, plan_hail.get_item_index(attack_draft.get("hail_target", -1))))
	end_button.disabled = true
	begin_contact_button.disabled = true
	action_button.disabled = true
	var previous_target := plan_target.get_selected_id()
	var previous_weapon := _plan_weapon_choice()
	plan_weapon.clear()
	plan_target.clear()
	var own_model: bool = state.units.has(selected) and state.units[selected].squad == attack_draft.squad and state.units[selected].wounds > 0
	if own_model:
		for option: Dictionary in Combat.AttackPlan.Equipment.choices(state, selected, attack_draft.melee):
			plan_weapon.add_item(option.label)
			var index := plan_weapon.item_count - 1
			plan_weapon.set_item_metadata(index, option)
			if index == 0: plan_weapon.select(0)
			if option.weapon == previous_weapon.get("weapon", "") and option.profile == previous_weapon.get("profile", ""): plan_weapon.select(index)
		var choice := _plan_weapon_choice()
		if not choice.is_empty():
			for target: int in Combat.AttackPlan.legal_targets(state, selected, attack_draft.melee, choice.weapon, choice.profile): plan_target.add_item("Target: " + state.squads[target].name, target)
		var index := plan_target.get_item_index(previous_target)
		if index >= 0: plan_target.select(index)
		elif plan_target.item_count > 0: plan_target.select(0)
	plan_amount.visible = editing and attack_draft.melee
	var selected_weapon := _plan_weapon_choice()
	if attack_draft.melee and not selected_weapon.is_empty() and selected_weapon.stats.attacks is String: plan_amount.visible = false
	plan_amount.max_value = selected_weapon.stats.attacks if attack_draft.melee and not selected_weapon.is_empty() and not selected_weapon.stats.attacks is String else 1
	plan_add.disabled = not own_model or plan_target.item_count == 0
	plan_clear.disabled = not own_model
	plan_steps.text = "1 • Select a living model from %s.\nSelected: %s\n2 • Choose weapon/profile, target%s.\n3 • Assign; repeat for the other models/weapons.\n4 • Review the plan and confirm to roll dice. Cancel discards this draft." % [state.squads[attack_draft.squad].name, _model_choice_label(selected) if own_model else "no model from the attacking unit", " and attack count" if attack_draft.melee else ""]
	var target_order: Array[int] = []
	var target_names: Array[String] = []
	for entry: Dictionary in attack_draft.entries:
		if entry.target not in target_order:
			target_order.append(entry.target)
			target_names.append(state.squads[entry.target].name)
	plan_steps.text += "\nReview: %d assignments • %d target units" % [attack_draft.entries.size(), target_order.size()]
	if not target_names.is_empty(): plan_steps.text += "\nResolution order: " + " → ".join(target_names)
	plan_confirm.text = "Confirm and resolve attack plan"
	plan_summary.text = "Assigned attacks for " + state.squads[attack_draft.squad].name
	if attack_draft.get("hail_target", -1) != -1:
		plan_summary.text += "\nHail of Bolts: +2 attacks per bolt rifle targeting " + state.squads[attack_draft.hail_target].name
	if attack_draft.melee: plan_summary.text += "\nChoose one ordinary melee weapon and all eligible Extra Attacks weapons for each model."
	for entry: Dictionary in attack_draft.entries:
		var option := Combat.AttackPlan.Equipment.select(state, entry.model, attack_draft.melee, entry.get("weapon", ""), entry.get("profile", ""))
		plan_summary.text += "\nModel %d • %s → %s ×%d%s" % [entry.model, option.label, state.squads[entry.target].name, entry.amount, " attacks" if attack_draft.melee and not option.stats.attacks is String else " weapon"]
		if attack_draft.melee and option.stats.attacks is String: plan_summary.text += " (A %s generated when resolving; one target)" % option.stats.attacks
	var error := Combat.attack_plan_error(state, _local_player(), attack_draft.attacker, attack_draft.entries, attack_draft.revision, attack_draft.melee, lethal_choice.button_pressed, attack_draft.get("hail_target", -1))
	plan_confirm.disabled = not error.is_empty()
	plan_summary.text += "\n" + ("Ready to resolve." if error.is_empty() else error)

func _plan_weapon_choice() -> Dictionary:
	if plan_weapon.selected < 0 or plan_weapon.item_count == 0: return {}
	return plan_weapon.get_item_metadata(plan_weapon.selected)

@rpc("any_peer", "call_remote", "reliable")
func request_attack_plan(attacker: int, entries: Array, revision: int, melee: bool, lethal: bool, hail_target: int = -1) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_attack_plan(2, attacker, entries, revision, melee, lethal, hail_target)

func _apply_attack_plan(player: int, attacker: int, entries: Array, revision: int, melee: bool, lethal: bool, hail_target: int = -1) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := Combat.resolve_attack_plan(state, player, attacker, entries, revision, melee, lethal, _d6, hail_target)
	if not result.error.is_empty():
		_feedback(player, result.error)
		return
	_broadcast()
	_feedback(player, result.message)

func _sync_terrain() -> void:
	if terrain_root == null: return
	var areas: Array = Combat.Terrain.areas(state)
	var signature := var_to_str(areas) + var_to_str(state.get("mission", {}).get("objectives", [])) + str(state.get("phase", "") == "deployment")
	if signature == terrain_signature: return
	terrain_signature = signature
	for child in terrain_root.get_children():
		terrain_root.remove_child(child)
		child.queue_free()
	if state.get("phase", "") == "deployment":
		for owner: int in state.deployment.zones:
			var zone: Rect2 = state.deployment.zones[owner]
			var center := zone.get_center()
			var color := Color("52b9d1") if owner == 1 else Color("e68d5c")
			for offset in [-1.0, 1.0]:
				_box(Vector3(zone.size.x, 0.07, 0.12), Vector3(center.x, 0.12, center.y + offset * zone.size.y / 2), color, terrain_root)
				_box(Vector3(0.12, 0.07, zone.size.y), Vector3(center.x + offset * zone.size.x / 2, 0.12, center.y), color, terrain_root)
	for area: Dictionary in areas:
		var tint := Color("596b73") if area.category == "dense" else Color("72714a") if area.category == "light" else Color("6f5e4d")
		var bounds: Rect2 = area.bounds
		var center := bounds.get_center()
		if area.category != "legacy":
			_box(Vector3(bounds.size.x, 0.025, bounds.size.y), Vector3(center.x, 0.035, center.y), tint, terrain_root)
			var label := Label3D.new()
			label.text = "%s • %s" % [area.name, area.category.capitalize()]
			label.font_size = 40
			label.pixel_size = 0.009
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.position = Vector3(center.x, 0.35, center.y)
			terrain_root.add_child(label)
		for feature: Dictionary in area.features:
			var shape: Rect2 = feature.bounds
			var point := shape.get_center()
			_box(Vector3(shape.size.x, feature.height, shape.size.y), Vector3(point.x, float(feature.height) / 2.0, point.y), tint.lightened(0.15), terrain_root)
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		var bounds: Rect2 = objective.bounds
		var center := bounds.get_center()
		var tint := Color("52b9d1") if objective.controller == 1 else Color("e68d5c") if objective.controller == 2 else Color("f2df83")
		for offset in [-1.0, 1.0]:
			_box(Vector3(bounds.size.x, 0.06, 0.08), Vector3(center.x, 0.10, center.y + offset * bounds.size.y / 2.0), tint, terrain_root)
			_box(Vector3(0.08, 0.06, bounds.size.y), Vector3(center.x + offset * bounds.size.x / 2.0, 0.10, center.y), tint, terrain_root)

func _host() -> void:
	if saved_army_mode and not saved_training_consent.button_pressed:
		status.text = "Accept the partial rules before starting LAN training."
		return
	var initial := _initial_state()
	if initial.has("error"):
		status.text = initial.error
		return
	var own: Dictionary = {}
	if saved_army_mode:
		own = _saved_army_report(1)
		if not own.error.is_empty():
			status.text = own.error
			return
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, 1)
	if error != OK:
		status.text = "Cannot host: " + error_string(error)
		return
	multiplayer.multiplayer_peer = peer
	mode = "host"
	host_session = SessionSeat.create()
	pending_seats = {}
	guest_id = 0
	state = initial
	_reset_history()
	if saved_army_mode:
		pending_armies = {1: own.selection}
		state.ready_armies = [1]
	_spawn_pieces()
	selected = -1
	status.text = "Waiting for player 2. Both players must select the same exercise before connecting."
	_refresh()

func _join() -> void:
	if saved_army_mode:
		if not saved_training_consent.button_pressed:
			status.text = "Accept the partial rules before joining LAN training."
			return
		var own := _saved_army_report(2)
		if not own.error.is_empty():
			status.text = own.error
			return
		submitted_army = own.selection
		validated_saved_setup = ""
		state = _initial_state()
		_reset_history()
		_spawn_pieces()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address.text.strip_edges(), PORT)
	if error != OK:
		status.text = "Cannot join: " + error_string(error)
		return
	multiplayer.multiplayer_peer = peer
	mode = "client"
	seat_challenge = {}
	selected = -1
	status.text = "Connecting…"
	_refresh()

func _offline(message: String) -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = "local"
	guest_id = 0
	pending_seats = {}
	seat_challenge = {}
	host_session = {}
	state = _initial_state()
	_reset_history()
	_spawn_pieces()
	selected = -1
	status.text = message
	_refresh()

func _peer_connected(id: int) -> void:
	if mode == "host":
		if not SessionSeat.valid_session(host_session): host_session = SessionSeat.create()
		var nonce := SessionSeat.secret()
		pending_seats[id] = {"nonce": nonce, "issued": ""}
		receive_seat_challenge.rpc_id(id, host_session.id, nonce, not host_session.token.is_empty())
		status.text = "Verifying player 2 credentials…"
		get_tree().create_timer(10.0).timeout.connect(func():
			if mode == "host" and pending_seats.get(id, {}).get("nonce") == nonce:
				pending_seats.erase(id)
				multiplayer.multiplayer_peer.disconnect_peer(id)
				status.text = "Verification timed out; waiting for player 2.")

@rpc("authority", "call_remote", "reliable")
func receive_seat_challenge(session_id: String, nonce: String, claimed: bool) -> void:
	if mode != "client" or not SessionSeat.valid(session_id) or not SessionSeat.valid(nonce): return
	seat_challenge = {"id": session_id, "nonce": nonce}
	var saved := SessionSeat.credentials()
	if saved.has("error"):
		_offline(saved.error)
		return
	var token: String = saved.seats.get(session_id, "")
	if claimed and token.is_empty():
		_offline("This seat belongs to another guest. Use the local credentials from the computer that joined as player 2.")
		return
	request_seat.rpc_id(1, SessionSeat.proof(token, nonce, session_id) if claimed else "")

@rpc("any_peer", "call_remote", "reliable")
func request_seat(response: String) -> void:
	var id := multiplayer.get_remote_sender_id()
	if mode != "host" or not pending_seats.has(id) or guest_id != 0: return
	var nonce: String = pending_seats[id].nonce
	if host_session.token.is_empty() and pending_seats[id].issued.is_empty():
		pending_seats[id].issued = SessionSeat.secret()
		receive_seat_token.rpc_id(id, host_session.id, nonce, pending_seats[id].issued)
		return
	var candidate := host_session.duplicate(true)
	if candidate.token.is_empty(): candidate.token = pending_seats[id].issued
	if not SessionSeat.accepts(candidate, nonce, response):
		_reject_seat(id)
		return
	# Make the reservation durable before allowing commands or publishing state.
	var previous := host_session
	host_session = candidate
	if state.get("phase") != "army_selection":
		var error := _save_snapshot()
		if not error.is_empty():
			host_session = previous
			status.text = "Could not save the seat reservation: " + error
			_reject_seat(id)
			return
	pending_seats.erase(id)
	guest_id = id
	receive_seat_ready.rpc_id(id)
	status.text = "Player 2 authenticated. Match is ready."
	_broadcast()

func _reject_seat(id: int) -> void:
	pending_seats.erase(id)
	receive_seat_rejected.rpc_id(id)
	var peer := multiplayer.multiplayer_peer
	get_tree().create_timer(0.3).timeout.connect(func():
		if mode == "host" and multiplayer.multiplayer_peer == peer and id in multiplayer.get_peers(): peer.disconnect_peer(id))

@rpc("authority", "call_remote", "reliable")
func receive_seat_token(session_id: String, nonce: String, token: String) -> void:
	if mode != "client" or seat_challenge.get("id") != session_id or seat_challenge.get("nonce") != nonce: return
	var error := SessionSeat.remember(session_id, token)
	if not error.is_empty():
		_offline("Could not save your credentials: " + error)
		return
	request_seat.rpc_id(1, SessionSeat.proof(token, nonce, session_id))

@rpc("authority", "call_remote", "reliable")
func receive_seat_ready() -> void:
	if mode != "client": return
	seat_challenge = {}
	if saved_army_mode and not submitted_army.is_empty(): request_saved_army.rpc_id(1, submitted_army)

@rpc("authority", "call_remote", "reliable")
func receive_seat_rejected() -> void:
	if mode == "client": _offline("Seat credentials were rejected or the reservation could not be saved.")

func _peer_disconnected(id: int) -> void:
	var was_pending := pending_seats.has(id)
	pending_seats.erase(id)
	if mode == "host" and was_pending:
		status.text = "Verification interrupted; waiting for the guest with this session's credentials."
	if mode == "host" and id == guest_id:
		guest_id = 0
		if saved_army_mode and state.phase == "army_selection":
			pending_armies.erase(2)
			state.ready_armies = pending_armies.keys()
		status.text = "Player 2 disconnected. Match paused; the seat remains reserved for them."
		_refresh()

func _broadcast() -> void:
	if mode != "client":
		autosave_error = _save_snapshot()
	_refresh()
	if history_panel.is_visible_in_tree() and mode != "client": history_panel.show_page(_journal_page())
	if mode == "host" and guest_id != 0:
		receive_state.rpc_id(guest_id, state)
	if not autosave_error.is_empty() and state.get("phase") != "army_selection":
		status.text = "Autosave failed: " + autosave_error

func _save_config() -> Dictionary:
	return {"combat_enabled": combat_enabled, "saved_army_mode": saved_army_mode, "prepared_match": prepared_match, "terrain_layout": terrain_layout, "mission_id": mission_id, "squads_per_side": squads_per_side, "manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "allocation_practice": allocation_practice, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts}

func _reset_history() -> void:
	journal.reset(state)
	autosave_error = ""
	if history_panel != null: history_panel.show_page(journal.page())

func _journal_page(start: int = -1) -> Dictionary:
	var page: Dictionary = journal.page(start)
	if not autosave_error.is_empty() and state.get("phase") != "army_selection": page.notice = "Save failed: " + autosave_error
	return page

func _save_snapshot() -> String:
	if state.get("phase") == "army_selection": return "Complete both army selections before saving."
	var error: String = journal.capture(state)
	if not error.is_empty(): return "History: " + error
	return MatchSave.write(state, _save_config(), rng.state, attack_draft, MatchSave.PATH, host_session, journal.checkpoint())

func _history_page(start: int = -1) -> void:
	if mode == "client":
		if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			request_history_page.rpc_id(1, start)
	else:
		history_panel.show_page(_journal_page(start))

@rpc("any_peer", "call_remote", "reliable")
func request_history_page(start: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		receive_history_page.rpc_id(guest_id, _journal_page(start))

@rpc("authority", "call_remote", "reliable")
func receive_history_page(page: Dictionary) -> void:
	if mode == "client": history_panel.show_page(page)

func _save_match() -> void:
	if mode == "client":
		status.text = "The host is responsible for saving the match."
		return
	var error := _save_snapshot()
	autosave_error = error
	status.text = "Match saved on this computer." if error.is_empty() else "Could not save the match: " + error
	if history_panel.is_visible_in_tree(): _history_page(-1)

func _load_match(as_host: bool = false) -> void:
	if mode != "local":
		status.text = "Disconnect from the LAN session before resuming a saved match."
		return
	var saved := MatchSave.read()
	if saved.has("error"):
		status.text = saved.error
		return
	var config: Dictionary = saved.config
	# Older saves predate the opt-in rule; their public state and hashes stay intact.
	if not config.has("core_stratagems"): config.core_stratagems = false
	if not config.has("hail_of_bolts"): config.hail_of_bolts = false
	if config.hail_of_bolts != (saved.state.get("hail_of_bolts", {}).get("implementation", "") == Combat.HailOfBolts.ID):
		status.text = "The Hail of Bolts option does not match the save."
		return
	if not config.has("implacable_eradication"): config.implacable_eradication = false
	if config.implacable_eradication != (saved.state.get("implacable_eradication", {}).get("implementation", "") == Combat.ImplacableEradication.ID):
		status.text = "The Implacable Eradication option does not match the save."
		return
	if not config.has("objective_secured"): config.objective_secured = false
	if config.objective_secured != (saved.state.get("objective_secured", {}).get("implementation", "") == Combat.ObjectiveSecured.ID):
		status.text = "The Objective Secured option does not match the save."
		return
	if not config.has("count_rerolls"): config.count_rerolls = false
	if config.count_rerolls != saved.state.get("stratagems", {}).get("count_rerolls", false):
		status.text = "The attack-count re-roll setting does not match the save."
		return
	if not config.has("escape_rerolls"): config.escape_rerolls = false
	if config.escape_rerolls != saved.state.get("stratagems", {}).get("escape_rerolls", false):
		status.text = "The Desperate Escape re-roll setting does not match the save."
		return
	if not config.has("hazard_rerolls"): config.hazard_rerolls = false
	if config.hazard_rerolls != saved.state.get("stratagems", {}).get("hazard_rerolls", false):
		status.text = "The Hazardous re-roll setting does not match the save."
		return
	if not config.has("damage_rerolls"): config.damage_rerolls = false
	if config.damage_rerolls != saved.state.get("stratagems", {}).get("damage_rerolls", false):
		status.text = "The damage re-roll setting does not match the save."
		return
	if not config.has("save_rerolls"): config.save_rerolls = false
	if config.save_rerolls != saved.state.get("stratagems", {}).get("save_rerolls", false):
		status.text = "The save re-roll setting does not match the save."
		return
	if not config.has("attack_rerolls"): config.attack_rerolls = false
	if config.attack_rerolls != saved.state.get("stratagems", {}).get("attack_rerolls", false):
		status.text = "The attack re-roll setting does not match the save."
		return
	if not config.has("movement_rerolls"): config.movement_rerolls = false
	if config.get("movement_rerolls") != saved.state.get("stratagems", {}).get("movement_rerolls", false):
		status.text = "The Command Re-roll setting does not match the save."
		return
	if config.get("core_stratagems") != saved.state.has("stratagems"):
		status.text = "The saved options do not match the current configuration."
		return
	var restored_session: Variant = saved.get("session", {})
	if not restored_session is Dictionary or (not restored_session.is_empty() and not SessionSeat.valid_session(restored_session)):
		status.text = "The saved seat reservation is invalid."
		return
	var current := _save_config()
	if config.keys().size() != current.keys().size():
		status.text = "The match configuration is incompatible."
		return
	for key in current:
		if not config.has(key) or typeof(config[key]) != typeof(current[key]):
			status.text = "The match configuration is invalid."
			return
	var initial: Dictionary
	if config.saved_army_mode:
		initial = PreparedTraining.from_setup(saved.state.get("saved_army_setup", {}))
	elif config.prepared_match:
		initial = PreparedTraining.initial_state({"manual_allocation": config.manual_allocation, "varied_equipment": config.varied_equipment, "core_stratagems": config.core_stratagems, "movement_rerolls": config.movement_rerolls, "attack_rerolls": config.attack_rerolls, "save_rerolls": config.save_rerolls, "damage_rerolls": config.damage_rerolls, "hazard_rerolls": config.hazard_rerolls, "escape_rerolls": config.escape_rerolls, "count_rerolls": config.count_rerolls, "objective_secured": config.objective_secured, "implacable_eradication": config.implacable_eradication, "hail_of_bolts": config.hail_of_bolts})
	elif config.allocation_practice:
		initial = TestBattlefield.apply(AllocationPractice.initial_state(config.damage_rerolls, config.count_rerolls))
	elif config.combat_enabled:
		initial = TestBattlefield.apply(Combat.initial_state(config.terrain_layout, config.mission_id, config.squads_per_side, config.manual_allocation, config.varied_equipment))
	else:
		initial = Rules.initial_state()
	if initial.is_empty() or initial.has("error") or initial.get("pack") != saved.state.get("pack") or initial.get("pack_hash") != saved.state.get("pack_hash"):
		status.text = "The saved match requires a different rules version or local data pack."
		return
	for key in initial:
		if not saved.state.has(key) or typeof(initial[key]) != typeof(saved.state[key]):
			status.text = "The saved state is incomplete or incompatible."
			return
	if not saved.get("journal", {}) is Dictionary:
		status.text = "The history reference is invalid."
		return
	var restored_journal = MatchJournal.new()
	var history_error: String = restored_journal.restore(saved.get("journal", {}), saved.state)
	if not history_error.is_empty():
		status.text = history_error
		return
	var peer: ENetMultiplayerPeer
	if as_host:
		peer = ENetMultiplayerPeer.new()
		var error := peer.create_server(PORT, 1)
		if error != OK:
			status.text = "Cannot host: " + error_string(error)
			return
	for key in config: set(key, config[key])
	stratagem_choice.button_pressed = core_stratagems
	reroll_choice.button_pressed = movement_rerolls
	attack_reroll_choice.button_pressed = attack_rerolls
	save_reroll_choice.button_pressed = save_rerolls
	damage_reroll_choice.button_pressed = damage_rerolls
	hazard_reroll_choice.button_pressed = hazard_rerolls
	escape_reroll_choice.button_pressed = escape_rerolls
	count_reroll_choice.button_pressed = count_rerolls
	objective_secured_choice.button_pressed = objective_secured
	implacable_eradication_choice.button_pressed = implacable_eradication
	hail_of_bolts_choice.button_pressed = hail_of_bolts
	state = saved.state
	journal = restored_journal
	autosave_error = ""
	host_session = restored_session if not restored_session.is_empty() else SessionSeat.create()
	pending_seats = {}
	rng.state = saved.rng_state
	attack_draft = saved.attack_draft
	selected = -1
	guest_id = 0
	pending_armies = {}
	validated_saved_setup = ""
	if as_host:
		multiplayer.multiplayer_peer = peer
		mode = "host"
	_spawn_pieces()
	_refresh()
	status.text = "Match resumed; waiting for player 2 on LAN." if as_host else "Match resumed with decisions and dice preserved."
	if history_panel.is_visible_in_tree(): _history_page(-1)
	if as_host and not host_session.token.is_empty(): status.text += " Vaga reservada ao convidado original."

@rpc("authority", "call_remote", "reliable")
func receive_state(snapshot: Dictionary) -> void:
	if mode != "client": return
	var expected: Dictionary = state
	var setup_digest := JSON.stringify(snapshot.get("saved_army_setup", {})).sha256_text()
	if saved_army_mode and snapshot.has("saved_army_setup") and (setup_digest != validated_saved_setup or snapshot.get("pack_hash") != state.get("pack_hash")):
		if snapshot.saved_army_setup.get("options", {}).get("hail_of_bolts", false) != hail_of_bolts:
			_offline("Players have different Hail of Bolts settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("implacable_eradication", false) != implacable_eradication:
			_offline("Players have different Implacable Eradication settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("objective_secured", false) != objective_secured:
			_offline("Players have different Objective Secured settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("count_rerolls", false) != count_rerolls:
			_offline("Players have different attack-count re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("escape_rerolls", false) != escape_rerolls:
			_offline("Players have different Desperate Escape re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("hazard_rerolls", false) != hazard_rerolls:
			_offline("Players have different Hazardous re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("damage_rerolls", false) != damage_rerolls:
			_offline("Players have different damage re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("save_rerolls", false) != save_rerolls:
			_offline("Players have different save re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("attack_rerolls", false) != attack_rerolls:
			_offline("Players have different attack re-roll settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("movement_rerolls", false) != movement_rerolls:
			_offline("The received Command Re-roll option differs from the selected settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("core_stratagems", false) != core_stratagems:
			_offline("The received stratagem option differs from the selected settings. Choose the same option as the host.")
			return
		expected = PreparedTraining.from_setup(snapshot.saved_army_setup)
		if expected.has("error") or submitted_army.is_empty():
			_offline("The received list configuration is incompatible with the local data pack.")
			return
		if TrainingRoster.digest(expected.saved_army_setup.armies[2]) != TrainingRoster.digest(submitted_army):
			_offline("The host changed its army selection; connection closed.")
			return
	if snapshot.get("pack") != expected.get("pack") or snapshot.get("pack_hash") != expected.get("pack_hash"):
		_offline("Incompatible rules pack.")
		return
	var replace_pieces: bool = snapshot.get("pack_hash") != state.get("pack_hash")
	if saved_army_mode and snapshot.has("saved_army_setup"): validated_saved_setup = setup_digest
	state = snapshot
	if replace_pieces: _spawn_pieces()
	status.text = "State synchronized with host."
	_refresh()
	if history_panel.is_visible_in_tree(): _history_page(-1)

@rpc("any_peer", "call_remote", "reliable")
func request_move(id: int, target: Vector2, revision: int = -1) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_move(2, id, target, revision)

func _apply_move(player: int, id: int, target: Vector2, revision: int = -1) -> void:
	if mode == "host" and guest_id == 0:
		status.text = "Wait for player 2."
		return
	if combat_enabled:
		var error: String = Deployment.place(state, player, id, target, revision) if state.phase == "deployment" else Combat.move(state, player, id, target, revision)
		if not error.is_empty():
			_feedback(player, error)
			return
		_broadcast()
		_feedback(player, "Deployment position accepted." if state.phase == "deployment" else "Miniature repositioned. Confirm the squad's movement when ready.")
		return
	var reason: String = Rules.validate_move(state, player, id, target)
	if not reason.is_empty():
		_feedback(player, reason)
		return
	var distance: float = state.units[id].position.distance_to(target)
	state.units[id].position = target
	state.units[id].moved = true
	_feedback(player, "Moved %.2f units." % distance)
	_broadcast()

func _feedback(player: int, message: String) -> void:
	if mode == "host" and player == 2:
		receive_feedback.rpc_id(guest_id, message)
	else:
		status.text = message

@rpc("authority", "call_remote", "reliable")
func receive_feedback(message: String) -> void:
	status.text = message

func _request_end() -> void:
	if mode == "client":
		request_end.rpc_id(1, int(state.get("revision", -1)), selected)
	else:
		_apply_end(_local_player(), int(state.get("revision", -1)), selected)

func _refresh_command_reaction() -> void:
	var window := Combat.Stratagems.pending(state) if combat_enabled else {}
	for control in [reaction_help, reaction_squad, reaction_roll, reaction_use]: control.visible = not window.is_empty()
	if window.is_empty():
		if reaction_die != null: reaction_die.visible = false
		return
	var attack: bool = window.kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"]
	var rolling: bool = window.kind != "before_battle_shock"
	if reaction_die == null:
		reaction_die = OptionButton.new()
		reaction_use.get_parent().add_child(reaction_die)
		reaction_die.get_parent().move_child(reaction_die, reaction_use.get_index())
	reaction_die.visible = attack
	var previous_die := reaction_die.get_selected_id()
	reaction_die.clear()
	if attack:
		for index: int in window.eligible: reaction_die.add_item(window.labels[index] if window.has("labels") else "Die %d: %d" % [index + 1, window.rolls[index]], index)
		reaction_die.select(maxi(0, reaction_die.get_item_index(previous_die)))
	var previous := reaction_squad.get_selected_id()
	reaction_squad.clear()
	var squads: Array = [window.squad] if rolling else window.remaining
	for squad: int in squads:
		reaction_squad.add_item(state.squads[squad].name, squad)
	var chosen := reaction_squad.get_item_index(previous)
	reaction_squad.select(maxi(0, chosen))
	var player := _local_player()
	var waiting: bool = (mode == "host" and guest_id == 0) or player != window.player
	reaction_die.disabled = waiting
	reaction_squad.disabled = waiting
	reaction_squad.visible = not rolling
	reaction_roll.disabled = waiting
	var stratagem := "command-re-roll" if rolling else "insane-bravery"
	var error := Combat.Stratagems.use_error(state, player, reaction_squad.get_selected_id(), stratagem, state.revision)
	reaction_use.disabled = waiting or not error.is_empty()
	reaction_use.text = "Command Re-roll • 1 CP • uma vez por fase" if rolling else "Insane Bravery • 1 CP • uma vez por batalha"
	reaction_roll.text = "Accept result and continue" if rolling else "Roll Battle-shock normally"
	if attack:
		reaction_help.text = "%s • P%d • %d CP\n%s: %s. Choose a die to replace or accept all.\nThe next step has not been rolled yet; the new result will be mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], "Saves" if window.kind == "after_save_roll" else ("Hits" if window.kind == "after_hit_roll" else "Wounds"), str(window.rolls)]
		if window.kind == "after_attack_count_roll": reaction_help.text = "%s • P%d • %d CP\nAttacks: %d • A %s • D6: %s.\nChoose one die or accept the pool. Bonuses and other dice stay the same; D3 converts D6 results to 1–3. Hits have not been rolled. The new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], window.total, str(window.expression), str(window.rolls)]
		elif window.kind == "after_escape_roll": reaction_help.text = "%s • P%d • %d CP\nDesperate Escape hazards: %s. Choose one D6 or accept the pool.\n1–2 fails; 3–6 passes. The new result is mandatory. Mortal wounds, prevention and movement wait for this decision." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls)]
		elif window.kind == "after_hazardous_roll": reaction_help.text = "%s • P%d • %d CP\nHazardous: %s. Choose a D6 to replace or accept the pool.\n1–2 fails; 3–6 passes. The new result is mandatory, even if it is worse. Mortal wounds and prevention are waiting for this decision." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls)]
		elif window.kind == "after_damage_roll": reaction_help.text = "%s • P%d • %d CP\nDamage %s = %d • Original D6: %s.\nChoose a D6 to replace. For D3, each D6 converts to 1–3. Recipient %d stays fixed; prevention and casualties wait for this decision. The new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.expression), window.value, str(window.rolls), window.model]
	elif rolling:
		var total := 0
		for die: int in window.rolls: total += die
		reaction_help.text = "%s • P%d • %d CP\n%s: %s = %d inches.\nAccepting costs no CP. Command Re-roll replaces %s; the new result is mandatory, even if it is lower." % [state.squads[window.squad].name, window.player, state.cp[window.player], "Advance" if window.kind == "after_advance_roll" else "Charge", str(window.rolls), total, "the D6" if window.kind == "after_advance_roll" else "both D6"]
	else:
		reaction_help.text = "P%d • %d CP • %d pending test(s). Choose the next unit.\nRolling normally costs no CP. Insane Bravery passes the test without rolling dice." % [window.player, state.cp[window.player], window.remaining.size()]
	if not error.is_empty() and not waiting: reaction_help.text += "\n" + error
	reaction_use.tooltip_text = error

func _request_use_reaction() -> void:
	_request_command_reaction("insane-bravery" if Combat.Stratagems.pending(state).get("kind") == "before_battle_shock" else "command-re-roll")

func _request_command_reaction(stratagem: String) -> void:
	var squad := reaction_squad.get_selected_id()
	if mode == "client": request_command_reaction.rpc_id(1, squad, stratagem, state.revision, reaction_die.get_selected_id() if reaction_die != null else -1)
	else: _apply_command_reaction(_local_player(), squad, stratagem, state.revision, reaction_die.get_selected_id() if reaction_die != null else -1)

@rpc("any_peer", "call_remote", "reliable")
func request_command_reaction(squad: int, stratagem: String, revision: int, die: int = -1) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_command_reaction(2, squad, stratagem, revision, die)

func _apply_command_reaction(player: int, squad: int, stratagem: String, revision: int, die: int = -1) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var morale: bool = Combat.Stratagems.pending(state).get("kind") == "before_battle_shock"
	var attack: bool = Combat.Stratagems.pending(state).get("kind") in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"]
	var hazard: bool = Combat.Stratagems.pending(state).get("kind") == "after_hazardous_roll"
	var escape: bool = Combat.Stratagems.pending(state).get("kind") == "after_escape_roll"
	var error: String
	if escape: error = Combat.resolve_escape_reaction(state, player, squad, stratagem, revision, die, _d6)
	elif hazard: error = Combat.resolve_hazard_reaction(state, player, squad, stratagem, revision, die, _d6)
	elif attack: error = Combat.resolve_attack_reaction(state, player, squad, stratagem, revision, die, _d6)
	elif morale: error = Combat.resolve_command_reaction(state, player, squad, stratagem, revision, _d6)
	else: error = Combat.resolve_roll_reaction(state, player, squad, stratagem, revision, _d6)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	var message: String
	if morale:
		var result: Dictionary = state.last_morale[-1]
		message = "Insane Bravery: teste aprovado sem rolagem." if not stratagem.is_empty() else "Battle-shock %s vs %d: %s." % [str(result.rolls), result.target, "aprovado" if result.passed else "falhou"]
	else:
		message = "%s: %s → %s." % ["Command Re-roll" if not stratagem.is_empty() else "Result accepted", str(state.last_command_roll.original_rolls), str(state.last_command_roll.rolls)]
		if state.last_command_roll.kind == "after_attack_count_roll": message += " Attack count confirmed: %d." % state.last_command_roll.total
		elif escape: message += " Allocate escape mortal wounds before moving." if state.pending_move.hazard_remaining > 0 else " Escape placement can begin."
		elif hazard: message += " Hazardous allocation is ready." if not state.pending_hazard.is_empty() else " Hazardous resolved; activation complete."
		elif state.last_command_roll.kind == "after_damage_roll": message += " Damage %s: %d, before prevention." % [str(state.last_command_roll.expression), state.last_command_roll.value]
		elif attack: message += " Attack resumed at the next required decision."
		elif state.last_command_roll.kind == "after_charge_roll":
			message += " Charge failed; this unit cannot declare another charge this phase." if state.pending_charge.is_empty() else " Choose charge targets."
		else: message += " Position models within the final Advance distance."
	_feedback(player, "%s P%d: %d CP remaining. Result recorded in match history." % [message, player, state.cp[player]])

@rpc("any_peer", "call_remote", "reliable")
func request_end(revision: int = -1, model: int = -1) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_end(2, revision, model)

func _apply_end(player: int, revision: int = -1, model: int = -1) -> void:
	if mode == "host" and guest_id == 0: return
	if combat_enabled and state.phase == "deployment":
		_apply_deployment(player, revision, true)
		return
	if combat_enabled:
		var squad: int = state.units[model].squad if state.units.has(model) and state.units[model].owner == player else -1
		var error: String = Combat.advance_phase(state, player, revision, _d6, squad)
		if not error.is_empty():
			_feedback(player, error)
			return
		_broadcast()
		if not Combat.Stratagems.pending(state).is_empty():
			_feedback(player, "Battle-shock pending: choose a unit and decide before rolling.")
		else:
			_feedback(player, "Phase: %s. %s" % [state.phase, "Right click an enemy to shoot." if state.phase == "shooting" else "Move individual miniatures, then confirm the squad." if state.phase == "movement" else "Advance when ready; unimplemented effects are listed above."])
		return
	if player != state.active:
		_feedback(player, "Wait for your turn.")
		return
	Rules.end_turn(state)
	_broadcast()

@rpc("any_peer", "call_remote", "reliable")
func request_attack(attacker: int, target: int, revision: int, use_lethal: bool) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_attack(2, attacker, target, revision, use_lethal)

func _apply_attack(player: int, attacker: int, target: int, revision: int, use_lethal: bool) -> void:
	if not combat_enabled: return
	if mode == "host" and guest_id == 0:
		status.text = "Wait for player 2."
		return
	var result: Dictionary = Combat.shoot(state, player, attacker, target, revision, use_lethal, _d6)
	if not result.error.is_empty():
		_feedback(player, result.error)
		return
	_broadcast()
	_feedback(player, result.message)

func _d6() -> int:
	var value := rng.randi_range(1, 6)
	journal.roll(state, value)
	return value

func _request_action() -> void:
	if not combat_enabled: return
	var objective := action_objective.get_selected_id()
	if mode == "client": request_action.rpc_id(1, selected, objective, state.revision)
	else: _apply_action(_local_player(), selected, objective, state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_action(model: int, objective: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_action(2, model, objective, revision)

func _apply_action(player: int, model: int, objective: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error := Combat.start_action(state, player, model, objective, revision)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Secure Ground started. Shooting and charging remain restricted until turn end.")

func _request_begin_movement() -> void:
	if not combat_enabled: return
	var move_type: String = MOVE_TYPES[movement_choice.selected]
	if mode == "client": request_begin_movement.rpc_id(1, selected, move_type, state.revision)
	else: _apply_begin_movement(_local_player(), selected, move_type, state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_movement(model: int, move_type: String, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_begin_movement(2, model, move_type, revision)

func _apply_begin_movement(player: int, model: int, move_type: String, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.begin_movement(state, player, model, move_type, revision, _d6)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Roll complete: accept the result or use Command Re-roll before allocation and movement." if not Combat.Stratagems.pending(state).is_empty() else "Movement selected. Allocate any escape wounds, then place models and confirm.")

func _request_escape_wound() -> void:
	if not combat_enabled: return
	if mode == "client": request_escape_wound.rpc_id(1, selected, state.revision)
	else: _apply_escape_wound(_local_player(), selected, state.revision)

func _request_abandon_fall_back() -> void:
	if not combat_enabled: return
	if mode == "client": request_abandon_fall_back.rpc_id(1, state.revision)
	else: _apply_abandon_fall_back(_local_player(), state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_abandon_fall_back(revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_abandon_fall_back(2, revision)

func _apply_abandon_fall_back(player: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.abandon_fall_back(state, player, revision)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Fall Back not completed. Positions restored; casualties retained and movement selection consumed.")

@rpc("any_peer", "call_remote", "reliable")
func request_escape_wound(model: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_escape_wound(2, model, revision)

func _apply_escape_wound(player: int, model: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.allocate_escape_wound(state, player, model, revision, _d6)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Escape mortal wound allocated.")

func _request_coherency_removal() -> void:
	if not combat_enabled: return
	if mode == "client": request_coherency_removal.rpc_id(1, selected, state.revision)
	else: _apply_coherency_removal(_local_player(), selected, state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_coherency_removal(model: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id:
		_apply_coherency_removal(2, model, revision)

func _apply_coherency_removal(player: int, model: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.remove_for_coherency(state, player, model, revision)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Model %d removed for coherency." % model)

func _request_finish_movement(cancel: bool) -> void:
	if not combat_enabled: return
	if mode == "client": request_finish_movement.rpc_id(1, state.revision, cancel)
	else: _apply_finish_movement(_local_player(), state.revision, cancel)

@rpc("any_peer", "call_remote", "reliable")
func request_finish_movement(revision: int, cancel: bool) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_finish_movement(2, revision, cancel)

func _apply_finish_movement(player: int, revision: int, cancel: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.finish_movement(state, player, revision, cancel, _d6)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Placement reset; selected move, dice and casualties retained." if cancel and not state.pending_move.is_empty() else "Pending movement cancelled." if cancel else "Squad movement confirmed.")

func _request_charge_roll() -> void:
	if not combat_enabled: return
	var decline: bool = not state.pending_charge.is_empty()
	if mode == "client": request_charge_roll.rpc_id(1, selected, state.revision, decline)
	else: _apply_charge_roll(_local_player(), selected, state.revision, decline)

@rpc("any_peer", "call_remote", "reliable")
func request_charge_roll(model: int, revision: int, decline: bool) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_charge_roll(2, model, revision, decline)

func _apply_charge_roll(player: int, model: int, revision: int, decline: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	if decline:
		var error: String = Combat.decline_charge(state, player, revision)
		if not error.is_empty():
			_feedback(player, error)
			return
		_broadcast()
		_feedback(player, "Charge finished without movement.")
		return
	var result: Dictionary = Combat.declare_charge(state, player, model, revision, _d6)
	if not result.error.is_empty():
		_feedback(player, result.error)
		return
	_broadcast()
	_feedback(player, result.message)

@rpc("any_peer", "call_remote", "reliable")
func request_charge(target: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_charge(2, target, revision)

func _apply_charge(player: int, target: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result: Dictionary = Combat.select_charge_target(state, player, target, revision)
	if not result.error.is_empty():
		_feedback(player, result.error)
		return
	_broadcast()
	_feedback(player, result.message)

func _request_begin_contact() -> void:
	if not combat_enabled: return
	var kind: String = "charge" if state.phase == "charge" else "pile_in" if state.fight_step == "pile_in" else "consolidate" if state.fight_step == "consolidate" else "overrun"
	var objective := consolidation_objective.get_selected_id() if consolidation_objective.visible else -1
	var targets: Array[int] = []
	if contact_enemy.visible: targets.append(contact_enemy.get_selected_id())
	if mode == "client": request_begin_contact.rpc_id(1, selected, kind, state.revision, objective, targets)
	else: _apply_begin_contact(_local_player(), selected, kind, state.revision, objective, targets)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_contact(model: int, kind: String, revision: int, objective: int = -1, targets: Array[int] = []) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_begin_contact(2, model, kind, revision, objective, targets)

func _apply_begin_contact(player: int, model: int, kind: String, revision: int, objective: int = -1, targets: Array[int] = []) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.begin_contact_move(state, player, model, kind, revision, targets, objective)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Place individual models with right-click, then confirm contact movement.")

@rpc("any_peer", "call_remote", "reliable")
func request_contact_move(model: int, destination: Vector2, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_contact_move(2, model, destination, revision)

func _apply_contact_move(player: int, model: int, destination: Vector2, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.stage_contact_move(state, player, model, destination, revision)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Contact placement staged.")

func _request_finish_contact(cancel: bool) -> void:
	if not combat_enabled: return
	if mode == "client": request_finish_contact.rpc_id(1, state.revision, cancel)
	else: _apply_finish_contact(_local_player(), state.revision, cancel)

@rpc("any_peer", "call_remote", "reliable")
func request_finish_contact(revision: int, cancel: bool) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_finish_contact(2, revision, cancel)

func _apply_finish_contact(player: int, revision: int, cancel: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var error: String = Combat.finish_contact_move(state, player, revision, cancel)
	if not error.is_empty():
		_feedback(player, error)
		return
	_broadcast()
	_feedback(player, "Contact placement cancelled; positions restored." if cancel else "Contact movement confirmed.")

@rpc("any_peer", "call_remote", "reliable")
func request_fight(attacker: int, target: int, revision: int) -> void:
	if mode == "host" and multiplayer.get_remote_sender_id() == guest_id: _apply_fight(2, attacker, target, revision)

func _apply_fight(player: int, attacker: int, target: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result: Dictionary = Combat.fight(state, player, attacker, target, revision, _d6)
	if not result.error.is_empty():
		_feedback(player, result.error)
		return
	_broadcast()
	_feedback(player, result.message)

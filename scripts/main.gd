extends Node3D

class DicePipFace extends Control:
	var value := 1

	func _draw() -> void:
		var bounds := Rect2(Vector2(1, 1), size - Vector2(2, 2))
		var ink := Color("20272d")
		draw_rect(bounds, Color("f2eee0"), true)
		draw_rect(bounds, ink, false, 1.5, true)
		var positions: Array[Vector2] = [
			Vector2(0.25, 0.25), Vector2(0.5, 0.25), Vector2(0.75, 0.25),
			Vector2(0.25, 0.5), Vector2(0.5, 0.5), Vector2(0.75, 0.5),
			Vector2(0.25, 0.75), Vector2(0.5, 0.75), Vector2(0.75, 0.75)
		]
		var active_pips: Array[int] = []
		match value:
			1: active_pips = [4]
			2: active_pips = [0, 8]
			3: active_pips = [0, 4, 8]
			4: active_pips = [0, 2, 6, 8]
			5: active_pips = [0, 2, 4, 6, 8]
			6: active_pips = [0, 2, 3, 5, 6, 8]
		for pip: int in active_pips:
			draw_circle(size * positions[pip], minf(size.x, size.y) * 0.075, ink, true, -1.0, true)

const Rules = preload("res://scripts/rules.gd")
const MatchResult = preload("res://scripts/match_result.gd")
const MatchRestart = preload("res://scripts/match_restart.gd")
const DecisionCamera = preload("res://scripts/ui/decision_camera.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var attack_feedback = preload("res://scripts/ui/attack_feedback.gd").new()
var shooting_complete: Label
var blockers_button: Button
var blockers_reference: Label
var blockers_rules: Label
var blockers_rules_toggle: CheckButton
var unit_details_button: Button
var unit_choice_reference: Label
var waiting_unit_picker: OptionButton
var waiting_activity: VBoxContainer
var waiting_activity_text: Label
var workshop_tabs: TabContainer
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const KeywordGlossary = preload("res://scripts/edition_11/keyword_glossary.gd")
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
const MainMenu = preload("res://scripts/ui/main_menu.gd")
const CombatHud = preload("res://scripts/ui/combat_hud.gd")
const SessionTransport = preload("res://scripts/network/session_transport.gd")
const MatchSession = preload("res://scripts/network/match_session.gd")
var journal = MatchJournal.new()
var match_save_path := MatchSave.PATH
var match_journal_directory := MatchJournal.DIRECTORY
var history_panel
var session_transport
var match_session = MatchSession.new()
var host_session: Dictionary:
	get:
		return match_session.host_session
	set(value):
		match_session.host_session = value
var pending_seats: Dictionary:
	get:
		return match_session.pending_seats
	set(value):
		match_session.pending_seats = value
var seat_challenge: Dictionary:
	get:
		return match_session.guest_challenge
	set(value):
		match_session.guest_challenge = value
var autosave_error := ""
var auto_models: CheckBox
var local_model_status: Label
var saved_army_mode := false
var saved_army_pickers: Dictionary = {}
var saved_training_consent: CheckBox
var saved_army_review: Label
var saved_army_start_button: Button
var local_match_status: Label
var network_army_picker: OptionButton
var network_army_status: Label
var network_army_submit: Button
var setup_feedback_status: Label
var setup_notice: Label
var pending_armies: Dictionary = {}
var submitted_army: Dictionary = {}
var local_visual_armies: Dictionary = {}
var validated_saved_setup := ""
var army_builder
var prepared_match := false
var objective_secured := false
var implacable_eradication := false
var hail_of_bolts := false
var oath_of_moment := false
var reanimation_protocols := false
var combat_doctrines := false
var marine_detachment := "gladius"
var marine_detachment_p2 := "gladius"
var marine_detachments: Dictionary = {1: "gladius", 2: "gladius"}
var ability_token_nodes: Dictionary = {}
var checked_rosters := false
var checked_rosters_choice: CheckBox
var official_mission := false
var official_mission_choice: CheckBox
var official_primary_choice: OptionButton
var official_primary_heading: Label
var official_primary_help: Label
var official_layout_heading: Label
var official_layout_choice: OptionButton
var official_layout_preview: TextureRect
var official_layout_preview_status: Label
var unit_abilities := false
var unit_abilities_choice: CheckBox
var unit_action_picker: OptionButton
var doctrine_action_panel: VBoxContainer
var unit_action_x: SpinBox
var unit_action_z: SpinBox
var unit_action_help: Label
var unit_action_button: Button
var setup_preparation_status: Label
var setup_required_status: Label
var setup_decisions_heading: Label
var setup_equipment_toggle: Button
var setup_equipment_list: VBoxContainer
var setup_finish_button: Button
var setup_equipment_open := false
var setup_decision_choices: Array[Dictionary] = []
var awakened_dynasty := false
var objective_secured_choice: CheckBox
var implacable_eradication_choice: CheckBox
var hail_of_bolts_choice: CheckBox
var oath_of_moment_choice: CheckBox
var reanimation_protocols_choice: CheckBox
var combat_doctrines_choice: CheckBox
var marine_detachment_choice: OptionButton
var marine_detachment_choice_p2: OptionButton
var awakened_dynasty_choice: CheckBox
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
var reaction_reference: Label
var defense_reference: Label
var reaction_dice: HFlowContainer
var reaction_dice_hint: Label
var reaction_dice_buttons: Dictionary = {}
var match_result_panel
var displayed_result_id := ""
var reaction_squad: OptionButton
var reaction_roll: Button
var reaction_use: Button
var reaction_sudden: Button
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
var health_tags: Dictionary = {}
var board_presentation_state: Dictionary = {}
var selected := -1
var mode := "local"
var guest_id: int:
	get:
		return match_session.guest_id
	set(value):
		match_session.guest_id = value
var camera: Camera3D
var pivot: Node3D
var focus_tween: Tween
var auto_frame_toggle: CheckButton
var last_camera_key := ""
var status: Label
var details: Label
var selection_card: Label
var datasheet_button: Button
var datasheet_details: Label
var decision_details: Label
var attack_reference: Label
var technical_toggle: CheckButton
var address: LineEdit
var session_label: Label
var decision_label: Label
var objective_summary: Label
var combat_hud
var main_menu
var home_nav_button: Button
var menu_return_tab := 1
var tactical_overlay: Control
var tactical_overlay_body: VBoxContainer
var tactical_overlay_title: Label
var tactical_overlay_content: Control
var tactical_overlay_parent: Node
var tactical_overlay_index := -1
var history_scroll: ScrollContainer
var help_scroll: ScrollContainer
var workshop_scroll: ScrollContainer
var tools_scroll: ScrollContainer
var settings_panel: VBoxContainer
var display_mode_picker: OptionButton
var resolution_picker: OptionButton
var settings_toggles: Dictionary = {}
var applied_display_settings: Dictionary = {}
var settings_notice: Label
var screen_settings := ConfigFile.new()
var ui_preferences_path := "user://ui_settings.cfg"
var resume_compatible := false
var resume_succeeded := false
var dice_toggle: CheckButton
var match_tabs: TabContainer
var gameplay_scroll: ScrollContainer
var ui_combat_enabled := false
var host_button: Button
var join_button: Button
var end_button: Button
var zoom := 15.5
var angle := 0.0
var combat_enabled := false
var terrain_layout := Combat.Terrain.DEFAULT_LAYOUT
var official_terrain_layout := Combat.Mission.DEFAULT_TERRAIN_LAYOUT
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
var sidebar_title: Label
var notice_heading: Label
var controls_help: Label
var first_session_guide: Label
var first_session_panel: PanelContainer
var first_session_heading: Label
var first_session_progress: ProgressBar
var first_session_boundary: RichTextLabel
var first_session_experiments: Label
var first_session_terms: HFlowContainer
var guided_first_session := false
var tutorial_details_toggle: Button
var tutorial_extra: VBoxContainer
var reaction_focus_key := ""
var unit_decline_button: Button
var unit_decline_choice: Dictionary = {}
var recipient_cards: VBoxContainer
var recipient_scroll: ScrollContainer
var placement_feedback = preload("res://scripts/ui/placement_feedback.gd").new()
var placement_reason: Label
var combat_tray = preload("res://scripts/ui/combat_tray.gd").new()
var combat_audio_toggle: CheckButton
var casualty_tweens: Dictionary = {}
var last_camera_area := Rect2()
var camera_manual_override := false
var training_swap_sides := false
var training_swap_choice: CheckBox
var lethal_choice: CheckBox
var event_log: RichTextLabel
var log_toggle: CheckButton
var result_summary: Label
var damage_preview: Label
var dice_visual: VBoxContainer
var dice_visual_rolls: HFlowContainer
var dice_audit_label: Label
var dice_animation_toggle: CheckButton
var dice_visual_signature := ""
var health_overlay_toggle: CheckButton
var board_feedback_toggle: CheckButton
var charge_button: Button
var finish_move_button: Button
var cancel_move_button: Button
var coherency_button: Button
var movement_choice: OptionButton
var movement_choices
var sudden_onslaught_choice: CheckBox
var movement_reference: Label
var action_unit_picker: OptionButton
var contact_flow
var contact_reference: Label
var charge_targets: VBoxContainer
var charge_target_buttons: Dictionary = {}
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
var plan_assignment_status: Label
var reanimation_help: Label
var reanimation_squad: OptionButton
var reanimation_model: OptionButton
var reanimation_x: SpinBox
var reanimation_z: SpinBox
var reanimation_roll: Button
var reanimation_place: Button
var reanimation_suggest: Button
var reanimation_failure: Button
var reanimation_reset: Button
var reanimation_confirm: Button
var awakened_help: Label
var awakened_target: OptionButton
var awakened_confirm: Button
var doctrine_help: Label
var doctrine_choice: OptionButton
var doctrine_confirm: Button
var oath_help: Label
var oath_target: OptionButton
var oath_confirm: Button
var plan_hail: OptionButton
var indirect_choice: CheckBox
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
var command_panel: PanelContainer
var command_panel_body: VBoxContainer
var tactical_opportunity_label: Label
var command_panel_open := true
var command_panel_pending_revision := -1
var guide_panel: PanelContainer
var guide_label: Label
var guides_toggle: CheckBox
var guides
var hover_time := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_child(attack_feedback)
	rng.randomize()
	_reset_history()
	if state.is_empty():
		push_error("Startup stopped: the local demo data pack is invalid.")
		get_tree().quit(1)
		return
	session_transport = SessionTransport.new()
	session_transport.name = "SessionTransport"
	add_child(session_transport)
	session_transport.bind(multiplayer)
	_build_board()
	_build_ui()
	_load_ui_preferences()
	_spawn_pieces()
	get_viewport().size_changed.connect(_layout_ui)
	_layout_ui()
	session_transport.peer_connected.connect(_peer_connected)
	session_transport.peer_disconnected.connect(_peer_disconnected)
	session_transport.connected_to_server.connect(_connected_to_server)
	session_transport.connection_failed.connect(func(): _offline("Connection failed."))
	session_transport.server_disconnected.connect(func(): _offline("Host disconnected. Local preview restored."))
	_refresh()
	_update_main_menu_resume_state()

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
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("172027")
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
	zoom = maxf(18.0, maxf(size.x, size.y) * 0.82)
	if camera != null: _update_camera()

func _spawn_pieces() -> void:
	_finish_casualty_feedback()
	for piece: MeshInstance3D in pieces.values(): piece.queue_free()
	pieces.clear()
	health_tags.clear()
	board_presentation_state.clear()
	for id: int in state.units:
		var piece := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = state.units[id].radius if combat_enabled else 0.32
		mesh.bottom_radius = state.units[id].radius
		mesh.height = clampf(float(state.units[id].radius) * 2.4, 1.05, 2.2)
		piece.mesh = mesh
		add_child(piece)
		pieces[id] = piece
		_create_health_tag(piece, id)
		if model_imports != null:
			var definition := str(state.units[id].get("definition_id", ""))
			var visual: Node3D = model_imports.visual_variant_for(_local_visual_variant(id), float(state.units[id].radius))
			if visual == null: visual = model_imports.visual_for(definition, float(state.units[id].radius))
			if visual != null:
				mesh.height = 0.08
				mesh.top_radius = state.units[id].radius
				var base_offset := Node3D.new()
				base_offset.position.y = 0.04
				piece.add_child(base_offset)
				base_offset.add_child(visual)
				# Keep the colored selection base on the board; visuals are cosmetic.
				piece.set_meta("imported_visual", true)

func _canonical_visual_definition(faction: String, unit_id: String) -> String:
	if unit_id.begins_with("40kdc:11e:"):
		return TrainingRoster.Capabilities.canonical_id(faction, unit_id)
	return Combat.RosterValidation.A.canonical_id(faction, unit_id)

func _local_visual_variant(model_id: int) -> String:
	if not state.units.has(model_id): return ""
	var unit: Dictionary = state.units[model_id]
	var owner := int(unit.get("owner", 0))
	if not local_visual_armies.has(owner): return ""
	var army: Dictionary = local_visual_armies[owner]
	var target_definition := str(unit.get("definition_id", ""))
	var squads: Array[int] = []
	for squad_id: int in state.squads:
		if int(state.squads[squad_id].get("owner", 0)) != owner: continue
		var squad_models: Array[int] = []
		for candidate_id: int in state.units:
			if int(state.units[candidate_id].get("squad", -1)) == squad_id: squad_models.append(candidate_id)
		if squad_models.is_empty(): continue
		squad_models.sort()
		if str(state.units[squad_models[0]].get("definition_id", "")) == target_definition: squads.append(squad_id)
	squads.sort()
	var target_group := squads.find(int(unit.get("squad", -1)))
	if target_group < 0: return ""
	var cursor := 0
	for entry: Dictionary in army.get("entries", []):
		if _canonical_visual_definition(str(army.get("faction", "")), str(entry.get("unit_id", ""))) != target_definition: continue
		var models := int(entry.get("models", 0))
		var visuals: Array = entry.get("visual_variants", []) if entry.get("visual_variants", []) is Array else []
		for copy_index in range(int(entry.get("copies", 1))):
			if cursor == target_group:
				var slot := copy_index * models + posmod(model_id, 100)
				return str(visuals[slot]) if slot >= 0 and slot < visuals.size() else ""
			cursor += 1
	return ""

func _create_health_tag(piece: MeshInstance3D, model_id: int) -> void:
	var health_root := Node3D.new()
	health_root.name = "HealthStatus"
	health_root.position = Vector3(0, 1.35, 0)
	piece.add_child(health_root)
	var back := MeshInstance3D.new()
	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(0.72, 0.065, 0.035)
	back.mesh = bar_mesh
	back.material_override = _material(Color("202a30"))
	back.position.y = 0.1
	health_root.add_child(back)
	var fill := MeshInstance3D.new()
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(0.68, 0.04, 0.04)
	fill.mesh = fill_mesh
	fill.position = Vector3(0, 0.1, -0.025)
	health_root.add_child(fill)
	var label := Label3D.new()
	label.name = "HealthText"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.009
	label.font_size = 42
	label.outline_size = 8
	label.outline_modulate = Color("10161b")
	label.modulate = Color("f1f4f5")
	label.position.y = 0.31
	label.text = "Wounds"
	health_root.add_child(label)
	health_tags[model_id] = {"root": health_root, "back": back, "fill": fill, "label": label}

func _show_board_feedback(model_id: int, message: String, tint: Color) -> void:
	if not pieces.has(model_id): return
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.01
	label.font_size = 60
	label.outline_size = 10
	label.outline_modulate = Color("10161b")
	label.modulate = tint
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pieces[model_id].position + Vector3(0, 1.55, 0)
	add_child(label)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", label.position.y + 0.65, 0.72)
	var faded := tint
	faded.a = 0.0
	tween.parallel().tween_property(label, "modulate", faded, 0.72)
	tween.tween_callback(label.queue_free)

func _board_motion_enabled() -> bool:
	return board_feedback_toggle != null and board_feedback_toggle.button_pressed and combat_tray.speed.selected != 2

func _finish_casualty_feedback() -> void:
	for model: int in casualty_tweens:
		casualty_tweens[model].tween.kill()
		if pieces.has(model):
			pieces[model].scale = casualty_tweens[model].scale
			pieces[model].visible = state.units.has(model) and int(state.units[model].get("wounds", 0)) > 0 and bool(state.units[model].get("on_battlefield", true))
	casualty_tweens.clear()

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
	panel.custom_minimum_size = Vector2(384, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.075, 0.09, 0.94)
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
	sidebar_title = Label.new()
	sidebar_title.text = "MATCH CONTROLS"
	sidebar_title.add_theme_font_size_override("font_size", 22)
	sidebar_title.add_theme_color_override("font_color", Color("f2df83"))
	header.add_child(sidebar_title)
	home_nav_button = _button(header, "Return to title screen", _open_home)
	home_nav_button.custom_minimum_size.y = 34
	combat_hud = CombatHud.new()
	layer.add_child(combat_hud)
	decision_label = combat_hud.decision_label
	objective_summary = combat_hud.objective_label
	session_label = combat_hud.connection_label
	combat_hud.menu_requested.connect(_open_home)
	combat_hud.focus_requested.connect(_focus_selected_unit)
	combat_hud.help_requested.connect(_open_help_screen)
	combat_hud.history_requested.connect(_open_history_screen)
	combat_hud.command_panel_requested.connect(_toggle_command_panel)
	match_tabs = TabContainer.new()
	match_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header.add_child(match_tabs)
	match_tabs.tab_changed.connect(func(tab: int):
		if tab == 2 and workshop_tabs != null:
			match_tabs.current_tab = 3
			workshop_tabs.current_tab = 1
			return
		if tab != 1: attack_feedback.clear()
		_layout_ui()
		if tab == 1 and not action_groups.is_empty(): _refresh()
	)
	var setup := _scroll_column(match_tabs, "New match")
	match_tabs.set_tab_title(0, "New match")
	setup.add_theme_constant_override("separation", 12)
	var column := _scroll_column(match_tabs, "Play")
	match_result_panel = preload("res://scripts/ui/match_result_panel.gd").new()
	match_result_panel.visible = false
	column.add_child(match_result_panel)
	match_result_panel.rematch_requested.connect(func(): _rematch_local())
	match_result_panel.copy_requested.connect(_copy_final_result)
	match_result_panel.save_requested.connect(func(): _save_final_result())
	match_result_panel.menu_requested.connect(_open_home)
	match_result_panel.folder_requested.connect(_open_result_folder)
	gameplay_scroll = column.get_parent() as ScrollContainer
	var models := _scroll_column(match_tabs, "Models")
	match_tabs.set_tab_title(2, "Models / Import")
	model_imports = ModelImports.new()
	model_imports.selected_definition = func():
		if army_builder != null and not army_builder.preview_entry.is_empty(): return str(army_builder.preview_entry.unit_id)
		return str(state.units[selected].get("definition_id", "")) if state.units.has(selected) else ""
	model_imports.selected_radius = func():
		if army_builder != null and not army_builder.preview_entry.is_empty(): return 0.0
		return float(state.units[selected].radius) if state.units.has(selected) else 0.0
	model_imports.selected_label = func(): return str(army_builder.preview_entry.name) if army_builder != null and not army_builder.preview_entry.is_empty() else model_imports._definition()
	model_imports.mappings_changed.connect(func():
		_spawn_pieces()
		if army_builder != null and not army_builder.preview_entry.is_empty(): army_builder._preview_entry(army_builder.preview_entry, army_builder.preview_slot)
		_refresh()
	)
	models.add_child(model_imports)
	var armies := _scroll_column(match_tabs, "Armies")
	workshop_scroll = armies.get_parent() as ScrollContainer
	army_builder = ArmyBuilder.new()
	army_builder.model_imports = model_imports
	model_imports.variants_changed.connect(func(_definition: String):
		army_builder._render_visual_slots()
		if not army_builder.preview_entry.is_empty(): army_builder._preview_entry(army_builder.preview_entry, army_builder.preview_slot)
		_spawn_pieces()
		_refresh()
	)
	model_imports.automatic_status.connect(func(message: String): army_builder.set_visual_status(message))
	armies.add_child(army_builder)
	match_tabs.set_tab_title(3, "Army & Models")
	match_tabs.set_tab_hidden(2, true)
	var workshop_header := HBoxContainer.new()
	armies.add_child(workshop_header)
	armies.move_child(workshop_header, 0)
	_button(workshop_header, "← Return to menu", _close_tactical_screen)
	workshop_tabs = TabContainer.new()
	armies.add_child(workshop_tabs)
	var roster_page := VBoxContainer.new()
	roster_page.name = "Army"
	workshop_tabs.add_child(roster_page)
	army_builder.reparent(roster_page)
	var import_page := VBoxContainer.new()
	import_page.name = "Import models"
	workshop_tabs.add_child(import_page)
	model_imports.reparent(import_page)
	model_imports.linked_unit_requested.connect(func(): workshop_tabs.current_tab = 0)
	model_imports.has_roster_context = func(): return not army_builder.preview_entry.is_empty()
	army_builder.import_requested.connect(func(): workshop_tabs.current_tab = 1)
	var history := _scroll_column(match_tabs, "History")
	history.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var tools := _scroll_column(match_tabs, "Tools")
	tools_scroll = tools.get_parent() as ScrollContainer
	history_scroll = history.get_parent() as ScrollContainer
	history_panel = MatchHistoryPanel.new()
	history_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	history.add_child(history_panel)
	history_panel.page_requested.connect(_history_page)
	history_panel.visibility_changed.connect(func():
		if history_panel.is_visible_in_tree() and tactical_overlay != null and tactical_overlay.visible: _history_page(-1))
	army_builder.library_changed.connect(_refresh_army_choices)
	var overview := _setup_section(setup, "START PLAYING", "Choose a match and get to the table.")
	scope_label = Label.new()
	scope_label.custom_minimum_size.x = 360
	scope_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(scope_label)
	var guided_intro := Label.new()
	guided_intro.text = "Gladius tactical training • Captain, Intercessors and Hellblasters vs Chaplain, Assault Intercessors and Bladeguard. Local free play with tips; asymmetric forces, partial support. Uses the prepared local catalog; no downloads."
	guided_intro.custom_minimum_size.x = 360
	guided_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overview.add_child(guided_intro)
	training_swap_choice = CheckBox.new()
	training_swap_choice.text = "Swap training sides (Player 1: Close Assault)"
	overview.add_child(training_swap_choice)
	training_swap_choice.toggled.connect(_set_training_swap)
	var guided_start := _button(overview, "Start tactical training", _start_guided_first_session)
	guided_start.custom_minimum_size.y = 42
	guided_start.tooltip_text = "Free play with contextual tips, current unit abilities and Core/Gladius stratagems. You control both players locally. Review list points below; full army legality and competitive balance are not certified."
	guided_start.add_theme_color_override("font_color", Color("101820"))
	var guided_style := StyleBoxFlat.new()
	guided_style.bg_color = Color("d9aa4f")
	guided_style.set_corner_radius_all(6)
	guided_style.content_margin_left = 8
	guided_style.content_margin_right = 8
	guided_start.add_theme_stylebox_override("normal", guided_style)
	var guided_hover := guided_style.duplicate() as StyleBoxFlat
	guided_hover.bg_color = Color("f1c875")
	guided_start.add_theme_stylebox_override("hover", guided_hover)
	var local_match := _setup_section(setup, "LOCAL MATCH • SAVED ARMIES", "Current catalog • fixed loadouts • partial rules support")
	for owner in [1, 2]:
		var owner_row := HBoxContainer.new()
		owner_row.add_theme_constant_override("separation", 8)
		local_match.add_child(owner_row)
		var owner_label := Label.new()
		owner_label.text = "P%d" % owner
		owner_label.custom_minimum_size.x = 30
		owner_row.add_child(owner_label)
		var picker := OptionButton.new()
		picker.fit_to_longest_item = false
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		picker.custom_minimum_size.x = 280
		owner_row.add_child(picker)
		saved_army_pickers[owner] = picker
		picker.item_selected.connect(func(_index: int): _review_saved_armies())
	var local_summary := Label.new()
	local_summary.custom_minimum_size.x = 360
	local_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_match.add_child(local_summary)
	saved_army_review = local_summary
	saved_army_start_button = _button(local_match, "Start local match", _start_saved_match)
	saved_army_start_button.custom_minimum_size.y = 42
	saved_army_start_button.add_theme_color_override("font_color", Color("f2df83"))
	var launch := _make_setup_foldout(setup, "More ways to play", "Local training modes with different levels of setup and rules scope.")
	var network := _make_setup_foldout(setup, "Play over LAN", "Use the lists selected above, accept the training scope, then Host or Join.")
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
	recovery_help.custom_minimum_size.x = 360
	network.add_child(recovery_help)
	var recovery := _make_setup_foldout(setup, "Resume a match", "Save or continue a match on this computer.")
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
	checked_rosters_choice = CheckBox.new()
	checked_rosters_choice.text = "Next prepared match: saved Incursion rosters (legacy prices)"
	checked_rosters_choice.tooltip_text = "Saved Gladius/Awakened rosters retain their MFM 1.6 price snapshot from 17 October and fixed loadouts. Wahapedia 11e is the rules source; implemented datasheets and effects remain partial, and full army legality is not certified."
	advanced.add_child(checked_rosters_choice)
	checked_rosters_choice.toggled.connect(func(active: bool):
		if active:
			official_mission_choice.button_pressed = true
			stratagem_choice.button_pressed = true
			reroll_choice.button_pressed = true
			attack_reroll_choice.button_pressed = true
			save_reroll_choice.button_pressed = true
			damage_reroll_choice.button_pressed = true
			hazard_reroll_choice.button_pressed = true
			count_reroll_choice.button_pressed = true
			escape_reroll_choice.button_pressed = true
		_refresh_army_choices())
	official_mission_choice = CheckBox.new()
	official_mission_choice.text = "Next prepared match: Chapter Approved 2026-27 mission"
	official_mission_choice.tooltip_text = "11th-edition primary mission, Hammer and Anvil, the selected Event Companion Take and Hold mirror terrain layout, and fixed Engage on All Fronts + Assassination. Current abilities required; reference points are not army legality certification."
	advanced.add_child(official_mission_choice)
	official_mission_choice.toggled.connect(func(active: bool):
		if active: unit_abilities_choice.button_pressed = true
		_refresh_official_layout_controls()
		_review_saved_armies())
	official_primary_heading = Label.new()
	official_primary_heading.text = "11e Primary Mission (mirror mission for both players)"
	official_primary_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_heading)
	official_primary_choice = OptionButton.new()
	for primary_id: String in Combat.Mission.PRIMARY_MISSIONS:
		official_primary_choice.add_item(str(Combat.Mission.PRIMARY_MISSIONS[primary_id].name))
		official_primary_choice.set_item_metadata(official_primary_choice.item_count - 1, primary_id)
	official_primary_choice.item_selected.connect(func(_index: int):
		_refresh_primary_mission_help()
		_refresh_official_layout_controls())
	advanced.add_child(official_primary_choice)
	official_primary_help = Label.new()
	official_primary_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_help)
	_refresh_primary_mission_help()
	official_layout_heading = Label.new()
	official_layout_heading.text = "11e Event Companion terrain · Take and Hold mirror"
	official_layout_heading.tooltip_text = "Terrain-only presets from the 11th-edition Event Companion. Mission, objectives, deployment and scoring remain unchanged; terrain is a ground-level proxy."
	official_layout_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_layout_heading)
	official_layout_choice = OptionButton.new()
	for option: Dictionary in Combat.Terrain.event_layout_options():
		official_layout_choice.add_item(str(option.label))
		official_layout_choice.set_item_metadata(official_layout_choice.item_count - 1, str(option.id))
	official_layout_choice.item_selected.connect(func(_index: int): _refresh_official_layout_preview())
	advanced.add_child(official_layout_choice)
	official_layout_preview = TextureRect.new()
	official_layout_preview.custom_minimum_size = Vector2(300, 205)
	official_layout_preview.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	official_layout_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	official_layout_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	advanced.add_child(official_layout_preview)
	official_layout_preview_status = Label.new()
	official_layout_preview_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_layout_preview_status)
	official_layout_choice.select(0)
	_refresh_official_layout_controls()
	unit_abilities_choice = CheckBox.new()
	unit_abilities_choice.text = "Next prepared match: implemented Wahapedia e11 unit abilities (partial)"
	unit_abilities_choice.tooltip_text = "Enables implemented 11th-edition abilities for admitted fixed profiles, including supported reserves and Leaders. Wahapedia 11e is the rules source. Historical Hail of Bolts and Objective Secured are incompatible; faction coverage and full army legality remain incomplete."
	advanced.add_child(unit_abilities_choice)
	unit_abilities_choice.toggled.connect(func(active: bool):
		if active:
			equipment_choice.button_pressed = false
			implacable_eradication_choice.button_pressed = false
			hail_of_bolts_choice.button_pressed = false
			objective_secured_choice.button_pressed = false
			oath_of_moment_choice.button_pressed = false
			reanimation_protocols_choice.button_pressed = true
			combat_doctrines_choice.button_pressed = true
			awakened_dynasty_choice.button_pressed = true
			stratagem_choice.button_pressed = true
		_review_saved_armies())
	awakened_dynasty_choice = CheckBox.new()
	awakened_dynasty_choice.text = "Next prepared match: 11e Awakened Dynasty"
	awakened_dynasty_choice.tooltip_text = "Command Protocols: +1 to hit for a unit led by a living Necron Character. Declare admitted Overlords standalone or attached to Warriors/Immortals before deployment. Supports Reanimation for admitted Overlord attachments; surviving leaders retain the bonus after bodyguard losses. Other detachment rules and full army legality remain pending. Both LAN players must agree."
	advanced.add_child(awakened_dynasty_choice)
	awakened_dynasty_choice.toggled.connect(func(_enabled: bool): _review_saved_armies())
	combat_doctrines_choice = CheckBox.new()
	combat_doctrines_choice.text = "Next prepared match: 11e Combat Doctrines + Space Marine detachment"
	combat_doctrines_choice.tooltip_text = "Enables the 11e army rule and a locally implemented detachment effect. Gladius adds one shared extra doctrine use; Adept of the Codex adds Tactical Doctrine to an eligible Captain, Artificer Armour gives its bearer Save 2+ and Feel No Pain 5+, Laurels of Triumph improves its bearer's melee Strength/AP, and Standard of the Emperor Ascendant improves an Ancient's OC/Leadership and grants Feel No Pain 5+, with a once-per-battle +1 melee Attack for its unit. Stormlance gives eligible Mounted and Speeder units +2 inches Movement. Ironclad Champions lets friendly Adeptus Astartes Dreadnought units re-roll hit rolls of 1 and implements all three stratagems and both enhancements. Local checks for these new Gladius and Ironclad paths, and full army legality, remain pending. Both LAN players must agree."
	advanced.add_child(combat_doctrines_choice)
	var marine_detachment_heading_p1 := Label.new()
	marine_detachment_heading_p1.text = "Player 1 Space Marine detachment"
	advanced.add_child(marine_detachment_heading_p1)
	marine_detachment_choice = OptionButton.new()
	marine_detachment_choice.add_item("Gladius Task Force — Codex Discipline")
	marine_detachment_choice.set_item_metadata(0, "gladius")
	marine_detachment_choice.add_item("Stormlance Task Force — Lightning-fast Strike")
	marine_detachment_choice.set_item_metadata(1, "stormlance")
	marine_detachment_choice.add_item("Ironclad Champions — Enduring Vengeance")
	marine_detachment_choice.set_item_metadata(2, "ironclad-champions")
	marine_detachment_choice.add_item("Assault Brethren — Assault Mastery")
	marine_detachment_choice.set_item_metadata(3, "assault-brethren")
	marine_detachment_choice.add_item("Tactical Brethren — Tactical Mastery")
	marine_detachment_choice.set_item_metadata(4, "tactical-brethren")
	marine_detachment_choice.add_item("Devastator Brethren — Devastator Mastery")
	marine_detachment_choice.set_item_metadata(5, "devastator-brethren")
	marine_detachment_choice.add_item("Terminator Storm Force — Death Blow")
	marine_detachment_choice.set_item_metadata(6, "terminator-storm-force")
	marine_detachment_choice.add_item("Tacticus Firestorm Force — Codex Fire-patterns")
	marine_detachment_choice.set_item_metadata(7, "tacticus-firestorm-force")
	marine_detachment_choice.add_item("Tacticus Attack Force — Wrath of the Chapter")
	marine_detachment_choice.set_item_metadata(8, "tacticus-attack-force")
	marine_detachment_choice.add_item("Gravis Linebreaker Force — Walking Fortress")
	marine_detachment_choice.set_item_metadata(9, "gravis-linebreaker-force")
	marine_detachment_choice.add_item("Wrath of the Rock — Dutiful Tenacity")
	marine_detachment_choice.set_item_metadata(10, "wrath-of-the-rock")
	marine_detachment_choice.add_item("Spearpoint Task Force — Storm-swift Onslaught")
	marine_detachment_choice.set_item_metadata(11, "spearpoint-task-force")
	marine_detachment_choice.add_item("Ironstorm Spearhead — Ironstorm Auto-targeters")
	marine_detachment_choice.set_item_metadata(12, "ironstorm-spearhead")
	marine_detachment_choice.add_item("Phobos Shock Force — Vanguard Ambushers")
	marine_detachment_choice.set_item_metadata(13, "phobos-shock-force")
	marine_detachment_choice.tooltip_text = "Select a locally implemented Space Marine detachment rule. Vanguard Ambushers marks friendly Phobos units hidden at the end of your Movement phase; their attacks re-roll Wound rolls of 1 until the end of that turn. Remaining Phobos Shock Force rules, local checks and full army legality remain pending. Ironstorm Auto-targeters lets a friendly Adeptus Astartes Vehicle unit other than a Walker optionally re-roll one Hit roll and one Wound roll during each ranged attack activation. Ironstorm also supports Redoubtable Machine Spirit (25 points: 5+ invulnerable save and heal 1 at Command end) and Gunnery Honours (15 points: ranged attacks gain Heavy) on eligible non-Transport, non-Fly, non-Walker vehicles. Gladius supports Adept of the Codex, Artificer Armour, Laurels of Triumph and Standard of the Emperor Ascendant on eligible units; the roster identifies the bearer for model-only enhancements. Ironclad Champions implements Enduring Vengeance, all three stratagems and both enhancements. Assault, Tactical and Devastator Brethren each allow their named Combat Doctrine one additional time per battle. Terminator Storm Force gives Adeptus Astartes Terminator units +1 to Charge rolls. Tacticus Firestorm Force grants Rapid Fire at any distance within maximum range for Tacticus units. Tacticus Attack Force lets Tacticus units re-roll Advance rolls. Gravis Linebreaker Force lets Gravis units that made a Normal move fire without Heavy and with +1 to Hit. Wrath of the Rock worsens Wound rolls by 1 against Astartes Infantry/Mounted targets when Strength exceeds Toughness. Spearpoint allows one extra Assault or Tactical Doctrine selection per battle and gives +1 to Advance rolls to friendly Adeptus Astartes Mounted/Speeder units. At Fight-phase end, if Suboden Khan's unit was eligible to fight this phase, it can make a Normal Move while unengaged or a Fall Back move while engaged, using the models' Movement characteristics. Selecting Spearpoint enables current unit abilities for that movement workflow. The White Scars-only chapter restriction is enforced for current runtime profiles. Other detachment rules, interactions and full army legality remain pending."
	advanced.add_child(marine_detachment_choice)
	marine_detachment_choice.item_selected.connect(func(_index: int):
		marine_detachment = _selected_marine_detachment()
		marine_detachments = _selected_marine_detachments()
		if marine_detachment == "spearpoint-task-force" and unit_abilities_choice != null: unit_abilities_choice.button_pressed = true
		_review_saved_armies())
	var marine_detachment_heading_p2 := Label.new()
	marine_detachment_heading_p2.text = "Player 2 Space Marine detachment"
	advanced.add_child(marine_detachment_heading_p2)
	marine_detachment_choice_p2 = OptionButton.new()
	for index in marine_detachment_choice.item_count:
		marine_detachment_choice_p2.add_item(marine_detachment_choice.get_item_text(index))
		marine_detachment_choice_p2.set_item_metadata(index, marine_detachment_choice.get_item_metadata(index))
	marine_detachment_choice_p2.tooltip_text = "Choose Player 2's detachment independently. LAN peers must use the same per-player selections."
	advanced.add_child(marine_detachment_choice_p2)
	marine_detachment_choice_p2.item_selected.connect(func(_index: int):
		marine_detachment_p2 = _selected_marine_detachment_for(marine_detachment_choice_p2)
		marine_detachments = _selected_marine_detachments()
		if marine_detachment_p2 == "spearpoint-task-force" and unit_abilities_choice != null: unit_abilities_choice.button_pressed = true
		_review_saved_armies())
	combat_doctrines_choice.toggled.connect(func(active: bool):
		marine_detachment = _selected_marine_detachment() if active else "none"
		marine_detachments = _selected_marine_detachments() if active else {1: "none", 2: "none"}
		_review_saved_armies())
	reanimation_protocols_choice = CheckBox.new()
	reanimation_protocols_choice.text = "Next prepared match: Reanimation Protocols"
	reanimation_protocols_choice.tooltip_text = "September 2026 faction rule, limited to Warriors/Immortals, living Overlords and admitted Overlord attachments. End of own Command: roll D3 per living unit, preview returned troop models, then confirm. Heal surviving models first, then return troops. Slain Characters are unsupported. Resurrection Orb and other datasheet abilities require the current unit abilities option. Both LAN players must agree."
	advanced.add_child(reanimation_protocols_choice)
	oath_of_moment_choice = CheckBox.new()
	oath_of_moment_choice.text = "Legacy training option: Oath of Moment (June 2026 profile)"
	oath_of_moment_choice.tooltip_text = "Isolated historical training rule: select an enemy at the start of your Command phase. Marine attacks against it re-roll failed hits and use the recorded +1 wound condition. This is not current Wahapedia 11e support. Other detachment rules are disabled. Both LAN players must agree."
	advanced.add_child(oath_of_moment_choice)
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
	var saved_lists := _make_setup_foldout(roster_page, "Two-army training match", "Choose saved lists for local or LAN training. This uses partial rules; official army legality is not certified.")
	_button(saved_lists, "Refresh profile lists", _refresh_army_choices)
	var saved_lists_help := Label.new()
	saved_lists_help.text = "Choose lists on the New match screen. This section contains LAN consent and model-download options."
	saved_lists_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	saved_lists.add_child(saved_lists_help)
	for owner in [1, 2]:
		_button(saved_lists, "Save a copy of player %d's list to my profile" % owner, func(): _save_selected_army(owner))
	auto_models = CheckBox.new()
	auto_models.text = "Download and link ForceOrg models automatically"
	auto_models.button_pressed = true
	saved_lists.add_child(auto_models)
	local_model_status = Label.new()
	local_model_status.custom_minimum_size.x = 360
	local_model_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_model_status.text = "Models: ForceOrg catalog and compatible miniatures download automatically. Saved links are reused."
	saved_lists.add_child(local_model_status)
	var model_play_notice := Label.new()
	model_play_notice.custom_minimum_size.x = 360
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
	setup_notice = Label.new()
	setup_notice.custom_minimum_size.x = 360
	setup_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	saved_lists.add_child(setup_notice)
	saved_training_consent = CheckBox.new()
	saved_training_consent.text = "LAN: accept partial training rules"
	network.add_child(saved_training_consent)
	_refresh_army_choices()
	match_tabs.set_tab_title(5, "Tools")
	var labs := _setup_section(tools, "PRACTICE LABS", "Optional rules exercises and local development tools.")
	_button(labs, "Rules lab • mixed defense / Precision", _start_allocation_practice)
	_button(labs, "Local preview / disconnect", func(): _offline("Local preview: control both sides."))
	_button(labs, "11th edition attack sequence lab", func():
		session_transport.reset()
		get_tree().change_scene_to_file("res://scenes/attack_lab.tscn")
	)
	action_unit_picker = OptionButton.new()
	action_unit_picker.fit_to_longest_item = false
	action_unit_picker.custom_minimum_size.y = 36
	action_unit_picker.item_selected.connect(_choose_action_unit)
	column.add_child(action_unit_picker)
	var selected_card := PanelContainer.new()
	selected_card.custom_minimum_size.x = 360
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = Color("172129")
	selected_style.border_color = Color("536b78")
	selected_style.set_border_width_all(1)
	selected_style.border_width_left = 3
	selected_style.set_corner_radius_all(6)
	selected_style.content_margin_left = 10
	selected_style.content_margin_right = 10
	selected_style.content_margin_top = 7
	selected_style.content_margin_bottom = 7
	selected_card.add_theme_stylebox_override("panel", selected_style)
	column.add_child(selected_card)
	var selected_content := VBoxContainer.new()
	selected_content.add_theme_constant_override("separation", 5)
	selected_card.add_child(selected_content)
	selection_card = Label.new()
	selection_card.custom_minimum_size.x = 340
	selection_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_card.add_theme_font_size_override("font_size", 14)
	selection_card.add_theme_color_override("font_color", Color("e6edf0"))
	selected_content.add_child(selection_card)
	datasheet_button = Button.new()
	datasheet_button.text = "Show unit datasheet"
	datasheet_button.toggle_mode = true
	datasheet_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	datasheet_button.visible = false
	selected_content.add_child(datasheet_button)
	datasheet_details = Label.new()
	datasheet_details.custom_minimum_size.x = 340
	datasheet_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	datasheet_details.add_theme_font_size_override("font_size", 12)
	datasheet_details.add_theme_color_override("font_color", Color("c4d0d7"))
	datasheet_details.visible = false
	selected_content.add_child(datasheet_details)
	datasheet_button.toggled.connect(func(expanded: bool):
		datasheet_details.visible = expanded
		datasheet_button.text = "Hide unit datasheet" if expanded else "Show unit datasheet"
	)
	contact_flow = preload("res://scripts/ui/decision_steps.gd").new()
	contact_flow.visible = false
	column.add_child(contact_flow)
	first_session_panel = PanelContainer.new()
	first_session_panel.custom_minimum_size.x = 360
	first_session_panel.visible = false
	var guide_card_style := StyleBoxFlat.new()
	guide_card_style.bg_color = Color("18212b")
	guide_card_style.border_color = Color("d9aa4f")
	guide_card_style.set_border_width_all(2)
	guide_card_style.set_corner_radius_all(8)
	guide_card_style.content_margin_left = 12
	guide_card_style.content_margin_right = 12
	guide_card_style.content_margin_top = 10
	guide_card_style.content_margin_bottom = 10
	first_session_panel.add_theme_stylebox_override("panel", guide_card_style)
	column.add_child(first_session_panel)
	var first_session_content := VBoxContainer.new()
	first_session_content.add_theme_constant_override("separation", 7)
	first_session_panel.add_child(first_session_content)
	first_session_heading = Label.new()
	first_session_heading.add_theme_color_override("font_color", Color("f2df83"))
	first_session_content.add_child(first_session_heading)
	first_session_progress = ProgressBar.new()
	first_session_progress.min_value = 0
	first_session_progress.max_value = 10
	first_session_progress.show_percentage = false
	first_session_progress.custom_minimum_size.y = 8
	first_session_content.add_child(first_session_progress)
	first_session_guide = Label.new()
	first_session_guide.custom_minimum_size.x = 376
	first_session_guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_session_content.add_child(first_session_guide)
	first_session_boundary = RichTextLabel.new()
	first_session_boundary.bbcode_enabled = true
	first_session_boundary.fit_content = true
	first_session_boundary.scroll_active = false
	first_session_boundary.custom_minimum_size.x = 376
	first_session_content.add_child(first_session_boundary)
	first_session_experiments = Label.new()
	first_session_experiments.custom_minimum_size.x = 376
	first_session_experiments.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_session_experiments.add_theme_font_size_override("font_size", 11)
	first_session_experiments.add_theme_color_override("font_color", Color("b7c8d2"))
	first_session_experiments.visible = false
	first_session_content.add_child(first_session_experiments)
	var keyword_heading := Label.new()
	keyword_heading.visible = false
	first_session_content.add_child(keyword_heading)
	first_session_terms = HFlowContainer.new()
	first_session_terms.add_theme_constant_override("h_separation", 6)
	first_session_terms.add_theme_constant_override("v_separation", 4)
	first_session_content.add_child(first_session_terms)
	decision_details = Label.new()
	decision_details.custom_minimum_size.x = 360
	decision_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(decision_details)
	technical_toggle = CheckButton.new()
	technical_toggle.text = "Show equipment and technical details"
	technical_toggle.toggled.connect(func(expanded: bool): details.visible = expanded)
	column.add_child(technical_toggle)
	details = Label.new()
	details.visible = false
	details.custom_minimum_size.x = 360
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(details)
	reanimation_help = Label.new()
	reanimation_help.custom_minimum_size.x = 360
	reanimation_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reanimation_help.tooltip_text = "Return within 2 inches of a surviving model present at Command entry, and within 9 inches of every unit member. Returned models cannot extend the anchor chain or create engagement with a new enemy unit. Purple previews do not restore wounds or capture objectives until confirmed."
	column.add_child(reanimation_help)
	reanimation_squad = OptionButton.new()
	column.add_child(reanimation_squad)
	reanimation_roll = _button(column, "Roll selected unit's Reanimation D3", _request_reanimation.bind("roll"))
	reanimation_model = OptionButton.new()
	column.add_child(reanimation_model)
	reanimation_model.item_selected.connect(_reanimation_model_selected)
	reanimation_x = SpinBox.new()
	reanimation_z = SpinBox.new()
	for coordinate in [reanimation_x, reanimation_z]:
		coordinate.min_value = -50
		coordinate.max_value = 50
		coordinate.step = 0.05
		column.add_child(coordinate)
	reanimation_x.prefix = "Base centre X: "
	reanimation_z.prefix = "Base centre Z: "
	reanimation_place = _button(column, "Preview model at X/Z (or right-click board)", _request_reanimation.bind("place"))
	reanimation_suggest = _button(column, "Suggest return positions", _request_reanimation.bind("suggest"))
	reanimation_failure = _button(column, "Declare selected model cannot be placed", _request_reanimation.bind("unplaceable"))
	reanimation_failure.tooltip_text = "Controller declaration, recorded in the match. This does not prove that no legal position exists. The model remains destroyed."
	reanimation_reset = _button(column, "Reset preview (keep original D3)", _request_reanimation.bind("reset"))
	reanimation_confirm = _button(column, "Confirm this unit's Reanimation", _request_reanimation.bind("confirm"))
	awakened_help = Label.new()
	awakened_help.custom_minimum_size.x = 360
	awakened_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(awakened_help)
	awakened_target = OptionButton.new()
	awakened_target.fit_to_longest_item = false
	column.add_child(awakened_target)
	unit_action_help = Label.new()
	unit_action_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(unit_action_help)
	unit_details_button = _button(column, "Details for this choice", _open_unit_choice_help)
	unit_action_picker = OptionButton.new()
	unit_action_picker.fit_to_longest_item = false
	unit_action_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	unit_action_picker.item_selected.connect(func(_index: int): _refresh_unit_actions())
	column.add_child(unit_action_picker)
	doctrine_action_panel = preload("res://scripts/ui/doctrine_choice.gd").new()
	doctrine_action_panel.visible = false
	column.add_child(doctrine_action_panel)
	doctrine_action_panel.choice_selected.connect(func(choice: Dictionary):
		for index in range(unit_action_picker.item_count):
			if unit_action_picker.get_item_metadata(index) == choice:
				unit_action_picker.select(index)
				_refresh_unit_actions()
				break
	)
	unit_action_x = SpinBox.new()
	unit_action_x.min_value = -100
	unit_action_x.max_value = 100
	unit_action_x.step = 0.1
	unit_action_x.prefix = "Ability X: "
	column.add_child(unit_action_x)
	unit_action_z = SpinBox.new()
	unit_action_z.min_value = -100
	unit_action_z.max_value = 100
	unit_action_z.step = 0.1
	unit_action_z.prefix = "Ability Z: "
	column.add_child(unit_action_z)
	unit_action_button = _button(column, "Use ability / confirm choice", _request_unit_action)
	unit_action_button.custom_minimum_size.y = 40
	network_army_status = Label.new()
	network_army_status.custom_minimum_size.x = 360
	network_army_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(network_army_status)
	network_army_picker = OptionButton.new()
	network_army_picker.fit_to_longest_item = false
	network_army_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	network_army_picker.custom_minimum_size.x = 360
	network_army_picker.item_selected.connect(_network_army_selected)
	column.add_child(network_army_picker)
	network_army_submit = _button(column, "Submit my army list", _submit_saved_army)
	network_army_submit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	network_army_submit.custom_minimum_size.x = 360
	network_army_submit.custom_minimum_size.y = 42
	setup_preparation_status = Label.new()
	setup_preparation_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setup_preparation_status.add_theme_color_override("font_color", Color("f2df83"))
	column.add_child(setup_preparation_status)
	setup_required_status = Label.new()
	setup_required_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(setup_required_status)
	setup_feedback_status = Label.new()
	setup_feedback_status.custom_minimum_size.x = 360
	setup_feedback_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setup_feedback_status.add_theme_color_override("font_color", Color("8ad9a7"))
	column.add_child(setup_feedback_status)
	setup_finish_button = _button(column, "Finish army preparations", _request_setup_finish)
	setup_finish_button.custom_minimum_size.y = 42
	setup_finish_button.add_theme_color_override("font_color", Color("f2df83"))
	setup_decisions_heading = Label.new()
	setup_decisions_heading.text = "Army decisions and declarations"
	setup_decisions_heading.add_theme_color_override("font_color", Color("e3b75c"))
	column.add_child(setup_decisions_heading)
	setup_equipment_toggle = Button.new()
	setup_equipment_toggle.text = "Customize equipment  ▸"
	setup_equipment_toggle.pressed.connect(func():
		setup_equipment_open = not setup_equipment_open
		setup_equipment_toggle.text = "Customize equipment  ▾" if setup_equipment_open else "Customize equipment  ▸"
		_refresh_unit_actions()
	)
	column.add_child(setup_equipment_toggle)
	setup_equipment_list = VBoxContainer.new()
	setup_equipment_list.add_theme_constant_override("separation", 8)
	column.add_child(setup_equipment_list)
	awakened_confirm = _button(column, "Confirm Overlord attachment / standalone", _request_awakened_attachment)
	doctrine_help = Label.new()
	doctrine_help.custom_minimum_size.x = 360
	doctrine_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(doctrine_help)
	doctrine_choice = OptionButton.new()
	doctrine_choice.fit_to_longest_item = false
	column.add_child(doctrine_choice)
	doctrine_confirm = _button(column, "Confirm doctrine / no doctrine", _request_combat_doctrine)
	oath_help = Label.new()
	oath_help.custom_minimum_size.x = 360
	oath_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(oath_help)
	oath_target = OptionButton.new()
	oath_target.fit_to_longest_item = false
	column.add_child(oath_target)
	oath_confirm = _button(column, "Confirm Oath of Moment target", _request_oath_target)
	reaction_help = Label.new()
	reaction_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reaction_help.custom_minimum_size.x = 360
	column.add_child(reaction_help)
	reaction_dice_hint = Label.new()
	reaction_dice_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(reaction_dice_hint)
	reaction_dice = HFlowContainer.new()
	reaction_dice.add_theme_constant_override("h_separation", 6)
	reaction_dice.add_theme_constant_override("v_separation", 6)
	column.add_child(reaction_dice)
	reaction_die = OptionButton.new()
	reaction_die.fit_to_longest_item = false
	reaction_die.item_selected.connect(func(_index: int): _refresh())
	column.add_child(reaction_die)
	reaction_squad = OptionButton.new()
	reaction_squad.item_selected.connect(func(_index: int): _refresh())
	column.add_child(reaction_squad)
	reaction_roll = _button(column, "Keep result · 0 CP", func(): _request_command_reaction(""))
	reaction_use = _button(column, "Command Re-roll · 1 CP", _request_use_reaction)
	reaction_roll.custom_minimum_size.y = 44
	reaction_use.custom_minimum_size.y = 44
	reaction_sudden = _button(column, "Sudden Storm: re-roll Advance • 0 CP", func():
		var window := Combat.Stratagems.pending(state)
		var reroll_source := "sudden-storm"
		if window.get("valour", false): reroll_source = "unstoppable-valour"
		elif window.get("master_shadows", false): reroll_source = "master-shadows"
		elif window.get("supercharged", false): reroll_source = "supercharged-engines"
		elif window.get("stormseers_wisdom", false): reroll_source = "stormseers-wisdom"
		elif window.get("honour_vigilance", false): reroll_source = "honour-of-vigilance"
		elif window.get("wrath_chapter", false): reroll_source = "wrath-of-the-chapter"
		_request_command_reaction(reroll_source)
	)
	movement_choice = OptionButton.new()
	var movement_options := [
		{"label": "Normal move", "type": "normal"},
		{"label": "Advance (D6)", "type": "advance"},
		{"label": "Fall Back: Ordered Retreat", "type": "ordered_retreat"},
		{"label": "Fall Back: Desperate Escape", "type": "desperate_escape"},
		{"label": "Remain stationary", "type": "stationary"}
	]
	for option: Dictionary in movement_options:
		movement_choice.add_item(str(option.label))
		movement_choice.set_item_tooltip(movement_choice.item_count - 1, KeywordGlossary.describe_move_type(str(option.type)))
	movement_choice.tooltip_text = "Choose a move type. Hover an option for its eligibility and consequences under Core Rules §09."
	movement_choice.item_selected.connect(func(_index: int): _refresh())
	column.add_child(movement_choice)
	sudden_onslaught_choice = CheckBox.new()
	sudden_onslaught_choice.text = "Sudden Onslaught • spend 1 CP to set Advance to 6"
	sudden_onslaught_choice.tooltip_text = "Stormlance Task Force Stratagem. Declare it when this Mounted/Speeder unit is selected to Advance; replace its Advance D6 with 6 before other modifiers. It uses the unit's one stratagem for this phase."
	sudden_onslaught_choice.toggled.connect(func(_active: bool): _refresh())
	column.add_child(sudden_onslaught_choice)
	movement_choices = preload("res://scripts/ui/movement_choices.gd").new()
	column.add_child(movement_choices)
	movement_choices.choice_selected.connect(func(index: int): movement_choice.select(index); _refresh())
	begin_move_button = _button(column, "Begin move", _request_begin_movement)
	begin_move_button.tooltip_text = "Start the selected move for the unit. Review any roll or required decision before placing models; positions are committed only when you confirm squad movement."
	escape_wound_button = _button(column, "Allocate escape wound to selected model", _request_escape_wound)
	finish_move_button = _button(column, "Confirm move", func(): _request_finish_movement(false))
	finish_move_button.tooltip_text = "Confirm the current model positions for this move. The movement validator checks distance, placement and coherency before applying them."
	cancel_move_button = _button(column, "Cancel pending movement", func(): _request_finish_movement(true))
	abandon_move_button = _button(column, "Abandon Fall Back (retain casualties)", _request_abandon_fall_back)
	coherency_button = _button(column, "Remove selected model for coherency", _request_coherency_removal)
	allocate_button = _button(column, "Allocate next damaging attack to selected model", _request_allocate_damage)
	precision_skip = _button(column, "Do not use Precision", _request_skip_precision)
	defense_steps = Label.new()
	defense_steps.custom_minimum_size.x = 360
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
	charge_button.tooltip_text = KeywordGlossary.describe_charge_roll()
	charge_targets = VBoxContainer.new()
	charge_targets.visible = false
	column.add_child(charge_targets)
	begin_contact_button = _button(column, "Begin contact movement", _request_begin_contact)
	consolidation_objective = OptionButton.new()
	column.add_child(consolidation_objective)
	contact_enemy = OptionButton.new()
	column.add_child(contact_enemy)
	confirm_contact_button = _button(column, "Confirm contact movement", func(): _request_finish_contact(false))
	cancel_contact_button = _button(column, "Cancel contact placement (retain roll)", func(): _request_finish_contact(true))
	lethal_choice = CheckBox.new()
	lethal_choice.text = "Use Lethal Hits automatic wounds"
	lethal_choice.tooltip_text = KeywordGlossary.describe_lethal_choice()
	lethal_choice.button_pressed = true
	column.add_child(lethal_choice)
	plan_begin = _button(column, "Plan attacks", _begin_attack_plan)
	shooting_complete = Label.new()
	shooting_complete.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shooting_complete.text = "✓ Shooting complete"
	column.add_child(shooting_complete)
	plan_steps = Label.new()
	plan_steps.custom_minimum_size.x = 360
	plan_steps.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(plan_steps)
	plan_assignment_status = Label.new()
	plan_assignment_status.custom_minimum_size.x = 360
	plan_assignment_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plan_assignment_status.add_theme_font_size_override("font_size", 12)
	plan_assignment_status.add_theme_color_override("font_color", Color("d6e0e4"))
	column.add_child(plan_assignment_status)
	plan_hail = OptionButton.new()
	plan_hail.fit_to_longest_item = false
	plan_hail.tooltip_text = "Optional Hail of Bolts target, selected before confirming all attacks. Only bolt rifles assigned to this unit gain +2 attacks."
	plan_hail.item_selected.connect(func(index: int):
		if attack_draft.is_empty(): return
		attack_draft.hail_target = -1 if index == 0 else plan_hail.get_item_id(index)
		_refresh())
	column.add_child(plan_hail)
	indirect_choice = CheckBox.new()
	indirect_choice.text = "Use Indirect Shooting"
	indirect_choice.tooltip_text = "For an unengaged unit that did not Advance and has an Indirect Fire weapon: indirect attacks grant cover, cannot re-roll hits, and unmodified 1–5 fail (1–3 if stationary and a friendly unit sees the target)."
	indirect_choice.toggled.connect(func(value: bool):
		if attack_draft.is_empty(): return
		attack_draft.indirect_shooting = value
		_refresh())
	column.add_child(indirect_choice)
	plan_weapon = OptionButton.new()
	plan_weapon.fit_to_longest_item = false
	plan_weapon.tooltip_text = "Hover a weapon profile to read explanations for its listed 11e abilities. Only the mechanics enabled by this match are resolved."
	plan_weapon.item_selected.connect(func(_index: int): _refresh())
	column.add_child(plan_weapon)
	plan_target = OptionButton.new()
	plan_target.fit_to_longest_item = false
	plan_target.tooltip_text = KeywordGlossary.describe_attack_target()
	plan_target.item_selected.connect(func(_index: int): _refresh())
	column.add_child(plan_target)
	plan_amount = SpinBox.new()
	plan_amount.min_value = 1
	plan_amount.step = 1
	column.add_child(plan_amount)
	plan_add = _button(column, "Assign", _assign_attack)
	plan_clear = _button(column, "Clear this model", _clear_attack_model)
	plan_summary = Label.new()
	plan_summary.custom_minimum_size.x = 360
	plan_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plan_summary.add_theme_color_override("font_color", Color("d8e3e7"))
	column.add_child(plan_summary)
	damage_preview = Label.new()
	damage_preview.custom_minimum_size.x = 360
	damage_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	damage_preview.add_theme_color_override("font_color", Color("f2c879"))
	column.add_child(damage_preview)
	plan_confirm = _button(column, "Confirm attacks", _confirm_attack_plan)
	plan_cancel = _button(column, "Cancel plan", func(): attack_draft = {}; _refresh())
	status = Label.new()
	status.custom_minimum_size.x = 360
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "Local preview: control both sides."
	column.add_child(status)
	column.move_child(status, 0)
	notice_heading = Label.new()
	notice_heading.visible = false
	column.add_child(notice_heading)
	column.move_child(notice_heading, 0)
	controls_help = Label.new()
	controls_help.text = "Left: select miniature • Right: move / target\nWheel: zoom • Middle drag: orbit • WASD: pan"
	column.add_child(controls_help)
	result_summary = Label.new()
	result_summary.custom_minimum_size.x = 360
	result_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(result_summary)
	health_overlay_toggle = CheckButton.new()
	health_overlay_toggle.text = "Show Wounds and status above models"
	health_overlay_toggle.tooltip_text = "W means Wounds; each tag shows current/maximum Wounds plus a bar. Green means over 50%, amber means over 25% through 50%, and red means 25% or less. The selected model also shows OC, Battle-shocked and Moved status in text."
	health_overlay_toggle.button_pressed = true
	health_overlay_toggle.toggled.connect(func(_enabled: bool): _refresh_health_tags())
	column.add_child(health_overlay_toggle)
	board_feedback_toggle = CheckButton.new()
	board_feedback_toggle.text = "Animate board and camera"
	board_feedback_toggle.button_pressed = true
	board_feedback_toggle.tooltip_text = "Animate camera focus, models and resolved attack links. Gold arrows link attacker to target; orange rings mean damage applied, pale cyan means none. These are schematic cues, not projectile paths or visibility checks."
	board_feedback_toggle.toggled.connect(func(enabled: bool):
		if not enabled:
			_stop_camera_motion()
			attack_feedback.clear()
			_finish_casualty_feedback()
	)
	column.add_child(board_feedback_toggle)
	auto_frame_toggle = CheckButton.new()
	auto_frame_toggle.text = "Auto-frame decisions"
	auto_frame_toggle.button_pressed = true
	auto_frame_toggle.tooltip_text = "Frame the unit involved in supported decisions. Pan, orbit or zoom takes manual control until the next decision. Camera only."
	auto_frame_toggle.toggled.connect(func(enabled: bool):
		_stop_camera_motion()
		if enabled:
			last_camera_key = ""
			call_deferred("_refresh_decision_camera")
	)
	column.add_child(auto_frame_toggle)
	dice_toggle = CheckButton.new()
	dice_toggle.text = "Show attack details"
	dice_toggle.tooltip_text = "Open the recorded attack breakdown and final D6 faces. This does not generate a new roll."
	dice_toggle.visible = false
	dice_toggle.toggled.connect(_set_dice_details_visible)
	column.add_child(dice_toggle)
	dice_visual = VBoxContainer.new()
	dice_visual.add_theme_constant_override("separation", 5)
	column.add_child(dice_visual)
	var dice_heading := Label.new()
	dice_heading.text = "RECORDED D6"
	dice_visual.add_child(dice_heading)
	var dice_explanation := Label.new()
	dice_explanation.text = "Final faces used by the attack. The brief reveal shows these saved values; it does not roll again."
	dice_explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dice_explanation.add_theme_color_override("font_color", Color("aeb9c0"))
	dice_visual.add_child(dice_explanation)
	dice_audit_label = Label.new()
	dice_audit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dice_visual.add_child(dice_audit_label)
	dice_animation_toggle = CheckButton.new()
	dice_animation_toggle.text = "Animate dice reveals"
	dice_animation_toggle.button_pressed = true
	dice_animation_toggle.tooltip_text = "Briefly reveal each final face already rolled by the game. This does not generate or change dice."
	dice_visual.add_child(dice_animation_toggle)
	combat_audio_toggle = CheckButton.new()
	combat_audio_toggle.text = "Combat sound cues"
	combat_audio_toggle.button_pressed = true
	combat_audio_toggle.toggled.connect(func(enabled: bool):
		combat_tray.sound_enabled = enabled
		if not enabled: combat_tray.sound.stop()
	)
	dice_visual.add_child(combat_audio_toggle)
	var tray := PanelContainer.new()
	var tray_style := StyleBoxFlat.new()
	tray_style.bg_color = Color("191d21")
	tray_style.border_color = Color("756646")
	tray_style.set_border_width_all(1)
	tray_style.set_corner_radius_all(10)
	tray_style.content_margin_left = 9
	tray_style.content_margin_right = 9
	tray_style.content_margin_top = 9
	tray_style.content_margin_bottom = 9
	tray_style.shadow_color = Color(0, 0, 0, 0.28)
	tray_style.shadow_size = 3
	tray_style.shadow_offset = Vector2(0, 2)
	tray.add_theme_stylebox_override("panel", tray_style)
	dice_visual.add_child(tray)
	dice_visual_rolls = HFlowContainer.new()
	dice_visual_rolls.add_theme_constant_override("h_separation", 4)
	dice_visual_rolls.add_theme_constant_override("v_separation", 4)
	dice_visual_rolls.custom_minimum_size = Vector2(390, 64)
	tray.add_child(dice_visual_rolls)
	log_toggle = CheckButton.new()
	log_toggle.text = "Show combat history"
	log_toggle.toggled.connect(func(expanded: bool): event_log.visible = combat_enabled and expanded)
	column.add_child(log_toggle)
	event_log = RichTextLabel.new()
	event_log.visible = false
	event_log.custom_minimum_size = Vector2(400, 130)
	column.add_child(event_log)
	deployment_help = Label.new()
	deployment_help.custom_minimum_size.x = 360
	deployment_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(deployment_help)
	deployment_preset_button = _button(column, "Use preview positions", _request_deployment_preset)
	deployment_confirm_button = _button(column, "Confirm deployment", _request_end)
	blockers_button = _button(column, "Why unavailable?", _open_blockers_help)
	waiting_unit_picker = OptionButton.new()
	waiting_unit_picker.fit_to_longest_item = false
	waiting_unit_picker.tooltip_text = "Inspect your units while the other player decides. Selection and Focus are local only; no action is submitted."
	waiting_unit_picker.item_selected.connect(_inspect_waiting_unit)
	column.add_child(waiting_unit_picker)
	waiting_activity = VBoxContainer.new()
	column.add_child(waiting_activity)
	var activity_heading := Label.new()
	activity_heading.text = "Last recorded"
	activity_heading.add_theme_color_override("font_color", Color("a5afb5"))
	waiting_activity.add_child(activity_heading)
	waiting_activity_text = Label.new()
	waiting_activity_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	waiting_activity_text.max_lines_visible = 2
	waiting_activity_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	waiting_activity.add_child(waiting_activity_text)
	_button(waiting_activity, "View history", _open_waiting_history)
	_build_action_groups(column)
	column.move_child(first_session_panel, 0)
	column.move_child(status, 0)
	# Keep the current decision separate from reference material and preferences.
	var reference := _scroll_column(match_tabs, "Help")
	help_scroll = reference.get_parent() as ScrollContainer
	var field_guide := RichTextLabel.new()
	field_guide.bbcode_enabled = true
	field_guide.fit_content = true
	field_guide.scroll_active = false
	field_guide.custom_minimum_size.x = 360
	field_guide.text = "[color=#e3b75c][b]TURN RAIL[/b][/color]\nThe gold phase is active. R# and P# show the round and active player; the decision line identifies who has priority now.\n\n[color=#e3b75c][b]CURRENT ACTION[/b][/color]\nThe banner below the rail names who acts and the next required task. Follow the available controls in the Command panel; phase progression stays gated while required choices remain.\n\n[color=#e3b75c][b]TABLE CONTROLS[/b][/color]\nLeft-click a miniature to select it. Right-click to place a move or choose a target. Use the wheel to zoom, middle-drag to orbit and WASD to pan. Focus or F centers the selected unit.\n\n[color=#e3b75c][b]READ-ONLY PANELS[/b][/color]\nHelp, Settings and the battle log are local screens. Reading them does not submit a gameplay action. LAN matches continue while they are open."
	reference.add_child(field_guide)
	blockers_reference = Label.new()
	blockers_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blockers_reference.custom_minimum_size.x = 360
	reference.add_child(blockers_reference)
	blockers_rules_toggle = CheckButton.new()
	blockers_rules_toggle.text = "Show rule references"
	reference.add_child(blockers_rules_toggle)
	blockers_rules = Label.new()
	blockers_rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blockers_rules.custom_minimum_size.x = 360
	blockers_rules.visible = false
	reference.add_child(blockers_rules)
	blockers_rules_toggle.toggled.connect(func(expanded: bool): blockers_rules.visible = expanded)
	unit_choice_reference = Label.new()
	unit_choice_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unit_choice_reference.custom_minimum_size.x = 360
	reference.add_child(unit_choice_reference)
	reaction_reference = Label.new()
	reaction_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reaction_reference.custom_minimum_size.x = 360
	reference.add_child(reaction_reference)
	reaction_die.reparent(reference)
	defense_reference = Label.new()
	defense_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	defense_reference.custom_minimum_size.x = 360
	reference.add_child(defense_reference)
	contact_reference = Label.new()
	contact_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contact_reference.custom_minimum_size.x = 360
	reference.add_child(contact_reference)
	movement_reference = Label.new()
	movement_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	movement_reference.custom_minimum_size.x = 360
	reference.add_child(movement_reference)
	attack_reference = Label.new()
	attack_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	attack_reference.custom_minimum_size.x = 360
	attack_reference.text = "Attacks: select a model, choose its weapon and target, then Assign. Repeat for other models. Review the assignments before confirming. Cancel discards the draft."
	reference.add_child(attack_reference)
	for control: Control in [technical_toggle, details, decision_details, health_overlay_toggle, board_feedback_toggle, auto_frame_toggle, log_toggle, event_log, controls_help]:
		control.reparent(reference)
	var tutorial_details := VBoxContainer.new()
	tutorial_details.add_theme_constant_override("separation", 6)
	reference.add_child(tutorial_details)
	reference.move_child(tutorial_details, 0)
	var tutorial_details_heading := Label.new()
	tutorial_details_heading.text = "YOUR CURRENT STEP"
	tutorial_details_heading.add_theme_color_override("font_color", Color("e3b75c"))
	tutorial_details.add_child(tutorial_details_heading)
	for control: Control in [first_session_guide, first_session_boundary, first_session_experiments, first_session_terms]:
		control.reparent(tutorial_details)
	tutorial_extra = VBoxContainer.new()
	tutorial_details_toggle = _button(tutorial_details, "Show experiments and rule terms", func():
		tutorial_extra.visible = not tutorial_extra.visible
		tutorial_details_toggle.text = "Hide experiments and rule terms" if tutorial_extra.visible else "Show experiments and rule terms"
	)
	tutorial_details.add_child(tutorial_extra)
	tutorial_extra.visible = false
	for control: Control in [first_session_boundary, first_session_experiments, first_session_terms]: control.reparent(tutorial_extra)
	# The current instruction leads; reference material never pushes it below the fold.
	first_session_guide.add_theme_font_size_override("font_size", 17)
	first_session_guide.custom_minimum_size.x = 0
	first_session_guide.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	first_session_boundary.visible = true
	# A required choice may be long; phase navigation must not scroll out of reach.
	action_groups.phase.container.reparent(header)
	end_button.custom_minimum_size.y = 44
	end_button.add_theme_color_override("font_color", Color("f2df83"))
	match_tabs.current_tab = 0
	setup.get_parent().visible = true
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
	_build_command_panel(layer)
	var menu_layer := CanvasLayer.new()
	menu_layer.layer = 10
	add_child(menu_layer)
	main_menu = MainMenu.new()
	menu_layer.add_child(main_menu)
	main_menu.start_guided_requested.connect(_menu_start_guided)
	main_menu.training_summary.text = TrainingRoster.Tactical.summary()
	main_menu.training_sides_changed.connect(_set_training_swap)
	main_menu.resume_requested.connect(_menu_resume)
	main_menu.new_match_requested.connect(func(): _dismiss_home(0))
	main_menu.section_requested.connect(_open_menu_section)
	main_menu.settings_requested.connect(_open_settings_screen)
	main_menu.history_requested.connect(_open_history_screen)
	main_menu.save_requested.connect(_save_from_match_menu)
	_build_tactical_overlay()
	main_menu.visible = true
	main_menu.focus_primary_action()
	sidebar_panel.visible = false
	guide_panel.visible = false
	combat_hud.visible = false

func _build_tactical_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	tactical_overlay = Control.new()
	tactical_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tactical_overlay.visible = false
	tactical_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(tactical_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.015, 0.024, 0.032, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	tactical_overlay.add_child(dim)
	var frame := PanelContainer.new()
	frame.name = "TacticalScreen"
	frame.anchor_left = 0.5
	frame.anchor_top = 0.5
	frame.anchor_right = 0.5
	frame.anchor_bottom = 0.5
	frame.grow_horizontal = Control.GROW_DIRECTION_BOTH
	frame.grow_vertical = Control.GROW_DIRECTION_BOTH
	var style := StyleBoxFlat.new()
	style.bg_color = Color("10171d")
	style.border_color = Color("8c713e")
	style.set_border_width_all(1)
	style.border_width_top = 3
	style.set_corner_radius_all(7)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 14
	frame.add_theme_stylebox_override("panel", style)
	tactical_overlay.add_child(frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	frame.add_child(column)
	var heading := HBoxContainer.new()
	column.add_child(heading)
	tactical_overlay_title = Label.new()
	tactical_overlay_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tactical_overlay_title.add_theme_font_size_override("font_size", 22)
	tactical_overlay_title.add_theme_color_override("font_color", Color("f2df83"))
	heading.add_child(tactical_overlay_title)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(86, 34)
	close.pressed.connect(_close_tactical_screen)
	heading.add_child(close)
	var separator := HSeparator.new()
	column.add_child(separator)
	tactical_overlay_body = VBoxContainer.new()
	tactical_overlay_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tactical_overlay_body)
	_build_settings_panel()
	_layout_tactical_overlay()

func _layout_tactical_overlay() -> void:
	if tactical_overlay == null: return
	var size := get_viewport().get_visible_rect().size
	var frame := tactical_overlay.get_node_or_null("TacticalScreen") as PanelContainer
	if frame == null: return
	var width := minf(1160.0, size.x - 48.0)
	var height := minf(720.0, size.y - 40.0)
	frame.offset_left = -width / 2.0
	frame.offset_right = width / 2.0
	frame.offset_top = -height / 2.0
	frame.offset_bottom = height / 2.0

func _build_command_panel(layer: CanvasLayer) -> void:
	layer.add_child(placement_feedback)
	layer.add_child(combat_tray)
	combat_tray.minimum_size_changed.connect(func(): call_deferred("_layout_combat_tray"))
	combat_hud.layout_changed.connect(func(): call_deferred("_layout_ui"))
	combat_tray.speed.item_selected.connect(func(index: int):
		if index == 2:
			_stop_camera_motion()
			attack_feedback.clear()
			_finish_casualty_feedback()
		screen_settings.set_value("presentation", "combat_speed", index)
		var error := screen_settings.save(ui_preferences_path)
		if error != OK: status.text = "Presentation speed applied; local preference could not be saved."
	)
	command_panel = PanelContainer.new()
	command_panel.name = "CommandPanel"
	command_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("10171d", 0.96)
	panel_style.border_color = Color("586b78")
	panel_style.set_border_width_all(1)
	panel_style.border_width_left = 3
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	command_panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(command_panel)
	var shell := VBoxContainer.new()
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_theme_constant_override("separation", 6)
	command_panel.add_child(shell)
	var heading := HBoxContainer.new()
	shell.add_child(heading)
	var title := Label.new()
	title.text = "COMMAND"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("f2df83"))
	heading.add_child(title)
	var divider := HSeparator.new()
	shell.add_child(divider)
	command_panel_body = VBoxContainer.new()
	command_panel_body.custom_minimum_size = Vector2(360, 120)
	command_panel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_panel_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(command_panel_body)
	tactical_opportunity_label = Label.new()
	tactical_opportunity_label.custom_minimum_size.x = 360
	tactical_opportunity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tactical_opportunity_label.add_theme_font_size_override("font_size", 12)
	tactical_opportunity_label.add_theme_color_override("font_color", Color("8ad9a7"))
	tactical_opportunity_label.visible = false
	tactical_opportunity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	command_panel_body.add_child(tactical_opportunity_label)
	placement_reason = Label.new()
	placement_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	placement_reason.add_theme_color_override("font_color", Color("f2b1a0"))
	placement_reason.visible = false
	command_panel_body.add_child(placement_reason)

func _show_tactical_screen(content: Control, title: String) -> void:
	if tactical_overlay_content != null: _close_tactical_screen()
	tactical_overlay_content = content
	tactical_overlay_title.text = title
	if content != settings_panel:
		tactical_overlay_parent = content.get_parent()
		tactical_overlay_index = content.get_index()
	if content.get_parent() == null: tactical_overlay_body.add_child(content)
	else: content.reparent(tactical_overlay_body)
	content.visible = true
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tactical_overlay.visible = true
	_layout_ui()
	_layout_tactical_overlay()
	if content == history_scroll: _history_page(-1)

func _close_tactical_screen() -> void:
	if tactical_overlay_content == null: return
	if tactical_overlay_content != settings_panel and is_instance_valid(tactical_overlay_parent):
		tactical_overlay_content.reparent(tactical_overlay_parent)
		if tactical_overlay_parent == match_tabs and tactical_overlay_index >= 0:
			match_tabs.move_child(tactical_overlay_content, mini(tactical_overlay_index, match_tabs.get_child_count() - 1))
	elif tactical_overlay_content == settings_panel and tactical_overlay_content.get_parent() == tactical_overlay_body:
		# Keep the settings controls owned by the scene. Removing this subtree
		# leaves it detached when the overlay was never opened (or is closed
		# during a headless test), which leaks the entire settings UI at exit.
		settings_panel.visible = false
	tactical_overlay_content = null
	tactical_overlay_parent = null
	tactical_overlay_index = -1
	tactical_overlay.visible = false
	_layout_ui()
	_refresh()

func _open_history_screen() -> void:
	if not combat_enabled or history_scroll == null: return
	_show_tactical_screen(history_scroll, "BATTLE LOG  /  EVENTS + D6")

func _open_help_screen() -> void:
	if help_scroll == null: return
	_show_tactical_screen(help_scroll, "FIELD GUIDE  /  HELP")
	for control: Control in [health_overlay_toggle, board_feedback_toggle, auto_frame_toggle, log_toggle, event_log]:
		control.visible = false

func _open_settings_screen() -> void:
	if not combat_enabled:
		main_menu.show_status("Display and presentation settings are available during a match.")
		return
	_sync_settings_from_applied()
	_show_tactical_screen(settings_panel, "SETTINGS  /  LOCAL DISPLAY + PRESENTATION")

func _save_from_match_menu() -> void:
	_save_match()
	main_menu.show_status(status.text)

func _build_settings_panel() -> void:
	settings_panel = VBoxContainer.new()
	settings_panel.add_theme_constant_override("separation", 10)
	settings_panel.visible = false
	tactical_overlay_body.add_child(settings_panel)
	var intro := Label.new()
	intro.text = "Local preferences. Opening this screen does not pause or change a LAN match."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_panel.add_child(intro)
	var display_heading := Label.new()
	display_heading.text = "DISPLAY"
	display_heading.add_theme_color_override("font_color", Color("e3b75c"))
	settings_panel.add_child(display_heading)
	var display_row := HBoxContainer.new()
	display_row.add_theme_constant_override("separation", 12)
	settings_panel.add_child(display_row)
	display_mode_picker = OptionButton.new()
	display_mode_picker.add_item("Windowed", Window.MODE_WINDOWED)
	display_mode_picker.add_item("Borderless fullscreen", Window.MODE_FULLSCREEN)
	display_mode_picker.add_item("Exclusive fullscreen", Window.MODE_EXCLUSIVE_FULLSCREEN)
	display_mode_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	display_row.add_child(display_mode_picker)
	resolution_picker = OptionButton.new()
	for resolution: Vector2i in [Vector2i(1024, 768), Vector2i(1280, 800), Vector2i(1600, 900), Vector2i(1920, 1080)]:
		resolution_picker.add_item("%d × %d" % [resolution.x, resolution.y], resolution.x)
	resolution_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	display_row.add_child(resolution_picker)
	var options_heading := Label.new()
	options_heading.text = "BOARD + DICE PRESENTATION"
	options_heading.add_theme_color_override("font_color", Color("e3b75c"))
	settings_panel.add_child(options_heading)
	for entry: Dictionary in [
		{"key": "health", "label": "Show Wounds and status above models", "source": "health_overlay_toggle"},
		{"key": "board", "label": "Animate board and camera", "source": "board_feedback_toggle"},
		{"key": "camera", "label": "Auto-frame decisions", "source": "auto_frame_toggle"},
		{"key": "dice", "label": "Animate new dice results", "source": "dice_animation_toggle"},
		{"key": "audio", "label": "Combat sound cues", "source": "combat_audio_toggle"}
	]:
		var toggle := CheckButton.new()
		toggle.text = str(entry.label)
		toggle.button_pressed = _source_presentation_toggle(str(entry.source)).button_pressed
		toggle.set_meta("source_key", str(entry.source))
		settings_panel.add_child(toggle)
		settings_toggles[str(entry.key)] = toggle
	var notice := Label.new()
	notice.text = ""
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("e8bd73"))
	settings_notice = notice
	settings_panel.add_child(notice)
	var actions := HBoxContainer.new()
	settings_panel.add_child(actions)
	var apply := Button.new()
	apply.text = "Apply"
	apply.custom_minimum_size = Vector2(120, 40)
	apply.pressed.connect(_apply_ui_preferences)
	actions.add_child(apply)
	var revert := Button.new()
	revert.text = "Revert"
	revert.custom_minimum_size = Vector2(120, 40)
	revert.pressed.connect(_revert_ui_preferences)
	actions.add_child(revert)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var audio_note := Label.new()
	audio_note.text = "Combat cues are optional; dice and outcomes remain visible when muted."
	audio_note.add_theme_color_override("font_color", Color("9da9b0"))
	settings_panel.add_child(audio_note)
	_capture_applied_display()

func _source_presentation_toggle(source_key: String) -> CheckButton:
	return get(source_key) as CheckButton

func _capture_applied_display() -> void:
	var window := get_window()
	applied_display_settings = {"mode": window.mode, "size": window.size, "presentation": {}}
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		applied_display_settings.presentation[key] = source.button_pressed if source != null else false

func _sync_settings_from_applied() -> void:
	if settings_toggles.is_empty(): return
	display_mode_picker.select(maxi(0, display_mode_picker.get_item_index(int(applied_display_settings.get("mode", Window.MODE_WINDOWED)))))
	var size: Vector2i = applied_display_settings.get("size", Vector2i(1280, 800))
	resolution_picker.select(resolution_picker.get_item_index(size.x))
	for key: String in settings_toggles:
		settings_toggles[key].set_pressed_no_signal(bool(applied_display_settings.get("presentation", {}).get(key, true)))
	settings_notice.text = ""

func _apply_ui_preferences() -> void:
	var selected_mode := display_mode_picker.get_selected_id()
	var resolution_width := resolution_picker.get_selected_id()
	var resolutions := {1024: Vector2i(1024, 768), 1280: Vector2i(1280, 800), 1600: Vector2i(1600, 900), 1920: Vector2i(1920, 1080)}
	var window := get_window()
	window.mode = selected_mode
	if selected_mode == Window.MODE_WINDOWED: window.size = resolutions.get(resolution_width, Vector2i(1280, 800))
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		if source != null: source.button_pressed = toggle.button_pressed
	_capture_applied_display()
	var save_error := _save_ui_preferences()
	settings_notice.text = "Applied and saved on this computer." if save_error == OK else "Applied, but local preferences could not be saved (%s)." % error_string(save_error)
	_layout_ui()
	_layout_tactical_overlay()

func _revert_ui_preferences() -> void:
	if applied_display_settings.is_empty(): return
	var window := get_window()
	window.mode = int(applied_display_settings.mode)
	window.size = applied_display_settings.size
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		var pressed := bool(applied_display_settings.presentation.get(key, true))
		toggle.set_pressed_no_signal(pressed)
		if source != null: source.button_pressed = pressed
	_sync_settings_from_applied()
	settings_notice.text = "Reverted to the last applied preferences."
	_layout_ui()
	_layout_tactical_overlay()

func _save_ui_preferences() -> Error:
	screen_settings.set_value("display", "mode", int(get_window().mode))
	screen_settings.set_value("display", "width", get_window().size.x)
	screen_settings.set_value("display", "height", get_window().size.y)
	var presentation: Dictionary = {}
	for key: String in settings_toggles: presentation[key] = bool(settings_toggles[key].button_pressed)
	screen_settings.set_value("presentation", "options", presentation)
	screen_settings.set_value("presentation", "combat_speed", combat_tray.speed.selected)
	return screen_settings.save(ui_preferences_path)

func _load_ui_preferences() -> void:
	if screen_settings.load(ui_preferences_path) != OK: return
	combat_tray.speed.select(clampi(int(screen_settings.get_value("presentation", "combat_speed", 0)), 0, 2))
	var window := get_window()
	var mode_value := int(screen_settings.get_value("display", "mode", window.mode))
	window.mode = mode_value
	var width := int(screen_settings.get_value("display", "width", window.size.x))
	var height := int(screen_settings.get_value("display", "height", window.size.y))
	if window.mode == Window.MODE_WINDOWED: window.size = Vector2i(width, height)
	var presentation: Dictionary = screen_settings.get_value("presentation", "options", {})
	for key: String in settings_toggles:
		var pressed := bool(presentation.get(key, settings_toggles[key].button_pressed))
		settings_toggles[key].set_pressed_no_signal(pressed)
		var source := _source_presentation_toggle(str(settings_toggles[key].get_meta("source_key")))
		if source != null: source.button_pressed = pressed
	_capture_applied_display()

func _build_action_groups(column: VBoxContainer) -> void:
	unit_decline_button = _button(column, "Continue without this ability · 0 CP", _request_decline_unit_choice)
	unit_decline_button.custom_minimum_size.y = 44
	unit_decline_button.visible = false
	recipient_scroll = ScrollContainer.new()
	recipient_scroll.custom_minimum_size.y = 112
	recipient_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	recipient_scroll.visible = false
	column.add_child(recipient_scroll)
	recipient_cards = VBoxContainer.new()
	recipient_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recipient_scroll.add_child(recipient_cards)
	var definitions := {
		"army_selection": {"title": "Choose your army", "controls": [network_army_status, network_army_picker, network_army_submit]},
		"reanimation": {"title": "Reanimation Protocols", "controls": [reanimation_help, reanimation_squad, reanimation_roll, reanimation_model, reanimation_x, reanimation_z, reanimation_place, reanimation_suggest, reanimation_failure, reanimation_reset, reanimation_confirm]},
		"awakened": {"title": "Awakened Dynasty • Overlord assignment", "controls": [awakened_help, awakened_target, awakened_confirm]},
		"unit": {"title": "Army preparation / unit abilities", "controls": [setup_preparation_status, setup_required_status, setup_feedback_status, setup_finish_button, setup_decisions_heading, setup_equipment_toggle, setup_equipment_list, unit_action_help, unit_decline_button, doctrine_action_panel, unit_action_picker, unit_action_x, unit_action_z, unit_action_button, unit_details_button]},
		"doctrine": {"title": "Combat Doctrines • 11e Gladius", "controls": [doctrine_help, doctrine_choice, doctrine_confirm]},
		"oath": {"title": "Oath of Moment • June 2026", "controls": [oath_help, oath_target, oath_confirm]},
		"reaction": {"title": "Decision window", "controls": [reaction_help, reaction_roll, reaction_use, reaction_sudden, reaction_dice_hint, reaction_dice, reaction_squad]},
		"deployment": {"title": "Deploy", "controls": [deployment_help, deployment_preset_button, deployment_confirm_button]},
		"movement": {"title": "Move", "controls": [movement_choice, sudden_onslaught_choice, movement_choices, begin_move_button, escape_wound_button, finish_move_button, cancel_move_button, abandon_move_button, coherency_button]},
		"contact": {"title": "Charge / fight", "controls": [charge_targets, charge_button, begin_contact_button, consolidation_objective, contact_enemy, confirm_contact_button, cancel_contact_button]},
		"attack": {"title": "Attacks", "controls": [shooting_complete, lethal_choice, plan_begin, plan_steps, plan_assignment_status, plan_hail, indirect_choice, plan_weapon, plan_target, plan_amount, plan_add, plan_clear, plan_summary, plan_confirm, plan_cancel]},
		"defense": {"title": "Allocate", "controls": [defense_steps, defense_picker, recipient_scroll, allocate_button, precision_skip]},
		"objectives": {"title": "Objective", "controls": [action_objective, action_button]},
		"phase": {"title": "Continue", "controls": [end_button]}}
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
		reason.custom_minimum_size.x = 360
		reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(reason)
		for control: Control in definitions[key].controls: control.reparent(group)
		action_groups[key] = {"container": group, "reason": reason, "controls": definitions[key].controls}
	action_groups.phase.container.get_child(0).visible = false
	column.move_child(action_groups.deployment.container, 0)
	column.move_child(action_groups.reaction.container, 0)
	column.move_child(action_groups.oath.container, 0)
	column.move_child(action_groups.reanimation.container, 0)
	column.move_child(action_groups.doctrine.container, 0)
	column.move_child(action_groups.unit.container, 0)
	column.move_child(action_groups.awakened.container, 0)
	column.move_child(action_groups.army_selection.container, 0)

func _refresh_action_groups() -> void:
	var mission_preparation := combat_enabled and Combat.Mission.actor(state) > 0
	var army_preparation := combat_enabled and not mission_preparation and Combat.UnitActions.setup_actor(state) > 0
	var battle_start_setup := combat_enabled and not mission_preparation and Combat.UnitActions.battle_actor(state) > 0
	if not combat_enabled and match_tabs != null and match_tabs.current_tab != 1:
		for group: Dictionary in action_groups.values(): group.container.visible = false
		return
	if army_preparation: action_groups.unit.container.get_child(0).text = "Army preparation"
	elif battle_start_setup: action_groups.unit.container.get_child(0).text = "Start-of-battle choices"
	else: action_groups.unit.container.get_child(0).text = "Mission and unit choices" if combat_enabled and Combat.Mission.enabled(state) else "Current unit abilities"
	if combat_enabled and state.phase == "army_selection":
		for group: Dictionary in action_groups.values(): group.container.visible = false
		action_groups.army_selection.container.visible = saved_army_mode and mode != "local"
		return
	var exclusive := ""
	if combat_enabled:
		if Combat.Mission.actor(state) > 0: exclusive = "unit"
		elif Combat.Awakened.needs_setup(state): exclusive = "awakened"
		elif Combat.Doctrines.needs_choice(state): exclusive = "doctrine"
		elif Combat.UnitActions.actor(state) > 0 and Combat.Reanimation.pending(state).is_empty(): exclusive = "unit"
		elif Combat.Reanimation.pending(state).get("current", {}).get("reroll_pending", false): exclusive = "unit"
		elif state.phase == "deployment":
			var has_vulkan_objective_choice := false
			for ability: Dictionary in Combat.unit_choices(state, _local_player()):
				if ability.action == "seeker-objective": has_vulkan_objective_choice = true
			exclusive = "unit" if has_vulkan_objective_choice else "deployment"
		elif not Combat.Reanimation.pending(state).is_empty(): exclusive = "reanimation"
		elif Combat.Doctrines.needs_choice(state): exclusive = "doctrine"
		elif Combat.OathOfMoment.needs_choice(state): exclusive = "oath"
		elif not Combat.Stratagems.pending(state).is_empty(): exclusive = "reaction"
		elif not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): exclusive = "defense"
		elif not state.pending_move.is_empty() or coherency_button.visible: exclusive = "movement"
		elif not state.pending_contact.is_empty() or not state.pending_charge.is_empty(): exclusive = "contact"
		elif not attack_draft.is_empty(): exclusive = "attack"
	for key: String in action_groups:
		var group: Dictionary = action_groups[key]
		var has_controls := false
		for control: Control in group.controls:
			if control.visible: has_controls = true
		group.container.visible = has_controls and (exclusive.is_empty() or exclusive == key or (key == "unit" and exclusive == "reaction" and not Combat.unit_choices(state, _local_player()).is_empty()))
		group.reason.text = ""
		group.reason.visible = false
		for control: Control in group.controls:
			if control is Label: continue
			control.tooltip_text = ""
	if army_preparation:
		end_button.disabled = true
		end_button.tooltip_text = "Finish army preparations through the validated preparation control."
		action_groups.phase.container.visible = false
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
		var objective_choice_pending := false
		for ability: Dictionary in Combat.unit_choices(state, _local_player()):
			if ability.action == "seeker-objective": objective_choice_pending = true
		_action_reason("unit" if objective_choice_pending else "deployment", Deployment.confirm_error(state))
		return
	if plan_begin.visible and plan_begin.disabled:
		_action_reason("attack", Combat.attack_window_error(state, _local_player(), selected, state.revision, state.phase == "fight"))
	if not attack_draft.is_empty():
		var reason := Combat.attack_plan_error(state, _local_player(), attack_draft.attacker, attack_draft.entries, attack_draft.revision, attack_draft.melee, lethal_choice.button_pressed, attack_draft.get("hail_target", -1), attack_draft.get("indirect_shooting", false))
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
		_action_reason("movement", "Select a model allowed by the Mortal Wounds allocation priority.")
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
			elif not Combat.Doctrines.charge_error(state, state.units[selected].squad).is_empty(): reason = Combat.Doctrines.charge_error(state, state.units[selected].squad)
			elif Combat.Actions.charge_blocked(state, state.units[selected].squad): reason = "This unit started an action that prevents charging."
		_action_reason("contact", reason)
		if state.pending_charge.is_empty(): _action_reason("contact", Combat.charge_declaration_error(state, _local_player(), selected, state.revision))
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
	elif combat_enabled:
		end_button.tooltip_text = KeywordGlossary.describe_phase(str(state.phase), str(state.get("fight_step", "")))
	else:
		end_button.tooltip_text = "End the local movement preview turn. Start a combat exercise to use the supported 11e phase flow."

func _unit_choice_error(model: int) -> String:
	if state.phase == "charge": return Combat.charge_declaration_error(state, _local_player(), model, state.revision)
	if state.phase == "fight":
		if not state.units.has(model): return "Select a living model in your unit."
		if int(state.units[model].squad) not in Combat.FightQueue.choices(state, _local_player()): return "Select a unit in the current fight priority or reaction queue."
		if state.fight_step in ["attacks", "consolidation_reaction"]: return Combat.attack_window_error(state, _local_player(), model, state.revision, true)
		return ""
	if state.phase == "movement":
		var first_error := ""
		for move_type: String in MOVE_TYPES:
			var error := Combat.movement_choice_error(state, _local_player(), model, move_type, state.revision)
			if error.is_empty(): return ""
			if first_error.is_empty(): first_error = error
		return first_error
	return Combat.attack_window_error(state, _local_player(), model, state.revision, false)

func _refresh_unit_choices() -> void:
	action_unit_picker.visible = combat_enabled and ((state.phase == "movement" and begin_move_button.visible and action_groups.movement.container.visible) or (state.phase == "shooting" and (plan_begin.visible or shooting_complete.visible) and action_groups.attack.container.visible) or (state.phase == "charge" and state.pending_charge.is_empty() and action_groups.contact.container.visible) or (state.phase == "fight" and state.pending_contact.is_empty() and attack_draft.is_empty() and (action_groups.contact.container.visible or action_groups.attack.container.visible)))
	if not action_unit_picker.visible: return
	action_unit_picker.clear()
	action_unit_picker.add_item("Choose a unit…", -1)
	var player := _local_player()
	action_unit_picker.disabled = Combat.actor(state) != player or state.test_winner != 0 or (mode == "host" and guest_id == 0)
	var selected_squad: int = state.units[selected].squad if state.units.has(selected) else -1
	var seen: Array[int] = []
	var ready := 0
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner != player or unit.wounds <= 0 or not unit.get("on_battlefield", true) or int(unit.squad) in seen: continue
		seen.append(int(unit.squad))
		var error := _unit_choice_error(model)
		var name: String = "%s · #%d" % [state.squads[unit.squad].name, int(unit.squad)]
		action_unit_picker.add_item(name + (" · unavailable" if not error.is_empty() else ""), model)
		var index := action_unit_picker.item_count - 1
		action_unit_picker.set_item_disabled(index, not error.is_empty())
		action_unit_picker.set_item_tooltip(index, error if not error.is_empty() else "Select this unit. No move or attack is committed.")
		if error.is_empty(): ready += 1
		if int(unit.squad) == selected_squad: action_unit_picker.select(index)
	if action_unit_picker.selected <= 0:
		action_unit_picker.set_item_text(0, "Choose a unit (%d)" % ready)
	action_unit_picker.tooltip_text = "Select a unit here or click a miniature. Unavailable entries explain their validator restriction."
	if action_unit_picker.disabled: action_unit_picker.visible = false

func _choose_action_unit(index: int) -> void:
	if action_unit_picker.disabled or not action_unit_picker.visible or index <= 0: return
	if index >= action_unit_picker.item_count or action_unit_picker.is_item_disabled(index): return
	var model := action_unit_picker.get_item_id(index)
	# Recheck the live window; UI selection never commits a gameplay action.
	if not _unit_choice_error(model).is_empty():
		_refresh()
		return
	selected = model
	_set_command_panel_open(true)
	_refresh()

func _refresh_movement_choices() -> void:
	movement_reference.visible = combat_enabled and state.phase == "movement"
	attack_reference.visible = combat_enabled and state.phase in ["shooting", "fight"]
	if not combat_enabled: return
	var errors: Array[String] = []
	var references: Array[String] = []
	var reference_lines: Array[String] = ["MOVEMENT OPTIONS"]
	# Every movement type shares the same command window, revision and pending
	# decision gate. Evaluate that authoritative gate once, then only perform
	# the move-type-specific checks for each reference row.
	var command_error := Combat.PhaseCloseGate.command_error(state, _local_player(), state.revision)
	if mode == "host" and guest_id == 0: command_error = "Waiting for player 2 to connect."
	for move_type: String in MOVE_TYPES:
		var error := Combat.movement_choice_error_after_command(state, _local_player(), selected, move_type, command_error)
		errors.append(error)
		var reference := KeywordGlossary.describe_move_type(move_type)
		references.append(reference)
		reference_lines.append(reference + ("\nUnavailable now: " + error if not error.is_empty() else "\nAvailable for the selected unit."))
	movement_reference.text = "\n\n".join(reference_lines)
	var choosing: bool = state.pending_move.is_empty()
	var own_model: bool = state.units.has(selected) and state.units[selected].owner == _local_player() and state.units[selected].wounds > 0 and state.units[selected].get("on_battlefield", true)
	var selected_move: String = MOVE_TYPES[movement_choice.selected] if movement_choice.selected >= 0 and movement_choice.selected < MOVE_TYPES.size() else ""
	var sudden_available := false
	if own_model and state.phase == "movement" and choosing and selected_move == "advance":
		sudden_available = Combat.DetachmentStratagems.error(state, _local_player(), state.units[selected].squad, Combat.DetachmentStratagems.SUDDEN_ONSLAUGHT).is_empty()
	sudden_onslaught_choice.visible = sudden_available
	sudden_onslaught_choice.disabled = mode == "host" and guest_id == 0
	if not sudden_available: sudden_onslaught_choice.set_pressed_no_signal(false)
	var stage := 1 if own_model else 0
	var message := "Choose a unit above or click a miniature."
	if state.phase == "movement" and choosing and not state.units.has(selected):
		selection_card.get_parent().visible = false
		begin_move_button.visible = false
		action_groups.movement.reason.visible = false
	if own_model: message = "Choose a move, then Begin move. × = unavailable; reasons in Help."
	if own_model and choosing and not errors.has(""):
		stage = 0
		message = "No move available for this selection. Choose another unit or continue."
		if state.squads[state.units[selected].squad].moved:
			stage = 4
			choosing = false
			message = "Move complete. Choose another unit or continue to Shooting."
			begin_move_button.visible = false
			action_groups.movement.reason.visible = false
	if not state.pending_move.is_empty():
		stage = 2
		message = "Select each model; right-click its destination."
		if not state.pending_move.get("spent", {}).is_empty() and not finish_move_button.disabled:
			stage = 3
			message = "Review the preview. Confirm move, or keep adjusting models."
	if Combat.actor(state) != _local_player():
		message = "Waiting for player %d to resolve movement." % Combat.actor(state)
		movement_choices.visible = false
		begin_move_button.visible = false
		sudden_onslaught_choice.visible = false
		action_groups.phase.reason.visible = false
	movement_choices.configure(movement_choice.selected, errors, references, stage, choosing and own_model, message)

func _request_charge_target(model: int) -> void:
	if not combat_enabled or not charge_targets.is_visible_in_tree(): return
	if mode == "host" and guest_id == 0: return
	if not Combat.charge_target_error(state, _local_player(), model, state.revision).is_empty(): return
	if mode == "client": request_charge.rpc_id(1, model, state.revision)
	else: _apply_charge(_local_player(), model, state.revision)

func _refresh_contact_flow() -> void:
	contact_reference.visible = combat_enabled and state.phase in ["charge", "fight"]
	contact_flow.visible = contact_reference.visible and (action_groups.contact.container.visible or action_groups.attack.container.visible or action_groups.phase.container.visible)
	if not contact_reference.visible: return
	var pending: bool = not state.pending_contact.is_empty()
	var steps: Array[String] = ["Unit", "Roll", "Targets", "Place", "Confirm"]
	var stage := 0
	var message := "Choose a unit, then Roll charge."
	if state.phase == "charge":
		action_groups.contact.container.get_child(0).text = "Charge"
		contact_reference.text = KeywordGlossary.describe_charge_roll() + "\n\n" + KeywordGlossary.describe_contact_action("charge")
		if state.units.has(selected) and Combat.charge_declaration_error(state, _local_player(), selected, state.revision).is_empty(): stage = 1
		if not state.pending_charge.is_empty():
			stage = 2
			message = "%d\" rolled · mark targets, then Begin placement." % int(state.pending_charge.maximum)
			if not state.pending_charge.targets.is_empty(): stage = 3
			var seen: Array[int] = []
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if unit.owner == Combat.actor(state) or unit.wounds <= 0 or not unit.get("on_battlefield", true) or int(unit.squad) in seen: continue
				var squad := int(unit.squad)
				seen.append(squad)
				if not charge_target_buttons.has(squad):
					var button := CheckButton.new()
					button.clip_text = true
					button.custom_minimum_size.y = 36
					charge_targets.add_child(button)
					button.toggled.connect(func(_checked: bool): _request_charge_target(int(button.get_meta("model"))))
					charge_target_buttons[squad] = button
				var button: CheckButton = charge_target_buttons[squad]
				button.set_meta("model", model)
				button.visible = true
				var error := Combat.charge_target_error(state, _local_player(), model, state.revision)
				button.disabled = not error.is_empty() or (mode == "host" and guest_id == 0)
				button.text = "%s · #%d" % [state.squads[squad].name, squad]
				button.set_pressed_no_signal(squad in state.pending_charge.targets)
				button.tooltip_text = button.text + "\n" + (error if not error.is_empty() else "Toggle this charge target. Final placement still requires validation.")
				contact_reference.text += "\n\n%s: %s" % [button.text, error if not error.is_empty() else ("Selected" if button.button_pressed else "Available to select")]
			for squad: int in charge_target_buttons:
				if squad not in seen: charge_target_buttons[squad].visible = false
	else:
		steps = ["Unit", "Pile-in", "Attacks", "Consolidate"]
		var titles := {"pile_in": "Pile-in", "attacks": "Melee attacks", "consolidation_reaction": "Reaction attacks", "consolidate": "Consolidation", "complete": "Fight complete"}
		var title: String = titles.get(str(state.fight_step), "Fight")
		action_groups.contact.container.get_child(0).text = title
		stage = {"pile_in": 1, "attacks": 2, "consolidation_reaction": 2, "consolidate": 3, "complete": 4}.get(str(state.fight_step), 0)
		if state.fight_step != "complete" and not pending and attack_draft.is_empty() and not _unit_choice_error(selected).is_empty(): stage = 0
		message = title + ": choose a unit in the current priority queue."
		if state.fight_step in ["pile_in", "consolidate"]: message = "Choose a unit and begin placement, or decline this optional step."
		elif state.fight_step in ["attacks", "consolidation_reaction"]: message = "Choose a unit, then Plan attacks."
		elif state.fight_step == "complete": message = "Fight complete. Continue to the next step."
		if state.fight_step in ["attacks", "consolidation_reaction"] and end_button.disabled and action_groups.attack.container.visible:
			action_groups.phase.container.visible = false
		contact_reference.text = KeywordGlossary.describe_phase("fight", str(state.fight_step)) + "\n\n" + KeywordGlossary.describe_contact_action("fight", str(state.fight_step))
	if pending:
		if state.phase == "charge": stage = 3
		message = "Select each model; right-click its destination, then Confirm."
		var error := Combat.ContactActions.final_error(state)
		confirm_contact_button.disabled = confirm_contact_button.disabled or not error.is_empty()
		if not error.is_empty():
			_action_reason("contact", error)
			contact_reference.text += "\n\nPlacement blocked: " + error
		else:
			if state.phase == "charge": stage = 4
			message = "Preview valid. Confirm placement, or keep adjusting models."
		charge_button.visible = false
	if mode != "local" and Combat.actor(state) != _local_player():
		message = "Waiting for player %d to resolve this step." % Combat.actor(state)
		charge_targets.visible = false
	contact_flow.configure(steps, stage, message)

func _action_reason(key: String, text: String) -> void:
	if text.is_empty(): return
	var group: Dictionary = action_groups[key]
	group.reason.text = text
	group.reason.visible = true
	var rule_reference := KeywordGlossary.describe_action_group_reference(key, str(state.get("phase", "")))
	for control: Control in group.controls:
		if control is BaseButton and control.disabled:
			control.tooltip_text = text if rule_reference.is_empty() else text + "\n\n" + rule_reference

func _open_blockers_help() -> void:
	_open_help_screen()
	var scroll := blockers_reference.get_parent().get_parent() as ScrollContainer
	if scroll != null: scroll.set_deferred("scroll_vertical", 0)

func _refresh_blockers_help() -> void:
	var sections: Array[String] = []
	var references: Array[String] = []
	for key: String in action_groups:
		var group: Dictionary = action_groups[key]
		if not group.container.visible or group.reason.text.is_empty(): continue
		var blocked := false
		for control: Control in group.controls:
			if control is BaseButton and control.visible and control.disabled: blocked = true
		if not blocked: continue
		var heading: String = group.container.get_child(0).text
		var entry := heading + "\n" + str(group.reason.text)
		var rule := KeywordGlossary.describe_action_group_reference(key, str(state.get("phase", "")))
		if not rule.is_empty() and rule not in references: references.append(rule)
		sections.append(entry)
	blockers_button.visible = combat_enabled and not sections.is_empty() and int(state.get("test_winner", 0)) == 0
	blockers_reference.visible = combat_enabled and not sections.is_empty()
	blockers_rules_toggle.visible = combat_enabled and not references.is_empty()
	blockers_rules.visible = blockers_rules_toggle.visible and blockers_rules_toggle.button_pressed
	blockers_rules.text = "\n\n".join(references)
	blockers_reference.text = "CURRENT UNAVAILABLE ACTIONS\n\n" + "\n\n".join(sections) if not sections.is_empty() else "No current action blockers to explain. Select an action in the Command panel to inspect its available choices."

func _layout_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if match_tabs != null:
		match_tabs.tabs_visible = not combat_enabled
		for tab_index: int in range(match_tabs.get_tab_count()):
			match_tabs.set_tab_hidden(tab_index, tab_index not in [0, 1] or (combat_enabled and tab_index == 0))
	var workspace_tab := match_tabs != null and match_tabs.current_tab in [2, 3]
	var sidebar_width := clampf(viewport_size.x * (0.43 if workspace_tab else 0.22), 350.0 if not workspace_tab else 520.0, 420.0 if not workspace_tab else 860.0)
	if workspace_tab: sidebar_width = minf(1160, viewport_size.x - 64)
	sidebar_panel.position = Vector2(16, 118)
	if workspace_tab: sidebar_panel.position.x = (viewport_size.x - sidebar_width) / 2
	sidebar_panel.size = Vector2(sidebar_width, maxf(300, viewport_size.y - 134))
	if home_nav_button != null: home_nav_button.visible = not combat_enabled and not workspace_tab
	if sidebar_title != null: sidebar_title.visible = not combat_enabled and not workspace_tab
	if workspace_tab and action_groups.has("phase"): action_groups.phase.container.visible = false
	if gameplay_scroll != null and command_panel_body != null and match_tabs != null:
		if combat_enabled:
			var panel_width := minf(420.0, maxf(330.0, viewport_size.x * 0.40))
			command_panel.position = Vector2(viewport_size.x - panel_width - 16.0, _board_top())
			command_panel.size = Vector2(panel_width, maxf(300.0, viewport_size.y - _board_top() - 16.0))
			command_panel.visible = command_panel_open and (main_menu == null or not main_menu.visible) and tactical_overlay_content == null
		else:
			command_panel.visible = false
		if command_panel != null and combat_hud != null: combat_hud.set_command_panel_open(command_panel_open)
		call_deferred("_sync_gameplay_workspace")
	sidebar_panel.visible = not combat_enabled and main_menu != null and not main_menu.visible
	if combat_hud != null: combat_hud.visible = combat_enabled and (main_menu == null or not main_menu.visible)
	if guide_panel != null:
		guide_panel.visible = combat_enabled and not workspace_tab and (main_menu == null or not main_menu.visible) and viewport_size.x >= 1600.0 and not command_panel_open
		guide_panel.position = Vector2(16, 118)
	if main_menu != null:
		main_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		main_menu.set_in_match_mode(combat_enabled)
	if tactical_overlay != null:
		tactical_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tactical_overlay.visible = tactical_overlay_content != null
		_layout_tactical_overlay()
		if tactical_overlay_content == history_scroll and history_panel != null: history_panel.visible = true
	if auto_frame_toggle != null: call_deferred("_refresh_decision_camera")
	_layout_combat_tray()

func _layout_combat_tray() -> void:
	if combat_tray == null or not combat_tray.is_inside_tree(): return
	var viewport_size := get_viewport().get_visible_rect().size
	var right := command_panel.position.x - 16.0 if command_panel != null and command_panel.visible else viewport_size.x - 16.0
	combat_tray.size = Vector2(minf(640.0, maxf(280.0, right - 16.0)), 0)
	combat_tray.position = Vector2(16, maxf(_board_top(), viewport_size.y - combat_tray.size.y - 16))

func _board_top() -> float:
	if combat_hud != null and combat_hud.header_panel != null:
		return maxf(112, combat_hud.header_panel.get_global_rect().end.y + 16)
	return 112

func _sync_gameplay_workspace() -> void:
	if gameplay_scroll == null or command_panel_body == null or match_tabs == null: return
	if combat_enabled:
		if gameplay_scroll.get_parent() != command_panel_body: gameplay_scroll.reparent(command_panel_body, false)
		if tactical_opportunity_label != null and tactical_opportunity_label.get_parent() == command_panel_body:
			command_panel_body.move_child(tactical_opportunity_label, 0)
		gameplay_scroll.visible = true
		if action_groups.has("phase") and action_groups.phase.container.get_parent() != command_panel_body:
			action_groups.phase.container.reparent(command_panel_body, false)
	else:
		if gameplay_scroll.get_parent() != match_tabs:
			gameplay_scroll.reparent(match_tabs, false)
			match_tabs.move_child(gameplay_scroll, mini(1, match_tabs.get_child_count() - 1))
		var header := sidebar_panel.get_child(0).get_child(0)
		if action_groups.has("phase") and action_groups.phase.container.get_parent() != header:
			action_groups.phase.container.reparent(header, false)
	for index: int in range(match_tabs.get_tab_count()):
		match_tabs.set_tab_hidden(index, index not in [0, 1] or (combat_enabled and index == 0))

func _toggle_command_panel() -> void:
	_set_command_panel_open(not command_panel_open)

func _set_command_panel_open(open: bool) -> void:
	command_panel_open = open
	if command_panel != null: command_panel.visible = combat_enabled and command_panel_open and (main_menu == null or not main_menu.visible) and tactical_overlay_content == null
	if combat_hud != null: combat_hud.set_command_panel_open(command_panel_open)
	_layout_ui()

func _has_pending_command() -> bool:
	if not PendingDecisions.current(state, ["awakened-attachment", "mission-preparation", "unit-actions", "combat-doctrines", "reanimation", "stratagems", "damage-allocation"]).is_empty(): return true
	for key: String in ["pending_charge", "pending_contact", "pending_hazard", "pending_attack"]:
		if not state.get(key, {}).is_empty(): return true
	return false

func _open_home() -> void:
	if main_menu == null: return
	attack_feedback.clear()
	_stop_camera_motion()
	menu_return_tab = match_tabs.current_tab if match_tabs != null else 1
	if combat_enabled:
		main_menu.set_resume_state(true, "Return to the current match.", true)
	else:
		_update_main_menu_resume_state()
	main_menu.set_in_match_mode(combat_enabled)
	main_menu.show_status("")
	main_menu.visible = true
	main_menu.focus_primary_action()
	sidebar_panel.visible = false
	guide_panel.visible = false
	combat_hud.visible = false
	_layout_ui()

func _dismiss_home(tab_index: int = 1) -> void:
	if main_menu != null: main_menu.visible = false
	if tactical_overlay_content != null: _close_tactical_screen()
	sidebar_panel.visible = true
	match_tabs.current_tab = clampi(tab_index, 0, match_tabs.get_tab_count() - 1)
	menu_return_tab = match_tabs.current_tab
	_layout_ui()
	_refresh()

func _open_menu_section(tab_index: int) -> void:
	if combat_enabled: return
	if tab_index == 2 or tab_index == 3:
		workshop_tabs.current_tab = 1 if tab_index == 2 else 0
		_show_tactical_screen(workshop_scroll, "MODEL IMPORT" if tab_index == 2 else "ARMY WORKSHOP")
		return
	if tab_index == 5:
		_show_tactical_screen(tools_scroll, "TRAINING TOOLS")
		return
	_dismiss_home(tab_index)

func _menu_start_guided() -> void:
	main_menu.show_status("")
	_start_guided_first_session()
	if combat_enabled and saved_army_mode and guided_first_session:
		_dismiss_home(1)
	else:
		main_menu.show_status(status.text)

func _menu_resume() -> void:
	if combat_enabled:
		_dismiss_home(menu_return_tab if menu_return_tab > 0 else 1)
		return
	_load_match()
	if resume_succeeded:
		_dismiss_home(1)
	else:
		main_menu.show_status(status.text)
		_update_main_menu_resume_state()

func _update_main_menu_resume_state() -> void:
	if main_menu == null or combat_enabled: return
	var previous_status := status.text if status != null else ""
	_load_match(false, true)
	var issue := status.text
	if status != null: status.text = previous_status
	main_menu.set_resume_state(resume_compatible, issue if not resume_compatible else "")

func _update_guides() -> void:
	if guides == null or guide_label == null: return
	if not guides.visible:
		guide_label.text = "Range guides hidden."
		return
	guides.rebuild(state, selected, combat_enabled, _local_player())
	_update_hover_guides()

func _update_hover_guides() -> void:
	if guides == null or guide_label == null: return
	var hit: Variant = null
	if get_viewport().gui_get_hovered_control() == null:
		var mouse := get_viewport().get_mouse_position()
		var world: Variant = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
		if world != null: hit = Vector2(world.x, world.z)
	var preview_destination: Variant = placement_feedback.destination if hit == null and placement_feedback.pinned else hit
	guides.preview(state, selected, combat_enabled, _local_player(), preview_destination)
	guide_label.text = guides.caption + ("\n" + guides.hover_caption if not guides.hover_caption.is_empty() else "")
	if hit != null and state.units.has(selected):
		if not guides.hover_error.is_empty():
			if not placement_feedback.pinned: placement_feedback.show_reason(selected, hit, guides.hover_error)
		elif guides.hover_valid or not placement_feedback.pinned:
			_clear_placement_feedback()
	elif not placement_feedback.pinned:
		_clear_placement_feedback()

func _selected_marine_detachment() -> String:
	return _selected_marine_detachment_for(marine_detachment_choice)

func _selected_marine_detachment_for(picker: OptionButton) -> String:
	if picker == null or picker.selected < 0: return "gladius"
	var value: Variant = picker.get_item_metadata(picker.selected)
	return str(value) if value is String else "gladius"

func _selected_marine_detachments() -> Dictionary:
	return {1: _selected_marine_detachment(), 2: _selected_marine_detachment_for(marine_detachment_choice_p2)}

func _marine_detachment_assignments_equal(left: Dictionary, right: Dictionary) -> bool:
	for owner in [1, 2]:
		var left_value := str(left.get(owner, left.get(str(owner), "none")))
		var right_value := str(right.get(owner, right.get(str(owner), "none")))
		if left_value != right_value: return false
	return true

func _select_marine_detachment(picker: OptionButton, detachment: String) -> void:
	if picker == null: return
	for index in picker.item_count:
		if str(picker.get_item_metadata(index)) == detachment:
			picker.select(index)
			return

func _selected_official_terrain_layout() -> String:
	if official_layout_choice == null or official_layout_choice.selected < 0: return Combat.Mission.DEFAULT_TERRAIN_LAYOUT
	return str(official_layout_choice.get_item_metadata(official_layout_choice.selected))

func _selected_official_primary_mission() -> String:
	if official_primary_choice == null or official_primary_choice.selected < 0: return "battlefield-dominance"
	return str(official_primary_choice.get_item_metadata(official_primary_choice.selected))

func _refresh_primary_mission_help() -> void:
	if official_primary_help == null: return
	match _selected_official_primary_mission():
		"battlefield-dominance": official_primary_help.text = "Score from controlling objectives; the selected 11e Event Companion layout and fixed secondaries remain in use."
		"meatgrinder": official_primary_help.text = "Reward enemy unit destruction, objective control and taking the opponent’s home objective."
		"reconnaissance-sweep": official_primary_help.text = "Score for spreading units across table quarters, destroying enemy units and controlling objectives."
		"secure-asset": official_primary_help.text = "Start Secure Asset in the Shooting phase at a controlled non-home objective; hold it through end of turn."

func _select_official_primary_mission(primary_id: String) -> void:
	if official_primary_choice == null: return
	var selected_index := 0
	for index in official_primary_choice.item_count:
		if str(official_primary_choice.get_item_metadata(index)) == primary_id:
			selected_index = index
			break
	official_primary_choice.select(selected_index)
	_refresh_primary_mission_help()

func _select_official_terrain_layout(layout_id: String) -> void:
	official_terrain_layout = layout_id if Combat.Terrain.is_event_layout(layout_id) else Combat.Mission.DEFAULT_TERRAIN_LAYOUT
	if official_layout_choice == null: return
	var selected_index := 0
	for index in official_layout_choice.item_count:
		if str(official_layout_choice.get_item_metadata(index)) == layout_id:
			selected_index = index
			break
	official_layout_choice.select(selected_index)
	_refresh_official_layout_preview()

func _refresh_official_layout_controls() -> void:
	if official_layout_heading == null: return
	var active := official_mission_choice.button_pressed
	official_primary_heading.visible = active
	official_primary_choice.visible = active
	official_primary_help.visible = active
	official_layout_heading.text = "11e Event Companion terrain · Take and Hold mirror" if _selected_official_primary_mission() == "battlefield-dominance" else "11e Event Companion terrain · Take and Hold mirror proxy"
	official_layout_heading.tooltip_text = "Terrain-only presets A/B/C. For this selected primary, the existing Take and Hold mirror proxies are reused; terrain does not change mission rules. Exact recommended layouts for every primary-mission pairing are not implemented."
	official_layout_heading.visible = active
	official_layout_choice.visible = active
	official_layout_preview.visible = active
	official_layout_preview_status.visible = active
	if active: _refresh_official_layout_preview()

func _refresh_official_layout_preview() -> void:
	if official_layout_choice == null or official_layout_preview == null or official_layout_preview_status == null: return
	var cache_path := ProjectSettings.globalize_path("res://" + Combat.Terrain.event_layout_image_path(_selected_official_terrain_layout()))
	official_layout_preview.texture = null
	if FileAccess.file_exists(cache_path):
		var image := Image.new()
		if image.load(cache_path) == OK:
			official_layout_preview.texture = ImageTexture.create_from_image(image)
			official_layout_preview_status.text = "Terrain preview only. Mission, objectives, deployment and scoring stay unchanged. Runtime terrain uses ground-level proxy geometry."
			return
	official_layout_preview_status.text = "The 11th-edition source diagram is not cached on this computer. The terrain preset remains playable with ground-level proxies."

func _initial_state() -> Dictionary:
	if combat_enabled and saved_army_mode: return PreparedTraining.waiting({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "terrain_layout": _selected_official_terrain_layout(), "checked_rosters": checked_rosters})
	if combat_enabled and prepared_match: return PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "terrain_layout": _selected_official_terrain_layout(), "checked_rosters": checked_rosters})
	if combat_enabled and allocation_practice: return TestBattlefield.apply(AllocationPractice.initial_state(damage_rerolls, count_rerolls))
	return TestBattlefield.apply(Combat.initial_state(terrain_layout, mission_id, squads_per_side, manual_allocation, varied_equipment)) if combat_enabled else Rules.initial_state()

func _refresh_army_choices() -> void:
	if saved_army_pickers.is_empty(): return
	var presets := TrainingRoster.presets(checked_rosters_choice.button_pressed)
	for owner: int in saved_army_pickers:
		var picker: OptionButton = saved_army_pickers[owner]
		var previous := ""
		if picker.item_count > 0 and picker.get_selected_metadata() is Dictionary: previous = str(picker.get_selected_metadata().get("id", ""))
		picker.clear()
		picker.add_item("Player %d: choose a saved list" % owner)
		picker.set_item_metadata(0, {})
		for list: Dictionary in presets:
			var report := Combat.RosterValidation.inspect(list) if str(list.get("id", "")).begins_with("preset:checked-mfm16") else TrainingRoster.inspect(list)
			picker.add_item("P%d • %s • %d/%d pts" % [owner, list.name, report.total, list.points_limit])
			picker.set_item_metadata(picker.item_count - 1, list.duplicate(true))
			if list.id == previous or (previous.is_empty() and str(list.id) == "reference:core-v2:Space Marines"): picker.select(picker.item_count - 1)
		for profile: Dictionary in army_builder.store.data.profiles:
			for list: Dictionary in profile.lists:
				picker.add_item("%s / %s" % [profile.name, list.name])
				picker.set_item_metadata(picker.item_count - 1, list.duplicate(true))
				if list.id == previous: picker.select(picker.item_count - 1)
		if checked_rosters_choice.button_pressed and (previous.is_empty() or previous.begins_with("preset:") or previous.begins_with("reference:")):
			for index in range(picker.item_count):
				var candidate: Variant = picker.get_item_metadata(index)
				if candidate is Dictionary and candidate.get("id", "") == "preset:checked-mfm16:" + ("Space Marines" if owner == 1 else "Necrons"): picker.select(index)
	_review_saved_armies()

func _set_training_swap(swapped: bool) -> void:
	training_swap_sides = swapped
	if training_swap_choice != null: training_swap_choice.set_pressed_no_signal(swapped)
	if main_menu != null: main_menu.training_swap_choice.set_pressed_no_signal(swapped)

func _start_guided_first_session() -> void:
	if mode != "local":
		status.text = "Start the guided sample locally before connecting to a LAN match."
		return
	guided_first_session = false
	checked_rosters_choice.set_pressed_no_signal(false)
	official_mission_choice.set_pressed_no_signal(false)
	_refresh_official_layout_controls()
	unit_abilities_choice.set_pressed_no_signal(true)
	combat_doctrines_choice.set_pressed_no_signal(true)
	awakened_dynasty_choice.set_pressed_no_signal(false)
	reanimation_protocols_choice.set_pressed_no_signal(false)
	marine_detachment_choice.select(0)
	marine_detachment_choice_p2.select(0)
	stratagem_choice.set_pressed_no_signal(true)
	reroll_choice.set_pressed_no_signal(true)
	attack_reroll_choice.set_pressed_no_signal(true)
	save_reroll_choice.set_pressed_no_signal(true)
	damage_reroll_choice.set_pressed_no_signal(true)
	hazard_reroll_choice.set_pressed_no_signal(true)
	count_reroll_choice.set_pressed_no_signal(true)
	escape_reroll_choice.set_pressed_no_signal(true)
	equipment_choice.set_pressed_no_signal(false)
	hail_of_bolts_choice.set_pressed_no_signal(false)
	oath_of_moment_choice.set_pressed_no_signal(false)
	objective_secured_choice.set_pressed_no_signal(false)
	implacable_eradication_choice.set_pressed_no_signal(false)
	defender_choice.set_pressed_no_signal(true)
	auto_models.button_pressed = false
	_refresh_army_choices()
	for owner: int in [1, 2]:
		var assault := (owner == 2) != training_swap_sides
		var wanted: String = TrainingRoster.Tactical.ASSAULT_ID if assault else TrainingRoster.Tactical.FIRE_ID
		var picker: OptionButton = saved_army_pickers[owner]
		var found := false
		for index in range(picker.item_count):
			var list: Variant = picker.get_item_metadata(index)
			if list is Dictionary and str(list.get("id", "")) == wanted:
				picker.select(index)
				found = true
				break
		if not found:
			status.text = "The tactical training list is unavailable for Player %d. Prepare the current local catalog and try again; no historical data will be substituted." % owner
			return
	_start_saved_match(true, true)
	if not saved_army_mode or not state.has("saved_army_setup") or state.saved_army_setup.get("armies", {}).size() != 2: return
	guided_first_session = true
	match_tabs.current_tab = 1
	_refresh()
	status.text = "Tactical training ready: Fire and Manoeuvre vs Close Assault. Declare the Captain and Chaplain as Warlords and attach each to its Intercessor unit. You control both sides; abilities and stratagems are optional."

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
	if list.is_empty(): return {"error": "Choose a list for player %d." % owner}
	if checked_rosters_choice.button_pressed:
		return {"error": "The saved MFM 1.6 roster check is historical and cannot create a new current-catalog match."}
	return TrainingRoster.admit_current_catalog(list)

func _review_saved_armies() -> void:
	if saved_army_review == null: return
	var lines: Array[String] = ["Quick local match • custom training • fixed loadouts • partial rules support"]
	var details: Array[String] = ["Core-profile training admits up to six units per player. Only explicitly enabled effects run. Full army legality is not certified."]
	if checked_rosters_choice.button_pressed:
		lines[0] = "Historical saved-roster exercise • not available for new current-catalog matches"
		details[0] = "Saved Incursion rosters retain MFM 1.6 prices from 17 October, up to twelve fixed-profile units, Gladius/Awakened only, and no enhancements. This historical check cannot create a new current-catalog match."
	if official_mission_choice.button_pressed:
		lines[0] = "CA 2026-27 %s • Hammer and Anvil • 44 × 60 inches • partial rules support" % str(Combat.Mission.PRIMARY_MISSIONS[_selected_official_primary_mission()].name)
	for owner in [1, 2]:
		var report := _saved_army_report(owner)
		lines.append("P%d: %s" % [owner, report.error if not report.error.is_empty() else ("%s • %d units • %d/%d points") % [report.selection.faction, report.get("unit_count", report.selection.get("copies", 0)), report.total, report.selection.points_limit]])
	for owner in [1, 2]:
		var report := _saved_army_report(owner)
		if report.error.is_empty():
			for warning: String in report.get("warnings", []):
				if unit_abilities_choice.button_pressed: continue
				if objective_secured_choice.button_pressed:
					warning = warning.replace("objective-secured, ", "").replace(", objective-secured", "")
				if implacable_eradication_choice.button_pressed:
					warning = warning.replace("implacable-eradication, ", "").replace(", implacable-eradication", "")
					if warning.ends_with(": implacable-eradication") or warning == "implacable-eradication": continue
				if hail_of_bolts_choice.button_pressed:
					warning = warning.replace("target-elimination, ", "").replace(", target-elimination", "")
					if warning.ends_with(": target-elimination") or warning == "target-elimination": continue
				details.append("P%d • unavailable abilities: %s" % [owner, warning])
	var active_options: Array[String] = []
	for item in [[unit_abilities_choice, "Current unit abilities"], [combat_doctrines_choice, "Combat Doctrines"], [awakened_dynasty_choice, "Awakened Dynasty"], [reanimation_protocols_choice, "Reanimation Protocols"], [stratagem_choice, "Stratagem decisions"], [official_mission_choice, "CA mission"]]:
		if item[0].button_pressed: active_options.append(item[1])
	lines.append("Options: " + (", ".join(active_options) if not active_options.is_empty() else "standard training rules"))
	details.append("Only the local owner chooses their own list in LAN. Both computers must use the same match options.")
	saved_army_review.text = "\n".join(lines)
	saved_army_review.tooltip_text = "\n".join(details)
	var invalid := false
	for owner in [1, 2]:
		if not _saved_army_report(owner).error.is_empty(): invalid = true
	if saved_army_start_button != null: saved_army_start_button.disabled = invalid or mode != "local"
	if local_match_status != null:
		local_match_status.text = "Ready to start with the selected lists." if not invalid else "Choose two current-catalog lists to enable Start local match."

func _start_saved_match(local_match: bool = true, tactical_training: bool = false) -> void:
	if mode != "local": return
	guided_first_session = false
	if checked_rosters_choice.button_pressed:
		status.text = "The saved MFM 1.6 roster check is historical; use the current local catalog to create a new match."
		return
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
	local_visual_armies = {}
	for owner: int in selections:
		local_visual_armies[owner] = _picked_army(owner)
	if selections.is_empty():
		status.text = "Select at least your saved list before enabling LAN."
		return
	var options := {"manual_allocation": defender_choice.button_pressed, "varied_equipment": false, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed, "oath_of_moment": oath_of_moment_choice.button_pressed, "reanimation_protocols": reanimation_protocols_choice.button_pressed, "combat_doctrines": combat_doctrines_choice.button_pressed, "marine_detachment": _selected_marine_detachment() if combat_doctrines_choice.button_pressed else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines_choice.button_pressed else {1: "none", 2: "none"}, "awakened_dynasty": awakened_dynasty_choice.button_pressed, "unit_abilities": unit_abilities_choice.button_pressed, "official_mission": official_mission_choice.button_pressed, "primary_mission": _selected_official_primary_mission(), "terrain_layout": _selected_official_terrain_layout(), "checked_rosters": checked_rosters_choice.button_pressed}
	if tactical_training: options.training_scenario_id = TrainingRoster.Tactical.ID
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
	oath_of_moment = oath_of_moment_choice.button_pressed
	reanimation_protocols = reanimation_protocols_choice.button_pressed
	combat_doctrines = combat_doctrines_choice.button_pressed
	marine_detachment = _selected_marine_detachment() if combat_doctrines else "none"
	marine_detachment_p2 = _selected_marine_detachment_for(marine_detachment_choice_p2) if combat_doctrines else "none"
	marine_detachments = _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}
	checked_rosters = checked_rosters_choice.button_pressed
	official_mission = official_mission_choice.button_pressed
	unit_abilities = unit_abilities_choice.button_pressed
	awakened_dynasty = awakened_dynasty_choice.button_pressed
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
	_layout_ui()
	_sync_gameplay_workspace()
	if local_match: _prepare_local_models()
	status.text = ("Selected CA mission ready. Resolve mission preparation, then formations and deployment." if official_mission else "Saved lists accepted for partial training. Confirm each unit's deployment.") if local_match else "Saved-list LAN mode is active. Player 1: Host; player 2: Join. Each player must select their own list."
	_refresh()

func _connected_to_server() -> void:
	status.text = "Connected. Verifying session seat…"

func _submit_saved_army() -> void:
	if not saved_army_mode or state.get("phase", "") != "army_selection": return
	var owner := 2 if mode == "client" else 1
	if network_army_picker != null and network_army_picker.selected >= 0 and network_army_picker.selected < saved_army_pickers[owner].item_count:
		saved_army_pickers[owner].select(network_army_picker.selected)
	var report := _saved_army_report(owner)
	if not report.error.is_empty():
		network_army_status.text = report.error
		status.text = report.error
		return
	if mode == "client":
		local_visual_armies[owner] = _picked_army(owner)
		submitted_army = report.selection
		request_saved_army.rpc_id(1, submitted_army)
		network_army_status.text = "Your list was sent to the host. Waiting for both lists to pass validation."
	elif mode == "host":
		local_visual_armies[owner] = _picked_army(owner)
		pending_armies[1] = report.selection
		_try_saved_armies()
		if state.phase == "army_selection": network_army_status.text = "Player 1 list submitted. Waiting for Player 2."
	_refresh_network_army_selection()

func _network_army_selected(index: int) -> void:
	var owner := _local_player()
	if not saved_army_pickers.has(owner): return
	var source: OptionButton = saved_army_pickers[owner]
	if index >= 0 and index < source.item_count: source.select(index)
	_refresh_network_army_selection()

func _refresh_network_army_selection() -> void:
	if network_army_picker == null: return
	var selecting: bool = combat_enabled and saved_army_mode and state.get("phase", "") == "army_selection" and mode != "local"
	network_army_status.visible = selecting
	network_army_picker.visible = selecting
	network_army_submit.visible = selecting
	if not selecting: return
	var owner := _local_player()
	var source: OptionButton = saved_army_pickers.get(owner)
	if source == null:
		network_army_status.text = "This connection has no army-selection seat."
		network_army_picker.disabled = true
		network_army_submit.disabled = true
		return
	var selected_id := ""
	if source.selected >= 0 and source.get_selected_metadata() is Dictionary: selected_id = str(source.get_selected_metadata().get("id", ""))
	network_army_picker.clear()
	var selected_index := -1
	for index in range(source.item_count):
		network_army_picker.add_item(source.get_item_text(index))
		var item: Variant = source.get_item_metadata(index)
		network_army_picker.set_item_metadata(index, item)
		if item is Dictionary and not selected_id.is_empty() and str(item.get("id", "")) == selected_id: selected_index = index
	if selected_index >= 0: network_army_picker.select(selected_index)
	var ready: Array = state.get("ready_armies", [])
	var ready_labels: Array[String] = []
	for player in [1, 2]: ready_labels.append("P%d %s" % [player, "submitted" if player in ready else "waiting"])
	network_army_status.text = "Player %d: choose your list and submit.\n%s" % [owner, " • ".join(ready_labels)]
	if mode == "client" and not submitted_army.is_empty():
		network_army_status.text = "Your list was sent to the host. Waiting for both lists to pass validation.\n%s" % " • ".join(ready_labels)
	elif mode == "host" and 1 in ready and 2 not in ready:
		network_army_status.text = "Player 1 list submitted. Waiting for Player 2.\n%s" % " • ".join(ready_labels)
	network_army_picker.disabled = false
	network_army_submit.disabled = false

@rpc("any_peer", "call_remote", "reliable")
func request_saved_army(selection: Dictionary) -> void:
	if mode != "host" or not saved_army_mode or not match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): return
	var report := TrainingRoster.admit_current_catalog(selection)
	if not report.error.is_empty():
		_feedback(2, report.error)
		return
	if state.phase != "army_selection":
		if state.has("saved_army_setup") and _selection_digest(report.selection) == _selection_digest(state.saved_army_setup.armies[2]): _broadcast()
		else: _feedback(2, "The list does not match this match's locked selection.")
		return
	pending_armies[2] = report.selection
	_try_saved_armies()

func _selection_digest(selection: Dictionary) -> String:
	return Combat.RosterValidation.selection_digest(selection) if checked_rosters else TrainingRoster.digest(selection)

func _try_saved_armies() -> void:
	state.ready_armies = pending_armies.keys()
	if pending_armies.size() != 2:
		_broadcast()
		return
	var candidate := PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "terrain_layout": _selected_official_terrain_layout(), "checked_rosters": checked_rosters}, pending_armies)
	if candidate.has("error"):
		_broadcast()
		status.text = candidate.error
		_feedback(2, candidate.error)
		return
	# Newly agreed tactical formations use their own identity. Old saves still
	# reconstruct from their original setup without implicit scenario migration.
	if TrainingRoster.Tactical.matches(candidate) and unit_abilities and combat_doctrines and core_stratagems and _selected_marine_detachments() == {1: "gladius", 2: "gladius"}:
		var tactical_setup: Dictionary = candidate.saved_army_setup.duplicate(true)
		tactical_setup.options.training_scenario_id = TrainingRoster.Tactical.ID
		candidate = PreparedTraining.from_setup(tactical_setup)
		if candidate.has("error"):
			_feedback(2, candidate.error)
			status.text = candidate.error
			return
	state = candidate
	_reset_history()
	selected = -1
	_spawn_pieces()
	_broadcast()
	status.text = "Both lists passed partial training validation. Deployment started."

func _start_prepared_match() -> void:
	if mode != "local": return
	local_visual_armies.clear()
	var candidate := PreparedTraining.initial_state({"manual_allocation": defender_choice.button_pressed, "varied_equipment": equipment_choice.button_pressed, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed, "oath_of_moment": oath_of_moment_choice.button_pressed, "reanimation_protocols": reanimation_protocols_choice.button_pressed, "combat_doctrines": combat_doctrines_choice.button_pressed, "marine_detachment": _selected_marine_detachment() if combat_doctrines_choice.button_pressed else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines_choice.button_pressed else {1: "none", 2: "none"}, "awakened_dynasty": awakened_dynasty_choice.button_pressed, "unit_abilities": unit_abilities_choice.button_pressed, "official_mission": official_mission_choice.button_pressed, "primary_mission": _selected_official_primary_mission(), "terrain_layout": _selected_official_terrain_layout(), "checked_rosters": checked_rosters_choice.button_pressed})
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
	oath_of_moment = oath_of_moment_choice.button_pressed
	reanimation_protocols = reanimation_protocols_choice.button_pressed
	combat_doctrines = combat_doctrines_choice.button_pressed
	marine_detachment = _selected_marine_detachment() if combat_doctrines else "none"
	checked_rosters = checked_rosters_choice.button_pressed
	official_mission = official_mission_choice.button_pressed
	unit_abilities = unit_abilities_choice.button_pressed
	awakened_dynasty = awakened_dynasty_choice.button_pressed
	manual_allocation = defender_choice.button_pressed
	varied_equipment = equipment_choice.button_pressed
	state = candidate
	_reset_history()
	attack_draft = {}
	selected = Combat.living(state, Deployment.current(state))[0]
	_spawn_pieces()
	status.text = "Selected CA mission ready. Resolve mission preparation before deployment; complete army legality remains unverified." if official_mission else "Custom prepared match. Deploy each unit, then play the five-round training mission. Complete army legality is not validated."
	_refresh()

func _request_deployment_preset() -> void:
	if mode == "client": request_deployment_preset.rpc_id(1, state.revision)
	else: _apply_deployment(_local_player(), state.revision, false)

@rpc("any_peer", "call_remote", "reliable")
func request_deployment_preset(revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_deployment(2, revision, false)

func _apply_deployment(player: int, revision: int, confirm: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var kind := MatchCommandService.DEPLOYMENT_CONFIRM if confirm else MatchCommandService.DEPLOYMENT_PRESET
	var result := MatchCommandService.execute(state, player, {"kind": kind, "revision": revision})
	if not str(result.get("error", "")).is_empty(): _feedback(player, result.error); return
	if state.phase == "deployment": selected = Combat.living(state, Deployment.current(state))[0]
	_broadcast()
	_feedback(player, result.message)

func _start_allocation_practice() -> void:
	local_visual_armies.clear()
	objective_secured = false
	implacable_eradication = false
	hail_of_bolts = false
	oath_of_moment = false
	reanimation_protocols = false
	combat_doctrines = false
	checked_rosters = false
	official_mission = false
	unit_abilities = false
	awakened_dynasty = false
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
	_dismiss_home(1)

func _start_objectives(unit_count: int = 1) -> void:
	if mode != "local": return
	local_visual_armies.clear()
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
	oath_of_moment = false
	reanimation_protocols = false
	combat_doctrines = false
	checked_rosters = false
	official_mission = false
	unit_abilities = false
	awakened_dynasty = false
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
	status.text = "Training · 1 VP per objective · 5 rounds."
	_refresh()

func _toggle_combat(layout: String = Combat.Terrain.DEFAULT_LAYOUT) -> void:
	if mode != "local": return
	if not saved_army_mode: local_visual_armies.clear()
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
	oath_of_moment = false
	reanimation_protocols = false
	combat_doctrines = false
	checked_rosters = false
	official_mission = false
	unit_abilities = false
	awakened_dynasty = false
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
	button.custom_minimum_size.y = 32
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _update_camera() -> void:
	camera.position = Vector3(sin(angle) * zoom, zoom * 0.85, cos(angle) * zoom)
	camera.look_at(pivot.position, Vector3.UP)

func _focus_selected_unit() -> void:
	if not state.units.has(selected): return
	_manual_camera_control()
	var ids := DecisionCamera.models(state, [state.units[selected].squad])
	_apply_camera_plan(DecisionCamera.plan(camera, pivot, state, ids, _camera_board_area(), angle))

func _camera_board_area() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	var left := 16.0
	var right := viewport_size.x - 16.0
	if sidebar_panel.is_visible_in_tree(): left = sidebar_panel.get_global_rect().end.x + 16.0
	if command_panel != null and command_panel.is_visible_in_tree(): right = command_panel.get_global_rect().position.x - 16.0
	if guide_panel.is_visible_in_tree(): left = maxf(left, guide_panel.get_global_rect().end.x + 16.0)
	var bottom := viewport_size.y - 16
	if combat_tray != null and combat_tray.is_visible_in_tree(): bottom = minf(bottom, combat_tray.position.y - 16)
	return Rect2(Vector2(left, _board_top()), Vector2(maxf(0, right - left), maxf(0, bottom - _board_top())))

func _decision_camera_subject() -> Dictionary:
	if not combat_enabled or action_groups.is_empty() or int(state.get("test_winner", 0)) != 0: return {}
	var context := {
		"defense": action_groups.defense.container.visible,
		"reaction": action_groups.reaction.container.visible,
		"reaction_squad": reaction_squad.get_selected_id(),
		"contact": action_groups.contact.container.visible,
		"movement": action_groups.movement.container.visible,
		"attack": action_groups.attack.container.visible,
		"attack_target": plan_target.get_selected_id(),
		"deployment": action_groups.deployment.container.visible,
		"ordinary": action_groups.movement.container.visible or action_groups.attack.container.visible or action_groups.contact.container.visible}
	return DecisionCamera.subject(state, selected, attack_draft, context)

func _stop_camera_motion() -> void:
	if focus_tween != null and focus_tween.is_running(): focus_tween.kill()

func _manual_camera_control() -> void:
	_stop_camera_motion()
	camera_manual_override = true
	last_camera_key = str(_decision_camera_subject().get("key", ""))

func _set_focus_zoom(value: float) -> void:
	zoom = value
	_update_camera()

func _apply_camera_plan(plan: Dictionary) -> void:
	if plan.is_empty(): return
	_stop_camera_motion()
	if pivot.position.is_equal_approx(plan.position) and is_equal_approx(zoom, plan.zoom): return
	if not _board_motion_enabled():
		pivot.position = plan.position
		_set_focus_zoom(plan.zoom)
		return
	focus_tween = create_tween().set_parallel(true)
	focus_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	focus_tween.tween_property(pivot, "position", plan.position, 0.28)
	focus_tween.tween_method(_set_focus_zoom, zoom, float(plan.zoom), 0.28)

func _refresh_decision_camera() -> void:
	if auto_frame_toggle == null or not auto_frame_toggle.button_pressed: return
	# Gameplay is reparented out of the workshop tabs during a match.
	if not combat_enabled or main_menu == null or main_menu.visible or tactical_overlay_content != null: return
	var subject := _decision_camera_subject()
	var key := str(subject.get("key", ""))
	var board_area := _camera_board_area()
	if key.is_empty(): return
	if key == last_camera_key and (camera_manual_override or last_camera_area.is_equal_approx(board_area)): return
	var plan := DecisionCamera.plan(camera, pivot, state, subject.models, board_area, angle)
	if plan.is_empty(): return
	if key != last_camera_key: camera_manual_override = false
	last_camera_key = key
	last_camera_area = board_area
	_apply_camera_plan(plan)

func _process(delta: float) -> void:
	if not placement_feedback.message.is_empty() and state.units.has(placement_feedback.model):
		placement_feedback.visible = main_menu != null and not main_menu.visible and tactical_overlay_content == null
		var location: Vector2 = state.units[placement_feedback.model].position
		placement_feedback.place(camera, Vector3(location.x, 1.7, location.y), _camera_board_area())
	if setup_notice != null and status != null:
		var notice := status.text
		if not autosave_error.is_empty() and state.get("phase") != "army_selection": notice += "\nAutosave failed: " + autosave_error
		if setup_notice.text != notice: setup_notice.text = notice
	if main_menu != null and main_menu.visible: return
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
	if direction != Vector3.ZERO:
		_manual_camera_control()
		pivot.position += direction.rotated(Vector3.UP, angle) * delta * 12
		var limit: Vector2 = Rules.half_board(state) + Vector2(12, 12)
		pivot.position.x = clampf(pivot.position.x, -limit.x, limit.x)
		pivot.position.z = clampf(pivot.position.z, -limit.y, limit.y)

func _unhandled_input(event: InputEvent) -> void:
	if main_menu != null and main_menu.visible: return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F:
		var focused_control := get_viewport().gui_get_focus_owner()
		if not focused_control is LineEdit and not focused_control is TextEdit:
			_focus_selected_unit()
		return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		_manual_camera_control()
		angle -= event.relative.x * 0.006
		_update_camera()
	if not event is InputEventMouseButton or not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_manual_camera_control()
		zoom = clampf(zoom + (-2 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 2), 10, DecisionCamera.max_zoom(state))
		_update_camera()
		return
	var hit: Variant = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
	if hit == null:
		return
	var target := Vector2(hit.x, hit.z)
	if event.button_index == MOUSE_BUTTON_LEFT:
		_clear_placement_feedback()
		selected = _pick_model(target)
		if selected >= 0: _set_command_panel_open(true)
		_refresh()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if combat_enabled and Combat.UnitAbilities.enabled(state) and (unit_action_picker.is_visible_in_tree() or doctrine_action_panel.is_visible_in_tree()) and unit_action_picker.selected >= 0:
			var ability: Dictionary = unit_action_picker.get_selected_metadata()
			if Combat.UnitActions.pending(state).get("kind", "") == "ingress":
				for choice: Dictionary in Combat.unit_choices(state, _local_player()):
					if choice.action == "ingress-place" and choice.model == selected: ability = choice
			if ability.action in ["ingress-place", "scout-place", "homer", "heal-revive", "heal-place", "purgation-place", "transport-disembark-place"]:
				unit_action_x.value = target.x
				unit_action_z.value = target.y
				if mode == "client": request_unit_action.rpc_id(1, ability, target, state.revision)
				else: _apply_unit_action(_local_player(), ability, target, state.revision)
				return
		if combat_enabled and not Combat.Reanimation.pending(state).is_empty():
			reanimation_x.value = target.x
			reanimation_z.value = target.y
			_request_reanimation("place")
			return
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
		var preview: Dictionary = Combat.UnitActions.pending(state).get("positions", {}) if combat_enabled else {}
		if combat_enabled and Combat.UnitActions.pending(state).get("kind", "") == "healing": preview = Combat.UnitActions.pending(state).placements
		if (state.units[id].get("wounds", 1) <= 0 or not state.units[id].get("on_battlefield", true)) and not preview.has(id): continue
		var distance: float = point.distance_to(preview.get(id, state.units[id].position))
		if distance < closest:
			closest = distance
			nearest = id
	return nearest

func _local_player() -> int:
	return (Combat.actor(state) if combat_enabled else int(state.active)) if mode == "local" else (1 if mode == "host" else 2)

func _refresh_tactical_opportunity_cue() -> void:
	if tactical_opportunity_label == null: return
	var cue := ""
	if combat_enabled and guided_first_session and saved_army_mode and int(state.get("test_winner", 0)) == 0 and TrainingRoster.Tactical.matches(state):
		var actor := Combat.actor(state)
		if actor > 0:
			cue = TrainingRoster.Tactical.opportunity_status(Combat.unit_choices(state, actor))
			if not cue.is_empty() and mode != "local" and actor != _local_player():
				cue = "WAITING — Player %d: %s" % [actor, cue]
		if not state.get("manual_allocation", false):
			cue = "Automatic allocation assist is active. Start new tactical training for defender choices." + ("\n" + cue if not cue.is_empty() else "")
	tactical_opportunity_label.add_theme_color_override("font_color", Color("e8bd73") if combat_enabled and not state.get("manual_allocation", false) else Color("8ad9a7"))
	tactical_opportunity_label.text = cue
	tactical_opportunity_label.tooltip_text = cue
	tactical_opportunity_label.visible = not cue.is_empty()

func _refresh_decision() -> void:
	_refresh_tactical_opportunity_cue()
	decision_label.tooltip_text = KeywordGlossary.describe_phase(str(state.get("phase", "")), str(state.get("fight_step", ""))) if combat_enabled else "Local movement preview. Choose a combat exercise to see the supported 11e phase flow."
	if combat_enabled:
		var pending_state_error := Combat.MatchActor.pending_state_error(state)
		if not pending_state_error.is_empty():
			objective_summary.visible = false
			decision_label.text = "MATCH STATE INVALID • resume a valid save or start a new match."
			decision_label.tooltip_text = pending_state_error
			combat_hud.set_steps(str(state.get("phase", "")), int(state.get("round", 0)), int(state.get("active", 1)), -1)
			return
	if combat_enabled != ui_combat_enabled:
		match_tabs.current_tab = 1 if combat_enabled else 0
		ui_combat_enabled = combat_enabled
		if combat_enabled: command_panel_open = true
	objective_summary.visible = combat_enabled and (Combat.Objectives.training(state) or Combat.Mission.enabled(state)) and state.phase != "army_selection"
	if objective_summary.visible:
		objective_summary.text = "CUSTOM TRAINING • VP %d / %d" % [state.mission.scores[1], state.mission.scores[2]]
		var objectives: Array[String] = []
		for objective: Dictionary in state.mission.get("objectives", []):
			objectives.append("%s: %s%s" % [objective.name, "neutral" if objective.controller == 0 else "P%d" % objective.controller, " (secured)" if objective.secured != 0 else ""])
		objective_summary.text += "\n" + " • ".join(objectives)
		if Combat.Mission.enabled(state): objective_summary.text = Combat.Mission.summary(state)
		objective_summary.tooltip_text = objective_summary.text
		objective_summary.text = "P1 %d VP · %d CP   P2 %d VP · %d CP" % [state.mission.scores[1], int(state.get("cp", {}).get(1, 0)), state.mission.scores[2], int(state.get("cp", {}).get(2, 0))]
	if not combat_enabled:
		combat_hud.set_round("Preview")
		combat_hud.set_steps("", 0, 0)
		decision_label.text = "Choose a mode from the title screen to begin."
		return
	combat_hud.set_steps(str(state.phase), int(state.round), int(state.get("active", 1)), Combat.actor(state))
	if state.phase == "army_selection":
		match_tabs.current_tab = 0
		decision_label.text = "ARMY SELECTION • choose and submit your list."
		decision_label.tooltip_text = "Choose and submit your own list in the command panel. The readiness line shows which player is waiting; an admission error explains any rejected selection."
		return
	if state.test_winner != 0:
		decision_label.text = "EXERCISE COMPLETE • " + ("Draw" if state.test_winner == -1 else "Player %d wins" % state.test_winner)
		return
	if mode == "host" and guest_id == 0:
		decision_label.text = "WAITING FOR PLAYER 2"
		decision_label.tooltip_text = "Both players must select the same exercise."
		return
	var actor := Combat.actor(state)
	var instruction := "Select a model to see its available actions below."
	if Combat.Mission.actor(state) > 0:
		instruction = "Mission preparation: use the choice below."
	elif Combat.Awakened.needs_setup(state):
		instruction = "Required: declare each Overlord standalone or leading a unit before deployment."
	elif Combat.Doctrines.needs_choice(state):
		instruction = "Required: choose an available Combat Doctrine or no doctrine before continuing Command."
	elif Combat.UnitActions.actor(state) > 0 and Combat.Reanimation.pending(state).is_empty():
		if Combat.UnitActions.setup_actor(state) > 0: instruction = "Choose Warlord/Support and finish army preparations."
		elif Combat.UnitActions.battle_actor(state) > 0: instruction = "Optional: place or skip Terminator Homers, then finish setup."
		elif Combat.UnitActions.pending(state).get("kind", "") in ["healing", "healing-order"]: instruction = "Unit healing: resolve wounds and confirm returned-model previews."
		elif Combat.UnitActions.pending(state).get("kind", "") == "ingress": instruction = "Required: preview every arriving model, then confirm the coherent unit or cancel ingress."
		elif Combat.UnitActions.pending(state).get("kind", "") == "bladeguard": instruction = "Bladeguard: choose a stance or decline. Attack dice wait."
		elif Combat.UnitActions.pending(state).get("kind", "") == "wound": instruction = "Implacable Eradication: choose free wound rerolls, then keep the remaining dice to continue to saves."
		else: instruction = "Required: resolve or decline the current unit ability window."
	elif state.phase == "deployment":
		var needs_seeker_choice := false
		for ability: Dictionary in Combat.unit_choices(state, _local_player()):
			if ability.action == "seeker-objective": needs_seeker_choice = true
		instruction = "Vulkan He’stan: Seeker of the Unfound — choose one objective before confirming deployment." if needs_seeker_choice else "Deploy %s: place models in the zone or use the preview, then Confirm deployment." % state.squads[Deployment.current(state)].name
	elif not Combat.Reanimation.pending(state).is_empty():
		instruction = "Required: resolve Reanimation for each unit before leaving Command. Positions are previews until confirmed."
	elif Combat.Doctrines.needs_choice(state):
		instruction = "Required: choose an available Combat Doctrine or no doctrine before continuing Command."
	elif Combat.OathOfMoment.needs_choice(state):
		instruction = "Required: choose one enemy as your Oath of Moment target before continuing Command."
	elif not Combat.Stratagems.pending(state).is_empty():
		var roll_window: Dictionary = Combat.Stratagems.pending(state)
		if roll_window.kind == "before_battle_shock": instruction = "Battle-shock pending: choose a unit and roll, or use Insane Bravery (1 CP)."
		elif roll_window.get("honour_vigilance", false): instruction = "Advance pending: accept the roll or use Honour of Vigilance to re-roll it for 0 CP."
		elif roll_window.get("valour", false): instruction = "Charge: accept or use Unstoppable Valour to re-roll both dice for 0 CP."
		else: instruction = "Decision pending: accept the roll or use Command Re-roll (1 CP) to continue."
	elif not state.get("pending_hazard", {}).is_empty():
		instruction = "Required: select an eligible model, then allocate Hazardous wounds."
	elif not state.get("pending_attack", {}).is_empty():
		match str(state.pending_attack.current.phase):
			"precision": instruction = "Choose a visible character for Precision, or choose Do not use Precision."
			"order": instruction = "Required: select a model from the next defense group, then confirm its allocation group."
			_: instruction = "Required: select an eligible model, then allocate the attack's damage."
	elif not state.get("pending_contact", {}).is_empty():
		instruction = "Place the unit's models, then confirm or cancel contact placement."
	elif not Combat.UnitAbilities.Detection.selection(state).is_empty():
		instruction = "Shoot with the selected Eliminators, or cancel in Unit abilities."
	elif state.phase == "end_turn" and Combat.incoherent_squad(state) != -1:
		instruction = "Required: remove models to restore unit coherency before ending the turn."
	elif state.phase == "movement" and state.pending_move.is_empty():
		instruction = "Choose a move, then Begin move." if state.units.has(selected) and state.units[selected].owner == actor else "Choose a unit above or click a miniature."
		if state.units.has(selected) and state.squads[state.units[selected].squad].moved:
			instruction = "Move complete. Choose another unit or continue to Shooting."
	elif state.phase == "movement":
		instruction = "Place the unit, then Confirm move."
	elif state.phase == "shooting" and attack_draft.is_empty():
		instruction = "Shooting complete for this unit. Choose another unit or continue to Charge." if _selected_shooting_complete() else "Select your unit, then Plan attacks."
	elif state.phase == "shooting":
		instruction = "Assign each attack, then Confirm attacks."
	elif state.phase == "charge" and state.pending_charge.is_empty():
		instruction = "Select your unit, then Roll charge — or Continue."
	elif state.phase == "charge":
		instruction = "Choose charge targets, then Begin placement."
	elif state.phase == "fight":
		instruction = {"pile_in": "Choose a unit for pile-in, or decline.", "attacks": "Choose a unit, then Plan attacks.", "consolidation_reaction": "Choose a unit for the reaction attacks.", "consolidate": "Choose a unit to consolidate, or decline.", "complete": "Fight complete. Continue to the next step."}.get(str(state.fight_step), "Follow the current Fight options.")
	elif state.phase in ["start_turn", "command"]:
		instruction = "Advance the phase."
	else:
		instruction = "Use the options below."
	var owner_text := "Player %d to act" % actor if actor == int(state.get("active", actor)) else "Player %d's turn · Player %d decides" % [int(state.get("active", actor)), actor]
	if mode != "local" and actor != _local_player():
		owner_text = "Waiting · " + owner_text
		var subject := str(state.phase).replace("_", " ")
		if Combat.Mission.actor(state) > 0: subject = "mission setup"
		elif Combat.UnitActions.actor(state) > 0: subject = "a unit ability"
		elif not Combat.Reanimation.pending(state).is_empty(): subject = "Reanimation"
		elif not Combat.Stratagems.pending(state).is_empty(): subject = "a dice decision"
		elif not state.get("pending_hazard", {}).is_empty(): subject = "Hazardous allocation"
		elif not state.get("pending_attack", {}).is_empty(): subject = "damage allocation"
		elif not state.get("pending_contact", {}).is_empty(): subject = "contact placement"
		elif not state.pending_charge.is_empty(): subject = "charge targets"
		elif not state.pending_move.is_empty(): subject = "movement placement"
		instruction = "Resolving %s." % subject
	decision_label.text = "%s · %s" % [owner_text, instruction]
	decision_label.tooltip_text = "%s\n%s" % [KeywordGlossary.describe_phase(str(state.phase), str(state.get("fight_step", ""))), instruction]

func _refresh_first_session_guide() -> void:
	if first_session_panel == null: return
	first_session_panel.visible = false
	if not (guided_first_session and combat_enabled and saved_army_mode):
		first_session_guide.visible = false
		first_session_boundary.visible = false
		first_session_experiments.visible = false
		first_session_terms.visible = false
		if combat_hud != null: combat_hud.set_guide_progress(false)
		return
	first_session_guide.visible = true
	first_session_boundary.visible = true
	first_session_experiments.visible = false
	first_session_terms.visible = true
	var heading := "FOLLOW THE STEPS"
	var instruction := "Resolve the highlighted choice in the Command panel. The decision banner shows whose turn it is and what is required."
	var boundary := "CAN DO: follow the highlighted controls.  •  WAIT: phase progression stays unavailable while a required choice is open."
	var step_number := 1
	var terms: Array[Dictionary] = []
	if state.test_winner != 0:
		var phase_steps := {"deployment": 3, "start_turn": 4, "command": 5, "movement": 6, "shooting": 7, "charge": 8, "fight": 9, "end_turn": 10}
		step_number = 10 if int(state.get("turn", 1)) > 1 else int(phase_steps.get(str(state.phase), 1))
		heading = "MATCH ENDED"
		instruction = "The recorded match has ended. Review the result and history, or start another exercise in Match setup."
		boundary = "This sample uses bounded local training lists. It does not certify full army legality or every game rule."
		terms = [{"name": "Result", "help": "The current sample has reached its end condition. You can keep exploring the board or start a different exercise."}]
	elif int(state.get("turn", 1)) > 1:
		step_number = 10
		heading = "FIRST TURN COMPLETE • 10 OF 10"
		instruction = "The first player's turn is complete. Continue following the phase rail through the local sample."
		boundary = "CAN DO: continue the match or review recorded actions and dice."
		terms = [{"name": "Turn", "help": "A player's turn proceeds through Command, Movement, Shooting, Charge and Fight."}, {"name": "Phase rail", "help": "The rail marks the current phase and the player's next step."}]
	elif Combat.Mission.actor(state) > 0:
		step_number = 1
		heading = "STEP 1 OF 10 • MISSION SETUP"
		instruction = "In the Command panel, resolve the highlighted mission roll-off or declaration. Repeat tied roll-offs, then continue to army choices."
		boundary = "CAN DO: use the highlighted mission control.  •  WAIT: deployment and turn actions are not available until preparation is complete."
		terms = [{"name": "Roll-off", "help": "Both players roll as directed by the selected mission. A tie asks for another roll."}, {"name": "Attacker / Defender", "help": "Mission roles determine setup responsibilities and are recorded before deployment."}]
	elif Combat.Awakened.needs_setup(state) or Combat.UnitActions.setup_actor(state) > 0:
		step_number = 2
		heading = "STEP 2 OF 10 • ARMY PREPARATION"
		instruction = "Declare each army's Warlord and Leader attachment in the Command panel. In tactical training, attach the Captain to Intercessors and the Chaplain to Assault Intercessors, then finish preparation. Keep default equipment."
		boundary = "CAN DO: make each listed declaration and review its highlighted control.  •  WAIT: deployment begins after required army choices are confirmed."
		terms = [{"name": "Leader", "help": "A Character attachment must be declared with its bodyguard unit during army setup."}, {"name": "Warlord", "help": "Declare the required Warlord before deployment."}, {"name": "Reserve", "help": "Declare the supported unit's reserve choice when the army preparation step requests it."}]
	elif state.phase == "deployment":
		step_number = 3
		heading = "STEP 3 OF 10 • DEPLOYMENT"
		instruction = "Place the current unit's models inside its marked zone, or accept the suggested preview positions, then confirm the unit. Repeat for each unit."
		boundary = "CAN DO: place models in the marked zone or accept the preview.  •  CANNOT: confirm a unit while its deployment is incomplete or invalid."
		terms = [{"name": "Deployment zone", "help": "The shaded area on your side of the battlefield where your models must be placed during setup."}, {"name": "Preview", "help": "Suggested positions are not final until you accept and confirm the unit's deployment."}]
	elif Combat.UnitActions.battle_actor(state) > 0:
		step_number = 4
		heading = "STEP 4 OF 10 • OPTIONAL BATTLE-START SETUP"
		instruction = "Select a Terminator unit's optional Teleport Homer, set its X/Z position and confirm, or skip it. Then choose Finish start-of-battle declarations to continue."
		boundary = "OPTIONAL: place markers for later Teleport Homer ingress.  •  REQUIRED: finish start-of-battle choices before continuing to Command."
		terms = [{"name": "Teleport Homer", "help": "An optional marker for a Terminator unit. Its supported Teleport Homer ingress choice can later use this location."}, {"name": "X/Z", "help": "Set the marker's battlefield position. Confirm the selected choice to place it."}]
	elif state.phase in ["start_turn", "command"]:
		step_number = 5
		heading = "STEP 5 OF 10 • COMMAND"
		instruction = "Resolve the highlighted Command choices. When ready, use Phase progression to enter Movement."
		boundary = "CAN DO: make available Command choices.  •  WAIT: do not skip an open required decision."
		terms = [{"name": "Command", "help": "The first phase of a turn. It can include mission and unit ability decisions."}, {"name": "Phase progression", "help": "The next-step control is enabled when the current phase has no unresolved required decision."}]
	elif state.phase == "movement":
		step_number = 6
		var acting_player := int(state.active)
		var moved := false
		for squad: Dictionary in state.squads.values():
			if squad.owner == acting_player and squad.moved: moved = true
		heading = "STEP 6 OF 10 • MOVEMENT"
		instruction = ("Select a Player %d model, choose Normal move, begin, right-click its new position and confirm the squad." % acting_player) if not moved else "Your movement is confirmed. Use Phase progression when ready to enter Shooting."
		boundary = "CAN DO: move an eligible friendly unit and confirm its new positions.  •  CANNOT: place models beyond the move allowed by the selected action."
		terms = [{"name": "Normal move", "help": "A standard move action. The interface previews legal movement distance and checks placement before confirmation."}, {"name": "Confirm squad", "help": "Records the planned positions for the unit. Review them before confirming."}]
	elif state.phase == "shooting" and not state.has("last_attack"):
		step_number = 7
		heading = "STEP 7 OF 10 • SHOOTING"
		instruction = "Select an eligible friendly unit, plan attacks against an eligible enemy, review the assignments and confirm the plan."
		boundary = "CAN DO: assign attacks the interface marks eligible, then review and confirm.  •  CANNOT: submit an incomplete attack plan."
		terms = [{"name": "Eligible target", "help": "A target the selected unit can attack under the current visibility and range checks."}, {"name": "Attack plan", "help": "A draft of weapon, target and model assignments. It resolves only after you review and confirm it."}]
	elif state.phase == "shooting" and state.has("last_attack"):
		step_number = 7
		heading = "STEP 7 OF 10 • REVIEW SHOOTING"
		instruction = "Your attack result is recorded. Choose another eligible unit or continue to Charge when ready."
		boundary = "CAN DO: review the result, inspect the board or continue when eligible units have finished shooting."
		terms = [{"name": "Combat history", "help": "Expand the history panel to review recorded actions and dice."}, {"name": "Phase progression", "help": "Continue when the shooting phase has no unresolved required choice."}]
	elif state.phase == "charge":
		step_number = 8
		heading = "STEP 8 OF 10 • CHARGE"
		instruction = "Choose an eligible unit, select its charge targets, roll 2D6 and resolve any placement step."
		boundary = "CAN DO: declare an available charge or continue when ready.  •  WAIT: required target and placement choices must be resolved first."
		terms = [{"name": "Charge targets", "help": "Select the eligible enemy units this charge will attempt to reach."}, {"name": "Charge roll", "help": "The 2D6 result is checked against the selected targets before placement."}]
	elif state.phase == "fight":
		step_number = 9
		var fight_step := str(state.get("fight_step", ""))
		var fight_label: String = {"pile_in": "PILE-IN", "attacks": "FIGHT", "consolidation_reaction": "REACTION", "consolidate": "CONSOLIDATE", "complete": "COMPLETE"}.get(fight_step, "FIGHT")
		heading = "STEP 9 OF 10 • %s" % fight_label
		instruction = {"pile_in": "Choose an eligible unit for pile-in, or continue if the optional step can be skipped.", "attacks": "Choose a unit in the fight order and plan its melee attacks.", "consolidation_reaction": "Resolve the available reaction attacks, then follow the fight order.", "consolidate": "Choose an eligible unit for consolidation, or continue if the optional step can be skipped.", "complete": "Fight actions are resolved. Use Phase progression to reach the end of the turn."}.get(fight_step, "Follow the highlighted Fight choice, then continue through the fight order.")
		boundary = "CAN DO: follow the current Fight step.  •  WAIT: resolve required attacks and placement before continuing."
		terms = [{"name": "Pile-in", "help": "An eligible unit can make its supported pile-in move before its melee attacks."}, {"name": "Consolidation", "help": "After fighting, an eligible unit can make its supported consolidation move."}]
	elif state.phase == "end_turn":
		step_number = 10
		heading = "STEP 10 OF 10 • END TURN"
		var incoherent_squad := Combat.incoherent_squad(state)
		if incoherent_squad != -1:
			var incoherent_name := str(state.squads.get(incoherent_squad, {}).get("name", "the incoherent unit"))
			instruction = "Select a living model from %s and use Remove selected model for coherency. The choice is required before the turn can close." % incoherent_name
			boundary = "CAN DO: choose one eligible model from the highlighted unit.  •  WAIT: Phase progression remains locked until coherency is restored."
			terms = [{"name": "Coherency", "help": "Models in a unit must remain within the supported distance of another model in that unit. At End of Turn, the owning player removes a living model when the unit is incoherent."}, {"name": "Casualty choice", "help": "The current decision lists the legal living models. Removing one is recorded and can pass the pending close to the other player."}]
		else:
			instruction = "Your phases are resolved. Use Phase progression to start the other player's turn."
			boundary = "CAN DO: inspect the board and history before continuing."
			terms = [{"name": "End turn", "help": "The turn advances to the other player after required effects and choices are resolved."}, {"name": "Phase progression", "help": "The next-step control applies the existing phase-close checks."}]
	first_session_heading.text = heading
	first_session_progress.value = step_number
	var tactical_lists := TrainingRoster.Tactical.matches(state)
	if tactical_lists and state.test_winner == 0:
		instruction += "\n\nTACTICAL TIP: " + TrainingRoster.Tactical.tip(str(state.phase))
		first_session_experiments.visible = true
		var current_window := TrainingRoster.Tactical.experiment_window(state)
		var opportunity_status := ""
		var opportunity_actor := Combat.actor(state)
		if opportunity_actor > 0:
			opportunity_status = TrainingRoster.Tactical.opportunity_status(Combat.unit_choices(state, opportunity_actor))
		var opportunity_line := ("\n" + opportunity_status) if not opportunity_status.is_empty() else ""
		var experiment_count := TrainingRoster.Tactical.experiment_count(state)
		first_session_experiments.text = "OPTIONAL EXPERIMENTS\nPROGRESS: %d / 4 observed\nDONE = observed • OPEN = available\nCURRENT WINDOW: " % experiment_count + current_window + opportunity_line + "\n" + "\n".join(TrainingRoster.Tactical.experiment_lines(state).map(func(item: String): return "• " + item))
	first_session_guide.text = instruction
	first_session_boundary.text = boundary.replace("CAN DO:", "[color=#8ad9a7]CAN DO:[/color]").replace("WAIT:", "[color=#f2df83]WAIT:[/color]").replace("CANNOT:", "[color=#f08c8c]CANNOT:[/color]").replace("OPTIONAL:", "[color=#8ad9a7]OPTIONAL:[/color]")
	first_session_boundary.visible = true
	first_session_guide.tooltip_text = boundary
	# The guide is rebuilt synchronously during each state refresh. Free the
	# previous keyword cards immediately so repeated headless refreshes do not
	# accumulate queued controls until the next frame.
	for child in first_session_terms.get_children(): child.free()
	for term: Dictionary in terms:
		first_session_terms.add_child(_first_session_keyword(str(term.name), str(term.help)))
	if combat_hud != null: combat_hud.set_guide_progress(true, step_number)

func _first_session_keyword(term: String, explanation: String) -> PanelContainer:
	var chip := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("263746")
	style.border_color = Color("607b91")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	chip.add_theme_stylebox_override("panel", style)
	chip.tooltip_text = explanation
	var label := Label.new()
	label.text = term
	label.add_theme_color_override("font_color", Color("e3edf5"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(label)
	return chip

func _refresh_selection_card() -> void:
	if not state.units.has(selected):
		var setup_context: bool = combat_enabled and (state.get("phase", "") == "army_selection" or Combat.UnitActions.setup_actor(state) > 0 or Combat.UnitActions.battle_actor(state) > 0 or Combat.Mission.actor(state) > 0)
		selection_card.get_parent().visible = not setup_context
		selection_card.text = "No model selected. Click a miniature."
		datasheet_button.visible = false
		datasheet_details.visible = false
		return
	var unit: Dictionary = state.units[selected]
	if not combat_enabled:
		selection_card.text = "Player %d • Model %d\n%s" % [unit.owner, selected, "Moved" if unit.moved else "Ready to move"]
		datasheet_button.visible = false
		datasheet_details.visible = false
		return
	var squad: Dictionary = state.squads[unit.squad]
	datasheet_button.visible = true
	datasheet_button.text = "Hide unit datasheet" if datasheet_button.button_pressed else "Show unit datasheet"
	datasheet_details.text = _selected_datasheet(unit, squad)
	datasheet_details.visible = datasheet_button.button_pressed
	var living := 0
	for model: Dictionary in state.units.values():
		if model.squad == unit.squad and model.wounds > 0: living += 1
	selection_card.text = "%s  •  P%d\n%d models alive  •  Model %d  •  W %d/%d" % [squad.name, unit.owner, living, selected, unit.wounds, unit.max_wounds]
	if not unit.get("on_battlefield", true):
		selection_card.text += "  •  Strategic Reserves"
		return
	if unit.wounds <= 0:
		selection_card.text += "  •  Destroyed"
		return
	var defense := Combat.Allocation.Groups.profile(state, selected)
	if defense.error.is_empty(): selection_card.text += "\nT%d  •  Sv%d+  •  InSv %s" % [defense.toughness, defense.save_target, _invulnerable_text(defense)]
	selection_card.text += "  •  OC %d  •  %s" % [Combat.Morale.objective_control(state, selected), "Battle-shocked" if squad.battle_shocked else "Steady"]
	if state.phase == "movement": selection_card.text += "\nMove remaining  %.1f\"" % Combat.movement_remaining(state, selected)
	elif not squad.get("action", {}).is_empty(): selection_card.text += "\nAction in progress  •  Secure Ground"
	selection_card.tooltip_text = "FNP %s" % Combat.Attacks.Prevention.describe(unit.feel_no_pain) if not unit.get("feel_no_pain", []).is_empty() else "Selected model and unit state. Expand technical details for equipment, abilities and match context."

func _invulnerable_text(defense: Dictionary) -> String:
	var general: int = defense.invulnerable_target
	var conditional: int = defense.get("melee_invulnerable_target", 0)
	if conditional > 0 and (general == 0 or conditional < general):
		return "%d+ melee" % conditional if general == 0 else "%d+; melee %d+" % [general, conditional]
	return "—" if general == 0 else "%d+" % general

func _selected_datasheet(unit: Dictionary, squad: Dictionary) -> String:
	var stats: Dictionary = squad.get("stats", {})
	var defense := Combat.Allocation.Groups.profile(state, selected)
	var movement := int(unit.get("movement", stats.get("movement_inches", 0)))
	var toughness := int(defense.get("toughness", stats.get("toughness", 0)))
	var save := int(defense.get("save_target", stats.get("save_target", 0)))
	var wounds := int(unit.get("max_wounds", stats.get("wounds", 0)))
	var leadership := int(stats.get("leadership_target", 0))
	var oc := int(Combat.Morale.objective_control(state, selected))
	var lines: Array[String] = ["DATASHEET • MATCH PROFILE", "M %s\"  ·  T %s  ·  Sv %s+  ·  W %s  ·  Ld %s+  ·  OC %s" % [_required_stat_text(movement), _required_stat_text(toughness), _required_stat_text(save), _required_stat_text(wounds), _required_stat_text(leadership), _required_stat_text(oc)]]
	var invulnerable := _invulnerable_text(defense)
	if invulnerable != "—": lines.append("Invulnerable save %s" % invulnerable)
	for melee: bool in [false, true]:
		var options: Array[Dictionary] = Combat.AttackPlan.Equipment.choices(state, selected, melee)
		if options.is_empty(): continue
		lines.append("MELEE WEAPONS" if melee else "RANGED WEAPONS")
		for option: Dictionary in options:
			var weapon: Dictionary = option.get("stats", {})
			var range_text := "Melee" if melee else "%s\"" % _stat_text(weapon.get("range_inches", 0))
			var skill := "WS" if melee else "BS"
			var keywords: Array[String] = []
			for key: String in weapon.get("keywords", {}):
				var value: Variant = weapon.keywords[key]
				if value is bool and not value: continue
				if value is int and value == 0: continue
				if value is String and value.is_empty(): continue
				var keyword := str(KeywordGlossary.DEFINITIONS.get(key, {}).get("name", key.replace("-", " ").capitalize()))
				if value is int: keyword += " %d" % value
				elif value is String: keyword += " " + value
				keywords.append(keyword)
			var weapon_line := "%s — %s  A %s  %s %s+  S %s  AP %s  D %s" % [str(option.get("label", "Weapon")), range_text, _stat_text(weapon.get("attacks", "—")), skill, _stat_text(weapon.get("skill", 0)), _stat_text(weapon.get("strength", 0)), _stat_text(weapon.get("ap", 0)), _stat_text(weapon.get("damage", "—"))]
			if not keywords.is_empty(): weapon_line += "  ·  " + ", ".join(keywords)
			lines.append(weapon_line)
	lines.append("Profile is captured from this match; overall datasheet and rules coverage can be partial.")
	return "\n".join(lines)

func _stat_text(value: Variant) -> String:
	if value == null or str(value).is_empty(): return "—"
	if value is float and is_equal_approx(value, roundf(value)): return str(roundi(value))
	return str(value)

func _required_stat_text(value: Variant) -> String:
	if str(value) in ["0", "0.0"]: return "—"
	return _stat_text(value)

func _refresh() -> void:
	status.visible = true
	if not attack_draft.is_empty() and (not combat_enabled or attack_draft.revision != state.revision or attack_draft.get("pack_hash") != state.get("pack_hash")): attack_draft = {}
	_sync_board()
	_sync_terrain()
	_sync_ability_tokens()
	for id: int in pieces:
		var unit: Dictionary = state.units[id]
		var previews: Dictionary = Combat.Reanimation.pending(state).get("current", {}).get("placements", {}) if combat_enabled else {}
		if combat_enabled and Combat.UnitActions.pending(state).get("kind", "") == "ingress": previews = Combat.UnitActions.pending(state).positions
		if combat_enabled and Combat.UnitActions.pending(state).get("kind", "") == "healing": previews = Combat.UnitActions.pending(state).placements
		if combat_enabled and not state.get("unit_abilities", {}).get("transport_window", {}).is_empty(): previews = state.unit_abilities.transport_window.placements
		var display_position: Vector2 = previews.get(id, unit.position)
		var wounds := int(unit.get("wounds", 1))
		var on_battlefield := bool(unit.get("on_battlefield", true))
		var alive := wounds > 0 and on_battlefield
		var visible := alive or previews.has(id) or casualty_tweens.has(id)
		var target_position := Vector3(display_position.x, 0.04 if pieces[id].get_meta("imported_visual", false) else 0.65, display_position.y)
		var previous: Dictionary = board_presentation_state.get(id, {})
		var feedback_enabled := _board_motion_enabled()
		if combat_enabled and feedback_enabled and not previous.is_empty():
			var previous_wounds := int(previous.get("wounds", wounds))
			var previous_position: Vector2 = previous.get("position", display_position)
			if visible and previous_position != display_position:
				pieces[id].position = Vector3(previous_position.x, target_position.y, previous_position.y)
				var move_tween := create_tween()
				move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				move_tween.tween_property(pieces[id], "position", target_position, 0.24)
			if previous_wounds > wounds and wounds > 0:
				_show_board_feedback(id, "−%d W" % (previous_wounds - wounds), Color("f17969"))
			elif previous_wounds < wounds and wounds > 0:
				_show_board_feedback(id, "+%d W" % (wounds - previous_wounds), Color("82d49c"))
			elif previous_wounds > 0 and wounds == 0:
				_show_board_feedback(id, "Destroyed", Color("f0b46a"))
				var piece: MeshInstance3D = pieces[id]
				var resting_scale := piece.scale
				var removal := create_tween()
				casualty_tweens[id] = {"tween": removal, "scale": resting_scale}
				visible = true
				removal.tween_interval(0.45)
				removal.tween_property(piece, "scale", resting_scale * 0.05, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
				removal.tween_callback(func():
					if is_instance_valid(piece):
						piece.visible = false
						piece.scale = resting_scale
					casualty_tweens.erase(id)
				)
		if alive and casualty_tweens.has(id):
			casualty_tweens[id].tween.kill()
			pieces[id].scale = casualty_tweens[id].scale
			casualty_tweens.erase(id)
		pieces[id].visible = visible
		if not previous.is_empty() and previous.get("position", display_position) != display_position and (not feedback_enabled or not combat_enabled):
			pieces[id].position = target_position
		elif previous.is_empty() or (not visible and pieces[id].position != target_position):
			pieces[id].position = target_position
		board_presentation_state[id] = {"position": display_position, "wounds": wounds, "on_battlefield": on_battlefield}
		var color := Color("52b9d1") if unit.owner == 1 else Color("e68d5c")
		if unit.moved: color = color.darkened(0.4)
		if combat_enabled and state.units.has(selected) and unit.squad == state.units[selected].squad: color = color.lightened(0.12)
		if id == selected: color = Color("f2df83")
		if previews.has(id): color = Color("a88fea")
		pieces[id].material_override = _material(color)
	_refresh_health_tags()
	session_label.text = "Mode: %s | UDP %d | You: %s" % [mode, PORT, "both sides" if mode == "local" else str(_local_player())]
	_refresh_decision()
	if combat_enabled:
		if _has_pending_command() and command_panel_pending_revision != int(state.get("revision", -1)):
			command_panel_pending_revision = int(state.get("revision", -1))
			_set_command_panel_open(true)
		elif not _has_pending_command():
			command_panel_pending_revision = -1
	combat_hud.set_focus_available(state.units.has(selected) and pieces.has(selected) and pieces[selected].visible)
	if combat_enabled and state.get("test_battlefield", "") == TestBattlefield.ID:
		session_label.text = "Incursion test • 1,000 points • 43 × 43 inches\n%s • Rosters not points-validated" % ("Local: both players" if mode == "local" else "%s: player %d" % [mode, _local_player()])
	if state.has("saved_army_setup"):
		session_label.text += "\nSaved-list training • %d-point limit • P1 %d / P2 %d local points\n%d × %d inches • official list legality is not validated" % [state.points_limit, state.training_points[1], state.training_points[2], state.board_size.x, state.board_size.y]
	elif Combat.Mission.enabled(state): session_label.text += "\nCA 2026-27 / %s / Hammer and Anvil / fixed secondaries" % str(state.mission.get("name", "Battlefield Dominance"))
	elif state.has("match_manifest"): session_label.text += "\nPrepared custom mission • two units per side"
	if state.get("rules_practice", false): session_label.text += "\nSYNTHETIC RULES LAB • practice profiles"
	if Combat.RosterValidation.enabled(state):
		session_label.text = session_label.text.replace("Saved-list training", "Saved fixed rosters").replace("local points", "legacy MFM 1.6 snapshot points").replace("official list legality is not validated", "Wahapedia 11e coverage is partial; army legality is not certified")
		session_label.text += "\nLegacy MFM 1.6 • formations %s / %s" % ["checked" if state.roster_validation.armies[1].formations_verified else "pending", "checked" if state.roster_validation.armies[2].formations_verified else "pending"]
	var session_details := session_label.text
	session_label.tooltip_text = session_details
	session_label.text = ("LAN • HOST" if mode == "host" else "LAN • PLAYER %d" % _local_player()) if mode != "local" else "LOCAL • BOTH SIDES"
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
			if current.phase in ["rolls", "save_decision", "damage_decision"]: details.text += "\nAttack paused: choose Implacable Eradication in unit abilities, or resolve the indicated dice decision." if Combat.UnitActions.pending(state).get("kind", "") == "wound" else "\nAttack paused before the next step: accept or choose a die for Command Re-roll."
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
			var ability_names: Array[String] = []
			for model_id: int in state.units:
				if state.units[model_id].squad != unit.squad or state.units[model_id].wounds <= 0: continue
				for ability_id: String in Combat.UnitAbilities.RULES.get(Combat.UnitAbilities.identity(state.units[model_id]), []):
					var ability_name := ability_id.replace("-", " ").capitalize()
					if ability_name not in ability_names: ability_names.append(ability_name)
			if not ability_names.is_empty(): details.text += "\nReference-pass e11 abilities: " + ", ".join(ability_names)
			elif "implacable-eradication" in state.squads[unit.squad].get("enabled_abilities", []): details.text += "\nImplacable Eradication: reference profile only; current ability is disabled."
			if Combat.UnitActions.DetachmentStratagems.hungry_active(state, unit.squad): details.text += "\nHungry Void: +1 melee Strength" + (", AP improved by 1 (no stacking)" if state.detachment_stratagems.hungry[unit.squad].led else "") + " until Fight phase ends"
			if Combat.Awakened.hit_bonus(state, unit.squad) > 0: details.text += "\nCommand Protocols: +1 to hit while led"
			var active_doctrines := Combat.Doctrines.active_doctrines_for(state, unit.squad)
			if not active_doctrines.is_empty():
				var doctrine_names: Array[String] = []
				for doctrine: String in active_doctrines: doctrine_names.append(Combat.Doctrines.NAMES[doctrine])
				details.text += "\n11e doctrines • " + "; ".join(doctrine_names)
			if Combat.OathOfMoment.enabled(state):
				var marked_squad: int = state.oath_of_moment.targets.get(state.squads[unit.squad].owner, -1)
				if marked_squad != -1 and Combat.OathOfMoment.marine_army(state, state.squads[unit.squad].owner): details.text += "\nOath of Moment target: " + state.squads[marked_squad].name
			var defense := Combat.Allocation.Groups.profile(state, selected)
			if defense.error.is_empty(): details.text += "\nT%d • Sv%d+ • InSv%s" % [defense.toughness, defense.save_target, _invulnerable_text(defense)]
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
		if Combat.RosterValidation.enabled(state): details.text += "\n" + Combat.RosterValidation.summary(state)
		if Combat.Mission.enabled(state): details.text += "\n" + Combat.Mission.summary(state)
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
	scope_label.tooltip_text = ("COMBAT INTEGRATION EXERCISE — partial 11e. " + str(state.get("scope", Combat.DISABLED))) if combat_enabled else "Movement demo — use the combat exercise for persistent shooting."
	scope_label.text = "COMBAT EXERCISE • PARTIAL 11e" if combat_enabled else "LOCAL MOVEMENT PREVIEW"
	scope_label.visible = false
	if controls_help != null: controls_help.visible = not combat_enabled
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
	hail_of_bolts_choice.disabled = mode != "local"
	oath_of_moment_choice.disabled = mode != "local"
	reanimation_protocols_choice.disabled = mode != "local"
	combat_doctrines_choice.disabled = mode != "local"
	marine_detachment_choice.disabled = mode != "local" or not combat_doctrines_choice.button_pressed
	marine_detachment_choice_p2.disabled = mode != "local" or not combat_doctrines_choice.button_pressed
	checked_rosters_choice.disabled = mode != "local"
	official_mission_choice.disabled = mode != "local"
	unit_abilities_choice.disabled = mode != "local"
	awakened_dynasty_choice.disabled = mode != "local"
	count_reroll_choice.disabled = mode != "local"
	lethal_choice.visible = combat_enabled and state.phase == "shooting"
	charge_button.visible = combat_enabled and state.phase == "charge"
	charge_targets.visible = combat_enabled and state.phase == "charge" and not state.pending_charge.is_empty() and state.pending_contact.is_empty()
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
		deployment_help.text = "%s: %d/%d placed. Use the preview or place models in the zone, then Confirm deployment." % [state.squads[squad].name, placed, Combat.living(state, squad).size()]
		for ability: Dictionary in Combat.unit_choices(state, _local_player()):
			if ability.action == "seeker-objective": deployment_help.text = "%s: %d/%d placed. Select the Seeker objective in Current unit abilities before confirming." % [state.squads[squad].name, placed, Combat.living(state, squad).size()]
		deployment_help.tooltip_text = "Unplaced miniatures show preview positions only. Confirming locks this unit."
		if Combat.Mission.enabled(state): deployment_help.tooltip_text = "Hammer and Anvil • Attacker P%d left / Defender P%d right. %s" % [state.mission.attacker, state.mission.defender, deployment_help.tooltip_text]
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
			for enemy: int in Combat.ContactActions.enemies(state, squad, distance):
				contact_enemy.add_item("Contact target: " + state.squads[enemy].name, enemy)
				contact_enemy.set_item_tooltip(contact_enemy.item_count - 1, KeywordGlossary.describe_contact_action(str(state.phase), str(state.fight_step)))
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
				consolidation_objective.set_item_tooltip(consolidation_objective.item_count - 1, KeywordGlossary.describe_contact_action(str(state.phase), str(state.fight_step)))
			consolidation_objective.visible = consolidation_objective.item_count > 0
			var previous_index := consolidation_objective.get_item_index(previous_objective)
			if previous_index >= 0: consolidation_objective.select(previous_index)
	consolidation_objective.disabled = not can_act
	begin_contact_button.text = "Begin charge placement" if combat_enabled and state.phase == "charge" else "Begin pile-in" if combat_enabled and state.fight_step == "pile_in" else "Begin consolidation" if combat_enabled and state.fight_step == "consolidate" else "Begin overrun pile-in"
	begin_contact_button.tooltip_text = KeywordGlossary.describe_contact_action(str(state.get("phase", "")), str(state.get("fight_step", "")))
	begin_contact_button.disabled = not can_act or not state.units.has(selected)
	if state.units.has(selected): begin_contact_button.disabled = not can_act or state.units[selected].wounds <= 0 or state.units[selected].owner != _local_player()
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.fight_step in ["attacks", "consolidation_reaction"]:
		var squad: int = state.units[selected].squad
		if state.squads[squad].fought or state.squads[squad].overrun_used or not Combat._eligible_fighter(state, squad) or (Combat._engaged(state, squad) and state.squads[squad].was_engaged): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.units[selected].squad not in Combat.FightQueue.choices(state, _local_player()): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "charge" and state.pending_charge.get("targets", []).is_empty(): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.fight_step in ["attacks", "consolidation_reaction"] and begin_contact_button.disabled and not pending_contact:
		begin_contact_button.visible = false
		contact_enemy.visible = false
	confirm_contact_button.visible = pending_contact
	cancel_contact_button.visible = pending_contact
	confirm_contact_button.tooltip_text = "Confirm this charge/pile-in/consolidation preview. Legal placement and coherency are checked before applying the move."
	cancel_contact_button.tooltip_text = "Discard the current placement preview. The pending action remains open for another attempt."
	cancel_contact_button.text = "Cancel contact placement (retain charge roll)" if pending_contact and state.pending_contact.kind == "charge" else "Cancel contact placement"
	confirm_contact_button.disabled = not can_act
	cancel_contact_button.disabled = not can_act
	movement_choice.visible = false
	begin_move_button.visible = combat_enabled and state.phase == "movement" and not pending_move
	movement_choices.visible = combat_enabled and state.phase == "movement"
	begin_move_button.disabled = not can_act
	if begin_move_button.visible:
		begin_move_button.disabled = not can_act or not Combat.movement_choice_error(state, _local_player(), selected, MOVE_TYPES[movement_choice.selected], state.revision).is_empty()
	movement_choice.disabled = not can_act
	escape_wound_button.visible = pending_move and state.pending_move.hazard_remaining > 0
	var escape_decision := PendingDecisions.current(state, ["escape-wounds"])
	var selected_escape_option := false
	for option: Dictionary in escape_decision.get("legal_options", []):
		if int(option.get("model", -1)) == selected:
			selected_escape_option = true
			break
	escape_wound_button.disabled = not can_act or not selected_escape_option
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
	charge_button.text = "Finish charge without moving" if combat_enabled and not state.pending_charge.is_empty() else "Roll charge (2D6)"
	charge_button.disabled = combat_enabled and (Combat.actor(state) != _local_player() or state.test_winner != 0 or (mode == "host" and guest_id == 0))
	if combat_enabled and state.pending_charge.is_empty():
		if not state.units.has(selected) or state.units[selected].get("wounds", 0) <= 0 or state.units[selected].owner != _local_player():
			charge_button.disabled = true
		elif state.squads[state.units[selected].squad].charge_declared or not Combat.Doctrines.charge_error(state, state.units[selected].squad).is_empty() or Combat.Actions.charge_blocked(state, state.units[selected].squad):
			charge_button.disabled = true
		if state.phase == "charge" and not Combat.charge_declaration_error(state, _local_player(), selected, state.revision).is_empty(): charge_button.disabled = true
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
				if pool.get("benefit_of_cover", false) and not pool.get("hit_rolls", []).is_empty(): log_text += "Cover: BS worsened to %d+.\n" % pool.effective_skill
				log_text += "Dice: hit %s / wound %s / save %s\n" % [str(pool.hit_rolls), str(pool.wound_rolls), str(pool.save_rolls)]
		if event_log.text != log_text:
			event_log.text = log_text
			event_log.scroll_to_line(maxi(0, event_log.get_line_count() - 1))
	status.tooltip_text = status.text
	if status.text.length() > 118:
		var concise_notice := status.text.get_slice("\n", 0)
		if concise_notice.length() > 118: concise_notice = concise_notice.substr(0, 115) + "…"
		status.text = concise_notice
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
	_refresh_reanimation()
	_refresh_awakened()
	_refresh_unit_actions()
	if combat_enabled and Combat.UnitAbilities.enabled(state):
		lethal_choice.button_pressed = true
		lethal_choice.disabled = true
	_refresh_doctrine()
	_refresh_oath()
	_refresh_command_reaction()
	_refresh_attack_plan()
	var hazard_pending: bool = combat_enabled and not state.get("pending_hazard", {}).is_empty()
	var allocating: bool = combat_enabled and Combat.UnitActions.pending(state).get("kind", "") != "wound" and Combat.Stratagems.pending(state).is_empty() and (hazard_pending or not state.get("pending_attack", {}).is_empty())
	allocate_button.visible = allocating
	allocate_button.text = "Allocate 1 Hazardous wound" if hazard_pending else "Allocate this attack"
	var precision_pending: bool = allocating and not hazard_pending and state.pending_attack.current.phase == "precision"
	precision_skip.visible = precision_pending
	precision_skip.disabled = not can_act
	if precision_pending: allocate_button.text = "Confirm Precision"
	elif allocating and not hazard_pending:
		if state.pending_attack.current.phase == "order": allocate_button.text = "Confirm allocation group next"
		elif state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": allocate_button.text = "Allocate Devastating Wounds"
	allocate_button.disabled = not allocating or not can_act or not (Combat.Hazard.choice_error(state, _local_player(), selected) if hazard_pending else Combat.Allocation.choice_error(state, _local_player(), selected)).is_empty()
	if precision_pending and selected < 0: allocate_button.disabled = true
	if allocating:
		for control in [end_button, charge_button, begin_contact_button, begin_move_button, action_button, plan_begin, plan_confirm, coherency_button, escape_wound_button, abandon_move_button, finish_move_button, cancel_move_button, confirm_contact_button, cancel_contact_button]: control.disabled = true
	_refresh_defense_steps(allocating, hazard_pending)
	_refresh_action_groups()
	_refresh_unit_choices()
	_refresh_movement_choices()
	_refresh_contact_flow()
	_refresh_defense_presentation(allocating, hazard_pending)
	_refresh_choice_ownership()
	_refresh_blockers_help()
	if combat_enabled and not end_button.disabled and end_button.text == "Advance phase":
		var destinations := {"start_turn": "Command", "movement": "Shooting", "shooting": "Charge", "charge": "Fight", "end_turn": "Next player"}
		end_button.text = "Continue to %s →" % destinations.get(str(state.phase), "next phase")
	_refresh_first_session_guide()
	_update_guides()
	_refresh_match_result()
	if match_tabs.current_tab == 3: action_groups.phase.container.visible = false
	if combat_enabled and Combat.UnitActions.battle_actor(state) > 0:
		end_button.text = "Finish start-of-battle choices first"
		end_button.disabled = true
		end_button.tooltip_text = "Place any optional Teleport Homers, then choose Finish start-of-battle declarations in the Command panel."
	if combat_enabled and state.phase == "army_selection": status.visible = false
	if combat_enabled and (_has_pending_command() or placement_reason.visible): status.visible = false
	call_deferred("_refresh_decision_camera")

func _refresh_choice_ownership() -> void:
	_refresh_waiting_inspection()
	if not combat_enabled or mode == "local" or Combat.actor(state) == _local_player(): return
	var own_unit_choices := not Combat.unit_choices(state, _local_player()).is_empty()
	for key: String in action_groups:
		if key != "unit" or not own_unit_choices: action_groups[key].container.visible = false
	action_unit_picker.visible = false
	if reaction_die != null: reaction_die.visible = false
	reaction_reference.visible = false
	defense_reference.visible = false
	if state.units.has(selected) and state.units[selected].owner == _local_player():
		_refresh_selection_card()

func _refresh_waiting_inspection() -> void:
	waiting_unit_picker.clear()
	waiting_unit_picker.visible = combat_enabled and mode != "local" and Combat.actor(state) != _local_player() and int(state.get("test_winner", 0)) == 0 and state.phase != "army_selection"
	_refresh_waiting_activity(waiting_unit_picker.visible)
	if not waiting_unit_picker.visible: return
	waiting_unit_picker.add_item("Inspect your units…", -1)
	var seen: Array[int] = []
	for id: int in state.units:
		var unit: Dictionary = state.units[id]
		if unit.owner != _local_player() or unit.wounds <= 0 or not unit.get("on_battlefield", true) or int(unit.squad) in seen: continue
		seen.append(int(unit.squad))
		waiting_unit_picker.add_item("Inspect · " + str(state.squads[unit.squad].name), id)
		waiting_unit_picker.set_item_tooltip(waiting_unit_picker.item_count - 1, "%s · Player %d · inspection only" % [state.squads[unit.squad].name, unit.owner])
		if state.units.has(selected) and state.units[selected].squad == unit.squad: waiting_unit_picker.select(waiting_unit_picker.item_count - 1)
	waiting_unit_picker.disabled = waiting_unit_picker.item_count <= 1

func _refresh_waiting_activity(waiting: bool) -> void:
	var message := ""
	if waiting:
		var events: Array = state.get("events", [])
		for index in range(events.size() - 1, -1, -1):
			if not events[index] is Dictionary: continue
			var candidate: Variant = events[index].get("message", "")
			if candidate is String and not candidate.strip_edges().is_empty():
				message = candidate.strip_edges()
				break
	waiting_activity.visible = not message.is_empty()
	waiting_activity_text.text = message
	waiting_activity_text.tooltip_text = message

func _open_waiting_history() -> void:
	_open_history_screen()

func _inspect_waiting_unit(index: int) -> void:
	if not waiting_unit_picker.visible or index < 0 or index >= waiting_unit_picker.item_count: return
	var model := waiting_unit_picker.get_item_id(index)
	if not state.units.has(model): return
	var unit: Dictionary = state.units[model]
	if mode == "local" or Combat.actor(state) == _local_player() or unit.owner != _local_player() or unit.wounds <= 0 or not unit.get("on_battlefield", true): return
	selected = model
	_set_command_panel_open(true)
	_refresh()

func _refresh_match_result() -> void:
	match_result_panel.visible = combat_enabled and int(state.get("test_winner", 0)) in [-1, 1, 2]
	match_result_panel.set_workshop_available(not combat_enabled)
	if not match_result_panel.visible: return
	var record := MatchResult.build(state, journal.checkpoint())
	if displayed_result_id != record.id:
		match_result_panel.show_notice("")
		match_result_panel.show_saved("")
		displayed_result_id = record.id
	var reason := "" if mode == "local" else "LAN rematch is not available yet. Return to the menu to arrange the next match."
	match_result_panel.show_result(record, mode == "local", reason)
	for group: Dictionary in action_groups.values(): group.container.visible = false
	for control: Control in [first_session_panel, selection_card.get_parent(), action_unit_picker, contact_flow, result_summary, dice_toggle, dice_visual, status]: control.visible = false
	var column: Node = match_result_panel.get_parent()
	column.move_child(match_result_panel, 0)
	combat_hud.set_complete(int(state.round))

func _copy_final_result() -> void:
	var record := MatchResult.build(state, journal.checkpoint())
	if record.has("error"):
		match_result_panel.show_notice(record.error)
		return
	DisplayServer.clipboard_set(MatchResult.text(record))
	match_result_panel.show_notice("Result copied. Paste it wherever you want to share it.")

func _save_final_result(directory: String = MatchResult.DIRECTORY) -> Dictionary:
	var record := MatchResult.build(state, journal.checkpoint())
	var result := MatchResult.save(record, directory)
	match_result_panel.show_saved(result.path if result.error.is_empty() else "")
	match_result_panel.show_notice(result.error if not result.error.is_empty() else "Result saved locally.")
	return result

func _open_result_folder(path: String) -> void:
	if path.is_empty() or not FileAccess.file_exists(path):
		match_result_panel.show_notice("The saved result file is no longer available.")
		return
	var error := OS.shell_open(path.get_base_dir())
	if error != OK: match_result_panel.show_notice("Could not open the result folder (%d)." % error)

func _rematch_local(directory: String = MatchResult.DIRECTORY) -> bool:
	if mode != "local" or not combat_enabled or int(state.get("test_winner", 0)) not in [-1, 1, 2]: return false
	var candidate := MatchRestart.build(_save_config(), state)
	if candidate.has("error"):
		match_result_panel.show_notice(candidate.error)
		return false
	var saved := _save_final_result(directory)
	if not saved.error.is_empty(): return false
	state = candidate
	attack_draft = {}
	selected = -1
	host_session = {}
	board_presentation_state.clear()
	rng.randomize()
	_reset_history()
	_spawn_pieces()
	match_result_panel.show_notice("")
	status.text = "New local match · same armies and options."
	gameplay_scroll.scroll_vertical = 0
	_dismiss_home(1)
	return true

func _refresh_result_summary() -> void:
	if combat_tray.is_inside_tree():
		combat_tray.sync(state, Combat.Stratagems.pending(state) if combat_enabled else {}, dice_animation_toggle.button_pressed, combat_enabled and not main_menu.visible and tactical_overlay_content == null)
		_layout_combat_tray()
	attack_feedback.sync(state, combat_enabled and _board_motion_enabled(), not main_menu.visible and tactical_overlay_content == null)
	result_summary.visible = combat_enabled and state.has("last_attack")
	health_overlay_toggle.visible = combat_enabled
	dice_toggle.visible = result_summary.visible
	if not result_summary.visible:
		result_summary.text = ""
		dice_visual.visible = false
		dice_toggle.button_pressed = false
		return
	var last: Dictionary = state.last_attack
	_refresh_dice_visual(last)
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
	var full_result := result_summary.text
	result_summary.tooltip_text = full_result
	var compact_lines: Array[String] = ["Last completed attack"]
	for target_id: int in targets:
		var target_name: String = state.squads[target_id].name if state.squads.has(target_id) else "Target"
		var totals: Dictionary = targets[target_id]
		compact_lines.append("%s · %d attacks · %d damage · %d models out" % [target_name, totals.attacks, totals.damage, totals.destroyed])
	if prevented > 0: compact_lines.append("Feel No Pain prevented %d wounds" % prevented)
	result_summary.text = "\n".join(compact_lines)

func _attack_assignment_lines(last: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	for assignment: Dictionary in last.get("assignments", []):
		var model := int(assignment.get("model", -1))
		var target := int(assignment.get("target", -1))
		var model_label := "Model %d" % model
		if state.units.has(model):
			var unit: Dictionary = state.units[model]
			model_label = "%s · Model %d" % [str(state.squads.get(unit.get("squad", -1), {}).get("name", "Unit")), model]
		var target_label: String = str(state.squads.get(target, {}).get("name", "Target"))
		var row := "%s → %s" % [model_label, target_label]
		var weapon_id := str(assignment.get("weapon", ""))
		var profile_id := str(assignment.get("profile", ""))
		if not weapon_id.is_empty():
			var option := {}
			if state.units.has(model):
				for melee: bool in [false, true]:
					var candidate: Dictionary = Combat.AttackPlan.Equipment.select(state, model, melee, weapon_id, profile_id)
					if not candidate.has("error"):
						option = candidate
						break
			if not option.is_empty(): row += " · " + str(option.get("label", weapon_id))
			else: row += " · " + weapon_id
		if row not in lines: lines.append(row)
	return lines

func _refresh_dice_visual(last: Dictionary) -> void:
	_refresh_dice_audit()
	var signature := str(hash(var_to_str(last)))
	if signature == dice_visual_signature: return
	dice_visual_signature = signature
	dice_toggle.set_pressed_no_signal(false)
	dice_visual.visible = false
	for child in dice_visual_rolls.get_children():
		dice_visual_rolls.remove_child(child)
		child.queue_free()
	var shown := 0
	for pool: Dictionary in last.get("pools", []):
		for record: Dictionary in pool.get("attack_generation", []):
			for value: int in record.get("rolls", []):
				shown += _add_die_tile("A D6", value, Color("7654a3"), shown)
			var attack_note := "A %s → %d attacks" % [str(record.get("expression", "?")), int(record.get("total", record.get("value", 0)))]
			if not record.get("rolls", []).is_empty(): attack_note = "A %s: D6 %s → %d attacks" % [str(record.get("expression", "?")), str(record.rolls), int(record.get("total", record.get("value", 0)))]
			if int(record.get("bonus", 0)) > 0: attack_note += " (%d + %d bonus)" % [int(record.get("value", 0)), int(record.bonus)]
			_add_die_note(attack_note)
		if pool.has("final_hit_rolls"):
			for value: int in pool.final_hit_rolls:
				var hit := _classify_attack_roll("hit", value, pool)
				shown += _add_die_tile(str(hit.label), value, hit.color, shown, str(hit.symbol))
		else:
			for value: int in pool.get("hit_rolls", []): shown += _add_die_tile("HIT", value, Color("327c96"), shown)
		if pool.has("final_wound_rolls"):
			for value: int in pool.final_wound_rolls:
				var wound := _classify_attack_roll("wound", value, pool)
				shown += _add_die_tile(str(wound.label), value, wound.color, shown, str(wound.symbol))
		else:
			for value: int in pool.get("wound_rolls", []): shown += _add_die_tile("WOUND", value, Color("8a6635"), shown)
		for value: int in pool.get("save_rolls", []):
			shown += _add_die_tile("SAVE", value, Color("526d52"), shown)
		for record: Dictionary in pool.get("damage_rolls", []):
			for value: int in record.get("rolls", []):
				shown += _add_die_tile("D6", value, Color("9a4d45"), shown)
			var damage_note := "Damage %s → %d" % [str(record.get("expression", "?")), int(record.get("value", 0))]
			if not record.get("rolls", []).is_empty(): damage_note = "Damage %s: D6 %s → %d" % [str(record.get("expression", "?")), str(record.rolls), int(record.get("value", 0))]
			_add_die_note(damage_note)
		for prevention: Dictionary in pool.get("prevention_rolls", []):
			for value: int in prevention.get("rolls", []): shown += _add_die_tile("FNP", value, Color("526d52"), shown)
			if not prevention.get("rolls", []).is_empty(): _add_die_note("Feel No Pain %d+: %s → %d prevented" % [int(prevention.get("target", 0)), str(prevention.rolls), int(prevention.get("prevented", 0))])
	var hazard: Dictionary = last.get("hazardous", {})
	for value: int in hazard.get("rolls", []): shown += _add_die_tile("HAZ", value, Color("7654a3"), shown)
	if not hazard.get("rolls", []).is_empty(): _add_die_note("Hazardous: %s → %d mortal wounds" % [str(hazard.rolls), int(hazard.get("total", 0))])
	for prevention: Dictionary in hazard.get("prevention", []):
		for value: int in prevention.get("rolls", []): shown += _add_die_tile("FNP", value, Color("526d52"), shown)
		if not prevention.get("rolls", []).is_empty(): _add_die_note("Feel No Pain %d+: %s → %d prevented" % [int(prevention.get("target", 0)), str(prevention.rolls), int(prevention.get("prevented", 0))])
	if shown == 0:
		var none := Label.new()
		none.text = "No rolled dice in this result (for example, Torrent attacks)."
		dice_visual_rolls.add_child(none)

func _set_dice_details_visible(expanded: bool) -> void:
	dice_toggle.text = "Hide attack details" if expanded else "Show attack details"
	dice_visual.visible = expanded
	if expanded: call_deferred("_ensure_dice_details_visible")

func _ensure_dice_details_visible() -> void:
	await get_tree().process_frame
	if is_instance_valid(gameplay_scroll) and is_instance_valid(dice_visual_rolls): gameplay_scroll.ensure_control_visible(dice_visual_rolls)

func _refresh_dice_audit() -> void:
	if dice_audit_label == null: return
	var source := "Rolled locally" if mode == "local" else "Rolled by host" if mode == "host" else "Recorded by match host"
	if mode == "client":
		dice_audit_label.text = "Dice source: %s • see the host's match history for recorded rolls" % source
		dice_audit_label.tooltip_text = "In LAN play the host resolves and records dice. Host authority does not independently prove RNG fairness or unpredictability."
		return
	if journal.entries.is_empty():
		dice_audit_label.text = "Dice source: %s • no history record yet" % source
		dice_audit_label.tooltip_text = "The match journal is created on save or the first action that changes match state."
		return
	var roll_entry: Dictionary = {}
	for index in range(journal.entries.size() - 1, -1, -1):
		var candidate: Dictionary = journal.entries[index]
		if not candidate.get("dice", []).is_empty():
			roll_entry = candidate
			break
	var checkpoint: Dictionary = journal.checkpoint()
	var prefix := str(checkpoint.get("hash", ""))
	var hash_label := prefix.substr(0, 12) if prefix.length() >= 12 else prefix
	if roll_entry.is_empty():
		dice_audit_label.text = "Dice source: %s • no D6 recorded yet • history chain #%d • %s" % [source, int(checkpoint.get("count", 0)), hash_label]
	else:
		dice_audit_label.text = "Dice source: %s • latest recorded D6: entry #%d (%d dice) • chain %s" % [source, int(roll_entry.get("sequence", 0)), roll_entry.get("dice", []).size(), hash_label]
	dice_audit_label.tooltip_text = "The chained hash links these history records. Loading against the matching save verifies the committed prefix for changes. It does not independently prove that the host RNG was fair or unpredictable. Full chain tip: %s" % prefix
	if not autosave_error.is_empty():
		dice_audit_label.text += " • history save issue"
		dice_audit_label.tooltip_text += "\nCurrent save status: " + autosave_error

func _add_die_note(message: String) -> void:
	var note := Label.new()
	note.text = message
	note.custom_minimum_size.x = 390
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("cbd5dc"))
	dice_visual_rolls.add_child(note)

func _classify_attack_roll(stage: String, value: int, pool: Dictionary) -> Dictionary:
	if stage == "hit":
		var is_snap_shooting: bool = pool.get("snap_shooting", false)
		if is_snap_shooting:
			return {"label": "HIT" if value == 6 else "MISS", "symbol": "✓" if value == 6 else "×", "color": Color("397d59") if value == 6 else Color("884b4b")}
		if value == 6: return {"label": "CRIT", "symbol": "★", "color": Color("997b32")}
		var hit: bool = Combat.Attacks.successful_roll(value, int(pool.get("effective_skill", 6)), int(pool.get("hit_modifier", 0)))
		return {"label": "HIT" if hit else "MISS", "symbol": "✓" if hit else "×", "color": Color("397d59") if hit else Color("884b4b")}
	if value == 6: return {"label": "CRIT", "symbol": "★", "color": Color("997b32")}
	var wound: bool = Combat.Attacks.successful_roll(value, int(pool.get("wound_target", 6)), int(pool.get("wound_modifier", 0)))
	return {"label": "WOUND" if wound else "FAIL", "symbol": "✓" if wound else "×", "color": Color("397d59") if wound else Color("884b4b")}

func _add_die_tile(stage: String, value: int, color: Color, shown: int, marker: String = "") -> int:
	if shown >= 72: return 0
	var tile := PanelContainer.new()
	var animate: bool = dice_visual.is_visible_in_tree() and dice_animation_toggle != null and dice_animation_toggle.button_pressed
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(0 if marker == "×" else (12 if marker == "★" else 5))
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	tile.add_theme_stylebox_override("panel", style)
	var face := Label.new()
	face.add_theme_font_size_override("font_size", 13)
	face.add_theme_color_override("font_color", Color("ffffff"))
	var contents := HBoxContainer.new()
	contents.add_theme_constant_override("separation", 6)
	contents.add_child(face)
	var pips := DicePipFace.new()
	pips.value = clampi(value, 1, 6)
	pips.custom_minimum_size = Vector2(26, 26)
	pips.tooltip_text = "D6 face: %d" % value
	contents.add_child(pips)
	tile.add_child(contents)
	tile.custom_minimum_size = Vector2(76, 34)
	tile.pivot_offset = Vector2(38, 17)
	if animate:
		face.text = "%s D6" % stage
		pips.value = 0
		tile.scale = Vector2(0.88, 0.88)
		tile.rotation = 0.0
	else:
		face.text = "%s %s %d" % [marker, stage, value] if not marker.is_empty() else "%s %d" % [stage, value]
	dice_visual_rolls.add_child(tile)
	if animate:
		var reveal := create_tween()
		reveal.tween_interval(minf(float(shown) * 0.006, 0.35))
		reveal.tween_property(tile, "rotation", deg_to_rad(150), 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		reveal.tween_property(tile, "rotation", deg_to_rad(-150), 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		reveal.tween_property(tile, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		reveal.parallel().tween_property(tile, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		reveal.tween_callback(func():
			face.text = "%s %s %d" % [marker, stage, value] if not marker.is_empty() else "%s %d" % [stage, value]
			pips.value = clampi(value, 1, 6)
			pips.queue_redraw()
		)
	return 1

func _refresh_health_tags() -> void:
	if health_tags.is_empty(): return
	for model_id: int in health_tags:
		if not state.units.has(model_id) or not pieces.has(model_id): continue
		var unit: Dictionary = state.units[model_id]
		var tag: Dictionary = health_tags[model_id]
		var live_on_board: bool = int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true))
		tag.root.visible = combat_enabled and health_overlay_toggle != null and health_overlay_toggle.button_pressed and live_on_board
		if not tag.root.visible: continue
		var remaining := maxi(0, int(unit.get("wounds", 0)))
		var maximum := maxi(1, int(unit.get("max_wounds", remaining)))
		var ratio := clampf(float(remaining) / float(maximum), 0.0, 1.0)
		tag.fill.scale.x = ratio
		tag.fill.position.x = -0.34 + 0.34 * ratio
		tag.fill.material_override = _material(Color("5ebd80") if ratio > 0.5 else (Color("e3ad52") if ratio > 0.25 else Color("dd665e")))
		var text := "W %d/%d" % [remaining, maximum]
		if model_id == selected:
			var facts: Array[String] = []
			if combat_enabled and state.squads.has(unit.squad):
				var squad: Dictionary = state.squads[unit.squad]
				facts.append("OC %d" % Combat.Morale.objective_control(state, model_id))
				if squad.get("battle_shocked", false): facts.append("Battle-shocked")
				if unit.get("moved", false): facts.append("Moved")
			text += "\n" + " • ".join(facts)
		tag.label.text = text

func _model_choice_label(model: int) -> String:
	var unit: Dictionary = state.units[model]
	return "%s • Model %d • %d/%d wounds" % [state.squads[unit.squad].name, model, unit.wounds, unit.max_wounds]

func _refresh_defense_steps(allocating: bool, hazard: bool) -> void:
	for card: Node in recipient_cards.get_children(): card.free()
	recipient_scroll.visible = allocating
	defense_reference.visible = allocating
	defense_steps.visible = allocating
	defense_picker.visible = allocating
	defense_picker.clear()
	if not allocating: return
	defense_picker.add_item("Choose an eligible model…", -1)
	# OptionButton auto-assigns -1 IDs; explicitly set the prompt's sentinel.
	defense_picker.set_item_id(0, -1)
	var eligible: Array[int] = Combat.Hazard.eligible(state) if hazard else Combat.Allocation.eligible(state)
	recipient_scroll.custom_minimum_size.y = minf(132, maxf(44, eligible.size() * 44))
	for model: int in eligible:
		defense_picker.add_item(_model_choice_label(model), model)
		if model == selected: defense_picker.select(defense_picker.item_count - 1)
		var card := _button(recipient_cards, "%sModel %d · %d/%d wounds" % ["✓ " if model == selected else "", model, int(state.units[model].wounds), int(state.units[model].max_wounds)], func():
			selected = model
			_refresh()
		)
		card.custom_minimum_size.y = 40
		card.tooltip_text = _model_choice_label(model) + "\nSelect this recipient, then confirm allocation."
		card.disabled = Combat.actor(state) != _local_player() or (mode == "host" and guest_id == 0)
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
	defense_reference.text = defense_steps.text
	var compact_stage := stage.trim_prefix("1 • ").trim_prefix("2 • ").trim_prefix("3 • ")
	var compact_instruction := "Choose a recipient, then confirm."
	if stage == "1 • Optional Precision": compact_instruction = "Choose a character, or skip Precision."
	elif stage == "2 • Defense group order": compact_instruction = "Choose the next group before saves."
	elif hazard: compact_instruction = "Choose a recipient for 1 mortal wound."
	elif stage == "3 • Allocate damage" and state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": compact_instruction = "No save · choose a recipient."
	defense_steps.text = "%s\nPlayer %d decides · %s" % [compact_stage, Combat.actor(state), compact_instruction]
	if not hazard: defense_steps.text += "\n" + state.squads[state.pending_attack.current.target].name
	if selected in eligible and not hazard and state.pending_attack.current.phase == "damage":
		var damage := Combat.Attacks.RandomStat.spec(state.pending_attack.current.damage)
		if str(damage.get("error", "")).is_empty():
			var amount := str(damage.minimum) if damage.minimum == damage.maximum else "%d–%d" % [int(damage.minimum), int(damage.maximum)]
			defense_steps.text += "\nIncoming damage: %s before prevention." % amount

func _refresh_defense_presentation(allocating: bool, hazard: bool) -> void:
	if not allocating: return
	action_groups.defense.container.get_child(0).visible = false
	var reason: String = action_groups.defense.reason.text
	if not reason.is_empty(): defense_reference.text += "\n\nCurrent restriction: " + reason
	var eligible: Array[int] = Combat.Hazard.eligible(state) if hazard else Combat.Allocation.eligible(state)
	if selected not in eligible:
		selection_card.get_parent().visible = false
		# The stage instruction and filtered picker already explain this selection prompt.
		action_groups.defense.reason.visible = false
	if Combat.actor(state) != _local_player() or (mode == "host" and guest_id == 0):
		defense_steps.text = "Player %d decides · waiting" % Combat.actor(state)
		action_groups.defense.reason.visible = false
		defense_picker.visible = false
		recipient_scroll.visible = false
		allocate_button.visible = false
		precision_skip.visible = false

func _request_allocate_damage() -> void:
	if not combat_enabled: return
	var identity := _damage_decision_identity(selected)
	if mode == "client": request_allocate_damage.rpc_id(1, selected, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))
	else: _apply_allocate_damage(_local_player(), selected, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))

func _request_skip_precision() -> void:
	if not combat_enabled: return
	var identity := _damage_decision_identity(-1)
	if mode == "client": request_allocate_damage.rpc_id(1, -1, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))
	else: _apply_allocate_damage(_local_player(), -1, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))

func _damage_decision_identity(model: int) -> Dictionary:
	var decision := Combat.Allocation.pending_decision(state)
	for option: Dictionary in decision.get("legal_options", []):
		if int(option.get("model", -1)) == model:
			return {"decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", ""))}
	return {}

@rpc("any_peer", "call_remote", "reliable")
func request_allocate_damage(model: int, revision: int, decision_id: String = "", option_id: String = "") -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_allocate_damage(2, model, revision, decision_id, option_id)

func _apply_allocate_damage(player: int, model: int, revision: int, decision_id: String = "", option_id: String = "") -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.ALLOCATE_DAMAGE, "model": model, "revision": revision, "decision_id": decision_id, "option_id": option_id}, _d6)
	_present_match_command(player, result)

func _begin_attack_plan() -> void:
	if not combat_enabled or not state.units.has(selected): return
	var melee: bool = state.phase == "fight"
	var error := Combat.attack_window_error(state, _local_player(), selected, state.revision, melee)
	if not error.is_empty():
		status.text = error
		return
	_set_command_panel_open(true)
	attack_draft = {"squad": state.units[selected].squad, "attacker": selected, "melee": melee, "revision": state.revision, "pack_hash": state.pack_hash, "entries": [], "indirect_shooting": false}
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
	if mode == "client": request_attack_plan.rpc_id(1, draft.attacker, draft.entries, draft.revision, draft.melee, lethal_choice.button_pressed, draft.get("hail_target", -1), draft.get("indirect_shooting", false))
	else: _apply_attack_plan(_local_player(), draft.attacker, draft.entries, draft.revision, draft.melee, lethal_choice.button_pressed, draft.get("hail_target", -1), draft.get("indirect_shooting", false))

func _selected_shooting_complete() -> bool:
	if not combat_enabled or state.phase != "shooting" or not attack_draft.is_empty(): return false
	if not state.units.has(selected) or state.units[selected].owner != Combat.actor(state): return false
	if state.units[selected].wounds <= 0: return false
	return bool(state.squads[state.units[selected].squad].get("shot", false))

func _refresh_attack_plan() -> void:
	var editing := not attack_draft.is_empty()
	shooting_complete.visible = _selected_shooting_complete()
	if shooting_complete.visible: lethal_choice.visible = false
	plan_begin.visible = combat_enabled and state.phase in ["shooting", "fight"] and not editing and (state.phase != "fight" or state.fight_step in ["attacks", "consolidation_reaction"])
	if shooting_complete.visible: plan_begin.visible = false
	plan_begin.disabled = true
	if plan_begin.visible: plan_begin.disabled = not Combat.attack_window_error(state, _local_player(), selected, state.revision, state.phase == "fight").is_empty() or (mode == "host" and guest_id == 0)
	for control in [plan_steps, plan_hail, indirect_choice, plan_weapon, plan_target, plan_amount, plan_add, plan_clear, plan_summary, plan_assignment_status, damage_preview, plan_confirm, plan_cancel]: control.visible = editing
	if not editing: return
	var can_indirect: bool = not attack_draft.melee and not Combat.AttackPlan.Queue.engaged(state, attack_draft.squad) and not state.squads[attack_draft.squad].advanced and Combat.AttackPlan._has_indirect_fire(state, attack_draft.squad)
	indirect_choice.visible = can_indirect
	indirect_choice.set_pressed_no_signal(attack_draft.get("indirect_shooting", false))
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
			plan_weapon.set_item_tooltip(index, KeywordGlossary.describe_weapon(option))
			if index == 0: plan_weapon.select(0)
			if option.weapon == previous_weapon.get("weapon", "") and option.profile == previous_weapon.get("profile", ""): plan_weapon.select(index)
		var choice := _plan_weapon_choice()
		if not choice.is_empty():
			for target: int in Combat.AttackPlan.legal_targets(state, selected, attack_draft.melee, choice.weapon, choice.profile, attack_draft.get("indirect_shooting", false)): plan_target.add_item("Target: " + state.squads[target].name, target)
		var index := plan_target.get_item_index(previous_target)
		if index >= 0: plan_target.select(index)
		elif plan_target.item_count > 0: plan_target.select(0)
	plan_amount.visible = editing and attack_draft.melee
	var selected_weapon := _plan_weapon_choice()
	if not selected_weapon.is_empty(): plan_weapon.tooltip_text = KeywordGlossary.describe_weapon(selected_weapon)
	if attack_draft.melee and not selected_weapon.is_empty() and selected_weapon.stats.attacks is String: plan_amount.visible = false
	plan_amount.max_value = Combat.UnitAbilities.melee_attack_count(state, selected, selected_weapon.stats) if attack_draft.melee and own_model and not selected_weapon.is_empty() and not selected_weapon.stats.attacks is String else 1
	plan_add.disabled = not own_model or plan_target.item_count == 0
	plan_clear.disabled = not own_model
	plan_steps.text = "1 • Select a living model from %s.\nSelected: %s\n2 • Choose weapon/profile, target%s.\n3 • Assign; repeat for the other models/weapons.\n4 • Review the plan and confirm to roll dice. Cancel discards this draft." % [state.squads[attack_draft.squad].name, _model_choice_label(selected) if own_model else "no model from the attacking unit", " and attack count" if attack_draft.melee else ""]
	var firing_deck_limit := FiringDeck.model_limit(state, attack_draft.attacker) if not attack_draft.melee else 0
	if firing_deck_limit > 0 and FiringDeck.embarked_model_count(state, attack_draft.attacker) > 0:
		plan_steps.text += "\nFiring Deck %d: choose up to %d embarked models, one non-One Shot ranged weapon per model. All units embarked in this transport become ineligible to shoot for the rest of the turn." % [firing_deck_limit, firing_deck_limit]
	var target_order: Array[int] = []
	var target_names: Array[String] = []
	for entry: Dictionary in attack_draft.entries:
		if entry.target not in target_order:
			target_order.append(entry.target)
			target_names.append(state.squads[entry.target].name)
	var assigned_by_model: Dictionary = {}
	for entry: Dictionary in attack_draft.entries:
		var model := int(entry.model)
		var target_name: String = str(state.squads.get(int(entry.target), {}).get("name", "Target"))
		var assignment_text := "Model %d → %s" % [model, target_name]
		var weapon_id := str(entry.get("weapon", ""))
		if not weapon_id.is_empty():
			var option := Combat.AttackPlan.Equipment.select(state, model, attack_draft.melee, weapon_id, str(entry.get("profile", "")))
			assignment_text += " · " + str(option.get("label", weapon_id))
		if not assigned_by_model.has(model): assigned_by_model[model] = []
		assigned_by_model[model].append(assignment_text)
	var confirmed_rows: Array[String] = []
	var unassigned_models: Array[String] = []
	var living_models := 0
	for model: int in state.units:
		var candidate: Dictionary = state.units[model]
		if int(candidate.get("squad", -1)) != attack_draft.squad or int(candidate.get("wounds", 0)) <= 0 or not candidate.get("on_battlefield", true): continue
		living_models += 1
		if assigned_by_model.has(model): confirmed_rows.append_array(assigned_by_model[model])
		else: unassigned_models.append("Model %d" % model)
	var assignment_lines: Array[String] = ["TARGETS DEFINED · %d/%d models" % [assigned_by_model.size(), living_models]]
	if confirmed_rows.is_empty(): assignment_lines.append("No models assigned yet.")
	else: assignment_lines.append("Assigned: " + "; ".join(confirmed_rows))
	if not unassigned_models.is_empty(): assignment_lines.append("No target yet: " + ", ".join(unassigned_models))
	plan_assignment_status.text = "\n".join(assignment_lines)
	plan_steps.text += "\nReview: %d assignments • %d target units" % [attack_draft.entries.size(), target_order.size()]
	if not target_names.is_empty(): plan_steps.text += "\nResolution order: " + " → ".join(target_names)
	plan_confirm.text = "Confirm and resolve attack plan"
	plan_summary.text = "Assigned attacks for " + state.squads[attack_draft.squad].name
	if firing_deck_limit > 0 and FiringDeck.embarked_model_count(state, attack_draft.attacker) > 0:
		plan_summary.text += "\nFiring Deck %d: passenger weapons are fired by the transport. Embarked units cannot shoot for the rest of this turn." % firing_deck_limit
	if Combat.UnitAbilities.has(state, attack_draft.squad, "targeter-optics"):
		plan_summary.text += "\nTargeter Optics: visible ranged targets ignore cover."
	if attack_draft.get("indirect_shooting", false):
		plan_summary.text += "\nIndirect Fire: hidden targets allowed; target gains Cover; no hit re-rolls; unmodified 1–5 fail (1–3 if stationary and a friendly unit sees the target). After shooting this way, no action this phase."
	if attack_draft.get("hail_target", -1) != -1:
		plan_summary.text += "\nHail of Bolts: +2 attacks per bolt rifle targeting " + state.squads[attack_draft.hail_target].name
	if attack_draft.melee: plan_summary.text += "\nChoose one ordinary melee weapon and all eligible Extra Attacks weapons for each model."
	for entry: Dictionary in attack_draft.entries:
		var option := Combat.AttackPlan.Equipment.select(state, entry.model, attack_draft.melee, entry.get("weapon", ""), entry.get("profile", ""))
		plan_summary.text += "\nModel %d • %s → %s ×%d%s" % [entry.model, option.label, state.squads[entry.target].name, entry.amount, " attacks" if attack_draft.melee and not option.stats.attacks is String else " weapon"]
		if attack_draft.melee and option.stats.attacks is String: plan_summary.text += " (A %s generated when resolving; one target)" % option.stats.attacks
	if attack_draft.melee and Combat.UnitAbilities.melee_bonus(state, attack_draft.squad) > 0:
		plan_steps.text += "\nDeeds of Legend: +1 A per melee weapon while the unit is in objective range. Allocate the modified attack count, including when splitting targets."
	# Keep full instructions available without placing the manual above the controls.
	plan_steps.tooltip_text = plan_steps.text
	attack_reference.text = plan_steps.text
	plan_steps.text = "Select → Assign → Review\n%d assignments · %d targets" % [attack_draft.entries.size(), target_order.size()]
	if not own_model: plan_steps.text = "Select a model from %s\n%d assignments" % [state.squads[attack_draft.squad].name, attack_draft.entries.size()]
	if attack_draft.melee and Combat.UnitAbilities.melee_bonus(state, attack_draft.squad) > 0:
		plan_steps.text += "\nDeeds of Legend: allocate +1 A per weapon."
	var error := Combat.attack_plan_error(state, _local_player(), attack_draft.attacker, attack_draft.entries, attack_draft.revision, attack_draft.melee, lethal_choice.button_pressed, attack_draft.get("hail_target", -1), attack_draft.get("indirect_shooting", false))
	plan_confirm.disabled = not error.is_empty()
	plan_summary.text += "\n" + ("Ready to resolve." if error.is_empty() else error)
	_refresh_damage_preview()

func _refresh_damage_preview() -> void:
	damage_preview.text = "Conditional raw damage if every generated attack becomes one unsaved wound:"
	if attack_draft.entries.is_empty():
		damage_preview.text += "\nAssign attacks to see each weapon's damage range."
		return
	var prepared := Combat.AttackPlan.prepare(state, attack_draft.squad, attack_draft.melee, attack_draft.entries, lethal_choice.button_pressed, attack_draft.get("hail_target", -1), attack_draft.get("indirect_shooting", false))
	if not prepared.get("error", "").is_empty():
		damage_preview.text += "\nComplete a valid assignment to calculate the profile values."
		return
	var total_minimum := 0
	var total_maximum := 0
	for batch: Dictionary in prepared.get("batches", []):
		var damage := Combat.Attacks.RandomStat.spec(batch.weapon.damage)
		if not damage.get("error", "").is_empty(): continue
		var attack_minimum := 0
		var attack_maximum := 0
		var sources: Array = batch.get("context", {}).get("attack_sources", [])
		if sources.is_empty():
			var low_pool := Combat.Attacks.generate_attacks(batch.weapon, batch.get("context", {}).duplicate(true), func(): return 1)
			var high_pool := Combat.Attacks.generate_attacks(batch.weapon, batch.get("context", {}).duplicate(true), func(): return 6)
			if not low_pool.get("error", "").is_empty() or not high_pool.get("error", "").is_empty(): continue
			attack_minimum = int(low_pool.count)
			attack_maximum = int(high_pool.count)
		else:
			for source: Dictionary in sources:
				var generated := Combat.Attacks.RandomStat.spec(source.expression)
				if not generated.get("error", "").is_empty(): continue
				var fixed_bonus := int(source.get("bonus", 0))
				attack_minimum += int(generated.minimum) + fixed_bonus
				attack_maximum += int(generated.maximum) + fixed_bonus
		var low := attack_minimum * int(damage.minimum)
		var high := attack_maximum * int(damage.maximum)
		total_minimum += low
		total_maximum += high
		var target_name: String = state.squads[batch.target].name if state.squads.has(batch.target) else "Target"
		var attack_range := str(attack_minimum) if attack_minimum == attack_maximum else "%d–%d" % [attack_minimum, attack_maximum]
		damage_preview.text += "\n%s → %s: %s generated attacks × %s = %d–%d raw damage" % [", ".join(batch.get("labels", [batch.weapon.get("name", "Weapon")])), target_name, attack_range, str(batch.weapon.damage), low, high]
	if total_maximum > 0:
		damage_preview.text += "\nAll pools: %d–%d in this conditional scenario." % [total_minimum, total_maximum]
	damage_preview.text += "\nAttack/wound rolls, critical or extra hits, saves and damage prevention can change applied damage. This is not a prediction."

func _plan_weapon_choice() -> Dictionary:
	if plan_weapon.selected < 0 or plan_weapon.item_count == 0: return {}
	return plan_weapon.get_item_metadata(plan_weapon.selected)

@rpc("any_peer", "call_remote", "reliable")
func request_attack_plan(attacker: int, entries: Array, revision: int, melee: bool, lethal: bool, hail_target: int = -1, indirect_shooting: bool = false) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_attack_plan(2, attacker, entries, revision, melee, lethal, hail_target, indirect_shooting)

func _apply_attack_plan(player: int, attacker: int, entries: Array, revision: int, melee: bool, lethal: bool, hail_target: int = -1, indirect_shooting: bool = false) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.ATTACK_PLAN, "attacker": attacker, "entries": entries, "revision": revision, "melee": melee, "use_lethal": lethal, "hail_target": hail_target, "indirect_shooting": indirect_shooting}, _d6)
	_present_match_command(player, result)

func _sync_terrain() -> void:
	if terrain_root == null: return
	var areas: Array = Combat.Terrain.areas(state)
	var signature := var_to_str(areas) + var_to_str(state.get("mission", {}).get("objectives", [])) + str(state.get("phase", "") == "deployment") + var_to_str(state.get("deployment", {}).get("zones", {}))
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
	if not saved_army_mode and saved_training_consent.button_pressed:
		_start_saved_match(false)
		if not saved_army_mode or not combat_enabled: return
	if saved_army_mode and not saved_training_consent.button_pressed:
		status.text = "Accept the partial rules before starting LAN training."
		return
	var initial := _initial_state()
	if initial.has("error"):
		status.text = initial.error
		return
	var transport_error: String = session_transport.start_host(PORT, 1)
	if not transport_error.is_empty():
		status.text = transport_error
		return
	mode = "host"
	match_session.start_host()
	state = initial
	_reset_history()
	if saved_army_mode:
		pending_armies = {}
		state.ready_armies = []
		saved_army_pickers[1].select(0)
	_spawn_pieces()
	selected = -1
	status.text = "Waiting for player 2. Both players choose and submit their own list in the match."
	_refresh()

func _join() -> void:
	if not saved_army_mode and saved_training_consent.button_pressed:
		_start_saved_match(false)
		if not saved_army_mode or not combat_enabled: return
	if saved_army_mode:
		if not saved_training_consent.button_pressed:
			status.text = "Accept the partial rules before joining LAN training."
			return
		submitted_army = {}
		saved_army_pickers[2].select(0)
		validated_saved_setup = ""
		state = _initial_state()
		_reset_history()
		_spawn_pieces()
	var transport_error: String = session_transport.start_client(address.text.strip_edges(), PORT)
	if not transport_error.is_empty():
		status.text = transport_error
		return
	mode = "client"
	match_session.guest_ready()
	selected = -1
	status.text = "Connecting…"
	_refresh()

func _offline(message: String) -> void:
	session_transport.reset()
	mode = "local"
	match_session.reset()
	local_visual_armies.clear()
	state = _initial_state()
	_reset_history()
	_spawn_pieces()
	selected = -1
	status.text = message
	_refresh()

func _peer_connected(id: int) -> void:
	if mode == "host":
		var challenge: Dictionary = match_session.begin_challenge(id)
		receive_seat_challenge.rpc_id(id, host_session.id, challenge.nonce, challenge.claimed)
		status.text = "Verifying player 2 credentials…"
		get_tree().create_timer(10.0).timeout.connect(func():
			if mode == "host" and pending_seats.get(id, {}).get("nonce") == challenge.nonce:
				match_session.reject(id)
				session_transport.disconnect_peer(id)
				status.text = "Verification timed out; waiting for player 2.")

@rpc("authority", "call_remote", "reliable")
func receive_seat_challenge(session_id: String, nonce: String, claimed: bool) -> void:
	if mode != "client": return
	var proof: Dictionary = match_session.accept_challenge(session_id, nonce, claimed)
	if not proof.error.is_empty():
		_offline(proof.error)
		return
	request_seat.rpc_id(1, proof.response)

@rpc("any_peer", "call_remote", "reliable")
func request_seat(response: String) -> void:
	var id := multiplayer.get_remote_sender_id()
	if mode != "host": return
	var decision: Dictionary = match_session.decide_seat(id, response)
	match decision.status:
		"ignore": return
		"issue_token":
			receive_seat_token.rpc_id(id, decision.session_id, decision.nonce, decision.token)
			return
		"reject":
			_reject_seat(id)
			return
		"authenticated": pass
		_: return
	# Make the reservation durable before allowing commands or publishing state.
	var error := match_session.reserve(decision.session, Callable(self, "_save_snapshot"), str(state.get("phase", "")))
	if not error.is_empty():
		status.text = "Could not save the seat reservation: " + error
		_reject_seat(id)
		return
	match_session.admit(id)
	receive_seat_ready.rpc_id(id)
	status.text = "Player 2 authenticated. Match is ready."
	_broadcast()

func _reject_seat(id: int) -> void:
	match_session.reject(id)
	receive_seat_rejected.rpc_id(id)
	var peer: MultiplayerPeer = session_transport.current_peer()
	get_tree().create_timer(0.3).timeout.connect(func():
		if mode == "host" and session_transport.current_peer() == peer and session_transport.has_peer(id): session_transport.disconnect_peer(id))

@rpc("authority", "call_remote", "reliable")
func receive_seat_token(session_id: String, nonce: String, token: String) -> void:
	if mode != "client" or seat_challenge.get("id") != session_id or seat_challenge.get("nonce") != nonce: return
	var result: Dictionary = match_session.receive_token(session_id, nonce, token)
	if not result.error.is_empty():
		_offline("Could not save your credentials: " + result.error)
		return
	request_seat.rpc_id(1, result.response)

@rpc("authority", "call_remote", "reliable")
func receive_seat_ready() -> void:
	if mode != "client": return
	match_session.guest_ready()
	if saved_army_mode:
		network_army_status.text = "Connected. Choose your list and submit."
		_refresh_network_army_selection()

@rpc("authority", "call_remote", "reliable")
func receive_seat_rejected() -> void:
	if mode == "client": _offline("Seat credentials were rejected or the reservation could not be saved.")

func _peer_disconnected(id: int) -> void:
	var disconnected: Dictionary = match_session.peer_disconnected(id)
	if mode == "host" and disconnected.pending:
		status.text = "Verification interrupted; waiting for the guest with this session's credentials."
	if mode == "host" and disconnected.guest:
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
		receive_state.rpc_id(guest_id, Combat.Mission.public_state(state, 2))
	if not autosave_error.is_empty() and state.get("phase") != "army_selection":
		status.text = "Autosave failed: " + autosave_error

func _save_config() -> Dictionary:
	var saved_event_layout := str(state.get("mission", {}).get("terrain_layout", _selected_official_terrain_layout()))
	var saved_primary_mission := str(state.get("mission", {}).get("primary_id", _selected_official_primary_mission()))
	var selected_detachment := marine_detachment if combat_doctrines else "none"
	var selected_detachments: Dictionary = _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}
	# The manifest preserves both declarations even when only one player is Marine.
	var match_manifest: Dictionary = state.get("match_manifest", {})
	var declared_detachments: Dictionary = match_manifest.get("marine_detachments", {})
	if not declared_detachments.is_empty(): selected_detachments = declared_detachments.duplicate(true)
	if match_manifest.has("marine_detachment"): selected_detachment = str(match_manifest.marine_detachment)
	return {"combat_enabled": combat_enabled, "saved_army_mode": saved_army_mode, "prepared_match": prepared_match, "terrain_layout": terrain_layout, "mission_id": mission_id, "squads_per_side": squads_per_side, "manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "allocation_practice": allocation_practice, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": selected_detachment, "marine_detachments": selected_detachments, "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "official_terrain_layout": saved_event_layout, "official_primary_mission": saved_primary_mission, "checked_rosters": checked_rosters}

func _reset_history() -> void:
	for record: Dictionary in casualty_tweens.values(): record.tween.kill()
	casualty_tweens.clear()
	attack_feedback.reset()
	combat_tray.reset()
	_clear_placement_feedback()
	_stop_camera_motion()
	last_camera_key = ""
	last_camera_area = Rect2()
	camera_manual_override = false
	if camera != null:
		pivot.position = Vector3.ZERO
		var board_size: Vector2 = Rules.half_board(state) * 2.0
		zoom = maxf(18.0, maxf(board_size.x, board_size.y) * 0.82)
		_update_camera()
	journal.storage_directory = match_journal_directory
	journal.reset(state)
	autosave_error = ""
	if history_panel != null: history_panel.show_page(journal.page())

func _journal_page(start: int = -1) -> Dictionary:
	var page: Dictionary = journal.page(start)
	page.checkpoint = journal.checkpoint()
	if not autosave_error.is_empty() and state.get("phase") != "army_selection": page.notice = "Save failed: " + autosave_error
	return page

func _save_snapshot() -> String:
	if state.get("phase") == "army_selection": return "Complete both army selections before saving."
	var pending_state_error := Combat.MatchActor.pending_state_error(state)
	if not pending_state_error.is_empty(): return pending_state_error
	journal.storage_directory = match_journal_directory
	var error: String = journal.capture(state)
	if not error.is_empty(): return "History: " + error
	return MatchSave.write(state, _save_config(), rng.state, attack_draft, match_save_path, host_session, journal.checkpoint())

func _history_page(start: int = -1) -> void:
	if mode == "client":
		var peer: MultiplayerPeer = session_transport.current_peer()
		if peer is ENetMultiplayerPeer and session_transport.connected():
			request_history_page.rpc_id(1, start)
		else:
			history_panel.show_page({"items": [], "start": 0, "total": 0, "notice": "Connect to the match host to read its battle log."})
	else:
		history_panel.show_page(_journal_page(start))

@rpc("any_peer", "call_remote", "reliable")
func request_history_page(start: int) -> void:
	if Combat.Mission.secret_formations(state): return
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
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

func _load_match(as_host: bool = false, validate_only: bool = false) -> void:
	resume_compatible = false
	resume_succeeded = false
	if mode != "local":
		status.text = "Disconnect from the LAN session before resuming a saved match."
		return
	var saved := MatchSave.read(match_save_path)
	if saved.has("error"):
		status.text = saved.error
		return
	var pending_state_error := Combat.MatchActor.pending_state_error(saved.state)
	if not pending_state_error.is_empty():
		status.text = "The saved match contains an invalid pending decision state."
		return
	var config: Dictionary = saved.config
	# Older saves predate the opt-in rule; their public state and hashes stay intact.
	if not config.has("core_stratagems"): config.core_stratagems = false
	if not config.has("checked_rosters"): config.checked_rosters = false
	if config.checked_rosters != Combat.RosterValidation.enabled(saved.state):
		status.text = "The saved-roster option or legacy price snapshot does not match the save."
		return
	if not config.has("official_mission"): config.official_mission = false
	if not config.has("official_primary_mission"): config.official_primary_mission = str(saved.state.get("mission", {}).get("primary_id", "battlefield-dominance"))
	if not config.has("official_terrain_layout"):
		config.official_terrain_layout = str(saved.state.get("mission", {}).get("terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT))
	if not Combat.Terrain.is_event_layout(str(config.official_terrain_layout)) or str(config.official_terrain_layout) != str(saved.state.get("mission", {}).get("terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT)):
		status.text = "The selected 11th-edition terrain layout does not match the save."
		return
	if config.official_mission != Combat.Mission.enabled(saved.state):
		status.text = "The selected mission option does not match the save."
		return
	if config.official_mission and (not Combat.Mission.PRIMARY_MISSIONS.has(str(config.official_primary_mission)) or str(config.official_primary_mission) != str(saved.state.get("mission", {}).get("primary_id", "battlefield-dominance"))):
		status.text = "The selected primary mission does not match the save."
		return
	if not config.has("unit_abilities"): config.unit_abilities = false
	if config.unit_abilities != Combat.UnitAbilities.enabled(saved.state):
		status.text = "The unit abilities option does not match the save."
		return
	if not config.has("awakened_dynasty"): config.awakened_dynasty = false
	if config.awakened_dynasty != Combat.Awakened.enabled(saved.state):
		status.text = "The Awakened Dynasty option does not match the save."
		return
	if not config.has("combat_doctrines"): config.combat_doctrines = false
	if config.combat_doctrines != Combat.Doctrines.enabled(saved.state):
		status.text = "The Combat Doctrines option does not match the save."
		return
	if not config.has("marine_detachment"):
		config.marine_detachment = str(saved.state.get("combat_doctrines", {}).get("detachment", "gladius" if config.combat_doctrines else "none"))
	# Compare the saved declaration, not only the detachment effects active for Marine owners.
	var saved_detachments: Dictionary = saved.state.get("match_manifest", {}).get("marine_detachments", {})
	if saved_detachments.is_empty(): saved_detachments = saved.state.get("combat_doctrines", {}).get("detachments", {})
	if saved_detachments.is_empty():
		var legacy_detachment := str(saved.state.get("combat_doctrines", {}).get("detachment", "gladius" if config.combat_doctrines else "none"))
		saved_detachments = {1: legacy_detachment, 2: legacy_detachment}
	if not config.has("marine_detachments"): config.marine_detachments = saved_detachments.duplicate(true)
	if not _marine_detachment_assignments_equal(config.marine_detachments, saved_detachments):
		status.text = "The per-player Space Marine detachment selections do not match the save."
		return
	if config.marine_detachment != str(saved.state.get("combat_doctrines", {}).get("detachment", "gladius" if config.combat_doctrines else "none")) and not str(saved.state.get("combat_doctrines", {}).get("detachment", "")).is_empty():
		status.text = "The Space Marine detachment selection does not match the save."
		return
	if not config.has("reanimation_protocols"): config.reanimation_protocols = false
	if config.reanimation_protocols != Combat.Reanimation.enabled(saved.state):
		status.text = "The Reanimation Protocols option does not match the save."
		return
	if not config.has("oath_of_moment"): config.oath_of_moment = false
	if config.oath_of_moment != (saved.state.get("oath_of_moment", {}).get("implementation", "") == Combat.OathOfMoment.ID):
		status.text = "The Oath of Moment option does not match the save."
		return
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
	if not restored_session is Dictionary or (not restored_session.is_empty() and not MatchSession.valid_host_session(restored_session)):
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
		initial = PreparedTraining.initial_state({"manual_allocation": config.manual_allocation, "varied_equipment": config.varied_equipment, "core_stratagems": config.core_stratagems, "movement_rerolls": config.movement_rerolls, "attack_rerolls": config.attack_rerolls, "save_rerolls": config.save_rerolls, "damage_rerolls": config.damage_rerolls, "hazard_rerolls": config.hazard_rerolls, "escape_rerolls": config.escape_rerolls, "count_rerolls": config.count_rerolls, "objective_secured": config.objective_secured, "implacable_eradication": config.implacable_eradication, "hail_of_bolts": config.hail_of_bolts, "oath_of_moment": config.oath_of_moment, "reanimation_protocols": config.reanimation_protocols, "combat_doctrines": config.combat_doctrines, "marine_detachment": config.marine_detachment, "marine_detachments": config.get("marine_detachments", {1: config.marine_detachment, 2: config.marine_detachment}), "awakened_dynasty": config.awakened_dynasty, "unit_abilities": config.unit_abilities, "official_mission": config.official_mission, "primary_mission": config.official_primary_mission, "terrain_layout": config.official_terrain_layout, "checked_rosters": config.checked_rosters})
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
	restored_journal.storage_directory = match_journal_directory
	var history_error: String = restored_journal.restore(saved.get("journal", {}), saved.state)
	if not history_error.is_empty():
		status.text = history_error
		return
	resume_compatible = true
	if validate_only:
		status.text = "Saved match is compatible."
		return
	if as_host:
		var transport_error: String = session_transport.start_host(PORT, 1)
		if not transport_error.is_empty():
			status.text = transport_error
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
	oath_of_moment_choice.button_pressed = oath_of_moment
	reanimation_protocols_choice.button_pressed = reanimation_protocols
	combat_doctrines_choice.button_pressed = combat_doctrines
	marine_detachment = str(marine_detachments.get(1, marine_detachments.get("1", marine_detachment)))
	marine_detachment_p2 = str(marine_detachments.get(2, marine_detachments.get("2", marine_detachment_p2)))
	_select_marine_detachment(marine_detachment_choice, marine_detachment)
	_select_marine_detachment(marine_detachment_choice_p2, marine_detachment_p2)
	checked_rosters_choice.set_pressed_no_signal(checked_rosters)
	official_mission_choice.set_pressed_no_signal(official_mission)
	_select_official_primary_mission(str(config.official_primary_mission))
	_select_official_terrain_layout(str(config.official_terrain_layout))
	_refresh_official_layout_controls()
	unit_abilities_choice.set_pressed_no_signal(unit_abilities)
	awakened_dynasty_choice.button_pressed = awakened_dynasty
	state = saved.state
	guided_first_session = TrainingRoster.Tactical.matches(state)
	journal = restored_journal
	autosave_error = ""
	match_session.start_host(restored_session)
	rng.state = saved.rng_state
	attack_draft = saved.attack_draft
	selected = -1
	pending_armies = {}
	validated_saved_setup = ""
	if as_host:
		mode = "host"
	_spawn_pieces()
	_refresh()
	status.text = "Match resumed; waiting for player 2 on LAN." if as_host else "Match resumed with decisions and dice preserved."
	if history_panel.is_visible_in_tree(): _history_page(-1)
	if as_host and not host_session.token.is_empty(): status.text += " Vaga reservada ao convidado original."
	resume_succeeded = true

@rpc("authority", "call_remote", "reliable")
func receive_state(snapshot: Dictionary) -> void:
	if mode != "client": return
	var pending_state_error := Combat.MatchActor.pending_state_error(snapshot)
	if not pending_state_error.is_empty():
		_offline("The host sent an invalid pending decision state.")
		return
	var expected: Dictionary = state
	var setup_digest := JSON.stringify(snapshot.get("saved_army_setup", {})).sha256_text()
	if saved_army_mode and snapshot.has("saved_army_setup") and (setup_digest != validated_saved_setup or snapshot.get("pack_hash") != state.get("pack_hash")):
		if snapshot.saved_army_setup.get("options", {}).get("checked_rosters", false) != checked_rosters:
			_offline("Players have different roster-validation settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("official_mission", false) != official_mission:
			_offline("Players have different mission settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("unit_abilities", false) != unit_abilities:
			_offline("Players have different current unit ability settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("awakened_dynasty", false) != awakened_dynasty:
			_offline("Players have different Awakened Dynasty settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("combat_doctrines", false) != combat_doctrines:
			_offline("Players have different Combat Doctrines settings.")
			return
		var remote_detachments: Dictionary = snapshot.saved_army_setup.get("options", {}).get("marine_detachments", {1: snapshot.saved_army_setup.get("options", {}).get("marine_detachment", "gladius" if combat_doctrines else "none"), 2: snapshot.saved_army_setup.get("options", {}).get("marine_detachment", "gladius" if combat_doctrines else "none")})
		var local_detachments: Dictionary = _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}
		if not _marine_detachment_assignments_equal(remote_detachments, local_detachments):
			_offline("Players have different Space Marine detachment selections.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("reanimation_protocols", false) != reanimation_protocols:
			_offline("Players have different Reanimation Protocols settings.")
			return
		if snapshot.saved_army_setup.get("options", {}).get("oath_of_moment", false) != oath_of_moment:
			_offline("Players have different Oath of Moment settings.")
			return
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
		if expected.has("error"):
			_offline("The received list configuration is incompatible with the local data pack.")
			return
		if not submitted_army.is_empty() and _selection_digest(expected.saved_army_setup.armies[2]) != _selection_digest(submitted_army):
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
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_move(2, id, target, revision)

func _apply_move(player: int, id: int, target: Vector2, revision: int = -1) -> void:
	if mode == "host" and guest_id == 0:
		status.text = "Wait for player 2."
		return
	if combat_enabled:
		var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.PLACE_MODEL, "model": id, "destination": target, "revision": revision})
		_placement_result(player, id, target, str(result.get("error", "")))
		_present_match_command(player, result)
		return
	var reason: String = Rules.validate_move(state, player, id, target)
	if not reason.is_empty():
		_placement_result(player, id, target, reason)
		_feedback(player, reason)
		return
	_placement_result(player, id, target, "")
	var distance: float = state.units[id].position.distance_to(target)
	state.units[id].position = target
	state.units[id].moved = true
	_feedback(player, "Moved %.2f units." % distance)
	_broadcast()

func _clear_placement_feedback() -> void:
	placement_feedback.clear()
	if placement_reason != null: placement_reason.visible = false

func _placement_result(player: int, model: int, destination: Vector2, error: String) -> void:
	if mode == "host" and player == 2:
		if guest_id != 0: receive_placement_feedback.rpc_id(guest_id, model, destination, error)
		return
	receive_placement_feedback(model, destination, error)

@rpc("authority", "call_remote", "reliable")
func receive_placement_feedback(model: int, destination: Vector2, error: String) -> void:
	_clear_placement_feedback()
	if error.is_empty() or not state.units.has(model): return
	placement_feedback.show_reason(model, destination, error, true)
	placement_reason.text = "Placement blocked · " + error + "\nChoose another destination, or cancel the placement."
	placement_reason.visible = true
	_set_command_panel_open(true)
	var location: Vector2 = state.units[model].position
	placement_feedback.place(camera, Vector3(location.x, 1.7, location.y), _camera_board_area())

func _feedback(player: int, message: String) -> void:
	if saved_army_mode and combat_enabled and state.get("phase", "") == "army_selection" and network_army_status != null:
		network_army_status.text = message
		network_army_status.visible = true
	if setup_feedback_status != null and Combat.UnitActions.setup_actor(state) > 0 and not message.is_empty():
		setup_feedback_status.text = message
		setup_feedback_status.visible = true
	if mode == "host" and player == 2:
		receive_feedback.rpc_id(guest_id, message)
	else:
		status.text = message
		status.visible = not placement_reason.visible

@rpc("authority", "call_remote", "reliable")
func receive_feedback(message: String) -> void:
	if saved_army_mode and combat_enabled and state.get("phase", "") == "army_selection" and network_army_status != null:
		network_army_status.text = message
		network_army_status.visible = true
	if setup_feedback_status != null and Combat.UnitActions.setup_actor(state) > 0 and not message.is_empty():
		setup_feedback_status.text = message
		setup_feedback_status.visible = true
	status.text = message

func _request_end() -> void:
	if mode == "client":
		request_end.rpc_id(1, int(state.get("revision", -1)), selected)
	else:
		_apply_end(_local_player(), int(state.get("revision", -1)), selected)

func _refresh_command_reaction() -> void:
	var window := Combat.Stratagems.pending(state) if combat_enabled else {}
	reaction_reference.visible = not window.is_empty()
	reaction_dice.visible = not window.is_empty() and window.get("kind", "") != "before_battle_shock"
	reaction_dice_hint.visible = reaction_dice.visible
	for control in [reaction_help, reaction_squad, reaction_roll, reaction_use]: control.visible = not window.is_empty()
	if reaction_sudden != null:
		reaction_sudden.visible = window.get("valour", false) or window.get("master_shadows", false) or (window.get("kind", "") == "after_advance_roll" and (window.get("sudden", false) or window.get("supercharged", false) or window.get("honour_vigilance", false) or window.get("wrath_chapter", false) or window.get("stormseers_wisdom", false)))
		reaction_sudden.text = _free_movement_reroll_label(window)
	if window.is_empty():
		reaction_focus_key = ""
		if reaction_die != null: reaction_die.visible = false
		return
	var attack: bool = window.kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"]
	var rolling: bool = window.kind != "before_battle_shock"
	if reaction_die == null:
		reaction_die = OptionButton.new()
		reaction_use.get_parent().add_child(reaction_die)
		reaction_die.get_parent().move_child(reaction_die, reaction_use.get_index())
	reaction_die.visible = attack
	reaction_die.tooltip_text = "Choose the eligible D6 to replace with Command Re-roll. The new result is mandatory, even if it is lower. Core Rules §15.02 (June 2026). " + KeywordGlossary.RULES_URL if attack else ""
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
	reaction_squad.tooltip_text = "Choose the unit that will take this Battle-shock test or be the target of Insane Bravery. Insane Bravery must be chosen before rolling. Core Rules §§08, 15.04. " + KeywordGlossary.RULES_URL if not rolling else ""
	reaction_roll.disabled = waiting
	var honour_roll: bool = rolling and window.get("honour_vigilance", false)
	var stratagem := ("honour-of-vigilance" if honour_roll else "command-re-roll") if rolling else "insane-bravery"
	var error := "" if honour_roll else Combat.Stratagems.use_error(state, player, reaction_squad.get_selected_id(), stratagem, state.revision)
	reaction_use.disabled = waiting or not error.is_empty()
	if reaction_sudden != null: reaction_sudden.disabled = waiting
	reaction_use.text = ("Honour of Vigilance • 0 CP" if honour_roll else "Command Re-roll • 1 CP • uma vez por fase") if rolling else "Insane Bravery • 1 CP • uma vez por batalha"
	reaction_roll.text = "Accept result and continue" if rolling else "Roll Battle-shock normally"
	reaction_use.tooltip_text = KeywordGlossary.describe_stratagem_decision(str(window.kind), error.is_empty() and not waiting, error)
	reaction_roll.tooltip_text = KeywordGlossary.describe_accept_decision(str(window.kind))
	if attack:
		reaction_help.text = "%s • P%d • %d CP\n%s: %s. Choose a die to replace or accept all.\nThe next step has not been rolled yet; the new result will be mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], "Saves" if window.kind == "after_save_roll" else ("Hits" if window.kind == "after_hit_roll" else "Wounds"), str(window.rolls)]
		if window.kind == "after_attack_count_roll": reaction_help.text = "%s • P%d • %d CP\nAttacks: %d • A %s • D6: %s.\nChoose one die or accept the pool. Bonuses and other dice stay the same; D3 converts D6 results to 1–3. Hits have not been rolled. The new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], window.total, str(window.expression), str(window.rolls)]
		elif window.kind == "after_escape_roll":
			reaction_help.text = "Desperate Escape hazards: %s. Replace one D6 or accept." % str(window.rolls)
			reaction_help.tooltip_text = "P%d · %d CP. 1–2 fails; 3–6 passes. The new result is mandatory." % [window.player, state.cp[window.player]]
		elif window.kind == "after_hazardous_roll": reaction_help.text = "%s • P%d • %d CP\nHazardous: %s. Choose a D6 to replace or accept the pool.\n1–2 fails; 3–6 passes. The new result is mandatory, even if it is worse. Mortal wounds and prevention are waiting for this decision." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls)]
		elif window.kind == "after_damage_roll": reaction_help.text = "%s • P%d • %d CP\nDamage %s = %d • Original D6: %s.\nChoose a D6 to replace. For D3, each D6 converts to 1–3. Recipient %d stays fixed; prevention and casualties wait for this decision. The new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.expression), window.value, str(window.rolls), window.model]
	elif rolling:
		var total := 0
		for die: int in window.rolls: total += die
		reaction_help.text = "%s • P%d • %d CP\n%s: %s = %d inches.\nAccepting costs no CP. Command Re-roll replaces %s; the new result is mandatory, even if it is lower." % [state.squads[window.squad].name, window.player, state.cp[window.player], "Advance" if window.kind == "after_advance_roll" else "Charge", str(window.rolls), total, "the D6" if window.kind == "after_advance_roll" else "both D6"]
	else:
		reaction_help.text = "P%d • %d CP • %d pending test(s). Choose the next unit.\nRolling normally costs no CP. Insane Bravery passes the test without rolling dice." % [window.player, state.cp[window.player], window.remaining.size()]
	if window.get("supercharged", false): reaction_help.text = "%s • P%d • %d CP\nAdvance %s = %d inches.\nSupercharged Engines lets this Mounted unit re-roll its Advance roll for 0 CP. Accept or re-roll once; the new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls), int(window.rolls[0])]
	elif window.get("honour_vigilance", false): reaction_help.text = "%s • P%d • %d CP\nAdvance %s = %d inches.\nHonour of Vigilance lets this unit re-roll its Advance roll for 0 CP while Devastator Doctrine is active. Accept or re-roll once; the new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls), int(window.rolls[0])]
	elif window.get("valour", false): reaction_help.text = "%s • P%d • %d CP\nCharge %s = %d inches.\nUnstoppable Valour replaces BOTH D6 for 0 CP. Accept or re-roll once. The new result is mandatory, even if lower; these dice cannot be re-rolled again." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls), int(window.rolls[0]) + int(window.rolls[1])]
	elif window.get("master_shadows", false): reaction_help.text = "%s • P%d • %d CP\nCharge %s = %d inches.\nMaster of Shadows may re-roll both D6 for 0 CP. Accept or re-roll once; the final result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], str(window.rolls), int(window.rolls[0]) + int(window.rolls[1])]
	elif window.get("wrath_chapter", false): reaction_help.text = "%s • P%d • %d CP\nAdvance D6 = %d inches.\nWrath of the Chapter lets this Tacticus unit re-roll its Advance roll for 0 CP. Accept or re-roll once; the new result is mandatory." % [state.squads[window.squad].name, window.player, state.cp[window.player], int(window.rolls[0])]
	if not error.is_empty() and not waiting and not window.get("valour", false) and not window.get("master_shadows", false) and not window.get("supercharged", false) and not window.get("honour_vigilance", false) and not window.get("wrath_chapter", false): reaction_help.text += "\n" + error
	reaction_reference.text = reaction_help.text + "\n\n" + reaction_use.tooltip_text + "\n\n" + reaction_roll.tooltip_text
	var names := {"after_hit_roll": "Hits", "after_wound_roll": "Wounds", "after_save_roll": "Saves", "after_damage_roll": "Damage", "after_hazardous_roll": "Hazardous", "after_attack_count_roll": "Attack count", "after_escape_roll": "Desperate Escape hazards", "after_advance_roll": "Advance", "after_charge_roll": "Charge", "before_battle_shock": "Battle-shock"}
	var title: String = names.get(str(window.kind), "Dice decision")
	action_groups.reaction.container.get_child(0).text = title
	reaction_help.text = "Player %d decides · %d CP" % [window.player, state.cp[window.player]]
	selection_card.get_parent().visible = false
	if rolling:
		if window.kind not in ["after_advance_roll", "after_charge_roll"]: reaction_help.text += "\n" + state.squads[window.squad].name
		if window.kind in ["after_advance_roll", "after_charge_roll"]:
			var total := 0
			for value: int in window.rolls: total += value
			reaction_help.text += "\n%s · %d\" rolled" % [state.squads[window.squad].name, total]
		elif window.kind == "after_damage_roll": reaction_help.text += "\nDamage %s = %d · recipient %d" % [str(window.expression), int(window.value), int(window.model)]
		elif window.kind == "after_attack_count_roll": reaction_help.text += "\nA %s = %d attacks" % [str(window.expression), int(window.total)]
		elif window.kind == "after_escape_roll": reaction_help.text += "\nDesperate Escape hazards"
		reaction_help.text += "\nOptional: keep these dice for 0 CP."
		reaction_roll.text = "Keep result · 0 CP"
		reaction_use.text = "Command Re-roll · 1 CP"
	else:
		reaction_help.text += "\nChoose the next unit · %d tests pending" % window.remaining.size()
		reaction_roll.text = "Roll Battle-shock · 0 CP"
		reaction_use.text = "Insane Bravery · pass · 1 CP"
	if not error.is_empty() and not waiting: reaction_help.text += "\n%s unavailable: %s" % ["Command Re-roll" if rolling else "Insane Bravery", error]
	if waiting: reaction_help.text = "Waiting for player %d · %s" % [window.player, title]
	if reaction_sudden.visible:
		reaction_sudden.text = "Re-roll both D6 · 0 CP" if window.kind == "after_charge_roll" else _free_movement_reroll_label(window)
		reaction_sudden.tooltip_text = reaction_reference.text
	_refresh_pending_dice(window, attack, waiting)
	var focus_key := str(window.get("kind", "")) + ":" + str(state.revision)
	if not waiting and focus_key != reaction_focus_key:
		reaction_focus_key = focus_key
		reaction_roll.call_deferred("grab_focus")
		gameplay_scroll.set_deferred("scroll_vertical", 0)

func _free_movement_reroll_label(window: Dictionary) -> String:
	if window.get("valour", false): return "Unstoppable Valour: re-roll Charge · 0 CP"
	if window.get("master_shadows", false): return "Master of Shadows: re-roll Charge · 0 CP"
	if window.get("supercharged", false): return "Supercharged Engines: re-roll Advance · 0 CP"
	if window.get("stormseers_wisdom", false): return "Stormseer's Wisdom: re-roll Advance · 0 CP"
	if window.get("honour_vigilance", false): return "Honour of Vigilance: re-roll Advance · 0 CP"
	if window.get("wrath_chapter", false): return "Wrath of the Chapter: re-roll Advance · 0 CP"
	if window.get("sudden", false): return "Sudden Storm: re-roll Advance · 0 CP"
	return ""

func _select_reaction_die(die: int) -> void:
	if not reaction_dice.is_visible_in_tree() or reaction_die.disabled: return
	var window := Combat.Stratagems.pending(state)
	if window.is_empty() or die not in window.get("eligible", []) or window.player != _local_player(): return
	var index := reaction_die.get_item_index(die)
	if index < 0: return
	reaction_die.select(index)
	_refresh()

func _refresh_pending_dice(window: Dictionary, single: bool, waiting: bool) -> void:
	for button: Button in reaction_dice_buttons.values(): button.visible = false
	if not reaction_dice.visible: return
	var indices: Array = window.eligible.duplicate() if single else range(window.rolls.size())
	var shown := indices.slice(0, 12)
	var selected_die := reaction_die.get_selected_id() if single else -1
	if selected_die in indices and selected_die not in shown and not shown.is_empty(): shown[shown.size() - 1] = selected_die
	for die: int in shown:
		if not reaction_dice_buttons.has(die):
			var button := Button.new()
			button.custom_minimum_size = Vector2(64, 64)
			button.toggle_mode = true
			button.pressed.connect(func(): _select_reaction_die(die))
			var content := VBoxContainer.new()
			content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			content.offset_left = 6
			content.offset_right = -6
			content.offset_top = 4
			content.offset_bottom = -4
			content.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(content)
			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 12)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(label)
			var face := DicePipFace.new()
			face.custom_minimum_size = Vector2(28, 28)
			face.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			face.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(face)
			button.set_meta("label", label)
			button.set_meta("face", face)
			reaction_dice.add_child(button)
			reaction_dice_buttons[die] = button
		var button: Button = reaction_dice_buttons[die]
		button.visible = true
		button.disabled = waiting or not single
		button.set_pressed_no_signal(single and die == selected_die)
		var label: Label = button.get_meta("label")
		label.text = "%s#%d" % ["✓ " if single and die == selected_die else "", die + 1]
		var face: Control = button.get_meta("face")
		face.value = int(window.rolls[die])
		face.queue_redraw()
		button.tooltip_text = "D6 #%d = %d" % [die + 1, int(window.rolls[die])]
		if window.has("labels"): button.tooltip_text += "\n" + str(window.labels[die])
	reaction_dice_hint.text = "Select one D6 to replace." if single else "The re-roll replaces both D6." if window.kind == "after_charge_roll" else "The re-roll replaces this D6."
	if indices.size() > 12: reaction_dice_hint.text += " Showing %d of %d; all dice in Help." % [shown.size(), indices.size()]
	if waiting: reaction_dice_hint.visible = false

func _request_use_reaction() -> void:
	var window: Dictionary = Combat.Stratagems.pending(state)
	_request_command_reaction("insane-bravery" if window.get("kind", "") == "before_battle_shock" else "honour-of-vigilance" if window.get("honour_vigilance", false) else "command-re-roll")

func _request_command_reaction(stratagem: String) -> void:
	var squad := reaction_squad.get_selected_id()
	# Keeping a pool has no replacement die. A selected D6 belongs only to re-roll.
	var die := reaction_die.get_selected_id() if reaction_die != null and not stratagem.is_empty() else -1
	var choice := _stratagem_choice_payload(squad, stratagem, die)
	if mode == "client": request_command_reaction.rpc_id(1, choice, state.revision)
	else: _apply_command_reaction(_local_player(), choice, state.revision)

func _stratagem_choice_payload(squad: int, stratagem: String, die: int) -> Dictionary:
	var choice := {"action": "stratagem-reaction", "model": -1, "target": squad, "value": stratagem, "die": die}
	var decision := Combat.Stratagems.pending_decision(state)
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) != str(choice.action): continue
		if int(option.get("target", -1)) != squad or str(option.get("value", "")) != stratagem: continue
		if int(option.get("details", {}).get("die", -1)) != die: continue
		option_id = str(option.get("id", ""))
		break
	return {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": option_id, "choice": choice}

@rpc("any_peer", "call_remote", "reliable")
func request_command_reaction(choice: Dictionary, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_command_reaction(2, choice, revision)

func _apply_command_reaction(player: int, choice: Dictionary, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var selected: Dictionary = choice.get("choice", {})
	var squad := int(selected.get("target", -1))
	var stratagem := str(selected.get("value", ""))
	var morale: bool = Combat.Stratagems.pending(state).get("kind") == "before_battle_shock"
	var attack: bool = Combat.Stratagems.pending(state).get("kind") in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"]
	var hazard: bool = Combat.Stratagems.pending(state).get("kind") == "after_hazardous_roll"
	var escape: bool = Combat.Stratagems.pending(state).get("kind") == "after_escape_roll"
	var command_result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.COMMAND_REACTION, "choice": choice, "revision": revision}, _d6)
	if not str(command_result.get("error", "")).is_empty(): _feedback(player, command_result.error); return
	_broadcast()
	var message: String
	if morale:
		var result: Dictionary = state.last_morale[-1]
		message = "Insane Bravery: test passed without rolling." if not stratagem.is_empty() else "Battle-shock %s vs %d: %s." % [str(result.rolls), result.target, "passed" if result.passed else "failed"]
	else:
		message = "%s: %s → %s." % ["Unstoppable Valour" if stratagem == "unstoppable-valour" else ("Supercharged Engines" if stratagem == "supercharged-engines" else ("Stormseer's Wisdom" if stratagem == "stormseers-wisdom" else ("Honour of Vigilance" if stratagem == "honour-of-vigilance" else ("Wrath of the Chapter" if stratagem == "wrath-of-the-chapter" else ("Sudden Storm re-roll" if stratagem == "sudden-storm" else ("Command Re-roll" if not stratagem.is_empty() else "Result accepted")))))), str(state.last_command_roll.original_rolls), str(state.last_command_roll.rolls)]
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
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_end(2, revision, model)

func _apply_end(player: int, revision: int = -1, model: int = -1) -> void:
	if mode == "host" and guest_id == 0: return
	if combat_enabled and state.phase == "deployment":
		_apply_deployment(player, revision, true)
		return
	if combat_enabled:
		var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.ADVANCE_PHASE, "revision": revision, "model": model}, _d6)
		if not result.error.is_empty():
			_feedback(player, result.error)
			return
		_broadcast()
		_feedback(player, result.message)
		return
	if player != state.active:
		_feedback(player, "Wait for your turn.")
		return
	Rules.end_turn(state)
	_broadcast()

@rpc("any_peer", "call_remote", "reliable")
func request_attack(attacker: int, target: int, revision: int, use_lethal: bool) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_attack(2, attacker, target, revision, use_lethal)

func _apply_attack(player: int, attacker: int, target: int, revision: int, use_lethal: bool) -> void:
	if not combat_enabled: return
	if mode == "host" and guest_id == 0:
		status.text = "Wait for player 2."
		return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SHOOT, "attacker": attacker, "target": target, "revision": revision, "use_lethal": use_lethal}, _d6)
	_present_match_command(player, result)

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
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_action(2, model, objective, revision)

func _apply_action(player: int, model: int, objective: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.START_ACTION, "model": model, "objective": objective, "revision": revision})
	_present_match_command(player, result)

func _request_begin_movement() -> void:
	if not combat_enabled: return
	var move_type: String = MOVE_TYPES[movement_choice.selected]
	var sudden := sudden_onslaught_choice.button_pressed
	if mode == "client": request_begin_movement.rpc_id(1, selected, move_type, state.revision, sudden)
	else: _apply_begin_movement(_local_player(), selected, move_type, state.revision, sudden)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_movement(model: int, move_type: String, revision: int, use_sudden_onslaught: bool = false) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_begin_movement(2, model, move_type, revision, use_sudden_onslaught)

func _apply_begin_movement(player: int, model: int, move_type: String, revision: int, use_sudden_onslaught: bool = false) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.BEGIN_MOVEMENT, "model": model, "move_type": move_type, "revision": revision, "use_sudden_onslaught": use_sudden_onslaught}, _d6)
	if not str(result.get("error", "")).is_empty(): _feedback(player, result.error); return
	sudden_onslaught_choice.set_pressed_no_signal(false)
	_broadcast()
	_feedback(player, result.message)

func _request_escape_wound() -> void:
	if not combat_enabled: return
	var choice := _escape_wound_choice_payload(selected)
	if mode == "client": request_escape_wound.rpc_id(1, choice, state.revision)
	else: _apply_escape_wound(_local_player(), choice, state.revision)

func _request_abandon_fall_back() -> void:
	if not combat_enabled: return
	if mode == "client": request_abandon_fall_back.rpc_id(1, state.revision)
	else: _apply_abandon_fall_back(_local_player(), state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_abandon_fall_back(revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_abandon_fall_back(2, revision)

func _apply_abandon_fall_back(player: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.ABANDON_FALL_BACK, "revision": revision})
	_present_match_command(player, result)

@rpc("any_peer", "call_remote", "reliable")
func request_escape_wound(choice: Dictionary, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_escape_wound(2, choice, revision)

func _apply_escape_wound(player: int, choice: Dictionary, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.ALLOCATE_ESCAPE_WOUND, "choice": choice, "revision": revision}, _d6)
	_present_match_command(player, result)

func _escape_wound_choice_payload(model: int) -> Dictionary:
	var decision := PendingDecisions.current(state, ["escape-wounds"])
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == "allocate-escape-mortal-wound" and int(option.get("model", -1)) == model:
			option_id = str(option.get("id", ""))
			break
	return {"_decision_type": MatchCommandService.ESCAPE_WOUND_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": option_id, "choice": {"action": "allocate-escape-mortal-wound", "model": model}}

func _request_coherency_removal() -> void:
	if not combat_enabled: return
	var choice := _coherency_choice_payload(selected)
	if mode == "client": request_coherency_removal.rpc_id(1, choice, state.revision)
	else: _apply_coherency_removal(_local_player(), choice, state.revision)

func _coherency_choice_payload(model: int) -> Dictionary:
	var decision := PendingDecisions.current(state, ["coherency"])
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == "remove-coherency-model" and int(option.get("model", -1)) == model:
			option_id = str(option.get("id", ""))
			break
	return {"_decision_type": MatchCommandService.COHERENCY_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": option_id, "choice": {"action": "remove-coherency-model", "model": model}}

@rpc("any_peer", "call_remote", "reliable")
func request_coherency_removal(choice: Dictionary, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_coherency_removal(2, choice, revision)

func _apply_coherency_removal(player: int, choice: Dictionary, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var selected_choice: Dictionary = choice.get("choice", {})
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": int(selected_choice.get("model", -1)), "decision_id": str(choice.get("decision_id", "")), "option_id": str(choice.get("option_id", "")), "revision": revision})
	_present_match_command(player, result)

func _request_finish_movement(cancel: bool) -> void:
	if not combat_enabled: return
	if mode == "client": request_finish_movement.rpc_id(1, state.revision, cancel)
	else: _apply_finish_movement(_local_player(), state.revision, cancel)

@rpc("any_peer", "call_remote", "reliable")
func request_finish_movement(revision: int, cancel: bool) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_finish_movement(2, revision, cancel)

func _apply_finish_movement(player: int, revision: int, cancel: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.FINISH_MOVEMENT, "revision": revision, "cancel": cancel}, _d6)
	if state.units.has(selected): _placement_result(player, selected, state.units[selected].position, str(result.get("error", "")))
	_present_match_command(player, result)

func _request_charge_roll() -> void:
	if not combat_enabled: return
	var decline: bool = not state.pending_charge.is_empty()
	if mode == "client": request_charge_roll.rpc_id(1, selected, state.revision, decline)
	else: _apply_charge_roll(_local_player(), selected, state.revision, decline)

@rpc("any_peer", "call_remote", "reliable")
func request_charge_roll(model: int, revision: int, decline: bool) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_charge_roll(2, model, revision, decline)

func _apply_charge_roll(player: int, model: int, revision: int, decline: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.CHARGE_ROLL, "model": model, "revision": revision, "decline": decline}, _d6)
	_present_match_command(player, result)

@rpc("any_peer", "call_remote", "reliable")
func request_charge(target: int, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_charge(2, target, revision)

func _apply_charge(player: int, target: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.CHARGE_TARGET, "target": target, "revision": revision})
	_present_match_command(player, result)

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
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_begin_contact(2, model, kind, revision, objective, targets)

func _apply_begin_contact(player: int, model: int, kind: String, revision: int, objective: int = -1, targets: Array[int] = []) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.BEGIN_CONTACT, "model": model, "move_kind": kind, "revision": revision, "targets": targets, "objective": objective})
	_present_match_command(player, result)

@rpc("any_peer", "call_remote", "reliable")
func request_contact_move(model: int, destination: Vector2, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_contact_move(2, model, destination, revision)

func _apply_contact_move(player: int, model: int, destination: Vector2, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.STAGE_CONTACT, "model": model, "destination": destination, "revision": revision})
	_placement_result(player, model, destination, str(result.get("error", "")))
	_present_match_command(player, result)

func _request_finish_contact(cancel: bool) -> void:
	if not combat_enabled: return
	if mode == "client": request_finish_contact.rpc_id(1, state.revision, cancel)
	else: _apply_finish_contact(_local_player(), state.revision, cancel)

@rpc("any_peer", "call_remote", "reliable")
func request_finish_contact(revision: int, cancel: bool) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_finish_contact(2, revision, cancel)

func _apply_finish_contact(player: int, revision: int, cancel: bool) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.FINISH_CONTACT, "revision": revision, "cancel": cancel})
	if state.units.has(selected): _placement_result(player, selected, state.units[selected].position, str(result.get("error", "")))
	_present_match_command(player, result)

func _present_match_command(player: int, result: Dictionary) -> void:
	if not str(result.get("error", "")).is_empty():
		_feedback(player, str(result.error))
		return
	_broadcast()
	_feedback(player, str(result.get("message", "Command completed.")))

@rpc("any_peer", "call_remote", "reliable")
func request_fight(attacker: int, target: int, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_fight(2, attacker, target, revision)

func _apply_fight(player: int, attacker: int, target: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.FIGHT, "attacker": attacker, "target": target, "revision": revision}, _d6)
	_present_match_command(player, result)

func _refresh_oath() -> void:
	var pending: bool = combat_enabled and Combat.OathOfMoment.needs_choice(state)
	for control in [oath_help, oath_target, oath_confirm]: control.visible = pending
	if not pending: return
	var previous := oath_target.get_selected_id()
	oath_target.clear()
	for target: int in Combat.OathOfMoment.targets(state, state.active): oath_target.add_item(state.squads[target].name, target)
	oath_target.select(maxi(0, oath_target.get_item_index(previous)))
	var waiting: bool = _local_player() != state.active or (mode == "host" and guest_id == 0)
	oath_target.disabled = waiting
	oath_confirm.disabled = waiting or oath_target.item_count == 0
	oath_help.text = "Player %d: choose one enemy, then Confirm." % state.active
	oath_help.tooltip_text = "Until your next Command phase, Marine attacks against that enemy re-roll failed hits and may gain the Codex +1 wound bonus. No CP."

func _request_oath_target() -> void:
	var target := oath_target.get_selected_id()
	var identity := _oath_decision_identity(target)
	if mode == "client": request_oath_target.rpc_id(1, target, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))
	else: _apply_oath_target(_local_player(), target, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))

@rpc("any_peer", "call_remote", "reliable")
func request_oath_target(target: int, revision: int, decision_id: String, option_id: String) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_oath_target(2, target, revision, decision_id, option_id)

func _oath_decision_identity(target: int) -> Dictionary:
	var decision := Combat.OathOfMoment.pending_decision(state)
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == "oath-target" and int(option.get("target", -1)) == target:
			return {"decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", ""))}
	return {}

func _apply_oath_target(player: int, target: int, revision: int, decision_id: String, option_id: String) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_OATH_TARGET, "target": target, "revision": revision, "decision_id": decision_id, "option_id": option_id})
	_present_match_command(player, result)

func _reanimation_model_selected(_index: int) -> void:
	var model := reanimation_model.get_selected_id()
	if not state.units.has(model): return
	var point: Vector2 = Combat.Reanimation.pending(state).get("current", {}).get("placements", {}).get(model, state.units[model].position)
	reanimation_x.value = point.x
	reanimation_z.value = point.y

func _refresh_reanimation() -> void:
	var window: Dictionary = Combat.Reanimation.pending(state) if combat_enabled else {}
	var controls := [reanimation_help, reanimation_squad, reanimation_roll, reanimation_model, reanimation_x, reanimation_z, reanimation_place, reanimation_suggest, reanimation_failure, reanimation_reset, reanimation_confirm]
	for control in controls: control.visible = not window.is_empty()
	if window.is_empty(): return
	end_button.disabled = true
	var waiting: bool = _local_player() != window.player or (mode == "host" and guest_id == 0)
	var current: Dictionary = window.current
	if current.get("reroll_pending", false):
		for control in [reanimation_squad, reanimation_roll, reanimation_model, reanimation_x, reanimation_z, reanimation_place, reanimation_suggest, reanimation_failure, reanimation_reset, reanimation_confirm]: control.visible = false
		reanimation_help.text = "Their Number is Legion: choose keep or re-roll in the unit ability controls."
		return
	var choosing := current.is_empty()
	var previous := reanimation_squad.get_selected_id()
	reanimation_squad.clear()
	for squad: int in window.remaining: reanimation_squad.add_item(state.squads[squad].name, squad)
	reanimation_squad.select(maxi(0, reanimation_squad.get_item_index(previous)))
	reanimation_squad.visible = choosing
	reanimation_roll.visible = choosing
	reanimation_squad.disabled = waiting
	reanimation_roll.disabled = waiting
	for control in [reanimation_model, reanimation_x, reanimation_z, reanimation_place, reanimation_suggest, reanimation_failure, reanimation_reset, reanimation_confirm]:
		control.visible = not choosing
		if control is BaseButton or control is OptionButton: control.disabled = waiting
		if control is SpinBox: control.editable = not waiting
	if choosing:
		reanimation_help.text = "Player %d: choose the next unit and roll D3. Intact units still activate. Living models heal before troops return; destroyed units and Characters do not return. %d units remaining." % [window.player, window.remaining.size()]
		return
	previous = reanimation_model.get_selected_id()
	reanimation_model.clear()
	for model: int in Combat.Reanimation.returnable(state):
		var suffix := " [preview]" if current.placements.has(model) else " [declared unplaceable]" if model in current.unplaced else ""
		reanimation_model.add_item("Model %d%s" % [model, suffix], model)
	reanimation_model.select(maxi(0, reanimation_model.get_item_index(previous)))
	_reanimation_model_selected(0)
	reanimation_confirm.disabled = waiting or not Combat.Reanimation.confirm_error(state).is_empty()
	reanimation_help.text = "%s • D6 %d → %s %d\nReturn attempts %d/%d. Purple = preview. Living-model healing is reserved first.\nChoose a destroyed model, set X/Z or right-click, then confirm. Return within 2 inches of a Command-entry survivor. Equipment is preserved." % [state.squads[current.squad].name, current.raw_roll, current.get("healing_die", "D3"), current.budget, current.placements.size() + current.unplaced.size(), current.slots]

func _request_reanimation(action: String) -> void:
	var point := Vector2(reanimation_x.value, reanimation_z.value)
	var squad := int(Combat.Reanimation.pending(state).get("current", {}).get("squad", reanimation_squad.get_selected_id())) if action != "roll" else reanimation_squad.get_selected_id()
	var model := reanimation_model.get_selected_id() if action in ["place", "unplaceable"] else -1
	var choice := _reanimation_choice_payload(action, squad, model)
	if mode == "client": request_reanimation.rpc_id(1, choice, point, state.revision)
	else: _apply_reanimation(_local_player(), choice, point, state.revision)

func _reanimation_choice_payload(action: String, squad: int, model: int) -> Dictionary:
	var choice := {"action": "reanimation", "model": model, "target": squad, "value": action}
	var decision := Combat.Reanimation.pending_decision(state)
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) != str(choice.action): continue
		if int(option.get("model", -1)) != model or int(option.get("target", -1)) != squad: continue
		if str(option.get("value", "")) != action: continue
		option_id = str(option.get("id", ""))
		break
	return {"_decision_type": MatchCommandService.REANIMATION_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": option_id, "choice": choice}

@rpc("any_peer", "call_remote", "reliable")
func request_reanimation(choice: Dictionary, point: Vector2, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_reanimation(2, choice, point, revision)

func _apply_reanimation(player: int, choice: Dictionary, point: Vector2, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.RESOLVE_REANIMATION, "choice": choice, "point": point, "revision": revision}, _d6)
	_present_match_command(player, result)

func _refresh_doctrine() -> void:
	var pending: bool = combat_enabled and Combat.Doctrines.needs_choice(state)
	for control in [doctrine_help, doctrine_choice, doctrine_confirm]: control.visible = pending
	if not pending: return
	end_button.disabled = true
	var previous := doctrine_choice.get_selected_id()
	doctrine_choice.clear()
	doctrine_choice.add_item(Combat.Doctrines.NAMES.none, 0)
	var selected_detachment: String = str(state.combat_doctrines.get("detachment", "gladius"))
	var mastery_doctrines: Array = Combat.Doctrines.DETACHMENT_EXTRA_DOCTRINES.get(selected_detachment, [])
	for doctrine: String in Combat.Doctrines.available(state, state.active):
		var extra := " [extra use]" if doctrine in state.combat_doctrines.used.get(state.active, []) and (selected_detachment == "gladius" or doctrine in mastery_doctrines) else ""
		doctrine_choice.add_item(Combat.Doctrines.NAMES[doctrine] + extra, Combat.Doctrines.ORDER.find(doctrine) + 1)
	doctrine_choice.select(maxi(0, doctrine_choice.get_item_index(previous)))
	var waiting: bool = _local_player() != state.active or (mode == "host" and guest_id == 0)
	doctrine_choice.disabled = waiting
	doctrine_confirm.disabled = waiting
	doctrine_help.text = "Player %d: choose a doctrine or none, then Confirm." % state.active
	var extra_status := "spent" if state.combat_doctrines.extra_used.get(state.active, false) else "available"
	var extra_summary := ""
	if selected_detachment == "gladius": extra_summary = "Gladius Codex Discipline has one shared extra doctrine use; it is %s." % extra_status
	elif selected_detachment == "spearpoint-task-force": extra_summary = "Spearpoint can select Assault or Tactical Doctrine one extra time; that use is %s." % extra_status
	elif not mastery_doctrines.is_empty(): extra_summary = "%s Brethren can select %s Doctrine one extra time; that use is %s." % [selected_detachment.trim_suffix("-brethren").capitalize(), str(mastery_doctrines[0]).capitalize(), extra_status]
	doctrine_help.tooltip_text = "Each doctrine is normally available once per battle. %s No CP." % extra_summary

func _request_combat_doctrine() -> void:
	var index := doctrine_choice.get_selected_id()
	var doctrine: String = "none" if index == 0 else Combat.Doctrines.ORDER[index - 1]
	var decision := Combat.Doctrines.pending_decision(state)
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == "combat-doctrine" and str(option.get("value", "")) == doctrine:
			option_id = str(option.get("id", ""))
			break
	var decision_id := str(decision.get("decision_id", ""))
	if mode == "client": request_combat_doctrine.rpc_id(1, doctrine, decision_id, option_id, state.revision)
	else: _apply_combat_doctrine(_local_player(), doctrine, decision_id, option_id, state.revision)

@rpc("any_peer", "call_remote", "reliable")
func request_combat_doctrine(doctrine: String, decision_id: String, option_id: String, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_combat_doctrine(2, doctrine, decision_id, option_id, revision)

func _apply_combat_doctrine(player: int, doctrine: String, decision_id: String, option_id: String, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_DOCTRINE, "doctrine": doctrine, "decision_id": decision_id, "option_id": option_id, "revision": revision})
	if not result.error.is_empty(): _feedback(player, result.error); return
	_broadcast()
	_feedback(player, result.message)

func _refresh_awakened() -> void:
	var pending: bool = combat_enabled and Combat.Mission.actor(state) < 0 and Combat.Awakened.needs_setup(state)
	for control in [awakened_help, awakened_target, awakened_confirm]: control.visible = pending
	if not pending: return
	end_button.disabled = true
	var previous := awakened_target.get_selected_id()
	awakened_target.clear()
	awakened_target.add_item("Leave Overlord standalone (no Command Protocols bonus)", 0)
	for squad: int in Combat.Awakened.candidates(state): awakened_target.add_item("Lead " + state.squads[squad].name, squad)
	awakened_target.select(maxi(0, awakened_target.get_item_index(previous)))
	var owner := Combat.Awakened.setup_actor(state)
	var waiting: bool = _local_player() != owner or (mode == "host" and guest_id == 0)
	awakened_target.disabled = waiting
	awakened_confirm.disabled = waiting
	awakened_help.text = "Player %d: attach %s or leave it standalone, then Confirm." % [owner, state.squads[state.awakened_dynasty.pending[0]].name]
	awakened_help.tooltip_text = "A led unit receives +1 to hit while its Necron Character and bodyguards survive."
	if Combat.Reanimation.enabled(state): awakened_help.tooltip_text += " Reanimation heals survivors first, then returns destroyed troops. Destroyed Characters do not return."

func _request_awakened_attachment() -> void:
	var target := awakened_target.get_selected_id()
	if target == 0: target = -1
	var identity := _awakened_attachment_identity(target)
	if mode == "client": request_awakened_attachment.rpc_id(1, target, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))
	else: _apply_awakened_attachment(_local_player(), target, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))

func _awakened_attachment_identity(bodyguard: int) -> Dictionary:
	var decision := PendingDecisions.current(state, ["awakened-attachment"])
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == "awakened-attachment" and int(option.get("target", -2)) == bodyguard:
			return {"decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", ""))}
	return {"decision_id": "", "option_id": ""}

@rpc("any_peer", "call_remote", "reliable")
func request_awakened_attachment(bodyguard: int, revision: int, decision_id: String = "", option_id: String = "") -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_awakened_attachment(2, bodyguard, revision, decision_id, option_id)

func _apply_awakened_attachment(player: int, bodyguard: int, revision: int, decision_id: String = "", option_id: String = "") -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_AWAKENED_ATTACHMENT, "bodyguard": bodyguard, "revision": revision, "decision_id": decision_id, "option_id": option_id})
	_present_match_command(player, result)

func _open_unit_choice_help() -> void:
	_open_help_screen()
	var scroll := unit_choice_reference.get_parent().get_parent() as ScrollContainer
	if scroll != null: scroll.call_deferred("ensure_control_visible", unit_choice_reference)

func _refresh_unit_actions() -> void:
	doctrine_action_panel.visible = false
	unit_decline_choice = {}
	unit_decline_button.visible = false
	var selecting_saved_army: bool = combat_enabled and saved_army_mode and state.get("phase", "") == "army_selection"
	if selecting_saved_army:
		for control in [setup_preparation_status, setup_required_status, setup_feedback_status, setup_finish_button, setup_decisions_heading, setup_equipment_toggle, setup_equipment_list, unit_details_button, unit_choice_reference, unit_action_help, unit_action_picker, unit_action_x, unit_action_z, unit_action_button]: control.visible = false
		_setup_clear_equipment_rows()
		_refresh_network_army_selection()
		return
	_refresh_network_army_selection()
	var choices: Array = Combat.unit_choices(state, _local_player()) if combat_enabled else []
	_refresh_unit_decline_choice(choices)
	var mission_preparation := combat_enabled and Combat.Mission.actor(state) > 0
	var preparing := combat_enabled and not mission_preparation and Combat.UnitActions.setup_actor(state) > 0
	var battle_start_setup := combat_enabled and not mission_preparation and Combat.UnitActions.battle_actor(state) > 0
	if battle_start_setup:
		choices.sort_custom(func(a: Dictionary, b: Dictionary):
			var priority := {"homer": 0, "invictor-mark": 0, "battle-done": 1}
			var a_priority: int = int(priority.get(str(a.get("action", "")), 0))
			var b_priority: int = int(priority.get(str(b.get("action", "")), 0))
			return a_priority < b_priority if a_priority != b_priority else str(a.get("label", "")) < str(b.get("label", ""))
		)
	setup_preparation_status.visible = preparing
	setup_required_status.visible = preparing
	setup_feedback_status.visible = preparing and not setup_feedback_status.text.is_empty()
	setup_finish_button.visible = preparing
	setup_decisions_heading.visible = preparing
	setup_equipment_toggle.visible = preparing
	setup_equipment_list.visible = preparing and setup_equipment_open
	unit_details_button.visible = not choices.is_empty()
	unit_choice_reference.visible = not choices.is_empty()
	unit_choice_reference.text = ""
	unit_action_help.tooltip_text = ""
	for control in [unit_action_help, unit_action_picker, unit_action_x, unit_action_z, unit_action_button]: control.visible = not choices.is_empty()
	if choices.is_empty():
		unit_action_picker.clear()
		_setup_clear_equipment_rows()
		return
	var previous: int = unit_action_picker.selected
	var previous_choice: Variant = unit_action_picker.get_item_metadata(previous) if previous >= 0 and previous < unit_action_picker.item_count else null
	unit_action_picker.clear()
	setup_decision_choices.clear()
	var equipment_choices: Array[Dictionary] = []
	for choice: Dictionary in choices:
		if preparing and _is_setup_equipment_choice(choice): equipment_choices.append(choice)
		elif not preparing or str(choice.get("action", "")) != "setup-done": setup_decision_choices.append(choice)
	# A dedicated neutral action must not also occupy a picker row.
	var picker_choices: Array = setup_decision_choices if preparing else choices.filter(func(choice: Dictionary) -> bool: return choice != unit_decline_choice)
	if preparing:
		setup_decision_choices.sort_custom(func(a: Dictionary, b: Dictionary):
			var priority := {"warlord": 0, "attach": 1, "reserve": 2, "transport-embark-start": 3}
			var a_priority: int = int(priority.get(str(a.get("action", "")), 4))
			var b_priority: int = int(priority.get(str(b.get("action", "")), 4))
			return a_priority < b_priority if a_priority != b_priority else str(a.get("label", "")) < str(b.get("label", ""))
		)
		picker_choices = setup_decision_choices
	for choice: Dictionary in picker_choices:
		unit_action_picker.add_item(choice.label)
		unit_action_picker.set_item_metadata(unit_action_picker.item_count - 1, choice)
		unit_action_picker.set_item_tooltip(unit_action_picker.item_count - 1, choice.label)
	var selected_index := 0
	for index in range(picker_choices.size()):
		if picker_choices[index] == previous_choice:
			selected_index = index
			break
	if picker_choices.is_empty():
		unit_action_picker.select(-1)
	else:
		unit_action_picker.select(selected_index)
	if preparing:
		_build_setup_equipment_rows(equipment_choices)
		var owner := Combat.UnitActions.setup_actor(state)
		setup_preparation_status.text = "PLAYER %d · ARMY PREPARATION\nMake declarations first. Default equipment is ready; customization is optional." % owner
		setup_required_status.text = _setup_required_summary(owner)
		var finish_choice := _setup_finish_choice(owner)
		var finish_probe := Combat.UnitActions.apply(state.duplicate(true), owner, finish_choice, Vector2.ZERO, func() -> int: return 1) if not finish_choice.is_empty() else {"error": "Army preparation is not available right now."}
		var finish_error := str(finish_probe.get("error", ""))
		var waiting_for_guest := mode == "host" and guest_id == 0
		setup_finish_button.disabled = not finish_error.is_empty() or waiting_for_guest
		setup_finish_button.text = "Waiting for Player 2" if waiting_for_guest else "Finish Player %d's army" % owner
		setup_finish_button.tooltip_text = finish_error if not finish_error.is_empty() else ("Player 2 must join before the host can continue." if waiting_for_guest else "")
		unit_action_help.text = "Choose an army decision, then confirm it. Opening or browsing equipment never changes the army."
		unit_action_picker.visible = not picker_choices.is_empty()
		unit_action_button.visible = not picker_choices.is_empty()
		unit_action_x.visible = false
		unit_action_z.visible = false
		unit_details_button.visible = false
		unit_action_button.text = "Confirm selected choice"
		unit_action_button.disabled = mode == "host" and guest_id == 0
		setup_equipment_toggle.text = "Customize equipment  ▾" if setup_equipment_open else "Customize equipment  ▸"
		return
	_setup_clear_equipment_rows()
	if picker_choices.is_empty():
		unit_action_picker.visible = false
		unit_action_button.visible = false
		unit_action_x.visible = false
		unit_action_z.visible = false
		unit_details_button.visible = false
		unit_choice_reference.visible = false
		unit_action_help.text = "Player %d decides · continue without this ability." % _local_player()
		return
	unit_action_help.text = "Current e11 unit abilities and enabled detachment stratagems. Choose an action; X/Z apply to placement choices. Pending phase/setup decisions must be completed or declined."
	if battle_start_setup:
		unit_action_help.text = "Optional: set a Teleport Homer for each Terminator unit by selecting its choice, setting X/Z and confirming. Choose Finish start-of-battle declarations when done, or to skip this option."
	if unit_action_picker.get_selected_metadata().get("action", "") == "helix-bearer":
		unit_action_help.text = "Helix Gauntlet: optional, one Infiltrator bearer per unit. Choosing a different bearer transfers it; remove to leave it unequipped. A surviving bearer heals its unit D3 in your Command phase."
	elif unit_action_picker.get_selected_metadata().get("action", "") == "phobos-lieutenant-gun":
		unit_action_help.text = "Phobos Lieutenant: the Bolt Carbine replaces the Special-issue Bolt Pistol. Monomolecular Combat Blades remain. Swap back before preparation finishes."
	elif unit_action_picker.get_selected_metadata().get("action", "") == "omni-scramblers":
		unit_action_help.text = "Omni-scramblers: select a visible enemy within 18 inches. Its detection range increases by 3 until this phase ends. Once per phase for this unit, 0 CP; repeated marks do not stack."
	elif unit_action_picker.get_selected_metadata().get("action", "") == "priority-target":
		unit_action_help.text = "Priority Target Identified: once per battle, choose one visible terrain feature in your Command phase. Enemy models within it gain +3 inches detection range until the end of this turn."
	if unit_action_picker.get_selected_metadata().get("action", "") == "gravis-captain-loadout":
		unit_action_help.text = "Gravis loadouts replace BOTH the rifle and power weapon. Choose the gauntlet plus one relic with Extra Attacks, or restore the rifle and power weapon. Swaps are reversible before preparation finishes."
	if unit_action_picker.get_selected_metadata().get("action", "") in ["terminator-captain-gun", "terminator-captain-blade"]:
		unit_action_help.text = "Terminator Captain: swap ranged and melee equipment independently. Combi-weapon has three alternative firing profiles; choose one when declaring attacks. Changes are reversible before finishing preparation."
	if unit_action_picker.get_selected_metadata().get("action", "") == "terminator-chaplain-shield":
		unit_action_help.text = "Relic Shield replaces the Storm Bolter and gives its bearer +1 W (6 total). Crozius remains. Swap back before finishing preparation to restore the bolter and 5 W."
	if unit_action_picker.get_selected_metadata().get("action", "") == "ancient-loadout":
		unit_action_help.text = "Ancient equipment: Power Weapon replaces only the Bolt Rifle. Bolt Pistol and Ceramite Fists remain. Choose again to restore the rifle. Finish Support and Warlord declarations before deployment."
	if Combat.UnitActions.pending(state).get("kind", "") == "start":
		for option: Dictionary in choices:
			if option.action == "spiritual-leader":
				unit_action_help.text = "Start of phase: choose an available ability or decline. Spiritual Leader removes Battle-shock from one friendly Astartes unit within 6 inches of the Chaplain. Once per battle round, 0 CP; visibility is not required."
				break
	if Combat.UnitActions.pending(state).get("kind", "") == Combat.DetachmentStratagems.UNSTOPPABLE_WINDOW:
		var movement_stratagem_window: Dictionary = Combat.UnitActions.pending(state)
		if movement_stratagem_window.get("action", "") == "movement" and movement_stratagem_window.get("move_type", "") in ["advance", "ordered_retreat", "desperate_escape"]:
			unit_action_help.text = "Before the selected Advance or Fall Back continues, choose a listed stratagem or decline. Mobile Lethality gives this unit ranged Assault and lets it shoot after Falling Back this turn."
		else:
			unit_action_help.text = "Before this selected move or charge continues, choose a listed stratagem or decline. Flawless Riders and Unstoppable Advance give the unit Mobile for this phase."
	if Combat.UnitActions.pending(state).get("kind", "") == "tactics":
		var tactical_move_source := "Hunter's Instincts" if Combat.UnitActions.pending(state).get("source", "") == Combat.DetachmentStratagems.HUNTERS_INSTINCTS else "Responsive Tactics"
		var tactical_move_record: Dictionary = state.get("detachment_stratagems", {}).get("tactics", {}).get(Combat.UnitActions.pending(state).get("squad", -1), {})
		unit_action_help.text = "%s: preview a Normal Move of up to %d inches for every model, keep the unit unengaged, then confirm." % [tactical_move_source, int(tactical_move_record.get("inches", 0))]
	var optics := Combat.UnitAbilities.Detection.selection(state)
	if not optics.is_empty():
		var effect: String = "Ignores Cover" if optics.mode == "cover" else "+6 detection on " + state.squads[optics.target].name
		unit_action_help.text = "%s active for the selected Eliminators. Shoot this unit now; other units wait." % effect
		unit_action_help.tooltip_text = "You may revise or cancel this preview before committing dice. The effect ends when this shooting finishes."
	if Combat.UnitActions.pending(state).get("kind", "") == "bladeguard":
		unit_action_help.text = "Bladeguard: +1 to your unit’s melee hit rolls OR -1 to enemy hit rolls against it, until Fight ends. Once per turn, 0 CP. Declining keeps the use. Declared attacks wait; no attack dice rolled yet."
	elif Combat.UnitActions.pending(state).get("kind", "") == "wound": unit_action_help.text = "Implacable Eradication: re-roll any wound dice for 0 CP, including successes, or keep the remaining rolls. Each die can only be re-rolled once. Saves wait until you finish."
	elif Combat.UnitActions.pending(state).get("kind", "") == "ingress": unit_action_help.text = "Ingress: select each model and place its preview using X/Z or right-click. Confirm only after the whole unit fits coherently, more than 8 inches from enemies. Cancel preserves reserves and resources."
	elif Combat.UnitActions.pending(state).get("kind", "") in ["evade-and-survive", "evade-placement"]:
		unit_action_help.text = "Evade and Survive: during the opponent's Movement phase, after an enemy ends a move within 8 inches, an unengaged Lieutenant can make one normal move of D3+3 inches. Preview and confirm; the move must end unengaged."
	elif Combat.UnitActions.pending(state).get("kind", "") in ["tactical-fluidity", "tactical-fluidity-placement"]:
		if Combat.UnitActions.pending(state).get("source", "") == "storm-swift-onslaught":
			unit_action_help.text = "Wrath of the First Khan: if Suboden Khan's unit was eligible to fight this phase, it can make a Normal Move while unengaged or a Fall Back move while engaged. Move each model up to its Movement characteristic. Preview every model and confirm a coherent move."
		else:
			unit_action_help.text = "Tactical Fluidity: once per battle round for this unit, after it shoots while unengaged, move normally up to D6 inches; or at the end of the opponent's Fight phase while engaged, Fall Back up to 6 inches. Preview every model and confirm a coherent move."
	if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty():
		var transport_window: Dictionary = state.unit_abilities.transport_window
		unit_action_help.text = "Disembark %s: place every model wholly within %s inches of the transport, without overlapping bases. Use X/Z and confirm each position; confirm the complete coherent unit when finished." % [state.squads[int(transport_window.passenger_squad)].name, "6" if transport_window.mode in ["combat", "emergency"] else "3"]

	if Combat.UnitActions.pending(state).get("kind", "") == "healing":
		var healing: Dictionary = Combat.UnitActions.pending(state)
		unit_action_help.text = "%s: %d wounds, %d left. Heal wounded survivors first; then place returned non-Characters with X/Z or right-click. Changes are previews until confirmed. Reset keeps the same roll." % [healing.get("ability_name", "Narthecium"), healing.total, healing.remaining]
	elif Combat.UnitActions.pending(state).get("kind", "") == "healing-order":
		unit_action_help.text = "Command: resolve available unit healing before finishing the phase. No CP cost."

	_update_unit_placement_controls()
	if Combat.Mission.actor(state) > 0: unit_action_help.text = "CA 2026-27: mission preparation. Roll-offs are resolved for both players; ties require another roll. Declare Battle Ready only if applicable to your army."
	var full_help := unit_action_help.text
	if not unit_action_help.tooltip_text.is_empty(): full_help += "\n" + unit_action_help.tooltip_text
	unit_choice_reference.text = "CURRENT CHOICE\n" + str(unit_action_picker.get_selected_metadata().label) + "\n\n" + full_help
	unit_action_help.tooltip_text = full_help
	var tactical: bool = str(Combat.UnitActions.pending(state).get("kind", "")) in ["healing", "healing-order", "ingress", "bladeguard", "wound", "evade-and-survive", "evade-placement", "tactical-fluidity", "tactical-fluidity-placement", Combat.DetachmentStratagems.UNSTOPPABLE_WINDOW] or not optics.is_empty() or not state.get("unit_abilities", {}).get("transport_window", {}).is_empty()
	if not tactical and not battle_start_setup: unit_action_help.text = "Choose an option, then Confirm choice."
	if guided_first_session and not preparing:
		# The picker may truncate a long unit/stratagem label, including its CP cost.
		# Repeat the live label in wrapping text before the player confirms it.
		unit_action_help.text = "Player %d decides\n%s" % [Combat.actor(state), str(unit_action_picker.get_selected_metadata().label)]
		if tactical: unit_action_help.text += "\n" + full_help
	unit_action_button.text = "Confirm mission choice" if Combat.Mission.actor(state) > 0 else "Confirm choice"
	unit_action_button.disabled = mode == "host" and guest_id == 0
	if state.get("phase", "") == "command" and not preparing and not battle_start_setup:
		var current_choice: Dictionary = unit_action_picker.get_selected_metadata()
		var grouped_choice: Dictionary = doctrine_action_panel.sync(state, picker_choices, current_choice, unit_action_button.disabled)
		if doctrine_action_panel.visible:
			for index in range(unit_action_picker.item_count):
				if unit_action_picker.get_item_metadata(index) == grouped_choice: unit_action_picker.select(index)
			unit_action_picker.visible = false
			if doctrine_action_panel.category(grouped_choice) != "other":
				unit_action_help.text = "Player %d · optional doctrine change" % _local_player()
				unit_action_button.text = doctrine_action_panel.confirmation_text
				unit_choice_reference.text = doctrine_action_panel.explanation.text
				unit_details_button.visible = false

func _refresh_unit_decline_choice(choices: Array) -> void:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var keep_actions := ["legion-keep", "damage-keep", "hit-finish", "machine-spirit-finish", "wound-finish"]
	if int(decision.get("priority_player_id", -1)) == _local_player():
		for choice: Dictionary in choices:
			var action := str(choice.get("action", ""))
			var can_decline: bool = decision.get("pass_allowed", false) and (action == "pass" or action.ends_with("-pass") or str(choice.get("value", "")) == "pass")
			if can_decline or action in keep_actions:
				unit_decline_choice = choice.duplicate(true)
				break
	unit_decline_button.visible = not unit_decline_choice.is_empty()
	unit_decline_button.text = "Keep results · 0 CP" if str(unit_decline_choice.get("action", "")) in keep_actions else "Continue without this ability · 0 CP"
	unit_decline_button.disabled = mode == "host" and guest_id == 0
	unit_decline_button.tooltip_text = str(unit_decline_choice.get("label", ""))

func _is_setup_equipment_choice(choice: Dictionary) -> bool:
	return str(choice.get("action", "")) in [
		"aggressor-loadout", "inceptor-loadout", "land-speeder-cannon", "intercessor-melee", "intercessor-rifle",
		"intercessor-grenade-launcher", "heavy-intercessor-bolter", "terminator-melee", "terminator-special-weapon",
		"terminator-assault-loadout", "outrider-melee", "outrider-plasma-pistol", "eliminator-troopers", "eliminator-sergeant",
		"ancient-loadout", "jump-pack-captain-loadout", "gravis-captain-loadout", "terminator-captain-gun", "terminator-captain-blade",
		"captain-ranged-loadout", "captain-melee-loadout", "lieutenant-ranged-loadout", "lieutenant-melee-loadout",
		"lieutenant-storm-shield", "terminator-chaplain-shield", "captain-loadout", "lieutenant-loadout",
		"impulsor-loadout", "transport-weapon-loadout", "eliminator-loadout", "phobos-lieutenant-gun", "relic-shield",
		"apothecary-loadout", "redemptor-loadout", "dreadnought-loadout", "heavy-weapon-loadout"
	]

func _setup_required_summary(owner: int) -> String:
	var finish_choice := _setup_finish_choice(owner)
	if not finish_choice.is_empty():
		var probe := Combat.UnitActions.apply(state.duplicate(true), owner, finish_choice, Vector2.ZERO, func() -> int: return 1)
		var validator_error := str(probe.get("error", ""))
		if not validator_error.is_empty(): return "Required before finishing: " + validator_error
	return "Required checks are clear. You may finish now or customize equipment first."

func _setup_finish_choice(owner: int) -> Dictionary:
	for choice: Dictionary in Combat.unit_choices(state, owner):
		if str(choice.get("action", "")) == "setup-done": return choice
	return {}

func _setup_clear_equipment_rows() -> void:
	if setup_equipment_list == null: return
	for child: Node in setup_equipment_list.get_children():
		setup_equipment_list.remove_child(child)
		child.queue_free()

func _build_setup_equipment_rows(choices: Array[Dictionary]) -> void:
	_setup_clear_equipment_rows()
	if not setup_equipment_open: return
	if choices.is_empty():
		var empty := Label.new()
		empty.text = "No optional equipment changes are available for this army."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		setup_equipment_list.add_child(empty)
		return
	var groups: Dictionary = {}
	var squad_ids: Array[int] = []
	for choice: Dictionary in choices:
		var squad_id := int(choice.get("target", -1))
		if not groups.has(squad_id):
			groups[squad_id] = {}
			squad_ids.append(squad_id)
		var key := "%s:%d" % [str(choice.get("action", "")), int(choice.get("model", -1))]
		if not groups[squad_id].has(key): groups[squad_id][key] = []
		groups[squad_id][key].append(choice)
	squad_ids.sort()
	for squad_id: int in squad_ids:
		var squad_name := str(state.squads.get(squad_id, {}).get("name", "Unit %d" % squad_id))
		var heading := Label.new()
		heading.text = squad_name
		heading.add_theme_color_override("font_color", Color("f2df83"))
		setup_equipment_list.add_child(heading)
		var slot_keys: Array = groups[squad_id].keys()
		slot_keys.sort()
		for key: String in slot_keys:
			var options: Array = groups[squad_id][key]
			if options.is_empty(): continue
			var first: Dictionary = options[0]
			var model_id := int(first.get("model", -1))
			var slot := _setup_equipment_slot(str(first.get("action", "")))
			var current := _setup_current_equipment(first)
			var caption := Label.new()
			caption.text = "%s · %s\nCurrent: %s" % [_setup_equipment_model_name(model_id), slot, current]
			caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			setup_equipment_list.add_child(caption)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for option: Dictionary in options:
				picker.add_item(str(option.get("label", "Alternative")))
				picker.set_item_metadata(picker.item_count - 1, option)
				picker.set_item_tooltip(picker.item_count - 1, str(option.get("label", "")))
			setup_equipment_list.add_child(picker)
			var confirm := Button.new()
			confirm.text = "Confirm change"
			confirm.pressed.connect(func(): _submit_setup_equipment(picker.get_selected_metadata()))
			setup_equipment_list.add_child(confirm)

func _setup_equipment_model_name(model_id: int) -> String:
	if model_id < 0: return "Unit option"
	var unit: Dictionary = state.units.get(model_id, {})
	var name := str(unit.get("name", ""))
	if not name.is_empty(): return name
	var squad_id := int(unit.get("squad", -1))
	var models: Array[int] = []
	for candidate: int in state.units:
		if int(state.units[candidate].get("squad", -1)) == squad_id: models.append(candidate)
	models.sort()
	return "Model %d" % (models.find(model_id) + 1)

func _setup_equipment_slot(action: String) -> String:
	if action in ["terminator-melee", "intercessor-melee", "outrider-melee", "captain-melee-loadout", "terminator-captain-blade", "lieutenant-melee-loadout"]: return "Melee weapon"
	if action in ["terminator-special-weapon", "intercessor-rifle", "intercessor-grenade-launcher", "heavy-intercessor-bolter", "terminator-captain-gun", "captain-ranged-loadout", "lieutenant-ranged-loadout", "transport-weapon-loadout"]: return "Ranged weapon"
	if action in ["terminator-assault-loadout", "terminator-chaplain-shield", "lieutenant-storm-shield", "relic-shield"]: return "Wargear"
	if action in ["eliminator-troopers", "eliminator-sergeant"]: return "Weapon loadout"
	if action in ["jump-pack-captain-loadout", "gravis-captain-loadout", "captain-loadout", "lieutenant-loadout", "apothecary-loadout"]: return "Model loadout"
	return "Equipment"

func _setup_current_equipment(choice: Dictionary) -> String:
	var model_id := int(choice.get("model", -1))
	var action := str(choice.get("action", ""))
	var unit: Dictionary = state.units.get(model_id, {})
	match action:
		"terminator-melee":
			return str(unit.get("terminator_melee_choice", "power-fist")).capitalize().replace("-", " ")
		"terminator-special-weapon":
			var weapon := str(unit.get("terminator_special_weapon", ""))
			return "Storm Bolter" if weapon.is_empty() else weapon.capitalize().replace("-", " ")
		"terminator-assault-loadout": return "Storm Shield + Thunder Hammer" if unit.get("terminator_assault_storm_shield", false) else "Twin Lightning Claws"
		"terminator-captain-gun": return "Storm Bolter" if unit.get("terminator_combi", false) else "Combi-weapon"
		"terminator-captain-blade": return "Relic Weapon" if unit.get("terminator_fist", false) else "Relic Fist"
		"terminator-chaplain-shield": return "Relic Shield" if unit.get("terminator_chaplain_shield", false) else "Storm Bolter"
		"aggressor-loadout": return "Flamestorm" if state.squads.get(int(choice.get("target", -1)), {}).get("boltstorm_loadout", false) else "Boltstorm / Fragstorm"
		"inceptor-loadout": return "Plasma Exterminators" if unit.get("inceptor_plasma_exterminators", false) else "Assault Bolters"
		"land-speeder-cannon": return "Onslaught Gatling Cannon" if unit.get("land_speeder_pyrecannon", false) else "Pyrecannon"
		"intercessor-melee": return str(unit.get("intercessor_melee_choice", "knives-and-fists")).capitalize().replace("-", " ")
		"intercessor-rifle": return str(unit.get("intercessor_rifle_choice", "bolt-rifle")).capitalize().replace("-", " ")
		"intercessor-grenade-launcher": return "Grenade Launcher" if unit.get("intercessor_grenade_launcher", false) else "No grenade launcher"
		"heavy-intercessor-bolter": return "Heavy Bolter" if unit.get("heavy_intercessor_heavy_bolter", false) else "Heavy Bolt Rifle"
		"outrider-plasma-pistol": return "Plasma Pistol" if unit.get("outrider_plasma_pistol", false) else "Heavy Bolt Pistol"
		"jump-pack-captain-loadout":
			var jump_options := {"default": "Heavy Bolt Pistol + Chainsword", "hand-flamer": "Hand Flamer + Chainsword", "plasma-pistol": "Plasma Pistol + Chainsword", "power-fist": "Heavy Bolt Pistol + Power Fist", "relic-weapon": "Heavy Bolt Pistol + Relic Weapon", "thunder-hammer-shield": "Thunder Hammer + Relic Shield", "chainsword-shield": "Chainsword + Relic Shield"}
			return str(jump_options.get(unit.get("jump_captain_loadout", "default"), "Datasheet loadout"))
		"gravis-captain-loadout":
			var gravis_options := {"rifle": "Heavy Bolt Rifle + Power Weapon", "blade": "Boltstorm Gauntlet + Relic Blade", "chainsword": "Boltstorm Gauntlet + Chainsword", "fist": "Boltstorm Gauntlet + Relic Fist"}
			return str(gravis_options.get(unit.get("gravis_loadout", "rifle"), "Datasheet loadout"))
		"captain-ranged-loadout":
			var captain_options := {"default": "Master-crafted Bolter + Heavy Bolt Pistol", "neo-volkite": "Neo-volkite Pistol", "plasma-pistol": "Plasma Pistol", "relic-shield": "Relic Shield + Heavy Bolt Pistol"}
			return str(captain_options.get(unit.get("captain_ranged_loadout", "default"), "Datasheet loadout"))
		"captain-melee-loadout": return "Power Fist" if unit.get("captain_power_fist", false) else "Master-crafted Power Weapon"
		"lieutenant-ranged-loadout":
			var lieutenant_options := {"default": "Bolt Pistol + Master-crafted Bolter", "heavy-bolt-pistol": "Heavy Bolt Pistol + Master-crafted Bolter", "power-weapon": "Bolt Pistol + Master-crafted Power Weapon", "heavy-pistol-power-weapon": "Heavy Bolt Pistol + Master-crafted Power Weapon", "plasma-pistol": "Bolt Pistol + Plasma Pistol", "heavy-pistol-plasma-pistol": "Heavy Bolt Pistol + Plasma Pistol", "power-fist": "Bolt Pistol + Power Fist", "heavy-pistol-power-fist": "Heavy Bolt Pistol + Power Fist", "neo-volkite": "Neo-volkite Pistol + Master-crafted Power Weapon"}
			return str(lieutenant_options.get(unit.get("lieutenant_weapon_package", "default"), "Datasheet loadout"))
		"lieutenant-melee-loadout": return str(unit.get("lieutenant_fists_replacement", "ceramite-fists")).capitalize().replace("-", " ")
		"lieutenant-storm-shield": return "Storm Shield" if unit.get("lieutenant_storm_shield", false) else "No Storm Shield"
		"ancient-loadout": return "Power Weapon" if unit.get("ancient_power", false) else "Bolt Rifle"
	return "Current datasheet loadout"

func _submit_setup_equipment(choice: Variant) -> void:
	if not choice is Dictionary or choice.is_empty():
		_feedback(_local_player(), "Select an equipment option before confirming.")
		return
	var submitted := _unit_choice_payload(choice)
	if mode == "client": request_unit_action.rpc_id(1, submitted, Vector2.ZERO, state.revision)
	else: _apply_unit_action(_local_player(), submitted, Vector2.ZERO, state.revision)

func _request_setup_finish() -> void:
	if not combat_enabled:
		_feedback(_local_player(), "Army preparation is unavailable outside a match.")
		return
	var choice := _setup_finish_choice(Combat.UnitActions.setup_actor(state))
	if choice.is_empty():
		_feedback(_local_player(), "Army preparation is not available right now. Refresh the current match state and try again.")
		return
	var submitted := _unit_choice_payload(choice)
	if mode == "client": request_unit_action.rpc_id(1, submitted, Vector2.ZERO, state.revision)
	else: _apply_unit_action(_local_player(), submitted, Vector2.ZERO, state.revision)

func _request_unit_action() -> void:
	if unit_action_picker.selected < 0: return
	var choice: Dictionary = unit_action_picker.get_selected_metadata()
	var submitted_choice := _unit_choice_payload(choice)
	var point := Vector2(unit_action_x.value, unit_action_z.value)
	if mode == "client": request_unit_action.rpc_id(1, submitted_choice, point, state.revision)
	else: _apply_unit_action(_local_player(), submitted_choice, point, state.revision)

func _request_decline_unit_choice() -> void:
	if unit_decline_choice.is_empty(): return
	var submitted := _unit_choice_payload(unit_decline_choice)
	if mode == "client": request_unit_action.rpc_id(1, submitted, Vector2.ZERO, state.revision)
	else: _apply_unit_action(_local_player(), submitted, Vector2.ZERO, state.revision)

func _unit_choice_payload(choice: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["mission-preparation", "unit-actions"])
	if decision.is_empty(): return choice
	var option_id := ""
	for option: Dictionary in decision.legal_options:
		if str(choice.get("action", "")) != str(option.get("action", "")): continue
		if int(choice.get("model", -1)) != int(option.get("model", -1)): continue
		if int(choice.get("target", -1)) != int(option.get("target", -1)): continue
		if str(choice.get("value", "")) != str(option.get("value", "")): continue
		option_id = str(option.get("id", ""))
		break
	return {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.decision_id), "option_id": option_id, "choice": choice.duplicate(true)}

@rpc("any_peer", "call_remote", "reliable")
func request_unit_action(choice: Dictionary, point: Vector2, revision: int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	if mode == "host" and match_session.accepts_guest_command(sender_id): _apply_unit_action(2, choice, point, revision)

func _apply_unit_action(player: int, choice: Dictionary, point: Vector2, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": choice, "point": point, "revision": revision}, _d6)
	if not result.error.is_empty(): _feedback(player, result.error); return
	_broadcast()
	_feedback(player, result.message)

func _sync_ability_tokens() -> void:
	var tokens: Dictionary = state.get("unit_abilities", {}).get("homers", {}) if combat_enabled else {}
	for squad: int in ability_token_nodes.keys():
		if not tokens.has(squad):
			ability_token_nodes[squad].queue_free()
			ability_token_nodes.erase(squad)
	for squad: int in tokens:
		if not ability_token_nodes.has(squad):
			var marker := Label3D.new()
			marker.text = "Teleport Homer\n" + state.squads[squad].name
			marker.font_size = 40
			marker.pixel_size = 0.025
			marker.no_depth_test = true
			marker.outline_size = 6
			marker.modulate = Color("a88fea")
			marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			var token := MeshInstance3D.new()
			var shape := CylinderMesh.new()
			shape.top_radius = 0.45
			shape.bottom_radius = 0.45
			shape.height = 0.06
			token.mesh = shape
			var paint := StandardMaterial3D.new()
			paint.albedo_color = Color("a88fea")
			paint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			token.material_override = paint
			token.position.y = -0.25
			marker.add_child(token)
			add_child(marker)
			ability_token_nodes[squad] = marker
		ability_token_nodes[squad].position = Vector3(tokens[squad].x, 0.3, tokens[squad].y)

func _update_unit_placement_controls() -> void:
	if unit_action_x == null or unit_action_z == null: return
	var placement := false
	var selected_action := ""
	if unit_action_picker.selected >= 0:
		var selected_option: Variant = unit_action_picker.get_selected_metadata()
		if selected_option is Dictionary:
			selected_action = str(selected_option.get("action", ""))
			placement = selected_action in ["homer", "ingress-place", "scout-place", "heal-revive", "heal-place", "evade-place", "fluidity-place"]
	unit_action_x.visible = placement
	unit_action_z.visible = placement
	var homer_position := selected_action == "homer"
	unit_action_x.prefix = "Homer X: " if homer_position else "Ability X: "
	unit_action_z.prefix = "Homer Z: " if homer_position else "Ability Z: "
	unit_action_x.tooltip_text = "Set the Teleport Homer position across the battlefield." if homer_position else "Set the X coordinate for this placement choice."
	unit_action_z.tooltip_text = "Set the Teleport Homer position along the battlefield." if homer_position else "Set the Z coordinate for this placement choice."

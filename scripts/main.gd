extends Node3D

const DicePipFace = preload("res://scripts/ui/dice_pip_face.gd")
const CombatSymbol = preload("res://scripts/ui/combat_symbol.gd")

const Rules = preload("res://scripts/rules.gd")
const MatchResult = preload("res://scripts/match_result.gd")
const SavedResultsBrowser = preload("res://scripts/ui/saved_results_browser.gd")
const SavedMatchesBrowser = preload("res://scripts/ui/saved_matches_browser.gd")
const LocalPlayerHandoff = preload("res://scripts/ui/local_player_handoff.gd")
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
const WeaponKeywordHelp = preload("res://scripts/ui/weapon_keyword_help.gd")
const AllocationPractice = preload("res://scripts/edition_11/allocation_practice.gd")
const TacticalGuides = preload("res://scripts/tactical_guides.gd")
const ModelImports = preload("res://scripts/model_import_panel.gd")
const TestBattlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const PreparedTraining = preload("res://scripts/edition_11/prepared_training.gd")
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const ArmyBuilder = preload("res://scripts/army_builder_panel.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const ArmyList = preload("res://scripts/ui/army_roster.gd")
const MatchSave = preload("res://scripts/match_save.gd")
const MatchJournal = preload("res://scripts/match_journal.gd")
const MatchHistoryPanel = preload("res://scripts/match_history_panel.gd")
const SAVE_SLOTS_FULL_NOTICE := "All five local save slots are occupied. This match is not resumable until you save it to an empty slot or confirm replacing a save."
const INPUT_INSPECT_DATASHEET := "inspect_selected_datasheet"
const INPUT_FOCUS_SELECTED_UNIT := "focus_selected_unit"
const INPUT_CAMERA_PAN_LEFT := "camera_pan_left"
const INPUT_CAMERA_PAN_RIGHT := "camera_pan_right"
const INPUT_CAMERA_PAN_UP := "camera_pan_up"
const INPUT_CAMERA_PAN_DOWN := "camera_pan_down"
const REBINDABLE_ACTIONS: Array[String] = [
	INPUT_INSPECT_DATASHEET,
	INPUT_FOCUS_SELECTED_UNIT,
	INPUT_CAMERA_PAN_UP,
	INPUT_CAMERA_PAN_DOWN,
	INPUT_CAMERA_PAN_LEFT,
	INPUT_CAMERA_PAN_RIGHT,
]
const DEFAULT_CONTROL_BINDINGS := {
	INPUT_INSPECT_DATASHEET: KEY_I,
	INPUT_FOCUS_SELECTED_UNIT: KEY_F,
	INPUT_CAMERA_PAN_UP: KEY_W,
	INPUT_CAMERA_PAN_DOWN: KEY_S,
	INPUT_CAMERA_PAN_LEFT: KEY_A,
	INPUT_CAMERA_PAN_RIGHT: KEY_D,
}
const CONTROL_BINDING_LABELS := {
	INPUT_INSPECT_DATASHEET: "Inspect selected datasheet",
	INPUT_FOCUS_SELECTED_UNIT: "Focus selected unit",
	INPUT_CAMERA_PAN_UP: "Pan camera up",
	INPUT_CAMERA_PAN_DOWN: "Pan camera down",
	INPUT_CAMERA_PAN_LEFT: "Pan camera left",
	INPUT_CAMERA_PAN_RIGHT: "Pan camera right",
}
const MainMenu = preload("res://scripts/ui/main_menu.gd")
const CombatHud = preload("res://scripts/ui/combat_hud.gd")
const SessionTransport = preload("res://scripts/network/session_transport.gd")
const MatchSession = preload("res://scripts/network/match_session.gd")
var journal = MatchJournal.new()
var match_save_path := MatchSave.PATH
var match_journal_directory := MatchJournal.DIRECTORY
var active_save_slot := 1
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
var marine_chapters: Dictionary = {1: "", 2: ""}
var ability_token_nodes: Dictionary = {}
var checked_rosters := false
var checked_rosters_choice: CheckBox
var official_mission := false
var official_mission_choice: CheckBox
var official_primary_choice: OptionButton
var official_primary_choice_p2: OptionButton
var official_primary_heading: Label
var official_primary_heading_p2: Label
var official_primary_help: Label
var official_primary_help_p2: Label
var official_primary_missions: Dictionary = {1: "battlefield-dominance", 2: "battlefield-dominance"}
var official_secondary_choice: OptionButton
var official_secondary_heading: Label
var official_secondary_help: Label
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
var marine_chapter_choice_p1: OptionButton
var marine_chapter_choice_p2: OptionButton
var vowed_help: Label
var vowed_objective: OptionButton
var vowed_confirm: Button
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
var reaction_use_row: HBoxContainer
var reaction_use_icon
var reaction_sudden_row: HBoxContainer
var reaction_sudden_icon
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
var allocation_markers: Dictionary = {}
var board_presentation_state: Dictionary = {}
var board_feedback_effects: Dictionary = {}
var selected := -1
var mode := "local"
var awaiting_initial_authoritative_snapshot := false
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
var _ui_refresh_depth := 0
var _ui_projection_state: Dictionary = {}
var _ui_projection_revision := -1
var _ui_actor := 0
var _ui_choices: Dictionary = {}
var _ui_decisions: Dictionary = {}
var _ui_gate_errors: Dictionary = {}
var _selection_refresh := false
var selection_panel: PanelContainer
var selection_home: Node
var selection_home_index := 0
var army_panel: PanelContainer
var army_panel_open := true
var army_models_button: Button
var army_card_host: VBoxContainer
var army_roster
var datasheet_button: Button
var datasheet_details: ScrollContainer
var datasheet_view: VBoxContainer
var datasheet_presented_model_id := -1
var selection_stats: GridContainer
var selection_health: ProgressBar
var selection_stats_key := ""
const UnitDatasheet = preload("res://scripts/ui/unit_datasheet.gd")
const LocalAbilityReference = preload("res://scripts/ui/local_ability_reference.gd")
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
var tactical_overlay_close_button: Button
var tactical_overlay_content: Control
var tactical_overlay_parent: Node
var tactical_overlay_index := -1
var tactical_overlay_return_focus: Control
var title_guide_scroll: ScrollContainer
var mission_overview_scroll: ScrollContainer
var mission_overview_text: RichTextLabel
var saved_results_browser
var saved_matches_browser
var local_player_handoff: Control
var local_handoff_last_owner := 0
var history_scroll: ScrollContainer
var help_scroll: ScrollContainer
var workshop_scroll: ScrollContainer
var tools_scroll: ScrollContainer
var settings_panel: VBoxContainer
var settings_scroll: ScrollContainer
var settings_content: VBoxContainer
var display_mode_picker: OptionButton
var resolution_picker: OptionButton
var ui_scale_picker: OptionButton
var settings_toggles: Dictionary = {}
var settings_binding_buttons: Dictionary = {}
var control_draft: Dictionary = {}
var pending_binding_action := ""
var control_settings_warning := ""
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
var framed_side_key := ""
var side_anchor_key := ""
var side_anchor_root: Node3D
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
var placement_reason_row: HBoxContainer
var placement_reason_icon
var placement_details_toggle: Button
var placement_details_label: Label
var placement_detail_entries: Array[String] = []
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
var dice_visual_omitted := 0
var health_overlay_toggle: CheckButton
var board_feedback_toggle: CheckButton
var charge_button: Button
var take_to_skies_charge_choice: CheckBox
var take_to_skies_charge_draft_squad := -1
var finish_move_button: Button
var cancel_move_button: Button
var coherency_button: Button
var movement_choice: OptionButton
var movement_elevation_choice: OptionButton
var movement_elevation_model := -1
var movement_choices
var sudden_onslaught_choice: CheckBox
var take_to_skies_choice: CheckBox
var movement_reference: Label
var action_unit_picker: OptionButton
var contact_flow
var contact_reference: Label
var charge_targets: VBoxContainer
var charge_target_notes: Label
var charge_target_buttons: Dictionary = {}
var presented_hazard_key := ""
var begin_move_button: Button
var escape_wound_button: Button
var abandon_move_button: Button
var begin_contact_button: Button
var tactical_focus_button: Button
var consolidation_objective: OptionButton
var contact_enemy: OptionButton
var contact_elevation_choice: OptionButton
var contact_elevation_model := -1
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
var command_panel_title: Label
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
	_ensure_tactical_input_actions()
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

func _ensure_tactical_input_actions() -> void:
	for action: String in REBINDABLE_ACTIONS:
		var action_name := StringName(action)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		var has_keyboard_binding := false
		for input_event: InputEvent in InputMap.action_get_events(action_name):
			if input_event is InputEventKey:
				has_keyboard_binding = true
				break
		if has_keyboard_binding:
			continue
		var keycode := int(DEFAULT_CONTROL_BINDINGS[action])
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		key_event.keycode = keycode
		InputMap.action_add_event(action_name, key_event)

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
	side_anchor_root = Node3D.new()
	side_anchor_root.name = "SideAnchors"
	add_child(side_anchor_root)
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
	_clear_board_feedback()
	for piece: MeshInstance3D in pieces.values(): piece.queue_free()
	pieces.clear()
	health_tags.clear()
	allocation_markers.clear()
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
		var marker := MeshInstance3D.new()
		marker.name = "EligibleRecipientMarker"
		var marker_mesh := CylinderMesh.new()
		marker_mesh.top_radius = float(state.units[id].radius) + 0.12
		marker_mesh.bottom_radius = float(state.units[id].radius) + 0.12
		marker_mesh.height = 0.12
		marker.mesh = marker_mesh
		var marker_material := _material(Color("78e1ac"))
		marker_material.emission_enabled = true
		marker_material.emission = Color("78e1ac")
		marker_material.emission_energy_multiplier = 0.45
		marker.material_override = marker_material
		marker.visible = false
		var eligible_cue := Label3D.new()
		eligible_cue.text = "Eligible"
		eligible_cue.font_size = 28
		eligible_cue.pixel_size = 0.01
		eligible_cue.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		eligible_cue.position = Vector3(0, 0.28, 0)
		eligible_cue.modulate = Color("78e1ac")
		eligible_cue.outline_size = 8
		eligible_cue.outline_modulate = Color("10161b")
		marker.add_child(eligible_cue)
		piece.add_child(marker)
		allocation_markers[id] = marker
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
	_remember_player_side()

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
	var ordinal := Label3D.new()
	ordinal.name = "RosterOrdinal"
	ordinal.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ordinal.no_depth_test = true
	ordinal.pixel_size = 0.01
	ordinal.font_size = 48
	ordinal.outline_size = 8
	ordinal.outline_modulate = Color("10161b")
	ordinal.modulate = Color("f2df83")
	ordinal.position = Vector3(0, 1.95, 0)
	ordinal.visible = false
	piece.add_child(ordinal)
	var shocked := Label3D.new()
	shocked.name = "ShockedCue"
	shocked.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shocked.no_depth_test = true
	shocked.pixel_size = 0.01
	shocked.font_size = 42
	shocked.outline_size = 8
	shocked.outline_modulate = Color("10161b")
	shocked.modulate = Color("e3ad52")
	shocked.position = Vector3(0, 2.28, 0)
	shocked.text = "Shocked"
	shocked.visible = false
	piece.add_child(shocked)
	health_tags[model_id] = {"root": health_root, "back": back, "fill": fill, "label": label, "ordinal": ordinal, "shocked": shocked}

func _show_board_feedback(model_id: int, message: String, tint: Color, hold: float = 0.0) -> void:
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
	var effect_id := label.get_instance_id()
	var tween := create_tween()
	board_feedback_effects[effect_id] = {"label": label, "tween": tween}
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if hold > 0.0: tween.tween_interval(hold)
	tween.tween_property(label, "position:y", label.position.y + 0.65, 0.72)
	var faded := tint
	faded.a = 0.0
	tween.parallel().tween_property(label, "modulate", faded, 0.72)
	tween.tween_callback(func():
		board_feedback_effects.erase(effect_id)
		if is_instance_valid(label): label.queue_free()
	)

func _clear_board_feedback() -> void:
	for record: Dictionary in board_feedback_effects.values():
		var tween: Tween = record.get("tween")
		if tween != null and tween.is_running(): tween.kill()
		var label: Label3D = record.get("label")
		if is_instance_valid(label): label.queue_free()
	board_feedback_effects.clear()

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
	combat_hud.side_requested.connect(_look_from_player_side)
	combat_hud.army_requested.connect(_show_army_panel)
	combat_hud.help_requested.connect(_open_help_screen)
	combat_hud.history_requested.connect(_open_history_screen)
	combat_hud.mission_requested.connect(_open_mission_overview)
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
	scope_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(scope_label)
	var guided_intro := Label.new()
	guided_intro.text = "Gladius tactical training • Captain, Intercessors and Hellblasters vs Chaplain, Assault Intercessors and Bladeguard. Local free play with tips; asymmetric forces, partial support. Uses the prepared local catalog; no downloads."
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
	official_mission_choice.tooltip_text = "11th-edition mission with one supported primary per player, Hammer and Anvil, the selected Event Companion terrain and a fixed secondary pair shared by both players. Eight current primary cards are implemented; current abilities are required, and reference points do not certify army legality."
	advanced.add_child(official_mission_choice)
	official_mission_choice.toggled.connect(func(active: bool):
		if active: unit_abilities_choice.button_pressed = true
		_refresh_official_layout_controls()
		_review_saved_armies())
	official_primary_heading = Label.new()
	official_primary_heading.text = "11e Primary Mission · Player 1"
	official_primary_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_heading)
	official_primary_choice = OptionButton.new()
	for primary_id: String in Combat.Mission.PRIMARY_MISSIONS:
		official_primary_choice.add_item(str(Combat.Mission.PRIMARY_MISSIONS[primary_id].name))
		official_primary_choice.set_item_metadata(official_primary_choice.item_count - 1, primary_id)
	official_primary_choice.item_selected.connect(func(_index: int):
		_refresh_primary_mission_help(1)
		_refresh_official_layout_controls())
	advanced.add_child(official_primary_choice)
	official_primary_help = Label.new()
	official_primary_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_help)
	official_primary_heading_p2 = Label.new()
	official_primary_heading_p2.text = "11e Primary Mission · Player 2"
	official_primary_heading_p2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_heading_p2)
	official_primary_choice_p2 = OptionButton.new()
	for primary_id: String in Combat.Mission.PRIMARY_MISSIONS:
		official_primary_choice_p2.add_item(str(Combat.Mission.PRIMARY_MISSIONS[primary_id].name))
		official_primary_choice_p2.set_item_metadata(official_primary_choice_p2.item_count - 1, primary_id)
	official_primary_choice_p2.item_selected.connect(func(_index: int):
		_refresh_primary_mission_help(2)
		_refresh_official_layout_controls())
	advanced.add_child(official_primary_choice_p2)
	official_primary_help_p2 = Label.new()
	official_primary_help_p2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_primary_help_p2)
	_refresh_primary_mission_help(1)
	_refresh_primary_mission_help(2)
	official_secondary_heading = Label.new()
	official_secondary_heading.text = "11e Fixed Secondary Pair (same pair for both players)"
	official_secondary_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_secondary_heading)
	official_secondary_choice = OptionButton.new()
	for pair_id: String in Combat.Mission.SECONDARY_PAIRS:
		official_secondary_choice.add_item(str(Combat.Mission.SECONDARY_PAIRS[pair_id].label))
		official_secondary_choice.set_item_metadata(official_secondary_choice.item_count - 1, pair_id)
	official_secondary_choice.item_selected.connect(func(_index: int): _refresh_secondary_mission_help())
	advanced.add_child(official_secondary_choice)
	official_secondary_help = Label.new()
	official_secondary_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_secondary_help)
	_select_official_primary_missions({1: "battlefield-dominance", 2: "battlefield-dominance"})
	_select_official_secondary_pair(Combat.Mission.DEFAULT_SECONDARY_PAIR)
	official_layout_heading = Label.new()
	official_layout_heading.text = "11e Event Companion terrain · Take and Hold mirror"
	official_layout_heading.tooltip_text = "Terrain-only presets from the 11th-edition Event Companion. Mission, objectives, deployment and scoring remain unchanged. Runtime terrain uses project-authored wall and first-floor proxies; exact terrain meshes are not imported."
	official_layout_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advanced.add_child(official_layout_heading)
	official_layout_choice = OptionButton.new()
	for option: Dictionary in Combat.Terrain.event_layout_options():
		official_layout_choice.add_item(str(option.label))
		official_layout_choice.set_item_metadata(official_layout_choice.item_count - 1, str(option.id))
	official_layout_choice.item_selected.connect(func(_index: int):
		terrain_layout = _selected_official_terrain_layout()
		_refresh_official_layout_preview()
		_review_saved_armies()
	)
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
	marine_detachment_choice.add_item("Gravis Siege Force — Indomitable Defence")
	marine_detachment_choice.set_item_metadata(10, "gravis-siege-force")
	marine_detachment_choice.add_item("Wrath of the Rock — Dutiful Tenacity")
	marine_detachment_choice.set_item_metadata(11, "wrath-of-the-rock")
	marine_detachment_choice.add_item("Spearpoint Task Force — Storm-swift Onslaught")
	marine_detachment_choice.set_item_metadata(12, "spearpoint-task-force")
	marine_detachment_choice.add_item("Ironstorm Spearhead — Ironstorm Auto-targeters")
	marine_detachment_choice.set_item_metadata(13, "ironstorm-spearhead")
	marine_detachment_choice.add_item("Phobos Shock Force — 3 Stratagems + 2 Enhancements (partial)")
	marine_detachment_choice.set_item_metadata(14, "phobos-shock-force")
	marine_detachment_choice.add_item("Darkflight Pursuit — Black-winged Vigilance")
	marine_detachment_choice.set_item_metadata(15, "darkflight-pursuit")
	marine_detachment_choice.add_item("Inner Circle Task Force — Vowed Target + Champion + Singular Will (partial)")
	marine_detachment_choice.set_item_metadata(16, "inner-circle-task-force")
	marine_detachment_choice.add_item("Medusa's Wrath — Methodical Brutality, Unbowed Conviction + other effects (partial)")
	marine_detachment_choice.set_item_metadata(marine_detachment_choice.item_count - 1, "medusa-wrath")
	marine_detachment_choice.add_item("Blade of Ultramar — Mastered Doctrines (partial)")
	marine_detachment_choice.set_item_metadata(marine_detachment_choice.item_count - 1, "blade-of-ultramar")
	marine_detachment_choice.add_item("Gauntlet Task Force — Combined Deployment + 3 Stratagems (partial)")
	marine_detachment_choice.set_item_metadata(marine_detachment_choice.item_count - 1, "gauntlet-task-force")
	marine_detachment_choice.add_item("Phobos Shadow Force — partial")
	marine_detachment_choice.set_item_metadata(marine_detachment_choice.item_count - 1, "phobos-shadow-force")
	marine_detachment_choice.add_item("Fist of the God-Emperor — Oathbound only (partial)")
	marine_detachment_choice.set_item_metadata(marine_detachment_choice.item_count - 1, "fist-of-the-god-emperor")
	marine_detachment_choice.tooltip_text = "Select a Space Marine detachment with locally implemented effects. Detachments marked partial expose only the effects listed here; other effects remain unavailable. Vanguard Ambushers is blocked pending focused local validation and does not activate. Remaining Phobos Shock Force rules, local checks and full army legality remain pending. Ironstorm Auto-targeters lets a friendly Adeptus Astartes Vehicle unit other than a Walker optionally re-roll one Hit roll and one Wound roll during each ranged attack activation. Ironstorm also supports Redoubtable Machine Spirit (25 points: 5+ invulnerable save and heal 1 at Command end) and Gunnery Honours (15 points: ranged attacks gain Heavy) on eligible non-Transport, non-Fly, non-Walker vehicles. Gladius supports Adept of the Codex, Artificer Armour, Laurels of Triumph and Standard of the Emperor Ascendant on eligible units; the roster identifies the bearer for model-only enhancements. Ironclad Champions implements Enduring Vengeance, all three stratagems and both enhancements. Assault, Tactical and Devastator Brethren each allow their named Combat Doctrine one additional time per battle. Terminator Storm Force gives Adeptus Astartes Terminator units +1 to Charge rolls; Champion of the First Company (20 points) grants Lethal Hits to all melee attacks in its export-eligible bearer's unit while the bearer lives. Corporeum Reliquary (25 points) lets an export-eligible Terminator unit ingress in its owner's first Movement phase of battle round 1; it does not enable opponent-turn Rapid Ingress. Merciless Veterans costs 1 CP when an eligible Terminator unit is selected to shoot and gives its ranged attacks Lethal Hits and Sustained Hits 1 for the phase. Tacticus Firestorm Force grants Rapid Fire at any distance within maximum range for Tacticus units. Tacticus Attack Force lets Tacticus units re-roll Advance rolls. Gravis Linebreaker Force lets Gravis units that made a Normal move fire without Heavy and with +1 to Hit. Wrath of the Rock worsens Wound rolls by 1 against Astartes Infantry/Mounted targets when Strength exceeds Toughness. Spearpoint allows one extra Assault or Tactical Doctrine selection per battle and gives +1 to Advance rolls to friendly Adeptus Astartes Mounted/Speeder units. At Fight-phase end, if Suboden Khan's unit was eligible to fight this phase, it can make a Normal Move while unengaged or a Fall Back move while engaged, using the models' Movement characteristics. Selecting Spearpoint enables current unit abilities for that movement workflow. The White Scars-only chapter restriction is enforced for current runtime profiles. Other detachment rules, interactions and full army legality remain pending."
	marine_detachment_choice.tooltip_text += " Gravis Siege Force gives friendly Gravis units within objective range -1 to incoming Wound rolls when attack Strength exceeds their Toughness. Immovable Conquerors adds +1 OC to an eligible Gravis unit for 15 points. Narthecis Gauntlet (20 points) is available to an export-eligible Apothecary Biologis and heals its unit D3+1 wounds in the Command phase. Gravis Linebreaker offers Indefatigable Fortitude and Relentless Advance (20 points each; -1 to Wound against stronger attacks or Scouts 5 for the unit), available to export-eligible Apothecary Biologis and Captain in Gravis Armour bearers. Gravis Linebreaker and Gravis Siege offer Annihilating Force at attack declaration (1 CP, Lethal Hits for the phase); Gravis Linebreaker also offers Purgation Push after a shot (1 CP, move up to 5 inches and end within objective range; no Charge or embark this turn) and Armoured Impact after a charge (1 CP, one mortal wound for each 3+ on a D6 per engaged model). Gravis Siege offers Stand Unyielding at Movement-phase end (1 CP, secure one objective controlled by an eligible Gravis unit) and Suppression Volleys after a Gravis shooting activation hits (1 CP, one hit enemy takes Battle-shock at -1). Focused local checks remain pending."
	marine_detachment_choice.tooltip_text += " Darkflight Pursuit implements Black-winged Vigilance and the 15-point Thundercowl Turbines ingress exception for eligible current Ravenwing FLY/MOUNTED profiles. It requires current unit abilities and Dark Angels Chapter context. Wings of Shadow is selectable as a 1 CP defender reaction that grants Stealth before dice when an enemy targets eligible Ravenwing FLY/MOUNTED units in its Shooting phase. We Are Vengeance is selectable after an enemy Shooting activation targets an unengaged Ravenwing FLY unit and allows a Normal Move up to D3+3 inches. Skyborne Surveillance is selectable after a Ravenwing FLY unit shoots and grants +3 detection to visible enemy units within 6 inches through the end of the Shooting phase. Nightforged Battery remains unsupported; focused checks and full army legality remain pending."
	marine_detachment_choice.tooltip_text += " Inner Circle Task Force implements Vowed Target, the 20-point Champion of the Deathwing and Singular Will enhancements. Vowed Target prompts at Command entry to choose or skip one objective; eligible Deathwing Infantry attacks gain +1 to Wound against enemies in its range until the next Command phase. Champion is selectable for five current-catalog Deathwing bearer profiles and grants the bearer unit Sustained Hits 1 against enemies within range of its active Vowed objective. Current unit abilities and Dark Angels Chapter context are required. Singular Will (20 points) is selectable for five source-linked Deathwing profiles and lets the unit consolidate up to D3+3 inches. Duty Unto Death now offers its 1 CP Fight reaction to a targeted Deathwing unit before it fights, with +1 to the retention roll when engaged with an enemy unit that has a living model within the active Vowed objective range. Relic Teleportarium (1 CP) permits eligible Deathwing Deep Strike reserves to ingress more than 6 inches from enemies in the normal timing window and blocks Charge for the turn; focused checks remain pending. Full army legality is uncertified."
	marine_detachment_choice.tooltip_text += " Medusa's Wrath implements Methodical Brutality, Unbowed Conviction, Ancient Fury, Spirits of Iron, Vengeful Animus, Power of the Machine Spirit and Armoured Wrath for bounded local scopes. Methodical Brutality costs 1 CP when a friendly Adeptus Astartes unit is selected to attack and grants Sustained Hits 1; Vehicle units also gain +1 to Wound for the phase. Unbowed Conviction costs 1 CP in your Command phase for a friendly Adeptus Astartes unit below Starting Strength; until your next Command phase, it ignores modifiers to BS/WS and Hit/Wound rolls. Spirits of Iron costs 1 CP when a friendly Adeptus Astartes unit suffers a mortal wound and grants Feel No Pain 5+ against mortal wounds for the phase. Vengeful Animus costs 1 CP when a friendly Adeptus Astartes Vehicle is destroyed, before Deadly Demise, and changes all its Deadly Demise rolls to unmodified 6s. These effects require current unit abilities and Iron Hands Chapter context. Power of the Machine Spirit is a 1 CP reaction after an enemy shoots an unengaged friendly Astartes Vehicle; it returns fire only at that enemy, using Snap shooting above half-strength and normal shooting at half-strength or below. Armoured Wrath permits one attack re-roll for a selected Astartes unit, or one Hit, Wound and Damage re-roll each within 6 inches of friendly Iron Father Feirros. The Flesh is Weak costs 15 points and is selectable for 23 source-matched current profiles; its bearer gains +1 Toughness and Feel No Pain 5+. Target Augury Web costs 30 points and is selectable for the source-matched Techmarine profile; at the start or end of its unit's Movement-phase move, it can select one friendly Adeptus Astartes Vehicle model within 3 inches of any model in the bearer unit. That model gains Lethal Hits for ranged and melee attacks until the start of your next Command phase. Master of the Machine War costs 25 points and is selectable for 23 source-linked current profiles; in your Movement phase the bearer selects one visible friendly Adeptus Astartes Vehicle unit within 6 inches and chooses Devastator or Tactical Doctrine for it until your next Command phase. The choice uses the shared doctrine usage limit. Adept of the Omnissiah costs 25 points and is available to the Techmarine; once per battle round per army, when an enemy targets a friendly Adeptus Astartes Vehicle within 6 inches of the bearer unit, it can gain Feel No Pain 5+ until that enemy finishes attacking. Focused checks and full army legality remain pending."
	marine_detachment_choice.tooltip_text += " Ancient Fury costs 1 CP in your Command phase for a friendly Adeptus Astartes Dreadnought; it gains +1 M, T, Ld, OC and Hit rolls until your next Command phase."
	marine_detachment_choice.tooltip_text += " Phobos Shock Force offers Strike from the Shadows at attack declaration (1 CP; a hidden PHOBOS unit gains +1 Strength and Lethal Hits for its attack), Transhuman Reactions after an enemy move ends within 8 inches (1 CP; an unengaged PHOBOS unit makes a Normal Move up to D6 inches, or up to 6 inches with Tactical Doctrine), Umbral Evasion when an enemy ranged attack targets a PHOBOS unit (1 CP; -1 to Hit against that unit for the phase), the 15-point Seal of Shrouding for four export-linked PHOBOS bearers (blocks Snap Shooting target selection), and the 15-point Venator Omni-auspex for the same four bearers. Against fully hidden targets, Venator re-rolls natural Wound 1s; in Assault Doctrine it also re-rolls failed natural 2s and offers successful natural 2s as optional free choices. Focused checks remain pending."
	marine_detachment_choice.tooltip_text += " Blade of Ultramar implements Mastered Doctrines: if the army includes Marneus Calgar, each Combat Doctrine can be selected one additional time per battle. It requires current unit abilities and Ultramarines Chapter context. Student of the Codex (20 points) is selectable for six current-catalog Captain profiles; it keeps Tactical Doctrine active for the enhanced unit alongside its other doctrine. Armour of Antoninus (15 points) is selectable for 23 source-linked current-catalog Character profiles; its bearer has Save 2+ and Feel No Pain 5+. Oath of Macragge (20 points) is selectable for 23 source-linked current-catalog Character profiles; its bearer's melee attacks gain +1 Strength and AP, or +2 Strength and AP while Assault Doctrine is active. Veteran of Behemoth (20 points) is selectable for 23 source-linked current-catalog Character profiles; the bearer unit's ranged attacks gain Sustained Hits 1. All four enhancements, Armour of Contempt, Courage and Honour!, Exemplary Vigilance, Ultramarian Adaptivity, and Practical Tactics have local runtime paths. Courage costs 1 CP and grants Lance to the selected unit’s melee attacks; Exemplary Vigilance costs 1 CP and grants ranged Ignores Cover; Ultramarian Adaptivity costs 1 CP and assigns a Combat Doctrine to one friendly unit until your next Command phase; Practical Tactics costs 1 CP and offers a D3+3-inch Normal Move after an enemy move ends nearby; Tactical Foresight costs 1 CP when an enemy targets a friendly Astartes unit in the opponent's Shooting or Fight phase and gives that enemy's attacks -1 to Wound when Strength exceeds Toughness. All six stratagems have local runtime paths; focused local checks, current official rule locators and full army legality remain pending."
	marine_detachment_choice.tooltip_text += " Gauntlet Task Force is partial: after a friendly Adeptus Astartes Transport shoots, choose one enemy unit it hit or pass. That unit is Assailed until end of turn; friendly Adeptus Astartes units that disembarked this turn gain Sustained Hits 1 against it. Linebreaker Onslaught (20 points) lets its enhanced unit re-roll Charge rolls and prevents Snap Shooting targeting if it disembarked this turn; 21 current-catalog Infantry bearers are source-linked. Damocles-class Uplink (15 points) is selectable for six Captain profiles; while its bearer unit is embarked, assign one unused doctrine in your Movement phase to nearby Infantry with Combat Doctrines, until your next Command phase. Storm and Secure (1 CP) lets a friendly Astartes Transport carrying Astartes Battleline secure an objective it controls at the end of your Movement phase. Duty is Never Done (1 CP, end of the Fight phase) lets an unengaged friendly Astartes Infantry unit that was eligible to fight embark in a friendly eligible Transport when every model is within 6 inches. Aggressive Disembarkation (1 CP) is available for current Movement-phase disembark choices; each model may be set up within, rather than wholly within, the Transport's set-up distance. Emergency Disembark now offers an optional pre-Hazard use of Aggressive Disembarkation; models may be set up within (not wholly within) 6 inches and must still be placed as close as possible. Before each mandatory Drop Pod Assault Rapid Disembark, the pre-placement choice is available after arrival, including after Rapid Ingress during the opponent's Movement phase; the more-than-8-inch enemy restriction remains. Other out-of-phase selection contexts remain unsupported; focused checks remain pending."
	marine_detachment_choice.tooltip_text += " Phobos Shadow Force is partial. After a friendly PHOBOS or SCOUT SQUAD shoots in its own Shooting phase, Shadow Masters offers Hidden preservation for the turn or a Normal Move up to D6 inches that blocks Charge until turn end. Strike from the Shadows (1 CP) grants hidden PHOBOS attacks +1 Strength and Lethal Hits; Tactical Withdrawal (1 CP) can place an unengaged PHOBOS or SCOUT SQUAD in Strategic Reserves at the opponent's Fight-phase end; Mortis Snares (1 CP) arms controlled objectives at Movement-phase end and can inflict D6 mortal wounds when an enemy move ends within range and the owner's roll is 2+. Venator Omni-auspex (15 points) grants Wound rerolls against fully hidden targets, with successful natural 2s optional in Assault Doctrine; Execute and Redeploy (25 points) offers an unengaged post-shot Normal Move up to 6 inches and blocks Charge until turn end. Both enhancements are limited to four export-linked PHOBOS bearers. Shadow Masters remains limited to the owner's Shooting phase. Focused checks, network validation and full army legality remain pending."
	marine_detachment_choice.tooltip_text += " Fist of the God-Emperor is partial: Oathbound Exemplar (10 points) is selectable for source-linked Adeptus Astartes Infantry units. It removes only the Advance/Fall Back restriction from starting an otherwise eligible action. Purge and Sanctify, Righteous Fervour and the three detachment stratagems remain unavailable; current checks, network validation and full army legality remain pending."
	advanced.add_child(marine_detachment_choice)
	marine_detachment_choice.item_selected.connect(func(_index: int):
		marine_detachment = _selected_marine_detachment()
		marine_detachments = _selected_marine_detachments()
		if marine_detachment in ["spearpoint-task-force", "darkflight-pursuit", "inner-circle-task-force", "medusa-wrath", "blade-of-ultramar", "fist-of-the-god-emperor"] and unit_abilities_choice != null: unit_abilities_choice.button_pressed = true
		_review_saved_armies())
	var marine_detachment_heading_p2 := Label.new()
	marine_detachment_heading_p2.text = "Player 2 Space Marine detachment"
	advanced.add_child(marine_detachment_heading_p2)
	marine_detachment_choice_p2 = OptionButton.new()
	for index in marine_detachment_choice.item_count:
		marine_detachment_choice_p2.add_item(marine_detachment_choice.get_item_text(index))
		marine_detachment_choice_p2.set_item_metadata(index, marine_detachment_choice.get_item_metadata(index))
	marine_detachment_choice_p2.tooltip_text = "Choose Player 2's detachment independently. Gravis Siege Force gives Gravis units within objective range -1 to incoming Wound rolls when attack Strength exceeds Toughness; Immovable Conquerors adds +1 OC to an eligible Gravis unit for 15 points. Narthecis Gauntlet (20 points) is available to an export-eligible Apothecary Biologis and heals its unit D3+1 wounds in the Command phase. Gravis Linebreaker offers Indefatigable Fortitude and Relentless Advance (20 points each; -1 to Wound against stronger attacks or Scouts 5 for the unit), available to export-eligible Apothecary Biologis and Captain in Gravis Armour bearers. Gravis Linebreaker and Gravis Siege offer Annihilating Force at attack declaration (1 CP, Lethal Hits for the phase); Gravis Linebreaker also offers Purgation Push after a shot (1 CP, move up to 5 inches and end within objective range; no Charge or embark this turn) and Armoured Impact after a charge (1 CP, one mortal wound for each 3+ on a D6 per engaged model). Gravis Siege offers Stand Unyielding at Movement-phase end (1 CP, secure one objective controlled by an eligible Gravis unit) and Suppression Volleys after a Gravis shooting activation hits (1 CP, one hit enemy takes Battle-shock at -1). Terminator Storm Force also supports Champion of the First Company, Corporeum Reliquary and Merciless Veterans for their bounded local scopes. Focused local checks remain pending. LAN peers must use the same per-player selections."
	marine_detachment_choice_p2.tooltip_text += " Darkflight Pursuit implements Black-winged Vigilance and the 15-point Thundercowl Turbines ingress exception for eligible current Ravenwing FLY/MOUNTED profiles. It requires current unit abilities and Dark Angels Chapter context. Wings of Shadow is selectable as a 1 CP defender reaction that grants Stealth before dice when an enemy targets eligible Ravenwing FLY/MOUNTED units in its Shooting phase. We Are Vengeance is selectable after an enemy Shooting activation targets an unengaged Ravenwing FLY unit and allows a Normal Move up to D3+3 inches. Skyborne Surveillance is selectable after a Ravenwing FLY unit shoots and grants +3 detection to visible enemy units within 6 inches through the end of the Shooting phase. Nightforged Battery remains unsupported; focused checks and full army legality remain pending."
	marine_detachment_choice_p2.tooltip_text += " Inner Circle Task Force implements Vowed Target, the 20-point Champion of the Deathwing and Singular Will enhancements. Vowed Target prompts at Command entry to choose or skip one objective; eligible Deathwing Infantry attacks gain +1 to Wound against enemies in its range until the next Command phase. Champion is selectable for five current-catalog Deathwing bearer profiles and grants the bearer unit Sustained Hits 1 against enemies within range of its active Vowed objective. Current unit abilities and Dark Angels Chapter context are required. Singular Will (20 points) is selectable for five source-linked Deathwing profiles and lets the unit consolidate up to D3+3 inches. Duty Unto Death now offers its 1 CP Fight reaction to a targeted Deathwing unit before it fights, with +1 to the retention roll when engaged with an enemy unit that has a living model within the active Vowed objective range. Relic Teleportarium (1 CP) permits eligible Deathwing Deep Strike reserves to ingress more than 6 inches from enemies in the normal timing window and blocks Charge for the turn; focused checks remain pending. Full army legality is uncertified."
	marine_detachment_choice_p2.tooltip_text += " Medusa's Wrath implements Methodical Brutality, Unbowed Conviction, Ancient Fury, Spirits of Iron, Vengeful Animus, Power of the Machine Spirit and Armoured Wrath for bounded local scopes. Methodical Brutality costs 1 CP when a friendly Adeptus Astartes unit is selected to attack and grants Sustained Hits 1; Vehicle units also gain +1 to Wound for the phase. Unbowed Conviction costs 1 CP in your Command phase for a friendly Adeptus Astartes unit below Starting Strength; until your next Command phase, it ignores modifiers to BS/WS and Hit/Wound rolls. Spirits of Iron costs 1 CP when a friendly Adeptus Astartes unit suffers a mortal wound and grants Feel No Pain 5+ against mortal wounds for the phase. Vengeful Animus costs 1 CP when a friendly Adeptus Astartes Vehicle is destroyed, before Deadly Demise, and changes all its Deadly Demise rolls to unmodified 6s. These effects require current unit abilities and Iron Hands Chapter context. Power of the Machine Spirit is a 1 CP reaction after an enemy shoots an unengaged friendly Astartes Vehicle; it returns fire only at that enemy, using Snap shooting above half-strength and normal shooting at half-strength or below. Armoured Wrath permits one attack re-roll for a selected Astartes unit, or one Hit, Wound and Damage re-roll each within 6 inches of friendly Iron Father Feirros. The Flesh is Weak costs 15 points and is selectable for 23 source-matched current profiles; its bearer gains +1 Toughness and Feel No Pain 5+. Target Augury Web costs 30 points and is selectable for the source-matched Techmarine profile; at the start or end of its unit's Movement-phase move, it can select one friendly Adeptus Astartes Vehicle model within 3 inches of any model in the bearer unit. That model gains Lethal Hits for ranged and melee attacks until the start of your next Command phase. Master of the Machine War costs 25 points and is selectable for 23 source-linked current profiles; in your Movement phase the bearer selects one visible friendly Adeptus Astartes Vehicle unit within 6 inches and chooses Devastator or Tactical Doctrine for it until your next Command phase. The choice uses the shared doctrine usage limit. Adept of the Omnissiah costs 25 points and is available to the Techmarine; once per battle round per army, when an enemy targets a friendly Adeptus Astartes Vehicle within 6 inches of the bearer unit, it can gain Feel No Pain 5+ until that enemy finishes attacking. Focused checks and full army legality remain pending."
	marine_detachment_choice_p2.tooltip_text += " Ancient Fury costs 1 CP in your Command phase for a friendly Adeptus Astartes Dreadnought; it gains +1 M, T, Ld, OC and Hit rolls until your next Command phase."
	marine_detachment_choice_p2.tooltip_text += " Gauntlet Task Force is partial: after a friendly Adeptus Astartes Transport shoots, choose one enemy unit it hit or pass. That unit is Assailed until end of turn; friendly Adeptus Astartes units that disembarked this turn gain Sustained Hits 1 against it. Linebreaker Onslaught (20 points) lets its enhanced unit re-roll Charge rolls and prevents Snap Shooting targeting if it disembarked this turn; 21 current-catalog Infantry bearers are source-linked. Damocles-class Uplink (15 points) is selectable for six Captain profiles; while its bearer unit is embarked, assign one unused doctrine in your Movement phase to nearby Infantry with Combat Doctrines, until your next Command phase. Storm and Secure (1 CP) lets a friendly Astartes Transport carrying Astartes Battleline secure an objective it controls at the end of your Movement phase. Duty is Never Done (1 CP, end of the Fight phase) lets an unengaged friendly Astartes Infantry unit that was eligible to fight embark in a friendly eligible Transport when every model is within 6 inches. Aggressive Disembarkation (1 CP) is available for current Movement-phase disembark choices; each model may be set up within, rather than wholly within, the Transport's set-up distance. Emergency Disembark now offers an optional pre-Hazard use of Aggressive Disembarkation; models may be set up within (not wholly within) 6 inches and must still be placed as close as possible. Before each mandatory Drop Pod Assault Rapid Disembark, the pre-placement choice is available after arrival, including after Rapid Ingress during the opponent's Movement phase; the more-than-8-inch enemy restriction remains. Other out-of-phase selection contexts remain unsupported; focused checks remain pending."
	marine_detachment_choice_p2.tooltip_text += " Blade of Ultramar implements Mastered Doctrines: if the army includes Marneus Calgar, each Combat Doctrine can be selected one additional time per battle. It requires current unit abilities and Ultramarines Chapter context. Student of the Codex (20 points) is selectable for six current-catalog Captain profiles; it keeps Tactical Doctrine active for the enhanced unit alongside its other doctrine. Armour of Antoninus (15 points) is selectable for 23 source-linked current-catalog Character profiles; its bearer has Save 2+ and Feel No Pain 5+. Oath of Macragge (20 points) is selectable for 23 source-linked current-catalog Character profiles; its bearer's melee attacks gain +1 Strength and AP, or +2 Strength and AP while Assault Doctrine is active. Veteran of Behemoth (20 points) is selectable for 23 source-linked current-catalog Character profiles; the bearer unit's ranged attacks gain Sustained Hits 1. All four enhancements, Armour of Contempt, Courage and Honour!, Exemplary Vigilance, Ultramarian Adaptivity, and Practical Tactics have local runtime paths. Courage costs 1 CP and grants Lance to the selected unit’s melee attacks; Exemplary Vigilance costs 1 CP and grants ranged Ignores Cover; Ultramarian Adaptivity costs 1 CP and assigns a Combat Doctrine to one friendly unit until your next Command phase; Practical Tactics costs 1 CP and offers a D3+3-inch Normal Move after an enemy move ends nearby; Tactical Foresight costs 1 CP when an enemy targets a friendly Astartes unit in the opponent's Shooting or Fight phase and gives that enemy's attacks -1 to Wound when Strength exceeds Toughness. All six stratagems have local runtime paths; focused local checks, current official rule locators and full army legality remain pending."
	marine_detachment_choice_p2.tooltip_text += " Phobos Shadow Force is partial. Shadow Masters offers Hidden preservation or a D6-inch Normal Move after an eligible unit shoots, and the 15-point Venator Omni-auspex plus 25-point Execute and Redeploy enhancements are selectable for four export-linked PHOBOS bearers. Strike from the Shadows, Tactical Withdrawal and Mortis Snares have bounded local paths. Shadow Masters remains limited to the owner's Shooting phase; focused checks, network validation and full army legality remain pending."
	marine_detachment_choice_p2.tooltip_text += " Fist of the God-Emperor is partial: Oathbound Exemplar (10 points) is selectable for source-linked Adeptus Astartes Infantry units. It removes only the Advance/Fall Back restriction from starting an otherwise eligible action. Purge and Sanctify, Righteous Fervour and the three detachment stratagems remain unavailable; current checks, network validation and full army legality remain pending."
	advanced.add_child(marine_detachment_choice_p2)
	marine_detachment_choice_p2.item_selected.connect(func(_index: int):
		marine_detachment_p2 = _selected_marine_detachment_for(marine_detachment_choice_p2)
		marine_detachments = _selected_marine_detachments()
		if marine_detachment_p2 in ["spearpoint-task-force", "darkflight-pursuit", "inner-circle-task-force", "medusa-wrath", "blade-of-ultramar", "fist-of-the-god-emperor"] and unit_abilities_choice != null: unit_abilities_choice.button_pressed = true
		_review_saved_armies())
	var marine_chapter_heading_p1 := Label.new()
	marine_chapter_heading_p1.text = "Player 1 Chapter context"
	advanced.add_child(marine_chapter_heading_p1)
	marine_chapter_choice_p1 = OptionButton.new()
	_populate_marine_chapter_choice(marine_chapter_choice_p1)
	marine_chapter_choice_p1.tooltip_text = "Choose the Chapter for generic current-reference Adeptus Astartes profiles, or infer it from named Chapter profiles and the selected detachment. Dark Angels grants the conditional DEATHWING and RAVENWING keywords. Conflicting roster or detachment contexts are rejected. Both LAN players must use matching selections."
	advanced.add_child(marine_chapter_choice_p1)
	marine_chapter_choice_p1.item_selected.connect(func(_index: int):
		marine_chapters = _selected_marine_chapters()
		_review_saved_armies())
	var marine_chapter_heading_p2 := Label.new()
	marine_chapter_heading_p2.text = "Player 2 Chapter context"
	advanced.add_child(marine_chapter_heading_p2)
	marine_chapter_choice_p2 = OptionButton.new()
	_populate_marine_chapter_choice(marine_chapter_choice_p2)
	marine_chapter_choice_p2.tooltip_text = marine_chapter_choice_p1.tooltip_text
	advanced.add_child(marine_chapter_choice_p2)
	marine_chapter_choice_p2.item_selected.connect(func(_index: int):
		marine_chapters = _selected_marine_chapters()
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
	var multi_storey_button := _button(launch, "Multi-storey objective practice · 3 in / 6 in", func(): _start_objectives(1, Combat.Terrain.MULTI_STOREY_PRACTICE_LAYOUT))
	multi_storey_button.tooltip_text = "Move eligible models onto the 3-inch or 6-inch surfaces along the ruin wall. Vertical distance counts toward movement. Attacks from either surface can use Plunging Fire if the target is visible and contains a ground-level model. Project-authored exercise geometry, not an Event Companion layout."
	prepared_button = _button(launch, "Prepare match • deployment + 5 rounds", _start_prepared_match)
	for primary: Button in [combat_button, objective_button, multi_storey_button, prepared_button]:
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
	local_model_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_model_status.text = "Models: ForceOrg catalog and compatible miniatures download automatically. Saved links are reused."
	saved_lists.add_child(local_model_status)
	var model_play_notice := Label.new()
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
	selected_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selection_panel = selected_card
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = Color("10171d")
	selected_style.border_color = Color("536b78")
	selected_style.border_width_top = 1
	selected_style.content_margin_left = 0
	selected_style.content_margin_right = 0
	selected_style.content_margin_top = 7
	selected_style.content_margin_bottom = 7
	selected_card.add_theme_stylebox_override("panel", selected_style)
	column.add_child(selected_card)
	selection_home = column
	selection_home_index = selected_card.get_index()
	var selected_content := VBoxContainer.new()
	selected_content.add_theme_constant_override("separation", 5)
	selected_card.add_child(selected_content)
	selection_card = Label.new()
	selection_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selection_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_card.add_theme_font_size_override("font_size", 16)
	selection_card.add_theme_color_override("font_color", Color("e6edf0"))
	selected_content.add_child(selection_card)
	selection_health = ProgressBar.new()
	selection_health.show_percentage = false
	selection_health.custom_minimum_size.y = 6
	var health_fill := StyleBoxFlat.new()
	health_fill.bg_color = Color("93cba8")
	health_fill.set_corner_radius_all(3)
	selection_health.add_theme_stylebox_override("fill", health_fill)
	selection_health.visible = false
	selected_content.add_child(selection_health)
	selection_stats = GridContainer.new()
	selection_stats.visible = false
	selected_content.add_child(selection_stats)
	datasheet_button = Button.new()
	datasheet_button.text = "Datasheet"
	datasheet_button.tooltip_text = "Inspect the selected match profile."
	datasheet_button.custom_minimum_size.y = 40
	datasheet_button.visible = false
	datasheet_button.pressed.connect(_open_selected_datasheet)
	selected_content.add_child(datasheet_button)
	datasheet_details = ScrollContainer.new()
	datasheet_details.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	datasheet_details.focus_mode = Control.FOCUS_ALL
	datasheet_details.visible = false
	selected_content.add_child(datasheet_details)
	datasheet_view = UnitDatasheet.new()
	datasheet_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	datasheet_view.reference_folder_requested.connect(_open_local_ability_reference_folder)
	datasheet_view.reference_reload_requested.connect(_reload_local_ability_reference)
	datasheet_view.reference_folder_copy_requested.connect(_copy_local_ability_reference_folder_path)
	datasheet_details.add_child(datasheet_view)
	_build_army_panel(layer)
	contact_flow = preload("res://scripts/ui/decision_steps.gd").new()
	contact_flow.visible = false
	column.add_child(contact_flow)
	first_session_panel = PanelContainer.new()
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
	first_session_guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_session_guide.max_lines_visible = 4
	first_session_guide.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	first_session_content.add_child(first_session_guide)
	first_session_boundary = RichTextLabel.new()
	first_session_boundary.bbcode_enabled = true
	first_session_boundary.fit_content = true
	first_session_boundary.scroll_active = false
	first_session_content.add_child(first_session_boundary)
	first_session_experiments = Label.new()
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
	decision_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(decision_details)
	technical_toggle = CheckButton.new()
	technical_toggle.text = "Show equipment and technical details"
	technical_toggle.toggled.connect(func(expanded: bool): details.visible = expanded)
	column.add_child(technical_toggle)
	details = Label.new()
	details.visible = false
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(details)
	reanimation_help = Label.new()
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
	vowed_help = Label.new()
	vowed_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(vowed_help)
	vowed_objective = OptionButton.new()
	vowed_objective.fit_to_longest_item = false
	column.add_child(vowed_objective)
	vowed_confirm = _button(column, "Confirm Vowed objective / skip", _request_vowed_objective)
	doctrine_help = Label.new()
	doctrine_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(doctrine_help)
	doctrine_choice = OptionButton.new()
	doctrine_choice.fit_to_longest_item = false
	column.add_child(doctrine_choice)
	doctrine_confirm = _button(column, "Confirm doctrine / no doctrine", _request_combat_doctrine)
	oath_help = Label.new()
	oath_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(oath_help)
	oath_target = OptionButton.new()
	oath_target.fit_to_longest_item = false
	column.add_child(oath_target)
	oath_confirm = _button(column, "Confirm Oath of Moment target", _request_oath_target)
	reaction_help = Label.new()
	reaction_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	reaction_use_row = HBoxContainer.new()
	reaction_use_row.add_theme_constant_override("separation", 6)
	column.add_child(reaction_use_row)
	reaction_use_icon = CombatSymbol.new()
	reaction_use_icon.kind = "Reroll"
	reaction_use_row.add_child(reaction_use_icon)
	reaction_use = _button(reaction_use_row, "Command Re-roll · 1 CP", _request_use_reaction)
	reaction_use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reaction_roll.custom_minimum_size.y = 44
	reaction_use.custom_minimum_size.y = 44
	reaction_sudden_row = HBoxContainer.new()
	reaction_sudden_row.add_theme_constant_override("separation", 6)
	column.add_child(reaction_sudden_row)
	reaction_sudden_icon = CombatSymbol.new()
	reaction_sudden_icon.kind = "Reroll"
	reaction_sudden_row.add_child(reaction_sudden_icon)
	reaction_sudden = _button(reaction_sudden_row, "Sudden Storm: re-roll Advance • 0 CP", func():
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
	reaction_sudden.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	movement_elevation_choice = OptionButton.new()
	movement_elevation_choice.tooltip_text = "Choose the height for right-click placement. Without Take to the Skies, ordinary terrain access and vertical distance apply to FLY models too. Take to the Skies lets FLY models pass through all models and terrain while ignoring vertical distance, with a 2-inch maximum-move reduction unless the unit has HOVER."
	movement_elevation_choice.item_selected.connect(func(_index: int): _refresh())
	column.add_child(movement_elevation_choice)
	sudden_onslaught_choice = CheckBox.new()
	sudden_onslaught_choice.text = "Sudden Onslaught • spend 1 CP to set Advance to 6"
	sudden_onslaught_choice.tooltip_text = "Stormlance Task Force Stratagem. Declare it when this Mounted/Speeder unit is selected to Advance; replace its Advance D6 with 6 before other modifiers. It uses the unit's one stratagem for this phase."
	sudden_onslaught_choice.toggled.connect(func(_active: bool): _refresh())
	column.add_child(sudden_onslaught_choice)
	take_to_skies_choice = CheckBox.new()
	take_to_skies_choice.text = "Take to the Skies • FLY unit"
	take_to_skies_choice.tooltip_text = "Declare before moving (and before rolling Advance). FLY models can move through all models and terrain. Maximum move is reduced by 2 inches unless the unit has HOVER."
	take_to_skies_choice.toggled.connect(func(_active: bool): _refresh())
	column.add_child(take_to_skies_choice)
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
	allocate_button.custom_minimum_size.y = 40
	allocate_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	precision_skip = _button(column, "Do not use Precision", _request_skip_precision)
	precision_skip.custom_minimum_size.y = 40
	defense_steps = Label.new()
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
	take_to_skies_charge_choice = CheckBox.new()
	take_to_skies_charge_choice.text = "Take to the Skies • FLY unit"
	take_to_skies_charge_choice.tooltip_text = "Declare before rolling the charge. FLY models can move through all models and terrain while resolving this move. Reduce maximum charge distance by 2 inches unless the unit has HOVER."
	take_to_skies_charge_choice.toggled.connect(func(_active: bool): _refresh())
	column.add_child(take_to_skies_charge_choice)
	charge_targets = VBoxContainer.new()
	charge_targets.visible = false
	column.add_child(charge_targets)
	charge_target_notes = Label.new()
	charge_target_notes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	charge_target_notes.max_lines_visible = 4
	charge_target_notes.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	charge_target_notes.add_theme_color_override("font_color", Color("f2b1a0"))
	charge_target_notes.visible = false
	charge_targets.add_child(charge_target_notes)
	begin_contact_button = _button(column, "Begin contact movement", _request_begin_contact)
	tactical_focus_button = _button(column, "Tactical Focus (1 CP) and begin consolidation", _request_tactical_focus_contact)
	tactical_focus_button.visible = false
	consolidation_objective = OptionButton.new()
	column.add_child(consolidation_objective)
	contact_enemy = OptionButton.new()
	column.add_child(contact_enemy)
	contact_elevation_choice = OptionButton.new()
	contact_elevation_choice.tooltip_text = "Choose the surface for this model's contact move. Vertical distance counts unless this FLY model is taking to the skies or has Reiver Grapnel Launchers."
	contact_elevation_choice.item_selected.connect(func(_index: int): _refresh())
	column.add_child(contact_elevation_choice)
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
	plan_steps.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(plan_steps)
	plan_assignment_status = Label.new()
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
	plan_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plan_summary.add_theme_color_override("font_color", Color("d8e3e7"))
	column.add_child(plan_summary)
	damage_preview = Label.new()
	damage_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	damage_preview.add_theme_color_override("font_color", Color("f2c879"))
	column.add_child(damage_preview)
	plan_confirm = _button(column, "Confirm attacks", _confirm_attack_plan)
	plan_cancel = _button(column, "Cancel plan", func(): attack_draft = {}; _refresh())
	status = Label.new()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "Local preview: control both sides."
	column.add_child(status)
	column.move_child(status, 0)
	notice_heading = Label.new()
	notice_heading.visible = false
	column.add_child(notice_heading)
	column.move_child(notice_heading, 0)
	controls_help = Label.new()
	controls_help.text = "Left: select miniature • Right: move / target\nWheel: zoom • Middle drag: orbit"
	column.add_child(controls_help)
	result_summary = Label.new()
	result_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(result_summary)
	health_overlay_toggle = CheckButton.new()
	health_overlay_toggle.text = "Show Wounds and status above models"
	health_overlay_toggle.tooltip_text = "W means Wounds; each tag shows current/maximum Wounds plus a bar. Green means over 50%, amber means over 25% through 50%, and red means 25% or less. A Battle-shocked model reads Shocked above it even when this overlay is hidden. The selected model also shows OC and Moved status in its wound tag."
	health_overlay_toggle.button_pressed = true
	health_overlay_toggle.toggled.connect(func(_enabled: bool): _refresh_health_tags())
	column.add_child(health_overlay_toggle)
	board_feedback_toggle = CheckButton.new()
	board_feedback_toggle.text = "Animate board and camera"
	board_feedback_toggle.button_pressed = true
	board_feedback_toggle.tooltip_text = "Animate camera focus, models and attack links. A gold line marks a pending attack's weapon and target. After the result, a warm line means damage was applied and a cool line means no damage. These are schematic cues, not projectile paths or visibility checks."
	board_feedback_toggle.toggled.connect(func(enabled: bool):
		if not enabled:
			_stop_camera_motion()
			attack_feedback.clear()
			_finish_casualty_feedback()
			_clear_board_feedback()
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
	dice_audit_label.visible = false
	var dice_audit_toggle := CheckButton.new()
	dice_audit_toggle.text = "Show dice record"
	dice_audit_toggle.tooltip_text = "Show where these faces were recorded. Entry numbers and chain text are not a rule and do not change the result."
	dice_audit_toggle.toggled.connect(func(expanded: bool): dice_audit_label.visible = expanded)
	dice_visual.add_child(dice_audit_toggle)
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
		if not enabled:
			combat_tray.sound.stop()
			combat_tray.confirm_sound.stop()
			combat_tray.impact_sound.stop()
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
	field_guide.text = "[color=#e3b75c][b]TURN RAIL[/b][/color]\nThe gold phase is active. R# and P# show the round and active player; the decision line identifies who has priority now.\n\n[color=#e3b75c][b]CURRENT ACTION[/b][/color]\nThe banner below the rail names who acts and the next required task. Follow the available controls in the Command panel; phase progression stays gated while required choices remain.\n\n[color=#e3b75c][b]ARMY LIST[/b][/color]\nThe left panel keeps the selected model and the active player's units. Each model is named by its place in the unit, such as Model 1. Sergeant is added only for the one model that can use that unit's sergeant weapon options. Rows show wounds or Destroyed/Reserves, and the unit row shows Steady or Battle-shocked. Choosing a row selects that model and frames it. The arrow beside a unit hides its models. Hide models does that for every unit. Hide closes this panel; Army on the top bar opens it again.\n\n[color=#e3b75c][b]TABLE CONTROLS[/b][/color]\nLeft-click a miniature to select it. Right-click to place a move or choose a target. Use the wheel to zoom, middle-drag to orbit and the camera pan keys shown in Settings to pan. The Focus control centers the selected unit. P1 side or P2 side returns the camera to that player's table edge. The P1 and P2 marks stay on those edges.\n\n[color=#e3b75c][b]PANEL NAVIGATION[/b][/color]\nWhen a panel opens, focus moves to its first available control. Use Tab or the arrow keys to move between controls and Enter/Space to activate. Escape/Cancel closes the panel and returns focus to the control that opened it.\n\n[color=#e3b75c][b]READ-ONLY PANELS[/b][/color]\nThe army list, Help, Settings and the battle log are local screens. Reading them does not submit a gameplay action. LAN matches continue while they are open."
	reference.add_child(field_guide)
	reference.add_child(WeaponKeywordHelp.new())
	blockers_reference = Label.new()
	blockers_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(blockers_reference)
	blockers_rules_toggle = CheckButton.new()
	blockers_rules_toggle.text = "Show rule references"
	reference.add_child(blockers_rules_toggle)
	blockers_rules = Label.new()
	blockers_rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blockers_rules.visible = false
	reference.add_child(blockers_rules)
	blockers_rules_toggle.toggled.connect(func(expanded: bool): blockers_rules.visible = expanded)
	unit_choice_reference = Label.new()
	unit_choice_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(unit_choice_reference)
	reaction_reference = Label.new()
	reaction_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(reaction_reference)
	reaction_die.reparent(reference)
	defense_reference = Label.new()
	defense_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(defense_reference)
	contact_reference = Label.new()
	contact_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(contact_reference)
	movement_reference = Label.new()
	movement_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference.add_child(movement_reference)
	attack_reference = Label.new()
	attack_reference.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	attack_reference.text = "Attacks: select a model, choose its weapon and target, then Assign. Repeat for other models. Review the assignments before confirming. Cancel discards the draft."
	reference.add_child(attack_reference)
	for control: Control in [technical_toggle, details, decision_details, health_overlay_toggle, board_feedback_toggle, auto_frame_toggle, log_toggle, event_log, controls_help]:
		control.reparent(reference)
	tutorial_details_toggle = _button(first_session_content, "Show help and rule terms", func():
		tutorial_extra.visible = not tutorial_extra.visible
		tutorial_details_toggle.text = "Hide help and rule terms" if tutorial_extra.visible else "Show help and rule terms"
	)
	tutorial_extra = VBoxContainer.new()
	tutorial_extra.add_theme_constant_override("separation", 6)
	first_session_content.add_child(tutorial_extra)
	tutorial_extra.visible = false
	for control: Control in [first_session_boundary, first_session_experiments, first_session_terms]: control.reparent(tutorial_extra)
	# Keep the current instruction in the command panel; optional explanation stays collapsed.
	first_session_guide.add_theme_font_size_override("font_size", 17)
	first_session_guide.custom_minimum_size.x = 0
	first_session_guide.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# A required choice may be long; phase navigation must not scroll out of reach.
	action_groups.phase.container.reparent(header)
	end_button.custom_minimum_size.y = 44
	end_button.add_theme_color_override("font_color", Color("f2df83"))
	match_tabs.current_tab = 0
	setup.get_parent().visible = true
	guide_panel = PanelContainer.new()
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
	main_menu.help_requested.connect(_open_title_field_guide)
	main_menu.settings_requested.connect(_open_settings_screen)
	main_menu.saved_results_requested.connect(_open_saved_results)
	main_menu.history_requested.connect(_open_history_screen)
	main_menu.save_requested.connect(_save_from_match_menu)
	_build_tactical_overlay()
	saved_matches_browser.load_requested.connect(_load_saved_match_slot)
	saved_matches_browser.save_requested.connect(_save_current_match_to_slot)
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
	tactical_overlay_close_button = Button.new()
	tactical_overlay_close_button.text = "Close"
	tactical_overlay_close_button.custom_minimum_size = Vector2(86, 34)
	tactical_overlay_close_button.pressed.connect(_close_tactical_screen)
	heading.add_child(tactical_overlay_close_button)
	var separator := HSeparator.new()
	column.add_child(separator)
	tactical_overlay_body = VBoxContainer.new()
	tactical_overlay_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tactical_overlay_body)
	_build_title_field_guide()
	saved_matches_browser = SavedMatchesBrowser.new()
	saved_matches_browser.visible = false
	tactical_overlay_body.add_child(saved_matches_browser)
	saved_results_browser = SavedResultsBrowser.new()
	saved_results_browser.visible = false
	tactical_overlay_body.add_child(saved_results_browser)
	_build_mission_overview()
	_build_settings_panel()
	_layout_tactical_overlay()
	var handoff_layer := CanvasLayer.new()
	handoff_layer.layer = 30
	add_child(handoff_layer)
	var handoff_component: Control = LocalPlayerHandoff.new()
	handoff_component.visible = false
	handoff_component.connect("confirmed", _on_local_handoff_confirmed)
	local_player_handoff = handoff_component
	handoff_layer.add_child(handoff_component)

func _refresh_local_handoff() -> void:
	if local_player_handoff == null: return
	if mode != "local" or not combat_enabled or main_menu == null or main_menu.visible or state.get("phase", "") == "army_selection" or int(state.get("test_winner", 0)) != 0:
		local_handoff_last_owner = 0
		local_player_handoff.visible = false
		return
	var actor := _match_actor()
	if actor not in [1, 2]:
		local_player_handoff.visible = false
		return
	if local_handoff_last_owner == 0:
		# Treat Player 1 as the seat that opened a local match. If a resumed
		# state already belongs to Player 2, cover it with the handoff prompt.
		local_handoff_last_owner = 1
		if actor == local_handoff_last_owner: return
	if actor != local_handoff_last_owner:
		local_handoff_last_owner = actor
		local_player_handoff.call("show_for_player", actor)

func _on_local_handoff_confirmed(player: int) -> void:
	if mode != "local" or player != _match_actor():
		_refresh_local_handoff()
		return
	local_handoff_last_owner = player
	call_deferred("_focus_local_decision_control")

func _focus_local_decision_control() -> void:
	if local_player_handoff == null or local_player_handoff.visible or mode != "local": return
	var target := _find_visible_focus_target(command_panel) if command_panel != null else null
	if target != null: target.grab_focus()

func _build_title_field_guide() -> void:
	title_guide_scroll = ScrollContainer.new()
	title_guide_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	title_guide_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_guide_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_guide_scroll.visible = false
	tactical_overlay_body.add_child(title_guide_scroll)
	var guide := RichTextLabel.new()
	guide.bbcode_enabled = true
	guide.fit_content = true
	guide.scroll_active = false
	guide.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide.text = "[color=#e3b75c][b]QUICK START[/b][/color]\nStart tactical training for offline practice with two local armies, optional tips and no downloads. You control both sides. Choose New match for a saved-army exercise or LAN setup. Armies, Models and Tools open local workspaces; opening them does not start a match.\n\n[color=#e3b75c][b]READ THE TURN[/b][/color]\nThe highlighted phase and decision line show where play is and who must act. Read the instruction below the turn rail, then use the matching controls in Command. The game keeps phase progression closed while required choices remain.\n\n[color=#e3b75c][b]DICE AND RE-ROLLS[/b][/color]\nIf Command offers Keep result, it accepts the displayed dice for 0 CP. A re-roll remains optional when Keep result is available; the re-roll control shows its current CP cost and which die or dice would be replaced.\n\n[color=#e3b75c][b]TABLE CONTROLS[/b][/color]\nLeft-click a miniature to select it. Right-click to request a move or choose a target. Use the mouse wheel to zoom and middle-drag to orbit. The current keyboard bindings for camera pan, Focus and Datasheet appear in Settings. The Focus and Datasheet buttons also perform these actions. Camera shortcuts pause while a menu, handoff or reference screen is open.\n\n[color=#e3b75c][b]KEYBOARD AND GAMEPAD[/b][/color]\nThe highlighted control has focus. Use Tab or the directional buttons to move between choices, Enter/Space to activate, and Escape/Cancel to close an open panel. The title and in-match menus focus a primary action when they open.\n\n[color=#e3b75c][b]DATASHEET AND SCOPE[/b][/color]\nDatasheet shows the selected match profile. Ability Rules may include text from an optional verified local source; Implemented Scope describes behavior the game supports. Source text alone does not mean an ability is implemented.\n\n[color=#e3b75c][b]LOCAL SETTINGS[/b][/color]\nOpen Settings to choose window mode, resolution, interface size, keyboard bindings and local presentation options. Select a binding, press an unmodified key and choose Apply to save. Escape cancels key capture; Revert returns to the last applied values.\n\n[color=#e3b75c][b]MATCH STATE[/b][/color]\nReading the guide does not create a match or change saved game state. During LAN play, local reference screens do not pause the other player's match."
	title_guide_scroll.add_child(guide)
	title_guide_scroll.add_child(WeaponKeywordHelp.new())

func _build_mission_overview() -> void:
	mission_overview_scroll = ScrollContainer.new()
	mission_overview_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mission_overview_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_overview_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mission_overview_scroll.visible = false
	tactical_overlay_body.add_child(mission_overview_scroll)
	mission_overview_text = RichTextLabel.new()
	mission_overview_text.fit_content = true
	mission_overview_text.scroll_active = false
	mission_overview_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_overview_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_overview_text.add_theme_font_size_override("normal_font_size", 16)
	mission_overview_text.add_theme_color_override("default_color", Color("edf1f2"))
	mission_overview_scroll.add_child(mission_overview_text)

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

func _build_army_panel(layer: CanvasLayer) -> void:
	army_panel = PanelContainer.new()
	army_panel.name = "ArmyPanel"
	army_panel.visible = false
	army_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("10171d", 0.96)
	panel_style.border_color = Color("586b78")
	panel_style.set_border_width_all(1)
	panel_style.border_width_right = 3
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	army_panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(army_panel)
	var shell := VBoxContainer.new()
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_theme_constant_override("separation", 6)
	army_panel.add_child(shell)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 6)
	shell.add_child(title_row)
	var title := Label.new()
	title.text = "ARMY"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("f2df83"))
	title.tooltip_text = "Selected model and the active player's units. Choosing a row selects that model only."
	title_row.add_child(title)
	army_models_button = Button.new()
	army_models_button.text = "Models"
	army_models_button.tooltip_text = "Hide the models listed under every unit."
	army_models_button.pressed.connect(_toggle_army_models)
	title_row.add_child(army_models_button)
	var army_hide := Button.new()
	army_hide.text = "Hide"
	army_hide.tooltip_text = "Hide the army list and the selected model card. Army on the top bar brings them back."
	army_hide.pressed.connect(_hide_army_panel)
	title_row.add_child(army_hide)
	var roster_scroll := ScrollContainer.new()
	roster_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	roster_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shell.add_child(roster_scroll)
	army_roster = ArmyList.new()
	army_roster.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_scroll.add_child(army_roster)
	army_roster.model_chosen.connect(_choose_roster_model)
	army_roster.folds_changed.connect(_sync_army_models_button)
	# Selected-model inspection belongs below the scrollable army, not above it.
	army_card_host = VBoxContainer.new()
	army_card_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.add_child(army_card_host)

func _toggle_army_models() -> void:
	if army_roster == null:
		return
	army_roster.toggle_models()

func _sync_army_models_button(models_hidden: bool) -> void:
	if army_models_button == null:
		return
	army_models_button.text = "Show" if models_hidden else "Models"
	army_models_button.tooltip_text = "Show the models listed under every unit." if models_hidden else "Hide the models listed under every unit."

func _hide_army_panel() -> void:
	army_panel_open = false
	_layout_ui()

func _show_army_panel() -> void:
	army_panel_open = true
	_layout_ui()

func _choose_roster_model(model_id: int) -> void:
	if not state.units.has(model_id):
		return
	get_viewport().set_input_as_handled()
	_clear_placement_feedback()
	selected = model_id
	_set_command_panel_open(true)
	_finish_roster_choice()

func _finish_roster_choice() -> void:
	_refresh_for_selection()
	_focus_selected_unit()

func _place_selection_card() -> void:
	if selection_panel == null:
		return
	if combat_enabled and army_card_host != null:
		if selection_panel.get_parent() != army_card_host:
			selection_panel.reparent(army_card_host)
	elif selection_home != null and selection_panel.get_parent() != selection_home:
		selection_panel.reparent(selection_home)
		selection_home.move_child(selection_panel, mini(selection_home_index, selection_home.get_child_count() - 1))

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
			_clear_board_feedback()
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
	command_panel_title = title
	title.text = "ACTIONS"
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
	tactical_opportunity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tactical_opportunity_label.add_theme_font_size_override("font_size", 12)
	tactical_opportunity_label.add_theme_color_override("font_color", Color("8ad9a7"))
	tactical_opportunity_label.visible = false
	tactical_opportunity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	command_panel_body.add_child(tactical_opportunity_label)
	placement_reason_row = HBoxContainer.new()
	placement_reason_row.add_theme_constant_override("separation", 8)
	placement_reason_row.visible = false
	placement_reason_icon = CombatSymbol.new()
	placement_reason_icon.kind = "Blocked footprint"
	placement_reason_icon.ink = Color("ff766d")
	placement_reason_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	placement_reason_row.add_child(placement_reason_icon)
	placement_reason = Label.new()
	placement_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	placement_reason.add_theme_color_override("font_color", Color("f2b1a0"))
	placement_reason.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	placement_reason_row.add_child(placement_reason)
	command_panel_body.add_child(placement_reason_row)
	placement_details_toggle = Button.new()
	placement_details_toggle.text = "Show other affected models"
	placement_details_toggle.toggle_mode = true
	placement_details_toggle.custom_minimum_size.y = 40
	placement_details_toggle.visible = false
	placement_details_toggle.toggled.connect(_toggle_placement_details)
	command_panel_body.add_child(placement_details_toggle)
	placement_details_label = Label.new()
	placement_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	placement_details_label.add_theme_color_override("font_color", Color("e5d8ce"))
	placement_details_label.visible = false
	command_panel_body.add_child(placement_details_label)

func _show_tactical_screen(content: Control, title: String) -> void:
	var return_focus := tactical_overlay_return_focus
	if tactical_overlay_content != null:
		_close_tactical_screen()
	else:
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner is Control: return_focus = focus_owner
	tactical_overlay_return_focus = return_focus
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
	call_deferred("_focus_tactical_screen", content)

func _find_visible_focus_target(root: Node) -> Control:
	if root is Control:
		var candidate := root as Control
		if candidate != tactical_overlay_close_button and candidate.focus_mode != Control.FOCUS_NONE and candidate.is_visible_in_tree():
			if not (candidate is BaseButton and (candidate as BaseButton).disabled): return candidate
	for child: Node in root.get_children():
		var target := _find_visible_focus_target(child)
		if target != null: return target
	return null

func _focus_tactical_screen(root: Control) -> void:
	if root != tactical_overlay_content or not tactical_overlay.visible: return
	var target := _find_visible_focus_target(root)
	if target == null and tactical_overlay_close_button != null and tactical_overlay_close_button.is_visible_in_tree():
		target = tactical_overlay_close_button
	if target != null: target.grab_focus()

func _restore_tactical_overlay_focus(target: Control) -> void:
	if tactical_overlay != null and tactical_overlay.visible: return
	if _can_receive_tactical_focus(target):
		target.grab_focus()
		return
	if main_menu != null and main_menu.visible:
		main_menu.focus_primary_action()
		return
	if command_panel_body != null and command_panel_body.is_visible_in_tree():
		var fallback := _find_visible_focus_target(command_panel_body)
		if fallback != null:
			fallback.grab_focus()
			return
	if army_panel != null and army_panel.is_visible_in_tree():
		var army_fallback := _find_visible_focus_target(army_panel)
		if army_fallback != null:
			army_fallback.grab_focus()
			return
	if combat_hud != null and combat_hud.menu_button != null and _can_receive_tactical_focus(combat_hud.menu_button):
		combat_hud.menu_button.grab_focus()

func _can_receive_tactical_focus(target: Control) -> bool:
	if not is_instance_valid(target) or not target.is_visible_in_tree() or target.focus_mode == Control.FOCUS_NONE:
		return false
	if target is BaseButton and (target as BaseButton).disabled:
		return false
	return true

func _close_tactical_screen() -> void:
	if tactical_overlay_content == null: return
	_cancel_binding_capture()
	var closing_content := tactical_overlay_content
	var return_focus := tactical_overlay_return_focus
	var hide_overlay_only_content := tactical_overlay_parent == tactical_overlay_body
	if closing_content != settings_panel and is_instance_valid(tactical_overlay_parent):
		closing_content.reparent(tactical_overlay_parent)
		if tactical_overlay_parent == match_tabs and tactical_overlay_index >= 0:
			match_tabs.move_child(closing_content, mini(tactical_overlay_index, match_tabs.get_child_count() - 1))
	elif closing_content == settings_panel and closing_content.get_parent() == tactical_overlay_body:
		# Keep the settings controls owned by the scene. Removing this subtree
		# leaves it detached when the overlay was never opened (or is closed
		# during a headless test), which leaks the entire settings UI at exit.
		settings_panel.visible = false
	if hide_overlay_only_content: closing_content.visible = false
	if closing_content == datasheet_details: datasheet_details.visible = false
	tactical_overlay_content = null
	tactical_overlay_parent = null
	tactical_overlay_index = -1
	tactical_overlay_return_focus = null
	tactical_overlay.visible = false
	_layout_ui()
	_refresh()
	# A keyboard-opened overlay can start without an existing GUI focus owner.
	# Always run the shared restore path so it can choose the menu or command fallback.
	call_deferred("_restore_tactical_overlay_focus", return_focus)

func _open_history_screen() -> void:
	if not combat_enabled or history_scroll == null: return
	_show_tactical_screen(history_scroll, "BATTLE LOG  /  EVENTS + D6")

func _open_help_screen() -> void:
	if help_scroll == null: return
	_show_tactical_screen(help_scroll, "FIELD GUIDE  /  HELP")
	for control: Control in [health_overlay_toggle, board_feedback_toggle, auto_frame_toggle, log_toggle, event_log]:
		control.visible = false

func _open_title_field_guide() -> void:
	if title_guide_scroll == null: return
	_show_tactical_screen(title_guide_scroll, "FIELD GUIDE  /  BEFORE YOU PLAY")

func _open_saved_results() -> void:
	if saved_results_browser == null: return
	saved_results_browser.refresh_records()
	_show_tactical_screen(saved_results_browser, "SAVED RESULTS  /  LOCAL MATCHES")

func _open_saved_matches() -> void:
	if saved_matches_browser == null: return
	var local_match_can_save: bool = combat_enabled and mode != "client" and state.get("phase", "") != "army_selection"
	saved_matches_browser.set_context(not combat_enabled, local_match_can_save, active_save_slot)
	_show_tactical_screen(saved_matches_browser, "SAVED MATCHES  /  LOCAL SLOTS")

func _open_mission_overview() -> void:
	if not combat_enabled or mission_overview_scroll == null: return
	_refresh_mission_overview_text()
	_show_tactical_screen(mission_overview_scroll, "MISSION  /  OBJECTIVES + CONTROL")

func _refresh_mission_overview_text() -> void:
	if mission_overview_text == null: return
	var previous_scroll := mission_overview_scroll.scroll_vertical
	mission_overview_text.text = _mission_overview_copy()
	mission_overview_scroll.scroll_vertical = previous_scroll

func _mission_overview_copy() -> String:
	var mission: Dictionary = state.get("mission", {})
	var lines: Array[String] = ["MISSION STATUS"]
	if Combat.Mission.enabled(state):
		lines.append("CA 2026-27 · %s · Hammer and Anvil" % str(mission.get("name", "Primary mission")))
		lines.append("Score: P1 %d VP · P2 %d VP" % [int(mission.get("scores", {}).get(1, 0)), int(mission.get("scores", {}).get(2, 0))])
		var primary_names: Dictionary = mission.get("primary_names", {})
		lines.append("Primary cards: P1 %s · P2 %s" % [str(primary_names.get(1, primary_names.get("1", "Primary"))), str(primary_names.get(2, primary_names.get("2", "Primary")))])
		lines.append("Primary: %d / %d VP · fixed secondaries: %d / %d VP" % [int(mission.get("primary", {}).get(1, 0)), int(mission.get("primary", {}).get(2, 0)), int(mission.get("secondary", {}).get(1, 0)), int(mission.get("secondary", {}).get(2, 0))])
		var card_scores: Dictionary = mission.get("cards", {})
		var p1_card_scores: Dictionary = card_scores.get(1, {})
		var p2_card_scores: Dictionary = card_scores.get(2, {})
		for card: String in mission.get("secondary_cards", []):
			var card_name := str(Combat.Mission.SECONDARY_CARD_NAMES.get(card, card))
			lines.append("%s: P1 %d VP · P2 %d VP" % [card_name, int(p1_card_scores.get(card, 0)), int(p2_card_scores.get(card, 0))])
	elif Combat.Objectives.training(state):
		lines.append("Custom objective training · round %d / %d" % [int(state.get("round", 0)), int(mission.get("rounds", 5))])
		lines.append("Score: P1 %d VP · P2 %d VP" % [int(mission.get("scores", {}).get(1, 0)), int(mission.get("scores", {}).get(2, 0))])
		lines.append("Each controlled objective scores %d VP at the end of a battle round." % int(mission.get("points_per_objective", 1)))
		var round_events := _recent_training_round_events()
		if not round_events.is_empty():
			lines.append("")
			lines.append("RECENT ROUND SCORES · NEWEST FIRST")
			lines.append_array(round_events)
	else:
		lines.append("This exercise does not use objective scoring.")

	var objectives: Array = mission.get("objectives", [])
	if not objectives.is_empty():
		lines.append("")
		lines.append("OBJECTIVE CONTROL")
		for objective_index in range(objectives.size()):
			var objective: Dictionary = objectives[objective_index]
			var levels: Dictionary = objective.get("levels", {1: 0, 2: 0})
			var controller := int(objective.get("controller", 0))
			var control_text := "Neutral" if controller == 0 else "Controlled by Player %d" % controller
			var secured := int(objective.get("secured", 0))
			if secured in [1, 2]: control_text += " · Secured for Player %d" % secured
			var objective_name := str(objective.get("name", "Objective"))
			var target_owners: Array[String] = []
			if Combat.Mission.enabled(state): target_owners = Combat.Mission.tempting_target_owners(state, objective_name)
			if not target_owners.is_empty(): control_text += " · Tempting Target for " + ", ".join(target_owners)
			var vowed_owners: Array[int] = []
			if combat_enabled: vowed_owners = Combat.VowedTarget.owners_of_objective(state, objective_index)
			if not vowed_owners.is_empty(): control_text += " · Vowed by " + "/".join(vowed_owners.map(func(owner: int) -> String: return "P%d" % owner))
			lines.append("%s — %s\nP1 OC %d · P2 OC %d" % [objective_name, control_text, int(levels.get(1, 0)), int(levels.get(2, 0))])
		lines.append("")
		lines.append("Control and OC are the latest resolved phase values. Movement previews do not update them; control is recalculated at the next phase boundary.")
	if Combat.Mission.enabled(state):
		lines.append("")
		lines.append("RECENT SCORING EVENTS · NEWEST FIRST")
		var mission_log: Array = mission.get("log", [])
		var shown_events := 0
		for index in range(mission_log.size() - 1, -1, -1):
			var event_text := str(mission_log[index])
			if " VP" not in event_text: continue
			lines.append("• " + event_text)
			shown_events += 1
			if shown_events >= 5: break
		if shown_events == 0: lines.append("No mission score recorded yet.")
	return "\n".join(lines)

func _recent_training_round_events() -> Array[String]:
	var events: Array[String] = []
	var match_events: Array = state.get("events", [])
	for index in range(match_events.size() - 1, -1, -1):
		var event: Dictionary = match_events[index]
		var message := str(event.get("message", ""))
		if not message.begins_with("Training round "): continue
		events.append("• " + message)
		if events.size() >= 5: break
	return events

func _open_settings_screen() -> void:
	_sync_settings_from_applied()
	_show_tactical_screen(settings_panel, "SETTINGS  /  DISPLAY + CONTROLS")

func _save_from_match_menu() -> void:
	if mode == "client":
		main_menu.show_status("The host is responsible for saving the match.")
		return
	if state.get("phase", "") == "army_selection":
		main_menu.show_status("Complete both army selections before saving.")
		return
	_open_saved_matches()

func _build_settings_panel() -> void:
	settings_panel = VBoxContainer.new()
	settings_panel.add_theme_constant_override("separation", 10)
	settings_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_panel.visible = false
	tactical_overlay_body.add_child(settings_panel)
	settings_scroll = ScrollContainer.new()
	settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	settings_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_panel.add_child(settings_scroll)
	settings_content = VBoxContainer.new()
	settings_content.add_theme_constant_override("separation", 10)
	settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_scroll.add_child(settings_content)
	control_draft = _read_control_bindings_from_input_map()
	var intro := Label.new()
	intro.text = "Local preferences. Changing these settings does not alter match rules or state. An open LAN match continues."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_content.add_child(intro)
	var display_heading := Label.new()
	display_heading.text = "DISPLAY"
	display_heading.add_theme_color_override("font_color", Color("e3b75c"))
	settings_content.add_child(display_heading)
	var display_row := HBoxContainer.new()
	display_row.add_theme_constant_override("separation", 12)
	settings_content.add_child(display_row)
	display_mode_picker = OptionButton.new()
	display_mode_picker.add_item("Windowed", Window.MODE_WINDOWED)
	display_mode_picker.add_item("Borderless fullscreen", Window.MODE_FULLSCREEN)
	display_mode_picker.add_item("Exclusive fullscreen", Window.MODE_EXCLUSIVE_FULLSCREEN)
	display_mode_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	display_row.add_child(display_mode_picker)
	resolution_picker = OptionButton.new()
	for resolution: Vector2i in _display_resolution_choices():
		resolution_picker.add_item("%d × %d" % [resolution.x, resolution.y], resolution.x)
	resolution_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	display_row.add_child(resolution_picker)
	var scale_row := HBoxContainer.new()
	scale_row.add_theme_constant_override("separation", 12)
	settings_content.add_child(scale_row)
	var scale_label := Label.new()
	scale_label.text = "Interface size"
	scale_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_row.add_child(scale_label)
	ui_scale_picker = OptionButton.new()
	ui_scale_picker.tooltip_text = "Scales the 2D interface, including text and controls. The 3D tabletop keeps its size."
	for percentage: int in _ui_scale_percentages():
		ui_scale_picker.add_item("%d%%" % percentage, percentage)
	ui_scale_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_row.add_child(ui_scale_picker)
	var controls_header := HBoxContainer.new()
	controls_header.add_theme_constant_override("separation", 8)
	settings_content.add_child(controls_header)
	var controls_heading := Label.new()
	controls_heading.text = "KEYBOARD CONTROLS"
	controls_heading.add_theme_color_override("font_color", Color("e3b75c"))
	controls_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_header.add_child(controls_heading)
	var reset_controls := Button.new()
	reset_controls.text = "Reset controls"
	reset_controls.tooltip_text = "Stage the default keyboard bindings. Apply to save them."
	reset_controls.pressed.connect(_reset_control_bindings)
	controls_header.add_child(reset_controls)
	var controls_note := Label.new()
	controls_note.text = "Choose an unmodified key. If another listed action already uses it, those two bindings swap. Apply saves; Escape cancels capture."
	controls_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_note.add_theme_color_override("font_color", Color("9da9b0"))
	settings_content.add_child(controls_note)
	for action: String in REBINDABLE_ACTIONS:
		var binding_row := HBoxContainer.new()
		binding_row.add_theme_constant_override("separation", 8)
		settings_content.add_child(binding_row)
		var binding_label := Label.new()
		binding_label.text = str(CONTROL_BINDING_LABELS[action])
		binding_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		binding_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		binding_row.add_child(binding_label)
		var binding_button := Button.new()
		binding_button.custom_minimum_size = Vector2(128, 36)
		binding_button.pressed.connect(_start_binding_capture.bind(action))
		binding_row.add_child(binding_button)
		settings_binding_buttons[action] = binding_button
	_update_control_binding_buttons()
	var options_heading := Label.new()
	options_heading.text = "BOARD + DICE PRESENTATION"
	options_heading.add_theme_color_override("font_color", Color("e3b75c"))
	settings_content.add_child(options_heading)
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
		settings_content.add_child(toggle)
		settings_toggles[str(entry.key)] = toggle
	var audio_note := Label.new()
	audio_note.text = "Combat cues are optional. The confirm tick and the destruction or Hazardous tone use this toggle, and both stay silent when reduced motion is on. Dice and outcomes remain visible when muted."
	audio_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	audio_note.add_theme_color_override("font_color", Color("9da9b0"))
	settings_content.add_child(audio_note)
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
	_capture_applied_display()
	_refresh_control_hints()

func _source_presentation_toggle(source_key: String) -> CheckButton:
	return get(source_key) as CheckButton

func _display_resolution_choices() -> Array[Vector2i]:
	return [Vector2i(1024, 768), Vector2i(1280, 800), Vector2i(1600, 900), Vector2i(1920, 1080)]

func _ui_scale_percentages() -> Array[int]:
	return [100, 110, 120]

func _supported_ui_scale_percent(value: Variant) -> int:
	if typeof(value) == TYPE_INT and int(value) in _ui_scale_percentages():
		return int(value)
	return 100

func _supported_display_mode(value: Variant) -> int:
	if typeof(value) == TYPE_INT and int(value) in [Window.MODE_WINDOWED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]:
		return int(value)
	return Window.MODE_WINDOWED

func _read_control_bindings_from_input_map() -> Dictionary:
	var bindings: Dictionary = {}
	for action: String in REBINDABLE_ACTIONS:
		var action_name := StringName(action)
		var keycode := int(DEFAULT_CONTROL_BINDINGS[action])
		for input_event: InputEvent in InputMap.action_get_events(action_name):
			if input_event is InputEventKey:
				var key_event := input_event as InputEventKey
				var mapped_key := int(key_event.physical_keycode)
				if mapped_key == 0: mapped_key = int(key_event.keycode)
				if mapped_key > 0:
					keycode = mapped_key
					break
		bindings[action] = keycode
	return bindings

func _control_key_label(keycode: int) -> String:
	var label := OS.get_keycode_string(keycode)
	return label if not label.is_empty() else str(keycode)

func _draft_action_for_key(keycode: int, except_action: String) -> String:
	for other_action: String in REBINDABLE_ACTIONS:
		if other_action != except_action and int(control_draft.get(other_action, 0)) == keycode:
			return other_action
	return ""

func _is_supported_control_key(keycode: int) -> bool:
	if keycode <= 0:
		return false
	return keycode not in [KEY_ESCAPE, KEY_TAB, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]

func _validated_control_bindings(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var source: Dictionary = value
	var bindings: Dictionary = {}
	for action: String in REBINDABLE_ACTIONS:
		var key_value: Variant = source.get(action, null)
		if typeof(key_value) != TYPE_INT or not _is_supported_control_key(int(key_value)):
			return {}
		var keycode := int(key_value)
		if keycode in bindings.values():
			return {}
		bindings[action] = keycode
	for action: String in REBINDABLE_ACTIONS:
		var conflict := _external_control_binding_conflict(int(bindings[action]))
		if not conflict.is_empty():
			return {}
	return bindings

func _external_control_binding_conflict(keycode: int) -> String:
	for mapped_action: StringName in InputMap.get_actions():
		var mapped_name := str(mapped_action)
		if mapped_name in REBINDABLE_ACTIONS:
			continue
		for input_event: InputEvent in InputMap.action_get_events(mapped_action):
			if not input_event is InputEventKey:
				continue
			var key_event := input_event as InputEventKey
			if key_event.shift_pressed or key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed:
				continue
			if int(key_event.physical_keycode) == keycode or int(key_event.keycode) == keycode:
				return mapped_name
	return ""

func _apply_control_bindings(bindings: Dictionary) -> void:
	for action: String in REBINDABLE_ACTIONS:
		var action_name := StringName(action)
		for input_event: InputEvent in InputMap.action_get_events(action_name):
			if input_event is InputEventKey:
				InputMap.action_erase_event(action_name, input_event)
		var keycode := int(bindings.get(action, DEFAULT_CONTROL_BINDINGS[action]))
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		key_event.keycode = keycode
		InputMap.action_add_event(action_name, key_event)
	control_draft = bindings.duplicate(true)
	_update_control_binding_buttons()
	_refresh_control_hints()

func _update_control_binding_buttons() -> void:
	for action: String in settings_binding_buttons:
		var button: Button = settings_binding_buttons[action]
		button.text = "Press a key…" if pending_binding_action == action else _control_key_label(int(control_draft.get(action, DEFAULT_CONTROL_BINDINGS[action])))
		button.tooltip_text = "Press to change this binding. Unmodified keys swap with another listed action; menu controls stay reserved. Escape cancels."

func _start_binding_capture(action: String) -> void:
	if action not in REBINDABLE_ACTIONS:
		return
	pending_binding_action = action
	_update_control_binding_buttons()
	settings_notice.text = "Press an unmodified key for %s. Escape cancels; keys used by reserved menu controls are unavailable." % str(CONTROL_BINDING_LABELS[action])
	if settings_binding_buttons.has(action):
		(settings_binding_buttons[action] as Button).grab_focus()

func _cancel_binding_capture(show_notice: bool = false) -> void:
	if pending_binding_action.is_empty():
		return
	pending_binding_action = ""
	_update_control_binding_buttons()
	if show_notice and settings_notice != null:
		settings_notice.text = "Key capture cancelled."

func _handle_pending_control_binding(event: InputEvent) -> bool:
	if pending_binding_action.is_empty():
		return false
	if event.is_action_pressed("ui_cancel"):
		_cancel_binding_capture(true)
		return true
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return true
	if key_event.shift_pressed or key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed:
		settings_notice.text = "Choose one unmodified key. Escape cancels capture."
		return true
	var keycode := int(key_event.physical_keycode)
	if keycode == 0: keycode = int(key_event.keycode)
	if not _is_supported_control_key(keycode):
		settings_notice.text = "That key is reserved for menu navigation. Choose another key."
		return true
	var conflict := _external_control_binding_conflict(keycode)
	if not conflict.is_empty():
		settings_notice.text = "%s is already used by %s. Choose another key." % [_control_key_label(keycode), conflict]
		return true
	var changed_action := pending_binding_action
	var old_keycode := int(control_draft.get(changed_action, DEFAULT_CONTROL_BINDINGS[changed_action]))
	var other_action := _draft_action_for_key(keycode, changed_action)
	if not other_action.is_empty():
		control_draft[changed_action] = keycode
		control_draft[other_action] = old_keycode
		pending_binding_action = ""
		_update_control_binding_buttons()
		settings_notice.text = "%s and %s swapped (%s ↔ %s). Apply to save the new controls." % [str(CONTROL_BINDING_LABELS[changed_action]), str(CONTROL_BINDING_LABELS[other_action]), _control_key_label(keycode), _control_key_label(old_keycode)]
		return true
	control_draft[changed_action] = keycode
	pending_binding_action = ""
	_update_control_binding_buttons()
	settings_notice.text = "%s is staged. Apply to save the new controls; Revert restores the last applied bindings." % _control_key_label(keycode)
	return true

func _reset_control_bindings() -> void:
	_cancel_binding_capture()
	control_draft = DEFAULT_CONTROL_BINDINGS.duplicate(true)
	_update_control_binding_buttons()
	settings_notice.text = "Default controls are staged. Apply to save them."

func _capture_applied_display() -> void:
	var window := get_window()
	applied_display_settings = {
		"mode": window.mode,
		"size": window.size,
		"ui_scale_percent": int(round(window.content_scale_factor * 100.0)),
		"presentation": {},
		"controls": _read_control_bindings_from_input_map(),
	}
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		applied_display_settings.presentation[key] = source.button_pressed if source != null else false

func _sync_settings_from_applied() -> void:
	if settings_toggles.is_empty(): return
	display_mode_picker.select(maxi(0, display_mode_picker.get_item_index(int(applied_display_settings.get("mode", Window.MODE_WINDOWED)))))
	var size: Vector2i = applied_display_settings.get("size", Vector2i(1280, 800))
	if size not in _display_resolution_choices(): size = Vector2i(1280, 800)
	resolution_picker.select(maxi(0, resolution_picker.get_item_index(size.x)))
	var scale_percent := _supported_ui_scale_percent(applied_display_settings.get("ui_scale_percent", 100))
	ui_scale_picker.select(maxi(0, ui_scale_picker.get_item_index(scale_percent)))
	for key: String in settings_toggles:
		settings_toggles[key].set_pressed_no_signal(bool(applied_display_settings.get("presentation", {}).get(key, true)))
	control_draft = applied_display_settings.get("controls", DEFAULT_CONTROL_BINDINGS).duplicate(true)
	_update_control_binding_buttons()
	settings_notice.text = control_settings_warning

func _apply_ui_preferences() -> void:
	if not pending_binding_action.is_empty():
		settings_notice.text = "Finish the key choice or press Escape before applying settings."
		return
	var validated_bindings := _validated_control_bindings(control_draft)
	if validated_bindings.is_empty():
		settings_notice.text = "Keyboard bindings conflict with each other or menu controls. Reset controls or choose different keys."
		return
	var selected_mode := display_mode_picker.get_selected_id()
	var resolution_width := resolution_picker.get_selected_id()
	var scale_percent := _supported_ui_scale_percent(ui_scale_picker.get_selected_id())
	var resolutions := {}
	for resolution: Vector2i in _display_resolution_choices(): resolutions[resolution.x] = resolution
	var window := get_window()
	window.mode = _supported_display_mode(selected_mode)
	if window.mode == Window.MODE_WINDOWED: window.size = resolutions.get(resolution_width, Vector2i(1280, 800))
	window.content_scale_factor = float(scale_percent) / 100.0
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		if source != null: source.button_pressed = toggle.button_pressed
	_apply_control_bindings(validated_bindings)
	_capture_applied_display()
	var save_error := _save_ui_preferences()
	if save_error == OK: control_settings_warning = ""
	settings_notice.text = "Applied and saved on this computer." if save_error == OK else "Applied, but local preferences could not be saved (%s)." % error_string(save_error)
	_layout_ui()
	_layout_tactical_overlay()

func _revert_ui_preferences() -> void:
	if applied_display_settings.is_empty(): return
	_cancel_binding_capture()
	var window := get_window()
	window.mode = int(applied_display_settings.mode)
	window.size = applied_display_settings.size
	window.content_scale_factor = float(_supported_ui_scale_percent(applied_display_settings.get("ui_scale_percent", 100))) / 100.0
	for key: String in settings_toggles:
		var toggle: CheckButton = settings_toggles[key]
		var source := _source_presentation_toggle(str(toggle.get_meta("source_key")))
		var pressed := bool(applied_display_settings.presentation.get(key, true))
		toggle.set_pressed_no_signal(pressed)
		if source != null: source.button_pressed = pressed
	_apply_control_bindings(applied_display_settings.get("controls", DEFAULT_CONTROL_BINDINGS))
	_sync_settings_from_applied()
	settings_notice.text = "Reverted to the last applied preferences."
	if not control_settings_warning.is_empty():
		settings_notice.text += " " + control_settings_warning
	_layout_ui()
	_layout_tactical_overlay()

func _save_ui_preferences() -> Error:
	screen_settings.set_value("display", "mode", int(get_window().mode))
	screen_settings.set_value("display", "width", get_window().size.x)
	screen_settings.set_value("display", "height", get_window().size.y)
	var ui_scale_percent := _supported_ui_scale_percent(int(round(get_window().content_scale_factor * 100.0)))
	screen_settings.set_value("display", "ui_scale_percent", ui_scale_percent)
	var presentation: Dictionary = {}
	for key: String in settings_toggles: presentation[key] = bool(settings_toggles[key].button_pressed)
	screen_settings.set_value("presentation", "options", presentation)
	screen_settings.set_value("presentation", "combat_speed", combat_tray.speed.selected)
	screen_settings.set_value("controls", "bindings", _read_control_bindings_from_input_map())
	return screen_settings.save(ui_preferences_path)

func _load_ui_preferences() -> void:
	if screen_settings.load(ui_preferences_path) != OK: return
	var saved_speed: Variant = screen_settings.get_value("presentation", "combat_speed", 0)
	var speed_index := int(saved_speed) if typeof(saved_speed) == TYPE_INT else 0
	combat_tray.speed.select(clampi(speed_index, 0, 2))
	var window := get_window()
	var mode_value: Variant = screen_settings.get_value("display", "mode", Window.MODE_WINDOWED)
	window.mode = _supported_display_mode(mode_value)
	var saved_scale: Variant = screen_settings.get_value("display", "ui_scale_percent", 100)
	var scale_percent := _supported_ui_scale_percent(saved_scale)
	window.content_scale_factor = float(scale_percent) / 100.0
	var saved_width: Variant = screen_settings.get_value("display", "width", window.size.x)
	var saved_height: Variant = screen_settings.get_value("display", "height", window.size.y)
	var current_size := window.size if window.size in _display_resolution_choices() else Vector2i(1280, 800)
	var saved_size := current_size
	if typeof(saved_width) == TYPE_INT and typeof(saved_height) == TYPE_INT:
		var requested_size := Vector2i(int(saved_width), int(saved_height))
		if requested_size in _display_resolution_choices(): saved_size = requested_size
	if window.mode == Window.MODE_WINDOWED: window.size = saved_size
	if ui_scale_picker != null:
		ui_scale_picker.select(maxi(0, ui_scale_picker.get_item_index(scale_percent)))
	var saved_presentation: Variant = screen_settings.get_value("presentation", "options", {})
	var presentation: Dictionary = saved_presentation if typeof(saved_presentation) == TYPE_DICTIONARY else {}
	for key: String in settings_toggles:
		var saved_value: Variant = presentation.get(key, settings_toggles[key].button_pressed)
		var pressed: bool = bool(saved_value) if typeof(saved_value) == TYPE_BOOL else settings_toggles[key].button_pressed
		settings_toggles[key].set_pressed_no_signal(pressed)
		var source := _source_presentation_toggle(str(settings_toggles[key].get_meta("source_key")))
		if source != null: source.button_pressed = pressed
	var has_saved_bindings := screen_settings.has_section_key("controls", "bindings")
	var saved_bindings: Variant = screen_settings.get_value("controls", "bindings", DEFAULT_CONTROL_BINDINGS)
	var loaded_bindings := _validated_control_bindings(saved_bindings)
	control_settings_warning = ""
	if has_saved_bindings and loaded_bindings.is_empty():
		control_settings_warning = "Saved keyboard bindings were invalid or conflicting; defaults were loaded. Apply to save them."
	_apply_control_bindings(loaded_bindings if not loaded_bindings.is_empty() else DEFAULT_CONTROL_BINDINGS)
	_capture_applied_display()

func _refresh_control_hints() -> void:
	var bindings := _read_control_bindings_from_input_map()
	var inspect_key := _control_key_label(int(bindings.get(INPUT_INSPECT_DATASHEET, KEY_I)))
	var focus_key := _control_key_label(int(bindings.get(INPUT_FOCUS_SELECTED_UNIT, KEY_F)))
	var pan_up := _control_key_label(int(bindings.get(INPUT_CAMERA_PAN_UP, KEY_W)))
	var pan_down := _control_key_label(int(bindings.get(INPUT_CAMERA_PAN_DOWN, KEY_S)))
	var pan_left := _control_key_label(int(bindings.get(INPUT_CAMERA_PAN_LEFT, KEY_A)))
	var pan_right := _control_key_label(int(bindings.get(INPUT_CAMERA_PAN_RIGHT, KEY_D)))
	if datasheet_button != null:
		datasheet_button.tooltip_text = "Inspect the selected match profile. Keyboard shortcut: %s." % inspect_key
	if combat_hud != null and combat_hud.has_method("set_focus_binding_label"):
		combat_hud.set_focus_binding_label(focus_key)
	if controls_help != null:
		controls_help.text = "Left: select miniature • Right: move / target\nWheel: zoom • Middle drag: orbit\nPan: Up %s • Down %s • Left %s • Right %s\nFocus %s • Datasheet %s" % [pan_up, pan_down, pan_left, pan_right, focus_key, inspect_key]

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
		"reaction": {"title": "Decision window", "controls": [reaction_help, reaction_roll, reaction_use_row, reaction_use, reaction_sudden_row, reaction_sudden, reaction_dice_hint, reaction_dice, reaction_squad]},
		"deployment": {"title": "Deploy", "controls": [deployment_help, deployment_preset_button, deployment_confirm_button]},
		"movement": {"title": "Move", "controls": [movement_choice, movement_elevation_choice, sudden_onslaught_choice, take_to_skies_choice, movement_choices, begin_move_button, escape_wound_button, finish_move_button, cancel_move_button, abandon_move_button, coherency_button]},
		"contact": {"title": "Charge / fight", "controls": [charge_targets, charge_button, take_to_skies_charge_choice, begin_contact_button, tactical_focus_button, consolidation_objective, contact_enemy, contact_elevation_choice, confirm_contact_button, cancel_contact_button]},
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
		reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reason.max_lines_visible = 4
		reason.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		reason.add_theme_color_override("font_color", Color("f2b1a0"))
		reason.visible = false
		group.add_child(reason)
		for control: Control in definitions[key].controls:
			if control.get_parent() == column: control.reparent(group)
		action_groups[key] = {"container": group, "reason": reason, "controls": definitions[key].controls}
		if key in ["contact", "objectives"]: group.move_child(reason, -1)
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
			for ability: Dictionary in _available_unit_choices(_local_player()):
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
		group.container.visible = has_controls and (exclusive.is_empty() or exclusive == key or (key == "unit" and exclusive == "reaction" and not _available_unit_choices(_local_player()).is_empty()))
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
	elif _match_actor() != _local_player(): common = "Waiting for player %d to make this decision." % _match_actor()
	if not common.is_empty():
		for key: String in action_groups:
			if action_groups[key].container.visible: _action_reason(key, common)
		return
	if state.phase == "deployment":
		var objective_choice_pending := false
		for ability: Dictionary in _available_unit_choices(_local_player()):
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
		_action_reason("movement", Combat.movement_choice_error_after_command(state, _local_player(), selected, MOVE_TYPES[movement_choice.selected], _ui_command_error(_local_player())))
	if finish_move_button.visible and finish_move_button.disabled:
		var reason := "The unit must end movement coherent and outside enemy engagement range."
		if escape_wound_button.visible: reason = "Allocate the remaining escape wounds before confirming movement."
		if not state.pending_move.is_empty() and Combat.UnitActions.TargetAuguryWeb.start_decision_pending(state, int(state.pending_move.get("squad", -1))): reason = "Choose a Target Augury Web Vehicle or pass before confirming movement."
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

func _promote_primary_actions() -> void:
	for key: String in action_groups:
		var group: Dictionary = action_groups[key]
		var container: VBoxContainer = group.container
		if not container.visible: continue
		var chosen: Button = null
		var fallback: Button = null
		for control: Control in group.controls:
			if control is OptionButton or control is CheckBox or control is CheckButton: continue
			if not control is Button or not control.visible: continue
			var button := control as Button
			if fallback == null: fallback = button
			if not button.disabled:
				chosen = button
				break
		var primary := chosen if chosen != null else fallback
		if primary == null: continue
		var anchor: Node = primary
		while anchor.get_parent() != container and anchor.get_parent() != null:
			anchor = anchor.get_parent()
		if anchor.get_parent() != container: continue
		container.move_child(anchor, mini(1, container.get_child_count() - 1))
		var reason: Control = group.reason
		if reason.get_parent() == container:
			container.move_child(reason, mini(anchor.get_index() + 1, container.get_child_count() - 1))

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
			var error := Combat.movement_choice_error_after_command(state, _local_player(), model, move_type, _ui_command_error(_local_player()))
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
	action_unit_picker.disabled = _match_actor() != player or state.test_winner != 0 or (mode == "host" and guest_id == 0)
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
	_refresh_for_selection()

func _selected_movement_elevation() -> float:
	if movement_elevation_choice == null or movement_elevation_choice.selected < 0: return 0.0
	var value: Variant = movement_elevation_choice.get_item_metadata(movement_elevation_choice.selected)
	return float(value) if value is int or value is float else 0.0

func _selected_contact_elevation() -> float:
	if contact_elevation_choice != null and contact_elevation_choice.selected >= 0:
		var value: Variant = contact_elevation_choice.get_item_metadata(contact_elevation_choice.selected)
		if value is int or value is float: return float(value)
	return float(state.units[selected].get("elevation", 0.0)) if state.units.has(selected) else 0.0

func _refresh_contact_elevation_options() -> void:
	if contact_elevation_choice == null: return
	var preferred := float(state.units[selected].get("elevation", 0.0)) if state.units.has(selected) else 0.0
	if contact_elevation_model == selected and contact_elevation_choice.selected >= 0:
		var selected_value: Variant = contact_elevation_choice.get_item_metadata(contact_elevation_choice.selected)
		if selected_value is int or selected_value is float: preferred = float(selected_value)
	contact_elevation_choice.clear()
	var move: Dictionary = state.get("pending_contact", {})
	if not combat_enabled or move.is_empty() or not state.units.has(selected) or not move.get("origins", {}).has(selected):
		contact_elevation_choice.visible = false
		contact_elevation_model = -1
		return
	var options: Array[Dictionary] = Combat.Terrain.movement_surface_options(state, state.units[selected])
	var selected_index := 0
	for option: Dictionary in options:
		contact_elevation_choice.add_item("%s · %s in" % [str(option.name), _stat_text(option.elevation)])
		var index := contact_elevation_choice.item_count - 1
		contact_elevation_choice.set_item_metadata(index, float(option.elevation))
		contact_elevation_choice.set_item_tooltip(index, "End this model's contact move at %s. Vertical travel counts unless this move ignores vertical distance." % str(option.name))
		if absf(float(option.elevation) - preferred) <= 0.001: selected_index = index
	contact_elevation_choice.select(selected_index)
	contact_elevation_choice.visible = options.size() > 1 and state.units[selected].owner == _local_player()
	contact_elevation_choice.disabled = _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
	contact_elevation_model = selected

func _refresh_movement_elevation_options() -> void:
	if movement_elevation_choice == null: return
	var preferred := 0.0
	if movement_elevation_model == selected and movement_elevation_choice.selected >= 0:
		var selected_value: Variant = movement_elevation_choice.get_item_metadata(movement_elevation_choice.selected)
		if selected_value is int or selected_value is float: preferred = float(selected_value)
	elif state.units.has(selected):
		preferred = float(state.units[selected].get("elevation", 0.0))
	movement_elevation_choice.clear()
	if not combat_enabled or not state.units.has(selected):
		movement_elevation_choice.visible = false
		movement_elevation_model = selected
		return
	var options: Array[Dictionary] = Combat.Terrain.movement_surface_options(state, state.units[selected])
	var selected_index := 0
	for option: Dictionary in options:
		movement_elevation_choice.add_item("%s · %s in" % [str(option.name), _stat_text(option.elevation)])
		var index := movement_elevation_choice.item_count - 1
		movement_elevation_choice.set_item_metadata(index, float(option.elevation))
		movement_elevation_choice.set_item_tooltip(index, "End this model's movement at %s. Vertical distance counts toward its movement." % str(option.name))
		if absf(float(option.elevation) - preferred) <= 0.001: selected_index = index
	movement_elevation_choice.select(selected_index)
	movement_elevation_choice.visible = state.phase == "movement" and options.size() > 1 and state.units[selected].owner == _local_player()
	movement_elevation_choice.disabled = _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
	movement_elevation_model = selected

func _refresh_movement_choices() -> void:
	movement_reference.visible = combat_enabled and state.phase == "movement"
	attack_reference.visible = combat_enabled and state.phase in ["shooting", "fight"]
	_refresh_movement_elevation_options()
	if not combat_enabled: return
	var errors: Array[String] = []
	var references: Array[String] = []
	var reference_lines: Array[String] = ["MOVEMENT OPTIONS"]
	# Every movement type shares the same command window, revision and pending
	# decision gate. Evaluate that authoritative gate once, then only perform
	# the move-type-specific checks for each reference row.
	var command_error := _ui_command_error(_local_player())
	if mode == "host" and guest_id == 0: command_error = "Waiting for player 2 to connect."
	for move_type: String in MOVE_TYPES:
		var error := Combat.movement_choice_error_after_command(state, _local_player(), selected, move_type, command_error)
		errors.append(error)
		var reference := KeywordGlossary.describe_move_type(move_type)
		references.append(reference)
		reference_lines.append(reference + ("\nUnavailable now: " + error if not error.is_empty() else "\nAvailable for the selected unit."))
	var choosing: bool = state.pending_move.is_empty()
	var own_model: bool = state.units.has(selected) and state.units[selected].owner == _local_player() and state.units[selected].wounds > 0 and state.units[selected].get("on_battlefield", true)
	var selected_move: String = MOVE_TYPES[movement_choice.selected] if movement_choice.selected >= 0 and movement_choice.selected < MOVE_TYPES.size() else ""
	var selected_squad := int(state.units[selected].get("squad", -1)) if own_model else -1
	var take_skies_draft := _movement_take_to_skies_draft(selected_squad) if own_model else {}
	var pending_take_skies := not take_skies_draft.is_empty()
	var take_skies_available := false
	var selected_move_index := MOVE_TYPES.find(selected_move)
	if own_model and state.phase == "movement" and choosing and command_error.is_empty() and selected_move_index >= 0 and selected_move_index < errors.size():
		take_skies_available = errors[selected_move_index].is_empty() and Combat.Terrain.squad_can_fly(state, selected_squad) and selected_move in ["normal", "advance", "ordered_retreat", "desperate_escape"]
	take_to_skies_choice.visible = take_skies_available or pending_take_skies
	take_to_skies_choice.disabled = not take_skies_available or _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
	if pending_take_skies:
		take_to_skies_choice.set_pressed_no_signal(true)
	elif not take_skies_available:
		take_to_skies_choice.set_pressed_no_signal(false)
	var declaration_text := ""
	if pending_take_skies:
		declaration_text = "TAKE TO THE SKIES DECLARED • " + ("HOVER: no movement reduction" if float(take_skies_draft.get("take_to_skies_penalty", 0.0)) == 0.0 else "maximum move reduced by 2 inches") + " • FLY models pass through all models and terrain"
		reference_lines.append(declaration_text)
	movement_reference.text = "\n\n".join(reference_lines)
	var sudden_available := false
	if own_model and state.phase == "movement" and choosing and selected_move == "advance":
		sudden_available = Combat.DetachmentStratagems.error(state, _local_player(), state.units[selected].squad, Combat.DetachmentStratagems.SUDDEN_ONSLAUGHT).is_empty()
	sudden_onslaught_choice.visible = sudden_available
	sudden_onslaught_choice.disabled = mode == "host" and guest_id == 0
	if not sudden_available: sudden_onslaught_choice.set_pressed_no_signal(false)
	var stage := 1 if own_model else 0
	var message := "Choose a model in the army list or click a miniature."
	if state.phase == "movement" and choosing and not state.units.has(selected):
		selection_card.get_parent().visible = false
		begin_move_button.visible = false
		action_groups.movement.reason.visible = false
	if own_model: message = "Choose a move, then Begin move. Unavailable choices list the reason below."
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
	if _match_actor() != _local_player():
		message = "Waiting for player %d to resolve movement." % _match_actor()
		movement_choices.visible = false
		begin_move_button.visible = false
		sudden_onslaught_choice.visible = false
		take_to_skies_choice.visible = false
		action_groups.phase.reason.visible = false
	movement_choices.configure(movement_choice.selected, errors, references, stage, choosing and own_model, message)

func _movement_take_to_skies_draft(squad: int) -> Dictionary:
	if squad < 0: return {}
	var pending_move: Dictionary = state.get("pending_move", {})
	if int(pending_move.get("squad", -1)) == squad and bool(pending_move.get("take_to_skies", false)): return pending_move
	var mobile_window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(mobile_window.get("action", "")) == "movement" and int(mobile_window.get("squad", -1)) == squad and bool(mobile_window.get("take_to_skies", false)): return mobile_window
	var roll_window: Dictionary = state.get("stratagems", {}).get("pending", {})
	var roll_draft: Dictionary = roll_window.get("draft", {})
	if int(roll_draft.get("squad", -1)) == squad and bool(roll_draft.get("take_to_skies", false)): return roll_draft
	return {}

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
		var charge_squad := int(state.units[selected].get("squad", -1)) if state.units.has(selected) else int(state.pending_charge.get("squad", -1))
		var charge_take_draft := _charge_take_to_skies_draft(charge_squad)
		var charge_take_pending := not charge_take_draft.is_empty()
		var charge_take_available: bool = state.units.has(selected) and state.units[selected].owner == _local_player() and state.pending_charge.is_empty() and state.pending_contact.is_empty() and Combat.Terrain.squad_can_fly(state, charge_squad) and Combat.charge_declaration_error(state, _local_player(), selected, state.revision).is_empty()
		if not charge_take_pending and charge_squad != take_to_skies_charge_draft_squad: take_to_skies_charge_choice.set_pressed_no_signal(false)
		take_to_skies_charge_draft_squad = charge_squad
		var charge_has_hover := Combat.Terrain.squad_has_hover(state, charge_squad)
		take_to_skies_charge_choice.text = "Take to the Skies • HOVER (no −2 in)" if charge_has_hover else "Take to the Skies • −2 in max Charge"
		take_to_skies_charge_choice.visible = charge_take_available or charge_take_pending
		take_to_skies_charge_choice.disabled = not charge_take_available or _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
		if charge_take_pending:
			take_to_skies_charge_choice.set_pressed_no_signal(true)
			var charge_penalty := float(charge_take_draft.get("take_to_skies_penalty", Combat.Terrain.take_to_skies_penalty(state, charge_squad, true)))
			contact_reference.text += "\n\nTAKE TO THE SKIES DECLARED • " + ("HOVER: no maximum-distance reduction" if charge_penalty == 0.0 else "maximum distance reduced by 2 inches") + " • FLY models pass through models and terrain"
		elif charge_take_available and take_to_skies_charge_choice.button_pressed:
			contact_reference.text += "\n\nREADY TO DECLARE TAKE TO THE SKIES • " + ("HOVER: no maximum-distance reduction" if charge_has_hover else "maximum Charge distance reduced by 2 inches for every model")
		elif not charge_take_available:
			take_to_skies_charge_choice.set_pressed_no_signal(false)
		if not state.pending_charge.is_empty():
			stage = 2
			message = "%d\" rolled · mark targets, then Begin placement." % int(state.pending_charge.maximum)
			if not state.pending_charge.targets.is_empty(): stage = 3
			var seen: Array[int] = []
			var blocked_targets: Dictionary = {}
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if unit.owner == _match_actor() or unit.wounds <= 0 or not unit.get("on_battlefield", true) or int(unit.squad) in seen: continue
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
				if not error.is_empty():
					if not blocked_targets.has(error): blocked_targets[error] = []
					blocked_targets[error].append(state.squads[squad].name)
				contact_reference.text += "\n\n%s: %s" % [button.text, error if not error.is_empty() else ("Selected" if button.button_pressed else "Available to select")]
			for squad: int in charge_target_buttons:
				if squad not in seen: charge_target_buttons[squad].visible = false
			var target_notes: Array[String] = []
			for error: String in blocked_targets:
				target_notes.append("%s · %s" % [", ".join(blocked_targets[error]), error])
			charge_target_notes.text = "\n".join(target_notes)
			charge_target_notes.tooltip_text = charge_target_notes.text
			charge_target_notes.visible = not target_notes.is_empty()
			charge_targets.move_child(charge_target_notes, -1)
	else:
		charge_target_notes.visible = false
		take_to_skies_charge_choice.visible = false
		take_to_skies_charge_choice.set_pressed_no_signal(false)
		take_to_skies_charge_draft_squad = -1
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
		message = "Select each model, choose its destination height, then right-click. Confirm when every model is placed."
		var vertical_ignored: bool = (str(state.pending_contact.get("kind", "")) == "charge" and bool(state.pending_contact.get("take_to_skies", false)) and state.units.has(selected) and Combat.Terrain.has_keyword(state.units[selected], ["fly"])) or (state.units.has(selected) and bool(state.squads.get(int(state.units[selected].get("squad", -1)), {}).get("reiver_grapnel_launchers", false)))
		contact_reference.text += "\n\nDESTINATION HEIGHT • " + ("vertical distance is ignored for this model" if vertical_ignored else "vertical distance and supported wall access apply")
		var error := Combat.ContactActions.final_error(state)
		confirm_contact_button.disabled = confirm_contact_button.disabled or not error.is_empty()
		if not error.is_empty():
			_action_reason("contact", error)
			contact_reference.text += "\n\nPlacement blocked: " + error
		else:
			if state.phase == "charge": stage = 4
			message = "Preview valid. Confirm placement, or keep adjusting models."
		charge_button.visible = false
	if mode != "local" and _match_actor() != _local_player():
		message = "Waiting for player %d to resolve this step." % _match_actor()
		charge_targets.visible = false
	contact_flow.configure(steps, stage, message)

func _charge_take_to_skies_draft(squad: int) -> Dictionary:
	if squad < 0: return {}
	var pending_contact: Dictionary = state.get("pending_contact", {})
	if str(pending_contact.get("kind", "")) == "charge" and int(pending_contact.get("squad", -1)) == squad and bool(pending_contact.get("take_to_skies", false)): return pending_contact
	var pending_charge: Dictionary = state.get("pending_charge", {})
	if int(pending_charge.get("squad", -1)) == squad and bool(pending_charge.get("take_to_skies", false)): return pending_charge
	var mobile_window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(mobile_window.get("action", "")) == "charge" and int(mobile_window.get("squad", -1)) == squad and bool(mobile_window.get("take_to_skies", false)): return mobile_window
	var roll_window: Dictionary = state.get("stratagems", {}).get("pending", {})
	var roll_draft: Dictionary = roll_window.get("draft", {})
	if str(roll_window.get("kind", "")) == "after_charge_roll" and int(roll_window.get("squad", -1)) == squad and bool(roll_draft.get("take_to_skies", false)): return roll_draft
	return {}

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
		_place_selection_card()
		if army_panel != null:
			var army_width := clampf(viewport_size.x * 0.26, 248.0, 320.0)
			army_panel.position = Vector2(16, _board_top())
			army_panel.size = Vector2(army_width, maxf(220.0, viewport_size.y - _board_top() - 16.0))
			army_panel.visible = army_panel_open and combat_enabled and (main_menu == null or not main_menu.visible) and tactical_overlay_content == null
			if combat_hud != null:
				combat_hud.set_army_open(army_panel.visible)
		if command_panel != null and combat_hud != null: combat_hud.set_command_panel_open(command_panel_open)
		call_deferred("_sync_gameplay_workspace")
	sidebar_panel.visible = not combat_enabled and main_menu != null and not main_menu.visible
	if combat_hud != null: combat_hud.visible = combat_enabled and (main_menu == null or not main_menu.visible)
	if guide_panel != null:
		guide_panel.visible = combat_enabled and not workspace_tab and (main_menu == null or not main_menu.visible) and viewport_size.x >= 1600.0 and not command_panel_open
		var guide_x := 16.0
		if army_panel != null and army_panel.visible:
			guide_x = army_panel.position.x + army_panel.size.x + 12.0
		guide_panel.position = Vector2(guide_x, _board_top())
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
	var command_open := command_panel != null and command_panel.visible
	if viewport_size.x < 1280.0 and combat_enabled and command_open:
		var width := maxf(280.0, viewport_size.x - 32.0)
		combat_tray.size = Vector2(width, 0)
		var preferred_height := combat_tray.get_combined_minimum_size().y
		var available := maxf(220.0, viewport_size.y - _board_top() - 24.0)
		var tray_height := minf(preferred_height, minf(200.0, available * 0.42))
		var panel_height := maxf(160.0, minf(260.0, available - tray_height - 8.0))
		var tray_y := viewport_size.y - tray_height - 16.0
		combat_tray.size = Vector2(width, tray_height)
		combat_tray.position = Vector2(16.0, tray_y)
		command_panel.position = Vector2(16.0, tray_y - panel_height - 8.0)
		command_panel.size = Vector2(width, panel_height)
		if army_panel != null and army_panel.visible:
			army_panel.size.y = maxf(140.0, command_panel.position.y - army_panel.position.y - 12.0)
		return
	var right := command_panel.position.x - 16.0 if command_open else viewport_size.x - 16.0
	var left := army_panel.position.x + army_panel.size.x + 12.0 if army_panel != null and army_panel.visible else 16.0
	var tray_width := minf(640.0, maxf(280.0, right - left))
	combat_tray.size = Vector2(tray_width, 0)
	# A width change can wrap labels and increase minimum height after the previous layout.
	var preferred_height := combat_tray.get_combined_minimum_size().y
	var tray_height := minf(preferred_height, maxf(180.0, viewport_size.y - _board_top() - 32.0))
	combat_tray.size = Vector2(tray_width, tray_height)
	combat_tray.position = Vector2(left, maxf(_board_top(), viewport_size.y - tray_height - 32.0))
	if army_panel != null and army_panel.visible and combat_tray.visible:
		army_panel.size.y = maxf(180.0, combat_tray.position.y - army_panel.position.y - 12.0)

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
	if not _pending_ui_decision(["awakened-attachment", "mission-preparation", "unit-actions", "combat-doctrines", "oath-of-moment", "vowed-target", "reanimation", "stratagems", "damage-allocation"]).is_empty(): return true
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
	var slots := MatchSave.existing_slots()
	if slots.size() != 1:
		_open_saved_matches()
		return
	if int(slots[0]) != active_save_slot or not resume_compatible:
		_open_saved_matches()
		return
	_load_match()
	if resume_succeeded:
		_dismiss_home(1)
	else:
		main_menu.show_status(status.text)
		_update_main_menu_resume_state()

func _update_main_menu_resume_state() -> void:
	if main_menu == null or combat_enabled: return
	var slots := MatchSave.existing_slots()
	if slots.is_empty():
		main_menu.set_resume_state(false, "No compatible saved match found.")
		return
	if slots.size() > 1 or int(slots[0]) != 1:
		main_menu.set_resume_state(true, "Choose a local save slot; compatibility is checked before loading.", false, slots.size())
		return
	var previous_status := status.text if status != null else ""
	_set_active_save_slot(1)
	_load_match(false, true)
	var issue := status.text
	var recovery_notice := issue if issue.contains("previous backup") else ""
	if status != null: status.text = previous_status
	main_menu.set_resume_state(true, issue if not resume_compatible else recovery_notice, false, slots.size())

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
	var preview_elevation := -1.0
	if combat_enabled:
		if not state.pending_contact.is_empty(): preview_elevation = _selected_contact_elevation()
		elif state.phase == "movement": preview_elevation = _selected_movement_elevation()
	if get_viewport().gui_get_hovered_control() == null:
		var mouse := get_viewport().get_mouse_position()
		var hover_plane_height := preview_elevation if preview_elevation >= 0.0 else 0.0
		var world: Variant = Plane(Vector3.UP, hover_plane_height).intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
		if world != null: hit = Vector2(world.x, world.z)
	guides.preview(state, selected, combat_enabled, _local_player(), hit, preview_elevation)
	guide_label.text = guides.caption + ("\n" + guides.hover_caption if not guides.hover_caption.is_empty() else "")
	if placement_feedback.pinned and placement_feedback.destination_marker: guide_label.text += "\nA blocked footprint marks the rejected destination; off-screen targets move to the nearest visible edge."
	if hit != null and state.units.has(selected):
		if not guides.hover_error.is_empty():
			if not placement_feedback.pinned:
				var marker_elevation := preview_elevation if preview_elevation >= 0.0 else float(state.units[selected].get("elevation", 0.0))
				placement_feedback.show_reason(selected, hit, guides.hover_error, false, true, marker_elevation, guides.hover_error_code, guides.hover_recovery)
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

func _populate_marine_chapter_choice(picker: OptionButton) -> void:
	picker.add_item("Infer from roster / detachment")
	picker.set_item_metadata(0, "")
	var chapter_keywords: Array = CurrentMarineProfiles.CHAPTER_KEYWORD_NAMES.keys()
	chapter_keywords.sort()
	for keyword: Variant in chapter_keywords:
		picker.add_item(CurrentMarineProfiles.chapter_name(str(keyword)))
		picker.set_item_metadata(picker.item_count - 1, str(keyword))

func _selected_marine_chapter_for(picker: OptionButton) -> String:
	if picker == null or picker.selected < 0: return ""
	var value: Variant = picker.get_item_metadata(picker.selected)
	return str(value).strip_edges().to_upper() if value is String else ""

func _selected_marine_chapters() -> Dictionary:
	if unit_abilities_choice != null and not unit_abilities_choice.button_pressed: return {1: "", 2: ""}
	return {1: _selected_marine_chapter_for(marine_chapter_choice_p1), 2: _selected_marine_chapter_for(marine_chapter_choice_p2)}

func _marine_chapter_assignments_equal(left: Dictionary, right: Dictionary) -> bool:
	for owner in [1, 2]:
		var left_value := str(left.get(owner, left.get(str(owner), ""))).strip_edges().to_upper()
		var right_value := str(right.get(owner, right.get(str(owner), ""))).strip_edges().to_upper()
		if left_value != right_value: return false
	return true

func _select_marine_chapter(picker: OptionButton, chapter: String) -> void:
	if picker == null: return
	var normalized := chapter.strip_edges().to_upper()
	for index in picker.item_count:
		if str(picker.get_item_metadata(index)).to_upper() == normalized:
			picker.select(index)
			return
	picker.select(0)

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

func _selected_official_primary_mission(player: int = 1) -> String:
	var picker: OptionButton = official_primary_choice if player == 1 else official_primary_choice_p2
	if picker == null or picker.selected < 0: return "battlefield-dominance"
	return str(picker.get_item_metadata(picker.selected))

func _selected_official_primary_missions() -> Dictionary:
	return {1: _selected_official_primary_mission(1), 2: _selected_official_primary_mission(2)}

func _selected_official_secondary_pair() -> String:
	if official_secondary_choice == null or official_secondary_choice.selected < 0: return Combat.Mission.DEFAULT_SECONDARY_PAIR
	return str(official_secondary_choice.get_item_metadata(official_secondary_choice.selected))

func _refresh_primary_mission_help(player: int = 1) -> void:
	var help: Label = official_primary_help if player == 1 else official_primary_help_p2
	if help == null: return
	match _selected_official_primary_mission(player):
		"battlefield-dominance": help.text = "Score from controlling objectives; the selected Event Companion terrain and shared fixed secondaries remain in use."
		"meatgrinder": help.text = "Reward enemy unit destruction, objective control and taking the opponent’s home objective."
		"destroyers-wrath": help.text = "End turn: +3VP if you destroyed an enemy unit. From round two, score +4VP for a non-home objective and +6VP for controlling more objectives; end turn also scores +4VP if enemy losses exceed your previous-turn losses."
		"outmanoeuvre": help.text = "Round 1 end turn: 4VP per non-home objective. Rounds 2–3 Command: 5VP each. Rounds 4–5 end turn: 6VP each. Enemy home objective at any turn end: +10VP."
		"immovable-object": help.text = "End turn: +3VP if you control a central objective. From rounds 2–4 at Command, and round 5 at turn end, score 5VP per controlled non-home objective."
		"delaying-action": help.text = "End turn: +2VP per enemy unit destroyed. From round 2, score +4VP at the checkpoint for any objective other than either home objective, and +3VP at turn end if you control a central and an expansion objective."
		"reconnaissance-sweep": help.text = "Score for spreading units across table quarters, destroying enemy units and controlling objectives."
		"secure-asset": help.text = "Start Secure Asset in the Shooting phase at a controlled non-home objective; hold it through end of turn."
	help.text += "\nEach player scores their own choice. This practice setup does not select roster-available Force Dispositions or derive missions from their pairings."

func _refresh_secondary_mission_help() -> void:
	if official_secondary_help == null: return
	match _selected_official_secondary_pair():
		"engage-assassination": official_secondary_help.text = "Engage on All Fronts + Assassination. Both players use this fixed pair."
		"engage-bring-it-down": official_secondary_help.text = "Engage on All Fronts + Bring It Down. Score 4VP for each enemy model with 10+ Wounds destroyed this turn (max 20VP per card); both armies need an eligible target."
		"engage-grievous-blow": official_secondary_help.text = "Engage on All Fronts + A Grievous Blow. Score 4VP per enemy unit with a starting strength of 13+ destroyed this turn, up to 5VP; both armies need an eligible unit."
		"engage-secure-no-mans-land": official_secondary_help.text = "Engage on All Fronts + Secure No Man's Land. Score 5VP at the end of your turn if you control at least two objectives outside both deployment zones."
		"engage-no-prisoners": official_secondary_help.text = "Engage on All Fronts + No Prisoners. At the end of each turn, score 2VP for each enemy unit destroyed that turn, up to 5VP."
		"engage-behind-enemy-lines": official_secondary_help.text = "Engage on All Fronts + Behind Enemy Lines. Score 3VP for each friendly unit wholly within the opponent's deployment zone at the end of your turn, up to 5VP; Aircraft and Battle-shocked units do not count."
		"engage-centre-ground": official_secondary_help.text = "Engage on All Fronts + Centre Ground. At the end of your turn, score 5VP if a friendly unit is within 3 inches of the battlefield centre and no enemy unit is within 6 inches; score 3VP instead if no enemy unit is within 3 inches. Aircraft and Battle-shocked units cannot establish friendly presence."
		"engage-display-of-might": official_secondary_help.text = "Engage on All Fronts + Display of Might. Score 2VP at the end of your turn or 5VP at the end of your opponent's turn if you have more eligible units wholly in No Man's Land. Aircraft and Battle-shocked units do not count."
		"engage-overwhelming-force": official_secondary_help.text = "Engage on All Fronts + Overwhelming Force. Score 3VP for each enemy unit destroyed this turn that was within range of an objective at turn start, up to 5VP."
		"engage-outflank": official_secondary_help.text = "Engage on All Fronts + Outflank. Score 3VP for an eligible unit near a battlefield edge and outside your territory, or 5VP for units near opposite edges when at least one is outside your territory. Aircraft and Battle-shocked units do not count."
		"engage-forward-position": official_secondary_help.text = "Engage on All Fronts + Forward Position. Score 5VP for controlling the opponent's home objective and 5VP for each expansion objective you control at the end of your turn."
		"engage-defend-stronghold": official_secondary_help.text = "Engage on All Fronts + Defend Stronghold. From battle round two, score 3VP at the end of your opponent's turn if you control your home objective, plus 2VP if no enemy units are within your deployment zone."
		"engage-tempting-target": official_secondary_help.text = "Engage on All Fronts + A Tempting Target. After the central objectives are rolled, each opponent chooses one central or expansion objective for the other player. Score 5VP at the end of your turn if you control your chosen target."

func _select_official_secondary_pair(pair_id: String) -> void:
	if official_secondary_choice == null: return
	var selected_index := 0
	for index in official_secondary_choice.item_count:
		if str(official_secondary_choice.get_item_metadata(index)) == pair_id:
			selected_index = index
			break
	official_secondary_choice.select(selected_index)
	_refresh_secondary_mission_help()

func _select_official_primary_mission(primary_id: String, player: int = 1) -> void:
	var picker: OptionButton = official_primary_choice if player == 1 else official_primary_choice_p2
	if picker == null: return
	var selected_index := 0
	for index in picker.item_count:
		if str(picker.get_item_metadata(index)) == primary_id:
			selected_index = index
			break
	picker.select(selected_index)
	_refresh_primary_mission_help(player)
	official_primary_missions[player] = _selected_official_primary_mission(player)

func _select_official_primary_missions(primary_ids: Dictionary) -> void:
	var fallback := str(primary_ids.get(1, primary_ids.get("1", "battlefield-dominance")))
	_select_official_primary_mission(fallback, 1)
	_select_official_primary_mission(str(primary_ids.get(2, primary_ids.get("2", fallback))), 2)
	official_primary_missions = _selected_official_primary_missions()

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
	official_primary_heading_p2.visible = active
	official_primary_choice_p2.visible = active
	official_primary_help_p2.visible = active
	official_primary_choice.disabled = not active or mode != "local"
	official_primary_choice_p2.disabled = not active or mode != "local"
	official_secondary_heading.visible = active
	official_secondary_choice.visible = active
	official_secondary_help.visible = active
	official_secondary_choice.disabled = not active or mode != "local"
	var mirrored_primary := _selected_official_primary_mission(1) == "battlefield-dominance" and _selected_official_primary_mission(2) == "battlefield-dominance"
	official_layout_heading.text = "11e Event Companion terrain · Take and Hold mirror" if mirrored_primary else "11e Event Companion terrain · bounded training proxy"
	official_layout_heading.tooltip_text = "Terrain-only presets A/B/C. The supported primary cards are selected per player, while the Take and Hold mirror terrain proxies remain in use. Exact recommended layouts for every primary-mission pairing are not implemented."
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
			official_layout_preview_status.text = "Terrain preview only. Mission, objectives, deployment and scoring stay unchanged. Runtime terrain uses bounded wall and first-floor proxies."
			return
	official_layout_preview_status.text = "The 11th-edition source diagram is not cached on this computer. The preset remains playable with bounded wall and first-floor proxies."

func _initial_state() -> Dictionary:
	if combat_enabled and saved_army_mode: return PreparedTraining.waiting({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "marine_chapters": _selected_marine_chapters(), "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "primary_missions": _selected_official_primary_missions(), "secondary_pair": _selected_official_secondary_pair(), "terrain_layout": terrain_layout, "checked_rosters": checked_rosters})
	if combat_enabled and prepared_match: return PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "marine_chapters": _selected_marine_chapters(), "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "primary_missions": _selected_official_primary_missions(), "secondary_pair": _selected_official_secondary_pair(), "terrain_layout": terrain_layout, "checked_rosters": checked_rosters})
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
	var invalid := false
	for owner in [1, 2]:
		if not _saved_army_report(owner).error.is_empty(): invalid = true
	if unit_abilities_choice.button_pressed and not invalid:
		var selections: Dictionary = {}
		for owner in [1, 2]:
			var report := _saved_army_report(owner)
			if report.error.is_empty(): selections[owner] = report.selection
		if selections.size() == 2:
			var doctrines_enabled := combat_doctrines_choice.button_pressed
			var chapter_options := {"unit_abilities": true, "combat_doctrines": doctrines_enabled,
				"marine_detachment": _selected_marine_detachment() if doctrines_enabled else "none",
				"marine_detachments": _selected_marine_detachments() if doctrines_enabled else {1: "none", 2: "none"},
				"marine_chapters": _selected_marine_chapters()}
			var preview := PreparedTraining.initial_state(chapter_options, selections)
			if preview.has("error"):
				details.append(str(preview.error))
				invalid = true
			else:
				var effective_chapters: Dictionary = preview.get("marine_chapters", {})
				var selected_chapters: Dictionary = preview.get("marine_chapter_selections", {})
				for owner in [1, 2]:
					var chapter := str(effective_chapters.get(owner, ""))
					if chapter.is_empty():
						lines.append("P%d Chapter context: none inferred" % owner)
					else:
						var origin := "selected" if not str(selected_chapters.get(owner, "")).is_empty() else "inferred"
						lines.append("P%d Chapter context: %s (%s)" % [owner, CurrentMarineProfiles.chapter_name(chapter), origin])
	saved_army_review.text = "\n".join(lines)
	saved_army_review.tooltip_text = "\n".join(details)
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
	var options := {"manual_allocation": defender_choice.button_pressed, "varied_equipment": false, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed, "oath_of_moment": oath_of_moment_choice.button_pressed, "reanimation_protocols": reanimation_protocols_choice.button_pressed, "combat_doctrines": combat_doctrines_choice.button_pressed, "marine_detachment": _selected_marine_detachment() if combat_doctrines_choice.button_pressed else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines_choice.button_pressed else {1: "none", 2: "none"}, "marine_chapters": _selected_marine_chapters(), "awakened_dynasty": awakened_dynasty_choice.button_pressed, "unit_abilities": unit_abilities_choice.button_pressed, "official_mission": official_mission_choice.button_pressed, "primary_mission": _selected_official_primary_mission(), "primary_missions": _selected_official_primary_missions(), "secondary_pair": _selected_official_secondary_pair(), "terrain_layout": terrain_layout, "checked_rosters": checked_rosters_choice.button_pressed}
	if tactical_training: options.training_scenario_id = TrainingRoster.Tactical.ID
	var candidate := PreparedTraining.initial_state(options, selections) if local_match else PreparedTraining.waiting(options)
	if candidate.has("error"):
		status.text = candidate.error
		return
	var save_target_notice := _prepare_new_match_save_target() if local_match else ""
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
	marine_chapters = _selected_marine_chapters()
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
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
	var candidate := PreparedTraining.initial_state({"manual_allocation": manual_allocation, "varied_equipment": false, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": marine_detachment if combat_doctrines else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}, "marine_chapters": _selected_marine_chapters(), "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "primary_mission": _selected_official_primary_mission(), "primary_missions": _selected_official_primary_missions(), "secondary_pair": _selected_official_secondary_pair(), "terrain_layout": terrain_layout, "checked_rosters": checked_rosters}, pending_armies)
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
	var candidate := PreparedTraining.initial_state({"manual_allocation": defender_choice.button_pressed, "varied_equipment": equipment_choice.button_pressed, "core_stratagems": stratagem_choice.button_pressed, "movement_rerolls": reroll_choice.button_pressed, "attack_rerolls": attack_reroll_choice.button_pressed, "save_rerolls": save_reroll_choice.button_pressed, "damage_rerolls": damage_reroll_choice.button_pressed, "hazard_rerolls": hazard_reroll_choice.button_pressed, "escape_rerolls": escape_reroll_choice.button_pressed, "count_rerolls": count_reroll_choice.button_pressed, "objective_secured": objective_secured_choice.button_pressed, "implacable_eradication": implacable_eradication_choice.button_pressed, "hail_of_bolts": hail_of_bolts_choice.button_pressed, "oath_of_moment": oath_of_moment_choice.button_pressed, "reanimation_protocols": reanimation_protocols_choice.button_pressed, "combat_doctrines": combat_doctrines_choice.button_pressed, "marine_detachment": _selected_marine_detachment() if combat_doctrines_choice.button_pressed else "none", "marine_detachments": _selected_marine_detachments() if combat_doctrines_choice.button_pressed else {1: "none", 2: "none"}, "marine_chapters": _selected_marine_chapters(), "awakened_dynasty": awakened_dynasty_choice.button_pressed, "unit_abilities": unit_abilities_choice.button_pressed, "official_mission": official_mission_choice.button_pressed, "primary_mission": _selected_official_primary_mission(), "primary_missions": _selected_official_primary_missions(), "secondary_pair": _selected_official_secondary_pair(), "terrain_layout": terrain_layout, "checked_rosters": checked_rosters_choice.button_pressed})
	if candidate.has("error"):
		status.text = candidate.error
		return
	var save_target_notice := _prepare_new_match_save_target()
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
	marine_chapters = _selected_marine_chapters()
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
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
	var save_target_notice := _prepare_new_match_save_target()
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
	_dismiss_home(1)

func _start_objectives(unit_count: int = 1, layout_id: String = Combat.Terrain.DEFAULT_LAYOUT) -> void:
	if mode != "local": return
	local_visual_armies.clear()
	var candidate := TestBattlefield.apply(Combat.initial_state(layout_id, Combat.Objectives.TRAINING, unit_count, defender_choice.button_pressed, equipment_choice.button_pressed))
	if candidate.has("error"):
		status.text = candidate.error
		return
	var save_target_notice := _prepare_new_match_save_target()
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
	terrain_layout = layout_id
	mission_id = Combat.Objectives.TRAINING
	squads_per_side = unit_count
	manual_allocation = defender_choice.button_pressed
	varied_equipment = equipment_choice.button_pressed
	state = candidate
	_reset_history()
	selected = -1
	_spawn_pieces()
	status.text = "Training · 1 VP per objective · 5 rounds."
	if layout_id == Combat.Terrain.MULTI_STOREY_PRACTICE_LAYOUT: status.text = "Training · 5 rounds · 3/6 in ruin. Vertical climb counts; high ground can use Plunging Fire."
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
	_refresh()

func _toggle_combat(layout: String = Combat.Terrain.DEFAULT_LAYOUT) -> void:
	if mode != "local": return
	if not saved_army_mode: local_visual_armies.clear()
	var next_terrain: String = str(terrain_layout) if combat_enabled else layout
	var next_manual := manual_allocation if combat_enabled else defender_choice.button_pressed
	var next_varied := varied_equipment if combat_enabled else equipment_choice.button_pressed
	var candidate: Dictionary = Rules.initial_state() if combat_enabled else TestBattlefield.apply(Combat.initial_state(next_terrain, "elimination", 1, next_manual, next_varied))
	if candidate.has("error"):
		status.text = candidate.error + " Run tools/import_starter_factions.py as documented."
		return
	var save_target_notice := _prepare_new_match_save_target() if not combat_enabled else ""
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
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
	var unit: Dictionary = state.units[selected]
	var ids := DecisionCamera.models(state, [unit.squad])
	var plan := DecisionCamera.plan(camera, pivot, state, ids, _camera_board_area(), angle)
	if plan.is_empty():
		var spot: Vector2 = unit.position
		plan = {"position": Vector3(spot.x, 0.0, spot.y), "zoom": clampf(zoom, 14.0, 24.0)}
	_apply_camera_plan(plan)

func _table_seat() -> int:
	if mode == "client": return 2
	if mode == "host": return 1
	var active := int(state.get("active", 1))
	return active if active in [1, 2] else 1

func _player_outward(player: int) -> Vector2:
	var zones: Dictionary = state.get("deployment", {}).get("zones", {})
	var zone: Variant = zones.get(player, zones.get(str(player), null))
	if zone is Rect2 and (zone as Rect2).size.length_squared() > 0.01:
		return (zone as Rect2).get_center()
	var half := Rules.half_board(state)
	return Vector2(-half.x * 0.5, 0.0) if player != 2 else Vector2(half.x * 0.5, 0.0)

func _table_angle_for(player: int) -> float:
	var outward := _player_outward(player)
	if outward.length_squared() < 0.01:
		outward = Vector2(-1, 0) if player != 2 else Vector2(1, 0)
	return atan2(outward.x, outward.y)

func _opening_zoom() -> float:
	var size := Rules.half_board(state) * 2.0
	return maxf(18.0, maxf(size.x, size.y) * 0.82)

func _look_from_player_side() -> void:
	if camera == null or pivot == null: return
	_manual_camera_control()
	angle = _table_angle_for(_table_seat())
	zoom = _opening_zoom()
	pivot.position = Vector3.ZERO
	_update_camera()

func _remember_player_side() -> void:
	if not combat_enabled:
		framed_side_key = ""
		return
	var key := "%s:%s" % [str(state.get("pack_hash", "")), mode]
	if key == framed_side_key: return
	framed_side_key = key
	_look_from_player_side()

func _refresh_side_anchors() -> void:
	if side_anchor_root == null: return
	var seat := _table_seat() if combat_enabled else 0
	var half := Rules.half_board(state)
	var key := "%s:%s:%s:%s:%s" % [combat_enabled, seat, half, _player_outward(1), _player_outward(2)]
	if key == side_anchor_key: return
	side_anchor_key = key
	for child in side_anchor_root.get_children():
		side_anchor_root.remove_child(child)
		child.queue_free()
	if not combat_enabled: return
	for player: int in [1, 2]:
		var outward := _player_outward(player)
		if outward.length_squared() < 0.01:
			outward = Vector2(-1, 0) if player == 1 else Vector2(1, 0)
		var direction := outward.normalized()
		var reach_x := half.x / absf(direction.x) if absf(direction.x) > 0.001 else INF
		var reach_z := half.y / absf(direction.y) if absf(direction.y) > 0.001 else INF
		var edge := direction * minf(reach_x, reach_z) * 0.9
		var marker := Label3D.new()
		marker.text = "P%d" % player
		marker.font_size = 48
		marker.pixel_size = 0.016
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.position = Vector3(edge.x, 0.35, edge.y)
		marker.modulate = Color("f2df83") if player == seat else Color("8aa0ab")
		marker.outline_size = 8
		marker.outline_modulate = Color("10171d")
		side_anchor_root.add_child(marker)

func _camera_board_area() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	var left := 16.0
	var right := viewport_size.x - 16.0
	var bottom := viewport_size.y - 16.0
	if sidebar_panel.is_visible_in_tree(): left = sidebar_panel.get_global_rect().end.x + 16.0
	if army_panel != null and army_panel.is_visible_in_tree(): left = maxf(left, army_panel.get_global_rect().end.x + 16.0)
	if command_panel != null and command_panel.is_visible_in_tree():
		var command_rect := command_panel.get_global_rect()
		if command_rect.position.y <= _board_top() + 8.0: right = command_rect.position.x - 16.0
		else: bottom = minf(bottom, command_rect.position.y - 16.0)
	if guide_panel.is_visible_in_tree(): left = maxf(left, guide_panel.get_global_rect().end.x + 16.0)
	if combat_tray != null and combat_tray.is_visible_in_tree(): bottom = minf(bottom, combat_tray.position.y - 16.0)
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
		var elevation := float(state.units[placement_feedback.model].get("elevation", 0.0))
		var base_world := Vector3(location.x, elevation + 0.12, location.y)
		var anchor_world := Vector3(location.x, elevation + 1.7, location.y)
		placement_feedback.place(camera, anchor_world, base_world, float(state.units[placement_feedback.model].get("radius", 0.5)), _camera_board_area())
	if setup_notice != null and status != null:
		var notice := status.text
		if not autosave_error.is_empty() and state.get("phase") != "army_selection": notice += "\nAutosave failed: " + autosave_error
		if setup_notice.text != notice: setup_notice.text = notice
	if main_menu != null and main_menu.visible: return
	if local_player_handoff != null and local_player_handoff.visible: return
	if tactical_overlay_content != null: return
	hover_time += delta
	if hover_time >= 0.05:
		hover_time = 0.0
		_update_hover_guides()
	if _keyboard_choice_has_focus():
		return
	var pan_x := Input.get_axis(INPUT_CAMERA_PAN_LEFT, INPUT_CAMERA_PAN_RIGHT)
	var pan_z := Input.get_axis(INPUT_CAMERA_PAN_UP, INPUT_CAMERA_PAN_DOWN)
	var direction := Vector3(pan_x, 0.0, pan_z)
	if direction != Vector3.ZERO:
		_manual_camera_control()
		pivot.position += direction.rotated(Vector3.UP, angle) * delta * 12
		var limit: Vector2 = Rules.half_board(state) + Vector2(12, 12)
		pivot.position.x = clampf(pivot.position.x, -limit.x, limit.x)
		pivot.position.z = clampf(pivot.position.z, -limit.y, limit.y)

func _keyboard_choice_has_focus() -> bool:
	var focused := get_viewport().gui_get_focus_owner()
	return focused is LineEdit or focused is TextEdit or focused is OptionButton or focused is SpinBox or focused is Tree or focused is ItemList

func _handle_datasheet_scroll_key(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed or key_event.shift_pressed:
		return false
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != datasheet_details and (focus_owner == null or not datasheet_details.is_ancestor_of(focus_owner)):
		return false
	var page_size := maxi(24, int(datasheet_details.size.y * 0.75))
	var scroll_bar := datasheet_details.get_v_scroll_bar()
	var max_scroll := maxi(0, int(scroll_bar.max_value - scroll_bar.page))
	match key_event.keycode:
		KEY_PAGEUP:
			datasheet_details.scroll_vertical = maxi(0, datasheet_details.scroll_vertical - page_size)
		KEY_PAGEDOWN:
			datasheet_details.scroll_vertical = mini(max_scroll, datasheet_details.scroll_vertical + page_size)
		KEY_HOME:
			datasheet_details.scroll_vertical = 0
		KEY_END:
			datasheet_details.scroll_vertical = max_scroll
		_:
			return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if local_player_handoff != null and local_player_handoff.visible:
		get_viewport().set_input_as_handled()
		return
	if _handle_pending_control_binding(event):
		get_viewport().set_input_as_handled()
		return
	if tactical_overlay_content != null and event.is_action_pressed("ui_cancel"):
		_close_tactical_screen()
		get_viewport().set_input_as_handled()
		return
	if tactical_overlay_content == datasheet_details and _handle_datasheet_scroll_key(event):
		get_viewport().set_input_as_handled()
		return
	if tactical_overlay_content != null:
		get_viewport().set_input_as_handled()
		return
	if main_menu != null and main_menu.visible: return
	if event.is_action_pressed(INPUT_INSPECT_DATASHEET, false):
		if not _keyboard_choice_has_focus() and combat_enabled and state.units.has(selected):
			_open_selected_datasheet()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(INPUT_FOCUS_SELECTED_UNIT, false):
		if not _keyboard_choice_has_focus():
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
	if event.button_index == MOUSE_BUTTON_LEFT:
		_clear_placement_feedback()
		selected = _pick_model_from_screen(event.position)
		if selected >= 0: _set_command_panel_open(true)
		_refresh_for_selection()
		return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	var target_elevation := 0.0
	var movement_placement: bool = combat_enabled and state.phase == "movement" and state.pending_contact.is_empty() and Combat.UnitActions.pending(state).is_empty() and Combat.Reanimation.pending(state).is_empty()
	var contact_placement: bool = combat_enabled and not state.pending_contact.is_empty()
	if movement_placement: target_elevation = _selected_movement_elevation()
	elif contact_placement: target_elevation = _selected_contact_elevation()
	var hit: Variant = Plane(Vector3.UP, target_elevation).intersects_ray(camera.project_ray_origin(event.position), camera.project_ray_normal(event.position))
	if hit == null:
		return
	var target := Vector2(hit.x, hit.z)
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if combat_enabled and Combat.UnitAbilities.enabled(state) and (unit_action_picker.is_visible_in_tree() or doctrine_action_panel.is_visible_in_tree()) and unit_action_picker.selected >= 0:
			var ability: Dictionary = unit_action_picker.get_selected_metadata()
			if Combat.UnitActions.pending(state).get("kind", "") == "ingress":
				for choice: Dictionary in _available_unit_choices(_local_player()):
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
			if mode == "client": request_contact_move.rpc_id(1, selected, target, state.revision, target_elevation)
			else: _apply_contact_move(_local_player(), selected, target, state.revision, target_elevation)
			return
		if combat_enabled and state.phase in ["shooting", "charge", "fight"]:
			var target_id := _pick_model_from_screen(event.position)
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
		if combat_enabled and state.phase == "movement" and state.pending_move.is_empty() and take_to_skies_choice.button_pressed:
			_request_begin_movement()
			return
		if mode == "client":
			request_move.rpc_id(1, selected, target, int(state.get("revision", -1)), target_elevation)
		else:
			_apply_move(_local_player(), selected, target, int(state.get("revision", -1)), target_elevation)

func _pick_model_from_screen(screen_position: Vector2) -> int:
	var nearest := -1
	var best_ratio := INF
	for id: int in state.units:
		if not pieces.has(id) or not pieces[id].visible: continue
		var unit: Dictionary = state.units[id]
		if unit.get("wounds", 1) <= 0 or not unit.get("on_battlefield", true): continue
		var world: Vector3 = pieces[id].global_position
		if camera.is_position_behind(world): continue
		var center := camera.unproject_position(world)
		var radius: float = float(unit.get("radius", 0.5))
		var radius_x := center.distance_to(camera.unproject_position(world + Vector3(radius, 0, 0)))
		var radius_z := center.distance_to(camera.unproject_position(world + Vector3(0, 0, radius)))
		var hit_radius := maxf(radius_x, radius_z) + 8.0
		var ratio := screen_position.distance_to(center) / maxf(hit_radius, 1.0)
		if ratio <= 1.0 and ratio < best_ratio:
			best_ratio = ratio
			nearest = id
	return nearest

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

func _ui_projection_valid() -> bool:
	return _ui_refresh_depth > 0 and is_same(_ui_projection_state, state) and _ui_projection_revision == int(state.get("revision", -1))

func _match_actor() -> int:
	return _ui_actor if _ui_projection_valid() else Combat.actor(state)

func _available_unit_choices(player: int) -> Array:
	if not _ui_projection_valid(): return Combat.unit_choices(state, player)
	if not _ui_choices.has(player): _ui_choices[player] = Combat.unit_choices(state, player)
	return _ui_choices[player].duplicate()

func _pending_ui_decision(sources: Array) -> Dictionary:
	if not _ui_projection_valid(): return PendingDecisions.current(state, sources)
	for source: String in sources:
		if not _ui_decisions.has(source): _ui_decisions[source] = PendingDecisions.current(state, [source])
		if not _ui_decisions[source].is_empty(): return _ui_decisions[source]
	return {}

func _ui_command_error(player: int) -> String:
	if not _ui_projection_valid(): return Combat.PhaseCloseGate.command_error(state, player, state.revision)
	if not _ui_gate_errors.has(player): _ui_gate_errors[player] = Combat.PhaseCloseGate.command_error(state, player, state.revision)
	return str(_ui_gate_errors[player])

func _local_player() -> int:
	return (_match_actor() if combat_enabled else int(state.active)) if mode == "local" else (1 if mode == "host" else 2)

func _refresh_tactical_opportunity_cue() -> void:
	if tactical_opportunity_label == null: return
	var cue := ""
	if combat_enabled and guided_first_session and saved_army_mode and int(state.get("test_winner", 0)) == 0 and TrainingRoster.Tactical.matches(state):
		var actor := _match_actor()
		if actor > 0:
			cue = TrainingRoster.Tactical.opportunity_status(_available_unit_choices(actor))
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
			combat_hud.set_mission_available(false)
			decision_label.text = "MATCH STATE INVALID • resume a valid save or start a new match."
			decision_label.tooltip_text = pending_state_error
			combat_hud.set_steps(str(state.get("phase", "")), int(state.get("round", 0)), int(state.get("active", 1)), -1)
			return
	if combat_enabled != ui_combat_enabled:
		match_tabs.current_tab = 1 if combat_enabled else 0
		ui_combat_enabled = combat_enabled
		if combat_enabled: command_panel_open = true
	objective_summary.visible = combat_enabled and (Combat.Objectives.training(state) or Combat.Mission.enabled(state)) and state.phase != "army_selection"
	combat_hud.set_mission_available(objective_summary.visible)
	if objective_summary.visible:
		objective_summary.text = "P1 %d VP · %d CP   P2 %d VP · %d CP" % [state.mission.scores[1], int(state.get("cp", {}).get(1, 0)), state.mission.scores[2], int(state.get("cp", {}).get(2, 0))]
		objective_summary.tooltip_text = _mission_overview_copy()
		if tactical_overlay_content == mission_overview_scroll: _refresh_mission_overview_text()
	if not combat_enabled:
		combat_hud.set_round("Preview")
		combat_hud.set_steps("", 0, 0)
		decision_label.text = "Choose a mode from the title screen to begin."
		decision_label.tooltip_text = "No exercise is running. Choose a mode from the title screen to begin."
		return
	combat_hud.set_steps(str(state.phase), int(state.round), int(state.get("active", 1)), _match_actor())
	if state.phase == "army_selection":
		match_tabs.current_tab = 0
		decision_label.text = "ARMY SELECTION • choose and submit your list."
		decision_label.tooltip_text = "Choose and submit your own list in the command panel. The readiness line shows which player is waiting; an admission error explains any rejected selection."
		return
	if state.test_winner != 0:
		decision_label.text = "EXERCISE COMPLETE • " + ("Draw" if state.test_winner == -1 else "Player %d wins" % state.test_winner)
		decision_label.tooltip_text = "The exercise is complete. Start another exercise from Match setup."
		return
	if mode == "host" and guest_id == 0:
		decision_label.text = "WAITING FOR PLAYER 2"
		decision_label.tooltip_text = "Both players must select the same exercise."
		return
	var actor := _match_actor()
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
		for ability: Dictionary in _available_unit_choices(_local_player()):
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
	var phase_name := str(state.phase).capitalize()
	if phase_name == "Fight" and not str(state.get("fight_step", "")).is_empty():
		phase_name += " · " + str(state.fight_step).capitalize()
	var active_player := int(state.get("active", actor))
	var owner_text := "Round %d · %s · Player %d's turn · Player %d decides" % [int(state.get("round", 0)), phase_name, active_player, actor]
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
	decision_label.text = "%s\n%s" % [owner_text, instruction]
	decision_label.tooltip_text = "%s\n%s\n%s" % [owner_text, KeywordGlossary.describe_phase(str(state.phase), str(state.get("fight_step", ""))), instruction]

func _refresh_first_session_guide() -> void:
	if first_session_panel == null: return
	var guide_active := guided_first_session and combat_enabled and saved_army_mode
	first_session_panel.visible = guide_active
	if not guide_active:
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
		var opportunity_actor := _match_actor()
		if opportunity_actor > 0:
			opportunity_status = TrainingRoster.Tactical.opportunity_status(_available_unit_choices(opportunity_actor))
		var opportunity_line := ("\n" + opportunity_status) if not opportunity_status.is_empty() else ""
		var experiment_count := TrainingRoster.Tactical.experiment_count(state)
		first_session_experiments.text = "OPTIONAL EXPERIMENTS\nPROGRESS: %d / 4 observed\nDONE = observed • OPEN = available\nCURRENT WINDOW: " % experiment_count + current_window + opportunity_line + "\n" + "\n".join(TrainingRoster.Tactical.experiment_lines(state).map(func(item: String): return "• " + item))
	first_session_guide.text = instruction
	first_session_boundary.text = boundary.replace("CAN DO:", "[color=#8ad9a7]CAN DO:[/color]").replace("WAIT:", "[color=#f2df83]WAIT:[/color]").replace("CANNOT:", "[color=#f08c8c]CANNOT:[/color]").replace("OPTIONAL:", "[color=#8ad9a7]OPTIONAL:[/color]")
	first_session_boundary.visible = true
	first_session_guide.tooltip_text = instruction + "\n" + boundary
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

func _keep_model_card_visible() -> void:
	if selection_card == null:
		return
	_place_selection_card()
	var content := selection_card.get_parent()
	if content == null:
		return
	if int(state.get("test_winner", 0)) != 0:
		content.visible = false
		return
	if state.units.has(selected):
		content.visible = true
		if selection_panel != null:
			selection_panel.visible = true

func _refresh_army_roster() -> void:
	if army_roster == null or not combat_enabled:
		return
	var shown_player := _match_actor()
	if shown_player <= 0:
		shown_player = int(state.get("active", 1))
	army_roster.present(state, selected, shown_player)

func _refresh_selection_card() -> void:
	_refresh_army_roster()
	selection_stats.visible = false
	selection_health.visible = false
	if not state.units.has(selected):
		var setup_context: bool = combat_enabled and (state.get("phase", "") == "army_selection" or Combat.UnitActions.setup_actor(state) > 0 or Combat.UnitActions.battle_actor(state) > 0 or Combat.Mission.actor(state) > 0)
		selection_card.get_parent().visible = not setup_context
		selection_card.text = "No model selected. Click a miniature."
		datasheet_button.visible = false
		datasheet_details.visible = false
		return
	var unit: Dictionary = state.units[selected]
	if not combat_enabled:
		selection_card.text = "Model %d\n%s" % [selected, "Moved" if unit.moved else "Ready to move"]
		datasheet_button.visible = false
		datasheet_details.visible = false
		return
	var squad: Dictionary = state.squads[unit.squad]
	datasheet_button.visible = true
	datasheet_details.visible = tactical_overlay_content == datasheet_details
	if datasheet_details.visible:
		if datasheet_presented_model_id != selected:
			datasheet_details.scroll_vertical = 0
			datasheet_details.scroll_horizontal = 0
			datasheet_presented_model_id = selected
		datasheet_view.present(_selected_datasheet_model(unit, squad))
	selection_card.get_parent().visible = true
	if selection_panel != null: selection_panel.visible = true
	selection_card.text = "%s\n%s · W %d/%d" % [squad.name, ArmyList.model_label(state, selected), unit.wounds, unit.max_wounds]
	selection_health.visible = true
	selection_health.max_value = maxi(1, int(unit.max_wounds))
	selection_health.value = unit.wounds
	if not unit.get("on_battlefield", true): selection_card.text += "\nStrategic Reserves"
	elif unit.wounds <= 0: selection_card.text += "\nDestroyed"
	elif squad.battle_shocked: selection_card.text += "\nBattle-shocked"
	if state.phase == "movement" and unit.wounds > 0 and unit.get("on_battlefield", true): selection_card.text += "\nMove remaining %.1f\"" % Combat.movement_remaining(state, selected)
	elif not squad.get("action", {}).is_empty(): selection_card.text += "\nSecure Ground in progress"
	if Combat.UnitActions.TargetAuguryWeb.active(state, selected): selection_card.text += "\nTarget Augury Web · Lethal Hits until Player %d's next Command phase" % int(unit.get("owner", -1))
	var machine_war_doctrine := Combat.Doctrines.master_machine_war_doctrine(state, int(unit.get("squad", -1)))
	if not machine_war_doctrine.is_empty(): selection_card.text += "\nMaster of the Machine War · %s Doctrine until Player %d's next Command phase" % ["Devastator" if machine_war_doctrine == "devastator" else "Tactical", int(unit.get("owner", -1))]
	var adept_effect: Dictionary = state.get("marine_enhancements", {}).get("adept_active", {})
	if int(adept_effect.get("target", -1)) == int(unit.get("squad", -2)):
		var attacker_squad := int(adept_effect.get("attacker_squad", -1))
		var attacker_name := str(state.squads.get(attacker_squad, {}).get("name", "the attacking enemy"))
		selection_card.text += "\nAdept of the Omnissiah · Feel No Pain 5+ against %s until it finishes attacking" % attacker_name
	var prevention_rules: Variant = Combat.UnitPrevention.rules(state, selected)
	selection_card.tooltip_text = "Feel No Pain: " + Combat.Attacks.Prevention.describe(prevention_rules) if prevention_rules is Array and not prevention_rules.is_empty() else "Selected model. Open its datasheet for weapons and ability references."

func _invulnerable_text(defense: Dictionary) -> String:
	var general := int(defense.get("invulnerable_target", 0))
	var conditional := int(defense.get("melee_invulnerable_target", 0))
	if conditional > 0 and (general == 0 or conditional < general):
		return "%d+ melee" % conditional if general == 0 else "%d+; melee %d+" % [general, conditional]
	return "—" if general == 0 else "%d+" % general

func _open_selected_datasheet() -> void:
	if not combat_enabled or not state.units.has(selected): return
	var unit: Dictionary = state.units[selected]
	datasheet_details.scroll_vertical = 0
	datasheet_details.scroll_horizontal = 0
	datasheet_presented_model_id = selected
	datasheet_view.present(_selected_datasheet_model(unit, state.squads[unit.squad]))
	_show_tactical_screen(datasheet_details, "UNIT DATASHEET / MATCH PROFILE")

func _open_local_ability_reference_folder() -> void:
	var folder := ProjectSettings.globalize_path(LocalAbilityReference.USER_ROOT)
	if not DirAccess.dir_exists_absolute(folder):
		var create_error := DirAccess.make_dir_recursive_absolute(folder)
		if create_error != OK and not DirAccess.dir_exists_absolute(folder):
			datasheet_view.set_reference_folder_status("Could not create the local reference folder (%s). Copy its path to open or create it manually." % error_string(create_error), true)
			return
	var open_error := OS.shell_open(folder)
	if open_error == OK:
		datasheet_view.set_reference_folder_status("Folder opened. Copy a verified snapshot there, then select Reload local reference. Cross-file gaps appear as an incomplete-export warning.")
	else:
		datasheet_view.set_reference_folder_status("Could not open the folder (%s). Copy its path, then open or create it manually: %s" % [error_string(open_error), folder], true)

func _copy_local_ability_reference_folder_path() -> void:
	var folder := ProjectSettings.globalize_path(LocalAbilityReference.USER_ROOT)
	DisplayServer.clipboard_set(folder)
	datasheet_view.set_reference_folder_status("Local reference folder path copied to the clipboard: %s" % folder)

func _reload_local_ability_reference() -> void:
	LocalAbilityReference.reload()
	if state.units.has(selected):
		var unit: Dictionary = state.units[selected]
		var squad_id := int(unit.get("squad", -1))
		if state.squads.has(squad_id): datasheet_view.present(_selected_datasheet_model(unit, state.squads[squad_id]))
	var reload_message := "Local reference reloaded."
	if not LocalAbilityReference.issue.is_empty():
		reload_message = "Reload failed. Review the source message above."
		if "not installed" in LocalAbilityReference.issue.to_lower(): reload_message = "No verified source found. Copy one above, then reload."
	elif not LocalAbilityReference.warning.is_empty():
		reload_message = "Local reference reloaded with an incomplete-snapshot warning."
	datasheet_view.set_reference_folder_status(reload_message)

func _selected_datasheet_model(unit: Dictionary, squad: Dictionary, with_weapons: bool = true) -> Dictionary:
	var stats: Dictionary = squad.get("stats", {})
	var defense := Combat.Allocation.Groups.profile(state, selected)
	var attributes: Array = [
		{"label": "M", "value": _required_stat_text(unit.get("movement", stats.get("movement_inches", 0))) + "\"", "help": "Movement"},
		{"label": "T", "value": _required_stat_text(defense.get("toughness", stats.get("toughness", 0))), "help": "Toughness"},
		{"label": "Sv", "value": _required_stat_text(defense.get("save_target", stats.get("save_target", 0))) + "+", "help": "Armour save"},
		{"label": "W", "value": _required_stat_text(unit.get("max_wounds", stats.get("wounds", 0))), "help": "Wounds characteristic"},
		{"label": "Ld", "value": _required_stat_text(stats.get("leadership_target", 0)) + "+", "help": "Leadership"},
		{"label": "OC", "value": str(Combat.Morale.objective_control(state, selected)), "help": "Current Objective Control"}]
	var chapter_rule_keywords: Array[String] = []
	var chapter_contexts: Dictionary = state.get("marine_chapters", {})
	var owner := int(unit.get("owner", -1))
	if str(chapter_contexts.get(owner, chapter_contexts.get(str(owner), ""))) == "DARK ANGELS":
		for keyword: String in ["DEATHWING", "RAVENWING"]:
			if keyword in unit.get("keywords", []): chapter_rule_keywords.append(keyword)
	var model := {"name": str(squad.name), "identity": "%s · %d/%d wounds remaining" % [ArmyList.model_label(state, selected), unit.wounds, unit.max_wounds], "attributes": attributes, "invulnerable": _invulnerable_text(defense), "keywords": unit.get("keywords", []).duplicate(), "conditional_chapter_keywords": chapter_rule_keywords, "ranged": [], "melee": [], "abilities": [], "conditions": ""}
	if not with_weapons: return model
	var conditions: Array[String] = []
	if model.invulnerable != "—": conditions.append("Invulnerable save " + model.invulnerable)
	if squad.battle_shocked: conditions.append("Battle-shocked")
	if not unit.get("on_battlefield", true): conditions.append("Strategic Reserves")
	if unit.wounds <= 0: conditions.append("Destroyed")
	var prevention_rules: Variant = Combat.UnitPrevention.rules(state, selected)
	if prevention_rules is Array and not prevention_rules.is_empty(): conditions.append("Feel No Pain " + Combat.Attacks.Prevention.describe(prevention_rules))
	elif not prevention_rules is Array: conditions.append("Feel No Pain rules unresolved")
	model.conditions = " · ".join(conditions)
	for melee: bool in [false, true]:
		for option: Dictionary in Combat.AttackPlan.Equipment.choices(state, selected, melee):
			var weapon: Dictionary = option.get("stats", {})
			var keywords: Array[String] = []
			for key: String in weapon.get("keywords", {}):
				var value: Variant = weapon.keywords[key]
				if (value is bool and not value) or (value is int and value == 0) or (value is String and value.is_empty()): continue
				var keyword := str(KeywordGlossary.DEFINITIONS.get(key, {}).get("name", key.replace("-", " ").capitalize()))
				if value is int: keyword += " %d" % value
				elif value is String: keyword += " " + value
				keywords.append(keyword)
			model["melee" if melee else "ranged"].append({"name": str(option.get("label", "Weapon")), "range": "Melee" if melee else _stat_text(weapon.get("range_inches", 0)) + "\"", "attacks": _stat_text(weapon.get("attacks", "—")), "skill": _stat_text(weapon.get("skill", 0)) + "+", "strength": _stat_text(weapon.get("strength", 0)), "ap": _stat_text(weapon.get("ap", 0)), "damage": _stat_text(weapon.get("damage", "—")), "keywords": " · ".join(keywords)})
	var identity := Combat.UnitAbilities.identity(unit)
	var reference := LocalAbilityReference.for_identity(identity)
	model["ability_source"] = reference.source
	model["ability_source_issue"] = reference.issue
	model["ability_source_warning"] = reference.warning
	model["ability_rules"] = reference.abilities
	for ability: String in Combat.UnitAbilities.RULES.get(identity, []):
		var capability: Dictionary = preload("res://scripts/edition_11/capabilities.gd").KNOWN.get(ability, {})
		model.abilities.append({"name": str(capability.get("name", ability.replace("-", " ").capitalize())), "text": str(capability.get("scope", "Implementation details unavailable for this ability."))})
	if Combat.MarineEnhancements.flesh_is_weak_bearer(state, selected):
		model.abilities.append({"name": "The Flesh is Weak", "text": "The bearer has +1 Toughness and Feel No Pain 5+ against any wound."})
	return model

func _stat_text(value: Variant) -> String:
	if value == null or str(value).is_empty(): return "—"
	if value is float and is_equal_approx(value, roundf(value)): return str(roundi(value))
	return str(value)

func _required_stat_text(value: Variant) -> String:
	if str(value) in ["0", "0.0"]: return "—"
	return _stat_text(value)

func _refresh_command_panel_title() -> void:
	if command_panel_title == null: return
	if not combat_enabled:
		command_panel_title.text = "ACTIONS"
	elif int(state.get("test_winner", 0)) != 0:
		command_panel_title.text = "MATCH RESULT"
	else:
		var phase := str(state.get("phase", ""))
		command_panel_title.text = {"army_selection": "ARMY SELECTION", "start_turn": "START OF TURN", "end_turn": "END OF TURN"}.get(phase, phase.replace("_", " ").to_upper())
		if command_panel_title.text.is_empty(): command_panel_title.text = "ACTIONS"

func _refresh_for_selection() -> void:
	_selection_refresh = true
	_refresh()
	_selection_refresh = false

func _refresh() -> void:
	_ui_refresh_depth += 1
	if _ui_refresh_depth == 1:
		var reuse := _selection_refresh and is_same(_ui_projection_state, state) and _ui_projection_revision == int(state.get("revision", -1))
		if not reuse:
			_ui_projection_state = state
			_ui_projection_revision = int(state.get("revision", -1))
			_ui_actor = Combat.actor(state) if combat_enabled else int(state.active)
			_ui_choices.clear()
			_ui_decisions.clear()
			_ui_gate_errors.clear()
	_refresh_command_panel_title()
	status.visible = true
	if not attack_draft.is_empty() and (not combat_enabled or attack_draft.revision != state.revision or attack_draft.get("pack_hash") != state.get("pack_hash")): attack_draft = {}
	_sync_board()
	_refresh_side_anchors()
	_sync_terrain()
	_sync_ability_tokens()
	var hazard_pending: bool = combat_enabled and not state.get("pending_hazard", {}).is_empty()
	var allocating: bool = combat_enabled and Combat.UnitActions.pending(state).get("kind", "") != "wound" and Combat.Stratagems.pending(state).is_empty() and (hazard_pending or not state.get("pending_attack", {}).is_empty())
	var eligible_recipient_models: Array[int] = []
	if allocating:
		eligible_recipient_models = Combat.Hazard.eligible(state) if hazard_pending else Combat.Allocation.eligible(state)
	var recipient_highlights: Dictionary = {}
	for model: int in eligible_recipient_models: recipient_highlights[model] = true
	var impact_cue := false
	var match_was_presented := not board_presentation_state.is_empty()
	for id: int in pieces:
		var unit: Dictionary = state.units[id]
		var previews: Dictionary = Combat.Reanimation.pending(state).get("current", {}).get("placements", {}) if combat_enabled else {}
		if combat_enabled and Combat.UnitActions.pending(state).get("kind", "") == "ingress": previews = Combat.UnitActions.pending(state).positions
		if combat_enabled and Combat.UnitActions.pending(state).get("kind", "") == "healing": previews = Combat.UnitActions.pending(state).placements
		if combat_enabled and not state.get("unit_abilities", {}).get("transport_window", {}).is_empty(): previews = state.unit_abilities.transport_window.placements
		var display_position: Vector2 = previews.get(id, unit.position)
		var elevation := float(unit.get("elevation", 0.0))
		var wounds := int(unit.get("wounds", 1))
		var on_battlefield := bool(unit.get("on_battlefield", true))
		var alive := wounds > 0 and on_battlefield
		var visible := alive or previews.has(id) or casualty_tweens.has(id)
		var base_offset := 0.04 if pieces[id].get_meta("imported_visual", false) else 0.65
		var target_position := Vector3(display_position.x, elevation + base_offset, display_position.y)
		if allocation_markers.has(id):
			var marker: MeshInstance3D = allocation_markers[id]
			marker.position.y = 0.06 - base_offset
			marker.visible = visible and recipient_highlights.has(id)
		var previous: Dictionary = board_presentation_state.get(id, {})
		if match_was_presented and not previous.is_empty() and int(previous.get("wounds", wounds)) > 0 and wounds == 0:
			impact_cue = true
		var feedback_enabled := _board_motion_enabled()
		var position_changed: bool = not previous.is_empty() and (previous.get("position", display_position) != display_position or absf(float(previous.get("elevation", elevation)) - elevation) > 0.001)
		if combat_enabled and feedback_enabled and not previous.is_empty():
			var previous_wounds := int(previous.get("wounds", wounds))
			var previous_position: Vector2 = previous.get("position", display_position)
			var previous_elevation := float(previous.get("elevation", elevation))
			position_changed = previous_position != display_position or absf(previous_elevation - elevation) > 0.001
			if visible and position_changed:
				pieces[id].position = Vector3(previous_position.x, previous_elevation + base_offset, previous_position.y)
				var move_tween := create_tween()
				move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				move_tween.tween_property(pieces[id], "position", target_position, 0.24)
			if previous_wounds > wounds and wounds > 0:
				_show_board_feedback(id, "%d → %d" % [previous_wounds, wounds], Color("f17969"))
			elif previous_wounds < wounds and wounds > 0:
				_show_board_feedback(id, "%d → %d" % [previous_wounds, wounds], Color("82d49c"))
			elif previous_wounds > 0 and wounds == 0:
				_show_board_feedback(id, "%d → 0 · Destroyed" % previous_wounds, Color("f0b46a"), 0.5)
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
		if not previous.is_empty() and position_changed and (not feedback_enabled or not combat_enabled):
			pieces[id].position = target_position
		elif previous.is_empty() or (not visible and pieces[id].position != target_position):
			pieces[id].position = target_position
		board_presentation_state[id] = {"position": display_position, "elevation": elevation, "wounds": wounds, "on_battlefield": on_battlefield}
		var color := Color("52b9d1") if unit.owner == 1 else Color("e68d5c")
		if unit.moved: color = color.darkened(0.4)
		if combat_enabled and state.units.has(selected) and unit.squad == state.units[selected].squad: color = color.lightened(0.12)
		if id == selected: color = Color("f2df83")
		if previews.has(id): color = Color("a88fea")
		pieces[id].material_override = _material(color)
	if combat_enabled and state.has("last_attack"):
		var hazard: Dictionary = state.last_attack.get("hazardous", {})
		var hazard_key := str(hazard.get("rolls", [])) if int(hazard.get("total", 0)) > 0 else ""
		if not match_was_presented:
			presented_hazard_key = hazard_key
		elif hazard_key != presented_hazard_key:
			presented_hazard_key = hazard_key
			if not hazard_key.is_empty(): impact_cue = true
	elif presented_hazard_key != "":
		presented_hazard_key = ""
	if impact_cue: combat_tray.play_impact()
	_refresh_health_tags()
	session_label.text = "Mode: %s | UDP %d | You: %s" % [mode, PORT, "both sides" if mode == "local" else str(_local_player())]
	_refresh_decision()
	_refresh_local_handoff()
	if combat_enabled:
		if _has_pending_command() and command_panel_pending_revision != int(state.get("revision", -1)):
			command_panel_pending_revision = int(state.get("revision", -1))
			_set_command_panel_open(true)
		elif not _has_pending_command():
			command_panel_pending_revision = -1
	combat_hud.set_focus_available(state.units.has(selected) and pieces.has(selected) and pieces[selected].visible)
	combat_hud.set_side_player(_table_seat())
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
			details.text += "\nPlayer %d: Hazardous • %d mortal wounds remaining\nHazard rolls: %s\nEligible models: %s" % [_match_actor(), state.pending_hazard.remaining, str(state.pending_hazard.resolved.hazardous.rolls), str(Combat.Hazard.eligible(state))]
		if not state.get("pending_attack", {}).is_empty():
			var current: Dictionary = state.pending_attack.current
			if current.phase in ["rolls", "save_decision", "damage_decision"]: details.text += "\nAttack paused: choose Implacable Eradication in unit abilities, or resolve the indicated dice decision." if Combat.UnitActions.pending(state).get("kind", "") == "wound" else "\nAttack paused before the next step: accept or choose a die for Command Re-roll."
			elif current.phase == "precision": details.text += "\nPlayer %d: choose a visible CHARACTER for Precision, or decline." % _match_actor()
			elif current.phase == "order": details.text += "\nPlayer %d: choose the next allocation group. Select one of its models. Saves have not been rolled.\nGroups ordered: %d/%d" % [_match_actor(), current.order.size(), current.groups.size()]
			else:
				var step: Dictionary = current.steps[current.cursor]
				var source := "Devastating Wounds • no save" if step.kind == "devastating" else "Failed save %d" % step.save_roll
				details.text += "\nPlayer %d: allocate to %s\n%s • damage %s • %d remaining" % [_match_actor(), state.squads[current.target].name, source, str(current.damage), current.steps.size() - current.cursor]
				if current.damage is String: details.text += "\nDamage rolls after the recipient is selected."
			details.text += "\nEligible models: " + str(Combat.Allocation.eligible(state))
			if current.phase == "order":
				for group: Dictionary in current.groups: details.text += "\n%s %s • W%d • Sv%d+ • InSv%s" % ["Character" if group.character else "Group", str(group.models), group.profile.wounds_per_model, group.profile.save_target, "—" if group.profile.invulnerable_target == 0 else "%d+" % group.profile.invulnerable_target]
		decision_details.text = details.text.substr(decision_start).strip_edges()
		if state.units.has(selected):
			var unit: Dictionary = state.units[selected]
			var prevention_rules: Variant = Combat.UnitPrevention.rules(state, selected)
			if prevention_rules is Array and not prevention_rules.is_empty(): details.text += "\nFeel No Pain: " + Combat.Attacks.Prevention.describe(prevention_rules)
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
		if state.phase == "fight": details.text += "\nFight: %s • player %d acts • %s" % [state.fight_step, _match_actor(), state.fight_priority]
		if state.phase == "fight" and state.fight_step != "complete":
			var names: Array[String] = []
			for squad: int in Combat.FightQueue.choices(state, _match_actor()): names.append("%d: %s" % [squad, state.squads[squad].name])
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
			details.text += "\nPlayer %d: select a model to remove from the incoherent squad." % _match_actor()
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
	marine_chapter_choice_p1.disabled = mode != "local" or not unit_abilities_choice.button_pressed
	marine_chapter_choice_p2.disabled = mode != "local" or not unit_abilities_choice.button_pressed
	checked_rosters_choice.disabled = mode != "local"
	official_mission_choice.disabled = mode != "local"
	official_primary_choice.disabled = mode != "local" or not official_mission_choice.button_pressed
	official_primary_choice_p2.disabled = mode != "local" or not official_mission_choice.button_pressed
	official_secondary_choice.disabled = mode != "local" or not official_mission_choice.button_pressed
	unit_abilities_choice.disabled = mode != "local"
	awakened_dynasty_choice.disabled = mode != "local"
	count_reroll_choice.disabled = mode != "local"
	lethal_choice.visible = combat_enabled and state.phase == "shooting"
	charge_button.visible = combat_enabled and state.phase == "charge"
	charge_targets.visible = combat_enabled and state.phase == "charge" and not state.pending_charge.is_empty() and state.pending_contact.is_empty()
	var pending_move: bool = combat_enabled and not state.pending_move.is_empty()
	finish_move_button.visible = pending_move
	cancel_move_button.visible = pending_move
	var can_act: bool = not combat_enabled or (_match_actor() == _local_player() and state.test_winner == 0 and not (mode == "host" and guest_id == 0))
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
		for ability: Dictionary in _available_unit_choices(_local_player()):
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
	tactical_focus_button.visible = false
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
	if combat_enabled and state.phase == "fight" and state.fight_step == "consolidate" and state.units.has(selected):
		var consolidation_squad := int(state.units[selected].squad)
		if Combat.MarineEnhancements.singular_will_active(state, consolidation_squad):
			begin_contact_button.text = "Begin consolidation (Singular Will)"
			begin_contact_button.tooltip_text += "\n\nSingular Will: this unit can consolidate up to D3+3 inches. The roll is retained if placement is cancelled."
		var focus_error: String = Combat.DetachmentStratagems.error(state, _local_player(), consolidation_squad, Combat.DetachmentStratagems.TACTICAL_FOCUS)
		if focus_error.is_empty():
			var focus_roll: Dictionary = Combat.DetachmentStratagems.tactical_focus_roll(state, _local_player(), consolidation_squad)
			tactical_focus_button.visible = combat_enabled and not pending_contact
			tactical_focus_button.text = "Resume Tactical Focus (roll retained)" if not focus_roll.is_empty() else "Tactical Focus (1 CP) and begin consolidation"
			tactical_focus_button.tooltip_text = "Tactical Focus costs 1 CP, reduced by an eligible discount. Roll D3+3 inches, then place and confirm this unit's consolidation. A cancelled placement keeps the roll and does not charge CP again."
			tactical_focus_button.disabled = not can_act or state.units[selected].owner != _local_player() or state.units[selected].wounds <= 0
			if not focus_roll.is_empty():
				begin_contact_button.disabled = true
				begin_contact_button.tooltip_text += "\n\nTactical Focus is already spent for this consolidation. Resume the saved roll to finish placement."
	begin_contact_button.disabled = not can_act or not state.units.has(selected)
	if state.units.has(selected): begin_contact_button.disabled = not can_act or state.units[selected].wounds <= 0 or state.units[selected].owner != _local_player()
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.fight_step in ["attacks", "consolidation_reaction"]:
		var squad: int = state.units[selected].squad
		if state.squads[squad].fought or state.squads[squad].overrun_used or not Combat._eligible_fighter(state, squad) or (Combat._engaged(state, squad) and state.squads[squad].was_engaged): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.units.has(selected) and state.units[selected].squad not in Combat.FightQueue.choices(state, _local_player()): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "charge" and state.pending_charge.get("targets", []).is_empty(): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.fight_step == "consolidate" and state.units.has(selected):
		var saved_focus_roll: Dictionary = Combat.DetachmentStratagems.tactical_focus_roll(state, _local_player(), int(state.units[selected].squad))
		if not saved_focus_roll.is_empty(): begin_contact_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.fight_step in ["attacks", "consolidation_reaction"] and begin_contact_button.disabled and not pending_contact:
		begin_contact_button.visible = false
		contact_enemy.visible = false
	confirm_contact_button.visible = pending_contact
	cancel_contact_button.visible = pending_contact
	confirm_contact_button.tooltip_text = "Confirm this charge/pile-in/consolidation preview. Legal placement and coherency are checked before applying the move."
	cancel_contact_button.tooltip_text = "Discard the current placement preview and restore model positions. If Tactical Focus was used, its paid roll remains available to resume."
	cancel_contact_button.text = "Cancel contact placement (retain charge roll)" if pending_contact and state.pending_contact.kind == "charge" else "Cancel contact placement"
	confirm_contact_button.disabled = not can_act
	cancel_contact_button.disabled = not can_act
	movement_choice.visible = false
	begin_move_button.visible = combat_enabled and state.phase == "movement" and not pending_move
	movement_choices.visible = combat_enabled and state.phase == "movement"
	begin_move_button.disabled = not can_act
	if begin_move_button.visible:
		begin_move_button.disabled = not can_act or not Combat.movement_choice_error_after_command(state, _local_player(), selected, MOVE_TYPES[movement_choice.selected], _ui_command_error(_local_player())).is_empty()
	movement_choice.disabled = not can_act
	escape_wound_button.visible = pending_move and state.pending_move.hazard_remaining > 0
	var escape_decision := _pending_ui_decision(["escape-wounds"])
	var selected_escape_option := false
	for option: Dictionary in escape_decision.get("legal_options", []):
		if int(option.get("model", -1)) == selected:
			selected_escape_option = true
			break
	escape_wound_button.disabled = not can_act or not selected_escape_option
	finish_move_button.disabled = not can_act
	cancel_move_button.disabled = not can_act
	if pending_move and Combat.UnitActions.TargetAuguryWeb.start_decision_pending(state, int(state.pending_move.get("squad", -1))): finish_move_button.disabled = true
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
	charge_button.disabled = combat_enabled and (_match_actor() != _local_player() or state.test_winner != 0 or (mode == "host" and guest_id == 0))
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
				if pool.get("snap_shooting", false): log_text += "Snap Shooting: hits on unmodified %d+\n" % int(pool.get("snap_hit_threshold", 6))
				if pool.get("plunging_fire", false): log_text += "Plunging Fire: BS improved by 1\n"
				for prevention: Dictionary in pool.get("prevention_rolls", []):
					if prevention.target > 0: log_text += "Feel No Pain: %d+ %s • %d prevented\n" % [prevention.target, str(prevention.rolls), prevention.prevented]
				if pool.get("devastating_wounds", 0) > 0: log_text += "Devastating Wounds: %d critical wounds • %d mortal damage • %d normal damage\n" % [pool.devastating_wounds, pool.mortal_damage_applied, pool.normal_damage_applied]
				for generated: Dictionary in pool.get("attack_generation", []):
					if generated.expression is String or generated.bonus > 0: log_text += "A %s: %s + %d = %d\n" % [str(generated.expression), str(generated.value), generated.bonus, generated.total]
				for damage: Dictionary in pool.get("damage_rolls", []):
					if damage.expression is String: log_text += "D %s: %s = %d\n" % [str(damage.expression), str(damage.rolls), damage.value]
				for retention: Dictionary in pool.get("casualty_retention_rolls", []):
					var retention_outcome := "remained on the battlefield" if bool(retention.get("kept", false)) else "was removed"
					log_text += "%s: model %d rolled D6 %d %+d = %d; %s.\n" % [str(retention.get("rule_name", "Model retention")), int(retention.get("model", -1)), int(retention.get("roll", 0)), int(retention.get("modifier", 0)), int(retention.get("total", 0)), retention_outcome]
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
	end_button.disabled = mode != "local" and (_local_player() != (_match_actor() if combat_enabled else state.active) or (mode == "host" and guest_id == 0))
	if combat_enabled and not state.pending_charge.is_empty(): end_button.disabled = true
	if pending_move: end_button.disabled = true
	if pending_contact:
		end_button.text = "Confirm or cancel contact placement first"
		end_button.disabled = true
	if coherency_button.visible:
		end_button.text = "Resolve coherency casualties first"
		end_button.disabled = true
	if combat_enabled and state.phase == "fight" and state.fight_step in ["attacks", "consolidation_reaction"] and not pending_contact:
		var options := Combat.FightQueue.choices(state, _match_actor())
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
	_refresh_vowed_target()
	_refresh_command_reaction()
	_refresh_attack_plan()
	allocate_button.visible = allocating
	allocate_button.text = "Allocate 1 Hazardous wound" if hazard_pending else "Allocate this attack"
	var precision_pending: bool = allocating and not hazard_pending and state.pending_attack.current.phase == "precision"
	precision_skip.visible = precision_pending
	precision_skip.disabled = not can_act
	if hazard_pending and selected in Combat.Hazard.eligible(state):
		allocate_button.text = "Allocate Hazardous wound to " + _model_role_label(selected)
	if precision_pending:
		allocate_button.text = "Use Precision on " + _model_role_label(selected) if selected in Combat.Allocation.eligible(state) else "Confirm Precision"
	elif allocating and not hazard_pending:
		if state.pending_attack.current.phase == "order": allocate_button.text = "Confirm allocation group next"
		elif selected in Combat.Allocation.eligible(state):
			var current: Dictionary = state.pending_attack.current
			var cursor := int(current.get("cursor", 0))
			var steps: Array = current.get("steps", [])
			if cursor < steps.size() and steps[cursor].get("kind", "") == "devastating":
				allocate_button.text = "Allocate Devastating Wounds to " + _model_role_label(selected)
			else: allocate_button.text = "Allocate attack to " + _model_role_label(selected)
	allocate_button.disabled = not allocating or not can_act or not (Combat.Hazard.choice_error(state, _local_player(), selected) if hazard_pending else Combat.Allocation.choice_error(state, _local_player(), selected)).is_empty()
	if precision_pending and selected < 0: allocate_button.disabled = true
	if allocating:
		for control in [end_button, charge_button, begin_contact_button, tactical_focus_button, begin_move_button, action_button, plan_begin, plan_confirm, coherency_button, escape_wound_button, abandon_move_button, finish_move_button, cancel_move_button, confirm_contact_button, cancel_contact_button]: control.disabled = true
	_refresh_defense_steps(allocating, hazard_pending, eligible_recipient_models)
	_refresh_action_groups()
	_refresh_unit_choices()
	_refresh_movement_choices()
	_refresh_contact_elevation_options()
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
	_keep_model_card_visible()
	if match_tabs.current_tab == 3: action_groups.phase.container.visible = false
	if combat_enabled and Combat.UnitActions.battle_actor(state) > 0:
		end_button.text = "Finish start-of-battle choices first"
		end_button.disabled = true
		end_button.tooltip_text = "Place any optional Teleport Homers, then choose Finish start-of-battle declarations in the Command panel."
	if combat_enabled and state.phase == "army_selection": status.visible = false
	if combat_enabled and (_has_pending_command() or placement_reason.visible): status.visible = false
	_promote_primary_actions()
	call_deferred("_refresh_decision_camera")
	_ui_refresh_depth -= 1

func _refresh_choice_ownership() -> void:
	_refresh_waiting_inspection()
	if not combat_enabled or mode == "local" or _match_actor() == _local_player(): return
	var own_unit_choices := not _available_unit_choices(_local_player()).is_empty()
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
	waiting_unit_picker.visible = combat_enabled and mode != "local" and _match_actor() != _local_player() and int(state.get("test_winner", 0)) == 0 and state.phase != "army_selection"
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
	if mode == "local" or _match_actor() == _local_player() or unit.owner != _local_player() or unit.wounds <= 0 or not unit.get("on_battlefield", true): return
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
	var save_target_notice := _prepare_new_match_save_target()
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
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
	var hazard_lost := 0
	var hazard_prevented := 0
	if int(hazard.get("total", 0)) > 0:
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
		compact_lines.append("%s · %d attacks · %d damage · %d destroyed" % [target_name, totals.attacks, totals.damage, totals.destroyed])
	if prevented > 0: compact_lines.append("Feel No Pain prevented %d wounds" % prevented)
	if int(hazard.get("total", 0)) > 0: compact_lines.append("Hazardous · %d wounds lost · %d prevented" % [hazard_lost, hazard_prevented])
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
	dice_visual_omitted = 0
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
			var final_hits: Array = pool.final_hit_rolls
			for index in range(final_hits.size()):
				var value: int = int(final_hits[index])
				var outcome := _recorded_roll_outcome(pool, "hit_outcomes", index, value)
				if outcome.is_empty(): shown += _add_die_tile("HIT", value, Color("327c96"), shown)
				else:
					var hit := _roll_outcome_visual("hit", outcome)
					shown += _add_die_tile(str(hit.label), value, hit.color, shown, str(hit.symbol))
		else:
			for value: int in pool.get("hit_rolls", []): shown += _add_die_tile("HIT", value, Color("327c96"), shown)
		if pool.has("final_wound_rolls"):
			var final_wounds: Array = pool.final_wound_rolls
			for index in range(final_wounds.size()):
				var value: int = int(final_wounds[index])
				var outcome := _recorded_roll_outcome(pool, "wound_outcomes", index, value)
				if outcome.is_empty(): shown += _add_die_tile("WOUND", value, Color("8a6635"), shown)
				else:
					var wound := _roll_outcome_visual("wound", outcome)
					shown += _add_die_tile(str(wound.label), value, wound.color, shown, str(wound.symbol))
		else:
			for value: int in pool.get("wound_rolls", []): shown += _add_die_tile("WOUND", value, Color("8a6635"), shown)
		var saves: Array = pool.get("save_rolls", [])
		for index in range(saves.size()):
			var value: int = int(saves[index])
			var outcome := _recorded_roll_outcome(pool, "save_outcomes", index, value)
			if outcome.is_empty(): shown += _add_die_tile("SAVE", value, Color("526d52"), shown)
			else:
				var save_visual := _roll_outcome_visual("save", outcome)
				shown += _add_die_tile(str(save_visual.label), value, save_visual.color, shown, str(save_visual.symbol), not bool(outcome.get("success", false)))
		for record: Dictionary in pool.get("damage_rolls", []):
			for value: int in record.get("rolls", []):
				shown += _add_die_tile("D6", value, Color("9a4d45"), shown)
			var damage_note := "Damage %s → %d" % [str(record.get("expression", "?")), int(record.get("value", 0))]
			if not record.get("rolls", []).is_empty(): damage_note = "Damage %s: D6 %s → %d" % [str(record.get("expression", "?")), str(record.rolls), int(record.get("value", 0))]
			_add_die_note(damage_note)
		for prevention: Dictionary in pool.get("prevention_rolls", []):
			var prevention_rolls: Array = prevention.get("rolls", [])
			for index in range(prevention_rolls.size()):
				var value: int = int(prevention_rolls[index])
				var outcome := _recorded_roll_outcome(prevention, "roll_outcomes", index, value)
				if outcome.is_empty(): shown += _add_die_tile("FNP", value, Color("526d52"), shown)
				else:
					var prevention_visual := _roll_outcome_visual("prevention", outcome)
					shown += _add_die_tile(str(prevention_visual.label), value, prevention_visual.color, shown, str(prevention_visual.symbol))
			if not prevention.get("rolls", []).is_empty(): _add_die_note(_prevention_roll_note(prevention))
	var hazard: Dictionary = last.get("hazardous", {})
	for value: int in hazard.get("rolls", []): shown += _add_die_tile("HAZ", value, Color("7654a3"), shown)
	if not hazard.get("rolls", []).is_empty(): _add_die_note("Hazardous: %s → %d mortal wounds" % [str(hazard.rolls), int(hazard.get("total", 0))])
	for prevention: Dictionary in hazard.get("prevention", []):
		var prevention_rolls: Array = prevention.get("rolls", [])
		for index in range(prevention_rolls.size()):
			var value: int = int(prevention_rolls[index])
			var outcome := _recorded_roll_outcome(prevention, "roll_outcomes", index, value)
			if outcome.is_empty(): shown += _add_die_tile("FNP", value, Color("526d52"), shown)
			else:
				var prevention_visual := _roll_outcome_visual("prevention", outcome)
				shown += _add_die_tile(str(prevention_visual.label), value, prevention_visual.color, shown, str(prevention_visual.symbol))
		if not prevention.get("rolls", []).is_empty(): _add_die_note(_prevention_roll_note(prevention))
	if dice_visual_omitted > 0: _add_die_note("Showing the first %d faces. %d more are in the combat tray." % [shown, dice_visual_omitted])
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
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("cbd5dc"))
	dice_visual_rolls.add_child(note)

func _recorded_roll_outcome(pool: Dictionary, key: String, index: int, value: int) -> Dictionary:
	var outcomes: Array = pool.get(key, [])
	if index < 0 or index >= outcomes.size() or not outcomes[index] is Dictionary: return {}
	var outcome: Dictionary = outcomes[index]
	return outcome if int(outcome.get("roll", -1)) == value else {}

func _prevention_roll_note(prevention: Dictionary) -> String:
	var rolls: Array = prevention.get("rolls", [])
	var faces: Array[String] = []
	var classified := 0
	for index in range(rolls.size()):
		var value := int(rolls[index])
		var face := str(value)
		var outcome := _recorded_roll_outcome(prevention, "roll_outcomes", index, value)
		if not outcome.is_empty():
			face += "✓" if outcome.get("success", false) else "×"
			classified += 1
		faces.append(face)
	var note := "Feel No Pain %d+: D6 %s" % [int(prevention.get("target", 0)), ", ".join(faces)]
	if classified == rolls.size():
		note += " → %d wounds prevented" % int(prevention.get("prevented", 0))
	else:
		var missing := rolls.size() - classified
		note += " · %d wounds prevented · %d per-die outcome%s unavailable" % [int(prevention.get("prevented", 0)), missing, "" if missing == 1 else "s"]
	return note

func _roll_outcome_visual(stage: String, outcome: Dictionary) -> Dictionary:
	var passed: bool = outcome.get("success", false)
	if outcome.get("critical", false): return {"label": "CRIT", "symbol": "★", "color": Color("997b32")}
	var label := "HIT" if passed else "MISS"
	if stage == "wound": label = "WOUND" if passed else "FAIL"
	elif stage == "save": label = "PASS" if passed else "FAIL"
	elif stage == "prevention": label = "FNP"
	return {"label": label, "symbol": "✓" if passed else "×", "color": Color("397d59") if passed else Color("884b4b")}

func _add_die_tile(stage: String, value: int, color: Color, shown: int, marker: String = "", failed_save: bool = false) -> int:
	if shown >= 72:
		dice_visual_omitted += 1
		return 0
	var tile := PanelContainer.new()
	var animate: bool = dice_visual.is_visible_in_tree() and dice_animation_toggle != null and dice_animation_toggle.button_pressed
	var style := StyleBoxFlat.new()
	style.bg_color = Color("6b3030") if failed_save else color
	style.border_color = Color("ff766d")
	style.set_border_width_all(3 if failed_save else 0)
	style.set_corner_radius_all(2 if failed_save else (0 if marker == "×" else (12 if marker == "★" else 5)))
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
	tile.custom_minimum_size = Vector2(118, 40) if failed_save else Vector2(76, 34)
	tile.pivot_offset = Vector2(59, 20) if failed_save else Vector2(38, 17)
	tile.tooltip_text = "Recorded failed save. The face is already resolved." if failed_save else ""
	var caption := "FAILED SAVE %d" % value if failed_save else ("%s %s %d" % [marker, stage, value] if not marker.is_empty() else "%s %d" % [stage, value])
	if animate:
		face.text = "SAVE D6" if failed_save else "%s D6" % stage
		pips.value = 0
		tile.scale = Vector2(0.88, 0.88)
		tile.rotation = 0.0
	else:
		face.text = caption
	dice_visual_rolls.add_child(tile)
	if animate:
		var reveal := create_tween()
		reveal.tween_interval(minf(float(shown) * 0.006, 0.35))
		reveal.tween_property(tile, "rotation", deg_to_rad(150), 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		reveal.tween_property(tile, "rotation", deg_to_rad(-150), 0.09).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		reveal.tween_property(tile, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		reveal.parallel().tween_property(tile, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		reveal.tween_callback(func():
			face.text = caption
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
		var ordinal := tag.get("ordinal") as Label3D
		if ordinal != null:
			ordinal.visible = combat_enabled and model_id == selected and live_on_board
			if ordinal.visible: ordinal.text = ArmyList.model_label(state, model_id)
		var shocked := tag.get("shocked") as Label3D
		if shocked != null:
			var squad_shocked: bool = combat_enabled and live_on_board and state.squads.has(unit.squad) and bool(state.squads[unit.squad].get("battle_shocked", false))
			shocked.visible = squad_shocked
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

func _model_role_label(model: int) -> String:
	var unit: Dictionary = state.units[model]
	var label := ArmyList.model_label(state, model)
	if Combat.Allocation.Groups.character(unit): label += " · Character"
	return label

func _model_choice_label(model: int) -> String:
	var unit: Dictionary = state.units[model]
	return "%s • %s • %d/%d wounds" % [state.squads[unit.squad].name, _model_role_label(model), unit.wounds, unit.max_wounds]

func _model_equipment_labels(model_id: int) -> Array[String]:
	var labels: Array[String] = []
	for melee: bool in [false, true]:
		for option: Dictionary in Combat.AttackPlan.Equipment.choices(state, model_id, melee):
			var weapon_label := str(option.get("label", "")).strip_edges()
			var label := ("Melee: " if melee else "Ranged: ") + weapon_label
			if not weapon_label.is_empty() and label not in labels: labels.append(label)
	return labels

func _distinctive_model_equipment(model_ids: Array[int]) -> Dictionary:
	var distinctive_by_model: Dictionary = {}
	if model_ids.is_empty() or not state.units.has(model_ids[0]): return distinctive_by_model
	var squad_id := int(state.units[model_ids[0]].get("squad", -1))
	var labels_by_model: Dictionary = {}
	var occurrence_count: Dictionary = {}
	for other_id: int in state.units:
		var other: Dictionary = state.units[other_id]
		if int(other.get("squad", -1)) != squad_id or int(other.get("wounds", 0)) <= 0: continue
		var labels := _model_equipment_labels(other_id)
		labels_by_model[other_id] = labels
		for label: String in labels: occurrence_count[label] = int(occurrence_count.get(label, 0)) + 1
	for model_id: int in model_ids:
		var distinctive: Array[String] = []
		for label: String in labels_by_model.get(model_id, []):
			if int(occurrence_count.get(label, 0)) == 1: distinctive.append(label)
		distinctive_by_model[model_id] = distinctive
	return distinctive_by_model

func _refresh_defense_steps(allocating: bool, hazard: bool, eligible_models: Array[int]) -> void:
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
	var eligible := eligible_models
	var equipment_hints := _distinctive_model_equipment(eligible)
	var desired_card_height := 0.0
	for model: int in eligible:
		var unique_equipment: Array[String] = equipment_hints.get(model, [])
		desired_card_height += 60.0 if not unique_equipment.is_empty() else 44.0
	recipient_scroll.custom_minimum_size.y = minf(132.0, maxf(44.0, desired_card_height))
	for model: int in eligible:
		defense_picker.add_item(_model_choice_label(model), model)
		defense_picker.set_item_tooltip(defense_picker.item_count - 1, _model_choice_label(model))
		if model == selected: defense_picker.select(defense_picker.item_count - 1)
		var card_text := "%s%s · %d/%d wounds" % ["✓ " if model == selected else "", _model_role_label(model), int(state.units[model].wounds), int(state.units[model].max_wounds)]
		var consequence := ""
		if model == selected and not hazard and str(state.get("pending_attack", {}).get("current", {}).get("phase", "")) == "damage":
			consequence = _allocation_consequence(_damage_allocation_preview(model, state.pending_attack.current))
			if not consequence.is_empty(): card_text += "\n" + consequence
		var unique_equipment: Array[String] = equipment_hints.get(model, [])
		if not unique_equipment.is_empty():
			var visible_equipment: Array[String] = []
			for index in range(mini(2, unique_equipment.size())): visible_equipment.append(unique_equipment[index])
			if unique_equipment.size() > visible_equipment.size(): visible_equipment.append("+%d more" % (unique_equipment.size() - visible_equipment.size()))
			card_text += "\nUnique: " + " · ".join(visible_equipment)
		var card_row := HBoxContainer.new()
		card_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_row.add_theme_constant_override("separation", 8)
		recipient_cards.add_child(card_row)
		var wound_mark := CombatSymbol.new()
		var wounds_remaining := int(state.units[model].wounds)
		var wounds_maximum := maxi(1, int(state.units[model].max_wounds))
		wound_mark.kind = "Wounds remaining"
		wound_mark.remaining = wounds_remaining
		wound_mark.maximum = wounds_maximum
		wound_mark.tooltip_text = "%d of %d wounds remaining." % [wounds_remaining, wounds_maximum]
		if wounds_maximum > 6: wound_mark.tooltip_text += " The mark shows the proportion; the numbers are exact."
		wound_mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		card_row.add_child(wound_mark)
		var card := _button(card_row, card_text, func():
			selected = model
			_refresh()
		)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size.y = (78 if not consequence.is_empty() else 60) if not unique_equipment.is_empty() else (62 if not consequence.is_empty() else 44)
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.tooltip_text = _model_choice_label(model) + ("\nUnique equipment: " + ", ".join(unique_equipment) if not unique_equipment.is_empty() else "") + ("\n" + consequence if not consequence.is_empty() else "") + "\nSelect this recipient, then confirm allocation."
		card.disabled = _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
	defense_picker.disabled = _match_actor() != _local_player() or (mode == "host" and guest_id == 0)
	var stage := "Allocate Hazardous wounds" if hazard else str(state.pending_attack.current.phase)
	var instruction := "Choose an eligible model, then confirm one damaging attack. The listed models reflect current allocation priority."
	if stage == "precision":
		stage = "1 • Optional Precision"
		instruction = "Attacker: choose a visible character and confirm, or decline Precision."
	elif stage == "order":
		stage = "2 • Defense group order"
		instruction = "Defender: choose a model from the next group. Confirm each group before saves are rolled."
	elif not hazard:
		stage = "3 • Allocate damage"
		if state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": instruction = "Choose an eligible recipient for Devastating Wounds. This packet allows no save; listed models reflect current allocation priority."
	else: instruction = "Choose and confirm one Hazardous mortal wound recipient. Priority: wounded non-Characters, other non-Characters, wounded Characters, then other Characters."
	defense_steps.text = "%s\nPlayer %d decides. %s" % [stage, _match_actor(), instruction]
	defense_steps.text += "\nSelected: " + (_model_choice_label(selected) if selected in eligible else "no eligible model")
	if not hazard: defense_steps.text += "\nTarget unit: " + state.squads[state.pending_attack.current.target].name
	defense_reference.text = defense_steps.text
	var compact_stage := stage.trim_prefix("1 • ").trim_prefix("2 • ").trim_prefix("3 • ")
	var compact_instruction := "Choose a recipient, then confirm."
	if stage == "1 • Optional Precision": compact_instruction = "Choose a character, or skip Precision."
	elif stage == "2 • Defense group order": compact_instruction = "Choose the next group before saves."
	elif hazard: compact_instruction = "Choose a recipient for 1 mortal wound."
	elif stage == "3 • Allocate damage" and state.pending_attack.current.steps[state.pending_attack.current.cursor].kind == "devastating": compact_instruction = "No save · choose a recipient."
	defense_steps.text = "%s\n%s" % [compact_stage, compact_instruction]
	if not hazard: defense_steps.text += "\n" + state.squads[state.pending_attack.current.target].name
	if selected in eligible and not hazard and state.pending_attack.current.phase == "damage":
		var preview := _damage_allocation_preview(selected, state.pending_attack.current)
		defense_steps.text += "\n" + preview
		defense_reference.text += "\n" + preview

func _allocation_consequence(preview: String) -> String:
	if preview.contains("Feel No Pain"): return "Feel No Pain can still change the wounds."
	if preview.contains("not yet known") or preview.contains("not determined") or preview.contains("uncertain"): return "Remaining wounds are not settled yet."
	var preview_at := preview.find("Preview:")
	if preview_at >= 0: return preview.substr(preview_at).strip_edges()
	var possible_at := preview.find("Possible remaining")
	if possible_at >= 0: return preview.substr(possible_at).strip_edges()
	return ""

func _damage_allocation_preview(model: int, current: Dictionary) -> String:
	var damage_spec := Combat.Attacks.RandomStat.spec(current.get("damage", 1))
	if not str(damage_spec.get("error", "")).is_empty(): return "Damage and remaining wounds are not yet known."
	var raw_minimum := int(damage_spec.get("minimum", 0))
	var raw_maximum := int(damage_spec.get("maximum", raw_minimum))
	var minimum := Combat.UnitAbilities.damage(state, model, raw_minimum)
	var maximum := Combat.UnitAbilities.damage(state, model, raw_maximum)
	var raw_range := str(raw_minimum) if raw_minimum == raw_maximum else "%d–%d" % [raw_minimum, raw_maximum]
	var effective_range := str(minimum) if minimum == maximum else "%d–%d" % [minimum, maximum]
	var preview := "Damage preview: %s" % effective_range
	if minimum != raw_minimum or maximum != raw_maximum:
		preview += " after supported damage reduction (raw %s)" % raw_range
	preview += " before prevention."
	var cursor := int(current.get("cursor", 0))
	var steps: Array = current.get("steps", [])
	if cursor >= steps.size():
		preview += " Remaining wounds are not determined yet."
		return preview
	var step: Dictionary = steps[cursor]
	var kind := "normal" if step.get("kind", "normal") == "normal" else "mortal"
	var special_kind := "psychic" if current.get("weapon", {}).get("keywords", {}).get("psychic", false) else ""
	var prevention_rules: Variant = Combat.UnitPrevention.rules(state, model)
	var prevention_error := Combat.Attacks.Prevention.validate(prevention_rules)
	if not prevention_error.is_empty():
		preview += " Remaining wounds are uncertain because prevention rules are unresolved."
		return preview
	var best_prevention_target := 0
	for rule: Dictionary in prevention_rules:
		if rule.against in ["any", kind, special_kind] and (best_prevention_target == 0 or rule.target < best_prevention_target):
			best_prevention_target = rule.target
	if best_prevention_target > 0:
		preview += " Best applicable Feel No Pain: %d+; final wounds depend on its rolls." % best_prevention_target
		return preview
	var before := int(state.units[model].wounds)
	var lowest_remaining := maxi(0, before - maximum)
	var highest_remaining := maxi(0, before - minimum)
	if lowest_remaining == highest_remaining:
		if lowest_remaining == 0: preview += " Preview: %d → 0 wounds before any post-destruction effect." % before
		else: preview += " Preview: %d → %d wounds remaining." % [before, lowest_remaining]
	else:
		preview += " Possible remaining wounds: %d–%d." % [lowest_remaining, highest_remaining]
		if lowest_remaining == 0: preview += " Destruction depends on the damage result."
	return preview

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
	if _match_actor() != _local_player() or (mode == "host" and guest_id == 0):
		defense_steps.text = "Waiting"
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
	if not state.units.has(selected) or state.units[selected].owner != _match_actor(): return false
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
	tactical_focus_button.disabled = true
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
			var point_blank_preview: bool = not attack_draft.melee and Combat.DetachmentStratagems.point_blank_brutality_available(state, _local_player(), attack_draft.squad)
			for target: int in Combat.AttackPlan.legal_targets(state, selected, attack_draft.melee, choice.weapon, choice.profile, attack_draft.get("indirect_shooting", false), point_blank_preview): plan_target.add_item("Target: " + state.squads[target].name, target)
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
	if not attack_draft.melee and Combat.DetachmentStratagems.point_blank_brutality_available(state, _local_player(), attack_draft.squad):
		plan_summary.text += "\nPoint-Blank Brutality: after confirming, choose whether to spend 1 CP; non-Blast ranged attacks gain Close-Quarters and Ignores Cover for this phase."
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
	var preview_state := state
	if not attack_draft.melee and Combat.DetachmentStratagems.point_blank_brutality_available(state, _local_player(), attack_draft.squad):
		preview_state = state.duplicate(true)
		preview_state._point_blank_legality_preview = true
	var prepared := Combat.AttackPlan.prepare(preview_state, attack_draft.squad, attack_draft.melee, attack_draft.entries, lethal_choice.button_pressed, attack_draft.get("hail_target", -1), attack_draft.get("indirect_shooting", false))
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
	var surfaces: Array = Combat.Terrain.surfaces(state)
	var signature := var_to_str(areas) + var_to_str(surfaces) + var_to_str(state.get("mission", {}).get("objectives", [])) + str(state.get("phase", "") == "deployment") + var_to_str(state.get("deployment", {}).get("zones", {}))
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
	for surface: Dictionary in surfaces:
		var bounds: Rect2 = surface.bounds
		var center := bounds.get_center()
		var elevation := float(surface.elevation)
		_box(Vector3(bounds.size.x, 0.08, bounds.size.y), Vector3(center.x, elevation - 0.04, center.y), Color("73858b"), terrain_root)
		var label := Label3D.new()
		label.text = "%s · %s in" % [str(surface.name), _stat_text(elevation)]
		label.font_size = 32
		label.pixel_size = 0.009
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(center.x, elevation + 0.25, center.y)
		terrain_root.add_child(label)
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
	var save_target_notice := _prepare_new_match_save_target()
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
	if not save_target_notice.is_empty(): status.text += " " + save_target_notice
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
	awaiting_initial_authoritative_snapshot = true
	match_session.guest_ready()
	selected = -1
	status.text = "Connecting…"
	_refresh()

func _offline(message: String) -> void:
	session_transport.reset()
	mode = "local"
	awaiting_initial_authoritative_snapshot = false
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
		var notice_prefix := "Autosave paused: " if active_save_slot < 1 and not autosave_error.begins_with("History:") else "Autosave failed: "
		status.text = notice_prefix + autosave_error

func _save_config() -> Dictionary:
	var saved_event_layout := str(state.get("mission", {}).get("terrain_layout", _selected_official_terrain_layout()))
	var saved_primary_missions: Dictionary = _selected_official_primary_missions()
	if Combat.Mission.enabled(state): saved_primary_missions = Combat.Mission.primary_assignments(state)
	var saved_primary_mission := str(saved_primary_missions.get(1, _selected_official_primary_mission()))
	var saved_secondary_pair := str(state.get("mission", {}).get("secondary_pair_id", _selected_official_secondary_pair()))
	var selected_detachment := marine_detachment if combat_doctrines else "none"
	var selected_detachments: Dictionary = _selected_marine_detachments() if combat_doctrines else {1: "none", 2: "none"}
	var selected_chapters: Dictionary = _selected_marine_chapters()
	# The manifest preserves both declarations even when only one player is Marine.
	var match_manifest: Dictionary = state.get("match_manifest", {})
	var declared_detachments: Dictionary = match_manifest.get("marine_detachments", {})
	if not declared_detachments.is_empty(): selected_detachments = declared_detachments.duplicate(true)
	if match_manifest.has("marine_detachment"): selected_detachment = str(match_manifest.marine_detachment)
	var declared_chapters: Dictionary = match_manifest.get("marine_chapter_selections", match_manifest.get("marine_chapters", {}))
	if not declared_chapters.is_empty(): selected_chapters = declared_chapters.duplicate(true)
	return {"combat_enabled": combat_enabled, "saved_army_mode": saved_army_mode, "prepared_match": prepared_match, "terrain_layout": terrain_layout, "mission_id": mission_id, "squads_per_side": squads_per_side, "manual_allocation": manual_allocation, "varied_equipment": varied_equipment, "allocation_practice": allocation_practice, "core_stratagems": core_stratagems, "movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls, "save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls, "hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls, "count_rerolls": count_rerolls, "objective_secured": objective_secured, "implacable_eradication": implacable_eradication, "hail_of_bolts": hail_of_bolts, "oath_of_moment": oath_of_moment, "reanimation_protocols": reanimation_protocols, "combat_doctrines": combat_doctrines, "marine_detachment": selected_detachment, "marine_detachments": selected_detachments, "marine_chapters": selected_chapters, "awakened_dynasty": awakened_dynasty, "unit_abilities": unit_abilities, "official_mission": official_mission, "official_terrain_layout": saved_event_layout, "official_primary_mission": saved_primary_mission, "official_primary_missions": saved_primary_missions, "official_secondary_pair": saved_secondary_pair, "checked_rosters": checked_rosters}

func _prepared_options_for_restore(config: Dictionary, saved_state: Dictionary) -> Dictionary:
	var legacy_primary := str(config.get("official_primary_mission", "battlefield-dominance"))
	var primary_ids: Dictionary = {1: legacy_primary, 2: legacy_primary}
	var configured_primary_ids: Variant = config.get("official_primary_missions", {})
	if configured_primary_ids is Dictionary: primary_ids = configured_primary_ids.duplicate(true)
	var options := {"manual_allocation": config.manual_allocation, "varied_equipment": config.varied_equipment, "core_stratagems": config.core_stratagems, "movement_rerolls": config.movement_rerolls, "attack_rerolls": config.attack_rerolls, "save_rerolls": config.save_rerolls, "damage_rerolls": config.damage_rerolls, "hazard_rerolls": config.hazard_rerolls, "escape_rerolls": config.escape_rerolls, "count_rerolls": config.count_rerolls, "objective_secured": config.objective_secured, "implacable_eradication": config.implacable_eradication, "hail_of_bolts": config.hail_of_bolts, "oath_of_moment": config.oath_of_moment, "reanimation_protocols": config.reanimation_protocols, "combat_doctrines": config.combat_doctrines, "marine_detachment": config.marine_detachment, "marine_detachments": config.get("marine_detachments", {1: config.marine_detachment, 2: config.marine_detachment}), "awakened_dynasty": config.awakened_dynasty, "unit_abilities": config.unit_abilities, "official_mission": config.official_mission, "primary_mission": legacy_primary, "primary_missions": primary_ids, "secondary_pair": config.get("official_secondary_pair", Combat.Mission.DEFAULT_SECONDARY_PAIR), "terrain_layout": str(config.official_terrain_layout if config.official_mission else config.terrain_layout), "checked_rosters": config.checked_rosters}
	var manifest: Dictionary = saved_state.get("match_manifest", {})
	if manifest.get("marine_chapter_rules", "") == ChapterRules.ID:
		options.marine_chapters = config.get("marine_chapters", {1: "", 2: ""}).duplicate(true)
	return options

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
	if not autosave_error.is_empty() and state.get("phase") != "army_selection":
		var notice_prefix := "Snapshot autosave paused: " if active_save_slot < 1 and not autosave_error.begins_with("History:") else "Save failed: "
		page.notice = notice_prefix + autosave_error
	return page

func _save_snapshot() -> String:
	if state.get("phase") == "army_selection": return "Complete both army selections before saving."
	if active_save_slot < 1:
		journal.storage_directory = match_journal_directory
		var history_error: String = journal.capture(state)
		if not history_error.is_empty(): return "History: " + history_error
		return SAVE_SLOTS_FULL_NOTICE
	return _save_snapshot_to_slot(active_save_slot)

func _save_snapshot_to_slot(target_slot: int) -> String:
	var target_path := MatchSave.slot_path(target_slot)
	if target_path.is_empty(): return "Choose a valid local save slot."
	if state.get("phase") == "army_selection": return "Complete both army selections before saving."
	var pending_state_error := Combat.MatchActor.pending_state_error(state)
	if not pending_state_error.is_empty(): return pending_state_error
	journal.storage_directory = match_journal_directory
	var error: String = journal.capture(state)
	if not error.is_empty(): return "History: " + error
	var target_journal_directory := MatchSave.journal_directory(target_slot)
	var save_checkpoint := journal.checkpoint()
	var copied_journal_id := ""
	var source_journal_id: String = journal.id
	var copied_retired_ids: Array[String] = journal.retired_ids.duplicate()
	var previous_save: Dictionary = {}
	if MatchSave.slot_has_file(target_slot):
		previous_save = MatchSave.read(target_path)
	var previous_backup: Dictionary = MatchSave.read_backup(target_slot)
	for previous_slot_save: Dictionary in [previous_save, previous_backup]:
		if not previous_slot_save.is_empty() and not previous_slot_save.has("error"):
			var previous_reference: Variant = previous_slot_save.get("journal", {})
			if previous_reference is Dictionary:
				var previous_id := str(previous_reference.get("id", ""))
				if MatchJournal.valid_id(previous_id) and previous_id != source_journal_id and previous_id not in copied_retired_ids:
					copied_retired_ids.append(previous_id)
				var previous_retired: Variant = previous_reference.get("retired_ids", [])
				if previous_retired is Array:
					for previous_retired_id: Variant in previous_retired:
						if previous_retired_id is String and MatchJournal.valid_id(previous_retired_id) and previous_retired_id != source_journal_id and previous_retired_id not in copied_retired_ids:
							copied_retired_ids.append(previous_retired_id)
	if target_slot != active_save_slot:
		var copied: Dictionary = journal.copy_to_directory(target_journal_directory)
		if not str(copied.get("error", "")).is_empty(): return "History: " + str(copied.error)
		copied_journal_id = str(copied.get("id", ""))
		save_checkpoint = copied.get("checkpoint", {})
		if source_journal_id not in copied_retired_ids: copied_retired_ids.append(source_journal_id)
	if copied_retired_ids.is_empty(): save_checkpoint.erase("retired_ids")
	else: save_checkpoint.retired_ids = copied_retired_ids.duplicate()
	error = MatchSave.write(state, _save_config(), rng.state, attack_draft, target_path, host_session, save_checkpoint, previous_save, Combat.MatchActor.player(state))
	if not error.is_empty():
		if not copied_journal_id.is_empty(): journal.remove_copy(copied_journal_id, target_journal_directory)
		return error
	if not copied_journal_id.is_empty():
		journal.id = copied_journal_id
		journal.storage_directory = target_journal_directory
	journal.retired_ids = copied_retired_ids
	if target_slot != active_save_slot: journal.cleanup_pending = true
	_set_active_save_slot(target_slot)
	journal.prune_retired_files()
	return ""

func _set_active_save_slot(slot: int) -> bool:
	var path := MatchSave.slot_path(slot)
	if path.is_empty(): return false
	active_save_slot = slot
	match_save_path = path
	match_journal_directory = MatchSave.journal_directory(slot)
	journal.storage_directory = match_journal_directory
	return true

func _prepare_new_match_save_target() -> String:
	var occupied_slots := MatchSave.existing_slots()
	for slot in range(1, MatchSave.SLOT_COUNT + 1):
		if slot not in occupied_slots and _set_active_save_slot(slot): return ""
	_set_no_active_save_slot()
	return SAVE_SLOTS_FULL_NOTICE

func _set_no_active_save_slot() -> void:
	active_save_slot = 0
	match_save_path = ""
	match_journal_directory = "user://matches/journals/unslotted"
	journal.storage_directory = match_journal_directory

func _load_saved_match_slot(slot: int) -> void:
	if combat_enabled:
		saved_matches_browser.show_feedback("Return to the title screen before loading another match.", true)
		return
	var previous_slot := active_save_slot
	if not _set_active_save_slot(slot):
		saved_matches_browser.show_feedback("Choose a valid local save slot.", true)
		return
	_load_match()
	if resume_succeeded:
		_dismiss_home(1)
		return
	if previous_slot == 0: _set_no_active_save_slot()
	else: _set_active_save_slot(previous_slot)
	saved_matches_browser.show_feedback(status.text, true)

func _save_current_match_to_slot(slot: int) -> void:
	var error := _save_snapshot_to_slot(slot)
	autosave_error = error
	status.text = "Match saved to Slot %d on this computer." % slot if error.is_empty() else "Could not save the match: " + error
	if saved_matches_browser != null:
		var local_match_can_save: bool = combat_enabled and mode != "client" and state.get("phase", "") != "army_selection"
		saved_matches_browser.set_context(not combat_enabled, local_match_can_save, active_save_slot)
		saved_matches_browser.refresh_slots()
		saved_matches_browser.show_feedback(status.text, not error.is_empty())
	if history_panel != null and history_panel.is_visible_in_tree(): _history_page(-1)

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
	if state.get("phase", "") == "army_selection":
		status.text = "Complete both army selections before saving."
		return
	if active_save_slot < 1:
		_open_saved_matches()
		if saved_matches_browser != null: saved_matches_browser.show_feedback(SAVE_SLOTS_FULL_NOTICE, true)
		return
	var error := _save_snapshot()
	autosave_error = error
	status.text = "Match saved on this computer." if error.is_empty() else "Could not save the match: " + error
	if history_panel.is_visible_in_tree(): _history_page(-1)

func _load_backup_after_primary_failure(as_host: bool, validate_only: bool, primary_error: String) -> void:
	var backup := MatchSave.read_snapshot_file(match_save_path + ".bak")
	if backup.has("error"):
		status.text = "%s Previous backup could not be read: %s" % [primary_error, str(backup.error)]
		return
	backup.recovered_from_backup = true
	backup.primary_error = primary_error
	_load_match(as_host, validate_only, backup)
	if not resume_compatible and not resume_succeeded:
		status.text += " The previous backup was selected after the primary failed validation: " + primary_error

func _report_structural_match_load_failure(saved: Dictionary, saved_override: Dictionary, as_host: bool, validate_only: bool, error: String) -> void:
	var recovered_from_backup := bool(saved.get("recovered_from_backup", false))
	if saved_override.is_empty() and not recovered_from_backup:
		_load_backup_after_primary_failure(as_host, validate_only, error)
		return
	status.text = error
	if recovered_from_backup and saved_override.is_empty():
		status.text += " The previous backup also failed validation. Primary save error: " + str(saved.get("primary_error", "The primary save could not be used."))

func _saved_attack_draft_structure_error(draft: Dictionary, saved_state: Dictionary) -> String:
	if draft.is_empty(): return ""
	for key in ["squad", "attacker", "revision"]:
		if not draft.has(key) or not draft[key] is int: return "The saved attack plan is malformed."
	if not draft.has("melee") or not draft.melee is bool: return "The saved attack plan is malformed."
	if not draft.has("pack_hash") or not draft.pack_hash is String: return "The saved attack plan is malformed."
	if not draft.has("entries") or not draft.entries is Array: return "The saved attack plan is malformed."
	if draft.has("hail_target") and not draft.hail_target is int: return "The saved attack plan is malformed."
	if draft.has("indirect_shooting") and not draft.indirect_shooting is bool: return "The saved attack plan is malformed."
	for entry: Variant in draft.entries:
		if not entry is Dictionary: return "The saved attack assignment is malformed."
		for key in ["model", "target", "amount"]:
			if not entry.has(key) or not entry[key] is int: return "The saved attack assignment is malformed."
		for key in ["weapon", "profile"]:
			if entry.has(key) and not entry[key] is String: return "The saved attack assignment is malformed."
	var matches_saved_state: bool = int(draft.revision) == int(saved_state.get("revision", -1)) and str(draft.pack_hash) == str(saved_state.get("pack_hash", ""))
	if not matches_saved_state: return ""
	var squads: Variant = saved_state.get("squads", {})
	var units: Variant = saved_state.get("units", {})
	if not squads is Dictionary or not units is Dictionary: return "The saved attack plan references incomplete match data."
	var squad_id := int(draft.squad)
	var attacker_id := int(draft.attacker)
	if not squads.has(squad_id) or not units.has(attacker_id): return "The saved attack plan references an unknown unit."
	var attacker: Variant = units[attacker_id]
	if not attacker is Dictionary or int(attacker.get("squad", -1)) != squad_id: return "The saved attack plan references an invalid attacker."
	for entry: Dictionary in draft.entries:
		var model_id := int(entry.model)
		var target_id := int(entry.target)
		if not squads.has(target_id) or not units.has(model_id): return "The saved attack assignment references an unknown model or target."
		var model: Variant = units[model_id]
		if not model is Dictionary or int(model.get("squad", -1)) != squad_id: return "The saved attack assignment references a model outside its attacking unit."
	return ""

func _load_match(as_host: bool = false, validate_only: bool = false, saved_override: Dictionary = {}) -> void:
	resume_compatible = false
	resume_succeeded = false
	if mode != "local":
		status.text = "Disconnect from the LAN session before resuming a saved match."
		return
	var saved := saved_override if not saved_override.is_empty() else MatchSave.read(match_save_path)
	if saved.has("error"):
		status.text = saved.error
		return
	var recovered_from_backup := bool(saved.get("recovered_from_backup", false))
	var pending_state_error := Combat.MatchActor.pending_state_error(saved.state)
	if not pending_state_error.is_empty():
		_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved match contains an invalid pending decision state.")
		return
	var config: Dictionary = saved.config
	var current := _save_config()
	for key in config:
		if current.has(key) and typeof(config[key]) != typeof(current[key]):
			_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved match configuration contains invalid data.")
			return
	for section_key in ["mission", "terrain", "combat_doctrines", "match_manifest", "roster_validation", "stratagems", "oath_of_moment", "hail_of_bolts", "implacable_eradication", "objective_secured", "reanimation_protocols", "unit_abilities", "awakened_dynasty", "saved_army_setup", "squads", "units"]:
		if saved.state.has(section_key) and not saved.state[section_key] is Dictionary:
			_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved state section '%s' is invalid." % str(section_key))
			return
	if bool(config.get("saved_army_mode", false)):
		var saved_setup: Variant = saved.state.get("saved_army_setup", null)
		if not saved_setup is Dictionary or saved_setup.size() != 3 or saved_setup.get("schema_version") != 1 or not saved_setup.get("options") is Dictionary or not saved_setup.get("armies") is Dictionary:
			_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved army setup is incomplete or malformed.")
			return
	for field_spec in [
		{"section": "mission", "field": "primary_ids"},
		{"section": "combat_doctrines", "field": "detachments"},
		{"section": "match_manifest", "field": "marine_detachments"},
		{"section": "match_manifest", "field": "marine_chapter_selections"},
		{"section": "match_manifest", "field": "marine_chapters"},
	]:
		var section: Variant = saved.state.get(str(field_spec.section), {})
		if section is Dictionary and section.has(str(field_spec.field)) and not section[str(field_spec.field)] is Dictionary:
			_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved state field '%s.%s' is invalid." % [str(field_spec.section), str(field_spec.field)])
			return
	var attack_draft_error := _saved_attack_draft_structure_error(saved.attack_draft, saved.state)
	if not attack_draft_error.is_empty():
		_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, attack_draft_error)
		return
	# Older saves predate the opt-in rule; their public state and hashes stay intact.
	if not config.has("core_stratagems"): config.core_stratagems = false
	if not config.has("checked_rosters"): config.checked_rosters = false
	if config.checked_rosters != Combat.RosterValidation.enabled(saved.state):
		status.text = "The saved-roster option or legacy price snapshot does not match the save."
		return
	if not config.has("official_mission"): config.official_mission = false
	if not config.has("official_primary_mission"): config.official_primary_mission = str(saved.state.get("mission", {}).get("primary_id", "battlefield-dominance"))
	if not config.has("official_primary_missions"):
		var stored_primaries: Variant = saved.state.get("mission", {}).get("primary_ids", {})
		config.official_primary_missions = stored_primaries.duplicate(true) if stored_primaries is Dictionary and not stored_primaries.is_empty() else {1: str(config.official_primary_mission), 2: str(config.official_primary_mission)}
	if not config.has("official_secondary_pair"): config.official_secondary_pair = str(saved.state.get("mission", {}).get("secondary_pair_id", Combat.Mission.DEFAULT_SECONDARY_PAIR))
	if not config.has("official_terrain_layout"):
		config.official_terrain_layout = str(saved.state.get("mission", {}).get("terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT))
	var saved_terrain_id := str(saved.state.get("terrain", {}).get("id", Combat.Terrain.DEFAULT_LAYOUT))
	if config.official_mission:
		if not Combat.Terrain.is_event_layout(str(config.official_terrain_layout)) or str(config.official_terrain_layout) != str(saved.state.get("mission", {}).get("terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT)) or str(config.official_terrain_layout) != saved_terrain_id:
			status.text = "The selected 11th-edition terrain layout does not match the save."
			return
	if config.official_mission != Combat.Mission.enabled(saved.state):
		status.text = "The selected mission option does not match the save."
		return
	if config.official_mission:
		var saved_primaries := Combat.Mission.primary_assignments(saved.state)
		var configured_primaries: Variant = config.get("official_primary_missions", {})
		if not configured_primaries is Dictionary:
			status.text = "The saved primary mission choices are invalid."
			return
		for owner in [1, 2]:
			var selected_primary := str(configured_primaries.get(owner, configured_primaries.get(str(owner), config.get("official_primary_mission", "battlefield-dominance"))))
			if not Combat.Mission.PRIMARY_MISSIONS.has(selected_primary) or selected_primary != str(saved_primaries[owner]):
				status.text = "The selected primary mission for Player %d does not match the save." % owner
				return
	if config.official_mission and (not Combat.Mission.SECONDARY_PAIRS.has(str(config.official_secondary_pair)) or str(config.official_secondary_pair) != Combat.Mission.secondary_pair_id(saved.state)):
		status.text = "The selected fixed secondary pair does not match the save."
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
	var saved_manifest: Dictionary = saved.state.get("match_manifest", {})
	var has_saved_chapter_context: bool = saved_manifest.has("marine_chapters") and str(saved_manifest.get("marine_chapter_rules", "")) == ChapterRules.ID
	var saved_chapters: Dictionary = saved_manifest.get("marine_chapter_selections", saved_manifest.get("marine_chapters", {1: "", 2: ""}))
	if not config.has("marine_chapters"): config.marine_chapters = saved_chapters.duplicate(true)
	if not config.marine_chapters is Dictionary:
		status.text = "The saved per-player Chapter selections are invalid."
		return
	if has_saved_chapter_context:
		if not _marine_chapter_assignments_equal(config.marine_chapters, saved_chapters):
			status.text = "The per-player Chapter selections do not match the save."
			return
	elif not _marine_chapter_assignments_equal(config.marine_chapters, {1: "", 2: ""}):
		status.text = "The saved match does not contain the selected Chapter context."
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
		_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved seat reservation is invalid.")
		return
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
		var restore_options := _prepared_options_for_restore(config, saved.state)
		initial = PreparedTraining.initial_state(restore_options)
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
			_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The saved state is incomplete or incompatible.")
			return
	if not saved.get("journal", {}) is Dictionary:
		_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, "The history reference is invalid.")
		return
	var restored_journal = MatchJournal.new()
	restored_journal.storage_directory = match_journal_directory
	var history_error: String = restored_journal.restore(saved.get("journal", {}), saved.state)
	if not history_error.is_empty():
		_report_structural_match_load_failure(saved, saved_override, as_host, validate_only, history_error)
		return
	resume_compatible = true
	if validate_only:
		status.text = "Saved match is compatible."
		if recovered_from_backup: status.text += " Compatibility was checked against the previous backup because the primary save could not be used."
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
	marine_chapters = ChapterRules.normalize_assignments(config.marine_chapters)
	_select_marine_chapter(marine_chapter_choice_p1, str(marine_chapters[1]))
	_select_marine_chapter(marine_chapter_choice_p2, str(marine_chapters[2]))
	checked_rosters_choice.set_pressed_no_signal(checked_rosters)
	official_mission_choice.set_pressed_no_signal(official_mission)
	_select_official_primary_missions(config.get("official_primary_missions", {1: str(config.official_primary_mission), 2: str(config.official_primary_mission)}))
	_select_official_secondary_pair(str(config.official_secondary_pair))
	_select_official_terrain_layout(str(config.official_terrain_layout))
	_refresh_official_layout_controls()
	unit_abilities_choice.set_pressed_no_signal(unit_abilities)
	awakened_dynasty_choice.button_pressed = awakened_dynasty
	state = saved.state
	# Seed presentation from the restored snapshot without replaying its old attack effects.
	attack_feedback.reset()
	combat_tray.reset()
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
	if recovered_from_backup: status.text += " Restored from the previous backup because the primary save could not be used."
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
		if official_mission:
			var host_primary_ids: Variant = snapshot.saved_army_setup.get("options", {}).get("primary_missions", {})
			if not host_primary_ids is Dictionary:
				_offline("The host sent invalid per-player primary mission settings.")
				return
			for owner in [1, 2]:
				var host_primary := str(host_primary_ids.get(owner, host_primary_ids.get(str(owner), "battlefield-dominance")))
				if host_primary != _selected_official_primary_mission(owner):
					_offline("Players have different primary mission choices.")
					return
		if official_mission and str(snapshot.saved_army_setup.get("options", {}).get("secondary_pair", Combat.Mission.DEFAULT_SECONDARY_PAIR)) != _selected_official_secondary_pair():
			_offline("Players have different fixed secondary pair settings.")
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
		var remote_chapters: Dictionary = snapshot.saved_army_setup.get("options", {}).get("marine_chapters", {1: "", 2: ""})
		var local_chapters: Dictionary = _selected_marine_chapters()
		if not _marine_chapter_assignments_equal(remote_chapters, local_chapters):
			_offline("Players have different Space Marine Chapter selections.")
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
	if awaiting_initial_authoritative_snapshot:
		# The first host snapshot is a baseline; its recorded attack is not a new impact.
		attack_feedback.reset()
		combat_tray.reset()
		_finish_casualty_feedback()
		_clear_board_feedback()
		board_presentation_state.clear()
		awaiting_initial_authoritative_snapshot = false
	state = snapshot
	if replace_pieces: _spawn_pieces()
	status.text = "State synchronized with host."
	_refresh()
	if history_panel.is_visible_in_tree(): _history_page(-1)

@rpc("any_peer", "call_remote", "reliable")
func request_move(id: int, target: Vector2, revision: int = -1, destination_elevation: float = -1.0) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_move(2, id, target, revision, destination_elevation)

func _apply_move(player: int, id: int, target: Vector2, revision: int = -1, destination_elevation: float = -1.0) -> void:
	if mode == "host" and guest_id == 0:
		status.text = "Wait for player 2."
		return
	if combat_enabled:
		var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.PLACE_MODEL, "model": id, "destination": target, "destination_elevation": destination_elevation, "revision": revision})
		_placement_result(player, id, target, str(result.get("error", "")), destination_elevation, str(result.get("error_code", "")), str(result.get("recovery", "")), result.get("details", []))
		_present_match_command(player, result)
		return
	var validation: Dictionary = Rules.validate_move_result(state, player, id, target)
	if not bool(validation.get("valid", false)):
		var reason := str(validation.get("reason", "Movement validation failed."))
		_placement_result(player, id, target, reason, -1.0, str(validation.get("code", "movement_blocked")), str(validation.get("recovery", "Choose another destination.")))
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
	if placement_reason_row != null: placement_reason_row.visible = false
	placement_detail_entries.clear()
	if placement_details_toggle != null:
		placement_details_toggle.set_pressed_no_signal(false)
		placement_details_toggle.visible = false
	if placement_details_label != null:
		placement_details_label.text = ""
		placement_details_label.visible = false

func _placement_result(player: int, model: int, destination: Vector2, error: String, destination_elevation: float = -1.0, error_code: String = "", recovery: String = "", details: Array = []) -> void:
	if mode == "host" and player == 2:
		if guest_id != 0: receive_placement_feedback.rpc_id(guest_id, model, destination, error, destination_elevation, error_code, recovery, details)
		return
	_show_placement_feedback(model, destination, error, destination_elevation, error_code, recovery, details)

@rpc("authority", "call_remote", "reliable")
func receive_placement_feedback(model: int, destination: Vector2, error: String, destination_elevation: float = -1.0, error_code: String = "", recovery: String = "", details: Array = []) -> void:
	_show_placement_feedback(model, destination, error, destination_elevation, error_code, recovery, details)

func _show_placement_feedback(model: int, destination: Vector2, error: String, destination_elevation: float = -1.0, error_code: String = "", recovery: String = "", details: Array = []) -> void:
	_clear_placement_feedback()
	if error.is_empty() or not state.units.has(model): return
	var current_elevation := float(state.units[model].get("elevation", 0.0))
	var target_elevation := current_elevation if destination_elevation < 0.0 else destination_elevation
	var mark_destination := not destination.is_equal_approx(state.units[model].position) or absf(target_elevation - current_elevation) > 0.001
	var fallback_recovery := "Rejected destination marked. Choose another or cancel." if mark_destination else "Review the placement, then retry or reset."
	placement_feedback.show_reason(model, destination, error, true, mark_destination, target_elevation, error_code, recovery if not recovery.is_empty() else fallback_recovery)
	var squads: Dictionary = state.get("squads", {})
	var squad_name := str(squads.get(int(state.units[model].get("squad", -1)), {}).get("name", "Unit"))
	var model_label := "%s · %s" % [squad_name, ArmyList.model_label(state, model)]
	placement_reason.text = "%s · %s\n%s\n%s" % [model_label, placement_feedback.heading, error, placement_feedback.recovery]
	placement_reason.visible = true
	if placement_reason_row != null: placement_reason_row.visible = true
	for detail: Variant in details:
		var detail_text := ""
		if detail is Dictionary:
			var detail_model := int(detail.get("model", -1))
			var detail_unit: Dictionary = state.units.get(detail_model, {})
			if not detail_unit.is_empty():
				var detail_squad := int(detail_unit.get("squad", -1))
				var detail_squad_name := str(squads.get(detail_squad, {}).get("name", "Unit"))
				detail_text = "%s · %s: %s" % [detail_squad_name, ArmyList.model_label(state, detail_model), str(detail.get("reason", "Additional contact requirement not met."))]
		else:
			detail_text = str(detail).strip_edges()
		if not detail_text.is_empty(): placement_detail_entries.append(detail_text)
	if not placement_detail_entries.is_empty():
		placement_details_toggle.text = "Show other affected models"
		placement_details_toggle.visible = true
	_set_command_panel_open(true)
	var location: Vector2 = state.units[model].position
	var base_world := Vector3(location.x, current_elevation + 0.12, location.y)
	var anchor_world := Vector3(location.x, current_elevation + 1.7, location.y)
	placement_feedback.place(camera, anchor_world, base_world, float(state.units[model].get("radius", 0.5)), _camera_board_area())

func _toggle_placement_details(expanded: bool) -> void:
	if placement_details_label == null or placement_details_toggle == null: return
	placement_details_label.visible = expanded and not placement_detail_entries.is_empty()
	if placement_details_label.visible:
		var lines: Array[String] = []
		for detail: String in placement_detail_entries: lines.append("• " + detail)
		placement_details_label.text = "\n".join(lines)
	placement_details_toggle.text = "Hide other affected models" if expanded else "Show other affected models"

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
	reaction_use_row.visible = not window.is_empty()
	reaction_use_icon.visible = not window.is_empty() and window.get("kind", "") != "before_battle_shock"
	if reaction_sudden != null:
		reaction_sudden.visible = window.get("valour", false) or window.get("master_shadows", false) or (window.get("kind", "") == "after_advance_roll" and (window.get("sudden", false) or window.get("supercharged", false) or window.get("honour_vigilance", false) or window.get("wrath_chapter", false) or window.get("stormseers_wisdom", false)))
		reaction_sudden_row.visible = reaction_sudden.visible
		reaction_sudden_icon.visible = reaction_sudden.visible
		reaction_sudden.text = _free_movement_reroll_label(window)
	if window.is_empty():
		reaction_focus_key = ""
		if reaction_die != null: reaction_die.visible = false
		return
	var attack: bool = window.kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"]
	var rolling: bool = window.kind != "before_battle_shock"
	if reaction_die == null:
		reaction_die = OptionButton.new()
		var reaction_column := reaction_use_row.get_parent()
		reaction_column.add_child(reaction_die)
		reaction_column.move_child(reaction_die, reaction_use_row.get_index())
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
	reaction_help.text = "%d CP" % state.cp[window.player]
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
	var transport_hazard: bool = Combat.Stratagems.pending(state).get("kind") == "after_transport_hazard_roll"
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
		elif transport_hazard:
			var transport_window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
			if transport_window.is_empty(): message += " Transport Hazard resolved; no passenger models remain to place."
			elif int(transport_window.get("hazard_total", 0)) > 0:
				var hazard_wounds := int(transport_window.hazard_total)
				var wound_label := "mortal wound" if hazard_wounds == 1 else "mortal wounds"
				message += " Allocate %d transport Hazard %s before placing passengers." % [hazard_wounds, wound_label]
			else: message += " Transport Hazard resolved; place the surviving passengers."
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
	var take_to_skies := take_to_skies_choice.button_pressed
	if mode == "client": request_begin_movement.rpc_id(1, selected, move_type, state.revision, sudden, take_to_skies)
	else: _apply_begin_movement(_local_player(), selected, move_type, state.revision, sudden, take_to_skies)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_movement(model: int, move_type: String, revision: int, use_sudden_onslaught: bool = false, take_to_skies: bool = false) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()):
		_apply_begin_movement(2, model, move_type, revision, use_sudden_onslaught, take_to_skies)

func _apply_begin_movement(player: int, model: int, move_type: String, revision: int, use_sudden_onslaught: bool = false, take_to_skies: bool = false) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.BEGIN_MOVEMENT, "model": model, "move_type": move_type, "revision": revision, "use_sudden_onslaught": use_sudden_onslaught, "take_to_skies": take_to_skies}, _d6)
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
	var decision := _pending_ui_decision(["escape-wounds"])
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
	var decision := _pending_ui_decision(["coherency"])
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
	var feedback_model := selected
	var pending_move: Dictionary = state.get("pending_move", {})
	if not pending_move.is_empty() and (not state.units.has(feedback_model) or int(state.units[feedback_model].get("squad", -1)) != int(pending_move.get("squad", -2))):
		feedback_model = -1
		for candidate: Variant in pending_move.get("origins", {}):
			var model := int(candidate)
			if state.units.has(model) and int(state.units[model].get("squad", -1)) == int(pending_move.get("squad", -2)):
				feedback_model = model
				break
	if state.units.has(feedback_model): _placement_result(player, feedback_model, state.units[feedback_model].position, str(result.get("error", "")), -1.0, str(result.get("error_code", "")), str(result.get("recovery", "")), result.get("details", []))
	_present_match_command(player, result)

func _request_charge_roll() -> void:
	if not combat_enabled: return
	var decline: bool = not state.pending_charge.is_empty()
	var take_to_skies := take_to_skies_charge_choice.button_pressed
	if mode == "client": request_charge_roll.rpc_id(1, selected, state.revision, decline, take_to_skies)
	else: _apply_charge_roll(_local_player(), selected, state.revision, decline, take_to_skies)

@rpc("any_peer", "call_remote", "reliable")
func request_charge_roll(model: int, revision: int, decline: bool, take_to_skies: bool = false) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_charge_roll(2, model, revision, decline, take_to_skies)

func _apply_charge_roll(player: int, model: int, revision: int, decline: bool, take_to_skies: bool = false) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.CHARGE_ROLL, "model": model, "revision": revision, "decline": decline, "take_to_skies": take_to_skies}, _d6)
	_present_match_command(player, result)

@rpc("any_peer", "call_remote", "reliable")
func request_charge(target: int, revision: int) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_charge(2, target, revision)

func _apply_charge(player: int, target: int, revision: int) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.CHARGE_TARGET, "target": target, "revision": revision})
	_present_match_command(player, result)

func _request_begin_contact() -> void:
	_request_begin_contact_with_tactical_focus(false)

func _request_tactical_focus_contact() -> void:
	_request_begin_contact_with_tactical_focus(true)

func _request_begin_contact_with_tactical_focus(use_tactical_focus: bool) -> void:
	if not combat_enabled: return
	var kind: String = "charge" if state.phase == "charge" else "pile_in" if state.fight_step == "pile_in" else "consolidate" if state.fight_step == "consolidate" else "overrun"
	var objective := consolidation_objective.get_selected_id() if consolidation_objective.visible else -1
	var targets: Array[int] = []
	if contact_enemy.visible: targets.append(contact_enemy.get_selected_id())
	if mode == "client": request_begin_contact.rpc_id(1, selected, kind, state.revision, objective, targets, use_tactical_focus)
	else: _apply_begin_contact(_local_player(), selected, kind, state.revision, objective, targets, use_tactical_focus)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_contact(model: int, kind: String, revision: int, objective: int = -1, targets: Array[int] = [], use_tactical_focus: bool = false) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_begin_contact(2, model, kind, revision, objective, targets, use_tactical_focus)

func _apply_begin_contact(player: int, model: int, kind: String, revision: int, objective: int = -1, targets: Array[int] = [], use_tactical_focus: bool = false) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.BEGIN_CONTACT, "model": model, "move_kind": kind, "revision": revision, "targets": targets, "objective": objective, "use_tactical_focus": use_tactical_focus}, _d6)
	_present_match_command(player, result)

@rpc("any_peer", "call_remote", "reliable")
func request_contact_move(model: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_contact_move(2, model, destination, revision, destination_elevation)

func _apply_contact_move(player: int, model: int, destination: Vector2, revision: int, destination_elevation: float = -1.0) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.STAGE_CONTACT, "model": model, "destination": destination, "destination_elevation": destination_elevation, "revision": revision})
	_placement_result(player, model, destination, str(result.get("error", "")), destination_elevation)
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
	var feedback_model := selected
	var pending_contact: Dictionary = state.get("pending_contact", {})
	var primary_model := int(result.get("primary_model", -1))
	if state.units.has(primary_model): feedback_model = primary_model
	if not pending_contact.is_empty() and (not state.units.has(feedback_model) or int(state.units[feedback_model].get("squad", -1)) != int(pending_contact.get("squad", -2))):
		feedback_model = -1
		for candidate: Variant in pending_contact.get("origins", {}):
			var model := int(candidate)
			if state.units.has(model) and int(state.units[model].get("squad", -1)) == int(pending_contact.get("squad", -2)):
				feedback_model = model
				break
	if state.units.has(feedback_model): _placement_result(player, feedback_model, state.units[feedback_model].position, str(result.get("error", "")), -1.0, str(result.get("error_code", "")), str(result.get("recovery", "")), result.get("details", []))
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

func _refresh_vowed_target() -> void:
	var pending: bool = combat_enabled and Combat.VowedTarget.needs_choice(state)
	if pending:
		var active_decision := _pending_ui_decision(["awakened-attachment", "mission-preparation", "unit-actions", "combat-doctrines", "oath-of-moment", "vowed-target", "reanimation", "stratagems", "damage-allocation"])
		pending = str(active_decision.get("source", "")) == "vowed-target"
	for control in [vowed_help, vowed_objective, vowed_confirm]: control.visible = pending
	if not pending: return
	end_button.disabled = true
	var previous := vowed_objective.get_selected_id()
	vowed_objective.clear()
	for index in Combat.VowedTarget.objective_indices(state):
		var objective: Dictionary = state.mission.objectives[index]
		vowed_objective.add_item(str(objective.get("name", "Objective %d" % (index + 1))), index)
	vowed_objective.add_item("Do not use Vowed Target this Command phase", -2)
	vowed_objective.select(maxi(0, vowed_objective.get_item_index(previous)))
	var waiting: bool = _local_player() != state.active or (mode == "host" and guest_id == 0)
	vowed_objective.disabled = waiting
	vowed_confirm.disabled = waiting or vowed_objective.item_count == 0
	vowed_help.text = "Player %d: choose an objective or skip now. Deathwing Infantry attacks against enemies in its range gain +1 to Wound until your next Command phase." % state.active
	vowed_help.tooltip_text = "The local prompt appears at Command entry. The selected objective can be controlled by either player. Objective range follows the current mission geometry."

func _request_vowed_objective() -> void:
	if vowed_objective.selected < 0: return
	var selection := vowed_objective.get_selected_id()
	var objective_index := -1 if selection == -2 else selection
	var identity := _vowed_decision_identity(objective_index)
	if mode == "client": request_vowed_objective.rpc_id(1, objective_index, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))
	else: _apply_vowed_objective(_local_player(), objective_index, state.revision, str(identity.get("decision_id", "")), str(identity.get("option_id", "")))

func _vowed_decision_identity(objective_index: int) -> Dictionary:
	var decision := Combat.VowedTarget.pending_decision(state)
	var expected_action := "vowed-target-pass" if objective_index < 0 else "vowed-target"
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == expected_action and int(option.get("target", -1)) == objective_index:
			return {"decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", ""))}
	return {}

@rpc("any_peer", "call_remote", "reliable")
func request_vowed_objective(objective_index: int, revision: int, decision_id: String, option_id: String) -> void:
	if mode == "host" and match_session.accepts_guest_command(multiplayer.get_remote_sender_id()): _apply_vowed_objective(2, objective_index, revision, decision_id, option_id)

func _apply_vowed_objective(player: int, objective_index: int, revision: int, decision_id: String, option_id: String) -> void:
	if not combat_enabled or (mode == "host" and guest_id == 0): return
	var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_VOWED_OBJECTIVE, "target": objective_index, "revision": revision, "decision_id": decision_id, "option_id": option_id})
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
	var selected_detachment: String = Combat.Doctrines.detachment_for(state, state.active)
	var mastery_doctrines: Array = Combat.Doctrines.DETACHMENT_EXTRA_DOCTRINES.get(selected_detachment, [])
	for doctrine: String in Combat.Doctrines.available(state, state.active):
		var has_extra_use := selected_detachment == "gladius" or doctrine in mastery_doctrines or Combat.Doctrines.blade_mastered_doctrines_active(state, state.active)
		var extra := " [extra use]" if doctrine in state.combat_doctrines.used.get(state.active, []) and has_extra_use else ""
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
	elif selected_detachment == "blade-of-ultramar": extra_summary = "Mastered Doctrines gives each doctrine a separate extra use while Marneus Calgar is in the army." if Combat.Doctrines.blade_mastered_doctrines_active(state, state.active) else "Mastered Doctrines requires Marneus Calgar in the army; no extra doctrine uses are available."
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
	var decision := _pending_ui_decision(["awakened-attachment"])
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
	var choices: Array = _available_unit_choices(_local_player()) if combat_enabled else []
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
		unit_action_help.text = "Continue without this ability."
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
	if unit_action_picker.get_selected_metadata().get("action", "") == "damocles-class-uplink":
		unit_action_help.text = "Damocles-class Uplink: while its living Captain bearer unit is embarked in a Transport, use this once in your Movement phase. Give one friendly Adeptus Astartes Infantry unit with Combat Doctrines within 6 inches of that Transport one available doctrine until your next Command phase."
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
	if Combat.UnitActions.pending(state).get("kind", "") == Combat.UnitActions.TargetAuguryWeb.WINDOW:
		var augury_moment := "start" if Combat.UnitActions.pending(state).get("moment", "") == "start" else "end"
		unit_action_help.text = "Target Augury Web at the %s of the Techmarine unit's move: choose one friendly Adeptus Astartes Vehicle model within 3 inches of any model in that unit. That Vehicle model gains Lethal Hits for ranged and melee attacks until the start of your next Command phase. Choose a Vehicle or pass." % augury_moment
	var optics: Dictionary = Combat.UnitAbilities.Detection.selection(state)
	if not optics.is_empty():
		var effect: String = "Ignores Cover" if optics.mode == "cover" else "+6 detection on " + state.squads[optics.target].name
		unit_action_help.text = "%s active for the selected Eliminators. Shoot this unit now; other units wait." % effect
		unit_action_help.tooltip_text = "You may revise or cancel this preview before committing dice. The effect ends when this shooting finishes."
	if Combat.UnitActions.pending(state).get("kind", "") == "bladeguard":
		unit_action_help.text = "Bladeguard: +1 to your unit’s melee hit rolls OR -1 to enemy hit rolls against it, until Fight ends. Once per turn, 0 CP. Declining keeps the use. Declared attacks wait; no attack dice rolled yet."
	elif Combat.UnitActions.pending(state).get("kind", "") == "wound": unit_action_help.text = "Implacable Eradication: re-roll any wound dice for 0 CP, including successes, or keep the remaining rolls. Each die can only be re-rolled once. Saves wait until you finish."
	elif Combat.UnitActions.pending(state).get("kind", "") == "ingress":
		var ingress_window: Dictionary = Combat.UnitActions.pending(state)
		if bool(ingress_window.get("relic_teleportarium", false)):
			unit_action_help.text = "Relic Teleportarium: set up the Deathwing unit more than 6 inches horizontally from every enemy. It cannot Charge this turn. The CP is spent when selected and is not refunded if placement is canceled. Confirm only after every model fits coherently."
		else:
			unit_action_help.text = "Ingress: select each model and place its preview using X/Z or right-click. Confirm only after the whole unit fits coherently, more than 8 inches from enemies. Cancel preserves reserves and resources."
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
	var tactical: bool = str(Combat.UnitActions.pending(state).get("kind", "")) in ["healing", "healing-order", "ingress", "bladeguard", "wound", "evade-and-survive", "evade-placement", "tactical-fluidity", "tactical-fluidity-placement", Combat.DetachmentStratagems.UNSTOPPABLE_WINDOW, Combat.UnitActions.TargetAuguryWeb.WINDOW] or not optics.is_empty() or not state.get("unit_abilities", {}).get("transport_window", {}).is_empty()
	if not tactical and not battle_start_setup: unit_action_help.text = "Choose an option, then Confirm choice."
	if guided_first_session and not preparing:
		# The picker may truncate a long unit/stratagem label, including its CP cost.
		# Repeat the live label in wrapping text before the player confirms it.
		unit_action_help.text = str(unit_action_picker.get_selected_metadata().label)
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
	var decision := _pending_ui_decision(["unit-actions"])
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
		"aggressor-loadout", "inceptor-loadout", "land-speeder-cannon", "land-speeder-vengeance-cannon", "intercessor-melee", "intercessor-rifle",
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
		var probe: Dictionary = Combat.UnitActions.apply(state.duplicate(true), owner, finish_choice, Vector2.ZERO, func() -> int: return 1)
		var validator_error := str(probe.get("error", ""))
		if not validator_error.is_empty(): return "Required before finishing: " + validator_error
	return "Required checks are clear. You may finish now or customize equipment first."

func _setup_finish_choice(owner: int) -> Dictionary:
	for choice: Dictionary in _available_unit_choices(owner):
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
		"land-speeder-vengeance-cannon": return "Assault Cannon" if unit.get("land_speeder_vengeance_assault_cannon", false) else "Heavy Bolter"
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
	var decision := _pending_ui_decision(["mission-preparation", "unit-actions"])
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

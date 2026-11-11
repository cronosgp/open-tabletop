extends "res://scripts/model_import_panel.gd"
## Deterministic transfer boundary for launch tests. No files or network are used.
## Match admission, public buttons, preflight signals and continuation stay real.
var prepare_calls := 0
var cancel_calls := 0
var accept_start := true
var requested_definitions: Array[String] = []
var requested_variants: Dictionary = {}

func _ready() -> void: pass
func _process(_delta: float) -> void: pass

func prepare_armies(definitions: Array[String], _force_refresh_saved: bool = false, _source_pose_pilot: bool = false, variant_requests: Dictionary = {}) -> bool:
	prepare_calls += 1
	if not accept_start: return false
	requested_definitions = definitions.duplicate()
	requested_variants = variant_requests.duplicate(true)
	automatic_total = definitions.size()
	automatic_ready = 0
	automatic_appearance_total = 1
	automatic_appearance_ready = 0
	automatic_running = true
	automatic_status.emit("Preparing controlled local miniature fixtures…")
	return true

func finish_preparation(complete: bool) -> void:
	automatic_running = false
	automatic_ready = automatic_total if complete else 0
	automatic_appearance_ready = automatic_appearance_total if complete else 0
	automatic_finished.emit(automatic_ready, automatic_total, "Controlled local preparation finished.")

func cancel_automatic() -> void:
	cancel_calls += 1
	automatic_running = false
	automatic_generation += 1

static func install(game):
	if game.model_imports != null and game.model_imports.get_script() == load("res://tests/fixtures/controlled_model_preparer.gd"):
		return game.model_imports
	var preparer = load("res://tests/fixtures/controlled_model_preparer.gd").new()
	preparer.visible = false
	game.add_child(preparer)
	game.model_imports = preparer
	preparer.automatic_status.connect(game._model_preparation_status)
	preparer.automatic_finished.connect(game._model_preparation_finished)
	return preparer

static func start_tactical_with_fallbacks(game) -> bool:
	var preparer = install(game)
	game.main_menu.guided_button.pressed.emit()
	if not game.local_visual_preflight_pending: return false
	preparer.finish_preparation(false)
	game.main_menu.guided_button.pressed.emit()
	return game.saved_army_mode and game.guided_first_session

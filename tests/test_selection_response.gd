extends "res://tests/test_doctrine_choice_ui.gd"

func run() -> void:
	prepare_command()
	var model := model_of(1, "hellblaster-squad")
	var before := var_to_bytes(game.state)
	var cached: Array = game._ui_choices.get(1, [])
	game._choose_roster_model(model)
	check(game.selected == model and "Hellblaster" in game.selection_card.text, "Roster selection updates its card synchronously")
	var selected_row: Button = game.army_roster._model_rows[model]
	var other_model := -1
	for id: int in game.army_roster._model_rows:
		if id != model:
			other_model = id
			break
	game._choose_roster_model(other_model)
	check(game.army_roster._selected_id == other_model and game.army_roster._model_rows[model] == selected_row, "Changing roster selection updates the two existing rows without rebuilding the army list")
	game._choose_roster_model(model)
	check(var_to_bytes(game.state) == before, "Selection and camera focus never mutate authoritative state")
	check(is_same(cached, game._ui_choices.get(1, [])), "Selection reuses the same revision's read-only legal-choice projection")
	check(game._ui_refresh_depth == 0 and not game._selection_refresh, "Projection reuse scope closes after selection")
	var choice := raw_choice(1, "acumen", -2, -2, "assault")
	check(not choice.is_empty(), "A real Captain doctrine choice is available")
	var result := PublicChoice.submit(game.state, 1, choice)
	check(str(result.get("error", "")).is_empty(), "Authoritative action changes the decision revision")
	game._choose_roster_model(model)
	check(game._ui_projection_revision == game.state.revision and not is_same(cached, game._ui_choices.get(1, [])), "A new revision invalidates selection projections")
	for offered: Dictionary in game._ui_choices.get(1, []): check(offered.action != "acumen", "Consumed Captain ability cannot remain as a stale legal option")
	cached = game._ui_choices.get(1, [])
	game.state = game.state.duplicate(true)
	game._choose_roster_model(model)
	check(not is_same(cached, game._ui_choices.get(1, [])), "Replacing a snapshot invalidates projections even at the same revision")
	game.datasheet_button.pressed.emit()
	check(game.datasheet_view.last_model.name == game.state.squads[game.state.units[model].squad].name and game.datasheet_view.last_model.ranged.size() >= 2, "Full inspector retains the selected model's weapon profiles")
	game._close_tactical_screen()
	check(not game.datasheet_details.visible and game.selected == model, "Closing the inspector restores the selected model")
	var old_row: Button = game.army_roster._model_rows[model]
	game.state.units[model].wounds -= 1
	game._refresh_selection_card()
	check(game.army_roster._model_rows[model] != old_row and "W 1/2" in game.army_roster._model_rows[model].text, "A real roster-visible state change rebuilds rows and refreshes wounds")
	print("Selection response checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	await process_frame
	quit(1 if failures else 0)

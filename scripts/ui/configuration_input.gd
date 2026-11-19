extends RefCounted
## Explicit standard controller mappings for Godot's existing UI actions.
## Does not alter gameplay actions or the player's keyboard bindings.
static func ensure_actions() -> void:
	var buttons := {
		"ui_accept": JOY_BUTTON_A, "ui_cancel": JOY_BUTTON_B,
		"ui_up": JOY_BUTTON_DPAD_UP, "ui_down": JOY_BUTTON_DPAD_DOWN,
		"ui_left": JOY_BUTTON_DPAD_LEFT, "ui_right": JOY_BUTTON_DPAD_RIGHT,
		"ui_focus_next": JOY_BUTTON_RIGHT_SHOULDER,
		"ui_focus_prev": JOY_BUTTON_LEFT_SHOULDER,
	}
	for action: String in buttons:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var present := false
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton and event.button_index == buttons[action]: present = true
		if present: continue
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = buttons[action]
		InputMap.action_add_event(action, event)

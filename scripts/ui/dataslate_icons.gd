extends RefCounted
## Shared CC BY game-icons loader for dataslate UI. Presentation only.

const ICON_DIR := "res://assets/ui/icons/dataslate/"

const FILES := {
	"armies": "armies.svg",
	"miniatures": "miniatures.svg",
	"training_tools": "training_tools.svg",
	"results": "results.svg",
	"guide": "guide.svg",
	"exit": "exit.svg",
	"saved_matches": "saved_matches.svg",
	"saved_matches_on_gold": "saved_matches_on_gold.svg",
	"new_match": "new_match.svg",
	"army_builder": "army_builder.svg",
	"settings": "settings.svg",
	"start_training": "start_training.svg",
	"start_training_on_gold": "start_training_on_gold.svg",
	"menu": "menu.svg",
	"actions": "actions.svg",
	"tools": "tools.svg",
	"history": "history.svg",
	"close": "close.svg",
	"save": "save.svg",
	"load": "load.svg",
	"reload": "reload.svg",
	"copy": "copy.svg",
	"rematch": "rematch.svg",
	"handoff": "handoff.svg",
	"mission": "mission.svg",
	"datasheet": "datasheet.svg",
	"focus": "focus.svg",
	"camera": "camera.svg",
	"confirm": "confirm.svg",
	"decline": "decline.svg",
	"folder": "folder.svg",
	"diagnostics": "diagnostics.svg",
	"connection": "connection.svg",
	"previous": "previous.svg",
	"next": "next.svg",
	"dice": "dice.svg",
	"host": "host.svg",
	"join": "join.svg",
	"play": "play.svg",
	"lab": "lab.svg",
}

static func texture(key: String) -> Texture2D:
	var file_name := str(FILES.get(key, ""))
	if file_name.is_empty():
		return null
	var path := ICON_DIR + file_name
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

static func apply(button: BaseButton, key: String) -> void:
	if button == null:
		return
	var icon := texture(key)
	if icon == null:
		return
	button.icon = icon
	if button is Button:
		var plain := button as Button
		plain.expand_icon = false
		plain.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	elif button is MenuButton:
		var menu := button as MenuButton
		menu.expand_icon = false
		menu.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

extends RefCounted
## Presentation helper for the Command-phase Combat Doctrine selector.
## Authoritative doctrine legality and CP remain in scripts/edition_11/combat_doctrines.gd.

const DESCRIPTIONS := {
	"none": "Save all remaining doctrines for a later battle round.",
	"devastator": "Units can shoot after Advancing until your next Command phase.",
	"tactical": "Units can shoot and declare a charge after Falling Back until your next Command phase.",
	"assault": "Units can declare a charge after Advancing until your next Command phase.",
}

static func present(state: Dictionary, doctrines_api: Variant, doctrine_choice: OptionButton, doctrine_confirm: Button, doctrine_skip: Button, doctrine_help: Label, waiting: bool) -> void:
	var previous := doctrine_choice.get_selected_id()
	doctrine_choice.clear()
	doctrine_choice.add_item(doctrines_api.NAMES.none, 0)
	var selected_detachment: String = doctrines_api.detachment_for(state, state.active)
	var mastery_doctrines: Array = doctrines_api.DETACHMENT_EXTRA_DOCTRINES.get(selected_detachment, [])
	for doctrine: String in doctrines_api.available(state, state.active):
		var has_extra_use: bool = selected_detachment == "gladius" or doctrine in mastery_doctrines or bool(doctrines_api.blade_mastered_doctrines_active(state, state.active))
		var extra := " [extra use]" if doctrine in state.combat_doctrines.used.get(state.active, []) and has_extra_use else ""
		doctrine_choice.add_item(doctrines_api.NAMES[doctrine] + extra, doctrines_api.ORDER.find(doctrine) + 1)
	doctrine_choice.select(maxi(0, doctrine_choice.get_item_index(previous)))
	var selected_id := doctrine_choice.get_selected_id()
	var selected_doctrine := "none" if selected_id <= 0 else str(doctrines_api.ORDER[selected_id - 1])
	doctrine_choice.disabled = waiting
	doctrine_confirm.disabled = waiting
	doctrine_skip.disabled = waiting
	if selected_doctrine == "none":
		doctrine_confirm.text = "Continue without a doctrine"
		doctrine_skip.visible = false
	else:
		doctrine_confirm.text = "Activate %s Doctrine · 0 CP" % selected_doctrine.capitalize()
		doctrine_skip.visible = true
	doctrine_help.text = "Player %d · %s" % [state.active, DESCRIPTIONS.get(selected_doctrine, "Choose a doctrine or continue without one.")]
	var extra_status := "spent" if state.combat_doctrines.extra_used.get(state.active, false) else "available"
	var extra_summary := ""
	if selected_detachment == "gladius":
		extra_summary = "Gladius Codex Discipline has one shared extra doctrine use; it is %s." % extra_status
	elif selected_detachment == "spearpoint-task-force":
		extra_summary = "Spearpoint can select Assault or Tactical Doctrine one extra time; that use is %s." % extra_status
	elif not mastery_doctrines.is_empty():
		extra_summary = "%s Brethren can select %s Doctrine one extra time; that use is %s." % [selected_detachment.trim_suffix("-brethren").capitalize(), str(mastery_doctrines[0]).capitalize(), extra_status]
	elif selected_detachment == "blade-of-ultramar":
		extra_summary = "Mastered Doctrines gives each doctrine a separate extra use while Marneus Calgar is in the army." if doctrines_api.blade_mastered_doctrines_active(state, state.active) else "Mastered Doctrines requires Marneus Calgar in the army; no extra doctrine uses are available."
	doctrine_help.tooltip_text = "Each doctrine is normally available once per battle. %s No CP." % extra_summary

extends RefCounted
## Read-only presentation helper for live 11e army legality feedback in the Army Workshop.
## Never mutates the army draft or bypasses authoritative match admission.

const ArmyLegality = preload("res://scripts/edition_11/army_legality.gd")

static func summarize_draft(draft: Dictionary, context: Dictionary = {}) -> Dictionary:
	var evaluation := ArmyLegality.evaluate_draft(draft, context)
	var valid := bool(evaluation.get("valid", false))
	var errors: Array = evaluation.get("errors", [])
	var warnings: Array = evaluation.get("warnings", [])
	var checks: Array = evaluation.get("checks", [])

	var lines: Array[String] = []
	for check_item: Variant in checks:
		if not check_item is Dictionary:
			continue
		var mark := "✓" if bool(check_item.get("ok", false)) else "✗"
		lines.append("%s %s" % [mark, str(check_item.get("label", ""))])
	for err: Variant in errors:
		lines.append("• " + str(err))
	for warn: Variant in warnings:
		lines.append("Note: " + str(warn))

	var status_text := ""
	var status_color := Color("82d49c")
	if valid:
		var category := str(draft.get("category", "incursion")).replace("_", " ").capitalize()
		if warnings.is_empty():
			status_text = "✓ Legal 11e roster (%s)" % category
			status_color = Color("82d49c")
		else:
			status_text = "✓ Legal with notes (%s)" % category
			status_color = Color("f2df83")
	else:
		var headline := str(errors[0]) if not errors.is_empty() else "Draft incomplete"
		status_text = "Legality · %d issue(s): %s" % [maxi(1, errors.size()), headline]
		status_color = Color("f0b46a")

	return {
		"valid": valid,
		"status_text": status_text,
		"status_color": status_color,
		"tooltip": "\n".join(lines),
		"errors": errors,
		"warnings": warnings,
	}

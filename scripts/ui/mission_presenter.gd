extends RefCounted
## Read-only mission view-model and round-end scoring receipt formatter.
## Authoritative control and VP remain in objectives.gd and chapter_approved.gd.

static func view_model(state: Dictionary, combat: Variant, combat_enabled: bool) -> Dictionary:
	var mission: Dictionary = state.get("mission", {})
	var has_official_mission := bool(combat.Mission.enabled(state))
	var is_training := bool(combat.Objectives.training(state))
	var total_rounds := int(mission.get("rounds", 5))
	var title := str(mission.get("name", "Mission status")) if has_official_mission or is_training else "Mission status"
	var subtitle := "Battle round %d of %d" % [int(state.get("round", 1)), total_rounds]
	if has_official_mission:
		subtitle = "Chapter Approved 2026–27  ·  Hammer and Anvil  ·  " + subtitle
	elif is_training:
		subtitle = "Custom objective training  ·  " + subtitle
	else:
		subtitle = "This exercise does not use objective scoring."
	var scores: Array[Dictionary] = []
	var card_scores: Dictionary = mission.get("cards", {})
	for player: int in [1, 2]:
		var primary_score := int(mission.get("primary", {}).get(player, 0)) if has_official_mission else 0
		var secondary_score := int(mission.get("secondary", {}).get(player, 0)) if has_official_mission else 0
		var breakdown := "Primary %d VP  ·  Secondaries %d VP" % [primary_score, secondary_score] if has_official_mission else "End-of-round objective scoring" if is_training else ""
		var player_details: Array[String] = []
		if has_official_mission:
			var player_card_scores: Dictionary = card_scores.get(player, {})
			for card: String in mission.get("secondary_cards", []):
				var card_name := str(combat.Mission.SECONDARY_CARD_NAMES.get(card, card))
				player_details.append("%s  ·  %d VP" % [card_name, int(player_card_scores.get(card, 0))])
		elif is_training:
			player_details.append("%d VP for each controlled objective at round end" % int(mission.get("points_per_objective", 1)))
		scores.append({
			"label": "Player %d" % player,
			"total": int(mission.get("scores", {}).get(player, 0)),
			"breakdown": breakdown,
			"details": player_details,
		})
	var details: Array[String] = []
	if has_official_mission:
		var force_disposition_names: Dictionary = mission.get("force_disposition_names", {})
		if not force_disposition_names.is_empty():
			details.append("Force dispositions  ·  P1 %s  ·  P2 %s" % [str(force_disposition_names.get(1, "Unknown")), str(force_disposition_names.get(2, "Unknown"))])
		var primary_names: Dictionary = mission.get("primary_names", {})
		if not primary_names.is_empty():
			details.append("Primary cards  ·  P1 %s  ·  P2 %s" % [str(primary_names.get(1, primary_names.get("1", "Primary"))), str(primary_names.get(2, primary_names.get("2", "Primary")))])
	var objectives: Array[Dictionary] = []
	for index in range(mission.get("objectives", []).size()):
		var objective: Dictionary = mission.objectives[index]
		var controller := int(objective.get("controller", 0))
		var control_text := "Neutral" if controller == 0 else "Controlled by Player %d" % controller
		var secured := int(objective.get("secured", 0))
		if secured in [1, 2]: control_text += "  ·  Secured for Player %d" % secured
		var objective_name := str(objective.get("name", "Objective"))
		var target_owners: Array[String] = []
		if has_official_mission: target_owners = combat.Mission.tempting_target_owners(state, objective_name)
		if not target_owners.is_empty(): control_text += "  ·  Tempting Target for " + ", ".join(target_owners)
		var vowed_owners: Array[int] = []
		if combat_enabled: vowed_owners = combat.VowedTarget.owners_of_objective(state, index)
		if not vowed_owners.is_empty(): control_text += "  ·  Vowed by " + "/".join(vowed_owners.map(func(owner: int) -> String: return "P%d" % owner))
		var bounds: Variant = objective.get("bounds", null)
		var location: Variant = objective.get("position", null)
		var focus_available := (bounds is Rect2 and (bounds as Rect2).size.length_squared() > 0.01) or location is Vector2
		var levels: Dictionary = objective.get("levels", {1: 0, 2: 0})
		objectives.append({
			"name": objective_name,
			"control": "Latest resolved control  ·  " + control_text,
			"p1_oc": int(levels.get(1, 0)),
			"p2_oc": int(levels.get(2, 0)),
			"focus_available": focus_available,
		})
	var history: Array[String] = []
	if has_official_mission:
		var mission_log: Array = mission.get("log", [])
		for index in range(mission_log.size() - 1, -1, -1):
			var event_text := str(mission_log[index])
			if " VP" not in event_text: continue
			history.append("• " + event_text)
			if history.size() >= 5: break
	elif is_training:
		history = recent_training_round_events(state)
	return {
		"title": title,
		"subtitle": subtitle,
		"show_scores": has_official_mission or is_training,
		"scores": scores,
		"details": details,
		"objectives": objectives,
		"history": history,
	}

static func tooltip_copy(state: Dictionary, combat: Variant, combat_enabled: bool) -> String:
	var mission: Dictionary = state.get("mission", {})
	var lines: Array[String] = ["MISSION STATUS"]
	if combat.Mission.enabled(state):
		lines.append("CA 2026-27 · %s · Hammer and Anvil" % str(mission.get("name", "Primary mission")))
		lines.append("Score: P1 %d VP · P2 %d VP" % [int(mission.get("scores", {}).get(1, 0)), int(mission.get("scores", {}).get(2, 0))])
		var force_disposition_names: Dictionary = mission.get("force_disposition_names", {})
		if not force_disposition_names.is_empty():
			lines.append("Force Dispositions: P1 %s · P2 %s" % [str(force_disposition_names.get(1, "Unknown")), str(force_disposition_names.get(2, "Unknown"))])
			lines.append("Primary cards use direct selection, which can override the disposition matchup.")
		var primary_names: Dictionary = mission.get("primary_names", {})
		lines.append("Primary cards: P1 %s · P2 %s" % [str(primary_names.get(1, primary_names.get("1", "Primary"))), str(primary_names.get(2, primary_names.get("2", "Primary")))])
		lines.append("Primary: %d / %d VP · fixed secondaries: %d / %d VP" % [int(mission.get("primary", {}).get(1, 0)), int(mission.get("primary", {}).get(2, 0)), int(mission.get("secondary", {}).get(1, 0)), int(mission.get("secondary", {}).get(2, 0))])
		var card_scores: Dictionary = mission.get("cards", {})
		var p1_card_scores: Dictionary = card_scores.get(1, {})
		var p2_card_scores: Dictionary = card_scores.get(2, {})
		for card: String in mission.get("secondary_cards", []):
			lines.append("• %s: P1 %d VP · P2 %d VP" % [combat.Mission.SECONDARY_CARD_NAMES.get(card, card), int(p1_card_scores.get(card, 0)), int(p2_card_scores.get(card, 0))])
	elif combat.Objectives.training(state):
		lines.append("Custom objective training · Round %d / %d" % [int(state.get("round", 1)), int(mission.get("rounds", 5))])
		lines.append("Score: P1 %d VP · P2 %d VP (%d VP per controlled objective at round end)" % [int(mission.get("scores", {}).get(1, 0)), int(mission.get("scores", {}).get(2, 0)), int(mission.get("points_per_objective", 1))])
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
			if combat.Mission.enabled(state): target_owners = combat.Mission.tempting_target_owners(state, objective_name)
			if not target_owners.is_empty(): control_text += " · Tempting Target for " + ", ".join(target_owners)
			var vowed_owners: Array[int] = []
			if combat_enabled: vowed_owners = combat.VowedTarget.owners_of_objective(state, objective_index)
			if not vowed_owners.is_empty(): control_text += " · Vowed by " + "/".join(vowed_owners.map(func(owner: int) -> String: return "P%d" % owner))
			lines.append("%s — %s\nP1 OC %d · P2 OC %d" % [objective_name, control_text, int(levels.get(1, 0)), int(levels.get(2, 0))])
		lines.append("")
		lines.append("Control and OC are the latest resolved phase values. Movement previews do not update them; control is recalculated at the next phase boundary.")
	if combat.Mission.enabled(state):
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

static func recent_training_round_events(state: Dictionary) -> Array[String]:
	var events: Array[String] = []
	var match_events: Array = state.get("events", [])
	for index in range(match_events.size() - 1, -1, -1):
		var event: Dictionary = match_events[index]
		var message := str(event.get("message", ""))
		if not message.begins_with("Training round "): continue
		events.append("• " + message)
		if events.size() >= 5: break
	return events

static func round_receipt(state: Dictionary, combat: Variant) -> Dictionary:
	var mission: Dictionary = state.get("mission", {})
	if combat.Objectives.training(state):
		var receipts: Array = mission.get("round_receipts", [])
		if receipts.is_empty():
			return {}
		var latest: Dictionary = receipts[-1]
		var round_number := int(latest.get("round", 0))
		var gained: Dictionary = latest.get("gained", {})
		var totals: Dictionary = latest.get("totals", mission.get("scores", {}))
		var p1_gain := int(gained.get(1, gained.get("1", 0)))
		var p2_gain := int(gained.get(2, gained.get("2", 0)))
		var p1_names: Array[String] = []
		var p2_names: Array[String] = []
		for obj: Variant in latest.get("objectives", []):
			if not obj is Dictionary: continue
			if int(obj.get("owner", 0)) == 1: p1_names.append(str(obj.get("name", "Objective")))
			elif int(obj.get("owner", 0)) == 2: p2_names.append(str(obj.get("name", "Objective")))
		var breakdown := ""
		if p1_gain == 0 and p2_gain == 0:
			breakdown = "Round %d scored · 0 VP awarded (all objectives neutral at round end)." % round_number
		else:
			var p1_part := "P1 +%d VP (%s)" % [p1_gain, ", ".join(p1_names)] if p1_gain > 0 else "P1 +0 VP"
			var p2_part := "P2 +%d VP (%s)" % [p2_gain, ", ".join(p2_names)] if p2_gain > 0 else "P2 +0 VP"
			breakdown = "Round %d scored · %s · %s" % [round_number, p1_part, p2_part]
		return {
			"round": round_number,
			"summary": breakdown,
			"totals": "Total: P1 %d VP · P2 %d VP" % [int(totals.get(1, totals.get("1", 0))), int(totals.get(2, totals.get("2", 0)))],
			"timing_note": "Based on resolved round-end control.",
		}
	if combat.Mission.enabled(state):
		var mission_log: Array = mission.get("log", [])
		for index in range(mission_log.size() - 1, -1, -1):
			var event_text := str(mission_log[index])
			if " VP" not in event_text: continue
			var scores: Dictionary = mission.get("scores", {})
			return {
				"round": int(state.get("round", 1)),
				"summary": event_text,
				"totals": "Total: P1 %d VP · P2 %d VP" % [int(scores.get(1, 0)), int(scores.get(2, 0))],
				"timing_note": "Based on resolved mission scoring.",
			}
	return {}

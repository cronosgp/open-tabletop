extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PhaseEligibility = preload("res://scripts/edition_11/phase_eligibility.gd")
const DecisionCopy = preload("res://scripts/ui/decision_copy.gd")
const DoctrinePanel = preload("res://scripts/ui/doctrine_panel.gd")
const MissionPresenter = preload("res://scripts/ui/mission_presenter.gd")
const RoundReceipt = preload("res://scripts/ui/round_receipt.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_phase_1_decision_copy()
	_test_phase_2_suggested_deployment()
	_test_phase_3_doctrine_panel()
	_test_phase_4_phase_eligibility()
	_test_phase_5_round_receipt()
	print("Gameplay flow overhaul checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _test_phase_1_decision_copy() -> void:
	var roll_state := {
		"round": 1,
		"phase": "shooting",
		"active": 1,
		"turn": 1,
		"combat_doctrines": {"active": {1: "none", 2: "none"}, "used": {1: [], 2: []}, "extra_used": {1: false, 2: false}, "pending_player": 0},
		"oath_of_moment": {"pending_player": 0, "target": 0},
		"stratagems": {"pending": {"kind": "save", "player": 2, "cost": 1}, "used_this_phase": {}},
		"pending_move": {},
		"pending_charge": {},
		"pending_attack": {},
		"pending_hazard": {},
		"pending_contact": {},
	}
	var built := DecisionCopy.build_decision(roll_state, 2, "local", 1, -1, Combat, {}, false)
	check("Player 2 decides" in str(built.get("owner_text", "")), "Decision copy identifies the deciding player")
	check("Command Re-roll" in str(built.get("view", {}).get("instruction", "")), "Decision copy explains Command Re-roll reaction window")

func _test_phase_2_suggested_deployment() -> void:
	var non_deploy := {"phase": "command", "active": 1, "revision": 0, "deployment": {}}
	check(not Deployment.suggested_error(non_deploy, 1, 0).is_empty(), "Suggested deployment is rejected outside deployment phase")

	# Build a minimal deployment-phase state with one undeployed squad for Player 1
	var deploy_state := {
		"phase": "deployment",
		"active": 1,
		"turn": 1,
		"round": 1,
		"revision": 3,
		"board_size": Vector2(60.0, 44.0),
		"terrain": {"areas": [], "obstacles": []},
		"squads": {1: {"owner": 1, "name": "Intercessor Squad", "reserves": ""}},
		"units": {
			101: {"id": 101, "owner": 1, "squad": 1, "alive": true, "wounds": 2, "position": Vector2(-24.0, -1.0), "radius": 0.63, "elevation": 0.0},
			102: {"id": 102, "owner": 1, "squad": 1, "alive": true, "wounds": 2, "position": Vector2(-24.0, 1.0), "radius": 0.63, "elevation": 0.0},
		},
		"events": [],
	}
	Deployment.begin(deploy_state)
	check(Deployment.suggested_error(deploy_state, 1, 3).is_empty(), "Suggested deployment is valid for active deployment actor")
	var result := MatchCommandService.execute(deploy_state, 1, {"kind": MatchCommandService.DEPLOYMENT_DEPLOY_SUGGESTED, "revision": 3})
	check(str(result.get("error", "")).is_empty(), "MatchCommandService handles DEPLOYMENT_DEPLOY_SUGGESTED: %s" % str(result))
	check(bool(deploy_state.deployment.complete), "Suggested deployment completes deployment for single-squad queue")
	check(1 in deploy_state.deployment.committed, "Suggested deployment commits the deployed squad")

class _DoctrinesStub extends RefCounted:
	const NAMES := {"none": "No Combat Doctrine", "devastator": "Devastator Doctrine", "tactical": "Tactical Doctrine", "assault": "Assault Doctrine"}
	const ORDER := ["devastator", "tactical", "assault"]
	const DETACHMENT_EXTRA_DOCTRINES := {}
	func detachment_for(_state: Dictionary, _player: int) -> String: return "gladius"
	func available(_state: Dictionary, _player: int) -> Array[String]: return ["devastator", "tactical", "assault"]
	func blade_mastered_doctrines_active(_state: Dictionary, _player: int) -> bool: return false

func _test_phase_3_doctrine_panel() -> void:
	var state := {
		"active": 1,
		"combat_doctrines": {
			"active": {1: "none", 2: "none"},
			"used": {1: [], 2: []},
			"extra_used": {1: false, 2: false},
			"pending_player": 1,
		},
		"squads": {},
		"units": {},
	}
	var stub := _DoctrinesStub.new()
	var choice := OptionButton.new()
	var confirm := Button.new()
	var skip := Button.new()
	var help := Label.new()
	DoctrinePanel.present(state, stub, choice, confirm, skip, help, false)
	check(confirm.text == "Continue without a doctrine" and not skip.visible, "When 'none' is selected, primary button says 'Continue without a doctrine' and skip button is hidden")
	choice.select(1)
	DoctrinePanel.present(state, stub, choice, confirm, skip, help, false)
	check(confirm.text.begins_with("Activate ") and skip.visible, "When a doctrine is selected, primary button activates it and secondary skip button is visible")
	choice.free()
	confirm.free()
	skip.free()
	help.free()

func _test_phase_4_phase_eligibility() -> void:
	var base := Combat.initial_state()
	base.phase = "charge"
	base.active = 1
	var never_charge := {"can_declare_charge": func(_s: Dictionary, _p: int, _id: int) -> bool: return false}
	var can_charge := {"can_declare_charge": func(_s: Dictionary, _p: int, _id: int) -> bool: return true}

	check(not bool(PhaseEligibility.can_auto_skip(base, never_charge).get("skip", false)), "Auto-skip is disabled when auto_advance_empty_phases is false")

	var enabled := base.duplicate(true)
	enabled.auto_advance_empty_phases = true
	check(bool(PhaseEligibility.can_auto_skip(enabled, never_charge).get("skip", false)), "Empty charge phase auto-skips when enabled and no unit can charge")
	check(not bool(PhaseEligibility.can_auto_skip(enabled, can_charge).get("skip", false)), "Charge phase does NOT auto-skip when a squad can declare a charge")

	enabled.phase = "fight"
	enabled.fight_step = "complete"
	check(bool(PhaseEligibility.can_auto_skip(enabled, never_charge).get("skip", false)), "Empty fight phase auto-skips when no Fight-start triggers or combat eligibilities exist")

func _test_phase_5_round_receipt() -> void:
	var state := {
		"round": 1,
		"phase": "end_turn",
		"active": 2,
		"first_player": 1,
		"mission": {
			"id": Combat.Objectives.TRAINING,
			"points_per_objective": 2,
			"rounds": 5,
			"scored_rounds": [],
			"scores": {1: 0, 2: 0},
			"objectives": [
				{"name": "Alpha", "position": Vector2.ZERO, "radius": 3.0, "controller": 1, "levels": {1: 2, 2: 0}},
				{"name": "Beta", "position": Vector2(10, 0), "radius": 3.0, "controller": 0, "levels": {1: 0, 2: 0}},
			],
		},
		"squads": {},
		"units": {},
		"events": [],
	}
	Combat.Objectives.score_round(state)
	var receipts: Array = state.mission.get("round_receipts", [])
	check(receipts.size() == 1, "Objectives.score_round records a structured round_receipts entry")
	var view := MissionPresenter.round_receipt(state, Combat)
	check("Round 1 scored" in str(view.get("summary", "")) and "P1 +2 VP (Alpha)" in str(view.get("summary", "")), "MissionPresenter formats round-end scoring receipt")

	var panel := RoundReceipt.new()
	panel._ready()
	panel.present(view)
	check(panel.visible and "P1 +2 VP" in panel.summary_label.text, "RoundReceipt presents structured receipt")
	panel.dismiss_button.pressed.emit()
	check(not panel.visible, "Dismiss hides RoundReceipt for that round")
	panel.present(view)
	check(not panel.visible, "Dismissed RoundReceipt stays hidden for the same round")
	panel.free()

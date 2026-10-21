"""Static checks for rules-module dependency direction."""
import re
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
PRELOAD = re.compile(r'preload\("res://scripts/edition_11/([^"/]+)\.gd"\)')


def edition_11_graph():
    scripts = {path.stem: path for path in (ROOT / "scripts/edition_11").glob("*.gd")}
    graph = {}
    for name, path in scripts.items():
        graph[name] = {target for target in PRELOAD.findall(path.read_text(encoding="utf-8")) if target in scripts}
    return graph


def reachable(graph, source, target):
    pending = [source]
    visited = set()
    while pending:
        current = pending.pop()
        if current == target:
            return True
        if current in visited:
            continue
        visited.add(current)
        pending.extend(graph.get(current, ()) - visited)
    return False


def cyclic_components(graph):
    """Return preload dependency cycles, including self-referencing modules."""
    unseen = set(graph)
    components = []
    while unseen:
        source = unseen.pop()
        component = {source}
        for candidate in tuple(unseen):
            if reachable(graph, source, candidate) and reachable(graph, candidate, source):
                component.add(candidate)
        unseen.difference_update(component)
        if len(component) > 1 or source in graph.get(source, set()):
            components.append(frozenset(component))
    return set(components)


def function_block(source, name):
    match = re.search(rf"^(?:static )?func {re.escape(name)}\b.*?(?=^(?:static )?func |^@rpc|\Z)", source, re.MULTILINE | re.DOTALL)
    return match.group(0) if match else ""


class ArchitectureDependencyTests(unittest.TestCase):
    def test_player_phases_are_separate_from_turn_boundary_steps(self):
        source = (ROOT / "scripts/edition_11/phase_progression.gd").read_text(encoding="utf-8")
        self.assertIn('const PHASES := ["command", "movement", "shooting", "charge", "fight"]', source)
        self.assertIn('const PROGRESSION_STEPS := ["start_turn", "command", "movement", "shooting", "charge", "fight", "end_turn"]', source)
        self.assertIn("static func is_player_phase(phase: String)", source)
        self.assertIn("PROGRESSION_STEPS.find(current)", source)

    def test_edition_rules_preload_graph_has_no_cycles(self):
        graph = edition_11_graph()
        self.assertEqual(cyclic_components(graph), set())

    def test_doctrines_use_low_level_ability_catalog(self):
        graph = edition_11_graph()
        self.assertIn("unit_ability_catalog", graph["combat_doctrines"])
        self.assertNotIn("unit_abilities", graph["combat_doctrines"])

    def test_objectives_receive_control_calculation_from_the_caller(self):
        graph = edition_11_graph()
        self.assertNotIn("morale", graph["objectives"])

    def test_leader_identity_catalog_stays_below_rules_and_setup(self):
        graph = edition_11_graph()
        self.assertIn("leader_catalog", graph["leaders"])
        self.assertIn("leader_catalog", graph["unit_abilities"])
        self.assertIn("leader_catalog", graph["unit_actions"])
        self.assertNotIn("leaders", graph["unit_abilities"])
        self.assertNotIn("leaders", graph["unit_actions"])
        self.assertFalse(reachable(graph, "unit_abilities", "leaders"))
        self.assertFalse(reachable(graph, "unit_actions", "leaders"))

    def test_match_actor_resolver_does_not_depend_on_combat_facade(self):
        graph = edition_11_graph()
        self.assertIn("match_actor", graph["combat_scenario"])
        self.assertFalse(reachable(graph, "match_actor", "combat_scenario"))

    def test_phase_boundary_resolution_sits_below_the_combat_facade(self):
        graph = edition_11_graph()
        combat_source = (ROOT / "scripts/edition_11/combat_scenario.gd").read_text(encoding="utf-8")
        phase_source = (ROOT / "scripts/edition_11/phase_resolution.gd").read_text(encoding="utf-8")
        self.assertIn("PhaseResolution.advance_after_admission", function_block(combat_source, "advance_phase"))
        self.assertIn("phase_resolution", graph["combat_scenario"])
        self.assertNotIn("combat_scenario", graph["phase_resolution"])
        self.assertIn("PhaseProgression.advance(state)", phase_source)
        self.assertIn("UnitActions.open_end(state)", phase_source)
        self.assertIn("ResolutionFrames.begin(state", phase_source)
        self.assertIn("ResolutionFrames.suspend(state", phase_source)
        self.assertIn("ResolutionFrames.complete(state", phase_source)
        self.assertIn("resolution_frame", graph["pending_decision"])
        self.assertIn("resolution_frame", graph["phase_resolution"])
        self.assertFalse(reachable(graph, "resolution_frame", "combat_scenario"))

    def test_doctrine_choice_priority_uses_the_shared_decision_projection(self):
        graph = edition_11_graph()
        doctrine_source = (ROOT / "scripts/edition_11/combat_doctrines.gd").read_text(encoding="utf-8")
        actor_source = (ROOT / "scripts/edition_11/match_actor.gd").read_text(encoding="utf-8")
        self.assertIn("static func pending_decision(state: Dictionary)", doctrine_source)
        self.assertIn('preload("res://scripts/edition_11/pending_decision.gd")', doctrine_source)
        self.assertIn("PendingDecisions.current(state", actor_source)
        self.assertIn("pending_decision", graph["combat_doctrines"])
        self.assertIn("pending_decision_registry", graph["match_actor"])
        self.assertIn("pending_decision_registry", graph["phase_close_gate"])
        registry_source = (ROOT / "scripts/edition_11/pending_decision_registry.gd").read_text(encoding="utf-8")
        self.assertIn("static func current(state: Dictionary, source_order: Array)", registry_source)
        self.assertNotIn("DEFAULT_ORDER", registry_source)
        self.assertIn("PendingDecisions.current(state", (ROOT / "scripts/edition_11/phase_close_gate.gd").read_text(encoding="utf-8"))

    def test_match_commands_leave_main_as_transport_and_presentation_adapter(self):
        graph = edition_11_graph()
        service_source = (ROOT / "scripts/edition_11/match_command_service.gd").read_text(encoding="utf-8")
        main_source = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
        self.assertIn("match_command_service", graph)
        self.assertIn("MatchCommandService.execute(", main_source)
        self.assertIn("func _unit_choice_payload(choice: Dictionary)", main_source)
        self.assertIn("MatchCommandService.UNIT_CHOICE_ENVELOPE", main_source)
        self.assertIn("decision_id: String, option_id: String", function_block(main_source, "request_combat_doctrine"))
        self.assertIn('"decision_id": decision_id, "option_id": option_id', function_block(main_source, "_apply_combat_doctrine"))
        registry_source = (ROOT / "scripts/edition_11/pending_decision_registry.gd").read_text(encoding="utf-8")
        for source in ["Doctrines", "DamageAllocation", "Reanimation", "Stratagems", "UnitActions"]:
            self.assertIn(f"{source}.pending_decision(state)", registry_source)
        self.assertIn("func _stratagem_choice_payload(squad: int, stratagem: String, die: int)", main_source)
        self.assertIn("func _reanimation_choice_payload(action: String, squad: int, model: int)", main_source)
        self.assertIn("STRATAGEM_DECISION_ENVELOPE", main_source)
        self.assertNotIn('preload("res://scripts/main.gd")', service_source)
        self.assertNotIn('preload("res://scripts/network/', service_source)
        expected_delegations = {
            "_apply_end": "Combat.advance_phase",
            "_apply_combat_doctrine": "Combat.select_combat_doctrine",
            "_apply_unit_action": "Combat.unit_action",
            "_apply_deployment": "MatchCommandService.DEPLOYMENT_",
            "_apply_move": "MatchCommandService.PLACE_MODEL",
            "_apply_allocate_damage": "MatchCommandService.ALLOCATE_DAMAGE",
            "_apply_command_reaction": "MatchCommandService.COMMAND_REACTION",
            "_apply_coherency_removal": "MatchCommandService.REMOVE_COHERENCY",
            "_apply_oath_target": "MatchCommandService.SELECT_OATH_TARGET",
            "_apply_reanimation": "MatchCommandService.RESOLVE_REANIMATION",
            "_apply_awakened_attachment": "MatchCommandService.SELECT_AWAKENED_ATTACHMENT",
            "_apply_begin_movement": "Combat.begin_movement",
            "_apply_abandon_fall_back": "Combat.abandon_fall_back",
            "_apply_escape_wound": "Combat.allocate_escape_wound",
            "_apply_finish_movement": "Combat.finish_movement",
            "_apply_charge_roll": "Combat.declare_charge",
            "_apply_charge": "Combat.select_charge_target",
            "_apply_begin_contact": "Combat.begin_contact_move",
            "_apply_contact_move": "Combat.stage_contact_move",
            "_apply_finish_contact": "Combat.finish_contact_move",
            "_apply_attack": "Combat.shoot",
            "_apply_attack_plan": "Combat.resolve_attack_plan",
            "_apply_fight": "Combat.fight",
            "_apply_action": "Combat.start_action",
        }
        for adapter, rules_call in expected_delegations.items():
            block = function_block(main_source, adapter)
            self.assertIn("MatchCommandService.execute(" if not rules_call.startswith("MatchCommandService.") else rules_call, block, adapter)
            if not rules_call.startswith("MatchCommandService."):
                self.assertNotIn(rules_call, block, adapter)

    def test_projected_decision_envelope_validation_is_shared_by_command_handlers(self):
        source = (ROOT / "scripts/edition_11/match_command_service.gd").read_text(encoding="utf-8")
        self.assertIn("static func _projected_option(", source)
        for handler in ["_select_doctrine", "_select_unit_choice", "_allocate_damage", "_command_reaction", "_resolve_reanimation"]:
            self.assertIn("_projected_option(", function_block(source, handler), handler)

    def test_guest_command_admission_is_owned_by_match_session(self):
        main_source = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
        session_source = (ROOT / "scripts/network/match_session.gd").read_text(encoding="utf-8")
        self.assertIn("func accepts_guest_command(peer_id: int)", session_source)
        self.assertIn("match_session.accepts_guest_command(", main_source)
        self.assertNotRegex(main_source, r'multiplayer\.get_remote_sender_id\(\)\s*==\s*guest_id')
        self.assertNotRegex(main_source, r'multiplayer\.get_remote_sender_id\(\)\s*!=\s*guest_id')


if __name__ == "__main__":
    unittest.main()

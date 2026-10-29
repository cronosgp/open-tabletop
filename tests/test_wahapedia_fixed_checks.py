import copy
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
import wahapedia_fixed_checks as checks
import build_space_marine_transport_profiles as transport_builder
import compare_wahapedia_marines as marine_comparer


class FixedDataChecksTests(unittest.TestCase):
    def test_runtime_source_identity_accepts_chapter_books_and_rejects_mismatched_ids(self):
        sheet = {"id": "000002795", "source_id": "000000162", "name": "Emperor’s Champion"}
        sources = {"000000162": {"id": "000000162", "name": "Black Templars", "edition": "11"}}
        profile = {"name": "Emperor's Champion", "source_book_id": "000000162", "source_datasheet_id": "000002795"}

        self.assertTrue(marine_comparer._runtime_identity_check("emperor-s-champion", profile, sheet, sources)["consistent"])
        wrong_book = dict(profile, source_book_id="000000139")
        self.assertFalse(marine_comparer._runtime_identity_check("emperor-s-champion", wrong_book, sheet, sources)["consistent"])
        wrong_sheet = dict(profile, source_datasheet_id="000002794")
        self.assertFalse(marine_comparer._runtime_identity_check("emperor-s-champion", wrong_sheet, sheet, sources)["consistent"])
        wrong_edition = {"000000162": {"id": "000000162", "name": "Black Templars", "edition": "10"}}
        self.assertFalse(marine_comparer._runtime_identity_check("emperor-s-champion", profile, sheet, wrong_edition)["consistent"])

    def test_traits_detect_changed_parameters_unknown_effects_and_boolean_parameter(self):
        self.assertTrue(checks.traits("ASSAULT, Rapid Fire 1", {"assault": True, "rapid-fire": 1})["consistent"])
        self.assertFalse(checks.traits("Rapid Fire 2", {"rapid-fire": 1})["consistent"])
        self.assertFalse(checks.traits("Rapid Fire 1", {"rapid-fire": True})["consistent"])
        self.assertFalse(checks.traits("Unreviewed effect", {})["consistent"])
        self.assertFalse(checks.traits("", {"heavy": True})["consistent"])
        self.assertTrue(checks.traits("PSYCHIC", {"psychic": True})["consistent"])
        self.assertTrue(checks.traits("Pistol", {"close-quarters": True})["consistent"])
        self.assertTrue(checks.traits("Blast 1", {"blast": 1})["consistent"])
        self.assertTrue(checks.traits("Blast 1", {"blast": True})["consistent"])
        self.assertTrue(checks.traits("Blast 2", {"blast": 2})["consistent"])
        self.assertTrue(checks.traits("Anti-Fly 2+", {"anti-fly": 2})["consistent"])
        self.assertTrue(checks.traits("Anti-Vehicle 2+", {"anti-vehicle": 2})["consistent"])
        self.assertTrue(checks.traits("Twin-linked, Rapid Fire 2", {"twin-linked": True, "rapid-fire": 2})["consistent"])
        conditional = checks.traits("Devastating Wounds: non-MONSTER/VEHICLE, Sustained Hits 2: non-MONSTER/VEHICLE",
                                    {"devastating-wounds": True, "sustained-hits": 2},
                                    {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]})
        self.assertTrue(conditional["consistent"])
        self.assertTrue(checks.traits("One Shot, Anti-Monster/Vehicle 4+, Lance",
                                      {"one-shot": True, "anti-monster": 4, "anti-vehicle": 4, "lance": True})["consistent"])
        self.assertTrue(checks.traits("Anti-non-Monster/vehicle 2+", {"anti-non-monster-vehicle": 2})["consistent"])
        self.assertTrue(checks.traits("Devastating Wounds: Infantry", {"devastating-wounds": True},
                                      {}, {"devastating-wounds": ["INFANTRY"]})["consistent"])
        self.assertFalse(checks.traits("Devastating Wounds: Infantry", {"devastating-wounds": True},
                                       {"devastating-wounds": ["INFANTRY"]})["consistent"])
        self.assertTrue(checks.traits("Rapid Fire 2", {"rapid-fire": 2.0})["consistent"])
        self.assertEqual(checks.number("D3+3"), "D3+3")

    def test_target_restricted_lethal_hits_requires_matching_runtime_condition(self):
        source = "CLEAVE 1, LETHAL HITS: non-MONSTER/VEHICLE"
        runtime = {"cleave": 1, "lethal-hits": True}
        condition = {"lethal-hits": ["MONSTER", "VEHICLE"]}
        self.assertTrue(checks.traits(source, runtime, condition)["consistent"])
        self.assertFalse(checks.traits(source, runtime)["consistent"])

    def test_hunter_profiles_reconcile_source_page_gate_omitted_from_export_rows(self):
        expected_profile = {"name": "Chainfist - Hunter", "keywords": {"hunter": ["Monster", "Vehicle"]}}
        gate = marine_comparer.hunter_profile_target_check("000001183", "Chainfist - Hunter", expected_profile)
        self.assertTrue(gate["recognized"] and gate["consistent"])
        for sheet_id, weapon_name in [("000003873", "Chainfist - Hunter"),
                                      ("000000230", "Chainfist - Hunter"),
                                      ("000002781", "Melta Rifle - Hunter"),
                                      ("000002781", "Multi-melta - Hunter")]:
            self.assertTrue(marine_comparer.hunter_profile_target_check(
                sheet_id, weapon_name, expected_profile)["consistent"])
        self.assertFalse(marine_comparer.hunter_profile_target_check(
            "000001183", "Chainfist - Hunter", {"name": "Chainfist - Hunter", "keywords": {}})["consistent"])
        self.assertFalse(marine_comparer.hunter_profile_target_check(
            "000001183", "Chainfist - Hunter", {"name": "Chainfist - Hunter", "keywords": {"hunter": ["INFANTRY"]}})["consistent"])
        self.assertFalse(marine_comparer.hunter_profile_target_check(
            "000001183", "Unmapped Hunter", expected_profile)["consistent"])

    def test_source_wargear_traits_and_pistol_types_are_projected(self):
        source_ability = {"type": "Wargear",
                          "description": "Ranged weapons equipped by the bearer have the [IGNORES COVER] ability."}
        projections = marine_comparer.source_wargear_weapon_trait_projections([source_ability])
        self.assertEqual(projections, {"ranged": {"ignores-cover"}, "melee": set()})
        source = {"name": "Bolt Pistol", "description": ""}
        description = marine_comparer.source_weapon_trait_description(source, "ranged")
        self.assertTrue(checks.traits(description, {"close-quarters": True})["consistent"])
        self.assertTrue(checks.traits(
            marine_comparer.source_weapon_trait_description({"name": "Twin Assault Cannon", "description": ""},
                                                            "ranged", projections["ranged"]),
            {"ignores-cover": True})["consistent"])

    def test_transport_builder_extracts_excluded_and_required_target_traits(self):
        self.assertEqual(transport_builder.target_conditions(
            "DEVASTATING WOUNDS: non-MONSTER/VEHICLE, SUSTAINED HITS 2: non-MONSTER/VEHICLE"),
            {"target_restricted_traits": {
                "devastating-wounds": ["MONSTER", "VEHICLE"],
                "sustained-hits": ["MONSTER", "VEHICLE"]}})
        self.assertEqual(transport_builder.target_conditions("DEVASTATING WOUNDS: INFANTRY"),
                         {"target_required_traits": {"devastating-wounds": ["INFANTRY"]}})

    def test_role_specific_default_loadout_is_compared_by_model_type(self):
        source = ('<b>The Vanguard Veteran Sergeant with Jump Pack is equipped with:</b> '
                  '1 Heavy Bolt Pistol; 1 Relic Blade.<br><br>'
                  '<b>Every Vanguard Veteran with Jump Pack is equipped with:</b> '
                  '1 Heavy Bolt Pistol; 1 Master-crafted Power Weapon.')
        runtime = {"default_loadout_by_role": {
            "Vanguard Veteran Sergeant with Jump Pack": {"heavy bolt pistol": 1, "relic blade": 1},
            "Vanguard Veteran with Jump Pack": {"heavy bolt pistol": 1, "master-crafted power weapon": 1}}}
        self.assertTrue(checks.loadout(source, runtime)["consistent"])
        runtime["default_loadout_by_role"]["Vanguard Veteran Sergeant with Jump Pack"]["relic blade"] = 0
        self.assertFalse(checks.loadout(source, runtime)["consistent"])

    def test_generic_source_model_role_covers_runtime_model_roles_and_implicit_items(self):
        source = "<b>Every model is equipped with:</b> 1 Bolt Pistol; Chainsword."
        profile = {"default_loadout_by_role": {
            "Blood Claw": {"Bolt Pistol": 1, "Chainsword": 1},
            "Blood Claw Pack Leader": {"Bolt Pistol": 1, "Chainsword": 1}}}
        self.assertTrue(checks.loadout(source, profile)["consistent"])
        profile["default_loadout_by_role"]["Blood Claw Pack Leader"]["Chainsword"] = 0
        result = checks.loadout(source, profile)
        self.assertFalse(result["consistent"])
        self.assertEqual(result["differences"]["Blood Claw Pack Leader"], result["source_by_role"]["model"])

    def test_single_this_model_role_matches_named_runtime_role_and_source_alias(self):
        source = "<b>This model is equipped with:</b> 1 Artificier Crozius; The Lion Helm."
        profile = {"default_loadout_by_role": {"Azrael": {
            "Artificer Crozius": 1, "The Lion Helm": 1}}}
        self.assertTrue(checks.loadout(source, profile)["consistent"])


    def test_role_loadout_normalizes_display_names_and_accepts_banner_option(self):
        source = ('<b>The Chapter Ancient is equipped with:</b> Banner of Macragge; '
                  '1 Master-crafted Bolt Carbine; 1 Master-crafted Power Weapon.')
        profile = {"default_loadout_by_role": {"Chapter Ancient": {
            "Banner of Macragge": 1, "Master-crafted Bolt Carbine": 1, "Master-crafted Power Weapon": 1}}}
        self.assertTrue(checks.loadout(source, profile)["consistent"])

    def test_named_model_loadouts_follow_source_model_names_not_array_position(self):
        source = ('<b>Model One is equipped with:</b> 1 First Weapon.<br><br>'
                  '<b>Model Two is equipped with:</b> 1 Second Weapon.')
        profile = {"model_loadouts": [
            {"source_model_name": "Model Two", "ranged": [{"id": "second", "profiles": {"a": {"name": "Second Weapon - Rapid"}, "b": {"name": "Second Weapon - Slow"}}}], "melee": []},
            {"source_model_name": "Model One", "ranged": [], "melee": [{"id": "first", "profiles": {"standard": {"name": "First Weapon"}}}]}]}
        self.assertTrue(checks.loadout(source, profile)["consistent"])

    def test_model_loadout_role_labels_with_equipment_suffix_match_by_role_and_signature(self):
        source = ('<b>The Veteran with Stalker Rifle, Bolt Pistol and Fists is equipped with:</b> '
                  '1 Bolt Pistol; 1 Stalker Rifle; 1 Knives and Fists.<br><br>'
                  '<b>The Sergeant is equipped with:</b> 1 Plasma Pistol; 1 Power Weapon.')
        veteran = {"source_model_name": "Veteran with Stalker Rifle",
                   "ranged": [{"id": "pistol", "profiles": {"standard": {"name": "Bolt Pistol"}}},
                              {"id": "rifle", "profiles": {"standard": {"name": "Stalker Rifle"}}}],
                   "melee": [{"id": "fists", "profiles": {"standard": {"name": "Knives and Fists"}}}]}
        profile = {"model_loadouts": [
            {"source_model_name": "Sergeant", "ranged": [{"id": "plasma", "profiles": {"standard": {"name": "Plasma Pistol"}}}],
             "melee": [{"id": "power", "profiles": {"standard": {"name": "Power Weapon"}}}]},
            veteran, copy.deepcopy(veteran)]}
        self.assertTrue(checks.loadout(source, profile)["consistent"])
        profile["model_loadouts"][1]["ranged"][1]["profiles"]["standard"]["name"] = "Wrong Rifle"
        self.assertFalse(checks.loadout(source, profile)["consistent"])

    def test_empty_source_loadout_is_consistent_only_for_empty_runtime_equipment(self):
        self.assertTrue(checks.loadout("", {"ranged": [], "melee": []})["consistent"])
        self.assertFalse(checks.loadout("", {"ranged": [{"profiles": {"standard": {"name": "Weapon"}}}], "melee": []})["consistent"])

    def test_all_formation_sizes_and_third_plus_prices_are_compared(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST TO 2ND UNITS COST", "cost": ""},
            {"line": "2", "description": "5 models", "cost": "110"},
            {"line": "3", "description": "10 models", "cost": "220"},
            {"line": "4", "description": "YOUR 3RD+ UNIT COSTS", "cost": ""},
            {"line": "5", "description": "5 models", "cost": "130"},
            {"line": "6", "description": "10 models", "cost": "240"}]
        fixed = {"cost": 110, "models": 5, "sizes": {"5": 110, "10": 220},
                 "third_plus_sizes": {"5": 130, "10": 240}}
        self.assertTrue(checks.costs(rows, fixed)["consistent"])
        fixed["third_plus_sizes"]["10"] = 200
        self.assertFalse(checks.costs(rows, fixed)["consistent"])

    def test_two_modes_are_one_weapon_but_an_added_weapon_is_not_default(self):
        profile = {"ranged": [{"id": "rifle", "profiles": {"one": {"name": "Original Rifle - One"}, "two": {"name": "Original Rifle - Two"}}}],
                   "melee": [{"id": "fists", "profiles": {"standard": {"name": "Original Fists"}}}]}
        source = "<b>Every model is equipped with:</b> 1 Original Rifle; 1 Original Fists."
        self.assertTrue(checks.loadout(source, profile)["consistent"])
        changed = copy.deepcopy(profile)
        changed["ranged"].append(copy.deepcopy(changed["ranged"][0]))
        self.assertFalse(checks.loadout(source, changed)["consistent"])
        changed["ranged"][0]["profiles"]["two"]["name"] = "Different Weapon"
        self.assertTrue(checks.loadout(source, changed)["issues"])

    def test_unknown_loadout_and_composition_are_not_guessed(self):
        self.assertFalse(checks.loadout("Select equipment", {"ranged": [], "melee": []})["consistent"])
        rows = [{"line": "1", "description": "1 Original Sergeant model"}, {"line": "2", "description": "4-9 Original Trooper models"}]
        result = checks.composition(rows, {"models": 5})
        self.assertTrue(result["consistent"])
        self.assertFalse(result["model_role_assignment_certified"])
        self.assertFalse(checks.composition(rows, {"models": 4})["consistent"])
        self.assertFalse(checks.composition([{"line": "1", "description": "variable troops"}], {"models": 5})["consistent"])
        optional_roles = [{"line": "1", "description": "0-1 Original Ancient model"},
                          {"line": "2", "description": "0-1 Original Champion model"},
                          {"line": "3", "description": "1-6 Original Guard models"}]
        self.assertTrue(checks.composition(optional_roles, {"models": 3})["consistent"])

    def test_cost_tiers_and_optional_costs_do_not_replace_the_default_price(self):
        rows = [{"line": "1", "description": "YOUR 1ST TO 2ND UNITS COST", "cost": ""},
                {"line": "2", "description": "5 models", "cost": "190"},
                {"line": "3", "description": "YOUR 3RD+ UNIT COSTS", "cost": ""},
                {"line": "4", "description": "5 models", "cost": "230"},
                {"line": "5", "description": "WARGEAR OPTIONS", "cost": ""},
                {"line": "6", "description": "per Original Launcher", "cost": "10"}]
        self.assertTrue(checks.costs(rows, {"models": 5, "cost": 190, "third_cost": 230})["consistent"])
        self.assertFalse(checks.costs(rows, {"models": 5, "cost": 230})["consistent"])
        self.assertFalse(checks.costs(rows, {"models": 10, "cost": 190})["consistent"])
        self.assertFalse(checks.costs(rows, {"models": 5, "cost": 190, "third_cost": 190})["consistent"])

    def test_explicitly_mapped_optional_wargear_price_is_compared(self):
        rows = [{"line": "1", "description": "YOUR 1ST TO 2ND UNITS COST", "cost": ""},
                {"line": "2", "description": "1 model", "cost": "170"},
                {"line": "3", "description": "WARGEAR OPTIONS", "cost": ""},
                {"line": "4", "description": "per Macro Plasma Incinerator", "cost": "10"}]
        fixed = {"models": 1, "cost": 170, "wargear_costs": {"macro-plasma-incinerator": 10}}
        self.assertTrue(checks.costs(rows, fixed)["consistent"])
        fixed["wargear_costs"]["macro-plasma-incinerator"] = 5
        self.assertFalse(checks.costs(rows, fixed)["consistent"])

    def test_duplicate_equal_prices_are_allowed_but_conflicts_are_explicit(self):
        rows = [{"line": "1", "description": "YOUR UNIT COSTS", "cost": ""},
                {"line": "2", "description": "1 model", "cost": "50"},
                {"line": "3", "description": "1 model", "cost": "50"}]
        self.assertTrue(checks.costs(rows, {"models": 1, "cost": 50})["consistent"])
        rows[2]["cost"] = "60"
        self.assertFalse(checks.costs(rows, {"models": 1, "cost": 60})["consistent"])
        rows[0]["description"] = "Unreviewed cost condition"
        self.assertFalse(checks.costs(rows, {"models": 1, "cost": 60})["consistent"])

    def test_first_to_third_and_fourth_plus_prices_keep_copy_boundaries(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST TO 3RD UNITS COST", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "70"},
            {"line": "3", "description": "YOUR 4TH+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "80"},
        ]
        fixed = {"models": 1, "cost": 70, "sizes": {"1": 70}, "third_plus_sizes": {"1": 70}}
        result = checks.costs(rows, fixed, max_supported_copies=3)
        self.assertTrue(result["consistent"])
        self.assertEqual(result["source_sections"]["first_third"], {"1": 70.0})
        self.assertEqual(result["source_sections"]["fourth_plus"], {"1": 80.0})
        self.assertEqual(result["source_fourth_plus_status"], "outside_declared_copy_limit")
        fixed["third_plus_sizes"] = {"1": 80}
        self.assertFalse(checks.costs(rows, fixed, max_supported_copies=3)["consistent"])
        self.assertFalse(checks.costs(rows, {**fixed, "third_plus_sizes": {"1": 70}}, max_supported_copies=4)["consistent"])

    def test_fourth_plus_cost_requires_and_checks_a_separate_runtime_tier(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST TO 3RD UNITS COST", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "70"},
            {"line": "3", "description": "YOUR 4TH+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "80"},
        ]
        fixed = {"models": 1, "cost": 70, "sizes": {"1": 70}, "third_plus_sizes": {"1": 70}}
        self.assertFalse(checks.costs(rows, fixed, max_supported_copies=4)["consistent"])
        fixed["fourth_plus_sizes"] = {"1": 80}
        result = checks.costs(rows, fixed, max_supported_copies=4)
        self.assertTrue(result["consistent"])
        self.assertEqual(result["source_fourth_plus_status"], "represented")

    def test_transport_builder_keeps_first_third_and_fourth_plus_sections_separate(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST TO 3RD UNITS COST", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "60"},
            {"line": "3", "description": "YOUR 4TH+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "70"},
            {"line": "5", "description": "WARGEAR OPTIONS", "cost": ""},
            {"line": "6", "description": "per Sample Upgrade", "cost": "10"},
        ]
        self.assertEqual(transport_builder.cost_tiers(rows), {"first_third": {1: 60}, "fourth_plus": {1: 70}})

    def test_weaponless_datasheets_have_a_valid_empty_trait_comparison(self):
        no_weapons = {"ranged": [], "melee": [], "additional_weapon_profiles": {"ranged": [], "melee": []}}
        blank_source_row = [{"name": ""}]
        self.assertTrue(marine_comparer.weapon_trait_scope_consistent(blank_source_row, no_weapons, []))
        self.assertFalse(marine_comparer.weapon_trait_scope_consistent([{"name": "Storm Bolter"}], no_weapons, []))
        self.assertFalse(marine_comparer.weapon_trait_scope_consistent([], {**no_weapons, "ranged": [{"id": "orphan"}]}, []))

    def test_copy_tier_beyond_declared_cap_does_not_block_in_scope_prices(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST TO 2ND UNITS COST", "cost": ""},
            {"line": "2", "description": "3 models", "cost": "90"},
            {"line": "3", "description": "YOUR 3RD+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "3 models", "cost": "110"},
        ]
        result = checks.costs(rows, {"models": 3, "cost": 90, "sizes": {"3": 90}}, max_supported_copies=2)
        self.assertTrue(result["consistent"])
        self.assertTrue(result["price_scope_complete"])

    def test_first_and_second_plus_prices_compare_second_and_third_copies(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST UNIT COSTS", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "245"},
            {"line": "3", "description": "YOUR 2ND+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "265"},
        ]
        fixed = {"models": 1, "cost": 245, "sizes": {1: 245}, "second_plus_sizes": {1: 265}}
        result = checks.costs(rows, fixed, max_supported_copies=3)
        self.assertTrue(result["consistent"])
        self.assertEqual(result["source_sections"]["second_plus"], {"1": 265.0})
        fixed["second_plus_sizes"] = {1: 255}
        self.assertFalse(checks.costs(rows, fixed, max_supported_copies=3)["consistent"])

    def test_first_and_second_plus_price_cannot_be_misrepresented_as_third_plus_only(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST UNIT COSTS", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "245"},
            {"line": "3", "description": "YOUR 2ND+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "265"},
        ]
        fixed = {"models": 1, "cost": 245, "sizes": {1: 245}, "third_plus_sizes": {1: 265}}
        result = checks.costs(rows, fixed, max_supported_copies=3)
        self.assertFalse(result["consistent"])
        self.assertIn("Runtime does not represent the source price change by the second copy", result["issues"])

    def test_transport_builder_preserves_second_plus_section(self):
        rows = [
            {"line": "1", "description": "YOUR 1ST UNIT COSTS", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "245"},
            {"line": "3", "description": "YOUR 2ND+ UNIT COSTS", "cost": ""},
            {"line": "4", "description": "1 model", "cost": "265"},
        ]
        self.assertEqual(transport_builder.cost_tiers(rows), {"first": {1: 245}, "second_plus": {1: 265}})

    def test_optional_cost_keys_ignore_display_punctuation(self):
        rows = [
            {"line": "1", "description": "YOUR UNIT COSTS", "cost": ""},
            {"line": "2", "description": "1 model", "cost": "260"},
            {"line": "3", "description": "WARGEAR OPTIONS", "cost": ""},
            {"line": "4", "description": "per Heavy Laser Destroyer", "cost": "10"},
        ]
        result = checks.costs(rows, {"models": 1, "cost": 260, "sizes": {1: 260},
                                     "wargear_costs": {"heavy-laser-destroyer": 10}})
        self.assertTrue(result["consistent"])


if __name__ == "__main__":
    unittest.main()

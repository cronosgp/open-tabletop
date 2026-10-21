import copy
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
import wahapedia_fixed_checks as checks


class FixedDataChecksTests(unittest.TestCase):
    def test_traits_detect_changed_parameters_unknown_effects_and_boolean_parameter(self):
        self.assertTrue(checks.traits("ASSAULT, Rapid Fire 1", {"assault": True, "rapid-fire": 1})["consistent"])
        self.assertFalse(checks.traits("Rapid Fire 2", {"rapid-fire": 1})["consistent"])
        self.assertFalse(checks.traits("Rapid Fire 1", {"rapid-fire": True})["consistent"])
        self.assertFalse(checks.traits("Unreviewed effect", {})["consistent"])
        self.assertFalse(checks.traits("", {"heavy": True})["consistent"])
        self.assertTrue(checks.traits("PSYCHIC", {"psychic": True})["consistent"])
        self.assertTrue(checks.traits("Anti-Fly 2+", {"anti-fly": 2})["consistent"])
        self.assertTrue(checks.traits("Anti-Vehicle 2+", {"anti-vehicle": 2})["consistent"])
        self.assertTrue(checks.traits("Twin-linked, Rapid Fire 2", {"twin-linked": True, "rapid-fire": 2})["consistent"])
        conditional = checks.traits("Devastating Wounds: non-MONSTER/VEHICLE, Sustained Hits 2: non-MONSTER/VEHICLE",
                                    {"devastating-wounds": True, "sustained-hits": 2},
                                    {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]})
        self.assertTrue(conditional["consistent"])
        self.assertEqual(checks.number("D3+3"), "D3+3")

    def test_target_restricted_lethal_hits_requires_matching_runtime_condition(self):
        source = "CLEAVE 1, LETHAL HITS: non-MONSTER/VEHICLE"
        runtime = {"cleave": 1, "lethal-hits": True}
        condition = {"lethal-hits": ["MONSTER", "VEHICLE"]}
        self.assertTrue(checks.traits(source, runtime, condition)["consistent"])
        self.assertFalse(checks.traits(source, runtime)["consistent"])

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


if __name__ == "__main__":
    unittest.main()

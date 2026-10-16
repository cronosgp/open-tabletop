import importlib.util
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
spec = importlib.util.spec_from_file_location("starter", Path(__file__).parents[1] / "tools/import_starter_factions.py")
starter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(starter)


class StarterTests(unittest.TestCase):
    def test_profile_links_geometry_and_identity(self):
        record = {"id": "test", "name": "Test", "profiles": [{"M": 5, "T": 4, "W": 1, "Sv": 4}],
                  "base_size_mm": {"shape": "round", "diameter": 32}, "model_count": {"min": 10, "max": 20},
                  "weapon_ids": ["test-gun", "missing"], "ability_ids": ["test-ability"],
                  "game_version": {"edition": "11th", "dataslate": "launch"}}
        unit = starter.normalize_unit(record, {"test-gun": {"id": "test-gun"}},
                                      [{"ability_id": "test-ability", "effect": {"type": "test"}}], "necrons")
        self.assertEqual(unit["id"], "40kdc:11e:necrons:test")
        self.assertAlmostEqual(unit["base"]["radius_inches"], 32 / 50.8)
        self.assertEqual(unit["composition"], {"min": 10, "max": 20})
        self.assertEqual(len(unit["source_weapon_definitions"]), 1)
        self.assertEqual(len(unit["source_ability_definitions"]), 1)
        self.assertIn("Unresolved weapon: missing", unit["warnings"])
        self.assertFalse(unit["playable"])

    def test_geometry_not_invented(self):
        unit = starter.normalize_unit({"id": "x", "name": "X", "profiles": [{}]}, {}, [], "necrons")
        self.assertIsNone(unit["base"])


if __name__ == "__main__":
    unittest.main()

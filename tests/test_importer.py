import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("importer", Path(__file__).parents[1] / "tools/import_openhammer.py")
importer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(importer)


class ImportTests(unittest.TestCase):
    def record(self):
        return {"id": "sample", "name": "Original test unit", "stats": {"M": '6"', "T": "4", "SV": "3+", "W": "2", "LD": "6+", "OC": "1"},
                "abilities": [{"name": "Test ability", "description": "This prose must not be copied"}]}

    def test_normalization_and_missing_geometry(self):
        unit = importer.normalize(self.record(), "11e")
        self.assertEqual(unit["stats"]["movement_inches"], 6)
        self.assertEqual(unit["stats"]["save_target"], 3)
        self.assertFalse(unit["playable"])
        self.assertIsNone(unit["base"])
        self.assertIn("Test ability", unit["unsupported_rules"])
        self.assertNotIn("This prose", json.dumps(unit))

    def test_unknown_stat_is_not_guessed(self):
        record = self.record()
        record["stats"]["M"] = "D6+2"
        unit = importer.normalize(record, "11e")
        self.assertIsNone(unit["stats"]["movement_inches"])
        self.assertIn("Unresolved stat: M", unit["warnings"])

    def test_invalid_composition_is_reported(self):
        record = self.record()
        record["composition"] = {"min_models": 4, "max_models": 2}
        unit = importer.normalize(record, "11e")
        self.assertTrue(any("Invalid source composition" in warning for warning in unit["warnings"]))

    def test_snapshot_integrity_and_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = importer.write_pack([self.record()], directory, "11e", "test-fixture")
            content = (Path(directory) / "units.json").read_bytes()
            self.assertEqual(manifest["units_sha256"], importer.hashlib.sha256(content).hexdigest())
            with self.assertRaises(ValueError):
                importer.write_pack([self.record()], directory, "11e", "test-fixture")

    def test_reject_duplicate_and_empty(self):
        with tempfile.TemporaryDirectory() as directory:
            for records in [[], [self.record(), self.record()]]:
                with self.assertRaises(ValueError):
                    importer.write_pack(records, directory, "11e", "test")


if __name__ == "__main__":
    unittest.main()

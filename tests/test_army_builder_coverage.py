"""Guard source-review acceptance against mixed or stale provenance."""
import copy
import csv
import hashlib
import json
from pathlib import Path
import sys
import subprocess
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
from render_army_builder_coverage import review_matches, schema_review_matches
from audit_army_builder_equipment_reviews import audit
from review_army_builder_equipment_catalog import classify


class EquipmentReviewTests(unittest.TestCase):
    def setUp(self):
        self.record = {"identity": "fixture", "source_book_id": "book", "source_datasheet_id": "sheet",
                       "source_digest": "runtime", "saved_fields": [],
                       "source_snapshot_id": "old", "source_manifest_sha256": "old-hash",
                       "source_verified_against_snapshot_id": "new",
                       "source_verified_against_manifest_sha256": "new-hash",
                       "source_verified_against_slice_manifest_sha256": "slice-hash"}
        self.review = {"identity": "fixture", "classification": "fixed_equipment_no_options",
                       "review_method": "fixed_equipment_continuity",
                       "source_book_id": "book", "source_datasheet_id": "sheet", "source_digest": "runtime",
                       "source_snapshot_id": "new", "source_manifest_sha256": "new-hash",
                       "source_review_basis": "verified_against"}

    def test_explicit_basis_keeps_extraction_and_verification_distinct(self):
        self.assertTrue(review_matches(self.record, self.review))
        original = dict(self.review, source_snapshot_id="old", source_manifest_sha256="old-hash")
        original.pop("source_review_basis")
        self.assertTrue(review_matches(self.record, original))
        self.assertFalse(review_matches(self.record, dict(self.review, source_manifest_sha256="old-hash")))
        self.assertFalse(review_matches(self.record, dict(self.review, source_review_basis="extraction")))
        self.assertFalse(review_matches(self.record, dict(self.review, source_review_basis="unknown")))

    def test_stale_identity_digest_and_missing_verification_fail_closed(self):
        for field in ("source_book_id", "source_datasheet_id", "source_digest",
                      "source_verified_against_snapshot_id", "source_verified_against_manifest_sha256",
                      "source_verified_against_slice_manifest_sha256"):
            with self.subTest(field=field):
                changed = dict(self.record, **{field: ""})
                self.assertFalse(review_matches(changed, self.review))

    def test_source_classification_separates_fixed_equipment_from_unimplemented_options(self):
        source = {"sheets": {"sheet": {"source_id": "book", "loadout": "Fixture weapon"}},
                  "books": {"book": {"id": "book", "edition": "11", "type": "App"}},
                  "options": {}, "metadata": {"export_updated_at": "fixture-revision"}}
        sources = {("new", "new-hash"): source}
        self.assertEqual(classify(self.record, sources, "2026-11-14")["classification"], "fixed_equipment_no_options")
        source["options"]["sheet"] = [{"description": "Fixture replacement"}]
        self.assertEqual(classify(self.record, sources, "2026-11-14")["classification"], "equipment_options_present")
        composition = dict(self.record, source_option_kinds=["size_scaled_wargear_count"])
        source["options"]["sheet"] = [{"description": "For every 3 models, add one Plasmacyte."}]
        reviewed_composition = classify(composition, sources, "2026-11-15")
        self.assertEqual(reviewed_composition["classification"], "fixed_equipment_no_options")
        self.assertIn("model-composition", reviewed_composition["summary"])
        source["options"]["sheet"].append({"description": "Replace the default gun."})
        self.assertEqual(classify(composition, sources, "2026-11-15")["classification"], "equipment_options_present")
        source["sheets"]["sheet"]["loadout"] = ""
        with self.assertRaises(ValueError):
            classify(self.record, sources, "2026-11-14")
        with self.assertRaises(ValueError):
            classify(self.record, {}, "2026-11-14")

    def test_schema_review_requires_explicit_source_audit_and_exact_fields(self):
        record = dict(self.record, saved_fields=["pistol", "extra_weapon"])
        review = dict(self.review, classification="saved_equipment_options_reviewed",
                      review_method="saved_equipment_source_audit", schema_fields="extra_weapon;pistol",
                      evidence="fixture-source-audit.md")
        self.assertTrue(schema_review_matches(record, review))
        for field, value in (("schema_fields", "pistol"), ("schema_fields", "pistol;extra_weapon;unknown"),
                             ("review_method", "export_equipment_classification"), ("evidence", ""),
                             ("source_digest", "stale")):
            with self.subTest(field=field, value=value):
                self.assertFalse(schema_review_matches(record, dict(review, **{field: value})))
        self.assertFalse(schema_review_matches(dict(record, saved_fields=[]), review))

    def test_renderer_retains_a_stale_review_when_schema_fields_change_or_disappear(self):
        for saved_fields, expected_status in ((["pistol"], "saved_schema_source_reviewed"),
                                               (["pistol", "new_option"], "saved_schema_review_stale"),
                                               ([], "saved_schema_review_stale")):
            with self.subTest(saved_fields=saved_fields), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                record = dict(self.record, saved_fields=saved_fields, faction="Space Marines")
                review = dict(self.review, classification="saved_equipment_options_reviewed",
                              review_method="saved_equipment_source_audit", schema_fields="pistol",
                              evidence="fixture-source-audit.md")
                (root / "input.json").write_text(json.dumps({"records": [record], "excluded": []}), encoding="utf-8")
                with (root / "reviews.tsv").open("w", encoding="utf-8", newline="") as stream:
                    writer = csv.DictWriter(stream, fieldnames=list(review), delimiter="\t")
                    writer.writeheader()
                    writer.writerow(review)
                result = subprocess.run([sys.executable, str(Path(__file__).parents[1] / "tools/render_army_builder_coverage.py"),
                                         "--input", str(root / "input.json"), "--source-review", str(root / "reviews.tsv"),
                                         "--output", str(root / "output")], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                with (root / "output/army-builder-coverage.tsv").open(encoding="utf-8", newline="") as stream:
                    self.assertEqual(next(csv.DictReader(stream, delimiter="\t"))["status"], expected_status)

    def fixture(self, root, *, loadout="Fixture weapon", option=False, edition="11"):
        root.mkdir()
        tables = {
            "Source.csv": [{"id": "book", "name": "Fixture", "type": "App", "edition": edition}],
            "Datasheets.csv": [{"id": "sheet", "source_id": "book", "loadout": loadout,
                                "faction_id": "fixture", "legend": "false"}],
            "Datasheets_options.csv": [{"datasheet_id": "sheet"}] if option else [],
        }
        files = []
        for name, rows in tables.items():
            with (root / name).open("w", encoding="utf-8", newline="") as target:
                writer = csv.DictWriter(target, fieldnames=list(rows[0]) if rows else ["datasheet_id"], delimiter="|")
                writer.writeheader()
                writer.writerows(rows)
            files.append({"filename": name, "sha256": hashlib.sha256((root / name).read_bytes()).hexdigest()})
        manifest = {"edition": "11e", "snapshot_id": root.name, "files": files,
                    "source_page": "https://wahapedia.ru/wh40k11ed/the-rules/data-export/"}
        (root / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
        return hashlib.sha256((root / "manifest.json").read_bytes()).hexdigest()

    def test_source_continuity_rejects_changed_loadout_options_edition_and_corrupt_bytes(self):
        for case in ("valid", "loadout", "options", "edition", "corrupt"):
            with self.subTest(case=case), tempfile.TemporaryDirectory() as temp:
                old, new = Path(temp) / "old", Path(temp) / "new"
                self.fixture(old)
                digest = self.fixture(new, loadout="Changed" if case == "loadout" else "Fixture weapon",
                                      option=case == "options", edition="10" if case == "edition" else "11")
                record, review = copy.deepcopy(self.record), copy.deepcopy(self.review)
                record["source_verified_against_manifest_sha256"] = digest
                review["source_manifest_sha256"] = digest
                if case == "corrupt":
                    (new / "Datasheets_options.csv").write_text("corrupt", encoding="utf-8")
                if case == "valid":
                    self.assertEqual(len(audit({"records": [record]}, [review], old, new)["checked"]), 1)
                else:
                    with self.assertRaises(ValueError):
                        audit({"records": [record]}, [review], old, new)


if __name__ == "__main__":
    unittest.main()

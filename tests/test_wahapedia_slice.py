import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
import import_wahapedia as w
import slice_wahapedia as slicer
import compare_wahapedia_marines as comparator
from test_wahapedia_import import fixture, blob


def capture_fixture(directory, tables):
    source = Path(directory) / "input"
    source.mkdir()
    for name, rows in tables.items():
        (source / (name + ".csv")).write_bytes(blob(name, rows))
    output = Path(directory) / "snapshot"
    w.capture(output, source)
    return output


class WahapediaSliceTests(unittest.TestCase):
    def test_unrelated_global_error_does_not_block_closed_slice(self):
        tables = fixture()
        unrelated = copy.deepcopy(tables["Datasheets"][0])
        unrelated.update(id="example", source_id="", name="Unrelated placeholder")
        tables["Datasheets"].append(unrelated)
        with tempfile.TemporaryDirectory() as directory:
            parent = capture_fixture(directory, tables)
            manifest = slicer.extract(parent, Path(directory) / "slice", "000001")
            self.assertTrue(manifest["structurally_valid"])
            self.assertEqual(len(manifest["parent_validation_errors"]), 1)
            self.assertEqual(manifest["subject_datasheet_ids"], ["000001"])
            self.assertFalse(manifest["playable"])
            self.assertFalse(manifest["full_match_certified"])
            content = (Path(directory) / "slice/catalog.json").read_bytes()
            self.assertEqual(w.sha(content), manifest["catalog_sha256"])
            catalog = json.loads(content)
            self.assertEqual(len(catalog["units"]), 1)
            self.assertEqual(catalog["units"][0]["source_datasheet"]["id"], "000001")
            self.assertFalse(catalog["units"][0]["playable"])

    def test_broken_selected_dependency_is_preserved_and_blocks_slice(self):
        tables = fixture()
        tables["Datasheets_abilities"][0]["ability_id"] = "missing"
        with tempfile.TemporaryDirectory() as directory:
            parent = capture_fixture(directory, tables)
            output = Path(directory) / "slice"
            manifest = slicer.extract(parent, output, "000001")
            self.assertFalse(manifest["structurally_valid"])
            self.assertTrue(any("unknown ability_id=missing" in error for error in manifest["validation_errors"]))
            _, extracted, _ = w.load_snapshot(output)
            self.assertEqual(extracted["Datasheets_abilities"][0]["ability_id"], "missing")
            self.assertEqual(extracted["Abilities"], [])

    def test_external_leader_endpoint_is_identity_only(self):
        tables = fixture()
        external = copy.deepcopy(tables["Datasheets"][0])
        external.update(id="chapter-leader", source_id="chapter-book")
        tables["Datasheets"].append(external)
        book = copy.deepcopy(tables["Source"][0])
        book.update(id="chapter-book", name="Original chapter book")
        tables["Source"].append(book)
        tables["Datasheets_leader"][0]["leader_id"] = external["id"]
        # External effects must not be pulled in as playable subject content.
        extra_ability = copy.deepcopy(tables["Datasheets_abilities"][0])
        extra_ability.update(datasheet_id=external["id"], ability_id="missing-external-effect")
        tables["Datasheets_abilities"].append(extra_ability)
        selected, subject_book, subjects, support = slicer.select_tables(tables, "000001")
        self.assertEqual(subjects, ["000001"])
        self.assertEqual(support, ["chapter-leader"])
        self.assertEqual(len(selected["Datasheets"]), 2)
        self.assertEqual(len(selected["Datasheets_abilities"]), 1)
        self.assertFalse(w.validate(selected))
        catalog = slicer.build_catalog(selected, subject_book, subjects)
        self.assertEqual(len(catalog), 1)
        self.assertEqual(len(catalog[0]["abilities"]), 1)
        self.assertNotIn("chapter-leader", [u["source_datasheet"]["id"] for u in catalog])

    def test_wrong_edition_and_cross_book_request_are_rejected(self):
        tables = fixture()
        with self.assertRaisesRegex(ValueError, "another source book"):
            slicer.select_tables(tables, "000001", ["not-in-source"])
        tables["Source"][0]["edition"] = "10"
        with self.assertRaisesRegex(ValueError, "e11 source ID"):
            slicer.select_tables(tables, "000001")

    def test_repeatable_slice_and_parent_hash_validation(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = capture_fixture(directory, fixture())
            first = slicer.extract(parent, Path(directory) / "one", "000001")
            second = slicer.extract(parent, Path(directory) / "two", "000001")
            self.assertEqual(first, second)
            (Path(directory) / "two/catalog.json").write_bytes(b"changed")
            with self.assertRaisesRegex(ValueError, "Changed snapshot catalog"):
                w.load_snapshot(Path(directory) / "two")
            with self.assertRaisesRegex(ValueError, "already exists"):
                slicer.extract(parent, Path(directory) / "one", "000001")
            (parent / "raw/Datasheets.csv").write_bytes(b"changed")
            with self.assertRaisesRegex(ValueError, "Changed snapshot"):
                slicer.extract(parent, Path(directory) / "three", "000001")

    def test_conditional_keyword_context_is_revision_scoped_and_not_a_runtime_grant(self):
        context = json.loads(comparator.KEYWORD_CONTEXT.read_text(encoding="utf-8"))
        sheet = {"id": "000001183", "source_id": "000000139"}
        profile = {"keywords": ["INFANTRY", "TERMINATOR SQUAD"]}
        rows = [{"keyword": k, "model": "", "is_faction_keyword": "false"} for k in ["INFANTRY", "DEATHWING"]]
        shared = comparator.review_keywords(rows, profile, sheet, "terminator-squad", context["export_updated_at"], "shared", context)
        self.assertTrue(shared["scope_consistent"])
        self.assertEqual(shared["raw_source_only_keywords"], ["DEATHWING"])
        self.assertEqual(shared["internal_identity_tags"], ["TERMINATOR SQUAD"])
        self.assertEqual(len(shared["excluded_chapter_keywords"]), 1)
        chapter = comparator.review_keywords(rows, profile, sheet, "terminator-squad", context["export_updated_at"], "dark-angels", context)
        self.assertFalse(chapter["scope_consistent"])
        self.assertEqual(chapter["missing_from_runtime"], ["DEATHWING"])
        stale = comparator.review_keywords(rows, profile, sheet, "terminator-squad", "new revision", "shared", context)
        self.assertFalse(stale["scope_consistent"])
        self.assertTrue(stale["context_issues"])
        self.assertNotIn("DEATHWING", profile["keywords"])


if __name__ == "__main__":
    unittest.main()

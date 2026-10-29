import copy
from contextlib import redirect_stdout
import csv
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import sys

spec = importlib.util.spec_from_file_location("wahapedia", Path(__file__).parents[1] / "tools/import_wahapedia.py")
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)
sys.path.insert(0, str(Path(__file__).parents[1] / "tools"))
import compare_wahapedia_marines as comparator
import wahapedia_fixed_checks as fixed_checks


class FixedDataChecks(unittest.TestCase):
    def test_ranged_and_melee_profiles_can_share_one_physical_weapon(self):
        profile = {
            "ranged": [{"id": "hand-ranged", "physical_weapon_id": "hand", "profiles": {"standard": {"name": "Hand of Dominion"}}}],
            "melee": [{"id": "sword", "profiles": {"standard": {"name": "Emperor's Sword"}}},
                      {"id": "hand-melee", "physical_weapon_id": "hand", "profiles": {"standard": {"name": "Hand of Dominion"}}}],
        }
        result = fixed_checks.loadout("This model is equipped with: 1 Emperor's Sword; 1 Hand of Dominion.", profile)
        self.assertTrue(result["consistent"])
        self.assertEqual(result["runtime_per_model"], {"handofdominion": 1, "emperorssword": 1})

    def test_chapter_keyword_projection_is_compared_in_requested_context(self):
        rows = [{"keyword": "Deathwing", "model": "", "is_faction_keyword": "false"},
                {"keyword": "Infantry", "model": "", "is_faction_keyword": "false"}]
        profile = {"keywords": ["INFANTRY", "DEATHWING"]}
        sheet = {"id": "000001", "source_id": "000000139"}
        context = {"conditional_keywords": [{"datasheet_id": "000001", "source_book_id": "000000139",
                                             "keyword": "DEATHWING", "requires_chapter": "dark-angels"}],
                   "internal_identity_tags": []}
        shared = comparator.review_keywords(rows, profile, sheet, "fixture", [], "shared", context)
        dark_angels = comparator.review_keywords(rows, profile, sheet, "fixture", [], "dark-angels", context)
        self.assertTrue(shared["scope_consistent"])
        self.assertEqual(len(shared["excluded_chapter_keywords"]), 1)
        self.assertTrue(dark_angels["scope_consistent"])
        self.assertEqual(len(dark_angels["applied_chapter_keywords"]), 1)

    def test_runtime_internal_mobile_tag_is_not_misreported_as_a_source_keyword(self):
        rows = [{"keyword": "Adeptus Astartes", "model": "", "is_faction_keyword": "true"},
                {"keyword": "Epic Hero", "model": "", "is_faction_keyword": "false"}]
        profile = {"keywords": ["ADEPTUS ASTARTES", "EPIC HERO", "MOBILE"]}
        sheet = {"id": "000002291", "source_id": "000000023"}
        context = {"conditional_keywords": [], "internal_identity_tags": [
            {"runtime_identity": "sammael", "tag": "MOBILE"}]}
        review = comparator.review_keywords(rows, profile, sheet, "sammael", [], "shared", context)
        self.assertTrue(review["scope_consistent"])
        self.assertEqual(review["internal_identity_tags"], ["MOBILE"])

    def test_model_characteristics_use_per_model_profiles_and_conditional_invulnerability(self):
        tables = fixture()
        tables["Source"][0].update(id="000000139", name="Space Marines", edition="11")
        tables["Datasheets"][0].update(source_id="000000139", name="Mapped Test Unit",
                                       link=w.BASE + "factions/space-marines/Unexpected-URL")
        first = tables["Datasheets_models"][0]
        first.update(name="Model One", M='6"', T="4", Sv="3+", inv_sv="-", W="2", Ld="6+", OC="1")
        second = copy.deepcopy(first)
        second.update(line="2", name="Model Two", M='6"', T="5", Sv="3+", inv_sv="4", inv_sv_descr="Melee attacks only", W="2", Ld="6+", OC="-")
        tables["Datasheets_models"].append(second)
        base_stats = {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2,
                      "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
        second_stats = {**base_stats, "toughness": 5, "objective_control": 0, "melee_invulnerable_target": 4}
        profile = {"stats": base_stats,
                   "model_loadouts": [{"source_model_name": "Model Two", "stats": second_stats},
                                      {"source_model_name": "Model One", "stats": base_stats}],
                   "keywords": ["INFANTRY"], "ranged": [], "melee": []}
        runtime = {"id": "model-test", "digest": "test", "profiles": {"mapped-test": profile}}
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input"
            source.mkdir()
            for name, rows in tables.items():
                (source / (name + ".csv")).write_bytes(blob(name, rows))
            snapshot = Path(directory) / "snapshot"
            manifest = w.capture(snapshot, source)
            identity_map = {"source_book_id": "000000139",
                            "datasheets_csv_sha256": manifest["files"]["Datasheets"]["sha256"],
                            "identity_mappings": [{"identity": "mapped-test", "source_datasheet_id": "000001"}]}
            context = {"id": "fixture-context", "export_updated_at": manifest["export_updated_at"],
                       "conditional_keywords": [], "internal_identity_tags": []}
            report = comparator.compare(snapshot, runtime, keyword_context=context, source_identity_map=identity_map)
        model_differences = [row for row in report["profiles"][0]["differences"] if row.get("field", "").startswith("model.")]
        self.assertEqual(model_differences, [])

    def test_model_characteristics_match_source_types_to_expanded_runtime_roles(self):
        common = {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2,
                  "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
        neophyte = {**common, "toughness": 4, "save_target": 4}
        loadouts = [
            {"source_model_name": "Sword Brother", "stats": common},
            {"source_model_name": "Neophyte", "stats": neophyte},
            {"source_model_name": "Neophyte", "stats": neophyte},
            {"source_model_name": "Initiate", "stats": common},
        ]
        source_neophyte = {"name": "Neophyte", "M": '6"', "T": "4", "Sv": "4+", "W": "2",
                           "Ld": "6+", "OC": "2", "inv_sv": "-", "inv_sv_descr": ""}
        self.assertEqual(comparator._best_model_row_match(source_neophyte, loadouts, common), [])

        # A source type may have a different display name while its characteristic line
        # still matches a runtime role among several per-model option records.
        source_initiate = {**source_neophyte, "name": "Black Templar Initiate", "T": "5", "Sv": "3+"}
        self.assertEqual(comparator._best_model_row_match(source_initiate, loadouts, common), [])

    def test_torrent_source_ballistic_skill_is_not_compared(self):
        tables = fixture()
        tables["Source"][0].update(id="000000139", name="Space Marines", edition="11")
        tables["Datasheets"][0].update(source_id="000000139", name="Mapped Test Unit",
                                       link=w.BASE + "factions/space-marines/Unexpected-URL")
        tables["Datasheets_models"][0].update(name="Model", M='6"', T="4", Sv="3+", inv_sv="-",
                                              W="2", Ld="6+", OC="1")
        tables["Datasheets_wargear"][0].update(name="Heavy Flamer", type="Ranged", range='12"', A="3",
                                               BS_WS="7+", S="5", AP="-1", D="1", description="Torrent")
        stats = {"range_inches": 12, "attacks": 3, "skill": 0, "strength": 5, "ap": -1,
                 "damage": 1, "keywords": {"torrent": True}}
        profile_stats = {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2,
                         "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}
        profile = {"stats": profile_stats, "keywords": ["INFANTRY"],
                   "ranged": [{"id": "heavy-flamer", "profiles": {"standard": {"name": "Heavy Flamer", **stats}}}],
                   "melee": []}
        runtime = {"id": "torrent-test", "digest": "test", "profiles": {"mapped-test": profile}}
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input"
            source.mkdir()
            for name, rows in tables.items():
                (source / (name + ".csv")).write_bytes(blob(name, rows))
            snapshot = Path(directory) / "snapshot"
            manifest = w.capture(snapshot, source)
            identity_map = {"source_book_id": "000000139",
                            "datasheets_csv_sha256": manifest["files"]["Datasheets"]["sha256"],
                            "identity_mappings": [{"identity": "mapped-test", "source_datasheet_id": "000001"}]}
            context = {"id": "fixture-context", "export_updated_at": manifest["export_updated_at"],
                       "conditional_keywords": [], "internal_identity_tags": []}
            report = comparator.compare(snapshot, runtime, keyword_context=context, source_identity_map=identity_map)
        differences = report["profiles"][0]["differences"]
        self.assertNotIn("weapon.heavy-flamer.standard.skill", [row.get("field") for row in differences])


def fixture():
    tables = {}
    for name, header in w.HEADERS.items():
        row = dict.fromkeys(header.split(), "")
        for column in row:
            if column == "id" or column in w.REFERENCES:
                row[column] = "000001"
            elif column in ["line", "line_in_wargear"]:
                row[column] = "1"
        for column in w.BOOLS.get(name, []):
            row[column] = "false"
        tables[name] = [row]
    tables["Factions"][0].update(name="Space Marines", link=w.BASE + "factions/space-marines")
    tables["Source"][0].update(name="Original test book", edition="11", type="Test")
    tables["Datasheets"][0].update(name="Original test unit", link=w.BASE + "factions/space-marines/Original-Test-Unit")
    tables["Last_update"][0]["last_update"] = "2026-10-16 21:03:46"
    tables["Datasheets_keywords"][0]["keyword"] = "INFANTRY"
    tables["Detachments_chapter_dp"][0]["keyword"] = "TEST CHAPTER"
    return tables


def blob(name, rows):
    stream = io.StringIO(newline="")
    writer = csv.writer(stream, delimiter="|")
    header = w.HEADERS[name].split()
    writer.writerow(header + [""])
    writer.writerows([[row[k] for k in header] + [""] for row in rows])
    return stream.getvalue().encode("utf-8-sig")


class WahapediaImportTests(unittest.TestCase):
    def test_parser_preserves_ids_and_html_with_quoted_pipes(self):
        tables = fixture()
        tables["Abilities"][0]["description"] = '<b>Original | test</b>\nsecond line'
        rows = w.parse("Abilities", blob("Abilities", tables["Abilities"]))
        self.assertEqual(rows[0]["id"], "000001")
        self.assertEqual(rows, tables["Abilities"])
        self.assertFalse(w.validate(tables))

    def test_reject_missing_headers_bad_shape_and_empty(self):
        for data in [b"id|name|\n", b"id|name|link|\n1|two|\n", b"<html>Not CSV</html>"]:
            with self.subTest(data=data), self.assertRaises(ValueError):
                w.parse("Factions", data)

    def test_publisher_unquoted_newline_preserves_text_and_reports_repair(self):
        data = b'id|name|link|\n00001|Original\ncontinued|https://example.test|\n'
        notes = []
        row = w.parse("Factions", data, notes)[0]
        self.assertEqual(row["name"], "Original\ncontinued")
        self.assertEqual(row["id"], "00001")
        self.assertEqual(len(notes), 1)
        with self.assertRaises(ValueError):
            w.parse("Factions", b'id|name|link|\n00001|unfinished')

    def test_reject_duplicate_identity_line_and_dangling_reference(self):
        tables = fixture()
        tables["Factions"].append(copy.deepcopy(tables["Factions"][0]))
        extra = copy.deepcopy(tables["Datasheets_models"][0])
        extra["T"] = "99"
        tables["Datasheets_models"].append(extra)
        tables["Datasheets_leader"][0]["attached_id"] = "missing"
        errors = w.validate(tables)
        self.assertTrue(any("duplicate primary" in e for e in errors))
        self.assertTrue(any("duplicate relation" in e for e in errors))
        self.assertTrue(any("unknown attached_id" in e for e in errors))

    def test_edition_boundary_and_no_automatic_support(self):
        tables = fixture()
        self.assertTrue(w.marine_index(tables)[0]["edition_11_candidate"])
        tables["Source"][0]["edition"] = "10"
        unit = w.marine_index(tables)[0]
        self.assertFalse(unit["edition_11_candidate"])
        self.assertFalse(unit["playable"])
        self.assertEqual(unit["book"]["edition"], "10")

    def test_shared_ability_ids_keep_faction_scope_and_detect_conflicts(self):
        tables = fixture()
        faction = copy.deepcopy(tables["Factions"][0])
        faction["id"] = "OTHER"
        tables["Factions"].append(faction)
        alias = copy.deepcopy(tables["Abilities"][0])
        alias["faction_id"] = "OTHER"
        tables["Abilities"].append(alias)
        self.assertFalse(w.validate(tables))
        alias["description"] = "Conflicting effect"
        self.assertTrue(any("conflicting definition" in e for e in w.validate(tables)))

    def test_comparison_detects_model_delta_and_tampered_raw_file(self):
        tables = fixture()
        tables["Datasheets"][0]["link"] = w.BASE + "factions/space-marines/Intercessor-Squad"
        tables["Datasheets_models"][0].update(name="Original model", M='6"', T="5", Sv="3+", W="2", Ld="6+", OC="2", inv_sv="-")
        stats = {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}
        profile = {"stats": stats, "keywords": ["INFANTRY"], "ranged": [], "melee": []}
        runtime = {"id": "test", "digest": "test", "profiles": {name: profile for name in ["intercessor-squad", "assault-intercessor-squad", "heavy-intercessor-squad", "terminator-squad", "captain", "lieutenant"]}}
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input"
            source.mkdir()
            for name, rows in tables.items():
                (source / (name + ".csv")).write_bytes(blob(name, rows))
            output = Path(directory) / "out"
            w.capture(output, source)
            report = comparator.compare(output, runtime)
            self.assertEqual({p["identity"] for p in report["profiles"]}, set(runtime["profiles"]))
            intercessor = next(p for p in report["profiles"] if p["identity"] == "intercessor-squad")
            model_differences = [row for row in intercessor["differences"] if row.get("field", "").startswith("model.")]
            self.assertEqual(len(model_differences), 1)
            self.assertEqual(model_differences[0]["field"], "model.Original model.toughness")
            self.assertFalse(report["full_match_certified"])
            runtime_path = Path(directory) / "runtime.json"
            runtime_path.write_text(json.dumps(runtime), encoding="utf-8")
            failed_report = Path(directory) / "failed-audit.json"
            args = ["compare", "--snapshot", str(output), "--runtime-profiles", str(runtime_path), "--output", str(failed_report), "--require-fixed-data"]
            with patch.object(sys, "argv", args), redirect_stdout(io.StringIO()):
                self.assertEqual(comparator.main(), 1)
            self.assertTrue(failed_report.exists())
            (output / "raw/Datasheets.csv").write_bytes(b"tampered")
            with self.assertRaisesRegex(ValueError, "Changed snapshot"):
                comparator.compare(output, runtime)
            with self.assertRaisesRegex(ValueError, "Changed offline snapshot"):
                w.capture(Path(directory) / "second", output / "raw")

    def test_comparison_uses_hash_bound_identity_map_and_faction_keywords(self):
        tables = fixture()
        tables["Source"][0].update(id="000000139", name="Space Marines", edition="11")
        tables["Datasheets"][0].update(source_id="000000139", name="Mapped Test Unit",
                                       link=w.BASE + "factions/space-marines/Unexpected-URL")
        tables["Datasheets_models"][0].update(name="Test Model", M='6"', T="4", Sv="3+", W="2", Ld="6+", OC="2", inv_sv="-")
        faction_keyword = copy.deepcopy(tables["Datasheets_keywords"][0])
        faction_keyword.update(keyword="ADEPTUS ASTARTES", is_faction_keyword="true")
        tables["Datasheets_keywords"].append(faction_keyword)
        profile = {"stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2,
                              "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0},
                   "keywords": ["INFANTRY", "ADEPTUS ASTARTES"], "ranged": [], "melee": []}
        runtime = {"id": "mapped-test", "digest": "test", "profiles": {"override-fixture": profile}}
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input"
            source.mkdir()
            for name, rows in tables.items():
                (source / (name + ".csv")).write_bytes(blob(name, rows))
            snapshot = Path(directory) / "snapshot"
            manifest = w.capture(snapshot, source)
            identity_map = {"source_book_id": "000000139",
                            "datasheets_csv_sha256": manifest["files"]["Datasheets"]["sha256"],
                            "identity_mappings": [{"identity": "override-fixture", "source_datasheet_id": "000001"}]}
            context = {"id": "fixture-context", "export_updated_at": "older retrieval marker",
                       "source_files_sha256": {name + ".csv": manifest["files"][name]["sha256"]
                                               for name in ["Datasheets", "Datasheets_keywords", "Source"]},
                       "conditional_keywords": [], "internal_identity_tags": []}
            report = comparator.compare(snapshot, runtime, keyword_context=context, source_identity_map=identity_map)
            profile_report = report["profiles"][0]
            self.assertTrue(report["identity_mapping_verified"])
            self.assertTrue(report["keyword_context_source_verified"])
            self.assertEqual(profile_report["source_id"], "000001")
            self.assertEqual(profile_report["source_match_method"], "verified_identity_map")
            self.assertEqual(profile_report["keyword_review"]["missing_faction_keywords"], [])
            self.assertEqual(profile_report["keyword_review"]["unresolved_runtime_extras"], [])
            identity_map["datasheets_csv_sha256"] = "0" * 64
            with self.assertRaisesRegex(ValueError, "does not match"):
                comparator.compare(snapshot, runtime, keyword_context=context, source_identity_map=identity_map)

    def test_boolean_and_missing_required_reference(self):
        tables = fixture()
        tables["Datasheets"][0]["virtual"] = "yes"
        tables["Datasheets_leader"][0]["leader_id"] = ""
        self.assertTrue(any("invalid boolean" in e for e in w.validate(tables)))
        self.assertTrue(any("missing leader_id" in e for e in w.validate(tables)))

    def test_offline_capture_hashes_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "input"
            source.mkdir()
            for name, rows in fixture().items():
                (source / (name + ".csv")).write_bytes(blob(name, rows))
            output = Path(directory) / "output"
            manifest = w.capture(output, source)
            self.assertTrue(manifest["structurally_valid"])
            self.assertFalse(manifest["live_timestamp_bracket_checked"])
            self.assertEqual(manifest["export_updated_at"], "2026-10-16T21:03:46+03:00")
            self.assertEqual(len(manifest["files"]), 22)
            self.assertEqual(manifest["files"]["Datasheets"]["sha256"], w.sha((output / "raw/Datasheets.csv").read_bytes()))
            self.assertFalse(json.loads((output / "space-marines-index.json").read_text())[0]["playable"])
            with self.assertRaises(ValueError):
                w.capture(output, source)

    def test_live_update_during_download_does_not_publish(self):
        tables = fixture()
        calls = []
        def fetch(name):
            calls.append(name)
            rows = copy.deepcopy(tables[name])
            if name == "Last_update" and calls.count(name) == 2:
                rows[0]["last_update"] = "2026-10-17 00:00:00"
            data = blob(name, rows)
            return data, {"sha256": w.sha(data)}
        with tempfile.TemporaryDirectory() as directory, patch.object(w, "fetch", fetch):
            output = Path(directory) / "out"
            with self.assertRaisesRegex(ValueError, "changed during"):
                w.capture(output)
            self.assertFalse((output / "manifest.json").exists())
            self.assertFalse((output / "space-marines-index.json").exists())
            self.assertTrue((output / "raw/Datasheets.csv").exists())


if __name__ == "__main__":
    unittest.main()

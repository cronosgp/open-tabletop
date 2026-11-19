import csv
import json
from pathlib import Path
import sys
import tempfile
import unittest
import sqlite3
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from build_forceorg_model_weapon_catalog import enrich_variants, EXPECTED_RULES_MANIFEST, EXPECTED_RULES_SNAPSHOT
from forceorg_model_database import classify, classify_source_object, object_inventory, search_objects, visual_weapons, source_weapon_aliases, abbreviated_label_weapon, model_role_links, relation_in_scope, literal_profile_index, literal_profile_matches, occurrence_inventory, SCHEMA, search, coverage
from build_forceorg_datasheet_review import build_wargear_pattern


class ModelCatalogTests(unittest.TestCase):
    def catalog_fixture(self, path):
        db = sqlite3.connect(path)
        db.executescript(SCHEMA)
        for index in range(1, 5):
            identity = f"{index:09}"
            db.execute("INSERT INTO datasheets VALUES(?,?,?,?,?,?,?,?)", (identity, f"Example {index}", "Example faction", "Infantry", "Synthetic book", "fixture", 0, "{}"))
            db.execute("INSERT INTO runtime_profiles VALUES(?,?)", (f"synthetic:{index}", identity))
        db.execute("INSERT INTO variants VALUES(?,?,?,?,?,?,?,?,?,?,?,?)", ("visual", "source", "variant", "fingerprint", "Example Body", "example body", "miniature", "synthetic", "", "Example group", "CustomMesh", "{}"))
        db.execute("INSERT INTO links VALUES(?,?,1,'','label_association')", ("visual", "000000001"))
        db.execute("INSERT INTO links VALUES(?,?,0.2,'','candidate')", ("visual", "000000003"))
        db.execute("INSERT INTO fallback_links VALUES(?,?,?,?)", ("visual", "000000002", "synthetic-registry", "example body"))
        db.execute("INSERT INTO metadata VALUES('rules_snapshot_id','\"synthetic\"')")
        db.commit()
        db.close()

    def variants(self):
        return [{"save_sha256": "synthetic-save", "variant_key": "variant-one",
                 "representative_label": "Example - Plasma Pistol", "e11_definition_id": "synthetic:example",
                 "e11_equipment_signature": "plasma-pistol", "source_occurrences": "[]"}]

    def relations(self):
        return [{"forceorg_save_sha256": "synthetic-save", "variant_key": "variant-one",
                 "candidate_datasheet_id": identity, "candidate_datasheet_name": "Example",
                 "candidate_review_order": str(index), "candidate_lexical_score": "1.0",
                 "rules_snapshot_id": EXPECTED_RULES_SNAPSHOT, "rules_manifest_sha256": EXPECTED_RULES_MANIFEST}
                for index, identity in enumerate(["000000001", "000000002"], start=1)]

    def enriched(self, relations):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "relations.csv"
            with path.open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=list(relations[0]))
                writer.writeheader()
                writer.writerows(relations)
            return enrich_variants(self.variants(), path, "synthetic")

    def test_raw_inventory_cannot_silently_lose_all_links(self):
        with self.assertRaisesRegex(ValueError, "relations"):
            enrich_variants(self.variants(), None, "synthetic")

    def test_join_keeps_source_identity_and_reports_real_ties(self):
        row = self.enriched(self.relations())[0]
        self.assertEqual(row["candidate_datasheet_id"], "000000001")
        self.assertEqual(row["top_candidate_tie_count"], 2)
        self.assertEqual(row["existing_e11_definition_id"], "synthetic:example")
        self.assertEqual(row["existing_e11_equipment_signature"], "plasma-pistol")
        self.assertEqual(row["source_occurrences"], "[]")

    def test_join_rejects_other_snapshot(self):
        relations = self.relations()
        relations[0]["forceorg_save_sha256"] = "different-save"
        with self.assertRaises(ValueError):
            self.enriched(relations)

    def test_lexical_candidates_require_rules_provenance(self):
        relations = self.relations()
        relations[0]["rules_manifest_sha256"] = ""
        with self.assertRaisesRegex(ValueError, "provenance"):
            self.enriched(relations)

    def test_parts_accessories_and_mount_notes(self):
        for label, paths, category in [
            ("Kayvaan Shrike (without tactical wall)", [], "miniature"),
            ("Ruined Building", [], "terrain"),
            ("32mm base", [], "base"),
            ("170x109mm", [], "base"),
            ("Objective Token", [], "ignored"),
            ("Example / component 1", [{"tts_path": "ObjectStates/1/ChildObjects/0"}], "component"),
        ]:
            with self.subTest(label=label):
                result, _ = classify({"representative_label": label, "source_occurrences": json.dumps(paths)})
                self.assertEqual(result, category)

    def test_export_weapon_vocabulary_supplements_initial_abbreviations(self):
        pattern = build_wargear_pattern([{"wargear_names": ["Gauss Reaper", "Gauss Blaster", "Bolt Rifle", "Plasma Incinerator – Supercharge"]}])
        self.assertEqual(visual_weapons({"representative_label": "Necron Warrior - Gauss Reaper", "visual_weapon_hints": ""}, pattern), ["gauss-reaper"])
        self.assertEqual(visual_weapons({"representative_label": "Intercessor - Bolt Rifle + GL", "visual_weapon_hints": "bolt-rifle|grenade-launcher"}, pattern), ["bolt-rifle", "grenade-launcher"])
        historical = visual_weapons({"representative_label": "Intercessor - Auto Bolt Rifle", "visual_weapon_hints": "auto-bolt-rifle"}, pattern)
        self.assertIn("auto-bolt-rifle", historical)
        self.assertNotIn("bolt-rifle", historical)

    def test_mixed_model_roles_preserve_specificity_and_ambiguity(self):
        models = [{"name": "Chaplain Grimaldus"}, {"name": "Cenobyte Servitor"}]
        self.assertEqual(model_role_links("Cenobyte Servitor - Relic", models), ("label_model_role", ["Cenobyte Servitor"]))
        self.assertEqual(model_role_links("Grimaldus and Servitors", models), ("unresolved_model_role", []))
        self.assertEqual(model_role_links("Chaplain Grimaldus and Cenobyte Servitor", models)[0], "ambiguous_model_role")
        terminators = [{"name": "Terminator"}, {"name": "Terminator Sergeant"}]
        self.assertEqual(model_role_links("Terminator Sergeant - Storm Bolter", terminators), ("label_model_role", ["Terminator Sergeant"]))
        self.assertEqual(model_role_links("Unusual label", models, "cenobyte"), ("explicit_role", ["cenobyte"]))

    def test_source_faction_boolean_case_does_not_hide_valid_associations(self):
        for value in ["True", "true", " TRUE "]:
            self.assertTrue(relation_in_scope({"group_faction_scope": "Example faction", "candidate_matches_group_faction_scope": value}))
        for value in ["False", "false", "", "unresolved"]:
            self.assertFalse(relation_in_scope({"group_faction_scope": "Example faction", "candidate_matches_group_faction_scope": value}))
        relations = self.relations()
        for r in relations:
            r["group_faction_scope"] = "Example faction"
            r["candidate_matches_group_faction_scope"] = "True" if r["candidate_datasheet_id"] == "000000002" else "False"
        result = self.enriched(relations)[0]
        self.assertEqual(result["candidate_datasheet_id"], "000000002")
        self.assertEqual(result["top_candidate_tie_count"], 1)

    def test_reviewed_fallback_is_searchable_without_becoming_model_identity(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "models.sqlite"
            self.catalog_fixture(path)
            rows = search(SimpleNamespace(database=path, name="", category="miniature", datasheet="000000002", weapon="", model_role="", character=False, limit=20))
            self.assertEqual(len(rows), 1)
            links = {r["id"]: r for r in rows[0]["datasheets"]}
            self.assertEqual(links["000000001"]["status"], "label_association")
            self.assertEqual(links["000000002"]["status"], "reviewed_visual_fallback")
            self.assertIsNone(links["000000002"]["score"])
            self.assertEqual(links["000000003"]["status"], "candidate")

    def test_coverage_accounts_for_exact_proxy_candidate_and_absent_profiles(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "models.sqlite"
            self.catalog_fixture(path)
            report = coverage(SimpleNamespace(database=path, output=None))
            self.assertEqual(report["runtime_identities"], 4)
            self.assertEqual(report["status_counts"], {"label_associations": 1, "reviewed_visual_fallback_only": 1, "candidate_only": 1, "no_source_candidate": 1})

    def test_literal_names_allow_only_source_bounded_suffixes(self):
        profiles = [{"datasheet_id": "000000001", "datasheet_name": "Example Bunker", "faction_name": "Example faction",
                     "wargear_profiles": '["Example Heavy Bolter Array"]', "model_roles_and_base_sizes": '[{"name":"Bunker"}]',
                     "unit_composition": '["1-3 Example Bunker Emplacements"]'}]
        index = literal_profile_index(profiles)
        self.assertEqual(literal_profile_matches({"representative_label": "Example Bunker Heavy Bolter Array"}, index), ["000000001"])
        self.assertEqual(literal_profile_matches({"representative_label": "Example Bunker Unknown Cannon"}, index), [])
        self.assertEqual(literal_profile_matches({"representative_label": "Heavy Bolter Array"}, index), [])
        self.assertEqual(literal_profile_matches({"representative_label": "Example Bunker - Emplacement"}, index), ["000000001"])
        self.assertEqual(literal_profile_matches({"representative_label": "Example Bunker", "group_faction_scope": "Another faction"}, index), [])

    def test_detailed_occurrences_preserve_label_case_and_reject_other_sources(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "visuals.csv"
            row = {"save_sha256": "source", "tts_path": "ObjectStates/1", "guid": "abcdef", "asset_fingerprint": "fingerprint", "variant_label": "Example BODY"}
            with path.open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=list(row))
                writer.writeheader()
                writer.writerow(row)
            self.assertEqual(occurrence_inventory([path], {"source"})["source", "ObjectStates/1"]["variant_label"], "Example BODY")
            with self.assertRaises(ValueError):
                occurrence_inventory([path], {"another-source"})
            with self.assertRaises(ValueError):
                occurrence_inventory([path, path], {"source"})

    def test_weapon_aliases_are_unique_per_source_and_keep_legacy_terms_separate(self):
        self.assertEqual(source_weapon_aliases(["heavy-bolter"], ["Hammerfall Heavy Bolter Array"]), {"heavy-bolter": "hammerfall-heavy-bolter-array"})
        self.assertEqual(source_weapon_aliases(["heavy-bolter"], ["Twin Heavy Bolter", "Quad Heavy Bolter"]), {})
        self.assertEqual(source_weapon_aliases(["heavy-bolter"], ["Heavy Bolter", "Twin Heavy Bolter"]), {})
        self.assertEqual(source_weapon_aliases(["heavy-bolter"], ["Twin Heavy Bolter - Focused Fire", "Twin Heavy Bolter - Saturation"]), {"heavy-bolter": "twin-heavy-bolter"})
        self.assertEqual(source_weapon_aliases(["auto-bolt-rifle"], ["Bolt Rifle - Focused Fire"]), {})

    def test_abbreviated_weapon_requires_complete_model_prefix_and_unique_source_suffix(self):
        names = ["Necron Warriors"]
        weapons = ["Gauss flayer", "Gauss reaper", "Close combat weapon"]
        self.assertEqual(abbreviated_label_weapon("necron warrior flayer", names, weapons), ("gauss-flayer", "flayer"))
        self.assertEqual(abbreviated_label_weapon("Necron Warrior with Reaper", names, weapons), ("gauss-reaper", "reaper"))
        for label in ["Warrior reaper", "Necron Warrior", "Necron Warrior unknown reaper", "Necron Warrior reaper 1"]:
            self.assertIsNone(abbreviated_label_weapon(label, names, weapons))
        self.assertIsNone(abbreviated_label_weapon("Necron Warrior reaper", names, weapons + ["Heavy reaper"]))
        self.assertIsNone(abbreviated_label_weapon("Intercessor Auto Bolt Rifle", ["Intercessor"], ["Bolt Rifle"]))
        self.assertIsNone(abbreviated_label_weapon("Burning Chariot of Tzeentch", ["Burning Chariot"], ["Fire of Tzeentch"]))
        self.assertEqual(abbreviated_label_weapon("Example trooper incinerator", ["Example trooper"],
                         ["Plasma incinerator - Standard", "Plasma incinerator - Supercharge"]),
                         ("plasma-incinerator", "incinerator"))

    def test_search_exposes_abbreviated_weapon_evidence_on_its_own_link(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "models.sqlite"
            self.catalog_fixture(path)
            with sqlite3.connect(path) as db:
                db.execute("INSERT INTO weapons VALUES('visual','gauss-reaper')")
                db.execute("INSERT INTO weapon_label_resolutions VALUES('visual','000000001','gauss-reaper','reaper','unique_source_weapon_suffix_after_model_name')")
            db.close()
            rows = search(SimpleNamespace(database=path, name="", category="miniature", datasheet="000000001", weapon="gauss-reaper", model_role="", character=False, limit=20))
            links = {r["id"]: r for r in rows[0]["datasheets"]}
            self.assertEqual(links["000000001"]["weapon_label_resolutions"][0]["label_suffix"], "reaper")
            self.assertEqual(links["000000003"]["weapon_label_resolutions"], [])

    def test_source_object_types_override_character_like_accessory_names(self):
        def row(kind, label, path="ObjectStates/0"):
            return {"tts_type": kind, "label": label, "path": path}
        self.assertEqual(classify_source_object(row("CardCustom", "Lazarus"), "miniature")[0], "ignored")
        self.assertEqual(classify_source_object(row("Bag", "Ruined Buildings"))[0], "container")
        self.assertEqual(classify_source_object(row("BlockSquare", "Ruined Building"))[0], "terrain")
        self.assertEqual(classify_source_object(row("Custom_Model", "32mm"))[0], "base")
        self.assertEqual(classify_source_object(row("Custom_Model", "Body", "ObjectStates/0/ChildObjects/0"))[0], "component")
        self.assertEqual(classify_source_object(row("BlockSquare", "Unknown"))[0], "unclassified")
        self.assertEqual(classify_source_object(row("Custom_Model", "Example Body"), "miniature")[0], "miniature")

    def test_object_inventory_requires_complete_unique_parented_sources(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "objects.json"
            root = {"path": "ObjectStates/0", "parent_path": "", "guid": "root", "label": "Container", "source_label": "Container", "tts_type": "Bag", "asset_kinds": []}
            child = dict(root, path="ObjectStates/0/ContainedObjects/0", parent_path="ObjectStates/0", guid="child", label="Ruin", source_label="Ruin", tts_type="BlockSquare")
            payload = {"schema_version": 1, "source_sha256": "source", "scanned_object_count": 2, "warnings": [], "objects": [root, child]}
            def save(): path.write_text(json.dumps(payload), encoding="utf-8")
            save()
            self.assertEqual(len(object_inventory([path], {"source"})), 2)
            with self.assertRaises(ValueError): object_inventory([path], {"source", "missing"})
            payload["objects"] = [root, root]
            save()
            with self.assertRaisesRegex(ValueError, "Duplicate"): object_inventory([path], {"source"})
            payload["objects"] = [dict(child, parent_path="ObjectStates/99")]
            payload["scanned_object_count"] = 1
            save()
            with self.assertRaisesRegex(ValueError, "parent"): object_inventory([path], {"source"})

    def test_object_search_excludes_accessories_and_exposes_unsupported_scenery(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "models.sqlite"
            self.catalog_fixture(path)
            db = sqlite3.connect(path)
            for index, category in enumerate(["terrain", "ignored", "container", "unclassified"]):
                db.execute("INSERT INTO source_objects VALUES(?,?,?,?,?,?,?,?,?,?,?)", ("source", f"ObjectStates/{index}", None, str(index), category, category, category, "BlockSquare", category, "synthetic", "[]"))
            db.commit()
            db.close()
            args = SimpleNamespace(database=path, name="", category=None, source="", parent="", limit=20)
            rows = search_objects(args)
            self.assertEqual({r["category"] for r in rows}, {"terrain", "unclassified"})
            self.assertTrue(all(r["visual_reference_status"] == "no_supported_visual_reference" for r in rows))
            args.category = "ignored"
            self.assertEqual(len(search_objects(args)), 1)


if __name__ == "__main__":
    unittest.main()

extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const VERIFIED_SNAPSHOT_ID := "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z"
const VERIFIED_EXPORT_UPDATED_AT := "2026-10-28T23:48:19+03:00"
const VERIFIED_MANIFEST_SHA256 := "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e"
const VERIFIED_SLICE_SHA256_BY_BOOK := {
	"000000139": "735b84fad5e1b0901ed34dc9cd4f55a62fc69a1e4b8eb086746e598d1770c535",
	"000000021": "0ef16f837a955ea6b832a53c66e5ddae56680c2e629afd83d4cdd970d8b3a0ea",
	"000000023": "63babe1ca34885808f13f7250bd2f1f490fbeb0ba386e9bae1280a93802397f8",
	"000000035": "ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109",
	"000000036": "427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327",
	"000000162": "49b1df5633b88744e6b4f9ee60d0b1e3841178e2ed9bcb76c3eab021efba3f97",
	"000000356": "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var lysander := Profiles.profile("darnath-lysander")
	check("CHARACTER" in lysander.keywords, "Darnath Lysander carries the source datasheet CHARACTER keyword")

	var judiciar := Profiles.profile("judiciar")
	check(judiciar.stats.invulnerable_target == 0 and judiciar.stats.melee_invulnerable_target == 4, "Judiciar's 4+ invulnerable save remains limited to melee attacks")

	var company_heroes := Profiles.profile("company-heroes")
	check(is_equal_approx(company_heroes.base_radius_inches, 20.0 / 25.4), "Company Heroes' 40 mm bases map to a 20 mm radius")

	var catalog := Profiles.catalog()
	var source_scope_counts := {"000000139": 0, "000000356": 0}
	for profile: Dictionary in catalog.values():
		var book_id := str(profile.get("source_book_id", ""))
		if source_scope_counts.has(book_id): source_scope_counts[book_id] = int(source_scope_counts[book_id]) + 1
	check(catalog.size() == 185 and source_scope_counts["000000139"] == 85 and source_scope_counts["000000356"] == 24, "The catalog contains 161 standard Space Marine sheets plus twenty-four separately sourced Legends profiles")
	for identity: String in catalog:
		var profile: Dictionary = catalog[identity]
		var book_id := str(profile.get("source_book_id", ""))
		var expected_slice_sha256 := str(VERIFIED_SLICE_SHA256_BY_BOOK.get(book_id, ""))
		check(not str(profile.get("source_datasheet_id", "")).is_empty(), "%s records its Wahapedia datasheet identity" % identity)
		check(profile.get("source_verified_against_snapshot_id", "") == VERIFIED_SNAPSHOT_ID and profile.get("source_verified_against_export_updated_at", "") == VERIFIED_EXPORT_UPDATED_AT, "%s records the current verified export revision" % identity)
		check(profile.get("source_verified_against_manifest_sha256", "") == VERIFIED_MANIFEST_SHA256 and not expected_slice_sha256.is_empty() and profile.get("source_verified_against_slice_manifest_sha256", "") == expected_slice_sha256, "%s records its verified export and chapter-slice hashes" % identity)

	print("Space Marine source field checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

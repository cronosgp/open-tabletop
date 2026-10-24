extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

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

	print("Space Marine source field checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

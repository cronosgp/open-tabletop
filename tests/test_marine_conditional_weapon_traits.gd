extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const WeaponTraits = preload("res://scripts/edition_11/weapon_traits.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func state_for(identity: String, target_keywords: Array[String]) -> Dictionary:
	return {
		"turn": 1, "round": 1, "phase": "shooting", "active": 1,
		"unit_abilities": {"implementation": Abilities.ID, "used": {}, "window": {}},
		"units": {
			100: {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "squad": 1, "owner": 1, "wounds": 1, "max_wounds": 1, "keywords": ["ADEPTUS ASTARTES"]},
			200: {"definition_id": "fixture:conditional-target", "squad": 2, "owner": 2, "wounds": 1, "max_wounds": 1, "keywords": target_keywords.duplicate()}
		},
		"squads": {
			1: {"owner": 1, "name": "Attacker", "charged": false},
			2: {"owner": 2, "name": "Target", "charged": false}
		}
	}

func traits_for(identity: String, weapon: Dictionary, target_keywords: Array[String], melee: bool = false) -> Dictionary:
	return Abilities.weapon(state_for(identity, target_keywords), 100, 2, weapon, melee)

func run() -> void:
	var anzuq: Dictionary = Profiles.profile("kor-sarro-khan").ranged[0].profiles.standard
	check(anzuq.get("target_required_traits", {}) == {"devastating-wounds": ["INFANTRY"]}, "Anzuq records its Infantry-only Devastating Wounds condition")
	check(traits_for("kor-sarro-khan", anzuq, ["INFANTRY"]).keywords.get("devastating-wounds", false), "Anzuq keeps Devastating Wounds against Infantry")
	check(not traits_for("kor-sarro-khan", anzuq, ["VEHICLE"]).keywords.has("devastating-wounds"), "Anzuq loses Devastating Wounds against non-Infantry targets")

	var aethon_claws: Dictionary = Profiles.profile("aethon-shaan").melee[0].profiles.standard
	check(aethon_claws.get("target_restricted_traits", {}).get("sustained-hits") == ["MONSTER", "VEHICLE"], "Claws of Severax source metadata restricts Sustained Hits against Monsters and Vehicles")
	check(traits_for("aethon-shaan", aethon_claws, ["INFANTRY"], true).keywords.get("sustained-hits", 0) == 2, "Claws of Severax keep Sustained Hits 2 against Infantry")
	check(not traits_for("aethon-shaan", aethon_claws, ["MONSTER"], true).keywords.has("sustained-hits") and not traits_for("aethon-shaan", aethon_claws, ["VEHICLE"], true).keywords.has("sustained-hits"), "Claws of Severax lose Sustained Hits 2 against Monsters and Vehicles")

	var carbine: Dictionary = Profiles.eliminator_gun("carbine").profiles.standard
	check(carbine.keywords.get("lethal-hits", false) and carbine.get("target_restricted_traits", {}).get("lethal-hits") == ["MONSTER", "VEHICLE"], "Instigator Bolt Carbine encodes its conditional Lethal Hits on the source weapon profile")
	check(traits_for("eliminator-squad", carbine, ["INFANTRY"]).keywords.get("lethal-hits", false), "Instigator Bolt Carbine has Lethal Hits against non-Monster/Vehicle targets")
	check(not traits_for("eliminator-squad", carbine, ["MONSTER"]).keywords.has("lethal-hits") and not traits_for("eliminator-squad", carbine, ["VEHICLE"]).keywords.has("lethal-hits"), "Instigator Bolt Carbine loses Lethal Hits against Monsters and Vehicles")

	for identity: String in ["repulsor", "repulsor-executioner"]:
		var cannon: Dictionary = {}
		for weapon: Dictionary in Profiles.profile(identity).ranged:
			if weapon.id == "heavy-onslaught-gatling-cannon": cannon = weapon.profiles.standard
		check(not cannon.is_empty(), "%s exposes its Heavy Onslaught profile" % identity)
		if cannon.is_empty(): continue
		var against_infantry := traits_for(identity, cannon, ["INFANTRY"])
		var against_monster := traits_for(identity, cannon, ["MONSTER"])
		var against_vehicle := traits_for(identity, cannon, ["VEHICLE"])
		check(against_infantry.keywords.get("devastating-wounds", false) and against_infantry.keywords.get("sustained-hits", 0) == 2, "%s keeps both conditional traits against Infantry" % identity)
		check(not against_monster.keywords.has("devastating-wounds") and not against_monster.keywords.has("sustained-hits"), "%s removes both conditional traits against Monsters" % identity)
		check(not against_vehicle.keywords.has("devastating-wounds") and not against_vehicle.keywords.has("sustained-hits"), "%s removes both conditional traits against Vehicles" % identity)

	var invader_cannon: Dictionary = Profiles.profile("invader-atvs").ranged[1].profiles.standard
	check(invader_cannon.get("target_restricted_traits", {}) == {"devastating-wounds": ["MONSTER", "VEHICLE"]}, "Invader Onslaught Cannon records the source target restriction")
	check(traits_for("invader-atvs", invader_cannon, ["INFANTRY"]).keywords.get("devastating-wounds", false), "Invader Onslaught Cannon keeps Devastating Wounds against non-Monster/Vehicle targets")
	check(not traits_for("invader-atvs", invader_cannon, ["MONSTER"]).keywords.has("devastating-wounds") and not traits_for("invader-atvs", invader_cannon, ["VEHICLE"]).keywords.has("devastating-wounds"), "Invader Onslaught Cannon loses Devastating Wounds against Monsters and Vehicles")

	var speeder_cannon: Dictionary = Profiles.profile("land-speeder").ranged[1].profiles.standard
	check(speeder_cannon.get("target_restricted_traits", {}) == {"devastating-wounds": ["MONSTER", "VEHICLE"]}, "Land Speeder Onslaught Cannon records the source target restriction")
	check(traits_for("land-speeder", speeder_cannon, ["INFANTRY"]).keywords.get("devastating-wounds", false), "Land Speeder Onslaught Cannon keeps Devastating Wounds against non-Monster/Vehicle targets")
	check(not traits_for("land-speeder", speeder_cannon, ["MONSTER"]).keywords.has("devastating-wounds") and not traits_for("land-speeder", speeder_cannon, ["VEHICLE"]).keywords.has("devastating-wounds"), "Land Speeder Onslaught Cannon loses Devastating Wounds against Monsters and Vehicles")

	var eradicator_hunter: Dictionary = Profiles.eradicator_ranged(false).profiles.hunter
	var terminator_hunter: Dictionary = Profiles.profile("terminator-squad").additional_weapon_profiles.melee[0].profiles.hunter
	check(WeaponTraits.hunter_error(eradicator_hunter, ["INFANTRY"]) != "" and WeaponTraits.hunter_error(eradicator_hunter, ["VEHICLE"]).is_empty(), "Eradicator Hunter profile remains gated to Monster or Vehicle targets")
	check(terminator_hunter.keywords.get("hunter", []) == ["Monster", "Vehicle"] and WeaponTraits.hunter_error(terminator_hunter, ["INFANTRY"]) != "" and WeaponTraits.hunter_error(terminator_hunter, ["MONSTER"]).is_empty(), "Terminator Chainfist Hunter now uses the source Monster/Vehicle target gate")

	print("Marine conditional weapon traits: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")

extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const BloodAngelsCharacters = preload("res://scripts/edition_11/blood_angels_characters.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")

const CAPTAIN := "death-company-captain"
const JUMP_CAPTAIN := "death-company-captain-with-jump-pack"
const ASTORATH := "astorath"
const LEMARTES := "lemartes"
const FOOT_DC := "death-company-marines"
const JUMP_DC := "death-company-marines-with-jump-packs"

var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func fresh_state() -> Dictionary:
	var lists := F.current_marine_selections()
	for owner: int in [1, 2]:
		lists[owner].category = "custom"
		lists[owner].points_limit = 3000
	lists[1].entries = [entry(CAPTAIN), entry(JUMP_CAPTAIN), entry(ASTORATH), entry(LEMARTES), entry(FOOT_DC, 5), entry(JUMP_DC, 5)]
	lists[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true,
		"marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, lists)

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func find_choice(state: Dictionary, player: int, action: String, squad: int, model: int, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if int(option.get("target", -1)) != squad or int(option.get("model", -1)) != model: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func find_in_options(options: Array, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func submit_choice(state: Dictionary, player: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	var selected := find_choice(state, player, action, squad, model, value)
	if selected.is_empty(): return {"error": "Missing choice %s/%s for model %d." % [action, value, model]}
	return PublicUnitCommand.submit(state, player, selected, Vector2.ZERO, Callable(self, "next_die"))

func next_die() -> int:
	if dice.is_empty(): return 1
	return dice.pop_front()

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var snapshot_hash := "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"
	var slice_hash := "74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5"
	var expected := {
		CAPTAIN: {"id": "000003832", "points": 80, "movement": 6, "wounds": 5},
		JUMP_CAPTAIN: {"id": "000003833", "points": 85, "movement": 12, "wounds": 5},
		ASTORATH: {"id": "000000157", "points": 90, "movement": 12, "wounds": 5},
		LEMARTES: {"id": "000000164", "points": 110, "movement": 12, "wounds": 5}}
	for identity: String in expected:
		var profile := Profiles.profile(identity)
		var facts: Dictionary = expected[identity]
		check(profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == facts.id, "%s maps to its exact Blood Angels App datasheet." % identity)
		check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == snapshot_hash and profile.get("source_slice_manifest_sha256") == slice_hash, "%s records the verified local export snapshot and hashes." % identity)
		check(profile.get("points_by_models", {}) == {1: facts.points} and profile.get("stats", {}).get("movement_inches") == facts.movement and profile.get("stats", {}).get("wounds") == facts.wounds, "%s fixed points and characteristics match the pinned export." % identity)
		check(profile.get("base_size_source_mm") == 40 and profile.get("stats", {}).get("toughness") == 5 and profile.get("stats", {}).get("invulnerable_target") == 4, "%s preserves its 40 mm base, Toughness and invulnerable save." % identity)

	var foot := Profiles.profile(CAPTAIN)
	check(foot.get("options", {}).get("ranged_packages", []) == ["heavy-bolt-pistol", "inferno-pistol"] and foot.get("options", {}).get("melee_packages", []) == ["master-crafted-chainsword", "power-fist", "relic-weapon"], "Foot Captain exposes only the source-listed pistol and melee replacements.")
	for pistol: String in ["heavy-bolt-pistol", "inferno-pistol"]:
		for melee: String in ["master-crafted-chainsword", "power-fist", "relic-weapon"]:
			var package := Profiles.death_company_captain_weapons(pistol, melee)
			check(not package.is_empty() and package.ranged.size() == 1 and package.melee.size() == 1, "Foot Captain builds the legal %s / %s package." % [pistol, melee])
	check(Profiles.death_company_captain_weapons("plasma-pistol", "power-fist").is_empty(), "Foot Captain rejects unlisted equipment.")
	var jump_profile := Profiles.profile(JUMP_CAPTAIN)
	var jump_packages: Array = jump_profile.get("options", {}).get("loadout_packages", [])
	check(jump_packages.size() == 9, "Jump Pack Captain retains all nine source-listed equipment packages.")
	for package: String in jump_packages:
		var weapons := Profiles.death_company_jump_captain_weapons(package)
		check(not weapons.is_empty(), "Jump Pack Captain builds source-listed package %s." % package)
		check(bool(weapons.get("relic_shield", false)) == (package in ["thunder-hammer-shield", "chainsword-shield"]), "Jump Pack Captain sets the Relic Shield only for shield packages.")
	check(Profiles.death_company_jump_captain_weapons("invalid").is_empty(), "Jump Pack Captain rejects unlisted equipment.")

	var expected_abilities := {
		CAPTAIN: ["leader", "combat-doctrines", "feel-no-pain-6", "death-visions-of-sanguinius", "black-rage", "forlorn-hero"],
		JUMP_CAPTAIN: ["deep-strike", "combat-doctrines", "feel-no-pain-6", "black-rage", "death-visions-of-sanguinius", "lost-to-fury"],
		ASTORATH: ["leader", "deep-strike", "combat-doctrines", "redeemer-of-the-lost", "mass-of-doom"],
		LEMARTES: ["leader", "deep-strike", "feel-no-pain-6", "combat-doctrines", "fury-unbound", "guardian-of-the-lost"]}
	for identity: String in expected_abilities:
		check(AbilityCatalog.RULES.get(identity, []) == expected_abilities[identity], "%s registers only its source-listed ability set." % identity)
		check(Catalog.SPECS.get(identity, {}).get("current_reference", false) and Roster.POINTS.get(identity, {}).get("sizes", {}) == {1: expected[identity].points}, "%s is admitted at its fixed source cost." % identity)
	check(MarineLinks.CHAPTER_TARGETS.get(CAPTAIN, []) == [FOOT_DC], "Foot Captain has only its listed Death Company Marine target.")
	for identity: String in [JUMP_CAPTAIN, ASTORATH, LEMARTES]:
		check(MarineLinks.CHAPTER_TARGETS.get(identity, []) == [JUMP_DC], "%s has only its listed Jump Pack Death Company target." % identity)

	var state := fresh_state()
	var materialization_error := str(state.get("error", ""))
	check(materialization_error.is_empty(), "Both players materialize with current Marine catalogs: " + materialization_error)
	if not materialization_error.is_empty():
		print(materialization_error)
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.setup_players = []
	state.unit_abilities.window = {}
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(-12, 12) if int(state.units[model].owner) == 1 else Vector2(12, 12)

	var foot_model := find_model(state, 1, CAPTAIN)
	var jump_model := find_model(state, 1, JUMP_CAPTAIN)
	var astorath_model := find_model(state, 1, ASTORATH)
	var lemartes_model := find_model(state, 1, LEMARTES)
	var foot_captain_squad := int(state.units[foot_model].squad) if foot_model >= 0 else -1
	var jump_captain_squad := int(state.units[jump_model].squad) if jump_model >= 0 else -1
	var astorath_squad := int(state.units[astorath_model].squad) if astorath_model >= 0 else -1
	var foot_squad := find_squad(state, 1, FOOT_DC)
	var jump_squad := find_squad(state, 1, JUMP_DC)
	var enemy_captain := find_model(state, 2, "captain")
	var enemy_squad := find_squad(state, 2, "captain")
	var required_ids: Array[int] = [foot_model, jump_model, astorath_model, lemartes_model, foot_squad, jump_squad, enemy_captain, enemy_squad]
	var required_ids_valid := true
	for required_id: int in required_ids:
		if required_id < 0: required_ids_valid = false
	check(required_ids_valid, "All four Blood Angels characters and both Death Company targets materialize.")
	if not required_ids_valid:
		quit(1)
		return
	check(C.UnitActions.attachment_allowed(state, foot_model, foot_squad), "Foot Captain can lead Death Company Marines.")
	for model: int in [jump_model, astorath_model, lemartes_model]:
		check(C.UnitActions.attachment_allowed(state, model, jump_squad), "%s can lead Death Company Marines With Jump Packs." % C.UnitAbilities.identity(state.units[model]))
	for identity: String in [CAPTAIN, JUMP_CAPTAIN, ASTORATH, LEMARTES]:
		var model := find_model(state, 1, identity)
		var squad := int(state.units[model].squad)
		var grants: Array = UnitPrevention.grants(state, squad)
		check({"target": 6, "against": "any"} in grants if identity in [CAPTAIN, JUMP_CAPTAIN, LEMARTES] else {"target": 6, "against": "any"} not in grants, "%s has only its datasheet Feel No Pain grant." % identity)
	for identity: String in [CAPTAIN, JUMP_CAPTAIN, ASTORATH, LEMARTES]:
		check(not find_choice(state, 1, "warlord", -1, find_model(state, 1, identity)).is_empty(), "%s is offered as a Warlord choice." % identity)
	for identity: String in [JUMP_CAPTAIN, ASTORATH, LEMARTES]:
		var model := find_model(state, 1, identity)
		var squad := int(state.units[model].squad)
		check(C.UnitAbilities.has(state, squad, "deep-strike") and C.UnitAbilities.every_model_has(state, squad, "deep-strike"), "%s retains Deep Strike through its attached-unit reserve check." % identity)
	for identity: String in [CAPTAIN, JUMP_CAPTAIN, ASTORATH, LEMARTES]:
		var model := find_model(state, 1, identity)
		check(C.UnitAbilities.has(state, int(state.units[model].squad), "combat-doctrines"), "%s is affected by the shared Combat Doctrines rule." % identity)

	var prepared_options := C.UnitActions.choices(state, 1)
	var pistol_option := find_in_options(prepared_options, "death-company-captain-ranged-loadout", foot_captain_squad, foot_model, "inferno-pistol")
	var captain_pistol_result := PublicUnitCommand.submit(state, 1, pistol_option, Vector2.ZERO, Callable(self, "next_die")) if not pistol_option.is_empty() else {"error": "Inferno Pistol was not projected."}
	var melee_option := find_in_options(C.UnitActions.choices(state, 1), "death-company-captain-melee-loadout", foot_captain_squad, foot_model, "power-fist")
	var captain_melee_result := PublicUnitCommand.submit(state, 1, melee_option, Vector2.ZERO, Callable(self, "next_die")) if not melee_option.is_empty() else {"error": "Power Fist was not projected."}
	var equipped_foot_package := Profiles.death_company_captain_weapons("inferno-pistol", "power-fist")
	check(str(captain_pistol_result.get("error", "")).is_empty() and str(captain_melee_result.get("error", "")).is_empty() and state.units[foot_model].ranged_weapons == equipped_foot_package.ranged and state.units[foot_model].melee_weapons == equipped_foot_package.melee, "Public preparation choices install the source-listed Inferno Pistol and Power Fist package: %s / %s; ranged=%s melee=%s" % [str(captain_pistol_result), str(captain_melee_result), str(state.units[foot_model].ranged_weapons), str(state.units[foot_model].melee_weapons)])
	var captain_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, equipped_foot_package, foot_model, enemy_squad)
	check(captain_weapon_failures.is_empty(), "Death Company Captain's selected Inferno Pistol/Power Fist weapons pass Equipment and AttackPlan checks: %s" % str(captain_weapon_failures))

	for package: String in jump_packages:
		var weapons := Profiles.death_company_jump_captain_weapons(package)
		check(not weapons.is_empty() and bool(weapons.get("relic_shield", false)) == (package in ["thunder-hammer-shield", "chainsword-shield"]), "Jump Pack package %s builds its exact weapons and shield flag." % package)
	var jump_option := find_in_options(C.UnitActions.choices(state, 1), "death-company-jump-captain-loadout", jump_captain_squad, jump_model, "thunder-hammer-shield")
	var jump_public_result := PublicUnitCommand.submit(state, 1, jump_option, Vector2.ZERO, Callable(self, "next_die")) if not jump_option.is_empty() else {"error": "Thunder Hammer + Relic Shield was not projected."}
	var equipped_jump_package := Profiles.death_company_jump_captain_weapons("thunder-hammer-shield")
	check(str(jump_public_result.get("error", "")).is_empty() and state.units[jump_model].ranged_weapons == equipped_jump_package.ranged and state.units[jump_model].melee_weapons == equipped_jump_package.melee and state.units[jump_model].max_wounds == 6, "Public Jump Pack equipment choice installs the Thunder Hammer and Relic Shield and adds one Wound: %s; ranged=%s melee=%s wounds=%s" % [str(jump_public_result), str(state.units[jump_model].ranged_weapons), str(state.units[jump_model].melee_weapons), str(state.units[jump_model].max_wounds)])

	state.phase = "fight"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.units[foot_model].position = Vector2(0, 0)
	state.units[enemy_captain].position = Vector2(1, 0)
	var foot_plan := C.AttackPlan.prepare(state, foot_captain_squad, true, [{"model": foot_model, "target": enemy_squad, "amount": 6, "weapon": "power-fist", "profile": "standard"}], true)
	check(str(foot_plan.get("error", "")).is_empty() and foot_plan.batches.size() == 1 and foot_plan.batches[0].context.hit_reroll == "ones", "Foot Captain Black Rage grants melee Hit re-rolls through AttackPlan.")
	var jump_weapon: Dictionary = Equipment.select(state, jump_model, true).get("stats", {})
	var jump_effective := C.UnitAbilities.weapon(state, jump_model, enemy_squad, jump_weapon, true)
	check(jump_effective.get("keywords", {}).get("sustained-hits", 0) == 1, "Jump Pack Captain Lost to Fury adds Sustained Hits 1 to melee attacks.")
	var astorath_weapon: Dictionary = Equipment.select(state, astorath_model, true).get("stats", {})
	var astorath_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, Profiles.profile(ASTORATH), astorath_model, enemy_squad)
	check(astorath_weapon_failures.is_empty(), "Astorath's Executioner's Axe passes Equipment and AttackPlan checks: %s" % str(astorath_weapon_failures))
	state.squads[astorath_squad].charged = true
	var astorath_effective := C.UnitAbilities.weapon(state, astorath_model, enemy_squad, astorath_weapon, true)
	check(astorath_effective.get("keywords", {}).get("devastating-wounds", false), "Astorath's Mass of Doom adds Devastating Wounds to eligible melee targets after a Charge move.")
	state.units[enemy_captain].keywords.append("MONSTER")
	var monster_effective := C.UnitAbilities.weapon(state, astorath_model, enemy_squad, astorath_weapon, true)
	check(monster_effective.get("keywords", {}) == astorath_weapon.get("keywords", {}), "Mass of Doom adds no extra keyword against MONSTER targets; Astorath's axe retains its source Devastating Wounds trait.")
	state.units[enemy_captain].keywords.erase("MONSTER")
	var lemartes_weapon: Dictionary = Equipment.select(state, lemartes_model, true).get("stats", {})
	var lemartes_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, Profiles.profile(LEMARTES), lemartes_model, enemy_squad)
	check(lemartes_weapon_failures.is_empty(), "Lemartes' pistol and Blood Crozius pass Equipment and AttackPlan checks: %s" % str(lemartes_weapon_failures))
	var lemartes_effective := C.UnitAbilities.weapon(state, lemartes_model, enemy_squad, lemartes_weapon, true)
	check(lemartes_effective.get("keywords", {}).get("lethal-hits", false), "Lemartes Fury Unbound adds Lethal Hits to melee attacks.")
	check(C.UnitAbilities.damage(state, lemartes_model, 3) == 2 and C.UnitAbilities.damage(state, lemartes_model, 1) == 1 and C.UnitAbilities.damage(state, lemartes_model, 3, "mortal") == 3, "Guardian of the Lost reduces normal Damage by 1, keeps a minimum of 1, and does not reduce mortal wounds.")
	check(C.UnitAbilities.scout_distance(state, foot_captain_squad) == 6, "Forlorn Hero gives the foot Captain's unit Scouts 6.")

	var death_state: Dictionary = state.duplicate(true)
	death_state.phase = "fight"
	death_state.unit_abilities.window = {}
	death_state.units[foot_model].wounds = 0
	death_state.units[foot_model].position = Vector2(0, 0)
	death_state.units[enemy_captain].keywords.append("WARLORD")
	death_state.units[enemy_captain].position = Vector2(1, 0)
	death_state.pending_attack = {"melee": true, "squad": enemy_squad}
	BloodAngelsCharacters.record_death_visions(death_state, foot_model)
	var triggers: Array = death_state.unit_abilities.get("death_visions_triggers", [])
	check(triggers.size() == 1 and bool(triggers[0].get("warlord_engaged", false)), "Death Visions records the destroyed Captain and the engaged enemy Warlord unit.")
	death_state.pending_attack = {}
	check(C.UnitActions.open_death_visions(death_state, enemy_squad), "Death Visions opens after the enemy unit finishes fighting.")
	var death_options := BloodAngelsCharacters.choices(death_state, 1)
	var use_option: Dictionary = {}
	for option: Dictionary in death_options:
		if str(option.get("action", "")) == BloodAngelsCharacters.DEATH_VISIONS_USE: use_option = option
	check(not use_option.is_empty(), "The destroyed Captain's owner can choose Death Visions against the destroying unit.")
	dice = [4, 3]
	var death_result := BloodAngelsCharacters.apply(death_state, 1, use_option, Callable(self, "next_die")) if not use_option.is_empty() else {"error": "missing Death Visions choice"}
	check(str(death_result.get("error", "")).is_empty() and int(death_state.last_death_visions.total) == 6 and int(death_state.last_death_visions.total_wounds) == 5, "Death Visions adds +2 against an engaged Warlord unit and resolves D3+3 from the host dice: %s / %s" % [str(death_result), str(death_state.get("last_death_visions", {}))])
	var mortal_options := C.CoreReactions.mortal_allocations(death_state, 2, BloodAngelsCharacters.DEATH_VISIONS_MORTAL)
	check(not mortal_options.is_empty(), "Death Visions hands mortal wounds to the target controller's allocation window: window=%s record=%s" % [str(C.UnitActions.pending(death_state)), str(death_state.get("last_death_visions", {}))])
	if not mortal_options.is_empty():
		var allocation := C.CoreReactions.allocate_mortal(death_state, 2, mortal_options[0], Callable(self, "next_die"), BloodAngelsCharacters.DEATH_VISIONS_MORTAL)
		check(str(allocation.get("error", "")).is_empty() and int(death_state.last_death_visions.remaining) == 4, "The defender allocates Death Visions mortal wounds through the shared reaction resolver: %s / remaining=%s" % [str(allocation), str(death_state.last_death_visions.remaining)])

	var redeemer_fail: Dictionary = state.duplicate(true)
	redeemer_fail.phase = "fight"
	redeemer_fail.unit_abilities.window = {}
	redeemer_fail.fight_selected = -1
	redeemer_fail.squads[astorath_squad].fought = false
	redeemer_fail.squads[enemy_squad].stats.toughness = 4
	redeemer_fail.units[astorath_model].wounds = 0
	redeemer_fail.units[astorath_model].position = Vector2(0, 0)
	redeemer_fail.units[enemy_captain].position = Vector2(1, 0)
	dice = [3]
	var failed_redeemer := C.DetachmentStratagems.hold_destroyed(redeemer_fail, astorath_model, Callable(self, "next_die"))
	check(str(failed_redeemer.get("error", "")).is_empty() and not bool(failed_redeemer.get("held", true)), "Redeemer of the Lost does not add its modifier against lower-Toughness enemies.")
	var redeemer_hold: Dictionary = state.duplicate(true)
	redeemer_hold.phase = "fight"
	redeemer_hold.unit_abilities.window = {}
	redeemer_hold.fight_selected = -1
	redeemer_hold.squads[astorath_squad].fought = false
	redeemer_hold.squads[enemy_squad].stats.toughness = 5
	redeemer_hold.units[astorath_model].wounds = 0
	redeemer_hold.units[astorath_model].position = Vector2(0, 0)
	redeemer_hold.units[enemy_captain].position = Vector2(1, 0)
	dice = [3]
	var held := C.DetachmentStratagems.hold_destroyed(redeemer_hold, astorath_model, Callable(self, "next_die"))
	check(str(held.get("error", "")).is_empty() and bool(held.get("held", false)) and redeemer_hold.units[astorath_model].wounds == 1 and redeemer_hold.units[astorath_model].get("lingering", false), "Redeemer of the Lost adds +1 for equal Toughness and retains Astorath at 1 wound.")
	C.DetachmentStratagems.remove_lingering(redeemer_hold, astorath_squad)
	check(redeemer_hold.units[astorath_model].wounds == 0 and not redeemer_hold.units[astorath_model].get("lingering", false), "Astorath is removed after his unit fights or the Fight phase ends.")

	print("Blood Angels character source-bounded checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

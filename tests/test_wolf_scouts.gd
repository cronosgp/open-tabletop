extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const FenrisianWolves = preload("res://scripts/edition_11/fenrisian_wolves.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "wolf-scouts"
const ENTRY := "40kdc:11e:adeptus-astartes:wolf-scouts"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [
			{"definition_id": ENTRY, "models": 6, "copies": 1},
			{"definition_id": ENTRY, "models": 12, "copies": 1},
			{"definition_id": ENTRY, "models": 6, "copies": 1}
		]
		if owner == 1: result[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:captain-in-phobos-armour", "models": 1, "copies": 1})
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}
	}, selections())

func squads_for(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == UNIT:
				result.append(squad)
				break
	result.sort()
	return result

func models_for(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == UNIT: result.append(model)
	result.sort()
	return result

func model_with_role(state: Dictionary, squad: int, role: String) -> int:
	for model: int in models_for(state, squad):
		if str(state.units[model].get("wolf_scouts_role", "")) == role: return model
	return -1

func choice(state: Dictionary, player: int, action: String, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func submit(state: Dictionary, player: int, action: String, model: int, squad: int, value: String, roller: Callable = Callable()) -> Dictionary:
	return PublicUnitCommand.submit(state, player, choice(state, player, action, model, squad, value), Vector2.ZERO, roller)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000004182" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "af19b879ba7ecfd116ac06d5cd9aeaae2231a385a7bbca195fe34f5058cdb88d", "Wolf Scouts records the Space Wolves App sheet and verified local slice")
	check(profile.points_by_models == {6: 95, 12: 190} and profile.third_plus_points_by_models == {6: 105, 12: 200} and profile.max_supported_copies == 3, "Both source-priced compositions and copy tiers match the local export")
	check(profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and profile.model_base_sizes_source_mm["Hunting Wolf"] == "60 x 35.5", "The Pack Leader baseline and three model base definitions match the export")
	check(Army.SPECS.get(UNIT, {}).get("current_reference", false) and Army.SPECS[UNIT].get("max_supported_copies", 0) == 3, "Wolf Scouts enters the consolidated current construction catalog")
	check("wolf-scouts" in Links.targets("captain-in-phobos-armour") and "wolf-scouts" in Links.targets("lieutenant-in-phobos-armour") and "wolf-scouts" in Links.targets("librarian-in-phobos-armour"), "All three source-listed Phobos Leaders resolve to Wolf Scouts")
	check("deadly-stalkers" in C.UnitAbilities.RULES.get(UNIT, []) and "hunting-hounds" in C.UnitAbilities.RULES.get(UNIT, []) and "haywire-mine" in C.UnitAbilities.RULES.get(UNIT, []) and "scouts-8" in C.UnitAbilities.RULES.get(UNIT, []) and "infiltrators" in C.UnitAbilities.RULES.get(UNIT, []), "All exported Wolf Scouts abilities are registered")
	var options: Array = profile.options.wolf_scout_loadouts
	check(options == ["default", "bolt-pistol", "runic-stave", "thunderclap", "instigator-bolt-carbine", "plasma-gun"], "Only the six source-listed ordinary Scout loadouts are selectable")
	var leader := Profiles.wolf_scouts_model_loadout(0, 6)
	var hunter := Profiles.wolf_scouts_model_loadout(1, 6)
	var scout := Profiles.wolf_scouts_model_loadout(2, 6)
	var second_hunter := Profiles.wolf_scouts_model_loadout(2, 12)
	var twelve_scout_profile := Profiles.wolf_scouts_model_loadout(3, 12)
	check(leader.role == "Wolf Scout Pack Leader" and leader.stats.leadership_target == 6 and leader.ranged[0].id == "plasma-pistol" and leader.melee[0].id == "power-weapon", "The Pack Leader keeps its fixed Plasma Pistol and Power Weapon")
	check(hunter.role == "Hunting Wolf" and hunter.stats.movement_inches == 10 and hunter.stats.save_target == 6 and hunter.stats.wounds == 1 and hunter.stats.objective_control == 0 and hunter.base_radius_inches == 30.0 / 25.4 and hunter.melee[0].profiles.standard.attacks == 2, "Hunting Wolf characteristics, teeth and 60 mm bounding-circle base are role-specific")
	check(scout.role == "Wolf Scout" and scout.stats.movement_inches == 8 and scout.ranged[0].id == "plasma-pistol" and scout.melee[0].id == "combat-knife" and second_hunter.role == "Hunting Wolf" and twelve_scout_profile.role == "Wolf Scout", "Six- and twelve-model compositions assign the correct one/two Hunting Wolves")
	var bolt_pistol := Profiles.wolf_scouts_model_loadout(2, 6, "bolt-pistol")
	var runic_stave := Profiles.wolf_scouts_model_loadout(2, 6, "runic-stave")
	var thunderclap := Profiles.wolf_scouts_model_loadout(2, 6, "thunderclap")
	var carbine := Profiles.wolf_scouts_model_loadout(3, 12, "instigator-bolt-carbine")
	var plasma_gun := Profiles.wolf_scouts_model_loadout(2, 6, "plasma-gun")
	check(bolt_pistol.ranged[0].id == "bolt-pistol" and bolt_pistol.melee.is_empty() and runic_stave.ranged.is_empty() and runic_stave.melee[0].id == "runic-stave" and thunderclap.ranged[0].profiles.standard.keywords.psychic and thunderclap.ranged[0].profiles.standard.keywords.blast == 1 and thunderclap.melee.is_empty(), "The paired replacement options remove both default weapons and preserve each source profile")
	check(carbine.ranged[0].profiles.standard.keywords.precision and carbine.ranged[0].profiles.standard.target_restricted_traits["lethal-hits"] == ["MONSTER", "VEHICLE"] and carbine.melee[0].id == "combat-knife", "Instigator Carbine has Precision, conditional Lethal Hits and retains the knife")
	check(plasma_gun.ranged[0].profiles.standard.keywords["rapid-fire"] == 1 and plasma_gun.ranged[0].profiles.supercharge.keywords.hazardous and plasma_gun.melee[0].id == "combat-knife", "Plasma Gun carries both profiles and leaves the Combat Knife")

	var state := fresh()
	check(not state.has("error"), "The source-priced Wolf Scouts roster materializes from the current catalog")
	if state.has("error"):
		print(str(state.get("error", "")))
		quit(1)
		return
	var friendly := squads_for(state, 1)
	var enemy := squads_for(state, 2)
	check(friendly.size() == 3 and enemy.size() == 3, "Each player can field the two legal sizes and a third copy")
	if friendly.size() < 3 or enemy.size() < 3:
		quit(1)
		return
	var squad := -1
	var twelve_squad := -1
	var remaining_six_squad := -1
	for candidate: int in friendly:
		var count := models_for(state, candidate).size()
		if count == 12: twelve_squad = candidate
		elif squad < 0: squad = candidate
		else: remaining_six_squad = candidate
	if squad < 0 or twelve_squad < 0 or remaining_six_squad < 0:
		print("Wolf Scouts prepared squad sizes: %s" % str(friendly.map(func(candidate: int) -> int: return models_for(state, candidate).size())))
		quit(1)
		return
	var target := enemy[0]
	var other_enemy := enemy[1]
	var models := models_for(state, squad)
	var twelve_models := models_for(state, twelve_squad)
	check(models.size() == 6 and twelve_models.size() == 12 and int(state.squads[squad].training_cost) == 95 and int(state.squads[twelve_squad].training_cost) == 190 and int(state.squads[remaining_six_squad].training_cost) == 95, "Prepared model counts and size-specific first/second copy costs match the datasheet")
	var pack_leader := model_with_role(state, squad, "Wolf Scout Pack Leader")
	var hunting_wolf := model_with_role(state, squad, "Hunting Wolf")
	var regular_scout := model_with_role(state, squad, "Wolf Scout")
	check(pack_leader >= 0 and hunting_wolf >= 0 and regular_scout >= 0 and state.units[pack_leader].radius == 16.0 / 25.4 and state.units[hunting_wolf].radius == 30.0 / 25.4 and state.units[hunting_wolf].max_wounds == 1 and state.units[hunting_wolf].objective_control == 0, "Each mixed model receives its own source stats and base proxy")
	check(C.UnitAbilities.scout_distance(state, squad) == 8 and Detection.infiltrators(state, squad), "Scouts 8 and Infiltrators use the shared pre-battle placement rules")
	check(C.UnitAbilities.has(state, squad, "deadly-stalkers") and C.UnitAbilities.has(state, squad, "hunting-hounds") and C.UnitAbilities.has(state, squad, "haywire-mine"), "The prepared unit exposes its three datasheet abilities")
	check(state.units[pack_leader].ranged_weapons[0].id == "plasma-pistol" and state.units[pack_leader].melee_weapons[0].id == "power-weapon" and state.units[hunting_wolf].melee_weapons[0].id == "teeth-and-claws" and state.units[regular_scout].ranged_weapons[0].id == "plasma-pistol" and state.units[regular_scout].melee_weapons[0].id == "combat-knife", "Default model weapon inventories remain role-specific")

	var no_carbine_for_six := choice(state, 1, "wolf-scouts-loadout", regular_scout, squad, "instigator-bolt-carbine")
	check(no_carbine_for_six.is_empty(), "A six-model unit cannot take the 12-model Instigator Carbine option")
	var twelve_scout := model_with_role(state, twelve_squad, "Wolf Scout")
	var carbine_choice := submit(state, 1, "wolf-scouts-loadout", twelve_scout, twelve_squad, "instigator-bolt-carbine")
	check(str(carbine_choice.get("error", "")).is_empty() and state.units[twelve_scout].ranged_weapons[0].id == "instigator-bolt-carbine" and state.units[twelve_scout].melee_weapons[0].id == "combat-knife", "One 12-model Scout may publicly replace its Plasma Pistol with an Instigator Carbine")
	var extra_carbine_model: int = twelve_models.filter(func(model: int) -> bool: return str(state.units[model].get("wolf_scouts_role", "")) == "Wolf Scout" and model != twelve_scout)[0]
	check(choice(state, 1, "wolf-scouts-loadout", extra_carbine_model, twelve_squad, "instigator-bolt-carbine").is_empty(), "The per-12-model limit prevents a second carbine")
	var special_choice := submit(state, 1, "wolf-scouts-loadout", regular_scout, squad, "runic-stave")
	check(str(special_choice.get("error", "")).is_empty() and state.units[regular_scout].ranged_weapons.is_empty() and state.units[regular_scout].melee_weapons[0].id == "runic-stave", "The public choice applies a paired weapon replacement to one ordinary Scout")
	var second_scout: int = models.filter(func(model: int) -> bool: return str(state.units[model].get("wolf_scouts_role", "")) == "Wolf Scout" and model != regular_scout)[0]
	check(choice(state, 1, "wolf-scouts-loadout", second_scout, squad, "thunderclap").is_empty(), "Only one Scout can take the Bolt Pistol, Runic Stave or Thunderclap pair")
	var plasma_choice := submit(state, 1, "wolf-scouts-loadout", second_scout, squad, "plasma-gun")
	check(str(plasma_choice.get("error", "")).is_empty() and state.units[second_scout].ranged_weapons[0].id == "plasma-gun" and state.units[second_scout].melee_weapons[0].id == "combat-knife", "A separate Scout may take the Plasma Gun and retain its Combat Knife")
	var mine_install := submit(state, 1, "wolf-scouts-haywire-mine", pack_leader, squad, "on")
	check(str(mine_install.get("error", "")).is_empty() and state.units[pack_leader].get("wolf_scouts_haywire_mine", false), "The Pack Leader can carry the mine while retaining its Plasma Pistol")
	check(choice(state, 1, "wolf-scouts-haywire-mine", hunting_wolf, squad, "on").is_empty() and choice(state, 1, "wolf-scouts-haywire-mine", regular_scout, squad, "on").is_empty(), "The unit carries at most one mine and Hunting Wolves are not eligible bearers")

	var captain := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and C.UnitAbilities.identity(state.units[model]) == "captain-in-phobos-armour": captain = model
	check(captain >= 0 and "CHARACTER" in state.units[captain].keywords and "SPACE WOLVES" not in state.units[captain].keywords, "A generic Captain in Phobos Armour does not gain a Space Wolves datasheet keyword from Chapter context")
	if captain >= 0:
		var hunting_character_id := 0
		for model: int in state.units: hunting_character_id = maxi(hunting_character_id, model + 1)
		var hunting_character: Dictionary = state.units[captain].duplicate(true)
		var hunting_character_keywords: Array = hunting_character.get("keywords", []).duplicate()
		hunting_character_keywords.append("SPACE WOLVES")
		hunting_character.keywords = hunting_character_keywords
		hunting_character.definition_id = "test:11e:adeptus-astartes:space-wolves-character-fixture"
		state.units[hunting_character_id] = hunting_character
		state.units[hunting_wolf].position = Vector2.ZERO
		state.units[hunting_character_id].position = Vector2(6.0 + float(state.units[hunting_wolf].radius) + float(state.units[hunting_character_id].radius), 0.0)
		check(Morale.objective_control(state, hunting_wolf) == 1 and FenrisianWolves.hunting_hounds_bonus(state, regular_scout) == 0, "Hunting Hounds grants +1 OC only to a Hunting Wolf at the inclusive 6-inch base boundary")
		state.units[hunting_character_id].position.x += 0.01
		check(Morale.objective_control(state, hunting_wolf) == 0, "Hunting Hounds stops when the Character moves beyond six inches")
		state.units[hunting_character_id].position.x -= 0.01
		state.squads[squad].battle_shocked = true
		check(Morale.objective_control(state, hunting_wolf) == 0, "Battle-shock prevents the Hunting Hounds Objective Control bonus")
		state.squads[squad].battle_shocked = false

	var attack_state: Dictionary = state.duplicate(true)
	attack_state.phase = "shooting"
	attack_state.active = 1
	attack_state.unit_abilities.setup_players = []
	var attack_scout := -1
	for model: int in models_for(attack_state, squad):
		if str(attack_state.units[model].get("wolf_scouts_role", "")) != "Wolf Scout": continue
		if attack_state.units[model].get("ranged_weapons", []).any(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) == "plasma-pistol"):
			attack_scout = model
			break
	for model: int in models_for(attack_state, squad): attack_state.units[model].position = Vector2(-10.0, float(model % 6) * 2.5)
	for index in range(C.living(attack_state, target).size()): attack_state.units[C.living(attack_state, target)[index]].position = Vector2(0.0, float(index) * 2.5)
	for other_squad: int in enemy:
		if other_squad == target: continue
		var x := 10.0 if other_squad == other_enemy else 20.0
		for model: int in C.living(attack_state, other_squad): attack_state.units[model].position = Vector2(x, float(model % 12) * 2.5)
	var isolated_target_plan := C.AttackPlan.prepare(attack_state, squad, false, [{"model": attack_scout, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "standard"}], true)
	check(str(isolated_target_plan.get("error", "")).is_empty() and isolated_target_plan.batches[0].context.get("wound_modifier", 0) == 1, "Deadly Stalkers grants +1 to Wound when no other enemy unit is within six inches")
	for model: int in C.living(attack_state, other_enemy): attack_state.units[model].position = Vector2(5.5, float(model % 12) * 2.5)
	var supported_target_plan := C.AttackPlan.prepare(attack_state, squad, false, [{"model": attack_scout, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "standard"}], true)
	check(str(supported_target_plan.get("error", "")).is_empty() and supported_target_plan.batches[0].context.get("wound_modifier", 0) == 0, "Deadly Stalkers does not apply when another enemy unit is within six inches")

	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.setup_players = []
	var live_scout := model_with_role(state, squad, "Wolf Scout")
	for model: int in models_for(state, squad): state.units[model].position = Vector2(-18.0, float(model % 6) * 3.0)
	state.units[live_scout].position = Vector2(-4.0, 0.0)
	for index in range(C.living(state, target).size()): state.units[C.living(state, target)[index]].position = Vector2(0.0, float(index) * 2.5)
	var mine_choice: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "haywire-mine" and int(option.get("target", -1)) == target: mine_choice = option; break
	var mine_result := PublicUnitCommand.submit(state, 1, mine_choice, Vector2.ZERO, func() -> int: return 6)
	check(not mine_choice.is_empty() and str(mine_result.get("error", "")).is_empty() and state.last_incursor_haywire_mine.datasheet == UNIT and state.last_incursor_haywire_mine.damage.expression == "D3" and state.last_incursor_haywire_mine.mortal_wounds == 3, "The equipped mine uses unit-wide visibility and range, then deals D3 to a non-Vehicle")
	check(state.unit_abilities.window.get("kind", "") == Incursors.MINE_WINDOW, "Wolf Scouts mortal wounds enter the shared defender-allocation window")
	check(C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "haywire-mine" and int(option.get("target", -1)) == target).is_empty(), "Haywire Mine is once per battle per unit")

	print("Wolf Scouts checks: %d failures" % failures)
	quit(1 if failures else 0)

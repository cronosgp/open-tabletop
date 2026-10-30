extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var source := Catalog.new()
	root.add_child(source)
	source.cache_directory = "res://.tools/retired-api-cache"
	Roster.write_json(source.cache_directory.path_join("11e.json"), {"canary": "External API cache must not be loaded or rewritten"})
	var cache_before := FileAccess.get_file_as_string(source.cache_directory.path_join("11e.json"))
	check(source.select_edition("11e").is_empty() and not source.catalog.units.is_empty(), "Local catalog loads without an API/cache")
	check(source.catalog.units.size() == 185 and source.excluded.size() == 5, "The 85 shared-book and 76 Chapter profiles plus twenty-four locally checked Legends profiles publish; four historical datasheets and the conflicting Decimus size are excluded (got %d selectable, %d excluded: %s)" % [source.catalog.units.size(), source.excluded.size(), str(source.excluded)])
	var mutable_profile := Catalog.Current.profile("high-marshal-helbrecht")
	mutable_profile.stats.toughness = 99
	mutable_profile.ranged.clear()
	var mutable_profile_catalog := Catalog.Current.catalog()
	mutable_profile_catalog.erase("high-marshal-helbrecht")
	var pristine_profile := Catalog.Current.profile("high-marshal-helbrecht")
	check(pristine_profile.stats.toughness == 5 and pristine_profile.ranged.size() == 1 and Catalog.Current.catalog().has("high-marshal-helbrecht"), "Cached profile reads remain isolated from caller mutation")
	check(not source.excluded.has("aethon-shaan") and Catalog.Current.profile("aethon-shaan").source_datasheet_id == "000004148", "Locally checked Aethon Shaan is admitted from the Wahapedia source profile")
	check(not source.excluded.has("stormtalon-gunship") and Catalog.Current.profile("stormtalon-gunship").source_datasheet_id == "000001190", "Locally checked Stormtalon Gunship is admitted from the Wahapedia source profile")
	check(not source.excluded.has("rhino-primaris") and Catalog.Current.profile("rhino-primaris").source_datasheet_id == "000000085" and Catalog.Current.profile("rhino-primaris").get("fourth_plus_points_by_models", {}).is_empty(), "Rhino Primaris is admitted from its Legends sheet without inheriting the common Rhino fourth-copy price")
	check(not source.excluded.has("dreadnought") and Catalog.Current.profile("dreadnought").source_datasheet_id == "000000117", "Locally checked Dreadnought Legends is admitted from its Wahapedia source profile")
	check(not source.excluded.has("venerable-dreadnought-legends") and Catalog.Current.profile("venerable-dreadnought-legends").source_datasheet_id == "000000120" and Catalog.Current.profile("venerable-dreadnought").source_datasheet_id == "000002801", "The separate Legends Venerable Dreadnought sheet is admitted without replacing the Space Wolves profile")
	check(not source.excluded.has("fenrisian-wolves") and Catalog.Current.profile("fenrisian-wolves").source_datasheet_id == "000000323", "Fenrisian Wolves is admitted from its source-bounded Space Wolves profile")
	check(not source.excluded.has("wolf-guard-terminators") and Catalog.Current.profile("wolf-guard-terminators").source_datasheet_id == "000000318", "Wolf Guard Terminators is admitted from its source-bounded Space Wolves profile")
	check(not source.excluded.has("thunderwolf-cavalry") and Catalog.Current.profile("thunderwolf-cavalry").source_datasheet_id == "000000322", "Thunderwolf Cavalry is admitted from its source-bounded Space Wolves profile")
	check(not source.excluded.has("wulfen") and Catalog.Current.profile("wulfen").source_datasheet_id == "000000311", "Wulfen is admitted from its source-bounded Space Wolves profile")
	check(not source.excluded.has("wulfen-with-storm-shields") and Catalog.Current.profile("wulfen-with-storm-shields").source_datasheet_id == "000004132", "Wulfen with Storm Shields is admitted from its source-bounded Space Wolves profile")
	check(not source.excluded.has("hammerfall-bunker") and Catalog.Current.profile("hammerfall-bunker").source_datasheet_id == "000000097", "Hammerfall Bunker is admitted as a source-bounded Warhammer Legends profile")
	var hammerfall_record: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "hammerfall-bunker")[0]
	check(hammerfall_record.source_scope == "Warhammer Legends" and hammerfall_record.options == [{"models": 1, "cost": 175, "second_plus_cost": 175, "third_plus_cost": 175}] and hammerfall_record.scope.contains("organiser approval") and hammerfall_record.scope.contains("120 mm"), "Hammerfall construction publishes exact copy-tier cost, Legends event policy and footprint boundary")
	check(Roster.catalog_error(source.catalog).is_empty(), "Local catalog preserves roster schema")
	var digest: String = source.catalog.digest
	for unit: Dictionary in source.catalog.units:
		var identity: String = unit.source_id
		check(Catalog.Capabilities.SPECS[identity].get("current_reference", false) and Catalog.Capabilities.SPECS[identity].get("validation_status", "") not in ["tests_written_not_run", "local_checks_pending"], "Only reconciled profiles without pending validation are offered")
		var profile := Catalog.Current.profile(identity)
		for option: Dictionary in unit.options:
			check(profile.points_by_models[option.models] == option.cost, "Sizes/prices come from the implemented profile")
			if profile.get("third_plus_points_by_models", {}).has(option.models): check(option.get("third_plus_cost", -1) == profile.third_plus_points_by_models[option.models], "Third-plus prices publish from the same local profile")
			if profile.get("fourth_plus_points_by_models", {}).has(option.models): check(option.get("fourth_plus_cost", -1) == profile.fourth_plus_points_by_models[option.models], "Fourth-plus prices publish from the same local profile")
	var published_sources: Array[String] = []
	for unit: Dictionary in source.catalog.units: published_sources.append(str(unit.source_id))
	check("deathwatch-veterans" in published_sources, "Locally source-bounded Deathwatch Veterans enter the construction catalog")
	check("deathwatch-terminator-squad" in published_sources, "Locally source-bounded Deathwatch Terminator Squad enters the construction catalog")
	check("blood-claws" in published_sources, "Blood Claws enters the consolidated current construction catalog")
	check("grey-hunters" in published_sources, "Grey Hunters enters the consolidated current construction catalog")
	check("wolf-guard-terminators" in published_sources, "Wolf Guard Terminators enters the consolidated current construction catalog")
	check("wolf-scouts" in published_sources, "Source-bounded Wolf Scouts enters the consolidated current construction catalog")
	check("arjac-rockfist" in published_sources, "Source-bounded Arjac Rockfist enters the consolidated current construction catalog")
	check("logan-grimnar" in published_sources, "Source-bounded Logan Grimnar enters the consolidated current construction catalog")
	check("njal-stormcaller" in published_sources, "Source-bounded Njal Stormcaller enters the consolidated current construction catalog")
	check("ragnar-blackmane" in published_sources, "Source-bounded Ragnar Blackmane enters the consolidated current construction catalog")
	check("ulrik-the-slayer" in published_sources, "Source-bounded Ulrik the Slayer enters the consolidated current construction catalog")
	check("iron-priest" in published_sources, "Source-bounded Iron Priest enters the consolidated current construction catalog")
	check("wolf-guard-battle-leader" in published_sources, "Source-bounded Wolf Guard Battle Leader enters the consolidated current construction catalog")
	check("fortis-kill-team" in published_sources, "Locally source-bounded Fortis Kill Team enters the construction catalog")
	check("talonstrike-kill-team" in published_sources, "Locally source-bounded Talonstrike Kill Team enters the construction catalog")
	check("indomitor-kill-team" in published_sources, "Locally source-bounded Indomitor Kill Team enters the construction catalog")
	var decimus: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "decimus-kill-team")[0]
	check("decimus-kill-team" in published_sources and decimus.options == [{"models": 10, "cost": 210}] and source.excluded.get("decimus-kill-team/5-models", "").contains("conflict") and str(decimus.scope).contains("six-model minimum") and str(decimus.scope).contains("MFM v1.0") and str(decimus.scope).contains("190 pts"), "Decimus construction exposes its Wahapedia-sized roster and warns that the current GW MFM uses a different price")
	var headtakers: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "wolf-guard-headtakers")[0]
	var headtaker_models: Array[int] = []
	var headtaker_costs: Array[int] = []
	for option: Dictionary in headtakers.options:
		headtaker_models.append(int(option.models))
		headtaker_costs.append(int(option.cost))
	check(headtaker_models == [6, 12] and headtaker_costs == [115, 230] and str(headtakers.scope).contains("other allowed mixes have no confirmed cost"), "Headtakers exposes only priced compatible mixes and explains the remaining unpriced legal mixes")
	var crusaders: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "crusader-squad")[0]
	check(str(crusaders.scope).contains("bounded") and str(crusaders.scope).contains("Righteous Zeal") and str(crusaders.scope).contains("MFM v1.0") and str(crusaders.scope).contains("10/150"), "Crusader Squad exposes its bounded placement coverage and Wahapedia/MFM price difference")
	var partial_status := "source_bounded_local_scope_partial_2026_10_30"
	check(Catalog.Capabilities.SPECS["crusader-squad"].validation_status == partial_status and Catalog.Capabilities.SPECS["decimus-kill-team"].validation_status == "source_bounded_wahapedia_configuration_passed_2026_10_30_points_crosscheck_conflict" and Catalog.Capabilities.SPECS["wolf-guard-headtakers"].validation_status == partial_status, "Only unresolved Crusader routing, Decimus official-points reconciliation and Headtakers composition/base scopes remain qualified")
	check(not source.excluded.has("crusader-squad") and not source.excluded.has("decimus-kill-team") and not source.excluded.has("wolf-guard-headtakers"), "Partial status does not hide legal, source-priced configurations; their specific blockers remain in construction scope notes")
	check("infiltrator-squad" in published_sources and "lieutenant-in-phobos-armour" in published_sources and "captain-in-gravis-armour" in published_sources and "ancient-in-terminator-armour" in published_sources and "desolation-squad" in published_sources and "kaius-konorius" in published_sources and "librarian" in published_sources and "aethon-shaan" in published_sources and "death-company-captain" in published_sources and "death-company-captain-with-jump-pack" in published_sources and "astorath" in published_sources and "lemartes" in published_sources, "Locally validated Space Marine additions enter the construction catalog")
	check("assault-intercessors-with-jump-packs" in published_sources, "Locally validated Jump Pack datasheet enters construction")
	check("captain-with-jump-pack" in published_sources, "Locally validated Jump Pack Captain enters construction")
	check("sanguinary-guard" in published_sources, "Locally validated Sanguinary Guard enters construction")
	check("thunderwolf-cavalry" in published_sources, "Locally validated Thunderwolf Cavalry enters construction")
	check("wulfen" in published_sources, "Locally validated Wulfen enters construction")
	check("wulfen-with-storm-shields" in published_sources, "Locally validated Wulfen with Storm Shields enters construction")
	check("adrax-agatone" in published_sources, "Locally validated Adrax Agatone enters construction")
	check("librarian-in-phobos-armour" in published_sources, "Locally validated Phobos Librarian enters construction")
	check("captain-in-phobos-armour" in published_sources, "Locally validated Phobos Captain enters construction")
	check("rhino" in published_sources, "Locally validated Rhino enters construction")
	check("land-raider" in published_sources and "land-raider-crusader" in published_sources and "land-raider-redeemer" in published_sources and "drop-pod" in published_sources and "impulsor" in published_sources and "repulsor" in published_sources and "repulsor-executioner" in published_sources, "Locally reconciled transport sheets enter construction")
	check("captain" in published_sources, "Locally validated current-reference Captain enters construction")
	check("watch-master" in published_sources, "Source-bounded Watch Master enters the consolidated current construction catalog")
	check("blood-angels-captain" in published_sources, "Locally source-bounded Blood Angels Captain enters construction")
	check("sanguinary-priest" in published_sources, "Locally source-bounded Sanguinary Priest enters construction")
	check("baal-predator" in published_sources, "Locally source-bounded Baal Predator enters construction")
	check("the-sanguinor" in published_sources, "Locally source-bounded The Sanguinor enters construction")
	check("high-marshal-helbrecht" in published_sources, "Locally validated High Marshal Helbrecht enters construction")
	check("invader-atvs" in published_sources, "Locally validated Invader ATVs enter construction")
	check("tor-garadon" in published_sources, "Locally validated Tor Garadon enters construction")
	check("darnath-lysander" in published_sources, "Locally validated Darnath Lysander enters construction")
	check("suboden-khan" in published_sources, "Locally validated Suboden Khan enters construction")
	check("iron-father-feirros" in published_sources and "caanok-var" in published_sources and "chief-librarian-tigurius" in published_sources and "kayvaan-shrike" in published_sources and "cato-sicarius" in published_sources and "victrix-honour-guard" in published_sources and "marneus-calgar" in published_sources and "kor-sarro-khan" in published_sources and "captain-titus" in published_sources and "wardens-of-ultramar" in published_sources, "Locally reconciled chapter characters, Wardens, Victrix Honour Guard, Marneus Calgar, Kor'sarro Khan and Captain Titus enter construction")
	check("assault-intercessor-squad" in published_sources, "Locally validated Assault Intercessor enters construction")
	check("intercessor-squad" in published_sources, "Locally validated Intercessor Squad enters construction")
	check("heavy-intercessor-squad" in published_sources, "Locally validated Heavy Intercessor Squad enters construction")
	check("terminator-squad" in published_sources, "Locally validated Terminator Squad enters construction")
	check("outrider-squad" in published_sources, "Locally validated Outrider Squad enters construction")
	check("gladiator-reaper" in published_sources, "Locally validated Gladiator Reaper enters construction")
	check("gladiator-valiant" in published_sources, "Locally validated Gladiator Valiant enters construction")
	check("gladiator-lancer" in published_sources, "Locally validated Gladiator Lancer enters construction")
	check("land-speeder" in published_sources, "Locally validated Land Speeder enters construction")
	check("chaplain-on-bike" in published_sources, "Locally validated Chaplain on Bike enters construction")
	check("terminator-assault-squad" in published_sources, "Locally validated Terminator Assault Squad enters construction")
	check("captain-on-bike" in published_sources, "Locally validated Captain on Bike enters construction")
	check("storm-speeder-hammerstrike" in published_sources, "Locally validated Storm Speeder Hammerstrike enters construction")
	check("storm-speeder-hailstrike" in published_sources, "Locally validated Storm Speeder Hailstrike enters construction")
	check("storm-speeder-thunderstrike" in published_sources, "Locally validated Storm Speeder Thunderstrike enters construction")
	check("inceptor-squad" in published_sources, "Locally validated Inceptor Squad enters construction")
	check("incursor-squad" in published_sources, "Locally validated Incursor Squad enters construction")
	check("reiver-squad" in published_sources, "Locally validated Reiver Squad enters construction")
	check("firestrike-servo-turrets" in published_sources, "Locally validated Firestrike Servo-turrets enter construction")
	check("tarantula-air-defence-battery" in published_sources, "Locally validated Tarantula Air Defence Battery enters construction as a labelled Legends profile")
	var tarantula_record: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "tarantula-air-defence-battery")[0]
	check(tarantula_record.source_scope == "Warhammer Legends" and tarantula_record.options == [{"models": 1, "cost": 70}] and tarantula_record.scope.contains("organiser approval"), "The Legends catalog record exposes its only priced size and use conditions")
	check("rapier-carrier" in published_sources, "Locally validated Rapier Carrier enters construction as a labelled Legends profile")
	var rapier_record: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "rapier-carrier")[0]
	check(rapier_record.source_scope == "Warhammer Legends" and rapier_record.options == [{"models": 1, "cost": 90}] and rapier_record.scope.contains("organiser approval") and rapier_record.scope.contains("footprint"), "The Rapier Legends catalog record publishes the source price and event/footprint conditions")
	check("tarantula-sentry-battery" in published_sources, "Locally validated Tarantula Sentry Battery enters construction as a labelled Legends profile")
	var tarantula_sentry_record: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "tarantula-sentry-battery")[0]
	check(tarantula_sentry_record.source_scope == "Warhammer Legends" and tarantula_sentry_record.options == [{"models": 1, "cost": 30}, {"models": 2, "cost": 60}, {"models": 3, "cost": 90}] and tarantula_sentry_record.scope.contains("organiser approval") and tarantula_sentry_record.scope.contains("footprint"), "The Sentry Battery exposes all three source-priced sizes and its Legends/footprint conditions")
	check("centurion-assault-squad" in published_sources, "Locally validated Centurion Assault Squad enters construction as a labelled Legends profile")
	var centurion_assault_record: Dictionary = source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "centurion-assault-squad")[0]
	check(centurion_assault_record.source_scope == "Warhammer Legends" and centurion_assault_record.options == [{"models": 3, "cost": 150}, {"models": 6, "cost": 300}] and centurion_assault_record.scope.contains("organiser approval") and centurion_assault_record.scope.contains("EXPLOSIVES"), "Centurion Assault construction publishes legal sizes, exact points, event status and the launcher keyword rule")
	check("ballistus-dreadnought" in published_sources, "Locally validated Ballistus Dreadnought enters construction")
	check("redemptor-dreadnought" in published_sources, "Locally validated Redemptor Dreadnought enters construction")
	check("brutalis-dreadnought" in published_sources, "Locally validated Brutalis Dreadnought enters construction")
	check("invictor-tactical-warsuit" in published_sources, "Locally validated Invictor Tactical Warsuit enters construction")
	check("lieutenant-with-combi-weapon" in published_sources, "Locally validated Combi-weapon Lieutenant enters construction")
	check("techmarine" in published_sources, "Locally validated Techmarine enters construction")
	check("roboute-guilliman" in published_sources and source.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.source_id == "roboute-guilliman")[0].options.size() == 1, "Wahapedia-priced Guilliman enters construction as one fixed 415-point model")
	check(source.excluded.has("necron-warriors") and not source.excluded.has("intercessor-squad") and not source.excluded.has("techmarine") and not source.excluded.has("lieutenant-with-combi-weapon"), "Unreconciled and historical profiles remain excluded explicitly")
	check(source.supports_size("40kdc:11e:adeptus-astartes:intercessor-squad", 5) and not source.supports_size("openhammer:11e:Space%20Marines:8da0-4570-c3c-819f", 5), "Current local entries are selectable while prior OpenHammer Intercessor lists remain labeled legacy drafts")
	source.refresh()
	check(source.catalog.digest == digest and not source.busy and source.get_child_count() == 0, "Reload is deterministic and creates no HTTP request")
	check(FileAccess.get_file_as_string(source.cache_directory.path_join("11e.json")) == cache_before, "Local provider does not rewrite retired API caches")
	check(not source.select_edition("10e").is_empty() and source.catalog.is_empty(), "Earlier-edition construction stays unavailable")
	source.select_edition("11e")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var panel = game.army_builder
	check(panel.source.catalog.provider == "Consolidated local runtime", "Workshop uses the local provider")
	panel._new_empty()
	var tarantula_ui_index := -1
	for index in panel.unit_picker.item_count:
		var candidate: Dictionary = panel.unit_picker.get_item_metadata(index)
		if candidate.get("source_id", "") == "tarantula-air-defence-battery": tarantula_ui_index = index
	check(tarantula_ui_index >= 0 and panel.unit_picker.get_item_text(tarantula_ui_index).contains("Warhammer Legends"), "The unit picker visibly distinguishes the Legends datasheet")
	check(panel._model_count_label(1) == "1 model" and panel._model_count_label(2) == "2 models", "Roster model counts use the correct singular and plural labels")
	if tarantula_ui_index >= 0:
		panel.unit_picker.select(tarantula_ui_index)
		panel._select_unit(tarantula_ui_index)
		check(panel.construction_scope_hint.visible and panel.construction_scope_hint.text.contains("competitive events require organiser approval"), "The selected datasheet shows the use and geometry boundary")
		panel._add()
		check(panel.draft.entries.size() == 1 and panel.draft.entries[0].get("source_scope", "") == "Warhammer Legends" and panel.entries.get_item_text(0).contains("Warhammer Legends") and panel.entries.get_item_text(0).contains("1 model") and not panel.entries.get_item_text(0).contains("1 models"), "The draft roster keeps the Legends label and correct singular count next to the unit")
	panel._new_empty()
	var rapier_ui_index := -1
	for index in panel.unit_picker.item_count:
		var candidate: Dictionary = panel.unit_picker.get_item_metadata(index)
		if candidate.get("source_id", "") == "rapier-carrier": rapier_ui_index = index
	check(rapier_ui_index >= 0 and panel.unit_picker.get_item_text(rapier_ui_index).contains("Warhammer Legends"), "The unit picker visibly labels Rapier Carrier as a Legends datasheet")
	if rapier_ui_index >= 0:
		panel.unit_picker.select(rapier_ui_index)
		panel._select_unit(rapier_ui_index)
		check(panel.construction_scope_hint.visible and panel.construction_scope_hint.text.contains("competitive events require organiser approval") and panel.construction_scope_hint.text.contains("60 mm"), "The selected Rapier shows its event and footprint boundaries")
		panel._add()
		check(panel.draft.entries.size() == 1 and panel.draft.entries[0].get("source_scope", "") == "Warhammer Legends" and panel.entries.get_item_text(0).contains("90 pts"), "The builder admits the Rapier Carrier as one correctly priced Legends model")
	panel._new_empty()
	var tarantula_sentry_ui_index := -1
	for index in panel.unit_picker.item_count:
		var candidate: Dictionary = panel.unit_picker.get_item_metadata(index)
		if candidate.get("source_id", "") == "tarantula-sentry-battery": tarantula_sentry_ui_index = index
	check(tarantula_sentry_ui_index >= 0 and panel.unit_picker.get_item_text(tarantula_sentry_ui_index).contains("Warhammer Legends"), "The builder labels the new Tarantula Sentry profile as Legends")
	if tarantula_sentry_ui_index >= 0:
		panel.unit_picker.select(tarantula_sentry_ui_index)
		panel._select_unit(tarantula_sentry_ui_index)
		check(panel.choice_picker.item_count == 3 and panel.construction_scope_hint.visible and panel.construction_scope_hint.text.contains("competitive events require organiser approval") and panel.construction_scope_hint.text.contains("60 mm"), "The selected Sentry Battery exposes 1/2/3-model sizes and its game-use/footprint note")
		panel.choice_picker.select(2)
		panel._refresh_addition_summary()
		panel._add()
		check(panel.draft.entries.size() == 1 and panel.draft.entries[0].models == 3 and panel.draft.entries[0].cost == 90 and panel.entries.get_item_text(0).contains("Warhammer Legends"), "The builder adds the source-priced 3-model Legends composition")
	panel._new_empty()
	var hammerfall_ui_index := -1
	for index in panel.unit_picker.item_count:
		var candidate: Dictionary = panel.unit_picker.get_item_metadata(index)
		if candidate.get("source_id", "") == "hammerfall-bunker": hammerfall_ui_index = index
	check(hammerfall_ui_index >= 0 and panel.unit_picker.get_item_text(hammerfall_ui_index).contains("Warhammer Legends"), "The builder labels Hammerfall Bunker as a Legends datasheet")
	if hammerfall_ui_index >= 0:
		panel.unit_picker.select(hammerfall_ui_index)
		panel._select_unit(hammerfall_ui_index)
		check(panel.choice_picker.item_count == 1 and panel.construction_scope_hint.visible and panel.construction_scope_hint.text.contains("competitive events require organiser approval") and panel.construction_scope_hint.text.contains("120 mm"), "Hammerfall selection shows its single-model price and game-use/footprint conditions")
		panel._add()
		check(panel.draft.entries.size() == 1 and panel.draft.entries[0].models == 1 and panel.draft.entries[0].cost == 175 and panel.draft.entries[0].get("source_scope", "") == "Warhammer Legends" and panel.entries.get_item_text(0).contains("175 pts") and panel.entries.get_item_text(0).contains("Warhammer Legends"), "The builder admits the 175-point Hammerfall Bunker with its Legends label")
	panel._new_empty()
	var first: Dictionary = panel.source.catalog.units[0]
	panel.unit_picker.clear()
	panel.unit_picker.add_item(first.name)
	panel.unit_picker.set_item_metadata(0, first)
	panel._select_unit(0)
	panel._add()
	check(panel.draft.entries.size() == 1 and panel.source.contains(panel.draft.entries[0].unit_id), "Workshop adds a supported local entry")
	var fake := first.duplicate(true)
	fake.id = "unimplemented:external:unit"
	panel.selected_unit = fake
	panel.choice_picker.add_item("Synthetic unsupported composition")
	var before := var_to_str(panel.draft)
	panel._add()
	check(var_to_str(panel.draft) == before and "outside the consolidated" in panel.notice.text, "Unsupported metadata cannot be submitted as a new unit")
	var legacy := first.duplicate(true)
	legacy.id = "legacy:external:unit"
	panel.draft.entries.append(Roster.entry(legacy, 0))
	panel._render_draft()
	check(panel.catalog_boundary.visible and "legacy draft" in panel.catalog_boundary.text, "Existing out-of-scope entries are explicitly isolated")
	print("Implemented catalog: %d selectable, %d excluded; %d failures" % [source.catalog.get("units", []).size(), source.excluded.size(), failures])
	quit(0 if failures == 0 else 1)

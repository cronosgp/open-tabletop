extends RefCounted
## Second half of source-bounded Orks App v1.2 runtime catalog. Raw exports remain under .tools/.
const SNAPSHOT_ID := "20261031T053336Z"
const EXPORT_UPDATED_AT := "2026-10-30T22:19:16+03:00"
const SOURCE_BOOK_ID := "000000046"
const SOURCE_BOOK_VERSION := "1.2"
const PARENT_MANIFEST_SHA256 := "e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef"
const SLICE_MANIFEST_SHA256 := "e1b230898eedfa32c66ec839812270a6a3fc364eee9b95732585c204cf9d40f1"
const SLICE_CATALOG_SHA256 := "23d403a227ecaaeedd0c78492e0210e5f0b347f78faaee7549dee2d4a3bd9cb9"
const SOURCE_FILE_SHA256 := {"Factions.csv": "5d6fa825d2c7e8934c64cf4d85696cfea98b6e981d06103eb250ac7df2947535", "Source.csv": "20177d38c72e09e3c7a3976f197581c9258eee704433e1196e90e9664ed6e102", "Datasheets.csv": "353a6c7f769435cc4c3ff5b932a39e3b7bbbc9ed58c0f5316f1b60e98b2cd620", "Datasheets_abilities.csv": "6e68866cd1cd64096380367fd1dd957fb7c7cf64f220aaf9d660c4db1281c513", "Datasheets_keywords.csv": "3a5cd3e2b170831e830ef2189cbf3a7dff9caf817c26219f793ebe34f12e0131", "Datasheets_models.csv": "e4282a1be0b643fbf437c465aaf8c336a4bbb22ed4e5114217d836d5eacb614f", "Datasheets_options.csv": "680fabab698203695614252b649baa03a693298453f668ce07426587ce93a0f7", "Datasheets_wargear.csv": "9fdc42b03f27174ca1fc5664a59aa356b089cd34c14061849fab3251758d4863", "Datasheets_unit_composition.csv": "db79eb633bc6ee8164448e659b38bd35c7cde535d79fa1ba7ffbc35d66f4f319", "Datasheets_models_cost.csv": "2e677a38bf3036645a0efed691785c2b939c0c26a20c0da07929e60bcd59f657", "Datasheets_stratagems.csv": "1b4b75d1018bfed807224e99ce18728bf503eb924714c0abddd170486e46e46b", "Datasheets_enhancements.csv": "3325055b51af129796e79d735a18a4fb80967f3ac3ada346d6d897bfa7de1446", "Datasheets_detachment_abilities.csv": "2cbcff8d7eab717d5097c36cdddef581a5a922ac36510b1fcd6b7a697b7c4795", "Datasheets_leader.csv": "0cc428cab9808e9431fadb5eeab8c3e389a30308be8f18b635bc6c840672df77"}

static func profile(source: String) -> Dictionary:
	if source == "morkanaut":
		var rec := _record("morkanaut", "Morkanaut", "000000042", "Morkanaut", {1: 345}, 1, 170.0,
			{"movement_inches": 9, "toughness": 12, "save_target": 2, "wounds": 20, "leadership_target": 7, "objective_control": 8, "invulnerable_target": 5},
			["ORKS", "WALKER", "TRANSPORT", "TITANIC", "VEHICLE", "TOWERING"],
			[{"id": "dual-big-shoota", "profiles": {"standard": _weapon("Dual Big Shoota", 36.0, 6, 4, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}, {"id": "kustom-mega-blasta", "profiles": {"standard": _weapon("Kustom Mega-blasta", 24.0, 3, 4, 9, -2, 3, {"hazardous": true})}}, {"id": "kustom-mega-zappa", "profiles": {"standard": _weapon("Kustom Mega-zappa", 36.0, 3, 4, 12, -2, 4, {"blast": 1, "hazardous": true})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 4, 5, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 4, 10, -2, 3, {})}}],
			[{"id": "klaw-of-mork", "profiles": {"standard": _weapon("Klaw of Mork", 0.0, 5, 3, 18, -3, 6, {"cleave": 2})}}],
			["Damaged", "Deadly Demise", "Super-heavy Walker", "Waaagh!", "Gut Hatch", "Big an’ Shooty"],
			["waaagh"], [], [], [], [], {1: 375})
		rec.base_size_source_note = "170 x 109mm (170 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "7"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000010844", "name": "Super-heavy Walker", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Gut Hatch", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Big an’ Shooty", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "gorkanaut":
		var rec := _record("gorkanaut", "Gorkanaut", "000000043", "Gorkanaut", {1: 325}, 1, 170.0,
			{"movement_inches": 9, "toughness": 12, "save_target": 2, "wounds": 20, "leadership_target": 7, "objective_control": 8, "invulnerable_target": 6},
			["ORKS", "WALKER", "TOWERING", "TITANIC", "VEHICLE", "TRANSPORT"],
			[{"id": "deffstorm-mega-shoota", "profiles": {"aimed": _weapon("Deffstorm Mega-shoota - Aimed", 36.0, 20, 5, 6, -1, 1, {"lethal-hits-non-monster-vehicle": true}), "point-blank": _weapon("Deffstorm Mega-shoota - Point Blank", 12.0, "3D6", "-", 6, -1, 1, {"torrent": true})}}, {"id": "dual-big-shoota", "profiles": {"standard": _weapon("Dual Big Shoota", 36.0, 6, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 5, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {})}}, {"id": "skorcha", "profiles": {"standard": _weapon("Skorcha", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}],
			[{"id": "klaw-of-gork", "profiles": {"standard": _weapon("Klaw of Gork", 0.0, 6, 3, 18, -3, 6, {"cleave": 3})}}],
			["Damaged", "Deadly Demise", "Super-heavy Walker", "Waaagh!", "Gut Hatch", "Big an’ Stompy"],
			["waaagh"], [], [], [], [], {1: 355})
		rec.base_size_source_note = "170 x 109mm (170 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "7"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000010844", "name": "Super-heavy Walker", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Gut Hatch", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Big an’ Stompy", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "flash-gitz":
		var rec := _record("flash-gitz", "Flash Gitz", "000000045", "Flash-Gitz", {5: 110, 10: 220}, 5, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 3, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "EXPLOSIVES", "INFANTRY"],
			[{"id": "snazzgun", "profiles": {"cutta": _weapon("Snazzgun - Cutta", 12.0, 1, 4, 9, -3, "D3+2", {"hazardous": true, "melta": 2}), "dakka": _weapon("Snazzgun - Dakka", 24.0, 3, 4, 6, -1, 2, {"lethal-hits-non-monster-vehicle": true, "sustained-hits": 1}), "kill-shot": _weapon("Snazzgun - Kill Shot", 36.0, 2, 4, 8, -2, 2, {"hazardous": true})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 4, 3, 5, -1, 1, {})}}],
			["Waaagh!", "Finderz Keeperz"],
			["waaagh"], [], ["000000012", "000000013", "000003707"], [], [], {5: 150, 10: 260})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Finderz Keeperz", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "stompa":
		var rec := _record("stompa", "Stompa", "000000046", "Stompa", {1: 700}, 1, 120.0,
			{"movement_inches": 10, "toughness": 14, "save_target": 2, "wounds": 30, "leadership_target": 6, "objective_control": 12, "invulnerable_target": 5},
			["ORKS", "VEHICLE", "FRAME", "TITANIC", "TOWERING", "TRANSPORT", "WALKER"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "deffkannon-and-supa-rokkits", "profiles": {"standard": _weapon("Deffkannon and Supa-rokkits", 72.0, 12, 5, 14, -3, "D6+2", {"blast": 2})}}, {"id": "skorcha", "profiles": {"standard": _weapon("Skorcha", 12.0, 3, "-", 5, -1, 1, {"blast": 2, "torrent": true})}}, {"id": "supa-gatler", "profiles": {"aimed": _weapon("Supa-gatler - Aimed", 24.0, 30, 5, 7, -2, 2, {"lethal-hits-non-monster-vehicle": true, "sustained-hits": 1}), "point-blank": _weapon("Supa-gatler - Point Blank", 12.0, "3D6+3", "-", 7, -2, 2, {"torrent": true})}}],
			[{"id": "mega-choppa", "profiles": {"standard": _weapon("Mega-choppa", 0.0, 6, 3, 24, -4, 10, {"cleave": 4})}}],
			["Damaged", "Deadly Demise", "Super-heavy Walker", "Waaagh!", "Idol of Belligerence", "Waaagh! Effigy"],
			["waaagh"], [], [], [], [], {})
		rec.second_plus_points_by_models = {1: 800}
		rec.base_size_source_note = "Use model (120 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "10"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "2D6"}, {"source_line": 3, "ability_id": "000010844", "name": "Super-heavy Walker", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Idol of Belligerence", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Waaagh! Effigy", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "big-mek-with-shokk-attack-gun":
		var rec := _record("big-mek-with-shokk-attack-gun", "Big Mek With Shokk Attack Gun", "000001536", "Big-Mek-With-Shokk-Attack-Gun", {1: 110}, 1, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 5, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "EXPLOSIVES", "CHARACTER", "BIG MEK", "INFANTRY"],
			[{"id": "shokk-attack-gun", "profiles": {"standard": _weapon("Shokk Attack Gun", 60.0, "D3+3", 5, 12, -4, "D6+1", {"blast": 1, "heavy": true})}}],
			[{"id": "big-meks-toolz", "profiles": {"standard": _weapon("Big Mek’s Toolz", 0.0, 4, 3, 5, 0, 1, {})}}],
			["Leader", "Waaagh!", "More Dakka", "Support Shokka"],
			["waaagh"], [], [], ["000000016", "000000020", "000000021", "000000038"], [], {})
		rec.second_plus_points_by_models = {1: 125}
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "More Dakka", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Support Shokka", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "deffkilla-wartrike":
		var rec := _record("deffkilla-wartrike", "Deffkilla Wartrike", "000001537", "Deffkilla-Wartrike", {1: 80}, 1, 150.0,
			{"movement_inches": 12, "toughness": 6, "save_target": 4, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
			["ORKS", "WARBOSS", "SPEED FREEKS", "CHARACTER", "MOUNTED"],
			[{"id": "boomstikks", "profiles": {"standard": _weapon("Boomstikks", 12.0, 6, 5, 5, 0, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "snagga-klaw", "profiles": {"standard": _weapon("Snagga Klaw", 12.0, 1, 5, 7, -2, 2, {"assault": true, "precision": true})}}],
			[{"id": "killa-jet", "profiles": {"burna": _weapon("Killa Jet - Burna", 0.0, 3, 3, 5, -1, 1, {"cleave": 1, "extra-attacks": true}), "cutta": _weapon("Killa Jet - Cutta", 0.0, 1, 3, 10, -3, "D6+2", {"extra-attacks": true})}}, {"id": "snagga-klaw", "profiles": {"standard": _weapon("Snagga Klaw", 0.0, 5, 2, 7, -2, 2, {"cleave": 2})}}],
			["Deadly Demise", "Leader", "Da Boss", "Waaagh!", "Get Back in da Race! (Once per battle round, per army)", "Fuel-mixa Grot"],
			["waaagh"], [], [], ["000000033"], [], {})
		rec.base_size_source_note = "150 x 95mm (150 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Get Back in da Race! (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Fuel-mixa Grot", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "zodgrod-wortsnagga":
		var rec := _record("zodgrod-wortsnagga", "Zodgrod Wortsnagga", "000002488", "Zodgrod-Wortsnagga", {1: 50}, 1, 50.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 5, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 6},
			["ORKS", "CHARACTER", "RUNTHERD", "INFANTRY", "EPIC HERO"],
			[{"id": "squigstoppa", "profiles": {"standard": _weapon("Squigstoppa", 12.0, 1, 5, 4, -1, 1, {"anti-monster": 4, "anti-vehicle": 4, "close-quarters": true, "devastating-wounds-monster-vehicle": true})}}],
			[{"id": "da-grabzappa", "profiles": {"standard": _weapon("Da Grabzappa", 0.0, 5, 2, 7, -2, 2, {})}}],
			["Leader", "Waaagh!", "Super Runts"],
			["waaagh"], [], [], ["000000017"], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Super Runts", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "beastboss":
		var rec := _record("beastboss", "Beastboss", "000002489", "Beastboss", {1: 85}, 1, 50.0,
			{"movement_inches": 6, "toughness": 6, "save_target": 4, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
			["ORKS", "INFANTRY", "WARBOSS", "CHARACTER", "BEAST SNAGGA"],
			[{"id": "shoota", "profiles": {"standard": _weapon("Shoota", 18.0, 2, 4, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}],
			[{"id": "beast-snagga-klaw-and-beastchoppa", "profiles": {"standard": _weapon("Beast Snagga Klaw and Beastchoppa", 0.0, 6, 2, 12, -2, 2, {"sustained-hits-monster-vehicle": 2})}}],
			["Feel No Pain", "Leader", "Da Boss", "Waaagh!", "Keep Huntin’! (Once per battle round, per army)", "Dodge Dis!"],
			["waaagh"], [], [], ["000002494"], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "6+"}, {"source_line": 2, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Keep Huntin’! (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Dodge Dis!", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "beastboss-on-squigosaur":
		var rec := _record("beastboss-on-squigosaur", "Beastboss on Squigosaur", "000002490", "Beastboss-on-Squigosaur", {1: 140}, 1, 80.0,
			{"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5},
			["ORKS", "WARBOSS", "MONSTER", "BEAST SNAGGA", "CHARACTER"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "thump-gun", "profiles": {"standard": _weapon("Thump Gun", 18.0, 3, 5, 6, 0, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			[{"id": "beastchoppa", "profiles": {"standard": _weapon("Beastchoppa - Standard", 0.0, 6, 2, 6, -2, 2, {"cleave": 1}), "hunter": _weapon("Beastchoppa - Hunter", 0.0, 6, 2, 12, -2, "D6", {})}}, {"id": "squigosaurs-jaws", "profiles": {"standard": _weapon("Squigosaur’s Jaws", 0.0, 3, 3, 7, -2, 3, {"anti-monster": 3, "anti-vehicle": 3, "extra-attacks": true})}}],
			["Feel No Pain", "Da Boss", "Waaagh!", "Thundering Stampede (Aura)", "Keep Huntin’! (Once per battle round, per army)", "Boss of da Hunt"],
			["waaagh"], [], [], [], [], {1: 155})
		rec.source_option_descriptions = ["This model can be equipped with 1 Thump Gun."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "5+"}, {"source_line": 2, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Thundering Stampede (Aura)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Keep Huntin’! (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Boss of da Hunt", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "painboss":
		var rec := _record("painboss", "Painboss", "000002491", "Painboss", {1: 60}, 1, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 4, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 6},
			["ORKS", "INFANTRY", "BEAST SNAGGA", "CHARACTER"],
			[],
			[{"id": "beast-snagga-klaw", "profiles": {"standard": _weapon("Beast Snagga Klaw", 0.0, 3, 3, 10, -2, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			["Support", "Waaagh!", "Push Dat Bit Back In (Once per battle, per unit)", "Hardy Bioniks", "Runnin’ wiv da Herd"],
			["waaagh"], [], [], ["000002494", "000002496"], [], {1: 70})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Push Dat Bit Back In (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Hardy Bioniks", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Runnin’ wiv da Herd", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "mozrog-skragbad":
		var rec := _record("mozrog-skragbad", "Mozrog Skragbad", "000002493", "Mozrog-Skragbad", {1: 170}, 1, 80.0,
			{"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
			["ORKS", "MONSTER", "BEAST SNAGGA", "EPIC HERO", "CHARACTER"],
			[{"id": "thump-gun", "profiles": {"standard": _weapon("Thump Gun", 18.0, 3, 5, 6, 0, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			[{"id": "big-chompas-jaws", "profiles": {"standard": _weapon("Big Chompa’s Jaws", 0.0, 3, 3, 7, -2, 4, {"anti-monster": 3, "anti-vehicle": 3, "extra-attacks": true})}}, {"id": "gutrippa", "profiles": {"standard": _weapon("Gutrippa - Standard", 0.0, 6, 2, 9, -2, 2, {"cleave": 1}), "hunter": _weapon("Gutrippa - Hunter", 0.0, 6, 2, 12, -2, "D6+1", {"lethal-hits": true})}}],
			["Feel No Pain", "Waaagh!", "One Last Kill", "Da Bigger Dey Iz…", "Beast Snagga Following"],
			["waaagh"], [], [], [], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "5+"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "One Last Kill", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Da Bigger Dey Iz…", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Beast Snagga Following", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "beast-snagga-boyz":
		var rec := _record("beast-snagga-boyz", "Beast Snagga Boyz", "000002494", "Beast-Snagga-Boyz", {10: 80, 20: 160}, 10, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "INFANTRY", "BEAST SNAGGA", "MOB", "BATTLELINE"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "thump-gun", "profiles": {"standard": _weapon("Thump Gun", 18.0, 3, 5, 6, 0, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa - Standard", 0.0, 3, 3, 5, -1, 1, {}), "hunter": _weapon("Choppa - Hunter", 0.0, 3, 3, 6, -2, 1, {})}}, {"id": "power-snappa", "profiles": {"standard": _weapon("Power Snappa", 0.0, 3, 3, 8, -2, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			["Waaagh!", "Mobbed"],
			["waaagh"], [], ["000000004", "000002489", "000002491"], [], [], {})
		rec.fourth_plus_points_by_models = {10: 90, 20: 170}
		rec.source_option_descriptions = ["For every 10 models in this unit, 1 Beast Snagga Boy model can be equipped with 1 Thump Gun."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Mobbed", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "squighog-boyz":
		var rec := _record("squighog-boyz", "Squighog Boyz", "000002496", "Squighog-Boyz", {4: 130, 8: 260}, 4, 75.0,
			{"movement_inches": 10, "toughness": 6, "save_target": 4, "wounds": 3, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "BEAST SNAGGA", "EXPLOSIVES", "MOBILE", "MOUNTED"],
			[{"id": "saddlegits-shiv", "profiles": {"standard": _weapon("Saddlegit’s Shiv", 9.0, 1, 4, 3, 0, 1, {"assault": true})}}, {"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "stikka", "profiles": {"standard": _weapon("Stikka", 9.0, 1, 5, 5, -1, 2, {"anti-monster": 4, "anti-vehicle": 4, "assault": true})}}],
			[{"id": "big-choppa", "profiles": {"standard": _weapon("Big Choppa", 0.0, 4, 3, 7, -1, 2, {"anti-monster": 4, "anti-vehicle": 4, "cleave": 2})}}, {"id": "squigs-jaws", "profiles": {"standard": _weapon("Squig’s Jaws", 0.0, 3, 4, 6, -1, 2, {"extra-attacks": true})}}, {"id": "stikka", "profiles": {"standard": _weapon("Stikka", 0.0, 3, 3, 5, -1, 2, {"anti-monster": 4, "anti-vehicle": 4})}}],
			["Waaagh!", "Bomb Squig (Once per battle, per unit)", "Brutal Impact"],
			["waaagh"], [], ["000002491"], [], [], {4: 160, 8: 290})
		rec.base_size_source_note = "75 x 42mm (75 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Bomb Squig (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Brutal Impact", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "kill-rig":
		var rec := _record("kill-rig", "Kill Rig", "000002497", "Kill-Rig", {1: 175}, 1, 170.0,
			{"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 16, "leadership_target": 7, "objective_control": 5, "invulnerable_target": 6},
			["ORKS", "TRANSPORT", "PSYKER", "WAGON", "MONSTER", "BEAST SNAGGA"],
			[{"id": "eavy-lobba", "profiles": {"standard": _weapon("’Eavy Lobba", 48.0, 3, 5, 6, 0, 2, {"blast": 2, "indirect-fire": true})}}, {"id": "stikka-kannon", "profiles": {"standard": _weapon("Stikka Kannon", 12.0, 1, 5, 12, -2, 3, {"anti-monster": 2, "anti-vehicle": 2})}}, {"id": "wurrtower", "profiles": {"standard": _weapon("Wurrtower", 24.0, 1, "-", 12, -3, 6, {"hazardous": true, "psychic": true, "torrent": true})}}],
			[{"id": "butcha-boyz", "profiles": {"standard": _weapon("Butcha Boyz", 0.0, 4, 3, 5, -1, 1, {"anti-monster": 4, "anti-vehicle": 4, "extra-attacks": true})}}, {"id": "savage-horns-and-hooves", "profiles": {"standard": _weapon("Savage Horns and Hooves", 0.0, 4, 4, 8, -1, 3, {"extra-attacks": true, "lance": true})}}, {"id": "saw-blades", "profiles": {"standard": _weapon("Saw Blades", 0.0, 6, 3, 10, -2, 2, {"cleave": 1, "extra-attacks": true})}}],
			["Damaged", "Deadly Demise", "Feel No Pain", "Unstable Energies", "Waaagh!", "Wurrboy (psyker level 1)", "Beastscent (psychic level 1)", "Warpath (psychic level 1)"],
			["waaagh"], [], [], [], [], {1: 195})
		rec.base_size_source_note = "170 x 109mm (170 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "6"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "5+"}, {"source_line": 4, "ability_id": "000011127", "name": "Unstable Energies", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Wurrboy (psyker level 1)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Beastscent (psychic level 1)", "model_role": "", "type": "Psychic", "parameter": ""}, {"source_line": 8, "ability_id": "", "name": "Warpath (psychic level 1)", "model_role": "", "type": "Psychic", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "hunta-rig":
		var rec := _record("hunta-rig", "Hunta Rig", "000002498", "Hunta-Rig", {1: 165}, 1, 170.0,
			{"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 16, "leadership_target": 7, "objective_control": 5, "invulnerable_target": 6},
			["ORKS", "BEAST SNAGGA", "TRANSPORT", "WAGON", "MONSTER"],
			[{"id": "eavy-lobba", "profiles": {"standard": _weapon("’Eavy Lobba", 48.0, 3, 5, 6, 0, 2, {"blast": 2, "indirect-fire": true})}}, {"id": "stikka-kannon", "profiles": {"standard": _weapon("Stikka Kannon", 12.0, 1, 5, 12, -2, 3, {"anti-monster": 2, "anti-vehicle": 2})}}],
			[{"id": "butcha-boyz", "profiles": {"standard": _weapon("Butcha Boyz", 0.0, 4, 3, 5, -1, 1, {"anti-monster": 4, "anti-vehicle": 4})}}, {"id": "savage-horns-and-hooves", "profiles": {"standard": _weapon("Savage Horns and Hooves", 0.0, 4, 4, 8, -1, 3, {"extra-attacks": true, "lance": true})}}, {"id": "saw-blades", "profiles": {"standard": _weapon("Saw Blades", 0.0, 6, 3, 10, -2, 2, {"cleave": 1, "extra-attacks": true})}}],
			["Damaged", "Deadly Demise", "Feel No Pain", "Firing Deck", "Waaagh!", "Fully Loaded Butchery", "Tramplasquig Charge"],
			["waaagh"], [], [], [], [], {1: 185})
		rec.base_size_source_note = "170 x 109mm (170 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "6"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000008338", "name": "Feel No Pain", "model_role": "", "type": "Core", "parameter": "5+"}, {"source_line": 4, "ability_id": "000008334", "name": "Firing Deck", "model_role": "", "type": "Core", "parameter": "11"}, {"source_line": 5, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Fully Loaded Butchery", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Tramplasquig Charge", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "biged-bossbunka":
		var rec := _record("biged-bossbunka", "Big’ed Bossbunka", "000002499", "Big-ed-Bossbunka", {1: 135}, 1, 60.0,
			{"movement_inches": 0, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 0},
			["ORKS", "VEHICLE", "FORTIFICATION", "FRAME", "TRANSPORT"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "gaze-of-gork", "profiles": {"glare": _weapon("Gaze of Gork - Glare", 24.0, 3, 5, 5, 0, 1, {"blast": 1}), "squint": _weapon("Gaze of Gork - Squint", 18.0, 1, 5, 12, -3, 3, {})}}],
			[],
			["Deadly Demise", "Firing Deck", "Waaagh!", "Raucous Occupants", "Fortification", "Ramshackle Cover"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "Use model (60 mm circular proxy)"
		rec.source_option_descriptions = ["This model can be equipped with up to 3 Big Shootas."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 2, "ability_id": "000008334", "name": "Firing Deck", "model_role": "", "type": "Core", "parameter": "11"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Raucous Occupants", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Fortification", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Ramshackle Cover", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "big-mek":
		var rec := _record("big-mek", "Big Mek", "000003707", "Big-Mek", {1: 100}, 1, 50.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 6, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "CHARACTER", "EXPLOSIVES"],
			[{"id": "kustom-mega-blasta", "profiles": {"standard": _weapon("Kustom Mega-blasta", 24.0, 3, 4, 9, -2, 3, {"hazardous": true})}}, {"id": "traktor-blasta", "profiles": {"standard": _weapon("Traktor Blasta", 24.0, 3, 4, 6, -2, "D3+3", {"anti-fly": 2})}}],
			[{"id": "drilla", "profiles": {"standard": _weapon("Drilla", 0.0, 3, 3, 12, -3, 3, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 5, 3, 10, -2, 2, {})}}],
			["Leader", "Waaagh!", "More Dakka", "Shokk-boosta"],
			["waaagh"], [], [], ["000000016", "000000020", "000000021", "000000038", "000000045", "000003861"], [], {1: 115})
		rec.source_option_descriptions = ["This model’s Power Klaw can be replaced with 1 Drilla.", "This model’s Kustom Mega-blasta can be replaced with 1 Traktor Blasta."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "More Dakka", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Shokk-boosta", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "breaka-boyz":
		var rec := _record("breaka-boyz", "Breaka Boyz", "000003861", "Breaka-Boyz", {6: 120}, 6, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "EXPLOSIVES"],
			[{"id": "rokkit-pistol", "profiles": {"standard": _weapon("Rokkit Pistol", 12.0, 1, 5, 10, -2, 3, {"close-quarters": true})}}],
			[{"id": "smash-hammer", "profiles": {"standard": _weapon("Smash Hammer - Standard", 0.0, 3, 3, 7, -2, 2, {}), "hunter": _weapon("Smash Hammer - Hunter", 0.0, 3, 3, 12, -2, 3, {})}}, {"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 4, 3, 5, -1, 1, {})}}, {"id": "knucklebustas", "profiles": {"standard": _weapon("Knucklebustas", 0.0, 4, 3, 5, -2, 2, {"anti-monster": 4, "anti-vehicle": 4})}}, {"id": "tankhammer", "profiles": {"standard": _weapon("Tankhammer", 0.0, 3, 4, 12, -2, 3, {"devastating-wounds": true, "hazardous": true})}}],
			["Waaagh!", "Bomb Squigs (Once per turn, twice per battle, per unit)", "Trophy Hunters"],
			["waaagh"], [], ["000000001", "000000013", "000003707", "000004228"], [], [], {6: 130})
		rec.source_option_descriptions = ["The Nob can have their Smash Hammer replaced with 1 Rokkit Pistol.", "1 Breaka Boy model can have their Smash Hammer replaced with 1 Knucklebustas.", "1 Breaka Boy model can have their Smash Hammer replaced with 1 Tankhammer."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Bomb Squigs (Once per turn, twice per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Trophy Hunters", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "wazdakka-gutsmek":
		var rec := _record("wazdakka-gutsmek", "Wazdakka Gutsmek", "000004221", "Wazdakka-Gutsmek", {1: 200}, 1, 120.0,
			{"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4},
			["ORKS", "CHARACTER", "VEHICLE", "MOUNTED", "SPEED FREEKS", "SMOKE", "EPIC HERO"],
			[{"id": "grabba-dragga", "profiles": {"standard": _weapon("Grabba Dragga", 12.0, 1, 2, 10, -2, 3, {"assault": true, "precision": true})}}, {"id": "psyko-gatler", "profiles": {"standard": _weapon("Psyko-gatler", 24.0, 12, 4, 6, -2, 2, {"assault": true, "lethal-hits-non-monster-vehicle": true, "sustained-hits": 1})}}],
			[{"id": "speeding-bulk-and-flaming-exhaust", "profiles": {"standard": _weapon("Speeding Bulk and Flaming Exhaust", 0.0, 3, 2, 5, -1, 1, {"cleave": 1, "extra-attacks": true})}}, {"id": "fixits-wrench", "profiles": {"standard": _weapon("Fixit’s Wrench", 0.0, 1, 4, 3, 0, 1, {"extra-attacks": true})}}, {"id": "grabba-dragga", "profiles": {"standard": _weapon("Grabba Dragga", 0.0, 6, 2, 10, -2, 3, {"cleave": 2, "lance": true})}}],
			["Deadly Demise", "Deep Strike", "Lone Operative", "Waaagh!", "Full Throttle", "Turbo Engine", "Shokk Attack Engine", "Pulse Jet"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "120 x 92mm (120 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 2, "ability_id": "000008343", "name": "Deep Strike", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000008336", "name": "Lone Operative", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Full Throttle", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Turbo Engine", "model_role": "", "type": "Primarch", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Shokk Attack Engine", "model_role": "", "type": "Primarch", "parameter": ""}, {"source_line": 8, "ability_id": "", "name": "Pulse Jet", "model_role": "", "type": "Primarch", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "bannernob":
		var rec := _record("bannernob", "Bannernob", "000004227", "Bannernob", {1: 30}, 1, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 4, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 5},
			["ORKS", "CHARACTER", "INFANTRY"],
			[{"id": "shoota", "profiles": {"standard": _weapon("Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}],
			[{"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}],
			["Support", "Waaagh!", "Waaagh! Banner"],
			["waaagh"], [], [], ["000000016", "000000021"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Waaagh! Banner", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "bigboss":
		var rec := _record("bigboss", "Bigboss", "000004228", "Bigboss", {1: 50}, 1, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 5, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "CHARACTER", "INFANTRY"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "big-choppa", "profiles": {"standard": _weapon("Big Choppa", 0.0, 5, 3, 7, -2, 2, {"precision": true})}}],
			["Support", "Waaagh!", "Sumfin’ to Prove"],
			["waaagh"], [], [], ["000000016", "000000021", "000003861"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Sumfin’ to Prove", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "big-mek-dakkarig":
		var rec := _record("big-mek-dakkarig", "Big Mek Dakkarig", "000004229", "Big-Mek-Dakkarig", {1: 160}, 1, 90.0,
			{"movement_inches": 8, "toughness": 8, "save_target": 3, "wounds": 11, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 5},
			["ORKS", "VEHICLE", "WALKER", "CHARACTER", "BIG MEK"],
			[{"id": "blitzkannon", "profiles": {"standard": _weapon("Blitzkannon", 24.0, 8, 4, 7, -2, 2, {"ignores-cover": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "multi-busta-launcha", "profiles": {"standard": _weapon("Multi-busta Launcha", 24.0, 6, 5, 10, -2, 3, {"ignores-cover": true, "lethal-hits": true})}}],
			[{"id": "stompy-feet", "profiles": {"standard": _weapon("Stompy Feet", 0.0, 4, 3, 6, -1, 1, {})}}],
			["Deadly Demise", "Waaagh!", "Even More Dakka", "Blitz Dem Gitz!"],
			["waaagh"], [], [], [], [], {1: 180})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Even More Dakka", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Blitz Dem Gitz!", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "runtherd":
		var rec := _record("runtherd", "Runtherd", "000004239", "Runtherd", {1: 10}, 1, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 3, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "CHARACTER"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "runtherds-toolz", "profiles": {"standard": _weapon("Runtherd’s Toolz", 0.0, 3, 3, 5, 0, 1, {})}}],
			["Support", "Waaagh!", "That’ll Learn Ya (Once per battle round, per unit)"],
			["waaagh"], [], [], ["000000017"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "That’ll Learn Ya (Once per battle round, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "wartrakks":
		var rec := _record("wartrakks", "Wartrakks", "000004240", "Wartrakks", {1: 70, 2: 130}, 1, 105.0,
			{"movement_inches": 12, "toughness": 6, "save_target": 4, "wounds": 7, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 6},
			["ORKS", "MOUNTED", "SPEED FREEKS"],
			[{"id": "kustom-shoota", "profiles": {"standard": _weapon("Kustom Shoota", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "multi-busta-launcha", "profiles": {"standard": _weapon("Multi-busta Launcha", 24.0, "D3+3", 5, 10, -2, 3, {})}}],
			[{"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}],
			["Waaagh!", "Speednob Support", "Bust ’Em"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "105 x 70mm (105 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Speednob Support", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Bust ’Em", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "gunwagon":
		var rec := _record("gunwagon", "Gunwagon", "000004241", "Gunwagon", {1: 150}, 1, 60.0,
			{"movement_inches": 10, "toughness": 12, "save_target": 3, "wounds": 16, "leadership_target": 7, "objective_control": 5, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "FRAME", "TRANSPORT", "WAGON"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "kannon", "profiles": {"frag": _weapon("Kannon - Frag", 36.0, 4, 4, 5, 0, 1, {"blast": 3, "rapid-fire": 4}), "shell": _weapon("Kannon - Shell", 36.0, 2, 4, 10, -2, "D6+1", {"rapid-fire": 2})}}, {"id": "killkannon", "profiles": {"standard": _weapon("Killkannon", 24.0, 4, 4, 6, -3, 2, {"anti-infantry": 3, "blast": 1, "rapid-fire": 4})}}, {"id": "lobba", "profiles": {"standard": _weapon("Lobba", 48.0, 3, 4, 5, 0, 1, {"blast": 3, "indirect-fire": true})}}, {"id": "zzap-gun", "profiles": {"standard": _weapon("Zzap Gun", 36.0, 2, 4, 8, -2, 4, {"anti-monster": 4, "anti-vehicle": 4, "devastating-wounds-monster-vehicle": true, "rapid-fire": 2, "sustained-hits": 2})}}],
			[{"id": "crushin-bulk", "profiles": {"standard": _weapon("Crushin’ Bulk", 0.0, 6, 3, 8, -2, 2, {"cleave": 2})}}, {"id": "grabbin-klaw", "profiles": {"standard": _weapon("Grabbin’ Klaw", 0.0, 2, 3, 10, -2, 2, {"extra-attacks": true})}}, {"id": "wreckin-ball", "profiles": {"standard": _weapon("Wreckin’ Ball", 0.0, 1, 3, 10, 0, "D6", {"cleave": 2, "extra-attacks": true})}}],
			["Damaged", "Deadly Demise", "Waaagh!", "Mobile Arsenal"],
			["waaagh"], [], [], [], [], {1: 160})
		rec.wargear_costs = {"zzap-gun": 10}
		rec.base_size_source_note = "Use model (60 mm circular proxy)"
		rec.source_option_descriptions = ["This model can be equipped with 1 Wreckin’ Ball.", "This model can be equipped with 1 Grabbin’ Klaw.", "This model can be equipped with 1 Lobba.", "This model can be equipped with up to 4 Big Shoota.", "This model’s Kannon can be replaced with one of the following: 1 Killkannon 1 Zzap Gun"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "6"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Mobile Arsenal", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "nazdreg":
		var rec := _record("nazdreg", "Nazdreg", "000004242", "Nazdreg", {1: 165}, 1, 60.0,
			{"movement_inches": 5, "toughness": 7, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
			["ORKS", "INFANTRY", "CHARACTER", "EPIC HERO", "WARBOSS", "MEGA ARMOUR"],
			[{"id": "kustom-blasta-x", "profiles": {"gatler": _weapon("Kustom Blasta X - Gatler", 24.0, 6, 4, 9, -2, 3, {"hazardous": true}), "shoota": _weapon("Kustom Blasta X - Shoota", 18.0, 4, 4, 5, -1, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2}), "skorcha": _weapon("Kustom Blasta X - Skorcha", 12.0, 3, "-", 5, -1, 1, {"blast": 1, "torrent": true})}}],
			[{"id": "kustom-blasta-x", "profiles": {"standard": _weapon("Kustom Blasta X", 0.0, 6, 2, 5, -1, 1, {"cleave": 1, "extra-attacks": true})}}, {"id": "moonchewa", "profiles": {"standard": _weapon("Moonchewa", 0.0, 5, 2, 12, -2, 3, {"cleave": 1, "twin-linked": true})}}],
			["Deep Strike", "Leader", "Da Boss", "Waaagh!", "Intimidating Motivation (Once per battle round, per army)", "Nazdreg’s Know-wotz", "Supreme Kunnin’ (Once per phase, per army)"],
			["waaagh"], [], [], ["000000024"], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008343", "name": "Deep Strike", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Intimidating Motivation (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Nazdreg’s Know-wotz", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Supreme Kunnin’ (Once per phase, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "rukkatrukk-squigbuggies":
		var rec := _record("rukkatrukk-squigbuggies", "Rukkatrukk Squigbuggies", "000004243", "Rukkatrukk-Squigbuggies", {1: 85, 2: 160}, 1, 150.0,
			{"movement_inches": 12, "toughness": 7, "save_target": 4, "wounds": 9, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 6},
			["ORKS", "SPEED FREEKS", "EXPLOSIVES", "VEHICLE"],
			[{"id": "sawn-off-shotgun", "profiles": {"standard": _weapon("Sawn-off Shotgun", 12.0, 2, 5, 4, 0, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true})}}, {"id": "squig-launchas", "profiles": {"standard": _weapon("Squig Launchas", 24.0, "D6+6", 4, 5, -1, 2, {"ignores-cover": true})}}],
			[{"id": "saw-blades", "profiles": {"standard": _weapon("Saw Blades", 0.0, 4, 3, 7, -1, 2, {"cleave": 1})}}],
			["Deadly Demise", "Waaagh!", "Squig Barrage"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "150 x 95mm (150 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Squig Barrage", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	return {}

static func catalog() -> Dictionary:
	var result := {}
	for slug: String in ["morkanaut", "gorkanaut", "flash-gitz", "stompa", "big-mek-with-shokk-attack-gun", "deffkilla-wartrike", "zodgrod-wortsnagga", "beastboss", "beastboss-on-squigosaur", "painboss", "mozrog-skragbad", "beast-snagga-boyz", "squighog-boyz", "kill-rig", "hunta-rig", "biged-bossbunka", "big-mek", "breaka-boyz", "wazdakka-gutsmek", "bannernob", "bigboss", "big-mek-dakkarig", "runtherd", "wartrakks", "gunwagon", "nazdreg", "rukkatrukk-squigbuggies"]:
		result[slug] = profile(slug)
	return result

static func _record(source: String, display_name: String, datasheet_id: String, slug: String, costs: Dictionary, default_models: int, base_size_mm: float, stats: Dictionary, keywords: Array, ranged: Array, melee: Array, ability_names: Array, supported_rules: Array, unsupported_abilities: Array, leader_ids: Array, bodyguard_ids: Array = [], options: Array = [], third_plus_costs: Dictionary = {}) -> Dictionary:
	var result := {
		"name": display_name, "source_book_id": SOURCE_BOOK_ID, "source_book_version": SOURCE_BOOK_VERSION,
		"source_datasheet_id": datasheet_id, "source_snapshot_id": SNAPSHOT_ID, "source_export_updated_at": EXPORT_UPDATED_AT,
		"source_manifest_sha256": PARENT_MANIFEST_SHA256, "source_slice_manifest_sha256": SLICE_MANIFEST_SHA256,
		"source_slice_catalog_sha256": SLICE_CATALOG_SHA256, "source_file_sha256": SOURCE_FILE_SHA256.duplicate(true),
		"source_url": "https://wahapedia.ru/wh40k11ed/factions/orks/" + slug,
		"points": costs[default_models], "points_by_models": costs.duplicate(true), "construction_model_sizes": costs.keys(),
		"models": default_models, "base_size_source_mm": base_size_mm, "base_radius_inches": float(base_size_mm) / 50.8,
		"stats": stats.duplicate(true), "keywords": keywords.duplicate(), "ranged": ranged.duplicate(true), "melee": melee.duplicate(true),
		"source_ability_names": ability_names.duplicate(), "supported_rule_ids": supported_rules.duplicate(),
		"unsupported_abilities": unsupported_abilities.duplicate(), "source_scope": "Orks App v1.2"
	}
	if not leader_ids.is_empty(): result.source_leader_datasheet_ids = leader_ids.duplicate()
	if not bodyguard_ids.is_empty(): result.source_bodyguard_datasheet_ids = bodyguard_ids.duplicate()
	if not options.is_empty(): result.source_options = options.duplicate(true)
	if not third_plus_costs.is_empty(): result.third_plus_points_by_models = third_plus_costs.duplicate(true)
	if "EPIC HERO" in keywords: result.max_supported_copies = 1
	return result

static func _weapon(label: String, range_inches: float, attacks: Variant, skill: Variant, strength: int, ap: int, damage: Variant, keywords: Dictionary) -> Dictionary:
	return {"name": label, "range_inches": range_inches, "attacks": attacks, "skill": skill, "strength": strength, "ap": ap, "damage": damage, "keywords": keywords}

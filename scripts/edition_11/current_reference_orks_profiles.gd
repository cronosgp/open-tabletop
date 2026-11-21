extends RefCounted
## Source-bounded Orks App v1.2 runtime catalog (54 datasheets). Raw exports remain under .tools/.
const RemainingProfiles = preload("res://scripts/edition_11/current_reference_orks_remaining_profiles.gd")
const ID := "orks-e11-fixed-reference-2026-10-31-v1"
const SNAPSHOT_ID := "20261031T053336Z"
const EXPORT_UPDATED_AT := "2026-10-30T22:19:16+03:00"
const SOURCE_BOOK_ID := "000000046"
const SOURCE_BOOK_VERSION := "1.2"
const PARENT_MANIFEST_SHA256 := "e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef"
const SLICE_MANIFEST_SHA256 := "e1b230898eedfa32c66ec839812270a6a3fc364eee9b95732585c204cf9d40f1"
const SLICE_CATALOG_SHA256 := "23d403a227ecaaeedd0c78492e0210e5f0b347f78faaee7549dee2d4a3bd9cb9"
const SOURCE_FILE_SHA256 := {"Factions.csv": "5d6fa825d2c7e8934c64cf4d85696cfea98b6e981d06103eb250ac7df2947535", "Source.csv": "20177d38c72e09e3c7a3976f197581c9258eee704433e1196e90e9664ed6e102", "Datasheets.csv": "353a6c7f769435cc4c3ff5b932a39e3b7bbbc9ed58c0f5316f1b60e98b2cd620", "Datasheets_abilities.csv": "6e68866cd1cd64096380367fd1dd957fb7c7cf64f220aaf9d660c4db1281c513", "Datasheets_keywords.csv": "3a5cd3e2b170831e830ef2189cbf3a7dff9caf817c26219f793ebe34f12e0131", "Datasheets_models.csv": "e4282a1be0b643fbf437c465aaf8c336a4bbb22ed4e5114217d836d5eacb614f", "Datasheets_options.csv": "680fabab698203695614252b649baa03a693298453f668ce07426587ce93a0f7", "Datasheets_wargear.csv": "9fdc42b03f27174ca1fc5664a59aa356b089cd34c14061849fab3251758d4863", "Datasheets_unit_composition.csv": "db79eb633bc6ee8164448e659b38bd35c7cde535d79fa1ba7ffbc35d66f4f319", "Datasheets_models_cost.csv": "2e677a38bf3036645a0efed691785c2b939c0c26a20c0da07929e60bcd59f657", "Datasheets_stratagems.csv": "1b4b75d1018bfed807224e99ce18728bf503eb924714c0abddd170486e46e46b", "Datasheets_enhancements.csv": "3325055b51af129796e79d735a18a4fb80967f3ac3ada346d6d897bfa7de1446", "Datasheets_detachment_abilities.csv": "2cbcff8d7eab717d5097c36cdddef581a5a922ac36510b1fcd6b7a697b7c4795", "Datasheets_leader.csv": "0cc428cab9808e9431fadb5eeab8c3e389a30308be8f18b635bc6c840672df77"}

const SOURCE_SHEETS := {
	"warboss": {"id": "000000001", "name": "Warboss"},
	"warboss-in-mega-armour": {"id": "000000002", "name": "Warboss In Mega Armour"},
	"weirdboy": {"id": "000000004", "name": "Weirdboy"},
	"big-mek-in-mega-armour": {"id": "000000006", "name": "Big Mek In Mega Armour"},
	"ghazghkull-thraka": {"id": "000000008", "name": "Ghazghkull Thraka"},
	"boss-snikrot": {"id": "000000011", "name": "Boss Snikrot"},
	"mek": {"id": "000000012", "name": "Mek"},
	"painboy": {"id": "000000013", "name": "Painboy"},
	"boyz": {"id": "000000016", "name": "Boyz"},
	"gretchin": {"id": "000000017", "name": "Gretchin"},
	"tankbustas": {"id": "000000020", "name": "Tankbustas"},
	"nobz": {"id": "000000021", "name": "Nobz"},
	"meganobz": {"id": "000000024", "name": "Meganobz"},
	"kommandos": {"id": "000000025", "name": "Kommandos"},
	"trukk": {"id": "000000026", "name": "Trukk"},
	"stormboyz": {"id": "000000027", "name": "Stormboyz"},
	"deffkoptas": {"id": "000000028", "name": "Deffkoptas"},
	"dakkajet": {"id": "000000029", "name": "Dakkajet"},
	"burna-bommer": {"id": "000000030", "name": "Burna-bommer"},
	"blitza-bommer": {"id": "000000031", "name": "Blitza-bommer"},
	"wazbom-blastajet": {"id": "000000032", "name": "Wazbom Blastajet"},
	"warbikers": {"id": "000000033", "name": "Warbikers"},
	"warbuggies": {"id": "000000036", "name": "Warbuggies"},
	"mek-gunz": {"id": "000000038", "name": "Mek Gunz"},
	"battlewagon": {"id": "000000039", "name": "Battlewagon"},
	"deff-dread": {"id": "000000040", "name": "Deff Dread"},
	"killa-kans": {"id": "000000041", "name": "Killa Kans"},
	"morkanaut": {"id": "000000042", "name": "Morkanaut"},
	"gorkanaut": {"id": "000000043", "name": "Gorkanaut"},
	"flash-gitz": {"id": "000000045", "name": "Flash Gitz"},
	"stompa": {"id": "000000046", "name": "Stompa"},
	"big-mek-with-shokk-attack-gun": {"id": "000001536", "name": "Big Mek With Shokk Attack Gun"},
	"deffkilla-wartrike": {"id": "000001537", "name": "Deffkilla Wartrike"},
	"zodgrod-wortsnagga": {"id": "000002488", "name": "Zodgrod Wortsnagga"},
	"beastboss": {"id": "000002489", "name": "Beastboss"},
	"beastboss-on-squigosaur": {"id": "000002490", "name": "Beastboss on Squigosaur"},
	"painboss": {"id": "000002491", "name": "Painboss"},
	"mozrog-skragbad": {"id": "000002493", "name": "Mozrog Skragbad"},
	"beast-snagga-boyz": {"id": "000002494", "name": "Beast Snagga Boyz"},
	"squighog-boyz": {"id": "000002496", "name": "Squighog Boyz"},
	"kill-rig": {"id": "000002497", "name": "Kill Rig"},
	"hunta-rig": {"id": "000002498", "name": "Hunta Rig"},
	"biged-bossbunka": {"id": "000002499", "name": "Big’ed Bossbunka"},
	"big-mek": {"id": "000003707", "name": "Big Mek"},
	"breaka-boyz": {"id": "000003861", "name": "Breaka Boyz"},
	"wazdakka-gutsmek": {"id": "000004221", "name": "Wazdakka Gutsmek"},
	"bannernob": {"id": "000004227", "name": "Bannernob"},
	"bigboss": {"id": "000004228", "name": "Bigboss"},
	"big-mek-dakkarig": {"id": "000004229", "name": "Big Mek Dakkarig"},
	"runtherd": {"id": "000004239", "name": "Runtherd"},
	"wartrakks": {"id": "000004240", "name": "Wartrakks"},
	"gunwagon": {"id": "000004241", "name": "Gunwagon"},
	"nazdreg": {"id": "000004242", "name": "Nazdreg"},
	"rukkatrukk-squigbuggies": {"id": "000004243", "name": "Rukkatrukk Squigbuggies"}
}

static func inventory() -> Dictionary:
	return SOURCE_SHEETS.duplicate(true)

static func profile(source: String) -> Dictionary:
	if source == "warboss":
		var rec := _record("warboss", "Warboss", "000000001", "Warboss", {1: 100}, 1, 50.0,
			{"movement_inches": 6, "toughness": 6, "save_target": 4, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
			["ORKS", "WARBOSS", "INFANTRY", "EXPLOSIVES", "CHARACTER"],
			[{"id": "kombi-rokkit", "profiles": {"busta-rokkit": _weapon("Kombi-rokkit - Busta Rokkit", 24.0, 1, 5, 10, -2, 3, {}), "shoota": _weapon("Kombi-rokkit - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}, {"id": "kombi-skorcha", "profiles": {"shoota": _weapon("Kombi-skorcha - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1}), "skorcha": _weapon("Kombi-skorcha - Skorcha", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kustom-shoota", "profiles": {"standard": _weapon("Kustom Shoota", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}],
			[{"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 6, 2, 7, -2, 2, {"cleave": 2})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 6, 2, 12, -2, 2, {})}}],
			["Leader", "Da Boss", "Waaagh!", "Boss’ Ammo Runt (Once per battle, per unit)", "Might Is Right", "Intimidating Motivation (Once per battle round, per army)"],
			["waaagh"], [], [], ["000000016", "000000021", "000003861"], [], {})
		rec.source_option_descriptions = ["This model’s Kustom Choppa can be replaced with 1 Power Klaw.", "This model’s Kustom Shoota can be replaced with one of the following: 1 Kombi-rokkit 1 Kombi-skorcha"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Boss’ Ammo Runt (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Might Is Right", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Intimidating Motivation (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "warboss-in-mega-armour":
		var rec := _record("warboss-in-mega-armour", "Warboss In Mega Armour", "000000002", "Warboss-In-Mega-Armour", {1: 115}, 1, 50.0,
			{"movement_inches": 5, "toughness": 7, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
			["ORKS", "MEGA ARMOUR", "WARBOSS", "INFANTRY", "CHARACTER"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 4, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}],
			[{"id": "uge-choppa", "profiles": {"standard": _weapon("’Uge Choppa", 0.0, 5, 2, 12, -2, 3, {"cleave": 2})}}],
			["Leader", "Da Boss", "Waaagh!", "Krushin’ Impetus", "Intimidating Motivation (Once per battle round, per army)"],
			["waaagh"], [], [], ["000000024"], [], {1: 130})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Krushin’ Impetus", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Intimidating Motivation (Once per battle round, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "weirdboy":
		var rec := _record("weirdboy", "Weirdboy", "000000004", "Weirdboy", {1: 60}, 1, 50.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 4, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "PSYKER", "CHARACTER", "INFANTRY"],
			[{"id": "power-vomit", "profiles": {"standard": _weapon("Power Vomit", 12.0, 3, "-", 5, -3, 2, {"blast": 1, "hazardous": true, "psychic": true, "torrent": true})}}],
			[{"id": "copper-staff", "profiles": {"standard": _weapon("Copper Staff", 0.0, 3, 3, 8, -1, 2, {"psychic": true})}}],
			["Deadly Demise", "Support", "Unstable Energies", "Waaagh!", "Waaagh! Energy (psyker level 1)", "Da Jump (psychic level 1, once per army, per battle round)", "Warpath (psychic level 1)"],
			["waaagh"], [], [], ["000000016", "000002494"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 2, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000011127", "name": "Unstable Energies", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Waaagh! Energy (psyker level 1)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Da Jump (psychic level 1, once per army, per battle round)", "model_role": "", "type": "Psychic", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Warpath (psychic level 1)", "model_role": "", "type": "Psychic", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "big-mek-in-mega-armour":
		var rec := _record("big-mek-in-mega-armour", "Big Mek In Mega Armour", "000000006", "Big-Mek-In-Mega-Armour", {1: 90}, 1, 40.0,
			{"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "BIG MEK", "CHARACTER", "EXPLOSIVES", "MEGA ARMOUR"],
			[{"id": "kombi-weapon", "profiles": {"shoota": _weapon("Kombi-weapon - Shoota", 18.0, 2, 4, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1}), "kill-shot": _weapon("Kombi-weapon - Kill Shot", 24.0, 1, 4, 10, -2, 3, {}), "point-blank": _weapon("Kombi-weapon - Point Blank", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kustom-mega-blasta", "profiles": {"standard": _weapon("Kustom Mega-blasta", 24.0, 3, 4, 9, -2, 3, {"hazardous": true})}}, {"id": "kustom-shoota", "profiles": {"aimed": _weapon("Kustom Shoota - Aimed", 18.0, 4, 4, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2}), "point-blank": _weapon("Kustom Shoota - Point Blank", 6.0, "D3+3", "-", 4, 0, 1, {"close-quarters": true, "torrent": true})}}, {"id": "tellyport-blasta", "profiles": {"standard": _weapon("Tellyport Blasta", 12.0, 6, 4, 9, -2, 3, {"blast": 1})}}],
			[{"id": "killsaw", "profiles": {"standard": _weapon("Killsaw", 0.0, 3, 4, 10, -2, 3, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Leader", "Waaagh!", "Fix Dat Armour Up (Once per battle, per unit)", "More Dakka", "Kustom Force Field"],
			["waaagh"], [], [], ["000000024", "000000038"], [], {})
		rec.source_option_descriptions = ["This model can be equipped with one of the following: 1 Tellyport Blasta 1 Kustom Force Field", "This model’s Kustom Shoota can be replaced with one of the following: 1 Killsaw 1 Kombi-weapon 1 Kustom Mega-blasta"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Fix Dat Armour Up (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "More Dakka", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Kustom Force Field", "model_role": "", "type": "Wargear", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "ghazghkull-thraka":
		var rec := _record("ghazghkull-thraka", "Ghazghkull Thraka", "000000008", "Ghazghkull-Thraka", {1: 290}, 1, 80.0,
			{"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 16, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 4},
			["ORKS", "INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "WARBOSS"],
			[{"id": "morks-roar", "profiles": {"aimed": _weapon("Mork’s Roar - Aimed", 36.0, 12, 5, 6, -1, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4}), "point-blank": _weapon("Mork’s Roar - Point Blank", 9.0, "2D6+2", "-", 6, -1, 1, {"close-quarters": true, "torrent": true})}}],
			[{"id": "adamantine-eadbutt", "profiles": {"standard": _weapon("Adamantine ’Eadbutt", 0.0, 1, 2, 14, -2, "D3+3", {"devastating-wounds": true, "extra-attacks": true, "precision": true})}}, {"id": "gorks-klaw", "profiles": {"standard": _weapon("Gork’s Klaw", 0.0, 7, 2, 14, -3, 4, {"cleave": 2, "devastating-wounds": true})}}],
			["Da Boss", "Waaagh!", "Da Grand Warlord's Ladz", "Makari, Hoist Dat Banner! (Once per battle, per army)", "Prophet of da Great Waaagh! (Aura)", "SUPREME COMMANDER"],
			["waaagh"], [], [], [], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011126", "name": "Da Boss", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Da Grand Warlord's Ladz", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Makari, Hoist Dat Banner! (Once per battle, per army)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Prophet of da Great Waaagh! (Aura)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "SUPREME COMMANDER", "model_role": "", "type": "Fortification (левая колонка)", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "boss-snikrot":
		var rec := _record("boss-snikrot", "Boss Snikrot", "000000011", "Boss-Snikrot", {1: 80}, 1, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 5},
			["ORKS", "INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "SMOKE"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true, "precision": true})}}],
			[{"id": "morks-teef", "profiles": {"standard": _weapon("Mork’s Teef", 0.0, 6, 2, 6, -2, 2, {"anti-infantry": 2, "precision": true})}}],
			["Infiltrators", "Leader", "Lone Operative", "Stealth", "Waaagh!", "Kunnin’ Infiltrator", "Deff from the Shadows (First battle round onwards)"],
			["waaagh"], [], [], ["000000025"], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008345", "name": "Infiltrators", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000008346", "name": "Leader", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000008336", "name": "Lone Operative", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 4, "ability_id": "000008337", "name": "Stealth", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 5, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Kunnin’ Infiltrator", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Deff from the Shadows (First battle round onwards)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "mek":
		var rec := _record("mek", "Mek", "000000012", "Mek", {1: 55}, 1, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 4, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "EXPLOSIVES", "INFANTRY", "CHARACTER"],
			[{"id": "kustom-mega-slugga", "profiles": {"standard": _weapon("Kustom Mega-slugga", 12.0, 3, 4, 8, -2, 3, {"close-quarters": true, "hazardous": true})}}],
			[{"id": "meks-toolz", "profiles": {"standard": _weapon("Mek’s Toolz", 0.0, 3, 3, 5, 0, 1, {})}}],
			["Support", "Waaagh!", "Kustom Dakka", "Clever Know-wotz"],
			["waaagh"], [], [], ["000000016", "000000020", "000000021", "000000038", "000000045"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Kustom Dakka", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Clever Know-wotz", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "painboy":
		var rec := _record("painboy", "Painboy", "000000013", "Painboy", {1: 45}, 1, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 3, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "CHARACTER"],
			[],
			[{"id": "urty-syringe", "profiles": {"standard": _weapon("’Urty Syringe", 0.0, 1, 3, 2, 0, "D6", {"anti-infantry": 4, "devastating-wounds-infantry": true, "extra-attacks": true})}}, {"id": "doks-toolz", "profiles": {"standard": _weapon("Dok’s Toolz", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Support", "Waaagh!", "Crude Surgery", "Catch Dat Red Bit (Once per battle, per unit)"],
			["waaagh"], [], [], ["000000016", "000000020", "000000021", "000000045", "000003861"], [], {})
		rec.source_is_support = true
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000010857", "name": "Support", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Crude Surgery", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Catch Dat Red Bit (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "boyz":
		var rec := _record("boyz", "Boyz", "000000016", "Boyz", {10: 85, 20: 170}, 10, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "BATTLELINE", "EXPLOSIVES", "MOB"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "burna", "profiles": {"standard": _weapon("Burna", 12.0, 3, "-", 4, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kombi-rokkit", "profiles": {"busta-rokkit": _weapon("Kombi-rokkit - Busta Rokkit", 24.0, 1, 5, 10, -2, 3, {}), "shoota": _weapon("Kombi-rokkit - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}, {"id": "kombi-skorcha", "profiles": {"shoota": _weapon("Kombi-skorcha - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1}), "skorcha": _weapon("Kombi-skorcha - Skorcha", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kustom-shoota", "profiles": {"standard": _weapon("Kustom Shoota", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 4, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {})}}, {"id": "shoota", "profiles": {"standard": _weapon("Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}, {"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "big-choppa", "profiles": {"standard": _weapon("Big Choppa", 0.0, 4, 3, 7, -1, 2, {"cleave": 2})}}, {"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 3, 3, 5, -1, 1, {})}}, {"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Waaagh!", "Ammo Runts (Once per battle, per unit)", "Tide of Muscle", "Never Too Busy to Fight"],
			["waaagh"], [], ["000000001", "000000004", "000000012", "000000013", "000001536", "000003707", "000004227", "000004228"], [], [], {})
		rec.fourth_plus_points_by_models = {10: 95, 20: 180}
		rec.source_option_descriptions = ["Any number of Nob models can each have their Kustom Choppa and Kombi-skorcha replaced with 1 Big Choppa.", "Any number of Nob models can each have their Kustom Choppa replaced with 1 Power Klaw.", "Any number of Nob models can each have their Kombi-skorcha replaced with one of the following: 1 Kombi-rokkit 1 Kustom Shoota", "For every 10 models in this unit, 1 Boy model can have their Shoota replaced with 1 Big Shoota.", "For every 10 models in this unit, 1 Boy model can have their Shoota replaced with 1 Rokkit Launcha.", "For every 10 models in this unit, 1 Boy model can have their Shoota replaced with 1 Burna."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Ammo Runts (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Tide of Muscle", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Never Too Busy to Fight", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "gretchin":
		var rec := _record("gretchin", "Gretchin", "000000017", "Gretchin", {10: 45, 20: 80}, 10, 25.0,
			{"movement_inches": 6, "toughness": 2, "save_target": 6, "wounds": 1, "leadership_target": 8, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "GROTS"],
			[{"id": "grot-blasta", "profiles": {"standard": _weapon("Grot Blasta", 12.0, 1, 4, 3, 0, 1, {"close-quarters": true})}}],
			[{"id": "scavenged-shivs", "profiles": {"standard": _weapon("Scavenged Shivs", 0.0, 1, 5, 2, 0, 1, {})}}],
			["Waaagh!", "Downtrodden", "Thievin’ Scavengers"],
			["waaagh"], [], ["000002488", "000004239"], [], [], {})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Downtrodden", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Thievin’ Scavengers", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "tankbustas":
		var rec := _record("tankbustas", "Tankbustas", "000000020", "Tankbustas", {6: 160}, 6, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "EXPLOSIVES", "INFANTRY"],
			[{"id": "busta-rokkit-launcha", "profiles": {"standard": _weapon("Busta Rokkit Launcha - Standard", 24.0, 2, 4, 10, -2, 3, {}), "hunter": _weapon("Busta Rokkit Launcha - Hunter", 24.0, 3, 4, 12, -2, 3, {})}}, {"id": "rokkit-pistol", "profiles": {"standard": _weapon("Rokkit Pistol", 12.0, 1, 4, 10, -2, 3, {"close-quarters": true})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 4, 3, 5, -1, 1, {})}}, {"id": "gitstikka", "profiles": {"standard": _weapon("Gitstikka", 0.0, 3, 3, 5, 0, 1, {})}}, {"id": "smash-hammer", "profiles": {"standard": _weapon("Smash Hammer - Standard", 0.0, 3, 3, 7, -2, 2, {}), "hunter": _weapon("Smash Hammer - Hunter", 0.0, 3, 3, 12, -2, 3, {})}}],
			["Waaagh!", "Rokkit Barrage", "Bomb Squigs (Once per turn, twice per battle, per unit)", "Pulsa Rokkit (Once per battle, per unit)"],
			["waaagh"], [], ["000000012", "000000013", "000001536", "000003707"], [], [], {6: 170})
		rec.source_option_descriptions = ["The Nob can have their Rokkit Pistol replaced with 1 Smash Hammer.", "1 Tankbusta model can be equipped with one of the following: 1 Busta Rokkit Launcha 1 Pulsa Rokkit"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Rokkit Barrage", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Bomb Squigs (Once per turn, twice per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Pulsa Rokkit (Once per battle, per unit)", "model_role": "", "type": "Wargear", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "nobz":
		var rec := _record("nobz", "Nobz", "000000021", "Nobz", {5: 115, 10: 230}, 5, 40.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 4, "wounds": 3, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "EXPLOSIVES"],
			[{"id": "big-skorcha", "profiles": {"standard": _weapon("Big Skorcha", 18.0, 3, "-", 5, -1, 1, {"blast": 2, "torrent": true})}}, {"id": "kustom-big-shoota", "profiles": {"standard": _weapon("Kustom Big Shoota", 18.0, 8, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true})}}, {"id": "kombi-rokkit", "profiles": {"busta-rokkit": _weapon("Kombi-rokkit - Busta Rokkit", 24.0, 1, 5, 10, -2, 3, {}), "shoota": _weapon("Kombi-rokkit - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1})}}, {"id": "kustom-shoota", "profiles": {"standard": _weapon("Kustom Shoota", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}],
			[{"id": "big-choppa", "profiles": {"standard": _weapon("Big Choppa", 0.0, 4, 3, 7, -1, 2, {"cleave": 2})}}, {"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}, {"id": "kustom-krumpa", "profiles": {"standard": _weapon("Kustom Krumpa", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Waaagh!", "Get Out da Way!", "Ammo Runts (Once per battle, per unit)", "Paired Krumpas"],
			["waaagh"], [], ["000000001", "000000012", "000000013", "000001536", "000003707", "000004227", "000004228"], [], [], {5: 145, 10: 260})
		rec.wargear_costs = {"paired-krumpas": 5}
		rec.source_option_descriptions = ["For every 5 models in this unit, 1 model can have their Kustom Krumpa and Kustom Shoota replaced with 1 Big Skorcha and 1 Kustom Choppa.", "For every 5 models in this unit, 1 model can have their Kustom Krumpa and Kustom Shoota replaced with 1 Kustom Big Shoota and 1 Kustom Choppa.", "For every 5 models in this unit, 1 model can have their Kustom Krumpa and Kustom Shoota replaced with 1 Big Choppa.", "For every 5 models in this unit, 1 model can have their Kustom Shoota replaced with 1 Paired Krumpas.", "Any number of models can each have their Kustom Shoota replaced with 1 Kombi-rokkit."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Get Out da Way!", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Ammo Runts (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Paired Krumpas", "model_role": "", "type": "Wargear", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "meganobz":
		var rec := _record("meganobz", "Meganobz", "000000024", "Meganobz", {2: 70, 3: 105, 5: 175, 6: 210}, 2, 40.0,
			{"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 3, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "MEGA ARMOUR", "EXPLOSIVES"],
			[{"id": "kombi-weapon", "profiles": {"shoota": _weapon("Kombi-weapon - Shoota", 18.0, 2, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 1}), "kill-shot": _weapon("Kombi-weapon - Kill Shot", 24.0, 1, 5, 10, -2, 3, {}), "point-blank": _weapon("Kombi-weapon - Point Blank", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kustom-shoota", "profiles": {"aimed": _weapon("Kustom Shoota - Aimed", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2}), "point-blank": _weapon("Kustom Shoota - Point Blank", 6.0, "D3+3", "-", 4, 0, 1, {"close-quarters": true, "torrent": true})}}],
			[{"id": "killsaw", "profiles": {"standard": _weapon("Killsaw", 0.0, 3, 4, 10, -2, 3, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 3, 3, 10, -2, 2, {})}}, {"id": "twin-killsaws", "profiles": {"standard": _weapon("Twin Killsaws", 0.0, 3, 4, 10, -2, 3, {"twin-linked": true})}}],
			["Waaagh!", "Arrogant Invulnerability", "Krumpin’ Time"],
			["waaagh"], [], ["000000002", "000000006", "000004242"], [], [], {2: 110, 3: 145, 5: 215, 6: 250})
		rec.wargear_costs = {"killsaw": 5, "twin-killsaws": 5}
		rec.source_option_descriptions = ["Any number of models can each have their Power Klaw replaced with 1 Killsaw.", "Any number of models can each have their Kustom Shoota replaced with 1 Kombi-weapon.", "Any number of models can each have their Power Klaw and Kustom Shoota replaced with 1 Twin Killsaws."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Arrogant Invulnerability", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Krumpin’ Time", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "kommandos":
		var rec := _record("kommandos", "Kommandos", "000000025", "Kommandos", {10: 125}, 10, 32.0,
			{"movement_inches": 6, "toughness": 5, "save_target": 5, "wounds": 1, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "SMOKE", "EXPLOSIVES", "INFANTRY"],
			[{"id": "burna", "profiles": {"standard": _weapon("Burna", 12.0, 3, "-", 4, 0, 1, {"blast": 1, "torrent": true})}}, {"id": "kustom-shoota", "profiles": {"standard": _weapon("Kustom Shoota", 18.0, 4, 5, 4, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 4, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {})}}, {"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "big-choppa", "profiles": {"standard": _weapon("Big Choppa", 0.0, 4, 3, 7, -1, 2, {"cleave": 2})}}, {"id": "breacha-ram", "profiles": {"standard": _weapon("Breacha Ram", 0.0, 2, 4, 8, -2, 2, {})}}, {"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 3, 3, 5, -1, 1, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Infiltrators", "Stealth", "Waaagh!", "Found ’Em!", "Taktikal Know-wotz", "Nowhere to Hide", "Bomb Squig (Once per battle, per unit)"],
			["waaagh"], [], ["000000011"], [], [], {})
		rec.source_option_descriptions = ["The Nob can have their Choppa replaced with one of the following: 1 Big Choppa 1 Power Klaw", "1 Kommando model can be equipped with 1 Burna.", "1 Kommando model can be equipped with 1 Rokkit Launcha.", "1 Kommando model can have their Choppa replaced with 1 Breacha Ram.", "Up to 2 Kommando models can each be equipped with 1 Kustom Shoota."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008345", "name": "Infiltrators", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000008337", "name": "Stealth", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Found ’Em!", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Taktikal Know-wotz", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 6, "ability_id": "", "name": "Nowhere to Hide", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 7, "ability_id": "", "name": "Bomb Squig (Once per battle, per unit)", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "trukk":
		var rec := _record("trukk", "Trukk", "000000026", "Trukk", {1: 60}, 1, 60.0,
			{"movement_inches": 12, "toughness": 8, "save_target": 4, "wounds": 10, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "TRANSPORT", "SPEED FREEKS", "FRAME", "DEDICATED TRANSPORT"],
			[{"id": "dual-big-shoota", "profiles": {"standard": _weapon("Dual Big Shoota", 36.0, 6, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 4, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {})}}],
			[{"id": "buzzsaw", "profiles": {"standard": _weapon("Buzzsaw", 0.0, 2, 3, 6, -1, 2, {"cleave": 1, "extra-attacks": true})}}, {"id": "grabbin-klaw", "profiles": {"standard": _weapon("Grabbin’ Klaw", 0.0, 2, 3, 10, -2, 2, {"extra-attacks": true})}}, {"id": "spiked-ram", "profiles": {"standard": _weapon("Spiked Ram", 0.0, 3, 3, 6, 0, 1, {"cleave": 1})}}],
			["Deadly Demise", "Firing Deck", "Waaagh!", "Pilin’ Out"],
			["waaagh"], [], [], [], [], {})
		rec.fourth_plus_points_by_models = {1: 70}
		rec.base_size_source_note = "Use model (60 mm circular proxy)"
		rec.source_option_descriptions = ["This model’s Dual Big Shoota can be replaced with 1 Rokkit Launcha.", "This model can be equipped with one of the following: 1 Buzzsaw 1 Grabbin' Klaw"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 2, "ability_id": "000008334", "name": "Firing Deck", "model_role": "", "type": "Core", "parameter": "12"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Pilin’ Out", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "stormboyz":
		var rec := _record("stormboyz", "Stormboyz", "000000027", "Stormboyz", {5: 70, 10: 140}, 5, 32.0,
			{"movement_inches": 12, "toughness": 5, "save_target": 5, "wounds": 1, "leadership_target": 7, "objective_control": 1, "invulnerable_target": 0},
			["ORKS", "INFANTRY", "FLY", "JUMP PACK", "EXPLOSIVES"],
			[{"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 3, 3, 5, -1, 1, {})}}, {"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}, {"id": "power-klaw", "profiles": {"standard": _weapon("Power Klaw", 0.0, 3, 3, 10, -2, 2, {})}}],
			["Deep Strike", "Waaagh!", "Rokkit Charge"],
			["waaagh"], [], [], [], [], {})
		rec.source_option_descriptions = ["The Nob can have their Kustom Choppa replaced with 1 Power Klaw."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008343", "name": "Deep Strike", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Rokkit Charge", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "deffkoptas":
		var rec := _record("deffkoptas", "Deffkoptas", "000000028", "Deffkoptas", {3: 85, 6: 170}, 3, 75.0,
			{"movement_inches": 12, "toughness": 6, "save_target": 4, "wounds": 4, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "EXPLOSIVES", "MOUNTED", "SPEED FREEKS", "FLY"],
			[{"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 4, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {"lethal-hits": true})}}, {"id": "kustom-mega-blasta", "profiles": {"standard": _weapon("Kustom Mega-blasta", 24.0, 3, 5, 9, -2, 3, {"hazardous": true, "lethal-hits": true})}}, {"id": "slugga", "profiles": {"standard": _weapon("Slugga", 12.0, 1, 5, 4, 0, 1, {"close-quarters": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 3, 4, 5, -1, 1, {})}}, {"id": "spinnin-blades", "profiles": {"standard": _weapon("Spinnin’ Blades", 0.0, 4, 3, 5, -1, 1, {"cleave": 1, "hazardous": true})}}],
			["Deep Strike", "Waaagh!", "Deff from Above", "Aerial Manoover"],
			["waaagh"], [], [], [], [], {3: 95, 6: 180})
		rec.base_size_source_note = "75 x 42mm (75 mm circular proxy)"
		rec.source_option_descriptions = ["For every 3 models in this unit, 1 model can have their Rokkit Launcha replaced with 1 Kustom Mega-blasta."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008343", "name": "Deep Strike", "model_role": "", "type": "Core", "parameter": ""}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Deff from Above", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Aerial Manoover", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "dakkajet":
		var rec := _record("dakkajet", "Dakkajet", "000000029", "Dakkajet", {1: 125}, 1, 120.0,
			{"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "AIRCRAFT", "SPEED FREEKS", "FLY"],
			[{"id": "dual-supa-shoota", "profiles": {"standard": _weapon("Dual Supa-shoota", 36.0, 8, 5, 6, -1, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}],
			[{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Damaged", "Deadly Demise", "Waaagh!", "Strafing Run"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "120 x 92mm flying base (120 mm circular proxy)"
		rec.source_option_descriptions = ["This model can be equipped with 1 Dual Supa-shoota."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "4"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Strafing Run", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "burna-bommer":
		var rec := _record("burna-bommer", "Burna-bommer", "000000030", "Burna-bommer", {1: 125}, 1, 120.0,
			{"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 6},
			["ORKS", "SPEED FREEKS", "FLY", "VEHICLE", "AIRCRAFT"],
			[{"id": "dual-big-shoota", "profiles": {"standard": _weapon("Dual Big Shoota", 36.0, 6, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}, {"id": "dual-supa-shoota", "profiles": {"standard": _weapon("Dual Supa Shoota", 36.0, 8, 5, 6, -1, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4, "sustained-hits": 1})}}, {"id": "skorcha-missile-rack", "profiles": {"standard": _weapon("Skorcha Missile Rack", 36.0, 6, 5, 5, 0, 1, {"blast": 2, "ignores-cover": true})}}],
			[{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Damaged", "Deadly Demise", "Waaagh!", "Burna Bomb"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "120 x 92mm flying base (120 mm circular proxy)"
		rec.source_option_descriptions = ["This model can be equipped with 1 Skorcha Missile Rack."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "4"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Burna Bomb", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "blitza-bommer":
		var rec := _record("blitza-bommer", "Blitza-bommer", "000000031", "Blitza-bommer", {1: 115}, 1, 120.0,
			{"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 6},
			["ORKS", "SPEED FREEKS", "FLY", "AIRCRAFT", "VEHICLE"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "dual-supa-shoota", "profiles": {"standard": _weapon("Dual Supa-shoota", 36.0, 8, 5, 6, -1, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}],
			[{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Damaged", "Deadly Demise", "Waaagh!", "Boom Bomb"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "120 x 92mm flying base (120 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "4"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Boom Bomb", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "wazbom-blastajet":
		var rec := _record("wazbom-blastajet", "Wazbom Blastajet", "000000032", "Wazbom-Blastajet", {1: 215}, 1, 120.0,
			{"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 6},
			["ORKS", "SMOKE", "FLY", "AIRCRAFT", "VEHICLE", "SPEED FREEKS"],
			[{"id": "dual-supa-shoota", "profiles": {"standard": _weapon("Dual Supa-shoota", 36.0, 8, 4, 6, -1, 1, {"ignores-cover": true, "lethal-hits-non-monster-vehicle": true, "rapid-fire": 4})}}, {"id": "dual-tellyport-mega-blasta", "profiles": {"standard": _weapon("Dual Tellyport Mega-blasta", 24.0, 6, 4, 9, -2, 3, {"blast": 1, "ignores-cover": true, "rapid-fire": 6})}}, {"id": "dual-wazbom-mega-kannon", "profiles": {"standard": _weapon("Dual Wazbom Mega-kannon", 36.0, 4, 4, 12, -2, 4, {"hazardous": true, "ignores-cover": true})}}, {"id": "smasha-gun", "profiles": {"standard": _weapon("Smasha Gun", 48.0, 4, 4, 6, -3, 3, {"ignores-cover": true})}}],
			[{"id": "armoured-impact", "profiles": {"standard": _weapon("Armoured Impact", 0.0, 3, 4, 6, 0, 1, {})}}],
			["Damaged", "Deadly Demise", "Waaagh!", "Go fer da Weak Spot", "Blastajet Force Field"],
			["waaagh"], [], [], [], [], {1: 235})
		rec.base_size_source_note = "120 x 92mm flying base (120 mm circular proxy)"
		rec.source_option_descriptions = ["This model’s Dual Wazbom Mega-kannon can be replaced with 1 Dual Tellyport Mega-blasta.", "This model can be equipped with 1 Blastajet Force Field.", "This model can be equipped with 1 Dual Supa-shoota."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "4"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D3"}, {"source_line": 3, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 4, "ability_id": "", "name": "Go fer da Weak Spot", "model_role": "", "type": "Datasheet", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Blastajet Force Field", "model_role": "", "type": "Wargear", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "warbikers":
		var rec := _record("warbikers", "Warbikers", "000000033", "Warbikers", {3: 75, 6: 140}, 3, 75.0,
			{"movement_inches": 12, "toughness": 6, "save_target": 4, "wounds": 3, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "MOUNTED", "SPEED FREEKS", "EXPLOSIVES"],
			[{"id": "dual-kombi-rokkit", "profiles": {"dakkagun": _weapon("Dual Kombi-rokkit - Dakkagun", 18.0, 6, 5, 5, 0, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true}), "busta-rokkit": _weapon("Dual Kombi-rokkit - Busta Rokkit", 24.0, 2, 5, 10, -2, 3, {"assault": true})}}, {"id": "dual-dakkagun", "profiles": {"standard": _weapon("Dual Dakkagun", 18.0, 6, 5, 5, 0, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true})}}],
			[{"id": "choppa", "profiles": {"standard": _weapon("Choppa", 0.0, 3, 3, 5, -1, 1, {})}}, {"id": "kustom-choppa", "profiles": {"standard": _weapon("Kustom Choppa", 0.0, 4, 3, 5, -2, 2, {})}}],
			["Waaagh!", "High-speed Carnage"],
			["waaagh"], [], ["000001537"], [], [], {})
		rec.base_size_source_note = "75 x 42mm (75 mm circular proxy)"
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "High-speed Carnage", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "warbuggies":
		var rec := _record("warbuggies", "Warbuggies", "000000036", "Warbuggies", {1: 70, 2: 130}, 1, 150.0,
			{"movement_inches": 12, "toughness": 7, "save_target": 4, "wounds": 9, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "EXPLOSIVES", "SPEED FREEKS"],
			[{"id": "extra-dakka", "profiles": {"standard": _weapon("Extra Dakka", 12.0, 4, 5, 5, -1, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true, "sustained-hits": 1})}}, {"id": "rivet-kannon", "profiles": {"aimed": _weapon("Rivet Kannon - Aimed", 24.0, 6, 4, 7, -2, 2, {"anti-infantry": 4, "assault": true, "devastating-wounds-infantry": true}), "point-blank": _weapon("Rivet Kannon - Point Blank", 6.0, "D3+1", "-", 7, -2, 2, {"anti-infantry": 4, "assault": true, "devastating-wounds-infantry": true, "torrent": true})}}, {"id": "mek-speshul", "profiles": {"aimed": _weapon("Mek Speshul - Aimed", 24.0, 14, 4, 5, -1, 1, {"assault": true, "lethal-hits-non-monster-vehicle": true, "sustained-hits": 1}), "point-blank": _weapon("Mek Speshul - Point Blank", 6.0, "2D6+2", "-", 5, -1, 1, {"assault": true, "torrent": true})}}],
			[{"id": "spiked-ram", "profiles": {"standard": _weapon("Spiked Ram", 0.0, 4, 3, 7, -1, 2, {"cleave": 1})}}],
			["Deadly Demise", "Waaagh!", "Drive-by Skorchin’"],
			["waaagh"], [], [], [], [], {})
		rec.base_size_source_note = "150 x 95mm (150 mm circular proxy)"
		rec.source_option_descriptions = ["Any number of models can each have their Mek Speshul replaced with 1 Rivet Kannon."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Drive-by Skorchin’", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "mek-gunz":
		var rec := _record("mek-gunz", "Mek Gunz", "000000038", "Mek-Gunz", {1: 55, 2: 110, 3: 165}, 1, 60.0,
			{"movement_inches": 5, "toughness": 6, "save_target": 4, "wounds": 6, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "FRAME", "GROTS"],
			[{"id": "smasha-gun", "profiles": {"standard": _weapon("Smasha Gun", 48.0, 4, 4, 7, -3, 3, {"blast": 1})}}, {"id": "bubblechukka", "profiles": {"standard": _weapon("Bubblechukka", 48.0, 8, 4, 3, -3, 1, {"blast": 3, "lethal-hits": true})}}, {"id": "kustom-mega-kannon", "profiles": {"standard": _weapon("Kustom Mega-kannon", 36.0, "D3+1", 4, 12, -2, 4, {"blast": 1, "hazardous": true})}}, {"id": "traktor-kannon", "profiles": {"standard": _weapon("Traktor Kannon", 48.0, 2, 4, 6, -2, "D3+3", {"anti-fly": 2})}}],
			[{"id": "scavenged-shivs", "profiles": {"standard": _weapon("Scavenged Shivs", 0.0, 5, 5, 2, 0, 1, {})}}],
			["Waaagh!", "Madcap Artillery"],
			["waaagh"], [], ["000000006", "000000012", "000001536", "000003707"], [], [], {1: 65, 2: 120, 3: 175})
		rec.base_size_source_note = "Use model (60 mm circular proxy)"
		rec.source_option_descriptions = ["Any number of models can each have their Smasha Gun replaced with one of the following: 1 Bubblechukka 1 Kustom Mega-kannon 1 Traktor Kannon"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 2, "ability_id": "", "name": "Madcap Artillery", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "battlewagon":
		var rec := _record("battlewagon", "Battlewagon", "000000039", "Battlewagon", {1: 160}, 1, 60.0,
			{"movement_inches": 10, "toughness": 11, "save_target": 3, "wounds": 16, "leadership_target": 7, "objective_control": 5, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "FRAME", "TRANSPORT", "WAGON"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}],
			[{"id": "crushin-bulk", "profiles": {"standard": _weapon("Crushin’ Bulk", 0.0, 6, 3, 8, -2, 2, {"cleave": 1})}}, {"id": "grabbin-klaw", "profiles": {"standard": _weapon("Grabbin’ Klaw", 0.0, 2, 3, 10, -2, 2, {"extra-attacks": true})}}, {"id": "wreckin-ball", "profiles": {"standard": _weapon("Wreckin’ Ball", 0.0, 1, 3, 10, 0, "D6", {"cleave": 2, "extra-attacks": true})}}],
			["Damaged", "Deadly Demise", "Firing Deck", "Waaagh!", "Mobile Fortress"],
			["waaagh"], [], [], [], [], {1: 180})
		rec.base_size_source_note = "Use model (60 mm circular proxy)"
		rec.source_option_descriptions = ["This model can be equipped with 1 Wreckin’ Ball.", "This model can be equipped with up to 4 Big Shoota.", "This model can be equipped with 1 Grabbin’ Klaw."]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000011125", "name": "Damaged", "model_role": "", "type": "Core", "parameter": "6"}, {"source_line": 2, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "D6"}, {"source_line": 3, "ability_id": "000008334", "name": "Firing Deck", "model_role": "", "type": "Core", "parameter": "11"}, {"source_line": 4, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 5, "ability_id": "", "name": "Mobile Fortress", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "deff-dread":
		var rec := _record("deff-dread", "Deff Dread", "000000040", "Deff-Dread", {1: 130}, 1, 60.0,
			{"movement_inches": 8, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "WALKER"],
			[{"id": "big-shoota", "profiles": {"standard": _weapon("Big Shoota", 36.0, 3, 5, 5, 0, 1, {"lethal-hits-non-monster-vehicle": true, "rapid-fire": 2})}}, {"id": "kustom-mega-blasta", "profiles": {"standard": _weapon("Kustom Mega-blasta", 24.0, 3, 5, 9, -2, 3, {"hazardous": true})}}, {"id": "rokkit-launcha", "profiles": {"blasta": _weapon("Rokkit Launcha - Blasta", 24.0, 2, 5, 4, 0, 1, {"blast": 2}), "busta": _weapon("Rokkit Launcha - Busta", 24.0, 2, 5, 10, -2, 3, {})}}, {"id": "skorcha", "profiles": {"standard": _weapon("Skorcha", 12.0, 3, "-", 5, 0, 1, {"blast": 1, "torrent": true})}}],
			[{"id": "extra-klaw", "profiles": {"standard": _weapon("Extra Klaw", 0.0, 1, 3, 12, -2, 3, {"extra-attacks": true})}}, {"id": "dread-klaws", "profiles": {"standard": _weapon("Dread Klaws", 0.0, 5, 3, 12, -2, 3, {"cleave": 1})}}],
			["Deadly Demise", "Waaagh!", "Dread ’Ard"],
			["waaagh"], [], [], [], [], {1: 140})
		rec.source_option_descriptions = ["This model’s Big Shoota can be replaced with one of the following: 1 Extra Klaw 1 Kustom Mega-blasta 1 Rokkit Launcha", "This model’s Skorcha can be replaced with one of the following: 1 Extra Klaw 1 Big Shoota 1 Kustom Mega-blasta 1 Rokkit Launcha"]
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Dread ’Ard", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	if source == "killa-kans":
		var rec := _record("killa-kans", "Killa Kans", "000000041", "Killa-Kans", {3: 130, 6: 275}, 3, 60.0,
			{"movement_inches": 8, "toughness": 7, "save_target": 3, "wounds": 5, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 6},
			["ORKS", "VEHICLE", "WALKER", "GROTS"],
			[{"id": "kan-blasta", "profiles": {"dakka": _weapon("Kan Blasta - Dakka", 24.0, 4, 4, 6, -1, 1, {"blast": 1, "ignores-cover": true, "sustained-hits": 1}), "kill-shot": _weapon("Kan Blasta - Kill Shot", 24.0, 2, 4, 10, -2, 3, {}), "point-blank": _weapon("Kan Blasta - Point Blank", 12.0, 3, "-", 5, -1, 1, {"blast": 2, "torrent": true})}}],
			[{"id": "kan-klaw", "profiles": {"standard": _weapon("Kan Klaw", 0.0, 3, 4, 8, -2, 3, {})}}],
			["Deadly Demise", "Waaagh!", "Spiteful Power Trip"],
			["waaagh"], [], [], [], [], {3: 170, 6: 315})
		rec.source_ability_bindings = [{"source_line": 1, "ability_id": "000008339", "name": "Deadly Demise", "model_role": "", "type": "Core", "parameter": "1"}, {"source_line": 2, "ability_id": "000003676", "name": "Waaagh!", "model_role": "", "type": "Faction", "parameter": ""}, {"source_line": 3, "ability_id": "", "name": "Spiteful Power Trip", "model_role": "", "type": "Datasheet", "parameter": ""}]
		rec.pending_source_checks = []
		rec.source_profile_readiness = "source_bounded_local_scope_passed_2026_11_20"
		return rec
	return RemainingProfiles.profile(source)

static func catalog() -> Dictionary:
	var result := {}
	for slug: String in ["warboss", "warboss-in-mega-armour", "weirdboy", "big-mek-in-mega-armour", "ghazghkull-thraka", "boss-snikrot", "mek", "painboy", "boyz", "gretchin", "tankbustas", "nobz", "meganobz", "kommandos", "trukk", "stormboyz", "deffkoptas", "dakkajet", "burna-bommer", "blitza-bommer", "wazbom-blastajet", "warbikers", "warbuggies", "mek-gunz", "battlewagon", "deff-dread", "killa-kans"]:
		result[slug] = profile(slug)
	result.merge(RemainingProfiles.catalog(), false)
	return result

static func digest() -> String:
	return var_to_str({"id": ID, "snapshot_id": SNAPSHOT_ID, "parent_manifest_sha256": PARENT_MANIFEST_SHA256, "slice_manifest_sha256": SLICE_MANIFEST_SHA256, "source_sheets": SOURCE_SHEETS, "profiles": catalog()}).sha256_text()

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

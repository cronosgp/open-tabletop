extends RefCounted
## Read-only identity, eligibility and granted-ability queries shared by rules modules.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const ID := Detection.ABILITY_IMPLEMENTATION_ID
const RULES := {
	"company-heroes": ["raise-the-banner", "command-squad"],
	"crusader-squad": ["righteous-zeal"],
	"sword-brethren-squad": ["combat-doctrines", "exploit-their-cowardice"],
	"crusade-ancient": ["support", "combat-doctrines", "martial-honour", "vengeful-exhortation"],
	"execrator": ["leader", "combat-doctrines", "remorseless-persecution", "condemnatory-annihilation"],
	"wardens-of-ultramar": ["support", "combat-doctrines", "raise-the-banner", "strategium-command"],
	"outrider-squad": ["full-throttle-assault"],
	"gladiator-reaper": ["damaged-4", "deadly-demise-d3", "reaping-tally"],
	"gladiator-valiant": ["damaged-4", "deadly-demise-d3", "priority-target-acquisition"],
	"gladiator-lancer": ["damaged-4", "deadly-demise-d3", "aquilon-optics"],
	"land-speeder": ["deep-strike", "purgation-run"],
	"land-speeder-vengeance": ["deep-strike", "deadly-demise-d3", "combat-doctrines", "storm-of-vengeance"],
	"ravenwing-darkshroud": ["deep-strike", "deadly-demise-d3", "lone-operative", "combat-doctrines", "icon-of-old-caliban"],
	"ravenwing-black-knights": ["combat-doctrines", "knights-of-caliban"],
	"inner-circle-companions": ["combat-doctrines", "stealth", "braziers-of-judgement", "emnity-for-the-unworthy"],
	"asmodai": ["leader", "combat-doctrines", "transhuman-strategist", "exemplar-of-hate", "feared-interrogator"],
	"lazarus": ["leader", "combat-doctrines", "transhuman-strategist", "intractable-will", "the-spiritshield-helm"],
	"azrael": ["leader", "combat-doctrines", "transhuman-strategist", "masterful-tactician", "supreme-grand-master", "watcher-in-the-dark"],
	"belial": ["leader", "deep-strike", "combat-doctrines", "transhuman-strategist", "grand-master-of-the-deathwing", "strikes-of-retribution"],
	"ezekiel": ["leader", "combat-doctrines", "transhuman-strategist", "book-of-salvation", "chief-librarian", "psychic-hood", "engulfing-fear", "whispers-of-the-shadow-forest"],
	"sammael": ["leader", "combat-doctrines", "transhuman-strategist", "cut-off-their-escape", "grand-master-of-the-ravenwing"],
	"ravenwing-command-squad": ["support", "combat-doctrines", "ravenwing-astartes-banner", "ravenwing-honour-or-death", "narthecium"],
	"nephilim-jetfighter": ["damaged-3", "deadly-demise-d3", "combat-doctrines", "lightning-fast-manoeuvres"],
	"ravenwing-dark-talon": ["damaged-3", "deadly-demise-d3", "combat-doctrines", "stasis-bomb"],
	"deathwing-knights": ["deep-strike", "teleport-homer", "combat-doctrines", "inner-circle", "watcher-in-the-dark"],
	"deathwing-terminator-squad": ["deep-strike", "combat-doctrines", "deathwing", "watcher-in-the-dark"],
	"invader-atvs": ["combat-doctrines", "aggressive-reconnaissance"],
	"storm-speeder-hammerstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "hammerstrike"],
	"storm-speeder-hailstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "hailstrike"],
	"storm-speeder-thunderstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "thunderstrike", "shattered-defences"],
	# Their current effects live on the imported transport_profile and are resolved by TransportRules.
	"land-raider": ["transport-deadly-demise"],
	"land-raider-crusader": ["transport-deadly-demise"],
	"land-raider-redeemer": ["transport-deadly-demise"],
	"drop-pod": ["deep-strike", "transport-deadly-demise"],
	"impulsor": ["transport-deadly-demise"],
	"repulsor": ["transport-deadly-demise"],
	"repulsor-executioner": ["transport-deadly-demise", "executioner"],
	"scout-squad": ["scouts-6", "infiltrators", "flexible-asset"],
	"rhino": ["veiling-smoke", "transport-deadly-demise"],
	"incursor-squad": ["scouts-6", "divinator-class-auspexes", "haywire-mine"],
	"reiver-squad": ["scouts-6", "deep-strike", "terror-troops", "fearsome-assault", "grapnel-launchers", "grav-chutes"],
	"firestrike-servo-turrets": ["sentinel-protocols"],
	"ballistus-dreadnought": ["ballistus-strike", "damaged-4", "deadly-demise-d3"],
	"redemptor-dreadnought": ["damaged-4", "deadly-demise-d3", "duty-eternal"],
	"brutalis-dreadnought": ["damaged-4", "deadly-demise-d3", "brutalis-charge"],
	"death-company-dreadnought": ["damaged-4", "deadly-demise-d3", "combat-doctrines", "feel-no-pain-6", "black-rage", "driven-by-fury"],
	"death-company-marines": ["combat-doctrines", "feel-no-pain-6", "black-rage", "an-honourable-death-in-combat"],
	"death-company-marines-with-jump-packs": ["deep-strike", "combat-doctrines", "feel-no-pain-6", "black-rage", "savage-fury"],
	"talonstrike-kill-team": ["deep-strike", "combat-doctrines", "talonstrike-doctrines"],
	"fortis-kill-team": ["combat-doctrines", "fortis-doctrines"],
	"spectrus-kill-team": ["infiltrators", "scouts-6", "combat-doctrines", "spectrus-doctrines", "helix-gauntlet"],
	"indomitor-kill-team": ["combat-doctrines", "indomitor-doctrines"],
	"decimus-kill-team": ["combat-doctrines", "death-to-the-alien", "storm-shield"],
	"deathwatch-veterans": ["death-to-the-alien", "storm-shield"],
	"deathwatch-terminator-squad": ["deep-strike", "combat-doctrines", "deathwatch-terminatus-assault", "teleport-homer", "storm-shield"],
	"corvus-blackstar": ["damaged-5", "transport-deadly-demise", "combat-doctrines", "blackstar-cluster-launcher", "stealth"],
	"blood-claws": ["combat-doctrines", "berserk-charge"],
	"grey-hunters": ["combat-doctrines", "old-greymanes", "cunning-hunters"],
	"fenrisian-wolves": ["combat-doctrines", "predatory-instinct", "hunting-hounds"],
	"wolf-guard-terminators": ["deep-strike", "combat-doctrines", "rugged-resilience", "storm-shield"],
	"thunderwolf-cavalry": ["combat-doctrines", "thunderous-charge", "storm-shield"],
	"wulfen": ["combat-doctrines", "savage-frenzy", "death-totem", "curse-of-the-wulfen", "bestial-forms"],
	"wulfen-with-storm-shields": ["combat-doctrines", "death-totem", "curse-of-the-wulfen", "bestial-forms", "hammer-blow"],
	"wolf-scouts": ["scouts-8", "infiltrators", "combat-doctrines", "deadly-stalkers", "hunting-hounds", "haywire-mine"],
	"wolf-guard-headtakers": ["combat-doctrines", "headhunter-quarry", "let-loose-the-wolves", "hunting-hounds", "storm-shield"],
	"arjac-rockfist": ["leader", "deep-strike", "combat-doctrines", "champion-of-the-kingsguard", "anvil-of-endurance"],
	"logan-grimnar": ["leader", "deep-strike", "combat-doctrines", "high-king-of-fenris", "guile-of-the-wolf"],
	"ragnar-blackmane": ["leader", "combat-doctrines", "transhuman-strategist", "battle-lust", "war-howl"],
	"ulrik-the-slayer": ["leader", "combat-doctrines", "transhuman-strategist", "slayer-s-oath", "oathbound"],
	"iron-priest": ["leader", "combat-doctrines", "transhuman-strategist", "gift-of-the-iron-wolf", "iron-priest-lone-operative", "judgement-of-the-omnissiah"],
	"wolf-guard-battle-leader": ["leader", "combat-doctrines", "transhuman-strategist", "tempered-ferocity", "heroic-last-stand"],
	"wolf-priest": ["leader", "combat-doctrines", "transhuman-strategist", "healing-balms", "litany-of-hate"],
	"bjorn-the-fell-handed": ["deadly-demise-1", "feel-no-pain-5", "combat-doctrines", "legendary-tenacity", "ancient-tactician"],
	"murderfang": ["deadly-demise-1", "feel-no-pain-6", "combat-doctrines", "curse-of-the-wulfen", "murder-maker", "bestial-fury", "force-of-untamed-destruction"],
	"venerable-dreadnought": ["deadly-demise-1", "combat-doctrines", "fervour-of-the-ancients"],
	"wulfen-dreadnought": ["deadly-demise-1", "feel-no-pain-6", "curse-of-the-wulfen", "combat-doctrines", "violent-fury", "bestial-rage", "blizzard-shield", "bestial-forms"],
	"njal-stormcaller": ["leader", "combat-doctrines", "wind-walker", "high-rune-priest", "murderous-hurricane", "storm-caller", "tempests-wrath"],
	"watch-master": ["leader", "combat-doctrines", "transhuman-strategist", "strategic-knowledge", "watch-master", "purgatus-quarry"],
	"watch-captain-artemis": ["leader", "combat-doctrines", "transhuman-strategist", "feel-no-pain-6", "tactical-instinct", "unstoppable-champion"],
	"death-company-captain": ["leader", "combat-doctrines", "feel-no-pain-6", "death-visions-of-sanguinius", "black-rage", "forlorn-hero"],
	"death-company-captain-with-jump-pack": ["leader", "deep-strike", "combat-doctrines", "feel-no-pain-6", "black-rage", "death-visions-of-sanguinius", "lost-to-fury"],
	"sanguinary-guard": ["deep-strike", "combat-doctrines", "heirs-of-azkaellon", "angelic-visage"],
	"commander-dante": ["deep-strike", "leader", "combat-doctrines", "transhuman-strategist", "death-mask-of-sanguinius", "warden-of-the-imperium-nihilus"],
	"the-sanguinor": ["deep-strike", "fights-first", "lone-operative", "combat-doctrines", "aura-of-fervour", "miraculous-saviour"],
	"mephiston": ["feel-no-pain-5", "fights-first", "lone-operative", "combat-doctrines", "transhuman-strategist", "chief-librarian", "quickening", "transfixing-gaze"],
	"astorath": ["leader", "deep-strike", "combat-doctrines", "redeemer-of-the-lost", "mass-of-doom"],
	"lemartes": ["leader", "deep-strike", "feel-no-pain-6", "combat-doctrines", "fury-unbound", "guardian-of-the-lost"],
	"invictor-tactical-warsuit": ["damaged-4", "deadly-demise-d3", "scouts-8", "forward-assault-warsuit"],
	"desolation-squad": ["targeter-optics"],
	"infiltrator-squad": ["infiltrators", "omni-scramblers", "helix-gauntlet"],
	"lieutenant-in-phobos-armour": ["support", "combat-doctrines", "infiltrators", "deep-strike", "tactical-precision", "demi-company-commander"],
	"lieutenant-with-combi-weapon": ["feel-no-pain-5", "infiltrators", "lone-operative", "stealth", "combat-doctrines", "priority-target-identified", "evade-and-survive"],
	"techmarine": ["leader", "techmarine-lone-operative", "blessings-of-the-omnissiah"],
	"captain-in-gravis-armour": ["leader", "strategic-acumen", "transhuman-strategist", "refuse-to-yield"],
	"tor-garadon": ["leader", "combat-doctrines", "transhuman-strategist", "siege-captain", "signum-array"],
	"darnath-lysander": ["deep-strike", "leader", "combat-doctrines", "transhuman-strategist", "rampart", "icon-of-obstinacy"],
	"suboden-khan": ["leader", "combat-doctrines", "transhuman-strategist", "spear-of-chogoris", "skilled-riders"],
	"iron-father-feirros": ["feel-no-pain-5", "leader", "combat-doctrines", "transhuman-strategist", "master-of-the-forge", "rites-of-tempering", "iron-father"],
	"caanok-var": ["feel-no-pain-5", "deep-strike", "leader", "combat-doctrines", "transhuman-strategist", "cold-and-calculating", "cerebrex-logic-engine"],
	"chief-librarian-tigurius": ["leader", "combat-doctrines", "transhuman-strategist", "librarius", "hood-of-hellfire", "prescience", "telepathic-assault"],
	"cato-sicarius": ["leader", "combat-doctrines", "transhuman-strategist", "captain-of-the-honour-guard", "knight-champion-of-macragge", "honour-or-death"],
	"victrix-honour-guard": ["combat-doctrines", "glory-of-ultramar", "honour-guard-of-macragge", "banner-of-macragge"],
	"kayvaan-shrike": ["deep-strike", "lone-operative", "leader", "combat-doctrines", "transhuman-strategist", "stealth", "trifold-path-of-shadow", "echo-of-the-ravenspire"],
	"ancient-in-terminator-armour": ["support", "deep-strike", "combat-doctrines", "raise-the-banner", "never-shall-the-standard-fall"],
	"captain-in-terminator-armour": ["leader", "deep-strike", "combat-doctrines", "strategic-acumen", "unstoppable-valour", "transhuman-strategist"],
	"chaplain-in-terminator-armour": ["leader", "deep-strike", "combat-doctrines", "litany-of-hate", "zealous-fortitude", "relic-shield"],
	"librarian-in-terminator-armour": ["leader", "deep-strike", "combat-doctrines", "librarius", "psychic-hood", "might-of-heroes", "thunderous-force"],
	"librarian": ["leader", "combat-doctrines", "librarius", "psychic-hood", "veil-of-time", "force-dome"],
	"aethon-shaan": ["deep-strike", "lone-operative", "stealth", "combat-doctrines", "transhuman-strategist", "master-of-shadows", "blackwing-mantle"],
	"librarian-in-phobos-armour": ["leader", "deep-strike", "scouts-6", "infiltrators", "stealth", "combat-doctrines", "librarius", "psychic-hood", "shrouding", "soul-sight"],
	"captain-in-phobos-armour": ["leader", "deep-strike", "scouts-6", "infiltrators", "stealth", "strategic-acumen", "transhuman-strategist", "tactical-fluidity"],
	"apothecary": ["support", "narthecium"],
	"sanguinary-priest": ["support", "narthecium", "blood-chalice"],
	"ancient": ["support", "raise-the-banner", "honour-of-the-company"],
	"bladeguard-ancient": ["support", "raise-the-banner", "deeds-of-legend"],
	"bladeguard-veteran-squad": ["bladeguard"],
	"judiciar": ["support", "fights-first", "tempormortis"],
	"chaplain": ["leader", "litany-of-hate", "spiritual-leader"],
	"chaplain-on-bike": ["leader", "litany-of-hate", "catechism-of-fire"],
	"captain-on-bike": ["leader", "combat-doctrines", "strategic-acumen", "transhuman-strategist", "into-the-fray"],
	"adrax-agatone": ["leader", "combat-doctrines", "lord-of-the-pyroclasts", "unto-the-anvil", "transhuman-strategist"],
	"kaius-konorius": ["support", "combat-doctrines", "veteran-bodyguard", "calgars-champion"],
	"chaplain-with-jump-pack": ["leader", "deep-strike", "litany-of-hate", "exhortation-of-rage"],
	"sternguard-veteran-squad": ["veteran-marksmen"],
	"eliminator-squad": ["chameleoline-cloaks", "stealth", "infiltrators", "special-issue-optics-and-ammunition"],
	"eradicator-squad-with-melta-rifles": ["total-obliteration"],
	"eradicator-squad-with-heavy-bolters": ["overlapping-destruction"],
	"apothecary-biologis": ["support", "vivispectral-analysis-targeting"],
	"aggressor-squad": ["close-quarters-firestorm"],
	"infernus-squad": ["driven-from-cover"],
	"hellblaster-squad": ["rites-of-thermal-appeasement"],
	"intercessor-squad": ["bolter-discipline", "tactical-mainstay"],
	"assault-intercessor-squad": ["targeted-intercession"],
	"assault-intercessors-with-jump-packs": ["deep-strike", "hammer-of-wrath"],
	"inceptor-squad": ["deep-strike", "meteoric-descent", "parabolic-jetleap"],
	"captain-with-jump-pack": ["leader", "deep-strike", "combat-doctrines", "strategic-acumen", "angel-s-wrath", "transhuman-strategist", "relic-shield"],
	"vanguard-veteran-squad-with-jump-packs": ["deep-strike", "vanguard-assault", "combat-shield"],
	"heavy-intercessor-squad": ["unyielding-in-the-face-of-the-foe"],
	"terminator-squad": ["deep-strike", "teleport-homer", "fury-of-the-first"],
	"terminator-assault-squad": ["deep-strike", "teleport-homer", "terminatus-assault", "storm-shield"],
	"captain": ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist", "relic-shield"],
	"blood-angels-captain": ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist"],
	"baal-predator": ["damaged-4", "deadly-demise-d3", "combat-doctrines", "overcharged-engines"],
	"lieutenant": ["support", "combat-doctrines", "tactical-precision", "demi-company-commander", "storm-shield"],
	"vulkan-hestan": ["feel-no-pain-6", "leader", "combat-doctrines", "transhuman-strategist", "seeker-of-the-unfound", "forgefather"],
	"roboute-guilliman": ["codex-adept", "primarch-of-the-xiii", "author-of-the-codex", "feel-no-pain-5-guilliman", "leader-of-the-astartes", "supreme-commander", "transhuman-strategist"],
	"lion-eljonson": ["deep-strike", "fights-first", "combat-doctrines", "transhuman-strategist", "dark-angels-bodyguard", "emperors-shield", "primarch-of-the-first-legion", "the-watchers", "master-strategist", "mist-wreathed-shadow-realms", "martial-exemplar", "no-hiding-from-the-watchers", "supreme-commander"],
	"emperor-s-champion": ["leader", "lone-operative", "combat-doctrines", "armour-of-faith", "chosen-of-the-emperor", "sigismunds-heir"],
	"high-marshal-helbrecht": ["leader", "combat-doctrines", "transhuman-strategist", "high-marshal", "crusade-of-wrath"],
	"chaplain-grimaldus": ["leader", "feel-no-pain-5", "combat-doctrines", "temple-relics", "faithful-cenobytes", "litanies-of-the-devout"],
	"castellan": ["support", "combat-doctrines", "vehement-aggression"],
	"marshal": ["leader", "combat-doctrines", "transhuman-strategist", "inspirational-exemplar", "pious-fervour"],
	"black-templars-gladiator-lancer": ["damaged-4", "deadly-demise-d3", "aquilon-optics"],
	"black-templars-gladiator-reaper": ["damaged-4", "deadly-demise-d3", "reaping-tally"],
	"black-templars-gladiator-valiant": ["damaged-4", "deadly-demise-d3", "priority-target-acquisition"],
	"black-templars-impulsor": ["transport-deadly-demise"],
	"black-templars-repulsor": ["transport-deadly-demise", "combat-embarkation"],
	"black-templars-repulsor-executioner": ["transport-deadly-demise", "executioner"],
	"marneus-calgar": ["deep-strike", "leader", "combat-doctrines", "transhuman-strategist", "codex-adept", "master-tactician", "thunderhawk-insertion"],
	"kor-sarro-khan": ["leader", "combat-doctrines", "transhuman-strategist", "trophy-taker", "for-the-khan"],
	"captain-titus": ["feel-no-pain-5", "leader", "combat-doctrines", "transhuman-strategist", "press-the-attack", "righteous-fury", "honour-of-ultramar"],
	"necron-warriors": ["their-number-is-legion"],
	"immortals": ["implacable-eradication"],
	"overlord": ["leader", "my-will-be-done", "implacable-resilience", "resurrection-orb"],
	"royal-warden": ["leader", "adaptive-strategy", "engrammatic-logic"]}

static func identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func enabled(state: Dictionary) -> bool:
	return state.get("unit_abilities", {}).get("implementation", "") == ID

static func sources(state: Dictionary, squad: int, name: String) -> Array[int]:
	var result: Array[int] = []
	if not enabled(state): return result
	for model: int in Geometry.alive(state, squad):
		var unit_identity := identity(state.units[model])
		if unit_identity == "chaplain-grimaldus" and str(state.units[model].get("chaplain_grimaldus_role", "")) != "chaplain": continue
		if unit_identity == "cato-sicarius" and LeaderCatalog.army_has_calgar(state, int(state.units[model].owner)):
			if name == "leader": continue
			if name == "support": result.append(model); continue
		if name == "deep-strike" and int(state.get("unit_abilities", {}).get("thunderhawk_targets", {}).get(state.squads[squad].owner, -1)) == squad:
			result.append(model)
			continue
		if name == "deep-strike" and unit_identity == "reiver-squad" and not state.squads[squad].get("reiver_grav_chutes", false): continue
		if name == "grav-chutes" and unit_identity == "reiver-squad" and not state.squads[squad].get("reiver_grav_chutes", false): continue
		if name == "grapnel-launchers" and unit_identity == "reiver-squad" and not state.squads[squad].get("reiver_grapnel_launchers", false): continue
		if name == "helix-gauntlet" and not state.units[model].get("helix_gauntlet", false): continue
		if name == "watcher-in-the-dark" and unit_identity == "deathwing-knights" and not bool(state.squads.get(squad, {}).get("deathwing_knights_watcher_equipped", false)): continue
		if name == "watcher-in-the-dark" and unit_identity == "deathwing-terminator-squad" and not bool(state.squads.get(squad, {}).get("deathwing_terminator_watcher_equipped", false)): continue
		if unit_identity == "ravenwing-command-squad":
			var command_role := str(state.units[model].get("ravenwing_command_role", ""))
			var required_role: String = str({"ravenwing-astartes-banner": "Ravenwing Ancient", "ravenwing-honour-or-death": "Ravenwing Champion", "narthecium": "Ravenwing Apothecary"}.get(name, ""))
			if not required_role.is_empty() and command_role != required_role: continue
		if name == "relic-shield" and not state.units[model].get("relic_shield", false): continue
		if name == "combat-shield" and not state.units[model].get("combat_shield", false): continue
		if name == "storm-shield":
			var equipped: bool = unit_identity == "lieutenant" and bool(state.units[model].get("lieutenant_storm_shield", false))
			equipped = equipped or (unit_identity == "terminator-assault-squad" and state.units[model].get("terminator_assault_storm_shield", false))
			equipped = equipped or (unit_identity == "deathwatch-veterans" and state.units[model].get("deathwatch_veteran_storm_shield", false))
			equipped = equipped or (unit_identity == "deathwatch-terminator-squad" and state.units[model].get("deathwatch_terminator_storm_shield", false))
			equipped = equipped or (unit_identity == "decimus-kill-team" and state.units[model].get("decimus_storm_shield", false))
			equipped = equipped or (unit_identity == "wolf-guard-terminators" and state.units[model].get("wolf_guard_terminator_storm_shield", false))
			equipped = equipped or (unit_identity == "thunderwolf-cavalry" and state.units[model].get("thunderwolf_cavalry_storm_shield", false))
			equipped = equipped or (unit_identity == "wolf-guard-headtakers" and state.units[model].get("wolf_guard_headtaker_storm_shield", false))
			if not equipped: continue
		if name == "death-totem" and unit_identity in ["wulfen", "wulfen-with-storm-shields"] and not bool(state.units[model].get("wulfen_death_totem", false)): continue
		if name in RULES.get(identity(state.units[model]), []): result.append(model)
	return result

static func has(state: Dictionary, squad: int, name: String) -> bool:
	return not sources(state, squad, name).is_empty()

static func doctrine(state: Dictionary, squad: int) -> String:
	if not enabled(state): return ""
	var record: Dictionary = state.unit_abilities.doctrines.get(squad, {})
	return str(record.get("doctrine", ""))

static func additional_doctrines(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	if not enabled(state): return result
	if has(state, squad, "warden-of-the-imperium-nihilus"):
		result.append_array(["assault", "tactical"])
	if has(state, squad, "guile-of-the-wolf"):
		result.append_array(["assault", "devastator", "tactical"])
	for doctrine: String in state.unit_abilities.get("additional_doctrines", {}).get(squad, []):
		if doctrine not in result: result.append(doctrine)
	return result

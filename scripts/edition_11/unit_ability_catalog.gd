extends RefCounted
## Read-only identity, eligibility and granted-ability queries shared by rules modules.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const ID := Detection.ABILITY_IMPLEMENTATION_ID
const RULES := {
	"company-heroes": ["raise-the-banner", "command-squad"],
	"wardens-of-ultramar": ["support", "combat-doctrines", "raise-the-banner", "strategium-command"],
	"outrider-squad": ["full-throttle-assault"],
	"gladiator-reaper": ["damaged-4", "deadly-demise-d3", "reaping-tally"],
	"gladiator-valiant": ["damaged-4", "deadly-demise-d3", "priority-target-acquisition"],
	"gladiator-lancer": ["damaged-4", "deadly-demise-d3", "aquilon-optics"],
	"land-speeder": ["deep-strike", "purgation-run"],
	"invader-atvs": ["combat-doctrines", "aggressive-reconnaissance"],
	"storm-speeder-hammerstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "hammerstrike"],
	"storm-speeder-hailstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "hailstrike"],
	"storm-speeder-thunderstrike": ["damaged-4", "deadly-demise-d3", "deep-strike", "thunderstrike", "shattered-defences"],
	# Their current effects live on the imported transport_profile and are resolved by TransportRules.
	"land-raider": [],
	"land-raider-crusader": [],
	"land-raider-redeemer": [],
	"drop-pod": [],
	"impulsor": [],
	"repulsor": [],
	"repulsor-executioner": ["executioner"],
	"scout-squad": ["scouts-6", "infiltrators", "flexible-asset"],
	"rhino": ["veiling-smoke"],
	"incursor-squad": ["scouts-6", "divinator-class-auspexes", "haywire-mine"],
	"reiver-squad": ["scouts-6", "deep-strike", "terror-troops", "fearsome-assault", "grapnel-launchers", "grav-chutes"],
	"firestrike-servo-turrets": ["sentinel-protocols"],
	"ballistus-dreadnought": ["ballistus-strike", "damaged-4", "deadly-demise-d3"],
	"redemptor-dreadnought": ["damaged-4", "deadly-demise-d3", "duty-eternal"],
	"brutalis-dreadnought": ["damaged-4", "deadly-demise-d3", "brutalis-charge"],
	"invictor-tactical-warsuit": ["damaged-4", "deadly-demise-d3", "scouts-8", "forward-assault-warsuit"],
	"desolation-squad": ["targeter-optics"],
	"infiltrator-squad": ["infiltrators", "omni-scramblers", "helix-gauntlet"],
	"lieutenant-in-phobos-armour": ["support", "combat-doctrines", "infiltrators", "deep-strike", "tactical-precision", "demi-company-commander"],
	"lieutenant-with-combi-weapon": ["feel-no-pain-5", "infiltrators", "lone-operative", "stealth", "priority-target-identified", "evade-and-survive"],
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
	"ancient-in-terminator-armour": ["support", "deep-strike", "raise-the-banner", "never-shall-the-standard-fall"],
	"captain-in-terminator-armour": ["leader", "deep-strike", "strategic-acumen", "unstoppable-valour", "transhuman-strategist"],
	"chaplain-in-terminator-armour": ["leader", "deep-strike", "litany-of-hate", "zealous-fortitude", "relic-shield"],
	"librarian-in-terminator-armour": ["leader", "deep-strike", "librarius", "psychic-hood", "might-of-heroes", "thunderous-force"],
	"librarian": ["leader", "librarius", "psychic-hood", "veil-of-time", "force-dome"],
	"aethon-shaan": ["deep-strike", "lone-operative", "stealth", "combat-doctrines", "transhuman-strategist", "master-of-shadows", "blackwing-mantle"],
	"librarian-in-phobos-armour": ["leader", "deep-strike", "scouts-6", "infiltrators", "stealth", "librarius", "psychic-hood", "shrouding", "soul-sight"],
	"captain-in-phobos-armour": ["leader", "deep-strike", "scouts-6", "infiltrators", "stealth", "strategic-acumen", "transhuman-strategist", "tactical-fluidity"],
	"apothecary": ["support", "narthecium"],
	"ancient": ["support", "raise-the-banner", "honour-of-the-company"],
	"bladeguard-ancient": ["support", "raise-the-banner", "deeds-of-legend"],
	"bladeguard-veteran-squad": ["bladeguard"],
	"judiciar": ["support", "fights-first", "tempormortis"],
	"chaplain": ["leader", "litany-of-hate", "spiritual-leader"],
	"chaplain-on-bike": ["leader", "litany-of-hate", "catechism-of-fire"],
	"captain-on-bike": ["leader", "strategic-acumen", "transhuman-strategist", "into-the-fray"],
	"adrax-agatone": ["leader", "lord-of-the-pyroclasts", "unto-the-anvil", "transhuman-strategist"],
	"kaius-konorius": ["leader", "veteran-bodyguard", "calgars-champion"],
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
	"captain-with-jump-pack": ["leader", "deep-strike", "strategic-acumen", "angel-s-wrath", "relic-shield"],
	"vanguard-veteran-squad-with-jump-packs": ["deep-strike", "vanguard-assault", "combat-shield"],
	"heavy-intercessor-squad": ["unyielding-in-the-face-of-the-foe"],
	"terminator-squad": ["deep-strike", "teleport-homer", "fury-of-the-first"],
	"terminator-assault-squad": ["deep-strike", "teleport-homer", "terminatus-assault", "storm-shield"],
	"captain": ["leader", "combat-doctrines", "strategic-acumen", "finest-hour", "transhuman-strategist", "relic-shield"],
	"lieutenant": ["support", "combat-doctrines", "tactical-precision", "demi-company-commander", "storm-shield"],
	"vulkan-hestan": ["leader", "combat-doctrines", "transhuman-strategist", "seeker-of-the-unfound", "forgefather"],
	"roboute-guilliman": ["codex-adept", "primarch-of-the-xiii", "author-of-the-codex", "feel-no-pain-5-guilliman", "leader-of-the-astartes", "supreme-commander", "transhuman-strategist"],
	"marneus-calgar": ["deep-strike", "leader", "combat-doctrines", "codex-adept", "master-tactician", "thunderhawk-insertion"],
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
		if name == "relic-shield" and not state.units[model].get("relic_shield", false): continue
		if name == "combat-shield" and not state.units[model].get("combat_shield", false): continue
		if name == "storm-shield":
			var equipped: bool = unit_identity == "lieutenant" and bool(state.units[model].get("lieutenant_storm_shield", false))
			equipped = equipped or (unit_identity == "terminator-assault-squad" and state.units[model].get("terminator_assault_storm_shield", false))
			if not equipped: continue
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
	for doctrine: String in state.unit_abilities.get("additional_doctrines", {}).get(squad, []):
		if doctrine not in result: result.append(doctrine)
	return result

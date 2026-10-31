extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/leader_catalog.gd")
const LeaderRuntime = preload("res://scripts/edition_11/leaders.gd")
const SupportLinks = preload("res://scripts/edition_11/support_attachments.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("necron-warriors")
	check(profile.get("source_snapshot_id") == "20261031T053336Z" and profile.get("source_book_id") == "000000029" and profile.get("source_book_version") == "1.2" and profile.get("source_datasheet_id") == "000000534", "Warriors identify the hash-recorded Necrons App v1.2 export subject")
	check(profile.get("points_by_models", {}) == {10: 85, 20: 190} and Army.construction_model_sizes("necron-warriors", profile) == [10, 20], "Only the source-priced 10- and 20-model sizes are constructible")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0}, "Warriors stats match the current source record")
	check(profile.get("keywords", []) == ["NECRONS", "INFANTRY", "BATTLELINE", "NECRON WARRIORS"] and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 16.0 / 25.4), "Source keywords and 32 mm base are represented")
	var flayer: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var blade: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(flayer == {"name": "Gauss flayer", "range_inches": 24.0, "attacks": 1, "skill": 4, "strength": 4, "ap": 0, "damage": 1, "keywords": {"lethal-hits": true, "rapid-fire": 1}}, "The default Gauss flayer profile includes Lethal Hits and Rapid Fire 1")
	check(blade == {"name": "Close combat weapon", "range_inches": 0.0, "attacks": 1, "skill": 4, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}, "The default close-combat profile matches the source")
	check(profile.get("additional_weapon_profiles", {}).get("ranged", [])[0].profiles.standard.keywords == {"lethal-hits": true} and profile.source_options[0].implemented, "Gauss Reaper facts and the any-number per-model replacement are represented")
	check(AbilityCatalog.RULES.get("necron-warriors", []) == ["their-number-is-legion"] and profile.supported_rule_ids == ["reanimation-protocols", "their-number-is-legion"] and Registry.KNOWN.get("reanimation-protocols", {}).get("supported", false), "Warriors connect to their existing Reanimation abilities")
	var immortals := Profiles.profile("immortals")
	var immortals_blaster: Dictionary = immortals.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var immortals_tesla: Dictionary = immortals.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(immortals.get("source_datasheet_id") == "000000535" and immortals.get("points_by_models", {}) == {5: 65, 10: 130} and Army.construction_model_sizes("immortals", immortals) == [5, 10], "Immortals match the App v1.2 size and points rows")
	check(immortals.get("stats", {}) == {"movement_inches": 5, "toughness": 5, "save_target": 3, "wounds": 1, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0} and immortals.get("base_size_source_mm") == 32, "Immortals source characteristics and base are transcribed")
	check(immortals_blaster == {"name": "Gauss blaster", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"lethal-hits": true}} and immortals_tesla.keywords == {"assault": true, "sustained-hits": 2}, "Both Immortals weapon profiles and their source traits are retained")
	check(immortals.source_options.size() == 1 and immortals.source_options[0].implemented and immortals.source_options[0].maximum == "unit_size" and immortals.supported_rule_ids == ["reanimation-protocols", "implacable-eradication"], "Immortals' any-number Tesla replacement and supported local abilities are recorded")
	var overlord := Profiles.profile("overlord")
	var tachyon: Dictionary = overlord.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var blade_profile: Dictionary = overlord.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(overlord.get("source_datasheet_id") == "000000523" and overlord.get("points_by_models", {}) == {1: 90} and overlord.get("stats", {}).get("invulnerable_target") == 4 and overlord.get("base_size_source_mm") == 40, "Overlord matches its current App profile, points, save and base")
	check(tachyon == {"name": "Tachyon arrow", "range_inches": 72.0, "attacks": 1, "skill": 2, "strength": 16, "ap": -5, "damage": "D6+2", "keywords": {"one-shot": true}} and blade_profile.keywords == {"devastating-wounds": true}, "Overlord default weapons and One Shot/Devastating Wounds data are retained")
	check(overlord.get("additional_weapon_profiles", {}).get("melee", []).size() == 2 and overlord.source_options.size() == 2 and overlord.source_options.all(func(option: Dictionary) -> bool: return not option.get("implemented", true)), "Overlord's replacement and conditional Orb options are all explicitly gated")
	check("40kdc:11e:necrons:lychguard" in LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:overlord", []), "Overlord's third source-listed bodyguard, Lychguard, is included in the Leader catalog")
	var warden := Profiles.profile("royal-warden")
	var warden_gun: Dictionary = warden.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(warden.get("source_datasheet_id") == "000002350" and warden.get("points_by_models", {}) == {1: 50} and warden.get("base_size_source_mm") == 32, "Royal Warden matches its current App identity, cost and base")
	check(warden_gun == {"name": "Relic gauss blaster", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"lethal-hits": true, "rapid-fire": 2}} and "engrammatic-logic" in warden.supported_rule_ids, "Royal Warden's fixed weapons and current ability links are recorded")
	var orikan := Profiles.profile("orikan-the-diviner")
	var orikan_staff: Dictionary = orikan.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(orikan.get("source_datasheet_id") == "000000530" and orikan.get("points_by_models", {}) == {1: 90} and orikan.get("base_size_source_mm") == 40 and orikan.get("stats", {}).get("invulnerable_target") == 4, "Orikan matches the current source cost, characteristics and base")
	check(orikan_staff == {"name": "Staff of Tomorrow", "range_inches": 0.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -3, "damage": "D3", "keywords": {"devastating-wounds": true}} and orikan.get("unsupported_abilities", []) == ["Reanimation Protocols", "Master Chronomancer", "The Stars Are Right"], "Orikan's weapon is recorded and the three unsupported effects remain explicit blockers")
	check(orikan.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535"] and orikan.supported_rule_ids == ["support"] and SupportLinks.BODYGUARDS.get("orikan-the-diviner", []) == ["necron-warriors", "immortals"], "Orikan's source Support targets are wired to the existing Support attachment path")
	var support_probe := [{"definition_id": "40kdc:11e:necrons:orikan-the-diviner", "copies": 1}, {"definition_id": "40kdc:11e:necrons:necron-warriors", "copies": 1}]
	check(SupportLinks.matching_error(support_probe).is_empty(), "The shared attachment matcher accepts Orikan with a source-listed bodyguard")
	var trazyn := Profiles.profile("trazyn-the-infinite")
	var obliterator: Dictionary = trazyn.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(trazyn.get("source_datasheet_id") == "000000532" and trazyn.get("points_by_models", {}) == {1: 60} and trazyn.get("base_size_source_mm") == 25, "Trazyn matches the current source cost and 25 mm base")
	check(obliterator == {"name": "Empathic Obliterator", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 7, "ap": 0, "damage": "D3", "keywords": {"sustained-hits": "D3"}} and trazyn.get("unsupported_abilities", []) == ["Reanimation Protocols", "Ancient Collector", "Surrogate Hosts"] and trazyn.get("unsupported_weapon_rules", []) == ["Empathic Obliterator: Sustained Hits D3"], "Trazyn's weapon trait and three unsupported abilities remain explicit blockers")
	check(trazyn.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000536", "000000535"] and trazyn.supported_rule_ids == ["leader"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:trazyn-the-infinite", []) == ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:lychguard", "40kdc:11e:necrons:immortals"], "Trazyn's source Leader targets use the shared attachment catalog")
	var trazyn_attachment_state := {"squads": {1: {"owner": 1}, 2: {"owner": 1}}, "units": {101: {"squad": 1, "definition_id": "40kdc:11e:necrons:trazyn-the-infinite"}, 201: {"squad": 2, "definition_id": "40kdc:11e:necrons:lychguard"}}}
	check(LeaderRuntime.can_attach(trazyn_attachment_state, 1, 2), "The live Leader rule path accepts Trazyn with source-listed Lychguard")
	var lychguard := Profiles.profile("lychguard")
	check(lychguard.get("source_datasheet_id") == "000000536" and lychguard.get("points_by_models", {}) == {5: 80, 10: 160} and lychguard.get("base_size_source_mm") == 32, "Lychguard match both source size/price rows and base")
	check(lychguard.get("source_leader_datasheet_ids", []).size() == 7 and lychguard.get("unsupported_abilities", []) == ["Reanimation Protocols", "Dispersion Shield", "Guardian Protocols"] and not lychguard.get("source_options", [])[0].get("implemented", true), "Lychguard keep all seven Leader links and gate Reanimation, shield effects and loadout")
	var deathmarks := Profiles.profile("deathmarks")
	var disintegrator: Dictionary = deathmarks.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(deathmarks.get("source_datasheet_id") == "000000537" and deathmarks.get("points_by_models", {}) == {5: 60, 10: 120} and deathmarks.get("third_plus_points_by_models", {}) == {5: 70, 10: 130}, "Deathmarks retain both source sizes and first-two/third-plus prices")
	check(disintegrator == {"name": "Synaptic disintegrator", "range_inches": 36.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"heavy": true, "precision": true}} and deathmarks.get("unsupported_abilities", []).is_empty() and deathmarks.supported_rule_ids == ["deep-strike", "reanimation-protocols", "hyperspace-hunters"] and AbilityCatalog.RULES.get("deathmarks", []) == ["deep-strike", "hyperspace-hunters"], "Deathmarks map Deep Strike, Reanimation Protocols and Hyperspace Hunters")
	var deathmark_probe := {"unit_abilities": {"implementation": AbilityCatalog.ID}, "squads": {90: {"owner": 1}}, "units": {901: {"owner": 1, "squad": 90, "wounds": 1, "definition_id": "40kdc:11e:necrons:deathmarks"}}}
	check(AbilityCatalog.sources(deathmark_probe, 90, "deep-strike") == [901] and AbilityCatalog.sources(deathmark_probe, 90, "hyperspace-hunters") == [901], "Deathmarks are exposed as sources for Deep Strike and Hyperspace Hunters")
	var flayed := Profiles.profile("flayed-ones")
	var claws: Dictionary = flayed.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(flayed.get("source_datasheet_id") == "000000538" and flayed.get("points_by_models", {}) == {5: 55, 10: 100} and flayed.get("base_size_source_mm") == 28.5, "Flayed Ones preserve both local size/cost rows and the 28.5 mm base")
	check(claws == {"name": "Flayer claws", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1, "twin-linked": true}} and flayed.get("unsupported_abilities", []).is_empty(), "Flayed Ones preserve their weapon and local ability scope")
	check(flayed.supported_rule_ids == ["infiltrators", "stealth", "reanimation-protocols", "flesh-hunger"] and AbilityCatalog.RULES.get("flayed-ones", []) == ["infiltrators", "stealth", "flesh-hunger"], "Flayed Ones map Infiltrators, Stealth, Reanimation Protocols and Flesh Hunger")
	var flayed_probe := {"unit_abilities": {"implementation": AbilityCatalog.ID}, "squads": {91: {"owner": 1}}, "units": {911: {"owner": 1, "squad": 91, "wounds": 1, "definition_id": "40kdc:11e:necrons:flayed-ones"}}}
	check(AbilityCatalog.sources(flayed_probe, 91, "infiltrators") == [911] and AbilityCatalog.sources(flayed_probe, 91, "stealth") == [911] and AbilityCatalog.sources(flayed_probe, 91, "flesh-hunger") == [911], "Flayed Ones are exposed as sources for Infiltrators, Stealth and Flesh Hunger")
	var praetorians := Profiles.profile("triarch-praetorians")
	var rod: Dictionary = praetorians.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var particle: Dictionary = praetorians.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var voidblade: Dictionary = praetorians.get("additional_weapon_profiles", {}).get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(praetorians.get("source_datasheet_id") == "000000539" and praetorians.get("points_by_models", {}) == {5: 80, 10: 160} and praetorians.stats.movement_inches == 10, "Triarch Praetorians preserve source sizes, costs and movement")
	check(rod == {"name": "Rod of covenant", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {}} and particle.keywords == {"devastating-wounds": true, "pistol": true} and voidblade.attacks == 4, "Praetorian default and replacement weapon profiles match the local export")
	check(praetorians.supported_rule_ids == ["deep-strike", "reanimation-protocols"] and praetorians.get("unsupported_abilities", []) == ["Relentless Combatants"] and not praetorians.source_options[0].implemented, "Praetorian Deep Strike uses the shared resolver while unsupported charge and loadout rules stay gated")
	var skorpekh := Profiles.profile("skorpekh-destroyers")
	var skorpekh_melee: Dictionary = skorpekh.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(skorpekh.get("source_datasheet_id") == "000002110" and skorpekh.get("points_by_models", {}) == {3: 85, 6: 170} and skorpekh.get("third_plus_points_by_models", {}) == {3: 95, 6: 180} and skorpekh.stats.wounds == 3, "Skorpekh Destroyers preserve multi-wound models and first-two/third-plus local prices")
	check(skorpekh_melee == {"name": "Skorpekh hyperphase weapons", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 7, "ap": -2, "damage": 2, "keywords": {}} and skorpekh.get("unsupported_abilities", []) == ["Plasmacyte", "Whirling Onslaught"] and not skorpekh.source_options[0].implemented, "Skorpekh weapons are recorded while Plasmacyte loadout and Whirling Onslaught stay blocked")
	check(skorpekh.get("source_leader_datasheet_ids", []) == ["000002109"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:skorpekh-lord", []) == ["40kdc:11e:necrons:skorpekh-destroyers"], "The local Skorpekh Lord Leader pairing is preserved")
	var scarabs := Profiles.profile("canoptek-scarab-swarms")
	var mandibles: Dictionary = scarabs.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(scarabs.get("source_datasheet_id") == "000002114" and scarabs.get("points_by_models", {}) == {3: 40, 6: 80} and scarabs.stats.wounds == 4 and scarabs.stats.objective_control == 0, "Scarab Swarms preserve four-wound models, zero OC and source prices")
	check(mandibles == {"name": "Feeder mandibles", "range_inches": 0.0, "attacks": 6, "skill": 5, "strength": 2, "ap": 0, "damage": 1, "keywords": {"lethal-hits": true}} and scarabs.get("unsupported_abilities", []).is_empty(), "Scarab melee and local ability scope are recorded")
	check(scarabs.supported_rule_ids == ["reanimation-protocols", "self-destruction", "chittering-swarm"], "Scarab Swarms map Reanimation Protocols, Self-destruction and Chittering Swarm")
	var wraiths := Profiles.profile("canoptek-wraiths")
	var claws_profile: Dictionary = wraiths.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(wraiths.get("source_datasheet_id") == "000000546" and wraiths.get("points_by_models", {}) == {3: 95, 6: 220} and wraiths.get("third_plus_points_by_models", {}) == {3: 115, 6: 240} and wraiths.stats.invulnerable_target == 4, "Canoptek Wraiths preserve source costs, third-plus costs and invulnerable save")
	check(claws_profile == {"name": "Vicious claws", "range_inches": 0.0, "attacks": 4, "skill": 4, "strength": 6, "ap": -1, "damage": 2, "keywords": {}} and wraiths.get("additional_weapon_profiles", {}).get("ranged", []).size() == 2 and wraiths.get("additional_weapon_profiles", {}).get("melee", []).size() == 1, "Wraith default and alternate weapons are transcribed")
	check(wraiths.get("unsupported_abilities", []) == ["Wraith Form"] and wraiths.get("source_options", []).size() == 2 and wraiths.supported_rule_ids == ["reanimation-protocols"], "Wraith Form and both equipment selections stay explicit gates while Reanimation is supported")
	var reanimator := Profiles.profile("canoptek-reanimator")
	var atomiser: Dictionary = reanimator.get("ranged", [{}])[0]
	check(reanimator.get("source_datasheet_id") == "000002112" and reanimator.get("points_by_models", {}) == {1: 75} and reanimator.stats.wounds == 6 and reanimator.get("base_size_source_mm") == 60 and atomiser.get("count") == 2, "Canoptek Reanimator records its source size, points, six-wound profile and two atomiser beams")
	check(reanimator.get("supported_rule_ids", []) == ["feel-no-pain-4", "reanimation-protocols", "nanoscarab-reanimation-beam"] and reanimator.get("unsupported_abilities", []).is_empty(), "The Reanimator's prevention, healing and aura effects use supported runtime paths")
	check(reanimator.get("source_file_sha256", {}).size() == 14 and reanimator.get("source_ability_bindings", []).size() == 3 and reanimator.source_ability_bindings[0].get("ability_id") == "000008338" and reanimator.source_ability_bindings[0].get("parameter") == "4+", "Reanimator source bindings and export hashes preserve the locally extracted ability details")
	var lokhusts := Profiles.profile("lokhust-destroyers")
	var cannon: Dictionary = lokhusts.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(lokhusts.get("source_datasheet_id") == "000002359" and lokhusts.get("points_by_models", {}) == {1: 40, 2: 55, 3: 80, 6: 190} and lokhusts.get("third_plus_points_by_models", {}) == {1: 70, 2: 85, 3: 110}, "Lokhust Destroyers retain priced sizes, third-plus prices and the unpriced-size blocker")
	check(cannon == {"name": "Gauss cannon", "range_inches": 24.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"lethal-hits": true}} and lokhusts.get("unsupported_abilities", []) == ["Hard-wired for Destruction"], "Lokhust Destroyers preserve their cannon and gate their target-dependent reroll")
	check(lokhusts.get("source_leader_datasheet_ids", []) == ["000002351"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:lokhust-lord", []) == ["40kdc:11e:necrons:lokhust-destroyers", "40kdc:11e:necrons:lokhust-heavy-destroyers"], "Lokhust Lord source targets are kept in the shared Leader catalog")
	var heavy_lokhusts := Profiles.profile("lokhust-heavy-destroyers")
	var destructor: Dictionary = heavy_lokhusts.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(heavy_lokhusts.get("source_datasheet_id") == "000002116" and heavy_lokhusts.get("points_by_models", {}) == {1: 50, 2: 100, 3: 165} and heavy_lokhusts.get("third_plus_points_by_models", {}) == {1: 60, 2: 110, 3: 175}, "Lokhust Heavy Destroyers retain both source copy-price tiers")
	check(destructor == {"name": "Gauss destructor", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 14, "ap": -4, "damage": 6, "keywords": {"heavy": true, "lethal-hits": true}} and heavy_lokhusts.get("unsupported_abilities", []) == ["Optimised for Slaughter"] and not heavy_lokhusts.source_options[0].implemented, "Heavy Destroyer weapon replacement and target-dependent rerolls stay gated")
	var imotekh := Profiles.profile("imotekh-the-stormlord")
	var gauntlet: Dictionary = imotekh.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(imotekh.get("source_datasheet_id") == "000000522" and imotekh.get("points_by_models", {}) == {1: 100} and imotekh.get("max_supported_copies") == 1 and imotekh.get("stats", {}).get("invulnerable_target") == 4, "Imotekh preserves current identity, cost, Epic Hero limit and invulnerable save")
	check(gauntlet == {"name": "Gauntlet of Fire", "range_inches": 12.0, "attacks": "D6", "skill": "-", "strength": 5, "ap": -1, "damage": 1, "keywords": {"ignores-cover": true, "torrent": true}} and imotekh.get("unsupported_abilities", []) == ["Reanimation Protocols", "Grand Strategist", "Lord of the Storm"], "Imotekh's auto-hit weapon and unsupported command/Storm effects are recorded")
	check(imotekh.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000536", "000000535"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:imotekh-the-stormlord", []).size() == 3 and "leader" in imotekh.supported_rule_ids, "Imotekh's Leader targets use the shared attachment catalog")
	var szeras := Profiles.profile("illuminor-szeras")
	var lance: Dictionary = szeras.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var legs: Dictionary = szeras.get("melee", [{}])[1].get("profiles", {}).get("standard", {})
	check(szeras.get("source_datasheet_id") == "000002092" and szeras.get("points_by_models", {}) == {1: 175} and szeras.get("max_supported_copies") == 1 and szeras.stats.wounds == 9 and szeras.get("base_size_source_mm") == 80, "Illuminor Szeras preserves Epic Hero cost, 9-wound profile and 80 mm base")
	check(lance == {"name": "Eldritch lance", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 9, "ap": -3, "damage": 3, "keywords": {}} and legs.keywords == {"extra-attacks": true} and szeras.get("unsupported_abilities", []).size() == 5, "Szeras's weapons and all five unsupported effects stay explicit")
	var plasmancer := Profiles.profile("plasmancer")
	check(plasmancer.get("source_datasheet_id") == "000002108" and plasmancer.get("points_by_models", {}) == {1: 60} and plasmancer.stats.wounds == 4, "Plasmancer preserves the 60-point, 4-wound profile")
	check(plasmancer.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535"] and SupportLinks.BODYGUARDS.get("plasmancer", []) == ["necron-warriors", "immortals"] and AbilityCatalog.RULES.get("plasmancer", []) == ["support"], "Plasmancer's Support targets use the shared attachment catalog")
	var plasmancer_support_probe := [{"definition_id": "40kdc:11e:necrons:plasmancer", "copies": 1}, {"definition_id": "40kdc:11e:necrons:necron-warriors", "copies": 1}]
	check(SupportLinks.matching_error(plasmancer_support_probe).is_empty() and not LeaderLinks.ATTACHMENTS.has("40kdc:11e:necrons:plasmancer"), "Plasmancer attaches through Support rather than the Leader rule path")
	var plasmancer_state := {"unit_abilities": {"implementation": AbilityCatalog.ID}, "squads": {92: {"owner": 1}}, "units": {921: {"owner": 1, "squad": 92, "wounds": 4, "definition_id": "40kdc:11e:necrons:plasmancer"}}}
	check(AbilityCatalog.sources(plasmancer_state, 92, "support") == [921], "Plasmancer is exposed to the existing Support attachment resolver")
	var skorpekh_lord := Profiles.profile("skorpekh-lord")
	var annihilator: Dictionary = skorpekh_lord.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(skorpekh_lord.get("source_datasheet_id") == "000002109" and skorpekh_lord.get("points_by_models", {}) == {1: 95} and skorpekh_lord.get("third_plus_points_by_models", {}) == {1: 105} and skorpekh_lord.stats.wounds == 7 and skorpekh_lord.stats.invulnerable_target == 4, "Skorpekh Lord retains 7 wounds, invulnerable save and both source prices")
	check(annihilator == {"name": "Enmitic annihilator", "range_inches": 18.0, "attacks": 2, "skill": 2, "strength": 6, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}} and skorpekh_lord.get("unsupported_abilities", []) == ["Reanimation Protocols", "United in Destruction", "Crimson Harvest"], "Skorpekh Lord weapons are transcribed and unsupported Leader/reaction effects remain gated")
	check(skorpekh_lord.get("source_bodyguard_datasheet_ids", []) == ["000002110"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:skorpekh-lord", []).size() == 1 and "leader" in skorpekh_lord.supported_rule_ids, "Skorpekh Lord Leader target matches the local source sheet")
	var lokhust_lord := Profiles.profile("lokhust-lord")
	var staff: Dictionary = lokhust_lord.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var lords_blade: Dictionary = lokhust_lord.get("additional_weapon_profiles", {}).get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(lokhust_lord.get("source_datasheet_id") == "000002351" and lokhust_lord.get("points_by_models", {}) == {1: 80} and lokhust_lord.stats.wounds == 6 and lokhust_lord.stats.invulnerable_target == 4, "Lokhust Lord retains its cost, 6 wounds and invulnerable save")
	check(staff == {"name": "Staff of light", "range_inches": 18.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -2, "damage": 1, "keywords": {}} and lords_blade.keywords == {"devastating-wounds": true} and lokhust_lord.source_options.size() == 2, "Lokhust Lord weapon replacement and Orb/amulet choices remain gated")
	check(lokhust_lord.get("source_bodyguard_datasheet_ids", []) == ["000002116", "000002359"] and LeaderLinks.ATTACHMENTS.get("40kdc:11e:necrons:lokhust-lord", []).size() == 2, "Lokhust Lord's source Leader targets match both Lokhust units")
	var technomancer := Profiles.profile("technomancer")
	check(technomancer.get("source_datasheet_id") == "000002352" and technomancer.get("points_by_models", {}) == {1: 80} and technomancer.get("third_plus_points_by_models", {}) == {1: 90} and technomancer.stats.movement_inches == 10, "Technomancer retains both source copy prices and Canoptek Cloak movement")
	check(technomancer.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535", "000000546"] and SupportLinks.BODYGUARDS.get("technomancer", []) == ["necron-warriors", "immortals", "canoptek-wraiths"] and AbilityCatalog.RULES.get("technomancer", []) == ["support"] and technomancer.get("unsupported_abilities", []).size() == 3, "Technomancer Support targets and unsupported healing effects stay explicit")
	var psychomancer := Profiles.profile("psychomancer")
	var abyssal_lance: Dictionary = psychomancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(psychomancer.get("source_datasheet_id") == "000002353" and psychomancer.get("points_by_models", {}) == {1: 65} and psychomancer.stats.wounds == 4 and psychomancer.get("base_size_source_mm") == 40, "Psychomancer preserves current cost, wounds and base size")
	check(abyssal_lance == {"name": "Abyssal lance", "range_inches": 18.0, "attacks": 1, "skill": 4, "strength": 6, "ap": -3, "damage": 3, "keywords": {}} and psychomancer.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535"] and SupportLinks.BODYGUARDS.get("psychomancer", []) == ["necron-warriors", "immortals"] and AbilityCatalog.RULES.get("psychomancer", []) == ["support"] and psychomancer.get("unsupported_abilities", []).size() == 3, "Psychomancer weapon, Support targets and Battle-shock effects are recorded")
	var chronomancer := Profiles.profile("chronomancer")
	var aeonstave: Dictionary = chronomancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(chronomancer.get("source_datasheet_id") == "000002354" and chronomancer.get("points_by_models", {}) == {1: 70} and chronomancer.get("third_plus_points_by_models", {}) == {1: 80} and chronomancer.stats.invulnerable_target == 4, "Chronomancer preserves both source costs and its invulnerable save")
	check(aeonstave == {"name": "Aeonstave", "range_inches": 18.0, "attacks": "D6", "skill": 4, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": true}} and chronomancer.get("source_loadout_label", "") == "Chronomancer’s stave" and chronomancer.get("source_wargear_table_label", "") == "Aeonstave", "Chronomancer keeps the weapon table profile and records the composition label mismatch")
	check(chronomancer.get("unsupported_abilities", []).has("Chronometron") and chronomancer.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535"] and SupportLinks.BODYGUARDS.get("chronomancer", []) == ["necron-warriors", "immortals"] and AbilityCatalog.RULES.get("chronomancer", []) == ["support"], "Chronomancer movement and Support effects remain explicit")
	var ghost_ark := Profiles.profile("ghost-ark")
	var ghost_array: Dictionary = ghost_ark.get("ranged", [{}])[0]
	check(ghost_ark.get("source_datasheet_id") == "000000543" and ghost_ark.get("points_by_models", {}) == {1: 100} and ghost_ark.stats.wounds == 14 and ghost_ark.stats.invulnerable_target == 4, "Ghost Ark preserves its local identity, price and 14-wound/4+ invulnerable profile")
	check(ghost_array.get("count") == 2 and ghost_array.profiles.standard.keywords == {"lethal-hits": true, "rapid-fire": 5} and ghost_ark.get("source_transport_capacity", "").contains("10 Necron Warrior models") and ghost_ark.get("unsupported_abilities", []) == ["Repair Barge"], "Ghost Ark weapons and transport capacity are transcribed while Repair Barge and passenger rules remain gated")
	var doomstalker := Profiles.profile("canoptek-doomstalker")
	var blaster: Dictionary = doomstalker.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(doomstalker.get("source_datasheet_id") == "000002115" and doomstalker.get("points_by_models", {}) == {1: 130} and doomstalker.stats.wounds == 12 and doomstalker.get("source_damaged_wounds") == "1-4", "Canoptek Doomstalker characteristics, points and damaged threshold match its source row")
	check(blaster == {"name": "Doomsday blaster", "range_inches": 48.0, "attacks": "D6+1", "skill": 4, "strength": 14, "ap": -3, "damage": 3, "keywords": {"blast": true, "heavy": true}} and doomstalker.supported_rule_ids == ["deadly-demise-d3", "reanimation-protocols", "sentinel-construct", "damaged-4"] and doomstalker.get("unsupported_abilities", []).is_empty(), "Doomstalker weapons and local abilities are in the checked scope")
	var doomsday_ark := Profiles.profile("doomsday-ark")
	var doomsday_cannon: Dictionary = doomsday_ark.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(doomsday_ark.get("source_datasheet_id") == "000000554" and doomsday_ark.get("points_by_models", {}) == {1: 200} and doomsday_ark.get("third_plus_points_by_models", {}) == {1: 230} and doomsday_ark.get("source_damaged_wounds") == "1-5", "Doomsday Ark retains first/second and third-plus prices and its Damaged 5 threshold")
	check(doomsday_cannon == {"name": "Doomsday cannon", "range_inches": 72.0, "attacks": "D6+1", "skill": 3, "strength": 18, "ap": -4, "damage": 4, "keywords": {"blast": true, "heavy": true}} and doomsday_ark.get("unsupported_abilities", []) == ["Overwhelming Obliteration"], "Doomsday cannon profile is recorded while conditional Devastating Wounds stays blocked")
	var monolith := Profiles.profile("monolith")
	var particle_whip: Dictionary = monolith.get("ranged", [])[1].get("profiles", {}).get("standard", {})
	check(monolith.get("source_datasheet_id") == "000000552" and monolith.get("points_by_models", {}) == {1: 420} and monolith.get("source_repeat_copy_costs", {}).get("2ND+", {}) == {1: 440} and monolith.stats.wounds == 22, "Monolith preserves its first and second-plus source prices and 22-wound profile")
	check(particle_whip.keywords == {"blast": true, "devastating-wounds": true} and monolith.get("source_damaged_wounds") == "1-7" and monolith.get("unsupported_abilities", []).has("Eternity Gate") and not monolith.get("source_options", [])[0].implemented and monolith.get("unsupported_weapon_rules", []) == ["Death ray: Sustained Hits D3"], "Monolith's weapons and gates preserve the damaged-profile effects, Death Ray replacement and unsupported Sustained Hits D3")
	var command_barge := Profiles.profile("catacomb-command-barge")
	var barge_gauss: Dictionary = command_barge.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(command_barge.get("source_datasheet_id") == "000000533" and command_barge.get("points_by_models", {}) == {1: 120} and command_barge.stats.wounds == 9 and command_barge.stats.invulnerable_target == 4, "Catacomb Command Barge records its source cost, wounds and invulnerable save")
	check(barge_gauss.keywords == {"lethal-hits": true} and command_barge.get("source_options", []).size() == 3 and command_barge.get("unsupported_abilities", []).has("Carrier Wave (Aura)"), "Command Barge fixed weapons are transcribed while equipment choices and unique aura/shield rules stay gated")
	var stalker := Profiles.profile("triarch-stalker")
	var heat_ray: Dictionary = stalker.get("ranged", [{}])[0].get("profiles", {})
	check(stalker.get("source_datasheet_id") == "000000540" and stalker.get("points_by_models", {}) == {1: 110} and stalker.get("third_plus_points_by_models", {}) == {1: 120} and stalker.get("source_base_size_label") == "Use model" and stalker.get("base_size_proxy_mm") == 120, "Triarch Stalker prices and unspecified source footprint are explicitly distinguished from its labelled runtime proxy")
	check(heat_ray.get("dispersed", {}).get("keywords", {}) == {"ignores-cover": true, "torrent": true} and heat_ray.get("focused", {}).get("keywords", {}) == {"melta": 4} and stalker.get("unsupported_abilities", []) == ["Targeting Relay"] and stalker.get("unsupported_geometry", []).size() == 1, "Triarch Stalker heat-ray profiles and unsupported target relay/footprint effects are retained")
	var hexmark := Profiles.profile("hexmark-destroyer")
	var hexmark_pistols: Dictionary = hexmark.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	check(hexmark.get("source_datasheet_id") == "000002355" and hexmark.get("points_by_models", {}) == {1: 75} and hexmark.stats.wounds == 5 and hexmark_pistols.keywords == {"close-quarters": true, "ignores-cover": true}, "Hexmark Destroyer maps its local Pistol profile onto close-quarters shooting and keeps Ignores Cover")
	check(hexmark.supported_rule_ids == ["deep-strike", "lone-operative", "reanimation-protocols", "inescapable-death", "multi-threat-eliminator"] and hexmark.get("unsupported_abilities", []).is_empty(), "Hexmark Destroyer's local abilities are in the checked scope")
	var ophydians := Profiles.profile("ophydian-destroyers")
	var ophydian_weapons: Dictionary = ophydians.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(ophydians.get("source_datasheet_id") == "000002358" and ophydians.get("points_by_models", {}) == {3: 80, 6: 150} and ophydians.get("third_plus_points_by_models", {}) == {3: 90, 6: 160} and ophydians.stats.wounds == 3, "Ophydian Destroyers retain both legal unit sizes, copy-price tiers and three-wound model profile")
	check(ophydian_weapons.strength == 4 and ophydian_weapons.ap == -2 and ophydian_weapons.damage == 2 and ophydians.get("source_options", [])[0].get("models_per_wargear") == 3 and ophydians.get("unsupported_abilities", []) == ["Plasmacyte", "Tunnelling Horrors"], "Ophydian weapons are recorded while Plasmacyte sizing and Tunnelling Horrors stay gated")
	check(Profiles.catalog().size() == 51, "The local runtime profile records now cover all 51 current Necrons App sheets")
	var remaining_profile_ids := {
		"annihilation-barge": "000000553", "ctan-shard-of-the-deceiver": "000000542",
		"ctan-shard-of-the-nightbringer": "000000541", "ctan-shard-of-the-void-dragon": "000002357",
		"canoptek-macrocytes": "000004176", "canoptek-spyders": "000000551",
		"canoptek-tomb-crawlers": "000004177", "doom-scythe": "000000545",
		"convergence-of-dominion": "000002361", "cryptothralls": "000002111",
		"geomancer": "000004178", "nekrosor-ammentar": "000004186", "night-scythe": "000000544",
		"obelisk": "000000557", "overlord-with-translocation-shroud": "000003693",
		"tesseract-vault": "000000556", "the-silent-king": "000002360", "tomb-blades": "000000548",
		"transcendent-ctan": "000000555"
	}
	check(remaining_profile_ids.size() == 19, "The source-fact expansion covers the nineteen previously identity-only sheets")
	for source: String in remaining_profile_ids:
		var record: Dictionary = Profiles.profile(source)
		var source_weapons: Dictionary = record.get("source_weapon_profiles", {})
		var reanimation_admitted := source != "the-silent-king"
		var deadly_demise_admitted: bool = record.get("supported_rule_ids", []).any(func(rule: String) -> bool: return rule.begins_with("deadly-demise-"))
		var deep_strike_admitted: bool = record.get("supported_rule_ids", []).has("deep-strike")
		var fnp_admitted: bool = record.get("supported_rule_ids", []).has("feel-no-pain-5")
		var scouts_admitted: bool = record.get("supported_rule_ids", []).any(func(rule: String) -> bool: return rule.begins_with("scouts-"))
		var necrodermis_admitted := source in ["ctan-shard-of-the-deceiver", "ctan-shard-of-the-nightbringer", "ctan-shard-of-the-void-dragon", "transcendent-ctan"]
		var enslaved_admitted := necrodermis_admitted
		var ctan_shard_admitted := source == "transcendent-ctan"
		var transdimensional_admitted := source == "transcendent-ctan"
		var stealth_admitted := source == "ctan-shard-of-the-deceiver"
		var remaining_abilities: Array = record.get("source_ability_names", []).filter(func(name: String) -> bool: return not (name == "Reanimation Protocols" and reanimation_admitted) and not (name == "Deadly Demise" and deadly_demise_admitted) and not (name == "Deep Strike" and deep_strike_admitted) and not (name == "Feel No Pain" and fnp_admitted) and not (name == "Scouts" and scouts_admitted) and not (name == "Necrodermis" and necrodermis_admitted) and not (name == "ENSLAVED STAR GOD" and enslaved_admitted) and not (name == "C’TAN SHARD" and ctan_shard_admitted) and not (name == "Transdimensional Displacement" and transdimensional_admitted) and not (name == "Stealth" and stealth_admitted))
		check(record.get("source_datasheet_id", "") == remaining_profile_ids[source] and record.get("source_scope", "") == "Necrons App v1.2", "New record preserves its verified App identity: " + source)
		check(not record.get("source_model_profiles", []).is_empty() and not record.get("source_composition_rows", []).is_empty() and not record.get("source_cost_rows", []).is_empty(), "New record retains local model, composition and cost rows: " + source)
		check(not source_weapons.get("ranged", []).is_empty() or not source_weapons.get("melee", []).is_empty(), "New record retains source weapon profiles: " + source)
		check(not record.get("source_ability_bindings", []).is_empty() and record.get("supported_rule_ids", []).has("reanimation-protocols") == reanimation_admitted and record.get("supported_rule_ids", []).has("necrodermis") == necrodermis_admitted and record.get("supported_rule_ids", []).has("enslaved-star-god") == enslaved_admitted and record.get("supported_rule_ids", []).has("ctan-shard") == ctan_shard_admitted and record.get("supported_rule_ids", []).has("transdimensional-displacement") == transdimensional_admitted and record.get("supported_rule_ids", []).has("stealth") == stealth_admitted and record.get("unsupported_abilities", []) == remaining_abilities, "New record maps Reanimation, C’tan rules and Deceiver Stealth while keeping other source abilities gated: " + source)
		check(record.get("source_file_sha256", {}).size() == 14 and record.source_file_sha256.get("Datasheets.csv", "") == Profiles.SOURCE_FILE_SHA256["Datasheets.csv"] and record.source_file_sha256.get("Datasheets_leader.csv", "") == Profiles.SOURCE_FILE_SHA256["Datasheets_leader.csv"], "New record carries the verified local source-file hashes: " + source)
		check(record.get("source_leader_relations", []).all(func(relation: Dictionary) -> bool: return relation.get("leader_id", "") == record.source_datasheet_id or relation.get("attached_id", "") == record.source_datasheet_id), "New record retains local Leader/Support relation rows: " + source)
		check(record.get("source_options", []).all(func(option: Dictionary) -> bool: return not option.get("implemented", true)), "New source options remain unavailable pending implementation: " + source)
		check(record.get("source_unmatched_loadout_equipment", []).all(func(item: Dictionary) -> bool: return item.get("reason", "") == "source wargear outside the weapon table"), "Default non-weapon wargear is distinguished from weapons: " + source)
		check(record.get("source_profile_readiness", "") == "source_facts_transcribed_implementation_pending" and not record.get("pending_source_checks", []).is_empty(), "Source transcription does not claim datasheet implementation: " + source)
	for source: String in Profiles.catalog():
		var record: Dictionary = Profiles.profile(source)
		check(record.get("source_datasheet_id", "") == Profiles.inventory().get(source, {}).get("id", "") and record.get("source_snapshot_id", "") == "20261031T053336Z", "Every transcribed record preserves the local source identity and snapshot: " + source)
		var resolution := Army.resolve("Necrons", "40kdc:11e:necrons:" + source)
		if source in ["royal-warden", "necron-warriors", "canoptek-reanimator", "immortals", "deathmarks", "flayed-ones", "canoptek-scarab-swarms", "hexmark-destroyer", "canoptek-doomstalker"]:
			check(str(resolution.get("error", "")).is_empty(), "The source-bounded Necron datasheet is admitted after its focused checks: " + source)
		else:
			check(str(resolution.get("error", "")).contains("Local validation pending"), "Other source transcriptions do not bypass their pending construction gates: " + source)
	var ability_probe := {"unit_abilities": {"implementation": AbilityCatalog.ID}, "squads": {70: {"owner": 1}}, "units": {701: {"owner": 1, "squad": 70, "wounds": 4, "definition_id": "40kdc:11e:necrons:canoptek-doomstalker"}}}
	check(AbilityCatalog.sources(ability_probe, 70, "deadly-demise-d3") == [701] and UnitAbilities.deadly_demise_value(ability_probe, 701) == "D3" and UnitAbilities.damaged_attack_penalty(ability_probe, 701) == -1, "Doomstalker maps its source Deadly Demise D3 and Damaged 4 effects to existing runtime paths")
	ability_probe.units[701].wounds = 5
	check(UnitAbilities.damaged_attack_penalty(ability_probe, 701) == 0, "Doomstalker Damaged 4 ends above four remaining wounds")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:doomsday-ark"
	ability_probe.units[701].wounds = 5
	check(UnitAbilities.deadly_demise_value(ability_probe, 701) == "D3" and UnitAbilities.damaged_attack_penalty(ability_probe, 701) == -1, "Doomsday Ark maps Deadly Demise D3 and Damaged 5 at its threshold")
	ability_probe.units[701].wounds = 6
	check(UnitAbilities.damaged_attack_penalty(ability_probe, 701) == 0, "Doomsday Ark Damaged 5 ends above five remaining wounds")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:monolith"
	check(AbilityCatalog.sources(ability_probe, 70, "deep-strike") == [701] and UnitAbilities.deadly_demise_value(ability_probe, 701) == "D6", "Monolith maps Deep Strike and its source Deadly Demise D6 profile")
	var new_deadly_profiles := {
		"annihilation-barge": ["deadly-demise-1", "1"],
		"ctan-shard-of-the-deceiver": ["deadly-demise-d6", "D6"],
		"ctan-shard-of-the-nightbringer": ["deadly-demise-d6", "D6"],
		"ctan-shard-of-the-void-dragon": ["deadly-demise-d6", "D6"],
		"canoptek-spyders": ["deadly-demise-1", "1"],
		"doom-scythe": ["deadly-demise-d3", "D3"],
		"night-scythe": ["deadly-demise-d3", "D3"],
		"obelisk": ["deadly-demise-d6", "D6"],
		"tesseract-vault": ["deadly-demise-d6-plus-three", "D6+3"],
		"transcendent-ctan": ["deadly-demise-d6", "D6"]
	}
	for identity: String in new_deadly_profiles:
		ability_probe.units[701].definition_id = "40kdc:11e:necrons:" + identity
		var current_profile := Profiles.profile(identity)
		var rule_id: String = new_deadly_profiles[identity][0]
		var value: String = new_deadly_profiles[identity][1]
		var source_binding: Array = current_profile.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "Deadly Demise")
		check(AbilityCatalog.sources(ability_probe, 70, rule_id) == [701] and UnitAbilities.deadly_demise_value(ability_probe, 701) == value, "New source profile maps its exact Deadly Demise expression: " + identity)
		check(source_binding.size() == 1 and source_binding[0].get("parameter", "") == value, "Mapped Deadly Demise expression matches the local ability binding: " + identity)
		check(current_profile.get("supported_rule_ids", []).has(rule_id) and not current_profile.get("unsupported_abilities", []).has("Deadly Demise"), "Deadly Demise support metadata follows the source binding: " + identity)
	for identity: String in ["ctan-shard-of-the-deceiver", "ctan-shard-of-the-nightbringer", "ctan-shard-of-the-void-dragon", "night-scythe", "obelisk", "transcendent-ctan"]:
		ability_probe.units[701].definition_id = "40kdc:11e:necrons:" + identity
		var deep_strike_profile := Profiles.profile(identity)
		check(AbilityCatalog.sources(ability_probe, 70, "deep-strike") == [701] and deep_strike_profile.get("supported_rule_ids", []).has("deep-strike") and deep_strike_profile.get("source_ability_names", []).has("Deep Strike"), "New source profile maps its locally recorded Deep Strike rule: " + identity)
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:transcendent-ctan"
	var transdimensional_profile := Profiles.profile("transcendent-ctan")
	var transdimensional_binding: Array = transdimensional_profile.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "Transdimensional Displacement")
	check(AbilityCatalog.sources(ability_probe, 70, "transdimensional-displacement") == [701] and transdimensional_binding.size() == 1 and transdimensional_profile.get("supported_rule_ids", []).has("transdimensional-displacement") and not transdimensional_profile.get("unsupported_abilities", []).has("Transdimensional Displacement"), "Transcendent C’tan maps its local Transdimensional Displacement ability into the movement resolver")
	for identity: String in ["ctan-shard-of-the-deceiver", "ctan-shard-of-the-nightbringer", "ctan-shard-of-the-void-dragon", "transcendent-ctan"]:
		ability_probe.units[701].definition_id = "40kdc:11e:necrons:" + identity
		var fnp_profile := Profiles.profile(identity)
		var fnp_source: Array = fnp_profile.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "Feel No Pain")
		UnitAbilities.enable(ability_probe)
		var fnp_rules: Variant = UnitPrevention.rules(ability_probe, 701)
		var prevented: Dictionary = WoundPrevention.resolve(1, 16, fnp_rules, "normal", func() -> int: return 5)
		var failed_fnp: Dictionary = WoundPrevention.resolve(1, 16, fnp_rules, "normal", func() -> int: return 4)
		check(fnp_source.size() == 1 and fnp_source[0].get("parameter", "") == "5+", "C'tan Feel No Pain target matches the local ability binding: " + identity)
		check(AbilityCatalog.sources(ability_probe, 70, "feel-no-pain-5") == [701] and fnp_profile.get("supported_rule_ids", []).has("feel-no-pain-5") and fnp_rules == [{"target": 5, "against": "any"}], "C'tan Feel No Pain 5+ enters the shared prevention rules: " + identity)
		check(prevented.get("prevented", 0) == 1 and prevented.get("lost", -1) == 0 and failed_fnp.get("lost", 0) == 1, "C'tan Feel No Pain 5+ prevents a 5 and fails on a 4: " + identity)
	var necrodermis_profiles := ["ctan-shard-of-the-deceiver", "ctan-shard-of-the-nightbringer", "ctan-shard-of-the-void-dragon", "transcendent-ctan"]
	for identity: String in necrodermis_profiles:
		ability_probe.units[701].definition_id = "40kdc:11e:necrons:" + identity
		UnitAbilities.enable(ability_probe)
		var current_profile := Profiles.profile(identity)
		var necrodermis_binding: Array = current_profile.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "Necrodermis")
		check(AbilityCatalog.sources(ability_probe, 70, "necrodermis") == [701] and current_profile.get("supported_rule_ids", []).has("necrodermis") and not current_profile.get("unsupported_abilities", []).has("Necrodermis"), "Local Necrodermis binding enters the shared damage resolver: " + identity)
		check(necrodermis_binding.size() == 1 and UnitAbilities.damage(ability_probe, 701, 3) == 2 and UnitAbilities.damage(ability_probe, 701, 1) == 1, "Necrodermis subtracts one allocated attack Damage to a minimum of one: " + identity)
		check(UnitAbilities.damage(ability_probe, 701, 3, "mortal") == 3, "Necrodermis does not reduce mortal wounds outside an allocated attack Damage characteristic: " + identity)
		check(UnitAbilities.cannot_be_warlord(ability_probe, 701) and AbilityCatalog.sources(ability_probe, 70, "enslaved-star-god") == [701], "ENSLAVED STAR GOD records the local Warlord restriction: " + identity)
	var transcendent_profile := Profiles.profile("transcendent-ctan")
	var ctan_shard_bindings: Array = transcendent_profile.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "C’TAN SHARD")
	var forged_ctan_enhancement := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:necrons:transcendent-ctan", "models": 1, "copies": 1, "enhancement_id": "forged-enhancement"}]})
	var plain_transcendent_selection := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:necrons:transcendent-ctan", "models": 1, "copies": 1}]})
	check(ctan_shard_bindings.size() == 1 and AbilityCatalog.cannot_receive_enhancements("40kdc:11e:necrons:transcendent-ctan") and transcendent_profile.get("supported_rule_ids", []).has("ctan-shard") and not transcendent_profile.get("unsupported_abilities", []).has("C’TAN SHARD") and Registry.KNOWN.get("ctan-shard", {}).get("supported", false), "The local Transcendent C’tan C’TAN SHARD binding records its Enhancement restriction")
	check(str(forged_ctan_enhancement.get("error", "")).contains("cannot be given Enhancements") and str(plain_transcendent_selection.get("error", "")).contains("Local validation pending"), "A forged Transcendent Enhancement is rejected while the unfinished sheet remains gated from construction")
	var warlord_probe := Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2, true)
	var warlord_probe_model := -1
	for model: int in warlord_probe.units:
		if int(warlord_probe.units[model].get("owner", -1)) == 1 and int(warlord_probe.units[model].get("wounds", 0)) > 0:
			warlord_probe_model = model
			break
	if warlord_probe_model > 0:
		warlord_probe.units[warlord_probe_model].definition_id = "40kdc:11e:necrons:ctan-shard-of-the-deceiver"
		warlord_probe.units[warlord_probe_model].keywords = ["NECRONS", "MONSTER", "CHARACTER", "EPIC HERO", "FLY", "C’TAN SHARD OF THE DECEIVER"]
		UnitAbilities.enable(warlord_probe)
		var projected_ctan_warlord := UnitActions.choices(warlord_probe, 1).any(func(option: Dictionary) -> bool: return option.get("action", "") == "warlord" and int(option.get("model", -1)) == warlord_probe_model)
		var forged_ctan_warlord := UnitActions.apply(warlord_probe, 1, {"action": "warlord", "model": warlord_probe_model, "target": -1, "value": ""}, Vector2.ZERO, func() -> int: return 6)
		var roster_probe := {"roster_validation": {"implementation": RosterValidation.ID, "digest": RosterValidation.digest(), "armies": {1: {}, 2: {}}}, "units": {warlord_probe_model: warlord_probe.units[warlord_probe_model].duplicate(true)}, "unit_abilities": {"warlords": {1: warlord_probe_model}}}
		var seal_error := RosterValidation.seal(roster_probe, 1)
		check(not projected_ctan_warlord and str(forged_ctan_warlord.get("error", "")).contains("cannot be selected as your Warlord") and seal_error.contains("cannot be selected as your Warlord"), "ENSLAVED STAR GOD blocks projected and forged Warlord selection and checked-roster sealing")
	else:
		check(false, "Local combat fixture contains a living model for the C’tan Warlord restriction check")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:ctan-shard-of-the-deceiver"
	var deceiver_profile := Profiles.profile("ctan-shard-of-the-deceiver")
	check(AbilityCatalog.sources(ability_probe, 70, "stealth") == [701] and deceiver_profile.get("supported_rule_ids", []).has("stealth") and not deceiver_profile.get("unsupported_abilities", []).has("Stealth"), "The Deceiver's locally listed Stealth ability uses the existing shared rule")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:canoptek-reanimator"
	ability_probe.units[701].wounds = 6
	ability_probe.units[701].feel_no_pain = []
	UnitAbilities.enable(ability_probe)
	var reanimator_fnp_source: Array = reanimator.get("source_ability_bindings", []).filter(func(binding: Dictionary) -> bool: return binding.get("name", "") == "Feel No Pain")
	var reanimator_fnp: Variant = UnitPrevention.rules(ability_probe, 701)
	var reanimator_prevented: Dictionary = WoundPrevention.resolve(1, 6, reanimator_fnp, "normal", func() -> int: return 4)
	var reanimator_failed: Dictionary = WoundPrevention.resolve(1, 6, reanimator_fnp, "normal", func() -> int: return 3)
	check(reanimator.get("supported_rule_ids", []) == ["feel-no-pain-4", "reanimation-protocols", "nanoscarab-reanimation-beam"] and reanimator.get("unsupported_abilities", []).is_empty(), "Canoptek Reanimator's three source abilities are implemented")
	check(reanimator_fnp_source.size() == 1 and reanimator_fnp_source[0].get("parameter", "") == "4+" and reanimator_fnp == [{"target": 4, "against": "any"}], "Reanimator Feel No Pain 4+ matches its local binding and stays model-only")
	check(AbilityCatalog.sources(ability_probe, 70, "feel-no-pain-4") == [701] and AbilityCatalog.sources(ability_probe, 70, "nanoscarab-reanimation-beam") == [701], "Reanimator prevention and aura abilities register from the local source sheet")
	check(reanimator_prevented.get("prevented", 0) == 1 and reanimator_prevented.get("lost", -1) == 0 and reanimator_failed.get("lost", 0) == 1, "Reanimator Feel No Pain 4+ prevents a 4 and fails on a 3")
	for scout_profile: Array in [["canoptek-macrocytes", 8], ["tomb-blades", 9]]:
		var identity: String = scout_profile[0]
		var distance: int = scout_profile[1]
		ability_probe.units[701].definition_id = "40kdc:11e:necrons:" + identity
		UnitAbilities.enable(ability_probe)
		var current_profile: Dictionary = Profiles.profile(identity)
		var scout_rule := "scouts-%d" % distance
		check(AbilityCatalog.sources(ability_probe, 70, scout_rule) == [701] and UnitAbilities.scout_distance(ability_probe, 70) == distance, "Necron Scouts resolves from the exact local distance: " + identity)
		check(current_profile.get("supported_rule_ids", []).has(scout_rule) and not current_profile.get("unsupported_abilities", []).has("Scouts"), "Scouts support metadata follows the local source parameter: " + identity)
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:catacomb-command-barge"
	check(UnitAbilities.deadly_demise_value(ability_probe, 701) == "1", "Catacomb Command Barge maps the source Deadly Demise 1 profile")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:triarch-stalker"
	check(AbilityCatalog.sources(ability_probe, 70, "scouts-8") == [701] and UnitAbilities.deadly_demise_value(ability_probe, 701) == "D3", "Triarch Stalker maps source Scouts 8 and Deadly Demise D3")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:hexmark-destroyer"
	check(AbilityCatalog.sources(ability_probe, 70, "deep-strike") == [701] and AbilityCatalog.sources(ability_probe, 70, "lone-operative") == [701] and AbilityCatalog.sources(ability_probe, 70, "inescapable-death") == [701] and AbilityCatalog.sources(ability_probe, 70, "multi-threat-eliminator") == [701], "Hexmark Destroyer maps Deep Strike, Lone Operative, Inescapable Death and Multi-threat Eliminator")
	ability_probe.units[701].definition_id = "40kdc:11e:necrons:ophydian-destroyers"
	check(AbilityCatalog.sources(ability_probe, 70, "deep-strike") == [701], "Ophydian Destroyers map to the shared Deep Strike resolver")
	var resolved := Army.resolve("Necrons", "40kdc:11e:necrons:necron-warriors")
	check(resolved.get("error", "").is_empty() and int(resolved.get("cost", -1)) == 85 and resolved.get("pack_hash", "") == Profiles.digest(), "The locally validated 10-model source profile resolves at 85 points")
	var resolved_warden := Army.resolve("Necrons", "40kdc:11e:necrons:royal-warden")
	check(resolved_warden.get("error", "").is_empty() and int(resolved_warden.get("cost", -1)) == 50, "The source-bounded Royal Warden is admitted at its local fixed cost")
	var resolved_reanimator := Army.resolve("Necrons", "40kdc:11e:necrons:canoptek-reanimator")
	check(resolved_reanimator.get("error", "").is_empty() and int(resolved_reanimator.get("cost", -1)) == 75 and resolved_reanimator.get("pack_hash", "") == Profiles.digest(), "The locally checked Canoptek Reanimator resolves at its fixed App cost")
	var legacy := Army.resolve("Necrons", "40kdc:11e:necrons:necron-warriors", false)
	check(legacy.get("error", "").is_empty() and legacy.get("pack_hash", "") != Profiles.digest(), "Historical Necron training still resolves through its separate starter pack")
	var legacy_state := {"units": {1: {"definition_id": "40kdc:11e:necrons:necron-warriors", "owner": 1}}, "pack_hash": "legacy-necron-fixture"}
	var legacy_loadout_error := Prepared._current_loadouts(legacy_state)
	check(legacy_loadout_error.is_empty(), "Historical Warrior unit-ability loadout resolves through the starter pack: " + legacy_loadout_error)
	if legacy_loadout_error.is_empty():
		check(legacy_state.units[1].ranged_weapons[0].profiles.standard == legacy.weapons.gun, "Historical unit-ability loadout retains the starter weapon profile")
		check(legacy_state.pack_hash == "legacy-necron-fixture", "Historical unit-ability loadout does not inherit the current source digest")
	var ten := Army.admit({"schema_version": 2, "faction": "Necrons", "entries": [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}], "category": "custom", "points_limit": 1000})
	var twenty := Army.admit({"schema_version": 2, "faction": "Necrons", "entries": [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 20, "copies": 1}], "category": "custom", "points_limit": 1000})
	check(ten.get("error", "").is_empty() and ten.get("total", -1) == 85 and twenty.get("error", "").is_empty() and twenty.get("total", -1) == 190, "Army admission supports both source-priced Warrior sizes")
	var catalog := Catalog.new()
	root.add_child(catalog)
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog loads")
	var warrior_catalog := catalog.lookup("40kdc:11e:necrons:necron-warriors")
	check(warrior_catalog.get("source_id", "") == "necron-warriors" and warrior_catalog.get("options", []) == [{"models": 10, "cost": 85}, {"models": 20, "cost": 190}], "The consolidated catalog offers both validated Warrior sizes and source prices")
	check(catalog.lookup("40kdc:11e:necrons:canoptek-reanimator").get("options", []) == [{"models": 1, "cost": 75}], "The consolidated catalog offers the locally checked fixed Reanimator profile")
	check(catalog.lookup("40kdc:11e:necrons:royal-warden").get("source_id", "") == "royal-warden" and catalog.lookup("40kdc:11e:necrons:royal-warden").get("options", []) == [{"models": 1, "cost": 50}], "The consolidated catalog offers the locally validated Royal Warden configuration")
	var current_choice := Army.current_catalog_choice({"id": "40kdc:11e:necrons:necron-warriors", "edition": "11e", "faction": "Necrons"})
	check(current_choice.get("options", []) == [{"models": 10, "cost": 85}, {"models": 20, "cost": 190}], "The army builder exposes both current source-priced Warrior configurations")
	var source_sheets := Profiles.inventory()
	var source_ids: Dictionary = {}
	var necron_spec_count := 0
	for source: String in source_sheets:
		var identity: String = str(source_sheets[source].get("id", ""))
		check(not identity.is_empty() and not source_ids.has(identity), "The source inventory has a non-empty, unique datasheet ID: " + source)
		source_ids[identity] = true
		check(Army.SPECS.has(source), "Every local Necrons App sheet has a runtime admission record: " + source)
		if Army.SPECS.has(source):
			var spec: Dictionary = Army.SPECS[source]
			check(spec.get("source_datasheet_id", "") == identity and spec.get("source_name", "") == source_sheets[source].get("name", ""), "Runtime identity metadata matches the local sheet: " + source)
			var readiness_ok: bool = spec.get("validation_status", "") in ["implemented_local_checks_pending", "local_checks_pending"]
			if source in ["royal-warden", "necron-warriors", "canoptek-reanimator", "immortals", "deathmarks", "flayed-ones", "canoptek-scarab-swarms", "hexmark-destroyer", "canoptek-doomstalker"]: readiness_ok = spec.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_31"
			check(spec.get("current_reference", false) and readiness_ok, "Necron readiness status follows completed local datasheet scopes while other sheets remain gated: " + source)
	for source: String in Army.SPECS:
		if Army.SPECS[source].get("faction", "") == "Necrons": necron_spec_count += 1
	check(source_sheets.size() == 51 and source_ids.size() == 51 and necron_spec_count == 51, "The Necrons App v1.2 source inventory and runtime gate cover the same 51 sheets")
	for source: String in Army.SPECS:
		if Army.SPECS[source].faction == "Necrons" and source not in ["necron-warriors", "royal-warden", "canoptek-reanimator", "immortals", "deathmarks", "flayed-ones", "canoptek-scarab-swarms", "hexmark-destroyer", "canoptek-doomstalker"]:
			check(not catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id") == source), "Unimplemented Necron datasheets remain outside construction: " + source)
	check(catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "royal-warden") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "necron-warriors") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "canoptek-reanimator") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "immortals") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "deathmarks") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "flayed-ones") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "canoptek-scarab-swarms") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "hexmark-destroyer") and catalog.catalog.units.any(func(unit: Dictionary) -> bool: return unit.get("source_id", "") == "canoptek-doomstalker") and catalog.catalog.units.filter(func(unit: Dictionary) -> bool: return unit.get("faction", "") == "Necrons").size() == 9, "Nine of the 51 current Necrons App sheets have cleared local construction admission")
	if failures == 0: print("Current Necron source-profile checks: passed")
	else: print("Current Necron Warriors checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

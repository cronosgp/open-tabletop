extends SceneTree

const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func model(identity: String, squad: int, owner: int = 1, role: String = "") -> Dictionary:
	var unit := {
		"definition_id": "40kdc:11e:adeptus-astartes:" + identity,
		"owner": owner,
		"squad": squad,
		"wounds": 1,
		"max_wounds": 1,
		"on_battlefield": true
	}
	if identity == "chaplain-grimaldus": unit.chaplain_grimaldus_role = "chaplain"
	if not role.is_empty():
		unit.attachment_role = role
	return unit

func fixture(source: String, target: String, include_calgar: bool = false) -> Dictionary:
	var state := {
		"squads": {
			1: {"owner": 1, "name": source, "starting_strength": 1, "disabled_abilities": [], "stats": {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "melee_invulnerable_target": 0, "leadership_target": 6, "objective_control": 1}},
			2: {"owner": 1, "name": target, "starting_strength": 1, "disabled_abilities": [], "stats": {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "melee_invulnerable_target": 0, "leadership_target": 6, "objective_control": 1}}
		},
		"units": {
			100: model(source, 1),
			200: model(target, 2)
		}
	}
	if include_calgar:
		state.squads[3] = {"owner": 1, "disabled_abilities": []}
		state.units[300] = model("marneus-calgar", 3)
	UnitAbilities.enable(state)
	return state

func preparation_fixture(source: String, target: String) -> Dictionary:
	var state := fixture(source, target)
	state.phase = "deployment"
	state.turn = 1
	state.round = 1
	state.revision = 0
	state.active = 1
	state.first_player = 1
	state.deployment = {"placed": {}, "order": []}
	state.mission = {"objectives": []}
	state.unit_abilities.setup_players = []
	return state

func sorted(values: Array) -> Array:
	var result := values.duplicate()
	result.sort()
	return result

func roster_entry(identity: String, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "copies": copies}

func _initialize() -> void:
	var relation_count := 0
	for source_variant: Variant in Links.TARGETS:
		var source := str(source_variant)
		var targets: Array = Links.TARGETS[source]
		relation_count += targets.size()
		var role := "support" if Supports.BODYGUARDS.has(source) else "leader"
		for target_variant: Variant in targets:
			var target := str(target_variant)
			var state := fixture(source, target)
			check(UnitAbilities.has(state, 1, role), "%s is not exposed as a %s action source" % [source, role])
			var allowed := UnitActions.attachment_allowed(state, 100, 2)
			check(allowed, "%s cannot attach to source-listed %s" % [source, target])
			check(UnitActions._attachment_role_for_target(state, state.units[100], 2) == role, "%s receives the wrong attachment role for %s" % [source, target])
	check(Links.TARGETS.size() == 37 and relation_count == 153, "The common-book source map must retain all 153 relations across 37 datasheets (got %d)" % relation_count)
	var chapter_relation_count := 0
	for source_variant: Variant in Links.CHAPTER_TARGETS:
		var source := str(source_variant)
		var role := "support" if Supports.BODYGUARDS.has(source) else "leader"
		for target_variant: Variant in Links.CHAPTER_TARGETS[source]:
			var target := str(target_variant)
			if target in Links.TARGETS.get(source, []): continue
			chapter_relation_count += 1
			var state := fixture(source, target)
			check(UnitAbilities.has(state, 1, role), "%s is not exposed as a %s source for Chapter target %s" % [source, role, target])
			var allowed := UnitActions.attachment_allowed(state, 100, 2)
			check(allowed, "%s cannot attach to source-listed Chapter target %s" % [source, target])
			check(UnitActions._attachment_role_for_target(state, state.units[100], 2) == role, "%s receives the wrong role for Chapter target %s" % [source, target])
	check(chapter_relation_count == 210, "Chapter maps must add 210 distinct source relations (got %d)" % chapter_relation_count)
	check(Links.CHAPTER_TARGETS.has("ulrik-the-slayer") and Links.targets("ulrik-the-slayer").size() == 6, "Ulrik's six Chapter-book Leader endpoints are recorded separately from the common-book map")
	check(Links.targets("iron-priest") == ["intercessor-squad", "wolf-guard-headtakers", "blood-claws", "assault-intercessor-squad", "grey-hunters"], "Iron Priest's five Space Wolves App Leader endpoints are recorded separately from the common-book map")
	check(Links.targets("wolf-priest") == ["wolf-guard-headtakers", "assault-intercessor-squad", "grey-hunters", "blood-claws", "bladeguard-veteran-squad", "intercessor-squad"], "Wolf Priest's six Space Wolves App Leader endpoints are recorded separately from the common-book map")

	for source_variant: Variant in Supports.BODYGUARDS:
		var source := str(source_variant)
		var missing_support_targets: Array[String] = []
		for target: String in Supports.BODYGUARDS[source]:
			if target not in Links.targets(source): missing_support_targets.append(target)
		check(missing_support_targets.is_empty(), "%s has Support targets missing from the merged current source relation map" % source)
	check(Supports.BODYGUARDS.has("castellan") and Supports.links("castellan").size() == 8, "Castellan's Support identity and all eight current-source bodyguard links are admitted")
	check(sorted(Supports.CONDITIONAL_BODYGUARDS["cato-sicarius"]) == sorted(Links.TARGETS["cato-sicarius"]), "Cato's conditional Support retains the same source-listed target")
	var support_assignment_checks := 0
	for source_variant: Variant in Supports.BODYGUARDS:
		var source := str(source_variant)
		for target: String in Supports.BODYGUARDS[source]:
			var entries: Array = [roster_entry(source), roster_entry(target)]
			check(Supports.matching_error(entries).is_empty(), "%s can fill a Support slot using its source-listed %s bodyguard" % [source, target])
			support_assignment_checks += 1
	var cato_support_entries: Array = [roster_entry("cato-sicarius"), roster_entry("marneus-calgar"), roster_entry("victrix-honour-guard")]
	check(Supports.matching_error(cato_support_entries).is_empty(), "Calgar enables Cato's conditional Support assignment to the source-listed Victrix Honour Guard")
	check(support_assignment_checks == 97, "The local matcher exercises every one of the 97 static Support/bodyguard pairs")
	var support_identities: Array[String] = []
	for source_variant: Variant in Supports.BODYGUARDS: support_identities.append(str(source_variant))
	support_identities.append("cato-sicarius")
	support_identities.sort()
	var competing_assignment_checks := 0
	for first_index in range(support_identities.size()):
		var first_support := support_identities[first_index]
		for second_index in range(first_index + 1, support_identities.size()):
			var second_support := support_identities[second_index]
			for target: String in Supports.links(first_support):
				if target not in Supports.links(second_support): continue
				var entries: Array = [roster_entry(first_support), roster_entry(second_support), roster_entry(target)]
				if first_support == "cato-sicarius" or second_support == "cato-sicarius": entries.append(roster_entry("marneus-calgar"))
				var can_share := [first_support, second_support] == ["apothecary", "lieutenant"]
				var matching_error := Supports.matching_error(entries)
				check(matching_error.is_empty() == can_share,
					"%s and %s %s one %s bodyguard slot" % [first_support, second_support, "may share" if can_share else "cannot share", target])
				competing_assignment_checks += 1
	check(competing_assignment_checks > 0, "Pairwise Support overlap checks exercise competing bodyguard assignments")

	var captain_titus := fixture("captain-titus", "terminator-assault-squad")
	check(not UnitActions.attachment_allowed(captain_titus, 100, 2), "Titus cannot attach to an unlisted Terminator Assault Squad")
	var techmarine := fixture("techmarine", "bladeguard-veteran-squad")
	check(not UnitActions.attachment_allowed(techmarine, 100, 2), "Techmarine cannot attach to an unlisted Bladeguard Veteran Squad")
	var captain := fixture("captain", "victrix-honour-guard")
	check(UnitActions.attachment_allowed(captain, 100, 2), "Captain can attach to the source-listed Victrix Honour Guard")
	var terminator_captain := fixture("captain-in-terminator-armour", "terminator-assault-squad")
	check(UnitActions.attachment_allowed(terminator_captain, 100, 2), "Terminator Captain can attach to the source-listed Terminator Assault Squad")
	var emperor_champion := fixture("emperor-s-champion", "intercessor-squad")
	check(sorted(Links.targets("emperor-s-champion")) == sorted(["assault-intercessor-squad", "intercessor-squad", "sternguard-veteran-squad", "crusader-squad", "sword-brethren-squad"]), "Emperor’s Champion keeps all five source-listed Leader identities")
	check(UnitAbilities.has(emperor_champion, 1, "leader") and UnitActions.attachment_allowed(emperor_champion, 100, 2), "Emperor’s Champion can attach to the source-listed Intercessor endpoint")
	for source in ["captain-titus", "techmarine"]:
		var menu_state := preparation_fixture(source, "intercessor-squad")
		var has_warlord_choice := false
		var has_attachment_choice := false
		for option: Dictionary in UnitActions.choices(menu_state, 1):
			if option.action == "warlord" and option.model == 100: has_warlord_choice = true
			if option.action == "attach" and option.model == 100 and option.target == 2: has_attachment_choice = true
		check(has_warlord_choice, "%s is available as a Warlord during army preparation" % source)
		check(has_attachment_choice, "%s attachment target is exposed in the army-preparation action menu" % source)
	var cato_with_calgar := fixture("cato-sicarius", "victrix-honour-guard", true)
	check(UnitActions.is_support_identity(cato_with_calgar, cato_with_calgar.units[100]), "Cato changes to Support while Calgar is in the army")
	check(UnitActions.models(cato_with_calgar, 1, "support").has(100) and not UnitActions.models(cato_with_calgar, 1, "leader").has(100), "Cato's conditional Support role is exposed to the correct action selector")
	var cato_without_calgar := fixture("cato-sicarius", "victrix-honour-guard")
	check(not UnitActions.is_support_identity(cato_without_calgar, cato_without_calgar.units[100]), "Cato remains a Leader without Calgar")
	check(UnitActions.models(cato_without_calgar, 1, "leader").has(100) and UnitActions.models(cato_without_calgar, 1, "support").is_empty(), "Cato retains the Leader selector without Calgar")

	var support_reassignment := Supports.matching_error([
		roster_entry("ancient"), roster_entry("bladeguard-ancient"),
		roster_entry("bladeguard-veteran-squad"), roster_entry("intercessor-squad")])
	check(support_reassignment.is_empty(), "Roster matching reassigns a broad Ancient to Intercessors so the Bladeguard Ancient can use its sole bodyguard target")
	var support_collision := Supports.matching_error([
		roster_entry("ancient"), roster_entry("bladeguard-ancient"), roster_entry("bladeguard-veteran-squad")])
	check(not support_collision.is_empty(), "Roster matching rejects two Supports competing for one Bladeguard bodyguard")
	var legal_apothecary_lieutenant_pair := Supports.matching_error([
		roster_entry("apothecary"), roster_entry("lieutenant"), roster_entry("intercessor-squad")])
	check(legal_apothecary_lieutenant_pair.is_empty(), "An Apothecary/Lieutenant pair can share one eligible bodyguard assignment")
	var illegal_three_supports_one_body := Supports.matching_error([
		roster_entry("apothecary"), roster_entry("lieutenant"), roster_entry("judiciar"), roster_entry("intercessor-squad")])
	check(not illegal_three_supports_one_body.is_empty(), "The Apothecary/Lieutenant exception does not let a third Support join the same bodyguard")
	var legal_pair_and_judiciar := Supports.matching_error([
		roster_entry("apothecary"), roster_entry("lieutenant"), roster_entry("judiciar"),
		roster_entry("intercessor-squad"), roster_entry("bladeguard-veteran-squad")])
	check(legal_pair_and_judiciar.is_empty(), "A legal Apothecary/Lieutenant pair and a separate Judiciar fit on two distinct bodyguards")
	var cato_support_without_victrix := Supports.matching_error([
		roster_entry("cato-sicarius"), roster_entry("marneus-calgar"), roster_entry("intercessor-squad")])
	var cato_support_with_victrix := Supports.matching_error([
		roster_entry("cato-sicarius"), roster_entry("marneus-calgar"), roster_entry("victrix-honour-guard")])
	check(not cato_support_without_victrix.is_empty() and cato_support_with_victrix.is_empty(),
		"Cato's conditional Support slot requires Victrix Honour Guard when Calgar is in the roster")

	print("Space Marine Leader/Support link checks: %d source relations, %d failures" % [relation_count, failures])
	quit(0 if failures == 0 else 1)

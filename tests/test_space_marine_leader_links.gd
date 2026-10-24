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
	if not role.is_empty():
		unit.attachment_role = role
	return unit

func fixture(source: String, target: String, include_calgar: bool = false) -> Dictionary:
	var state := {
		"squads": {
			1: {"owner": 1, "name": source, "starting_strength": 1, "disabled_abilities": []},
			2: {"owner": 1, "name": target, "starting_strength": 1, "disabled_abilities": []}
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
			check(UnitActions.attachment_allowed(state, 100, 2), "%s cannot attach to source-listed %s" % [source, target])
	check(Links.TARGETS.size() == 37 and relation_count == 153, "The common-book source map must retain all 153 relations across 37 datasheets")

	for source_variant: Variant in Supports.BODYGUARDS:
		var source := str(source_variant)
		check(sorted(Supports.BODYGUARDS[source]) == sorted(Links.TARGETS.get(source, [])), "%s Support targets differ from the source Leader relation map" % source)
	check(sorted(Supports.CONDITIONAL_BODYGUARDS["cato-sicarius"]) == sorted(Links.TARGETS["cato-sicarius"]), "Cato's conditional Support retains the same source-listed target")

	var captain_titus := fixture("captain-titus", "terminator-assault-squad")
	check(not UnitActions.attachment_allowed(captain_titus, 100, 2), "Titus cannot attach to an unlisted Terminator Assault Squad")
	var techmarine := fixture("techmarine", "bladeguard-veteran-squad")
	check(not UnitActions.attachment_allowed(techmarine, 100, 2), "Techmarine cannot attach to an unlisted Bladeguard Veteran Squad")
	var captain := fixture("captain", "victrix-honour-guard")
	check(UnitActions.attachment_allowed(captain, 100, 2), "Captain can attach to the source-listed Victrix Honour Guard")
	var terminator_captain := fixture("captain-in-terminator-armour", "terminator-assault-squad")
	check(UnitActions.attachment_allowed(terminator_captain, 100, 2), "Terminator Captain can attach to the source-listed Terminator Assault Squad")
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
	check(UnitActions.models(cato_with_calgar, 1, "support").has(100) and UnitActions.models(cato_with_calgar, 1, "leader").is_empty(), "Cato's conditional Support role is exposed to the correct action selector")
	var cato_without_calgar := fixture("cato-sicarius", "victrix-honour-guard")
	check(not UnitActions.is_support_identity(cato_without_calgar, cato_without_calgar.units[100]), "Cato remains a Leader without Calgar")
	check(UnitActions.models(cato_without_calgar, 1, "leader").has(100) and UnitActions.models(cato_without_calgar, 1, "support").is_empty(), "Cato retains the Leader selector without Calgar")

	print("Space Marine Leader/Support link checks: %d source relations, %d failures" % [relation_count, failures])
	quit(0 if failures == 0 else 1)

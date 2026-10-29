extends SceneTree

const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Roster = preload("res://scripts/army_roster.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_entry(identity: String, copies: int, models: int, composition: String = "") -> Dictionary:
	var result := {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}
	if not composition.is_empty(): result.composition_choice_id = composition
	return result

func admit(category: String, entries: Array) -> Dictionary:
	var points_limit: int = int(Roster.LIMITS.get(category, 5000))
	if category == "custom": points_limit = 5000
	var selection := {"schema_version": 2, "faction": "Space Marines", "category": category, "points_limit": points_limit, "entries": entries}
	return Army.admit(selection, 24)

func cheapest_limit_entry(identity: String, copies: int) -> Dictionary:
	var profile := CurrentMarines.profile(identity)
	var source_points: Dictionary = profile.get("source_roster_points", profile)
	var points_by_models: Dictionary = source_points.get("points_by_models", profile.get("points_by_models", {}))
	var model_sizes: Array = Army.construction_model_sizes(identity, profile)
	model_sizes.sort_custom(func(first: Variant, second: Variant) -> bool:
		var first_cost := int(points_by_models[first])
		var second_cost := int(points_by_models[second])
		return first_cost < second_cost if first_cost != second_cost else int(first) < int(second))
	for model_variant: Variant in model_sizes:
		var models := int(model_variant)
		var composition_choice: Dictionary = {}
		if profile.has("composition_options"):
			var choices: Array[Dictionary] = []
			for option: Dictionary in profile.get("composition_options", []):
				if int(option.get("models", -1)) != models: continue
				var keywords := CurrentMarines.unit_keywords_for_composition(profile, option)
				if "EPIC HERO" in keywords and "EPIC HERO" not in profile.get("keywords", []): continue
				choices.append(option)
			choices.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
				var first_cost := int(first.get("wargear_cost", 0))
				var second_cost := int(second.get("wargear_cost", 0))
				return first_cost < second_cost if first_cost != second_cost else str(first.get("id", "")) < str(second.get("id", "")))
			if choices.is_empty(): continue
			composition_choice = choices[0]
		return make_entry(identity, copies, models, str(composition_choice.get("id", "")))
	return {}

func copy_limit_configurations(identity: String, profile: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var source_points: Dictionary = profile.get("source_roster_points", profile)
	var points_by_models: Dictionary = source_points.get("points_by_models", profile.get("points_by_models", {}))
	if profile.has("composition_options"):
		for option: Dictionary in profile.get("composition_options", []):
			var models := int(option.get("models", -1))
			if not points_by_models.has(models) or models not in Army.construction_model_sizes(identity, profile): continue
			var keywords := CurrentMarines.unit_keywords_for_composition(profile, option)
			if "EPIC HERO" in keywords: continue
			var choice_id := str(option.get("id", ""))
			var unit_cost := int(points_by_models[models]) + int(option.get("wargear_cost", 0))
			candidates.append({"key": "%02d:%s" % [models, choice_id], "entry": make_entry(identity, 1, models, choice_id), "cost": unit_cost})
	else:
		for models_variant: Variant in Army.construction_model_sizes(identity, profile):
			var models := int(models_variant)
			candidates.append({"key": "%02d" % models, "entry": make_entry(identity, 1, models), "cost": int(points_by_models[models_variant])})
	candidates.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		if int(first.cost) != int(second.cost): return int(first.cost) < int(second.cost)
		return str(first.key) < str(second.key))
	return candidates

func run() -> void:
	var current_profile_count := 0
	var common_profile_count := 0
	var chapter_profile_count := 0
	for identity: String in Army.SPECS:
		var spec: Dictionary = Army.SPECS[identity]
		if not spec.get("current_reference", false): continue
		var profile: Dictionary = CurrentMarines.profile(identity)
		check(not profile.is_empty(), "%s has a source-backed current profile for copy-limit evaluation" % identity)
		if profile.is_empty(): continue
		current_profile_count += 1
		if profile.get("source_book_id", "") == "000000139": common_profile_count += 1
		else: chapter_profile_count += 1
		var keywords: Array = profile.get("keywords", [])
		var expected_incursion := 1 if "EPIC HERO" in keywords else (4 if "BATTLELINE" in keywords or "DEDICATED TRANSPORT" in keywords else 2)
		var expected_strike_force := 1 if "EPIC HERO" in keywords else (6 if "BATTLELINE" in keywords or "DEDICATED TRANSPORT" in keywords else 3)
		check(Army.standard_unit_copy_limit("incursion", keywords) == expected_incursion, "%s uses its exported keywords for the Incursion repeat limit" % identity)
		check(Army.standard_unit_copy_limit("strike_force", keywords) == expected_strike_force, "%s uses its exported keywords for the Strike Force repeat limit" % identity)
	check(current_profile_count == 160 and common_profile_count == 85 and chapter_profile_count == 75,
		"The category audit covers all 160 runtime profiles (85 shared-book, 75 Chapter-book; got %d/%d/%d)" % [current_profile_count, common_profile_count, chapter_profile_count])
	var actual_strike_force_limit_profiles := 0
	for identity: String in Army.SPECS:
		if not Army.SPECS[identity].get("current_reference", false): continue
		var profile := CurrentMarines.profile(identity)
		var keywords := CurrentMarines.roster_keywords(identity, profile)
		var expected_limit := Army.standard_unit_copy_limit("strike_force", keywords)
		if expected_limit <= 0: continue
		var maximum_entry := cheapest_limit_entry(identity, expected_limit)
		check(not maximum_entry.is_empty(), "%s has a source-priced composition for an actual copy-limit admission" % identity)
		if maximum_entry.is_empty(): continue
		var at_limit := admit("strike_force", [maximum_entry])
		check(str(at_limit.get("error", "")).is_empty(), "%s admits %d copies at its Strike Force datasheet limit: %s" % [identity, expected_limit, str(at_limit.get("error", ""))])
		var above_limit_entry := maximum_entry.duplicate(true)
		above_limit_entry.copies = expected_limit + 1
		var above_limit := admit("strike_force", [above_limit_entry])
		var expected_error := "An army cannot include more than one EPIC HERO unit with the same datasheet:" if "EPIC HERO" in keywords else "Core-profile repetition limit exceeded:"
		check(str(above_limit.get("error", "")).begins_with(expected_error), "%s rejects copy %d through the correct Strike Force limit gate: %s" % [identity, expected_limit + 1, str(above_limit.get("error", ""))])
		actual_strike_force_limit_profiles += 1
	check(actual_strike_force_limit_profiles == 160,
		"Actual Strike Force admission checks cover all 160 current runtime profiles (got %d)" % actual_strike_force_limit_profiles)
	var actual_incursion_limit_profiles := 0
	for identity: String in Army.SPECS:
		if not Army.SPECS[identity].get("current_reference", false): continue
		var profile := CurrentMarines.profile(identity)
		var keywords := CurrentMarines.roster_keywords(identity, profile)
		var expected_limit := Army.standard_unit_copy_limit("incursion", keywords)
		if expected_limit <= 0: continue
		var maximum_entry := cheapest_limit_entry(identity, expected_limit)
		check(not maximum_entry.is_empty(), "%s has a source-priced composition for actual Incursion copy-limit admission" % identity)
		if maximum_entry.is_empty(): continue
		var at_limit := admit("incursion", [maximum_entry])
		check(str(at_limit.get("error", "")).is_empty(),
			"%s admits %d copies at its Incursion datasheet limit: %s" % [identity, expected_limit, str(at_limit.get("error", ""))])
		var above_limit_entry := maximum_entry.duplicate(true)
		above_limit_entry.copies = expected_limit + 1
		var above_limit := admit("incursion", [above_limit_entry])
		var expected_error := "An army cannot include more than one EPIC HERO unit with the same datasheet:" if "EPIC HERO" in keywords else "Core-profile repetition limit exceeded:"
		check(str(above_limit.get("error", "")).begins_with(expected_error),
			"%s rejects copy %d through the correct Incursion limit gate: %s" % [identity, expected_limit + 1, str(above_limit.get("error", ""))])
		actual_incursion_limit_profiles += 1
	check(actual_incursion_limit_profiles == 160,
		"Actual Incursion admission checks cover all 160 current runtime profiles (got %d)" % actual_incursion_limit_profiles)
	var split_configuration_profiles := 0
	for identity: String in Army.SPECS:
		if not Army.SPECS[identity].get("current_reference", false): continue
		var profile := CurrentMarines.profile(identity)
		var keywords := CurrentMarines.roster_keywords(identity, profile)
		var expected_limit := Army.standard_unit_copy_limit("strike_force", keywords)
		if expected_limit <= 1: continue
		var configurations := copy_limit_configurations(identity, profile)
		if configurations.size() < 2: continue
		var split_admitted := false
		for first_index in range(configurations.size()):
			for second_index in range(first_index + 1, configurations.size()):
				var first_entry: Dictionary = configurations[first_index].entry.duplicate(true)
				var second_entry: Dictionary = configurations[second_index].entry.duplicate(true)
				first_entry.copies = expected_limit - 1
				second_entry.copies = 1
				var at_limit := admit("strike_force", [first_entry, second_entry])
				if not str(at_limit.get("error", "")).is_empty(): continue
				second_entry.copies = 2
				var above_limit := admit("strike_force", [first_entry, second_entry])
				var expected_error := "An army cannot include more than one EPIC HERO unit with the same datasheet:" if "EPIC HERO" in keywords else "Core-profile repetition limit exceeded:"
				check(str(above_limit.get("error", "")).begins_with(expected_error),
					"%s counts copies split across model/composition configurations toward its Strike Force limit" % identity)
				split_configuration_profiles += 1
				split_admitted = true
				break
			if split_admitted: break
		check(split_admitted, "%s has an admitted mixed-configuration roster at its Strike Force repeat limit" % identity)
	check(split_configuration_profiles >= 30,
		"The source catalog exposes at least 30 current profiles with repeatable mixed configurations (got %d)" % split_configuration_profiles)

	# Exercise different datasheet caps and a Chapter restriction in one costed
	# Strike Force roster. Each profile is at its own cap; raising any one above
	# that cap must still be rejected among shared-book and Chapter-tagged units.
	var mixed_cap_identities: Array[String] = ["black-templars-impulsor", "lieutenant", "emperor-s-champion", "crusader-squad"]
	var mixed_cap_entries: Array[Dictionary] = []
	var mixed_cap_total_units := 0
	for identity: String in mixed_cap_identities:
		var profile := CurrentMarines.profile(identity)
		var keywords := CurrentMarines.roster_keywords(identity, profile)
		var limit := Army.standard_unit_copy_limit("strike_force", keywords)
		var entry := cheapest_limit_entry(identity, limit)
		check(not entry.is_empty(), "%s has a priced profile for the mixed-cap Strike Force roster" % identity)
		if entry.is_empty(): continue
		mixed_cap_entries.append(entry)
		mixed_cap_total_units += limit
	var mixed_cap_roster := admit("strike_force", mixed_cap_entries)
	check(mixed_cap_entries.size() == mixed_cap_identities.size() and mixed_cap_roster.error.is_empty(),
		"A mixed Strike Force admits Battleline, Dedicated Transport, non-Battleline, EPIC HERO and Black Templars profiles at their separate caps: %s" % str(mixed_cap_roster.get("error", "")))
	check(int(mixed_cap_roster.get("unit_count", 0)) == mixed_cap_total_units,
		"The combined cap roster preserves the sum of copies across distinct datasheets")
	for identity: String in mixed_cap_identities:
		var over_limit_entries: Array[Dictionary] = mixed_cap_entries.duplicate(true)
		for entry: Dictionary in over_limit_entries:
			if str(entry.definition_id).ends_with(":" + identity): entry.copies = int(entry.copies) + 1
		var profile := CurrentMarines.profile(identity)
		var keywords := CurrentMarines.roster_keywords(identity, profile)
		var over_limit := admit("strike_force", over_limit_entries)
		var expected_error := "An army cannot include more than one EPIC HERO unit with the same datasheet:" if "EPIC HERO" in keywords else "Core-profile repetition limit exceeded:"
		check(str(over_limit.get("error", "")).begins_with(expected_error),
			"The combined roster enforces %s's independent cap when that datasheet gains one copy" % identity)

	# Distinct sheets with the same repeat category must each retain their own cap.
	var paired_battleline_entries: Array[Dictionary] = [
		make_entry("intercessor-squad", 6, 5),
		make_entry("assault-intercessor-squad", 6, 5)]
	var paired_battleline_roster := admit("strike_force", paired_battleline_entries)
	check(paired_battleline_roster.error.is_empty() and int(paired_battleline_roster.get("unit_count", 0)) == 12,
		"A Strike Force can simultaneously take six copies of each of two distinct Battleline datasheets: %s" % str(paired_battleline_roster.get("error", "")))
	for identity: String in ["intercessor-squad", "assault-intercessor-squad"]:
		var over_limit_entries: Array[Dictionary] = paired_battleline_entries.duplicate(true)
		for entry: Dictionary in over_limit_entries:
			if str(entry.definition_id).ends_with(":" + identity): entry.copies = 7
		var over_limit := admit("strike_force", over_limit_entries)
		check(str(over_limit.get("error", "")).begins_with("Core-profile repetition limit exceeded:"),
			"The paired Battleline roster rejects a seventh %s without confusing the other datasheet's cap" % identity)
	var paired_transport_entries: Array[Dictionary] = [
		make_entry("rhino", 6, 1),
		make_entry("drop-pod", 6, 1)]
	var paired_transport_roster := admit("strike_force", paired_transport_entries)
	check(paired_transport_roster.error.is_empty() and int(paired_transport_roster.get("unit_count", 0)) == 12,
		"A Strike Force can simultaneously take six copies of each of two distinct Dedicated Transport datasheets: %s" % str(paired_transport_roster.get("error", "")))
	for identity: String in ["rhino", "drop-pod"]:
		var over_limit_entries: Array[Dictionary] = paired_transport_entries.duplicate(true)
		for entry: Dictionary in over_limit_entries:
			if str(entry.definition_id).ends_with(":" + identity): entry.copies = 7
		var over_limit := admit("strike_force", over_limit_entries)
		check(str(over_limit.get("error", "")).begins_with("Core-profile repetition limit exceeded:"),
			"The paired transport roster rejects a seventh %s without confusing the other datasheet's cap" % identity)

	var incursion_two_non_battleline := admit("incursion", [make_entry("sternguard-veteran-squad", 2, 5)])
	var incursion_three_non_battleline := admit("incursion", [make_entry("sternguard-veteran-squad", 3, 5)])
	check(incursion_two_non_battleline.error.is_empty() and "wahapedia-e11-core-rules-25.03" == incursion_two_non_battleline.copy_limit_basis, "Incursion admits two non-Battleline copies and reports the Core Rules basis")
	check(not incursion_three_non_battleline.error.is_empty(), "Incursion rejects a third non-Battleline copy even if its profile has a higher local ceiling")

	var strike_three_non_battleline := admit("strike_force", [make_entry("sternguard-veteran-squad", 3, 5)])
	var strike_four_non_battleline := admit("strike_force", [make_entry("sternguard-veteran-squad", 4, 5)])
	check(strike_three_non_battleline.error.is_empty(), "Strike Force admits the third non-Battleline copy above the old Incursion ceiling")
	check(not strike_four_non_battleline.error.is_empty(), "Strike Force rejects a fourth non-Battleline copy")

	var incursion_four_battleline := admit("incursion", [make_entry("intercessor-squad", 4, 5)])
	var incursion_five_battleline := admit("incursion", [make_entry("intercessor-squad", 5, 5)])
	var strike_six_battleline := admit("strike_force", [make_entry("intercessor-squad", 6, 5)])
	var strike_seven_battleline := admit("strike_force", [make_entry("intercessor-squad", 7, 5)])
	check(incursion_four_battleline.error.is_empty() and not incursion_five_battleline.error.is_empty(), "Incursion doubles the datasheet limit for Battleline from two to four")
	check(strike_six_battleline.error.is_empty() and not strike_seven_battleline.error.is_empty(), "Strike Force doubles the datasheet limit for Battleline from three to six")

	var incursion_four_transports := admit("incursion", [make_entry("rhino", 4, 1)])
	var incursion_five_transports := admit("incursion", [make_entry("rhino", 5, 1)])
	var strike_six_transports := admit("strike_force", [make_entry("rhino", 6, 1)])
	var strike_seven_transports := admit("strike_force", [make_entry("rhino", 7, 1)])
	check(incursion_four_transports.error.is_empty() and not incursion_five_transports.error.is_empty(), "Incursion doubles the datasheet limit for Dedicated Transports")
	check(strike_six_transports.error.is_empty() and not strike_seven_transports.error.is_empty(), "Strike Force doubles the datasheet limit for Dedicated Transports")

	var one_epic := admit("strike_force", [make_entry("roboute-guilliman", 1, 1)])
	var two_epic := admit("strike_force", [make_entry("roboute-guilliman", 2, 1)])
	check(one_epic.error.is_empty() and not two_epic.error.is_empty(), "EPIC HERO profiles stay limited to one in every standard battle size")

	var victrix := CurrentMarines.profile("victrix-honour-guard")
	var guards_option: Dictionary = {}
	var champion_option: Dictionary = {}
	for option: Dictionary in victrix.get("composition_options", []):
		if int(option.models) != 3: continue
		if option.id == "guards-only": guards_option = option
		if option.id == "champion": champion_option = option
	var guards_keywords := CurrentMarines.unit_keywords_for_composition(victrix, guards_option)
	var champion_keywords := CurrentMarines.unit_keywords_for_composition(victrix, champion_option)
	check(not guards_keywords.has("EPIC HERO") and champion_keywords.has("EPIC HERO"), "Victrix composition keywords include EPIC HERO only when the Chapter Champion is selected")
	var two_guards := admit("incursion", [make_entry("victrix-honour-guard", 2, 3, "guards-only")])
	var one_guard_and_epic := admit("incursion", [make_entry("victrix-honour-guard", 1, 3, "guards-only"), make_entry("victrix-honour-guard", 1, 3, "champion")])
	var two_epic_compositions := admit("strike_force", [make_entry("victrix-honour-guard", 1, 3, "guards-only"), make_entry("victrix-honour-guard", 2, 3, "champion")])
	check(two_guards.error.is_empty(), "Two pure Victrix guard units are not incorrectly treated as Epic Heroes")
	check(one_guard_and_epic.error.is_empty(), "The sheet repetition count is shared across configurations while the Epic Hero count remains one")
	check(not two_epic_compositions.error.is_empty(), "Two Victrix configurations containing Epic Hero models exceed the one-Epic-Hero limit")

	var project_category := admit("custom", [make_entry("sternguard-veteran-squad", 2, 5)])
	check(project_category.error.is_empty() and project_category.copy_limit_basis == "project-local-supported-copy-ceiling", "Custom-point rosters keep the clearly labeled local ceiling")

	var space_wolves_battleline_four := admit("incursion", [make_entry("blood-claws", 4, 10)])
	var space_wolves_battleline_five := admit("incursion", [make_entry("blood-claws", 5, 10)])
	check(space_wolves_battleline_four.error.is_empty(), "Actual Incursion admission applies the four-copy Battleline cap to Space Wolves Blood Claws")
	check(not space_wolves_battleline_five.error.is_empty(), "Actual Incursion admission rejects a fifth Space Wolves Blood Claw copy")
	var mixed_chapter_roster := admit("custom", [make_entry("crusader-squad", 1, 10), make_entry("blood-claws", 1, 10)])
	check(str(mixed_chapter_roster.get("error", "")).contains("more than one Chapter"),
		"Roster admission rejects a Black Templars and Space Wolves datasheet mix")
	var black_templars_shared_roster := admit("incursion", [
		make_entry("crusader-squad", 1, 10),
		make_entry("intercessor-squad", 1, 5),
		make_entry("rhino", 1, 1),
		make_entry("sternguard-veteran-squad", 1, 5),
	])
	check(black_templars_shared_roster.error.is_empty() and int(black_templars_shared_roster.get("unit_count", 0)) == 4,
		"Incursion admits a Black Templars unit with three shared-book profiles in one roster")
	var tagged_chapter_profile_count := 0
	var profiles_by_chapter: Dictionary = {}
	for identity: String in Army.SPECS:
		if not Army.SPECS[identity].get("current_reference", false): continue
		var profile := CurrentMarines.profile(identity)
		var chapters := CurrentMarines.chapter_keywords(identity)
		check(chapters.size() <= 1, "%s carries at most one Chapter faction keyword" % identity)
		if chapters.size() != 1: continue
		tagged_chapter_profile_count += 1
		var roster_entry := {"identity": identity, "entry": cheapest_limit_entry(identity, 1)}
		if not profiles_by_chapter.has(chapters[0]): profiles_by_chapter[chapters[0]] = []
		profiles_by_chapter[chapters[0]].append(roster_entry)
	check(tagged_chapter_profile_count >= 75, "The audit verifies Chapter keywords across all Chapter-book runtime profiles")
	var chapter_names: Array = profiles_by_chapter.keys()
	chapter_names.sort()
	var same_chapter_checks := 0
	var cross_chapter_checks := 0
	var cross_chapter_pair_coverage: Dictionary = {}
	for chapter_variant: Variant in chapter_names:
		var chapter := str(chapter_variant)
		var chapter_profiles: Array = profiles_by_chapter[chapter]
		var chapter_index := chapter_names.find(chapter_variant)
		for profile_index in range(chapter_profiles.size()):
			var profile_record: Dictionary = chapter_profiles[profile_index]
			var same_chapter_peer: Dictionary = {}
			for candidate_record: Dictionary in chapter_profiles:
				if candidate_record.identity == profile_record.identity: continue
				same_chapter_peer = candidate_record
				break
			check(not same_chapter_peer.is_empty(), "%s has a distinct same-Chapter roster peer" % profile_record.identity)
			if not same_chapter_peer.is_empty():
				var same_chapter_admission := admit("custom", [profile_record.entry, same_chapter_peer.entry])
				check(str(same_chapter_admission.get("error", "")).is_empty(),
					"%s is admitted with %s under its shared %s Chapter keyword" % [profile_record.identity, same_chapter_peer.identity, chapter])
				same_chapter_checks += 1
			var chapter_offset := profile_index % (chapter_names.size() - 1) + 1
			var other_chapter_index := (chapter_index + chapter_offset) % chapter_names.size()
			var other_chapter := str(chapter_names[other_chapter_index])
			var other_profiles: Array = profiles_by_chapter[other_chapter]
			var other_anchor: Dictionary = other_profiles[0]
			var mixed_admission := admit("custom", [profile_record.entry, other_anchor.entry])
			check(str(mixed_admission.get("error", "")).contains("more than one Chapter"),
				"%s is rejected with %s because their Chapter keywords conflict" % [profile_record.identity, other_anchor.identity])
			cross_chapter_pair_coverage[chapter + "->" + other_chapter] = true
			cross_chapter_checks += 1
	check(same_chapter_checks == tagged_chapter_profile_count,
		"Every Chapter profile participates in an accepted same-Chapter roster pair (%d/%d)" % [same_chapter_checks, tagged_chapter_profile_count])
	check(cross_chapter_checks == tagged_chapter_profile_count,
		"Every Chapter profile participates in a rejected cross-Chapter roster pair (%d/%d)" % [cross_chapter_checks, tagged_chapter_profile_count])
	var directed_chapter_pairs := 0
	for chapter_variant: Variant in chapter_names:
		var chapter := str(chapter_variant)
		for other_chapter_variant: Variant in chapter_names:
			var other_chapter := str(other_chapter_variant)
			if chapter == other_chapter: continue
			directed_chapter_pairs += 1
			var pair_key := chapter + "->" + other_chapter
			if cross_chapter_pair_coverage.has(pair_key): continue
			var first_profile: Dictionary = profiles_by_chapter[chapter][0]
			var second_profile: Dictionary = profiles_by_chapter[other_chapter][0]
			var mixed_admission := admit("custom", [first_profile.entry, second_profile.entry])
			check(str(mixed_admission.get("error", "")).contains("more than one Chapter"),
				"Roster admission rejects the %s and %s Chapter pair" % [chapter, other_chapter])
			cross_chapter_pair_coverage[pair_key] = true
	check(cross_chapter_pair_coverage.size() == directed_chapter_pairs,
		"Actual mixed-roster checks cover every directed cross-Chapter pairing (%d pairs)" % directed_chapter_pairs)
	print("Marine category copy-limit checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

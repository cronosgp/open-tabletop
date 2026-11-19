extends RefCounted
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
## Explicit admission to partial training, never certification of official armies.
const Checked = preload("res://scripts/edition_11/roster_validation.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Tactical = preload("res://scripts/edition_11/tactical_training.gd")
const DIRECTORY := "res://data/imported/starter-11e-v1"
const SPECS := {
	"Space Marines": {"folder": "adeptus-astartes", "source": "intercessor-squad", "models": 5, "template": 1,
		"aliases": ["40kdc:11e:adeptus-astartes:intercessor-squad", "openhammer:11e:Space%20Marines:8da0-4570-c3c-819f"]},
	"Necrons": {"folder": "necrons", "source": "necron-warriors", "models": 10, "template": 2,
		"aliases": ["40kdc:11e:necrons:necron-warriors", "openhammer:11e:Necrons:58e9-5212-f5a6-c12d"]}}

static func definition(faction: String) -> Dictionary:
	if not SPECS.has(faction): return {"error": "Training supports only Space Marines / Intercessors and Necrons / Warriors."}
	var spec: Dictionary = SPECS[faction]
	var pack := Pack.load_pack(DIRECTORY.path_join(spec.folder))
	if not pack.error.is_empty(): return {"error": "Prepare o pacote starter fixado: " + pack.error}
	for unit: Dictionary in pack.units:
		if unit.source_id != spec.source: continue
		for price: Dictionary in unit.get("points", []):
			if price.get("models") == spec.models and not price.has("models_max") and Roster.integer(price.get("cost"), 1):
				return {"error": "", "unit": unit, "models": spec.models, "cost": int(price.cost), "pack_hash": pack.manifest.units_sha256, "template": spec.template}
	return {"error": "Training profile, size, or cost is unresolved in the local pack."}

static func inspect(list: Variant, roster_context: Dictionary = {}, use_verified_current: bool = false) -> Dictionary:
	var error := Roster.validate(list)
	if not error.is_empty(): return {"error": error}
	if list.edition != "11e": return {"error": "The training engine only uses the implemented 11th edition pack."}
	if not SPECS.has(list.faction): return {"error": "This faction is outside local training scope."}
	var spec: Dictionary = SPECS[list.faction]
	var current_digest := Capabilities.current_reference_digest(list.faction) if use_verified_current else ""
	var verified_current: bool = not current_digest.is_empty() and not list.entries.is_empty()
	var mixed := false
	var requested := 0
	for entry: Dictionary in list.entries:
		requested += int(entry.copies)
		verified_current = verified_current and entry.source_digest == current_digest and str(entry.unit_id).begins_with("40kdc:11e:")
		if entry.unit_id not in spec.aliases or entry.get("enhancement_id", "") != "": mixed = true
	if mixed or requested > 2 or verified_current:
		var entries: Array[Dictionary] = []
		for entry: Dictionary in list.entries:
			if entry.faction != list.faction: return {"error": "Mixed factions are unsupported in core-profile training."}
			var selected := {"definition_id": Capabilities.canonical_id(list.faction, str(entry.unit_id)), "models": int(entry.models), "copies": int(entry.copies)}
			if SavedEquipment.supports(str(entry.unit_id)):
				var saved_loadouts: Array = []
				for copy_index in range(int(entry.copies)):
					saved_loadouts.append(Roster.model_equipment_loadouts(entry, copy_index) if SavedEquipment.is_model_scoped(str(entry.unit_id)) else Roster.model_equipment(entry, copy_index, 0))
				selected.saved_model_loadouts = saved_loadouts
			if SavedEquipment.supports_unit(str(entry.unit_id)):
				var unit_loadouts: Array[Dictionary] = []
				var has_saved_unit := false
				for copy_index in range(int(entry.copies)):
					unit_loadouts.append(Roster.unit_equipment(entry, copy_index))
					has_saved_unit = has_saved_unit or Roster.has_unit_equipment(entry, copy_index)
				if has_saved_unit: selected.saved_unit_loadouts = unit_loadouts
			if entry.get("enhancement_id", "") != "": selected.enhancement_id = str(entry.enhancement_id)
			if entry.has("composition_choice_id"): selected.composition_choice_id = str(entry.composition_choice_id)
			if entry.has("intercessor_sergeant_loadouts"): selected.intercessor_sergeant_loadouts = entry.intercessor_sergeant_loadouts.duplicate(true)
			if entry.has("intercessor_grenade_launcher_loadouts"):
				selected.intercessor_grenade_launcher_loadouts = entry.intercessor_grenade_launcher_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":intercessor-squad"):
				var launcher_loadouts: Array[Array] = []
				var has_launcher := false
				for copy_index in range(int(entry.copies)):
					var copy_loadouts := Roster.intercessor_grenade_launcher_loadouts(entry, copy_index)
					launcher_loadouts.append(copy_loadouts)
					has_launcher = has_launcher or copy_loadouts.has(true)
				if has_launcher: selected.intercessor_grenade_launcher_loadouts = launcher_loadouts
			if entry.has("eliminator_sergeant_loadouts"): selected.eliminator_sergeant_loadouts = entry.eliminator_sergeant_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":eliminator-squad"): selected.eliminator_sergeant_loadouts = Roster.eliminator_sergeant_loadouts(entry)
			if entry.has("eliminator_trooper_loadouts"): selected.eliminator_trooper_loadouts = entry.eliminator_trooper_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":eliminator-squad"): selected.eliminator_trooper_loadouts = Roster.eliminator_trooper_loadouts(entry)
			if str(entry.get("unit_id", "")).ends_with(":outrider-squad"):
				var outrider_loadouts: Array[Dictionary] = []
				for copy_index in range(int(entry.copies)): outrider_loadouts.append(Roster.outrider_loadout(entry, copy_index))
				selected.outrider_loadouts = outrider_loadouts
			if str(entry.get("unit_id", "")).ends_with(":ravenwing-darkshroud"):
				var darkshroud_loadouts: Array[String] = []
				for copy_index in range(int(entry.copies)): darkshroud_loadouts.append(Roster.ravenwing_darkshroud_loadout(entry, copy_index))
				selected.ravenwing_darkshroud_loadouts = darkshroud_loadouts
			if str(entry.get("unit_id", "")).ends_with(":land-speeder"):
				var land_speeder_loadouts: Array[String] = []
				for copy_index in range(int(entry.copies)): land_speeder_loadouts.append(str(Roster.model_equipment(entry, copy_index, 0).get("land_speeder_cannon", "onslaught")))
				selected.land_speeder_loadouts = land_speeder_loadouts
			if str(entry.get("unit_id", "")).ends_with(":land-speeder-vengeance"):
				var vengeance_loadouts: Array[String] = []
				for copy_index in range(int(entry.copies)): vengeance_loadouts.append(str(Roster.model_equipment(entry, copy_index, 0).get("land_speeder_vengeance_cannon", "heavy-bolter")))
				selected.land_speeder_vengeance_loadouts = vengeance_loadouts
			if str(entry.get("unit_id", "")).ends_with(":baal-predator"):
				var baal_loadouts: Array[Dictionary] = []
				for copy_index in range(int(entry.copies)): baal_loadouts.append(Roster.model_equipment(entry, copy_index, 0))
				selected.baal_predator_loadouts = baal_loadouts
			if str(entry.get("unit_id", "")).ends_with(":predator-destructor"):
				var destructor_loadouts: Array[Dictionary] = []
				for copy_index in range(int(entry.copies)): destructor_loadouts.append(Roster.model_equipment(entry, copy_index, 0))
				selected.predator_destructor_loadouts = destructor_loadouts
			if str(entry.get("unit_id", "")).ends_with(":predator-annihilator"):
				var annihilator_loadouts: Array[Dictionary] = []
				for copy_index in range(int(entry.copies)): annihilator_loadouts.append(Roster.model_equipment(entry, copy_index, 0))
				selected.predator_annihilator_loadouts = annihilator_loadouts
			if str(entry.get("unit_id", "")).ends_with(":hellblaster-squad"):
				selected.hellblaster_sergeant_pistol_loadouts = Roster.hellblaster_sergeant_pistol_loadouts(entry)
			if str(entry.get("unit_id", "")).ends_with(":assault-intercessor-squad"):
				selected.assault_intercessor_sergeant_loadouts = Roster.assault_intercessor_sergeant_loadouts(entry)
			if str(entry.get("unit_id", "")).ends_with(":heavy-intercessor-squad"):
				var heavy_intercessor_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): heavy_intercessor_loadouts.append(Roster.heavy_intercessor_bolter_loadouts(entry, copy_index))
				selected.heavy_intercessor_bolter_loadouts = heavy_intercessor_loadouts
			if str(entry.get("unit_id", "")).ends_with(":inceptor-squad"):
				var inceptor_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): inceptor_loadouts.append(Roster.inceptor_loadouts(entry, copy_index))
				selected.inceptor_loadouts = inceptor_loadouts
			if str(entry.get("unit_id", "")).ends_with(":invader-atvs"):
				var invader_atv_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): invader_atv_loadouts.append(Roster.invader_atv_loadouts(entry, copy_index))
				selected.invader_atv_loadouts = invader_atv_loadouts
			if str(entry.get("unit_id", "")).ends_with(":reiver-squad"):
				var reiver_loadouts: Array[Dictionary] = []
				var has_saved_reiver_loadout := false
				for copy_index in range(int(entry.copies)):
					reiver_loadouts.append(Roster.unit_equipment(entry, copy_index))
					has_saved_reiver_loadout = has_saved_reiver_loadout or Roster.has_unit_equipment(entry, copy_index)
				if has_saved_reiver_loadout: selected.reiver_loadouts = reiver_loadouts
			if str(entry.get("unit_id", "")).ends_with(":aggressor-squad"):
				var aggressor_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): aggressor_loadouts.append(Roster.aggressor_model_loadouts(entry, copy_index))
				selected.aggressor_loadouts = aggressor_loadouts
			if str(entry.get("unit_id", "")).ends_with(":scout-squad"):
				var scout_loadouts: Array[Array] = []
				var has_saved_scout_loadout := false
				for copy_index in range(int(entry.copies)):
					scout_loadouts.append(Roster.scout_loadout(entry, copy_index))
					has_saved_scout_loadout = has_saved_scout_loadout or Roster.has_model_equipment(entry, copy_index, 0)
				if has_saved_scout_loadout: selected.scout_loadouts = scout_loadouts
			if entry.has("necron_warrior_loadouts"): selected.necron_warrior_loadouts = entry.necron_warrior_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":necron-warriors"):
				var warrior_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): warrior_loadouts.append(Roster.necron_warrior_loadouts(entry, copy_index))
				selected.necron_warrior_loadouts = warrior_loadouts
			if entry.has("immortal_loadouts"): selected.immortal_loadouts = entry.immortal_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":immortals"):
				var immortal_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): immortal_loadouts.append(Roster.immortal_loadouts(entry, copy_index))
				selected.immortal_loadouts = immortal_loadouts
			if entry.has("canoptek_macrocytes_loadouts"): selected.canoptek_macrocytes_loadouts = entry.canoptek_macrocytes_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":canoptek-macrocytes"):
				var macrocyte_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): macrocyte_loadouts.append(Roster.canoptek_macrocytes_loadouts(entry, copy_index))
				selected.canoptek_macrocytes_loadouts = macrocyte_loadouts
			if entry.has("canoptek_spyders_loadouts"): selected.canoptek_spyders_loadouts = entry.canoptek_spyders_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":canoptek-spyders"):
				var spyder_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): spyder_loadouts.append(Roster.canoptek_spyders_loadouts(entry, copy_index))
				selected.canoptek_spyders_loadouts = spyder_loadouts
			if entry.has("canoptek_tomb_crawlers_loadouts"): selected.canoptek_tomb_crawlers_loadouts = entry.canoptek_tomb_crawlers_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":canoptek-tomb-crawlers"):
				var tomb_crawler_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): tomb_crawler_loadouts.append(Roster.canoptek_tomb_crawlers_loadouts(entry, copy_index))
				selected.canoptek_tomb_crawlers_loadouts = tomb_crawler_loadouts
			if entry.has("necron_annihilation_barge_loadouts"): selected.necron_annihilation_barge_loadouts = entry.necron_annihilation_barge_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":annihilation-barge"):
				var barge_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): barge_loadouts.append(Roster.necron_vehicle_loadouts(entry, copy_index))
				selected.necron_annihilation_barge_loadouts = barge_loadouts
			if entry.has("necron_monolith_loadouts"): selected.necron_monolith_loadouts = entry.necron_monolith_loadouts.duplicate(true)
			elif str(entry.get("unit_id", "")).ends_with(":monolith"):
				var monolith_loadouts: Array[Array] = []
				for copy_index in range(int(entry.copies)): monolith_loadouts.append(Roster.necron_vehicle_loadouts(entry, copy_index))
				selected.necron_monolith_loadouts = monolith_loadouts
			entries.append(selected)
		var report := Capabilities.admit({"schema_version": 2, "faction": list.faction, "entries": entries, "category": list.category, "points_limit": int(list.points_limit)}, Capabilities.MATCH_UNIT_CAP, roster_context)
		if report.error.is_empty(): report.saved_reference_points = Roster.summary(list).points
		return report
	var resolved := definition(list.faction)
	if not resolved.error.is_empty(): return resolved
	var count := 0
	for entry: Dictionary in list.entries:
		if entry.unit_id not in spec.aliases or entry.faction != list.faction:
			return {"error": "Unit is not implemented in this training mode: " + entry.name}
		if entry.models != spec.models:
			return {"error": "%s: training supports %d models per unit; the list specifies %d. Composition was not changed automatically." % [resolved.unit.name, spec.models, entry.models]}
		count += int(entry.copies)
	if count not in [1, 2]: return {"error": "Choose one or two units per player for this training mode."}
	var selection := {"schema_version": 1, "faction": list.faction, "definition_id": resolved.unit.id,
		"models": resolved.models, "copies": count, "category": list.category, "points_limit": int(list.points_limit)}
	var report := admit(selection)
	if report.error.is_empty(): report.saved_reference_points = Roster.summary(list).points
	return report

## Maps local stable miniature IDs to their canonical unit/model coordinates.
## Local IDs stay in the builder and never enter the shared roster.
static func stable_model_refs(list: Dictionary, selection: Dictionary) -> Dictionary:
	if int(selection.get("schema_version", 0)) != 2 or not selection.get("entries", []) is Array:
		return {"error": "Stable miniature mapping requires a current-catalog selection."}
	var groups := {}
	var unit_index := 0
	for canonical_entry: Dictionary in selection.entries:
		var key := Capabilities.configuration_key(canonical_entry)
		if groups.has(key): return {"error": "The canonical roster contains an ambiguous unit configuration."}
		groups[key] = {"start": unit_index, "copies": int(canonical_entry.get("copies", 0))}
		unit_index += int(canonical_entry.get("copies", 0))
	var ordinals := {}
	var models := {}
	var copies := {}
	for item: Dictionary in list.get("entries", []):
		var copy_ids := Roster.normalize_copy_instance_ids(item)
		for copy_index in range(int(item.get("copies", 0))):
			var projected := _canonical_entry_for_copy(list, item, copy_index)
			var key := Capabilities.configuration_key(projected)
			if not groups.has(key): return {"error": "A saved unit copy could not be mapped to its canonical match entry."}
			var group: Dictionary = groups[key]
			var ordinal := int(ordinals.get(key, 0))
			if ordinal >= int(group.copies): return {"error": "Saved copy identities do not match the canonical unit count."}
			var canonical_unit_index := int(group.start) + ordinal
			var copy_id := str(copy_ids[copy_index])
			copies[copy_id] = {"unit_index": canonical_unit_index}
			for model_index in range(int(item.get("models", 0))):
				var model_id := Roster.model_instance_id(item, copy_index, model_index)
				models[model_id] = {"unit_index": canonical_unit_index, "model_index": model_index}
			ordinals[key] = ordinal + 1
	for key: String in groups:
		if int(ordinals.get(key, 0)) != int(groups[key].copies):
			return {"error": "The canonical match roster contains copies without saved local identities."}
	return {"error": "", "models": models, "copies": copies}

## Converts persistent Army Builder Warlord/attachment candidates to bounded
## match-local coordinates. Stable profile IDs never leave the local builder.
static func stable_formation_declaration(list: Dictionary, refs: Dictionary) -> Dictionary:
	var model_refs: Variant = refs.get("models", {})
	var copy_refs: Variant = refs.get("copies", {})
	if not model_refs is Dictionary or not copy_refs is Dictionary:
		return {"error": "Saved formation candidates could not be mapped to the accepted roster."}
	var declaration: Dictionary = {}
	var warlord_id := str(list.get("warlord_model_id", ""))
	if not warlord_id.is_empty():
		if not model_refs.has(warlord_id): return {"error": "The saved Warlord does not map to a model in the accepted roster."}
		declaration.warlord = model_refs[warlord_id].duplicate(true)
	var assignments: Variant = list.get("leader_assignments", [])
	if not assignments is Array or assignments.size() > 100:
		return {"error": "Saved Leader assignments are invalid."}
	var mapped_assignments: Array[Dictionary] = []
	for assignment: Variant in assignments:
		if not assignment is Dictionary:
			return {"error": "A saved Leader assignment is invalid."}
		var leader_id := str(assignment.get("leader_model_id", ""))
		var target_id := str(assignment.get("target_copy_id", ""))
		if not model_refs.has(leader_id) or not copy_refs.has(target_id):
			return {"error": "A saved Leader assignment does not map to the accepted roster."}
		var target_ref: Variant = copy_refs[target_id]
		if not target_ref is Dictionary or typeof(target_ref.get("unit_index", null)) != TYPE_INT or int(target_ref.unit_index) < 0:
			return {"error": "A saved Leader assignment has an invalid bodyguard reference."}
		mapped_assignments.append({"leader": model_refs[leader_id].duplicate(true), "target_unit_index": int(target_ref.unit_index)})
	if not mapped_assignments.is_empty(): declaration.attachments = mapped_assignments
	if not valid_match_formation_declaration(declaration):
		return {"error": "Saved formation candidates have an invalid match reference."}
	return {"error": "", "declaration": declaration}

## Shape-only network validation. PreparedTraining still checks the choices
## against the source-bounded roster and current public rules before applying.
static func valid_match_formation_declaration(value: Variant) -> bool:
	if not value is Dictionary or value.size() > 2: return false
	for key: Variant in value:
		if str(key) not in ["warlord", "attachments"]: return false
	if value.has("warlord") and not _valid_match_model_ref(value.warlord): return false
	if value.has("attachments"):
		var attachments: Variant = value.attachments
		if not attachments is Array or attachments.size() > 100: return false
		for attachment: Variant in attachments:
			if not attachment is Dictionary or attachment.size() != 2 or not attachment.has("leader") or not attachment.has("target_unit_index"): return false
			if not _valid_match_model_ref(attachment.leader) or typeof(attachment.target_unit_index) != TYPE_INT or int(attachment.target_unit_index) < 0: return false
	return true

static func _valid_match_model_ref(value: Variant) -> bool:
	return value is Dictionary and value.size() == 2 and typeof(value.get("unit_index", null)) == TYPE_INT and typeof(value.get("model_index", null)) == TYPE_INT and int(value.unit_index) >= 0 and int(value.model_index) >= 0

static func _canonical_entry_for_copy(list: Dictionary, item: Dictionary, copy_index: int) -> Dictionary:
	var selected := {
		"definition_id": Capabilities.canonical_id(str(list.get("faction", "")), str(item.get("unit_id", ""))),
		"models": int(item.get("models", 0)), "copies": 1
	}
	if SavedEquipment.supports(str(item.unit_id)):
		selected.saved_model_loadouts = [Roster.model_equipment_loadouts(item, copy_index) if SavedEquipment.is_model_scoped(str(item.unit_id)) else Roster.model_equipment(item, copy_index, 0)]
	if SavedEquipment.supports_unit(str(item.unit_id)) and Roster.has_unit_equipment(item, copy_index): selected.saved_unit_loadouts = [Roster.unit_equipment(item, copy_index)]
	if str(item.get("enhancement_id", "")) != "": selected.enhancement_id = str(item.enhancement_id)
	if item.has("composition_choice_id"): selected.composition_choice_id = str(item.composition_choice_id)
	if str(item.get("unit_id", "")).ends_with(":intercessor-squad"):
		var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
		var rifle_choice := str(loadout.get("rifle_choice", "bolt-rifle"))
		var melee_choice := str(loadout.get("melee_choice", "knives-and-fists"))
		if rifle_choice != "bolt-rifle" or melee_choice != "knives-and-fists":
			selected.intercessor_rifle_choice = rifle_choice
			selected.intercessor_melee_choice = melee_choice
		var launcher_loadouts := Roster.intercessor_grenade_launcher_loadouts(item, copy_index)
		if launcher_loadouts.has(true): selected.intercessor_grenade_launcher_loadouts = [launcher_loadouts]
	if str(item.get("unit_id", "")).ends_with(":eliminator-squad"):
		selected.eliminator_sergeant_weapon_choice = str(Roster.model_equipment(item, copy_index, 0).get("eliminator_sergeant_ranged", "sniper"))
		var troopers: Array[String] = []
		for model_index in range(1, int(item.get("models", 0))):
			troopers.append(str(Roster.model_equipment(item, copy_index, model_index).get("eliminator_trooper_ranged", "sniper")))
		selected.eliminator_trooper_weapon_choices = troopers
	if str(item.get("unit_id", "")).ends_with(":outrider-squad"):
		selected.outrider_loadouts = [Roster.outrider_loadout(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":ravenwing-darkshroud"):
		selected.ravenwing_darkshroud_loadouts = [Roster.ravenwing_darkshroud_loadout(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":land-speeder"):
		selected.land_speeder_loadouts = [str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_cannon", "onslaught"))]
	if str(item.get("unit_id", "")).ends_with(":land-speeder-vengeance"):
		selected.land_speeder_vengeance_loadouts = [str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_vengeance_cannon", "heavy-bolter"))]
	if str(item.get("unit_id", "")).ends_with(":baal-predator"):
		selected.baal_predator_loadouts = [Roster.model_equipment(item, copy_index, 0)]
	if str(item.get("unit_id", "")).ends_with(":predator-destructor"):
		selected.predator_destructor_loadouts = [Roster.model_equipment(item, copy_index, 0)]
	if str(item.get("unit_id", "")).ends_with(":predator-annihilator"):
		selected.predator_annihilator_loadouts = [Roster.model_equipment(item, copy_index, 0)]
	if str(item.get("unit_id", "")).ends_with(":hellblaster-squad"):
		selected.hellblaster_sergeant_pistol_loadouts = [str(Roster.model_equipment(item, copy_index, 0).get("hellblaster_sergeant_pistol", "bolt-pistol"))]
	if str(item.get("unit_id", "")).ends_with(":assault-intercessor-squad"):
		selected.assault_intercessor_sergeant_loadouts = [Roster.assault_intercessor_sergeant_loadouts(item)[copy_index]]
	if str(item.get("unit_id", "")).ends_with(":heavy-intercessor-squad"):
		selected.heavy_intercessor_bolter_loadouts = [Roster.heavy_intercessor_bolter_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":inceptor-squad"):
		selected.inceptor_loadouts = [Roster.inceptor_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":invader-atvs"):
		selected.invader_atv_loadouts = [Roster.invader_atv_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":reiver-squad") and Roster.has_unit_equipment(item, copy_index):
		selected.reiver_loadouts = [Roster.unit_equipment(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":aggressor-squad"):
		selected.aggressor_loadouts = [Roster.aggressor_model_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":scout-squad") and Roster.has_model_equipment(item, copy_index, 0):
		selected.scout_loadouts = [Roster.scout_loadout(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":necron-warriors"):
		selected.necron_warrior_loadouts = [Roster.necron_warrior_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":immortals"):
		selected.immortal_loadouts = [Roster.immortal_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":canoptek-macrocytes"):
		selected.canoptek_macrocytes_loadouts = [Roster.canoptek_macrocytes_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":canoptek-spyders"):
		selected.canoptek_spyders_loadouts = [Roster.canoptek_spyders_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":canoptek-tomb-crawlers"):
		selected.canoptek_tomb_crawlers_loadouts = [Roster.canoptek_tomb_crawlers_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":annihilation-barge"):
		selected.necron_annihilation_barge_loadouts = [Roster.necron_vehicle_loadouts(item, copy_index)]
	if str(item.get("unit_id", "")).ends_with(":monolith"):
		selected.necron_monolith_loadouts = [Roster.necron_vehicle_loadouts(item, copy_index)]
	return selected

static func admit(selection: Variant, roster_context: Dictionary = {}, prefer_current_reference: bool = true) -> Dictionary:
	if selection is Dictionary and selection.get("schema_version") == 2: return Capabilities.admit(selection, Capabilities.MATCH_UNIT_CAP, roster_context, prefer_current_reference)
	if not selection is Dictionary or selection.size() != 7: return {"error": "Invalid public army selection."}
	for key: String in ["faction", "definition_id", "category"]:
		if not selection.get(key) is String: return {"error": "Invalid selection identity."}
	if selection.get("schema_version") != 1 or not Roster.integer(selection.get("copies"), 1, 2) or not Roster.integer(selection.get("models"), 1, 1000): return {"error": "Invalid training quantity."}
	if selection.category not in Roster.LIMITS or not Roster.integer(selection.get("points_limit"), 100, 100000): return {"error": "Invalid training budget."}
	if selection.category != "custom" and selection.points_limit != Roster.LIMITS[selection.category]: return {"error": "Category and points limit do not match."}
	var resolved := definition(selection.faction)
	if not resolved.error.is_empty(): return resolved
	if selection.definition_id != resolved.unit.id or selection.models != resolved.models: return {"error": "Profile or composition is unsupported in this training mode."}
	var total: int = resolved.cost * int(selection.copies)
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	# Only this minimal, canonical selection is shared; profile names, notes and prices are private.
	var canonical := {"schema_version": 1, "faction": str(selection.faction), "definition_id": str(selection.definition_id),
		"models": int(selection.models), "copies": int(selection.copies), "category": str(selection.category), "points_limit": int(selection.points_limit)}
	return {"error": "", "selection": canonical, "total": total, "unit_cost": resolved.cost, "pack_hash": resolved.pack_hash,
		"template": resolved.template, "unsupported_abilities": resolved.unit.get("unsupported_rules", []).duplicate()}

## Admission for a new match. Historical training and unreconciled profiles may
## still be inspected or used to reconstruct old saves, but cannot enter new
## construction through this boundary.
static func admit_current_catalog(list: Variant) -> Dictionary:
	var report := Capabilities.admit(list, Capabilities.MATCH_UNIT_CAP) if list is Dictionary and list.get("schema_version") == 2 and not list.has("edition") else inspect(list, {}, true)
	if not report.get("error", "").is_empty(): return report
	if int(report.selection.get("schema_version", 0)) != 2:
		return {"error": "This saved list uses a historical training profile and remains a legacy draft."}
	for resolved: Dictionary in report.get("definitions", {}).values():
		if not resolved.get("spec", {}).get("current_reference", false):
			return {"error": "This saved list contains historical profiles and remains a legacy draft."}
		if not resolved.get("unsupported_abilities", []).is_empty():
			return {"error": "%s has unsupported current datasheet abilities: %s" % [resolved.get("unit", {}).get("name", "A selected datasheet"), ", ".join(resolved.unsupported_abilities)]}
		if not resolved.get("unsupported_weapon_rules", []).is_empty():
			return {"error": "%s has unsupported weapon rules: %s" % [resolved.get("unit", {}).get("name", "A selected datasheet"), ", ".join(resolved.unsupported_weapon_rules)]}
	return report

static func digest(selection: Dictionary) -> String:
	var report := admit(selection)
	return JSON.stringify(report.selection).sha256_text() if report.error.is_empty() else ""

static func template(faction: String, category: String, limit: int) -> Dictionary:
	var resolved := definition(faction)
	if not resolved.error.is_empty(): return resolved
	var list := Roster.new_list("11e", faction, category, limit)
	list.name = "Training-compatible — " + faction
	list.pricing_source = "starter-training-v1"
	list.catalog_digest = resolved.pack_hash
	list.notes = "Partial training: fixed default weapons. Unit and faction abilities and official legality are not validated."
	for index in range(2):
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": "Linha de batalha", "models": resolved.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

static func reprice(list: Dictionary) -> Dictionary:
	var report := inspect(list)
	if not report.error.is_empty(): return report
	var updated := list.duplicate(true)
	updated.pricing_source = "starter-training-v1"
	updated.catalog_digest = definition(updated.faction).pack_hash if report.selection.schema_version == 2 else report.pack_hash
	for entry: Dictionary in updated.entries:
		if report.selection.schema_version == 2:
			var spec: Dictionary = SPECS[updated.faction]
			var identity: String = definition(updated.faction).unit.id if entry.unit_id in spec.aliases else Capabilities.canonical_id(updated.faction, entry.unit_id)
			var resolved: Dictionary = report.definitions[identity]
			if resolved.spec.get("current_reference", false):
				var profile := CurrentMarines.profile(identity.get_slice(":", 3))
				entry.cost = int(profile.get("points_by_models", {}).get(int(entry.models), resolved.cost))
				var second_tier: Dictionary = profile.get("second_plus_points_by_models", {})
				if second_tier.has(int(entry.models)): entry.second_plus_cost = int(second_tier[int(entry.models)])
				else: entry.erase("second_plus_cost")
				var tiered: Dictionary = profile.get("third_plus_points_by_models", {})
				if tiered.has(int(entry.models)): entry.third_plus_cost = int(tiered[int(entry.models)])
				else: entry.erase("third_plus_cost")
				var fourth_tier: Dictionary = profile.get("fourth_plus_points_by_models", {})
				if fourth_tier.has(int(entry.models)): entry.fourth_plus_cost = int(fourth_tier[int(entry.models)])
				else: entry.erase("fourth_plus_cost")
			else: entry.cost = resolved.cost
			entry.source_digest = resolved.pack_hash
		else:
			entry.cost = report.unit_cost
			entry.source_digest = report.pack_hash
	return {"error": "", "list": updated}

## Built-ins are independent copies, never inserted into a profile implicitly.
static func presets(checked: bool = false) -> Array[Dictionary]:
	var lists: Array[Dictionary] = []
	# New-match choices come only from the current local Space Marine catalog.
	# Historical starter and MFM-derived profiles remain available through their
	# explicit legacy loading paths; they are not fresh construction presets.
	var reference := Capabilities.reference_army("Space Marines")
	if reference.error.is_empty() and inspect(reference.list).error.is_empty(): lists.append(reference.list)
	for assault: bool in [false, true]:
		var tactical := Tactical.army(assault)
		if tactical.error.is_empty() and admit_current_catalog(tactical.list).error.is_empty(): lists.append(tactical.list)
	return lists

static func awakened_reference() -> Dictionary:
	var list := Roster.new_list("11e", "Necrons", "training", 500)
	list.id = "preset:necrons-awakened-v1"
	list.name = "Necrons • Overlord + Warriors + Immortals"
	list.pricing_source = "starter-training-v1"
	list.notes = "Command Protocols training; enable Awakened Dynasty and declare the Overlord attachment before deployment. Other rules and full legality are pending."
	for source: String in ["overlord", "necron-warriors", "immortals"]:
		var resolved := Capabilities.resolve("Necrons", "40kdc:11e:necrons:" + source, false)
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": "Necrons", "role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

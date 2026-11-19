# Local model variant database

The model database separates **visual identity**, **datasheet associations** and
**actual equipped weapons**. The exact ForceOrg label is the initial visual name
and weapon claim. Corrections are exceptions; indexing does not require reviewing
every sculpt. Rules admission and weapon legality remain owned by the consolidated
runtime profiles backed by the verified local Wahapedia 11e export.

## Implementation assessment and next priorities

The current direction fits weapon-driven visual selection: build one local index,
retain source identity and alternate associations, and resolve an equipped model
against available variants. Reviewing every sculpt before indexing would delay
discovery; label associations should remain usable while uncertain associations
enter a separate review queue. Download and geometry inspection belong after
selection, with reusable local assets, rather than before every catalog search.

The Models / Import search waits 150 ms after the last typed character and runs
immediately on Enter. It still filters the in-memory scanned entries linearly;
each entry's normalized search text is cached on first use. The local headless
profile measured 260 ms for the first query and 42 ms for the next, calling the
filter directly rather than exercising the debounce. Because this search is
confined to setup, retain the simple scan unless an interactive profile shows
that it delays use; a token index would add memory and build cost to every scan.

Repeated source scans now use a versioned binary cache under the user's local
`user://` data folder. It is keyed by the exact source path and SHA-256, and holds
the parsed static entries before datasheet links are applied. Every load reapplies
the current source-gated visual index, so rebuilding those links does not require
reparsing the save or retain stale associations. A cache miss for the 35,936-object
Workshop save took 6.68 seconds including a 1.32-second cache write; a later
process reloaded it in 1.35 seconds. The cache is local, optional, and excluded
from the project and distribution.

At this scale, the measured search and repeat-scan costs are already small. The
remaining delay is deciding whether a source label really matches a datasheet,
whether its asset can load, and whether the variant belongs to the selected visual
family. Keep discovery indexed and move those checks to the selected profile/model
rather than downloading and reviewing the whole library up front.

At match time, the renderer scores complete variants against the physical weapons
on each individual roster model; fire-mode profile names do not count as separate
weapons. It tries compatible equipment sculpts in the selected visual family
first, then a matching source-role sculpt there, followed by compatible equipment
sculpts already available in other families and their role matches. This lets a
weapon-specific model win when its selected-family sculpt is absent, while making
the palette change visible and predictable. Generic appearance, palette and
datasheet variants remain recovery choices after those specific candidates. A
missing exact sculpt falls back without changing the saved loadout. For
Intercessors, the Bolt Pistol is standard alongside the Bolt Rifle; a Grenade
Launcher is an additional option, so the useful visual distinction is the
standard Intercessor versus the Grenadier, not a pistol-versus-rifle choice. Only
admitted label/user associations feed this automatic path; pending candidates
remain searchable evidence.

The 6 November schema-8 database contains 35,884 source variants. Of those,
35,807 are classified as miniature, 59 as base, 16 as ignored and two as terrain. These are
root candidates from the selected captures, not a complete terrain/child-object
inventory. Only 10,008 miniature variants have recognized weapon terms. Absence
of a term means unknown, not weaponless. There are 22,772 miniature variants with
no source group; 4,187 variants associated with current runtime profiles also
have no declared group. The scanner can now derive a separate material family
for some of these entries; the actual-save audit found 1,665 Workshop and 2,208
AutoSave runtime-associated occurrences with such hints. Occurrence counts are
not directly comparable with variant-row counts. Entries without either kind
of family retain the unit appearance fallback.

The terrain rows are both occurrences of the same explicitly labelled `Shield
Wall`; neither has a confirmed datasheet association. Its ten lexical candidate
links include Shield-Captain, Wulfen with Storm Shields and Tomb Citadel Walls,
so none is promoted automatically. Keep this scenery category separate from the
current source's 28 `Fortifications` datasheets: those have 44 confirmed
variant-to-datasheet links and 437 candidate links across 319 unique variants.
Search the latter with `search --datasheet-role Fortifications`; search the
physical terrain inventory with `objects --category terrain`. The selected
ForceOrg/AutoSave sources are strong model catalogs but do not provide a broad
standalone scenery library.

Prioritize the remaining work in this order:

1. Verify the Intercessor weapon-specific recovery in a live match and decide
   whether automatic cross-family selection should stay enabled. A staged local
   capture now confirms an available Grenadier in another family is chosen before
   the generic appearance, but the selected-family generic failed to load in that
   capture, and palette matching is not guaranteed. No cross-family asset is
   downloaded or queued by this fallback; it uses only files already available.
2. Resolve missing appearance families for associated variants. Keep any derived
   family separate from the original source group; shared textures alone do not
   establish matching paint. Until supported, retain the selected unit visual.
3. Review ambiguous names and weapon labels by affected current profile, not
   alphabetical asset order. The schema-8 weapon-label report
   (`.tools/forceorg-model-table/catalog_v2/runtime-weapon-coverage-20261106.json`,
   SHA-256 `5fe9985ee2e020d81e0144b1035de38153f47468ad5709b95c26478fb01f6b18`)
   covers 236 runtime datasheets: 132 physical weapon/datasheet pairs have
   confirmed source-label evidence, 101 are candidate-only and 744 have no
   recognized label term across 235 sheets with weapon profiles. These are
   discovery counts, not proof that a weapon is absent or not sculpted. Reuse
   fingerprint-scoped corrections across saves and keep unresolved links
   explicit. The all-datasheet association report
   covers the full 1,469-sheet source catalog: 1,057 have label associations,
   321 are candidate-only, 16 rely on reviewed fallbacks without confirmed label
   associations and 75 have no miniature candidate. Fifteen of those 16 fallback
   records also retain unreviewed candidates. The runtime subset matches the
   existing 214/16/4/2 coverage split. These categories describe available
   evidence, not complete model or loadout coverage. A separate exact-name
   review signal finds 704 candidate variant/datasheet links across 89 sheets;
   every one is retained as a candidate because its recorded source-faction scope
   conflicts. Forty-five candidate-only sheets account for 356 of those exact
   name links, making them a focused cross-faction review queue. The optional
   `--review-queue` CSV expands those rows to source hashes, fingerprints, GUIDs,
   occurrence paths, roles, weapon-label hints and other confirmed datasheet
   links; every row remains pending visual/scope review.
   A local cache audit on 6 November checked the 25 unique source occurrences in
   that queue that had no other confirmed datasheet association. All 25 matched
   their exact save hash/path/GUID, but none had all model dependencies in the
   5,981-file TTS cache; no OBJ was parsed. One Daemon Prince occurrence had a
   single cached OBJ while its other parts were missing. The audit made no
   association changes. Its ignored report is
   `.tools/forceorg-model-table/catalog_v2/exact-name-unconfirmed-cache-audit-20261106.json`
   (SHA-256 `3aed95b1556e45353d4f77e91dcd1fd7089aeaeac9bb92a761d44dc4d1e6602a`);
   it covers ForceOrg source SHA-256
   `ed0b66dc0518f03ea746a485d2739deb57ea2094117d552c02925983c3bcba44` and
   AutoSave source SHA-256
   `ea1550037e8ae36aff8225cfc06c24eb9cd0f23a0a150e9688611aa78f70af63`.
   Further review of those same cache paths cannot resolve the queue without new
   local assets or other evidence.
   These weapon-label counts describe source evidence only; they do not certify
   model geometry, visible weapons, complete loadouts or legality.
4. Extend terrain and component extraction from actual saves independently of
   miniature-to-datasheet matching. The complete bounded static-object inventory
   now covers both selected saves; new scenery sources and objects without
   supported visual references remain separate work. Do not represent the two
   terrain-labelled occurrences as a broad scenery library.

The next acceptance target is correct selection and recovery for representative
equipped members, followed by measured coverage expansion. The database itself
is not a claim that every listed model is importable or visually correct.

## Recover missing saved unit mappings

`tools/reconcile_local_model_mappings.gd` reconciles missing standard Marine
profile links against the configured ForceOrg source and existing local caches.
It uses the production matcher, component resolver and base/completeness gates;
it never downloads assets or replaces an existing mapping. Dry run is the default:

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . `
  --script tools/reconcile_local_model_mappings.gd -- `
  --output .tools/forceorg-model-table/catalog_v2/mapping-recovery-dry-run.json
```

Add `--apply` to save recoverable links, retaining a timestamped config backup.
Use `--settings <cfg>` for an alternate config. Reports preserve source identity,
chosen object paths, fingerprints, failures and reviewed-alias status. An unresolved
profile produces exit code 1; other recoverable profiles may still be saved with
`--apply`. Existing keys, even malformed ones, remain untouched for separate review.
The report's `missing_after` is prospective on a dry run; check `applied` before
treating it as saved state. Keep reports/backups and model files outside Git.

The 6 November recovery restored 17 links, reaching 161/161 standard-profile saved
mappings; a fresh headless production-importer check loaded all 17 recovered
visuals. This does not certify the original 144 mappings, visible equipment or
correct sculpt identity. See [reconciliation evidence](model-import-validation.md#current-saved-mapping-reconciliation--6-november-2026).

## Storage and identity

`tools/forceorg_model_database.py` builds an indexed SQLite database using Python's
standard library. Generated databases, source tables, corrections and the Godot
index stay under ignored `.tools/`; they are not distributed with the game.

- `variants`: source hash plus variant key, original name, asset fingerprint,
  category, model role, source group and original consolidated metadata.
- `occurrences`: each original TTS path, GUID, state and group.
  The exact occurrence label is preserved independently of the variant's canonical
  representative label, including case differences and repeated-label aliases.
- `source_objects`: the complete bounded static traversal, including containers,
  accessories, components and objects without supported mesh references. It
  retains exact source hash/path/GUID, actual parent-object path, original and
  inherited labels, TTS type, asset-field kinds and category evidence. The two
  selected exports contain 74,766 objects: 38,380 miniature occurrences, 28,508
  components, 1,760 containers, 6,017 ignored accessories/interface or
  image-only-tile objects, 95 bases, two terrain-labelled objects and four
  unclassified block objects. Image-only tiles and recognized board controls
  remain searchable in the source inventory but stay out of 3D model selection.
  These are source occurrences, not distinct complete miniatures or geometry counts. An
  index on `(parent_path,source_sha256)` supports hierarchy queries without
  scanning the full object table.
- `weapons`: normalized visual weapon terms; not gameplay equipment grants.
  The full selected export's weapon vocabulary supplements the initial ForceOrg
  abbreviations, including labels such as Gauss Reaper. Historical terms remain
  distinct until an explicit visual mapping or correction relates them.
- `weapon_aliases`: a short visual term may resolve to a unique physical weapon
  name within that same source datasheet. Existing exact names take precedence;
  ambiguous matches and one-word fragments are not expanded. Fire-mode suffixes
  do not create additional physical weapon identities.
- `weapon_label_resolutions`: a complete source model-name prefix followed by a
  unique source-weapon suffix can resolve an otherwise unrecognized label, such
  as `necron warrior reaper` to `gauss-reaper`. Every admitted datasheet association
  must agree; explicit weapon corrections, including an empty list, take priority.
  Extended identities beginning with `of`, `and` or `the` are not weapon suffixes.
  The current build adds terms to 91 variants and retains 100 per-link evidence
  records. Search results expose the suffix and evidence on its own link. These
  are label interpretations, not inspected geometry or legal loadout declarations.
- `datasheets`: current-source IDs, names, faction, book, revision, character flag
  (Character/Epic Hero source role) and provenance. IDs retain leading zeroes.
- `links`: every candidate relation, score, faction comparison and association
  status. Equal names never merge datasheets or asset fingerprints.
- `model_role_links`: source model names within each datasheet, with explicit
  resolved, ambiguous or unresolved role status. A role belongs to its datasheet;
  a shared visual does not acquire the same role in every linked profile.
- `runtime_profiles`: datasheet-to-runtime definition identities, used only to
  connect visuals to existing profiles, never to add construction choices.
- `fallback_links`: the existing runtime's visual substitutes, kept separately from
  model-identity associations and bound to a SHA-256 of the runtime alias registry.

Categories are `miniature`, `terrain`, `component`, `base` and `ignored`.
Classification is label/path based and retains its reason. Cards, tokens, totems
and similar accessories are excluded from default miniature searches. A miniature
label does not prove an assembly is complete or importable. The current upstream
variant tables contain root visual candidates, not an exhaustive inventory of
standalone child parts or non-mesh TTS scenery. The supplemental `source_objects`
inventory covers those static objects separately without promoting them to whole
miniature choices. Assembly parts retain their original parent/source paths.
Source-object categories additionally include `container` and `unclassified`.
TTS card/deck/token/dice/interface types take priority over character-like names;
unknown non-mesh objects do not default to miniatures. Neither source-object
classification nor a visual-reference field proves import/render readiness.

Exact lexical family/role associations and complete source-datasheet names within
the hinted faction (or without a faction hint), plus explicit user corrections,
enter the automatic runtime index. Literal-name matching permits suffix terms
from that sheet's weapons, model names and composition; unknown suffixes are not
discarded arbitrarily. Its `literal_label_association` status preserves the original
family score when one exists. Weaker matches stay searchable candidates. This label-first policy
does not certify the sculpt, matching paint, a combined loadout or source rules.

The generated `runtime_visual_index.json` is keyed by the source save hash and
exact object path/GUID. Each occurrence carries admitted datasheet IDs and names,
current runtime definitions, model roles, weapon terms and sheet-scoped aliases.
The importer search matches all query words across the source label, role, linked
datasheet names, runtime names, and weapon terms/aliases. Selecting a result shows
the linked datasheet names and weapon terms as separate source-label clues. The
two-source 6 November index has 18,084 source occurrences with at least one
admitted association, 22,277 occurrence-to-datasheet references and 891 distinct
datasheet names across the sources. Of those, 9,107 occurrences link to one of the
236 current runtime identities. Nine fingerprint-scoped corrections are included
in these totals, including five Intercessor Grenadier assets linked to the current
Intercessor Squad sheet.
Search is for discovery; it does not certify weapon legality, the sculpt, or that a
loadout exists in the source models.

## Build and search

First rebuild `build_forceorg_model_weapon_catalog.py` with the intended raw
`--autosave-variants` / `--workshop-variants` and matching `--autosave-relations` /
`--workshop-relations`. Raw inventories without relations now fail explicitly.
Alternatively use already enriched best-match tables. Existing raw-save hash,
per-row source hash and selected rules-provenance checks remain mandatory.
The compact join preserves genuine top-score ties instead of treating a unique
review-order number as disambiguating evidence.

For the current local captures:

```powershell
# Complete static traversal; no Lua execution, downloads or object rendering.
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . `
  --script tools/export_forceorg_object_inventory.gd -- ForceOrg.json `
  res://.tools/forceorg-model-table/catalog_v2/workshop-objects.json
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . `
  --script tools/export_forceorg_object_inventory.gd -- `
  .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_latest_snapshot.json `
  res://.tools/forceorg-model-table/catalog_v2/autosave-objects.json

# Re-export if the current runtime/visual alias registry changes.
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . `
  --script tools/export_runtime_visual_datasheet_identities.gd -- `
  --output .tools/forceorg-model-table/runtime_visual_datasheet_identities.json

python tools/forceorg_model_database.py build `
  --catalog .tools/forceorg-model-table/catalog_v2/forceorg_model_weapon_catalog.csv `
  --datasheets .tools/forceorg-model-table/live_20261106_4/forceorg_datasheet_profiles_11e.csv `
  --runtime-profiles .tools/forceorg-model-table/runtime_visual_datasheet_identities.json `
  --relations .tools/forceorg-model-table/live_20261106_4/forceorg_visual_variant_datasheet_candidates.csv `
  --relations .tools/forceorg-model-table/forceorg_source/forceorg_visual_variant_datasheet_candidates.csv `
  --visual-inventory .tools/forceorg-model-table/ForceOrg_catalog_visual_candidates.csv `
  --visual-inventory .tools/forceorg-model-table/live_20261106_4/TS_AutoSave_2_visual_candidates.csv `
  --object-inventory .tools/forceorg-model-table/catalog_v2/workshop-objects.json `
  --object-inventory .tools/forceorg-model-table/catalog_v2/autosave-objects.json `
  --corrections .tools/forceorg-model-table/catalog_v2/visual-corrections-20261106.json `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite

python tools/forceorg_model_database.py search `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --datasheet 000001157 --weapon grenade-launcher --name Intercessor

python tools/forceorg_model_database.py objects `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite --category terrain
python tools/forceorg_model_database.py objects `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --category component --name "necron warrior flayer"

python tools/forceorg_model_database.py export-index `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --output .tools/forceorg-model-table/catalog_v2/runtime_visual_index.json

python tools/forceorg_model_database.py coverage `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --output .tools/forceorg-model-table/catalog_v2/runtime-coverage.json

python tools/forceorg_model_database.py datasheet-coverage `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --output .tools/forceorg-model-table/catalog_v2/all-datasheet-coverage.json `
  --review-queue .tools/forceorg-model-table/catalog_v2/exact-name-scope-review.csv

# Weapon-profile names vs associated/candidate source-label terms; mode suffixes
# are grouped by physical weapon. These reports do not certify visible geometry.
python tools/forceorg_model_database.py weapon-coverage `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --runtime-only `
  --output .tools/forceorg-model-table/catalog_v2/runtime-weapon-coverage.json
python tools/forceorg_model_database.py weapon-coverage `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --output .tools/forceorg-model-table/catalog_v2/all-weapon-coverage.json
```

### Add a local scenery-only source

A user-supplied TTS save that contains scenery but no datasheet model catalog can
now enter the same database without fabricated candidate relations:

```powershell
.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . `
  --script tools/export_forceorg_object_inventory.gd -- `
  "<local-scenery-save.json>" `
  res://.tools/forceorg-model-table/catalog_v2/local-scenery-objects.json

# Repeat the complete build command above, preserving its regular
# --object-inventory entries, and add:
# --object-only-inventory .tools/forceorg-model-table/catalog_v2/local-scenery-objects.json

python tools/forceorg_model_database.py objects `
  --database .tools/forceorg-model-table/catalog_v2/models.sqlite `
  --category terrain --source "<source_sha256-from-inventory>"
```

An `--object-only-inventory` adds exact save/path/GUID/name/type records and its
input hash to the rebuilt database. It does not add variants, datasheet or weapon
links, or runtime model choices. Cards, tokens and similar TTS types stay ignored;
ambiguous labels remain unclassified for review. Use the normal visual-variant
catalog and relation path for a new model intended to match a datasheet or loadout.

`search` defaults to miniatures and returns candidates as well as associations;
it is a discovery operation, not a legal equipment validator. With a datasheet
filter, label/user associations rank first, reviewed visual fallbacks second and
candidate-only links third; candidate rows remain visible with their status.
Use `--category`
to search terrain, parts or excluded accessories separately.
Use `--datasheet-role Fortifications` to search linked source roles without
relabeling the visual category.
`weapon-coverage` groups fire-mode profiles under their physical weapon, then
counts distinct confirmed and candidate variants whose source labels carry that
term. A missing term means no recognized label evidence; it does not mean the
weapon or model variant does not exist.
`--character` filters associations to Character/Epic Hero datasheets; character
identity is independent of the miniature/terrain category.
`--model-role Ancient --datasheet 000002772` filters a member of a mixed datasheet.
`objects` searches the supplemental object hierarchy, including components and
non-mesh scenery. Its default excludes ignored objects and containers; explicit
`--category ignored`, `--category container` and `--category unclassified` retain
access to those records. `--parent` and exact `--source` SHA-256 scope a hierarchy
query. Results distinguish supported visual-reference fields from no supported
reference, and link catalog variant IDs only where that exact object is a visual
catalog occurrence. Child parts do not inherit a parent datasheet as their own
identity. A source-object-only result cannot become an automatic miniature.
`coverage` summarizes the 236 datasheets already linked to runtime definitions;
`datasheet-coverage` summarizes all current source datasheets, including faction,
role, Character status, confirmed miniature associations, candidates, reviewed
fallbacks and profiles with no candidate. Neither report certifies visible weapon
geometry or import readiness.
Search results include recognized weapons and every linked datasheet's faction,
source role, source book, Character status, score, association status and
model-role evidence. Candidate results also distinguish a complete exact
datasheet-name label from a weaker lexical match; an exact name with a source-
faction scope conflict stays a candidate and is never silently promoted.
Candidates, characters, Fortifications and ordinary unit profiles remain
distinguishable without opening the database manually.
An existing runtime proxy appears as `reviewed_visual_fallback` or separate
`visual_fallback` evidence on a candidate; it does not become model identity or
weapon certification. The source label stays unchanged. Coverage accounts for all
236 runtime identities and separately counts label associations, profiles with
reviewed fallbacks but no confirmed label association, unresolved candidates and
profiles with no source candidate. A fallback profile may still have unreviewed
candidates. Role-eligible counts are source evidence, not local-file readiness.

Builds check complete relation coverage for every source, preserve all alternate
datasheet candidates, run SQLite integrity/foreign-key checks and replace the
previous database only after success. Input file SHA-256 hashes and rules snapshot
identity are recorded in its metadata. No source or model is downloaded.
Detailed inventory inputs verify each occurrence's source hash, path, GUID and
asset fingerprint. They recover exact per-occurrence labels from older variant
tables; future visual-table exports also include each occurrence label directly.
If detailed inventories are supplied, every source occurrence must be covered.
If object inventories are supplied, all selected sources must be present, every
static object must have a valid actual parent, and every catalog occurrence must
match its exact source-object label/GUID. Object exporters reject scanner warnings
and source changes during export. Omitting `--object-inventory` explicitly leaves
this supplemental inventory absent; `objects` then reports the rebuild requirement.

Use `--corrections <local.json>` for a JSON object keyed by asset fingerprint.
Supported fields are `category`, `model_role`, `weapons` (a list), `datasheet_ids`
(an explicit replacement list) and `note`. Invalid categories, unknown fingerprints,
unknown datasheet IDs and unknown fields fail the build. Corrections apply to
the same fingerprint across sources and survive later inventory regenerations
when kept in that independent input file. An explicit empty `datasheet_ids` list
removes all proposed links for an incorrectly labelled asset.

## Godot selection

The scanner optionally reads `user://forceorg_visual_index.json`, then the local
development index above. Source hash, TTS path, GUID and label must match before
an entry receives generated associations. A changed save requires rebuilding its
index; a clean checkout continues to use the existing importer and aliases.
The index also carries categories for all 38,495 indexed source occurrences, so
ignored accessories disappear from the miniature picker and cannot enter the
automatic unit-sculpt pool. The current index supplies 9,107 runtime-associated
occurrences, covering 214 runtime identities by label association. Sixteen more
have reviewed visual fallbacks, four retain unresolved name candidates and two
have no source candidate. A fallback is a presentation substitute only; it does
not grant an equipment-role association or confirm the sculpt identity.

The matcher admits complete source assemblies and attaches generated equipment
variants to existing definitions. Match preparation uses the existing selected
appearance-family preflight to prepare their role visuals. At runtime:

1. An explicit per-model visual override takes priority.
2. Available same-family variants whose visual weapon terms are all represented
   by equipped weapon instances are ranked by the number of matching terms.
   Source-specific model-role constraints distinguish characters and companions;
   unresolved/tied roles do not enter automatic equipment selection. Runtime role
   fields and current-profile model loadouts provide the member identity without
   adding cosmetic data to match state. Stable identity breaks ties.
3. A same-family source-role sculpt is tried next, then weapon-compatible and
   role-compatible variants from other families that already have usable local
   files. That can change the paint scheme. Family hints do not certify paint.
4. Existing specific Intercessor aliases remain a fallback. If a leading asset
   fails parsing, fingerprint checks or base fit, rendering tries the remaining
   candidates before the unit appearance, palette, existing mapping or built-in
   miniature. Explicit per-model assignments retain priority. Scene metadata
   records the visual that actually rendered.

For profiles whose source says `Use model`, the interaction footprint is only a
gameplay proxy. Non-source-pose visuals keep their TTS root scale (and optional
user adjustment) instead of fitting a detected flat hull surface to the proxy.
That prevents a vehicle's underside from being mistaken for a physical base; it
does not certify the source model's real-world dimensions or placement clearance.

Fire modes are stripped from profile names; changing an attack mode does not
equip a different physical weapon. The Intercessor visual term `grenade-launcher`
also matches its equipped `Astartes Grenade Launcher`. Other unrecognized historical
names do not create weapon options and may fall back to the unit sculpt.
Source-bounded aliases also connect `heavy-bolter` to `Hammerfall Heavy Bolter Array`
and `heavy-flamer` to `Hammerfall Heavy Flamer Array`. They are scoped by definition
and checked against the actual equipped instances. A full and short name for the
same weapon count once when ranking variants. The current build contains 47 such
source alias pairs; they do not certify the visual weapon or grant equipment.

Current visual names and indexed model roles come from the consolidated local
Marine/Necron runtime catalogs, without loading the historical starter pack.
Declared source groups take priority. Without one, static mesh assemblies can use
a `materials-v1` family derived from their complete set of diffuse/normal
references, source tints, shader settings and material indices. Untextured parts
also require identical mesh references; entirely untextured assemblies,
AssetBundles, unsupported built-in children and incomplete/over-limit traversals
receive no derived hint. The hint is stored separately as `material_family_hint`;
it never invents a source-group label. Preparation, cached mappings and runtime
weapon selection use the same family resolver. Exact texture references can still
contain multiple atlas regions, so this is a candidate filter rather than paint
certification. The real Flayer/Reaper assemblies share the resulting family in
both selected saves, enabling their role-preparation candidates.

A staged Godot rendering on 6 November loaded the actual Flayer and Reaper
assemblies through the production equipment selector and visual loader. Front
and reverse captures show distinct weapon geometry with the shared source
texture. The first capture exposed a larger body-contact estimate overriding
the separately detected base ring on the Flayer; composite fitting now prefers
a complete measured rim over a heuristic estimate, independent of part order.
Both variants subsequently use the same measured-base scale. This is evidence
for these two source objects, not the whole library or a live match interaction.
Source object tints are not reproduced by this OBJ material path (the bases
render white); shared-material families therefore remain candidate filters.

Source and material families filter candidates; they do not prove matching paint. Unresolved
mixed-model labels, unrecognized weapon synonyms, ambiguous associations, importer
limitations and full-library visual review remain open.
Cosmetic IDs and local files stay outside authoritative match state and traffic.

## Evidence boundary

The latest 6 November schema-8 rebuild contains 35,884 source variants,
147,384 candidate/identity links and 38,495 visual catalog occurrences. Its
source-gated runtime index exports 9,107 runtime-associated occurrences across
the two selected saves. Nine reviewed fingerprint-scoped corrections are included
in the link and index totals.
These are inventory/association counts, not unique complete miniature counts.
The selected rules context remains snapshot `20261021T130623Z`, manifest SHA-256
`169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`.

Verification commands and their observed results belong in the
[verification record](../verification/verification-results.md). Headless checks
exercise source gating, weapon/role matching and missing/same-group asset handling;
they do not establish visual fidelity, whole-library weapon coverage or network
readiness. Live Godot inspection of the generalized variants remains a separate gate.

## Local source discovery and unresolved links — 6 November 2026

A hash inventory of the 11 locally installed Workshop JSON saves found one
Warhammer 40,000 model source: `ForceOrg` (`3753014527`). The other ten are
Gloomhaven, The Mind, Splendor, Ticket to Ride, Arkham Horror, 7 Wonders, X-Wing,
UNO, Carcassonne and a Dungeons & Dragons board game; they were not merged into
the 40k catalog. Per-file sizes, object counts and SHA-256 hashes are recorded in
`.tools/forceorg-model-table/catalog_v2/local-workshop-source-inventory-20261106.json`.
This bounds the current local source search, not the global ForceOrg or Warhammer
model library.

The installed TTS Workshop cache identifies item `3753014527` as `ForceOrg`.
Its local JSON (`Documents/My Games/Tabletop Simulator/Mods/Workshop/3753014527.json`,
SHA-256 `6293a22c39da3d932d7f062d280ea0c1154709219158286026182cf1dad09f67`)
exported 37,351 objects, 19,154 visual rows and 17,871 variants, including
10,979 embedded static objects, with zero parser warnings. Compared with the
current database, all 17,523 unique asset fingerprints and all 17,871
fingerprint/label pairs already exist; this local file adds no visual variants.
The ignored export is
`.tools/forceorg-model-table/catalog_v2/forceorg_workshop_cache_20261106_variants.csv`.

The three additional saves in the local TTS `Saves` folder were compared with the
indexed AutoSave snapshot (`ea1550037e8ae36aff8225cfc06c24eb9cd0f23a0a150e9688611aa78f70af63`).
Each has the same 1,543 static visual-asset signatures by path, label, GUID,
asset kind/references and tint, plus the same 47 `objectJSONs` script path/hash
pairs. Their different save-file hashes do not represent extra model content:

| Local AutoSave | SHA-256 |
| --- | --- |
| `TS_AutoSave.json` | `59efe8219bd6ba50b395f13dac8d01edcf53fd0cb37bf878130ed15832b68a47` |
| `TS_AutoSave_2.json` | `76153525469c9deea4a732d25a287e3dbb3cb405a1b969cc44a7ad08f59b1d7a` |
| `TS_AutoSave_3.json` | `9afdf915f504ae66aefee6f2741c2903442d31579bd507ae4670869c152c22af` |

The detailed comparison is stored locally at
`.tools/forceorg-model-table/catalog_v2/local-source-coverage-20261106.json`.
It bounds discovery to these local sources; it does not establish that the full
ForceOrg or Warhammer model library is present.

Four candidate-only links and the weaker candidates for two reviewed visual
fallbacks were inspected against their source labels and the current local 11e
profiles. Fallback labels remain separate from confirmed identity associations:

| Datasheet | Leading local source candidate | Disposition |
| --- | --- | --- |
| Falchion (`000001666`) | Apothecary/Interceptor/Justicar Falchions (0.667) | Weapon-name collision with Grey Knights/characters; not the Titanic vehicle. |
| Land Raider Excelsior (`000000067`) | generic and Chapter Land Raiders (0.800) | Uses `Ultramarine Land Raider` as a local presentation fallback. No exact Excelsior sculpt is identified; this does not establish its weapons. |
| Rapier Carrier (`000000110`) | `3/3 Rapier Laser Destroyer` (0.667) | Promising: Laser Destroyer is an allowed current option, but five Rapier Carrier datasheet candidates tie and the sculpt is unreviewed. |
| Relic Razorback (`000002720`) | standard Razorback weapon variants (0.667) | Uses `Razorback Lascannon` as a local presentation fallback. The source asset's Lascannon label remains separate from the Relic datasheet's actual equipped weapons. |
| Scout Bike Squad (`000000137`) | Scout infantry/weapon variants (0.667) | The candidates are foot Scouts; no bike sculpt is identified. |
| Tarantula Sentry Battery (`000000098`) | Necron Sentry Pylon (0.400) | Different model family; do not associate. |
| Mastodon (`000001189`) | none | No source candidate in the selected local catalogs. |
| Tarantula Air Defence Battery (`000000099`) | none | No source candidate in the selected local catalogs. |

The local cache contains 11 complete Land Raider/Razorback candidates among 104
root candidates. All 11 assembled through the production OBJ importer; four
were rendered with declared diffuse textures. This verifies local availability
and renderability for those captures, not identity, exact weapon fit or the
completeness of the ForceOrg library. The two reviewed aliases let selection
work now while remaining explicitly weaker than exact sculpt links. The
weapon-to-Intercessor Grenadier route is locally rendered in the Ultramarines
family. A separate fallback capture used complete generic variants from saved
user mappings: it forced the first same-family candidate's path missing in memory
and rendered the next candidate, which belongs to another material family. This
shows importer recovery, not recovery from a real damaged file or a live match.
Next, verify the sequence in a live match and review whether cross-family last
resort should remain automatic. Then review exact Rapier Carrier evidence or add
a genuinely new model source.

`tools/audit_forceorg_visual_catalog.gd --source <save> --output <report>` checks
the real local save and generated index through the Godot matcher. Add
`--index-only` to verify occurrence coverage without enumerating profile choices.
Run it with Godot's `--headless --path . --script tools/audit_forceorg_visual_catalog.gd --`
prefix. It performs no downloads or mesh imports and records exact save/index
hashes. Its source-index check requires every indexed occurrence to match and the
bounded parser to report no warnings; a successful check does not certify geometry.

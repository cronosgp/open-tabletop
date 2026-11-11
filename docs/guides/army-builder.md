# Army Workshop

## Workspace

Open **Armies** from the title-screen bottom bar. The library keeps New,
Edit selected, Duplicate and confirmed Delete together with saved roster inspection.
The editor shows a unit catalog, current roster and selected-unit inspector. Search
and select a catalog unit to inspect its available compositions before adding it.
The Add action stays beside the catalog; roster model-size and unit-copy controls
appear at the top of the **Unit** inspector. Apply unit size commits those edits.

The header keeps points, unit/model counts and remaining budget visible. Save list,
Save a copy and New match stay in the footer. **Appearance** retains paint choices,
per-model overrides and palette preparation; **Army** retains category, faction,
notes and advanced construction controls. The miniature's rotate, zoom and Fit
controls change the preview only. At narrow logical widths, choose a workspace
region from the selector instead of using compressed columns.

**Miniatures & import** separates miniature browsing from Advanced source, files
and fit. Local cache preview does not download or link a model. Explicit download
and Link to unit type retain their previous scope. New match opens both saved-army
side selectors; advanced download settings and LAN options remain on that screen.

Closing the editor retains the session draft; use **Resume unsaved draft** in the
library to continue it. Editing the same saved army also resumes its dirty revision.
Before New, Edit another army or Duplicate replaces unsaved work, choose **Save
draft**, **Keep editing** or explicit **Discard changes**. A failed save preserves
the draft. Save explicitly to persist the army across application restarts.

Large local previews and the first large Appearance search show loading feedback
while their files and variants are prepared in the background. Selection changes
ignore older completions. Explicit source scans, large-catalog match/appearance preparation, heavy cached
imports and GLB preparation also run in the background. **Cancel preparation**
stops a batch from installing later results; existing saved links are preserved. Changing
the source path or a conversion target/fit prevents the obsolete result from
replacing the current catalog/mapping. Preparation can still take several seconds;
whole-library transfer speed and wider device behavior remain unverified. See the [redesign implementation and
verification record](../project/ui-redesign.md) for observed coverage and limits.

## Catalog and admission

The workshop offers only profiles in the consolidated local runtime catalog. Wahapedia 11e is the selected source for rules and datasheet facts; see the [source policy](../data/source-assessment.md) and [construction catalog policy](../construction-catalog-policy.md). The catalog currently contains 85 shared Space Marine profiles. A selectable profile does not imply complete rules support, full army legality or network certification.

Use the workshop to choose a profile, an available composition, unit counts and supported roster options. Save a list or a copy, then select it for a local match. Match admission revalidates each identity and composition against the enabled rules. Unsupported or unreconciled entries remain blocked or labelled as legacy drafts; they are not silently rewritten.

## Intercessor Sergeant equipment

The workshop stores the Intercessor Sergeant's supported rifle and melee choices separately for each unit copy. This is roster equipment with no added points cost under the current local profile. The Sergeant retains its Bolt Pistol. The list may use the default Bolt Rifle and Knives and Fists, or one of the displayed source-listed replacements.

The saved equipment is included in the canonical match roster and applied to the Sergeant's gameplay weapon set. During match preparation, the player can still change it through the existing supported setup choices. The selected equipment remains the single source of truth; the miniature appearance follows it automatically when a matching local sculpt is available.

Seven complete ForceOrg/TTS Sergeant assemblies currently have reviewed exact loadout mappings. Other supported combinations use the default Sergeant sculpt. The preview identifies the saved equipment and shows a cached matching sculpt when available; otherwise it explains which fallback will be used. The role-specific Sergeant sculpt takes priority over a per-model visual fallback when an exact equipment mapping is ready.

## Local appearances and preparation

Each unit copy can use one local paint appearance shared by its models. A reviewed per-model sculpt fallback remains available for other distinct roles. These choices are saved only in the local profile and are removed before the gameplay roster is sent to a peer.

When automatic model preparation is enabled, a local saved-list match prepares selected miniatures before opening the board. Intercessor lists also prepare the seven mapped Sergeant loadout sculpts and the supported Grenadier role sculpt so legal equipment choices can swap the correct individual model during match preparation. Common models keep the unit's single paint choice. The player can cancel preparation and continue with available or built-in miniatures. Missing visuals do not block roster rules or gameplay. Assets, mappings and appearance settings remain on the current computer.

Downloads and appearance assignments do not establish rules support. The full army legality and separate-machine multiplayer behavior remain outside the current certification boundary.

## Lists and privacy

Profiles and lists belong to the local computer. The match shares only canonical gameplay selections such as unit identity, composition and equipment. Private profile/list names, notes, ForceOrg mappings, model files, paint choices and camera state are not match data.

The broad OpenHammer API catalog and its cache do not supply new construction choices. Historical adapters remain isolated from the current army workshop. See [saved army matches](saved-army-matches.md) and the [current support matrix](../project/support-matrix.md) for implementation limits.

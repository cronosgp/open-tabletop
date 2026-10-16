# ForceOrg / Tabletop Simulator visual import assessment

Updated 2026-10-16. Automatic catalog/model preparation is implemented for local two-list matches; the manual runtime importer remains available in the **Models / Import** tab. It reads local TTS/ForceOrg saves, previews local OBJ meshes with an optional diffuse image, saves visual mappings by unit definition and renders them on the board. No third-party models are bundled. Broader ForceOrg library discovery remains incomplete.

Real-content validation is now complete for three sample meshes: two Intercessors and one Necron child component. The current official save's static `objectJSONs` catalogs and `ChildObjects` are discoverable without executing Lua. Model-name search shows at most 200 matches while retaining original source identities. Image decoding uses PNG/JPEG/WebP signatures, so extensionless or mislabeled cached images work. See [real validation results and remaining limits](model-import-validation.md).

## Use the initial importer

### Automatic models for a local match

In **Match setup → LOCAL MATCH • TWO ARMIES**, choose two default/profile lists and use **Create local match with these two lists**. Automatic download/linking is enabled initially and can be unchecked. When no source is configured or detected, the game downloads the public ForceOrg JSON automatically, validates its catalog and saves it as `user://ForceOrg.json`, then continues with the miniatures. You can instead choose your own JSON in **Models / Import → Browse / Scan local save** and use **Retry automatic models for current match**. The chosen source path is saved. The game also detects `ForceOrg.json` in its user-data directory, project root or the standard TTS Saves directory. The default endpoint is the manual JSON download documented by the [ForceOrg Downloader project](https://gitlab.com/forceorg1/ForceOrg-Downloader/-/raw/main/README.md). Catalog transfers are limited to 64 MiB, three redirects and 60 seconds; invalid/empty JSON or HTTP errors preserve earlier files and report how to retry or select a local source.

Existing valid links are reused, including manual choices. Missing/broken saved links are reported for manual repair rather than silently replaced. For unmapped playable profiles, the importer selects a compatible visual variant from the catalog using unit aliases, prefers exact names and sorts equivalent variants by asset URLs. It reports the chosen variant; use Models / Import to override it. Asset URL pairs are deduplicated. This changes appearance only, never roster identity, weapons, bases or rules.

The batch checks downloaded files and the configured cache before HTTP, captures each target definition independently of the selected pawn, validates OBJ/diffuse content and atomically persists each successful link. Successful models appear on all corresponding pawns immediately. Progress, cancellation, errors and retry are available; unavailable models keep placeholders and the match remains playable. No user library lists are created implicitly.

Only supported single-mesh/diffuse entries are matched. Downloading the catalog does not fetch the entire miniature collection; only missing visuals for the two selected armies are retrieved. Aliases cover Intercessors, Warriors, Terminators and Immortals; named Terminator characters and obvious incompatible families are excluded, and Gauss-labelled Immortals are preferred. Bases, Assault/Heavy/Jump Intercessors, normal-map entries, Unity bundles and arbitrary composite parts are excluded. One explicitly verified Necron Warrior body component is accepted by its known mesh URL (see [real validation](model-import-validation.md)); it renders over the board's base. This does not assemble the original composite or reproduce its transforms/materials. Other components still require manual choice.

### Manual direct download

Open the JSON, search/select a miniature, choose the download folder and press the selected-model download button. Default destination is `user://downloaded-models`. Scanning/searching alone does not download assets. The manual path opens a preview and requires saving its association; the automatic batch above links validated files directly.

Transfers require HTTPS, allow at most three redirects, time out after 45 seconds per file and are limited to 64 MiB per file. Files are validated before becoming permanent; versioned filenames preserve older content. Manual selection changes prevent a stale download from being previewed as another object. AssetBundles and automatic whole-composite downloads remain unsupported.

### Existing files / TTS cache — optional

1. Independently acquire ForceOrg and the desired models using the user's existing workflow. The downloader installs the utility save; it does not itself install all referenced model meshes.
2. Start an exercise and select a model in **Play** to identify the target unit definition.
3. Open **Models / Import**. Choose `ForceOrg.json` or a TTS saved army/object JSON and press **Scan local save**. The source path also accepts a directory containing `ForceOrg.json`. Search model names and choose an entry to inspect original references/credits. Static JSON literals in the known `objectJSONs` table and child components are included; Lua and remote references are never executed or fetched. Components without a name inherit their parent's searchable name.
4. Choose your **Local TTS Mods / cache folder** and press **Find selected object's local files**. The importer searches that directory and its subdirectories for full-URL-derived alphanumeric filenames, with optional OBJ/image extensions. A unique mesh and any declared diffuse texture load the preview automatically. Missing or ambiguous matches are reported beside the lookup button; select those files manually instead. No network requests occur. **Save cache folder setting** persists the chosen folder. This adapter recognizes specific filename conventions, not every possible TTS/cache version.
5. Alternatively, choose a locally downloaded OBJ (extensionless cached text OBJ is accepted) and optional diffuse PNG/JPEG/WebP, then press **Load model preview**.
6. Adjust visual scale, rotation and height. Auto-fit initially normalizes mesh height to 1.3 inches; it is a visual convenience, not an official miniature measurement. Press **Save visual for selected unit type**. All models sharing that definition use this local visual. Different sculpt variants per model are future work.
7. Use **Remove visual for selected unit type** to restore placeholders. Mappings and the cache folder persist in `user://local-models.cfg` and reference source files without modifying them. Missing or changed mesh/texture files fall back to placeholders when loaded again; preview and save again to accept replacements. Already loaded meshes remain cached for the current run.

Supported: text OBJ triangles and convex polygon faces, negative indices, optional UVs, recomputed normals, a diffuse texture and bounded local cache lookup by full URL-derived names. The lookup ignores hidden entries and symbolic links, does not match by short asset ID/basename alone, recognizes the `{verifycache}` URL prefix, and never chooses among multiple candidates. It re-indexes on each explicit lookup so newly cached files and duplicates are visible. Bounds: eight subdirectory levels, 2,048 directories and 50,000 files; exceeding a bound fails the scan instead of using partial results. Unsupported/hashed cache naming still requires manual selection.

Not yet supported: MTL/multiple materials, normal maps, animations, arbitrary AssetBundle conversion, GLB imports, automatic assembly of multiple components/transforms, vertex-color-only appearance or arbitrary dynamically computed Lua catalogs. Known static `objectJSONs` long-string JSON tables are parsed as data, including equal-sign delimiters; expressions or malformed tables are skipped with warnings. OBJ source attributes and triangulated vertices are each bounded at 300,000; save/mesh files and total extracted static JSON at 64 MiB; scanned object records at 100,000; textures at 8192 pixels per side and 64 MiB per file. Concave polygon triangulation is not guaranteed; triangulate such models before import.

Earlier synthetic validation covered parsing, cache ambiguity, persistence, state isolation and placeholder fallbacks. The subsequent real-content increment tested static catalogs/children, image-content detection, three actual meshes/textures, preview/board rendering, persisted mappings and fresh default-profile launch. Six local suites and one host/client loopback/rejoin scenario passed. Files downloaded for this explicitly authorized test reside only in the ignored `.tools/forceorg-real` directory. An actual TTS-produced cache, all catalog entries, arbitrary composite models, separate-machine peers and Linux remain unverified. Full evidence: [real validation report](model-import-validation.md).

## Confirmed acquisition workflow

The intended catalog source is ForceOrg itself (Workshop item 3753014527 and ForceOrg-Downloader). The user subsequently requested an in-game per-model download option to remove the dependency on TTS/cache. The game supplies the importer and explicit download control; it does not ship the collection, run its external downloader, subscribe to Workshop items, acquire the whole library or transfer assets to other players. Existing local files/caches remain optional inputs. Original files are preserved and downloads stay in a local player-selected library.

Primary sources:
- https://steamcommunity.com/sharedfiles/filedetails/?id=3753014527
- https://gitlab.com/forceorg1/ForceOrg-Downloader

The downloader's public README and DownloaderUI.cs were subsequently inspected. It writes `ForceOrg.json` and `ForceOrg.png` into the selected TTS Saves directory. Its code does not download the full mesh/texture collection. The mesh files still need to exist locally, for example from the player's TTS workflow. No downloader executable was run. The backup inspection below is supporting evidence about one TTS save, not a specification of a complete ForceOrg collection.

Implementation must prioritize reading the formats actually produced by the player's ForceOrg download. GLB remains an optional compatible import/fallback, not a requirement for the user to manually rebuild the collection. Where a downloaded format needs conversion, provide a supported local adapter or a precise per-file unsupported status. Do not promise conversion of arbitrary AssetBundles.

## Backup findings

Source: https://github.com/KMill-source/TTS-Resources-Backup

The repository describes itself as a backup of TTS table saves. Its ForceOrg directory contains TS_Save_1.json and a preview PNG, not a standalone catalog of miniature meshes. The downloaded JSON identifies itself as ForceOrg 6-29-2026 and is approximately 43 MB. An inspection of ObjectStates, recursively including ContainedObjects and alternate States, found 140 root objects and 3,245 total object records, including 56 CustomMesh and 4 CustomAssetbundle records. These counts describe those fields in this save, not unique miniature assets or a complete ForceOrg library. Many sampled mesh records are bases or utility objects. Models loaded by scripts or external services require separate discovery; the importer must not assume the table save contains the player's army.

CustomMesh records hold MeshURL, DiffuseURL, NormalURL and ColliderURL references. Referenced files are external dependencies and their availability/content has not been verified. CustomAssetbundle records hold AssetbundleURL references. No asset meshes, textures or bundles were downloaded or redistributed during this assessment, and no source Lua or installer scripts were executed.

The repository LICENSE explicitly reserves save content to the respective creators and says the maintainer has no licensing rights over it. The public-domain permission applies to the maintainer's installer and documentation. Therefore this repository does not establish permission to bundle these models in our distribution. Track creator, origin, attribution and applicable permission per asset; local import support itself does not establish rights to copy or distribute content.

## Planned player configuration

Add a dedicated **Models / Import** area under Match setup, independent of combat setup and the future battlefield builder:

1. Choose the local ForceOrg download/output directory. Optionally select a local TTS saved-object JSON or table-save JSON and asset/cache directory when the downloaded collection needs them. Detect the actual layout and report what was found; the ForceOrg utility-table save alone is not assumed to contain the collection.
2. Scan references without executing Lua, downloading files or modifying the army. List objects by name and stable source identity, distinguish contained objects and alternate states, and report missing/unsupported references. Deduplicate referenced files without collapsing distinct instances or variants.
3. Select candidate miniature assets and explicitly map them to our faction/unit/model identifiers. Names may suggest matches but must not silently grant stats, equipment, abilities, roster legality or base sizes.
4. Preview the visual model with configurable scale, rotation and vertical offset. Local OBJ plus an explicit diffuse texture is implemented first for the TTS mesh workflow; GLB support remains an extension. Unity/TTS AssetBundles must be reported as needing an independently prepared compatible model.
5. Persist versioned local mappings and settings, including provenance and fingerprints. Never execute embedded scripts or adopt source colliders. Keep gameplay bases, selection markers and authoritative geometry controlled by our rules/scenario data. Visual imports do not make mesh-based visibility or vertical geometry supported.
6. Missing or incompatible assets fall back to the existing placeholder with a clear status. In multiplayer, share the logical identity only; each player supplies local visuals or explicitly downloads the chosen model. Automatic inter-player asset transfer remains a future feature.

Initial local completion criteria are met using original OBJ/cache fixtures: scan a saved object, locate uniquely matched cached files, preview and map its mesh, persist/reload, render on the board and return placeholders for missing/unmapped visuals without changing gameplay state. Real miniature and automatic catalog/download validation has since passed; see [latest results](model-import-validation.md). Remaining acceptance work includes separate-client validation and additional format/composite adapters.

Implemented: catalog discovery, supported OBJ/image adapters, preview/mapping/persistence, board integration/fallback and an explicit per-model downloader. Further conversion/composite support remains planned. Players initiate downloads themselves; the game does not acquire models in the background. This feature is distinct from the deferred battlefield editor. Core rules and current UI clarity work remain active roadmap items.

## References

- Repository README: https://github.com/KMill-source/TTS-Resources-Backup#readme
- Repository license: https://github.com/KMill-source/TTS-Resources-Backup/blob/main/LICENSE
- ForceOrg downloader linked by the repository: https://gitlab.com/forceorg1/ForceOrg-Downloader
- Downloader source: https://gitlab.com/forceorg1/ForceOrg-Downloader/-/raw/main/DownloaderUI.cs
- Godot formats: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html
- TTS custom objects: https://api.tabletopsimulator.com/custom-game-objects/

## Identifying catalog entries

The picker now shows miniature names instead of CustomMesh/internal object paths. Repeated names have numbered options, named millimeter bases are marked Base, and child components are labeled Peça. A visible selected-entry description explains separate components; verify the preview before applying. Missing local references explain that a JSON save is a catalog, not a download of the model/texture, and that the project/save directory may not be the cache directory. Source URLs, credits and paths remain in the detailed notice. Three related local suites passed for this usability correction.

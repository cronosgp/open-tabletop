# Configuration workspace redesign — 6 November 2026

Implementation record for the supplied `open_tabletop_ui_redesign_agent_plan.md`.
This work concerns configuration and pre-match presentation. Rules, construction
admission, catalog provenance, match protocols and save formats retain their existing
owners. A saved draft or a loaded visual is not an officially legal army.

## Repository audit and implementation map

The project uses Godot 4.7.2 standard, Compatibility rendering, with a 1280 × 800
reference viewport, `canvas_items` scaling and expanded aspect ratio. The entry scene
is `scenes/main.tscn`; the interfaces are constructed from GDScript Controls.

| File | Ownership and reuse |
|---|---|
| `scripts/main.gd` | Title callbacks, configuration routing, reusable tactical overlay, match setup, Settings, Guide and Training Tools. Existing overlay close/focus restoration remains in use. |
| `scripts/army_builder_panel.gd` | Library/editor selection, draft controls, catalog filtering, supported equipment and appearance adapters. Existing callbacks are rearranged into regions. |
| `scripts/army_profiles.gd` | Local profile bank, create/select/save/copy/delete lifecycle; schema 1 at `user://profiles/army-lists.json`. Not changed by this redesign. |
| `scripts/army_roster.gd` | Composition, copies, price tiers, enhancements, validation and totals. Not changed by this redesign; model counts are displayed from existing entry sizes and copies. |
| `scripts/implemented_army_catalog.gd` | Consolidated current construction catalog and supported sizes. No API catalog is introduced. |
| `scripts/model_import_panel.gd` | Existing source selection, searching, local files/cache, preview, linking, conversion and download/cancel flows. Reorganized without changing the import pipeline. |
| `scripts/ui/miniature_preview.gd` | One isolated SubViewport, bounds-based camera fit, rotate/zoom/reset, explicit placeholder/imported status. |
| `scripts/ui/main_menu.gd` | Imperial Dataslate title and match menu (`scenes/ui/MainMenu.tscn`, `themes/menu_theme.tres`). Left branding, right primary actions, bottom toolbar; Training details button omitted with summary and side-swap kept visible. |
| `scripts/ui/saved_results_browser.gd` | Existing local result search, scan errors and detail reader; an empty-history training action is added. |
| `scripts/ui/workspace_theme.gd` | New shared configuration colors, spacing, panel/control states and primary-action styling. |
| `scripts/ui/guide_browser.gd` | New topic/search view over the existing maintained Guide text. |

The implementation sequence was audit/capture → shared theme → Army Builder →
viewer and miniature browsing → title/match setup → secondary screens → regression
and layout review. Existing signals and storage interfaces are reused throughout.

Navigation remains local:

```text
Title
  Continue → existing compatible save/slot flow
  New Match → setup workspace → saved Side 1 / Side 2, training, LAN, advanced options
  Army Builder / Armies → army library → editor (catalog / roster / inspector)
  Models → miniature library → advanced source / files / fit
  Training Tools → training and showcase cards → expandable advanced labs
  Guide → topic/search reader and weapon glossary
  Results → existing saved results and empty-history recovery
  Settings → Display / Controls / Presentation → persistent Apply / Revert
```

The shared overlay supplies Close, Escape/Cancel and focus restoration. Native
dialogs still handle paths and delete confirmation. Closing the army editor retains
its existing session-draft policy. Saving and failed-save retry use the existing
profile writer; copying keeps the original identity and creates a separate saved list.

Model mappings still live at `user://local-models.cfg`; the configured source/cache
paths and `user://downloaded-models` default remain local. Roster and catalog preview
selections remain separate: browsing a candidate never silently changes the roster
import target, equipment, points or appearance assignment.

## Design brief

The requested `godot-ui-control` skill was installed in `.agents/skills/` from
`gamedev-skills/awesome-gamedev-agent-skills`, path `skills/godot/godot-ui-control`,
at commit `19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9` on 6 November 2026.
The existing copy was updated rather than failing on its already-existing directory.
SHA-256: `SKILL.md` =
`0b2cc92d670cc2274f6579748a1703ec6a2bf70dc3d2875985deea1018f05bdc`;
`references/layout-and-theming.md` =
`5f54eed206cd7d7f5fecffd2ce1c189739eba5b5e18b2d1773f9ba7202427f66`.
Relevant router, Godot scripting/composition/signals/UI, game UI/UX, online game
design, design-first, screenshot, input, preview camera/3D and testing guidance
was applied. No unrelated gameplay skill or web dependency was introduced.

The player should find a unit, understand its composition and cost, inspect its
miniature and save an army without navigating unrelated pages. The desktop editor
has independently scrolling catalog/roster/inspector regions. Its name/budget header
and Save/Copy/New Match footer stay outside those scrolling regions. At widths below
980 logical pixels, a region selector replaces compressed columns.

The palette uses a dark blue-grey base, ivory text and restrained gold emphasis.
Body text uses the existing licensed engine font at 16 logical pixels; headings and
metadata have separate sizes. Gold is not used as proof of legality. Save errors,
unsaved drafts and successful saves retain explicit text and existing semantic colors.
Focus borders, hover/pressed/disabled styles and named actions remain visible.
No new font, copyrighted illustration, web dependency or cloud service is introduced.

## Phase record

### Phase 0 — Audit and baseline

**Status:** Complete for the local implementation audit.

The owners and routes above were identified before changing behavior. A live Godot
baseline was captured at `.tools/ui-redesign/before-builder.png`; it shows the old
library/preview layout, not every original workflow. The twelve reference screenshots
mentioned in the supplied plan were not attached to this task.

The original targeted baseline passed import, Python checks and `test_army_builder`;
`test_workshop_ui` failed by indexing an empty historical training roster. Report:
`.tools/verification/20261106T204159985783Z/results.json`.

### Phase 1 — Foundation and navigation

**Status:** Implemented; local layout validation is recorded below.

Shared tokens and control states now style configuration workspaces. The existing
overlay provides stable headers, Close/Back behavior and focus restoration; larger
workspaces use available screen area. Army editing keeps global actions outside
scrolling content. Existing setup and import controls remain reachable.

Files: `workspace_theme.gd`, `main.gd`, `main_menu.gd`, `army_builder_panel.gd`.
`configuration_input.gd` explicitly fills missing standard controller bindings for
Godot's existing UI actions. It preserves configured keyboard/gameplay actions.

### Phase 2 — Army Builder

**Status:** Implemented; focused persistence/interaction checks are recorded below.

The catalog, roster and selected-unit inspector stay together. Catalog additions
have their own composition/copy controls and projected cost; roster squad size and
copy edits use the existing apply callback. Equipment, enhancements, notes, appearance,
palette preparation and advanced model import remain available in inspector sections.
The existing price functions drive the budget meter and partial/over-budget feedback.
Library actions include New, Edit, Duplicate and confirmed Delete. Save status remains
distinct from draft state and storage errors. The shared viewer also works in the library.

Files: `army_builder_panel.gd`; existing profile/roster owners are reused.

### Phase 3 — Miniatures

**Status:** Implemented as a searchable catalog and single-preview workflow.

The existing browser is separated into Miniature library, Advanced source, Advanced
files and Advanced fit. Cache preview and explicit download/link actions retain their
semantics. Catalog configuration is reachable from the empty library. GLB preparation
is under advanced files. Existing appearance pickers and per-model overrides remain;
this does not introduce a thumbnail grid or preload every variant.

The roster viewer now fits bounds at load/resize and rotates around the visual center;
zoom/reset affect only its camera. Placeholders and unavailable assigned variants stay
labelled. Existing import validation and storage formats remain in place. The follow-up
below moves heavy preview parsing and large appearance matching off the UI thread.

Files: `miniature_preview.gd`, `model_import_panel.gd`, `army_builder_panel.gd`.

### Phase 4 — Home and match setup

**Status:** Local launch regression passed; separate-machine LAN remains deferred.

Home has Continue when compatible and New Match in the primary stack, with Armies on the bottom bar and expandable
training details. New Match opens the existing setup controls in a larger workspace
with explicit Side 1 and Side 2 labels. LAN and advanced model-download options are
retained. Launch callbacks and consent semantics are reused, including the existing
asynchronous visual-preparation flow.

Files: `main_menu.gd`, `main.gd`.

### Phase 5 — Secondary screens

**Status:** Implemented using existing content and stored data.

Training/showcase cards are separate from expandable advanced labs. Guide adds topic
selection, search and a zero-result recovery state. Settings groups Display, Controls
and Presentation while Apply/Revert stay outside scrolling content. Results keeps
its existing data-backed search/detail/error behavior and adds a training action only
for a readable, empty result location. It does not fabricate match-history cards.

Files: `guide_browser.gd`, `saved_results_browser.gd`, `main.gd`.

### Phase 6 — Accessibility and regression

**Status:** Local implementation and review performed; release-wide validation remains partial.

Native Godot captures and focused checks cover the implemented slices. Physical
controller testing, human usability testing and separate-machine LAN remain outside
the observed scope. Representative local assets have now been profiled; advanced
conversion still has the blocking limitation recorded in the follow-up below. Previous
screens were reorganized rather than deleting their behavior or persistence owners.

## Verification record

Generated images, test profiles and reports stay in gitignored `.tools/`.

The focused current-catalog run passed **5/5 processes** (import, Python checks,
configuration workspace, workshop UI and army-builder suites) at
`.tools/verification/20261106T210755697276Z/results.json`, with network disabled and
no historical starter pack staged:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_configuration_workspaces --only test_workshop_ui --only test_army_builder --timeout 300
```

The broader run passed **6/6 processes**, adding `test_gameplay_layout`, at
`.tools/verification/20261106T211402634912Z/results.json`. It staged the optional
historical starter fixture needed by that existing layout suite and kept network
disabled. It checks Settings Apply/Revert persistence, overlay return and match-state
preservation in addition to the current-catalog editor checks:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_configuration_workspaces --only test_workshop_ui --only test_army_builder --only test_gameplay_layout --timeout 300
```

The layout fixture now completes the existing optional first-run setup through
Continue without models before checking normal-title focus. Its original focus
failure was also reproduced in the preserved baseline at
`.tools/verification/20261106T204159985783Z/project/.tools/verification/20261106T211327254962Z/results.json`.
The real skip action now restores title focus. The broader passing run reported two
screen-reader-only focus warnings; the shared helper was then tightened to respect
accessibility-only controls, and the focused follow-up passed **4/4 processes** at
`.tools/verification/20261106T211637224083Z/results.json` with no focus warnings
(import, Python, configuration workspaces and gameplay layout; network disabled,
optional legacy layout fixture staged):

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_configuration_workspaces --only test_gameplay_layout --timeout 300
```

The Appearance shortcut also reveals its actual picker through both nested scroll
containers and restores focus there. Its separate live capture is
`.tools/ui-redesign/1920x1080-appearance.png`. The final native empty-army check
also confirmed the empty-roster instruction is visible and selected-unit size controls
are hidden; see `.tools/ui-redesign/1920x1080-empty-army.png`. An empty inspector does
not render a pretend miniature, and army notes remain under Army options. These last
presentation changes were checked by running Godot, rather than repeating unrelated
rules suites.

The reference check returned **0 errors, 1 warning**:

```text
python .agents/skills/godot-nodes-scenes/scripts/check_godot_project.py . --json
git diff --check
```

The warning is the existing orphan `tests/test_jump_pack_chaplain.gd.uid`; the diff
whitespace check passed. No orphan file was deleted as part of this UI work.

Live Compatibility-renderer captures were inspected at physical 1920×1080,
1366×768 and 2560×1440, including 100%, 110% and 120% interface scaling. A contact sheet of the 22 configuration captures is at `.tools/ui-redesign/contact-sheet.png`. These are
staged configuration states rendered by the actual application, using the local
construction catalog and labelled placeholders; they are not a miniature-library
visual certification. Files include:

- `.tools/ui-redesign/1920x1080-builder.png` and `1920x1080-candidate.png`;
- `1920x1080-home.png`, `1920x1080-miniatures.png`, `1920x1080-match.png`;
- `1920x1080-settings.png`, `1920x1080-controls.png`, `1920x1080-guide.png`;
- `1920x1080-results.png`, `1920x1080-tools.png`, `1920x1080-library.png`;
- `1366x768-120-builder.png`, `1366x768-120-settings.png`,
  `1366x768-120-miniatures.png`, `1366x768-120-home-details.png`;
- `1920x1080-110-builder.png` and the corresponding 1366×768 / 2560×1440
  default-scale builder/candidate/home captures.

Save actions stay outside editor scrolling. At large interface sizes the inspector
scrolls; model availability is placed above its viewport so a placeholder is still
identified before the model is viewed. Library overflow and expanded home training
details scroll rather than extending beyond the window.

Synthetic keyboard focus navigation and controller Back were exercised through
Godot input events; no physical controller was connected. A debug-build monitor
snapshot with 185 catalog rows reported 13.797 ms CPU process time and 200 draw calls
on the RX 6750 XT system. Concurrent-run snapshots were 177.994–179.252 ms and 200–201 draw calls, so these
are observational samples, not a stable frame-time budget, optimization comparison
or release benchmark. At that point representative large models and batch conversion
were still unmeasured; the continuation below now records those local observations.

The following two launch failures were initially reproduced both during this redesign and in
the preserved pre-redesign staged source: `test_tactical_training` expects an immediate
started match; `test_match_result_ui` expects an immediate guided army setup. Baseline
comparison report:
`.tools/verification/20261106T204159985783Z/project/.tools/verification/20261106T205407389272Z/results.json`.
Its import/Python checks passed and both launch suites initially failed. These failures
are superseded by the asynchronous launch checks in the follow-up below. Their optional historical
starter fixtures were staged locally; this is not current rules-source verification.

`test_workshop_ui` now constructs its UI fixture from the consolidated current catalog,
uses explicit per-model overrides and gives its variant fixture the target definition
needed for consistent current-profile base normalization. It no longer requires the optional
historical training template. The new `test_configuration_workspaces` checks composition,
save/copy/reload across JSON numeric normalization, selection boundaries, settings,
guide recovery and configuration navigation. Test fixtures are not product catalog data.

No rules coverage, full army legality, source certification or network capability is
added by this presentation work. Existing project limitations remain authoritative.


## Continuation — acceptance review and remaining gates

This record supersedes the earlier launch-failure and unmeasured-preview limitations.
It does **not** mark all phases complete. The supplied plan is the requested design
scope; examples and suggested implementations were adapted to this repository.

| Phase | Current acceptance status |
|---|---|
| 0 — audit | Complete for the available local source and baseline; the twelve external reference images were not supplied. |
| 1 — foundation | Complete for the observed local screens, keyboard and synthetic controller events. |
| 2 — army workflow | Complete for the tested local create/edit/copy/save/reopen/delete and session-draft paths. |
| 3 — miniatures | Local linking, restoration, fallback, async selection/source scan/conversion and conversion round-trip checks pass. Six-default/60-appearance local batch planning and three heavy cached import completions are now measured; external whole-library transfers remain unverified. |
| 4 — home/setup | Local async launch, fallback, cancel, side changes, Continue and rematch pass. Separate-machine LAN is deferred. |
| 5 — secondary screens | Local screen parity checks pass, including persisted controls and real stored result summaries. |
| 6 — release review | Partial: native size/scale review, representative asset measurements and local regression are recorded; physical controller, human usability, separate-machine LAN and wider device/external-transfer review remain open. |

### Corrections and behavior

- Successful asynchronous visual preparation now dismisses Home and the setup
  workspace only after a local match actually starts. Cancelling, changing sides
  during preparation and late completions cannot silently launch the wrong match.
- The old immediate-start tactical/result fixtures now exercise the real public
  prepare → explicit available-models continuation. The test double replaces only
  transfer completion, uses the actual requested definitions/scopes and performs
  no network activity; it does not bypass admission or fabricate a rules result.
- Closing Army Builder exposes **Resume unsaved draft**. Editing the same saved
  army resumes its session revision. New/Edit/Duplicate require Save draft,
  Keep editing or explicit Discard before replacing a dirty draft. A failed save
  leaves the revision and the pending decision intact. The save schema is unchanged.
- Heavy OBJ/composite previews use the existing worker-safe loader, followed by
  main-thread texture upload and scene installation. Generation checks discard
  obsolete completions after selection changes, closure or teardown. Catalog
  browsing preserves the roster import target and all army fields.
- The appearance source is loaded on demand, with both parsing and large-catalog
  variant matching in the background. Explicit source scans and the first-run
  file choice also use that worker; obsolete paths cannot replace the catalog or
  override Continue without models. GLB preparation/linking runs in the worker
  and rechecks the preview, destination, fit and source entry before installing a
  mapping; an obsolete conversion cannot replace a newer selection. Its loading message is revealed in the
  scrolling inspector; stale tab/entry requests cannot repopulate another view.
- The preview area is taller and complete fallback/equipment messages scroll
  instead of being truncated to two lines. Save and navigation remain outside
  the inspector scroll. Camera buttons are hidden while its model is loading.
- Results reports damaged JSON as an invalid local file without raising an engine
  parse error or rewriting the file. Deferred focus helpers validate their target
  after deferred delivery, including when the original Control was freed.

### Regression matrix

The matrix describes observed scope, not universal or source-certified coverage.

| Plan IDs | Evidence and scope |
|---|---|
| A01–A06 | `test_army_builder`, `test_configuration_workspaces`, `test_workshop_ui`: current-catalog composition, copies, totals, options, selection, save/copy/reload and appearance separation. |
| A07 | `test_army_draft_navigation`: copy/save compatibility, dirty revision recovery, failed-save recovery and delete confirm/cancel. |
| A08 | Army-builder/workshop scope checks retain unit/model assignments; real local Appearance renders 396 options. This does not visually certify every sculpt. |
| M01–M03 | Workshop/local-model suites cover placeholders and local imported meshes, persistence, missing/corrupt inputs, source fingerprints and GLB round trips; native captures inspect four existing imported models. |
| M04 | `test_model_download` covers controlled transfer/cancel/retry; launch preflight uses a controlled completion boundary. No live external download or whole-library batch certification is claimed. |
| P01 | `test_configuration_screen_parity`: public Continue restores the saved state and reveals the match. |
| P02 | `test_match_launch_workflow`, tactical and result/rematch suites cover local preflight, explicit fallback, cancellation, changed sides and setup closure. LAN callbacks remain reachable; real LAN is deferred. |
| R01 | Empty, populated, zero-search and corrupt-file results use the real local writer/browser; native populated captures are labelled controlled fixtures. |
| S01–S02 | Settings Apply/Revert, staged versus active controls, occupied-key swap, reserved/modified keys, unfinished capture and Escape cancellation are checked. |
| U01 | Keyboard focus and synthetic gamepad Back pass. No physical controller is connected in the native measurement. |
| U02 | Native 1366×768, 1920×1080 and 2560×1440 review, plus 1024×768 compact layout; 100/110/120% scales are covered across the original and follow-up captures. Content scrolls; footer actions remain reachable. |

The broad follow-up passed **12/12 processes** (import, Python and ten suites),
network disabled, with existing optional historical fixtures staged only where
needed. Report: `.tools/verification/20261106T223900607426Z/results.json`.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --only test_configuration_screen_parity --only test_match_launch_workflow --only test_tactical_training --only test_match_result_ui --only test_army_draft_navigation --only test_model_download --only test_workshop_ui --only test_configuration_workspaces --only test_gameplay_layout --timeout 300
```

After moving large appearance matching to the worker, the focused run passed
**5/5 processes** (import, Python, asynchronous miniature preview, local models and
workshop UI). It checks late preview/appearance completions, switching tabs,
closing the editor and teardown while a worker is active. Report:
`.tools/verification/20261106T224332353778Z/results.json`.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_async_miniature_preview --only test_local_models --only test_workshop_ui --timeout 300
```

The local-model suite dynamically enters an existing historical allocation lab.
`tools/verify.py` now declares that fixture dependency explicitly; it stages existing
local data and does not download content or admit historical profiles into the
current construction catalog.

### Native evidence and performance

Ignored evidence directory: `.tools/ui-redesign-followup-20261106/`. Native captures
include `1920-loading.png`, `1920-real-preview.png`, appearance loading/ready,
unsaved confirmation/resume, compact preview/settings and
`1920-populated-results-fixture.png`. These are actual Compatibility-renderer
screens. The result capture uses a controlled saved outcome, not a human-played
match. Scroll positions intentionally expose different parts of the inspector.

Measurements use an isolated APPDATA profile and a copy of the existing model
configuration. The original file's SHA-256 was unchanged before/after. The measured
inventory contains **162 mappings and 64 variants**; these are local runtime counts,
not a model-library completeness claim. No third-party asset was downloaded or
added to Git.

| Imported model | Selection callback | Preview ready | Warm callback range |
|---|---:|---:|---:|
| Intercessor Squad | 7.25 ms | 584 ms | 1.62–1.80 ms |
| Repulsor | 8.77 ms | 621 ms | 0.59–0.70 ms |
| Land Raider Crusader | 12.16 ms | 1512 ms | 0.48–0.75 ms |
| Redemptor Dreadnought | 8.53 ms | 1826 ms | 0.61–0.65 ms |

The earlier synchronous callbacks measured 9372, 891, 1565 and 1674 ms respectively;
the first also eagerly parsed a hidden 32,256-entry appearance source. These are
sequential debug observations with OS/cache variation, not a controlled speedup
benchmark. After the change, preview loading spans frames with explicit feedback;
maximum observed loading-frame intervals were 42–57 ms. Display-paced frame p95
was approximately 32 ms; it is not an independently measured release FPS budget.
Full measurements: `real-asset-profile.json` and `real-asset-profile-after.json`.

First Appearance access to that 32,256-entry source exposed a separate 3.8-second
main-thread matching pause. Moving that matching to the worker retained 396
options. The final native capture run observed roughly 5.1 seconds total loading,
2.4 ms dispatch and a 109 ms maximum frame interval (an earlier follow-up was
5.5 seconds / 3.2 ms / 126 ms). This remains a local debug observation;
loading time and worst-frame latency are separate quantities.

Sequential GLB conversion and verified reload succeeded for Repulsor, Land Raider
and Redemptor. The measured conversion calls took approximately **4–18 seconds**
before the conversion UI was moved to the shared worker. The roughly 43.6-second four-model
review included render sampling, waits and conversions; it is not batch-import
throughput. These initial stalls are superseded by the conversion/source-scan follow-up below.
Full large-library transfer/import and weak-GPU behavior remain wider performance work. The
redesign must not be described as fully release-validated while those gates remain.

### Remaining acceptance work

- Exercise broader real transfer/import batches and weak-device behavior. Heavy
  previews, source scanning, six-default/60-appearance batch planning, three heavy
  cache completions and three local conversions are measured in the background,
  with stale completion/link protections. Controlled network
  tests do not establish external-service availability or whole-library throughput.
- Observe physical-controller focus, confirm/back and settings capture on actual
  hardware. Synthetic events establish mapping and routing only.
- Complete the project's final separate-machine LAN integration, including side
  assignment, joining, menu interaction and unchanged match-state semantics.
- Perform human usability and wider accessibility/device review. No numeric design
  score or whole-library visual certification is claimed.


### Conversion and explicit-scan follow-up

The later native run uses the same shared worker API called by the advanced GLB
button and source-pose linking. Repulsor, Land Raider and Redemptor converted in
5.58, 6.24 and 5.94 seconds respectively, while the main loop advanced 175, 196
and 186 frames. Their maximum observed frame intervals were 48.9, 49.3 and
49.0 ms. Each package reopened with its verified source/fit checks intact.
`real-asset-profile-conversion.json` records the measurements. This establishes
responsiveness for these existing local examples, not a release/device benchmark.

Explicit scanning of the actual 32,256-entry source dispatched in 0.081 ms and
finished in 6.66 seconds across 206 observed frames, with a 98.3 ms maximum frame
interval. The library caps displayed rows at 200 and reports the full result count.
Captures `1920-source-scan-loading.png` and `1920-large-miniature-library.png`
show its actual feedback and populated state. Source configuration integrity was
checked again: SHA-256 unchanged. No asset download was requested.

The extended async suite additionally checks conversion busy feedback, changed-fit
rejection, verified prepared-key persistence, stale source scans, successful source
installation and the first-run skip/scan race. A successful scan or conversion
keeps the same storage formats and validation owners. Obsolete work may finish
writing an unused local cache package, but never installs its mapping.


The final scan/first-run race suite passed **3/3 processes** (import, Python and
`test_async_miniature_preview`) at
`.tools/verification/20261106T225133842344Z/results.json`, network disabled.
It supersedes the immediately preceding fixture-only parse error (a missing
Dictionary annotation); that failed run is retained at
`.tools/verification/20261106T224946043919Z/results.json`. Its local-model and
configuration-workspace suites passed; the corrected extended suite passed in the
final run. No failure has been counted as a passing process.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_async_miniature_preview --timeout 300
python .agents/skills/godot-nodes-scenes/scripts/check_godot_project.py . --json
git diff --check
```

The project reference check returned 0 errors / 1 existing orphan-UID warning
(`tests/test_jump_pack_chaplain.gd.uid`). Whitespace validation passed; Git emitted
line-ending normalization notices. Calculated sRGB contrast for the shared opaque
theme tokens is 13.04:1 body text/surface, 8.07:1 muted text/surface and 8.74:1
gold/base. These token calculations are not a comprehensive accessibility audit or
a numeric visual-quality score.


## Final local acceptance follow-up — batch planning and stress layouts

### Measured batch defect and correction

A native offline review of six existing unit defaults and 60 requested local
appearances exposed an additional **11,134 ms synchronous preparation callback**.
All files were already present, so this was catalog/cache planning cost, not a slow
transfer. The input snapshot is retained in ignored `batch-profile-before.json`.

Large-source planning now runs source parsing, cache indexing and pure candidate
selection on the shared worker. The main thread owns live queues, mappings,
validation, saves and signals. Small fixture catalogs retain the existing immediate
path; all-saved batches without appearance requests still reuse immediately.
Directory sources use the size of their `ForceOrg.json` for the same decision.
Cancellation invalidates the generation before any queued replacement is installed.
If the source changes or becomes unreadable, reused defaults are distinguished from
unresolved appearances, preventing a falsely complete preparation result.

The same six defaults and 60 appearances subsequently completed with **1.63 ms
callback dispatch**, approximately **7.13 seconds** total work across **224 frames**,
and a **120 ms maximum observed frame interval**. Every requested local visual was
ready; **zero external transfer attempts** occurred. These figures compare the
same local inputs in sequential debug runs, not release throughput or a controlled
hardware benchmark. `batch-profile.json` contains the final measurement.

Heavy cached-item and cached-appearance parsing also uses the existing worker-safe
asset reader and main-thread texture finalization. A late cancelled completion cannot
install its unit mapping or appearance. The original admission, fit, dependency,
fingerprint and persistence owners remain in place. The visible action now reads
**Cancel preparation** while a batch is being prepared; the native capture
`1920-batch-planning.png` shows actual busy feedback and the available cancel action.

A separate native cache-completion fixture exercised the normal completion handler
with actual Repulsor, Land Raider and Redemptor files. Each installed its local map
and cache successfully, with callback dispatch 0.08–0.11 ms, total preparation
0.72 / 1.61 / 1.88 seconds and maximum frame intervals about 115 ms. This fixture
supplies the existing local-file completion boundary; it does not simulate a live
HTTP transfer. `batch-import-profile.json` records the outputs. Existing missing
MTL notices for Repulsor/Redemptor remain explicit; declared textures/default
materials are used, and complete material fidelity is not claimed. Source
configuration SHA-256 remained unchanged in every native run.

### Large roster and long-text evidence

`layout-stress.json` and eight `*-stress-roster.png` / `*-stress-notes.png` native
captures exercise **48 entries / 240 models**, a name beyond the supported
120-character limit, long row labels and 300 repeated note sentences. These are
labelled display stress fixtures, not legal army lists or source facts.

At 1920×1080 and 2560×1440 (100%), and 1366×768 and 1024×768 (120%), the entire
editor and Save/New match controls remained within the viewport. The final row
stayed selected and scrollable, its tooltip retained the full label, long notes
stayed inside their editor, and compact navigation activated at the narrower
logical width. The existing name-length error remained legible and disabled Save.
Roster rebuild dispatched in approximately 14.6 ms in this debug observation.
The captures were inspected individually and through `stress-contact-sheet.png`.

### Checks and correction history

The batch/import regression run passed **6/6 processes** (import, Python,
`test_automatic_model_preparation`, `test_local_armies_models`,
`test_forceorg_catalog`, `test_async_miniature_preview`) at
`.tools/verification/20261106T230038658297Z/results.json`, network disabled.
Existing local optional historical fixture staging is recorded in that report;
it does not extend current construction or source certification.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_automatic_model_preparation --only test_local_armies_models --only test_forceorg_catalog --only test_async_miniature_preview --timeout 300
```

The subsequent extended cancellation check passed **3/3 processes** at
`.tools/verification/20261106T230218184539Z/results.json`, network disabled,
without historical fixture staging. It additionally covers heavy cached unit and
appearance parsing cancellation, plus directory-source background planning.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_automatic_model_preparation --timeout 300
```

`test_forceorg_catalog` now awaits the existing 150 ms search debounce before
checking filtered identity and empty results. Its earlier immediate assertions
failed at `.tools/verification/20261106T225657594601Z/results.json`; the corrected
suite passed 3/3 processes at `20261106T225841650431Z`, then in the 6/6 run above.
The new batch fixture initially used a constant named `Panel`, shadowing Godot's
native type; it was renamed `ImportPanel`. The mixed initial run at
`20261106T225756920497Z` failed that fixture and passed the local launch suite.
The corrected batch suite passed at `20261106T225904414514Z` and in both final
runs above. Two exploratory native import fixtures were stopped after setup
errors (typed-array assignment and missing captured catalog metadata), corrected,
and rerun successfully. Their failures are not counted as import success.

Final reference validation returned **0 errors / 1 existing orphan-UID warning**;
`git diff --check` passed. Both installed skill-file SHA-256 values still match the
pinned installation recorded above. No third-party asset was added to Git, no
external model request was permitted in the native batch review, and no rules,
army legality, network certification or save schema was added by these changes.

### Completion audit of this continuation's objective

| Requirement | Authoritative observed evidence |
|---|---|
| Investigate/resolve local launch regressions | Actual Home/setup dismissal fix; controlled public async preflight/fallback/cancel/changed-side tests, tactical exercise, Continue and rematch in the 12/12 run; local launch suite also passed during the batch follow-up. |
| Verify miniature/import and secondary-screen parity | Current roster save/copy/reload and local model/source/GLB suites; real empty/populated/corrupt-result and settings-binding checks; 6/6 import follow-up plus native source, appearance and conversion evidence. |
| Improve accessibility and responsive layout | Shared focus/contrast states, keyboard/synthetic controller navigation, deferred focus validity, 100/110/120% scaling and native compact/48-entry/long-text stress captures. |
| Profile representative local assets and batches | Four actual imported model previews, three verified worker conversions, full 32,256-entry source scan, six-default/60-appearance planning and three heavy cached completion-handler imports with frame/dispatch measurements. |
| Report physical-controller/separate-machine limits accurately | No physical-controller session or separate-machine LAN test was performed; synthetic events, local profiles and offline controlled completions are labelled explicitly. Human usability, weaker hardware and whole-library external transfer coverage remain outside the observed scope. |

This closes the local acceptance work requested by the active continuation goal.
The **overall redesign release gate remains partial** until the separate physical,
human and wider-device/network reviews above are performed. This audit does not
turn those remaining release checks into passed tests or claim that every phase
of the original plan is certified complete.

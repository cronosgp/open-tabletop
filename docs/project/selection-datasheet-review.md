# Selection responsiveness and datasheet review

24 October 2026. Implementation candidate; new human acceptance remains open.

## Findings and design

The player's review identified selection/focus delay and an over-dense model card. The existing sidebar repeated player and living-model counts already present in the army list, repeated normal `Steady` status, and expanded weapon profiles into small continuous text. Keep the army list for composition and casualties; use the selected-model card for its wounds, characteristics and exceptional conditions. Keep the existing two-sidebar tabletop layout rather than introduce another permanent panel.

The first compact-card candidate still occupied too much space above the army list. The next human review rejected that placement. The selected model now appears as an integrated footer below the scrollable army list, separated by one rule rather than a nested bordered card. It shows unit name, ordinal/role, current/max wounds, a small wounds bar and relevant exceptional or movement/action state. The six characteristic cells are reserved for the full datasheet. `Datasheet` opens that inspector; the roster retains most of the available height. No third panel covers the board.

The right panel heading now follows the authoritative phase (`COMMAND`, `MOVEMENT`, `SHOOTING`, `CHARGE`, `FIGHT`, plus preparation/start/end states), with `MATCH RESULT` at a recorded outcome and `ACTIONS` in the movement demo. Existing decision ownership and interrupt controls remain underneath the phase heading. This heading reads state directly and adds no legal-choice projection.

`Datasheet` opens the existing local inspector overlay. It presents M/T/Sv/W/Ld/OC across one row, selected-model conditions, ranged and melee sections, keyword lines and ability references. Each weapon profile stacks its name above a three-column grid for Range, Attacks, BS/WS, Strength, AP and Damage; this removes the fixed 200-pixel name column and six 56-pixel stat columns that could exceed the narrow inspector. The stats remain labeled per profile, and long names and keyword lines wrap inside the vertical inspector. All values come from the current match's existing model, defense and equipment projections; ability names are references, not a claim that every source ability is fully supported. Opening and closing the inspector preserve state and selection. The new compact profile layout has no current Godot capture or visual acceptance evidence.

Other concrete redundancies addressed in this correction cycle: the optional pass/keep action appears only in its dedicated button when one is legal, and save outcomes distinguish confirmed protection, failed saves awaiting allocation, and applied damage. Global decision ownership remains visible because interrupting decisions can belong to the other player. The generic Command opportunity cue and longer ability explanations remain candidates for a later comprehension-led pass; no further information is hidden solely to reduce text.

## Measured responsiveness

Godot 4.7.2 OpenGL debug runtime on the same Windows machine and stored tactical checkpoint, eight scripted roster selections per run. This is CPU instrumentation and engine-monitor evidence, not release-build FPS, GPU timing, human latency or platform certification.

| Scope | Before | After |
|---|---|---|
| Synchronous UI refresh per selection | 166.1–173.9 ms | 7.2–9.6 ms |
| Camera subject/fitting call | 0.14–0.18 ms | 0.14–0.17 ms |

The major delay came from rebuilding authoritative legal-choice, normalized-decision and command-gate projections repeatedly for an unchanged match. The camera was waiting behind that work and an extra deferred roster-selection callback. Selection now updates synchronously and reuses read-only projections for the same dictionary identity and revision. A normal refresh always rebuilds them; a changed revision or replacement snapshot invalidates reuse. Movement-specific checks still inspect the selected model, and every submitted action still uses authoritative validation. No validator was weakened or moved into the renderer. Hidden full datasheet profiles are now built only when inspected.

Raw before/intermediate/final measurements are `.tools/selection-profile-{before,cached,after,remaining,final}.json`. The command was `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --rendering-method gl_compatibility --profiling --script .tools/profile_selection.gd -- final` (replace `final` with the recorded stage). The test-only subclass measures calls into the current main script; it is not shipped. One profiling attempt referenced a nonexistent override and terminated with a parse error; the corrected instrumentation produced the final measurements. The profiler's two-frame observation field is not an input-to-photon measurement.

## Evidence

- Actual Godot captures: `.tools/selection-card-before-1280.png`, `.tools/datasheet-review-card-{1280,1024}.png`, and `.tools/datasheet-review-weapons-{1280,1024}.png`. The final card and inspector were inspected at 1280×800 and 1024×768; no required control or table column was clipped. The long plasma profile fits without repeated legends. These are scripted restored-match views, not mockups or human acceptance.
- `test_selection_response` exercises synchronous roster selection without state mutation, projection reuse, invalidation after an actual public Captain ability, replacement-snapshot invalidation, and inspector/selection recovery.
- `test_selection_card` additionally covers the compact fields, full inspector, read-only browsing, stale/destroyed selections, and preserved required Precision/allocation decisions. Its existing historical fixture now has an explicit local snapshot dependency in the verifier; the current-catalog response test needs no legacy snapshot or download.
- The broad local command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_selection_response --only test_selection_card --only test_decision_camera --only test_choice_ownership_ui --only test_gameplay_layout --only test_tactical_training --only test_doctrine_choice_ui --only test_save_outcome_ui --only test_combat_tray --only test_attack_feedback --timeout 300` passed **12/12 processes**, including **39 Python checks**, at `.tools/verification/20261024T213835681697Z/results.json`. This predates only the final column-legend/health-bar styling refinement; final checks are recorded in the main progress report.

The remaining human gate is whether selecting, focusing and reading the new card/datasheet feels clear during actual play. Existing rules, army-legality and network/platform limits remain unchanged.

## Footer and phase-heading follow-up

Actual Godot restored-match captures: `.tools/selection-footer-{1280,1024}.png`. Inspected at 1280×800 and 1024×768. The footer and inspector action fit without clipping, and the Movement checkpoint correctly displays `MOVEMENT`. Phase-label regression covers Command, Movement, Shooting, Charge, Fight and End of Turn; selection/inspector tests retain the read-only and recovery checks. This is local presentation evidence, not a new rules or human-acceptance claim.

Follow-up verification: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_selection_card --only test_selection_response --only test_decision_camera --only test_gameplay_layout --timeout 300` passed 6/6 processes, `.tools/verification/20261024T215647113751Z/results.json`.

## Ability explanation follow-up

The inspector now displays descriptions from the verified optional local Wahapedia 11e relational export, alongside the existing project-authored implemented scope. It joins datasheet ability rows to shared abilities, shows model/parameter context and snapshot provenance, and strips HTML without executing it. It never writes reference text into authoritative match state. Missing identity, absent export and integrity failure remain explicit; it does not fetch a fallback edition or bundle the export.

Evidence: `.tools/datasheet-review-ability-rules-{1280,1024}.png`, actual restored Hellblaster match, scrolled to the ability section and inspected at both sizes. The capture asserts nonempty Thermal Appeasement source text, state immutability and inspector recovery. The initial Godot CSV reader treated unescaped inch/HTML quotes as CSV quoting and failed the source assertion; it was replaced by the export's pipe/numeric-record parser, with multiline and inch-mark regression checks. The corrected capture passes.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_selection_card --only test_selection_response --timeout 300` passed 4/4 processes, `.tools/verification/20261024T220318974006Z/results.json` (before only the final heading/list whitespace refinement). The final loader check `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script .tools/test_ability_reference.gd` passed: verified snapshot lookup, plain headings/lists, multiline inch marks, missing identity. Actual OpenGL final capture `.tools/capture_ability_rules.gd` passed after the refinement. Source snapshot remains 20261021T130623Z, retrieved 2026-10-21T19:46:58Z; no new source certification or network check. This follow-up changes the project sources; the earlier packaged candidate has not been rebuilt for it.

## Consolidation re-audit — 24 October 2026

The complete reader audit now checks the user-data snapshot first, then the local development snapshot. The installed snapshot manifest must record the source URL, 11e/Space Marines context, matching snapshot folder ID, retrieval time, export revision and SHA-256 for every listed file. A broken user snapshot remains an explicit error and cannot fall through to project data. The source reader resolves inline and shared ability definitions, keeps multiline pipe-delimited values and Unicode, strips markup into display text, and fails the full load on unresolved source rows. An identity with no ability rows is identified separately. The fixture regression covers external precedence, tampered hashes, malformed tables, conflicting shared definitions, plain markup, and unavailable source text.

The project-local verified snapshot remains `20261021T130623Z`: 23 manifest files, every listed hash verified, with 22 CSV tables and the specification workbook. The parser audit found 193 Space Marines source datasheets, 192 identities with ability records and 882 resolved ability rows; the remaining identity is retained and reported as a known datasheet with no listed ability entries. The 25 October feedback update is pending focused local verification. This is an audit of the existing local export, not a source refresh or rules certification. Source text stays separate from project-authored implemented scope.

**Static source scan — 26 October 2026:** all 23 files currently listed in the local snapshot manifest still match their recorded SHA-256 values. A scan of the two ability text tables found no named or numeric HTML entities outside the reader's explicit entity map and XML entity handling. The observed table markup uses `td`/`tr` boundaries already converted to spaces and line breaks; the scan found no `th` cells or image `alt` text. The reader source and fixture were inspected for multiline records, shared definitions, missing identities and unresolved cross-file relations; this was a code/source review only. No reader test or Godot run was performed, so runtime parsing and display remain pending focused verification.

Actual Godot captures in `.tools/worklog/consolidation-baseline-20261024-191705/screenshots/datasheet-reference-{1024,1280,1920}.png` show the source and implementation sections at each requested size. The new exported-pack smoke uses isolated user data to confirm the optional source is absent while implemented scope remains visible. It also saves the tactical preparation state, changes it, then reloads and compares the complete state and RNG. The final report and artifact identity below supersede the earlier note that the source follow-up had not yet been packaged. These checks do not establish human comprehension or that every listed ability is implemented.

## Roster selection update and performance recheck — 24 October 2026

The same eight-selection checkpoint exposed avoidable army-list work: selected model ID was part of the roster digest, so each selection destroyed and rebuilt all model rows. The roster now retains those buttons when displayed match data and active owner are unchanged, updating only the old and new selection styles. Changes to displayed wounds, casualties, reserve state, Battle-shock, names, owners or Sergeant labels still invalidate the digest. `test_selection_response` checks row identity across selection changes and verifies a wounds change rebuilds the affected rows.

Before that change, two checkpoint runs measured `_refresh` at 9.3–13.3 ms. Two post-change runs measured 4.3–8.1 ms and 4.4–6.0 ms; `_refresh_army_roster` fell from 3.4–5.7 ms to 0.2–0.6 ms. The two-frame observation ranged from 68.1–76.6 ms after the change, with `TIME_PROCESS` readings of 35.4–41.9 ms, compared with 25.3–27.1 ms in the earlier profile. This is debug-runtime instrumentation and does not establish release FPS or input-to-photon latency. The synchronous UI refresh improved; the full frame observation remains inconclusive under the measured frame load. Raw profiles are `.tools/selection-profile-final-consolidation.json`, `.tools/selection-profile-final-consolidation-repeat.json`, `.tools/selection-profile-final-roster-update.json` and `.tools/selection-profile-final-roster-update-repeat.json`.

Final candidate verification: the 22-process targeted report is `.tools/verification/20261024T230814521351Z/results.json`; the complete demo/loopback report is `.tools/verification/20261024T230025979983Z/results.json`; and the final package report is `.tools/verification/build-20261024T224938400914Z/results.json`. The targeted recovery test saves a pending damage-allocation decision to disk, reloads it, and compares the state, RNG, legal options, owner and resolution frame before continuing. The corresponding PCK is `.tools/verification/build-20261024T224938400914Z/open-tabletop-demo.pck`, SHA-256 `a95a65c6d639dc780d8225add1fb880b1b5fd3fd8a11da7acc1ab1a79adfdabe`. Its isolated pack smoke confirms no optional source text is installed, implemented scope remains visible, inspection is read-only and the saved setup recovers with exact state/RNG equality. Human acceptance remains pending.

## Combat tray safe-area follow-up — 26 October 2026

Review of the existing actual 1024×768 allocation capture (`.tools/worklog/consolidation-baseline-20261024-191705/screenshots/ux-flow-allocation.png`) shows the combat tray's lower edge and presentation controls clipped by the viewport. `_layout_combat_tray` now measures the tray after width-dependent text wrapping and reserves a 32-pixel bottom margin when placing it. This is a code change based on the recorded capture; no new Godot capture or runtime verification was made in this increment. Recheck the allocation decision at 1024×768, 1280×800 and 1920×1080 after the user can run the game. Human acceptance remains pending.

## Inspector model-switch reading position — 26 October 2026

When the datasheet overlay remains open and the selected model changes, the inspector now resets both scroll axes before presenting the new profile. Reloading the same profile's local source reference preserves the current reading position. This changes presentation state only; it does not alter match state or the selected model.

No tests, Godot interaction or capture were run because testing is unavailable. Model-switch and source-reload behavior remain pending focused visual and input review.

## Implemented scope before source reference — 26 October 2026

When project-authored scope entries exist, the inspector shows Implemented Scope before the optional local Source Rules section. A visible note clarifies that source text is reference material and does not establish that its effects are implemented. This keeps current match capability boundaries visible before long reference descriptions.

No tests, Godot session or capture were run because testing is unavailable. Section order, long-text fit and the no-source state remain pending visual and interaction review.

## Optional source-reference foldout — 26 October 2026

Verified local ability text now starts collapsed behind a `Show source reference` action, so the match's project-authored scope remains first in the inspector. Integrity errors and incomplete-export warnings start expanded; reloading the source opens the section to show status. The player can toggle the reference, and a new model profile resets the foldout state.

No tests, Godot interaction or capture were run. Focus behavior, fit, reload feedback and source-present/source-absent states remain pending visual and input review.
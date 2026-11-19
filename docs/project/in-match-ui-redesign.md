# In-match UI redesign and stability — 6 November 2026

Implementation log for `open_tabletop_in_match_ui_ux_redesign_agent_plan.md`.
The user requested all eight phases. The document is a design specification, not
proof of implemented behavior. All phases remain in scope. Existing configuration
redesign and unrelated worktree changes are preserved.

## Phase 0 — Repository audit and baseline

**Status:** Source, crash evidence and native baseline captured.

### Stack and ownership

| Responsibility | Existing owner / boundary |
|---|---|
| Entry/runtime | `scenes/main.tscn`: Node3D with `scripts/main.gd`; Godot 4.7.2 stable, Compatibility/OpenGL 3.3. |
| Scaling | `project.godot`: 1280×800 reference, `canvas_items`, expanded aspect. 1920×1080 is the new design reference, not a replacement coordinate system. |
| HUD/roster | `scripts/ui/combat_hud.gd`, `army_roster.gd`; `main.gd` owns the action groups, recipient controls and overlay routing. |
| Theme | Reuse `scripts/ui/workspace_theme.gd` from the configuration redesign. |
| Dice/results | `combat_tray.gd`, `dice_pip_face.gd`, `combat_symbol.gd`, `attack_feedback.gd`; presentation must use recorded data. |
| Specialized UI | `decision_steps.gd`, `doctrine_choice.gd`, `movement_choices.gd`, `placement_feedback.gd`. |
| Inspector/reference | `unit_datasheet.gd`, `local_ability_reference.gd`; source errors must remain diagnosable separately from tactical actions. |
| Board/camera | Horizontal state Vector2 maps to world X/Z in inches; Y is elevation. `decision_camera.gd` and `table_camera_motion.gd` are presentation. UI geometry never changes measurement or collision. |
| Match authority | `scripts/edition_11/combat_scenario.gd` and existing services own phases, CP/VP, movement, deployment, wounds, reactions and resolution. |
| Decision authority | `match_actor.gd`, `pending_decision.gd`, `pending_decision_registry.gd`, `resolution_frame.gd` expose priority, decision/option IDs and interrupted resolution. Adapt these read-only projections; do not duplicate legality. |
| Command dispatch | `match_command_service.gd` validates revision, actor and projected choices. `main.gd` routes local and authenticated host/client requests. |
| Local handoff | `local_player_handoff.gd`; privacy acknowledgment is distinct from turn ownership and absent from LAN-client authorization. |
| Saves/history | `match_save.gd`, journal/history services and `main.gd` publication/save/load paths retain native IDs/types, pending decisions, attack draft and RNG. Existing version-1 format, temporary write, backup and five-slot ownership remain authoritative. |

Selection of a recipient, target, weapon or die is a presentation draft. Only its
existing authoritative command commits. Allocation uses the combat allocation
service for eligible recipients, wounded priority, Precision, group order and
damage/Feel No Pain.

Autosave follows accepted published commands. Attack-draft-only changes require a
manual save. Recovery must use actual validated snapshots/journal checkpoints;
manual saves cannot be overwritten by invented recovery state. The capability
registry and current support matrix remain authoritative about rules and network
coverage; UI clarity does not establish official army legality.

### Crash evidence and reproducible baseline

Ignored `.tools/in-match-redesign-20261106/source-baseline/` preserves pre-change
scripts, scenes and project configuration. `baseline-main.sha256` identifies the
starting controller. Native `reported-crash.log` and `crash-evidence.json` preserve
the user's available local log, its SHA-256, OS, engine/build and GPU.

That log contains six errors about a signal emitter being freed, followed by a
native signal-11 crash. The GDScript traces point to recipient selection →
`_refresh` → `_refresh_defense_steps` → immediate `card.free()` at main.gd:7620.
This is code-level evidence beyond correlation with the final screenshot.

The new deterministic `test_allocation_lifecycle` emits the actual recipient-card
button signal after real synthetic attack/save decisions. It reproduced the same
emitter-lifetime error and failed at
`.tools/verification/20261107T014643049531Z/results.json` (network disabled).
Import and Python passed; the existing `test_damage_allocation` separately failed
its wounded-model assertion in the untouched baseline. Neither failure is a pass.
The lifecycle fixture uses synthetic weapons and does not certify datasheet facts.

Normal start: import `project.godot` in Godot 4.7.2 and run `scenes/main.tscn`.
Scoped verification uses the existing isolated runner:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_allocation_lifecycle --only test_damage_allocation --timeout 300
```

### Reference-to-state map

The twenty screenshots are described by the plan but not supplied as image files
in this chat. New native captures will be labelled controlled states, not claimed
pixel-for-pixel reproductions of unseen references.

| References | Actual state/subsystem |
|---|---|
| S01, S07 | Army preparation, Warlord and supported declarations |
| S02, S03 | Camera/roster visibility and shared selected model ID |
| S04, S05 | Expanded datasheet/source status |
| S06 | Local privacy handoff |
| S08, S09 | Deployment preview, floor, squad confirmation |
| S10, S11 | Command doctrine and optional unit/stratagem choices |
| S12–S14 | Movement draft/validation/elevation and opponent reaction |
| S15–S17 | Attack assignments/declaration and defensive response |
| S18, S19 | Recorded dice decision and committed attack results |
| S20 | Failed-save recipient preview and allocation command |

### File-by-file implementation sequence

1. `main.gd` recipient lifecycle plus regression near allocation; inspect existing
   decision IDs/command guards and save boundaries before UI movement.
2. `combat_hud.gd`, shared theme and command layout: compact status/owner strip,
   board-safe geometry and pinned current-action footer.
3. Read-only UI adapter over existing pending-decision registry; distinguish
   mandatory, optional and reaction choices without changing their authority.
4. Existing placement/movement views and controller routing: preparation/deployment,
   inline validation, floor selection and camera/draft preservation.
5. Combat tray, attack review, recipient presentation: one resolution surface,
   recorded replay and guarded authoritative confirmation.
6. Inspector/roster/labels/handoff/guide and diagnostic routing: compact readable
   views, annotation density and preserved privacy/focus.
7. T01–T36 regression, native equivalent-state captures/scales, profiling and
   documented physical/network limits. Only then retire superseded UI wiring.

## Design brief

Keep the central board dominant. A compact phase/status rail identifies round,
turn player, CP/VP and a separate decision owner. The right rail presents one
current decision with pinned confirm/decline/cancel; long help and diagnostics
scroll elsewhere. A bounded resolution dock appears only for combat. Narrow
layouts collapse optional roster/details before shrinking critical actions.
Reuse ivory/gold tokens and semantic colors with explicit text/focus states.
No preview spends CP, rolls dice, applies wounds or advances the phase.

## Phase status

| Phase | Implementation and evidence |
|---|---|
| 0. Baseline | Complete. Source snapshot, crash log, deterministic reproducer and native allocation, handoff, deployment, Command and Movement comparisons are preserved. |
| 1. Allocation stability | Complete for the reproduced path. Recipient rows detach and free after their signals return. Revision and actor checks protect stale rows. Allocation ignores repeated activation in the same input cycle. Native recovery restored the exact pending allocation and RNG after process termination and disclosed rollback when the primary slot was corrupted. |
| 2. Shell | Complete for the tested workflows. The compact owner and phase strips, Tools menu and pinned action footer reuse existing commands. The turn caption keeps its full width instead of ending in an ellipsis. The score and the Actions, Menu, and Tools buttons sit on a second header row so they are not pushed off by the phase chips. The decision owner sits above the instruction so a long owner line does not squeeze it. The phase chips wrap with the turn caption instead of staying on one rigid row. Roster rows and the selected-model card keep their full names. Command explanations, the action heading, and the live opportunity cue do the same. Army preparation shows the Warlord choice before Finish, with the required reason directly above that button. Native comparisons cover Deployment, Command, Movement and Shooting. |
| 3. Decision presentation | Complete for the tested workflows. The owner strip reads the existing pending-decision identity and marks optional, required, reaction and allocation windows. The preparation and both opposing-player reaction flows were exercised. |
| 4. Placement | Complete for the tested workflows. Preview bases, deployment progress, the floor picker and rejection feedback use existing validation and geometry. A blocked move lists its validator reason in the movement panel without a four-line cutoff. A 3-inch floor selection and toggling both side panels preserved the live draft, selection and manual camera. |
| 5. Resolution | Complete for the tested workflows. The stage and outcome remain visible while the dice viewport scrolls. Attack context and the recorded result wrap in full inside that scroll when the dock is height-capped. The dock width stays inside the open gap between the roster and the command rail. Recorded dice and the combat history use the command rail's width instead of a 390- or 400-pixel floor. Each recorded face keeps its full caption and wraps inside that rail. The visible attack summary keeps discarded damage, including unallocated Hazardous wounds, and says when another attack is still pending. A failed save says damage is still pending and does not call it applied until allocation commits. The range card stays 280 pixels wide and scrolls its caption instead of covering the board. Match notices keep their full text in the command rail. A battle-log event with no early sentence break stays whole instead of ending in an ellipsis. Feel No Pain history text is in English. Loading a save whose history file was damaged reports that the history is corrupted. A failed save opens the recorded save stage. Attack planning reads the weapon and target before the review, and the damage preview stays in that same rail ahead of Declare. An opponent's allocation step still names that player while the local controls stay hidden. A reaction heading names the roll and the player who must decide. A blocked move keeps the requested and remaining distance in the command panel. Charge and fight placement show the selected model's remaining distance on its card. Armour of Contempt keeps a short closed-picker name, with cost and effect in the wrapping help and pinned footer. Declaration, defender response, keep/re-roll, selection and allocation have distinct controls. The selected allocation recipient is named in full in the allocation prompt. Command Re-roll stays the 1 CP action and closes when that stratagem is unavailable, including while a free Advance re-roll remains open. A free Advance or Charge re-roll keeps its own name and 0 CP label. Those rejection messages are in English. |
| 6. Inspector and handoff | Implemented for the tested workflows. The selection card previews M, Sv and OC. Profile values, the live guide and the waiting activity cue wrap in full. Full profiles, optional local source status, the field guide, battle log and diagnostics are independently reachable. Model preparation warnings leave a Tools marker and a brief notice clear of the action rail. The handoff covers the board and focuses the next decision after acknowledgment. Wide, medium and near annotations prioritize selection, eligible recipients and active targets in the clear board area. |
| 7. Integration | Partial. Targeted automation, native layout including 2560×1080, input-event simulation, recovery and host/client loopback have evidence. Tools routes native popup items directly to the existing signals. Model-download notices stay in Diagnostics, not between Warlord and Finish. Physical-controller and separate-machine LAN checks remain open because the hardware is unavailable. Removing `dice_visual` is deferred: the optional attack-details toggle and existing suites still use it. The project exposes no Low/Medium/High graphics presets to compare. |

### Remaining work to finish the plan

| Plan item | Current evidence | Status |
|---|---|---|
| Phases 0–6 exit criteria | Project log, paired captures S01–S20, layout and combat suites | Complete for the tested workflows |
| Definition of done except input/LAN | Crash fix, HUD shell, decision/placement/resolution/inspector flows with recorded checks | Complete for the tested workflows |
| Physical gamepad | Simulated gamepad input only | Open — hardware unavailable |
| Separate-machine LAN | Host/client loopback only | Open — second machine unavailable |
| Retire superseded widgets | `dice_visual` still wired to Show attack details | Deferred until a replacement proof exists |
| Graphics presets | None exposed by the project | Not applicable |
| Remaining command-rail label overflow | Deployment, doctrine, defense, attack plan and Help references now keep full wrapping text | Closed for the listed controls |
| Local handoff label overflow | Pass-the-table instruction and continue button keep full text | Closed — `tests/test_local_handoff_ui.gd` 0 failures |
| Match result panel overflow | Winner title, rematch note and actions keep full text | Closed — `tests/test_match_result_panel_ui.gd` 0 failures |

Command-rail labels for deployment, doctrine/oath/reanimation help, defense steps, attack planning, Help references and placement details now wrap without ellipsis. The local handoff card keeps its full instruction and continue label. The match result panel keeps its winner title, rematch note and action labels. Closable Phase 7 software work is closed for the tested workflows; physical controller and separate-machine LAN stay open because the hardware is unavailable.

### Implementation files and compatibility

| Phase | Implementation files and boundary |
|---|---|
| 1 | `scripts/main.gd` defers freeing recipient controls and checks the projected decision at submission. `scripts/match_recovery.gd` handles process markers independently of the version-1 save. The lifecycle fixture drives the same recipient controls that reproduced the crash. |
| 2 | `scripts/ui/combat_hud.gd` displays the phase and owner. `scripts/ui/decision_footer.gd` moves the original action controls and restores their owners and focus. Existing command subscriptions are retained. |
| 3 | `scripts/ui/match_decision_view.gd` projects existing owner, window and instruction data. Actor authorization remains in the gameplay dispatcher. |
| 4 | `scripts/main.gd` and `scripts/ui/placement_feedback.gd` display placement, floor and rejection details. The existing preview state and authoritative validators still control placement. |
| 5 | `scripts/ui/combat_tray.gd` presents recorded rolls and their outcomes. The controller retains the attack and allocation command paths. Replay reads the stored faces through the presentation layer. |
| 6 | `scripts/army_roster.gd`, `scripts/ui/unit_datasheet.gd`, `scripts/ui/local_player_handoff.gd` and `scripts/ui/guide_browser.gd` own the player-facing inspection and help surfaces. `scripts/ui/decision_camera.gd` and the controller keep camera and annotation changes outside match state. |
| 7 | `scripts/ui/combat_hud.gd` routes Tools items to the existing signals and restores full phase captions on resize. `scripts/main.gd` refits the action rail after wrapped content settles. The focused suites check the native menu routes, action availability, and rail geometry. |

Native captures and process logs are in `.tools/in-match-redesign-20261106/`.
The capture fixtures use synthetic weapons and built-in miniature markers.
No primary local slot inspected for this work contained the original S20 pending
attack. `interruption-recovery.json` records a synthetic pending snapshot restored
in a new Godot process and confirms the separate manual file remained unchanged.
`20261107T020107255969Z/results.json` records slot reselection and exact previous
backup recovery after corrupting a test-only primary save. These checks preserve
the version-1 format.

### Equivalent-state visual comparisons

The 14 visual QA cases in the plan have paired native captures. The 12
new pairs were rendered at 1920×1080 in the preserved baseline and current
projects. The comparison scripts require matching match-state digests,
camera transforms and selected model IDs before reporting a pass. These
controlled captures reproduce the described situations from the plan.

| Cases | Paired captures in `.tools/in-match-redesign-20261106/` |
|---|---|
| S01, S03, S04, S06 | `paired-preparation/`. Player 1 preparation, the deployed Captain selected, the Captain datasheet, and the Player 2 handoff. |
| S08, S09, S14 | `paired-preparation/`. Guide open during deployment, the Captain ready to confirm, and Player 2 Fire Overwatch during Player 1 Movement. |
| S10 | `baseline-required-doctrine-1920.png` and `current-required-doctrine-1920.png`. Required doctrine selection before commit. |
| S12 | `baseline-layout-movement-1600.png` and `current-layout-movement-1600.png`. The same pending Normal Move. |
| S13, S17 | `paired-combat/`. Rejected 30-inch movement with the draft intact, and the defender's pre-dice choice. The current elevated floor selection has a separate capture in `current-move-floor-1600.png`. |
| S18, S19, S20 | `paired-combat/`. Player 2 save decision, recorded attack outcome, and failed save with an eligible recipient selected. |

Run the comparison drivers from the project root with the baseline staging
project and local fixtures present.

```text
python .tools/in-match-redesign-20261106/run_paired_combat.py preparation
python .tools/in-match-redesign-20261106/run_paired_combat.py combat
```

The S09 comparison caught a roster panel that retained a temporary height of
928 logical pixels in an 800-pixel viewport. The roster now reapplies its
height after its content minimum changes. The same Captain checkpoint
returned to 671 logical pixels with the selection card and deployment action
visible. The original capture is `paired-preparation/S09-roster-overflow-1920.png`.
The S19 comparison also caught stale allocation instructions after the last
wound. The command now reports `Attack recorded.` when it publishes a new
completed attack. The S17 reaction choice keeps a short Armour of Contempt name in the closed
picker. Cost, target and effect stay in the wrapping help and the pinned
action footer, including at 1280×720 with 120% UI scale. Confirm and Decline
stay separate reaction actions.

The final layout run checked the roster alongside the header, action rail
and dice dock in all 150 cases. The targeted run at
`.tools/verification/20261107T151155885296Z/results.json` passed 7/7
processes covering the layout, combat outcome, allocation and command service.

The title displays a recovery notice only when a previous local session marker
matches a compatible saved checkpoint. The marker records the slot, journal
fingerprint and revision separately from the save. Normal exit clears the
session marker. Dismissing a recovery notice clears only that marker. Browsing
other saved slots and resuming the checkpoint use the existing save paths.
The live-process check was exercised on Windows. Godot's process query covers
child processes, so independent Windows instances use a local process lookup.
[Godot OS class documentation](https://github.com/godotengine/godot-docs/blob/master/classes/class_os.rst#class-os-method-is-process-running)

The historical `test_damage_allocation` wounded-model assertion exposed a
separate legacy attack-plan defect. Ranged batch preparation replaced the
weapon's fixed A characteristic with the number of assigned weapons. That
substitution is now confined to melee, where the batch counts individually
assigned attacks. The existing wounded-model test now passes and records
priority, destruction and resumption across consecutive allocations. Rules and
platform support remain governed by the project support matrix.

### Verification and captures

Run commands from the project root with the existing local optional starter
fixture staged by the verifier. The current catalog tests use the project catalog.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gameplay_layout --only test_combat_results_ui --only test_allocation_lifecycle --only test_match_save --only test_prepared_match --only test_selection_card --only test_tactical_training --only test_action_guidance --only test_turn_choices_ui --only test_tactical_guides --only test_combat_tray --only test_roll_choice_ui --only test_save_outcome_ui --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_attack_plan_network --only test_movement_network --network --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_damage_allocation --only test_attack_plan --only test_allocation_lifecycle --only test_roll_choice_ui --only test_save_outcome_ui --only test_attack_plan_network --only test_damage_allocation_network --network --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_damage_allocation_network --network --timeout 150
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_models --only test_match_save --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_match_save --only test_gameplay_layout --only test_allocation_lifecycle --only test_configuration_screen_parity --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decision_camera --only test_match_hud_shell --only test_allocation_lifecycle --only test_gameplay_layout --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_current_reference_match_network --network --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gameplay_layout --only test_match_hud_shell --only test_match_launch_workflow --only test_automatic_model_preparation --only test_tactical_training --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decision_camera --only test_gameplay_layout --only test_allocation_lifecycle --only test_tactical_training --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_match_hud_shell --only test_gameplay_layout --only test_decision_camera --only test_guided_turn_ui --only test_damage_rerolls --only test_incursion_battlefield --only test_allocation_lifecycle --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gameplay_layout --only test_allocation_lifecycle --only test_configuration_screen_parity --only test_match_save --only test_tactical_training --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_match_journal --only test_roll_choice_ui --only test_allocation_lifecycle --timeout 180
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_session_recovery_network --network --timeout 240
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gameplay_layout --only test_allocation_lifecycle --only test_save_outcome_ui --only test_combat_results_ui --only test_match_command_service --timeout 180
.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_local_handoff_ui.gd
.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_match_result_panel_ui.gd
```

- `.tools/verification/20261111T125107837949Z/results.json` recorded 7/7
  processes for layout, allocation lifecycle, HUD shell, combat results and
  save-outcome UI on the current tree.
- Headless `tests/test_local_handoff_ui.gd` and
  `tests/test_match_result_panel_ui.gd` each reported 0 failures on
  11 November 2026.
- `.tools/verification/20261107T040334432198Z/results.json` recorded 15/15
  processes. `test_tactical_guides` printed an ObjectDB shutdown warning.
- `.tools/verification/20261107T040334403416Z/results.json` recorded 8/8
  processes, including paired loopback host/client tests for movement and ranged
  and melee attack plans. The initial run lacked the staged legacy starter.
  With the fixture present, the two client expectations still used raw model IDs
  in the summary. The final run checks the visible roster name.
- `.tools/verification/20261107T034408543996Z/results.json` recorded 14/14
  processes, including settings/remapping, camera, Core Reactions and the
  five-round tactical combat workflow.
- `.tools/verification/20261107T040755286121Z/results.json` recorded 6/6
  processes for local model import, army-model association, camera and settings
  parity. The model suites use isolated import and fallback fixtures.
- `.tools/verification/20261107T041321690027Z/results.json` recorded 11/15
  processes after the legacy ranged batch correction. All five local suites
  and both attack-plan loopback variants passed. The four old allocation
  loopback processes failed when the fixture submitted confirmations without
  the authoritative decision and option IDs.
- `.tools/verification/20261107T041619326350Z/results.json` recorded 6/6
  processes after the allocation loopback fixture used the actual confirmation
  button. Both ranged and melee scenarios reconnect the defending guest between
  wounds, reject stale or ineligible choices and finish the pending attack.
- `.tools/verification/20261107T041815036240Z/results.json` recorded 4/4
  processes. A version-1 fixture checkpoint reopened with its mapped model, then
  reopened with a placeholder when the local mesh was absent and the parsed mesh
  cache was cleared to simulate restart. Both loads matched the same game state.
- `.tools/verification/20261107T042730903013Z/results.json` recorded 6/6
  processes after the title recovery change. The save suite checks that a
  successful write creates a local marker, the running process suppresses it
  as an interruption, and a clean scene exit removes it.
- `.tools/verification/20261107T043614422848Z/results.json` recorded 6/6
  processes covering the camera presets, HUD, layout and allocation.
- `.tools/verification/20261107T043718099989Z/results.json` recorded 6/6
  processes for the full current-reference and tactical loopback scenarios.
  Both pairs rejoined during deployment and pending Fire Overwatch, preserved
  the checkpoint, rejected stale decisions and agreed on the canonical final
  match digest. Both clients reported headless shutdown cleanup diagnostics.
  The earlier current-reference run at
  `.tools/verification/20261023T225711261053Z/` already reported client
  ObjectDB and canvas leaks. The current orphan probe
  (`network-orphan-client.log`) found one unnamed, detached Label after
  teardown. Its creator remains unidentified.
  The first run at `.tools/verification/20261107T043052287186Z/results.json`
  read an obsolete fixture save path. The test now reads the active slot and
  requires an isolated host profile with empty save slots.
- `baseline-layout-{deployment,command,movement}-1600.png` and
  `current-layout-{deployment,command,movement}-1600.png` use the same script,
  fixed camera zoom, roster fixture and 1600×900 window. The baseline runs from a
  separate project seeded with the preserved source. Allocation has additional
  1920×1080 and 1280×720 before/after captures.
- `baseline-required-doctrine-1920.png` and
  `current-required-doctrine-1920.png` compare the required doctrine selection
  before commit. The native fixture checks that choosing the draft option
  preserves state, phase advancement stays blocked and confirmation commits
  exactly once.
- `capture_flow.log` covers current-catalog preparation, Fire Overwatch,
  Armour of Contempt before dice and its 1 CP cost, plus a synthetic declaration
  through failed save, allocation, recorded result and Charge. The corresponding
  `current-*.png` images are actual Godot renders. Imported models are optional
  and the fixture uses built-in markers.
- `capture_placement_after.log` records a rejected 30-inch move with 6 inches
  remaining. The command rail explained the rejection and kept confirmation
  inside the window. The state digest stayed equal. Floor and panel changes
  preserved the move draft. See `current-move-{pending,floor,rejected}-1600.png`.
- `capture_qa.log` records allocation at 1280×720, 1600×900, 1920×1080
  and 2560×1440 at 100%, 110% and 120%. The confirm button and dice viewport
  fit and their surfaces did not intersect. A native synthetic Gamepad A event
  opened Tools. The earlier 1024×768 capture covers 120%.
- `verify_native_workflow_layout.log` recorded 120 geometry checks across ten
  preparation, inspection, declaration, reaction and resolution checkpoints at
  those four resolutions and three scales. Visible footer controls and dice
  docks stayed in the viewport. The dock and action rail did not intersect.
  Every resize preserved the exact match state.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_final_layout.gd`
  adds 2560×1080 and checks the HUD and actual window size alongside the footer
  and dock. The initial extended run reproduced an allocation resize where
  the 1280×720 action rail stayed tall after wrapped content shrank. The
  confirmation was below the viewport. The command panel now reapplies its
  height when the content minimum changes. The rerun passed 150/150 cases
  across ten checkpoints, five window sizes and three scales. See
  `verify_native_final_layout-repro.log`, `verify_native_final_layout.log`,
  `qa-footer-outside.png` and `qa-footer-refit-1280.png` for the same
  pending allocation before and after, plus `current-overwatch-ultrawide.png`
  and `current-allocation-ultrawide.png`.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_tools_cleanup.gd`
  opened Tools via Enter, activated both camera presets and compared the exact
  pending move before and after. The before and after menu captures have
  identical pixels within the menu crop. Changing the scale from 120% to 100%
  restored the full phase caption with the same match state.
- The first guided UI check assumed tactical launch finished synchronously.
  The fixture now uses the same controlled preparation and fallback path as
  the other tactical tests. Its optional Homer scenario uses built-in
  miniatures. The corrected guided suite passed in
  `.tools/verification/20261107T111036912664Z/results.json`.
- `.tools/verification/20261107T111341402479Z/results.json` recorded 9/9
  processes after the action rail fix. The layout regression also forces a
  temporary oversized content minimum and checks that the rail refits when
  that minimum clears.
- `verify_native_allocation_input.log` exercised the graphical viewport with
  a mouse double-click across frames, Enter key echoes, and synthetic Gamepad
  Cancel and Accept. Each confirmation applied one wound and advanced one
  revision. Gamepad Cancel closed the datasheet and restored confirm focus
  before any allocation was applied. These are engine-dispatched events.
- `.tools/verification/20261107T111737418678Z/results.json` reproduced two
  local handoff failures. A menu round trip repeated the already acknowledged
  Player 2 prompt and skipped an unacknowledged Player 1 prompt. The match now
  records the acknowledged seat only on confirmation and keeps that seat
  across the menu round trip. New matches and loaded saves start with the
  existing Player 1 seat default.
- `.tools/verification/20261107T111905445246Z/results.json` recorded 7/7
  processes after the handoff fix, covering layout, allocation, configuration
  and remapping, saves and tactical training.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_battle_trace.gd`
  runs a deterministic attack through Player 2's paid save re-roll and four
  damage allocations. The Battle Log lists the re-roll and the completed
  attack in order. The final rows identify both recipients and the recorded
  damage per packet. The fixture checks exact match, RNG and journal
  preservation while reading the log. See `battle-log-save-reroll-1280.png`
  and `battle-log-allocation-1280.png`.
- The history renderer also stopped creating a detached empty Label for
  event cards with a title alone. The journal suite checks for newly orphaned
  nodes when switching records and verifies the projected details against
  the original journal digest.
- `.tools/verification/20261107T112548630162Z/results.json` recorded 5/5
  processes for journal recovery and compaction, roll choices and allocation.
- The current-reference and tactical host/client pairs passed in
  `.tools/verification/20261107T112639999652Z/results.json`, with matching
  canonical state hashes for both pairs. Those four processes produced clean
  shutdown logs. The combined run also recorded a separate restart fixture
  failure from missing legacy starter data. The verifier now stages that
  local dependency for the restart suite, and the replacement host reads
  the slot recorded by the original host.
- `.tools/verification/20261107T113155151879Z/results.json` recorded 4/4
  processes for the standalone restart suite. The fresh host restored its
  slot and journal. The client exercised missing and forged credentials
  before recovering the authorized seat, receiving its public history page
  and resuming deployment. The test allows up to 90 seconds for the
  authorized guest while the client recreates its scene between attempts.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_handoff_controls.gd`
  exercised both menu round trips, focus confinement and stale Enter echoes
  using the graphical viewport. It also rebound Inspect from I to K through
  Settings, opened the datasheet with the new binding, and restored the
  movement confirmation focus via simulated Cancel. The draft and exact match
  state survived these interactions. The privacy capture is
  `handoff-restored-player-1-1280.png`. The gamepad events were simulated.
- `verify_native_camera_presets.log` exercised the Tools menu at 1600×900 in a
  pending move. Board overview and Active action changed the camera while
  preserving the exact draft, state and selection. The camera suite checks the
  projected board corners and both player-side presets. Attack declarations and
  a selected Fire Overwatch option contribute their existing board subjects.
  `verify_native_reaction_camera.log` verifies both reaction subjects and the
  unchanged pending states in the graphical run.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_asset_warning.gd`
  exercises cancellation of a controlled local miniature batch with a move
  pending. At 120% UI scale, the notice stays clear of the action rail at
  1280×720 and 1024×768. The pending state, selection, action rail geometry and
  focus stay intact. After three seconds the notice disappears and the Tools
  marker remains. Keyboard navigation reaches the cancellation details, and
  successful preparation clears the marker. The native captures use
  `asset-warning-*.png`. Gameplay events remain in the separate history view.
- `.tools/verification/20261107T105159166824Z/results.json` recorded 7/7
  processes covering the HUD, match launch, miniature preparation and tactical
  training. The layout suite also checks the incomplete-preparation notice.
- `python .tools/in-match-redesign-20261106/run_native.py capture_annotation_tiers.gd`
  compares the same 1920×1080 synthetic roster, camera and selected model at
  zoom distances 16, 27 and 48. The visible health-tag counts changed from
  15/15/2 to 9/1/0. A synthetic display overlap preserved the selected label.
  An actual shooting draft showed the target name above the target model
  after the label shifted clear of the selection. Hovering with the native
  pointer showed the opposing squad name at medium zoom. The checks compare
  the complete match state before and after the presentation changes.
- `.tools/verification/20261107T110131805037Z/results.json` recorded 6/6
  processes covering camera control, match layout, allocation and tactical
  training with the three annotation levels.
- `python .tools/in-match-redesign-20261106/run_native.py verify_native_annotation_allocation.gd`
  checks a pending failed save at 1280×720 and 120% UI scale. Both eligible
  bases remain marked, one text cue fits in the projected area, and unrelated
  model labels are hidden. The selected recipient and pending state are
  preserved. See `annotations-allocation-1280.png`.
- `run_continue.py` interrupted the Godot writer after the production save-slot
  write in the allocation practice fixture. The restarted graphical process
  activated the title Continue button. `continue-reader.log` confirms exact
  snapshot and RNG, unchanged separate manual save and visible recipient
  controls. `continued-allocation-1920.png` records the recovered screen.
- `python .tools/in-match-redesign-20261106/run_recovery_ui.py` runs the dedicated
  title recovery flow in isolated profiles. A second instance sees the normal
  title while the writer is alive. After interruption the title offers the
  exact checkpoint. With a corrupted test primary, it offers the earlier backup
  and gives the rollback in saved revisions. A normal exit clears the notice.
  Dismissing the notice keeps the saved slot byte-identical and leaves normal
  Continue available.
  The normal and recovery title captures use the same saved fixture.
  `recovery-ui-exact-1920.png` shows the recovery action at 1920×1080.
  `recovery-ui-rollback-1280.png` shows the rollback layout at 1280×720 with
  120% UI scale.

### Regression matrix

| Plan cases | Exercised scope |
|---|---|
| T01–T05 | Both Warlord and preparation flows in tactical training, native preparation and handoff, read-only datasheet during a pending choice, optional source status in the full profile. |
| T06–T08 | Prepared-match preview, authoritative rejection and coherency, then legal confirmation and next deployment owner. Native preview and committed positions use the same placement fixture. |
| T09–T10 | Tactical doctrine, Captain ability and optional stratagem choices through the existing authority. |
| T11–T15 | Normal move draft, rejected placement, native floor selection, camera/panel stability, confirm/cancel in local and loopback checks, and P2 Fire Overwatch during the P1 turn. |
| T16–T17 | Local and loopback attack-plan validation. Native declaration and defender choice exercise the pending window before dice. |
| T18–T22 | Recorded die faces, keep/re-roll costs and resolution, read-only replay, and successful saves in the roll, tray and save-outcome suites. |
| T23–T28 | Synthetic recipient preview, wounded priority, destruction and sequential allocation with same-cycle repeat protection. The allocation lifecycle suite also closes the datasheet and checks exact pending state, selection and focus. The fixed-A legacy regression and native input checks cover the original allocation boundaries. |
| T29–T30 | Exact pending slot and RNG after process interruption, plus independent manual-file preservation. Native panel toggling preserves a partial move and manual camera. |
| T31–T33 | 150 native workflow geometry checks across five resolutions and three scales. The viewport accepted one allocation each through mouse, keyboard and simulated gamepad. Native handoff and an applied datasheet remap preserved focus and the pending action. Physical controller coverage is pending. |
| T34–T36 | Tactical five-round scoring, native P2 CP spending and Shooting-to-Charge progression, plus old slot, backup and draft recovery. The same version-1 checkpoint reopens with a local miniature and with its placeholder. |

### Render sampling

The native OpenGL Compatibility sample on the local Radeon RX 6750 XT averaged
90 drawn frames per condition. At a zoom distance of 50, the old annotation
toggle changed total draws from 208 to 268 for 15 health tags. The new same-run
toggle changed draws from 216 to 218 with one selected health tag. At zoom 18 all
15 tags were visible. The scene uses the existing label and base assets. The
comparison measures annotation draw calls. Frame time varied between runs with
other verification processes open. The project exposes no Low, Medium or High
graphics presets to compare.

The later 15-model, 1920×1080 annotation fixture sampled 60 frames per tier.
At zoom 16/27/48, total mean draw calls were 195/159/159 and mean CPU time
for the projected label layout was 0.203/0.092/0.116 ms. The totals compare
the current scene across camera positions. Geometry visible in those views
also varies.

## 11 November 2026 — Imperial Dataslate plan follow-up audit

The supplied `open_tabletop_imperial_dataslate_ui_agent_plan.md` overlaps the
completed match-shell, decision, allocation, army-list and combat-presentation
work above. The Mission screen is a remaining concrete gap: `main.gd`
`_build_mission_overview()` still creates one `RichTextLabel`, and
`_mission_overview_copy()` flattens the score, objective state and history into
one long text block. `_refresh()` already refreshes it while the Mission screen
is open.

The match model remains authoritative. `objectives.gd` and `chapter_approved.gd`
create objective `bounds`; `resolve_control()` writes `controller` and `levels`
at the existing phase boundary. The UI will display those stored values as the
latest resolved control result and will not recompute OC or score. The main
controller already owns read-only camera focus through `_camera_board_area()`,
`DecisionCamera.plan_points()` and `_apply_camera_plan()`, so objective focus
can remain a camera-only callback. The compatible migration is a small
`scripts/ui/mission_overview.gd` view that renders a read-only presentation
model from `main.gd`, with score cards, objective cards, timing guidance and
recent scoring events. It will preserve the current refresh behavior and avoid
changing mission state, scoring or phase progression.

Existing match captures and the earlier crash regression remain useful
baselines, but they predate the latest Dataslate commit. This follow-up adds a
Mission UI regression and fresh native captures at the planned viewport sizes.
Other hardware-dependent gates remain open as recorded above.

### Outcome

`scripts/ui/mission_overview.gd` now renders the Mission screen as a structured,
scrollable view. It presents both players' saved totals and primary/secondary
breakdowns, objective cards with the latest stored controller and OC levels,
optional camera focus, scoring timing guidance and up to five recent scoring
events. The view model reads the existing match snapshot; it does not calculate
control or award points. Objective focus closes the overlay and uses the
existing camera planner without issuing a match command.

`tests/test_mission_overview_ui.gd` checks the objective-training and official
mission presentation, score components, stored control, history, empty states,
camera focus and that opening/focusing the dashboard leaves match state
unchanged. Native captures were produced by Godot for 1280×720, 1600×900 and
1920×1080 using the objective-training fixture. The PNGs are under the ignored
`.tools/ui-refactor-20261111/` directory; the capture shows the initial viewport
and the remaining objective cards are reached by scrolling. The native capture
process exited 0, with renderer shutdown leak diagnostics in its log.

The targeted verification run passed import, Python checks and all eight
selected UI regressions: `test_mission_overview_ui`, `test_gameplay_layout`,
`test_combat_tray`, `test_decision_ui`, `test_allocation_lifecycle`,
`test_combat_results_ui`, `test_army_draft_navigation` and
`test_match_hud_shell` (10 processes; PASS). Its report is
`.tools/verification/20261111T203717135673Z/results.json`. A separate
`test_chapter_approved` run during this work failed its mission/layout identity
assertion before creating the UI scene. That domain assertion is outside this
presentation change and remains a separate issue. No rules, scoring,
capability or network claims changed here.

## 11 November 2026 — Preparation progress and army setup follow-up

The preparation entry point needs visible progress before Tactical Training
opens, while the in-match setup panel needs to explain which required declarations
still block finishing. Asset readiness and rules readiness remain separate: the
asset bar reads default miniature and selected appearance completion counts from
the existing importer; the in-match meter reads the existing finish validator.
Neither meter creates or changes game rules state.

### Outcome

The title menu and saved-army setup now show a determinate miniature-preparation
bar with live ready/total counts. It stays indeterminate only while source counts
are being initialized, reports partial readiness when local visuals are missing,
and clears on cancel, failed start or match launch. Selected appearance completions
now publish status as each item finishes. External cancellation also restores the
start-with-available-models path instead of leaving the preflight pending.

Army Preparation now has a concise owner label, a readiness status and a thin
ready/pending meter driven by the existing finish command validation. The required
reason appears without a duplicated prefix; optional equipment remains explicitly
optional. The pinned Warlord prompt uses its player-facing picker label instead of
the internal model ID. Main-menu actions are 48 px high, and in-match primary
preparation actions use a 44 px minimum target to reduce visual bulk while keeping
the primary controls easy to click. In Army Preparation the confirmation stays
beside its choice in the command panel; the fixed footer is hidden for that state,
so it no longer duplicates the action or leaves a detached button at the bottom.
The preparation rail is narrower and shorter, grows when equipment details are
opened, and suppresses the repeated instruction in the top HUD. The roster starts
collapsed in this state and remains available through Tools → Army. The board
auto-fits to the unobstructed area while camera control remains automatic; manual
camera input keeps the player's framing. This leaves one action rail beside the
board instead of two side panels covering it.

Native Godot captures are under the ignored
`.tools/in-match-redesign-20261106/` directory:
`preparation-progress-menu-1280.png` uses controlled sample counts (37/161), and
`army-preparation-followup-1280x800.png` and
`army-preparation-followup-1600x900.png` use a controlled pending-declaration
state.
The menu uses controlled sample counts, and the match capture uses the local
tactical-training composition with no Warlord chosen. They document layout and
wording, not a live importer run or rules/roster certification. The capture
process exited 0; renderer shutdown reported the same
resource-leak diagnostics observed in prior native captures. No rules, catalog,
admission, scoring or network scope changed. This follow-up did not run the test
suite.

## 12 November 2026 — Army preparation and match HUD hierarchy

Review of the preparation panel showed its compact selectors clipping long
Captain and Sergeant labels, equipment choices blending into surrounding
instructions, and the Tools menu presenting as unframed text between two
buttons. The turn rail also read as a single line of labels. This is a
presentation-only pass; the existing preparation validator and available
choices remain authoritative.

### Outcome

The command rail now scales with viewport width and uses the available height
when optional equipment is expanded; the separate pre-match sidebar also stays
inside the viewport. Required declarations, optional equipment and the final
finish action now have explicit separators. Optional loadouts sit in bordered
cards with a model/slot heading, current equipment, a concise option label and a
full-width Apply change action. Full choice descriptions remain available as
tooltips. The closed preparation view keeps Finish army visible.

Turn ownership and each battle phase now use distinct bordered chips, with
separators between phase, utility and decision rows. Hide, Tools and Menu share
the same framed button styling and measured width. No rules, choices, scoring,
capability or network scope changed.

Native Godot captures are under the ignored
`.tools/ui-refactor-20261112/` directory. `preparation-required-1280x800.png`
shows the pending Warlord state; `preparation-optional-1280x800.png`,
`preparation-optional-1600x900.png` and
`preparation-optional-960x640.png` show optional equipment expanded. The
fixture uses the local tactical-training composition and does not certify
roster legality or datasheet coverage. The capture process exited 0; Godot
printed renderer-resource leak diagnostics during shutdown. The Godot 4.7.2
editor import also exited 0. The test suite was not run.

## 12 November 2026 — Compact preparation completion

The title menu kept its continue action in a second column that was clipped at
narrow window widths. Partial asset readiness also left the workflow bar below
100% after the preparation queue had already ended.

### Outcome

Below 1000 px, the title screen now uses a single-column layout with saved
matches, training, new match and settings actions beside the preparation status.
After partial preparation, the continue-with-available-models action also appears
beside the status on wide screens, so the next step remains visible with the
readiness summary.
The completion bar represents the finished preparation queue, while the label
continues to report which unit defaults and appearance variants are available.
When defaults are ready but some variants are missing, the status names those
variants and confirms that unit defaults remain usable. No rules or admission
scope changed.

The continue action receives primary emphasis during this state. Compact mode
uses larger text and keeps saved matches, training, new match and settings in one
column. Captures in `.tools/title-partial-1280x800.png` and
`.tools/title-partial-536x690.png` use a Godot fixture with staged counts (6/6
unit defaults and 42/46 appearance variants); they demonstrate the UI state and
do not perform or certify model downloads. Godot exited 0; its shutdown printed
renderer-resource leak diagnostics from the capture fixture.

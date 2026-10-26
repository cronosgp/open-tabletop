# Tactical training experience correction progress

**Battle-shock on the model — 26 October 2026:** a living model whose unit is Battle-shocked now reads Shocked above it. The word stays visible when the wound overlay is hidden, and it does not replace the selected model's OC and Moved lines. It reads the existing unit state and does not apply or remove Battle-shock. No tests or Godot session were run.

**Eligible recipient word — 26 October 2026:** a model that can receive the current allocation keeps its green ring and now also reads Eligible above that ring. The word hides with the ring. It does not select the model or change who is eligible. No tests or Godot session were run.

**Miss and failed wound on the tray — 26 October 2026:** a recorded missed hit now says Miss on its face, and a recorded failed wound says Failed. Both keep the existing number, cross and color. A failed save keeps its red border and the word Failed, so the save remains the distinct face. The words read the stored outcome and do not roll or change that outcome. No tests or Godot session were run.

**Narrow command dock — 26 October 2026:** below a 1280-pixel-wide window, the command panel sits across the bottom, directly above the combat tray, instead of taking a full-height column from the board. The army list stops above that dock. At 1280 and wider, the command panel stays on the right. The camera's clear board area treats a docked panel as a bottom edge. No control moved into a different command, and no rule changed. No tests or Godot session were run. Fit at 1024×768 and 1280×800 remains pending review.

**Current step is labeled — 26 October 2026:** the movement and charge/fight progress strips mark the current step with the word Now, not only with gold. Completed steps keep the check, and later steps keep their numbers. The strips still do not choose a move or start a charge. No tests or Godot session were run.

**Last-attack summary — 26 October 2026:** the compact last-attack line now says `destroyed` instead of `models out`. When the recorded attack generated Hazardous wounds, that loss and the prevented count stay on the visible summary. The longer text remains in the tooltip. The summary does not change the recorded result. No tests or Godot session were run.

**Long dice list — 26 October 2026:** attack details still show at most 72 faces. When the recorded result has more, the list now says how many are shown and how many remain in the combat tray. Faces are not dropped from the result, and no new roll is made. No tests or Godot session were run.

**Decision owner stays on the banner — 26 October 2026:** the allocation steps, the reroll window, and the unit-choice line no longer repeat which player decides. The visible allocation line keeps the stage and the action. A reroll window keeps the CP count. A unit choice keeps the selected label. While allocation belongs to the other player, the group says Waiting. The banner and the round chip still name the owner. Help text that already copied the longer explanation is unchanged. No command or owner check changed. No tests or Godot session were run.

**Settled saves and replay note — 26 October 2026:** when a settled Saves mark includes a recorded failure, the caption leads with the failed count and uses the same red as the failed face. A pass-only save mark stays in the normal color. Under the tray controls, a line states that replay shows the saved faces and does not roll again. The button label is unchanged. Neither change rolls dice or submits a command. No tests or Godot session were run.

**Failed-save hold in the reveal — 26 October 2026:** after a Saves stage reveals at least one recorded failure, the tray waits longer before the next stage. Fast mode keeps the same proportion, and reduced motion still skips the sequence. The extra wait does not roll, allocate, or change the recorded failure. No tests or Godot session were run.

**Wound change on the model — 26 October 2026:** a wound change above a miniature now shows the previous and current wounds, such as `3 → 1`. Destruction shows `2 → 0 · Destroyed` and holds for half a second before the existing rise and fade. Healing uses the same before-and-after form. The label still appears only while board motion is on, and it does not change wounds or remove the model. No tests or Godot session were run.

**Guide cap and allocation consequence — 26 October 2026:** the guided instruction now shows at most four lines. The full instruction and boundary stay in its tooltip, and the optional experiments remain behind Show help. The selected damage-recipient card repeats the existing wound preview, including when Feel No Pain or an unknown roll means the result is not settled. Other eligible cards keep their current wounds. The card does not allocate damage or change prevention. No tests or Godot session were run. Guide fit at 1024×768 remains pending review.

**Dice record collapsed — 26 October 2026:** opening attack details now shows the recorded faces and the note that they are not a new roll. The entry number and chain text stay behind Show dice record. The board-motion tooltip now matches the attack link: gold for a pending weapon and target, warm when damage was applied, cool when none was. Neither change rolls dice or edits the journal. No tests or Godot session were run.

**Attack link — 26 October 2026:** while an attack is pending, the board draws a line from the attacking unit to its target and labels the recorded weapon and target. It does not show dice or damage. When the recorded result replaces that attack, the line and ring use a warm color with the applied damage, or a cool color with No damage. The link still appears only while board motion is on, and it stays hidden during a pending Hazardous allocation. It reads existing attack fields and does not choose a target or resolve the attack. No tests or Godot session were run. Label overlap on a crowded table remains pending review.

**Primary action first — 26 October 2026:** each visible command group now places its first enabled button directly under the group heading. Checkboxes and dropdowns stay where they configure that action. If every button is disabled, the first visible button still leads and its existing block sentence sits immediately underneath. Keep result therefore leads a reroll window when it can be used. The reorder does not enable a control, spend CP, or submit a command. No tests or Godot session were run. Keyboard focus after the move remains pending review.

**Failed-save hold — 26 October 2026:** a recorded failed save now reads differently from a missed hit. In the combat tray the face keeps its number, cross and pips, and adds the word Failed on a red border. In the attack-detail tiles the same face is labeled FAILED SAVE. Passed saves, hits, wounds and Feel No Pain keep their existing marks. The change reads the stored save outcome and does not roll, allocate or change whether the save failed. No tests or Godot session were run. Tile fit beside a full dice pool remains pending review.

**Visual gameplay review — 26 October 2026:** a source reading of the tactical-training flow found the same round and decision owner repeated on the HUD, the decision banner and the combat tray, while charge, Fight and objective failures often stayed on a tooltip. Selected miniatures did not show the army-list ordinal, and combat feedback was one synthesized beep plus a line. This pass stays in presentation. The tray heading is now only the obligation (`Optional`, `Required`, or `Recorded result`); weapon and target stay on the context line, and the full round sentence remains on the banner. Charge targets that share an existing rejection are listed once under those controls. Fight and objective block sentences use the same reason label, placed under those controls. The selected miniature shows its roster ordinal, such as `Model 3` or `Model 3 · Sergeant`, while it stays selected. A short confirm tick plays when a dice reveal finishes, and a lower tone plays when a model is destroyed or Hazardous wounds are newly generated. Both use a local SFX bus and stay silent when combat sound is off or the tray is set to reduced motion. No hit-stop, camera shake, dice roll, validator or phase change was added. No tests or Godot session were run. Fit at 1024×768 and 1280×800, focus order and the two tones remain pending a live pass.

**Movement unavailability — 26 October 2026:** a movement type that cannot be chosen now lists its existing reason under the choices, grouped when several types share the same reason. The button tooltip and the movement reference still carry the explanation. The list does not add or remove a legal move.

**Decision banner split — 26 October 2026:** the command banner now puts round, phase, turn owner and decision owner on the first line, and the current action on the following lines. A connected player who is waiting sees that prefix before the same facts. The full text stays in the tooltip, and the banner shows at most four lines. This reads the existing actor and phase; it does not change who may act.

**HUD decision owner — 26 October 2026:** when the player who must decide is not the player whose turn is active, the round label shows both, for example `R2 P1 · P2 decides`. Setup uses the same distinction. When they are the same player, the label stays `R2 P1`. The tooltip always states the round, the turn owner and the decision owner. This reads the players already passed to the HUD and does not change who may act.

**Battle-log scanning — 26 October 2026:** each history row now leads with the first recorded event, or the attack's weapon and target, instead of only the round, player, phase and dice count. The tooltip keeps the full messages. Inside a non-attack record, the round and phase appear once, and each event card leads with its opening sentence. The full message stays on the card when it is longer than that sentence. The technical record is unchanged. This reads the existing journal page and does not rewrite history.

**Combat timing line — 26 October 2026:** the combat tray now pins round, phase, active player and decision owner above the result. A pending re-roll is labeled Optional and names the roll's owner. Precision is labeled Optional and names the attacking player. Defense-group order and damage allocation are labeled Required and name the target unit's owner. Other attack windows in progress are labeled Required. A finished attack is labeled Recorded result and names no decision owner. The line reads existing match state and does not change who may act.

**Settled combat stage marks — 26 October 2026:** after recorded dice finish revealing, the combat tray keeps a Hits, Wounds, Saves and Damage mark for each stage present in that result. Each mark keeps its name, threshold or before-prevention note, and success or applied-damage count. The strip stays hidden while the reveal is still playing, and it does not roll dice or resolve a decision.

**Blocked placement footprint — 26 October 2026:** a rejected destination now uses an original blocked-footprint mark on the board and beside the command-card reason. The card still states the heading, validator reason and recovery step. The mark does not accept a move or change validation. No tests or Godot session were run. Marker fit, off-screen clamping and command-card wrapping remain pending review.

**Allocation wound marks — 26 October 2026:** eligible recipient cards now show a segmented remaining-wound mark beside the existing role and `current/maximum` text. Up to six segments match the wound count exactly; higher totals use a proportional mark and say so in the tooltip. A settled combat-tray result shows a crossed-miniature mark only when the recorded attack destroyed one or more models, and hides that mark while dice are still revealing. Neither mark selects a recipient, changes eligibility or alters the recorded result. No tests or Godot session were run. Card fit, keyboard focus and the hidden-during-reveal behavior remain pending review.

**Actionable reference-integrity errors — 26 October 2026:** when a listed file in the optional Wahapedia snapshot is missing or fails its SHA-256 check, the inspector's error now names that file. This tells the player which part of the local installation needs replacement while preserving the existing all-or-nothing failure behavior. No tests, Godot interaction or capture were run because testing is unavailable; packaged-source and rendered error states remain pending review.

**Overlay focus fallback — 26 October 2026:** closing a tactical screen now always runs the shared focus-restoration path, even when the screen was opened from the board with no GUI control focused. The recovery logic restores the original visible control when possible; otherwise it chooses the title action, first available Command control, first Army control, or the persistent HUD Menu button. This keeps keyboard and gamepad navigation from ending on an unfocused screen when the panels are closed; it does not change match state. No tests, Godot interaction or capture were run because testing is unavailable; datasheet close behavior and fallback focus still need focused review.

**Manual source-folder recovery — 26 October 2026:** if the operating system cannot open the optional reference folder, the datasheet inspector now reveals **Copy local reference folder path**. The player can paste the Godot user-data location into a file manager and install the verified snapshot manually, then use the existing reload action without restarting. The copy action stays hidden unless folder creation or opening fails. It copies only the local path and does not read or alter match state or clipboard contents until selected. No tests, Godot session or capture were run; keyboard focus, clipboard behavior and packaged-build folder handling remain pending review.

**Compact combat result summary — 26 October 2026:** the combat tray's headline now uses at most four wrapped lines and shows its full text in the tooltip. A completed result lists saves first, then damage and casualties, followed by Hazardous losses on a separate line; the detailed result stages retain their per-die records. During a reveal animation, the tooltip now matches the neutral “Recorded dice · presentation only” label and does not retain an older outcome. No tests, Godot session or capture were run; line fit, tooltip access and result ordering remain pending visual and interaction review.

**Pending owner in saved-slot summary — 26 October 2026:** new saves now record the priority player returned by the match's central resolver, and the slot browser distinguishes that owner from the active turn player. A save awaiting Player 2 during Player 1's turn is summarized as “Player 1's turn · Player 2 decides,” including recoverable backups; each slot's tooltip retains the full summary if its picker label is truncated. Older saves remain readable and continue to show the active turn player. The metadata does not change match state or save version. No tests or Godot interaction were run; slot-list fit, phase edge cases and restored decision continuity remain pending review.

**Board-input isolation during overlays — 26 October 2026:** static inspection found that WASD camera panning continued in `_process` while the tactical overlay was open, and unhandled key input could still trigger F to frame the selected model behind it. Camera panning now pauses while the local handoff or a tactical screen is open; unhandled input is consumed by a tactical overlay after Escape/Cancel gets its close action. The in-game Field Guide and UI guide state this boundary. This is a local presentation/input change and does not affect match state. No tests or Godot interaction were run because testing is unavailable; overlay focus, Escape/Cancel, camera input after close and mouse/gamepad behavior remain pending focused review.

**Non-finite save data rejection — 26 October 2026:** static review found `MatchSave.safe()` allowed `NaN`/infinite floating-point values as scalars and inside vector, rectangle, color or packed-float data. Save payload validation now rejects non-finite values in those types before serialization; integer, string, Boolean and byte/integer packed data keep their existing paths. The persistence guide records this boundary. It does not normalize or repair an invalid value, and it does not change match rules or existing save format. No tests or Godot session were run; rejection, autosave error feedback and valid save/load recovery remain pending focused verification.

**In-session journal tail recovery — 26 October 2026:** if an append left bytes beyond the last journal record committed in memory, a later append now validates that confirmed prefix through the existing restore path, writes it to a temporary file, commits the branch by rename and retries the current record. The interrupted tail remains in the old file; a disk file shorter than the committed prefix still blocks safely. This avoids waiting for a full application restart after a recoverable partial write and does not replay or rerun match actions. No tests or Godot session were run; partial-write recovery, retry behavior, autosave integration, cleanup and slot-copy continuity remain pending focused verification.

**Keyboard datasheet access — 26 October 2026:** the selected-model inspector now opens with the **I** action as well as its existing button. The action is handled only during a match with a selected model, and text-entry, title/menu, handoff and tactical-overlay input retains priority. The shortcut is bound in `project.godot`; gamepad users can still focus the Datasheet button. Opening it remains read-only. No tests or Godot interaction were run; InputMap loading, focus return and keyboard/gamepad behavior remain pending review.

**Named camera controls — 26 October 2026:** the existing **F** focus and **W/A/S/D** pan controls now read named actions from `InputMap`, with their current physical-key defaults in `project.godot`. Pan uses separate horizontal/vertical axes and preserves the prior unnormalized diagonal speed. The modal, handoff and text-entry guards remain in place. No new device binding or remapping UI is claimed. No tests or Godot interaction were run; InputMap startup, directional signs, diagonal motion and focus suppression remain pending review.

Updated 26 October 2026. The earlier tactical candidate passed the scoped local, bounded loopback and PCK checks recorded below. The 25 October source-reference, preference, Field Guide, Mission overview and narrow-HUD layout additions are not included in those runs and remain pending focused local verification. The 26 October datasheet weapon-profile layout also lacks a current Godot capture and visual check. Human acceptance is still open. Tactical-overlay focus and `ui_cancel` behavior also remain pending interaction verification. This report follows the [experience plan](tactical-training-experience-plan.md) and [UX audit](tactical-training-ux-audit.md).

**Expandable contact-placement diagnostics — 26 October 2026:** when final Charge, pile-in or consolidation validation finds more than one affected model, the first existing rejection remains primary, the feedback anchors to that model, and the command card offers the other affected models with their roster labels and specific findings. These diagnostics are collected during the existing per-model validation pass; they do not accept a move or change its state transition. The host-to-guest placement RPC carries the primary error code, recovery instruction and additional findings so the guest receives the same diagnostic information. No tests or Godot interaction were run because testing is unavailable; model identification, panel fit, keyboard operation and live network delivery remain pending verification.

**Placement feedback in narrow board areas — 26 October 2026:** the board-side error card now measures its text against the remaining board width and height, and recomputes its safe area when the inset would consume the whole area. If no readable card fits, it hides that overlay while preserving the full reason and recovery in the command card and attempting to keep the rejected-destination marker visible. This changes presentation only. No tests, Godot session or capture were run because testing is unavailable; narrow-layout fit and marker visibility remain pending review.

**Initial LAN snapshot presentation baseline — 26 October 2026:** the first host snapshot now clears the client's previous position/wound comparison and any in-flight board damage or casualty cues, alongside the existing combat tray and attack-link reset. This prevents state retained from the pre-connection scene from being presented as a new attack or movement. No game state or network payload changed. No tests or LAN session were run; initial host-snapshot behavior remains pending focused verification.

**Combat tray result navigation — 26 October 2026:** selecting a die now keeps its full description instead of stopping after two lines; the text wraps in its own bounded scroll area below the dice list, so a large pool does not hide it at the end of the same scroll. Activating a die moves keyboard focus into the description area, where Up/Down, Page Up/Down, Home or End scroll the full text and Escape returns focus to that die. Switching or replaying a stage starts at the top so its stage selector, heading and first results appear together. The attack summary and presentation controls stay outside that scrolling area. No tests, Godot session or capture were run because testing is unavailable; long-detail fit and focus/scroll behavior remain pending review.

**Datasheet model-switch reading position — 26 October 2026:** when the datasheet inspector stays open and the selected model changes, the new profile now starts at the top. Reloading the same profile's local source reference preserves the current reading position. This changes presentation state only. No tests, Godot interaction or capture were run because testing is unavailable; model-switch and source-reload behavior remain pending focused review.

**Implemented-scope reading order — 26 October 2026:** the match-profile inspector now presents project-authored Implemented Scope before optional Source Rules when scope entries exist. A visible note says source text is informational and does not establish runtime support. No rules, eligibility or match state changed. No tests, Godot interaction or capture were run; section order, long-text fit and the source-absent state remain pending focused review.

**Optional source-reference foldout — 26 October 2026:** verified local ability text now starts collapsed behind a `Show source reference` action, keeping the project-authored scope above it in the first view. Integrity errors and incomplete-export warnings start expanded; reload status also opens the section. The user can toggle the reference per model, while switching profiles resets the choice. No source, rules or match state changed. No tests or Godot capture were run; focus, fit, and all source states remain pending visual/input review.

**Field Guide re-roll explanation — 26 October 2026:** the title-screen guide now explains that Keep result accepts the displayed dice for 0 CP when offered, and that the current re-roll action shows its CP cost and which die or dice it would replace. This adds no decision or eligibility behavior. No tests, Godot interaction or capture were run; title-guide fit and comprehension remain pending review.

**Decision banner end states — 26 October 2026:** the non-match preview and completed-exercise states now replace any tooltip left by the previous decision with matching guidance. This affects hover/focus help only; match state and available actions are unchanged. No Godot interaction or capture was run, so tooltip visibility and the suggested next step remain pending review.

**Mixed snapshot-name validation — 26 October 2026:** the optional ability-reference reader now checks every timestamp-shaped snapshot folder name before choosing how to order candidates. A non-timestamp folder no longer stops validation of later names, so an impossible date cannot slip through in a mixed folder. No tests were run because testing is unavailable; reader behavior remains pending focused verification.

**Re-roll action markers — 26 October 2026:** Command Re-roll and available free Advance or Charge re-roll actions now show an original arrow-and-die vector icon beside their controls; button labels continue to state the action and CP cost. This is presentation only. No tests, Godot interaction, capture or visual review were run; icon fit and legibility remain pending.

**Pre-match training summary density — 26 October 2026:** the title screen gives its action column more width than the title column, uses compact unit counts and raises the summary font to 15 points. The change aims to make both training forces, the practice scope and primary controls easier to scan at 1024×768 and 1280×800. Points, unit names, practice areas, local free-play/no-download status and the legality/balance limitation remain visible. This is presentation only. No tests, Godot capture or visual review were run; wrapping at 1024×768, 1280×800 and 1920×1080 remains pending.

**Title-screen navigation wrapping — 26 October 2026:** the Armies, Models, Tools, Results and Guide links now use a horizontal flow container that wraps when the action column narrows, preserving the button insertion order for keyboard traversal. No tests or Godot interaction were run; row wrapping and directional focus movement still need review at the supported window sizes and larger interface scales.

**Tactical overlay focus recovery — 26 October 2026:** closing an overlay now rejects a stale, hidden or disabled return target, then falls back to the title/menu primary action or the first visible command control. A valid opening control still receives focus. No tests or Godot interaction were run; mouse-open, `ui_cancel`, handoff and overlay-switch sequences still need keyboard/gamepad review.

**Save-slot path guard — 26 October 2026:** journal-directory lookup now rejects slot numbers outside 1–5, matching the save-file path helper instead of constructing `slot-00` or an out-of-range directory. Existing valid slot paths are unchanged. No tests or Godot interaction were run; focused slot and journal checks remain pending.

**Save-browser status separation — 26 October 2026:** the selected slot's empty, readable or damaged-save feedback now has its own status line, separate from the current match's autosave/resumability notice. A match without an active slot can no longer overwrite the selected slot's compatibility or corruption explanation. No tests or Godot interaction were run; wrapped-message fit and keyboard selection remain pending.

**Previous snapshot recovery — 26 October 2026:** before replacing a readable primary snapshot, the save writer preserves it as `<slot>.bak`. Slot discovery treats a backup-only slot as occupied; loading falls back to a readable backup when the primary is missing, corrupted or fails the load-time structural checks for saved configuration types, match-state sections, saved-army setup shape, attack-draft fields/references, pending decisions, required state fields, seat reservations or journal references. The title screen and resume status report when a later structural check selected the backup; the slot browser labels recovery when file-level reading selects it. A primary from a newer game version remains a compatibility blocker rather than silently restoring older state. A recovered backup is kept when the damaged primary is overwritten, so it is not replaced by the unreadable file. Journal cleanup checks primary and backup snapshots and keeps every referenced journal branch. No tests or Godot interaction were run; interrupted-write recovery, repeated autosave backup refresh, journal continuity, compatibility failures and browser layout remain pending focused verification.

**Guided opening visibility — 26 October 2026:** the current-step instruction now stays in the guided match's command panel, and the panel appears only when the guided session is active. Help text, experiments and rule terms are behind a collapsed control, so optional explanation does not lead the opening. No Godot capture, viewport review or interaction check was run; containment, keyboard focus and human acceptance remain open.

**Elevated placement preview — 26 October 2026:** the cursor preview now intersects the same selected height that right-click placement uses during Movement and contact moves. It sends that height to the authoritative validator, includes vertical distance in the displayed movement cost, and previews coherency/engagement with the model at its proposed elevation. The guide line and destination ring follow the selected surface. No tests, Godot capture or visual check was run; elevated-floor fit and feedback remain pending review.

**Structured movement feedback — 26 October 2026 (initial delivery):** normal Movement, contact placement and the clean demo validator now expose a stable validity flag, reason code, player-facing reason and recovery hint. Command execution returns those fields for rejected placements while the existing string-returning APIs keep their reason text. The hover panel categorizes common blocks and shows a recovery step; the action card uses the same information for local rejections. The initial host-to-guest RPC preserved its earlier signature and sent the authoritative reason text; the guest presentation inferred familiar categories and recovery steps from it without affecting validation. The later expandable contact-placement diagnostics entry records the RPC extension for primary error code, recovery text and per-model findings. The network round-trip remains unverified. No tests, Godot capture or human review were run; the movement feedback acceptance gate remains open.

**Movement confirmation feedback — 26 October 2026:** normal and contact move completion now return structured reasons and recovery hints for incomplete squad coherency, engagement and approach requirements, objective range, pending escape-wound allocation and unresolved movement abilities. The command service uses these results, while the existing string-returning combat APIs remain available to older callers. Rejected confirmations feed the same action card and anchor feedback to a model in the active move; at this stage the guest still received only the original RPC reason text and inferred familiar cases locally. The later expandable contact-placement diagnostics entry records the added RPC metadata and per-model findings. This adds no new movement legality. No tests, Godot interaction, network round-trip or human review were run.

**Placement feedback positioning — 26 October 2026:** the anchored error card now follows the selected model at its current elevation as the camera moves. Its layout projects the model's base footprint and tries positions above, below, beside and at the safe board-area corners before using the clamped fallback; the rejected-destination marker remains independent. This is a presentation change only. No tests, Godot capture or viewport review were run, so the no-overlap behavior still needs visual confirmation.

**Combat presentation controls — 26 October 2026:** Skip animation and Replay recorded dice now have tooltips explaining that they finish or replay the presentation without changing the recorded result, rolling again or resolving a pending choice. The underlying actions remain presentation-only. No tests, Godot interaction or human comprehension review were run.

**Combat-stage reveal lock — 26 October 2026:** the result-stage selector is disabled while recorded dice animate, so selecting a later stage cannot reveal it ahead of the presentation sequence. It is enabled again when the sequence settles, including when the player skips; pending decisions remain in the Command panel. This changes only result presentation. No tests, Godot capture or interaction review were run; stage navigation and focus behavior remain pending.

**Battle log event cards — 26 October 2026:** non-attack journal records now display each recorded event message as its own card labeled with the round, phase and active player. Attack-pool outcome cards and the technical record remain available, including full messages, state changes and D6 order. No journal data or reconstruction behavior changes. No tests, Godot capture or human review were run; card scanning and long-message fit remain pending.

**Responsive datasheet weapon profiles — 26 October 2026:** weapon rows now present the profile name above a three-column grid for Range, Attacks, BS/WS, Strength, AP and Damage, followed by keywords. This removes fixed minimum widths that could make the right-side inspector wider than its available area. Long profile names and keyword lines wrap in the existing vertical scroll view. The change alters presentation only and reads the same current match profile. No tests, Godot captures or visual checks were run in this increment; fit at 1024×768, 1280×800 and 1920×1080 remains open for review.

**Distinctive allocation recipients — 26 October 2026:** eligible model cards still show model role and remaining wounds, and now also identify weapon profiles that only one living model in the unit carries. Common weapons stay out of the card; the tooltip lists every distinguishing profile. Choosing a card continues to change only local selection, and the authoritative eligible set still controls what can be confirmed. Equipment labels are projected from the current match's model loadout. No tests, Godot captures or visual checks were run in this increment; card fit and recognition remain open for review.

**Board markers for eligible recipients — 26 October 2026:** the same eligible model list used by allocation cards now drives a green outer-base marker for each visible recipient. Markers appear only during an active Precision, defense-group, damage or Hazardous allocation window and update with the pending choice; they do not determine eligibility or alter the model's existing owner-color material. No tests, Godot captures or visual checks were run in this increment; marker fit, visibility on imported miniatures and board readability remain open for review.

**Datasheet reading position — 26 October 2026:** opening the selected model's inspector resets its vertical and horizontal scroll offsets so a newly opened profile starts at the top after a previous read. Reloading the local ability reference while the inspector stays open continues to preserve the current reading position. This is presentation-only. No tests, Godot captures or visual checks were run; the reopen and refresh interaction remains pending review.

## Findings and changes

**Optional datasheet-reference identity feedback — 25 October 2026:** the verified source index now retains every Space Marines datasheet identity, including the one identity with no ability relation. The inspector can distinguish that valid empty entry from an identity absent from the export. No source content or match behavior changes; focused reader verification remains pending.

**Optional source-reference integrity — 25 October 2026:** ability relations now fail the whole snapshot if they point to a datasheet identity absent from the same export. Previously those rows were skipped along with valid non-Marine rows, which could make a cross-file mismatch look like a complete source. No match rules or state change; focused reader verification remains pending.

**Local preference fallback — 25 October 2026:** startup now accepts only the window modes and resolutions offered in Settings, validates the saved animation-speed index and presentation-options map, and ignores malformed values in favor of current defaults. Unsupported dimensions fall back to the current supported size or 1280×800; an unsupported mode falls back to Windowed. This affects local presentation preferences only. The first Godot capture launch found a GDScript inference error in the saved-toggle local; it now has an explicit `bool` type. Save/load fallback behavior remains pending focused verification.

**Readable interface size — 25 October 2026:** Settings now offers 100%, 110% and 120% local interface scales, applied through the root window's 2D content scale. The selection is included in Apply/Revert and saved under the local display preferences; unsupported or malformed saved values return to 100%. This scales the 2D interface while leaving the 3D tabletop at its current scale. Fit, keyboard/gamepad navigation and save/load behavior remain pending visual and interaction verification.

**Pre-match accessibility settings — 25 October 2026:** the title screen now exposes the same Settings overlay as the in-match menu. Display and interface size can be adjusted before the first match; the settings screen describes the local scope and that an open LAN match continues. Initial focus, overlay focus restoration and pre-match layout remain pending interaction verification.

**Pre-match Field Guide — 25 October 2026:** a title-screen **Guide** entry opens a read-only page for quick start, turn/decision reading, table controls, keyboard/gamepad navigation, local settings and match-state boundaries. It distinguishes optional source ability text from project-authored implemented scope. It reuses the tactical overlay stack and returns focus to the Guide control on close; no game state or save is changed. Title-screen fit, focus return and content review remain pending interaction verification.

**Mission overview — 25 October 2026:** the HUD now exposes a keyboard/gamepad-accessible **Mission** action when objective scoring is active. Its read-only overlay lists current VP, mission scores, each objective's controller, secured owner and latest resolved P1/P2 OC totals; it states that provisional movement is not included. The HUD keeps its compact VP/CP summary, and the detail view refreshes while open as the LAN match advances. Closing it hides the overlay-only content and restores the opener's focus. Fit, refresh, focus and match-state invariance remain pending local verification.

**Narrow HUD score placement — 25 October 2026:** below 1400 pixels wide, the compact VP/CP score now moves into the second toolbar row with connection and local controls, leaving the phase row for round and phase markers. This is layout-only; narrow-window fit remains pending a current runtime capture.

**Recorded mission result detail — 25 October 2026:** the final result record now whitelists primary/secondary totals, each selected secondary's P1/P2 score, up to five recorded score events or objective-training round summaries, and each objective's final controller, secured owner, role and resolved P1/P2 OC. **Result details** and the opt-in clipboard summary present this breakdown; local JSON exports use schema version 3. The recorded winner remains authoritative, and the breakdown does not recompute scoring. The final-result panel and export have not been locally rechecked or captured after this change.

**Result score-event trace — 25 October 2026:** the result summary/export now carries the five newest VP-bearing mission log entries, excluding the mission setup roll-off. The end-battle Battle Ready +10 VP award is now recorded in that mission log so it is visible in the trace. No score values or eligibility changed. The result card/export and updated mission history have not been locally rechecked or captured after this change.

**Mission scoring history — 25 October 2026:** the in-match Mission overview now shows up to five recorded mission scoring events, newest first. It reads the existing mission log and performs no scoring. Local layout and LAN refresh behavior have not been rechecked or captured after this change.

**Objective-training round history — 25 October 2026:** the Mission overview and final result now surface up to five recorded training-round score summaries from the match event journal, newest first. They do not recompute totals; older saves show only summaries present in their event journal. Local layout, result export and restored-save behavior have not been rechecked or captured after this change.

**Saved-result browser — 25 October 2026:** the title screen now opens a read-only browser for explicitly saved local result JSON. It lists supported schema versions 1–3 newest first, checks each filename against its record ID and required summary fields, and verifies schema-3 record contents against their SHA-256 identity. It searches compatible records by scenario, outcome, score, round, mission, scope and unit names, shows the selected result without loading or changing match state, and can copy its summary on request. The browser distinguishes an empty folder, an unreadable folder, a search with no matches and a folder containing only damaged or unsupported JSON; it reports how many incompatible files it filtered when compatible records are also present. Layout, keyboard navigation, historical-file rendering and search behavior have not been locally rechecked or captured after this change.

**Local decision handoff on resume — 26 October 2026:** when the decision owner changes during a local match, a full-screen handoff covers the board and decision controls until the receiving player confirms readiness. The first local state treats Player 1 as the seat that opened the match, so a local match that starts or resumes directly into a Player 2 decision also opens the handoff. The prompt reveals only the player number, traps keyboard focus on its confirmation action and cannot be dismissed with Escape. It now gives a player-specific instruction and a Continue as Player N action; the pending decision remains hidden until confirmation, after which focus returns to the first available command control. LAN waiting behavior is unchanged, and the handoff does not modify match state. No tests or Godot interaction/capture were run for the text change; owner transitions, focus containment, panel fit and input blocking remain pending local verification.

**Local reference folder shortcut — 25 October 2026:** when optional ability text is unavailable, the datasheet inspector explains the expected `user://rules/wahapedia/11e/space-marines/<snapshot-id>/` location and offers **Open local reference folder**. It creates the parent directory if needed, opens it in the operating system's file manager, and reports whether opening succeeded. The player installs a verified snapshot manually; the game still makes no network request. Desktop interaction and exported-pack behavior remain pending verification.

**Reloadable local reference — 25 October 2026:** the datasheet's Source Rules section now keeps **Open local reference folder** and **Reload local reference** available whether source text is missing, valid or invalid. Players can install a first snapshot or pick up an updated user snapshot immediately; external-first integrity validation and explicit errors remain intact. Reload refreshes only the selected datasheet and does not change match state. Source installation and button behavior still need interaction review.

**Tactical overlay keyboard focus — 25 October 2026:** opening an overlay now focuses its first visible, enabled interactive control, falling back to Close when the content has no controls. The semantic `ui_cancel` action closes it before board input is considered. Closing restores the control that opened the overlay when it is still visible; replacing one overlay with another preserves the original return target. Match state is untouched; keyboard/gamepad navigation verification remains pending.

**Field Guide rendered capture — 25 October 2026:** actual Godot 4.7.2/OpenGL captures show the earlier navigation instructions at 1024×768, 1280×800 and 1920×1080. The text fits in the scrollable Help panel at each size, with no visible clipping. Captures are scripted runtime views at `.tools/worklog/help-navigation-20261025/help-navigation-{1024,1280,1920}.png`; the current turn-flow/source text and Mission overview were added after those captures and have no rendered evidence yet. These images do not verify keyboard/gamepad input, focus restoration or human comprehension.

| Reported issue | Finding | Implemented correction |
|---|---|---|
| Missing defender choice | Guided launch explicitly disabled manual allocation. | New tactical training enables the existing defender allocation path. Saved match options are preserved; no allocation timing or eligibility rule was changed. |
| Apparently mandatory Command Re-roll | The Keep button forwarded the selected replacement die. The normalized pass option requires no selected die, so the command was rejected. | Keeping now submits die `-1`; selecting a replacement die is reserved for re-rolls. Keep is visible before the die picker, has keyboard focus on entry and states its zero CP cost. The tactical lifecycle regression now presses the actual Keep button. |
| Hidden optional ability pass | Some passes and free re-roll keep actions were only available inside the choice picker. | An explicit neutral button submits an existing legal pass/keep option through the same normalized command path. It never invents a pass for a mandatory choice. |
| Confusing opening/help | General reference preceded the current guide, and the compact HUD could clip its rightmost controls. | Current guidance leads Help; experiments and rule terms are collapsible. Narrow HUDs split phase/score and tools into separate rows. Command and board regions respect the actual header height. Both players' CP are visible. |
| Distant movement rejection | Movement validation already returned an error, but the main feedback was a text notice. | The same domain reason appears in a clamped label above or below the miniature and in the command panel. If the model is outside the visible board area, the notice moves to the nearest board edge and identifies the direction; a model behind the camera is labeled explicitly. A red X now keeps the rejected destination visible while the player previews another location; off-screen targets clamp to the nearest visible edge, and the command card names the marker and retry/cancel path. The distance rejection states requested and remaining movement. Final placement/coherency failures use the same feedback surface without claiming a specific failed point. A scripted Godot capture shows the marker and live cursor preview together; input behavior remains unchecked. The requested 1024×768 window produced a 1280×960 logical viewport due the local stretch/DPI setup, so this is not an exact logical-size acceptance capture. |
| Unreadable combat | The default result repeated long messages and firing-model lists, with final dice hidden in details. | A read-only combat tray shows the current recorded roll or allocation, weapon/target context, threshold/modifier where available, selectable stages and a stable final damage/casualty summary. Full identifiers and journal details remain accessible separately. |
| Weak combat presentation | Dice appeared as a fast status update; casualties disappeared immediately. | Group reveal timing, optional original synthesized sound cues and a brief casualty removal transition make changes visible. Normal/Fast/Reduced motion, skip, replay and a collapsible tray preserve access to legal decisions. Fixed damage is labeled without a fake roll. |
| Excessive text and history detail | Repeated scaffolding competed with the decision. | Original native vector symbols distinguish hits, wounds, saves and damage. History presents compact event cards first, with an explicit technical-record toggle. |
| Miniatures obscured or not framed | The camera still gated itself on the old Play tab after gameplay was reparented into Command; header/tray changes also changed its available area. | Frame the actual match screen, reserve panel/tray space and recompute automatic framing when that space changes. Manual camera control remains respected until the next decision. |

The new UI components live in `scripts/ui/combat_tray.gd`, `placement_feedback.gd` and `combat_symbol.gd`. Symbols and the short synthesized cue are original project-owned content under the project license; no third-party imagery, audio, data or browser dependencies were added.

The window stretch policy now expands to the available aspect ratio. Actual 1024×768 rendering previously produced a 1024×640 gameplay texture; the expanded policy uses the full 1024×768 window. Public journal pages carry a bounded attack summary for event cards while continuing to omit raw state patches. Reading that summary does not alter hashed entries or saved state.

## Invariants

- Presentation does not generate gameplay dice, select recipients, spend CP or advance phases. Replay and skip operate only on the currently recorded presentation.
- Mandatory decisions remain in Command. Folding or hiding dice does not hide their legal controls.
- Allocation uses the existing authoritative eligible set, including its supported restrictions and exceptions. Selecting a model card only changes local selection; confirmation sends the existing allocation command.
- The delayed casualty transition is visual only. Destroyed models are already excluded by authoritative state and cannot be selected for play.
- Reduced motion also suppresses board/camera animation. Combat sound has a separate local setting. Presentation speed is saved as a local preference.
- Initial/restored results are settled; unrelated events do not replay an old impact. This does not establish new save/reconnect or network coverage for every pending interaction.

## Verification record

### Command doctrine follow-up

The player supplied a screenshot of the combined Adaptive Strategy/Strategic Acumen dropdown and asked what its rule meant, then requested the proposed correction. The Command panel now uses action → unit → doctrine selectors. The free Captain ability is offered separately and initially preferred; Adaptive Strategy shows its selected target's projected CP cost. The preview explains effect, expiry and current doctrine, and warns when the primary doctrine is already active. Confirmation repeats the action and cost. The internal Captain model number is absent from this card. Other legal abilities remain accessible through their own category, including existing board placement input. The new `scripts/ui/doctrine_choice.gd` only browses existing choices; normalized submission and authoritative eligibility are unchanged.

The design uses the existing dark Command card and theme, three 40-logical-pixel selectors and a wrapping explanation, without new imagery or dependencies. It preserves the supported doctrine restrictions and does not re-certify their rule implementation. Initial render inspection accidentally loaded a Movement checkpoint; that capture was replaced with a public guided-setup/deployment/Command reproduction in `tests/test_doctrine_choice_ui.gd`. The inspected before captures are `.tools/doctrine-before-{1280,1024}.png`; final free, paid and redundant states are `.tools/doctrine-{free,paid,redundant}-{1280,1024}.png`, actual Godot/OpenGL at 1280×800 and 1024×768. The free 1280 capture includes the doctrine selector's hover tooltip. No required selector or confirmation was clipped. These are scripted runtime reproductions, not human acceptance.

`test_doctrine_choice_ui` checks browsing without state changes, free and paid real confirmation buttons, selected unit, doctrine application, CP and the redundant-doctrine warning. The initial focused run `.tools/verification/20261024T170217056233Z/results.json` passed that suite and tactical training but failed the old Help regression: its optional historical exercise had an undeclared local snapshot dependency. The verifier now declares that dependency, and refuses the focused profile rather than silently running the fixture without its data. No download was added. `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_doctrine_choice_ui --only test_tactical_training --only test_unit_choice_help_ui --timeout 300` passed **5/5 processes** at `.tools/verification/20261024T170427180122Z/results.json`, including 39 Python checks. After preserving the grouped panel's existing right-click placement route, the final command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_doctrine_choice_ui --only test_unit_choice_help_ui --timeout 300` passed **4/4** at `.tools/verification/20261024T170633135548Z/results.json`. No new network, human-comprehension or general rules coverage is claimed.

The implementation requires targeted regression and actual Godot rendering. No test or screenshot is human comprehension evidence.

1. The initial focused run at `.tools/verification/20261024T145621821297Z/results.json` passed tactical training but failed the old layout exercise because its runtime legacy-data dependency was not declared. `tools/verify.py` now explicitly identifies that dependency; it stages only the existing verified local snapshot in targeted runs and performs no download.
2. The targeted run at `.tools/verification/20261024T151328597027Z/results.json` passed 9/9 processes for the initial tray, layout, ownership, reactions, result UI and tactical changes. Later work expanded coverage and found the Keep-button submission defect.
3. The targeted run at `.tools/verification/20261024T151727376088Z/results.json` passed 10/10 processes, adding movement coverage. This predates the final Keep-button correction and later history/presentation refinements.
4. The reroll audit at `.tools/verification/20261024T152153264000Z/results.json` passed the seven domain reroll suites but failed the strengthened tactical UI lifecycle. That failure exposed the selected-die/pass-envelope mismatch; it must not be reported as a passing run.
5. After correcting the envelope, `& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_tactical_training.gd` completed with `Tactical training checks: 0 failures`. Fresh isolated results follow below.
6. The presentation/history audit at `.tools/verification/20261024T152834900251Z/results.json` passed import, Python, tray, layout, results and journal, but failed camera fitting. Investigation found the stale Play-tab guard described above. This run is failed evidence, not a completed visual gate.

The standalone `test_combat_tray.gd` checks skip/replay state invariance, fixed values, stable restored results, current-roll-only presentation, reduced motion and suppression of unrelated-event replays. It does not certify rules or player comprehension.

The additional `test_roll_choice_ui.gd` audit exercises both actual connected reaction buttons on independently restored domain checkpoints for all nine enabled Core roll kinds: Advance, Charge, Desperate Escape, attack count, Hit, Wound, Save, Damage and Hazardous. It checks visible/enabled alternatives, zero-CP continuation, exactly one CP spent by the owning player, original dice retention, mandatory replacement and the selected die versus whole movement-roll replacement. It uses current-catalog base models and a clearly synthetic weapon, not a new datasheet or rules certification. The first standalone attempt failed to compile because the fixture called the wrong allocation helper; the next failed visibility assertions because it omitted the production workspace reparenting step. Correcting those test-fixture errors produced a standalone pass. The final isolated command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_roll_choice_ui --timeout 300` passed **3/3 processes**, including **37 Python checks**, at `.tools/verification/20261024T161811460493Z/results.json`, with `legacy_starter_staged: false`, `network: false` and no cleanup diagnostics. Headless visibility checks do not establish viewport fit or human comprehension; the existing rendered captures and open human gate remain separate. This addition changes tests/tool dependency metadata only; the candidate runtime and exported PCK are unchanged.

### Passing candidate checks

The following exact commands ran from the repository root on Windows with Godot 4.7.2:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_tactical_training --only test_combat_tray --only test_match_journal --only test_gameplay_layout --only test_combat_results_ui --only test_decision_camera --only test_choice_ownership_ui --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_tactical_training --only test_combat_tray --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --network --only test_current_reference_match_network --timeout 300
python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300
```

| Check | Outcome | Evidence |
|---|---|---|
| Local presentation, actual tactical Keep/decline buttons, ownership, journal and camera | 9/9 processes passed | `.tools/verification/20261024T154842358045Z/results.json` |
| Final focused tactical/tray recheck after the last dice-label adjustment | 4/4 processes passed; no legacy starter staged | `.tools/verification/20261024T155634746804Z/results.json` |
| Mirror and tactical host/client lifecycle, including guest placement rejection/recovery UI | 6/6 processes passed in local loopback; no legacy starter staged | `.tools/verification/20261024T160441117483Z/results.json` |
| Clean staged import, tactical smoke, PCK export, exported startup and tactical pack smoke | 5/5 stages passed | `.tools/verification/build-20261024T155634742518Z/results.json` |

None of these reports recorded headless RID cleanup diagnostics. The local nine-process check stages the existing verified historical snapshot only for legacy exercise regressions; it is not current datasheet-source certification. The final focused training and network checks do not stage that snapshot. The final network recheck adds an actual invalid guest deployment-position command in both profiles, checks that the authoritative reason reaches the pinned miniature feedback and Command card without changing synchronized state or local RNG, then submits a legal position and checks both rejection surfaces clear. Both clients print `GUEST PLACEMENT FEEDBACK: PASS` before completing their matching canonical-state lifecycle. This is bounded RPC/functional UI evidence; it does not render the remote client, cover every movement rejection, or establish separate-machine LAN, general Marine networking or human comprehension.

The earlier exported artifact is `.tools/verification/build-20261024T155634742518Z/open-tabletop-demo.pck`, SHA-256 `bfe4fd96a3e5d815848c34800f94c7596ba80de25f170fb253f84b1b532a9a86`. It runs through Godot; this report does not claim a new native executable build. `.tools/ux-candidate-20261024.json` records the code-file hashes, artifact identity and check locations for the next human session.

## Visual evidence

Actual Godot/OpenGL captures are retained in the ignored `.tools/` directory. These are scripted runtime sessions with project-owned primitives, not mockups. Combat captures use an explicitly test-only deterministic dice subclass; production `_d6()` is unchanged.

- `.tools/ux-native-opening-1280.png` and `ux-native-help-1280.png`: actual 1280×800 opening and current-step Help using the project's native stretch policy.
- `.tools/ux-native-opening-1024.png` and `ux-native-help-1024.png`: actual 1024×768 opening and Help; logical canvas 1280×960 under aspect expansion.
- `.tools/ux-native-opening-1600.png` and `ux-native-help-1600.png`: actual 1600×900 comparison with the single-row toolbar.
- `.tools/ux-flow-invalid-move.png`, `ux-flow-reroll.png`, `ux-flow-next-decision.png`, `ux-flow-allocation.png`, `ux-flow-completed.png` and `ux-flow-reveal.png`: scripted current-catalog tactical setup, deployment and combat at actual 1024×768, exercising domain commands and actual UI buttons. Keep is asserted to advance the revision without spending CP. The defender selects a non-default recipient through the actual allocation UI.
- `.tools/ux-flow-history.png` and `ux-flow-reduced-motion.png`: compact public attack cards and reduced-motion presentation. The capture asserts that changing presentation preserves the match state.
- `.tools/ux-flow-reroll-1280.png`, `ux-flow-allocation-1280.png` and `ux-flow-completed-1280.png`: actual 1280×800 views rebuilt from the corresponding serialized runtime checkpoints, with presentation caches reset to avoid invented healing/impact effects.
- Initial `.tools/ux-before-*` captures used different physical/logical viewport combinations. They are starting-state evidence only, not pixel-matched before/after comparisons.

## Open acceptance gates

### Follow-up: phase replay, save outcomes and neutral choices

The player reported combat animations recurring on phase changes, missing save/damage feedback and duplicated neutral choices. Reproduction found that `AttackFeedback.record_key` used the position of the completion message in the 30-entry rolling event list. Evicting older events changed that position, making the same attack look new. Completed attacks now persist `completion_revision`; presentation keys use that identity, with a stable content fallback for older saves. Annotation, phase changes and event eviction do not create a new attack. Restored/settled dice also no longer create their own face-pop tween; explicit new reveals/replay retain animation.

The resolver records confirmed passed-save counts without changing the save predicate, ordering, dice or damage. The tray distinguishes `Saves await confirmation`, `Save failed` with pending recipient/damage decisions, `Saved · no damage applied`, and committed damage/casualties. Counts do not label unallocated excess attacks as successful saves. Old records without the new counts retain their existing summary rather than guess. A legal pass/keep exposed by the dedicated button is removed from the generic picker and grouped doctrine browser; a neutral-only window hides the empty picker and redundant confirmation. No mandatory choice gains a new pass.

The initial scoped checks passed **8/8** at `.tools/verification/20261024T173312733000Z/results.json`. The domain/save/result/journal check passed **7/7** at `.tools/verification/20261024T173501437803Z/results.json`. After strengthening the actual phase-transition and stable-identity checks, `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_save_outcome_ui --only test_combat_tray --only test_attack_feedback --timeout 300` passed **5/5** at `.tools/verification/20261024T173726030594Z/results.json`. The current-reference/tactical loopback passed **6/6** at `.tools/verification/20261024T173726028512Z/results.json`, and the intermediate PCK passed all five stages at `.tools/verification/build-20261024T173726029493Z/results.json`. Later selection/datasheet changes supersede that intermediate package.

Actual Godot/OpenGL captures at 1280×800 and 1024×768 are `.tools/save-feedback-{saved,failed-pending,damage}-{1280,1024}.png` (clearly synthetic weapon, real domain/confirmation flow) and `.tools/single-decline-{stratagem,bladeguard}-{1280,1024}.png` (restored tactical decisions). An initial neutral-choice capture had the local menu open; the corrected capture closes it and shows the actual decision controls. All final images were inspected. The save-outcome test uses real phase progression to verify no new dice sequence or battlefield burst, while the feedback/tray tests also exercise rolling-history eviction and old-save fallback. Images do not establish human comprehension or motion comfort.

### Follow-up: selection and datasheet design

The player's subsequent review expanded the task to selection/focus lag, card redundancy and datasheet readability. The [selection/datasheet review](selection-datasheet-review.md) records the implementation, CPU measurements, source boundaries and actual captures. Selection refresh CPU time fell from 166.1–173.9 ms to 7.2–9.6 ms across eight scripted selections on the same debug-runtime checkpoint. This is bounded local evidence, not a release FPS or input-to-photon claim. The compact card omits owner/living count, and the full inspector groups characteristics and weapon columns without repeating their legend per profile.

The playtest launcher and record validator now explicitly include the six experience-correction observations (opening/controls, optional Keep and paid cost, defender recipient, local movement recovery, attack explanation, and pacing/symbols/motion). Previously their required table covered only the earlier tactical baseline; that table could not prove acceptance of these corrections. Existing records without the new observations remain incomplete for this candidate. No human outcome was filled by the agent.

Tool validation: `python -m unittest discover -s tests -p test_verification.py` passed **28 tests**. The launcher/validator checks now reject a missing correction observation and keep an unobserved reroll gate open. `pwsh -NoProfile -File ./tools/run_tactical_playtest.ps1 -Godot './.tools/intentionally-missing-playtest-preflight.exe'` created `.tools/playtest-20261024-132045266/tactical-training-session.md` and returned the expected **2** for the deliberately missing executable. `python tools/validate_tactical_playtest.py .tools/playtest-20261024-132037979/tactical-training-session.md` returned **2** for the generated blank record, listing all 16 missing outcomes. These are tooling preflight checks, not a launched or completed human session; no Godot runtime changed in this refinement.

- Repeat the human tasks in the [playtest procedure](../verification/tactical-training-playtest.md): explain who decides, keep a result, choose a legal non-default recipient, correct an invalid move, and explain why models were destroyed. Record hesitation and comprehension, including whether normal combat pacing feels satisfying.
- Review icon recognition, sound level and motion comfort with the player. These are design hypotheses, not achieved quality scores.
- Broader Marine networking, graphical inspection of the remote client, separate-machine LAN, remote CI and native builds remain distinct verification boundaries.

No general rules, faction, army-legality or platform certification follows from this UX correction.

The Command doctrine follow-up was packaged with `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300`: all five stages passed at `.tools/verification/build-20261024T170716525024Z/results.json`. The updated PCK is `.tools/verification/build-20261024T170716525024Z/open-tabletop-demo.pck`, SHA-256 `14f2f69504037fbf55be5ff099d68473d467a90444f1051be9089faff040284a`. The earlier build at `build-20261024T170548080962Z` passed before the final grouped-placement input guard refinement and is superseded. The updated candidate manifest identifies the new artifact; human acceptance remains pending.

## Final follow-up candidate checks

After the final datasheet column-legend/health-bar styling refinement, the following exact commands completed:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_selection_response --only test_selection_card --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --network --only test_current_reference_match_network --timeout 300
python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300
```

The final selection/card check passed **4/4 processes** at `.tools/verification/20261024T214203268368Z/results.json`. The bounded mirror/tactical host/client run passed **6/6** at `.tools/verification/20261024T214203268551Z/results.json`. The final build passed **5/5** at `.tools/verification/build-20261024T214203269305Z/results.json`. All three reports contain no headless cleanup diagnostics. The PCK is `.tools/verification/build-20261024T214203269305Z/open-tabletop-demo.pck`, SHA-256 `34f09c803cb77cf442d22f6099d1ca87b1235c6a3df597e76fce733b6195c93d`; the candidate manifest now references it and the current source hashes. Earlier packages remain historical evidence. No native executable, separate-machine LAN or new human acceptance is claimed.

## Phase heading and selection footer — 24 October 2026

Human feedback: the right-hand heading remained COMMAND outside that phase, and the new model card was still oversized and poorly placed. The action heading now reads the actual phase, with explicit start/end labels, movement-demo ACTIONS and recorded MATCH RESULT. It does not infer legality or decision ownership from the phase; required interrupt controls and owner remain visible below it.

The selected-model summary is now a footer below the scrollable army list, integrated with a single divider. The six characteristic cells move to the existing full datasheet; identity, wounds/bar and relevant exceptional/movement/action feedback remain in the footer. No extra board overlay or camera behavior was introduced. Actual Godot restored-match captures `.tools/selection-footer-1280.png` and `.tools/selection-footer-1024.png` were inspected; footer and button fit both sizes. These are runtime captures, not human playtest acceptance.

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_selection_card --only test_selection_response --only test_decision_camera --only test_gameplay_layout --timeout 300` passed **6/6 processes**, report `.tools/verification/20261024T215647113751Z/results.json`. The tests cover phase labels, footer order, selection projection reuse, inspector recovery and existing board/layout constraints. Historical card/layout fixtures use the already-present local staged snapshot; no download or new rule certification. `git diff --check` passed with existing CRLF normalization warnings. The prior loopback result applies to its recorded earlier candidate; no new network check was run for this presentation-only follow-up.

Final package: `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300` passed **5/5 processes**, `.tools/verification/build-20261024T215755705781Z/results.json`. Artifact `.tools/verification/build-20261024T215755705781Z/open-tabletop-demo.pck`, SHA-256 `4201f0c91476c20c635fa9a59db9c59ec0f71be7c9943306faaebf22f6a3b428`. Candidate manifest refreshed; human acceptance remains pending.

## Night consolidation candidate — 24 October 2026

This work completed the user-directed local consolidation plan without expanding factions, catalog choices or rules. The dirty checkout and prior PCK were preserved before edits in `.tools/worklog/consolidation-baseline-20261024-191705/`, including the patch, copies of the initial changed files and prior reports/package. `issue-log.md` in that folder records the reproductions, corrections, evidence and outstanding gates.

The 1024×768 preparation capture exposed a fixed minimum width that cut off a wrapping instruction. Long labels now use their container width while actual buttons and option pickers retain their required size. The army roster also keeps its model rows when only selection changes; it restyles the old and new selected rows and still rebuilds after any displayed roster state changes. The `test_selection_response` regression checks both paths. No permanent panel or rule eligibility changed.

The optional ability reader now checks `user://rules/wahapedia/11e/space-marines/<snapshot-id>/` before the project-local `.tools/wahapedia/11e/space-marines/<snapshot-id>/`. It validates source metadata, snapshot identity and every listed file hash, handles multiline pipe-delimited records/Unicode/shared definitions, and fails the complete load on corruption or unresolved source rows. Invalid user data is reported without a project fallback. The inspector keeps source rules separate from project-authored implemented scope; no source file enters saves or network state. The guide documents the optional user-data copy for exported packs, and the packaged game makes no download request.

The real local snapshot audit resolved **192 Space Marines identities and 882 ability records** from snapshot `20261021T130623Z`; it rechecked all **23 manifest files** and hashes. Of 193 Space Marines source datasheets, one has no ability relation; the reader now retains it as a known identity with an empty ability list and reports that state separately from an unmatched identity. The existing snapshot's recorded retrieval time is 2026-10-21 19:46:58 UTC and its export specification revision is `20260817b`; no source refresh or rule certification was performed.

Actual Godot/OpenGL captures were inspected at **1024×768, 1280×800 and 1920×1080**. They cover title, preparation, Help, an optional reaction, the scrolled source/implemented-scope inspector and a staged result card. Combat flow captures cover invalid movement, reaction/reroll, next decision, defender allocation and attack completion; 1280×800 and 1920×1080 reroll/allocation/completion frames were rebuilt from serialized checkpoints. See `.tools/worklog/consolidation-baseline-20261024-191705/screenshots/`. The match-result images are staged result fixtures, and controlled combat dice belong to a test-only capture subclass; none is human playtest evidence.

The same eight-selection debug checkpoint first measured the synchronous `_refresh` path at 9.3–13.3 ms. After avoiding the roster rebuild, two runs measured 4.3–8.1 ms and 4.4–6.0 ms; army-roster refresh fell from 3.4–5.7 ms to 0.2–0.6 ms. The two-frame observation was 68.1–76.6 ms while `TIME_PROCESS` reported 35.4–41.9 ms, compared with 25.3–27.1 ms in the earlier profile. The synchronous work improved; end-to-end selection latency remains inconclusive until profiled under controlled frame load. This is debug-runtime instrumentation, not release FPS or input-to-photon evidence. Raw measurements are `.tools/selection-profile-{final-consolidation,final-consolidation-repeat,final-roster-update,final-roster-update-repeat}.json`.

Final local checks on this source candidate:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_local_ability_reference --only test_selection_response --only test_selection_card --only test_decision_camera --only test_choice_ownership_ui --only test_gameplay_layout --only test_roll_choice_ui --only test_save_outcome_ui --only test_combat_tray --only test_attack_feedback --only test_match_result_ui --only test_pending_decision --only test_resolution_frame --only test_guided_turn_ui --only test_tactical_training --only test_tactical_combat_flow --only test_attack_rerolls --only test_save_rerolls --only test_damage_rerolls --only test_damage_allocation --timeout 300
```

Passed **22/22 processes**, `.tools/verification/20261024T230814521351Z/results.json`, without cleanup diagnostics. The selection/response assertion checks selection without match-state mutation, camera/focus and same-revision projection reuse. The damage-reroll suite now also saves a live pending allocation through the actual match file, deliberately changes the in-memory revision, reloads the file and compares exact state/RNG, allocation options, defender ownership and the suspended attack frame before continuing the attack.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile demo --network --timeout 300
```

Passed **13/13 processes** at `.tools/verification/20261024T230025979983Z/results.json`, including the host/client loopback pair, without cleanup diagnostics. Host/guest runs were sequential. Loopback evidence is limited to the exercised local profiles and is not separate-machine LAN evidence.

```text
python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --target pack --timeout 300
```

Passed **5/5 stages** at `.tools/verification/build-20261024T224938400914Z/results.json`. The PCK smoke checks the title, tactical guide, both preparation declarations and clean staged scenario; it starts with isolated `user://` data, confirms source rules are unavailable while implemented scope is visible, opens the inspector without changing selection/state/RNG, then saves, changes and restores the tactical setup with exact match-state and RNG equality. The PCK contains none of the three source CSV filename entries or the export workbook. Artifact: `.tools/verification/build-20261024T224938400914Z/open-tabletop-demo.pck`, **1,486,836 bytes**, SHA-256 `a95a65c6d639dc780d8225add1fb880b1b5fd3fd8a11da7acc1ab1a79adfdabe`. The prior approved candidate remains preserved; this new PCK passed all five gates.

`git diff --check` passed; Git emitted only existing line-ending normalization notices. The candidate manifest `.tools/ux-candidate-20261024.json` identifies the new PCK, reports and source hashes. No commit, external message or publication was made.

### Deferred gates and experience decisions

Human playtests remain deferred, and no human acceptance is recorded. Separate-machine LAN remains deferred by the user; remote CI was not run on this working-tree candidate; native Windows/Linux exports remain unavailable because matching Godot 4.7.2 templates are not installed. The full-frame selection measurement needs a controlled follow-up. No rules, datasheet certification, army legality or wider platform claim follows from these checks.

When the player returns, the useful experience decisions are whether the selected-model footer and inspector are easy to scan during decisions, whether the optional Keep/defender allocation choices and combat tray explain outcomes at the current pace, and whether the sound and reduced-motion controls feel comfortable.

## Keyboard-accessible weapon glossary — 25 October 2026

The pre-match Guide and in-match Help tab now offer a collapsed glossary of the weapon ability entries already maintained by `KeywordGlossary`. Its toggle and read-only text can receive keyboard focus; the text can be selected with the keyboard, and each existing scroll area contains the full reference. This extends access to current definitions without introducing new ability support or match choices. Weapon tooltips now render Anti-X thresholds as `Anti-Fly 4+`, substitute numeric Blast/Rapid Fire/Sustained Hits values in their explanations, and retain the existing explicit missing-entry warning.

The glossary uses the existing June 2026 Core Rules references recorded in code. It remains a partial pilot: abilities without an entry, unit abilities and faction stratagems still require separate source/version review. No test suite or Godot interaction was run because that playtest environment is currently unavailable. `git diff --check` passed, and the structural project checker reported zero errors or warnings in 794 files after the pre-match Guide entry was added. Focus order, panel height, keyboard expansion and tooltip readability remain to be checked in Godot.

## Per-die attack outcome cues — 25 October 2026

The attack resolver now carries hit and wound success/critical outcomes alongside the final dice it already records. The command-checkpoint path records the same outcomes after its existing calculations. Damage allocation records each save result when that die is actually processed, with the armor threshold after AP and any save modifier plus the effective invulnerable threshold. The combat tray and expanded dice details use these values for ✓, × and ★ markers; unresolved saves stay raw while allocation is waiting. Older result records remain readable and display raw hit, wound and save faces without inferred markers. No attack eligibility, dice, allocation or damage behavior changed.

No test suite or Godot interaction was run because playtesting is unavailable. `git diff --check` passed; the structural project checker reported zero errors or warnings in 794 files. Layout, mixed-defense presentation, accessibility and continuation behavior still need focused Godot verification.

## Keyboard inspection for recorded dice — 25 October 2026

Revealed dice in the combat tray are now keyboard-focusable and clickable. Focus or click shows a separate read-only detail line with the recorded face and, when present, the resolver's recorded outcome and applicable hit, wound or save threshold. Faces that have not reached their reveal step expose no underlying value. Selecting a die sends no gameplay command and does not change the result. This advances D3/E1 access for individual results without adding a rule or changing RNG.

No test suite or Godot interaction was run because the user cannot test now. `git diff --check` and the structural project checker are the only checks for this increment; visible focus, pointer behavior, panel fit and accessibility still need Godot review. No screen-reader compatibility is claimed.

## Damage roll inspection — 25 October 2026

The combat tray now associates each recorded random damage expression and pre-prevention value with its displayed D6 faces. When the allocation record contains per-packet resolution, inspecting a damage face also shows wounds applied, prevented and discarded. Stages that do not use success/failure markers now describe their raw recorded value and stage context instead of implying that a missing pass/fail classification is an error. No result is recalculated and no rules or RNG behavior changed.

No test suite or Godot interaction was run. `git diff --check` exited 0; `python .agents/skills/godot-nodes-scenes/scripts/check_godot_project.py .` reported 0 errors and 0 warnings in 794 files. Dice-to-packet ordering and detail-line fit need Godot review, especially for multi-D6 expressions and older records.

## Dice face pips in the combat tray — 25 October 2026

The combat tray now pairs its numeric D6 face and success marker with the same original vector pip drawing used in reroll choices and the detailed result view. The renderer is a shared UI component; unrevealed dice keep both the number and pips hidden until the existing presentation reveal. Textual stage labels and per-die detail remain available. No roll or match result changes.

No tests or Godot interaction were run. Layout, pip legibility and animation fit still need in-engine review at the target viewports.

## Per-die Feel No Pain outcomes — 25 October 2026

Feel No Pain dice now carry the outcome already decided by the wound-prevention resolver. The combat tray marks each stored success or failure, summarizes the number of wounds prevented, and explains the selected die with its target and effect. The expanded latest-result dice view and attack history show the same per-die cue when present; history reports how many classifications are unavailable in older or incomplete records. This applies to attack damage and recorded Hazardous prevention. No result is inferred; the resolver's calculation, die order, and RNG calls are unchanged.

No tests or Godot interaction were run because the user cannot test now. `git diff --check` and the structural project checker are the only checks for this increment; symbol meaning, legacy display, layout and input still need Godot review.

## Allocation recipient labels — 25 October 2026

Eligible-model cards now use the roster ordinal and add Sergeant/Character role labels when applicable, with current wounds beside each recipient. The confirmation action repeats the selected model so the player can check the target before submitting the existing allocation command. The list still comes from the authoritative allocation eligibility projection; no priority, ownership or command behavior changed. Hazardous guidance retains its existing priority order and prevention.

No tests or Godot interaction were run because the user cannot test now. `git diff --check` and the structural project checker are the only checks for this increment; long labels, focus, card/confirmation fit and 1024×768 behavior still need Godot review.

## Allocation damage forecast — 25 October 2026

The selected-recipient forecast now passes the weapon damage range through the same supported damage-reduction helper used by resolution. It labels that range before prevention and shows exact or possible remaining wounds only when the damage range and applicable Feel No Pain rules allow it. When Feel No Pain applies, the forecast names the best threshold and leaves the final wound count undecided. Zero wounds are described before post-destruction effects, so the preview does not promise removal when a survival effect may still resolve. No damage roll, prevention roll, allocation or casualty state is created by the forecast.

No tests or Godot interaction were run because the user cannot test now. `git diff --check` and the structural project checker are the only checks for this increment; wording, fit and representative reduced-damage/FNP/survival cases remain pending Godot review.

## Retained rejected-destination marker — 25 October 2026

After a placement command is rejected, a red screen-space X now marks its destination while the live cursor preview remains independent. The marker follows a projected target into the visible board area when it is beyond the camera view. The action card identifies the X and offers a retry/cancel path. Whole-squad confirmation errors do not mark the model's current position as if it were a specific rejected destination. Placement reasons, host validation and game state remain unchanged.

A capture-only staged tactical session produced `.tools/worklog/consolidation-baseline-20261024-191705/screenshots/ux-flow-invalid-move-after.png` in Godot 4.7.2/OpenGL; it shows the rejected target and the separate live cursor preview. The window was requested at 1024×768, but Godot reported a 1280×960 logical viewport under the local DPI/stretch setup, so this is not exact target-size evidence. No input sequence or automated suite was run. `--headless --editor --path . --quit` loaded the project without script parse errors. During capture setup, that load exposed four compile blockers in already modified outcome/UI scripts; explicit typing, a loop-local rename and a missing attack-sequence reference fixed them without changing resolved results. Input recovery and exact logical target sizes remain pending Godot interaction review.

## Resume presentation baseline — 25 October 2026

Accepted saved matches and a client's first validated host snapshot now reset the combat tray and battlefield attack-feedback signatures before the restored state is refreshed. This seeds both presentation systems from the authoritative snapshot, so an old completed attack or pending roll is shown as the current state instead of replaying merely because another match was open before resume or a guest joined mid-match. Later host updates keep the normal event presentation. The restored journal, dice, RNG and decision state are preserved; no gameplay effect is repeated.

No test suite or Godot interaction was run because the user cannot test now. Static project loading, structural checks and `git diff --check` are recorded for this increment; resuming over a different live match, joining mid-match, and pending attack decisions still need in-engine review.

## Reload optional datasheet source in place — 25 October 2026

The Source Rules section keeps **Open local reference folder** and **Reload local reference** available when the source is missing, valid or invalid. After a verified snapshot is copied or updated in the user-data folder, reload clears the static reader cache, re-runs external-first integrity validation, and refreshes that datasheet immediately. Invalid user data remains an explicit error with no project fallback. Match state and selection are not changed, and the game still performs no download. The folder-opening status and installation guide direct the player to reload after copying instead of restarting the game.

Actual Godot 4.7.2/OpenGL captures of the main game scene at 1024×768, 1280×800 and 1920×1080 show the folder and reload actions in missing-source and invalid-source states, with implemented scope kept distinct: `.tools/reference-reload-missing-{1024,1280,1920}.png` and `.tools/reference-reload-invalid-{1024,1280,1920}.png`. The missing-source cache was staged. Reloading the project-local snapshot reported the cross-file validation error below; its UI state is an actual error report, not a valid loaded source. No button interaction was simulated, so the images establish layout only.

The current project-local snapshot `20261021T130623Z` still matches all **23 manifest file hashes**, but the reader rejects it because relation record **5947** references datasheet ID `000004150`, which is absent from `Datasheets.csv`. No raw export was changed or refreshed. Source text from this snapshot is unavailable until a complete, internally consistent export is installed; the explicit error prevents partial text from appearing complete. No test suite was run. Reload behavior, external snapshot installation and focus/navigation remain pending interaction verification.

## Saved-result content identity — 25 October 2026

The saved-result browser checks schema-3 records against the SHA-256 identity produced from the complete result contents. An edited record whose filename and `id` still match but whose result fields changed is filtered as damaged; the save path also refuses a schema-3 record whose contents no longer match its identity. The legacy schema-1 and schema-2 read paths were retained; the schema-1 identity follow-up is recorded below. This protects the saved result history and does not load a result into the active match or affect match resolution.

No test suite was run because the user cannot test now. Godot project loading, structural validation and `git diff --check` are recorded for this code-only increment; schema-3 read/write round-trip and legacy schema rendering still need focused verification.

## Legacy schema-1 result identity — 25 October 2026

The repository's original schema-1 writer also created its `id` from the complete JSON result before adding the `id` field. The saved-results reader now checks that content identity for schema 1 as well as schema 3, so edits to those older records are hidden as damaged. Schema 2 retains filename/field validation because its historical writer is not present in the repository; no compatibility assumption was added. Saving still writes schema 3 only, and match resolution is unchanged.

No gameplay tests or Godot interaction were run because the user cannot test now. Script-load and whitespace checks are the only checks for this increment; legacy schema files still need a focused read-only review.

## Saved-result recovery details — 25 October 2026

The saved-results scan now keeps a concise reason for every filtered JSON result. The browser exposes those reasons through a collapsed, keyboard-focusable detail area, with the affected filename and a limit of twelve displayed entries. It directs the player to `user://matches/results` and to reload after restoring a valid copy. Schema-1 and schema-3 records receive content-identity validation; schema 2 retains the prior compatibility checks. The Godot JSON parser presents integral JSON numbers as floats, so validation accepts only whole-number values where an integer is required and normalizes those values before checking the legacy SHA-256 identity. Match state and result resolution are untouched.

Capture-only Godot 4.7.2/OpenGL views of the actual main scene are `.tools/saved-result-issues-empty-before-1024.png` and `.tools/saved-result-issues-expanded-{1024,1280,1920}.png`. The fixture was one deliberately edited schema-3 result in a previously absent local results folder; the capture script removed it afterward. Godot reported a 1280×960 logical viewport for the requested 1024×768 window, 1280×800 for the requested 1280×800 window, and 1422×800 for the requested 1920×1080 window. The detail list fits in the rendered views. These captures do not verify keyboard activation/scrolling or player comprehension. No gameplay or automated test suite was run; focused legacy read/write compatibility review remains pending.

## Ancient Weapons for Wrath of the Rock — 25 October 2026

`Ancient Weapons` is now available as a 20-point Wrath of the Rock enhancement. The Army Workshop filters it through the local Space Marine catalog and the exact enhancement-to-datasheet relations. The initial intersection was 12 identities: Lieutenant with Combi-weapon, Techmarine, Chaplain on Bike, Captain on Bike, Chaplain with Jump Pack, Captain with Jump Pack, Librarian in Terminator Armour, Librarian, Librarian in Phobos Armour, Captain in Phobos Armour, Captain and Lieutenant. The Terminator source-link follow-up raised the intersection to 15; the Gravis source-link follow-up then added Apothecary Biologis and Captain in Gravis Armour for 17; the Ancient identity follow-up at the end of this report raises it to 19 with Ancient and Bladeguard Ancient. Only the assigned bearer model's melee attacks receive +2 Strength and +1 AP; ranged profiles and other models are unchanged.

The current Wahapedia 11e Space Marines page lists the 20-point cost, Adeptus Astartes model restriction and melee effect ([Wrath of the Rock source](https://wahapedia.ru/wh40k11ed/factions/space-marines/), App 2.8.1, observed 25 October 2026). Local eligibility uses snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`. `Enhancements.csv`, `Datasheets_enhancements.csv`, `Datasheets.csv` and `Datasheets_keywords.csv` each match their manifest SHA-256, recorded with this rule in the [rules ledger](../space-marines-rules-ledger.json). The four eligibility tables contain 37 related datasheet identities; all resolve, and 12 were in the runtime catalog at the initial implementation; Terminator source binding raised the count to 15, Gravis source binding to 17, and the later Ancient identity follow-up to 19. The separate `Datasheets_abilities.csv` orphan remains unresolved, so the broader optional ability reader still rejects the full snapshot; this increment does not certify that table or any datasheet profile.

Focused enhancement/attack checks and human playtesting remain pending. No test suite or in-game playtest was run for this increment. `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` exited 0 with no script parse errors; `python -m json.tool docs/space-marines-rules-ledger.json` succeeded; and `git diff --check` exited 0 with existing line-ending notices. A read-only comparison matched all 37 configured eligibility IDs to the local relation table, with no orphan datasheets and 12 initial current-catalog intersections; Terminator source binding recorded 15, Gravis source binding 17, and the later Ancient identity follow-up below records 19. These checks confirm source-file integrity and project load only; they do not validate the enhancement's combat behavior.

## Deathwing Assault ingress — 25 October 2026

`Deathwing Assault` is now available as a 15-point Wrath of the Rock enhancement. In battle round 1, the enhanced unit can ingress during its own first Movement phase. The placement check now enforces the core ingress requirement that each base be wholly within 6 inches of a battlefield edge, more than 8 inches horizontally from every enemy, and outside the opponent's deployment zone before battle round 3. If deployment zones are missing or malformed in an early-round state, ingress is rejected with a specific validation error instead of skipping that restriction. The enhancement exception does not make the unit eligible for Rapid Ingress during the opponent's first Movement phase. The action label names Deathwing Assault when that early choice is available.

The local Data Export relation file lists five datasheets. Four currently selectable profiles have the required local Deep Strike ability: Librarian in Terminator Armour, Chaplain in Terminator Armour, Captain in Terminator Armour and Ancient in Terminator Armour. Ancient in Terminator Armour still omits its documented DEATHWING keyword in the shared profile; its exact source identity binds it to this enhancement, but the broader keyword reconciliation remains open. Bladeguard Ancient is also in the export relation but its verified local ability records do not include Deep Strike, so it remains unavailable under the current restriction. The relevant source tables match the hashes in snapshot `20261021T130623Z`; their identities, retrieval date, revision and hashes are in the [rules ledger](../space-marines-rules-ledger.json). The full snapshot still has the previously recorded unrelated orphan ability-relation row; this feature does not certify that table. Core placement limits follow [Ingress Move 20.04](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), observed 25 October 2026.

Focused reserve/ingress checks and human playtesting remain pending. No test suite or playtest was run for this increment because the user cannot test now. Static checks on 25 October 2026: `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` exited 0; `python -m json.tool docs/space-marines-rules-ledger.json` exited 0; scoped `git diff --check` exited 0 with existing CRLF notices; and a read-only SHA-256 comparison confirmed all six recorded source files match. These checks do not verify gameplay behavior.

## Gravis detachments — 25 October 2026

`Gravis Siege Force` is available in prepared-match selection with its `Indomitable Defence` detachment rule. A friendly GRAVIS unit within range of an objective receives -1 to incoming Wound rolls when the attack Strength exceeds that unit's Toughness. The effect uses the existing local GRAVIS keyword, objective geometry and shared defensive Wound modifier path.

The local army enhancement picker now offers `Immovable Conquerors` (15 points) for Gravis profiles linked by the local export and present in the consolidated Marine catalog. In a Gravis Siege Force match, models in that enhanced unit contribute +1 OC through the shared objective-control path.

Gravis Linebreaker and Gravis Siege also offer `Annihilating Force` (1 CP) when a friendly GRAVIS unit is selected to attack in Shooting or Fight. The owner can use the bound attack-declaration choice or decline; when used, the unit's attacks gain Lethal Hits for the phase.

Gravis Linebreaker Force now also offers `Armoured Impact` (1 CP) immediately after a friendly GRAVIS unit completes a Charge move. The owner chooses one engaged enemy unit; the game rolls one D6 for each friendly model engaged with that target, and each 3+ adds one mortal wound. The target defender resolves those wounds through the shared allocation and prevention path. The owner may decline. Focused combat checks remain pending.

Gravis Linebreaker Force now also offers `Purgation Push` (1 CP) after a friendly unengaged GRAVIS unit shoots. The owner previews a Normal Move up to 5 inches and confirms only when at least one model ends within objective range. The shared placement path checks movement distance, terrain, base overlap, coherency and engagement; the unit cannot Charge or embark until the end of the turn. Focused combat and movement checks remain pending.

The local enhancement catalog now offers `Indefatigable Fortitude` and `Relentless Advance` (20 points each), restricted by the export mapping to Apothecary Biologis and Captain in Gravis Armour. Fortitude applies the shared -1 Wound modifier when attack Strength exceeds the unit's Toughness. Relentless Advance contributes Scouts 5 to the unit through the existing pre-battle Scout flow. Focused enhancement and Scout movement checks remain pending.

Gravis Siege Force now offers `Stand Unyielding` (1 CP) in the end-of-Movement decision window. The player can choose a friendly GRAVIS unit that contributed positive OC to an objective the army controls, then secure one objective that unit controls. Eligibility uses the resolved phase control and live unit OC; securing uses the existing objective effect. Focused control, CP, and phase-continuation checks remain pending.

Gravis Siege Force now offers `Suppression Volleys` (1 CP) after a friendly GRAVIS unit shoots. The shot records only living enemy units hit by that activation; the player chooses one target for a Battle-shock roll at -1. The tested unit's controller can keep the result or use `Tempered in Battle` to re-roll both Leadership dice when eligible. Focused combat and decision-owner checks remain pending.

The current Wahapedia Space Marines page confirms these effects in App 2.8.1 (observed 25 October 2026). Local source rows `000011215`, `000011216002`, `000011208002`, `000011208003`, `000011209002`, `000011209003`, `000011209004`, `000011217002`, `000011217003` and `000011217004` use export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. `Detachment_abilities.csv`, `Enhancements.csv`, `Datasheets_enhancements.csv`, `Stratagems.csv`, `Datasheets_keywords.csv` and `Datasheets.csv` match their manifest SHA-256 values, recorded in the [rules ledger](../space-marines-rules-ledger.json). This confirms source identity and local file integrity only; it does not validate all Gravis profile data or any runtime effect.

Focused combat, movement, enhancement and Scout checks plus human playtesting remain pending, and no test suite or playtest was run because the user cannot test now. Static checks after this increment on 25 October 2026: `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` exited 0; `python -m json.tool docs/space-marines-rules-ledger.json` exited 0; scoped `git diff --check` exited 0 with existing CRLF notices; source-row inspection confirmed Indefatigable Fortitude `000011208002`, Relentless Advance `000011208003`, Purgation Push `000011209003`, Armoured Impact `000011209004`, Stand Unyielding `000011217003` and Suppression Volleys `000011217004` in snapshot `20261021T130623Z`; `Datasheets_enhancements.csv` maps the two enhancements to Apothecary Biologis `000000060` and Captain in Gravis Armour `000001172`; and SHA-256 comparisons matched `Enhancements.csv`, `Datasheets_enhancements.csv`, `Stratagems.csv`, `Datasheets_keywords.csv` and `Datasheets.csv` against the manifest. These checks establish project load, source identity and file integrity only; no visual capture or gameplay behavior is claimed.

## Narthecis Gauntlet — 25 October 2026

`Narthecis Gauntlet` is now available in the Gravis Siege Force local enhancement picker for the export-matched Apothecary Biologis model. In the Command phase, the action rolls D3+1 and opens the existing healing decision flow for that unit. The shared flow allocates wounds to living models first and can return an eligible destroyed non-Character model with 1 wound, including placement preview and coherency confirmation. The action is limited to the active owner's Command phase, a living on-battlefield bearer, a living unit that needs healing and one use per unit turn; its source key is kept separate from the datasheet's Narthecium action.

Wahapedia Space Marines 11e App 2.8.1, observed 25 October 2026, confirms the 20-point cost, Apothecary Biologis bearer restriction and Command-phase D3+1 effect. The local export row is `000011216003` in snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`; `Datasheets_enhancements.csv` maps it only to Apothecary Biologis `000000060`. The ledger records SHA-256 values for `Enhancements.csv`, `Datasheets_enhancements.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`.

Focused healing/enhancement checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. On 25 October 2026, `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` exited 0; `python -m json.tool docs/space-marines-rules-ledger.json` exited 0; a read-only Python audit matched the Narthecis export row, its sole Apothecary Biologis mapping and four recorded source SHA-256 values; and scoped `git diff --check` exited 0 with line-ending conversion notices only. No live-Godot capture was made because the Command-phase healing choice was not staged in a match; no visual presentation is claimed. These checks establish project loading, source identity and file integrity only; they do not verify gameplay behavior.


## Champion of the First Company — 25 October 2026

At its initial implementation, `Champion of the First Company` was admitted only for Librarian in Terminator Armour (`000000079`), because the other three current-reference profiles lacked the source IDs required by the source-restricted enhancement filter. While the living bearer remains in its unit, every model's melee attacks in that unit gain Lethal Hits through the shared attack-profile path. The source-mapping follow-up below links all four identities and records the additional source-restricted enhancement options this enables.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Enhancement row `000011200002` maps to datasheets `000000079`, `000000115`, `000000135` and `000002677`; only `000000079` is currently in the consolidated construction catalog. The ledger records and audits SHA-256 values for `Enhancements.csv`, `Datasheets_enhancements.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`. Wahapedia Space Marines 11e App 2.8.1, observed 25 October 2026, agrees with the local cost, bearer restriction and melee Lethal Hits effect.

Focused enhancement/combat checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. A static Godot project-load check, JSON parse, source-row/mapping/hash audit and scoped whitespace check are recorded after completion of this increment. These checks establish project loading and source identity only; they do not establish gameplay correctness, visual acceptance, network behavior or army legality. No live-Godot capture was made because an enhanced attack was not staged in a match.


## Corporeum Reliquary — 25 October 2026

At its initial implementation, `Corporeum Reliquary` was admitted only for Librarian in Terminator Armour (`000000079`), because the other three current-reference profiles lacked the source IDs required by the source-restricted enhancement filter. During battle round 1, its living bearer lets the unit ingress in its own first Movement phase. The choice reuses reserve placement, coherency and battlefield-boundary validation; it does not create an opponent-turn Rapid Ingress choice. Deathwing Assault retains its separate Dark Angels eligibility gate.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Enhancement row `000011200003` maps to datasheets `000000079`, `000000115`, `000000135` and `000002677`; at the initial implementation only `000000079` carried a source ID in the profiles used by the eligibility filter. The follow-up below links all four. Wahapedia Space Marines 11e App 2.8.1, observed 25 October 2026, agrees with the local cost, Terminator bearer restriction and first-Movement-phase ingress effect. The ledger records SHA-256 values for `Enhancements.csv`, `Datasheets_enhancements.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`.

Focused ingress/enhancement checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static project loading, JSON validity, source-row/mapping/hash integrity and scoped whitespace checks are the only verification evidence; they do not establish gameplay behavior, visual acceptance, network behavior or army legality. No live-Godot capture was made because the round-1 ingress choice was not staged in a match.


## Merciless Veterans — 25 October 2026

`Merciless Veterans` is available for 1 CP in Terminator Storm Force when a friendly Adeptus Astartes Terminator unit is selected to shoot. Its ranged attacks gain Lethal Hits and Sustained Hits 1 for the Shooting phase. The attack declaration pauses for the use/pass decision, then resumes the same selected attack. The shared weapon-profile path applies the two keywords to ranged attacks only.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Stratagem row `000011201003` is the 1 CP Merciless Veterans entry. The ledger records SHA-256 values for `Stratagems.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`; the current Wahapedia Space Marines 11e App 2.8.1 page, observed 25 October 2026, agrees with the export's timing, eligibility and effect.

Focused stratagem/combat checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static project loading, JSON validity, source-row/hash integrity and scoped whitespace checks are the only verification evidence; they do not establish gameplay behavior, visual acceptance, network behavior or army legality. No live-Godot capture was made because the attack choice was not staged in a match.


## Tactical Dreadnought Fortitude — 25 October 2026

`Tactical Dreadnought Fortitude` is available for 2 CP in Terminator Storm Force when an enemy unit targets a friendly Adeptus Astartes Terminator unit in the opponent's Shooting or Fight phase. The target controller receives a use/pass choice before attack dice are rolled. If used, the selected unit's attacks from that declared enemy activation have Damage reduced by 1, minimum 1. The modifier is carried on the suspended declaration and applied through shared damage allocation, so it covers both ranged and melee attack activations and expires when that attack ends.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Stratagem row `000011201002` records the 2 CP Fortitude effect. The ledger records SHA-256 values for `Stratagems.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`; the current Wahapedia Space Marines 11e App 2.8.1 page, observed 25 October 2026, agrees with the export's timing, eligibility and effect.

Focused stratagem/combat checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static project loading, JSON validity, source-row/hash integrity and scoped whitespace checks are the only verification evidence; they do not establish gameplay behavior, visual acceptance, network behavior or army legality. No live-Godot capture was made because a Terminator Fortitude reaction was not staged in a match.


## Gunship Extraction — 25 October 2026

`Gunship Extraction` is available for 1 CP at the end of the opponent's Fight phase. It offers one friendly, unengaged Adeptus Astartes Terminator unit that is on the battlefield and places its living models in Strategic Reserves through the shared reserve state. The choice appears only for a selected Terminator Storm Force owner with an admitted reserve cost; the action removes the squad from the battlefield and deployment order.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Stratagem row `000011201004` records the 1 CP Gunship Extraction effect. The ledger records SHA-256 values for `Stratagems.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`; the current Wahapedia Space Marines 11e App 2.8.1 page, observed 25 October 2026, agrees with the export's timing, eligibility and effect.

Focused reserve/stratagem checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static project loading, JSON validity, source-row/hash integrity and scoped whitespace checks are the only verification evidence; they do not establish gameplay behavior, visual acceptance, network behavior or army legality. No live-Godot capture was made because a Gunship Extraction choice was not staged in a match.


## Gravis enhancement source mapping follow-up — 25 October 2026

Five current catalog profiles already carried the `GRAVIS` keyword and had exact relations in the local e11 export, but lacked the source datasheet IDs required by the source-restricted enhancement picker. Added those identities: Captain in Gravis Armour (`000001172`), Apothecary Biologis (`000000060`), Aggressor Squad (`000002099`), Eradicator Squad with Heavy Bolters (`000004231`) and Eradicator Squad with Melta Rifles (`000004249`). The existing picker can now offer `Immovable Conquerors` across seven export-matched current catalog identities: Apothecary Biologis, Inceptor Squad, Captain in Gravis Armour, Heavy Intercessor Squad, Aggressor Squad and both Eradicator Squad loadout profiles. The source relation excludes Iron Father Feirros and Tor Garadon. The picker also offers `Narthecis Gauntlet` to the Biologis and `Indefatigable Fortitude` / `Relentless Advance` to the Biologis and Captain in Gravis Armour. The Biologis and Captain in Gravis Armour also join the source-eligible `Ancient Weapons` choices. No new datasheet, enhancement effect or faction was added.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. All five profile IDs resolve to shared Space Marines book `000000139`; `Datasheets_keywords.csv` records `Gravis` for each, and `Datasheets_enhancements.csv` links each profile to its exact configured enhancement rows. Its exact `Immovable Conquerors` relation has ten datasheets, seven of which are current-catalog identities; it excludes Iron Father Feirros (`000000127`) and Tor Garadon (`000002473`) even though both are Gravis profiles. The runtime source list was corrected to the export's exact ten linked IDs. The source files `Datasheets.csv` (`39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`), `Datasheets_keywords.csv` (`bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341`) and `Datasheets_enhancements.csv` (`97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`) match the snapshot manifest.

Focused Gravis combat, healing, Scout and enhancement checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static source mapping, manifest hashes, project load, JSON validity and whitespace checks do not establish gameplay behavior, visual acceptance, network behavior or army legality.


## Terminator enhancement source mapping follow-up — 25 October 2026

The current catalog already contained Librarian, Chaplain, Captain and Ancient in Terminator Armour profiles, but three profiles lacked their source datasheet IDs. Added the local export book/datasheet identity to all three records. This makes the existing source-restricted eligibility recognize all four bearers for `Champion of the First Company` and `Corporeum Reliquary`, and also exposes their exact export-linked options in the existing Assault Brethren, Tactical Brethren, Devastator Brethren, Spearpoint Task Force and Wrath of the Rock enhancement records where source relations and rule keywords match. `Ancient Weapons` now intersects 15 current-catalog identities; `Deathwing Assault` remains limited to the four Terminator profiles whose local abilities include Deep Strike, with Ancient's missing shared-profile `DEATHWING` keyword still unresolved. No profiles were added and the consolidated catalog remains the only construction source.

The Data Export relation table links datasheets `000000079`, `000000115`, `000000135` and `000002677` to both enhancement rows `000011200002` and `000011200003`. The four source files used by the ledger (`Enhancements.csv`, `Datasheets_enhancements.csv`, `Datasheets_keywords.csv` and `Datasheets.csv`) match their manifest SHA-256 hashes in snapshot `20261021T130623Z`, revision `20260817b`. The Ancient in Terminator Armour profile still omits `DEATHWING`; this enhancement mapping uses its separately source-matched Adeptus Astartes and Terminator eligibility and does not close that profile-wide issue.

Focused enhancement checks and human playtesting remain pending. No gameplay tests were run because the user cannot test now. Static source mapping/hash review and project load do not establish gameplay behavior, visual acceptance, network behavior or army legality.


## Ancient source identity follow-up — 25 October 2026

The current catalog already contained Ancient (`000002775`) and Bladeguard Ancient (`000001165`), but their local profile records lacked source IDs. Added their exact shared Space Marines book/datasheet identities. This raises the current-catalog `Ancient Weapons` intersection from 17 to 19 and lets each profile use its exact export-linked `Imperium's Sword`, `Furious Assault`, `Laurels of Vigilance`, `Master-forged Firearms`, `Honour of Vigilance`, `Stormseer's Wisdom`, `Hunter's Eye` and `Spearpoint Paragon` options when that detachment is selected. Both identities also link to `Ancient Weapons`. The source link does not add the source-listed `DEATHWING` keyword to Bladeguard Ancient's shared profile; Bladeguard Ancient still lacks the local Deep Strike ability required by `Deathwing Assault`, so that enhancement remains limited to its four current Terminator bearers. Ancient in Terminator Armour retains its separate omitted-`DEATHWING` profile limitation.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. `Datasheets.csv` identifies the Ancient pair as `000002775` and `000001165` in book `000000139`; `Datasheets_enhancements.csv` links each to Ancient Weapons row `000010155005` and to the listed supported source-restricted enhancement rows. `Datasheets.csv`, `Datasheets_keywords.csv` and `Datasheets_enhancements.csv` match their manifest SHA-256 hashes. The ledger now records 19 current-catalog IDs for Ancient Weapons; the full optional ability-reference snapshot still has its separately recorded orphan and remains rejected.

Focused enhancement and melee checks and human playtesting remain pending; no gameplay tests or playtest were run because the user cannot test now. Static source mapping, manifest hashes, project load, JSON validity and whitespace checks do not establish gameplay behavior, visual acceptance, network behavior or army legality.


## Current-reference source mapping follow-up — 25 October 2026

The ten remaining current-reference Space Marine profiles now carry their exact shared-book and datasheet IDs from the local export: Infiltrator Squad (`000000128`), Lieutenant in Phobos Armour (`000002530`), Apothecary (`000002773`), Bladeguard Veteran Squad (`000000071`), Judiciar (`000002707`), Chaplain (`000001174`), Sternguard Veteran Squad (`000002255`), Eliminator Squad (`000001668`), Infernus Squad (`000000126`) and Hellblaster Squad (`000002098`). This closes the missing source-identity gap across all 77 records in the current-reference profile script. No profile stats, weapon facts, abilities or construction choices were added.

The source-restricted picker can now surface already implemented, exact export-linked choices. Infiltrator Squad, Bladeguard Veteran Squad, Sternguard Veteran Squad, Eliminator Squad, Infernus Squad and Hellblaster Squad gain `Furious Assault` when Assault Brethren is selected. Lieutenant in Phobos Armour, Apothecary, Judiciar and Chaplain gain their nine linked options: `Imperium's Sword` and `Furious Assault` (Assault Brethren); `Laurels of Vigilance` (Tactical Brethren); `Master-forged Firearms` and `Honour of Vigilance` (Devastator Brethren); `Stormseer's Wisdom`, `Hunter's Eye` and `Spearpoint Paragon` (Spearpoint Task Force); and `Ancient Weapons` (Wrath of the Rock). `Ancient Weapons` now intersects 23 current-catalog identities. Source linking only makes the existing picker recognize these options; it does not certify other abilities or full list legality. Although the source export lists `DEATHWING` for the two Ancient profiles, this remains a conditional Chapter adaptation and stays outside the shared baseline until contextual Chapter grants are implemented.

The Wahapedia 11e Data Export snapshot remains `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. All ten IDs resolve to shared book `000000139`, each has the local/export `ADEPTUS ASTARTES` keyword, and the exact export relations match the runtime enhancement source lists for all 42 newly available identity/option pairs. The complete 37-ID `Ancient Weapons` relation in `Datasheets_enhancements.csv` exactly matches the runtime source list; 23 IDs intersect the current-reference catalog. `Datasheets.csv`, `Datasheets_keywords.csv`, `Datasheets_enhancements.csv` and `Enhancements.csv` match their manifest SHA-256 values recorded in the ledger.

No automated tests or gameplay playtests were run because the user cannot test now. The source-row, relation, source-list and hash audits are read-only checks; they do not validate runtime behavior, presentation, network play or army legality. Focused local enhancement checks and human playtesting remain pending.

## Optional ability reference with an incomplete export — 25 October 2026

The local ability reader now keeps resolved Space Marines ability text available when an export relation points to a datasheet ID missing from `Datasheets.csv`. Each skipped relation is counted and up to three examples are shown in an amber warning before the source entries; the inspector states that displayed entries may omit abilities. Empty datasheet identities, invalid manifests, hash mismatches, malformed tables, unsupported metadata and unresolved required ability text still fail closed. Snapshot completeness is reported as false whenever a load error or incomplete-export warning exists.

The current local snapshot remains `20261021T130623Z`; record 5947 in `Datasheets_abilities.csv` is the known orphan for ID `000004150`. No raw export was changed, no rules engine behavior or datasheet certification changed, and the optional reader still cannot make a choice legal. The help text and packaged-build installation guide now explain the partial-reference warning.

This follow-up supersedes earlier entries in this report that described the optional reader as rejecting the entire snapshot: it now skips the orphan relation and displays resolved entries with the incomplete-export warning.

No automated tests or gameplay playtests were run because the user cannot test now. A headless capture of the staged Godot scene was attempted, but the scene runner remained blocked before saving an image and was stopped; no visual capture is available for this increment. Static project loading and source file/hash audit are the available checks; they do not establish runtime display, visual acceptance, network behavior or rules completeness.


## Per-player Chapter context — 25 October 2026

Prepared matches with current unit abilities enabled now accept a Chapter selection for each player or resolve context from current-reference Chapter faction keywords and the selected restricted detachment. Conflicting roster and selector identities fail admission. Dark Angels context adds the source-conditional `DEATHWING` and `RAVENWING` keywords to eligible current-reference Adeptus Astartes profiles so existing rule and datasheet views can inspect them. The context and raw selection are retained in saved setup and the match manifest, and LAN setup agreement compares the selections. This does not infer a Chapter from `DEATHWING` or `RAVENWING`, modify historical/unreconciled profiles, add catalog choices, or certify full army legality.

The selected model's in-match datasheet now shows its current keywords and separately labels `DEATHWING`/`RAVENWING` grants from Dark Angels context. This is a read-only presentation of the prepared state; it does not change roster admission or make any additional effect available.

The faction-page conditions were checked against Wahapedia Space Marines 11e App 2.8.1, observed 25 October 2026. Datasheet facts use the verified local Data Export snapshot `20261021T130623Z`, revision `20260817b`; the source identities and conditional keyword notes are recorded in `docs/wahapedia-keyword-context.json` and `docs/wahapedia-marines-slice.md`.

No tests or playtests were run because the user cannot test now. Focused context/admission checks, save/load and LAN behavior, plus a visible Godot review of the datasheet section remain pending. Any static load or source review performed for this increment is not evidence of runtime correctness or human acceptance.

## Darkflight Pursuit — 25 October 2026

Prepared matches now offer Darkflight Pursuit for each player. Its `Black-winged Vigilance` rule adds `Ignores Cover` to ranged attacks from current-reference Dark Angels `RAVENWING` `FLY` units, and grants `BATTLELINE` to current-reference Outrider Squads. The Chapter selector/context resolves Darkflight Pursuit to Dark Angels, rejects a conflicting selected or represented Chapter, and applies the existing conditional Ravenwing grant. Selecting the detachment enables current unit abilities because that is the runtime dependency for Chapter context. The rules effect is applied to copied attack profiles and per-match model keywords; shared datasheet profiles and other construction choices are unchanged.

The source is the Wahapedia Space Marines 11e App 2.8.1 faction page, observed 25 October 2026. Outrider Squad already maps to datasheet `000002712` in shared book `000000139` in local verified export snapshot `20261021T130623Z`, revision `20260817b`; `Datasheets.csv` SHA-256 is `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`. No datasheet facts or datasheet identities were added; Thundercowl Turbines is the new enhancement choice. The capability registry, detachment selector, current Chapter admission guide, support matrix, roadmap and rules ledger now identify the bounded implemented scope. Thundercowl Turbines is implemented for eight current-catalog identities; Skyborne Surveillance now offers +3 detection to visible enemy units within 6 inches after a Ravenwing FLY unit shoots, through the end of that Shooting phase. Nightforged Battery remains unavailable because Land Speeder Vengeance is outside the consolidated catalog.

No automated tests or playtests were run because the user cannot test now. Focused checks for ranged-only Ignores Cover, Ravenwing+FLY eligibility, Outrider BATTLELINE, conflicting Chapter rejection, per-player setup persistence/LAN agreement, and the detachment prerequisite remain pending. Network validation, human review of the setup screen and full army legality remain open.


## Thundercowl Turbines — 25 October 2026

Darkflight Pursuit now offers the 15-point `Thundercowl Turbines` enhancement for the eight export-linked identities present in the current-reference catalog: Chaplain on Bike, Captain on Bike, Storm Speeder Hammerstrike, Storm Speeder Hailstrike, Storm Speeder Thunderstrike, Land Speeder, Outrider Squad and Invader ATVs. The 19-row Data Export relation remains the source allowlist; unmapped identities do not become construction choices. The picker requires `FLY` or `MOUNTED`, and match-time eligibility also requires the selected Darkflight detachment, a living active bearer and `RAVENWING` in the prepared Dark Angels context.

During battle round 1, an eligible reserve unit can choose ingress in its own first Movement phase. The action uses the shared reserve placement preview, edge and enemy-distance limits, pre-round-3 deployment-zone rule and unit coherency checks. It does not grant opponent-phase Rapid Ingress. Export snapshot `20261021T130623Z`, revision `20260817b`, records enhancement row `000011095002`; `Enhancements.csv` SHA-256 is `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`, `Datasheets_enhancements.csv` is `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`, `Datasheets_keywords.csv` is `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341`, and `Datasheets.csv` is `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`.

No gameplay tests or playtests were run because the user cannot test now. Static project loading, ledger JSON parsing, local export/hash audit and whitespace checking are the available checks; they do not establish runtime behavior, multiplayer agreement, human acceptance or full army legality. Focused ingress/bearer checks remain pending.

## Wings of Shadow — 25 October 2026

Darkflight Pursuit now offers `Wings of Shadow` as a 1 CP defender reaction when an enemy declares ranged attacks against a friendly Ravenwing FLY or MOUNTED unit in the opponent's Shooting phase. The choice is presented before attack dice, applies Stealth for the rest of that phase and resumes the suspended declaration; Stealth uses the existing cover and Ignores Cover path. Nightforged Battery remains unavailable because its only bearer, Land Speeder Vengeance, is outside the consolidated construction catalog. Export row `000011096004` is recorded in snapshot `20261021T130623Z`, revision `20260817b`; `Stratagems.csv` SHA-256 is `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`. Wahapedia Space Marines App 2.8.1 and Core Rules Stealth 24.33 were checked on 25 October 2026.

No gameplay tests, playtests or in-game capture were run. The Godot project was statically loaded and `git diff --check` passed; the feature remains `implemented_local_checks_pending`.

## We Are Vengeance — 25 October 2026

Darkflight Pursuit now offers `We Are Vengeance` for 1 CP once per phase after an enemy shooting activation in the opponent's Shooting phase targets a friendly, unengaged Ravenwing FLY unit. The defender chooses an eligible surviving target, rolls D3+3 with the host dice provider, then previews and confirms a Normal Move through the shared response placement flow. The pending attack frame remains suspended through the choice and placement; the reaction nests over other post-shot choices so their continuation is retained. Eligibility requires the current Darkflight Pursuit and Dark Angels Chapter context.

The local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. `Stratagems.csv` row `000011096003` records the timing and effect; the file SHA-256 is `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`. Wahapedia Space Marines 11e App 2.8.1 was checked on 25 October 2026.

No gameplay tests, playtests or in-game capture were run. Focused checks for eligible target timing, once-per-phase use, CP payment, D3+3 bounds, post-shot frame continuation and legal Normal Move placement remain pending; network validation and full army legality remain uncertified.

## Skyborne Surveillance — 25 October 2026

Darkflight Pursuit now offers `Skyborne Surveillance` for 1 CP immediately after a friendly Ravenwing FLY unit shoots in its owner's Shooting phase. The player may pass or use it once per phase. At use, the shared visibility and terrain geometry identifies enemy units visible to at least one model in the Ravenwing unit and within 6 inches of any of its models. Those enemy units receive +3 detection range through the end of that Shooting phase, following Core Rules 01.02.02 for a Shooting-phase-triggered effect with no stated duration. The effect flows through the shared detection calculation, so multiple separate detection modifiers remain additive.

The verified local Wahapedia 11e Data Export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`. Stratagem row `000011096002` contains the timing and +3 detection effect; `Stratagems.csv` SHA-256 is `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`. Wahapedia Space Marines 11e App 2.8.1 and Core Rules 01.02.02 were checked on 25 October 2026.

No gameplay tests, playtests or in-game capture were run because the user cannot test now. Focused checks for post-shot timing, the one-use-per-phase rule, visible/range boundaries, target mark expiry and detection stacking remain pending; network validation and full army legality remain uncertified. Static project load with `.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` exited 0. The local export row/hash and ledger JSON audit passed. `git diff --check` exited 0 with line-ending conversion notices only; none of these checks establishes gameplay behavior.

## Nightforged Battery — 25 October 2026

The 10-point Darkflight Pursuit enhancement now has runtime choices on the Land Speeder Vengeance profile only. During attack generation, its owner can keep or re-roll the D6 determining the weapon's random Attack characteristic. Before Hazard mortal wounds are allocated, the owner can re-roll each Hazard die at most once, then accept the result or use an otherwise eligible Command Re-roll on a different die. The decisions use the existing serialized attack checkpoint and Hazard continuation; the enhancement remains unavailable in construction because the Vengeance profile is still held out pending focused local checks.

Source: verified Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, revision `20260817b`; enhancement row `000011095003` is related to Dark Angels App datasheet `000000242`. `Enhancements.csv` SHA-256 is `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`; `Datasheets_enhancements.csv` is `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`; `Datasheets.csv` is `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`.

No gameplay tests, playtests or in-game capture were run because the user cannot test now. Focused checks for source eligibility, Attack characteristic replacement, repeated Hazard choices, interaction with Command Re-roll, wound allocation, serialized continuation and disabled unit abilities remain pending. Network validation and full Dark Angels army legality remain uncertified.

## Multiline ability-reference preservation — 26 October 2026

The optional local ability reader now preserves empty physical lines inside a pending multiline field. Previously its blank-line cleanup could remove source text while joining a multiline record. Blank lines between records remain ignored. The current `20261021T130623Z` `Datasheets_abilities.csv` has no interior blank physical lines; this is a parser-integrity correction for multiline exports, not a change to the stored source or match rules.

No tests, playtests or in-game capture were run because the user cannot test now. Code inspection and a read-only line-shape audit of the local source file are the available evidence; the correction remains pending focused parser verification.

## Wrath of the Lion — 26 October 2026

Inner Circle Task Force now offers `Wrath of the Lion` after a friendly DEATHWING unit ends a Charge move. The player chooses one engaged enemy unit, rolls one D6 per friendly model in Engagement Range, and inflicts one mortal wound on each 3+, capped at six. The choice shares the post-charge decision, applies the normal CP discount and once-per-phase stratagem gate, and sends wounds through defender allocation and mortal-wound prevention. Eligibility requires the selected Inner Circle Task Force, Dark Angels Chapter context and the unit's current DEATHWING keyword. Once the effect is resolved or skipped, the same charge continuation opens Tank Shock when the unit remains eligible.

The Wahapedia Space Marines 11e faction page, App 2.8.1, was observed on 26 October 2026. Verified local export snapshot `20261021T130623Z`, revision `20260817b`, contains stratagem row `000008775004`; `Stratagems.csv` SHA-256 is `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`. The detachment's `UNIQUE: TERMINATOR` metadata was not used as an extra target restriction; the stratagem target is the charged DEATHWING unit.

No tests, playtests or in-game capture were run because the user cannot test now. Focused checks for target eligibility, charge timing, CP/discount and once-per-phase limits, the six-wound cap, defender allocation/prevention, Tank Shock handoff and persisted continuation remain pending. Network validation and full Dark Angels army legality remain uncertified.



## Medusa's Wrath enhancement: The Flesh is Weak — 26 October 2026

Added the 15-point enhancement from the exact local export relation. It is selectable for 23 source-linked current-catalog identities; the living bearer model gains +1 Toughness and Feel No Pain 5+ against any wound through the existing defender-profile and per-model prevention paths. Attached units retain the existing rule for resolving unit Toughness from surviving Bodyguard models. Wahapedia Space Marines App 2.8.1 was observed on 26 October 2026. Local snapshot `20261021T130623Z`, revision `20260817b`, maps row `000011180005` to 37 datasheets; the three source file hashes are recorded in the rules ledger.

No tests, Godot session or capture were made because testing is unavailable. Focused local checks, visual review and human acceptance remain pending; network validation and full army legality are uncertified.

## Medusa's Wrath enhancement: Target Augury Web — 26 October 2026

Added the 30-point enhancement for the current-catalog Techmarine profile. At the start or end of the bearer unit's Movement-phase move, the player may select one friendly Adeptus Astartes Vehicle model within 3 inches of any model in the Techmarine's unit. The selected Vehicle model gains Lethal Hits for ranged and melee attacks until the owner's next Command phase. The effect follows that model through the per-model attack profile, and its selection card reports the active duration; the start choice must be resolved or declined before movement is confirmed, and the end choice suspends the movement continuation.

The verified local export row is `000011180002` in snapshot `20261021T130623Z`, revision `20260817b`, retrieved `2026-10-21T19:46:58Z`. It links to datasheets `000000140` (Techmarine) and `000000306` (Iron Priest); only Techmarine is present in the current consolidated catalog. `Enhancements.csv`, `Datasheets_enhancements.csv` and `Datasheets.csv` hashes are recorded in the rules ledger. Wahapedia Space Marines App 2.8.1 was observed on 26 October 2026.

No tests, Godot session or capture were made because the user cannot test now. Focused checks for start/end timing, unit-range measurement, per-model attack scope, expiry at the next Command phase and movement-frame continuation remain pending. Network validation, visual review and full army legality remain pending.

## Medusa's Wrath enhancement: Master of the Machine War — 26 October 2026

Added the 25-point enhancement for 23 source-linked current-catalog bearer profiles. In the owner's Movement phase, the bearer selects one visible friendly Adeptus Astartes Vehicle within 6 inches and chooses Devastator or Tactical Doctrine for that unit until the start of the owner's next Command phase. The selected doctrine enters the shared per-unit doctrine query and its selection uses the existing once-per-battle doctrine ledger. The action is available in the active owner's Movement phase and the selected Vehicle's model card reports the doctrine and expiry.

The verified local export row is `000011180004` in snapshot `20261021T130623Z`, revision `20260817b`, retrieved `2026-10-21T19:46:58Z`; it links to 37 source datasheets, 23 of which resolve to the current consolidated catalog. Wahapedia Space Marines App 2.8.1 was observed on 26 October 2026. Source file hashes are recorded in the rules ledger.

No tests, Godot session or capture were made because the user cannot test now. Focused checks for target eligibility, visibility and range, doctrine availability/usage accounting, interaction with an active army doctrine, expiry at the next Command phase, save/load and player feedback remain pending. Network validation and full army legality remain uncertified.

## Medusa's Wrath enhancement: Adept of the Omnissiah — 26 October 2026

Added the 25-point enhancement for the current-catalog Techmarine. Once per battle round per army, when an enemy unit targets a friendly Adeptus Astartes Vehicle within 6 inches of the bearer unit, the defender may grant Feel No Pain 5+ against that attacker's damage until the attack resolution completes. The choice is persisted in both Shooting and Fight attack declarations, binds the effect to that attacker and target, and forces use of the shared damage-allocation and prevention path. The Vehicle card reports the temporary protection.

The local export row is `000011180003` in snapshot `20261021T130623Z`, revision `20260817b`; it links to Techmarine `000000140` and Iron Priest `000000306`, but only Techmarine resolves to the current consolidated catalog. Source hashes are recorded in the [rules ledger](../space-marines-rules-ledger.json). Wahapedia Space Marines App 2.8.1 was observed on 26 October 2026.

No tests, Godot session or capture were made because testing is unavailable. Focused checks for once-per-round accounting, unit-range measurement, optional use/pass, multi-target attacks, Shooting/Fight timing, effect expiry and persisted resolution remain pending. Network validation and full army legality are uncertified.

## Optional ability-reference identity boundary — 26 October 2026

The static source-reader audit found that a datasheet link was previously reduced to its final path segment without checking its host or faction route. Identity links now must use the canonical HTTPS Wahapedia 11e Space Marines path and one URL-safe slug before they can index ability text; an invalid link reports the datasheet ID. This keeps an off-source or malformed link from being presented as a verified Space Marines identity; source files and match rules are unchanged. The existing external-first `user://` loading and explicit invalid-installation behavior remain in place.

No tests, Godot session or capture were run because testing is unavailable. The verified local snapshot's 193 Space Marines links were checked read-only and all match the accepted URL shape. Runtime parser behavior, reload interaction and exported-pack behavior remain pending verification.

## Optional ability-reference timestamp validation — 26 October 2026

The local reader now validates the calendar and clock fields in `retrieved_at_utc` and timestamp-shaped snapshot folder IDs, including leap years. Impossible dates or times fail with an explicit source error instead of being accepted as provenance or used to choose the newest timestamp snapshot. This tightens metadata validation only; it does not change source files, match rules or installed snapshots.

No tests, Godot session or capture were run because testing is unavailable. Static code inspection is the only evidence for this correction; focused parser verification remains pending.

## Combat tray viewport containment — 26 October 2026

The combat tray now caps its height to the available board area. Its optional stage selector, dice, and die details live in a vertical scroll region; the attack summary and presentation controls stay outside that region. This keeps the recorded result and skip/replay controls reachable when the tray would otherwise exceed the viewport. No combat rules or match state changed.

No tests, Godot session, capture or viewport review were run because testing is unavailable. Static inspection is the only evidence for this layout change; fit and control reachability at 1024×768 and 1280×800 remain pending visual review.

## Weapon glossary coverage — 26 October 2026

The contextual weapon glossary now has definitions for all 25 keyword IDs in `AttackSequence.SUPPORTED_KEYWORDS`, plus the existing Lance entry handled by the attack planner before that sequence. New entries include Anti-Infantry, Anti-Character, Anti-NON-MONSTER/VEHICLE, Cleave, Indirect Fire, Melta, One Shot and Psychic. Numeric Anti-X, Cleave and Melta values are inserted into the selected-profile explanations. These entries summarize the source terms; they do not enable effects that the match runtime does not support.

Source: [Wahapedia's current 11th-edition Core Rules page](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), checked 26 October 2026; it identifies the June 2026 Core Rules. New summaries use §§24.03, 24.06, 24.19, 24.25–24.26 and 24.29. The weapon validator's accepted keyword IDs were compared statically with the glossary keys. No tests, Godot session or capture were run; glossary length, keyboard navigation and fit in the Guide and Help panels remain pending visual and input review.

## Remappable keyboard controls — 26 October 2026

Settings now stages remappable bindings for Datasheet inspection, Focus and four camera-pan directions. Capture rejects modified/reserved keys; choosing a key assigned to another listed action swaps the pair, and Escape cancels. Apply activates and saves the staged bindings, while Revert restores the last applied set. A scrollable settings body keeps Apply/Revert reachable. Combat HUD and contextual controls show the active keys; the Guide directs players to Settings for the current bindings.

No tests, Godot session or capture were run because testing is unavailable. Static source review is the available evidence; key capture, Apply/Revert persistence, keyboard/gamepad navigation and layout at 1024×768 and 1280×800 remain pending.

## Invalid keyboard preference recovery — 26 October 2026

If saved key bindings are malformed, duplicated or conflict with another control, startup loads the defaults and Settings explains the fallback. Applying a valid binding set saves the corrected preferences and clears the warning; Revert keeps the fallback warning visible. Older settings files without a controls section continue to receive the defaults without a warning.

No tests or Godot interaction were run because testing is unavailable. Static inspection is the available evidence; corrupted preference recovery and warning persistence remain pending focused verification.

## Explicit unsupported source-entity handling — 26 October 2026

The optional ability reader now converts entity text in ability names, descriptions and context fields before display. If an entity remains unresolved, the snapshot fails with the relation record and datasheet ID instead of showing partial or raw entity text. A read-only scan of the verified `20261021T130623Z` snapshot found no named HTML entity outside the reader mapping; the source data was not changed.

No tests or Godot interaction were run because testing is unavailable. Static source review and the entity scan are the available evidence; parser regression coverage and rendered reference text remain pending.

## Keyboard shortcut priority for focused selectors — 26 October 2026

Camera pan, Focus and Datasheet shortcuts now yield while text entry, an option picker, Tree or ItemList has keyboard focus. This prevents a camera binding or inspection shortcut from competing with a focused gameplay selector; ordinary HUD buttons retain their existing shortcut behavior.

No tests or Godot interaction were run because testing is unavailable. Static source inspection is the available evidence; keyboard focus behavior in active gameplay selectors and the documented navigation path remain pending verification.

## Direct keyboard binding swaps — 26 October 2026

Changing a binding to a key used by another listed action now swaps the two staged keys. The Settings note and capture notice explain the behavior; reserved UI keys remain blocked and external conflicts remain errors. Apply/Revert semantics are unchanged.

No tests or Godot interaction were run because testing is unavailable. Static inspection is the available evidence; swap capture, collision handling, persistence and navigation remain pending verification.

## Recorded attack context clarity — 26 October 2026

The combat tray now labels completed attack summaries with the attacking unit(s), weapon and target. During an optional attack roll decision, it resolves the context from the pending attack so a defender-owned re-roll still reads as attacker → weapon → target rather than repeating the defending unit. This is display-only and does not alter decisions or roll results.

No tests, Godot session or capture were run because testing is unavailable. Static inspection is the available evidence; attacker lookup, long-name layout, stage ownership and local/network presentation remain pending verification.

## Datasheet keyboard scrolling — 26 October 2026

The match-profile inspector now receives focus when opened and handles Page Up/Down and Home/End while the inspector or one of its controls has focus. The visible hint lists these keys; Escape continues to close the overlay through the existing global `ui_cancel` path. Arrow keys remain available for focus navigation.

No tests, Godot interaction or capture were run because testing is unavailable. Initial focus, keyboard scrolling with the source foldout expanded and collapsed, focus restoration after close, and fit at 1024×768, 1280×800 and 1920×1080 remain pending.

## Optional source status on the collapsed foldout — 26 October 2026

The datasheet reference toggle now retains its integrity state when collapsed. It pairs the entry count with `incomplete`, or labels a source status as `unavailable` or `error`. The project snapshot's orphan ability relation continues to show its resolved entries with the explicit warning that entries may omit abilities; collapsing the list no longer removes the status cue. This is presentation-only and does not change the source, match state or rules.

No tests, Godot interaction or capture were run because testing is unavailable. Static code inspection is the available evidence; label fit at the target resolutions, screen-reader phrasing and fold/unfold behavior remain pending in-engine review.

## Duty is Never Done for Gauntlet Task Force — 26 October 2026

The Fight-phase end window now offers Duty is Never Done (1 CP) when a friendly ADEPTUS ASTARTES INFANTRY unit was eligible to fight this phase, is unengaged, and every living model is within 6 inches of a friendly Transport it can embark within. Transport profile keywords and remaining capacity are checked separately from the stratagem's wholly-within 6-inch range. After the shared stratagem gate validates the use and spends CP, all living passenger models enter the Transport through the shared transport state path. The shared gate retains CP discounts, once-per-phase use and one-stratagem-per-unit limits.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`, row `000011185003`. `Stratagems.csv` SHA-256: `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; network validation is deferred and full army legality remains uncertified.

## Aggressive Disembarkation for Gauntlet Task Force — 26 October 2026

The supported Movement-phase disembark choices now offer Aggressive Disembarkation for 1 CP. Each model may be placed within, instead of wholly within, the selected mode's set-up distance. Tactical-mode availability also checks whether the relaxed placement makes a legal setup possible. Ordinary disembarks now require each model to be wholly within range; mode, Engagement Range, coherency, Hazard, ingress and post-move restrictions remain enforced. The shared stratagem gate applies current CP discounts, once-per-phase use and one use per target unit.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`, row `000011185002`. `Stratagems.csv` SHA-256: `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`. Core placement wording follows Core Rules §18 Transports.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; out-of-phase selection is unimplemented, and any emergency-disembark interaction remains unverified. Network validation is deferred and full army legality remains uncertified.

## Tactical Withdrawal for Phobos Shadow Force — 26 October 2026

At the end of the opponent's Fight phase, the new partial Phobos Shadow Force selector offers Tactical Withdrawal (1 CP) for one unengaged friendly PHOBOS or SCOUT SQUAD unit. The selected unit must have an admitted reserve cost and every living model on the battlefield. On use, the match records it in Strategic Reserves, removes its living models from the battlefield and removes it from the deployment order; the existing ingress rules handle a later return. The shared stratagem gate retains CP discounts and once-per-phase/unit limits.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`, row `000011189004`. `Stratagems.csv` SHA-256: `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.

No tests or Godot interaction were run because testing is unavailable. Shadow Masters, enhancements, Mortis Snares and Strike from the Shadows remain unimplemented; focused local checks and human playtesting are pending. Network validation is deferred and full army legality remains uncertified.

## Strike from the Shadows for Phobos Shadow Force — 26 October 2026

Phobos Shadow Force now uses the existing persisted attack-declaration window for Strike from the Shadows. When a friendly hidden PHOBOS unit is selected to attack in Shooting or Fight, its owner can spend 1 CP; the attack gains +1 Strength and Lethal Hits through the shared weapon-profile path. The declaration remains available as use or pass, and the local Hidden check requires every living model to pass. This entry has its own capability and detachment gate, separate from the identical Phobos Shock Force stratagem.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`, row `000011189002`. `Stratagems.csv` SHA-256: `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.

No tests or Godot interaction were run because testing is unavailable. Shadow Masters, enhancements and Mortis Snares remain unimplemented; focused local checks and human playtesting are pending. Network validation is deferred and full army legality remains uncertified.

## Mortis Snares for Phobos Shadow Force — 26 October 2026

Mortis Snares is now selectable at the end of your Movement phase for an eligible unengaged friendly PHOBOS or SCOUT SQUAD unit. The local implementation arms each objective the selected unit currently controls. When an enemy unit ends a move within range of a snared objective, the snare is consumed and the snare owner resolves a persisted D6 trigger roll; on 2+, a separate persisted D6 sets mortal wounds against the moving unit. The defender allocates through shared mortal-wound prevention and Deadly Demise handling. The handler is connected to Normal/Advance/Fall Back and Charge/contact-move completion; reserve setup does not trigger it. Trigger, damage and allocation windows preserve the movement action's nested reaction chain.

The Wahapedia rule names no roller, so this implementation assigns both dice to the snare owner. Its singular “that objective” wording is implemented as every objective controlled by the selected unit; this multi-objective interpretation and ordering against other post-move reactions need focused review.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, specification revision `20260817b`, row `000011189003`. `Stratagems.csv` SHA-256: `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; network validation is deferred and full army legality remains uncertified.

## Shadow Masters for Phobos Shadow Force — 26 October 2026

Shadow Masters now opens a persisted post-shot choice for an eligible PHOBOS or SCOUT SQUAD unit in its owner's Shooting phase. The player can mark the attacks as preserving Hidden eligibility for the current turn, which the shared Hidden query honors, or choose a D6-inch Normal Move through the existing per-model placement, terrain and coherency path. Completing the move records normal movement and prevents the unit from declaring a Charge for the rest of that turn. Nested post-shot choices resume through the existing window stack.

Source checked against Wahapedia Space Marines 11e App 2.8.1 (October 2026), observed 26 October 2026: [Phobos Shadow Force, Shadow Masters](https://wahapedia.ru/wh40k11ed/factions/space-marines/). The text does not name a phase; the local implementation is bounded to the owner's Shooting phase. Out-of-phase shooting, focused local checks and interaction with later same-turn Hidden checks require review.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; network validation is deferred and full army legality remains uncertified.

## Venator Omni-auspex for Phobos Shadow Force — 26 October 2026

Phobos Shadow Force now admits its own Venator Omni-auspex source entry (15 points, export row `000011188002`) through a distinct capability gate. The verified export links it to the same four current-catalog PHOBOS bearers as the Phobos Shock Force version: Lieutenant with Combi-weapon, Librarian in Phobos Armour, Lieutenant in Phobos Armour and Captain in Phobos Armour. The shared attack planner applies the existing hidden-target Wound reroll behavior; in Assault Doctrine it also presents successful natural 2s as optional free reroll choices at the persisted Wound checkpoint. The detachment-specific rule text/source identity remains distinct while both versions reuse the same combat resolution.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`. `Enhancements.csv` SHA-256: `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`; `Datasheets_enhancements.csv` SHA-256: `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; network validation is deferred and full army legality remains uncertified.

## Execute and Redeploy for Phobos Shadow Force — 26 October 2026

Execute and Redeploy (25 points, export row `000011188003`) is now selectable for four source-linked PHOBOS bearers. After its unit shoots in its own Shooting phase while unengaged, the player can choose a Normal Move up to 6 inches; using it blocks Charge until turn end. Its persisted use/pass choice follows Shadow Masters, and the move shares the board placement preview, terrain and coherency rules. Core Rules §09.05.01 allows only one Normal Move in a phase: when Shadow Masters already moved the unit, Execute and Redeploy remains passable but cannot be used. The runtime records the phase's Normal Move so the shared Tactical Fluidity option is suppressed as well.

Source checked against Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026, and local Data Export snapshot `20261021T130623Z`, revision `20260817b`, row `000011188003`. `Enhancements.csv` SHA-256: `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`; `Datasheets_enhancements.csv` SHA-256: `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.

No tests or Godot interaction were run because testing is unavailable. Focused local checks and human playtesting remain pending; network validation is deferred and full army legality remains uncertified.

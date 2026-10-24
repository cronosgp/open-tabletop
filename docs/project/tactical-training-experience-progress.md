# Tactical training experience correction progress

Updated 24 October 2026. The implementation candidate has passed the scoped local, bounded loopback and PCK checks recorded below. Human acceptance is still open. This report follows the [experience plan](tactical-training-experience-plan.md) and [UX audit](tactical-training-ux-audit.md).

## Findings and changes

| Reported issue | Finding | Implemented correction |
|---|---|---|
| Missing defender choice | Guided launch explicitly disabled manual allocation. | New tactical training enables the existing defender allocation path. Saved match options are preserved; no allocation timing or eligibility rule was changed. |
| Apparently mandatory Command Re-roll | The Keep button forwarded the selected replacement die. The normalized pass option requires no selected die, so the command was rejected. | Keeping now submits die `-1`; selecting a replacement die is reserved for re-rolls. Keep is visible before the die picker, has keyboard focus on entry and states its zero CP cost. The tactical lifecycle regression now presses the actual Keep button. |
| Hidden optional ability pass | Some passes and free re-roll keep actions were only available inside the choice picker. | An explicit neutral button submits an existing legal pass/keep option through the same normalized command path. It never invents a pass for a mandatory choice. |
| Confusing opening/help | General reference preceded the current guide, and the compact HUD could clip its rightmost controls. | Current guidance leads Help; experiments and rule terms are collapsible. Narrow HUDs split phase/score and tools into separate rows. Command and board regions respect the actual header height. Both players' CP are visible. |
| Distant movement rejection | Movement validation already returned an error, but the main feedback was a text notice. | The same domain reason appears in a clamped label above the miniature and in the command panel. Existing destination/path guides remain advisory. The distance rejection now states requested and remaining movement. Final placement/coherency failures use the same feedback surface. |
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

The playtest launcher and record validator now explicitly include the six experience-correction observations (opening/controls, optional Keep and paid cost, defender recipient, local movement recovery, attack explanation, and pacing/symbols/motion). Previously their required table covered only the earlier tactical baseline; that table could not prove acceptance of these corrections. Existing records without the new observations remain incomplete for this candidate. No human outcome was filled by the agent.

Tool validation: `python -m unittest discover -s tests -p test_verification.py` passed **28 tests**. The launcher/validator checks now reject a missing correction observation and keep an unobserved reroll gate open. `pwsh -NoProfile -File ./tools/run_tactical_playtest.ps1 -Godot './.tools/intentionally-missing-playtest-preflight.exe'` created `.tools/playtest-20261024-132045266/tactical-training-session.md` and returned the expected **2** for the deliberately missing executable. `python tools/validate_tactical_playtest.py .tools/playtest-20261024-132037979/tactical-training-session.md` returned **2** for the generated blank record, listing all 16 missing outcomes. These are tooling preflight checks, not a launched or completed human session; no Godot runtime changed in this refinement.

- Repeat the human tasks in the [playtest procedure](../verification/tactical-training-playtest.md): explain who decides, keep a result, choose a legal non-default recipient, correct an invalid move, and explain why models were destroyed. Record hesitation and comprehension, including whether normal combat pacing feels satisfying.
- Review icon recognition, sound level and motion comfort with the player. These are design hypotheses, not achieved quality scores.
- Broader Marine networking, graphical inspection of the remote client, separate-machine LAN, remote CI and native builds remain distinct verification boundaries.

No general rules, faction, army-legality or platform certification follows from this UX correction.

The Command doctrine follow-up was packaged with `python tools/build_demo.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300`: all five stages passed at `.tools/verification/build-20261024T170716525024Z/results.json`. The updated PCK is `.tools/verification/build-20261024T170716525024Z/open-tabletop-demo.pck`, SHA-256 `14f2f69504037fbf55be5ff099d68473d467a90444f1051be9089faff040284a`. The earlier build at `build-20261024T170548080962Z` passed before the final grouped-placement input guard refinement and is superseded. The updated candidate manifest identifies the new artifact; human acceptance remains pending.

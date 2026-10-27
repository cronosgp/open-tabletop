# Tactical training playtest record

Status: the user reported a human playtest on 24 October 2026, identifying guide/layout, clarity, allocation, reroll, movement-feedback and combat-pacing problems. No structured build/viewport/session record was supplied. The [experience correction](../project/tactical-training-experience-progress.md) addresses that report; a new human acceptance session remains pending. Automated agents and controlled test dice are not human comprehension evidence.

## Preflight evidence — 24 October 2026

The current local candidate has a distinct `marine-tactical-training-v1` scenario with Fire and Manoeuvre versus Close Assault, four optional experiments, a persisted `PROGRESS: n / 4 observed` checklist with a `DONE = observed • OPEN = available` legend, a phase-aware Help cue and live legal-opportunity cues for leader abilities, CP stratagems and Bladeguard stances. The title screen shows both catalog-derived totals, summarizes incompatible saves with a recovery action and focuses the first valid primary command for keyboard/gamepad navigation. Actual Godot/OpenGL captures were inspected at 1280×800 and 1024×768 in `.tools/tactical-title-*.png`, `.tools/tactical-preparation-*.png`, `.tools/tactical-experiments-*.png`, `.tools/tactical-opportunity-*.png` and `.tools/tactical-bladeguard-*.png`; the latter shows `READY NOW` for a real Bladeguard stance choice.

The legend and 0/4 initial state are covered by the focused headless UI regression; the stored captures above remain layout and opportunity evidence, not human-comprehension evidence.

The local evidence that should accompany a session record is `.tools/verification/20261024T064117338648Z/results.json` (latest focused tactical/UI recheck, 5/5), `.tools/verification/20261024T075744731933Z/results.json` (current-catalog tactical lifecycle, experiment progress/legend and integrated combat, 4/4), `.tools/verification/20261024T060650663369Z/results.json` (layout, focus, independent Leader/CP/combined/Bladeguard opportunity assertions and no-false-positive preparation check, 5/5), `.tools/verification/20261024T080319927934Z/results.json` (latest demo with loopback, 13/13), `.tools/verification/20261024T075949863687Z/results.json` (latest mirror and tactical host/client re-audit, 6/6, including experiment-tracker snapshot checkpoints), `.tools/verification/build-20261024T080456779917Z/results.json` (latest clean-tree and exported-pack tactical smoke, title/guide surface, plus import/export/startup) and `.tools/verification/20261024T044319660501Z/results.json` (earlier isolated loopback, 4/4). These prove runtime, packaged startup and presentation preparation only; they do not fill the human, separate-machine LAN, remote-CI or native-platform fields below.

## Launching the local session

On Windows, launch the project with the pinned graphical Godot executable from the project root:

```powershell
& .tools/godot/Godot_v4.7.2-stable_win64.exe --path .
```

For a repeatable shared-computer session, the repository also provides a launcher that isolates `user://` data and creates a blank session record:

```powershell
& .\tools\run_tactical_playtest.ps1
```

The launcher does not automate play, collect telemetry or download content. It leaves the generated profile and record under `.tools/playtest-<timestamp>/` so the participants can fill the observations after closing the game.

If the pinned Godot executable is unavailable, the launcher still writes the metadata record, prints the missing-path error and exits with code `2`; this is an environment preflight failure, not a playtest result.

After the session, validate the filled record with `python tools/validate_tactical_playtest.py PATH_TO_RECORD`. Every gate must contain an outcome and a concrete note; placeholder notes such as `observed`, `ok` or `done` are rejected. Exit code `0` means every declared gate is `pass` for that session only. Exit code `2` means the record is incomplete or malformed; exit code `3` means it is structurally complete but contains `partial`, `blocked` or `not observed` outcomes. Neither result certifies rules accuracy or general product readiness.

Use a shared computer for this gate, with two participants alternating control. Set the window to 1280×800 or 1024×768, select **Start tactical training**, keep the default equipment and complete both intended Leader attachments. Do not use the controlled capture scripts or test-only dice as a substitute for this session. The project-owned scenario uses local data and placeholder visuals; it does not require downloads.

## Session

Use the [tactical training configuration](../guides/tactical-training.md), default equipment and both intended Leader attachments. Two people may share one computer and alternate control in the local scenario. A connected session is a separate network gate and must record whether it uses loopback or two actual machines.

Record the date, code revision or verification snapshot, Godot version, operating systems, window sizes, participating player experience, side assignment, and local/shared-computer or connected mode. Record interruptions and assistance. Do not collect personal identifiers or use a telemetry service.

The launcher pre-fills the code revision, working-tree state and scenario identity. For each gate, use `pass`, `partial`, `blocked` or `not observed`, then add the concrete evidence or assistance in the notes. A legal opportunity that never appears is `not observed`, not a failure of the player and not a passed feature.

## Tasks to observe

1. From the title screen, identify each force, its model counts and points, the side-swap option and the training limits.
2. Start training, declare each Warlord, attach the Captain to Intercessors and the Chaplain to Assault Intercessors, then finish preparation with default equipment.
3. Deploy both armies using legal placement or the suggested preview. Check that each player can identify the next unit and confirm it.
4. Play freely through five rounds. Observe whether players can find a Leader ability, compare a Hellblaster firing profile, use or decline an eligible stratagem, and understand a Bladeguard stance when its legal window appears. Ask them to use the Help checklist to identify which experiment categories have actually been observed; a line marked `OPEN` or `IN PROGRESS` must not be treated as completed. At End of Turn, if an incoherent unit occurs, observe whether the player understands the required casualty choice and why phase progression is locked. Do not force a particular roll or grant CP to manufacture an opportunity. Record absent opportunities explicitly.
5. Ask each participant, at an actual decision, to identify the round/phase, active player, current decision owner, target, CP cost and next action. Observe their answer before providing help.
6. Save during a pending decision and resume. Record whether the owner, choices, phase and next step remain understandable, and whether the player's intended action can continue.
7. Inspect the final result and a recorded attack in the battle log. Ask players to explain which displayed dice have already resolved.

## Observation record

### Experience correction acceptance

The session record now includes six additional required observations from the [correction plan](../project/tactical-training-experience-plan.md). Earlier baseline records without these observations do not establish acceptance of the corrected experience. Record the actual window size and UI scale, participant experience and side assignment without personal identifiers.

1. Start a **new** tactical session and identify the current instruction and next action. Check opening and Help for clipping, including required controls. Saved sessions retain their original allocation settings.
2. At a legal optional roll window, keep the result and verify no CP was spent. At another legal opportunity, deliberately use Command Re-roll and explain the cost and mandatory replacement. Do not equate declining with rerolling.
3. As defender, identify eligible recipients, select a non-default model where a legal alternative exists and explain any mandatory recipient restriction. Explain the selected model's remaining wounds and destruction when applicable.
4. Attempt an invalid movement destination, explain the local rejection reason and correct it without consulting the history. Record whether the attempted destination and recovery remain understandable.
5. Watch an attack and explain the displayed hits, wounds, saves, damage and destroyed models. Distinguish remaining model wounds from successful wound rolls and fixed damage from rolled damage.
6. Compare Normal/Fast pacing, Skip and Reduced motion while retaining all decisions. Record whether combat is still too quick or hidden, symbols are recognizable, and sound/motion are comfortable. A technically available control does not establish comfortable pacing.

Observe answers before helping. Record hesitation, incorrect assumptions and assistance. If no legal opportunity appears, mark it `not observed`; do not fabricate a passing result or modify dice/state to create one. The record validator checks field completeness and declared outcomes only; the participant's observations remain the acceptance evidence.

| Observation | Result to record |
|---|---|
| Starting the match | Completed unaided / assistance required / blocked; location and cause |
| Setup and deployment | Decisions understood, incorrect selections, recovery and assistance |
| Abilities and stratagems | Offered opportunity, discovery, understood cost/effect, use or pass |
| End-of-Turn coherency | Required casualty identified, ownership understood, phase lock explained, recovery completed |
| Turn flow | Turn durations, hesitation, unresolved choices and reasons |
| Ownership and feedback | Whether each participant identifies who acts and what changed |
| Accessibility | Text readability, non-color cues, focus/navigation and actual window size |
| Save/resume | Exact phase/decision, successful recovery and player comprehension |
| Match completion | Result reached, abandonment, technical intervention or defect |

For each defect, record severity, frequency, reproduction steps and the recovery available to the player. Prioritize blocked progression, misleading legal choices or ownership, lost progress and unreadable required information before decoration. Capture only actual Godot states and label any independently staged reproduction.

## Exit condition

Both participants can complete the bounded scenario and explain the observed required decisions without technical intervention. Any missing ability opportunity remains an observation to investigate, not a passed task. Outstanding blockers require a correction and a new observed session. This gate does not certify rules accuracy, competitive balance, another platform or cross-machine networking.

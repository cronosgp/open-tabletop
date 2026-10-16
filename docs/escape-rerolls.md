# Command Re-roll: Desperate Escape

Implemented 16 October 2026 for the supported training scenarios. Enable **Match setup → Advanced match options → Next match: Desperate Escape re-roll** before creating a prepared or saved-list match. This enables core stratagem infrastructure; the other re-roll checkboxes remain independent. Both LAN players must select the same options. Changing setup controls during a match configures the next setup.

## Rules and timing

The [official Core Rules PDF](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf) was checked through the cached source with SHA-256 `f6a2443a44627ac5f0ef08407d29aa5ec7e97339998f05bc35f3ae37bf276833`, sections 06.03 (hazards), 09.07 (Fall Back), 15.01 (stratagem restrictions) and 15.02 (Command Re-roll). Command Re-roll costs 1 CP and replaces one selected die of a simultaneous hazard pool. The new result is mandatory, including when a successful original becomes a failure. The exception requiring both charge dice to be replaced does not apply here.

An engaged, steady unit may choose Desperate Escape instead of Ordered Retreat. A Battle-shocked unit must use Desperate Escape to Fall Back, but cannot receive this friendly stratagem. A steady unit that completes Desperate Escape still makes the existing post-movement Battle-shock test. No Battle-shock re-roll is added by this option.

After the original hazard dice, an eligible unit pauses before any recipient selection, Feel No Pain, lost wounds or movement. **Accept result and continue** is free and rolls nothing. Alternatively, choose a D6 and use **Command Re-roll**. Only that die changes. Original pools with no failures still offer the decision. Results of 1–2 fail; other results pass. Consequences are recalculated before allocation resumes.

The enabled capability uses the shared hazard evaluator, including three mortal wounds per failure when every living model is MONSTER/VEHICLE. The four supported reference profiles are infantry; the heavy case is tested with a synthetic fixture and does not admit arbitrary vehicle armies. The disabled historical exercise path is preserved.

All existing usage restrictions apply: CP, once per player/phase, target eligibility and unit stratagem limits. Advance and escape in the same Movement phase share the Command Re-roll allowance. Without eligibility, the original pool continues directly to allocation/placement. There is no late request after accepting, allocating, moving or resetting placement. Resetting positions retains final hazards, casualties and CP spent. Abandoning an impossible Fall Back consumes the move as before.

## State, UI and recovery

Capability ID: `command-reroll-escape-hazard-v1`. The flag is frozen in the prepared-match manifest and saved-list public setup. Older saves without the flag restore disabled, retaining their previous rules identity. Conflicting save or peer settings are rejected.

The Play decision window shows the original pool, unit, CP and die selector. Other gameplay commands and tactical destination guides remain blocked while it is open. The result notice reports the final pool, CP remaining and whether escape allocation or placement follows.

The host validates the player, unit, phase, revision, window, die index, cost and limits. The client sends no die value. Invalid choices do not commit state or CP. Save/journal preserve the original pool, pending movement draft, decision, final replacement, usage and RNG. An authenticated guest can reconnect to a restarted host and resolve the original pending pool exactly once.

`test_escape_rerolls.gd` covers the rule window, rejected commands, deterministic replacements, all-pass/worse results, free acceptance, prevention timing, heavy multiplier, default compatibility, UI, journal, save/resume and conflicting configuration. `test_escape_rerolls_network.gd` verifies a fresh host process and authenticated rejoin with pending hazards. The saved-army network suite includes an escape-option variant. These are Windows loopback checks, not separate-machine or cross-platform certification.

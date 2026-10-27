# Phase, action and decision flow

Status: **target architecture and implementation contract**. This document defines the shared shape of match progression. It does not certify rule timings or claim that the current runtime has a generic reaction engine. Exact rules, substeps and timings belong to a versioned rules/mission profile and must be checked against the project's selected 11th-edition source before they are enabled.

## Design invariant

The match may continue only when the current phase has no unresolved action, decision, mandatory effect or resolution frame. A player's turn ownership and the right to make the next decision are separate facts.

```text
phase -> declare action -> validate -> resolve automatic effects
      -> offer an eligible decision, if one exists
      -> resolve that decision -> resume the suspended work
      -> complete action -> next action or phase close
```

An observed event does not by itself create a reaction. The active rules profile must define an eligible trigger and at least one legal decision. When no decision is available, processing continues automatically.

## State hierarchy

Keep these levels distinct in match state and in the user interface:

| Level | Owns | Example state |
|---|---|---|
| Match lifecycle | Whether the match is being prepared, played or finished | `PRE_GAME`, `DEPLOYMENT`, `IN_BATTLE`, `FINISHED` |
| Battle progression | Round, turn owner, current phase and phase step | `round`, `activePlayerId`, `phase`, `phaseStep` |
| Work in progress | Declared action and its current resolution state | `actionId`, `actionStatus`, selected unit/targets |
| Pending decision | Which player must choose, legal options and pass policy | `decisionId`, `priorityPlayerId`, `legalOptions`, `passAllowed` |
| Resolution frames | Work suspended while nested choices/effects are resolved | ordered frames with resume points |

`activePlayerId` identifies whose turn is underway. `priorityPlayerId` identifies who may submit the next command. They are often the same, but a rules decision can give priority to the opponent. `actorId` on an incoming command must match the authorized priority/decision owner, not merely the active player.

## Match and battle progression

The outer lifecycle is:

```text
LOBBY -> ARMY_BUILDING -> PRE_GAME -> DEPLOYMENT -> IN_BATTLE -> FINISHED
```

The enabled mission profile owns the exact preparation sequence. It may configure list confirmation, mission/map/terrain selection, attacker/defender and pre-battle choices, deployment, redeployments and first-turn selection. Do not hard-code one universal pre-game ordering into the rules kernel.

The battle loop is:

```text
ROUND_START
  -> TURN_START(active player)
  -> PHASE_START
  -> PHASE_BODY
  -> PHASE_CLOSE_PENDING
  -> PHASE_END
  -> next PHASE_START, or TURN_END
  -> next player's TURN_START, or ROUND_END
  -> next ROUND_START, or FINISHED
```

For the current target scope, the ordinary battle phases are Command, Movement, Shooting, Charge and Fight. Start/end-of-turn bookkeeping and round boundaries are progression steps, not extra player-facing phases. A profile may define phase-specific steps and insert rule-driven decisions without changing this outer loop.

## Common phase stages

Every phase follows the same orchestration stages. A phase profile supplies its applicable rules and permitted work for each stage.

| Stage | Purpose | Gate to continue |
|---|---|---|
| `ENTER` | Set phase identity and reset only state whose duration ends or begins here | Phase-start mandatory effects are processed |
| `START_EFFECTS` | Resolve mandatory start effects and enumerate optional start decisions | No required start decision remains pending |
| `BODY` | Accept eligible player actions, one at a time or through a phase-specific sequence | No action/decision is currently unresolved |
| `CLOSE_REQUESTED` | Record an attempt to end the phase; do not advance yet | All phase work, triggers and mandatory effects are settled |
| `END_EFFECTS` | Resolve mandatory/optional end effects in rule-defined order | No required end decision or resolution remains pending |
| `EXIT` | Apply phase-end bookkeeping and transition to the next configured step | Transition is valid for the active profile |

Do not ask for a confirmation when a stage has no player choice. An optional decision with no legal options is skipped. `Pass` closes only the decision that offered it and follows its configured continuation.

## Phase-specific work areas

These are architectural containers, not claims that every listed substep is required by every rules profile. The source-reviewed profile determines exact order, eligibility and decisions.

| Phase | Work that the phase handler may organize |
|---|---|
| Command | Phase-start choices, resource updates, required tests, healing or other enabled command work, then close processing |
| Movement | Choose an eligible unit, declare movement type, resolve required pre-move choices/rolls, draft and validate placement, commit movement, resolve resulting triggers |
| Shooting | Choose an eligible unit, declare attacks and targets, resolve attack steps and required defender choices, apply results, resolve resulting triggers |
| Charge | Choose a unit, declare targets, resolve required roll/target choices, move and validate placement, resolve resulting triggers |
| Fight | Build the eligible activation/priority sequence, resolve each activation's choices and attacks, placement steps and resulting triggers, then close |

The runtime may display fewer or more player-facing steps than these internal work areas. UI steps must reflect current server state and never determine legality.

## Action lifecycle

Use one explicit lifecycle for actions that can be interrupted by decisions:

```text
DRAFT -> DECLARED -> VALIDATED -> COMMITTED -> RESOLVING -> COMPLETED
                       |                |
                       +-> REJECTED     +-> SUSPENDED -> RESUMING -> RESOLVING
```

- **Draft** is editable intent. It does not spend resources or change authoritative game state unless a rule says otherwise.
- **Declared** records the player's choice at the rule-defined declaration timing.
- **Validated** confirms preconditions, ownership, targets and current revision.
- **Committed** applies costs/locks at the timing specified by the rule.
- **Suspended** stores a resume point while a permitted decision or nested effect is resolved.
- **Completed** marks the action's effects and follow-up triggers settled.
- **Rejected** leaves no partial state. Rollback is not a generic substitute for a rule's procedure when a later effect invalidates an action.

Actions that are not interruptible can use the same lifecycle without entering `SUSPENDED`.

## Decision window contract

Each pending decision should have a stable identity and enough context to close and resume deterministically:

```text
decisionId
sourceEventId
actionId                 # nullable for phase/setup decisions
timing                   # profile-defined timing key
priorityPlayerId
legalOptions             # server-computed option IDs and required public details
passAllowed
closePolicy              # pass, choose, timeout/disconnect policy where supported
resumeFrameId
rulesProfileId/version
```

The server recomputes eligibility when the command arrives. The client-visible option list is guidance, not authorization. A closed decision ID cannot be used again. Options and logs sent to each player must respect information visibility.

Multiple eligible effects are queued and ordered by the configured rules priority, never by packet arrival order. Mandatory effects are not represented as optional `Pass` decisions. If an effect creates another legal decision, suspend the current frame, resolve the nested work, then resume its parent frame.

## Command and resolution pipeline

```text
receive command
-> authenticate seat and match lifecycle
-> validate expected version, idempotency and priority owner
-> validate current phase/step, action and targets
-> record declaration/commitment at its rules-defined timing
-> emit domain events and resolve mandatory effects
-> collect only eligible decisions for this event/timing
-> persist state, decision/frame queue and journal atomically
-> publish a visibility-filtered state to each player
```

A command based on a stale revision or closed decision is rejected without partial mutation. The ordering is deterministic and independent of transport timing. Random results are generated and recorded by the authoritative host.

## Phase-close gate

`End Phase` means **request close**, not immediate advancement. The close gate must refuse to advance while any of the following applies:

- an action draft is awaiting confirmation or an action is resolving/suspended;
- a legal decision window remains open;
- mandatory effects or queued triggers remain unresolved;
- a phase-specific sequence has required work remaining;
- the selected mission/rules profile has a required close-stage decision.

Once these are clear, phase-end effects resolve, duration-limited state expires at its specified boundary and the progression state advances. No generic timeout may silently choose for a player unless the match profile explicitly defines that behavior.

## Current implementation boundary

The runtime delegates deterministic phase ordering and turn rollover to `scripts/edition_11/phase_progression.gd`; `scripts/edition_11/phase_resolution.gd` sequences boundary effects and transitions after common admission. The combat facade retains close admission and Fight-sequence continuation. Command-priority precedence lives in `scripts/edition_11/match_actor.gd`, and common command admission plus phase-close blockers, including transport placement and unresolved resolution frames, lives in `scripts/edition_11/phase_close_gate.gd`. The gate allows only the matching phase-close continuation to re-enter while its decision is being resumed. `scripts/edition_11/pending_decision_registry.gd` centralizes reads of normalized pending decisions; callers supply the applicable source order so the registry does not invent or reorder rules priority. `scripts/edition_11/match_command_service.gd` executes phase advancement, doctrine and unit choices, movement and contact workflows, charge, shooting, attack plans, fights and mission-action starts without depending on UI or transport; `main.gd` keeps the root RPC endpoints, guest admission, broadcasts and player feedback. Rule validation and state mutation remain in the combat facade and domain modules. Combat Doctrine, supported stratagem roll/Battle-shock windows, Reanimation, pending attack allocation, phase-start/end reaction windows and other active UnitActions ability/preparation windows expose read-only normalized decision records through `scripts/edition_11/pending_decision.gd`; command priority and phase-close admission consume the projection, while specialized handlers remain authoritative and recompute eligible options when a choice arrives. Reanimation placement projects the choice of model while leaving coordinates as rule-validated inputs. Damage allocation projects the authorized model and current defender/attacker priority. The projection does not invent a domain event ID. Phase-close, Movement and Charge decisions link to persisted LIFO resolution frames in `scripts/edition_11/resolution_frame.gd`; Movement retains its frame through dice decisions and placement, while Charge retains one through rerolls, target selection, contact placement and immediate post-charge effects. The phase resolver resumes its close frame after its decision settles. `match_command_service.gd` validates Combat Doctrine, stratagem, Reanimation, damage allocation and UnitActions selections against the current decision ID and legal option ID. Other workflows retain specialized revision and choice validation. Pending workflows are not yet universally modeled as shared records, and close-blocker coverage remains incremental. Generic trigger dispatch and action-frame migration across the remaining workflows remain future work. Rule-specific phase-boundary sequencing now lives in `scripts/edition_11/phase_resolution.gd`; faction effects still use their domain modules. Match identity is assembled without the combat orchestrator, and leader/ability identity facts are shared through low-level catalogues.

The architecture direction in [architecture.md](../architecture.md) and this contract describe target boundaries. Do not mark the generic engine supported until the code, capability metadata, tests and status documents reflect it. Continue implementing current Space Marine scope with local rules/combat/admission checks; network validation remains deferred to the final integration stage.

## Incremental implementation order

1. Record the current phase/decision behavior as characterization coverage without changing rule outcomes.
2. **In progress:** persist LIFO resolution frames for phase close, Movement and Charge, linking their player decisions to the suspended continuation. Extend action-level frames to other interrupted gameplay workflows without duplicating rule validation.
3. Continue routing phase-close checks through the extracted gate and add explicit blocker coverage for every supported pending workflow while retaining rule-specific validation.
4. Migrate one local, source-checked decision workflow at a time; verify no-choice auto-advance, pass, chosen option, stale command, nested decision and close blocking locally.
5. Update capability/support claims only for the workflows actually migrated and locally validated. Defer network checks to final integration as requested.

This order establishes reusable plumbing before using it to add or certify additional timings. It does not make any fictional example timing in a design specification universal.

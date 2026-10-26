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

The runtime delegates deterministic phase ordering and turn rollover to `scripts/edition_11/phase_progression.gd`; `scripts/edition_11/phase_resolution.gd` sequences boundary effects and transitions after common admission. The combat facade retains close admission and Fight-sequence continuation. Command-priority precedence lives in `scripts/edition_11/match_actor.gd`, and common command admission plus phase-close blockers, including transport placement and unresolved resolution frames, lives in `scripts/edition_11/phase_close_gate.gd`. The gate allows only the matching phase-close continuation to re-enter while its decision is being resumed. `scripts/edition_11/pending_decision_registry.gd` centralizes reads of normalized pending decisions; callers supply the applicable source order so the registry does not invent or reorder rules priority. `scripts/edition_11/match_command_service.gd` executes phase advancement, doctrine and unit choices, movement and contact workflows, charge, shooting, attack plans, fights and mission-action starts without depending on UI or transport; `main.gd` keeps the root RPC endpoints, guest admission, broadcasts and player feedback. Rule validation and state mutation remain in the combat facade and domain modules. Combat Doctrine, supported stratagem roll/Battle-shock windows, Reanimation, pending attack allocation, phase-start/end reaction windows and other active UnitActions ability/preparation windows expose read-only normalized decision records through `scripts/edition_11/pending_decision.gd`; command priority and phase-close admission consume the projection, while specialized handlers remain authoritative and recompute eligible options when a choice arrives. Reanimation placement projects the choice of model while leaving coordinates as rule-validated inputs. Damage allocation projects the authorized model and current defender/attacker priority. The projection does not invent a domain event ID. Phase-close, pre-dice attack declarations/reactions, attack allocation, unengaged Fight/Bladeguard choices, Movement and Charge decisions link to persisted LIFO resolution frames in `scripts/edition_11/resolution_frame.gd`; the end-of-Command Reanimation window suspends the phase-close frame, then resumes into remaining end-of-phase choices. Attack frames retain their identity through pre-dice reactions, rerolls, defender assignment, destruction effects and any resulting Hazardous allocation. After attack finalization, selected Tactical Fluidity, Purgation Run, Glory of Ultramar and Invictor mark-replacement choices suspend the attack frame through their response chains and placement steps; the normalized UnitActions decision retains the frame identity. Counteroffensive and Vengeful Stars continue to use their own child/response frames. Movement retains its frame through dice decisions and placement, while Charge retains one through rerolls, target selection, contact placement and immediate post-charge effects. The phase resolver resumes its close frame after its decision settles. `match_command_service.gd` validates Combat Doctrine, stratagem, Reanimation, damage allocation and UnitActions selections against the current decision ID and legal option ID. Other workflows retain specialized revision and choice validation. The phase-start/end UnitActions windows retain their player order while each player resolves or declines available choices; choices are recomputed after every effect. Before unit-choice projection, the command service validates the UnitActions container, transport window and decision owners so malformed saved state fails closed before domain access. Mission, Combat Doctrine, Oath of Moment, Awakened Dynasty, Stratagem and Reanimation decision containers are validated before command-priority projection or specialized dispatch. This supports the tested Spiritual Leader/Smokescreen interaction, where removing Battle-shock makes Smokescreen eligible before the player closes the same start window. Mandatory phase effects remain in their specialized boundary handlers. A generic trigger registry and deferred-activation batch are not implemented; add them only if another source-checked timing demonstrates that existing windows cannot preserve the required order or continuation. Close-blocker coverage and action-frame migration remain incremental. Rule-specific phase-boundary sequencing lives in `scripts/edition_11/phase_resolution.gd`; faction effects remain in their domain modules. Match identity is assembled without the combat orchestrator, and leader/ability identity facts are shared through low-level catalogues.

During alternating Deployment, immediate UnitActions choices are assigned to the owner of the currently deploying squad when that player has a legal option. The projection uses `Deployment.current()`/`Deployment.actor()` and exposes a normal `unit-actions` decision, so the command service can validate its owner and option IDs before applying a deployment-timed ability.

The architecture direction in [architecture.md](../architecture.md) and this contract describe target boundaries. Continue implementing current Space Marine scope with local rules/combat/admission checks; network validation remains deferred to the final integration stage.

Deployment validation accepts `index == order.size()` only when the persisted deployment state is marked complete. This preserves the exhausted placement cursor as players enter post-deployment mission choices and the first turn, while an incomplete exhausted order still fails closed.

Common command admission in `phase_close_gate.gd` rejects raw transport resolution state before unrelated commands can enter, even if its mirrored UnitActions choice window is absent. It also validates the stored types for Movement, Charge, Fight-contact, damage allocation, Hazardous allocation and Deadly Demise state before deriving command priority or pending decisions. Phase close validates the outer UnitActions state and transport window before reading either. A non-empty UnitActions window with a missing type, empty owner list, invalid player ID, duplicate owner or an unrecognized kind fails closed before it can be projected. Unknown UnitActions window kinds do not receive the generic decline option. A new child frame can open only under a suspended parent. Commands are blocked while a persisted frame is open unless they carry the matching pending Movement, Charge or Fight-contact action identity. Raw pending drafts also require the matching action identity when a save has no frame, so older drafts can be resumed only through their owning workflow. The only Core reaction entry points that can resume a suspended phase-close frame are the current actor's validated Overwatch shot and Heroic Intervention charge declaration; reaction ownership alone never bypasses frame admission. These checks also reject orphaned frames whose specialized pending record is missing.

The specialized damage-allocation command also checks for pending Deadly Demise, transport and UnitActions work before reading the allocation projection. The unit-choice dispatcher requires a matching projected destruction or emergency-disembark option while a Deadly Demise chain is active. A unit choice that has no normalized projection must pass common command admission, which checks the actor and refuses unrelated pending decisions or resolution frames. These checks are necessary because attack allocation and destruction choices run inside suspended action frames and cannot use the ordinary command gate, which must continue blocking unrelated commands during those frames.

Command-start Combat Doctrine and phase-start UnitActions are migrated onto a persisted `phase-start` frame keyed by turn, phase and active player. When both are pending at Command entry, the doctrine choice resumes and re-suspends the same frame for UnitActions; player order and recomputed options remain unchanged. Each selection or pass suspends the frame again while choices remain, then completes it when the window closes. The frame survives state serialization, and phase close remains blocked while the pending decision is available.

The shared pending-state type guard in `match_actor.gd` runs before actor projection and is reused by command admission. It covers normalized decision windows plus deployment, core reaction, detachment reaction, Command Battle-shock, Fearsome Assault and Adamantine Terror containers read during priority calculation; UnitActions setup/player lists, used-ability records, reserves and Teleport Homers are also type-checked. Saving and restoring a local match, accepting a host snapshot, and rendering the decision HUD also reject malformed decision containers before reading domain projections. A rejected host snapshot leaves the last accepted local state intact and closes the client session; an invalid save is refused with a recovery message. A phase-close regression confirms that when no choices are eligible, the phase advances and its temporary continuation frame is completed. With Core Stratagems enabled, the opponent's Rapid Ingress end window opens only when that opponent owns a reserve unit with a legal CP or Teleport Homer entry, so unrelated reserve presence does not create a pass-only window.

Completed Movement actions now suspend their same `unit-action` frame when Cato Sicarius’ Knight Champion, a Combi-weapon Lieutenant’s Evade and Survive, or a Techmarine’s deferred Blessings of the Omnissiah opens a post-move choice. The normalized decision points back to that frame; placement and queued reactions retain it, and the frame completes when the reaction chain closes. The focused Cato and Techmarine checks exercise serialization and phase-close blocking; the Combi Lieutenant check exercises the real movement, decision and decline path. This is bounded frame-continuation coverage for those admitted local workflows, not a generic trigger engine or broader rules certification.

The same completed Movement frame now covers the opponent’s immediate Responsive Tactics, Masterful Tactics and Hunter’s Instincts response. The responder receives the matching eligible detachment options plus an explicit pass; using one opens the existing Normal Move preview as a child choice, and confirming or cancelling returns to that response before the movement frame completes. The Spearpoint test opens Hunter’s Instincts from the recorded enemy-movement trigger, restores its normalized response choice, and submits the option with the injected D3 result. Mobile stratagem choices made at the start of a selected Movement action also re-enter that suspended movement frame before the chosen move resumes; Flawless Riders uses the same contract for its Charge declaration. The Ironclad Unstoppable Advance check now submits its pre-move Mobile choice through the normalized UnitActions command, confirms its decision identity survives save/restore, then verifies the CP cost and return to the movement declaration. This choice precedes the Movement action, so it does not claim a frame for work that has not begun. Focused checks exercise real command choices, ownership, save/resume, cancellation and frame completion. These remain bounded rules-specific windows, not a generic reaction dispatcher.

The Spearpoint Movement/Charge tests now route Flawless Riders and Mobile Lethality through `MatchCommandService.SELECT_UNIT_CHOICE`. Flawless Riders' Movement decision keeps its identity through save/restore; both Movement and Charge continue with Mobile applied, while the existing checks retain terrain traversal, charge placement and model-spacing assertions.

Suboden Khan’s Wrath of the First Khan now has a focused local command-flow check from the opponent’s Fight close: the normalized end-phase decision belongs to Suboden’s player, the move opens its placement subchoice, the phase-close frame identity survives save/restore, and an attempted close while the choice is pending is rejected without mutation. Confirmation returns to the same end-phase window; passing then completes Fight close and hands off to the distinct End-of-Turn coherency continuation when that mandatory choice is present. This is evidence for that Spearpoint workflow, not all end-of-phase abilities.

Stormlance Wind-Swift Evasion is also exercised through the public UnitActions command from the opponent-owned Fight-end window. Its normalized choice spends CP, opens the Movement-characteristic placement, retains the phase-close frame through serialization, blocks a premature phase close, restores the end window after confirmation, and completes Fight close after pass. This is bounded evidence for Wind-Swift's local continuation path.

Spearpoint Withdraw and Regroup is exercised through the normalized public Fight-end command after the earlier-priority player declines their choices. The eligible Mounted unit spends 1 CP and enters reserves while the end window and suspended phase-close frame remain pending; save/restore preserves that continuation, and the unit's owner can then pass to resume Fight close. This is bounded evidence for Withdraw and Regroup's local continuation path.

Inceptor Parabolic Jetleap and Kayvaan Shrike's Echo of the Ravenspire are also exercised from the opponent's Fight close through normalized UnitActions commands. Their tests verify that an eligible unengaged unit enters Strategic Reserves, the phase-close frame remains suspended through save/restore, and the owner can pass to resume close. This evidence covers these two local reserve-choice continuations only.

End-of-Fight Tactical Fluidity is exercised through the normalized public command path from the opponent's Fight close. Its response retains the same phase-close frame through the `fluidity-use` subchoice, serialized Fall Back placement, rejection of a premature close, move confirmation and the remaining explicit pass. This is bounded local evidence for that Captain response sequence.

Resurrection Orb's Reanimation decision now reports its actual end-of-phase timing (including the phase name); Undying Legions reports its post-destruction timing. The Orb continuation is tested through activation, the paired Necron reroll choice when present, normalized return placement, save/restore, phase-close rejection and explicit pass. Its normalized Reanimation choice retains the suspended phase-close frame until the required placement is confirmed. Undying Legions now reaches the defender through a normalized post-attack choice in the opponent's Shooting or Fight phase. Its attack frame remains suspended through the Reanimation reroll and return placement, survives save/restore, then completes without advancing the phase. A no-return case also verifies that accepting the paired Character reroll cannot advance the phase early. Eternal Revenant's normalized return placement now stores the original end-of-phase window and restores it after confirmation; this keeps other eligible end choices available instead of silently ending the window. The focused test verifies save/restore, remaining pass and phase-close resumption. These are bounded local paths, not general Necron or Reanimation certification.

The isolated June 2026 Oath of Moment profile also projects its Command-start target choice as a normalized decision and shares the Command `phase-start` frame. The command validates the current decision and target option IDs before the Oath-specific owner, revision and enemy-target checks; resolving the target completes the frame.

The mandatory Fearsome Assault Battle-shock sequence at Fight entry uses the same `phase-start` frame contract. Its normalized UnitActions decision carries the frame ID; resolving each target re-suspends the frame while targets remain, then completes it after the final test. The Reiver test now submits the initial roll, an existing-shock result and the target controller's Tempered in Battle re-roll through the normalized command envelope, including the serialized controller-owned decision. The Fight queue cannot advance while these tests are pending.

Adamantine Terror's sequential Fight-phase Leadership tests use the same normalized command path. The Ironclad test submits the initial trigger and each target controller's Tempered in Battle re-roll through the current decision/option IDs; completing the first target resumes the same phase-start sequence for the next target, and the frame closes after both results are recorded.

Start-of-battle declarations such as Teleport Homer placement and initial Invictor marks now expose a normalized UnitActions decision for the current owner. They gate progression from the internal `start_turn` step; they do not suspend an already resolving gameplay action.

The selected CA 2026-27 mission-preparation sequence also exposes one normalized decision at a time through the pending-decision registry. The command service validates the current decision and option IDs before mission-specific checks run. These setup choices advance their own persisted mission stage and do not create gameplay resolution frames.

The legacy Awakened Dynasty Overlord attachment declaration now uses a normalized preparation decision for standalone or currently eligible bodyguard options. Command priority and the UI read it from the common registry; the command service validates decision and option IDs before the faction-specific pairing and revision checks. These pre-deployment declarations remain a preparation workflow and do not create gameplay frames.

A `phase-close` frame now also suspends before Command healing and the Insane Bravery/Battle-shock decision. The Apothecary Command-healing test drives the Narthecium start and healing confirmation through normalized UnitActions commands, rejects a premature close without mutation, serializes the suspended frame between those choices, then resumes Command close and resolves the opponent's remaining end-phase choice before progression completes. The no-Core-Stratagem fallback uses `command_battle_shock.gd` to preserve each result and expose the tested unit controller's Tempered in Battle choice through the UnitActions decision projection; the test rejects premature phase close without mutation, restores the choice and resolves the re-roll through `MatchCommandService.SELECT_UNIT_CHOICE`, completing the original phase-close frame. This preserves the existing order and lets normalized decisions expose the active continuation ID.

Counteroffensive now keeps a `fight` continuation after a melee attack completes and opens the opponent reaction window. The attack frame is completed first, then its parent Fight sequence is suspended and exposed through the normalized UnitActions decision. Taking or declining the reaction resumes and completes that frame while retaining the Fight queue state. The test submits both choices through the command service after save/restore and verifies a wrong-owner submission fails without mutating the continuation.

Vengeful Stars and Hail of Vengeance now expose the eligible post-attack Shooting reaction as a normalized UnitActions decision. Completing the original attack opens a persisted `shooting-reaction` frame; choosing the stratagem retains the same action identity as the state changes to reactive shooting, and declining or completing the reactive shot closes the continuation. The normalized decision blocks phase close and carries its frame through serialization. Attack admission accepts only the decision owner and the unit bound as the reactive shooter while that continuation is active; unrelated pending UnitActions choices still block commands. Both effects resolve their retaliatory shot through the public `SHOOT` command. Hail coverage starts from a real attack that destroys a model, resolves the defender's projected allocation, chooses Hail, then fires the bound response. Vengeful coverage starts from a public attack-plan declaration using the Captain's equipped Master-crafted Bolter; normalized defender allocation destroys the last Immortal, after which the nearby Overlord chooses Vengeful and shoots the destroying Marine unit. The reactive attack carries into a defender-owned save-roll choice; serialization preserves that decision and both nested attack/reaction frames before accepting the result and completing the continuation.

A Worthy Death and Duty in Death now have attack-declaration coverage through their normalized defender choices. The tests exercise an actual Fight attack, Armour of Contempt pass, defender ownership, rejection of premature Fight close, save/restore of the pending decision and suspended attack frame, and resumption after the 1 CP stratagem choice. Duty in Death also retains its Assault Doctrine casualty-roll modifier check. Duty Unto Death reuses this continuation with Inner Circle Deathwing eligibility and a Vowed-objective engagement modifier; focused local checks for that branch remain pending. This verifies the named local attack-declaration branches, not all stratagem timings.

Stormlance Hurtling Targets now submits its defender response through the normalized command after save/restore. The suspended ranged attack frame blocks Shooting close while the choice is pending; selecting Hurtling resumes and completes the same attack, spends CP and applies the ranged hit modifier. This is bounded coverage for that attack-declaration response.

Spearpoint Evasive Manoeuvres now follows the same contract from a public ranged attack against a Mounted unit. The normalized defender choice retains the suspended attack frame through save/restore, blocks phase close, then resumes the shot with the wound modifier and CP cost applied. The separate Hurtling and Evasive outcomes stay tied to their eligible detachments.

The other currently admitted core Fight reactions follow different timing paths. Fire Overwatch and Heroic Intervention are offered from phase-end windows and use the existing phase-close continuation. Fire Overwatch is exercised through its normalized public command and save/restore path; Heroic Intervention's Leap to Defend and Into the Fray modes now also use normalized choices, spend their respective CP costs, open the reacting unit's charge and retain the phase-close frame while that charge is pending. Epic Challenge is offered after a Character unit is selected and before its attacks; choosing it immediately spends CP and applies Precision to that model's melee weapons, so it does not suspend an already resolving attack or create a separate pending window. Fight pile-in, overrun and consolidation placement drafts own a persisted `unit-action` contact frame; each placement segment suspends the same frame, and confirmation or cancellation completes it. An unengaged Fight activation that opens a Bladeguard stance choice owns a persisted `fight` frame through the choice, blocks phase close, and completes it when the activation advances. The phase/command gate also explicitly blocks while a Deadly Demise destruction chain remains pending, including a missing or temporarily absent UnitActions window; this prevents the close contract from relying only on UI-facing choice projection. Reserve/Rapid Ingress now owns a `unit-action` frame through preview, save/resume, cancel or confirmation, preserving a suspended phase-close parent for an opponent's reaction. Normal Transport disembarkation owns a persisted `transport-disembark` frame across Hazard allocation and model placement; confirmation completes it, and when Hazard removes every passenger the no-choice path completes the frame automatically. Its Hazard and placement steps now use normalized UnitActions decisions, including the no-failure case, preserve decision and frame identity through save/restore, block phase close and complete the frame on confirmation. Drop Pod Assault nests one `transport-drop-pod-assault` frame under ingress and carries it across every mandatory passenger disembark, including save/resume and no-survivor transitions; its mandatory passenger placement now uses the normalized command across multiple passengers, returns the same child frame between passengers and completes both child and ingress frames after the final confirmation. Emergency Disembark remains nested in its owning attack continuation; a legal Gauntlet Task Force passenger now receives an optional Aggressive Disembarkation choice before Hazard rolls, then passenger-owned Hazard allocations and active-player placement use normalized UnitActions choices linked to the suspended attack frame. Focused checks for the new choice stage remain pending; the existing allocation/placement path survives save/restore and resumes the attack after confirmation. The remaining A2 work is to audit each supported pending workflow against phase-close admission and continuation needs, then migrate the unresolved cases incrementally.

**Drop Pod Assault stratagem choice:** before each mandatory passenger Rapid Disembark enters placement, a Gauntlet Task Force owner can use or pass Aggressive Disembarkation through the existing `transport-drop-pod-assault` child frame. This applies after Drop Pod arrival in either player's Movement phase, including after Rapid Ingress in the opponent's Movement phase. The same frame returns after each passenger, the stratagem's phase/unit limits control later passengers, and every model still must remain more than 8 inches from enemies. It adds no resolution frame; focused checks, save/restore review and playtesting remain pending.

Ironstorm Headhunter Doctrine now exercises the same contract at pre-dice attack declaration: a public attack-plan opens an attacker-owned normalized decision linked to the suspended attack frame, rejects opponent submission without mutation, preserves decision/frame identity through save/restore, blocks Shooting close, and resumes after either spending CP to use the stratagem or passing. Remaining attack reroll choices are then submitted through normalized commands until the local attack frame completes. This verifies the bounded continuation path; it does not certify all Ironstorm combinations or rules scope.

Firestorm Point-Blank Brutality opens a persisted use/pass decision as soon as an eligible engaged TACTICUS attack plan is confirmed. The planner previews non-Blast Close-Quarters legality only while the stratagem is available; final attack preparation occurs after the response, so declining cancels a plan that depended on the added keyword without spending CP. When used, non-Blast ranged profiles receive Close-Quarters and Ignores Cover through the shared weapon path. Focused checks and save/resume playtesting remain pending.

Cato Sicarius's post-movement Knight Champion reaction now submits its use, placement and confirmation through normalized UnitActions commands. The reaction stays attached to the completed Movement frame through placement, rejects an opponent command without mutation, and completes the same frame after the Normal Move is confirmed. The Combi-weapon Lieutenant's Evade and Survive use, pass, placement and confirmation also use normalized commands; placement restores a pre-existing decision and the completed-move frame is retained through the choice. Techmarine Blessings choices now use normalized commands at movement start, when deferring the effect, and at movement end; its movement continuation remains available while the effect resolves.

Wind-Swift Evasion's post-Fight Normal Move confirmation and its Fall Back placement and confirmation now use normalized UnitActions commands as well. The actual phase-close path preserves its suspended `phase-close` frame; these domain-level cases enter through the same decision projection when a movement choice is active.

Invictor Forward Assault target selection now uses the normalized choice both at battle start and after a marked enemy is destroyed during an attack. The replacement decision retains the suspended attack frame through save/restore, rejects the defender's command without mutation, blocks Shooting close, and resumes the same attack when the new mark is selected. Victrix Glory of Ultramar's use, Surge placement and confirmation now use the same command path, retaining the post-attack frame through the move.

Purgation Run now opens from a public Land Speeder attack-plan and routes its use, Normal Move placement and confirmation through normalized commands. The defender-owner decision rejects the opponent without mutation, keeps phase close blocked and retains the same attack frame through save/restore and placement.

Captain Phobos Tactical Fluidity now uses the normalized command path for its post-shot D6 choice, Normal Move placement and confirmation. The owner check rejects the opponent without mutation, and the attack frame remains suspended through save/restore until placement completes. The existing end-of-Fight Fall Back response continues to use normalized decisions and its phase-close frame.

Power of the Machine Spirit and Ironstorm Auto-targeters Hit/Wound rerolls now exercise the normalized UnitActions command envelope inside their pending attack. The Machine Spirit decision ID survives save/restore, rejects the opposing player without mutation and blocks phase close; use or decline resumes the existing attack-resolution path. This remains a bounded local attack-roll workflow.

Core Command Re-roll after Hit and Wound also runs through the public normalized stratagem-decision envelope. The selected attack-roll decision preserves its ID across save/restore, rejects bad owner, stale revision, ineligible die and invalid RNG attempts without consuming dice or mutating state, and resumes the suspended attack frame after accept or reroll. The existing UI submits the same envelope.

The defender's mortal-wound allocations from Hammer of Wrath, Tigurius's Telepathic Assault, Explosives, Incursor Haywire Mine and Tank Shock now use normalized UnitActions command envelopes. Hammer of Wrath and Tank Shock retain their suspended Charge frames across save/restore and complete them after the defender resolves the allocation. Telepathic Assault, Explosives and Haywire Mine preserve defender-owned decision IDs, reject an attacker command without mutation and block phase close until each packet is resolved. Ballistus Deadly Demise also keeps the defender's allocation under its suspended attack frame across save/restore, then resumes the same attack transaction after allocation. These are bounded source-path checks; other mortal-wound triggers and broader combinations remain under audit.

The Ironstorm interaction regression now enters Tank Shock, Hammer of Wrath, Telepathic Assault and Haywire Mine through `MatchCommandService`, then resolves Layered Ceramite and the mortal allocation through normalized UnitActions choices. This checks those defender reactions in combination with the underlying trigger, while the source-specific suites retain the ownership, persistence and frame assertions for their individual workflows.

The Drop Pod integration path now starts Rapid Ingress through `MatchCommandService` even before a UnitActions decision is open, then uses normalized preview and confirmation commands. Its nested mandatory disembarkation continues through normalized passenger decisions and closes the same Drop Pod and ingress frames after the final passenger.

Captain Titus's Righteous Fury choice at Fight activation now enters through `MatchCommandService`. This is an immediate activation choice; the test confirms an opponent command is rejected without mutation and the selected ability is applied once.

Captain Phobos's start-of-Command Combat Doctrine selection and Strategic Acumen/end-window pass now also use `MatchCommandService`. The focused test follows the doctrine choice into the Captain's selected Assault Doctrine, then passes the remaining Command window before continuing to the once-per-round Warlord effect.

Repulsor Combat Embarkation during Charge placement now uses the normalized defender decision through `MatchCommandService`. The test rejects the charging player's submission without mutation, blocks Charge close while the response is pending, and verifies that passing or embarking lets the existing charge-target selection continue.

Bladeguard attacker and defender stances now submit through normalized UnitActions decisions before attack dice. The existing Fight frame remains suspended across both players' choices and resumes with the selected hit modifiers; passing also resumes without consuming the once-per-turn stance.

The Apothecary test now routes Narthecium selection, wound allocation, revived-model placement, reset and confirmation through `MatchCommandService`. Its Command-close healing continuation preserves the phase-close frame through save/restore and resumes after the owner's choices and the opponent's end-phase pass.

Implacable Eradication Hit/Wound rerolls and the keep-results choice now submit through the normalized UnitActions envelope inside the attack. The defender-owned decision survives save/restore, rejects the attacker without mutation, and resumes the attack after reroll or continuation.

Responsive Tactics after an enemy move now uses normalized commands for activation, placement cancellation back to the response window, and decline. The Movement continuation remains suspended through the nested choice and completes after the final pass.

The Scout Squad and standalone Phobos Librarian pre-battle flows now submit Scout declaration, per-model previews and confirmation through normalized UnitActions commands. The Phobos Librarian checks both an ordinary Scout move and a Strategic Reserves set-up, including movement/deployment bounds. Completing the final queued Scout move advances the setup flow automatically into `start_turn`.

The shared current-unit-abilities regression now submits a UnitActions choice through the normalized command envelope whenever the pending-decision projection contains that exact option. Specialized response choices without a UnitActions projection, such as My Will Be Done's Core Stratagem discount prompt, remain on their existing domain path until that window has its own normalized contract.

Rampart of Heroes, Hailstrike and Shattered Defences now submit their eligible choices through normalized UnitActions decisions. Finalized ranged attacks invoke the existing cover-target window builder; it still filters to a living enemy unit that was hit and applies the source-specific target restriction. These mark decisions happen after the attack completes, so they do not claim an attack-frame continuation.

The current-reference Captain test submits Strategic Acumen through `MatchCommandService` and confirms the opponent is rejected without mutation. The source permits this immediate use during the Command phase, so the exercised action does not require a persisted pending-decision identity.

The Banner of Macragge activation during a Fight selection now uses its projected UnitActions decision through `MatchCommandService`. The test verifies a foreign player cannot activate it and that the accepted choice applies the once-per-army bonus.

Driven from Cover's post-shot target selection now submits the normalized owner decision through the command service. The command refuses phase close while the mark is pending; the owner can choose only one of the hit enemy targets, and a foreign player is rejected without mutation.

Adamantine Terror's sequential Tempered in Battle results now submit through normalized controller-owned decisions in the two-player, two-detachment fixture. The serialized next result has a fresh decision identity and the owning Ironclad player cannot submit the opposing controller's re-roll.

After Command Reanimation resolves, the remaining end-of-phase pass now uses the projected decision envelope. The other player is rejected without mutation, and the accepted pass completes the same serialized phase-close frame into Movement.

Phobos Librarian Shrouding now resolves through its normalized defender decision before attack dice. The attacker is rejected without mutation, Shooting close remains blocked, and the saved attack declaration resumes only after the authorized psychic choice.

Iron Father Feirros's Master of the Forge defer and repair choices now use projected decisions through the command service. The opponent is rejected at both steps, preserving the same eligible movement continuation from pre-move deferral through the completed move and vehicle repair.

End-of-Turn coherency casualties now project through the shared pending-decision registry with a stable decision ID and model-specific option IDs. Priority follows the existing rule path: the active player's first incoherent unit, then the opponent's. The command service re-computes that projection and requires the current decision and option IDs before delegating to the existing coherency validation/removal. This makes the mandatory choice visible to the common actor/UI flow while preserving phase-close blocking and the domain rule checks.

Desperate Escape mortal-wound allocation now follows the same shared contract inside its Movement action. The projection uses the shared Mortal Wounds eligible-model calculation, and the command service requires the current decision and selected model option before the combat rule resolves prevention and applies the wound. The UI disables models outside that eligible set, and phase close remains blocked until allocation finishes. While wounds remain, the Movement frame is suspended at `escape-wound-allocation`; each choice keeps the same frame, and the final wound resumes that frame at `movement-placement`. This remains true after accepting or replacing the hazard pool and after save/resume. This keeps the order in [Core Rules §§06.02, 06.03 and 09.07](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/): wounded non-Characters, other non-Characters, wounded Characters, then other Characters.

`Dread Crusaders` now opens from the defender's eligible reaction when the charging player selects a friendly Adeptus Astartes Infantry unit as a target after the Charge roll. The charge target is recorded first, then the Charge frame suspends while the defender spends 1 CP and resolves the charging unit's Battle-shock roll at -1, or declines. If the charging unit has an eligible `Tempered in Battle` aura, its controller can keep the result or re-roll both dice with the modifier retained; the saved Charge frame resumes after that choice. Target selection and charge placement remain blocked while either decision is pending.

End-of-Turn coherency casualties now suspend a `phase-close` frame on entry to `end_turn` when either player's unit is incoherent. The normalized decision carries that frame through save/resume and changes priority to the next affected player after each casualty. Removing the final required model resumes the same frame; phase close then performs the existing end-of-turn scoring and turn rollover. Legacy End-of-Turn states without the frame can still resolve the casualty through the same decision projection before the next phase-close request.

The no-Core-Stratagem Command Battle-shock fallback stages its batch on a copy and commits only after a successful resolution. Missing or invalid host dice therefore leave the match untouched. The batch stops after its final result is completed, retaining the result history, and a passed Command test clears the Battle-shock condition.

Spiritual Leader in the Chaplain phase-start window now submits through the projected UnitActions envelope. Wrong-player submissions are rejected without mutation, and the accepted choice clears Battle-shock without spending CP.

## Incremental implementation order

1. Record the current phase/decision behavior as characterization coverage without changing rule outcomes.
2. **Foundation in place for the current slice:** persisted LIFO frames link phase-close (including end-of-Command Reanimation), attack damage allocation and selected post-attack reactions, Movement and selected post-movement reactions, and Charge decisions to their continuations. Extend action-level frames to other interrupted workflows without duplicating rule validation.
3. Extend the existing specialized decision windows for source-checked timings. Introduce a shared activation batch only when multiple implemented rules require persisted intra-timing order or deferred triggers that those windows cannot represent.
4. Continue routing phase-close checks through the extracted gate and add explicit blocker coverage for every supported pending workflow while retaining rule-specific validation.
5. Migrate one local, source-checked timing at a time; verify no-choice advance, mandatory/optional priority, player-selected order, deferred triggers, stale activation, nested decision, resume and close blocking locally.
6. Update capability/support claims only for workflows actually migrated and locally validated. Defer network checks to final integration as requested.

This order establishes reusable plumbing before using it to add or certify additional timings. It does not make any fictional example timing in a design specification universal.

One current public-command exception permits an out-of-turn `Protocol of the Hungry Void` choice during Fight. The command service allows it only when that exact option is still offered to its owner; shared command admission continues to validate revision, pending work and resolution frames. This is not a generic out-of-turn bypass.

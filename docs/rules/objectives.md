# Objectives and custom training

The combat exercise implements core objective control from 11e §§14.01–14.03. A terrain objective uses its entire terrain area: a living model contributes its effective OC when its base intersects that area. Battle-shocked models contribute zero. The marker helper supports the alternative 40 mm marker with 3-inch horizontal and 5-inch vertical range, measured from its edge. The bundled training map uses terrain objectives only.

All objectives begin uncontrolled. Control is determined at the end of each actual phase, after Command battle-shock and before subsequent end-of-phase effects. Movement drafts do not capture objectives. The end-of-turn boundary uses control determined before coherency casualties. Equal OC leaves an unsecured objective neutral. An internally secured objective keeps its owner on a tie, including 0–0; greater opposing OC removes secured status and transfers control. Only in-range squads containing a positive-OC model count as controlling units, even if their army retains a secured objective without models present.

Securing is an effect API used by the custom training action Secure Ground. There is no unrestricted securing command. Prepared matches can now explicitly enable [Intercessor Objective Secured](objective-secured.md); it applies after Command control and Battle-shock, only for qualifying Intercessors. The default disabled exercise behavior is preserved.

## Play the training mission

Select **Start custom objective training (5 rounds)**. This starts a new match with three objectives: the central ruin, rubble and barricade. Yellow outlines mean neutral; blue and orange mean player 1 and player 2. The panel shows control, OC totals and VP. OC totals are the last resolved boundary values, rather than provisional movement totals.

This is an explicitly custom mission: each controlled objective awards 1 VP at the end of every battle round, after player 2's turn. After five rounds, the higher score wins; equal scores draw. Elimination does not end this mission early. The original combat exercise retains its elimination ending. No official mission deck, secondaries, deployment sequence or army construction is implied by this training mode.

Both network players must select the same mode before connecting. The host owns control resolution, round scoring and victory; mission configuration is included in the compatibility hash. Scores and objective states replicate with ordinary snapshots. A finished game rejects further commands, and each round can score only once.

## Validation and remaining work

`test_objectives.gd` checks range boundaries, OC ties, battle-shock timing, secured retention/loss, controlling squads, wrong-player/stale/draft rejection, scoring idempotence, victory/draw and a complete five-round phase sequence. `test_objectives_network.gd` checks guest phase requests, synchronized control/score/victory, UI, stale requests and finished-game rejection.

Eleven local rules/UI suites and four host/client loopback suites passed on Windows; the objective panel and colored terrain borders were rendered and inspected. Separate-machine LAN and Linux remain unverified.

Official mission scoring and deployment remain unimplemented; [multiple-unit fight/reaction queues](multiple-units.md) are available in the optional two-unit training mode. Objective consolidation is available with the limits described below; the custom training action [Secure Ground](actions.md) exercises the core action lifecycle.

## Objective consolidation

During the Fight consolidation step, select an eligible squad. If it is engaged, ongoing consolidation takes priority; otherwise enemies within 3 inches require engaging consolidation. Only when neither applies can the squad choose an objective within 3 inches. The objective dropdown lets the player select among available objectives before **Begin consolidation**.

Move models individually up to 3 inches along their accumulated paths. Every moved model must finish within objective range if possible, otherwise closer. A model already within range can reposition while remaining within range. Confirmation requires coherency, no enemy engagement and at least one model within range. Control updates at the end of the phase. Cancel restores placement. These commands, the selected objective and confirmation synchronize through the host.

The geometric lower bound is conservative: if a moved model could cover the direct distance to objective range within its budget, this implementation requires it to reach range. It does not yet certify objective-specific terrain/coherency impossibility exceptions, and can therefore reject some legal detours. This limitation is separate from the existing enemy-contact certificates.

`test_objective_consolidation.gd` checks mode priority, range, approach, in-range repositioning, distant members, enemy engagement, eligibility, cancellation and phase-boundary capture. `test_objective_consolidation_network.gd` checks guest target selection, placement/cancellation, confirmation, guides, synchronized capture and stale requests. Six local suites and four two-process network suites passed on Windows; UI was visually inspected.

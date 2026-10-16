# Actions and Secure Ground training

Core eligibility and lifecycle follow [11e §16.01](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Performing-Actions). Actual actions need their own start window, eligible units, use limit, completion window and effect. This increment supplies one explicitly custom action to exercise that lifecycle; it does not implement an official mission action catalogue.

A unit cannot start an action if absent/destroyed, Aircraft/Fortification, battle-shocked, OC 0, engaged (unless Titanic), after Advance/Fall Back, or after starting another action this turn. Starting an action prevents declaring charges for the rest of the turn and prevents shooting except for Titanic units. Those restrictions survive interruption or early completion. Melee remains permitted. Starter model types remain infantry; the keyword gates do not imply full support for Titanic, Aircraft or Fortification rules.

Committed normal/advance/fall-back and charge moves interrupt an action. Pile-in, additional overrun pile-in and consolidation do not. An accepted zero-distance normal move still counts as a move; remaining stationary does not. Editable placement alone does not interrupt: cancellation restores the previous placement and retains the action. Destruction, leaving the battlefield or battle-shock interrupt a pending action when an authoritative state-changing event resolves. Future transport/reserve handlers must use these same lifecycle hooks.

## Custom action: Secure Ground

Available only in **custom objective training**:

| Field | Training rule |
|---|---|
| Starts | During your Shooting phase |
| Units | One eligible unit that has not shot, controlling an objective from within its range |
| Use limit | Once per army per player turn |
| Completes | End of the same turn, if still controlling the chosen objective from within range |
| Effect | Secure that objective for the unit's army; no immediate VP |

Select a miniature, choose the objective in **Secure**, and press **Start Secure Ground (custom action)**. The panel records progress, completion or failure; the charge button and shooting previews respect the action restriction. The host checks all requirements and replicates action history, turn restrictions and the secured objective. Clients cannot directly award the effect.

Control is determined at the end of Fight before the End of Turn action completion. The action completes before owner-selected coherency removals. Secured control can then persist without models and is lost when the opponent has greater control at a phase boundary. Round-end VP still follows the separate training scoring rule.

## Validation and limits

`test_actions.gd` checks eligibility, Titanic exceptions, same-unit and army use limits, target/phase/stale/ownership rejection, shooting and charge restrictions, turn expiry, movement and battle-shock/destruction/absence interruption, cancelled drafts, pile-in/consolidation exceptions, completion conditions and idempotence. `test_actions_network.gd` checks guest UI start, host rejection of blocked shooting/charges and stale starts, completion, secured control, score and restriction expiry.

Ten local rules/UI suites and five two-process host/client suites passed on Windows. Progress and completed-action panels were rendered and visually inspected. Linux and separate-machine LAN remain unverified.

This supports the bundled same-turn action. Cross-turn completion schedules, other action effects, official mission actions and special abilities that override eligibility remain future work. [Multiple-unit fight/reaction queues](multiple-units.md) are available in the optional two-unit training mode. The battlefield builder remains low priority in the future backlog.

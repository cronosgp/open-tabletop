# Multiple-unit training and Fight queues

Select **Start training: two units per player**. This creates two Intercessor squads for player 1 and two Warrior units for player 2, using the existing fixed profiles and custom objective mission. There are 30 individual models. Unit IDs and player IDs are separate; movement, shooting, morale, action use limits, coherency and objectives refer to the actual unit and its owner.

This is a fixed training roster. It does not provide legal army construction, points balancing, deployment or faction abilities. The original one-unit-per-player modes remain available. Both peers must choose the same training size before connecting; roster size participates in the compatibility hash and survives local resets/hosting.

## Fight selection

The panel lists the unit IDs and names eligible in the current window. Select a miniature from the unit you want to use. Right-click a living enemy to resolve melee, or use the existing individual contact-placement controls.

- **Pile-in:** the active player resolves or declines each eligible unit, in their chosen order, before the opponent does the same. Each unit gets one initial pile-in decision.
- **Fight:** players alternate eligible units, with charging units taking Fights First priority. A different friendly unit cannot bypass that priority. If one player has no unit in the priority group, the other continues. An accepted additional overrun pile-in commits that activation to the moved unit; the player cannot move one unit and attack with another.
- **Consolidation:** resolve or decline each eligible unit once, active army first. The panel retains remaining choices. Declining an optional move applies to the selected eligible unit, or the next listed unit if none is selected.
- **Reactions:** every contacted, unfought enemy unit is queued after ongoing or engaging consolidation, including the ongoing-consolidation erratum. The opponent chooses their order. Each must resolve its fight before consolidation resumes. Destroyed or already-fought units leave the queue; unrelated units cannot take that reaction window.

An engaged unit cannot skip required melee. When several units can resolve an unengaged fight, explicitly select one before advancing. Enemy contact targets for unengaged pile-in, overrun and engaging consolidation can be chosen in the **Contact target** dropdown; ongoing contact moves automatically retain all engaged enemy units. Objective selection remains in its separate dropdown when objective mode is eligible.

## Current limits

Each model still has fixed weapon profiles. [Attack plans](attack-plans.md) now distribute attacks across several target units, including splitting individual melee weapons; mixed weapon/profile selection remains unimplemented. The unengaged contact dropdown chooses one target; the rules API also accepts multiple selected contact targets, and charge selection supports several targets through right-click toggles. Innate Fights First and other ability/stratagem timing remain unsupported. Existing terrain and bounded approach-certificate limitations continue to apply.

Elimination mode now ends only after the last living model in the opposing army is destroyed, rather than after one of its units is destroyed. Objective training still ends by its five-round scoring rule.

## Validation

`test_multi_units.gd` verifies real rosters and ownership, compatibility identity, initial coherency, per-unit optional decisions, same-owner priority enforcement, alternating combat, overrun activation locks, multiple consolidation reactions, queue pruning, rejection of unrelated reactions and army-wide elimination checks.

`test_multi_units_network.gd` verifies a guest's fourth unit consolidating into two host units, both reactions resolving in a chosen order, remaining consolidation decisions, synchronized unit/queue state, UI and stale/wrong-window requests.

Thirteen local rules/UI suites and five host/client loopback suites passed on Windows. The 30-model board and two-reaction panel were rendered and visually inspected. Separate-machine LAN and Linux remain unverified. Defender-selected model allocation is available as a next-match option. The next combat increment is mixed equipment, followed by further verified abilities and mission timing. The player battlefield builder stays in the low-priority backlog.

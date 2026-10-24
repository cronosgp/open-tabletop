# Assigning attacks across targets

The exercise now supports target allocation for its fixed weapons using [11e §§04.02–04.03](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Selecting-Targets): each ranged weapon selects one enemy unit; a melee weapon may distribute its attacks across enemy units engaged with its model, with at least one attack per selected target.

## Controls

1. During your Shooting or eligible Fight window, select a model and press **Plan attacks across targets**.
2. Select each miniature in that unit, choose an enemy in **Target**, and press **Assign selected model to target**. Right-clicking an eligible enemy while editing also assigns the selected model.
3. For melee, set the attack amount before assigning. Add another target for the same model to split its attacks. Allocate exactly the full A characteristic of every model with eligible melee targets. Models unable to engage a target do not need a row. For shooting, the amount represents the model's one fixed weapon; its attacks all go to one target, and models may be omitted.
4. Review all rows and the validation message, then **Confirm complete attack plan**. Targets resolve in the order they first appear in the plan, completing all pools for one target before proceeding to the next.

Assigning the same model/target again replaces that row. A new ranged target replaces the model's previous target. **Clear selected model's assignments** removes its rows; **Cancel attack plan** discards the local draft without spending an activation or rolling dice. A new authoritative revision invalidates an old local draft.

The ordinary right-click shortcut remains available outside planning: it proposes all eligible fixed weapons against that enemy. It cannot silently omit melee models that have other legal targets; use the planner if that shortcut cannot allocate their attacks legally.

## Host validation and resolution

The host validates ownership, phase, action restrictions, Fight priority/reaction window, current revision, row schema, model survival, target eligibility, ranges, weapon limits and all defender profiles before any dice. Duplicate rows, fractional/negative amounts, ranged weapon splitting and incomplete/overspent melee allocations reject the entire plan.

Target selection freezes visibility, range, Rapid Fire and per-model cover before casualties. Identical ranged attacks still split into separate pools when cover or Rapid Fire differs. Damage does not redirect declared attacks to other units, and front-model casualties do not invalidate attacks already declared against the same unit. Each pool identifies its target in the event log. Results include the declared rows and target order in the synchronized snapshot.

Weapon BS/WS characteristics are resolved independently from modifiers to Hit rolls. Source modules can record unit-level or model-level characteristic modifiers; positive values improve the target number (3+ to 2+), negative values worsen it, and the result is capped at 2+–6+ under the current Core Rules. Might of the Machine Spirit and Master of the Forge can ignore the direct characteristic modifiers through this path without erasing separate Hit-roll modifiers. The ordinary Techmarine Blessings of the Omnissiah ignores Hit/Wound-roll modifiers only; it does not ignore direct BS/WS characteristic modifiers.

In automatic-assist mode, resolution applies damage and consumes shooting/Fight eligibility once for the entire unit. If any pool fails, including an invalid dice provider after an earlier pool, all match-state damage, activation and history changes are discarded. In [defender-choice mode](defender-allocation.md), damage instead commits per accepted choice while activation and queue progression wait for all choices. The random provider may already have consumed values; dice are host-owned. Mandatory reactions resume only after the complete plan resolves.

## Limits and verification

The default starter exercise retains fixed equipment. The optional [varied equipment mode](equipment.md) supports multiple owned weapons and profile selection. Ranged random A and [Hunter/Extra Attacks](weapon-selection.md) are supported by the planner. Random melee A, mixed defending allocation groups and attached characters remain future work. Defender-selected model allocation is available in the optional mode documented separately. Existing terrain proxies, supported weapon keywords and other exercise restrictions still apply.

`test_attack_plan.gd` covers per-model melee splitting, target order, conservation of attacks, ranged omission and weapon restrictions, invalid/incomplete plans before dice, transactional damage, later-pool failure, frozen range/Rapid Fire, wasted excess attacks, ownership and stale requests. `test_attack_plan_network.gd` runs both ranged and melee scenarios with guest UI assignment/cancellation/confirmation, synchronized target pools, invalid requests and repeat rejection.

Fifteen local rules/UI suites and six host/client loopback scenarios passed on Windows, including combat, multi-unit queues, contact and terrain regressions. The plan editor and result log were rendered and visually inspected. Linux and separate-machine LAN remain unverified. Weapon/profile selection is now available in the optional varied training mode.


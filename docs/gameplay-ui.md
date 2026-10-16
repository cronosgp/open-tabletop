# Gameplay UI

The main sidebar separates **Match setup**, **Play** and **Models / Import**. Round, phase, actual decision owner and custom-training scores/objective ownership remain above the scrolling tabs. The decision owner may differ from the active player during Precision, defender allocation or fight reactions.

## Contextual actions

Play groups controls into Movement/coherency, Charge/contact placement, Attacks, Resolve attack/damage, Objective actions and Phase progression. Groups with no relevant controls are hidden.

During an attack draft only its group is displayed, including Confirm and Cancel. Pending movement, contact placement, coherency removal and attack/Hazardous allocation focus the corresponding group until that decision finishes. Other groups return after the pending decision is resolved. This changes presentation, not host validation or the rules protocol.

An unavailable action has a reason next to its group and on the disabled action's tooltip. Movement, attack planning, allocation and objective eligibility reuse rule validators. Charge/contact guidance follows the current eligibility checks. Completed exercises, missing peers and opponent-owned decisions identify the responsible state/player. Plan confirmation errors update as assignments change; a valid selection clears the old explanation. Available alternative actions in a group remain usable, for example declining Precision while no character is selected.

The **Direct Precision** button requires a selected character. A selection of -1 is reserved for the explicit **Do not use Precision** button, rather than accidentally accepting the decline through a button labeled as directing Precision.

## Validation and remaining work

Context guidance tests cover no/valid attacker selection, incomplete/complete plans, exclusive editing with cancellation, mandatory allocation, Precision decline, waiting for the opponent, movement selection and charge restrictions. The guidance does not change match state. Ten related local suites passed for this increment, and shooting/Precision guidance screens were rendered and inspected at 1280x800 on Windows. New separate-machine network and Linux checks were not performed.

## Compact selection card

Play now starts with a compact card: unit name and owner, living models in that unit, selected model wounds, T/Sv/InSv, morale/effective OC and assigned FNP. Movement remaining and an active Secure Ground action appear when relevant. No selection and destroyed selections are explicitly identified. Mixed defenses use the selected model's own profile.

**Show equipment and technical details** expands the existing equipment/profile list and technical state. The expansion choice survives ordinary refreshes and selection changes. Mandatory Precision/Hazardous/damage choices, eligible models, defensive group profiles and fight/contact/movement queues remain in a separate visible area, so collapsing details cannot hide them. Hazardous raw rolls remain in expanded technical details and completed combat history.

Six local suites passed for the card increment (selection card, action guidance, gameplay layout, allocation practice, local models and cache lookup). The selected mixed-profile/FNP card and collapsed Precision view were rendered and visually inspected at 1280x800. No new network/Linux validation was performed.

## Guided attack and defense flow

Attack editing presents four steps: select a living model from the attacking unit; choose its weapon/profile, target and any fixed melee count; assign and repeat; review and confirm to roll dice. The review names the selected model/unit, counts assignments and distinct target units, and lists the resolution order from the first assignment to each target. Cancel discards the local draft. Weapon and target dropdowns preserve their selections on refresh and do not expand the sidebar to fit long names.

Pending Precision, defensive group order, damage and Hazardous choices show stage-specific instructions and the responsible player. An eligible-model dropdown names the unit, model ID and remaining wounds. Selecting an item only changes board selection; the existing confirm button applies the decision through host validation. Returning to the prompt clears selection without declining Precision. The explicit decline button remains available for Precision; other required choices cannot be cancelled. Opponent-owned choices disable the picker locally. No save/damage rolls are exposed ahead of the existing rules sequence.

Six local suites passed for this increment: guided attacks, contextual action guidance, selection card, allocation practice, attack plans and mixed defenders. Tests check draft review without state changes, correct/incorrect model selection, named eligible choices, explicit confirmation, prompt reset, save timing guidance, opponent ownership and stale panel hiding. Planner and Precision screens were visually inspected at 1280x800. Network/Linux were not newly verified.

## Results and history

The latest local/host notice appears before the selection card and action controls. It is separate from the completed-result summary and historical events; a notice is not proof that an entire attack has finished.

**Last completed attack** summarizes each defending unit's attacks, applied damage and destroyed models across all pools. FNP prevention and discarded excess are separate totals. Hazardous wounds lost by the attacker, prevented wounds and unallocated discarded wounds have their own line, so they are not added to the defending target's losses. During another pending attack the previous result is explicitly labeled as previous; partial pending pools are not summarized as complete.

**Show combat history and dice** expands the existing detailed log. It starts collapsed, preserves expansion across refreshes, and preserves the reader's scroll position when history content has not changed. New history content still scrolls to the latest entries. Controls/help text follows the result/history area rather than interrupting the summary.

Six local suites passed for this increment: combat results UI, guided attacks, selection card, action guidance, gameplay layout and allocation practice. New checks cover real attack completion, damage/prevention/excess separation, raw dice visibility, pending versus completed results, separate Hazardous totals, expansion, scroll preservation and hiding obsolete results in preview mode. Summary and expanded-history screens were rendered and inspected at 1280x800. No new network/Linux validation was performed.

Next: broader UI accessibility/window-size and host/guest/rejoin validation, plus keyword explanations and terminology review. Core rules work remains on the overall roadmap.

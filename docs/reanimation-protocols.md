# Reanimation Protocols — scoped September 2026 profile

Enable **Match setup → Advanced match options → Next prepared match: Reanimation Protocols** for a prepared or saved-list training match. Both LAN players must agree. This implements the faction effect for **Warriors, Immortals, living standalone Overlords and one Overlord attached to either troop profile**. It does not certify a complete current Necron army or detachment.

## Source and limits

The official download catalog was queried on 16 October 2026. [Faction Pack: Necrons v1.3, legal 30 September 2026](https://assets.warhammer-community.com/eng_30-09_wh40k_faction_pack_necrons-1urphgbmpy-wbhocjbaba.pdf), **Rules Updates → Army Rules → Reanimation Protocols**, specifies activation for each friendly unit with the ability on the battlefield at the end of its own Command phase, healing D3 wounds.

Inspected PDF SHA-256: `fe9be8f7acdbbff581a099dd44dc8540dfee7a982573c6d0aa3d12d6467ea1ef`.

Placement uses **REVIVED** and flat-board coherency/engagement from the [official June core rules](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf): preserve original equipment, do not exceed starting strength, place in coherency with models present at the start of the phase, and do not engage an enemy unit that was not already engaged. Core PDF SHA-256: `f6a2443a44627ac5f0ef08407d29aa5ec7e97339998f05bc35f3ae37bf276833`.

The current [e11 core reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) includes Appendix 02.02.04: each healed wound restores a living wounded model first; only when all survivors are at full wounds can a destroyed non-CHARACTER model return with one wound. This scope has at most one wounded survivor (the Overlord); multiwound troop compositions and ambiguous healing choices remain blocked. Sections 19 and 19.04 retain the original attached unit, combined starting strength and surviving leader's ability after bodyguard destruction. Bodyguards may consequently return while their leader survives.

The official June PDF verifies the attached-unit identity and abilities, but does not reproduce the complete updated healing Appendix. The [official July update](https://www.warhammer-community.com/en-gb/articles/rgqanids/warhammer-40000-july-update-what-you-need-to-know/) confirms changed character/healing interactions; an independently revived Character returns as its own unit. Character revival is not implemented here. Other mixed compositions, multiwound troop returns, destroyed units, Resurrection Orb, Their Number is Legion, reserves/transports and upper floors remain outside scope. Unsupported living units reject Command before morale/dice.

## Player flow

1. Command entry snapshots living models as return anchors. Battle-shock resolves before this end-of-phase ability; being battle-shocked does not itself prevent it.
2. The active Necron controller chooses the order of eligible living units. Every unit activates, including intact units. The host rolls one D6, mapped to D3 as 1–2 / 3–4 / 5–6. No Command Re-roll or automatic Warriors reroll is offered for this unsupported dice window.
3. The shared D3 budget heals living wounded models first. Remaining wounds provide troop return attempts, capped by missing troops. Attached healing and returns commit together after preview; when there are no return attempts, healing commits immediately. The controller chooses original destroyed troop IDs. IDs, weapons and enhancements remain on the original model record.
4. Use X/Z coordinates or right-click the board to preview positions. **Suggest return positions** is a convenience search, not proof that all possible positions have been considered. Purple models are previews; their wounds and objective control are unchanged.
5. Confirm after all available attempts are assigned. Alternatively explicitly declare that a selected model cannot be placed; it stays destroyed and the declaration is recorded. The engine validates proposed positions but does not mathematically prove an impossibility declaration. Reset clears the draft while retaining the original roll. Confirming the last unit completes Command and resolves control without repeating Battle-shock or CP gain.

Returned bases must fit fully on the board, avoid living and staged bases and blocked terrain, remain within 2 inches of a surviving Command-entry anchor and within 9 inches of every living unit member, and leave the final unit coherent. Newly returned models cannot extend the anchor chain. Only enemy units engaged before this return may be engaged by it. This is setup: a corpse's former position does not create a movement path requirement.

Unused healing and declared placement failures are reported. There is no extra D3 carry-over and no later activation of the same unit in that Command phase. The model choice preserves different equipment rather than always reviving the lowest ID automatically.

## Authority and recovery

Implementation ID: `reanimation-core-profiles-september-2026-v2`. The boolean setup option is frozen in the manifest and saved-list options; disabled matches retain their previous identity. Old saves default to disabled, and conflicting save or peer flags are rejected.

The pending queue, original roll, budget, phase-entry anchors, pre-return engagement, chosen positions and declarations are serializable public state. The server validates player, phase, revision, unit, model, budget and geometry; clients send choices, never dice or wound totals. Unrelated gameplay commands and tactical movement guides are blocked while a decision is pending. Save/load and authenticated rejoin after a fresh host-process restart preserve the draft and RNG, and do not reroll.

`tests/test_reanimation_protocols.gd` covers timing, ownership/revisions, D3 conversion, budget/starting strength, untouched previews, equipment preservation, geometry, new engagement, blocked terrain versus setup, unsupported profiles, healing, Battle-shock ordering, options, UI and saves. `tests/test_reanimation_protocols_network.gd` covers authenticated guest actions, invalid requests, a pending preview across host restart, confirmation, predicted final state/RNG and exact journal dice counts. Loopback tests do not certify separate-machine or cross-platform play.

`tests/test_attached_reanimation.gd` covers shared budgets, preview serialization, a lone leader anchoring wiped bodyguards, both troop pairings and excluded slain Characters. `tests/test_attached_reanimation_network.gd` adds a mixed heal/return preview across a fresh host restart with exact state/RNG and journal checks. Version v2 changes enabled-match identity; v1 enabled saves require their matching implementation rather than silently migrating pending healing.

Current extension: the [current unit-ability option](current-unit-abilities.md) adds Royal Warden healing/attachments, Their Number is Legion and end-phase Resurrection Orb D6 activations. It preserves the no-Character-revival boundary. Normal scoped Reanimation without that option does not enable those datasheet abilities.

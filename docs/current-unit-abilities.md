# Current unit abilities - Track A

Enable **Advanced match options -> Next prepared match: current e11 unit abilities (Track A)**. This enables current faction/doctrine/core-stratagem options and turns off historical Hail of Bolts, Objective Secured and Oath selections. Both LAN players must select the same options. The four formerly proposed unit types are now admitted to mixed saved lists, for ten supported fixed-loadout types in total (at most six units per player).

## Current datasheet scope

| Unit | Implemented abilities in this profile |
| --- | --- |
| Intercessor Squad | Bolter Discipline: ranged +1 hit in own Shooting when attacker or target is in objective range. Tactical Mainstay: actions while engaged/Battle-shocked and shooting after starting an action, including Battle-shock continuation. |
| Assault Intercessor Squad | Targeted Intercession: melee +1 Strength and AP after a successful charge move this turn, including attached Characters. |
| Heavy Intercessor Squad | Unyielding in the Face of the Foe: +1 save rolls while controlling an objective, requiring positive OC. The save modifier is frozen for an attacking unit's full attack resolution. |
| Terminator Squad | Fury of the First: +1 AP against targets within 9 inches of the unit. Deep Strike reserves and manual arrival previews. Teleport Homer declared at battle start, removed when an enemy move ends within 1 inch; optional -1 CP Rapid Ingress with its placement restriction. |
| Captain | Verified Leader pairing with Intercessors/Assault Intercessors; Warlord selection; Transhuman Strategist bonus CP at battle-round start; Strategic Acumen local doctrine until next own Command; Finest Hour once per battle with +3 melee attacks and Devastating Wounds, including split attacks. |
| Lieutenant | Mandatory Support attachment to Intercessors/Assault Intercessors, including a unit already joined by Captain. Tactical Precision grants Lethal Hits except against Monster/Vehicle targets. Demi-company Commander optionally copies a friendly Captain's Strategic Acumen doctrine once per turn. |
| Necron Warriors | Their Number is Legion: keep the healing die or reroll once before allocating healing, including Resurrection Orb activations. No CP is spent and a rerolled die cannot be rerolled again. |
| Immortals | Current Implacable Eradication applies to the whole attached unit. Wound rolls of one reroll outside objective range; against an objective-range target, choose any individual wound dice for free rerolls before saves, including successful wounds, then accept remaining dice. |
| Overlord | Existing verified Leader declarations; My Will Be Done optional CP reduction shared once per army per battle round; Implacable Resilience subtracts one attack Damage, minimum one, for the Overlord model only; Resurrection Orb optional end-phase D6 healing, once per unit per battle and no more than one resurrection per player per turn. |
| Royal Warden | Leader for Warriors/Immortals; Adaptive Strategy permits shooting/charging after Fall Back; Engrammatic Logic removes friendly Battle-shock within 12 inches at phase start, once per battle. Standalone and attached Warden healing is supported. |

The former roadmap names **Judgement of the Weak**, **Target Elimination**, **Target Priority**, and the historical Intercessor abilities are not substituted for current datasheets. Current Lieutenant is Support; the regular Captain cannot lead Terminators. Historical reference exercises remain isolated.

## Player flow and recovery

After Overlord declarations, each player assigns any remaining Leader/Support attachments, chooses a Warlord when Characters are present, optionally declares Terminator reserves, and finishes preparations. Support units require an eligible attachment. Normal deployment follows. Teleport Homers are optional declarations at battle start after deployment, including for Terminators in reserves.

The **Current unit abilities** panel lists legal choices for the current controller. Setup and phase windows must be resolved or declined. X/Z or right-click place Homer/ingress models. Purple arrivals remain previews: every model needs a valid position, bases cannot overlap, the entire unit must be coherent, and every enemy must be more than 8 inches away. Own-Movement arrivals are available from round two. Rapid Ingress is an end-of-opponent-Movement reaction, normally 1 CP or 0 CP using the unit's Homer; the arriving unit must be within 3 inches of that token. Confirmation spends CP/consumes the token once. Cancellation retains reserves and resources. Units that never arrive are destroyed after round three. Reserve allocation uses the configured training-pack budget and its half-limit, not certification of latest official prices.

Units in reserves retain their original wounds/equipment, are hidden, cannot affect movement/visibility/objectives, and cannot attack. An ingress prevents further Movement moves; setup flags reset at the next turn. Homers are visible labels on the board and do not act as model bases.

At phase end, current-profile objective control is resolved before end-phase healing/abilities (core Appendix 14.02.01). At Command start, the active Marine army's doctrine decision precedes opposing optional phase-start abilities. Other optional unit doctrines are selected later during Command. My Will Be Done can be chosen in a stratagem window, including when normal CP are insufficient; all other targeting, Battle-shock and per-phase stratagem restrictions remain.

All choices are validated against the host's available actions, player and revision before mutation/dice. Setup, Warlords, local doctrines, free reroll checkpoints, limits, tokens and arrival previews are serialized in state. The new `unit_abilities` option and implementation `track-a-current-datasheets-2026-10-v1` enter prepared/saved-list manifests and peer/save checks. Historical saves default to disabled. Clients never supply damage modifiers, profiles or dice results.

## Sources checked on 17 October 2026

Effects and timings use the user's [e11 core reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and [Rules Appendix](https://wahapedia.ru/wh40k11ed/the-rules/rules-appendix/), together with current e11 datasheets:

- [Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Intercessor-Squad), [Assault Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessor-Squad), [Heavy Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Heavy-Intercessor-Squad), [Terminators](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Squad), [Captain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain), [Lieutenant](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant).
- [Warriors](https://wahapedia.ru/wh40k11ed/factions/necrons/Necron-Warriors), [Immortals](https://wahapedia.ru/wh40k11ed/factions/necrons/Immortals), [Overlord](https://wahapedia.ru/wh40k11ed/factions/necrons/Overlord), [Royal Warden](https://wahapedia.ru/wh40k11ed/factions/necrons/Royal-Warden).

Official cross-checks: [Space Marines printed updates v1.1, 14 October](https://assets.warhammer-community.com/eng_14-10_wh40k_printed_product_updates_space_marines_updates-91hillwcff-wzs8qnozam.pdf) states that updates also apply in the app; it changes other named datasheets, not these six Marine types. It does not reproduce the base Codex. [Necron faction updates v1.3, 30 September](https://assets.warhammer-community.com/eng_30-09_wh40k_faction_pack_necrons-1urphgbmpy-wbhocjbaba.pdf) supplies the current Reanimation effect and is read alongside the e11 datasheets; individual page/app and pack version labels do not denote the same document. [July official update](https://www.warhammer-community.com/en-gb/articles/rgqanids/warhammer-40000-july-update-what-you-need-to-know/) records the changed character-revival interaction. No destroyed Character is revived by this healing implementation.

## Boundaries

This closes the named datasheet effects for the ten **admitted fixed loadouts**, not every weapon/wargear variant. Current loadouts include the default secondary pistols and both Intercessor bolt-rifle profiles; Terminators use Power Fists, and Overlord uses Staff of Light plus Resurrection Orb. Relic Shield/Storm Shield are not equipped in these loadouts. Source data/points remain the pinned reference pack; latest points, repetition surcharges, wargear budgets, full MFM pairing certification, detachments/enhancements/other stratagems and an official mission are A2/A3 work. Full official army legality, transports, vertical floors and exact imported-mesh visibility are not certified by this increment.

Validation records are maintained in [verification-results](verification-results.md). The current ability, actual combat, reserve geometry/serialization and fresh-host-restart suites are separate from rules-source verification.

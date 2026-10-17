# Awakened Dynasty — e11 Command Protocols

Enable **Match setup → Advanced match options → Next prepared match: 11e Awakened Dynasty**. This implements **Command Protocols**, the detachment's +1 to hit effect while a Necron Character is leading a unit. It does not implement the entire detachment or certify a complete legal army.

## Sources and edition

Checked on 17 October 2026 against the user's [e11 Necron reference](https://wahapedia.ru/wh40k11ed/factions/necrons/#Command-Protocols) and [e11 Overlord datasheet](https://wahapedia.ru/wh40k11ed/factions/necrons/Overlord). The admitted Overlord pairings are Warriors and Immortals; Lychguard and other leaders remain outside the local profile whitelist.

The current [official Necron Faction Pack v1.3, legal 30 September 2026](https://assets.warhammer-community.com/eng_30-09_wh40k_faction_pack_necrons-1urphgbmpy-wbhocjbaba.pdf) was inspected, including its Awakened Dynasty updates. It changes Veil of Darkness and Eternal Revenant, not this bonus, and does not reproduce the full base Codex. Its SHA-256 is `fe9be8f7acdbbff581a099dd44dc8540dfee7a982573c6d0aa3d12d6467ea1ef`. Older official previews describe the same core effect but are historical corroboration, not a substitute for the current e11 reference. Checked-roster [Awakened stratagems](detachment-stratagems.md) are separate from this hit bonus. Enhancements, DP/force disposition legality and remaining datasheet abilities are not silently enabled.

## A usable list and attachment declaration

The army selectors now include a seventh offline preset, **Necrons • Overlord + Warriors + Immortals**: one Overlord, ten Warriors and five Immortals, at **245/500 local starter-pack points**. These are reference costs, not certification of the latest official budget. Showing the preset does not write a list into the profile; the existing save-copy action creates an independent editable list.

With the option enabled, each admitted Overlord requires a pre-deployment declaration by its controller: leave it standalone, or attach it to an intact friendly unled Warriors/Immortals unit. The interface makes standalone the initial selection. The server validates player, revision, current pending leader and bodyguard permission before changing state. A completed declaration cannot be repeated or changed after deployment begins.

Attachment merges actual models and their weapons/defenses into one unit; it does not merely set a bonus flag. The deployment order is rebuilt without the former standalone leader entry. A convenience search suggests a coherent Overlord preview near the bodyguards, avoiding bases of other previewed units too. Suggestions are not exhaustive: normal manual positioning remains available, and every model still requires validated deployment. Declaring an attachment consumes no CP or dice and preserves the match's initial pack identity; the dynamic declaration and positions are captured by state/journal revisions.

## Attack effect

Command Protocols grants +1 to hit to the led unit's ranged and melee attacks, including the Character's attacks. A nearby standalone Character does not provide the effect. A support role does not impersonate a leader. The bonus requires the enabled Necron army context, an attached unit, a living Necron Character in its leader component. The surviving leader retains its leading ability after all bodyguards are destroyed, as required by e11 19.04. Future declarations lose the bonus after leader death.

The host computes the attack context, combining this modifier with Heavy and engagement modifiers before applying the final +/-1 cap. Cover continues through the separate e11 targeting/skill path. Natural 1s and critical-hit rules remain in the existing attack engine. Source weapon profiles are unchanged. Declared attack batches and hit checkpoints retain their frozen modifier through player decisions, saves and authenticated rejoin after a fresh host restart.

## Explicit integration limits

Reanimation now supports one admitted Overlord attached to Warriors or Immortals. e11 19 treats the attachment as one unit throughout the battle: bodyguard casualties do not separate the leader or reset combined starting strength. The living leader retains its leading ability, and can anchor returning bodyguards. This corrects the earlier roadmap assumption that ordinary bodyguard destruction requires component separation.

The shared D3 budget first heals lost wounds on the surviving Overlord, then spends remaining wounds returning 1W troops. Destroyed Characters cannot return through healing. Other leader/support compositions, character revival, Overlord's remaining abilities, the rest of Awakened Dynasty, current datasheet/points certification and official missions remain pending.

## Recovery and verification

Implementation ID: `awakened-dynasty-command-protocols-11e-v2`. Setup/manifest/saved-list options freeze the effect; disabled identities are unchanged. Pending declarations, actual model components, assignment history and rebuilt deployment state are serializable. Old saves restore disabled; mismatched save/peer flags are rejected. Clients send bodyguard choices, never leader stats or attack modifiers.

`tests/test_awakened_dynasty.gd` checks identity/options, ownership/revisions, verified pairings, standalone choices, compatible attached healing, placement/coherency, live/dead leader/bodyguard cases, melee/ranged contexts, modifier aggregation, source immutability, real UI lists and pending/completed save recovery. The canonical roster sorter assigns IDs by identity rather than list-entry order; fixtures use the resulting IDs. `tests/test_awakened_dynasty_network.gd` checks guest attachment declaration, invalid requests, a frozen hit window across fresh-process host restart and authenticated rejoin, CP and predicted final state/RNG. These are loopback/staged checks, not separate-machine or full-rules certification.

The [current unit-ability profile](current-unit-abilities.md) now adds Royal Warden declarations and the remaining named Overlord fixed-loadout abilities. Other detachment stratagems/enhancements, broader pairing and points/MFM certification remain separate.

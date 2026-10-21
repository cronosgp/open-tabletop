# Oath of Moment — June 2026 rules profile

**Historical profile.** The current e11 Marine army rule is [Combat Doctrines](combat-doctrines.md), replacing Oath. This page documents compatibility/training behavior from the earlier snapshot, not current-Codex certification. The current doctrine option rejects combination with this profile; the project must migrate remaining outdated datasheet/ability references before claiming legal current armies.

This increment advances Track A's requested Oath of Moment rule using an explicitly pinned rules profile. It does **not** certify the current October Codex or a complete Gladius detachment.

## Source and version boundary

The [official June Space Marines faction pack](https://assets.warhammer-community.com/eng_08-06_warhammer40000_faction_pack_space-marines-nd2ezs5yzn-wxe2nf2ckk.pdf), version 1.0, legal from 20 June 2026, supplies the replacement Oath rule in **Rules Updates → Army Rules**, page 61. Its effect is selection of one opposing unit at the start of the owner's Command phase, hit rerolls against it until the next own Command phase, and a conditional +1 wound modifier for the specified Codex detachment context without the excluded chapters.

SHA-256 of the inspected source: `82b2e28b0950c53b12bc83681a3bee3fd6a58cd6d2acd7a9d67d37f2dcbe6f2f`.

Historical source note: the official download catalog and June Codex-era profile were recorded when this training implementation was first assessed. This option remains an isolated historical profile; it does not claim current e11 support. Current behavior must follow the definitive Wahapedia `/wh40k11ed/` source/version recorded for the active profile, and a separate Games Workshop locator is not an admission prerequisite. The June source file and catalog response were inspected locally under `.tools`; they are not required at runtime or bundled content.

## Playable scope

The historical training option is **Match setup → Advanced match options → Next prepared match: Oath of Moment (June 2026 Codex profile)**. Both LAN players must choose the same historical option. This explicitly selects the June Codex-detachment condition for the admitted Space Marine force and cannot combine with current Combat Doctrines. Other Gladius rules and complete detachment legality are not certified by this historical profile.

Entering Command gains the usual CP and expires that owner's old Oath target. Before Battle-shock or advancing further, Play requires selection of one living opposing unit. Oath does not require visibility or weapon range. The selection itself consumes no CP or dice. It cannot be changed later that Command phase. The other player's turn does not expire it, and the target's destruction does not grant an automatic replacement. With no living enemy unit, there is no mandatory choice.

Marine attacks against that target automatically repeat failed hits once, preserving successful hits. This deterministic training policy does not offer free rerolls of successful hits to seek criticals. The conditional wound modifier is omitted for non-Codex context and when the army includes BLOOD ANGELS, DARK ANGELS, DEATHWATCH or SPACE WOLVES. The four keyword spellings are normalized; dead members still count as part of the army. The engine supports the base non-Codex context for rule tests/future admission, while the current checkbox declares the Codex-context training profile.

Both ranged and melee plans receive the frozen context. Opposing factions, wrong targets and foreign/mixed army identities do not inherit it. Fast pools and serializable checkpoints share replacement order and final dice. Lethal Hits and Sustained Hits use final hit results; Torrent does not create hit dice. A die automatically repeated by Oath cannot be repeated again with Command Re-roll. Random-A checkpoints apply Oath after attack count is finalized and hits are rolled. Hail of Bolts can independently expand the selected bolt-rifle pool before those hit decisions.

## State and recovery

Capability ID: `oath-of-moment-june-2026-v1`. Owners, declared context, selected target and selection turn are public state; the implementation is frozen in the manifest and saved-list options. Old saves restore disabled. Mismatched save/peer flags are rejected. Command selection and pending attack state survive save/resume and authenticated host restart, preserving CP, RNG and ordered journal dice.

The Command choice is a dedicated Play section and blocks unrelated gameplay commands and tactical destinations. Selected Marines show their current target. The server validates player, phase, target and revision; clients send choices, never attack bonuses or die results.

Local tests cover timing/expiry, eligibility, chapter exclusions, base/Codex contexts, deterministic dice parity, critical effects, random-A continuation, double-reroll protection, setup identity and saves. A combined LAN test exercises guest Oath selection, Hail declaration, a pending expanded hit pool, fresh host-process restoration, authenticated rejoin and final state/RNG prediction. These loopback and staged graphical fixtures do not certify separate-machine or cross-platform play.

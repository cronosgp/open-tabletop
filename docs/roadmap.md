Current A3 increment (17 October 2026): [checked Incursion rosters](roster-validation.md) use official MFM 1.6 points for ten fixed profiles, 2/4 repetition limits, the sole-3DP detachment exception and mandatory Warlord/Support declarations. Two 290-point starters, one 930-point Gladius list and one 880-point Awakened list are available under the 1,000-point ceiling. For these checked lists, the [Gladius/Awakened stratagem set](detachment-stratagems.md), selected mission and implemented infantry core rules are certified together. Broader equipment, additional units and complete 1,000-point rosters remain future work.

Current Track A status (17 October 2026): A1–A5 are integrated for the documented 930-point Gladius vs 880-point Awakened infantry match. The selected CA 2026-27 mission, ten fixed-loadout profiles, current fixed-roster MFM checks and remaining required infantry core effects are covered. Other rosters, optional wargear, enhancements, unsupported keywords and other terrain/missions remain outside this certification.

Current Track D increments: D1 guided first-session entry and D2 contextual help are in progress. The Main menu now prioritizes the guided 290-point checked sample; alternate modes, LAN, resume and advanced setup are collapsed, while army building and optional tools have dedicated tabs. D1 launches the sample locally and gives numbered, progressively revealed steps through mission setup, army declarations, deployment, movement and a confirmed shot. The guide distinguishes available actions from gated or invalid actions and states that the starter sample is not a full-match legality certificate. The D2 pilot explains recognized weapon abilities, current phases, movement/charge/Fight placement choices, supported Battle-shock/Command Re-roll decisions and rule references for selected blocked actions; it is not yet a complete keyword, unit-ability, faction-stratagem and phase reference. A D3 presentation pilot is in progress: overhead model health/status, conditional pre-attack damage ranges, labeled and animated result tiles, success/failure/critical markers for resolved hit and wound rolls, and visible host/local dice provenance with a journal-chain reference. The journal reference helps identify the recorded history and detect changes when validating a matching save; it does not independently prove RNG fairness or unpredictability. D4 now includes manual unit focus plus optional movement, wound-change and destroyed-model cues. Automatic decision framing, projectile tracers and hit/impact effects remain unimplemented.

# Open Tabletop — Roadmap

> **Single source of truth for the remaining work to the final product.** This document consolidates and supersedes the [functional roadmap](roadmap-funcional.md) (retained only as the historical increment log) and the [backlog](backlog.md). Current shipped capabilities are summarized separately in the [support matrix](support-matrix.md). This document is the plan forward — not a changelog.

## 1. Product vision

**Open Tabletop is a gaming platform** for two-player Warhammer 40,000 (11th edition) matches on desktop (Windows/Linux). The engine enforces the rules, resolves dice and state authoritatively, and presents a polished, accessible, social experience built around user-supplied visuals. Players bring the armies and the miniatures; the platform brings the board, the rules, the dice and the connection.

What it is **not**: a rules encyclopedia, a single-player AI game, or a "training tool." The combat/training exercises in the current build are implementation/test harnesses and will be absorbed by real matches as rule coverage grows.

- **Target platform:** desktop, Windows and Linux, keyboard + mouse. (Mobile, touch and controllers are out of scope for v1.)
- **Target audience:** tabletop players who already know 40k and want a faithful, faster, easier way to play a match against a friend.
- **North star (player):** *"Set up, connect, and play a complete, legal match — with the rules handled for me and every rule explained where I need it."*

**v1 non-goals:** full vertical geometry / battlefield editor, all factions, single-player AI, mobile, and redistributing third-party miniatures (content boundary — user-supplied visuals remain local and are never transferred between peers).

## 2. Current state (baseline)

| Area | Shipped | Still missing |
|---|---|---|
| Rules | Checked CA infantry match: ten fixed e11 profiles, declared Leaders/Warlord/Support, Gladius/Awakened rules and stratagems, selected mission/deployment, MFM 1.6 fixed-profile construction, core reactions and recovery | Other armies, optional wargear/enhancements, remaining catalog content, other missions/layouts and unsupported mechanics |
| Multiplayer | Authoritative host, LAN/direct, snapshots, guest seat credentials (HMAC challenge/proof), rejoin after host restart | Lobby negotiation, encrypted internet transport, relay/service, credential reset UI, accounts |
| Persistence | Versioned snapshot, atomic replace, checksum, autosave, draft save, local/LAN resume, seat reservation, RNG continuation, hash-chained event/dice journal with verified reconstruction | Visual replay, multiple slots, journal compaction, cross-version migration |
| Army builder | OpenHammer catalog, filters/variants/budgets, local profiles, checked-roster MFM 1.6 construction and ten fixed profile admissions | Arbitrary units, optional equipment/enhancements and general roster legality |
| Models | ForceOrg auto-acquire, cached/HTTPS OBJ+diffuse download, saved pawn links, manual override | GLB, AssetBundles, composites/materials, per-model variants |
| Delivery | Offline verification runner, CI definition, demo export presets | CI execution on GitHub, native builds, cross-platform matches |

Experience, accessibility, social, onboarding, audio, licensing, and telemetry are **not yet represented** as first-class work. Closing that gap is the purpose of this document.

## 3. Tracks and milestones

Remaining work is organized into eight tracks. Each milestone lists its deliverables and its "done when."

### A. Rules & content completeness *(the critical path)*

> **Integrated for the checked match** — the locked roster scope and rule boundaries are in [track-a.md](track-a.md) and [track-a-a5.md](track-a-a5.md).

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| A1 | Checked reference match | Ten fixed-loadout Space Marine + Necron profiles, Leader/attachment declarations, faction/detachment effects and stratagems for the two checked lists | The documented 930/880 infantry lists complete the selected mission with the checked rules; broader armies remain future work |
| A2 | Selected official mission & deployment | CA 2026-27 Battlefield Dominance / Hammer and Anvil, fixed secondaries, deployment, reserves and scoring | The documented match reaches a five-round VP result under the selected profile |
| A3 | Current fixed-roster pricing/construction | MFM 1.6, Incursion ceiling, 2/4 repetitions, sole-3DP exception, Warlord/Support checks; see scope above | The ten admitted profiles and checked lists pass the documented construction validation |
| A4 | Unified capability registry | One machine-readable "what's supported" registry consumed by the validator, UI and tests | Unsupported content is blocked consistently everywhere from a single source of truth |
| A5 | Remaining core rules for the shipped lists | [Gladius 930 vs Awakened 880](track-a-a5.md): Command Re-roll plus Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge | Checked CA infantry match certified; remaining 1000-point fill is catalog work |
| A6 | *Post-launch* expansion | More factions/units/missions, vertical geometry, battlefield editor | Each increment widens the matrix without admitting partially implemented content |

### B. Multiplayer & platform networking

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| B1 | Lobby & negotiation | Scenario/pack/option agreement, readiness/accept, immutable pre-match manifest | Both clients agree on a configuration before any rules run, with no out-of-band setup |
| B2 | Internet transport | Encrypted transport, NAT/relay or a connection service, discovery | Two players connect and complete a match over the internet, not just LAN/loopback |
| B3 | Accounts & identity | Player identity, credential reset/transfer UI, friend/invite flow | A player can invite a friend and rejoin across devices with their own seat |
| B4 | Resilience & diagnostics | Loss/latency handling, reconnect UX, connection diagnostics | A dropped connection recovers to the last verified state with a clear player-facing explanation |

### C. Persistence & integrity *(mostly shipped; finishing work)*

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| C1 | Multi-slot & journal housekeeping | Multiple save slots, journal compaction | Players can keep several matches and the journal stays bounded over long games |
| C2 | Visual replay | Deterministic replay rendered from the existing journal | A match can be replayed visually from its hash-chained journal |
| C3 | Cross-version migration | Safe migration of saves/replays across rules versions | Updating a data pack does not invalidate existing saves without a clear migration path |

### D. Player experience — UX & presentation *(parallel from day one, not a final polish)*

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| D1 *(in progress)* | Onboarding / first session | Guided first turn, ready sample armies, "play without reading the README" | A new player selects, moves, shoots and confirms with no external docs |
| D2 *(pilot in progress)* | Inline rules reference | Contextual help for recognized weapon abilities, movement and contact placement choices, phase control, supported core-stratagem decisions and selected blocked-action reasons is prototyped; expand to every supported keyword, unit ability, stratagem and phase rule, and link all disabled-action reasons to rule text | A player can explain *why* any action is blocked using only the UI |
| D3 *(presentation pilot in progress)* | Dice visualization | Current pilot: a dark bordered tray, outcome markers for final hit/wound faces using symbol, shape and color; pipped D6 tiles for attack-count/save/damage and prevention dice; brief optional settle animation; a pre-roll conditional raw-damage range; optional overhead Wounds/status with numeric and text cues; local/host provenance plus a hash-chain history reference with integrity limits disclosed. Remaining: runtime viewport-resize and host/guest rendering review | Dice results are legible at a glance and their recorded source/history is visible; the app does not overclaim RNG fairness |
| D4 *(pilot in progress)* | HUD, camera & feedback | Existing phase/turn HUD; manual selected-unit focus; optional short movement, wound-change and destroyed-model cues. Remaining: decision framing, tracers and impact effects, with clear animation controls | The board always answers "whose turn, what phase, whose decision, what just happened" |
| D5 | Inactive-player engagement | Pre-planning/queueing during the opponent's turn, clear "waiting on X deciding Y" with an activity cue | The idle player stays oriented and can plan ahead without blocking the active player |
| D6 | End-of-match loop | Rematch (same armies), save armies, share result | A match ends into a next action, not a dead end |

### E. Accessibility & audio

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| E1 | Accessibility pass | Colorblind-safe guides (shape + color), text scaling, keyboard-only navigation, reduced motion | The game is playable without relying on color or mouse alone |
| E2 | Localization | Localization framework for UI text (the codebase is already bilingual) | UI can ship in additional languages without code changes |
| E3 | Audio | Dice/feedback/error cues, optional ambient, global toggle | Feedback is audible as well as visual; audio is optional and accessible |

### F. Social & meta

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| F1 | Spectator mode | A third party can watch a live match | A spectator joins without disturbing state or leaking hidden info |
| F2 | Replay & result sharing | Share a replay/result with another player | A finished match can be exported/imported as a replay |
| F3 | *Optional* stats & ranking | Match stats browser, leaderboards/ELO | If adopted, competitive integrity is preserved (no pay-to-win) |

### G. Content, licensing & moderation *(decisions that block release)*

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| G1 | Licensing | Code license + data/user-content policy | The project has an explicit license and contribution policy |
| G2 | Monetization | A transparent model (if any) — no hidden costs, no pay-to-win, no coercive pressure | Any paid element is clearly documented with content and limits |
| G3 | Moderation & reporting | Reporting/blocking when internet play and UGC sharing are live | Players can report and block, with a clear content policy |
| G4 | Content catalog strategy | Community-catalog acquisition with no third-party redistribution | The model/catalog pipeline stays within the content boundary |

### H. Quality, delivery & validation

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| H1 | CI & native builds | CI execution on GitHub, native Windows/Linux builds, cross-machine Windows↔Linux matches | Every change is verified on CI; installers run on both OSes |
| H2 | Performance targets | Turn-length, frame-rate and memory budgets | A full match stays within documented performance targets |
| H3 | Telemetry & playtesting | Opt-in telemetry, a playtest plan measuring human outcomes (turn time, abandonment, confusion) | We measure success-without-help, time-to-complete, errors and abandonment — not just automated tests |
| H4 | Release & distribution | Installers, auto-update (if applicable), user docs | A user without Godot installs, connects and completes a match |

## 4. Sequencing

| Phase | Focus | Tracks | Exit criterion |
|---|---|---|---|
| 0 | Foundation | H1 (CI), C1 (slots) | CI green; repository checkpointed |
| 1 | First complete legal match | A1–A5, B1 | Two players finish a legal match on LAN |
| 2 | Product multiplayer | B2–B4 | Internet match with accounts and recovery |
| 3 | Experience & accessibility | D1–D6, E1–E3 | Onboarding, inline rules, dice, HUD and accessibility ship |
| 4 | Social & replay | F1–F3, C2 | Spectate and replay ship |
| 5 | Release | G1, H2–H4 | Windows↔Linux release, licensed, measured |
| 6 | Post-launch expansion | A6 | Broader coverage on top of a stable platform |

**Tracks D and E are not a final polish pass.** They start in parallel with Phase 1 and gate the release alongside rules and networking. A platform without them is a rules engine with a debug UI.

## 5. Definition of done — v1 GA

**Player:** two players install, create/select *legal* armies, connect over LAN **or** internet, play a *legal* mission to a decisive result with rules enforced, survive a disconnect and resume, watch the replay, and read every rule inline — without a README.

**Product:** Windows↔Linux verified on CI, native installers, an explicit license, opt-in telemetry confirming the performance targets, and a support matrix with no shipped "missing" entries.

## 6. Open decisions (decision register)

| Decision | Options | Blocks | Notes |
|---|---|---|---|
| Code/data license | Open-source (MIT/GPL/Apache), source-available | G1, distribution | Content boundary: user visuals and community catalog are not redistributable |
| Monetization | Free, donation, one-time, subscription | G2, internet service cost | Must be transparent, no pay-to-win, age-appropriate |
| Accounts & identity | Anonymous/device, self-hosted, managed service | B3, moderation | Trade-off: privacy vs. friend/invite/social |
| Internet transport service | Self-host relay, third-party service | B2 | Cost, trust, moderation obligations |
| Community catalog strategy | On-demand download, no redistribution | G4 | Already followed; make it an explicit policy |

## 7. Validation & telemetry

**Playtest questions** (measurable):

- First session: can a new player select → move → shoot → confirm **without the README**? (time-to-first-action, errors)
- Can a player explain *why* an action was blocked, using only the UI?
- Do players report trusting the dice, before vs. after dice visualization?
- How long does the inactive player idle, and do they report "I knew what was happening" during the opponent's turn?
- What is the completion rate of a full match, and where do players abandon?

**Telemetry (opt-in):** time-to-first-action, turn/phase duration, idle time, error/blocked-action frequency, disconnect/recovery rate, match completion rate, abandonment points.

## 8. Next five actions (prioritized)

1. **D1 — onboarding / first session.** Guide a new player through a prepared match using the checked sample armies.
2. **D2 — inline rules reference.** Explain supported keywords and disabled-action reasons in the interface.
3. **B1 — lobby & negotiation.** Agree on scenario, pack and options before play.
4. **D3 — dice visualization.** Make dice outcomes readable and show the authoritative results clearly.
5. **H1 — CI execution + native builds.** Turns the existing CI definition into running verification.

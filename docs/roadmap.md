# Open Tabletop — Roadmap

> **Single source of truth for the remaining work to the final product.** This document consolidates and supersedes the [functional roadmap](roadmap-funcional.md) (retained only as the historical increment log) and the [backlog](backlog.md). Current shipped capabilities are summarized separately in the [support matrix](support-matrix.md). This document is the plan forward — not a changelog.

## 1. Product vision

**Open Tabletop is a gaming platform** for two-player Warhammer 40,000 (10th edition) matches on desktop (Windows/Linux). The engine enforces the rules, resolves dice and state authoritatively, and presents a polished, accessible, social experience built around user-supplied visuals. Players bring the armies and the miniatures; the platform brings the board, the rules, the dice and the connection.

What it is **not**: a rules encyclopedia, a single-player AI game, or a "training tool." The combat/training exercises in the current build are implementation/test harnesses and will be absorbed by real matches as rule coverage grows.

- **Target platform:** desktop, Windows and Linux, keyboard + mouse. (Mobile, touch and controllers are out of scope for v1.)
- **Target audience:** tabletop players who already know 40k and want a faithful, faster, easier way to play a match against a friend.
- **North star (player):** *"Set up, connect, and play a complete, legal match — with the rules handled for me and every rule explained where I need it."*

**v1 non-goals:** full vertical geometry / battlefield editor, all factions, single-player AI, mobile, and redistributing third-party miniatures (content boundary — user-supplied visuals remain local and are never transferred between peers).

## 2. Current state (baseline)

| Area | Shipped | Still missing |
|---|---|---|
| Rules | Movement (individual + coherency), morale, shooting, charges/melee, attack planning, weapon selection, defender allocation, mixed defense/Precision, FNP, Hazardous, Devastating Wounds; opt-in Intercessor Objective Secured and Immortal Implacable Eradication; Insane Bravery + full Command Re-roll set | Commanders/attachments, detachments, remaining unit/faction abilities, full datasheet verification, official missions/deployment, complete army legality |
| Multiplayer | Authoritative host, LAN/direct, snapshots, guest seat credentials (HMAC challenge/proof), rejoin after host restart | Lobby negotiation, encrypted internet transport, relay/service, credential reset UI, accounts |
| Persistence | Versioned snapshot, atomic replace, checksum, autosave, draft save, local/LAN resume, seat reservation, RNG continuation, hash-chained event/dice journal with verified reconstruction | Visual replay, multiple slots, journal compaction, cross-version migration |
| Army builder | OpenHammer catalog, filters/variants/budgets, local profiles, six offline presets, four whitelisted core profiles | Detachment/equipment/alliance legality, arbitrary units |
| Models | ForceOrg auto-acquire, cached/HTTPS OBJ+diffuse download, saved pawn links, manual override | GLB, AssetBundles, composites/materials, per-model variants |
| Delivery | Offline verification runner, CI definition, demo export presets | CI execution on GitHub, native builds, cross-platform matches |

Experience, accessibility, social, onboarding, audio, licensing, and telemetry are **not yet represented** as first-class work. Closing that gap is the purpose of this document.

## 3. Tracks and milestones

Remaining work is organized into eight tracks. Each milestone lists its deliverables and its "done when."

### A. Rules & content completeness *(the critical path)*

> **In progress** — the locked 1,000pt target and per-ability execution order are in [track-a.md](track-a.md).

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| A1 | Legal reference armies | Commanders/attachments, detachments, verified unit/faction abilities for the Space Marines + Necrons reference forces; confirm the current Immortal datasheet | Both reference forces build and play as legal lists, every ability sourced and implemented |
| A2 | Official mission & deployment | One official mission with primary/secondary objectives, full timing/scoring/actions, and official deployment rules | Two players complete a legal mission to a decisive result with no unsupported-rule prompts |
| A3 | Points & legality certification | Validate the reference lists at an agreed budget (e.g. 1,000 pts Incursion) | The lists pass official points/update certification |
| A4 | Unified capability registry | One machine-readable "what's supported" registry consumed by the validator, UI and tests | Unsupported content is blocked consistently everywhere from a single source of truth |
| A5 | Remaining core rules for the shipped lists | Cover/terrain edge cases, vertical movement only as the chosen mission requires, complete weapon-trait and ability coverage for shipped lists | The support matrix shows no "implemented but missing X" for shipped content |
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
| D1 | Onboarding / first session | Guided first turn, ready sample armies, "play without reading the README" | A new player selects, moves, shoots and confirms with no external docs |
| D2 | Inline rules reference | Tooltip/glossary for every keyword, weapon trait, stratagem and phase rule; disabled-action reasons link to the rule text | A player can explain *why* any action is blocked using only the UI |
| D3 | Dice visualization | Physical dice tray: dice tumble and settle, pip-level results, success/fail/crit coded by shape + color (not color alone) | Dice results are legible and trustworthy at a glance; RNG fairness is visible |
| D4 | HUD, camera & feedback | Phase/turn HUD bar, camera choreography (focus the current decision), action feedback ("juice"): tracers, impacts, casualties — all toggleable | The board always answers "whose turn, what phase, whose decision, what just happened" |
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

1. **A1 — legal reference armies** (commanders/attachments, detachments, verified abilities). The critical path; everything else is downstream.
2. **A2 — official mission + deployment.** Closes the "complete legal match" loop (Phase 1).
3. **B1 — lobby & negotiation.** Removes the "configure the same exercise on both peers" friction.
4. **D2 — inline rules reference.** Highest design ROI, low technical risk (the keyword model already exists).
5. **H1 — CI execution + native builds.** Turns the existing CI definition into running verification.

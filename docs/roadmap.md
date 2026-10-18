Historical A3 increment (17 October 2026): the [MFM 1.6 reference roster snapshot](roster-validation.md) contains ten fixed profiles, 2/4 repetition limits, the sole-3DP detachment exception and Warlord/Support declarations. It includes 290-point starters, a 930-point Gladius list and an 880-point Awakened list. On 18 October, the full-match certification claim was downgraded because current Space Marines Codex datasheet/effect applicability remains unreconciled. The MFM 1.6 prices were captured 17 October, after the official 14 October update. Treat these as experimental reference matches until the rules review is complete.

Historical Track A status (17 October 2026): A1–A5 were integrated for the documented 930/880 infantry match. As of 18 October, source reconciliation against the new Marine Codex is an active gate; current full-match certification is withheld. Existing mechanics remain available as experimental reference behavior. MFM 1.6 prices were captured 17 October after the 14 October official update.

Current Track D increments: D1 guided first-session entry and D2 contextual help are in progress. The Main menu now prioritizes the guided 290-point checked sample; alternate modes, LAN, resume and advanced setup are collapsed, while army building and optional tools have dedicated tabs. D1 launches the sample locally and gives numbered, progressively revealed steps through mission setup, army declarations, deployment, movement and a confirmed shot. The guide distinguishes available actions from gated or invalid actions and states that the starter sample is not a full-match legality certificate. The D2 pilot explains recognized weapon abilities, current phases, movement/charge/Fight placement choices, supported Battle-shock/Command Re-roll decisions and rule references for selected blocked actions; it is not yet a complete keyword, unit-ability, faction-stratagem and phase reference. A D3 presentation pilot is in progress: overhead model health/status, conditional pre-attack damage ranges, labeled and animated result tiles, success/failure/critical markers for resolved hit and wound rolls, and visible host/local dice provenance with a journal-chain reference. The journal reference helps identify the recorded history and detect changes when validating a matching save; it does not independently prove RNG fairness or unpredictability. D4 now includes manual unit focus plus optional movement, wound-change and destroyed-model cues. Automatic decision framing, projectile tracers and hit/impact effects remain unimplemented.

# Open Tabletop — Roadmap

> **Single source of truth for the remaining work to the final product.** This document consolidates and supersedes the [functional roadmap](roadmap-funcional.md) (retained only as the historical increment log) and the [backlog](backlog.md). Current shipped capabilities are summarized separately in the [support matrix](support-matrix.md). This document is the plan forward — not a changelog.

## 1. Product vision

**Open Tabletop is an open-source experimental platform** for two-player Warhammer 40,000 (11th edition) matches on desktop (Windows/Linux). The final goal is to play with every current faction, datasheet, weapon option and ability; choose missions; and build custom battlefields. The game enforces the selected rules, resolves dice and match state authoritatively, and supports one player hosting a match for a LAN or direct internet connection. Players supply their own miniature visuals.

What it is **not**: a rules encyclopedia, a single-player AI game, or a "training tool." The combat/training exercises in the current build are implementation/test harnesses and will be absorbed by real matches as rule coverage grows.

- **Target platform:** desktop, Windows and Linux, keyboard + mouse. Mobile, touch and controllers are out of scope.
- **Target audience:** tabletop players who want to play a complete match with a friend while the game handles movement, timing, choices, dice and scoring.
- **North star (player):** *"Choose armies and a mission, connect to my opponent, and finish a complete 11th-edition match with the game enforcing the rules."*
- **Hosting model:** one player runs the authoritative host. There is no project-operated game server, account service or monetization plan. Direct internet connections may need router configuration or an optional community/user-operated relay.

**Out of scope:** single-player AI, mobile, project-operated servers/accounts, monetization, and redistributing third-party miniatures or other source content. The battlefield editor is part of the final product but is deliberately the last implementation milestone. Until then, improve and maintain a shared, flexible battlefield that works with the supported missions and terrain rules.

## 2. Current state (baseline)

| Area | Shipped | Still missing |
|---|---|---|
| Rules | Experimental CA infantry reference match: ten fixed e11 profiles, declared Leaders/Warlord/Support, selected mission, captured MFM 1.6 prices, and implemented core/faction rules | Reconcile current Marine Codex/app datasheets/effects before restoring current full-match certification; other armies, optional wargear/enhancements and missions |
| Multiplayer | Authoritative host, LAN/direct address, snapshots, guest seat credentials (HMAC challenge/proof), rejoin after host restart | Match negotiation, secure direct internet connection and practical NAT traversal, credential reset UI |
| Persistence | Versioned snapshot, atomic replace, checksum, autosave, draft save, local/LAN resume, seat reservation, RNG continuation, hash-chained event/dice journal with verified reconstruction | Visual replay, multiple slots, journal compaction, cross-version migration |
| Army builder | OpenHammer candidate catalog, filters/variants/budgets, local profiles, MFM 1.6 reference-price construction and ten experimental fixed-profile admissions | Current Codex applicability, arbitrary units, optional equipment/enhancements and general roster legality |
| Models | ForceOrg auto-acquire, cached/HTTPS OBJ+diffuse download, saved pawn links, manual override | GLB, AssetBundles, composites/materials, per-model variants |
| Delivery | Offline verification runner, CI definition, demo export presets | CI execution on GitHub, native builds, cross-platform matches |

Experience, accessibility, onboarding, audio and release validation remain first-class work. The project is free and open source; there is no monetization or project-operated service to design.

## 3. Tracks and milestones

Remaining work is organized into nine tracks. Each milestone lists its deliverables and its "done when."

### A. Rules & content completeness *(the critical path)*

> **Integrated for the 17 October reference profile; current-source review pending** — the locked roster scope and rule boundaries are in [track-a.md](track-a.md) and [track-a-a5.md](track-a-a5.md).

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| A1 | Checked reference match | Ten fixed-loadout Space Marine + Necron profiles, Leader/attachment declarations, faction/detachment effects and stratagems for the two checked lists | The documented 930/880 infantry lists complete the selected mission with the checked rules; broader armies remain future work |
| A2 | Selected official mission & deployment | CA 2026-27 Battlefield Dominance / Hammer and Anvil, fixed secondaries, deployment, reserves and scoring | The documented match reaches a five-round VP result under the selected profile |
| A3 | Current fixed-roster pricing/construction | MFM 1.6, Incursion ceiling, 2/4 repetitions, sole-3DP exception, Warlord/Support checks; see scope above | The ten admitted profiles and checked lists pass the documented construction validation |
| A4 | Unified capability registry | One machine-readable "what's supported" registry consumed by the validator, UI and tests | Unsupported content is blocked consistently everywhere from a single source of truth |
| A5 | Remaining core rules for the reference lists | [Gladius 930 vs Awakened 880](track-a-a5.md): Command Re-roll plus Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge | Core mechanics are implemented for the fixed profile; current Codex reconciliation restores certification, with remaining 1,000-point fill as catalog work |
| A6 | Expand current-edition faction content | Start with the [Space Marines source catalog](space-marines-catalog.md), then admit current datasheets, weapon options, abilities, detachments and points in verified slices; continue across all current factions | Every released profile is versioned, executable, validated and accurately represented in the support matrix |
| A7 | Mission selection and breadth | Selectable mission profiles, deployments, objectives and scoring, each tied to a compatible battlefield definition | Players can configure and complete every mission profile marked supported |
| A8 | Complete rules coverage | Remaining shared core rules, vertical geometry, vehicles, transports, aircraft, reinforcements and faction interactions | The published support matrix has no unsupported rules within the declared current-edition release scope |

### B. Multiplayer & platform networking

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| B1 | Lobby & negotiation | Scenario/pack/option agreement, readiness/accept, immutable pre-match manifest | Both clients agree on a configuration before any rules run, with no out-of-band setup |
| B2 | Direct internet transport | Secure host-to-guest connection, address/share flow and documented NAT/port-forwarding behavior; optional community/user-operated relay adapter | Two players connect directly to the host and complete a match over the internet |
| B3 | Local seat recovery | Credential reset/transfer UI and clear reconnection flow using the existing host-owned seats | A guest can recover their seat after a reconnect without accounts or a project service |
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

### F. Replay & post-match

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| F1 *(optional)* | Spectator mode | A third party can watch a live match | A spectator joins without disturbing state or leaking hidden info |
| F2 | Replay & result export | Save and exchange a replay/result file directly between players | A finished match can be replayed from its journal and shared without a hosted account service |
| F3 *(optional)* | Local match history | Browse results and statistics stored on this device | Players can review their own local matches without ranking or remote telemetry |

### G. Open-source content policy

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| G1 | Code and content policy | Keep the code license explicit; document source provenance, update versions and what user-supplied content stays local | Contributors can tell which code and data may be redistributed and which assets/catalogs must be acquired by each player |
| G2 | Community maintenance | Reproducible contribution and rules-source review workflow | A rules/content change records edition, faction source, update version and validation scope |

The project remains free and non-commercial. No monetization, account system or project-operated game service is planned. Rules and point references must retain their source/version boundaries; user visuals and third-party catalogs are not bundled by default.

### H. Quality, delivery & validation

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| H1 | CI & native builds | CI execution on GitHub, native Windows/Linux builds, cross-machine Windows↔Linux matches | Every change is verified on CI; installers run on both OSes |
| H2 | Performance targets | Turn-length, frame-rate and memory budgets | A full match stays within documented performance targets |
| H3 | Playtesting | A local playtest plan measuring human outcomes (turn time, abandonment, confusion) | Results can be recorded and shared voluntarily; the game does not require a telemetry service |
| H4 | Release & distribution | Installers, auto-update (if applicable), user docs | A user without Godot installs, connects and completes a match |

## 4. Sequencing

| Phase | Focus | Tracks | Exit criterion |
|---|---|---|---|
| 0 | Structural foundation | Architecture boundaries, content identity/versioning, H1 | Rules, content, match orchestration, transport and UI have documented owners and stable contracts |
| 1 | Checked complete match foundation | A1–A5, B1, C | Two players finish the verified reference match and can resume it |
| 2 | Rules and faction expansion | A6, A8 | Each admitted increment expands playable, source-checked coverage without false support claims |
| 3 | Missions and shared battlefield | A7 plus shared-map improvements | Multiple supported missions work on the maintained shared battlefield |
| 4 | Host-led online play | B2–B3 | A guest completes and recovers a direct internet match with the user-hosted server |
| 5 | Experience, access and release | D, E, H, G | The current declared rules scope is usable, reproducible and distributable on Windows/Linux |
| 6 | Battlefield editor — final implementation milestone | I | Players can create, validate, save, share and host custom maps with explicit rules geometry |

**Tracks D and E are not a final polish pass.** They start in parallel with Phase 1 and gate the release alongside rules and networking. A platform without them is a rules engine with a debug UI.

## 5. Definition of done — v1 GA

**Player:** two players install, create/select legal armies from every supported current-edition faction, choose a mission and battlefield, connect over LAN or directly over the internet with one player hosting, play to a decisive result with rules enforced, survive a disconnect and resume, watch the replay, and read every supported rule inline.

**Product:** free and open source, Windows/Linux builds verified, explicit code/content policy, reproducible match versions, and a support matrix that accurately states the current complete-edition coverage. The map editor is delivered after rules, missions, hosting and release-critical work.

## 6. Open decisions (decision register)

| Decision | Options | Blocks | Notes |
|---|---|---|---|
| Code/data policy | MIT code; source-attributed, versioned rule references; player-supplied local visuals | G1, distribution | Do not bundle third-party catalogs or miniatures by default |
| Monetization | None | None | Free, experimental and non-commercial |
| Identity | Local host-issued seat credentials | B3 | No account or identity service |
| Internet connection | Direct connection to the player host; optional user/community-operated relay later | B2 | No project-operated server; document port forwarding and VPN options |
| Map workflow | Shared maintained battlefield first; in-game editor last | I | Missions and rules geometry must work before custom map creation |

## 7. Validation & playtesting

**Playtest questions** (measurable):

- First session: can a new player select → move → shoot → confirm **without the README**? (time-to-first-action, errors)
- Can a player explain *why* an action was blocked, using only the UI?
- Do players report trusting the dice, before vs. after dice visualization?
- How long does the inactive player idle, and do they report "I knew what was happening" during the opponent's turn?
- What is the completion rate of a full match, and where do players abandon?

Record time-to-first-action, turn/phase duration, idle time, blocked-action frequency, disconnect/recovery rate, match completion and abandonment points during local playtests. Players may choose to share reports; no remote telemetry backend is part of the product plan.

## 8. Next five actions (prioritized)

1. **Bulk e11 baseline.** Refresh an ignored local OpenHammer snapshot for the selected faction, retain its digests and provider IDs, and expand the candidate identity ledger without calling imported units playable.
2. **Reconcile the existing Marine baseline, then the first vertical slice.** Recheck the existing fixed profiles against the current Codex, current official MFM/app data and applicable updates. Then pick a coherent new Space Marines group and implement its complete profile, options and required mechanics. Keep unresolved records out of current-edition support claims while independent work continues.
3. **Capability/source registry.** Represent source provenance, provisional/current-reference/GW-checked status, implementation and validation scope per unit/rule/mission in one inspectable contract.
4. **Rules windows.** Make timing, triggers, choices, costs and effect duration explicit shared engine concepts and grow reusable handlers from the vertical slice.
5. **B1 — lobby & negotiation.** Have both peers verify the same immutable content, mission and battlefield manifest before play; keep the shared battlefield data-driven and defer its editor to the final milestone.

### I. Battlefield editor *(final implementation milestone)*

Until the final milestone, maintain one flexible shared battlefield and make its dimensions, deployment zones, objective positions, terrain footprints and elevations data-driven so every supported mission can use it. Do not start a player-facing map editor ahead of rules and mission completeness.

| # | Milestone | Deliverables | Done when |
|---|---|---|---|
| I1 | Custom battlefield authoring | Place and resize terrain, define height/footprint/traversability/visibility, objectives and deployment zones; validate and version map files | Two peers load the same map hash and the rules engine uses the same geometry the editor previews |
| I2 | Map library and sharing | Local map library, import/export and compatibility checks against mission/rules versions | A player can choose a saved map for a LAN or internet-hosted match and unsupported geometry is clearly rejected |

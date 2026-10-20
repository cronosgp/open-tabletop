# Track A — First complete legal match (working plan)

**Locked target:** 1,000-point Incursion, **Space Marines (Gladius Task Force)** vs **Necrons (Awakened Dynasty)**, one Warlord character per side, one official matched-play mission, on a 60 × 44-inch board for the selected current Chapter Approved scenario (the 43 × 43 board remains a training option).

**Rules baseline:** official **11th edition**, with the user's [Wahapedia e11 reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and current official faction/Codex updates. Superseded profiles are migration work, not completion of the current legal-match target. The current Marine army rule is Combat Doctrines; Gladius uses Codex Discipline. See [source policy](../data/source-assessment.md#required-rules-baseline).

## Progress

- **A1–A5 integrated for the checked match.** The 930-point Gladius and 880-point Awakened fixed infantry lists complete the selected CA 2026-27 mission under the documented current e11 profile. See [A5 scope and stratagem windows](track-a-a5.md) and [recorded verification](../verification/verification-results.md).
- **A3 roster construction:** [MFM 1.6 fixed-profile pricing and Incursion validation](../rules/roster-validation.md), including 2/4 repetition limits, sole-3DP exception and Warlord/Support formation checks. Two 290-point starters and the checked 930/880 lists are available; filling to 1,000 points needs more admitted datasheets.
- **A2 mission:** [CA 2026-27 mission and deployment](../rules/chapter-approved-mission.md), including fixed-scenario/custom-terrain scope. Other missions, layouts and rosters remain separate.
- **A4 capability registry:** one registry feeds the current admission, validation and interface rules (`scripts/edition_11/capabilities.gd`, `tests/test_capabilities.gd`).
- **Current abilities and faction effects:** [ten fixed-loadout unit profiles](../rules/current-unit-abilities.md), [Combat Doctrines + Codex Discipline](../rules/combat-doctrines.md), [Awakened Dynasty Command Protocols](../rules/awakened-dynasty.md), and scoped [Reanimation Protocols](../rules/reanimation-protocols.md) are implemented with documented source/version boundaries. Historical Oath and incompatible abilities remain isolated. Slain Character revival and other unadmitted compositions are out of scope.
- **Detachment/core stratagems:** [checked Gladius/Awakened cards](../rules/detachment-stratagems.md), Command Re-roll, Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge are available for the checked lists. Enhancements and Explosives/Smokescreen/Crushing Impact remain blocked where unsupported.

This document records Track A's scoped completion and the rule boundaries for the roadmap's [Track A](roadmap.md#a-rules--content-completeness-the-critical-path). The checked match uses 930/880-point lists under the 1,000-point cap; it does not claim complete 1,000-point lists or general-purpose army legality.

## Candidate army lists (draft)

Point values below are historical snapshot costs, retained for old profiles, **not current prices**. Use the [MFM 1.6 table and starters](../rules/roster-validation.md) for checked matches. Final complete 1,000-point compositions remain open.

**Space Marines — Gladius Task Force**
| Unit | Role | Ref. points | Abilities to implement |
|---|---|---|---|
| Captain | Warlord, Character | 80 | Leader/Warlord, Strategic Acumen, Finest Hour and Transhuman Strategist implemented |
| Intercessor Squad | Battleline | 80 | Current Bolter Discipline and Tactical Mainstay implemented; historical effects isolated |
| Terminator Squad | Infantry | 160 | Deep Strike, Teleport Homer and Fury of the First implemented; Judgement is superseded |
| Assault Intercessor Squad | Battleline | 75 | Targeted Intercession implemented |
| Heavy Intercessor Squad | Battleline | 100 | Unyielding in the Face of the Foe implemented |
| Lieutenant | Character | 45 | Support, Tactical Precision and Demi-company Commander implemented; Target Priority superseded |

**Necrons — Awakened Dynasty**
| Unit | Role | Ref. points | Abilities to implement |
|---|---|---|---|
| Overlord | Warlord, Character | 90 | Leader, My Will Be Done, Implacable Resilience and Resurrection Orb implemented |
| Necron Warriors | Battleline | 85 (×10) | Their Number is Legion implemented |
| Immortals | Battleline | 70 (×5) | Current Implacable Eradication implemented, including optional successful-wound rerolls |
| Royal Warden | Character | 50 | Leader, Adaptive Strategy and Engrammatic Logic implemented |

## Rules to implement

### Faction rules
- Space Marines: **Combat Doctrines** — current e11 effect implemented. Historical Oath is superseded compatibility/training code and must not be combined with current doctrines. The ten admitted fixed-loadout datasheets use the current ability profile in the checked match; other lists remain outside scope.
- Necrons: **Reanimation Protocols** — September 2026 faction effect implemented for one-wound Warriors/Immortals, living Overlords and admitted Overlord attachments; slain Characters and broader healing remain pending. See [scope and source boundary](../rules/reanimation-protocols.md).

### Detachment rules
- Gladius Task Force: **Codex Discipline** — implemented: one shared additional doctrine selection per battle. Other Gladius options outside the checked match remain pending.
- Awakened Dynasty: **Command Protocols** — e11 +1 to hit while led implemented. Admitted attached-unit healing is integrated; other compositions remain pending; see [scope](../rules/awakened-dynasty.md).

### Leader / attachment
- Current e11 attachment declarations and Warlord/Support requirements are implemented for admitted profiles. An attached unit retains combined strength; admitted Overlord attachments integrate with Reanimation. The checked mission and current fixed-profile MFM checks are available. Remaining work is broader roster/catalog coverage, optional wargear and other missions/layouts.

### Unit ability stage

The requested ten fixed-profile unit types are covered by [current unit abilities](../rules/current-unit-abilities.md). This includes the four formerly proposed types, optional free rerolls, current Leader/Support permissions and minimal Terminator reserve/Homer mechanics. Current regular Captain does not lead Terminators. Optional unselected weapon/shield variants, broader armies, enhancements/other detachment stratagems and full legality are not included in this stage.

## Mission (A2)

[Selected CA 2026-27 scenario](../rules/chapter-approved-mission.md): Battlefield Dominance for both Take and Hold armies, Hammer and Anvil, fixed Engage on All Fronts + Assassination. Includes 60 × 44 terrain-objective board, central-configuration/role/first-turn roll-offs, Defender-first deployment, private reserve declarations, official score timing/caps and five rounds even after wipeout. Custom agreed ground-level terrain is used; other cards, interactive terrain authoring and recommended event layouts are outside this profile. The checked lists and mission are certified together for the documented fixed profile.

## Execution order

1. **A4 — Capability registry implemented.** The registry supports current admission, validation and interface states.
2. **A1 — Leaders, faction rules and abilities implemented for the checked profiles.** Current e11 rules replace historical names where documented; attachment/Reanimation scope and exclusions are recorded in their rule pages.
3. **A1 — Detachment effects and stratagems implemented for the checked lists.** Gladius Codex Discipline, Awakened Command Protocols and the documented Gladius/Awakened cards are covered; unsupported options remain blocked.
4. **A2 — Selected mission and deployment implemented.** See the CA 2026-27 profile and its custom-terrain/source boundaries.
5. **A3 — Current fixed-roster pricing/construction implemented.** MFM 1.6 checks cover the ten admitted profiles and checked rosters.
6. **A5 — Remaining infantry core implemented for the checked lists.** [Command Re-roll windows plus Fire Overwatch, Heroic Intervention, Counteroffensive and Epic Challenge](track-a-a5.md) complete the documented match. Explosives/Smokescreen/Crushing Impact stay blocked because these loadouts do not expose those keywords/roles. Filling 930/880 to 1,000 points is catalog work after Track A.

## Source verification

Faction/detachment rules and the Immortal datasheet must be verified against current sources before being marked supported — the existing [source-assessment](../data/source-assessment.md) discipline applies. No ability is implemented from memory alone.

## Open decisions

- Final complete 1,000-point lists: current MFM prices are pinned; the two starter lists use 290 points each. Checked Incursion lists are a **930-point Gladius** list (Captain, 4 Heavy Intercessors, 2 Terminators) and an **880-point Awakened** list (2 Overlords, 2 Royal Wardens, 4 Warrior squads, 4 Immortal squads). Filling the remaining points still needs more admitted datasheets.
- Selected mission is pinned to the documented CA 2026-27 scenario; other mission/deck/layout choices are future expansion.
- Player Warlord declarations are enforced before deployment; both Overlord and Royal Warden have their admitted fixed-profile abilities.
- After Track A, new datasheets follow [faction catalog admission](../data/faction-catalog.md) and the A6 local-source migration. Do not pick or implement a candidate from an API record; first verify its current Wahapedia export record and official update boundary.

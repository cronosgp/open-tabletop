# Track A — First complete legal match (working plan)

**Locked target:** 1,000-point Incursion, **Space Marines (Gladius Task Force)** vs **Necrons (Awakened Dynasty)**, one Warlord character per side, one official matched-play mission, on the existing 43 × 43-inch board.

This is the execution plan for the roadmap's [Track A](roadmap.md#a-rules--content-completeness-the-critical-path). Goal: two players complete a **legal** 1,000pt match from deployment to a decisive result, with every rule the chosen lists and mission require implemented and verified; everything else stays blocked.

## Candidate army lists (draft)

Point values below are the pinned snapshot's reference costs, **not** certified official points. Exact composition and points are finalized in step **A3**.

**Space Marines — Gladius Task Force**
| Unit | Role | Ref. points | Abilities to implement |
|---|---|---|---|
| Captain | Warlord, Character | 80 | Leader (attachment) + Warlord |
| Intercessor Squad | Battleline | 80 | Target Elimination *(Objective Secured already done)* |
| Terminator Squad | Infantry | 160 | Deep Strike, Teleport Homer, Judgement of the Weak, Fury of the First |
| Assault Intercessor Squad | Battleline | 75 | Targeted Intercession |
| Heavy Intercessor Squad | Battleline | 100 | Unyielding in the Face of the Foe |
| Lieutenant | Character | 45 | Leader, Tactical Precision, Target Priority |

**Necrons — Awakened Dynasty**
| Unit | Role | Ref. points | Abilities to implement |
|---|---|---|---|
| Overlord | Warlord, Character | 90 | Leader, My Will Be Done, Implacable Resilience, Resurrection Orb |
| Necron Warriors | Battleline | 85 (×10) | Their Number is Legion |
| Immortals | Battleline | 70 (×5) | Implacable Eradication *(ref implemented; verify current datasheet)* |
| Royal Warden | Character | 50 | Leader, Adaptive Strategy, Engrammatic Logic *(optional second character)* |

## Rules to implement

### Faction rules (both disabled today)
- Space Marines: **Oath of Moment** *(verify wording/effect vs current source)*
- Necrons: **Reanimation Protocols** *(verify vs current source)*

### Detachment rules (neither exists)
- Gladius Task Force: **Combat Doctrines**
- Awakened Dynasty: **+1 to Hit while led** (confirm exact detachment rule vs current source)

### Leader / attachment
- Implement the `Leader` mechanic: which characters may attach to which units, single-bodyguard rule, and Warlord designation.

### Remaining unit abilities
- Terminators: Deep Strike *(implies a minimal reserves/placement system)*, Teleport Homer, Judgement of the Weak, Fury of the First.
- Intercessors: Target Elimination.
- Warriors: Their Number is Legion.
- Immortals: confirm current Implacable Eradication datasheet (the existing reference uses a prior-edition source).

## Mission (A2)

One official Incursion mission: a deployment map + primary + secondary objectives with official round/scoring timing, replacing the custom five-round training mission. Prefer a mission with a simple deployment layout to bound the first increment; objective-control and Secure Ground already exist as building blocks.

## Execution order

1. **A4 — Capability registry.** Consolidate the scattered `DISABLED` string, `unsupported_rules` and `disabled_abilities` arrays into one machine-readable registry consumed by the validator, UI and tests. This is the foundation for cleanly admitting new abilities.
2. **A1 — Leaders & attachments.** Implement `Leader` + Warlord; whitelist the Captain and Overlord in `army_capabilities.gd`.
3. **A1 — Faction rules.** Oath of Moment, then Reanimation Protocols.
4. **A1 — Detachment rules.** Combat Doctrines, then Awakened Dynasty.
5. **A1 — Unit abilities.** Terminators (Deep Strike + the three datasheet abilities), Warriors (Their Number is Legion), Intercessors (Target Elimination), and verify Immortals.
6. **A2 — Official mission + deployment.**
7. **A3 — Points & legality certification.**
8. **A5 — Only as required.** Deep Strike already pulls in minimal reserves; upper floors, exact mesh visibility and transports stay blocked unless the chosen mission demands them.

## Source verification

Faction/detachment rules and the Immortal datasheet must be verified against current sources before being marked supported — the existing [source-assessment](source-assessment.md) discipline applies. No ability is implemented from memory alone.

## Open decisions

- Final exact lists and points (A3) — the snapshot costs are reference values.
- Which official mission (A2).
- Necron Warlord: **Overlord** (90, 4 abilities) is recommended for a real leader; Royal Warden (50, 2 abilities) is the lower-scope alternative.

# Gladius and Awakened stratagems (Track A)

Enabled only with **checked Incursion rosters**. These are the current e11 Gladius Task Force and Awakened Dynasty stratagems implemented for the documented fixed-roster scope. This implementation boundary does not certify every Codex interaction. Enhancements remain outside the fixed-loadout profile.

## Implemented

- **Adaptive Strategy (1 CP, your Command):** one Adeptus Astartes unit uses a chosen Combat Doctrine until your next Command. It does not spend army doctrine uses or Codex Discipline.
- **Storm of Devastation (1 CP, your Shooting):** one Adeptus Astartes unit that has not shot this phase: its ranged attacks have [Ignores Cover] for that shoot. Source weapon profiles are copied, not mutated.
- **Armour of Contempt (1 CP, opponent Shooting or Fight):** one Adeptus Astartes unit: incoming attacks have AP worsened by 1 until that attacking unit has finished. Digital use is declared on the defending unit; the first attacker that then targets it is bound for the rest of its attacks.
- **Might of Angels (1 CP, Fight):** one Adeptus Astartes unit that is fighting: melee attacks have [Lance]. The +1 to Wound applies only if that unit Charged this turn, matching the core Lance rule.
- **A Worthy Death (1 CP, Fight):** one Adeptus Astartes unit that has not been selected to fight: when a model is destroyed, roll D6; on a 4+ it remains until that unit has fought or the Fight phase ends.
- **Responsive Tactics (1 CP, opponent Movement):** after an enemy unit ends a move within 8" of a friendly unengaged Adeptus Astartes Infantry/Mounted unit, that unit may make a normal move of up to D6". Printed name taken from the current Gladius card listing (Wahapedia heading was blank in the scrape).
- **Protocol of the Hungry Void (1 CP, Fight):** one Necrons unit that has not been selected to fight: +1 melee Strength this phase; if a Necron Character is leading it, also improve melee AP by 1 without stacking with a stronger AP improvement.
- **Protocol of the Sudden Storm (1 CP, your Movement):** one Necrons unit: ranged weapons have [Assault] until the end of the turn. If a Necron Character is leading it, the Advance D6 may be re-rolled in the existing movement window without spending extra CP.
- **Protocol of the Conquering Tyrant (1 CP, your Shooting):** one Necrons unit that has not shot: attacks against a target within half range re-roll hit rolls of 1, or all failed hit rolls if a Necron Character is leading the unit.
- **Protocol of the Undying Legions (1 CP, after enemy attacks):** one Necrons unit that lost models to those attacks activates Reanimation Protocols for D3 wounds, or D3+1 if led. Their Number is Legion still applies. This does not consume the army's end-of-Command Reanimation.
- **Protocol of the Eternal Revenant (1 CP, end of any phase):** one Necron Infantry Character that was just destroyed this phase is set up unengaged, not attached, starting strength 1, with remaining wounds equal to half its starting wounds (rounded up). Once per model per battle. Closest-possible placement is a controller duty; the engine enforces unengaged battlefield set-up.
- **Protocol of the Vengeful Stars (1 CP, opponent Shooting):** just after an enemy unit destroys a Necron unit, one living Necron Character unit within 6" of the destroyed unit may shoot as if it were your Shooting phase, but only at that enemy unit.

Each use costs 1 CP unless My Will Be Done is armed. One friendly stratagem per unit per phase, shared with core stratagems. Battle-shocked units cannot be targeted.

## Remaining for a complete legal Gladius vs Awakened match

Enhancements stay rejected by A3. Complete 1,000-point Necron compositions, remaining core rules and official-match certification are still outside this card set.

## Sources checked 17 October 2026

- [Space Marines / Gladius Task Force](https://wahapedia.ru/wh40k11ed/factions/space-marines/)
- [Necrons / Awakened Dynasty](https://wahapedia.ru/wh40k11ed/factions/necrons/)

The per-rule source and scope ledger is [space-marines-rules-ledger.json](space-marines-rules-ledger.json). The current Gladius reference describes Armour of Contempt as changing incoming AP until the attacking unit has attacked; the implementation binds the first attacker that targets the selected unit for the remainder of that attack sequence. The precise official Codex/update locator for that binding is still pending, so this stays within the existing fixed-roster scope and is not evidence for broader Astartes support.

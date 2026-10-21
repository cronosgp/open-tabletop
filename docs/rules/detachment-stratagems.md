# Gladius and Awakened stratagems (Track A)

Enabled only with **checked Incursion rosters**. These are the current e11 Gladius Task Force and Awakened Dynasty stratagems implemented for the documented fixed-roster scope. This implementation boundary does not certify every Codex interaction. Enhancements remain outside the fixed-loadout profile.

## Implemented

- **Adaptive Strategy (1 CP, your Command):** one Adeptus Astartes unit uses a chosen Combat Doctrine until your next Command. It does not spend army doctrine uses or Codex Discipline.
- **Storm of Devastation (1 CP, your Shooting):** one Adeptus Astartes unit that has not shot this phase: its ranged attacks have [Ignores Cover] for that shoot. Source weapon profiles are copied, not mutated.
- **Armour of Contempt (1 CP, opponent Shooting or Fight):** when an enemy unit targets one of your Adeptus Astartes units, you may use this stratagem on that target. Attacks by that same enemy unit targeting it worsen AP by 1 until that enemy unit has attacked. The game opens the reaction after the actual attack target declaration and binds the named attacker before rolling attack dice.
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

## Brethren doctrine mastery

The local Wahapedia export lists three additional Codex detachments. Assault Brethren permits Assault Doctrine one additional time per battle (`Assault Mastery`, row `000011203`); Tactical Brethren permits Tactical Doctrine one additional time (`Tactical Mastery`, row `000011219`); Devastator Brethren permits Devastator Doctrine one additional time (`Devastator Mastery`, row `000011211`). These fixed extra uses are enforced by the Combat Doctrines selection limit and are available in the prepared-match detachment selector. All three Assault Brethren stratagems now use local runtime paths: `Armour of Contempt` (`000011205002`) binds -1 AP to the enemy unit that triggered the choice, `Duty in Death` (`000011205004`) opens at enemy attack declaration and adds +1 to its casualty roll with Assault Doctrine, and `Gene-Wrought Might` (`000011205003`) grants Lance and the same doctrine's +1 AP. All three Tactical Brethren stratagems and both enhancements have focused local checks: `Armour of Contempt` (`000011221002`) binds -1 AP to its triggering attacker, `Domination Fire` (`000011221003`) applies -1 to Hit through the start of your next turn to an enemy unit hit by the shooting unit, and `Masterful Tactics` (`000011221004`) grants a D6-inch Normal Move or a fixed 6 inches while Tactical Doctrine is active. `Laurels of Vigilance` (`000011220002`) discounts eligible Overwatch/Heroic Intervention once per battle round per army, and source-restricted `Tactical Insight` (`000011220003`) adds Tactical Doctrine to its Captain's unit. All three Devastator Brethren stratagems and both enhancements also pass local checks: `Armour of Contempt` (`000011213002`) binds -1 AP to its triggering attacker; `Storm of Fire` (`000011213003`) grants Ignores Cover and +1 AP while Devastator Doctrine is active; `Hail of Vengeance` (`000011213004`) grants 2 CP retaliatory shooting after enemy fire destroys a model, locked to that shooter. `Master-forged Firearms` (`000011212002`) improves the bearer's ranged attacks except Psychic attacks, and `Honour of Vigilance` (`000011212003`) grants Lethal Hits and a free Advance re-roll with Devastator Doctrine. Local focused checks pass; network validation is deferred and full army legality remains uncertified.

Terminator Storm Force is also available in that selector. Its `Death Blow` rule (local export row `000011199`) adds 1 to Charge rolls for friendly Adeptus Astartes Terminator units. The modifier enters through the shared charge-roll calculation. Local runtime checks remain pending; its enhancements and stratagems are not implemented yet.

Tacticus Firestorm Force is available in the selector. Its `Codex Fire-patterns` rule (local export row `000011227`) applies the Rapid Fire bonus to friendly Tacticus units when targeting an enemy at any distance up to the weapon's maximum range. The rule is included in attack-plan generation and the shared attack-sequence fallback. Local runtime checks remain pending; its enhancements and stratagems are not implemented yet.

Tacticus Attack Force is available in the selector. Its `Wrath of the Chapter` rule (local export row `000011191`) lets friendly Tacticus units re-roll their Advance roll once for 0 CP. The choice appears after the Advance roll and before movement; the replacement result is mandatory. Local runtime checks remain pending; its enhancements and stratagems are not implemented yet.

Gravis Linebreaker Force is available in the selector. Its `Walking Fortress` rule (local export row `000011207`) applies for the turn after a friendly Gravis unit makes a Normal move: its ranged weapons lose Heavy and gain +1 to Hit. The move is tracked through the unit's turn state; both attack-plan paths remove Heavy before attack validation and apply the capped hit modifier. Local runtime checks remain pending; its enhancements and stratagems are not implemented yet.

Wrath of the Rock is available in the selector. Its `Dutiful Tenacity` rule (local export row `000010154`) worsens Wound rolls by 1 when Strength exceeds Toughness and attacks target friendly Adeptus Astartes Infantry or Mounted units. The modifier is applied through the shared defensive wound calculation. Local runtime checks remain pending; Dark Angels-only army restrictions and the detachment's enhancements and stratagems are not implemented yet.

Ironstorm Spearhead's three local stratagem implementations are pending focused local validation and are blocked from admission and use: `Layered Ceramite` (`000008479002`), `Might of the Machine Spirit` (`000008479003`) and `Headhunter Doctrine` (`000008479004`). The documented effects describe their bounded implementation scope only; they are not currently offered or resolved. Direct BS characteristic modifiers are not modeled. Network validation is deferred and full army legality is uncertified.

## Remaining for a complete legal Gladius vs Awakened match

Enhancements stay rejected by A3. Complete 1,000-point Necron compositions, remaining core rules and official-match certification are still outside this card set.

## Sources checked 17 October 2026

- [Space Marines / Gladius Task Force](https://wahapedia.ru/wh40k11ed/factions/space-marines/)
- [Necrons / Awakened Dynasty](https://wahapedia.ru/wh40k11ed/factions/necrons/)

The per-rule source and scope ledger is [space-marines-rules-ledger.json](../space-marines-rules-ledger.json). The Gladius card row `000008352002` in the local Wahapedia e11 export supplies the timing and effect text; runtime eligibility and attack-sequence behavior still await local checks. Network validation remains deferred to final integration.

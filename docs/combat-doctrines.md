# Space Marine Combat Doctrines and detachments — current e11 effects

The project's definitive rules source is Wahapedia **11th edition**. Current structured data comes from local source book `000000139`, export revision `2026-10-16T21:03:46+03:00`; Storm-swift Onslaught's rule text comes from the local Wahapedia faction-page extraction (App 2.8.1, observed 2026-10-17) because its `Detachment_abilities.csv` row is absent. The [e11 core rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) supply shared movement and weapon effects; [Space Marines rules](https://wahapedia.ru/wh40k11ed/factions/space-marines/) provide faction page context. Network validation remains deferred.

The current army rule is **Combat Doctrines**, replacing Oath. Prepared-match selection currently offers Gladius, Stormlance, Ironclad Champions, Assault/Tactical/Devastator Brethren, Terminator Storm Force, Tacticus Firestorm Force, Tacticus Attack Force, Gravis Linebreaker Force, Wrath of the Rock and Spearpoint Task Force. Focused local checks cover Gladius, Stormlance, Ironclad Champions, Assault/Tactical/Devastator Brethren, Death Blow, Codex Fire-patterns, Wrath of the Chapter, Walking Fortress, Dutiful Tenacity and Spearpoint. The other detachment effects and full chapter/army restrictions remain pending; these checks do not certify full detachment or army legality. Older Gladius profiles remain isolated as historical training code.

## Implemented scope

Enable **Match setup → Advanced match options → Next prepared match: 11e Combat Doctrines + Space Marine detachment**, then choose the detachment effect. This declares the selected effect for the admitted Marine force; the choice is included in the match identity and both LAN players must agree. Spearpoint also enables current unit abilities because Suboden Khan's end-of-Fight-phase move uses that phase-choice workflow. Current doctrines and the historical Oath option cannot be enabled together. The checked saved-roster snapshot and selected CA mission remain Gladius-only. The older Oath profile remains historical training code and is not current-rule certification.

At own Command start, choose a doctrine or explicitly choose none. The choice precedes core CP gain and Battle-shock. Choosing or declining costs no CP or dice; the subsequent normal core CP is gained once. Declining preserves uses. A doctrine lasts until the start of the next own Command and remains active during the opponent's turn. Expiry happens before choosing again.

- **Devastator:** ranged attack profiles receive Assault. The effective profile is a copy; original weapons are unchanged. It enables the existing e11 assault-shooting path, retaining its engagement, range, visibility and weapon-selection restrictions.
- **Tactical:** Fall Back does not block shooting or charge declaration. Actual Fall Back movement, leaving engagement, hazards where applicable and other eligibility still resolve normally.
- **Assault:** Advance does not block charge declaration. It does not grant the Assault weapon keyword or permit unrelated shooting.

Each doctrine has one normal use. Codex Discipline supplies **one shared additional use**, spent when a previously selected doctrine is selected a second time. It does not grant one extra use of every doctrine or a third use of one doctrine. The selector marks choices that spend this extra use and shows whether it is spent. After all uses are exhausted, Command proceeds without an empty mandatory choice. The engine also tests the army rule without the Gladius effect; the current prepared-match option explicitly selects Gladius.

These doctrine effects come from the pinned local Wahapedia e11 extraction. They apply to the admitted Marine force, not the opponent or a foreign/mixed faction. They change shooting/charge eligibility only; actions, existing action commitments, engagement, charge range, once-per-phase use and placement requirements still apply. The shared query supports simultaneous doctrine effects: `codex-adept` keeps all three doctrines active for Guilliman; `author-of-the-codex` grants one doctrine to a visible friendly Astartes unit within 12 inches during Movement until the next own Command; and `primarch-of-the-xiii` grants nearby friendly Astartes hit/wound re-rolls of 1 within 6 inches. Guilliman's other implemented effects and selectable profile are recorded in [his implementation note](marine-guilliman.md).

## Gladius stratagems in the local source

The local export links six Gladius stratagems to detachment `000000750`. Their executable scope is covered by `detachment_stratagems.gd` and the targeted detachment suite:

| Source ID | Stratagem | Local effect |
|---|---|---|
| `000008352005` | Adaptive Strategy | One friendly Astartes unit gains a selected doctrine through the next own Command phase. |
| `000008352006` | Storm of Devastation | Selected unit's ranged attacks gain Ignores Cover for the attack activation. |
| `000008352002` | Armour of Contempt | Attacks by the enemy unit that triggered the choice worsen AP by 1 until it has attacked. |
| `000008352004` | Might of Angels | The selected unit's melee attacks gain Lance; the core Lance rule supplies its charge-dependent Wound bonus. |
| `000008352003` | A Worthy Death | Models destroyed before their unit fights can remain on a 4+ until that unit fights or the phase ends. |
| `000008352007` | Responsive Tactics | A friendly unengaged Infantry/Mounted unit can Normal Move up to D6 after an enemy ends within 8 inches. |

The detachment's `Codex Discipline` ability is export row `000008355`; its shared extra doctrine use is checked by the doctrine suite.

## Stormlance Task Force

The local export identifies Stormlance as detachment `000000796`, with `Reconnaissance` disposition. Its **Lightning-fast Strike** ability is row `000008485`: friendly Adeptus Astartes **Mounted** and **Speeder** units have +2 inches Movement. The runtime applies this to each eligible unit's Normal, Advance and Fall Back allowance through the shared remaining-movement calculation. Other units receive no bonus. The option records `stormlance` in the public match manifest and refuses unsupported detachment names.

The local runtime implements the three Stormlance stratagems: Wind-Swift Evasion opens a Normal Move/Fall Back preview at the end of the Fight phase for a Mounted unit that was eligible to fight, using each model's Movement characteristic and Stormlance bonus; Sudden Onslaught fixes the Advance roll to 6 when the unit is selected to Advance; Hurtling Targets offers the defending player a reaction before ranged attack dice and applies -1 to Hit for that phase. Focused local checks passed for those stratagems; obstacle and crowded-base movement edge cases remain to cover.

The local consolidated army catalog now carries both Stormlance enhancements from export rows `000008486002` and `000008486003`, each priced at 10 points and gated to the exported datasheet-to-enhancement mappings. The Army Workshop assigns an enhancement to one selected unit entry; when the entry contains multiple copies, one copy is split off before assignment. Training admission adds the points, rejects ineligible profiles and duplicate enhancement choices, and requires Stormlance at match setup. Supercharged Engines offers the free Advance re-roll in the normal pre-movement decision. Auspex Triangulation Shrines offers the start-of-Shooting selection for a visible enemy within 12 inches and adds 3 inches to that enemy's detection range while marked spotted. The export text gives the spotted mark no expiry, so the implementation retains it for the battle. Focused local checks passed in `test_stormlance_enhancements.gd`; network validation remains deferred and full army legality remains uncertified.

## Spearpoint Task Force

The local Wahapedia faction-page extraction supplies the detachment rule because Spearpoint's identity is present in the structured export but its `Detachment_abilities.csv` row is absent. **Storm-swift Onslaught** lets Adeptus Astartes units declare a charge in a turn in which they Advanced or Fell Back; the charge validator applies this permission to eligible units. **Wrath of the First Khan** triggers at Fight-phase end when Suboden Khan's unit destroyed at least one enemy unit during that phase and is outside Engagement Range. It offers a Normal Move of up to 6 inches through the placement preview. The White Scars-only army restriction is checked against chapter keywords recognized by the current runtime. Selecting Spearpoint enables current unit abilities for the movement-choice workflow. `test_suboden_khan.gd` checks the charge permission and destroyed-enemy trigger/distance; local execution passed, while full White Scars army legality and network validation remain deferred.

The local structured export includes **Spear Thrust and Sabre Swing** (`000010630005`, 1 CP). When an eligible Adeptus Astartes unit is selected to fight, its melee attacks gain Lethal Hits or Lance; if the unit has Mounted, they gain both. The attack-profile path applies the chosen keywords through that Fight phase, and the ordinary stratagem-use checks enforce CP discounts, one use of this stratagem per phase and one stratagem per unit per phase. Focused local checks passed in `test_spearpoint_stratagems.gd`; network validation remains deferred.

All four Spearpoint enhancements now use export rows `000010629002`–`000010629005`, exact `Datasheets_enhancements.csv` eligibility, and their listed points in the local catalog. Stormseer's Wisdom opens the free Advance re-roll after the first roll; Chogorian Huntmaster advances the effective ingress round, allowing its eligible Mounted/Speeder unit to arrive in round 1; Hunter's Eye adds Ignores Cover and Sustained Hits 1 to the bearer's unit ranged attacks; Spearpoint Paragon modifies only the bearer’s melee profile, with the larger bonus after a Charge move. Focused local checks pass in `test_spearpoint_enhancements.gd`; network validation and full faction legality remain deferred.

**Flawless Riders** (`000010630004`, 1 CP) can be used in your Movement or Charge phase when a friendly Adeptus Astartes Mounted unit is selected to move or declares a charge. The unit gains Mobile for that phase; the existing declaration window and terrain path rules handle the choice and effect. Focused local checks passed; full Mobile terrain/charge interaction checks remain pending.

**Evasive Manoeuvres** (`000010630002`, 1 CP) is offered when an enemy Shooting attack targets a friendly Adeptus Astartes Mounted/Speeder unit. The defender may spend 1 CP before attack dice; ranged attacks targeting that unit suffer -1 to Wound for the phase. It shares the mounted-unit reaction decision with Stormlance's Hurtling Targets. Focused local checks passed.

**Mobile Lethality** (`000010630003`, 1 CP) is offered when an Adeptus Astartes unit is selected to Advance or Fall Back in your Movement phase. Its ranged weapons gain Assault for the turn, and Falling Back does not make it ineligible to shoot. The choice is resolved before movement rolls and uses the regular attack and engagement restrictions afterward. Focused local checks passed.

**Withdraw and Regroup** (`000010630006`, 1 CP) is offered at the end of your opponent's Fight phase for an unengaged Adeptus Astartes Mounted/Speeder unit on the battlefield. The selected unit is moved into the existing Strategic Reserves flow. Focused local checks passed.

**Hunter's Instincts** (`000010630007`, 1 CP) is offered after an enemy unit ends a move within 8 inches of a friendly, unengaged Adeptus Astartes Infantry/Mounted/Speeder unit in your opponent's Movement phase. It rolls D3 and opens the existing reaction-move placement flow for a Normal Move up to D3+3 inches. Focused local checks passed.

Setup rejects Stormlance with the checked saved-roster snapshot or selected CA mission, whose compatibility has not been reconciled. Gladius' local export lists `Priority Assets` while prior page-context review recorded multiple dispositions; that mission compatibility is unresolved. This does not claim full Space Marines coverage or army legality.

## Assault Brethren

The local Wahapedia export rows `000011205002`–`000011205004` define the three Assault Brethren stratagems. **Armour of Contempt** reacts to an enemy targeting an Astartes unit in the opponent's Shooting phase or either Fight phase; it binds -1 AP to that enemy until it has attacked. **Duty in Death** reacts when an enemy targets the unit in the Fight phase; before the unit fights, destroyed models roll to remain, with +1 to the D6 if Assault Doctrine is active. **Gene-Wrought Might** is used when a unit is selected to fight and grants its melee attacks Lance, plus +1 AP with Assault Doctrine. The prepared-training path enables the cards, and their target declaration, attack and casualty flows are covered by the passing targeted detachment suite. Network validation remains deferred.

## Authority and recovery

Implementation ID: `combat-doctrines-11e-gladius-v1`. Owners, declared detachment, active doctrine, selection turn, spent selections, shared extra-use flag and deferred core-CP step are public serializable state. Gladius retains the prior match identity and default for older saves; Stormlance adds its detachment ID to the match manifest. Setup/saved-list options freeze the selection. Disabled matches retain their previous pack identity, and inconsistent save/peer flags are rejected.

The host validates phase, active player, revision, doctrine and remaining uses. Clients send doctrine IDs rather than effects or dice. While a choice is pending, gameplay commands and tactical destinations are blocked. Save/load and authenticated rejoin after restarting the host preserve the pending choice and CP step. Selecting after restoration consumes no dice or duplicate CP. Effective ranged weapons and frozen attack plans continue through the existing fast and staged attack paths.

The local focused run `.tools/verification/20261019T220424916822Z/results.json` passed import, offline checks, startup, `test_capabilities` and `test_combat_doctrines`. The doctrine suite also checks detachment identity, option rejection, mission restriction, Stormlance Mounted/Speeder eligibility, mixed keyword handling and no Infantry bonus. `tests/test_combat_doctrines_network.gd` covers the pending Gladius doctrine choice and authenticated rejoin; separate-machine and cross-platform network validation remains deferred. Graphical QA for the new selector was not captured. These fixtures do not establish complete rules compliance or army legality.

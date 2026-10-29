# Vow-sworn Crusaders

Vow-sworn Crusaders is a **partial local implementation** for the 11th-edition Space Marines rules. It requires Black Templars Chapter context and the current unit-abilities option.

At the start of the first battle round, the Black Templars player may select one of the three Templar Vows or skip selection:

- `Abhor the Witch, Destroy the Witch`: current-reference Adeptus Astartes melee attacks against a PSYKER unit gain Precision and Lance. Lance adds its normal +1 to Wound roll only when the attacking unit made a Charge move this turn.
- `Accept Any Challenge, No Matter the Odds`: current-reference Adeptus Astartes melee attacks gain +1 to Wound when the target's Toughness is greater than that attack profile's Strength, subject to the shared wound-modifier cap.
- `Uphold the Honour of the Emperor`: at the end of the player's Movement phase, an objective controlled by a current-reference Adeptus Astartes Infantry unit is secured. Those Infantry units can start otherwise eligible actions after Advancing; Falling Back still prevents action starts unless another supported rule permits them.

All other action gates remain active. These effects require current unit abilities and Black Templars Chapter context.

## Focused local verification

`tests/test_templar_vows.gd` passes in `.tools/verification/20261027T025046843904Z/results.json`. It submits Abhor the Witch through the public unit-command path, then checks each Vow in a current-reference scenario: Abhor's Lance Charge condition and Precision target gate, Accept Any Challenge's Toughness/Strength comparison, and Uphold's secured objective and post-Advance action eligibility. The four enhancement paths pass focused offline verification in `.tools/verification/20261029T094844825000Z/results.json` (6/6 processes, `network: false`): sampled admission/bearer checks, Consecrating Aura's granted and preserved saves, Incendiary Animus through melee AttackPlan, Zealous Vanguard through the shared pre-battle Scout flow, and Augury Servo-host's visible-target/cover-denial/phase-expiry flow through a public command. All six stratagem effects also pass focused local checks in the 29 October 11/11-process run at `.tools/verification/20261029T095653298940Z/results.json` (`network: false`). Full public saved attack continuations for Pious Enmity, For the Emperor's Honour! and Spoor of the Unholy, Dread Crusaders' saved Charge/Leadership reroll continuation, every eligible bearer combination, network validation, playtesting and full army legality remain open. The checked-roster/direct-selection Force Disposition path passes; Purge the Foe matchup defaults and sealed reveal remain unsupported.

## Implemented enhancements

The 20-point `Consecrating Aura` can be assigned to one of 23 export-linked bearer profiles in the current construction catalog. The bearer’s unit has a 5+ invulnerable save. Models in that unit keep any better invulnerable save they already have.

The 25-point `Incendiary Animus` can be assigned to one of five export-linked Chaplain or Judiciar profiles in the current construction catalog. The bearer’s unit gets +1 Strength on its melee attacks. Both enhancements require the Vow-sworn Crusaders detachment, current unit abilities and Black Templars Chapter context.

The 25-point `Zealous Vanguard` can be assigned to one of 23 current-catalog bearer profiles linked by the local export. Its unit gains Scouts 6 through the shared pre-battle Scout move or Strategic Reserves set-up flow. It requires Vow-sworn Crusaders, current unit abilities and Black Templars Chapter context. The focused check confirms Scouts 6 enters the normal pre-battle Scout move flow; the enhanced reserve set-up path remains untested.

The 20-point `Augury Servo-host` can be assigned to one of 23 current-catalog bearer profiles linked by the local export. In the Shooting phase, the enhanced unit can select one visible enemy unit within 18 inches; that target cannot benefit from cover for the phase. Focused offline checks cover the public selection command, cover denial in AttackPlan, once-per-phase use and expiry at phase end; see the verification report above.

`Pious Enmity` (1 CP) is now offered when a friendly Chaplain or Judiciar unit is selected to fight, in either player's Fight phase. Choose melee Hit rerolls of 1, or choose the option that also rerolls Wound rolls of 1 when those melee attacks target a MONSTER or VEHICLE unit. The choice resumes the saved attack declaration before attack preparation. Focused checks cover both choices and Hit/Wound rerolls of 1 against a Redemptor; the complete saved attack continuation remains unverified.

`For the Emperor's Honour!` (1 CP) is offered when a friendly Adeptus Astartes Infantry unit is selected to fight in either player's Fight phase. If used, that unit's melee attacks gain Precision for the phase. The choice resumes the saved attack declaration before attack preparation. Focused checks confirm Precision in the Chaplain melee AttackPlan; the complete saved attack continuation remains unverified.

`Spoor of the Unholy` (1 CP) is offered when a friendly Adeptus Astartes unit is selected to attack in its Shooting phase or either player's Fight phase. If used, that unit ignores BS/WS and Hit roll modifiers for the attack phase. The choice resumes the saved attack declaration before attack preparation. Focused checks confirm removal of a stationary Heavy Bolt Rifle Hit modifier; the complete saved declaration and other modifier contexts remain unverified.

`Dread Crusaders` (1 CP) is offered during the opponent's Charge phase when an enemy unit selects a friendly Adeptus Astartes Infantry unit as a charge target. The defender may spend 1 CP to make the charging unit take a Battle-shock roll at -1. The reaction suspends and resumes the saved Charge target-selection frame. Focused checks confirm the eligible reaction, CP use and -1 modifier; the saved Charge continuation remains unverified.

If the charging unit is within range of an eligible `Tempered in Battle` aura, its controller may keep the result or re-roll both Leadership dice; the Dread Crusaders modifier remains -1. A successful roll does not clear Battle-shock already present on the charging unit. This optional Leadership reroll continuation remains unverified.

`Devout Push` (1 CP) is offered when a friendly Adeptus Astartes Infantry unit is selected for a pile-in or consolidation in the Fight phase. Roll D3+3 and use that distance for each model’s placement through the shared contact movement flow. CP discounts and the once-per-phase gate apply. If placement is canceled, positions are restored while the CP and roll remain spent; resuming placement does not charge CP again. Focused checks confirm the persisted pile-in roll and paid cancellation/resume path.

`Heresy Begets Retribution` (1 CP) is offered during the opponent’s Movement phase after an enemy unit ends a move within 8 inches of a friendly Adeptus Astartes Infantry unit. The friendly unit must be unengaged and have not moved this phase. Roll D6, select the closest enemy unit as the Surge target (the controlling player chooses among tied closest units), then preview each model up to that distance. Models that can reach Engagement Range must end engaged with the Surge target; other models must end as close as possible. The move must preserve coherency and cannot end engaged with a different enemy unit. A bounded waypoint graph supports detours around terrain and blocking bases, and each segment uses shared movement validation. Enemy Engagement Range endpoint restrictions now use exact line-circle intersections, so narrow safe intervals between enemy zones are considered. The regression and connected Crusader/Fist checks passed in `.tools/verification/20261029T075602211222Z/results.json` (6/6 processes, `network: false`). The 29 October target-placement follow-up checks the whole moving formation and terrain-route lower bounds for every supporting model. The wall-separated placement regression passed in the connected 6-process offline run at `.tools/verification/20261029T082036208546Z/results.json` (SHA-256 `35E571F774D5F6B6D99651B3464F240D4F9D417E689A771A38DAA7F7940673F7`). The latest focused stratagem check enters this trigger, rolls D6 and completes a legal Surge endpoint in `.tools/verification/20261029T095653298940Z/results.json`. Unknown and search-limited proofs retain the engagement requirement; finite waypoint and coherent-placement search still do not certify every legal route or group placement. Broader playtesting remains pending.

## Unsupported scope

The checked Incursion roster profile records the export-listed 2 DP Force Disposition, Purge the Foe. Direct-selection Chapter Approved setup offers that choice and requires direct primary-mission selections for both players. The sealed matchup-default flow remains unavailable because its Purge the Foe primary mapping is not implemented. This is local practice, not army-legality certification; full public saved attack and Charge continuations, network validation, playtesting and full army legality remain open.

## Source and implementation record

- Rules reference: [Wahapedia, Space Marines, 11th edition](https://wahapedia.ru/wh40k11ed/factions/space-marines/), App 2.8.1, observed 26 October 2026.
- Local Data Export: snapshot `20261021T130623Z`, revision `20260817b`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`.
- `Detachments.csv`, row `000001230`: SHA-256 `e8790f57ee8210513102bc736ddd72d24e4a70ddffba6f09d92244d68b12c585`.
- `Detachment_abilities.csv`, row `000011171` (`Templar Vows`): SHA-256 `92121fb215c41e5ff2c7c33a38c7ca0835f91887fb41670dc6a17694d1c3d7fe`.
- `Stratagems.csv`, row `000011173006` (`Pious Enmity`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Stratagems.csv`, row `000011173003` (`For the Emperor's Honour!`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Stratagems.csv`, row `000011173005` (`Spoor of the Unholy`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Stratagems.csv`, row `000011173002` (`Dread Crusaders`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Stratagems.csv`, row `000011173007` (`Devout Push`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Stratagems.csv`, row `000011173004` (`Heresy Begets Retribution`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
- `Enhancements.csv`, row `000011172002` (`Augury Servo-host`): SHA-256 `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`.
- `Enhancements.csv`, row `000011172003` (`Consecrating Aura`): SHA-256 `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`.
- `Enhancements.csv`, row `000011172004` (`Incendiary Animus`): SHA-256 `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`.
- `Enhancements.csv`, row `000011172005` (`Zealous Vanguard`): SHA-256 `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`.
- `Datasheets_enhancements.csv`, relation `enhancement_id=000011172002` (37 source datasheets): SHA-256 `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.
- `Datasheets_enhancements.csv`, relation `enhancement_id=000011172003` (37 source datasheets): SHA-256 `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.
- `Datasheets_enhancements.csv`, relation `enhancement_id=000011172004` (6 source datasheets): SHA-256 `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.
- `Datasheets_enhancements.csv`, relation `enhancement_id=000011172005` (37 source datasheets): SHA-256 `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`.
- Runtime implementation: `scripts/edition_11/templar_vows.gd`; enabled capability: `templar-vows`.
- `Pious Enmity` uses `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/combat_scenario.gd`, `scripts/edition_11/attack_plan.gd` and `scripts/edition_11/unit_actions.gd`; enabled capability: `vow-sworn-pious-enmity`.
- `For the Emperor's Honour!` uses `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/combat_scenario.gd`, `scripts/edition_11/attack_plan.gd` and `scripts/edition_11/unit_actions.gd`; enabled capability: `vow-sworn-for-the-emperors-honour`.
- `Spoor of the Unholy` uses `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/combat_scenario.gd`, `scripts/edition_11/attack_plan.gd` and `scripts/edition_11/unit_actions.gd`; enabled capability: `vow-sworn-spoor-of-the-unholy`.
- `Dread Crusaders` uses `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/combat_scenario.gd` and `scripts/edition_11/unit_actions.gd`; enabled capability: `vow-sworn-dread-crusaders`.
- `Devout Push` uses `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/combat_scenario.gd`, `scripts/edition_11/match_command_service.gd` and `scripts/main.gd`; enabled capability: `vow-sworn-devout-push`.
- `Heresy Begets Retribution` uses `scripts/edition_11/heresy_retribution.gd`, `scripts/edition_11/detachment_stratagems.gd`, `scripts/edition_11/unit_actions.gd` and `scripts/main.gd`; enabled capability: `vow-sworn-heresy-begets-retribution`.
- Enhancement runtime implementation: `scripts/edition_11/stormlance_enhancements.gd`, `scripts/edition_11/defender_groups.gd`, `scripts/edition_11/attack_plan.gd`, `scripts/edition_11/unit_abilities.gd`, `scripts/edition_11/scout_moves.gd` and `scripts/edition_11/unit_actions.gd`; enabled capabilities: `augury-servo-host`, `consecrating-aura`, `incendiary-animus` and `zealous-vanguard`.

The export supplies local detachment and ability facts; the live 11th-edition faction page remains the selected rules reference. No export data is copied into this document beyond row identity and provenance.

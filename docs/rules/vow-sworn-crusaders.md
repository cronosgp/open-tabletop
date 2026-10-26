# Vow-sworn Crusaders

Vow-sworn Crusaders is a **partial local implementation** for the 11th-edition Space Marines rules. It requires Black Templars Chapter context and the current unit-abilities option.

At the start of the first battle round, the Black Templars player may select one of the three Templar Vows or skip selection:

- `Abhor the Witch, Destroy the Witch`: current-reference Adeptus Astartes melee attacks against a PSYKER unit gain Precision and Lance. Lance adds its normal +1 to Wound roll only when the attacking unit made a Charge move this turn.
- `Accept Any Challenge, No Matter the Odds`: current-reference Adeptus Astartes melee attacks gain +1 to Wound when the target's Toughness is greater than that attack profile's Strength, subject to the shared wound-modifier cap.
- `Uphold the Honour of the Emperor`: at the end of the player's Movement phase, an objective controlled by a current-reference Adeptus Astartes Infantry unit is secured. Those Infantry units can start otherwise eligible actions after Advancing; Falling Back still prevents action starts unless another supported rule permits them.

All other action gates remain active. These effects require current unit abilities and Black Templars Chapter context.

## Implemented enhancements

The 20-point `Consecrating Aura` can be assigned to one of 23 export-linked bearer profiles in the current construction catalog. The bearer’s unit has a 5+ invulnerable save. Models in that unit keep any better invulnerable save they already have.

The 25-point `Incendiary Animus` can be assigned to one of five export-linked Chaplain or Judiciar profiles in the current construction catalog. The bearer’s unit gets +1 Strength on its melee attacks. Both enhancements require the Vow-sworn Crusaders detachment, current unit abilities and Black Templars Chapter context.

The 25-point `Zealous Vanguard` can be assigned to one of 23 current-catalog bearer profiles linked by the local export. Its unit gains Scouts 6 through the shared pre-battle Scout move or Strategic Reserves set-up flow. It requires Vow-sworn Crusaders, current unit abilities and Black Templars Chapter context. Focused checks are pending.

The 20-point `Augury Servo-host` can be assigned to one of 23 current-catalog bearer profiles linked by the local export. In the Shooting phase, the enhanced unit can select one visible enemy unit within 18 inches; that target cannot benefit from cover for the phase. Focused checks are pending.

`Pious Enmity` (1 CP) is now offered when a friendly Chaplain or Judiciar unit is selected to fight, in either player's Fight phase. Choose melee Hit rerolls of 1, or choose the option that also rerolls Wound rolls of 1 when those melee attacks target a MONSTER or VEHICLE unit. The choice resumes the saved attack declaration before attack preparation. Focused checks remain pending.

## Unsupported scope

`Dread Crusaders`, `For the Emperor's Honour!`, `Heresy Begets Retribution`, `Spoor of the Unholy` and `Devout Push` are not implemented. The detachment's 2 DP Force Disposition is not enforced. This option is for local practice and does not certify army legality. Focused checks, playtesting and network validation remain pending.

## Source and implementation record

- Rules reference: [Wahapedia, Space Marines, 11th edition](https://wahapedia.ru/wh40k11ed/factions/space-marines/), App 2.8.1, observed 26 October 2026.
- Local Data Export: snapshot `20261021T130623Z`, revision `20260817b`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`.
- `Detachments.csv`, row `000001230`: SHA-256 `e8790f57ee8210513102bc736ddd72d24e4a70ddffba6f09d92244d68b12c585`.
- `Detachment_abilities.csv`, row `000011171` (`Templar Vows`): SHA-256 `92121fb215c41e5ff2c7c33a38c7ca0835f91887fb41670dc6a17694d1c3d7fe`.
- `Stratagems.csv`, row `000011173006` (`Pious Enmity`): SHA-256 `9e01eb024e3fc851e4717f3a4f0c5f73f29c5bd87d08fd94e999f35f7e57b621`.
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
- Enhancement runtime implementation: `scripts/edition_11/stormlance_enhancements.gd`, `scripts/edition_11/defender_groups.gd`, `scripts/edition_11/attack_plan.gd`, `scripts/edition_11/unit_abilities.gd`, `scripts/edition_11/scout_moves.gd` and `scripts/edition_11/unit_actions.gd`; enabled capabilities: `augury-servo-host`, `consecrating-aura`, `incendiary-animus` and `zealous-vanguard`.

The export supplies local detachment and ability facts; the live 11th-edition faction page remains the selected rules reference. No export data is copied into this document beyond row identity and provenance.

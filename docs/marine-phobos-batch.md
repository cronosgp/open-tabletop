# Phobos batch — targeted local validation passed

Targeted local validation ran on 18 October 2026. `test_infiltrator_squad.gd` and `test_phobos_lieutenant.gd` passed, alongside the local catalog, roster, reserve, capability, Infiltrators and Ancient regressions in verification run `.tools/verification/20261019T022024657123Z`. The runner passed 13 processes, including import, Python checks and startup. The full local suite and network validation remain pending; this batch does not establish full army legality.

## Sources and admitted scope

Reviewed 18 October 2026 against [Wahapedia Infiltrator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infiltrator-Squad), sheet `000000128`, and [Lieutenant In Phobos Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-In-Phobos-Armour), sheet `000002530`, shared App Space Marines book `000000139`. Local export revision: 16 October 2026, 21:03:46 GMT+3. Core [01.02.02, 02.02.04, 24.31 and 24.33](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) govern duration, healing, Scouts and Stealth. Chapter, Boarding Actions and unadmitted bodyguard variants remain excluded.

Infiltrators support 5/10 models at 85/150 points, with M8/T4/Sv3/W2/Ld6/OC1 and 32mm bases. The carbine, pistol and fists use separate fixed weapon instances; the carbine keeps Precision and Rapid Fire. The squad's deployment ability uses the existing ground-board Infiltrators checks. Optional Helix equipment is selected on exactly one Infiltrator during preparation. Selecting another bearer transfers it, and removing it leaves the unit unequipped. It neither replaces weapons nor grants healing without a surviving equipped source.

Helix Gauntlet uses the shared D3 healing preview in the owner's Command phase. It can heal the attached Lieutenant and can return destroyed non-Characters under the existing survivor-first and placement rules. A dead equipped bearer supplies no action. Reset preserves the original budget. Mandatory useful Command healing includes both Helix and Narthecium choices; their labels and usage records remain separate. This batch retains the existing battlefield-source healing scope and does not certify new off-board healing interactions.

Omni-scramblers is a separate Shooting-phase action. Visibility and 18-inch unit range are checked before applying the mark; its detection benefit cannot bootstrap selection of an otherwise invisible target. A phase-stamped target mark adds three inches of detection, expires with the phase and does not stack with another identical mark. It can combine with the different Eliminator Optics bonus. It does not spend CP, consume shooting or require the unit to be unshocked. The once-per-phase source-unit limit is recorded independently of shooting.

The 40-point Phobos Lieutenant has M8/T4/Sv3/W4/Ld6/OC1 on 40mm. Pistol versus carbine is an exclusive reversible preparation swap; melee blades remain. Tactical Precision and Demi-company Commander reuse existing mechanisms. It is a Support and must join admitted Infiltrators or Eliminators before setup can finish. Other source-linked bodies remain outside admission; it does not use the Tacticus Lieutenant's attachment list or Apothecary pairing exception.

## Mixed-unit eligibility

Infiltrators deployment checks now recognize each reviewed provider individually. A Phobos Lieutenant attached to either admitted bodyguard preserves this ability. It does not supply Stealth, so attaching it to Eliminators prevents the whole unit from qualifying for all-model Stealth; their separate unit-level cloak rule is unchanged.

Scouts 6 inches is retained as source metadata on the Lieutenant and its all-model eligibility predicate is explicit. Both currently admitted mandatory bodyguards lack Scouts. Consequently, no legal completed formation introduced here qualifies for a Scout move; no general Scout movement controller is claimed implemented. Supporting future Scout-capable bodies requires implementing that controller before their admission. After combat casualties, an isolated Lieutenant cannot retroactively take a pre-battle Scout move.

Deep Strike is similarly model-specific and requires every model in a unit. The mixed Phobos formations do not qualify. Reserve selection now uses that whole-unit condition, and an unattached mandatory Support cannot enter reserves before formation declarations. Existing complete Terminator formations retain their eligibility. Regression of that shared change is pending the final run.

The profile digest now includes the alternate Terminator Captain, Gravis Captain and Phobos Lieutenant equipment helpers, avoiding silent compatibility changes from alternate loadout data.

## Written tests and UI evidence

`test_infiltrator_squad.gd` covers 5/10-model pricing, mixed-unit deployment eligibility, optional single Helix bearer transfer/removal, D3 healing previews, attached-character healing, revival, excess/usage/source boundaries, detection duration/combination, hidden/out-of-range selection and rejected actor/revision commands.

`test_phobos_lieutenant.gd` covers source stats, Support links, conditional Lethal Hits, mixed Deep Strike/Scouts/Stealth eligibility, exclusive gun swaps across attachment, reserve restrictions and doctrine response. `marine_phobos_fixture.gd` is shared data preparation. Both targeted suites passed. Earlier `test_infiltrators.gd` remains the existing core-deployment suite and was not overwritten.

The UI preserves existing layout, typography and controls. Context help identifies the single optional Helix bearer, transfer/removal, the exclusive Lieutenant swap and detection duration. Healing displays the actual source name. The inspected real Godot capture `.tools/phobos-batch-preparation.png` shows a staged 1600x1000 preparation fixture, the selected Helix option and readable help. No pre-implementation capture or full interaction validation is claimed. It is not a completed match or test-pass report.

Final-run queue: the complete Space Marine suite, including mixed-unit Stealth, detection/Optics, shared healing/Apothecary, Support matching, doctrines, preparation/UI startup and capability metadata. Game/network validation remains deferred to final integration. Runtime inventory is 27 shared-book Marines and four Necrons, with 58 shared-book Marine identities unimplemented. See the [audit](marine-phobos-batch-audit.json).

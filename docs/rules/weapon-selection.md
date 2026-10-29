# Hunter profiles and Extra Attacks

The combat planner now supports Hunter target restrictions and multiple Extra Attacks weapon instances. The current Intercessor/Warrior practice inventory does not contain those weapons. This increment does not grant equipment from other datasheets to those models or enable complete Terminator/Techmarine units.

## Hunter

A Hunter profile can target a unit with at least one of its specified keywords. Repeated imported Hunter entries are alternatives, so Monster/Vehicle accepts either. Matching uses exact keywords, ignoring case, and the combat exercise collects keywords from living target models. Names and destroyed models do not qualify.

The target dropdown filters by the selected profile; the host repeats the check before any dice. Target eligibility is frozen with the declaration, before earlier attack pools cause casualties. Range, engagement, visibility and phase restrictions still apply independently.

Both the repeated keyword entries and structured required_keywords_any restrictions in the imported Chainfist profile are preserved. Conflicting or malformed restrictions reject. Unknown target restrictions and unimplemented conditional keyword parameters also reject, rather than being discarded during import.

To inspect this with current imported data, open the attack sequence lab, choose Terminator Squad and Chainfist - Hunter, then compare Necron Warriors against a Land Raider defender. Infantry is rejected; a Vehicle passes the Hunter check. The lab remains an isolated calculation of one profile and does not enable army abilities or legal equipment validation.

## Extra Attacks

For each engaged model, select one eligible ordinary melee weapon, if available, and every eligible Extra Attacks weapon. An inventory containing only Extra Attacks weapons can fight. An ordinary Hunter weapon without any legal target does not prevent its eligible Extra Attacks weapons from fighting.

Each physical weapon selects one profile and uses that profile's full fixed A. It can split its own attacks among legal engaged targets independently of the other selected weapons. Two ordinary weapons remain prohibited; duplicate profiles of one instance and under/over-assigned attack counts reject before dice. Random melee A supports one whole weapon against one target; splitting those random attacks remains restricted. Profiles of one physical weapon that disagree about whether it has Extra Attacks are conservatively blocked as unresolved equipment.

The planner preserves Extra Attacks assignments when changing the ordinary weapon, and preserves other weapon instances when editing one Extra Attacks weapon. It marks those options and numbers otherwise identical choices. Confirmation explains missing required weapons. The quick melee shortcut selects the first ordinary option legal against its chosen target and all legal Extra Attacks instances. Use the full planner when the weapons need different targets.

Selection traits are checked before pooling identical attack properties. Different ordinary and extra weapons may then share a pool. Their physical instances remain distinct for assignments, attack counts and Hazardous tests. Defender-selected allocation resolves every pool before finishing the unit's single fight activation.

## Conditional attack traits

Anti-X requires the defending unit to have the named keyword; the matching unmodified Wound threshold becomes a Critical Wound. The attack resolver admits Anti-Psyker alongside Anti-Monster and Anti-Vehicle and uses the target's actual keywords. Lazarus's Enmity's Edge Anti-PSYKER 2+ is covered against PSYKER and non-PSYKER targets by the attack-sequence regression and its fixed profile through AttackPlan. Unknown Anti keywords remain explicit validation blockers.

Lance adds 1 to Wound only when the attacking unit made a Charge move this turn. Lance is accepted by weapon import and validation, then applied when building the attack plan; Suboden's Stormtooth test checks the charged condition. This is the core weapon rule, separate from any other ability that grants a weapon Lance.

## Validation and scope

The implementation follows [Core Rules §§04.01.03, 24.11 and 24.11.01](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/). Weapon selection introduced protocol v18; the current advanced-defense increment uses v21. Both peers need the updated build.

Twenty-three local suites and nine host/client loopback scenarios passed on Windows. New tests use actual imported Chainfist and servo-arm profiles on a synthetic test unit, covering Hunter alternatives and malformed restrictions, ordinary/extra completeness, independent targets, extra-only inventories, physical-weapon Hazardous counts, defender allocation, client filtering and host rejection of invalid requests. Visual checks covered Hunter filtering, missing-extra feedback, a completed multi-weapon plan and numbered identical instances. Synthetic test equipment is not a legal playable roster.

[Advanced defense](advanced-defense.md) now covers Monster/Vehicle shooting, attached combat, mixed defending groups, prevention and single-target random melee A. The isolated lab reports Extra Attacks as a selection rule outside its single-profile calculation; full multi-weapon enforcement belongs to the combat planner. [Devastating Wounds](devastating-wounds.md) is now supported. Further core work includes remaining weapon keywords and damage modifiers. Linux and separate-machine LAN remain unverified. Battlefield editing remains low priority.



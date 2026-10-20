# Six selectable Marine profiles: reconciliation increment

**Subsequent user decision, 18 October 2026:** [Wahapedia e11 is the definitive source](rules-source-policy.md). The official-locator gates recorded below describe the earlier review and are superseded. The remaining actionable gates are complete Wahapedia source/scope reconciliation and executable interaction validation; certification is not automatically restored.

Observed 18 October 2026. This historical review covers the original six-profile fixed-loadout pass, not complete datasheet, Chapter or army legality. Guilliman was outside that original scope; his current admission is recorded in [the Guilliman note](marine-guilliman.md).

## Evidence and remaining gates

The six e11 reference pages were opened directly. Their characteristic and default weapon tables agree with `current_reference_marine_profiles.gd`. The review found missing EXPLOSIVES and TACTICUS keywords on Captain and Lieutenant; reference profile v3 restores both. Its changed identity and digest enter match content identity. That keyword correction alone did not enable Explosives or general transport rules. [Explosives](explosives.md) was implemented separately in the subsequent core increment.

| Profile / reference locator | Fixed scope compared | Next source/interaction gate |
|---|---|---|
| [Intercessor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Intercessor-Squad), characteristics, ranged/melee tables, abilities and composition | Five models, default weapons and both rifle modes; Bolter Discipline and Tactical Mainstay identities | Exact official datasheet/amendment locator; action exceptions and objective eligibility |
| [Assault Intercessor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessor-Squad), same sections | Five models, default pistol/chainsword; Targeted Intercession identity | Exact official locator; charge timing and attached-model modifier scope |
| [Heavy Intercessor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Heavy-Intercessor-Squad), same sections | Five models, default rifle/pistol/fists; Unyielding identity | Exact official locator; controlling objectives, OC and save interaction |
| [Terminator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Squad), same sections | Five models, default storm bolters/power fists and invulnerable save; Homer/Fury identities | Exact official locator; reserve distances, token timing, unit-distance measurement and chapter-conditional keywords. Runtime's TERMINATOR SQUAD identity tag is not a source keyword certification |
| [Captain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain), same sections plus Keywords and Leader | Default equipment, characteristics; missing keywords repaired | Exact official locator; Strategic Acumen, Finest Hour, Transhuman Strategist and legal pairings |
| [Lieutenant](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant), same sections plus Keywords and Support | Default equipment, characteristics; missing keywords repaired | Exact official locator; Demi-company Commander, conditional Lethal Hits and legal support pairings |

These are reference comparisons and identified follow-up checks, not completed interaction audits. Optional wargear and ten-model units remain outside the admitted scope. Existing points remain the recorded MFM 1.6 snapshot from 17 October.

## Official cross-check boundary

- [GW, Emboldened Astartes, 30 September 2026](https://www.warhammer-community.com/en-gb/articles/rylbvfnv/warhammer-40000-balance-update-emboldened-astartes/), Toughness and Weapons sections: corroborates broad characteristic/weapon changes; does not confirm each complete profile or keyword list.
- [GW, First look: Space Marines datasheets, 14 September 2026](https://www.warhammer-community.com/en-gb/articles/paxsnmde/first-look-space-marines-datasheets/): the consulted preview covers selected other datasheets, including Guilliman. It supplies no full-text locator for these six profiles.
- [GW downloads hub](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/), Munitorum Field Manual section: observed update label 14 October 2026. The linked [Marine MFM endpoint](https://mfm.warhammer-community.com/en/space-marines) failed in the web reader during this pass. This is not evidence that prices changed or remained unchanged; no new price certification is claimed.
- [Requested e11 core reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) opened for edition boundary; complete core dependencies remain to be reviewed with the selected effects.

No exact current official Codex/app full-text locators were obtained in this increment. Keep `checked-incursion-rosters` unsupported and all full-match/official-legality flags false, including after both players complete Warlord/Support declarations.

## Validation

Targeted checks cover materialized Captain/Lieutenant keywords before attachments, and the invariant that roster preparation cannot certify unresolved sources. Two existing startup blockers were repaired: the army builder's local `active` value now has an explicit Dictionary type, and the selection card assigns `border_width_left` through its Godot property rather than calling a nonexistent setter. No layout redesign was performed.

Final isolated run: `.tools/verification/20261018T040734735034Z/results.json`, seven processes PASS: resource import, nine Python tests, headless main-scene startup, `test_army_builder`, `test_capabilities`, `test_current_unit_abilities` and `test_roster_validation`. Earlier sandbox runs hit a Windows safe-save error; the final run used the same isolated workspace profiles outside the sandbox. No player profile was used. No graphical, separate-machine LAN or Linux validation was performed. Passing these checks establishes software behavior only, not official rules accuracy.
